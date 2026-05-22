import Mathlib

/-!
# Tropical Dequantization: Softmin Bounds and Zero-Temperature Limits

This file establishes the mathematical bridge between quantum-inspired sampling (via
partition functions / log-sum-exp) and tropical optimization (via min). The key result
is that the **softmin** function — defined as `-(1/β) * log(∑ exp(-β * E(x)))` —
is sandwiched between the true minimum and the minimum plus a logarithmic correction.

As β → ∞ (the "zero-temperature" or "tropical" limit), softmin converges to the exact
minimum. This formalizes the precise sense in which tropical dequantization recovers
the dominant contribution from quantum-inspired partition function computations.

## Main results

- `softmin_le_min`: The softmin is always ≤ the true minimum.
- `min_sub_log_le_softmin`: The softmin is ≥ min - log(n)/β.
- `finite_softmin_bounds`: Both bounds combined as a conjunction.
- `softmin_sandwich`: Equivalent formulation: `0 ≤ min - softmin ≤ log(n)/β`.

## Mathematical significance

This is a genuine bridge between:
- **Quantum-inspired sampling**: dominated by exponentially weighted amplitudes
- **Statistical mechanics**: partition functions and Gibbs measures
- **Tropical geometry**: zero-temperature / large-deviation limits
- **Optimization**: the min operation as the canonical tropical limit

The tropicalization `β → ∞` recovers the minimum-energy (ground state) selector,
which is exactly the min-plus semiring operation.
-/

noncomputable section

open Finset BigOperators Real

namespace TropicalSoftmin

variable {α : Type} [Fintype α] [Nonempty α]

/-- The softmin function: a smooth approximation to the minimum.
At large β, this converges to the minimum of E. -/
def softmin (E : α → ℝ) (β : ℝ) : ℝ :=
  -(1 / β) * Real.log (∑ x : α, Real.exp (-β * E x))

/-- The Gibbs weight (Boltzmann factor) at inverse temperature β. -/
def gibbsWeight (β : ℝ) (E : α → ℝ) (x : α) : ℝ :=
  Real.exp (-β * E x)

/-- Gibbs weights are always positive. -/
theorem gibbsWeight_pos (β : ℝ) (E : α → ℝ) (x : α) :
    0 < gibbsWeight β E x :=
  Real.exp_pos _

/-- The partition function (sum of Gibbs weights) is positive. -/
theorem partitionFun_pos (β : ℝ) (E : α → ℝ) :
    0 < ∑ x : α, Real.exp (-β * E x) := by
  apply Finset.sum_pos
  · intro x _
    exact Real.exp_pos _
  · exact Finset.univ_nonempty

/-- The minimum of E over the finite type, using Finset.inf'. -/
def minEnergy (E : α → ℝ) : ℝ :=
  Finset.univ.inf' Finset.univ_nonempty E

/-- The minimum energy is achieved by some element. -/
theorem minEnergy_le (E : α → ℝ) (x : α) :
    minEnergy E ≤ E x :=
  Finset.inf'_le _ (Finset.mem_univ x)

/-- There exists an element achieving the minimum energy. -/
theorem exists_minEnergy (E : α → ℝ) :
    ∃ x : α, E x = minEnergy E := by
  obtain ⟨x, _, hx⟩ := Finset.exists_mem_eq_inf' Finset.univ_nonempty E
  exact ⟨x, hx.symm⟩

/-
**Upper bound**: softmin ≤ min(E).

