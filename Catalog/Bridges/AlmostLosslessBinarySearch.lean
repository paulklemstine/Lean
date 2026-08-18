/-
Copyright (c) 2025 Non-Archimedean Information Theory Project. All rights reserved.

# Almost-Lossless Compression VIII: A Logarithmic-Cost Decoder

## Bridge: Universal hashing ↔ order theory (monotone indexing) ↔ verified algorithmics

The decoder of `AlmostLosslessRandomCoding` costs exactly `|S|` hash evaluations
per query (`scanCost_snd`), because the codebook is stored as an unstructured
list.  Conjecture 1 of the previous cycle asked for a **sub-linear** decoder and
guessed that one would need a hash family that is 2-universal *and* monotone on
every codebook.  That guess is unnecessary: the codebook may simply be **sorted
by hash value after the key is chosen**, which costs nothing in the probabilistic
analysis (it is a permutation of the codebook) and turns the unique-match scan
into a binary search.

This file develops the algorithmic half, entirely free of probabilistic
hypotheses:

* `bsearch` — a cost-instrumented binary search over an index range;
* `bsearch_cost_le` — **exact complexity**: at most `log₂ len + 1` key
  evaluations, proved by strong induction (no `O(·)` hand-waving);
* `bsearch_sound` / `bsearch_found` — soundness and completeness for a key
  function that is monotone on the range;
* `bsDecode` — the decoder: binary search plus a two-neighbour uniqueness check,
  so a duplicate hash value forces abstention;
* `bsDecode_never_wrong` — **no silent corruption**, unconditionally on the
  codebook;
* `bsDecode_cost_le` — total cost `≤ log₂ n + 3`.

## Impact: sublinear_decoder_cost, no_silent_corruption_binary_search
-/

import Mathlib

namespace AlmostLossless

/-! ## Section 1: A cost-instrumented binary search -/

section Search

/-- Binary search for the value `t` of the key function `key` inside the index
range `[lo, lo+len)`, returning the index found (if any) together with the
**exact number of key evaluations performed**. -/
def bsearch (key : ℕ → ℕ) (t : ℕ) (lo len : ℕ) : Option ℕ × ℕ :=
  if h : len = 0 then (none, 0)
  else
    let half := len / 2
    let m := lo + half
    if key m = t then (some m, 1)
    else if key m < t then
      let p := bsearch key t (m + 1) (len - half - 1)
      (p.1, p.2 + 1)
    else
      let p := bsearch key t lo half
      (p.1, p.2 + 1)
termination_by len
decreasing_by
  · omega
  · omega

@[simp] theorem bsearch_zero (key : ℕ → ℕ) (t lo : ℕ) :
    bsearch key t lo 0 = (none, 0) := by
  rw [bsearch]; simp

theorem bsearch_succ (key : ℕ → ℕ) (t lo len : ℕ) (h : len ≠ 0) :
    bsearch key t lo len =
      (if key (lo + len / 2) = t then (some (lo + len / 2), 1)
       else if key (lo + len / 2) < t then
         ((bsearch key t (lo + len / 2 + 1) (len - len / 2 - 1)).1,
          (bsearch key t (lo + len / 2 + 1) (len - len / 2 - 1)).2 + 1)
       else
         ((bsearch key t lo (len / 2)).1, (bsearch key t lo (len / 2)).2 + 1)) := by
  rw [bsearch]
  simp only [h, dif_neg, not_false_iff]

