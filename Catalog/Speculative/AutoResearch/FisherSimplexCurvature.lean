import Mathlib

/-!
# The Levi-Civita connection and Gaussian curvature of a concrete finite-support model

This file carries out, **completely explicitly and with no `sorry`**, the full
Riemannian computation for the smallest genuinely two-dimensional finite-support
statistical model: the *open trinomial simplex*

  `Δ° = {(x, y) : x > 0, y > 0, 1 - x - y > 0}`,
  `p_(x,y) = (x, y, 1 - x - y)` on the three-point sample space `Fin 3`,

equipped with its Fisher–Rao metric.

The pipeline is deliberately staged so that **each geometric object is derived,
not postulated**:

1. `score`  — the score functions are *proved* to be the logarithmic derivatives
   of the model (`hasDerivAt_log_prob_fst/snd`).
2. `fisherMetric` — defined as `E[s_i s_j]` and *proved* equal to the closed form
   `gL` (`fisherMetric_eq_gL`).
3. `dgL` — *proved* to be the genuine partial derivatives of `gL`
   (`hasDerivAt_gL_fst/snd`).
4. `amariC` — the Amari–Chentsov cubic tensor `E[s_i s_j s_k]`; we prove the
   *mixture-coordinate* identity `∂_k g_ij = - C_ijk` (`dgL_eq_neg_amariC`).
5. `chrLow` — the Christoffel symbols of the first kind, together with a general
   Koszul-type **uniqueness theorem** (`levi_civita_unique`) showing that they are
   the *only* torsion-free metric-compatible candidate.
6. `gInv`, `chr` — the inverse metric and the Christoffel symbols of the second
   kind, in closed form, *proved* to be the raised `chrLow` (`chr_eq_raise`).
7. `dchr` — *proved* to be the partial derivatives of `chr`
   (`hasDerivAt_chr_fst/snd`).
8. `riemann`, `sectional`, `alphaCurv` — the curvature machinery, and the two
   headline results:

   * `gaussianCurvature_eq` : the Gauss curvature of the Fisher–Rao metric on the
     trinomial simplex is the **constant `+1/4`** — the model is a piece of a round
     sphere of radius `2`, *not* a hyperbolic plane;
   * `alphaCurv_eq` : for Amari's whole one-parameter family of `α`-connections the
     curvature scalar is `(1 - α²)/4`, which is `≥ 0` for `|α| ≤ 1` and vanishes
     exactly at the dually flat endpoints `α = ±1`.

The methodological point of the mission — *"test curvature only after
identifiability; constant negative curvature is a separate claim, not a corollary
of exponential sensitivity"* — is settled in the companion file
`Combinatorics.FisherSimplexCurvatureConsequences`.
-/

open Finset

noncomputable section

namespace TrinomialFisher

/-! ## 1. The model, its scores, and the Fisher metric -/

/-- The three point-masses of the trinomial model at parameter `(x, y)`. -/
def prob : Fin 3 → ℝ → ℝ → ℝ
  | 0, x, _ => x
  | 1, _, y => y
  | 2, x, y => 1 - x - y

/-- The score functions `s_i(a) = ∂_i log p_a` of the trinomial model, in closed form. -/
def score : Fin 2 → Fin 3 → ℝ → ℝ → ℝ
  | 0, 0, x, _ => 1 / x
  | 0, 1, _, _ => 0
  | 0, 2, x, y => -1 / (1 - x - y)
  | 1, 0, _, _ => 0
  | 1, 1, _, y => 1 / y
  | 1, 2, x, y => -1 / (1 - x - y)

/-- The probabilities sum to one: `p` really is a probability vector. -/
theorem sum_prob (x y : ℝ) : ∑ a : Fin 3, prob a x y = 1 := by
  simp only [Fin.sum_univ_three, prob]; ring

