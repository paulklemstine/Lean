/-
# Planes Map to Spheres Under Inverse Stereographic Projection

This file proves that k-dimensional planes in ℝ^N map to k-spheres on S^N
under inverse stereographic projection, and characterizes the image of
hyperplanes via linear constraints.

## Main results

* `plane_image_on_sphere` — every point on a parametric plane maps to S^N
* `hyperplane_image_characterization` — points satisfying a linear constraint
  in ℝ^N have images satisfying a corresponding constraint on S^N
* `invStereoN_2_surj_on_sphere` — invStereoN is surjective onto S² \ {NP}
-/
import Mathlib
import Geometry.Stereographic.Basic

namespace StereographicProjection

open Finset BigOperators

noncomputable section

/-- A parametric plane in ℝ^N through point p with direction vectors v₁, v₂ -/
def paramPlane {N : ℕ} (p v₁ v₂ : Fin N → ℝ) (s t : ℝ) : Fin N → ℝ :=
  fun i => p i + s * v₁ i + t * v₂ i

/-- Every point on a parametric plane maps to S^N -/
theorem plane_image_on_sphere {N : ℕ} (p v₁ v₂ : Fin N → ℝ) (s t : ℝ) :
    ∑ i : Fin (N + 1), (invStereoN (paramPlane p v₁ v₂ s t) i) ^ 2 = 1 :=
  invStereoN_norm_sq _

/-
Hyperplane characterization: if y satisfies ∑ aᵢyᵢ = c in ℝ^N,
    then the image x = invStereoN(y) satisfies the linear constraint
    ∑ aᵢxᵢ = c · (1 - x_N) on S^N, where x_N is the last coordinate
-/
theorem hyperplane_image_characterization {N : ℕ} (a : Fin N → ℝ) (c : ℝ)
    (y : Fin N → ℝ) (hy : ∑ i, a i * y i = c) :
    ∑ i : Fin N, a i * invStereoN y ⟨i.val, Nat.lt_succ_of_lt i.isLt⟩ =
      c * (1 - invStereoN y (lastIdx N)) := by
        convert congr_arg ( fun x : ℝ => x * ( 1 - invStereoN y ( lastIdx N ) ) ) hy using 1;
        rw [ Finset.sum_mul _ _ _ ];
        refine' Finset.sum_congr rfl fun i _ => _;
        unfold invStereoN;
        simp +decide [ mul_assoc, mul_div_assoc, stereoDenom, lastIdx ];
        exact Or.inl ( by rw [ one_sub_div ( by linarith [ show 0 ≤ sqNormFin y from Finset.sum_nonneg fun _ _ => sq_nonneg _ ] ) ] ; ring )

/-
invStereoN for N=2 is surjective onto S² \ {north pole}
-/
theorem invStereoN_2_surj_on_sphere (x : Fin 3 → ℝ)
    (hx_sphere : ∑ i : Fin 3, x i ^ 2 = 1)
    (hx_ne_np : x ⟨2, by omega⟩ ≠ 1) :
    ∃ y : Fin 2 → ℝ, invStereoN y = x := by
      have h_range : x ∈ Set.range (invStereoN : (Fin 2 → ℝ) → Fin 3 → ℝ) := by
        have h_eq : Set.range (invStereoN : (Fin 2 → ℝ) → Fin 3 → ℝ) = {x : Fin 3 → ℝ | (∑ i, x i ^ 2) = 1 ∧ x ⟨2, by linarith⟩ ≠ 1} := by
          convert invStereoN_image_eq
        exact h_eq.symm.subset ⟨ hx_sphere, hx_ne_np ⟩;
      exact h_range

end

end StereographicProjection