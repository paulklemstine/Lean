import Mathlib

/-!
# Cayley's `2 × 2 × 2` hyperdeterminant and three-qubit entanglement classes

For a three-qubit amplitude tensor `ψ : Fin 2 → Fin 2 → Fin 2 → ℂ` we define Cayley's
hyperdeterminant `hyperdet ψ`, the degree-four polynomial invariant whose modulus (times
four) is the *residual tangle* `τ_ABC` of Coffman–Kundu–Wootters.

The main results are:

* `hyperdet_actA`, `hyperdet_actB`, `hyperdet_actC`, `hyperdet_localAct`: the
  hyperdeterminant is a relative `SL(2)^{×3}` invariant,
  `hyperdet ((A ⊗ B ⊗ C) ψ) = (det A * det B * det C)^2 * hyperdet ψ`.
* `hyperdet_swapAB`, `hyperdet_swapAC`, `hyperdet_swapBC`: it is symmetric under
  permuting the three tensor slots.
* `hyperdet_eq_zero_of_isProductA/B/C`: it vanishes on every biseparable state.
* `hyperdet_ghz`, `hyperdet_wState`: `hyperdet` separates the GHZ and W states, whence
  `ghz_not_slocc_wState`: the GHZ state and the W state are **not** SLOCC equivalent.
* `oneTangleA`: the one-tangle `τ_{A|BC} = 4 det ρ_A`, shown to be nonnegative, bounded
  by one on normalized states, zero on `A|BC`-product states, and computed for GHZ and W.
* `ghz_genuinely_entangled`, `wState_genuinely_entangled`: neither state is biseparable
  along any of the three cuts.
* `oneTangleA_actA`, `oneTangleA_localUnitary`, `residualTangle_localUnitary`: covariance
  of the one-tangle under an operation on Alice's qubit, and local-unitary invariance of
  both tangles.
* `tangle2_eq_concurrence_sq`: for two-qubit pure states the tangle is the squared
  Wootters concurrence `C = 2 |det v|`.
* `ckw_ghzFamily`, `ckw_wFamily`: the CKW relation `τ_{A|BC} = C_AB² + C_AC² + τ_ABC`
  holds with equality on the generalized GHZ and W families.
* `residualTangle_le_oneTangleA`: `τ_ABC ≤ τ_{A|BC}` for every amplitude tensor, hence
  `residualTangle_le_one`: the three-tangle of a normalized state is at most one, a bound
  attained by GHZ.
-/

open scoped ComplexConjugate
open Matrix Finset

noncomputable section

namespace ThreeQubit

/-- Amplitude tensor of a three-qubit pure state. -/
abbrev Amp := Fin 2 → Fin 2 → Fin 2 → ℂ

/-- Cayley's `2 × 2 × 2` hyperdeterminant of a three-qubit amplitude tensor. -/
def hyperdet (a : Amp) : ℂ :=
  (a 0 0 0) ^ 2 * (a 1 1 1) ^ 2 + (a 0 0 1) ^ 2 * (a 1 1 0) ^ 2
    + (a 0 1 0) ^ 2 * (a 1 0 1) ^ 2 + (a 1 0 0) ^ 2 * (a 0 1 1) ^ 2
  - 2 * (a 0 0 0 * a 0 0 1 * a 1 1 0 * a 1 1 1
       + a 0 0 0 * a 0 1 0 * a 1 0 1 * a 1 1 1
       + a 0 0 0 * a 1 0 0 * a 0 1 1 * a 1 1 1
       + a 0 0 1 * a 0 1 0 * a 1 0 1 * a 1 1 0
       + a 0 0 1 * a 1 0 0 * a 0 1 1 * a 1 1 0
       + a 0 1 0 * a 1 0 0 * a 0 1 1 * a 1 0 1)
  + 4 * (a 0 0 0 * a 0 1 1 * a 1 0 1 * a 1 1 0 + a 0 0 1 * a 0 1 0 * a 1 0 0 * a 1 1 1)

/-- The *residual tangle* (three-tangle) `τ_ABC = 4 |Det ψ|`. -/
def residualTangle (a : Amp) : ℝ := 4 * ‖hyperdet a‖

/-! ## Local operations -/

/-- Action of a `2 × 2` matrix on the first (Alice) tensor slot. -/
def actA (A : Matrix (Fin 2) (Fin 2) ℂ) (a : Amp) : Amp :=
  fun i j k => A i 0 * a 0 j k + A i 1 * a 1 j k

/-- Action of a `2 × 2` matrix on the second (Bob) tensor slot. -/
def actB (B : Matrix (Fin 2) (Fin 2) ℂ) (a : Amp) : Amp :=
  fun i j k => B j 0 * a i 0 k + B j 1 * a i 1 k

/-- Action of a `2 × 2` matrix on the third (Charlie) tensor slot. -/
def actC (C : Matrix (Fin 2) (Fin 2) ℂ) (a : Amp) : Amp :=
  fun i j k => C k 0 * a i j 0 + C k 1 * a i j 1

/-- The full local action `(A ⊗ B ⊗ C) ψ`. -/
def localAct (A B C : Matrix (Fin 2) (Fin 2) ℂ) (a : Amp) : Amp :=
  fun i j k => ∑ l, ∑ m, ∑ n, A i l * B j m * C k n * a l m n

theorem localAct_eq (A B C : Matrix (Fin 2) (Fin 2) ℂ) (a : Amp) :
    localAct A B C a = actA A (actB B (actC C a)) := by
  funext i j k
  simp [localAct, actA, actB, actC, Fin.sum_univ_two]
  ring

theorem hyperdet_actA (A : Matrix (Fin 2) (Fin 2) ℂ) (a : Amp) :
    hyperdet (actA A a) = A.det ^ 2 * hyperdet a := by
  simp only [hyperdet, actA, Matrix.det_fin_two]
  ring

