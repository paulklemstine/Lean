# A Metric Theory of Certified Novelty: Adaptive Thresholds, Compositional Scores, and Multi-Scale Filtrations

## Abstract

We develop a quantitative, axiomatically grounded theory of *novelty certification* in
(pseudo)metric spaces, motivated by the problem of deciding — with provable guarantees —
whether a newly produced mathematical object (theorem, conjecture, construction) is
genuinely distinct from an existing corpus of known objects. The central object is the
**novelty score** of a candidate `x` against a corpus `S`, defined as the distance from
`x` to the set `S`, together with the binary certificate `IsNovel ε S x` asserting that
`x` is `ε`-separated from every element of `S`. We prove that the certificate and the
score are equivalent (`IsNovel ε S x ↔ ε ≤ noveltyScore S x`), that the score is
`1`-Lipschitz in the candidate and antitone in the corpus, and that novelty degrades by at
most the perturbation under small edits of the candidate.

Building on this foundation we establish results along three orthogonal axes. **(I)
Knowledge saturation:** if the corpus is an `ε`-net of the ambient space then every novelty
score is at most `ε` and no threshold above `ε` can be certified; we prove an honest
approximate converse with arbitrary slack `η > 0`, the slack being unavoidable in general
spaces because the infimal distance need not be attained. **(II) Adaptive thresholds:**
taking the threshold equal to the corpus's own separation `σ` yields an *exactly
discriminating* certificate — every known object is `σ`-novel against its peers yet
correctly rejected against the full corpus — with soundness flowing from the single fact
`dist x x = 0`. **(III) Compositional and multi-scale structure:** the weakest-link
composite score `min(noveltyScore S x, noveltyScore T y)` is `1`-Lipschitz in the `ℓ^∞`
product metric, enabling modular certification, and the novelty sets `{x | IsNovel δ S x}`
form a bifiltration that is antitone in both the threshold `δ` and the corpus `S`, the
metric analogue of a persistence module. Finally we connect mutual separation to packing:
an `ε`-separated corpus induces pairwise-disjoint balls of radius `ε/2`, the geometric core
of covering- and capacity-type bounds. All results rest only on the metric axioms and
standard properties of the infimal distance function.

**Keywords:** novelty detection, metric geometry, infimal distance, Lipschitz regularity,
covering and packing, persistence, certified machine reasoning.

---

## 1. Introduction

### 1.1 Motivation

The automation of mathematical discovery raises a judgment problem of growing urgency.
When candidate theorems, conjectures, and constructions are produced at machine scale, the
binding constraint is no longer *generation* but *evaluation*: which of these objects are
genuinely new relative to the body of known mathematics, and which are rediscoveries or
trivial variants? Human expert judgment — the traditional arbiter of novelty — does not
scale and does not produce auditable certificates.

This paper proposes to ground novelty in metric geometry. We model the space of objects as
a (pseudo)metric space `(α, dist)`, a corpus of known objects as a set `S ⊆ α`, and a
candidate as a point `x ∈ α`. The intuition "`x` is new" becomes "`x` is far from `S`,"
which the distance function makes precise and computable. The contribution is a collection
of theorems that turn this intuition into guarantees with controlled behavior under
perturbation, corpus growth, composition, and change of scale.

### 1.2 Contributions

1. A score/certificate duality identifying the binary novelty predicate with a continuous,
   optimizable scoring function (§3).
2. Regularity theory: `1`-Lipschitz dependence on the candidate, antitone dependence on the
   corpus, and graceful degradation under perturbation (§3).
3. A knowledge-saturation theorem for `ε`-nets and an honest approximate converse, locating
   the exact source of inexactness in the non-attainment of infimal distance (§4).
4. An adaptive-threshold theorem showing that the separation-scaled threshold is exactly
   discriminating, with soundness reduced to `dist x x = 0` (§5).
5. Compositional novelty on products with `1`-Lipschitz regularity in the `ℓ^∞` metric (§6).
6. A two-parameter novelty filtration, antitone in threshold and corpus, as a metric
   persistence module (§7).
7. A packing principle linking mutual separation to disjoint balls (§8).

### 1.3 Setting and conventions

Throughout, `α` and `β` are pseudometric spaces. We work with pseudometrics (allowing
`dist x y = 0` for distinct points) so that the theory applies to feature embeddings in
which distinct objects may be representationally identical. We write `infDist x S` for the
infimal distance from `x` to `S`, i.e. `inf {dist x s : s ∈ S}`, with the convention that
`infDist x ∅ = 0`. We use `ε, δ, σ, η` for nonnegative real parameters.

