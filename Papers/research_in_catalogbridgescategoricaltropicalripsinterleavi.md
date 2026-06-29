# Categorical Tropicalization of Interleaving Distance and Vietoris–Rips Stability

## Abstract

We develop, in a deliberately minimal order-theoretic setting, the algebraic and
geometric core of persistence stability and exhibit its tropical (min-plus)
nature. A **persistence module** is modeled as a monotone map `M : ℝ → α` into a
preorder `α`; an **ε-interleaving** of two modules is a pair of `ε`-shifted
dominations. We prove that interleavings form a reflexive, symmetric system that
is monotone in the shift and, crucially, **composable with additive shifts**:
an `ε`-interleaving followed by a `δ`-interleaving is an `(ε+δ)`-interleaving.
This composition law is the engine of the theory. From it we construct the
**interleaving distance** `interleavingDist : PersMod α → PersMod α → ℝ≥0∞` as
an infimum of admissible shifts and prove it is an extended pseudometric:
self-distance zero, symmetry, and the triangle inequality. We then show the
triangle inequality is **literally** a statement of tropical algebra: under the
canonical embedding `trop : ℝ≥0∞ → Tropical ℝ≥0∞` (where multiplication is
ordinary addition and addition is `min`/infimum), the triangle inequality is
exactly submultiplicativity, `trop d(M,L) ≤ trop d(M,N) · trop d(N,L)`. Finally
we specialize to **Vietoris–Rips modules** of a dissimilarity `d : X → X → ℝ`,
modeling the scale-`t` complex by its edge set `{(x,y) : d x y ≤ t} ⊆ X × X` in
the complete lattice `Set (X×X)`, and prove **stability**: sup-close
dissimilarities yield interleaved Rips modules, hence
`interleavingDist (RipsMod d) (RipsMod d') ≤ ENNReal.ofReal ‖d − d'‖_∞`. All
results are fully formally verified with no additional axioms beyond
`propext`, `Classical.choice`, and `Quot.sound`. We close with a program of
falsifiable conjectures (isometry/sharpness, an `ℝ≥0∞`-valued pseudo-emetric
structure, functoriality under Lipschitz maps, single-linkage ultrametric
refinement, and connectivity-threshold stability).

**Keywords.** persistent homology, interleaving distance, tropical semiring,
min-plus algebra, Vietoris–Rips filtration, stability, persistence modules,
extended pseudometric, topological data analysis.

---

## 1. Introduction

Persistent homology summarizes a parametrized family of spaces — a
**filtration** — by tracking the birth and death of topological features
(connected components, loops, voids) across a scale parameter. Its practical
utility rests on a single guarantee: **stability**. If the input is perturbed by
a small amount, the output summary changes by a correspondingly small amount.
Without stability, topological features extracted from noisy data would be
meaningless.

The standard formalization of "how close are two filtrations" is the
**interleaving distance**, introduced by Chazal, Cohen-Steiner, Glisse, Guibas,
and Oudot. The classical stability theorem states that the bottleneck distance
between persistence diagrams equals (or is bounded by) the interleaving distance
of the modules, which is in turn controlled by the sup-distance of the inputs.

This paper isolates the **order-theoretic skeleton** of that story and makes
explicit a structural fact that is often left implicit: the interleaving distance
is a tropical object. Composition of interleavings *adds shifts*, and ordinary
addition is multiplication in the **tropical (min-plus) semiring**; the optimal
interleaving is an infimum, which is tropical addition. The triangle inequality
is therefore not merely *analogous to* submultiplicativity in a tropical
semiring — it *is* submultiplicativity, after a faithful embedding.

We achieve maximal simplicity, without loss of faithfulness, by valuing
persistence modules in an arbitrary **preorder** `α`. In a preorder there is at
most one comparison between any two elements, so the naturality squares that
ordinarily decorate an interleaving commute automatically (proof irrelevance).
An interleaving thereby reduces to a pair of shifted pointwise inequalities, and
every categorical lemma becomes elementary real arithmetic — while the
mathematical content (composition, the pseudometric axioms, Rips stability) is
preserved exactly.

### Contributions

1. A minimal, faithful model of persistence modules and interleavings in a
   preorder (`PersMod`, `Interleaved`), with reflexivity, symmetry, monotone
   weakening, and the additive **composition law** (Section 2).
