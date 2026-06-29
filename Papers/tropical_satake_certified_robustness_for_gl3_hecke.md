# Certified Top-K Robustness for Tropical Satake Score Classifiers

## Abstract

We prove a formally verified theorem establishing top-k ranking stability for
multiclass score classifiers under bounded perturbation. The result generalizes
the classical argmax (top-1) robustness theorem to set-valued decisions: if the
gap between the k-th and (k+1)-th ranked scores exceeds twice the perturbation
bound, the top-k label set is exactly preserved. We specialize this to tropical
Satake score families arising from GL₃ Hecke data, providing the first certified
robustness guarantee for ranking outputs in the tropical representation-theoretic
setting. All results are machine-verified in Lean 4 with Mathlib.

## 1. Introduction

Certified robustness — the guarantee that a classifier's output is invariant
under bounded input perturbation — is a central concern in trustworthy machine
learning. The classical result certifies stability of the *argmax* (winning class)
when the score margin exceeds twice the perturbation budget. However, many
real-world systems produce *ranked lists* rather than single predictions:
recommendation engines return top-k items, beam search decoders maintain a
shortlist of hypotheses, and retrieval systems rank documents by relevance.

For such systems, the relevant robustness question is not "does the winner change?"
but "does the *top-k set* change?" This paper answers that question with a clean,
formally verified theorem.

### Contribution

1. **Abstract top-k stability theorem** (Theorem 1): For any finite score family
   with a gap Δ between the k-th and (k+1)-th scores and uniform perturbation
   bounded by η, the condition 2η < Δ guarantees exact preservation of the top-k set.

2. **Lipschitz/metric corollary** (Theorem 2): When scores come from a K-Lipschitz
   family and the input moves by at most ε, the condition 2Kε < Δ suffices.

3. **Argmax recovery** (Theorem 3): The k = 1 case exactly recovers the classical
   argmax stability theorem.

4. **GL₃ tropical certificate** (Theorem 4): Specialization to tropical Satake
   score maps, where Δ decomposes as edge + Levi separation certificates.

5. **Formal verification**: All theorems are machine-checked in Lean 4 + Mathlib
   with no sorry axioms. The proof uses only `propext`, `Classical.choice`, and
   `Quot.sound`.

## 2. Definitions

### 2.1 Top-K Set

Given a score function `score : ι → ℝ` on a finite type ι and a natural number k,
we define the **top-k set** as:

```
topKSet(score, k) = {i ∈ ι : |{j ∈ ι : score(i) < score(j)}| < k}
```

This is the set of labels with fewer than k labels strictly above them. This
definition is *tie-tolerant*: when multiple labels share the same score, they are
all included if fewer than k labels are strictly above them. This means
|topKSet(score, k)| may exceed k when ties exist at the k-th boundary.

### 2.2 Score Gap

The **top-k gap** condition with parameter Δ > 0 requires that every label in the
top-k set outscores every label outside it by at least Δ:

```
topKGapAt(score, k, Δ) ⟺ Δ > 0 ∧ ∀ i ∈ topKSet, ∀ j ∉ topKSet, Δ ≤ score(i) - score(j)
```

### 2.3 Uniform Perturbation

Scores `score'` are η-close to `score` if:
```
UniformScoreClose(score, score', η) ⟺ ∀ i, |score'(i) - score(i)| ≤ η
```

### 2.4 Exact Cardinality Condition

The theorem requires `|topKSet(score, k)| = k`, ruling out ties at the k-th
boundary. This is a natural non-degeneracy condition: it says the k-th and
(k+1)-th ranked scores are distinct.

**Why this is necessary**: With ties at the boundary, the top-k set can contain
more than k elements. Small perturbations can break ties, changing which subset
of the tied labels remains in the top-k set, even when the overall separation
from outside labels is maintained. See Section 5 for a concrete counterexample.

## 3. Main Results

### Theorem 1 (Top-K Invariance under Uniform Perturbation)

