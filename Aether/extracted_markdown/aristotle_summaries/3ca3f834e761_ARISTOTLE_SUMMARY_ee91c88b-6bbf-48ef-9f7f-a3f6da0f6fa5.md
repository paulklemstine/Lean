# Summary of changes
## The Omega Point is "Infinity" in Inverse Stereographic Projection

Created `core/Stereographic/OmegaPoint.lean` with a complete formalization and proof of the theorem that the Omega point (north pole) is "infinity" in inverse stereographic projection.

### What was formalized

Working with the unit circle S¹ ⊂ ℝ² and the inverse stereographic projection `circleStereographicInv(t) = (2t/(t²+1), (t²-1)/(t²+1))`, we define the **Omega point** as the north pole `(0, 1)` and prove:

1. **`omegaPoint_not_in_range`**: The north pole (0,1) is *not* in the image of the inverse stereographic projection — no finite value of t maps to the Omega point. This is the geometric analogue of Tarski's indefinability theorem: Ω sits above the entire hierarchy and cannot be reached from within it.

2. **`omega_point_is_infinity_atTop`**: As t → +∞, `circleStereographicInv t → (0, 1)`. The Omega point is the limit of the inverse projection at positive infinity.

3. **`omega_point_is_infinity_atBot`**: As t → −∞, `circleStereographicInv t → (0, 1)`. Both ends of ℝ converge to the same point — infinity has no sign on the circle.

4. **`omega_point_is_infinity_cocompact`**: As |t| → ∞ (cocompact filter), the inverse projection converges to the Omega point. This unifies the atTop and atBot results.

Supporting lemmas include `circleStereographicInv_fst_tendsto_zero` and `circleStereographicInv_snd_tendsto_one` for the individual coordinates.

### Verification

- All proofs compile with no `sorry` statements remaining.
- All axioms are standard (`propext`, `Classical.choice`, `Quot.sound`).
- The file documents the connection between the geometric Omega point and the Oracle hierarchy concept from Section 4.3.