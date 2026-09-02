/-
# How much a sweep grid can resolve: counting, divisors, and the coarsest fine grid

Second cycle on the NET-62 material.  `Catalog/NumberTheory/GridKneeQuantization.lean`
shows that a grid measurement is the grid-rounding of the truth; this file asks the
quantitative follow-up: *how many knees can a given sweep resolve at all, and which
sweeps resolve a prescribed chain of knees?*

## Results

* `GridKnee.card_resolved_arith` — a step-`d` sweep resolves exactly `⌊N/d⌋` of the
  budgets in `(0, N]`: a positive proportion `1/d`.
* `GridKnee.card_resolved_dyad_le` — a doubling sweep resolves at most
  `log₂ N + 1` of them: a vanishing proportion.  `GridKnee.dyad_loses_to_fine_grid`
  makes the comparison explicit at `N = 2 ^ m`, `m ≥ 5` (the NET-62 regime:
  `N = 32` upwards).
* `GridKnee.card_verdicts_dyad_le` — an *information* bound: whatever the true knees
  are, a doubling sweep over `(0, N]` can return at most `clog₂ N + 1` distinct
  verdicts.  A chain of knees longer than that must contain a repeat: apparent
  "flatness" of a coarse chain is forced by counting, before any modelling.
* `GridKnee.arith_resolves_iff_mem_divisors` — the set of arithmetic sweeps that resolve
  a knee `k` is exactly the divisor set of `k`; so the "resolution power" of a knee is
  the divisor-counting function `τ`.  Along the NET-62 chain this is `5, 6, 8` for
  `16, 20, 24` (`GridKnee.chain_resolution_powers`), and τ is **not** monotone in the
  budget, although the chain is.
* `GridKnee.chain_resolved_iff_dvd_four` — the punchline for the experiment design: an
  arithmetic sweep resolves *all* of `16, 20, 24` iff its step divides `4`.  The step-`4`
  fine grid is therefore the **coarsest** arithmetic sweep that can see the whole chain,
  and every coarser arithmetic sweep must misread at least one cell.

-- !-- Lab Notes -- !--
Hypothesizer (cycle 2):
 (H6) Resolution is a divisibility phenomenon: the steps resolving `k` are its divisors.
 (H7) The coarsest sweep resolving a finite chain has step `gcd` of the chain.
 (H8) A doubling sweep has only `O(log N)` possible verdicts, so long knee chains are
      *forced* to look flat under it, independently of the model.
 (H9) Resolution power `τ(k)` is not monotone along a monotone chain — so "we moved to
      a finer grid" is not the same as "the new cells are easier to resolve".

Experimenter: H6–H9 are the four theorem groups above, all proved.

Analyst: H8 is the structurally strongest: it converts the NET-62 verdict from a
statement about one experiment into a counting obstruction on doubling sweeps.  H7
identifies `4 = gcd {16, 20, 24}` as the design-optimal step, which is exactly the grid
NET-62 chose — the choice is retrospectively forced, not lucky.

Critic: the counting theorems are stated for all `N` (not evaluated at a sample), the
divisor theorem quantifies over all `k` and all steps, and `chain_resolved_iff_dvd_four`
is an iff, so neither direction is vacuous.
-/

import Mathlib
import NumberTheory.GridKneeQuantization

namespace GridKnee

open Finset

open scoped Classical in
/-- The budgets in `(0, N]` that a sweep on `G` resolves exactly. -/
noncomputable def resolved (G : Grid) (N : ℕ) : Finset ℕ :=
  (Finset.Ioc 0 N).filter (fun k => k ∈ G.carrier)

theorem mem_resolved {G : Grid} {N k : ℕ} :
    k ∈ resolved G N ↔ (0 < k ∧ k ≤ N) ∧ read G k = k := by
  classical
  simp [resolved, read_eq_self_iff, Finset.mem_filter, Finset.mem_Ioc, and_assoc]

/-! ## 1.  Counting resolvable budgets -/

/-- A step-`d` sweep resolves exactly `⌊N/d⌋` of the budgets in `(0, N]`. -/
theorem card_resolved_arith (d N : ℕ) (hd : 0 < d) :
    (resolved (arithGrid d hd) N).card = N / d := by
  classical
  rw [← Nat.Ioc_filter_dvd_card_eq_div N d]
  congr 1
  apply Finset.filter_congr
  intro x _
  simp [arithGrid]

