/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# The Discrete Hodge Laplacian, its Harmonic Space, and Diffusion Message Passing

This file gives a **self-contained Mathlib foundation** for the discrete Hodge program.
It works with a two-step cochain complex of finite-dimensional real inner-product spaces

    U --e--> V --d--> W

and studies the *Hodge Laplacian* on the middle space `V`,

    Δ = d* ∘ d + e ∘ e*,

where `d* = LinearMap.adjoint d` and `e* = LinearMap.adjoint e`.

The single organizing identity is the sum-of-squares **Dirichlet energy**

    ⟪Δ x, x⟫ = ‖d x‖² + ‖e* x‖²,

from which everything else follows:

* the harmonic space `ker Δ` is exactly the *closed-and-co-closed* cochains
  (`d x = 0 ∧ e* x = 0`);
* the Rayleigh quadratic form is strictly positive off `ker Δ`;
* `Δ` is self-adjoint, so its image lands in `(ker Δ)ᗮ`.

On the dynamical side, the explicit-Euler **diffusion step** `S = id − a·Δ`
fixes the harmonic space pointwise and *conserves the harmonic projection* along the
whole trajectory, `P (Sᵏ x) = P x`: diffusion never creates or destroys the
topological (harmonic) component, it only relaxes the exact / co-exact part.

This file is deliberately independent of the rest of the catalog (it imports only
Mathlib), repairing the previously non-elaborating `Hodge*` stack.

-- !-- Lab Notebook -- !--
Hypothesis:  For the two-step complex `U → V → W`, the Hodge Laplacian
  `Δ = d*d + e e*` should satisfy the Dirichlet identity `⟪Δx,x⟫ = ‖dx‖² + ‖e*x‖²`,
  which simultaneously makes `Δ` positive semidefinite, identifies its kernel with the
  closed-&-co-closed cochains, and (via self-adjointness) forces `range Δ ⊆ (ker Δ)ᗮ`.
  The diffusion step `S = id − aΔ` should then fix harmonics and conserve the harmonic
  projection at every depth.
Result:  Formalised and proved sorry-free.  `hodgeLap_isSymmetric` (self-adjoint),
  `hodgeLap_quadratic_form` (the Dirichlet identity), `hodgeLap_apply_eq_zero_iff`
  (harmonic ⇔ closed & co-closed), `hodgeLap_quadratic_eq_zero_iff` (strict positivity
  off the kernel), `hodgeLap_apply_mem_orthogonal_ker` (`Δx ⊥ ker Δ`),
  `diffStep_harmonic_fixed` / `diffStep_pow_harmonic_fixed` (harmonics are fixed at
  every depth), and `harmonicProjection_diffStep` / `harmonicProjection_diffStep_pow`
  (the harmonic projection is conserved along diffusion).
Insight:  Every analytic fact is a one-line consequence of the two adjunction lemmas
  `adjoint_inner_left/right` once the energy is written as a sum of squares; the
  dynamical facts then need only linearity of `Δ` and of the orthogonal projection,
  plus the symmetry-driven inclusion `Δx ∈ (ker Δ)ᗮ`.
Failure analysis:  Working with the inner-product energy `⟪v,v⟫` rather than `‖v‖`
  avoids `Real.sqrt`; phrasing the kernel characterisation through the quadratic form
  (`⟪Δx,x⟫ = 0 ↔ Δx = 0`) sidesteps any explicit eigenvalue bookkeeping.
-- !-- Lab Notebook -- !--
-/
import Mathlib

open scoped InnerProductSpace BigOperators

namespace HodgeLaplacianGreen

variable {U V W : Type*}
  [NormedAddCommGroup U] [InnerProductSpace ℝ U] [FiniteDimensional ℝ U]
  [NormedAddCommGroup V] [InnerProductSpace ℝ V] [FiniteDimensional ℝ V]
  [NormedAddCommGroup W] [InnerProductSpace ℝ W] [FiniteDimensional ℝ W]

/-- The discrete **Hodge Laplacian** of the two-step complex `U --e--> V --d--> W`,
acting on the middle space `V` by `Δ = d* ∘ d + e ∘ e*`. -/
noncomputable def hodgeLap (e : U →ₗ[ℝ] V) (d : V →ₗ[ℝ] W) : V →ₗ[ℝ] V :=
  LinearMap.adjoint d ∘ₗ d + e ∘ₗ LinearMap.adjoint e

