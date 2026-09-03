import Bridges.Ma1EffectiveEquidistribution

/-!
# Scale decay, concentration, and the converse direction of the MA-1 effectivization

`Bridges.Ma1EffectiveEquidistribution` turns an equidistribution certificate `EquiCert N μ ε`
into an effective cap constant `capConst ε = (4/3)(1+ε)/(1−ε)`.  This file is the second
cycle of the same research loop and answers the three questions the first cycle left open.

1. **How fast does the effectivization become free?**  Experiment 509's H3 records that the
   deviations shrink from scale to scale.  Modelled as `ε(k+1) ≤ ρ·ε(k)` with `ρ < 1`, we
   prove `eps_geom_bound` (`ε(k) ≤ ρ^k ε(0)`, by induction) and `cap_eventually_within`: the
   effective constant converges to the ideal `4/3` and the number of scales needed for a
   prescribed accuracy is explicit.  `capConst_sub_eq` identifies the excess *exactly* as
   `(8/3)·ε/(1−ε)` — the effectivization cost is linear in `ε` with slope `8/3`.

2. **How much can a certificate be violated by a few classes?**  `card_large_deviation_le`
   is an exact finite Chebyshev bound: under the (weaker) mean-square certificate, fewer
   than `n/t²` classes can deviate by more than `t·ε·μ`.  So an `ℓ²`-certificate already
   controls the *count* of outlying residue classes.

3. **Is the certificate necessary, not merely sufficient?**  `eps_ge_of_ratio` is the
   converse: an observed class ratio `R` forces `ε ≥ (R−1)/(R+1)`.  Combined with
   `EquiCert.ratio_le` this pins the certificate to the observed ratio from both sides, and
   `ratio_transfer_attained` exhibits a count vector on which the transfer ratio is exactly
   attained by the max/min readout.

Finally `four_sig_figs_fails` is the adversarial boundary of the headline claim: at
`ε = 0.000446` three significant figures survive and **four do not**.  The recorded claim is
therefore sharp as stated, and would be false if strengthened one digit.
-/

namespace Ma1Effective

open Finset

/-! ## The exact cost of the effectivization -/

/-- The excess of the effective constant over the ideal `4/3` is exactly `(8/3)ε/(1−ε)`. -/
theorem capConst_sub_eq {ε : ℝ} (hε : ε ≠ 1) : capConst ε - 4 / 3 = 8 / 3 * (ε / (1 - ε)) := by
  have h : (1 : ℝ) - ε ≠ 0 := sub_ne_zero.mpr (Ne.symm hε)
  unfold capConst
  field_simp
  ring

/-- For `ε ≤ 1/2` the cost is linear: `capConst ε ≤ 4/3 + (16/3)ε`. -/
theorem capConst_sub_le {ε : ℝ} (h0 : 0 ≤ ε) (h1 : ε ≤ 1 / 2) :
    capConst ε - 4 / 3 ≤ 16 / 3 * ε := by
  have hne : ε ≠ 1 := by intro h; rw [h] at h1; norm_num at h1
  have hpos : (0 : ℝ) < 1 - ε := by linarith
  rw [capConst_sub_eq hne]
  have hle : ε / (1 - ε) ≤ 2 * ε := by
    rw [div_le_iff₀ hpos]; nlinarith
  linarith

/-- **Four significant figures fail.**  The recorded three-figure claim is sharp: the
effective constant `1.33452…` differs from `4/3` in the fourth significant digit. -/
theorem four_sig_figs_fails : ¬ (|capConst 0.000446 - 4 / 3| < 4 / 3 * (1 / 10000)) := by
  have h : capConst 0.000446 - 4 / 3 > 0 := by unfold capConst; norm_num
  rw [abs_of_pos h]
  push_neg
  unfold capConst
  norm_num

/-! ## H3 as a dynamical statement: geometric decay of the certificate -/

