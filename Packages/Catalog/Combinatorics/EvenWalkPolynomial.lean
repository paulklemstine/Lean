/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Every moment is a polynomial in `N`: the binomial expansion of the even-walk counts

Combining the dictionary of `Combinatorics.EvenClosedWalks` (moments = counts of even
closed walks), the relabeling invariance of `Combinatorics.EvenWalkRelabeling`, and the
vertex bound of `Combinatorics.EvenWalkVertexBound`, we obtain a *structure theorem*
for the spectral moments of the symmetric Rademacher ensemble:

* `evenClosedWalkCount_eq_sum_choose`: for every length `L`,
  `evenClosedWalkCount N L = ∑ r, (N choose r) * surjEvenWalkCount r L`,
  where `surjEvenWalkCount r L` counts the even closed `L`-walks that *use all* of
  `r` vertices.  In particular every moment is a polynomial in `N`, with coefficients
  in the binomial basis given by finitely many "shape" counts that do not depend on
  `N` at all.
* `surjEvenWalkCount_eq_zero_of_lt`: those shape counts vanish as soon as
  `2 r > L + 2`, so the polynomial has degree at most `L / 2 + 1`.
* `evenClosedWalkCount_le`: hence `evenClosedWalkCount N (2k) ≤ c_k N^(k+1)` with an
  explicit combinatorial constant, i.e. `E [tr W^(2k)] = O(N^(k+1))` at all orders.
* `evenClosedWalkCount_six` and `expect_trace_W_six`: the shape counts at `L = 6` are
  `(2, 60, 120)`, giving the **exact sixth trace moment**
  `E [tr W^6] = N(N-1)(5N² - 15N + 11)`, a new order beyond the second and fourth
  moments of `Probability.WignerRademacherEnsemble`.
-/
import Combinatorics.EvenWalkVertexBound

open Finset RademacherWigner

namespace EvenWalks

variable {N L : ℕ}

/-- The number of even closed `L`-walks on `r` vertices that visit *every* vertex.
These are the `N`-independent "shapes" out of which all moments are assembled. -/
def surjEvenWalkCount (r L : ℕ) [NeZero L] : ℕ :=
  (Finset.univ.filter
    fun w : Fin L → Fin r => IsEvenClosedWalk w ∧ Function.Surjective w).card

