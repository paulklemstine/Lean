# Spectral Contraction Theory for Collatz Parity Words

## Abstract

We develop a rigorous spectral-theoretic framework connecting the binary parity encoding of Collatz orbits to contraction dynamics via Fourier analysis. The central object is the **contraction exponent** ξ(k,s) = k·log(2) − s·log(3), where k is the orbit length and s is the count of odd steps. We prove a biconditional theorem: the ones-density s/k falls below the critical threshold log(2)/log(3) ≈ 0.6309 if and only if ξ(k,s) > 0 (orbit contraction). Reformulating via the Discrete Fourier Transform, we show that the DC spectral energy (squared ones-density) falling below (log 2/log 3)² ≈ 0.3981 is equivalent to positive contraction. The fundamental arithmetic inequality log(3) < 2·log(2) ensures that even 50% ones-density yields contraction, establishing a built-in bias toward orbit shrinkage. All results are formally verified in Lean 4 with the Mathlib library.

**Keywords**: Collatz conjecture, spectral analysis, parity word, contraction exponent, Fourier analysis, formal verification

## 1. Introduction

The Collatz map T: ℕ → ℕ defined by T(n) = n/2 for even n, T(n) = (3n+1)/2 for odd n, generates orbits whose eventual convergence to 1 is the content of the celebrated Collatz conjecture. Despite extensive computational verification (all n ≤ 2^68 by Barina, 2021) and partial theoretical results (Tao, 2019), a complete proof remains elusive.

A fruitful approach encodes Collatz orbits via **parity words**: given a starting value n, the orbit n, T(n), T²(n), ... generates a binary sequence w ∈ {0,1}^k where w_i = 1 if T^i(n) is odd and w_i = 0 otherwise. The parity word captures the essential branching structure of the orbit.

The multiplicative effect of k Collatz steps with s odd steps is 3^s / 2^k. The orbit contracts when this factor is less than 1, i.e., when s·log(3) < k·log(2). This motivates the **contraction exponent** ξ(k,s) = k·log(2) − s·log(3) and the **critical density** ρ* = log(2)/log(3) ≈ 0.6309.

Our main contributions are:
1. A formally verified proof of the biconditional: ones-density < ρ* ⟺ ξ(k,s) > 0.
2. A spectral reformulation: DC spectral energy < (ρ*)² ⟺ ξ(k,s) > 0.
3. The proof that ρ* > 1/2, establishing inherent contraction bias.
4. Additivity of the contraction exponent under concatenation.
5. A tropical certificate framework for verified contraction.

## 2. Definitions

### 2.1 Contraction Exponent

**Definition 2.1** (Contraction Exponent). For k, s ∈ ℕ, the contraction exponent is
$$\xi(k, s) = k \cdot \log 2 - s \cdot \log 3$$

When ξ(k,s) > 0, an orbit segment with k total steps and s odd steps contracts (the orbit value decreases on average by a factor of 2^k / 3^s > 1).

### 2.2 Ones-Density and Critical Density

**Definition 2.2** (Ones-Density). The ones-density of a parity word with k steps and s odd steps is d(k,s) = s/k.

**Definition 2.3** (Critical Density). The critical density is ρ* = log(2)/log(3) ≈ 0.6309.

### 2.3 DC Spectral Energy

**Definition 2.4** (DC Spectral Energy). The DC spectral energy of a binary word with parameters (k,s) is E_DC(k,s) = d(k,s)² = (s/k)².

In the Discrete Fourier Transform of the binary parity word w ∈ {0,1}^k, the zero-frequency component is ŵ(0) = (1/k)·Σ w_i = s/k = d(k,s). The DC energy is |ŵ(0)|² = d(k,s)².

### 2.4 ContractionSystem

**Definition 2.5** (ContractionSystem). A ContractionSystem is a tuple (k, s, k > 0, s ≤ k) packaging the contraction data of an orbit segment. It provides the exponent ξ, density d, multiplicative factor 3^s/2^k, and contraction predicate.

### 2.5 Tropical Certificate

**Definition 2.6** (TropicalCertificate). A TropicalCertificate is a ContractionSystem together with a rational upper bound q on the density satisfying q < ρ* and d(k,s) ≤ q. It provides a computationally verifiable proof of contraction.

## 3. Main Results

### 3.1 The Fundamental Contraction Inequality

**Theorem 3.1** (log_three_lt_two_log_two). log(3) < 2·log(2).

*Proof.* Since 3 < 4 = 2², monotonicity of the logarithm gives log(3) < log(4) = 2·log(2). □

**Corollary 3.2** (critical_density_gt_half). ρ* = log(2)/log(3) > 1/2.

*Proof.* ρ* > 1/2 ⟺ 2·log(2) > log(3), which is Theorem 3.1. □

