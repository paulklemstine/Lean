import Mathlib
import Shared.AttentionBudgetKnee
import Shared.CatalogbuildSharedIspythtriple.IsPythTriple
import Pythagorean.NET79GeometricRatioKnee

/-!
# Pythagorean decay ratios: a universal short-leg budget, and a forced inversion

Attach to a Pythagorean triple `a ^ 2 + b ^ 2 = c ^ 2` (`IsPythTriple`, the catalog
definition) the two *decay ratios* `a / c` and `b / c` and the two geometric attention
profiles they generate.  Because the ratios lie on the unit circle, the pair
`(a/c, b/c)` is rigidly constrained, and the knee theory of
`Pythagorean/NET79GeometricRatioKnee.lean` converts that rigidity into hard statements
about key budgets.

The three main results, at the NET-79 gate `τ = 0.985`:

* `pyth_short_leg_budget_le_thirteen` — **a universal budget.**  For *every*
  Pythagorean triple and *every* context length, the short-leg profile clears the gate
  with `13` keys.  The mechanism is purely Pythagorean: `a ≤ b` and `a² + b² = c²`
  force `(a/c)² ≤ 1/2`, and the exact geometric certificate then gives `13`.
* `pyth_universal_budget_thirteen_sharp` — **and it is sharp.**  The near-isosceles
  triple `(696, 697, 985)` (a Pell triple) has short-leg knee exactly `13` at context
  `64`, so no smaller universal budget exists.
* `pyth_long_leg_budget_unbounded` — **the complementary side has no budget at all.**
  Over the family `(2m+1, 2m(m+1), 2m(m+1)+1)` the long-leg knee exceeds every bound.

Together with `pyth_knee_inversion` these give the Pythagorean analogue of the NET-79
scale × context phenomenon: an ordering of budgets that is *forced to invert*.  If one
triple has the smaller short-leg budget it necessarily has the larger long-leg budget —
the unit-circle constraint makes non-monotone interaction unavoidable, and
`net79_explicit_inversion` exhibits it with the concrete pair `(3,4,5)`, `(20,21,29)`:
short-leg knees `9 < 12`, long-leg knees `19 > 14`.

-- !-- Lab Notes -- !--
Hypothesizer:
 (P1) Some absolute constant `K(τ)` bounds the short-leg budget over *all* triples and
      contexts.                                                              [BOLD]
 (P2) `K(0.985) = 13`, attained by near-isosceles (Pell) triples.            [BOLD]
 (P3) No such constant exists for long legs.
 (P4) Ratio inversion is forced: the triple with the smaller short-leg budget has the
      larger long-leg budget.                                                [BOLD]
Experimenter: P1–P4 proved below, zero sorries.  Exact knees computed at context 64,
gate 0.985: `3/5 ↦ 9`, `20/29 ↦ 12`, `21/29 ↦ 14`, `4/5 ↦ 19`, `696/985 ↦ 13`.
Analyst: P2 is the surprise.  The *generic* tail certificate `r^K/(1-r) ≤ 1-τ` would
give `16`; the exact geometric certificate `r^K ≤ 1-τ` gives `13`, and the gap between
`13` and `16` is exactly the `1/(1-r)` loss of the generic bound.  Both numbers occur
in the NET-79 grid, which is a coincidence of the gate value and is flagged as such:
nothing here claims to derive a measured knee from arithmetic.
Critic: every quantitative claim is a bracket (a pass *and* a fail), so no theorem is
one-sided; `pyth_long_leg_budget_unbounded` produces genuine triples (verified by
`ring`), not a vacuous existential.
-/

namespace PythKnee

open AttentionBudget

/-- The decay ratio a leg contributes: `x / c`. -/
noncomputable def legRatio (x c : ℤ) : ℝ := (x : ℝ) / (c : ℝ)

lemma legRatio_pos {x c : ℤ} (hx : 0 < x) (hc : 0 < c) : 0 < legRatio x c := by
  have hx' : (0 : ℝ) < (x : ℝ) := by exact_mod_cast hx
  have hc' : (0 : ℝ) < (c : ℝ) := by exact_mod_cast hc
  exact div_pos hx' hc'

