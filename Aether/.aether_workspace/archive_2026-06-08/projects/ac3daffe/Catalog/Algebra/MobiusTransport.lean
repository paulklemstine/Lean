import Mathlib

/-!
# Critical-Line ↔ Unit-Circle Equivalence via Möbius Transform

We prove that the Möbius transform `φ(s) = (s − 3/2) / (s + 1/2)` sends
the critical line `Re(s) = 1/2` exactly to the unit circle `‖z‖ = 1`, and
conversely.

The key idea: shift `s` by `−1/2` to center the critical line on the imaginary
axis, then apply a standard Cayley-type map `(w−1)/(w+1)`. The composition
gives `φ(s) = (s − 3/2)/(s + 1/2)`.

For `s = 1/2 + it`: numerator `= −1 + it`, denominator `= 1 + it`, and
`|−1+it|² = 1+t² = |1+it|²`, so `|φ(s)| = 1`. Conversely, `|φ(s)| = 1`
implies `|s−3/2| = |s+1/2|`, which forces `Re(s) = 1/2`.

This is the geometric Rosetta stone connecting Riemann-style critical-line
problems to self-inversive/unit-circle algebra.

## Main Results

- `criticalLine_iff_unitCircle`: `Re(s) = 1/2 ↔ ‖φ(s)‖ = 1` away from the pole
-/

open Complex

noncomputable section

/-- The Möbius transform sending the critical line `Re(s) = 1/2` to the unit circle.
    This is the composition of centering `w = s − 1/2` and the Cayley map
    `z = (w − 1)/(w + 1)`, giving `φ(s) = (s − 3/2)/(s + 1/2)`. -/
def criticalLineMap (s : ℂ) : ℂ :=
  (s - (3 / 2 : ℂ)) / (s + (1 / 2 : ℂ))

/-- The denominator `s + 1/2` is nonzero when `s ≠ -1/2`. -/
theorem criticalLineMap_denom_ne_zero {s : ℂ} (h : s ≠ -(1 / 2 : ℂ)) :
    s + (1 / 2 : ℂ) ≠ 0 := by
  intro heq; apply h; linear_combination heq

/-- Key algebraic fact: `(σ - 3/2)² = (σ + 1/2)²` iff `σ = 1/2`. -/
theorem sq_sub_eq_sq_add_iff (σ : ℝ) :
    (σ - 3 / 2) ^ 2 = (σ + 1 / 2) ^ 2 ↔ σ = 1 / 2 := by
  constructor
  · intro h; nlinarith
  · intro h; subst h; ring

/-
**Critical line → unit circle.** If `Re(s) = 1/2`, then `‖φ(s)‖ = 1`.
-/
theorem criticalLine_to_unitCircle
    {s : ℂ} (h : s ≠ -(1 / 2 : ℂ)) (hs : s.re = 1 / 2) :
    ‖criticalLineMap s‖ = 1 := by
  erw [ norm_div]
  generalize_proofs at *;
  rw [ div_eq_iff ] <;> norm_num [ Complex.normSq, Complex.norm_def, hs ] ; ring;
  positivity

/-
**Unit circle → critical line.** If `‖φ(s)‖ = 1`, then `Re(s) = 1/2`.
-/
theorem unitCircle_to_criticalLine
    {s : ℂ} (_h : s ≠ -(1 / 2 : ℂ)) (habs : ‖criticalLineMap s‖ = 1) :
    s.re = 1 / 2 := by
  unfold criticalLineMap at habs;
  norm_num [ Complex.normSq, Complex.norm_def ] at habs;
  grind

/-- **Critical line ↔ unit circle.** A complex number `s` with `s ≠ -1/2` satisfies
    `Re(s) = 1/2` if and only if `‖φ(s)‖ = 1`. -/
theorem criticalLine_iff_unitCircle
    {s : ℂ} (h : s ≠ -(1 / 2 : ℂ)) :
    s.re = 1 / 2 ↔ ‖criticalLineMap s‖ = 1 :=
  ⟨criticalLine_to_unitCircle h, unitCircle_to_criticalLine h⟩

end