2. The `ℝ≥0∞`-valued **interleaving distance** and a complete proof that it is an
   extended pseudometric (Section 3).
3. The **tropical reformulation**: the triangle inequality is submultiplicativity
   of `trop ∘ interleavingDist` in `Tropical ℝ≥0∞` (Section 4).
4. **Vietoris–Rips stability** as a one-line metric estimate inside the lattice
   `Set (X×X)` (Section 5).
5. A program of five precise, falsifiable conjectures for future work
   (Section 7).

---

## 2. Persistence modules and interleavings

Throughout, `α` is a preorder.

### 2.1 Definition (Persistence module)

A **persistence module** valued in `α` is a structure

```
structure PersMod (α : Type u) [Preorder α] where
  obj  : ℝ → α
  mono : Monotone obj
```

i.e. a function `obj : ℝ → α` together with a proof that it is monotone:
`s ≤ t ⟹ obj s ≤ obj t`. We write `M.obj t` for the object at scale `t`.

The choice of a preorder codomain is the central modeling decision. Two canonical
instances:

- `α = Set (X × X)` ordered by inclusion: the Vietoris–Rips edge-set model
  (Section 5).
- `α = Prop` or `α = ℕ` (Betti-number proxies), recovering coarse but legitimate
  one-dimensional invariants.

### 2.2 Definition (ε-interleaving)

For `ε : ℝ`, two modules `M, N` are **ε-interleaved**, written `Interleaved ε M N`,
iff

```
(∀ t, M.obj t ≤ N.obj (t + ε)) ∧ (∀ t, N.obj t ≤ M.obj (t + ε)).
```

In a general (non-thin) target category, an interleaving additionally requires
two natural transformations whose composites equal the structure maps of the
`2ε`-shift. In a preorder these coherence conditions hold automatically, since
any two parallel morphisms (here, instances of `≤`) are equal. Thus the pair of
shifted dominations above is a *complete* description of an interleaving in this
setting.

### 2.3 Reflexivity, symmetry, weakening

**Proposition (reflexivity).** `Interleaved 0 M M`.

*Proof.* Both conjuncts read `M.obj t ≤ M.obj (t + 0) = M.obj t`. ∎

**Proposition (symmetry).** If `Interleaved ε M N` then `Interleaved ε N M`.

*Proof.* Swap the two conjuncts. ∎

**Proposition (weakening).** If `Interleaved ε M N` and `ε ≤ δ` then
`Interleaved δ M N`.

*Proof.* For the first conjunct, `M.obj t ≤ N.obj (t + ε) ≤ N.obj (t + δ)`, the
last step by monotonicity of `N.obj` since `t + ε ≤ t + δ`. Symmetrically for the
second. ∎

### 2.4 The composition law

This is the structural heart of the paper.

**Theorem 2.1 (Composition / tropical multiplication of interleavings).**
If `Interleaved ε M N` and `Interleaved δ N L`, then `Interleaved (ε + δ) M L`.

*Proof.* For the forward domination,
```
M.obj t ≤ N.obj (t + ε)            (first conjunct of the M–N interleaving)
        ≤ L.obj ((t + ε) + δ)      (first conjunct of the N–L interleaving)
        = L.obj (t + (ε + δ))      (associativity of +).
```
The reverse domination is symmetric:
```
L.obj t ≤ N.obj (t + δ) ≤ M.obj ((t + δ) + ε) = M.obj (t + (ε + δ)).
```
∎

Conceptually: interleavings compose, and **the shift is additive under
composition**. This single additivity is what makes the interleaving distance a
metric and what realizes it as a tropical object (Section 4).

---

## 3. The interleaving distance

We package the optimal interleaving into an extended-nonnegative-real distance.

### 3.1 Definition

Let `ℝ≥0∞ = [0, ∞]` denote the extended nonnegative reals. Define the **set of
admissible shifts**

```
interleavingSet M N := { x : ℝ≥0∞ | ∃ ε : ℝ, 0 ≤ ε ∧ Interleaved ε M N ∧ x = ENNReal.ofReal ε },
```

and the **interleaving distance**

```
interleavingDist M N := sInf (interleavingSet M N) : ℝ≥0∞.
```

By the convention `sInf ∅ = ⊤`, modules admitting no finite interleaving are at
distance `∞`.

### 3.2 The pseudometric axioms

**Theorem 3.1 (Self-distance).** `interleavingDist M M = 0`.

