import Mathlib
import Combinatorics.KneeInvariance
import Probability.NET64GridArtifact
import Probability.NET64GridDesign

/-!
# NET-64, cycle 3: the *exact* capacity of a budget sweep

`Probability/NET64GridDesign.lean` proved a two-sided but non-matching pair of
bounds for the design question *"how many sampled budgets does an honest sweep
need?"*:

* geometric grids `{r^0, …, r^s}` (`s+1` points) localise every budget in
  `[1, r^s]` to a factor `r` (`ratioGrid_upto_covers`), and
* every grid localising `[1, N]` to a factor `r` has `N < (r+1)^{|G|}`
  (`grid_card_lower_bound`).

Direction **D2** of `FUTURE_DIRECTIONS.md` conjectured that the truth is the
geometric value `N ≤ r^{|G|}`.  This file settles the question, and the answer
is *neither* endpoint:

* `sweep_capacity_upper` — **upper bound**: a grid of `s` points localising
  `[1, N]` to a factor `r ≥ 1` satisfies `N ≤ r + r² + ⋯ + r^s = geoSum r s`.
* `geoGrid_localises`, `geoGrid_card` — **attainment**: the *offset* geometric
  grid `{r, r+r², …, ∑_{i≤s} r^i}` has exactly `s` points and localises the whole
  of `[1, geoSum r s]`.
* `sweep_capacity_exact` — hence `geoSum r s` is the **exact** capacity of an
  `s`-point ratio-`r` sweep: it is achieved, and nothing larger is.
* `D2_conjecture_false` — the conjectured value `r^{|G|}` is *strictly* too
  small: the two-point grid `{2, 6}` localises `[1, 6]` to a factor `2`, while
  `r^{|G|} = 4`.  So the honest sweep is cheaper than the pure geometric grid
  suggests: shifting each grid point up buys a constant factor `r/(r-1)` of
  range for free.
* `geoSum_lt_grid_card_bound` — and the cycle-2 bound `(r+1)^s` is *strictly*
  too large, so cycle 2's inequality was never tight either.
* `net64_four_point_capacity_exact` — the concrete NET-64 instance: a four-point
  doubling-accurate sweep covers `[1, 30]` and no four-point grid whatsoever
  covers `[1, 31]`.  (Cycle 2 could only rule out `81`.)

Everything is stated through `Localises`, which by the factorisation theorem
`gridKnee_eq_gridCeil` of `NET64GridArtifact` is exactly the condition that the
sweep reports every knee in `[1, N]` within a factor `r`; `localises_gridKnee_le`
records that translation.
-/

namespace Catalog.Probability.NET64SharpSweepCost

open Finset Combinatorics.KneeInvariance Catalog.Probability.NET64GridArtifact

/-! ## 1. The capacity function -/

/-- `geoSum r s = r + r² + ⋯ + r^s`, the exact number of budgets an `s`-point
ratio-`r` sweep can localise. -/
def geoSum (r s : ℕ) : ℕ := ∑ i ∈ range s, r ^ (i + 1)

@[simp] theorem geoSum_zero (r : ℕ) : geoSum r 0 = 0 := by simp [geoSum]

theorem geoSum_succ (r s : ℕ) : geoSum r (s + 1) = geoSum r s + r ^ (s + 1) :=
  Finset.sum_range_succ _ _

