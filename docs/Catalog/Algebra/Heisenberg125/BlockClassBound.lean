/-
# Combining central blocks with the direction-class analysis

`Algebra.Heisenberg125.HeavyClass` bounds a product-one-free sequence through
exclusions among its direction classes.  A second, independent mechanism is
available: every direction class carrying `p` entries contains a nonempty block
whose product is *central* (`Heis.exists_central_block_of_dir`), every central
entry is such a block by itself, and `p` pairwise disjoint central blocks force
a product-one subsequence (`Heis.card_disjoint_central_blocks_lt`).  Hence

`#{directions with ≥ p entries} + #{central entries} ≤ p - 1`
(`Heis.card_large_classes_add_central_lt`).

Feeding this into the class count — and using the heavy-pair exclusion to cap a
direction class at `2p - 3` as soon as a second class also has `p` entries —
improves the bound to `p² + 2p - 7`, i.e. `d(H_125) ≤ 28`.
-/
import Algebra.Heisenberg125.HeavyClass
import Algebra.Heisenberg125.SpreadBound

namespace Heisenberg125

namespace Heis

variable {p : ℕ}

section Prime

variable [Fact p.Prime]

/-! ### Blocks from distinct classes together with the central entries -/

/-- Flattening one block chosen inside each of finitely many distinct direction
classes, together with all central entries, gives a sub-multiset of `L`. -/
lemma subperm_blocks_and_centrals {L : List (Heis p)} {S : Finset (Option (ZMod p))}
    (blockOf : Option (ZMod p) → List (Heis p))
    (hb : ∀ d ∈ S, (blockOf d).Sublist (classList L (some d))) :
    ((S.toList.map blockOf).flatten ++ classList L none).Subperm L := by
  classical
  set F : Option (Option (ZMod p)) → Multiset (Heis p) :=
    fun k => ((classList L k : List (Heis p)) : Multiset (Heis p)) with hF
  have hflat : (((S.toList.map blockOf).flatten : List (Heis p)) : Multiset (Heis p))
      = ∑ d ∈ S, ((blockOf d : List (Heis p)) : Multiset (Heis p)) := by
    rw [coe_flatten, List.map_map, ← Finset.sum_map_toList]
    rfl
  have hnotmem : (none : Option (Option (ZMod p))) ∉ S.image some := by simp
  have hins : ∑ k ∈ insert (none : Option (Option (ZMod p))) (S.image some), F k
      = F none + ∑ d ∈ S, F (some d) := by
    rw [Finset.sum_insert hnotmem, Finset.sum_image (fun x _ y _ h => Option.some_injective _ h)]
  have hle : (((S.toList.map blockOf).flatten ++ classList L none : List (Heis p)) :
      Multiset (Heis p)) ≤ (L : Multiset (Heis p)) := by
    have hexp : (((S.toList.map blockOf).flatten ++ classList L none : List (Heis p)) :
        Multiset (Heis p))
        = (((S.toList.map blockOf).flatten : List (Heis p)) : Multiset (Heis p)) + F none := rfl
    rw [hexp, hflat]
    calc ∑ d ∈ S, ((blockOf d : List (Heis p)) : Multiset (Heis p)) + F none
        ≤ ∑ d ∈ S, F (some d) + F none :=
          add_le_add (Finset.sum_le_sum
            (fun d hd => Multiset.coe_le.2 (hb d hd).subperm)) le_rfl
      _ = ∑ k ∈ insert (none : Option (Option (ZMod p))) (S.image some), F k := by
          rw [hins]; exact add_comm _ _
      _ ≤ ∑ k : Option (Option (ZMod p)), F k :=
          Finset.sum_le_sum_of_subset (Finset.subset_univ _)
      _ = (L : Multiset (Heis p)) := sum_coe_filter_fiber (dirClass (p := p)) L
  exact Multiset.coe_le.1 hle

