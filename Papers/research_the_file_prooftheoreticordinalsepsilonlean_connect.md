# Composition Theory for Set-Local Distortion of Hausdorff Dimension

## Abstract

We develop the composition calculus for *set-local* distortion of Hausdorff dimension
under Lipschitz, antilipschitz, and Hölder maps between extended metric spaces. Building
on the single-map distortion theory — which records how one well-behaved map changes the
Hausdorff dimension of a fixed subset `s` — we close the gap that prevents that theory
from being applied to fractals, namely the absence of a *composition* law. We introduce a
set-local notion of antilipschitz map, `AntilipschitzOnWith K f s`, and prove that this
class is closed under composition (with multiplied constants), closed under restriction to
subsets, and contains the restrictions of globally antilipschitz maps. From these we
derive the two headline geometric results: (i) **composite bi-Lipschitz invariance** — the
composite of two set-local bi-Lipschitz maps preserves Hausdorff dimension; and (ii) the
**composite quasi-symmetric (bi-Hölder) distortion bound** — the composite of two
set-local bi-Hölder maps distorts Hausdorff dimension with the *product* of the individual
Hölder exponents, with bi-Lipschitz invariance recovered as the exponent-one corollary.
Every statement is local to a subset, so the theory applies directly to the nested pieces
out of which iterated function systems, quasi-symmetric conjugacies, and self-similar
fractals are built. All results have been formally verified.

## 1. Introduction

Hausdorff dimension is the canonical scale-invariant measurement of metric complexity. For
a subset `s` of a metric space it is the unique critical exponent `dimH s` at which the
Hausdorff measure of `s` jumps from `+∞` to `0`. Its central virtue is *invariance*: it is
unchanged by bi-Lipschitz maps, and is controlled in a quantitative, two-sided way by
Hölder maps with Hölder inverses (quasi-symmetric maps). These invariance properties are
what justify calling `dimH s` an intrinsic invariant of the *shape* of `s` rather than an
artefact of an embedding or a coordinate system.

The single-map theory answers "what does one good map do to `dimH s`?". But fractals are
not single-map objects. The middle-thirds Cantor set, self-similar attractors, Julia and
limit sets, and quasi-symmetric conjugacies are all assembled by *chaining* good maps,
often on a nested hierarchy of pieces. A distortion theory that does not compose cannot
reach these objects. This paper supplies the composition calculus.

We work throughout with **set-local** statements: every hypothesis is imposed only on a
fixed subset `s` (or on the relevant image set), and every conclusion is about the
dimension of an image of `s`. This is not a cosmetic generality. Fractal arguments live on
small pieces — a single cylinder of an iterated function system, a neighbourhood on a
boundary at infinity — where the maps in play are well-behaved only locally. The set-local
framework is exactly what lets the composition law be applied generation by generation.

### Contributions

1. A set-local antilipschitz predicate `AntilipschitzOnWith K f s` and its basic calculus:
   injectivity on `s`, a canonical Lipschitz left inverse on the image, and the local
   lower bound `dimH s ≤ dimH (f '' s)`.
2. **Composition closure** of the set-local antilipschitz class, with multiplied constants
   (Theorem 5.1), plus restriction monotonicity (Theorem 5.2) and the global-to-local
   embedding (Theorem 5.3).
3. **Composite bi-Lipschitz invariance** of Hausdorff dimension (Theorem 6.1).
4. The **composite quasi-symmetric (bi-Hölder) distortion bound** with product exponents
   (Theorem 7.1), specialising to Theorem 6.1 when all exponents equal 1.

## 2. Preliminaries and notation

Let `(X, d_X)`, `(Y, d_Y)`, `(Z, d_Z)` be extended metric spaces (`EMetricSpace`); we
write `edist` for the `[0, ∞]`-valued distance. Constants `K, C, r` are nonnegative reals
(`ℝ≥0`). For a subset `s ⊆ X` we write `f '' s` for the image `{f x : x ∈ s}`. We write
`dimH s` for the Hausdorff dimension of `s`, valued in `[0, ∞]`.

We use three regularity classes, each *relative to a set*.

