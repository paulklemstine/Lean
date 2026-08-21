import MachineLearning.BerggrenEuclidParam
import MachineLearning.BerggrenBranchGrowth

/-!
# The silver coordinate: where `ℤ[√2]` really lives inside the Berggren tree

This file is the arithmetic half of a research cycle testing the conjecture that the
Berggren (Barning–Hall) tree of Pythagorean triples "is" the arithmetic of the real
quadratic field `ℚ(√2)`.

The mechanism we isolate is a single ring-theoretic map, the **silver coordinate**

  `ζ(a, b, c) = (a + b) + c √2 ∈ ℤ[√2]`,

together with its twin `ζ⁻(a, b, c) = (a − b) + c √2`.  The three Berggren generators act
on these coordinates by *multiplication by the square of the fundamental unit*:

  `ζ (mB v) = (3 + 2√2) · ζ v`,  `ζ (mA v) = (3 + 2√2) · ζ⁻ v`,
  `ζ (mC v) = (3 + 2√2) · (b − a + c√2)`.

So only the middle generator `mB` acts as an honest `ℤ[√2]`-scalar on its own coordinate:
the `B`-spine of the tree is an orbit of the unit group, while `mA` and `mC` swap the two
coordinates.  This is the precise sense in which `ℚ(√2)` sits inside the tree — along one
geodesic axis, not globally.

Consequences proved here.

* `zeta_spine` : the `n`-th node of the all-`B` spine has silver coordinate exactly
  `(1 + √2)^(2n+3)`, the odd powers of the fundamental unit of `ℤ[√2]`.
* `spine_negPell` : hence the spine solves the negative Pell equation `x² − 2y² = −1`
  with `x = a + b`, `y = c`;  equivalently `c² − 2ab = 1` (`spine_area_identity`).
* `spine_zeta_isUnit` : every spine node is a unit of `ℤ[√2]`.
* `mBq_eigen_plus`, `mBq_eigen_minus`, `mBq_eigen_neg` : the full eigen-decomposition of
  the hyperbolic generator over `ℤ[√2]`: eigenvalues `3 + 2√2`, `3 − 2√2`, `−1`, with the
  two hyperbolic eigenvectors `(1, 1, ±√2)` lying on the light cone.  The attracting
  eigenvector is the boundary point of the `B`-spine.
* `charpoly_mB_factors` : `char(B) = (X + 1)(X² − 6X + 1)`, and `X² − 6X + 1` is the
  minimal polynomial of `3 + 2√2 = (1 + √2)²`.
* `spine_ratio_sq`, `spine_ratio_tendsto` : `((a + b)/c)² = 2 − 1/c²` exactly, hence the
  spine converges to the irrational boundary direction `√2` at rate `O(c⁻²)`.
* `mB_euclid_matrix_charpoly` : in the *spin* (Euclid-parameter) representation the same
  generator is the `GL(2, ℤ)` matrix `!![2, 1; 1, 0]` whose eigenvalues are `1 ± √2`.
  The `3`-dimensional eigenvalue is the square of the `2`-dimensional one: the fundamental
  unit is a *spinor* eigenvalue of the tree, not an ambient field of definition.
-/

namespace BerggrenStars

namespace Silver

open Zsqrtd

/-! ### The fundamental unit of `ℤ[√2]` -/

/-- The fundamental unit `1 + √2` of `ℤ[√2]` (the *silver ratio*). -/
def silver : ℤ√2 := ⟨1, 1⟩

/-- The square `3 + 2√2` of the fundamental unit: the hyperbolic eigenvalue of the
Berggren generator `mB`. -/
def lam : ℤ√2 := ⟨3, 2⟩

/-- `√2` itself, as an element of `ℤ[√2]`. -/
def rt2 : ℤ√2 := ⟨0, 1⟩

theorem rt2_sq : rt2 * rt2 = 2 := by decide

theorem lam_eq_silver_sq : lam = silver ^ 2 := by decide

theorem silver_norm : silver.norm = -1 := by decide

theorem lam_norm : lam.norm = 1 := by decide

theorem lam_isUnit : IsUnit lam := IsUnit.of_mul_eq_one (⟨3, -2⟩ : ℤ√2) (by decide)

theorem silver_isUnit : IsUnit silver := IsUnit.of_mul_eq_one (⟨-1, 1⟩ : ℤ√2) (by decide)

