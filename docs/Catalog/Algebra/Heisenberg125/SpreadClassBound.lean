/-
# `d(H_125) ≤ 23`

We feed the quantitative spread exclusion `Heis.spread_exclusion` into the
class count.  Write `s_k` for the number of direction classes of a
product-one-free sequence `L` over `Heis 5` carrying at least `k` entries and
`c` for the number of central entries.  The layer-cake identity turns the
length of `L` into

`|L| = c + s₁ + s₂ + ⋯ + s₈`   (each class has at most `2p - 2 = 8` entries),

and the exclusions proved so far constrain the `s_k`:

* `s₄ ≥ 3 → s₁ ≤ 3`         (four-class exclusion),
* `s₈ ≥ 1 → s₅ ≤ 1`         (heavy pair exclusion),
* `s₈ ≥ 1 ∧ s₄ ≥ 2 → s₁ ≤ 2` (heavy triple exclusion),
* `s₅ ≥ 1 → s₄ ≤ 2`         (spread exclusion `(5,4,4)`),
* `s₆ ≥ 1 ∧ s₄ ≥ 2 → s₃ ≤ 2` (spread exclusion `(6,4,3)`),
* `s₇ ≥ 1 → s₃ ≤ 2`         (spread exclusion `(7,3,3)`),
* `s₇ ≥ 1 ∧ s₄ ≥ 2 → s₂ ≤ 2` (spread exclusion `(7,4,2)`),
* `s₈ ≥ 1 ∧ s₃ ≥ 2 → s₂ ≤ 2` (spread exclusion `(8,3,2)`),

together with the mixed block count `s₅ + c + ⌊(|L| - 5 s₅ - c)/9⌋ ≤ 4`.  The
resulting integer program has optimum `23`, attained by the count vector
`(6,3,3,3,3,3)` with two central entries — so `d(H_125) ≤ 23`, improving the
previous bound `27`.
-/
import Algebra.Heisenberg125.SpreadExclusion

namespace Heisenberg125

namespace Heis

/-- `5` is prime; made available as an instance for this file. -/
local instance factPrimeFive : Fact (Nat.Prime 5) := ⟨by norm_num⟩

/-! ### Three combinatorial helpers -/

/-- A finset with at least two elements contains an element different from any
prescribed one. -/
lemma exists_mem_ne {α : Type*} [DecidableEq α] {S : Finset α} {x : α} (h : 2 ≤ S.card) :
    ∃ y ∈ S, y ≠ x := by
  have h1 : 1 ≤ (S.erase x).card := by
    have := Finset.pred_card_le_card_erase (s := S) (a := x)
    omega
  obtain ⟨y, hy⟩ := Finset.card_pos.1 h1
  exact ⟨y, Finset.mem_of_mem_erase hy, Finset.ne_of_mem_erase hy⟩

/-- A finset with at least three elements contains an element different from
any two prescribed ones. -/
lemma exists_mem_ne₂ {α : Type*} [DecidableEq α] {S : Finset α} {x y : α} (h : 3 ≤ S.card) :
    ∃ z ∈ S, z ≠ x ∧ z ≠ y := by
  have h1 : 2 ≤ (S.erase x).card := by
    have := Finset.pred_card_le_card_erase (s := S) (a := x)
    omega
  obtain ⟨z, hz, hzy⟩ := exists_mem_ne (S := S.erase x) (x := y) h1
  exact ⟨z, Finset.mem_of_mem_erase hz, Finset.ne_of_mem_erase hz, hzy⟩

/-- A finset with at least four elements contains an element different from
any three prescribed ones. -/
lemma exists_mem_ne₃ {α : Type*} [DecidableEq α] {S : Finset α} {x y z : α} (h : 4 ≤ S.card) :
    ∃ w ∈ S, w ≠ x ∧ w ≠ y ∧ w ≠ z := by
  have h1 : 3 ≤ (S.erase x).card := by
    have := Finset.pred_card_le_card_erase (s := S) (a := x)
    omega
  obtain ⟨w, hw, hwy, hwz⟩ := exists_mem_ne₂ (S := S.erase x) (x := y) (y := z) h1
  exact ⟨w, Finset.mem_of_mem_erase hw, Finset.ne_of_mem_erase hw, hwy, hwz⟩

/-- The elementary layer-cake identity for a single natural number. -/
lemma sum_indicator_range (m B : ℕ) :
    ∑ k ∈ Finset.range B, (if k + 1 ≤ m then 1 else 0) = min m B := by
  induction B with
  | zero => simp
  | succ B ih =>
      rw [Finset.sum_range_succ, ih]
      by_cases h : B + 1 ≤ m
      · simp only [h, if_true]; omega
      · simp only [h, if_false]; omega

