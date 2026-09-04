/-
# From periods to windows: a certified error term for the small-prime cell measure

## Research context (FACT round-95 #4, exp 606, cycle 3)

`Novelty.KappaCellPeriod` computes the distribution of small-prime cells **exactly**, but
only over a full period `M = ∏_{p ∈ B} p` of the base.  Experiment 606 does not sample a
period: it samples a window of `n_hit` integers of a fixed bit-width, with `n ≪ M` as soon as
the base has a dozen primes.  The gap between the two is precisely the place where a sampling
artefact could imitate a genuine arithmetic effect — the same failure mode that the run's own
pre-run audits caught twice in the random-stream design.

This file closes that gap.  For an arbitrary initial window `[0, N)` the cell counts obey

  `| #{v < N : cell(v) = S} − N · ∏_{p∈S} (1/p) · ∏_{p ∈ B∖S} (1 − 1/p) | ≤ 2^{|B∖S|}`,

an error bound that is *independent of `N`* — so the empirical cell frequencies converge to
the exact periodic densities at rate `2^{|B|}/N`, with a fully explicit constant.

## Main results

* `cell_indicator_inclusion_exclusion` — the Möbius expansion of the cell indicator:
  `1[cell(v) = S] = ∑_{T ⊆ B∖S} (−1)^{|T|} · 1[(∏_{p ∈ S ∪ T} p) ∣ v]`, valid pointwise for
  every integer `v` (the engine of the whole file).
* `card_multiples_range`, `abs_card_multiples_sub_div_le` — the count of multiples of `d` in
  `[0, N)` is `⌈N/d⌉`, within `1` of `N/d`.
* `abs_card_cellFiber_window_sub_le` — **the window bound** displayed above.
* `cell_frequency_tendsto` — consequently the empirical frequency of any cell in `[0, N)`
  converges, as `N → ∞`, to the exact periodic density of `Novelty.KappaCellPeriod`.

Combined with `Novelty.KappaSufficiencyScale`, this means the slope and sufficiency laws are
statements about *sampled* populations too, not only about complete periods.

-- !-- Lab Notes -- !--
-- HYPOTHESIS (cycle 3).  The periodic cell densities should survive truncation to a window
--   with an error depending only on the base, not on the window length.
-- EXPERIMENT (`#eval`, B = {2,3,5}, S = {2}).  Window counts for N = 10, 50, 97, 1000:
--   3, 13, 26, 267 against the predicted `8N/30`: 2.67, 13.33, 25.87, 266.67 — errors
--   0.33, 0.33, 0.13, 0.33, all well inside the proved bound `2^{|B∖S|} = 4`, and with no
--   growth in `N` (the point of the bound).
-- OUTCOME.  Bound proved for every base, cell and window length, with no coprimality or size
--   hypothesis on `N`.
-- FAILURE ANALYSIS.  A first attempt bounded the error by the number of incomplete periods
--   (`≤ M`), which is useless once `N < M` — exactly the experimental regime.  Expanding the
--   indicator by inclusion–exclusion *first* and only then truncating each divisibility count
--   replaces `M` by `2^{|B∖S|}`.
-/
import Mathlib
import Novelty.KappaCellPeriod

open Finset

namespace Catalog.Novelty.KappaWindowError

open Catalog.Novelty.KappaCellPeriod

variable {B S : Finset ℕ} {d : ℕ}

/-! ## 1. Counting multiples in an initial window -/

