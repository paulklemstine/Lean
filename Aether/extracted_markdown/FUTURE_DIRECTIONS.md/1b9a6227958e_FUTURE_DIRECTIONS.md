# Future Directions: Symmetric Square Transfer and Langlands Functoriality

## 1. Trace-Det Sufficiency for All Symmetric Powers

- **Hypothesis:** For every `n : ℕ`, the local Euler denominator of `Symⁿ` of a rank-2 parameter is a polynomial whose coefficients are universal polynomials in `trace = α + β` and `det = αβ`. Specifically, the denominator `∏ᵢ₌₀ⁿ (1 - αⁱβⁿ⁻ⁱ X)` can be written as a degree-(n+1) polynomial in X whose coefficients are elements of `ℤ[t, d]`.
- **Why it matters:** This would establish that functorial transfer for all symmetric powers depends only on conjugacy-invariant data, giving a complete algebraic foundation for the local Langlands correspondence for symmetric power lifts. It would also provide certified formulas for Hecke eigenvalues of all symmetric power L-functions.
- **Test:** Prove the `n = 3` case in Lean:
  ```lean
  theorem symmCube_denominator_in_trace_det (α β X : ℂ) :
      (1 - α^3 * X) * (1 - α^2 * β * X) * (1 - α * β^2 * X) * (1 - β^3 * X)
        = 1 - ((α+β)^3 - 2*(α+β)*(α*β)) * X + ... -- expand in t, d
  ```
  Alternatively, find a formal obstruction in the current API or produce counterexample for a specific n.
- **First step:** Define `symmPowerParameter (n : ℕ) (α β : ℂ) : Fin (n+1) → ℂ := fun i => α^(n-i) * β^i` and prove the n=3 denominator identity.

## 2. Semisimple Matrix Conjugacy Invariance

- **Hypothesis:** The symmetric-square local Euler factor depends only on the conjugacy class of a semisimple 2×2 matrix, not on its diagonalization. Concretely: if M, M' ∈ GL₂(ℂ) are conjugate (M' = P⁻¹MP for invertible P), then the symmetric square Euler denominators computed from their eigenvalues are equal.
- **Why it matters:** This would validate the representation-theoretic axiom that L-factors are conjugacy-class invariants, and would connect the eigenvalue-based formalization to the matrix-based formulation needed for non-split tori and ramified representations.
- **Test:** Prove equality for conjugate diagonalizable matrices in Lean:
  ```lean
  theorem symmSquare_euler_conjugacy_invariant (α β : ℂ) (P : Matrix (Fin 2) (Fin 2) ℂ)
      (hP : IsUnit P) (X : ℂ) :
      localEulerSymmSquare ⟨α, β⟩ X = localEulerSymmSquare ⟨α, β⟩ X
  ```
  More substantively, define `eigenvalues_of_matrix` and show `symmSquare_euler` factors through it. Identify which Mathlib lemmas about `Matrix.charpoly` and eigenvalue extraction are needed.
- **First step:** Formalize `charpolyCoeffs_conjugacy_invariant` showing that characteristic polynomial coefficients are conjugation-invariant, then derive the Euler factor invariance.

## 3. Finite Euler Product Coefficient Identities

- **Hypothesis:** The first nontrivial coefficient (coefficient of X) of a finite symmetric-square Euler product `∏_{v ∈ S} P_v(X)` equals the sum over local transformed traces: `- ∑_{v ∈ S} (α_v² + α_v β_v + β_v²)`. More generally, the k-th coefficient of the product is an elementary symmetric polynomial in the local symmetric-square traces.
- **Why it matters:** This connects local functoriality to global L-function coefficient formulas, the exact data needed for computational verification of the Langlands correspondence via modular form databases (LMFDB).
- **Test:** Expand the product over Finsets of sizes 1, 2, 3 and verify coefficient formulas:
  ```lean
  theorem finite_euler_linear_coeff (S : Finset ι) (α β : ι → ℂ) :
      -- coefficient of X in ∏_{v ∈ S} (1 - (α_v² + α_vβ_v + β_v²)X + ...)
      -- equals -∑_{v ∈ S} (α_v² + α_vβ_v + β_v²)
  ```
  Verify computationally for |S| = 1, 2, 3 using `#eval` over `ℚ`.
- **First step:** Define `symmSquareEulerPoly (α β : ι → ℂ) (v : ι) : Polynomial ℂ` as the formal cubic polynomial, then compute `(∏ v in S, symmSquareEulerPoly α β v).coeff 1`.

## 4. Palindromicity Under Determinant-One Normalization for Higher Symmetric Powers

- **Hypothesis:** For every `n : ℕ`, the local `Symⁿ` denominator polynomial with `det = αβ = 1` satisfies a self-reciprocity relation: `X^(n+1) · P(X⁻¹) = (-1)^(n+1) · P(X)` where P(X) = ∏ᵢ₌₀ⁿ (1 - αⁱβⁿ⁻ⁱ X).
- **Why it matters:** Palindromicity (functional equation symmetry) is the local manifestation of the global functional equation of L-functions. Proving it algebraically for all symmetric powers would give a certified local functional equation without analytic continuation.
- **Test:** Prove for n = 2 (already done as `symmSquare_palindromic_det_one` conceptually) and n = 3:
  ```lean
  theorem symmCube_palindromic_det_one (α β X : ℂ) (h : α * β = 1) :
      (1 - α^3*X) * (1 - α*X) * (1 - β*X) * (1 - β^3*X)
        = X^4 * ((1 - α^3*X⁻¹) * (1 - α*X⁻¹) * (1 - β*X⁻¹) * (1 - β^3*X⁻¹))
  ```
  Or produce a counterexample to the guessed sign/exponent normalization.
- **First step:** Prove `symmSquare_palindromic_det_one` rigorously (handling X⁻¹ for X ≠ 0 via a hypothesis or working with formal polynomials instead), then generalize.

## 5. Bridge to Certified Spectral Transfer Framework

- **Hypothesis:** There exists an abstract "spectral transfer" typeclass encompassing both iterative spectral bounds (as in spectral radius transfer for dynamical systems) and local Langlands symmetric-power transfer, unifying them through a common interface of: (1) source spectrum type, (2) transfer map, (3) invariant polynomial controlling the transferred spectrum.
- **Why it matters:** This would create a reusable formal framework connecting disparate areas of mathematics — dynamical systems, number theory, and representation theory — through their shared structure of spectral data transformation. It would enable code reuse and cross-pollination of proof techniques.
- **Test:** Define a typeclass and instantiate both examples:
  ```lean
  class SpectralTransfer (Source Target : Type*) where
    transferMap : Source → Target
    invariantPoly : Source → Polynomial ℂ
    transfer_respects_invariant : ∀ s, invariantPoly s = charPoly (transferMap s)

  instance : SpectralTransfer LocalGL2Parameter (ℂ × ℂ × ℂ) where ...
  ```
  Identify the obstruction if no clean common interface exists.
- **First step:** Define `SpectralTransfer` structure, instantiate for symmetric square, and attempt to instantiate for one other spectral transfer example in the codebase.
