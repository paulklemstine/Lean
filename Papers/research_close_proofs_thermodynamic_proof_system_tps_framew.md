# Composition Theory for Set-Local Distortion of Hausdorff Dimension

## Abstract

The Hausdorff dimension is the canonical scale-invariant measure of the metric complexity of
a set, and its behaviour under maps is the backbone of fractal geometry, geometric measure
theory, and the metric theory of dynamical systems. Classical "single-map" results describe
how one Lipschitz, antilipschitz, or Hölder map distorts the Hausdorff dimension of a fixed
subset *s* of a metric space. However, the objects of genuine interest — iterated function
systems, dynamical conjugacies, quasi-symmetric homeomorphisms — are constructed by *chaining*
such maps on nested pieces. A distortion theory that does not compose cannot reach them.

This paper develops the **composition calculus** for the set-local distortion theory. We
introduce a set-local antilipschitz class, prove it is closed under composition (with
multiplied constants), under restriction to subsets, and that globally antilipschitz maps
restrict into it. We then establish two composite distortion theorems: (i) the composite of
two set-local bi-Lipschitz maps preserves Hausdorff dimension exactly, and (ii) — the main
result — the composite of two set-local bi-Hölder maps distorts Hausdorff dimension with the
*product* of the Hölder exponents, sharpening the dimension corridor multiplicatively. The
bi-Lipschitz invariance emerges as the exponent-one specialization of the bi-Hölder bound.
Every result is formalized and machine-checked in a proof assistant over a general
`EMetricSpace`, using only standard foundational axioms.

**Keywords:** Hausdorff dimension, fractal geometry, Lipschitz maps, antilipschitz maps,
Hölder continuity, quasi-symmetric maps, composition, bi-Lipschitz invariance, iterated
function systems.

---

## 1. Introduction

### 1.1 Background and motivation

Let (*X*, *d*) be a metric space. The *Hausdorff dimension* dimH(*A*) of a subset *A* ⊆ *X* is
defined, via the family of Hausdorff outer measures, as the unique critical exponent at which
the *t*-dimensional Hausdorff measure of *A* jumps from +∞ to 0. It refines the topological
dimension, takes non-integer values on fractals (e.g. log 2 / log 3 for the middle-thirds
Cantor set, log 4 / log 3 for the Koch curve), and is the standard invariant by which the
"roughness across scales" of a set is quantified.

The interaction between Hausdorff dimension and maps is governed by three regularity classes:

- **Lipschitz** maps, which cannot increase dimension;
- **antilipschitz** maps (non-collapsing), which cannot decrease dimension;
- **Hölder** maps of exponent *r* ∈ (0, 1], which can inflate dimension by up to a factor 1/*r*.

The combination of the first two yields the celebrated bi-Lipschitz invariance of Hausdorff
dimension, and the two-sided Hölder estimate yields the quasi-symmetric distortion corridor.
These constitute the **single-map theory**.

### 1.2 The gap: composition

Single-map theory is insufficient for the structures it is meant to serve. The defining
examples of fractal geometry are intrinsically compositional:

- **Iterated function systems (IFS).** The attractor of an IFS {*w_1*, …, *w_m*} is the fixed
  point of the Hutchinson operator, obtained by indefinitely composing contractions on nested
  cylinder sets. Dimension estimates on the attractor are assembled from estimates on the
  individual *w_i* applied stage after stage.
- **Conjugacies in dynamics.** Two systems are metrically equivalent when related by *g* ∘ *T*
  ∘ *g*⁻¹; controlling dimension through a conjugacy is a composition problem.
- **Quasi-symmetric homeomorphisms.** A quasi-symmetric map between fractals — central in
  analysis on metric spaces and the boundary theory of hyperbolic groups — is analysed by
  decomposing it into Hölder pieces on scales and composing the local estimates.

For any of these, one needs the regularity classes to be **closed under composition**, with an
explicit law for how the controlling constants and exponents combine. This paper supplies that
calculus and its dimension-theoretic consequences.

### 1.3 The set-local viewpoint

A guiding principle throughout is that all hypotheses are *set-local*. We never demand global
regularity on the ambient space; each map is assumed regular only on the relevant set, and the
next map only on the image of that set. This matches reality: the contractions of an IFS are
bi-Lipschitz on the attractor and arbitrary off it; conjugacies are controlled on invariant
sets only. The set-local formulation is precisely what permits the composition hypotheses to
chain — *g*'s hypothesis lives on *f*(*s*), exactly where *f* deposits *s*.

### 1.4 Contributions

1. A self-contained definition of the **set-local antilipschitz class** `AntilipschitzOnWith`
   and its basic structure (injectivity, canonical Lipschitz inverse on the image, the
   dimension lower bound).
2. **Closure laws**: composition with multiplied constants (`AntilipschitzOnWith.comp`),
   monotonicity under restriction (`AntilipschitzOnWith.mono`), and the global-to-local bridge
   (`antilipschitzOnWith_of_antilipschitzWith`).
3. **Composite bi-Lipschitz invariance** of Hausdorff dimension
   (`dimH_image_comp_eq_of_lipschitzOn_antilipschitzOn`).
4. The **main theorem**: composite bi-Hölder distortion with product exponents
   (`dimH_image_comp_bounds_of_biholderOn`), with bi-Lipschitz invariance as its exponent-one
   corollary.

All results are proved over a general extended-metric space (`EMetricSpace`), so they apply
uniformly to Euclidean space, fractal attractors, and abstract metric measure spaces alike.

---

## 2. Definitions and conventions

Throughout, *X*, *Y*, *Z* are extended metric spaces, *s* ⊆ *X* is a fixed subset, and `edist`
denotes the extended distance valued in [0, ∞]. We write *f*(*s*) for the image of *s* under
*f*. Constants *K*, *C* range over the nonnegative reals ℝ≥0, and Hölder exponents over ℝ≥0.

**Definition 2.1 (Lipschitz on a set).** A map *f* : *X* → *Y* is *Lipschitz with constant K
on s*, written `LipschitzOnWith K f s`, if for all *x*, *y* ∈ *s*,
edist(*f(x)*, *f(y)*) ≤ *K* · edist(*x*, *y*).

**Definition 2.2 (Hölder on a set).** A map *f* is *Hölder with constant C and exponent r on
s*, written `HolderOnWith C r f s`, if for all *x*, *y* ∈ *s*,
edist(*f(x)*, *f(y)*) ≤ *C* · edist(*x*, *y*)^*r*. (Exponent *r* = 1 recovers Lipschitz.)

**Definition 2.3 (Antilipschitz on a set).** A map *f* is *antilipschitz with constant K on s*,
written `AntilipschitzOnWith K f s`, if for all *x*, *y* ∈ *s*,

> edist(*x*, *y*) ≤ *K* · edist(*f(x)*, *f(y)*).

Equivalently, *f* does not contract distances on *s* by more than the factor *K*. This is the
set-local dual of the global `AntilipschitzWith` and the central new object of the theory.

**Definition 2.4 (Bi-Lipschitz on a set).** *f* is *bi-Lipschitz on s* if it is simultaneously
`LipschitzOnWith Kf f s` and `AntilipschitzOnWith Kf' f s` for some constants.

**Definition 2.5 (Bi-Hölder on a set).** *f* is *bi-Hölder on s* if *f* is Hölder on *s* with
some exponent and there is a left inverse *f′* on *f*(*s*) that is Hölder there; the pair of
exponents (*r_f*, *r_f′*) is the bi-Hölder data.

---

## 3. Single-map theory (prerequisites)

We record the single-map results that the composition theory builds on. These are reproduced
self-containedly so the development verifies standalone.

**Lemma 3.1 (Lipschitz inverse forces a dimension lower bound).**
*If g* : *Y* → *X is Lipschitz on the image f*(*s*) *and is a left inverse of f on s (that is,
g(f(x)) = x for all x ∈ s), then* dimH(*s*) ≤ dimH(*f*(*s*)).

*Proof sketch.* The left-inverse identity gives *g*(*f*(*s*)) = *s* as sets. Since *g* is
Lipschitz on *f*(*s*), it cannot increase dimension, so
dimH(*s*) = dimH(*g*(*f*(*s*))) ≤ dimH(*f*(*s*)). ∎

**Lemma 3.2 (Antilipschitz ⇒ injective).** *If f is antilipschitz on s, then f is injective on
s.*

*Proof sketch.* If *f(x)* = *f(y)* with *x*, *y* ∈ *s*, the defining inequality gives
edist(*x*, *y*) ≤ *K* · edist(*f(x)*, *f(y)*) = *K* · 0 = 0, hence *x* = *y*. ∎

**Lemma 3.3 (Canonical inverse is Lipschitz on the image).** *If f is antilipschitz with
constant K on s, then the canonical partial inverse* `invFunOn f s` *is Lipschitz with the same
constant K on f*(*s*).

*Proof sketch.* On the image, the canonical inverse undoes *f* (Lemma 3.2 makes it
well-defined). Rewriting both arguments through this identity turns the desired Lipschitz
inequality into the antilipschitz hypothesis of *f*. ∎

**Theorem 3.4 (Antilipschitz dimension lower bound).** *If f is antilipschitz on s, then*
dimH(*s*) ≤ dimH(*f*(*s*)).

*Proof sketch.* Combine Lemma 3.3 (the canonical inverse is Lipschitz on *f*(*s*)) with
Lemma 3.1. ∎

**Theorem 3.5 (Set-local bi-Lipschitz invariance).** *If f is bi-Lipschitz on s
(`LipschitzOnWith Kf f s` and `AntilipschitzOnWith Kf' f s`), then* dimH(*f*(*s*)) = dimH(*s*).

*Proof sketch.* The Lipschitz half gives dimH(*f*(*s*)) ≤ dimH(*s*) (Lipschitz maps do not
increase dimension); the antilipschitz half gives the reverse inequality by Theorem 3.4.
Antisymmetry of ≤ closes it. ∎

**Theorem 3.6 (Two-sided Hölder distortion).** *Let f be Hölder on s with exponent r_f > 0,
and let g be a left inverse of f that is Hölder on f*(*s*) *with exponent r_g > 0. Then*

> dimH(*f*(*s*)) ≤ dimH(*s*) / *r_f*   and   dimH(*s*) ≤ dimH(*f*(*s*)) / *r_g*.

*Proof sketch.* A Hölder map of exponent *r* multiplies Hausdorff dimension by at most 1/*r*
(`HolderOnWith.dimH_image_le`). Apply this to *f* for the first inequality. For the second, use
the left-inverse identity *g*(*f*(*s*)) = *s* and apply the same Hölder dimension bound to *g*
on *f*(*s*). ∎

---

## 4. Composition closure of the antilipschitz class

We now establish that the set-local antilipschitz class is a robust, composable category. These
three lemmas are the new structural backbone.

**Theorem 4.1 (Composition multiplies constants — `AntilipschitzOnWith.comp`).**
*If f is antilipschitz with constant K_f on s, and g is antilipschitz with constant K_g on
f*(*s*), *then g* ∘ *f is antilipschitz with constant K_f · K_g on s.*

*Proof.* Fix *x*, *y* ∈ *s*. Then *f(x)*, *f(y)* ∈ *f*(*s*), so the two hypotheses chain:

> edist(*x*, *y*) ≤ *K_f* · edist(*f(x)*, *f(y)*)
> ≤ *K_f* · (*K_g* · edist(*g(f(x))*, *g(f(y))*))
> = (*K_f* · *K_g*) · edist((*g* ∘ *f*)(*x*), (*g* ∘ *f*)(*y*)).

The first step is the antilipschitz bound for *f*; the second applies the antilipschitz bound
for *g* at the image points *f(x)*, *f(y)* ∈ *f*(*s*) and uses monotonicity of multiplication on
[0, ∞]; the final equality is associativity. ∎

This is the exact set-local dual of `LipschitzOnWith.comp`: where Lipschitz constants multiply
on the upper bound, antilipschitz constants multiply on the lower bound.

**Theorem 4.2 (Restriction — `AntilipschitzOnWith.mono`).** *If f is antilipschitz with
constant K on s and t ⊆ s, then f is antilipschitz with constant K on t.*

*Proof.* The defining inequality is universally quantified over points of the set; membership
*t* ⊆ *s* supplies the required hypotheses for any *x*, *y* ∈ *t*. ∎

**Theorem 4.3 (Global ⇒ local — `antilipschitzOnWith_of_antilipschitzWith`).** *If f is
antilipschitz on all of X (in the global sense `AntilipschitzWith K f`), then f is antilipschitz
with the same constant K on every subset s.*

*Proof.* The global hypothesis is a pointwise bound for all pairs; specialize it to *x*, *y* ∈
*s*. ∎

Together, Theorems 4.1–4.3 say the antilipschitz class behaves like a category of "good maps":
it is closed under chaining, passes to subobjects, and receives globally good maps. The same
three properties already hold for the Lipschitz class in the library, so both sides of the
bi-Lipschitz notion now compose.

---

## 5. Composite bi-Lipschitz invariance

**Theorem 5.1 (Composite bi-Lipschitz invariance —
`dimH_image_comp_eq_of_lipschitzOn_antilipschitzOn`).** *Suppose f is bi-Lipschitz on s
(`LipschitzOnWith Kf f s`, `AntilipschitzOnWith Kf' f s`) and g is bi-Lipschitz on f*(*s*)
(`LipschitzOnWith Kg g (f''s)`, `AntilipschitzOnWith Kg' g (f''s)`). Then*

> dimH((*g* ∘ *f*)(*s*)) = dimH(*s*).

*Proof.* By `LipschitzOnWith.comp`, the composite *g* ∘ *f* is Lipschitz on *s* (constant
*K_g* · *K_f*), using that *f* maps *s* into *f*(*s*) so *g*'s domain hypothesis applies. By
Theorem 4.1, *g* ∘ *f* is antilipschitz on *s* (constant *K_f′* · *K_g′*). Thus *g* ∘ *f* is
bi-Lipschitz on *s*, and Theorem 3.5 gives dimH((*g* ∘ *f*)(*s*)) = dimH(*s*). ∎

Iterating Theorem 5.1 (an immediate induction) shows any finite chain of set-local bi-Lipschitz
maps preserves Hausdorff dimension — the exact licence needed to analyse iterated function
systems stagewise.

---

## 6. Main theorem: composite quasi-symmetric distortion

The central result chains the dimension-altering Hölder maps and shows the exponents multiply.

**Theorem 6.1 (Composite bi-Hölder distortion — `dimH_image_comp_bounds_of_biholderOn`).**
*Suppose*

- *f is Hölder on s with exponent r_f > 0, with a left inverse f′ that is Hölder on f*(*s*)
  *with exponent r_f′ > 0 (so f′(f(x)) = x for x ∈ s);*
- *g is Hölder on f*(*s*) *with exponent r_g > 0, with a left inverse g′ that is Hölder on
  g*(*f*(*s*)) *with exponent r_g′ > 0 (so g′(g(y)) = y for y ∈ f*(*s*)).

*Then the composite g* ∘ *f distorts Hausdorff dimension with product exponents:*

> dimH((*g* ∘ *f*)(*s*)) ≤ dimH(*s*) / (*r_g* · *r_f*)   and
> dimH(*s*) ≤ dimH((*g* ∘ *f*)(*s*)) / (*r_f′* · *r_g′*).

*Proof.* The argument forms the composite forward and inverse maps and feeds them to the
single-map two-sided estimate (Theorem 3.6).

*Forward map.* By `HolderOnWith.comp`, *g* ∘ *f* is Hölder on *s* with exponent *r_g* · *r_f*
and constant *C_g* · *C_f*^(*r_g*): substituting the bound for *f* into the bound for *g* raises
an *r_f*-power to the *r_g* power, and (*d*^*r_f*)^*r_g* = *d*^(*r_g*·*r_f*). The domain
condition holds because *f* maps *s* into *f*(*s*), where *g*'s hypothesis lives.

*Inverse map.* The composite *f′* ∘ *g′* is a left inverse of *g* ∘ *f* on *s*: for *x* ∈ *s*,
(*f′* ∘ *g′*)((*g* ∘ *f*)(*x*)) = *f′*(*g′*(*g*(*f*(*x*)))) = *f′*(*f*(*x*)) = *x*, using
*g′*(*g*(*y*)) = *y* at *y* = *f*(*x*) ∈ *f*(*s*) and then *f′*(*f*(*x*)) = *x*. By
`HolderOnWith.comp`, *f′* ∘ *g′* is Hölder on the image (*g* ∘ *f*)(*s*) = *g*(*f*(*s*)) with
exponent *r_f′* · *r_g′* (matching arguments after rewriting via `image_comp`).

*Conclusion.* Apply Theorem 3.6 to the composite pair (*g* ∘ *f*, *f′* ∘ *g′*) with forward
exponent *r_g* · *r_f* and inverse exponent *r_f′* · *r_g′* (both positive, being products of
positives). This yields exactly the stated two inequalities. ∎

**Corollary 6.2 (Exponent-one collapse).** *If all four Hölder exponents equal 1, then
r_g · r_f = 1 and r_f′ · r_g′ = 1, and the corridor of Theorem 6.1 collapses to the equality*
dimH((*g* ∘ *f*)(*s*)) = dimH(*s*). *Thus the composite bi-Lipschitz invariance (Theorem 5.1)
is the exponent-one specialization of the main theorem.*

The conceptual content of Theorem 6.1 is the **multiplicativity of dimension distortion under
composition**. The distortion factor of a chain of bi-Hölder maps is the product of the
distortion factors of the links. This is the dimension shadow of the fact that snowflaking and
Hölder conjugation compose multiplicatively in their exponents — the precise quantitative
principle underlying the stability of quasi-symmetric equivalence classes.

---

## 7. Algorithms and computational content

While the theorems are statements about (possibly fractal) sets, their *bookkeeping* — how
constants and exponents propagate through a chain — is fully algorithmic. We make this explicit.

**Algorithm 7.1 (Chain-distortion accumulation).** Given a finite chain of bi-Hölder links,
each link contributing a forward exponent *r_i* and an inverse exponent *r_i′*, the composite
distortion corridor is determined by the products Π *r_i* (forward) and Π *r_i′* (inverse). The
algorithm folds the chain, multiplying exponents (and, if tracked, constants via the
*C_g* · *C_f*^(*r_g*) rule), in linear time in the number of links. The output is the pair of
dimension multipliers (1 / Π *r_i*, 1 / Π *r_i′*) that bound dimH of the image in terms of
dimH of the source.

**Algorithm 7.2 (Similarity-dimension estimation for IFS attractors).** For a self-similar set
generated by *m* contractions with ratios *c_1*, …, *c_m* satisfying the open set condition, the
Hausdorff dimension is the unique *D* solving Σ *c_i*^*D* = 1, computable by bisection on the
strictly decreasing function *D* ↦ Σ *c_i*^*D*. This supplies the concrete dimensions on which
the distortion theorems act in the demonstrations.

---

## 8. Applications

- **Iterated function systems.** Theorem 5.1 (and its iteration) guarantees that any
  bi-Lipschitz recoding of an IFS attractor — change of contraction coordinates, conjugation by
  a bi-Lipschitz homeomorphism — leaves the attractor's Hausdorff dimension invariant.
- **Quasi-symmetric rigidity.** Theorem 6.1 quantifies how Hausdorff dimension can change under
  a quasi-symmetric map decomposed into Hölder pieces, with the product law controlling the
  cumulative distortion across the decomposition.
- **Dynamics and conjugacy.** The composition closure (§4) lets dimension estimates pass
  through conjugacies *g* ∘ *T* ∘ *g*⁻¹ link by link, rather than requiring a global regularity
  assumption on the conjugating map.
- **Analysis on metric spaces.** The set-local, `EMetricSpace`-level generality means the
  results apply to abstract doubling spaces and metric measure spaces, not merely to Euclidean
  subsets.

---

## 9. Discussion

The architecture deliberately separates two layers. The *single-map* layer (§3) is the
classical dimension-distortion theory, re-expressed in set-local form. The *composition* layer
(§4–§6) is the new contribution: it turns the regularity classes into composable categories and
reads off the multiplicative law for the exponents. Keeping the two layers distinct is what
makes the main theorem's proof short — it never re-derives a measure-theoretic estimate, only
composes maps and invokes the single-map results.

A second design decision worth emphasizing is the relentless use of *images* as the domain of
the next hypothesis. Because *g*'s regularity is assumed on *f*(*s*) — exactly the set that *f*
produces — the chaining requires no compatibility side-conditions beyond the left-inverse
identities. This is the technical reason the set-local formulation, rather than a global one,
is the correct altitude for a composition theory.

Finally, the exponent-one collapse (Corollary 6.2) is more than an aesthetic remark: it shows
the bi-Lipschitz and bi-Hölder results are one theorem, not two, unifying the
dimension-preserving and dimension-inflating regimes under a single product law.

---

## 10. Future directions

- **Coarse-graining and partial proofs.** Extend the calculus from injective good maps to
  non-injective coarse-grainings *f* : *α* → *β* that "forget" distinctions, and quantify the
  resulting controlled loss of dimension/information — a data-processing-style inequality for
  dimension.
- **Quantitative quasi-symmetry.** Refine the Hölder corridor of Theorem 6.1 into sharp
  two-sided control matching the modulus of quasi-symmetry, recovering known rigidity theorems
  as limiting cases.
- **Packing and box-counting dimensions.** Port the composition laws to the packing and
  upper/lower box-counting dimensions, where the multiplicative exponent law is expected to
  persist but the inverse-map handling differs.
- **Measures, not just sets.** Lift the distortion theory from dimension of sets to dimension of
  measures (local dimension, multifractal spectra) under composition of pushforwards.
- **Effective constants.** Track the multiplicative constants (*C_g* · *C_f*^(*r_g*)) through
  arbitrarily long chains and bound their growth, yielding effective uniformity statements for
  families of conjugacies.

---

## 11. Conclusion

We have given the composition calculus that the set-local Hausdorff-dimension distortion theory
was missing. The set-local antilipschitz class is closed under composition (constants multiply),
restriction, and the global-to-local bridge; composites of bi-Lipschitz maps preserve dimension
exactly; and composites of bi-Hölder maps distort dimension by the *product* of their Hölder
exponents, with bi-Lipschitz invariance as the exponent-one corollary. Every statement is
formalized over a general extended-metric space and machine-verified with standard axioms,
turning the historically error-prone task of composing distortion estimates into certified
mathematics. With these laws in place, the distortion theory finally reaches its intended
objects: the chained, iterated, conjugated maps from which fractals are actually built.