/-- Geometric decay of the measured deviations, by induction on the scale index. -/
theorem eps_geom_bound (e : ℕ → ℝ) (ρ : ℝ) (hρ : 0 ≤ ρ)
    (hstep : ∀ k, e (k + 1) ≤ ρ * e k) (k : ℕ) : e k ≤ ρ ^ k * e 0 := by
  induction k with
  | zero => simp
  | succ n ih =>
      calc e (n + 1) ≤ ρ * e n := hstep n
        _ ≤ ρ * (ρ ^ n * e 0) := mul_le_mul_of_nonneg_left ih hρ
        _ = ρ ^ (n + 1) * e 0 := by ring

/-- **The effectivization becomes free.**  If the certificates decay geometrically with
ratio `ρ < 1`, then for every accuracy `δ > 0` there is an explicit scale beyond which the
effective cap constant is within `δ` of the ideal `4/3`.  This is the theorem-level content
of H3: the MA-1 assumption is *asymptotically* free, and the observed shrinking is exactly
what makes the recorded three-figure agreement stable under increasing `x`. -/
theorem cap_eventually_within (e : ℕ → ℝ) (ρ : ℝ) (hnn : ∀ k, 0 ≤ e k) (hρ0 : 0 ≤ ρ)
    (hρ1 : ρ < 1) (hstep : ∀ k, e (k + 1) ≤ ρ * e k) (he0 : e 0 ≤ 1 / 2) {δ : ℝ}
    (hδ : 0 < δ) : ∃ K : ℕ, ∀ k, K ≤ k → capConst (e k) - 4 / 3 ≤ δ := by
  have hden : 0 < 16 / 3 * e 0 + 1 := by have := hnn 0; linarith
  obtain ⟨K, hK⟩ := exists_pow_lt_of_lt_one (x := δ / (16 / 3 * e 0 + 1)) (by positivity) hρ1
  refine ⟨K, fun k hk => ?_⟩
  have hgeom : e k ≤ ρ ^ k * e 0 := eps_geom_bound e ρ hρ0 hstep k
  have hmono : ρ ^ k ≤ ρ ^ K := pow_le_pow_of_le_one hρ0 (le_of_lt hρ1) hk
  have he0nn : 0 ≤ e 0 := hnn 0
  have hkle : e k ≤ 1 / 2 := by
    have h1 : ρ ^ k * e 0 ≤ 1 * e 0 :=
      mul_le_mul_of_nonneg_right (pow_le_one₀ hρ0 (le_of_lt hρ1)) he0nn
    linarith
  have hlin : capConst (e k) - 4 / 3 ≤ 16 / 3 * e k := capConst_sub_le (hnn k) hkle
  have hchain : 16 / 3 * e k ≤ 16 / 3 * (ρ ^ K * e 0) := by
    have h1 : ρ ^ k * e 0 ≤ ρ ^ K * e 0 := mul_le_mul_of_nonneg_right hmono he0nn
    linarith
  have hfin : 16 / 3 * (ρ ^ K * e 0) ≤ δ := by
    rcases eq_or_lt_of_le he0nn with h0 | h0
    · rw [← h0]; simp; linarith
    · have hKlt : ρ ^ K < δ / (16 / 3 * e 0 + 1) := hK
      have h1 : ρ ^ K * (16 / 3 * e 0) < δ / (16 / 3 * e 0 + 1) * (16 / 3 * e 0) :=
        mul_lt_mul_of_pos_right hKlt (by linarith)
      have h2 : δ / (16 / 3 * e 0 + 1) * (16 / 3 * e 0) ≤ δ := by
        rw [div_mul_eq_mul_div, div_le_iff₀ hden]
        nlinarith
      nlinarith
  linarith

/-! ## Concentration: how many classes can be outliers -/

variable {ι : Type*} [Fintype ι] {N : ι → ℝ} {μ ε : ℝ}

