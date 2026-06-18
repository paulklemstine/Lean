# Future Directions: Quantum Stabilizer Code Bounds

This document identifies five concrete, testable research hypotheses emerging directly from the formalized quantum coding theory. Each is a precise, falsifiable conjecture with a well-defined test.

---

### 1. Complete Classification of Perfect Stabilizer Codes at Distance 3

**Conjecture.** Every nondegenerate perfect binary stabilizer code correcting one error has parameters [[n, k, 3]] where n = (4^m − 1)/3 and k = n − 2m for some integer m ≥ 2. The infinite family of arithmetic solutions to 1 + 3n = 2^{n−k} is exhaustive: there are no "sporadic" perfect stabilizer codes at distance 3.

**Why it matters.** Our formal verification confirms [[5,1,3]] is the unique MDS perfect code at distance 3, and computational search reveals the full infinite family (n, k) = ((4^m − 1)/3, (4^m − 1)/3 − 2m). But existence of stabilizer codes with these parameters for all m > 3 is unknown. If confirmed, this would show perfect quantum codes are completely classified (analogous to the Tietäväinen–van Lint theorem for classical codes).

**Test.** 
- Formalize the constraint that stabilizer code parameters must satisfy: the stabilizer group must be isotropic in F₂^{2n} with the correct rank. Implement an exhaustive search over GF(2) matrices for m = 3, 4, 5 to check existence.
- In Lean: prove that the Diophantine equation 1 + 3n = 2^{n−k} has solutions exactly when n = (4^m − 1)/3, by showing 2^{2m} ≡ 1 (mod 3) and 2^{2m+1} ≢ 1 (mod 3).

---

### 2. Toric Codes Are Asymptotically Hamming-Loose

**Conjecture.** For toric code parameters [[2L², 2, L]], the Hamming packing ratio

    R(L) = hammingSum(2L², (L−1)/2) / 2^{2L²−2}

satisfies R(L) → 0 as L → ∞. More precisely, log₂(R(L)) = −Θ(L²) as L → ∞.

**Why it matters.** This quantifies the gap between the nondegenerate Hamming bound and the actual performance of toric codes. Toric codes are highly degenerate — many distinct errors produce the same syndrome but map to the same logical operation. This conjecture, if proved, would formally demonstrate that degeneracy is essential for topological codes and that the nondegenerate Hamming bound is the wrong metric for evaluating them.

**Test.**
- Compute R(L) numerically for L = 2, 3, ..., 20. Verify the log₂(R(L)) ∼ −Θ(L²) scaling.
- In Lean: prove the weaker statement that hammingSum(2L², 1) / 2^{2L²−2} → 0, which reduces to showing (1 + 6L²) · 2^{−(2L²−2)} → 0.
- For the full conjecture, use Stirling-type bounds on binomial coefficients to bound hammingSum from above.

---

### 3. CSS Rank Imbalance Sharpens the Hamming Bound

**Conjecture.** For a CSS code [[n, k, d]] arising from classical codes C₁ ⊂ C₂ with dim(C₂) − dim(C₁) = k, if the X-distance dX and Z-distance dZ satisfy dX ≠ dZ, then the effective Hamming bound

    Σ_{i=0}^{tX} 3^i C(n, i) + Σ_{i=0}^{tZ} 3^i C(n, i) ≤ 2^{n−k+1}

is strictly tighter than the standard stabilizer Hamming bound with d = min(dX, dZ).

**Why it matters.** Current formal bounds treat CSS codes identically to generic stabilizer codes. But CSS codes have additional structure (the X and Z stabilizers are independent) that should yield tighter constraints. If this conjecture holds, it would provide the first formal improvement to the Hamming bound for a structured code family, with implications for quantum LDPC code design.

**Test.**
- Define CSSCodeParams with separate dX, dZ in Lean (already done in our framework).
- Compute both bounds numerically for families like the Steane code (dX = dZ = 3) and asymmetric CSS codes.
- Formalize the "CSS Hamming bound" and prove it implies the standard bound as a special case when dX = dZ.

---

### 4. The BPT Bound kd² ≤ cn Is Certifiably Tight for 2D Codes

**Conjecture.** For any family of 2D local stabilizer codes with geometric locality on a planar or toroidal lattice, the bound kd² ≤ cn holds with c = 1 (not merely c = O(1)). The toric code saturates this with equality: kd² = n.

**Why it matters.** The Bravyi-Poulin-Terhal (BPT) theorem proves kd² = O(n) for 2D local codes, but the constant c is not optimized. Our formal verification shows toric codes achieve c = 1 exactly. If c = 1 is optimal, it would give hardware engineers a sharp formula for the fundamental tradeoff between logical qubits, code distance, and physical qubit count in any 2D quantum memory.

**Test.**
- Define a Lean structure for "2D local stabilizer codes" with axioms: (i) qubits on vertices of a planar graph, (ii) stabilizer generators act on bounded-size neighborhoods.
- Verify c = 1 for surface codes, color codes, and other known 2D families.
- Search for counterexamples where kd² > n by constructing non-standard 2D codes.
- Attempt a formal proof of kd² ≤ n under 2D locality axioms, using the isoperimetric inequality on planar graphs.

---

### 5. Entropy Defect Bounds the Minimum Distance

**Conjecture.** For a stabilizer code [[n, k, d]] and any single-qubit erasure channel with erasure probability p, the entropy defect δ(p) = nH(p) − S(ρ_out) satisfies

    δ(p) ≥ (d − 1) · h(p)

where h(p) = −p log p − (1−p) log(1−p) is the binary entropy function and S is the von Neumann entropy. In other words, the entropy defect per erased qubit is at least proportional to d − 1.

**Why it matters.** This would establish a formal bridge between information-theoretic entropy bounds (already partially formalized in the codebase via `post_quantum_security_entropy_defect_bound`) and the combinatorial code distance. It would unify two threads of quantum information theory: channel capacity arguments and stabilizer code combinatorics. A formal proof would enable certified entropy-based security arguments in quantum key distribution protocols using stabilizer codes.

**Test.**
- Compute δ(p) numerically for the five-qubit code (d = 3), Steane code (d = 3), and toric code (d = L) at various erasure rates.
- In Lean: formalize the erasure channel output entropy for a stabilizer code using the existing von Neumann entropy definitions.
- Prove the lower bound for the simplest case (single-qubit code, d = 1) as a warm-up, then generalize.
- Connect to the existing `syndrome_log_bound` theorem to bound the entropy from the syndrome space dimension.

---

## Prioritization

| Direction | Difficulty | Impact | Dependencies |
|-----------|-----------|--------|--------------|
| 1. Perfect classification | Medium | High | Diophantine analysis + GF(2) linear algebra |
| 2. Toric Hamming looseness | Low | Medium | Asymptotic analysis of binomial sums |
| 3. CSS rank refinement | Medium | High | CSS formalization + comparison theorem |
| 4. BPT tightness | High | Very High | 2D locality axioms + isoperimetric theory |
| 5. Entropy-distance bridge | High | Very High | von Neumann entropy + channel coding theory |

**Recommended next step:** Direction 2 (toric Hamming looseness), as it requires the least new infrastructure and directly extends the current formal framework with a publishable asymptotic result.
