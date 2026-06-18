# The Interleaving Distance and Bottleneck Stability of Sublevel Filtrations: A Sharp 1-Lipschitz Metric Theory of Persistence

## Abstract

Persistent homology turns a finite, weighted, or metric data set into a
one-parameter nested family of simplicial complexes — a *filtration* — whose
multiscale topological features summarize the shape of the data. For this
summary to be scientifically meaningful it must be *stable*: small perturbations
of the data must induce only small perturbations of the computed topology. We
develop a self-contained metric theory of this stability at the level of the
filtration itself. We define a symmetric, additively composable **interleaving
relation** `Interleaved F G δ` on sublevel filtrations, prove it is reflexive,
symmetric, monotone in the shift, and additive (the relational triangle
inequality), and distill from it a real-valued **interleaving distance**
`interleavingDist`, which we show is nonnegative, vanishes on the diagonal,
is symmetric, and is bounded above by every admissible interleaving shift. We
then prove the **Cohen-Steiner–Edelsbrunner–Harer sublevel stability theorem**
in its sharp 1-Lipschitz form: if two filtrations have weight functions within
sup-norm distance `D`, then they are `D`-interleaved and their interleaving
distance is at most `D`. Specializing to the **Vietoris–Rips** filtration built
from an explicit distance matrix, we isolate the single load-bearing estimate —
the simplex diameter is 1-Lipschitz in the input metric — and derive a complete
Gromov–Hausdorff/correspondence-distortion stability layer: a distortion of at
most `ε` between two distance matrices forces an `ε`-interleaving and hence a
bottleneck bound of `ε`. We close with a fully explicit certificate on two
three-point clouds. The entire stability phenomenon reduces to one inequality;
everything downstream is monotonicity bookkeeping. We also catalog the precise
fault line (the real-valued infimum convention `inf ∅ = 0`) that motivates an
`EReal`-valued upgrade, and lay out five concrete research directions.

**Keywords:** persistent homology, interleaving distance, bottleneck distance,
stability theorem, Vietoris–Rips filtration, Gromov–Hausdorff, topological data
analysis, Lipschitz continuity, simplicial complex.

---

## 1. Introduction

Topological data analysis (TDA) extracts qualitative, multiscale geometric
features — connected components, loops, voids, and their higher-dimensional
analogues — from finite data. Its central pipeline is:

1. From data (a finite metric space, a function, a point cloud) build a
   **filtration**: a nested, one-parameter family of simplicial complexes.
2. Compute the **persistence diagram**: the multiset of (birth, death) pairs of
   homological features across the parameter.
3. Compare or analyze diagrams.

The scientific legitimacy of this pipeline rests entirely on **stability**:
the map (data) ↦ (persistence diagram) must be Lipschitz, so that measurement
noise produces proportionate — not catastrophic — changes in the output.
The foundational stability theorem of Cohen-Steiner, Edelsbrunner, and Harer
(2007) establishes precisely this for sublevel-set persistence, and the
*isometry theorem* of Lesnick and of Bauer–Lesnick identifies the algebraic
interleaving distance with the combinatorial bottleneck distance, making the
bound sharp.

This paper develops the metric core of that theory in a clean, fully verified,
self-contained form. We work at the level of the **filtration** rather than the
persistence module, which keeps every argument elementary (set inclusions and
real inequalities) while losing none of the stability content. Our contributions
are:

- a packaged, named **interleaving relation** with all four order-theoretic
  properties (Section 3);
- a **real-valued interleaving distance** with its pre-distance axioms
  (Section 4);
- the **CESH stability theorem** in sharp 1-Lipschitz form (Section 5);
- a **Vietoris–Rips correspondence-distortion** stability layer over explicit
  distance matrices, reduced to a single Lipschitz estimate (Section 6);
- an **end-to-end concrete certificate** (Section 7);
- a careful account of the **`inf ∅` fault line** and five **future directions**
  (Sections 8–9).

