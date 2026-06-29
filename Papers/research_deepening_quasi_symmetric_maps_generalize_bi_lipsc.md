# Composition Theory for Set-Local Distortion of Hausdorff Dimension

## Abstract

We develop a composition calculus for the *set-local* distortion of Hausdorff
dimension under maps that are well behaved only on a prescribed subset. Building
on a previously established single-map theory — set-local bi-Lipschitz
invariance, a set-local antilipschitz lower bound, and a two-sided Hölder
("quasi-symmetric flavored") distortion estimate — we close the principal
structural gap: behavior under **composition**. We introduce and study the
set-local predicate `AntilipschitzOnWith K f s`, prove it is closed under
composition (with multiplied constants), under restriction to subsets, and that
it is implied by the classical global antilipschitz condition. These closure
properties upgrade the single-map invariance theorem to a *composite*
bi-Lipschitz invariance theorem, and — our headline result — to a *composite
bi-Hölder distortion bound* in which the four Hölder exponents combine
multiplicatively as the two products `r_g · r_f` (forward) and `r_f' · r_g'`
(inverse). Setting all exponents to `1` recovers exact composite invariance,
confirming internal consistency. The emergent structural lesson is that the
theory is *functorial in the set-local map*: distortion is a multiplicative
invariant on a category of set-local bi-Hölder maps. All results are formalized
and machine-checked.

**Keywords:** Hausdorff dimension, quasi-symmetric maps, bi-Lipschitz maps,
Hölder continuity, antilipschitz maps, fractal geometry, iterated function
systems, composition.

---

## 1. Introduction

### 1.1 Background and motivation

The Hausdorff dimension `dimH s ∈ [0, ∞]` of a subset `s` of a metric space is
the canonical measure of its metric "roughness" or fractal complexity. A
foundational principle of geometric measure theory is that this number is robust
under controlled deformation. Classically:

- A **Lipschitz** map (`d(f x, f y) ≤ K · d(x, y)`) cannot *increase* Hausdorff
  dimension: `dimH(f(s)) ≤ dimH s`.
- An **antilipschitz** map (`d(x, y) ≤ K · d(f x, f y)`) cannot *decrease* it:
  `dimH s ≤ dimH(f(s))`.
- A **bi-Lipschitz** map (both at once) therefore preserves it exactly.
- A **Hölder** map of exponent `r` (`d(f x, f y) ≤ C · d(x, y)^r`) distorts it by
  the factor `1/r`: `dimH(f(s)) ≤ dimH s / r`.

Mathlib provides these facts for maps that are well behaved *globally*. But the
maps that arise throughout fractal geometry — iterated function system (IFS)
generators, quasi-symmetric conjugacies between attractors, snowflaking maps,
local coordinate charts on self-similar sets — are almost never globally
controlled. They are controlled only on the *piece* under study. A usable theory
must therefore be **set-local**: the hypotheses must constrain `f` only on a
chosen subset `s`, and the conclusions must concern only the image of that
subset.

The single-map set-local theory was established previously (summarized in §2). It
left open the structural property that matters most for fractals:
**composition**. Fractals are built by *chaining* good maps on nested pieces; a
distortion calculus that does not compose is not yet usable. This paper closes
that gap.

### 1.2 Contributions

We prove the following (all formalized and machine-checked):

1. **`AntilipschitzOnWith.comp`** — the set-local antilipschitz class is closed
   under composition, with constants multiplying: `K_f · K_g`.
2. **`AntilipschitzOnWith.mono`** — restriction of a set-local antilipschitz map
   to a subset preserves the property with the same constant.
3. **`antilipschitzOnWith_of_antilipschitzWith`** — a globally antilipschitz map
   is antilipschitz on every subset.
4. **`dimH_image_comp_eq_of_lipschitzOn_antilipschitzOn`** — Hausdorff dimension
   is invariant under a composite of two set-local bi-Lipschitz maps.
5. **`dimH_image_comp_bounds_of_biholderOn`** — composite quasi-symmetric
   distortion: chaining two bi-Hölder maps multiplies the exponents, giving
   `dimH((g∘f)(s)) ≤ dimH s / (r_g · r_f)` and
   `dimH s ≤ dimH((g∘f)(s)) / (r_f' · r_g')`.

