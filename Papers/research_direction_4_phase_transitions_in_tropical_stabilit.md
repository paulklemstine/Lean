# A Deterministic Threshold Theory for Tropical Lorentzian Stability and Its Random-Matrix Phase Transition

## Abstract

We introduce the **tropical margin** — the minimum diagonal exchange slack over distinct index pairs — as a scalar order parameter for tropical Lorentzian stability of symmetric matrices. We prove five deterministic theorems: (1) the margin equals twice the diagonal bias; (2) the margin is 4-Lipschitz in the entry sup-norm; (3) a signal/noise decomposition yields a sharp finite-dimensional threshold criterion; (4) the mean model's margin is exactly 2(μ_off − μ_diag); (5) the margin is monotone under the ferromagnetic ordering. Together these results establish the tropical margin as a genuine order parameter with all the hallmarks of a phase-transition observable: Lipschitz continuity, monotone response, exact computability on structured models, and a certified perturbation theory. We conjecture that for Gaussian random matrices the probability of positive margin undergoes a sharp phase transition at the scale σ√(log n) and present Monte Carlo evidence supporting finite-size scaling collapse.

## 1. Introduction

### 1.1 Motivation

The theory of Lorentzian polynomials, introduced by Brändén and Huh [1], establishes deep connections between log-concavity, negative dependence, and tropical geometry through exchange inequalities on coefficient exponents. A natural question is: *how robust are these exchange conditions under random perturbations?*

This paper initiates an average-case theory of tropical Lorentzian certification by identifying the tropical margin as the right order parameter, proving deterministic perturbation theorems, and using them to predict a sharp phase transition in Gaussian random matrix ensembles.

### 1.2 Relationship to Prior Work

Our starting point is the catalog of results in `TropicalLorentzianShadows.lean`, which establishes:
- The diagonal exchange slack `diagExchangeSlack(w, i, j) = 2w(i,j) − w(i,i) − w(j,j)` as the fundamental local certificate for 2×2 Lorentzian minor conditions.
- Lipschitz stability of the exchange slack under weight perturbations (`exchange_slack_lipschitz`).
- Exact computation for uniform weight families (`tropical_gap_eq_uniform`).
- The tropical spectral gap as an infimum over distinct-pair exchange slacks.

We build on this foundation by:
1. Reformulating the theory for plain symmetric matrices (rather than `TropicalQuadraticWeight` structures).
2. Introducing the entry sup-norm perturbation framework.
3. Proving global Lipschitz stability of the minimum (not just pointwise).
4. Establishing monotonicity under the ferromagnetic ordering.
5. Computing exact margins for the mean model and deriving certified stability bounds.

### 1.3 Contributions

1. **New definitions**: `exSlack`, `diagBias`, `tropMargin`, `meanModel`, `OffDiagMonotoneLe`, `entrySupNorm`.
2. **Five formally verified theorems** (all proved in Lean 4 with no `sorry`):
   - `tropMargin_eq_two_diagBias`
   - `tropMargin_lipschitz`
   - `tropMargin_lower_bound_signal_noise` and `tropMargin_pos_of_signal_noise`
   - `tropMargin_meanModel`
   - `tropMargin_mono_offdiag`
3. **A certified stability estimator** combining the mean model computation with the perturbation bound.
4. **A falsifiable conjecture** on finite-size scaling collapse with a computational disproof protocol.
5. **Monte Carlo experiments** supporting the conjecture.

## 2. Definitions and Notation

### 2.1 Exchange Slack

For a matrix W ∈ ℝ^{n×n} and indices i, j, k, l ∈ {0, …, n−1}:

**exSlack(W; i, j, k, l) = W(i,j) + W(k,l) − W(i,k) − W(j,l)**

This is the four-point exchange inequality deficit. When W encodes log-coefficients of a quadratic form, nonnegativity of the exchange slack is the tropical Lorentzian condition.

### 2.2 Diagonal Exchange Slack

**diagExSlack(W, i, j) = 2·W(i,j) − W(i,i) − W(j,j)**

