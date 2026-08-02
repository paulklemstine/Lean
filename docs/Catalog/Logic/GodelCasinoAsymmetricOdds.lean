/-
# Gödel's Casino: asymmetric odds, transaction costs, and abstention

This file advances the randomized casino model from symmetric ±1 payoffs to
asymmetric odds.  A correct bet earns `a`, while an incorrect bet loses `b`.
The resulting break-even probability is `b / (a+b)` for betting true and
`a / (a+b)` for betting false.  We also add a zero-payoff abstention option.
-/
import Mathlib

namespace GodelCasinoAsymmetricOdds

open Finset

variable {W : Type*} [Fintype W]

/-- Payoff of a pure Boolean bet: gain `a` when correct and lose `b` otherwise. -/
def oddsPayoff (s : W → Bool) (a b : ℚ) (bet : Bool) (ω : W) : ℚ :=
  if bet = s ω then a else -b

/-- Expected per-world payoff when `true` is bet with probability `r`. -/
def randOddsPayoff (s : W → Bool) (a b r : ℚ) (ω : W) : ℚ :=
  r * oddsPayoff s a b true ω + (1 - r) * oddsPayoff s a b false ω

omit [Fintype W] in
/-- Closed form of the per-world randomized payoff. -/
lemma randOddsPayoff_eq (s : W → Bool) (a b r : ℚ) (ω : W) :
    randOddsPayoff s a b r ω =
      if s ω then (a + b) * r - b else a - (a + b) * r := by
  split_ifs with hs
  · unfold randOddsPayoff oddsPayoff; simp [hs]; ring
  · unfold randOddsPayoff oddsPayoff; simp [hs]; ring

/-- Prior mass of worlds where the statement is true. -/
def trueMass (μ : W → ℚ) (s : W → Bool) : ℚ :=
  ∑ ω, if s ω then μ ω else 0

/-- Prior mass of worlds where the statement is false. -/
def falseMass (μ : W → ℚ) (s : W → Bool) : ℚ :=
  ∑ ω, if s ω then 0 else μ ω

/-- The true and false masses partition total prior mass. -/
lemma mass_split (μ : W → ℚ) (s : W → Bool) :
    trueMass μ s + falseMass μ s = ∑ ω, μ ω := by
  simp only [trueMass, falseMass]
  rw [← Finset.sum_add_distrib]
  apply Finset.sum_congr rfl
  intro ω _
  cases s ω <;> simp

/-- Expected asymmetric-odds profit under a finite rational prior. -/
def expOdds (μ : W → ℚ) (s : W → Bool) (a b r : ℚ) : ℚ :=
  ∑ ω, μ ω * randOddsPayoff s a b r ω

/-- Exact closed form in terms of true and false prior mass. -/
theorem expOdds_eq (μ : W → ℚ) (s : W → Bool) (a b r : ℚ) :
    expOdds μ s a b r =
      ((a + b) * r - b) * trueMass μ s +
      (a - (a + b) * r) * falseMass μ s := by
  simp only [expOdds, randOddsPayoff_eq, trueMass, falseMass]
  have h : ∀ ω, μ ω * (if s ω then (a + b) * r - b else a - (a + b) * r) =
           (if s ω then ((a + b) * r - b) * μ ω else (a - (a + b) * r) * μ ω) := fun ω => by
    split_ifs with hs <;> ring
  simp_rw [h]
  rw [Finset.sum_ite, Finset.sum_ite]
  congr 1
  · rw [← Finset.mul_sum]
    simp
  · rw [← Finset.mul_sum]
    apply congr_arg _
    rw [Finset.sum_ite]
    simp

/-- The always-false pure strategy's value. -/
theorem expOdds_zero (μ : W → ℚ) (s : W → Bool) (a b : ℚ) :
    expOdds μ s a b 0 = a * falseMass μ s - b * trueMass μ s := by
  rw [expOdds_eq]
  ring

/-- The always-true pure strategy's value. -/
theorem expOdds_one (μ : W → ℚ) (s : W → Bool) (a b : ℚ) :
    expOdds μ s a b 1 = a * trueMass μ s - b * falseMass μ s := by
  rw [expOdds_eq]
  ring

/-- Every randomized value is the convex affine combination of pure values. -/
theorem expOdds_affine (μ : W → ℚ) (s : W → Bool) (a b r : ℚ) :
    expOdds μ s a b r =
      r * expOdds μ s a b 1 + (1 - r) * expOdds μ s a b 0 := by
  rw [expOdds_eq, expOdds_eq, expOdds_eq]
  ring

