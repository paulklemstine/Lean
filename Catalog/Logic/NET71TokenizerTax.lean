/-
# NET-71 — the tokenizer tax: quantisation, resolution, and what the `+4` really certifies

The round names its verdict *the tokenizer tax is four keys*: German prose needs one
fine grid step more cache than English prose, at both measured contexts.  This file is
the adversarial half of the round.  A sweep reports a *quantised* knee, so three
questions must be separated:

1. what the grid does to a knee (a closure operator, §1);
2. what the reported `+4` certifies about the unquantised knees (§2 — **less than the
   headline claims**: the true tax is pinned only to the open interval `(0, 8)`, though
   it is certified to be strictly positive, so P3 is refuted even continuously);
3. which sweep grids can see the effect at all (§3 — the step-`4` grid is the *coarsest*
   faithful one, and a step-`8` grid both hides the code gap and doubles the German one).

§4 then turns the informal mechanism — German compounds pack more content per token —
into a calibrated, falsifiable model: a corpus of relative content density `ρ` has
predicted base `4 · ⌈4ρ⌉`.  Calibrated on English (`ρ = 1 ↦ 16`), the measured bases
force the densities into *disjoint* intervals: code `ρ ∈ (1/2, 3/4]`, English `ρ ∈
(3/4, 1]`, German `ρ ∈ (1, 5/4]`.  These are statements about token counts alone —
checkable on the corpora with no model training — so the tokenizer-tax mechanism is
falsifiable independently of the sweep that suggested it.

## What this file proves

* §1 `gridUp_le_iff` (Galois connection), `le_gridUp`, `gridUp_mono`, `gridUp_idem`
  (the sweep grid is a closure operator on the budget axis).
* §2 `true_knee_bracket`, `net71_true_shift_pos`, `net71_true_shift_lt_two_steps`,
  `net71_true_shift_not_identifiable` (two scenarios consistent with all four measured
  readings whose true shifts are `1/2` and `31/4`), `net71_reported_shift_is_one_step`.
* §3 `roundUp_eq_self_iff_dvd`, `net71_grid_faithful_iff_dvd_four`,
  `coarse_grid_hides_code_gap_and_doubles_german_gap`.
* §4 `predBase_calibrated`, `predBase_mono`, `predBase_eq_iff`,
  `net71_density_intervals`, `net71_density_intervals_disjoint`,
  `high_density_forces_seven_steps`.
-/
import Mathlib
import Logic.NET71FourDomainDeployment

namespace Catalog.NET71

open Catalog.NET68

/-! ## 1. The sweep grid is a closure operator -/

/-- Reading a budget on a sweep grid of step `s`: round it up to the next multiple. -/
noncomputable def gridUp (s : ℕ) (x : ℚ) : ℚ := (s : ℚ) * ⌈x / s⌉₊

