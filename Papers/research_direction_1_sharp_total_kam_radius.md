# Sharp Instability Threshold for Finite-Scale Diophantine Resonance Avoidance

## Abstract

We establish an exact phase-transition theorem for finite-scale Diophantine resonance avoidance under adversarial perturbations. Given a frequency vector ω ∈ ℝ^d satisfying the (K,C)-Diophantine condition — that |k·ω| ≥ C for all nonzero integer modes k with ‖k‖₁ ≤ K — we prove that the perturbation budget C/K is the **exact universal threshold** for stability in the ℓ∞ norm. Specifically:

1. **Safety** (Theorem 3): If ‖δ‖∞ < C/K, then k·(ω+δ) ≠ 0 for all admissible modes.
2. **Sharpness** (Theorem 5): For any B > C/K, there exist a (K,C)-Diophantine ω and a perturbation δ with ‖δ‖∞ ≤ B creating exact resonance.
3. **Attainment** (Theorem 6): When a mode k₀ with ‖k₀‖₁ = K achieves |k₀·ω| = C, a perturbation of ‖δ‖∞ = C/K exactly produces resonance.
4. **Geometry** (Theorem 7): The ℓ∞-distance from ω to each resonance hyperplane equals |k·ω|/‖k‖₁, proved via explicit sign-perturbation construction.

All results are formally verified in Lean 4 with Mathlib. The proofs use no axioms beyond the standard logical foundations.

**Keywords**: Diophantine approximation, KAM theory, sharp threshold, ℓ¹/ℓ∞ duality, adversarial robustness, resonance geometry, phase transition.

---

## 1. Introduction

### 1.1 Motivation

The classical KAM (Kolmogorov-Arnold-Moser) theorem guarantees that quasi-periodic motions in nearly integrable Hamiltonian systems persist under small perturbations, provided the frequency vector satisfies a Diophantine non-resonance condition. The quantitative versions of KAM theory provide sufficient conditions for persistence, but the question of whether these conditions are necessary — whether the perturbation bounds are sharp — has remained largely open.

In the finite-scale setting, the Diophantine condition becomes a finitary statement: |k·ω| ≥ C for all nonzero integer modes k with ‖k‖₁ ≤ K. The existing catalog of tropical KAM results (Theorems `total_perturbation_budget_bound` and `certifyMultiScaleKAM_sound` in the Catalog) establishes that a cumulative perturbation budget less than C/K preserves the non-resonance condition. This paper proves the converse: the budget C/K is not merely sufficient but universally optimal.

### 1.2 Relationship to Prior Work

Our work builds directly on the multi-scale renormalization framework in `TropicalKAMRenormalization.lean`, which establishes:
- Iterated stability with geometric decay (Theorem `tropical_diophantine_iterated_stable`)
- Finite total budget bound < C/K (Theorem `total_perturbation_budget_bound`)
- Certification soundness (Theorem `certifyMultiScaleKAM_sound`)

These results provide the "safety" direction. Our contribution is the matching "sharpness" direction, transforming a one-sided certification into an exact threshold theorem.

### 1.3 Contributions

1. **Explicit Diophantine witness**: ω = (KC, −C) is (K,C)-Diophantine for all K ≥ 1, C > 0 (Theorem 4).
2. **Universal sharpness**: For any B > C/K, there exists a (K,C)-Diophantine ω and a perturbation δ with ‖δ‖∞ ≤ B creating resonance (Theorem 5).
3. **Exact attainment**: The critical budget C/K is achieved with equality (Theorem 6).
4. **Hyperplane distance formula**: dist_∞(ω, {x : k·x = 0}) = |k·ω|/‖k‖₁ (Theorem 7).
5. **Verified algorithms**: Computational methods for the resonance margin and adversarial perturbation, with formal correctness guarantees.

---

## 2. Definitions and Notation

### 2.1 Basic Setup

Fix a dimension d ≥ 1 (our main results use d = 2 but definitions are general).

**Definition 1** (L1 norm). For k : ℤ^d, define ‖k‖₁ = Σᵢ |kᵢ|.

**Definition 2** (Lattice inner product). For k ∈ ℤ^d and ω ∈ ℝ^d:
  k · ω = Σᵢ kᵢ · ωᵢ

**Definition 3** (Sup norm). For x ∈ ℝ^d:
  ‖x‖∞ = maxᵢ |xᵢ|

**Definition 4** ((K,C)-Diophantine). A frequency ω ∈ ℝ^d is (K,C)-Diophantine if for all k ∈ ℤ^d with k ≠ 0 and ‖k‖₁ ≤ K:
  C ≤ |k · ω|

