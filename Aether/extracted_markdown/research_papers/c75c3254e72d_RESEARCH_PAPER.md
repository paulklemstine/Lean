# Iteration and Semigroup Theory for Set-Local Distortion of Hausdorff Dimension

## Abstract

The Hausdorff dimension `dimH` is the canonical scaling invariant of a metric
set. Its distortion under maps is classically governed by three facts: Lipschitz
maps cannot increase it, Hölder maps of exponent `r` divide it by `r`, and
antilipschitz maps cannot decrease it. The first two of these are *set-local* —
they constrain only the behaviour of the map on the set under study — but the
third, the lower bound, has traditionally been available only for *globally*
antilipschitz maps. This asymmetry blocks the natural application domain of the
theory: self-maps of a fractal set, the generators of iterated function systems
and the conjugacies of dynamical systems, which are antilipschitz only on the set
they act upon.

We close this gap. We introduce the predicate `AntilipschitzOnWith K f s` — a
set-local antilipschitz condition — and prove the missing set-local lower bound
`dimH s ≤ dimH (f '' s)`. The proof is conceptually economical: the lower bound is
the existing Lipschitz upper bound applied to the (Lipschitz) left inverse of `f`
on its image. From this keystone we develop a complete *composition layer*:
set-local antilipschitz maps are injective, closed under composition with
multiplying constants, and bi-Lipschitz maps preserve dimension and compose to
dimension-preserving maps; composing Hölder maps multiplies their exponents. We
then specialise to the *iteration* setting on an invariant set `s` (with
`MapsTo f s s`): the (anti)Lipschitz constant of the `n`-fold iterate `f^[n]` is
`Kⁿ`, its Hölder exponent is `rⁿ`, and the central theorem
`dimH (f^[n] '' s) = dimH s` holds for every iterate — the orbit-piece dimension
is a constant sequence, a fixed point of the dynamics. For genuinely Hölder maps
we obtain the iterated geometric corridor `dimH (f^[n] '' s) ≤ dimH s / rⁿ`. All
results are formalised and machine-checked. We close with five concrete research
directions extending the theory to free monoids of generators, attractor fixed
points, two-sided corridors, topological entropy, and dimension-agnostic
abstraction.

---

## 1. Introduction

### 1.1 Background and motivation

Let `(X, d)` be a metric space and `s ⊆ X`. The **Hausdorff dimension** `dimH s`
is defined through the Hausdorff measures `μ^d`: it is the unique critical
exponent at which `μ^d(s)` jumps from `+∞` to `0`,

> dimH s = inf { d ≥ 0 : μ^d(s) = 0 } = sup { d ≥ 0 : μ^d(s) = +∞ }.

It is the principal invariant of fractal geometry, taking the value `log 4 / log 3
≈ 1.262` for the Koch curve, `log 3 / log 2 ≈ 1.585` for the Sierpiński gasket,
and integer values for smooth manifolds.

The behaviour of `dimH` under maps is controlled by three classical distortion
estimates. Writing `f '' s` for the image of `s` under `f`:

- **(Lipschitz upper bound.)** If `f` is `K`-Lipschitz on `s`, then
  `dimH (f '' s) ≤ dimH s`.
- **(Hölder upper bound.)** If `f` is `(C, r)`-Hölder on `s` with `0 < r ≤ 1`,
  then `dimH (f '' s) ≤ dimH s / r`.
- **(Antilipschitz lower bound.)** If `f` is `K'`-antilipschitz, then
  `dimH s ≤ dimH (f '' s)`.

The Lipschitz and Hölder estimates hold under genuinely *set-local* hypotheses:
nothing is assumed about `f` outside `s`. The antilipschitz lower bound, however,
has classically been formulated for maps that are antilipschitz on their entire
domain. This is an unfortunate asymmetry, because the maps that matter most in
fractal geometry are *self-maps* of the fractal: an iterated function system is a
family of contractions whose attractor is the unique invariant set, and the
generators are antilipschitz only on that attractor, not globally.

### 1.2 Contribution

This work supplies the missing set-local lower bound and builds the composition
and iteration theory it unlocks. The contributions are:

1. A set-local antilipschitz predicate `AntilipschitzOnWith K f s` (Section 2).
2. The injectivity lemma and the **set-local lower bound**
   `dimH s ≤ dimH (f '' s)` (Section 3), whose proof routes the antilipschitz
   inequality through the Lipschitz left inverse — the conceptual keystone.
