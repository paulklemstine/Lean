/-! # CatalogBuild.Pythagorean.Berggren.BerggrenGenesis

Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 39
-/

import Mathlib

/-- Berggren matrix A -/
def berg_A : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, -2, 2; 2, -1, 2; 2, -2, 3]


/-- Berggren matrix B -/
def berg_B : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, 2, 2; 2, 1, 2; 2, 2, 3]


/-- Berggren matrix C -/
def berg_C : Matrix (Fin 3) (Fin 3) ℤ :=
  !![-1, 2, 2; -2, 1, 2; -2, 2, 3]


/-- The swap matrix S that exchanges coordinates a and b -/
def berg_S : Matrix (Fin 3) (Fin 3) ℤ :=
  !![0, 1, 0; 1, 0, 0; 0, 0, 1]


/-- The vacuum triple (0, 1, 1) -/
def vacuum : Fin 3 → ℤ := ![0, 1, 1]


/-- The light triple (1, 0, 1) -/
def light : Fin 3 → ℤ := ![1, 0, 1]


/-- The first real triple (3, 4, 5) -/
def triple345 : Fin 3 → ℤ := ![3, 4, 5]


/-- The swapped first triple (4, 3, 5) -/
def triple435 : Fin 3 → ℤ := ![4, 3, 5]


/-- The vacuum triple satisfies the Pythagorean equation -/
theorem vacuum_pythagorean : (vacuum 0) ^ 2 + (vacuum 1) ^ 2 = (vacuum 2) ^ 2 := by
  native_decide


/-- **Theorem (Vacuum Fixed Point)**: A · (0,1,1) = (0,1,1) -/
theorem vacuum_fixed_by_A : berg_A.mulVec vacuum = vacuum := by
  native_decide


/-- **Theorem (Light Fixed Point)**: C · (1,0,1) = (1,0,1) -/
theorem light_fixed_by_C : berg_C.mulVec light = light := by
  native_decide


/-- **Theorem (Creation from Vacuum)**: B · (0,1,1) = (4,3,5) -/
theorem creation_B_vacuum : berg_B.mulVec vacuum = triple435 := by
  native_decide


/-- **Theorem (Creation from Light)**: B · (1,0,1) = (3,4,5) -/
theorem creation_B_light : berg_B.mulVec light = triple345 := by
  native_decide


/-- **Theorem (C also creates from vacuum)**: C · (0,1,1) = (4,3,5) -/
theorem creation_C_vacuum : berg_C.mulVec vacuum = triple435 := by
  native_decide


/-- **Theorem (A also creates from light)**: A · (1,0,1) = (3,4,5) -/
theorem creation_A_light : berg_A.mulVec light = triple345 := by
  native_decide


/-- **Theorem (B-C Degeneracy at Vacuum)**: B and C produce the same result from vacuum -/
theorem BC_degenerate_at_vacuum : berg_B.mulVec vacuum = berg_C.mulVec vacuum := by
  native_decide


/-- **Theorem (A-B Degeneracy at Light)**: A and B produce the same result from light -/
theorem AB_degenerate_at_light : berg_A.mulVec light = berg_B.mulVec light := by
  native_decide


/-- The swap matrix exchanges vacuum and light -/
theorem swap_vacuum_light : berg_S.mulVec vacuum = light := by
  native_decide


/-- The swap matrix exchanges light and vacuum -/
theorem swap_light_vacuum : berg_S.mulVec light = vacuum := by
  native_decide


/-- **Theorem (Swap Conjugation: A ↔ C)**: S · A · S = C -/
theorem swap_conjugates_A_to_C : berg_S * berg_A * berg_S = berg_C := by
  native_decide


/-- **Theorem (Swap Conjugation: C ↔ A)**: S · C · S = A -/
theorem swap_conjugates_C_to_A : berg_S * berg_C * berg_S = berg_A := by
  native_decide


/-- **Theorem (B is Self-Dual)**: S · B · S = B -/
theorem swap_fixes_B : berg_S * berg_B * berg_S = berg_B := by
  native_decide


/-- **Theorem (A is Unipotent of Order 3)**: (A - I)³ = 0 -/
theorem A_unipotent : (berg_A - 1) ^ 3 = 0 := by
  native_decide


