import Mathlib

/-! # CatalogBuild.Algebra.DivisionAlgebras.GeometricAlgebra

Auto-generated from theorem catalog database.
Domain: Algebra/DivisionAlgebras
Declarations: 6
-/


/-- [Section: # CatalogBuild.Algebra.DivisionAlgebras.GeometricAlgebra
Auto-generated from theorem catalog database.
Domain: Algebra/DivisionAlgebras
Declarations: 6] -/
theorem dist_symm_real (x y : ℝ) : dist x y = dist y x := by
  exact dist_comm x y




/-- [Section: # CatalogBuild.Algebra.DivisionAlgebras.GeometricAlgebra
Auto-generated from theorem catalog database.
Domain: Algebra/DivisionAlgebras
Declarations: 6] -/
theorem triangle_ineq_R2 (a b c : EuclideanSpace ℝ (Fin 2)) :
    dist a c ≤ dist a b + dist b c := by
      exact dist_triangle _ _ _




theorem rotation_det_one (θ : ℝ) :
    Matrix.det !![Real.cos θ, -Real.sin θ; Real.sin θ, Real.cos θ] = 1 := by
      norm_num [ Real.cos_sq' ];
      rw [ ← sq, ← sq, Real.cos_sq_add_sin_sq ]




theorem rotation_compose (α β : ℝ) :
    !![Real.cos α, -Real.sin α; Real.sin α, Real.cos α] *
    !![Real.cos β, -Real.sin β; Real.sin β, Real.cos β] =
    !![Real.cos (α + β), -Real.sin (α + β); Real.sin (α + β), Real.cos (α + β)] := by
      ext i j ; fin_cases i <;> fin_cases j <;> simpa [ Real.cos_add, Real.sin_add ] using by ring;




theorem isometry_preserves_dist {X Y : Type*} [PseudoMetricSpace X] [PseudoMetricSpace Y]
    (f : X → Y) (hf : Isometry f) (a b : X) :
    dist (f a) (f b) = dist a b := by
      exact hf.dist_eq a b ▸ rfl




theorem isometry_comp {X Y Z : Type*} [PseudoMetricSpace X] [PseudoMetricSpace Y]
    [PseudoMetricSpace Z] (f : X → Y) (g : Y → Z) (hf : Isometry f) (hg : Isometry g) :
    Isometry (g ∘ f) := by
      exact?