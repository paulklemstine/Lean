import Probability.NET89BlockInterpolation

/-!
# NET-89, cycle 8: the gate-resolution budget of an `m`-domain protocol

Cycle 5 showed that interleaving *two* domains subdivides every step of the knee staircase
into two sub-steps, so a mixed measurement resolves the gate at most half as finely as the
pure measurement it is compared against.  Direction **D4** of that cycle asked for the
general law.  Here it is.

* `stepWidth_roundRobin` — the step of a round-robin context at index `m·k + j` is the
  normalised mass of key `k` of domain `j`: one sub-step per domain, per pooled step.
* `poolFam_step_splits` — the `m` sub-steps of a pooled step sum to that pooled step.
  Interleaving neither creates nor destroys resolution; it partitions it.
* `exists_substep_le_pooled_div_m` — hence some sub-step is at most `1/m` of the pooled
  step: **the finest gate distinction degrades like `1/m` in the number of domains.**
* `net89_multidomain_resolution_limit` — and the degradation is realised: there is an
  explicit gate at which a perturbation of size `(pooled step)/m` already moves the
  round-robin knee by one key.  With cycle 3's multiplier theorem (`Δ_rr ≈ m·Δ_pool`) this
  gives the exact trade-off of a multi-domain protocol: **the increment is multiplied by
  `m` and the gate resolution is divided by `m`.**  A reported `m`-domain increment is a
  measurement only if the gate sits further than `1/m` of a pooled step from a step edge.

-- !-- Lab Notes -- !--
Hypothesizer (cycle 8):
 (H1) A round-robin step is a single domain's key mass, normalised by the total.
 (H2) The `m` sub-steps of a pooled step telescope to it, so the minimum sub-step is at
      most `1/m` of the pooled step.                                          [BOLD]
 (H3) The bound is attained as an instability: an explicit gate flips under a
      perturbation of that size, so `1/m` is a genuine resolution budget.     [BOLD]

Experimenter: H1–H3 formalised below, zero sorries; the two-domain case recovers cycle 5
via `roundRobin_two`.

Analyst: cycles 3 and 8 together say that the two headline quantities of a multi-domain
protocol move in opposite directions by the same factor.  Every extra content type buys a
proportionally larger increment and pays a proportionally smaller resolution, so the
*signal-to-resolution ratio* of the protocol is invariant in `m` — which is why a raw
increment comparison across domain counts is not a fair comparison.

Critic: the resolution statement is an existence statement over the `m` sub-steps, which is
the honest form: a particular sub-step may be wide, but the staircase is only as fine as
its narrowest visible step, and that one is exhibited.
-/

namespace Catalog.Probability.NET89MixedDomainKnee

open Finset AttentionBudget

variable {U : ℕ → ℕ → ℝ} {m n k j : ℕ}

/-! ## 1. The sub-steps of a round-robin context -/

lemma roundRobin_index (hm : 0 < m) (hj : j < m) (U : ℕ → ℕ → ℝ) (k : ℕ) :
    roundRobin m U (m * k + j) = U j k := by
  have h1 : (m * k + j) % m = j := by rw [Nat.mul_add_mod, Nat.mod_eq_of_lt hj]
  have h2 : (m * k + j) / m = k := by
    rw [Nat.mul_add_div hm, Nat.div_eq_of_lt hj, Nat.add_zero]
  simp [roundRobin, h1, h2]

/-- A single step of the round-robin staircase is one domain's key mass, normalised by the
total mass of the interleaved context. -/
lemma stepWidth_roundRobin (hm : 0 < m) (hj : j < m) (U : ℕ → ℕ → ℝ) (n k : ℕ) :
    stepWidth (roundRobin m U) (m * n) (m * k + j)
      = U j k / ∑ i ∈ range m, headMass (U i) n := by
  rw [stepWidth, roundRobin_index hm hj, headMass_roundRobin hm]

