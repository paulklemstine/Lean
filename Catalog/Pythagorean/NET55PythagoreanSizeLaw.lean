import Mathlib
import Shared.AttentionBudgetKnee
import Shared.CatalogbuildSharedIspythtriple.IsPythTriple
import Pythagorean.NET79GeometricRatioKnee
import Pythagorean.NET79PythagoreanInversion
import Pythagorean.NET55SizeInvariantKnee

/-!
# NET-55, Pythagorean form: the knee is a similarity invariant

The NET-55 verdict — *tripling the parameters did not raise the lossless attention
budget by one key* — has an exact arithmetic shadow in the Pythagorean family used
throughout this catalog to generate decay ratios.  A Pythagorean triple `(a, b, c)`
supplies the geometric attention profile with ratio `legRatio a c = a / c`, and the size
of the triple is its scaling parameter `m` in `(ma, mb, mc)`.

* **Exact size invariance** (`pyth_knee_similarity_invariant`).  Scaling a triple does
  not change its knee *at all*, at any context length and any gate: the knee is a
  function of the similarity class, i.e. of the *shape* of the triangle, never of its
  size.  Applied to the near-isosceles Pell triple this produces an infinite family of
  arbitrarily large triples with the identical knee `12`
  (`pell_family_knee_size_invariant`).
* **A universal 12-key budget at the NET-55 gate** (`pyth_short_leg_budget_le_twelve_98`).
  Every Pythagorean triple with `0 < a ≤ b`, of any size, clears the `0.98` gate with
  `12` keys at every context length.  The bound is sharp: the Pell triple attains it
  (`pell_short_leg_knee_eq_twelve_98`, `pyth_budget_twelve_sharp_98`).
* **Shape, not size, sets the budget** (`net55_shape_not_size`).  The single triple
  `(3,4,5)` yields knees `8` (short leg) and `18` (long leg) at the same gate and the
  same context, a gap of ten keys, while *all* rescalings of either leg reproduce the
  same two numbers.  Size is exactly the direction in which the budget does not move.
* **The invariance is not vacuous** (`pyth_long_leg_budget_unbounded_of_gate`,
  `pyth_budget_dichotomy_98`).  Within the same arithmetic family the long-leg budgets
  are unbounded, at every gate above `5/9`.  So a bounded budget is a real property of
  the short-leg regime, not an artefact of the parametrisation — and a two-point size
  sweep cannot distinguish "flat in size" from "flat in everything".

-- !-- Lab Notes -- !--
Hypothesizer (Pythagorean cycle):
 (Q1) The knee is a similarity invariant of Pythagorean triples: exact size
      invariance, with no error term.                                        [BOLD]
 (Q2) At the NET-55 gate `0.98` there is a universal short-leg budget, and it is `12`.
 (Q3) The same triple realises widely different budgets on its two legs, so the
      budget is a shape functional.                                          [BOLD]
 (Q4) Long-leg budgets are unbounded at every gate above `5/9`, so Q2 is a genuine
      dichotomy rather than a normalisation.

Experimenter: Q1 = `pyth_knee_similarity_invariant` (via `legRatio_scale`);
Q2 = `pyth_short_leg_budget_le_twelve_98` with sharpness `pell_short_leg_knee_eq_twelve_98`
(exact rational arithmetic on `(696/985) ^ 12` and `(696/985) ^ 64`);
Q3 = `net55_shape_not_size` (knees `8` and `18` for `3/5` and `4/5`);
Q4 = `pyth_long_leg_budget_unbounded_of_gate`, a gate-uniform strengthening of the
NET-79 result, which was stated only at `0.985`.  All proved, zero sorries.

Analyst: the mechanism behind Q1 is homogeneity — `legRatio` is invariant under the
diagonal action `(a,c) ↦ (ma,mc)`, and the knee factors through it.  That is the same
mechanism as `kstar_const_smul` in `NET55SizeInvariantKnee.lean`, but acting on the
*index* of the model family rather than on the weights: two different group actions,
one invariance.  This is the structural reason a measured `{16,16}` chain is cheap to
obtain and expensive to interpret.

Critic: the `0.98` budget `12` is smaller than the NET-79 budget `13` at gate `0.985`,
as gate monotonicity demands (`kstar_mono_gate`), so the two rounds are consistent; the
sharpness witness is the same Pell triple in both, which is exactly the extremal shape
`a/c → 1/√2`.  No claim here derives a *measured* knee from arithmetic: the Pythagorean
family is a source of explicit profiles, not a model of a transformer.
-/

namespace PythKnee

open Finset AttentionBudget

/-! ## Q1 — the knee is a similarity invariant -/

/-- `legRatio` only sees the shape of a triple: it is invariant under scaling. -/
lemma legRatio_scale {a c m : ℤ} (hm : 0 < m) (hc : 0 < c) :
    legRatio (m * a) (m * c) = legRatio a c := by
  have hm' : ((m : ℝ)) ≠ 0 := by
    have : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm
    exact ne_of_gt this
  have hc' : ((c : ℝ)) ≠ 0 := by
    have : (0 : ℝ) < (c : ℝ) := by exact_mod_cast hc
    exact ne_of_gt this
  unfold legRatio
  push_cast
  field_simp