---

## 2. Core definitions

**Definition 2.1 (Novelty certificate).** For `ε ∈ ℝ`, a set `S ⊆ α`, and a point `x ∈ α`,
we say `x` is **`ε`-novel** with respect to `S`, written `IsNovel ε S x`, if
$$ \forall s \in S,\quad \varepsilon \le \operatorname{dist}(x, s). $$
That is, every known object lies at distance at least `ε` from `x`.

**Definition 2.2 (Novelty score).** The **novelty score** of `x` relative to `S` is
$$ \operatorname{noveltyScore}(S, x) := \operatorname{infDist}(x, S) = \inf_{s \in S} \operatorname{dist}(x, s). $$
For finite nonempty `S` this is `min_{s∈S} dist(x, s)`.

**Definition 2.3 (Mutual separation).** A set `S ⊆ α` is **mutually `ε`-separated**,
written `MutuallySeparated ε S`, if any two distinct points are at least `ε` apart:
$$ \forall a, b \in S,\ a \ne b \implies \varepsilon \le \operatorname{dist}(a, b). $$

**Definition 2.4 (`ε`-net).** A set `S ⊆ α` is an **`ε`-net** of `α`, written
`IsEpsNet ε S`, if every point of the ambient space is within `ε` of `S`:
$$ \forall x \in \alpha,\ \exists s \in S,\ \operatorname{dist}(x, s) \le \varepsilon. $$

**Definition 2.5 (Compositional novelty score).** For corpora `S ⊆ α`, `T ⊆ β` and a
composite `p = (x, y) ∈ α × β`, the **compositional novelty score** is the weakest link
$$ \operatorname{compNovelty}(S, T, p) := \min\bigl(\operatorname{noveltyScore}(S, x),\ \operatorname{noveltyScore}(T, y)\bigr), $$
with `α × β` carrying the `ℓ^∞` product metric `dist((x₁,y₁),(x₂,y₂)) = max(dist(x₁,x₂), dist(y₁,y₂))`.

**Definition 2.6 (Novelty set / filtration).** For threshold `δ` and corpus `S`, the
**novelty set** is
$$ \operatorname{noveltySet}(\delta, S) := \{\, x \in \alpha \mid \operatorname{IsNovel} \delta\, S\, x \,\}. $$

---

## 3. Score–certificate duality and regularity

The first structural result identifies the qualitative certificate with a threshold on the
quantitative score, converting novelty into an optimizable quantity.

**Theorem 3.1 (Score characterization).** *For nonempty `S`,*
$$ \operatorname{IsNovel} \varepsilon\, S\, x \iff \varepsilon \le \operatorname{noveltyScore}(S, x). $$

*Proof sketch.* Unfolding `IsNovel`, the left side is the assertion that `ε` is a lower
bound for `{dist x s : s ∈ S}`. Since the score is the infimum of this set, `ε` is a lower
bound iff `ε ≤ inf`, which is the standard characterization `le_infDist` of the infimal
distance for nonempty sets. ∎

For the empty corpus every point is vacuously `ε`-novel (`IsNovel ε ∅ x` holds for all
`ε, x`), the degenerate case where nothing is known.

**Theorem 3.2 (Lipschitz regularity in the candidate).** *The map
`x ↦ noveltyScore(S, x)` is `1`-Lipschitz:*
$$ |\operatorname{noveltyScore}(S, x) - \operatorname{noveltyScore}(S, y)| \le \operatorname{dist}(x, y). $$

*Proof sketch.* This is the classical `1`-Lipschitz property of distance-to-a-set: for any
`s ∈ S`, `infDist(x, S) ≤ dist(x, s) ≤ dist(x, y) + dist(y, s)`; taking the infimum over
`s` gives `infDist(x, S) ≤ dist(x, y) + infDist(y, S)`, and symmetrically, whence the
absolute bound. ∎

**Theorem 3.3 (Nonnegativity).** `0 ≤ noveltyScore(S, x)` for all `S, x`, since distances
are nonnegative and the infimum of a set bounded below by `0` is `≥ 0`.

