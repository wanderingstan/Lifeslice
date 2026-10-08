# Icon artwork — one thing to know before exporting

`icon_1024.png` carries a **red-orange square hidden underneath the transparency**.

The alpha channel is correct, so the icon looks right everywhere that respects
alpha: the app icon, Finder, the Dock, the About window, a browser rendering the
PNG. But the RGB channel behind the transparent pixels is not blank. Around the
circle it is roughly `(255, 90, 2)`, spanning about x112–948, y68–924 — a square
behind the circle — and the cut slice has orange behind it too. Only the outer
corners are white underneath.

Anything that **drops** the alpha channel rather than compositing against a
background will reveal it. `Image.convert("RGB")` in Pillow does exactly that,
which is how it first showed up: a red square appeared behind the circle and the
cut slice filled in.

So before any flatten — a social preview, an email signature, a favicon, any
non-alpha export — composite onto an explicit background rather than discarding
alpha. In Pillow:

```python
icon = Image.open("icon_1024.png").convert("RGBA")
flat = Image.new("RGB", icon.size, "white")
flat.paste(icon, mask=icon.split()[3])   # the alpha channel as the mask
```

Three copies of this file exist and all are byte-identical (sha256 begins
`9f568ec211a70545`):

- `icon_1024.png` — loose source, not referenced by any build setting
- `Lifeslice.icon/Assets/icon_1024.png` — the live app icon, via Icon Composer
- `Media.xcassets/AppIcon.appiconset/icon_1024.png` — the superseded icon set

They have been left as they are. The hidden data is harmless to every consumer
that honours alpha, and rewriting the artwork would mean a new signed and
notarized build for a defect nobody can see. The fix, if it is ever worth doing,
is to zero the RGB of fully transparent pixels in all three at once.
