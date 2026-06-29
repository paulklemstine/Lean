# The Extended Interleaving Metric: A Faithful Metric Representation of Persistence Stability

## Abstract

The interleaving distance is the canonical metric of persistent homology: it
measures how far apart two multi-scale shapes-of-data are, and it underlies the
Cohen-Steiner–Edelsbrunner–Harer (CESH) stability theorem, which guarantees that
the topological summary of a data set is robust to perturbation. When the
interleaving distance is defined over the ordinary real numbers, however, a
structural defect appears: for two filtrations that admit *no* finite
interleaving, the infimum defining their distance is taken over the empty set, and
under the standard convention `sInf ∅ = 0` the distance is misreported as `0`.
This single misreading falsifies the triangle inequality and so prevents the
interleaving distance from being a metric at all.

We repair this defect by relocating the codomain from `ℝ` to the extended
non-negative reals `ℝ≥0∞`, in which `sInf ∅ = ⊤` is the *correct* value. We define
the **extended interleaving distance** `eInterleavingDist`, prove that it vanishes
on the diagonal, is symmetric, and — decisively — satisfies the triangle
inequality **unconditionally**, with no interleavability hypothesis. The proof
hinges on the absorption law of `⊤` under addition in `ℝ≥0∞` together with the
distributivity of addition over infima, neither of which has a nonemptiness
requirement. The consequence is a genuine **representation theorem**: filtrations
form an extended pseudometric space `(Filtration α, eInterleavingDist)`, exhibiting
the abstract relational interleaving preorder as a concrete metric geometry. We
recover CESH stability in sharp `1`-Lipschitz form, specialize it to the
Vietoris–Rips construction over explicit distance matrices, and certify it on an
explicit pair of three-point clouds. All results are fully formalized and depend
only on the standard foundational axioms.

**Keywords.** persistent homology, interleaving distance, bottleneck stability,
extended pseudometric space, Vietoris–Rips filtration, extended non-negative reals,
representation theorem.

---

## 1. Introduction

### 1.1 Persistence, stability, and the need for a metric

Topological data analysis extracts qualitative shape — connected components,
loops, voids, and their higher analogues — from quantitative data. The central
construction is the *filtration*: a finite weighted data set induces a nested
one-parameter family of simplicial complexes, and the features that persist across
a wide range of the scale parameter encode the intrinsic shape of the data.

For this paradigm to be scientifically meaningful, persistence must be *stable*:
small perturbations of the data must induce small changes in the inferred shape.
The quantitative form of this statement is the **Cohen-Steiner–Edelsbrunner–Harer
(CESH) stability theorem**, which bounds the change in the persistence summary by
the change in the input. To even state CESH one needs a *metric on the space of
filtrations*, and the canonical such metric is the **interleaving distance**: the
least scale shift δ under which the two filtrations contain one another.

### 1.2 The defect over `ℝ`

The interleaving relation `Interleaved F G δ` — "each filtration's sublevel family
is contained in the other's after a δ-shift" — is reflexive, symmetric, monotone
in δ, and additively transitive. These are precisely the relational shadows of the
metric axioms, and they suggest defining

> `interleavingDist F G = sInf { δ : Interleaved F G δ }`.

This is a clean definition with a fatal flaw. When `F` and `G` admit no finite
interleaving, the set `{ δ : Interleaved F G δ }` is empty. Under the Lean/Mathlib
convention `sInf ∅ = 0` in `ℝ`, the distance between two *maximally
incompatible* filtrations is reported as `0`. Since `0` is reserved for identity,
this is a category error, and it **falsifies the triangle inequality**: one can
have `interleavingDist F G` and `interleavingDist G H` both small and honest while
`interleavingDist F H` is the bogus zero, breaking
`d(F,H) ≤ d(F,G) + d(G,H)` as a faithful statement. Consequently
`interleavingDist` is not a metric, and the only theorems one can prove over `ℝ`
without extra hypotheses are nonnegativity, the upper bound by any witness,
diagonal vanishing, and symmetry — the triangle inequality is genuinely
unavailable.

### 1.3 Contribution