variable (e : U →ₗ[ℝ] V) (d : V →ₗ[ℝ] W)

@[simp] theorem hodgeLap_apply (x : V) :
    hodgeLap e d x = LinearMap.adjoint d (d x) + e (LinearMap.adjoint e x) := by
  simp [hodgeLap]

/-
!-- comment: Expand `Δ` and move each summand across the relevant adjunction
(`adjoint_inner_left/right`) to land symmetrically on `x` and `y`. -- !--

The Hodge Laplacian is **self-adjoint**: `⟪Δ x, y⟫ = ⟪x, Δ y⟫`.
-/
theorem hodgeLap_isSymmetric : (hodgeLap e d).IsSymmetric := by
  intro x y;
  simp +decide only [hodgeLap, LinearMap.add_apply, LinearMap.comp_apply, inner_add_left,
      LinearMap.adjoint_inner_left];
  rw [ inner_add_right, LinearMap.adjoint_inner_right ];
  simp +decide [ ← LinearMap.adjoint_inner_left ]

/-
!-- comment: `⟪d*(dx),x⟫ = ⟪dx,dx⟫` and `⟪e(e*x),x⟫ = ⟪e*x,e*x⟫` by the two
adjunction lemmas; rewrite `⟪v,v⟫` as `‖v‖²`. -- !--

The **Dirichlet energy / Rayleigh quotient** is a sum of squares:
`⟪Δ x, x⟫ = ‖d x‖² + ‖e* x‖²`.
-/
theorem hodgeLap_quadratic_form (x : V) :
    (⟪hodgeLap e d x, x⟫_ℝ) = ‖d x‖ ^ 2 + ‖LinearMap.adjoint e x‖ ^ 2 := by
  have h1 : ⟪LinearMap.adjoint d (d x), x⟫_ℝ = ‖d x‖ ^ 2 := by
    rw [LinearMap.adjoint_inner_left, real_inner_self_eq_norm_sq]
  have h2 : ⟪e (LinearMap.adjoint e x), x⟫_ℝ = ‖LinearMap.adjoint e x‖ ^ 2 := by
    rw [← LinearMap.adjoint_inner_right, real_inner_self_eq_norm_sq]
  simp only [hodgeLap, LinearMap.add_apply, LinearMap.comp_apply, inner_add_left, h1, h2]

/-
!-- comment: From the sum-of-squares form, `⟪Δx,x⟫ = 0` forces both squares to vanish;
conversely if both vanish then `Δx = 0`.  Combine with the quadratic-eq-zero lemma. -- !--

**Harmonic ⇔ closed & co-closed**: `Δ x = 0 ↔ d x = 0 ∧ e* x = 0`.
-/
theorem hodgeLap_apply_eq_zero_iff (x : V) :
    hodgeLap e d x = 0 ↔ d x = 0 ∧ LinearMap.adjoint e x = 0 := by
  by_cases h₁ : d x = 0 <;> simp_all +decide [ hodgeLap ];
  · constructor <;> intro h <;> have := LinearMap.adjoint_inner_right e ( LinearMap.adjoint e x ) x <;> simp_all +decide [ inner_self_eq_norm_sq_to_K ];
  · contrapose! h₁; have := hodgeLap_quadratic_form e d x; simp_all +decide;
    exact norm_eq_zero.mp ( by nlinarith )

/-
!-- comment: `⟪Δx,x⟫ = ‖dx‖²+‖e*x‖² = 0 ↔ dx = 0 ∧ e*x = 0 ↔ Δx = 0`
(strict positivity of the Rayleigh form off the kernel). -- !--

**Strict positivity off the kernel**: the Rayleigh form vanishes only on harmonics,
`⟪Δ x, x⟫ = 0 ↔ Δ x = 0`.
-/
theorem hodgeLap_quadratic_eq_zero_iff (x : V) :
    (⟪hodgeLap e d x, x⟫_ℝ) = 0 ↔ hodgeLap e d x = 0 := by
  convert ( hodgeLap_apply_eq_zero_iff e d x ) |> Iff.symm using 1;
  rw [ hodgeLap_quadratic_form ];
  exact ⟨ fun h => ⟨ norm_eq_zero.mp ( by nlinarith ), norm_eq_zero.mp ( by nlinarith ) ⟩, fun h => by simp +decide [ h ] ⟩