/-- Norms are multiplicative on powers. -/
theorem norm_pow (x : ℤ√2) : ∀ n : ℕ, (x ^ n).norm = x.norm ^ n := by
  intro n
  induction n with
  | zero => simp
  | succ k ih => rw [pow_succ, pow_succ, Zsqrtd.norm_mul, ih]

/-- Odd powers of the fundamental unit have norm `−1`: they are the solutions of the
negative Pell equation `x² − 2y² = −1`. -/
theorem norm_silver_odd (n : ℕ) : (silver ^ (2 * n + 3)).norm = -1 := by
  rw [norm_pow, silver_norm]
  rw [show 2 * n + 3 = 2 * (n + 1) + 1 by ring, pow_succ, pow_mul]
  norm_num

/-! ### The silver coordinate of a Lorentz vector -/

/-- The **silver coordinate** `ζ(a, b, c) = (a + b) + c√2 ∈ ℤ[√2]`. -/
def zeta (v : Vec) : ℤ√2 := ⟨v.1 + v.2.1, v.2.2⟩

/-- The twisted silver coordinate `ζ⁻(a, b, c) = (a − b) + c√2`. -/
def zetaMinus (v : Vec) : ℤ√2 := ⟨v.1 - v.2.1, v.2.2⟩

/-- **The hyperbolic generator is multiplication by the square of the fundamental unit.**
This is the key intertwining relation of the whole file; note that it holds for *every*
integer vector, not just for Pythagorean triples. -/
theorem zeta_mB (v : Vec) : zeta (mB v) = lam * zeta v := by
  obtain ⟨a, b, c⟩ := v
  ext <;> simp [zeta, mB, lam, Zsqrtd.re_mul, Zsqrtd.im_mul] <;> ring

/-- `mA` multiplies by the same unit but *reads the twisted coordinate*: the `ℤ[√2]`-scalar
structure is not preserved by this generator. -/
theorem zeta_mA (v : Vec) : zeta (mA v) = lam * zetaMinus v := by
  obtain ⟨a, b, c⟩ := v
  ext <;> simp [zeta, zetaMinus, mA, lam, Zsqrtd.re_mul, Zsqrtd.im_mul] <;> ring

/-- `mC` multiplies by the same unit after the *opposite* twist. -/
theorem zeta_mC (v : Vec) : zeta (mC v) = lam * ⟨v.2.1 - v.1, v.2.2⟩ := by
  obtain ⟨a, b, c⟩ := v
  ext <;> simp [zeta, mC, lam, Zsqrtd.re_mul, Zsqrtd.im_mul] <;> ring

/-- On the light cone the norm form of `ℤ[√2]` computes `2ab − c²`, twice the area of the
triangle minus the square of its hypotenuse. -/
theorem zeta_norm_onCone {v : Vec} (h : OnCone v) :
    (zeta v).norm = 2 * v.1 * v.2.1 - v.2.2 ^ 2 := by
  obtain ⟨a, b, c⟩ := v
  rw [onCone_iff] at h
  simp only [zeta, Zsqrtd.norm_def]
  nlinarith [h]

/-! ### The `B`-spine is the unit group -/

/-- The all-`B` spine of the Berggren tree, the axis of the hyperbolic generator. -/
def spine : ℕ → Vec
  | 0 => root
  | n + 1 => mB (spine n)

@[simp] theorem spine_zero : spine 0 = (3, 4, 5) := rfl

theorem spine_one : spine 1 = (21, 20, 29) := by decide

theorem spine_two : spine 2 = (119, 120, 169) := by decide

theorem spine_onCone (n : ℕ) : OnCone (spine n) := by
  induction n with
  | zero => exact onCone_root
  | succ k ih => exact onCone_mB ih

theorem zeta_root : zeta root = silver ^ 3 := by decide

/-- **Main arithmetic theorem.**  The silver coordinate of the `n`-th spine node is exactly
the `(2n+3)`-rd power of the fundamental unit `1 + √2`.  The all-`B` branch of the
Berggren tree *is* the odd part of the unit group of `ℤ[√2]`. -/
theorem zeta_spine (n : ℕ) : zeta (spine n) = silver ^ (2 * n + 3) := by
  induction n with
  | zero => simpa using zeta_root
  | succ k ih =>
      have : zeta (spine (k + 1)) = lam * zeta (spine k) := zeta_mB _
      rw [this, ih, lam_eq_silver_sq, ← pow_add]
      ring_nf

