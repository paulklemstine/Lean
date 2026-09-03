import Mathlib
import Tropical.ScaleFlowSweep

/-!
# The continuous budget table: reach, and the staircase-versus-triangle defect

The discrete theory (`Combinatorics.OctaveShiftLaw`) reads the octave shift law in
*adjoint* form: for a fixed key budget `b`, the first context octave that fails
moves right by exactly one per scale doubling (`firstFail_shift`), and the served
region of the `S × J` corner of the (scale, context) table is a staircase of
triangular area, `2·card = 2·S·f + S(S−1)`.

This file gives both statements a real-parameter form.

* `reach` — the **budget reach** `(b − k₀)/δ`, the number of context octaves a
  budget `b` buys above the base context.  `served_iff` proves the exact adjunction
  `k*(σ, t) ≤ b ↔ t ≤ σ + reach`, and `isGreatest_served` upgrades it to
  `IsGreatest`: the served interval at scale `σ` is `(−∞, σ + reach]`.
* `reach_flow` — the **continuous budget law**: the boundary of the served region
  is the line `t = σ + reach` of slope exactly `1`.  A fixed budget buys one
  context octave per octave of scale, now for *real* scale; the discrete law is the
  restriction of this line to the integer lattice.
* `net66_reach_16` — the measured instance: a 16-key budget has reach `0`, so its
  served boundary is the diagonal `t = σ`, and `net66_firstFail_eq_reach` checks
  this against the measured discrete cells (`firstFail = s + 1`).
* `net66_staircase_defect` — the **bridge**: the exact number of served *cells* of
  the discrete table and the exact *area* under the continuous served boundary
  differ by exactly `S/2`, for every `S`.  The half is the Euler–Maclaurin
  correction of the staircase; it is the precise price of discretising the scale
  axis, and it vanishes to first order, which is why the continuous table is a
  faithful interpolation of the measured one.
-/

namespace Tropical.ScaleFlowBudget

open Tropical.ScaleFlowSweep Combinatorics.OctaveShiftLaw Finset

/-! ## The reach of a budget -/

/-- The **reach** of a key budget: the number of context octaves above the base
context that budget `b` buys, for a profile with base knee `k₀` and rate `δ`. -/
noncomputable def reach (k0 delta b : ℝ) : ℝ := (b - k0) / delta

theorem reach_nonneg {k0 delta b : ℝ} (hδ : 0 < delta) (hb : k0 ≤ b) : 0 ≤ reach k0 delta b :=
  div_nonneg (by linarith) (le_of_lt hδ)