/-- **Exact complexity of the search**: at most `log₂ len + 1` key evaluations. -/
theorem bsearch_cost_le (key : ℕ → ℕ) (t : ℕ) :
    ∀ len lo : ℕ, (bsearch key t lo len).2 ≤ Nat.log 2 len + 1 := by
  intro len
  induction len using Nat.strong_induction_on with
  | _ len ih =>
    intro lo
    rcases Nat.eq_zero_or_pos len with rfl | hpos
    · simp
    · rcases Nat.lt_or_ge len 2 with h2 | h2
      · -- len = 1 : the search stops after one evaluation either way
        have hlen : len = 1 := by omega
        subst hlen
        rw [bsearch_succ key t lo 1 (by norm_num)]
        norm_num
        split <;> simp
      · -- len ≥ 2 : recurse on a range of size at most `len / 2`
        have hlen2 : 2 ≤ len := h2
        have hlog : Nat.log 2 (len / 2) + 1 = Nat.log 2 len := by
          have hp : 0 < Nat.log 2 len := Nat.log_pos (by norm_num) hlen2
          rw [Nat.log_div_base]
          omega
        rw [bsearch_succ key t lo len (by omega)]
        by_cases hkey : key (lo + len / 2) = t
        · simp [hkey]
        · have hr1 : len - len / 2 - 1 < len := by omega
          have hr2 : len / 2 < len := by omega
          have hb1 : (bsearch key t (lo + len / 2 + 1) (len - len / 2 - 1)).2
              ≤ Nat.log 2 (len / 2) + 1 := by
            refine le_trans (ih _ hr1 _) ?_
            have : Nat.log 2 (len - len / 2 - 1) ≤ Nat.log 2 (len / 2) :=
              Nat.log_mono_right (by omega)
            omega
          have hb2 : (bsearch key t lo (len / 2)).2 ≤ Nat.log 2 (len / 2) + 1 :=
            ih _ hr2 _
          by_cases hlt : key (lo + len / 2) < t <;> simp [hkey, hlt] <;> omega

/-- **Soundness.**  Any index returned lies in the search range and has the
requested key value — no monotonicity hypothesis is needed. -/
theorem bsearch_sound (key : ℕ → ℕ) (t : ℕ) :
    ∀ len lo m : ℕ, (bsearch key t lo len).1 = some m →
      key m = t ∧ lo ≤ m ∧ m < lo + len := by
  intro len
  induction len using Nat.strong_induction_on with
  | _ len ih =>
    intro lo m hm
    rcases Nat.eq_zero_or_pos len with rfl | hpos
    · simp at hm
    · rw [bsearch_succ key t lo len (by omega)] at hm
      by_cases hkey : key (lo + len / 2) = t
      · simp only [hkey, if_pos] at hm
        have : m = lo + len / 2 := by
          simpa [eq_comm] using hm
        subst this
        exact ⟨hkey, by omega, by omega⟩
      · by_cases hlt : key (lo + len / 2) < t
        · simp only [hkey, hlt, if_neg, if_pos, not_false_iff] at hm
          obtain ⟨h1, h2, h3⟩ := ih (len - len / 2 - 1) (by omega) (lo + len / 2 + 1) m hm
          exact ⟨h1, by omega, by omega⟩
        · simp only [hkey, hlt, if_neg, not_false_iff] at hm
          obtain ⟨h1, h2, h3⟩ := ih (len / 2) (by omega) lo m hm
          exact ⟨h1, by omega, by omega⟩

