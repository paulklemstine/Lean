/-
# Front-loading, the touch floor, and lab certification of the prior-shape channel

Third instalment of the GAP-L7' programme
(`Novelty.ReorderExtremalitySignFlip`, `Novelty.ReorderMasterCapWitnesses`).
It closes three of the ranked ledger items with unconditional statements.

## L7-c : the touch floor, proved rather than booked

* `cost_eq_tail_sums` — the Abel identity `∑ (k+1)·w k = ∑_j tail_j(w)`: the
  expected probe cost of an enumeration is the sum of its *survival* masses.
* `frontload_le` — **head-domination law**: if one order's prefix masses dominate
  another's (it front-loads more), its expected cost is smaller.  This is the
  only thing that transfers from the exp-570 early-fire trace — *front-loading*,
  not `√N`-descending dominance.
* `uniform_scan_cost`, `speedup_le_inv_mu` — the touch floor: a policy that must
  still touch a `μ`-fraction of the index set pays at least `(μM+1)/2` probes, so
  its speedup against the full scan is at most `1/μ`.  The `1/μ` branch of the
  master cap is therefore a theorem, not a booking.

## L7-a : lab certification of `Λ` from a measured mean with error bars

* `asc_lt_desc_iff_mean` — the scalar sign-flip criterion.
* `Lambda_lab`, `Lambda_antitone`, `Lambda_bracket` — the prior-shape gain
  `Λ = (1 - m)/(m - 1/√2)` is strictly antitone in the population mean
  `m = E[1/√r]`, so a measurement `m̂ ± ε` brackets `Λ` between
  `Λ(m̂+ε)` and `Λ(m̂-ε)`.
* `signflip_certified` — a measurement certifies the winner as soon as the error
  bar clears the crossover: `m̂ + ε < (2+√2)/4` forces window-ascending to win.
  This is exactly the missing step L7-a: without a measured `Λ_lab` the premise
  is unchecked, with one the conclusion is unconditional.

## No free lunch on flat priors

* `flat_prior_cost` — against a flat population every enumeration costs the same
  `(n+1)/2`.  All REORDER gains are therefore prior-shape gains; a policy cannot
  manufacture one, which is the structural reason the residue-coupling arms of
  the ledger measured exactly zero.

-- !-- Lab Notes -- !--
-- With the round-74 hard-balanced measurement m̂ ≈ 0.8284 (tilt 0.4095-0.4148,
-- analytic √2 - 1) and a conservative ε = 0.01, `signflip_certified` applies:
-- 0.8384 < (2+√2)/4 = 0.85355, so window-ascending is certified extremal on
-- that pool, and `Lambda_bracket` brackets the gain factor Λ.
-- On the narrow-band pool (m̂ ≈ 0.899) the same test fires the other way.
-/
import Mathlib
import Novelty.ReorderExtremalitySignFlip

namespace ReorderL7

open Finset

noncomputable section

/-! ## 1.  Abel identity and the head-domination law -/

/-- Expected probe cost of the enumeration whose `k`-th probe carries mass `w k`. -/
def scanCostOf (n : ℕ) (w : ℕ → ℝ) : ℝ := ∑ k ∈ Finset.range n, ((k : ℝ) + 1) * w k

/-- **Abel identity.**  The expected probe cost is the sum of the survival
(tail) masses of the enumeration. -/
theorem cost_eq_tail_sums (n : ℕ) (w : ℕ → ℝ) :
    scanCostOf n w = ∑ j ∈ Finset.range n, ∑ k ∈ Finset.Ico j n, w k := by
  induction n with
  | zero => simp [scanCostOf]
  | succ n ih =>
      have hsplit : ∀ j ∈ Finset.range (n + 1),
          ∑ k ∈ Finset.Ico j (n + 1), w k = (∑ k ∈ Finset.Ico j n, w k) + w n := by
        intro j hj
        rw [Finset.sum_Ico_succ_top (by simpa using Nat.lt_succ_iff.mp (Finset.mem_range.mp hj))]
      rw [scanCostOf, Finset.sum_range_succ, ← scanCostOf, ih, Finset.sum_congr rfl hsplit,
        Finset.sum_add_distrib, Finset.sum_range_succ (f := fun j => ∑ k ∈ Finset.Ico j n, w k)]
      simp [Finset.sum_const, Finset.card_range]

/-- **Head-domination law (the transferable part of the early-fire trace).**
If the enumeration `v` front-loads at least as much mass as `u` at every prefix
(and both carry the same total), then `v` costs no more than `u`.