/-- The multiples of `d` in `[0, N)` are exactly `⌈N/d⌉` many. -/
theorem card_multiples_range (hd : 0 < d) (N : ℕ) :
    ((range N).filter (fun v => d ∣ v)).card = (N + d - 1) / d := by
  classical
  set c : ℕ := (N + d - 1) / d with hc
  have hiff : ∀ k : ℕ, d * k < N ↔ k < c := by
    intro k
    rw [hc]
    constructor
    · intro h
      by_contra hk
      push_neg at hk
      have h1 : (N + d - 1) / d < k + 1 := by omega
      have h2 : N + d - 1 < (k + 1) * d := (Nat.div_lt_iff_lt_mul hd).1 h1
      have h3 : (k + 1) * d = k * d + d := by ring
      have h4 : k * d = d * k := Nat.mul_comm _ _
      omega
    · intro h
      have h1 : k + 1 ≤ (N + d - 1) / d := h
      have h2 : (k + 1) * d ≤ N + d - 1 := (Nat.le_div_iff_mul_le hd).1 h1
      have h3 : (k + 1) * d = k * d + d := by ring
      have h4 : k * d = d * k := Nat.mul_comm _ _
      omega
  have himg : (range N).filter (fun v => d ∣ v) = (range c).image (fun k => d * k) := by
    ext v
    simp only [mem_filter, mem_range, mem_image]
    constructor
    · rintro ⟨hv, k, rfl⟩
      exact ⟨k, (hiff k).1 hv, rfl⟩
    · rintro ⟨k, hk, rfl⟩
      exact ⟨(hiff k).2 hk, Dvd.intro k rfl⟩
  rw [himg, Finset.card_image_of_injective _ (fun a b h => Nat.eq_of_mul_eq_mul_left hd h),
    Finset.card_range]

/-- The count of multiples of `d` in a window `[0, N)` is within `1` of `N/d`. -/
theorem abs_card_multiples_sub_div_le (hd : 0 < d) (N : ℕ) :
    |((((range N).filter (fun v => d ∣ v)).card : ℝ)) - (N : ℝ) / d| ≤ 1 := by
  classical
  set c : ℕ := (N + d - 1) / d with hc
  have hcard : ((range N).filter (fun v => d ∣ v)).card = c := card_multiples_range hd N
  have hdr : (0 : ℝ) < d := by exact_mod_cast hd
  -- `N ≤ c * d`
  have hup : N ≤ c * d := by
    have h1 : (N + d - 1) / d ≤ (N + d - 1) / d := le_refl _
    have h2 : c * d ≤ N + d - 1 := by
      rw [hc]
      exact Nat.div_mul_le_self _ _
    by_contra hcon
    push_neg at hcon
    -- if `c * d < N` then `c + 1 ≤ (N + d - 1)/d`, contradicting `c = (N+d-1)/d`
    have h3 : (c + 1) * d ≤ N + d - 1 := by
      have : (c + 1) * d = c * d + d := by ring
      omega
    have h4 : c + 1 ≤ (N + d - 1) / d := (Nat.le_div_iff_mul_le hd).2 h3
    omega
  -- `(c - 1) * d < N`
  have hlow : c * d < N + d := by
    rcases Nat.eq_zero_or_pos c with hc0 | hcpos
    · simp [hc0]
      omega
    · have h2 : c * d ≤ N + d - 1 := by
        rw [hc]; exact Nat.div_mul_le_self _ _
      omega
  have hupR : (N : ℝ) ≤ (c : ℝ) * d := by exact_mod_cast hup
  have hlowR : (c : ℝ) * d < (N : ℝ) + d := by exact_mod_cast hlow
  have h1 : (N : ℝ) / d ≤ (c : ℝ) := by
    rw [div_le_iff₀ hdr]; linarith
  have h2 : (c : ℝ) - 1 < (N : ℝ) / d := by
    rw [lt_div_iff₀ hdr]; nlinarith
  rw [hcard, abs_le]
  constructor <;> linarith

/-! ## 2. Möbius expansion of the cell indicator -/