Let ι be a finite type, score and score' functions ι → ℝ, k a natural number,
Δ and η real numbers. If:
- topKGapAt(score, k, Δ) holds,
- UniformScoreClose(score, score', η) holds,
- 2η < Δ, and
- |topKSet(score, k)| = k,

then **topKSet(score', k) = topKSet(score, k)**.

### Proof Strategy

The proof proceeds in three steps:

**Step 1 (Pairwise Engine):** If score(i) - score(j) ≥ Δ and 2η < Δ, then
score'(j) < score'(i). This follows from:
- score'(i) ≥ score(i) - η  (from |score'(i) - score(i)| ≤ η)
- score'(j) ≤ score(j) + η  (from |score'(j) - score(j)| ≤ η)
- score(j) + η < score(i) - η  (from Δ ≤ score(i) - score(j) and 2η < Δ)

**Step 2 (Forward inclusion):** For i ∈ topKSet(score, k), show i ∈ topKSet(score', k).
The key observation is that labels beating i in perturbed scores must come from
topKSet(score, k) \ {i} (since every outside label is beaten by i after perturbation).
With |topKSet(score, k)| = k, this set has at most k-1 elements, ensuring the
cardinality condition for membership.

**Step 3 (Reverse inclusion):** For j ∉ topKSet(score, k), show j ∉ topKSet(score', k).
Every element of topKSet(score, k) still beats j after perturbation (by Step 1),
providing at least k labels above j, preventing membership.

### Theorem 2 (Lipschitz Version)

If scores come from a K-Lipschitz family over a (pseudo)metric space with
d(x, x') ≤ ε, then 2Kε < Δ implies topKSet(score(x'), k) = topKSet(score(x), k).

*Proof:* Set η = Kε and apply Theorem 1.

### Theorem 3 (Argmax Recovery)

Setting k = 1 in Theorem 1 recovers the classical argmax stability theorem:
the winning label is preserved under perturbation when the margin exceeds
twice the perturbation bound.

### Theorem 4 (GL₃ Tropical Certificate)

When the Lipschitz family comes from tropical Satake test functions for GL₃
Hecke data, the gap decomposes as Δ = edgeCert + leviCert, where:
- **edgeCert**: separation from simple-coroot edge valuations
- **leviCert**: rank-2 Levi marginal contributions

The condition 2Kε < edgeCert + leviCert then certifies top-k ranking stability.

## 4. Applications

### 4.1 Shortlist Decoding

In neural machine translation, beam search maintains a shortlist of the top-k
hypotheses at each decoding step. Our theorem certifies that small perturbations
to the score function (e.g., from quantization, noise, or approximate computation)
do not change the shortlist, provided the gap condition holds.

### 4.2 Multiclass Retrieval

Information retrieval systems rank documents by relevance scores. The top-k
retrieved set should be stable under score noise. Our theorem provides a
certifiable radius: if scores are K-Lipschitz in the query embedding and the
k-th gap exceeds 2Kε, the retrieved set is guaranteed invariant.

### 4.3 Certified Ranking Robustness

In adversarial ML, certified robustness typically applies to the argmax.
Our result extends this to ranking-based decisions, enabling certified
robustness for top-k classification, recommendation, and multi-label prediction.

### 4.4 Representation-Theoretic Applications

The GL₃ specialization connects to the Satake isomorphism in algebraic number
theory. The tropical Satake transform maps Hecke data to score vectors, and
our theorem certifies that the "fingerprint" of a representation (its top-k
Hecke eigenvalue structure) is stable under perturbation of the underlying data.

## 5. The Tie Boundary Condition

A crucial insight uncovered during formalization is that the exact cardinality
condition |topKSet(score, k)| = k cannot be dropped.

**Counterexample:** Consider 4 labels with scores [10, 5, 5, 0] and k = 2.
The top-2 set is {0, 1, 2} (all three labels have < 2 labels above them),
which has 3 elements, not 2. The gap from inside to outside is 5 (minimum
inside score minus maximum outside score). With η = 1.5, we have 2η = 3 < 5 = Δ.

However, perturbing to scores [9, 3, 7, -1] (all perturbations ≤ 2 > η, but
consider [9, 3, 7, -1] with perturbations [-1, -2, +2, -1], where max perturbation
is 2 > 1.5): actually with η = 1.5, consider scores [9.5, 3.5, 6.5, -1.5]. Then
topKSet = {0, 2}, which is ≠ {0, 1, 2}.

The issue is that ties at the k-th boundary create an "unstable" top-k set:
any perturbation that breaks the tie can remove elements. The exact cardinality
condition excludes this degenerate case.

## 6. Discussion: Making Robustness Guarantees Real

### For a General Audience

Imagine you're using a music recommendation app. It shows you a "Top 5 Songs
for You" list. How confident can you be that this list is really *your* list,
and not an artifact of some small computational error, network glitch, or
rounding in the algorithm?

Our theorem answers this precisely: if the 5th-best song's score is separated
from the 6th-best by a sufficient margin, then *no small perturbation can change
the list*. The critical threshold is simple: if the margin is Δ and the maximum
possible perturbation is η, then the list is guaranteed stable whenever 2η < Δ.

This is the mathematical equivalent of saying: "If the 5th song is clearly better
than the 6th, small noise won't promote the 6th into your top 5."

What makes this interesting is that it's *certified* — not a probabilistic bound,
not an empirical observation, but a mathematical *theorem*, machine-verified by
a computer proof assistant. There is literally zero probability of the guarantee
being wrong, assuming the perturbation bound holds.

### Connection to Tropical Geometry

The "tropical" in our title refers to tropical geometry, a branch of mathematics
where addition is replaced by max and multiplication by addition. This creates
a "piecewise-linear" version of algebraic geometry that turns out to be deeply
connected to representation theory through the Satake isomorphism.

In our setting, tropical score functions are piecewise-linear maps that encode
Hecke eigenvalue data from GL₃ (the group of invertible 3×3 matrices, fundamental
in the Langlands program). The piecewise-linear structure makes Lipschitz bounds
particularly natural, and the representation-theoretic separation theorems provide
the gap certificates needed for our robustness theorem.

### Future Directions

1. **Beyond uniform perturbation**: Extend to label-dependent or
   distribution-dependent perturbation bounds.
2. **Weighted top-k**: Incorporate score-dependent weights for ranking metrics
   like NDCG.
3. **Higher-rank groups**: Generalize the GL₃ specialization to GL_n and other
   reductive groups.
4. **Computational certificates**: Develop algorithms that, given concrete
   Hecke data, compute the certified robustness radius automatically.
5. **Connection to randomized smoothing**: Relate the deterministic certificate
   to probabilistic certified robustness methods.

## 7. Formal Verification Details

All results are formalized in Lean 4.28.0 with Mathlib. The proof development
comprises approximately 260 lines of Lean code, organized as:

- **Definitions** (topKSet, topKGapAt, UniformScoreClose, IsKLipschitzFamily)
- **Characterization lemmas** (membership, equivalence of gap predicates)
- **Pairwise engine** (separated_order_preserved_of_uniform_score_close)
- **Subset inclusions** (forward and reverse)
- **Main theorems** (equality, Lipschitz, argmax, GL₃ certificate)

The proof uses only standard axioms: `propext`, `Classical.choice`, and
`Quot.sound`. No `sorry` remains in the final development.

## References

The formal development builds on the Lean 4 + Mathlib ecosystem. The tropical
Satake connection draws on the classical Satake isomorphism for p-adic groups
and its tropical/combinatorial analogs studied in recent literature on Newton
polytopes and Hecke algebras. The certified robustness framework follows the
general pattern established in the adversarial ML literature, with the key
novelty being the extension from top-1 to top-k decisions and the connection
to representation-theoretic separation certificates.