/-- Layer-cake: the sum of a bounded function over a finite type is the sum of
the level-set cardinalities. -/
lemma sum_eq_layer_cake {β : Type*} [Fintype β] (n : β → ℕ) {B : ℕ} (hB : ∀ b, n b ≤ B) :
    ∑ b, n b = ∑ k ∈ Finset.range B, (Finset.univ.filter (fun b => k + 1 ≤ n b)).card := by
  simp_rw [Finset.card_filter]
  rw [Finset.sum_comm]
  refine Finset.sum_congr rfl fun b _ => ?_
  rw [sum_indicator_range (n b) B, Nat.min_eq_left (hB b)]

/-! ### Level counts of direction classes -/

/-- The number of direction classes of `L` carrying at least `k` entries. -/
noncomputable def levelCard (L : List (Heis 5)) (k : ℕ) : ℕ :=
  (Finset.univ.filter (fun d : Option (ZMod 5) => k ≤ (classList L (some d)).length)).card

lemma mem_level_filter (L : List (Heis 5)) (k : ℕ) (d : Option (ZMod 5)) :
    d ∈ Finset.univ.filter (fun d : Option (ZMod 5) => k ≤ (classList L (some d)).length)
      ↔ k ≤ (classList L (some d)).length := by
  simp

lemma levelCard_antitone {L : List (Heis 5)} {k l : ℕ} (h : k ≤ l) :
    levelCard L l ≤ levelCard L k := by
  refine Finset.card_le_card ?_
  intro d hd
  rw [mem_level_filter] at hd ⊢
  omega

lemma levelCard_le_six (L : List (Heis 5)) (k : ℕ) : levelCard L k ≤ 6 := by
  have h := Finset.card_le_univ
    (Finset.univ.filter (fun d : Option (ZMod 5) => k ≤ (classList L (some d)).length))
  have hcard : Fintype.card (Option (ZMod 5)) = 6 := by simp [ZMod.card]
  simpa [levelCard, Finset.card_univ, hcard] using h

/-- If the `k`-th level set is nonempty, some direction carries `k` entries. -/
lemma exists_of_levelCard_pos {L : List (Heis 5)} {k : ℕ} (h : 1 ≤ levelCard L k) :
    ∃ d : Option (ZMod 5), k ≤ (classList L (some d)).length := by
  have hpos : 0 < (Finset.univ.filter
      (fun d : Option (ZMod 5) => k ≤ (classList L (some d)).length)).card := by
    simpa [levelCard] using h
  obtain ⟨d, hd⟩ := Finset.card_pos.1 hpos
  exact ⟨d, (mem_level_filter L k d).1 hd⟩

/-! ### The exclusions in level form -/

section Exclusions

variable {L : List (Heis 5)} (hfree : ProductOneFree L)

private lemma hodd5 : Odd 5 := by decide

include hfree

/-- Spread exclusion `(5,4,4)`: a class with `5` entries forbids three classes
with `4` entries. -/
theorem level_five_four (h5 : 1 ≤ levelCard L 5) : levelCard L 4 ≤ 2 := by
  by_contra hcon
  push_neg at hcon
  obtain ⟨d1, hd1⟩ := exists_of_levelCard_pos h5
  obtain ⟨d2, hd2mem, hd2ne⟩ :=
    exists_mem_ne (S := Finset.univ.filter
      (fun d : Option (ZMod 5) => 4 ≤ (classList L (some d)).length)) (x := d1)
      (by simpa [levelCard] using (by omega : 2 ≤ levelCard L 4))
  obtain ⟨d3, hd3mem, hd3ne1, hd3ne2⟩ :=
    exists_mem_ne₂ (S := Finset.univ.filter
      (fun d : Option (ZMod 5) => 4 ≤ (classList L (some d)).length)) (x := d1) (y := d2)
      (by simpa [levelCard] using (by omega : 3 ≤ levelCard L 4))
  have hd2 := (mem_level_filter L 4 d2).1 hd2mem
  have hd3 := (mem_level_filter L 4 d3).1 hd3mem
  exact spread_exclusion hodd5 hfree (Ne.symm hd2ne) (Ne.symm hd3ne1) (Ne.symm hd3ne2)
    (by omega) (by omega)