/-- The even closed walks with a prescribed vertex set `S` are, after relabeling, the
surjective even closed walks on `S.card` vertices. -/
theorem card_walks_with_vertexSet [NeZero L] (S : Finset (Fin N)) :
    (Finset.univ.filter
        fun w : Fin L → Fin N => IsEvenClosedWalk w ∧ walkVertices w = S).card
      = surjEvenWalkCount S.card L := by
  classical
  set ι : Fin S.card → Fin N := fun j => (S.equivFin.symm j : Fin N) with hι
  have hι_inj : Function.Injective ι := by
    intro j j' h
    exact S.equivFin.symm.injective (Subtype.ext h)
  have hι_mem : ∀ j, ι j ∈ S := fun j => (S.equivFin.symm j).2
  have hι_onto : ∀ x ∈ S, ∃ j, ι j = x := by
    intro x hx
    exact ⟨S.equivFin ⟨x, hx⟩, by simp [hι]⟩
  symm
  refine Finset.card_bij (fun u _ => fun t => ι (u t)) ?_ ?_ ?_
  · rintro u hu
    obtain ⟨heven, hsurj⟩ := (Finset.mem_filter.1 hu).2
    refine Finset.mem_filter.2 ⟨Finset.mem_univ _, ?_, ?_⟩
    · exact (isEvenClosedWalk_comp_iff hι_inj u).2 heven
    · ext x
      simp only [mem_walkVertices]
      constructor
      · rintro ⟨t, rfl⟩
        exact hι_mem _
      · intro hx
        obtain ⟨j, hj⟩ := hι_onto x hx
        obtain ⟨t, ht⟩ := hsurj j
        exact ⟨t, by rw [ht, hj]⟩
  · intro u _ u' _ h
    funext t
    exact hι_inj (congrFun h t)
  · intro w hw
    obtain ⟨heven, hvert⟩ := (Finset.mem_filter.1 hw).2
    have hmem : ∀ t, w t ∈ S := by
      intro t
      rw [← hvert]
      exact mem_walkVertices.2 ⟨t, rfl⟩
    refine ⟨fun t => S.equivFin ⟨w t, hmem t⟩, ?_, ?_⟩
    · refine Finset.mem_filter.2 ⟨Finset.mem_univ _, ?_, ?_⟩
      · refine (isEvenClosedWalk_comp_iff hι_inj _).1 ?_
        have : (fun t => ι (S.equivFin ⟨w t, hmem t⟩)) = w := by
          funext t
          simp [hι]
        rw [this]
        exact heven
      · intro j
        have hx : ι j ∈ S := hι_mem j
        rw [← hvert] at hx
        obtain ⟨t, ht⟩ := mem_walkVertices.1 hx
        refine ⟨t, ?_⟩
        show S.equivFin ⟨w t, hmem t⟩ = j
        rw [Equiv.apply_eq_iff_eq_symm_apply]
        refine Subtype.ext ?_
        show w t = ((S.equivFin.symm j : { x // x ∈ S }) : Fin N)
        rw [ht, hι]
    · funext t
      simp [hι]

/-- No surjective walk of length `L` onto more than `L` vertices exists. -/
theorem surjEvenWalkCount_eq_zero_of_card_lt (r L : ℕ) [NeZero L] (h : L < r) :
    surjEvenWalkCount r L = 0 := by
  rw [surjEvenWalkCount, Finset.card_eq_zero, Finset.filter_eq_empty_iff]
  rintro w - ⟨-, hsurj⟩
  have := Fintype.card_le_of_surjective w hsurj
  simp only [Fintype.card_fin] at this
  omega

/-- **Polynomiality of the moment counts.**  The number of even closed `L`-walks on
`N` vertices is `∑ r ≤ L, (N choose r) * surjEvenWalkCount r L`: a polynomial in `N`
whose coefficients in the binomial basis are pure shape counts. -/
theorem evenClosedWalkCount_eq_sum_choose (N L : ℕ) [NeZero L] :
    evenClosedWalkCount N L
      = ∑ r ∈ Finset.range (L + 1), N.choose r * surjEvenWalkCount r L := by
  classical
  have hfib : evenClosedWalkCount N L
      = ∑ S ∈ (Finset.univ : Finset (Finset (Fin N))),
          (Finset.univ.filter
            fun w : Fin L → Fin N => IsEvenClosedWalk w ∧ walkVertices w = S).card := by
    rw [evenClosedWalkCount,
      Finset.card_eq_sum_card_fiberwise
        (f := walkVertices) (t := (Finset.univ : Finset (Finset (Fin N))))
        (fun w _ => Finset.mem_coe.2 (Finset.mem_univ _))]
    refine Finset.sum_congr rfl fun S _ => ?_
    congr 1
    rw [Finset.filter_filter]
  have hshape : ∀ S : Finset (Fin N),
      (Finset.univ.filter
        fun w : Fin L → Fin N => IsEvenClosedWalk w ∧ walkVertices w = S).card
        = surjEvenWalkCount S.card L := fun S => card_walks_with_vertexSet S
  rw [hfib, Finset.sum_congr rfl fun S _ => hshape S]
  -- group the vertex sets by their cardinality
  have hmaps : ∀ S ∈ (Finset.univ : Finset (Finset (Fin N))),
      S.card ∈ Finset.range (N + 1) := by
    intro S _
    have : S.card ≤ N := by
      simpa using Finset.card_le_univ S
    simpa using Nat.lt_succ_of_le this
  rw [← Finset.sum_fiberwise_of_maps_to hmaps (fun S => surjEvenWalkCount S.card L)]
  have hinner : ∀ r ∈ Finset.range (N + 1),
      (∑ S ∈ (Finset.univ : Finset (Finset (Fin N))) with S.card = r,
        surjEvenWalkCount S.card L) = N.choose r * surjEvenWalkCount r L := by
    intro r _
    rw [Finset.sum_congr rfl (g := fun _ => surjEvenWalkCount r L)
      (fun S hS => by rw [(Finset.mem_filter.1 hS).2]), Finset.sum_const, smul_eq_mul]
    congr 1
    have : (Finset.univ.filter fun S : Finset (Fin N) => S.card = r)
        = Finset.powersetCard r Finset.univ := by
      ext S
      simp
    rw [this, Finset.card_powersetCard]
    simp
  rw [Finset.sum_congr rfl hinner]
  -- both index ranges give the same sum
  have hsub1 : Finset.range (N + 1) ⊆ Finset.range (N + L + 2) := by
    intro x hx
    simp only [Finset.mem_range] at hx ⊢
    omega
  have hsub2 : Finset.range (L + 1) ⊆ Finset.range (N + L + 2) := by
    intro x hx
    simp only [Finset.mem_range] at hx ⊢
    omega
  have e1 : (∑ r ∈ Finset.range (N + 1), N.choose r * surjEvenWalkCount r L)
      = ∑ r ∈ Finset.range (N + L + 2), N.choose r * surjEvenWalkCount r L :=
    Finset.sum_subset hsub1 fun r _ hr => by
      rw [Nat.choose_eq_zero_of_lt (by simpa using hr), zero_mul]
  have e2 : (∑ r ∈ Finset.range (L + 1), N.choose r * surjEvenWalkCount r L)
      = ∑ r ∈ Finset.range (N + L + 2), N.choose r * surjEvenWalkCount r L :=
    Finset.sum_subset hsub2 fun r _ hr => by
      rw [surjEvenWalkCount_eq_zero_of_card_lt r L (by simpa using hr), mul_zero]
  rw [e1, e2]

/-- **Degree bound.**  A surjective even closed `L`-walk on `r` vertices forces
`2r ≤ L + 2`; beyond that the shape counts vanish. -/
theorem surjEvenWalkCount_eq_zero_of_lt (r L : ℕ) [NeZero L] (h : L + 2 < 2 * r) :
    surjEvenWalkCount r L = 0 := by
  rw [surjEvenWalkCount, Finset.card_eq_zero, Finset.filter_eq_empty_iff]
  rintro w - ⟨hw, hsurj⟩
  have hV : walkVertices w = Finset.univ := by
    ext u
    simp only [mem_walkVertices, Finset.mem_univ, iff_true]
    exact hsurj u
  have hb := two_mul_card_walkVertices_le hw
  rw [hV, Finset.card_univ, Fintype.card_fin] at hb
  omega

/-- **All even moments are `O(N^(k+1))`, with an explicit combinatorial constant.**
The number of even closed walks of length `2k + 2` is at most the total number of
shapes times `N^(k+2)`. -/
theorem evenClosedWalkCount_le (N k : ℕ) :
    evenClosedWalkCount N (2 * k + 2)
      ≤ (∑ r ∈ Finset.range (k + 3), surjEvenWalkCount r (2 * k + 2)) * N ^ (k + 2) := by
  rcases Nat.eq_zero_or_pos N with rfl | hN
  · have hzero : evenClosedWalkCount 0 (2 * k + 2) = 0 := by
      simp [evenClosedWalkCount, Finset.univ_eq_empty]
    simp [hzero]
  · rw [evenClosedWalkCount_eq_sum_choose]
    have hsub : Finset.range (k + 3) ⊆ Finset.range (2 * k + 2 + 1) := by
      intro x hx
      simp only [Finset.mem_range] at hx ⊢
      omega
    have hvanish : ∀ r ∈ Finset.range (2 * k + 2 + 1), r ∉ Finset.range (k + 3) →
        N.choose r * surjEvenWalkCount r (2 * k + 2) = 0 := by
      intro r _ hr
      simp only [Finset.mem_range, not_lt] at hr
      rw [surjEvenWalkCount_eq_zero_of_lt r (2 * k + 2) (by omega), mul_zero]
    rw [← Finset.sum_subset hsub hvanish, Finset.sum_mul]
    refine Finset.sum_le_sum fun r hr => ?_
    simp only [Finset.mem_range] at hr
    calc N.choose r * surjEvenWalkCount r (2 * k + 2)
        ≤ N ^ r * surjEvenWalkCount r (2 * k + 2) :=
          Nat.mul_le_mul_right _ (Nat.choose_le_pow N r)
      _ ≤ N ^ (k + 2) * surjEvenWalkCount r (2 * k + 2) :=
          Nat.mul_le_mul_right _ (Nat.pow_le_pow_right hN (by omega))
      _ = surjEvenWalkCount r (2 * k + 2) * N ^ (k + 2) := by ring

/-! ### The shape counts at length six

The three surviving shapes at length `6` are counted by exhaustive verification:
`2` walks use two vertices (the doubled edge traversed three times), `60` use three
vertices, and `120` use four vertices (the doubled spanning trees on four vertices:
`12` paths contributing `6` each and `4` stars contributing `12` each).  Five or more
vertices are impossible by the vertex bound. -/

theorem surjEvenWalkCount_zero_six : surjEvenWalkCount 0 6 = 0 := by decide

theorem surjEvenWalkCount_one_six : surjEvenWalkCount 1 6 = 0 := by decide

set_option maxRecDepth 40000 in
theorem surjEvenWalkCount_two_six : surjEvenWalkCount 2 6 = 2 := by decide

set_option maxRecDepth 400000 in
set_option maxHeartbeats 1000000 in
theorem surjEvenWalkCount_three_six : surjEvenWalkCount 3 6 = 60 := by decide

set_option maxRecDepth 4000000 in
set_option maxHeartbeats 4000000 in
theorem surjEvenWalkCount_four_six : surjEvenWalkCount 4 6 = 120 := by decide

theorem surjEvenWalkCount_five_six : surjEvenWalkCount 5 6 = 0 :=
  surjEvenWalkCount_eq_zero_of_lt 5 6 (by norm_num)

theorem surjEvenWalkCount_six_six : surjEvenWalkCount 6 6 = 0 :=
  surjEvenWalkCount_eq_zero_of_lt 6 6 (by norm_num)

/-- **Exact count of even closed 6-walks.**  In the binomial basis the count is
`2 C(N,2) + 60 C(N,3) + 120 C(N,4)`. -/
theorem evenClosedWalkCount_six (N : ℕ) :
    evenClosedWalkCount N 6
      = 2 * N.choose 2 + 60 * N.choose 3 + 120 * N.choose 4 := by
  rw [evenClosedWalkCount_eq_sum_choose]
  rw [Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ,
    Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ,
    Finset.sum_range_one]
  rw [surjEvenWalkCount_zero_six, surjEvenWalkCount_one_six, surjEvenWalkCount_two_six,
    surjEvenWalkCount_three_six, surjEvenWalkCount_four_six, surjEvenWalkCount_five_six,
    surjEvenWalkCount_six_six]
  ring

/-- The same count written with falling factorials:
`N^(2) + 10 N^(3) + 5 N^(4)`. -/
theorem evenClosedWalkCount_six_descFactorial (N : ℕ) :
    evenClosedWalkCount N 6
      = N.descFactorial 2 + 10 * N.descFactorial 3 + 5 * N.descFactorial 4 := by
  rw [evenClosedWalkCount_six, Nat.descFactorial_eq_factorial_mul_choose,
    Nat.descFactorial_eq_factorial_mul_choose, Nat.descFactorial_eq_factorial_mul_choose]
  norm_num [Nat.factorial]
  ring

/-- The polynomial form of the sixth count, over the reals:
`N(N-1)(5N² - 15N + 11)`.  Its leading coefficient is the third Catalan number `5`. -/
theorem evenClosedWalkCount_six_real (N : ℕ) :
    (evenClosedWalkCount N 6 : ℝ)
      = (N : ℝ) * ((N : ℝ) - 1) * (5 * (N : ℝ) ^ 2 - 15 * (N : ℝ) + 11) := by
  rw [evenClosedWalkCount_six_descFactorial]
  match N with
  | 0 => norm_num [Nat.descFactorial]
  | 1 => norm_num [Nat.descFactorial]
  | 2 => norm_num [Nat.descFactorial]
  | (n + 3) =>
      have d2 : (n + 3).descFactorial 2 = (n + 2) * (n + 3) := by
        simp [Nat.descFactorial]
      have d3 : (n + 3).descFactorial 3 = (n + 1) * ((n + 2) * (n + 3)) := by
        simp [Nat.descFactorial]
      have d4 : (n + 3).descFactorial 4 = n * ((n + 1) * ((n + 2) * (n + 3))) := by
        simp [Nat.descFactorial]
      rw [d2, d3, d4]
      push_cast
      ring

end EvenWalks

namespace RademacherWigner

open EvenWalks

/-- **The exact sixth trace moment of the symmetric Rademacher ensemble**, at every
finite dimension `N`:  `E [tr W^6] = N(N-1)(5N² - 15N + 11)`.  Its leading coefficient
is the third Catalan number `5`, as the semicircle law predicts, and this is an order
beyond the second and fourth moments computed in
`Probability.WignerRademacherEnsemble`. -/
theorem expect_trace_W_six (N : ℕ) :
    expect (fun g : Config N => ((W g) ^ 6).trace)
      = (N : ℝ) * ((N : ℝ) - 1) * (5 * (N : ℝ) ^ 2 - 15 * (N : ℝ) + 11) := by
  have h := expect_trace_pow_eq_evenClosedWalkCount (N := N) 5
  norm_num at h
  rw [h, evenClosedWalkCount_six_real]

end RademacherWigner