We resolve the defect by changing the codomain to the extended non-negative reals
`ℝ≥0∞ = [0, ∞]`. There `sInf ∅ = ⊤`, which is the mathematically correct value:
non-interleavable filtrations are infinitely far apart. We then prove that the
resulting **extended interleaving distance** satisfies *all* the (pseudo)metric
axioms unconditionally, yielding:

1. `eInterleavingDist` — the `ℝ≥0∞`-valued interleaving distance (Definition 3.1);
2. `eInterleavingDist_le` — every interleaving witness bounds the distance
   (Lemma 3.2);
3. `eInterleavingDist_self`, `eInterleavingDist_comm` — diagonal vanishing and
   symmetry (Lemmas 3.3, 3.4);
4. `eInterleavingDist_triangle` — the **unconditional** triangle inequality
   (Theorem 3.5);
5. `interleavingPseudoEMetric` — the representation theorem: filtrations form an
   extended pseudometric space (Theorem 4.1);
6. `eInterleavingDist_le_supDist` — CESH stability in extended `1`-Lipschitz form
   (Theorem 5.1);
7. `vr_eStability`, `cloud_eInterleavingDist_le` — the Vietoris–Rips and concrete
   point-cloud specializations (Theorems 6.1, 7.1).

The conceptual content is a *duality*: the metric triangle inequality is the
shadow of the relational composability of interleavings, and the bridge between
them is exactly the `ℝ≥0∞`-algebra (`ENNReal.iInf_add`, `ENNReal.add_iInf`, and
the absorption of `⊤`) that the real `sInf` lacked.

---

## 2. Background: filtrations and interleaving

We work over an arbitrary vertex type `α`.

### 2.1 Abstract simplicial complexes and filtrations

**Definition 2.1 (Abstract simplicial complex).** An *abstract simplicial complex*
(ASC) on `α` is a downward-closed family of finite subsets of `α` containing the
empty set: a set `faces ⊆ Finset α` with `∅ ∈ faces` and, whenever `σ ∈ faces` and
`τ ⊆ σ`, also `τ ∈ faces`.

**Definition 2.2 (Filtration).** A *filtration* on `α` is a weight function
`weight : Finset α → ℝ` on finite subsets ("simplices") subject to two conditions:

- *Grounding:* `weight ∅ ≤ 0`;
- *Monotonicity:* `σ ⊆ τ ⇒ weight σ ≤ weight τ`.

The weight of a simplex is the scale at which it is born; monotonicity is precisely
what makes the sublevel sets downward closed.

**Definition 2.3 (Sublevel family).** For a filtration `F` and a scale `t ∈ ℝ`, the
*sublevel faces* are `F.sublevelFaces t = { σ : F.weight σ ≤ t }`. For `t ≥ 0`,
`sublevelFaces t` is the face set of an ASC, the *sublevel complex*. The family is
nested in the scale parameter:

> **(sublevel monotonicity)** if `t₁ ≤ t₂` then `F.sublevelFaces t₁ ⊆ F.sublevelFaces t₂`.

This is immediate: `weight σ ≤ t₁ ≤ t₂`.

### 2.2 The interleaving relation

**Definition 2.4 (δ-interleaving).** Two filtrations `F, G` are *δ-interleaved*
(written `Interleaved F G δ`), for a shift `δ ∈ ℝ`, when

> `0 ≤ δ`, and for all `t`:  `F.sublevelFaces t ⊆ G.sublevelFaces (t + δ)`
> and  `G.sublevelFaces t ⊆ F.sublevelFaces (t + δ)`.

The interleaving relation is the relational skeleton of the metric. It satisfies
four structural properties, each proved by direct manipulation of the inclusions:

- **Reflexivity.** `Interleaved F F 0`, since `F.sublevelFaces t ⊆ F.sublevelFaces (t+0)`.
- **Symmetry.** `Interleaved F G δ ⇒ Interleaved G F δ`, by swapping the two
  inclusion clauses.
- **Monotonicity in δ.** `Interleaved F G δ` and `δ ≤ δ′` imply `Interleaved F G δ′`,
  by enlarging each shift via sublevel monotonicity.
