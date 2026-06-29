import Mathlib

/-!
# A complete pipeline: series → integral representation of `γ` with convergence rates

This file develops the Euler–Mascheroni constant `γ = Real.eulerMascheroniConstant`
through the elementary term
```
g k = 1/k − log(1 + 1/k)   (k ≥ 1).
```

We prove, in order:

* `gk_pos`            : each term `g k` is strictly positive (`k ≥ 1`);
* `gterm_partial`     : the telescoping partial-sum identity
                        `∑_{k=1}^n g k = (∑_{k=1}^n 1/k) − log(n+1)`;
* `hasSum_g`          : `HasSum g γ` (the series sums to `γ`);
* `gk_integral`       : the integral form `g k = ∫_k^{k+1} (1/k − 1/y) dy`;
* `gamma_integral`    : the improper integral representation
                        `γ = ∫_1^∞ (1/⌊x⌋ − 1/x) dx`, as the limit of `∫_1^N`;
* `gk_bound`          : the sharp upper bound `g k < 1/(2 k²)` (the key non-trivial step);
* `gamma_approx_error`: the convergence rate `γ − ∑_{k=1}^n g k < 1/(2 n)`.

The development is self-contained on top of Mathlib's `eulerMascheroniSeq`/
`eulerMascheroniConstant`.
-/

open Filter Topology Real intervalIntegral

namespace EMLPipeline

/-! ## The auxiliary `0`-indexed term and its basic theory (reused machinery) -/

/-- The `0`-indexed term `gterm k = 1/(k+1) − (log(k+2) − log(k+1))`. -/
noncomputable def gterm (k : ℕ) : ℝ :=
  (1 : ℝ) / (k + 1) - (Real.log (k + 2) - Real.log (k + 1))

theorem gterm_pos (k : ℕ) : 0 < gterm k := by
  unfold gterm
  rw [← Real.log_div (by positivity) (by positivity)]
  have hne : (k + 2 : ℝ) / (k + 1) ≠ 1 := by
    rw [ne_eq, div_eq_one_iff_eq (by positivity)]; intro h; linarith
  have hlog := Real.log_lt_sub_one_of_pos (x := (k + 2 : ℝ) / (k + 1)) (by positivity) hne
  have heq : (k + 2 : ℝ) / (k + 1) - 1 = 1 / (k + 1) := by field_simp; ring
  rw [heq] at hlog; linarith

theorem gterm_partial_range (n : ℕ) :
    ∑ k ∈ Finset.range n, gterm k = Real.eulerMascheroniSeq n := by
  simp only [gterm, Real.eulerMascheroniSeq]
  induction n with
  | zero => simp
  | succ m ih =>
    rw [Finset.sum_range_succ, ih, harmonic_succ]
    push_cast
    rw [show ((m : ℝ) + 1 + 1) = (m : ℝ) + 2 by ring]
    ring

theorem hasSum_gterm : HasSum gterm Real.eulerMascheroniConstant := by
  have hsummable : Summable gterm := by
    apply summable_of_sum_range_le (c := Real.eulerMascheroniConstant)
    · intro n; exact (gterm_pos n).le
    · intro n
      rw [gterm_partial_range n]
      exact (Real.eulerMascheroniSeq_lt_eulerMascheroniConstant n).le
  have h1 := hsummable.hasSum
  have h2 := h1.tendsto_sum_nat
  have h3 : Tendsto (fun n => ∑ k ∈ Finset.range n, gterm k) atTop
      (𝓝 Real.eulerMascheroniConstant) := by
    simp only [gterm_partial_range]; exact Real.tendsto_eulerMascheroniSeq
  have huniq := tendsto_nhds_unique h2 h3
  rw [← huniq]; exact h1