/-- Randomization cannot beat the better pure strategy. -/
theorem no_benefit_randomization (μ : W → ℚ) (s : W → Bool) (a b r : ℚ)
    (hr0 : 0 ≤ r) (hr1 : r ≤ 1) :
    expOdds μ s a b r ≤ max (expOdds μ s a b 0) (expOdds μ s a b 1) := by
  rw [expOdds_affine]
  calc r * expOdds μ s a b 1 + (1 - r) * expOdds μ s a b 0
      ≤ r * max (expOdds μ s a b 0) (expOdds μ s a b 1) + (1 - r) * max (expOdds μ s a b 0) (expOdds μ s a b 1) := by
        nlinarith [le_max_left (expOdds μ s a b 0) (expOdds μ s a b 1),
                   le_max_right (expOdds μ s a b 0) (expOdds μ s a b 1)]
    _ = max (expOdds μ s a b 0) (expOdds μ s a b 1) := by ring

/-- A positive randomized edge exists exactly when one pure bet has an edge. -/
theorem edge_iff_pure_edge (μ : W → ℚ) (s : W → Bool) (a b : ℚ) :
    (∃ r, 0 ≤ r ∧ r ≤ 1 ∧ 0 < expOdds μ s a b r) ↔
      0 < expOdds μ s a b 0 ∨ 0 < expOdds μ s a b 1 := by
  constructor
  · intro ⟨r, hr0, hr1, hrpos⟩
    have := no_benefit_randomization μ s a b r hr0 hr1
    have hmax : 0 < max (expOdds μ s a b 0) (expOdds μ s a b 1) := lt_of_lt_of_le hrpos this
    rw [lt_max_iff] at hmax
    exact hmax
  · intro h
    rcases h with h0 | h1
    · exact ⟨0, le_refl 0, by norm_num, h0⟩
    · exact ⟨1, by norm_num, le_refl 1, h1⟩

/-- Under a normalized prior, the pure-false value is `a-(a+b)π`. -/
theorem expOdds_zero_normalized (μ : W → ℚ) (s : W → Bool) (a b : ℚ)
    (hμ : ∑ ω, μ ω = 1) :
    expOdds μ s a b 0 = a - (a + b) * trueMass μ s := by
  rw [expOdds_zero]
  have hfalse : falseMass μ s = 1 - trueMass μ s := by
    linarith [mass_split μ s ▸ hμ]
  rw [hfalse]
  ring

/-- Under a normalized prior, the pure-true value is `(a+b)π-b`. -/
theorem expOdds_one_normalized (μ : W → ℚ) (s : W → Bool) (a b : ℚ)
    (hμ : ∑ ω, μ ω = 1) :
    expOdds μ s a b 1 = (a + b) * trueMass μ s - b := by
  rw [expOdds_one]
  have hfalse : falseMass μ s = 1 - trueMass μ s := by
    linarith [mass_split μ s]
  rw [hfalse]
  ring

/-- Sharp profitability thresholds for asymmetric odds. -/
theorem edge_iff_outside_no_bet_interval (μ : W → ℚ) (s : W → Bool) (a b : ℚ)
    (hμ : ∑ ω, μ ω = 1) (hab : 0 < a + b) :
    (∃ r, 0 ≤ r ∧ r ≤ 1 ∧ 0 < expOdds μ s a b r) ↔
      trueMass μ s < a / (a + b) ∨ b / (a + b) < trueMass μ s := by
  rw [edge_iff_pure_edge]
  rw [expOdds_zero_normalized μ s a b hμ, expOdds_one_normalized μ s a b hμ]
  constructor
  · intro h
    rcases h with h0 | h1
    · left
      rw [lt_div_iff₀ hab]
      linarith
    · right
      rw [div_lt_iff₀ hab]
      linarith
  · intro h
    rcases h with h | h
    · left
      rw [lt_div_iff₀ hab] at h
      linarith
    · right
      rw [div_lt_iff₀ hab] at h
      linarith

/-- Optimal value when passing for zero payoff is allowed. -/
def abstentionValue (μ : W → ℚ) (s : W → Bool) (a b : ℚ) : ℚ :=
  max 0 (max (expOdds μ s a b 0) (expOdds μ s a b 1))

/-- Abstention guarantees that the optimal value is nonnegative. -/
theorem abstentionValue_nonneg (μ : W → ℚ) (s : W → Bool) (a b : ℚ) :
    0 ≤ abstentionValue μ s a b := by
  exact le_max_left _ _

/-- In the no-bet interval, abstention is optimal and the value is zero. -/
theorem abstentionValue_eq_zero (μ : W → ℚ) (s : W → Bool) (a b : ℚ)
    (hfalse : expOdds μ s a b 0 ≤ 0) (htrue : expOdds μ s a b 1 ≤ 0) :
    abstentionValue μ s a b = 0 := by
  simp [abstentionValue, max_eq_left (le_trans (max_le hfalse htrue) (le_refl 0))]

/-- Every admissible randomized bet is bounded by the value available with abstention. -/
theorem expOdds_le_abstentionValue (μ : W → ℚ) (s : W → Bool) (a b r : ℚ)
    (hr0 : 0 ≤ r) (hr1 : r ≤ 1) :
    expOdds μ s a b r ≤ abstentionValue μ s a b := by
  have h := no_benefit_randomization μ s a b r hr0 hr1
  simp only [abstentionValue]
  exact le_trans h (le_max_right _ _)

end GodelCasinoAsymmetricOdds