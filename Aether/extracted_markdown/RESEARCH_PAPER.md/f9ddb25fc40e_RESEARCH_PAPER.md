# Gravity from Information: Spacetime as a Quantum Error-Correcting Code

## Abstract

We formalize the connection between quantum error-correcting codes and holographic gravity in Lean 4, proving a suite of novel theorems that deepen the quantum Singleton bound and its geometric interpretation. Our main contributions include: (1) a **weighted Singleton bound** for inhomogeneous Planck areas; (2) a proof that **concatenation preserves the Singleton bound** when both codes encode at least one logical qubit, with a verified counterexample showing the hypothesis is necessary; (3) a proof that the **BPT bound implies the Singleton bound**, establishing a strict hierarchy among coding constraints; (4) a **sharp erasure phase transition** characterizing the entanglement wedge transition; (5) a precise characterization of the **Singleton deficit as discrete curvature**, with a proof that zero deficit is equivalent to entropy–distance optimality (MDS = flat geometry); (6) the **area defect equals four times the syndrome defect**, providing an exact quantitative bridge between information theory and Riemannian geometry. All proofs are machine-verified in Lean 4 with no sorry axioms, building on and extending the Catalog's StabilizerBounds and HolographicGravity frameworks.

## 1. Introduction

The holographic principle, originating in the work of 't Hooft (1993) and Susskind (1995), asserts that the information content of a gravitational system is encoded on its boundary. The Ryu-Takayanagi (RT) formula S(A) = Area(γ_A)/(4G) makes this precise for static spacetimes in AdS/CFT, relating boundary entanglement entropy to bulk minimal surface area.

Almheiri, Dong, and Harlow (2014) made the crucial observation that the RT formula has the mathematical structure of a quantum error-correcting code. Pastawski, Yoshida, Harlow, and Preskill (2015) constructed explicit tensor network models (the HaPPY codes) realizing this connection.

In this work, we push the formalization significantly deeper, proving results about the *structure* of the code-geometry correspondence that go beyond what was previously available in the Catalog. Our key insight is that the **Singleton deficit** — the gap between a code's actual parameters and the MDS (Maximum Distance Separable) optimum — serves as a discrete measure of bulk curvature.

### 1.1 Summary of Results

| Theorem | Statement | Significance |
|---------|-----------|-------------|
| `concat_singleton` | 2d₁d₂ + k₁k₂ ≤ n₁n₂ + 2 (when k₁,k₂ ≥ 1) | Holographic structure preserved under RG |
| `sub_bpt_singleton` | kd² ≤ n ⟹ 2d + k ≤ n + 2 | BPT strictly stronger than Singleton |
| `toric_bpt_saturation` | kd² = n for toric codes | Toric codes are BPT-optimal |
| `complementary_exclusion` | Reconstruction ⟹ complement cannot | Code-theoretic no-cloning |
| `curvature_from_deficit` | Δ = 0 ⟺ S = 2(d-1) | Zero deficit = flat geometry |
| `toric_deficit_grows` | Δ(L₁) < Δ(L₂) for L₁ < L₂ | Curvature grows with scale |
| `area_defect_eq_four_entropy_defect` | Area defect = 4 × entropy defect | Quantitative information-geometry bridge |
| `bekenstein_singleton_mds` | S = A/(4G) = n - 2d + 2 for MDS | Bekenstein-Hawking is Singleton maximum |

## 2. Code Parameters and Validity

### 2.1 Definition

A quantum stabilizer code is specified by parameters [[n, k, d]] where:
- n = number of physical (boundary) qubits
- k = number of logical (bulk) qubits  
- d = code distance (minimum weight of undetectable errors)

**Definition (ValidQECC).** A code [[n, k, d]] is valid if k ≤ n, d ≥ 1, and the quantum Singleton bound holds: 2d + k ≤ n + 2.

### 2.2 Singleton Deficit

**Definition.** The Singleton deficit is Δ(n,k,d) = (n + 2) - (2d + k).

**Definition.** A code is MDS (Maximum Distance Separable) if Δ = 0, equivalently 2d + k = n + 2.

**Theorem (curvature_from_deficit).** For a valid code, Δ = 0 if and only if S = 2(d-1), where S = n - k is the entanglement entropy.

*Proof sketch.* Both conditions are equivalent to 2d + k = n + 2 by elementary arithmetic. ∎

**Theorem (entropy_ge_distance).** For any valid code, S ≥ 2(d-1) (as integers). Equality characterizes MDS codes.

### 2.3 Holographic Interpretation

In the holographic dictionary:
- n corresponds to the number of Planck areas on the boundary: n = A/ℓ_P²
- k corresponds to the Bekenstein-Hawking entropy: k = S = A/(4G)  
- d corresponds to half the minimal geodesic length: d = L/(2ℓ_P)
- Δ = 0 corresponds to flat bulk geometry (the RT formula is exactly tight)
- Δ > 0 corresponds to bulk curvature (sub-optimal coding efficiency)

## 3. Erasure Phase Transition

### 3.1 Sharp Threshold

**Theorem (reconstruction_iff).** A boundary region of size s can reconstruct the bulk if and only if s + d > n.

