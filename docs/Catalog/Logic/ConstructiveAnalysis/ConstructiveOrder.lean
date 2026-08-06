/-
# The constructive order on Bishop reals

Constructively, the order relation on the reals is *not* obtained by negating an
equality: `x < y` must carry positive information.  Bishop defines, for regular
sequences of rationals,

  `x > 0`  iff  `∃ n, x n > 1/n`,      `x < y`  iff  `y - x > 0`,

so that a proof of `x < y` is a *witness index* together with a rational
inequality, from which a rational lower bound on the gap `y - x` can be read off.

This file develops that order for the Bishop reals of
`Logic/ConstructiveAnalysis/BishopReals.lean`:

* `Bishop.Reg.pos_iff_toReal_pos`, `Bishop.Reg.lt_iff_toReal_lt` : the witnessed
  relations agree with the classical order on the denoted reals (so nothing is
  lost, and the constructive relation is not weaker);
* `Bishop.Reg.lt_cotrans` : **cotransitivity**, the constructive substitute for
  trichotomy, in fully explicit form — from a witness `n` for `x < y` one computes
  an index `m` at which a *decidable rational comparison* of `z.approx m` with the
  midpoint `(x.approx m + y.approx m)/2` decides between `x < z` and `z < y`;
* `Bishop.Reg.approx_locate_left`, `approx_locate_right`, `approx_locate` : the
  constructive location lemma — for rationals `a < b`, a single rational
  comparison at a computed index decides `a < x` or `x < b`;
* `Bishop.Reg.no_uniform_lt_witness` : the witness index in `x < y` cannot be
  bounded in advance — the precise sense in which the order, though it agrees
  extensionally with the classical one, is not decidable at bounded precision.
-/

import Mathlib
import Logic.ConstructiveAnalysis.BishopReals
import Logic.ConstructiveAnalysis.ComputableReals

namespace Bishop

namespace Reg

/-! ## Two-sided form of the explicit modulus -/

lemma toReal_lower (x : Reg) (n : ℕ) : (x.approx n : ℝ) - 1 / (n + 1) ≤ x.toReal := by
  have h := abs_le.mp (x.abs_toReal_sub_approx_le n)
  linarith [h.1]

lemma toReal_upper (x : Reg) (n : ℕ) : x.toReal ≤ (x.approx n : ℝ) + 1 / (n + 1) := by
  have h := abs_le.mp (x.abs_toReal_sub_approx_le n)
  linarith [h.2]

/-- An index at which the canonical accuracy `C/(n+1)` beats a given positive real. -/
lemma exists_nat_inv_lt (C : ℝ) {t : ℝ} (ht : 0 < t) : ∃ n : ℕ, C / (n + 1) < t := by
  obtain ⟨n, hn⟩ := exists_nat_gt (C / t)
  refine ⟨n, ?_⟩
  have h1 : (0 : ℝ) < (n : ℝ) + 1 := by positivity
  rw [div_lt_iff₀ h1]
  have h2 : C / t < (n : ℝ) + 1 := by linarith
  have h3 : C / t * t < ((n : ℝ) + 1) * t := by
    exact mul_lt_mul_of_pos_right h2 ht
  have h4 : C / t * t = C := by field_simp
  linarith [h3, h4]

/-! ## Positivity and the strict order -/

/-- **Bishop positivity**: `x > 0` means that some approximation exceeds its own
error bound.  A proof is a witness index `n`, from which the rational number
`x.approx n - 1/(n+1) > 0` is an explicit lower bound for `x`. -/
def Pos (x : Reg) : Prop := ∃ n : ℕ, 1 / (n + 1 : ℚ) < x.approx n

/-- **Bishop's strict order**: `x < y` means that at some index the approximations
are separated by more than the sum of their error bounds. -/
def Lt (x y : Reg) : Prop := ∃ n : ℕ, x.approx n + 2 / (n + 1 : ℚ) < y.approx n

/-- Bishop positivity agrees with positivity of the denoted classical real. -/
theorem pos_iff_toReal_pos (x : Reg) : Pos x ↔ 0 < x.toReal := by
  constructor
  · rintro ⟨n, hn⟩
    have hnR : (1 : ℝ) / ((n : ℝ) + 1) < (x.approx n : ℝ) := by
      have : ((1 / (n + 1 : ℚ) : ℚ) : ℝ) < ((x.approx n : ℚ) : ℝ) := by exact_mod_cast hn
      push_cast at this
      exact this
    have := x.toReal_lower n
    linarith
  · intro h
    obtain ⟨n, hn⟩ := exists_nat_inv_lt 2 h
    have hup := x.toReal_upper n
    have hR : (1 : ℝ) / ((n : ℝ) + 1) < (x.approx n : ℝ) := by
      have h2 : (2 : ℝ) / ((n : ℝ) + 1) = 1 / ((n : ℝ) + 1) + 1 / ((n : ℝ) + 1) := by ring
      linarith
    refine ⟨n, ?_⟩
    have : ((1 / (n + 1 : ℚ) : ℚ) : ℝ) < ((x.approx n : ℚ) : ℝ) := by push_cast; exact hR
    exact_mod_cast this

