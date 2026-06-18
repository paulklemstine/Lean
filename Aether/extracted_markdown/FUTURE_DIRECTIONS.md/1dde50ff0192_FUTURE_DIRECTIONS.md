# Future Directions

## Hypothesis 1: Parametric Paley Certification

**Conjecture**: For every prime p ≡ 3 (mod 4), the Paley Type I construction produces a certified Hadamard matrix of order p + 1, provable in Lean 4 using Mathlib's finite field and quadratic character infrastructure.

**Test**: Formalize the Jacobsthal matrix Q over 𝔽_p using `ZMod p` and the Legendre symbol `legendreSym`. Prove Q · Q^T = pI − J (where J is all-ones) using character sum identities (specifically, the evaluation of ∑_{t ∈ 𝔽_p} χ(t)χ(t+a) for the quadratic character χ). Then lift to ℤ and verify the Paley matrix [[1, j^T], [−j, Q+I]] satisfies HH^T = (p+1)I.

**Refutation**: The conjecture would be refuted if Mathlib's character sum infrastructure is insufficient to prove the key orthogonality ∑_{t} χ(t)χ(t+a) = −1 for a ≠ 0, which requires the explicit evaluation of Jacobi sums. Verify by attempting the formalization for p = 3 and p = 7 as test cases.

**Impact**: Would provide a formally certified infinite family of Hadamard orders of the form p + 1 (primes p ≡ 3 mod 4), immediately generating thousands of new certified orders via Kronecker closure. This is the single highest-impact extension of the current work.

---

## Hypothesis 2: Formal Hadamard-BIBD Bridge

**Conjecture**: From a normalized Hadamard matrix H of order 4n (formalized in Lean), the (4n−1) × (4n−1) core incidence matrix A (defined by A_{ij} = (1 − H_{i+1,j+1})/2) satisfies the symmetric BIBD equations:
- Each row sum equals 2n − 1
- A · A^T = (n−1)I + (2n−1−n+1)·(J − I) ... more precisely, A · A^T = nI + (n−1)J_reduced

**Test**: Define the extraction map from normalized Hadamard matrices to binary incidence matrices in Lean 4. Prove the row-sum and Gram matrix identities using the dot-product lemmas already formalized. Start with the n = 1 case (trivial 3×3 design from H₄) and generalize.

**Refutation**: The conjecture could fail if the formalization of "deleting a row and column" introduces intractable type-theoretic complications with `Fin (4n)` vs `Fin (4n − 1)`. Test by attempting the extraction for the explicit H₄ first.

**Impact**: Would formally bridge Hadamard matrix theory to combinatorial design theory, enabling certified BIBD constructions for all certified Hadamard orders. This opens the door to formal finite geometry.

---

## Hypothesis 3: Kronecker Saturation Density

**Conjecture**: The density of certified Hadamard orders (as a fraction of all multiples of 4) within [4, N] converges to a positive limit as N → ∞, and this limit is at least 0.8 when using Sylvester + Paley Type I + Paley Type II + Kronecker closure.

**Test**: Implement the certified existence engine for N up to 10,000 and 100,000. Compute the coverage fraction and fit an asymptotic model. Compare with theoretical predictions from the density of Paley primes (which has density 1/2 among primes by Dirichlet's theorem, giving positive Kronecker density).

**Refutation**: If the coverage fraction drops below 0.7 for N = 100,000, or if the growth rate is sub-logarithmic rather than polynomial, the conjecture is likely false. Specific counterexamples: orders like 4 · p where p is a prime ≡ 1 (mod 4) and neither p−1 nor 2p−1 is a prime power may create persistent gaps.

**Impact**: A positive density result would quantify exactly how much of the Hadamard conjecture is resolved by classical constructions, sharpening the frontier of the remaining open problem.

---

## Hypothesis 4: Equivalence Class Distinguishability

**Conjecture**: Inequivalent Hadamard matrices of the same order n ≥ 16 can be distinguished by a formally computable invariant based on the spectrum of the "row intersection graph" — where vertices are rows and edge weights are |⟨r_i, r_j⟩| (which is 0 for Hadamard matrices, but becomes non-trivial after normalization and core extraction).

**Test**: For the 5 known inequivalent Hadamard matrices of order 16:
1. Normalize each matrix
2. Compute the core (delete first row/column)
3. Build the intersection matrix: I_{ij} = #{k : core_{ik} = core_{jk} = 1}
4. Compute the spectrum (eigenvalues) of I
5. Check if spectra distinguish all 5 inequivalent classes

**Refutation**: Find two inequivalent Hadamard matrices of the same order with identical intersection spectra. This would demonstrate that the invariant is too coarse.

**Impact**: A successful distinguishing invariant would provide a certified equivalence test for Hadamard matrices, enabling formal enumeration of equivalence classes for small orders.

---

## Hypothesis 5: Code Optimality Certificate

**Conjecture**: The equidistant binary code extracted from an n × n Hadamard matrix (2n codewords, length n, distance n/2) meets the Plotkin bound with equality, and this can be formally proved in Lean 4.

**Test**: 
1. Formalize the Plotkin bound: for a binary code with M codewords of length n and minimum distance d, if d is even and 2d > n, then M ≤ 2d/(2d − n). For 2d = n (our case), the bound becomes M ≤ 2n.
2. Verify that the Hadamard code achieves M = 2n with d = n/2.
3. Prove equality in the Plotkin bound.

**Refutation**: The conjecture could fail if the Plotkin bound in its standard form doesn't exactly match the Hadamard code parameters (e.g., if the bound gives M ≤ 2n but equality requires additional conditions). Check the exact bound statement.

**Impact**: Would provide the first formally certified optimality result in coding theory, connecting Hadamard matrices to extremal combinatorics. This would demonstrate that Hadamard codes are not merely good but provably best possible among equidistant codes.
