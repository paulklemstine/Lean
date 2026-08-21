import Shared.BerggrenTQC.NonUniversality

/-!
# The silver spectrum of the Berggren `B`-spine

The `B`-branch of the Berggren tree is governed by the matrix `U₂ = !![2,1;1,0]`, whose
eigenvalues are the silver-ratio units `1 ± √2` of `ℤ[√2]`; its square `W = U₂² = !![5,2;2,1]`
has eigenvalues `3 ± 2√2`, the fundamental Pell unit, and satisfies `W² = 6W - 1`, which is
exactly the recurrence `c_{n+2} = 6c_{n+1} - c_n` for the hypotenuses along the `B`-spine
(catalog: `bHyp_recurrence`).

Main results.

* `silver_sq`, `pell_unit_real`, `pell_unit_zsqrtd`: `(1+√2)² = 3+2√2` and `(3+2√2)(3-2√2) = 1`,
  i.e. `3 + 2√2` is a unit of `ℤ[√2]` of norm `1`.
* `U₂_eigenvector`, `W_eigenvector`: explicit eigenvectors realising the eigenvalues `1+√2`
  and `3+2√2`.
* `U₂_cayley_hamilton`, `W_cayley_hamilton`: `U₂² = 2U₂ + 1` and `W² = 6W - 1`.
* `bSpine_hyp`: the hypotenuse of the `n`-th `B`-spine triple is the catalog sequence `bHyp n`,
  and `bSpine_recurrence` derives the Pell recurrence from the Euclid lift.
* `bHyp_lower`, `bHyp_upper`: `5^(n+1) ≤ bHyp n ≤ 5 · 6^n`, the exponential growth of the
  spine.
* `W_pow_entry_lower` and `W_pow_not_orthogonal`: the spine element is *hyperbolic* — the
  entries of `Wⁿ` grow at least like `5ⁿ`, so no positive power of `W` is orthogonal
  (equivalently unitary).  Hyperbolic elements can never act as anyonic braiding phases.
-/

namespace BerggrenTQC

open Matrix

/-! ## The silver ratio and the fundamental Pell unit -/

theorem silver_sq : (1 + Real.sqrt 2) ^ 2 = 3 + 2 * Real.sqrt 2 := by
  have h : Real.sqrt 2 * Real.sqrt 2 = 2 := Real.mul_self_sqrt (by norm_num)
  nlinarith [h]

theorem pell_unit_real : (3 + 2 * Real.sqrt 2) * (3 - 2 * Real.sqrt 2) = 1 := by
  have h : Real.sqrt 2 * Real.sqrt 2 = 2 := Real.mul_self_sqrt (by norm_num)
  nlinarith [h]

/-- `3 + 2√2` is a unit of `ℤ[√2]`, the square of the silver ratio `1 + √2`. -/
theorem pell_unit_zsqrtd :
    (⟨1, 1⟩ : ℤ√2) ^ 2 = ⟨3, 2⟩ ∧ Zsqrtd.norm (⟨3, 2⟩ : ℤ√2) = 1 ∧ IsUnit (⟨3, 2⟩ : ℤ√2) := by
  exact ⟨by decide, by decide, ⟨⟨⟨3, 2⟩, ⟨3, -2⟩, by decide, by decide⟩, rfl⟩⟩

/-! ## Eigenvectors: the spectrum of the `B`-generator -/

/-- The real form of the `B`-generator. -/
noncomputable def U₂R : Matrix (Fin 2) (Fin 2) ℝ := !![2, 1; 1, 0]

/-- The real form of the spine element `W = U₂²`. -/
noncomputable def WR : Matrix (Fin 2) (Fin 2) ℝ := !![5, 2; 2, 1]