/-- The two ratios of a Pythagorean triple lie on the unit circle. -/
lemma legRatio_sq_add {a b c : ℤ} (h : IsPythTriple a b c) (hc : 0 < c) :
    legRatio a c ^ 2 + legRatio b c ^ 2 = 1 := by
  have hc' : (0 : ℝ) < (c : ℝ) := by exact_mod_cast hc
  have hR : (a : ℝ) ^ 2 + (b : ℝ) ^ 2 = (c : ℝ) ^ 2 := by exact_mod_cast h
  rw [legRatio, legRatio, div_pow, div_pow, (add_div _ _ _).symm, hR,
    div_self (by positivity : ((c : ℝ)) ^ 2 ≠ 0)]

lemma legRatio_lt_one {a b c : ℤ} (h : IsPythTriple a b c) (hb : 0 < b) (hc : 0 < c) :
    legRatio a c < 1 := by
  have hc' : (0 : ℝ) < (c : ℝ) := by exact_mod_cast hc
  have hsq := legRatio_sq_add h hc
  have hbpos : 0 < legRatio b c := legRatio_pos hb hc
  nlinarith [sq_nonneg (legRatio a c - 1), sq_nonneg (legRatio a c + 1)]

/-- **The Pythagorean squeeze.**  The shorter leg's ratio has square at most `1/2`. -/
theorem short_legRatio_sq_le_half {a b c : ℤ} (h : IsPythTriple a b c) (ha : 0 < a)
    (hab : a ≤ b) (hc : 0 < c) : legRatio a c ^ 2 ≤ 1 / 2 := by
  have hsq := legRatio_sq_add h hc
  have hc' : (0 : ℝ) < (c : ℝ) := by exact_mod_cast hc
  have hmono : legRatio a c ≤ legRatio b c := by
    have hab' : (a : ℝ) ≤ (b : ℝ) := by exact_mod_cast hab
    rw [legRatio, legRatio]
    gcongr
  have hpos : 0 < legRatio a c := legRatio_pos ha hc
  nlinarith

/-- A rational consequence of the squeeze, convenient for numerics. -/
theorem short_legRatio_le {a b c : ℤ} (h : IsPythTriple a b c) (ha : 0 < a) (hab : a ≤ b)
    (hc : 0 < c) : legRatio a c ≤ 708 / 1000 := by
  have hsq := short_legRatio_sq_le_half h ha hab hc
  have hpos : 0 < legRatio a c := legRatio_pos ha hc
  nlinarith

/-! ## P1 — a universal short-leg budget of 13 keys at gate 0.985 -/

/-- **Universal Pythagorean key budget.**  For every Pythagorean triple with `0 < a ≤ b`
and every context length, `13` retained keys clear the `0.985` gate for the short-leg
geometric profile.  The bound depends on nothing but the Pythagorean relation. -/
theorem pyth_short_leg_budget_le_thirteen {a b c : ℤ} (h : IsPythTriple a b c) (ha : 0 < a)
    (hab : a ≤ b) (hc : 0 < c) {n : ℕ} (hn : 0 < n) :
    kstar (geomProfile (legRatio a c)) n (985 / 1000) ≤ 13 := by
  set r := legRatio a c with hr
  have hpos : 0 < r := legRatio_pos ha hc
  have hle : r ≤ 708 / 1000 := short_legRatio_le h ha hab hc
  have hsq : r ^ 2 ≤ 1 / 2 := short_legRatio_sq_le_half h ha hab hc
  have hlt1 : r < 1 := by linarith
  refine kstar_geomProfile_le_of_pow_le hpos hlt1 hn ?_
  have h6 : (r ^ 2) ^ 6 ≤ (1 / 2 : ℝ) ^ 6 := pow_le_pow_left₀ (by positivity) hsq 6
  have hfac : r ^ 13 = (r ^ 2) ^ 6 * r := by ring
  have : r ^ 13 ≤ (1 / 2 : ℝ) ^ 6 * (708 / 1000) := by
    rw [hfac]
    exact mul_le_mul h6 hle hpos.le (by positivity)
  norm_num at this ⊢
  linarith

/-! ## P2 — sharpness via the Pell triple `(696, 697, 985)` -/

lemma pell_triple : IsPythTriple 696 697 985 := by
  unfold IsPythTriple; norm_num

lemma legRatio_pell : legRatio 696 985 = (696 / 985 : ℝ) := by
  norm_num [legRatio]