/-- **Block count.**  In a product-one-free sequence over `Heis p` the number of
direction classes carrying at least `p` entries, plus the number of central
entries, is smaller than `p`. -/
theorem card_large_classes_add_central_lt {L : List (Heis p)} (hfree : ProductOneFree L) :
    (Finset.univ.filter
        (fun d : Option (ZMod p) => p ≤ (classList L (some d)).length)).card
      + (classList L none).length < p := by
  classical
  set S : Finset (Option (ZMod p)) :=
    Finset.univ.filter (fun d => p ≤ (classList L (some d)).length) with hS
  have hchoice : ∀ d ∈ S, ∃ B : List (Heis p), B.Sublist (classList L (some d)) ∧ B ≠ [] ∧
      (B.prod).a = 0 ∧ (B.prod).b = 0 := by
    intro d hd
    have hlen : p ≤ (classList L (some d)).length := by
      simpa [hS] using hd
    exact exists_central_block_of_dir (fun g hg => dirOf_of_mem_classList hg) hlen
  choose! blockOf hbsub hbne hba hbb using hchoice
  set Bs : List (List (Heis p)) :=
    S.toList.map blockOf ++ (classList L none).map (fun w => [w]) with hBs
  have hsing : ∀ l : List (Heis p), (l.map (fun w => [w])).flatten = l := by
    intro l
    induction l with
    | nil => rfl
    | cons a t ih => simp [ih]
  have hflatten : Bs.flatten = (S.toList.map blockOf).flatten ++ classList L none := by
    rw [hBs, List.flatten_append, hsing]
  have hBne : ∀ B ∈ Bs, B ≠ [] := by
    intro B hB
    rw [hBs, List.mem_append] at hB
    rcases hB with hB | hB
    · obtain ⟨d, hd, rfl⟩ := List.mem_map.1 hB
      exact hbne d (Finset.mem_toList.1 hd)
    · obtain ⟨w, _, rfl⟩ := List.mem_map.1 hB
      simp
  have hBcen : ∀ B ∈ Bs, (B.prod).a = 0 ∧ (B.prod).b = 0 := by
    intro B hB
    rw [hBs, List.mem_append] at hB
    rcases hB with hB | hB
    · obtain ⟨d, hd, rfl⟩ := List.mem_map.1 hB
      exact ⟨hba d (Finset.mem_toList.1 hd), hbb d (Finset.mem_toList.1 hd)⟩
    · obtain ⟨w, hw, rfl⟩ := List.mem_map.1 hB
      have hw' := central_of_mem_classList_none hw
      rw [List.prod_singleton]
      exact hw'
  have hBsub : Bs.flatten.Subperm L := by
    rw [hflatten]
    exact subperm_blocks_and_centrals blockOf (fun d hd => hbsub d hd)
  have hlen := card_disjoint_central_blocks_lt hfree hBne hBcen hBsub
  have hBlen : Bs.length = S.card + (classList L none).length := by
    rw [hBs]
    simp [Finset.length_toList]
  omega

/-! ### The bound `p² + 2p - 7` -/

