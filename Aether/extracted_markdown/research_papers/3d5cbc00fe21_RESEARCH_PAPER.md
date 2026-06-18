# The Boltzmann Bridge: A Verified Filtration Calculus for Persistent Topology

## Abstract

We develop a self-contained, fully formalized calculus of one-parameter
filtrations of abstract simplicial complexes, aimed at the foundations of
persistent homology in arbitrary dimension. From a single structural primitive —
a *monotone weight* on finite simplices — we derive the sublevel-set filtration,
prove that every sublevel set is a genuine abstract simplicial complex, and prove
that the family is nested in the scale parameter. We instantiate this abstraction
with the *diameter weight* to recover the Vietoris–Rips filtration and prove the
identification `σ ∈ VR(ε) ⇔ diamWeight σ ≤ ε`, which pins down the birth time of
every simplex. We then establish the two structural pillars that make persistent
homology a robust invariant: (i) **functoriality**, namely that complex
containment is a preorder and the sublevel complexes assemble into a one-parameter
diagram of inclusions (the combinatorial skeleton of a persistence module); and
(ii) **stability**, namely that uniformly close weights yield interleaved sublevel
families, with interleavings composing additively — the algebraic core of the
Cohen–Steiner–Edelsbrunner–Harer stability theorem. We prove the combinatorial
Nerve interleaving `Čech(ε) ⊆ VR(2ε) ⊆ Čech(2ε)` relating the cheap Vietoris–Rips
model to the topologically faithful Čech model, isolating the triangle inequality
as the sole metric input and the constant `2` as the exact approximation slack.
Finally, we establish the Euler–Poincaré bridge `eulerChar = Σ (−1)^k f_k`
relating the combinatorial Euler characteristic to the alternating f-vector for any
finite complex, and specialize it to prove that the full simplex on `n` vertices
has Euler characteristic `1`. We close with a thermodynamic reading — the
"Boltzmann Bridge" — in which the diameter weight is replaced by a log-partition
weight whose zero-temperature limit recovers the Vietoris–Rips filtration.

---

## 1. Introduction

Persistent homology is the central computational tool of topological data
analysis. Given a finite metric data set, one constructs a one-parameter nested
family of simplicial complexes — a **filtration** — and tracks the appearance and
disappearance of topological features (connected components, loops, voids) across
the parameter. Features that persist over a wide range of scales are deemed
signal; transient features are deemed noise. The two theorems that make this
program scientifically credible are the **stability theorem** (small perturbations
of the input produce small changes of the output) and the **Nerve Lemma** (the
combinatorial model faithfully captures the topology of the underlying space).

This paper formalizes the algebraic and combinatorial core of both. Our guiding
methodological principle is *abstraction to the minimal hypothesis*: rather than
study the Vietoris–Rips filtration directly, we isolate the single property it uses
— monotonicity of a weight function — and develop the entire filtration calculus
at that level of generality. The specific geometric and combinatorial theorems then
follow as instantiations or short corollaries.

Throughout, `α` is a vertex type. A **finite simplex** (or **face**) is a term
`σ : Finset α`. We work over the reals for scale parameters and over the integers
for Euler characteristics.

---

## 2. Abstract simplicial complexes and filtrations

### 2.1 Abstract simplicial complexes

**Definition 2.1 (ASC).** An *abstract simplicial complex* on `α` is a family of
faces `K.faces ⊆ Finset α` that contains the empty face and is downward closed:

> `∅ ∈ K.faces`, and for all `σ, τ`, if `σ ∈ K.faces` and `τ ⊆ σ` then
> `τ ∈ K.faces`.

**Definition 2.2 (Containment).** For complexes `K, L` we write `K ⊑ L`
(`ASC.Sub K L`) to mean `K.faces ⊆ L.faces`.

### 2.2 Monotone weights and sublevel filtrations

**Definition 2.3 (Filtration).** A *filtration* on `α` is a weight function
`F.weight : Finset α → ℝ` satisfying

> `F.weight ∅ ≤ 0` (the empty face is born at or before scale `0`), and
> monotonicity: `σ ⊆ τ ⇒ F.weight σ ≤ F.weight τ`.

The weight of a simplex is interpreted as its **birth time**.

**Definition 2.4 (Sublevel faces).** For a filtration `F` and scale `t : ℝ`,

> `F.sublevelFaces t := { σ | F.weight σ ≤ t }`.

**Theorem 2.5 (Sublevel sets are complexes; `sublevelComplex`).** For `t ≥ 0`, the
family `F.sublevelFaces t` is an abstract simplicial complex.