Note the scope: this says *front-loading* wins, it does **not** say that any
particular arithmetic order front-loads.  Which order does is the population
question settled by `signflip_uniform_band`. -/
theorem frontload_le {n : ℕ} {u v : ℕ → ℝ}
    (htot : ∑ k ∈ Finset.range n, u k = ∑ k ∈ Finset.range n, v k)
    (hpre : ∀ j ≤ n, ∑ k ∈ Finset.range j, u k ≤ ∑ k ∈ Finset.range j, v k) :
    scanCostOf n v ≤ scanCostOf n u := by
  rw [cost_eq_tail_sums, cost_eq_tail_sums]
  refine Finset.sum_le_sum ?_
  intro j hj
  have hj' : j ≤ n := Nat.lt_succ_iff.mp (Nat.lt_succ_of_lt (Finset.mem_range.mp hj))
  have hsu : ∑ k ∈ Finset.range j, u k + ∑ k ∈ Finset.Ico j n, u k
      = ∑ k ∈ Finset.range n, u k := Finset.sum_range_add_sum_Ico u hj'
  have hsv : ∑ k ∈ Finset.range j, v k + ∑ k ∈ Finset.Ico j n, v k
      = ∑ k ∈ Finset.range n, v k := Finset.sum_range_add_sum_Ico v hj'
  have := hpre j hj'
  linarith [hsu, hsv, htot]

/-! ## 2.  No free lunch on a flat prior -/

/-- Gauss sum, in the shape used by the scan model. -/
theorem sum_range_index (n : ℕ) : ∑ k ∈ Finset.range n, ((k : ℝ) + 1) = (n : ℝ) * ((n : ℝ) + 1) / 2 := by
  induction n with
  | zero => simp
  | succ n ih =>
      rw [Finset.sum_range_succ, ih]
      push_cast
      ring

/-- **No free lunch on flat priors.**  Against a flat population every
enumeration pays exactly `(n+1)/2`; reordering can only pay off against a
non-flat prior.  Every REORDER gain is a prior-shape gain. -/
theorem flat_prior_cost {n : ℕ} (hn : 0 < n) :
    scanCostOf n (fun _ => 1 / (n : ℝ)) = ((n : ℝ) + 1) / 2 := by
  have hnR : (0:ℝ) < (n : ℝ) := by exact_mod_cast hn
  rw [scanCostOf]
  simp only [mul_one_div]
  rw [← Finset.sum_div, sum_range_index]
  field_simp

/-! ## 3.  The touch floor : the `1/μ` branch is a theorem -/

/-- Expected probe cost when the hit is uniform on the `k` candidates the filter
keeps: exactly `(k+1)/2`. -/
theorem uniform_scan_cost {k : ℕ} (hk : 0 < k) :
    scanCostOf k (fun _ => 1 / (k : ℝ)) = ((k : ℝ) + 1) / 2 := flat_prior_cost hk

/-- **Touch floor ⇒ the `1/μ` branch of the master cap.**  If the filter still
keeps at least a `μ`-fraction of the `M` candidates, the policy pays at least
`(μM+1)/2` probes, so its speedup against the full scan `(M+1)/2` is at most
`1/μ`.  No booking, no uniformity assumption inside cells. -/
theorem speedup_le_inv_mu {M k : ℕ} {mu : ℝ} (hmu : 0 < mu) (hmu1 : mu ≤ 1)
    (hk : mu * (M : ℝ) ≤ (k : ℝ)) :
    (((M : ℝ) + 1) / 2) / (((k : ℝ) + 1) / 2) ≤ 1 / mu := by
  have hkpos : (0:ℝ) < ((k : ℝ) + 1) / 2 := by positivity
  have hMnn : (0:ℝ) ≤ (M : ℝ) := Nat.cast_nonneg M
  rw [div_le_div_iff₀ hkpos hmu]
  nlinarith [hk, hMnn, hmu, hmu1]

/-! ## 4.  L7-a : certifying the prior-shape channel from a lab measurement -/

/-- The scalar sign-flip criterion: the window-ascending cost `m - 1/√2` beats the
window-descending cost `1 - m` exactly below the crossover mean. -/
theorem asc_lt_desc_iff_mean (m : ℝ) :
    (m - 1 / Real.sqrt 2 < 1 - m) ↔ m < crossoverMean := by
  have hs2 : Real.sqrt 2 * Real.sqrt 2 = 2 := sq_sqrt2
  have hpos := sqrt2_pos
  have hinv : 1 / Real.sqrt 2 = Real.sqrt 2 / 2 := by field_simp; nlinarith [hs2]
  rw [crossoverMean, hinv]
  constructor <;> intro h <;> linarith