/-- Bishop's strict order agrees with the classical order on the denoted reals. -/
theorem lt_iff_toReal_lt (x y : Reg) : Lt x y ↔ x.toReal < y.toReal := by
  constructor
  · rintro ⟨n, hn⟩
    have hR : (x.approx n : ℝ) + 2 / ((n : ℝ) + 1) < (y.approx n : ℝ) := by
      have : ((x.approx n + 2 / (n + 1 : ℚ) : ℚ) : ℝ) < ((y.approx n : ℚ) : ℝ) := by
        exact_mod_cast hn
      push_cast at this
      exact this
    have h1 := x.toReal_upper n
    have h2 := y.toReal_lower n
    have h3 : (2 : ℝ) / ((n : ℝ) + 1) = 1 / ((n : ℝ) + 1) + 1 / ((n : ℝ) + 1) := by ring
    linarith
  · intro h
    obtain ⟨n, hn⟩ := exists_nat_inv_lt 4 (sub_pos.mpr h)
    have h1 := x.toReal_lower n
    have h2 := y.toReal_upper n
    have hR : (x.approx n : ℝ) + 2 / ((n : ℝ) + 1) < (y.approx n : ℝ) := by
      have h3 : (4 : ℝ) / ((n : ℝ) + 1)
          = 2 / ((n : ℝ) + 1) + (1 / ((n : ℝ) + 1) + 1 / ((n : ℝ) + 1)) := by ring
      linarith
    refine ⟨n, ?_⟩
    have : ((x.approx n + 2 / (n + 1 : ℚ) : ℚ) : ℝ) < ((y.approx n : ℚ) : ℝ) := by
      push_cast; exact hR
    exact_mod_cast this

lemma lt_irrefl (x : Reg) : ¬ Lt x x := by
  intro h
  exact absurd ((lt_iff_toReal_lt x x).1 h) (by simp)

lemma lt_trans {x y z : Reg} (h₁ : Lt x y) (h₂ : Lt y z) : Lt x z :=
  (lt_iff_toReal_lt x z).2
    (((lt_iff_toReal_lt x y).1 h₁).trans ((lt_iff_toReal_lt y z).1 h₂))

