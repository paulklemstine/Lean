/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Eliminating a portfolio member: what is safe and what is not

Fourth cycle of the portfolio programme, formalising the ledger requirement that
*eliminations need dominance arguments, not mean comparisons*.

* `oracleOn` — the oracle restricted to a sub-portfolio.
* `oracleOn_erase_of_dominates` / `ev_oracleOn_erase_of_dominates` — **safe
  elimination**: a member that is dominated *pointwise* by another member may be
  deleted without changing the oracle, instancewise and in expectation.
* `mean_elimination_unsafe` — **unsafe elimination**: a member whose mean cost is
  twice that of another can nevertheless be the only member that keeps the oracle
  cheap; deleting it doubles the oracle's expected cost.  A mean comparison is
  therefore never sufficient grounds for elimination.
-/
import Mathlib
import Probability.PortfolioRegretCore
import Probability.PortfolioRegretTail

namespace Probability.PortfolioRegret

open Finset

variable {Ω S : Type*}

/-- The oracle restricted to the sub-portfolio `T`. -/
noncomputable def oracleOn (T : Finset S) (hT : T.Nonempty) (cost : Ω → S → ℚ) (ω : Ω) : ℚ :=
  T.inf' hT (cost ω)

/-- **Safe elimination.**  If `a` is at least as good as `b` on every instance,
then deleting `b` from the portfolio leaves the oracle unchanged. -/
theorem oracleOn_erase_of_dominates [DecidableEq S] {cost : Ω → S → ℚ} {a b : S}
    (hdom : ∀ ω, cost ω a ≤ cost ω b) {T : Finset S} (ha : a ∈ T.erase b)
    (hT : T.Nonempty) (hTe : (T.erase b).Nonempty) (ω : Ω) :
    oracleOn (T.erase b) hTe cost ω = oracleOn T hT cost ω := by
  refine le_antisymm ?_ (Finset.le_inf' _ _ ?_)
  · refine Finset.le_inf' _ _ fun t ht => ?_
    by_cases hb : t = b
    · subst hb
      exact le_trans (Finset.inf'_le _ ha) (hdom ω)
    · exact Finset.inf'_le _ (Finset.mem_erase.mpr ⟨hb, ht⟩)
  · intro t ht
    exact Finset.inf'_le _ (Finset.mem_of_mem_erase ht)

/-- Safe elimination, in expectation. -/
theorem ev_oracleOn_erase_of_dominates [Fintype Ω] [DecidableEq S] {cost : Ω → S → ℚ} {a b : S}
    (hdom : ∀ ω, cost ω a ≤ cost ω b) {T : Finset S} (ha : a ∈ T.erase b)
    (hT : T.Nonempty) (hTe : (T.erase b).Nonempty) (w : Ω → ℚ) :
    EV w (oracleOn (T.erase b) hTe cost) = EV w (oracleOn T hT cost) :=
  Finset.sum_congr rfl fun ω _ => by
    rw [oracleOn_erase_of_dominates hdom ha hT hTe ω]

/-- The two-member portfolio witnessing the failure of mean-based elimination:
member `0` is cheap on the bulk, member `1` is cheap exactly on the tail. -/
def elimCost : Fin 2 → Fin 2 → ℚ := ![![1, 5], ![5, 1]]

theorem oracleCost_elimCost (ω : Fin 2) : oracleCost elimCost ω = 1 := by
  fin_cases ω
  · rw [oracleCost_fin_two]
    show min (1 : ℚ) 5 = 1
    norm_num
  · rw [oracleCost_fin_two]
    show min (5 : ℚ) 1 = 1
    norm_num

/-- **Unsafe elimination.**  Member `1` has twice the mean cost of member `0`,
yet it is the only member that is cheap on the tail: erasing it doubles the
expected oracle cost, from `1` to `2`.  Mean dominance is not an elimination
certificate. -/
theorem mean_elimination_unsafe :
    (∀ i, 0 ≤ tailW i) ∧ (∑ i, tailW i = 1) ∧
    EV tailW (fun ω => elimCost ω 0) = 2 ∧
    EV tailW (fun ω => elimCost ω 1) = 4 ∧
    EV tailW (oracleCost elimCost) = 1 ∧
    EV tailW (oracleOn ((univ : Finset (Fin 2)).erase 1) ⟨0, by decide⟩ elimCost) = 2 := by
  refine ⟨fun i => by fin_cases i <;> norm_num [tailW], by norm_num [tailW, Fin.sum_univ_two],
    ?_, ?_, ?_, ?_⟩
  · norm_num [EV, tailW, elimCost, Fin.sum_univ_two]
  · norm_num [EV, tailW, elimCost, Fin.sum_univ_two]
  · simp only [EV, oracleCost_elimCost, mul_one]
    norm_num [tailW, Fin.sum_univ_two]
  · have hsingle : ((univ : Finset (Fin 2)).erase 1) = {0} := by decide
    have hval : oracleOn ((univ : Finset (Fin 2)).erase 1) ⟨0, by decide⟩ elimCost
        = fun ω => elimCost ω 0 :=
      funext fun ω => by rw [oracleOn]; simp [hsingle]
    rw [hval]
    norm_num [EV, tailW, elimCost, Fin.sum_univ_two]

end Probability.PortfolioRegret