import Mathlib

/-!
# The Lorentz form of signature `(n,1)`, its integral automorphisms, and the reflection move

This file sets up the general framework in which the Berggren tree of primitive Pythagorean
triples and its higher–dimensional analogues live:

* `lorentzJ n`   — the Gram matrix `diag(1,…,1,-1)` of the form `x₁²+…+xₙ² − y²`;
* `lorentzQ n v` — the form itself;
* `NullCone n`   — its integral null cone (`= ` Pythagorean `n`-tuples);
* `IsIntegralLorentz n M` — the integral automorphisms of the form.

Main results.

* `lorentzQ_mulVec` : integral Lorentz matrices preserve the form, hence the null cone
  (`IsIntegralLorentz.mapsTo_nullCone`).
* `IsIntegralLorentz.det_sq` : such matrices have determinant `±1`.
* `lorentz_move_height_bound` : the *sharp* growth constant of the reflection move in the
  all-ones vector: the height is multiplied by at most `(√n+1)/(√n−1)`.  For `n = 2` this is
  `3+2√2 = (1+√2)²`, the square of the silver ratio (Berggren); for `n = 3` it is `2+√3`.
* `refl_not_integral_of_four_le` : the all-ones reflection is *not* integral for `n ≥ 4`,
  so the Berggren mechanism only exists in dimensions `n = 2, 3`.
-/

namespace HigherPythagorean

open Matrix Finset

section Form

variable (n : ℕ)

/-- Gram matrix of the Lorentz form of signature `(n,1)`: `diag(1,…,1,-1)`. -/
def lorentzJ : Matrix (Fin (n + 1)) (Fin (n + 1)) ℤ :=
  Matrix.diagonal fun i => if i = Fin.last n then -1 else 1

/-- The Lorentz quadratic form `q(v) = v ⬝ J ⬝ v = x₁²+…+xₙ² − y²`. -/
def lorentzQ (v : Fin (n + 1) → ℤ) : ℤ := v ⬝ᵥ (lorentzJ n *ᵥ v)

/-- The integral null cone of the Lorentz form: solutions of `x₁²+…+xₙ² = y²`. -/
def NullCone : Set (Fin (n + 1) → ℤ) := {v | lorentzQ n v = 0}

variable {n}

lemma lorentzJ_transpose : (lorentzJ n)ᵀ = lorentzJ n := by
  simp [lorentzJ, Matrix.diagonal_transpose]

lemma lorentzQ_eq_sum (v : Fin (n + 1) → ℤ) :
    lorentzQ n v = (∑ i : Fin n, (v i.castSucc) ^ 2) - (v (Fin.last n)) ^ 2 := by
  classical
  have h : lorentzQ n v = ∑ i : Fin (n + 1), (if i = Fin.last n then -(v i) ^ 2 else (v i) ^ 2) := by
    simp only [lorentzQ, dotProduct, lorentzJ, mulVec_diagonal]
    refine Finset.sum_congr rfl ?_
    intro i _
    by_cases hi : i = Fin.last n <;> simp [hi, sq]
  rw [h, Fin.sum_univ_castSucc]
  simp [Fin.castSucc_lt_last, Fin.ne_of_lt]
  ring

/-- Membership in the null cone, written out. -/
lemma mem_nullCone_iff (v : Fin (n + 1) → ℤ) :
    v ∈ NullCone n ↔ (∑ i : Fin n, (v i.castSucc) ^ 2) = (v (Fin.last n)) ^ 2 := by
  simp [NullCone, lorentzQ_eq_sum, sub_eq_zero]

end Form

section Automorphisms

variable {n : ℕ}

/-- An integral automorphism of the Lorentz form: `Mᵀ J M = J`. -/
def IsIntegralLorentz (M : Matrix (Fin (n + 1)) (Fin (n + 1)) ℤ) : Prop :=
  Mᵀ * lorentzJ n * M = lorentzJ n

lemma isIntegralLorentz_one : IsIntegralLorentz (1 : Matrix (Fin (n + 1)) (Fin (n + 1)) ℤ) := by
  simp [IsIntegralLorentz]

lemma IsIntegralLorentz.mul {M N : Matrix (Fin (n + 1)) (Fin (n + 1)) ℤ}
    (hM : IsIntegralLorentz M) (hN : IsIntegralLorentz N) : IsIntegralLorentz (M * N) := by
  unfold IsIntegralLorentz at *
  calc (M * N)ᵀ * lorentzJ n * (M * N) = Nᵀ * (Mᵀ * lorentzJ n * M) * N := by
        rw [Matrix.transpose_mul]; noncomm_ring
    _ = Nᵀ * lorentzJ n * N := by rw [hM]
    _ = lorentzJ n := hN