3. A **composition layer**: closure under composition with multiplying constants,
   the bi-Lipschitz invariance `dimH (f '' s) = dimH s`, the composite invariance,
   and the product-exponent Hölder bound (Section 4).
4. An **iteration layer** on invariant sets: the `Kⁿ` and `rⁿ` constant/exponent
   laws for iterates, the main invariance theorem `dimH (f^[n] '' s) = dimH s`,
   its constancy restatement, and the iterated Hölder corridor
   `dimH (f^[n] '' s) ≤ dimH s / rⁿ` (Section 5).
5. Worked numerical applications to self-similar sets and snowflake maps
   (Section 6) and five research directions (Section 8).

All statements have been formally verified.

### 1.3 Notation

Distances are taken in the extended non-negative reals `[0,∞]` via the extended
distance `edist`, so that the antilipschitz inequality makes sense without
finiteness side-conditions. Constants `K, K', C` range over the non-negative
reals `ℝ≥0`; Hölder exponents `r` range over `ℝ≥0` and are assumed in `(0, 1]`
where stated. `f^[n]` denotes the `n`-fold composition of `f` with itself,
`f^[0]` the identity. `MapsTo f s t` means `f x ∈ t` for all `x ∈ s`.

---

## 2. The set-local antilipschitz predicate

The Mathlib library exposes `LipschitzOnWith K f s` and `HolderOnWith C r f s` as
set-local predicates, but its antilipschitz notion `AntilipschitzWith` is global.
We introduce the set-local analogue.

> **Definition 2.1 (`AntilipschitzOnWith`).** For `K : ℝ≥0`, a map `f : X → Y`,
> and `s ⊆ X`, we say `f` is *set-local antilipschitz with constant `K` on `s`*,
> written `AntilipschitzOnWith K f s`, if
>
> for all `x ∈ s` and `y ∈ s`:  edist x y ≤ K · edist (f x) (f y).

In words: distances between points of `s` can be recovered, up to the factor `K`,
from the distances of their images. The condition is exactly `AntilipschitzWith`
restricted to pairs of points in `s`. We say `f` is **set-local bi-Lipschitz on
`s`** if it is both `LipschitzOnWith K f s` and `AntilipschitzOnWith K' f s` for
some constants `K, K'`.

---

## 3. The keystone: the set-local lower bound

### 3.1 Injectivity

> **Lemma 3.1 (`AntilipschitzOnWith.injOn`).** If `AntilipschitzOnWith K f s`,
> then `f` is injective on `s`.

*Proof.* Take `x, y ∈ s` with `f x = f y`. The defining inequality gives
`edist x y ≤ K · edist (f x) (f y) = K · 0 = 0`, hence `edist x y = 0` and `x = y`.
∎

### 3.2 The lower bound

> **Theorem 3.2 (`AntilipschitzOnWith.le_dimH_image`).** If
> `AntilipschitzOnWith K f s`, then `dimH s ≤ dimH (f '' s)`.

*Proof sketch.* By Lemma 3.1, `f` is injective on `s`, so the left inverse
`g := Function.invFunOn f s` satisfies `g (f x) = x` for all `x ∈ s`
(`LeftInvOn g f s`). We claim `g` is `K`-Lipschitz on the image `f '' s`. Indeed,
any two points of `f '' s` are `f a, f b` with `a, b ∈ s`; since
`g (f a) = a` and `g (f b) = b`,

> edist (g (f a)) (g (f b)) = edist a b ≤ K · edist (f a) (f b),

which is precisely `LipschitzOnWith K g (f '' s)`. Now apply the Lipschitz upper
bound (`LipschitzOnWith.dimH_image_le`) to `g`:

> dimH (g '' (f '' s)) ≤ dimH (f '' s).

Finally `g '' (f '' s) = s` because `g ∘ f` is the identity on `s`
(`LeftInvOn.image_image`), giving `dimH s ≤ dimH (f '' s)`. ∎

The proof is the conceptual heart of the development: the lower bound is *not*
new geometry, it is the Lipschitz upper bound applied to the left inverse.
Antilipschitz-on-`s` is precisely the statement that the inverse is Lipschitz on
`f '' s`. (A practical subtlety in the formalisation: a naive rewrite of
`g '' (f '' s) = s` rewrites both occurrences of `s` in the goal
`dimH s ≤ dimH (f '' s)`; the fix is to isolate the left-hand `s` in a `calc`
step so only the intended occurrence is rewritten.)