*Proof.* `0 ∈ interleavingSet M M`, witnessed by `ε = 0` via reflexivity
(Proposition 2.3) and `ENNReal.ofReal 0 = 0`; hence the infimum is `≤ 0`. Since
all elements of `ℝ≥0∞` are `≥ 0`, equality holds. ∎

**Theorem 3.2 (Symmetry).** `interleavingDist M N = interleavingDist N M`.

*Proof.* The map `ε ↦ ε` is a bijection between admissible shifts for `(M, N)`
and for `(N, M)`, because `Interleaved ε M N ↔ Interleaved ε N M` (symmetry,
Proposition 2.3). Hence the two infimum sets coincide, and so do their infima. ∎

**Lemma 3.3 (Upper bound from a witness).** If `0 ≤ ε` and `Interleaved ε M N`,
then `interleavingDist M N ≤ ENNReal.ofReal ε`.

*Proof.* `ENNReal.ofReal ε ∈ interleavingSet M N`, and the infimum of a set lies
below any of its members. ∎

**Theorem 3.4 (Triangle inequality).**
`interleavingDist M L ≤ interleavingDist M N + interleavingDist N L`.

*Proof.* It suffices to prove that for every admissible shift `x` for `(M, N)` and
every admissible shift `y` for `(N, L)`,
```
interleavingDist M L ≤ x + y.                    (∗)
```
Granting (∗), the result follows by the identities
`sInf A + sInf B = sInf { x + y : x ∈ A, y ∈ B }` for the `ℝ≥0∞`-infimum
(`ENNReal.sInf_add` together with `ENNReal.add_sInf`), reducing the goal to (∗)
quantified over the two sets.

To prove (∗): write `x = ENNReal.ofReal ε`, `y = ENNReal.ofReal δ` with `ε, δ ≥ 0`
and `Interleaved ε M N`, `Interleaved δ N L`. By the composition law
(Theorem 2.1), `Interleaved (ε + δ) M L`, and `ε + δ ≥ 0`. By Lemma 3.3,
```
interleavingDist M L ≤ ENNReal.ofReal (ε + δ) = ENNReal.ofReal ε + ENNReal.ofReal δ = x + y,
```
the middle equality being `ENNReal.ofReal_add` (valid since `ε, δ ≥ 0`). ∎

Theorems 3.1, 3.2, 3.4 together state that `interleavingDist` is an **extended
pseudometric** on `PersMod α`. (Separation — `d(M, N) = 0 ⟹ M = N` — fails in
general and is *correctly* not claimed: distinct modules can be at distance zero;
see Conjecture 2 in Section 7 for the left-continuous refinement that recovers
separation.)

---

## 4. The tropical reformulation

The **tropical (min-plus) semiring** `Tropical ℝ≥0∞` has carrier `ℝ≥0∞` with

- tropical addition `a ⊕ b := min(a, b)` (and, for infinite families, `inf`);
- tropical multiplication `a ⊙ b := a + b` (ordinary addition);
- tropical unit `1_trop = 0` and tropical zero `0_trop = ⊤`.

Order is **reversed** under the standard convention: `trop a ≤ trop b ⟺ a ≤ b`
holds with the order chosen so that tropical multiplication is monotone. We use
the embedding `trop : ℝ≥0∞ → Tropical ℝ≥0∞`.

### 4.1 The triangle inequality is submultiplicativity

**Theorem 4.1 (Tropical submultiplicativity).**
```
trop (interleavingDist M L) ≤ trop (interleavingDist M N) · trop (interleavingDist N L)
```
in `Tropical ℝ≥0∞`, where `·` is tropical multiplication.

*Proof.* Unfolding the tropical operations, the right-hand side is
`trop (interleavingDist M N + interleavingDist N L)`, and `trop` is
order-preserving onto its image; the claim is therefore equivalent, after
unfolding, to the ordinary triangle inequality Theorem 3.4. ∎

The content of Theorem 4.1 is conceptual rather than computational: it certifies
that the assignment `(M, N) ↦ trop (interleavingDist M N)` is a **lax (tropical)
enrichment** of the category of persistence modules. Composition of
interleavings is tropical multiplication; the self-distance `trop 0 = 1_trop` is
the tropical unit (the identity of `⊙`); and the optimal interleaving, being an
infimum, is a tropical sum. The interleaving distance is, in the precise sense of
Theorem 4.1, a **min-plus valuation** on pairs of modules.

