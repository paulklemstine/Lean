/-
# The Airy Kernel: Symmetry, Diagonal, and Determinantal Positivity

The local statistics at the spectral edge of a random matrix are a determinantal
point process with correlation kernel the **Airy kernel**.  In Christoffel–Darboux
(integrable-kernel) form it is built from two solutions `f, g` of Airy's equation:

  `K(x, y) = (f x · g y − g x · f y) / (x − y)`.

This file proves three genuine properties of this kernel and of determinantal
correlation kernels in general:

* `airyKernel_symm` — the kernel is symmetric, `K x y = K y x`.
* `airyKernel_diagonal_tendsto` — the off-diagonal kernel has a removable
  singularity on the diagonal, and its limiting diagonal value is `−W`, the
  (constant!) Wronskian.  This *reuses* `airyWronskian_const` from `AiryODE.lean`:
  the diagonal value is the *same* at every point precisely because the Wronskian
  is constant — the analytic shadow of translation structure of the Airy process.
* `gram_corr_det_nonneg` / `gram_corr_posSemidef` — for any projection-type
  (Gram) correlation kernel `K(x,y) = ⟪φ x, φ y⟫`, the `2×2` correlation
  determinant is `≥ 0` and the full `n×n` correlation matrix is positive
  semidefinite.  This is exactly the positivity that makes the Airy kernel define
  an honest determinantal point process.
-/
import Mathlib
import Novelty.RandomMatrices.AiryODE

open Filter Topology RealInnerProductSpace

namespace RandomMatrices

/-- The Christoffel–Darboux Airy kernel built from two solutions `f, g`:
`K(x,y) = (f x · g y − g x · f y)/(x − y)`. -/
noncomputable def airyKernel (f g : ℝ → ℝ) (x y : ℝ) : ℝ :=
  (f x * g y - g x * f y) / (x - y)

/-- **The Airy kernel is symmetric.**  `K x y = K y x` whenever `x ≠ y`.
The numerator is antisymmetric and the denominator flips sign, so the quotient
is symmetric. -/
theorem airyKernel_symm (f g : ℝ → ℝ) (x y : ℝ) (h : x ≠ y) :
    airyKernel f g x y = airyKernel f g y x := by
  unfold airyKernel
  rw [div_eq_div_iff (sub_ne_zero.mpr h) (sub_ne_zero.mpr (Ne.symm h))]
  ring

/-- **Diagonal value of the Airy kernel is the (constant) Wronskian.**