This is the special case exSlack(W; i, j, i, j). It measures how much the off-diagonal entry exceeds the average of the corresponding diagonal entries.

### 2.3 Diagonal Bias

**diagBias(W) = min_{i≠j} [W(i,j) − (W(i,i) + W(j,j))/2]**

The worst-case deficit of off-diagonal entries relative to diagonal half-sums.

### 2.4 Tropical Margin

**tropMargin(W) = min_{i≠j} diagExSlack(W, i, j) = min_{i≠j} [2·W(i,j) − W(i,i) − W(j,j)]**

This is the central order parameter. By construction, tropMargin(W) = 2·diagBias(W).

### 2.5 Entry Sup-Norm

**entrySupNorm(W) = max_{i,j} |W(i,j)|**

### 2.6 Mean Model

For parameters μ_diag, μ_off ∈ ℝ:

**meanModel(n, μ_diag, μ_off)(i,j) = μ_diag if i=j, μ_off if i≠j**

### 2.7 Ferromagnetic Ordering

**OffDiagMonotoneLe(W, W') ⟺ (∀i: W'(i,i) ≤ W(i,i)) ∧ (∀i≠j: W(i,j) ≤ W'(i,j))**

W' is "more off-diagonal" than W: cross-interactions increase, self-interactions decrease.

## 3. Main Results

### 3.1 Theorem 1: Margin–Bias Identity

**Theorem** (tropMargin_eq_two_diagBias). *For n ≥ 2 and any W ∈ ℝ^{n×n}:*
$$\operatorname{tropMargin}(W) = 2 \cdot \operatorname{diagBias}(W).$$

*Proof sketch.* Both quantities are defined as the infimum of the same finite set of values, related by a factor of 2. Specifically, diagExSlack(W, i, j) = 2·(W(i,j) − (W(i,i)+W(j,j))/2), so the infimum over distinct pairs scales by exactly 2. The formal proof uses the linearity of scalar multiplication through finite infima (`Finset.inf'`). □

### 3.2 Theorem 2: Lipschitz Stability

**Theorem** (tropMargin_lipschitz). *For n ≥ 2 and W, W' ∈ ℝ^{n×n}:*
$$|\operatorname{tropMargin}(W) - \operatorname{tropMargin}(W')| \leq 4 \cdot \operatorname{entrySupNorm}(W - W').$$

*Proof sketch.* First establish the pointwise bound: for each pair (i,j),

|diagExSlack(W,i,j) − diagExSlack(W',i,j)| = |2(W−W')(i,j) − (W−W')(i,i) − (W−W')(j,j)|
≤ 2·|D(i,j)| + |D(i,i)| + |D(j,j)| ≤ 4·entrySupNorm(D)

where D = W − W'. Then apply the standard finite-minimum perturbation argument: the infimum of f is at most the infimum of g plus the pointwise supremum of |f − g|. Formally, use `Finset.inf'_mem` to extract witnesses and combine with the pointwise bound. □

**Remark.** The Lipschitz constant 4 is tight: consider n = 2, W diagonal, and perturb only the off-diagonal entry by ε. Then tropMargin changes by 2·2ε = 4ε.

### 3.3 Theorem 3: Signal/Noise Decomposition

**Theorem** (tropMargin_lower_bound_signal_noise). *For n ≥ 2:*
$$\operatorname{tropMargin}(S) - 4 \cdot \operatorname{entrySupNorm}(N) \leq \operatorname{tropMargin}(S + N).$$

**Corollary** (tropMargin_pos_of_signal_noise). *If 4·entrySupNorm(N) < tropMargin(S), then tropMargin(S+N) > 0.*

*Proof sketch.* Apply Theorem 2 with W = S and W' = S + N. Then S − (S+N) = −N, so entrySupNorm(S − (S+N)) = entrySupNorm(N). The one-sided inequality gives the result. □

**Significance.** This is the deterministic skeleton of the phase transition. In a random model where N has independent Gaussian entries with variance σ², the entry sup-norm satisfies

entrySupNorm(N) ≈ σ·√(2 log n²) = σ·√(4 log n)

with high probability. Setting S = meanModel(n, μ_diag, μ_off), the certified stability condition becomes:

2(μ_off − μ_diag) > 4σ·√(4 log n) = 8σ·√(log n)

which predicts the √(log n) scaling of the phase transition.

### 3.4 Theorem 4: Mean Model Computation

**Theorem** (tropMargin_meanModel). *For n ≥ 2:*
$$\operatorname{tropMargin}(\operatorname{meanModel}(n, \mu_d, \mu_o)) = 2(\mu_o - \mu_d).$$

*Proof sketch.* For each distinct pair (i,j), diagExSlack(meanModel, i, j) = 2μ_off − μ_diag − μ_diag = 2(μ_off − μ_diag). Since all terms are equal, the infimum equals this common value. □

### 3.5 Theorem 5: Ferromagnetic Monotonicity

**Theorem** (tropMargin_mono_offdiag). *If OffDiagMonotoneLe(W, W'), then tropMargin(W) ≤ tropMargin(W').*

*Proof sketch.* For each distinct pair (i,j), OffDiagMonotoneLe implies W'(i,j) ≥ W(i,j) (off-diagonal increases) and W'(i,i) ≤ W(i,i), W'(j,j) ≤ W(j,j) (diagonal decreases). Hence diagExSlack(W',i,j) ≥ diagExSlack(W,i,j). Since this holds for all pairs, the minimum over W' is at least the minimum over W. □

**Cross-domain significance.** This monotonicity is the tropical analogue of the FKG inequality in statistical mechanics. The tropical margin is a monotone increasing function of the "field strength" (off-diagonal coupling), making it a genuine order parameter in the sense of Landau theory.

### 3.6 Certified Stability Estimator

**Theorem** (certified_stability_bound). *For n ≥ 2, if entrySupNorm(N) ≤ ε, then:*
$$\operatorname{tropMargin}(\operatorname{meanModel}(n, \mu_d, \mu_o) + N) \geq 2(\mu_o - \mu_d) - 4\varepsilon.$$

This combines Theorems 3 and 4 into a single practical certificate.

### 3.7 Witness Extraction

**Theorem** (tropMargin_witness). *For n ≥ 2, there exist distinct i, j such that tropMargin(W) = diagExSlack(W, i, j).*

This is the *certificate extraction* theorem: the infimum is attained, and the achieving pair serves as a verifiable witness.

## 4. Algorithms

### 4.1 Tropical Margin Computation

```
Algorithm: ComputeTropMargin(W)
Input: n×n matrix W
Output: (margin, witness_pair)

margin ← +∞
witness ← (0, 1)
for i = 0 to n−1:
    for j = 0 to n−1:
        if i ≠ j:
            s ← 2·W[i,j] − W[i,i] − W[j,j]
            if s < margin:
                margin ← s
                witness ← (i, j)
return (margin, witness)
```

**Complexity:** O(n²) time, O(1) space (beyond the input matrix).

**Soundness:** Follows from Theorem 3.7 — the algorithm's output equals the mathematical definition.

### 4.2 Certified Stability Estimation

```
Algorithm: CertifiedStability(μ_diag, μ_off, ε)
Input: Mean parameters and noise bound
Output: Certified lower bound on tropMargin(meanModel + N)

return 2·(μ_off − μ_diag) − 4·ε
```

**Soundness:** Follows from Theorem 3.6.

## 5. Computational Experiments

### 5.1 Phase Transition Curves

We generated symmetric Gaussian random matrices with n ∈ {5, 10, 20}, σ = 1, and varying μ_off (with μ_diag = 0). For each parameter setting, 2000 samples were drawn, and P(tropMargin ≥ 0) was estimated.

When plotted against the scaled parameter x = (μ_off − μ_diag)/(σ√(log n)), the curves for different n show approximate collapse, supporting the finite-size scaling conjecture. The transition steepens with increasing n.

### 5.2 Lipschitz Bound Verification

300 random perturbations of a base matrix were generated, and |ΔtropMargin| was plotted against 4·‖ΔW‖∞. All points lie below the diagonal, confirming the Lipschitz constant of 4.

### 5.3 Mean Model Verification

tropMargin(meanModel(n, μ_d, μ_o)) = 2(μ_o − μ_d) was verified computationally for n ∈ {3, 5, 10, 20} and multiple parameter combinations.

### 5.4 Monotonicity Verification

100 random instances of the ferromagnetic perturbation were tested: in all cases, tropMargin(W') ≥ tropMargin(W), confirming the monotonicity theorem.

## 6. Conjectures

### 6.1 Main Conjecture: Finite-Size Scaling Collapse

Let W ~ G(n, μ_diag, μ_off, σ) be a symmetric Gaussian ensemble. There exists a universal constant c > 0 and a nontrivial profile Φ: ℝ → [0,1] such that

P(tropMargin(W) ≥ 0) ≈ Φ((μ_off − μ_diag)/(σ√(log n)) − c)

uniformly for moderate n, with convergence to a step function as n → ∞.

**Computational disproof protocol:** For n ∈ {5, 10, 20, 50}, sample 10,000 matrices per parameter value. Plot P(tropMargin ≥ 0) vs (μ_off − μ_diag)/(σ√(log n)). If the curves fail to collapse after horizontal translation/scaling, the conjecture is false.

### 6.2 Stronger Conjecture: Extremal Pair Sparsity

With high probability in the critical window, the minimizing pair for tropMargin is asymptotically unique and does not depend on n. This "defect localization" would connect to disordered systems.

## 7. Discussion

### 7.1 Implications

The tropical margin provides the first scalar certificate for tropical Lorentzian stability that is simultaneously:
- **Exact** on structured models (Theorem 4).
- **Lipschitz-stable** under arbitrary perturbations (Theorem 2).
- **Monotone** under the natural physical ordering (Theorem 5).
- **Efficiently computable** with witness extraction (Algorithm 4.1).

This combination of properties is precisely what is needed for a phase-transition theory: the order parameter must vary smoothly, respond monotonically to control parameters, and be computable.

### 7.2 Limitations

1. The Lipschitz constant 4 may not be the tightest possible for the minimum over all pairs (as opposed to a single pair).
2. The certified stability bound is conservative: it uses the worst-case noise sup-norm rather than the typical behavior.
3. The conjectured √(log n) scaling is supported by Monte Carlo but not yet proved.

### 7.3 Connection to Catalog

The results in this paper extend the catalog's `TropicalLorentzianShadows.lean` in the following ways:
- The catalog's `exchange_slack_lipschitz` gives pointwise stability; we extend to global minimum stability.
- The catalog's `tropical_gap_eq_uniform` computes the gap for uniform weights; we compute for the more general mean model.
- The catalog's `TropicalQuadraticWeight` structure is replaced by plain matrices, making the theory more directly applicable.

## 8. Future Work

1. Prove the √(log n) scaling conjecture rigorously using concentration inequalities for Gaussian maxima.
2. Extend to non-Gaussian ensembles using the Lipschitz framework and universality arguments.
3. Study defect localization: does the minimizing pair concentrate as n → ∞?
4. Connect the tropical margin to spectral properties (eigenvalue gaps) of the matrix exponential.
5. Apply to random feature kernel matrices in machine learning.

## References

[1] P. Brändén and J. Huh, "Lorentzian Polynomials," *Annals of Mathematics*, 2020.

[2] D. Maclagan and B. Sturmfels, *Introduction to Tropical Geometry*, AMS, 2015.

[3] M. Ledoux and M. Talagrand, *Probability in Banach Spaces*, Springer, 1991.

[4] S. Boucheron, G. Lugosi, and P. Massart, *Concentration Inequalities*, Oxford University Press, 2013.

[5] M. Talagrand, *Upper and Lower Bounds for Stochastic Processes*, Springer, 2014.