**Definition 5** (Critical budget). criticalBudget(K, C) = C/K.

**Definition 6** (Margin attainment). ω attains the margin at scale K with constant C if there exists k ≠ 0 with ‖k‖₁ = K and |k·ω| = C.

**Definition 7** (Finite resonance set).
  R_K = {ω ∈ ℝ^d : ∃ k ≠ 0, ‖k‖₁ ≤ K, k·ω = 0}

### 2.2 Resonance Margin

**Definition 8** (Resonance margin). For ω ∈ ℝ^d and K ∈ ℕ:
  r_K(ω) = min_{k ≠ 0, ‖k‖₁ ≤ K} |k·ω| / ‖k‖₁

This is the instance-specific adversarial radius: the smallest ℓ∞-perturbation that can create resonance at some admissible mode. The universal bound C/K is a lower bound on r_K(ω) for all (K,C)-Diophantine ω.

---

## 3. Main Results

### Theorem 1: ℓ¹/ℓ∞ Duality (dot_le_l1_mul_sup2)

**Statement**: For all k ∈ ℤ² and x ∈ ℝ²:
  |k · x| ≤ ‖k‖₁ · ‖x‖∞

**Proof sketch**: By the triangle inequality:
  |k₀x₀ + k₁x₁| ≤ |k₀||x₀| + |k₁||x₁| ≤ (|k₀| + |k₁|) · max(|x₀|, |x₁|)

This is the fundamental inequality connecting the two natural norms in the problem. The mode vector k lives naturally in ℓ¹ (its complexity is the sum of absolute values), while the perturbation δ lives naturally in ℓ∞ (the relevant constraint is the maximum component).

### Theorem 2: Per-Mode Safety (perturbation_below_mode_margin_safe_fin2)

**Statement**: If ‖k‖₁ · ‖δ‖∞ < |k·ω|, then k·(ω+δ) ≠ 0.

**Proof**: By Theorem 1, |k·δ| ≤ ‖k‖₁ · ‖δ‖∞ < |k·ω|. Since |k·δ| < |k·ω|, we have k·ω + k·δ ≠ 0, as the perturbation term is strictly smaller in absolute value than the original inner product. □

### Theorem 3: Safety Below Critical Budget (safety_below_critical_budget_fin2)

**Statement**: If ω is (K,C)-Diophantine and ‖δ‖∞ < C/K, then for all k ≠ 0 with ‖k‖₁ ≤ K: k·(ω+δ) ≠ 0.

**Proof**: For any admissible k: ‖k‖₁ · ‖δ‖∞ ≤ K · ‖δ‖∞ < K · (C/K) = C ≤ |k·ω|. Apply Theorem 2. □

This is the "safety" half of the threshold theorem, corresponding to the catalog result `total_perturbation_budget_bound`.

### Theorem 4: Diophantine Witness (diophantine_witness)

**Statement**: For K ≥ 1 and C > 0, the frequency ω = (KC, −C) is (K,C)-Diophantine.

**Proof**: For any nonzero (a, b) ∈ ℤ² with |a| + |b| ≤ K:
  (a, b) · (KC, −C) = C(aK − b)

We claim |aK − b| ≥ 1. If aK = b, then |a|(K+1) = |a|K + |a| ≤ |a| + |b| ≤ K. But |a|(K+1) ≥ K+1 > K when a ≠ 0, a contradiction. If a = 0, then b = 0, contradicting (a,b) ≠ 0.

Therefore |aK − b| ≥ 1, giving |dot| = C|aK − b| ≥ C. □

**Remark**: The key property of ω = (KC, −C) is that the linear functional k ↦ kK − b has no integer zeros in the admissible region {|a| + |b| ≤ K} \ {0}. This is because the coefficient K+1 of a in the constraint |a|(K+1) ≤ K exceeds K.

### Theorem 5: Universal Sharpness (exists_resonant_perturbation_above_critical)

**Statement**: For any K ≥ 1, C > 0, and B > C/K, there exist ω ∈ ℝ², δ ∈ ℝ² such that:
1. ω is (K,C)-Diophantine
2. ‖δ‖∞ ≤ B
3. There exists k ≠ 0 with ‖k‖₁ ≤ K and k·(ω+δ) = 0

**Proof**: Take ω = (KC, −C) (Diophantine by Theorem 4). The mode k₀ = (1, K−1) has ‖k₀‖₁ = K and k₀·ω = KC − (K−1)C = C. By the hyperplane distance construction (Theorem 7), there exists δ with ‖δ‖∞ ≤ C/K < B and k₀·(ω+δ) = 0. □