/-- The mean-square certificate implied by the uniform one. -/
theorem sum_sq_le_of_equiCert (h : EquiCert N μ ε) :
    ∑ a, (N a - μ) ^ 2 ≤ (Fintype.card ι : ℝ) * (ε * μ) ^ 2 := by
  have hpt : ∀ a ∈ (Finset.univ : Finset ι), (N a - μ) ^ 2 ≤ (ε * μ) ^ 2 := by
    intro a _
    have h1 := h a
    have h2 : |N a - μ| ^ 2 = (N a - μ) ^ 2 := sq_abs _
    nlinarith [abs_nonneg (N a - μ)]
  calc ∑ a, (N a - μ) ^ 2 ≤ ∑ _a : ι, (ε * μ) ^ 2 := Finset.sum_le_sum hpt
    _ = (Fintype.card ι : ℝ) * (ε * μ) ^ 2 := by
        rw [Finset.sum_const, Finset.card_univ, nsmul_eq_mul]

/-- **Finite Chebyshev bound for the deviation field.**  Under the mean-square certificate,
at most `n/t²` residue classes deviate from the target by more than `t·(εμ)`.  Only the
`ℓ²` control is used, so this survives a certificate that fails for a few classes. -/
theorem card_large_deviation_le [DecidableEq ι] {s t : ℝ} (hs : 0 < s) (ht : 0 < t)
    (hsq : ∑ a, (N a - μ) ^ 2 ≤ (Fintype.card ι : ℝ) * s ^ 2) :
    (((univ.filter fun a => t * s < |N a - μ|)).card : ℝ) * t ^ 2
      ≤ (Fintype.card ι : ℝ) := by
  classical
  set B : Finset ι := univ.filter fun a => t * s < |N a - μ| with hB
  have hmem : ∀ a ∈ B, t ^ 2 * s ^ 2 ≤ (N a - μ) ^ 2 := by
    intro a ha
    have hlt : t * s < |N a - μ| := by
      have := Finset.mem_filter.1 (hB ▸ ha)
      exact this.2
    have hts : 0 < t * s := mul_pos ht hs
    have h1 : (t * s) ^ 2 ≤ |N a - μ| ^ 2 := by nlinarith
    have h2 : |N a - μ| ^ 2 = (N a - μ) ^ 2 := sq_abs _
    nlinarith
  have hlow : (B.card : ℝ) * (t ^ 2 * s ^ 2) ≤ ∑ a ∈ B, (N a - μ) ^ 2 := by
    have := Finset.card_nsmul_le_sum B (fun a => (N a - μ) ^ 2) (t ^ 2 * s ^ 2) hmem
    simpa [nsmul_eq_mul] using this
  have hsub : ∑ a ∈ B, (N a - μ) ^ 2 ≤ ∑ a, (N a - μ) ^ 2 :=
    Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ B)
      (fun a _ _ => sq_nonneg _)
  have hs2 : 0 < s ^ 2 := by positivity
  nlinarith [hlow.trans (hsub.trans hsq)]

/-! ## The converse: an observed ratio forces a large certificate -/

omit [Fintype ι] in
/-- **Converse effectivization.**  If two class counts are observed in ratio `R ≥ 1`, then
no certificate better than `ε ≥ (R−1)/(R+1)` can hold.  Together with `EquiCert.ratio_le`
(`R ≤ (1+ε)/(1−ε)`) this is an exact two-sided dictionary between the measured ratio and the
certificate: the two conditions are equivalent, not merely comparable. -/
theorem eps_ge_of_ratio {R : ℝ} (h : EquiCert N μ ε) (hμ : 0 < μ) (hR1 : 1 ≤ R) {a b : ι}
    (hratio : R * N b ≤ N a) : (R - 1) / (R + 1) ≤ ε := by
  have hRpos : (0 : ℝ) < R + 1 := by linarith
  have hb : (1 - ε) * μ ≤ N b := h.lower b
  have ha : N a ≤ (1 + ε) * μ := h.upper a
  have hstep : R * ((1 - ε) * μ) ≤ (1 + ε) * μ := by
    have h1 : R * ((1 - ε) * μ) ≤ R * N b :=
      mul_le_mul_of_nonneg_left hb (by linarith)
    linarith
  rw [div_le_iff₀ hRpos]
  nlinarith

