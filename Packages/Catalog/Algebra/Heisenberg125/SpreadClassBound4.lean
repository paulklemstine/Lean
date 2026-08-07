/-
# `d(H_125) ≤ 20`

The four-class spread exclusion `Heis.spread_exclusion4` adds five new
constraints to the level counts `s_k = ` number of direction classes with at
least `k` entries of a product-one-free sequence over `Heis 5`:

* `s₄ ≥ 1 → s₃ ≤ 3`                      (configuration `(4; 3,3,3)`),
* `s₄ ≥ 2 ∧ s₃ ≥ 3 → s₂ ≤ 3`             (configuration `(4; 4,3,2)`),
* `s₅ ≥ 1 ∧ s₃ ≥ 3 → s₂ ≤ 3`             (configuration `(5; 3,3,2)`),
* `s₅ ≥ 1 ∧ s₄ ≥ 2 → s₂ ≤ 3`             (configuration `(5; 4,2,2)`),
* `s₅ ≥ 1 ∧ s₄ ≥ 2 ∧ s₃ ≥ 3 → s₁ ≤ 3`    (configuration `(5; 4,3,1)`).

Together with the constraints of `Algebra.Heisenberg125.SpreadClassBound` the
integer program now has optimum `20`, attained for instance by six classes of
three entries each together with two central entries.  Hence `d(H_125) ≤ 20`.
-/
import Algebra.Heisenberg125.SpreadClassBound
import Algebra.Heisenberg125.SpreadExclusion4

namespace Heisenberg125

namespace Heis

local instance factPrimeFive'' : Fact (Nat.Prime 5) := ⟨by norm_num⟩

section Exclusions4

variable {L : List (Heis 5)} (hfree : ProductOneFree L)

private lemma hodd5' : Odd 5 := by decide

include hfree

/-- Level form of the four-class spread exclusion `(4; 3,3,3)`: a class with
`4` entries forbids three further classes with `3` entries. -/
theorem level4_four_three (h4 : 1 ≤ levelCard L 4) : levelCard L 3 ≤ 3 := by
  by_contra hcon
  push_neg at hcon
  obtain ⟨d1, hd1⟩ := exists_of_levelCard_pos h4
  obtain ⟨d2, hd2mem, hd2ne⟩ :=
    exists_mem_ne (S := Finset.univ.filter
      (fun d : Option (ZMod 5) => 3 ≤ (classList L (some d)).length)) (x := d1)
      (by simpa [levelCard] using (by omega : 2 ≤ levelCard L 3))
  obtain ⟨d3, hd3mem, hd3ne1, hd3ne2⟩ :=
    exists_mem_ne₂ (S := Finset.univ.filter
      (fun d : Option (ZMod 5) => 3 ≤ (classList L (some d)).length)) (x := d1) (y := d2)
      (by simpa [levelCard] using (by omega : 3 ≤ levelCard L 3))
  obtain ⟨d4, hd4mem, hd4ne1, hd4ne2, hd4ne3⟩ :=
    exists_mem_ne₃ (S := Finset.univ.filter
      (fun d : Option (ZMod 5) => 3 ≤ (classList L (some d)).length)) (x := d1) (y := d2) (z := d3)
      (by simpa [levelCard] using (by omega : 4 ≤ levelCard L 3))
  have hd2 := (mem_level_filter L 3 d2).1 hd2mem
  have hd3 := (mem_level_filter L 3 d3).1 hd3mem
  have hd4 := (mem_level_filter L 3 d4).1 hd4mem
  exact spread_exclusion4 hodd5' hfree (Ne.symm hd2ne) (Ne.symm hd3ne1) (Ne.symm hd4ne1)
    (Ne.symm hd3ne2) (Ne.symm hd4ne2) (Ne.symm hd4ne3) (by omega) (by omega)