**Significance**: This proves the catalog bound C/K is not an artifact of proof technique — it is the exact universal threshold.

### Theorem 6: Exact Attainment (exact_resonance_at_critical_budget_fin2)

**Statement**: If ω attains the margin (∃ k₀ with ‖k₀‖₁ = K and |k₀·ω| = C), then there exists δ with ‖δ‖∞ ≤ C/K and k₀·(ω+δ) = 0.

**Proof**: Apply the hyperplane distance construction (Theorem 7) to k₀ and ω. The perturbation has ‖δ‖∞ ≤ |k₀·ω|/‖k₀‖₁ = C/K. □

### Theorem 7: Hyperplane Distance (hyperplane_linfty_distance_achieved_fin2)

**Statement**: For any k ≠ 0 with ‖k‖₁ > 0 and any ω ∈ ℝ², there exists δ with ‖δ‖∞ ≤ |k·ω|/‖k‖₁ and k·(ω+δ) = 0.

**Proof**: Construct δᵢ = −(k·ω / ‖k‖₁) · kᵢ/|kᵢ| (with δᵢ = 0 when kᵢ = 0).

*Sup norm bound*: |δᵢ| = |k·ω|/‖k‖₁ · |kᵢ|/|kᵢ| ≤ |k·ω|/‖k‖₁ (since |kᵢ|/|kᵢ| ≤ 1).

*Resonance*: k·δ = −(k·ω/‖k‖₁) · Σᵢ kᵢ · kᵢ/|kᵢ| = −(k·ω/‖k‖₁) · Σᵢ |kᵢ| = −(k·ω/‖k‖₁) · ‖k‖₁ = −k·ω.
So k·(ω+δ) = k·ω − k·ω = 0. □

**Geometric interpretation**: The perturbation δ is the projection of ω onto the nearest point of the hyperplane {x : k·x = 0}, in the ℓ∞ geometry. Combined with Theorem 2, this proves dist_∞(ω, {x : k·x = 0}) = |k·ω|/‖k‖₁ exactly.

---

## 4. Algorithms

### Algorithm 1: Resonance Margin Computation

```
INPUT:  K (scale), ω (frequency vector in ℝ^d)
OUTPUT: r (resonance margin), k* (critical mode)

1. Initialize r ← ∞, k* ← null
2. For each k ∈ ℤ^d with 0 < ‖k‖₁ ≤ K:
   a. Compute ratio = |k·ω| / ‖k‖₁
   b. If ratio < r: set r ← ratio, k* ← k
3. Return (r, k*)
```

**Complexity**: O((2K+1)^d · d) time, O(d) space. For d = 2: O(K²).

**Correctness**: By exhaustive search over the finite set {k ∈ ℤ^d : 0 < ‖k‖₁ ≤ K}, the algorithm computes the exact minimum. The correctness is guaranteed by Theorems 2 and 7: r is the exact ℓ∞-distance to the nearest resonance hyperplane.

### Algorithm 2: Adversarial Perturbation Construction

```
INPUT:  k* (critical mode), ω (frequency vector)
OUTPUT: δ (perturbation achieving resonance)

1. Compute s ← k*·ω / ‖k*‖₁
2. For each i:
   a. If k*_i > 0: δ_i ← -s
   b. If k*_i < 0: δ_i ← s
   c. If k*_i = 0: δ_i ← 0
3. Return δ
```

**Correctness**: ‖δ‖∞ = |s| = |k*·ω|/‖k*‖₁ = r_K(ω) and k*·(ω+δ) = 0.

### Algorithm 3: Safety Certification

```
INPUT:  K, C, ω, budget B
OUTPUT: SAFE or UNSAFE with certificate

1. If B < C/K: return SAFE (universal guarantee)
2. Compute (r, k*) ← ResonanceMargin(K, ω)
3. If B < r: return SAFE (instance-specific guarantee)
4. Return UNSAFE (k* is vulnerable mode)
```

---

## 5. Computational Experiments

### 5.1 Diophantine Witness Verification

For K = 5, C = 1: ω = (5, −1).

| Mode k | ‖k‖₁ | k·ω | |k·ω|/‖k‖₁ |
|--------|-------|------|-------------|
| (1, 0) |   1   |   5  |    5.000    |
| (0, 1) |   1   |  −1  |    1.000    |
| (1, 4) |   5   |   1  |    0.200    |
| (−1,−4)|   5   |  −1  |    0.200    |
| (1, 1) |   2   |   4  |    2.000    |

Resonance margin = 0.200 = C/K. Critical modes: (1, 4) and (−1, −4).