theorem gterm_eq_integral (k : ℕ) :
    gterm k = ∫ x in ((k : ℝ) + 1)..((k : ℝ) + 2), ((1 : ℝ) / (k + 1) - 1 / x) := by
  have hle : ((k : ℝ) + 1) ≤ ((k : ℝ) + 2) := by linarith
  have hsub : (0 : ℝ) ∉ Set.uIcc ((k : ℝ) + 1) ((k : ℝ) + 2) := by
    rw [Set.uIcc_of_le hle]
    simp only [Set.mem_Icc, not_and, not_le]; intro h; linarith
  have hII : IntervalIntegrable (fun x => 1 / x) MeasureTheory.volume
      ((k : ℝ) + 1) ((k : ℝ) + 2) := by
    apply intervalIntegrable_one_div (f := fun x => x)
    · intro x hx
      rw [Set.uIcc_of_le hle] at hx
      simp only [Set.mem_Icc] at hx
      intro h; rw [h] at hx; linarith [hx.1]
    · exact continuousOn_id
  rw [intervalIntegral.integral_sub intervalIntegral.intervalIntegrable_const hII,
    integral_one_div hsub]
  simp only [intervalIntegral.integral_const, smul_eq_mul]
  rw [Real.log_div (by positivity) (by positivity)]
  unfold gterm; ring

/-! ## The `1`-indexed term `g` of the task -/

/-- The term `g k = 1/k − log(1 + 1/k)`.  Note `g 0 = 0` since `1/0 = 0` in `ℝ`. -/
noncomputable def g (k : ℕ) : ℝ := 1 / (k : ℝ) - Real.log (1 + 1 / (k : ℝ))

@[simp] theorem g_zero : g 0 = 0 := by simp [g]

/-- The two indexings agree: `g (k+1) = gterm k`. -/
theorem g_succ (k : ℕ) : g (k + 1) = gterm k := by
  simp only [g, gterm, Nat.cast_add, Nat.cast_one]
  rw [show (1 : ℝ) + 1 / ((k : ℝ) + 1) = ((k : ℝ) + 2) / ((k : ℝ) + 1) by
        field_simp; ring,
    Real.log_div (by positivity) (by positivity)]

/-- **(1)** Each term is strictly positive for `k ≥ 1`. -/
theorem gk_pos : ∀ k : ℕ, 1 ≤ k → 0 < g k := by
  intro k hk
  obtain ⟨m, rfl⟩ := Nat.exists_eq_add_of_lt (Nat.lt_of_lt_of_le Nat.zero_lt_one hk)
  simpa [g_succ] using gterm_pos m

