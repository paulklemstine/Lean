import Tropical.WeightExponentFit

/-!
# Dequantization of the fit: the `α → ∞` limit of the dial regression

Files `Tropical.WeightExponentDial` and `Tropical.WeightExponentFit` set up the weight
family `ℓ ↦ ℓ^(-α)` and the selection rule `α ↦ R²(α)`.  Here the two layers are joined:
we compute the limit of the *whole regression* as the weight exponent grows, and show that
it is the min-plus (tropical) regression.

Fix data indices `ι`, a support `supp i ⊆ {ℓ : c_ℓ(N_i) = 1}` for each datum, and let `M`
be a prime that is `≤` every active prime (the left edge of the window).  Then:

* `TropicalLimit.dialSum_eq_smul_normDial` : the covariate factors as
  `S_α(i) = M^(-α) · Σ_{ℓ ∈ supp i} (M/ℓ)^α`, i.e. a *global* scalar times a normalized
  covariate;
* `TropicalLimit.tendsto_normDial` : the normalized covariate converges pointwise to the
  **tropical covariate** `1_{M ∈ supp i}` — all information except membership of the
  smallest prime is annihilated;
* `TropicalLimit.tendsto_R2_atTop` : consequently `R²(α)` converges to the `R²` of that
  single-bit tropical covariate.  Large exponents therefore throw away the whole window
  and regress on one prime; combined with `FitLayer.r2Curve_argmax_eq_half` this explains
  *why* the measured curve must fall off past its interior optimum, and why the pre-`α`-fit
  choice `α = 1` was already on the wrong side of the peak.

The proof of `tendsto_R2_atTop` uses the scale invariance `FitLayer.R2_affine_left`: the
global factor `M^(-α)`, which by itself sends every covariate entry to `0`, is invisible to
`R²`.
-/

open Filter Finset

namespace TropicalLimit

open FitLayer WeightDial

variable {ι : Type*} [Fintype ι]

/-- The normalized (scale-free) dial covariate `Σ_{ℓ ∈ supp i} (M/ℓ)^α`. -/
noncomputable def normDial (supp : ι → Finset ℕ) (M : ℕ) (α : ℝ) (i : ι) : ℝ :=
  ∑ l ∈ supp i, ((M : ℝ) / (l : ℝ)) ^ α

/-- The tropical covariate: the indicator that the smallest window prime is active. -/
noncomputable def tropDial (supp : ι → Finset ℕ) (M : ℕ) (i : ι) : ℝ :=
  if M ∈ supp i then 1 else 0

omit [Fintype ι] in
/-- The raw dial covariate is a *global* multiple of the normalized one. -/
theorem dialSum_eq_smul_normDial (supp : ι → Finset ℕ) {M : ℕ} (hM : 2 ≤ M)
    (h2 : ∀ i, ∀ l ∈ supp i, 2 ≤ l) (α : ℝ) (i : ι) :
    dialSum (supp i) α = (M : ℝ) ^ (-α) * normDial supp M α i := by
  have hM0 : (0 : ℝ) < (M : ℝ) := by exact_mod_cast (by omega : 0 < M)
  unfold dialSum normDial
  rw [Finset.mul_sum]
  refine Finset.sum_congr rfl fun l hl => ?_
  have hl0 : (0 : ℝ) < (l : ℝ) := by
    have := h2 i l hl; exact_mod_cast (by omega : 0 < l)
  have hMa : ((M : ℝ) ^ α) ≠ 0 := ne_of_gt (Real.rpow_pos_of_pos hM0 α)
  have hla : ((l : ℝ) ^ α) ≠ 0 := ne_of_gt (Real.rpow_pos_of_pos hl0 α)
  rw [dialWeight, Real.div_rpow (le_of_lt hM0) (le_of_lt hl0), Real.rpow_neg (le_of_lt hM0),
    Real.rpow_neg (le_of_lt hl0)]
  field_simp

