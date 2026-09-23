import Tropical.DependentFibers.Profiles

/-!
# The tropical fundamental theorem in equality form for convex coefficient data

`Core.multiplicity_sum_le` gives the inequality `∑_x (|fibre x| − 1) ≤ n` for arbitrary
coefficients, and `LabNotes` exhibits a non-convex polynomial where the inequality is
strict.  Here we prove that for a **convex** polynomial — one given by a nondecreasing
sequence of Newton-polygon increments `d` — the inequality is an *equality*, the sum
being taken over the (finitely many) distinct slopes:

`∑_{v ∈ image of d on [0,n)} (|fibre(−v)| − 1) = n`   (`multiplicity_sum_convex_eq`).

The route is a counting identity.  For monotone `d` the sets `{l < n | d l < v}` and
`{l < n | d l ≤ v}` are initial segments (`lt_iff_lt_cntLt`, `le_iff_lt_cntLe`), so the
hypotheses of the profile theorem `fiber_sumCoeff_eq_Icc` hold with
`A = #{l < n | d l < v}` and `B = #{l < n | d l ≤ v}`.  Hence

`|fibre(−v)| = #{l < n | d l = v} + 1`   (`fiber_card_convex`),

**the multiplicity of a corner is one more than the number of Newton increments of that
slope**, and summing the fibrewise partition of `[0, n)` by slope value gives exactly
`n`.  This also shows every corner is accounted for: the multiplicity profile of a
convex tropical polynomial is precisely the composition of `n` recorded by the
multiplicities of its slopes.
-/

namespace TropicalDependentFibers

open Finset

variable {n : ℕ} {d : ℕ → ℚ} {v : ℚ}

/-- Number of Newton increments of slope strictly below `v`. -/
def cntLt (n : ℕ) (d : ℕ → ℚ) (v : ℚ) : ℕ := ((range n).filter fun l => d l < v).card

/-- Number of Newton increments of slope at most `v`. -/
def cntLe (n : ℕ) (d : ℕ → ℚ) (v : ℚ) : ℕ := ((range n).filter fun l => d l ≤ v).card

theorem cntLt_le_cntLe (n : ℕ) (d : ℕ → ℚ) (v : ℚ) : cntLt n d v ≤ cntLe n d v := by
  refine Finset.card_le_card fun l hl => ?_
  rw [mem_filter] at hl ⊢
  exact ⟨hl.1, le_of_lt hl.2⟩

theorem cntLe_le (n : ℕ) (d : ℕ → ℚ) (v : ℚ) : cntLe n d v ≤ n := by
  simpa using Finset.card_le_card (Finset.filter_subset (fun l => d l ≤ v) (range n))

/-- For monotone increments, `{l < n | d l < v}` is the initial segment of length
`cntLt n d v`. -/
theorem lt_iff_lt_cntLt (hd : Monotone d) {l : ℕ} (hl : l < n) :
    d l < v ↔ l < cntLt n d v := by
  constructor
  · intro hlt
    have hsub : range (l + 1) ⊆ (range n).filter fun j => d j < v := by
      intro j hj
      rw [mem_range] at hj
      rw [mem_filter, mem_range]
      exact ⟨by omega, lt_of_le_of_lt (hd (by omega)) hlt⟩
    have := Finset.card_le_card hsub
    rw [Finset.card_range] at this
    simpa [cntLt] using this
  · intro hcount
    by_contra hge
    push_neg at hge
    have hsub : ((range n).filter fun j => d j < v) ⊆ range l := by
      intro j hj
      rw [mem_filter, mem_range] at hj
      rw [mem_range]
      by_contra hjl
      push_neg at hjl
      exact absurd (le_trans hge (hd hjl)) (not_le.mpr hj.2)
    have := Finset.card_le_card hsub
    rw [Finset.card_range] at this
    simp only [cntLt] at hcount
    omega

/-- For monotone increments, `{l < n | d l ≤ v}` is the initial segment of length
`cntLe n d v`. -/
theorem le_iff_lt_cntLe (hd : Monotone d) {l : ℕ} (hl : l < n) :
    d l ≤ v ↔ l < cntLe n d v := by
  constructor
  · intro hlt
    have hsub : range (l + 1) ⊆ (range n).filter fun j => d j ≤ v := by
      intro j hj
      rw [mem_range] at hj
      rw [mem_filter, mem_range]
      exact ⟨by omega, le_trans (hd (by omega)) hlt⟩
    have := Finset.card_le_card hsub
    rw [Finset.card_range] at this
    simpa [cntLe] using this
  · intro hcount
    by_contra hgt
    push_neg at hgt
    have hsub : ((range n).filter fun j => d j ≤ v) ⊆ range l := by
      intro j hj
      rw [mem_filter, mem_range] at hj
      rw [mem_range]
      by_contra hjl
      push_neg at hjl
      exact absurd (le_trans (hd hjl) hj.2) (not_le.mpr hgt)
    have := Finset.card_le_card hsub
    rw [Finset.card_range] at this
    simp only [cntLe] at hcount
    omega