theorem hyperdet_actB (B : Matrix (Fin 2) (Fin 2) ℂ) (a : Amp) :
    hyperdet (actB B a) = B.det ^ 2 * hyperdet a := by
  simp only [hyperdet, actB, Matrix.det_fin_two]
  ring

theorem hyperdet_actC (C : Matrix (Fin 2) (Fin 2) ℂ) (a : Amp) :
    hyperdet (actC C a) = C.det ^ 2 * hyperdet a := by
  simp only [hyperdet, actC, Matrix.det_fin_two]
  ring

/-- **Relative invariance.** The hyperdeterminant is an `SL(2) × SL(2) × SL(2)` invariant:
local operations multiply it by the square of the product of the three determinants. -/
theorem hyperdet_localAct (A B C : Matrix (Fin 2) (Fin 2) ℂ) (a : Amp) :
    hyperdet (localAct A B C a) = (A.det * B.det * C.det) ^ 2 * hyperdet a := by
  rw [localAct_eq, hyperdet_actA, hyperdet_actB, hyperdet_actC]
  ring

/-! ## Permutation symmetry -/

/-- Exchange the first two qubits. -/
def swapAB (a : Amp) : Amp := fun i j k => a j i k

/-- Exchange the first and third qubits. -/
def swapAC (a : Amp) : Amp := fun i j k => a k j i

/-- Exchange the last two qubits. -/
def swapBC (a : Amp) : Amp := fun i j k => a i k j

theorem hyperdet_swapAB (a : Amp) : hyperdet (swapAB a) = hyperdet a := by
  simp only [hyperdet, swapAB]; ring

theorem hyperdet_swapAC (a : Amp) : hyperdet (swapAC a) = hyperdet a := by
  simp only [hyperdet, swapAC]; ring

theorem hyperdet_swapBC (a : Amp) : hyperdet (swapBC a) = hyperdet a := by
  simp only [hyperdet, swapBC]; ring

/-! ## Biseparable states -/

/-- `ψ` factorizes across the cut `A | BC`. -/
def IsProductA (a : Amp) : Prop := ∃ u : Fin 2 → ℂ, ∃ v : Fin 2 → Fin 2 → ℂ,
  ∀ i j k, a i j k = u i * v j k

/-- `ψ` factorizes across the cut `B | AC`. -/
def IsProductB (a : Amp) : Prop := ∃ u : Fin 2 → ℂ, ∃ v : Fin 2 → Fin 2 → ℂ,
  ∀ i j k, a i j k = u j * v i k

/-- `ψ` factorizes across the cut `C | AB`. -/
def IsProductC (a : Amp) : Prop := ∃ u : Fin 2 → ℂ, ∃ v : Fin 2 → Fin 2 → ℂ,
  ∀ i j k, a i j k = u k * v i j

theorem hyperdet_eq_zero_of_isProductA {a : Amp} (h : IsProductA a) : hyperdet a = 0 := by
  obtain ⟨u, v, h⟩ := h
  simp only [hyperdet, h]; ring

theorem hyperdet_eq_zero_of_isProductB {a : Amp} (h : IsProductB a) : hyperdet a = 0 := by
  obtain ⟨u, v, h⟩ := h
  simp only [hyperdet, h]; ring

theorem hyperdet_eq_zero_of_isProductC {a : Amp} (h : IsProductC a) : hyperdet a = 0 := by
  obtain ⟨u, v, h⟩ := h
  simp only [hyperdet, h]; ring

theorem isProductB_swapAB {a : Amp} (h : IsProductB a) : IsProductA (swapAB a) := by
  obtain ⟨u, v, h⟩ := h
  exact ⟨u, fun j k => v j k, fun i j k => h j i k⟩

theorem isProductC_swapAC {a : Amp} (h : IsProductC a) : IsProductA (swapAC a) := by
  obtain ⟨u, v, h⟩ := h
  exact ⟨u, fun j k => v k j, fun i j k => h k j i⟩

/-! ## The reduced density matrix of the first qubit -/

/-- The reduced density matrix `ρ_A = Tr_{BC} |ψ⟩⟨ψ|`. -/
def rhoA (a : Amp) : Matrix (Fin 2) (Fin 2) ℂ :=
  Matrix.of fun i i' => ∑ j, ∑ k, a i j k * conj (a i' j k)

/-- The one-tangle `τ_{A|BC} = 4 det ρ_A`. -/
def oneTangleA (a : Amp) : ℝ := 4 * (rhoA a).det.re

/-- Squared norm of the amplitude tensor. -/
def normSqAmp (a : Amp) : ℝ := ∑ i, ∑ j, ∑ k, ‖a i j k‖ ^ 2

/-- `ρ_A` has trace equal to the squared norm of `ψ`. -/
theorem rhoA_trace (a : Amp) : (rhoA a) 0 0 + (rhoA a) 1 1 = (normSqAmp a : ℂ) := by
  simp only [rhoA, normSqAmp, Matrix.of_apply, Fin.sum_univ_two]
  push_cast
  simp [Complex.mul_conj, ← Complex.sq_norm]

/-- The determinant of `ρ_A` is the Gram determinant of the two `2 × 2` slices of `ψ`. -/
theorem rhoA_det_re (a : Amp) :
    (rhoA a).det.re = (∑ j, ∑ k, ‖a 0 j k‖ ^ 2) * (∑ j, ∑ k, ‖a 1 j k‖ ^ 2)
      - ‖∑ j, ∑ k, a 0 j k * conj (a 1 j k)‖ ^ 2 := by
  have h00 : rhoA a 0 0 = ((∑ j, ∑ k, ‖a 0 j k‖ ^ 2 : ℝ) : ℂ) := by
    simp [rhoA, Complex.mul_conj, ← Complex.sq_norm]
  have h11 : rhoA a 1 1 = ((∑ j, ∑ k, ‖a 1 j k‖ ^ 2 : ℝ) : ℂ) := by
    simp [rhoA, Complex.mul_conj, ← Complex.sq_norm]
  have h10 : rhoA a 1 0 = conj (rhoA a 0 1) := by simp [rhoA, mul_comm]
  have h01 : rhoA a 0 1 = ∑ j, ∑ k, a 0 j k * conj (a 1 j k) := rfl
  rw [Matrix.det_fin_two, h00, h11, h10, h01, Complex.mul_conj]
  simp [Complex.sq_norm]