**Definition 2.1 (Lipschitz on a set).** `LipschitzOnWith K f s` holds iff
`d_Y(f x, f y) ≤ K · d_X(x, y)` for all `x, y ∈ s`.

**Definition 2.2 (Hölder on a set).** `HolderOnWith C r f s` holds iff
`d_Y(f x, f y) ≤ C · d_X(x, y)^r` for all `x, y ∈ s`.

**Definition 2.3 (Antilipschitz on a set).**
```
AntilipschitzOnWith K f s  :=  ∀ x ∈ s, ∀ y ∈ s,  d_X(x, y) ≤ K · d_Y(f x, f y).
```
This is the set-local dual of Lipschitz continuity: it forbids `f` from contracting
distances on `s` by more than a factor `K`. It is the local counterpart of the global
`AntilipschitzWith K f`.

We use two classical facts about how regularity controls dimension; both are standard and
are the only external inputs.

**Fact 2.4 (Lipschitz upper bound).** If `LipschitzOnWith K f s`, then
`dimH (f '' s) ≤ dimH s`. A Lipschitz map cannot increase Hausdorff dimension.

**Fact 2.5 (Hölder upper bound).** If `HolderOnWith C r f s` with `r > 0`, then
`dimH (f '' s) ≤ dimH s / r`. A Hölder map of exponent `r` inflates dimension by at most
the factor `1/r`.

## 3. The set-local antilipschitz calculus

The antilipschitz class is engineered to deliver a *lower* bound on image dimension, dual
to Fact 2.4. We collect the structural lemmas.

**Lemma 3.1 (Injectivity).** If `AntilipschitzOnWith K f s`, then `f` is injective on `s`.

*Proof.* If `f x = f y` for `x, y ∈ s`, the defining inequality gives
`d_X(x, y) ≤ K · d_Y(f x, f y) = K · 0 = 0`, hence `x = y`. ∎

Because `f` is injective on `s`, it admits a left inverse on `s`; the canonical choice is
`invFunOn f s`, which satisfies `invFunOn f s (f x) = x` for `x ∈ s`.

**Lemma 3.2 (Lipschitz left inverse).** If `AntilipschitzOnWith K f s`, then the canonical
left inverse `g := invFunOn f s` is Lipschitz on the image: `LipschitzOnWith K g (f '' s)`.

*Proof.* For points `f x, f y ∈ f '' s` with `x, y ∈ s`, the left-inverse identity rewrites
the target `d_X(g(f x), g(f y)) = d_X(x, y)`, and the antilipschitz inequality bounds this
by `K · d_Y(f x, f y)`, which is exactly the Lipschitz estimate for `g`. ∎

**Lemma 3.3 (Inverse-Lipschitz lower bound).** Let `g` be a left inverse of `f` on `s`
that is Lipschitz on `f '' s`. Then `dimH s ≤ dimH (f '' s)`.

*Proof.* Since `g(f x) = x` on `s`, we have `g '' (f '' s) = s`. By Fact 2.4 applied to
`g` on `f '' s`, `dimH (g '' (f '' s)) ≤ dimH (f '' s)`. Rewriting the left side as
`dimH s` gives the claim. ∎

**Theorem 3.4 (Set-local antilipschitz lower bound).** If `AntilipschitzOnWith K f s`,
then `dimH s ≤ dimH (f '' s)`.

*Proof.* Combine Lemma 3.2 (the canonical inverse is Lipschitz on the image) with Lemma
3.3 (such an inverse forces the lower bound). ∎

## 4. Single-map distortion (baseline)

The composition results rest on two single-map theorems, restated here for completeness.

**Theorem 4.1 (Bi-Lipschitz invariance).** If `LipschitzOnWith Kf f s` and
`AntilipschitzOnWith Kf' f s`, then `dimH (f '' s) = dimH s`.

*Proof.* The Lipschitz hypothesis gives `dimH (f '' s) ≤ dimH s` (Fact 2.4); the
antilipschitz hypothesis gives `dimH s ≤ dimH (f '' s)` (Theorem 3.4). Antisymmetry of `≤`
yields equality. ∎

