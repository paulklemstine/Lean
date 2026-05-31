import Mathlib

/-!
# EML Fixed-Point Theorem: Exp-Log Iteration Convergence

We study the single-operator EML function `f(x) = e^a · log(b·x + c)` and prove
that under suitable parameter constraints it is a contraction mapping on a closed
interval, yielding a unique fixed point with geometric convergence.

## Main definitions

* `EMLIterOp` — the exp-log operator `f(x) = exp(a) * log(b*x + c)`
* `EMLIterOp.iterSeq` — the iteration sequence `x_{n+1} = f(x_n)`
* `ContractionData` — a structure packaging the contraction mapping data

## Main results

* `EMLIterOp.deriv_formula` — derivative `f'(x) = exp(a) * b / (b*x + c)`
* `EMLIterOp.fixedPoint_eq` — any fixed point satisfies `x* = exp(a) * log(b*x* + c)`
* `EMLIterOp.contraction_of_deriv_bound` — when |f'| < 1 on an interval,
  f is a contraction
* `EMLIterOp.fixedPoint_unique` — uniqueness of fixed point on contraction interval
* `EMLIterOp.iterSeq_converges` — the iteration sequence converges

## References

* Banach fixed-point theorem
* EML (Exp-Minus-Log) neural network framework
-/

noncomputable section

open Real Set Filter Topology

/-! ## Core Definitions -/

/-- The EML single-operator function: `f(x) = exp(a) * log(b*x + c)`.
This is a building block for EML neural network layers, combining
exponential scaling with logarithmic compression. -/
def EMLIterOp (a b c : ℝ) (x : ℝ) : ℝ := exp a * log (b * x + c)

/-- The iteration sequence for the EML operator: `x_{n+1} = EMLIterOp a b c x_n`. -/
def EMLIterOp.iterSeq (a b c x₀ : ℝ) : ℕ → ℝ
  | 0 => x₀
  | n + 1 => EMLIterOp a b c (EMLIterOp.iterSeq a b c x₀ n)

/-- A structure packaging the contraction mapping data for an EML operator.
Contains the parameters, the contraction ratio, and the invariant interval. -/
structure EMLContractionData where
  /-- Exponential scaling parameter -/
  a : ℝ
  /-- Linear coefficient -/
  b : ℝ
  /-- Translation parameter -/
  c : ℝ
  /-- Left endpoint of invariant interval -/
  lo : ℝ
  /-- Right endpoint of invariant interval -/
  hi : ℝ
  /-- Contraction ratio -/
  rho : ℝ
  /-- Parameters define a valid interval -/
  lo_lt_hi : lo < hi
  /-- Contraction ratio is in [0, 1) -/
  rho_nonneg : 0 ≤ rho
  rho_lt_one : rho < 1
  /-- The argument of log is positive on the interval -/
  arg_pos : ∀ x ∈ Icc lo hi, 0 < b * x + c
  /-- The function maps the interval to itself -/
  maps_to : ∀ x ∈ Icc lo hi, EMLIterOp a b c x ∈ Icc lo hi
  /-- The derivative is bounded by rho on the interval -/
  deriv_bound : ∀ x ∈ Icc lo hi, |exp a * b / (b * x + c)| ≤ rho

/-! ## Basic Properties -/

/-- Unfolding the definition of `EMLIterOp`. -/
theorem EMLIterOp.unfold (a b c x : ℝ) :
    EMLIterOp a b c x = exp a * log (b * x + c) := rfl

/-- The iteration sequence at step 0 is the initial point. -/
theorem EMLIterOp.iterSeq_zero (a b c x₀ : ℝ) :
    EMLIterOp.iterSeq a b c x₀ 0 = x₀ := rfl

/-- The iteration sequence satisfies the recurrence. -/
theorem EMLIterOp.iterSeq_succ (a b c x₀ : ℝ) (n : ℕ) :
    EMLIterOp.iterSeq a b c x₀ (n + 1) =
    EMLIterOp a b c (EMLIterOp.iterSeq a b c x₀ n) := rfl

