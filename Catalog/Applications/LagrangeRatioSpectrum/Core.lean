import Mathlib

/-!
# Lagrange constants and their behaviour under integer transformations — Core

This file sets up the basic objects behind the *ratio spectrum of Lagrange
constants under integer linear fractional transformations* studied in the
mission "Exact Ratio Spectrum of Lagrange Constants under Integer Linear
Fractional Transformations".

For a real number `x` we use the classical **approximation function**
`approx x q = q · ‖q·x‖`, where `‖·‖` is the distance to the nearest integer
(`ndist`).  The **Lagrange (approximation) constant** is
`Lc x = liminf_{q→∞} q · ‖q·x‖`, taken in `ENNReal` so that the `liminf`
machinery is unconditionally well behaved (every term is `≥ 0`).  A real number
is **badly approximable** (`Bad`) exactly when `Lc x > 0`.

The catalog target is the statement that for an integer matrix `M` with
`det M ≠ 0` the set of ratios `{ k(Mx)/k(x) }` equals `[|det M|⁻¹, |det M|]`.
This Core file proves the part of that statement living over the
**determinant `±1` affine subgroup**: `Lc` is invariant under `x ↦ ±x + b`
(`b ∈ ℤ`), so for those `M` the ratio set is exactly `{1} = [1,1]`, which is
`[|det M|⁻¹, |det M|]` since `|det M| = 1`.

-- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer).  The "easy" generators of `GL₂(ℤ)` acting on `x`,
namely integer translations `x ↦ x + b` and the reflection `x ↦ -x`, should
leave the Lagrange constant *exactly* invariant, because `‖q(x+b)‖ = ‖qx‖`
and `‖q(-x)‖ = ‖qx‖` hold term-by-term, not merely asymptotically.  These are
determinant `±1` transformations, so the predicted ratio is `1`, in agreement
with `[|det|⁻¹, |det|] = [1,1]`.

EXPERIMENT (Experimenter).  Proven below.  The term-by-term identities
`approx_add_intCast`, `approx_neg` reduce the `liminf` statements to a `congr`
on the underlying sequences — no real analysis is needed for the invariances.
The pointwise `ndist` facts use `round_add_intCast` and
`abs_sub_round_eq_min` / `Int.fract_neg`.

ANALYSIS (Analyst).  The invariance results are *unconditional* (they hold for
every real `x`, not only badly approximable ones) and exact.  This is the
sharpest possible behaviour and confirms the `[1,1]` prediction for the
affine `±1` family.  The genuinely hard part of the mission — *attaining every
value* of `[|det|⁻¹, |det|]` for `|det| > 1` — needs explicit constructions of
badly approximable numbers and is recorded in `FUTURE_DIRECTIONS.md`.

CRITIQUE (Critic).  None of these theorems is vacuous: they assert equalities
of `liminf`s and are used downstream (`ndist_eq_zero_iff_int` powers the
catalog bridge).  No `native_decide`, no `True`.
-/

open Filter Topology

namespace LagrangeSpectrum

/-- Distance from `y` to the nearest integer, `‖y‖`. -/
noncomputable def ndist (y : ℝ) : ℝ := |y - round y|

/-- The approximation function `q ↦ q · ‖q·x‖`, valued in `ENNReal`. -/
noncomputable def approx (x : ℝ) (q : ℕ) : ENNReal :=
  (q : ENNReal) * ENNReal.ofReal (ndist ((q : ℝ) * x))

/-- The Lagrange (approximation) constant `k(x) = liminf_{q→∞} q · ‖q·x‖`. -/
noncomputable def Lc (x : ℝ) : ENNReal := Filter.liminf (approx x) Filter.atTop

/-- The set of badly approximable reals: those with positive Lagrange constant. -/
def Bad : Set ℝ := {x | 0 < Lc x}

/-! ## Distance-to-nearest-integer lemmas -/

theorem ndist_nonneg (y : ℝ) : 0 ≤ ndist y := abs_nonneg _

theorem ndist_add_intCast (y : ℝ) (n : ℤ) : ndist (y + n) = ndist y := by
  unfold ndist; rw [round_add_intCast]; push_cast; ring_nf