/-- A doubling sweep resolves at most `log₂ N + 1` of the budgets in `(0, N]` — the
powers of two are all it can see. -/
theorem card_resolved_dyad_le (N : ℕ) :
    (resolved dyadGrid N).card ≤ Nat.log 2 N + 1 := by
  classical
  have hmaps : Set.MapsTo (Nat.log 2) (resolved dyadGrid N : Set ℕ)
      (Finset.range (Nat.log 2 N + 1) : Set ℕ) := by
    intro k hk
    rw [Finset.mem_coe, mem_resolved] at hk
    obtain ⟨⟨hk0, hkN⟩, hres⟩ := hk
    simp only [Finset.coe_range, Set.mem_Iio]
    have := Nat.log_mono_right (b := 2) hkN
    omega
  have hinj : Set.InjOn (Nat.log 2) (resolved dyadGrid N : Set ℕ) := by
    intro k hk k' hk' hlog
    rw [Finset.mem_coe, mem_resolved] at hk hk'
    obtain ⟨e, he⟩ : ∃ e : ℕ, k = 2 ^ e := read_eq_self_iff.1 hk.2
    obtain ⟨e', he'⟩ : ∃ e : ℕ, k' = 2 ^ e := read_eq_self_iff.1 hk'.2
    rw [he, he', Nat.log_pow (by norm_num), Nat.log_pow (by norm_num)] at hlog
    rw [he, he', hlog]
  have := Finset.card_le_card_of_injOn (f := Nat.log 2) hmaps hinj
  simpa using this

/-- **The doubling sweep loses to the fine grid.**  From `N = 32` on, a step-`4` sweep
resolves strictly more budgets than a doubling sweep — and the gap grows exponentially. -/
theorem dyad_loses_to_fine_grid {m : ℕ} (hm : 5 ≤ m) :
    (resolved dyadGrid (2 ^ m)).card < (resolved (arithGrid 4 (by norm_num)) (2 ^ m)).card := by
  have hlin : ∀ j : ℕ, 3 ≤ j → j + 3 < 2 ^ j := by
    intro j hj
    induction j with
    | zero => omega
    | succ n ih =>
      rcases Nat.lt_or_ge n 3 with hn | hn
      · interval_cases n
        · omega
        · omega
        · norm_num
      · have h := ih hn
        have hpos : 0 < 2 ^ n := Nat.two_pow_pos n
        have : (2:ℕ) ^ (n + 1) = 2 * 2 ^ n := by ring
        omega
  obtain ⟨j, rfl⟩ : ∃ j, m = j + 2 := ⟨m - 2, by omega⟩
  have hj : 3 ≤ j := by omega
  have hdyad : (resolved dyadGrid (2 ^ (j + 2))).card ≤ j + 3 := by
    have := card_resolved_dyad_le (2 ^ (j + 2))
    rwa [Nat.log_pow (by norm_num)] at this
  have harith : (resolved (arithGrid 4 (by norm_num)) (2 ^ (j + 2))).card = 2 ^ j := by
    rw [card_resolved_arith]
    have h4 : (2:ℕ) ^ (j + 2) = 2 ^ j * 4 := by ring
    rw [h4]
    omega
  have := hlin j hj
  omega

/-! ## 2.  An information bound on coarse sweeps -/

/-- **Verdict bound.**  Over all true knees in `(0, N]` a doubling sweep can return at
most `clog₂ N + 1` distinct readings.  Any knee chain longer than that must repeat a
value: coarse chains are forced to look flat. -/
theorem card_verdicts_dyad_le (N : ℕ) :
    ((Finset.Ioc 0 N).image (read dyadGrid)).card ≤ Nat.clog 2 N + 1 := by
  classical
  have hsub : (Finset.Ioc 0 N).image (read dyadGrid) ⊆
      (Finset.range (Nat.clog 2 N + 1)).image (fun e => 2 ^ e) := by
    intro y hy
    obtain ⟨k, hk, rfl⟩ := Finset.mem_image.1 hy
    obtain ⟨hk0, hkN⟩ := Finset.mem_Ioc.1 hk
    refine Finset.mem_image.2 ⟨Nat.clog 2 k, Finset.mem_range.2 ?_, ?_⟩
    · have := Nat.clog_mono_right 2 hkN
      omega
    · exact (read_dyadGrid k).symm
  calc ((Finset.Ioc 0 N).image (read dyadGrid)).card
      ≤ ((Finset.range (Nat.clog 2 N + 1)).image (fun e => 2 ^ e)).card :=
        Finset.card_le_card hsub
    _ ≤ (Finset.range (Nat.clog 2 N + 1)).card := Finset.card_image_le
    _ = Nat.clog 2 N + 1 := by simp

/-! ## 3.  Which sweeps resolve a given knee: the divisor set -/

/-- **Resolution is divisibility.**  A step-`d` sweep resolves the knee `k ≠ 0` exactly
when `d` is a divisor of `k`; hence the number of arithmetic sweeps resolving `k` is the
divisor-counting function `τ(k)`. -/
theorem arith_resolves_iff_mem_divisors {k d : ℕ} (hd : 0 < d) (hk : k ≠ 0) :
    read (arithGrid d hd) k = k ↔ d ∈ Nat.divisors k := by
  rw [arith_exact_iff_dvd hd, Nat.mem_divisors]
  exact ⟨fun h => ⟨h, hk⟩, fun h => h.1⟩

/-- The resolution powers of the reported chain: `16, 20, 24` are resolved by `5, 6, 8`
arithmetic sweeps respectively.  Along the chain itself `τ` happens to increase, but it
is not a monotone function of the budget: see `resolution_power_not_monotone` for the
failure at the very next fine-grid cell. -/
theorem chain_resolution_powers :
    (Nat.divisors 16).card = 5 ∧ (Nat.divisors 20).card = 6 ∧ (Nat.divisors 24).card = 8 := by
  refine ⟨by decide, by decide, by decide⟩

/-- Resolution power is genuinely non-monotone: the very next fine-grid cell `28` is
resolved by fewer sweeps than `24`.  A finer grid does not monotonically buy resolution. -/
theorem resolution_power_not_monotone :
    (Nat.divisors 24).card = 8 ∧ (Nat.divisors 28).card = 6 ∧ (24 : ℕ) < 28 := by
  refine ⟨by decide, by decide, by norm_num⟩

/-! ## 4.  The coarsest grid that resolves the whole chain -/

/-- **The gcd design principle.**  An arithmetic sweep resolves every knee of a finite
chain `K` iff its step divides `gcd K`.  Hence the coarsest arithmetic sweep that sees a
whole chain has step exactly `gcd K`, and grid design is an arithmetic optimisation. -/
theorem chain_resolved_iff_dvd_gcd (K : Finset ℕ) {d : ℕ} (hd : 0 < d) :
    (∀ k ∈ K, read (arithGrid d hd) k = k) ↔ d ∣ K.gcd id := by
  simp only [arith_exact_iff_dvd hd]
  exact ⟨fun h => Finset.dvd_gcd fun b hb => h b hb,
    fun h k hk => h.trans (Finset.gcd_dvd hk)⟩

/-- **The step-`4` grid is forced.**  An arithmetic sweep resolves every cell of the
reported chain `{16, 20, 24}` iff its step divides `4`.  So `4` is the coarsest
arithmetic sweep that can see the chain, and any coarser one misreads a cell — a
retrospective justification of the NET-62 grid choice, and an obstruction for the
doubling grid, whose steps `8, 16, 32` do not divide `4`. -/
theorem chain_resolved_iff_dvd_four {d : ℕ} (hd : 0 < d) :
    (read (arithGrid d hd) 16 = 16 ∧ read (arithGrid d hd) 20 = 20 ∧
      read (arithGrid d hd) 24 = 24) ↔ d ∣ 4 := by
  simp only [arith_exact_iff_dvd hd]
  constructor
  · rintro ⟨h16, h20, -⟩
    have : d ∣ 20 - 16 := Nat.dvd_sub h20 h16
    simpa using this
  · intro h4
    refine ⟨h4.trans (by norm_num), h4.trans (by norm_num), h4.trans (by norm_num)⟩

/-- The chain's greatest common divisor is exactly the fine grid step. -/
theorem chain_gcd_eq_four : Nat.gcd 16 (Nat.gcd 20 24) = 4 := by decide

end GridKnee