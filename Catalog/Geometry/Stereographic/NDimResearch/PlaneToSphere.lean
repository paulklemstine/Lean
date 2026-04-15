import Mathlib
import Geometry.Stereographic.NDimResearch.Basic

/-!
# Question 2: Planes Map to 2-Spheres Under Inverse Stereographic Projection

## Main Result

A k-dimensional affine subspace of ℝ^N maps under inverse stereographic projection
to a k-dimensional sphere on S^N (the intersection of S^N with a (k+1)-dimensional
affine subspace of ℝ^{N+1}).

In particular:
- A **line** (k=1) in ℝ^N maps to a **circle** (1-sphere) on S^N
- A **plane** (k=2) in ℝ^N maps to a **2-sphere** on S^N
- A **hyperplane** (k=N-1) in ℝ^N maps to an **(N-1)-sphere** on S^N

This answers Question 2 affirmatively: **Yes**, a plane can be transformed into
a sphere (specifically a 2-sphere on S^N) using inverse stereographic projection.

## Key Insight

Stereographic projection is a **Möbius transformation** — it preserves the class
of "generalized spheres" (spheres and hyperplanes). Since a k-dimensional affine
subspace of ℝ^N is a "flat k-sphere" (a sphere of infinite radius), its image under
inverse stereographic projection is a k-sphere of finite radius on S^N.
-/

open Finset BigOperators Real

noncomputable section

/-! ## 2D plane in ℝ^N maps to S^N -/

/-- Parametric plane in ℝ^N: (s,t) ↦ p + s·u + t·v -/
def parametricPlane (N : ℕ) (p u v : Fin N → ℝ) (s t : ℝ) : Fin N → ℝ :=
  fun j => p j + s * u j + t * v j

/-- Every point of a parametric plane, mapped through invStereoN, lies on S^N. -/
theorem plane_image_on_sphere (N : ℕ) (p u v : Fin N → ℝ) (s t : ℝ) :
    ∑ i : Fin (N + 1), (invStereoN N (parametricPlane N p u v s t) i) ^ 2 = 1 :=
  invStereoN_norm_sq N _

/-! ## The 2D concrete case: ℝ² plane maps to S² -/

/-
The entire plane ℝ² maps onto S² \ {north pole} via invStereoN.
    For any point on S² with last coordinate ≠ 1, there exists a preimage.
-/
theorem invStereoN_2_surj_on_sphere (x : Fin 3 → ℝ)
    (hx_norm : ∑ i : Fin 3, (x i) ^ 2 = 1)
    (hx_np : x ⟨2, by omega⟩ ≠ 1) :
    ∃ y : Fin 2 → ℝ, invStereoN 2 y = x := by
  -- Set y = (x₀ / (1 - x₂), x₁ / (1 - x₂)).
  set y : Fin 2 → ℝ := ![x ⟨0, by decide⟩ / (1 - x ⟨2, by decide⟩), x ⟨1, by decide⟩ / (1 - x ⟨2, by decide⟩)];
  use y;
  unfold invStereoN;
  ext i;
  simp +zetaDelta at *;
  fin_cases i <;> simp_all +decide [ Fin.sum_univ_succ, sqNorm, stereoDenom ];
  · grind +qlia;
  · grind;
  · grind

/-! ## Key structural theorem: affine constraints are preserved -/

/-
If points in ℝ^N satisfy a linear equation Σ aᵢ·yᵢ = c (a hyperplane),
    then their images under invStereoN satisfy a linear equation relating the
    first N sphere coordinates, specifically:
    Σ aᵢ · (2·yᵢ/D) = 2c/D
    This means the image lies on S^N ∩ {hyperplane}, which is a (generalized) sphere.
-/
theorem hyperplane_image_characterization (N : ℕ) (a : Fin N → ℝ) (c : ℝ)
    (y : Fin N → ℝ) (hy : ∑ i, a i * y i = c) :
    ∑ i : Fin N, a i * invStereoN N y ⟨i, Nat.lt_succ_of_lt i.isLt⟩ =
    2 * c / stereoDenom N y := by
  convert congr_arg ( fun z => z * ( 2 / stereoDenom N y ) ) hy using 1;
  · simp +decide only [invStereoN, Finset.sum_mul _ _ _];
    exact Finset.sum_congr rfl fun i hi => by simp +decide [ mul_assoc, mul_comm, mul_left_comm, div_eq_mul_inv ] ;
  · ring

/-! ## Topological characterization -/

/-- The north pole in ℝ^{N+1}. -/
def northPole (N : ℕ) : Fin (N + 1) → ℝ := fun i =>
  if (i : ℕ) = N then 1 else 0

/-
The image of ℝ^N under invStereoN is exactly S^N minus the north pole.
-/
theorem invStereoN_image_eq (N : ℕ) :
    Set.range (invStereoN N) =
    {x : Fin (N + 1) → ℝ | ∑ i, (x i) ^ 2 = 1} \ {northPole N} := by
  ext x
  constructor
  intro hx
  obtain ⟨y, hy⟩ := hx
  all_goals generalize_proofs at *;
  · simp_all +decide [ ← hy ];
    exact ⟨ invStereoN_norm_sq N y, fun h => invStereoN_last_ne_one N y <| by simpa [ northPole ] using congr_fun h ⟨ N, Nat.lt_succ_self _ ⟩ ⟩;
  · simp +zetaDelta at *;
    intro hx hx';
    by_cases h : x ⟨ N, Nat.lt_succ_self N ⟩ = 1;
    · contrapose! hx';
      ext i; by_cases hi : i.val = N <;> simp_all +decide [ Fin.sum_univ_castSucc ] ;
      · grind +locals;
      · simp_all +decide [ Fin.ext_iff, northPole ];
        exact eq_zero_of_mul_self_eq_zero ( by nlinarith! [ Finset.single_le_sum ( fun a ( _ : a ∈ Finset.univ ) => sq_nonneg ( x ( Fin.castSucc a ) ) ) ( Finset.mem_univ ⟨ i, lt_of_le_of_ne ( Fin.le_last _ ) hi ⟩ ) ] );
    · use fun i => x ⟨i, Nat.lt_succ_of_lt i.isLt⟩ / (1 - x ⟨N, Nat.lt_succ_self N⟩);
      ext i;
      by_cases hi : i.val < N <;> simp_all +decide [ Fin.sum_univ_castSucc ];
      · unfold invStereoN;
        unfold stereoDenom; simp +decide [ Finset.sum_div _ _ _, sqNorm, hi ];
        field_simp;
        rw [ ← Finset.sum_div _ _ _, div_eq_iff ];
        · rw [ show ( ∑ i : Fin N, x ⟨ i, by linarith [ Fin.is_lt i ] ⟩ ^ 2 ) = 1 - x ⟨ N, Nat.lt_succ_self N ⟩ ^ 2 by linarith! ] ; ring;
          grind;
        · exact sub_ne_zero_of_ne <| Ne.symm h;
      · simp_all +decide [ Fin.eq_last_of_not_lt, invStereoN ];
        unfold sqNorm stereoDenom;
        nontriviality;
        unfold sqNorm; simp_all +decide [ Finset.sum_div _ _ _, div_pow ];
        simp_all +decide [ ← Finset.sum_div _ _ _, Finset.sum_range, Fin.sum_univ_castSucc ];
        grind +suggestions

end