**Theorem 4.2 (Two-sided Hölder distortion).** Let `HolderOnWith Cf rf f s` with `rf > 0`,
let `g` be a left inverse of `f` on `s`, and let `HolderOnWith Cg rg g (f '' s)` with
`rg > 0`. Then
```
dimH (f '' s) ≤ dimH s / rf      and      dimH s ≤ dimH (f '' s) / rg.
```

*Proof.* The first inequality is Fact 2.5 applied to `f` on `s`. For the second, the
left-inverse identity gives `g '' (f '' s) = s`, so Fact 2.5 applied to `g` on `f '' s`
yields `dimH s = dimH (g '' (f '' s)) ≤ dimH (f '' s) / rg`. ∎

When `rf = rg = 1` (i.e. both maps Lipschitz) the two inequalities pinch to
`dimH (f '' s) = dimH s`, recovering Theorem 4.1.

## 5. Composition closure of the antilipschitz class

We now prove the new structural backbone: the set-local antilipschitz class is a
*composable* class, with the expected calculus.

**Theorem 5.1 (Composition).** If `AntilipschitzOnWith Kf f s` and
`AntilipschitzOnWith Kg g (f '' s)`, then `AntilipschitzOnWith (Kf · Kg) (g ∘ f) s`.

*Proof.* Fix `x, y ∈ s`. By the antilipschitz bound for `f`,
`d_X(x, y) ≤ Kf · d_Y(f x, f y)`. Because `f x, f y ∈ f '' s`, the antilipschitz bound for
`g` applies at these points: `d_Y(f x, f y) ≤ Kg · d_Z(g(f x), g(f y))`. Substituting and
using associativity/monotonicity of multiplication on `[0, ∞]`,
```
d_X(x, y) ≤ Kf · (Kg · d_Z(g(f x), g(f y))) = (Kf · Kg) · d_Z((g ∘ f) x, (g ∘ f) y).
```
This is exactly `AntilipschitzOnWith (Kf · Kg) (g ∘ f) s`. ∎

This is the precise dual of the classical `LipschitzOnWith.comp`, in which Lipschitz
constants likewise multiply. The crucial set-local subtlety is that `g`'s hypothesis must
be imposed on the *image* `f '' s` (not on all of `Y`), and the membership
`f x, f y ∈ f '' s` is automatic — exactly the bookkeeping that makes the local theory
chain correctly.

**Theorem 5.2 (Restriction).** If `AntilipschitzOnWith K f s` and `t ⊆ s`, then
`AntilipschitzOnWith K f t`.

*Proof.* The defining inequality is universally quantified over points of `s`; restricting
the quantifier to `t ⊆ s` preserves it. ∎

**Theorem 5.3 (Global ⇒ local).** If `f` is globally antilipschitz, `AntilipschitzWith K f`,
then `AntilipschitzOnWith K f s` for every set `s`.

*Proof.* The global pointwise inequality holds for all points of `X`, in particular for all
points of `s`. ∎

Theorems 5.1–5.3 say the antilipschitz class behaves as a regularity class should: it
composes, it localises downward, and it absorbs the global theory.

## 6. Composite bi-Lipschitz invariance

We can now upgrade single-map invariance to the iterated setting.

**Theorem 6.1 (Composite bi-Lipschitz invariance).** Suppose
- `LipschitzOnWith Kf f s` and `AntilipschitzOnWith Kf' f s` (so `f` is bi-Lipschitz on
  `s`), and
- `LipschitzOnWith Kg g (f '' s)` and `AntilipschitzOnWith Kg' g (f '' s)` (so `g` is
  bi-Lipschitz on `f '' s`).

Then `dimH ((g ∘ f) '' s) = dimH s`.

*Proof.* By Theorem 4.1 applied to the composite, it suffices to show `g ∘ f` is both
Lipschitz and antilipschitz on `s`.
- *Lipschitz part.* The classical Lipschitz composition law `LipschitzOnWith.comp` applies
  because `f` maps `s` into `f '' s` (the relevant `MapsTo` condition); it yields
  `LipschitzOnWith (Kg · Kf) (g ∘ f) s`.
- *Antilipschitz part.* Theorem 5.1 yields `AntilipschitzOnWith (Kf' · Kg') (g ∘ f) s`.

