/-
# A refined upper bound: `d(H_{p^3}) ≤ 2p(p-1)`

The line bound of `Algebra.Heisenberg125.LineBound` caps each of the `p + 1`
direction classes at `2p - 2`.  Here we show that at most `p - 1` classes can be
"large" (of size `≥ p`), which improves the bound to

  `d(H_{p^3}) ≤ (p-1)(2p-2) + 2(p-1) = 2p(p-1)`,

in particular `d(H_125) ≤ 40`.

The mechanism combines all three tools of this development:

* inside a direction class the *chart* of `LineBound` linearises the group law,
  so a class of size `≥ p` contains a nonempty consecutive block whose chart
  first coordinate sums to zero — such a block has **central product**;
* blocks taken from different classes are disjoint sub-multisets of the
  sequence;
* `p` disjoint central blocks force a product-one subsequence, by the
  quotient criterion `Heis.exists_productOne_of_central_blocks`.
-/
import Algebra.Heisenberg125.LineBound
import Algebra.Heisenberg125.BlockCriterion

namespace Heisenberg125

namespace Heis

variable {p : ℕ}

/-! ### A consecutive block with vanishing statistic -/

/-- Pigeonhole on prefix sums: any list of length at least `p` has a nonempty
consecutive block on which a given `ZMod p`-valued statistic sums to zero. -/
lemma exists_consecutive_block_sum_zero [NeZero p] {α : Type*} (f : α → ZMod p)
    (C : List α) (hlen : p ≤ C.length) :
    ∃ i j : ℕ, i < j ∧ j ≤ C.length ∧ ((((C.take j).drop i).map f).sum = 0) := by
  classical
  have hkey : ∀ k l : ℕ, k < l → l ≤ C.length →
      ((C.take k).map f).sum = ((C.take l).map f).sum →
      ((((C.take l).drop k).map f).sum = 0) := by
    intro k l hlt _ heq
    have htake : (C.take l).take k = C.take k := by
      rw [List.take_take, Nat.min_eq_left hlt.le]
    have hsplit : ((((C.take l).take k)).map f).sum + (((C.take l).drop k).map f).sum
        = ((C.take l).map f).sum := by
      rw [← List.sum_append, ← List.map_append, List.take_append_drop]
    rw [htake, heq] at hsplit
    linear_combination hsplit
  obtain ⟨i, hi, j, hj, hij, hval⟩ :=
    Finset.exists_ne_map_eq_of_card_lt_of_maps_to
      (s := Finset.range (p + 1)) (t := (Finset.univ : Finset (ZMod p)))
      (by simp [ZMod.card]) (fun k _ => Finset.mem_univ (((C.take k).map f).sum))
  simp only [Finset.mem_range] at hi hj
  rcases lt_or_gt_of_ne hij with hlt | hlt
  · exact ⟨i, j, hlt, by omega, hkey i j hlt (by omega) hval⟩
  · exact ⟨j, i, hlt, by omega, hkey j i hlt (by omega) hval.symm⟩

/-! ### Large direction classes contain a central block -/

section Prime

variable [Fact p.Prime]

