/-
# Per-N predictor at the sampling ceiling (paper 142, exp 472)

Setting.  For each modulus `N` in a finite panel `ι` we observe `n` binary outcomes
`y N i ∈ {0,1}` (in exp 472: `n = 60` sieve values per `N`, outcome = "smooth").  A *per-N
predictor* is any function `f : ι → ℝ` (in exp 472: `f N = β₀ + β₁·QRcount(N)`).

This file proves the exact finite-sample algebra behind the claims

* **Ceiling.**  No per-N predictor, however rich its feature set, can push the residual
  sum of squares below the within-N sum of squares `SSW`; hence its in-sample `R²` is at
  most `SSB / SST` (`rsq_le_ceiling`).  The gap is exactly `n·∑ (ȳ_N − f N)²`
  (`rss_decomp`): *the only thing richer features can still capture is the distance of the
  predictor from the per-N means.*
* **Binomial floor.**  For binary data `SSW = n·∑ m_N (1 − m_N)` exactly
  (`ssw_binary`), and for a `Binomial(n, θ)` count the expected squared deviation of the
  observed rate from any centre `c` is `(θ − c)² + θ(1 − θ)/n` (`binom_bias_variance`),
  derived from Mathlib's Bernstein-polynomial variance identity.  Summed over the panel,
  this is the "signal + floor" law (`panel_signal_plus_floor`): the observed per-N variance
  is the systematic variance plus the pure `n`-draw sampling floor.
* **Ceiling grows with `n`.**  The population ceiling `V / (V + E/n)` is strictly
  increasing in `n` and tends to `1` (`ceiling_strictMono`, `ceiling_tendsto_one`):
  richer features need more values per `N` first.
* **One feature = squared correlation.**  The OLS predictor on a single per-N feature has
  `R² = ceiling · ρ²`, with `ρ` the correlation between the feature and the per-N means
  (`one_feature_rsq_eq`); `ρ² ≤ 1` by least squares (`scov_sq_le`).
* **Fraction-of-ceiling law.**  If the residual is `κ` times the floor then the predictor
  attains the fraction `1 − (κ − 1)·F/(T − F)` of the ceiling (`frac_of_ceiling`), with
  the exp 472 numerical instances checked as interval statements, plus a consistency
  check showing the `u = 2.5` triple (R², ceiling, κ) is in mild tension
  (`exp472_u25_tension`) while `u = 3.5` is consistent (`exp472_u35_ratio`).

Everything is elementary and exact; no `native_decide` is used.
-/
import Mathlib

namespace PerNPredictor

open Finset

/-! ## Balanced panel: ANOVA and the ceiling theorem -/

section Panel

variable {ι : Type*} [Fintype ι] {n : ℕ}

/-- Per-N mean of the `n` observations. -/
noncomputable def groupMean (y : ι → Fin n → ℝ) (N : ι) : ℝ := (∑ i, y N i) / n

/-- Within-N (pure sampling) sum of squares. -/
noncomputable def SSW (y : ι → Fin n → ℝ) : ℝ :=
  ∑ N, ∑ i, (y N i - groupMean y N) ^ 2

/-- Residual sum of squares of a per-N predictor `f`. -/
noncomputable def RSS (y : ι → Fin n → ℝ) (f : ι → ℝ) : ℝ :=
  ∑ N, ∑ i, (y N i - f N) ^ 2

omit [Fintype ι] in
/-- Within one group, deviations from the group mean sum to zero. -/
lemma sum_sub_groupMean (hn : 0 < n) (y : ι → Fin n → ℝ) (N : ι) :
    ∑ i, (y N i - groupMean y N) = 0 := by
  have hn' : (n : ℝ) ≠ 0 := by exact_mod_cast hn.ne'
  rw [Finset.sum_sub_distrib, Finset.sum_const, Finset.card_univ, Fintype.card_fin,
    nsmul_eq_mul, groupMean]
  field_simp
  ring