This work closes a four-part development. Parts I–III established the filtration
calculus (abstract simplicial complexes, sublevel filtrations, the
Vietoris–Rips filtration, monotonicity, the Euler characteristic of a simplex)
and the relational stability lemmas (functoriality, δ-interleaving from
δ-closeness, additive composition). The present part assembles them into a single
coherent metric theory.

---

## 2. Preliminaries: filtrations and sublevel complexes

Fix a vertex type `α`. A **simplex** is a finite subset `σ : Finset α`; its
dimension is `|σ| − 1`.

**Definition 2.1 (Abstract simplicial complex).** An *abstract simplicial
complex* (ASC) on `α` is a set of simplices `faces` that contains the empty
simplex and is downward closed: if `σ ∈ faces` and `τ ⊆ σ` then `τ ∈ faces`.

**Definition 2.2 (Filtration).** A *filtration* on `α` is a weight function
`weight : Finset α → ℝ` together with two monotonicity conditions:

- `weight ∅ ≤ 0` (the empty simplex is born at the start);
- if `σ ⊆ τ` then `weight σ ≤ weight τ` (a face is born no later than any
  simplex containing it).

The number `weight σ` is the *birth scale* of `σ`.

**Definition 2.3 (Sublevel family).** The *sublevel faces* of a filtration `F`
at scale `t` are
> `F.sublevelFaces t := { σ : F.weight σ ≤ t }`.

For `t ≥ 0`, monotonicity makes `F.sublevelFaces t` an ASC (the *sublevel
complex*): the empty simplex qualifies since `weight ∅ ≤ 0 ≤ t`, and downward
closure is immediate because `τ ⊆ σ` forces `weight τ ≤ weight σ ≤ t`.

**Proposition 2.4 (Filtration monotonicity).** If `t₁ ≤ t₂` then
`F.sublevelFaces t₁ ⊆ F.sublevelFaces t₂`.

*Proof.* If `weight σ ≤ t₁ ≤ t₂` then `weight σ ≤ t₂`. ∎

**The Vietoris–Rips example.** On a pseudometric space, the *diameter weight* of
a simplex is the largest pairwise distance among its vertices (taken to be `0`
for the empty simplex and singletons). It is monotone (a larger simplex has at
least as many pairs, hence at least as large a maximum), so it defines a
filtration. Its sublevel complex at scale `ε` is exactly the Vietoris–Rips
complex `{ σ : ∀ x, y ∈ σ, dist x y ≤ ε }` — the bridge between the metric and
combinatorial pictures of persistence.

---

## 3. The interleaving relation

The comparison of two filtrations is governed by a single relation.

**Definition 3.1 (δ-interleaving).** For `δ ≥ 0`, two filtrations `F` and `G`
are *δ-interleaved*, written `Interleaved F G δ`, when

- `0 ≤ δ`,
- for every `t`, `F.sublevelFaces t ⊆ G.sublevelFaces (t + δ)`, and
- for every `t`, `G.sublevelFaces t ⊆ F.sublevelFaces (t + δ)`.

Each filtration, shifted forward in scale by `δ`, contains the other. This is
the combinatorial form of an interleaving of persistence modules.

**Theorem 3.2 (Interleaving is a graded preorder).** The relation `Interleaved`
satisfies:

1. **Reflexivity.** `Interleaved F F 0`.
2. **Symmetry.** `Interleaved F G δ` implies `Interleaved G F δ`.
3. **Monotonicity in the shift.** If `Interleaved F G δ` and `δ ≤ δ′` then
   `Interleaved F G δ′`.
4. **Additivity (triangle inequality).** If `Interleaved F G δ` and
   `Interleaved G H δ′` then `Interleaved F H (δ + δ′)`.

