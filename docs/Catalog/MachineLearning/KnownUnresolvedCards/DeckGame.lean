/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license.

# Known versus unresolved cards — III. The deck game

We now assemble the pieces.  A deck consists of

* `d` **resolved** cards, each paying a deterministic unit;
* an **unresolved** block indexed by a nonempty finite type `α`, whose true
  arrangement is a uniformly random bijection `σ : α ≃ α` and on which the
  predictor plays an arbitrary strategy `g : α → α`.

The scoring of an unresolved slot is `w` on a hit and `l` on a miss.

## Main results

* `E_slotScore` — the **master formula** for a single unresolved slot:
  `E = (w - l)/|α| + l`, *independent of the slot and of the strategy*.
* `expected_deckScore` — for the whole unresolved block,
  `E = (w - l) + l * |α|`.
* `fair_odds_iff` — **rigidity of fair odds**: the unresolved block has zero
  expected value iff `w = l * (1 - |α|)`; for `l = -1` this is exactly the
  `(|α| - 1) : 1` payout.  So the "no edge" phenomenon is not an accident of a
  lucky normalisation: it *characterises* fair odds.
* `expected_gamePayoff_eq_known` — **the headline theorem**: with `d` resolved
  cards and a fair-odds unresolved block, the expected payoff is exactly `d`.
* `expected_unit_score_eq_known_add_one` — **the counting anomaly**: with naive
  unit scoring (`1` for a hit, `0` for a miss) the expected payoff is `d + 1`,
  for *every* strategy and *every* size of the unresolved block.  The apparent
  "edge" of uncertainty is one single card, and it is a scoring artefact.
* `Var_hits_collision` — the exact variance of an arbitrary strategy, equal to
  its normalised collision profile.
* `Var_hits_injective`, `Var_hits_const` — **second-moment dichotomy**: the mean score
  is strategy-invariant but the variance is not (`1` for an injective strategy,
  `0` for a constant one).  Uncertainty offers no edge in the mean, yet the
  strategy fully controls the risk.
-/

import MachineLearning.KnownUnresolvedCards.Basic
import MachineLearning.KnownUnresolvedCards.PermCount

namespace KnownUnresolvedCards

open Finset

variable {α : Type*} [Fintype α] [DecidableEq α]

/-! ## A single unresolved slot -/

/-- Score of one unresolved slot: `w` if the predicted card is right, `l` if not. -/
def slotScore (w l : ℚ) (i a : α) (σ : Equiv.Perm α) : ℚ := if σ i = a then w else l

lemma sum_slotScore (w l : ℚ) (i a : α) :
    ∑ σ : Equiv.Perm α, slotScore w l i a σ
      = (w - l) * ((fiber i a).card : ℚ) + l * (Fintype.card (Equiv.Perm α) : ℚ) := by
  have h1 : ∀ σ : Equiv.Perm α,
      slotScore w l i a σ = (w - l) * (if σ i = a then (1 : ℚ) else 0) + l := by
    intro σ
    by_cases h : σ i = a <;> simp [slotScore, h]
  rw [Finset.sum_congr rfl (fun σ (_ : σ ∈ (univ : Finset (Equiv.Perm α))) => h1 σ)]
  rw [Finset.sum_add_distrib, ← Finset.mul_sum, Finset.sum_boole, Finset.sum_const,
    Finset.card_univ, nsmul_eq_mul]
  rw [fiber]
  ring

/-- **Master formula for one unresolved slot.**  Whatever card is named, the
expected score of a single slot of an unresolved block of size `|α|` is
`(w - l)/|α| + l`. -/
theorem E_slotScore [Nonempty α] (w l : ℚ) (i a : α) :
    E (slotScore w l i a) = (w - l) / (Fintype.card α : ℚ) + l := by
  have hu : 0 < Fintype.card α := Fintype.card_pos
  have hP : 0 < Fintype.card (Equiv.Perm α) := Fintype.card_pos
  have hkey : Fintype.card α * (fiber i a).card = Fintype.card (Equiv.Perm α) :=
    card_fiber_mul i a
  have hN : 0 < (fiber i a).card := by
    rcases Nat.eq_zero_or_pos (fiber i a).card with h | h
    · rw [h, Nat.mul_zero] at hkey; omega
    · exact h
  have hkeyQ : (Fintype.card α : ℚ) * ((fiber i a).card : ℚ)
      = (Fintype.card (Equiv.Perm α) : ℚ) := by exact_mod_cast hkey
  have huQ : ((Fintype.card α : ℚ)) ≠ 0 := by positivity
  have hNQ : (((fiber i a).card : ℚ)) ≠ 0 := by positivity
  rw [E_def, sum_slotScore, ← hkeyQ]
  field_simp

