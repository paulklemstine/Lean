# Relabeling Invariance and Quotient Transport for the Categorical Tropical Rips Interleaving Geometry

## Abstract

We develop a compact, fully formalized theory of **transport-compatibility and
invariance** for the interleaving geometry of filtrations, read through a
categorical–tropical lens. A *filtration* on a label set is a monotone, grounded
real weighting of finite simplices — equivalently a tropical (min-plus) weight on
the simplicial cone. Two endofunctors act on filtrations: the **shift** (additive
smoothing) `shift a`, which lowers every weight by a constant `a ≥ 0`, and the
**relabeling** functor `comap e` along an equivalence of label sets `e : α ≃ β`,
which pulls a filtration back through the induced map on simplices. Our principal
results are: (i) **functorial commutation** `comap e (shift a F) = shift a (comap e F)`;
(ii) **relabeling invariance of interleaving** — for every scale `δ`, `comap e F`
and `comap e G` are `δ`-interleaved iff `F` and `G` are, whence both the real-valued
interleaving distance and its `ℝ≥0∞`-valued refinement are invariant under
relabeling; (iii) **descent to the separation quotient**, where the interleaving
pseudometric becomes a genuine extended metric and relabeling remains an isometry on
classes; and (iv) a **transport principle** that propagates any exact
self-shift-distance equation `interleavingDist(F, shift a F) = a` verbatim to every
relabeling `comap e F` and to the corresponding quotient classes. The development
introduces no new analytic machinery: it rests on a filtration extensionality
lemma, the standard interleaving/pseudometric API, and the separation-quotient
construction. The upshot is a clean statement that the interleaving distance is a
true invariant of the *shape* of data, blind to the naming of data points, together
with a mechanism to reuse exact computations across entire relabeling orbits.

**Keywords.** persistent homology, Vietoris–Rips, interleaving distance, tropical
geometry, filtration, separation quotient, extended metric space, functoriality.

---

## 1. Introduction

Topological data analysis (TDA) extracts multiscale geometric features — connected
components, loops, voids — from data by interpolating a one-parameter family of
spaces, a *filtration*, and recording the births and deaths of homological
features across scales. The comparison of two such families is governed by the
**interleaving distance**, the canonical (extended pseudo-)metric on filtrations and
on the persistence modules they generate, and the object whose stability under data
perturbation underlies the entire field.

A foundational expectation, almost always left tacit in applications, is that the
interleaving geometry depends only on the *shape* encoded by a filtration and not on
the arbitrary labeling of the underlying data points. Sorting, hashing, sharding,
or otherwise permuting samples is ubiquitous in practice; correctness of any such
pipeline silently presumes that relabeling cannot alter the geometric answer. This
paper isolates and proves that expectation, in a form strong enough to be reused
mechanically.

We work in a **categorical–tropical** presentation of the Rips interleaving arc. A
filtration is a tropical (min-plus) weighting of simplices; the additive smoothing
operator and the relabeling operator are the natural endofunctors; and interleaving
distance is the induced extended pseudometric. In this language we prove four
things:

1. **Commutation** of smoothing and relabeling (Theorem 3.1).
2. **Relabeling invariance** of interleaving and of the (real and `ℝ≥0∞`) distances
   (Theorems 4.1–4.3).
3. **Descent to the separation quotient**, where interleaving becomes a genuine
   extended metric and relabeling remains an isometry (Theorem 5.1).
4. A **transport principle** propagating exact self-shift-distance equations across
   relabelings and into the quotient (Theorems 6.1–6.2).

All statements are theorems with complete formal proofs; below we give precise
statements and self-contained proof sketches.

### 1.1 Context and motivation

The interleaving distance was introduced to compare persistence modules and, more
generally, functors out of a poset into a target category. Its defining feature is
that it is computed not by a single optimal matching but by the existence of a pair
of shift-compatible comparison morphisms in both directions. This makes it robust
and functorial, but it also means that even basic invariance properties must be
verified at the level of the comparison data rather than asserted by analogy with
ordinary metrics. The present work treats one such property — invariance under
relabeling of the underlying ground set — with the care it deserves, and turns it
into reusable infrastructure.

