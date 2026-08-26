import Physics.StackSquareCorePartitions

/-!
# Stack polyominoes with a square core: the combinatorial model

This file justifies the arithmetic definition `Physics.StackSquareCore.stackSC` of
`Physics.StackSquareCoreBasic` by exhibiting the objects it counts.

A stack polyomino is recorded by its list of column heights `L`.  It is a genuine
bottom-justified column-convex polyomino with a square core exactly when

* every column is nonempty (`∀ x ∈ L, 1 ≤ x`),
* `L` is **unimodal**: it splits as a weakly increasing part followed by a weakly
  decreasing part (`Unimodal L`), and
* the maximal height `k = maxH L` occurs exactly `k` times, so the top plateau is a
  `k × k` square (`L.count (maxH L) = maxH L`).

The predicate is `IsSquareCoreStack`.  The main results are

* `mem_squareCoreStacks_iff` : the explicit finite set `squareCoreStacks n` consists exactly of the
  square-core stacks of area `n`;
* `card_squareCoreStacks` : `#(squareCoreStacks n) = stackSC n`.

Combined with `Physics.StackSquareCoreBasic`, this shows that the sequence
`1,1,0,0,1,2,3,4,5,7,9,13,…` really enumerates square-core stack polyominoes by area, and
transfers all the growth theorems proved there to the combinatorial objects.
-/

namespace Physics.StackSquareCore

open Finset

/-! ## The maximum of a list -/

/-- The largest entry of a list of naturals (`0` for the empty list). -/
def maxH (L : List ℕ) : ℕ := L.foldr max 0

@[simp] lemma maxH_nil : maxH [] = 0 := rfl

@[simp] lemma maxH_cons (a : ℕ) (L : List ℕ) : maxH (a :: L) = max a (maxH L) := rfl

lemma maxH_append (A B : List ℕ) : maxH (A ++ B) = max (maxH A) (maxH B) := by
  induction A with
  | nil => simp
  | cons a t ih => simp [ih, max_assoc]