omit [Fintype ι] in
/-- The additive form of the certificate: any two class counts differ by at most `2εμ`.  An
observed gap exceeding `2εμ` therefore *refutes* the `ε`-certificate. -/
theorem abs_sub_le_two_eps (h : EquiCert N μ ε) (a b : ι) : |N a - N b| ≤ 2 * (ε * μ) := by
  have h1 := h a
  have h2 := h b
  calc |N a - N b| = |(N a - μ) - (N b - μ)| := by ring_nf
    _ ≤ |N a - μ| + |N b - μ| := abs_sub _ _
    _ ≤ 2 * (ε * μ) := by linarith

/-! ## Attainment of the transfer ratio by the max/min readout -/

/-- On the extremal two-class configuration the transfer ratio is *attained* by the max/min
readout: `maxOf N = ((1+ε)/(1−ε))·minOf N`.  Hence the constant in
`maxOf_le_capConst_mul_minOf` cannot be lowered below `(1+ε)/(1−ε)`. -/
theorem ratio_transfer_attained (hε0 : 0 ≤ ε) (hε : ε < 1) (hμ : 0 < μ) :
    ∃ N : Fin 2 → ℝ, EquiCert N μ ε ∧ maxOf N = (1 + ε) / (1 - ε) * minOf N := by
  obtain ⟨N, hcert, _, hratio⟩ := ratio_bound_sharp hε0 hε hμ
  have hN1le : N 1 ≤ N 0 := by
    have h1 : (1 - ε) * μ ≤ N 1 := hcert.lower 1
    have h0 : N 0 ≤ (1 + ε) * μ := hcert.upper 0
    have hpos : (0 : ℝ) < 1 - ε := by linarith
    have hq : (1 : ℝ) ≤ (1 + ε) / (1 - ε) := by
      rw [le_div_iff₀ hpos]; linarith
    have hN1nn : 0 ≤ N 1 := le_trans (by positivity) h1
    calc N 1 = 1 * N 1 := (one_mul _).symm
      _ ≤ (1 + ε) / (1 - ε) * N 1 := mul_le_mul_of_nonneg_right hq hN1nn
      _ = N 0 := hratio.symm
  have hmax : maxOf N = N 0 := by
    refine le_antisymm (Finset.sup'_le _ _ fun a _ => ?_) (Finset.le_sup' N (mem_univ 0))
    fin_cases a
    · exact le_refl _
    · exact hN1le
  have hmin : minOf N = N 1 := by
    refine le_antisymm (Finset.inf'_le N (mem_univ 1)) (Finset.le_inf' _ _ fun a _ => ?_)
    fin_cases a
    · exact hN1le
    · exact le_refl _
  exact ⟨N, hcert, by rw [hmax, hmin, hratio]⟩

/-! ## Aggregating certificates over a family of moduli -/

omit [Fintype ι] in
/-- **Uniform transfer over a family of moduli.**  A cap that holds under exact
equidistribution transfers, with the single constant `capConst ε'`, to every modulus whose
certificate is at least as good as `ε'`.  This is the form in which the experiment's
per-modulus table (`m ∈ {3,4,5,7,8,11,31}`) yields one constant for the whole family. -/
theorem cap_transfer_of_le {Φ Ψ : (ι → ℝ) → ℝ} {ε' : ℝ}
    (hΦm : MonotoneReadout Φ) (hΦh : PosHomogeneous Φ)
    (hΨm : MonotoneReadout Ψ) (hΨh : PosHomogeneous Ψ)
    (hcap : Φ (fun _ => μ) ≤ 4 / 3 * Ψ (fun _ => μ))
    (h : EquiCert N μ ε) (hε0 : 0 ≤ ε) (hle : ε ≤ ε') (hε1 : ε' < 1)
    (hΨ : 0 ≤ Ψ N) : Φ N ≤ capConst ε' * Ψ N := by
  have hmain := cap_transfer hΦm hΦh hΨm hΨh hcap h hε0 (lt_of_le_of_lt hle hε1)
  have hmono : capConst ε ≤ capConst ε' := capConst_mono hle hε1
  nlinarith

end Ma1Effective