/-- The slope-`v` increments are exactly the gap between the two initial segments. -/
theorem card_eq_slope (n : ℕ) (d : ℕ → ℚ) (v : ℚ) :
    ((range n).filter fun l => d l = v).card = cntLe n d v - cntLt n d v := by
  classical
  have hsub : ((range n).filter fun l => d l < v) ⊆ (range n).filter fun l => d l ≤ v := by
    intro l hl
    rw [mem_filter] at hl ⊢
    exact ⟨hl.1, le_of_lt hl.2⟩
  have hdiff : ((range n).filter fun l => d l ≤ v) \ ((range n).filter fun l => d l < v)
      = (range n).filter fun l => d l = v := by
    ext l
    simp only [Finset.mem_sdiff, mem_filter, mem_range, not_and, not_lt]
    constructor
    · rintro ⟨⟨hln, hle⟩, hnot⟩
      exact ⟨hln, le_antisymm hle (hnot hln)⟩
    · rintro ⟨hln, heq⟩
      exact ⟨⟨hln, le_of_eq heq⟩, fun _ => le_of_eq heq.symm⟩
  rw [← hdiff, Finset.card_sdiff_of_subset hsub]
  rfl

/-- **Multiplicity = number of increments of that slope, plus one.**  The exact local
multiplicity of a convex tropical polynomial at the corner `−v`. -/
theorem fiber_card_convex (hd : Monotone d) (n : ℕ) (v : ℚ) :
    (fiber n (sumCoeff d) (-v)).card = ((range n).filter fun l => d l = v).card + 1 := by
  have hAB := cntLt_le_cntLe n d v
  have hBn := cntLe_le n d v
  have hcard := fiber_sumCoeff_card (n := n) (A := cntLt n d v) (B := cntLe n d v)
    (d := d) (v := v) hAB hBn
    (fun l hl => (lt_iff_lt_cntLt hd (by omega : l < n)).mpr hl)
    (fun l hAl hlB => by
      have hln : l < n := by omega
      have h1 : d l ≤ v := (le_iff_lt_cntLe hd hln).mpr hlB
      have h2 : ¬ d l < v := fun hlt => absurd ((lt_iff_lt_cntLt hd hln).mp hlt) (by omega)
      exact le_antisymm h1 (not_lt.mp h2))
    (fun l hBl hln => by
      have h : ¬ d l ≤ v := fun hle => absurd ((le_iff_lt_cntLe hd hln).mp hle) (by omega)
      exact not_le.mp h)
  rw [hcard, card_eq_slope]

/-- **Tropical fundamental theorem, equality form.**  For a convex tropical polynomial
the multiplicity excesses of its corners sum to the degree exactly: the profile of a
convex polynomial is a full composition of `n`. -/
theorem multiplicity_sum_convex_eq (hd : Monotone d) (n : ℕ) :
    ∑ v ∈ (range n).image d, ((fiber n (sumCoeff d) (-v)).card - 1) = n := by
  classical
  have hterm : ∀ v ∈ (range n).image d,
      ((fiber n (sumCoeff d) (-v)).card - 1) = ((range n).filter fun l => d l = v).card := by
    intro v _
    rw [fiber_card_convex hd n v]
    omega
  rw [Finset.sum_congr rfl hterm]
  exact (Finset.card_eq_sum_card_image d (range n)).symm.trans (Finset.card_range n)

/-- Consistency check: the equality form refines the inequality `multiplicity_sum_le`,
which therefore is attained by every convex coefficient vector. -/
theorem convex_saturates_degree_bound (hd : Monotone d) (n : ℕ) :
    ∑ v ∈ (range n).image d, ((fiber n (sumCoeff d) (-v)).card - 1) = n ∧
      ∀ S : Finset ℚ, ∑ x ∈ S, ((fiber n (sumCoeff d) x).card - 1) ≤ n :=
  ⟨multiplicity_sum_convex_eq hd n, fun S => multiplicity_sum_le n (sumCoeff d) S⟩

end TropicalDependentFibers