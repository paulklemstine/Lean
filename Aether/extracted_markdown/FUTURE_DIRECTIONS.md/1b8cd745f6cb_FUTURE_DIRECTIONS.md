# Future Directions: Hadamard Matrix Theory in Lean 4

## 1. Paley Construction and Quadratic Residues

Formalize the Paley construction: for any prime power q ≡ 3 (mod 4), there exists a Hadamard matrix of order q + 1. This requires formalizing Jacobi matrices from quadratic residue characters over finite fields and proving the resulting conference matrix satisfies the Hadamard orthogonality condition.

The key insight is that the quadratic residue character χ of GF(q) naturally produces a conference matrix C with C·Cᵀ = (q-1)I + J, and the bordered matrix [1 jᵀ; j C+I] is Hadamard of order q+1.

Why now? Mathlib already has substantial finite field theory (`ZMod`, `legendreSym`, `quadraticChar`) and the Hadamard infrastructure (definitions, tensor closure, obstruction) is fully formalized in this project. The Paley construction would be the first non-power-of-two infinite family of Hadamard orders, dramatically expanding the set of proven Hadamard orders beyond the Sylvester family.

## 2. Hadamard Maximal Determinant Bound

Prove the full Hadamard bound: for any n×n matrix M with |M_{ij}| ≤ 1, we have |det M| ≤ n^(n/2), with equality if and only if M is a (real) Hadamard matrix. We already proved det(H)² = n^n for ±1 Hadamard matrices. The converse direction — that equality in the determinant bound forces the Hadamard orthogonality condition — would complete the characterization.

The key insight is that the AM-GM inequality applied to the Gram matrix eigenvalues gives det(MMᵀ) ≤ (tr(MMᵀ)/n)^n = n^n, with equality iff all eigenvalues are equal (i.e., MMᵀ = nI).

Why now? The forward direction (det² = n^n) is already proved in `Spectral.lean`. Formalizing the bound requires Mathlib's spectral theory for Hermitian matrices and eigenvalue inequalities, which are increasingly available.

## 3. Equivalence Classification for Small Orders

Formalize the classification of Hadamard equivalence classes for small orders. For n = 1, 2, 4, 8, there is exactly one equivalence class; for n = 12, there are exactly 1 class; for n = 16, there are exactly 5 inequivalent Hadamard matrices. Prove the uniqueness results for n ≤ 12 by exhaustive case analysis on normalized forms.

The key insight is that after normalization (first row and column all 1s), the remaining (n-1)×(n-1) submatrix has very constrained structure: its rows must be orthogonal ±1 vectors that are all orthogonal to the all-ones vector, and for small n this forces a unique solution up to equivalence.

Why now? The `HadamardEquivalent` relation and `IsNormalizedHadamard` are already defined. For n = 4, the proof is a finite computation; `native_decide` or `Decidable` instances could handle it. This would be the first verified classification result in Hadamard theory.

## 4. Hadamard–BIBD Bridge Theorem

Complete the bridge between Hadamard matrices and symmetric balanced incomplete block designs. We have the counting lemmas (row-pair intersection counts). The missing piece is constructing the actual BIBD: from a normalized Hadamard matrix of order 4t, extract the incidence matrix of a symmetric 2-(4t-1, 2t-1, t-1) design and verify all BIBD axioms.

The key insight is that the ±1 → {0,1} conversion of the non-trivial rows/columns of a normalized Hadamard matrix directly yields the incidence matrix, and the Hadamard orthogonality conditions translate exactly into the BIBD pair-counting condition.

Why now? The `SymmetricBIBD` structure and the `normalized_row_pair_ones` theorem (showing the intersection count is n/4) are already formalized in `Design.lean`. The construction of the actual BIBD instance is the natural next step.

## 5. Williamson Construction and Circulant Hadamard Matrices

Formalize the Williamson construction: given four symmetric circulant ±1 matrices A, B, C, D of order n satisfying AᵀA + BᵀB + CᵀC + DᵀD = 4nI, construct a Hadamard matrix of order 4n. This construction covers many orders not reachable by Sylvester or Paley alone.

The key insight is that the block matrix [[A B C D]; [-B A -D C]; [-C D A -B]; [-D -C B A]] is Hadamard whenever the Williamson equation holds, because the block structure ensures row orthogonality via the four-square identity.

Why now? The tensor product infrastructure (Kronecker product, `hadamardOrder'_mul`) provides the algebraic foundation. Formalizing circulant matrices and the Williamson equation would open the door to verifying Hadamard existence for specific orders like 12, 20, 28, 36 — filling gaps in the construction landscape beyond powers of two.