set_option maxRecDepth 40000 in
/-- The short-leg knee of the near-isosceles triple `(696, 697, 985)` at context `64` is
exactly `13`: the universal budget of `pyth_short_leg_budget_le_thirteen` is attained. -/
theorem pell_short_leg_knee_eq_thirteen :
    kstar (geomProfile (legRatio 696 985)) 64 (985 / 1000) = 13 := by
  rw [legRatio_pell]
  refine kstar_geomProfile_eq_of_bracket (by norm_num) (by norm_num) (by norm_num)
    (by norm_num) (by norm_num) (by norm_num) ?_ ?_
  · rw [le_div_iff₀ (by norm_num)]; norm_num
  · norm_num

/-- **Sharpness.**  No universal budget smaller than `13` works: there is a Pythagorean
triple and a context at which `12` keys fail the `0.985` gate. -/
theorem pyth_universal_budget_thirteen_sharp :
    ∃ a b c : ℤ, ∃ n : ℕ, IsPythTriple a b c ∧ 0 < a ∧ a ≤ b ∧ 0 < c ∧
      12 < kstar (geomProfile (legRatio a c)) n (985 / 1000) := by
  refine ⟨696, 697, 985, 64, pell_triple, by norm_num, by norm_num, by norm_num, ?_⟩
  rw [pell_short_leg_knee_eq_thirteen]
  norm_num

/-! ## P3 — the long-leg budget is unbounded -/

lemma near_square_triple (m : ℕ) :
    IsPythTriple ((2 * m + 1 : ℕ) : ℤ) ((2 * m * m + 2 * m : ℕ) : ℤ)
      ((2 * m * m + 2 * m + 1 : ℕ) : ℤ) := by
  unfold IsPythTriple
  push_cast
  ring

/-- **No universal long-leg budget.**  For every bound `K` there is a Pythagorean triple
and a context length whose long-leg profile needs more than `K` keys at the `0.985`
gate.  The witnesses are the near-square triples `(2m+1, 2m(m+1), 2m(m+1)+1)`, whose
long-leg ratio `t/(t+1)` tends to `1`. -/
theorem pyth_long_leg_budget_unbounded (K : ℕ) :
    ∃ a b c : ℤ, ∃ n : ℕ, IsPythTriple a b c ∧ 0 < a ∧ a ≤ b ∧ 0 < c ∧ 0 < n ∧
      K < kstar (geomProfile (legRatio b c)) n (985 / 1000) := by
  set m : ℕ := 10 * K + 10 with hm
  set t : ℕ := 2 * m * m + 2 * m with ht
  refine ⟨((2 * m + 1 : ℕ) : ℤ), (t : ℤ), ((t + 1 : ℕ) : ℤ), 2 * K + 2,
    near_square_triple m, by positivity, ?_, by positivity, by omega, ?_⟩
  · have : 2 * m + 1 ≤ t := by simp only [ht, hm]; nlinarith [Nat.zero_le K]
    exact_mod_cast this
  · -- the long-leg ratio
    have htpos : 0 < t := by simp only [ht, hm]; nlinarith [Nat.zero_le K]
    have htR : (1 : ℝ) ≤ (t : ℝ) := by exact_mod_cast htpos
    have hden : (0 : ℝ) < (t : ℝ) + 1 := by linarith
    have hratio : legRatio (t : ℤ) ((t + 1 : ℕ) : ℤ) = (t : ℝ) / ((t : ℝ) + 1) := by
      unfold legRatio; push_cast; ring
    set r : ℝ := (t : ℝ) / ((t : ℝ) + 1) with hrdef
    have hr0 : 0 < r := by positivity
    have hr1 : r ≤ 1 := by rw [hrdef, div_le_one hden]; linarith
    -- a Bernoulli lower bound on `r ^ (2K+1)`
    have hbern : (1 : ℝ) - (2 * K + 1 : ℕ) / ((t : ℝ) + 1) ≤ r ^ (2 * K + 1) := by
      have hx : (-2 : ℝ) ≤ -(1 / ((t : ℝ) + 1)) := by
        have : (0 : ℝ) < 1 / ((t : ℝ) + 1) := by positivity
        have h1 : 1 / ((t : ℝ) + 1) ≤ 1 := by
          rw [div_le_one hden]; linarith
        linarith
      have hpow := one_add_mul_le_pow hx (2 * K + 1)
      have hrew : (1 : ℝ) + -(1 / ((t : ℝ) + 1)) = r := by
        rw [hrdef]; field_simp; ring
      rw [hrew] at hpow
      calc (1 : ℝ) - (2 * K + 1 : ℕ) / ((t : ℝ) + 1)
          = 1 + ((2 * K + 1 : ℕ) : ℝ) * -(1 / ((t : ℝ) + 1)) := by push_cast; ring
        _ ≤ r ^ (2 * K + 1) := hpow
    have hKt : (10 : ℝ) * (2 * (K : ℝ) + 1) ≤ (t : ℝ) := by
      have hnat : (10 * (2 * K + 1) : ℕ) ≤ t := by simp only [ht, hm]; nlinarith [Nat.zero_le K]
      have := (Nat.cast_le (α := ℝ)).mpr hnat
      push_cast at this
      linarith
    have hbig : ((2 * K + 1 : ℕ) : ℝ) / ((t : ℝ) + 1) ≤ 1 / 10 := by
      rw [div_le_iff₀ hden]
      push_cast
      linarith
    have hpow910 : (9 : ℝ) / 10 ≤ r ^ (2 * K + 1) := by linarith
    -- the flat estimate now beats the gate
    rw [hratio]
    refine lt_kstar_geomProfile_of_flat hr0 hr1 (by omega) (by norm_num) ?_
    have hn1 : (2 * K + 2) - 1 = 2 * K + 1 := by omega
    rw [hn1]
    have hnR : ((2 * K + 2 : ℕ) : ℝ) = 2 * (K : ℝ) + 2 := by push_cast; ring
    rw [hnR]
    have hdpos : (0 : ℝ) < (2 * (K : ℝ) + 2) * r ^ (2 * K + 1) := by
      have : (0 : ℝ) < r ^ (2 * K + 1) := by positivity
      have hK0 : (0 : ℝ) ≤ (K : ℝ) := Nat.cast_nonneg K
      positivity
    rw [div_lt_iff₀ hdpos]
    have hK0 : (0 : ℝ) ≤ (K : ℝ) := Nat.cast_nonneg K
    nlinarith

