# Quasi-Symmetric Gauges, the Bi-Lipschitz Monoid, and Hausdorff-Dimension Invariance

## Abstract

We develop a self-contained theory of *quasi-symmetric* maps between metric spaces, organized around the relative-distortion **gauge** `η`, and connect it to the measure-theoretic invariant of Hausdorff dimension. Quasi-symmetric maps generalize bi-Lipschitz maps by controlling *ratios* of distances rather than absolute distances, via a single one-variable gauge `η : [0,∞) → [0,∞)` satisfying `dist(f x, f a) ≤ η(dist(x,a)/dist(x,b)) · dist(f x, f b)`. We establish: (i) that the bi-Lipschitz class embeds in the quasi-symmetric class with the linear gauge `η(t) = L²t`; (ii) a **gauge calculus** consisting of enlargement (monotonicity in the gauge), single-scale eccentricity control (the constant `η(1)` bounds the spreading of equidistant points), and an iteration law (the `n`-fold iterate of an injective quasi-symmetric self-map has gauge `η^[n]`); (iii) that the bi-Lipschitz maps form a **monoid** under composition with multiplicative constants and a `1`-bi-Lipschitz identity; and (iv) the central **cross-domain bridge**: every bi-Lipschitz map preserves Hausdorff dimension on every set, `dimH(f(S)) = dimH(S)`. The proof of (iv) exploits the observation that the single bi-Lipschitz constant `L` serves simultaneously as a Lipschitz constant (forcing `dimH(f(S)) ≤ dimH(S)`) and an antilipschitz constant (forcing `dimH(f(S)) ≥ dimH(S)`). All results are formalized and machine-verified. We discuss applications to iterated function systems and conclude with open directions on inverse gauges and conformal dimension.

**Keywords:** quasi-symmetric maps, bi-Lipschitz maps, Hausdorff dimension, gauge calculus, conformal geometry, fractals, iterated function systems.

**MSC 2020:** 30L10 (quasiconformal mappings on metric spaces), 28A78 (Hausdorff measures and dimensions), 51F30 (Lipschitz and coarse geometry).

---

## 1. Introduction

The classification of metric spaces up to "gentle" deformation is a central program in modern analysis and geometry. Two notions of gentleness dominate.

The **bi-Lipschitz** maps control absolute distances: a map `f` is `L`-bi-Lipschitz (`L ≥ 1`) when `L⁻¹ · dist(x,y) ≤ dist(f x, f y) ≤ L · dist(x,y)` for all `x, y`. These maps preserve a large amount of metric structure but are rigid — they treat all scales identically.

The **quasi-symmetric** maps, introduced by Tukia and Väisälä and central to the analysis on metric spaces of Heinonen, Koskela, and others, relax this rigidity. Rather than controlling absolute distances, they control the *relative* distortion of triples through a one-variable gauge. This is exactly the scale-invariant weakening needed for the geometry of fractals and self-similar sets, where uniform distance control is unattainable but proportional control persists.

This paper has two goals. First, to isolate a small but complete **calculus of gauges** — the algebraic operations one can perform on the function `η` itself: enlargement, evaluation at the canonical scale `t = 1`, and iteration. Second, to build the **bridge** from the distance-based, conformal-geometric predicates to the measure-theoretic invariant `dimH`, proving that the bi-Lipschitz sub-monoid preserves Hausdorff dimension exactly.

All theorems below are formalized in the Lean 4 theorem prover atop Mathlib, with no unproved assumptions; the present paper records the mathematics and the proof strategies.

---

## 2. Definitions

Throughout, `X`, `Y`, `Z` are metric spaces with distance functions written `dist`.

**Definition 2.1 (Quasi-symmetric map).** A map `f : X → Y` is *η-quasi-symmetric*, for a gauge `η : ℝ → ℝ`, if for all `x, a, b ∈ X` with `x ≠ b`,
> `dist(f x, f a) ≤ η( dist(x,a) / dist(x,b) ) · dist(f x, f b).`