- **Additive transitivity.** `Interleaved F G δ` and `Interleaved G H δ′` imply
  `Interleaved F H (δ + δ′)`, by chaining the inclusions; the shifts add because
  `t + (δ + δ′) = (t + δ) + δ′`.

The last property is the relational triangle inequality and is the engine of
everything below.

### 2.3 The real-valued distance and its limits

Over `ℝ`, one defines `interleavingDist F G = sInf { δ : Interleaved F G δ }` and
proves: nonnegativity (`interleavingDist_nonneg`), the witness upper bound
(`interleavingDist_le`), diagonal vanishing (`interleavingDist_self`), and symmetry
(`interleavingDist_comm`). The triangle inequality is **not** provable
unconditionally because `sInf ∅ = 0` in `ℝ` corrupts the never-interleaved case.
This is the defect we now repair.

---

## 3. The extended interleaving distance

We move to `ℝ≥0∞`, the type of extended non-negative reals, which is a complete
lattice with `sInf ∅ = ⊤`. The coercion `ENNReal.ofReal : ℝ → ℝ≥0∞` sends `δ` to
`max(δ, 0)` viewed in `ℝ≥0∞`; it is additive on non-negative arguments:
`ENNReal.ofReal (a + b) = ENNReal.ofReal a + ENNReal.ofReal b` when `0 ≤ a, 0 ≤ b`.

**Definition 3.1 (Extended interleaving distance).** For filtrations `F, G`,

> `eInterleavingDist F G  :=  ⨅ (δ : { x : ℝ // Interleaved F G x }), ENNReal.ofReal (δ : ℝ).`

The infimum ranges over the *subtype* of admissible shifts. When that subtype is
empty (no finite interleaving exists), the infimum over the empty index is `⊤` — the
correct value, in contrast to the real `sInf ∅ = 0`.

**Lemma 3.2 (Witness upper bound, `eInterleavingDist_le`).** If `Interleaved F G δ`
then `eInterleavingDist F G ≤ ENNReal.ofReal δ`.

*Proof sketch.* The pair `⟨δ, h⟩` is an element of the index subtype, so the
generic bound `iInf_le` applied to the function `x ↦ ENNReal.ofReal (x : ℝ)`
yields the inequality directly. ∎

**Lemma 3.3 (Diagonal vanishing, `eInterleavingDist_self`).**
`eInterleavingDist F F = 0`.

*Proof sketch.* The reverse inequality `0 ≤ ·` is automatic in `ℝ≥0∞`. For the
forward inequality, apply Lemma 3.2 with the reflexive witness `Interleaved F F 0`;
this gives `eInterleavingDist F F ≤ ENNReal.ofReal 0 = 0`. ∎

**Lemma 3.4 (Symmetry, `eInterleavingDist_comm`).**
`eInterleavingDist F G = eInterleavingDist G F`.

*Proof sketch.* Antisymmetry of `≤`. For each direction, take an arbitrary
admissible shift `δ` for one ordered pair; symmetry of the relation
(`Interleaved_symm`) turns it into an admissible shift for the other pair with the
same value `ENNReal.ofReal δ`, and Lemma 3.2 bounds the opposite distance.
Quantifying over all shifts with `le_iInf` closes both directions. ∎

**Theorem 3.5 (Unconditional triangle inequality, `eInterleavingDist_triangle`).**
For all filtrations `F, G, H`,

> `eInterleavingDist F H ≤ eInterleavingDist F G + eInterleavingDist G H`.

*Proof sketch.* Expand all three distances as infima over their respective shift
subtypes. Using the `ℝ≥0∞` distributivity laws `ENNReal.iInf_add` and
`ENNReal.add_iInf` — which hold with **no** nonemptiness hypothesis because `⊤`
absorbs `+` — rewrite the right-hand sum as a double infimum:

> `eInterleavingDist F G + eInterleavingDist G H = ⨅ a, ⨅ b, (ENNReal.ofReal a + ENNReal.ofReal b)`,

where `a` ranges over `F,G`-witnesses and `b` over `G,H`-witnesses. It therefore
suffices, by `le_iInf` twice, to bound `eInterleavingDist F H` by each summand. For
fixed witnesses `a, b` (both nonnegative as the first component of `Interleaved`),
additivity of `ENNReal.ofReal` gives