/-- Cauchy–Schwarz for the two slices of a three-qubit amplitude tensor. -/
theorem slice_cauchy_schwarz (x y : Fin 2 → Fin 2 → ℂ) :
    ‖∑ j, ∑ k, x j k * conj (y j k)‖ ^ 2
      ≤ (∑ j, ∑ k, ‖x j k‖ ^ 2) * (∑ j, ∑ k, ‖y j k‖ ^ 2) := by
  have key : ‖∑ j, ∑ k, x j k * conj (y j k)‖ ≤ ∑ j, ∑ k, ‖x j k‖ * ‖y j k‖ := by
    calc ‖∑ j, ∑ k, x j k * conj (y j k)‖ ≤ ∑ j, ‖∑ k, x j k * conj (y j k)‖ :=
          norm_sum_le _ _
      _ ≤ ∑ j, ∑ k, ‖x j k * conj (y j k)‖ :=
          Finset.sum_le_sum fun j _ => norm_sum_le _ _
      _ = ∑ j, ∑ k, ‖x j k‖ * ‖y j k‖ := by simp
  have h2 : (∑ j, ∑ k, ‖x j k‖ * ‖y j k‖) ^ 2
      ≤ (∑ j, ∑ k, ‖x j k‖ ^ 2) * (∑ j, ∑ k, ‖y j k‖ ^ 2) := by
    simp only [Fin.sum_univ_two]
    nlinarith [sq_nonneg (‖x 0 0‖ * ‖y 0 1‖ - ‖x 0 1‖ * ‖y 0 0‖),
      sq_nonneg (‖x 0 0‖ * ‖y 1 0‖ - ‖x 1 0‖ * ‖y 0 0‖),
      sq_nonneg (‖x 0 0‖ * ‖y 1 1‖ - ‖x 1 1‖ * ‖y 0 0‖),
      sq_nonneg (‖x 0 1‖ * ‖y 1 0‖ - ‖x 1 0‖ * ‖y 0 1‖),
      sq_nonneg (‖x 0 1‖ * ‖y 1 1‖ - ‖x 1 1‖ * ‖y 0 1‖),
      sq_nonneg (‖x 1 0‖ * ‖y 1 1‖ - ‖x 1 1‖ * ‖y 1 0‖)]
  exact le_trans (pow_le_pow_left₀ (norm_nonneg _) key 2) h2

/-- Cauchy–Schwarz: the one-tangle is nonnegative. -/
theorem oneTangleA_nonneg (a : Amp) : 0 ≤ oneTangleA a := by
  have := slice_cauchy_schwarz (fun j k => a 0 j k) (fun j k => a 1 j k)
  rw [oneTangleA, rhoA_det_re]
  linarith

/-- The squared norm splits as the sum of the squared norms of the two slices. -/
theorem normSqAmp_split (a : Amp) :
    normSqAmp a = (∑ j, ∑ k, ‖a 0 j k‖ ^ 2) + (∑ j, ∑ k, ‖a 1 j k‖ ^ 2) := by
  simp [normSqAmp, Fin.sum_univ_two]

/-- On a normalized state the one-tangle is at most one, with equality exactly for a
maximally mixed reduction. -/
theorem oneTangleA_le_one {a : Amp} (h : normSqAmp a = 1) : oneTangleA a ≤ 1 := by
  have hcs := slice_cauchy_schwarz (fun j k => a 0 j k) (fun j k => a 1 j k)
  have hsum := normSqAmp_split a
  rw [h] at hsum
  have hA : (0:ℝ) ≤ ∑ j, ∑ k, ‖a 0 j k‖ ^ 2 := by positivity
  have hB : (0:ℝ) ≤ ∑ j, ∑ k, ‖a 1 j k‖ ^ 2 := by positivity
  rw [oneTangleA, rhoA_det_re]
  nlinarith [sq_nonneg ((∑ j, ∑ k, ‖a 0 j k‖ ^ 2) - (∑ j, ∑ k, ‖a 1 j k‖ ^ 2)),
    norm_nonneg (∑ j, ∑ k, a 0 j k * conj (a 1 j k))]

/-- A state that factorizes across the `A | BC` cut has vanishing one-tangle. -/
theorem oneTangleA_eq_zero_of_isProductA {a : Amp} (h : IsProductA a) : oneTangleA a = 0 := by
  obtain ⟨u, v, h⟩ := h
  have : (rhoA a).det = 0 := by
    simp only [rhoA, Matrix.det_fin_two, Matrix.of_apply, h, Fin.sum_univ_two, map_mul]
    ring
  simp [oneTangleA, this]

/-! ## The GHZ and W states -/

/-- `1/√2`. -/
def c2 : ℂ := ((Real.sqrt 2)⁻¹ : ℝ)

/-- `1/√3`. -/
def c3 : ℂ := ((Real.sqrt 3)⁻¹ : ℝ)

theorem c2_sq : c2 ^ 2 = (1 / 2 : ℂ) := by
  have h : Real.sqrt 2 ^ 2 = 2 := Real.sq_sqrt (by norm_num)
  simp only [c2]
  rw [← Complex.ofReal_pow]
  rw [inv_pow, h]
  norm_num

theorem c3_sq : c3 ^ 2 = (1 / 3 : ℂ) := by
  have h : Real.sqrt 3 ^ 2 = 3 := Real.sq_sqrt (by norm_num)
  simp only [c3]
  rw [← Complex.ofReal_pow]
  rw [inv_pow, h]
  norm_num

