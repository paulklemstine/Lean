/-
# Gödel's Casino: randomized strategies and the minimax value

This file continues the "Gödel's Casino" thread. Earlier developments
(`Catalog/NumberTheory/GodelCasino.lean` and
`Catalog/output-final_aristotle/Logic/GodelCasino.lean`) studied *deterministic*
Boolean bets: they proved a deterministic no-free-lunch theorem (complementing a
world negates the payoff) and a sharp *conditional* expected-profit criterion
(positive expectation requires aggregate accuracy `> 1/2`).

Here we take the next step listed under "Further formalization": we formalize
**randomized strategies** on a finite space of possible worlds and prove a
minimax / no-free-lunch theorem against **complement-symmetric priors**, together
with the sharp information-theoretic profitability threshold.

## The model

Fix a finite world space `W`. A statement is `s : W → Bool`. A *randomized
strategy* is a single number `r ∈ [0,1]`: the probability the player bets `true`.
Against the truth value in a world, the expected payoff (over the player's own
coin) is `randPayoff s r ω`, and against a prior `μ : W → ℚ` over worlds it is
`expRand μ s r = ∑ ω, μ ω * randPayoff s r ω`.

## Main results

* `randPayoff_eq` : per-world expected payoff is `2r-1` if true, `1-2r` if false.
* `randPayoff_half` : the **fair coin** `r = 1/2` pays exactly `0` in *every*
  world — a strategy that cannot lose (nor win).
* `expRand_eq` : the exact closed form
  `expRand μ s r = (2r-1) · (trueMass μ s − falseMass μ s)`; the expected profit
  is *bilinear* in the strategy and the prior's truth–falsehood imbalance.
* `expRand_normalized` : for a probability prior, `= (2r-1)·(2·π − 1)` where
  `π = trueMass` is the probability the statement is true.
* `symmetric_prior_zero` : **randomized no-free-lunch.** If the prior admits a
  truth-flipping, mass-preserving involution, then *every* strategy nets exactly
  `0`. Incompleteness modelled as a symmetric prior gives no edge, even with
  randomization.
* `no_benefit_randomization` / `optimal_pure_value` : deterministic (pure) bets
  are optimal, and the optimal value is `|trueMass − falseMass|`. Randomization
  never helps a player who knows the prior.
* `edge_iff_asymmetric` : **edge iff information.** A positive-expectation
  strategy exists *iff* the prior is asymmetric between truth and falsehood. The
  entire edge is the prior's imbalance — decidability/independence per se
  supplies none.
* `deckValue_nonneg`, `deckValue_card_le` : over a deck, the optimal total value
  is the sum of per-card imbalances; it is nonnegative and dominated card by
  card.

The development is elementary and fully self-contained (finite sums over `ℚ`).
-/
import Mathlib

namespace GodelCasinoRandomized

open Finset

variable {W : Type*} [Fintype W]

/-- Per-world payoff of the pure bet `b` on statement `s`: `+1` if it matches the
truth value in world `ω`, `-1` otherwise. -/
def payoff (s : W → Bool) (b : Bool) (ω : W) : ℚ := if b = s ω then 1 else -1

