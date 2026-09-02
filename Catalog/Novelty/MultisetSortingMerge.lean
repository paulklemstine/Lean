import Novelty.MultisetSortingMultinomial

/-!
# The merge ledger: how much information a merge erases

`Novelty.SortingDirectSum` shows that for *independent* sorting tasks the erased information is
additive.  For multisets there is a third term.  If a multiset `A` of `n` items (multiplicities
`mᵢ`) and a multiset `B` of `n'` items (multiplicities `m'ⱼ`) over **disjoint** key alphabets are
concatenated, the erased information of the combined task is

  `log₂ (A-erasure) + log₂ (B-erasure) + log₂ C(n+n', n)`,

the extra term being exactly the information in the *interleaving pattern* of the merge.  This is
the information-theoretic content of the classical statement that merging two sorted lists costs
`log₂ C(n+n', n)` comparisons.

## Main results

* `multinomial_sum_type` : the arithmetic identity
  `multinomial (m ⊕ m') = C(n+n', n) · multinomial m · multinomial m'`.
* `keyMult_unionWord` / `card_rearrangements_unionWord` : its combinatorial incarnation for key
  words over a disjoint union of slots and keys.
* `infoErased_merge_ledger` and `landauer_merge_ledger` : the erased information and the Landauer
  work of the concatenated multiset task, split into the two block tasks and the merge term.
* `merge_term_nonneg` : the merge term is nonnegative, so concatenating multisets never erases
  less than the two tasks separately — the multiset analogue of the direct-sum inequality.
-/

open Finset Nat

namespace MultisetSorting

/-! ## The arithmetic identity -/

variable {ι κ : Type*} [Fintype ι] [DecidableEq ι] [Fintype κ] [DecidableEq κ]

