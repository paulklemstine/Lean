# The Interleaving Metric Quotient: From a Pseudometric of Filtrations to a Genuine Metric Space of Persistent Shapes

**Boltzmann Bridge VI**

---

## Abstract

The interleaving distance is the canonical way to compare the multi-scale shapes
produced by topological data analysis. We study its formalization on an abstract
class of *filtrations* — monotone weight functions on the finite subsets of a
vertex type — and trace a careful progression from a crude real-valued
pre-distance to a genuine metric space. We work with the **extended interleaving
distance** valued in the extended nonnegative reals `ℝ≥0∞`, under which
filtrations form a *pseudometric space*: the distance is symmetric, vanishes on
the diagonal, and satisfies the triangle inequality unconditionally. This
structure carries one honest defect — distinct filtrations may sit at distance
zero — so it is only a *pseudo*metric.

Our main contribution removes this defect categorically. Rather than constructing
a quotient by hand, we observe that the extended interleaving distance already
satisfies the pseudometric axioms, and we therefore apply the universal
*separation quotient* reflection, which manufactures a genuine **extended metric
space** `interleavingEMetric` on the quotient with the canonical projection an
**isometry**. We characterize the identification kernel completely and
intrinsically: two filtrations are identified in the quotient **if and only if**
their extended interleaving distance is zero, which in turn holds **if and only
if** they admit admissible interleavings of arbitrarily small positive
magnitude. A literal zero-shift interleaving is sufficient for identification but,
in general, not necessary — a precise reflection of the fact that the defining
infimum need not be attained. We give full definitions, theorem statements,
proof sketches, algorithms, applications, and a program of five future research
directions.

**Keywords:** persistent homology, topological data analysis, interleaving
distance, filtration, pseudometric space, separation quotient, extended metric,
Vietoris–Rips, stability.

---

## 1. Introduction

Topological data analysis (TDA) extracts robust, multi-scale structure from
finite data by associating to it a nested family of simplicial complexes — a
*filtration* — and recording the scales at which topological features are born
and die. The single number that compares two such filtrations is the
**interleaving distance**, and its foundational property is **stability**: a
small perturbation of the input data produces only a proportionally small change
in the filtration. Stability is what makes the entire enterprise trustworthy in
the presence of measurement noise.

While the interleaving distance is universally described as "a metric," a
delicate point is routinely glossed over: as ordinarily set up, it is only a
*pseudometric*, because the infimum that defines it need not be attained and so
distinct filtrations can sit at distance zero. This paper takes that delicacy
seriously. We isolate exactly where and why the metric axioms hold, exhibit the
precise structural defect, and resolve it by a universal categorical
construction, characterizing the resulting identification completely.

The development sits at the end of a six-part arc:

- **II — Higher Persistence:** the filtration calculus (the structure
  `Filtration`, the sublevel family `sublevelFaces`, monotonicity `sublevel_mono`,
  the Vietoris–Rips diameter weight `diamWeight`).
- **III — Persistence Stability:** the set-inclusion interleaving lemmas.
- **IV — Bottleneck Stability:** the relational interleaving preorder
  `Interleaved` with its reflexivity, symmetry, monotonicity, and transitivity,
  and a first real-valued `interleavingDist`.
- **V — Interleaving Metric:** the `ℝ≥0∞`-valued `eInterleavingDist` and the
  representation theorem yielding a `PseudoEMetricSpace` of filtrations.
- **VI — Interleaving Quotient (this paper):** removal of the pseudometric defect
  by the separation quotient, with a complete intrinsic description of the
  identification kernel.

---

## 2. Definitions

Throughout, `α` is an arbitrary vertex type, and simplices are finite subsets
`σ : Finset α`.

### 2.1 Filtrations

**Definition 2.1 (Filtration).** A *filtration* on `α` is a weight function
`weight : Finset α → ℝ` together with two axioms:

- **Grounding:** `weight(∅) ≤ 0`.
- **Monotonicity:** for all `σ ⊆ τ`, `weight(σ) ≤ weight(τ)`.

The weight of a simplex is interpreted as the scale at which it is born.

**Definition 2.2 (Sublevel family).** For a filtration `F` and a scale `t : ℝ`,
the *sublevel set of faces* is
```
sublevelFaces(F, t) = { σ : Finset α | weight_F(σ) ≤ t }.
```
By monotonicity this set is downward closed, hence a genuine abstract simplicial
complex for `t ≥ 0`; and by transitivity of `≤` it is nested in the scale:
`t₁ ≤ t₂ ⟹ sublevelFaces(F, t₁) ⊆ sublevelFaces(F, t₂)` (this is `sublevel_mono`).