/-- Integral Lorentz matrices preserve the Lorentz form. -/
lemma lorentzQ_mulVec {M : Matrix (Fin (n + 1)) (Fin (n + 1)) ℤ} (hM : IsIntegralLorentz M)
    (v : Fin (n + 1) → ℤ) : lorentzQ n (M *ᵥ v) = lorentzQ n v := by
  have h1 : M *ᵥ v = v ᵥ* Mᵀ := by rw [Matrix.vecMul_transpose]
  calc lorentzQ n (M *ᵥ v)
      = (M *ᵥ v) ⬝ᵥ (lorentzJ n *ᵥ (M *ᵥ v)) := rfl
    _ = ((M *ᵥ v) ᵥ* lorentzJ n) ⬝ᵥ (M *ᵥ v) := dotProduct_mulVec _ _ _
    _ = (((M *ᵥ v) ᵥ* lorentzJ n) ᵥ* M) ⬝ᵥ v := dotProduct_mulVec _ _ _
    _ = ((v ᵥ* Mᵀ) ᵥ* lorentzJ n ᵥ* M) ⬝ᵥ v := by rw [h1]
    _ = (v ᵥ* (Mᵀ * lorentzJ n * M)) ⬝ᵥ v := by
        rw [Matrix.vecMul_vecMul, Matrix.vecMul_vecMul, ← Matrix.mul_assoc]
    _ = (v ᵥ* lorentzJ n) ⬝ᵥ v := by rw [hM]
    _ = lorentzQ n v := (dotProduct_mulVec _ _ _).symm

/-- Integral Lorentz matrices map the null cone to itself: Pythagorean `n`-tuples are sent
to Pythagorean `n`-tuples. -/
lemma IsIntegralLorentz.mapsTo_nullCone {M : Matrix (Fin (n + 1)) (Fin (n + 1)) ℤ}
    (hM : IsIntegralLorentz M) {v : Fin (n + 1) → ℤ} (hv : v ∈ NullCone n) :
    M *ᵥ v ∈ NullCone n := by
  simpa [NullCone, lorentzQ_mulVec hM] using hv

lemma det_lorentzJ : (lorentzJ n).det = -1 := by
  classical
  rw [lorentzJ, Matrix.det_diagonal, Fin.prod_univ_castSucc]
  simp [Fin.ne_of_lt, Fin.castSucc_lt_last]

/-- Integral Lorentz matrices are unimodular. -/
lemma IsIntegralLorentz.det_sq {M : Matrix (Fin (n + 1)) (Fin (n + 1)) ℤ}
    (hM : IsIntegralLorentz M) : M.det ^ 2 = 1 := by
  have h := congrArg Matrix.det hM
  rw [Matrix.det_mul, Matrix.det_mul, Matrix.det_transpose, det_lorentzJ] at h
  nlinarith [h]

end Automorphisms

section Reflection

/-!
### The all-ones reflection and its growth constant

For the vector `r = (1,…,1;1)` one has `q(r) = n − 1` and the reflection
`s_r(v) = v − (2·B(v,r)/(n−1))·r` subtracts the *same* rational number from every coordinate.
Its effect on the height (last coordinate) is `y ↦ ((n+1)y − 2∑ εᵢxᵢ)/(n−1)`.
-/

/-- The height after one all-ones reflection move with sign pattern `e`, in dimension `n`. -/
noncomputable def moveHeight (n : ℕ) (x e : Fin n → ℝ) (y : ℝ) : ℝ :=
  ((n + 1) * y - 2 * ∑ i, e i * x i) / (n - 1)

/-- Cauchy–Schwarz for a `±1` pattern against a null vector. -/
lemma abs_signed_sum_le {n : ℕ} (x e : Fin n → ℝ) (y : ℝ) (hy : 0 < y)
    (h : ∑ i, (x i) ^ 2 = y ^ 2) (he : ∀ i, e i = 1 ∨ e i = -1) :
    |∑ i, e i * x i| ≤ Real.sqrt n * y := by
  have hsq : (∑ i, e i * x i) ^ 2 ≤ (n : ℝ) * y ^ 2 := by
    have hcs : (∑ i, e i * x i) ^ 2 ≤ ((Finset.univ : Finset (Fin n)).card : ℝ) *
        ∑ i, (e i * x i) ^ 2 := sq_sum_le_card_mul_sum_sq
    have hval : ∑ i, (e i * x i) ^ 2 = ∑ i, (x i) ^ 2 := by
      refine Finset.sum_congr rfl ?_
      intro i _
      rcases he i with h1 | h1 <;> simp [h1]
    rw [hval, h] at hcs
    simpa using hcs
  have hs : Real.sqrt n * y = Real.sqrt ((n : ℝ) * y ^ 2) := by
    rw [Real.sqrt_mul (by positivity), Real.sqrt_sq hy.le]
  rw [hs]
  calc |∑ i, e i * x i| = Real.sqrt ((∑ i, e i * x i) ^ 2) := (Real.sqrt_sq_eq_abs _).symm
    _ ≤ Real.sqrt ((n : ℝ) * y ^ 2) := Real.sqrt_le_sqrt hsq

