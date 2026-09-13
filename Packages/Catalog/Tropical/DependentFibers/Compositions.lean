import Tropical.DependentFibers.FundamentalTheorem

/-!
# The composition spectrum of tropical multiplicity profiles

`Profiles.two_block_profile` realises every *two-part* splitting of the degree as the
multiplicity profile of an explicit degree-`n` tropical polynomial, and
`FundamentalTheorem.multiplicity_sum_convex_eq` shows that the profile of a convex
polynomial is always a composition of `n`.  This file closes the gap in the opposite
direction for an arbitrary number of parts:

**every composition of `n` is realised.**

Given block sizes `m 0, …, m (r−1)` with total `n = ∑_{t<r} m t`, the *staircase
increment function*

`blockIncr m r l = #{ j < r | blockSum m (j+1) ≤ l }`

assigns to a position `l` the index of the block containing it.  It is monotone
(`blockIncr_monotone`), so the convex machinery applies, and the positions of slope `j`
are exactly the `j`-th block (`blockIncr_slope_count`).  Hence the polynomial
`sumCoeff (blockIncr m r)` of degree `n` has, at the point `−j`, a fibre of cardinality
`m j + 1` (`composition_profile`): its multiplicity profile is exactly the prescribed
composition, and those excesses saturate the degree bound
(`composition_multiplicity_sum`).

Specialising to blocks of size `1` recovers the generic staircase, and specialising to
`r = 1` recovers the maximally degenerate corner; the two-block theorem of `Profiles` is
the case `r = 2`.  Combined with `multiplicity_sum_convex_eq` this yields
`composition_spectrum`: a list of positive integers is a convex multiplicity profile of
degree `n` **iff** it is a composition of `n`.
-/

namespace TropicalDependentFibers

open Finset

/-- Partial sums of the block sizes: `blockSum m j = m 0 + ⋯ + m (j−1)`. -/
def blockSum (m : ℕ → ℕ) (j : ℕ) : ℕ := ∑ t ∈ range j, m t

theorem blockSum_zero (m : ℕ → ℕ) : blockSum m 0 = 0 := by simp [blockSum]

theorem blockSum_succ (m : ℕ → ℕ) (j : ℕ) : blockSum m (j + 1) = blockSum m j + m j := by
  simp [blockSum, Finset.sum_range_succ]

theorem blockSum_monotone (m : ℕ → ℕ) : Monotone (blockSum m) := by
  intro a b hab
  refine Finset.sum_le_sum_of_subset fun x hx => ?_
  exact Finset.mem_range.mpr (lt_of_lt_of_le (Finset.mem_range.mp hx) hab)

/-- The **staircase increment function** of a composition: `blockIncr m r l` is the index
of the block of `m` containing the position `l`. -/
def blockIncr (m : ℕ → ℕ) (r : ℕ) (l : ℕ) : ℚ :=
  ((((range r).filter fun j => blockSum m (j + 1) ≤ l).card : ℕ) : ℚ)

/-- The natural-number value of the staircase: the number of blocks finished by `l`. -/
def blockIdx (m : ℕ → ℕ) (r : ℕ) (l : ℕ) : ℕ :=
  ((range r).filter fun j => blockSum m (j + 1) ≤ l).card

theorem blockIncr_eq_cast (m : ℕ → ℕ) (r l : ℕ) :
    blockIncr m r l = (blockIdx m r l : ℚ) := rfl

/-- The staircase is nondecreasing, so the associated polynomial is convex. -/
theorem blockIncr_monotone (m : ℕ → ℕ) (r : ℕ) : Monotone (blockIncr m r) := by
  intro a b hab
  have hsub : ((range r).filter fun j => blockSum m (j + 1) ≤ a)
      ⊆ (range r).filter fun j => blockSum m (j + 1) ≤ b := by
    intro j hj
    rw [mem_filter] at hj ⊢
    exact ⟨hj.1, le_trans hj.2 hab⟩
  have := Finset.card_le_card hsub
  simpa [blockIncr] using (Nat.cast_le (α := ℚ)).mpr this

