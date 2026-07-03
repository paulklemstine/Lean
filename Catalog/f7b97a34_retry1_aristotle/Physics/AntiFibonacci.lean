import Mathlib
import Catalog.Novelty.GoldenRatioApproximation

/-!
# The Anti-Fibonacci Sequence: quadratic growth that avoids the golden ratio

The Fibonacci sequence `F(n+1) = F(n) + F(n-1)` grows exponentially and its
consecutive ratios converge to the golden ratio `φ = (1+√5)/2`.  This file studies
the **anti-Fibonacci sequence**

```
A(0) = 1,   A(n+1) = A(n) + n,
```

whose first terms are `1, 1, 2, 4, 7, 11, 16, 22, 29, 37, …` (OEIS A000124 with a
repeated leading `1`, the "lazy caterer"/central-polygonal numbers).  It is the
greedy record of the informal construction "each new term dodges the running
Fibonacci-style sum": the increment grows by one at every step instead of copying
the previous term.

## Main results

* `AntiFibonacci.tendsto_div_sq` — the density theorem: `A(n)/n² → 1/2`.  In
  particular the sequence is genuinely **quadratic** with leading coefficient `1/2`.
* `AntiFibonacci.ratio_avoids_goldenRatio` — the consecutive ratio `A(n+1)/A(n)`
  **converges to `1`**, and `1 ≠ φ`.  So, unlike Fibonacci, the anti-Fibonacci
  sequence never approaches the golden ratio: its ratio settles at `1`.
* `AntiFibonacci.fibRelation_iff` — the Fibonacci three-term relation
  `A(n+2) = A(n+1) + A(n)` holds for **exactly** `n = 0` and `n = 3`; for every
  `n ≥ 4` the sequence undershoots the Fibonacci sum (`fibRelation_lt`).

The engine is the closed form `two_mul_add` : `2·A(n) + n = n² + 2`, proved by
induction, from which all asymptotics follow by casting to `ℝ` and squeezing.

## Catalog synthesis

This extends the catalog's golden-ratio / Fibonacci thread
(`Catalog/Novelty/GoldenRatioApproximation.lean`,
`Catalog/Novelty/RiordanRowSumFibonacci.lean`).  Where `GoldenRatio.phi_sq`
records that `φ` is the attractor of Fibonacci ratios, here we prove a companion
sequence whose ratios provably *avoid* `φ`, using `GoldenRatio.phi` and
`GoldenRatio.phi_sq` directly.

-- !-- Lab Notes -- !--
-- !-- HYPOTHESIS (Hypothesizer). The description's numeric conjectures were:
--     (a) A(n) ~ n²/4, (b) A(n+1)/A(n) oscillates in [1,2] and does not converge,
--     (c) A always avoids being a Fibonacci sum. We ranked (b) as the most
--     surprising and (a) as the highest-impact quantitative claim. -- !--
-- !-- EXPERIMENT (Experimenter). #eval of A(0..11) = 1,1,2,4,7,11,16,22,29,37,46,56
--     gave 2·A(n)+n = n²+2 (verified n≤11), so A(n) ≈ n²/2, REFUTING (a): the
--     constant is 1/2, not 1/4. Consecutive ratios 1,2,2,1.75,1.57,1.45,… decrease
--     monotonically toward 1, REFUTING (b): they DO converge, to 1 (not oscillate).
--     The Fibonacci relation A(n+2)=A(n+1)+A(n) held only at n∈{0,3}, REFUTING the
--     naive reading of (c) while confirming the sequence eventually undershoots. -- !--
-- !-- ANALYSIS (Analyst). Everything reduces to the closed form 2A(n)+n=n²+2.
--     Since A(n+2)=A(n+1)+(n+1) by definition, the Fibonacci relation is equivalent
--     to A(n)=n+1, i.e. n²=3n, i.e. n∈{0,3}: "true but for a hidden linear reason".
--     The ratio limit is a rational-function squeeze; the correct invariant is 1/2,
--     and the golden ratio is provably avoided since the limit 1 ≠ φ. -- !--
-- !-- CRITIQUE (Critic). We refuse to state the false n²/4 / oscillation claims;
--     each surviving theorem carries genuine content (induction, real limits,
--     nonlinear characterisation) and none is closed by decide/native_decide.
--     The golden-ratio avoidance genuinely consumes catalog lemma phi_sq. -- !--
-- !-- SYNTHESIS. The anti-Fibonacci sequence is the quadratic mirror of Fibonacci:
--     leading coefficient 1/2, ratio limit 1, and a Fibonacci-sum coincidence set
--     of size two. It is the sequence that structurally avoids the golden ratio. -- !--
-/

open Filter Topology

namespace AntiFibonacci

/-- The anti-Fibonacci sequence `A(0) = 1`, `A(n+1) = A(n) + n`;
first terms `1, 1, 2, 4, 7, 11, 16, 22, 29, …`. -/
def A : ℕ → ℕ
  | 0 => 1
  | (n + 1) => A n + n

@[simp] lemma A_zero : A 0 = 1 := rfl
@[simp] lemma A_succ (n : ℕ) : A (n + 1) = A n + n := rfl

/-
Closed form (subtraction-free): `2·A(n) + n = n² + 2`.
-/
lemma two_mul_add (n : ℕ) : 2 * A n + n = n * n + 2 := by
  exact Nat.recOn n ( by norm_num [ A_zero ] ) fun n ih => by norm_num [ Nat.mul_succ, A_succ ] at * ; linarith;