*Proof sketch.* The empty face is born by `t` since `F.weight ∅ ≤ 0 ≤ t`. For
downward closure, if `τ ⊆ σ` and `F.weight σ ≤ t`, then by monotonicity
`F.weight τ ≤ F.weight σ ≤ t`. ∎

**Theorem 2.6 (Filtration monotonicity; `sublevel_mono`).** If `t₁ ≤ t₂` then
`F.sublevelFaces t₁ ⊆ F.sublevelFaces t₂`.

*Proof sketch.* If `F.weight σ ≤ t₁ ≤ t₂` then `F.weight σ ≤ t₂` by transitivity.
∎

These two one-line proofs are the entire engine: any monotone weight yields a
nested family of genuine complexes — a filtration in the topological sense — at no
further cost.

---

## 3. The Vietoris–Rips filtration

Let `α` carry a pseudometric (`PseudoMetricSpace α`), with distance `dist`.

**Definition 3.1 (Diameter weight).** For `σ : Finset α`,

> `diamWeight σ := sup' ( {0} ∪ { dist x y : (x,y) ∈ σ × σ } )`,

the supremum of `0` together with all internal pairwise distances. The inclusion of
`0` makes the supremum well-defined on the empty face and on singletons (which have
diameter `0`).

**Theorem 3.2 (Diameter is a filtration; `diamFiltration`).** `diamWeight` is a
filtration: `diamWeight ∅ = 0 ≤ 0`, and `σ ⊆ τ ⇒ diamWeight σ ≤ diamWeight τ`.

*Proof sketch.* The empty case reduces to `sup' {0} = 0`. For monotonicity, every
element of the indexing set for `σ` is an element of the indexing set for `τ`
(because `σ × σ ⊆ τ × τ`), so the supremum over the larger set dominates; this is a
single application of `Finset.sup'_le` against `Finset.le_sup'`. ∎

**Definition 3.3 (Vietoris–Rips faces).** For `ε : ℝ`,

> `VRfaces ε := { σ | ∀ x ∈ σ, ∀ y ∈ σ, dist x y ≤ ε }`.

**Theorem 3.4 (VR = sublevel of diameter; `vr_mem_iff_diam_le`).** For `ε ≥ 0`,

> `σ ∈ VRfaces ε ⇔ diamWeight σ ≤ ε`.

*Proof sketch.* By `Finset.sup'_le_iff`, `diamWeight σ ≤ ε` unfolds to `0 ≤ ε`
together with the condition that every pairwise distance is `≤ ε`, which is exactly
membership in `VRfaces ε`. ∎

This is the central bridge between the *metric* description (pairwise distances) and
the *combinatorial* description (a single sublevel inequality). It identifies the
geometric Vietoris–Rips filtration with the abstract sublevel filtration of
`diamFiltration`, and it makes `diamWeight` the canonical birth-time function.

**Corollary 3.5 (VR monotonicity; `vr_mono`).** If `ε₁ ≤ ε₂` then
`VRfaces ε₁ ⊆ VRfaces ε₂`.

**Corollary 3.6 (Singletons; `vr_singleton_mem`).** For `ε ≥ 0` and `x : α`,
`{x} ∈ VRfaces ε`, since the only internal pair is `(x,x)` with `dist x x = 0`.

---

## 4. Functoriality: the persistence module skeleton

A filtration is not merely a nested family of sets; after applying homology it
becomes a **persistence module**, a functor from the poset `(ℝ, ≤)` to vector
spaces. The combinatorial skeleton of this structure is the diagram of inclusions
between sublevel complexes, which we record exactly.

**Theorem 4.1 (Containment is a preorder; `Sub_refl`, `Sub_trans`).** `ASC.Sub` is
reflexive (`K ⊑ K`) and transitive (`K ⊑ L`, `L ⊑ M ⇒ K ⊑ M`).

*Proof sketch.* Reflexivity and transitivity of `⊆` on the face sets. ∎

**Theorem 4.2 (Connecting maps; `sublevelComplex_sub`).** For a fixed filtration
`F` and `0 ≤ t₁ ≤ t₂`, `F.sublevelComplex t₁ ⊑ F.sublevelComplex t₂`.

*Proof sketch.* The face sets are the sublevel sets, so this is `sublevel_mono`. ∎

**Theorem 4.3 (Lattice compatibility; `sublevelFaces_min`, `VRfaces_min`).**
The sublevel set at the minimum of two scales is the intersection of the two
sublevel sets:

> `F.sublevelFaces (min t₁ t₂) = F.sublevelFaces t₁ ∩ F.sublevelFaces t₂`,

