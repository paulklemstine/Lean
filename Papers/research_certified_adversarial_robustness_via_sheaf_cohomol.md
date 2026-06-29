# Certified Adversarial Robustness via Sheaf Cohomology: Persistent Filtrations and Composition Theorems

## Abstract

We develop a sheaf-cohomological framework for certified adversarial robustness of neural network classifiers, extending the existing Čech descent approach with three novel contributions: (1) a **Persistent Robustness Filtration** connecting topological data analysis to adversarial ML, defining a decreasing family of robust sets indexed by perturbation radius; (2) a **Composition Robustness Theorem** providing certified radius bounds for multi-layer Lipschitz networks with explicit dependence on per-layer constants; and (3) a **Mayer-Vietoris Robustness Theorem** enabling local-to-global certificate gluing for two overlapping regions. All results are machine-verified in Lean 4 with no remaining axioms beyond the standard logical framework. We additionally prove refinement monotonicity, weight perturbation stability, stalk vulnerability characterization, and a star-shaped nerve optimality result. A falsifiable conjecture connecting H² obstruction to strict radius reduction is stated and verified in a special case.

**Keywords**: Adversarial robustness, sheaf cohomology, persistent homology, Lipschitz networks, certified defense, Čech cohomology, topological data analysis

---

## 1. Introduction

The vulnerability of neural networks to adversarial perturbations — small, often imperceptible modifications to inputs that cause misclassification — poses fundamental challenges for safety-critical AI systems. While empirical defenses (adversarial training, input transformation) offer practical improvements, they provide no formal guarantees. Certified defenses based on randomized smoothing, interval bound propagation, or Lipschitz analysis provide rigorous certificates but often yield loose bounds.

Recent work has established a sheaf-theoretic perspective on robustness certification, modeling the score-gap function (margin between class logits) as a section of a presheaf on the input space, with local robustness certificates corresponding to sections over open subsets. The central insight: **local certificates glue to global ones precisely when the first Čech cohomology of the cover vanishes**.

### 1.1 Contributions

This paper extends the sheaf-cohomological framework in several directions:

1. **Persistent Robustness Filtration** (§3): We introduce the persistent robust set R(r) = {x : ∀y, dist(y,x) < r → g(y) > 0} and show it forms a monotone decreasing filtration, connecting adversarial robustness to persistent homology.

2. **Composition Robustness** (§4): For f: X → Y with Lipschitz constant L₁ and g: Y → ℝ with Lipschitz constant L₂, if g(f(x)) ≥ m, then x is certified at radius m/(L₁·L₂).

3. **Mayer-Vietoris Robustness** (§5): For S ⊆ U₁ ∪ U₂ with local certificates at radii r₁, r₂, the global certificate has radius min(r₁, r₂).

4. **Weight Perturbation Stability** (§6): If two networks are δ-close pointwise and the original has margin > δ on the certified ball, the certificate transfers.

5. **Refinement Monotonicity** (§7): Finer covers yield at least as large a global certified radius.

6. **Stalk Vulnerability Characterization** (§8): A point has trivial stalk iff it is vulnerable at every positive radius.

7. **Star-Shaped Nerve Optimality** (§9): When one region has the minimum radius, the global inf equals that region's radius.

### 1.2 Relation to Prior Work

The existing catalog provides:
- `vanishing_H1_implies_certified_Linf_radius`: The fundamental descent theorem [SheafCertifiedRobustness.lean]
- `finite_cover_vanishing_H1_implies_global_radius`: Finite cover globalization [CechDecisionBoundaryObstructions.lean]
- `nonexact_implies_vulnerability`: Cosheaf exactness → vulnerability [ActivationNerveCosheafRobustness.lean]
- `global_certified_radius_of_coboundary`: Coboundary → global radius [NeuralSheafCohomology.lean]

Our results build directly on these foundations, extending them with new structures (persistent filtration), new theorems (composition, Mayer-Vietoris, stability), and new connections (TDA, multi-layer analysis).

---

## 2. Preliminaries

### 2.1 Score-Gap Robustness

**Definition 2.1** (Persistent Robust Set). Let (X, d) be a pseudo-metric space and g: X → ℝ a score-gap function. The *persistent robust set at scale r* is:

