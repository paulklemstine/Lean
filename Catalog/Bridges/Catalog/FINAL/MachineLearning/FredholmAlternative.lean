/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license.

# The Fredholm Alternative for Compact Perturbations of the Identity

This file proves the Fredholm alternative: if `K` is a compact operator on an
infinite-dimensional Banach space over `ℝ` or `ℂ`, and `1 - K` is injective,
then `1 - K` is surjective.

## Main results

* `IsCompactOperator.isClosed_range_one_sub`: If `K` is compact and `1 - K` is injective,
  then the range of `1 - K` is closed.
* `IsCompactOperator.surjective_one_sub_of_injective`: The Fredholm alternative —
  injective `1 - K` implies surjective `1 - K`.
* `IsCompactOperator.bijective_one_sub_of_injective`: Injective `1 - K` implies bijective.

## Strategy

We follow the classical descending-range-chain proof:
1. Show that `1 - K` injective + `K` compact implies `1 - K` is bounded below,
   hence has closed range.
2. Show that the ranges `Vₙ = range((1-K)ⁿ)` form a strictly decreasing chain
   when `1 - K` is injective but not surjective.
3. Apply Riesz's lemma to extract a separated sequence, contradicting compactness.

## References

* Brezis, *Functional Analysis, Sobolev Spaces and Partial Differential Equations*
* Conway, *A Course in Functional Analysis*
-/

import Mathlib

open Filter Topology Set Function ContinuousLinearMap

noncomputable section

variable {𝕜 : Type*} [RCLike 𝕜]
variable {E : Type*} [NormedAddCommGroup E] [NormedSpace 𝕜 E] [CompleteSpace E]

/-! ### Compact operators on powers -/

/-
A positive power of a compact operator is compact.
-/
theorem IsCompactOperator.pow_pos {K : E →L[𝕜] E} (hK : IsCompactOperator K) :
    ∀ n : ℕ, 0 < n → IsCompactOperator (K ^ n : E →L[𝕜] E) := by
  intro n hn;
  induction' n with n ih;
  · contradiction;
  · rcases n with ( _ | n ) <;> simp_all +decide [ pow_succ, mul_assoc ];
    exact IsCompactOperator.comp_clm ih K

/-
`1 - (1-K)^n` is compact when `K` is compact. This is because the expression
    expands to a polynomial in `K` with no constant term, and each monomial `K^j`
    (for `j ≥ 1`) is compact.
-/
theorem IsCompactOperator.one_sub_pow_compact {K : E →L[𝕜] E} (hK : IsCompactOperator K)
    (n : ℕ) : IsCompactOperator ((1 - (1 - K) ^ n : E →L[𝕜] E) : E → E) := by
  induction n <;> simp_all +decide [ pow_succ, sub_mul ];
  · exact isCompactOperator_zero;
  · rename_i n ih
    have h_comp : IsCompactOperator ((⇑((1 - K) ^ n) ∘ ⇑K)) := by
      exact?;
    convert ih.add h_comp using 1 ; ext ; simp +decide [ sub_mul ];
    abel1

/-! ### Bounded below property and closed range -/

/-
If `K` is a compact operator and `1 - K` is injective, then `1 - K` is bounded below:
    there exists `c > 0` such that `c * ‖x‖ ≤ ‖(1 - K) x‖` for all `x`.
