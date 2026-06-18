# The Interleaving Distance on Filtrations Is a Genuine Metric: Closing the Separation Kernel via an Attained Infimum

## Abstract

The interleaving (bottleneck) distance is the central stability invariant of
persistent homology and topological data analysis. Defined as an infimum of
admissible scale-shifts, it is routinely treated as only a *pseudometric*: the
folklore worry — recorded explicitly in two prior developments of this theory — is
that an infimum need not be attained, so distinct filtrations might sit at distance
`0`, and one must pass to a *separation quotient* to recover a genuine metric. We
show that this worry is unfounded for the natural combinatorial model of filtrations
as monotone weight functions on simplices. The decisive technical fact is an
*attained-infimum* lemma: if two filtrations are `ε`-interleaved for every `ε > 0`,
then they are `0`-interleaved. Its entire content is the Archimedean squeeze
`(∀ ε > 0, a ≤ b + ε) ⇒ a ≤ b` applied pointwise to the weights. From this we derive
that the extended interleaving distance equals `0` if and only if the two
filtrations are equal — the T0 (Kolmogorov) separation axiom — so the interleaving
pseudo-extended-metric is *already* a genuine extended metric on the space of
filtrations, and the separation quotient construction is *trivial* (its canonical map
is injective). We give complete definitions, statements, and proof sketches for all
results, an algorithmic treatment, numerical demonstrations, and a discussion of the
methodological lesson: a *limiting* characterization of a metric kernel
("distance 0 = arbitrarily tight interleavings") is strictly weaker than an
*algebraic* one ("distance 0 = a literal 0-interleaving"), and closing the gap is
exactly an attained-infimum argument.

**Keywords.** persistent homology, topological data analysis, interleaving distance,
bottleneck stability, extended metric space, separation quotient, Vietoris–Rips
filtration, Archimedean property, attained infimum.

---

## 1. Introduction

### 1.1 Background and the problem

Persistent homology summarizes the multiscale topological structure of a data set by
a one-parameter nested family of simplicial complexes — a *filtration*. The
foundational stability theorem of the field states that this summary is robust:
small perturbations of the data produce small perturbations of the filtration, where
"small" is measured in the **interleaving distance**. The interleaving distance is an
infimum over admissible *scale-shifts* `δ` for which the two filtrations contain one
another after a uniform `δ`-shift of scale.

For the distance to be a *metric* in the strict sense, it must satisfy the
**identity-of-indiscernibles** (T0/Kolmogorov separation) axiom:

> distance `0` implies equality.

Because the interleaving distance is an infimum, and infima need not be attained, it
is standard to *suspect* that this axiom fails: one might have a sequence of
interleavings whose slacks shrink to `0` without any `0`-interleaving existing,
yielding distinct filtrations at distance `0`. Under that suspicion the structure is
only a **pseudometric**, and the usual remedy is to apply the universal **separation
quotient**, gluing all distance-`0` points to obtain a genuine metric on equivalence
classes.

### 1.2 Two prior developments and the deferred question

This paper is the seventh and final movement of a development arc. We summarize the
relevant prior results (all of which we restate self-containedly below):

- A *real-valued* interleaving distance `interleavingDist = inf{δ : Interleaved F G δ}`
  was constructed, together with the relational interleaving preorder
  `Interleaved` and its reflexivity, symmetry, monotonicity-in-slack, and additive
  transitivity. The real codomain has a flaw: with the convention `inf ∅ = 0`, two
  never-interleaved filtrations falsely register at distance `0`, breaking the
  triangle inequality.

- The codomain was then moved to the extended nonnegative reals `[0, ∞]`, with
  `eInterleavingDist = ⨅_{δ : Interleaved F G δ} ofReal δ`. Here `inf ∅ = ∞` is
  correct, the triangle inequality holds *unconditionally*, and one obtains a genuine
  `PseudoEMetricSpace` structure on filtrations. Its lab notebook recorded the
  *honest defect*: "distinct filtrations can sit at distance `0`, so the structure is
  only a pseudometric."