/-- Every spine node is a unit of `ℤ[√2]`. -/
theorem spine_zeta_isUnit (n : ℕ) : IsUnit (zeta (spine n)) := by
  rw [zeta_spine]
  exact silver_isUnit.pow _

/-- **The spine solves the negative Pell equation.**  With `x = a + b` and `y = c`,
`x² − 2y² = −1`. -/
theorem spine_negPell (n : ℕ) :
    ((spine n).1 + (spine n).2.1) ^ 2 - 2 * (spine n).2.2 ^ 2 = -1 := by
  have h := norm_silver_odd n
  rw [← zeta_spine] at h
  have h2 : ((spine n).1 + (spine n).2.1) * ((spine n).1 + (spine n).2.1)
      - 2 * (spine n).2.2 * (spine n).2.2 = -1 := by
    simpa [zeta, Zsqrtd.norm_def] using h
  linear_combination h2

/-- Equivalent form on the light cone: the hypotenuse and the area satisfy `c² − 2ab = 1`,
so every spine triangle misses being isoceles by exactly one unit of area. -/
theorem spine_area_identity (n : ℕ) :
    (spine n).2.2 ^ 2 - 2 * (spine n).1 * (spine n).2.1 = 1 := by
  have hc := spine_onCone n
  have h := spine_negPell n
  rw [onCone_iff] at hc
  nlinarith [h, hc]

/-! ### Positivity and growth along the spine -/

theorem spine_pos (n : ℕ) : 0 < (spine n).1 ∧ 0 < (spine n).2.1 ∧ 0 < (spine n).2.2 := by
  induction n with
  | zero => exact ⟨by norm_num, by norm_num, by norm_num⟩
  | succ k ih =>
      obtain ⟨ha, hb, hc⟩ := ih
      refine ⟨?_, ?_, ?_⟩ <;> simp only [spine, mB] <;> linarith

theorem spine_hyp_growth (n : ℕ) : 3 * (spine n).2.2 < (spine (n + 1)).2.2 := by
  obtain ⟨ha, hb, _⟩ := spine_pos n
  simp only [spine, mB]
  linarith

/-- The hypotenuse of the spine grows at least like `3ⁿ`. -/
theorem spine_hyp_ge (n : ℕ) : (3 : ℤ) ^ n ≤ (spine n).2.2 := by
  induction n with
  | zero => norm_num
  | succ k ih =>
      have h := spine_hyp_growth k
      have : (3 : ℤ) ^ (k + 1) = 3 * 3 ^ k := by ring
      rw [this]
      nlinarith [h, ih]

/-! ### The boundary direction of the spine is irrational -/