omit [Fintype ι] in
/-- **Dequantization of the covariate.**  As the exponent grows, the normalized dial
converges to the tropical (min-plus) covariate: everything except the smallest active
prime is exponentially suppressed. -/
theorem tendsto_normDial (supp : ι → Finset ℕ) {M : ℕ} (hM : 2 ≤ M)
    (hmin : ∀ i, ∀ l ∈ supp i, M ≤ l) (i : ι) :
    Tendsto (fun α : ℝ => normDial supp M α i) atTop (nhds (tropDial supp M i)) := by
  have hM0 : (0 : ℝ) < (M : ℝ) := by exact_mod_cast (by omega : 0 < M)
  have hterm : ∀ l ∈ supp i,
      Tendsto (fun α : ℝ => ((M : ℝ) / (l : ℝ)) ^ α) atTop
        (nhds (if l = M then (1 : ℝ) else 0)) := by
    intro l hl
    rcases eq_or_ne l M with rfl | hne
    · simp only [div_self (ne_of_gt hM0), Real.one_rpow]
      exact tendsto_const_nhds
    · have hlM : M < l := lt_of_le_of_ne (hmin i l hl) (Ne.symm hne)
      have hl0 : (0 : ℝ) < (l : ℝ) := lt_trans hM0 (by exact_mod_cast hlM)
      have hlt : (M : ℝ) / (l : ℝ) < 1 := by
        rw [div_lt_one hl0]; exact_mod_cast hlM
      have hgt : (-1 : ℝ) < (M : ℝ) / (l : ℝ) := by
        have hpos : (0 : ℝ) < (M : ℝ) / (l : ℝ) := by positivity
        linarith
      rw [if_neg hne]
      exact tendsto_rpow_atTop_of_base_lt_one _ hgt hlt
  have hsum := tendsto_finset_sum (supp i) hterm
  have hval : (∑ l ∈ supp i, if l = M then (1 : ℝ) else 0) = tropDial supp M i := by
    unfold tropDial
    rw [Finset.sum_ite_eq' (supp i) M (fun _ => (1 : ℝ))]
  rwa [hval] at hsum

omit [Fintype ι] in
/-- **Geometric rate of the tropical collapse.**  If every active prime other than the
smallest one `M` is at least `M'`, the normalized dial is within
`|supp i| · (M/M')^α` of its tropical value.  The collapse is therefore exponentially fast
in the weight exponent, with rate governed by the *spectral gap* `M'/M` of the window. -/
theorem abs_normDial_sub_tropDial_le (supp : ι → Finset ℕ) {M M' : ℕ} (hM : 2 ≤ M)
    (hMM' : M ≤ M') (i : ι) (hsep : ∀ l ∈ supp i, l ≠ M → M' ≤ l) {α : ℝ} (hα : 0 ≤ α) :
    |normDial supp M α i - tropDial supp M i| ≤ (supp i).card * ((M : ℝ) / (M' : ℝ)) ^ α := by
  have hM0 : (0 : ℝ) < (M : ℝ) := by exact_mod_cast (by omega : 0 < M)
  have hM'0 : (0 : ℝ) < (M' : ℝ) := by exact_mod_cast (by omega : 0 < M')
  have hc0 : 0 ≤ ((M : ℝ) / (M' : ℝ)) ^ α :=
    le_of_lt (Real.rpow_pos_of_pos (div_pos hM0 hM'0) α)
  have htrop : tropDial supp M i = ∑ l ∈ supp i, (if l = M then (1 : ℝ) else 0) := by
    unfold tropDial
    rw [Finset.sum_ite_eq' (supp i) M (fun _ => (1 : ℝ))]
  have hdiff : normDial supp M α i - tropDial supp M i
      = ∑ l ∈ supp i, (((M : ℝ) / (l : ℝ)) ^ α - (if l = M then (1 : ℝ) else 0)) := by
    rw [htrop, normDial, ← Finset.sum_sub_distrib]
  have hterm : ∀ l ∈ supp i,
      ((M : ℝ) / (l : ℝ)) ^ α - (if l = M then (1 : ℝ) else 0)
        ≤ ((M : ℝ) / (M' : ℝ)) ^ α := by
    intro l hl
    rcases eq_or_ne l M with rfl | hne
    · simp [div_self (ne_of_gt hM0), Real.one_rpow, hc0]
    · rw [if_neg hne, sub_zero]
      have hl' : (M' : ℝ) ≤ (l : ℝ) := by exact_mod_cast hsep l hl hne
      have hle : (M : ℝ) / (l : ℝ) ≤ (M : ℝ) / (M' : ℝ) :=
        div_le_div_of_nonneg_left (le_of_lt hM0) hM'0 hl'
      exact Real.rpow_le_rpow (by positivity) hle hα
  have hterm0 : ∀ l ∈ supp i,
      (0 : ℝ) ≤ ((M : ℝ) / (l : ℝ)) ^ α - (if l = M then (1 : ℝ) else 0) := by
    intro l hl
    rcases eq_or_ne l M with rfl | hne
    · simp [div_self (ne_of_gt hM0), Real.one_rpow]
    · rw [if_neg hne, sub_zero]
      positivity
  rw [abs_le]
  constructor
  · rw [hdiff]
    have := Finset.sum_nonneg hterm0
    have hcard : (0 : ℝ) ≤ (supp i).card * ((M : ℝ) / (M' : ℝ)) ^ α := by positivity
    linarith
  · rw [hdiff]
    calc ∑ l ∈ supp i, (((M : ℝ) / (l : ℝ)) ^ α - (if l = M then (1 : ℝ) else 0))
        ≤ ∑ _l ∈ supp i, ((M : ℝ) / (M' : ℝ)) ^ α := Finset.sum_le_sum hterm
      _ = (supp i).card * ((M : ℝ) / (M' : ℝ)) ^ α := by
          rw [Finset.sum_const, nsmul_eq_mul]

/-! ### Continuity of the fit functionals -/

variable {β : Type*} {F : Filter β}

lemma tendsto_mean {x : β → ι → ℝ} {xlim : ι → ℝ}
    (h : ∀ i, Tendsto (fun b => x b i) F (nhds (xlim i))) :
    Tendsto (fun b => mean (x b)) F (nhds (mean xlim)) := by
  unfold mean
  exact (tendsto_finset_sum Finset.univ fun i _ => h i).div_const _

lemma tendsto_cov {x y : β → ι → ℝ} {xlim ylim : ι → ℝ}
    (hx : ∀ i, Tendsto (fun b => x b i) F (nhds (xlim i)))
    (hy : ∀ i, Tendsto (fun b => y b i) F (nhds (ylim i))) :
    Tendsto (fun b => cov (x b) (y b)) F (nhds (cov xlim ylim)) := by
  unfold cov
  refine tendsto_finset_sum Finset.univ fun i _ => ?_
  exact ((hx i).sub (tendsto_mean hx)).mul ((hy i).sub (tendsto_mean hy))

lemma tendsto_varr {x : β → ι → ℝ} {xlim : ι → ℝ}
    (hx : ∀ i, Tendsto (fun b => x b i) F (nhds (xlim i))) :
    Tendsto (fun b => varr (x b)) F (nhds (varr xlim)) :=
  tendsto_cov hx hx

lemma tendsto_R2 {x : β → ι → ℝ} {xlim y : ι → ℝ}
    (hx : ∀ i, Tendsto (fun b => x b i) F (nhds (xlim i)))
    (hden : varr xlim * varr y ≠ 0) :
    Tendsto (fun b => R2 (x b) y) F (nhds (R2 xlim y)) := by
  have hc : Tendsto (fun b => cov (x b) y) F (nhds (cov xlim y)) :=
    tendsto_cov (ylim := y) hx (fun _ => tendsto_const_nhds)
  have hv : Tendsto (fun b => varr (x b) * varr y) F (nhds (varr xlim * varr y)) :=
    (tendsto_varr hx).mul tendsto_const_nhds
  unfold R2
  exact (hc.pow 2).div hv hden

/-! ### The limit of the regression -/

/-- **The dial regression dequantizes.**  As the weight exponent grows, the explanatory
power of the dial covariate converges to that of the single-bit tropical covariate
`1_{M ∈ supp i}` — provided the latter is non-degenerate.  Together with the measured
interior optimum at `α̂ = 1/2`, this pins the shape of the `α`-curve: it must eventually
decay to a fixed, information-poor value. -/
theorem tendsto_R2_atTop [Nonempty ι] (supp : ι → Finset ℕ) {M : ℕ} (hM : 2 ≤ M)
    (h2 : ∀ i, ∀ l ∈ supp i, 2 ≤ l) (hmin : ∀ i, ∀ l ∈ supp i, M ≤ l) (y : ι → ℝ)
    (hden : varr (tropDial supp M) * varr y ≠ 0) :
    Tendsto (fun α : ℝ => R2 (fun i => dialSum (supp i) α) y) atTop
      (nhds (R2 (tropDial supp M) y)) := by
  have hM0 : (0 : ℝ) < (M : ℝ) := by exact_mod_cast (by omega : 0 < M)
  have hraw : ∀ α : ℝ, R2 (fun i => dialSum (supp i) α) y = R2 (normDial supp M α) y := by
    intro α
    have hfun : (fun i => dialSum (supp i) α)
        = fun i => (M : ℝ) ^ (-α) * normDial supp M α i + 0 := by
      funext i
      rw [add_zero]
      exact dialSum_eq_smul_normDial supp hM h2 α i
    rw [hfun]
    exact R2_affine_left (ne_of_gt (Real.rpow_pos_of_pos hM0 (-α))) 0 _ y
  simp only [hraw]
  exact tendsto_R2 (fun i => tendsto_normDial supp hM hmin i) hden

/-! ### Non-degeneracy of the limiting regression

The hypothesis `varr (tropDial supp M) * varr y ≠ 0` of `tendsto_R2_atTop` is satisfiable:
two data points whose supports differ in the smallest prime already give a non-constant
tropical covariate. -/

/-- A concrete two-point configuration with a non-degenerate tropical covariate. -/
theorem tropDial_varr_ne_zero_example :
    varr (tropDial (ι := Fin 2) ![{3}, {5}] 3) = 1 / 2 := by
  have h : tropDial (ι := Fin 2) ![{3}, {5}] 3 = ![1, 0] := by
    funext i
    fin_cases i <;> simp [tropDial]
  rw [h]
  simp [varr, cov, mean, Fin.sum_univ_two]
  norm_num

end TropicalLimit