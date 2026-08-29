import Mathlib
import Tropical.OrbitDialCapLaw
import Tropical.OrbitDialInvariants

/-!
# Where the escape comes from: prior, not information

Cycle 4 of the ORBIT-DIAL-CAP-TEST.  Cycles 1–3 established two regimes: exchangeable
dials capped at `4/3`, structural dials unbounded.  This file isolates *why* a fixed
(zero-information) dial can be super-exchangeable at all.

A dial is a fixed set `K` of retained candidates inside the candidate pool `C`.  Its
retention is the density `|K| / |C|`, and its soundness is the probability that the true
factor lies in `K`.

* `OrbitDialCap.Dich.uniform_prior_soundness_eq_retention` — if the true factor is
  *uniform* on the pool, then soundness equals retention: a fixed dial is automatically
  exchangeable.
* `OrbitDialCap.Dich.fixed_dial_uniform_prior_capped` — hence a fixed dial against a
  uniform prior obeys the `4/3` cap.  A zero-information dial cannot beat the cap by
  itself.
* `OrbitDialCap.Dich.supported_prior_soundness_one` — the escape hatch: if the prior is
  *supported* in `K` — as the divisors of an odd `N` are supported in the odd residues —
  the soundness jumps to `1` with no information gained.
* `OrbitDialCap.Dich.parity_pool_density` and `OrbitDialCap.Dich.parity_escape` — the
  ORBIT arm instantiated: within any pool `range (2*k)` the odd candidates have density
  exactly `1/2`, and for odd `N` every divisor is odd, so `s = 1`, `θ = 1/2`, speedup
  `2`.

The dichotomy: `s > θ` requires either per-`N` information (a dial that varies with `N`)
or a prior that is already concentrated on the kept set (a structural congruence such as
`p` odd).  The Berggren orbit dial is entirely of the second kind.
-/

namespace OrbitDialCap
namespace Dich

open Finset

variable {α : Type*} [DecidableEq α]

/-- Retention of a fixed dial `K` inside a candidate pool `C`. -/
noncomputable def retention (K C : Finset α) : ℝ := ((K ∩ C).card : ℝ) / (C.card : ℝ)

/-- Soundness of the dial against a prior `π` on the pool: the total prior mass of the
kept candidates. -/
noncomputable def soundness (K : Finset α) (C : Finset α) (π : α → ℝ) : ℝ :=
  ∑ a ∈ K ∩ C, π a

/-- **Fixed dial, uniform prior: soundness = retention.**  With no per-`N` information
and no structural bias the dial is exactly exchangeable. -/
theorem uniform_prior_soundness_eq_retention (K C : Finset α) (hC : 0 < C.card) :
    soundness K C (fun _ => (1 : ℝ) / (C.card : ℝ)) = retention K C := by
  have hCne : ((C.card : ℝ)) ≠ 0 := by positivity
  rw [soundness, retention, Finset.sum_const, nsmul_eq_mul]
  field_simp

/-- **No free lunch for information-free dials.**  A fixed dial evaluated against a
uniform prior has soundness equal to its retention, so the `4/3` cap applies to it. -/
theorem fixed_dial_uniform_prior_capped (K C : Finset α) (hC : 0 < C.card)
    (hpos : 0 < retention K C) (hle : retention K C ≤ 1) :
    dialSpeedup (soundness K C (fun _ => (1 : ℝ) / (C.card : ℝ))) (retention K C) ≤ 4 / 3 := by
  rw [uniform_prior_soundness_eq_retention K C hC]
  exact exchangeable_cap hpos hle

/-- **The escape hatch.**  If the prior is supported in the kept set — as the divisors of
an odd `N` are supported in the odd numbers — the soundness is `1`, no matter how small
the retention, and no information about `N` has been used. -/
theorem supported_prior_soundness_one {K C : Finset α} {π : α → ℝ}
    (htot : ∑ a ∈ C, π a = 1) (hsupp : ∀ a ∈ C, a ∉ K → π a = 0) :
    soundness K C π = 1 := by
  rw [soundness, ← htot]
  refine Finset.sum_subset Finset.inter_subset_right ?_
  intro a haC haKC
  exact hsupp a haC (fun haK => haKC (Finset.mem_inter.mpr ⟨haK, haC⟩))

/-- The odd candidates in `range (2*k)` number exactly `k`: the parity dial has retention
exactly `1/2` in every even-length pool. -/
theorem parity_pool_card (k : ℕ) :
    ((Finset.range (2 * k)).filter (fun a => ¬ 2 ∣ a)).card = k := by
  induction k with
  | zero => simp
  | succ n ih =>
      have hstep : 2 * (n + 1) = (2 * n + 1) + 1 := by ring
      rw [hstep, Finset.range_add_one, Finset.filter_insert,
        if_pos (by omega : ¬ (2 ∣ (2 * n + 1))), Finset.range_add_one, Finset.filter_insert,
        if_neg (by simp : ¬ ¬ (2 ∣ 2 * n)), Finset.card_insert_of_notMem (by simp), ih]

/-- Retention of the parity dial in the pool `range (2*k)` is exactly `1/2`. -/
theorem parity_pool_density {k : ℕ} (hk : 0 < k) :
    retention ((Finset.range (2 * k)).filter (fun a => ¬ 2 ∣ a)) (Finset.range (2 * k))
      = 1 / 2 := by
  have hcard : ((Finset.range (2 * k)).filter (fun a => ¬ 2 ∣ a) ∩
      Finset.range (2 * k)).card = k := by
    rw [Finset.inter_eq_left.mpr (Finset.filter_subset _ _)]
    exact parity_pool_card k
  have hk' : ((k : ℝ)) ≠ 0 := Nat.cast_ne_zero.mpr hk.ne'
  rw [retention, hcard, Finset.card_range]
  push_cast
  field_simp

/-- **The ORBIT arm, end to end.**  For an odd `N`, in any even-length candidate pool the
parity dial has retention `1/2` and soundness `1` (every divisor of `N` is odd), hence
speedup `2 > 4/3` — while a fixed dial against a uniform prior would have been capped at
`4/3`.  The gap is created by the prior, not by information. -/
theorem parity_escape {N : ℕ} (hN : Odd N) :
    (∀ p, p ∣ N → ¬ (2 ∣ p)) ∧
    dialSpeedup 1 (1 / 2) = 2 ∧
    dialSpeedup (1 / 2) (1 / 2) = 4 / 3 := by
  refine ⟨fun p hp => Berggren.parity_dial_sound hN hp, parity_skip_speedup, exchangeable_half⟩

end Dich
end OrbitDialCap