/-- **Galois connection.**  A grid point `s · n` is enough budget for a true requirement
`x` exactly when its index dominates the ceiling index of `x`.  Every statement in this
section is a consequence. -/
theorem gridUp_le_iff {s : ℕ} (hs : 0 < s) (x : ℚ) (n : ℕ) :
    x ≤ (s : ℚ) * n ↔ ⌈x / s⌉₊ ≤ n := by
  have hs' : (0 : ℚ) < s := by exact_mod_cast hs
  rw [Nat.ceil_le, div_le_iff₀ hs', mul_comm]

/-- Rounding up never loses budget. -/
theorem le_gridUp {s : ℕ} (hs : 0 < s) (x : ℚ) : x ≤ gridUp s x := by
  have hs' : (0 : ℚ) < s := by exact_mod_cast hs
  have h := Nat.le_ceil (x / s)
  calc x = (s : ℚ) * (x / s) := by field_simp
    _ ≤ (s : ℚ) * ⌈x / s⌉₊ := by exact mul_le_mul_of_nonneg_left h hs'.le

/-- A coarser reading of a larger requirement is larger. -/
theorem gridUp_mono {s : ℕ} (hs : 0 < s) : Monotone (gridUp s) := by
  intro x y hxy
  have hs' : (0 : ℚ) < s := by exact_mod_cast hs
  have : ⌈x / s⌉₊ ≤ ⌈y / s⌉₊ := Nat.ceil_le_ceil (by gcongr)
  have : ((⌈x / s⌉₊ : ℚ)) ≤ (⌈y / s⌉₊ : ℚ) := by exact_mod_cast this
  simpa [gridUp] using mul_le_mul_of_nonneg_left this hs'.le

/-- Re-reading a grid value on the same grid changes nothing: the sweep is idempotent,
so a reported knee is a fixed point of the measurement. -/
theorem gridUp_idem {s : ℕ} (hs : 0 < s) (x : ℚ) : gridUp s (gridUp s x) = gridUp s x := by
  have hs' : (0 : ℚ) ≠ (s : ℚ) := by
    have : (0 : ℚ) < s := by exact_mod_cast hs
    exact ne_of_lt this
  have : (s : ℚ) * (⌈x / s⌉₊ : ℚ) / s = (⌈x / s⌉₊ : ℚ) := by
    field_simp
  simp [gridUp, this, Nat.ceil_natCast]

/-- Grid points are exactly the fixed points of the reading map. -/
theorem gridUp_natCast_mul {s : ℕ} (hs : 0 < s) (n : ℕ) :
    gridUp s ((s : ℚ) * n) = (s : ℚ) * n := by
  have hs' : (0 : ℚ) ≠ (s : ℚ) := by
    have : (0 : ℚ) < s := by exact_mod_cast hs
    exact ne_of_lt this
  have h : (s : ℚ) * (n : ℚ) / s = (n : ℚ) := by field_simp
  simp [gridUp, h, Nat.ceil_natCast]

/-! ## 2. What the reported `+4` certifies about the true knees -/

/-- **Bracketing.**  A sweep of step `4` that reports index `j ≠ 0` certifies exactly
that the true knee lies in the half-open cell `(4j − 4, 4j]`, and nothing more. -/
theorem true_knee_bracket {κ : ℚ} {j : ℕ} (hj : j ≠ 0)
    (h : ⌈κ / 4⌉₊ = j) : 4 * (j : ℚ) - 4 < κ ∧ κ ≤ 4 * j := by
  have hb := (Nat.ceil_eq_iff hj).1 h
  have hj1 : 1 ≤ j := Nat.one_le_iff_ne_zero.2 hj
  have hcast : ((j - 1 : ℕ) : ℚ) = (j : ℚ) - 1 := by
    rw [Nat.cast_sub hj1, Nat.cast_one]
  rw [hcast] at hb
  exact ⟨by linarith [hb.1], by linarith [hb.2]⟩

/-- **The true tax is strictly positive.**  Whatever the unquantised German and English
knees are, the measured readings (`index 5` for German, `index 4` for English, on the
step-`4` grid at `ctx = 512`) force the German knee strictly above the English one: P3 is
refuted at the continuous level, not merely on the grid. -/
theorem net71_true_shift_pos {κDE κEN : ℚ}
    (hDE : ⌈κDE / 4⌉₊ = 5) (hEN : ⌈κEN / 4⌉₊ = 4) : 0 < κDE - κEN := by
  have h1 := (true_knee_bracket (by norm_num) hDE).1
  have h2 := (true_knee_bracket (by norm_num) hEN).2
  norm_num at h1 h2
  linarith

/-- **…but it is not four.**  The same readings bound the true tax only by two fine
steps. -/
theorem net71_true_shift_lt_two_steps {κDE κEN : ℚ}
    (hDE : ⌈κDE / 4⌉₊ = 5) (hEN : ⌈κEN / 4⌉₊ = 4) : κDE - κEN < 8 := by
  have h1 := (true_knee_bracket (by norm_num) hDE).2
  have h2 := (true_knee_bracket (by norm_num) hEN).1
  norm_num at h1 h2
  linarith

/-- **Non-identifiability, exhibited.**  Two scenarios reproduce *both* measured indices
at `ctx = 512` yet have true taxes `1/2` and `31/4`: the headline value `4` is a property
of the reported grid readings, not of the underlying knees.  This is the sharp boundary
of the verdict, and `net71_true_shift_pos` is what survives it. -/
theorem net71_true_shift_not_identifiable :
    (∃ κDE κEN : ℚ, ⌈κDE / 4⌉₊ = 5 ∧ ⌈κEN / 4⌉₊ = 4 ∧ κDE - κEN = 1 / 2) ∧
    (∃ κDE κEN : ℚ, ⌈κDE / 4⌉₊ = 5 ∧ ⌈κEN / 4⌉₊ = 4 ∧ κDE - κEN = 31 / 4) := by
  constructor
  · refine ⟨33 / 2, 16, ?_, ?_, by norm_num⟩
    · rw [show (33 : ℚ) / 2 / 4 = 33 / 8 by norm_num,
        Nat.ceil_eq_iff (n := 5) (by norm_num)]
      norm_num
    · rw [show (16 : ℚ) / 4 = 4 by norm_num, Nat.ceil_eq_iff (n := 4) (by norm_num)]
      norm_num
  · refine ⟨20, 49 / 4, ?_, ?_, by norm_num⟩
    · rw [show (20 : ℚ) / 4 = 5 by norm_num, Nat.ceil_eq_iff (n := 5) (by norm_num)]
      norm_num
    · rw [show (49 : ℚ) / 4 / 4 = 49 / 16 by norm_num,
        Nat.ceil_eq_iff (n := 4) (by norm_num)]
      norm_num

/-- What *is* identified: the reported budgets, and hence the reported shift, are exactly
one fine step apart — for every pair of true knees consistent with the two readings. -/
theorem net71_reported_shift_is_one_step {κDE κEN : ℚ}
    (hDE : ⌈κDE / 4⌉₊ = 5) (hEN : ⌈κEN / 4⌉₊ = 4) :
    gridUp 4 κDE - gridUp 4 κEN = (fineStep : ℚ) := by
  simp only [gridUp, fineStep]
  rw [show ((4 : ℕ) : ℚ) = 4 from rfl] at *
  rw [hDE, hEN]
  norm_num

/-! ## 3. Which grids can see the effect -/

/-- A budget is unchanged by a step-`g` reading exactly when it is a multiple of `g`.
(One direction is `Catalog.NET68.roundUp_of_dvd`; this is the converse.) -/
theorem roundUp_eq_self_iff_dvd {g k : ℕ} (hg : 0 < g) : roundUp g k = k ↔ g ∣ k := by
  constructor
  · intro h
    refine ⟨(k + g - 1) / g, ?_⟩
    conv_lhs => rw [← h]
    rfl
  · intro h; exact roundUp_of_dvd hg h

/-- **Exact resolution threshold.**  A sweep of step `g` reports all four measured bases
without distortion iff `g` divides `4`: the fine grid of round 21–24 is the *coarsest*
faithful one. -/
theorem net71_grid_faithful_iff_dvd_four {g : ℕ} (hg : 0 < g) :
    (roundUp g 12 = 12 ∧ roundUp g 16 = 16 ∧ roundUp g 20 = 20) ↔ g ∣ 4 := by
  constructor
  · rintro ⟨h12, h16, _⟩
    have d12 : g ∣ 12 := (roundUp_eq_self_iff_dvd hg).1 h12
    have d16 : g ∣ 16 := (roundUp_eq_self_iff_dvd hg).1 h16
    simpa using Nat.dvd_sub d16 d12
  · intro hg4
    refine ⟨(roundUp_eq_self_iff_dvd hg).2 (hg4.trans (by norm_num)), ?_, ?_⟩
    · exact (roundUp_eq_self_iff_dvd hg).2 (hg4.trans (by norm_num))
    · exact (roundUp_eq_self_iff_dvd hg).2 (hg4.trans (by norm_num))

/-- **The step-`8` grid is doubly misleading**: it collapses the code/English gap to zero
and inflates the English/German gap to `8`, twice its true reported size.  Only the
step-`4` grid reports both gaps correctly. -/
theorem coarse_grid_hides_code_gap_and_doubles_german_gap :
    roundUp 8 12 = roundUp 8 16 ∧
    roundUp 8 20 - roundUp 8 16 = 2 * fineStep ∧
    roundUp 4 16 - roundUp 4 12 = fineStep ∧
    roundUp 4 20 - roundUp 4 16 = fineStep := by
  refine ⟨by norm_num [roundUp], ?_, ?_, ?_⟩ <;> norm_num [roundUp, fineStep]

/-! ## 4. The tokenizer-tax mechanism, calibrated and falsifiable -/

/-- **The density model.**  A corpus whose content density is `ρ` times English's needs
`16ρ` keys before quantisation, i.e. a base of `4 · ⌈4ρ⌉` on the fine grid. -/
noncomputable def predBase (ρ : ℚ) : ℕ := 4 * ⌈4 * ρ⌉₊

/-- The model is the grid reading of the linear content requirement. -/
theorem predBase_eq_gridUp (ρ : ℚ) : (predBase ρ : ℚ) = gridUp 4 (16 * ρ) := by
  simp only [predBase, gridUp, Nat.cast_mul, Nat.cast_ofNat]
  rw [show (16 : ℚ) * ρ / 4 = 4 * ρ by ring]

/-- **Calibration.**  English prose, the reference corpus, has `ρ = 1` and base `16`. -/
theorem predBase_calibrated : predBase 1 = 16 := by
  simp [predBase]

/-- Denser corpora never need fewer keys. -/
theorem predBase_mono : Monotone predBase := by
  intro x y hxy
  exact Nat.mul_le_mul_left 4 (Nat.ceil_le_ceil (by gcongr))

/-- The model inverted: a measured base of `4n` (with `n ≠ 0`) pins the density to the
half-open interval `((n−1)/4, n/4]`. -/
theorem predBase_eq_iff {ρ : ℚ} {n : ℕ} (hn : n ≠ 0) :
    predBase ρ = 4 * n ↔ ((n : ℚ) - 1) / 4 < ρ ∧ ρ ≤ (n : ℚ) / 4 := by
  have h4 : (0 : ℚ) < 4 := by norm_num
  have hn1 : 1 ≤ n := Nat.one_le_iff_ne_zero.2 hn
  have hcast : ((n - 1 : ℕ) : ℚ) = (n : ℚ) - 1 := by rw [Nat.cast_sub hn1, Nat.cast_one]
  constructor
  · intro h
    have hc : ⌈4 * ρ⌉₊ = n := by
      have : 4 * ⌈4 * ρ⌉₊ = 4 * n := h
      omega
    have hb := (Nat.ceil_eq_iff hn).1 hc
    rw [hcast] at hb
    exact ⟨by linarith [hb.1], by linarith [hb.2]⟩
  · rintro ⟨h1, h2⟩
    have hc : ⌈4 * ρ⌉₊ = n := by
      refine (Nat.ceil_eq_iff hn).2 ⟨?_, by linarith⟩
      rw [hcast]; linarith
    simp [predBase, hc]

/-- **The measured bases bound the three densities.**  Code, English and German are
forced into the stated intervals — statements about token counts alone, testable on the
corpora without training a model. -/
theorem net71_density_intervals {ρc ρe ρd : ℚ}
    (hcb : predBase ρc = 12) (heb : predBase ρe = 16) (hdb : predBase ρd = 20) :
    (1 / 2 < ρc ∧ ρc ≤ 3 / 4) ∧ (3 / 4 < ρe ∧ ρe ≤ 1) ∧ (1 < ρd ∧ ρd ≤ 5 / 4) := by
  have h1 := (predBase_eq_iff (ρ := ρc) (n := 3) (by norm_num)).1 (by omega)
  have h2 := (predBase_eq_iff (ρ := ρe) (n := 4) (by norm_num)).1 (by omega)
  have h3 := (predBase_eq_iff (ρ := ρd) (n := 5) (by norm_num)).1 (by omega)
  norm_num at h1 h2 h3
  exact ⟨⟨by linarith [h1.1], by linarith [h1.2]⟩, ⟨by linarith [h2.1], by linarith [h2.2]⟩,
    ⟨by linarith [h3.1], by linarith [h3.2]⟩⟩

/-- The three intervals are disjoint and ordered: the mechanism predicts a strict density
ladder `code < English < German`, which the `+4`/`−4` shifts already certify. -/
theorem net71_density_intervals_disjoint {ρc ρe ρd : ℚ} (hcb : predBase ρc = 12)
    (heb : predBase ρe = 16) (hdb : predBase ρd = 20) : ρc < ρe ∧ ρe < ρd := by
  obtain ⟨⟨_, hc2⟩, ⟨he1, he2⟩, ⟨hd1, _⟩⟩ := net71_density_intervals hcb heb hdb
  exact ⟨by linarith, by linarith⟩

/-- **A pre-registered prediction for the next language.**  Any corpus packing more than
`3/2` times English's content per token must show a base of at least `28` keys — seven
fine steps — at `ctx = 512`.  A language measured denser than that but reading `20` would
refute the density model outright. -/
theorem high_density_forces_seven_steps {ρ : ℚ} (hρ : 3 / 2 < ρ) : 28 ≤ predBase ρ := by
  have h : (6 : ℚ) < 4 * ρ := by linarith
  have h7 : 7 ≤ ⌈4 * ρ⌉₊ := by
    have := Nat.ceil_lt_add_one (a := 4 * ρ) (by linarith)
    by_contra hlt
    push_neg at hlt
    have hle : ⌈4 * ρ⌉₊ ≤ 6 := by omega
    have : 4 * ρ ≤ (6 : ℚ) := le_trans (Nat.le_ceil _) (by exact_mod_cast hle)
    linarith
  simpa [predBase] using Nat.mul_le_mul_left 4 h7

/-- The model reproduces the whole measured table from the three densities: with any
admissible choice, the predicted bases are exactly the measured `12, 16, 20`, and the
German-minus-English gap is exactly one fine step. -/
theorem net71_model_reproduces_table {ρc ρe ρd : ℚ} (hcb : predBase ρc = 12)
    (heb : predBase ρe = 16) (hdb : predBase ρd = 20) :
    predBase ρd - predBase ρe = fineStep ∧ predBase ρe - predBase ρc = fineStep := by
  rw [hcb, heb, hdb]
  constructor <;> norm_num [fineStep]

end Catalog.NET71