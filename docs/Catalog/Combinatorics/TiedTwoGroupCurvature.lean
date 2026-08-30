import Combinatorics.FisherSimplexCurvature

/-!
# A finite-support model whose Fisher–Rao curvature changes sign

`Combinatorics.FisherSimplexCurvature` shows that the *full* trinomial simplex has
constant curvature `+1/4`, and `Combinatorics.FisherSimplexIdentifiability` shows
that this coexists with exponential statistical sensitivity.  A natural follow-up
question is whether **every** finite-support model is positively curved.  It is not.

This file exhibits a completely concrete four-outcome, two-parameter model — the
*tied two-group Bernoulli model*

  group `A` occurs with probability `1 - s` and then succeeds with probability `t`;
  group `B` occurs with probability `s` and then succeeds with probability `t²`

so that

  `p = ((1-s)t, (1-s)(1-t), s t², s(1-t²))`,  `(s, t) ∈ (0,1)²`,

and computes its Levi-Civita connection and Gauss curvature exactly.  The result:

* `tiedCurvature_at_half_neg` : `K(1/10, 1/2) = -239/3844 < 0`;
* `tiedCurvature_at_tenth_pos` : `K(1/10, 1/10) = 6209/42436 > 0`;
* `tiedCurvature_changes_sign`, `tied_not_constant_curvature` : hence the Gauss
  curvature of a finite-support model need be neither constant nor of one sign.

Consequences for the guiding question:

* negative Fisher curvature **does** occur for finite-support models, so it is not
  excluded a priori — but
* it is a *pointwise, model-specific* property.  It is not implied by exponential
  sensitivity (which the full simplex has, with curvature `+1/4`), and it need not
  even be constant on a single model.  "Constant negative curvature" must therefore
  be tested as an independent claim.

Every geometric object below is *derived*: the scores are proved to be logarithmic
derivatives, the metric is proved to equal `E[s_i s_j]`, `dgT` is proved to be the
derivative of `gT`, `chrT` is proved to satisfy torsion-freeness and metric
compatibility (hence is *the* Levi-Civita connection, by
`TrinomialFisher.levi_civita_unique`), and `dchrT` is proved to be the derivative of
`chrT`.
-/

open Finset TrinomialFisher

noncomputable section

namespace TiedTwoGroup

/-! ## 0. A uniform tool for differentiating rational functions -/