/-- `score 0 · ` is the derivative of `log p` in the first parameter direction. -/
theorem hasDerivAt_log_prob_fst (x y : ℝ) (hx : x ≠ 0) (hz : 1 - x - y ≠ 0) (a : Fin 3) :
    HasDerivAt (fun t => Real.log (prob a t y)) (score 0 a x y) x := by
  have hlin : HasDerivAt (fun t : ℝ => 1 - t - y) (-1) x := by
    simpa using ((hasDerivAt_id x).const_sub (1 : ℝ)).sub_const y
  fin_cases a <;> simp only [prob, score]
  · refine (Real.hasDerivAt_log hx).congr_deriv ?_; ring
  · exact hasDerivAt_const x _
  · refine ((Real.hasDerivAt_log hz).comp x hlin).congr_deriv ?_; ring

/-- `score 1 · ` is the derivative of `log p` in the second parameter direction. -/
theorem hasDerivAt_log_prob_snd (x y : ℝ) (hy : y ≠ 0) (hz : 1 - x - y ≠ 0) (a : Fin 3) :
    HasDerivAt (fun t => Real.log (prob a x t)) (score 1 a x y) y := by
  have hlin : HasDerivAt (fun t : ℝ => 1 - x - t) (-1) y := by
    simpa using (hasDerivAt_const y (1 - x)).sub (hasDerivAt_id y)
  fin_cases a <;> simp only [prob, score]
  · exact hasDerivAt_const y _
  · refine (Real.hasDerivAt_log hy).congr_deriv ?_; ring
  · refine ((Real.hasDerivAt_log hz).comp y hlin).congr_deriv ?_; ring

/-- The scores are centred: `E[s_i] = 0`. This is the identifiability/regularity
check that must precede any curvature claim. -/
theorem sum_prob_score (i : Fin 2) (x y : ℝ) (hx : x ≠ 0) (hy : y ≠ 0) (hz : 1 - x - y ≠ 0) :
    ∑ a : Fin 3, prob a x y * score i a x y = 0 := by
  fin_cases i <;> simp only [Fin.sum_univ_three, prob, score] <;> field_simp <;> ring

/-- The Fisher information metric `g_ij = E[s_i s_j]`. -/
def fisherMetric (i j : Fin 2) (x y : ℝ) : ℝ :=
  ∑ a : Fin 3, prob a x y * (score i a x y * score j a x y)

/-- The Amari–Chentsov cubic tensor `C_ijk = E[s_i s_j s_k]`. -/
def amariC (i j k : Fin 2) (x y : ℝ) : ℝ :=
  ∑ a : Fin 3, prob a x y * (score i a x y * score j a x y * score k a x y)

/-- Closed form of the Fisher metric on the trinomial simplex. -/
def gL : Fin 2 → Fin 2 → ℝ → ℝ → ℝ
  | 0, 0, x, y => 1 / x + 1 / (1 - x - y)
  | 0, 1, x, y => 1 / (1 - x - y)
  | 1, 0, x, y => 1 / (1 - x - y)
  | 1, 1, x, y => 1 / y + 1 / (1 - x - y)

/-- **The Fisher metric of the trinomial model equals its closed form.** -/
theorem fisherMetric_eq_gL (i j : Fin 2) (x y : ℝ)
    (hx : x ≠ 0) (hy : y ≠ 0) (hz : 1 - x - y ≠ 0) :
    fisherMetric i j x y = gL i j x y := by
  fin_cases i <;> fin_cases j <;>
    simp only [fisherMetric, Fin.sum_univ_three, prob, score, gL] <;> field_simp <;> ring

theorem gL_symm (i j : Fin 2) (x y : ℝ) : gL i j x y = gL j i x y := by
  fin_cases i <;> fin_cases j <;> rfl

/-! ## 2. Partial derivatives of the metric, and the Amari–Chentsov tensor -/

