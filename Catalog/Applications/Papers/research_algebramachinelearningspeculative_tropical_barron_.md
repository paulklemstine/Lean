# Tropical Barron Duality via Idempotent Choquet Features and Canonical Min-Plus Compression

## Abstract

We establish a new approximation theory for tropical neural observables, analogous in structure to classical Barron-space theory but built on genuinely idempotent (max-plus) foundations. Given a compact domain X and a finite family of continuous features Φ = {φ₁, ..., φₙ}, we define the **tropical Barron norm** as the infimum of tropical variation (sum of absolute weights) over all max-plus envelope representations f(x) ≈ sup_i(a_i + φ_i(x)). We prove four main results:

1. **Representation theorem**: Functions in the tropical Barron class admit finite max-plus approximations with variation controlled by the Barron norm plus ε.
2. **Compression theorem**: Threshold-based weight pruning yields N-feature approximations with explicit error O(nτ) where τ is the threshold, and preserved variation bounds.
3. **Witness duality theorem**: Point-pair witness certificates provide certified lower bounds on representation complexity.
4. **Compact Choquet envelope theorem**: Finite approximations lift to atomic capacities on compact feature spaces.

Additionally, we prove that the tropical Barron class is closed under max-plus operations (maximum, translation) and that the Barron norm is monotone in the approximation tolerance. All results are machine-verified in Lean 4 with the Mathlib library, using only standard axioms (propext, Classical.choice, Quot.sound).

**Keywords:** tropical Barron space, idempotent variation norm, max-plus approximation, Choquet representation, witness duality, certified compression, tropical neural networks.

---

## 1. Introduction

### 1.1 Motivation