/-- Derivative of a quartic polynomial. -/
theorem hasDerivAt_quartic (a b c d e x : ℝ) :
    HasDerivAt (fun r : ℝ => a * r ^ 4 + b * r ^ 3 + c * r ^ 2 + d * r + e)
      (4 * a * x ^ 3 + 3 * b * x ^ 2 + 2 * c * x + d) x := by
  have h4 := (hasDerivAt_pow 4 x).const_mul a
  have h3 := (hasDerivAt_pow 3 x).const_mul b
  have h2 := (hasDerivAt_pow 2 x).const_mul c
  have h1 := (hasDerivAt_id' x).const_mul d
  refine ((((h4.add h3).add h2).add h1).add_const e).congr_deriv ?_
  norm_num
  ring

/-- Any function that is *pointwise equal* to a quartic polynomial has the
corresponding derivative.  This lets every rational expression below be
differentiated by exhibiting its numerator and denominator coefficients. -/
theorem hasDerivAt_of_quartic {f : ℝ → ℝ} (a b c d e x v : ℝ)
    (hf : ∀ r : ℝ, f r = a * r ^ 4 + b * r ^ 3 + c * r ^ 2 + d * r + e)
    (hv : v = 4 * a * x ^ 3 + 3 * b * x ^ 2 + 2 * c * x + d) :
    HasDerivAt f v x := by
  have hfe : f = fun r : ℝ => a * r ^ 4 + b * r ^ 3 + c * r ^ 2 + d * r + e := funext hf
  rw [hfe, hv]
  exact hasDerivAt_quartic a b c d e x

/-! ## 1. The model and its scores -/

/-- The four outcome probabilities of the tied two-group Bernoulli model. -/
def probT : Fin 4 → ℝ → ℝ → ℝ
  | 0, s, t => (1 - s) * t
  | 1, s, t => (1 - s) * (1 - t)
  | 2, s, t => s * t ^ 2
  | 3, s, t => s * (1 - t ^ 2)

/-- The scores `∂_i log p_a` of the tied two-group model. -/
def scoreT : Fin 2 → Fin 4 → ℝ → ℝ → ℝ
  | 0, 0, s, _ => -1 / (1 - s)
  | 0, 1, s, _ => -1 / (1 - s)
  | 0, 2, s, _ => 1 / s
  | 0, 3, s, _ => 1 / s
  | 1, 0, _, t => 1 / t
  | 1, 1, _, t => -1 / (1 - t)
  | 1, 2, _, t => 2 / t
  | 1, 3, _, t => -2 * t / (1 - t ^ 2)

/-- The parameter domain: the open unit square. -/
structure Dom (s t : ℝ) : Prop where
  s_pos : 0 < s
  s_lt : s < 1
  t_pos : 0 < t
  t_lt : t < 1

namespace Dom
variable {s t : ℝ}

theorem s1_pos (h : Dom s t) : 0 < 1 - s := by have := h.s_lt; linarith
theorem t1_pos (h : Dom s t) : 0 < 1 - t := by have := h.t_lt; linarith
theorem t2_pos (h : Dom s t) : 0 < 1 - t ^ 2 := by
  have h1 := h.t_pos; have h2 := h.t_lt; nlinarith
theorem sq_pos (h : Dom s t) : 0 < s - s ^ 2 := by
  have h1 := h.s_pos; have h2 := h.s1_pos; nlinarith
theorem cubic_pos (h : Dom s t) : 0 < t - t ^ 3 := by
  have h1 := h.t_pos; have h2 := h.t2_pos; nlinarith
theorem N_pos (h : Dom s t) : 0 < (1 - s) + (1 + 3 * s) * t := by
  have h1 := h.s1_pos; have h2 := h.s_pos; have h3 := h.t_pos; nlinarith

theorem s_ne (h : Dom s t) : s ≠ 0 := ne_of_gt h.s_pos
theorem s1_ne (h : Dom s t) : 1 - s ≠ 0 := ne_of_gt h.s1_pos
theorem t_ne (h : Dom s t) : t ≠ 0 := ne_of_gt h.t_pos
theorem t1_ne (h : Dom s t) : 1 - t ≠ 0 := ne_of_gt h.t1_pos
theorem t2_ne (h : Dom s t) : 1 - t ^ 2 ≠ 0 := ne_of_gt h.t2_pos
theorem sq_ne (h : Dom s t) : s - s ^ 2 ≠ 0 := ne_of_gt h.sq_pos
theorem cubic_ne (h : Dom s t) : t - t ^ 3 ≠ 0 := ne_of_gt h.cubic_pos
theorem N_ne (h : Dom s t) : (1 - s) + (1 + 3 * s) * t ≠ 0 := ne_of_gt h.N_pos

end Dom

theorem probT_pos {s t : ℝ} (h : Dom s t) (a : Fin 4) : 0 < probT a s t := by
  have h1 := h.s_pos
  have h2 := h.s1_pos
  have h3 := h.t_pos
  have h4 := h.t1_pos
  have h5 := h.t2_pos
  fin_cases a <;> simp only [probT]
  · exact mul_pos h2 h3
  · exact mul_pos h2 h4
  · exact mul_pos h1 (pow_pos h3 2)
  · exact mul_pos h1 h5

theorem probT_ne {s t : ℝ} (h : Dom s t) (a : Fin 4) : probT a s t ≠ 0 :=
  ne_of_gt (probT_pos h a)

/-- The probabilities sum to one. -/
theorem sum_probT (s t : ℝ) : ∑ a : Fin 4, probT a s t = 1 := by
  simp only [Fin.sum_univ_four, probT]; ring

theorem hasDerivAt_log_probT_fst (s t : ℝ) (h : Dom s t) (a : Fin 4) :
    HasDerivAt (fun r => Real.log (probT a r t)) (scoreT 0 a s t) s := by
  have hA : HasDerivAt (fun r : ℝ => (1 - r) * t) (-t) s :=
    hasDerivAt_of_quartic 0 0 0 (-t) t s _ (fun r => by ring) (by ring)
  have hB : HasDerivAt (fun r : ℝ => (1 - r) * (1 - t)) (-(1 - t)) s :=
    hasDerivAt_of_quartic 0 0 0 (-(1 - t)) (1 - t) s _ (fun r => by ring) (by ring)
  have hC : HasDerivAt (fun r : ℝ => r * t ^ 2) (t ^ 2) s :=
    hasDerivAt_of_quartic 0 0 0 (t ^ 2) 0 s _ (fun r => by ring) (by ring)
  have hD : HasDerivAt (fun r : ℝ => r * (1 - t ^ 2)) (1 - t ^ 2) s :=
    hasDerivAt_of_quartic 0 0 0 (1 - t ^ 2) 0 s _ (fun r => by ring) (by ring)
  have e0 := probT_ne h 0
  have e1 := probT_ne h 1
  have e2 := probT_ne h 2
  have e3 := probT_ne h 3
  simp only [probT] at e0 e1 e2 e3
  have hs := h.s_ne
  have hs1 := h.s1_ne
  have ht := h.t_ne
  have ht1 := h.t1_ne
  have ht2 := h.t2_ne
  fin_cases a <;> simp only [probT, scoreT]
  · refine ((Real.hasDerivAt_log e0).comp s hA).congr_deriv ?_
    field_simp
  · refine ((Real.hasDerivAt_log e1).comp s hB).congr_deriv ?_
    field_simp
  · refine ((Real.hasDerivAt_log e2).comp s hC).congr_deriv ?_
    field_simp
  · refine ((Real.hasDerivAt_log e3).comp s hD).congr_deriv ?_
    field_simp

theorem hasDerivAt_log_probT_snd (s t : ℝ) (h : Dom s t) (a : Fin 4) :
    HasDerivAt (fun r => Real.log (probT a s r)) (scoreT 1 a s t) t := by
  have hA : HasDerivAt (fun r : ℝ => (1 - s) * r) (1 - s) t :=
    hasDerivAt_of_quartic 0 0 0 (1 - s) 0 t _ (fun r => by ring) (by ring)
  have hB : HasDerivAt (fun r : ℝ => (1 - s) * (1 - r)) (-(1 - s)) t :=
    hasDerivAt_of_quartic 0 0 0 (-(1 - s)) (1 - s) t _ (fun r => by ring) (by ring)
  have hC : HasDerivAt (fun r : ℝ => s * r ^ 2) (2 * s * t) t :=
    hasDerivAt_of_quartic 0 0 s 0 0 t _ (fun r => by ring) (by ring)
  have hD : HasDerivAt (fun r : ℝ => s * (1 - r ^ 2)) (-(2 * s * t)) t :=
    hasDerivAt_of_quartic 0 0 (-s) 0 s t _ (fun r => by ring) (by ring)
  have e0 := probT_ne h 0
  have e1 := probT_ne h 1
  have e2 := probT_ne h 2
  have e3 := probT_ne h 3
  simp only [probT] at e0 e1 e2 e3
  have hs := h.s_ne
  have hs1 := h.s1_ne
  have ht := h.t_ne
  have ht1 := h.t1_ne
  have ht2 := h.t2_ne
  fin_cases a <;> simp only [probT, scoreT]
  · refine ((Real.hasDerivAt_log e0).comp t hA).congr_deriv ?_
    field_simp
  · refine ((Real.hasDerivAt_log e1).comp t hB).congr_deriv ?_
    field_simp
  · refine ((Real.hasDerivAt_log e2).comp t hC).congr_deriv ?_
    field_simp
  · refine ((Real.hasDerivAt_log e3).comp t hD).congr_deriv ?_
    field_simp

/-! ## 2. The Fisher metric -/

/-- The Fisher information metric of the tied two-group model. -/
def fisherT (i j : Fin 2) (s t : ℝ) : ℝ :=
  ∑ a : Fin 4, probT a s t * (scoreT i a s t * scoreT j a s t)

/-- Closed form of the metric.  The `(1,1)` entry collapses to `N / (t - t³)` with
`N = (1-s) + (1+3s)t`. -/
def gT : Fin 2 → Fin 2 → ℝ → ℝ → ℝ
  | 0, 0, s, _ => 1 / (s - s ^ 2)
  | 0, 1, _, _ => 0
  | 1, 0, _, _ => 0
  | 1, 1, s, t => ((1 - s) + (1 + 3 * s) * t) / (t - t ^ 3)

/-- **The Fisher metric of the tied model equals its closed form.**  In particular it
is diagonal: the group-share parameter and the success parameter are orthogonal. -/
theorem fisherT_eq_gT (i j : Fin 2) (s t : ℝ) (h : Dom s t) :
    fisherT i j s t = gT i j s t := by
  have hs := h.s_ne
  have hs1 := h.s1_ne
  have ht := h.t_ne
  have ht1 := h.t1_ne
  have ht2 := h.t2_ne
  have hsq := h.sq_ne
  have hc := h.cubic_ne
  fin_cases i <;> fin_cases j <;>
    simp only [fisherT, Fin.sum_univ_four, probT, scoreT, gT] <;> field_simp <;> ring

theorem gT_symm (i j : Fin 2) (s t : ℝ) : gT i j s t = gT j i s t := by
  fin_cases i <;> fin_cases j <;> rfl

/-! ## 3. Derivatives of the metric -/

/-- Closed form for `∂_k g_ij`. -/
def dgT : Fin 2 → Fin 2 → Fin 2 → ℝ → ℝ → ℝ
  | 0, 0, 0, s, _ => (2 * s - 1) / (s - s ^ 2) ^ 2
  | 0, 1, 1, _, t => (3 * t - 1) / (t - t ^ 3)
  | 1, 1, 1, s, t =>
      (2 * (1 + 3 * s) * t ^ 3 + 3 * (1 - s) * t ^ 2 - (1 - s)) / (t - t ^ 3) ^ 2
  | _, _, _, _, _ => 0

theorem dgT_symm (k i j : Fin 2) (s t : ℝ) : dgT k i j s t = dgT k j i s t := by
  fin_cases k <;> fin_cases i <;> fin_cases j <;> rfl

theorem hasDerivAt_gT_fst (i j : Fin 2) (s t : ℝ) (h : Dom s t) :
    HasDerivAt (fun r => gT i j r t) (dgT 0 i j s t) s := by
  have hsq := h.sq_ne
  have hc := h.cubic_ne
  have hden : HasDerivAt (fun r : ℝ => r - r ^ 2) (1 - 2 * s) s :=
    hasDerivAt_of_quartic 0 0 (-1) 1 0 s _ (fun r => by ring) (by ring)
  have hnum : HasDerivAt (fun r : ℝ => (1 - r) + (1 + 3 * r) * t) (3 * t - 1) s :=
    hasDerivAt_of_quartic 0 0 0 (3 * t - 1) (1 + t) s _ (fun r => by ring) (by ring)
  fin_cases i <;> fin_cases j <;> simp only [gT, dgT]
  · refine ((hasDerivAt_const s (1 : ℝ)).div hden hsq).congr_deriv ?_
    field_simp
    ring
  · exact hasDerivAt_const s _
  · exact hasDerivAt_const s _
  · exact hnum.div_const (t - t ^ 3)

theorem hasDerivAt_gT_snd (i j : Fin 2) (s t : ℝ) (h : Dom s t) :
    HasDerivAt (fun r => gT i j s r) (dgT 1 i j s t) t := by
  have hc := h.cubic_ne
  have hnum : HasDerivAt (fun r : ℝ => (1 - s) + (1 + 3 * s) * r) (1 + 3 * s) t :=
    hasDerivAt_of_quartic 0 0 0 (1 + 3 * s) (1 - s) t _ (fun r => by ring) (by ring)
  have hden : HasDerivAt (fun r : ℝ => r - r ^ 3) (1 - 3 * t ^ 2) t :=
    hasDerivAt_of_quartic 0 (-1) 0 1 0 t _ (fun r => by ring) (by ring)
  fin_cases i <;> fin_cases j <;> simp only [gT, dgT]
  · exact hasDerivAt_const t _
  · exact hasDerivAt_const t _
  · exact hasDerivAt_const t _
  · refine (hnum.div hden hc).congr_deriv ?_
    field_simp
    ring

/-! ## 4. The Levi-Civita connection -/

/-- Christoffel symbols of the second kind of the tied model, in closed form. -/
def chrT : Fin 2 → Fin 2 → Fin 2 → ℝ → ℝ → ℝ
  | 0, 0, 0, s, _ => (2 * s - 1) / (2 * (s - s ^ 2))
  | 0, 1, 1, s, t => ((s ^ 2 - s) * (3 * t - 1)) / (2 * (t - t ^ 3))
  | 1, 0, 1, s, t => (3 * t - 1) / (2 * ((1 - s) + (1 + 3 * s) * t))
  | 1, 1, 0, s, t => (3 * t - 1) / (2 * ((1 - s) + (1 + 3 * s) * t))
  | 1, 1, 1, s, t =>
      (2 * (1 + 3 * s) * t ^ 3 + 3 * (1 - s) * t ^ 2 - (1 - s)) /
        (2 * ((1 - s) + (1 + 3 * s) * t) * (t - t ^ 3))
  | _, _, _, _, _ => 0

/-- Torsion-freeness. -/
theorem chrT_symm (k i j : Fin 2) (s t : ℝ) : chrT k i j s t = chrT k j i s t := by
  fin_cases k <;> fin_cases i <;> fin_cases j <;> rfl

/-- **Metric compatibility** `∂_k g_ij = Σ_m (g_jm Γ^m_{ki} + g_im Γ^m_{kj})`. -/
theorem metric_compat (k i j : Fin 2) (s t : ℝ) (h : Dom s t) :
    dgT k i j s t = ∑ m : Fin 2, (gT j m s t * chrT m k i s t + gT i m s t * chrT m k j s t) := by
  have hsq := h.sq_ne
  have hc := h.cubic_ne
  have hN := h.N_ne
  fin_cases k <;> fin_cases i <;> fin_cases j <;>
    simp only [dgT, gT, chrT, Fin.sum_univ_two,
      show (s ^ 2 - s : ℝ) = -(s - s ^ 2) from by ring] <;>
    revert hsq hN <;>
    generalize (s - s ^ 2 : ℝ) = S <;>
    generalize (1 : ℝ) - s + (1 + 3 * s) * t = N <;>
    intro hsq hN <;> field_simp <;> try ring

/-- **`chrT` is the Levi-Civita connection.**  Lowering an index gives exactly the
Koszul half-sum, which by `TrinomialFisher.levi_civita_unique` is the unique
torsion-free metric-compatible choice. -/
theorem chrT_is_levi_civita (i j l : Fin 2) (s t : ℝ) (h : Dom s t) :
    ∑ m : Fin 2, gT l m s t * chrT m i j s t
      = (dgT i j l s t + dgT j i l s t - dgT l i j s t) / 2 := by
  refine levi_civita_unique (fun k i j => dgT k i j s t)
    (fun i j l => ∑ m : Fin 2, gT l m s t * chrT m i j s t) ?_ ?_ i j l
  · intro i j l
    simp only [chrT_symm _ i j]
  · intro k i j
    simp only [metric_compat k i j s t h, Fin.sum_univ_two]
    ring

/-! ## 5. Derivatives of the connection -/

/-- Closed form for `∂_d Γ^k_{ij}`. -/
def dchrT : Fin 2 → Fin 2 → Fin 2 → Fin 2 → ℝ → ℝ → ℝ
  | 0, 0, 0, 0, s, _ => (2 * s ^ 2 - 2 * s + 1) / (2 * (s - s ^ 2) ^ 2)
  | 0, 0, 1, 1, s, t => ((2 * s - 1) * (3 * t - 1)) / (2 * (t - t ^ 3))
  | 0, 1, 0, 1, s, t => -(3 * t - 1) ^ 2 / (2 * ((1 - s) + (1 + 3 * s) * t) ^ 2)
  | 0, 1, 1, 0, s, t => -(3 * t - 1) ^ 2 / (2 * ((1 - s) + (1 + 3 * s) * t) ^ 2)
  | 0, 1, 1, 1, s, t => 2 / ((1 - s) + (1 + 3 * s) * t) ^ 2
  | 1, 0, 1, 1, s, t => ((s ^ 2 - s) * (6 * t ^ 3 - 3 * t ^ 2 + 1)) / (2 * (t - t ^ 3) ^ 2)
  | 1, 1, 0, 1, s, t => 2 / ((1 - s) + (1 + 3 * s) * t) ^ 2
  | 1, 1, 1, 0, s, t => 2 / ((1 - s) + (1 + 3 * s) * t) ^ 2
  | 1, 1, 1, 1, s, t =>
      (6 * t * ((1 - s) + (1 + 3 * s) * t) ^ 2 * (t - t ^ 3)
        - (2 * (1 + 3 * s) * t ^ 3 + 3 * (1 - s) * t ^ 2 - (1 - s)) * (1 + 3 * s) * (t - t ^ 3)
        - (2 * (1 + 3 * s) * t ^ 3 + 3 * (1 - s) * t ^ 2 - (1 - s))
            * ((1 - s) + (1 + 3 * s) * t) * (1 - 3 * t ^ 2)) /
      (2 * ((1 - s) + (1 + 3 * s) * t) ^ 2 * (t - t ^ 3) ^ 2)
  | _, _, _, _, _, _ => 0

theorem hasDerivAt_chrT_fst (k i j : Fin 2) (s t : ℝ) (h : Dom s t) :
    HasDerivAt (fun r => chrT k i j r t) (dchrT 0 k i j s t) s := by
  have hsq := h.sq_ne
  have hc := h.cubic_ne
  have hN := h.N_ne
  have hd1 : 2 * (s - s ^ 2) ≠ 0 := by
    simp only [ne_eq, mul_eq_zero]; push_neg; exact ⟨two_ne_zero, hsq⟩
  have hd2 : 2 * ((1 - s) + (1 + 3 * s) * t) ≠ 0 := by
    simp only [ne_eq, mul_eq_zero]; push_neg; exact ⟨two_ne_zero, hN⟩
  have hd3 : 2 * ((1 - s) + (1 + 3 * s) * t) * (t - t ^ 3) ≠ 0 := mul_ne_zero hd2 hc
  have hn1 : HasDerivAt (fun r : ℝ => 2 * r - 1) 2 s :=
    hasDerivAt_of_quartic 0 0 0 2 (-1) s _ (fun r => by ring) (by ring)
  have hb1 : HasDerivAt (fun r : ℝ => 2 * (r - r ^ 2)) (2 - 4 * s) s :=
    hasDerivAt_of_quartic 0 0 (-2) 2 0 s _ (fun r => by ring) (by ring)
  have hn2 : HasDerivAt (fun r : ℝ => (r ^ 2 - r) * (3 * t - 1))
      ((2 * s - 1) * (3 * t - 1)) s :=
    hasDerivAt_of_quartic 0 0 (3 * t - 1) (-(3 * t - 1)) 0 s _ (fun r => by ring) (by ring)
  have hb2 : HasDerivAt (fun r : ℝ => 2 * ((1 - r) + (1 + 3 * r) * t)) (2 * (3 * t - 1)) s :=
    hasDerivAt_of_quartic 0 0 0 (2 * (3 * t - 1)) (2 * (1 + t)) s _ (fun r => by ring) (by ring)
  have hn3 : HasDerivAt
      (fun r : ℝ => 2 * (1 + 3 * r) * t ^ 3 + 3 * (1 - r) * t ^ 2 - (1 - r))
      (6 * t ^ 3 - 3 * t ^ 2 + 1) s :=
    hasDerivAt_of_quartic 0 0 0 (6 * t ^ 3 - 3 * t ^ 2 + 1) (2 * t ^ 3 + 3 * t ^ 2 - 1) s _
      (fun r => by ring) (by ring)
  have hb3 : HasDerivAt (fun r : ℝ => 2 * ((1 - r) + (1 + 3 * r) * t) * (t - t ^ 3))
      (2 * (3 * t - 1) * (t - t ^ 3)) s :=
    hasDerivAt_of_quartic 0 0 0 (2 * (3 * t - 1) * (t - t ^ 3)) (2 * (1 + t) * (t - t ^ 3)) s _
      (fun r => by ring) (by ring)
  fin_cases k <;> fin_cases i <;> fin_cases j <;> simp only [chrT, dchrT]
  · refine (hn1.div hb1 hd1).congr_deriv ?_
    field_simp
    ring
  · exact hasDerivAt_const s _
  · exact hasDerivAt_const s _
  · exact hn2.div_const (2 * (t - t ^ 3))
  · exact hasDerivAt_const s _
  · refine ((hasDerivAt_const s (3 * t - 1)).div hb2 hd2).congr_deriv ?_
    field_simp
    ring
  · refine ((hasDerivAt_const s (3 * t - 1)).div hb2 hd2).congr_deriv ?_
    field_simp
    ring
  · refine (hn3.div hb3 hd3).congr_deriv ?_
    rw [div_eq_div_iff (pow_ne_zero 2 hd3) (pow_ne_zero 2 hN)]
    ring

theorem hasDerivAt_chrT_snd (k i j : Fin 2) (s t : ℝ) (h : Dom s t) :
    HasDerivAt (fun r => chrT k i j s r) (dchrT 1 k i j s t) t := by
  have hsq := h.sq_ne
  have hc := h.cubic_ne
  have hN := h.N_ne
  have hd1 : 2 * (t - t ^ 3) ≠ 0 := by
    simp only [ne_eq, mul_eq_zero]; push_neg; exact ⟨two_ne_zero, hc⟩
  have hd2 : 2 * ((1 - s) + (1 + 3 * s) * t) ≠ 0 := by
    simp only [ne_eq, mul_eq_zero]; push_neg; exact ⟨two_ne_zero, hN⟩
  have hd3 : 2 * ((1 - s) + (1 + 3 * s) * t) * (t - t ^ 3) ≠ 0 := mul_ne_zero hd2 hc
  have hn1 : HasDerivAt (fun r : ℝ => (s ^ 2 - s) * (3 * r - 1)) (3 * (s ^ 2 - s)) t :=
    hasDerivAt_of_quartic 0 0 0 (3 * (s ^ 2 - s)) (-(s ^ 2 - s)) t _ (fun r => by ring) (by ring)
  have hb1 : HasDerivAt (fun r : ℝ => 2 * (r - r ^ 3)) (2 - 6 * t ^ 2) t :=
    hasDerivAt_of_quartic 0 (-2) 0 2 0 t _ (fun r => by ring) (by ring)
  have hn2 : HasDerivAt (fun r : ℝ => 3 * r - 1) 3 t :=
    hasDerivAt_of_quartic 0 0 0 3 (-1) t _ (fun r => by ring) (by ring)
  have hb2 : HasDerivAt (fun r : ℝ => 2 * ((1 - s) + (1 + 3 * s) * r)) (2 * (1 + 3 * s)) t :=
    hasDerivAt_of_quartic 0 0 0 (2 * (1 + 3 * s)) (2 * (1 - s)) t _ (fun r => by ring) (by ring)
  have hn3 : HasDerivAt
      (fun r : ℝ => 2 * (1 + 3 * s) * r ^ 3 + 3 * (1 - s) * r ^ 2 - (1 - s))
      (6 * (1 + 3 * s) * t ^ 2 + 6 * (1 - s) * t) t :=
    hasDerivAt_of_quartic 0 (2 * (1 + 3 * s)) (3 * (1 - s)) 0 (-(1 - s)) t _
      (fun r => by ring) (by ring)
  have hb3 : HasDerivAt (fun r : ℝ => 2 * ((1 - s) + (1 + 3 * s) * r) * (r - r ^ 3))
      (2 * (1 + 3 * s) * (t - t ^ 3) + 2 * ((1 - s) + (1 + 3 * s) * t) * (1 - 3 * t ^ 2)) t :=
    hasDerivAt_of_quartic (-(2 * (1 + 3 * s))) (-(2 * (1 - s))) (2 * (1 + 3 * s)) (2 * (1 - s)) 0
      t _ (fun r => by ring) (by ring)
  fin_cases k <;> fin_cases i <;> fin_cases j <;> simp only [chrT, dchrT]
  · exact hasDerivAt_const t _
  · exact hasDerivAt_const t _
  · exact hasDerivAt_const t _
  · refine (hn1.div hb1 hd1).congr_deriv ?_
    field_simp
    ring
  · exact hasDerivAt_const t _
  · refine (hn2.div hb2 hd2).congr_deriv ?_
    field_simp
    ring
  · refine (hn2.div hb2 hd2).congr_deriv ?_
    field_simp
    ring
  · refine (hn3.div hb3 hd3).congr_deriv ?_
    field_simp
    ring

/-! ## 6. Curvature: it changes sign -/

/-- The Gauss curvature of the tied two-group model, computed with the same
`riemann`/`sectional` machinery as the simplex and the hyperbolic plane. -/
def tiedCurvature (s t : ℝ) : ℝ :=
  sectional (fun i j => gT i j s t) (fun k i j => chrT k i j s t)
    (fun d k i j => dchrT d k i j s t)

/-- At `(s, t) = (1/10, 1/2)` the curvature is the negative rational `-239/3844`. -/
theorem tiedCurvature_at_half : tiedCurvature (1 / 10) (1 / 2) = -239 / 3844 := by
  simp only [tiedCurvature, sectional, riemann, Fin.sum_univ_two, gT, chrT, dchrT]
  norm_num

/-- At `(s, t) = (1/10, 1/10)` the curvature is the positive rational `6209/42436`. -/
theorem tiedCurvature_at_tenth : tiedCurvature (1 / 10) (1 / 10) = 6209 / 42436 := by
  simp only [tiedCurvature, sectional, riemann, Fin.sum_univ_two, gT, chrT, dchrT]
  norm_num

theorem tiedCurvature_at_half_neg : tiedCurvature (1 / 10) (1 / 2) < 0 := by
  rw [tiedCurvature_at_half]; norm_num

theorem tiedCurvature_at_tenth_pos : 0 < tiedCurvature (1 / 10) (1 / 10) := by
  rw [tiedCurvature_at_tenth]; norm_num

/-- **The Gauss curvature of a finite-support model can change sign.**  Hence
"constant negative curvature" is not merely unproved for finite-support models; for
this one it fails in a strong way, the curvature being negative at one parameter
value and positive at another.  Curvature must be tested pointwise, per model. -/
theorem tiedCurvature_changes_sign :
    ∃ s₁ t₁ s₂ t₂ : ℝ, Dom s₁ t₁ ∧ Dom s₂ t₂ ∧
      tiedCurvature s₁ t₁ < 0 ∧ 0 < tiedCurvature s₂ t₂ :=
  ⟨1 / 10, 1 / 2, 1 / 10, 1 / 10, ⟨by norm_num, by norm_num, by norm_num, by norm_num⟩,
    ⟨by norm_num, by norm_num, by norm_num, by norm_num⟩,
    tiedCurvature_at_half_neg, tiedCurvature_at_tenth_pos⟩

/-- Consequently the tied two-group model is **not** a space of constant curvature. -/
theorem tied_not_constant_curvature :
    ¬ ∃ c : ℝ, ∀ s t : ℝ, Dom s t → tiedCurvature s t = c := by
  rintro ⟨c, hc⟩
  have h1 := hc (1 / 10) (1 / 2) ⟨by norm_num, by norm_num, by norm_num, by norm_num⟩
  have h2 := hc (1 / 10) (1 / 10) ⟨by norm_num, by norm_num, by norm_num, by norm_num⟩
  rw [tiedCurvature_at_half] at h1
  rw [tiedCurvature_at_tenth] at h2
  rw [← h1] at h2
  norm_num at h2

end TiedTwoGroup