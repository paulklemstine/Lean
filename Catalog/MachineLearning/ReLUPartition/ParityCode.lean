import Mathlib
import MachineLearning.ReLUPartition.Schlafli

/-!
# The change-set code for activation patterns on a line of neurons

To count the activation patterns realizable by the moment-curve arrangement we
need an exact combinatorial encoding of subsets `S ⊆ Fin n` by their
"sign-change positions".  Think of `S` as a binary string `s_0 … s_{n-1}`
extended by a virtual `s_n = 1` at infinity.  Its **change set**

  `changeSet S = {j | s_j ≠ s_{j+1}}`

records the positions where the string switches.  The two main results are:

* `changeSet` is a **bijection** of `Finset (Fin n)` onto itself, with explicit
  inverse `decodeSet` given by the parity rule
  `i ∈ decodeSet T ↔ Even #{j ∈ T | i ≤ j}` (`changeSet_decodeSet`,
  `decodeSet_changeSet`);
* consequently the number of subsets whose change set has at most `d` elements
  is exactly `schlafli n d` (`card_filter_changeSet_card_le`).

Under the bijection, the change set counts the *real roots* a monic polynomial
must spend in order to realize the pattern `S` on the points `0, 1, …, n-1`;
this is what makes the Schläfli count appear in
`MachineLearning.ReLUPartition.MomentSharp`.
-/

open Finset

namespace ReLUPartition

variable {n : ℕ}

/-- The indicator of `S`, extended by `true` beyond the index range (the
"virtual sign at infinity"). -/
def ind (S : Finset (Fin n)) (k : ℕ) : Bool :=
  if h : k < n then decide ((⟨k, h⟩ : Fin n) ∈ S) else true

@[simp] lemma ind_coe (S : Finset (Fin n)) (i : Fin n) : ind S (i : ℕ) = decide (i ∈ S) := by
  simp [ind, i.2]

lemma ind_of_ge (S : Finset (Fin n)) {k : ℕ} (h : n ≤ k) : ind S k = true := by
  simp [ind, Nat.not_lt.mpr h]

/-- The positions where the (extended) indicator string of `S` changes value. -/
def changeSet (S : Finset (Fin n)) : Finset (Fin n) :=
  univ.filter (fun j : Fin n => ind S (j : ℕ) ≠ ind S ((j : ℕ) + 1))

@[simp] lemma mem_changeSet {S : Finset (Fin n)} {j : Fin n} :
    j ∈ changeSet S ↔ ind S (j : ℕ) ≠ ind S ((j : ℕ) + 1) := by
  simp [changeSet]

/-- The number of elements of `T` at or beyond position `k`. -/
def tailCount (T : Finset (Fin n)) (k : ℕ) : ℕ := (T.filter (fun j : Fin n => k ≤ (j : ℕ))).card

@[simp] lemma tailCount_of_ge (T : Finset (Fin n)) {k : ℕ} (h : n ≤ k) : tailCount T k = 0 := by
  unfold tailCount
  rw [Finset.card_eq_zero, Finset.filter_eq_empty_iff]
  intro j _
  have := j.isLt
  omega