/-- Closed form for `∂_k g_ij`. -/
def dgL : Fin 2 → Fin 2 → Fin 2 → ℝ → ℝ → ℝ
  | 0, 0, 0, x, y => -1 / x ^ 2 + 1 / (1 - x - y) ^ 2
  | 0, 0, 1, x, y => 1 / (1 - x - y) ^ 2
  | 0, 1, 0, x, y => 1 / (1 - x - y) ^ 2
  | 0, 1, 1, x, y => 1 / (1 - x - y) ^ 2
  | 1, 0, 0, x, y => 1 / (1 - x - y) ^ 2
  | 1, 0, 1, x, y => 1 / (1 - x - y) ^ 2
  | 1, 1, 0, x, y => 1 / (1 - x - y) ^ 2
  | 1, 1, 1, x, y => -1 / y ^ 2 + 1 / (1 - x - y) ^ 2

theorem dgL_symm (k i j : Fin 2) (x y : ℝ) : dgL k i j x y = dgL k j i x y := by
  fin_cases k <;> fin_cases i <;> fin_cases j <;> rfl

/-- `t ↦ c / (1 - t - y)` differentiated at `x`. -/
theorem hasDerivAt_constDivZ_fst (c x y : ℝ) (hz : 1 - x - y ≠ 0) :
    HasDerivAt (fun t : ℝ => c / (1 - t - y)) (c / (1 - x - y) ^ 2) x := by
  have hlin : HasDerivAt (fun t : ℝ => 1 - t - y) (-1) x := by
    simpa using ((hasDerivAt_id x).const_sub (1 : ℝ)).sub_const y
  refine ((hasDerivAt_const x c).div hlin hz).congr_deriv ?_
  ring

/-- `t ↦ c / (1 - x - t)` differentiated at `y`. -/
theorem hasDerivAt_constDivZ_snd (c x y : ℝ) (hz : 1 - x - y ≠ 0) :
    HasDerivAt (fun t : ℝ => c / (1 - x - t)) (c / (1 - x - y) ^ 2) y := by
  have hlin : HasDerivAt (fun t : ℝ => 1 - x - t) (-1) y := by
    simpa using (hasDerivAt_const y (1 - x)).sub (hasDerivAt_id y)
  refine ((hasDerivAt_const y c).div hlin hz).congr_deriv ?_
  ring

/-- `t ↦ t / (1 - t - y)` differentiated at `x`. -/
theorem hasDerivAt_selfDivZ_fst (x y : ℝ) (hz : 1 - x - y ≠ 0) :
    HasDerivAt (fun t : ℝ => t / (1 - t - y)) (1 / (1 - x - y) + x / (1 - x - y) ^ 2) x := by
  have hlin : HasDerivAt (fun t : ℝ => 1 - t - y) (-1) x := by
    simpa using ((hasDerivAt_id x).const_sub (1 : ℝ)).sub_const y
  refine (((hasDerivAt_id x).div hlin hz)).congr_deriv ?_
  simp only [id_eq]
  field_simp
  ring

/-- `t ↦ t / (1 - x - t)` differentiated at `y`. -/
theorem hasDerivAt_selfDivZ_snd (x y : ℝ) (hz : 1 - x - y ≠ 0) :
    HasDerivAt (fun t : ℝ => t / (1 - x - t)) (1 / (1 - x - y) + y / (1 - x - y) ^ 2) y := by
  have hlin : HasDerivAt (fun t : ℝ => 1 - x - t) (-1) y := by
    simpa using (hasDerivAt_const y (1 - x)).sub (hasDerivAt_id y)
  refine (((hasDerivAt_id y).div hlin hz)).congr_deriv ?_
  simp only [id_eq]
  field_simp
  ring

/-- `t ↦ c / t` differentiated at `x ≠ 0`. -/
theorem hasDerivAt_constDiv (c x : ℝ) (hx : x ≠ 0) :
    HasDerivAt (fun t : ℝ => c / t) (-c / x ^ 2) x := by
  refine ((hasDerivAt_const x c).div (hasDerivAt_id x) hx).congr_deriv ?_
  simp only [id_eq]
  field_simp
  ring

