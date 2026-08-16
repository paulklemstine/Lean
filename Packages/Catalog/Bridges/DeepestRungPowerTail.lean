/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Bridges.DeepestRungTailCeiling

/-!
# The general power tail: closing Conjecture 1 (cycle 5)

Cycle 4 (`DeepestRungTailCeiling.lean`) proved a knee **ceiling** under an *inverse-square*
tail `p(σ i) ≤ c/(i+1)²`, where the tail sum telescopes exactly as `1/(j(j+1))`.
`FUTURE_DIRECTIONS.md` listed the general exponent as Conjecture 1, noting that the
difficulty there is analytic rather than combinatorial: no exact telescoping is available
for a real exponent `α > 1`.

This file closes that conjecture.  The analytic core is a *tangent-line* (Bernoulli)
estimate: for `x ≥ 1` and `α > 1`,

`(α − 1) · (x+1)^(−α) ≤ x^(1−α) − (x+1)^(1−α)`,

which is the discrete form of `∫ x^(−α) dx = x^(1−α)/(1−α)` and follows from Bernoulli's
inequality `1 + αs ≤ (1+s)^α` at `s = 1/x`.  Summing it telescopes, giving

`∑_{j = k}^{n−1} (j+1)^(−α) ≤ k^(1−α)/(α−1)`,

and hence `bestMass a k ≥ 1 − (c/(α−1))·k^(1−α)`, i.e. the knee ceiling
`k* ≤ (c/((α−1)(1−τ)))^(1/(α−1))`.

Along the way the cycle-4 mass bound is generalised to an arbitrary tail majorant
(`bestMass_ge_of_tail_bound`), which isolates the combinatorial half (a bijective
re-indexing along the ranking `σ`) from the analytic half.

## Main results

* `rpow_tail_step` — the Bernoulli/tangent-line step inequality
* `tail_sum_rpow_le` — `∑_{j≥k} (j+1)^(−α) ≤ k^(1−α)/(α−1)`
* `bestMass_ge_of_tail_bound` — combinatorial half, for an arbitrary majorant
* `bestMass_ge_of_power_tail` — `bestMass a k ≥ 1 − (c/(α−1))·k^(1−α)`
* `power_tail_ceiling`, `power_tail_knee_bound` — the knee ceiling for general `α > 1`
* `net43_power_tail_ceiling_at_256` — a heavy-tail (`α = 3/2`) instance at the NET-43 cell
-/

namespace Bridges.DeepestRungTwoSeed256

open Finset

/-! ## 1. The analytic core -/