/-- A direction class of size at least `p` contains a nonempty consecutive block
whose product is central. -/
theorem exists_central_block_of_dir {d : Option (ZMod p)} {C : List (Heis p)}
    (hdir : ∀ g ∈ C, dirOf g = d) (hlen : p ≤ C.length) :
    ∃ B : List (Heis p), B.Sublist C ∧ B ≠ [] ∧ (B.prod).a = 0 ∧ (B.prod).b = 0 := by
  haveI : NeZero p := ⟨(Fact.out : p.Prime).ne_zero⟩
  obtain ⟨i, j, hij, hjle, hsum⟩ := exists_consecutive_block_sum_zero (coord1 d) C hlen
  set B : List (Heis p) := (C.take j).drop i with hB
  have hBsub : B.Sublist C := (List.drop_sublist _ _).trans (List.take_sublist _ _)
  have hBdir : ∀ g ∈ B, dirOf g = d := fun g hg => hdir g (hBsub.mem hg)
  have hBne : B ≠ [] := by
    intro hc
    have hlen' : B.length = j - i := by
      simp [hB, List.length_drop, List.length_take, Nat.min_eq_left hjle]
    rw [hc] at hlen'
    simp only [List.length_nil] at hlen'
    omega
  have hcentral : asum B = 0 ∧ bsum B = 0 := by
    cases d with
    | none =>
        have hazero : ∀ g ∈ B, g.a = 0 := fun g hg => a_eq_zero_of_dir_none (hBdir g hg)
        refine ⟨by rw [asum_of_const (α := 0) hazero]; ring, ?_⟩
        rw [← sum_coord1_none]
        exact hsum
    | some m =>
        have hline : ∀ g ∈ B, g.b = m * g.a := fun g hg => b_eq_mul_of_dir_some (hBdir g hg)
        have ha : asum B = 0 := by rw [← sum_coord1_some m]; exact hsum
        exact ⟨ha, by rw [bsum_eq_mul_asum hline, ha, mul_zero]⟩
  refine ⟨B, hBsub, hBne, ?_, ?_⟩
  · rw [prod_eq]; exact hcentral.1
  · rw [prod_eq]; exact hcentral.2

end Prime

/-! ### Disjointness bookkeeping -/

/-- The multiset of a concatenation is the sum of the multisets. -/
lemma coe_flatten {α : Type*} (Ls : List (List α)) :
    (Ls.flatten : Multiset α) = (Ls.map (fun l => Multiset.ofList l)).sum := by
  induction Ls with
  | nil => rfl
  | cons l Ls ih => rw [List.flatten_cons, List.map_cons, List.sum_cons, ← ih, ← Multiset.coe_add]

/-- Filtering a list by the fibres of a map into a finite type partitions it:
the multisets of the fibres sum to the multiset of the list. -/
lemma sum_coe_filter_fiber {α β : Type*} [Fintype β] [DecidableEq β] (f : α → β) (L : List α) :
    ∑ b : β, ((L.filter (fun g => decide (f g = b)) : List α) : Multiset α) = (L : Multiset α) := by
  induction L with
  | nil => simp
  | cons g L ih =>
      have hstep : ∀ b : β, (((g :: L).filter (fun x => decide (f x = b)) : List α) : Multiset α)
          = (if f g = b then {g} else 0)
            + ((L.filter (fun x => decide (f x = b)) : List α) : Multiset α) := by
        intro b
        by_cases h : f g = b <;> simp [h]
      simp only [hstep]
      rw [Finset.sum_add_distrib, ih]
      simp

end Heis