There are two reasons this is more than pedantry. First, persistence pipelines
routinely permute, sort, hash, and shard their inputs; a guarantee that these label
manipulations cannot affect the geometric answer is precisely a relabeling-invariance
theorem. Second, exact (as opposed to merely bounded) interleaving computations are
rare and valuable; a principle that converts one exact computation into infinitely
many — one per relabeling, plus one per shape class — multiplies the value of each
hard-won equality. Both reasons converge on the same small set of structural
lemmas, which we now make precise.

---

## 2. Definitions

Throughout, `α`, `β`, `γ` denote label types (the vertex sets of the simplicial
data). A *simplex* on `α` is a finite subset `σ` of `α`; the simplices form the
lattice of finite subsets under inclusion.

### 2.1 Filtrations

**Definition 2.1 (Filtration).** A *filtration* `F` on `α` is a function
`weight : Finset α → ℝ` together with two properties:

- **Monotonicity.** `σ ⊆ τ ⟹ weight(σ) ≤ weight(τ)`.
- **Grounding.** `weight(∅)` is normalized at the bottom of the family
  (`weight_empty`).

Monotonicity is the order-preservation of appearance times: a face cannot appear
later than a coface. In the min-plus reading, `weight` is a tropical weighting on
the simplicial cone, and the sublevel family `{ σ : weight(σ) ≤ t }` is the
sublevel complex at scale `t`.

**Lemma 2.2 (Extensionality).** Two filtrations are equal as soon as their weight
functions agree: if `F.weight = G.weight` then `F = G`.

*Proof sketch.* The monotonicity and grounding fields are propositions
(proof-irrelevant), so equality of the data field `weight` determines the structure
up to definitional equality; destructuring both filtrations and substituting the
hypothesis closes the goal. ∎

### 2.2 The shift (smoothing) functor

**Definition 2.3 (Shift).** For `a ≥ 0` and a filtration `F` on `α`, the *shift*
`shift a F` is the filtration with

> `(shift a F).weight(σ) = F.weight(σ) − a`.

Monotonicity and grounding are inherited because subtracting a constant preserves
order and the normalization (`0 ≤ a` ensures the grounding inequality persists).
Operationally, the sublevel complex of `shift a F` at scale `t` is the sublevel
complex of `F` at scale `t + a`; smoothing advances every appearance by `a`.

### 2.3 The relabeling (comap) functor

**Definition 2.4 (Comap / relabeling).** For an equivalence `e : α ≃ β` and a
filtration `F` on `β`, the *relabeling* `comap e F` is the filtration on `α` with

> `(comap e F).weight(σ) = F.weight( map(e)(σ) )`,

where `map(e)(σ)` is the image of the simplex `σ` under the embedding induced by
`e`. Grounding follows since `map(e)(∅) = ∅`; monotonicity follows because `map(e)`
is inclusion-preserving (`σ ⊆ τ ⟹ map(e)(σ) ⊆ map(e)(τ)`), and `F` is monotone.
Thus `comap` is a contravariant functor on the groupoid of label equivalences.

### 2.4 Interleaving and interleaving distance

Two filtrations on the same label set are compared via their sublevel families.

**Definition 2.5 (δ-interleaving).** For `δ ≥ 0`, filtrations `F` and `G` are
*δ-interleaved* if the sublevel complex of `F` at every scale `t` is contained in
the sublevel complex of `G` at `t + δ`, and symmetrically with the roles reversed.
Concretely, for every simplex and scale the appearance times satisfy mutual
`δ`-domination.

**Definition 2.6 (Interleaving distances).** The *interleaving distance* is

> `interleavingDist(F, G) = inf { δ ≥ 0 : F and G are δ-interleaved }`,