/-- Level form of the four-class spread exclusion `(4; 4,3,2)`. -/
theorem level4_four_four_three_two (h4 : 2 ≤ levelCard L 4) (h3 : 3 ≤ levelCard L 3) :
    levelCard L 2 ≤ 3 := by
  by_contra hcon
  push_neg at hcon
  obtain ⟨d1, hd1⟩ := exists_of_levelCard_pos (L := L) (k := 4) (by omega)
  obtain ⟨d2, hd2mem, hd2ne⟩ :=
    exists_mem_ne (S := Finset.univ.filter
      (fun d : Option (ZMod 5) => 4 ≤ (classList L (some d)).length)) (x := d1)
      (by simpa [levelCard] using h4)
  obtain ⟨d3, hd3mem, hd3ne1, hd3ne2⟩ :=
    exists_mem_ne₂ (S := Finset.univ.filter
      (fun d : Option (ZMod 5) => 3 ≤ (classList L (some d)).length)) (x := d1) (y := d2)
      (by simpa [levelCard] using h3)
  obtain ⟨d4, hd4mem, hd4ne1, hd4ne2, hd4ne3⟩ :=
    exists_mem_ne₃ (S := Finset.univ.filter
      (fun d : Option (ZMod 5) => 2 ≤ (classList L (some d)).length)) (x := d1) (y := d2) (z := d3)
      (by simpa [levelCard] using (by omega : 4 ≤ levelCard L 2))
  have hd2 := (mem_level_filter L 4 d2).1 hd2mem
  have hd3 := (mem_level_filter L 3 d3).1 hd3mem
  have hd4 := (mem_level_filter L 2 d4).1 hd4mem
  exact spread_exclusion4 hodd5' hfree (Ne.symm hd2ne) (Ne.symm hd3ne1) (Ne.symm hd4ne1)
    (Ne.symm hd3ne2) (Ne.symm hd4ne2) (Ne.symm hd4ne3) (by omega) (by omega)

/-- Level form of the four-class spread exclusion `(5; 3,3,2)`. -/
theorem level4_five_three_three_two (h5 : 1 ≤ levelCard L 5) (h3 : 3 ≤ levelCard L 3) :
    levelCard L 2 ≤ 3 := by
  by_contra hcon
  push_neg at hcon
  obtain ⟨d1, hd1⟩ := exists_of_levelCard_pos h5
  obtain ⟨d2, hd2mem, hd2ne⟩ :=
    exists_mem_ne (S := Finset.univ.filter
      (fun d : Option (ZMod 5) => 3 ≤ (classList L (some d)).length)) (x := d1)
      (by simpa [levelCard] using (by omega : 2 ≤ levelCard L 3))
  obtain ⟨d3, hd3mem, hd3ne1, hd3ne2⟩ :=
    exists_mem_ne₂ (S := Finset.univ.filter
      (fun d : Option (ZMod 5) => 3 ≤ (classList L (some d)).length)) (x := d1) (y := d2)
      (by simpa [levelCard] using h3)
  obtain ⟨d4, hd4mem, hd4ne1, hd4ne2, hd4ne3⟩ :=
    exists_mem_ne₃ (S := Finset.univ.filter
      (fun d : Option (ZMod 5) => 2 ≤ (classList L (some d)).length)) (x := d1) (y := d2) (z := d3)
      (by simpa [levelCard] using (by omega : 4 ≤ levelCard L 2))
  have hd2 := (mem_level_filter L 3 d2).1 hd2mem
  have hd3 := (mem_level_filter L 3 d3).1 hd3mem
  have hd4 := (mem_level_filter L 2 d4).1 hd4mem
  exact spread_exclusion4 hodd5' hfree (Ne.symm hd2ne) (Ne.symm hd3ne1) (Ne.symm hd4ne1)
    (Ne.symm hd3ne2) (Ne.symm hd4ne2) (Ne.symm hd4ne3) (by omega) (by omega)