/-- **Inclusion–exclusion for the cell indicator.**  Membership in the cell `S` is an
alternating sum of divisibility conditions by the squarefree numbers `∏_{p ∈ S ∪ T} p`. -/
theorem cell_indicator_inclusion_exclusion (hB : ∀ p ∈ B, Nat.Prime p) (hS : S ⊆ B) (v : ℕ) :
    (if cell B v = S then (1 : ℝ) else 0)
      = ∑ T ∈ (B \ S).powerset,
          (-1 : ℝ) ^ T.card * (if (∏ p ∈ S ∪ T, p) ∣ v then 1 else 0) := by
  classical
  by_cases hSdvd : ∀ p ∈ S, p ∣ v
  · -- the forced part divides `v`; the sum collapses to the subsets of the "extra" primes
    set U : Finset ℕ := (B \ S).filter (fun p => p ∣ v) with hU
    have hUsub : U ⊆ B \ S := Finset.filter_subset _ _
    have hdvdiff : ∀ T ∈ (B \ S).powerset, ((∏ p ∈ S ∪ T, p) ∣ v ↔ T ⊆ U) := by
      intro T hT
      rw [Finset.mem_powerset] at hT
      constructor
      · intro hdvd p hp
        rw [hU, Finset.mem_filter]
        exact ⟨hT hp, dvd_trans (Finset.dvd_prod_of_mem _ (Finset.mem_union_right S hp)) hdvd⟩
      · intro hTU
        refine Finset.prod_primes_dvd v ?_ ?_
        · intro p hp
          rcases Finset.mem_union.1 hp with h | h
          · exact (hB p (hS h)).prime
          · exact (hB p ((Finset.mem_sdiff.1 (hT h)).1)).prime
        · intro p hp
          rcases Finset.mem_union.1 hp with h | h
          · exact hSdvd p h
          · exact (Finset.mem_filter.1 (hTU h)).2
    have hsum : ∑ T ∈ (B \ S).powerset,
          (-1 : ℝ) ^ T.card * (if (∏ p ∈ S ∪ T, p) ∣ v then 1 else 0)
        = ∑ T ∈ (B \ S).powerset.filter (fun T => T ⊆ U), (-1 : ℝ) ^ T.card := by
      rw [Finset.sum_filter]
      refine Finset.sum_congr rfl (fun T hT => ?_)
      by_cases h : T ⊆ U
      · rw [if_pos ((hdvdiff T hT).2 h), if_pos h, mul_one]
      · rw [if_neg (fun hc => h ((hdvdiff T hT).1 hc)), if_neg h, mul_zero]
    have hfilter : (B \ S).powerset.filter (fun T => T ⊆ U) = U.powerset := by
      ext T
      simp only [Finset.mem_filter, Finset.mem_powerset]
      exact ⟨fun h => h.2, fun h => ⟨h.trans hUsub, h⟩⟩
    rw [hsum, hfilter]
    have halt : ∑ T ∈ U.powerset, (-1 : ℝ) ^ T.card = if U = ∅ then 1 else 0 := by
      have hZ := Finset.sum_powerset_neg_one_pow_card (x := U)
      have hR := congrArg (fun z : ℤ => (z : ℝ)) hZ
      push_cast at hR
      simpa using hR
    rw [halt]
    -- and `cell B v = S ↔ U = ∅`
    have hcell : cell B v = S ↔ U = ∅ := by
      rw [cell_eq_iff hS]
      constructor
      · intro h
        refine Finset.eq_empty_of_forall_notMem (fun p hp => ?_)
        rw [hU, Finset.mem_filter, Finset.mem_sdiff] at hp
        exact hp.1.2 ((h p hp.1.1).1 hp.2)
      · intro h p hp
        constructor
        · intro hdvd
          by_contra hpS
          have : p ∈ U := by
            rw [hU, Finset.mem_filter]
            exact ⟨Finset.mem_sdiff.2 ⟨hp, hpS⟩, hdvd⟩
          rw [h] at this
          exact absurd this (Finset.notMem_empty p)
        · exact hSdvd p
    by_cases h : U = ∅
    · rw [if_pos h, if_pos (hcell.2 h)]
    · rw [if_neg h, if_neg (fun hc => h (hcell.1 hc))]
  · -- some prime of `S` misses `v`: both sides vanish
    push_neg at hSdvd
    obtain ⟨p₀, hp₀S, hp₀⟩ := hSdvd
    have hleft : ¬ cell B v = S := by
      intro h
      rw [cell_eq_iff hS] at h
      exact hp₀ ((h p₀ (hS hp₀S)).2 hp₀S)
    rw [if_neg hleft]
    refine (Finset.sum_eq_zero (fun T _ => ?_)).symm
    have : ¬ ((∏ p ∈ S ∪ T, p) ∣ v) := by
      intro hdvd
      exact hp₀ (dvd_trans (Finset.dvd_prod_of_mem _ (Finset.mem_union_left T hp₀S)) hdvd)
    rw [if_neg this, mul_zero]

/-! ## 3. The window error bound -/

