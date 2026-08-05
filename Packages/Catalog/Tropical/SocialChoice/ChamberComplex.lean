/-
# The cell complex of decisive coalitions, and the single-voter exchange law

This file completes the geometric half of the tropical/social-choice bridge
started in `Tropical/SocialChoice/Chambers.lean`.

For a min-plus aggregator `F x = min_{i ∈ S} (x i + δ i)` the *decisive
coalition at a profile* `x` is the set

`decisiveSet S δ x = {i ∈ S | x i + δ i = F x}`

of voters attaining the social score.  The cells of the induced complex are the
level sets of this labelling map, and the closed cells are exactly the finite
intersections of the chambers of `Chambers.lean`, hence convex polyhedra.

Main results.

* `decisiveSet_nonempty`, `mem_decisiveSet_iff_mem_chamber`: the labelling is
  well defined and matches the chamber description.
* `closedCell_eq_iInter`, `closedCell_convex`: the closed cell of a label `T` is
  `⋂ i ∈ T, chamber S δ i`, a convex polyhedron.
* `decisiveSet_locally_decisive`: the label really is a *decisive coalition* —
  the social score is unchanged by any raising of the scores of the voters
  outside it.
* `exists_decisiveSet_eq`: every nonempty `T ⊆ S` occurs as a label, so the
  labels of the complex are exactly the nonempty subcoalitions of the support.
* `exchange_mem_wall`, `decisiveSet_update_eq_singleton`, `single_voter_exchange`:
  the **single-voter exchange law**.  From any profile in the chamber of `i` one
  reaches the wall between the chambers of `i` and `j`, and then the open cell
  labelled `{j}`, by changing the score of the single voter `j`.  Adjacency of
  top-dimensional cells is thus governed by one-voter exchanges.
-/
import Mathlib
import Tropical.SocialChoice.Chambers

namespace TropicalChamberComplex

open Finset TropicalChambers

variable {ι : Type*}

open scoped Classical in
/-- The decisive coalition at a profile: the voters of the support that attain
the social score. -/
noncomputable def decisiveSet (S : Finset ι) (hS : S.Nonempty) (δ : ι → ℝ) (x : ι → ℝ) :
    Finset ι :=
  S.filter fun i => x i + δ i = tropAgg S hS δ x

open scoped Classical in
lemma mem_decisiveSet_iff {S : Finset ι} {hS : S.Nonempty} {δ : ι → ℝ} {x : ι → ℝ} {i : ι} :
    i ∈ decisiveSet S hS δ x ↔ i ∈ S ∧ x i + δ i = tropAgg S hS δ x := by
  simp [decisiveSet]

lemma decisiveSet_subset (S : Finset ι) (hS : S.Nonempty) (δ : ι → ℝ) (x : ι → ℝ) :
    decisiveSet S hS δ x ⊆ S := fun _ hi => (mem_decisiveSet_iff.mp hi).1

/-- The label is always a nonempty coalition. -/
theorem decisiveSet_nonempty (S : Finset ι) (hS : S.Nonempty) (δ : ι → ℝ) (x : ι → ℝ) :
    (decisiveSet S hS δ x).Nonempty := by
  obtain ⟨i, hiS, hi⟩ := Finset.exists_mem_eq_inf' hS (fun k => x k + δ k)
  exact ⟨i, mem_decisiveSet_iff.mpr ⟨hiS, hi.symm⟩⟩

/-- A voter is decisive at `x` exactly when `x` lies in its chamber. -/
theorem mem_decisiveSet_iff_mem_chamber {S : Finset ι} {hS : S.Nonempty} {δ : ι → ℝ}
    {x : ι → ℝ} {i : ι} :
    i ∈ decisiveSet S hS δ x ↔ i ∈ S ∧ x ∈ chamber S δ i := by
  rw [mem_decisiveSet_iff]
  constructor
  · rintro ⟨hiS, hi⟩
    exact ⟨hiS, mem_chamber_of_eq_inf' hS δ hi.symm⟩
  · rintro ⟨hiS, hx⟩
    exact ⟨hiS, (tropAgg_eq_on_chamber hS δ hiS hx).symm⟩

/-- The closed cell of a label `T`: the profiles at which every member of `T` is
decisive. -/
def closedCell (S : Finset ι) (hS : S.Nonempty) (δ : ι → ℝ) (T : Finset ι) : Set (ι → ℝ) :=
  {x | T ⊆ decisiveSet S hS δ x}

