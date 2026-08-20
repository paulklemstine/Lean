/-
# NET-30 / Catalog·NumberTheory — The ≥2 / ≥3 design rule, derived

Second research cycle.  The first three files show *that* the measured k = 2
signature needs at least two exclusive coordinates and a strictly concave
(saturating) read-out.  This file shows that once one accepts the canonical
saturating channel — `k` exclusive coordinates of equal gain `g > 0`, summed,
rectified and clipped at the level `1` needed by the digit read-out — the whole
NET-29/NET-30 width ladder is *forced arithmetic*:

| intervention   | surviving block gain | saturated iff |
|----------------|----------------------|---------------|
| `ctl`          | `k · g`              | `k g ≥ 1`     |
| `zeroAt i`     | `(k-1) · g`          | `(k-1) g ≥ 1` |
| `flipAt i`     | `(k-2) · g`          | `(k-2) g ≥ 1` |
| `zeroAll`      | `0`                  | never         |

At unit gain this reads: single ablations are no-ops **iff `k ≥ 2`**, sign flips
are no-ops **iff `k ≥ 3`**, and the whole block is never dispensable.  That is
exactly the empirical ladder:

* `k = 1`: ablation = block ablation, no redundancy (Part B);
* `k = 2`: single ablations no-op, **flip breaks** (`0.9980 → 0.7505`, NET-30);
* `k = 3`: single ablations no-op **and flip no-ops** (NET-29's "signs never
  matter", which NET-30 correctly downgraded to a `k = 3` statement).

Main results: `satGate_uniform`, `satGate_uniform_zeroAt`,
`satGate_uniform_flipAt` (the table), `self_sufficient_iff_gain`,
`sign_robust_iff_gain` (the two design thresholds),
`design_rule_two_exclusive_dims`, `design_rule_three_for_sign_robustness`
(the unit-gain corollaries — NET-30's design rule, derived rather than fitted),
and `saturation_ladder_k_one_two_three`, which packages the three measured
widths in one statement.

`self_sufficiency_monotone_in_gain` records the model's falsifiable prediction
in the other direction: at fixed width and fixed clip level, *larger* exclusive
coordinates are *more* self-sufficient.  The measured s = 13 arms are the
opposite (largest coordinates of their width, least self-sufficient), so a
fixed clip level is refuted for that seed and the clip must co-scale with the
coordinate magnitude — the sharpest next-cycle test this round produces.
-/

import Mathlib
import Catalog.NumberTheory.ExclusiveChannelPopulation

namespace NumberTheory.ExclusiveChannel

open Finset

variable {k : ℕ}

/-! ## Block sums under the interventions -/

theorem sum_zeroAt (c : Fin k → ℝ) (i : Fin k) :
    ∑ j, zeroAt i c j = (∑ j, c j) - c i := by
  simpa [margin] using margin_zeroAt 0 (fun _ => (1 : ℝ)) c i

theorem sum_flipAt (c : Fin k → ℝ) (i : Fin k) :
    ∑ j, flipAt i c j = (∑ j, c j) - 2 * c i := by
  simpa [margin] using margin_flipAt 0 (fun _ => (1 : ℝ)) c i

/-! ## The canonical saturating channel -/

/-- `k` exclusive coordinates of equal gain `g`. -/
def uniformCoef (k : ℕ) (g : ℝ) : Fin k → ℝ := fun _ => g

@[simp] theorem sum_uniformCoef (k : ℕ) (g : ℝ) : ∑ i, uniformCoef k g i = k * g := by
  simp [uniformCoef, mul_comm]

theorem satGate_uniform {g : ℝ} (hg : 0 ≤ g) :
    satGate (uniformCoef k g) = min (k * g) 1 := by
  have hk : (0 : ℝ) ≤ k * g := mul_nonneg (Nat.cast_nonneg k) hg
  simp [satGate, max_eq_left hk]

theorem satGate_uniform_zeroAt {g : ℝ} (hg : 0 ≤ g) (hk : 1 ≤ k) (i : Fin k) :
    satGate (zeroAt i (uniformCoef k g)) = min (((k : ℝ) - 1) * g) 1 := by
  have hkR : (1 : ℝ) ≤ k := by exact_mod_cast hk
  have hsum : ∑ j, zeroAt i (uniformCoef k g) j = ((k : ℝ) - 1) * g := by
    rw [sum_zeroAt, sum_uniformCoef]
    simp [uniformCoef]
    ring
  have hnn : (0 : ℝ) ≤ ((k : ℝ) - 1) * g := mul_nonneg (by linarith) hg
  simp [satGate, hsum, max_eq_left hnn]

theorem satGate_uniform_flipAt {g : ℝ} (hg : 0 ≤ g) (hk : 2 ≤ k) (i : Fin k) :
    satGate (flipAt i (uniformCoef k g)) = min (((k : ℝ) - 2) * g) 1 := by
  have hkR : (2 : ℝ) ≤ k := by exact_mod_cast hk
  have hsum : ∑ j, flipAt i (uniformCoef k g) j = ((k : ℝ) - 2) * g := by
    rw [sum_flipAt, sum_uniformCoef]
    simp [uniformCoef]
    ring
  have hnn : (0 : ℝ) ≤ ((k : ℝ) - 2) * g := mul_nonneg (by linarith) hg
  simp [satGate, hsum, max_eq_left hnn]

/-! ## The two design thresholds -/

/-- **Self-sufficiency threshold.**  In a saturated channel (`k g ≥ 1`) a single
ablation is a no-op exactly when the *remaining* gain still saturates the gate:
`(k - 1) g ≥ 1`. -/
theorem self_sufficient_iff_gain {g : ℝ} (hg : 0 ≤ g) (hk : 1 ≤ k)
    (hsat : 1 ≤ (k : ℝ) * g) (i : Fin k) :
    satGate (zeroAt i (uniformCoef k g)) = satGate (uniformCoef k g)
      ↔ 1 ≤ ((k : ℝ) - 1) * g := by
  rw [satGate_uniform hg, satGate_uniform_zeroAt hg hk i, min_eq_right hsat]
  constructor
  · intro h
    by_contra hcon
    push_neg at hcon
    rw [min_eq_left hcon.le] at h
    linarith
  · intro h
    exact min_eq_right h

/-- **Sign-robustness threshold.**  A single sign flip removes *twice* the
coordinate, so it is a no-op exactly when `(k - 2) g ≥ 1`. -/
theorem sign_robust_iff_gain {g : ℝ} (hg : 0 ≤ g) (hk : 2 ≤ k)
    (hsat : 1 ≤ (k : ℝ) * g) (i : Fin k) :
    satGate (flipAt i (uniformCoef k g)) = satGate (uniformCoef k g)
      ↔ 1 ≤ ((k : ℝ) - 2) * g := by
  rw [satGate_uniform hg, satGate_uniform_flipAt hg hk i, min_eq_right hsat]
  constructor
  · intro h
    by_contra hcon
    push_neg at hcon
    rw [min_eq_left hcon.le] at h
    linarith
  · intro h
    exact min_eq_right h

/-! ## The unit-gain ladder: NET-30's design rule, derived -/

/-- **Design rule: ≥ 2 exclusive dimensions for a self-sufficient recovery.**
At unit gain a single ablation is a no-op precisely from two exclusive
coordinates on. -/
theorem design_rule_two_exclusive_dims (hk : 1 ≤ k) (i : Fin k) :
    satGate (zeroAt i (uniformCoef k 1)) = satGate (uniformCoef k 1) ↔ 2 ≤ k := by
  have hkR : (1 : ℝ) ≤ k := by exact_mod_cast hk
  have hsat : 1 ≤ (k : ℝ) * 1 := by linarith
  rw [self_sufficient_iff_gain (by norm_num) hk hsat i]
  constructor
  · intro h
    have h2 : (2 : ℝ) ≤ k := by linarith
    exact_mod_cast h2
  · intro h
    have h2 : (2 : ℝ) ≤ k := by exact_mod_cast h
    linarith

/-- **Design rule: ≥ 3 exclusive dimensions for sign robustness.**  At unit gain
a sign flip is a no-op precisely from three exclusive coordinates on — the
formal content of "k = 3's flip was a no-op, k = 2's flip cost 0.25", i.e. of
sign-sensitivity being width-conditional. -/
theorem design_rule_three_for_sign_robustness (hk : 2 ≤ k) (i : Fin k) :
    satGate (flipAt i (uniformCoef k 1)) = satGate (uniformCoef k 1) ↔ 3 ≤ k := by
  have hkR : (2 : ℝ) ≤ k := by exact_mod_cast hk
  have hsat : 1 ≤ (k : ℝ) * 1 := by linarith
  rw [sign_robust_iff_gain (by norm_num) hk hsat i]
  constructor
  · intro h
    have h3 : (3 : ℝ) ≤ k := by linarith
    exact_mod_cast h3
  · intro h
    have h3 : (3 : ℝ) ≤ k := by exact_mod_cast h
    linarith

/-- **The measured ladder in one statement.**  For the unit-gain saturating
channel: at `k = 1` the sole ablation destroys the channel; at `k = 2` ablations
are no-ops but the sign flip destroys it; at `k = 3` both are no-ops.  Compare
Part B (k = 1), Part A (k = 2, flip `−0.2475`) and NET-29 (k = 3, flip a
no-op). -/
theorem saturation_ladder_k_one_two_three :
    (satGate (zeroAt 0 (uniformCoef 1 1)) = 0 ∧ satGate (uniformCoef 1 1) = 1) ∧
    (satGate (zeroAt 0 (uniformCoef 2 1)) = satGate (uniformCoef 2 1) ∧
      satGate (flipAt 0 (uniformCoef 2 1)) = 0 ∧ satGate (uniformCoef 2 1) = 1) ∧
    (satGate (zeroAt 0 (uniformCoef 3 1)) = satGate (uniformCoef 3 1) ∧
      satGate (flipAt 0 (uniformCoef 3 1)) = satGate (uniformCoef 3 1)) := by
  refine ⟨⟨?_, ?_⟩, ⟨?_, ?_, ?_⟩, ?_, ?_⟩
  · rw [zeroAt_eq_zeroAll_of_one _ 0, satGate_zeroAll]
  · rw [satGate_uniform (by norm_num)]; norm_num
  · exact (design_rule_two_exclusive_dims (by norm_num) 0).2 (by norm_num)
  · rw [satGate_uniform_flipAt (by norm_num) (by norm_num) 0]; norm_num
  · rw [satGate_uniform (by norm_num)]; norm_num
  · exact (design_rule_two_exclusive_dims (by norm_num) 0).2 (by norm_num)
  · exact (design_rule_three_for_sign_robustness (by norm_num) 0).2 (by norm_num)

/-! ## A falsifiable prediction in the other direction -/

/-- **Bigger coordinates are more self-sufficient (at a fixed clip level).**  If
the channel is self-sufficient at per-coordinate gain `g`, it is self-sufficient
at every larger gain.  The measured s = 13 arms carry the *largest* exclusive
coordinates of their width and are the *least* self-sufficient ones, so a
seed-independent clip level is refuted: the read-out threshold must co-scale
with the coordinate magnitude.  This is the round's sharpest next-cycle test. -/
theorem self_sufficiency_monotone_in_gain {g g' : ℝ} (hg : 0 ≤ g) (hgg : g ≤ g')
    (hk : 1 ≤ k) (i : Fin k)
    (hsat : 1 ≤ (k : ℝ) * g) (hself : satGate (zeroAt i (uniformCoef k g))
      = satGate (uniformCoef k g)) :
    satGate (zeroAt i (uniformCoef k g')) = satGate (uniformCoef k g') := by
  have hkR : (1 : ℝ) ≤ k := by exact_mod_cast hk
  have hg' : 0 ≤ g' := le_trans hg hgg
  have h1 : 1 ≤ ((k : ℝ) - 1) * g := (self_sufficient_iff_gain hg hk hsat i).1 hself
  have h2 : ((k : ℝ) - 1) * g ≤ ((k : ℝ) - 1) * g' :=
    mul_le_mul_of_nonneg_left hgg (by linarith)
  have hsat' : 1 ≤ (k : ℝ) * g' := by nlinarith
  exact (self_sufficient_iff_gain hg' hk hsat' i).2 (le_trans h1 h2)

end NumberTheory.ExclusiveChannel