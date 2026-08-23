import Mathlib
import Combinatorics.KneeInvariance
import Probability.NET64GridArtifact
import Probability.NET64GridDesign
import Probability.NET64SharpSweepCost

/-!
# NET-64, cycle 4: the optimal sweep grid is *unique*

`Probability/NET64SharpSweepCost.lean` (cycle 3) computed the exact capacity of a
budget sweep: an `s`-point grid that localises every budget of `[1, N]` to a
factor `r` satisfies `N ≤ geoSum r s = r + r² + ⋯ + r^s`, and the bound is
attained by the *offset* geometric grid `geoGrid r s = {r, r+r², …}`.  That left
direction **D2′** of `FUTURE_DIRECTIONS.md` open: *is the extremal grid unique?*

This file answers **yes**, and draws the consequences.

* `sweep_rigidity` — if `|G| = s` and `G` localises `[1, geoSum r s]` to a factor
  `r ≥ 1`, then `G = geoGrid r s`.  The proof is the equality analysis of cycle
  3's peeling induction: at capacity every inequality in the peeling step must be
  an equality, which forces the largest point to be `geoSum r s` and leaves an
  `(s-1)`-point problem *again at capacity*, so tightness propagates all the way
  down.
* `sweep_capacity_unique_maximiser` — the extremal grid is therefore the unique
  maximiser: the capacity `IsGreatest` statement of cycle 3 upgrades to a
  uniqueness statement.
* `optimal_grid_top_point`, `optimal_grid_avoids_one` — structural corollaries:
  an optimal sweep must sample the *top* of its range exactly, and (for `r ≥ 2`)
  must never sample the budget `1`.  The classical geometric grid `{1, r, r², …}`
  is thus excluded on purely structural grounds.
* `rigidity_is_sharp_at_capacity` — rigidity holds *only* at the capacity: one
  budget below it there are already two distinct optimal grids (`{2,6}` and
  `{2,5}` both localise `[1,5]` at ratio `2`).
* `net64_four_point_grid_unique` — the NET-64 instance: `{2, 6, 14, 30}` is the
  *only* four-point grid that localises `[1,30]` to a factor `2`.
* `sweep_min_points` / `net64_min_points_for_64` — the dual question, how many
  points a *given* range costs: the minimum is the least `s` with
  `N ≤ geoSum r s`, and covering the measured NET-64 budget range `[1, 64]`
  to a factor `2` costs exactly `6` points — half again as many as the four the
  measured coarse sweep used.
-/

namespace Catalog.Probability.NET64SweepRigidity

open Finset Catalog.Probability.NET64SharpSweepCost

/-! ## 1. Two elementary facts about the capacity function and `Localises` -/

/-- Localisation of a range restricts to any sub-range. -/
theorem localises_mono {G : Finset ℕ} {r N M : ℕ} (h : Localises G r N) (hMN : M ≤ N) :
    Localises G r M := fun c hc1 hc2 => h c hc1 (le_trans hc2 hMN)

/-- The capacity is at least the number of points: `s ≤ geoSum r s` for `r ≥ 1`. -/
theorem le_geoSum {r : ℕ} (hr : 1 ≤ r) (s : ℕ) : s ≤ geoSum r s := by
  induction s with
  | zero => simp
  | succ n ih =>
      have hpow : 1 ≤ r ^ (n + 1) := Nat.one_le_pow _ _ (by omega)
      rw [geoSum_succ]
      omega

/-- The offset geometric grid, peeled at the top. -/
theorem geoGrid_succ (r s : ℕ) :
    geoGrid r (s + 1) = insert (geoSum r (s + 1)) (geoGrid r s) := by
  simp [geoGrid, Finset.range_add_one, Finset.image_insert]

/-! ## 2. The rigidity theorem -/

/-- **Rigidity of capacity-extremal sweeps (direction D2′).**  A grid of `s`
points that localises the *whole* of `[1, geoSum r s]` to a factor `r` is
necessarily the offset geometric grid `{r, r+r², …, r+⋯+r^s}`.