### 1.3 Conventions

Throughout, `X`, `Y`, `Z` are extended metric spaces (`EMetricSpace`), distances
are written with the extended metric `edist : · → · → ℝ≥0∞`, and constants
`K, C, r` range over the nonnegative reals `ℝ≥0`. We write `f '' s` for the image
of `s` under `f`, `g ∘ f` for composition, and `dimH` for Hausdorff dimension
valued in `ℝ≥0∞`. Division of an extended nonnegative real by a nonnegative real
is the usual extended-real division.

---

## 2. The single-map theory (prerequisites)

We recall the four pillars on which the composition theory rests. Each is a
machine-checked theorem; here we give the statement and a proof sketch.

### 2.1 Lower bounds from a Lipschitz left inverse

**Lemma 2.1 (`le_dimH_image_of_lipschitzOn_leftInverse`).**
Let `f : X → Y`, `g : Y → X`, `s ⊆ X`. If `g` is Lipschitz on the image `f '' s`
and `g(f x) = x` for all `x ∈ s`, then `dimH s ≤ dimH(f '' s)`.

*Proof sketch.* Since `g` undoes `f` on `s`, one checks the set identity
`g '' (f '' s) = s`: the forward inclusion uses `g(f x) = x`, the reverse picks
the witness `f x`. Lipschitz maps do not increase Hausdorff dimension, so
`dimH(g '' (f '' s)) ≤ dimH(f '' s)`. Rewriting the left side as `dimH s` gives
the claim. ∎

### 2.2 Set-local bi-Lipschitz invariance (extrinsic form)

**Theorem 2.2 (`dimH_image_eq_of_lipschitzOn_lipschitzOn_inverse`).**
If `f` is Lipschitz on `s` and admits a left inverse `g` Lipschitz on `f '' s`,
then `dimH(f '' s) = dimH s`.

*Proof sketch.* The Lipschitz upper bound `dimH(f '' s) ≤ dimH s` and the lower
bound of Lemma 2.1 combine by antisymmetry. ∎

### 2.3 Two-sided Hölder distortion

**Theorem 2.3 (`dimH_image_bounds_of_holderOn_holderOn_inverse`).**
If `f` is Hölder on `s` with exponent `r_f > 0`, and `g` is a left inverse Hölder
on `f '' s` with exponent `r_g > 0`, then
```
dimH(f '' s) ≤ dimH s / r_f    and    dimH s ≤ dimH(f '' s) / r_g.
```

*Proof sketch.* The forward bound is the Hölder dimension estimate applied to
`f`. For the dual bound, use the identity `g '' (f '' s) = s` and apply the
Hölder dimension estimate to `g` on `f '' s`. Setting `r_f = r_g = 1` recovers
Theorem 2.2. ∎

### 2.4 The set-local antilipschitz predicate

**Definition 2.4 (`AntilipschitzOnWith`).** For `K : ℝ≥0`, `f : X → Y`,
`s ⊆ X`,
```
AntilipschitzOnWith K f s  :⇔  ∀ x ∈ s, ∀ y ∈ s,  edist x y ≤ K · edist (f x) (f y).
```
This is the set-local analogue of Mathlib's global `AntilipschitzWith`.

**Lemma 2.5 (`AntilipschitzOnWith.injOn`).** A set-local antilipschitz map is
injective on `s`.
*Proof sketch.* If `f x = f y` the bound gives `edist x y ≤ K · 0 = 0`, hence
`x = y`. ∎

**Lemma 2.6 (`AntilipschitzOnWith.lipschitzOnWith_invFunOn`).** The canonical
left inverse `invFunOn f s` is Lipschitz with constant `K` on `f '' s`.
*Proof sketch.* Rewrite `invFunOn` at image points via injectivity (Lemma 2.5),
reducing the Lipschitz bound on `f '' s` to the antilipschitz bound on `s`. ∎