*Proof.*
(1) `0 ≤ 0`, and `F.sublevelFaces t ⊆ F.sublevelFaces (t + 0)` since `t + 0 = t`.
(2) Swap the two inclusion clauses; `0 ≤ δ` is preserved.
(3) Enlarge each shift via Proposition 2.4: from `F.sublevelFaces t ⊆
G.sublevelFaces (t + δ)` and `t + δ ≤ t + δ′` we get
`F.sublevelFaces t ⊆ G.sublevelFaces (t + δ′)`, and symmetrically; `0 ≤ δ ≤ δ′`.
(4) Chain the inclusions: `F.sublevelFaces t ⊆ G.sublevelFaces (t + δ) ⊆
H.sublevelFaces ((t + δ) + δ′)`, and `(t + δ) + δ′ = t + (δ + δ′)` by
associativity; the reverse direction uses `(t + δ′) + δ = t + (δ + δ′)` after
commuting `δ′` and `δ`. Nonnegativity adds. ∎

Property (4) is the engine of the entire metric theory: composing a δ-delay with
a δ′-delay yields a (δ + δ′)-delay because scale shifts add. This *is* the
triangle inequality, expressed purely relationally.

---

## 4. The interleaving distance

**Definition 4.1 (Interleaving distance).** The *interleaving distance* between
filtrations `F` and `G` is the infimum of all admissible shifts:
> `interleavingDist F G := inf { δ : ℝ | Interleaved F G δ }`.

(We adopt Lean's convention `inf ∅ = 0`; see Section 8 for the consequence and
its fix.)

**Theorem 4.2 (Pre-distance axioms).** The interleaving distance satisfies:

1. **Nonnegativity.** `0 ≤ interleavingDist F G`.
2. **Upper bound by any witness.** If `Interleaved F G δ` then
   `interleavingDist F G ≤ δ`.
3. **Diagonal.** `interleavingDist F F = 0`.
4. **Symmetry.** `interleavingDist F G = interleavingDist G F`.

*Proof.*
(1) Every admissible shift is `≥ 0` (first component of the relation), so the
set `{δ | Interleaved F G δ}` is bounded below by `0`; the infimum of a set
bounded below by `0` is `≥ 0`.
(2) `δ` belongs to the set, which is bounded below; hence the infimum is `≤ δ`.
(3) By (2) applied to the reflexive `Interleaved F F 0`, `interleavingDist F F ≤
0`; with (1) this gives equality.
(4) By Theorem 3.2(2) the two shift sets `{δ | Interleaved F G δ}` and
`{δ | Interleaved G F δ}` are equal, hence so are their infima. ∎

This makes `interleavingDist` a *symmetric, grounded pre-distance*. The triangle
inequality holds at the relational level (Theorem 3.2(4)) and transfers to the
distance whenever both pairs are interleavable; the only obstruction in the
real-valued model is the empty-set convention, addressed in Section 8.

---

## 5. Cohen-Steiner–Edelsbrunner–Harer stability, 1-Lipschitz form

We now connect closeness of *data* (weight functions) to closeness of *shape*
(filtrations).

**Definition 5.1 (Uniform closeness).** Filtrations `F` and `G` are
*`D`-close* (written `WeightCloseBy F G D`) when
> `|F.weight σ − G.weight σ| ≤ D` for every simplex `σ`.

This is the sup-norm distance of the two weight functions.

**Lemma 5.2 (Two-sided interleaving from closeness).** If `F` and `G` are
`D`-close, then for every `t`,
`F.sublevelFaces t ⊆ G.sublevelFaces (t + D)` and
`G.sublevelFaces t ⊆ F.sublevelFaces (t + D)`.

*Proof.* From `|F.weight σ − G.weight σ| ≤ D` we extract
`G.weight σ ≤ F.weight σ + D` and `F.weight σ ≤ G.weight σ + D`. If
`F.weight σ ≤ t` then `G.weight σ ≤ F.weight σ + D ≤ t + D`, giving the first
inclusion; the second is symmetric. ∎