**Example 2.3 (Vietoris–Rips).** Given a distance matrix `d : α → α → ℝ`, the
*diameter weight* of a simplex is
```
diamWeightOf(d, σ) = max( {0} ∪ { d(x, y) : x, y ∈ σ } ),
```
the largest pairwise entry, with `0` adjoined so the empty simplex and singletons
receive weight `0`. This is a filtration `diamFiltrationOf(d)`; its sublevel set
at scale `ε` is exactly the Vietoris–Rips complex `{ σ : ∀ x, y ∈ σ, d(x,y) ≤ ε }`.

### 2.2 The interleaving relation

**Definition 2.4 (`δ`-interleaving).** Two filtrations `F` and `G` are
*`δ`-interleaved*, written `Interleaved(F, G, δ)`, when `δ ≥ 0` and both
asymmetric inclusions hold for every scale `t`:
```
sublevelFaces(F, t) ⊆ sublevelFaces(G, t + δ)   and
sublevelFaces(G, t) ⊆ sublevelFaces(F, t + δ).
```
Each filtration's growing shape is contained in a `δ`-delayed copy of the other.

This relation is the relational skeleton of a graded preorder:

- **Reflexivity:** `Interleaved(F, F, 0)`.
- **Symmetry:** `Interleaved(F, G, δ) ⟹ Interleaved(G, F, δ)`.
- **Monotonicity in the shift:** `Interleaved(F, G, δ)` and `δ ≤ δ'` imply
  `Interleaved(F, G, δ')`.
- **Additivity (transitivity):** `Interleaved(F, G, δ)` and `Interleaved(G, H, δ')`
  imply `Interleaved(F, H, δ + δ')`.

The last property is the relational form of the triangle inequality.

### 2.3 The extended interleaving distance

**Definition 2.5 (Extended interleaving distance).** The *extended interleaving
distance* is the infimum, taken in `ℝ≥0∞`, of `ofReal δ` over admissible shifts:
```
eInterleavingDist(F, G) = ⨅_{ δ : Interleaved(F, G, δ) } ENNReal.ofReal δ.
```
The choice of codomain is essential. When `F` and `G` are *never* interleaved the
index set is empty and the infimum is `⊤ = ∞` — the correct value. (In the real
numbers, the convention `inf ∅ = 0` instead reports never-interleaved filtrations
at distance `0` and breaks the triangle inequality; this is the precise reason
Bridge V moved to `ℝ≥0∞`.)

The basic facts, established in Bridge V, are:

- **Upper bound by any witness:** `Interleaved(F, G, δ) ⟹ eInterleavingDist(F, G) ≤ ofReal δ`.
- **Diagonal vanishing:** `eInterleavingDist(F, F) = 0`.
- **Symmetry:** `eInterleavingDist(F, G) = eInterleavingDist(G, F)`.
- **Triangle inequality (unconditional):**
  `eInterleavingDist(F, H) ≤ eInterleavingDist(F, G) + eInterleavingDist(G, H)`.

These four package into the representation theorem `interleavingPseudoEMetric`,
making `Filtration α` a `PseudoEMetricSpace`.

---

## 3. The Pseudometric Defect

The representation theorem of Bridge V is genuine but incomplete: a true
(extended) metric must additionally satisfy

> **Separation:** `edist(x, y) = 0 ⟹ x = y`.

This fails for `eInterleavingDist`. The distance is an infimum, and infima need
not be attained, so two *distinct* filtrations may admit `δ`-interleavings for
every `δ > 0` without admitting any literal `0`-interleaving. Their distance is
then the infimum of arbitrarily small positive shifts, namely `0`, even though
they are not equal. Concretely, any two filtrations whose sublevel families
coincide at every scale already have distance zero, and one can construct
non-equal weight functions with this property.

Thus `interleavingPseudoEMetric` is, honestly, a *pseudo*metric. The aim of this
paper is to remove the defect.

---

## 4. Main Results

We promote the pseudometric structure of Bridge V to a (file-local) instance, so
that Mathlib's universal **separation-quotient** machinery applies. Recall that
the separation quotient of a pseudometric space `X` is `SeparationQuotient X`, the
quotient of `X` by the *inseparability* relation; for a pseudometric this relation
coincides with "distance zero," and the quotient carries a canonical genuine
(extended) metric.

