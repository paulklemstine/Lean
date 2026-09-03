import Mathlib
import Tropical.ScaleFlowSweep

/-!
# What a model family owns, and what the flow owns

The mission's competing hypothesis is that "scale acts only discretely and each
model family needs its own chain".  The continuous theory lets that be settled
precisely, because it makes the *scale axis itself* a variable that could, a
priori, be re-gauged from family to family.  Two questions:

1. **Is the keys-per-octave rate a gauge artefact?**  If a family could be matched
   by re-parametrising the scale axis of another family with a different rate, the
   rate would carry no information.  `kstar_rate_identifiable` shows the opposite:
   if two clamped-affine tables agree at every real context, then their base knees,
   their rates *and* their scale offsets agree.  The rate `δ` is therefore an
   invariant of the flow, not of the parametrisation — and by
   `net66_rate_forced`, a family reproducing the measured NET-66 cells must have
   `δ = 4` keys per octave and base knee `16`.
2. **What freedom is left?**  Exactly one parameter: the scale offset.
   `kstar_offset_conjugacy` shows any two tables with the same `(k₀, δ)` are
   translates of each other along the flow direction `(1,1)`.

Together these say: a family owns *one number* beyond the shared profile — where it
sits on the scale axis.  The chain itself is not per-family, but the offset is; the
discrete-only reading is too coarse (it cannot express fractional offsets such as
the 3B model's `≈ 1.45`) and the "one universal table" reading is too strong.
-/

namespace Tropical.ScaleFlowFamilyRate

open Tropical.ScaleFlowSweep Combinatorics.OctaveShiftLaw

/-- **Offset conjugacy.**  Two clamped-affine tables with the same base knee and
rate are translates of one another along the flow direction `(1,1)`: the only
freedom a family has, once the profile is fixed, is *where it sits* on the scale
axis. -/
theorem kstar_offset_conjugacy (k0 delta a h t : ℝ) :
    kstar k0 delta (a + h) (t + h) = kstar k0 delta a t := by
  simp only [kstar]
  ring_nf

/-- **The keys-per-octave rate is a flow invariant.**  If two clamped-affine knee
tables agree at every real context, their base knees, their rates and their scale
offsets coincide.  No re-gauging of the scale axis can convert one rate into
another: a measured `δ` is data, not a fitting convention. -/
theorem kstar_rate_identifiable {k0 k0' d d' a b : ℝ} (hd' : 0 < d')
    (h : ∀ t : ℝ, kstar k0 d a t = kstar k0' d' b t) : k0 = k0' ∧ d = d' ∧ a = b := by
  set M := max a b with hM
  have haM : a ≤ M := le_max_left _ _
  have hbM : b ≤ M := le_max_right _ _
  have hmin_le_a : min a b ≤ a := min_le_left _ _
  have hmin_le_b : min a b ≤ b := min_le_right _ _
  -- base knees agree, read off below both clamps
  have hk : k0 = k0' := by
    have := h (min a b)
    rwa [kstar_of_le hmin_le_a, kstar_of_le hmin_le_b] at this
  -- two readings above both clamps identify the rate
  have h1 := h M
  have h2 := h (M + 1)
  rw [kstar_of_ge haM, kstar_of_ge hbM] at h1
  rw [kstar_of_ge (by linarith : a ≤ M + 1), kstar_of_ge (by linarith : b ≤ M + 1)] at h2
  have hrate : d = d' := by nlinarith
  refine ⟨hk, hrate, ?_⟩
  rw [hk, hrate] at h1
  have : d' * (M - a) = d' * (M - b) := by linarith
  have := mul_left_cancel₀ (ne_of_gt hd') this
  linarith

/-- **The measured rate is forced.**  Any clamped-affine family reproducing the
NET-66 cells `k*(0.5B, 512) = 16` and `k*(0.5B, 1024) = 20` at scale offset `0` has
base knee `16` and rate `4` keys per octave — the value the discrete theory
measured, now pinned inside the continuous family. -/
theorem net66_rate_forced {k0 d : ℝ}
    (h0 : kstar k0 d 0 0 = 16) (h1 : kstar k0 d 0 1 = 20) : k0 = 16 ∧ d = 4 := by
  rw [kstar_of_le (le_refl 0)] at h0
  rw [kstar_of_ge (by norm_num : (0:ℝ) ≤ 1)] at h1
  constructor
  · exact h0
  · rw [h0] at h1; linarith

/-- **Consistency of the two readings.**  The continuous family with the forced
parameters restricts, at integer scale offsets, exactly to the measured discrete
NET-66 table — so "one profile plus a per-family offset" reproduces every cell the
discrete theory recorded. -/
theorem net66_forced_restricts (s j : ℕ) :
    kstar 16 4 (s : ℝ) (j : ℝ) = (net66.chain s j : ℝ) := kstar_restricts s j

/-- **The offset can be fractional.**  The 3B scale offset is strictly between the
two measured integer offsets, so the family freedom is genuinely real-valued: no
integer offset reproduces the 3B table. -/
theorem offset_strictly_fractional :
    1 < scaleIndex 3 ∧ scaleIndex 3 < 2 ∧ ∀ s : ℕ, (s : ℝ) ≠ scaleIndex 3 := by
  obtain ⟨hlo, hhi⟩ := scaleIndex_3B_bounds
  refine ⟨by linarith, by linarith, fun s hs => ?_⟩
  rcases le_or_gt s 1 with hle | hgt
  · have : (s : ℝ) ≤ 1 := by exact_mod_cast hle
    linarith
  · have : (2 : ℝ) ≤ (s : ℝ) := by exact_mod_cast hgt
    linarith

end Tropical.ScaleFlowFamilyRate