a real-valued quantity, and `eInterleavingDist(F, G)` is its `ℝ≥0∞`-valued
refinement (allowing `+∞` when no finite interleaving exists). For the sublevel
filtrations considered here, `interleavingDist(F, G)` coincides with the uniform
(sup) norm of the weight difference, `sup_σ |F.weight(σ) − G.weight(σ)|`; this
identity is the engine behind the explicit values in §6.

**Proposition 2.7 (Pseudometric / extended metric structure).** `eInterleavingDist`
is an extended pseudometric on filtrations: it is reflexive-zero, symmetric, and
satisfies the triangle inequality. It need not separate points: two filtrations may
have distance zero without being equal.

---

## 3. Smoothing commutes with relabeling

**Theorem 3.1 (`shift_comap`).** For every equivalence `e : α ≃ β`, every `a ≥ 0`,
and every filtration `F` on `β`,

> `comap e (shift a F) = shift a (comap e F)`.

*Proof sketch.* By extensionality (Lemma 2.2) it suffices to compare weight
functions. On a simplex `σ`,

```
(comap e (shift a F)).weight(σ) = (shift a F).weight(map(e)(σ))
                                = F.weight(map(e)(σ)) − a,
(shift a (comap e F)).weight(σ) = (comap e F).weight(σ) − a
                                = F.weight(map(e)(σ)) − a.
```

The two are syntactically identical, so the weight functions agree and the
filtrations are equal. ∎

This is the naturality square of the two endofunctors: the diagram of "smooth then
relabel" versus "relabel then smooth" commutes on the nose. It is the structural
fact that powers the transport principle of §6.

---

## 4. Relabeling invariance of interleaving

### 4.1 The interleaving biconditional

**Theorem 4.1 (`Interleaved_comap_iff`).** For every equivalence `e : α ≃ β`,
filtrations `F, G` on `β`, and scale `δ`,

> `comap e F` and `comap e G` are δ-interleaved ⟺ `F` and `G` are δ-interleaved.

*Proof sketch.* Unfold the sublevel-faces definition of interleaving on both sides.
For the forward direction, a containment witness for the relabeled filtrations at
scale `t` is transported to a witness for `F, G` by applying `map(e.symm)` to each
simplex: since `map(e)` and `map(e.symm)` are mutually inverse bijections on
simplices and preserve the sublevel conditions, the relabeled containment is carried
back to the original. The reverse direction applies `map(e)` directly. The two
sublevel inclusions (each direction of the interleaving) are handled symmetrically.
∎

The conceptual content is that relabeling is an *isomorphism of the sublevel-complex
diagrams*; it cannot change which scale shifts `δ` realize an interleaving, because
it merely renames the simplices participating in each containment.

### 4.2 Invariance of the distances

**Theorem 4.2 (`interleavingDist_comap`).** For every equivalence `e : α ≃ β` and
filtrations `F, G` on `β`,

> `interleavingDist(comap e F, comap e G) = interleavingDist(F, G)`.

*Proof sketch.* The interleaving distance is the infimum over the set
`{ δ : F, G are δ-interleaved }`. By Theorem 4.1 this set is identical for the
relabeled and original pairs, so the two infima coincide. ∎

**Theorem 4.3 (`eInterleavingDist_comap`).** With the same hypotheses, the
`ℝ≥0∞`-valued interleaving distance is invariant:

> `eInterleavingDist(comap e F, comap e G) = eInterleavingDist(F, G)`.

*Proof sketch.* Identical reasoning at the level of extended reals: the defining
predicate set is unchanged by Theorem 4.1, so the extended infimum (taken in
`ℝ≥0∞`, including the `+∞` case) is unchanged. ∎

Together these say the interleaving geometry is a **labeling-free invariant**: it is
a function of the shape, not of any enumeration of the data.

---

## 5. Descent to the separation quotient

The pseudometric of Proposition 2.7 fails to separate points: distinct filtrations
can sit at distance zero. The canonical remedy is the **separation quotient**, which
collapses each distance-zero class to a point and yields a genuine extended metric
space `IsoClass(α)`, the natural home of persistence "shape classes."