/-- The exact periodic density, expanded by inclusion–exclusion. -/
theorem density_inclusion_exclusion (hB : ∀ p ∈ B, Nat.Prime p) (hS : S ⊆ B) (N : ℕ) :
    (N : ℝ) * (∏ p ∈ S, (1 : ℝ) / p) * ∏ p ∈ B \ S, (1 - (1 : ℝ) / p)
      = ∑ T ∈ (B \ S).powerset,
          (-1 : ℝ) ^ T.card * ((N : ℝ) / ((∏ p ∈ S ∪ T, p : ℕ) : ℝ)) := by
  classical
  have hexp : ∏ p ∈ B \ S, (1 - (1 : ℝ) / p)
      = ∑ T ∈ (B \ S).powerset, (∏ p ∈ T, (-(1 : ℝ) / p)) * ∏ _p ∈ (B \ S) \ T, (1 : ℝ) := by
    rw [← Finset.prod_add]
    exact Finset.prod_congr rfl (fun p _ => by ring)
  rw [hexp, Finset.mul_sum]
  refine Finset.sum_congr rfl (fun T hT => ?_)
  rw [Finset.mem_powerset] at hT
  have hdisj : Disjoint S T :=
    Finset.disjoint_left.2 (fun a haS haT => (Finset.mem_sdiff.1 (hT haT)).2 haS)
  have hprod : ((∏ p ∈ S ∪ T, p : ℕ) : ℝ) = (∏ p ∈ S, (p : ℝ)) * ∏ p ∈ T, (p : ℝ) := by
    rw [Finset.prod_union hdisj]; push_cast; ring
  have hneg : ∏ p ∈ T, (-(1 : ℝ) / p) = (-1 : ℝ) ^ T.card * ∏ p ∈ T, (1 : ℝ) / p := by
    rw [← Finset.prod_const, ← Finset.prod_mul_distrib]
    exact Finset.prod_congr rfl (fun p _ => by ring)
  have hSne : ∀ p ∈ S, (p : ℝ) ≠ 0 := by
    intro p hp
    exact_mod_cast (hB p (hS hp)).pos.ne'
  have hTne : ∀ p ∈ T, (p : ℝ) ≠ 0 := by
    intro p hp
    exact_mod_cast (hB p (Finset.mem_sdiff.1 (hT hp)).1).pos.ne'
  rw [hneg, hprod, Finset.prod_const_one, mul_one]
  rw [Finset.prod_div_distrib, Finset.prod_div_distrib, Finset.prod_const_one,
    Finset.prod_const_one]
  field_simp