/-- **`dgL` really is the partial derivative of the Fisher metric in `x`.** -/
theorem hasDerivAt_gL_fst (i j : Fin 2) (x y : ℝ) (hx : x ≠ 0) (hz : 1 - x - y ≠ 0) :
    HasDerivAt (fun t => gL i j t y) (dgL 0 i j x y) x := by
  fin_cases i <;> fin_cases j <;> simp only [gL, dgL]
  · exact (hasDerivAt_constDiv 1 x hx).add (hasDerivAt_constDivZ_fst 1 x y hz)
  · exact hasDerivAt_constDivZ_fst 1 x y hz
  · exact hasDerivAt_constDivZ_fst 1 x y hz
  · refine ((hasDerivAt_const x (1 / y)).add (hasDerivAt_constDivZ_fst 1 x y hz)).congr_deriv ?_
    ring

/-- **`dgL` really is the partial derivative of the Fisher metric in `y`.** -/
theorem hasDerivAt_gL_snd (i j : Fin 2) (x y : ℝ) (hy : y ≠ 0) (hz : 1 - x - y ≠ 0) :
    HasDerivAt (fun t => gL i j x t) (dgL 1 i j x y) y := by
  fin_cases i <;> fin_cases j <;> simp only [gL, dgL]
  · refine ((hasDerivAt_const y (1 / x)).add (hasDerivAt_constDivZ_snd 1 x y hz)).congr_deriv ?_
    ring
  · exact hasDerivAt_constDivZ_snd 1 x y hz
  · exact hasDerivAt_constDivZ_snd 1 x y hz
  · exact (hasDerivAt_constDiv 1 y hy).add (hasDerivAt_constDivZ_snd 1 x y hz)

/-- **In mixture coordinates the derivative of the Fisher metric is minus the
Amari–Chentsov tensor:** `∂_k g_ij = - C_ijk`.  (In *natural* coordinates of an
exponential family one gets `+C`; the sign flip is exactly the `α ↦ -α` duality.) -/
theorem dgL_eq_neg_amariC (k i j : Fin 2) (x y : ℝ)
    (hx : x ≠ 0) (hy : y ≠ 0) (hz : 1 - x - y ≠ 0) :
    dgL k i j x y = - amariC i j k x y := by
  fin_cases k <;> fin_cases i <;> fin_cases j <;>
    simp only [dgL, amariC, Fin.sum_univ_three, prob, score] <;> field_simp <;> ring

/-! ## 3. The Levi-Civita connection: Christoffel symbols of the first kind -/

/-- Christoffel symbols of the first kind, `Γ_{ij,l} = ½(∂_i g_jl + ∂_j g_il - ∂_l g_ij)`. -/
def chrLow (i j l : Fin 2) (x y : ℝ) : ℝ :=
  (dgL i j l x y + dgL j i l x y - dgL l i j x y) / 2

/-- **Koszul uniqueness.**  If `D k i j` plays the role of `∂_k g_ij` and `G` is any
symmetric (torsion-free) system compatible with it, then `G` is forced to be the
half-sum defining `chrLow`.  This is the general statement that the Levi-Civita
connection is unique; it holds over an arbitrary index type. -/
theorem levi_civita_unique {ι : Type*} (D G : ι → ι → ι → ℝ)
    (hGsym : ∀ i j l, G i j l = G j i l)
    (hcompat : ∀ k i j, D k i j = G k i j + G k j i) (i j l : ι) :
    G i j l = (D i j l + D j i l - D l i j) / 2 := by
  have h1 := hcompat i j l
  have h2 := hcompat j i l
  have h3 := hcompat l i j
  have e1 := hGsym i l j
  have e2 := hGsym j l i
  have e3 := hGsym j i l
  linarith

