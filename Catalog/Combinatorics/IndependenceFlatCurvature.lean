import Combinatorics.TiedTwoGroupCurvature

/-!
# A flat finite-support model, and the curvature trichotomy

`Combinatorics.FisherSimplexCurvature` computes the Gauss curvature of the full
trinomial simplex (`+1/4`, constant) and `Combinatorics.TiedTwoGroupCurvature`
computes it for the tied two-group model (negative at one point, positive at
another).  This file supplies the missing third sign by computing the Levi-Civita
connection and curvature of the **2×2 independence model**

  `p = (u v, u(1-v), (1-u)v, (1-u)(1-v))`,  `(u, v) ∈ (0,1)²`,

i.e. two independent Bernoulli coordinates.  Its Fisher metric is the *product*
metric `diag(1/(u-u²), 1/(v-v²))`, whose two factors are one-dimensional, and the
model turns out to be **identically flat**: `indepCurvature u v = 0` for all `u, v`.

Combining the three computations gives `curvature_trichotomy`: within the class of
four-outcome, two-parameter finite-support models the Fisher–Rao Gauss curvature
takes strictly positive, zero and strictly negative values.  Hence "the curvature
of a finite-support model" is not a well-defined sign, let alone a constant, and
"constant negative curvature" is a genuinely separate claim that has to be verified
model by model — exactly as the guiding question demands.

As before nothing is postulated: the scores are proved to be logarithmic
derivatives, the metric is proved to be `E[s_i s_j]`, the connection is proved to be
torsion-free and metric-compatible (hence Levi-Civita, by
`TrinomialFisher.levi_civita_unique`), and `dchrI` is proved to be its derivative.
-/

open Finset TrinomialFisher

noncomputable section

namespace IndependenceModel

/-! ## 1. The model and its scores -/

/-- Outcome probabilities of the 2×2 independence model. -/
def probI : Fin 4 → ℝ → ℝ → ℝ
  | 0, u, v => u * v
  | 1, u, v => u * (1 - v)
  | 2, u, v => (1 - u) * v
  | 3, u, v => (1 - u) * (1 - v)

/-- Scores `∂_i log p_a` of the independence model. -/
def scoreI : Fin 2 → Fin 4 → ℝ → ℝ → ℝ
  | 0, 0, u, _ => 1 / u
  | 0, 1, u, _ => 1 / u
  | 0, 2, u, _ => -1 / (1 - u)
  | 0, 3, u, _ => -1 / (1 - u)
  | 1, 0, _, v => 1 / v
  | 1, 1, _, v => -1 / (1 - v)
  | 1, 2, _, v => 1 / v
  | 1, 3, _, v => -1 / (1 - v)

/-- The parameter domain: the open unit square. -/
structure DomI (u v : ℝ) : Prop where
  u_pos : 0 < u
  u_lt : u < 1
  v_pos : 0 < v
  v_lt : v < 1

namespace DomI
variable {u v : ℝ}

theorem u1_pos (h : DomI u v) : 0 < 1 - u := by have := h.u_lt; linarith
theorem v1_pos (h : DomI u v) : 0 < 1 - v := by have := h.v_lt; linarith
theorem usq_pos (h : DomI u v) : 0 < u - u ^ 2 := by
  have h1 := h.u_pos; have h2 := h.u1_pos; nlinarith
theorem vsq_pos (h : DomI u v) : 0 < v - v ^ 2 := by
  have h1 := h.v_pos; have h2 := h.v1_pos; nlinarith

theorem u_ne (h : DomI u v) : u ≠ 0 := ne_of_gt h.u_pos
theorem u1_ne (h : DomI u v) : 1 - u ≠ 0 := ne_of_gt h.u1_pos
theorem v_ne (h : DomI u v) : v ≠ 0 := ne_of_gt h.v_pos
theorem v1_ne (h : DomI u v) : 1 - v ≠ 0 := ne_of_gt h.v1_pos
theorem usq_ne (h : DomI u v) : u - u ^ 2 ≠ 0 := ne_of_gt h.usq_pos
theorem vsq_ne (h : DomI u v) : v - v ^ 2 ≠ 0 := ne_of_gt h.vsq_pos

end DomI