We write `IsQuasisymmetric f η`. The gauge `η` is an *upper control*: any function pointwise dominating a valid gauge is itself a valid gauge (Theorem 4.1).

**Definition 2.2 (Bi-Lipschitz map).** A map `f : X → Y` is *`L`-bi-Lipschitz*, written `IsBiLipschitzWith f L`, if `1 ≤ L` and for all `x, y ∈ X`,
> `L⁻¹ · dist(x,y) ≤ dist(f x, f y)` and `dist(f x, f y) ≤ L · dist(x,y).`

**Definition 2.3 (Set-local antilipschitz map).** For Hausdorff-dimension purposes we use the dual of the Lipschitz condition in the extended-distance (`edist`) setting. A map `f` is `K`-*antilipschitz on a set `s`*, written `AntilipschitzOnWith K f s`, if for all `x, y ∈ s`,
> `edist(x,y) ≤ K · edist(f x, f y).`

An antilipschitz map cannot contract; combined with the Lipschitz (non-expansion) bound it pins distances from both sides.

**Definition 2.4 (Hausdorff dimension).** For a set `S` in a metric space, `dimH S ∈ [0, ∞]` is the Hausdorff dimension: the critical exponent `s` at which the `s`-dimensional Hausdorff measure of `S` transitions from `∞` to `0`. We use the following two standard facts as black boxes (both available in Mathlib):
- **(Lipschitz upper bound)** If `f` is `K`-Lipschitz, then `dimH(f(S)) ≤ dimH(S)`.
- **(Antilipschitz lower bound)** If `f` is `K`-antilipschitz on `S` (and `X` is nonempty), then `dimH(S) ≤ dimH(f(S))`.

---

## 3. The embedding of bi-Lipschitz into quasi-symmetric

**Theorem 3.1 (Bi-Lipschitz maps are quasi-symmetric, with a linear gauge).**
If `f` is `L`-bi-Lipschitz, then `f` is `η`-quasi-symmetric for the linear gauge `η(t) = L² · t`.

*Proof sketch.* Fix `x, a, b` with `x ≠ b`, so `dist(x,b) > 0`. From the bi-Lipschitz bounds,
`dist(f x, f a) ≤ L · dist(x,a)` and `dist(f x, f b) ≥ L⁻¹ · dist(x,b)`. Hence
```
dist(f x, f a)                  L · dist(x,a)        dist(x,a)
──────────────   ≤   ──────────────────────  =  L² · ────────.
dist(f x, f b)            L⁻¹ · dist(x,b)              dist(x,b)
```
Multiplying through by `dist(f x, f b) ≥ 0` gives `dist(f x, f a) ≤ L² · (dist(x,a)/dist(x,b)) · dist(f x, f b)`, which is the claim. The two factors of `L` from the upper and lower bounds multiply to `L²`. ∎

This exhibits the bi-Lipschitz class as exactly the corner of the quasi-symmetric world where the gauge is a straight line through the origin. Quasi-symmetry is the result of permitting the gauge to be nonlinear.

---

## 4. A calculus of gauges

The gauge is not rigid data attached to a map; it supports a small algebra. We record three operations.

**Theorem 4.1 (Gauge enlargement / monotonicity).**
If `f` is `η`-quasi-symmetric and `η(t) ≤ η'(t)` for all `t`, then `f` is `η'`-quasi-symmetric.

*Proof sketch.* For any triple, `dist(f x, f a) ≤ η(r)·dist(f x, f b) ≤ η'(r)·dist(f x, f b)`, the second inequality being `mul_le_mul_of_nonneg_right` applied to `η(r) ≤ η'(r)` and `dist(f x, f b) ≥ 0`. ∎

Conceptually: quasi-symmetry is the property of *possessing some* controlling gauge. The gauge is an upper bound, and upper bounds may always be relaxed.

