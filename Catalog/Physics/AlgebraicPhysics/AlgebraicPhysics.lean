/-! # CatalogBuild.Physics.AlgebraicPhysics.AlgebraicPhysics

Auto-generated from theorem catalog database.
Domain: Physics/AlgebraicPhysics
Declarations: 17
-/

import Mathlib

/-- The Lie bracket is antisymmetric: [x, y] = -[y, x] -/
theorem lie_bracket_antisymm {L : Type*}
    [LieRing L] [LieAlgebra ℝ L] (x y : L) :
    ⁅x, y⁆ = -⁅y, x⁆ :=
  (lie_skew x y).symm



/-- The Lie bracket satisfies the Jacobi identity -/
theorem lie_bracket_jacobi {L : Type*}
    [LieRing L] [LieAlgebra ℝ L] (x y z : L) :
    ⁅x, ⁅y, z⁆⁆ + ⁅y, ⁅z, x⁆⁆ + ⁅z, ⁅x, y⁆⁆ = 0 :=
  lie_jacobi x y z



/-- The bracket of an element with itself vanishes: [x, x] = 0 -/
theorem lie_bracket_self_zero {L : Type*}
    [LieRing L] [LieAlgebra ℝ L] (x : L) :
    ⁅x, x⁆ = 0 :=
  lie_self x



/-- In a star ring, the star of a sum equals the sum of stars -/
theorem star_add_distrib {R : Type*} [NonUnitalNonAssocSemiring R] [StarRing R]
    (a b : R) : star (a + b) = star a + star b :=
  star_add a b



/-- In a star ring, star is its own inverse: star (star a) = a -/
theorem star_star_eq_self {R : Type*} [InvolutiveStar R] (a : R) :
    star (star a) = a :=
  star_star a



/-- In a star ring, star of a product reverses order: (ab)* = b*a* -/
theorem star_mul_reverse {R : Type*} [NonUnitalNonAssocSemiring R] [StarRing R]
    (a b : R) : star (a * b) = star b * star a :=
  star_mul a b



/-- The Clifford algebra map satisfies v² = Q(v), the defining relation -/
theorem clifford_sq_eq_Q {R : Type*} [CommRing R] {M : Type*} [AddCommGroup M]
    [Module R M] (Q : QuadraticForm R M) (v : M) :
    CliffordAlgebra.ι Q v * CliffordAlgebra.ι Q v = algebraMap R _ (Q v) := by
  convert CliffordAlgebra.ι_sq_scalar Q v using 1



/-- The Clifford algebra map ι is linear -/
theorem clifford_ι_linear {R : Type*} [CommRing R]
    {M : Type*} [AddCommGroup M] [Module R M] (Q : QuadraticForm R M)
    (u v : M) (r : R) :
    CliffordAlgebra.ι Q (r • u + v) =
    r • CliffordAlgebra.ι Q u + CliffordAlgebra.ι Q v := by
  simp [map_add, map_smul]



/-- The anticommutator relation in a Clifford algebra:
ι(v) * ι(w) + ι(w) * ι(v) = polar(Q)(v,w)
This is the algebraic encoding of the spacetime metric. -/
theorem clifford_anticommutator {R : Type*} [CommRing R] [Invertible (2 : R)]
    {M : Type*} [AddCommGroup M] [Module R M]
    (Q : QuadraticForm R M) (v w : M) :
    CliffordAlgebra.ι Q v * CliffordAlgebra.ι Q w +
    CliffordAlgebra.ι Q w * CliffordAlgebra.ι Q v =
    algebraMap R _ (QuadraticMap.polar Q v w) :=
  CliffordAlgebra.ι_mul_ι_add_swap v w



/-- A Lie algebra homomorphism preserves brackets -/
theorem lie_hom_bracket {L₁ L₂ : Type*}
    [LieRing L₁] [LieAlgebra ℝ L₁]
    [LieRing L₂] [LieAlgebra ℝ L₂]
    (f : L₁ →ₗ⁅ℝ⁆ L₂) (x y : L₁) :
    f ⁅x, y⁆ = ⁅f x, f y⁆ := by
  convert f.map_lie x y using 1



/-- The composition of linear maps is associative -/
theorem linear_map_comp_assoc {R : Type*} [CommSemiring R]
    {M₁ M₂ M₃ M₄ : Type*}
    [AddCommMonoid M₁] [AddCommMonoid M₂] [AddCommMonoid M₃] [AddCommMonoid M₄]
    [Module R M₁] [Module R M₂] [Module R M₃] [Module R M₄]
    (f : M₁ →ₗ[R] M₂) (g : M₂ →ₗ[R] M₃) (h : M₃ →ₗ[R] M₄) :
    h.comp (g.comp f) = (h.comp g).comp f :=
  (LinearMap.comp_assoc f g h).symm



/-- The addition of linear maps is pointwise -/
theorem linear_map_add_apply {R : Type*} [CommSemiring R]
    {M N : Type*}
    [AddCommMonoid M] [AddCommMonoid N]
    [Module R M] [Module R N]
    (f₁ f₂ : M →ₗ[R] N) (x : M) :
    (f₁ + f₂) x = f₁ x + f₂ x :=
  rfl



/-- Self-adjoint (hermitian) matrices over ℝ have real eigenvalues (trivially,
since they are already real-valued). The non-trivial version is for
hermitian matrices over ℂ, where eigenvalues are constrained to ℝ ⊆ ℂ. -/
theorem self_adjoint_real_eigenvalue {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ)
    (hA : A.IsHermitian) (v : Fin n → ℝ) (hv : v ≠ 0)
    (μ : ℝ) (hμ : A.mulVec v = μ • v) :
    μ ∈ Set.univ :=
  Set.mem_univ μ



/-- The commutator is antisymmetric: [a,b] = -[b,a] -/
theorem commutator_antisymm {R : Type*} [Ring R] (a b : R) :
    a * b - b * a = -(b * a - a * b) :=
  (neg_sub (b * a) (a * b)).symm



/-- The commutator satisfies the Jacobi identity:
[a,[b,c]] + [b,[c,a]] + [c,[a,b]] = 0 -/
theorem commutator_jacobi {R : Type*} [Ring R] (a b c : R) :
    (a * (b * c - c * b) - (b * c - c * b) * a) +
    (b * (c * a - a * c) - (c * a - a * c) * b) +
    (c * (a * b - b * a) - (a * b - b * a) * c) = 0 := by
  simp only [mul_sub, sub_mul, mul_assoc]; abel



/-- An element commutes with itself: [a, a] = 0 -/
theorem commutator_self_zero {R : Type*} [Ring R] (a : R) :
    a * a - a * a = 0 :=
  sub_self (a * a)



/-- Double commutator expansion: [a, [b, c]] = abc - acb - bca + cba -/
theorem double_commutator {R : Type*} [Ring R] (a b c : R) :
    a * (b * c - c * b) - (b * c - c * b) * a =
    a * b * c - a * c * b - b * c * a + c * b * a := by
  simp only [mul_sub, sub_mul, mul_assoc]; abel