lemma mem_le_maxH {x : ℕ} {L : List ℕ} (h : x ∈ L) : x ≤ maxH L := by
  induction L with
  | nil => simp at h
  | cons a t ih =>
    rcases List.mem_cons.1 h with rfl | h'
    · simp
    · exact le_trans (ih h') (by simp)

lemma maxH_le {c : ℕ} {L : List ℕ} (h : ∀ x ∈ L, x ≤ c) : maxH L ≤ c := by
  induction L with
  | nil => simp
  | cons a t ih =>
    simp only [maxH_cons, max_le_iff]
    exact ⟨h a (by simp), ih (fun x hx => h x (by simp [hx]))⟩

lemma maxH_replicate (k c : ℕ) (hk : 1 ≤ k) : maxH (List.replicate k c) = c := by
  induction k with
  | zero => omega
  | succ k ih =>
    rcases Nat.eq_zero_or_pos k with rfl | hk' 
    · simp [List.replicate]
    · rw [List.replicate_succ, maxH_cons, ih hk']; simp

/-- Cancellation around a separator element that occurs in neither prefix. -/
lemma append_cons_inj {α : Type*} [DecidableEq α] {a : α} {A B A' B' : List α}
    (hA : a ∉ A) (hA' : a ∉ A') (h : A ++ a :: B = A' ++ a :: B') : A = A' ∧ B = B' := by
  induction A generalizing A' with
  | nil =>
    cases A' with
    | nil => simpa using h
    | cons x t =>
      exfalso
      simp only [List.nil_append, List.cons_append, List.cons.injEq] at h
      exact hA' (h.1 ▸ List.mem_cons_self ..)
  | cons x t ih =>
    cases A' with
    | nil =>
      exfalso
      simp only [List.nil_append, List.cons_append, List.cons.injEq] at h
      exact hA (h.1 ▸ List.mem_cons_self ..)
    | cons y s =>
      simp only [List.cons_append, List.cons.injEq] at h
      obtain ⟨rfl, h2⟩ := h
      have := ih (fun hx => hA (by simp [hx])) (fun hx => hA' (by simp [hx])) h2
      exact ⟨by simp [this.1], this.2⟩

/-- Mirror image of `sorted_ge_split` for weakly increasing lists. -/
lemma sorted_le_split (b : ℕ) (L : List ℕ) (hs : L.Pairwise (· ≤ ·)) (hb : ∀ x ∈ L, x ≤ b + 1) :
    ∃ c A, L = A ++ List.replicate c (b + 1) ∧ (∀ x ∈ A, x ≤ b) ∧ A.Pairwise (· ≤ ·) := by
  have hrev : L.reverse.Pairwise (· ≥ ·) := by rw [List.pairwise_reverse]; exact hs
  obtain ⟨c, L', hL, h1, h2⟩ := sorted_ge_split b L.reverse hrev
    (fun x hx => hb x (List.mem_reverse.1 hx))
  refine ⟨c, L'.reverse, ?_, ?_, ?_⟩
  · have := congrArg List.reverse hL
    simpa [List.reverse_append, List.reverse_replicate] using this
  · intro x hx; exact h1 x (List.mem_reverse.1 hx)
  · rw [List.pairwise_reverse]; exact h2

/-! ## Square-core stacks -/

/-- A list is unimodal when it weakly increases and then weakly decreases. -/
def Unimodal (L : List ℕ) : Prop :=
  ∃ p s, L = p ++ s ∧ p.Pairwise (· ≤ ·) ∧ s.Pairwise (· ≥ ·)

/-- The column-height list of a stack polyomino whose core is a square: all columns are
nonempty, the profile is unimodal, and the maximal height `k` is attained exactly `k`
times. -/
def IsSquareCoreStack (L : List ℕ) : Prop :=
  (∀ x ∈ L, 1 ≤ x) ∧ Unimodal L ∧ L.count (maxH L) = maxH L

/-- The column-height list built from a `k × k` core with slopes `l` (left) and `r`
(right), both recorded as weakly decreasing partitions read from the outside inwards. -/
def stackList (k : ℕ) (l r : List ℕ) : List ℕ := l.reverse ++ List.replicate k k ++ r

lemma stackList_maxH (k : ℕ) (l r : List ℕ) (hk : 1 ≤ k) (hl : ∀ x ∈ l, x < k)
    (hr : ∀ x ∈ r, x < k) : maxH (stackList k l r) = k := by
  rw [stackList, maxH_append, maxH_append, maxH_replicate k k hk]
  have h1 : maxH l.reverse ≤ k := maxH_le (fun x hx => le_of_lt (hl x (List.mem_reverse.1 hx)))
  have h2 : maxH r ≤ k := maxH_le (fun x hx => le_of_lt (hr x hx))
  omega

lemma stackList_count (k : ℕ) (l r : List ℕ) (hl : ∀ x ∈ l, x < k) (hr : ∀ x ∈ r, x < k) :
    (stackList k l r).count k = k := by
  have hnl : k ∉ l.reverse := fun h => by have := hl k (List.mem_reverse.1 h); omega
  have hnr : k ∉ r := fun h => by have := hr k h; omega
  rw [stackList, List.count_append, List.count_append, List.count_replicate_self,
    List.count_eq_zero_of_not_mem hnl, List.count_eq_zero_of_not_mem hnr]
  omega

lemma stackList_sum (k : ℕ) (l r : List ℕ) :
    (stackList k l r).sum = l.sum + k * k + r.sum := by
  rw [stackList, List.sum_append, List.sum_append, List.sum_replicate, List.sum_reverse,
    smul_eq_mul]

lemma stackList_zero (l r : List ℕ) (hl : ∀ x ∈ l, 1 ≤ x ∧ x ≤ 0) (hr : ∀ x ∈ r, 1 ≤ x ∧ x ≤ 0) :
    stackList 0 l r = [] := by
  have hl0 : l = [] := List.eq_nil_iff_forall_not_mem.2 (fun x hx => by have := hl x hx; omega)
  have hr0 : r = [] := List.eq_nil_iff_forall_not_mem.2 (fun x hx => by have := hr x hx; omega)
  simp [stackList, hl0, hr0]

/-- Every list produced by the core decomposition is a square-core stack. -/
theorem isStack_stackList (k : ℕ) (l r : List ℕ)
    (hl : ∀ x ∈ l, 1 ≤ x ∧ x ≤ k - 1) (hr : ∀ x ∈ r, 1 ≤ x ∧ x ≤ k - 1)
    (hlp : l.Pairwise (· ≥ ·)) (hrp : r.Pairwise (· ≥ ·)) :
    IsSquareCoreStack (stackList k l r) := by
  rcases Nat.eq_zero_or_pos k with rfl | hk
  · rw [stackList_zero l r (by simpa using hl) (by simpa using hr)]
    exact ⟨by simp, ⟨[], [], by simp, by simp, by simp⟩, by simp⟩
  · have hl' : ∀ x ∈ l, x < k := fun x hx => by have := hl x hx; omega
    have hr' : ∀ x ∈ r, x < k := fun x hx => by have := hr x hx; omega
    refine ⟨?_, ?_, ?_⟩
    · intro x hx
      rw [stackList] at hx
      rcases List.mem_append.1 hx with hx' | hx'
      · rcases List.mem_append.1 hx' with hx'' | hx''
        · exact (hl x (List.mem_reverse.1 hx'')).1
        · have := List.eq_of_mem_replicate hx''; omega
      · exact (hr x hx').1
    · refine ⟨l.reverse ++ List.replicate k k, r, by rw [stackList], ?_, hrp⟩
      rw [List.pairwise_append]
      refine ⟨by rw [List.pairwise_reverse]; exact hlp,
        List.pairwise_replicate.2 (Or.inr (le_refl _)), ?_⟩
      intro a ha b hb
      have h1 := hl' a (List.mem_reverse.1 ha)
      have h2 := List.eq_of_mem_replicate hb
      omega
    · rw [stackList_maxH k l r hk hl' hr', stackList_count k l r hl' hr']

/-- **Every square-core stack decomposes along its core.** -/
theorem exists_stackList_of_isStack {L : List ℕ} (h : IsSquareCoreStack L) :
    ∃ k l r, L = stackList k l r ∧ k = maxH L ∧
      (∀ x ∈ l, 1 ≤ x ∧ x < k) ∧ (∀ x ∈ r, 1 ≤ x ∧ x < k) ∧
      l.Pairwise (· ≥ ·) ∧ r.Pairwise (· ≥ ·) := by
  obtain ⟨hpos, ⟨p, s, hL, hp, hs⟩, hcount⟩ := h
  subst hL
  set k := maxH (p ++ s) with hk
  rcases Nat.eq_zero_or_pos k with hk0 | hk1
  · have hnil : p ++ s = [] := by
      rcases he : (p ++ s) with _ | ⟨a, t⟩
      · rfl
      · exfalso
        have h1 : 1 ≤ a := hpos a (by rw [he]; simp)
        have h2 : a ≤ k := by rw [hk]; exact mem_le_maxH (by rw [he]; simp)
        omega
    refine ⟨0, [], [], ?_, ?_, by simp, by simp, by simp, by simp⟩
    · rw [hnil]; simp [stackList]
    · rw [hk, hnil]; simp [maxH]
  · obtain ⟨j, hj⟩ : ∃ j, k = j + 1 := ⟨k - 1, by omega⟩
    have hbp : ∀ x ∈ p, x ≤ j + 1 := fun x hx => by
      rw [← hj, hk]; exact mem_le_maxH (List.mem_append.2 (Or.inl hx))
    have hbs : ∀ x ∈ s, x ≤ j + 1 := fun x hx => by
      rw [← hj, hk]; exact mem_le_maxH (List.mem_append.2 (Or.inr hx))
    obtain ⟨a, A, hA, hA1, hA2⟩ := sorted_le_split j p hp hbp
    obtain ⟨b, B, hB, hB1, hB2⟩ := sorted_ge_split j s hs hbs
    have hnA : (j + 1) ∉ A := fun hx => by have := hA1 _ hx; omega
    have hnB : (j + 1) ∉ B := fun hx => by have := hB1 _ hx; omega
    have hcnt : (p ++ s).count k = a + b := by
      rw [hA, hB, hj]
      simp [List.count_append, List.count_replicate_self,
        List.count_eq_zero_of_not_mem hnA, List.count_eq_zero_of_not_mem hnB]
    have hab : a + b = k := by rw [← hcnt]; exact hcount
    have hsplit : p ++ s = A ++ List.replicate k k ++ B := by
      rw [hA, hB]
      have hrep : List.replicate a (j + 1) ++ (List.replicate b (j + 1) ++ B)
          = List.replicate k k ++ B := by
        rw [← List.append_assoc, ← List.replicate_add, hab, ← hj]
      calc A ++ List.replicate a (j + 1) ++ (List.replicate b (j + 1) ++ B)
          = A ++ (List.replicate a (j + 1) ++ (List.replicate b (j + 1) ++ B)) := by
            rw [List.append_assoc]
        _ = A ++ (List.replicate k k ++ B) := by rw [hrep]
        _ = A ++ List.replicate k k ++ B := by rw [List.append_assoc]
    refine ⟨k, A.reverse, B, ?_, rfl, ?_, ?_, ?_, hB2⟩
    · rw [hsplit, stackList, List.reverse_reverse]
    · intro x hx
      have hxA : x ∈ A := List.mem_reverse.1 hx
      refine ⟨hpos x ?_, ?_⟩
      · rw [hA]; exact List.mem_append.2 (Or.inl (List.mem_append.2 (Or.inl hxA)))
      · have := hA1 x hxA; omega
    · intro x hx
      refine ⟨hpos x ?_, ?_⟩
      · rw [hB]; exact List.mem_append.2 (Or.inr (List.mem_append.2 (Or.inr hx)))
      · have := hB1 x hx; omega
    · rw [List.pairwise_reverse]; exact hA2

lemma stackList_inj_aux {j : ℕ} {l r l' r' : List ℕ}
    (hl : ∀ x ∈ l, x < j + 1) (hl' : ∀ x ∈ l', x < j + 1)
    (h : stackList (j + 1) l r = stackList (j + 1) l' r') : l = l' ∧ r = r' := by
  rw [stackList, stackList, List.replicate_succ] at h
  simp only [List.append_assoc, List.cons_append] at h
  have hnl : (j + 1) ∉ l.reverse := fun hx => by have := hl _ (List.mem_reverse.1 hx); omega
  have hnl' : (j + 1) ∉ l'.reverse := fun hx => by have := hl' _ (List.mem_reverse.1 hx); omega
  obtain ⟨h1, h2⟩ := append_cons_inj hnl hnl' h
  exact ⟨List.reverse_injective h1, List.append_cancel_left h2⟩

/-- **The core decomposition is unique.** -/
lemma stackList_inj {k k' : ℕ} {l r l' r' : List ℕ}
    (hl : ∀ x ∈ l, 1 ≤ x ∧ x ≤ k - 1) (hr : ∀ x ∈ r, 1 ≤ x ∧ x ≤ k - 1)
    (hl' : ∀ x ∈ l', 1 ≤ x ∧ x ≤ k' - 1) (hr' : ∀ x ∈ r', 1 ≤ x ∧ x ≤ k' - 1)
    (h : stackList k l r = stackList k' l' r') : k = k' ∧ l = l' ∧ r = r' := by
  have hkey : ∀ (a : ℕ) (u v : List ℕ), (∀ x ∈ u, 1 ≤ x ∧ x ≤ a - 1) →
      (∀ x ∈ v, 1 ≤ x ∧ x ≤ a - 1) → 1 ≤ a → maxH (stackList a u v) = a := by
    intro a u v hu hv ha
    exact stackList_maxH a u v ha (fun x hx => by have := hu x hx; omega)
      (fun x hx => by have := hv x hx; omega)
  rcases Nat.eq_zero_or_pos k with rfl | hk
  · have hnil : stackList 0 l r = [] := stackList_zero l r (by simpa using hl) (by simpa using hr)
    have hk'0 : k' = 0 := by
      by_contra hne
      have h1 : 1 ≤ k' := by omega
      have h2 := hkey k' l' r' hl' hr' h1
      rw [← h, hnil] at h2
      simp at h2
      omega
    subst hk'0
    have hl0 : l = [] := List.eq_nil_iff_forall_not_mem.2 (fun x hx => by have := hl x hx; omega)
    have hr0 : r = [] := List.eq_nil_iff_forall_not_mem.2 (fun x hx => by have := hr x hx; omega)
    have hl0' : l' = [] := List.eq_nil_iff_forall_not_mem.2 (fun x hx => by have := hl' x hx; omega)
    have hr0' : r' = [] := List.eq_nil_iff_forall_not_mem.2 (fun x hx => by have := hr' x hx; omega)
    exact ⟨rfl, by rw [hl0, hl0'], by rw [hr0, hr0']⟩
  · rcases Nat.eq_zero_or_pos k' with rfl | hk'
    · exfalso
      have hnil : stackList 0 l' r' = [] :=
        stackList_zero l' r' (by simpa using hl') (by simpa using hr')
      have h2 := hkey k l r hl hr hk
      rw [h, hnil] at h2
      simp at h2
      omega
    · have hkk : k = k' := by
        have h1 := hkey k l r hl hr hk
        have h2 := hkey k' l' r' hl' hr' hk'
        rw [h] at h1
        omega
      subst hkk
      obtain ⟨j, rfl⟩ : ∃ j, k = j + 1 := ⟨k - 1, by omega⟩
      obtain ⟨e1, e2⟩ := stackList_inj_aux (l := l) (r := r) (l' := l') (r' := r')
        (fun x hx => by have := hl x hx; omega) (fun x hx => by have := hl' x hx; omega) h
      exact ⟨rfl, e1, e2⟩

/-! ## The finite set of square-core stacks of a given area -/

/-- All square-core stack polyominoes of area `n`, listed by column heights. -/
def squareCoreStacks (n : ℕ) : Finset (List ℕ) :=
  (range (n + 1)).biUnion (fun k =>
    if k * k ≤ n then
      (range (n - k * k + 1)).biUnion (fun j =>
        ((partsList (k - 1) j) ×ˢ (partsList (k - 1) (n - k * k - j))).image
          (fun p => stackList k p.1 p.2))
    else ∅)

/-- **`squareCoreStacks n` is exactly the set of square-core stacks of area `n`.** -/
theorem mem_squareCoreStacks_iff (n : ℕ) (L : List ℕ) :
    L ∈ squareCoreStacks n ↔ IsSquareCoreStack L ∧ L.sum = n := by
  rw [squareCoreStacks]
  simp only [Finset.mem_biUnion, Finset.mem_range]
  constructor
  · rintro ⟨k, hk, hmem⟩
    split_ifs at hmem with hkn
    · simp only [Finset.mem_biUnion, Finset.mem_range, Finset.mem_image, Finset.mem_product] at hmem
      obtain ⟨j, hj, ⟨l, r⟩, ⟨hlm, hrm⟩, rfl⟩ := hmem
      rw [mem_partsList_iff] at hlm hrm
      obtain ⟨hlp, hlb, hls⟩ := hlm
      obtain ⟨hrp, hrb, hrs⟩ := hrm
      refine ⟨isStack_stackList k l r hlb hrb hlp hrp, ?_⟩
      rw [stackList_sum, hls, hrs]
      omega
    · simp at hmem
  · rintro ⟨hstack, hsum⟩
    obtain ⟨k, l, r, rfl, _, hl, hr, hlp, hrp⟩ := exists_stackList_of_isStack hstack
    rw [stackList_sum] at hsum
    have hkk : k * k ≤ n := by omega
    have hkn : k ≤ n := by nlinarith
    refine ⟨k, by omega, ?_⟩
    rw [if_pos hkk]
    simp only [Finset.mem_biUnion, Finset.mem_range, Finset.mem_image, Finset.mem_product]
    refine ⟨l.sum, by omega, (l, r), ⟨?_, ?_⟩, rfl⟩
    · rw [mem_partsList_iff]
      exact ⟨hlp, fun x hx => ⟨(hl x hx).1, by have := (hl x hx).2; omega⟩, rfl⟩
    · rw [mem_partsList_iff]
      refine ⟨hrp, fun x hx => ⟨(hr x hx).1, by have := (hr x hx).2; omega⟩, ?_⟩
      show r.sum = n - k * k - l.sum
      omega

/-- **The counting function is correct**: `stackSC n` is the number of square-core stack
polyominoes of area `n`. -/
theorem card_squareCoreStacks (n : ℕ) : (squareCoreStacks n).card = stackSC n := by
  have hinj : ∀ (k j : ℕ), Set.InjOn (fun p : List ℕ × List ℕ => stackList k p.1 p.2)
      ((partsList (k - 1) j) ×ˢ (partsList (k - 1) (n - k * k - j)) : Finset (List ℕ × List ℕ)) := by
    rintro k j ⟨l, r⟩ hp ⟨l', r'⟩ hp' heq
    rw [Finset.mem_coe, Finset.mem_product] at hp hp'
    simp only [mem_partsList_iff] at hp hp'
    obtain ⟨⟨_, hlb, _⟩, ⟨_, hrb, _⟩⟩ := hp
    obtain ⟨⟨_, hlb', _⟩, ⟨_, hrb', _⟩⟩ := hp'
    obtain ⟨_, e1, e2⟩ := stackList_inj hlb hrb hlb' hrb' heq
    simp [e1, e2]
  rw [squareCoreStacks, stackSC, Finset.card_biUnion]
  · refine Finset.sum_congr rfl (fun k _ => ?_)
    by_cases hkn : k * k ≤ n
    · rw [if_pos hkn, if_pos hkn, conv, Finset.card_biUnion]
      · refine Finset.sum_congr rfl (fun j _ => ?_)
        rw [Finset.card_image_of_injOn (hinj k j), Finset.card_product,
          card_partsList, card_partsList]
      · -- distinct left areas give distinct stacks
        intro j _ j' _ hne
        simp only [Finset.disjoint_left, Finset.mem_image, Finset.mem_product]
        rintro L ⟨⟨l, r⟩, hpm, rfl⟩ ⟨⟨l', r'⟩, hpm', heq⟩
        obtain ⟨hlm, hrm⟩ := hpm
        obtain ⟨hlm', hrm'⟩ := hpm'
        rw [mem_partsList_iff] at hlm hrm hlm' hrm'
        obtain ⟨_, e1, _⟩ := stackList_inj hlm.2.1 hrm.2.1 hlm'.2.1 hrm'.2.1 heq.symm
        exact hne (by rw [← hlm.2.2, e1, hlm'.2.2])
    · rw [if_neg hkn, if_neg hkn]
      simp
  · -- distinct cores give distinct stacks
    intro k _ k' _ hne
    simp only [Finset.disjoint_left]
    intro L hL hL'
    split_ifs at hL hL' with h1 h2 h3
    · simp only [Finset.mem_biUnion, Finset.mem_range, Finset.mem_image, Finset.mem_product]
        at hL hL'
      obtain ⟨j, _, ⟨l, r⟩, hpm, rfl⟩ := hL
      obtain ⟨j', _, ⟨l', r'⟩, hpm', heq⟩ := hL'
      obtain ⟨hlm, hrm⟩ := hpm
      obtain ⟨hlm', hrm'⟩ := hpm'
      rw [mem_partsList_iff] at hlm hrm hlm' hrm'
      obtain ⟨e0, _, _⟩ := stackList_inj hlm.2.1 hrm.2.1 hlm'.2.1 hrm'.2.1 heq.symm
      exact hne e0
    · simp at hL'
    · simp at hL
    · simp at hL

/-! ## Consequences for the polyominoes themselves -/

/-- The catalogued sequence enumerates square-core stack polyominoes by area. -/
theorem squareCoreStacks_card_table :
    (List.range 32).map (fun n => (squareCoreStacks n).card) =
      [1, 1, 0, 0, 1, 2, 3, 4, 5, 7, 9, 13, 17, 24, 31, 42, 54, 71, 90, 117, 147, 188,
        236, 298, 371, 466, 576, 716, 882, 1088, 1331, 1633] := by
  simpa [card_squareCoreStacks] using stackSC_table

/-- There is no square-core stack of area `2` or `3`, and these are the only such areas. -/
theorem squareCoreStacks_eq_empty_iff (n : ℕ) : squareCoreStacks n = ∅ ↔ n = 2 ∨ n = 3 := by
  rw [← Finset.card_eq_zero, card_squareCoreStacks, stackSC_eq_zero_iff]

/-- Stretched-exponential growth, stated for the polyominoes. -/
theorem two_pow_le_card_squareCoreStacks (m n : ℕ) (h : 3 * m * m + 11 * m + 8 ≤ 2 * n) :
    2 ^ m ≤ (squareCoreStacks n).card := by
  rw [card_squareCoreStacks]; exact two_pow_le_stackSC m n h

end Physics.StackSquareCore