/-! ## The whole unresolved block -/

/-- Total score of the unresolved block under strategy `g`. -/
def deckScore (w l : ℚ) (g : α → α) (σ : Equiv.Perm α) : ℚ :=
  ∑ i, slotScore w l i (g i) σ

/-- **The unresolved block has expected value `(w - l) + l * |α|`** — for every
strategy `g`, injective or not. -/
theorem expected_deckScore [Nonempty α] (w l : ℚ) (g : α → α) :
    E (deckScore w l g) = (w - l) + l * (Fintype.card α : ℚ) := by
  have hu : ((Fintype.card α : ℚ)) ≠ 0 := by
    have : 0 < Fintype.card α := Fintype.card_pos
    positivity
  have : E (fun σ : Equiv.Perm α => ∑ i, slotScore w l i (g i) σ)
      = ∑ _i : α, ((w - l) / (Fintype.card α : ℚ) + l) := by
    rw [E_sum]
    exact Finset.sum_congr rfl fun i _ => E_slotScore w l i (g i)
  have hd : deckScore w l g = fun σ : Equiv.Perm α => ∑ i, slotScore w l i (g i) σ := rfl
  rw [hd, this, Finset.sum_const, Finset.card_univ, nsmul_eq_mul]
  field_simp

/-- **Rigidity of fair odds.**  The unresolved block is a zero-expectation bet
precisely when the payout ratio is the fair one; no other normalisation of the
scoring makes uncertainty edge-free. -/
theorem fair_odds_iff [Nonempty α] (w l : ℚ) (g : α → α) :
    E (deckScore w l g) = 0 ↔ w = l * (1 - (Fintype.card α : ℚ)) := by
  rw [expected_deckScore]
  constructor
  · intro h; linarith
  · intro h; rw [h]; ring

/-- Fair odds on an unresolved block of size `u`: `u - 1` for a hit, `-1` for a
miss.  Its expected value is zero. -/
theorem expected_fairOdds [Nonempty α] (g : α → α) :
    E (deckScore ((Fintype.card α : ℚ) - 1) (-1) g) = 0 := by
  rw [fair_odds_iff]; ring

/-- Naive unit scoring: `1` for a hit, `0` for a miss.  The expected number of
correct calls on the unresolved block is exactly `1`, whatever the strategy and
however large the block. -/
theorem expected_unit_score [Nonempty α] (g : α → α) :
    E (deckScore 1 0 g) = 1 := by
  rw [expected_deckScore]; ring

/-! ## The full game: resolved cards plus an unresolved block -/

/-- Payoff of the full deck game: `d` resolved cards paying one unit each, and
an unresolved block priced at fair odds. -/
def gamePayoff (d : ℕ) (g : α → α) : (Fin d ⊕ α) → Equiv.Perm α → ℚ :=
  Sum.elim (fun _ _ => (1 : ℚ)) (fun i σ => slotScore ((Fintype.card α : ℚ) - 1) (-1) i (g i) σ)