**Theorem 5.3 (CESH stability, interleaving form).** If `0 ≤ D` and `F`, `G`
are `D`-close, then `Interleaved F G D`.

*Proof.* The nonnegativity component is `0 ≤ D`; the two inclusion components are
the two halves of Lemma 5.2. ∎

**Theorem 5.4 (CESH stability, sharp 1-Lipschitz form).** If `0 ≤ D` and `F`,
`G` are `D`-close, then `interleavingDist F G ≤ D`.

*Proof.* Apply Theorem 4.2(2) to the witness from Theorem 5.3. ∎

Theorem 5.4 is the central result: a perturbation of size `D` in the data
produces a perturbation of at most `D` in the shape. Persistence is
**1-Lipschitz** in the sup-norm of the weight — the optimal constant, with no
multiplicative loss.

---

## 6. Vietoris–Rips stability over explicit distance matrices

We descend from abstract weights to concrete metric data, where stability
becomes a Gromov–Hausdorff/correspondence-distortion statement. Fix a finite
vertex type `α` and represent the data by a *distance matrix* `d : α → α → ℝ`
(nonnegative, symmetric, with zero diagonal; the arguments below need only the
bound on entries).

**Definition 6.1 (Diameter weight of a matrix).** For a distance matrix `d`, the
*diameter* of a simplex `σ` is
> `diamWeightOf d σ := max ( {0} ∪ { d x y : x, y ∈ σ } )`,
the largest table entry among vertices of `σ` (or `0` if there are none). This is
monotone in `σ` and defines the **Vietoris–Rips filtration** `diamFiltrationOf d`.

**Definition 6.2 (Distortion).** Two distance matrices `d₁`, `d₂` have
*distortion at most `ε`* when `|d₁ x y − d₂ x y| ≤ ε` for all `x, y`. (Over the
identity correspondence; the general definition takes an infimum over
correspondences, recovered in Future Direction 3.)

**Theorem 6.3 (The diameter is 1-Lipschitz in the metric).** If
`|d₁ x y − d₂ x y| ≤ ε` for all `x, y`, then for every simplex `σ`,
> `|diamWeightOf d₁ σ − diamWeightOf d₂ σ| ≤ ε`.

*Proof.* The diameter is a maximum over a common finite index set (the pairs of
vertices of `σ`, together with the sentinel `0`). If every entry of `d₁` is
within `ε` of the corresponding entry of `d₂`, then the maximum of the `d₁`
entries is within `ε` of the maximum of the `d₂` entries: pick the pair
achieving `diamWeightOf d₁ σ`; its `d₂`-value is at least `diamWeightOf d₁ σ − ε`
and at most `diamWeightOf d₂ σ`, giving one inequality, and the symmetric choice
gives the other. The sentinel `0` is shared and never breaks the bound. Hence the
two maxima differ by at most `ε`. ∎

This single estimate is the load-bearing fact of the whole theory; everything in
Sections 3–5 is order-theoretic bookkeeping, and Theorem 6.3 is the only place
where the geometry of the data enters.

**Theorem 6.4 (Vietoris–Rips stability, interleaving form).** If `0 ≤ ε` and
`d₁`, `d₂` have distortion at most `ε`, then
`Interleaved (diamFiltrationOf d₁) (diamFiltrationOf d₂) ε`.

*Proof.* By Theorem 6.3 the two diameter weights are `ε`-close (Definition 5.1);
apply Theorem 5.3. ∎

**Theorem 6.5 (Vietoris–Rips stability, distance form).** Under the same
hypotheses,
`interleavingDist (diamFiltrationOf d₁) (diamFiltrationOf d₂) ≤ ε`.

*Proof.* Apply Theorem 5.4 to the `ε`-closeness from Theorem 6.3, or Theorem
4.2(2) to the witness of Theorem 6.4. ∎

