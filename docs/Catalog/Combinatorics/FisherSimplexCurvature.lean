import Mathlib

/-!
# The Fisher–Rao geometry of the trinomial simplex

The trinomial (three-outcome) model `p = (x, y, 1 - x - y)` on the open simplex, with its
Fisher–Rao metric, Levi-Civita connection, Riemann tensor and Gauss curvature — all
*derived* rather than postulated:

* `prob`, `sum_prob`, `dprob`, `hasDerivAt_prob_fst` / `hasDerivAt_prob_snd` — the model
  and the derivatives of its probabilities;
* `gL` — the Fisher metric, proved in `gL_eq_fisher_sum` to be the information matrix
  `g_ij = Σ_a (∂_i p_a)(∂_j p_a)/p_a`, together with the inverse metric `gInv`
  (`gInv_mul_gL`) and the derivatives `dgL` (`hasDerivAt_gL_fst` / `hasDerivAt_gL_snd`);
* `levi_civita_unique` — **Koszul uniqueness**: a connection symmetric in its two lower
  indices and compatible with the metric is the half-sum
  `(∂_i g_jl + ∂_j g_il - ∂_l g_ij)/2`.  This general lemma is what lets the companion
  control models certify their own connections;
* `chrLow`, `chrT`, `chrT_eq_raise`, `dchrT`, `hasDerivAt_chrT_fst` /
  `hasDerivAt_chrT_snd` — the Christoffel symbols of both kinds and their derivatives;
* `riemann`, `sectional` — the two-dimensional curvature machinery, and
  `gaussianCurvature` with **`gaussianCurvature_eq : K = 1/4`**: the trinomial simplex is a
  piece of a sphere of radius `2`, of constant *positive* curvature;
* `skewLow`, `skew`, `skew_eq_neg_two_chr` — Amari's skewness tensor is `-2` times the
  Levi-Civita connection for this model, so the `α`-connection `alphaChr` is `(1 + α)`
  times it, and **`alphaCurv_eq : K^{(α)} = (1 - α²)/4`** for the whole family, vanishing
  exactly at the two flat connections `α = ±1`.

The sign convention of `riemann` / `sectional` is calibrated in
`Combinatorics.HyperbolicControlCurvature`, where the same machinery returns `K = -1` on
the Poincaré half-plane.
-/

open Finset

noncomputable section

namespace TrinomialFisher

/-! ## 1. The model -/

/-- The trinomial probabilities `p = (x, y, 1 - x - y)`. -/
def prob : Fin 3 → ℝ → ℝ → ℝ
  | 0, x, _ => x
  | 1, _, y => y
  | 2, x, y => 1 - x - y

theorem sum_prob (x y : ℝ) : ∑ a : Fin 3, prob a x y = 1 := by
  simp [Fin.sum_univ_three, prob]

/-- The derivative of `p_a` in the direction `i`. -/
def dprob : Fin 2 → Fin 3 → ℝ
  | 0, 0 => 1
  | 0, 1 => 0
  | 0, 2 => -1
  | 1, 0 => 0
  | 1, 1 => 1
  | 1, 2 => -1