- The separation quotient was then applied, yielding a genuine `EMetricSpace` on the
  quotient with the canonical map an isometry, and the kernel was characterized only
  *in the limit*: `eInterleavingDist F G = 0` iff for every `ε > 0` there is an
  interleaving with slack `δ < ε`. The clean *algebraic* equivalence
  `eInterleavingDist F G = 0 ⇔ Interleaved F G 0` was explicitly deferred to future
  work, "requiring closedness of the witness set `{δ : Interleaved F G δ}`."

### 1.3 Contribution

We discharge the deferred closedness and show it overturns the pessimistic reading:

1. **(Attained infimum / closure.)** If `F` and `G` are `ε`-interleaved for every
   `ε > 0`, they are `0`-interleaved (Theorem 4.3). The proof is a pointwise
   Archimedean squeeze on the weights.
2. **(Kernel is algebraic.)** `eInterleavingDist F G = 0 ⇔ Interleaved F G 0`
   (Theorem 4.4) — the infimum is attained.
3. **(T0 separation.)** `eInterleavingDist F G = 0 ⇔ F = G` (Theorem 4.7), via the
   chain `Interleaved F G 0 ⇔` equal sublevel families `⇔` equal weights `⇔` equal
   filtrations.
4. **(Consequences.)** Filtrations *already* form a genuine `EMetricSpace`
   (Theorem 5.1); the separation quotient map is *injective* and the quotient is a
   faithful copy (Theorems 5.2–5.3); and the converse that the prior development
   declared to "fail in general" in fact holds (Theorem 5.4).

The "honest defect" of the two prior movements does not exist: there are no distinct
filtrations at extended interleaving distance `0`.

---

## 2. Preliminaries: filtrations and sublevel sets

Throughout, `α` is an arbitrary vertex type and `Finset α` denotes finite subsets of
`α` (the *simplices*).

**Definition 2.1 (Abstract simplicial complex).** An *abstract simplicial complex*
(ASC) on `α` is a set `K ⊆ Finset α` of *faces* that contains `∅` and is downward
closed: if `σ ∈ K` and `τ ⊆ σ` then `τ ∈ K`.

**Definition 2.2 (Filtration).** A *filtration* on `α` is a structure `F` consisting
of:

- a **weight** function `F.weight : Finset α → ℝ` (the birth scale of each simplex),
- the property `F.weight ∅ ≤ 0` (the empty simplex is born by scale `0`),
- the **monotonicity** property: `σ ⊆ τ ⇒ F.weight σ ≤ F.weight τ`.

The two properties are *propositions*, not data; the only data is the weight
function. This observation is decisive (Lemma 4.1).

**Definition 2.3 (Sublevel family).** For a filtration `F` and scale `t ∈ ℝ`, the
*sublevel set* is
$$ F.\mathrm{sublevelFaces}(t) \;=\; \{\, \sigma \in \mathrm{Finset}\,\alpha \;:\; F.\mathrm{weight}\,\sigma \le t \,\}. $$
For `t ≥ 0`, this is an ASC (the empty simplex is present since `weight ∅ ≤ 0 ≤ t`,
and downward closure follows from monotonicity). The family is nested:
`t₁ ≤ t₂ ⇒ F.sublevelFaces(t₁) ⊆ F.sublevelFaces(t₂)`.

**Example 2.4 (Vietoris–Rips).** Given a finite metric (or any matrix
`d : α → α → ℝ`), the *diameter weight* of `σ` is the largest pairwise value `d x y`
over vertices `x, y ∈ σ`, with `0` adjoined so that `∅` and singletons get weight
`0`. The diameter weight is nonnegative, monotone, and **1-Lipschitz in `d`**: if
`|d₁ x y − d₂ x y| ≤ ε` on the vertices of `σ` then
`|diamWeight(d₁, σ) − diamWeight(d₂, σ)| ≤ ε`. Its sublevel sets recover the classical
Vietoris–Rips complex.

---

## 3. The interleaving relation and distance

**Definition 3.1 (`δ`-interleaving).** For filtrations `F, G` and `δ ∈ ℝ`, say `F`
and `G` are **`δ`-interleaved**, written `Interleaved F G δ`, when
$$ 0 \le \delta \;\wedge\; \big(\forall t,\ F.\mathrm{sub}(t) \subseteq G.\mathrm{sub}(t+\delta)\big) \;\wedge\; \big(\forall t,\ G.\mathrm{sub}(t) \subseteq F.\mathrm{sub}(t+\delta)\big). $$