This is the code-theoretic content of the entanglement wedge phase transition. The transition is sharp: there is no intermediate regime.

### 3.2 Complementary Exclusion (No-Cloning)

**Theorem (complementary_exclusion).** If k ≥ 1 and a region of size s reconstructs the bulk, then the complementary region of size n - s cannot reconstruct.

*Proof sketch.* If s + d > n (A reconstructs) and (n-s) + d > n (complement reconstructs), then adding gives 2d > n, but from Singleton 2d ≤ n + 2 - k ≤ n + 1, so 2d ≤ n + 1. Combined: n < 2d ≤ n + 1, so s + (n-s) = n < 2d ≤ n + 1, contradiction with k ≥ 1 (which gives 2d ≤ n + 1). ∎

**Theorem (no_cloning).** More generally, if a region of size s reconstructs and s + t ≤ n, then no region of size t can independently reconstruct. This extends complementary exclusion to arbitrary (not just complementary) disjoint regions.

## 4. Weighted Singleton Bound

### 4.1 Weighted Codes

**Definition.** A weighted code assigns a positive integer weight w_i ≥ 1 to each physical qubit i. The total weight is W = Σ w_i ≥ n.

**Theorem (weighted_singleton_bound).** For a valid weighted code, W - k ≥ 2(d-1).

This generalizes the standard Singleton bound (where all weights equal 1, so W = n) to inhomogeneous spacetimes where different Planck cells contribute different areas.

### 4.2 Physical Interpretation

In a realistic spacetime, the Planck area varies with the local metric. Near a black hole, the effective Planck area is stretched. The weighted Singleton bound captures this: the total effective area W, not the qubit count n, determines the entropy bound.

## 5. Concatenation

### 5.1 Concatenated Codes

**Definition.** The concatenation of [[n₁, k₁, d₁]] and [[n₂, k₂, d₂]] is [[n₁n₂, k₁k₂, d₁d₂]].

**Theorem (concat_singleton).** If both codes satisfy the Singleton bound and k₁, k₂ ≥ 1, then the concatenated code satisfies the Singleton bound.

*Proof.* By nlinarith using the Singleton bounds of both codes and the key cross-product terms:
- k₁·(n₂ - d₂) ≥ 0 (since k₂ ≤ n₂ and d₂ ≤ n₂)
- k₂·(n₁ - d₁) ≥ 0

The proof exploits the non-negativity of products of positive quantities. ∎

### 5.2 Counterexample for k = 0

The hypothesis k ≥ 1 is necessary: [[2, 0, 2]] ⊗ [[2, 0, 2]] = [[4, 0, 4]], and 2·4 + 0 = 8 > 6 = 4 + 2, violating Singleton. This was discovered during our formalization as a machine-verified counterexample.

### 5.3 Holographic Interpretation

Concatenation models the renormalization group (RG) flow: the outer code represents coarse-grained boundary data, the inner code represents fine-grained data. The theorem says that if each level of the RG hierarchy carries at least one logical qubit, the holographic structure (Singleton bound) is preserved.

## 6. BPT Bound and Topological Codes

### 6.1 The BPT Bound

**Definition.** A code satisfies the BPT bound with constant c if kd² ≤ cn.

**Theorem (toric_bpt_saturation).** The toric code [[2L², 2, L]] saturates the BPT bound: kd² = n.

### 6.2 BPT Implies Singleton

**Theorem (sub_bpt_singleton).** If kd² ≤ n, k ≥ 1, and d ≥ 1, then 2d + k ≤ n + 2.

*Proof.* Key steps: (1) From (d-1)² ≥ 0, we get d² + 1 ≥ 2d. (2) From k ≥ 1, k(d²-1) ≥ d²-1. (3) Therefore d² + k ≤ kd² + 1. (4) So 2d ≤ d² + 1 ≤ kd² + 1 - k + 1 ≤ n - k + 2. ∎

This establishes that the BPT bound is strictly stronger than the Singleton bound: any code satisfying BPT automatically satisfies Singleton, but not conversely.

### 6.3 Toric Code Deficit

**Theorem (toric_deficit).** The Singleton deficit of the toric code [[2L², 2, L]] is Δ = 2L² - 2L = 2L(L-1).

**Theorem (toric_deficit_grows).** The toric deficit grows strictly with L: if L₁ < L₂ (both ≥ 2), then Δ(L₁) < Δ(L₂).

Physical interpretation: larger toric codes are increasingly far from MDS optimality. In the holographic dictionary, this means larger spatial regions exhibit more integrated curvature — a discrete analog of the fact that curvature accumulates over space.

## 7. Submodularity-Geometry Bridge

### 7.1 Syndrome Defect

**Definition.** For a submodular entropy function S on boundary regions, the syndrome defect is:
defect(X, Y) = S(X) + S(Y) - S(X∩Y) - S(X∪Y)

**Theorem (defect_nonneg).** The syndrome defect is nonnegative (from submodularity).

**Theorem (defect_self).** Self-defect vanishes: defect(X, X) = 0.