/-- **Completeness.**  If the key function is monotone on the search range and
some index in the range carries the value `t`, the search returns an index. -/
theorem bsearch_found (key : ℕ → ℕ) (t : ℕ) :
    ∀ len lo j : ℕ,
      (∀ i i' : ℕ, lo ≤ i → i ≤ i' → i' < lo + len → key i ≤ key i') →
      lo ≤ j → j < lo + len → key j = t →
      ∃ m, (bsearch key t lo len).1 = some m := by
  intro len
  induction len using Nat.strong_induction_on with
  | _ len ih =>
    intro lo j hmono hlo hhi hkeyj
    rcases Nat.eq_zero_or_pos len with rfl | hpos
    · omega
    · rw [bsearch_succ key t lo len (by omega)]
      set m := lo + len / 2 with hm
      by_cases hkey : key m = t
      · exact ⟨m, by simp [hkey]⟩
      · by_cases hlt : key m < t
        · -- target lies strictly to the right of the midpoint
          have hjm : m < j := by
            by_contra hcon
            push_neg at hcon
            have : key j ≤ key m := hmono j m hlo hcon (by omega)
            omega
          have hsub : ∀ i i' : ℕ, m + 1 ≤ i → i ≤ i' →
              i' < m + 1 + (len - len / 2 - 1) → key i ≤ key i' := by
            intro i i' h1 h2 h3
            exact hmono i i' (by omega) h2 (by omega)
          obtain ⟨m', hm'⟩ := ih (len - len / 2 - 1) (by omega) (m + 1) j hsub
            (by omega) (by omega) hkeyj
          exact ⟨m', by simp [hkey, hlt, hm']⟩
        · -- target lies strictly to the left of the midpoint
          push_neg at hlt
          have hjm : j < m := by
            by_contra hcon
            push_neg at hcon
            have : key m ≤ key j := hmono m j (by omega) hcon (by omega)
            omega
          have hsub : ∀ i i' : ℕ, lo ≤ i → i ≤ i' → i' < lo + len / 2 → key i ≤ key i' := by
            intro i i' h1 h2 h3
            exact hmono i i' h1 h2 (by omega)
          obtain ⟨m', hm'⟩ := ih (len / 2) (by omega) lo j hsub hlo (by omega) hkeyj
          exact ⟨m', by simp [hkey, hlt.not_gt, hm']⟩

end Search

/-! ## Section 2: The logarithmic decoder with a uniqueness check -/

section Decoder

variable {α : Type*}

/-- Two-sided neighbour test: on a range sorted by `key`, index `m` carries a
value distinct from its neighbours exactly when it is the *unique* index in
`[0,n)` with that value. -/
def neighbourDistinct (key : ℕ → ℕ) (n m : ℕ) : Prop :=
  (m = 0 ∨ key (m - 1) ≠ key m) ∧ (n ≤ m + 1 ∨ key (m + 1) ≠ key m)

instance (key : ℕ → ℕ) (n m : ℕ) : Decidable (neighbourDistinct key n m) := by
  unfold neighbourDistinct; infer_instance

/-- **Uniqueness from two comparisons.**  On a monotone range, distinctness from
the two neighbours upgrades to global uniqueness inside `[0,n)`. -/
theorem unique_of_neighbourDistinct {key : ℕ → ℕ} {n m : ℕ}
    (hmono : ∀ i i' : ℕ, i ≤ i' → i' < n → key i ≤ key i')
    (hm : m < n) (hnd : neighbourDistinct key n m) :
    ∀ j < n, key j = key m → j = m := by
  intro j hj hkey
  by_contra hne
  rcases lt_or_gt_of_ne hne with hlt | hgt
  · have hm0 : m ≠ 0 := by omega
    have hstep : key (m - 1) ≠ key m := by
      rcases hnd.1 with h | h
      · exact absurd h hm0
      · exact h
    have h1 : key j ≤ key (m - 1) := hmono j (m - 1) (by omega) (by omega)
    have h2 : key (m - 1) ≤ key m := hmono (m - 1) m (by omega) hm
    omega
  · have hmn : m + 1 < n := by omega
    have hstep : key (m + 1) ≠ key m := by
      rcases hnd.2 with h | h
      · omega
      · exact h
    have h1 : key m ≤ key (m + 1) := hmono m (m + 1) (by omega) hmn
    have h2 : key (m + 1) ≤ key j := hmono (m + 1) j (by omega) hj
    omega

/-- The logarithmic decoder: binary search for the received codeword, then two
neighbour comparisons; abstain unless the match is unique.  The second component
is the exact number of key evaluations. -/
def bsDecode (key : ℕ → ℕ) (a : ℕ → α) (n t : ℕ) : Option α × ℕ :=
  let p := bsearch key t 0 n
  match p.1 with
  | none => (none, p.2)
  | some m => (if neighbourDistinct key n m then some (a m) else none, p.2 + 2)