**Theorem 3.4 (Antitone in the corpus).** *If `∅ ≠ T ⊆ S` then*
$$ \operatorname{noveltyScore}(S, x) \le \operatorname{noveltyScore}(T, x). $$
*At the predicate level, `IsNovel ε S x` implies `IsNovel ε T x` for any `T ⊆ S`.*

*Proof sketch.* Enlarging the corpus enlarges the set of distances over which we take the
infimum, so the infimum can only decrease: `infDist(x, S) ≤ infDist(x, T)`. The predicate
version is immediate: a lower bound holding over all of `S` holds over the subset `T`. ∎

**Theorem 3.5 (Triangle transfer / robustness).** *If `dist(x, y) ≤ δ` and
`IsNovel ε S x`, then `IsNovel (ε − δ) S y`.*

*Proof sketch.* For any `s ∈ S`, `ε ≤ dist(x, s) ≤ dist(x, y) + dist(y, s) ≤ δ + dist(y,
s)`, so `dist(y, s) ≥ ε − δ`. As `s` was arbitrary, `y` is `(ε − δ)`-novel. ∎

Theorem 3.5 is the quantitative robustness backbone: a candidate certified at level `ε`
remains certified at level `ε − δ` after any edit of size `δ`. Two transport principles
under maps round out the regularity theory.

**Theorem 3.6 (Transport under antilipschitz maps).** *If `f` is `AntilipschitzWith K`
with `K > 0` (i.e. `dist(x, s) ≤ K · dist(f x, f s)`) and `IsNovel ε S x`, then*
$$ \operatorname{IsNovel} (\varepsilon / K)\ (f''S)\ (f\,x). $$

*Proof sketch.* For `s ∈ S`, `ε ≤ dist(x, s) ≤ K · dist(f x, f s)`, so
`dist(f x, f s) ≥ ε / K`. Expanding embeddings never destroy novelty; they merely rescale
the threshold. ∎

**Theorem 3.7 (Contraction under Lipschitz maps).** *If `f` is `LipschitzWith K` then
`dist(f x, f s) ≤ K · dist(x, s)`.* Combined with Theorem 3.6, a bi-Lipschitz map yields
faithful two-sided transport of novelty.

---

## 4. Knowledge saturation

As a corpus grows it may eventually cover the ambient space at some resolution `ε`,
becoming an `ε`-net (Definition 2.4). We show this collapses novelty quantitatively.

**Theorem 4.1 (Saturation, forward).** *If `IsEpsNet ε S` then for every `x`,*
$$ \operatorname{noveltyScore}(S, x) \le \varepsilon. $$

*Proof sketch.* By the net property there is a witness `s ∈ S` with `dist(x, s) ≤ ε`. Then
`infDist(x, S) ≤ dist(x, s) ≤ ε`. ∎

**Theorem 4.2 (Saturation kills high thresholds).** *If `IsEpsNet ε S` and `ε < δ`, then
for every `x`, `¬ IsNovel δ S x`.*

*Proof sketch.* A net witness `s` satisfies `dist(x, s) ≤ ε < δ`. If `x` were `δ`-novel we
would have `δ ≤ dist(x, s)`, contradicting `dist(x, s) < δ`. ∎

Together, Theorems 4.1–4.2 formalize the "exhausted field" phenomenon: once knowledge
covers the space at scale `ε`, the maximal achievable novelty is `ε`, and any stricter
certificate is impossible. We now ask whether observing low scores forces saturation.

**Theorem 4.3 (Approximate converse).** *Let `S` be nonempty and suppose
`noveltyScore(S, x) ≤ ε` for all `x`. Then for every `x` and every slack `η > 0` there
exists `s ∈ S` with `dist(x, s) < ε + η`.*

*Proof sketch.* Fix `x` and `η > 0`. Then `noveltyScore(S, x) ≤ ε < ε + η`, so the infimal
distance is strictly below `ε + η`; by the characterization of strict infimal-distance
bounds (`infDist_lt_iff` for nonempty `S`) there is `s ∈ S` with `dist(x, s) < ε + η`. ∎

**Remark 4.4 (Why the slack is necessary).** The exact converse — "`noveltyScore(S, x) ≤ ε`
for all `x`" implies "`S` is an exact `ε`-net" — fails in general (pseudo)metric spaces
because `infDist(x, S)` need not be *attained*: the infimum of `{dist x s}` may equal `ε`
while every individual `dist(x, s)` strictly exceeds `ε`. The standard counterexample is a
corpus whose distances to `x` form a decreasing sequence converging to `ε` from above with
no minimum. The theory therefore states the honest approximate converse with arbitrary
slack `η`, rather than overclaiming. On *proper* spaces (closed balls compact) with *closed*
corpora the infimum is attained and the slack can be removed; this is the subject of Future
Direction 1.

