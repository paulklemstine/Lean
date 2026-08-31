import Mathlib

/-!
# Ascent economics: restart energy, accuracy thresholds, compounding hints

Companion to `Bridges.TwoTreeClosure.TreeCore`.  A guided ascent of the
Berggren/Price tree of height `h` whose per-step letter oracle is correct with
probability `a` succeeds with probability `a ^ h`; with restarts, the expected
number of visited nodes is the **restart energy**

`E h a = h / a ^ h = h * a ^ (-h)`.

Results proved here:

* `restartEnergy_ge_height`, `restartEnergy_strictMono_height` : `E` is at least the
  height and strictly increases with the height for any accuracy `a < 1`;
* `restartEnergy_antitone_accuracy` : `E` strictly decreases in the accuracy;
* `restartEnergy_le_iff` : the budget constraint `E h a ≤ c` is exactly `h ≤ c aʰ`;
* `accuracy_085_over_budget` / `accuracy_086_within_budget` : at height `30` and
  budget `3000` visit-equivalents the critical accuracy `α*` lies strictly between
  `0.85` and `0.86` — a rigorous version of the empirical law `α* ≥ 0.85`;
* `sequential_hints_compound` / `compound_below_saturating` : sequential hints
  compound geometrically (`a ^ h → 0`) while a saturating class hint stays put;
* `exhaustive_cost_astronomical` : the exhaustive alternative at height `30` costs
  `(3 ^ 31 - 1) / 2 > 10 ^ 14` visits, so only the guided regime is on the table.
-/

namespace TwoTreeClosure

open Filter

/-- Expected number of node visits of a restarted guided ascent of height `h` whose
per-step letter oracle has accuracy `a`. -/
noncomputable def restartEnergy (h : ℕ) (a : ℝ) : ℝ := (h : ℝ) / a ^ h

theorem restartEnergy_eq_mul_inv (h : ℕ) (a : ℝ) :
    restartEnergy h a = (h : ℝ) * (a ^ h)⁻¹ := div_eq_mul_inv _ _

/-- With accuracy at most `1`, the restart energy is at least the height. -/
theorem restartEnergy_ge_height {a : ℝ} (h : ℕ) (ha : 0 < a) (ha1 : a ≤ 1) :
    (h : ℝ) ≤ restartEnergy h a := by
  have hpow : a ^ h ≤ 1 := pow_le_one₀ ha.le ha1
  have hpos : (0 : ℝ) < a ^ h := pow_pos ha h
  rw [restartEnergy, le_div_iff₀ hpos]
  nlinarith [Nat.cast_nonneg (α := ℝ) h]