This is the bridge advertised in the title: categorical persistence theory
(functors out of `(ℝ, ≤)` and their interleavings) and tropical algebra (the
min-plus semiring) are two presentations of the same structure, joined by the
additive composition law.

---

## 5. Vietoris–Rips modules and stability

We now instantiate `α = Set (X × X)`, the complete lattice of binary relations on
a fixed set `X`, ordered by inclusion.

### 5.1 Definition (Vietoris–Rips module)

For a **dissimilarity** `d : X → X → ℝ` (no axioms required — `d` need not be
symmetric or satisfy the triangle inequality), the **Vietoris–Rips module** is

```
RipsMod d : PersMod (Set (X × X)),    (RipsMod d).obj t := { p | d p.1 p.2 ≤ t }.
```

Monotonicity is immediate: if `s ≤ t` and `d p.1 p.2 ≤ s`, then
`d p.1 p.2 ≤ t`, so the edge set at scale `s` is contained in that at scale `t`.
This is the 1-skeleton (edge-set) model of the Vietoris–Rips filtration; modeling
the complex by its edge set inside the complete lattice keeps stability to a
single metric estimate.

### 5.2 Stability

**Theorem 5.1 (Rips stability).** Let `d, d' : X → X → ℝ` and `ε ≥ 0` satisfy the
pointwise bound `|d x y − d' x y| ≤ ε` for all `x, y`. Then
`Interleaved ε (RipsMod d) (RipsMod d')`.

*Proof.* We verify the first domination; the second is symmetric. Fix `t` and a
pair `p = (x, y)` with `(RipsMod d).obj t`-membership, i.e. `d x y ≤ t`. The bound
`|d x y − d' x y| ≤ ε` gives `d' x y ≤ d x y + ε ≤ t + ε`, so
`p ∈ (RipsMod d').obj (t + ε)`. Hence `(RipsMod d).obj t ⊆ (RipsMod d').obj (t + ε)`,
which is `(RipsMod d).obj t ≤ (RipsMod d').obj (t + ε)` in `Set (X×X)`. ∎

**Corollary 5.2 (Distance bound).** Under the hypotheses of Theorem 5.1,
```
interleavingDist (RipsMod d) (RipsMod d') ≤ ENNReal.ofReal ε.
```
In particular, taking `ε = ‖d − d'‖_∞ := ⨆_{x,y} |d x y − d' x y|` (when finite),
```
interleavingDist (RipsMod d) (RipsMod d') ≤ ENNReal.ofReal ‖d − d'‖_∞.
```

*Proof.* Immediate from Theorem 5.1 and Lemma 3.3. ∎

Corollary 5.2 is the **stability theorem** in this framework: the interleaving
distance between Rips modules is controlled by the sup-distance of their
dissimilarities. A perturbation of the input metric of size `ε` moves the entire
persistence summary by at most `ε` in interleaving distance — quantitatively,
provably, and with no smoothness or symmetry assumption on `d`.

---

## 6. Discussion

### 6.1 Faithfulness of the order-theoretic model

A natural worry is whether collapsing to a preorder discards essential
information. It does not, for the structural claims at issue. Interleaving
distance, the pseudometric axioms, and Rips stability are all statements about
the *existence* of shifted dominations and the *arithmetic* of shifts; none
references the internal homological structure beyond the partial order of
sublevel objects. The preorder model captures precisely this layer, and does so
without the coherence bookkeeping that obscures the additive composition law in
richer categories. The dimension-wise homology functor `Hₖ(−; F)` post-composed
with the Rips construction lands in vector-space-valued modules; the order-theoretic
results here are the universal backbone that those richer invariants inherit.

### 6.2 Why tropical, really

The recurring presence of `min`/`inf` (optimal interleaving) and `+` (composing
shifts) is not a coincidence of notation. Any quantity defined as a best-case
combination over chains, where chains compose additively, is governed by min-plus
algebra; this is the same reason shortest-path distances, Legendre transforms,
and large-deviation rate functions are tropical. Interleaving distance is the
persistence-theoretic member of that family, and Theorem 4.1 records its
membership precisely.

### 6.3 On the missing separation axiom