**Bottleneck corollary.** By the isometry theorem (Lesnick; Bauer–Lesnick), the
interleaving distance of the persistence modules equals the bottleneck distance
of their persistence diagrams. Theorem 6.5 therefore states that a distortion of
at most `ε` in the data moves every point of the persistence diagram by at most
`ε` — the canonical stability guarantee of TDA, with the sharp constant.

---

## 7. An end-to-end concrete certificate

To demonstrate that the abstract theory computes, we verify the whole chain on
two clouds of three points each, `α = {a, b, c}`. Let the first cloud have
pairwise distances summarized by a matrix `d₁` and the second by `d₂`, chosen so
that every corresponding entry differs by at most `ε`.

**Proposition 7.1 (Cloud distortion).** `|d₁ x y − d₂ x y| ≤ ε` for all
`x, y ∈ {a, b, c}` — a finite check over the (at most) nine entries.

**Proposition 7.2 (Cloud stability).** The two Vietoris–Rips filtrations are
`ε`-interleaved: `Interleaved (diamFiltrationOf d₁) (diamFiltrationOf d₂) ε`.

*Proof.* Proposition 7.1 plus Theorem 6.4. ∎

**Proposition 7.3 (Cloud interleaving bound).**
`interleavingDist (diamFiltrationOf d₁) (diamFiltrationOf d₂) ≤ ε`.

*Proof.* Proposition 7.2 plus Theorem 4.2(2) (equivalently Theorem 6.5). ∎

Every quantity in this certificate — the pairwise distances, the diameters of all
seven non-empty simplices of a 3-point cloud, the distortion, the interleaving,
and the final bound — is exact and machine-checked. The general theorem and the
specific instance agree.

---

## 8. The `inf ∅ = 0` fault line

Deliberate adversarial probing of the real-valued model exposed exactly one
weakness. The interleaving distance is defined as an infimum over the set of
admissible shifts. When two filtrations are **never** interleaved — for example
because one contains a simplex that, no matter how far the scale is shifted, the
other can never contain — the set `{δ | Interleaved F G δ}` is empty, and the
convention `inf ∅ = 0` reports the distance as `0` rather than `+∞`.

This is benign for every positive result above (all of which exhibit an explicit
finite witness and only use the upper-bound direction `interleavingDist ≤ δ`), but
it breaks the *triangle inequality* as a statement about arbitrary triples: a pair
falsely at distance `0` can violate `interleavingDist F H ≤ interleavingDist F G +
interleavingDist G H`. The remedy is purely a change of codomain — record "no
interleaving" as `⊤` — and is the first item below. Crucially, the relational
additivity (Theorem 3.2(4)) is already the full triangle inequality; only the
infimum's codomain needs upgrading.

---

## 9. Discussion and future directions

The theory presented here collapses the stability of persistence onto a single
inequality (Theorem 6.3) wrapped in order-theoretic bookkeeping (Sections 3–5).
This modularity suggests five concrete extensions.

**9.1 An `EReal` interleaving distance that is a true extended pseudometric.**
Replace the codomain by `EReal` (or `ℝ≥0∞`), defining
`interleavingEDist F G = inf { (δ : EReal) | Interleaved F G δ }`, and prove the
full pseudometric axioms — crucially
`interleavingEDist F H ≤ interleavingEDist F G + interleavingEDist G H` — using
Theorem 3.2(4) as the additive engine. The relational composition is already the
triangle inequality; the only missing ingredient is an order-complete codomain
that records "no interleaving" as `⊤` instead of `0`. *Falsifiable:* if the
triangle inequality still fails in `EReal`, an explicit three-filtration
counterexample refutes the conjecture.