**Theorem 4.2 (Single-scale eccentricity).**
If `f` is `η`-quasi-symmetric, `x ≠ b`, and `dist(x,a) = dist(x,b)` (so `a` and `b` are equidistant from `x`), then
> `dist(f x, f a) ≤ η(1) · dist(f x, f b).`

*Proof sketch.* When `dist(x,a) = dist(x,b)` and `dist(x,b) ≠ 0`, the ratio `dist(x,a)/dist(x,b) = 1`, so the defining inequality evaluated at this triple reads `dist(f x, f a) ≤ η(1)·dist(f x, f b)`. ∎

The single number `η(1)` bounds the eccentricity that a quasi-symmetric map can impose on a "round" (equidistant) configuration. This is the quantitative form of the statement that quasi-symmetric maps are conformal-flavored: spheres map to sets of bounded eccentricity, never to degenerate slivers.

**Theorem 4.3 (Composition law).**
If `f` is `η_f`-quasi-symmetric and injective, and `g` is `η_g`-quasi-symmetric with `η_g` monotone, then `g ∘ f` is `(η_g ∘ η_f)`-quasi-symmetric.

*Proof sketch.* Apply `g`'s inequality to the image triple `(f x, f a, f b)`, valid because injectivity of `f` keeps `f x ≠ f b`:
`dist(g(f x), g(f a)) ≤ η_g( dist(f x, f a)/dist(f x, f b) ) · dist(g(f x), g(f b))`.
The inner ratio is bounded by `η_f(dist(x,a)/dist(x,b))` using `f`'s inequality together with positivity of `dist(f x, f b)` (so that the division inequality `div_le_iff₀` applies). Monotonicity of `η_g` then pushes this bound through, yielding the composed gauge `η_g ∘ η_f`. ∎

**Theorem 4.4 (Iteration of the gauge).**
If `f : X → X` is `η`-quasi-symmetric, injective, with `η` monotone, then for every `n ∈ ℕ` the iterate `f^[n]` is `η^[n]`-quasi-symmetric (where `f^[n]` and `η^[n]` denote the `n`-fold compositions).

*Proof sketch.* Induct on `n`. The base case `n = 0` is the identity map with the identity "gauge," verified directly (the inequality is an equality where `dist(x,b) ≠ 0`, and trivial otherwise). For the step, write `f^[n+1] = f^[n] ∘ f` and `η^[n+1] = η^[n] ∘ η` (the `iterate_succ'` form), then apply Theorem 4.3 with inner map `f^[n]`, outer map `f`... more precisely with the composition oriented so the outer gauge `η^[n]` is monotone (it is, as an iterate of the monotone `η`, via `Monotone.iterate`) and the inner map injective (`f^[n]` is injective as an iterate of an injection, via `Function.Injective.iterate`). ∎

Theorem 4.4 is the algebraic skeleton of the Hölder exponents that appear in the coding maps of iterated function systems: iterating the *map* iterates the *gauge* in lockstep.

---

## 5. The bi-Lipschitz monoid

**Theorem 5.1 (Composition multiplies constants).**
If `f` is `L`-bi-Lipschitz and `g` is `M`-bi-Lipschitz, then `g ∘ f` is `(L·M)`-bi-Lipschitz.

*Proof sketch.* First, `1 ≤ L·M` since `1 ≤ L` and `1 ≤ M` (`one_le_mul_of_one_le_of_one_le`). For the two-sided distance bound, chain the inequalities through `f x, f y`:
- Upper: `dist(g(f x), g(f y)) ≤ M · dist(f x, f y) ≤ M · (L · dist(x,y)) = (L·M)·dist(x,y)`.
- Lower: `dist(g(f x), g(f y)) ≥ M⁻¹ · dist(f x, f y) ≥ M⁻¹ · (L⁻¹ · dist(x,y)) = (L·M)⁻¹·dist(x,y)`.
∎

**Theorem 5.2 (Identity is `1`-bi-Lipschitz).**
The identity map `id : X → X` is `1`-bi-Lipschitz.