R(r) = {x ∈ X : ∀y ∈ X, d(y,x) < r → g(y) > 0}

**Definition 2.2** (Persistent Robustness Filtration). A *persistent robustness filtration* on X is a triple (g, L, λ) where:
- g: X → ℝ is the score-gap function
- L > 0 is the Lipschitz constant
- λ: |g(x) - g(y)| ≤ L · d(x,y) for all x, y

### 2.2 Čech Cohomology

For a finite cover {Uᵢ}_{i ∈ I} of a region S, the Čech cohomology measures the obstruction to gluing local data. A 1-cocycle c: I × I → ℝ satisfies c(i,k) = c(i,j) + c(j,k), and is a coboundary if c(i,j) = b(j) - b(i) for some potential b: I → ℝ.

**Theorem** (H¹ Vanishes for Finite Covers). For any finite nonempty index set I, every 1-cocycle is a 1-coboundary. This is proven by fixing a base vertex i₀ and setting b(j) = c(i₀, j).

---

## 3. Persistent Robustness Filtration

### 3.1 Monotonicity

**Theorem 3.1** (Filtration Monotonicity). For any score-gap function g: X → ℝ:
$$r_1 \leq r_2 \implies R(r_2) \subseteq R(r_1)$$

*Proof.* If x ∈ R(r₂), then for all y with d(y,x) < r₁ ≤ r₂, we have d(y,x) < r₂, so g(y) > 0. Thus x ∈ R(r₁). □

### 3.2 Boundary Behavior

**Theorem 3.2** (Non-Positive Exclusion). If g(x) ≤ 0 and r > 0, then x ∉ R(r).

*Proof.* If x ∈ R(r), then taking y = x with d(x,x) = 0 < r gives g(x) > 0, contradicting g(x) ≤ 0. □

**Theorem 3.3** (Non-Positive Radius). If r ≤ 0, then R(r) = X.

*Proof.* For any x ∈ X, there is no y with d(y,x) < r ≤ 0 (since d(y,x) ≥ 0), so the condition is vacuously satisfied. □

### 3.3 Multi-Scale Certificates

**Definition 3.4** (Multi-Scale Certificate). A *multi-scale robustness certificate* at n scales consists of:
- Increasing radii 0 ≤ s₁ ≤ ... ≤ sₙ
- Robust sets Rᵢ = R(sᵢ) (the persistent robust set at each scale)

**Theorem 3.5** (Multi-Scale Nesting). The robust sets form a decreasing chain:
$$i \leq j \implies R_j \subseteq R_i$$

*Proof.* From sᵢ ≤ sⱼ and monotonicity (Theorem 3.1). □

---

## 4. Composition Robustness

### 4.1 Main Theorem

**Theorem 4.1** (Composition Robustness). Let f: X → Y be L₁-Lipschitz and g: Y → ℝ be L₂-Lipschitz. If g(f(x)) ≥ m > 0, then:
$$x \in R_{g \circ f}\!\left(\frac{m}{L_1 \cdot L_2}\right)$$

*Proof.* For y with d(y,x) < m/(L₁L₂):

|g(f(y)) - g(f(x))| ≤ L₂ · d(f(y), f(x)) ≤ L₂ · L₁ · d(y,x) < L₂ · L₁ · m/(L₁L₂) = m

Therefore g(f(y)) ≥ g(f(x)) - m > m - m = 0 (using g(f(y)) ≥ g(f(x)) - |g(f(y)) - g(f(x))| > m - m). □

### 4.2 Implications for Deep Networks

For a network with n layers having Lipschitz constants L₁, ..., Lₙ and final margin m, the certified radius is:

r = m / (∏ᵢ Lᵢ)

This exponential decay in the number of layers quantifies the *depth-robustness tradeoff*: each additional layer multiplicatively reduces the certified radius. This has practical implications:
- Shallow networks with larger Lipschitz constants may be preferable for certified robustness
- Lipschitz regularization at each layer has compounding benefits
- The "bottleneck" layer (largest Lipschitz constant) dominates the radius

---

## 5. Mayer-Vietoris Robustness

### 5.1 Two-Set Gluing