-/
theorem IsCompactOperator.bounded_below_one_sub_of_injective
    {K : E →L[𝕜] E} (hK : IsCompactOperator K)
    (hinj : Injective (1 - K : E →L[𝕜] E)) :
    ∃ c : ℝ, 0 < c ∧ ∀ x : E, c * ‖x‖ ≤ ‖(1 - K) x‖ := by
  by_contra! hc;
  -- By assumption, there exists a sequence $(x_n)$ such that $\|x_n\| = 1$ and $\|(1 - K) x_n\| < \frac{1}{n}$.
  obtain ⟨x, hx⟩ : ∃ x : ℕ → E, (∀ n, ‖x n‖ = 1) ∧ (∀ n, ‖(1 - K) (x n)‖ < 1 / (n + 1)) := by
    choose x hx using hc;
    refine' ⟨ fun n => ( ‖x ( 1 / ( n + 1 ) ) ( by positivity )‖⁻¹ : 𝕜 ) • x ( 1 / ( n + 1 ) ) ( by positivity ), _, _ ⟩ <;> simp_all +decide [ norm_smul ];
    · intro n; rw [ inv_mul_cancel₀ ] ; specialize hx ( ( n + 1 : ℝ ) ⁻¹ ) ( by positivity ) ; contrapose! hx; simp_all +decide [ sub_eq_iff_eq_add ] ;
    · intro n;
      rw [ inv_mul_lt_iff₀ ];
      · simpa [ mul_comm ] using hx ( ( n + 1 : ℝ ) ⁻¹ ) ( by positivity );
      · exact norm_pos_iff.mpr ( show x ( ( n : ℝ ) + 1 ) ⁻¹ ( by positivity ) ≠ 0 from fun h => by simpa [ h ] using hx ( ( n : ℝ ) + 1 ) ⁻¹ ( by positivity ) );
  -- Since $(x_n)$ is bounded and $K$ is compact, there is a subsequence with $K(x_{n_k})$ converging to some $z$.
  obtain ⟨z, hz⟩ : ∃ z : E, ∃ φ : ℕ → ℕ, StrictMono φ ∧ Filter.Tendsto (fun n => K (x (φ n))) Filter.atTop (nhds z) := by
    have := hK.isCompact_closure_image_of_bounded ( show Bornology.IsBounded ( Set.range x ) from ?_ );
    · have := this.isSeqCompact fun n => subset_closure ⟨ x n, Set.mem_range_self _, rfl ⟩;
      tauto;
    · exact isBounded_iff_forall_norm_le.mpr ⟨ 1, Set.forall_mem_range.mpr fun n => hx.1 n ▸ le_rfl ⟩;
  -- Then $x_{n_k} = (1-K)(x_{n_k}) + K(x_{n_k})$ converges to $z$.
  obtain ⟨φ, hφ_mono, hφ_conv⟩ := hz;
  have hx_conv : Filter.Tendsto (fun n => x (φ n)) Filter.atTop (nhds z) := by
    have hx_conv : Filter.Tendsto (fun n => (1 - K) (x (φ n))) Filter.atTop (nhds 0) := by
      exact squeeze_zero_norm ( fun n => le_of_lt ( hx.2 _ ) ) ( tendsto_one_div_add_atTop_nhds_zero_nat.comp hφ_mono.tendsto_atTop );
    convert hx_conv.add hφ_conv using 2 <;> simp +decide [ sub_eq_add_neg ];
  -- Since $\|x_{n_k}\| = 1$, we have $\|z\| = 1$.
  have hz_norm : ‖z‖ = 1 := by
    exact tendsto_nhds_unique ( hx_conv.norm ) ( tendsto_const_nhds.congr fun n => hx.1 _ ▸ rfl );
  -- Since $(1-K)(x_{n_k}) \to 0$, we have $(1-K)(z) = 0$.
  have hz_zero : (1 - K) z = 0 := by
    have hz_zero : Filter.Tendsto (fun n => (1 - K) (x (φ n))) Filter.atTop (nhds 0) := by
      exact squeeze_zero_norm ( fun n => le_of_lt ( hx.2 _ ) ) ( tendsto_one_div_add_atTop_nhds_zero_nat.comp hφ_mono.tendsto_atTop );
    exact tendsto_nhds_unique ( Filter.Tendsto.sub ( hx_conv ) ( K.continuous.continuousAt.tendsto.comp hx_conv ) ) hz_zero;
  exact absurd ( hinj ( show ( 1 - K ) z = ( 1 - K ) 0 by simpa using hz_zero ) ) ( by aesop )