/-- `U₂` has the silver ratio `1 + √2` as an eigenvalue, with eigenvector `(1+√2, 1)`. -/
theorem U₂_eigenvector :
    U₂R *ᵥ ![1 + Real.sqrt 2, 1] = (1 + Real.sqrt 2) • ![1 + Real.sqrt 2, 1] := by
  have h : Real.sqrt 2 * Real.sqrt 2 = 2 := Real.mul_self_sqrt (by norm_num)
  ext i
  fin_cases i <;> simp [U₂R, Matrix.mulVec, dotProduct, Fin.sum_univ_two]
  nlinarith [h]

/-- `W = U₂²` has the fundamental Pell unit `3 + 2√2` as an eigenvalue. -/
theorem W_eigenvector :
    WR *ᵥ ![1 + Real.sqrt 2, 1] = (3 + 2 * Real.sqrt 2) • ![1 + Real.sqrt 2, 1] := by
  have h : Real.sqrt 2 * Real.sqrt 2 = 2 := Real.mul_self_sqrt (by norm_num)
  ext i
  fin_cases i <;> simp [WR, Matrix.mulVec, dotProduct, Fin.sum_univ_two] <;> nlinarith [h]

/-! ## Cayley–Hamilton and the Pell recurrence -/

/-- The integral spine element `W = U₂²`. -/
def W : Matrix (Fin 2) (Fin 2) ℤ := !![5, 2; 2, 1]

theorem U₂_sq : U₂ * U₂ = W := by decide

/-- `U₂² = 2U₂ + 1`: the characteristic polynomial `x² - 2x - 1` of the silver ratio. -/
theorem U₂_cayley_hamilton : U₂ * U₂ = 2 • U₂ + 1 := by decide

/-- `W² = 6W - 1`: the characteristic polynomial `x² - 6x + 1` of the Pell unit `3 + 2√2`. -/
theorem W_cayley_hamilton : W * W = 6 • W - 1 := by decide

theorem W_trace_det : W.trace = 6 ∧ W.det = 1 := by
  constructor <;> simp [W, Matrix.trace_fin_two, Matrix.det_fin_two_of]

/-! ## The `B`-spine and its hypotenuses -/

/-- The Euclid parameters of the `n`-th triple along the `B`-spine. -/
def bSpine : ℕ → ℤ × ℤ
  | 0 => (2, 1)
  | n + 1 => act U₂ (bSpine n)

theorem bSpine_triple (n : ℕ) :
    euclid (bSpine (n + 1)).1 (bSpine (n + 1)).2 =
      bergB (euclid (bSpine n).1 (bSpine n).2).1 (euclid (bSpine n).1 (bSpine n).2).2.1
            (euclid (bSpine n).1 (bSpine n).2).2.2 := by
  rcases hb : bSpine n with ⟨m, k⟩
  simp only [bSpine, hb]
  exact euclid_U₂ m k

/-- Hypotenuse of the `n`-th `B`-spine triple. -/
def bSpineHyp (n : ℕ) : ℤ := (bSpine n).1 ^ 2 + (bSpine n).2 ^ 2

/-- The Pell recurrence for the spine hypotenuses, derived from the `GL(2,ℤ)` lift. -/
theorem bSpine_recurrence (n : ℕ) :
    bSpineHyp (n + 2) = 6 * bSpineHyp (n + 1) - bSpineHyp n := by
  rcases hb : bSpine n with ⟨m, k⟩
  simp only [bSpineHyp, bSpine, hb, act_U₂]
  ring

/-- The spine hypotenuses are exactly the catalog's `bHyp` sequence. -/
theorem bSpine_hyp (n : ℕ) : bSpineHyp n = bHyp n := by
  induction n using Nat.strong_induction_on with
  | _ n ih =>
    match n with
    | 0 => rfl
    | 1 => rfl
    | (n + 2) =>
      rw [bSpine_recurrence n, bHyp, ih (n + 1) (by omega), ih n (by omega)]

/-! ## Exponential growth of the spine -/

theorem bHyp_pos (n : ℕ) : 0 < bHyp n := by
  induction n using Nat.strong_induction_on with
  | _ n ih =>
    match n with
    | 0 => decide
    | 1 => decide
    | (n + 2) =>
      have h1 := ih (n + 1) (by omega)
      have h2 := bHyp_increasing n
      rw [bHyp]; omega

