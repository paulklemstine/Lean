import Mathlib

/-!
# Weighted Riesz Means and Power–Logarithm Asymptotics

This file develops, from first principles inside Mathlib, the analytic engine
behind asymptotic expansions of *weighted Riesz means* of arithmetic sequences,
in the regime relevant to the average behaviour of arithmetic functions such as
Hurwitz class numbers.

The motivating claim (Zagier '75 / Duke–Imamoğlu–Tóth '19 circle of ideas) is
that a suitably weighted mean of an arithmetic function behaves like
`C · X^α · (log X)^k` as `X → ∞`, where the power `α` and the log-power `k` are
determined by the location and order of the dominant singularity of the
associated Dirichlet series.  Here we isolate and *prove* the two clean model
regimes that already exhibit both features, together with the summation engine
that transfers an asymptotic equivalence through a Riesz (Cesàro) mean.

## Main results

* `sum_isLittleO_of_isLittleO` — the Stolz–Cesàro principle for little-o:
  if `h = o(g)` at `atTop`, `g` is eventually positive and its partial sums
  diverge, then the partial sums of `h` are `o` of those of `g`.

* `isEquivalent_sum` — partial summation preserves asymptotic equivalence:
  under the same divergence hypothesis, `f ~ g` implies
  `(∑_{n<N} f n) ~ (∑_{n<N} g n)`.  This is the abstract "Riesz-mean transfer".

* `power_sum_isEquivalent` — the pure power law (`k = 0`):
  `∑_{n<N} n^p ~ N^(p+1)/(p+1)` for real `p > 0`.