> `ENNReal.ofReal a + ENNReal.ofReal b = ENNReal.ofReal (a + b)`,

and additive transitivity `Interleaved_trans` makes `a + b` an `F,H`-interleaving
witness. Lemma 3.2 then yields `eInterleavingDist F H ≤ ENNReal.ofReal (a + b)`, as
required. The empty-witness case — fatal over `ℝ` — is handled automatically:
if either summand's index subtype is empty, that summand is `⊤`, the right side is
`⊤`, and the inequality is trivial. ∎

**Remark (why `ℝ≥0∞` and not `ℝ`).** The entire repair is localized in two algebraic
facts. First, `sInf ∅ = ⊤` is *correct* for non-interleavable filtrations, whereas
`sInf ∅ = 0` is *wrong*. Second, the distributivity of `+` over `⨅` holds
unconditionally in `ℝ≥0∞` precisely because `⊤` absorbs addition; over `ℝ` the
analogous distributivity requires the infima to be over nonempty, bounded sets.
The triangle inequality is thus not "patched" — it becomes *structurally true*.

---

## 4. The representation theorem

**Theorem 4.1 (Representation, `interleavingPseudoEMetric`).** The function
`eInterleavingDist` endows `Filtration α` with the structure of an extended
pseudometric space:

> `interleavingPseudoEMetric : PseudoEMetricSpace (Filtration α)` with
> `edist = eInterleavingDist`.

*Proof sketch.* The three required axioms `edist_self`, `edist_comm`, and
`edist_triangle` are exactly Lemmas 3.3, 3.4 and Theorem 3.5. The remaining
uniformity and topology fields are auto-generated from `edist` by the default
`PseudoEMetricSpace` construction. ∎

**Interpretation.** This is the conceptual payoff. The interleaving relation —
defined purely set-theoretically as a family of inclusions — is *faithfully
represented* as a metric geometry: filtrations become points of a space, and the
extended interleaving distance measures their separation. The metric axiom
(triangle) is the shadow of the relational axiom (additive transitivity), and the
representation is faithful in the sense that the metric exactly encodes the
relational preorder graded by δ. The space is a *pseudo*metric: distinct
filtrations may have distance `0` if they share identical sublevel families at
every scale (this kernel is studied in Future Direction 1). It is *extended*:
distances may be `⊤`, the honest value for incompatible shapes.

---

## 5. CESH stability in extended form

**Definition 5.1 (Uniform weight closeness).** Filtrations `F, G` are *D-close*
(`WeightCloseBy F G D`) when `|F.weight σ − G.weight σ| ≤ D` for every simplex `σ`.

The underlying real theory establishes that `D`-closeness produces a
`D`-interleaving: `stability_supDist F G hD h : Interleaved F G D` (for `0 ≤ D`),
obtained by feeding the two-sided weight bound into the sublevel-inclusion lemma in
each direction.

**Theorem 5.1 (Extended CESH stability, `eInterleavingDist_le_supDist`).** If
`0 ≤ D` and `WeightCloseBy F G D`, then

> `eInterleavingDist F G ≤ ENNReal.ofReal D`.

*Proof sketch.* `stability_supDist` yields a `D`-interleaving witness; Lemma 3.2
converts it to the `ENNReal.ofReal D` bound. ∎

This is persistence stability in its sharpest, exception-free form: the extended
interleaving distance is `1`-Lipschitz in the sup-norm distance of the weight
functions, now valid as a genuine metric statement.

---

## 6. Vietoris–Rips stability over explicit distance matrices

We instantiate the theory on Vietoris–Rips filtrations built directly from a bare
distance matrix `d : α → α → ℝ`, requiring **no** metric-space structure on `α`.

**Definition 6.1 (Diameter weight, `diamWeightOf`).** For `d : α → α → ℝ` and a
simplex `σ`,

> `diamWeightOf d σ = sup' { 0 } ∪ { d x y : (x,y) ∈ σ × σ }`,

the largest pairwise value of `d` over the vertices of `σ`, with `0` adjoined so
the empty simplex and singletons receive weight `0`. It is nonnegative, vanishes on
`∅`, and is monotone under inclusion, hence packages as a filtration
`diamFiltrationOf d`.