theorem probI_pos {u v : ℝ} (h : DomI u v) (a : Fin 4) : 0 < probI a u v := by
  have h1 := h.u_pos
  have h2 := h.u1_pos
  have h3 := h.v_pos
  have h4 := h.v1_pos
  fin_cases a <;> simp only [probI]
  · exact mul_pos h1 h3
  · exact mul_pos h1 h4
  · exact mul_pos h2 h3
  · exact mul_pos h2 h4

theorem probI_ne {u v : ℝ} (h : DomI u v) (a : Fin 4) : probI a u v ≠ 0 :=
  ne_of_gt (probI_pos h a)

/-- The probabilities sum to one. -/
theorem sum_probI (u v : ℝ) : ∑ a : Fin 4, probI a u v = 1 := by
  simp only [Fin.sum_univ_four, probI]; ring

theorem hasDerivAt_log_probI_fst (u v : ℝ) (h : DomI u v) (a : Fin 4) :
    HasDerivAt (fun r => Real.log (probI a r v)) (scoreI 0 a u v) u := by
  have hA : HasDerivAt (fun r : ℝ => r * v) v u :=
    TiedTwoGroup.hasDerivAt_of_quartic 0 0 0 v 0 u _ (fun r => by ring) (by ring)
  have hB : HasDerivAt (fun r : ℝ => r * (1 - v)) (1 - v) u :=
    TiedTwoGroup.hasDerivAt_of_quartic 0 0 0 (1 - v) 0 u _ (fun r => by ring) (by ring)
  have hC : HasDerivAt (fun r : ℝ => (1 - r) * v) (-v) u :=
    TiedTwoGroup.hasDerivAt_of_quartic 0 0 0 (-v) v u _ (fun r => by ring) (by ring)
  have hD : HasDerivAt (fun r : ℝ => (1 - r) * (1 - v)) (-(1 - v)) u :=
    TiedTwoGroup.hasDerivAt_of_quartic 0 0 0 (-(1 - v)) (1 - v) u _ (fun r => by ring) (by ring)
  have e0 := probI_ne h 0
  have e1 := probI_ne h 1
  have e2 := probI_ne h 2
  have e3 := probI_ne h 3
  simp only [probI] at e0 e1 e2 e3
  have hu := h.u_ne
  have hu1 := h.u1_ne
  have hv := h.v_ne
  have hv1 := h.v1_ne
  fin_cases a <;> simp only [probI, scoreI]
  · refine ((Real.hasDerivAt_log e0).comp u hA).congr_deriv ?_
    field_simp
  · refine ((Real.hasDerivAt_log e1).comp u hB).congr_deriv ?_
    field_simp
  · refine ((Real.hasDerivAt_log e2).comp u hC).congr_deriv ?_
    field_simp
  · refine ((Real.hasDerivAt_log e3).comp u hD).congr_deriv ?_
    field_simp

theorem hasDerivAt_log_probI_snd (u v : ℝ) (h : DomI u v) (a : Fin 4) :
    HasDerivAt (fun r => Real.log (probI a u r)) (scoreI 1 a u v) v := by
  have hA : HasDerivAt (fun r : ℝ => u * r) u v :=
    TiedTwoGroup.hasDerivAt_of_quartic 0 0 0 u 0 v _ (fun r => by ring) (by ring)
  have hB : HasDerivAt (fun r : ℝ => u * (1 - r)) (-u) v :=
    TiedTwoGroup.hasDerivAt_of_quartic 0 0 0 (-u) u v _ (fun r => by ring) (by ring)
  have hC : HasDerivAt (fun r : ℝ => (1 - u) * r) (1 - u) v :=
    TiedTwoGroup.hasDerivAt_of_quartic 0 0 0 (1 - u) 0 v _ (fun r => by ring) (by ring)
  have hD : HasDerivAt (fun r : ℝ => (1 - u) * (1 - r)) (-(1 - u)) v :=
    TiedTwoGroup.hasDerivAt_of_quartic 0 0 0 (-(1 - u)) (1 - u) v _ (fun r => by ring) (by ring)
  have e0 := probI_ne h 0
  have e1 := probI_ne h 1
  have e2 := probI_ne h 2
  have e3 := probI_ne h 3
  simp only [probI] at e0 e1 e2 e3
  have hu := h.u_ne
  have hu1 := h.u1_ne
  have hv := h.v_ne
  have hv1 := h.v1_ne
  fin_cases a <;> simp only [probI, scoreI]
  · refine ((Real.hasDerivAt_log e0).comp v hA).congr_deriv ?_
    field_simp
  · refine ((Real.hasDerivAt_log e1).comp v hB).congr_deriv ?_
    field_simp
  · refine ((Real.hasDerivAt_log e2).comp v hC).congr_deriv ?_
    field_simp
  · refine ((Real.hasDerivAt_log e3).comp v hD).congr_deriv ?_
    field_simp

