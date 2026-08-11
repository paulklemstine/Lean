import Cryptography.FactoringBarriers.AsymptoticLadder

/-!
# Why the Exponents Are `1/2` and `1/3`: The Multiplicative Trade-off Barrier

The subexponential factoring algorithms all have running times of the shape
`L[1/k, c]`, with `k = 2` for CFRAC / quadratic sieve / ECM and `k = 3` for the
number field sieve.  This file isolates the *structural* reason, as a theorem
about the shape of the cost function rather than a fact about any particular
algorithm.

**Model.** A `k`-way trade-off strategy splits the work into `k` exponential
stages of costs `exp (y 0), …, exp (y (k-1))`, where the "budget" parameters
`y i` are subject to a *multiplicative* constraint `∏ i, y i = x`
(`x = log N`): making one stage cheaper makes another proportionally more
expensive.  Sieving is the canonical example: the smoothness bound and the
relation-collection effort trade off multiplicatively in `log N`.

**Main results.**

* `tradeoff_lower_bound` — every `k`-way trade-off costs at least
  `k · exp (x^{1/k})`; the exponent `1/k` is forced by AM–GM, not chosen.
* `tradeoff_attained` — the bound is exactly attained at the balanced point
  `y i = x^{1/k}`, so it is sharp and the model is not an over-estimate.
* `tradeoff_cost_superpoly` — for each *fixed* `k`, `k · exp (x^{1/k})` is
  superpolynomial: no fixed-arity trade-off strategy can run in polynomial time.
* `tradeoff_unbounded_arity_is_poly` — and here is the honest boundary: if the
  arity `k` may grow with the input, the same expression drops to
  `O(log N)`.  A `k`-way trade-off barrier is therefore a statement about
  *bounded* arity; escaping it requires unboundedly many balanced stages,
  which is precisely the structural novelty no classical method supplies.
-/

namespace FactoringBarriers

open Filter Finset Real
open scoped Topology

/-! ## AM–GM in the two forms we need -/