We deliberately do **not** assert `interleavingDist M N = 0 ⟹ M = N`. It is
false in the present generality: two modules differing only on a measure-zero set
of "jump" scales can be `0`-interleaved without being equal. The honest object is
therefore a pseudometric, not a metric. Restricting to **left-continuous**
modules (those equal to the supremum of their predecessors) is the standard
remedy and is the content of Conjecture 2 below; we leave it as future work
rather than overstate the present results.

---

## 7. Future directions

The following conjectures are concrete and falsifiable: each can be settled by a
proof or by a single finite counterexample.

**Conjecture 1 (Isometry / sharpness of stability).** For finite `X` and
pseudometrics `d, d'`, the bound of Corollary 5.2 is an *equality*:
```
interleavingDist (RipsMod d) (RipsMod d') = ENNReal.ofReal (⨆_{x,y} |d x y − d' x y|),
```
whenever the sup is finite. The `≥` direction would follow by extracting, from any
`ε`-interleaving of edge-set modules, the pointwise bound `|d x y − d' x y| ≤ ε`
(evaluate the interleaving at `t = d x y`). *Falsifier:* a 3-point example with a
strict gap.

**Conjecture 2 (Genuine extended pseudo-emetric; separation).** Replacing `ℝ` by
`ℝ≥0∞` throughout and dropping nonemptiness hypotheses, the `ℝ≥0∞`-valued
distance is a `PseudoEMetricSpace` on the type of monotone filtrations, with
`d(F, G) = 0 ⟺ F = G` on *left-continuous* filtrations. The `sInf ∅ = ⊤`
convention removes the nonemptiness side-conditions that are load-bearing in the
`ℝ`-valued version. *Falsifier:* two distinct left-continuous monotone
filtrations at distance `0`.

**Conjecture 3 (Functoriality under Lipschitz maps).** A `1`-Lipschitz map
`φ : (X, d) → (X', d')` (i.e. `d'(φx, φy) ≤ d(x, y)`) induces graph homomorphisms
`RipsMod d ε → RipsMod d' ε` for all `ε`, and the induced map on filtrations is
`1`-Lipschitz for the interleaving distance:
`interleavingDist (push φ F) (push φ G) ≤ interleavingDist F G`. This exhibits
`interleavingDist` as a functor from finite metric spaces and Lipschitz maps into
the tropical-enriched category of filtrations. *Falsifier:* a Lipschitz map that
strictly increases some interleaving distance.

**Conjecture 4 (Single-linkage ultrametric refinement).** The
connected-components (`π₀`) functor applied to `RipsMod d` recovers the
single-linkage dendrogram, and the merge-scale distance
`d_SL(x, y) := inf { ε | x, y connected in RipsMod d ε }` is an **ultrametric**:
`d_SL(x, z) ≤ max(d_SL(x, y), d_SL(y, z))`, with the chained bound
```
interleavingDist (RipsMod d) (RipsMod d') ≤ ‖d_SL − d'_SL‖_∞ ≤ ‖d − d'‖_∞.
```
Thus single-linkage is a tropical-idempotent contraction of the metric, and
`d_SL` is exactly the ultrametric reconstructed from the tropical valuation data
of the filtration. *Falsifier:* a 4-point example violating the strong triangle
inequality for `d_SL`.

**Conjecture 5 (Connectivity-threshold stability).** Define the connectivity
(Poincaré) threshold `θ(d) := inf { ε | RipsMod d ε is connected }`. Then `θ` is
`1`-Lipschitz in the sup-distance: `|θ(d) − θ(d')| ≤ ‖d − d'‖_∞`. This follows
from Theorem 5.1 by transferring connectivity along an interleaving (a
`δ`-interleaving moves connectivity thresholds by at most `δ`). *Falsifier:* a
finite perturbation moving the connectivity threshold by more than
`‖d − d'‖_∞`.

---

## 8. Conclusion

We have isolated the order-theoretic and tropical core of persistence stability
in a minimal, fully verified package. The decisive structural fact is the
**additive composition law** for interleavings (Theorem 2.1): it makes the
interleaving distance an extended pseudometric (Section 3) and realizes it as a
**min-plus valuation** in the tropical semiring (Theorem 4.1). Specializing to
Vietoris–Rips modules yields stability — sup-close dissimilarities are
interleaved — as a single metric estimate (Section 5). The result is a clean
bridge between categorical persistence theory, tropical algebra, and the geometry
of data, accompanied by a program of falsifiable conjectures sharpening each face
of the bridge.
