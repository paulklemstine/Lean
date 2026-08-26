import Physics.StackSquareCoreBasic

/-!
# Bounded partitions as explicit lists

`Physics.StackSquareCore.pb b m` was defined in `Physics.StackSquareCoreBasic` by a
recursion on the largest allowed part.  This file provides the combinatorial content
behind that definition: an explicit `Finset (List ℕ)` of weakly decreasing lists of
positive integers bounded by `b` and summing to `m`, together with

* `mem_partsList_iff` : membership is *exactly* "weakly decreasing, all parts in
  `[1, b]`, sum `m`" — so `partsList b m` really is the set of partitions of `m` into
  parts of size at most `b`, written in descending order;
* `card_partsList` : the cardinality of that set is `pb b m`.

Together these two theorems certify the arithmetic definition of `pb`.
-/

namespace Physics.StackSquareCore

open Finset

/-- `partsList b m` is the finite set of weakly decreasing lists of positive integers,
each at most `b`, with sum `m` (i.e. the partitions of `m` into parts `≤ b`). -/
def partsList : ℕ → ℕ → Finset (List ℕ)
  | 0, m => if m = 0 then {[]} else ∅
  | (b + 1), m => (range (m / (b + 1) + 1)).biUnion (fun c =>
      (partsList b (m - c * (b + 1))).image (fun L => List.replicate c (b + 1) ++ L))

lemma partsList_zero (m : ℕ) : partsList 0 m = if m = 0 then {[]} else ∅ := rfl

lemma partsList_succ (b m : ℕ) :
    partsList (b + 1) m = (range (m / (b + 1) + 1)).biUnion (fun c =>
      (partsList b (m - c * (b + 1))).image (fun L => List.replicate c (b + 1) ++ L)) := rfl

