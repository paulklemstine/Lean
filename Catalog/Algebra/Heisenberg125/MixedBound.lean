/-
# Mixing line blocks, central entries and plane blocks

`Algebra.Heisenberg125.BlockClassBound` counts one central block per direction
class with `p` entries, plus one per central entry.  The elements *left over*
after these blocks are removed still carry central blocks: by Chevalley–Warning
any `2p - 1` of them contain a nonempty sub-multiset with vanishing image
(`Heis.exists_central_block_of_length`).  Combining the two phases gives

`#{d : |C_d| ≥ p} + #{central entries} + ⌊(rest)/(2p-1)⌋ ≤ p - 1`
(`Heis.card_classes_central_plane_lt`),

and feeding this into the class count of `BlockClassBound.lean` improves the
bound for `p = 5` to `d(H_125) ≤ 27`.
-/
import Algebra.Heisenberg125.BlockClassBound

namespace Heisenberg125

namespace Heis

variable {p : ℕ}

section Prime

variable [Fact p.Prime]

/-- **Mixed block count.**  If `p·m + c + N₀ ≤ |L|`, where `m` is the number of
direction classes with at least `p` entries and `c` the number of central
entries, then `m + c + N₀/(2p-1) < p` for a product-one-free `L`. -/
theorem card_classes_central_plane_lt {L : List (Heis p)} (hfree : ProductOneFree L)
    (N0 : ℕ)
    (hN0 : p * (Finset.univ.filter
        (fun d : Option (ZMod p) => p ≤ (classList L (some d)).length)).card
      + (classList L none).length + N0 ≤ L.length) :
    (Finset.univ.filter
        (fun d : Option (ZMod p) => p ≤ (classList L (some d)).length)).card
      + (classList L none).length + N0 / (2 * p - 1) < p := by
  classical
  have hp2 := (Fact.out : p.Prime).two_le
  set S : Finset (Option (ZMod p)) :=
    Finset.univ.filter (fun d => p ≤ (classList L (some d)).length) with hS
  -- one central block of size at most `p` inside each large class
  have hchoice : ∀ d ∈ S, ∃ B : List (Heis p), B.Sublist (classList L (some d)) ∧ B ≠ [] ∧
      B.length ≤ p ∧ (B.prod).a = 0 ∧ (B.prod).b = 0 := by
    intro d hd
    have hlen : p ≤ (classList L (some d)).length := by simpa [hS] using hd
    obtain ⟨B, hBsub, hBne, hBa, hBb⟩ :=
      exists_central_block_of_dir (C := (classList L (some d)).take p)
        (fun g hg => dirOf_of_mem_classList ((List.take_sublist _ _).mem hg))
        (by rw [List.length_take, Nat.min_eq_left hlen])
    refine ⟨B, hBsub.trans (List.take_sublist _ _), hBne, ?_, hBa, hBb⟩
    have := hBsub.length_le
    rw [List.length_take, Nat.min_eq_left hlen] at this
    exact this
  choose! blockOf hbsub hbne hblen hba hbb using hchoice
  set A : List (Heis p) := (S.toList.map blockOf).flatten ++ classList L none with hA
  have hAsub : A.Subperm L := subperm_blocks_and_centrals blockOf (fun d hd => hbsub d hd)
  have hAlen : A.length ≤ p * S.card + (classList L none).length := by
    have hflat : ((S.toList.map blockOf).flatten).length ≤ p * S.card := by
      have hall : ∀ x ∈ (S.toList.map blockOf).map List.length, x ≤ p := by
        intro x hx
        obtain ⟨B, hB, rfl⟩ := List.mem_map.1 hx
        obtain ⟨d, hd, rfl⟩ := List.mem_map.1 hB
        exact hblen d (Finset.mem_toList.1 hd)
      have hsum := List.sum_le_card_nsmul _ p hall
      simp only [List.length_flatten]
      simpa [List.length_map, Finset.length_toList, mul_comm] using hsum
    rw [hA, List.length_append]
    omega
  -- the leftover of `L`
  obtain ⟨A', hA'perm, hA'sub⟩ := hAsub
  obtain ⟨R, hRperm⟩ := hA'sub.exists_perm_append
  have hRlen : N0 ≤ R.length := by
    have h1 : L.length = A'.length + R.length := by
      rw [hRperm.length_eq, List.length_append]
    have h2 : A'.length = A.length := hA'perm.length_eq
    omega
  -- plane blocks from the leftover
  obtain ⟨Bs2, hBs2len, hBs2prop, hBs2sub⟩ :=
    exists_disjoint_blocks (fun B : List (Heis p) => (B.prod).a = 0 ∧ (B.prod).b = 0)
      (2 * p - 1) (fun M hM => exists_central_block_of_length M hM) (N0 / (2 * p - 1)) R
      (le_trans (Nat.div_mul_le_self N0 (2 * p - 1)) hRlen)
  -- assemble all the blocks
  set Bs : List (List (Heis p)) :=
    (S.toList.map blockOf ++ (classList L none).map (fun w => [w])) ++ Bs2 with hBs
  have hsing : ∀ l : List (Heis p), (l.map (fun w => [w])).flatten = l := by
    intro l
    induction l with
    | nil => rfl
    | cons a t ih => simp [ih]
  have hflatten : Bs.flatten = A ++ Bs2.flatten := by
    rw [hBs, List.flatten_append, List.flatten_append, hsing, hA]
  have hBne : ∀ B ∈ Bs, B ≠ [] := by
    intro B hB
    rw [hBs, List.mem_append, List.mem_append] at hB
    rcases hB with (hB | hB) | hB
    · obtain ⟨d, hd, rfl⟩ := List.mem_map.1 hB
      exact hbne d (Finset.mem_toList.1 hd)
    · obtain ⟨w, _, rfl⟩ := List.mem_map.1 hB
      simp
    · exact (hBs2prop B hB).1
  have hBcen : ∀ B ∈ Bs, (B.prod).a = 0 ∧ (B.prod).b = 0 := by
    intro B hB
    rw [hBs, List.mem_append, List.mem_append] at hB
    rcases hB with (hB | hB) | hB
    · obtain ⟨d, hd, rfl⟩ := List.mem_map.1 hB
      exact ⟨hba d (Finset.mem_toList.1 hd), hbb d (Finset.mem_toList.1 hd)⟩
    · obtain ⟨w, hw, rfl⟩ := List.mem_map.1 hB
      have hw' := central_of_mem_classList_none hw
      rw [List.prod_singleton]
      exact hw'
    · exact (hBs2prop B hB).2
  have hBsub : Bs.flatten.Subperm L := by
    rw [hflatten]
    have h1 : (A ++ Bs2.flatten).Subperm (A ++ R) := subperm_append_left_of A hBs2sub
    have h2 : (A ++ R).Perm (A' ++ R) := (hA'perm.symm).append_right R
    exact h1.trans (h2.subperm.trans hRperm.symm.subperm)
  have hcount := card_disjoint_central_blocks_lt hfree hBne hBcen hBsub
  have hBslen : Bs.length = S.card + (classList L none).length + N0 / (2 * p - 1) := by
    rw [hBs]
    simp only [List.length_append, List.length_map, Finset.length_toList, hBs2len]
  omega