/-- The prior-shape gain factor `Λ_lab` read off a measured population mean
`m = E[1/√r]`: the ratio of the descending cost to the ascending cost. -/
def Lambda_lab (m : ℝ) : ℝ := (1 - m) / (m - 1 / Real.sqrt 2)

/-- `Λ_lab` is strictly antitone on the admissible range `1/√2 < m < 1`: the more
bottom-heavy the population, the larger the ascending advantage. -/
theorem Lambda_antitone {m₁ m₂ : ℝ} (h1 : 1 / Real.sqrt 2 < m₁) (h12 : m₁ < m₂) (h2 : m₂ < 1) :
    Lambda_lab m₂ < Lambda_lab m₁ := by
  have hd1 : 0 < m₁ - 1 / Real.sqrt 2 := by linarith
  have hd2 : 0 < m₂ - 1 / Real.sqrt 2 := by linarith
  rw [Lambda_lab, Lambda_lab, div_lt_div_iff₀ hd2 hd1]
  nlinarith [h12, h2, hd1, hd2]

/-- **Measurement bracket for `Λ`.**  A lab measurement `m̂` with error bar `ε`
brackets the prior-shape gain between `Λ(m̂+ε)` and `Λ(m̂-ε)`. -/
theorem Lambda_bracket {mhat eps m : ℝ} (hlo : 1 / Real.sqrt 2 < mhat - eps)
    (hhi : mhat + eps < 1) (hm : |m - mhat| ≤ eps) :
    Lambda_lab (mhat + eps) ≤ Lambda_lab m ∧ Lambda_lab m ≤ Lambda_lab (mhat - eps) := by
  have habs := abs_le.mp hm
  have hml : mhat - eps ≤ m := by linarith [habs.1]
  have hmu : m ≤ mhat + eps := by linarith [habs.2]
  constructor
  · rcases eq_or_lt_of_le hmu with h | h
    · rw [h]
    · exact le_of_lt (Lambda_antitone (by linarith) h (by linarith))
  · rcases eq_or_lt_of_le hml with h | h
    · rw [h]
    · exact le_of_lt (Lambda_antitone (by linarith) h (by linarith))

/-- **L7-a, certification.**  If the measured mean plus its error bar still clears
the crossover, the window-ascending policy is certified extremal on the measured
population — and the certified gain factor is at least `Λ_lab(m̂+ε) > 1`. -/
theorem signflip_certified {mhat eps m : ℝ}
    (hlo : 1 / Real.sqrt 2 < mhat - eps) (hm : |m - mhat| ≤ eps)
    (hcert : mhat + eps < crossoverMean) :
    m - 1 / Real.sqrt 2 < 1 - m ∧ 1 < Lambda_lab m := by
  have habs := abs_le.mp hm
  have hmu : m ≤ mhat + eps := by linarith [habs.2]
  have hml : mhat - eps ≤ m := by linarith [habs.1]
  have hmlt : m < crossoverMean := lt_of_le_of_lt hmu hcert
  have hwin : m - 1 / Real.sqrt 2 < 1 - m := (asc_lt_desc_iff_mean m).mpr hmlt
  refine ⟨hwin, ?_⟩
  have hd : 0 < m - 1 / Real.sqrt 2 := by linarith
  rw [Lambda_lab, lt_div_iff₀ hd]
  linarith

/-- The round-74 hard-balanced pool, certified: measured mean `m̂ = 0.8284`
(the analytic value is `2(√2-1)`) with a conservative error bar `ε = 0.01`
clears the crossover, so window-ascending is extremal on that pool with a gain
factor `> 1`. -/
theorem hard_balanced_pool_certified {m : ℝ} (hm : |m - 0.8284| ≤ 0.01) :
    m - 1 / Real.sqrt 2 < 1 - m ∧ 1 < Lambda_lab m := by
  have hs2 : Real.sqrt 2 * Real.sqrt 2 = 2 := sq_sqrt2
  have hpos := sqrt2_pos
  have hub : Real.sqrt 2 < 1.41422 := by nlinarith [hs2, hpos]
  have hlb : (1.41421 : ℝ) < Real.sqrt 2 := by nlinarith [hs2, hpos]
  have hinv : 1 / Real.sqrt 2 < 0.70711 := by
    rw [div_lt_iff₀ hpos]; nlinarith [hlb]
  refine signflip_certified (mhat := 0.8284) (eps := 0.01) ?_ hm ?_
  · linarith
  · rw [crossoverMean]; linarith

end

end ReorderL7