**Corollary 3.3** (critical_density_lt_one). ρ* < 1.

*Proof.* ρ* < 1 ⟺ log(2) < log(3), which follows from 2 < 3. □

The interval (1/2, 1) containing ρ* is the "contraction window": densities in (0, ρ*) yield contraction, while densities in (ρ*, 1) yield expansion. The fact that ρ* > 1/2 means the contraction window is strictly larger than the expansion window.

### 3.2 The Density–Contraction Biconditional

**Theorem 3.4** (density_bound_iff_contraction_positive). For k > 0 and s ≤ k:
$$d(k,s) < \rho^* \iff \xi(k,s) > 0$$

*Proof.* Both sides are equivalent to s·log(3) < k·log(2):
- d(k,s) < ρ* ⟺ s/k < log(2)/log(3) ⟺ s·log(3) < k·log(2) (multiplying by k·log(3) > 0).
- ξ(k,s) > 0 ⟺ k·log(2) − s·log(3) > 0 ⟺ s·log(3) < k·log(2). □

### 3.3 The Spectral–Contraction Biconditional

**Theorem 3.5** (spectral_energy_iff_contraction). For k > 0 and s ≤ k:
$$E_{DC}(k,s) < (\rho^*)^2 \iff \xi(k,s) > 0$$

*Proof.* Since d(k,s) ≥ 0 and ρ* > 0, we have d(k,s)² < (ρ*)² ⟺ d(k,s) < ρ*. Then apply Theorem 3.4. □

This is the formal bridge between spectral analysis and orbit dynamics: **measuring the low-frequency content of the parity word determines whether the orbit contracts.**

### 3.4 Half-Density Contraction

**Theorem 3.6** (half_density_contracts). For k > 0: ξ(2k, k) > 0.

*Proof.* ξ(2k, k) = 2k·log(2) − k·log(3) = k·(2·log(2) − log(3)) > 0, since k > 0 and 2·log(2) − log(3) > 0 by Theorem 3.1. □

This is the mathematical formalization of the "contraction bias": even when exactly half the steps are odd — the most "balanced" scenario — the orbit still contracts.

### 3.5 Multiplicative Factor Characterization

**Theorem 3.7** (contracts_iff_factor_lt_one). A ContractionSystem C contracts if and only if its multiplicative factor 3^s/2^k < 1.

*Proof.* C contracts ⟺ ξ(k,s) > 0 ⟺ s·log(3) < k·log(2) ⟺ log(3^s) < log(2^k) ⟺ 3^s < 2^k ⟺ 3^s/2^k < 1, using monotonicity of log on ℝ₊. □

### 3.6 Additivity and Composition

**Theorem 3.8** (contractionExp_add). ξ(k₁+k₂, s₁+s₂) = ξ(k₁,s₁) + ξ(k₂,s₂).

*Proof.* Direct computation from the definition. □

**Corollary 3.9** (contraction_compose). If ξ(k₁,s₁) > 0 and ξ(k₂,s₂) > 0, then ξ(k₁+k₂, s₁+s₂) > 0.

**Theorem 3.10** (contraction_linear_growth). ξ(m·k₀, m·s₀) = m·ξ(k₀, s₀).

This linearity means that sustained contraction — maintaining low ones-density over consecutive segments — produces exponential orbit decay.

### 3.7 The Parity Balance Decomposition

**Theorem 3.11** (parityBalance_eq_contraction). The contraction exponent admits the decomposition:
$$\xi(k,s) = (k-s) \cdot \log(2) - s \cdot (\log(3) - \log(2))$$

This reveals ξ as a weighted sum: each even step contributes +log(2) ≈ +0.693, and each odd step contributes −(log(3)−log(2)) ≈ −0.405. The asymmetry (+0.693 vs −0.405) is the source of the contraction bias.

**Theorem 3.12** (step_contributions). The step weights satisfy:
1. log(2) > 0 (even steps always help)
2. log(3) − log(2) > 0 (odd steps always hurt)
3. log(2) > log(3) − log(2) (even steps help more than odd steps hurt)

**Theorem 3.13** (positive_drift_at_half). log(2) − (1/2)·log(3) > 0.

This is the per-step drift at half-density, confirming that the "expected" contraction is positive under the balanced distribution.

### 3.8 Gap Characterization

**Theorem 3.14** (contractionExp_eq_gap_times_log3). ξ(k,s) = Δ(k,s)·log(3), where Δ(k,s) = k·ρ* − s is the contraction gap.

The gap Δ measures how far below the critical threshold the ones-count falls. Since log(3) > 0, the sign of ξ equals the sign of Δ.

### 3.9 Tropical Certificates