/-- A weakly decreasing list bounded by `b+1` splits as a block of `b+1`s followed by a
list bounded by `b`. -/
lemma sorted_ge_split (b : ℕ) (L : List ℕ) (hs : L.Pairwise (· ≥ ·)) (hb : ∀ x ∈ L, x ≤ b + 1) :
    ∃ c L', L = List.replicate c (b + 1) ++ L' ∧ (∀ x ∈ L', x ≤ b) ∧ L'.Pairwise (· ≥ ·) := by
  induction L with
  | nil => exact ⟨0, [], by simp, by simp, List.Pairwise.nil⟩
  | cons a t ih =>
    have hst : t.Pairwise (· ≥ ·) := List.Pairwise.of_cons hs
    have hbt : ∀ x ∈ t, x ≤ b + 1 := fun x hx => hb x (by simp [hx])
    by_cases ha : a = b + 1
    · obtain ⟨c, L', hL, hL1, hL2⟩ := ih hst hbt
      exact ⟨c + 1, L', by rw [List.replicate_succ, List.cons_append, ← hL, ha], hL1, hL2⟩
    · refine ⟨0, a :: t, by simp, ?_, hs⟩
      intro x hx
      have hxa : x ≤ a := by
        rcases List.mem_cons.1 hx with rfl | hx'
        · exact le_refl x
        · exact List.rel_of_pairwise_cons hs hx'
      have : a ≤ b := by have := hb a (by simp); omega
      omega

/-- **`partsList` is the set of partitions with bounded parts.** -/
theorem mem_partsList_iff (b : ℕ) : ∀ (m : ℕ) (L : List ℕ),
    L ∈ partsList b m ↔ L.Pairwise (· ≥ ·) ∧ (∀ x ∈ L, 1 ≤ x ∧ x ≤ b) ∧ L.sum = m := by
  induction b with
  | zero =>
    intro m L
    rw [partsList_zero]
    constructor
    · intro h
      split_ifs at h with hm
      · simp at h; subst h; simp [hm.symm]
      · simp at h
    · rintro ⟨_, hx, hsum⟩
      have hL : L = [] := by
        rcases L with _ | ⟨a, t⟩
        · rfl
        · exact absurd (hx a (by simp)) (by omega)
      subst hL
      simp at hsum
      simp [← hsum]
  | succ b ih =>
    intro m L
    rw [partsList_succ]
    simp only [Finset.mem_biUnion, Finset.mem_image, Finset.mem_range]
    constructor
    · rintro ⟨c, hc, L₀, hL₀, rfl⟩
      rw [ih] at hL₀
      obtain ⟨hp, hx, hsum⟩ := hL₀
      have hcm : c * (b + 1) ≤ m := by
        have hc' : c ≤ m / (b + 1) := by omega
        exact (Nat.le_div_iff_mul_le (Nat.succ_pos b)).1 hc'
      refine ⟨?_, ?_, ?_⟩
      · rw [List.pairwise_append]
        refine ⟨List.pairwise_replicate.2 (Or.inr (le_refl _)), hp, ?_⟩
        intro a ha b' hb'
        have h1 := List.eq_of_mem_replicate ha
        have h2 := (hx b' hb').2
        omega
      · intro x hx'
        rcases List.mem_append.1 hx' with h | h
        · have := List.eq_of_mem_replicate h; omega
        · have := hx x h; omega
      · rw [List.sum_append, List.sum_replicate, hsum, smul_eq_mul]
        omega
    · rintro ⟨hp, hx, hsum⟩
      obtain ⟨c, L', rfl, h1, h2⟩ := sorted_ge_split b L hp (fun x hxm => (hx x hxm).2)
      rw [List.sum_append, List.sum_replicate, smul_eq_mul] at hsum
      have hsum' : c * (b + 1) + L'.sum = m := by exact_mod_cast hsum
      have hle : c * (b + 1) ≤ m := by omega
      have hcm : c ≤ m / (b + 1) := (Nat.le_div_iff_mul_le (Nat.succ_pos b)).2 hle
      refine ⟨c, by omega, L', ?_, rfl⟩
      rw [ih]
      have hgoal : L'.sum = m - c * (b + 1) := by
        rw [← hsum', Nat.add_sub_cancel_left]
      refine ⟨h2, ?_, hgoal⟩
      intro x hx'
      exact ⟨(hx x (List.mem_append.2 (Or.inr hx'))).1, h1 x hx'⟩

/-- **The arithmetic definition of `pb` counts bounded partitions.** -/
theorem card_partsList (b : ℕ) : ∀ m, (partsList b m).card = pb b m := by
  induction b with
  | zero =>
    intro m
    rw [partsList_zero]
    by_cases hm : m = 0 <;> simp [hm]
  | succ b ih =>
    intro m
    have hcount : ∀ (d : ℕ) (M : List ℕ), M ∈ partsList b (m - d * (b + 1)) →
        (List.replicate d (b + 1) ++ M).count (b + 1) = d := by
      intro d M hM
      have hMb : ∀ x ∈ M, x ≤ b := fun x hx => (((mem_partsList_iff b _ M).1 hM).2.1 x hx).2
      have hnot : (b + 1) ∉ M := fun h => by have := hMb _ h; omega
      rw [List.count_append, List.count_replicate_self, List.count_eq_zero_of_not_mem hnot]
      omega
    rw [partsList_succ, pb_succ_left, Finset.card_biUnion]
    · refine Finset.sum_congr rfl (fun c _ => ?_)
      rw [Finset.card_image_of_injective _ (fun L₁ L₂ h => List.append_cancel_left h), ih]
    · intro c _ c' _ hne
      simp only [Finset.disjoint_left, Finset.mem_image]
      rintro L ⟨L₀, hL₀, rfl⟩ ⟨L₁, hL₁, heq⟩
      have h1 := hcount c L₀ hL₀
      have h2 := hcount c' L₁ hL₁
      rw [heq] at h2
      omega

end Physics.StackSquareCore