/-- Expected payoff (over the player's own randomization) of the strategy that
bets `true` with probability `r` on statement `s`, in world `ω`. -/
def randPayoff (s : W → Bool) (r : ℚ) (ω : W) : ℚ :=
  r * payoff s true ω + (1 - r) * payoff s false ω

omit [Fintype W] in
/-- The per-world expected payoff is `2r-1` when the statement is true there and
`1-2r` when it is false. -/
lemma randPayoff_eq (s : W → Bool) (r : ℚ) (ω : W) :
    randPayoff s r ω = if s ω then (2 * r - 1) else (1 - 2 * r) := by
  unfold randPayoff payoff; cases s ω <;> simp <;> ring

omit [Fintype W] in
/-- **The fair coin never loses (nor wins).** Betting `true` with probability
`1/2` pays exactly `0` in every world, whatever the statement's truth value. -/
lemma randPayoff_half (s : W → Bool) (ω : W) : randPayoff s (1 / 2) ω = 0 := by
  rw [randPayoff_eq]; cases s ω <;> norm_num

/-- Expected profit of strategy `r` on statement `s` under prior `μ` over worlds. -/
def expRand (μ : W → ℚ) (s : W → Bool) (r : ℚ) : ℚ := ∑ ω, μ ω * randPayoff s r ω

/-- Prior mass on the worlds where `s` is true. -/
def trueMass (μ : W → ℚ) (s : W → Bool) : ℚ := ∑ ω, if s ω then μ ω else 0

/-- Prior mass on the worlds where `s` is false. -/
def falseMass (μ : W → ℚ) (s : W → Bool) : ℚ := ∑ ω, if s ω then 0 else μ ω

/-- The true- and false-masses partition the total prior mass. -/
lemma mass_split (μ : W → ℚ) (s : W → Bool) :
    trueMass μ s + falseMass μ s = ∑ ω, μ ω := by
  unfold trueMass falseMass
  rw [← Finset.sum_add_distrib]
  apply Finset.sum_congr rfl
  intro ω _; cases s ω <;> simp

/-- **The exact closed form.** Expected profit is bilinear: the product of the
strategy skew `2r-1` and the prior's truth–falsehood imbalance. -/
theorem expRand_eq (μ : W → ℚ) (s : W → Bool) (r : ℚ) :
    expRand μ s r = (2 * r - 1) * (trueMass μ s - falseMass μ s) := by
  unfold expRand trueMass falseMass
  rw [← Finset.sum_sub_distrib, Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro ω _
  rw [randPayoff_eq]; cases s ω <;> simp <;> ring

/-- The fair coin has expected profit `0` against *every* prior. -/
theorem expRand_half (μ : W → ℚ) (s : W → Bool) : expRand μ s (1 / 2) = 0 := by
  rw [expRand_eq]; ring

/-- Value of the always-`false` pure bet. -/
theorem expRand_zero (μ : W → ℚ) (s : W → Bool) :
    expRand μ s 0 = -(trueMass μ s - falseMass μ s) := by rw [expRand_eq]; ring

/-- Value of the always-`true` pure bet. -/
theorem expRand_one (μ : W → ℚ) (s : W → Bool) :
    expRand μ s 1 = trueMass μ s - falseMass μ s := by rw [expRand_eq]; ring

/-- For a probability prior (`∑ μ = 1`) the value uses the probability
`π = trueMass μ s` that the statement is true: `(2r-1)·(2π-1)`. -/
theorem expRand_normalized (μ : W → ℚ) (s : W → Bool) (r : ℚ)
    (hμ : ∑ ω, μ ω = 1) :
    expRand μ s r = (2 * r - 1) * (2 * trueMass μ s - 1) := by
  rw [expRand_eq]
  have hf : falseMass μ s = 1 - trueMass μ s := by
    have := mass_split μ s; rw [← hμ, ← this]; ring
  rw [hf]; ring

/-- A complement-symmetric prior has equal true- and false-mass: pair each world
with its truth-flipped, mass-preserving partner. -/
lemma symmetric_trueMass_eq (μ : W → ℚ) (s : W → Bool) (σ : W → W)
    (hσ : Function.Involutive σ) (hμ : ∀ ω, μ (σ ω) = μ ω)
    (hs : ∀ ω, s (σ ω) = ! s ω) :
    trueMass μ s = falseMass μ s := by
  unfold trueMass falseMass
  rw [← Equiv.sum_comp (hσ.toPerm) (fun ω => if s ω then (0 : ℚ) else μ ω)]
  apply Finset.sum_congr rfl
  intro ω _
  simp only [Function.Involutive.coe_toPerm]
  rw [hs ω, hμ ω]; cases s ω <;> simp

/-- **No free lunch (randomized).** If the prior admits a truth-flipping,
mass-preserving involution on worlds (a *complement-symmetric* prior), then
*every* randomized strategy has expected profit exactly `0`. This is the
randomized minimax: an adversary who keeps the prior symmetric drives the value
to zero no matter how the player randomizes. -/
theorem symmetric_prior_zero (μ : W → ℚ) (s : W → Bool) (σ : W → W)
    (hσ : Function.Involutive σ) (hμ : ∀ ω, μ (σ ω) = μ ω)
    (hs : ∀ ω, s (σ ω) = ! s ω) (r : ℚ) :
    expRand μ s r = 0 := by
  rw [expRand_eq, symmetric_trueMass_eq μ s σ hσ hμ hs]; ring

/-- **Pure strategies are optimal.** For any `r ∈ [0,1]` the randomized value is
at most the better of the two deterministic bets: randomizing never helps. -/
theorem no_benefit_randomization (μ : W → ℚ) (s : W → Bool) (r : ℚ)
    (hr0 : 0 ≤ r) (hr1 : r ≤ 1) :
    expRand μ s r ≤ max (expRand μ s 0) (expRand μ s 1) := by
  rw [expRand_zero, expRand_one, expRand_eq]
  set D := trueMass μ s - falseMass μ s with hD
  rcases le_total 0 D with h | h
  · apply le_trans _ (le_max_right _ _); nlinarith
  · apply le_trans _ (le_max_left _ _); nlinarith

/-- The optimal value over the two pure strategies is the absolute imbalance
`|trueMass − falseMass|`. -/
theorem optimal_pure_value (μ : W → ℚ) (s : W → Bool) :
    max (expRand μ s 0) (expRand μ s 1) = |trueMass μ s - falseMass μ s| := by
  rw [expRand_zero, expRand_one]
  rcases le_total 0 (trueMass μ s - falseMass μ s) with h | h
  · rw [abs_of_nonneg h, max_eq_right (by linarith)]
  · rw [abs_of_nonpos h, max_eq_left (by linarith)]

/-- Combining the two previous results: every admissible strategy is bounded by
the absolute imbalance, and this optimum is attained by a pure bet. -/
theorem expRand_le_optimal (μ : W → ℚ) (s : W → Bool) (r : ℚ)
    (hr0 : 0 ≤ r) (hr1 : r ≤ 1) :
    expRand μ s r ≤ |trueMass μ s - falseMass μ s| := by
  rw [← optimal_pure_value]; exact no_benefit_randomization μ s r hr0 hr1

/-- **Edge iff information.** A strategy with strictly positive expected profit
exists *if and only if* the prior is asymmetric between truth and falsehood.
Symmetric priors (the betting model of pure incompleteness) admit no edge; the
entire edge is the prior's imbalance. -/
theorem edge_iff_asymmetric (μ : W → ℚ) (s : W → Bool) :
    (∃ r, 0 ≤ r ∧ r ≤ 1 ∧ 0 < expRand μ s r) ↔ trueMass μ s ≠ falseMass μ s := by
  constructor
  · rintro ⟨r, _, _, hpos⟩ heq
    rw [expRand_eq, sub_eq_zero.mpr heq] at hpos; simp at hpos
  · intro hne
    rcases lt_or_gt_of_ne (sub_ne_zero.mpr hne) with h | h
    · exact ⟨0, le_refl _, by norm_num, by rw [expRand_zero]; linarith⟩
    · exact ⟨1, by norm_num, le_refl _, by rw [expRand_one]; linarith⟩

/-! ## Aggregate over a deck of statements

Playing one optimally-chosen pure bet per card of a deck (over a shared world
prior), the guaranteed total value is the sum of the per-card imbalances. -/

/-- Optimal total value of a deck: the sum of per-card absolute imbalances. -/
def deckValue (μ : W → ℚ) (deck : List (W → Bool)) : ℚ :=
  (deck.map (fun s => |trueMass μ s - falseMass μ s|)).sum

/-- The optimal deck value is nonnegative. -/
theorem deckValue_nonneg (μ : W → ℚ) (deck : List (W → Bool)) :
    0 ≤ deckValue μ deck := by
  unfold deckValue
  apply List.sum_nonneg
  intro x hx
  simp only [List.mem_map] at hx
  obtain ⟨s, _, rfl⟩ := hx
  exact abs_nonneg _

/-- Each card's optimal value is at most the whole deck's optimal value: no card
detracts from the total edge. -/
theorem deckValue_card_le (μ : W → ℚ) (deck : List (W → Bool))
    {s : W → Bool} (hs : s ∈ deck) :
    |trueMass μ s - falseMass μ s| ≤ deckValue μ deck := by
  unfold deckValue
  apply List.single_le_sum
  · intro x hx
    simp only [List.mem_map] at hx
    obtain ⟨t, _, rfl⟩ := hx
    exact abs_nonneg _
  · exact List.mem_map_of_mem hs

/-! ## Worked example: the two-world casino

On `W = Bool` with the uniform prior and the statement `s = id`, the world-flip
involution `not` is truth-flipping and mass-preserving, so *every* strategy nets
`0` — recovering, for randomized play, the contrarian verdict of the earlier
possible-world file. -/

/-- On the balanced two-world casino, even a biased coin (here `r = 3/7`) nets
exactly `0`. -/
example : expRand (fun _ : Bool => (1 / 2 : ℚ)) id (3 / 7) = 0 := by
  apply symmetric_prior_zero _ _ (fun b => !b)
    (by intro b; cases b <;> rfl) (by intro _; rfl) (by intro _; rfl)

/-- The balanced two-world casino admits no positive-expectation strategy at
all. -/
theorem two_world_no_edge :
    ¬ ∃ r, 0 ≤ r ∧ r ≤ 1 ∧ 0 < expRand (fun _ : Bool => (1 / 2 : ℚ)) id r := by
  rw [edge_iff_asymmetric]
  push_neg
  exact symmetric_trueMass_eq _ _ (fun b => !b)
    (by intro b; cases b <;> rfl) (by intro _; rfl) (by intro _; rfl)

end GodelCasinoRandomized