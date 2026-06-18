# Bound-Feasibility Theory for Quantum Error-Correcting Codes: Joint Obstructions, Degeneracy Forcing, and Topological Tradeoffs

## Abstract

We develop a formally verified structural theory of quantum code parameter feasibility, synthesizing the quantum Singleton and Hamming bounds into a joint classification framework. We introduce the concept of **bound-feasible quantum parameters** and prove that the interaction of these bounds creates a sharp obstruction region we call the **degeneracy-forcing zone**: parameter triples (n, k, d) satisfying the universal Singleton bound but violating the nondegenerate Hamming bound, implying that any code realization must exploit degeneracy. We prove three main theorems: (1) Hamming violation forces degeneracy (a contrapositive classification principle), (2) joint feasibility with correction radius ≥ 1 implies the computable obstruction 1 + 3n ≤ 2^(n−k), and (3) toric codes satisfy a geometric rate–distance product bound that decays as 1/L². We implement a certified three-way parameter classifier and validate the upward-closure of the degeneracy-forcing region computationally for n ≤ 25. All theorems are formalized and machine-verified in Lean 4 with Mathlib.

**Keywords**: quantum error correction, stabilizer codes, nondegenerate codes, degeneracy, sphere packing, Pauli metric, quantum Singleton bound, quantum Hamming bound, topological quantum computing, toric code, asymptotic tradeoffs, code feasibility, formal verification

---

## 1. Introduction

### 1.1 Motivation

The theory of quantum error-correcting codes (QECCs) is built on two foundational parameter bounds:

- The **quantum Singleton bound**: k + 2(d − 1) ≤ n, constraining the trade-off between encoding rate and minimum distance for all quantum codes [1].
- The **quantum Hamming bound**: Σᵢ₌₀ᵗ C(n,i)·3ⁱ ≤ 2^(n−k), a sphere-packing constraint that applies to nondegenerate codes [2].

These bounds have been studied independently for decades. However, the *joint* structure they impose on the parameter space—and in particular, the mathematical consequences of their *gap*—has not been systematically formalized.

### 1.2 Contributions

This paper makes four contributions:

1. **Degeneracy-forcing theory**: We formalize the concept that certain parameter triples are *forced* into degeneracy by the gap between the Singleton and Hamming bounds. This upgrades a one-way bound into a structural classification principle (Theorem 1).

2. **Computable obstruction certificates**: We derive a fast, closed-form necessary condition for joint feasibility: 1 + 3n ≤ 2^(n−k) whenever the correction radius t ≥ 1 (Theorem 2). This enables parameter pre-screening without computing the full sphere-packing sum.

3. **Topological tradeoff formalization**: We prove that toric codes satisfy a rate × relative distance bound that decays as 1/L², formalizing the fundamental efficiency limitation of topological quantum codes (Theorem 3).

4. **Certified classifier**: We implement a three-way parameter classifier (Singleton-forbidden / degeneracy-forcing / jointly feasible) with machine-verified correctness proofs for each classification outcome.

### 1.3 Related Work

The quantum Singleton bound was established by Knill and Laflamme [1] and independently by Rains [3]. The quantum Hamming bound for nondegenerate codes appears in [2]. The distinction between degenerate and nondegenerate codes has been studied extensively [4, 5], but the systematic formalization of degeneracy-forcing parameter regions is, to our knowledge, new. The toric code was introduced by Kitaev [6], and the Bravyi–Poulin–Terhal bound on topological codes was proved in [7].

---

## 2. Definitions and Notation

### 2.1 Code Parameters

A quantum stabilizer code is characterized by three non-negative integers:

**Definition 2.1** (Code Parameters). A *code parameter triple* is a tuple p = (n, k, d) ∈ ℕ³ where:
- n = number of physical qubits
- k = number of logical qubits (0 ≤ k ≤ n)
- d = minimum distance (d ≥ 1)

The *error-correction radius* is t = ⌊(d−1)/2⌋.

### 2.2 Pauli Ball Volume

**Definition 2.2** (Pauli Ball Volume). The volume of the Pauli ball of radius t on n qubits is:

V(n, t) = Σᵢ₌₀ᵗ C(n, i) · 3ⁱ

This counts the number of n-qubit Pauli errors of weight at most t. The factor 3ⁱ arises because each non-identity qubit position admits three Pauli operators (X, Y, Z).

### 2.3 Admissibility Predicates