**Theorem 5.1 (`edist_mk_comap`).** Equip filtrations with the interleaving
pseudo-extended-metric, and let `mk` denote the quotient map to the separation
quotient. For every equivalence `e : α ≃ β` and filtrations `F, G` on `β`,

> `edist( mk(comap e F), mk(comap e G) ) = edist( mk(F), mk(G) )`.

*Proof sketch.* By the defining property of the separation quotient, the genuine
extended distance between classes equals the pseudometric distance between
representatives: `edist(mk(X), mk(Y)) = eInterleavingDist(X, Y)`. Applying this on
both sides and invoking Theorem 4.3 yields the equality. ∎

Thus relabeling descends to an **isometry of the quotient extended-metric space**.
On `IsoClass(α)` the full Mathlib extended-metric topology — completeness,
continuity, uniform structure — becomes available, and within it relabeling is
invisible.

---

## 6. The transport principle

We now harvest the structural lemmas into a reuse mechanism for *exact*
self-shift-distance computations. Such equalities — distinguished from the routine
upper bound `interleavingDist(F, shift a F) ≤ a` by asserting equality — are the
sharp invariants one actually wants, and they can be costly to establish for a given
filtration. The transport principle makes each one infinitely reusable.

**Theorem 6.1 (Transport across relabelings, `selfShiftDist_comap`).** Let
`e : α ≃ β`, `a ≥ 0`, and `F` a filtration on `β`. If

> `interleavingDist(F, shift a F) = a`,

then for the relabeling,

> `interleavingDist(comap e F, shift a (comap e F)) = a`.

*Proof sketch.* By Theorem 3.1, `shift a (comap e F) = comap e (shift a F)`. Hence
`interleavingDist(comap e F, shift a (comap e F))
= interleavingDist(comap e F, comap e (shift a F))`, which by Theorem 4.2 equals
`interleavingDist(F, shift a F) = a`. ∎

**Theorem 6.2 (Transport into the quotient, `eSelfShiftDist_transport`).** Let
`e : α ≃ β`, `a ≥ 0`, `F` a filtration on `β`, and `d ∈ ℝ≥0∞`. If

> `eInterleavingDist(F, shift a F) = d`,

then the genuine extended distance between the quotient classes satisfies

> `edist( mk(comap e F), mk(shift a (comap e F)) ) = d`.

*Proof sketch.* Rewrite `shift a (comap e F)` as `comap e (shift a F)` via
Theorem 3.1; pass to representatives using the separation-quotient identity
`edist(mk(X), mk(Y)) = eInterleavingDist(X, Y)`; then apply Theorem 4.3 to move the
`comap e` outside, reducing to `eInterleavingDist(F, shift a F) = d`. ∎

**Worked instance.** For the sublevel-norm presentation of the distance, every
simplex of `shift a F` is displaced by exactly `a`, so on any nontrivial label set
`interleavingDist(F, shift a F) = a` (the supremum of `|−a|` over simplices is `a`).
Theorem 6.1 then immediately yields `interleavingDist(comap e F, shift a (comap e F)) = a`
for *every* relabeling `e`, and Theorem 6.2 propagates the value to all
corresponding shape classes — with no further computation.

---

## 7. Algorithms

Although the theory is qualitative, it has direct algorithmic content for finite
data. We record two routines used in the accompanying numerical demonstrations.

### 7.1 Finite interleaving distance via the sup-norm identity

For filtrations on a finite label set, `interleavingDist` equals the maximum of
`|F.weight(σ) − G.weight(σ)|` over all nonempty simplices `σ`. The algorithm
enumerates the simplices and maximizes the absolute weight difference.
Complexity: `Θ(2^n)` simplices on `n` labels (or `Θ(|S|)` if restricted to a fixed
simplex set `S`).

### 7.2 Relabeling-invariance checker

Given a permutation `e` of labels and two filtrations, the checker computes the
distance before and after applying `comap e`, confirming equality up to floating
tolerance. This is an executable witness of Theorem 4.2, and (by composing with a
shift) of Theorem 6.1.

---

## 8. Applications