theorem ndist_neg (y : ℝ) : ndist (-y) = ndist y := by
  unfold ndist
  rw [abs_sub_round_eq_min, abs_sub_round_eq_min]
  rcases eq_or_ne (Int.fract y) 0 with h | h
  · have hneg : Int.fract (-y) = 0 := by
      rw [Int.fract_eq_zero_iff] at *
      obtain ⟨z, rfl⟩ := h; exact ⟨-z, by push_cast; ring⟩
    rw [hneg, h]
  · rw [Int.fract_neg h, min_comm]; ring_nf

/-- `‖y‖ = 0` iff `y` is an integer. -/
theorem ndist_eq_zero_iff_int (y : ℝ) : ndist y = 0 ↔ ∃ m : ℤ, y = m := by
  unfold ndist; rw [abs_eq_zero, sub_eq_zero]
  exact ⟨fun h => ⟨round y, h⟩, fun ⟨m, hm⟩ => by rw [hm, round_intCast]⟩

/-! ## Approximation-function identities -/

theorem approx_add_intCast (x : ℝ) (b : ℤ) (q : ℕ) :
    approx (x + b) q = approx x q := by
  unfold approx
  congr 2
  have : (q : ℝ) * (x + b) = (q : ℝ) * x + ((q : ℤ) * b : ℤ) := by push_cast; ring
  rw [this, ndist_add_intCast]

theorem approx_neg (x : ℝ) (q : ℕ) : approx (-x) q = approx x q := by
  unfold approx
  congr 2
  rw [show (q : ℝ) * (-x) = -((q : ℝ) * x) by ring, ndist_neg]

/-- Exact dilation identity: `approx (n·x) q = approx x (n·q) / n` for `n ≥ 1`. -/
theorem approx_dilation (x : ℝ) (n q : ℕ) (hn : 1 ≤ n) :
    approx ((n : ℝ) * x) q = approx x (n * q) / (n : ENNReal) := by
  unfold approx
  have hne : (n : ENNReal) ≠ 0 := by exact_mod_cast Nat.one_le_iff_ne_zero.mp hn
  have htop : (n : ENNReal) ≠ ⊤ := ENNReal.natCast_ne_top n
  have hxeq : (q : ℝ) * ((n : ℝ) * x) = ((n * q : ℕ) : ℝ) * x := by push_cast; ring
  rw [hxeq]; push_cast
  set A := ENNReal.ofReal (ndist (↑n * ↑q * x)) with hA
  rw [show (↑n * ↑q * A) = (↑q * A) * ↑n from by ring, mul_div_assoc,
     ENNReal.div_self hne htop, mul_one]

/-! ## Invariance of the Lagrange constant (determinant `±1` affine subgroup) -/

/-- **Translation invariance.** `k(x + b) = k(x)` for every integer `b`. -/
theorem Lc_add_intCast (x : ℝ) (b : ℤ) : Lc (x + b) = Lc x := by
  unfold Lc; congr 1; funext q; exact approx_add_intCast x b q

/-- **Reflection invariance.** `k(-x) = k(x)`. -/
theorem Lc_neg (x : ℝ) : Lc (-x) = Lc x := by
  unfold Lc; congr 1; funext q; exact approx_neg x q

/-- **Determinant `±1` affine invariance.**  For `a = ±1` and `b ∈ ℤ` (the matrix
`![![a, b], ![0, 1]]`, of determinant `a = ±1`), the Lagrange constant of
`a·x + b` equals that of `x`.  Hence for such matrices the ratio spectrum is
`{1} = [|det|⁻¹, |det|]`. -/
theorem Lc_unimodular_affine (x : ℝ) (a b : ℤ) (ha : a = 1 ∨ a = -1) :
    Lc ((a : ℝ) * x + b) = Lc x := by
  rcases ha with rfl | rfl
  · simp only [Int.cast_one, one_mul]; exact Lc_add_intCast x b
  · rw [show ((-1 : ℤ) : ℝ) * x + (b : ℝ) = (-x) + (b : ℝ) by push_cast; ring]
    rw [Lc_add_intCast (-x) b, Lc_neg]

end LagrangeSpectrum