/-- The GHZ state `(|000⟩ + |111⟩)/√2`. -/
def ghz : Amp := ![![![c2, 0], ![0, 0]], ![![0, 0], ![0, c2]]]

/-- The W state `(|001⟩ + |010⟩ + |100⟩)/√3`. -/
def wState : Amp := ![![![0, c3], ![c3, 0]], ![![c3, 0], ![0, 0]]]

theorem norm_c2_sq : ‖c2‖ ^ 2 = 1 / 2 := by
  simp [c2, ← Real.sqrt_inv]

theorem norm_c3_sq : ‖c3‖ ^ 2 = 1 / 3 := by
  simp [c3, ← Real.sqrt_inv]

theorem c2_mul_conj : c2 * conj c2 = 1 / 2 := by
  rw [Complex.mul_conj]
  norm_cast
  rw [show Complex.normSq c2 = ‖c2‖ ^ 2 from (Complex.sq_norm c2).symm, norm_c2_sq]
  norm_num

theorem c3_mul_conj : c3 * conj c3 = 1 / 3 := by
  rw [Complex.mul_conj]
  norm_cast
  rw [show Complex.normSq c3 = ‖c3‖ ^ 2 from (Complex.sq_norm c3).symm, norm_c3_sq]
  norm_num

theorem ghz_normalized : normSqAmp ghz = 1 := by
  simp only [normSqAmp, Fin.sum_univ_two, ghz]
  norm_num [norm_c2_sq]

theorem wState_normalized : normSqAmp wState = 1 := by
  simp only [normSqAmp, Fin.sum_univ_two, wState]
  norm_num [norm_c3_sq]

theorem hyperdet_ghz : hyperdet ghz = 1 / 4 := by
  simp only [hyperdet, ghz]
  norm_num
  rw [show c2 ^ 2 * c2 ^ 2 = (c2 ^ 2) ^ 2 by ring, c2_sq]
  norm_num

theorem hyperdet_wState : hyperdet wState = 0 := by
  simp only [hyperdet, wState]
  norm_num

/-- The three-tangle of the GHZ state is one, its maximal value. -/
theorem residualTangle_ghz : residualTangle ghz = 1 := by
  simp [residualTangle, hyperdet_ghz]

/-- The W state has vanishing three-tangle. -/
theorem residualTangle_wState : residualTangle wState = 0 := by
  simp [residualTangle, hyperdet_wState]

theorem rhoA_det_ghz : (rhoA ghz).det = 1 / 4 := by
  simp only [rhoA, Matrix.det_fin_two, Matrix.of_apply, ghz, Fin.sum_univ_two]
  norm_num [c2_mul_conj]

/-- The GHZ state is maximally entangled across the `A | BC` cut. -/
theorem oneTangleA_ghz : oneTangleA ghz = 1 := by
  simp [oneTangleA, rhoA_det_ghz]

theorem rhoA_det_wState : (rhoA wState).det = 2 / 9 := by
  simp only [rhoA, Matrix.det_fin_two, Matrix.of_apply, wState, Fin.sum_univ_two]
  norm_num [c3_mul_conj]

/-- The one-tangle of the W state is `8/9`, saturating the CKW monogamy relation
`τ_{A|BC} = C_AB² + C_AC²` with `C_AB² = C_AC² = 4/9` and vanishing residual tangle. -/
theorem oneTangleA_wState : oneTangleA wState = 8 / 9 := by
  simp [oneTangleA, rhoA_det_wState]
  norm_num

/-! ## Consequences -/

/-- The GHZ state is genuinely tripartite entangled: it is not biseparable along any cut. -/
theorem ghz_genuinely_entangled :
    ¬ IsProductA ghz ∧ ¬ IsProductB ghz ∧ ¬ IsProductC ghz := by
  have h : hyperdet ghz ≠ 0 := by rw [hyperdet_ghz]; norm_num
  refine ⟨fun hp => h (hyperdet_eq_zero_of_isProductA hp),
    fun hp => h (hyperdet_eq_zero_of_isProductB hp),
    fun hp => h (hyperdet_eq_zero_of_isProductC hp)⟩

theorem swapAB_wState : swapAB wState = wState := by
  funext i j k
  fin_cases i <;> fin_cases j <;> fin_cases k <;> simp [swapAB, wState]

theorem swapAC_wState : swapAC wState = wState := by
  funext i j k
  fin_cases i <;> fin_cases j <;> fin_cases k <;> simp [swapAC, wState]

/-- The W state is genuinely tripartite entangled, even though its three-tangle vanishes.
Here the obstruction is the one-tangle rather than the hyperdeterminant. -/
theorem wState_genuinely_entangled :
    ¬ IsProductA wState ∧ ¬ IsProductB wState ∧ ¬ IsProductC wState := by
  have h : oneTangleA wState ≠ 0 := by rw [oneTangleA_wState]; norm_num
  refine ⟨fun hp => h (oneTangleA_eq_zero_of_isProductA hp), fun hp => ?_, fun hp => ?_⟩
  · have := oneTangleA_eq_zero_of_isProductA (isProductB_swapAB hp)
    rw [swapAB_wState] at this; exact h this
  · have := oneTangleA_eq_zero_of_isProductA (isProductC_swapAC hp)
    rw [swapAC_wState] at this; exact h this

/-- **GHZ and W are not SLOCC equivalent.** No invertible local operations map the GHZ
state to the W state. -/
theorem ghz_not_slocc_wState (A B C : Matrix (Fin 2) (Fin 2) ℂ)
    (hA : A.det ≠ 0) (hB : B.det ≠ 0) (hC : C.det ≠ 0) :
    localAct A B C ghz ≠ wState := by
  intro h
  have h1 : hyperdet (localAct A B C ghz) = 0 := by rw [h, hyperdet_wState]
  rw [hyperdet_localAct, hyperdet_ghz] at h1
  have : (A.det * B.det * C.det) ^ 2 ≠ 0 := by
    exact pow_ne_zero _ (by simp [hA, hB, hC])
  exact this (by
    rcases mul_eq_zero.1 h1 with h2 | h2
    · exact h2
    · norm_num at h2)