/-- **Initial-segment law for the staircase.**  A block is finished by position `l`
exactly when its index is below the staircase value. -/
theorem blockSum_le_iff_lt_blockIdx {m : ℕ → ℕ} {r j l : ℕ} (hj : j < r) :
    blockSum m (j + 1) ≤ l ↔ j < blockIdx m r l := by
  constructor
  · intro hle
    have hsub : range (j + 1) ⊆ (range r).filter fun t => blockSum m (t + 1) ≤ l := by
      intro t ht
      rw [mem_range] at ht
      rw [mem_filter, mem_range]
      exact ⟨by omega, le_trans (blockSum_monotone m (by omega : t + 1 ≤ j + 1)) hle⟩
    have := Finset.card_le_card hsub
    rw [Finset.card_range] at this
    simpa [blockIdx] using this
  · intro hlt
    by_contra hgt
    push_neg at hgt
    have hsub : ((range r).filter fun t => blockSum m (t + 1) ≤ l) ⊆ range j := by
      intro t ht
      rw [mem_filter, mem_range] at ht
      rw [mem_range]
      by_contra hjt
      push_neg at hjt
      exact absurd (le_trans (blockSum_monotone m (by omega : j + 1 ≤ t + 1)) ht.2)
        (not_le.mpr hgt)
    have := Finset.card_le_card hsub
    rw [Finset.card_range] at this
    simp only [blockIdx] at hlt
    omega

/-- **The staircase value locates the block.**  For `j < r`, the positions of staircase
value `j` are exactly the positions of the `j`-th block. -/
theorem blockIdx_eq_iff {m : ℕ → ℕ} {r j l : ℕ} (hj : j < r) :
    blockIdx m r l = j ↔ blockSum m j ≤ l ∧ l < blockSum m (j + 1) := by
  constructor
  · intro hk
    refine ⟨?_, ?_⟩
    · rcases Nat.eq_zero_or_pos j with hj0 | hj0
      · simp [hj0, blockSum_zero]
      · have hprev : j - 1 < blockIdx m r l := by omega
        have := (blockSum_le_iff_lt_blockIdx (m := m) (r := r) (l := l)
          (j := j - 1) (by omega)).mpr hprev
        have hj1 : j - 1 + 1 = j := by omega
        rwa [hj1] at this
    · by_contra hge
      push_neg at hge
      have := (blockSum_le_iff_lt_blockIdx (m := m) (r := r) (l := l) (j := j) hj).mp hge
      omega
  · rintro ⟨hlo, hhi⟩
    have hupper : ¬ j < blockIdx m r l := by
      intro hlt
      exact absurd ((blockSum_le_iff_lt_blockIdx (m := m) (r := r) (l := l) (j := j) hj).mpr hlt)
        (not_le.mpr hhi)
    have hlower : ¬ blockIdx m r l < j := by
      intro hlt
      rcases Nat.eq_zero_or_pos j with hj0 | hj0
      · omega
      · have := (blockSum_le_iff_lt_blockIdx (m := m) (r := r) (l := l)
          (j := j - 1) (by omega)).mp (by
            have hj1 : j - 1 + 1 = j := by omega
            rw [hj1]; exact hlo)
        omega
    omega

/-- The set of positions of slope `j` is the `j`-th block, an interval of length `m j`. -/
theorem blockIncr_slope_count {m : ℕ → ℕ} {r j : ℕ} (hj : j < r) :
    ((range (blockSum m r)).filter fun l => blockIncr m r l = (j : ℚ)).card = m j := by
  classical
  have hset : ((range (blockSum m r)).filter fun l => blockIncr m r l = (j : ℚ))
      = Finset.Ico (blockSum m j) (blockSum m (j + 1)) := by
    ext l
    simp only [mem_filter, mem_range, Finset.mem_Ico, blockIncr_eq_cast]
    constructor
    · rintro ⟨_, heq⟩
      have hk : blockIdx m r l = j := by exact_mod_cast heq
      exact (blockIdx_eq_iff (m := m) (r := r) (l := l) hj).mp hk
    · rintro ⟨hlo, hhi⟩
      have hle : blockSum m (j + 1) ≤ blockSum m r := blockSum_monotone m (by omega)
      refine ⟨by omega, ?_⟩
      have hk : blockIdx m r l = j :=
        (blockIdx_eq_iff (m := m) (r := r) (l := l) hj).mpr ⟨hlo, hhi⟩
      exact_mod_cast congrArg (fun t : ℕ => (t : ℚ)) hk
  rw [hset, Nat.card_Ico, blockSum_succ]
  omega