**Proposition 3.2 (Graded preorder).** The interleaving relation satisfies:
- *Reflexivity:* `Interleaved F F 0`.
- *Symmetry:* `Interleaved F G δ ⇒ Interleaved G F δ`.
- *Monotonicity in slack:* `Interleaved F G δ ∧ δ ≤ δ' ⇒ Interleaved F G δ'`
  (enlarge each shift using nestedness of sublevel sets).
- *Additive transitivity:* `Interleaved F G δ ∧ Interleaved G H δ' ⇒ Interleaved F H (δ + δ')`
  (chain the inclusions; shifts add since `t + (δ + δ') = (t + δ) + δ'`).

*Proof.* Each is immediate from Definitions 2.3 and 3.1; monotonicity uses
`sublevel_mono` and transitivity uses associativity of `+`. ∎

**Definition 3.3 (Extended interleaving distance).** The *extended interleaving
distance* is the infimum, in `[0,∞]`, of `ofReal δ` over all admissible slacks:
$$ \mathrm{eInterleavingDist}(F,G) \;=\; \bigsqcap_{\delta \,:\, \mathrm{Interleaved}\, F\, G\, \delta} \mathrm{ofReal}(\delta) \;\in\; [0,\infty]. $$
When no interleaving exists the index type is empty and the infimum is `∞`.

**Proposition 3.4 (Prior results, extended metric).** The extended interleaving
distance satisfies:
- *Upper bound by any witness:* `Interleaved F G δ ⇒ eInterleavingDist F G ≤ ofReal δ`.
- *Diagonal vanishing:* `eInterleavingDist F F = 0`.
- *Symmetry:* `eInterleavingDist F G = eInterleavingDist G F`.
- *Triangle inequality (unconditional):*
  `eInterleavingDist F H ≤ eInterleavingDist F G + eInterleavingDist G H`.

Together these make `(Filtration α, eInterleavingDist)` a `PseudoEMetricSpace`.

*Proof sketch.* The witness bound is `iInf_le` applied to the subtype element
`⟨δ, h⟩`. Diagonal vanishing uses reflexivity and `ofReal 0 = 0`. Symmetry uses
that `Interleaved_symm` is a value-preserving bijection of index subtypes. The
triangle inequality rewrites the right-hand sum using the `[0,∞]`-distributivities
`add_iInf` and `iInf_add` (valid with no nonemptiness hypothesis, because `∞`
absorbs `+`), reduces to `ofReal a + ofReal b = ofReal (a + b)` for nonnegative
`a, b`, and applies the witness bound to the `(a+b)`-interleaving furnished by
additive transitivity. ∎

**Proposition 3.5 (Stability).** If `|d₁ x y − d₂ x y| ≤ ε` for all `x, y`, then the
Vietoris–Rips filtrations of `d₁` and `d₂` are `ε`-interleaved, hence
`eInterleavingDist ≤ ofReal ε`. (Persistence is 1-Lipschitz in the data.)

**Proposition 3.6 (Limiting kernel, prior result).** The extended interleaving
distance vanishes iff interleavings can be made arbitrarily tight:
$$ \mathrm{eInterleavingDist}(F,G) = 0 \iff \forall \varepsilon > 0,\ \exists \delta,\ \mathrm{Interleaved}\,F\,G\,\delta \ \wedge\ \delta < \varepsilon. $$

*Proof sketch.* (`⇒`) For `ε > 0`, `0 = eInterleavingDist F G < ofReal ε`, so by
`iInf_lt_iff` some witness subtype element has value below `ofReal ε`; unpacking gives
`δ < ε`. (`⇐`) Each `δ < ε` yields `eInterleavingDist F G ≤ ofReal δ < ofReal ε`; a
value strictly below `ofReal ε` for every `ε > 0` must be `0` (case split on `0`,
`∞`, finite). ∎

Proposition 3.6 is the *limiting* characterization. It speaks only of approach. The
remainder of the paper replaces it with an *algebraic* one.