/-- **Q1 — exact size invariance.**  All triples in one similarity class have exactly
the same knee, at every context length and every gate.  Growing the triple by a factor
`m` — the arithmetic analogue of tripling the parameter count — moves the lossless key
budget by zero keys. -/
theorem pyth_knee_similarity_invariant {a c m : ℤ} (hm : 0 < m) (hc : 0 < c) (n : ℕ)
    (τ : ℝ) :
    kstar (geomProfile (legRatio (m * a) (m * c))) n τ
      = kstar (geomProfile (legRatio a c)) n τ := by
  rw [legRatio_scale hm hc]

/-! ## Q2 — the universal short-leg budget at the NET-55 gate -/

/-- **Q2 — universal `12`-key budget at gate `0.98`.**  For every Pythagorean triple
with `0 < a ≤ b`, of any size, twelve retained keys clear the `0.98` gate at every
context length.  Nothing but the Pythagorean relation is used. -/
theorem pyth_short_leg_budget_le_twelve_98 {a b c : ℤ} (h : IsPythTriple a b c) (ha : 0 < a)
    (hab : a ≤ b) (hc : 0 < c) {n : ℕ} (hn : 0 < n) :
    kstar (geomProfile (legRatio a c)) n (98 / 100) ≤ 12 := by
  set r := legRatio a c with hr
  have hpos : 0 < r := legRatio_pos ha hc
  have hle : r ≤ 708 / 1000 := short_legRatio_le h ha hab hc
  have hlt1 : r < 1 := by linarith
  refine kstar_geomProfile_le_of_pow_le hpos hlt1 hn ?_
  have h12 : r ^ 12 ≤ (708 / 1000 : ℝ) ^ 12 := pow_le_pow_left₀ hpos.le hle 12
  norm_num at h12 ⊢
  linarith

set_option maxRecDepth 40000 in
/-- The short-leg knee of the near-isosceles Pell triple `(696, 697, 985)` at the
`0.98` gate is exactly `12`, at every context length from `64` upwards. -/
theorem pell_short_leg_knee_eq_twelve_98 {n : ℕ} (hn : 64 ≤ n) :
    kstar (geomProfile (legRatio 696 985)) n (98 / 100) = 12 := by
  rw [legRatio_pell]
  refine kstar_geomProfile_eq_of_small_powers (by norm_num) (by norm_num)
    (m := 64) (by norm_num) hn (by norm_num) (by omega) (by norm_num) (by norm_num) ?_
  rw [div_lt_iff₀ (by norm_num)]
  norm_num

/-- **Sharpness of the universal budget.**  No budget below `12` serves all Pythagorean
triples at gate `0.98`: eleven keys already fail for the Pell triple. -/
theorem pyth_budget_twelve_sharp_98 :
    ∃ a b c : ℤ, ∃ n : ℕ, IsPythTriple a b c ∧ 0 < a ∧ a ≤ b ∧ 0 < c ∧
      11 < kstar (geomProfile (legRatio a c)) n (98 / 100) := by
  refine ⟨696, 697, 985, 64, pell_triple, by norm_num, by norm_num, by norm_num, ?_⟩
  rw [pell_short_leg_knee_eq_twelve_98 le_rfl]
  norm_num

/-- **The size-invariant family.**  Every member of the infinite family of triples
`(696 m, 697 m, 985 m)`, `m ≥ 1` — arbitrarily large triples — has short-leg knee
exactly `12` at gate `0.98` and every context from `64` upwards.  This is exact
size invariance with a sharp, attained value. -/
theorem pell_family_knee_size_invariant {m : ℤ} (hm : 0 < m) {n : ℕ} (hn : 64 ≤ n) :
    IsPythTriple (m * 696) (m * 697) (m * 985) ∧
      kstar (geomProfile (legRatio (m * 696) (m * 985))) n (98 / 100) = 12 := by
  refine ⟨?_, ?_⟩
  · have := pell_triple
    unfold IsPythTriple at this ⊢
    nlinarith [this]
  · rw [pyth_knee_similarity_invariant hm (by norm_num)]
    exact pell_short_leg_knee_eq_twelve_98 hn

/-! ## Q3 — shape, not size -/

/-- **Q3 — the budget is a shape functional.**  The single triple `(3,4,5)` produces two
profiles whose knees at the same gate and context differ by ten keys (`8` against `18`),
while every rescaling `(3m, 4m, 5m)` reproduces exactly the same pair.  Size is the
direction in which the budget provably does not move; shape is the direction in which it
moves a lot. -/
theorem net55_shape_not_size {m : ℤ} (hm : 0 < m) {n : ℕ} (hn : 64 ≤ n) :
    kstar (geomProfile (legRatio (m * 3) (m * 5))) n (98 / 100) = 8 ∧
      kstar (geomProfile (legRatio (m * 4) (m * 5))) n (98 / 100) = 18 := by
  constructor
  · rw [pyth_knee_similarity_invariant hm (by norm_num), legRatio_three_five]
    exact knee_three_fifths_98 hn
  · rw [pyth_knee_similarity_invariant hm (by norm_num), legRatio_four_five]
    exact knee_four_fifths_98 hn