**Theorem 2.7 (`AntilipschitzOnWith.le_dimH_image`).** If `f` is antilipschitz on
`s` then `dimH s ≤ dimH(f '' s)`.
*Proof sketch.* Apply Lemma 2.1 to the canonical Lipschitz left inverse of
Lemma 2.6. ∎

**Theorem 2.8 (`dimH_image_eq_of_lipschitzOn_antilipschitzOn`).** If `f` is both
Lipschitz and antilipschitz on `s`, then `dimH(f '' s) = dimH s`.
*Proof sketch.* Lipschitz gives `dimH(f '' s) ≤ dimH s`; antilipschitz gives the
reverse via Theorem 2.7; combine by antisymmetry. ∎

This intrinsic invariance theorem (single map) is the object we now lift to
composites.

---

## 3. Composition closure of the set-local antilipschitz class

The structural core of the paper is that `AntilipschitzOnWith` is a *well-behaved
class*: closed under composition and restriction, and implied by its global
counterpart.

### 3.1 Composition

**Theorem 3.1 (`AntilipschitzOnWith.comp`).**
Let `f : X → Y`, `g : Y → Z`, `s ⊆ X`. If `g` is antilipschitz on the image
`f '' s` with constant `K_g` and `f` is antilipschitz on `s` with constant `K_f`,
then `g ∘ f` is antilipschitz on `s` with constant `K_f · K_g`:
```
AntilipschitzOnWith K_g g (f '' s)  →  AntilipschitzOnWith K_f f s
                                    →  AntilipschitzOnWith (K_f · K_g) (g ∘ f) s.
```

*Proof sketch.* Fix `x, y ∈ s`. Chain the two guarantees:
```
edist x y
   ≤ K_f · edist (f x) (f y)                         (antilipschitz of f on s)
   ≤ K_f · (K_g · edist (g (f x)) (g (f y)))         (antilipschitz of g on f '' s,
                                                        applied at f x, f y ∈ f '' s)
   = (K_f · K_g) · edist ((g∘f) x) ((g∘f) y).         (associativity / commutativity)
```
The membership `f x ∈ f '' s` is automatic (`Set.mem_image_of_mem`). The middle
step uses monotonicity of multiplication on `ℝ≥0∞` (`gcongr`); the final step is
routine `ℝ≥0∞` arithmetic. This is the exact set-local dual of
`LipschitzOnWith.comp`. ∎

This is the lynchpin: it says distortion *control* survives chaining, and that
the antilipschitz constant of a pipeline is the product of the stage constants.

### 3.2 Restriction

**Theorem 3.2 (`AntilipschitzOnWith.mono`).** If `f` is antilipschitz on `s` with
constant `K` and `t ⊆ s`, then `f` is antilipschitz on `t` with the same constant
`K`.
*Proof sketch.* The pointwise defining inequality for `x, y ∈ t` is an instance of
the inequality for `x, y ∈ s` via the inclusion `t ⊆ s`. ∎

This is essential for IFS arguments, where one repeatedly zooms into nested
sub-pieces and needs the control to descend.

### 3.3 Global implies local

**Theorem 3.3 (`antilipschitzOnWith_of_antilipschitzWith`).** If `f` is
(globally) `AntilipschitzWith K`, then `AntilipschitzOnWith K f s` for every set
`s`.
*Proof sketch.* The global pointwise bound holds for all `x, y`, in particular for
`x, y ∈ s`. ∎

This bridges the new set-local theory to Mathlib's classical global theory: every
theorem proved set-locally specializes correctly to globally good maps.

---

## 4. Dimension invariance and distortion under composition

We now harvest the closure properties.

### 4.1 Composite bi-Lipschitz invariance

**Theorem 4.1 (`dimH_image_comp_eq_of_lipschitzOn_antilipschitzOn`).**
Let `f : X → Y`, `g : Y → Z`, `s ⊆ X`. Suppose:

- `f` is Lipschitz on `s` and antilipschitz on `s`;
- `g` is Lipschitz on `f '' s` and antilipschitz on `f '' s`.

Then
```
dimH ((g ∘ f) '' s) = dimH s.
```