and likewise `VRfaces (min ε₁ ε₂) = VRfaces ε₁ ∩ VRfaces ε₂`.

*Proof sketch.* `weight σ ≤ min t₁ t₂ ⇔ weight σ ≤ t₁ ∧ weight σ ≤ t₂` by
`le_min_iff`; for VR the analogous distribution of `min` over the universally
quantified pairwise condition. ∎

These say the filtration is a *lax-monoidal* / lattice-respecting diagram: the
sublevel functor sends meets of scales to intersections of complexes.

---

## 5. Stability and interleaving

Robustness is the property that small input perturbations cause small output
perturbations. The precise algebraic form is *δ-interleaving*.

**Theorem 5.1 (δ-interleaving; `stability_interleaving`).** Let `F, G` be
filtrations with `G.weight σ ≤ F.weight σ + δ` for all `σ`. Then for every `t`,

> `F.sublevelFaces t ⊆ G.sublevelFaces (t + δ)`.

*Proof sketch.* If `F.weight σ ≤ t`, then `G.weight σ ≤ F.weight σ + δ ≤ t + δ`. ∎

**Theorem 5.2 (Additivity / triangle inequality; `stability_compose`).** Under
`G.weight ≤ F.weight + δ` and `H.weight ≤ G.weight + δ′`,

> `F.sublevelFaces t ⊆ H.sublevelFaces (t + (δ + δ′))`.

*Proof sketch.* Compose the two interleavings (Theorem 5.1) and reassociate the
shift. ∎

**Theorem 5.3 (Two-sided stability; `stability_two_sided`).** If
`|F.weight σ − G.weight σ| ≤ δ` for all `σ`, then for every `t`,

> `F.sublevelFaces t ⊆ G.sublevelFaces (t + δ)` *and*
> `G.sublevelFaces t ⊆ F.sublevelFaces (t + δ)`.

*Proof sketch.* Each direction is Theorem 5.1 after extracting the two-sided bound
from `abs_le`. ∎

Theorems 5.2 and 5.3 are precisely the axioms of a (pseudo)metric — the
**interleaving distance** on the space of filtrations. Theorem 5.2 is its triangle
inequality. Applied to the diameter filtration, where perturbing each pairwise
distance by at most `δ` changes `diamWeight` by at most `δ` (because the supremum
operation `Finset.sup'` is 1-Lipschitz in its argument function), these theorems
deliver the working form of the stability theorem: jittering the data by `δ` moves
the entire persistence diagram by at most `δ`.

---

## 6. The combinatorial Nerve interleaving

The Vietoris–Rips complex (pairwise distances only) is cheap to compute but is an
approximation. The **Čech complex** (the nerve of the closed-ball cover) is
topologically faithful by the Nerve Lemma but expensive. We quantify the
approximation exactly.

**Definition 6.1 (Čech faces).** For `ε : ℝ`,

> `CechFaces ε := { σ | ∃ c : α, ∀ x ∈ σ, dist x c ≤ ε }`,

the simplices all of whose vertices lie in a common closed ball of radius `ε`.

**Theorem 6.2 (Čech is a complex; `cech_down_closed`).** If `σ ∈ CechFaces ε` and
`τ ⊆ σ` then `τ ∈ CechFaces ε`.

*Proof sketch.* The center `c` covering `σ` also covers every subface, since the
covering condition `∀ x ∈ σ, dist x c ≤ ε` is pointwise. ∎

**Theorem 6.3 (Čech monotonicity; `cech_mono`).** If `ε₁ ≤ ε₂` then
`CechFaces ε₁ ⊆ CechFaces ε₂`.

*Proof sketch.* The same center works at the larger radius: `dist x c ≤ ε₁ ≤ ε₂`.
∎

**Theorem 6.4 (Forward inclusion; `cech_subset_vr`).** `CechFaces ε ⊆ VRfaces (2ε)`.

*Proof sketch.* If all vertices of `σ` lie within `ε` of a common center `c`, then
for any `x, y ∈ σ`,
`dist x y ≤ dist x c + dist c y = dist x c + dist y c ≤ ε + ε = 2ε`,
the single use of the triangle inequality (with `dist_comm` to align the terms). ∎

**Theorem 6.5 (Reverse inclusion; `vr_subset_cech`).** If `σ` is nonempty and
`σ ∈ VRfaces ε`, then `σ ∈ CechFaces ε` (no scale factor lost).

*Proof sketch.* Pick any vertex `x₀ ∈ σ` as the center. For every `x ∈ σ`, VR
membership gives `dist x x₀ ≤ ε`. Nonemptiness is essential — it supplies the
center. ∎