### 4.1 The quotient projection is an isometry

**Theorem 4.1 (`edist_quotient_mk`).** For all filtrations `F, G`,
```
edist( mk F, mk G ) = eInterleavingDist(F, G),
```
where `mk : Filtration α → SeparationQuotient (Filtration α)` is the canonical
projection.

*Proof sketch.* By construction the local pseudometric instance has `edist`
literally equal to `eInterleavingDist`. The separation quotient is equipped so
that the distance between two classes equals the pseudodistance of any
representatives (`SeparationQuotient.edist_mk`); composing this with the
definitional unfolding of the instance gives the claim by reflexivity. ∎

Theorem 4.1 says the quotient is a faithful, distortion-free image of the original
pseudometric: no distances are changed, only zero-distance points are merged.

### 4.2 The genuine metric space

**Theorem 4.2 (`interleavingEMetric`).** `SeparationQuotient (Filtration α)`
carries a genuine `EMetricSpace` structure, under which distinct points are at
strictly positive distance.

*Proof sketch.* Mathlib's general theory provides, for any
`PseudoEMetricSpace X`, an `EMetricSpace` instance on `SeparationQuotient X`. With
the filtration pseudometric installed as a local instance, this metric is found by
type-class inference. The separation axiom holds by the defining property of the
quotient: classes are equal exactly when their representatives are inseparable,
i.e. at distance zero. ∎

### 4.3 The identification kernel is exactly distance zero

**Theorem 4.3 (`mk_eq_mk_iff_eInterleavingDist_zero`).** For all `F, G`,
```
mk F = mk G   ⟺   eInterleavingDist(F, G) = 0.
```

*Proof sketch.* Equality of classes in the separation quotient is, by
`SeparationQuotient.mk_eq_mk`, the inseparability of the representatives. In an
(extended) pseudometric space, `EMetric.inseparable_iff` rephrases inseparability
as vanishing distance. Since the instance's `edist` is `eInterleavingDist` by
definition, the result follows by reflexivity. ∎

This is the precise statement that the quotient identifies *exactly* the
distance-zero pairs — no more (faithfulness) and no less (separation).

### 4.4 Distance zero is a limiting condition

**Theorem 4.4 (`eInterleavingDist_eq_zero_iff`).** For all `F, G`,
```
eInterleavingDist(F, G) = 0   ⟺   ∀ ε > 0, ∃ δ, Interleaved(F, G, δ) ∧ δ < ε.
```

*Proof sketch.*

- **(⟹)** Suppose the distance is `0` and fix `ε > 0`. Then
  `eInterleavingDist(F, G) = 0 < ofReal ε`. Unfolding the distance as an infimum
  and applying the characterization `iInf_lt_iff`, some indexed witness lies
  strictly below `ofReal ε`; that witness is a subtype element `⟨δ, hδ⟩` with
  `ofReal δ < ofReal ε`. Since `ε > 0`, the order-embedding lemma
  `ENNReal.ofReal_lt_ofReal_iff` extracts `δ < ε`, and `hδ : Interleaved(F, G, δ)`
  is the required witness.

- **(⟸)** Suppose for every `ε > 0` there is `δ < ε` with `Interleaved(F, G, δ)`.
  Then for each such `ε`,
  `eInterleavingDist(F, G) ≤ ofReal δ < ofReal ε`, so the distance is strictly
  below every positive `ofReal ε`. A value `a ∈ ℝ≥0∞` lying strictly below every
  positive `ofReal ε` must be `0`: it cannot be `⊤` (take `ε = 1`), and if it were
  a positive finite value it would violate the bound at `ε = a.toReal` (using
  `ENNReal.ofReal_toReal`). Hence the distance is `0`. ∎

Theorem 4.4 gives the intrinsic, data-level meaning of the kernel: two filtrations
are identified precisely when they can be interleaved arbitrarily tightly.

### 4.5 A literal zero-interleaving suffices

**Theorem 4.5 (`mk_eq_mk_of_interleaved_zero`).** If `Interleaved(F, G, 0)`, then
`mk F = mk G`.

*Proof sketch.* From the witness `δ = 0` and the upper-bound property,
`eInterleavingDist(F, G) ≤ ofReal 0 = 0`, hence by antisymmetry the distance is
`0`; Theorem 4.3 then identifies the classes. ∎