*Proof sketch.* Lipschitz-on maps compose (`LipschitzOnWith.comp`, with the
`MapsTo` side-condition `f` maps `s` into `f '' s`, which is automatic), so
`g ∘ f` is Lipschitz on `s`. Antilipschitz-on maps compose by Theorem 3.1, so
`g ∘ f` is antilipschitz on `s`. Identifying `(g∘f) '' s` with `g '' (f '' s)`
via `Set.image_comp`, apply the single-map intrinsic invariance Theorem 2.8 to
`g ∘ f` on `s`. ∎

The result extends verbatim, by induction, to any finite chain of set-local
bi-Lipschitz maps: dimension is invariant along an arbitrarily long bi-Lipschitz
pipeline.

### 4.2 Composite quasi-symmetric (bi-Hölder) distortion — main theorem

**Theorem 4.2 (`dimH_image_comp_bounds_of_biholderOn`).**
Let `f : X → Y`, `g : Y → Z`, with left inverses `f⁻` on `s` and `g⁻` on
`f '' s`. Suppose `f` is bi-Hölder on `s` with forward exponent `r_f > 0` and
inverse exponent `r_f' > 0`, and `g` is bi-Hölder on `f '' s` with forward
exponent `r_g > 0` and inverse exponent `r_g' > 0`. Then
```
dimH ((g∘f) '' s) ≤ dimH s / (r_g · r_f)    and    dimH s ≤ dimH ((g∘f) '' s) / (r_f' · r_g').
```

*Proof sketch.* The composite of Hölder maps is Hölder with multiplied exponents:
if `f` is `(C_f, r_f)`-Hölder on `s` and `g` is `(C_g, r_g)`-Hölder on `f '' s`,
then `g ∘ f` is Hölder on `s` with exponent `r_g · r_f` (and constant
`C_g · C_f^{r_g}`), via `HolderOnWith.comp` and the `MapsTo` condition that `f`
sends `s` into `f '' s`. The same applies to the inverse direction with exponent
`r_f' · r_g'`. Identify `(g∘f) '' s` with `g '' (f '' s)` (`Set.image_comp`) and
apply the single-map two-sided Hölder estimate Theorem 2.3 to the composite. The
forward Hölder bound yields `dimH((g∘f) '' s) ≤ dimH s / (r_g · r_f)`; the inverse
Hölder bound yields the dual. ∎

**Corollary 4.3 (consistency).** Setting `r_f = r_f' = r_g = r_g' = 1` in
Theorem 4.2 gives both `r_g · r_f = 1` and `r_f' · r_g' = 1`, so the two
inequalities become `dimH((g∘f) '' s) ≤ dimH s` and `dimH s ≤ dimH((g∘f) '' s)`,
i.e. exact equality — recovering Theorem 4.1. The bi-Hölder theory degenerates
correctly to the bi-Lipschitz theory.

### 4.3 The multiplicativity principle

The single line that all of §4 expresses is:

> **Distortion exponents are multiplicative under composition.**

The reason is the algebra of nested rescaling: a Hölder map of exponent `r`
transforms an infinitesimal scale `δ` as `δ ↦ δ^r`, and composing two such maps
gives `δ ↦ δ^{r_f} ↦ δ^{r_f · r_g}`, because `(δ^{r_f})^{r_g} = δ^{r_f · r_g}`.
The Hausdorff dimension reads this exponent off directly, so the dimension
distortion factor of a pipeline is the product of the stage factors. The
constants `C` and the antilipschitz `K` multiply (additively in their
logarithms); the *exponents* multiply directly. This is the dimensional shadow of
the fact that snowflaking and Hölder conjugation compose.

---

## 5. Algorithms

Although the theory is qualitative (it concerns invariance and inequalities), it
yields a directly computable *certified distortion calculus*. Given a description
of each stage as a tuple of constants and exponents, one can compute the
guaranteed dimension envelope of an arbitrarily long pipeline.

**Algorithm 5.1 (Pipeline distortion envelope).**
*Input:* a base dimension `d = dimH s`, and a list of stages, each a record
`(r_forward, r_inverse)` of positive Hölder exponents (use `1` for a Lipschitz
stage).
*Output:* an interval `[lo, hi]` guaranteed to contain `dimH` of the final image.
*Method:* fold the list, multiplying forward exponents into `R_f` and inverse
exponents into `R_i`; return `[d / R_i, d / R_f]`. If every stage is bi-Lipschitz
(`R_f = R_i = 1`) the interval collapses to the point `d`.