*Proof sketch.* `1 ≤ 1`, and `1⁻¹ · dist(x,y) = dist(x,y) = 1 · dist(x,y)`, so both bounds hold with equality. ∎

**Corollary 5.3 (The bi-Lipschitz monoid inside the quasi-symmetric maps).**
The bi-Lipschitz self-maps of `X` form a monoid under composition: the operation is associative (composition of functions), the unit is `id` with constant `1` (Theorem 5.2), and the class is closed with constants multiplying (Theorem 5.1). Via Theorem 3.1, this monoid embeds into the quasi-symmetric maps, each `L`-bi-Lipschitz map carrying the linear gauge `η(t) = L²t`. Under this embedding, composition of bi-Lipschitz maps (constants `L`, `M ↦ LM`) is compatible with composition of gauges (linear gauges compose to a linear gauge `(LM)²t`), consistent with Theorem 4.3.

---

## 6. The cross-domain bridge: dimension invariance

The main theorem connects the distance-based predicate `IsBiLipschitzWith` to the measure-theoretic invariant `dimH`.

**Theorem 6.1 (Bi-Lipschitz maps preserve Hausdorff dimension).**
Let `f : X → Y` be `L`-bi-Lipschitz. Then for every set `S ⊆ X`,
> `dimH(f(S)) = dimH(S).`

*Proof sketch.* The single constant `L` does double duty.

*Upper bound `dimH(f(S)) ≤ dimH(S)`.* The bound `dist(f x, f y) ≤ L · dist(x,y)` says `f` is `L`-Lipschitz. Converting `L : ℝ` with `1 ≤ L` to a nonnegative real `⟨L, _⟩ : ℝ≥0` and translating `dist` to `edist`, the Lipschitz upper bound for Hausdorff dimension gives `dimH(f(S)) ≤ dimH(S)`. Lipschitz maps cannot manufacture detail, so they cannot increase dimension.

*Lower bound `dimH(S) ≤ dimH(f(S))`.* The bound `L⁻¹ · dist(x,y) ≤ dist(f x, f y)` rearranges to `dist(x,y) ≤ L · dist(f x, f y)`, i.e. `edist(x,y) ≤ L · edist(f x, f y)` — exactly the antilipschitz condition `AntilipschitzOnWith ⟨L,_⟩ f S` (here even globally, hence on `S`). The antilipschitz lower bound for Hausdorff dimension gives `dimH(S) ≤ dimH(f(S))`. Antilipschitz maps cannot crush detail out of existence, so they cannot decrease dimension.

Combining the two inequalities by antisymmetry of `≤` yields equality. ∎

**Remark 6.2 (Why one constant suffices).** The key observation, recorded in the formalization's lab notebook, is that `L⁻¹ ≤ ·` and `· ≤ L` are two readings of the same scalar bound. The same `L` is simultaneously the Lipschitz constant (top half) and the antilipschitz constant (bottom half). A single hypothesis `1 ≤ L` therefore packages both halves of dimension invariance — a structural economy that is invisible until one separates the two directions.

**Remark 6.3 (Relation to the set-local theory).** Theorem 6.1 is the global, `dist`-predicate packaging of a set-local result: a map that is simultaneously Lipschitz and antilipschitz *on a fixed set `s`* preserves the dimension of `s` (`dimH_image_eq_of_lipschitzOn_antilipschitzOn`). The set-local theory further yields a two-sided **Hölder distortion** estimate: if `f` is `(C_f, r_f)`-Hölder on `s` and its inverse is `(C_g, r_g)`-Hölder on `f(s)`, then
> `dimH(f(s)) ≤ dimH(s)/r_f` and `dimH(s) ≤ dimH(f(s))/r_g`,
recovering Theorem 6.1 in the exponent-one case `r_f = r_g = 1`. This is the quantitative form of how genuinely nonlinear (quasi-symmetric-flavored) maps distort dimension.

---

## 7. Algorithms