/-
!-- comment: For `h ∈ ker Δ`, `⟪h, Δx⟫ = ⟪Δh, x⟫ = 0` by self-adjointness, so
`Δx ⊥ ker Δ`. -- !--

**Image lands in the orthogonal complement of the kernel**: `Δ x ∈ (ker Δ)ᗮ`.
-/
theorem hodgeLap_apply_mem_orthogonal_ker (x : V) :
    hodgeLap e d x ∈ (LinearMap.ker (hodgeLap e d))ᗮ := by
  intro y hy;
  convert congr_arg ( fun z => ⟪z, x⟫_ℝ ) hy using 1;
  · rw [ hodgeLap_isSymmetric ];
  · simp +decide

/-! ## Diffusion message passing -/

/-- One explicit-Euler **diffusion step** `S = id − a·Δ`, as a linear endomorphism of
`V`, so that iterating it (`S ^ k`) is automatically linear. -/
noncomputable def diffStep (a : ℝ) : V →ₗ[ℝ] V :=
  LinearMap.id - a • hodgeLap e d

@[simp] theorem diffStep_apply (a : ℝ) (x : V) :
    diffStep e d a x = x - a • hodgeLap e d x := by
  simp [diffStep]

/-- The **harmonic projection** `P`: orthogonal projection onto the harmonic space
`ker Δ`. -/
noncomputable def harmonicProjection : V →L[ℝ] (LinearMap.ker (hodgeLap e d)) :=
  (LinearMap.ker (hodgeLap e d)).orthogonalProjection

/-
!-- comment: If `Δh = 0` then `S h = h − a•0 = h`. -- !--

Harmonic cochains are **fixed points** of a diffusion step.
-/
theorem diffStep_harmonic_fixed (a : ℝ) {h : V} (hh : hodgeLap e d h = 0) :
    diffStep e d a h = h := by
  unfold diffStep; aesop;

/-
!-- comment: Iterate `diffStep_harmonic_fixed` over depth `k` by induction
(`pow_succ'`). -- !--

Harmonic cochains are fixed at **every depth** of diffusion.
-/
theorem diffStep_pow_harmonic_fixed (a : ℝ) {h : V} (hh : hodgeLap e d h = 0) (k : ℕ) :
    ((diffStep e d a) ^ k) h = h := by
  induction' k with k ih;
  · rfl;
  · rw [ pow_succ', Module.End.mul_apply, ih, diffStep_harmonic_fixed e d a hh ]

/-
!-- comment: `S x = x − a•Δx` and `Δx ∈ (ker Δ)ᗮ`, so projecting kills the second
term: `P(Sx) = Px − a•P(Δx) = Px`. -- !--

**Conservation of the harmonic projection** under one diffusion step:
`P (S x) = P x`.
-/
theorem harmonicProjection_diffStep (a : ℝ) (x : V) :
    harmonicProjection e d (diffStep e d a x) = harmonicProjection e d x := by
  have h_orthogonal : ∀ (v : V), v ∈ (LinearMap.ker (hodgeLap e d))ᗮ → (harmonicProjection e d) v = 0 := by
    simp +decide [ harmonicProjection ];
  rw [ diffStep_apply, map_sub, map_smul, h_orthogonal _ ( hodgeLap_apply_mem_orthogonal_ker e d x ), smul_zero, sub_zero ]

/-
!-- comment: Induct on depth using the single-step conservation
`harmonicProjection_diffStep`. -- !--

**Conservation of the harmonic projection along the whole trajectory**:
`P (Sᵏ x) = P x`.
-/
theorem harmonicProjection_diffStep_pow (a : ℝ) (x : V) (k : ℕ) :
    harmonicProjection e d (((diffStep e d a) ^ k) x) = harmonicProjection e d x := by
  induction' k with k ih;
  · rfl;
  · convert harmonicProjection_diffStep e d a ( ( diffStep e d a ^ k ) x ) using 1;
    · exact congr_arg _ ( by rw [ pow_succ', Module.End.mul_apply ] );
    · exact ih.symm

end HodgeLaplacianGreen