**Theorem (defect_symm).** Defect is symmetric: defect(X, Y) = defect(Y, X).

### 7.2 The RT Bridge

For a holographic profile (equipped with the Ryu-Takayanagi relation S(X) = area(X)/4):

**Theorem (area_submod_of_rt).** Area submodularity follows from entropy submodularity under RT.

**Theorem (area_defect_eq_four_entropy_defect).** The area defect equals exactly 4 times the entropy defect.

**Theorem (flatness_iff_area_modular).** Zero entropy defect if and only if area is modular (additive over disjoint regions).

### 7.3 Physical Interpretation

The syndrome defect is the discrete curvature of the holographic code. Zero defect means flat geometry (exact additivity of entropy and area). Positive defect means curved geometry (strict subadditivity). The factor of 4 in the area–entropy defect relation comes directly from the RT factor S = A/4, reflecting the fundamental discreteness at the Planck scale.

## 8. Continuous Holographic Codes

### 8.1 Bekenstein-Singleton Equivalence

**Theorem (bekenstein_singleton_mds).** For a continuous holographic code where the Bekenstein entropy equals the Singleton maximum (MDS condition), we have:

A/(4G) = A/ℓ_P² - L/ℓ_P + 2

This is the exact algebraic identity that makes the Bekenstein-Hawking formula a coding theorem: the maximum number of logical qubits in a code with n = A/ℓ_P² physical qubits and distance d = L/(2ℓ_P) is exactly the Bekenstein-Hawking entropy.

## 9. Code Families

### 9.1 HaPPY Family

The HaPPY code family [[5(L+1), L+1, 3]] has:
- Linear entropy growth: S(L) = 4(L+1)
- MDS at L=0 (the [[5,1,3]] perfect code)
- Sharp reconstruction threshold at s = 5L + 3
- Constant gap n - threshold = 2 for all L

### 9.2 Toric Family

The toric code family [[2L², 2, L]] has:
- Quadratic entropy growth: S(L) = 2L² - 2
- BPT-saturating: kd² = n for all L
- Quadratic deficit growth: Δ(L) = 2L(L-1)
- Distance scaling d = √(n/2)

## 10. Discussion

### 10.1 What We Learned

The central lesson of this work is that the Singleton bound is not merely a constraint — it is *the* constraint. In the holographic setting, every major physical principle can be derived from it:

1. **Bekenstein-Hawking entropy** = maximum k for given n, d (Singleton maximum)
2. **No-cloning / causal structure** = complementary exclusion from Singleton
3. **Entanglement wedge transition** = sharp erasure threshold from code distance
4. **Bulk curvature** = Singleton deficit
5. **Strong subadditivity** = nonnegative syndrome defect = nonnegative curvature

### 10.2 The BPT Hierarchy

Our proof that BPT implies Singleton reveals a hierarchy of constraints:

**BPT bound** (geometric, 2D) ⟹ **Singleton bound** (coding-theoretic) ⟹ **entropy bounds** (thermodynamic)

Each level adds geometric structure. The BPT bound is specific to 2D topological codes; the Singleton bound applies to all quantum codes; entropy bounds are universal. The toric code sits at the top, saturating BPT.

### 10.3 The Counterexample

Our discovery that concatenation fails the Singleton bound for k = 0 codes is physically meaningful. Codes with k = 0 have no logical qubits — they encode nothing. In the holographic dictionary, this corresponds to a spacetime with zero entropy, i.e., zero horizon area. Such spacetimes (pure vacuum with no black holes) do not have a holographic structure in the usual sense. The k ≥ 1 requirement for concatenation reflects the physical requirement that each level of the holographic RG hierarchy must contain at least one bit of information.

## 11. Future Work

1. **Quantum extremal surface formula**: Extend the coding framework to include quantum corrections (1/N corrections in AdS/CFT).
2. **Dynamics of the code**: Model how the code parameters change under time evolution.
3. **Higher-dimensional BPT**: Generalize the BPT bound to 3D and 4D topological codes.
4. **Non-stabilizer codes**: Extend the framework beyond stabilizer codes to approximate error correction.

## References

1. A. Almheiri, X. Dong, D. Harlow, "Bulk Locality and Quantum Error Correction in AdS/CFT," JHEP (2014)
2. F. Pastawski, B. Yoshida, D. Harlow, J. Preskill, "Holographic quantum error-correcting codes: Toy models for the bulk/boundary correspondence," JHEP (2015)
3. S. Bravyi, D. Poulin, B. Terhal, "Tradeoffs for reliable quantum information storage in 2D systems," Phys. Rev. Lett. (2010)
4. D. Harlow, "The Ryu-Takayanagi Formula from Quantum Error Correction," Comm. Math. Phys. (2017)
5. S. Ryu, T. Takayanagi, "Holographic derivation of entanglement entropy from AdS/CFT," Phys. Rev. Lett. (2006)
6. Catalog/Physics/StabilizerBounds.lean — Quantum stabilizer code bound framework
7. Catalog/Physics/HolographicGravity.lean — RT-Singleton correspondence
8. Catalog/Bridges/HolographicCoding.lean — Holographic code profiles