/-! ## P4 — the forced inversion -/

/-- **Unit-circle inversion.**  If one triple has the smaller short-leg ratio, it has the
larger long-leg ratio.  There is no way to be uniformly steeper. -/
theorem pyth_complementary_ratio_inversion {a₁ b₁ c₁ a₂ b₂ c₂ : ℤ}
    (h₁ : IsPythTriple a₁ b₁ c₁) (h₂ : IsPythTriple a₂ b₂ c₂)
    (ha₁ : 0 < a₁) (hb₁ : 0 < b₁) (hc₁ : 0 < c₁)
    (hb₂ : 0 < b₂) (hc₂ : 0 < c₂)
    (hlt : legRatio a₁ c₁ < legRatio a₂ c₂) :
    legRatio b₂ c₂ < legRatio b₁ c₁ := by
  have hs₁ := legRatio_sq_add h₁ hc₁
  have hs₂ := legRatio_sq_add h₂ hc₂
  have hA₁ : 0 < legRatio a₁ c₁ := legRatio_pos ha₁ hc₁
  have hB₁ : 0 < legRatio b₁ c₁ := legRatio_pos hb₁ hc₁
  have hB₂ : 0 < legRatio b₂ c₂ := legRatio_pos hb₂ hc₂
  nlinarith

/-- **Forced budget inversion.**  Two Pythagorean triples can never be compared
uniformly: whichever needs fewer keys on its short leg needs at least as many on its
long leg, at every context length and every gate. -/
theorem pyth_knee_inversion {a₁ b₁ c₁ a₂ b₂ c₂ : ℤ}
    (h₁ : IsPythTriple a₁ b₁ c₁) (h₂ : IsPythTriple a₂ b₂ c₂)
    (ha₁ : 0 < a₁) (hb₁ : 0 < b₁) (hc₁ : 0 < c₁)
    (hb₂ : 0 < b₂) (hc₂ : 0 < c₂)
    (hlt : legRatio a₁ c₁ < legRatio a₂ c₂) {n : ℕ} (hn : 0 < n) {τ : ℝ} (hτ : τ ≤ 1) :
    kstar (geomProfile (legRatio a₁ c₁)) n τ ≤ kstar (geomProfile (legRatio a₂ c₂)) n τ ∧
      kstar (geomProfile (legRatio b₂ c₂)) n τ ≤ kstar (geomProfile (legRatio b₁ c₁)) n τ := by
  have hinv := pyth_complementary_ratio_inversion h₁ h₂ ha₁ hb₁ hc₁ hb₂ hc₂ hlt
  exact ⟨kstar_geomProfile_mono_ratio (legRatio_pos ha₁ hc₁) hlt.le hn hτ,
    kstar_geomProfile_mono_ratio (legRatio_pos hb₂ hc₂) hinv.le hn hτ⟩