/-- The defining recurrence: one more sweep point multiplies the reachable range
by `r` and then adds `r`. -/
theorem geoSum_succ' (r s : ℕ) : geoSum r (s + 1) = r * geoSum r s + r := by
  rw [geoSum, geoSum, Finset.sum_range_succ' (fun i => r ^ (i + 1)) s, Finset.mul_sum]
  simp [pow_succ, mul_comm]

theorem geoSum_mono (r : ℕ) : Monotone (geoSum r) :=
  monotone_nat_of_le_succ fun n => by rw [geoSum_succ]; omega

theorem geoSum_strictMono {r : ℕ} (hr : 1 ≤ r) : StrictMono (geoSum r) := by
  refine strictMono_nat_of_lt_succ fun n => ?_
  have : 0 < r ^ (n + 1) := Nat.pow_pos hr
  rw [geoSum_succ]
  omega

theorem geoSum_one (s : ℕ) : geoSum 1 s = s := by
  simp [geoSum]

/-! ## 2. What it means for a grid to localise a range -/

/-- `Localises G r N`: every budget `c ∈ [1, N]` has a sampled budget within a
factor `r` above it.  By `gridKnee_eq_gridCeil` this is exactly the statement
that the sweep on `G` reports every knee in `[1, N]` to within a factor `r`. -/
def Localises (G : Finset ℕ) (r N : ℕ) : Prop :=
  ∀ c, 1 ≤ c → c ≤ N → ∃ gp ∈ G, c ≤ gp ∧ gp ≤ r * c

/-- Translation into the language of sweep readings: if `G` localises `[1, N]`
then any monotone curve whose true knee lies in `[1, N]` is reported by the
sweep within a factor `r`. -/
theorem localises_gridKnee_le {G : Finset ℕ} {r N : ℕ} (h : Localises G r N)
    {A : ℕ → ℚ} {g : ℚ} (hA : Monotone A) (hne : ∃ m, g ≤ A m)
    (h1 : 1 ≤ knee A g) (h2 : knee A g ≤ N) :
    gridKnee (G : Set ℕ) A g ≤ r * knee A g := by
  obtain ⟨gp, hgp, hge, hle⟩ := h (knee A g) h1 h2
  have hval : g ≤ A gp := le_trans (Combinatorics.KneeInvariance.knee_mem hne) (hA hge)
  exact le_trans (gridKnee_le (by exact_mod_cast hgp) hval) hle

/-! ## 3. The upper bound: `s` points buy at most `geoSum r s` -/

/-- **Sweep capacity, upper bound.**  A grid of `n` points that localises every
budget of `[1, N]` to a factor `r` satisfies `N ≤ r + r² + ⋯ + r^n`.

The proof strips the largest grid point `M`.  A budget `c` is served by `M` only
when `M ≤ r·c`, so the remaining `n-1` points must themselves localise the whole
initial segment `[1, (M-1)/r]`; induction bounds that segment by `geoSum r (n-1)`
and the relation `M ≤ r·((M-1)/r) + r` propagates the bound. -/
theorem sweep_capacity_upper :
    ∀ (n : ℕ) (G : Finset ℕ) (r N : ℕ), G.card = n → 1 ≤ r → Localises G r N →
      N ≤ geoSum r n := by
  intro n
  induction n with
  | zero =>
      intro G r N hcard _ hloc
      by_contra hN
      push_neg at hN
      obtain ⟨gp, hgp, -, -⟩ := hloc 1 le_rfl (by omega)
      rw [Finset.card_eq_zero] at hcard
      simp [hcard] at hgp
  | succ n ih =>
      intro G r N hcard hr hloc
      rcases Nat.eq_zero_or_pos N with hN0 | hN1
      · simp [hN0]
      -- `G` is nonempty, so it has a largest point `M`, and `M ≥ N`.
      have hGne : G.Nonempty := Finset.card_pos.mp (by omega)
      set M := G.max' hGne with hM
      obtain ⟨gp, hgp, hge, -⟩ := hloc N hN1 le_rfl
      have hNM : N ≤ M := le_trans hge (Finset.le_max' G gp hgp)
      have hM1 : 1 ≤ M := le_trans hN1 hNM
      set N' := (M - 1) / r with hN'
      -- the remaining points localise `[1, min N N']`
      have hcard' : (G.erase M).card = n := by
        rw [Finset.card_erase_of_mem (Finset.max'_mem G hGne), hcard]
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
          have h4 : gp' ≤ M - 1 := le_trans h2 (le_trans h3 hrN')
          have h5 : M - 1 < M := by omega
          exact lt_of_le_of_lt h4 h5
        exact ⟨gp', Finset.mem_erase.mpr ⟨Nat.ne_of_lt hlt, hgp'⟩, h1, h2⟩
      have hmin := ih (G.erase M) r (min N N') hcard' hr hloc'
      by_cases hcase : N ≤ N'
      · have : min N N' = N := min_eq_left hcase
        rw [this] at hmin
        exact le_trans hmin (geoSum_mono r (Nat.le_succ n))
      · have hminN' : min N N' = N' :=
          min_eq_right (Nat.le_of_lt (Nat.lt_of_not_le hcase))
        rw [hminN'] at hmin
        -- `M ≤ r·N' + r` because `N' = (M-1)/r`
        have hMlt : M - 1 < r * N' + r := by
          rw [← hsplit]; exact Nat.add_lt_add_left hmodlt _
        have hMle : M ≤ r * N' + r := Nat.le_of_pred_lt hMlt
        have hchain : r * N' + r ≤ r * geoSum r n + r :=
          Nat.add_le_add_right (Nat.mul_le_mul (le_refl r) hmin) r
        rw [geoSum_succ']
        exact le_trans hNM (le_trans hMle hchain)

/-! ## 4. Attainment: the offset geometric grid -/

/-- The extremal grid `{r, r+r², …, r+⋯+r^s}` — the geometric grid shifted so
that each point sits at the *top* of the interval it serves. -/
def geoGrid (r s : ℕ) : Finset ℕ := (range s).image fun j => geoSum r (j + 1)

theorem geoGrid_card {r : ℕ} (hr : 1 ≤ r) (s : ℕ) : (geoGrid r s).card = s := by
  rw [geoGrid, Finset.card_image_of_injective _ ?_, Finset.card_range]
  intro a b hab
  have := (geoSum_strictMono hr).injective hab
  omega

/-- **Attainment.**  The offset geometric grid with `s` points localises every
budget of `[1, geoSum r s]` to a factor `r`. -/
theorem geoGrid_localises (r s : ℕ) :
    Localises (geoGrid r s) r (geoSum r s) := by
  classical
  intro c hc1 hc2
  have hex : ∃ j, c ≤ geoSum r j := ⟨s, hc2⟩
  set j := Nat.find hex with hj
  have hjc : c ≤ geoSum r j := Nat.find_spec hex
  have hjpos : 0 < j := by
    rcases Nat.eq_zero_or_pos j with h0 | h
    · rw [h0, geoSum_zero] at hjc
      omega
    · exact h
  have hjs : j ≤ s := Nat.find_le hc2
  have hprev : ¬ c ≤ geoSum r (j - 1) := Nat.find_min hex (by omega)
  push_neg at hprev
  refine ⟨geoSum r j, ?_, hjc, ?_⟩
  · rw [geoGrid, Finset.mem_image]
    exact ⟨j - 1, Finset.mem_range.mpr (by omega),
      by rw [Nat.sub_add_cancel hjpos]⟩
  · have hj1 : j - 1 + 1 = j := Nat.succ_pred_eq_of_pos hjpos
    have hrec : geoSum r j = r * geoSum r (j - 1) + r := by
      conv_lhs => rw [← hj1]
      exact geoSum_succ' r (j - 1)
    have hle : r * geoSum r (j - 1) + r ≤ r * (c - 1) + r :=
      Nat.add_le_add_right (Nat.mul_le_mul (le_refl r) (by omega)) r
    have hcc : r * (c - 1) + r = r * c := by
      cases c with
      | zero => omega
      | succ m => simp [Nat.mul_succ]
    omega

/-- **Exact sweep capacity.**  `geoSum r s` is achieved by an `s`-point grid, and
no `s`-point grid does better.  This is the exact answer to the design question
left open in cycle 2. -/
theorem sweep_capacity_exact {r : ℕ} (hr : 1 ≤ r) (s : ℕ) :
    IsGreatest {N | ∃ G : Finset ℕ, G.card = s ∧ Localises G r N} (geoSum r s) := by
  constructor
  · exact ⟨geoGrid r s, geoGrid_card hr s, geoGrid_localises r s⟩
  · rintro N ⟨G, hcard, hloc⟩
    exact sweep_capacity_upper s G r N hcard hr hloc

/-! ## 5. Both cycle-2 endpoints are strictly wrong -/

/-- The conjectured geometric capacity `r^{|G|}` (direction D2) is **too small**:
the two-point grid `{2, 6}` localises `[1, 6]` to a factor `2`, beating
`2² = 4`.  Offsetting the grid points buys strictly more range than the pure
geometric grid `{1, 2, 4, …}`. -/
theorem D2_conjecture_false :
    ∃ (G : Finset ℕ) (r N : ℕ), 1 ≤ r ∧ Localises G r N ∧ r ^ G.card < N := by
  refine ⟨{2, 6}, 2, 6, by norm_num, ?_, by decide⟩
  intro c hc1 hc2
  interval_cases c
  · exact ⟨2, by decide, by norm_num⟩
  · exact ⟨2, by decide, by norm_num⟩
  · exact ⟨6, by decide, by norm_num⟩
  · exact ⟨6, by decide, by norm_num⟩
  · exact ⟨6, by decide, by norm_num⟩
  · exact ⟨6, by decide, by norm_num⟩

/-- The cycle-2 bound `(r+1)^s` is **too large**: the true capacity is strictly
below it for every nonempty grid, so `grid_card_lower_bound` was never tight. -/
theorem geoSum_lt_grid_card_bound {r s : ℕ} (hr : 1 ≤ r) (hs : 1 ≤ s) :
    geoSum r s < (r + 1) ^ s := by
  induction s with
  | zero => omega
  | succ n ih =>
      rcases Nat.eq_zero_or_pos n with hn | hn
      · subst hn
        simp [geoSum_succ]
      · have hlt := ih hn
        have hpow : r ≤ (r + 1) ^ n := by
          calc r ≤ r + 1 := by omega
            _ = (r + 1) ^ 1 := (pow_one _).symm
            _ ≤ (r + 1) ^ n := Nat.pow_le_pow_right (by omega) hn
        have hexp : (r + 1) ^ (n + 1) = r * (r + 1) ^ n + (r + 1) ^ n := by ring
        have hpos : 0 < (r + 1) ^ n := Nat.pow_pos (by omega)
        have hstep : r * geoSum r n + r ≤ r * (r + 1) ^ n := by
          have h1 : geoSum r n + 1 ≤ (r + 1) ^ n := hlt
          have h2 : r * (geoSum r n + 1) ≤ r * (r + 1) ^ n :=
            Nat.mul_le_mul (le_refl r) h1
          have h3 : r * (geoSum r n + 1) = r * geoSum r n + r := by ring
          omega
        rw [geoSum_succ', hexp]
        omega

/-! ## 6. The NET-64 instance, exactly -/

/-- `geoSum 2 4 = 30`: four doubling-accurate sweep points, thirty budgets. -/
theorem geoSum_two_four : geoSum 2 4 = 30 := by decide

/-- **The four-point sweep, exactly.**  A four-point grid localising to a factor
`2` covers `[1, 30]` — witnessed by `{2, 6, 14, 30}` — and no four-point grid at
all covers `[1, 31]`.  Cycle 2's `net64_coarse_sweep_capacity` could only exclude
`81`; this is the exact boundary. -/
theorem net64_four_point_capacity_exact :
    (∃ G : Finset ℕ, G.card = 4 ∧ Localises G 2 30) ∧
      ¬ ∃ G : Finset ℕ, G.card = 4 ∧ Localises G 2 31 := by
  have hgreat := sweep_capacity_exact (r := 2) (by norm_num) 4
  rw [geoSum_two_four] at hgreat
  refine ⟨hgreat.1, ?_⟩
  rintro ⟨G, hcard, hloc⟩
  have := hgreat.2 ⟨G, hcard, hloc⟩
  omega

/-- The NET-64 coarse grid `{8, 16, 32, 64}` is *not* extremal: it has as many
points as the optimum `{2, 6, 14, 30}` yet localises strictly less, failing
already at the smallest budgets — nothing of it lies in `[1, 2]` or in `[3, 6]`.
Starting a doubling sweep high wastes points at the bottom of the range. -/
theorem net64_coarse_grid_not_extremal :
    ¬ Localises {8, 16, 32, 64} 2 30 := by
  intro h
  obtain ⟨gp, hgp, h1, h2⟩ := h 3 (by norm_num) (by norm_num)
  simp only [Finset.mem_insert, Finset.mem_singleton] at hgp
  rcases hgp with rfl | rfl | rfl | rfl <;> omega

end Catalog.Probability.NET64SharpSweepCost