/-- Product-one-freeness passes to sub-multisets. -/
lemma ProductOneFree.subperm {G : Type*} [Group G] {L T : List G} (h : ProductOneFree L)
    (hT : T.Subperm L) (hne : T ≠ []) : ¬ IsProductOne T := by
  obtain ⟨T', hT'perm, hT'sub⟩ := hT
  refine fun hone => h T' hT'sub ?_ (hone.perm hT'perm.symm)
  intro hc
  exact hne (hc ▸ hT'perm.symm).eq_nil

namespace Heis

variable {p : ℕ}

section Prime

variable [Fact p.Prime]

/-! ### At most `p - 1` direction classes are large -/

/-- **Spread bound on direction classes.**  For a product-one-free sequence `L`
over `Heis p`, fewer than `p` of the `p + 1` direction classes can have size at
least `p`.

Indeed each large class contains a nonempty block with central product, these
blocks are pairwise disjoint sub-multisets of `L`, and `p` disjoint central
blocks force a product-one subsequence. -/
theorem card_large_dirs_lt {L : List (Heis p)} (hfree : ProductOneFree L) :
    ({d : Option (ZMod p) |
        p ≤ (L.filter (fun g => decide (dirOf g = d))).length} : Finset _).card < p := by
  classical
  haveI : NeZero p := ⟨(Fact.out : p.Prime).ne_zero⟩
  set C : Option (ZMod p) → List (Heis p) :=
    fun d => L.filter (fun g => decide (dirOf g = d)) with hC
  set S : Finset (Option (ZMod p)) :=
    Finset.univ.filter (fun d => p ≤ (C d).length) with hS
  show S.card < p
  by_contra hcard
  push_neg at hcard
  have hdirC : ∀ (d : Option (ZMod p)), ∀ g ∈ C d, dirOf g = d := by
    intro d g hg
    simpa using List.of_mem_filter hg
  have hex : ∀ d : Option (ZMod p), ∃ B : List (Heis p),
      B.Sublist (C d) ∧ (p ≤ (C d).length → B ≠ [] ∧ (B.prod).a = 0 ∧ (B.prod).b = 0) := by
    intro d
    by_cases hlen : p ≤ (C d).length
    · obtain ⟨B, hB1, hB2, hB3, hB4⟩ := exists_central_block_of_dir (hdirC d) hlen
      exact ⟨B, hB1, fun _ => ⟨hB2, hB3, hB4⟩⟩
    · exact ⟨[], List.nil_sublist _, fun h => absurd h hlen⟩
  choose B hBsub hBprop using hex
  set Bs : List (List (Heis p)) := S.toList.map B with hBs
  have hmemS : ∀ B' ∈ Bs, ∃ d ∈ S, B d = B' := by
    intro B' hB'
    obtain ⟨d, hd, hdB⟩ := List.mem_map.1 hB'
    exact ⟨d, (Finset.mem_toList).1 hd, hdB⟩
  have hBslen : Bs.length = S.card := by simp [hBs]
  have hflat : (Bs.flatten : Multiset (Heis p)) ≤ (L : Multiset (Heis p)) := by
    have h1 : (Bs.flatten : Multiset (Heis p)) = ∑ d ∈ S, ((B d : List (Heis p)) : Multiset (Heis p)) := by
      rw [coe_flatten, hBs, List.map_map]
      exact Finset.sum_map_toList S _
    rw [h1]
    calc ∑ d ∈ S, ((B d : List (Heis p)) : Multiset (Heis p))
        ≤ ∑ d ∈ S, ((C d : List (Heis p)) : Multiset (Heis p)) :=
          Finset.sum_le_sum fun d _ => Multiset.coe_le.2 (hBsub d).subperm
      _ ≤ ∑ d : Option (ZMod p), ((C d : List (Heis p)) : Multiset (Heis p)) :=
          Finset.sum_le_sum_of_subset (Finset.subset_univ S)
      _ = (L : Multiset (Heis p)) := sum_coe_filter_fiber (dirOf (p := p)) L
  obtain ⟨T, hTsub, hTne, hTprod⟩ :=
    exists_productOne_of_central_blocks (Bs := Bs)
      (fun B' hB' => by
        obtain ⟨d, hd, rfl⟩ := hmemS B' hB'
        exact (hBprop d ((Finset.mem_filter.1 hd).2)).1)
      (fun B' hB' => by
        obtain ⟨d, hd, rfl⟩ := hmemS B' hB'
        exact ⟨(hBprop d ((Finset.mem_filter.1 hd).2)).2.1,
          (hBprop d ((Finset.mem_filter.1 hd).2)).2.2⟩)
      (by omega)
  exact ProductOneFree.subperm hfree (hTsub.subperm.trans (Multiset.coe_le.1 hflat)) hTne
    ⟨T, List.Perm.refl _, hTprod⟩

/-! ### The refined length bound -/

/-- **Refined upper bound.**  Every product-one-free sequence over `Heis p`
(`p` an odd prime) has length at most `2p(p-1)`. -/
theorem length_le_two_p_mul (hodd : Odd p) {L : List (Heis p)}
    (hfree : ProductOneFree L) : L.length ≤ 2 * p * (p - 1) := by
  classical
  haveI : NeZero p := ⟨(Fact.out : p.Prime).ne_zero⟩
  set C : Option (ZMod p) → List (Heis p) :=
    fun d => L.filter (fun g => decide (dirOf g = d)) with hC
  set S : Finset (Option (ZMod p)) :=
    Finset.univ.filter (fun d => p ≤ (C d).length) with hS
  have hSlt : S.card < p := card_large_dirs_lt hfree
  have hbound : ∀ d : Option (ZMod p),
      (C d).length ≤ (p - 1) + (if d ∈ S then (p - 1) else 0) := by
    intro d
    by_cases hd : d ∈ S
    · have h2 : (C d).length ≤ 2 * p - 2 := by
        refine length_le_of_const_dir (d := d) hodd (hfree.sublist List.filter_sublist) ?_
        intro g hg
        simpa using List.of_mem_filter hg
      have hp := (Fact.out : p.Prime).two_le
      simp only [hd, if_pos]
      omega
    · have : ¬ p ≤ (C d).length := by
        simpa [hS] using hd
      simp only [hd, if_neg, not_false_iff]
      omega
  have hcard : (Finset.univ : Finset (Option (ZMod p))).card = p + 1 := by
    simp [ZMod.card]
  have hsplit := length_eq_sum_filter (dirOf (p := p)) L
  have hstep : L.length ≤ (p + 1) * (p - 1) + S.card * (p - 1) := by
    calc L.length = ∑ d : Option (ZMod p), (C d).length := hsplit
      _ ≤ ∑ d : Option (ZMod p), ((p - 1) + (if d ∈ S then (p - 1) else 0)) :=
          Finset.sum_le_sum fun d _ => hbound d
      _ = (p + 1) * (p - 1) + S.card * (p - 1) := by
          rw [Finset.sum_add_distrib, Finset.sum_const, Finset.sum_ite_mem, Finset.univ_inter,
            Finset.sum_const, hcard, smul_eq_mul, smul_eq_mul]
  have hp := (Fact.out : p.Prime).two_le
  obtain ⟨q, rfl⟩ : ∃ q, p = q + 1 := ⟨p - 1, by omega⟩
  have hScard : S.card ≤ q := by omega
  simp only [Nat.add_sub_cancel] at hstep ⊢
  nlinarith [hstep, hScard]

end Prime

end Heis

open Heis

/-- `d(H_{p^3}) ≤ 2p(p-1)` for every odd prime `p`. -/
theorem smallDavenport_le_two_p_mul_p_sub_one {p : ℕ} [Fact p.Prime] (hodd : Odd p) :
    smallDavenport (Heis p) ≤ 2 * p * (p - 1) := by
  refine csSup_le ⟨0, ⟨[], rfl, productOneFree_nil⟩⟩ ?_
  rintro n ⟨L, rfl, hL⟩
  exact length_le_two_p_mul hodd hL

/-- For the Heisenberg group of order `125`: `d(H_125) ≤ 40`. -/
theorem smallDavenport_heis_five_le_40 : smallDavenport (Heis 5) ≤ 40 := by
  haveI : Fact (Nat.Prime 5) := ⟨by norm_num⟩
  have := smallDavenport_le_two_p_mul_p_sub_one (p := 5) (by decide)
  simpa using this

/-- The sharpened two-sided bound for the Heisenberg group of order `125`:
`12 ≤ d(H_125) ≤ 40`. -/
theorem smallDavenport_heis_five_refined_bounds :
    12 ≤ smallDavenport (Heis 5) ∧ smallDavenport (Heis 5) ≤ 40 :=
  ⟨twelve_le_smallDavenport_heis_five, smallDavenport_heis_five_le_40⟩

end Heisenberg125