### 5.2 Golden Ratio Scaling

For ω = (1, φ) where φ = (1+√5)/2:

| K  | r_K(ω)    | K·r_K(ω)  | Critical mode |
|----|-----------|-----------|---------------|
| 1  | 1.000000  | 1.000000  | (−1, 0)       |
| 2  | 0.309017  | 0.618034  | (−1, 1)       |
| 3  | 0.127322  | 0.381966  | (−2, 1)       |
| 5  | 0.047214  | 0.236068  | (−3, 2)       |
| 8  | 0.018237  | 0.145898  | (−5, 3)       |
| 13 | 0.006936  | 0.090170  | (−8, 5)       |
| 21 | 0.002654  | 0.055728  | (−13, 8)      |

The critical modes follow the Fibonacci sequence, and K·r_K(ω) → 0 at rate ~1/K, consistent with the golden ratio being Diophantine of type 1.

### 5.3 Phase Transition Demonstration

For K = 10, C = 1, ω = (10, −1):

| Budget B | B / r_K | Min |k·(ω+δ)| | Status    |
|----------|---------|-----------------|-----------|
| 0.050    | 0.50    | 0.500           | Safe      |
| 0.090    | 0.90    | 0.100           | Safe      |
| 0.099    | 0.99    | 0.010           | Safe      |
| 0.100    | 1.00    | 0.000           | Resonance |

The transition is perfectly sharp at B = C/K = 0.1.

---

## 6. Discussion

### 6.1 Significance

The main contribution is converting the catalog's one-sided certification theorem into an exact threshold theorem. This is qualitatively different mathematics: it establishes that the ℓ¹/ℓ∞ duality is the true geometric content of finite-scale resonance avoidance, not an artifact of proof technique.

### 6.2 The ℓ¹/ℓ∞ Duality Principle

The threshold C/K arises from the chain of inequalities:
  |k·δ| ≤ ‖k‖₁ · ‖δ‖∞ ≤ K · ‖δ‖∞

The first inequality is Hölder's inequality for the ℓ¹/ℓ∞ dual pair. The second uses ‖k‖₁ ≤ K. Sharpness follows because both inequalities are simultaneously achievable: the first by the sign-perturbation construction, the second by choosing modes with ‖k‖₁ = K.

### 6.3 Cross-Domain Connections

**Adversarial robustness (ML)**: The resonance margin is the ℓ∞ adversarial radius, and the sign perturbation is the Fast Gradient Sign Method. The theorem provides the exact adversarial robustness radius for the linear classifier k·x = 0.

**Convex geometry**: The resonance margin equals the ℓ∞-distance to the nearest hyperplane in the arrangement {k·x = 0 : 0 < ‖k‖₁ ≤ K}. The sign perturbation is the ℓ∞ metric projection.

**Coding theory**: The Diophantine condition is analogous to the minimum distance of a code, and the threshold C/K is the noise tolerance — the maximum channel noise the code can tolerate.

### 6.4 Limitations

The current results are restricted to the finite-scale setting (finitely many modes) and to the one-shot perturbation model. The extension to infinite-scale classical Diophantine conditions and to cumulative perturbation schedules (as in the catalog's multi-scale framework) are natural next steps.

---

## 7. Future Work

1. **Asymptotic analysis**: Study the behavior of r_K(ω) as K → ∞ for specific frequency classes (badly approximable, Liouville, etc.).
2. **Higher-dimensional witnesses**: Extend the Diophantine witness construction to d > 2.
3. **Schedule-level sharpness**: Prove that the cumulative budget bound in the multi-scale framework is also sharp.
4. **Tropical polytope structure**: Characterize the sublevel sets {ω : r_K(ω) ≥ t} as polyhedral complexes.
5. **Algorithmic improvements**: Reduce the mode enumeration complexity using lattice algorithms.

---

## 8. References

1. Kolmogorov, A. N. (1954). "On conservation of conditionally periodic motions for a small change in Hamilton's function." *Dokl. Akad. Nauk SSSR*, 98, 527–530.
2. Arnold, V. I. (1963). "Small denominators and problems of stability of motion in classical and celestial mechanics." *Russian Math. Surveys*, 18(6), 85–191.
3. Moser, J. (1962). "On invariant curves of area-preserving mappings of an annulus." *Nachr. Akad. Wiss. Göttingen Math.-Phys.*, 1–20.
4. Goodfellow, I. J., Shlens, J., & Szegedy, C. (2015). "Explaining and harnessing adversarial examples." *ICLR*.
5. Cassels, J. W. S. (1957). *An Introduction to Diophantine Approximation*. Cambridge University Press.
