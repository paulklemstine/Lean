# Future Directions: Paley-Hadamard Design Factory

## Hypothesis 1: Menon Lift Hypothesis

**Conjecture:** Every formally certified Menon difference set yields a Hadamard matrix through the generic sign-matrix Gram theorem (`differenceSet_sign_gram`), with no new matrix algebra lemmas required.

**Test:** Instantiate on the smallest nontrivial Menon parameter set (16, 6, 2). The Menon difference set in ℤ/16ℤ (or a suitable abelian group of order 16) should satisfy `IsDifferenceSet D 16 6 2`, and the sign-matrix Gram identity should immediately yield a 16×16 matrix with `A * Aᵀ = 16 • I + 0 • J = 16I`, certifying a Hadamard matrix.

**Pass/Fail Criterion:** The theorem `differenceSet_sign_gram` applied to a Menon (16,6,2) difference set produces the Hadamard identity without any additional lemma, and `native_decide` confirms the concrete instance.

**Impact if true:** This would demonstrate that the difference-set infrastructure is genuinely reusable: Hadamard matrices from Menon constructions (which arise from group rings and character theory) flow through exactly the same formal pipeline as Paley constructions, with zero additional proof effort. This validates the "certified factory" concept.

---

## Hypothesis 2: Singer-to-Projective-Plane Hypothesis

**Conjecture:** The generic difference-set incidence Gram identity (`differenceSet_incidence_gram`) is sufficient to derive the incidence axioms of a finite projective plane from Singer parameters in a machine-checked proof.

**Test:** Starting from the Singer (7,3,1) difference set (already certified as `singer_7_3_1`), prove that the incidence matrix satisfies:
1. Every pair of distinct "points" shares exactly λ = 1 "line."
2. Every pair of distinct "lines" shares exactly 1 "point."
3. Each line contains k = 3 points; each point lies on k = 3 lines.

These are the axioms of the Fano plane PG(2,2).

**Pass/Fail Criterion:** A theorem of the form
```
theorem singer_yields_fano_plane (D : Finset (ZMod 7)) (hD : IsDifferenceSet D 7 3 1) :
  IsProjectivePlaneIncidence (differenceSetIncidenceMatrix D)
```
compiles without sorry.

**Impact if true:** This creates a formal bridge from number theory (Singer's theorem on cyclic difference sets) to finite geometry (projective planes). It would be the first machine-verified derivation of a projective plane from character-theoretic data, connecting algebra, combinatorics, and geometry in a single certified pipeline.

---

## Hypothesis 3: Finite-Field Character Abstraction Hypothesis

**Conjecture:** A single quadratic-character API over arbitrary finite fields (not just prime fields) suffices to derive both the Paley graph strongly regular parameters and the Paley Type II Hadamard family, using the same core correlation lemma.

**Test:** Formalize the quadratic character correlation identity
```
∑ₜ χ(t - a) · χ(t - b) = q - 2  if a = b (and a ≠ 0)
                        = -1     if a ≠ b
```
over `K : Type` with `[Field K] [Fintype K]`, then derive:
- The Paley graph SRG parameters for q = 13 (prime field).
- The Hadamard identity for q = 9 (non-prime field, GF(3²)).

Both should follow from the same lemma with no case-splitting on primality.

**Pass/Fail Criterion:** A single `quadChar_correlation` lemma parameterized by `[Field K] [Fintype K]` (not `[Fact p.Prime]`) produces both results. The q = 9 case does not require any lemma not also used for q = 13.

**Impact if true:** This would prove that the finite-field abstraction barrier has been genuinely crossed. Currently, most formalized number-theoretic results are locked to prime fields (ZMod p). Lifting to arbitrary finite fields would open:
- Paley Type II for q = 25, 49, 121, ... (all prime squares with q ≡ 1 mod 4)
- An infinite certified Hadamard family beyond anything achievable with prime-only methods
- Reusable character infrastructure for future Gauss/Jacobi sum formalization

---

## Hypothesis 4: Spectral Transfer Hypothesis

**Conjecture:** Every certified difference-set sign matrix yields a certified two- or three-eigenvalue adjacency operator after an explicit normalization, with eigenvalues computable from the (v, k, λ) parameters alone.

**Test:** For each of the following difference sets:
- Singer (7, 3, 1): eigenvalues of A should be {6, −1} (two-eigenvalue, i.e., complete bipartite-like).
- Paley residues in F₁₃ (13, 6, 2): eigenvalues of A should be {6, (−1 ± √13)/2} (three-eigenvalue SRG spectrum).
- Menon (16, 6, 2): eigenvalues of A should be {6, −2} (two-eigenvalue Hadamard).

Verify that the sign-matrix Gram identity immediately implies the eigenvalue structure.

**Pass/Fail Criterion:** A theorem of the form
```
theorem differenceSet_eigenvalues (hD : IsDifferenceSet D v k lam) :
  ∀ μ, IsEigenvalue (differenceSetSignMatrix D) μ →
    μ = ... ∨ μ = ... ∨ μ = ...
```
compiles using only `differenceSet_sign_gram` and standard spectral theory.

**Impact if true:** This would formally connect combinatorial design theory to spectral graph theory in a single pipeline. Every new difference set automatically produces a certified spectral decomposition, enabling:
- Formal proofs of expansion properties (Cheeger inequality applications)
- Certified eigenvalue bounds for pseudorandom constructions
- Machine-verified spectral analysis of combinatorial objects

---

## Hypothesis 5: Kronecker Coverage Hypothesis

**Conjecture:** Combining Paley Type II certification (orders 12, 20, 28, ...) with Sylvester (powers of 2) and Kronecker product closure raises the formally certified Hadamard-order coverage to at least 80% of all multiples of 4 up to N = 1000.

**Test:** Write an executable Lean or Python checker that:
1. Starts with certified base orders: {1, 2, 4, 8, 12, 16, 20, 24, 28, ...}
2. Closes under multiplication (Kronecker product preserves Hadamard property)
3. Counts how many multiples of 4 up to N = 1000 are covered

The current Python computation shows 78.0% coverage at N = 1000.

**Pass/Fail Criterion:** The coverage exceeds 80% at N = 1000 and exceeds 65% at N = 10,000.

**Impact if true:** This would demonstrate that the Paley + Sylvester + Kronecker pipeline is practically sufficient for certifying the vast majority of known Hadamard orders. It would also identify exactly which orders require additional constructions (e.g., the Williamson, Turyn, or Goethals-Seidel methods), producing an explicit "gap list" that drives the next round of formalization.

**Additional prediction:** The gap at N = 92 (the smallest multiple of 4 not covered by known simple constructions) would appear prominently, confirming it as the critical frontier for Hadamard matrix existence theory.