At capacity, cycle 3's peeling chain
`geoSum r s ≤ M ≤ r·⌊(M-1)/r⌋ + r ≤ r·geoSum r (s-1) + r = geoSum r s`
collapses to a chain of equalities: the largest sampled budget must be exactly
`geoSum r s`, and the remaining `s-1` points must localise exactly
`[1, geoSum r (s-1)]` — the same problem one size down, again at capacity. -/
theorem sweep_rigidity :
    ∀ (s : ℕ) (G : Finset ℕ) (r : ℕ), 1 ≤ r → G.card = s →
      Localises G r (geoSum r s) → G = geoGrid r s := by
  intro s
  induction s with
  | zero =>
      intro G r _ hcard _
      rw [Finset.card_eq_zero] at hcard
      simp [hcard, geoGrid]
  | succ n ih =>
      intro G r hr hcard hloc
      set N := geoSum r (n + 1) with hNdef
      have hpow : 1 ≤ r ^ (n + 1) := Nat.one_le_pow _ _ (by omega)
      have hNrec : N = r * geoSum r n + r := geoSum_succ' r n
      have hN1 : 1 ≤ N := by
        rw [hNdef, geoSum_succ]; omega
      have hGne : G.Nonempty := Finset.card_pos.mp (by omega)
      set M := G.max' hGne with hM
      have hMmem : M ∈ G := Finset.max'_mem G hGne
      obtain ⟨gp, hgp, hge, -⟩ := hloc N hN1 le_rfl
      have hNM : N ≤ M := le_trans hge (Finset.le_max' G gp hgp)
      have hM1 : 1 ≤ M := le_trans hN1 hNM
      set N' := (M - 1) / r with hN'
      have hcard' : (G.erase M).card = n := by
        rw [Finset.card_erase_of_mem hMmem, hcard]
        omega
      have hmodlt : (M - 1) % r < r := Nat.mod_lt _ (by omega)
      have hrN' : r * N' ≤ M - 1 := Nat.mul_div_le _ _
      have hsplit : r * N' + (M - 1) % r = M - 1 := by
        have := Nat.div_add_mod (M - 1) r
        omega
      have hloc' : Localises (G.erase M) r (min N N') := by
        intro c hc1 hc2
        obtain ⟨gp', hgp', h1, h2⟩ := hloc c hc1 (le_trans hc2 (min_le_left _ _))
        have hcN' : c ≤ N' := le_trans hc2 (min_le_right _ _)
        have hlt : gp' < M := by
          have h3 : r * c ≤ r * N' := Nat.mul_le_mul (le_refl r) hcN'
          omega
        exact ⟨gp', Finset.mem_erase.mpr ⟨Nat.ne_of_lt hlt, hgp'⟩, h1, h2⟩
      have hmin := sweep_capacity_upper n (G.erase M) r (min N N') hcard' hr hloc'
      -- `N ≤ N'` is impossible: it would fit `geoSum r (n+1)` budgets into `n` points.
      have hcase : ¬ N ≤ N' := by
        intro hle
        rw [min_eq_left hle] at hmin
        have : geoSum r n < N := by
          rw [hNdef, geoSum_succ]; omega
        omega
      have hminEq : min N N' = N' := min_eq_right (Nat.le_of_lt (Nat.lt_of_not_le hcase))
      rw [hminEq] at hmin hloc'
      -- the peeling chain, now at capacity, collapses
      have hMle : M ≤ r * N' + r := by omega
      have hchain : r * N' + r ≤ r * geoSum r n + r :=
        Nat.add_le_add_right (Nat.mul_le_mul (le_refl r) hmin) r
      have hMeq : M = N := by omega
      have hN'eq : N' = geoSum r n := by
        have : r * N' = r * geoSum r n := by omega
        exact Nat.eq_of_mul_eq_mul_left (by omega) this
      -- the erased grid solves the same problem one size down, again at capacity
      have hlocsub : Localises (G.erase M) r (geoSum r n) := by
        rw [← hN'eq]
        exact hloc'
      have hsub := ih (G.erase M) r hr hcard' hlocsub
      have hMeq' : M = geoSum r (n + 1) := by rw [hMeq, hNdef]
      calc G = insert M (G.erase M) := (Finset.insert_erase hMmem).symm
        _ = insert (geoSum r (n + 1)) (geoGrid r n) := by rw [hsub, hMeq']
        _ = geoGrid r (n + 1) := (geoGrid_succ r n).symm

/-- **The capacity is attained by exactly one grid.**  Cycle 3's `IsGreatest`
statement upgrades to uniqueness of the maximiser. -/
theorem sweep_capacity_unique_maximiser {r : ℕ} (hr : 1 ≤ r) (s : ℕ) :
    IsGreatest {N | ∃ G : Finset ℕ, G.card = s ∧ Localises G r N} (geoSum r s) ∧
      ∀ G : Finset ℕ, G.card = s → Localises G r (geoSum r s) → G = geoGrid r s :=
  ⟨sweep_capacity_exact hr s, fun G hcard hloc => sweep_rigidity s G r hr hcard hloc⟩

/-! ## 3. Structural consequences: what an optimal sweep must and must not sample -/

/-- An optimal sweep samples the very top of its range: `geoSum r s ∈ G`. -/
theorem optimal_grid_top_point {r s : ℕ} (hr : 1 ≤ r) {G : Finset ℕ}
    (hcard : G.card = s) (hloc : Localises G r (geoSum r s)) (hs : 1 ≤ s) :
    geoSum r s ∈ G := by
  rw [sweep_rigidity s G r hr hcard hloc, geoGrid, Finset.mem_image]
  exact ⟨s - 1, Finset.mem_range.mpr (by omega), by rw [Nat.sub_add_cancel hs]⟩

/-- An optimal sweep at a ratio `r ≥ 2` **never** samples the budget `1`: every
point of the extremal grid is at least `r`.  In particular the classical
geometric grid `{1, r, r², …}`, which always starts at `1`, is never optimal. -/
theorem optimal_grid_avoids_one {r s : ℕ} (hr : 2 ≤ r) {G : Finset ℕ}
    (hcard : G.card = s) (hloc : Localises G r (geoSum r s)) :
    (1 : ℕ) ∉ G := by
  rw [sweep_rigidity s G r (by omega) hcard hloc, geoGrid]
  simp only [Finset.mem_image, Finset.mem_range, not_exists]
  rintro j ⟨-, hj⟩
  have hge : r ≤ geoSum r (j + 1) := by
    rw [geoSum_succ']
    omega
  omega

/-- **Rigidity is a capacity phenomenon, not a general one.**  One budget below
the capacity the optimum is already non-unique: both `{2,6}` and `{2,5}`
localise `[1,5]` to a factor `2` with two points, while at the capacity `6` only
`{2,6}` survives.  So the admissible grids genuinely contract to a single point
exactly at capacity. -/
theorem rigidity_is_sharp_at_capacity :
    Localises {2, 6} 2 5 ∧ Localises {2, 5} 2 5 ∧ ({2, 6} : Finset ℕ) ≠ {2, 5} ∧
      ¬ Localises {2, 5} 2 6 := by
  refine ⟨?_, ?_, by decide, ?_⟩
  · intro c hc1 hc2
    interval_cases c
    · exact ⟨2, by decide, by norm_num⟩
    · exact ⟨2, by decide, by norm_num⟩
    · exact ⟨6, by decide, by norm_num⟩
    · exact ⟨6, by decide, by norm_num⟩
    · exact ⟨6, by decide, by norm_num⟩
  · intro c hc1 hc2
    interval_cases c
    · exact ⟨2, by decide, by norm_num⟩
    · exact ⟨2, by decide, by norm_num⟩
    · exact ⟨5, by decide, by norm_num⟩
    · exact ⟨5, by decide, by norm_num⟩
    · exact ⟨5, by decide, by norm_num⟩
  · intro h
    obtain ⟨gp, hgp, h1, h2⟩ := h 6 (by norm_num) (by norm_num)
    simp only [Finset.mem_insert, Finset.mem_singleton] at hgp
    rcases hgp with rfl | rfl <;> omega

/-! ## 4. The NET-64 instance -/

theorem geoGrid_two_four : geoGrid 2 4 = {2, 6, 14, 30} := by decide

/-- **The NET-64 four-point sweep is unique.**  Cycle 3 showed that four
doubling-accurate sweep points cover exactly `[1,30]`; here that optimum is
achieved by one grid only, namely `{2, 6, 14, 30}`.  Every other four-point
sweep — in particular the measured coarse grid `{8, 16, 32, 64}` — has a blind
budget below `30`. -/
theorem net64_four_point_grid_unique (G : Finset ℕ) (hcard : G.card = 4)
    (hloc : Localises G 2 30) : G = {2, 6, 14, 30} := by
  have h30 : (30 : ℕ) = geoSum 2 4 := geoSum_two_four.symm
  rw [h30] at hloc
  rw [sweep_rigidity 4 G 2 (by norm_num) hcard hloc, geoGrid_two_four]

/-! ## 5. The dual question: how many points does a given range cost? -/

/-- **Minimal sweep cost.**  The least number of sampled budgets that localises
`[1, N]` to a factor `r` is the least `s` with `N ≤ geoSum r s`. -/
theorem sweep_min_points {r N s : ℕ} (hr : 1 ≤ r)
    (hs : IsLeast {t | N ≤ geoSum r t} s) :
    IsLeast {t | ∃ G : Finset ℕ, G.card = t ∧ Localises G r N} s := by
  constructor
  · exact ⟨geoGrid r s, geoGrid_card hr s, localises_mono (geoGrid_localises r s) hs.1⟩
  · rintro t ⟨G, hcard, hloc⟩
    exact hs.2 (sweep_capacity_upper t G r N hcard hr hloc)

/-- The least point count is always defined: `geoSum r` eventually exceeds `N`. -/
theorem sweep_min_points_exists {r : ℕ} (hr : 1 ≤ r) (N : ℕ) :
    ∃ s, IsLeast {t | N ≤ geoSum r t} s := by
  have hex : ∃ t, N ≤ geoSum r t := ⟨N, le_geoSum hr N⟩
  exact ⟨Nat.find hex, Nat.find_spec hex, fun t ht => Nat.find_le ht⟩

/-- **The measured coarse sweep was under-resourced by half.**  Localising every
budget of `[1, 64]` to a factor `2` costs exactly `6` sampled budgets; the NET-64
coarse sweep used `4`.  (With four points the honest range stops at `30`.) -/
theorem net64_min_points_for_64 :
    IsLeast {t | ∃ G : Finset ℕ, G.card = t ∧ Localises G 2 64} 6 := by
  refine sweep_min_points (r := 2) (N := 64) (by norm_num) ⟨by decide, ?_⟩
  intro t ht
  by_contra hlt
  push_neg at hlt
  have : geoSum 2 t ≤ geoSum 2 5 := geoSum_mono 2 (by omega)
  have h5 : geoSum 2 5 = 62 := by decide
  simp only [Set.mem_setOf_eq] at ht
  omega

end Catalog.Probability.NET64SweepRigidity