/-- Torsion-freeness of the Levi-Civita connection. -/
theorem chrLow_symm (i j l : Fin 2) (x y : ℝ) : chrLow i j l x y = chrLow j i l x y := by
  simp only [chrLow, dgL_symm l i j]
  ring

/-- Metric compatibility `∂_k g_ij = Γ_{ki,j} + Γ_{kj,i}`. -/
theorem dgL_eq_chrLow_add (k i j : Fin 2) (x y : ℝ) :
    dgL k i j x y = chrLow k i j x y + chrLow k j i x y := by
  simp only [chrLow, dgL_symm i k j, dgL_symm j k i, dgL_symm k i j]
  ring

/-- `chrLow` is the **unique** torsion-free metric-compatible connection: any other
candidate coincides with it. -/
theorem chrLow_unique (G : Fin 2 → Fin 2 → Fin 2 → ℝ) (x y : ℝ)
    (hGsym : ∀ i j l, G i j l = G j i l)
    (hcompat : ∀ k i j, dgL k i j x y = G k i j + G k j i) (i j l : Fin 2) :
    G i j l = chrLow i j l x y :=
  levi_civita_unique (fun k i j => dgL k i j x y) G hGsym hcompat i j l

/-- The Levi-Civita symbols are `-½` times the Amari–Chentsov tensor. -/
theorem chrLow_eq_neg_half_amariC (i j l : Fin 2) (x y : ℝ)
    (hx : x ≠ 0) (hy : y ≠ 0) (hz : 1 - x - y ≠ 0) :
    chrLow i j l x y = -(1 / 2) * amariC i j l x y := by
  simp only [chrLow, dgL_eq_neg_amariC _ _ _ x y hx hy hz]
  have h1 : amariC j l i x y = amariC i j l x y := by
    simp only [amariC]; exact Finset.sum_congr rfl fun a _ => by ring
  have h2 : amariC i l j x y = amariC i j l x y := by
    simp only [amariC]; exact Finset.sum_congr rfl fun a _ => by ring
  rw [h1, h2]
  ring

/-- **The α-connection collapse.**  Amari's α-connection of the first kind is
`Γ^{(α)}_{ij,l} = Γ_{ij,l} - (α/2) C_ijl`.  Because on this model
`Γ_{ij,l} = -½ C_ijl`, the whole α-family is a *scalar multiple* of the
Levi-Civita connection: `Γ^{(α)} = (1 + α) Γ`. -/
theorem alphaChrLow_eq (a : ℝ) (i j l : Fin 2) (x y : ℝ)
    (hx : x ≠ 0) (hy : y ≠ 0) (hz : 1 - x - y ≠ 0) :
    chrLow i j l x y - (a / 2) * amariC i j l x y = (1 + a) * chrLow i j l x y := by
  rw [chrLow_eq_neg_half_amariC i j l x y hx hy hz]
  ring

/-! ## 4. The inverse metric and the Christoffel symbols of the second kind -/

/-- The inverse Fisher metric: the multinomial covariance `g^{ij} = δ_ij p_i - p_i p_j`. -/
def gInv : Fin 2 → Fin 2 → ℝ → ℝ → ℝ
  | 0, 0, x, _ => x * (1 - x)
  | 0, 1, x, y => -(x * y)
  | 1, 0, x, y => -(x * y)
  | 1, 1, _, y => y * (1 - y)

/-- The determinant of the Fisher metric is `1 / (x y (1 - x - y))`. -/
theorem det_gL (x y : ℝ) (hx : x ≠ 0) (hy : y ≠ 0) (hz : 1 - x - y ≠ 0) :
    gL 0 0 x y * gL 1 1 x y - gL 0 1 x y * gL 1 0 x y = 1 / (x * y * (1 - x - y)) := by
  simp only [gL]
  field_simp
  ring