/-- Level form of the four-class spread exclusion `(5; 4,2,2)`. -/
theorem level4_five_four_two_two (h5 : 1 ≤ levelCard L 5) (h4 : 2 ≤ levelCard L 4) :
    levelCard L 2 ≤ 3 := by
  by_contra hcon
  push_neg at hcon
  obtain ⟨d1, hd1⟩ := exists_of_levelCard_pos h5
  obtain ⟨d2, hd2mem, hd2ne⟩ :=
    exists_mem_ne (S := Finset.univ.filter
      (fun d : Option (ZMod 5) => 4 ≤ (classList L (some d)).length)) (x := d1)
      (by simpa [levelCard] using h4)
  obtain ⟨d3, hd3mem, hd3ne1, hd3ne2⟩ :=
    exists_mem_ne₂ (S := Finset.univ.filter
      (fun d : Option (ZMod 5) => 2 ≤ (classList L (some d)).length)) (x := d1) (y := d2)
      (by simpa [levelCard] using (by omega : 3 ≤ levelCard L 2))
  obtain ⟨d4, hd4mem, hd4ne1, hd4ne2, hd4ne3⟩ :=
    exists_mem_ne₃ (S := Finset.univ.filter
      (fun d : Option (ZMod 5) => 2 ≤ (classList L (some d)).length)) (x := d1) (y := d2) (z := d3)
      (by simpa [levelCard] using (by omega : 4 ≤ levelCard L 2))
  have hd2 := (mem_level_filter L 4 d2).1 hd2mem
  have hd3 := (mem_level_filter L 2 d3).1 hd3mem
  have hd4 := (mem_level_filter L 2 d4).1 hd4mem
  exact spread_exclusion4 hodd5' hfree (Ne.symm hd2ne) (Ne.symm hd3ne1) (Ne.symm hd4ne1)
    (Ne.symm hd3ne2) (Ne.symm hd4ne2) (Ne.symm hd4ne3) (by omega) (by omega)

/-- Level form of the four-class spread exclusion `(5; 4,3,1)`. -/
theorem level4_five_four_three_one (h5 : 1 ≤ levelCard L 5) (h4 : 2 ≤ levelCard L 4)
    (h3 : 3 ≤ levelCard L 3) : levelCard L 1 ≤ 3 := by
  by_contra hcon
  push_neg at hcon
  obtain ⟨d1, hd1⟩ := exists_of_levelCard_pos h5
  obtain ⟨d2, hd2mem, hd2ne⟩ :=
    exists_mem_ne (S := Finset.univ.filter
      (fun d : Option (ZMod 5) => 4 ≤ (classList L (some d)).length)) (x := d1)
      (by simpa [levelCard] using h4)
  obtain ⟨d3, hd3mem, hd3ne1, hd3ne2⟩ :=
    exists_mem_ne₂ (S := Finset.univ.filter
      (fun d : Option (ZMod 5) => 3 ≤ (classList L (some d)).length)) (x := d1) (y := d2)
      (by simpa [levelCard] using h3)
  obtain ⟨d4, hd4mem, hd4ne1, hd4ne2, hd4ne3⟩ :=
    exists_mem_ne₃ (S := Finset.univ.filter
      (fun d : Option (ZMod 5) => 1 ≤ (classList L (some d)).length)) (x := d1) (y := d2) (z := d3)
      (by simpa [levelCard] using (by omega : 4 ≤ levelCard L 1))
  have hd2 := (mem_level_filter L 4 d2).1 hd2mem
  have hd3 := (mem_level_filter L 3 d3).1 hd3mem
  have hd4 := (mem_level_filter L 1 d4).1 hd4mem
  exact spread_exclusion4 hodd5' hfree (Ne.symm hd2ne) (Ne.symm hd3ne1) (Ne.symm hd4ne1)
    (Ne.symm hd3ne2) (Ne.symm hd4ne2) (Ne.symm hd4ne3) (by omega) (by omega)

end Exclusions4

end Heis

open Heis

local instance factPrimeFive₄ : Fact (Nat.Prime 5) := ⟨by norm_num⟩

