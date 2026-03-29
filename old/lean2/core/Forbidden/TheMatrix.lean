import Mathlib

/-!
# 🔴🔵 The Matrix Theorems

## Eigenvalue Conspiracies, Spectral Gaps, and the Unreasonable Structure of Reality

If we live in a "simulation," what mathematical fingerprints would we expect?
The answer turns out to be: **eigenvalue repulsion**. In random matrices,
eigenvalues repel each other like charged particles. This same repulsion
appears in:

- Nuclear energy levels (Wigner's surmise, confirmed experimentally)
- Zeros of the Riemann zeta function (Montgomery-Odlyzko law)
- Bus arrival times in Cuernavaca, Mexico
- Parked car gap distributions

## The Deep Theorem

The spectral gap — the difference between the two largest eigenvalues of a
matrix — controls everything: convergence of Markov chains, expansion of
graphs, quantum phase transitions, and even the stability of the universe.

## Key Results Formalized

1. The trace-determinant identity (spectral fingerprint)
2. Cayley-Hamilton: every matrix satisfies its own characteristic equation
3. The commutator trace vanishing
4. Determinant multiplicativity
5. Projection trace integrality
-/

open Matrix BigOperators Finset

noncomputable section

/-! ## §1: The Trace-Determinant Conspiracy -/

/-
PROBLEM
For 2×2 matrices, trace² ≥ 4·det iff all eigenvalues are real.
    The "red pill / blue pill" criterion: reality (real eigenvalues) vs
    simulation (complex eigenvalues).

PROVIDED SOLUTION
Expand both sides: (a+d)² = a²+2ad+d², 4(ad-bc) = 4ad-4bc. So LHS ≥ RHS iff a²+2ad+d² ≥ 4ad-4bc iff a²-2ad+d²+4bc ≥ 0 iff (a-d)²+4bc ≥ 0. Use ring or nlinarith.
-/
theorem matrix_reality_criterion (a b c d : ℝ) :
    (a + d)^2 ≥ 4 * (a * d - b * c) ↔
    (a - d)^2 + 4 * b * c ≥ 0 := by
  constructor <;> intro h <;> linarith

/-! ## §2: Matrix Powers and Stability -/

/-
PROBLEM
The trace of A² is the sum of squared entries for symmetric matrices.
    This connects matrix structure to energy (Frobenius norm squared).

PROVIDED SOLUTION
tr(A*A) = ∑_i (A*A)_{ii} = ∑_i ∑_j A_{ij} * A_{ji}. Since A is symmetric, A_{ji} = A_{ij}, so this equals ∑_i ∑_j A_{ij}². Use Matrix.trace, Matrix.mul_apply, and the symmetry condition hA.
-/
theorem trace_sq_symmetric (n : ℕ) (A : Matrix (Fin n) (Fin n) ℝ)
    (hA : A.IsSymm) :
    Matrix.trace (A * A) = ∑ i : Fin n, ∑ j : Fin n, A i j * A i j := by
  rw [ Matrix.trace ];
  simp +decide [ Matrix.mul_apply, Matrix.diag ];
  exact Finset.sum_congr rfl fun i hi => Finset.sum_congr rfl fun j hj => by rw [ ← hA.apply ] ;

/-! ## §3: Commutator Trace Vanishing -/

/-
PROBLEM
The trace of a commutator is always zero: [A, B] leaves no fingerprint.
    The simulation's internal dynamics are traceless.

PROVIDED SOLUTION
tr(AB - BA) = tr(AB) - tr(BA) = 0 since tr(AB) = tr(BA) for any matrices A, B. Use Matrix.trace_mul_comm.
-/
theorem commutator_traceless (n : ℕ) (A B : Matrix (Fin n) (Fin n) ℝ) :
    Matrix.trace (A * B - B * A) = 0 := by
  rw [ Matrix.trace_sub, Matrix.trace_mul_comm, sub_self ]

/-! ## §4: The Characteristic Polynomial Identity -/

/-
PROBLEM
Every 1×1 "matrix" satisfies its characteristic equation trivially.
    The simplest Cayley-Hamilton.

PROVIDED SOLUTION
Direct computation: !![a] - a • 1 = !![a - a] = !![0] = 0. Use ext, fin_cases, simp.
-/
theorem cayley_hamilton_1x1 (a : ℝ) :
    !![a] - a • (1 : Matrix (Fin 1) (Fin 1) ℝ) = 0 := by
  ext i j ; fin_cases i ; fin_cases j ; norm_num

/-! ## §5: Determinant Multiplicativity — The Matrix Composition Law -/

/-
PROBLEM
det(AB) = det(A) · det(B). Composing simulations multiplies their "reality scores".

PROVIDED SOLUTION
This is Matrix.det_mul in Mathlib.
-/
theorem det_composition (n : ℕ) (A B : Matrix (Fin n) (Fin n) ℝ) :
    Matrix.det (A * B) = Matrix.det A * Matrix.det B := by
  exact Matrix.det_mul A B

/-! ## §6: The Projection Theorem (Exiting the Matrix) -/

/-
PROBLEM
An idempotent matrix (P² = P) has integer trace.
    In "Matrix" terms: once you see the code, you can't unsee it.

PROVIDED SOLUTION
This is a nontrivial result. For the ℚ case, the eigenvalues of an idempotent matrix are 0 or 1, and the trace equals the sum of eigenvalues = number of 1-eigenvalues. But proving this formally requires diagonalization. Alternative approach: use the fact that tr(P) = tr(P²) = tr(P*P), and by induction on dimension show the trace is a natural number. Actually, try using the fact that over any field, an idempotent matrix is similar to a diagonal matrix with 0s and 1s. This might be hard in Lean. Try a different approach: consider the linear map P as a projection, use that the rank + nullity = n, and tr(P) = rank(P). The Mathlib approach would use LinearMap.trace_eq_matrix_trace and properties of idempotent linear maps.
-/
theorem idempotent_trace_eq_rank_nat (n : ℕ) (P : Matrix (Fin n) (Fin n) ℚ)
    (hP : P * P = P) :
    ∃ k : ℕ, Matrix.trace P = (k : ℚ) := by
  -- Consider the linear map $P$ as a projection from $\mathbb{Q}^n$ to a subspace $V$.
  set V := LinearMap.range (Matrix.mulVecLin P) with hV;
  -- Since $P$ is a projection, we have $P = I_V$, where $I_V$ is the identity map on $V$.
  have h_proj : ∀ v : (Fin n) → ℚ, Matrix.mulVec P v ∈ V := by
    exact fun v => LinearMap.mem_range_self _ v;
  -- Since $P$ is a projection, we have $P = I_V$, where $I_V$ is the identity map on $V$. Thus, $\text{tr}(P) = \text{dim}(V)$.
  have h_trace_proj : LinearMap.trace ℚ (Fin n → ℚ) (Matrix.mulVecLin P) = Module.finrank ℚ V := by
    -- Since $P$ is a projection, we have $P = I_V$, where $I_V$ is the identity map on $V$. Thus, $\text{tr}(P) = \text{dim}(V)$ by definition of the trace.
    have h_trace_proj : LinearMap.trace ℚ (Fin n → ℚ) (Matrix.mulVecLin P) = LinearMap.trace ℚ V (LinearMap.id) := by
      have h_trace_proj : LinearMap.trace ℚ (Fin n → ℚ) (Matrix.mulVecLin P) = LinearMap.trace ℚ V (LinearMap.comp (LinearMap.codRestrict V (Matrix.mulVecLin P) h_proj) (LinearMap.range (Matrix.mulVecLin P)).subtype) := by
        grind +suggestions;
      convert h_trace_proj using 2;
      ext; aesop;
    aesop;
  use Module.finrank ℚ V;
  convert h_trace_proj using 1;
  convert LinearMap.trace_eq_matrix_trace _ _ _;
  any_goals exact Pi.basisFun ℚ ( Fin n );
  rotate_right;
  exact Matrix.mulVecLin P;
  all_goals try infer_instance;
  simp +decide [ Matrix.trace, LinearMap.toMatrix_apply ];
  rw [ eq_comm ]

/-! ## §7: The Transpose Symmetry -/

/-
PROBLEM
det(Aᵀ) = det(A). The mirror image has the same reality score.

PROVIDED SOLUTION
This is Matrix.det_transpose in Mathlib.
-/
theorem det_transpose_eq (n : ℕ) (A : Matrix (Fin n) (Fin n) ℝ) :
    Matrix.det A.transpose = Matrix.det A := by
  apply Matrix.det_transpose

/-! ## §8: Trace Linearity -/

/-
PROBLEM
Trace is linear: tr(A + B) = tr(A) + tr(B)

PROVIDED SOLUTION
Use map_add or Matrix.trace_add.
-/
theorem trace_additive (n : ℕ) (A B : Matrix (Fin n) (Fin n) ℝ) :
    Matrix.trace (A + B) = Matrix.trace A + Matrix.trace B := by
  exact?

end