**Theorem 6.6 (Nerve interleaving; `nerve_interleaving`).**

> `CechFaces ε ⊆ VRfaces (2ε)`, and every nonempty `σ ∈ VRfaces (2ε)` lies in
> `CechFaces (2ε)`.

Together these are the finite, combinatorial avatar of the classical sandwich
`Čech(ε) ⊆ VR(2ε) ⊆ Čech(2ε)`.

*Proof sketch.* Chain Theorem 6.4 with Theorem 6.5 applied at scale `2ε`. ∎

The structural lesson: the interleaving constant `2` enters at exactly one place —
the triangle inequality in Theorem 6.4 — and nowhere else. Everything else is
pointwise `∀ x ∈ σ` bookkeeping that the filtration framework makes routine.

---

## 7. The Euler–Poincaré / f-vector bridge

We turn from constructing shapes to measuring them.

**Definition 7.1 (f-vector).** For a finite complex `K` (a `Finset` of faces) the
*f-vector* records the number of faces of each dimension:

> `fVector K k := #{ σ ∈ K : σ.card = k + 1 }`,

so `fVector K k` counts the `k`-dimensional faces (those with `k+1` vertices).

**Definition 7.2 (Combinatorial Euler characteristic).**

> `eulerCharFin K := Σ_{σ ∈ K, σ ≠ ∅} (−1)^(σ.card − 1)`,

the signed count of nonempty faces, each weighted by `(−1)` raised to its dimension.

**Theorem 7.3 (Euler–Poincaré bridge; `eulerChar_eq_alt_fVector`).** For any finite
complex with a dimension bound `n`,

> `eulerCharFin K = Σ_{k=1}^{n} (−1)^(k−1) · fVector K (k−1)`,

i.e. the Euler characteristic equals the alternating sum of the f-vector.

*Proof sketch.* Partition the nonempty faces by cardinality (dimension + 1) and
apply fibrewise regrouping (`Finset.sum_fiberwise_of_maps_to`): the sign
`(−1)^(card−1)` is constant on each fiber, and the size of the fiber over `k` is
`fVector K (k−1)`. The two summations are therefore equal. Crucially this holds for
*any* finite complex; the cancellation that produces a small final value is a
separate, complex-specific phenomenon. ∎

**Theorem 7.4 (f-vector of the full simplex; `fVector_full_simplex`).** For the full
simplex on `n` vertices (all subsets of an `n`-element vertex set), the number of
`k`-faces is `C(n, k+1)`; equivalently the count of faces with exactly `k` vertices
is `C(n, k)`.

*Proof sketch.* The `k`-vertex faces are exactly the `k`-element subsets of the
`n`-element vertex set, of which there are `C(n,k)` by definition of the binomial
coefficient (`Finset.card_powersetCard`). ∎

**Theorem 7.5 (Euler characteristic of the full simplex;
`euler_char_full_simplex` / `eulerChar_full_simplex`).** For `n ≥ 1`,

> `Σ_{k=1}^{n} (−1)^(k−1) · C(n,k) = 1`.

*Proof sketch.* Start from the alternating binomial identity
`Σ_{m=0}^{n} (−1)^m C(n,m) = 0` (the alternating row sum of Pascal's triangle, valid
for `n ≥ 1`; in Mathlib, `Int.alternating_sum_range_choose`). Split off the `m = 0`
term (`C(n,0) = 1`) and reindex `m = k`, multiplying through by `−1`:
`Σ_{k=1}^{n} (−1)^(k−1) C(n,k) = C(n,0) = 1`. ∎

Combining Theorems 7.3–7.5, the bare arithmetic identity `= 1` is upgraded to a
genuine topological statement: the full simplex, viewed as a simplicial complex, has
Euler characteristic `1`. This is the combinatorial shadow of the **contractibility**
of a simplex — a solid simplex deformation-retracts to a point, and a point has
Euler characteristic `1`.

---

## 8. Two orthogonal ledgers

The development is organized by two independent invariants of the data:

- **Metric ledger.** Distances control birth times (`diamWeight`, Theorem 3.4),
  robustness (the interleaving distance, Theorems 5.1–5.3), and the approximation
  slack of the cheap complex (the factor `2`, Theorem 6.6). Every metric fact
  reduces to the triangle inequality.

- **Combinatorial ledger.** Face counts control the Euler characteristic (the
  f-vector, Theorem 7.3) and its cancellations (the alternating binomial identity,
  Theorem 7.5).