/-
**(2)** Telescoping partial-sum identity.
-/
theorem gterm_partial (n : ℕ) :
    ∑ k ∈ Finset.Icc 1 n, g k
      = (∑ k ∈ Finset.Icc 1 n, (1 : ℝ) / (k : ℝ)) - Real.log (n + 1) := by
  erw [ Finset.sum_Ico_eq_sub _ _ ] <;> norm_num [ * ];
  erw [ Finset.sum_Ico_eq_sub _ _ ] <;> norm_num [ Finset.sum_range_succ', g_succ ];
  convert gterm_partial_range n using 1;
  unfold eulerMascheroniSeq; norm_num [ Finset.sum_range_succ' ] ;
  norm_num [ harmonic ]

/-
**(3)** The series `g` sums to `γ`.
-/
theorem hasSum_g : HasSum g Real.eulerMascheroniConstant := by
  -- Rewrite `g` as a shifted `gterm` and use `g_zero` to show the shifted `gterm` converges to `γ`.
  have h_shift_g : HasSum (fun n => g (n + 1)) Real.eulerMascheroniConstant := by
    -- gk_succ and hasSum_gterm give HasSum gterm γ
    have h1: HasSum gterm Real.eulerMascheroniConstant := by
      convert hasSum_gterm using 1
    -- gk_succ shows g (n+1) = gterm n
    have h2: (fun n => g (n + 1)) = gterm := by funext n; rw [g_succ n]
    -- So shiftHasSumKSucc: (fun n => g (n+1)) is gterm, has sum γ
    rw [h2] at *
    exact h1;
  rw [ ← hasSum_nat_add_iff' 1 ] ; aesop;

theorem summable_g : Summable g := hasSum_g.summable

/-
**(4)** Integral form of each term.
-/
theorem gk_integral : ∀ k : ℕ, 1 ≤ k →
    g k = ∫ y in (k : ℝ)..((k : ℝ) + 1), (1 / (k : ℝ) - 1 / y) := by
  intro k hk;
  obtain ⟨ m, rfl ⟩ := Nat.exists_eq_succ_of_ne_zero ( ne_of_gt hk );
  convert gterm_eq_integral m using 1;
  · exact g_succ m;
  · norm_num [ add_assoc ]

/-
The unit-interval integral of `1/⌊x⌋ − 1/x` over `[k, k+1]` equals `g k` (`k ≥ 1`).
-/
theorem floor_integral_unit : ∀ k : ℕ, 1 ≤ k →
    (∫ x in (k : ℝ)..((k : ℝ) + 1), (1 / (⌊x⌋ : ℝ) - 1 / x)) = g k := by
  intro k hk; rw [ gk_integral k hk ] ; norm_num [ intervalIntegral.integral_of_le ] ;
  rw [ MeasureTheory.integral_Ioc_eq_integral_Ioo, MeasureTheory.integral_Ioc_eq_integral_Ioo ];
  exact MeasureTheory.setIntegral_congr_fun measurableSet_Ioo fun x hx => by norm_num [ show ⌊x⌋ = k from Int.floor_eq_iff.mpr ⟨ hx.1.le, hx.2 ⟩ ] ;

/-
The truncated integral up to `N` equals the partial sum / lower approximant.
-/
theorem floor_integral_partial (N : ℕ) (hN : 1 ≤ N) :
    (∫ x in (1 : ℝ)..(N : ℝ), (1 / (⌊x⌋ : ℝ) - 1 / x))
      = Real.eulerMascheroniSeq (N - 1) := by
  -- Apply the interval integral sum property.
  have h_sum_integrals : ∫ x in (1 : ℝ)..N, (1 / ⌊x⌋ - 1 / x) = ∑ k ∈ Finset.range (N - 1), ∫ x in (k + 1 : ℝ)..((k + 1) + 1 : ℝ), (1 / ⌊x⌋ - 1 / x) := by
    symm;
    convert intervalIntegral.sum_integral_adjacent_intervals _ using 3;
    · norm_num;
    · norm_num;
    · rw [ Nat.cast_pred hN ] ; ring;
    · intro k hk; rw [ intervalIntegrable_iff_integrableOn_Ioo_of_le ] <;> norm_num;
      refine' MeasureTheory.Integrable.sub _ _;
      · rw [ MeasureTheory.integrable_congr ];
        exacts [ MeasureTheory.integrable_const ( ( k + 1 : ℝ ) ⁻¹ ), Filter.eventuallyEq_of_mem ( MeasureTheory.ae_restrict_mem measurableSet_Ioo ) fun x hx => by norm_num [ show ⌊x⌋ = k + 1 by exact Int.floor_eq_iff.mpr ⟨ by norm_num; linarith [ hx.1 ], by norm_num; linarith [ hx.2 ] ⟩ ] ];
      · exact ContinuousOn.integrableOn_Icc ( by exact continuousOn_of_forall_continuousAt fun x hx => ContinuousAt.inv₀ continuousAt_id ( by linarith [ hx.1 ] ) ) |> fun h => h.mono_set ( Set.Ioo_subset_Icc_self );
  -- Apply the interval integral sum property to each term in the sum.
  have h_integral_term : ∀ k : ℕ, ∫ x in (k + 1 : ℝ)..((k + 1) + 1 : ℝ), (1 / ⌊x⌋ - 1 / x) = g (k + 1) := by
    intro k; convert floor_integral_unit ( k + 1 ) ( by linarith ) using 1 ; norm_num [ add_assoc ] ;
  simp_all +decide;
  convert gterm_partial_range ( N - 1 ) using 1;
  exact Finset.sum_congr rfl fun _ _ => g_succ _ ▸ rfl

/-
**(5)** Integral representation of `γ`:
`γ = ∫_1^∞ (1/⌊x⌋ − 1/x) dx`, stated as the limit of the truncated integrals.
-/
theorem gamma_integral :
    Tendsto (fun N : ℕ => ∫ x in (1 : ℝ)..(N : ℝ), (1 / (⌊x⌋ : ℝ) - 1 / x))
      atTop (𝓝 Real.eulerMascheroniConstant) := by
  convert Tendsto.congr' _ ( Real.tendsto_eulerMascheroniSeq.comp ( Filter.tendsto_sub_atTop_nat 1 ) ) using 1;
  filter_upwards [ Filter.eventually_ge_atTop 1 ] with N hN using Eq.symm ( floor_integral_partial N hN )

/-! ## The sharp bound and convergence rate -/

/-
Quadratic lower bound for the logarithm: `x − x²/2 < log(1 + x)` for `x > 0`.
-/
theorem log_one_add_gt (x : ℝ) (hx : 0 < x) :
    x - x ^ 2 / 2 < Real.log (1 + x) := by
  -- Define the function $f(x) = \log(1 + x) - (x - x^2 / 2)$.
  set f : ℝ → ℝ := fun x => Real.log (1 + x) - (x - x^2 / 2);
  -- We'll use the fact that $f(x)$ is differentiable in the interval $[0, x]$ and that the derivative is positive on $(0, x)$.
  have h_deriv_pos : ∀ y ∈ Set.Ioo 0 x, 0 < deriv f y := by
    simp +zetaDelta at *;
    intro y hy₁ hy₂; norm_num [ add_comm, show y + 1 ≠ 0 by linarith ] ; ring_nf; nlinarith [ inv_mul_cancel₀ ( by linarith : ( 1 + y ) ≠ 0 ) ] ;
  -- Apply the mean value theorem to $f$ on the interval $[0, x]$.
  obtain ⟨c, hc⟩ : ∃ c ∈ Set.Ioo 0 x, deriv f c = (f x - f 0) / (x - 0) := by
    apply_rules [ exists_deriv_eq_slope ];
    · exact continuousOn_of_forall_continuousAt fun y hy => by exact ContinuousAt.sub ( ContinuousAt.log ( continuousAt_const.add continuousAt_id ) ( by linarith [ hy.1 ] ) ) ( ContinuousAt.sub continuousAt_id ( ContinuousAt.div_const ( continuousAt_id.pow 2 ) _ ) ) ;
    · exact fun y hy => DifferentiableAt.differentiableWithinAt ( by exact DifferentiableAt.sub ( DifferentiableAt.log ( differentiableAt_id.const_add _ ) ( by linarith [ hy.1 ] ) ) ( by norm_num ) );
  have := h_deriv_pos c hc.1; rw [ hc.2, lt_div_iff₀ ] at this <;> aesop;

/-
**(6)** The sharp upper bound `g k < 1/(2 k²)` for `k ≥ 1`.
-/
theorem gk_bound : ∀ k : ℕ, 1 ≤ k → g k < 1 / (2 * (k : ℝ) ^ 2) := by
  intro k hk; rw [ g ] ; exact by have := log_one_add_gt ( 1 / ( k : ℝ ) ) ( by positivity ) ; ring_nf at *; nlinarith [ mul_inv_cancel₀ ( by positivity : ( k : ℝ ) ≠ 0 ) ] ;

/-
Telescoping sum `∑_i (1/(i+n) − 1/(i+n+1)) = 1/n`.
-/
theorem telescope_hasSum (n : ℕ) (hn : 1 ≤ n) :
    HasSum (fun i : ℕ => (1 : ℝ) / ((i : ℝ) + n) - 1 / ((i : ℝ) + n + 1)) (1 / (n : ℝ)) := by
  -- The partial sums form a telescoping series that converges to 1/n.
  have h_telescope : ∀ m : ℕ, ∑ i ∈ Finset.range m, ((1 / (i + n : ℝ)) - (1 / (i + n + 1 : ℝ))) = 1 / (n : ℝ) - 1 / (m + n : ℝ) := by
    exact fun m => by convert Finset.sum_range_sub' _ _ using 3 <;> push_cast <;> ring;
  convert Summable.hasSum _ using 1;
  · refine' HasSum.tsum_eq _ |> Eq.symm;
    rw [ hasSum_iff_tendsto_nat_of_nonneg ];
    · simpa only [ h_telescope ] using le_trans ( tendsto_const_nhds.sub <| tendsto_const_nhds.div_atTop <| Filter.tendsto_atTop_add_const_right _ _ tendsto_natCast_atTop_atTop ) <| by norm_num;
    · exact fun i => sub_nonneg_of_le <| one_div_le_one_div_of_le ( by positivity ) <| by linarith;
  · field_simp;
    exact Summable.of_nonneg_of_le ( fun i => div_nonneg ( by linarith ) ( by positivity ) ) ( fun i => by rw [ div_le_div_iff₀ ] <;> ring <;> norm_cast <;> ring <;> nlinarith ) ( summable_nat_add_iff n |>.2 <| Real.summable_one_div_nat_pow.2 one_lt_two )

/-
The tail of the quadratic comparison series is bounded by `1/(2n)`.
-/
theorem sq_tail_bound (n : ℕ) (hn : 1 ≤ n) :
    ∑' i : ℕ, (1 : ℝ) / (2 * ((i : ℝ) + n + 1) ^ 2) ≤ 1 / (2 * (n : ℝ)) := by
  convert Summable.tsum_le_tsum _ _ _ using 1;
  convert ( HasSum.tsum_eq <| telescope_hasSum n hn |> HasSum.mul_left ( 1 / 2 : ℝ ) ) |> Eq.symm using 1 ; ring;
  all_goals try infer_instance;
  · field_simp;
    lia;
  · exact Summable.of_nonneg_of_le ( fun _ => by positivity ) ( fun i => by rw [ div_le_div_iff₀ ] <;> norm_cast <;> ring <;> nlinarith ) ( summable_nat_add_iff 1 |>.2 <| Real.summable_one_div_nat_pow.2 one_lt_two );
  · field_simp;
    ring_nf;
    exact Summable.of_nonneg_of_le ( fun i => by positivity ) ( fun i => by rw [ inv_le_comm₀ ] <;> norm_num <;> ring <;> nlinarith [ show ( n : ℝ ) ≥ 1 by norm_cast ] ) ( summable_nat_add_iff 1 |>.2 <| Real.summable_one_div_nat_pow.2 one_lt_two )

/-
The tail of the `g`-series equals `γ` minus the partial sum.
-/
theorem gamma_sub_partial (n : ℕ) :
    Real.eulerMascheroniConstant - (∑ k ∈ Finset.Icc 1 n, g k)
      = ∑' i : ℕ, g (i + (n + 1)) := by
  rw [ ← hasSum_g.tsum_eq, eq_comm ];
  erw [ eq_comm, ← Summable.sum_add_tsum_nat_add ( n + 1 ) ];
  · erw [ Finset.sum_Ico_eq_sub _ _ ] <;> norm_num [ Finset.sum_range_succ' ];
  · convert hasSum_g.summable

/-
**(7)** Convergence rate: `γ − ∑_{k=1}^n g k < 1/(2n)` for `n ≥ 1`.
-/
theorem gamma_approx_error : ∀ n : ℕ, 1 ≤ n →
    Real.eulerMascheroniConstant - (∑ k ∈ Finset.Icc 1 n, g k) < 1 / (2 * (n : ℝ)) := by
  intro n hn; rw [ gamma_sub_partial ] ; refine' lt_of_lt_of_le ( _ : _ < _ ) ( sq_tail_bound n hn ) ;
  apply_rules [ Summable.tsum_lt_tsum ];
  · intro i; exact_mod_cast ( gk_bound ( i + ( n + 1 ) ) ( by linarith ) |> le_of_lt ) ;
  · convert gk_bound ( n + ( n + 1 ) ) ( by linarith ) using 1 ; push_cast ; ring;
  · exact summable_g.comp_injective ( add_left_injective _ );
  · exact Summable.of_nonneg_of_le ( fun _ => by positivity ) ( fun _ => by rw [ div_le_div_iff₀ ] <;> norm_cast <;> ring <;> nlinarith ) ( summable_nat_add_iff 1 |>.2 <| Real.summable_one_div_nat_pow.2 one_lt_two )

end EMLPipeline