/-- Spread exclusion `(6,4,3)`. -/
theorem level_six_four_three (h6 : 1 ≤ levelCard L 6) (h4 : 2 ≤ levelCard L 4) :
    levelCard L 3 ≤ 2 := by
  by_contra hcon
  push_neg at hcon
  obtain ⟨d1, hd1⟩ := exists_of_levelCard_pos h6
  obtain ⟨d2, hd2mem, hd2ne⟩ :=
    exists_mem_ne (S := Finset.univ.filter
      (fun d : Option (ZMod 5) => 4 ≤ (classList L (some d)).length)) (x := d1)
      (by simpa [levelCard] using h4)
  obtain ⟨d3, hd3mem, hd3ne1, hd3ne2⟩ :=
    exists_mem_ne₂ (S := Finset.univ.filter
      (fun d : Option (ZMod 5) => 3 ≤ (classList L (some d)).length)) (x := d1) (y := d2)
      (by simpa [levelCard] using (by omega : 3 ≤ levelCard L 3))
  have hd2 := (mem_level_filter L 4 d2).1 hd2mem
  have hd3 := (mem_level_filter L 3 d3).1 hd3mem
  exact spread_exclusion hodd5 hfree (Ne.symm hd2ne) (Ne.symm hd3ne1) (Ne.symm hd3ne2)
    (by omega) (by omega)

/-- Spread exclusion `(7,3,3)`. -/
theorem level_seven_three (h7 : 1 ≤ levelCard L 7) : levelCard L 3 ≤ 2 := by
  by_contra hcon
  push_neg at hcon
  obtain ⟨d1, hd1⟩ := exists_of_levelCard_pos h7
  obtain ⟨d2, hd2mem, hd2ne⟩ :=
    exists_mem_ne (S := Finset.univ.filter
      (fun d : Option (ZMod 5) => 3 ≤ (classList L (some d)).length)) (x := d1)
      (by simpa [levelCard] using (by omega : 2 ≤ levelCard L 3))
  obtain ⟨d3, hd3mem, hd3ne1, hd3ne2⟩ :=
    exists_mem_ne₂ (S := Finset.univ.filter
      (fun d : Option (ZMod 5) => 3 ≤ (classList L (some d)).length)) (x := d1) (y := d2)
      (by simpa [levelCard] using (by omega : 3 ≤ levelCard L 3))
  have hd2 := (mem_level_filter L 3 d2).1 hd2mem
  have hd3 := (mem_level_filter L 3 d3).1 hd3mem
  exact spread_exclusion hodd5 hfree (Ne.symm hd2ne) (Ne.symm hd3ne1) (Ne.symm hd3ne2)
    (by omega) (by omega)

/-- Spread exclusion `(7,4,2)`. -/
theorem level_seven_four_two (h7 : 1 ≤ levelCard L 7) (h4 : 2 ≤ levelCard L 4) :
    levelCard L 2 ≤ 2 := by
  by_contra hcon
  push_neg at hcon
  obtain ⟨d1, hd1⟩ := exists_of_levelCard_pos h7
  obtain ⟨d2, hd2mem, hd2ne⟩ :=
    exists_mem_ne (S := Finset.univ.filter
      (fun d : Option (ZMod 5) => 4 ≤ (classList L (some d)).length)) (x := d1)
      (by simpa [levelCard] using h4)
  obtain ⟨d3, hd3mem, hd3ne1, hd3ne2⟩ :=
    exists_mem_ne₂ (S := Finset.univ.filter
      (fun d : Option (ZMod 5) => 2 ≤ (classList L (some d)).length)) (x := d1) (y := d2)
      (by simpa [levelCard] using (by omega : 3 ≤ levelCard L 2))
  have hd2 := (mem_level_filter L 4 d2).1 hd2mem
  have hd3 := (mem_level_filter L 2 d3).1 hd3mem
  exact spread_exclusion hodd5 hfree (Ne.symm hd2ne) (Ne.symm hd3ne1) (Ne.symm hd3ne2)
    (by omega) (by omega)

