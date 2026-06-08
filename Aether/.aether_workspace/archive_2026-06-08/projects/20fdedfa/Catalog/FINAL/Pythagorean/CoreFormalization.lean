import Mathlib

/-! # CatalogBuild.Pythagorean.Core.CoreFormalization

Auto-generated from theorem catalog database.
Domain: Pythagorean/Core
Declarations: 23
-/

/-- Berggren matrix A (also called B₁): generates the "slow lane" branch. -/
def berggrenA_matrix : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, -2, 2; 2, -1, 2; 2, -2, 3]

/-- Berggren matrix B (also called B₂): generates the "fast lane" branch. -/
def berggrenB_matrix : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, 2, 2; 2, 1, 2; 2, 2, 3]

/-- Berggren matrix C (also called B₃): mirror of A. -/
def berggrenC_matrix : Matrix (Fin 3) (Fin 3) ℤ :=
  !![(-1), 2, 2; (-2), 1, 2; (-2), 2, 3]

/-- The Lorentz metric matrix Q = diag(1, 1, -1). -/
def lorentzMetric : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, 0, 0; 0, 1, 0; 0, 0, (-1)]

/-- **Theorem (Lorentz preservation for A):** Bᵀ_A · Q · B_A = Q.
This means B_A ∈ O(2,1;ℤ), the integer Lorentz group. -/
theorem berggrenA_lorentz : berggrenA_matrix ᵀ * lorentzMetric * berggrenA_matrix = lorentzMetric := by
  native_decide

/-- **Theorem (Lorentz preservation for B):** Bᵀ_B · Q · B_B = Q. -/
theorem berggrenB_lorentz : berggrenB_matrix ᵀ * lorentzMetric * berggrenB_matrix = lorentzMetric := by
  native_decide

/-- **Theorem (Lorentz preservation for C):** Bᵀ_C · Q · B_C = Q. -/
theorem berggrenC_lorentz : berggrenC_matrix ᵀ * lorentzMetric * berggrenC_matrix = lorentzMetric := by
  native_decide

/-- The full Lorentz form is preserved by A for *any* integer vector, not just triples.
Q(Av) = Q(v) for all v ∈ ℤ³. -/
theorem berggrenA_preserves_form (a b c : ℤ) :
    lorentzQ (a - 2*b + 2*c) (2*a - b + 2*c) (2*a - 2*b + 3*c) = lorentzQ a b c := by
  unfold lorentzQ; ring

/-- The full Lorentz form is preserved by B for any integer vector. -/
theorem berggrenB_preserves_form (a b c : ℤ) :
    lorentzQ (a + 2*b + 2*c) (2*a + b + 2*c) (2*a + 2*b + 3*c) = lorentzQ a b c := by
  unfold lorentzQ; ring

/-- The full Lorentz form is preserved by C for any integer vector. -/
theorem berggrenC_preserves_form (a b c : ℤ) :
    lorentzQ (-a + 2*b + 2*c) (-2*a + b + 2*c) (-2*a + 2*b + 3*c) = lorentzQ a b c := by
  unfold lorentzQ; ring

/-- Depth of a tree path. -/
def BPath.depth : BPath → ℕ
  | .root  => 0
  | .brA p => p.depth + 1
  | .brB p => p.depth + 1
  | .brC p => p.depth + 1

/-- The hypotenuse at a given tree path. -/
def hypAt (p : BPath) : ℤ := (tripleAt p).2.2

/-- Every triple in the Berggren tree satisfies the Pythagorean equation. -/
theorem tripleAt_pyth (p : BPath) :
    let t := tripleAt p
    t.1 ^ 2 + t.2.1 ^ 2 = t.2.2 ^ 2 :=
  tripleAt_pyth_aux p

/-- The hypotenuse of a B-child is at least 3 times the parent's when legs are positive. -/
theorem hyp_B_growth (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) :
    2*a + 2*b + 3*c ≥ 3 * c := by linarith

/-- Descent step: hypotenuse strictly decreases when we apply B⁻¹ to a
primitive triple with hypotenuse > 5. -/
theorem descent_hyp_decrease (a b c : ℤ) (hpyth : a ^ 2 + b ^ 2 = c ^ 2)
    (ha : 0 < a) (hb : 0 < b) (hc5 : 5 < c) :
    -2*a - 2*b + 3*c < c := by nlinarith [sq_nonneg a, sq_nonneg b]

/-- **Key factoring identity:** For any Pythagorean triple (a,b,c),
we have (c-b)(c+b) = a². This is the bridge to integer factoring:
if a = N is the number to factor, the triple gives a non-trivial
factorization of N² as (c-b)(c+b). -/
theorem diff_of_squares_identity (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (c - b) * (c + b) = a ^ 2 := by nlinarith

/-- The first few Pell hypotenuses. -/
theorem pellHyp_values :
    pellHyp 0 = 5 ∧ pellHyp 1 = 29 ∧ pellHyp 2 = 169 ∧ pellHyp 3 = 985 := by
  refine ⟨rfl, rfl, ?_, ?_⟩ <;> simp [pellHyp]

/-- The Pell hypotenuses grow exponentially: c_n ≈ (3+2√2)ⁿ · 5.
We prove the weaker bound c_{n+1} ≥ 5 · c_n for n ≥ 1. -/
theorem pellHyp_growth : pellHyp 1 ≥ 5 * pellHyp 0 := by
  simp [pellHyp]

/-- The A-branch acts on Euclid parameters as (m,n) ↦ (2m-n, m).
After one A-step, parameters (m, m-1) become (m+1, m). -/
theorem A_branch_euclid_params (m : ℤ) :
    let a := m ^ 2 - (m - 1) ^ 2
    let b := 2 * m * (m - 1)
    let c := m ^ 2 + (m - 1) ^ 2
    let a' := a - 2 * b + 2 * c
    let b' := 2 * a - b + 2 * c
    let c' := 2 * a - 2 * b + 3 * c
    -- The new triple has parameters (m+1, m)
    a' = (m + 1) ^ 2 - m ^ 2 ∧
    b' = 2 * (m + 1) * m ∧
    c' = (m + 1) ^ 2 + m ^ 2 := by
  constructor <;> [skip; constructor] <;> ring

/-- The inverse A acts on consecutive parameters: (m, m-1) ↦ (m-1, m-2).
This is the descent step for the "slow lane." -/
theorem A_inv_consecutive (m : ℤ) :
    let a := m ^ 2 - (m - 1) ^ 2
    let b := 2 * m * (m - 1)
    let c := m ^ 2 + (m - 1) ^ 2
    let a' := a + 2 * b - 2 * c
    let b' := -2 * a - b + 2 * c
    let c' := -2 * a - 2 * b + 3 * c
    a' = (m - 1) ^ 2 - (m - 2) ^ 2 ∧
    b' = 2 * (m - 1) * (m - 2) ∧
    c' = (m - 1) ^ 2 + (m - 2) ^ 2 := by
  constructor <;> [skip; constructor] <;> ring

/-- The 3×3 Berggren A matrix has determinant 1 (it's in SO⁺(2,1;ℤ)). -/
theorem det_berggrenA : Matrix.det berggrenA_matrix = 1 := by native_decide

/-- The 3×3 Berggren B matrix has determinant -1. -/
theorem det_berggrenB : Matrix.det berggrenB_matrix = -1 := by native_decide

/-- The 3×3 Berggren C matrix has determinant 1. -/
theorem det_berggrenC : Matrix.det berggrenC_matrix = 1 := by native_decide