---

## 4. The composition layer

### 4.1 Bi-Lipschitz invariance

> **Theorem 4.1 (`dimH_image_eq`).** If `LipschitzOnWith K f s` and
> `AntilipschitzOnWith K' f s`, then `dimH (f '' s) = dimH s`.

*Proof.* The Lipschitz upper bound gives `dimH (f '' s) ≤ dimH s`; Theorem 3.2
gives `dimH s ≤ dimH (f '' s)`. Antisymmetry of `≤` concludes. ∎

### 4.2 Closure under composition

> **Theorem 4.2 (`AntilipschitzOnWith.comp`).** Let `f : X → Y` with
> `AntilipschitzOnWith Kf f s`, `g : Y → Z` with `AntilipschitzOnWith Kg g t`,
> and `MapsTo f s t`. Then `AntilipschitzOnWith (Kf · Kg) (g ∘ f) s`.

*Proof.* For `x, y ∈ s`, chain the two defining inequalities:

> edist x y ≤ Kf · edist (f x) (f y) ≤ Kf · (Kg · edist (g (f x)) (g (f y)))
> = (Kf · Kg) · edist ((g∘f) x) ((g∘f) y),

using `MapsTo f s t` to apply the hypothesis on `g` to the points
`f x, f y ∈ t`. ∎

The companion `LipschitzOnWith.comp` (from Mathlib) shows the Lipschitz class is
closed under composition with the same multiplicative law on constants. Combining
the two:

> **Theorem 4.3 (`dimH_image_comp_eq`).** If `f` is set-local bi-Lipschitz on `s`
> into `t` and `g` is set-local bi-Lipschitz on `t`, then
> `dimH ((g ∘ f) '' s) = dimH s`.

*Proof.* By the two composition lemmas, `g ∘ f` is set-local bi-Lipschitz on `s`;
apply Theorem 4.1. ∎

### 4.3 Product-exponent Hölder bound

> **Theorem 4.4 (`dimH_image_comp_holder_le`).** If `HolderOnWith Cf rf f s` with
> `MapsTo f s t` and `HolderOnWith Cg rg g t`, with `0 < rg · rf`, then
> `dimH ((g ∘ f) '' s) ≤ dimH s / (rg · rf)`.

*Proof.* `HolderOnWith.comp` shows `g ∘ f` is `(C, rg · rf)`-Hölder on `s` for a
suitable constant `C`; the Hölder upper bound `HolderOnWith.dimH_image_le` (which
requires the exponent positive) divides the dimension by `rg · rf`. ∎

---

## 5. The iteration layer

We now specialise composition to a single self-map. Fix `f : X → X` and an
**invariant** set `s` with `MapsTo f s s`, i.e. `f` maps `s` into itself. Then
every iterate `f^[n]` also maps `s` into itself, and the composition lemmas can be
applied `n` times.

### 5.1 Iterated constants and exponents

> **Lemma 5.1 (`lipschitzOnWith_iterate`).** If `LipschitzOnWith K f s` and
> `MapsTo f s s`, then `LipschitzOnWith (K^n) (f^[n]) s` for all `n`.

> **Lemma 5.2 (`antilipschitzOnWith_iterate`).** If `AntilipschitzOnWith K f s`
> and `MapsTo f s s`, then `AntilipschitzOnWith (K^n) (f^[n]) s` for all `n`.

> **Lemma 5.3 (`holderOnWith_iterate`).** If `HolderOnWith C r f s` (with the
> natural normalisation) and `MapsTo f s s`, then `f^[n]` is Hölder on `s` with
> exponent `r^n`.

*Proof (all three).* Induction on `n`. The base case `n = 0` is the identity,
which is `1`-Lipschitz / `1`-antilipschitz / exponent-`1` Hölder, matching
`K^0 = 1`, `r^0 = 1`. For the step, write `f^[n+1] = f ∘ f^[n]`, observe `f^[n]`
maps `s` into `s` by invariance, and apply the relevant composition lemma
(`LipschitzOnWith.comp`, Theorem 4.2, `HolderOnWith.comp`): constants multiply to
`K · K^n = K^{n+1}` and exponents to `r · r^n = r^{n+1}`. ∎

### 5.2 Main theorem: iterated invariance

