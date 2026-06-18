# Support Duality and Identifiability for Idempotent Kernel Mean Embeddings via Maxitive Measures

## Abstract

We establish a formally verified reconstruction theory for tropical kernel mean
embeddings of maxitive measures on finite discrete spaces. Our main results show
that (1) the discrete support of a maxitive measure is uniquely determined by its
tropical kernel mean embedding under a separating kernel hypothesis, and (2) the
full measure is identifiable from the embedding. These results are formalized in
Lean 4 with complete machine-checked proofs, connecting the analytic (KME),
geometric (support), and algebraic (residuation) aspects of tropical reconstruction
into a unified framework. We define the topological support of maxitive measures and
prove that it coincides with the discrete support on discrete spaces, establishing
the foundation for extensions to zero-dimensional compact spaces via Stone duality.

## 1. Introduction

Kernel mean embeddings (KMEs) are a foundational tool in machine learning and
statistics: they map probability measures into a reproducing kernel Hilbert space
(RKHS), where the rich geometry of the Hilbert space enables nonparametric
inference. The central question of KME theory is *identifiability*: when does
equality of embeddings imply equality of measures?

In classical RKHS theory, this question is answered by the notion of a
*characteristic kernel*: a kernel `k` is characteristic if the KME map
`μ ↦ ∫ k(·, x) dμ(x)` is injective on the space of probability measures.
The celebrated Sriperumbudur–Gretton–Fukumizu–Schölkopf theorem (2010) shows
that universal kernels are characteristic.

This paper develops the *tropical* (idempotent, max-plus) analogue of this theory.
In the max-plus semiring `(ℝ ∪ {-∞}, max, +)`, the analogue of a probability
measure is a *maxitive measure* `μ` satisfying `μ(A ∪ B) = max(μ(A), μ(B))`.
The tropical KME maps a weight profile `w : X → ℝ ∪ {-∞}` (representing the
singleton masses of a maxitive measure) to the tropical potential

```
m_w(y) = sup_x [w(x) + k(x, y)]
```

Our main contributions are:

1. **Singleton decomposition** (Theorem 3.1): On finite types, every maxitive
   measure is uniquely determined by its singleton masses, and the measure of
   any set equals the supremum of its singleton masses.

2. **Support identifiability** (Theorem 4.1): Under a separating kernel, equality
   of tropical KMEs implies equality of supports.

3. **Full identifiability** (Theorem 4.2): Under a separating kernel, equality of
   tropical KMEs implies equality of measures.

4. **Witness duality** (Theorem 4.3): Non-membership in the support is characterized
   by the existence of a singleton indicator function whose tropical integral vanishes.

5. **Topological-discrete support equivalence** (Theorem 5.1): On finite discrete
   spaces, the topological support equals the discrete support.

All results are formally verified in Lean 4 with Mathlib, with no axioms beyond
`propext`, `Classical.choice`, and `Quot.sound`.

## 2. Maxitive Measures

### 2.1 Definition

A *maxitive measure* on a set `X` is a function `μ : P(X) → ℝ ∪ {-∞}` satisfying:
- **Empty set**: `μ(∅) = -∞`
- **Maxitivity**: `μ(A ∪ B) = max(μ(A), μ(B))` for all `A, B ⊆ X`

Maxitive measures are the tropical analogues of probability measures. Where a
probability measure satisfies `μ(A ∪ B) = μ(A) + μ(B)` for disjoint sets (additivity),
a maxitive measure satisfies `μ(A ∪ B) = max(μ(A), μ(B))` for all sets (including
overlapping ones).

### 2.2 Monotonicity

From the maxitivity axiom, we immediately derive monotonicity: if `A ⊆ B`, then
`B = A ∪ B`, so `μ(B) = max(μ(A), μ(B)) ≥ μ(A)`.

### 2.3 Discrete Support

The *discrete support* of a maxitive measure is:

```
supp(μ) = {x ∈ X | μ({x}) ≠ -∞}
```

This is the set of points that carry nonvanishing singleton mass.

## 3. Singleton Decomposition

### Theorem 3.1 (Singleton Decomposition)

*On a finite type `X`, for any maxitive measure `μ` and any set `S ⊆ X`:*

```
μ(S) = sup_{x ∈ S} μ({x})
```