With both bounds in hand, Theorem 4.1 gives `dimH ((g ∘ f) '' s) = dimH s`. ∎

By induction this extends to any finite chain `f_n ∘ ⋯ ∘ f_1` of maps, each bi-Lipschitz
on the running image of the previous one: the composite preserves Hausdorff dimension. This
is the form in which the result is used for iterated function systems and conjugacy
pipelines.

## 7. Composite quasi-symmetric (bi-Hölder) distortion

The main theorem treats the genuinely roughening regime, where exponents differ from 1 and
the snowflake effect appears.

**Theorem 7.1 (Composite bi-Hölder distortion, product exponents).** Suppose
- `HolderOnWith Cf rf f s` with `rf > 0`, with a left inverse `f'` on `s` such that
  `HolderOnWith Cf' rf' f' (f '' s)` with `rf' > 0`;
- `HolderOnWith Cg rg g (f '' s)` with `rg > 0`, with a left inverse `g'` on `f '' s` such
  that `HolderOnWith Cg' rg' g' (g '' (f '' s))` with `rg' > 0`.

Then
```
dimH ((g ∘ f) '' s) ≤ dimH s / (rg · rf)      and
dimH s ≤ dimH ((g ∘ f) '' s) / (rf' · rg').
```

*Proof.* Form the composite forward map `g ∘ f` and the composite inverse `f' ∘ g'`.
- *Forward exponent.* The Hölder composition law multiplies exponents: composing
  `HolderOnWith Cg rg g (f '' s)` (after) with `HolderOnWith Cf rf f s` (before, using the
  `MapsTo` condition `f '' s ⊇ f(s)`) gives
  `HolderOnWith (Cg · Cf^{rg}) (rg · rf) (g ∘ f) s`.
- *Inverse exponent.* Symmetrically, composing the inverse Hölder data
  `HolderOnWith Cf' rf' f' (f '' s)` and `HolderOnWith Cg' rg' g' (g '' (f '' s))` gives a
  Hölder bound of exponent `rf' · rg'` for `f' ∘ g'` on the composite image
  `(g ∘ f) '' s = g '' (f '' s)`.
- *Left-inverse identity.* For `x ∈ s`, `(f' ∘ g')((g ∘ f) x) = f'(g'(g(f x))) = f'(f x) = x`,
  using the two left-inverse identities in turn; so `f' ∘ g'` is a left inverse of `g ∘ f`
  on `s`.
- *Conclusion.* Apply Theorem 4.2 to the composite pair `(g ∘ f, f' ∘ g')` with exponents
  `rf_total = rg · rf` and `rg_total = rf' · rg'`, giving the two displayed inequalities. ∎

**Corollary 7.2 (Exponent-one collapse).** If all four exponents equal 1, then
`rg · rf = rf' · rg' = 1` and Theorem 7.1 reads `dimH ((g ∘ f) '' s) ≤ dimH s` and
`dimH s ≤ dimH ((g ∘ f) '' s)`, i.e. `dimH ((g ∘ f) '' s) = dimH s`. This is exactly
Theorem 6.1; composite bi-Lipschitz invariance is the exponent-one shadow of the composite
bi-Hölder law.

The qualitative content is the **multiplicativity of distortion budgets**: snowflaking by
exponent `rf` and then by exponent `rg` is governed, at the level of Hausdorff dimension,
by the single exponent `rf · rg`. Roughness budgets compose by multiplication, never worse
than the worst individual link.

## 8. Algorithms and computation

Hausdorff dimension is not generally computable from finite data, but for the self-similar
sets where it is determined by a similarity equation, the composition laws above translate
into exact arithmetic that *can* be computed and checked. We highlight three algorithmic
primitives implemented in the accompanying demonstrations.

**(A) Similarity-dimension solver.** For an iterated function system of `m` contractions
with ratios `c_1, …, c_m` satisfying the open set condition, the similarity dimension `D`
is the unique root of `∑ c_i^D = 1`. A monotone bisection on `D` converges linearly; the
output is the Hausdorff dimension of the attractor. This is the ground truth against which
the invariance laws are tested.