/-- **Tangent-line (Bernoulli) step.**  For `x ≥ 1` and `α > 1`,
`(α − 1)·(x+1)^(−α) ≤ x^(1−α) − (x+1)^(1−α)`.  This is the discrete substitute for the
integral comparison `∫_x^{x+1} t^(−α) dt ≥ (x+1)^(−α)`; unlike the case `α = 2` it does not
telescope exactly, and the convexity of `t ↦ t^(1−α)` is what supplies the slack. -/
theorem rpow_tail_step {α x : ℝ} (hα : 1 < α) (hx : 1 ≤ x) :
    (α - 1) * (x + 1) ^ (-α) ≤ x ^ (1 - α) - (x + 1) ^ (1 - α) := by
  have hx0 : (0:ℝ) < x := lt_of_lt_of_le zero_lt_one hx
  have hx1 : (0:ℝ) < x + 1 := by linarith
  set A : ℝ := x ^ α with hA
  set B : ℝ := (x + 1) ^ α with hB
  have hApos : 0 < A := Real.rpow_pos_of_pos hx0 α
  have hBpos : 0 < B := Real.rpow_pos_of_pos hx1 α
  -- Bernoulli at `s = 1/x`
  have hs : (-1 : ℝ) ≤ 1 / x := by
    have : (0:ℝ) ≤ 1 / x := by positivity
    linarith
  have hbern : 1 + α * (1 / x) ≤ (1 + 1 / x) ^ α :=
    one_add_mul_self_le_rpow_one_add hs hα.le
  have hrw : (1 + 1 / x) ^ α = B / A := by
    have h1 : 1 + 1 / x = (x + 1) / x := by field_simp
    rw [h1, Real.div_rpow hx1.le hx0.le]
  rw [hrw] at hbern
  -- clear denominators: `(α + x)·A ≤ x·B`
  have hkey : (α + x) * A ≤ x * B := by
    have h2 : (1 + α * (1 / x)) * A ≤ (B / A) * A :=
      mul_le_mul_of_nonneg_right hbern hApos.le
    rw [div_mul_cancel₀ _ (ne_of_gt hApos)] at h2
    have h3 : (1 + α * (1 / x)) * A * x ≤ B * x := mul_le_mul_of_nonneg_right h2 hx0.le
    have h4 : (1 + α * (1 / x)) * A * x = (x + α) * A := by
      field_simp
    rw [h4] at h3
    nlinarith [h3]
  -- rewrite the rpow's as quotients
  have e1 : x ^ (1 - α) = x / A := by
    rw [Real.rpow_sub hx0, Real.rpow_one, hA]
  have e2 : (x + 1) ^ (1 - α) = (x + 1) / B := by
    rw [Real.rpow_sub hx1, Real.rpow_one, hB]
  have e3 : (x + 1) ^ (-α) = 1 / B := by
    rw [Real.rpow_neg hx1.le, hB, one_div]
  rw [e1, e2, e3]
  have hdiff : x / A - (x + 1) / B - (α - 1) * (1 / B)
      = (x * B - (x + 1) * A - (α - 1) * A) / (A * B) := by
    field_simp
  have hnum : 0 ≤ x * B - (x + 1) * A - (α - 1) * A := by nlinarith [hkey]
  have : 0 ≤ x / A - (x + 1) / B - (α - 1) * (1 / B) := by
    rw [hdiff]
    exact div_nonneg hnum (by positivity)
  linarith

/-- **General power-tail sum bound.**  `∑_{j=k}^{n-1} (j+1)^(−α) ≤ k^(1−α)/(α−1)` for
`k ≥ 1` and `α > 1`.  For `α = 2` this recovers `tail_sum_inv_sq_le`. -/
theorem tail_sum_rpow_le {α : ℝ} (hα : 1 < α) (k n : ℕ) (hk : 1 ≤ k) :
    ∑ j ∈ Finset.Ico k n, ((j : ℝ) + 1) ^ (-α) ≤ (k : ℝ) ^ (1 - α) / (α - 1) := by
  have hα1 : (0:ℝ) < α - 1 := by linarith
  have hkR : (1:ℝ) ≤ (k : ℝ) := by exact_mod_cast hk
  have hk0 : (0:ℝ) < (k : ℝ) := lt_of_lt_of_le zero_lt_one hkR
  rcases (by omega : n ≤ k ∨ k < n) with h | h
  · rw [Finset.Ico_eq_empty (by omega)]
    have : (0:ℝ) < (k : ℝ) ^ (1 - α) := Real.rpow_pos_of_pos hk0 _
    positivity
  · have key : ∀ m, k ≤ m →
        (α - 1) * ∑ j ∈ Finset.Ico k m, ((j : ℝ) + 1) ^ (-α)
          ≤ (k : ℝ) ^ (1 - α) - (m : ℝ) ^ (1 - α) := by
      intro m hm
      induction m, hm using Nat.le_induction with
      | base => simp
      | succ m hm ih =>
          rw [Finset.sum_Ico_succ_top hm]
          have hmR : (1:ℝ) ≤ (m : ℝ) := by exact_mod_cast le_trans hk hm
          have hstep := rpow_tail_step (α := α) (x := (m : ℝ)) hα hmR
          have hcast : (((m + 1 : ℕ) : ℝ)) = (m : ℝ) + 1 := by push_cast; ring
          rw [hcast]
          have hexp : (α - 1) * (∑ j ∈ Finset.Ico k m, ((j : ℝ) + 1) ^ (-α)
                + ((m : ℝ) + 1) ^ (-α))
              = (α - 1) * ∑ j ∈ Finset.Ico k m, ((j : ℝ) + 1) ^ (-α)
                + (α - 1) * ((m : ℝ) + 1) ^ (-α) := by ring
          rw [hexp]
          linarith
    have hn : (0:ℝ) < (n : ℝ) := by exact_mod_cast lt_of_lt_of_le hk h.le
    have hpos : (0:ℝ) < (n : ℝ) ^ (1 - α) := Real.rpow_pos_of_pos hn _
    have hkey := key n h.le
    rw [le_div_iff₀ hα1]
    nlinarith [hkey, hpos]