The theory is constructive enough to support direct numerical experimentation. We describe the principal algorithms (full code accompanies the package).

**Algorithm 7.1 (Linear gauge from a bi-Lipschitz constant).** Given `L ≥ 1`, return the gauge `η(t) = L²t` certified by Theorem 3.1. Complexity `O(1)` per evaluation. This is the witness that places a bi-Lipschitz map inside the quasi-symmetric class.

**Algorithm 7.2 (Gauge composition and iteration).** Given gauges `η_f, η_g` as callables, return `η_g ∘ η_f`; iterate `n` times to obtain `η^[n]`. Complexity `O(n)` evaluations for the `n`-fold iterate. This realizes Theorems 4.3–4.4 numerically: one can watch a gauge's fixed-point and growth behavior under iteration, which forecasts the Hölder regularity of the associated dynamics.

**Algorithm 7.3 (Box-counting Hausdorff-dimension estimator).** Given a finite point sample of a set `S` (or a deterministic generator for a self-similar set), estimate `dimH(S)` by counting the number `N(ε)` of grid boxes of side `ε` that meet `S` across a geometric sequence of scales, and fitting `log N(ε)` against `log(1/ε)`; the slope estimates the (box-counting upper bound on) dimension. Complexity `O(P · K)` for `P` points across `K` scales. Applied before and after a bi-Lipschitz image, this gives an empirical check of Theorem 6.1.

---

## 8. Applications

**8.1 Iterated function systems (IFS).** A self-similar fractal — the Cantor set, the Sierpiński gasket — is the attractor `K` of a finite family of contractions `{f_1, …, f_m}`. Its dimension is governed by a *coding map* `π : {1,…,m}^ℕ → K`. The gauge-iteration law (Theorem 4.4) is precisely the algebraic input needed to track how the regularity of `π` compounds under the symbolic dynamics: iterating the contraction iterates the gauge, and the resulting Hölder exponent feeds the dimension formula `Σ rᵢˢ = 1` for the similarity dimension `s`.

**8.2 Dimension-faithful normalization.** In data analysis on geometric data (point clouds, shape spaces), one frequently re-coordinates a dataset before measuring its fractal dimension. Theorem 6.1 certifies that any bi-Lipschitz re-coordinatization — rotation, anisotropic-but-bounded scaling, smooth bounded-Jacobian warping — leaves the estimated Hausdorff dimension invariant. The eccentricity bound `η(1)` (Theorem 4.2) further quantifies how much a quasi-symmetric (not merely bi-Lipschitz) normalization may distort local shape.

**8.3 Conformal classification.** The eccentricity constant `η(1)` and the gauge calculus are the first tools toward computing the *conformal dimension* of a space — the infimum of Hausdorff dimension over all quasi-symmetric redrawings — a genuine quasi-symmetry invariant that strips away accidental metric features.

---

## 9. Discussion

The results assemble into a coherent picture: a layered hierarchy of distortion classes, each preserving a graded amount of structure.

1. **Isometries** preserve distances exactly.
2. **Bi-Lipschitz maps** preserve distances up to a bounded factor and — the content of Theorem 6.1 — preserve Hausdorff dimension *exactly*. They form a monoid (Corollary 5.3).
3. **Quasi-symmetric maps** preserve only ratios of distances, controlled by a gauge `η`; they distort dimension only in a bounded, gauge-dependent fashion (the Hölder estimate of Remark 6.3 is the quantitative shadow). They form a category under composition (Theorem 4.3) with the bi-Lipschitz monoid embedded inside (Theorem 3.1).

The conceptual surprise is how much geometry a single one-variable function `η` encodes. The gauge can be enlarged (Theorem 4.1), it reports eccentricity at the canonical scale through `η(1)` (Theorem 4.2), and it iterates in perfect synchrony with the map (Theorem 4.4). These are not separate facts but facets of treating `η` as an algebraic object — a *calculus* — rather than as inert data.