**Definition 2.3** (Singleton Admissibility). Parameters (n, k, d) are *Singleton-admissible* if k + 2(d − 1) ≤ n.

**Definition 2.4** (Hamming Admissibility). Parameters (n, k, d) are *Hamming-admissible* if V(n, t) ≤ 2^(n−k), where t = ⌊(d−1)/2⌋.

**Definition 2.5** (Joint Bound Feasibility). Parameters (n, k, d) are *jointly bound-feasible* if they are both Singleton-admissible and Hamming-admissible.

**Definition 2.6** (Degeneracy-Forcing). Parameters (n, k, d) are *degeneracy-forcing* if they are Singleton-admissible but not Hamming-admissible.

### 2.4 Code Validity

**Definition 2.7** (Nondegenerate Code). A stabilizer code with parameters (n, k, d) is *nondegenerate* if distinct correctable errors produce distinct syndromes, which implies V(n, t) ≤ 2^(n−k).

---

## 3. Main Results

### 3.1 Theorem 1: Hamming Violation Forces Degeneracy

**Theorem 3.1.** *For any code parameters p = (n, k, d), if p is not Hamming-admissible, then no nondegenerate stabilizer code with parameters p exists.*

*Proof sketch.* By contrapositive from the quantum Hamming bound. Suppose a nondegenerate code C with parameters p exists. By definition of nondegeneracy, distinct correctable errors produce distinct syndromes, which gives V(n, t) ≤ 2^(n−k). This contradicts the assumption that p is not Hamming-admissible. Therefore, no such nondegenerate code exists. □

**Corollary 3.2.** *If p is degeneracy-forcing, then any stabilizer code with parameters p must be degenerate.*

**Remark.** This theorem is logically simple (a direct contrapositive), but its conceptual content is significant. It transforms the quantum Hamming bound from a *one-way certification* ("if nondegenerate, then Hamming holds") into a *two-way classification* ("Hamming violation forces degeneracy"). This reframing has immediate design implications: before attempting to construct a nondegenerate code with given parameters, one should first check Hamming admissibility.

**Example 3.3.** The parameters [[10, 2, 5]] are degeneracy-forcing:
- Singleton: 2 + 2·4 = 10 ≤ 10 ✓
- Hamming: V(10, 2) = 1 + 30 + 405 = 436 > 256 = 2⁸ ✗
- Therefore, any [[10, 2, 5]] code must be degenerate.

### 3.2 Theorem 2: Joint Feasibility Radius Bound

**Theorem 3.4.** *For any jointly bound-feasible parameters p = (n, k, d) with correction radius t ≥ 1:*
$$1 + 3n \leq 2^{n-k}$$

*Proof sketch.* Since p is Hamming-admissible, V(n, t) ≤ 2^(n−k). The Pauli ball volume V(n, t) is monotone in t (Lemma 3.5 below), so for t ≥ 1:

V(n, t) ≥ V(n, 1) = C(n,0)·3⁰ + C(n,1)·3¹ = 1 + 3n

Combining: 1 + 3n ≤ V(n, t) ≤ 2^(n−k). □

**Lemma 3.5** (Pauli Ball Monotonicity). *For any n ∈ ℕ, the function t ↦ V(n, t) is monotone increasing.*

*Proof.* Each term C(n, i)·3ⁱ is non-negative, and increasing t adds non-negative terms to the sum. □

**Corollary 3.6** (Distance Obstruction). *If d ≥ 3 and p is jointly feasible, then 1 + 3n ≤ 2^(n−k).*

*Proof.* d ≥ 3 implies t = ⌊(d−1)/2⌋ ≥ 1. Apply Theorem 3.4. □

**Algorithmic significance.** Theorem 3.4 provides a constant-time rejection test: compute 1 + 3n and compare with 2^(n−k). This avoids the O(d·n) binomial coefficient computation required for the full Hamming sum. For large-scale parameter sweeps, this acceleration is significant.

### 3.3 Theorem 3: Toric Rate–Distance Product Bound

**Theorem 3.7.** *For the toric code family with lattice size L ≥ 1, having parameters [[2L², 2, L]], the product of rate k/n and relative distance d/n satisfies:*

$$(k/n) \cdot (d/n) \leq 1/L^2$$

*Proof sketch.* Direct computation:

(k/n)·(d/n) = (2/(2L²))·(L/(2L²)) = 2L/(4L⁴) = 1/(2L³)