**Lemma 6.2 (Diameter is `1`-Lipschitz in the matrix, `diamWeightOf_dist_le`).**
If `0 ≤ ε` and `|d₁ x y − d₂ x y| ≤ ε` for all `x, y ∈ σ`, then

> `|diamWeightOf d₁ σ − diamWeightOf d₂ σ| ≤ ε`.

*Proof sketch.* For each direction of the absolute value, bound every candidate
pairwise distance of one matrix by the corresponding distance of the other plus
`ε`, then by the supremum plus `ε`; conclude with `sup'_le` and `abs_sub_le_iff`.
This single estimate is the entire content of VR stability. ∎

**Theorem 6.1 (Extended VR stability, `vr_eStability`).** If `0 ≤ ε` and
`|d₁ x y − d₂ x y| ≤ ε` for all `x, y`, then

> `eInterleavingDist (diamFiltrationOf d₁) (diamFiltrationOf d₂) ≤ ENNReal.ofReal ε`.

*Proof sketch.* Lemma 6.2 across all simplices gives `WeightCloseBy
(diamFiltrationOf d₁) (diamFiltrationOf d₂) ε`, hence (via `stability_supDist`) an
`ε`-interleaving `vr_stability_interleaved`; Lemma 3.2 finishes. ∎

Thus Vietoris–Rips persistence is, in the extended metric, a *short map*
(`1`-Lipschitz) from the space of distance matrices to the space of filtrations —
the precise category-theoretic content of "persistent homology is stable."

---

## 7. A concrete certificate

To exhibit the theory end-to-end we certify two explicit three-point clouds on
`Fin 3`.

**Definition 7.1.** `cloud₁ i j = 0` if `i = j` else `1` (a unit-distance
triangle); `cloud₂ i j = 0` if `i = j` else `11/10` (the same triangle inflated to
side `1.1`).

**Lemma 7.2 (`cloud_distortion`).** `|cloud₁ i j − cloud₂ i j| ≤ 1/10` for all
`i, j : Fin 3`. (Finite case check: each entry differs by `0` or `1/10`.)

**Theorem 7.1 (`cloud_eInterleavingDist_le`).**

> `eInterleavingDist (diamFiltrationOf cloud₁) (diamFiltrationOf cloud₂) ≤ ENNReal.ofReal (1/10)`.

*Proof sketch.* Apply Theorem 6.1 (`vr_eStability`) to the `1/10` distortion bound
of Lemma 7.2. ∎

This is a fully verified instance of "small change in data ⇒ small change in
shape," living inside the genuine extended pseudometric geometry.

---

## 8. Algorithms

The theory is constructive enough to support direct numerical realization. We
record three algorithms used in the accompanying demonstrations.

### 8.1 Diameter-weight filtration from a distance matrix

Given a finite point set with distance matrix `d`, compute, for every nonempty
subset, its diameter (maximum pairwise distance), and tabulate the birth scales of
all simplices. Complexity: `O(2^n · n²)` for `n` points (every subset, every pair).
For the small clouds of Section 7 this is trivial; for larger data one restricts to
simplices up to a fixed dimension.

### 8.2 Interleaving certificate verification

Given two filtrations (weight tables) and a candidate shift `δ`, verify the
δ-interleaving inclusions on a finite scale grid by checking
`weight_F(σ) ≤ t ⇒ weight_G(σ) ≤ t + δ` and symmetrically. Because both weight
functions are monotone, it suffices to check the inclusions at the finitely many
birth scales. Complexity: `O(S · G)` for `S` simplices and `G` grid points.

### 8.3 Extended interleaving distance estimate

For two diameter filtrations from matrices `d₁, d₂`, the extended interleaving
distance is bounded above by `‖d₁ − d₂‖_∞` (Theorem 6.1). The estimator returns
`ENNReal.ofReal(max_{x,y} |d₁(x,y) − d₂(x,y)|)`, an honest, always-valid upper
bound; when the two filtrations are genuinely non-interleavable the true distance
is `⊤`, which the estimator never spuriously reports as `0` — the very pathology
the extended codomain eliminates.

---

## 9. Applications