/-- Spread exclusion `(8,3,2)`. -/
theorem level_eight_three_two (h8 : 1 ≤ levelCard L 8) (h3 : 2 ≤ levelCard L 3) :
    levelCard L 2 ≤ 2 := by
  by_contra hcon
  push_neg at hcon
  obtain ⟨d1, hd1⟩ := exists_of_levelCard_pos h8
  obtain ⟨d2, hd2mem, hd2ne⟩ :=
    exists_mem_ne (S := Finset.univ.filter
      (fun d : Option (ZMod 5) => 3 ≤ (classList L (some d)).length)) (x := d1)
      (by simpa [levelCard] using h3)
  obtain ⟨d3, hd3mem, hd3ne1, hd3ne2⟩ :=
    exists_mem_ne₂ (S := Finset.univ.filter
      (fun d : Option (ZMod 5) => 2 ≤ (classList L (some d)).length)) (x := d1) (y := d2)
      (by simpa [levelCard] using (by omega : 3 ≤ levelCard L 2))
  have hd2 := (mem_level_filter L 3 d2).1 hd2mem
  have hd3 := (mem_level_filter L 2 d3).1 hd3mem
  exact spread_exclusion hodd5 hfree (Ne.symm hd2ne) (Ne.symm hd3ne1) (Ne.symm hd3ne2)
    (by omega) (by omega)

/-- Heavy pair exclusion in level form: a class with `2p - 2 = 8` entries
forbids a second class with `p = 5` entries. -/
theorem level_eight_five (h8 : 1 ≤ levelCard L 8) : levelCard L 5 ≤ 1 := by
  by_contra hcon
  push_neg at hcon
  obtain ⟨d1, hd1⟩ := exists_of_levelCard_pos h8
  obtain ⟨d2, hd2mem, hd2ne⟩ :=
    exists_mem_ne (S := Finset.univ.filter
      (fun d : Option (ZMod 5) => 5 ≤ (classList L (some d)).length)) (x := d1)
      (by simpa [levelCard] using (by omega : 2 ≤ levelCard L 5))
  have hd2 := (mem_level_filter L 5 d2).1 hd2mem
  exact heavy_pair_exclusion hodd5 hfree (Ne.symm hd2ne) (by omega) (by omega)

/-- Heavy triple exclusion in level form. -/
theorem level_eight_four_one (h8 : 1 ≤ levelCard L 8) (h4 : 2 ≤ levelCard L 4) :
    levelCard L 1 ≤ 2 := by
  by_contra hcon
  push_neg at hcon
  obtain ⟨d1, hd1⟩ := exists_of_levelCard_pos h8
  obtain ⟨d2, hd2mem, hd2ne⟩ :=
    exists_mem_ne (S := Finset.univ.filter
      (fun d : Option (ZMod 5) => 4 ≤ (classList L (some d)).length)) (x := d1)
      (by simpa [levelCard] using h4)
  obtain ⟨d3, hd3mem, hd3ne1, hd3ne2⟩ :=
    exists_mem_ne₂ (S := Finset.univ.filter
      (fun d : Option (ZMod 5) => 1 ≤ (classList L (some d)).length)) (x := d1) (y := d2)
      (by simpa [levelCard] using (by omega : 3 ≤ levelCard L 1))
  have hd2 := (mem_level_filter L 4 d2).1 hd2mem
  have hd3 := (mem_level_filter L 1 d3).1 hd3mem
  have hne : classList L (some d3) ≠ [] := by
    intro hnil
    rw [hnil] at hd3
    simp at hd3
  exact heavy_triple_exclusion hodd5 hfree (Ne.symm hd2ne) (Ne.symm hd3ne1) (Ne.symm hd3ne2)
    (by omega) (by omega) hne

/-- Four-class exclusion in level form. -/
theorem level_four_one (h4 : 3 ≤ levelCard L 4) : levelCard L 1 ≤ 3 := by
  by_contra hcon
  push_neg at hcon
  obtain ⟨d1, hd1⟩ := exists_of_levelCard_pos (L := L) (k := 4) (by omega)
  obtain ⟨d2, hd2mem, hd2ne⟩ :=
    exists_mem_ne (S := Finset.univ.filter
      (fun d : Option (ZMod 5) => 4 ≤ (classList L (some d)).length)) (x := d1)
      (by simpa [levelCard] using (by omega : 2 ≤ levelCard L 4))
  obtain ⟨d3, hd3mem, hd3ne1, hd3ne2⟩ :=
    exists_mem_ne₂ (S := Finset.univ.filter
      (fun d : Option (ZMod 5) => 4 ≤ (classList L (some d)).length)) (x := d1) (y := d2)
      (by simpa [levelCard] using h4)
  obtain ⟨d4, hd4mem, hd4ne1, hd4ne2, hd4ne3⟩ :=
    exists_mem_ne₃ (S := Finset.univ.filter
      (fun d : Option (ZMod 5) => 1 ≤ (classList L (some d)).length)) (x := d1) (y := d2) (z := d3)
      (by simpa [levelCard] using (by omega : 4 ≤ levelCard L 1))
  have hd2 := (mem_level_filter L 4 d2).1 hd2mem
  have hd3 := (mem_level_filter L 4 d3).1 hd3mem
  have hd4 := (mem_level_filter L 1 d4).1 hd4mem
  have hne : classList L (some d4) ≠ [] := by
    intro hnil
    rw [hnil] at hd4
    simp at hd4
  exact four_class_exclusion hodd5 hfree (Ne.symm hd2ne) (Ne.symm hd3ne1) (Ne.symm hd4ne1)
    (Ne.symm hd3ne2) (Ne.symm hd4ne2) (Ne.symm hd4ne3) (by omega) (by omega) (by omega) hne