/-! ## Q4 — the invariance is not vacuous: long-leg budgets are unbounded -/

/-- **Q4 — gate-uniform long-leg divergence.**  For every gate `τ` with `5/9 < τ ≤ 1`
and every bound `K` there is a Pythagorean triple and a context length whose long-leg
profile needs more than `K` keys.  (The NET-79 round proved this at the single gate
`0.985`; the budget of the NET-55 round, `0.98`, is covered as well.) -/
theorem pyth_long_leg_budget_unbounded_of_gate {τ : ℝ} (hτlo : 5 / 9 < τ) (hτ : τ ≤ 1)
    (K : ℕ) :
    ∃ a b c : ℤ, ∃ n : ℕ, IsPythTriple a b c ∧ 0 < a ∧ a ≤ b ∧ 0 < c ∧ 0 < n ∧
      K < kstar (geomProfile (legRatio b c)) n τ := by
  set m : ℕ := 10 * K + 10 with hm
  set t : ℕ := 2 * m * m + 2 * m with ht
  refine ⟨((2 * m + 1 : ℕ) : ℤ), (t : ℤ), ((t + 1 : ℕ) : ℤ), 2 * K + 2,
    near_square_triple m, by positivity, ?_, by positivity, by omega, ?_⟩
  · have : 2 * m + 1 ≤ t := by simp only [ht, hm]; nlinarith [Nat.zero_le K]
    exact_mod_cast this
  · have htpos : 0 < t := by simp only [ht, hm]; nlinarith [Nat.zero_le K]
    have htR : (1 : ℝ) ≤ (t : ℝ) := by exact_mod_cast htpos
    have hden : (0 : ℝ) < (t : ℝ) + 1 := by linarith
    have hratio : legRatio (t : ℤ) ((t + 1 : ℕ) : ℤ) = (t : ℝ) / ((t : ℝ) + 1) := by
      unfold legRatio; push_cast; ring
    set r : ℝ := (t : ℝ) / ((t : ℝ) + 1) with hrdef
    have hr0 : 0 < r := by positivity
    have hr1 : r ≤ 1 := by rw [hrdef, div_le_one hden]; linarith
    have hbern : (1 : ℝ) - (2 * K + 1 : ℕ) / ((t : ℝ) + 1) ≤ r ^ (2 * K + 1) := by
      have hx : (-2 : ℝ) ≤ -(1 / ((t : ℝ) + 1)) := by
        have h0 : (0 : ℝ) < 1 / ((t : ℝ) + 1) := by positivity
        have h1 : 1 / ((t : ℝ) + 1) ≤ 1 := by rw [div_le_one hden]; linarith
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
    rw [hratio]
    refine lt_kstar_geomProfile_of_flat hr0 hr1 (by omega) hτ ?_
    have hn1 : (2 * K + 2) - 1 = 2 * K + 1 := by omega
    rw [hn1]
    have hnR : ((2 * K + 2 : ℕ) : ℝ) = 2 * (K : ℝ) + 2 := by push_cast; ring
    rw [hnR]
    have hK0 : (0 : ℝ) ≤ (K : ℝ) := Nat.cast_nonneg K
    have hdpos : (0 : ℝ) < (2 * (K : ℝ) + 2) * r ^ (2 * K + 1) := by
      have : (0 : ℝ) < r ^ (2 * K + 1) := by positivity
      positivity
    rw [div_lt_iff₀ hdpos]
    nlinarith [hpow910, hτlo, hK0]

/-- **The Pythagorean budget dichotomy at the NET-55 gate.**  Short legs of Pythagorean
triples carry a universal `12`-key budget, valid at every size and every context, while
long legs carry no universal budget at all.  Bounded budgets are therefore a property of
one regime of shapes, and the size direction is flat inside each regime. -/
theorem pyth_budget_dichotomy_98 :
    (∀ a b c : ℤ, IsPythTriple a b c → 0 < a → a ≤ b → 0 < c → ∀ n : ℕ, 0 < n →
        kstar (geomProfile (legRatio a c)) n (98 / 100) ≤ 12) ∧
      (∀ K : ℕ, ∃ a b c : ℤ, ∃ n : ℕ, IsPythTriple a b c ∧ 0 < a ∧ a ≤ b ∧ 0 < c ∧ 0 < n ∧
        K < kstar (geomProfile (legRatio b c)) n (98 / 100)) :=
  ⟨fun _ _ _ h ha hab hc _ hn => pyth_short_leg_budget_le_twelve_98 h ha hab hc hn,
   fun K => pyth_long_leg_budget_unbounded_of_gate (by norm_num) (by norm_num) K⟩

end PythKnee