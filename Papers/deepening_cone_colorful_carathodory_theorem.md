# Computational Evidence — Cone Colorful Carathéodory

The target is a universally quantified geometric theorem (colorful Carathéodory
for the origin, in cone form). Computational evidence is used here mainly to fix
the correct **color threshold** and to sanity‑check the boundary cases that the
Lean statement encodes.

## 1. Threshold check (dimension 1)

In `ℝ¹`, a finite set captures the origin conically iff it contains `0` or has
both a strictly positive and a strictly negative element.

* `r = 1` color: the single class `{1, -1}` captures `0` (nontrivial conic
  combination `1·1 + 1·(-1) = 0`), yet each singleton transversal `{1}` or
  `{-1}` spans only a half‑line and cannot capture `0`. So `r = 1 = d` **fails**.
* `r = 2 = d + 1` colors: any two classes each straddling `0` admit a colorful
  transversal capturing `0` (pick one positive from one class and one negative
  from the other).

Conclusion: the naive threshold `r ≥ d` is too optimistic; the correct threshold
is `r ≥ d + 1`. This is exactly the hypothesis `finrank + 1 ≤ #colors` used in
`colorful_caratheodory_zero` / `colorful_cone`.

## 2. Small planar instance (dimension 2)

Take `d = 2`, `d + 1 = 3` colors in `ℝ²`, each class a pair of antipodal unit
vectors straddling the origin, e.g.

* `C₀ = {( 1, 0), (-1, 0)}`
* `C₁ = {( 0, 1), ( 0,-1)}`
* `C₂ = {( 1, 1), (-1,-1)}`

Every class has `0` in its convex hull. A colorful transversal capturing `0`
exists, e.g. `t = ((1,0), (0,1), (-1,-1))`, since
`½·(1,0) + ½·(0,1) + 1·(-1,-1)`‑type nonnegative combinations vanish
(`(1,0)+(0,1)+(-1,-1) = 0`, all coefficients `1`). This matches the theorem's
guarantee.

## 3. Counterexample hunt

Attempts to violate the conclusion all reduce to using fewer than `d + 1`
colors, or to classes that do **not** capture the origin — both excluded by the
hypotheses. Under the stated hypotheses (`d + 1` classes, each capturing `0`), no
counterexample exists; this is precisely what the formal proof establishes via
the nearest‑point descent argument.

## Note

These checks are informal orientation only. The authoritative verification is the
Lean development, which builds with no `sorry` and depends only on the standard
axioms `propext`, `Classical.choice`, `Quot.sound`.


# Computational Evidence — Cone Colorful Carathéodory

The target is a universally quantified geometric theorem (colorful Carathéodory
for the origin, in cone form). Computational evidence is used here mainly to fix
the correct **color threshold** and to sanity‑check the boundary cases that the
Lean statement encodes.

## 1. Threshold check (dimension 1)

In `ℝ¹`, a finite set captures the origin conically iff it contains `0` or has
both a strictly positive and a strictly negative element.

* `r = 1` color: the single class `{1, -1}` captures `0` (nontrivial conic
  combination `1·1 + 1·(-1) = 0`), yet each singleton transversal `{1}` or
  `{-1}` spans only a half‑line and cannot capture `0`. So `r = 1 = d` **fails**.
* `r = 2 = d + 1` colors: any two classes each straddling `0` admit a colorful
  transversal capturing `0` (pick one positive from one class and one negative
  from the other).

Conclusion: the naive threshold `r ≥ d` is too optimistic; the correct threshold
is `r ≥ d + 1`. This is exactly the hypothesis `finrank + 1 ≤ #colors` used in
`colorful_caratheodory_zero` / `colorful_cone`.

## 2. Small planar instance (dimension 2)

Take `d = 2`, `d + 1 = 3` colors in `ℝ²`, each class a pair of antipodal unit
vectors straddling the origin, e.g.

* `C₀ = {( 1, 0), (-1, 0)}`
* `C₁ = {( 0, 1), ( 0,-1)}`
* `C₂ = {( 1, 1), (-1,-1)}`

Every class has `0` in its convex hull. A colorful transversal capturing `0`
exists, e.g. `t = ((1,0), (0,1), (-1,-1))`, since
`½·(1,0) + ½·(0,1) + 1·(-1,-1)`‑type nonnegative combinations vanish
(`(1,0)+(0,1)+(-1,-1) = 0`, all coefficients `1`). This matches the theorem's
guarantee.

## 3. Counterexample hunt

Attempts to violate the conclusion all reduce to using fewer than `d + 1`
colors, or to classes that do **not** capture the origin — both excluded by the
hypotheses. Under the stated hypotheses (`d + 1` classes, each capturing `0`), no
counterexample exists; this is precisely what the formal proof establishes via
the nearest‑point descent argument.

## Note

These checks are informal orientation only. The authoritative verification is the
Lean development, which builds with no `sorry` and depends only on the standard
axioms `propext`, `Classical.choice`, `Quot.sound`.