---

## 5. Adaptive thresholds from corpus geometry

A fixed threshold ignores the intrinsic resolution of the corpus. We propose the
**separation-scaled threshold**: take `δ` equal to the corpus's own separation `σ`. We show
this choice is canonical in the precise sense of being exactly discriminating. Two soundness
lemmas come first.

**Theorem 5.1 (Positive novelty excludes corpus members).** *If `σ > 0` and
`IsNovel σ S x`, then `x ∉ S`.*

*Proof sketch.* If `x ∈ S`, instantiating the certificate at `s = x` gives `σ ≤ dist(x, x)
= 0`, contradicting `σ > 0`. ∎

**Theorem 5.2 (Corpus members are rejected).** *If `σ > 0` and `x ∈ S` then
`¬ IsNovel σ S x`.* (Restatement of Theorem 5.1.)

Soundness thus reduces to the single identity `dist x x = 0`: *any* positive threshold
automatically refuses to certify a known object. We now show the separation-scaled
threshold also correctly *accepts* known objects against their peers.

**Theorem 5.3 (Exact discrimination of the adaptive threshold).** *Let
`MutuallySeparated σ S` with `σ > 0`, and let `x ∈ S`. Then*
$$ \operatorname{IsNovel} \sigma\ (S \setminus \{x\})\ x \qquad\text{and}\qquad \neg\, \operatorname{IsNovel} \sigma\ S\ x. $$

*Proof sketch.* For the first conjunct, every `s ∈ S \ {x}` is a distinct corpus element,
so mutual separation gives `σ ≤ dist(x, s)`; hence `x` is `σ`-novel against its peers
(this is the separation-as-novelty bridge, Theorem 8.2 below). The second conjunct is
Theorem 5.2 applied with `x ∈ S`. ∎

**Interpretation.** Setting the threshold to the corpus separation makes the certificate
*exactly* match the corpus: each known theorem is judged a legitimate, fully separated
contribution relative to its peers, yet is never falsely certified as new relative to the
complete corpus. The standard adapts to local density automatically — fine where the corpus
is dense (small `σ`), coarse where it is sparse (large `σ`) — without external tuning.

---

## 6. Compositional novelty on products

Structured objects (proofs from lemmas, machines from parts) demand a composition law. We
adopt the conservative weakest-link rule (Definition 2.5) and prove it inherits the
regularity of its components.

**Theorem 6.1 (Component bounds).** *For all `p = (x, y)`,*
$$ \operatorname{compNovelty}(S, T, p) \le \operatorname{noveltyScore}(S, x), \qquad \operatorname{compNovelty}(S, T, p) \le \operatorname{noveltyScore}(T, y). $$

*Proof sketch.* Immediate from `min a b ≤ a` and `min a b ≤ b`. ∎

**Theorem 6.2 (Compositional Lipschitz regularity).** *On `α × β` with the `ℓ^∞` product
metric, the map `p ↦ compNovelty(S, T, p)` is `1`-Lipschitz.*

*Proof sketch.* Each component map is a composition of the `1`-Lipschitz novelty score
(Theorem 3.2) with a coordinate projection, and projections are `1`-Lipschitz for the
`ℓ^∞` metric since `dist(x₁, x₂) ≤ max(dist(x₁, x₂), dist(y₁, y₂))`. Thus
`x ↦ noveltyScore(S, x)` and `y ↦ noveltyScore(T, y)`, viewed as functions of `p`, are each
`1`-Lipschitz. The pointwise minimum of `1`-Lipschitz functions is `1`-Lipschitz (because
`|min(a,b) − min(c,d)| ≤ max(|a−c|, |b−d|)`), giving the claim. ∎

**Consequence (modular certification).** Theorem 6.2 means each part of a composite may be
certified and perturbed independently, with the guarantees assembling automatically: a
perturbation of size `δ` in the worst coordinate moves the composite score by at most `δ`.
This lifts the single-object robustness of §3 to arbitrary finite products by iteration.

---

## 7. The novelty filtration

Rather than commit to one threshold, we study the entire family of novelty sets as the
threshold and corpus vary, obtaining a two-parameter filtration — a metric persistence
module.

