import Mathlib
import Combinatorics.KneeInvariance
import Probability.NET64GridArtifact
import Probability.NET64SharpSweepCost
import Probability.NET64SweepRigidity

/-!
# NET-64, cycle 5: the price of the never-under-provision constraint

Cycles 3–4 measured *one-sided* sweeps: a grid `G` localises `[1, N]` to a factor
`r` when every budget `c ≤ N` has a sampled budget in `[c, r·c]` — the deployment
constraint "never report a budget below the true knee".  The exact capacity is
`geoSum r s = r + r² + ⋯ + r^s`, attained by a unique grid.

This file computes the capacity of the *relaxed*, two-sided requirement, where the
reported budget may also sit a factor `r` **below** the knee:

    TwoSided G r N  ↔  ∀ c ∈ [1, N], ∃ g ∈ G, g ≤ r·c ∧ c ≤ r·g.

* `twoSided_capacity_upper` — an `s`-point grid satisfies `N ≤ geoSum (r²) s`.
  The same peeling induction as cycle 3 applies, but each step now buys a factor
  `r²` instead of `r`: the largest point serves budgets down to `⌈M/r⌉` *and* up
  to `r·M`.
* `twoSidedGrid_localises`, `twoSided_capacity_exact` — the bound is attained, by
  the grid `{r·(geoSum (r²) j + 1) : j < s}` (for `r = 2`: `{2, 10, 42, 170}`), so
  the two-sided capacity is exactly `geoSum (r²) s`.
* `twoSided_conjecture_false` — the value `r^{2s-1}` conjectured in
  `FUTURE_DIRECTIONS.md` is strictly too small already at `r = 2, s = 2`
  (`20 > 8`).
* `twoSided_between_one_sided` — the sandwich
  `geoSum r (2s-1) < geoSum (r²) s < geoSum r (2s)` for `r ≥ 2`: relaxing to
  two-sided localisation is worth *almost exactly a factor two in sweep points*,
  but strictly less than two.  So the never-under-provision constraint roughly
  doubles the cost of an honest sweep, and no better.
* `net64_two_sided_four_points` — the NET-64 instance: four two-sided points cover
  `[1, 340]`, against `[1, 30]` one-sided.
-/

namespace Catalog.Probability.NET64TwoSidedCapacity

open Finset Catalog.Probability.NET64SharpSweepCost

/-! ## 1. Two-sided localisation -/

/-- `TwoSided G r N`: every budget `c ∈ [1, N]` has a sampled budget within a
factor `r` of it, on *either* side.  This is the sweep requirement when reporting
a budget slightly below the knee is acceptable. -/
def TwoSided (G : Finset ℕ) (r N : ℕ) : Prop :=
  ∀ c, 1 ≤ c → c ≤ N → ∃ g ∈ G, g ≤ r * c ∧ c ≤ r * g

/-- One-sided localisation is the stronger requirement. -/
theorem twoSided_of_localises {G : Finset ℕ} {r N : ℕ} (hr : 1 ≤ r)
    (h : Localises G r N) : TwoSided G r N := by
  intro c hc1 hc2
  obtain ⟨g, hg, h1, h2⟩ := h c hc1 hc2
  exact ⟨g, hg, h2, le_trans (Nat.le_mul_of_pos_left c hr) (Nat.mul_le_mul_left r h1)⟩

theorem twoSided_mono {G : Finset ℕ} {r N M : ℕ} (h : TwoSided G r N) (hMN : M ≤ N) :
    TwoSided G r M := fun c hc1 hc2 => h c hc1 (le_trans hc2 hMN)

/-! ## 2. Upper bound: each point buys a factor `r²` -/

/-- **Two-sided sweep capacity, upper bound.**  A grid of `n` points that
localises `[1, N]` two-sidedly to a factor `r` satisfies
`N ≤ r² + r⁴ + ⋯ + r^{2n} = geoSum (r²) n`.