**Remark 4.6 (the converse fails).** The converse of Theorem 4.5 is false in
general, precisely because the infimum in Definition 2.5 need not be attained. By
Theorem 4.4, `mk F = mk G` only guarantees interleavings of *arbitrarily small*
positive magnitude, not a literal `0`-interleaving. This asymmetry is the genuine
mathematical content of the construction: the quotient captures limiting closeness
that no single zero-shift test could detect. Whether the converse holds under a
closedness hypothesis on the witness set is the subject of Future Direction 1.

### 4.7 Logical hygiene

All `Prop`-valued results above (Theorems 4.1, 4.3, 4.4, 4.5) rest only on the
standard foundations `propext`, `Classical.choice`, and `Quot.sound`; no
additional axioms are introduced.

---

## 5. Algorithms

The constructions are inherently about infima over a continuum of shifts and so
are not directly "computed." Nonetheless, three concrete algorithmic kernels
underlie the theory and are eminently computable on finite data; they are
implemented and exercised in the accompanying demonstrations.

**Algorithm A — Diameter weight of a simplex.** Given a distance matrix `d` and a
simplex `σ`, return `max({0} ∪ { d(x,y) : x, y ∈ σ })`. Cost `O(|σ|²)` per
simplex. This is the load-bearing primitive of Vietoris–Rips persistence.

**Algorithm B — Interleaving certificate from distortion.** Given two distance
matrices `d₁, d₂` on a common vertex set, compute the sup-norm distortion
`ε = max_{x,y} |d₁(x,y) − d₂(x,y)|`. By the stability theorem the two
Vietoris–Rips filtrations are `ε`-interleaved, certifying
`eInterleavingDist ≤ ofReal ε`. Cost `O(n²)` in the number of vertices.

**Algorithm C — Sublevel-inclusion interleaving check.** To verify a candidate
shift `δ` directly, enumerate the (finitely many) simplices and check, at each
relevant scale breakpoint, the two sublevel inclusions of Definition 2.4. The
relevant breakpoints are the finitely many weight values, so the continuum of `t`
reduces to a finite check. Cost is polynomial in the number of simplices.

These algorithms make the abstract identification kernel testable: identification
at distance zero corresponds to Algorithm B / C returning arbitrarily small valid
shifts.

---

## 6. Applications

**6.1 Trustworthy shape comparison.** The genuine metric on the quotient is
exactly the structure required to do statistics, clustering, and nearest-neighbor
retrieval on persistent shapes. On a pseudometric, distinct samples at distance
zero make means and medoids ill-defined; the quotient eliminates this pathology
while preserving all distances (Theorem 4.1).

**6.2 Noise robustness, quantified.** The extended stability bound says: if two
data sets differ by at most `ε` in every pairwise distance, their filtration
classes are within `ofReal ε` in the quotient metric. Persistence is `1`-Lipschitz
in the data, all the way up to the quotient. This is the formal guarantee behind
TDA pipelines in fields from materials science to neuroscience.

**6.3 Canonical representatives.** Theorem 4.3 identifies the equivalence "same
persistent shape" with the concrete relation "distance zero," and Theorem 4.4
gives its intrinsic meaning. This justifies treating a filtration only up to its
sublevel content, the standard working practice in applied persistence.

**6.4 A worked certificate.** For two explicit three-point clouds — a unit
triangle `cloud₁` (all off-diagonal distances `1`) and a perturbed triangle
`cloud₂` (all off-diagonal distances `11/10`) — the sup-norm distortion is
`1/10`, certifying that their Vietoris–Rips filtrations satisfy
`eInterleavingDist ≤ ofReal (1/10)`, hence their classes lie within `1/10` in the
quotient metric. This is a complete, end-to-end instance of the theory.

---

## 7. Discussion

The conceptual payoff is the *ladder principle*: the climb from a crude
real-valued pre-distance, through an honest pseudometric, to a genuine metric
space of shapes is achieved purely by two structural moves, with no new geometric
input.

1. **Change the codomain `ℝ → ℝ≥0∞`** (Bridge V). This gives the empty-witness
   (never-interleaved) case its correct value `⊤` and makes the triangle
   inequality hold unconditionally, because `⊤` absorbs finite addition. The
   triangle inequality is revealed as the metric shadow of the relational
   additivity law `Interleaved_trans`.

2. **Apply the separation quotient** (this paper). This is a *universal*
   reflection from pseudometric to metric spaces; it does the work for free,
   keeps the projection an isometry (Theorem 4.1), and yields a complete intrinsic
   description of what gets identified (Theorems 4.3–4.5).