> **Theorem 5.4 (`dimH_image_iterate_eq`, main).** If `f` is set-local
> bi-Lipschitz on `s` (`LipschitzOnWith K f s` and `AntilipschitzOnWith K' f s`)
> and `MapsTo f s s`, then for every `n`,
>
> dimH (f^[n] '' s) = dimH s.

*Proof.* By Lemmas 5.1 and 5.2, `f^[n]` is `LipschitzOnWith (K^n) (f^[n]) s` and
`AntilipschitzOnWith (K'^n) (f^[n]) s`, i.e. set-local bi-Lipschitz on `s`. Apply
Theorem 4.1 (`dimH_image_eq`) to `f^[n]`. ∎

> **Corollary 5.5 (`dimH_image_iterate_const`).** Under the hypotheses of
> Theorem 5.4, the sequence `n ↦ dimH (f^[n] '' s)` is constant, equal to
> `dimH s`.

This is the precise statement that the orbit-piece dimension is a fixed point of
the iteration dynamics.

### 5.3 The iterated Hölder corridor

> **Theorem 5.6 (`dimH_image_iterate_le`).** If `f` is `(C, r)`-Hölder on `s`
> with `0 < r ≤ 1` and `MapsTo f s s`, then for every `n`,
>
> dimH (f^[n] '' s) ≤ dimH s / rⁿ.

*Proof.* By Lemma 5.3, `f^[n]` is Hölder on `s` with exponent `r^n`, which is
positive since `r > 0`. Apply the Hölder upper bound to `f^[n]`. ∎

When `r < 1`, `1/rⁿ → ∞` geometrically, so the bound permits geometric inflation
of dimension under iteration of a wild map — a quantitative, certified ceiling on
the snowflaking phenomenon.

---

## 6. Worked examples

### 6.1 Bi-Lipschitz self-map of the Cantor set

Let `C ⊆ [0,1]` be the middle-thirds Cantor set, `dimH C = log 2 / log 3 ≈ 0.6309`.
The self-map `f(x) = x/3` maps `C` into its left third `C ∩ [0, 1/3]`, with
`MapsTo f C C`. On `C`, `f` is exactly `(1/3)`-Lipschitz and `3`-antilipschitz —
a genuine set-local bi-Lipschitz self-map. Theorem 5.4 gives
`dimH (f^[n] '' C) = dimH C = log 2 / log 3` for every `n`, even though the orbit
pieces `f^[n] '' C ⊆ [0, 3^{-n}]` shrink to the single point `{0}` in Hausdorff
*measure*. Dimension is scale-invariant; measure is not. This is the cleanest
illustration of the theorem's content.

### 6.2 Snowflake map and the corridor

The snowflake map `f(x) = x^a` on `[0,1]` with `0 < a < 1` is `(1, a)`-Hölder and
maps `[0,1]` into itself. Iterating, `f^[n](x) = x^{aⁿ}`, which is Hölder of
exponent `aⁿ`. Theorem 5.6 yields `dimH (f^[n] '' [0,1]) ≤ 1 / aⁿ`. Since the
image is again `[0,1]` (dimension 1), the bound `1/aⁿ ≥ 1` is consistent and the
inequality is far from tight here — illustrating that the corridor is an *upper*
wall whose tightness depends on the geometry of `s`; embedding a snowflaked set of
positive dimension makes the bound bite.

### 6.3 Composition of distinct similarities

Take `f(x) = x/2` and `g(x) = x/3` on `[0,1]`, with constants `1/2` (Lipschitz),
`2` (antilipschitz) and `1/3`, `3` respectively. By Theorem 4.3,
`dimH ((g ∘ f) '' s) = dimH s` for any `s`; the composite has Lipschitz constant
`1/6` and antilipschitz constant `6`. This is the two-generator seed of the free
monoid of Direction 1.

---

## 7. Discussion

The development illustrates a recurring principle in metric geometry: *duality
between expansion and contraction estimates*. The Lipschitz upper bound and the
antilipschitz lower bound are not two independent theorems but one theorem applied
to a map and its inverse. Formalising the set-local antilipschitz predicate makes
this duality precise and exploitable, and it is exactly what lifts the dimension
theory from globally-defined maps to the self-maps of fractal geometry.

