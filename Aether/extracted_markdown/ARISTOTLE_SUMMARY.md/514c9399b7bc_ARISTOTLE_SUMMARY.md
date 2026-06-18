# Summary of changes for run cb8a7350-f1e2-4695-a49f-3ee4a44e1734
## Completed: Berggren Spectral Gap — Unipotency, Pell Recurrence, and Exponential Growth

### File: `Cryptography/BerggrenSpectralGap.lean`

A self-contained Lean 4 module establishing the **spectral dichotomy** of the three Berggren matrices A, B, C ∈ GL₃(ℤ) that generate the tree of all primitive Pythagorean triples. All 15 theorems compile with **zero sorries** and only standard axioms.

### Key Results (all fully proved)

**Spectral Structure (4 theorems):**
1. `matA_unipotent`: (A - I)³ = 0 — A is unipotent
2. `matA_nilpotency_exact`: (A - I)² ≠ 0 — nilpotency index is exactly 3 (full Jordan block)
3. `matC_unipotent`: (C - I)³ = 0 — C is also unipotent
4. `matB_cayley_hamilton_factored`: (B + I)(B² - 6B + I) = 0 — Cayley-Hamilton for B, revealing eigenvalues {-1, 3 ± 2√2}, spectral radius ρ(B) = 3 + 2√2 ≈ 5.83

**The Pell Recurrence (3 theorems):**
5. `matB_pell_row`: The third row of B² - 6B + I vanishes — the algebraic engine
6. `berggren_B_hyp_pell`: For **any** starting vector v, B-iteration satisfies c_{n+2} = 6c_{n+1} - c_n — a second-order linear recurrence whose characteristic roots 3 ± 2√2 are units in ℤ[√2]
7. `berggren_B_hyp_exponential_growth`: c_{n+1} ≥ 5·c_n for all n — exponential growth from (3,4,5)

**Universal Hypotenuse Growth (3 theorems):**
8. `berggren_hypA_gt`: For positive Pythagorean (a,b,c), the A-child hypotenuse > c
9. `berggren_hypB_gt`: B-child hypotenuse > 5c (tightest bound, from triangle inequality)
10. `berggren_hypC_gt`: C-child hypotenuse > c

**Plus:** Lorentz preservation for all three generators, spectral dichotomy witnesses, explicit Pell matrix computation, B-iteration verification for depths 0–2, and positivity of iterated hypotenuses.

### Mathematical Novelty

The main discovery is the **spectral dichotomy**: A and C are unipotent (eigenvalue 1, multiplicity 3) while B is hyperbolic (eigenvalues -1, 3 ± 2√2). This corrects the concept description's claim that all three matrices share spectral radius 2 + √3 — in fact only B has spectral radius > 1, and it equals 3 + 2√2 (not 2 + √3). The Pell recurrence for the hypotenuse under B-iteration is derived algebraically from the vanishing of the third row of B² - 6B + I, connecting the Berggren tree to the arithmetic of Pell equations in ℤ[√2].

### File: `FUTURE_DIRECTIONS.md`

Five research conjectures extending this work:
1. Full norm growth dichotomy for mixed words (polynomial × exponential)
2. Freeness of the Berggren semigroup via coordinate separation
3. Lattice successive minima from Pell asymptotics
4. Quantum hardness amplification via spectral type mixing
5. Berggren zeta function and its meromorphic continuation