/-! ## 2. The combinatorial half, for an arbitrary majorant -/

/-- **Mass captured by the top of a ranking.**  If the keys ranked at positions `≥ k` carry
total weight at most `B` (majorised term by term by `g`), then the top-`k` selection captures
mass at least `1 − B`.  This isolates the re-indexing argument of cycle 4 from the particular
inverse-square estimate. -/
theorem bestMass_ge_of_tail_bound {n : ℕ} (a : AttnDist n) (σ : Equiv.Perm (Fin n))
    (g : ℕ → ℝ) (hdecay : ∀ i : Fin n, a.p (σ i) ≤ g i) {k : ℕ} {B : ℝ}
    (hB : ∑ j ∈ Finset.Ico k n, g j ≤ B) : 1 - B ≤ bestMass a k := by
  classical
  set S : Finset (Fin n) := Finset.univ.filter (fun x : Fin n => ((σ.symm x : Fin n) : ℕ) < k)
    with hS
  have hcard : S.card ≤ k := by
    have hinj : Set.InjOn (fun x : Fin n => ((σ.symm x : Fin n) : ℕ)) S := by
      intro x _ y _ hxy
      have : σ.symm x = σ.symm y := Fin.ext hxy
      simpa using congrArg σ this
    have hmaps : Set.MapsTo (fun x : Fin n => ((σ.symm x : Fin n) : ℕ)) ↑S ↑(Finset.range k) := by
      intro x hx
      have hx' : x ∈ S := hx
      simp only [hS, Finset.mem_filter] at hx'
      simpa using hx'.2
    have := Finset.card_le_card_of_injOn _ hmaps hinj
    simpa using this
  have hsplit : ∑ x ∈ S, a.p x + ∑ x ∈ Finset.univ.filter
      (fun x : Fin n => ¬ ((σ.symm x : Fin n) : ℕ) < k), a.p x = 1 := by
    rw [Finset.sum_filter_add_sum_filter_not]
    exact a.sum_one
  have hreindex : ∑ x ∈ Finset.univ.filter (fun x : Fin n => ¬ ((σ.symm x : Fin n) : ℕ) < k),
      a.p x = ∑ j ∈ Finset.univ.filter (fun j : Fin n => ¬ ((j : ℕ) < k)), a.p (σ j) := by
    refine (Finset.sum_equiv σ ?_ ?_).symm
    · intro j
      simp
    · intro j _
      rfl
  have htail : ∑ j ∈ Finset.univ.filter (fun j : Fin n => ¬ ((j : ℕ) < k)), a.p (σ j) ≤ B := by
    have hbound : ∑ j ∈ Finset.univ.filter (fun j : Fin n => ¬ ((j : ℕ) < k)), a.p (σ j)
        ≤ ∑ j ∈ Finset.univ.filter (fun j : Fin n => ¬ ((j : ℕ) < k)), g (j : ℕ) :=
      Finset.sum_le_sum (fun j _ => hdecay j)
    have hset : (Finset.range n).filter (fun j : ℕ => ¬ (j < k)) = Finset.Ico k n := by
      ext j
      simp only [Finset.mem_filter, Finset.mem_range, Finset.mem_Ico, not_lt]
      omega
    have hcast : ∑ j ∈ Finset.univ.filter (fun j : Fin n => ¬ ((j : ℕ) < k)), g (j : ℕ)
        = ∑ j ∈ Finset.Ico k n, g j := by
      rw [Finset.sum_filter,
        Fin.sum_univ_eq_sum_range (fun j : ℕ => if ¬ (j < k) then g j else 0) n,
        ← Finset.sum_filter, hset]
    exact le_trans hbound (le_trans (le_of_eq hcast) hB)
  have hmass : 1 - B ≤ ∑ x ∈ S, a.p x := by
    rw [hreindex] at hsplit
    linarith
  exact le_trans hmass (mass_le_bestMass a hcard)