/-- The closed cells are the finite intersections of chambers. -/
theorem closedCell_eq_iInter {S : Finset ι} (hS : S.Nonempty) (δ : ι → ℝ) {T : Finset ι}
    (hTS : T ⊆ S) : closedCell S hS δ T = ⋂ i ∈ T, chamber S δ i := by
  ext x
  simp only [closedCell, Set.mem_setOf_eq, Set.mem_iInter]
  constructor
  · intro h i hi
    exact (mem_decisiveSet_iff_mem_chamber.mp (h hi)).2
  · intro h i hi
    exact mem_decisiveSet_iff_mem_chamber.mpr ⟨hTS hi, h i hi⟩

/-- Closed cells are convex polyhedra. -/
theorem closedCell_convex {S : Finset ι} (hS : S.Nonempty) (δ : ι → ℝ) {T : Finset ι}
    (hTS : T ⊆ S) : Convex ℝ (closedCell S hS δ T) := by
  rw [closedCell_eq_iInter hS δ hTS]
  exact convex_iInter fun i => convex_iInter fun _ => chamber_convex S δ i

/-- On the closed cell of `T` all the tropical monomials indexed by `T` agree:
the cell lies in the common wall of its chambers. -/
theorem eq_on_closedCell {S : Finset ι} {hS : S.Nonempty} {δ : ι → ℝ} {T : Finset ι}
    {x : ι → ℝ} (hx : x ∈ closedCell S hS δ T) {i j : ι} (hi : i ∈ T) (hj : j ∈ T) :
    x i + δ i = x j + δ j := by
  have h1 := (mem_decisiveSet_iff.mp (hx hi)).2
  have h2 := (mem_decisiveSet_iff.mp (hx hj)).2
  rw [h1, h2]

/-- **The label is a decisive coalition.**  Raising the scores of the voters
outside the decisive coalition at `x` does not change the social score. -/
theorem decisiveSet_locally_decisive {S : Finset ι} (hS : S.Nonempty) (δ : ι → ℝ)
    {x y : ι → ℝ} (hagree : ∀ i ∈ decisiveSet S hS δ x, y i = x i)
    (hge : ∀ i, x i ≤ y i) :
    tropAgg S hS δ y = tropAgg S hS δ x := by
  refine le_antisymm ?_ ?_
  · obtain ⟨i, hi⟩ := decisiveSet_nonempty S hS δ x
    obtain ⟨hiS, hival⟩ := mem_decisiveSet_iff.mp hi
    calc tropAgg S hS δ y ≤ y i + δ i := Finset.inf'_le (fun k => y k + δ k) hiS
      _ = x i + δ i := by rw [hagree i hi]
      _ = tropAgg S hS δ x := hival
  · refine Finset.le_inf' hS _ ?_
    intro j hj
    have h1 : tropAgg S hS δ x ≤ x j + δ j := Finset.inf'_le (fun k => x k + δ k) hj
    have h2 := hge j
    linarith

/-! ## Every nonempty subcoalition of the support is a cell label -/

/-- **Completeness of the labelling.**  For every nonempty `T ⊆ S` there is a
profile whose decisive coalition is exactly `T`.  Hence the cells of the complex
are labelled precisely by the nonempty subcoalitions of the tropical support. -/
theorem exists_decisiveSet_eq {S : Finset ι} (hS : S.Nonempty) (δ : ι → ℝ) {T : Finset ι}
    (hTS : T ⊆ S) (hT : T.Nonempty) :
    ∃ x : ι → ℝ, decisiveSet S hS δ x = T := by
  classical
  refine ⟨fun k => (if k ∈ T then (0:ℝ) else 1) - δ k, ?_⟩
  set x : ι → ℝ := fun k => (if k ∈ T then (0:ℝ) else 1) - δ k with hx
  have hval : ∀ k, x k + δ k = if k ∈ T then (0:ℝ) else 1 := by
    intro k; simp [hx]
  obtain ⟨t, htT⟩ := hT
  have hagg : tropAgg S hS δ x = 0 := by
    refine le_antisymm ?_ ?_
    · have := Finset.inf'_le (fun k => x k + δ k) (hTS htT)
      simpa [tropAgg, hval, htT] using this
    · refine Finset.le_inf' hS _ ?_
      intro j _
      rw [hval j]
      split_ifs <;> norm_num
  ext k
  rw [mem_decisiveSet_iff, hagg, hval k]
  constructor
  · rintro ⟨-, hk⟩
    by_contra hkT
    rw [if_neg hkT] at hk
    norm_num at hk
  · intro hk
    exact ⟨hTS hk, by rw [if_pos hk]⟩

/-! ## The single-voter exchange law -/