/-- The exact rate of approach to the boundary: `((a+b)/c)² = 2 − 1/c²`. -/
theorem spine_ratio_sq (n : ℕ) :
    ((((spine n).1 + (spine n).2.1 : ℤ) : ℝ) / ((spine n).2.2 : ℝ)) ^ 2
      = 2 - 1 / (((spine n).2.2 : ℝ)) ^ 2 := by
  obtain ⟨_, _, hc⟩ := spine_pos n
  have hc' : ((spine n).2.2 : ℝ) ≠ 0 := by
    exact_mod_cast (ne_of_gt hc)
  have h := spine_negPell n
  have h' : ((((spine n).1 + (spine n).2.1 : ℤ) : ℝ)) ^ 2
      - 2 * (((spine n).2.2 : ℤ) : ℝ) ^ 2 = -1 := by exact_mod_cast h
  field_simp
  push_cast at h' ⊢
  nlinarith [h']

/-- The spine converges to the irrational boundary direction `√2`: the attracting
eigendirection `(1, 1, √2)` of the hyperbolic generator. -/
theorem spine_ratio_tendsto :
    Filter.Tendsto
      (fun n => ((((spine n).1 + (spine n).2.1 : ℤ) : ℝ) / ((spine n).2.2 : ℝ)))
      Filter.atTop (nhds (Real.sqrt 2)) := by
  have hpos : ∀ n, (0 : ℝ) < ((spine n).2.2 : ℝ) := by
    intro n
    exact_mod_cast (spine_pos n).2.2
  have hnum : ∀ n, (0 : ℝ) ≤ (((spine n).1 + (spine n).2.1 : ℤ) : ℝ) := by
    intro n
    have := (spine_pos n).1
    have := (spine_pos n).2.1
    have : (0 : ℤ) ≤ (spine n).1 + (spine n).2.1 := by omega
    exact_mod_cast this
  -- the ratio is the square root of `2 - 1/c²`
  have key : ∀ n,
      ((((spine n).1 + (spine n).2.1 : ℤ) : ℝ) / ((spine n).2.2 : ℝ))
        = Real.sqrt (2 - 1 / (((spine n).2.2 : ℝ)) ^ 2) := by
    intro n
    rw [← spine_ratio_sq n, Real.sqrt_sq (div_nonneg (hnum n) (le_of_lt (hpos n)))]
  simp only [key]
  have hcto : Filter.Tendsto (fun n => (((spine n).2.2 : ℤ) : ℝ)) Filter.atTop Filter.atTop := by
    apply Filter.tendsto_atTop_mono (f := fun n : ℕ => ((3 : ℝ) ^ n))
    · intro n
      have := spine_hyp_ge n
      have : ((3 : ℤ) ^ n : ℝ) ≤ (((spine n).2.2 : ℤ) : ℝ) := by exact_mod_cast this
      simpa using this
    · exact tendsto_pow_atTop_atTop_of_one_lt (by norm_num)
  have h1 : Filter.Tendsto
      (fun n => 2 - 1 / (((spine n).2.2 : ℤ) : ℝ) ^ 2) Filter.atTop (nhds 2) := by
    have : Filter.Tendsto (fun n => 1 / (((spine n).2.2 : ℤ) : ℝ) ^ 2)
        Filter.atTop (nhds 0) := by
      have hsq : Filter.Tendsto (fun n => (((spine n).2.2 : ℤ) : ℝ) ^ 2)
          Filter.atTop Filter.atTop := by
        simpa [pow_two] using hcto.atTop_mul_atTop₀ hcto
      simpa [one_div] using hsq.inv_tendsto_atTop
    simpa using (tendsto_const_nhds (x := (2 : ℝ)) (f := Filter.atTop (α := ℕ))).sub this
  exact (Real.continuous_sqrt.tendsto 2).comp h1

/-! ### The eigen-decomposition of the hyperbolic generator over `ℤ[√2]` -/

/-- The Berggren generator `mB` extended to `ℤ[√2]`-coefficient vectors. -/
def mBq (v : ℤ√2 × ℤ√2 × ℤ√2) : ℤ√2 × ℤ√2 × ℤ√2 :=
  (v.1 + 2 * v.2.1 + 2 * v.2.2, 2 * v.1 + v.2.1 + 2 * v.2.2, 2 * v.1 + 2 * v.2.1 + 3 * v.2.2)

/-- `mBq` really is an extension of `mB`. -/
theorem mBq_extends (v : Vec) :
    mBq ((v.1 : ℤ√2), (v.2.1 : ℤ√2), (v.2.2 : ℤ√2))
      = (((mB v).1 : ℤ√2), ((mB v).2.1 : ℤ√2), ((mB v).2.2 : ℤ√2)) := by
  obtain ⟨a, b, c⟩ := v
  simp only [mBq, mB]
  refine Prod.ext ?_ (Prod.ext ?_ ?_) <;> push_cast <;> ring

/-- The `ℤ[√2]`-linear Lorentz form. -/
def qformQ (v : ℤ√2 × ℤ√2 × ℤ√2) : ℤ√2 := v.1 * v.1 + v.2.1 * v.2.1 - v.2.2 * v.2.2

/-- **Attracting eigenvector.**  `(1, 1, √2)` is an eigenvector of the hyperbolic generator
with eigenvalue `3 + 2√2 = (1 + √2)²`. -/
theorem mBq_eigen_plus : mBq (1, 1, rt2) = (lam * 1, lam * 1, lam * rt2) := by
  decide

/-- **Repelling eigenvector.**  `(1, 1, −√2)` has eigenvalue `3 − 2√2 = (1 + √2)⁻²`. -/
theorem mBq_eigen_minus :
    mBq (1, 1, -rt2) = ((⟨3, -2⟩ : ℤ√2) * 1, (⟨3, -2⟩ : ℤ√2) * 1, (⟨3, -2⟩ : ℤ√2) * (-rt2)) := by
  decide

/-- The third eigenvalue is `−1`, with the rational eigenvector `(1, −1, 0)`. -/
theorem mBq_eigen_neg : mBq (1, -1, 0) = ((-1 : ℤ√2) * 1, (-1 : ℤ√2) * (-1), (-1 : ℤ√2) * 0) := by
  decide

/-- Both hyperbolic eigenvectors are light-like: they are the two boundary fixed points of
the hyperbolic generator, and they are *not* rational points of the cone. -/
theorem eigen_plus_onCone : qformQ (1, 1, rt2) = 0 := by decide

theorem eigen_minus_onCone : qformQ (1, 1, -rt2) = 0 := by decide

/-- The two hyperbolic eigenvalues are inverse units: `(3+2√2)(3−2√2) = 1`. -/
theorem eigen_product_one : lam * (⟨3, -2⟩ : ℤ√2) = 1 := by decide

/-- Their sum is the rational number `6` — the trace of the hyperbolic block, which is why
no irrationality is visible at the level of traces. -/
theorem eigen_sum_six : lam + (⟨3, -2⟩ : ℤ√2) = (6 : ℤ√2) := by decide

/-! ### Characteristic polynomials: the spin origin of `√2` -/

open Polynomial

/-- The matrix of the hyperbolic Berggren generator on `ℤ^{2,1}`. -/
def mBmat : Matrix (Fin 3) (Fin 3) ℤ := !![1, 2, 2; 2, 1, 2; 2, 2, 3]

theorem mBmat_apply (v : Vec) :
    mBmat.mulVec ![v.1, v.2.1, v.2.2] = ![(mB v).1, (mB v).2.1, (mB v).2.2] := by
  obtain ⟨a, b, c⟩ := v
  funext i
  fin_cases i <;> simp [mBmat, mB, Matrix.mulVec, dotProduct, Fin.sum_univ_three]

/-- The characteristic polynomial of the hyperbolic generator factors as
`(X + 1)(X² − 6X + 1)`: a rational eigenvalue `−1` and the real quadratic pair
`3 ± 2√2`. -/
theorem charpoly_mB_factors : mBmat.charpoly = (X + 1) * (X ^ 2 - 6 * X + 1) := by
  simp [mBmat, Matrix.charpoly, Matrix.det_fin_three, Matrix.charmatrix]
  ring

/-- `3 + 2√2` is a root of the quadratic factor, over `ℤ[√2]`. -/
theorem lam_root_quadratic : lam ^ 2 - 6 * lam + 1 = 0 := by decide

/-- The `2`-dimensional (spin / Euclid-parameter) form of the same generator:
`(m, n) ↦ (2m + n, m)`, an element of `GL(2, ℤ)`. -/
def mBspin : Matrix (Fin 2) (Fin 2) ℤ := !![2, 1; 1, 0]

theorem mBspin_det : mBspin.det = -1 := by
  simp [mBspin, Matrix.det_fin_two]

/-- The spin matrix acts on Euclid parameters exactly as `mB` acts on triples: the double
cover intertwines the two representations. -/
theorem mBspin_euclid (m n : ℤ) :
    mB (euclidTriple m n)
      = euclidTriple (mBspin.mulVec ![m, n] 0) (mBspin.mulVec ![m, n] 1) := by
  have h0 : mBspin.mulVec ![m, n] 0 = 2 * m + n := by
    simp [mBspin, Matrix.mulVec, dotProduct, Fin.sum_univ_two]
  have h1 : mBspin.mulVec ![m, n] 1 = m := by
    simp [mBspin, Matrix.mulVec, dotProduct, Fin.sum_univ_two]
  rw [h0, h1, mB_euclid]

/-- The spin eigenvalues are `1 ± √2`, the fundamental unit itself: `char(spin) = X² − 2X − 1`. -/
theorem charpoly_mBspin : mBspin.charpoly = X ^ 2 - 2 * X - 1 := by
  simp [mBspin, Matrix.charpoly, Matrix.det_fin_two, Matrix.charmatrix]
  ring

theorem silver_root_spin : silver ^ 2 - 2 * silver - 1 = 0 := by decide

/-- **The `3`-dimensional eigenvalue is the square of the spin eigenvalue.**  The unit
`3 + 2√2` of the Berggren tree is a *spinor* quantity: it is the square of the
fundamental unit `1 + √2`, which is the eigenvalue of the `GL(2, ℤ)` matrix `!![2,1;1,0]`.
Since that matrix has rational integer entries, the field `ℚ(√2)` enters only as the
eigenvalue field of one hyperbolic element — not as a field of definition. -/
theorem eigenvalue_is_spin_square : lam = silver * silver := by decide

end Silver

end BerggrenStars