end Prime

end Heis

open Heis

/-- **Mixed bound for `H_125`.**  Combining the direction-class exclusions of
`ClassBound.lean`/`HeavyClass.lean` with the mixed block count gives
`d(H_125) ≤ 27`. -/
theorem length_le_27_heis_five {L : List (Heis 5)} (hfree : ProductOneFree L) :
    L.length ≤ 27 := by
  classical
  haveI : Fact (Nat.Prime 5) := ⟨by norm_num⟩
  have hodd : Odd 5 := by decide
  set cnt : Option (Option (ZMod 5)) → ℕ := fun k => (classList L k).length with hcnt
  have hsplit : L.length = cnt none + ∑ d : Option (ZMod 5), cnt (some d) := by
    rw [length_eq_sum_filter (dirClass (p := 5)) L]
    exact Fintype.sum_option _
  have hclass : ∀ d : Option (ZMod 5), cnt (some d) ≤ 8 := by
    intro d
    have := Heis.length_class_le hodd hfree d
    simpa [hcnt] using this
  have hcardOpt : Fintype.card (Option (ZMod 5)) = 6 := by simp [ZMod.card]
  set S4 : Finset (Option (ZMod 5)) := Finset.univ.filter (fun d => 4 ≤ cnt (some d)) with hS4
  set S5 : Finset (Option (ZMod 5)) := Finset.univ.filter (fun d => 5 ≤ cnt (some d)) with hS5
  have hmem4 : ∀ d, d ∈ S4 ↔ 4 ≤ cnt (some d) := by intro d; simp [hS4]
  have hmem5 : ∀ d, d ∈ S5 ↔ 5 ≤ cnt (some d) := by intro d; simp [hS5]
  have hsub54 : S5 ⊆ S4 := fun d hd => (hmem4 d).2 (by have := (hmem5 d).1 hd; omega)
  have hsdiff : (S4 \ S5).card + S5.card = S4.card := Finset.card_sdiff_add_card_eq_card hsub54
  have hle5 : ∑ d ∈ S5, cnt (some d) ≤ S5.card * 8 := by
    have := Finset.sum_le_card_nsmul S5 (fun d => cnt (some d)) 8 (fun d _ => hclass d)
    simpa [mul_comm] using this
  have hlediff : ∑ d ∈ S4 \ S5, cnt (some d) ≤ (S4 \ S5).card * 4 := by
    have hbnd : ∀ d ∈ S4 \ S5, cnt (some d) ≤ 4 := by
      intro d hd
      have hnot : ¬ (5 ≤ cnt (some d)) := fun hcon =>
        (Finset.mem_sdiff.1 hd).2 ((hmem5 d).2 hcon)
      omega
    have := Finset.sum_le_card_nsmul (S4 \ S5) (fun d => cnt (some d)) 4 hbnd
    simpa [mul_comm] using this
  have hsum4 : ∑ d ∈ S4 \ S5, cnt (some d) + ∑ d ∈ S5, cnt (some d)
      = ∑ d ∈ S4, cnt (some d) := Finset.sum_sdiff hsub54
  have hsum5ge : 5 * S5.card ≤ ∑ d : Option (ZMod 5), cnt (some d) := by
    have h1 : ∑ d ∈ S5, cnt (some d) ≤ ∑ d : Option (ZMod 5), cnt (some d) :=
      Finset.sum_le_sum_of_subset (Finset.subset_univ _)
    have h2 : S5.card * 5 ≤ ∑ d ∈ S5, cnt (some d) := by
      have := Finset.card_nsmul_le_sum S5 (fun d => cnt (some d)) 5 (fun d hd => (hmem5 d).1 hd)
      simpa [mul_comm] using this
    omega
  -- the mixed block count, applied with the largest admissible remainder
  have hmixed : ∀ N0 : ℕ, 5 * S5.card + cnt none + N0 ≤ L.length →
      S5.card + cnt none + N0 / 9 < 5 := by
    intro N0 hN0
    have h := Heis.card_classes_central_plane_lt (p := 5) hfree N0 (by
      simpa [hS5, hcnt] using hN0)
    simpa [hS5, hcnt] using h
  by_cases h3 : 3 ≤ S4.card
  · -- three classes with at least `p - 1 = 4` entries: all other classes are empty
    obtain ⟨T, hTS, hT3⟩ := Finset.exists_subset_card_eq h3
    obtain ⟨d0, e1, e2, h01, h02, h12, hTeq⟩ := Finset.card_eq_three.1 hT3
    rw [hTeq] at hT3 hTS
    have hbig : ∀ d ∈ ({d0, e1, e2} : Finset (Option (ZMod 5))), 4 ≤ cnt (some d) := by
      intro d hd
      exact (hmem4 d).1 (hTS hd)
    have hzero : ∀ d ∉ ({d0, e1, e2} : Finset (Option (ZMod 5))), cnt (some d) = 0 := by
      intro d hd
      by_contra hne
      have hne' : classList L (some d) ≠ [] := by
        intro hnil
        exact hne (by simp [hcnt, hnil])
      simp only [Finset.mem_insert, Finset.mem_singleton, not_or] at hd
      exact Heis.four_class_exclusion hodd hfree h01 h02 (Ne.symm hd.1) h12 (Ne.symm hd.2.1)
        (Ne.symm hd.2.2) (by simpa [hcnt] using hbig d0 (by simp))
        (by simpa [hcnt] using hbig e1 (by simp)) (by simpa [hcnt] using hbig e2 (by simp)) hne'
    have hS4eq : S4 = ({d0, e1, e2} : Finset (Option (ZMod 5))) := by
      apply Finset.Subset.antisymm
      · intro d hd
        by_contra hdn
        have := hzero d hdn
        have := (hmem4 d).1 hd
        omega
      · exact hTS
    have hsumall : ∑ d : Option (ZMod 5), cnt (some d) = ∑ d ∈ S4, cnt (some d) := by
      rw [hS4eq]
      exact (Finset.sum_subset (Finset.subset_univ _) (fun x _ hx => hzero x hx)).symm
    have hS4card : S4.card = 3 := by rw [hS4eq]; exact hT3
    have hm3 : S5.card ≤ 3 := by
      have := Finset.card_le_card hsub54; omega
    have hNle : ∑ d : Option (ZMod 5), cnt (some d) ≤ S5.card * 8 + (S4 \ S5).card * 4 := by
      rw [hsumall, ← hsum4]; omega
    have hmix := hmixed (∑ d : Option (ZMod 5), cnt (some d) - 5 * S5.card) (by omega)
    omega
  · -- at most two classes with `4` entries
    have hS42 : S4.card ≤ 2 := by omega
    have hcompl : ∀ d ∈ S4ᶜ, cnt (some d) ≤ 3 := by
      intro d hd
      have : ¬ (4 ≤ cnt (some d)) := fun hcon => (Finset.mem_compl.1 hd) ((hmem4 d).2 hcon)
      omega
    have hcardc : S4.card + S4ᶜ.card = 6 := by
      have := Finset.card_add_card_compl S4
      rw [hcardOpt] at this
      omega
    have hsplitS : ∑ d : Option (ZMod 5), cnt (some d)
        = ∑ d ∈ S4, cnt (some d) + ∑ d ∈ S4ᶜ, cnt (some d) :=
      (Finset.sum_add_sum_compl S4 _).symm
    have hleSc : ∑ d ∈ S4ᶜ, cnt (some d) ≤ S4ᶜ.card * 3 := by
      have := Finset.sum_le_card_nsmul S4ᶜ (fun d => cnt (some d)) 3 hcompl
      simpa [mul_comm] using this
    by_cases hm2 : 2 ≤ S5.card
    · -- two classes with `5` entries: each is capped at `2p - 3 = 7`
      have hcard5 : S5.card = 2 := le_antisymm (le_trans (Finset.card_le_card hsub54) hS42) hm2
      have hS54 : S5 = S4 := Finset.eq_of_subset_of_card_le hsub54 (by omega)
      obtain ⟨a, b, hab, hS5ab⟩ := Finset.card_eq_two.1 hcard5
      have ha5 : 5 ≤ cnt (some a) := (hmem5 a).1 (by rw [hS5ab]; simp)
      have hb5 : 5 ≤ cnt (some b) := (hmem5 b).1 (by rw [hS5ab]; simp)
      have hcap : ∀ x y : Option (ZMod 5), x ≠ y → 5 ≤ cnt (some y) → cnt (some x) ≤ 7 := by
        intro x y hxy hy
        by_contra hcon
        refine Heis.heavy_pair_exclusion (p := 5) hodd hfree hxy ?_ ?_
        · simp only [hcnt] at hcon ⊢; omega
        · simp only [hcnt] at hy ⊢; omega
      have hacap : cnt (some a) ≤ 7 := hcap a b hab hb5
      have hbcap : cnt (some b) ≤ 7 := hcap b a (Ne.symm hab) ha5
      have hsum2 : ∑ d ∈ S4, cnt (some d) = cnt (some a) + cnt (some b) := by
        rw [← hS54, hS5ab]; exact Finset.sum_pair hab
      have hcardc' : S4ᶜ.card = 4 := by
        have : S4.card = 2 := by rw [← hS54]; exact hcard5
        omega
      rw [hcardc'] at hleSc
      have hmix := hmixed (∑ d : Option (ZMod 5), cnt (some d) - 5 * S5.card) (by omega)
      omega
    · -- at most one class with `5` entries
      have hm1 : S5.card ≤ 1 := by omega
      have hNle : ∑ d : Option (ZMod 5), cnt (some d)
          ≤ S5.card * 8 + (S4 \ S5).card * 4 + S4ᶜ.card * 3 := by
        rw [hsplitS, ← hsum4]; omega
      have hmix := hmixed (∑ d : Option (ZMod 5), cnt (some d) - 5 * S5.card) (by omega)
      omega

/-- `d(H_125) ≤ 27`. -/
theorem smallDavenport_heis_five_le_27 : smallDavenport (Heis 5) ≤ 27 := by
  refine csSup_le ⟨0, ⟨[], rfl, productOneFree_nil⟩⟩ ?_
  rintro n ⟨L, rfl, hL⟩
  exact length_le_27_heis_five hL

/-- The sharpest two-sided bound proved in this project for the Heisenberg group
of order `125`: `12 ≤ d(H_125) ≤ 27`. -/
theorem smallDavenport_heis_five_mixed_bounds :
    12 ≤ smallDavenport (Heis 5) ∧ smallDavenport (Heis 5) ≤ 27 :=
  ⟨twelve_le_smallDavenport_heis_five, smallDavenport_heis_five_le_27⟩

end Heisenberg125