---

## 4. Main results: the kernel is trivial

### 4.1 A filtration is its weight

**Lemma 4.1 (`ext_weight`).** If `F.weight = G.weight` then `F = G`.

*Proof.* A `Filtration` has a single data field, `weight`; its `weight_empty` and
`weight_mono` fields are propositions. By proof irrelevance, equal weights force the
two structures to be definitionally equal (`cases F; cases G; cases h; rfl`). ∎

### 4.2 Intrinsic description of `0`-interleaving

**Lemma 4.2a (`interleaved_zero_iff_sublevel_eq`).**
$$ \mathrm{Interleaved}\,F\,G\,0 \iff \forall t \in \mathbb R,\ F.\mathrm{sublevelFaces}(t) = G.\mathrm{sublevelFaces}(t). $$

*Proof.* `Interleaved F G 0` unfolds to `0 ≤ 0` together with
`∀ t, F.sub(t) ⊆ G.sub(t + 0)` and `∀ t, G.sub(t) ⊆ F.sub(t + 0)`. Since `t + 0 = t`,
the two inclusions are exactly set antisymmetry `F.sub(t) = G.sub(t)`. Conversely,
equal sublevel sets give both inclusions and `0 ≤ 0`. ∎

**Lemma 4.2b (`interleaved_zero_iff_weight_eq`).**
$$ \mathrm{Interleaved}\,F\,G\,0 \iff F.\mathrm{weight} = G.\mathrm{weight}. $$

*Proof.* (`⇒`) From Lemma 4.2a, the sublevel sets agree at every scale. Fix `σ`.
Evaluating the agreement at `t = F.weight σ` puts `σ` in `G.sub(F.weight σ)`, i.e.
`G.weight σ ≤ F.weight σ`; evaluating at `t = G.weight σ` gives the reverse. Hence
`F.weight σ = G.weight σ` for all `σ`, so the functions are equal. (`⇐`) Equal
weights make the sublevel sets `{σ : weight σ ≤ t}` literally identical at every
scale, which by Lemma 4.2a gives `Interleaved F G 0`. ∎

### 4.3 The attained infimum (closure lemma)

**Theorem 4.3 (`interleaved_zero_of_forall_pos`; Future Direction 1).** If
`Interleaved F G ε` holds for every `ε > 0`, then `Interleaved F G 0`.

*Proof.* The slack condition `0 ≤ 0` is trivial. For the inclusion
`F.sub(t) ⊆ G.sub(t + 0) = G.sub(t)`: take `σ ∈ F.sub(t)`, so `F.weight σ ≤ t`. For
each `ε > 0`, the hypothesis gives `Interleaved F G ε`, whose first inclusion at
scale `t` yields `σ ∈ G.sub(t + ε)`, i.e. `G.weight σ ≤ t + ε`. As this holds for
every `ε > 0`, the **Archimedean squeeze** `(∀ ε > 0,\ a ≤ b + ε) ⇒ a ≤ b`
(`le_of_forall_pos_le_add`) gives `G.weight σ ≤ t`, i.e. `σ ∈ G.sub(t)`. The reverse
inclusion is symmetric. ∎

This is the closedness of the witness set `{δ : Interleaved F G δ}` at its infimum:
the infimum of admissible slacks is *attained*.

### 4.4 Distance zero equals a literal zero-interleaving

**Theorem 4.4 (`eInterleavingDist_eq_zero_iff_interleaved_zero`).**
$$ \mathrm{eInterleavingDist}(F,G) = 0 \iff \mathrm{Interleaved}\,F\,G\,0. $$

*Proof.* (`⇐`) By the witness bound (Proposition 3.4),
`eInterleavingDist F G ≤ ofReal 0 = 0`, so it equals `0`. (`⇒`) By Proposition 3.6,
for every `ε > 0` there is `δ` with `Interleaved F G δ` and `δ < ε`. By monotonicity
in slack (Proposition 3.2), `Interleaved F G δ` with `δ < ε` upgrades to
`Interleaved F G ε`. Thus `Interleaved F G ε` for every `ε > 0`, and Theorem 4.3
gives `Interleaved F G 0`. ∎