Since L ≥ 1, we have 1/(2L³) ≤ 1/L² ⟺ L² ≤ 2L³ ⟺ 1 ≤ 2L, which holds. The formal proof uses `field_simp` and `nlinarith` in Lean 4. □

**Corollary 3.8** (Toric BPT Saturation). *The toric code saturates the Bravyi–Poulin–Terhal bound: k·d² = n for all L.*

*Proof.* 2·L² = 2L². This is verified by `simp [toricParams]`. □

**Interpretation.** Theorem 3.7 formalizes a fundamental limitation of topological quantum codes: geometric locality constrains how efficiently information can be encoded and protected. The rate–distance product decays at least as 1/L², implying that toric codes are not *asymptotically good*—one cannot simultaneously achieve a constant rate and constant relative distance as the system size grows.

---

## 4. The Parameter Classifier

### 4.1 Algorithm

We implement a three-way classifier with the following pseudocode:

```
FUNCTION ClassifyParams(n, k, d):
    IF k + 2(d-1) > n THEN
        RETURN SINGLETON_FORBIDDEN
    t ← ⌊(d-1)/2⌋
    IF Σ_{i=0}^{t} C(n,i)·3^i > 2^(n-k) THEN
        RETURN DEGENERACY_FORCING
    ELSE
        RETURN JOINTLY_FEASIBLE
```

**Complexity**: O(d·n) for the Hamming sum computation, dominated by binomial coefficient evaluation. The fast pre-filter (Theorem 3.4) reduces this to O(1) for many infeasible cases.

### 4.2 Correctness

We prove three correctness theorems in Lean 4:

1. `classify_singleton_forbidden`: If the classifier returns SINGLETON_FORBIDDEN, then ¬singletonAdmissible p.
2. `classify_degeneracy_forcing`: If the classifier returns DEGENERACY_FORCING, then degeneracyForcing p.
3. `classify_jointly_feasible`: If the classifier returns JOINTLY_FEASIBLE, then jointlyBoundFeasible p.

These correctness proofs follow from the definition of `classifyParams` via `split_ifs` after unfolding.

---

## 5. Computational Experiments

### 5.1 Parameter Space Survey

We classify all parameter triples with n ≤ 15:

| Category | Count | Percentage |
|----------|-------|-----------|
| Singleton-forbidden | 917 | 67.4% |
| Degeneracy-forcing | 35 | 2.6% |
| Jointly feasible | 408 | 30.0% |
| **Total** | **1360** | **100%** |

The degeneracy-forcing region is a thin but nonempty band in parameter space, appearing primarily at high distances relative to the syndrome capacity.

### 5.2 Degeneracy Frontier

For fixed (n, k), we define the *degeneracy frontier* d₀(n, k) as the smallest distance d such that (n, k, d) is degeneracy-forcing. Selected values:

| n | k | d₀ | max Singleton d |
|---|---|-----|-----------------|
| 6 | 2 | 3 | 3 |
| 8 | 0 | 5 | 5 |
| 10 | 2 | 5 | 5 |
| 12 | 0 | 7 | 7 |
| 15 | 2 | 7 | 7 |
| 20 | 0 | 11 | 11 |

### 5.3 Upward-Closure Conjecture

**Conjecture 5.1.** For fixed (n, k), the set {d : (n, k, d) is degeneracy-forcing} is upward-closed within the Singleton-admissible range.

We verify this conjecture computationally for all n ≤ 25. The conjecture holds without exception. A proof or counterexample for general parameters remains an open problem.

### 5.4 Toric Code Verification

We verify the rate–distance product bound for toric codes with L = 1 to 50:

| L | n | Rate | Rel. Dist. | Product | 1/L² | Ratio |
|---|---|------|-----------|---------|------|-------|
| 1 | 2 | 1.000 | 0.500 | 0.50000 | 1.0000 | 0.500 |
| 5 | 50 | 0.040 | 0.100 | 0.00400 | 0.0400 | 0.100 |
| 10 | 200 | 0.010 | 0.050 | 0.00050 | 0.0100 | 0.050 |
| 50 | 5000 | 0.0004 | 0.010 | 0.000004 | 0.0004 | 0.010 |

The bound is tight up to a factor of 1/(2L), confirming the 1/(2L³) vs 1/L² gap.

---

## 6. Formal Verification Details

### 6.1 Lean 4 Formalization