/-- Removing position `k` from the tail decreases the tail count by `1` exactly
when `k` belongs to `T`. -/
lemma tailCount_succ (T : Finset (Fin n)) {k : ℕ} (hk : k < n) :
    tailCount T k = tailCount T (k + 1) + (if (⟨k, hk⟩ : Fin n) ∈ T then 1 else 0) := by
  classical
  unfold tailCount
  by_cases hmem : (⟨k, hk⟩ : Fin n) ∈ T
  · have hins : T.filter (fun j : Fin n => k ≤ (j : ℕ))
        = insert (⟨k, hk⟩ : Fin n) (T.filter (fun j : Fin n => k + 1 ≤ (j : ℕ))) := by
      ext j
      simp only [Finset.mem_filter, Finset.mem_insert]
      constructor
      · rintro ⟨hjT, hj⟩
        rcases Nat.eq_or_lt_of_le hj with h | h
        · exact Or.inl (Fin.eq_of_val_eq h).symm
        · exact Or.inr ⟨hjT, h⟩
      · rintro (rfl | ⟨hjT, hj⟩)
        · exact ⟨hmem, le_refl _⟩
        · exact ⟨hjT, by omega⟩
    rw [hins, Finset.card_insert_of_notMem (by simp), if_pos hmem]
  · have heq : T.filter (fun j : Fin n => k ≤ (j : ℕ)) = T.filter (fun j : Fin n => k + 1 ≤ (j : ℕ)) := by
      ext j
      simp only [Finset.mem_filter]
      constructor
      · rintro ⟨hjT, hj⟩
        refine ⟨hjT, ?_⟩
        rcases Nat.eq_or_lt_of_le hj with h | h
        · exact absurd (by rw [show (⟨k, hk⟩ : Fin n) = j from Fin.eq_of_val_eq h]; exact hjT) hmem
        · exact h
      · rintro ⟨hjT, hj⟩
        exact ⟨hjT, by omega⟩
    rw [heq, if_neg hmem]
    ring

/-- **Parity decoding.**  The sign of `S` at position `k` is determined by the
parity of the number of changes at or after `k`. -/
theorem ind_eq_even_tailCount (S : Finset (Fin n)) :
    ∀ m k : ℕ, n - k = m → k ≤ n → (ind S k = true ↔ Even (tailCount (changeSet S) k)) := by
  intro m
  induction m with
  | zero =>
      intro k hm hk
      have hkn : k = n := by omega
      rw [hkn, ind_of_ge S (le_refl n), tailCount_of_ge (changeSet S) (le_refl n)]
      simp
  | succ m ih =>
      intro k hm hk
      have hkn : k < n := by omega
      have hih := ih (k + 1) (by omega) (by omega)
      have hsplit := tailCount_succ (changeSet S) hkn
      by_cases hmem : (⟨k, hkn⟩ : Fin n) ∈ changeSet S
      · have hne : ind S k ≠ ind S (k + 1) := by simpa using mem_changeSet.mp hmem
        rw [hsplit, if_pos hmem, Nat.even_add_one]
        have hb : (ind S k = true) ↔ ¬ (ind S (k + 1) = true) := by
          revert hne; cases ind S k <;> cases ind S (k + 1) <;> simp
        rw [hb, hih]
      · have heq : ind S k = ind S (k + 1) := by
          by_contra hne
          exact hmem (mem_changeSet.mpr (by simpa using hne))
        rw [hsplit, if_neg hmem, add_zero, heq]
        exact hih

/-- The parity-decoding map, inverse to `changeSet`. -/
def decodeSet (T : Finset (Fin n)) : Finset (Fin n) :=
  univ.filter (fun i : Fin n => Even (tailCount T (i : ℕ)))

@[simp] lemma mem_decodeSet {T : Finset (Fin n)} {i : Fin n} :
    i ∈ decodeSet T ↔ Even (tailCount T (i : ℕ)) := by
  simp [decodeSet]

lemma ind_decodeSet (T : Finset (Fin n)) {k : ℕ} (hk : k ≤ n) :
    (ind (decodeSet T) k = true ↔ Even (tailCount T k)) := by
  rcases Nat.lt_or_ge k n with h | h
  · rw [show ind (decodeSet T) k = decide ((⟨k, h⟩ : Fin n) ∈ decodeSet T) by simp [ind, h]]
    simp
  · have hkn : k = n := by omega
    rw [hkn, ind_of_ge (decodeSet T) (le_refl n), tailCount_of_ge T (le_refl n)]
    simp