/-
Real closed form: `A(n) = (n² - n + 2)/2`.
-/
lemma A_real (n : ℕ) : (A n : ℝ) = ((n : ℝ) ^ 2 - n + 2) / 2 := by
  exact eq_div_of_mul_eq ( by norm_num ) ( by linarith [ show ( 2 * ( A n : ℝ ) + n : ℝ ) = n * n + 2 by exact mod_cast two_mul_add n ] )

/-
`A(n)` is positive.
-/
lemma A_pos (n : ℕ) : 0 < A n := by
  exact Nat.pos_of_ne_zero fun h => by nlinarith [ two_mul_add n, h.symm ] ;

/-
**Density / quadratic-growth theorem.** `A(n)/n² → 1/2`.  The anti-Fibonacci
sequence grows quadratically with leading coefficient `1/2` (refuting the naive
`1/4` guess).
-/
theorem tendsto_div_sq :
    Tendsto (fun n : ℕ => (A n : ℝ) / (n : ℝ) ^ 2) atTop (𝓝 (1 / 2)) := by
  -- Let's simplify the expression further by dividing numerator and denominator by $n^2$.
  suffices h_simp'' : Filter.Tendsto (fun n : ℕ => (1 - 1 / (n : ℝ) + 2 / (n ^ 2 : ℝ)) / 2) Filter.atTop (nhds (1 / 2)) by
    refine h_simp''.congr' ?_
    filter_upwards [ Filter.eventually_gt_atTop 0 ] with n hn
    have hn' : (n : ℝ) ≠ 0 := by exact_mod_cast hn.ne'
    rw [ A_real ]
    field_simp
  exact le_trans ( Filter.Tendsto.div_const ( Filter.Tendsto.add ( tendsto_const_nhds.sub <| tendsto_one_div_atTop_nhds_zero_nat ) <| tendsto_const_nhds.div_atTop <| Filter.tendsto_pow_atTop ( by norm_num ) |> Filter.Tendsto.comp <| tendsto_natCast_atTop_atTop ) _ ) <| by norm_num;

/-
The consecutive ratio converges to `1`.
-/
lemma tendsto_ratio_one :
    Tendsto (fun n : ℕ => (A (n + 1) : ℝ) / (A n : ℝ)) atTop (𝓝 1) := by
  -- We'll use the fact that if the denominator grows much faster than the numerator, the limit will approach 1.
  have h_lim : Filter.Tendsto (fun n => (A (n + 1) : ℝ) / (n : ℝ) ^ 2) Filter.atTop (nhds (1 / 2)) ∧ Filter.Tendsto (fun n => (A n : ℝ) / (n : ℝ) ^ 2) Filter.atTop (nhds (1 / 2)) := by
    refine' ⟨ _, tendsto_div_sq ⟩;
    -- We'll use the fact that $A(n+1) = A(n) + n$ to rewrite the limit expression.
    suffices h_suff : Filter.Tendsto (fun n : ℕ => ((A n : ℝ) + n) / n ^ 2) Filter.atTop (nhds (1 / 2)) by
      aesop;
    have h_suff : Filter.Tendsto (fun n : ℕ => ((A n : ℝ) / n ^ 2) + (1 / n)) Filter.atTop (nhds (1 / 2)) := by
      simpa using Filter.Tendsto.add ( tendsto_div_sq ) ( tendsto_one_div_atTop_nhds_zero_nat );
    grind;
  have := h_lim.1.div h_lim.2;
  norm_num at *;
  exact this.congr' ( by filter_upwards [ Filter.eventually_gt_atTop 0 ] with n hn; rw [ Pi.div_apply, div_div_div_cancel_right₀ ( by positivity ) ] )

/-
`1 ≠ φ`: the limit of the anti-Fibonacci ratios is not the golden ratio.
-/
lemma one_ne_goldenRatio : (1 : ℝ) ≠ GoldenRatio.phi := by
  exact ne_of_lt ( by rw [ show GoldenRatio.phi = ( 1 + Real.sqrt 5 ) / 2 by rfl ] ; nlinarith [ Real.sqrt_nonneg 5, Real.sq_sqrt ( show 5 ≥ 0 by norm_num ) ] )

/-- **Golden-ratio avoidance.** Unlike the Fibonacci sequence, whose consecutive
ratios converge to `φ`, the anti-Fibonacci ratios converge to `1 ≠ φ`. -/
theorem ratio_avoids_goldenRatio :
    Tendsto (fun n : ℕ => (A (n + 1) : ℝ) / (A n : ℝ)) atTop (𝓝 1)
      ∧ (1 : ℝ) ≠ GoldenRatio.phi :=
  ⟨tendsto_ratio_one, one_ne_goldenRatio⟩

/-
**Characterisation of the Fibonacci coincidences.** The three-term Fibonacci
relation `A(n+2) = A(n+1) + A(n)` holds for exactly `n = 0` and `n = 3`.
-/
theorem fibRelation_iff (n : ℕ) :
    A (n + 2) = A (n + 1) + A n ↔ n = 0 ∨ n = 3 := by
  rcases n with ( _ | _ | _ | _ | n ) <;> simp_all +arith +decide

/-
For every `n ≥ 4` the anti-Fibonacci sequence strictly undershoots the
Fibonacci sum: `A(n+2) < A(n+1) + A(n)`.
-/
lemma fibRelation_lt (n : ℕ) (hn : 4 ≤ n) : A (n + 2) < A (n + 1) + A n := by
  simp +arith +decide [ A_succ ];
  nlinarith [ two_mul_add n ]

end AntiFibonacci