/-
# Sharpening the counting bound for the memoryless class

Fourth research cycle.  The general bound `shtarkovSum_fsmClass_le` costs
*two* powers of `n+1` per state, because it records both the number of `true`s
and the number of `false`s emitted in each state.  For a single-state
(memoryless) machine the two counts are linked by `a + b = n`, so one power
suffices:

  `shtarkovSum (fsmClass M n) ≤ n + 1`  for `M : FSM 1`,

i.e. the minimax regret of the Bernoulli class is at most `log (n+1)`.  The
numerics in `ComputationalEvidence.md` show the true growth is `√(πn/2)`, so
this bound has the correct polynomial order and is off only by the classical
factor `1/2` in the exponent.
-/

import Catalog.Tropical.Shtarkov.EntropyBridge

open Finset

namespace TropicalShtarkov

/-- In a one-state machine the number of `false`s is determined by the number of
`true`s. -/
theorem visits_false_memoryless (M : FSM 1) {n : ℕ} (x : Word n) (s : Fin 1) :
    visits M x (s, false) = n - visits M x (s, true) := by
  have h := sum_visits_states_nat M x
  rw [Fin.sum_univ_one] at h
  have hs : s = 0 := Subsingleton.elim s 0
  subst hs
  omega

/-- The count statistic of a one-state machine is the number of `true`s. -/
theorem countVec_memoryless (M : FSM 1) {n : ℕ} (x : Word n) :
    countVec M x = fun _ => (visits M x (0, true), n - visits M x (0, true)) := by
  funext s
  have hs : s = 0 := Subsingleton.elim s 0
  subst hs
  rw [countVec, visits_false_memoryless M x 0]

/-- The maximum-likelihood plug-in of the memoryless class, indexed by the number
of `true`s. -/
noncomputable def memorylessPlugin (n : ℕ) (y : Fin (n + 1)) : Params 1 :=
  mlOf (fun _ => ((y : ℕ), n - (y : ℕ)))

/-- **The memoryless (Bernoulli) Shtarkov bound.**  A single free parameter costs
only one power of `n+1`: the minimax regret of the memoryless class is at most
`log (n+1)`. -/
theorem shtarkovSum_memoryless_le (M : FSM 1) (n : ℕ) :
    shtarkovSum (fsmClass M n) ≤ ((n : ℝ) + 1) := by
  have key := shtarkovSum_le_card_type (X := Word n) (ι := Params 1)
    (fsmClass M n)
    (fun x => (⟨visits M x (0, true), Nat.lt_succ_of_le (visits_le M x _)⟩ : Fin (n + 1)))
    (fun y x => fsmClass M n (memorylessPlugin n y) x)
    (fun θ x => by
      show fsmClass M n θ x
        ≤ fsmClass M n (memorylessPlugin n ⟨visits M x (0, true), _⟩) x
      have hplug : memorylessPlugin n ⟨visits M x (0, true),
          Nat.lt_succ_of_le (visits_le M x _)⟩ = mlOf (countVec M x) := by
        rw [memorylessPlugin, countVec_memoryless]
      rw [hplug]
      exact prob_le_prob_ml M θ.2 n x)
    (fun y x => fsmClass_nonneg M n _ x)
    (fun y => le_of_eq (sum_fsmClass M n _))
  refine key.trans (le_of_eq ?_)
  simp

/-- In regret form: `log S_n ≤ log (n+1)` for the memoryless class. -/
theorem log_shtarkovSum_memoryless_le (M : FSM 1) (n : ℕ) :
    Real.log (shtarkovSum (fsmClass M n)) ≤ Real.log ((n : ℝ) + 1) :=
  Real.log_le_log (lt_of_lt_of_le zero_lt_one (one_le_shtarkovSum_fsmClass M n))
    (shtarkovSum_memoryless_le M n)

/-- Consequently the memoryless class has vanishing redundancy rate: a
one-parameter family cannot memorise a positive fraction of the message. -/
theorem memoryless_regret_rate_le (M : FSM 1) (n : ℕ) :
    Real.log (shtarkovSum (fsmClass M n)) / n ≤ Real.log ((n : ℝ) + 1) / n :=
  div_le_div_of_nonneg_right (log_shtarkovSum_memoryless_le M n) (Nat.cast_nonneg n)

end TropicalShtarkov