end Exclusions

end Heis

/-! ### The improved bound -/

open Heis

local instance factPrimeFive' : Fact (Nat.Prime 5) := ⟨by norm_num⟩

set_option maxHeartbeats 1000000 in
/-- **Improved upper bound for `H_125`.**  A product-one-free sequence over the
Heisenberg group of order `125` has length at most `23`. -/
theorem length_le_23_heis_five {L : List (Heis 5)} (hfree : ProductOneFree L) :
    L.length ≤ 23 := by
  classical
  have hodd : Odd 5 := by decide
  -- the length as centre plus classes
  have hsplit : L.length = (classList L none).length
      + ∑ d : Option (ZMod 5), (classList L (some d)).length := by
    rw [length_eq_sum_filter (dirClass (p := 5)) L]
    exact Fintype.sum_option _
  have hclass : ∀ d : Option (ZMod 5), (classList L (some d)).length ≤ 8 := by
    intro d
    have := Heis.length_class_le hodd hfree d
    simpa using this
  -- layer cake
  have hlayer : ∑ d : Option (ZMod 5), (classList L (some d)).length
      = levelCard L 1 + levelCard L 2 + levelCard L 3 + levelCard L 4 + levelCard L 5
        + levelCard L 6 + levelCard L 7 + levelCard L 8 := by
    rw [sum_eq_layer_cake (fun d : Option (ZMod 5) => (classList L (some d)).length) hclass]
    simp only [Finset.sum_range_succ, Finset.sum_range_zero, levelCard, zero_add]
  -- monotonicity and the crude bounds
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
  -- the exclusions
  have e1 : 1 ≤ levelCard L 5 → levelCard L 4 ≤ 2 := fun h => level_five_four hfree h
  have e2 : 1 ≤ levelCard L 6 → 2 ≤ levelCard L 4 → levelCard L 3 ≤ 2 := fun h h' =>
    level_six_four_three hfree h h'
  have e3 : 1 ≤ levelCard L 7 → levelCard L 3 ≤ 2 := fun h => level_seven_three hfree h
  have e4 : 1 ≤ levelCard L 7 → 2 ≤ levelCard L 4 → levelCard L 2 ≤ 2 := fun h h' =>
    level_seven_four_two hfree h h'
  have e5 : 1 ≤ levelCard L 8 → 2 ≤ levelCard L 3 → levelCard L 2 ≤ 2 := fun h h' =>
    level_eight_three_two hfree h h'
  have e6 : 1 ≤ levelCard L 8 → levelCard L 5 ≤ 1 := fun h => level_eight_five hfree h
  have e7 : 1 ≤ levelCard L 8 → 2 ≤ levelCard L 4 → levelCard L 1 ≤ 2 := fun h h' =>
    level_eight_four_one hfree h h'
  have e8 : 3 ≤ levelCard L 4 → levelCard L 1 ≤ 3 := fun h => level_four_one hfree h
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
  omega

/-- `d(H_125) ≤ 23`. -/
theorem smallDavenport_heis_five_le_23 : smallDavenport (Heis 5) ≤ 23 := by
  refine csSup_le ⟨0, ⟨[], rfl, productOneFree_nil⟩⟩ ?_
  rintro n ⟨L, rfl, hL⟩
  exact length_le_23_heis_five hL

/-- The sharpest two-sided bound proved in this project for the Heisenberg
group of order `125`: `12 ≤ d(H_125) ≤ 23`. -/
theorem smallDavenport_heis_five_spread_class_bounds :
    12 ≤ smallDavenport (Heis 5) ∧ smallDavenport (Heis 5) ≤ 23 :=
  ⟨twelve_le_smallDavenport_heis_five, smallDavenport_heis_five_le_23⟩

end Heisenberg125