/-- **Sharp growth constant.**  One reflection move multiplies the height by at most
`(√n+1)/(√n−1)`.  At `n = 2` this constant is `3+2√2 = (1+√2)²` (silver ratio squared,
the Berggren case); at `n = 3` it is `2+√3`. -/
theorem lorentz_move_height_bound {n : ℕ} (hn : 2 ≤ n) (x e : Fin n → ℝ) (y : ℝ) (hy : 0 < y)
    (h : ∑ i, (x i) ^ 2 = y ^ 2) (he : ∀ i, e i = 1 ∨ e i = -1) :
    moveHeight n x e y ≤ (Real.sqrt n + 1) / (Real.sqrt n - 1) * y := by
  have hn2 : (2 : ℝ) ≤ (n : ℝ) := by exact_mod_cast hn
  set s := Real.sqrt n with hs
  have hs0 : 0 ≤ s := Real.sqrt_nonneg _
  have hs2 : s ^ 2 = (n : ℝ) := Real.sq_sqrt (by positivity)
  have hs1 : 1 < s := by nlinarith [hs2, hs0]
  have hb := abs_signed_sum_le x e y hy h he
  have hlow : -(s * y) ≤ ∑ i, e i * x i := by
    rcases abs_le.mp hb with ⟨h1, _⟩; linarith
  have hden : (0 : ℝ) < (n : ℝ) - 1 := by linarith
  have hden' : (0 : ℝ) < s - 1 := by linarith
  rw [moveHeight, div_le_iff₀ hden]
  have key : ((n : ℝ) + 1) * y - 2 * ∑ i, e i * x i ≤ ((n : ℝ) + 1) * y + 2 * (s * y) := by
    linarith
  refine key.trans ?_
  have hfac : (s + 1) / (s - 1) * y * ((n : ℝ) - 1) = (s + 1) * (s + 1) * y := by
    field_simp
    nlinarith [hs2]
  rw [hfac]
  nlinarith [hs2, hy.le, hs0]

/-- Sharpness in dimension `3`: the bound `2+√3` is attained on the real null cone. -/
theorem quad_growth_bound_sharp :
    ∃ (x e : Fin 3 → ℝ) (y : ℝ), 0 < y ∧ (∑ i, (x i) ^ 2 = y ^ 2) ∧ (∀ i, e i = 1 ∨ e i = -1) ∧
      moveHeight 3 x e y = (2 + Real.sqrt 3) * y := by
  have h3 : Real.sqrt 3 ^ 2 = 3 := Real.sq_sqrt (by norm_num)
  have h3' : (0 : ℝ) < Real.sqrt 3 := by positivity
  refine ⟨fun _ => 1 / Real.sqrt 3, fun _ => -1, 1, one_pos, ?_, fun _ => Or.inr rfl, ?_⟩
  · simp only [Fin.sum_univ_three]
    field_simp
    nlinarith [h3]
  · simp only [moveHeight, Fin.sum_univ_three]
    push_cast
    field_simp
    nlinarith [h3, h3']

/-!
### Failure of integrality for `n ≥ 4`

The reflection in the all-ones vector subtracts `c = 2·B(v,r)/(n−1)` from each coordinate.
Applied to the first basis vector this is `2/(n−1)`, which is an integer only for `n ≤ 3`.
Consequently the Berggren move exists over `ℤ` precisely in dimensions `n = 2` (triples) and
`n = 3` (quadruples).
-/

/-- The reflection coefficient `2/(n−1)` fails to be an integer as soon as `n ≥ 4`; hence the
all-ones reflection does not preserve the integral lattice in dimension `n ≥ 4`. -/
theorem refl_not_integral_of_four_le (n : ℕ) (hn : 4 ≤ n) :
    ¬ ∃ z : ℤ, (2 : ℚ) / ((n : ℚ) - 1) = (z : ℚ) := by
  rintro ⟨z, hz⟩
  have hn4 : (4 : ℚ) ≤ (n : ℚ) := by exact_mod_cast hn
  have hn1 : ((n : ℚ) - 1) ≠ 0 := by intro h; rw [sub_eq_zero] at h; rw [h] at hn4; norm_num at hn4
  have h2 : (2 : ℚ) = (z : ℚ) * ((n : ℚ) - 1) := by field_simp at hz; linarith
  have hZ : (2 : ℤ) = z * ((n : ℤ) - 1) := by
    have : ((2 : ℤ) : ℚ) = ((z * ((n : ℤ) - 1) : ℤ) : ℚ) := by push_cast; linarith
    exact_mod_cast this
  have hdvd : ((n : ℤ) - 1) ∣ 2 := ⟨z, by linarith⟩
  have hle : ((n : ℤ) - 1) ≤ 2 := Int.le_of_dvd (by norm_num) hdvd
  have h4 : (4 : ℤ) ≤ (n : ℤ) := by exact_mod_cast hn
  omega

/-- Concretely in dimension `4`: the null vector `(1,1,1,1;2)` is moved off the integral
lattice by the all-ones reflection (each coordinate is shifted by `4/3`). -/
theorem dim_four_refl_off_lattice :
    ¬ ∃ z : ℤ, (1 : ℚ) - 2 * ((1 + 1 + 1 + 1 : ℚ) - 2) / (4 - 1) = (z : ℚ) := by
  rintro ⟨z, hz⟩
  have : (3 : ℚ) * (z : ℚ) = -1 := by linarith [hz]
  have hZ : (3 : ℤ) * z = -1 := by exact_mod_cast this
  omega

end Reflection

end HigherPythagorean