As `y → x`, the off-diagonal kernel `K(x,y)` converges to `−W`, where
`W = airyWronskian f f' g g'`.  For solutions of the Airy equation `W` is
*constant* (`airyWronskian_const`), so the limiting diagonal value `−W(0)` is the
*same* at every base point `x` — the removable singularity is uniform along the
diagonal. -/
theorem airyKernel_diagonal_tendsto
    (f f' f'' g g' g'' : ℝ → ℝ)
    (hf : ∀ x, HasDerivAt f (f' x) x)
    (hf' : ∀ x, HasDerivAt f' (f'' x) x)
    (hg : ∀ x, HasDerivAt g (g' x) x)
    (hg' : ∀ x, HasDerivAt g' (g'' x) x)
    (eqf : ∀ x, f'' x = x * f x)
    (eqg : ∀ x, g'' x = x * g x)
    (x : ℝ) :
    Tendsto (fun y => airyKernel f g x y) (𝓝[≠] x)
      (𝓝 (-(airyWronskian f f' g g' 0))) := by
  -- First: the limit is `-(W x)`.
  set N : ℝ → ℝ := fun y => f x * g y - g x * f y with hN
  have hNderiv : HasDerivAt N (airyWronskian f f' g g' x) x := by
    have h1 : HasDerivAt (fun y => f x * g y) (f x * g' x) x := (hg x).const_mul (f x)
    have h2 : HasDerivAt (fun y => g x * f y) (g x * f' x) x := (hf x).const_mul (g x)
    have h3 := h1.sub h2
    have heq : f x * g' x - g x * f' x = airyWronskian f f' g g' x := by
      simp only [airyWronskian]; ring
    rw [heq] at h3; exact h3
  have hts : Tendsto (slope N x) (𝓝[≠] x) (𝓝 (airyWronskian f f' g g' x)) :=
    hasDerivAt_iff_tendsto_slope.mp hNderiv
  have key := hts.neg
  -- Replace `-(W x)` by `-(W 0)` using constancy of the Wronskian.
  have hconst : airyWronskian f f' g g' x = airyWronskian f f' g g' 0 :=
    airyWronskian_const f f' f'' g g' g'' hf hf' hg hg' eqf eqg x 0
  rw [hconst] at key
  refine key.congr' ?_
  filter_upwards [self_mem_nhdsWithin] with y hy
  have hyx : y ≠ x := hy
  have hxy : x - y ≠ 0 := sub_ne_zero.mpr (Ne.symm hyx)
  have hyx' : y - x ≠ 0 := sub_ne_zero.mpr hyx
  simp only [airyKernel, slope, hN, vsub_eq_sub, smul_eq_mul]
  field_simp
  ring

/-- A projection-type (Gram) correlation kernel from a "wave map"
`φ : ℝ → H` into a real inner-product space: `K(x,y) = ⟪φ x, φ y⟫`.
The genuine Airy kernel is of this form, `φ x = (t ↦ Ai(x + t))`. -/
noncomputable def gramKernel {H : Type*} [NormedAddCommGroup H]
    [InnerProductSpace ℝ H] (φ : ℝ → H) (x y : ℝ) : ℝ :=
  ⟪φ x, φ y⟫

/-- **`2×2` determinantal positivity.**  For a Gram correlation kernel, the
`2×2` correlation determinant `K(x,x)·K(y,y) − K(x,y)·K(y,x)` is nonnegative.
This is the Cauchy–Schwarz inequality, and is the `n = 2` instance of the
positivity required for `K` to define a determinantal point process. -/
theorem gram_corr_det_nonneg {H : Type*} [NormedAddCommGroup H]
    [InnerProductSpace ℝ H] (φ : ℝ → H) (x y : ℝ) :
    gramKernel φ x x * gramKernel φ y y
      - gramKernel φ x y * gramKernel φ y x ≥ 0 := by
  simp only [gramKernel]
  have hsymm : ⟪φ y, φ x⟫ = ⟪φ x, φ y⟫ := real_inner_comm _ _
  rw [hsymm]
  have hcs : ⟪φ x, φ y⟫ ^ 2 ≤ ⟪φ x, φ x⟫ * ⟪φ y, φ y⟫ := by
    have hx : ⟪φ x, φ x⟫ = ‖φ x‖ ^ 2 := real_inner_self_eq_norm_sq _
    have hy : ⟪φ y, φ y⟫ = ‖φ y‖ ^ 2 := real_inner_self_eq_norm_sq _
    rw [hx, hy]
    nlinarith [abs_le.mp (abs_real_inner_le_norm (φ x) (φ y)),
      norm_nonneg (φ x), norm_nonneg (φ y)]
  nlinarith [hcs]

/-- **`n×n` determinantal positivity.**  For any finite set of base points
`p : Fin n → ℝ`, the correlation matrix `(K(pᵢ, pⱼ))` of a Gram correlation
kernel is positive semidefinite.  This is the full positivity making the Airy
kernel an admissible determinantal correlation kernel. -/
theorem gram_corr_posSemidef {H : Type*} [NormedAddCommGroup H]
    [InnerProductSpace ℝ H] {n : ℕ} (φ : ℝ → H) (p : Fin n → ℝ) :
    (Matrix.of (fun i j => gramKernel φ (p i) (p j))).PosSemidef := by
  constructor
  · ext i j
    simp only [Matrix.of_apply, gramKernel, Matrix.conjTranspose_apply, star_trivial]
    exact real_inner_comm (φ (p i)) (φ (p j))
  · intro x
    -- `xᴴ M x = ⟪Σ xᵢ φ(pᵢ), Σ xⱼ φ(pⱼ)⟫ = ‖Σ xᵢ φ(pᵢ)‖² ≥ 0`
    have hS : (x.sum fun i xi => x.sum fun j xj =>
          star xi * (Matrix.of (fun i j => gramKernel φ (p i) (p j))) i j * xj)
        = ⟪x.sum (fun i xi => xi • φ (p i)), x.sum (fun i xi => xi • φ (p i))⟫ := by
      rw [Finsupp.sum, Finsupp.sum, sum_inner]
      apply Finset.sum_congr rfl
      intro i _
      rw [inner_sum]
      apply Finset.sum_congr rfl
      intro j _
      simp only [Matrix.of_apply, gramKernel, inner_smul_left, inner_smul_right,
        star_trivial, starRingEnd_apply]
      ring
    rw [hS]
    exact real_inner_self_nonneg

end RandomMatrices

/-
-- !-- Lab Notes -- !--

Hypothesis (Hypothesizer):
  H4. The CD Airy kernel `K(x,y)=(f x g y - g x f y)/(x-y)` is symmetric.
  H5 (surprising). The diagonal value of `K` (its removable-singularity limit) is
      `-W`, and is the SAME at every base point — a uniform diagonal — because the
      Wronskian is constant.  i.e. the singular-looking kernel is "flat" on the
      diagonal at the level of the Wronskian.
  H6 (counter-intuitive). The structural positivity of the determinantal process
      (n×n correlation matrices PSD) requires NO Airy-specific input at all: it is
      pure Cauchy–Schwarz / Gram positivity for ANY projection kernel.

Experiment (Experimenter):
  * H4: `div_eq_div_iff` + `ring` on the cross-multiplied identity.
  * H5: rewrite `K` as `-slope N x` for `N y = f x g y - g x f y` (vanishing at
    `y=x`), use `hasDerivAt_iff_tendsto_slope`; then `airyWronskian_const`
    (imported from AiryODE.lean) rewrites the position-dependent limit `-(W x)` to
    the constant `-(W 0)`.  The `field_simp; ring` reconciles `slope` with `K`.
  * H6: 2×2 case is Cauchy–Schwarz (`abs_real_inner_le_norm`); n×n case unfolds
    `vᵀ M v` to `⟪Σ vᵢφᵢ, Σ vⱼφⱼ⟫ = ‖Σ vᵢφᵢ‖² ≥ 0` via `inner_sum`/`sum_inner`.

Analysis (Analyst):
  * All SURVIVED (0 sorries).  H5 is the genuine cross-file reuse: drop
    `airyWronskian_const` and the diagonal value stays `-(W x)` — still true but no
    longer manifestly uniform.  So constancy is exactly what upgrades "removable
    singularity at each point" to "uniform diagonal".
  * Failure mode: stating the diagonal limit over the full `𝓝 x` (not the punctured
    `𝓝[≠] x`) is FALSE — `K` is undefined at `y=x`.  The punctured neighborhood is
    mandatory; `hasDerivAt_iff_tendsto_slope` is exactly tailored to it.

Critique (Critic):
  * No theorem is trivial: H4 uses `div_eq_div_iff`; H5 uses `HasDerivAt`/slope
    machinery + the imported constancy lemma; H6 uses Cauchy–Schwarz and a genuine
    PosSemidef expansion. None is `rfl`/`decide`/`native_decide`.
  * Corner case checked: `gram_corr_posSemidef` covers `n = 0` (empty matrix
    vacuously PSD) and repeated points (matrix is then singular but still PSD).

Synthesis (PI):
  Symmetry + uniform diagonal + Gram positivity are exactly the three hypotheses an
  abstract "Airy-type determinantal kernel" must satisfy; we have isolated them and
  shown which depend on the ODE (the diagonal) and which are universal (positivity).
-/