/-- **Step splitting for `m` domains.**  Each pooled step is partitioned into exactly `m`
round-robin sub-steps, one per domain. -/
theorem poolFam_step_splits (hm : 0 < m) (U : ℕ → ℕ → ℝ) (n k : ℕ) :
    stepWidth (poolFam m U) n k
      = ∑ j ∈ range m, stepWidth (roundRobin m U) (m * n) (m * k + j) := by
  rw [stepWidth, headMass_poolFam]
  have hnum : poolFam m U k = ∑ j ∈ range m, U j k := rfl
  rw [hnum, Finset.sum_div]
  refine Finset.sum_congr rfl fun j hj => ?_
  rw [stepWidth_roundRobin hm (mem_range.mp hj)]

/-- **The resolution budget.**  Some sub-step is at most `1/m` of the pooled step it
refines: the finest gate distinction a round-robin experiment can make degrades like the
reciprocal of the number of interleaved domains. -/
theorem exists_substep_le_pooled_div_m (hm : 0 < m) (U : ℕ → ℕ → ℝ) (n k : ℕ) :
    ∃ j < m, stepWidth (roundRobin m U) (m * n) (m * k + j)
      ≤ stepWidth (poolFam m U) n k / m := by
  by_contra hcon
  push_neg at hcon
  have hne : (range m).Nonempty := ⟨0, mem_range.mpr hm⟩
  have hlt : ∑ j ∈ range m, stepWidth (poolFam m U) n k / m
      < ∑ j ∈ range m, stepWidth (roundRobin m U) (m * n) (m * k + j) :=
    Finset.sum_lt_sum_of_nonempty hne fun j hj => hcon j (mem_range.mp hj)
  rw [Finset.sum_const, card_range, nsmul_eq_mul] at hlt
  rw [← poolFam_step_splits hm] at hlt
  have hm0 : (0 : ℝ) < m := by exact_mod_cast hm
  rw [mul_div_cancel₀ _ hm0.ne'] at hlt
  exact lt_irrefl _ hlt

/-! ## 2. The budget is attained: an explicit `m`-domain gate flip -/

/-- **The `m`-domain resolution limit.**  There is a sub-step of the pooled step at index
`k` of width at most `(pooled step)/m`, and at the gate sitting on its lower edge *every*
perturbation up to that width moves the round-robin knee by exactly one key.  Combined with
cycle 3's multiplier theorem, an `m`-domain protocol multiplies the reported increment by
`m` and divides the gate resolution by `m`. -/
theorem net89_multidomain_resolution_limit (hm : 0 < m) (hU : ∀ j i, 0 < U j i)
    (hk1 : 1 ≤ k) (hk : k < n) :
    ∃ j < m, stepWidth (roundRobin m U) (m * n) (m * k + j)
        ≤ stepWidth (poolFam m U) n k / m ∧
      ∀ ε : ℝ, 0 < ε → ε ≤ stepWidth (roundRobin m U) (m * n) (m * k + j) →
        kstar (roundRobin m U) (m * n)
            (retained (roundRobin m U) (m * n) (m * k + j)) = m * k + j ∧
          kstar (roundRobin m U) (m * n)
            (retained (roundRobin m U) (m * n) (m * k + j) + ε) = m * k + j + 1 := by
  obtain ⟨j, hj, hle⟩ := exists_substep_le_pooled_div_m hm U n k
  refine ⟨j, hj, hle, fun ε hε hεw => ?_⟩
  have hrp : ∀ i, 0 < roundRobin m U i := roundRobin_pos hU
  have hpos : 0 < m * k + j := by
    have : m ≤ m * k := Nat.le_mul_of_pos_right m hk1
    omega
  have hlt : m * k + j < m * n := by
    have h1 : m * (k + 1) ≤ m * n := Nat.mul_le_mul_left _ hk
    have h2 : m * (k + 1) = m * k + m := by ring
    omega
  exact knee_unstable_at_step_edge hrp hpos hlt hε hεw

end Catalog.Probability.NET89MixedDomainKnee