/-! ## 2. The Fisher metric is the product metric -/

/-- The Fisher information metric of the independence model. -/
def fisherI (i j : Fin 2) (u v : ℝ) : ℝ :=
  ∑ a : Fin 4, probI a u v * (scoreI i a u v * scoreI j a u v)

/-- Closed form: the product (diagonal) metric. -/
def gI : Fin 2 → Fin 2 → ℝ → ℝ → ℝ
  | 0, 0, u, _ => 1 / (u - u ^ 2)
  | 0, 1, _, _ => 0
  | 1, 0, _, _ => 0
  | 1, 1, _, v => 1 / (v - v ^ 2)

/-- **The Fisher metric of the independence model is the product metric.** -/
theorem fisherI_eq_gI (i j : Fin 2) (u v : ℝ) (h : DomI u v) :
    fisherI i j u v = gI i j u v := by
  have hu := h.u_ne
  have hu1 := h.u1_ne
  have hv := h.v_ne
  have hv1 := h.v1_ne
  have husq := h.usq_ne
  have hvsq := h.vsq_ne
  fin_cases i <;> fin_cases j <;>
    simp only [fisherI, Fin.sum_univ_four, probI, scoreI, gI] <;> field_simp <;> ring

/-! ## 3. Derivatives of the metric -/

/-- Closed form for `∂_k g_ij`. -/
def dgI : Fin 2 → Fin 2 → Fin 2 → ℝ → ℝ → ℝ
  | 0, 0, 0, u, _ => (2 * u - 1) / (u - u ^ 2) ^ 2
  | 1, 1, 1, _, v => (2 * v - 1) / (v - v ^ 2) ^ 2
  | _, _, _, _, _ => 0

theorem hasDerivAt_gI_fst (i j : Fin 2) (u v : ℝ) (h : DomI u v) :
    HasDerivAt (fun r => gI i j r v) (dgI 0 i j u v) u := by
  have husq := h.usq_ne
  have hden : HasDerivAt (fun r : ℝ => r - r ^ 2) (1 - 2 * u) u :=
    TiedTwoGroup.hasDerivAt_of_quartic 0 0 (-1) 1 0 u _ (fun r => by ring) (by ring)
  fin_cases i <;> fin_cases j <;> simp only [gI, dgI]
  · refine ((hasDerivAt_const u (1 : ℝ)).div hden husq).congr_deriv ?_
    field_simp
    ring
  · exact hasDerivAt_const u _
  · exact hasDerivAt_const u _
  · exact hasDerivAt_const u _

theorem hasDerivAt_gI_snd (i j : Fin 2) (u v : ℝ) (h : DomI u v) :
    HasDerivAt (fun r => gI i j u r) (dgI 1 i j u v) v := by
  have hvsq := h.vsq_ne
  have hden : HasDerivAt (fun r : ℝ => r - r ^ 2) (1 - 2 * v) v :=
    TiedTwoGroup.hasDerivAt_of_quartic 0 0 (-1) 1 0 v _ (fun r => by ring) (by ring)
  fin_cases i <;> fin_cases j <;> simp only [gI, dgI]
  · exact hasDerivAt_const v _
  · exact hasDerivAt_const v _
  · exact hasDerivAt_const v _
  · refine ((hasDerivAt_const v (1 : ℝ)).div hden hvsq).congr_deriv ?_
    field_simp
    ring

/-! ## 4. The Levi-Civita connection -/

/-- Christoffel symbols of the second kind of the independence model. -/
def chrI : Fin 2 → Fin 2 → Fin 2 → ℝ → ℝ → ℝ
  | 0, 0, 0, u, _ => (2 * u - 1) / (2 * (u - u ^ 2))
  | 1, 1, 1, _, v => (2 * v - 1) / (2 * (v - v ^ 2))
  | _, _, _, _, _ => 0

/-- Torsion-freeness. -/
theorem chrI_symm (k i j : Fin 2) (u v : ℝ) : chrI k i j u v = chrI k j i u v := by
  fin_cases k <;> fin_cases i <;> fin_cases j <;> rfl