/-- Conversely, no invertible local operations map the W state to the GHZ state. -/
theorem wState_not_slocc_ghz (A B C : Matrix (Fin 2) (Fin 2) ℂ) :
    localAct A B C wState ≠ ghz := by
  intro h
  have h1 : hyperdet (localAct A B C wState) = 0 := by
    rw [hyperdet_localAct, hyperdet_wState]; ring
  rw [h, hyperdet_ghz] at h1
  norm_num at h1

/-! ## Two-qubit pure states: the concurrence

For a two-qubit pure state the concurrence is `C = 2 |det v|`, and the tangle
`4 det ρ_A` equals `C²`.  This is the input to the CKW monogamy relation.
-/

/-- The determinant of a two-qubit amplitude matrix. -/
def det2 (v : Fin 2 → Fin 2 → ℂ) : ℂ := v 0 0 * v 1 1 - v 0 1 * v 1 0

/-- Reduced density matrix of the first qubit of a two-qubit pure state. -/
def rho2 (v : Fin 2 → Fin 2 → ℂ) : Matrix (Fin 2) (Fin 2) ℂ :=
  Matrix.of fun i i' => ∑ j, v i j * conj (v i' j)

/-- Wootters' concurrence of a two-qubit pure state. -/
def concurrence2 (v : Fin 2 → Fin 2 → ℂ) : ℝ := 2 * ‖det2 v‖

/-- `det ρ_A = |det v|²` for a two-qubit pure state (no normalization needed). -/
theorem rho2_det (v : Fin 2 → Fin 2 → ℂ) : (rho2 v).det = ((‖det2 v‖ ^ 2 : ℝ) : ℂ) := by
  have h : (rho2 v).det = det2 v * conj (det2 v) := by
    simp only [rho2, Matrix.det_fin_two, Matrix.of_apply, det2, Fin.sum_univ_two, map_sub,
      map_mul]
    ring
  rw [h, Complex.mul_conj]
  norm_cast
  rw [Complex.sq_norm]

/-- **Pure two-qubit tangle.** `4 det ρ_A = C²`, the squared concurrence. -/
theorem tangle2_eq_concurrence_sq (v : Fin 2 → Fin 2 → ℂ) :
    4 * (rho2 v).det.re = concurrence2 v ^ 2 := by
  rw [rho2_det, concurrence2, Complex.ofReal_re]
  ring

/-- The concurrence of a normalized two-qubit pure state is at most one. -/
theorem concurrence2_le_one {v : Fin 2 → Fin 2 → ℂ} (h : ∑ i, ∑ j, ‖v i j‖ ^ 2 = 1) :
    concurrence2 v ≤ 1 := by
  simp only [Fin.sum_univ_two] at h
  have hd : ‖det2 v‖ ≤ ‖v 0 0‖ * ‖v 1 1‖ + ‖v 0 1‖ * ‖v 1 0‖ := by
    calc ‖det2 v‖ ≤ ‖v 0 0 * v 1 1‖ + ‖v 0 1 * v 1 0‖ := norm_sub_le _ _
      _ = ‖v 0 0‖ * ‖v 1 1‖ + ‖v 0 1‖ * ‖v 1 0‖ := by simp
  have := sq_nonneg (‖v 0 0‖ - ‖v 1 1‖)
  have := sq_nonneg (‖v 0 1‖ - ‖v 1 0‖)
  simp only [concurrence2]
  nlinarith

/-! ## The CKW relation on the biseparable and generalized GHZ/W families -/

/-- If `ψ = v ⊗ u` splits off the third qubit, its one-tangle is the squared
concurrence of the two-qubit factor, rescaled by the norm of `u`. -/
theorem oneTangleA_of_productC (v : Fin 2 → Fin 2 → ℂ) (u : Fin 2 → ℂ) :
    oneTangleA (fun i j k => v i j * u k)
      = (∑ k, ‖u k‖ ^ 2) ^ 2 * concurrence2 v ^ 2 := by
  have hu : ∀ t : ℂ, t * conj t = ((‖t‖ : ℝ) : ℂ) ^ 2 := by
    intro t; rw [Complex.mul_conj, ← Complex.sq_norm]; push_cast; ring
  set S : ℝ := ∑ k, ‖u k‖ ^ 2 with hSdef
  have hS : ∀ i i' : Fin 2, (rhoA (fun i j k => v i j * u k)) i i'
      = (S : ℂ) * (rho2 v) i i' := by
    intro i i'
    simp only [rhoA, rho2, Matrix.of_apply, Fin.sum_univ_two, map_mul, hSdef]
    push_cast
    linear_combination (v i 0 * conj (v i' 0) + v i 1 * conj (v i' 1)) * (hu (u 0) + hu (u 1))
  have hdet : (rhoA (fun i j k => v i j * u k)).det = ((S ^ 2 * ‖det2 v‖ ^ 2 : ℝ) : ℂ) := by
    calc (rhoA (fun i j k => v i j * u k)).det = (S : ℂ) ^ 2 * (rho2 v).det := by
          simp only [Matrix.det_fin_two, hS]; ring
      _ = ((S ^ 2 * ‖det2 v‖ ^ 2 : ℝ) : ℂ) := by rw [rho2_det]; push_cast; ring
  rw [oneTangleA, hdet, Complex.ofReal_re, concurrence2]
  ring

/-- The generalized GHZ family `α|000⟩ + β|111⟩`. -/
def ghzFamily (α β : ℂ) : Amp := ![![![α, 0], ![0, 0]], ![![0, 0], ![0, β]]]