set_option maxHeartbeats 2000000 in
/-- The integer program behind the bound `20`: the level counts `s_k` of a
product-one-free sequence, subject to antitonicity, the bound `s₁ ≤ 6`, at most
`4` central entries, the class exclusions and the mixed block count, force the
total length to be at most `20`. -/
private lemma level_count_bound (s1 s2 s3 s4 s5 s6 s7 s8 c N : ℕ)
    (hN : N = c + (s1 + s2 + s3 + s4 + s5 + s6 + s7 + s8))
    (m21 : s2 ≤ s1) (m32 : s3 ≤ s2) (m43 : s4 ≤ s3) (m54 : s5 ≤ s4)
    (m65 : s6 ≤ s5) (m76 : s7 ≤ s6) (m87 : s8 ≤ s7)
    (h6 : s1 ≤ 6) (hc : c ≤ 4)
    (e4 : 1 ≤ s7 → 2 ≤ s4 → s2 ≤ 2)
    (e5 : 1 ≤ s8 → 2 ≤ s3 → s2 ≤ 2)
    (e6 : 1 ≤ s8 → s5 ≤ 1)
    (e7 : 1 ≤ s8 → 2 ≤ s4 → s1 ≤ 2)
    (e8 : 3 ≤ s4 → s1 ≤ 3)
    (f1 : 1 ≤ s4 → s3 ≤ 3)
    (f2 : 2 ≤ s4 → 3 ≤ s3 → s2 ≤ 3)
    (f3 : 1 ≤ s5 → 3 ≤ s3 → s2 ≤ 3)
    (f4 : 1 ≤ s5 → 2 ≤ s4 → s2 ≤ 3)
    (f5 : 1 ≤ s5 → 2 ≤ s4 → 3 ≤ s3 → s1 ≤ 3)
    (hmixed : s5 + c + (N - 5 * s5 - c) / 9 < 5) : N ≤ 20 := by
  rcases Nat.lt_or_ge s4 1 with h4 | h4
  · omega
  · have h3 := f1 h4
    rcases Nat.lt_or_ge s4 2 with h4' | h4'
    · omega
    · omega