/-- **Residual decomposition.**  For every per-N predictor `f`,
`RSS(f) = SSW + n · ∑_N (ȳ_N − f N)²`. -/
theorem rss_decomp (hn : 0 < n) (y : ι → Fin n → ℝ) (f : ι → ℝ) :
    RSS y f = SSW y + n * ∑ N, (groupMean y N - f N) ^ 2 := by
  unfold RSS SSW
  rw [Finset.mul_sum, ← Finset.sum_add_distrib]
  refine Finset.sum_congr rfl (fun N _ => ?_)
  have hexp : ∀ i, (y N i - f N) ^ 2 = (y N i - groupMean y N) ^ 2
      + 2 * (groupMean y N - f N) * (y N i - groupMean y N)
      + (groupMean y N - f N) ^ 2 := fun i => by ring
  simp only [hexp, Finset.sum_add_distrib, ← Finset.mul_sum, sum_sub_groupMean hn,
    Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
  ring

/-- **Ceiling (residual form).**  No per-N predictor beats the within-N sum of squares. -/
theorem ssw_le_rss (hn : 0 < n) (y : ι → Fin n → ℝ) (f : ι → ℝ) : SSW y ≤ RSS y f := by
  rw [rss_decomp hn]
  have : 0 ≤ ∑ N, (groupMean y N - f N) ^ 2 := Finset.sum_nonneg (fun _ _ => sq_nonneg _)
  have hn0 : (0 : ℝ) ≤ n := Nat.cast_nonneg n
  nlinarith

/-- The ceiling is attained exactly by the per-N means. -/
theorem rss_eq_ssw_iff (hn : 0 < n) (y : ι → Fin n → ℝ) (f : ι → ℝ) :
    RSS y f = SSW y ↔ f = groupMean y := by
  rw [rss_decomp hn]
  have hn0 : (0 : ℝ) < n := by exact_mod_cast hn
  constructor
  · intro h
    have hs : ∑ N, (groupMean y N - f N) ^ 2 = 0 := by
      have : (n : ℝ) * ∑ N, (groupMean y N - f N) ^ 2 = 0 := by linarith
      rcases mul_eq_zero.mp this with h1 | h1
      · exact absurd h1 hn0.ne'
      · exact h1
    funext N
    have := (Finset.sum_eq_zero_iff_of_nonneg (fun N _ => sq_nonneg
      (groupMean y N - f N))).mp hs N (Finset.mem_univ _)
    have := pow_eq_zero_iff (n := 2) (by norm_num) |>.mp this
    linarith
  · rintro rfl
    simp

/-- In-sample coefficient of determination of a per-N predictor, relative to a total
sum of squares `SST`. -/
noncomputable def rsq (SST : ℝ) (y : ι → Fin n → ℝ) (f : ι → ℝ) : ℝ := 1 - RSS y f / SST

/-- **Ceiling theorem.**  For any total sum of squares `SST > 0` (e.g. around the grand
mean), every per-N predictor has `R² ≤ 1 − SSW/SST`, the sampling ceiling. -/
theorem rsq_le_ceiling (hn : 0 < n) {SST : ℝ} (hT : 0 < SST) (y : ι → Fin n → ℝ)
    (f : ι → ℝ) : rsq SST y f ≤ 1 - SSW y / SST := by
  unfold rsq
  have := div_le_div_of_nonneg_right (ssw_le_rss hn y f) hT.le
  linarith

/-- **Headroom.**  The `R²` that any richer per-N feature set could still add on top of `f`
is exactly `n·∑ (ȳ_N − f N)² / SST`. -/
theorem ceiling_sub_rsq (hn : 0 < n) (SST : ℝ) (y : ι → Fin n → ℝ)
    (f : ι → ℝ) :
    (1 - SSW y / SST) - rsq SST y f = (n * ∑ N, (groupMean y N - f N) ^ 2) / SST := by
  unfold rsq
  rw [rss_decomp hn, add_div]
  ring

/-- **One-way ANOVA.**  Around any constant `c` (e.g. the grand mean), the total sum of
squares splits as within + `n ·` between. -/
theorem anova (hn : 0 < n) (y : ι → Fin n → ℝ) (c : ℝ) :
    RSS y (fun _ => c) = SSW y + n * ∑ N, (groupMean y N - c) ^ 2 :=
  rss_decomp hn y _

/-- **Binary data: the empirical binomial floor.**  For `0/1` observations the within-N
sum of squares is `n · ∑_N m_N (1 − m_N)`. -/
theorem ssw_binary (hn : 0 < n) (y : ι → Fin n → ℝ)
    (hy : ∀ N i, y N i = 0 ∨ y N i = 1) :
    SSW y = n * ∑ N, groupMean y N * (1 - groupMean y N) := by
  unfold SSW
  rw [Finset.mul_sum]
  refine Finset.sum_congr rfl (fun N _ => ?_)
  have hn' : (n : ℝ) ≠ 0 := by exact_mod_cast hn.ne'
  have hsq : ∀ i, y N i ^ 2 = y N i := fun i => by
    rcases hy N i with h | h <;> rw [h] <;> norm_num
  have hexp : ∀ i, (y N i - groupMean y N) ^ 2
      = y N i - 2 * groupMean y N * y N i + groupMean y N ^ 2 := fun i => by
    rw [sub_sq, hsq]; ring
  simp only [hexp, Finset.sum_add_distrib, Finset.sum_sub_distrib, ← Finset.mul_sum,
    Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
  have hsum : ∑ i, y N i = n * groupMean y N := by
    rw [groupMean]; field_simp
  rw [hsum]
  ring

end Panel

/-! ## Binomial sampling floor (from the Bernstein variance identity) -/

/-- Binomial probability `C(n,k) θ^k (1-θ)^(n-k)`. -/
noncomputable def binomW (n : ℕ) (θ : ℝ) (k : ℕ) : ℝ :=
  (n.choose k : ℝ) * θ ^ k * (1 - θ) ^ (n - k)

lemma binomW_eq_eval (n : ℕ) (θ : ℝ) (k : ℕ) :
    binomW n θ k = (bernsteinPolynomial ℝ n k).eval θ := by
  simp [binomW, bernsteinPolynomial]

/-- Total mass one. -/
theorem sum_binomW (n : ℕ) (θ : ℝ) : ∑ k ∈ range (n + 1), binomW n θ k = 1 := by
  have h := congrArg (Polynomial.eval θ) (bernsteinPolynomial.sum ℝ n)
  rw [Polynomial.eval_finset_sum] at h
  simpa [binomW_eq_eval] using h

/-- Mean `nθ`. -/
theorem sum_mul_binomW (n : ℕ) (θ : ℝ) :
    ∑ k ∈ range (n + 1), (k : ℝ) * binomW n θ k = n * θ := by
  have h := congrArg (Polynomial.eval θ) (bernsteinPolynomial.sum_smul ℝ n)
  rw [Polynomial.eval_finset_sum] at h
  simpa [binomW_eq_eval, nsmul_eq_mul] using h

/-- Variance `nθ(1-θ)`: the pure binomial sampling floor. -/
theorem sum_sq_binomW (n : ℕ) (θ : ℝ) :
    ∑ k ∈ range (n + 1), ((n : ℝ) * θ - k) ^ 2 * binomW n θ k = n * θ * (1 - θ) := by
  have h := congrArg (Polynomial.eval θ) (bernsteinPolynomial.variance ℝ n)
  rw [Polynomial.eval_finset_sum] at h
  simpa [binomW_eq_eval, nsmul_eq_mul, mul_assoc] using h

/-- **Bias–variance law for an observed rate.**  If `k ∼ Binomial(n, θ)` then for every
centre `c`, `E[(k/n − c)²] = (θ − c)² + θ(1 − θ)/n`. -/
theorem binom_bias_variance {n : ℕ} (hn : 0 < n) (θ c : ℝ) :
    ∑ k ∈ range (n + 1), ((k : ℝ) / n - c) ^ 2 * binomW n θ k
      = (θ - c) ^ 2 + θ * (1 - θ) / n := by
  have hn' : (n : ℝ) ≠ 0 := by exact_mod_cast hn.ne'
  have hexp : ∀ k : ℕ, ((k : ℝ) / n - c) ^ 2 * binomW n θ k
      = (((n : ℝ) * θ - k) ^ 2 * binomW n θ k) / (n : ℝ) ^ 2
        + (2 * (θ - c) / n) * ((k : ℝ) * binomW n θ k)
        + (c ^ 2 - θ ^ 2) * binomW n θ k := fun k => by
    field_simp
    ring
  simp only [hexp, Finset.sum_add_distrib, ← Finset.sum_div, ← Finset.mul_sum,
    sum_sq_binomW, sum_mul_binomW, sum_binomW]
  field_simp
  ring

/-- Unbiasedness of the observed rate. -/
theorem binom_rate_mean {n : ℕ} (hn : 0 < n) (θ : ℝ) :
    ∑ k ∈ range (n + 1), ((k : ℝ) / n) * binomW n θ k = θ := by
  have hn' : (n : ℝ) ≠ 0 := by exact_mod_cast hn.ne'
  have : ∀ k : ℕ, ((k : ℝ) / n) * binomW n θ k = ((k : ℝ) * binomW n θ k) / n :=
    fun k => by ring
  simp only [this, ← Finset.sum_div, sum_mul_binomW]
  field_simp

/-- **Signal + floor across a panel.**  If each `N` has true rate `θ N` and its observed
rate comes from `n` independent draws, then the expected squared deviation of observed
rates from any common centre `c`, summed over the panel, equals the systematic part
`∑ (θ N − c)²` plus the sampling floor `∑ θ N (1 − θ N) / n`. -/
theorem panel_signal_plus_floor {ι : Type*} [Fintype ι] {n : ℕ} (hn : 0 < n)
    (θ : ι → ℝ) (c : ℝ) :
    ∑ N, ∑ k ∈ range (n + 1), ((k : ℝ) / n - c) ^ 2 * binomW n (θ N) k
      = ∑ N, (θ N - c) ^ 2 + (∑ N, θ N * (1 - θ N)) / n := by
  simp only [binom_bias_variance hn, Finset.sum_add_distrib, Finset.sum_div]

/-- The binomial floor per draw is at most `1/4`, attained only at `θ = 1/2`. -/
theorem floor_le_quarter (θ : ℝ) : θ * (1 - θ) ≤ 1 / 4 := by
  nlinarith [sq_nonneg (θ - 1 / 2)]

/-! ## The population ceiling and its dependence on the number of values per N -/

/-- Population ceiling of `R²` when the systematic variance is `V` and the mean
per-draw binomial variance is `E`, with `n` values per `N`. -/
noncomputable def ceiling (V E : ℝ) (n : ℕ) : ℝ := V / (V + E / n)

/-- **More values per N raise the ceiling (strictly).** -/
theorem ceiling_strictMono {V E : ℝ} (hV : 0 < V) (hE : 0 < E) :
    StrictMono (fun n : ℕ => ceiling V E (n + 1)) := by
  refine strictMono_nat_of_lt_succ (fun n => ?_)
  simp only [ceiling]
  have h1 : (0 : ℝ) < (n : ℝ) + 1 := by positivity
  have h2 : (0 : ℝ) < (n : ℝ) + 1 + 1 := by positivity
  push_cast
  rw [div_lt_div_iff₀ (by positivity) (by positivity)]
  have : E / ((n : ℝ) + 1 + 1) < E / ((n : ℝ) + 1) :=
    div_lt_div_of_pos_left hE h1 (by linarith)
  nlinarith

/-- **The ceiling tends to `1` as the number of values per N grows.** -/
theorem ceiling_tendsto_one {V E : ℝ} (hV : 0 < V) :
    Filter.Tendsto (fun n : ℕ => ceiling V E n) Filter.atTop (nhds 1) := by
  have h : Filter.Tendsto (fun n : ℕ => E / (n : ℝ)) Filter.atTop (nhds 0) :=
    tendsto_const_nhds.div_atTop tendsto_natCast_atTop_atTop
  have h2 : Filter.Tendsto (fun n : ℕ => V / (V + E / (n : ℝ))) Filter.atTop
      (nhds (V / (V + 0))) :=
    tendsto_const_nhds.div (tendsto_const_nhds.add h) (by simpa using hV.ne')
  simpa [ceiling, hV.ne'] using h2

/-- The ceiling is strictly below `1` at any finite `n` (positive floor). -/
theorem ceiling_lt_one {V E : ℝ} (hV : 0 < V) (hE : 0 < E) {n : ℕ} (hn : 0 < n) :
    ceiling V E n < 1 := by
  unfold ceiling
  have : 0 < E / n := div_pos hE (by exact_mod_cast hn)
  rw [div_lt_one (by linarith)]
  linarith

/-! ## Fraction of ceiling achieved by a near-floor predictor -/

/-- **Fraction-of-ceiling law.**  With total variance `T`, floor `F < T` and residual
`κ·F`, the attained `R² = 1 − κF/T` is the fraction `1 − (κ − 1)F/(T − F)` of the
ceiling `1 − F/T`. -/
theorem frac_of_ceiling {T F κ : ℝ} (hT : 0 < T) (hFT : F < T) :
    (1 - κ * F / T) / (1 - F / T) = 1 - (κ - 1) * F / (T - F) := by
  have h1 : T - F ≠ 0 := by linarith
  have h2 : 1 - F / T ≠ 0 := by
    rw [sub_ne_zero, ne_comm, Ne, div_eq_one_iff_eq hT.ne']; exact hFT.ne
  field_simp
  ring

/-- **Residual-to-floor ratio controls the uncaptured systematic share.**  If the
residual is at most `κ` times the floor then the predictor captures at least the share
`1 − (κ − 1)F/(T − F)` of the systematic variance `T − F`. -/
theorem captured_share_ge {T F R κ : ℝ} (hFT : F < T) (hR : R ≤ κ * F) :
    1 - (κ - 1) * F / (T - F) ≤ (T - R) / (T - F) := by
  have h1 : 0 < T - F := by linarith
  have heq : 1 - (κ - 1) * F / (T - F) = (T - κ * F) / (T - F) := by
    field_simp; ring
  rw [heq]
  exact div_le_div_of_nonneg_right (by linarith) h1.le

/-- **Residual-ratio identity.**  On a common total sum of squares, a residual equal to
`κ` times the within-N floor satisfies `1 − R² = κ · (1 − ceiling)`. -/
theorem one_sub_rsq_eq_ratio_mul {T W R : ℝ} (hW : W ≠ 0) :
    1 - (1 - R / T) = (R / W) * (1 - (1 - W / T)) := by
  field_simp
  ring

/-- **Critic's consistency check (exp 472, `u = 2.5`).**  If the in-sample identity
`1 − R² = κ(1 − ceiling)` held with `R² = 0.2998` and residual/floor ratio `κ ≤ 1.24`, the
ceiling would be below `0.436`, not `≈ 0.45`; the reported triple is only consistent if
the ceiling and the held-out `R²` are measured on different sums of squares (or the ratio
at `u = 2.5` is nearer `1.27`). -/
theorem exp472_u25_tension {κ c : ℝ} (hκ0 : 0 ≤ κ) (hκ : κ ≤ 1.24)
    (h : 1 - 0.2998 = κ * (1 - c)) : c < 0.436 := by
  by_contra hc
  push_neg at hc
  nlinarith [mul_le_mul_of_nonneg_left (show 1 - c ≤ 0.564 by linarith) hκ0]

/-- At `u = 3.5` the reported numbers are mutually consistent: `R² = 0.2246`, ceiling
`0.31` force `κ = 0.7754/0.69 ∈ (1.12, 1.13)`, inside the reported band `1.12–1.24`. -/
theorem exp472_u35_ratio {κ : ℝ} (h : 1 - 0.2246 = κ * (1 - 0.31)) :
    1.12 < κ ∧ κ < 1.13 := by
  constructor <;> nlinarith

/-- exp 472, `u = 2.5`: `R² = 0.2998` against ceiling `0.45` is between 66% and 67%. -/
theorem exp472_u25_fraction : 0.66 < (0.2998 : ℝ) / 0.45 ∧ (0.2998 : ℝ) / 0.45 < 0.67 := by
  constructor <;> rw [div_eq_mul_inv] <;> norm_num

/-- exp 472, `u = 3.5`: `R² = 0.2246` against ceiling `0.31` is between 72% and 73%. -/
theorem exp472_u35_fraction : 0.72 < (0.2246 : ℝ) / 0.31 ∧ (0.2246 : ℝ) / 0.31 < 0.73 := by
  constructor <;> rw [div_eq_mul_inv] <;> norm_num


/-! ## The one-feature linear predictor: fraction of ceiling = squared correlation -/

section OneFeature

variable {ι : Type*} [Fintype ι]

/-- Panel mean of a per-N quantity. -/
noncomputable def pmean (v : ι → ℝ) : ℝ := (∑ N, v N) / Fintype.card ι

/-- Centred cross-product sum (unnormalised covariance) of two per-N quantities. -/
noncomputable def scov (u v : ι → ℝ) : ℝ := ∑ N, (u N - pmean u) * (v N - pmean v)

lemma sum_sub_pmean [Nonempty ι] (v : ι → ℝ) : ∑ N, (v N - pmean v) = 0 := by
  have hc : (Fintype.card ι : ℝ) ≠ 0 := by exact_mod_cast Fintype.card_ne_zero
  rw [Finset.sum_sub_distrib, Finset.sum_const, Finset.card_univ, nsmul_eq_mul, pmean]
  field_simp
  ring

lemma scov_self_nonneg (v : ι → ℝ) : 0 ≤ scov v v :=
  Finset.sum_nonneg (fun _ _ => mul_self_nonneg _)

lemma sum_eq_card_mul_pmean [Nonempty ι] (v : ι → ℝ) :
    ∑ N, v N = Fintype.card ι * pmean v := by
  have hc : (Fintype.card ι : ℝ) ≠ 0 := by exact_mod_cast Fintype.card_ne_zero
  rw [pmean]; field_simp

/-- Exact decomposition of the least-squares objective of a line `a + b·x` fitted to `m`. -/
theorem linfit_decomp [Nonempty ι] (m x : ι → ℝ) (a b : ℝ) :
    ∑ N, (m N - (a + b * x N)) ^ 2
      = scov m m - 2 * b * scov x m + b ^ 2 * scov x x
        + Fintype.card ι * (pmean m - a - b * pmean x) ^ 2 := by
  have hexp : ∀ N, (m N - (a + b * x N)) ^ 2
      = (m N - pmean m) * (m N - pmean m) - 2 * b * ((x N - pmean x) * (m N - pmean m))
        + b ^ 2 * ((x N - pmean x) * (x N - pmean x))
        + 2 * (pmean m - a - b * pmean x) * (m N - pmean m)
        - 2 * b * (pmean m - a - b * pmean x) * (x N - pmean x)
        + (pmean m - a - b * pmean x) ^ 2 := fun N => by ring
  simp only [hexp, Finset.sum_add_distrib, Finset.sum_sub_distrib, ← Finset.mul_sum,
    Finset.sum_const, Finset.card_univ, nsmul_eq_mul]
  rw [sum_eq_card_mul_pmean m, sum_eq_card_mul_pmean x]
  unfold scov
  ring

/-- **Least-squares lower bound** (completing the square): every line leaves at least
`S_mm − S_xm²/S_xx`. -/
theorem linfit_lower [Nonempty ι] (m x : ι → ℝ) (hx : 0 < scov x x) (a b : ℝ) :
    scov m m - scov x m ^ 2 / scov x x ≤ ∑ N, (m N - (a + b * x N)) ^ 2 := by
  rw [linfit_decomp]
  have h1 : 0 ≤ (Fintype.card ι : ℝ) * (pmean m - a - b * pmean x) ^ 2 := by positivity
  have h2 : scov m m - scov x m ^ 2 / scov x x
      = scov m m - 2 * b * scov x m + b ^ 2 * scov x x
        - (b * scov x x - scov x m) ^ 2 / scov x x := by
    field_simp; ring
  have h3 : 0 ≤ (b * scov x x - scov x m) ^ 2 / scov x x := by positivity
  linarith

/-- OLS slope and intercept. -/
noncomputable def olsSlope (m x : ι → ℝ) : ℝ := scov x m / scov x x
noncomputable def olsIntercept (m x : ι → ℝ) : ℝ := pmean m - olsSlope m x * pmean x

/-- The OLS line attains the least-squares lower bound. -/
theorem linfit_ols [Nonempty ι] (m x : ι → ℝ) (hx : 0 < scov x x) :
    ∑ N, (m N - (olsIntercept m x + olsSlope m x * x N)) ^ 2
      = scov m m - scov x m ^ 2 / scov x x := by
  rw [linfit_decomp]
  unfold olsIntercept olsSlope
  field_simp
  ring

/-- **Cauchy–Schwarz, recovered from least squares:** `S_xm² ≤ S_xx · S_mm`. -/
theorem scov_sq_le [Nonempty ι] (m x : ι → ℝ) (hx : 0 < scov x x) :
    scov x m ^ 2 ≤ scov x x * scov m m := by
  have h := linfit_ols m x hx
  have h0 : 0 ≤ ∑ N, (m N - (olsIntercept m x + olsSlope m x * x N)) ^ 2 :=
    Finset.sum_nonneg (fun _ _ => sq_nonneg _)
  rw [h] at h0
  have : scov x m ^ 2 / scov x x ≤ scov m m := by linarith
  rwa [div_le_iff₀ hx, mul_comm] at this

variable {n : ℕ}

/-- **Best one-feature residual.**  Among all predictors `β₀ + β₁·x(N)` built on a single
per-N feature `x`, the residual sum of squares is at least
`SSW + n·(S_mm − S_xm²/S_xx)` (with `m` the per-N means), and OLS on the per-N means
attains it. -/
theorem one_feature_rss_lower [Nonempty ι] (hn : 0 < n) (y : ι → Fin n → ℝ) (x : ι → ℝ)
    (hx : 0 < scov x x) (a b : ℝ) :
    SSW y + n * (scov (groupMean y) (groupMean y)
        - scov x (groupMean y) ^ 2 / scov x x) ≤ RSS y (fun N => a + b * x N) := by
  rw [rss_decomp hn]
  have := linfit_lower (groupMean y) x hx a b
  have hn0 : (0 : ℝ) ≤ n := Nat.cast_nonneg n
  nlinarith

/-- Total sum of squares of the panel around its grand mean. -/
noncomputable def SST (y : ι → Fin n → ℝ) : ℝ := RSS y (fun _ => pmean (groupMean y))

/-- **Fraction-of-ceiling = squared correlation.**  The OLS one-feature predictor has
in-sample `R²` equal to the sampling ceiling `1 − SSW/SST` times the squared correlation
`ρ² = S_xm² / (S_xx S_mm)` between the feature and the per-N means.  Thus "the one-feature
predictor reaches 66%/73% of ceiling" is exactly the statement `ρ² ≈ 0.66 / 0.73`. -/
theorem one_feature_rsq_eq [Nonempty ι] (hn : 0 < n) (y : ι → Fin n → ℝ) (x : ι → ℝ)
    (hx : 0 < scov x x) (hm : 0 < scov (groupMean y) (groupMean y)) :
    rsq (SST y) y (fun N => olsIntercept (groupMean y) x + olsSlope (groupMean y) x * x N)
      = (1 - SSW y / SST y)
        * (scov x (groupMean y) ^ 2 / (scov x x * scov (groupMean y) (groupMean y))) := by
  have hT : SST y = SSW y + n * scov (groupMean y) (groupMean y) := by
    unfold SST scov
    rw [rss_decomp hn]
    congr 2
    exact Finset.sum_congr rfl (fun N _ => by ring)
  have hn0 : (0 : ℝ) < n := by exact_mod_cast hn
  have hW : 0 ≤ SSW y := Finset.sum_nonneg (fun _ _ =>
    Finset.sum_nonneg (fun _ _ => sq_nonneg _))
  have hTpos : 0 < SST y := by rw [hT]; positivity
  unfold rsq
  rw [rss_decomp hn, linfit_ols _ _ hx, hT]
  have hT' : SSW y + n * scov (groupMean y) (groupMean y) ≠ 0 := by
    rw [← hT]; exact hTpos.ne'
  field_simp
  ring

/-- The squared correlation is at most one, so the one-feature predictor never exceeds
the ceiling (consistent with `rsq_le_ceiling`). -/
theorem sq_corr_le_one [Nonempty ι] (m x : ι → ℝ) (hx : 0 < scov x x)
    (hm : 0 < scov m m) : scov x m ^ 2 / (scov x x * scov m m) ≤ 1 := by
  rw [div_le_one (by positivity)]
  exact scov_sq_le m x hx

end OneFeature

end PerNPredictor