The peeling step is cycle 3's, with the serving interval widened: the largest
point `M` serves a budget `c` only when `M ≤ r·c`, so the other points must cover
`[1, ⌊(M-1)/r⌋]`; but `M` now reaches *up* to `r·M`, which is where the second
factor of `r` comes from. -/
theorem twoSided_capacity_upper :
    ∀ (n : ℕ) (G : Finset ℕ) (r N : ℕ), G.card = n → 1 ≤ r → TwoSided G r N →
      N ≤ geoSum (r ^ 2) n := by
  intro n
  induction n with
  | zero =>
      intro G r N hcard _ hloc
      by_contra hN
      push_neg at hN
      obtain ⟨g, hg, -, -⟩ := hloc 1 le_rfl (by omega)
      rw [Finset.card_eq_zero] at hcard
      simp [hcard] at hg
  | succ n ih =>
      intro G r N hcard hr hloc
      rcases Nat.eq_zero_or_pos N with hN0 | hN1
      · simp [hN0]
      have hGne : G.Nonempty := Finset.card_pos.mp (by omega)
      set M := G.max' hGne with hM
      obtain ⟨g, hg, -, hgN⟩ := hloc N hN1 le_rfl
      have hgM : g ≤ M := Finset.le_max' G g hg
      have hNrM : N ≤ r * M := le_trans hgN (Nat.mul_le_mul_left r hgM)
      have hM1 : 1 ≤ M := by
        rcases Nat.eq_zero_or_pos M with h0 | h
        · rw [h0] at hNrM; omega
        · exact h
      set N' := (M - 1) / r with hN'
      have hcard' : (G.erase M).card = n := by
        rw [Finset.card_erase_of_mem (Finset.max'_mem G hGne), hcard]
        omega
      have hmodlt : (M - 1) % r < r := Nat.mod_lt _ (by omega)
      have hrN' : r * N' ≤ M - 1 := Nat.mul_div_le _ _
      have hsplit : r * N' + (M - 1) % r = M - 1 := by
        have := Nat.div_add_mod (M - 1) r
        omega
      have hloc' : TwoSided (G.erase M) r (min N N') := by
        intro c hc1 hc2
        obtain ⟨g', hg', h1, h2⟩ := hloc c hc1 (le_trans hc2 (min_le_left _ _))
        have hcN' : c ≤ N' := le_trans hc2 (min_le_right _ _)
        have hlt : g' < M := by
          have h3 : r * c ≤ r * N' := Nat.mul_le_mul_left r hcN'
          omega
        exact ⟨g', Finset.mem_erase.mpr ⟨Nat.ne_of_lt hlt, hg'⟩, h1, h2⟩
      have hmin := ih (G.erase M) r (min N N') hcard' hr hloc'
      have hstep : geoSum (r ^ 2) (n + 1) = r ^ 2 * geoSum (r ^ 2) n + r ^ 2 :=
        geoSum_succ' (r ^ 2) n
      by_cases hcase : N ≤ N'
      · rw [min_eq_left hcase] at hmin
        exact le_trans hmin (geoSum_mono _ (Nat.le_succ n))
      · rw [min_eq_right (Nat.le_of_lt (Nat.lt_of_not_le hcase))] at hmin
        have hMle : M ≤ r * N' + r := by omega
        have h1 : N ≤ r * (r * N' + r) := le_trans hNrM (Nat.mul_le_mul_left r hMle)
        have h2 : r * (r * N' + r) = r ^ 2 * N' + r ^ 2 := by ring
        have h3 : r ^ 2 * N' ≤ r ^ 2 * geoSum (r ^ 2) n := Nat.mul_le_mul_left _ hmin
        omega

/-! ## 3. Attainment -/

/-- The extremal two-sided grid: point `j` sits one factor `r` above the top of
the range already covered, so that it reaches `r²` times as far.  For `r = 2`:
`{2, 10, 42, 170}`. -/
def twoSidedGrid (r s : ℕ) : Finset ℕ :=
  (range s).image fun j => r * (geoSum (r ^ 2) j + 1)

theorem twoSidedGrid_card {r : ℕ} (hr : 1 ≤ r) (s : ℕ) : (twoSidedGrid r s).card = s := by
  have hr2 : 1 ≤ r ^ 2 := Nat.one_le_pow _ _ (by omega)
  rw [twoSidedGrid, Finset.card_image_of_injOn, Finset.card_range]
  intro a _ b _ hab
  have h : geoSum (r ^ 2) a + 1 = geoSum (r ^ 2) b + 1 :=
    Nat.eq_of_mul_eq_mul_left (by omega) hab
  exact (geoSum_strictMono hr2).injective (by omega)

/-- **Attainment.**  The two-sided grid with `s` points covers all of
`[1, geoSum (r²) s]`. -/
theorem twoSidedGrid_localises (r s : ℕ) :
    TwoSided (twoSidedGrid r s) r (geoSum (r ^ 2) s) := by
  classical
  intro c hc1 hc2
  have hex : ∃ j, c ≤ geoSum (r ^ 2) j := ⟨s, hc2⟩
  set j := Nat.find hex with hj
  have hjc : c ≤ geoSum (r ^ 2) j := Nat.find_spec hex
  have hjpos : 0 < j := by
    rcases Nat.eq_zero_or_pos j with h0 | h
    · rw [h0, geoSum_zero] at hjc; omega
    · exact h
  have hjs : j ≤ s := Nat.find_le hc2
  have hprev : ¬ c ≤ geoSum (r ^ 2) (j - 1) := Nat.find_min hex (by omega)
  push_neg at hprev
  refine ⟨r * (geoSum (r ^ 2) (j - 1) + 1), ?_, ?_, ?_⟩
  · rw [twoSidedGrid, Finset.mem_image]
    exact ⟨j - 1, Finset.mem_range.mpr (by omega), rfl⟩
  · exact Nat.mul_le_mul_left r (by omega)
  · have hj1 : j - 1 + 1 = j := Nat.succ_pred_eq_of_pos hjpos
    have hrec : geoSum (r ^ 2) j = r ^ 2 * geoSum (r ^ 2) (j - 1) + r ^ 2 := by
      conv_lhs => rw [← hj1]
      exact geoSum_succ' (r ^ 2) (j - 1)
    have hexp : r * (r * (geoSum (r ^ 2) (j - 1) + 1))
        = r ^ 2 * geoSum (r ^ 2) (j - 1) + r ^ 2 := by ring
    omega

/-- **Exact two-sided capacity.**  `geoSum (r²) s = r² + r⁴ + ⋯ + r^{2s}` is
achieved by an `s`-point grid, and no `s`-point grid does better. -/
theorem twoSided_capacity_exact {r : ℕ} (hr : 1 ≤ r) (s : ℕ) :
    IsGreatest {N | ∃ G : Finset ℕ, G.card = s ∧ TwoSided G r N} (geoSum (r ^ 2) s) := by
  constructor
  · exact ⟨twoSidedGrid r s, twoSidedGrid_card hr s, twoSidedGrid_localises r s⟩
  · rintro N ⟨G, hcard, hloc⟩
    exact twoSided_capacity_upper s G r N hcard hr hloc

/-! ## 4. The conjectured value was wrong, and the true one is a factor-two saving -/

/-- The value `r^{2s-1}` conjectured for the two-sided capacity in
`FUTURE_DIRECTIONS.md` is **strictly too small**: at `r = 2, s = 2` it predicts
`8`, while two points genuinely cover `[1, 20]`. -/
theorem twoSided_conjecture_false :
    ∃ (G : Finset ℕ) (r N s : ℕ), 1 ≤ r ∧ G.card = s ∧ TwoSided G r N ∧
      r ^ (2 * s - 1) < N := by
  refine ⟨twoSidedGrid 2 2, 2, geoSum (2 ^ 2) 2, 2, by norm_num,
    twoSidedGrid_card (by norm_num) 2, twoSidedGrid_localises 2 2, ?_⟩
  norm_num [geoSum, Finset.sum_range_succ]

theorem geoSum_add_lt_pow {r : ℕ} (hr : 2 ≤ r) (m : ℕ) : geoSum r m + r ≤ r ^ (m + 1) := by
  induction m with
  | zero => simp
  | succ n ih =>
      have hpos : 0 < r ^ (n + 1) := Nat.pow_pos (by omega)
      have hdouble : 2 * r ^ (n + 1) ≤ r ^ (n + 1 + 1) := by
        have hre : r ^ (n + 1 + 1) = r * r ^ (n + 1) := by ring
        rw [hre]
        exact Nat.mul_le_mul_right _ hr
      rw [geoSum_succ]
      omega

theorem geoSum_sq_le_geoSum (r s : ℕ) : geoSum (r ^ 2) s ≤ geoSum r (2 * s) := by
  induction s with
  | zero => simp
  | succ n ih =>
      have hpow : (r ^ 2) ^ (n + 1) = r ^ (2 * n + 2) := by
        rw [← pow_mul]; ring_nf
      have h1 : 2 * (n + 1) = (2 * n + 1) + 1 := by ring
      have e1 : geoSum r (2 * (n + 1)) = geoSum r (2 * n + 1) + r ^ (2 * n + 2) := by
        rw [h1, geoSum_succ]
      have e2 : geoSum r (2 * n + 1) = geoSum r (2 * n) + r ^ (2 * n + 1) := geoSum_succ r (2 * n)
      rw [geoSum_succ, hpow, e1, e2]
      omega

/-- **The price of never under-provisioning is a factor two in sweep points — and
no more.**  For every ratio `r ≥ 2` and every point count `s ≥ 1`,

    geoSum r (2s-1)  <  geoSum (r²) s  <  geoSum r (2s),

i.e. an `s`-point two-sided sweep covers strictly more than a `(2s-1)`-point
one-sided sweep and strictly less than a `2s`-point one.  Allowing the sweep to
report a budget below the knee therefore halves its cost, up to a single point. -/
theorem twoSided_between_one_sided {r s : ℕ} (hr : 2 ≤ r) (hs : 1 ≤ s) :
    geoSum r (2 * s - 1) < geoSum (r ^ 2) s ∧ geoSum (r ^ 2) s < geoSum r (2 * s) := by
  obtain ⟨t, rfl⟩ : ∃ t, s = t + 1 := ⟨s - 1, by omega⟩
  constructor
  · -- the top term `r^{2s}` of the two-sided sum already beats the whole one-sided sum
    have hidx : 2 * (t + 1) - 1 = 2 * t + 1 := by omega
    have hbound : geoSum r (2 * t + 1) + r ≤ r ^ (2 * t + 2) := geoSum_add_lt_pow hr (2 * t + 1)
    have hpow : (r ^ 2) ^ (t + 1) = r ^ (2 * t + 2) := by rw [← pow_mul]; ring_nf
    have hge : r ^ (2 * t + 2) ≤ geoSum (r ^ 2) (t + 1) := by
      rw [geoSum_succ, hpow]; omega
    rw [hidx]
    omega
  · have ih := geoSum_sq_le_geoSum r t
    have hpow : (r ^ 2) ^ (t + 1) = r ^ (2 * t + 2) := by rw [← pow_mul]; ring_nf
    have h1 : 2 * (t + 1) = (2 * t + 1) + 1 := by ring
    have e1 : geoSum r (2 * (t + 1)) = geoSum r (2 * t + 1) + r ^ (2 * t + 2) := by
      rw [h1, geoSum_succ]
    have e2 : geoSum r (2 * t + 1) = geoSum r (2 * t) + r ^ (2 * t + 1) := geoSum_succ r (2 * t)
    have hpos : 0 < r ^ (2 * t + 1) := Nat.pow_pos (by omega)
    rw [geoSum_succ, hpow, e1, e2]
    omega

/-! ## 5. Rigidity again: the two-sided optimum is also unique -/

theorem twoSidedGrid_succ (r s : ℕ) :
    twoSidedGrid r (s + 1) = insert (r * (geoSum (r ^ 2) s + 1)) (twoSidedGrid r s) := by
  simp [twoSidedGrid, Finset.range_add_one, Finset.image_insert]

/-- **Rigidity of the two-sided optimum.**  Relaxing the deployment constraint
does not create extra optimal designs: a grid of `s` points covering the whole of
`[1, geoSum (r²) s]` two-sidedly is necessarily `twoSidedGrid r s`.  The equality
analysis is cycle 4's, run through the widened serving interval: at capacity the
largest point must satisfy `r·M = geoSum (r²) s` exactly. -/
theorem twoSided_rigidity :
    ∀ (s : ℕ) (G : Finset ℕ) (r : ℕ), 1 ≤ r → G.card = s →
      TwoSided G r (geoSum (r ^ 2) s) → G = twoSidedGrid r s := by
  intro s
  induction s with
  | zero =>
      intro G r _ hcard _
      rw [Finset.card_eq_zero] at hcard
      simp [hcard, twoSidedGrid]
  | succ n ih =>
      intro G r hr hcard hloc
      have hr2 : 1 ≤ r ^ 2 := Nat.one_le_pow _ _ (by omega)
      have hNrec : geoSum (r ^ 2) (n + 1) = r ^ 2 * geoSum (r ^ 2) n + r ^ 2 :=
        geoSum_succ' (r ^ 2) n
      have hN1 : 1 ≤ geoSum (r ^ 2) (n + 1) := by omega
      have hGne : G.Nonempty := Finset.card_pos.mp (by omega)
      set M := G.max' hGne with hM
      have hMmem : M ∈ G := Finset.max'_mem G hGne
      obtain ⟨g, hg, -, hgN⟩ := hloc _ hN1 le_rfl
      have hNrM : geoSum (r ^ 2) (n + 1) ≤ r * M :=
        le_trans hgN (Nat.mul_le_mul_left r (Finset.le_max' G g hg))
      have hM1 : 1 ≤ M := by
        rcases Nat.eq_zero_or_pos M with h0 | h
        · rw [h0] at hNrM; omega
        · exact h
      set N' := (M - 1) / r with hN'
      have hcard' : (G.erase M).card = n := by
        rw [Finset.card_erase_of_mem hMmem, hcard]
        omega
      have hmodlt : (M - 1) % r < r := Nat.mod_lt _ (by omega)
      have hrN' : r * N' ≤ M - 1 := Nat.mul_div_le _ _
      have hsplit : r * N' + (M - 1) % r = M - 1 := by
        have := Nat.div_add_mod (M - 1) r
        omega
      have hloc' : TwoSided (G.erase M) r (min (geoSum (r ^ 2) (n + 1)) N') := by
        intro c hc1 hc2
        obtain ⟨g', hg', h1, h2⟩ := hloc c hc1 (le_trans hc2 (min_le_left _ _))
        have hcN' : c ≤ N' := le_trans hc2 (min_le_right _ _)
        have hlt : g' < M := by
          have h3 : r * c ≤ r * N' := Nat.mul_le_mul_left r hcN'
          omega
        exact ⟨g', Finset.mem_erase.mpr ⟨Nat.ne_of_lt hlt, hg'⟩, h1, h2⟩
      have hmin := twoSided_capacity_upper n (G.erase M) r _ hcard' hr hloc'
      have hmono : geoSum (r ^ 2) n < geoSum (r ^ 2) (n + 1) :=
        geoSum_strictMono hr2 (Nat.lt_succ_self n)
      have hcase : ¬ geoSum (r ^ 2) (n + 1) ≤ N' := by
        intro hle
        rw [min_eq_left hle] at hmin
        omega
      have hminEq : min (geoSum (r ^ 2) (n + 1)) N' = N' :=
        min_eq_right (Nat.le_of_lt (Nat.lt_of_not_le hcase))
      rw [hminEq] at hmin hloc'
      -- the capacity chain collapses to equalities
      have hMle : M ≤ r * N' + r := by omega
      have hstep : r * (r * N' + r) = r ^ 2 * N' + r ^ 2 := by ring
      have hle2 : r ^ 2 * N' ≤ r ^ 2 * geoSum (r ^ 2) n := Nat.mul_le_mul_left _ hmin
      have hrM : r * M ≤ r * (r * N' + r) := Nat.mul_le_mul_left r hMle
      have hN'eq : N' = geoSum (r ^ 2) n := by
        have hge : r ^ 2 * geoSum (r ^ 2) n ≤ r ^ 2 * N' := by omega
        have := Nat.le_antisymm hmin (Nat.le_of_mul_le_mul_left hge (by omega))
        omega
      have hMeq : M = r * (geoSum (r ^ 2) n + 1) := by
        have hsubst : r ^ 2 * N' = r ^ 2 * geoSum (r ^ 2) n := by rw [hN'eq]
        have hMlow : r * (r * N' + r) ≤ r * M := by omega
        have : r * N' + r ≤ M := Nat.le_of_mul_le_mul_left hMlow (by omega)
        have hexp : r * (geoSum (r ^ 2) n + 1) = r * N' + r := by rw [hN'eq]; ring
        omega
      have hlocsub : TwoSided (G.erase M) r (geoSum (r ^ 2) n) := by
        rw [← hN'eq]; exact hloc'
      have hsub := ih (G.erase M) r hr hcard' hlocsub
      calc G = insert M (G.erase M) := (Finset.insert_erase hMmem).symm
        _ = insert (r * (geoSum (r ^ 2) n + 1)) (twoSidedGrid r n) := by rw [hsub, hMeq]
        _ = twoSidedGrid r (n + 1) := (twoSidedGrid_succ r n).symm

/-! ## 6. The NET-64 instance -/

theorem geoSum_four_four : geoSum (2 ^ 2) 4 = 340 := by decide

theorem twoSidedGrid_two_four : twoSidedGrid 2 4 = {2, 10, 42, 170} := by decide

/-- The unique optimal four-point two-sided sweep at ratio `2` is
`{2, 10, 42, 170}` — compare the unique one-sided optimum `{2, 6, 14, 30}`. -/
theorem net64_two_sided_grid_unique (G : Finset ℕ) (hcard : G.card = 4)
    (hloc : TwoSided G 2 340) : G = {2, 10, 42, 170} := by
  rw [← geoSum_four_four] at hloc
  rw [twoSided_rigidity 4 G 2 (by norm_num) hcard hloc, twoSidedGrid_two_four]

/-- **The NET-64 instance, two-sided.**  Four sweep points that may report a
budget within a factor `2` on either side cover `[1, 340]`; the same four points
under the deployment constraint cover only `[1, 30]` (cycle 3), and `340` is
optimal. -/
theorem net64_two_sided_four_points :
    IsGreatest {N | ∃ G : Finset ℕ, G.card = 4 ∧ TwoSided G 2 N} 340 ∧
      IsGreatest {N | ∃ G : Finset ℕ, G.card = 4 ∧ Localises G 2 N} 30 := by
  refine ⟨?_, ?_⟩
  · have h := twoSided_capacity_exact (r := 2) (by norm_num) 4
    rwa [geoSum_four_four] at h
  · have h := sweep_capacity_exact (r := 2) (by norm_num) 4
    rwa [geoSum_two_four] at h

end Catalog.Probability.NET64TwoSidedCapacity