# Summary of changes for run 27569ca5-8ba8-48fc-b066-da0fd78c998b
## Tropical p-Adic Berggren Factorization: Results

I've created two files in `Pythagorean/Berggren/`:

### 1. `TropicalPAdicBerggren.lean` — Fully verified Lean formalization (no sorries)

**Step 1 (Berggren Matrix Foundations) — Complete:**

- **Determinants** (corrected): `det(A) = 1`, `det(B) = -1`, `det(C) = 1`. Your brief incorrectly claimed `det(B) = 1`; it is actually `-1`. Matrix B is orientation-reversing.

- **Pythagorean preservation**: Proved in two ways:
  - Via Lorentz form preservation: `Mᵀ Q M = Q` for each M ∈ {A, B, C}, where Q = diag(1,1,-1). This extends to arbitrary products (`berggren_product_preserves_lorentz`).
  - Direct algebraic proofs for each matrix (`berggren_A/B/C_preserves_pyth`).

- **Characteristic polynomials** (corrected):
  - A and C are unipotent: χ = (λ-1)³, nilpotency order exactly 3.
  - B has characteristic polynomial λ³ - 5λ² - 5λ + 1 = (λ+1)(λ² - 6λ + 1), with eigenvalues -1, 3±2√2. This is **not** (λ-1)(λ-2)² as claimed — that relation is explicitly refuted (`berggren_B_not_user_charpoly`).

- **Concrete triple generation**: A·(3,4,5) = (5,12,13), B·(3,4,5) = (21,20,29), C·(3,4,5) = (15,8,17).

- **Path corrections**: The path to (15,8,17) is C alone, not B·A. The product B·A = [[9,-8,12],[8,-9,12],[12,-12,17]] (not [[-3,4,4],[-4,3,4],[-4,4,5]]), and B·A·(3,4,5) = (55,48,73).

### 2. `TropicalPAdicAnalysis.md` — Detailed mathematical analysis

**Steps 2 and 3 (Newton Polygon Conjecture) — Refuted:**

The Newton polygon conjecture fails at every base case. For each single-step Berggren path to a prime hypotenuse p, the p-adic valuations of all characteristic polynomial coefficients are 0, making the Newton polygon a trivial horizontal line carrying no information about p. This is because:

- For A and C (unipotent), the char poly is always (λ-1)³ with coefficients {-1, 3, -3, 1} — never divisible by any prime p ≥ 5.
- For B, the coefficients are {1, -5, -5, 1} — not divisible by 29 (or any larger hypotenuse prime).
- At depth 2, the same pattern holds (verified for hypotenuses 37, 53, 73, 89, 97).

The fundamental issue is a structural mismatch: the characteristic polynomial is an **intrinsic** invariant of the matrix (determined by trace, minors, determinant), while the hypotenuse is an **extrinsic** quantity (the third coordinate of a specific matrix-vector product). There is no algebraic mechanism connecting the p-adic properties of the former to the prime factorization of the latter.

**What IS true**: The Berggren matrices form a subgroup of O(2,1; ℤ), the integer indefinite orthogonal group. The correct framework for connecting Pythagorean triples to factorization is the arithmetic of Gaussian integers (a + bi = (m+ni)² in ℤ[i]), not spectral theory of the path matrices.

All 25+ theorems compile without sorry and use only standard axioms.