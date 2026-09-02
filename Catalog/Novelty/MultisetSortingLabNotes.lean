import Novelty.MultisetSortingEntropy

/-!
# Lab notes: verified small cases of the multiset erasure ledger

Machine-checked instances of the general theorems of `Novelty.MultisetSortingMultinomial` and
`Novelty.MultisetSortingEntropy`.  Every number below is produced by kernel computation
(`decide`) or by an explicit `Real` computation, never by `native_decide`.

| key word            | n | multiplicities | distinguishable inputs | erased bits | `n·H(p)` bits |
|---------------------|---|----------------|------------------------|-------------|---------------|
| `a a b b`           | 4 | `(2,2)`        | `6  = 4!/2!2!`         | `log₂ 6`    | `4`           |
| `a a b b c`         | 5 | `(2,2,1)`      | `30 = 5!/2!2!1!`       | `log₂ 30`   | `≈ 7.22`      |
| `a a b b b` (merge) | 5 | `(2,3)`        | `10 = 5!/2!3!`         | `log₂ 10`   | `≈ 4.85`      |

The third line is the coarsening of the second along `b, c ↦ b`, and `10 ≤ 30` is the
data-processing law `card_rearrangements_le_of_coarsening` in action.
-/

open Finset Nat

namespace MultisetSorting

/-! ## The balanced two-key word `a a b b` -/

/-- Key word for the multiset `{a, a, b, b}`. -/
def wAABB : Fin 4 → Fin 2 := ![0, 0, 1, 1]

theorem keyMult_wAABB : keyMult wAABB = ![2, 2] := by
  funext i; fin_cases i <;> decide

/-- `4!/2!2! = 6` distinguishable inputs. -/
theorem card_rearrangements_wAABB : (rearrangements wAABB).card = 6 := by
  rw [card_rearrangements, keyMult_wAABB]
  decide

/-- Orbit–stabiliser check: `6 · (2! · 2!) = 24 = 4!`. -/
theorem orbit_stabilizer_wAABB : (rearrangements wAABB).card * ∏ i, (keyMult wAABB i)! = 24 := by
  have h := card_rearrangements_mul_prod_factorial wAABB
  simpa using h

/-- Erased information of sorting `{a,a,b,b}`: exactly `log₂ 6` bits, not `log₂ 24`. -/
theorem infoErased_wAABB : infoErased (multisetSortingFunction wAABB) = Real.logb 2 6 := by
  rw [infoErased_multisetSorting, ← card_rearrangements, card_rearrangements_wAABB]
  norm_num

/-- The conservation ledger `log₂ 24 = log₂ 6 + log₂ 2! + log₂ 2!` holds numerically. -/
theorem conservation_wAABB :
    Real.logb 2 24 = infoErased (multisetSortingFunction wAABB) + 2 := by
  rw [infoErased_wAABB, show (24 : ℝ) = 6 * 2 ^ (2 : ℕ) by norm_num,
    Real.logb_mul (by norm_num) (by positivity), Real.logb_pow,
    Real.logb_self_eq_one (by norm_num : (1:ℝ) < 2)]
  norm_num

/-- The Shannon budget of the balanced two-key word is exactly `4` bits. -/
theorem keyEntropyBits_wAABB : keyEntropyBits wAABB = 4 := by
  have hcard : Fintype.card (Fin 4) = 4 := by simp
  unfold keyEntropyBits
  rw [keyMult_wAABB, hcard]
  have h2 : Real.logb 2 ((4 : ℝ) / 2) = 1 := by
    norm_num
  simp [Fin.sum_univ_two, h2]
  norm_num

/-- **Experimental datum: the Shannon ceiling is strict here.**  `log₂ 6 ≈ 2.585 < 4`. -/
theorem infoErased_wAABB_lt_keyEntropyBits :
    infoErased (multisetSortingFunction wAABB) < keyEntropyBits wAABB := by
  rw [infoErased_wAABB, keyEntropyBits_wAABB]
  have h : Real.logb 2 6 < Real.logb 2 16 := by
    exact Real.logb_lt_logb (by norm_num) (by norm_num) (by norm_num)
  have h16 : Real.logb 2 16 = 4 := by
    rw [show (16 : ℝ) = 2 ^ (4 : ℕ) by norm_num, Real.logb_pow,
      Real.logb_self_eq_one (by norm_num : (1:ℝ) < 2)]
    norm_num
  linarith

/-- The strict repetition discount at this instance: `log₂ 6 < log₂ 24`. -/
theorem discount_wAABB :
    infoErased (multisetSortingFunction wAABB) < Real.logb 2 ((Fintype.card (Fin 4))!) := by
  refine infoErased_multisetSorting_lt_baseline (i₀ := 0) ?_
  rw [keyMult_wAABB]
  decide

/-! ## A three-key word and its coarsening -/

/-- Key word for the multiset `{a, a, b, b, c}`. -/
def wAABBC : Fin 5 → Fin 3 := ![0, 0, 1, 1, 2]

theorem keyMult_wAABBC : keyMult wAABBC = ![2, 2, 1] := by
  funext i; fin_cases i <;> decide

/-- `5!/2!2!1! = 30` distinguishable inputs. -/
theorem card_rearrangements_wAABBC : (rearrangements wAABBC).card = 30 := by
  rw [card_rearrangements, keyMult_wAABBC]
  decide

/-- Merging the keys `b` and `c`. -/
def mergeBC : Fin 3 → Fin 2 := ![0, 1, 1]

theorem coarsening_eq : mergeBC ∘ wAABBC = ![0, 0, 1, 1, 1] := by
  funext a; fin_cases a <;> rfl

theorem keyMult_coarsened : keyMult (mergeBC ∘ wAABBC) = ![2, 3] := by
  funext i; fin_cases i <;> rw [coarsening_eq] <;> decide

/-- `5!/2!3! = 10` distinguishable inputs after the merge. -/
theorem card_rearrangements_coarsened : (rearrangements (mergeBC ∘ wAABBC)).card = 10 := by
  rw [card_rearrangements, keyMult_coarsened]
  decide

/-- **Experimental datum for the data-processing law**: merging two keys drops the number of
distinguishable inputs from `30` to `10`, so the erased information drops from `log₂ 30` to
`log₂ 10` — exactly what `card_rearrangements_le_of_coarsening` predicts. -/
theorem coarsening_strictly_decreases :
    (rearrangements (mergeBC ∘ wAABBC)).card < (rearrangements wAABBC).card := by
  rw [card_rearrangements_coarsened, card_rearrangements_wAABBC]
  norm_num

theorem coarsening_law_instance :
    infoErased (multisetSortingFunction (mergeBC ∘ wAABBC))
      ≤ infoErased (multisetSortingFunction wAABBC) :=
  infoErased_le_of_coarsening wAABBC mergeBC

/-! ## A decision-tree instance -/

/-- Every binary comparison sorter for `{a,a,b,b}` needs at least `⌈log₂ 6⌉ = 3` comparisons,
whereas sorting four *distinct* items needs `⌈log₂ 24⌉ = 5`: the two repeated keys save two
comparisons. -/
theorem comparison_bound_wAABB {d : ℕ} (S : MultisetSorter wAABB 2 d) : 3 ≤ d := by
  have h := S.clog_le_depth (by norm_num)
  rw [keyMult_wAABB] at h
  have hc : Nat.clog 2 (Nat.multinomial (Finset.univ : Finset (Fin 2)) ![2, 2]) = 3 := by
    decide
  omega

theorem clog_baseline_four_distinct : Nat.clog 2 (Nat.factorial 4) = 5 := by decide

end MultisetSorting