/-- `gInv` is a genuine two-sided inverse of `gL`. -/
theorem gInv_mul_gL (i j : Fin 2) (x y : ℝ) (hx : x ≠ 0) (hy : y ≠ 0) (hz : 1 - x - y ≠ 0) :
    ∑ l : Fin 2, gInv i l x y * gL l j x y = if i = j then 1 else 0 := by
  fin_cases i <;> fin_cases j <;> simp only [Fin.sum_univ_two, gInv, gL] <;> norm_num <;>
    field_simp <;> ring

/-- Christoffel symbols of the second kind `Γ^k_{ij}`, in closed form. -/
def chr : Fin 2 → Fin 2 → Fin 2 → ℝ → ℝ → ℝ
  | 0, 0, 0, x, y => (x / (1 - x - y) - 1 / x + 1) / 2
  | 1, 0, 0, x, y => (y / (1 - x - y) + y / x) / 2
  | 0, 0, 1, x, y => (x / (1 - x - y)) / 2
  | 0, 1, 0, x, y => (x / (1 - x - y)) / 2
  | 1, 0, 1, x, y => (y / (1 - x - y)) / 2
  | 1, 1, 0, x, y => (y / (1 - x - y)) / 2
  | 0, 1, 1, x, y => (x / (1 - x - y) + x / y) / 2
  | 1, 1, 1, x, y => (y / (1 - x - y) - 1 / y + 1) / 2

/-- **The closed-form `chr` is the raised Levi-Civita connection**
`Γ^k_{ij} = g^{kl} Γ_{ij,l}`. -/
theorem chr_eq_raise (k i j : Fin 2) (x y : ℝ) (hx : x ≠ 0) (hy : y ≠ 0) (hz : 1 - x - y ≠ 0) :
    chr k i j x y = ∑ l : Fin 2, gInv k l x y * chrLow i j l x y := by
  fin_cases k <;> fin_cases i <;> fin_cases j <;>
    simp only [chr, chrLow, dgL, gInv, Fin.sum_univ_two] <;> field_simp <;> ring

theorem chr_symm (k i j : Fin 2) (x y : ℝ) : chr k i j x y = chr k j i x y := by
  fin_cases k <;> fin_cases i <;> fin_cases j <;> rfl

/-! ## 5. Partial derivatives of the Christoffel symbols -/

/-- Closed form for `∂_d Γ^k_{ij}`. -/
def dchr : Fin 2 → Fin 2 → Fin 2 → Fin 2 → ℝ → ℝ → ℝ
  | 0, 0, 0, 0, x, y => (1 / (1 - x - y) + x / (1 - x - y) ^ 2 + 1 / x ^ 2) / 2
  | 1, 0, 0, 0, x, y => (x / (1 - x - y) ^ 2) / 2
  | 0, 1, 0, 0, x, y => (y / (1 - x - y) ^ 2 - y / x ^ 2) / 2
  | 1, 1, 0, 0, x, y => (1 / (1 - x - y) + y / (1 - x - y) ^ 2 + 1 / x) / 2
  | 0, 0, 0, 1, x, y => (1 / (1 - x - y) + x / (1 - x - y) ^ 2) / 2
  | 1, 0, 0, 1, x, y => (x / (1 - x - y) ^ 2) / 2
  | 0, 0, 1, 0, x, y => (1 / (1 - x - y) + x / (1 - x - y) ^ 2) / 2
  | 1, 0, 1, 0, x, y => (x / (1 - x - y) ^ 2) / 2
  | 0, 1, 0, 1, x, y => (y / (1 - x - y) ^ 2) / 2
  | 1, 1, 0, 1, x, y => (1 / (1 - x - y) + y / (1 - x - y) ^ 2) / 2
  | 0, 1, 1, 0, x, y => (y / (1 - x - y) ^ 2) / 2
  | 1, 1, 1, 0, x, y => (1 / (1 - x - y) + y / (1 - x - y) ^ 2) / 2
  | 0, 0, 1, 1, x, y => (1 / (1 - x - y) + x / (1 - x - y) ^ 2 + 1 / y) / 2
  | 1, 0, 1, 1, x, y => (x / (1 - x - y) ^ 2 - x / y ^ 2) / 2
  | 0, 1, 1, 1, x, y => (y / (1 - x - y) ^ 2) / 2
  | 1, 1, 1, 1, x, y => (1 / (1 - x - y) + y / (1 - x - y) ^ 2 + 1 / y ^ 2) / 2