/-- **Theorem (C is Unipotent of Order 3)**: (C - I)³ = 0 -/
theorem C_unipotent : (berg_C - 1) ^ 3 = 0 := by
  native_decide


/-- A - I is not zero (so A is not the identity) -/
theorem A_minus_I_nonzero : berg_A - 1 ≠ 0 := by
  native_decide


/-- (A - I)² is not zero (so A is not unipotent of order 2) -/
theorem A_minus_I_sq_nonzero : (berg_A - 1) ^ 2 ≠ 0 := by
  native_decide


/-- det(A) = 1 -/
theorem det_berg_A : Matrix.det berg_A = 1 := by
  native_decide


/-- det(B) = -1 -/
theorem det_berg_B : Matrix.det berg_B = -1 := by
  native_decide


/-- det(C) = 1 -/
theorem det_berg_C : Matrix.det berg_C = 1 := by
  native_decide


/-- det(S) = -1 -/
theorem det_berg_S : Matrix.det berg_S = -1 := by
  native_decide


/-- The Lorentz metric matrix Q = diag(1, 1, -1) -/
def lorentz_Q : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, 0, 0; 0, 1, 0; 0, 0, -1]


/-- A preserves the Lorentz form: Aᵀ Q A = Q -/
theorem A_preserves_lorentz : berg_A.transpose * lorentz_Q * berg_A = lorentz_Q := by
  native_decide


/-- B preserves the Lorentz form: Bᵀ Q B = Q -/
theorem B_preserves_lorentz : berg_B.transpose * lorentz_Q * berg_B = lorentz_Q := by
  native_decide


/-- C preserves the Lorentz form: Cᵀ Q C = Q -/
theorem C_preserves_lorentz : berg_C.transpose * lorentz_Q * berg_C = lorentz_Q := by
  native_decide


/-- The minimum energy triple at depth d has Euclid parameters (d+1, d):
a = 2d(d+1), b = 2d+1, c = d² + (d+1)² = 2d² + 2d + 1 -/
theorem min_energy_is_pythagorean (d : ℤ) :
    (2 * d * (d + 1)) ^ 2 + (2 * d + 1) ^ 2 = (d ^ 2 + (d + 1) ^ 2) ^ 2 := by ring


/-- The C matrix maps Euclid parameters (d+1, d) to (d+2, d+1),
advancing one step along the minimum-energy path.
In triple form: C · (2d(d+1), 2d+1, 2d²+2d+1) = (2(d+1)(d+2), 2d+3, 2d²+6d+5) -/
theorem C_advances_min_energy (d : ℤ) :
    let a := 2 * d * (d + 1)
    let b := 2 * d + 1
    let c := d ^ 2 + (d + 1) ^ 2
    -- C · (a, b, c) gives the triple with parameters (d+2, d+1)
    (-a + 2 * b + 2 * c = 2 * (d + 1) * (d + 2)) ∧
    (-2 * a + b + 2 * c = 2 * (d + 1) + 1) ∧
    (-2 * a + 2 * b + 3 * c = (d + 1) ^ 2 + (d + 2) ^ 2) := by
  constructor <;> [skip; constructor] <;> ring


/-- The minimum energy at depth d equals 2d² + 2d + 1,
which is the d-th centered square number (for d ≥ 0). -/
theorem centered_square_identity (d : ℤ) :
    d ^ 2 + (d + 1) ^ 2 = 2 * d ^ 2 + 2 * d + 1 := by ring


/-- The maximum energy B-path growth factor: if the B-path triple at
depth d has hypotenuse c(d), then the ratio satisfies a Pell-type
recurrence. Specifically, the near-diagonal triples satisfy:
if (a, a+1, c) is on the B-path, then c² = 2a² + 2a + 1. -/
theorem near_diagonal_hypotenuse (a : ℤ) :
    a ^ 2 + (a + 1) ^ 2 = 2 * a ^ 2 + 2 * a + 1 := by ring


/-- The Brahmagupta-Fibonacci identity: the product of two sums of squares
is itself a sum of squares. This underlies the Fibonacci-Pythagorean connection. -/
theorem brahmagupta_fibonacci_genesis (a b c d : ℤ) :
    (a ^ 2 + b ^ 2) * (c ^ 2 + d ^ 2) =
    (a * c - b * d) ^ 2 + (a * d + b * c) ^ 2 := by ring