**Proof sketch.** By induction on `|S|`. The base case `S = ∅` gives `μ(∅) = -∞ = sup_∅`.
For the inductive step, write `S = S' ∪ {a}` and apply maxitivity:
`μ(S) = max(μ(S'), μ({a})) = max(sup_{x ∈ S'} μ({x}), μ({a})) = sup_{x ∈ S} μ({x})`. ∎

### Corollary 3.2 (Extensionality from Singletons)

*Two maxitive measures on a finite type that agree on all singletons are equal.*

**Proof.** Immediate from Theorem 3.1: if `μ({x}) = ν({x})` for all `x`, then
`μ(S) = sup_{x ∈ S} μ({x}) = sup_{x ∈ S} ν({x}) = ν(S)` for all `S`. ∎

### Corollary 3.3 (Weight Representation)

*Every maxitive measure on a finite type is uniquely represented by a weight function
`w : X → ℝ ∪ {-∞}` via `μ(S) = sup_{x ∈ S} w(x)`, where `w(x) = μ({x})`.*

## 4. Tropical KME Identifiability

### 4.1 The Tropical KME

Given a real-valued kernel `k : X × X → ℝ` and a weight profile `w : X → ℝ ∪ {-∞}`,
the *tropical kernel mean embedding* is:

```
tropKME(k, w)(y) = sup_x [w(x) + k(x, y)]
```

This is the max-plus matrix-vector product `w ⊗ k`, where `⊗` denotes tropical
matrix multiplication.

### 4.2 Separating Kernels and Residuation

A kernel `k` is *separating* if the tropical KME admits exact reconstruction via
residuation:

```
w(x) = inf_y [tropKME(k, w)(y) - k(x, y)]    for all w, x
```

This is the tropical analogue of the RKHS reconstruction formula. The upper bound
`w(x) ≤ inf_y [tropKME(k, w)(y) - k(x, y)]` always holds by the residuation
inequality; the separating property demands equality.

### Theorem 4.1 (Support Identifiability)

*Under a separating kernel, if `tropKME(k, w₁) = tropKME(k, w₂)`, then
`supp(w₁) = supp(w₂)`.*

**Proof.** A separating kernel implies injectivity of the tropical KME
(by the reconstruction formula). Hence `tropKME(k, w₁) = tropKME(k, w₂)` implies
`w₁ = w₂`, which immediately gives `supp(w₁) = supp(w₂)`. ∎

### Theorem 4.2 (Full Identifiability)

*Under a separating kernel, if two maxitive measures `μ, ν` satisfy
`tropKME(k, μ) = tropKME(k, ν)` (where the KME uses singleton masses as weights),
then `μ = ν`.*

**Proof.** By Theorem 4.1, we get `w_μ = w_ν` (weight equality). By Corollary 3.2,
this implies `μ = ν` (measure equality). ∎

### Theorem 4.3 (Witness Duality)

*For a weight profile `w` and a point `x`, the following are equivalent:*
1. *`x ∉ supp(w)` (i.e., `w(x) = -∞`)*
2. *There exists a singleton witness `φ : X → ℝ ∪ {-∞}` with `φ(x) = 0`,
   `φ(y) = -∞` for `y ≠ x`, and `sup_y [w(y) + φ(y)] = -∞`.*

**Proof.** The key computation is that for any singleton indicator `φ_x`:
```
sup_y [w(y) + φ_x(y)] = w(x) + 0 = w(x)
```
since `w(y) + (-∞) = -∞` for all `y ≠ x`. Thus the tropical integral of the
singleton indicator recovers the singleton mass. ∎

## 5. Topological Support

### Definition

For a maxitive measure `μ` on a topological space `X`, the *topological support* is:

```
supp_top(μ) = {x ∈ X | ∀ open U ∋ x, μ(U) ≠ -∞}
```

### Theorem 5.1 (Topological-Discrete Equivalence)

*On a finite discrete space, `supp_top(μ) = supp_discrete(μ)`.*

**Proof.** (⊆) If `x ∈ supp_top(μ)`, then since `{x}` is open in the discrete topology,
we have `μ({x}) ≠ -∞`, so `x ∈ supp_discrete(μ)`.

(⊇) If `x ∈ supp_discrete(μ)` and `U` is any open neighborhood of `x`, then
`{x} ⊆ U`, so by monotonicity `μ({x}) ≤ μ(U)`. Since `μ({x}) ≠ -∞`, we have
`μ(U) ≠ -∞`. ∎

### Clopen Witness Characterization