theorem hyperdet_ghzFamily (α β : ℂ) : hyperdet (ghzFamily α β) = α ^ 2 * β ^ 2 := by
  simp only [hyperdet, ghzFamily]
  norm_num

theorem residualTangle_ghzFamily (α β : ℂ) :
    residualTangle (ghzFamily α β) = 4 * ‖α‖ ^ 2 * ‖β‖ ^ 2 := by
  simp only [residualTangle, hyperdet_ghzFamily]
  rw [norm_mul, norm_pow, norm_pow]
  ring

theorem oneTangleA_ghzFamily (α β : ℂ) :
    oneTangleA (ghzFamily α β) = 4 * ‖α‖ ^ 2 * ‖β‖ ^ 2 := by
  have hdet : (rhoA (ghzFamily α β)).det = ((‖α‖ ^ 2 * ‖β‖ ^ 2 : ℝ) : ℂ) := by
    simp only [rhoA, Matrix.det_fin_two, Matrix.of_apply, ghzFamily, Fin.sum_univ_two]
    simp [Complex.mul_conj, ← Complex.sq_norm]
  rw [oneTangleA, hdet, Complex.ofReal_re]
  ring

/-- **CKW saturation on the generalized GHZ family.**  The two-qubit reductions of
`α|000⟩ + β|111⟩` are separable, so both two-tangles vanish and the one-tangle is
carried entirely by the residual three-tangle `4 |Det ψ|`. -/
theorem ckw_ghzFamily (α β : ℂ) :
    oneTangleA (ghzFamily α β) = 0 + 0 + residualTangle (ghzFamily α β) := by
  rw [oneTangleA_ghzFamily, residualTangle_ghzFamily]; ring

/-- The generalized W family `a|100⟩ + b|010⟩ + c|001⟩`. -/
def wFamily (a b c : ℂ) : Amp := ![![![0, c], ![b, 0]], ![![a, 0], ![0, 0]]]

theorem hyperdet_wFamily (a b c : ℂ) : hyperdet (wFamily a b c) = 0 := by
  simp only [hyperdet, wFamily]
  norm_num

theorem residualTangle_wFamily (a b c : ℂ) : residualTangle (wFamily a b c) = 0 := by
  simp [residualTangle, hyperdet_wFamily]

theorem oneTangleA_wFamily (a b c : ℂ) :
    oneTangleA (wFamily a b c) = 4 * ‖a‖ ^ 2 * (‖b‖ ^ 2 + ‖c‖ ^ 2) := by
  have hdet : (rhoA (wFamily a b c)).det
      = ((‖a‖ ^ 2 * (‖b‖ ^ 2 + ‖c‖ ^ 2) : ℝ) : ℂ) := by
    simp only [rhoA, Matrix.det_fin_two, Matrix.of_apply, wFamily, Fin.sum_univ_two]
    simp [Complex.mul_conj, ← Complex.sq_norm]
    ring
  rw [oneTangleA, hdet, Complex.ofReal_re]
  ring

/-- **CKW saturation on the generalized W family.**  For `a|100⟩ + b|010⟩ + c|001⟩` the
squared concurrences of the `AB` and `AC` reductions are `4‖a‖²‖b‖²` and `4‖a‖²‖c‖²`,
the residual three-tangle vanishes, and the monogamy relation
`τ_{A|BC} = C_AB² + C_AC² + τ_ABC` holds with equality. -/
theorem ckw_wFamily (a b c : ℂ) :
    oneTangleA (wFamily a b c)
      = 4 * ‖a‖ ^ 2 * ‖b‖ ^ 2 + 4 * ‖a‖ ^ 2 * ‖c‖ ^ 2 + residualTangle (wFamily a b c) := by
  rw [oneTangleA_wFamily, residualTangle_wFamily]; ring

/-! ## Behaviour of the one-tangle under local operations

The one-tangle transforms covariantly under an operation on Alice's qubit and is
untouched by unitaries on Bob's or Charlie's qubit.  Consequently both the one-tangle
and the residual tangle are local-unitary invariants.
-/

theorem rhoA_actA (A : Matrix (Fin 2) (Fin 2) ℂ) (a : Amp) :
    rhoA (actA A a) = A * rhoA a * Aᴴ := by
  ext i i'
  simp only [rhoA, actA, Matrix.of_apply, Matrix.mul_apply, Matrix.conjTranspose_apply,
    Fin.sum_univ_two, map_add, map_mul, RCLike.star_def]
  ring

/-- Covariance of the one-tangle under an operation on the first qubit. -/
theorem oneTangleA_actA (A : Matrix (Fin 2) (Fin 2) ℂ) (a : Amp) :
    oneTangleA (actA A a) = ‖A.det‖ ^ 2 * oneTangleA a := by
  have h : (rhoA (actA A a)).det = ((‖A.det‖ ^ 2 : ℝ) : ℂ) * (rhoA a).det := by
    rw [rhoA_actA, Matrix.det_mul, Matrix.det_mul, Matrix.det_conjTranspose,
      show A.det * (rhoA a).det * star A.det = (A.det * conj A.det) * (rhoA a).det by
        rw [RCLike.star_def]; ring,
      Complex.mul_conj, Complex.sq_norm]
  rw [oneTangleA, oneTangleA, h, Complex.re_ofReal_mul]
  ring

