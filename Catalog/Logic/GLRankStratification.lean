import Mathlib
import Logic.PolymodalGL

/-!
# Rank stratification of iterated box: a quantitative Löb for every GL frame

This file pursues **Direction 4** ("Rank as a quantitative Löb / consistency-strength
gauge") of the polymodal-GL research cycle, building on the ordinal rank
`GLFrame.rank` and its descent lemma `gl_rank_lt_of_R` from
`Catalog/Logic/PolymodalGL.lean`, together with `GLFrame.boxSet` and
`GLFrame.IsMaximal` from `Catalog/Logic/GLKripke.lean`.

The concrete model file `Catalog/Logic/LobNatModel.lean` proved the *quantitative*
identity `natBox^[k] ∅ = Set.Iio k` for the canonical frame `(ℕ, >)`: the `k`-fold
"inconsistency" statement is exactly the set of worlds of depth `< k`.  Here we lift
that computation to an **arbitrary** GL frame, replacing the literal depth by the
ordinal rank:

## Main results

* `GLFrame.boxSet_empty_eq_maximal` — `□∅` is exactly the set of dead-end (maximal)
  worlds.

* `GLFrame.rank_eq_zero_iff_maximal` — a world has ordinal rank `0` iff it is a dead
  end; rank `0` is the bottom layer of the stratification.

* `GLFrame.boxSet_iterate_eq_rank_lt` — **the rank stratification**: for every `k`,
  `□^k ∅ = { w | rank w < k }`.  The `k`-fold falsity is satisfied exactly at worlds of
  ordinal rank below `k`, generalizing `natBox_iterate_eq_Iio` (where `rank n = n`) to
  every GL frame.

-- !-- Lab Notebook -- !--
**Hypothesis.** In any GL frame the iterated box of the empty set stratifies the
worlds by ordinal rank: `□^k ∅ = {w | rank w < k}`, generalizing the `(ℕ,>)`
computation `natBox^[k] ∅ = Iio k`.

**Result.** Confirmed. The base case `□^0 ∅ = ∅ = {rank < 0}` is trivial; the step
uses `rank w = ⨆_{R w v} succ (rank v)`, so `rank w ≤ k ↔ ∀ v, R w v → rank v < k`,
which is exactly membership of `w` in `□{rank < k}` by the induction hypothesis.

**Insight.** Provability rank is not extra data: the ordinal rank of a world *equals*
the least `k` for which `□^k ⊥` fails there. Gödel-style "consistency strength" and the
set-theoretic ordinal rank of the accessibility tree are the same invariant.

**Failure analysis.** The naive guess `□^k ∅ = {rank ≤ k}` is off by one: `□^1 ∅`
(the maximal worlds) is `{rank = 0} = {rank < 1}`, not `{rank ≤ 1}`. The strict `<`
is forced by the `succ` in `rank w = ⨆ succ (rank v)`.
-- !-- end Lab Notebook -- !--
-/

open Set Function

namespace GLFrame

/-
!-- `□∅` collects worlds all of whose successors lie in `∅`, i.e. worlds with no
successor at all — the dead ends. -- !--

**The box of the empty set is the set of dead ends.**  `□∅ = { w | IsMaximal w }`:
a world boxes falsity iff it has no accessible successor.
-/
theorem boxSet_empty_eq_maximal (F : GLFrame) :
    F.boxSet (∅ : Set F.World) = { w | F.IsMaximal w } := by
  grind +suggestions

/-
!-- `rank w = ⨆_{R w v} succ (rank v)`; this is `0` iff there are no successors. -- !--

**Rank zero characterizes dead ends.**  `rank w = 0 ↔ IsMaximal w`.  The bottom
ordinal layer of the rank stratification is exactly the maximal worlds.
-/
theorem rank_eq_zero_iff_maximal (F : GLFrame) (w : F.World) :
    F.rank w = 0 ↔ F.IsMaximal w := by
  constructor <;> intro h;
  · intro v hv; have := @gl_rank_lt_of_R F w v hv; aesop;
  · unfold GLFrame.rank;
    rw [ IsWellFounded.rank_eq ];
    convert ciSup_of_empty _;
    exact ⟨ fun x => h _ x.2 ⟩

/-
!-- Induction on `k`. Step: `w ∈ □^{k+1} ∅ ↔ ∀ v, R w v → rank v < k` (IH) ↔
`⨆_{R w v} succ (rank v) ≤ k` ↔ `rank w < k+1`. -- !--

**The rank stratification (quantitative Löb).**  For every `k`, the `k`-fold box of
falsity is exactly the set of worlds of ordinal rank below `k`:
`□^k ∅ = { w | rank w < k }`.  This generalizes `natBox_iterate_eq_Iio`
(`natBox^[k] ∅ = Iio k`, the case `rank n = n` of the frame `(ℕ, >)`) to every GL
frame, identifying consistency strength with ordinal rank.
-/
theorem boxSet_iterate_eq_rank_lt (F : GLFrame) (k : ℕ) :
    F.boxSet^[k] (∅ : Set F.World) = { w | F.rank w < (k : Ordinal) } := by
  apply Set.ext
  intro w
  revert w;
  induction' k with k ih <;> simp_all +decide [ Function.iterate_succ_apply' ];
  intro w
  rw [GLFrame.boxSet];
  rw [ show F.rank w = ⨆ v : { v // F.R w v }, Order.succ ( F.rank v ) from ?_ ];
  · simp +decide [ Ordinal.iSup_le_iff, ih ];
  · convert IsWellFounded.rank_eq _ w using 1

end GLFrame