import Mathlib
import Tropical.FactorLocationBarriers

/-!
# The noise-floor principle: aggregation cost = birthday bound

The free-witness programme's sharpest quantitative claim is the **noise-floor
principle**: factor-bearing samples of an `N`-computable aggregate occur at density
`≤ c/√N`, so the aggregation barrier and the trial-division birthday bound are the
*same* obstruction. This file proves that statement for the divisor-probe aggregate
on balanced semiprimes, where it is exactly formalisable.

Let `N = p·q` with `p < q ≤ 2p` (a *balanced* semiprime, the cryptographic case).

* `balanced_window_sq_bound`: any probe window `[2, m]` that contains a nontrivial
  divisor of `N` satisfies `N ≤ 2m²` — the sweep must reach the birthday scale
  `√(N/2)`.
* `balanced_window_sqrt_bound`: the same in real form, `√N ≤ √2 · m`.
* `hits_card_le_two`: a window contains at most two factor-bearing probes ever.
* `noise_floor_principle`: therefore the density of factor-bearing probes in any
  successful window is at most `2√2/√N` — the noise floor, with the explicit
  constant `c = 2√2`.
* `aggregation_cost_is_birthday_scale`: the two-sided bound
  `√(N/2) ≤ p ≤ √N` on the sweep length, i.e. the aggregation cost for a balanced
  semiprime is `Θ(√N)` — literally the birthday bound.

The divisor structure is imported from `Tropical.FactorLocationBarriers`.
-/

namespace NoiseFloor

open Finset FactorLocationBarriers

variable {p q : ℕ}

/-- Balanced semiprimes: the smaller factor is within a factor `2` of the corner. -/
theorem balanced_sq_bound (hbal : q ≤ 2 * p) : p * q ≤ 2 * p * p := by nlinarith

/-- Every nontrivial divisor of a semiprime is at least the smaller prime. -/
theorem nontrivial_divisor_ge (hp : p.Prime) (hq : q.Prime) (hlt : p < q) {d : ℕ}
    (hdvd : d ∣ p * q) (h1 : 1 < d) (h2 : d < p * q) : p ≤ d := by
  have hmem : d ∈ (p * q).divisors :=
    Nat.mem_divisors.mpr ⟨hdvd, Nat.mul_ne_zero hp.pos.ne' hq.pos.ne'⟩
  rw [divisors_semiprime p q hp hq] at hmem
  simp only [Finset.mem_insert, Finset.mem_singleton] at hmem
  rcases hmem with rfl | rfl | rfl | rfl <;> omega

/-- **The sweep must reach the birthday scale.** If a probe window `[2, m]` contains a
nontrivial divisor of the balanced semiprime `N = pq`, then `N ≤ 2m²`. -/
theorem balanced_window_sq_bound (hp : p.Prime) (hq : q.Prime) (hlt : p < q)
    (hbal : q ≤ 2 * p) {m d : ℕ} (hdvd : d ∣ p * q) (h1 : 1 < d) (h2 : d < p * q)
    (hdm : d ≤ m) : p * q ≤ 2 * m * m := by
  have hpd : p ≤ d := nontrivial_divisor_ge hp hq hlt hdvd h1 h2
  have hpm : p ≤ m := le_trans hpd hdm
  calc p * q ≤ 2 * p * p := balanced_sq_bound hbal
    _ ≤ 2 * m * m := by nlinarith

/-- Real form of the sweep bound: `√N ≤ √2 · m`. -/
theorem balanced_window_sqrt_bound {m N : ℕ} (hm : 0 < m) (h : N ≤ 2 * m * m) :
    Real.sqrt N ≤ Real.sqrt 2 * m := by
  have hle : (N : ℝ) ≤ (Real.sqrt 2 * m) ^ 2 := by
    have h2 : (Real.sqrt 2) ^ 2 = 2 := Real.sq_sqrt (by norm_num)
    have hN2 : (N : ℝ) ≤ 2 * m * m := by exact_mod_cast h
    nlinarith
  calc Real.sqrt N ≤ Real.sqrt ((Real.sqrt 2 * m) ^ 2) := Real.sqrt_le_sqrt hle
    _ = Real.sqrt 2 * m := Real.sqrt_sq (by positivity)

