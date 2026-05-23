# 🌌 Aurora Abyss

A dark, immersive theme for the **pi TUI** featuring a minimal 8-shade pastel palette. It uses a dark/purple base with soft pastel and gray accents, ensuring a consistent, immersive, and highly readable experience while significantly reducing color complexity.

---

## ✨ Design Principles

1. **Minimalist 8-Color Palette** — Strictly limited to 8 colors to reduce complexity and cognitive load
2. **60-30-10 Rule** — Balanced distribution of Dominant, Secondary, and Accent colors
3. **Pastel Harmony** — Soft purple, cyan, pink, and gold accents over a dark purple/gray base
4. **High Readability** — High-contrast text on muted surfaces for a comfortable coding experience
5. **Semantic Clarity** — Consistent use of colors for specific UI states and interactions

---

## 🎨 Color Palette

We use a clean **60-30-10** breakdown with a strict 8-shade pastel palette:

### 60% Dominant (Neutrals)
- `base`: `#191724`
- `surface`: `#1f1d2e`
- `muted`: `#6e6a86`
- `text`: `#e0def4`

### 30% Secondary (Primary/Brand)
- `primary`: `#c4a7e7` (Pastel Purple)
- `secondary`: `#9ccfd8` (Pastel Cyan)

### 10% Accent
- `accent`: `#eb6f92` (Pastel Pink)
- `warning`: `#f6c177` (Pastel Gold)

### Thinking Level Gradient 🌈
```
Off ──▶ Minimal ──▶ Low ──▶ Medium ──▶ High ──▶ XHigh
#1f1d2e   #6e6a86   #c4a7e7  #9ccfd8   #f6c177  #eb6f92
  ■━━━━━━━━■━━━━━━━━━■━━━━━━━━■━━━━━━━━■━━━━━━━━■
  Surface  Muted      Primary  Secondary Warning  Accent
```

---

## 📦 Installation

### Option 1: Local Extension (recommended)
Place this directory in your pi extensions folder:
```bash
cp -r aurora-abyss ~/.pi/agent/extensions/
```

### Option 2: npm package (if published)
```bash
pi install aurora-abyss
```

## 🔧 Activation

1. Open pi
2. Run `/settings`
3. Set `"theme": "aurora-abyss"`
4. Save — pi will hot-reload the theme automatically

Or manually edit `~/.pi/agent/settings.json`:
```json
{
  "theme": "aurora-abyss"
}
```

---

## 📄 License

MIT — Use freely, modify as you wish.