**(B) Composition-exponent propagator.** Given a pipeline of maps tagged with their
forward and inverse Hölder exponents `(r_i, r_i')`, the propagator returns the composite
forward exponent `∏ r_i` and inverse exponent `∏ r_i'`, hence the two-sided dimension
window `[dimH s · ∏ r_i', dimH s / ∏ r_i]` predicted by Theorem 7.1. When all `r_i = 1`
the window collapses to the exact invariant of Theorem 6.1.

**(C) Box-counting dimension estimator.** For a finite high-resolution rendering of a
fractal, the box-counting estimate `log N(ε) / log(1/ε)` (slope of a log–log regression)
numerically approximates `dimH`, letting one confirm e.g. `dimH(Cantor) ≈ log 2 / log 3`
and verify invariance under a sampled bi-Lipschitz map.

## 9. Applications

- **Iterated function systems and self-similar fractals.** An IFS attractor is the fixed
  point of a chain of contractions; Theorem 6.1 guarantees its dimension is independent of
  any bi-Lipschitz change of coordinates applied at any stage, and Theorem 5.2 lets the
  argument descend to individual cylinders.
- **Dynamical systems and strange attractors.** Attractor dimension is a coordinate-free
  physical invariant precisely because the generating dynamics is an iteration; the
  composition law is the formal reason iteration cannot smuggle in spurious dimension.
- **Quasi-symmetric geometry and boundary rigidity.** Quasi-symmetric maps between fractal
  boundaries are bi-Hölder on small pieces; Theorem 7.1 is the dimensional accounting that
  underlies snowflake-type rigidity statements.
- **Robust feature extraction.** Fractal-dimension descriptors of textures, scans, and time
  series are stable under bi-Lipschitz preprocessing (rescaling, smooth warping, sensor
  calibration) by Theorem 6.1 — the guarantee that the descriptor measures the object, not
  the instrument.

## 10. Discussion

The set-local viewpoint is what makes these results deployable. By imposing every
hypothesis on a fixed subset and its forward images, the theory matches the structure of
fractal arguments, which proceed piece-by-piece and generation-by-generation. The
antilipschitz calculus of Section 5 is the linchpin: once the lower-bound class is shown to
compose, restrict, and absorb the global theory, the geometric theorems of Sections 6–7
follow by pairing it with the classical Lipschitz/Hölder upper bounds.

A conceptual highlight is the unification in Theorem 7.1: a single statement, parameterised
by Hölder exponents, contains both the rigid (`r = 1`) and the roughening (`r < 1`) regimes.
The exponent dial interpolates continuously between exact invariance and quantitatively
controlled snowflaking, and the composition law is simply that exponents multiply along the
pipeline.

## 11. Future directions

- **Iterated and infinite compositions.** Promote Theorem 6.1 from finite chains to the
  limit objects of iterated function systems and infinite conjugacy towers, controlling the
  accumulation of constants along the way.
- **Measure-level refinement.** Lift the dimension statements to comparisons of Hausdorff
  *measures* in the critical dimension, tracking how the multiplicative constants (not just
  the exponents) propagate under composition.
- **Sharpness and extremal maps.** Characterise when the product-exponent bounds of Theorem
  7.1 are attained, identifying the extremal snowflake conjugacies.
- **Beyond Hölder.** Extend the composition calculus to more general moduli of continuity
  (`ω`-regularity), replacing the product of exponents by composition of moduli, and to the
  Assouad and box dimensions, where the local theory is expected to behave differently.
- **Quasi-symmetric invariants.** Use the composite bi-Hölder bound as the base case for a
  formal theory of quasi-symmetric invariants of fractal boundaries.

## 12. Conclusion

We have closed the composition gap in the set-local theory of Hausdorff-dimension
distortion. The set-local antilipschitz class composes with multiplied constants, restricts
to subsets, and contains the global theory; consequently bi-Lipschitz invariance composes,
and — most generally — bi-Hölder distortion composes with the product of the exponents,
recovering invariance in the exponent-one case. These are exactly the laws fractal geometry
needs to turn single-map distortion facts into statements about iterated, conjugated, and
self-similar objects.