**Theorem 5.1** (Mayer-Vietoris Robustness). Let S ⊆ U₁ ∪ U₂ with local certificates at radii r₁, r₂. Then S has a global certificate at radius min(r₁, r₂).

*Proof.* For x ∈ S and y with d(y,x) < min(r₁, r₂):
- If x ∈ U₁: d(y,x) < min(r₁,r₂) ≤ r₁, so g(y) > 0 by the U₁ certificate.
- If x ∈ U₂: d(y,x) < min(r₁,r₂) ≤ r₂, so g(y) > 0 by the U₂ certificate. □

### 5.2 Iterated Mayer-Vietoris

**Theorem 5.2** (Iterated Mayer-Vietoris). For a finite cover S ⊆ ⋃ᵢ Uᵢ with local radii rᵢ, the global certified radius is at least inf'ᵢ rᵢ.

*Proof.* For x ∈ S, find i with x ∈ Uᵢ. Then d(y,x) < inf'ᵢ rᵢ ≤ rᵢ, so g(y) > 0. □

---

## 6. Weight Perturbation Stability

### 6.1 Correct Formulation

An initial formulation — that δ-closeness of score-gaps reduces the certified radius by δ — turns out to be **false**. The correct theorem requires a uniform margin bound:

**Theorem 6.1** (Weight Perturbation Stability). If |g₁(x) - g₂(x)| ≤ δ for all x, and g₁(y) > δ for all y with d(y,x) < R, then x ∈ R_{g₂}(R).

*Proof.* For y with d(y,x) < R: g₂(y) ≥ g₁(y) - |g₁(y) - g₂(y)| ≥ g₁(y) - δ > δ - δ = 0. □

### 6.2 Why the Naive Statement Fails

The statement "x ∈ R_{g₁}(R) and |g₁-g₂| ≤ δ implies x ∈ R_{g₂}(R-δ)" is false because x ∈ R_{g₁}(R) only guarantees g₁(y) > 0, not g₁(y) > δ. A counterexample: let g₁(y) = ε for tiny ε > 0 and δ > ε; then g₂(y) ≥ -δ + ε < 0.

---

## 7. Refinement Monotonicity

**Theorem 7.1** (Refinement Improvement). If cover κ refines cover ι (via a refinement map φ: κ → ι with r_coarse(φ(k)) ≤ r_fine(k) for all k), then:
$$\inf(\text{range}(r_{\text{coarse}})) \leq \inf(\text{range}(r_{\text{fine}}))$$

*Proof.* For any k ∈ κ: inf(range(r_coarse)) ≤ r_coarse(φ(k)) ≤ r_fine(k). Taking the inf over k gives the result. □

---

## 8. Stalk Vulnerability Characterization

**Theorem 8.1** (Trivial Stalk ⟺ Vulnerable). For x ∈ X:

(∀r > 0, x ∉ R(r)) ⟺ (∀r > 0, ∃y, d(y,x) < r ∧ g(y) ≤ 0)

*Proof.* Both directions follow by unfolding the definition of R(r) and pushing negations through the quantifiers. □

---

## 9. Star-Shaped Nerve Optimality

**Theorem 9.1**. If r: I → ℝ has a star vertex s with r(s) ≤ r(i) for all i, then inf(range(r)) = r(s).

*Proof.* inf(range(r)) ≤ r(s) (since r(s) ∈ range(r)), and r(s) ≤ r(i) for all i implies r(s) ≤ inf(range(r)). □

### 9.1 Conjecture: H² Obstruction

**Conjecture 9.2** (Falsifiable). For a finite cover with n ≥ 3 regions and distinct local radii, the global radius from vanishing H¹ is strictly less than the maximum local radius.

**Verified Special Case**: For 3 regions with r₀ < r₁ < r₂, we have inf(range(r)) ≤ r₀ < r₂.

**Computational Test**: Construct a ReLU network with activation regions forming a non-contractible nerve. Compute H² and compare global radius against max local radius. If H² ≠ 0 but global = max, the conjecture fails.

---

## 10. Sheaf-Lipschitz Globalization

**Theorem 10.1**. For a finite cover where region i has margin mᵢ and Lipschitz constant Lᵢ, the global certified radius is at least inf'ᵢ(mᵢ/Lᵢ).

