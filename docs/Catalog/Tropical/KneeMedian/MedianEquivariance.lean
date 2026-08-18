/-
# Order-reversal equivariance of the median (tropical robust statistics)

This file develops, for an arbitrary linear order, the *counting* characterisation
of the median of an odd multiset

    `IsMedian k s m  ↔  m ∈ s ∧ #{x ∈ s | x ≤ m} ≥ k+1 ∧ #{x ∈ s | m ≤ x} ≥ k+1`

for `card s = 2k+1`, and proves the three structural theorems that make the
median the *canonical centre* of a seed distribution:

* `IsMedian.unique` — the median is unique (a counting/pigeonhole argument);
* `exists_isMedian` — the median exists (via the sorted representative);
* `IsMedian.map_mono` / `IsMedian.map_anti` — the median is equivariant under
  order-preserving **and** order-reversing reparametrisations of the sample.

The last pair is the structural content behind the empirical "7/8-median law"
of the NET-48 attention-cost thread: normalising knees by the product point
`P = d·ctx/32` is an order-preserving reparametrisation, while converting a
knee `k*` into a deployment speed-up `ctx / k*` is an order-*reversing* one.
Both leave the median where it is, so the median knee, the median ratio and the
median speed-up are the same statistic read in three coordinate systems.  The
extremes (min / max) do **not** have this property: order reversal swaps them
(`isLeast_map_of_isGreatest`), which is exactly why the "guaranteed"
speed-up is governed by the *largest* knee while the "median" speed-up is
governed by the median knee.
-/
import Mathlib

namespace Catalog.Tropical.KneeMedian

open Multiset

variable {α β : Type*} [LinearOrder α] [LinearOrder β]

/-! ## The counting characterisation of a median -/

/-- `IsMedian k s m` says that `m` is a median of a multiset `s` of odd size `2k+1`:
`m` occurs in `s`, at least `k+1` entries are `≤ m` and at least `k+1` entries are `≥ m`. -/
structure IsMedian (k : ℕ) (s : Multiset α) (m : α) : Prop where
  mem : m ∈ s
  lower : k + 1 ≤ card (s.filter (fun x => x ≤ m))
  upper : k + 1 ≤ card (s.filter (fun x => m ≤ x))

omit [LinearOrder α] in
/-- Two predicates that are never simultaneously true cut out disjoint parts of a
multiset, so their filtered cardinalities add up to at most the total. -/
theorem card_filter_add_card_filter_le (p q : α → Prop) [DecidablePred p] [DecidablePred q]
    (hpq : ∀ x, ¬(p x ∧ q x)) (s : Multiset α) :
    card (s.filter p) + card (s.filter q) ≤ card s := by
  induction s using Multiset.induction_on with
  | empty => simp
  | cons a s ih =>
      have hna := hpq a
      by_cases hp : p a
      · have hq : ¬ q a := fun h => hna ⟨hp, h⟩
        rw [Multiset.filter_cons_of_pos _ hp, Multiset.filter_cons_of_neg _ hq]
        simp only [Multiset.card_cons]
        omega
      · rw [Multiset.filter_cons_of_neg _ hp]
        by_cases hq : q a
        · rw [Multiset.filter_cons_of_pos _ hq]
          simp only [Multiset.card_cons]
          omega
        · rw [Multiset.filter_cons_of_neg _ hq]
          simp only [Multiset.card_cons]
          omega