/-- **Upper bound `20` for `H_125`.**  A product-one-free sequence over the
Heisenberg group of order `125` has length at most `20`. -/
theorem length_le_20_heis_five {L : List (Heis 5)} (hfree : ProductOneFree L) :
    L.length ≤ 20 := by
  classical
  have hodd : Odd 5 := by decide
  have hsplit : L.length = (classList L none).length
      + ∑ d : Option (ZMod 5), (classList L (some d)).length := by
    rw [length_eq_sum_filter (dirClass (p := 5)) L]
    exact Fintype.sum_option _
  have hclass : ∀ d : Option (ZMod 5), (classList L (some d)).length ≤ 8 := by
    intro d
    have := Heis.length_class_le hodd hfree d
    simpa using this
  have hlayer : ∑ d : Option (ZMod 5), (classList L (some d)).length
      = levelCard L 1 + levelCard L 2 + levelCard L 3 + levelCard L 4 + levelCard L 5
        + levelCard L 6 + levelCard L 7 + levelCard L 8 := by
    rw [sum_eq_layer_cake (fun d : Option (ZMod 5) => (classList L (some d)).length) hclass]
    simp only [Finset.sum_range_succ, Finset.sum_range_zero, levelCard, zero_add]
  have h21 : levelCard L 2 ≤ levelCard L 1 := levelCard_antitone (by norm_num)
  have h32 : levelCard L 3 ≤ levelCard L 2 := levelCard_antitone (by norm_num)
  have h43 : levelCard L 4 ≤ levelCard L 3 := levelCard_antitone (by norm_num)
  have h54 : levelCard L 5 ≤ levelCard L 4 := levelCard_antitone (by norm_num)
  have h65 : levelCard L 6 ≤ levelCard L 5 := levelCard_antitone (by norm_num)
  have h76 : levelCard L 7 ≤ levelCard L 6 := levelCard_antitone (by norm_num)
  have h87 : levelCard L 8 ≤ levelCard L 7 := levelCard_antitone (by norm_num)
  have hsix := levelCard_le_six L 1
  have hcentral : (classList L none).length ≤ 4 := by
    have := Heis.length_central_le (p := 5) hfree
    simpa using this
  -- the exclusions of `SpreadClassBound`
  have e4 : 1 ≤ levelCard L 7 → 2 ≤ levelCard L 4 → levelCard L 2 ≤ 2 := fun h h' =>
    level_seven_four_two hfree h h'
  have e5 : 1 ≤ levelCard L 8 → 2 ≤ levelCard L 3 → levelCard L 2 ≤ 2 := fun h h' =>
    level_eight_three_two hfree h h'
  have e6 : 1 ≤ levelCard L 8 → levelCard L 5 ≤ 1 := fun h => level_eight_five hfree h
  have e7 : 1 ≤ levelCard L 8 → 2 ≤ levelCard L 4 → levelCard L 1 ≤ 2 := fun h h' =>
    level_eight_four_one hfree h h'
  have e8 : 3 ≤ levelCard L 4 → levelCard L 1 ≤ 3 := fun h => level_four_one hfree h
  -- the new four-class exclusions
  have f1 : 1 ≤ levelCard L 4 → levelCard L 3 ≤ 3 := fun h => level4_four_three hfree h
  have f2 : 2 ≤ levelCard L 4 → 3 ≤ levelCard L 3 → levelCard L 2 ≤ 3 := fun h h' =>
    level4_four_four_three_two hfree h h'
  have f3 : 1 ≤ levelCard L 5 → 3 ≤ levelCard L 3 → levelCard L 2 ≤ 3 := fun h h' =>
    level4_five_three_three_two hfree h h'
  have f4 : 1 ≤ levelCard L 5 → 2 ≤ levelCard L 4 → levelCard L 2 ≤ 3 := fun h h' =>
    level4_five_four_two_two hfree h h'
  have f5 : 1 ≤ levelCard L 5 → 2 ≤ levelCard L 4 → 3 ≤ levelCard L 3 → levelCard L 1 ≤ 3 :=
    fun h h' h'' => level4_five_four_three_one hfree h h' h''
  -- the mixed block count
  have hmixed : levelCard L 5 + (classList L none).length
      + (L.length - 5 * levelCard L 5 - (classList L none).length) / 9 < 5 := by
    have h5 : 5 * levelCard L 5 ≤ ∑ d : Option (ZMod 5), (classList L (some d)).length := by
      have hle : ∑ d ∈ Finset.univ.filter
          (fun d : Option (ZMod 5) => 5 ≤ (classList L (some d)).length),
          (classList L (some d)).length
          ≤ ∑ d : Option (ZMod 5), (classList L (some d)).length :=
        Finset.sum_le_sum_of_subset (Finset.subset_univ _)
      have hge : (Finset.univ.filter
          (fun d : Option (ZMod 5) => 5 ≤ (classList L (some d)).length)).card * 5
          ≤ ∑ d ∈ Finset.univ.filter
            (fun d : Option (ZMod 5) => 5 ≤ (classList L (some d)).length),
            (classList L (some d)).length := by
        have := Finset.card_nsmul_le_sum (Finset.univ.filter
          (fun d : Option (ZMod 5) => 5 ≤ (classList L (some d)).length))
          (fun d => (classList L (some d)).length) 5
          (fun d hd => (mem_level_filter L 5 d).1 hd)
        simpa [mul_comm] using this
      simp only [levelCard]
      omega
    have hbound : 5 * levelCard L 5 + (classList L none).length
        + (L.length - 5 * levelCard L 5 - (classList L none).length) ≤ L.length := by omega
    have h := Heis.card_classes_central_plane_lt (p := 5) hfree
      (L.length - 5 * levelCard L 5 - (classList L none).length)
      (by simpa [levelCard] using hbound)
    simpa [levelCard] using h
  exact level_count_bound (levelCard L 1) (levelCard L 2) (levelCard L 3) (levelCard L 4)
    (levelCard L 5) (levelCard L 6) (levelCard L 7) (levelCard L 8)
    (classList L none).length L.length (by omega) h21 h32 h43 h54 h65 h76 h87 hsix hcentral
    e4 e5 e6 e7 e8 f1 f2 f3 f4 f5 hmixed

/-- `d(H_125) ≤ 20`. -/
theorem smallDavenport_heis_five_le_20 : smallDavenport (Heis 5) ≤ 20 := by
  refine csSup_le ⟨0, ⟨[], rfl, productOneFree_nil⟩⟩ ?_
  rintro n ⟨L, rfl, hL⟩
  exact length_le_20_heis_five hL

/-- The sharpest two-sided bound proved in this project for the Heisenberg
group of order `125`: `12 ≤ d(H_125) ≤ 20`. -/
theorem smallDavenport_heis_five_four_class_bounds :
    12 ≤ smallDavenport (Heis 5) ∧ smallDavenport (Heis 5) ≤ 20 :=
  ⟨twelve_le_smallDavenport_heis_five, smallDavenport_heis_five_le_20⟩

end Heisenberg125