/-- **The budget adjunction, continuous form.**  Context octave `t` is served at
real scale `σ` by budget `b` exactly when `t ≤ σ + reach`. -/
theorem served_iff {k0 delta b : ℝ} (hδ : 0 < delta) (hb : k0 ≤ b) (sigma t : ℝ) :
    kstar k0 delta sigma t ≤ b ↔ t ≤ sigma + reach k0 delta b := by
  rcases le_total t sigma with h | h
  · rw [kstar_of_le h]
    have : (0 : ℝ) ≤ reach k0 delta b := reach_nonneg hδ hb
    constructor
    · intro _; linarith
    · intro _; linarith
  · rw [kstar_of_ge h, reach]
    constructor
    · intro hcon
      rw [← sub_le_iff_le_add', le_div_iff₀ hδ]
      nlinarith
    · intro hcon
      rw [← sub_le_iff_le_add', le_div_iff₀ hδ] at hcon
      nlinarith

/-- The served set at a real scale is exactly the closed ray below `σ + reach`,
and that endpoint is attained. -/
theorem isGreatest_served {k0 delta b : ℝ} (hδ : 0 < delta) (hb : k0 ≤ b) (sigma : ℝ) :
    IsGreatest {t : ℝ | kstar k0 delta sigma t ≤ b} (sigma + reach k0 delta b) := by
  constructor
  · exact (served_iff hδ hb sigma _).mpr le_rfl
  · intro t ht
    exact (served_iff hδ hb sigma t).mp ht

/-- **The continuous budget law.**  The served boundary is the line of slope one:
`sup {t | k*(σ,t) ≤ b} = σ + reach`.  One octave of scale buys one octave of
context, for every real scale increment. -/
theorem reach_flow {k0 delta b : ℝ} (hδ : 0 < delta) (hb : k0 ≤ b) (sigma h : ℝ) :
    IsGreatest {t : ℝ | kstar k0 delta (sigma + h) t ≤ b}
      ((sigma + reach k0 delta b) + h) := by
  have hg := isGreatest_served hδ hb (sigma + h)
  rwa [show sigma + h + reach k0 delta b = sigma + reach k0 delta b + h by ring] at hg

/-! ## The measured instance -/

/-- A 16-key budget on the NET-66 profile has reach `0`: its served boundary is the
diagonal `t = σ`, i.e. the base context of the model at that scale. -/
theorem net66_reach_16 : reach 16 4 16 = 0 := by
  simp [reach]

theorem net66_served_16 (sigma : ℝ) :
    IsGreatest {t : ℝ | kstar 16 4 sigma t ≤ 16} sigma := by
  have := isGreatest_served (k0 := 16) (delta := 4) (b := 16) (by norm_num) (by norm_num) sigma
  simpa [net66_reach_16] using this

/-- Consistency with the measured discrete cells: the continuous reach of the
16-key budget at integer scale `s` is `s`, and the discrete first failing octave is
`s + 1` — the next lattice point, exactly as the catalog measured for `s = 0, 1`
and predicted for `s = 2`. -/
theorem net66_firstFail_eq_reach (s : ℕ) :
    firstFail (net66.chain s) 16 = s + 1 ∧
      IsGreatest {t : ℝ | kstar 16 4 (s : ℝ) t ≤ 16} (s : ℝ) := by
  have h1 : net66.chain 0 1 = 20 := by norm_num [net66, shift, net66Base]
  have hne : ∃ j, 16 < net66.chain 0 j := ⟨1, by rw [h1]; norm_num⟩
  have hbase : firstFail (net66.chain 0) 16 = 1 := net66_budget_16.1
  refine ⟨?_, net66_served_16 (s : ℝ)⟩
  rw [net66.budget_table hne (by rw [hbase]; omega) s, hbase, Nat.add_comm]

/-! ## Staircase versus triangle -/

/-- The area under the continuous served boundary over the scale window `[0, S]`,
for the 16-key budget (reach `0`), is the triangle `S²/2`. -/
theorem served_area (S : ℝ) : (∫ sigma in (0:ℝ)..S, sigma) = S ^ 2 / 2 := by
  rw [integral_id]
  ring

/-- **The staircase–triangle defect.**  For every scale window `S` (inside a wide
enough context window) the number of served *cells* of the measured discrete table
exceeds the *area* under the continuous served boundary by exactly `S/2`.

This is the exact discretisation error of the real-parameter extension: the
continuous table is not merely asymptotically consistent with the measurements, the
mismatch is a known linear term, the Euler–Maclaurin half-cell correction. -/
theorem net66_staircase_defect (S J : ℕ) (hJ : S ≤ J) :
    ((net66.served 16 S J).card : ℝ) = (∫ sigma in (0:ℝ)..(S : ℝ), sigma) + S / 2 := by
  have h1 : net66.chain 0 1 = 20 := by norm_num [net66, shift, net66Base]
  have hne : ∃ j, 16 < net66.chain 0 j := ⟨1, by rw [h1]; norm_num⟩
  have hbase : firstFail (net66.chain 0) 16 = 1 := net66_budget_16.1
  have hcard := net66.served_card_two_mul (b := 16) (S := S) (J := J) hne
    (by rw [hbase]; omega) (by omega)
  rw [hbase] at hcard
  -- `hcard : 2 * card = 2 * S * 1 + S * (S - 1)`
  have hR : 2 * ((net66.served 16 S J).card : ℝ) = 2 * S + S * (S - 1) := by
    rcases Nat.eq_zero_or_pos S with hS | hS
    · subst hS
      have : (net66.served 16 0 J).card = 0 := by
        have := hcard
        simpa using this
      simp [this]
    · have hcast : ((S * (S - 1) : ℕ) : ℝ) = (S : ℝ) * ((S : ℝ) - 1) := by
        push_cast [Nat.cast_sub hS]
        ring
      have := congrArg (fun n : ℕ => (n : ℝ)) hcard
      push_cast at this
      rw [Nat.cast_sub hS] at this
      push_cast at this
      linarith
  rw [served_area]
  linarith

end Tropical.ScaleFlowBudget