/-- **Uniqueness of the median.**  A pigeonhole argument: if `m < m'` were two medians,
the `k+1` entries `≤ m` and the `k+1` entries `≥ m'` would be disjoint, forcing
`2k+2 ≤ 2k+1`. -/
theorem IsMedian.unique {k : ℕ} {s : Multiset α} {m m' : α} (hcard : card s = 2 * k + 1)
    (h : IsMedian k s m) (h' : IsMedian k s m') : m = m' := by
  by_contra hne
  rcases lt_or_gt_of_ne hne with hlt | hlt
  · have hdis := card_filter_add_card_filter_le (fun x => x ≤ m) (fun x => m' ≤ x)
      (fun x hx => absurd (hx.2.trans hx.1) (not_le.mpr hlt)) s
    have h1 := h.lower
    have h2 := h'.upper
    omega
  · have hdis := card_filter_add_card_filter_le (fun x => x ≤ m') (fun x => m ≤ x)
      (fun x hx => absurd (hx.2.trans hx.1) (not_le.mpr hlt)) s
    have h1 := h'.lower
    have h2 := h.upper
    omega

/-! ## Existence via the sorted representative -/

/-- In a sorted list, the first `i+1` entries are all `≤ l[i]`, hence at least `i+1`
entries pass the test `· ≤ l[i]`. -/
theorem le_length_filter_le_getElem {l : List α} (hl : l.Pairwise (· ≤ ·)) {i : ℕ}
    (hi : i < l.length) :
    i + 1 ≤ (l.filter (fun x => decide (x ≤ l[i]))).length := by
  have hsub : (l.take (i + 1)).Sublist l := List.take_sublist _ _
  have hall : ∀ x ∈ l.take (i + 1), decide (x ≤ l[i]) = true := by
    intro x hx
    obtain ⟨j, hj, hjx⟩ := List.getElem_of_mem hx
    rw [List.getElem_take] at hjx
    have hjlen : j < i + 1 := by
      rw [List.length_take] at hj; omega
    have hle : l[j] ≤ l[i] := by
      rcases eq_or_lt_of_le (Nat.lt_succ_iff.mp hjlen) with h | h
      · simp [h]
      · exact (List.pairwise_iff_getElem.mp hl) j i (by omega) hi h
    simp [← hjx, hle]
  have hfil : (l.take (i + 1)).filter (fun x => decide (x ≤ l[i])) = l.take (i + 1) :=
    List.filter_eq_self.mpr hall
  have hsl := hsub.filter (fun x => decide (x ≤ l[i]))
  have hlen : (l.take (i + 1)).length = i + 1 := by
    rw [List.length_take]; omega
  calc i + 1 = ((l.take (i + 1)).filter (fun x => decide (x ≤ l[i]))).length := by
        rw [hfil, hlen]
    _ ≤ _ := hsl.length_le

/-- In a sorted list of length `n`, the last `n - i` entries are all `≥ l[i]`, hence at least
`n - i` entries pass the test `l[i] ≤ ·`. -/
theorem le_length_filter_getElem_le {l : List α} (hl : l.Pairwise (· ≤ ·)) {i : ℕ}
    (hi : i < l.length) :
    l.length - i ≤ (l.filter (fun x => decide (l[i] ≤ x))).length := by
  have hsub : (l.drop i).Sublist l := List.drop_sublist _ _
  have hall : ∀ x ∈ l.drop i, decide (l[i] ≤ x) = true := by
    intro x hx
    obtain ⟨j, hj, hjx⟩ := List.getElem_of_mem hx
    rw [List.getElem_drop] at hjx
    have hij : i + j < l.length := by
      rw [List.length_drop] at hj; omega
    have hle : l[i] ≤ l[i + j] := by
      rcases Nat.eq_zero_or_pos j with h | h
      · simp [h]
      · exact (List.pairwise_iff_getElem.mp hl) i (i + j) hi hij (by omega)
    simp [← hjx, hle]
  have hfil : (l.drop i).filter (fun x => decide (l[i] ≤ x)) = l.drop i :=
    List.filter_eq_self.mpr hall
  have hsl := hsub.filter (fun x => decide (l[i] ≤ x))
  calc l.length - i = ((l.drop i).filter (fun x => decide (l[i] ≤ x))).length := by
        rw [hfil, List.length_drop]
    _ ≤ _ := hsl.length_le

/-- **Existence of the median**: every multiset of odd size `2k+1` has a (unique) median,
namely the entry of index `k` in its sorted representative. -/
theorem exists_isMedian {k : ℕ} {s : Multiset α} (hcard : card s = 2 * k + 1) :
    ∃ m, IsMedian k s m := by
  classical
  set l : List α := s.sort (· ≤ ·) with hl
  have hs : s = (l : Multiset α) := (Multiset.sort_eq s _).symm
  have hlen : l.length = 2 * k + 1 := by rw [hl, Multiset.length_sort, hcard]
  have hsorted : l.Pairwise (· ≤ ·) := Multiset.pairwise_sort s _
  have hk : k < l.length := by omega
  refine ⟨l[k], ?_, ?_, ?_⟩
  · rw [hs]; exact Multiset.mem_coe.mpr (List.getElem_mem hk)
  · have h := le_length_filter_le_getElem hsorted hk
    rw [hs]
    simpa [Multiset.filter_coe] using h
  · have h := le_length_filter_getElem_le hsorted hk
    rw [hs]
    simp only [Multiset.filter_coe, Multiset.coe_card]
    omega

/-! ## Equivariance -/

omit [LinearOrder α] [LinearOrder β] in
/-- Cardinality of a filtered image: filtering after mapping equals mapping after filtering
by the pulled-back predicate. -/
theorem card_filter_map (f : α → β) (p : β → Prop) [DecidablePred p] (s : Multiset α) :
    card ((s.map f).filter p) = card (s.filter (fun x => p (f x))) := by
  classical
  induction s using Multiset.induction_on with
  | empty => simp
  | cons a s ih =>
      by_cases h : p (f a) <;> simp [h, ih]

/-- **Monotone equivariance.**  If `f` preserves the order of the entries of `s`, then it maps
the median of `s` to the median of the image sample.  (Only the order relation *on the sample*
matters, so this covers e.g. `x ↦ x / P` on positive data.) -/
theorem IsMedian.map_mono {k : ℕ} {s : Multiset α} {m : α} (f : α → β)
    (hf : ∀ x ∈ s, ∀ y ∈ s, (f x ≤ f y ↔ x ≤ y)) (h : IsMedian k s m) :
    IsMedian k (s.map f) (f m) := by
  classical
  refine ⟨Multiset.mem_map_of_mem f h.mem, ?_, ?_⟩
  · rw [card_filter_map]
    have he : s.filter (fun x => f x ≤ f m) = s.filter (fun x => x ≤ m) :=
      Multiset.filter_congr (fun x hx => by simpa using hf x hx m h.mem)
    rw [he]; exact h.lower
  · rw [card_filter_map]
    have he : s.filter (fun x => f m ≤ f x) = s.filter (fun x => m ≤ x) :=
      Multiset.filter_congr (fun x hx => by simpa using hf m h.mem x hx)
    rw [he]; exact h.upper

/-- **Order-reversal equivariance.**  If `f` *reverses* the order of the entries of `s`, it still
maps the median to the median: the two defining inequalities simply trade places.  This is the
theorem that makes `k* ↦ ctx / k*` (speed-up) median-preserving. -/
theorem IsMedian.map_anti {k : ℕ} {s : Multiset α} {m : α} (f : α → β)
    (hf : ∀ x ∈ s, ∀ y ∈ s, (f x ≤ f y ↔ y ≤ x)) (h : IsMedian k s m) :
    IsMedian k (s.map f) (f m) := by
  classical
  refine ⟨Multiset.mem_map_of_mem f h.mem, ?_, ?_⟩
  · rw [card_filter_map]
    have he : s.filter (fun x => f x ≤ f m) = s.filter (fun x => m ≤ x) :=
      Multiset.filter_congr (fun x hx => by simpa using hf x hx m h.mem)
    rw [he]; exact h.upper
  · rw [card_filter_map]
    have he : s.filter (fun x => f m ≤ f x) = s.filter (fun x => x ≤ m) :=
      Multiset.filter_congr (fun x hx => by simpa using hf m h.mem x hx)
    rw [he]; exact h.lower

/-! ## The extremes are *not* order-reversal equivariant -/

/-- Under an order-reversing reparametrisation the **largest** entry becomes the smallest one.
So the minimum of the transformed sample is the image of the maximum, never of the minimum
(unless the sample is constant).  This is the precise sense in which the median is the only
one of the three summary statistics `{min, med, max}` that survives the change of coordinates
`knee ↦ speed-up`. -/
theorem isLeast_map_of_isGreatest {s : Multiset α} {M : α} (f : α → β)
    (hf : ∀ x ∈ s, ∀ y ∈ s, (f x ≤ f y ↔ y ≤ x)) (hM : M ∈ s) (hgr : ∀ x ∈ s, x ≤ M) :
    f M ∈ s.map f ∧ ∀ z ∈ s.map f, f M ≤ z := by
  refine ⟨Multiset.mem_map_of_mem f hM, ?_⟩
  rintro z hz
  obtain ⟨x, hx, rfl⟩ := Multiset.mem_map.mp hz
  exact (hf M hM x hx).mpr (hgr x hx)

end Catalog.Tropical.KneeMedian