/-- **Metric compatibility** `∂_k g_ij = Σ_m (g_jm Γ^m_{ki} + g_im Γ^m_{kj})`. -/
theorem metric_compatI (k i j : Fin 2) (u v : ℝ) (h : DomI u v) :
    dgI k i j u v = ∑ m : Fin 2, (gI j m u v * chrI m k i u v + gI i m u v * chrI m k j u v) := by
  have husq := h.usq_ne
  have hvsq := h.vsq_ne
  fin_cases k <;> fin_cases i <;> fin_cases j <;>
    simp only [dgI, gI, chrI, Fin.sum_univ_two] <;> field_simp <;> try ring

/-- **`chrI` is the Levi-Civita connection** of the product Fisher metric. -/
theorem chrI_is_levi_civita (i j l : Fin 2) (u v : ℝ) (h : DomI u v) :
    ∑ m : Fin 2, gI l m u v * chrI m i j u v
      = (dgI i j l u v + dgI j i l u v - dgI l i j u v) / 2 := by
  refine levi_civita_unique (fun k i j => dgI k i j u v)
    (fun i j l => ∑ m : Fin 2, gI l m u v * chrI m i j u v) ?_ ?_ i j l
  · intro i j l
    simp only [chrI_symm _ i j]
  · intro k i j
    simp only [metric_compatI k i j u v h, Fin.sum_univ_two]
    ring

/-! ## 5. Derivatives of the connection -/

/-- Closed form for `∂_d Γ^k_{ij}`. -/
def dchrI : Fin 2 → Fin 2 → Fin 2 → Fin 2 → ℝ → ℝ → ℝ
  | 0, 0, 0, 0, u, _ => (2 * u ^ 2 - 2 * u + 1) / (2 * (u - u ^ 2) ^ 2)
  | 1, 1, 1, 1, _, v => (2 * v ^ 2 - 2 * v + 1) / (2 * (v - v ^ 2) ^ 2)
  | _, _, _, _, _, _ => 0

theorem hasDerivAt_chrI_fst (k i j : Fin 2) (u v : ℝ) (h : DomI u v) :
    HasDerivAt (fun r => chrI k i j r v) (dchrI 0 k i j u v) u := by
  have husq := h.usq_ne
  have hd : 2 * (u - u ^ 2) ≠ 0 := by
    simp only [ne_eq, mul_eq_zero]; push_neg; exact ⟨two_ne_zero, husq⟩
  have hn : HasDerivAt (fun r : ℝ => 2 * r - 1) 2 u :=
    TiedTwoGroup.hasDerivAt_of_quartic 0 0 0 2 (-1) u _ (fun r => by ring) (by ring)
  have hb : HasDerivAt (fun r : ℝ => 2 * (r - r ^ 2)) (2 - 4 * u) u :=
    TiedTwoGroup.hasDerivAt_of_quartic 0 0 (-2) 2 0 u _ (fun r => by ring) (by ring)
  fin_cases k <;> fin_cases i <;> fin_cases j <;> simp only [chrI, dchrI]
  · refine (hn.div hb hd).congr_deriv ?_
    field_simp
    ring
  · exact hasDerivAt_const u _
  · exact hasDerivAt_const u _
  · exact hasDerivAt_const u _
  · exact hasDerivAt_const u _
  · exact hasDerivAt_const u _
  · exact hasDerivAt_const u _
  · exact hasDerivAt_const u _

theorem hasDerivAt_chrI_snd (k i j : Fin 2) (u v : ℝ) (h : DomI u v) :
    HasDerivAt (fun r => chrI k i j u r) (dchrI 1 k i j u v) v := by
  have hvsq := h.vsq_ne
  have hd : 2 * (v - v ^ 2) ≠ 0 := by
    simp only [ne_eq, mul_eq_zero]; push_neg; exact ⟨two_ne_zero, hvsq⟩
  have hn : HasDerivAt (fun r : ℝ => 2 * r - 1) 2 v :=
    TiedTwoGroup.hasDerivAt_of_quartic 0 0 0 2 (-1) v _ (fun r => by ring) (by ring)
  have hb : HasDerivAt (fun r : ℝ => 2 * (r - r ^ 2)) (2 - 4 * v) v :=
    TiedTwoGroup.hasDerivAt_of_quartic 0 0 (-2) 2 0 v _ (fun r => by ring) (by ring)
  fin_cases k <;> fin_cases i <;> fin_cases j <;> simp only [chrI, dchrI]
  · exact hasDerivAt_const v _
  · exact hasDerivAt_const v _
  · exact hasDerivAt_const v _
  · exact hasDerivAt_const v _
  · exact hasDerivAt_const v _
  · exact hasDerivAt_const v _
  · exact hasDerivAt_const v _
  · refine (hn.div hb hd).congr_deriv ?_
    field_simp
    ring