omit [DecidableEq ι] [DecidableEq κ] in
/-- **Merge identity for multinomial coefficients.**  Splitting the multiplicity vector along a
disjoint union of alphabets factors the multinomial coefficient into the two block coefficients
times the binomial merge factor. -/
theorem multinomial_sum_type (m : ι → ℕ) (m' : κ → ℕ) :
    Nat.multinomial Finset.univ (Sum.elim m m')
      = ((∑ i, m i) + ∑ j, m' j).choose (∑ i, m i)
        * Nat.multinomial Finset.univ m * Nat.multinomial Finset.univ m' := by
  set n := ∑ i, m i with hn
  set n' := ∑ j, m' j with hn'
  set P := ∏ i, (m i)! with hP
  set P' := ∏ j, (m' j)! with hP'
  have hPpos : 0 < P := Finset.prod_pos fun i _ => Nat.factorial_pos _
  have hP'pos : 0 < P' := Finset.prod_pos fun j _ => Nat.factorial_pos _
  have hsum : ∑ x : ι ⊕ κ, Sum.elim m m' x = n + n' := by
    rw [Fintype.sum_sum_type]; simp [hn, hn']
  have hprod : ∏ x : ι ⊕ κ, (Sum.elim m m' x)! = P * P' := by
    rw [Fintype.prod_sum_type]; simp [hP, hP']
  have hspec := Nat.multinomial_spec (Finset.univ : Finset (ι ⊕ κ)) (Sum.elim m m')
  rw [hsum, hprod] at hspec
  have hspecι := Nat.multinomial_spec (Finset.univ : Finset ι) m
  have hspecκ := Nat.multinomial_spec (Finset.univ : Finset κ) m'
  rw [← hn, ← hP] at hspecι
  rw [← hn', ← hP'] at hspecκ
  have hchoose : (n + n').choose n * n ! * n' ! = (n + n')! := by
    have h := Nat.choose_mul_factorial_mul_factorial (Nat.le_add_right n n')
    simpa using h
  refine Nat.eq_of_mul_eq_mul_right (Nat.mul_pos hPpos hP'pos) ?_
  calc Nat.multinomial Finset.univ (Sum.elim m m') * (P * P')
      = (P * P') * Nat.multinomial Finset.univ (Sum.elim m m') := by ring
    _ = (n + n')! := hspec
    _ = (n + n').choose n * n ! * n' ! := hchoose.symm
    _ = (n + n').choose n * (P * Nat.multinomial Finset.univ m)
          * (P' * Nat.multinomial Finset.univ m') := by rw [hspecι, hspecκ]
    _ = ((n + n').choose n * Nat.multinomial Finset.univ m * Nat.multinomial Finset.univ m')
          * (P * P') := by ring

/-! ## The combinatorial incarnation -/

variable {α β : Type*} [Fintype α] [DecidableEq α] [Fintype β] [DecidableEq β]

/-- Concatenating two key words over disjoint slot sets and disjoint key alphabets. -/
def unionWord (w : α → ι) (w' : β → κ) : α ⊕ β → ι ⊕ κ :=
  Sum.elim (fun a => Sum.inl (w a)) (fun b => Sum.inr (w' b))

omit [Fintype ι] [Fintype κ] [DecidableEq α] [DecidableEq β] in
theorem keyMult_unionWord (w : α → ι) (w' : β → κ) :
    keyMult (unionWord w w') = Sum.elim (keyMult w) (keyMult w') := by
  classical
  funext x
  cases x with
  | inl i =>
      simp only [keyMult, unionWord, Sum.elim_inl]
      rw [Fintype.card_subtype, Fintype.card_subtype, Finset.card_filter, Finset.card_filter,
        Fintype.sum_sum_type]
      simp
  | inr j =>
      simp only [keyMult, unionWord, Sum.elim_inr]
      rw [Fintype.card_subtype, Fintype.card_subtype, Finset.card_filter, Finset.card_filter,
        Fintype.sum_sum_type]
      simp

/-- **Merge count.**  The number of distinguishable inputs of the concatenated multiset is the
product of the two block counts with the binomial merge factor. -/
theorem card_rearrangements_unionWord (w : α → ι) (w' : β → κ) :
    (rearrangements (unionWord w w')).card
      = (Fintype.card α + Fintype.card β).choose (Fintype.card α)
        * (rearrangements w).card * (rearrangements w').card := by
  rw [card_rearrangements, card_rearrangements, card_rearrangements, keyMult_unionWord,
    multinomial_sum_type, sum_keyMult, sum_keyMult]

/-! ## The information ledger -/

/-- **Merge ledger for erased information.**  The concatenated multiset task erases the two block
erasures plus `log₂ C(n+n', n)`: the interleaving pattern. -/
theorem infoErased_merge_ledger (w : α → ι) (w' : β → κ) :
    infoErased (multisetSortingFunction (unionWord w w'))
      = infoErased (multisetSortingFunction w) + infoErased (multisetSortingFunction w')
        + Real.logb 2 ((Fintype.card α + Fintype.card β).choose (Fintype.card α)) := by
  rw [infoErased_multisetSorting, infoErased_multisetSorting, infoErased_multisetSorting,
    ← card_rearrangements, ← card_rearrangements, ← card_rearrangements,
    card_rearrangements_unionWord]
  have hC : (0:ℝ) < ((Fintype.card α + Fintype.card β).choose (Fintype.card α) : ℕ) := by
    exact_mod_cast Nat.choose_pos (Nat.le_add_right _ _)
  have hA : (0:ℝ) < ((rearrangements w).card : ℕ) := by
    exact_mod_cast card_rearrangements_pos w
  have hB : (0:ℝ) < ((rearrangements w').card : ℕ) := by
    exact_mod_cast card_rearrangements_pos w'
  push_cast
  rw [Real.logb_mul (by positivity) (by positivity), Real.logb_mul (by positivity) (by positivity)]
  ring

/-- **Merge ledger in Landauer work.** -/
theorem landauer_merge_ledger (w : α → ι) (w' : β → κ) (kT : ℝ) :
    landauerGap (multisetSortingFunction (unionWord w w')) kT
      = landauerGap (multisetSortingFunction w) kT + landauerGap (multisetSortingFunction w') kT
        + kT * Real.log 2
            * Real.logb 2 ((Fintype.card α + Fintype.card β).choose (Fintype.card α)) := by
  unfold landauerGap landauerCost
  rw [infoErased_merge_ledger]
  ring

/-- The merge term is nonnegative: concatenation never erases less than the two blocks apart. -/
theorem merge_term_nonneg (n n' : ℕ) :
    0 ≤ Real.logb 2 ((n + n').choose n) := by
  refine Real.logb_nonneg (by norm_num) ?_
  exact_mod_cast Nat.choose_pos (Nat.le_add_right n n')

/-- Consequently the concatenated task erases at least the sum of the two block erasures. -/
theorem infoErased_merge_ge (w : α → ι) (w' : β → κ) :
    infoErased (multisetSortingFunction w) + infoErased (multisetSortingFunction w')
      ≤ infoErased (multisetSortingFunction (unionWord w w')) := by
  rw [infoErased_merge_ledger]
  linarith [merge_term_nonneg (Fintype.card α) (Fintype.card β)]

end MultisetSorting