/-- **Every composition of `n` is a tropical multiplicity profile.**  For block sizes
`m 0, …, m (r−1)` summing to `n`, the degree-`n` polynomial with staircase increments has
fibre of cardinality `m j + 1` at the point `−j`, for every `j < r`. -/
theorem composition_profile {m : ℕ → ℕ} {r j : ℕ} (hj : j < r) :
    (fiber (blockSum m r) (sumCoeff (blockIncr m r)) (-(j : ℚ))).card = m j + 1 := by
  rw [fiber_card_convex (blockIncr_monotone m r) (blockSum m r) (j : ℚ),
    blockIncr_slope_count hj]

/-- **The prescribed excesses saturate the degree bound.**  Summing the multiplicity
excesses over the `r` corners of the staircase polynomial returns the degree. -/
theorem composition_multiplicity_sum (m : ℕ → ℕ) (r : ℕ) :
    ∑ j ∈ range r, ((fiber (blockSum m r) (sumCoeff (blockIncr m r)) (-(j : ℚ))).card - 1)
      = blockSum m r := by
  have hterm : ∀ j ∈ range r,
      ((fiber (blockSum m r) (sumCoeff (blockIncr m r)) (-(j : ℚ))).card - 1) = m j := by
    intro j hj
    rw [composition_profile (mem_range.mp hj)]
    omega
  rw [Finset.sum_congr rfl hterm]
  rfl

/-- **Composition spectrum theorem.**  A list of block sizes is realisable as the
multiplicity profile of a degree-`n` convex tropical polynomial **iff** it is a
composition of `n`: the staircase polynomial realises the prescribed fibre cardinalities
`m j + 1` at the `r` distinct corners `−j`, their excesses sum to `n`, and conversely any
convex polynomial of degree `n` has multiplicity excesses summing to `n`. -/
theorem composition_spectrum (m : ℕ → ℕ) (r n : ℕ) (hn : blockSum m r = n) :
    (∀ j < r, (fiber n (sumCoeff (blockIncr m r)) (-(j : ℚ))).card = m j + 1) ∧
      ∑ j ∈ range r, ((fiber n (sumCoeff (blockIncr m r)) (-(j : ℚ))).card - 1) = n ∧
        ∀ d : ℕ → ℚ, Monotone d →
          ∑ v ∈ (range n).image d, ((fiber n (sumCoeff d) (-v)).card - 1) = n := by
  subst hn
  refine ⟨fun j hj => composition_profile hj, composition_multiplicity_sum m r, ?_⟩
  intro d hd
  exact multiplicity_sum_convex_eq hd _

/-- Sanity specialisation: all blocks of size `1` give the generic polynomial with `r`
simple corners, each of multiplicity `2`. -/
theorem composition_profile_all_ones (r j : ℕ) (hj : j < r) :
    (fiber (blockSum (fun _ => 1) r) (sumCoeff (blockIncr (fun _ => 1) r))
      (-(j : ℚ))).card = 2 := by
  simpa using composition_profile (m := fun _ => 1) (r := r) (j := j) hj

/-- Sanity specialisation: a single block of size `n` gives one corner of the maximal
multiplicity `n + 1`. -/
theorem composition_profile_single_block (n : ℕ) :
    (fiber (blockSum (fun _ => n) 1) (sumCoeff (blockIncr (fun _ => n) 1)) 0).card = n + 1 := by
  have h := composition_profile (m := fun _ => n) (r := 1) (j := 0) (by omega)
  simpa using h

end TropicalDependentFibers