/-! ## 3. Conjecture 1, closed -/

/-- **General power-tail mass bound (Conjecture 1).**  If some ranking of the keys satisfies
`p(σ i) ≤ c·(i+1)^(−α)` with `α > 1`, then the top-`k` selection captures mass at least
`1 − (c/(α−1))·k^(1−α)`. -/
theorem bestMass_ge_of_power_tail {n : ℕ} (a : AttnDist n) {c α : ℝ} (hc : 0 ≤ c)
    (hα : 1 < α) (σ : Equiv.Perm (Fin n))
    (hdecay : ∀ i : Fin n, a.p (σ i) ≤ c * ((((i : ℕ) : ℝ)) + 1) ^ (-α))
    {k : ℕ} (hk : 1 ≤ k) :
    1 - c / (α - 1) * (k : ℝ) ^ (1 - α) ≤ bestMass a k := by
  refine bestMass_ge_of_tail_bound a σ (fun j => c * (((j : ℕ) : ℝ) + 1) ^ (-α)) hdecay ?_
  have hsum : ∑ j ∈ Finset.Ico k n, c * (((j : ℕ) : ℝ) + 1) ^ (-α)
      = c * ∑ j ∈ Finset.Ico k n, (((j : ℕ) : ℝ) + 1) ^ (-α) := by
    rw [Finset.mul_sum]
  rw [hsum]
  have := mul_le_mul_of_nonneg_left (tail_sum_rpow_le hα k n hk) hc
  calc c * ∑ j ∈ Finset.Ico k n, (((j : ℕ) : ℝ) + 1) ^ (-α)
      ≤ c * ((k : ℝ) ^ (1 - α) / (α - 1)) := this
    _ = c / (α - 1) * (k : ℝ) ^ (1 - α) := by ring

/-- **General power-tail knee ceiling.**  Under a power tail with exponent `α > 1` and
constant `c`, any width `k` with `k^(α−1) ≥ c/((α−1)(1−τ))` reaches the mass target `τ`. -/
theorem power_tail_ceiling {n : ℕ} (a : AttnDist n) {c α τ : ℝ} (hc : 0 ≤ c) (hα : 1 < α)
    (hτ : τ < 1) (σ : Equiv.Perm (Fin n))
    (hdecay : ∀ i : Fin n, a.p (σ i) ≤ c * ((((i : ℕ) : ℝ)) + 1) ^ (-α))
    {k : ℕ} (hk : 1 ≤ k) (hbig : c / ((α - 1) * (1 - τ)) ≤ (k : ℝ) ^ (α - 1)) :
    τ ≤ bestMass a k := by
  have hα1 : (0:ℝ) < α - 1 := by linarith
  have hτ1 : (0:ℝ) < 1 - τ := by linarith
  have hkR : (1:ℝ) ≤ (k : ℝ) := by exact_mod_cast hk
  have hk0 : (0:ℝ) < (k : ℝ) := lt_of_lt_of_le zero_lt_one hkR
  have hpow : (k : ℝ) ^ (1 - α) = 1 / (k : ℝ) ^ (α - 1) := by
    rw [show (1 : ℝ) - α = -(α - 1) by ring, Real.rpow_neg hk0.le, one_div]
  have hppos : (0:ℝ) < (k : ℝ) ^ (α - 1) := Real.rpow_pos_of_pos hk0 _
  have hmain := bestMass_ge_of_power_tail a hc hα σ hdecay hk
  have hsmall : c / (α - 1) * (k : ℝ) ^ (1 - α) ≤ 1 - τ := by
    rw [hpow]
    rw [div_le_iff₀ (by positivity : (0:ℝ) < (α - 1) * (1 - τ))] at hbig
    rw [mul_one_div, div_le_iff₀ hppos]
    have : c ≤ (k : ℝ) ^ (α - 1) * ((α - 1) * (1 - τ)) := hbig
    rw [div_le_iff₀ hα1]
    nlinarith [this]
  linarith