/-- **Headline theorem: known versus unresolved cards.**  If `d` cards are
predicted with certainty and the remaining `u = |α|` cards are fair guesses,
the expected payoff is exactly `d`.  Uncertainty supplies no positive edge. -/
theorem expected_gamePayoff_eq_known [Nonempty α] (d : ℕ) (g : α → α) :
    E (fun σ : Equiv.Perm α => ∑ c : Fin d ⊕ α, gamePayoff d g c σ) = (d : ℚ) := by
  classical
  set K : Finset (Fin d ⊕ α) := (univ : Finset (Fin d)).map ⟨Sum.inl, Sum.inl_injective⟩ with hK
  have hcard : K.card = d := by simp [hK]
  have hres : ∀ c ∈ K, Resolved (gamePayoff d g c) 1 := by
    intro c hc
    rw [hK, Finset.mem_map] at hc
    obtain ⟨a, -, rfl⟩ := hc
    intro σ; rfl
  have hfair : ∀ c ∉ K, Fair (gamePayoff d g c) := by
    intro c hc
    rcases c with a | b
    · exact absurd (by simp [hK]) hc
    · have := E_slotScore (α := α) ((Fintype.card α : ℚ) - 1) (-1) b (g b)
      have hu : ((Fintype.card α : ℚ)) ≠ 0 := by
        have : 0 < Fintype.card α := Fintype.card_pos
        positivity
      rw [Fair, show gamePayoff d g (Sum.inr b)
          = slotScore ((Fintype.card α : ℚ) - 1) (-1) b (g b) from rfl, this]
      field_simp
      ring
  have := expected_total_eq_certain_count (Ω := Equiv.Perm α) (gamePayoff d g) K hres hfair
  rw [this, hcard]

/-- **The counting anomaly.**  Under naive unit scoring the expected number of
correct calls is `d + 1`, not `d`: the unresolved block contributes exactly one
extra hit, independently of its size and of the strategy.  This single card is
the whole of the apparent "edge" of uncertainty, and `fair_odds_iff` shows it is
purely an artefact of the scoring. -/
theorem expected_unit_score_eq_known_add_one [Nonempty α] (d : ℕ) (g : α → α) :
    E (fun σ : Equiv.Perm α => (d : ℚ) + deckScore 1 0 g σ) = (d : ℚ) + 1 := by
  have h := E_add (Ω := Equiv.Perm α) (fun _ => (d : ℚ)) (deckScore 1 0 g)
  rw [h, E_const, expected_unit_score]

/-! ## Second-moment dichotomy -/

lemma deckScore_one_zero_eq_hits (g : α → α) (σ : Equiv.Perm α) :
    deckScore 1 0 g σ = (hits g σ : ℚ) := by
  rw [deckScore, hits_eq_sum]
  push_cast
  exact Finset.sum_congr rfl fun i _ => by by_cases h : σ i = g i <;> simp [slotScore, h]

lemma E_hits [Nonempty α] (g : α → α) : E (fun σ : Equiv.Perm α => (hits g σ : ℚ)) = 1 := by
  have : (fun σ : Equiv.Perm α => (hits g σ : ℚ)) = deckScore 1 0 g :=
    funext fun σ => (deckScore_one_zero_eq_hits g σ).symm
  rw [this, expected_unit_score]

/-- The variance of the score of an *injective* strategy is `1`. -/
theorem Var_hits_injective (hcard : 2 ≤ Fintype.card α) {g : α → α} (hg : Function.Injective g) :
    Var (fun σ : Equiv.Perm α => (hits g σ : ℚ)) = 1 := by
  have hcpos : 0 < Fintype.card α := by omega
  have hne : Nonempty α := Fintype.card_pos_iff.mp hcpos
  have hP : (0 : ℚ) < (Fintype.card (Equiv.Perm α) : ℚ) := by
    have : 0 < Fintype.card (Equiv.Perm α) := Fintype.card_pos
    exact_mod_cast this
  have hPne : ((Fintype.card (Equiv.Perm α) : ℚ)) ≠ 0 := ne_of_gt hP
  have hsq : ∑ σ : Equiv.Perm α, ((hits g σ : ℚ)) ^ 2
      = 2 * (Fintype.card (Equiv.Perm α) : ℚ) := by
    have h := sum_hits_sq_eq_two_mul hcard hg
    have h' : ((∑ σ : Equiv.Perm α, (hits g σ) ^ 2 : ℕ) : ℚ)
        = ((2 * Fintype.card (Equiv.Perm α) : ℕ) : ℚ) := by rw [h]
    push_cast at h'
    exact h'
  rw [Var_def, E_hits g, E_def, hsq, mul_div_assoc, div_self hPne]
  norm_num

/-- A constant strategy has variance `0`: its score is the deterministic `1`. -/
theorem Var_hits_const [Nonempty α] (a : α) :
    Var (fun σ : Equiv.Perm α => (hits (fun _ => a) σ : ℚ)) = 0 := by
  have h : ∀ σ : Equiv.Perm α, ((hits (fun _ => a) σ : ℚ)) = 1 := by
    intro σ; rw [hits_const_eq_one a σ]; norm_num
  rw [Var_def]
  simp only [h, one_pow]
  simp