/-- **`dchr` really is the partial derivative of `chr` in `x`.** -/
theorem hasDerivAt_chr_fst (k i j : Fin 2) (x y : ℝ)
    (hx : x ≠ 0) (hz : 1 - x - y ≠ 0) :
    HasDerivAt (fun t => chr k i j t y) (dchr 0 k i j x y) x := by
  have hA := hasDerivAt_selfDivZ_fst x y hz
  have hC := hasDerivAt_constDiv 1 x hx
  have hCy := hasDerivAt_constDiv y x hx
  have hBy := hasDerivAt_constDivZ_fst y x y hz
  have hDy : HasDerivAt (fun t : ℝ => t / y) (1 / y) x := by
    simpa [div_eq_mul_inv, one_div] using (hasDerivAt_id x).div_const y
  fin_cases k <;> fin_cases i <;> fin_cases j <;> simp only [chr, dchr]
  · refine (((hA.sub hC).add_const 1).div_const 2).congr_deriv ?_; ring
  · exact hA.div_const 2
  · exact hA.div_const 2
  · refine ((hA.add hDy).div_const 2).congr_deriv ?_; ring
  · refine ((hBy.add hCy).div_const 2).congr_deriv ?_; ring
  · exact hBy.div_const 2
  · exact hBy.div_const 2
  · refine (((hBy.sub_const (1 / y)).add_const 1).div_const 2).congr_deriv ?_; ring

/-- **`dchr` really is the partial derivative of `chr` in `y`.** -/
theorem hasDerivAt_chr_snd (k i j : Fin 2) (x y : ℝ)
    (hy : y ≠ 0) (hz : 1 - x - y ≠ 0) :
    HasDerivAt (fun t => chr k i j x t) (dchr 1 k i j x y) y := by
  have hA := hasDerivAt_selfDivZ_snd x y hz
  have hC := hasDerivAt_constDiv 1 y hy
  have hCx := hasDerivAt_constDiv x y hy
  have hBx := hasDerivAt_constDivZ_snd x x y hz
  have hDx : HasDerivAt (fun t : ℝ => t / x) (1 / x) y := by
    simpa [div_eq_mul_inv, one_div] using (hasDerivAt_id y).div_const x
  fin_cases k <;> fin_cases i <;> fin_cases j <;> simp only [chr, dchr]
  · refine ((hBx.sub_const (1 / x)).add_const 1 |>.div_const 2).congr_deriv ?_; ring
  · exact hBx.div_const 2
  · exact hBx.div_const 2
  · refine ((hBx.add hCx).div_const 2).congr_deriv ?_; ring
  · refine ((hA.add hDx).div_const 2).congr_deriv ?_; ring
  · exact hA.div_const 2
  · exact hA.div_const 2
  · refine (((hA.sub hC).add_const 1).div_const 2).congr_deriv ?_; ring

/-! ## 6. Curvature -/

/-- The Riemann tensor of an arbitrary affine connection on a `2`-dimensional chart:
`R^l_{k i j} = ∂_i Γ^l_{jk} - ∂_j Γ^l_{ik} + Γ^l_{im} Γ^m_{jk} - Γ^l_{jm} Γ^m_{ik}`. -/
def riemann (G : Fin 2 → Fin 2 → Fin 2 → ℝ) (dG : Fin 2 → Fin 2 → Fin 2 → Fin 2 → ℝ)
    (l k i j : Fin 2) : ℝ :=
  dG i l j k - dG j l i k + ∑ m : Fin 2, (G l i m * G m j k - G l j m * G m i k)