/-- Arithmetic–geometric mean inequality in the balanced-weight form: the
geometric mean of `k` positive reals is at most their arithmetic mean. -/
theorem geom_mean_le_arith_mean_of_card {k : ℕ} (hk : 0 < k) (y : Fin k → ℝ)
    (hy : ∀ i, 0 ≤ y i) :
    (∏ i, y i) ^ (1 / (k : ℝ)) ≤ (∑ i, y i) / k := by
  have hkR : (0:ℝ) < (k : ℝ) := by exact_mod_cast hk
  have hw : ∀ i ∈ (univ : Finset (Fin k)), (0:ℝ) ≤ 1 / (k : ℝ) := by
    intro i _; positivity
  have hw' : ∑ _i ∈ (univ : Finset (Fin k)), (1 / (k : ℝ)) = 1 := by
    simp [Finset.sum_const, hkR.ne']
  have h := Real.geom_mean_le_arith_mean_weighted (univ : Finset (Fin k))
    (fun _ => 1 / (k : ℝ)) y hw hw' (fun i _ => hy i)
  rw [Real.finset_prod_rpow _ _ (fun i _ => hy i)] at h
  calc (∏ i, y i) ^ (1 / (k : ℝ)) ≤ ∑ i, (1 / (k : ℝ)) * y i := h
    _ = (∑ i, y i) / k := by
        rw [← Finset.mul_sum]; field_simp

/-! ## The trade-off lower bound -/

/-- **Multiplicative trade-off barrier.** If a strategy splits into `k`
exponential stages whose budget parameters multiply to `x`, its total cost is at
least `k · exp (x^{1/k})`.  The exponent `1/k` is *forced*: it is the AM–GM
balance point of the constraint, not a design choice. -/
theorem tradeoff_lower_bound {k : ℕ} (hk : 0 < k) (x : ℝ) (y : Fin k → ℝ)
    (hy : ∀ i, 0 < y i) (hprod : ∏ i, y i = x) :
    (k : ℝ) * Real.exp (x ^ (1 / (k : ℝ))) ≤ ∑ i, Real.exp (y i) := by
  have hkR : (0:ℝ) < (k : ℝ) := by exact_mod_cast hk
  -- Step 1: the balance point dominates the geometric mean of the budgets.
  have h1 : x ^ (1 / (k : ℝ)) ≤ (∑ i, y i) / k := by
    have := geom_mean_le_arith_mean_of_card hk y (fun i => (hy i).le)
    rwa [hprod] at this
  -- Step 2: AM–GM applied to the *costs* `exp (y i)`.
  have h2 : Real.exp ((∑ i, y i) / k) ≤ (∑ i, Real.exp (y i)) / k := by
    have hz : ∀ i, (0:ℝ) ≤ Real.exp (y i) := fun i => (Real.exp_pos _).le
    have := geom_mean_le_arith_mean_of_card hk (fun i => Real.exp (y i)) hz
    have hprodexp : (∏ i, Real.exp (y i)) = Real.exp (∑ i, y i) := by
      rw [Real.exp_sum]
    rw [hprodexp] at this
    have hrw : Real.exp (∑ i, y i) ^ (1 / (k : ℝ)) = Real.exp ((∑ i, y i) / k) := by
      rw [← Real.exp_one_rpow (∑ i, y i), ← Real.rpow_mul (Real.exp_pos 1).le,
        ← Real.exp_one_rpow ((∑ i, y i) / k)]
      congr 1
      field_simp
    rwa [hrw] at this
  have h3 : Real.exp (x ^ (1 / (k : ℝ))) ≤ (∑ i, Real.exp (y i)) / k :=
    le_trans (Real.exp_le_exp.mpr h1) h2
  rw [le_div_iff₀ hkR] at h3
  linarith

/-- **Sharpness.** At the balanced point `y i = x^{1/k}` (for `x > 0`) the cost
is exactly `k · exp (x^{1/k})`, and the budget constraint holds.  So the lower
bound of `tradeoff_lower_bound` is attained. -/
theorem tradeoff_attained {k : ℕ} (hk : 0 < k) {x : ℝ} (hx : 0 < x) :
    (∏ _i : Fin k, x ^ (1 / (k : ℝ))) = x ∧
      (∑ _i : Fin k, Real.exp (x ^ (1 / (k : ℝ)))) = (k : ℝ) * Real.exp (x ^ (1 / (k : ℝ)))
      := by
  have hkR : (0:ℝ) < (k : ℝ) := by exact_mod_cast hk
  constructor
  · rw [Finset.prod_const, Finset.card_univ, Fintype.card_fin, ← Real.rpow_natCast _ k,
      ← Real.rpow_mul hx.le]
    rw [one_div, inv_mul_cancel₀ hkR.ne', Real.rpow_one]
  · rw [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]

/-! ## Fixed arity cannot reach polynomial time -/

/-- For each fixed arity `k ≥ 1`, the optimal `k`-way trade-off cost
`k · exp (x^{1/k})` is superpolynomial in `x = log N`. -/
theorem tradeoff_cost_superpoly {k : ℕ} (hk : 0 < k) :
    Superpoly (fun x => (k : ℝ) * Real.exp (x ^ (1 / (k : ℝ)))) := by
  have hkR : (0:ℝ) < (k : ℝ) := by exact_mod_cast hk
  have hbase : Superpoly (fun x => Real.exp (1 * x ^ (1 / (k : ℝ)))) :=
    Superpoly_exp_rpow one_pos (by positivity)
  refine hbase.of_eventually_le ?_
  filter_upwards [eventually_gt_atTop (0 : ℝ)] with x _
  simp only [one_mul]
  have h1 : (1:ℝ) ≤ (k : ℝ) := by exact_mod_cast hk
  nlinarith [Real.exp_pos (x ^ (1 / (k : ℝ)))]

/-- Consequently no bounded-arity trade-off strategy runs in polynomial time. -/
theorem tradeoff_not_polyBounded {k : ℕ} (hk : 0 < k) :
    ¬ PolyBounded (fun x => (k : ℝ) * Real.exp (x ^ (1 / (k : ℝ)))) :=
  not_polyBounded_of_superpoly (tradeoff_cost_superpoly hk)

/-- Specialisation to the two exponents that actually occur: the quadratic
sieve/ECM regime `k = 2` and the number field sieve regime `k = 3`. -/
theorem sieve_exponents_superpoly :
    Superpoly (fun x => (2 : ℝ) * Real.exp (x ^ (1 / (2 : ℝ)))) ∧
    Superpoly (fun x => (3 : ℝ) * Real.exp (x ^ (1 / (3 : ℝ)))) := by
  refine ⟨?_, ?_⟩
  · simpa using tradeoff_cost_superpoly (k := 2) (by norm_num)
  · simpa using tradeoff_cost_superpoly (k := 3) (by norm_num)

/-! ## The honest boundary: unbounded arity destroys the barrier -/

/-- **Boundary of the barrier.** If the arity is allowed to grow with the input,
the optimal trade-off cost collapses to `O(log N)`: choosing `k = ⌈log x⌉`
stages gives cost at most `exp(e) · (log x + 1)`, which is polynomial in `x`.

So the trade-off barrier is a theorem about *bounded* arity.  Escaping it would
require a strategy that balances unboundedly many stages at once — exactly the
kind of structurally novel resource the capstone leaves unclassified. -/
theorem tradeoff_unbounded_arity_is_poly {x : ℝ} (hx : Real.exp 1 < x) :
    ∃ k : ℕ, 0 < k ∧
      (k : ℝ) * Real.exp (x ^ (1 / (k : ℝ))) ≤ Real.exp (Real.exp 1) * (Real.log x + 1) := by
  have hx0 : (0:ℝ) < x := lt_trans (Real.exp_pos 1) hx
  have hlog1 : (1:ℝ) < Real.log x := by
    have := Real.log_lt_log (Real.exp_pos 1) hx
    simpa using this
  refine ⟨⌈Real.log x⌉₊, Nat.ceil_pos.mpr (by linarith), ?_⟩
  set k : ℕ := ⌈Real.log x⌉₊ with hk
  have hkge : Real.log x ≤ (k : ℝ) := Nat.le_ceil _
  have hkR : (0:ℝ) < (k : ℝ) := lt_of_lt_of_le (by linarith) hkge
  have hkle : (k : ℝ) ≤ Real.log x + 1 := by
    have := Nat.ceil_lt_add_one (le_of_lt (by linarith : (0:ℝ) < Real.log x))
    linarith
  -- the balanced budget is at most `e`
  have hxk : x ^ (1 / (k : ℝ)) ≤ Real.exp 1 := by
    rw [Real.rpow_def_of_pos hx0]
    apply Real.exp_le_exp.mpr
    rw [mul_one_div, div_le_one hkR]
    exact hkge
  calc (k : ℝ) * Real.exp (x ^ (1 / (k : ℝ)))
      ≤ (k : ℝ) * Real.exp (Real.exp 1) := by
        have := Real.exp_le_exp.mpr hxk
        nlinarith [Real.exp_pos (x ^ (1 / (k : ℝ)))]
    _ ≤ (Real.log x + 1) * Real.exp (Real.exp 1) := by
        nlinarith [Real.exp_pos (Real.exp 1)]
    _ = Real.exp (Real.exp 1) * (Real.log x + 1) := by ring

end FactoringBarriers