theorem hasDerivAt_prob_fst (a : Fin 3) (x y : ℝ) :
    HasDerivAt (fun t => prob a t y) (dprob 0 a) x := by
  fin_cases a <;> simp only [prob, dprob]
  · exact hasDerivAt_id' (x := x)
  · exact hasDerivAt_const x y
  · simpa using ((hasDerivAt_id' (x := x)).const_sub (1 : ℝ)).sub_const y

theorem hasDerivAt_prob_snd (a : Fin 3) (x y : ℝ) :
    HasDerivAt (fun t => prob a x t) (dprob 1 a) y := by
  fin_cases a <;> simp only [prob, dprob]
  · exact hasDerivAt_const y x
  · exact hasDerivAt_id' (x := y)
  · simpa using (hasDerivAt_id' (x := y)).const_sub (1 - x : ℝ)

/-! ## 2. The Fisher metric -/

/-- The Fisher–Rao metric of the trinomial model in the coordinates `(x, y)`. -/
def gL : Fin 2 → Fin 2 → ℝ → ℝ → ℝ
  | 0, 0, x, y => 1 / x + 1 / (1 - x - y)
  | 0, 1, x, y => 1 / (1 - x - y)
  | 1, 0, x, y => 1 / (1 - x - y)
  | 1, 1, x, y => 1 / y + 1 / (1 - x - y)

/-- **The metric is the Fisher information**: `g_ij = Σ_a (∂_i p_a)(∂_j p_a) / p_a`. -/
theorem gL_eq_fisher_sum (i j : Fin 2) (x y : ℝ) (hx : x ≠ 0) (hy : y ≠ 0)
    (hz : 1 - x - y ≠ 0) :
    gL i j x y = ∑ a : Fin 3, dprob i a * dprob j a / prob a x y := by
  fin_cases i <;> fin_cases j <;>
    simp only [gL, Fin.sum_univ_three, dprob, prob] <;> field_simp <;> ring

theorem gL_symm (i j : Fin 2) (x y : ℝ) : gL i j x y = gL j i x y := by
  fin_cases i <;> fin_cases j <;> rfl

/-- The inverse Fisher metric `g^{ij} = p_i δ_ij - p_i p_j`. -/
def gInv : Fin 2 → Fin 2 → ℝ → ℝ → ℝ
  | 0, 0, x, _ => x * (1 - x)
  | 0, 1, x, y => -(x * y)
  | 1, 0, x, y => -(x * y)
  | 1, 1, _, y => y * (1 - y)

theorem gInv_mul_gL (i j : Fin 2) (x y : ℝ) (hx : x ≠ 0) (hy : y ≠ 0) (hz : 1 - x - y ≠ 0) :
    ∑ l : Fin 2, gInv i l x y * gL l j x y = if i = j then 1 else 0 := by
  fin_cases i <;> fin_cases j <;>
    simp only [Fin.sum_univ_two, gInv, gL, Fin.mk_zero, Fin.mk_one, if_true] <;>
    norm_num <;> field_simp <;> ring

/-! ## 3. Derivatives -/

/-- Closed form for `∂_k g_ij`. -/
def dgL : Fin 2 → Fin 2 → Fin 2 → ℝ → ℝ → ℝ
  | 0, 0, 0, x, y => -1 / x ^ 2 + 1 / (1 - x - y) ^ 2
  | 1, 1, 1, x, y => -1 / y ^ 2 + 1 / (1 - x - y) ^ 2
  | _, _, _, x, y => 1 / (1 - x - y) ^ 2

theorem dgL_symm (k i j : Fin 2) (x y : ℝ) : dgL k i j x y = dgL k j i x y := by
  fin_cases k <;> fin_cases i <;> fin_cases j <;> rfl

theorem hasDerivAt_affine_fst (y x : ℝ) : HasDerivAt (fun t : ℝ => 1 - t - y) (-1) x := by
  simpa using ((hasDerivAt_id' (x := x)).const_sub (1 : ℝ)).sub_const y

theorem hasDerivAt_affine_snd (x y : ℝ) : HasDerivAt (fun t : ℝ => 1 - x - t) (-1) y := by
  simpa using (hasDerivAt_id' (x := y)).const_sub (1 - x : ℝ)

/-- The derivative of `t ↦ c / t`. -/
theorem hasDerivAt_constDiv (c : ℝ) (y : ℝ) (hy : y ≠ 0) :
    HasDerivAt (fun t : ℝ => c / t) (-c / y ^ 2) y := by
  have h := (hasDerivAt_const y c).div (hasDerivAt_id' (x := y)) hy
  refine h.congr_deriv ?_
  field_simp
  ring

theorem hasDerivAt_constDivAffine_fst (c y : ℝ) {x : ℝ} (hz : 1 - x - y ≠ 0) :
    HasDerivAt (fun t : ℝ => c / (1 - t - y)) (c / (1 - x - y) ^ 2) x := by
  have h := (hasDerivAt_const x c).div (hasDerivAt_affine_fst y x) hz
  refine h.congr_deriv ?_
  field_simp
  ring

theorem hasDerivAt_constDivAffine_snd (c x : ℝ) {y : ℝ} (hz : 1 - x - y ≠ 0) :
    HasDerivAt (fun t : ℝ => c / (1 - x - t)) (c / (1 - x - y) ^ 2) y := by
  have h := (hasDerivAt_const y c).div (hasDerivAt_affine_snd x y) hz
  refine h.congr_deriv ?_
  field_simp
  ring

theorem hasDerivAt_idDivAffine_fst (y : ℝ) {x : ℝ} (hz : 1 - x - y ≠ 0) :
    HasDerivAt (fun t : ℝ => t / (1 - t - y)) ((1 - x - y + x) / (1 - x - y) ^ 2) x := by
  have h := (hasDerivAt_id' (x := x)).div (hasDerivAt_affine_fst y x) hz
  refine h.congr_deriv ?_
  field_simp
  ring

theorem hasDerivAt_idDivAffine_snd (x : ℝ) {y : ℝ} (hz : 1 - x - y ≠ 0) :
    HasDerivAt (fun t : ℝ => t / (1 - x - t)) ((1 - x - y + y) / (1 - x - y) ^ 2) y := by
  have h := (hasDerivAt_id' (x := y)).div (hasDerivAt_affine_snd x y) hz
  refine h.congr_deriv ?_
  field_simp
  ring

theorem hasDerivAt_oneSubDiv (x : ℝ) (hx : x ≠ 0) :
    HasDerivAt (fun t : ℝ => (1 - t) / t) (-1 / x ^ 2) x := by
  have h := (hasDerivAt_constDiv 1 x hx).sub_const 1
  refine h.congr_of_eventuallyEq ?_
  filter_upwards [eventually_ne_nhds hx] with t ht
  field_simp

theorem hasDerivAt_gL_fst (i j : Fin 2) (x y : ℝ) (hx : x ≠ 0) (hz : 1 - x - y ≠ 0) :
    HasDerivAt (fun t => gL i j t y) (dgL 0 i j x y) x := by
  have hz2 : HasDerivAt (fun t : ℝ => 1 / (1 - t - y)) (1 / (1 - x - y) ^ 2) x :=
    hasDerivAt_constDivAffine_fst 1 y hz
  have hx2 : HasDerivAt (fun t : ℝ => 1 / t) (-1 / x ^ 2) x := hasDerivAt_constDiv 1 x hx
  fin_cases i <;> fin_cases j <;> simp only [gL, dgL]
  · exact hx2.add hz2
  · exact hz2
  · exact hz2
  · exact hz2.const_add (1 / y)

theorem hasDerivAt_gL_snd (i j : Fin 2) (x y : ℝ) (hy : y ≠ 0) (hz : 1 - x - y ≠ 0) :
    HasDerivAt (fun t => gL i j x t) (dgL 1 i j x y) y := by
  have hz2 : HasDerivAt (fun t : ℝ => 1 / (1 - x - t)) (1 / (1 - x - y) ^ 2) y :=
    hasDerivAt_constDivAffine_snd 1 x hz
  have hy2 : HasDerivAt (fun t : ℝ => 1 / t) (-1 / y ^ 2) y := hasDerivAt_constDiv 1 y hy
  fin_cases i <;> fin_cases j <;> simp only [gL, dgL]
  · exact hz2.const_add (1 / x)
  · exact hz2
  · exact hz2
  · exact hy2.add hz2

/-! ## 4. The Levi-Civita connection -/

/-- **Koszul uniqueness.**  A connection which is symmetric in its two lower indices and
compatible with the metric (`∂_k g_ij = Γ_{ki,j} + Γ_{kj,i}`) is *the* Levi-Civita
connection `Γ_{ij,l} = (∂_i g_jl + ∂_j g_il - ∂_l g_ij)/2`. -/
theorem levi_civita_unique {ι : Type*} (dg : ι → ι → ι → ℝ) (G : ι → ι → ι → ℝ)
    (hGsym : ∀ i j l, G i j l = G j i l)
    (hcompat : ∀ k i j, dg k i j = G k i j + G k j i) (i j l : ι) :
    G i j l = (dg i j l + dg j i l - dg l i j) / 2 := by
  rw [hcompat i j l, hcompat j i l, hcompat l i j, hGsym i l j, hGsym j l i, hGsym j i l]
  ring

/-- Christoffel symbols of the first kind of the Fisher metric. -/
def chrLow (i j l : Fin 2) (x y : ℝ) : ℝ :=
  (dgL i j l x y + dgL j i l x y - dgL l i j x y) / 2

theorem chrLow_symm (i j l : Fin 2) (x y : ℝ) : chrLow i j l x y = chrLow j i l x y := by
  simp only [chrLow, dgL_symm l i j]
  ring

theorem dgL_eq_chrLow_add (k i j : Fin 2) (x y : ℝ) :
    dgL k i j x y = chrLow k i j x y + chrLow k j i x y := by
  simp only [chrLow, dgL_symm i k j, dgL_symm j k i, dgL_symm k i j]
  ring

/-- Christoffel symbols of the second kind of the Fisher metric, in closed form. -/
def chrT : Fin 2 → Fin 2 → Fin 2 → ℝ → ℝ → ℝ
  | 0, 0, 0, x, y => (x / (1 - x - y) - (1 - x) / x) / 2
  | 1, 0, 0, x, y => (y / (1 - x - y) + y / x) / 2
  | 0, 0, 1, x, y => (x / (1 - x - y)) / 2
  | 0, 1, 0, x, y => (x / (1 - x - y)) / 2
  | 1, 0, 1, x, y => (y / (1 - x - y)) / 2
  | 1, 1, 0, x, y => (y / (1 - x - y)) / 2
  | 0, 1, 1, x, y => (x / (1 - x - y) + x / y) / 2
  | 1, 1, 1, x, y => (y / (1 - x - y) - (1 - y) / y) / 2

/-- **`chrT` is the raised Levi-Civita connection**: `Γ^k_{ij} = Σ_l g^{kl} Γ_{ij,l}`. -/
theorem chrT_eq_raise (k i j : Fin 2) (x y : ℝ) (hx : x ≠ 0) (hy : y ≠ 0)
    (hz : 1 - x - y ≠ 0) :
    chrT k i j x y = ∑ l : Fin 2, gInv k l x y * chrLow i j l x y := by
  fin_cases k <;> fin_cases i <;> fin_cases j <;>
    simp only [chrT, chrLow, dgL, gInv, Fin.sum_univ_two] <;> field_simp <;> ring

/-- Closed form for `∂_d Γ^k_{ij}`. -/
def dchrT : Fin 2 → Fin 2 → Fin 2 → Fin 2 → ℝ → ℝ → ℝ
  | 0, 0, 0, 0, x, y => ((1 - x - y + x) / (1 - x - y) ^ 2 + 1 / x ^ 2) / 2
  | 1, 0, 0, 0, x, y => (x / (1 - x - y) ^ 2) / 2
  | 0, 1, 0, 0, x, y => (y / (1 - x - y) ^ 2 - y / x ^ 2) / 2
  | 1, 1, 0, 0, x, y => ((1 - x - y + y) / (1 - x - y) ^ 2 + 1 / x) / 2
  | 0, 0, 0, 1, x, y => ((1 - x - y + x) / (1 - x - y) ^ 2) / 2
  | 1, 0, 0, 1, x, y => (x / (1 - x - y) ^ 2) / 2
  | 0, 0, 1, 0, x, y => ((1 - x - y + x) / (1 - x - y) ^ 2) / 2
  | 1, 0, 1, 0, x, y => (x / (1 - x - y) ^ 2) / 2
  | 0, 1, 0, 1, x, y => (y / (1 - x - y) ^ 2) / 2
  | 1, 1, 0, 1, x, y => ((1 - x - y + y) / (1 - x - y) ^ 2) / 2
  | 0, 1, 1, 0, x, y => (y / (1 - x - y) ^ 2) / 2
  | 1, 1, 1, 0, x, y => ((1 - x - y + y) / (1 - x - y) ^ 2) / 2
  | 0, 0, 1, 1, x, y => ((1 - x - y + x) / (1 - x - y) ^ 2 + 1 / y) / 2
  | 1, 0, 1, 1, x, y => (x / (1 - x - y) ^ 2 - x / y ^ 2) / 2
  | 0, 1, 1, 1, x, y => (y / (1 - x - y) ^ 2) / 2
  | 1, 1, 1, 1, x, y => ((1 - x - y + y) / (1 - x - y) ^ 2 + 1 / y ^ 2) / 2

theorem hasDerivAt_chrT_fst (k i j : Fin 2) (x y : ℝ) (hx : x ≠ 0) (hz : 1 - x - y ≠ 0) :
    HasDerivAt (fun t => chrT k i j t y) (dchrT 0 k i j x y) x := by
  have hxz := hasDerivAt_idDivAffine_fst y hz
  have hyz := hasDerivAt_constDivAffine_fst y y hz
  have hone := hasDerivAt_oneSubDiv x hx
  have hyx := hasDerivAt_constDiv y x hx
  have hxy : HasDerivAt (fun t : ℝ => t / y) (1 / y) x := by
    simpa using (hasDerivAt_id' (x := x)).div_const y
  fin_cases k <;> fin_cases i <;> fin_cases j <;> simp only [chrT, dchrT]
  · exact ((hxz.sub hone).div_const 2).congr_deriv (by ring)
  · exact (hxz.div_const 2)
  · exact (hxz.div_const 2)
  · exact ((hxz.add hxy).div_const 2)
  · exact ((hyz.add hyx).div_const 2).congr_deriv (by ring)
  · exact (hyz.div_const 2)
  · exact (hyz.div_const 2)
  · exact ((hyz.sub (hasDerivAt_const x ((1 - y) / y))).div_const 2).congr_deriv (by ring)

theorem hasDerivAt_chrT_snd (k i j : Fin 2) (x y : ℝ) (hy : y ≠ 0) (hz : 1 - x - y ≠ 0) :
    HasDerivAt (fun t => chrT k i j x t) (dchrT 1 k i j x y) y := by
  have hxz := hasDerivAt_constDivAffine_snd x x hz
  have hyz := hasDerivAt_idDivAffine_snd x hz
  have hone := hasDerivAt_oneSubDiv y hy
  have hxy : HasDerivAt (fun t : ℝ => x / t) (-x / y ^ 2) y := hasDerivAt_constDiv x y hy
  have hyx : HasDerivAt (fun t : ℝ => t / x) (1 / x) y := by
    simpa using (hasDerivAt_id' (x := y)).div_const x
  fin_cases k <;> fin_cases i <;> fin_cases j <;> simp only [chrT, dchrT]
  · exact ((hxz.sub (hasDerivAt_const y ((1 - x) / x))).div_const 2).congr_deriv (by ring)
  · exact (hxz.div_const 2)
  · exact (hxz.div_const 2)
  · exact ((hxz.add hxy).div_const 2).congr_deriv (by ring)
  · exact ((hyz.add hyx).div_const 2)
  · exact (hyz.div_const 2)
  · exact (hyz.div_const 2)
  · exact ((hyz.sub hone).div_const 2).congr_deriv (by ring)

/-! ## 5. Curvature -/

/-- The Riemann tensor `R^l_{kij}` of a connection given by its Christoffel symbols and
their derivatives, in dimension two. -/
def riemann (chr : Fin 2 → Fin 2 → Fin 2 → ℝ) (dchr : Fin 2 → Fin 2 → Fin 2 → Fin 2 → ℝ)
    (l k i j : Fin 2) : ℝ :=
  dchr i l j k - dchr j l i k + ∑ m : Fin 2, (chr l i m * chr m j k - chr l j m * chr m i k)

/-- The sectional (Gauss) curvature in dimension two: `K = R_{0101} / det g`. -/
def sectional (g : Fin 2 → Fin 2 → ℝ) (chr : Fin 2 → Fin 2 → Fin 2 → ℝ)
    (dchr : Fin 2 → Fin 2 → Fin 2 → Fin 2 → ℝ) : ℝ :=
  (∑ m : Fin 2, g 0 m * riemann chr dchr m 1 0 1) / (g 0 0 * g 1 1 - g 0 1 * g 1 0)

/-- The Gauss curvature of the trinomial Fisher–Rao metric. -/
def gaussianCurvature (x y : ℝ) : ℝ :=
  sectional (fun i j => gL i j x y) (fun k i j => chrT k i j x y)
    (fun d k i j => dchrT d k i j x y)

/-- **The trinomial simplex has constant curvature `+1/4`** — it is a piece of the sphere
of radius `2` under the Hellinger embedding. -/
theorem gaussianCurvature_eq (x y : ℝ) (hx : x ≠ 0) (hy : y ≠ 0) (hz : 1 - x - y ≠ 0) :
    gaussianCurvature x y = 1 / 4 := by
  have hz2 : 1 + (-x - y) ≠ 0 := by intro h; exact hz (by linarith)
  simp only [gaussianCurvature, sectional, riemann, Fin.sum_univ_two, gL, chrT, dchrT]
  field_simp
  ring_nf
  field_simp
  ring

/-! ## 6. Amari's `α`-family -/

/-- The skewness (Amari–Chentsov) tensor `T_{ijl} = E[∂_i l ∂_j l ∂_l l]`. -/
def skewLow (i j l : Fin 2) (x y : ℝ) : ℝ :=
  ∑ a : Fin 3, dprob i a * dprob j a * dprob l a / (prob a x y) ^ 2

/-- The raised skewness tensor `T^k_{ij}`. -/
def skew (k i j : Fin 2) (x y : ℝ) : ℝ := ∑ l : Fin 2, gInv k l x y * skewLow i j l x y

/-- **The skewness tensor of the simplex is `-2Γ`.**  This is what makes the whole
`α`-family a rescaling of the Levi-Civita connection. -/
theorem skew_eq_neg_two_chr (k i j : Fin 2) (x y : ℝ) (hx : x ≠ 0) (hy : y ≠ 0)
    (hz : 1 - x - y ≠ 0) : skew k i j x y = -2 * chrT k i j x y := by
  fin_cases k <;> fin_cases i <;> fin_cases j <;>
    simp only [skew, skewLow, chrT, gInv, dprob, prob, Fin.sum_univ_two, Fin.sum_univ_three] <;>
    field_simp <;> ring

/-- Amari's `α`-connection `Γ^{(α)} = Γ - (α/2) T`. -/
def alphaChr (a : ℝ) (k i j : Fin 2) (x y : ℝ) : ℝ :=
  chrT k i j x y - (a / 2) * skew k i j x y

theorem alphaChr_eq (a : ℝ) (k i j : Fin 2) (x y : ℝ) (hx : x ≠ 0) (hy : y ≠ 0)
    (hz : 1 - x - y ≠ 0) : alphaChr a k i j x y = (1 + a) * chrT k i j x y := by
  rw [alphaChr, skew_eq_neg_two_chr k i j x y hx hy hz]
  ring

/-- The derivative of the `α`-connection. -/
def alphaDchr (a : ℝ) (d k i j : Fin 2) (x y : ℝ) : ℝ := (1 + a) * dchrT d k i j x y

theorem hasDerivAt_alphaChr_fst (a : ℝ) (k i j : Fin 2) (x y : ℝ) (hx : x ≠ 0)
    (hz : 1 - x - y ≠ 0) :
    HasDerivAt (fun t => (1 + a) * chrT k i j t y) (alphaDchr a 0 k i j x y) x :=
  (hasDerivAt_chrT_fst k i j x y hx hz).const_mul (1 + a)

theorem hasDerivAt_alphaChr_snd (a : ℝ) (k i j : Fin 2) (x y : ℝ) (hy : y ≠ 0)
    (hz : 1 - x - y ≠ 0) :
    HasDerivAt (fun t => (1 + a) * chrT k i j x t) (alphaDchr a 1 k i j x y) y :=
  (hasDerivAt_chrT_snd k i j x y hy hz).const_mul (1 + a)

/-- The Gauss curvature of the `α`-connection. -/
def alphaCurv (a x y : ℝ) : ℝ :=
  sectional (fun i j => gL i j x y) (fun k i j => (1 + a) * chrT k i j x y)
    (fun d k i j => alphaDchr a d k i j x y)

/-- **The whole `α`-family has constant curvature `(1 - α²)/4`**, vanishing exactly at the
two flat connections `α = ±1` (the exponential and mixture connections of the multinomial
family). -/
theorem alphaCurv_eq (a x y : ℝ) (hx : x ≠ 0) (hy : y ≠ 0) (hz : 1 - x - y ≠ 0) :
    alphaCurv a x y = (1 - a ^ 2) / 4 := by
  have hz2 : 1 + (-x - y) ≠ 0 := by intro h; exact hz (by linarith)
  simp only [alphaCurv, alphaDchr, sectional, riemann, Fin.sum_univ_two, gL, chrT, dchrT]
  field_simp
  ring_nf
  field_simp
  ring

theorem alphaCurv_zero (x y : ℝ) (hx : x ≠ 0) (hy : y ≠ 0) (hz : 1 - x - y ≠ 0) :
    alphaCurv 0 x y = gaussianCurvature x y := by
  rw [alphaCurv_eq 0 x y hx hy hz, gaussianCurvature_eq x y hx hy hz]
  norm_num

end TrinomialFisher