The single most informative result is the asymmetry of Theorem 4.5 and Remark
4.6: identification is an *analytic* (limiting) condition, not a combinatorial
(single-shift) one. This is why the quotient — rather than any finite test — is
the correct object, and it sets the agenda for the closedness question of Future
Direction 1.

---

## 8. Future Directions

**1. Attainment of the interleaving infimum (closedness of the witness set).**
`mk_eq_mk_of_interleaved_zero` is one-directional because the infimum defining the
distance need not be attained. *Conjecture:* the witness set
`{ δ | Interleaved(F, G, δ) }` is closed in `ℝ` (it is an up-set by monotonicity,
so closedness is equivalent to attainment of its infimum), whence whenever it is
nonempty the infimum is realized and `eInterleavingDist(F, G) = 0 ⟺
Interleaved(F, G, 0)`. The key insight is that `Interleaved(F, G, δ)` is an
intersection over scales `t` of the *closed* conditions
`sublevelFaces(F, t) ⊆ sublevelFaces(G, t + δ)`, with set inclusion varying
upper-semicontinuously in `δ`. This would upgrade Theorem 4.4 from a limiting
characterization to a clean algebraic one and make the kernel decidable from a
single `δ = 0` test.

**2. The quotient is a complete metric space.** The separation quotient of a
pseudometric is a metric space, but completeness is not automatic. *Conjecture:*
when `α` is finite, `SeparationQuotient (Filtration α)` is a *complete* extended
metric space; every Cauchy sequence of classes converges to the class of the
scale-wise limit of sublevel families. The insight: for finite `α`, a filtration
is determined by finitely many monotone weights `Finset α → ℝ`, a Cauchy sequence
in the interleaving metric is uniformly Cauchy in those weights, and a pointwise
limit of monotone functions is monotone. Completeness is exactly the hypothesis
needed for fixed-point and persistence-landscape arguments on the quotient.

**3. Functoriality: 1-Lipschitz pushforward along maps of data.** *Conjecture:* a
map `f : α → β` of vertex sets induces a `1`-Lipschitz map between interleaving
metric quotients, so that pulling a distance matrix back along `f` satisfies
`eInterleavingDist(pushforward f F, pushforward f G) ≤ eInterleavingDist(F, G)`.
The insight: pullback along `f` can only *merge* vertices and hence *shrink* every
simplex diameter spread — the functorial form of the load-bearing estimate that
the diameter is `1`-Lipschitz in the distance matrix. This turns the pipeline into
a functor `(finite data, distortion) ⟶ (metric spaces, 1-Lipschitz)`.

**4. Diameter / boundedness dichotomy of a connected component.** In the
pseudometric, two filtrations are at distance `⊤` exactly when never interleaved.
*Conjecture:* "finite interleaving distance" partitions filtrations into classes
that become the connected components of the quotient, with the metric bounded on a
component iff its weight functions are uniformly comparable. The insight:
transitivity makes "finite distance" an equivalence whose classes are the
`⊤`-free blocks, so the quotient is an `ℝ≥0∞`-metric coproduct of bounded pieces.
This connects to bottleneck-distance stratification in TDA.

**5. The quotient metric refines the persistence-diagram bottleneck distance.**
*Conjecture:* there is a `1`-Lipschitz map from the interleaving metric quotient
to the space of persistence diagrams under the bottleneck metric, factoring the
extended stability bound through the quotient metric. The insight: the
distance-zero kernel quotiented out here is *contained in* the kernel of the
diagram map (equal sublevel families at every scale ⟹ equal diagrams), so the
diagram map descends to the quotient and is automatically `1`-Lipschitz. This
realizes the classical Cohen–Steiner–Edelsbrunner–Harer stability theorem as a
clean quotient morphism.

---

## 9. Conclusion

We have completed the passage from the relational interleaving preorder to a
genuine metric space of persistent shapes. The extended interleaving distance is a
pseudometric with one honest defect — distinct filtrations at distance zero — and
that defect is removed once and for all by the universal separation quotient,
which yields a true extended metric space with the projection an isometry. The
identification kernel is characterized completely and intrinsically: equality in
the quotient is exactly distance zero, which is exactly the existence of
arbitrarily tight interleavings, with a literal zero-shift interleaving sufficient
but not necessary. The whole arc collapses to a single slogan — *persistence
stability is the metric shadow of relational additivity, and the metric ladder is
climbed by changing the codomain and taking a universal quotient* — and opens a
concrete five-point program for completeness, functoriality, and the recovery of
classical bottleneck stability.