/-! ## Explicit inversion: `(3,4,5)` against `(20,21,29)` at gate `0.985` -/

lemma legRatio_three_five : legRatio 3 5 = (3 / 5 : ℝ) := by norm_num [legRatio]
lemma legRatio_four_five : legRatio 4 5 = (4 / 5 : ℝ) := by norm_num [legRatio]
lemma legRatio_twenty : legRatio 20 29 = (20 / 29 : ℝ) := by norm_num [legRatio]
lemma legRatio_twentyone : legRatio 21 29 = (21 / 29 : ℝ) := by norm_num [legRatio]

set_option maxRecDepth 40000 in
theorem knee_three_five : kstar (geomProfile (legRatio 3 5)) 64 (985 / 1000) = 9 := by
  rw [legRatio_three_five]
  refine kstar_geomProfile_eq_of_bracket (by norm_num) (by norm_num) (by norm_num)
    (by norm_num) (by norm_num) (by norm_num) ?_ ?_
  · rw [le_div_iff₀ (by norm_num)]; norm_num
  · norm_num

set_option maxRecDepth 40000 in
theorem knee_four_five : kstar (geomProfile (legRatio 4 5)) 64 (985 / 1000) = 19 := by
  rw [legRatio_four_five]
  refine kstar_geomProfile_eq_of_bracket (by norm_num) (by norm_num) (by norm_num)
    (by norm_num) (by norm_num) (by norm_num) ?_ ?_
  · rw [le_div_iff₀ (by norm_num)]; norm_num
  · norm_num

set_option maxRecDepth 40000 in
theorem knee_twenty_twentynine : kstar (geomProfile (legRatio 20 29)) 64 (985 / 1000) = 12 := by
  rw [legRatio_twenty]
  refine kstar_geomProfile_eq_of_bracket (by norm_num) (by norm_num) (by norm_num)
    (by norm_num) (by norm_num) (by norm_num) ?_ ?_
  · rw [le_div_iff₀ (by norm_num)]; norm_num
  · norm_num

set_option maxRecDepth 40000 in
theorem knee_twentyone_twentynine :
    kstar (geomProfile (legRatio 21 29)) 64 (985 / 1000) = 14 := by
  rw [legRatio_twentyone]
  refine kstar_geomProfile_eq_of_bracket (by norm_num) (by norm_num) (by norm_num)
    (by norm_num) (by norm_num) (by norm_num) ?_ ?_
  · rw [le_div_iff₀ (by norm_num)]; norm_num
  · norm_num

/-- **The explicit inversion.**  At context `64` and gate `0.985` the triple `(3,4,5)`
beats `(20,21,29)` on its short leg (`9 < 12`) and loses to it on its long leg
(`19 > 14`).  This is the arithmetic shadow of the NET-79 finding that the ordering of
two models' key budgets reverses across the grid. -/
theorem net79_explicit_inversion :
    kstar (geomProfile (legRatio 3 5)) 64 (985 / 1000)
        < kstar (geomProfile (legRatio 20 29)) 64 (985 / 1000) ∧
      kstar (geomProfile (legRatio 21 29)) 64 (985 / 1000)
        < kstar (geomProfile (legRatio 4 5)) 64 (985 / 1000) := by
  rw [knee_three_five, knee_twenty_twentynine, knee_twentyone_twentynine, knee_four_five]
  exact ⟨by norm_num, by norm_num⟩

end PythKnee