/-- **Block-class bound.**  For every prime `p ≥ 5` a product-one-free sequence
over `Heis p` has length at most `p² + 2p - 7`; for `p = 5` this gives
`d(H_125) ≤ 28`. -/
theorem length_le_block_class_bound (hodd : Odd p) (hp5 : 5 ≤ p) {L : List (Heis p)}
    (hfree : ProductOneFree L) : L.length ≤ p ^ 2 + 2 * p - 7 := by
  classical
  obtain ⟨q, rfl⟩ : ∃ q, p = q + 5 := ⟨p - 5, by omega⟩
  set cnt : Option (Option (ZMod (q + 5))) → ℕ := fun k => (classList L k).length with hcnt
  have hsplit : L.length = cnt none + ∑ d : Option (ZMod (q + 5)), cnt (some d) := by
    rw [length_eq_sum_filter (dirClass (p := q + 5)) L]
    exact Fintype.sum_option _
  have hcentral : cnt none ≤ q + 4 := by
    have := length_central_le (p := q + 5) hfree
    simpa [hcnt] using this
  have hclass : ∀ d : Option (ZMod (q + 5)), cnt (some d) ≤ 2 * q + 8 := by
    intro d
    have := length_class_le hodd hfree d
    simpa [hcnt] using this
  have hcardOpt : Fintype.card (Option (ZMod (q + 5))) = q + 6 := by
    simp [ZMod.card]
  have hRHS : (q + 5) ^ 2 + 2 * (q + 5) - 7 = q ^ 2 + 12 * q + 28 := by
    have hsq : (q + 5) ^ 2 = q ^ 2 + 10 * q + 25 := by ring
    omega
  rw [hRHS]
  set S4 : Finset (Option (ZMod (q + 5))) :=
    Finset.univ.filter (fun d => q + 4 ≤ cnt (some d)) with hS4
  set S5 : Finset (Option (ZMod (q + 5))) :=
    Finset.univ.filter (fun d => q + 5 ≤ cnt (some d)) with hS5
  have hmem4 : ∀ d, d ∈ S4 ↔ q + 4 ≤ cnt (some d) := by intro d; simp [hS4]
  have hmem5 : ∀ d, d ∈ S5 ↔ q + 5 ≤ cnt (some d) := by intro d; simp [hS5]
  have hsub54 : S5 ⊆ S4 := by
    intro d hd
    exact (hmem4 d).2 (by have := (hmem5 d).1 hd; omega)
  have hblock : S5.card + cnt none < q + 5 := by
    have := card_large_classes_add_central_lt (p := q + 5) hfree
    simpa [hS5, hcnt] using this
  by_cases h3 : 3 ≤ S4.card
  · -- three heavily populated classes: all remaining classes are empty
    obtain ⟨T, hTS, hT3⟩ := Finset.exists_subset_card_eq h3
    obtain ⟨d0, e1, e2, h01, h02, h12, rfl⟩ := Finset.card_eq_three.1 hT3
    have hbig : ∀ d ∈ ({d0, e1, e2} : Finset (Option (ZMod (q + 5)))),
        q + 4 ≤ cnt (some d) := fun d hd => (hmem4 d).1 (hTS hd)
    have hd0 : q + 4 ≤ cnt (some d0) := hbig d0 (by simp)
    have he1 : q + 4 ≤ cnt (some e1) := hbig e1 (by simp)
    have he2 : q + 4 ≤ cnt (some e2) := hbig e2 (by simp)
    have hzero : ∀ d ∉ ({d0, e1, e2} : Finset (Option (ZMod (q + 5)))), cnt (some d) = 0 := by
      intro d hd
      by_contra hne
      have hne' : classList L (some d) ≠ [] := by
        intro hnil
        exact hne (by simp [hcnt, hnil])
      simp only [Finset.mem_insert, Finset.mem_singleton, not_or] at hd
      exact four_class_exclusion hodd hfree h01 h02 (Ne.symm hd.1) h12 (Ne.symm hd.2.1)
        (Ne.symm hd.2.2) (by simpa [hcnt] using hd0) (by simpa [hcnt] using he1)
        (by simpa [hcnt] using he2) hne'
    have hsum3 : ∑ d : Option (ZMod (q + 5)), cnt (some d)
        = ∑ d ∈ ({d0, e1, e2} : Finset (Option (ZMod (q + 5)))), cnt (some d) :=
      (Finset.sum_subset (Finset.subset_univ _) (fun x _ hx => hzero x hx)).symm
    have hle3 : ∑ d ∈ ({d0, e1, e2} : Finset (Option (ZMod (q + 5)))), cnt (some d)
        ≤ 3 * (2 * q + 8) := by
      have hcard : ({d0, e1, e2} : Finset (Option (ZMod (q + 5)))).card = 3 := hT3
      have := Finset.sum_le_card_nsmul ({d0, e1, e2} : Finset (Option (ZMod (q + 5))))
        (fun d => cnt (some d)) (2 * q + 8) (fun d _ => hclass d)
      simpa [hcard, mul_comm] using this
    rw [hsplit, hsum3]
    nlinarith [hcentral, hle3, sq_nonneg q]
  · -- at most two classes with `p - 1` entries
    have hS42 : S4.card ≤ 2 := by omega
    have hcompl : ∀ d ∈ S4ᶜ, cnt (some d) ≤ q + 3 := by
      intro d hd
      have : ¬ (q + 4 ≤ cnt (some d)) := fun hcon => (Finset.mem_compl.1 hd) ((hmem4 d).2 hcon)
      omega
    have hcardc : S4.card + S4ᶜ.card = q + 6 := by
      have := Finset.card_add_card_compl S4
      rw [hcardOpt] at this
      omega
    have hsplitS : ∑ d : Option (ZMod (q + 5)), cnt (some d)
        = ∑ d ∈ S4, cnt (some d) + ∑ d ∈ S4ᶜ, cnt (some d) :=
      (Finset.sum_add_sum_compl S4 _).symm
    have hleSc : ∑ d ∈ S4ᶜ, cnt (some d) ≤ S4ᶜ.card * (q + 3) := by
      have := Finset.sum_le_card_nsmul S4ᶜ (fun d => cnt (some d)) (q + 3) hcompl
      simpa [mul_comm] using this
    by_cases hm2 : 2 ≤ S5.card
    · -- two classes with `p` entries: each is capped at `2p - 3`
      have hcard5 : S5.card = 2 := le_antisymm (le_trans (Finset.card_le_card hsub54) hS42) hm2
      have hS54 : S5 = S4 := Finset.eq_of_subset_of_card_le hsub54 (by omega)
      obtain ⟨a, b, hab, hS5ab⟩ := Finset.card_eq_two.1 hcard5
      have ha5 : q + 5 ≤ cnt (some a) := (hmem5 a).1 (by rw [hS5ab]; simp)
      have hb5 : q + 5 ≤ cnt (some b) := (hmem5 b).1 (by rw [hS5ab]; simp)
      have hcap : ∀ x y : Option (ZMod (q + 5)), x ≠ y → q + 5 ≤ cnt (some y) →
          cnt (some x) ≤ 2 * q + 7 := by
        intro x y hxy hy
        by_contra hcon
        refine heavy_pair_exclusion hodd hfree hxy ?_ ?_
        · simp only [hcnt] at hcon ⊢; omega
        · simp only [hcnt] at hy ⊢; omega
      have hacap : cnt (some a) ≤ 2 * q + 7 := hcap a b hab hb5
      have hbcap : cnt (some b) ≤ 2 * q + 7 := hcap b a (Ne.symm hab) ha5
      have hnone : cnt none ≤ q + 2 := by omega
      have hsum4 : ∑ d ∈ S4, cnt (some d) = cnt (some a) + cnt (some b) := by
        rw [← hS54, hS5ab]
        exact Finset.sum_pair hab
      have hcardc' : S4ᶜ.card = q + 4 := by
        have : S4.card = 2 := by rw [← hS54]; exact hcard5
        omega
      rw [hcardc'] at hleSc
      rw [hsplit, hsplitS, hsum4]
      nlinarith [hleSc, hnone, hacap, hbcap]
    · -- at most one class with `p` entries
      have hm1 : S5.card ≤ 1 := by omega
      have hsdiff : (S4 \ S5).card + S5.card = S4.card :=
        Finset.card_sdiff_add_card_eq_card hsub54
      have hle5 : ∑ d ∈ S5, cnt (some d) ≤ S5.card * (2 * q + 8) := by
        have := Finset.sum_le_card_nsmul S5 (fun d => cnt (some d)) (2 * q + 8)
          (fun d _ => hclass d)
        simpa [mul_comm] using this
      have hlediff : ∑ d ∈ S4 \ S5, cnt (some d) ≤ (S4 \ S5).card * (q + 4) := by
        have hbnd : ∀ d ∈ S4 \ S5, cnt (some d) ≤ q + 4 := by
          intro d hd
          have hnot : ¬ (q + 5 ≤ cnt (some d)) := by
            intro hcon
            exact (Finset.mem_sdiff.1 hd).2 ((hmem5 d).2 hcon)
          omega
        have := Finset.sum_le_card_nsmul (S4 \ S5) (fun d => cnt (some d)) (q + 4) hbnd
        simpa [mul_comm] using this
      have hsum4 : ∑ d ∈ S4 \ S5, cnt (some d) + ∑ d ∈ S5, cnt (some d)
          = ∑ d ∈ S4, cnt (some d) := Finset.sum_sdiff hsub54
      have hnone : S5.card + cnt none ≤ q + 4 := by omega
      rw [hsplit, hsplitS, ← hsum4]
      nlinarith [hle5, hlediff, hleSc, hnone, hm1, hS42, hsdiff, hcardc]

/-- `d(H_{p³}) ≤ p² + 2p - 7` for every prime `p ≥ 5`. -/
theorem smallDavenport_le_block_class_bound (hodd : Odd p) (hp5 : 5 ≤ p) :
    smallDavenport (Heis p) ≤ p ^ 2 + 2 * p - 7 := by
  refine csSup_le ⟨0, ⟨[], rfl, productOneFree_nil⟩⟩ ?_
  rintro n ⟨L, rfl, hL⟩
  exact length_le_block_class_bound hodd hp5 hL

end Prime

end Heis

open Heis

/-- For the Heisenberg group of order `125`: `d(H_125) ≤ 28`. -/
theorem smallDavenport_heis_five_le_28 : smallDavenport (Heis 5) ≤ 28 := by
  haveI : Fact (Nat.Prime 5) := ⟨by norm_num⟩
  have h := Heis.smallDavenport_le_block_class_bound (p := 5) (by decide) (by norm_num)
  norm_num at h
  exact h

/-- The sharpest two-sided bound proved here for the Heisenberg group of order
`125`: `12 ≤ d(H_125) ≤ 28`. -/
theorem smallDavenport_heis_five_block_bounds :
    12 ≤ smallDavenport (Heis 5) ∧ smallDavenport (Heis 5) ≤ 28 :=
  ⟨twelve_le_smallDavenport_heis_five, smallDavenport_heis_five_le_28⟩

end Heisenberg125