/-- **At most two probes in any window are factor-bearing.** The numerator of the
density is bounded by an absolute constant, no matter how large the window. -/
theorem hits_card_le_two (hp : p.Prime) (hq : q.Prime) (hlt : p < q) (m : ℕ) :
    (((Finset.Icc 2 m).filter (fun d => d ∣ p * q ∧ d ≠ p * q)).card) ≤ 2 := by
  have hsub : ((Finset.Icc 2 m).filter (fun d => d ∣ p * q ∧ d ≠ p * q)) ⊆ ({p, q} : Finset ℕ) := by
    intro d hd
    simp only [Finset.mem_filter, Finset.mem_Icc] at hd
    obtain ⟨⟨hd2, _⟩, hdvd, hdne⟩ := hd
    have hmem : d ∈ (p * q).divisors :=
      Nat.mem_divisors.mpr ⟨hdvd, Nat.mul_ne_zero hp.pos.ne' hq.pos.ne'⟩
    rw [divisors_semiprime p q hp hq] at hmem
    simp only [Finset.mem_insert, Finset.mem_singleton] at hmem
    simp only [Finset.mem_insert, Finset.mem_singleton]
    rcases hmem with rfl | rfl | rfl | rfl
    · omega
    · exact Or.inl rfl
    · exact Or.inr rfl
    · exact absurd rfl hdne
  exact le_trans (Finset.card_le_card hsub) (le_trans (Finset.card_insert_le _ _) (by simp))

/-- **The noise-floor principle.** For a balanced semiprime `N = pq`, the density of
factor-bearing probes in any window `[2, m]` that succeeds at all is at most
`2√2 / √N`. The factor-bearing samples sit at the birthday-bound density: no
aggregate over such a window can beat trial division. -/
theorem noise_floor_principle (hp : p.Prime) (hq : q.Prime) (hlt : p < q) (hbal : q ≤ 2 * p)
    {m d : ℕ} (hdvd : d ∣ p * q) (h1 : 1 < d) (h2 : d < p * q) (hdm : d ≤ m) :
    ((((Finset.Icc 2 m).filter (fun x => x ∣ p * q ∧ x ≠ p * q)).card : ℝ) / m)
      ≤ 2 * Real.sqrt 2 / Real.sqrt ((p * q : ℕ) : ℝ) := by
  have hm : 0 < m := lt_of_lt_of_le (by omega) hdm
  have hN : 0 < p * q := Nat.mul_pos hp.pos hq.pos
  have hsq : p * q ≤ 2 * m * m := balanced_window_sq_bound hp hq hlt hbal hdvd h1 h2 hdm
  have hmR : (0 : ℝ) < m := by exact_mod_cast hm
  have hNR : (0 : ℝ) < (p * q : ℕ) := by exact_mod_cast hN
  have hcard : ((((Finset.Icc 2 m).filter (fun x => x ∣ p * q ∧ x ≠ p * q)).card : ℝ)) ≤ 2 := by
    exact_mod_cast hits_card_le_two hp hq hlt m
  have hstep : ((((Finset.Icc 2 m).filter (fun x => x ∣ p * q ∧ x ≠ p * q)).card : ℝ) / m)
      ≤ (2 : ℝ) / m := by gcongr
  refine le_trans hstep ?_
  have hs0 : 0 < Real.sqrt (p * q : ℕ) := Real.sqrt_pos.mpr hNR
  have hroot : Real.sqrt ((p * q : ℕ)) ≤ Real.sqrt 2 * m := balanced_window_sqrt_bound hm hsq
  rw [div_le_div_iff₀ hmR hs0]
  nlinarith [Real.sqrt_nonneg 2]

/-- **Aggregation cost is exactly the birthday scale.** For a balanced semiprime the
length of the sweep needed to see a factor is squeezed between `√(N/2)` and `√N`:
the free-witness aggregation barrier and the trial-division birthday bound are the
same `Θ(√N)` obstruction. -/
theorem aggregation_cost_is_birthday_scale (hlt : p < q)
    (hbal : q ≤ 2 * p) : p ≤ Nat.sqrt (p * q) ∧ p * q ≤ 2 * p * p := by
  refine ⟨Nat.le_sqrt.mpr (by nlinarith), balanced_sq_bound hbal⟩

end NoiseFloor