**Theorem 7.1 (Antitone in the threshold).** *If `δ₁ ≤ δ₂` then
`noveltySet(δ₂, S) ⊆ noveltySet(δ₁, S)`.*

*Proof sketch.* If `x` is `δ₂`-novel then for all `s ∈ S`, `δ₂ ≤ dist(x, s)`; since
`δ₁ ≤ δ₂`, also `δ₁ ≤ dist(x, s)`, so `x` is `δ₁`-novel. ∎

**Theorem 7.2 (Antitone in the corpus).** *If `T ⊆ S` then
`noveltySet(δ, S) ⊆ noveltySet(δ, T)`.*

*Proof sketch.* This is the predicate-level antitonicity of Theorem 3.4: a lower bound
holding over `S` holds over the subset `T`. ∎

**Theorem 7.3 (Joint monotonicity).** *If `δ₁ ≤ δ₂` and `T ⊆ S` then
`noveltySet(δ₂, S) ⊆ noveltySet(δ₁, T)`.* (Compose Theorems 7.1 and 7.2.)

The family `{noveltySet(δ, S)}` thus forms a decreasing chain in each parameter:
tightening the standard or enlarging knowledge can only shrink the set of certified-novel
objects. This is the order-theoretic skeleton of a *persistence module*; tracking the birth
and death thresholds of individual points across the filtration is the metric analogue of a
persistence diagram, and the robustly novel objects are exactly those with long persistence
intervals. (Stability of the resulting diagrams under perturbation of the corpus — a
bottleneck/Hausdorff Lipschitz estimate — is Future Direction 5.)

---

## 8. Packing: separation yields disjoint balls

Finally we connect the certificate to classical packing geometry, the engine of
capacity bounds.

**Theorem 8.1 (Separation ⇒ disjoint balls).** *If `ε ≤ dist(a, b)` then the open balls
`ball(a, ε/2)` and `ball(b, ε/2)` are disjoint. Consequently, if `MutuallySeparated ε S`
then `{ball(c, ε/2) : c ∈ S}` is a pairwise-disjoint family.*

*Proof sketch.* If `z` lay in both balls, the triangle inequality would give
`dist(a, b) ≤ dist(a, z) + dist(z, b) < ε/2 + ε/2 = ε`, contradicting `ε ≤ dist(a, b)`.
Applying this to every distinct pair in a mutually `ε`-separated set yields pairwise
disjointness. ∎

**Theorem 8.2 (Separation as pointwise novelty).** *If `MutuallySeparated ε S` and
`x ∈ S`, then `IsNovel ε (S \ {x}) x`.*

*Proof sketch.* Every `s ∈ S \ {x}` is distinct from `x`, so mutual separation gives
`ε ≤ dist(x, s)`. ∎

Theorem 8.1 is the geometric heart of every packing/capacity bound: the number of
genuinely `ε`-novel points fitting in a bounded region is limited by how many disjoint
`ε/2`-balls fit there. Theorem 8.2 identifies the global packing condition with the
pointwise certificates it guarantees, closing the loop with §5: it is exactly the first
conjunct of the adaptive-discrimination theorem (Theorem 5.3).

---

## 9. Algorithms

The theory is constructive on finite corpora. We summarize the two core procedures.

**Algorithm A (Novelty score and certificate).** Given a finite corpus `S = {s₁, …, sₙ}`
and candidate `x`, compute `score = min_i dist(x, sᵢ)` and return `(score, score ≥ ε)`.
Complexity: `Θ(n)` distance evaluations. Correctness is Theorem 3.1.