*Proof.* Combine the Lipschitz robustness radius (Theorem 8 of catalog) with the iterated Mayer-Vietoris theorem. For x ∈ S ∩ Uᵢ and y with d(y,x) < inf'(mᵢ/Lᵢ) ≤ mᵢ/Lᵢ:

|g(y) - g(x)| ≤ Lᵢ · d(y,x) < Lᵢ · mᵢ/Lᵢ = mᵢ ≤ g(x)

so g(y) > 0. □

---

## 11. Algorithms

### 11.1 Persistent Robustness Computation

```
Algorithm: ComputePersistentRobustSet(g, X, r, N)
Input: score-gap g, point set X, radius r, samples N
Output: boolean array indicating R(r) membership

for each x in X:
    robust[x] = true
    for j = 1 to N:
        y = x + Uniform(-r, r)^d    // L∞ perturbation
        if g(y) ≤ 0:
            robust[x] = false; break
return robust
```

### 11.2 Sheaf-Lipschitz Globalization

```
Algorithm: SheafLipschitzGlobal(margins, lipschitz_consts)
Input: per-region margins m_i, Lipschitz constants L_i
Output: global certified radius

local_radii = [m_i / L_i for each region i]
return min(local_radii)
```

---

## 12. Discussion

### 12.1 Connections to Existing Work

Our persistent robustness filtration connects to randomized smoothing (Cohen et al., 2019): both define scale-dependent robustness sets, but our approach is deterministic and based on the exact score-gap rather than Gaussian smoothing. The composition robustness theorem relates to spectral norm regularization (Yoshida & Miyato, 2017) by making the depth-radius tradeoff explicit.

### 12.2 Limitations

1. **Lipschitz bounds**: The certified radii depend on Lipschitz constants, which are notoriously hard to compute tightly for deep networks.
2. **Computational cost**: Exact computation of activation region decomposition is exponential in network width.
3. **Tightness**: The min-of-local-radii bound may be very conservative for topologically simple covers.

### 12.3 Corrected Weight Perturbation

We note that the initially proposed weight perturbation stability theorem (radius reduction by δ) was **falsified** during formalization. The corrected version requires a minimum margin bound exceeding δ. This illustrates the value of machine-verified proofs: the incorrect statement would have been accepted in an informal paper.

---

## 13. Future Work

1. **Persistent robustness barcodes**: Compute actual persistent homology of the filtration {R(r)} and define robustness-specific distance metrics.
2. **Spectral sequence for depth**: Formalize the spectral sequence connecting per-layer cohomology to end-to-end certificates.
3. **Efficient Čech computation**: Develop polynomial-time approximation algorithms for the Čech complex of ReLU activation regions.
4. **Higher cohomology obstructions**: Investigate whether nontrivial H² of the nerve creates strict improvements over the inf-of-local-radii bound.

---

## References

1. Catalog theorems: `SheafCertifiedRobustness.lean`, `CechDecisionBoundaryObstructions.lean`, `ActivationNerveCosheafRobustness.lean`, `NeuralSheafCohomology.lean`
2. Cohen, J., Rosenfeld, E., & Kolter, J. Z. (2019). Certified adversarial robustness via randomized smoothing. ICML.
3. Grothendieck, A. (1957). Sur quelques points d'algèbre homologique. Tōhoku Mathematical Journal.
4. Yoshida, Y., & Miyato, T. (2017). Spectral norm regularization for improving the generalizability of deep learning.

---

## Appendix: Lean 4 Formalization

All 13 theorems in this paper are fully machine-verified in Lean 4 (Mathlib v4.28.0), with no `sorry` statements and only standard logical axioms (propext, Classical.choice, Quot.sound). The formalization is in `MachineLearning/SheafCohomologyRobustness.lean`.

**Novel Lean structures**:
- `PersistentRobustSet`: Sublevel set of the robustness radius function
- `PersistentRobustnessFiltration`: Lipschitz score-gap with filtration data
- `MultiScaleCertificate`: Multi-scale robustness certificate package

**Theorem count**: 13 fully proven theorems, 0 sorry
**Lines of Lean code**: ~310
**Axioms used**: propext, Classical.choice, Quot.sound (standard)