/-- `decodeSet` is a left inverse of `changeSet`. -/
theorem decodeSet_changeSet (S : Finset (Fin n)) : decodeSet (changeSet S) = S := by
  ext i
  rw [mem_decodeSet, ← ind_eq_even_tailCount S (n - (i : ℕ)) (i : ℕ) rfl (le_of_lt i.isLt)]
  simp

/-- `decodeSet` is a right inverse of `changeSet`. -/
theorem changeSet_decodeSet (T : Finset (Fin n)) : changeSet (decodeSet T) = T := by
  ext j
  rw [mem_changeSet]
  have h1 := ind_decodeSet T (le_of_lt j.isLt)
  have h2 := ind_decodeSet T (show (j : ℕ) + 1 ≤ n from j.isLt)
  have hsplit := tailCount_succ T j.isLt
  have hj : (⟨(j : ℕ), j.isLt⟩ : Fin n) = j := rfl
  rw [hj] at hsplit
  have hne : (ind (decodeSet T) (j : ℕ) ≠ ind (decodeSet T) ((j : ℕ) + 1))
      ↔ ¬ ((ind (decodeSet T) (j : ℕ) = true) ↔ (ind (decodeSet T) ((j : ℕ) + 1) = true)) := by
    cases ind (decodeSet T) (j : ℕ) <;> cases ind (decodeSet T) ((j : ℕ) + 1) <;> simp
  rw [hne, h1, h2, hsplit]
  by_cases hjT : j ∈ T
  · simp only [if_pos hjT, Nat.even_add_one]
    tauto
  · simp [hjT]

/-- `changeSet` is injective. -/
theorem changeSet_injective : Function.Injective (changeSet : Finset (Fin n) → Finset (Fin n)) := by
  intro S₁ S₂ h
  rw [← decodeSet_changeSet S₁, ← decodeSet_changeSet S₂, h]

/-- The number of subsets of `Fin n` with at most `d` elements is `schlafli n d`. -/
theorem card_filter_card_le (n d : ℕ) :
    ((univ : Finset (Finset (Fin n))).filter (fun T => T.card ≤ d)).card = schlafli n d := by
  classical
  have hbi : (univ : Finset (Finset (Fin n))).filter (fun T => T.card ≤ d)
      = (Iic d).biUnion (fun k => Finset.powersetCard k (univ : Finset (Fin n))) := by
    ext T
    simp only [Finset.mem_filter, Finset.mem_univ, true_and, Finset.mem_biUnion, Finset.mem_Iic,
      Finset.mem_powersetCard]
    constructor
    · intro h; exact ⟨T.card, h, Finset.subset_univ T, rfl⟩
    · rintro ⟨k, hk, _, rfl⟩; exact hk
  rw [hbi, Finset.card_biUnion]
  · unfold schlafli
    refine Finset.sum_congr rfl fun k _ => ?_
    rw [Finset.card_powersetCard, Finset.card_univ, Fintype.card_fin]
  · intro a _ b _ hab
    refine Finset.disjoint_left.mpr fun T hTa hTb => hab ?_
    rw [Finset.mem_powersetCard] at hTa hTb
    rw [← hTa.2, ← hTb.2]

/-- **The change-set count.**  Exactly `schlafli n d` activation patterns have a
change set of size at most `d`. -/
theorem card_filter_changeSet_card_le (n d : ℕ) :
    ((univ : Finset (Finset (Fin n))).filter (fun S => (changeSet S).card ≤ d)).card
      = schlafli n d := by
  classical
  rw [← card_filter_card_le n d]
  refine Finset.card_bij (fun S _ => changeSet S) ?_ ?_ ?_
  · intro S hS
    simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hS ⊢
    exact hS
  · intro S₁ _ S₂ _ h
    exact changeSet_injective h
  · intro T hT
    simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hT
    refine ⟨decodeSet T, ?_, ?_⟩
    · simp only [Finset.mem_filter, Finset.mem_univ, true_and, changeSet_decodeSet]
      exact hT
    · exact changeSet_decodeSet T

end ReLUPartition