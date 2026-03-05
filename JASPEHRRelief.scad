//
// OpenSCAD: cleaned SVG をレリーフ化 + 新しい text() タグライン追加
// 対象SVG: logo_color_withoutStr.svg（小さな英文を削除済み）
//
// 使い方:
// 1) 本 .scad と logo_color_withoutStr.svg を同じフォルダに置く
// 2) F5(プレビュー)でサイズや位置を合わせる → F6(Render) → STLエクスポート
//

$fn = 64;

// === 入力SVG ===
svg_file = "logo_color_withoutStr.svg";

// === 寸法・押し出し(mm) ===
target_width = 120;     // 仕上がり横幅（ロゴ全体）
relief_high  = 6.0;     // レリーフ高さ（ロゴ＆文字）
base_thick   = 1.8;     // ベース板厚

// === 幾何修復・安定化 ===
heal_delta   = 0.02;    // 0→0.01→0.05→0.1…（Renderで欠けたら上げる）
convexity_v  = 12;

// === ベース形状 ===
use_base         = true;       // ベースが不要なら false
base_mode        = "rect";  // "outline" or "rect"
base_margin      = 4.0;        // outlineベース時の余白
rect_extra_marg  = 49.0;        // 矩形ベースの余白
svg_aspect_guess = 0.35;       // 矩形ベースの縦横比目安 (高さ=target_width*この値)

// === SVGスケール ===
svg_width_guess = 200;         // 元SVGの仮の横幅（座標目安）→プレビューで調整
scale_factor    = target_width / svg_width_guess;

// === 新しいタグライン ===
tag_text  = "the Japanese Standard Platform for EHRs";
tag_font  = "Liberation Sans:style=Bold";  // 任意のフォントに変更可
tag_size  = 6.0;       // 文字サイズ(mm)
tag_track = 0;         // 字間調整（必要に応じて）
tag_pos_y = -0.48 * target_width;  // 下方向オフセット（プレビューで微調整）
tag_pos_x = 5;         // 水平オフセット

// === モジュール ===
module logo_2d_clean(){
  offset(delta=heal_delta)
    scale([scale_factor, scale_factor, 1])
      import(file=svg_file, center=true, convexity=convexity_v, dpi=96);
}

module relief_logo(){
  translate([0,0, base_thick])
    linear_extrude(height=relief_high, convexity=convexity_v)
      logo_2d_clean();
}

module base_outline(){
  linear_extrude(height=base_thick, convexity=convexity_v)
    offset(delta=base_margin)
      logo_2d_clean();
}

module base_rect(){
  base_w = target_width + 2*rect_extra_marg;
  base_h = target_width*svg_aspect_guess + 2*rect_extra_marg;
  translate([0,0, base_thick/2])
    cube([base_w, base_h, base_thick], center=true);
}

module tagline(){
  translate([tag_pos_x, tag_pos_y, base_thick])
    linear_extrude(height=relief_high, convexity=convexity_v)
      text(tag_text, size=tag_size, font=tag_font,
           halign="center", valign="center", spacing=1.0 + tag_track/10.0);
}

module model(){
  if (use_base){
    if (base_mode == "outline") base_outline(); else base_rect();
  }
  relief_logo();
  tagline();
}

model();
