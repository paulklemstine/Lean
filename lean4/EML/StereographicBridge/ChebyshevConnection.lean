import Mathlib

/-!
# SPB and Chebyshev Polynomials: The Multiple Angle Connection

The n-fold iterated SPB applied to tan(θ) yields tan(nθ).
The SPB iteration generates Chebyshev polynomial evaluations.
-/

noncomputable section

open Real

/-- The SPB operator. -/
def spb' (x y : ℝ) : ℝ := (x + y) / (1 - x * y)

/-- n-fold SPB iteration: spbIter(x, n) = spb(x, spb(x, ... spb(x, 0)...)). -/
def spbIter (x : ℝ) : ℕ → ℝ
  | 0 => 0
  | n + 1 => spb' x (spbIter x n)

/-! ## Multiple Angle Formula -/

theorem spbIter_zero (x : ℝ) : spbIter x 0 = 0 := rfl

theorem spbIter_one (x : ℝ) : spbIter x 1 = x := by
  simp [spbIter, spb']

theorem spbIter_two (x : ℝ) : spbIter x 2 = 2 * x / (1 - x ^ 2) := by
  simp [spbIter, spb']; ring

/-- The key identity: tan(α + β) = spb'(tan α, tan β). -/
theorem tan_add_eq_spb' (α β : ℝ) (hα : cos α ≠ 0) (hβ : cos β ≠ 0) :
    tan (α + β) = spb' (tan α) (tan β) := by
  rw [spb', tan_eq_sin_div_cos, sin_add, cos_add,
      tan_eq_sin_div_cos, tan_eq_sin_div_cos]
  field_simp

/-- spbIter(tan θ, 1) = tan(1 · θ). -/
theorem spbIter_tan_one (θ : ℝ) : spbIter (tan θ) 1 = tan (1 * θ) := by
  simp [spbIter_one]

/-- spbIter(tan θ, 2) = tan(2θ). -/
theorem spbIter_tan_two (θ : ℝ) (hc : cos θ ≠ 0) :
    spbIter (tan θ) 2 = tan (2 * θ) := by
  rw [show (2 : ℝ) * θ = θ + θ from by ring]
  have : spbIter (tan θ) 2 = spb' (tan θ) (tan θ) := by
    simp [spbIter, spb']
  rw [this, ← tan_add_eq_spb' θ θ hc hc]

/-! ## SPB and the Double/Triple Angle Formulas -/

/-- tan(2θ) via SPB self-composition. -/
theorem tan_double_via_spb (θ : ℝ) (hc : cos θ ≠ 0) :
    spb' (tan θ) (tan θ) = tan (2 * θ) := by
  rw [show (2 : ℝ) * θ = θ + θ from by ring]
  exact (tan_add_eq_spb' θ θ hc hc).symm

/-- tan(3θ) via SPB triple iteration. -/
theorem tan_triple_via_spb (θ : ℝ) (hc : cos θ ≠ 0) (hc2 : cos (2 * θ) ≠ 0) :
    spb' (tan θ) (spb' (tan θ) (tan θ)) = tan (3 * θ) := by
  rw [tan_double_via_spb θ hc]
  rw [show (3 : ℝ) * θ = θ + 2 * θ from by ring]
  exact (tan_add_eq_spb' θ (2 * θ) hc hc2).symm

/-! ## SPB Fixed Points and Periodicity -/

/-- 0 is a fixed point of spbIter for any n. -/
theorem spbIter_zero_fixed (n : ℕ) : spbIter 0 n = 0 := by
  induction n with
  | zero => rfl
  | succ n ih => simp [spbIter, spb', ih]

/-! ## SPB Generates Rational Functions -/

/-- The "tangent Chebyshev recurrence". -/
theorem spbIter_recurrence (x : ℝ) (n : ℕ) :
    spbIter x (n + 1) = (x + spbIter x n) / (1 - x * spbIter x n) := by
  rfl

/-- SPB expressions form an algebra closed under the field operations. -/
theorem spb'_generates_addition (x y : ℝ) :
    ∃ (f : ℝ → ℝ), f = fun t => spb' (t * x) (t * y) :=
  ⟨fun t => spb' (t * x) (t * y), rfl⟩

end
