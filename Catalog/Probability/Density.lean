import Probability.ThreeCubes.LocalSolvability

/-!
# Density of locally solvable and of representable integers

Combining the main local-solvability theorem with an exact count over each block of nine
consecutive integers we obtain:

* `ThreeCubes.card_locallySolvable_block` — exactly `7N` of the integers `0, …, 9N-1` are
  everywhere locally solvable, i.e. the locally solvable integers have density exactly `7/9`;
* `ThreeCubes.card_isSumOfThreeCubes_le` — consequently at most `7N` of them are actual sums
  of three cubes.  The conjecture of Heath-Brown asserts that this upper bound is attained
  (asymptotically), i.e. that the density of representable integers is exactly `7/9`; the
  formal statement `ThreeCubes.DensitySevenNinths` records that conjecture, and
  `ThreeCubes.densitySevenNinths_iff_hasse` shows it is *equivalent* to the Hasse principle
  for the affine cubic surface.
-/

namespace ThreeCubes

open Finset

/-- In each block of nine consecutive residues exactly seven avoid `±4 mod 9`. -/
theorem card_admissible_block (N : ℕ) :
    ((Finset.range (9 * N)).filter (fun i => i % 9 ≠ 4 ∧ i % 9 ≠ 5)).card = 7 * N := by
  induction N with
  | zero => simp
  | succ M ih =>
      have h : 9 * (M + 1) = (9 * M) + 9 := by ring
      have hdisj : Disjoint (Finset.range (9 * M))
          (Finset.map (addLeftEmbedding (9 * M)) (Finset.range 9)) := by
        rw [Finset.disjoint_left]
        intro a ha hb
        simp only [Finset.mem_range] at ha
        simp only [Finset.mem_map, Finset.mem_range, addLeftEmbedding_apply] at hb
        obtain ⟨c, hc, rfl⟩ := hb
        omega
      rw [h, Finset.range_add, Finset.filter_union,
        Finset.card_union_of_disjoint (Finset.disjoint_filter_filter hdisj), ih,
        Finset.filter_map, Finset.card_map]
      have hc : Finset.filter ((fun i => i % 9 ≠ 4 ∧ i % 9 ≠ 5) ∘ ⇑(addLeftEmbedding (9 * M)))
          (Finset.range 9) = Finset.filter (fun i => i % 9 ≠ 4 ∧ i % 9 ≠ 5) (Finset.range 9) := by
        ext x
        simp only [Finset.mem_filter, Finset.mem_range, Function.comp_apply,
          addLeftEmbedding_apply]
        omega
      rw [hc]
      have h7 : (Finset.filter (fun i => i % 9 ≠ 4 ∧ i % 9 ≠ 5) (Finset.range 9)).card = 7 := by
        decide
      omega

open scoped Classical in
/-- **The locally solvable integers have density exactly `7/9`.** -/
theorem card_locallySolvable_block (N : ℕ) :
    (Finset.filter (fun i : ℕ => LocallySolvable (i : ℤ)) (Finset.range (9 * N))).card = 7 * N := by
  rw [show Finset.filter (fun i : ℕ => LocallySolvable (i : ℤ)) (Finset.range (9 * N))
      = (Finset.range (9 * N)).filter (fun i => i % 9 ≠ 4 ∧ i % 9 ≠ 5) from ?_]
  · exact card_admissible_block N
  · ext x
    simp only [Finset.mem_filter, Finset.mem_range, locallySolvable_iff]
    omega

open scoped Classical in
/-- Hence at most `7/9` of all integers are sums of three cubes. -/
theorem card_isSumOfThreeCubes_le (N : ℕ) :
    (Finset.filter (fun i : ℕ => IsSumOfThreeCubes (i : ℤ)) (Finset.range (9 * N))).card ≤ 7 * N := by
  rw [← card_locallySolvable_block N]
  apply Finset.card_le_card
  intro x hx
  simp only [Finset.mem_filter] at hx ⊢
  exact ⟨hx.1, locallySolvable_of_isSumOfThreeCubes hx.2⟩

open scoped Classical in
/-- The (conjectural) statement that the density of sums of three cubes is exactly `7/9`. -/
def DensitySevenNinths : Prop :=
  ∀ N : ℕ, (Finset.filter (fun i : ℕ => IsSumOfThreeCubes (i : ℤ)) (Finset.range (9 * N))).card = 7 * N

open scoped Classical in
/-- **The density statement is exactly the Hasse principle for nonnegative `n`.**  So the
`7/9` density conjecture is not a statistical strengthening: it is equivalent to the
representability of every locally solvable nonnegative integer. -/
theorem densitySevenNinths_iff_hasse :
    DensitySevenNinths ↔ ∀ n : ℕ, (n : ℤ) % 9 ≠ 4 → (n : ℤ) % 9 ≠ 5 →
      IsSumOfThreeCubes (n : ℤ) := by
  constructor
  · intro hD n h4 h5
    -- consider the block containing `n`
    have hlt : n < 9 * (n + 1) := by omega
    have hcard := hD (n + 1)
    have hsub : Finset.filter (fun i : ℕ => IsSumOfThreeCubes (i : ℤ)) (Finset.range (9 * (n + 1))) ⊆
        Finset.filter (fun i : ℕ => LocallySolvable (i : ℤ)) (Finset.range (9 * (n + 1))) := by
      intro x hx
      simp only [Finset.mem_filter] at hx ⊢
      exact ⟨hx.1, locallySolvable_of_isSumOfThreeCubes hx.2⟩
    have heq : Finset.filter (fun i : ℕ => IsSumOfThreeCubes (i : ℤ)) (Finset.range (9 * (n + 1))) =
        Finset.filter (fun i : ℕ => LocallySolvable (i : ℤ)) (Finset.range (9 * (n + 1))) := by
      apply Finset.eq_of_subset_of_card_le hsub
      rw [card_locallySolvable_block (n + 1), hcard]
    have hmem : n ∈ Finset.filter (fun i : ℕ => LocallySolvable (i : ℤ)) (Finset.range (9 * (n + 1))) := by
      simp only [Finset.mem_filter, Finset.mem_range]
      exact ⟨hlt, locallySolvable_of_not_mod_nine h4 h5⟩
    rw [← heq] at hmem
    simp only [Finset.mem_filter] at hmem
    exact hmem.2
  · intro hH N
    rw [← card_locallySolvable_block N]
    congr 1
    ext x
    simp only [Finset.mem_filter, Finset.mem_range]
    constructor
    · rintro ⟨h1, h2⟩
      exact ⟨h1, locallySolvable_of_isSumOfThreeCubes h2⟩
    · rintro ⟨h1, h2⟩
      obtain ⟨h4, h5⟩ := (locallySolvable_iff _).mp h2
      exact ⟨h1, hH x h4 h5⟩

end ThreeCubes