/-- **Exact decoding cost**: `log₂ n + 3` key evaluations, against `n` for the
linear scan. -/
theorem bsDecode_cost_le (key : ℕ → ℕ) (a : ℕ → α) (n t : ℕ) :
    (bsDecode key a n t).2 ≤ Nat.log 2 n + 3 := by
  unfold bsDecode
  have hc := bsearch_cost_le key t n 0
  rcases hfst : (bsearch key t 0 n).1 with _ | m <;> simp [hfst] <;> omega

/-- **Soundness / no silent corruption.**  Whenever the decoder answers, it
answers with an index of the range whose key is the received codeword and which
is the *unique* such index.  Nothing is assumed about `key`. -/
theorem bsDecode_sound {key : ℕ → ℕ} {a : ℕ → α} {n t : ℕ} {x : α}
    (hx : (bsDecode key a n t).1 = some x) :
    ∃ m, m < n ∧ x = a m ∧ key m = t ∧ neighbourDistinct key n m := by
  unfold bsDecode at hx
  rcases hfst : (bsearch key t 0 n).1 with _ | m
  · simp [hfst] at hx
  · simp only [hfst] at hx
    obtain ⟨hk, _, hlt⟩ := bsearch_sound key t n 0 m hfst
    by_cases hnd : neighbourDistinct key n m
    · simp only [hnd, if_pos] at hx
      have hxa : x = a m := by simpa using hx.symm
      exact ⟨m, by omega, hxa, hk, hnd⟩
    · simp [hnd] at hx

/-- **Never wrong on the codebook.**  If the transmitted symbol is the codebook
entry `a j` and the decoder answers at all, it answers `a j` — for a monotone
indexing, a wrong answer is impossible.  This is the "no silent corruption"
guarantee for the logarithmic decoder. -/
theorem bsDecode_never_wrong {key : ℕ → ℕ} {a : ℕ → α} {n j : ℕ} {x : α}
    (hmono : ∀ i i' : ℕ, i ≤ i' → i' < n → key i ≤ key i')
    (hj : j < n) (hx : (bsDecode key a n (key j)).1 = some x) : x = a j := by
  obtain ⟨m, hmn, hxm, hkm, hnd⟩ := bsDecode_sound hx
  have : j = m := unique_of_neighbourDistinct hmono hmn hnd j hj hkm.symm
  rw [hxm, this]

/-- **Completeness.**  A codebook entry whose key is unique in the range is
decoded exactly, in `log₂ n + 3` key evaluations. -/
theorem bsDecode_eq_some_of_unique {key : ℕ → ℕ} {a : ℕ → α} {n j : ℕ}
    (hmono : ∀ i i' : ℕ, i ≤ i' → i' < n → key i ≤ key i')
    (hj : j < n) (huniq : ∀ i < n, key i = key j → i = j) :
    (bsDecode key a n (key j)).1 = some (a j) := by
  have hmono' : ∀ i i' : ℕ, 0 ≤ i → i ≤ i' → i' < 0 + n → key i ≤ key i' := by
    intro i i' _ h2 h3
    exact hmono i i' h2 (by omega)
  obtain ⟨m, hm⟩ := bsearch_found key (key j) n 0 j hmono' (by omega) (by omega) rfl
  obtain ⟨hk, _, hlt⟩ := bsearch_sound key (key j) n 0 m hm
  have hmj : m = j := huniq m (by omega) hk
  subst hmj
  have hnd : neighbourDistinct key n m := by
    constructor
    · rcases Nat.eq_zero_or_pos m with h | h
      · exact Or.inl h
      · refine Or.inr ?_
        intro hcon
        have := huniq (m - 1) (by omega) hcon
        omega
    · by_cases hmn : n ≤ m + 1
      · exact Or.inl hmn
      · refine Or.inr ?_
        intro hcon
        have := huniq (m + 1) (by omega) hcon
        omega
  unfold bsDecode
  simp [hm, hnd]

end Decoder

end AlmostLossless