The `Filtration` abstraction decouples these completely: the stability theorems
never mention dimension or counts, and the Euler–Poincaré bridge never mentions
distance. They meet only in the final analysis of a dataset.

---

## 9. Algorithms

**Algorithm A — Birth time / diameter weight.** Given a finite point set `σ`,
compute `diamWeight σ` by scanning all ordered pairs and taking the max distance
(with a floor of `0`). Complexity `O(|σ|²)` distance evaluations. By Theorem 3.4
this is exactly the scale at which `σ` enters the Vietoris–Rips filtration.

**Algorithm B — Vietoris–Rips membership.** `σ ∈ VR(ε)` iff every pairwise distance
is `≤ ε`, i.e. `diamWeight σ ≤ ε`. Complexity `O(|σ|²)`.

**Algorithm C — Čech membership (discrete center test).** `σ ∈ Čech(ε)` iff some
center `c` covers all vertices within radius `ε`. For the *vertex-centered*
relaxation used in the reverse Nerve inclusion, test whether some vertex `x₀ ∈ σ`
has `max_{x ∈ σ} dist(x, x₀) ≤ ε`; complexity `O(|σ|²)`. By Theorem 6.6 a
vertex-centered Čech witness at scale `ε` certifies `σ ∈ VR(ε) ⊆ Čech(2ε)`.

**Algorithm D — Nerve interleaving certificate.** Given `σ` and a center `c` with
`max_x dist(x,c) ≤ ε`, output the certificate that `σ ∈ VR(2ε)` by verifying every
pairwise distance is `≤ 2ε`; the witness is the triangle-inequality bound of
Theorem 6.4.

**Algorithm E — Euler characteristic via the f-vector.** Enumerate the faces of a
finite complex, bucket them by cardinality to form the f-vector `(f₀, f₁, …)`, and
return the alternating sum `Σ_k (−1)^k f_k`. Complexity linear in the number of
faces. By Theorem 7.3 this equals the signed face count `eulerCharFin`.

---

## 10. Applications

- **Robust shape inference.** Theorems 5.1–5.3 certify that persistence diagrams
  computed from the diameter filtration are stable to measurement noise: a δ-bounded
  perturbation moves the diagram by at most δ in interleaving distance.

- **Cheap-vs-faithful trade-off.** Theorem 6.6 gives a precise, verified bound on
  the error incurred by substituting the cheap Vietoris–Rips complex for the
  faithful Čech complex: at most a factor of `2` in scale.

- **Topological summaries.** Theorems 7.3–7.5 give a verified pipeline for the Euler
  characteristic curve — a fast, integer-valued topological summary widely used in
  cosmology, materials science, and image analysis.

- **Thermodynamic filtrations.** See Section 11.

---

## 11. The Boltzmann reading and future work

The name *Boltzmann Bridge* points to a thermodynamic interpretation. Replace the
diameter weight by a **Boltzmann weight** `w_β(σ) = −β⁻¹ log Z(σ)`, where `Z(σ)` is
a partition function over the configurations associated with `σ` and `β` is inverse
temperature. Monotonicity of `w_β` — needed for it to be a `Filtration` — follows
from supermultiplicativity of `Z` under inclusion. Because the entire sublevel
calculus (Sections 2–5) is stated for an *arbitrary* monotone weight, instantiating
it with `w_β` immediately yields complexes, nesting, functoriality, and stability
with no further work. As `β → ∞` (temperature → 0), the log-partition weight
sharpens into a min-plus (tropical) diameter, and the Boltzmann filtration converges
to the ordinary Vietoris–Rips filtration — a thermodynamic limit recast as
convergence of filtration values.

Further directions include: a full persistent-homology layer (chain complexes,
Betti numbers, barcodes) atop the `Finset`-of-faces model; the f-vector / h-vector
theory of shellable complexes, where the same alternating-binomial cancellation
(Theorem 7.5) computes Euler characteristics of arbitrary shellable complexes; a
categorical packaging of the sublevel functor as a genuine `(ℝ, ≤)`-indexed
persistence module; and the metric stability of `diamWeight` proved as a clean
1-Lipschitz property of `Finset.sup'`.

---

## 12. Conclusion

We have presented a compact, fully verified foundation for persistent topology built
on a single primitive — the monotone weight — from which the Vietoris–Rips
filtration, its stability, the Nerve interleaving, and the Euler–Poincaré bridge all
follow. The recurring theme is economy: the deep theorems of applied topology rest
on the triangle inequality and the alternating sum of binomial coefficients,
organized by an abstraction that keeps the metric and combinatorial ledgers cleanly
apart.