/-- A unitary on Bob's qubit leaves Alice's reduced density matrix unchanged. -/
theorem rhoA_actB (B : Matrix (Fin 2) (Fin 2) ℂ) (a : Amp) (hB : Bᴴ * B = 1) :
    rhoA (actB B a) = rhoA a := by
  have h00 : conj (B 0 0) * B 0 0 + conj (B 1 0) * B 1 0 = 1 := by
    have := congrFun (congrFun hB 0) 0
    simpa [Matrix.mul_apply, Fin.sum_univ_two, Matrix.conjTranspose_apply, RCLike.star_def,
      Matrix.one_apply] using this
  have h11 : conj (B 0 1) * B 0 1 + conj (B 1 1) * B 1 1 = 1 := by
    have := congrFun (congrFun hB 1) 1
    simpa [Matrix.mul_apply, Fin.sum_univ_two, Matrix.conjTranspose_apply, RCLike.star_def,
      Matrix.one_apply] using this
  have h01 : conj (B 0 0) * B 0 1 + conj (B 1 0) * B 1 1 = 0 := by
    have := congrFun (congrFun hB 0) 1
    simpa [Matrix.mul_apply, Fin.sum_univ_two, Matrix.conjTranspose_apply, RCLike.star_def,
      Matrix.one_apply] using this
  have h10 : conj (B 0 1) * B 0 0 + conj (B 1 1) * B 1 0 = 0 := by
    have := congrFun (congrFun hB 1) 0
    simpa [Matrix.mul_apply, Fin.sum_univ_two, Matrix.conjTranspose_apply, RCLike.star_def,
      Matrix.one_apply] using this
  ext i i'
  simp only [rhoA, actB, Matrix.of_apply, Fin.sum_univ_two, map_add, map_mul]
  linear_combination (a i 0 0 * conj (a i' 0 0)) * h00 + (a i 1 0 * conj (a i' 1 0)) * h11
    + (a i 0 1 * conj (a i' 0 1)) * h00 + (a i 1 1 * conj (a i' 1 1)) * h11
    + (a i 0 0 * conj (a i' 1 0)) * h10 + (a i 1 0 * conj (a i' 0 0)) * h01
    + (a i 0 1 * conj (a i' 1 1)) * h10 + (a i 1 1 * conj (a i' 0 1)) * h01

/-- A unitary on Charlie's qubit leaves Alice's reduced density matrix unchanged. -/
theorem rhoA_actC (C : Matrix (Fin 2) (Fin 2) ℂ) (a : Amp) (hC : Cᴴ * C = 1) :
    rhoA (actC C a) = rhoA a := by
  have h00 : conj (C 0 0) * C 0 0 + conj (C 1 0) * C 1 0 = 1 := by
    have := congrFun (congrFun hC 0) 0
    simpa [Matrix.mul_apply, Fin.sum_univ_two, Matrix.conjTranspose_apply, RCLike.star_def,
      Matrix.one_apply] using this
  have h11 : conj (C 0 1) * C 0 1 + conj (C 1 1) * C 1 1 = 1 := by
    have := congrFun (congrFun hC 1) 1
    simpa [Matrix.mul_apply, Fin.sum_univ_two, Matrix.conjTranspose_apply, RCLike.star_def,
      Matrix.one_apply] using this
  have h01 : conj (C 0 0) * C 0 1 + conj (C 1 0) * C 1 1 = 0 := by
    have := congrFun (congrFun hC 0) 1
    simpa [Matrix.mul_apply, Fin.sum_univ_two, Matrix.conjTranspose_apply, RCLike.star_def,
      Matrix.one_apply] using this
  have h10 : conj (C 0 1) * C 0 0 + conj (C 1 1) * C 1 0 = 0 := by
    have := congrFun (congrFun hC 1) 0
    simpa [Matrix.mul_apply, Fin.sum_univ_two, Matrix.conjTranspose_apply, RCLike.star_def,
      Matrix.one_apply] using this
  ext i i'
  simp only [rhoA, actC, Matrix.of_apply, Fin.sum_univ_two, map_add, map_mul]
  linear_combination (a i 0 0 * conj (a i' 0 0)) * h00 + (a i 0 1 * conj (a i' 0 1)) * h11
    + (a i 1 0 * conj (a i' 1 0)) * h00 + (a i 1 1 * conj (a i' 1 1)) * h11
    + (a i 0 0 * conj (a i' 0 1)) * h10 + (a i 0 1 * conj (a i' 0 0)) * h01
    + (a i 1 0 * conj (a i' 1 1)) * h10 + (a i 1 1 * conj (a i' 1 0)) * h01

/-- A unitary matrix has determinant of modulus one. -/
theorem norm_det_of_unitary {U : Matrix (Fin 2) (Fin 2) ℂ} (hU : Uᴴ * U = 1) :
    ‖U.det‖ = 1 := by
  have h : conj U.det * U.det = 1 := by
    have := congrArg Matrix.det hU
    rwa [Matrix.det_mul, Matrix.det_conjTranspose, Matrix.det_one, RCLike.star_def] at this
  have h2 : ‖U.det‖ * ‖U.det‖ = 1 := by
    have := congrArg norm h
    simpa [norm_mul] using this
  nlinarith [norm_nonneg U.det]

/-- **The one-tangle is a local-unitary invariant.** -/
theorem oneTangleA_localUnitary (A B C : Matrix (Fin 2) (Fin 2) ℂ) (a : Amp)
    (hA : Aᴴ * A = 1) (hB : Bᴴ * B = 1) (hC : Cᴴ * C = 1) :
    oneTangleA (localAct A B C a) = oneTangleA a := by
  rw [localAct_eq, oneTangleA_actA, norm_det_of_unitary hA, oneTangleA, oneTangleA,
    rhoA_actB B _ hB, rhoA_actC C _ hC]
  ring

/-- **The residual tangle is a local-unitary invariant.** -/
theorem residualTangle_localUnitary (A B C : Matrix (Fin 2) (Fin 2) ℂ) (a : Amp)
    (hA : Aᴴ * A = 1) (hB : Bᴴ * B = 1) (hC : Cᴴ * C = 1) :
    residualTangle (localAct A B C a) = residualTangle a := by
  have hnorm : ‖(A.det * B.det * C.det) ^ 2‖ = 1 := by
    rw [norm_pow, norm_mul, norm_mul, norm_det_of_unitary hA, norm_det_of_unitary hB,
      norm_det_of_unitary hC]
    norm_num
  rw [residualTangle, residualTangle, hyperdet_localAct, norm_mul, hnorm, one_mul]