- **Pipeline correctness.** Any preprocessing step that permutes or relabels data
  points — sorting, hashing, sharding across machines — is certified harmless to the
  interleaving geometry by Theorems 4.2–4.3.
- **Computation reuse.** The transport principle (Theorems 6.1–6.2) licenses
  computing an exact self-shift distance on the most convenient representative of a
  shape and reading off the answer for its entire relabeling orbit and quotient
  class.
- **Foundations for stability.** By descending to the separation quotient
  (Theorem 5.1), the interleaving distance becomes a genuine extended metric on
  shape classes — the setting in which algebraic stability theorems are most cleanly
  stated and in which the standard extended-metric topology applies.
- **Tropical symmetry.** Read tropically, the commutation `shift_comap` exhibits
  relabeling as a min-plus-linear symmetry commuting with additive smoothing,
  situating persistence inside tropical geometry.

---

## 9. Discussion

The contribution is deliberately foundational: it makes precise, and proves, the
assumption that an interleaving-based invariant depends only on the shape of data
and not on its labeling, and it packages exact self-shift computations for reuse.
Five observations are worth highlighting.

**On the role of the equivalence.** The choice to relabel along an equivalence
`e : α ≃ β` rather than an arbitrary function is exactly what upgrades invariance
from a one-sided bound to a two-sided equality. A non-invertible relabeling could
merge or duplicate simplices and would only yield a contraction; the inverse
`e.symm` is what transports interleaving witnesses back across the renaming in
Theorem 4.1, giving the `if` direction of the biconditional.

**On proof economy.** The four headline theorems are short because they are
organized around a single reusable equality (`shift_comap`) and a single reusable
biconditional (`Interleaved_comap_iff`); everything quantitative is a corollary of
one of these together with the standard infimum and separation-quotient APIs. This
is the hallmark of a well-factored development: the conceptual content lives in two
lemmas and the rest is bookkeeping.

Further design choices:

First, the entire development rides on a single extensionality lemma plus the
existing interleaving and separation-quotient API; no new analytic theory is
introduced. This keeps the results robust and easy to extend.

Second, working through the equivalence `e : α ≃ β` rather than an arbitrary map is
exactly what makes invariance an *equality* rather than a one-sided bound: the
inverse `e.symm` transports witnesses both ways in Theorem 4.1.

Third, the separation quotient is treated as the genuine object of interest. Once
distance-zero filtrations are identified, the interleaving distance becomes a true
metric and relabeling a true isometry, aligning the formal objects with the
informal notion of "the shape of the data."

---

## 10. Future work

Natural next targets, building directly on the lemmas above, include:

- **Sharpness of contraction bounds.** Determine the cardinalities of the label set
  at which rank/Betti-curve stability is an isometric invariant versus a strict
  contraction, isolating saturation and strict-drop phenomena.
- **An isometric `ℝ≥0`-action of shift on the quotient.** Descend the shift to the
  shape-class space and prove it acts isometrically with displacement exactly `a`.
- **A genuine extended-metric instance on shape classes.** Assemble reflexivity,
  symmetry, triangle inequality, and point separation into a packaged
  `EMetricSpace`, exporting completeness and continuity vocabulary.
- **Lipschitz descent of functorial invariants.** Show that contracting functors
  (e.g. rank) send distance-zero classes to distance-zero classes and hence descend
  to 1-Lipschitz maps of quotient metrics.
- **Characterizing tightness.** Identify exactly which filtrations make the
  self-shift displacement equal to (rather than strictly below) `a`, in terms of
  the absence of flat windows.

---

## 11. Conclusion

We have shown, with full rigor, that the categorical–tropical Rips interleaving
geometry is invariant under relabeling at every level — the interleaving relation,
the real and extended distances, and the separation quotient — and that smoothing
commutes with relabeling. From these we extracted a transport principle that
propagates any exact self-shift-distance equality across all relabelings of a
filtration and into its shape classes. The net statement is simple and
consequential: the interleaving distance measures the shape of data and is blind to
its names, and exact measurements made once may be reused everywhere.