- **Robust shape comparison.** The representation theorem makes the full toolkit of
  metric topology available for filtrations: nearest-neighbor search, clustering,
  and averaging of shapes can now be phrased in a genuine (extended) metric space.
- **Noise certification.** Theorem 6.1 turns a measurement-error budget `ε` on the
  distance matrix into a certified bound `ENNReal.ofReal ε` on the change in
  persistent shape — a guarantee usable in safety-critical pipelines.
- **Honest infinity.** In applications comparing data sets of structurally
  different shape (e.g. a connected sample vs. a sample with a topological
  obstruction), the extended distance correctly returns `⊤` rather than masking the
  incompatibility as `0`, preventing false "these are identical" conclusions.

---

## 10. Discussion

The episode is a case study in *codomain selection*. The interleaving distance was
not wrong as a *formula*; it was wrong as a *real number*, because the real line has
no honest value for "the distance between incompatible objects." The extended
non-negative reals supply exactly one new element, `⊤`, and that single element
simultaneously (i) gives the empty infimum its correct value and (ii) makes the
distributivity of `+` over `⨅` hold unconditionally, which is what powers the
triangle inequality. No hypotheses were added to the theorems; the theory became
*more* general and *more* true at once.

The duality at the heart of the result — metric triangle inequality as the shadow
of relational additive transitivity — is, we believe, the right way to understand
persistence stability: the relational preorder and the metric geometry are two
faces of one object, and `ℝ≥0∞` is the arena in which the translation between them
is faithful.

---

## 11. Future directions

**1. The kernel of the pseudometric.** Conjecture: `eInterleavingDist F G = 0` iff
`F` and `G` have identical sublevel families at every scale. One direction is
immediate from Lemma 3.2; the converse needs a limiting argument squeezing the
shift to `0`, for which `ℝ≥0∞` supplies the requisite `iInf`-continuity machinery.
The metric quotient would then be a genuine `EMetricSpace` of persistence modules
up to isomorphism.

**2. The CESH isometry (lower bound).** We have the upper bound (Theorem 5.1); the
deep half of CESH is the matching lower bound via the bottleneck distance of
persistence diagrams: `bottleneck(Dgm F, Dgm G) = eInterleavingDist F G`. The upper
bound is monotonicity bookkeeping; the lower bound is a combinatorial matching
(Hall's theorem / min-cost assignment) — the two halves are dual optimization
problems, sup-of-shifts versus min-of-matchings.

**3. Completeness.** Conjecture: `(Filtration α, eInterleavingDist)` is a complete
extended pseudometric space; Cauchy sequences of filtrations converge to the
filtration of the pointwise weight limit. Cauchyness forces the weights to be
uniformly Cauchy in sup-norm (Theorem 5.1 run backwards), and pointwise limits of
monotone functions are monotone, so the limit is a legal filtration.

**4. Stability of the Euler characteristic curve.** Define `t ↦ χ(F.sublevelComplex
t)` and conjecture it is stable: a δ-interleaving forces the curves to interleave
horizontally by δ, so any translation-invariant `1`-Lipschitz functional (its `L¹`
distance, total variation) inherits a stability bound from the metric — invariant
stability as a corollary of metric stability.

**5. Gromov–Hausdorff functoriality.** Promote Theorem 6.1 to a `1`-Lipschitz map
between metric spaces and show it descends to a short map from the Gromov–Hausdorff
space of finite metric spaces into the interleaving-quotient space — the precise
categorical form of "persistent homology is stable."

---

## 12. Conclusion

By relocating the interleaving distance from `ℝ` to `ℝ≥0∞`, we converted a
quantity that merely resembled a metric into one that *is* a metric, with no
exceptions: the triangle inequality holds for all filtrations, and the space of
filtrations becomes a genuine extended pseudometric space. The repair is local —
one new value `⊤` and the absorption law it satisfies — but its consequence is
global: a faithful metric representation of the relational theory of persistence
stability, with CESH `1`-Lipschitz stability, Vietoris–Rips functoriality, and an
explicit certificate all riding along. All results are formalized with no `sorry`
and depend only on the standard foundational axioms `propext`, `Classical.choice`,
and `Quot.sound`.