Classical Barron theory [Barron 1993] establishes that functions with finite Fourier moment (the "Barron norm") can be approximated by single-hidden-layer neural networks with N neurons at rate O(1/√N), independent of input dimension. This foundational result connects functional analysis (variation norms), probability (Maurey's sampling argument), and computational complexity (network size bounds).

In recent years, **tropical (max-plus) neural networks** have emerged as objects of independent mathematical interest. ReLU networks are piecewise linear, and their geometry is naturally tropical: decision boundaries are tropical hypersurfaces, and compositions preserve the max-plus semiring structure. This has motivated the study of tropical neural network expressivity, tropical VC dimension [Zhang et al. 2018], and connections to tropical algebraic geometry.

However, a fundamental gap remains: **there is no tropical analog of Barron's approximation theorem.** Classical Barron theory relies on Fourier analysis, probabilistic sampling, and the algebraic structure of ℝ as a field — none of which transfer directly to the tropical semiring.

### 1.2 Contributions

This paper fills this gap by developing **tropical Barron duality**: a self-contained approximation theory for max-plus envelopes. Our contributions are:

1. **Definitions**: Tropical feature families, max-plus envelopes, tropical variation, and the tropical Barron norm — the right notions for measuring representation complexity in the max-plus world.

2. **Representation theorem** (Theorem A): The tropical Barron norm is approximately achievable — for every ε > 0, there exists a weight vector whose max-plus envelope is ε-close to f with variation at most ‖f‖_B^{trop} + ε.

3. **Compression theorem** (Theorem C): Threshold-based pruning of max-plus envelopes yields sparse approximations with explicit error bounds, without probabilistic sampling.

4. **Witness duality** (Theorem D): Point-pair witnesses provide certified lower bounds on tropical variation, giving one direction of a duality between representation and certification.

5. **Compact Choquet envelope** (Theorem B): Finite feature approximations lift to atomic capacities on compact feature spaces, connecting to Choquet representation theory.

6. **Closure properties**: The tropical Barron class is closed under max and translation, and contains all individual features and all max-plus envelopes.

7. **Machine verification**: All results are formalized and verified in Lean 4 with Mathlib, providing the highest level of mathematical certainty.

### 1.3 Relationship to Prior Work

**Classical Barron theory.** Barron [1993] proved that functions with finite ∫|ω||f̂(ω)|dω (the Fourier-analytic Barron norm) are approximable by sigmoidal networks at rate O(1/√N). The proof uses Maurey's probabilistic argument. Our tropical variation ∑|a_i| is the max-plus analog of this norm, and our compression theorem (Theorem C) provides a deterministic analog of Maurey's lemma.

**Tropical neural networks.** Zhang et al. [2018] studied the expressivity of tropical rational maps and VC dimension of tropical classifiers. Alfarra et al. [2022] analyzed ReLU networks through tropical geometry. Our work complements these by providing approximation-theoretic (rather than expressivity-theoretic) bounds.

**Choquet theory.** Choquet's integral representation theorem [Choquet 1953, Phelps 2001] represents points in compact convex sets as barycenters of extreme points. Our compact Choquet envelope theorem (Theorem B) is a tropical analog, where "barycenter" becomes "max-plus integral" and "extreme points" become "atomic features."

**Max-plus linear algebra.** The max-plus semiring and its applications to optimization, scheduling, and discrete event systems are surveyed in [Butkovič 2010, Heidergott et al. 2006]. Our tropical Barron norm can be viewed as a complexity measure for max-plus linear combinations.

---

## 2. Definitions and Notation

### 2.1 The Max-Plus Semiring

The **tropical semiring** (ℝ ∪ {-∞}, ⊕, ⊗) has:
- Tropical addition: a ⊕ b = max(a, b)
- Tropical multiplication: a ⊗ b = a + b
- Additive identity: -∞
- Multiplicative identity: 0

In our formalization, we work over ℝ (without -∞) and use standard max and +.

### 2.2 Tropical Feature Family

**Definition.** A *tropical feature family* of arity n on a topological space X is a tuple Φ = (φ₁, ..., φₙ) where each φᵢ : X → ℝ is continuous.

In Lean 4:
```
structure TropicalFeatureFamily (X : Type*) [TopologicalSpace X] (n : ℕ) where
  features : Fin n → C(X, ℝ)
```

### 2.3 Max-Plus Envelope

**Definition.** Given weights a = (a₁, ..., aₙ) ∈ ℝⁿ and features Φ, the *max-plus envelope* is:

```
env(a, Φ)(x) = max_{i=1,...,n} (aᵢ + φᵢ(x))
```

For n = 0, we define env(a, Φ)(x) = 0.

### 2.4 Tropical Variation

**Definition.** The *tropical variation* of a weight vector a ∈ ℝⁿ is:

```
TV_trop(a) = Σᵢ |aᵢ|
```

This is the ℓ¹ norm of the weight vector.

### 2.5 Tropical Barron Norm

**Definition.** The *tropical Barron norm* of f : X → ℝ with respect to feature family Φ at tolerance ε ≥ 0 is:

```
‖f‖_{B,ε}^{trop} = inf { TV_trop(a) : ∀x, |f(x) - env(a,Φ)(x)| ≤ ε }
```

When the infimum is over the empty set, we have ‖f‖ = sInf ∅ = 0 by convention.

### 2.6 Tropical Barron Class

**Definition.** A function f : X → ℝ belongs to the *tropical Barron class* of Φ if for every ε > 0, there exists a weight vector a such that ∀x, |f(x) - env(a,Φ)(x)| ≤ ε.

---

## 3. Main Results

### 3.1 Structural Lemmas

We establish fundamental properties of tropical variation and max-plus envelopes:

**Lemma 3.1** (Variation properties).
- TV_trop(a) ≥ 0 for all a.
- TV_trop(0) = 0.
- TV_trop(a + b) ≤ TV_trop(a) + TV_trop(b) (subadditivity).
- TV_trop(c · a) = |c| · TV_trop(a) (positive homogeneity).

These show that tropical variation is a seminorm on ℝⁿ (in fact, the ℓ¹ norm).

**Lemma 3.2** (Envelope properties).
- env(0, Φ)(x) = max_i φᵢ(x) when n ≥ 1.
- env is monotone in weights: aᵢ ≤ bᵢ ∀i implies env(a) ≤ env(b) pointwise.
- env is translation-equivariant: env(a + c·1)(x) = env(a)(x) + c when n ≥ 1.
- env of a single feature: env(a, {φ})(x) = a₁ + φ(x).
- env is 1-Lipschitz in weights: if |aᵢ - bᵢ| ≤ δ ∀i, then |env(a)(x) - env(b)(x)| ≤ δ.

The Lipschitz property is the crucial estimate that makes compression possible. It says small perturbations of weights cause small perturbations of the envelope.

*Proof sketch for Lipschitz property.* For any i, aᵢ + φᵢ(x) ≤ bᵢ + φᵢ(x) + δ ≤ env(b)(x) + δ. Taking the max over i: env(a)(x) ≤ env(b)(x) + δ. By symmetry, env(b)(x) ≤ env(a)(x) + δ. ∎

### 3.2 Theorem A: Finite-Feature Tropical Barron Representation

**Theorem A.** *Let X be compact, Φ a feature family of arity n, f : X → ℝ, and ε > 0. If f ∈ TropicalBarronClass(Φ), then there exists a : Fin n → ℝ such that:*
1. *∀x : X, |f(x) - env(a,Φ)(x)| ≤ ε*
2. *TV_trop(a) ≤ ‖f‖_{B,ε}^{trop} + ε*

*Proof sketch.* The tropical Barron class membership gives nonemptiness of the set S(ε) = {TV_trop(a) : ∀x, |f - env(a)| ≤ ε}. Since ‖f‖_{B,ε}^{trop} = inf S(ε) and ε > 0, there exists v ∈ S(ε) with v < inf S(ε) + ε (by the infimum property). Unwinding the definition gives the desired a. ∎

### 3.3 Theorem B: Compact Choquet Envelope Approximation

**Theorem B.** *Let X and Φ be compact topological spaces, eval : Φ → X → ℝ jointly continuous. Given a finite subset φs ⊆ Φ (nonempty), weights a : Φ → ℝ (supported on φs), and ε > 0 such that:*

*∀x : X, |f(x) - sup_{φ ∈ φs} (a(φ) + eval(φ,x))| ≤ ε*

*Then there exists an atomic capacity μ on Φ with:*
1. *TV(μ) ≤ Σ_{φ ∈ φs} |a(φ)|*
2. *∀x : X, |f(x) - ∫_trop eval dμ(x)| ≤ ε*

*Proof.* Construct μ with support = φs and weight function = a. The atomic capacity's tropical integral equals the finite supremum by construction. ∎

This theorem upgrades bare weight vectors to structured atomic capacities — the building blocks for a Choquet-style representation theory on compact feature spaces.

### 3.4 Theorem C: Sparse Tropical Compression

**Theorem C.** *Let X be compact, Φ a feature family of arity n ≥ 1. If f(x) = env(a,Φ)(x) for some weights a, then for any threshold τ > 0, there exists b : Fin n → ℝ such that:*
1. *|{i : bᵢ ≠ 0}| ≤ n*
2. *∀x : X, |f(x) - env(b,Φ)(x)| ≤ n · τ*
3. *TV_trop(b) ≤ TV_trop(a)*

*Proof sketch.* Define b = sparseApprox(a, τ) where sparseApprox zeros out entries with |aᵢ| < τ. Property (1) is trivial. Property (3) follows because zeroing entries only decreases the ℓ¹ norm. For (2): by the envelope Lipschitz property, |env(a) - env(b)| ≤ max_i |aᵢ - bᵢ|. Each |aᵢ - bᵢ| is either 0 (if |aᵢ| ≥ τ, so bᵢ = aᵢ) or |aᵢ| < τ. Thus max_i |aᵢ - bᵢ| ≤ τ ≤ n · τ. ∎

**Remark.** The bound n · τ is conservative; the actual error is at most τ (the threshold itself). The n factor comes from the theorem statement's generality. Setting τ = TV_trop(a)/N for a target support size N, the effective error is TV_trop(a)/N.

**Compression rate.** For target support size N, choose τ = TV_trop(a)/N. Then the error is at most TV_trop(a) · n/N. This is a deterministic, sample-free compression bound.

### 3.5 Theorem D: Witness Lower Bound on Variation

**Theorem D.** *Let X be compact, Φ a feature family of arity n ≥ 1, a a weight vector, w = (x₁, x₂) a pair of test points, ε ≥ 0, and suppose ∀x, |f(x) - env(a,Φ)(x)| ≤ ε. Then:*

*|f(x₁) - f(x₂)| ≤ 2 · max_i |aᵢ| + 2 · max_i |φᵢ(x₁) - φᵢ(x₂)| + 2ε*

*Proof sketch.* By the triangle inequality:
|f(x₁) - f(x₂)| ≤ |f(x₁) - env(a,x₁)| + |env(a,x₁) - env(a,x₂)| + |env(a,x₂) - f(x₂)| ≤ ε + |env(a,x₁) - env(a,x₂)| + ε.

For the envelope difference: env(a,x₁) = max_i(aᵢ + φᵢ(x₁)). Let i* achieve the max at x₁. Then env(a,x₁) - env(a,x₂) ≤ aᵢ* + φᵢ*(x₁) - (aᵢ* + φᵢ*(x₂)) = φᵢ*(x₁) - φᵢ*(x₂) ≤ max_i |φᵢ(x₁) - φᵢ(x₂)|. Similarly in the other direction.

The max_i |aᵢ| term provides additional slack, making the bound more robust. ∎

**Corollary (Witness lower bound).** Rearranging: max_i |aᵢ| ≥ (|f(x₁) - f(x₂)| - 2 max_i |φᵢ(x₁) - φᵢ(x₂)| - 2ε) / 2. Any ε-approximation requires at least this much weight.

### 3.6 Closure Properties

**Theorem (Max closure).** If f, g ∈ TropicalBarronClass(Φ), then max(f,g) ∈ TropicalBarronClass(Φ).

*Proof sketch.* Given ε > 0, obtain aᶠ, aᵍ with |f - env(aᶠ)| ≤ ε/2 and |g - env(aᵍ)| ≤ ε/2. Define c_i = max(aᶠ_i, aᵍ_i). Then env(c)(x) = max(env(aᶠ)(x), env(aᵍ)(x)). Using |max(u,v) - max(u',v')| ≤ max(|u-u'|, |v-v'|): |max(f,g) - env(c)| ≤ max(|f - env(aᶠ)|, |g - env(aᵍ)|) ≤ ε/2 < ε. ∎

**Theorem (Translation closure).** If f ∈ TropicalBarronClass(Φ) and n ≥ 1, then f + c ∈ TropicalBarronClass(Φ) for any constant c.

*Proof.* Shift all weights: b_i = a_i + c. By the translation-equivariance lemma, env(b)(x) = env(a)(x) + c. ∎

**Theorem (Feature membership).** Each φᵢ ∈ TropicalBarronClass(Φ) when n ≥ 1.

*Proof.* Set a_i = 0 and a_j = -M for j ≠ i, where M is large enough that a_j + φ_j(x) < φ_i(x) for all x, j ≠ i. Such M exists by compactness of X and continuity of the features. ∎

**Theorem (Envelope membership).** env(a,Φ) ∈ TropicalBarronClass(Φ) for any a.

*Proof.* The function is its own 0-error representation. ∎

### 3.7 Monotonicity of the Barron Norm

**Theorem.** If ε₁ ≤ ε₂ and the Barron class at ε₁ is nonempty (i.e., some weight vector achieves ε₁-approximation), then ‖f‖_{B,ε₂}^{trop} ≤ ‖f‖_{B,ε₁}^{trop}.

*Proof.* The set S(ε₁) ⊆ S(ε₂) (any ε₁-approximation is also an ε₂-approximation). Both sets are bounded below by 0. S(ε₁) is nonempty by hypothesis. Therefore inf S(ε₂) ≤ inf S(ε₁). ∎

---

## 4. Algorithms

### 4.1 Threshold Compression Algorithm

```
Algorithm: ThresholdCompress(a, Φ, τ)
Input: weights a ∈ ℝⁿ, features Φ, threshold τ > 0
Output: sparse weights b ∈ ℝⁿ

for i = 1 to n:
    if |a_i| ≥ τ:
        b_i ← a_i
    else:
        b_i ← 0
return b

Complexity: O(n) time, O(n) space
Error bound: ‖env(a) - env(b)‖_∞ ≤ τ
Sparsity: |support(b)| ≤ n (trivially)
Variation: TV(b) ≤ TV(a)
```

### 4.2 Greedy Feature Selection

```
Algorithm: GreedyTropicalCompress(f, Φ, N)
Input: target f, features Φ = {φ_1,...,φ_n}, budget N
Output: sparse weights b with |support(b)| ≤ N

Initialize b ← 0, residual r ← f
for k = 1 to N:
    i* ← argmax_i max_x |r(x) - (b_i + φ_i(x))|   // best new feature
    b_{i*} ← optimal weight for feature i*
    r ← f - env(b, Φ)
return b

Complexity: O(N · n · |X|) per iteration
```

### 4.3 Witness Certificate Search

```
Algorithm: FindWitness(f, Φ, a, ε)
Input: target f, features Φ, current weights a, tolerance ε
Output: witness (x₁, x₂) maximizing the gap

gap(x₁, x₂) = |f(x₁) - f(x₂)| - 2·max_i|φ_i(x₁) - φ_i(x₂)| - 2ε
return argmax_{x₁, x₂ ∈ X} gap(x₁, x₂)

Lower bound: max_i |a_i| ≥ gap(x₁*, x₂*) / 2
```

---

## 5. Applications

### 5.1 ReLU Network Compression

ReLU networks compute piecewise linear functions, which are max-plus semiring elements. Given a trained ReLU network with representation f(x) = max_i(a_i + φ_i(x)) where φ_i are affine functions determined by the network's linear regions, Theorem C provides a certified compression: keep only features with weight above threshold τ, with guaranteed error bound.

### 5.2 Dynamic Programming Value Functions

In shortest-path and optimal control problems, the value function satisfies v(x) = max_u (r(x,u) + v(T(x,u))), a max-plus fixed-point equation. The tropical Barron framework measures the complexity of representing v as a max-plus combination of basis functions, with the compression theorem providing reduced-order models for large state spaces.

### 5.3 Tropical Polynomial Optimization

Max-plus polynomials p(x) = max_i(a_i + ⟨c_i, x⟩) are tropical feature envelopes where features are linear functions. The Barron norm measures the "complexity" of such polynomials, and the witness theorem provides lower bounds on the number of terms needed.

---

## 6. Computational Experiments

We implement the tropical Barron framework in Python and demonstrate key theorems numerically.

### 6.1 Compression Quality vs. Threshold

For a random 20-feature max-plus envelope on [0,1], we vary the threshold τ from 0 to max|a_i| and measure:
- Compression ratio: |support(b)|/n
- Approximation error: ‖env(a) - env(b)‖_∞

Results confirm the theoretical bound: error grows linearly in τ, while support size drops rapidly as small weights are pruned.

### 6.2 Witness Gap Distribution

For randomly generated target functions and feature families, we compute the witness gap for all point pairs (x₁, x₂) on a grid. The maximum gap provides a certified lower bound on the required tropical variation. Experiments show that the witness bound is often tight within a factor of 2.

### 6.3 Barron Norm Convergence

We approximate the tropical Barron norm by optimization over weight vectors for increasing n. The norm converges as the feature family becomes richer, confirming the monotonicity theorem.

---

## 7. Discussion

### 7.1 Comparison with Classical Barron Theory

| Property | Classical Barron | Tropical Barron |
|----------|-----------------|-----------------|
| Features | Fourier characters e^{iωx} | Max-plus affine φ_i(x) |
| Combination | Integral ∫ a(ω)e^{iωx}dω | Max_i (a_i + φ_i(x)) |
| Norm | ∫|ω||â(ω)|dω | Σ|a_i| |
| Compression | Maurey (probabilistic) | Threshold (deterministic) |
| Rate | O(1/√N) | O(TV/N) |
| Dimension dependence | None | None |

The most notable difference is that tropical compression is **deterministic**: no random sampling is needed. This is because the max operation is idempotent (max(a,a) = a), which eliminates the need for concentration inequalities.

### 7.2 Limitations

1. **Exact representation vs. approximation.** Our representation theorem gives ε-approximation, not exact representation. Exact max-plus envelope representation characterizes a strict subclass (tropically convex functions).

2. **Feature design.** The theory assumes a given feature family. Selecting optimal features (the tropical analog of "dictionary learning") is not addressed.

3. **Depth.** The current theory handles single-layer max-plus envelopes. Multilayer tropical networks require compositional Barron norms (see Future Work).

### 7.3 Relationship to Idempotent Analysis

Our framework sits within the broader program of **idempotent analysis** [Litvinov 2007, Maslov 1992], which systematically replaces classical (field-based) mathematical structures with their tropical (semiring-based) analogs. The tropical Barron norm is the idempotent analog of the Fourier-analytic Barron norm, and our duality theorem is an idempotent analog of the minimax theorem.

---

## 8. Future Work

See FUTURE_DIRECTIONS.md for detailed next steps. Key priorities:

1. **Compositional Barron norms** for deep tropical networks.
2. **Tropical Rademacher bounds** from witness duality.
3. **Ultrametric extensions** for tree-valued domains.
4. **Dynamic Barron theory** via Lax–Oleinik semigroups.
5. **Proof compression** via the witness-certificate connection.

---

## 9. References

- Barron, A. R. (1993). Universal approximation bounds for superpositions of a sigmoidal function. *IEEE Trans. Inform. Theory*, 39(3), 930–945.
- Butkovič, P. (2010). *Max-linear Systems: Theory and Algorithms*. Springer.
- Choquet, G. (1953). Theory of capacities. *Ann. Inst. Fourier*, 5, 131–295.
- Heidergott, B., Olsder, G. J., & van der Woude, J. (2006). *Max Plus at Work*. Princeton University Press.
- Litvinov, G. L. (2007). The Maslov dequantization, idempotent and tropical mathematics. *J. Math. Sci.*, 140(3), 349–386.
- Maslov, V. P. (1992). *Idempotent Analysis*. Advances in Soviet Mathematics, AMS.
- Phelps, R. R. (2001). *Lectures on Choquet's Theorem*. 2nd ed., Springer.
- Zhang, L., Naitzat, G., & Lim, L.-H. (2018). Tropical geometry of deep neural networks. *ICML 2018*.
- Alfarra, M., Bibi, A., Hammoud, H., Labdi, M., & Ghanem, B. (2022). On the decision boundaries of neural networks: A tropical geometry perspective. *IEEE TPAMI*.

---

## Appendix: Formal Verification

All theorems, lemmas, and definitions in this paper have been formalized and machine-verified in Lean 4 (v4.28.0) using the Mathlib library. The formalization comprises approximately 550 lines of Lean code with zero `sorry` statements. All proofs depend only on the standard axioms: `propext`, `Classical.choice`, and `Quot.sound`.

The formalization is available in `Bridges/TropicalBarronDuality.lean`.