/-
If `K` is a compact operator and `1 - K` is injective, then `1 - K` has closed range.
-/
theorem IsCompactOperator.isClosed_range_one_sub
    {K : E →L[𝕜] E} (hK : IsCompactOperator K)
    (hinj : Injective (1 - K : E →L[𝕜] E)) :
    IsClosed (range (1 - K : E →L[𝕜] E)) := by
  -- Use bounded_below_one_sub_of_injective to get c > 0 with c * ‖x‖ ≤ ‖(1-K)x‖ for all x.
  obtain ⟨c, hc⟩ : ∃ c > 0, ∀ x : E, c * ‖x‖ ≤ ‖(1 - K) x‖ := by
    -- Apply the bounded below lemma to obtain the existence of c > 0 such that c * ‖x‖ ≤ ‖(1 - K) x‖ for all x.
    apply IsCompactOperator.bounded_below_one_sub_of_injective hK hinj;
  have h_antilipschitz : AntilipschitzWith (Real.toNNReal (c⁻¹)) (fun x : E => (1 - K) x) := by
    refine' AntilipschitzWith.of_le_mul_dist fun x y => _;
    simp_all +decide [ dist_eq_norm, Real.toNNReal_of_nonneg, le_of_lt ];
    rw [ inv_mul_eq_div, le_div_iff₀' hc.1 ] ; convert hc.2 ( x - y ) using 1 ; simp +decide [ sub_eq_add_neg, add_assoc ];
    exact congr_arg Norm.norm ( by abel1 );
  convert h_antilipschitz.isClosed_range ( ContinuousLinearMap.uniformContinuous _ ) using 1

/-! ### Strictly descending range chain -/

/-
If `T` is an injective continuous linear map and `range(T^N) = range(T^{N+1})`,
    then `T` is surjective.
-/
theorem ContinuousLinearMap.surjective_of_range_pow_eq
    {T : E →L[𝕜] E} (hT : Injective T)
    {N : ℕ} (hN : LinearMap.range (T ^ (N + 1)).toLinearMap = LinearMap.range (T ^ N).toLinearMap) :
    Surjective T := by
  intro y;
  have hT_pow_y : T^[N] y ∈ (T^(N+1)).range := by
    simp_all +decide [ Set.ext_iff ];
    exact ⟨ y, by exact Nat.recOn N ( by simp +decide ) fun n ihn => by simp +decide [ *, Function.iterate_succ_apply', pow_succ' ] ⟩;
  obtain ⟨ z, hz ⟩ := hT_pow_y;
  -- Since $T$ is injective, we have $T^N(T(z)) = T^N(y)$ implies $T(z) = y$.
  have hTz_eq_y : T^[N] (T z) = T^[N] y := by
    convert hz using 1;
    exact Nat.recOn N ( by simp +decide [ pow_succ' ] ) fun n ihn => by simp +decide [ *, Function.iterate_succ_apply', pow_succ' ] ;
  exact ⟨ z, Function.Injective.iterate hT N hTz_eq_y ⟩

/-
If `T = 1 - K` with `K` compact is injective but not surjective,
    then the ranges `Vₙ = range(T^n)` are strictly decreasing.
-/
theorem IsCompactOperator.range_pow_strictAnti
    {K : E →L[𝕜] E} (hK : IsCompactOperator K)
    (hinj : Injective (1 - K : E →L[𝕜] E))
    (hnsurj : ¬Surjective (1 - K : E →L[𝕜] E)) :
    StrictAnti (fun n => LinearMap.range ((1 - K : E →L[𝕜] E) ^ n).toLinearMap) := by
  -- First, show that the range of $T^{N+1}$ is strictly contained in the range of $T^N$ for any $N$.
  have h_range_lt (N : ℕ) : LinearMap.range ( ( 1 - K ) ^ ( N + 1 ) ).toLinearMap < LinearMap.range ( ( 1 - K ) ^ N ).toLinearMap := by
    refine' lt_of_le_of_ne _ _;
    · simp +decide [ pow_succ, SetLike.le_def ];
      exact fun x => ⟨ x - K x, by simp +decide ⟩;
    · exact fun h => hnsurj <| ContinuousLinearMap.surjective_of_range_pow_eq hinj h;
  exact strictAnti_nat_of_succ_lt fun n => h_range_lt n

/-! ### Helper: closedness of iterated ranges -/

/-
Each iterated range `range((1-K)^n)` is closed when `K` is compact and `1-K` is injective.
This follows from the fact that `(1-K)^n = 1 - K_n` where `K_n` is compact.
-/
theorem IsCompactOperator.isClosed_range_pow
    {K : E →L[𝕜] E} (hK : IsCompactOperator K)
    (hinj : Injective (1 - K : E →L[𝕜] E)) (n : ℕ) :
    IsClosed (LinearMap.range ((1 - K : E →L[𝕜] E) ^ n).toLinearMap : Set E) := by
  -- Since $T^n = (1-K)^n = 1 - K_n$ where $K_n = 1 - (1-K)^n$ is compact,
  obtain ⟨K', hK', hK''⟩ : ∃ K' : E →L[𝕜] E, IsCompactOperator K' ∧ (1 - K') = (1 - K) ^ n := by
    exact ⟨ _, IsCompactOperator.one_sub_pow_compact hK n, by simp ⟩;
  convert IsCompactOperator.isClosed_range_one_sub hK' _;
  · exact Set.ext fun x => by simp +decide [ ← hK'' ] ;
  · convert hinj.iterate n;
    convert congr_arg ( fun f : E →L[𝕜] E => f : ( E →L[𝕜] E ) → E → E ) hK'' using 1;
    exact?

/-! ### Helper: Riesz lemma for nested submodules -/

/-
A version of Riesz's lemma for nested closed submodules: given `W < V` both closed
submodules of `E`, there exists `x ∈ V` with `‖x‖ = 1` and distance to `W` at least `1/2`.
-/
theorem riesz_lemma_of_nested_submodules
    {V W : Submodule 𝕜 E}
    (hW_le : W ≤ V)
    (hW_closed : IsClosed (W : Set E))
    (hV_closed : IsClosed (V : Set E))
    (hW_ne : W ≠ V) :
    ∃ x : E, x ∈ V ∧ ‖x‖ = 1 ∧ ∀ y ∈ W, (1 / 2 : ℝ) ≤ ‖x - ↑y‖ := by
  -- By Riesz's lemma, there exists $x \in V$ with $\|x\| = 1$ such that $\|x - y\| \geq \frac{1}{2}$ for all $y \in W$.
  obtain ⟨x, hxV, hx⟩ : ∃ x : V, ‖x‖ = 1 ∧ ∀ y : V, y ∈ (W.comap (Submodule.subtype V)) → 1 / 2 ≤ ‖x - y‖ := by
    have := @riesz_lemma_of_lt_one;
    convert this ( show IsClosed ( Submodule.comap V.subtype W : Set V ) from ?_ ) ?_ ( show ( 1 : ℝ ) / 2 < 1 by norm_num ) using 1;
    · ext xop;
      by_cases hx : xop ∈ Submodule.comap V.subtype W <;> simp +decide [ hx ];
      exact fun _ => ⟨ xop, xop.2, hx, by simp +decide [ * ] ⟩;
    · convert hW_closed.preimage ( continuous_subtype_val ) using 1;
    · contrapose! hW_ne;
      exact SetLike.ext' ( Set.eq_of_subset_of_subset hW_le fun x hx => hW_ne ⟨ x, hx ⟩ );
  refine' ⟨ x, x.2, hxV, fun y hy => _ ⟩;
  convert hx ⟨ y, hW_le hy ⟩ hy

/-! ### The Fredholm Alternative -/

/-
**Fredholm Alternative (injective ⟹ surjective).**
Let `E` be an infinite-dimensional Banach space over `ℝ` or `ℂ`, and let
`K : E →L[𝕜] E` be a compact operator. If `1 - K` is injective, then `1 - K` is surjective.

This is proved by contradiction: assuming `1 - K` is injective but not surjective,
we construct a bounded sequence `(xₙ)` such that `(K xₙ)` has no convergent subsequence,
contradicting compactness of `K`. The sequence is obtained by applying Riesz's lemma
to the strictly descending chain of ranges `range((1-K)ⁿ)`.
-/
theorem IsCompactOperator.surjective_one_sub_of_injective
    {K : E →L[𝕜] E} (hK : IsCompactOperator K)
    (hinj : Injective (1 - K : E →L[𝕜] E))
    (hinfin : ¬FiniteDimensional 𝕜 E) :
    Surjective (1 - K : E →L[𝕜] E) := by
  -- By contradiction, assume `1 - K` is not surjective.
  by_contra hnsurj
  -- Apply the range_pow_strictAnti lemma to obtain a strictly decreasing chain of ranges.
  have h_chain : StrictAnti (fun n => LinearMap.range ((1 - K : E →L[𝕜] E) ^ n).toLinearMap) := by
    convert IsCompactOperator.range_pow_strictAnti hK hinj hnsurj using 1;
  -- Apply Riesz's lemma to obtain a sequence $(x_n)$ in $E$ such that $\|x_n\| = 1$ and $\|x_n - y\| \geq \frac{1}{2}$ for all $y \in \text{range}((1 - K)^{n+1})$.
  obtain ⟨x, hx⟩ : ∃ x : ℕ → E, (∀ n, ‖x n‖ = 1) ∧ (∀ n, x n ∈ LinearMap.range ((1 - K : E →L[𝕜] E) ^ n).toLinearMap) ∧ (∀ n, ∀ y ∈ LinearMap.range ((1 - K : E →L[𝕜] E) ^ (n + 1)).toLinearMap, (1 / 2 : ℝ) ≤ ‖x n - y‖) := by
    have h_riesz : ∀ n, ∃ x : E, x ∈ LinearMap.range ((1 - K : E →L[𝕜] E) ^ n).toLinearMap ∧ ‖x‖ = 1 ∧ ∀ y ∈ LinearMap.range ((1 - K : E →L[𝕜] E) ^ (n + 1)).toLinearMap, (1 / 2 : ℝ) ≤ ‖x - y‖ := by
      intro n
      have h_closed : IsClosed (LinearMap.range ((1 - K : E →L[𝕜] E) ^ n).toLinearMap : Set E) := by
        apply_rules [ IsCompactOperator.isClosed_range_pow ]
      have h_closed_succ : IsClosed (LinearMap.range ((1 - K : E →L[𝕜] E) ^ (n + 1)).toLinearMap : Set E) := by
        convert IsCompactOperator.isClosed_range_pow hK hinj ( n + 1 ) using 1
      have h_ne : LinearMap.range ((1 - K : E →L[𝕜] E) ^ (n + 1)).toLinearMap ≠ LinearMap.range ((1 - K : E →L[𝕜] E) ^ n).toLinearMap := by
        exact ne_of_lt ( h_chain n.lt_succ_self )
      apply riesz_lemma_of_nested_submodules (h_chain.antitone (Nat.le_succ n)) h_closed_succ h_closed h_ne;
    exact ⟨ fun n => Classical.choose ( h_riesz n ), fun n => Classical.choose_spec ( h_riesz n ) |>.2.1, fun n => Classical.choose_spec ( h_riesz n ) |>.1, fun n => Classical.choose_spec ( h_riesz n ) |>.2.2 ⟩;
  -- By the properties of the sequence $(x_n)$, we have $\|K(x_n) - K(x_m)\| \geq \frac{1}{2}$ for all $n < m$.
  have h_dist : ∀ n m, n < m → (1 / 2 : ℝ) ≤ ‖K (x n) - K (x m)‖ := by
    intro n m hnm
    have h_dist : (1 / 2 : ℝ) ≤ ‖x n - (1 - K) (x n) - (x m - (1 - K) (x m))‖ := by
      have h_dist : (1 - K) (x n) ∈ LinearMap.range ((1 - K : E →L[𝕜] E) ^ (n + 1)).toLinearMap ∧ x m ∈ LinearMap.range ((1 - K : E →L[𝕜] E) ^ (n + 1)).toLinearMap ∧ (1 - K) (x m) ∈ LinearMap.range ((1 - K : E →L[𝕜] E) ^ (n + 1)).toLinearMap := by
        refine' ⟨ _, _, _ ⟩;
        · simp +decide [ pow_succ', mul_assoc ];
          obtain ⟨ y, hy ⟩ := hx.2.1 n; use y; aesop;
        · exact h_chain.antitone ( Nat.succ_le_of_lt hnm ) ( hx.2.1 m );
        · have h_dist_step : (1 - K) (x m) ∈ LinearMap.range ((1 - K : E →L[𝕜] E) ^ (m + 1)).toLinearMap := by
            obtain ⟨ y, hy ⟩ := hx.2.1 m;
            simp +decide [ ← hy, pow_succ' ];
          exact h_chain.antitone ( Nat.succ_le_succ hnm.le ) h_dist_step;
      have := hx.2.2 n ( ( 1 - K ) ( x n ) + x m - ( 1 - K ) ( x m ) ) ?_ <;> simp_all +decide [ sub_eq_iff_eq_add ];
      · convert this using 2 ; abel_nf;
      · obtain ⟨ y, hy ⟩ := h_dist.1; obtain ⟨ z, hz ⟩ := h_dist.2.1; obtain ⟨ w, hw ⟩ := h_dist.2.2; use y + z - w; simp +decide [ hy, hz, hw, add_sub_assoc ] ;
    convert h_dist using 2 ; simp +decide [ sub_eq_add_neg, add_assoc ];
  -- Since $K$ is compact, the sequence $(K(x_n))$ has a convergent subsequence.
  obtain ⟨subseq, hsubseq⟩ : ∃ subseq : ℕ → ℕ, StrictMono subseq ∧ ∃ y, Filter.Tendsto (fun n => K (x (subseq n))) Filter.atTop (nhds y) := by
    have h_compact : IsCompact (closure (K '' Metric.closedBall 0 1)) := by
      exact hK.isCompact_closure_image_closedBall 1;
    have := h_compact.isSeqCompact fun n => subset_closure ⟨ x n, by simp +decide [ hx.1 ], rfl ⟩;
    tauto;
  obtain ⟨ y, hy ⟩ := hsubseq.2;
  have := hy.sub ( hy.comp ( Filter.tendsto_add_atTop_nat 1 ) );
  exact absurd ( this.eventually ( Metric.ball_mem_nhds _ one_half_pos ) ) fun h => by rcases h.exists with ⟨ n, hn ⟩ ; exact not_lt_of_ge ( h_dist _ _ ( hsubseq.1 n.lt_succ_self ) ) ( by simpa using hn ) ;

/-- **Fredholm Alternative (bijective form).**
A compact perturbation of the identity on an infinite-dimensional Banach space
is bijective if and only if it is injective. -/
theorem IsCompactOperator.bijective_one_sub_of_injective
    {K : E →L[𝕜] E} (hK : IsCompactOperator K)
    (hinj : Injective (1 - K : E →L[𝕜] E))
    (hinfin : ¬FiniteDimensional 𝕜 E) :
    Bijective (1 - K : E →L[𝕜] E) :=
  ⟨hinj, hK.surjective_one_sub_of_injective hinj hinfin⟩

/-! ### Equivalent formulations -/

/-- Range/kernel formulation of the Fredholm alternative. -/
theorem IsCompactOperator.range_eq_top_of_ker_eq_bot
    {K : E →L[𝕜] E} (hK : IsCompactOperator K)
    (hker : LinearMap.ker (1 - K : E →L[𝕜] E).toLinearMap = ⊥)
    (hinfin : ¬FiniteDimensional 𝕜 E) :
    LinearMap.range (1 - K : E →L[𝕜] E).toLinearMap = ⊤ := by
  rw [LinearMap.range_eq_top]
  exact hK.surjective_one_sub_of_injective (LinearMap.ker_eq_bot.mp hker) hinfin

/-! ### Supporting result: compact identity iff finite-dimensional -/

/-
The identity operator is compact if and only if the space is finite-dimensional.
This is a key supporting result for the Fredholm alternative.
-/
omit [CompleteSpace E] in
theorem isCompactOperator_id_iff_finiteDimensional :
    IsCompactOperator (ContinuousLinearMap.id 𝕜 E) ↔ FiniteDimensional 𝕜 E := by
  constructor;
  · intro h_compact
    have h_closed_ball : IsCompact (Metric.closedBall (0 : E) 1) := by
      have := h_compact.isCompact_closure_image_closedBall 1;
      simpa using this;
    exact FiniteDimensional.of_isCompact_closedBall _ zero_lt_one h_closed_ball;
  · -- Since E is finite-dimensional and complete, it is a ProperSpace.
    intro hfin
    have hproper : ProperSpace E := by
      exact?;
    exact ⟨ Metric.closedBall 0 1, ProperSpace.isCompact_closedBall _ _, Filter.mem_of_superset ( Metric.ball_mem_nhds _ zero_lt_one ) fun x hx => by simpa using hx.out.le ⟩

/-
A compact operator on an infinite-dimensional Banach space cannot be bounded below.
-/
theorem IsCompactOperator.not_bounded_below
    {T : E →L[𝕜] E} (hT : IsCompactOperator T)
    (hinfin : ¬FiniteDimensional 𝕜 E) :
    ¬∃ c : ℝ, 0 < c ∧ ∀ x : E, c * ‖x‖ ≤ ‖T x‖ := by
  intro ⟨ c, hc_pos, hc ⟩;
  -- Since $T$ is compact and bounded below, every bounded sequence has a convergent subsequence.
  have h_convergent_subseq : ∀ (x : ℕ → E), (∀ n, ‖x n‖ ≤ 1) → ∃ (subseq : ℕ → ℕ), StrictMono subseq ∧ ∃ y : E, Filter.Tendsto (fun n => x (subseq n)) Filter.atTop (nhds y) := by
    intro x hx
    obtain ⟨subseq, hsubseq⟩ : ∃ (subseq : ℕ → ℕ), StrictMono subseq ∧ ∃ y : E, Filter.Tendsto (fun n => T (x (subseq n))) Filter.atTop (nhds y) := by
      have := hT.isCompact_closure_image_closedBall 1;
      have := this.isSeqCompact fun n => subset_closure ⟨ x n, mem_closedBall_zero_iff.mpr ( hx n ), rfl ⟩;
      tauto;
    -- Since $T$ is bounded below, the sequence $(x_{n_k})$ is Cauchy.
    have h_cauchy : CauchySeq (fun n => x (subseq n)) := by
      have h_cauchy : ∀ m n, ‖x (subseq m) - x (subseq n)‖ ≤ (1 / c) * ‖T (x (subseq m)) - T (x (subseq n))‖ := by
        intro m n; rw [ div_mul_eq_mul_div, le_div_iff₀' hc_pos ] ; simpa [ map_sub ] using hc ( x ( subseq m ) - x ( subseq n ) ) ;
      rw [ Metric.cauchySeq_iff ];
      intro ε εpos;
      rcases Metric.cauchySeq_iff.1 ( hsubseq.2.choose_spec.cauchySeq ) ( ε * c ) ( mul_pos εpos hc_pos ) with ⟨ N, hN ⟩;
      exact ⟨ N, fun m hm n hn => by rw [ dist_eq_norm ] at *; exact lt_of_le_of_lt ( h_cauchy m n ) ( by rw [ div_mul_eq_mul_div, div_lt_iff₀ ] <;> nlinarith [ hN m hm n hn, norm_nonneg ( T ( x ( subseq m ) ) - T ( x ( subseq n ) ) ), dist_eq_norm ( T ( x ( subseq m ) ) ) ( T ( x ( subseq n ) ) ) ] ) ⟩;
    exact ⟨ subseq, hsubseq.1, _, h_cauchy.tendsto_limUnder ⟩;
  -- Since every bounded sequence has a convergent subsequence, the closed unit ball in $E$ is sequentially compact.
  have h_seq_compact : IsSeqCompact (Metric.closedBall (0 : E) 1) := by
    intro x hx;
    rcases h_convergent_subseq x ( fun n => by simpa using hx n ) with ⟨ subseq, hsubseq, y, hy ⟩;
    exact ⟨ y, by exact mem_closedBall_zero_iff.mpr ( le_of_tendsto' ( hy.norm ) fun n => by simpa using hx ( subseq n ) ), subseq, hsubseq, hy ⟩;
  exact hinfin <| FiniteDimensional.of_isCompact_closedBall _ zero_lt_one <| h_seq_compact.isCompact

end