/-- The sectional (Gauss) curvature scalar `⟨R(∂₀,∂₁)∂₁, ∂₀⟩ / det g`. -/
def sectional (g : Fin 2 → Fin 2 → ℝ) (G : Fin 2 → Fin 2 → Fin 2 → ℝ)
    (dG : Fin 2 → Fin 2 → Fin 2 → Fin 2 → ℝ) : ℝ :=
  (∑ l : Fin 2, riemann G dG l 1 0 1 * g l 0) / (g 0 0 * g 1 1 - g 0 1 * g 1 0)

/-- The curvature scalar of Amari's `α`-connection on the trinomial simplex. -/
def alphaCurv (a x y : ℝ) : ℝ :=
  sectional (fun i j => gL i j x y) (fun k i j => (1 + a) * chr k i j x y)
    (fun d k i j => (1 + a) * dchr d k i j x y)

/-- The Gauss curvature of the Fisher–Rao metric on the trinomial simplex. -/
def gaussianCurvature (x y : ℝ) : ℝ := alphaCurv 0 x y

/-- The contracted Riemann numerator `⟨R^{(α)}(∂₀,∂₁)∂₁, ∂₀⟩` of the `α`-connection. -/
theorem alpha_riemann_num (a x y : ℝ) (hx : x ≠ 0) (hy : y ≠ 0) (hz : 1 - x - y ≠ 0) :
    (∑ l : Fin 2, riemann (fun k i j => (1 + a) * chr k i j x y)
        (fun d k i j => (1 + a) * dchr d k i j x y) l 1 0 1 * gL l 0 x y)
      = (1 - a ^ 2) / 4 * (1 / (x * y * (1 - x - y))) := by
  simp only [riemann, Fin.sum_univ_two, gL, chr, dchr]
  field_simp
  ring

/-- **Main computation.**  The curvature scalar of the `α`-connection is the
constant `(1 - α²)/4` at every point of the open simplex. -/
theorem alphaCurv_eq (a x y : ℝ) (hx : x ≠ 0) (hy : y ≠ 0) (hz : 1 - x - y ≠ 0) :
    alphaCurv a x y = (1 - a ^ 2) / 4 := by
  have hnum := alpha_riemann_num a x y hx hy hz
  have hdet := det_gL x y hx hy hz
  simp only [alphaCurv, sectional]
  rw [hnum, hdet]
  field_simp

/-- **Headline theorem.**  The Fisher–Rao geometry of the trinomial model has
*constant Gauss curvature `+1/4`*: it is (an open piece of) the round sphere of
radius `2`, and in particular is **not** negatively curved anywhere. -/
theorem gaussianCurvature_eq (x y : ℝ) (hx : x ≠ 0) (hy : y ≠ 0) (hz : 1 - x - y ≠ 0) :
    gaussianCurvature x y = 1 / 4 := by
  rw [gaussianCurvature, alphaCurv_eq 0 x y hx hy hz]
  norm_num

/-- Amari's dual flatness: the `e`-connection (`α = 1`) is flat. -/
theorem alphaCurv_one (x y : ℝ) (hx : x ≠ 0) (hy : y ≠ 0) (hz : 1 - x - y ≠ 0) :
    alphaCurv 1 x y = 0 := by
  rw [alphaCurv_eq 1 x y hx hy hz]; norm_num

/-- Amari's dual flatness: the `m`-connection (`α = -1`) is flat. -/
theorem alphaCurv_neg_one (x y : ℝ) (hx : x ≠ 0) (hy : y ≠ 0) (hz : 1 - x - y ≠ 0) :
    alphaCurv (-1) x y = 0 := by
  rw [alphaCurv_eq (-1) x y hx hy hz]; norm_num

end TrinomialFisher