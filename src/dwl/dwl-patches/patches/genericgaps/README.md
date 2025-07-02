### Description

This patch adds gaps around windows and works with any layout (the layout code
does not need to know about the gaps). This patch is a modified version of
[vanitygaps][vanitygaps] patch.

This works by allowing layout code to place clients normally without gaps, and
then correcting positions and sizes of clients afterwards to add gaps around
them. This approach is very flexible but there is one small downside: you will
always have "outer" gaps (between edges of a monitor and a window) if "inner"
gaps are non-zero. But for me it's not a problem because I always want "outer"
gaps to be as big or bigger than "inner" gaps anyway.

[vanitygaps]: /dwl/dwl-patches/src/branch/main/patches/vanitygaps

### Download

- [0.7 2025-02-11](/dwl/dwl-patches/raw/branch/main/patches/genericgaps/genericgaps-0.7.patch):
  added support for `smartgaps` and `monoclegaps` settings and removed the suck
  from `arrange()` function
- [0.7](/dwl/dwl-patches/raw/branch/main/patches/genericgaps/genericgaps.patch)

### Authors

- [Nikita Ivanov](https://codeberg.org/nikitaivanov) ([GitHub](https://github.com/NikitaIvanovV))