/-- Changing the score of a single voter `j` to a value strictly below every
other tropical monomial makes `j` the unique decisive voter. -/
theorem decisiveSet_update_eq_singleton [DecidableEq ι] {S : Finset ι} (hS : S.Nonempty) (δ : ι → ℝ)
    {x : ι → ℝ} {j : ι} (hjS : j ∈ S) {c : ℝ}
    (hc : ∀ k ∈ S, k ≠ j → c + δ j < x k + δ k) :
    decisiveSet S hS δ (Function.update x j c) = {j} := by
  classical
  set y : ι → ℝ := Function.update x j c with hy
  have hyj : y j = c := by simp [hy]
  have hyk : ∀ k, k ≠ j → y k = x k := by
    intro k hk; simp [hy, Function.update_of_ne hk]
  have hagg : tropAgg S hS δ y = c + δ j := by
    refine le_antisymm ?_ ?_
    · have := Finset.inf'_le (fun k => y k + δ k) hjS
      simpa [tropAgg, hyj] using this
    · refine Finset.le_inf' hS _ ?_
      intro k hk
      by_cases hkj : k = j
      · subst hkj; simp [hyj]
      · rw [hyk k hkj]
        exact (hc k hk hkj).le
  ext k
  rw [mem_decisiveSet_iff, hagg, Finset.mem_singleton]
  constructor
  · rintro ⟨hkS, hkv⟩
    by_contra hkj
    rw [hyk k hkj] at hkv
    exact absurd hkv (ne_of_gt (hc k hkS hkj))
  · rintro rfl
    exact ⟨hjS, by rw [hyj]⟩

/-- **Exchange onto a wall.**  If `x` lies in the chamber of `i`, then lowering
the single score of another voter `j` to `x i + δ i - δ j` produces a profile on
the wall between the chambers of `i` and `j`: both voters are decisive there. -/
theorem exchange_mem_wall [DecidableEq ι] {S : Finset ι} (hS : S.Nonempty) (δ : ι → ℝ) {i j : ι}
    (hiS : i ∈ S) (hjS : j ∈ S) (hij : i ≠ j) {x : ι → ℝ} (hx : x ∈ chamber S δ i) :
    ({i, j} : Finset ι) ⊆ decisiveSet S hS δ (Function.update x j (x i + δ i - δ j)) := by
  classical
  set c : ℝ := x i + δ i - δ j with hc
  set y : ι → ℝ := Function.update x j c with hy
  have hyj : y j = c := by simp [hy]
  have hyk : ∀ k, k ≠ j → y k = x k := by
    intro k hk; simp [hy, Function.update_of_ne hk]
  have hyi : y i = x i := hyk i hij
  have hagg : tropAgg S hS δ y = x i + δ i := by
    refine le_antisymm ?_ ?_
    · have := Finset.inf'_le (fun k => y k + δ k) hiS
      simp only [tropAgg] at this ⊢
      rw [hyi] at this
      exact this
    · refine Finset.le_inf' hS _ ?_
      intro k hk
      by_cases hkj : k = j
      · subst hkj; rw [hyj, hc]; linarith
      · rw [hyk k hkj]; exact hx k hk
  intro k hk
  rcases Finset.mem_insert.mp hk with rfl | hk
  · exact mem_decisiveSet_iff.mpr ⟨hiS, by rw [hagg, hyi]⟩
  · have hkj : k = j := Finset.mem_singleton.mp hk
    subst hkj
    exact mem_decisiveSet_iff.mpr ⟨hjS, by rw [hagg, hyj, hc]; ring⟩

/-- **Single-voter exchange law.**  Let `x` be a profile in the chamber of voter
`i`.  For any voter `j` of the support and any `ε > 0`, changing *only* the
score of `j` to `x i + δ i - δ j - ε` moves the profile into the open cell
labelled `{j}`.  Thus the top-dimensional cells `{i}` and `{j}` of the complex
are joined by a single-voter exchange, across the wall produced by
`exchange_mem_wall`. -/
theorem single_voter_exchange [DecidableEq ι] {S : Finset ι} (hS : S.Nonempty) (δ : ι → ℝ) {i j : ι}
    (hjS : j ∈ S) {x : ι → ℝ} (hx : x ∈ chamber S δ i)
    {ε : ℝ} (hε : 0 < ε) :
    decisiveSet S hS δ (Function.update x j (x i + δ i - δ j - ε)) = {j} := by
  refine decisiveSet_update_eq_singleton hS δ hjS ?_
  intro k hk hkj
  have := hx k hk
  linarith

end TropicalChamberComplex