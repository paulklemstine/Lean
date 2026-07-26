import Mathlib

/-!
# Split geometry on `ℝ²` — the manifold and the metric tensor

This file sets up the *split geometry* studied in this development.  The underlying
manifold is `M := ℝ × ℝ` with its standard smooth structure.  On it we place the
Riemannian metric
$$ g \;=\; \frac{dx \otimes dx}{\cosh^2 y} \;+\; \cosh^2 x \; dy \otimes dy , $$
i.e. the metric whose component matrix in the global coordinates `(x, y)` is the
diagonal matrix `diag (sech²  y, cosh²  x)`.

We record:

* `SplitGeometry.M` — the manifold, a smooth manifold via the standard instance for a
  finite dimensional real normed space;
* `SplitGeometry.Emet`, `SplitGeometry.Gmet` — the two metric coefficients
  `E(p) = sech²(y)` and `G(p) = cosh²(x)`;
* `SplitGeometry.gForm` — the metric as a bilinear form on tangent vectors
  (tangent vectors to `ℝ²` are again elements of `ℝ²`);
* positivity of the coefficients, symmetry and **positive definiteness** of `g`;
* **smoothness** of the coefficients (`ContDiff ℝ ⊤`), hence smoothness of `g`.

All statements here are true as literally stated for the metric in the problem.
-/

namespace SplitGeometry

open Real

/-- The manifold `M := ℝ × ℝ` with global coordinates `(x, y) = (p.1, p.2)`. -/
abbrev M : Type := ℝ × ℝ

open scoped Manifold in
/-- `M` is a smooth (`C^∞`) manifold with the standard model on `ℝ²`. -/
example : IsManifold (𝓘(ℝ, M)) ⊤ M := inferInstance

/-- Coefficient `E(p) = sech²(y) = 1 / cosh²(y)` of `dx ⊗ dx`. -/
noncomputable def Emet (p : M) : ℝ := (Real.cosh p.2)⁻¹ ^ 2

/-- Coefficient `G(p) = cosh²(x)` of `dy ⊗ dy`. -/
noncomputable def Gmet (p : M) : ℝ := (Real.cosh p.1) ^ 2

/-- The Riemannian metric `g` as a bilinear form on tangent vectors `v, w ∈ ℝ²`:
`g_p(v, w) = E(p) · v₁ w₁ + G(p) · v₂ w₂`. -/
noncomputable def gForm (p : M) (v w : M) : ℝ :=
  Emet p * (v.1 * w.1) + Gmet p * (v.2 * w.2)

@[simp] lemma Emet_pos (p : M) : 0 < Emet p :=
  pow_pos (inv_pos.mpr (Real.cosh_pos _)) 2

@[simp] lemma Gmet_pos (p : M) : 0 < Gmet p :=
  pow_pos (Real.cosh_pos _) 2

/-- The metric is symmetric. -/
lemma gForm_symm (p v w : M) : gForm p v w = gForm p w v := by
  simp only [gForm]; ring

/-- Bilinearity: additivity in the second slot. -/
lemma gForm_add_right (p v w w' : M) :
    gForm p v (w + w') = gForm p v w + gForm p v w' := by
  simp only [gForm, Prod.fst_add, Prod.snd_add]; ring

/-- Bilinearity: homogeneity in the second slot. -/
lemma gForm_smul_right (p v w : M) (c : ℝ) :
    gForm p v (c • w) = c * gForm p v w := by
  simp only [gForm, Prod.smul_fst, Prod.smul_snd, smul_eq_mul]; ring

/-- The quadratic form `g_p(v, v)` is nonnegative. -/
lemma gForm_self_nonneg (p v : M) : 0 ≤ gForm p v v := by
  have hE := Emet_pos p
  have hG := Gmet_pos p
  have h1 : 0 ≤ Emet p * (v.1 * v.1) := mul_nonneg hE.le (mul_self_nonneg _)
  have h2 : 0 ≤ Gmet p * (v.2 * v.2) := mul_nonneg hG.le (mul_self_nonneg _)
  simpa [gForm] using add_nonneg h1 h2

/-
**Positive definiteness**: `g_p(v, v) = 0` iff `v = 0`.
-/
lemma gForm_self_eq_zero (p v : M) : gForm p v v = 0 ↔ v = 0 := by
  constructor <;> intro h <;> simp_all +decide [ gForm ];
  exact Prod.mk_inj.mpr ⟨ mul_self_eq_zero.mp ( by nlinarith [ Emet_pos p, Gmet_pos p ] ), mul_self_eq_zero.mp ( by nlinarith [ Emet_pos p, Gmet_pos p ] ) ⟩

/-
**Positive definiteness** (strict form): a nonzero tangent vector has positive
length squared.
-/
lemma gForm_self_pos (p v : M) (hv : v ≠ 0) : 0 < gForm p v v := by
  contrapose! hv;
  exact gForm_self_eq_zero p v |>.1 ( le_antisymm hv ( gForm_self_nonneg p v ) )

/-
The coefficient `E = sech²` is a smooth function on `M`.
-/
lemma Emet_smooth : ContDiff ℝ (⊤ : ℕ∞) Emet := by
  apply_rules [ ContDiff.pow, ContDiff.inv, ContDiff.cosh ];
  · exact contDiff_snd;
  · exact fun x => ne_of_gt ( Real.cosh_pos _ )

/-
The coefficient `G = cosh²` is a smooth function on `M`.
-/
lemma Gmet_smooth : ContDiff ℝ (⊤ : ℕ∞) Gmet := by
  unfold Gmet; exact ContDiff.pow ( Real.contDiff_cosh.comp contDiff_fst ) _;

/-
**Smoothness of the metric**: for fixed tangent vectors `v, w`, the map
`p ↦ g_p(v, w)` is smooth.
-/
lemma gForm_smooth (v w : M) : ContDiff ℝ (⊤ : ℕ∞) (fun p => gForm p v w) := by
  exact ContDiff.add ( ContDiff.mul ( Emet_smooth ) ( contDiff_const ) ) ( ContDiff.mul ( Gmet_smooth ) ( contDiff_const ) )

end SplitGeometry