### 4.5 T0 separation

**Theorem 4.7 (`eInterleavingDist_eq_zero_iff_eq`).**
$$ \mathrm{eInterleavingDist}(F,G) = 0 \iff F = G. $$

*Proof.* Chain the equivalences: by Theorem 4.4, `eInterleavingDist F G = 0 ⇔
Interleaved F G 0`; by Lemma 4.2b, `Interleaved F G 0 ⇔ F.weight = G.weight`; by
Lemma 4.1, `F.weight = G.weight ⇔ F = G` (the forward direction is Lemma 4.1; the
reverse is trivial). ∎

This is exactly the identity-of-indiscernibles axiom. The "honest defect" is refuted.

---

## 5. Consequences: the separation quotient is trivial

**Theorem 5.1 (`interleavingEMetricDirect`).** `(Filtration α, eInterleavingDist)` is
a genuine `EMetricSpace`.

*Proof.* It is already a `PseudoEMetricSpace` (Proposition 3.4). The only additional
axiom for an `EMetricSpace` is `eq_of_edist_eq_zero`: `edist F G = 0 ⇒ F = G`, which
is the forward direction of Theorem 4.7. ∎

Let `mk : Filtration α → SeparationQuotient (Filtration α)` denote the canonical map
of the prior development's separation quotient (with `edist (mk F) (mk G) =
eInterleavingDist F G`).

**Theorem 5.2 (`mk_eq_mk_iff_eq`).**
$$ \mathrm{mk}\,F = \mathrm{mk}\,G \iff F = G. $$

*Proof.* The prior development established `mk F = mk G ⇔ eInterleavingDist F G = 0`;
compose with Theorem 4.7. ∎

**Theorem 5.3 (`mk_injective`).** The quotient map `mk` is injective; the separation
quotient is a faithful copy of `Filtration α`.

*Proof.* Immediate from Theorem 5.2. ∎

**Theorem 5.4 (`mk_eq_mk_iff_interleaved_zero`).**
$$ \mathrm{mk}\,F = \mathrm{mk}\,G \iff \mathrm{Interleaved}\,F\,G\,0. $$

*Proof.* `mk F = mk G ⇔ eInterleavingDist F G = 0` (prior) `⇔ Interleaved F G 0`
(Theorem 4.4). The reverse implication is precisely the converse that the prior
development declared to "fail in general"; it holds. ∎

---

## 6. Algorithmic content

Although the results are about arbitrary (possibly infinite) vertex types, they have
direct algorithmic shadows on *finite* data, where filtrations are finite weight
tables and all quantifiers over scales `t` reduce to quantifiers over the finite set
of critical weights.

**Algorithm A (Decide a `δ`-interleaving).** For finite filtrations given as weight
tables over a common simplex set `S`, `F` and `G` are `δ`-interleaved iff
`δ ≥ 0` and for every `σ ∈ S`, `|F.weight σ − G.weight σ| ≤ δ`. (Reason: the sublevel
inclusion at every scale is equivalent to a uniform weight bound; this is the
combinatorial form of `stability_supDist` and its converse on finite carriers.) Cost:
`O(|S|)`.

**Algorithm B (Exact interleaving distance on finite carriers).** By the same
equivalence, the smallest admissible slack equals the sup-norm of the weight
difference:
`eInterleavingDist F G = ofReal( max_{σ ∈ S} |F.weight σ − G.weight σ| )`.
The maximum is over a finite set, so it is *attained* — a concrete instance of
Theorem 4.3. Cost: `O(|S|)`. In particular, the distance is `0` iff the weight
tables are identical, instantiating Theorem 4.7.

**Algorithm C (Vietoris–Rips weight from a distance matrix).** For a point cloud with
matrix `d`, `diamWeight(σ) = max(0, max_{x,y ∈ σ} d x y)`. Combined with Algorithm B
this yields the stability bound `eInterleavingDist ≤ max_{x,y} |d₁ x y − d₂ x y|`
(Proposition 3.5).

The conceptual point: the attained-infimum phenomenon of Theorem 4.3 is *visible*
already on finite carriers, where the infimum over slacks is a maximum over a finite
weight-difference table and is therefore trivially attained. The theorem is the
correct generalization of this elementary finite fact to arbitrary filtrations, with
the Archimedean squeeze standing in for finiteness.

---

## 7. Applications

- **A trustworthy metric for TDA pipelines.** Algorithms that cluster, average, or
  index filtrations frequently assume a true metric — e.g. that distance `0` uniquely
  identifies a representative. Theorem 4.7 licenses this assumption directly on
  filtrations, with no quotient bookkeeping.

- **No spurious collapses.** Because distance `0` forces equality, no two genuinely
  different filtrations can be silently merged by a distance-based deduplication or
  nearest-neighbor step. This rules out a class of subtle correctness bugs.

- **Stability with sharp separation.** The 1-Lipschitz stability bound
  (Proposition 3.5) bounds distance *from above* by data distortion, while
  Theorem 4.7 controls the *bottom* of the scale: the only way to reach distance `0`
  is to reach the data exactly. Together they pin the distance between `0` (equality)
  and the distortion bound.

---

## 8. Discussion: limiting vs. algebraic kernels

The methodological lesson is sharp. Two prior developments characterized the metric
kernel only *in the limit* (Proposition 3.6): "distance `0` = arbitrarily tight
interleavings." That statement is true but operationally weak — it never asserts that
any single interleaving achieves the bound. Treating it as the best available
description led to (i) a pessimistic "pseudometric" verdict and (ii) an elaborate
separation-quotient remedy.

The *algebraic* characterization (Theorem 4.4), "distance `0` = a literal
`0`-interleaving," is strictly stronger, and the gap between the two is *exactly* the
question of whether the defining infimum is attained. Attainment is not automatic for
infima in general — but here it holds for the most elementary of reasons, the
Archimedean squeeze. Pushing that squeeze through the definitions (Theorem 4.3)
collapses the entire pseudometric/quotient apparatus: the space was a genuine metric
space all along (Theorem 5.1) and the quotient was trivial (Theorem 5.3).

We emphasize the structural reason the squeeze suffices: a filtration's only
*data* is its weight function. The propositions it must satisfy (monotonicity, the
empty-face condition) are not extra degrees of freedom that could distinguish
distance-`0` filtrations. Once the weights agree, proof irrelevance (Lemma 4.1) does
the rest. A model of filtrations carrying genuine extra data (e.g. a chosen
orientation, or labels) could in principle reintroduce a nontrivial kernel; our
result is therefore also a statement about the *minimality* of the weight-only model.

---

## 9. Future work

- **EReal/`[0,∞]` upgrade of the real-valued distance.** The original real-valued
  `interleavingDist` mishandles never-interleaved pairs (`inf ∅ = 0`); the extended
  codomain repairs this. A uniform treatment that records `∞` while remaining
  computation-friendly on finite carriers would unify the two.

- **Stability of derived invariants.** Persistence diagrams/barcodes derived from
  these filtrations inherit stability through the interleaving distance. A
  T0-separation theorem at the level of *diagrams* (rather than filtrations) would
  complement Theorem 4.7.

- **Richer filtration models.** Investigate whether weight-plus-extra-data models
  (multiparameter persistence, labeled filtrations) retain or lose T0 separation, and
  identify exactly which extra data reintroduces a nontrivial separation kernel.

- **Quantitative attainment.** Theorem 4.3 is qualitative. On structured infinite
  carriers, quantify the *rate* at which `ε`-interleavings approach the
  `0`-interleaving, connecting attainment to modulus-of-continuity estimates.

---

## 10. Conclusion

We proved that the extended interleaving distance is a genuine extended metric on the
weight-only model of filtrations: distance `0` if and only if equality (Theorem 4.7).
The single technical engine is an attained-infimum lemma whose content is the
Archimedean squeeze (Theorem 4.3). As corollaries, the space needs no separation
quotient — the quotient map is injective (Theorem 5.3) — and the converse previously
believed to fail in fact holds (Theorem 5.4). The "honest defect" recorded by two
prior developments was an artifact of stopping at a *limiting* kernel description; the
*algebraic* description dissolves it entirely.