/-! ## 6. Flatness -/

/-- The Gauss curvature of the independence model, computed with the same
`riemann`/`sectional` machinery as every other model in this development. -/
def indepCurvature (u v : ℝ) : ℝ :=
  sectional (fun i j => gI i j u v) (fun k i j => chrI k i j u v)
    (fun d k i j => dchrI d k i j u v)

/-- **The 2×2 independence model is Fisher-flat.**  Every mixed Christoffel symbol
vanishes, so the whole Riemann tensor does; the curvature is identically zero, at
every parameter value, with no positivity hypothesis needed. -/
theorem indepCurvature_eq_zero (u v : ℝ) : indepCurvature u v = 0 := by
  simp only [indepCurvature, sectional, riemann, Fin.sum_univ_two, gI, chrI, dchrI]
  rw [div_eq_zero_iff]
  left
  ring

/-- The independence model is flat but not isometric to the trinomial simplex,
whose curvature is `1/4`. -/
theorem indep_ne_simplex (u v x y : ℝ) (hx : x ≠ 0) (hy : y ≠ 0) (hz : 1 - x - y ≠ 0) :
    indepCurvature u v ≠ gaussianCurvature x y := by
  rw [indepCurvature_eq_zero, gaussianCurvature_eq x y hx hy hz]
  norm_num

/-! ## 7. The curvature trichotomy -/

/-- **Curvature trichotomy for finite-support models.**  Among four-outcome,
two-parameter finite-support statistical models the Fisher–Rao Gauss curvature —
computed by one and the same Levi-Civita machinery — attains strictly positive,
exactly zero and strictly negative values:

* the trinomial simplex has `K = 1/4 > 0` everywhere;
* the 2×2 independence model has `K = 0` everywhere;
* the tied two-group model has `K = -239/3844 < 0` at `(1/10, 1/2)`.

So no sign, and a fortiori no constant, can be attached to "the curvature of a
finite-support model"; curvature claims must be proved per model. -/
theorem curvature_trichotomy :
    (∀ x y : ℝ, x ≠ 0 → y ≠ 0 → 1 - x - y ≠ 0 → 0 < gaussianCurvature x y) ∧
    (∀ u v : ℝ, indepCurvature u v = 0) ∧
    (∃ s t : ℝ, TiedTwoGroup.Dom s t ∧ TiedTwoGroup.tiedCurvature s t < 0) := by
  refine ⟨fun x y hx hy hz => ?_, indepCurvature_eq_zero, ?_⟩
  · rw [gaussianCurvature_eq x y hx hy hz]; norm_num
  · exact ⟨1 / 10, 1 / 2, ⟨by norm_num, by norm_num, by norm_num, by norm_num⟩,
      TiedTwoGroup.tiedCurvature_at_half_neg⟩

/-- Sharper form: even the *sign pattern* is not determined by the number of
outcomes and parameters.  Three four-outcome, two-parameter models realise
`K > 0`, `K = 0` and `K < 0`, and one single model (the tied one) already realises
both signs. -/
theorem sign_not_determined_by_support_size :
    ∃ a b c d : ℝ, TiedTwoGroup.Dom a b ∧ TiedTwoGroup.Dom c d ∧
      TiedTwoGroup.tiedCurvature a b < 0 ∧ indepCurvature a b = 0 ∧
      0 < TiedTwoGroup.tiedCurvature c d := by
  refine ⟨1 / 10, 1 / 2, 1 / 10, 1 / 10,
    ⟨by norm_num, by norm_num, by norm_num, by norm_num⟩,
    ⟨by norm_num, by norm_num, by norm_num, by norm_num⟩,
    TiedTwoGroup.tiedCurvature_at_half_neg, indepCurvature_eq_zero _ _,
    TiedTwoGroup.tiedCurvature_at_tenth_pos⟩

end IndependenceModel