* `log_sum_isEquivalent` — the pure log law (Stirling's leading term, `k = 1`):
  `∑_{n<N} log n ~ N · log N`, i.e. `α = 1`, `k = 1`.

* `power_log_sum_isEquivalent` — the mixed power–log law:
  `∑_{n<N} n^p · log n ~ N^(p+1) · log N / (p+1)` for real `p > 0`, realizing the
  target shape `C · X^α · (log X)^k` with both `α = p+1 > 1` and `k = 1` nontrivial.

* `iterated_power_sum_isEquivalent` — a genuine second-order Riesz mean obtained
  by feeding `power_sum_isEquivalent` through `isEquivalent_sum`:
  `∑_{n<N} ∑_{m<n} m^p ~ N^(p+2) / ((p+1)(p+2))`.
-/

open Filter Finset intervalIntegral Asymptotics
open scoped BigOperators Topology

namespace WeightedRieszMean

/-! ## The Stolz–Cesàro engine for little-o and asymptotic equivalence -/

/-
**Stolz–Cesàro for little-o.**  If `h = o(g)` along `atTop`, `g` is
eventually positive, and the partial sums of `g` diverge to `+∞`, then the
partial sums of `h` are little-o of the partial sums of `g`.
-/
theorem sum_isLittleO_of_isLittleO {h g : ℕ → ℝ}
    (ho : h =o[atTop] g) (hgpos : ∀ᶠ n in atTop, 0 < g n)
    (hdiv : Tendsto (fun N => ∑ n ∈ range N, g n) atTop atTop) :
    (fun N => ∑ n ∈ range N, h n) =o[atTop] (fun N => ∑ n ∈ range N, g n) := by
  -- By definition of $o(g)$, there exists $M$ such that for all $n \geq M$, $|h(n)| \leq \frac{\epsilon}{2} g(n)$.
  have h_o : ∀ ε > 0, ∃ M, ∀ n ≥ M, abs (h n) ≤ ε / 2 * g n := by
    rw [ Asymptotics.isLittleO_iff ] at ho;
    exact fun ε hε => by rcases Filter.eventually_atTop.mp ( ho ( half_pos hε ) |> Filter.Eventually.and <| hgpos ) with ⟨ M, hM ⟩ ; exact ⟨ M, fun n hn => by simpa [ abs_of_pos ( hM n hn |>.2 ) ] using hM n hn |>.1 ⟩ ;
  -- Choose $M$ such that for all $n \geq M$, $|h(n)| \leq \frac{\epsilon}{2} g(n)$.
  have h_bound : ∀ ε > 0, ∃ M, ∀ N ≥ M, abs (∑ n ∈ Finset.range N, h n) ≤ abs (∑ n ∈ Finset.range M, h n) + ε / 2 * (∑ n ∈ Finset.range N, g n - ∑ n ∈ Finset.range M, g n) := by
    intro ε hε_pos
    obtain ⟨M, hM⟩ := h_o ε hε_pos
    use M
    intro N hN
    have h_split : ∑ n ∈ Finset.range N, h n = ∑ n ∈ Finset.range M, h n + ∑ n ∈ Finset.Ico M N, h n := by
      rw [ Finset.sum_range_add_sum_Ico _ hN ]
    have h_abs : abs (∑ n ∈ Finset.Ico M N, h n) ≤ (ε / 2) * (∑ n ∈ Finset.Ico M N, g n) := by
      exact le_trans ( Finset.abs_sum_le_sum_abs _ _ ) ( by rw [ Finset.mul_sum _ _ _ ] ; exact Finset.sum_le_sum fun n hn => hM n <| Finset.mem_Ico.mp hn |>.1 )
    have h_abs_sum : abs (∑ n ∈ Finset.range N, h n) ≤ abs (∑ n ∈ Finset.range M, h n) + (ε / 2) * (∑ n ∈ Finset.Ico M N, g n) := by
      exact h_split.symm ▸ abs_le.mpr ⟨ by cases abs_cases ( ∑ n ∈ Finset.range M, h n ) <;> linarith [ abs_le.mp h_abs ], by cases abs_cases ( ∑ n ∈ Finset.range M, h n ) <;> linarith [ abs_le.mp h_abs ] ⟩
    have h_abs_sum_le : abs (∑ n ∈ Finset.range N, h n) ≤ abs (∑ n ∈ Finset.range M, h n) + (ε / 2) * (∑ n ∈ Finset.range N, g n - ∑ n ∈ Finset.range M, g n) := by
      simpa only [ Finset.sum_Ico_eq_sub _ hN ] using h_abs_sum
    exact h_abs_sum_le;
  rw [ Asymptotics.isLittleO_iff ];
  intro ε hε; rcases h_bound ε hε with ⟨ M, HM ⟩ ; filter_upwards [ Filter.eventually_ge_atTop M, hdiv.eventually_gt_atTop ( ( |∑ n ∈ Finset.range M, h n| + ε / 2 * |∑ n ∈ Finset.range M, g n| ) / ( ε / 2 ) ) ] with N hN₁ hN₂;
  rw [ div_lt_iff₀ ] at hN₂ <;> norm_num at *;
  · cases abs_cases ( ∑ n ∈ Finset.range N, g n ) <;> cases abs_cases ( ∑ n ∈ Finset.range M, g n ) <;> nlinarith [ HM N hN₁ ];
  · positivity

/-
**Riesz-mean transfer.**  Partial summation preserves asymptotic
equivalence, provided the reference sequence is eventually positive with
divergent partial sums.
-/
theorem isEquivalent_sum {f g : ℕ → ℝ}
    (hfg : f ~[atTop] g) (hgpos : ∀ᶠ n in atTop, 0 < g n)
    (hdiv : Tendsto (fun N => ∑ n ∈ range N, g n) atTop atTop) :
    (fun N => ∑ n ∈ range N, f n) ~[atTop] (fun N => ∑ n ∈ range N, g n) := by
  -- Apply `sum_isLittleO_of_isLittleO` with h := f - g and g := g.
  have h_sum : (fun N => ∑ n ∈ Finset.range N, (f - g) n) =o[atTop] (fun N => ∑ n ∈ Finset.range N, g n) := by
    apply sum_isLittleO_of_isLittleO;
    · exact hfg;
    · exact hgpos;
    · exact hdiv;
  simp_all +decide [ Asymptotics.IsEquivalent, Finset.sum_sub_distrib ];
  exact h_sum

/-! ## The pure power law -/

/-
The reference power sum `∑_{n<N} n^p` is asymptotically `N^(p+1)/(p+1)`
for real `p > 0`.  This is the `k = 0` (no logarithm) model regime.
-/
theorem power_sum_isEquivalent {p : ℝ} (hp : 0 < p) :
    (fun N => ∑ n ∈ range N, (n : ℝ) ^ p) ~[atTop]
      (fun N => (N : ℝ) ^ (p + 1) / (p + 1)) := by
  refine' Asymptotics.isEquivalent_iff_exists_eq_mul.mpr _;
  refine' ⟨ fun N => ( ∑ n ∈ Finset.range N, ( n : ℝ ) ^ p ) / ( N ^ ( p + 1 ) / ( p + 1 ) ), _, _ ⟩;
  · -- We'll use the fact that $\sum_{n=0}^{N-1} n^p$ is bounded between $\frac{(N-1)^{p+1}}{p+1}$ and $\frac{N^{p+1}}{p+1}$.
    have h_bounds : ∀ N : ℕ, 1 ≤ N → (∑ n ∈ Finset.range N, (n : ℝ) ^ p) ≥ ((N - 1 : ℝ) ^ (p + 1)) / (p + 1) ∧ (∑ n ∈ Finset.range N, (n : ℝ) ^ p) ≤ (N ^ (p + 1)) / (p + 1) := by
      intro N hN
      have h_lower_bound : (∑ n ∈ Finset.range N, (n : ℝ) ^ p) ≥ ∫ x in (0 : ℝ)..((N - 1) : ℝ), x ^ p := by
        -- We'll use the fact that the sum of a non-negative function over a range is greater than or equal to the integral of the function over the same range.
        have h_integral_le_sum : ∀ n : ℕ, ∫ x in (n : ℝ)..((n + 1) : ℝ), x ^ p ≤ (n + 1 : ℝ) ^ p := by
          intro n; rw [ intervalIntegral.integral_of_le ( by linarith ) ] ; exact le_trans ( MeasureTheory.setIntegral_mono_on ( by exact Continuous.integrableOn_Ioc ( by apply_rules [ Continuous.rpow ] <;> continuity ) ) ( by exact Continuous.integrableOn_Ioc ( by continuity ) ) measurableSet_Ioc fun x hx => Real.rpow_le_rpow ( by linarith [ hx.1 ] ) hx.2 ( by linarith ) ) ( by norm_num ) ;
        induction hN <;> simp_all +decide [ Finset.sum_range_succ ];
        · positivity;
        · rename_i k hk ih; specialize h_integral_le_sum ( k - 1 ) ; rcases k with ( _ | k ) <;> norm_num at *;
          convert add_le_add ih h_integral_le_sum using 1 ; rw [ intervalIntegral.integral_add_adjacent_intervals ] <;> exact intervalIntegral.intervalIntegrable_rpow' <| by linarith;
      have h_upper_bound : (∑ n ∈ Finset.range N, (n : ℝ) ^ p) ≤ ∫ x in (0 : ℝ)..((N) : ℝ), x ^ p := by
        have h_upper_bound : ∀ n : ℕ, n < N → (n : ℝ) ^ p ≤ ∫ x in (n : ℝ)..((n + 1) : ℝ), x ^ p := by
          intro n hn; rw [ intervalIntegral.integral_of_le ( by norm_num ) ] ; exact le_trans ( by norm_num ) ( MeasureTheory.setIntegral_mono_on ( by norm_num ) ( by exact ContinuousOn.integrableOn_Icc ( by exact continuousOn_of_forall_continuousAt fun x hx => by exact ContinuousAt.rpow ( continuousAt_id ) continuousAt_const <| Or.inr <| by linarith ) |> fun h => h.mono_set <| Set.Ioc_subset_Icc_self ) measurableSet_Ioc fun x hx => Real.rpow_le_rpow ( by linarith [ hx.1 ] ) hx.1.le <| by linarith ) ;
        convert Finset.sum_le_sum fun i hi => h_upper_bound i ( Finset.mem_range.mp hi ) using 1;
        symm;
        convert intervalIntegral.sum_integral_adjacent_intervals _ <;> norm_num;
        exact fun k hk => intervalIntegral.intervalIntegrable_rpow' ( by linarith );
      rw [ integral_rpow ] at * <;> norm_num at *;
      · simp_all +decide [ ne_of_gt ( add_pos hp zero_lt_one ) ];
      · linarith;
      · linarith;
    -- Using the bounds, we can show that the ratio tends to 1.
    have h_ratio : Filter.Tendsto (fun N : ℕ => ((N - 1 : ℝ) ^ (p + 1)) / (N ^ (p + 1))) Filter.atTop (nhds 1) := by
      -- We can rewrite the expression as $(1 - 1/N)^{p+1}$.
      suffices h_rewrite : Filter.Tendsto (fun N : ℕ => (1 - 1 / (N : ℝ)) ^ (p + 1)) Filter.atTop (nhds 1) by
        refine h_rewrite.congr' ( by filter_upwards [ Filter.eventually_gt_atTop 0 ] with N hN using by rw [ ← Real.div_rpow ( by linarith [ show ( N : ℝ ) ≥ 1 by norm_cast ] ) ( by positivity ), sub_div, div_self ( by positivity ) ] );
      convert Filter.Tendsto.rpow ( tendsto_const_nhds.sub ( tendsto_one_div_atTop_nhds_zero_nat ) ) tendsto_const_nhds _ using 2 <;> norm_num;
    refine' tendsto_of_tendsto_of_tendsto_of_le_of_le' h_ratio tendsto_const_nhds _ _;
    · filter_upwards [ Filter.eventually_ge_atTop 1 ] with N hN using by rw [ le_div_iff₀ ( by positivity ) ] ; have := h_bounds N hN; rw [ div_mul_div_cancel₀ ( by positivity ) ] ; linarith;
    · filter_upwards [ Filter.eventually_ge_atTop 1 ] with N hN using div_le_one_of_le₀ ( h_bounds N hN |>.2 ) ( by positivity );
  · filter_upwards [ Filter.eventually_gt_atTop 0 ] with N hN using by rw [ Pi.mul_apply, div_mul_cancel₀ _ ( by positivity ) ] ;

/-
The partial sums `∑_{n<N} n^p` diverge to `+∞` for `p > 0`.
-/
theorem power_sum_tendsto_atTop {p : ℝ} (hp : 0 < p) :
    Tendsto (fun N => ∑ n ∈ range N, (n : ℝ) ^ p) atTop atTop := by
  -- Since the series $\sum_{n=1}^{\infty} n^p$ diverges, the partial sums $\sum_{n=0}^{N-1} n^p$ also diverge.
  have h_partial_sums : Filter.Tendsto (fun N => ∑ n ∈ Finset.range N, (n : ℝ) ^ p) Filter.atTop Filter.atTop := by
    have h_series_diverges : ¬ Summable (fun n : ℕ => (n : ℝ) ^ p) := by
      exact fun h => absurd ( h.tendsto_atTop_zero ) fun H => not_tendsto_atTop_of_tendsto_nhds H <| tendsto_rpow_atTop hp |> Filter.Tendsto.comp <| tendsto_natCast_atTop_atTop
    exact not_summable_iff_tendsto_nat_atTop_of_nonneg ( fun _ => by positivity ) |>.1 h_series_diverges;
  convert h_partial_sums using 1

/-! ## The pure logarithm law (Stirling's leading term) -/

/-
Stirling's leading term: `∑_{n<N} log n ~ N · log N`.  This is the
`α = 1`, `k = 1` model regime, exhibiting the logarithmic power directly.
-/
theorem log_sum_isEquivalent :
    (fun N => ∑ n ∈ range N, Real.log n) ~[atTop]
      (fun N => (N : ℝ) * Real.log N) := by
  -- Use `Asymptotics.isEquivalent_iff_tendsto_one` (RHS (N:ℝ)*Real.log N is eventually ≠ 0 for N ≥ 2 since log N > 0), reducing to `Tendsto (fun N => S N / ((N:ℝ)*Real.log N)) atTop (𝓝 1)`, proved by squeeze.
  have h_tendsto : Filter.Tendsto (fun N => (∑ n ∈ Finset.range N, Real.log (n : ℝ)) / ((N : ℝ) * Real.log (N : ℝ))) Filter.atTop (nhds 1) := by
    -- We'll use the fact that $\sum_{n=2}^{N} \log n$ is asymptotically equivalent to $N \log N$.
    have h_log_sum : Tendsto (fun N : ℕ => (∑ n ∈ Finset.Icc 2 N, Real.log n) / (N * Real.log N)) Filter.atTop (nhds 1) := by
      -- We'll use the fact that $\sum_{n=2}^N \log n$ is bounded between $N \log N - N$ and $N \log N$.
      have h_bounds : ∀ N : ℕ, 2 ≤ N → (N * Real.log N - N) ≤ (∑ n ∈ Finset.Icc 2 N, Real.log n) ∧ (∑ n ∈ Finset.Icc 2 N, Real.log n) ≤ (N * Real.log N) := by
        intro N hN; induction hN <;> norm_num [ Finset.sum_Ioc_succ_top, (Nat.succ_eq_succ ▸ Finset.Icc_succ_left_eq_Ioc) ] at *;
        · exact ⟨ by linarith [ Real.log_le_sub_one_of_pos zero_lt_two ], by linarith [ Real.log_pos one_lt_two ] ⟩;
        · rw [ Finset.sum_Ioc_succ_top ] <;> norm_num;
          · constructor <;> have := Real.log_le_sub_one_of_pos ( by positivity : 0 < ( ( Nat.cast:ℕ →ℝ ) ‹_› + 1 ) / ( Nat.cast:ℕ →ℝ ) ‹_› ) <;> have := Real.log_le_sub_one_of_pos ( by positivity : 0 < ( ( Nat.cast:ℕ →ℝ ) ‹_› ) / ( ( Nat.cast:ℕ →ℝ ) ‹_› + 1 ) ) <;> rw [ Real.log_div ( by positivity ) ( by positivity ) ] at * <;> norm_num at *; all_goals rw [ div_sub_one, div_add', le_div_iff₀ ] at * <;> nlinarith [ ( by norm_cast : ( 2 :ℝ ) ≤ ‹ℕ› ) ];
          · linarith;
      -- We'll use the fact that $(N \log N - N) / (N \log N) = 1 - 1 / \log N$.
      have h_lower_bound : Filter.Tendsto (fun N : ℕ => (1 - 1 / Real.log N)) Filter.atTop (nhds 1) := by
        simpa using tendsto_const_nhds.sub ( tendsto_inv_atTop_zero.comp ( Real.tendsto_log_atTop.comp tendsto_natCast_atTop_atTop ) );
      refine' tendsto_of_tendsto_of_tendsto_of_le_of_le' h_lower_bound tendsto_const_nhds _ _;
      · filter_upwards [ Filter.eventually_ge_atTop 2 ] with N hN using by rw [ le_div_iff₀ ( mul_pos ( by positivity ) ( Real.log_pos ( by norm_cast ) ) ) ] ; nlinarith [ h_bounds N hN, one_div_mul_cancel ( ne_of_gt ( Real.log_pos ( by norm_cast : ( 1 :ℝ ) < N ) ) ) ] ;
      · filter_upwards [ Filter.eventually_ge_atTop 2 ] with N hN using div_le_one_of_le₀ ( h_bounds N hN |>.2 ) ( mul_nonneg ( Nat.cast_nonneg _ ) ( Real.log_nonneg ( Nat.one_le_cast.mpr ( by linarith ) ) ) );
    rw [ ← Filter.tendsto_add_atTop_iff_nat 1 ];
    -- We'll use the fact that $\sum_{n=0}^{N} \log n = \sum_{n=2}^{N} \log n$ for $N \geq 2$.
    have h_sum_eq : ∀ N : ℕ, 2 ≤ N → (∑ n ∈ Finset.range (N + 1), Real.log n) = (∑ n ∈ Finset.Icc 2 N, Real.log n) := by
      intro N hN; erw [ Finset.sum_Ico_eq_sub _ _ ] <;> norm_num [ Finset.sum_range_succ' ] ; linarith;
    rw [ Filter.tendsto_congr' ( by filter_upwards [ Filter.eventually_ge_atTop 2 ] with N hN using by rw [ h_sum_eq N hN ] ) ];
    convert h_log_sum.mul ( show Filter.Tendsto ( fun N : ℕ => ( N : ℝ ) / ( N + 1 ) ) Filter.atTop ( nhds 1 ) from ?_ ) |> Filter.Tendsto.mul <| show Filter.Tendsto ( fun N : ℕ => Real.log N / Real.log ( N + 1 ) ) Filter.atTop ( nhds 1 ) from ?_ using 2 <;> norm_num;
    · by_cases h : ‹_› = 0 <;> simp +decide [ div_eq_mul_inv, mul_assoc, mul_comm, mul_left_comm, h ];
      by_cases h' : Real.log ‹ℕ› = 0 <;> aesop;
    · simpa using tendsto_natCast_div_add_atTop 1;
    · -- We can use the fact that $\log(N+1) \sim \log N$ as $N \to \infty$.
      have h_log : Filter.Tendsto (fun N : ℕ => Real.log (N + 1) / Real.log N) Filter.atTop (nhds 1) := by
        -- We can use the fact that $\log(N+1) = \log N + \log\left(1 + \frac{1}{N}\right)$.
        suffices h_log_simplified : Filter.Tendsto (fun N : ℕ => (Real.log N + Real.log (1 + 1 / (N : ℝ))) / Real.log N) Filter.atTop (nhds 1) by
          refine h_log_simplified.congr' ( by filter_upwards [ Filter.eventually_gt_atTop 0 ] with N hN using by rw [ ← Real.log_mul ( by positivity ) ( by positivity ), mul_add, mul_one_div_cancel ( by positivity ), mul_one ] );
        ring_nf;
        exact le_trans ( Filter.Tendsto.add ( tendsto_const_nhds.congr' ( by filter_upwards [ Filter.eventually_gt_atTop 1 ] with x hx; rw [ mul_inv_cancel₀ ( ne_of_gt ( Real.log_pos ( mod_cast hx ) ) ) ] ) ) ( Filter.Tendsto.mul ( Filter.Tendsto.log ( tendsto_const_nhds.add ( tendsto_inv_atTop_nhds_zero_nat ) ) ( by norm_num ) ) ( tendsto_inv_atTop_zero.comp ( Real.tendsto_log_atTop.comp tendsto_natCast_atTop_atTop ) ) ) ) ( by norm_num );
      simpa using h_log.inv₀;
  rw [ Asymptotics.isEquivalent_iff_exists_eq_mul ];
  exact ⟨ _, h_tendsto, by filter_upwards [ Filter.eventually_gt_atTop 1 ] with N hN using by rw [ Pi.mul_apply, div_mul_cancel₀ _ ( ne_of_gt <| mul_pos ( Nat.cast_pos.mpr <| pos_of_gt hN ) <| Real.log_pos <| Nat.one_lt_cast.mpr hN ) ] ⟩

/-! ## The mixed power–logarithm law -/

/-
The mixed regime combining a genuine power `α = p+1` with a genuine logarithmic
factor `k = 1`: `∑_{n<N} n^p · log n ~ N^(p+1) · log N / (p+1)` for real `p > 0`.
This is the cleanest instance directly matching the mission's target shape
`C · X^α · (log X)^k` with both `α > 1` and `k ≥ 1` nontrivial.
-/
theorem power_log_sum_isEquivalent {p : ℝ} (hp : 0 < p) :
    (fun N => ∑ n ∈ range N, (n : ℝ) ^ p * Real.log n) ~[atTop]
      (fun N => (N : ℝ) ^ (p + 1) * Real.log N / (p + 1)) := by
  have h_integral : ∀ N : ℕ, 2 ≤ N → ∑ n ∈ Finset.Ico 2 N, (n : ℝ) ^ p * Real.log n ≤ ∫ x in (2 : ℝ)..N, x ^ p * Real.log x ∧ ∑ n ∈ Finset.Ico 2 N, (n : ℝ) ^ p * Real.log n ≥ ∫ x in (2 : ℝ)..N-1, x ^ p * Real.log x := by
    intro N hN
    have h_integral_bounds : ∀ n : ℕ, 2 ≤ n → (n : ℝ) ^ p * Real.log n ≤ ∫ x in (n : ℝ)..(n + 1 : ℝ), x ^ p * Real.log x ∧ (n : ℝ) ^ p * Real.log n ≥ ∫ x in (n - 1 : ℝ)..(n : ℝ), x ^ p * Real.log x := by
      intro n hn
      have h_integral_bounds : ∀ x ∈ Set.Icc (n : ℝ) (n + 1), x ^ p * Real.log x ≥ (n : ℝ) ^ p * Real.log n := by
        exact fun x hx => mul_le_mul ( Real.rpow_le_rpow ( by positivity ) hx.1 ( by positivity ) ) ( Real.log_le_log ( by positivity ) hx.1 ) ( Real.log_nonneg ( by norm_cast; linarith ) ) ( by exact Real.rpow_nonneg ( by linarith [ hx.1 ] ) _ )
      have h_integral_bounds' : ∀ x ∈ Set.Icc (n - 1 : ℝ) n, x ^ p * Real.log x ≤ (n : ℝ) ^ p * Real.log n := by
        intros x hx
        have h_monotone : x ^ p * Real.log x ≤ (n : ℝ) ^ p * Real.log n := by
          have h_monotone_aux : ∀ y z : ℝ, 1 ≤ y → y ≤ z → y ^ p * Real.log y ≤ z ^ p * Real.log z := by
            exact fun y z hy hz => mul_le_mul ( Real.rpow_le_rpow ( by linarith ) hz ( by linarith ) ) ( Real.log_le_log ( by linarith ) hz ) ( Real.log_nonneg ( by linarith ) ) ( by exact Real.rpow_nonneg ( by linarith ) _ )
          exact h_monotone_aux x n ( by linarith [ hx.1, show ( n : ℝ ) ≥ 2 by norm_cast ] ) hx.2;
        exact h_monotone;
      constructor;
      · refine' le_trans _ ( intervalIntegral.integral_mono_on _ _ _ h_integral_bounds ) <;> norm_num;
        apply_rules [ ContinuousOn.intervalIntegrable ];
        exact continuousOn_of_forall_continuousAt fun x hx => ContinuousAt.mul ( ContinuousAt.rpow continuousAt_id continuousAt_const <| Or.inr <| by linarith ) ( Real.continuousAt_log <| by cases Set.mem_uIcc.mp hx <;> linarith [ show ( n : ℝ ) ≥ 2 by norm_cast ] );
      · refine' le_trans ( intervalIntegral.integral_mono_on _ _ _ h_integral_bounds' ) _ <;> norm_num;
        apply_rules [ ContinuousOn.intervalIntegrable ];
        exact continuousOn_of_forall_continuousAt fun x hx => ContinuousAt.mul ( ContinuousAt.rpow continuousAt_id continuousAt_const <| Or.inr <| by linarith ) ( Real.continuousAt_log <| by cases Set.mem_uIcc.mp hx <;> linarith [ show ( n : ℝ ) ≥ 2 by norm_cast ] );
    induction hN <;> norm_num [ Finset.sum_Ico_succ_top ] at *;
    · rw [ intervalIntegral.integral_of_ge ] <;> norm_num;
      exact MeasureTheory.setIntegral_nonneg measurableSet_Ioc fun x hx => mul_nonneg ( Real.rpow_nonneg ( by linarith [ hx.1 ] ) _ ) ( Real.log_nonneg ( by linarith [ hx.1 ] ) );
    · rw [ Finset.sum_Ico_succ_top ( by linarith ) ];
      rename_i k hk ih;
      constructor;
      · convert add_le_add ih.1 ( h_integral_bounds k hk |>.1 ) using 1;
        rw [ intervalIntegral.integral_add_adjacent_intervals ] <;> apply_rules [ ContinuousOn.intervalIntegrable ]; all_goals exact continuousOn_of_forall_continuousAt fun x hx => ContinuousAt.mul ( ContinuousAt.rpow continuousAt_id continuousAt_const <| Or.inr <| by linarith ) ( Real.continuousAt_log <| by cases Set.mem_uIcc.mp hx <;> linarith [ show ( k : ℝ ) ≥ 2 by norm_cast ] );
      · convert add_le_add ih.2 ( h_integral_bounds k hk |>.2 ) using 1;
        rw [ intervalIntegral.integral_add_adjacent_intervals ] <;> apply_rules [ ContinuousOn.intervalIntegrable ]; all_goals exact continuousOn_of_forall_continuousAt fun x hx => ContinuousAt.mul ( ContinuousAt.rpow continuousAt_id continuousAt_const <| Or.inr <| by linarith ) ( Real.continuousAt_log <| by cases Set.mem_uIcc.mp hx <;> linarith [ show ( k : ℝ ) ≥ 2 by norm_cast ] );
  -- Integrate by parts to find the antiderivative of $x^p \log x$.
  have h_antideriv : ∀ a b : ℝ, 0 < a → a < b → ∫ x in a..b, x ^ p * Real.log x = (b ^ (p + 1) * Real.log b) / (p + 1) - (b ^ (p + 1)) / ((p + 1) ^ 2) - ((a ^ (p + 1) * Real.log a) / (p + 1) - (a ^ (p + 1)) / ((p + 1) ^ 2)) := by
    intros a b ha hb; rw [ intervalIntegral.integral_eq_sub_of_hasDerivAt ];
    · intro x hx; convert HasDerivAt.sub ( HasDerivAt.div_const ( HasDerivAt.mul ( Real.hasDerivAt_rpow_const ?_ ) ( Real.hasDerivAt_log ?_ ) ) _ ) ( HasDerivAt.div_const ( Real.hasDerivAt_rpow_const ?_ ) _ ) using 1 <;> ring <;> norm_num [ show x ≠ 0 by cases Set.mem_uIcc.mp hx <;> linarith ] ;
      field_simp;
      rw [ show x ^ ( 1 + p ) = x ^ p * x by rw [ Real.rpow_add ( by cases Set.mem_uIcc.mp hx <;> linarith ), Real.rpow_one ] ; ring ] ; rw [ eq_comm ] ; rw [ add_div', div_eq_iff ] <;> ring <;> cases Set.mem_uIcc.mp hx <;> linarith;
    · exact ContinuousOn.intervalIntegrable ( by exact continuousOn_of_forall_continuousAt fun x hx => ContinuousAt.mul ( ContinuousAt.rpow continuousAt_id continuousAt_const <| Or.inl <| by linarith [ Set.mem_Icc.mp <| by simpa [ hb.le ] using hx ] ) <| Real.continuousAt_log <| by linarith [ Set.mem_Icc.mp <| by simpa [ hb.le ] using hx ] );
  -- Divide the integral bounds by the reference $B(N) = N^{p+1} \log N / (p+1)$.
  have h_divide : Filter.Tendsto (fun N : ℕ => (∫ x in (2 : ℝ)..N, x ^ p * Real.log x) / ((N : ℝ) ^ (p + 1) * Real.log N / (p + 1))) Filter.atTop (nhds 1) ∧ Filter.Tendsto (fun N : ℕ => (∫ x in (2 : ℝ)..(N - 1), x ^ p * Real.log x) / ((N : ℝ) ^ (p + 1) * Real.log N / (p + 1))) Filter.atTop (nhds 1) := by
    constructor;
    · -- Apply the antiderivative result to rewrite the integral.
      suffices h_suff : Filter.Tendsto (fun N : ℕ => ((N : ℝ) ^ (p + 1) * Real.log N / (p + 1) - (N : ℝ) ^ (p + 1) / ((p + 1) ^ 2) - (2 ^ (p + 1) * Real.log 2 / (p + 1) - 2 ^ (p + 1) / ((p + 1) ^ 2))) / ((N : ℝ) ^ (p + 1) * Real.log N / (p + 1))) Filter.atTop (nhds 1) by
        refine h_suff.congr' ( by filter_upwards [ Filter.eventually_gt_atTop 2 ] with N hN using by rw [ h_antideriv 2 N ( by norm_num ) ( by norm_cast ) ] );
      -- Simplify the expression inside the limit.
      suffices h_simplify : Filter.Tendsto (fun N : ℕ => 1 - 1 / ((p + 1) * Real.log N) - ((2 ^ (p + 1) * Real.log 2 / (p + 1) - 2 ^ (p + 1) / (p + 1) ^ 2) / ((N : ℝ) ^ (p + 1) * Real.log N / (p + 1)))) Filter.atTop (nhds 1) by
        refine h_simplify.congr' ?_;
        filter_upwards [ Filter.eventually_gt_atTop 1 ] with N hN;
        field_simp;
        ring;
        simpa [ ne_of_gt ( Real.log_pos ( Nat.one_lt_cast.mpr hN ) ) ] using by ring;
      norm_num +zetaDelta at *;
      exact le_trans ( Filter.Tendsto.sub ( tendsto_const_nhds.sub ( Filter.Tendsto.mul ( tendsto_inv_atTop_zero.comp ( Real.tendsto_log_atTop.comp tendsto_natCast_atTop_atTop ) ) tendsto_const_nhds ) ) ( tendsto_const_nhds.div_atTop <| Filter.Tendsto.atTop_div_const ( by positivity ) <| Filter.Tendsto.atTop_mul_atTop₀ ( tendsto_rpow_atTop ( by positivity ) |> Filter.Tendsto.comp <| tendsto_natCast_atTop_atTop ) <| Real.tendsto_log_atTop.comp tendsto_natCast_atTop_atTop ) ) <| by norm_num;
    · -- Use the fact that $(N-1)^{p+1} \sim N^{p+1}$ and $\log(N-1) \sim \log N$ as $N \to \infty$.
      have h_sim : Filter.Tendsto (fun N : ℕ => ((N - 1 : ℝ) ^ (p + 1) * Real.log (N - 1)) / ((N : ℝ) ^ (p + 1) * Real.log N)) Filter.atTop (nhds 1) ∧ Filter.Tendsto (fun N : ℕ => ((N - 1 : ℝ) ^ (p + 1)) / ((N : ℝ) ^ (p + 1))) Filter.atTop (nhds 1) := by
        constructor;
        · -- We can use the fact that $(N-1)^{p+1} / N^{p+1} \to 1$ and $\log(N-1) / \log N \to 1$ as $N \to \infty$.
          have h_lim : Filter.Tendsto (fun N : ℕ => ((N - 1 : ℝ) / N) ^ (p + 1)) Filter.atTop (nhds 1) ∧ Filter.Tendsto (fun N : ℕ => Real.log (N - 1) / Real.log N) Filter.atTop (nhds 1) := by
            constructor;
            · norm_num [ sub_div ];
              exact le_trans ( Filter.Tendsto.rpow ( Filter.Tendsto.sub ( tendsto_const_nhds.congr' ( by filter_upwards [ Filter.eventually_ne_atTop 0 ] with N hN; aesop ) ) ( tendsto_inv_atTop_nhds_zero_nat ) ) tendsto_const_nhds ( Or.inr <| by positivity ) ) ( by norm_num );
            · -- We can use the fact that $\log(N-1) = \log N + \log(1 - 1/N)$ and apply the properties of logarithms.
              have h_log : Filter.Tendsto (fun N : ℕ => (Real.log N + Real.log (1 - 1 / (N : ℝ))) / Real.log N) Filter.atTop (nhds 1) := by
                ring_nf;
                exact le_trans ( Filter.Tendsto.add ( tendsto_const_nhds.congr' ( by filter_upwards [ Filter.eventually_gt_atTop 1 ] with x hx; rw [ mul_inv_cancel₀ ( ne_of_gt ( Real.log_pos ( mod_cast hx ) ) ) ] ) ) ( Filter.Tendsto.mul ( Filter.Tendsto.log ( tendsto_const_nhds.sub ( tendsto_inv_atTop_zero.comp tendsto_natCast_atTop_atTop ) ) ( by norm_num ) ) ( tendsto_inv_atTop_zero.comp ( Real.tendsto_log_atTop.comp tendsto_natCast_atTop_atTop ) ) ) ) ( by norm_num );
              refine h_log.congr' ( by filter_upwards [ Filter.eventually_gt_atTop 1 ] with N hN using by rw [ one_sub_div ( by positivity ) ] ; rw [ Real.log_div ] <;> norm_num <;> linarith [ show ( N : ℝ ) ≥ 2 by norm_cast ] );
          convert h_lim.1.mul h_lim.2 using 2 <;> norm_num;
          by_cases h : ( ‹_› : ℕ ) = 0 <;> simp +decide [ h, mul_div_mul_comm ];
          exact Or.inl ( by rw [ Real.div_rpow ( sub_nonneg_of_le ( mod_cast Nat.one_le_iff_ne_zero.mpr h ) ) ( Nat.cast_nonneg _ ) ] );
        · -- We can rewrite $(N-1)^{p+1} / N^{p+1}$ as $(1 - 1/N)^{p+1}$.
          suffices h_rewrite : Filter.Tendsto (fun N : ℕ => (1 - 1 / (N : ℝ)) ^ (p + 1)) Filter.atTop (nhds 1) by
            refine h_rewrite.congr' ( by filter_upwards [ Filter.eventually_gt_atTop 0 ] with N hN using by rw [ ← Real.div_rpow ( by linarith [ show ( N : ℝ ) ≥ 1 by norm_cast ] ) ( by positivity ), sub_div, div_self ( by positivity ) ] );
          convert Filter.Tendsto.rpow ( tendsto_const_nhds.sub ( tendsto_one_div_atTop_nhds_zero_nat ) ) tendsto_const_nhds _ using 2 <;> norm_num;
      -- Apply the fact that the integral of $x^p \log x$ over $[2, N-1]$ is asymptotically equivalent to $N^{p+1} \log N / (p+1)$.
      have h_integral_equiv : Filter.Tendsto (fun N : ℕ => ((N - 1 : ℝ) ^ (p + 1) * Real.log (N - 1) / (p + 1) - (N - 1 : ℝ) ^ (p + 1) / ((p + 1) ^ 2) - (2 ^ (p + 1) * Real.log 2 / (p + 1) - 2 ^ (p + 1) / ((p + 1) ^ 2))) / ((N : ℝ) ^ (p + 1) * Real.log N / (p + 1))) Filter.atTop (nhds 1) := by
        have h_integral_equiv : Filter.Tendsto (fun N : ℕ => ((N - 1 : ℝ) ^ (p + 1) * Real.log (N - 1) / (p + 1)) / ((N : ℝ) ^ (p + 1) * Real.log N / (p + 1))) Filter.atTop (nhds 1) ∧ Filter.Tendsto (fun N : ℕ => ((N - 1 : ℝ) ^ (p + 1) / ((p + 1) ^ 2)) / ((N : ℝ) ^ (p + 1) * Real.log N / (p + 1))) Filter.atTop (nhds 0) ∧ Filter.Tendsto (fun N : ℕ => ((2 ^ (p + 1) * Real.log 2 / (p + 1) - 2 ^ (p + 1) / ((p + 1) ^ 2))) / ((N : ℝ) ^ (p + 1) * Real.log N / (p + 1))) Filter.atTop (nhds 0) := by
          refine' ⟨ _, _, _ ⟩;
          · convert h_sim.1 using 2 ; ring;
            norm_num [ show 1 + p ≠ 0 by linarith ];
          · convert h_sim.2.div_atTop ( show Filter.Tendsto ( fun N : ℕ => Real.log N ) Filter.atTop ( Filter.atTop ) from Real.tendsto_log_atTop.comp tendsto_natCast_atTop_atTop ) |> Filter.Tendsto.div_const <| ( p + 1 ) using 2 ; ring;
            · grind;
            · norm_num;
          · refine' tendsto_const_nhds.div_atTop _;
            exact Filter.Tendsto.atTop_div_const ( by positivity ) ( Filter.Tendsto.atTop_mul_atTop₀ ( tendsto_rpow_atTop ( by positivity ) |> Filter.Tendsto.comp <| tendsto_natCast_atTop_atTop ) <| Real.tendsto_log_atTop.comp tendsto_natCast_atTop_atTop );
        convert h_integral_equiv.1.sub ( h_integral_equiv.2.1.add h_integral_equiv.2.2 ) using 2 <;> ring;
      refine h_integral_equiv.congr' ( by filter_upwards [ Filter.eventually_gt_atTop 3 ] with N hN using by rw [ h_antideriv 2 ( N - 1 ) ( by norm_num ) ( by linarith [ show ( N : ℝ ) ≥ 4 by norm_cast ] ) ] );
  -- By the squeeze theorem, the ratio of the sum to $B(N)$ tends to 1.
  have h_squeeze : Filter.Tendsto (fun N : ℕ => (∑ n ∈ Finset.Ico 2 N, (n : ℝ) ^ p * Real.log n) / ((N : ℝ) ^ (p + 1) * Real.log N / (p + 1))) Filter.atTop (nhds 1) := by
    refine' tendsto_of_tendsto_of_tendsto_of_le_of_le' h_divide.2 h_divide.1 _ _;
    · filter_upwards [ Filter.eventually_ge_atTop 2 ] with N hN using div_le_div_of_nonneg_right ( h_integral N hN |>.2 ) ( div_nonneg ( mul_nonneg ( Real.rpow_nonneg ( Nat.cast_nonneg _ ) _ ) ( Real.log_nonneg ( Nat.one_le_cast.mpr ( by linarith ) ) ) ) ( by positivity ) );
    · filter_upwards [ Filter.eventually_ge_atTop 2 ] with N hN using div_le_div_of_nonneg_right ( h_integral N hN |>.1 ) ( div_nonneg ( mul_nonneg ( Real.rpow_nonneg ( Nat.cast_nonneg _ ) _ ) ( Real.log_nonneg ( Nat.one_le_cast.mpr ( by linarith ) ) ) ) ( by positivity ) );
  rw [ Asymptotics.isEquivalent_iff_exists_eq_mul ];
  refine' ⟨ _, h_squeeze, _ ⟩;
  filter_upwards [ Filter.eventually_gt_atTop 2 ] with N hN;
  rw [ Pi.mul_apply, div_mul_cancel₀ _ ( ne_of_gt <| div_pos ( mul_pos ( Real.rpow_pos_of_pos ( Nat.cast_pos.mpr <| by linarith ) _ ) <| Real.log_pos <| Nat.one_lt_cast.mpr <| by linarith ) <| by positivity ), Finset.sum_Ico_eq_sub _ <| by linarith ] ; norm_num [ Finset.sum_range_succ' ]

/-! ## A second-order Riesz mean -/

/-
Feeding the power law through the summation engine yields a genuine
second-order (iterated) Riesz-mean asymptotic:
`∑_{n<N} ∑_{m<n} m^p ~ N^(p+2) / ((p+1)(p+2))`.
-/
theorem iterated_power_sum_isEquivalent {p : ℝ} (hp : 0 < p) :
    (fun N => ∑ n ∈ range N, ∑ m ∈ range n, (m : ℝ) ^ p) ~[atTop]
      (fun N => (N : ℝ) ^ (p + 2) / ((p + 1) * (p + 2))) := by
  -- Apply the power_sum_isEquivalent lemma to the inner sum.
  have h_inner : (fun N => ∑ n ∈ range N, ∑ m ∈ Finset.range n, (m : ℝ) ^ p) ~[atTop] (fun N => ∑ n ∈ range N, (n : ℝ) ^ (p + 1) / (p + 1)) := by
    convert isEquivalent_sum _ _ _ using 1;
    · convert power_sum_isEquivalent hp using 1;
    · filter_upwards [ Filter.eventually_gt_atTop 0 ] with n hn using by positivity;
    · simpa only [ ← Finset.sum_div ] using power_sum_tendsto_atTop ( by positivity ) |> Filter.Tendsto.atTop_div_const ( by positivity );
  -- Apply the power_sum_isEquivalent lemma to the outer sum.
  have h_outer : (fun N => ∑ n ∈ Finset.range N, (n : ℝ) ^ (p + 1) / (p + 1)) ~[atTop] (fun N => (N : ℝ) ^ (p + 2) / ((p + 1) * (p + 2))) := by
    have h_outer : (fun N => ∑ n ∈ Finset.range N, (n : ℝ) ^ (p + 1)) ~[atTop] (fun N => (N : ℝ) ^ (p + 2) / (p + 2)) := by
      convert power_sum_isEquivalent ( show 0 < p + 1 by linarith ) using 2 ; ring;
    rw [ Asymptotics.IsEquivalent ] at *;
    simp_all +decide [ ← Finset.sum_div _ _ _ ];
    rw [ Asymptotics.isLittleO_iff_tendsto' ] at *;
    · convert h_outer using 2 ; norm_num ; ring;
      grind;
    · filter_upwards [ Filter.eventually_gt_atTop 1 ] with N hN hN' using absurd hN' <| ne_of_gt <| div_pos ( lt_of_lt_of_le ( by positivity ) <| Finset.single_le_sum ( fun a _ => by positivity ) <| Finset.mem_range.mpr hN ) <| by positivity;
    · filter_upwards [ Filter.eventually_gt_atTop 0 ] with N hN using fun h => absurd h <| by positivity;
    · filter_upwards [ Filter.eventually_gt_atTop 0 ] with N hN using fun h => absurd h <| by positivity;
  exact h_inner.trans h_outer

end WeightedRieszMean