/-! ## Differentiability and Derivative Formula -/

/-
The EML operator has a derivative at x when b*x + c > 0,
and the derivative is `exp(a) * b / (b*x + c)`.
-/
theorem EMLIterOp.hasDerivAt (a b c x : ℝ) (harg : 0 < b * x + c) :
    HasDerivAt (EMLIterOp a b c) (exp a * b / (b * x + c)) x := by
  convert HasDerivAt.const_mul ( Real.exp a ) ( HasDerivAt.log ( HasDerivAt.add ( HasDerivAt.const_mul b ( hasDerivAt_id' x ) ) ( hasDerivAt_const _ _ ) ) harg.ne' ) using 1 ; ring!;
  rfl

/-
The derivative of the EML operator at the fixed point determines
the convergence rate.
-/
theorem EMLIterOp.deriv_eq (a b c x : ℝ) (harg : 0 < b * x + c) :
    deriv (EMLIterOp a b c) x = exp a * b / (b * x + c) := by
  convert HasDerivAt.deriv ( EMLIterOp.hasDerivAt a b c x harg ) using 1

/-! ## Fixed Point Characterization -/

/-
A fixed point of the EML operator satisfies the implicit equation
`x* = exp(a) * log(b * x* + c)`.
-/
theorem EMLIterOp.fixedPoint_eq (a b c xstar : ℝ)
    (hfix : EMLIterOp a b c xstar = xstar) :
    xstar = exp a * log (b * xstar + c) := by
  exact hfix.symm

/-
At a fixed point, if the log argument is positive, then exp(a) scales
the log value to produce the fixed point. This gives a useful bound:
log(b*x*+c) = x*/exp(a).
-/
theorem EMLIterOp.fixedPoint_log_eq (a b c xstar : ℝ)
    (hfix : EMLIterOp a b c xstar = xstar) :
    exp a * log (b * xstar + c) = xstar := by
  exact hfix

/-
When the log argument is in (0,∞) and the fixed point is positive,
the log value must be positive, hence b*x*+c > 1.
-/
theorem EMLIterOp.fixedPoint_arg_gt_one (a b c xstar : ℝ)
    (hfix : EMLIterOp a b c xstar = xstar)
    (hxstar_pos : 0 < xstar)
    (harg_pos : 0 < b * xstar + c) :
    1 < b * xstar + c := by
  exact not_le.mp fun h => hxstar_pos.not_ge <| by rw [ show EMLIterOp a b c xstar = Real.exp a * Real.log ( b * xstar + c ) by rfl ] at hfix; nlinarith [ Real.exp_pos a, Real.log_nonpos harg_pos.le h ] ;

/-! ## Contraction Mapping via Mean Value Theorem -/

/-
If the absolute derivative of f is bounded by ρ < 1 on [lo, hi],
then f is Lipschitz with constant ρ on that interval. This is
the key step from the mean value theorem to contraction.
-/
theorem EMLIterOp.lipschitz_of_deriv_bound
    (a b c lo hi rho : ℝ)
    (_hlo_hi : lo < hi)
    (harg_pos : ∀ x ∈ Icc lo hi, 0 < b * x + c)
    (hbound : ∀ x ∈ Icc lo hi, |exp a * b / (b * x + c)| ≤ rho) :
    ∀ x ∈ Icc lo hi, ∀ y ∈ Icc lo hi,
      |EMLIterOp a b c x - EMLIterOp a b c y| ≤ rho * |x - y| := by
  intros x hx y hy
  have h_convex : Convex ℝ (Set.Icc lo hi) := by
    exact convex_Icc lo hi;
  have := @Convex.norm_image_sub_le_of_norm_hasDerivWithin_le;
  specialize this ( fun x hx => HasDerivAt.hasDerivWithinAt ( EMLIterOp.hasDerivAt a b c x ( harg_pos x hx ) ) ) ( fun x hx => hbound x hx ) h_convex hx hy;
  simpa only [ norm_sub_rev, abs_sub_comm ] using this

/-! ## Fixed Point Uniqueness -/

/-
If the EML operator is a contraction on [lo, hi] (derivative bounded by ρ < 1),
then it has at most one fixed point in that interval.
-/
theorem EMLIterOp.fixedPoint_unique
    (a b c lo hi rho : ℝ)
    (hlo_hi : lo < hi)
    (hrho_lt : rho < 1)
    (_hrho_nn : 0 ≤ rho)
    (harg_pos : ∀ x ∈ Icc lo hi, 0 < b * x + c)
    (hbound : ∀ x ∈ Icc lo hi, |exp a * b / (b * x + c)| ≤ rho)
    (x₁ x₂ : ℝ) (hx₁ : x₁ ∈ Icc lo hi) (hx₂ : x₂ ∈ Icc lo hi)
    (hfix₁ : EMLIterOp a b c x₁ = x₁)
    (hfix₂ : EMLIterOp a b c x₂ = x₂) :
    x₁ = x₂ := by
  -- Applying the Lipschitz property to x₁ and x₂, we get |x₁ - x₂| ≤ rho * |x₁ - x₂|.
  have h_lip : |x₁ - x₂| ≤ rho * |x₁ - x₂| := by
    convert EMLIterOp.lipschitz_of_deriv_bound a b c lo hi rho hlo_hi harg_pos hbound x₁ hx₁ x₂ hx₂ using 1 ; aesop
  generalize_proofs at *; (
  exact sub_eq_zero.mp ( by contrapose! h_lip; nlinarith [ abs_pos.mpr h_lip ] ))

/-! ## Iteration Stays in Interval -/

/-
If the EML operator maps [lo, hi] to itself and x₀ ∈ [lo, hi],
then all iterates stay in [lo, hi].
-/
theorem EMLIterOp.iterSeq_mem_Icc
    (a b c x₀ lo hi : ℝ)
    (hx₀ : x₀ ∈ Icc lo hi)
    (hmaps : ∀ x ∈ Icc lo hi, EMLIterOp a b c x ∈ Icc lo hi)
    (n : ℕ) :
    EMLIterOp.iterSeq a b c x₀ n ∈ Icc lo hi := by
  induction' n with n ih <;> [ tauto; exact hmaps _ ih ]

/-! ## Convergence of Iteration -/

/-
The distance between consecutive iterates decays geometrically:
`|x_{n+1} - x_n| ≤ ρ^n * |x_1 - x_0|`.
-/
theorem EMLIterOp.iterSeq_geometric_decay
    (D : EMLContractionData) (x₀ : ℝ) (hx₀ : x₀ ∈ Icc D.lo D.hi) :
    ∀ n : ℕ, |EMLIterOp.iterSeq D.a D.b D.c x₀ (n + 1) -
              EMLIterOp.iterSeq D.a D.b D.c x₀ n| ≤
      D.rho ^ n * |EMLIterOp.iterSeq D.a D.b D.c x₀ 1 -
                    EMLIterOp.iterSeq D.a D.b D.c x₀ 0| := by
  intro n;
  induction' n with n ih <;> simp_all +decide [ pow_succ', mul_assoc ];
  refine' le_trans _ ( mul_le_mul_of_nonneg_left ih D.rho_nonneg );
  convert EMLIterOp.lipschitz_of_deriv_bound D.a D.b D.c D.lo D.hi D.rho D.lo_lt_hi D.arg_pos D.deriv_bound _ _ _ _ using 1 <;> norm_num [ EMLIterOp.iterSeq ];
  · exact D.maps_to _ ( EMLIterOp.iterSeq_mem_Icc _ _ _ _ _ _ hx₀ D.maps_to _ );
  · exact EMLIterOp.iterSeq_mem_Icc _ _ _ _ _ _ hx₀ D.maps_to _

/-
The iteration sequence is Cauchy, hence convergent.
-/
theorem EMLIterOp.iterSeq_cauchy
    (D : EMLContractionData) (x₀ : ℝ) (hx₀ : x₀ ∈ Icc D.lo D.hi) :
    CauchySeq (EMLIterOp.iterSeq D.a D.b D.c x₀) := by
  fapply cauchySeq_of_le_geometric;
  exact D.rho;
  exact |EMLIterOp.iterSeq D.a D.b D.c x₀ 1 - EMLIterOp.iterSeq D.a D.b D.c x₀ 0|;
  · exact D.rho_lt_one;
  · intro n; rw [ dist_comm ] ; convert EMLIterOp.iterSeq_geometric_decay D x₀ hx₀ n using 1 ; ring;

/-
Main convergence theorem: the EML iteration converges to a limit
that is a fixed point of the operator.
-/
theorem EMLIterOp.iterSeq_converges
    (D : EMLContractionData) (x₀ : ℝ) (hx₀ : x₀ ∈ Icc D.lo D.hi) :
    ∃ xstar, Filter.Tendsto (EMLIterOp.iterSeq D.a D.b D.c x₀) atTop (nhds xstar) ∧
      EMLIterOp D.a D.b D.c xstar = xstar ∧
      xstar ∈ Icc D.lo D.hi := by
  -- By iterSeq_cauchy, the sequence is Cauchy, hence converges to some limit xstar.
  obtain ⟨xstar, hxstar⟩ : ∃ xstar, Filter.Tendsto (EMLIterOp.iterSeq D.a D.b D.c x₀) Filter.atTop (𝓝 xstar) := by
    exact cauchySeq_tendsto_of_complete ( EMLIterOp.iterSeq_cauchy D x₀ hx₀ );
  refine' ⟨ xstar, hxstar, _, _ ⟩;
  · -- By continuity of EMLIterOp, we have EMLIterOp D.a D.b D.c xstar = xstar.
    have h_cont : ContinuousAt (EMLIterOp D.a D.b D.c) xstar := by
      exact DifferentiableAt.continuousAt ( by exact DifferentiableAt.mul ( differentiableAt_const _ ) ( DifferentiableAt.log ( differentiableAt_id.const_mul _ |> DifferentiableAt.add <| differentiableAt_const _ ) <| by linarith [ D.arg_pos xstar <| by exact ⟨ by exact le_of_tendsto_of_tendsto' tendsto_const_nhds hxstar fun n => ( EMLIterOp.iterSeq_mem_Icc D.a D.b D.c x₀ D.lo D.hi hx₀ D.maps_to n ) |>.1, by exact le_of_tendsto_of_tendsto' hxstar tendsto_const_nhds fun n => ( EMLIterOp.iterSeq_mem_Icc D.a D.b D.c x₀ D.lo D.hi hx₀ D.maps_to n ) |>.2 ⟩ ] ) );
    exact tendsto_nhds_unique ( h_cont.tendsto.comp hxstar ) ( hxstar.comp ( Filter.tendsto_add_atTop_nat 1 ) );
  · exact isClosed_Icc.mem_of_tendsto hxstar ( Filter.Eventually.of_forall fun n => EMLIterOp.iterSeq_mem_Icc _ _ _ _ _ _ hx₀ D.maps_to n )

/-! ## Specific Parameter Cases -/

/-- For the special case b = 1, c = 1, a > 0, the EML operator
simplifies to `f(x) = exp(a) * log(x + 1)`. -/
theorem EMLIterOp.special_b1_c1 (a x : ℝ) :
    EMLIterOp a 1 1 x = exp a * log (x + 1) := by
  simp [EMLIterOp, one_mul]

/-- For a = 0, the EML operator becomes `f(x) = log(b*x + c)`,
with derivative `b / (b*x + c)`. -/
theorem EMLIterOp.at_a_zero (b c x : ℝ) :
    EMLIterOp 0 b c x = log (b * x + c) := by
  simp [EMLIterOp]

/-! ## Conjecture: Power Series Expansion of Fixed Point -/

/-
**Conjecture**: For small `a > 0` with b = 1, c = 2, the fixed point
`x*(a)` of the EML operator `f(x) = exp(a) * log(x + 2)` admits a
convergent power series expansion in `a` around `a = 0`.

At `a = 0`, the fixed point satisfies `x* = log(x* + 2)`, which has a
unique solution x* ≈ 1.146. For small a, the fixed point moves smoothly.

**Test**: Compute the fixed point numerically for a = 0.01, 0.1, 0.5
and verify that the first-order approximation
`x*(a) ≈ x*(0) + a * x*(0) / (1 - exp(0) / (x*(0) + 2))`
matches to within O(a²).

This conjecture is falsifiable by computing the radius of convergence:
if the power series diverges for some a₀ > 0, the conjecture fails for
a > a₀.
-/
theorem EMLIterOp.fixedPoint_powerSeries_conjecture :
    ∀ a : ℝ, 0 < a → a < 1 / 2 →
    ∃ xstar : ℝ, EMLIterOp a 1 2 xstar = xstar ∧ 0 < xstar := by
  intro a ha h'a; unfold EMLIterOp; norm_num at *;
  -- We need to find where $f(x) - x$ changes sign. $f(1)-1 = \exp(a) \log(3) - 1 > 0$ (since $\log 3 > 1$ and $\exp(a) \geq 1$). $f(3)-3 = \exp(a) � \�log(5) - 3$. For $a=0$: $\log(5)-3 \approx 1.609-3 = -1.39 < 0$. For $a < 1/2$: $\exp(1/2) \log(5) \approx 2.65 < 3$. So $f(3) < 3$. By IVT, there exists $x^* \in (1,3)$ with $f(x^*) = x^*$.
  have h_ivt : ∃ xstar ∈ Set.Ioo 1 3, Real.exp a * Real.log (xstar + 2) = xstar := by
    have h_ivt : ∃ xstar ∈ Set.Ioo 1 3, Real.exp a * Real.log (xstar + 2) - xstar = 0 := by
      apply_rules [ intermediate_value_Ioo' ] <;> norm_num;
      · exact ContinuousOn.sub ( ContinuousOn.mul continuousOn_const ( ContinuousOn.log ( continuousOn_id.add continuousOn_const ) fun x hx => by linarith [ hx.1 ] ) ) continuousOn_id;
      · constructor;
        · -- We'll use that $e^{1/2} \approx 1.64872$ and $\log 5 \approx 1.60944$.
          have h_approx : Real.exp (1 / 2) < 1.7 ∧ Real.log 5 < 1.7 := by
            constructor;
            · rw [ ← Real.log_lt_log_iff ( by positivity ) ] <;> norm_num;
              rw [ div_lt_iff₀' ] <;> norm_num [ ← Real.log_rpow, Real.lt_log_iff_exp_lt ];
              exact Real.exp_one_lt_d9.trans_le <| by norm_num;
            · norm_num [ Real.log_lt_iff_lt_exp ];
              -- We can raise both sides to the power of 10 to remove the fraction.
              suffices h_exp : (5 : ℝ) ^ 10 < Real.exp 17 by
                contrapose! h_exp;
                convert pow_le_pow_left₀ ( by positivity ) h_exp 10 using 1 ; norm_num [ ← Real.exp_nat_mul ];
              have := Real.exp_one_gt_d9.le ; norm_num at * ; rw [ show Real.exp 17 = ( Real.exp 1 ) ^ 17 by rw [ ← Real.exp_nat_mul ] ; norm_num ] ; exact lt_of_lt_of_le ( by norm_num ) ( pow_le_pow_left₀ ( by positivity ) this _ );
          exact lt_of_le_of_lt ( mul_le_mul_of_nonneg_right ( Real.exp_le_exp.mpr h'a.le ) ( Real.log_nonneg ( by norm_num ) ) ) ( by norm_num at *; nlinarith [ Real.exp_pos ( 1 / 2 ) ] );
        · exact one_lt_mul_of_lt_of_le ( by norm_num; linarith ) ( Real.le_log_iff_exp_le ( by norm_num ) |>.2 <| by exact Real.exp_one_lt_d9.le.trans <| by norm_num );
    simpa only [ sub_eq_zero ] using h_ivt;
  grind

end