The proof economy of Theorem 6.1 deserves emphasis. The two directions of dimension invariance look like they require two independent hypotheses (a Lipschitz bound and an antilipschitz bound). The bi-Lipschitz definition reveals they are one: the same `L` serves both roles. This is the kind of structural compression that good definitions provide for free.

A methodological note: the entire development is formally verified, which matters here because the arguments mix three notational regimes — `dist`-based real inequalities, `edist`-based extended-real bounds, and the `ℝ≥0`-indexed Lipschitz/antilipschitz API of the underlying measure theory. The one genuine friction in the formalization was the coercion `ℝ → ℝ≥0` needed to feed `dist`-based bounds into the `ℝ≥0`-indexed dimension API; it is resolved by packaging the constant as `⟨L, _⟩`. Machine verification guarantees that no coercion mismatch silently invalidates a step.

---

## 10. Future work

The following directions are open and, we believe, within reach of the methods established here.

**10.1 The quasi-symmetric inverse gauge.** *Conjecture.* If `f` is an `η`-quasi-symmetric bijection with `η` strictly increasing and surjective on `[0,∞)`, then `f⁻¹` is `η'`-quasi-symmetric for the explicit gauge `η'(t) = 1 / η⁻¹(1/t)`. The key idea is that the defining inequality `dist(f x, f a) ≤ η(r)·dist(f x, f b)` can be inverted by reading it as a lower bound on the inverse ratio, so the inverse map's gauge is the reflection of `η` through the involution `t ↦ 1/t`. The composition law (Theorem 4.3) and the rigidity dichotomy are already in hand; what remains is order-theoretic manipulation of a single gauge.

**10.2 Contraction/expansion dichotomy from the iterated gauge.** For an injective quasi-symmetric self-map whose gauge satisfies `η(1) < 1`, the iterates `f^[n]` should exhibit uniform contraction of eccentricity, opening a route to fixed-point and attractor theory directly from the gauge.

**10.3 IFS attractor dimension via Lipschitz sections.** Define the coding map `π` of an IFS, prove it Hölder using contractivity, and exhibit a Lipschitz section on a dense subset via the open set condition; then the two-sided Hölder distortion estimate (Remark 6.3) yields both directions of the dimension bound `dimH(K) = s`, the similarity dimension.

**10.4 Hausdorff dimension of product sets.** Establish `dimH(A × B) ≥ dimH(A) + dimH(B)` via product Hausdorff measure and covering arguments, with the Lipschitz projection maps supplying the needed inequalities.

**10.5 Conformal dimension as a topological invariant.** Define `cdim(X) = inf{ dimH(Y) : Y quasi-symmetrically equivalent to X }` and develop it as an invariant; Theorem 6.1 is the bi-Lipschitz special case of the requisite invariance, and the gauge calculus is the entry point to the full quasi-symmetric statement.

**10.6 Bi-Lipschitz embedding dimension.** Define `bldim(X) = inf{ n : X bi-Lipschitz embeds into ℝⁿ }`. Theorem 6.1 (in the form: bi-Lipschitz embeddings preserve `dimH`) gives the lower bound `bldim(X) ≥ ⌈dimH(X)⌉` for free, since `dimH(ℝⁿ) = n`; the upper bound awaits a formal Assouad embedding theorem.

---

## 11. Conclusion

We have isolated a compact calculus of quasi-symmetric gauges — enlargement, single-scale eccentricity, and iteration — and shown that the bi-Lipschitz maps form a monoid embedded inside the quasi-symmetric category. The central bridge theorem establishes that bi-Lipschitz maps preserve Hausdorff dimension exactly, translating faithfully between the distance-based language of conformal geometry and the measure-theoretic language of dimension. The single bi-Lipschitz constant, doing the work of both a Lipschitz and an antilipschitz bound, is the lever that makes the bridge possible. These results provide a verified foundation for the harder quasi-symmetric dimension theory and for the fractal-topological program sketched in the future directions.