**Theorem 3.15** (TropicalCertificate.implies_contraction). Any tropical certificate implies contraction of its underlying system.

*Proof.* A certificate provides q ∈ ℚ with d(k,s) ≤ q < ρ*, so d(k,s) < ρ*, and contraction follows from Theorem 3.4. □

The significance of tropical certificates is computational: the density bound q is rational, so the comparison q < ρ* can be verified by rational arithmetic on log approximations. This enables certified finite-state verification of Collatz contraction.

## 4. Algorithms

### 4.1 Contraction Verification Algorithm

```
Input: Positive integer n, step count k
Output: Boolean (contracts or not)

1. Compute orbit T(n), T²(n), ..., T^k(n)
2. Count s = #{i : T^i(n) is odd}
3. Compute ξ = k · log(2) - s · log(3)
4. Return ξ > 0
```

### 4.2 Spectral Analysis Algorithm

```
Input: Binary parity word w ∈ {0,1}^k
Output: DC spectral energy, contraction status

1. Compute DC component: ŵ(0) = (1/k) · Σ w_i
2. DC energy: E = ŵ(0)²
3. Critical energy: E* = (log(2)/log(3))²
4. Return E, (E < E*)
```

### 4.3 Tropical Certificate Construction

```
Input: ContractionSystem (k, s)
Output: TropicalCertificate or failure

1. Compute d = s/k as rational number
2. Compute rational bound q = ⌈d · 10^6⌉ / 10^6
3. Verify q < 0.6309 (rational comparison)
4. If verified, return certificate (k, s, q)
5. Else return failure (density too high)
```

## 5. Discussion

### 5.1 Relation to Tao's Work

Tao (2019) proved that almost all Collatz orbits attain almost bounded values, using logarithmic density arguments closely related to our contraction exponent framework. Our contribution is to:
1. Formalize the density-contraction biconditional as a precise mathematical statement.
2. Provide the spectral reformulation connecting Fourier analysis to orbit dynamics.
3. Establish the tropical certificate framework for verified computation.

### 5.2 The Critical Density as a Phase Transition

The critical density ρ* = log(2)/log(3) acts as a phase transition point:
- For d < ρ*: the orbit contracts exponentially at rate e^{-ξ/k}.
- For d = ρ*: the orbit is marginally stable (multiplicative factor = 1).
- For d > ρ*: the orbit expands exponentially.

The Collatz conjecture asserts that no infinite orbit can sustain d ≥ ρ*. Equivalently, the parity word of any orbit must eventually exhibit d < ρ* on sufficiently long windows.

### 5.3 Connection to Tropical Spectral Theory

The contraction gap Δ(k,s) = k·ρ* − s has a natural interpretation in tropical mathematics. In the max-plus algebra, the contraction exponent becomes a tropical linear function, and the critical density corresponds to a tropical eigenvalue condition. The tropical certificate framework bridges this connection by enabling rational-arithmetic verification of contraction bounds.

### 5.4 Falsifiable Prediction

We state a quantitative, falsifiable conjecture:

**Conjecture** (Stopping Time Bound). For every n > 1, the Collatz orbit of n reaches a value less than n within at most C·log(n) steps, where C = 1/(log(2) − ½·log(3)) ≈ 2.41.

This predicts a specific stopping time bound testable against computational data. The constant C arises from the positive drift at half-density (Theorem 3.13).

## 6. Future Work

1. **Transfer operator spectral gap**: Extend the finite-dimensional spectral theory of [SpectralCriterion.lean] to the Ruelle-Perron-Frobenius transfer operator for the Collatz map, proving a spectral gap at s = 1.

2. **Large deviation bounds on parity words**: Establish that the probability of a Collatz parity word achieving ones-density ≥ ρ* decays exponentially in k, using the binary entropy function and Sanov's theorem.

3. **Tropical eigenvalue connection**: Embed the ContrationSystem framework into the tropical matrix theory of [Tropical/SymbolicDynamics/Core.lean], connecting contraction certificates to tropical spectral gaps.

4. **Multi-scale spectral analysis**: Analyze not just the DC component but the full spectrum of Collatz parity words, characterizing forbidden spectral patterns that would imply non-termination.

## References

1. Collatz, L. (1937). Problem statement at International Congress of Mathematicians.
2. Lagarias, J.C. (2010). "The Ultimate Challenge: The 3x+1 Problem." AMS.
3. Tao, T. (2019). "Almost all orbits of the Collatz map attain almost bounded values." Forum of Mathematics, Pi.
4. Barina, D. (2021). "Convergence verification of the Collatz problem." The Journal of Supercomputing.
5. Oliveira e Silva, T. (2010). "Maximum excursion and stopping time record-holders for the 3x+1 problem." Mathematics of Computation.