lemma lt_asymm {x y : Reg} (h : Lt x y) : ¬ Lt y x := by
  intro h'
  have := ((lt_iff_toReal_lt x y).1 h).trans ((lt_iff_toReal_lt y x).1 h')
  exact absurd this (by simp)

/-- The rational gap read off from a witness for `x < y`. -/
def gapAt (x y : Reg) (n : ℕ) : ℚ := y.approx n - x.approx n - 2 / (n + 1)

lemma gapAt_pos {x y : Reg} {n : ℕ} (h : x.approx n + 2 / (n + 1 : ℚ) < y.approx n) :
    0 < gapAt x y n := by
  simp only [gapAt]
  linarith

/-- The witness makes the gap explicit: `y - x` is at least the rational `gapAt x y n`. -/
lemma gapAt_le_toReal_sub (x y : Reg) (n : ℕ) :
    ((gapAt x y n : ℚ) : ℝ) ≤ y.toReal - x.toReal := by
  have h1 := x.toReal_upper n
  have h2 := y.toReal_lower n
  have hcast : ((gapAt x y n : ℚ) : ℝ)
      = (y.approx n : ℝ) - (x.approx n : ℝ) - 2 / ((n : ℝ) + 1) := by
    simp only [gapAt]; push_cast; ring
  rw [hcast]
  have h3 : (2 : ℝ) / ((n : ℝ) + 1) = 1 / ((n : ℝ) + 1) + 1 / ((n : ℝ) + 1) := by ring
  linarith

/-- Comparing approximations far enough out gives a rational lower bound for the gap. -/
lemma gap_le_approx_sub (x y : Reg) (n : ℕ) {m : ℕ}
    (hm : 1 / (m + 1 : ℚ) ≤ gapAt x y n / 8) :
    3 * gapAt x y n / 4 ≤ y.approx m - x.approx m := by
  have hmR : (1 : ℝ) / ((m : ℝ) + 1) ≤ ((gapAt x y n : ℚ) : ℝ) / 8 := by
    have : ((1 / (m + 1 : ℚ) : ℚ) : ℝ) ≤ ((gapAt x y n / 8 : ℚ) : ℝ) := by exact_mod_cast hm
    push_cast at this
    exact this
  have hgap := gapAt_le_toReal_sub x y n
  have h1 := x.toReal_lower m
  have h2 := y.toReal_upper m
  have hR : 3 * ((gapAt x y n : ℚ) : ℝ) / 4 ≤ (y.approx m : ℝ) - (x.approx m : ℝ) := by
    linarith
  have : ((3 * gapAt x y n / 4 : ℚ) : ℝ) ≤ ((y.approx m - x.approx m : ℚ) : ℝ) := by
    push_cast
    linarith
  exact_mod_cast this

/-- **Cotransitivity of the constructive order (explicit form).**

From a witness `n` for `x < y` one computes an index `m` (any index with
`1/(m+1) ≤ gapAt x y n / 8`) at which, for *any* third Bishop real `z`, a single
decidable comparison of the rationals `z.approx m` and `(x.approx m + y.approx m)/2`
decides between `x < z` and `z < y`.  This is the constructive substitute for the
classically trivial disjunction `x < z ∨ z < y`. -/
theorem lt_cotrans {x y : Reg} {n : ℕ}
    (h : x.approx n + 2 / (n + 1 : ℚ) < y.approx n) (z : Reg) {m : ℕ}
    (hm : 1 / (m + 1 : ℚ) ≤ gapAt x y n / 8) :
    (x.approx m + 2 / (m + 1 : ℚ) < z.approx m ∨
      z.approx m + 2 / (m + 1 : ℚ) < y.approx m) := by
  have hg : 0 < gapAt x y n := gapAt_pos h
  have hspread := gap_le_approx_sub x y n hm
  have hstep : (2 : ℚ) / (m + 1) ≤ gapAt x y n / 4 := by
    have he : (2 : ℚ) / ((m : ℚ) + 1) = 2 * (1 / ((m : ℚ) + 1)) := by ring
    rw [he]
    linarith
  by_cases hz : (x.approx m + y.approx m) / 2 ≤ z.approx m
  · left; linarith
  · push_neg at hz
    right; linarith

/-- **Cotransitivity, existential form.**  If `x < y` then for every `z`,
either `x < z` or `z < y`. -/
theorem lt_cotrans_or {x y : Reg} (h : Lt x y) (z : Reg) : Lt x z ∨ Lt z y := by
  obtain ⟨n, hn⟩ := h
  obtain ⟨m, hmR⟩ :=
    exists_nat_inv_lt 1 (t := ((gapAt x y n : ℚ) : ℝ) / 8)
      (by
        have := gapAt_pos hn
        have : (0 : ℝ) < ((gapAt x y n : ℚ) : ℝ) := by exact_mod_cast this
        linarith)
  have hm : 1 / (m + 1 : ℚ) ≤ gapAt x y n / 8 := by
    have : ((1 / (m + 1 : ℚ) : ℚ) : ℝ) ≤ ((gapAt x y n / 8 : ℚ) : ℝ) := by
      push_cast
      linarith
    exact_mod_cast this
  rcases lt_cotrans hn z hm with hc | hc
  · exact Or.inl ⟨m, hc⟩
  · exact Or.inr ⟨m, hc⟩

/-! ## Locating a Bishop real between two rationals -/

/-- If the `n`-th approximation is at least the midpoint of `[a,b]`, and the index is
fine enough, then `a` is strictly below the real denoted by `x`. -/
theorem approx_locate_left {x : Reg} {a b : ℚ} {n : ℕ}
    (hn : 4 / (n + 1 : ℚ) ≤ b - a) (h : (a + b) / 2 ≤ x.approx n) :
    (a : ℝ) < x.toReal := by
  have hnR : (4 : ℝ) / ((n : ℝ) + 1) ≤ (b : ℝ) - (a : ℝ) := by
    have : ((4 / (n + 1 : ℚ) : ℚ) : ℝ) ≤ ((b - a : ℚ) : ℝ) := by exact_mod_cast hn
    push_cast at this
    exact this
  have hR : ((a : ℝ) + (b : ℝ)) / 2 ≤ (x.approx n : ℝ) := by
    have : (((a + b) / 2 : ℚ) : ℝ) ≤ ((x.approx n : ℚ) : ℝ) := by exact_mod_cast h
    push_cast at this
    exact this
  have hlow := x.toReal_lower n
  have hpos : (0 : ℝ) < (n : ℝ) + 1 := by positivity
  have h4 : (1 : ℝ) / ((n : ℝ) + 1) ≤ ((b : ℝ) - (a : ℝ)) / 4 := by
    have he : (4 : ℝ) / ((n : ℝ) + 1) = 4 * (1 / ((n : ℝ) + 1)) := by ring
    rw [he] at hnR
    linarith
  have hab : (0 : ℝ) < (b : ℝ) - (a : ℝ) := by
    have : (0 : ℝ) < 4 / ((n : ℝ) + 1) := by positivity
    linarith
  linarith

/-- If the `n`-th approximation is below the midpoint of `[a,b]`, and the index is
fine enough, then the real denoted by `x` is strictly below `b`. -/
theorem approx_locate_right {x : Reg} {a b : ℚ} {n : ℕ}
    (hn : 4 / (n + 1 : ℚ) ≤ b - a) (h : x.approx n < (a + b) / 2) :
    x.toReal < (b : ℝ) := by
  have hnR : (4 : ℝ) / ((n : ℝ) + 1) ≤ (b : ℝ) - (a : ℝ) := by
    have : ((4 / (n + 1 : ℚ) : ℚ) : ℝ) ≤ ((b - a : ℚ) : ℝ) := by exact_mod_cast hn
    push_cast at this
    exact this
  have hR : (x.approx n : ℝ) < ((a : ℝ) + (b : ℝ)) / 2 := by
    have : ((x.approx n : ℚ) : ℝ) < (((a + b) / 2 : ℚ) : ℝ) := by exact_mod_cast h
    push_cast at this
    exact this
  have hup := x.toReal_upper n
  have h4 : (1 : ℝ) / ((n : ℝ) + 1) ≤ ((b : ℝ) - (a : ℝ)) / 4 := by
    have he : (4 : ℝ) / ((n : ℝ) + 1) = 4 * (1 / ((n : ℝ) + 1)) := by ring
    rw [he] at hnR
    linarith
  have hab : (0 : ℝ) < (b : ℝ) - (a : ℝ) := by
    have : (0 : ℝ) < 4 / ((n : ℝ) + 1) := by positivity
    linarith
  linarith

/-- **Constructive location.**  For rationals `a < b` and any Bishop real `x`, a
single rational comparison at a computed index decides `a < x` or `x < b`.  (The
classically trivial `a < x ∨ x ≤ a` is *not* constructively available; this
overlapping disjunction is its constructive replacement.) -/
theorem approx_locate (x : Reg) {a b : ℚ} (hab : a < b) :
    (a : ℝ) < x.toReal ∨ x.toReal < (b : ℝ) := by
  have habR : (0 : ℝ) < ((b - a : ℚ) : ℝ) := by exact_mod_cast sub_pos.mpr hab
  obtain ⟨n, hnR⟩ := exists_nat_inv_lt 4 habR
  have hn : 4 / (n + 1 : ℚ) ≤ b - a := by
    have : ((4 / (n + 1 : ℚ) : ℚ) : ℝ) ≤ ((b - a : ℚ) : ℝ) := by
      push_cast
      push_cast at hnR
      linarith
    exact_mod_cast this
  by_cases h : (a + b) / 2 ≤ x.approx n
  · exact Or.inl (approx_locate_left hn h)
  · push_neg at h
    exact Or.inr (approx_locate_right hn h)

/-! ## The order is not decidable at bounded precision -/

/-- **No uniform witness bound.**  However large a precision `N` is fixed in advance,
there are Bishop reals with `x < y` for which no index `n ≤ N` witnesses the
inequality: the witness in `Lt` genuinely depends on the pair, so the order cannot
be decided by inspecting a bounded number of approximations.  This is the exact
sense in which the constructive order, though extensionally the classical one
(`lt_iff_toReal_lt`), is not a decidable relation on the approximating data. -/
theorem no_uniform_lt_witness (N : ℕ) :
    ∃ x y : Reg, Lt x y ∧ ∀ n ≤ N, ¬ (x.approx n + 2 / (n + 1 : ℚ) < y.approx n) := by
  refine ⟨ofRat 0, ofRat (1 / (N + 1)), ?_, ?_⟩
  · rw [lt_iff_toReal_lt, toReal_ofRat, toReal_ofRat]
    have : (0 : ℝ) < ((1 / (N + 1 : ℚ) : ℚ) : ℝ) := by
      have : (0 : ℚ) < 1 / (N + 1) := by positivity
      exact_mod_cast this
    simpa using this
  · intro n hn hlt
    simp only [ofRat_approx] at hlt
    have h1 : (1 : ℚ) / (N + 1) ≤ 2 / (n + 1) := by
      have hn' : ((n : ℚ) + 1) ≤ (N : ℚ) + 1 := by
        have : (n : ℚ) ≤ (N : ℚ) := by exact_mod_cast hn
        linarith
      have hpos : (0 : ℚ) < (n : ℚ) + 1 := by positivity
      have hstep : (1 : ℚ) / ((N : ℚ) + 1) ≤ 1 / ((n : ℚ) + 1) :=
        one_div_le_one_div_of_le hpos hn'
      have : (1 : ℚ) / ((n : ℚ) + 1) ≤ 2 / ((n : ℚ) + 1) := by
        rw [div_le_div_iff_of_pos_right hpos]
        norm_num
      linarith
    linarith

end Reg

end Bishop