On finite discrete spaces (where every set is clopen), non-support is witnessed
by clopen sets:

```
x ∉ supp(μ) ↔ ∃ clopen S, x ∈ S ∧ μ(S) = -∞
```

This is the bridge to the Stone-dual theory: on compact totally disconnected spaces,
the clopen algebra replaces the powerset, and the witness characterization extends
via compactness arguments.

## 6. Discussion: Making the Invisible Visible

### For the General Reader

Imagine you have a collection of sensors spread across a city, each measuring the
maximum intensity of some phenomenon (rainfall, noise, pollution). The *maxitive
measure* assigns to each region the maximum reading among all sensors in that region.
The *support* is the set of locations where the sensors actually detect something.

The *tropical kernel mean embedding* is like encoding the sensor network into a
compact "fingerprint." Our main theorem says: if two sensor networks produce the
same fingerprint, they must have identical readings everywhere. Moreover, they
must be detecting the phenomenon in exactly the same locations. The kernel plays
the role of a communication protocol between sensors — if the protocol is rich
enough (a "separating kernel"), the fingerprint uniquely identifies the network.

This is the tropical analogue of a fundamental principle in statistics: the kernel
mean embedding of a probability distribution uniquely identifies the distribution
if the kernel is "universal." Our contribution is to prove this in the max-plus
world, where "addition" is replaced by "taking the maximum" — a world that arises
naturally in optimization, tropical geometry, and neural network theory.

### Historical Context

The theory of maxitive measures goes back to Shilkret (1971) and was developed
further by Maslov (1987) in the context of idempotent analysis. The connection
to tropical geometry was clarified by Litvinov, Maslov, and Shpiz in the 1990s.

Kernel mean embeddings were introduced by Smola, Gretton, Song, and Schölkopf
(2007) and have become a cornerstone of nonparametric statistics. The question
of when the embedding is injective ("characteristic kernels") was resolved by
Sriperumbudur et al. (2010).

The tropical KME was introduced more recently as an attempt to bring kernel
methods to the max-plus world. Our work provides the first formally verified
identifiability theory for this object.

### Connections to Existing Work

- **Tropical linear algebra** (Butkovič, 2010): Our residuation-based
  reconstruction is closely related to the theory of tropical matrix equations.

- **Possibility measures** (Dubois & Prade, 1988): Maxitive measures are
  exactly possibility measures. Our identifiability theorem applies to
  possibility-theoretic inference.

- **Max-plus neural networks** (Zhang et al., 2018): The tropical KME can be
  viewed as a one-layer max-plus neural network. Our support theorem gives
  geometric guarantees for such networks.

- **Formal verification** (Lean/Mathlib community): This work demonstrates
  that non-trivial results in tropical analysis can be fully machine-checked,
  including the subtle lattice-theoretic and order-theoretic arguments.

## 7. Conclusion

We have established a complete identifiability theory for tropical kernel mean
embeddings of maxitive measures on finite discrete spaces. The key insight is
that the residuation-based reconstruction formula for separating kernels directly
implies both support faithfulness and full measure identifiability. The witness
duality lemma provides a constructive characterization of non-support via
singleton indicators, bridging the analytic and geometric perspectives.

All results are formally verified in Lean 4, providing maximum confidence in
their correctness. The extension to compact zero-dimensional spaces via Stone
duality is a natural next step, requiring only the clopen approximation theory
that our discrete framework is designed to support.

## References

1. Butkovič, P. (2010). *Max-linear systems: Theory and algorithms*. Springer.

2. Dubois, D., & Prade, H. (1988). *Possibility theory*. Plenum Press.

3. Gretton, A., Borgwardt, K. M., Rasch, M. J., Schölkopf, B., & Smola, A. (2012).
   A kernel two-sample test. *JMLR*, 13, 723-773.

4. Litvinov, G. L., Maslov, V. P., & Shpiz, G. B. (2001). Idempotent functional
   analysis: An algebraic approach. *Mathematical Notes*, 69, 696-729.

5. Shilkret, N. (1971). Maxitive measure and integration. *Indag. Math.*, 33, 109-116.

6. Singer, I. (1997). *Abstract convex analysis*. Wiley.

7. Sriperumbudur, B. K., Gretton, A., Fukumizu, K., Schölkopf, B., & Lanckriet, G. R. G.
   (2010). Hilbert space embeddings and metrics on probability measures. *JMLR*, 11,
   1517-1561.