/-- Below perfect accuracy, the restart energy strictly increases with the height. -/
theorem restartEnergy_strictMono_height {a : ℝ} (h : ℕ) (ha : 0 < a) (ha1 : a < 1) :
    restartEnergy h a < restartEnergy (h + 1) a := by
  have hpos : (0 : ℝ) < a ^ h := pow_pos ha h
  have hpos' : (0 : ℝ) < a ^ (h + 1) := pow_pos ha (h + 1)
  rw [restartEnergy, restartEnergy, div_lt_div_iff₀ hpos hpos']
  have hstep : a ^ (h + 1) = a ^ h * a := by ring
  rw [hstep]
  push_cast
  have hkey : (h : ℝ) * a < (h : ℝ) + 1 := by nlinarith [Nat.cast_nonneg (α := ℝ) h]
  nlinarith [mul_lt_mul_of_pos_left hkey hpos]

/-- The restart energy is strictly decreasing in the per-step accuracy. -/
theorem restartEnergy_antitone_accuracy {a b : ℝ} {h : ℕ} (hh : 1 ≤ h) (ha : 0 < a)
    (hab : a < b) : restartEnergy h b < restartEnergy h a := by
  have hb : 0 < b := ha.trans hab
  have hpa : (0 : ℝ) < a ^ h := pow_pos ha h
  have hpb : (0 : ℝ) < b ^ h := pow_pos hb h
  have hlt : a ^ h < b ^ h := by
    exact pow_lt_pow_left₀ hab ha.le (by omega)
  have hhpos : (0 : ℝ) < (h : ℝ) := by exact_mod_cast Nat.lt_of_lt_of_le Nat.zero_lt_one hh
  rw [restartEnergy, restartEnergy, div_lt_div_iff₀ hpb hpa]
  nlinarith

/-- The budget constraint in its multiplicative form. -/
theorem restartEnergy_le_iff {a c : ℝ} {h : ℕ} (ha : 0 < a) :
    restartEnergy h a ≤ c ↔ (h : ℝ) ≤ c * a ^ h := by
  have hpos : (0 : ℝ) < a ^ h := pow_pos ha h
  rw [restartEnergy, div_le_iff₀ hpos]

/-! ### The critical accuracy at height 30 with a budget of 3000 visits -/

/-- Accuracy `0.85` blows the budget: `E 30 0.85 > 3000`. -/
theorem accuracy_085_over_budget : (3000 : ℝ) < restartEnergy 30 (17 / 20) := by
  have ha : (0 : ℝ) < 17 / 20 := by norm_num
  have hkey : ¬ ((30 : ℝ) ≤ 3000 * (17 / 20 : ℝ) ^ 30) := by
    norm_num
  have := (restartEnergy_le_iff (a := (17 / 20 : ℝ)) (c := 3000) (h := 30) ha)
  push_cast at this
  exact lt_of_not_ge fun hle => hkey (this.mp hle)

/-- Accuracy `0.86` fits the budget: `E 30 0.86 ≤ 3000`. -/
theorem accuracy_086_within_budget : restartEnergy 30 (43 / 50) ≤ 3000 := by
  have ha : (0 : ℝ) < 43 / 50 := by norm_num
  have hkey : (30 : ℝ) ≤ 3000 * (43 / 50 : ℝ) ^ 30 := by norm_num
  have := (restartEnergy_le_iff (a := (43 / 50 : ℝ)) (c := 3000) (h := 30) ha)
  push_cast at this
  exact this.mpr hkey

/-- **Critical accuracy.**  Every accuracy at most `0.85` overshoots a budget of
`3000` visit-equivalents at height `30`, while `0.86` fits: the threshold `α*`
satisfies `0.85 < α* ≤ 0.86`. -/
theorem critical_accuracy_bracket :
    (∀ a : ℝ, 0 < a → a ≤ 17 / 20 → (3000 : ℝ) < restartEnergy 30 a) ∧
      restartEnergy 30 (43 / 50) ≤ 3000 := by
  refine ⟨?_, accuracy_086_within_budget⟩
  intro a ha hle
  rcases eq_or_lt_of_le hle with rfl | hlt
  · exact accuracy_085_over_budget
  · exact accuracy_085_over_budget.trans
      (restartEnergy_antitone_accuracy (h := 30) (by norm_num) ha hlt)

/-! ### Compounding versus saturation -/

/-- **Sequential hints compound.**  With per-step accuracy `a < 1` the probability of
a correct height-`h` ascent decays geometrically to `0`. -/
theorem sequential_hints_compound {a : ℝ} (ha : 0 ≤ a) (ha1 : a < 1) :
    Tendsto (fun h : ℕ => a ^ h) atTop (nhds 0) :=
  tendsto_pow_atTop_nhds_zero_of_lt_one ha ha1

/-- Quantitative form: any target confidence is lost after finitely many steps. -/
theorem sequential_hints_compound_quant {a : ℝ} (ha : 0 ≤ a) (ha1 : a < 1) (ε : ℝ)
    (hε : 0 < ε) : ∃ H : ℕ, ∀ h ≥ H, a ^ h < ε := by
  have := (sequential_hints_compound ha ha1).eventually (eventually_lt_nhds hε)
  obtain ⟨H, hH⟩ := eventually_atTop.mp this
  exact ⟨H, fun h hh => hH h hh⟩

/-- The gap between the two regimes: a compounding hint eventually drops below any
fixed saturating level. -/
theorem compound_below_saturating {a c : ℝ} (ha : 0 ≤ a) (ha1 : a < 1) (hc : 0 < c) :
    ∃ H : ℕ, ∀ h ≥ H, a ^ h < c :=
  sequential_hints_compound_quant ha ha1 c hc

/-! ### The exhaustive alternative -/

/-- Exhaustive search of the ternary tree to depth `30` visits `(3 ^ 31 - 1) / 2`
nodes, more than `10 ^ 14` — eleven orders of magnitude above the guided budget. -/
theorem exhaustive_cost_astronomical :
    2 * ((3 ^ 31 - 1) / 2 : ℕ) + 1 = 3 ^ 31 ∧ (10 : ℕ) ^ 14 < (3 ^ 31 - 1) / 2 := by
  constructor <;> norm_num

end TwoTreeClosure