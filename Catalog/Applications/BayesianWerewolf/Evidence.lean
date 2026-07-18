import Mathlib
import Applications.BayesianWerewolf.Core

/-!
# Exact small-case evidence for an information-free Werewolf model

To make numerical claims meaningful, this file fixes a deliberately simple baseline model.
At a day vote, one uniformly random surviving player is eliminated.  If it is a wolf, play
continues after the following night unless it was the last wolf; if it is a villager, the
night removes one additional villager.  The boundary states are village victory at zero
wolves and wolf victory once wolves equal or outnumber villagers.

This is not a model of informative voting.  Its purpose is adversarial: it demonstrates that
win rates and scaling laws depend on the information and timing conventions.
-/

namespace BayesianWerewolf

/-- Fuelled exact recursion for the information-free baseline.  Arguments are remaining
fuel, villagers, and wolves.  Sufficient fuel gives the absorption probability. -/
def noInfoWin : ℕ → ℕ → ℕ → ℚ
  | 0, _, w => if w = 0 then 1 else 0
  | fuel + 1, v, w =>
      if w = 0 then 1
      else if v ≤ w then 0
      else
        (w : ℚ) / (v + w) * noInfoWin fuel (v - 1) (w - 1) +
        (v : ℚ) / (v + w) * noInfoWin fuel (v - 2) w

/-- In the specified information-free timing model, seven players with two wolves give
exact village win probability `8/35`, rather than a model-independent `0.36`. -/
theorem noInfoWin_seven_two : noInfoWin 7 5 2 = 8 / 35 := by
  norm_num [noInfoWin]

/-- The exact value lies strictly below `0.36 = 9/25`. -/
theorem noInfoWin_seven_two_lt_point36 : noInfoWin 7 5 2 < 9 / 25 := by
  rw [noInfoWin_seven_two]
  norm_num

end BayesianWerewolf

-- !-- Lab Notes -- !--
/-
## Lab Notes

**Hypothesis.** If the advertised seven-player probability were universal, it would survive
a fully specified information-free baseline with uniform daytime elimination.

**Experiment.** The absorbing-state recurrence was evaluated over exact rationals.  Its two
branches are a wolf hit followed by one night, and a villager hit followed by a second
villager loss at night.

**Analysis.** The result is `8/35`, strictly below `9/25`.  Thus `0.36` cannot be detached
from a particular information structure, move order, or policy class.

**Critique.** This baseline intentionally omits voting evidence and strategic signaling.  It
is a countermodel to universality, not an estimate for rich social play.  Fuel is explicit;
seven steps suffice for the displayed initial state because every nonterminal transition
reduces the surviving population.

**Synthesis.** Numerical Bayesian-Werewolf claims should be indexed by a complete generative
and strategic model.  Exact absorbing recurrences provide a reproducible baseline against
which information-bearing policies can be compared.
-/