/-- **The collision formula for the variance.**  For an arbitrary strategy the
variance of the blind score is the normalised collision profile
`(number of ordered slot pairs with distinct calls) / (u(u-1))`.  It interpolates
between `1` (injective calls) and `0` (a constant call) and is the first
quantity in the game that can see the strategy at all. -/
theorem Var_hits_collision (hcard : 2 ≤ Fintype.card α) (g : α → α) :
    Var (fun σ : Equiv.Perm α => (hits g σ : ℚ))
      = (distinctCallPairs g : ℚ)
          / ((Fintype.card α : ℚ) * ((Fintype.card α : ℚ) - 1)) := by
  have hcpos : 0 < Fintype.card α := by omega
  have hne : Nonempty α := Fintype.card_pos_iff.mp hcpos
  have hP : (0 : ℚ) < (Fintype.card (Equiv.Perm α) : ℚ) := by
    have : 0 < Fintype.card (Equiv.Perm α) := Fintype.card_pos
    exact_mod_cast this
  have hPne : ((Fintype.card (Equiv.Perm α) : ℚ)) ≠ 0 := ne_of_gt hP
  have hu : ((Fintype.card α : ℚ)) ≠ 0 := by positivity
  have hu1 : ((Fintype.card α : ℚ) - 1) ≠ 0 := by
    have : (2 : ℚ) ≤ (Fintype.card α : ℚ) := by exact_mod_cast hcard
    intro h; linarith
  have hQ : (Fintype.card α : ℚ) * ((Fintype.card α : ℚ) - 1)
        * (∑ σ : Equiv.Perm α, ((hits g σ : ℚ)) ^ 2)
      = ((Fintype.card α : ℚ) * ((Fintype.card α : ℚ) - 1) + (distinctCallPairs g : ℚ))
          * (Fintype.card (Equiv.Perm α) : ℚ) := by
    have h := congrArg (fun n : ℕ => (n : ℚ)) (sum_hits_sq_collision (α := α) g)
    push_cast [Nat.cast_sub (show 1 ≤ Fintype.card α by omega)] at h
    exact h
  rw [Var_def, E_hits g, E_def]
  field_simp
  linear_combination hQ

/-- Consistency check: an injective strategy has collision profile `u(u-1)`, so
variance `1`. -/
example (hcard : 2 ≤ Fintype.card α) {g : α → α} (hg : Function.Injective g) :
    Var (fun σ : Equiv.Perm α => (hits g σ : ℚ)) = 1 := by
  have hu : ((Fintype.card α : ℚ)) ≠ 0 := by
    have : 0 < Fintype.card α := by omega
    positivity
  have hu1 : ((Fintype.card α : ℚ) - 1) ≠ 0 := by
    have : (2 : ℚ) ≤ (Fintype.card α : ℚ) := by exact_mod_cast hcard
    intro h; linarith
  rw [Var_hits_collision hcard g, distinctCallPairs_of_injective hg]
  push_cast [Nat.cast_sub (show 1 ≤ Fintype.card α by omega)]
  field_simp

/-- **The mean is strategy-invariant, the variance is not.**  On an unresolved
block of size at least two, the identity strategy and the constant strategy have
the same expected score `1` but different variances `1` and `0`. -/
theorem mean_invariant_variance_not (hcard : 2 ≤ Fintype.card α) (a : α) :
    (E (fun σ : Equiv.Perm α => (hits (id : α → α) σ : ℚ))
        = E (fun σ : Equiv.Perm α => (hits (fun _ => a) σ : ℚ)))
      ∧ Var (fun σ : Equiv.Perm α => (hits (id : α → α) σ : ℚ))
        ≠ Var (fun σ : Equiv.Perm α => (hits (fun _ => a) σ : ℚ)) := by
  have hne : Nonempty α := ⟨a⟩
  refine ⟨by rw [E_hits, E_hits], ?_⟩
  rw [Var_hits_injective hcard Function.injective_id, Var_hits_const a]
  norm_num

end KnownUnresolvedCards