/-! ## The residual tangle never exceeds the one-tangle

Writing `ψ` as a `2 × 4` matrix whose two rows are the slices `a 0 j k` and `a 1 j k`,
let `m_{pq}` be its six `2 × 2` minors.  Two polynomial identities hold:

* `hyperdet_eq_minors`: `Det ψ = m₁₄² + m₂₃² - 2 m₁₂ m₃₄ - 2 m₁₃ m₂₄`;
* `rhoA_det_eq_minors` (Cauchy–Binet): `det ρ_A = Σ |m_{pq}|²`.

Comparing them with the triangle inequality and AM–GM gives `τ_ABC ≤ τ_{A|BC}`, the
inequality predicted by the CKW monogamy relation, and hence the sharp bound
`τ_ABC ≤ 1` on normalized states, attained by the GHZ state.
-/

/-- The `2 × 2` minor of the `2 × 4` matrix of slices of `ψ` in columns `(j,k)`
and `(j',k')`. -/
def slabMinor (a : Amp) (j k j' k' : Fin 2) : ℂ :=
  a 0 j k * a 1 j' k' - a 0 j' k' * a 1 j k

/-- Cayley's hyperdeterminant expressed through the minors of the slice matrix. -/
theorem hyperdet_eq_minors (a : Amp) :
    hyperdet a = slabMinor a 0 0 1 1 ^ 2 + slabMinor a 0 1 1 0 ^ 2
      - 2 * (slabMinor a 0 0 0 1 * slabMinor a 1 0 1 1)
      - 2 * (slabMinor a 0 0 1 0 * slabMinor a 0 1 1 1) := by
  simp only [hyperdet, slabMinor]
  ring

/-- **Cauchy–Binet.** `det ρ_A` is the sum of the squared moduli of the six minors. -/
theorem rhoA_det_eq_minors (a : Amp) :
    (rhoA a).det.re = ‖slabMinor a 0 0 1 1‖ ^ 2 + ‖slabMinor a 0 1 1 0‖ ^ 2
      + ‖slabMinor a 0 0 0 1‖ ^ 2 + ‖slabMinor a 1 0 1 1‖ ^ 2
      + ‖slabMinor a 0 0 1 0‖ ^ 2 + ‖slabMinor a 0 1 1 1‖ ^ 2 := by
  have hc : (rhoA a).det
      = slabMinor a 0 0 1 1 * conj (slabMinor a 0 0 1 1)
        + slabMinor a 0 1 1 0 * conj (slabMinor a 0 1 1 0)
        + slabMinor a 0 0 0 1 * conj (slabMinor a 0 0 0 1)
        + slabMinor a 1 0 1 1 * conj (slabMinor a 1 0 1 1)
        + slabMinor a 0 0 1 0 * conj (slabMinor a 0 0 1 0)
        + slabMinor a 0 1 1 1 * conj (slabMinor a 0 1 1 1) := by
    simp only [rhoA, Matrix.det_fin_two, Matrix.of_apply, slabMinor, Fin.sum_univ_two,
      map_sub, map_mul]
    ring
  rw [hc]
  simp only [Complex.mul_conj, Complex.sq_norm, Complex.add_re, Complex.ofReal_re]

/-- **Monogamy bound.**  The residual (three-)tangle of any pure three-qubit state is at
most its one-tangle: `τ_ABC ≤ τ_{A|BC}`.  This is the inequality implied by the
Coffman–Kundu–Wootters relation `τ_{A|BC} = C_AB² + C_AC² + τ_ABC`, proved here directly
from the minor identities. -/
theorem residualTangle_le_oneTangleA (a : Amp) : residualTangle a ≤ oneTangleA a := by
  set m1 := slabMinor a 0 0 1 1
  set m2 := slabMinor a 0 1 1 0
  set m3 := slabMinor a 0 0 0 1
  set m4 := slabMinor a 1 0 1 1
  set m5 := slabMinor a 0 0 1 0
  set m6 := slabMinor a 0 1 1 1
  have key : ∀ w x y z : ℂ, ‖w + x - y - z‖ ≤ ‖w‖ + ‖x‖ + ‖y‖ + ‖z‖ := by
    intro w x y z
    calc ‖w + x - y - z‖ ≤ ‖w + x - y‖ + ‖z‖ := norm_sub_le _ _
      _ ≤ ‖w + x‖ + ‖y‖ + ‖z‖ := by linarith [norm_sub_le (w + x) y]
      _ ≤ ‖w‖ + ‖x‖ + ‖y‖ + ‖z‖ := by linarith [norm_add_le w x]
  have hbound : ‖hyperdet a‖
      ≤ ‖m1‖ ^ 2 + ‖m2‖ ^ 2 + 2 * (‖m3‖ * ‖m4‖) + 2 * (‖m5‖ * ‖m6‖) := by
    rw [hyperdet_eq_minors]
    have h := key (m1 ^ 2) (m2 ^ 2) (2 * (m3 * m4)) (2 * (m5 * m6))
    simpa [norm_pow, norm_mul] using h
  have hdet := rhoA_det_eq_minors a
  rw [residualTangle, oneTangleA, hdet]
  nlinarith [sq_nonneg (‖m3‖ - ‖m4‖), sq_nonneg (‖m5‖ - ‖m6‖), norm_nonneg (hyperdet a)]

/-- The three-tangle of a normalized pure three-qubit state is at most one; the GHZ state
attains this bound (`residualTangle_ghz`). -/
theorem residualTangle_le_one {a : Amp} (h : normSqAmp a = 1) : residualTangle a ≤ 1 :=
  le_trans (residualTangle_le_oneTangleA a) (oneTangleA_le_one h)

end ThreeQubit