The multiplicativity of constants under composition (`Kf · Kg`) and of exponents
(`rg · rf`) is the algebraic backbone of the iteration theory. It says that the
assignment `f ↦ (its distortion data)` is a homomorphism from the composition
monoid of maps to the multiplicative monoid `(ℝ≥0, ·)`. The single-generator
iterates studied here are the cyclic submonoid generated by one map; the general
theory lives over the free monoid on a family of generators (Direction 1).

The constancy result (Corollary 5.5) is the rigorous form of the folklore that "a
self-similar fractal's dimension is the fixed point of its generating dynamics."
The theorem proves the fixed-point property unconditionally for bi-Lipschitz
self-maps; pinning the *value* to the similarity dimension `log m / log (1/K)`
additionally requires a separation hypothesis (the open set condition), which is
combinatorial rather than analytic and is the subject of Direction 2.

---

## 8. Future directions

**Direction 1 — From discrete iterates to the monoid of distortion exponents.**
Replace the single map by a finite family `{f_1, …, f_m}`, each bi-Hölder on a
common invariant `s`, indexed by words `w ∈ {1,…,m}^*`. Conjecture: for every
word the composite `f_w = f_{w_1} ∘ ⋯ ∘ f_{w_k}` satisfies
`dimH (f_w '' s) ≤ dimH s / ∏ r_{w_i}`, i.e. distortion exponents form a
multiplicative homomorphism from the free monoid into `(ℝ≥0, ·)`, with
`dimH_image_iterate_le` the single-generator restriction. Since `HolderOnWith.comp`
already multiplies exponents per step, the only new content is a `List.prod`
induction over the word — structurally identical to the iterate induction.

**Direction 2 — Invariant-set dimension as a fixed point: the attractor bound.**
For a contraction `f` (`LipschitzOnWith K f s` with `K < 1`) mapping `s` into
itself, the orbit pieces `f^[n] '' s` are nested and shrink. Conjecture: if `s` is
the attractor (so `f '' s = s` up to closure), then `dimH_image_iterate_eq` forces
`dimH (f^[n] '' s)` to be constant, and combined with a Moran-type open set
condition the common value is pinned to the similarity dimension
`log m / log (1/K)` for an `m`-map system. The constancy is exactly the new
theorem; the open set condition is a combinatorial (disjointness) hypothesis.

**Direction 3 — Quantitative failure of invariance for genuinely Hölder maps.**
`dimH_image_iterate_le` gives only the upper wall `dimH s / rⁿ`. A companion lower
bound (via a Hölder left inverse of exponent `r'`) would squeeze the iterated
image dimension into a shrinking-or-growing geometric corridor. Falsifiable claim:
explicit snowflake maps `x ↦ x^a` on `[0,1]` make both iterated bounds tight, so
the corridor cannot be narrowed without extra hypotheses. The two-sided one-step
estimate already exists; iterating the inverse exponent in parallel yields the
lower wall.

**Direction 4 — Topological-entropy lower bound from antilipschitz iteration.**
`antilipschitzOnWith_iterate` says distances are recovered up to `Kⁿ` after `n`
steps — precisely the separation rate lower-bounding topological entropy.
Conjecture: `h_top(f|_s) ≥ log(1/K_anti)` whenever `f` is set-local antilipschitz
with constant `K_anti < 1` on a compact invariant `s`. Antilipschitz-on-`s` with
constant `< 1` is an expansivity certificate; the iterate lemma turns one-step
expansivity into the `Kⁿ` separation needed for the Bowen entropy lower bound.

**Direction 5 — Bi-Lipschitz iteration invariance for box / Assouad dimension.**
The iteration argument is dimension-agnostic: it uses only monotonicity under
set-local Lipschitz images and invariance under set-local bi-Lipschitz maps.
Abstracting these two properties into a `SetLocalDimension` typeclass makes
`dimH_image_iterate_eq` a one-line corollary for box-counting and Assouad
dimension once those are formalised.

---

## 9. Conclusion

By recognising that the set-local antilipschitz lower bound is the Lipschitz upper
bound read through the inverse map, we have completed the set-local distortion
theory of Hausdorff dimension and extended it to the iteration setting. The main
theorem — invariance of `dimH` under every iterate of a set-local bi-Lipschitz
self-map — establishes that the dimension of a fractal's orbit pieces is a fixed
point of its generating dynamics, and the Hölder corridor bounds the inflation of
dimension under wild iteration. The composition multiplicativity of constants and
exponents exposes the semigroup structure underlying the whole theory and points
directly to the free-monoid generalisation that governs general iterated function
systems.