**Algorithm 5.2 (Antilipschitz constant accumulation).**
*Input:* per-stage antilipschitz constants `K_1, …, K_n`.
*Output:* the certified antilipschitz constant `K_1 · K_2 · … · K_n` of the
composite (Theorem 3.1).

These are not heuristics: each output is a theorem-backed guarantee.

---

## 6. Applications

- **Iterated function systems.** An IFS attractor is the fixed point of a
  finite family of contractions assembled by composition on nested cylinder
  sets. Theorems 3.1–3.2 give descending control on every cylinder; Theorem 4.1
  certifies that the dimension is stable along the construction; Theorem 4.2
  bounds it under Hölder-only generators.
- **Quasi-symmetric rigidity.** A quasi-symmetric conjugacy between two fractals
  is glued from local bi-Hölder pieces. Theorem 4.2 quantifies exactly how much
  the Hausdorff dimension can drift across the conjugacy, with the drift governed
  by the product of local exponents; Corollary 4.3 isolates the rigid
  (dimension-preserving) bi-Lipschitz regime.
- **Dynamical systems.** Comparing two systems via composed coordinate changes,
  Theorem 4.1 certifies that fractal invariants of strange attractors are
  intrinsic rather than coordinate artifacts.

---

## 7. Discussion

The proofs reveal a uniform pattern: the dimension estimates are mechanical
*consequences* of two structural facts — that a class is closed under composition
and restriction, and that a one-step distortion estimate holds. The bookkeeping
(rewriting `(g∘f) '' s` as `g '' (f '' s)` via `Set.image_comp`, discharging the
`MapsTo` side-conditions for the composition lemmas) is routine; the mathematical
content lives entirely in the closure properties. Nothing in the development was
disproved.

The deeper lesson is **functoriality**: the entire theory is functorial in the
set-local map. Once a class is shown closed under composition and restriction,
the dimension estimates lift automatically. This is exactly the data of a
category whose objects are subsets-with-dimension and whose morphisms are
set-local bi-Hölder maps, equipped with a multiplicative invariant (the exponent)
— a functor to `(ℝ_{>0}, ·)`.

---

## 8. Future directions

(Reproduced from the Phase A research program.)

This cycle deepened the set-local Hausdorff-dimension distortion theory by closing
the composition gap. The structural core is that the set-local classes compose and
that distortion exponents are multiplicative under composition — the dimension
shadow of the fact that snowflaking / Hölder conjugation composes.

**Direction 1: A category/groupoid of set-local bi-Hölder maps.**
Formalize the distortion data as an actual category (or groupoid, restricting to
invertible maps), with objects the subsets-with-dimension and morphisms the
set-local bi-Hölder maps; exhibit Hausdorff-dimension distortion as a functor to
the multiplicative monoid `(ℝ_{>0}, ·)`. The composition and restriction lemmas
proved here are precisely the functoriality and locality axioms.

**Further directions** suggested by the theory: (i) extend from finite to
*transfinite/iterated* composition for IFS limit objects; (ii) develop a packing-
and box-dimension analogue of the multiplicative distortion law; (iii) prove a
genuine quasi-symmetry (`η`-control) refinement in which scale-dependent
distortion replaces fixed Hölder exponents, and recover the present bounds in the
limit; (iv) formalize quasi-symmetric rigidity theorems on self-similar sets as
applications of Corollary 4.3.

---

## 9. Conclusion

We closed the central structural gap in set-local Hausdorff-dimension distortion
theory by proving that the relevant classes compose. The set-local antilipschitz
class is closed under composition (constants multiply) and restriction, and is
implied by the global condition. These closure lemmas lift single-map invariance
to composite invariance, and single-map Hölder distortion to a composite bound
with *multiplied exponents* — with the bi-Lipschitz case recovered exactly in the
degenerate limit. The theory is functorial in the set-local map, pointing toward a
category-theoretic foundation for fractal distortion calculus.