All theorems are formalized in Lean 4 (v4.28.0) with Mathlib. The main file `Physics/Quantum/BoundFeasibility.lean` contains:

- 5 definitions (CodeParams, admissibility predicates, classifier)
- 3 main theorems with complete proofs
- 12 supporting lemmas
- 4 concrete examples verified by `native_decide`
- 3 classifier correctness proofs

### 6.2 Axiom Audit

All proofs depend only on the standard axioms:
- `propext` (propositional extensionality)
- `Classical.choice` (axiom of choice)
- `Quot.sound` (quotient soundness)

No `sorry` statements, `axiom` declarations, or `@[implemented_by]` attributes are used.

### 6.3 Proof Techniques

The proofs use a variety of tactics:
- **Contrapositive reasoning** (`intro` + `exact`): Theorem 1
- **Transitivity chains** (`le_trans`, `calc`): Theorem 2
- **Field simplification** (`field_simp` + `nlinarith`): Theorem 3
- **Finset sum manipulation** (`Finset.sum_le_sum_of_subset_of_nonneg`, `Finset.range_mono`): Pauli ball monotonicity
- **Native decision** (`native_decide`): concrete examples
- **Case analysis** (`split_ifs`): classifier correctness

---

## 7. Discussion

### 7.1 Significance of Degeneracy Forcing

The degeneracy-forcing concept bridges two previously separate aspects of quantum coding theory:

1. **Bound analysis**: traditionally focused on proving impossibility results.
2. **Code construction**: traditionally focused on building specific codes.

Degeneracy forcing shows that bounds can do more than rule codes out—they can rule *mechanisms* out. This has immediate practical implications for stabilizer code search algorithms, which can now partition the search space into degenerate and nondegenerate sectors before commencing the search.

### 7.2 Topological Connections

The toric code analysis connects quantum coding theory to the geometry of surfaces. The BPT bound k·d² ≤ c·n (for 2D topological codes) is saturated by the toric code, which achieves k·d² = n. The rate–distance product bound we prove is a normalized version of this geometric constraint.

This suggests a broader program: formalizing efficiency bounds for code families defined by geometric or topological constraints, including surface codes on higher-genus surfaces, color codes on trivalent lattices, and hyperbolic codes.

### 7.3 Limitations

Our framework is inherently conservative: it can only rule out nondegenerate realizations, not prove existence. The jointly feasible classification does not guarantee that a code exists—only that these two bounds do not forbid it. Additional constraints (linear programming bounds, shadow enumerators, etc.) may further restrict the feasible region.

---

## 8. Future Work

1. **Extended bound integration**: Incorporate the linear programming bound and the shadow enumerator constraints to refine the three-way classification.

2. **Degeneracy frontier proof**: Prove or disprove the upward-closure conjecture (Conjecture 5.1) for general parameters.

3. **Higher-dimensional topological codes**: Extend the toric code analysis to 3D topological codes and hyperbolic codes, where the BPT bound takes a different form.

4. **Algorithmic applications**: Integrate the certified classifier into stabilizer code search tools, using verified parameter filtering to prune the search space.

5. **Degenerate code theory**: Develop a positive theory of degenerate codes in the degeneracy-forcing region, characterizing what properties such codes must have.

---

## References

[1] E. Knill and R. Laflamme, "Theory of quantum error-correcting codes," *Physical Review A*, vol. 55, no. 2, pp. 900–911, 1997.

[2] A.R. Calderbank, E.M. Rains, P.W. Shor, and N.J.A. Sloane, "Quantum error correction via codes over GF(4)," *IEEE Trans. Inform. Theory*, vol. 44, pp. 1369–1387, 1998.

[3] E.M. Rains, "Nonbinary quantum codes," *IEEE Trans. Inform. Theory*, vol. 45, pp. 1827–1832, 1999.

[4] P.W. Shor and R. Laflamme, "Quantum analogues of the main conjecture of classical coding theory," *Physical Review A*, vol. 56, p. R1, 1997.

[5] D. Gottesman, "Stabilizer Codes and Quantum Error Correction," PhD thesis, Caltech, 1997.

[6] A.Y. Kitaev, "Fault-tolerant quantum computation by anyons," *Annals of Physics*, vol. 303, no. 1, pp. 2–30, 2003.

[7] S. Bravyi, D. Poulin, and B. Terhal, "Tradeoffs for reliable quantum information storage in 2D systems," *Physical Review Letters*, vol. 104, p. 050503, 2010.