theorem bHyp_lower (n : ℕ) : 5 ^ (n + 1) ≤ bHyp n := by
  induction n using Nat.strong_induction_on with
  | _ n ih =>
    match n with
    | 0 => decide
    | 1 => decide
    | (n + 2) =>
      have h1 := ih (n + 1) (by omega)
      have h2 := bHyp_increasing n
      have hp : (5 : ℤ) ^ (n + 2 + 1) = 5 * 5 ^ (n + 1 + 1) := by ring
      rw [bHyp]
      linarith

theorem bHyp_upper (n : ℕ) : bHyp n ≤ 5 * 6 ^ n := by
  induction n using Nat.strong_induction_on with
  | _ n ih =>
    match n with
    | 0 => decide
    | 1 => decide
    | (n + 2) =>
      have h1 := ih (n + 1) (by omega)
      have h2 := bHyp_pos n
      have hq : (5 : ℤ) * 6 ^ (n + 2) = 6 * (5 * 6 ^ (n + 1)) := by ring
      rw [bHyp]
      linarith

/-! ## Hyperbolicity: no power of the spine element is unitary -/

theorem W_pow_nonneg_and_lower (n : ℕ) :
    (∀ i j, 0 ≤ (W ^ n) i j) ∧ 5 ^ n ≤ (W ^ n) 0 0 := by
  induction n with
  | zero => refine ⟨fun i j => ?_, by simp⟩; fin_cases i <;> fin_cases j <;> simp
  | succ n ih =>
    obtain ⟨hnn, hlow⟩ := ih
    have hmul : ∀ i j, (W ^ (n + 1)) i j =
        (W ^ n) i 0 * W 0 j + (W ^ n) i 1 * W 1 j := by
      intro i j
      rw [pow_succ]
      simp [Matrix.mul_apply, Fin.sum_univ_two]
    constructor
    · intro i j
      rw [hmul i j]
      have h1 : 0 ≤ W 0 j := by fin_cases j <;> simp [W]
      have h2 : 0 ≤ W 1 j := by fin_cases j <;> simp [W]
      exact add_nonneg (mul_nonneg (hnn i 0) h1) (mul_nonneg (hnn i 1) h2)
    · rw [hmul 0 0]
      have hW00 : W 0 0 = 5 := by simp [W]
      have hW10 : W 1 0 = 2 := by simp [W]
      have h01 := hnn 0 1
      rw [hW00, hW10]
      have : (5 : ℤ) ^ (n + 1) = 5 ^ n * 5 := by ring
      nlinarith [hlow, h01]

theorem W_pow_entry_lower (n : ℕ) : 5 ^ n ≤ (W ^ n) 0 0 := (W_pow_nonneg_and_lower n).2

/-- **The spine element is hyperbolic.**  For `n ≥ 1` the matrix `Wⁿ` has an entry larger than
`1`, hence is not a signed permutation matrix, hence is not orthogonal.  No positive power of
the Berggren `B`-generator can act as a unitary (anyonic) braiding operator. -/
theorem W_pow_not_orthogonal (n : ℕ) (hn : 1 ≤ n) : ¬ ((W ^ n)ᵀ * (W ^ n) = 1) := by
  intro h
  have hentry : (5 : ℤ) ≤ (W ^ n) 0 0 := by
    calc (5 : ℤ) = 5 ^ 1 := by ring
      _ ≤ 5 ^ n := pow_le_pow_right₀ (by norm_num) hn
      _ ≤ (W ^ n) 0 0 := W_pow_entry_lower n
  have h0 := congrFun (congrFun h 0) 0
  simp only [Matrix.mul_apply, Matrix.transpose_apply, Fin.sum_univ_two,
    Matrix.one_apply_eq] at h0
  nlinarith [h0, hentry, mul_self_nonneg ((W ^ n) 1 0)]

end BerggrenTQC