/-- **The window error bound.**  For every initial window `[0, N)` the cell counts differ from
the exact periodic prediction by at most `2^{|B∖S|}`, uniformly in `N`. -/
theorem abs_card_cellFiber_window_sub_le (hB : ∀ p ∈ B, Nat.Prime p) (hS : S ⊆ B) (N : ℕ) :
    |((((range N).filter (fun v => cell B v = S)).card : ℝ))
        - (N : ℝ) * (∏ p ∈ S, (1 : ℝ) / p) * ∏ p ∈ B \ S, (1 - (1 : ℝ) / p)|
      ≤ 2 ^ (B \ S).card := by
  classical
  -- expand the count by inclusion–exclusion
  have hcount : ((((range N).filter (fun v => cell B v = S)).card : ℝ))
      = ∑ T ∈ (B \ S).powerset, (-1 : ℝ) ^ T.card
          * ((((range N).filter (fun v => (∏ p ∈ S ∪ T, p) ∣ v)).card : ℝ)) := by
    rw [Finset.card_filter]
    push_cast
    rw [Finset.sum_congr rfl (fun v _ => cell_indicator_inclusion_exclusion hB hS v)]
    rw [Finset.sum_comm]
    refine Finset.sum_congr rfl (fun T _ => ?_)
    rw [Finset.card_filter]
    push_cast
    rw [Finset.mul_sum]
  rw [hcount, density_inclusion_exclusion hB hS N, ← Finset.sum_sub_distrib]
  have hbound : ∀ T ∈ (B \ S).powerset,
      |(-1 : ℝ) ^ T.card * ((((range N).filter (fun v => (∏ p ∈ S ∪ T, p) ∣ v)).card : ℝ))
        - (-1 : ℝ) ^ T.card * ((N : ℝ) / ((∏ p ∈ S ∪ T, p : ℕ) : ℝ))| ≤ 1 := by
    intro T hT
    rw [Finset.mem_powerset] at hT
    have hdpos : 0 < ∏ p ∈ S ∪ T, p := by
      refine Finset.prod_pos (fun p hp => ?_)
      rcases Finset.mem_union.1 hp with h | h
      · exact (hB p (hS h)).pos
      · exact (hB p (Finset.mem_sdiff.1 (hT h)).1).pos
    rw [← mul_sub, abs_mul, abs_pow, abs_neg, abs_one, one_pow, one_mul]
    exact abs_card_multiples_sub_div_le hdpos N
  calc |∑ T ∈ (B \ S).powerset, ((-1 : ℝ) ^ T.card
          * ((((range N).filter (fun v => (∏ p ∈ S ∪ T, p) ∣ v)).card : ℝ))
          - (-1 : ℝ) ^ T.card * ((N : ℝ) / ((∏ p ∈ S ∪ T, p : ℕ) : ℝ)))|
      ≤ ∑ T ∈ (B \ S).powerset, |(-1 : ℝ) ^ T.card
          * ((((range N).filter (fun v => (∏ p ∈ S ∪ T, p) ∣ v)).card : ℝ))
          - (-1 : ℝ) ^ T.card * ((N : ℝ) / ((∏ p ∈ S ∪ T, p : ℕ) : ℝ))| :=
        Finset.abs_sum_le_sum_abs _ _
    _ ≤ ∑ _T ∈ (B \ S).powerset, (1 : ℝ) := Finset.sum_le_sum hbound
    _ = 2 ^ (B \ S).card := by
        rw [Finset.sum_const, Finset.card_powerset, nsmul_eq_mul, mul_one]
        push_cast
        ring

/-- **Empirical cell frequencies converge to the exact periodic densities.**  The rate is
`2^{|B∖S|}/N` with the explicit constant of `abs_card_cellFiber_window_sub_le`. -/
theorem cell_frequency_tendsto (hB : ∀ p ∈ B, Nat.Prime p) (hS : S ⊆ B) :
    Filter.Tendsto
      (fun N : ℕ => ((((range N).filter (fun v => cell B v = S)).card : ℝ)) / (N : ℝ))
      Filter.atTop
      (nhds ((∏ p ∈ S, (1 : ℝ) / p) * ∏ p ∈ B \ S, (1 - (1 : ℝ) / p))) := by
  classical
  set L : ℝ := (∏ p ∈ S, (1 : ℝ) / p) * ∏ p ∈ B \ S, (1 - (1 : ℝ) / p) with hL
  set C : ℝ := 2 ^ (B \ S).card with hC
  have hCpos : 0 < C := by rw [hC]; positivity
  refine Metric.tendsto_atTop.2 (fun ε hε => ?_)
  obtain ⟨N₀, hN₀⟩ := exists_nat_gt (C / ε)
  refine ⟨max N₀ 1, fun N hN => ?_⟩
  have hN1 : 1 ≤ N := le_trans (le_max_right N₀ 1) hN
  have hNpos : (0 : ℝ) < N := by exact_mod_cast hN1
  have hNge : (C / ε) < (N : ℝ) := lt_of_lt_of_le hN₀ (by exact_mod_cast le_trans (le_max_left N₀ 1) hN)
  have hkey := abs_card_cellFiber_window_sub_le hB hS N
  have hrw : ((((range N).filter (fun v => cell B v = S)).card : ℝ)) / (N : ℝ) - L
      = (((((range N).filter (fun v => cell B v = S)).card : ℝ)) - (N : ℝ) * L) / (N : ℝ) := by
    field_simp
  rw [Real.dist_eq, hrw, abs_div, abs_of_pos hNpos, div_lt_iff₀ hNpos]
  have hkey' : |((((range N).filter (fun v => cell B v = S)).card : ℝ)) - (N : ℝ) * L| ≤ C := by
    rw [hL, ← mul_assoc]
    exact hkey
  have hCN : C < ε * N := by
    rw [div_lt_iff₀ hε] at hNge
    linarith [hNge]
  linarith [hkey', hCN]

end Catalog.Novelty.KappaWindowError