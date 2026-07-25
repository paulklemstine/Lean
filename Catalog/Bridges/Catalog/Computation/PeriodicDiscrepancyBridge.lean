import Computation.HammingBallDiscrepancy
import Computation.PeriodicDiscrepancyCurse

/-!
# Bridge: averaging duality for Hamming-ball discrepancy (lower bound companion)

This file connects the **duality / averaging** technique developed for the periodic
`L_p`-discrepancy curse (`PeriodicDiscrepancyCurse.lean`) with the **exact averaging
identity** of the catalog file `HammingBallDiscrepancy.lean`.

The catalog file proves an *exact mean* `∑_z |C ∩ B_r(z)| = |C|·|B_r|` and a *one-sided
upper* (Markov) tail bound `card_bad_centres_le`.  The very same "average ⇒ extremal"
duality step that powers `Rule.exists_large_err` in the curse file yields the missing
*lower* companion: **some centre is hit at least as often as the mean**.  This is a genuine
new consequence of the catalog's `sum_inter_ball`.

* `exists_centre_ge_average` — there is a centre `z` with
  `|C|·|B_r| ≤ |G| · |C ∩ B_r(z)|`, i.e. `|C ∩ B_r(z)| ≥ mean`.
* `exists_centre_pos` — if `C` and the ball are nonempty, some centre's ball meets `C`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The catalog's exact mean identity should, by the same pigeonhole
/ averaging duality used in the curse proof, force the *existence* of a centre whose ball
meets `C` at least the average number of times — a two-sided complement to the published
one-sided Markov bound.

Experiment (Experimenter): Apply `HammingBallDiscrepancy.sum_inter_ball` and then the
generic averaging step `Finset.exists_le_of_sum_le` (the discrete core of `exists_large_err`)
with the constant function `|C|·|B_r|` against `|G|·|C ∩ B_r(z)|`.

Analysis (Analyst): It goes through cleanly over `ℕ`; no division or reals are needed once
the inequality is multiplied through by `|G|`.  This shows the averaging duality is
*domain-agnostic*: the identical step lower-bounds both the integration error (curse file)
and the code–ball intersection (this file).  The shared kernel is exactly "a finite average
is attained from below by some index".

Critique (Critic): The result is non-vacuous (it produces a witness `z` and a genuine
ℕ-inequality) and is the sharp lower companion to `card_bad_centres_le`; the nonempty
hypothesis on the centre type is load-bearing for `exists_le_of_sum_le`.
-/

namespace PeriodicDiscrepancyBridge

open Finset HammingBallDiscrepancy

variable {ι : Type*} {α : Type*} [Fintype ι] [DecidableEq ι] [DecidableEq α] [Fintype α]
variable [AddGroup α] [Nonempty α]

/-- **Averaging lower companion to the Markov bound.**  Using the catalog's exact mean
`∑_z |C ∩ B_r(z)| = |C|·|B_r|`, the same averaging-duality step that drives the curse
lower bound produces a centre `z` whose ball is hit at least the average number of times:
`|C|·|B_r| ≤ |G| · |C ∩ B_r(z)|`. -/
theorem exists_centre_ge_average (C : Finset (ι → α)) (r : ℕ) :
    ∃ z : ι → α, C.card * (ball r (0 : ι → α)).card
      ≤ (Fintype.card (ι → α)) * (C ∩ ball r z).card := by
  have hmean : ∑ z, (C ∩ ball r z).card = C.card * (ball r (0 : ι → α)).card :=
    sum_inter_ball C r
  have hne : (Finset.univ : Finset (ι → α)).Nonempty := Finset.univ_nonempty
  -- Compare the constant `|C|·|B_r|` against `|G| · |C ∩ B_r(z)|` summed over centres.
  have hsum : ∑ _z : (ι → α), C.card * (ball r (0 : ι → α)).card
      ≤ ∑ z, (Fintype.card (ι → α)) * (C ∩ ball r z).card := by
    rw [Finset.sum_const, Finset.card_univ, smul_eq_mul, ← Finset.mul_sum, hmean]
  obtain ⟨z, _, hz⟩ := Finset.exists_le_of_sum_le hne hsum
  exact ⟨z, hz⟩

/-- **A populated ball exists.**  If the code `C` is nonempty and the ball of radius `r`
has positive volume, then some centre `z` has `C ∩ B_r(z)` nonempty: the averaging lower
bound is strong enough to guarantee a genuinely hit ball, not merely a non-negative count. -/
theorem exists_centre_pos (C : Finset (ι → α)) (r : ℕ) (hC : 0 < C.card)
    (hB : 0 < (ball r (0 : ι → α)).card) :
    ∃ z : ι → α, 0 < (C ∩ ball r z).card := by
  obtain ⟨z, hz⟩ := exists_centre_ge_average C r
  refine ⟨z, ?_⟩
  have hpos : 0 < C.card * (ball r (0 : ι → α)).card := Nat.mul_pos hC hB
  have : 0 < (Fintype.card (ι → α)) * (C ∩ ball r z).card := lt_of_lt_of_le hpos hz
  exact Nat.pos_of_mul_pos_left (by rwa [mul_comm] at this)

end PeriodicDiscrepancyBridge