Proof sketch: Since ∑ exp(-β·E(x)) ≥ exp(-β·min(E)) (from the minimizer),
we have log(∑...) ≥ -β·min(E), so -(1/β)·log(∑...) ≤ min(E).
-/
theorem softmin_le_min (E : α → ℝ) (β : ℝ) (hβ : 0 < β) :
    softmin E β ≤ minEnergy E := by
  unfold softmin;
  obtain ⟨ x₀, hx₀ ⟩ := exists_minEnergy E; simp_all +decide [ minEnergy ] ;
  intro x; rw [ neg_le ] ; have := hx₀ ▸ Finset.inf'_le E ( Finset.mem_univ x ) ; simp_all +decide [ Real.exp_pos, hβ.ne' ] ;
  rw [ inv_mul_eq_div, le_div_iff₀' hβ ];
  rw [ Real.le_log_iff_exp_le ( Finset.sum_pos ( fun _ _ => Real.exp_pos _ ) Finset.univ_nonempty ) ] ; exact le_trans ( by norm_num [ ← Real.exp_add, mul_comm β ] ) ( Finset.single_le_sum ( fun a _ => Real.exp_nonneg ( - ( β * E a ) ) ) ( Finset.mem_univ x ) ) ;

/-
**Lower bound**: min(E) - log(card α)/β ≤ softmin.

Proof sketch: Since ∑ exp(-β·E(x)) ≤ card(α)·exp(-β·min(E))
(each term ≤ exp(-β·min(E))), we have log(∑...) ≤ log(card α) - β·min(E),
so -(1/β)·log(∑...) ≥ min(E) - log(card α)/β.
-/
theorem min_sub_log_le_softmin (E : α → ℝ) (β : ℝ) (hβ : 0 < β) :
    minEnergy E - Real.log (Fintype.card α) / β ≤ softmin E β := by
  -- Since $\sum_{x} \exp(-\beta E(x)) \leq \text{card}(\alpha) \exp(-\beta \min(E))$, we have $\log(\sum_{x} \exp(-\beta E(x))) \leq \log(\text{card}(\alpha)) + (-\beta \min(E))$.
  have h_log_sum : Real.log (∑ x, Real.exp (-β * E x)) ≤ Real.log (Fintype.card α) + (-β * minEnergy E) := by
    rw [ Real.log_le_iff_le_exp, Real.exp_add, Real.exp_log ];
    · exact le_trans ( Finset.sum_le_sum fun _ _ => Real.exp_le_exp.mpr <| mul_le_mul_of_nonpos_left ( minEnergy_le E _ ) <| neg_nonpos.mpr hβ.le ) <| by norm_num;
    · exact Nat.cast_pos.mpr Fintype.card_pos;
    · exact Finset.sum_pos ( fun _ _ => Real.exp_pos _ ) Finset.univ_nonempty;
  unfold softmin;
  field_simp;
  norm_num at * ; linarith

/-- **Combined softmin bounds**: the softmin is sandwiched between
min(E) - log(n)/β and min(E). This is the finite combinatorial
substitute for the full zero-temperature convergence theorem. -/
theorem finite_softmin_bounds (E : α → ℝ) (β : ℝ) (hβ : 0 < β) :
    softmin E β ≤ minEnergy E
    ∧ minEnergy E - Real.log (Fintype.card α) / β ≤ softmin E β :=
  ⟨softmin_le_min E β hβ, min_sub_log_le_softmin E β hβ⟩

/-- **Sandwich form**: the gap between min and softmin is non-negative and bounded. -/
theorem softmin_sandwich (E : α → ℝ) (β : ℝ) (hβ : 0 < β) :
    0 ≤ minEnergy E - softmin E β
    ∧ minEnergy E - softmin E β ≤ Real.log (Fintype.card α) / β := by
  constructor
  · linarith [softmin_le_min E β hβ]
  · linarith [min_sub_log_le_softmin E β hβ]

/-
As β → ∞, the softmin converges to the true minimum.
This is the **tropical limit theorem**: tropicalization recovers exact optimization.
-/
theorem softmin_tendsto_min (E : α → ℝ) :
    Filter.Tendsto (softmin E) Filter.atTop (nhds (minEnergy E)) := by
  refine' ( tendsto_order.2 ⟨ fun x => _, fun x hx => _ ⟩ );
  · intro hx;
    -- Since $x < \min E$, we have $\min E - \frac{\log(\text{card} \alpha)}{\beta} > x$ for sufficiently large $\beta$.
    have h_log_card : Filter.Tendsto (fun β => minEnergy E - Real.log (Fintype.card α) / β) Filter.atTop (nhds (minEnergy E)) := by
      exact le_trans ( tendsto_const_nhds.sub ( tendsto_const_nhds.div_atTop Filter.tendsto_id ) ) ( by norm_num );
    filter_upwards [ h_log_card.eventually ( lt_mem_nhds hx ), Filter.eventually_gt_atTop 0 ] with β hβ₁ hβ₂ using by linarith [ min_sub_log_le_softmin E β hβ₂ ] ;
  · exact Filter.eventually_atTop.2 ⟨ 1, fun β hβ => lt_of_le_of_lt ( softmin_le_min _ _ <| by positivity ) hx ⟩

end TropicalSoftmin

end