**9.2 Combinatorial isometry theorem: bottleneck = interleaving.** Formalize a
finite multiset model of a persistence diagram (`Multiset (ℝ × ℝ)` over the
diagonal), define the bottleneck distance via partial matchings, prove the easy
inequality `d_B ≤ d_I` directly from `Interleaved`, and attack the converse for
diagrams arising from `diamFiltrationOf` on finite clouds. For finite clouds every
diagram has finitely many off-diagonal points, so the matching infimum is attained
and the converse becomes a finite combinatorial optimization rather than the
general measure-theoretic argument. *Falsifiable:* a finite cloud whose
matching-defined `d_B` strictly exceeds `interleavingDist`.

**9.3 The sharp factor-two Gromov–Hausdorff bound.** Define `dGH` between two
finite distance matrices as the infimum over correspondences of half the metric
distortion, and prove
`interleavingDist (diamFiltrationOf d₁) (diamFiltrationOf d₂) ≤ 2 · dGH d₁ d₂`,
the Chazal–Cohen-Steiner–Guibas–Mémoli–Oudot bound. Theorem 6.3 already gives the
per-correspondence estimate; upgrading to `dGH` requires only an infimum over the
finite set of correspondences and tracking the factor `2` from the symmetric
distortion definition. *Falsifiable:* a pair of clouds with
`interleavingDist > 2 · dGH`.

**9.4 Interleaving controls every numerical invariant (Euler/Betti stability).**
Conjecture that the Euler characteristic curve `t ↦ χ(sublevelComplex t)` and the
persistent Betti numbers are themselves stable: uniformly close filtrations
produce Euler curves agreeing except on a set of total length `≤ 2δ`. An
`Interleaved F G δ` sandwiches each sublevel complex of `F` between two sublevel
complexes of `G` at scales `t ± δ`, so any monotone-in-inclusion invariant is
trapped in a `δ`-window and inherits stability for free. *Falsifiable:* a
δ-interleaved pair whose Euler curves differ on a set longer than `2δ`.

**9.5 Functoriality / data-processing inequality.** Conjecture a contraction
principle: if `Φ` transforms weight functions and is itself 1-Lipschitz in
sup-norm (e.g. pushforward along a 1-Lipschitz vertex map, or smoothing), then
`interleavingDist (Φ F) (Φ G) ≤ interleavingDist F G`. Theorem 5.4 already shows
persistence is 1-Lipschitz in the weight, so any 1-Lipschitz preprocessing
composes to a non-expansive map on persistence — a topological data-processing
inequality that justifies denoising before computing diagrams. *Falsifiable:* a
1-Lipschitz `Φ` and a pair `F, G` with
`interleavingDist (Φ F) (Φ G) > interleavingDist F G`.

---

## 10. Conclusion

We have assembled the scattered inequalities of sublevel persistence into a single
coherent metric theory: a graded interleaving preorder, a symmetric grounded
interleaving distance, the sharp 1-Lipschitz CESH stability theorem, a
Vietoris–Rips correspondence-distortion layer reduced to one Lipschitz estimate,
and a fully explicit point-cloud certificate. All results are formally verified
and depend only on the standard foundational axioms. The recurring lesson is one
of radical simplicity: the stability of topological data analysis — the property
that lets practitioners trust shapes computed from noisy data — is, at bottom, the
statement that *the diameter of a simplex changes no faster than the distances it
is built from.*

---

## References (for orientation; this paper is self-contained)

- D. Cohen-Steiner, H. Edelsbrunner, J. Harer. *Stability of persistence
  diagrams.* Discrete & Computational Geometry, 2007.
- F. Chazal, D. Cohen-Steiner, L. Guibas, F. Mémoli, S. Oudot. *Gromov–Hausdorff
  stable signatures for shapes using persistence.* Computer Graphics Forum, 2009.
- M. Lesnick. *The theory of the interleaving distance on multidimensional
  persistence modules.* Foundations of Computational Mathematics, 2015.
- U. Bauer, M. Lesnick. *Induced matchings and the algebraic stability of
  persistence barcodes.* Journal of Computational Geometry, 2015.
- H. Edelsbrunner, J. Harer. *Computational Topology: An Introduction.* AMS, 2010.