/-- **Explicit knee ceiling.**  Under a power tail with exponent `α > 1`, every width at
least `(c/((α−1)(1−τ)))^(1/(α−1))` passes the mass target `τ`; so the knee obeys
`k* ≤ (c/((α−1)(1−τ)))^(1/(α−1))`.  For `α = 2` this is the cycle-4 bound `c/(1−τ)`. -/
theorem power_tail_knee_bound {n : ℕ} (a : AttnDist n) {c α τ : ℝ} (hc : 0 ≤ c) (hα : 1 < α)
    (hτ : τ < 1) (σ : Equiv.Perm (Fin n))
    (hdecay : ∀ i : Fin n, a.p (σ i) ≤ c * ((((i : ℕ) : ℝ)) + 1) ^ (-α))
    {k : ℕ} (hk : 1 ≤ k)
    (hbig : (c / ((α - 1) * (1 - τ))) ^ (1 / (α - 1)) ≤ (k : ℝ)) :
    τ ≤ bestMass a k := by
  have hα1 : (0:ℝ) < α - 1 := by linarith
  have hτ1 : (0:ℝ) < 1 - τ := by linarith
  have hX0 : (0:ℝ) ≤ c / ((α - 1) * (1 - τ)) := by positivity
  refine power_tail_ceiling a hc hα hτ σ hdecay hk ?_
  have h1 : ((c / ((α - 1) * (1 - τ))) ^ (1 / (α - 1))) ^ (α - 1) ≤ (k : ℝ) ^ (α - 1) :=
    Real.rpow_le_rpow (by positivity) hbig hα1.le
  have h2 : ((c / ((α - 1) * (1 - τ))) ^ (1 / (α - 1))) ^ (α - 1)
      = c / ((α - 1) * (1 - τ)) := by
    rw [← Real.rpow_mul hX0, one_div, inv_mul_cancel₀ (ne_of_gt hα1), Real.rpow_one]
  rwa [h2] at h1

/-- **NET-43 instance with a heavy tail.**  Even with the much heavier tail exponent
`α = 3/2` (against the `α = 2` of cycle 4), a tail constant `c = 0.6` at the
`(d = 32, ctx = 512)` cell certifies top-`256` mass at least `0.92` — the measured value is
`0.922`.  Heavier tails therefore still admit a finite knee ceiling; the exponent only
changes the rate. -/
theorem net43_power_tail_ceiling_at_256 (a : AttnDist 512) (σ : Equiv.Perm (Fin 512))
    (hdecay : ∀ i : Fin 512, a.p (σ i) ≤ 0.6 * ((((i : ℕ) : ℝ)) + 1) ^ (-(3/2 : ℝ))) :
    (0.92 : ℝ) ≤ bestMass a 256 := by
  refine power_tail_ceiling a (by norm_num) (by norm_num) (by norm_num) σ hdecay (by norm_num) ?_
  have h16 : ((256 : ℕ) : ℝ) ^ ((3/2 : ℝ) - 1) = 16 := by
    have h1 : ((256 : ℕ) : ℝ) = (16 : ℝ) ^ (2 : ℕ) := by norm_num
    rw [h1, ← Real.rpow_natCast (16 : ℝ) 2, ← Real.rpow_mul (by norm_num)]
    norm_num
  rw [h16]
  norm_num

end Bridges.DeepestRungTwoSeed256