**Algorithm B (Adaptive threshold).** Given a finite corpus `S`, compute the separation
`σ = min_{i≠j} dist(sᵢ, sⱼ)` (the corpus's intrinsic resolution) in `Θ(n²)` distance
evaluations, then certify candidates at threshold `σ`. By Theorem 5.3 this certificate
exactly discriminates the corpus. Spatial data structures (e.g. cover trees) reduce both
costs in low intrinsic dimension.

**Algorithm C (Filtration sweep).** Given thresholds `δ₁ < ⋯ < δₖ` and a candidate `x`,
its **persistence interval** is `[0, noveltyScore(S, x))`: `x` is `δ`-novel exactly for
`δ ≤ noveltyScore(S, x)`. Thus a single score computation yields the entire birth/death
profile across all scales (Theorems 7.1–7.3), at no extra asymptotic cost.

---

## 10. Applications

- **Curating machine-generated mathematics.** Embed conjectures/proofs in a feature
  metric, maintain the corpus of known results, and certify each candidate with Algorithm
  A; use Algorithm B to make the standard self-calibrating to the field's density.
- **De-duplication with guarantees.** Theorem 5.2 guarantees no known item is ever
  certified novel; Theorem 3.5 guarantees stability under reformulation, so near-duplicate
  restatements are caught.
- **Saturation diagnostics.** Theorem 4.1 turns "the field is exhausted" into a measurable
  claim: estimate the covering scale `ε` and report the maximal achievable novelty.
- **Modular review of structured artifacts.** Theorem 6.2 licenses lemma-by-lemma
  certification of large proofs with automatic assembly of guarantees.
- **Capacity estimates.** Theorem 8.1 bounds how many genuinely novel contributions a
  bounded region of object-space can hold, a packing-number interpretation of originality.

---

## 11. Discussion

The recurring structural lesson is that a single regularity fact — `noveltyScore(S, ·) =
infDist(·, S)`, which is `1`-Lipschitz and antitone in the corpus — drives the entire
theory. Three elementary levers do all the work: (i) `dist x x = 0` gives soundness of
every positive-threshold certificate; (ii) monotonicity and the triangle inequality of
`infDist` give saturation and robustness; (iii) closure of the Lipschitz property under
`min` and projections gives compositionality, while antitonicity in both parameters gives
the bifiltration. No new analytic input is needed beyond the metric axioms, which is why
the framework scales cleanly across adaptive, compositional, and multi-scale regimes.

A deliberate methodological choice is to state results at exactly the strength provable.
The approximate converse to saturation (Theorem 4.3) carries an explicit slack precisely
because infimal distance need not be attained (Remark 4.4); we do not paper over this with
an unwarranted exact statement.

**Limitations.** (1) The theory is purely geometric: it certifies distance-novelty, not
*semantic* importance — a far-away object may be far because it is nonsensical. (2) Results
depend on the chosen embedding metric; faithfulness of that metric to mathematical content
is an empirical, not a metric-theoretic, question. (3) Pseudometrics allow distinct objects
at distance zero, so distance-novelty is genuinely *representational* novelty.

---

## 12. Future directions

**Direction 1 — Exact saturation on proper/compact spaces.** Conjecture: if `α` is proper
(closed balls compact) and `S` is closed and nonempty, then
`(∀ x, noveltyScore(S, x) ≤ ε) ↔ IsEpsNet ε S` *exactly*, removing the slack of Theorem
4.3. Properness makes `infDist` attained, converting the approximate witness into an exact
net witness.

**Direction 2 — Covering-number lower bounds from packing.** Conjecture: in a totally
bounded space, a mutually `σ`-separated corpus satisfies `|S| ≤` (covering number at scale
`σ/2`), fusing Theorem 8.1 with Theorem 5.3 to bound corpus size by ambient capacity.

**Direction 3 — Quantitative saturation rates.** Beyond the qualitative collapse of §4,
quantify *how fast* novelty scores decay as corpora grow toward `ε`-density, connecting
novelty certification to covering-number theory and learning-curve estimates.

**Direction 4 — Information-theoretic novelty.** Complement geometric novelty with an
entropy-based measure (the increase in corpus-distribution entropy from adding `x`) and
prove a Fano-type inequality lower-bounding information gain by the metric score on finite
spaces.

**Direction 5 — Persistence stability.** Formalize the bottleneck distance on novelty
persistence diagrams and prove the diagram is `1`-Lipschitz in the Hausdorff distance on
corpora, a metric-novelty analogue of the persistence stability theorem; the core metric
estimates (Theorems 3.4, 7.1–7.3) are already in place.

---

## 13. Conclusion

We have given a compact, axiomatically minimal theory of certified novelty in metric
spaces. From the definition of a novelty score as distance-to-corpus we derived
score/certificate duality, sharp regularity, knowledge saturation with an honest converse,
an exactly discriminating adaptive threshold, a `1`-Lipschitz compositional score, a
two-parameter persistence-style filtration, and a packing principle — every result resting
only on the metric axioms and the geometry of infimal distance. The framework offers a
principled, auditable foundation for judging novelty at machine scale, recasting an old and
human question as a precise theorem about the shape of space.
