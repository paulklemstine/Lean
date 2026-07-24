/-
Copyright (c) 2025. All rights reserved.

# Idempotent Large Deviations: the Laplace Principle (Maslov Dequantization)

This file proves the **finite Laplace principle** — the zero-temperature limit that
connects *classical* exponential (Boltzmann/Gibbs) sums to the *idempotent*
(max-plus) integral.  It is the analytic engine behind the idempotent large
deviation principle of `Catalog/Tropical/MeasureTheory/LargeDeviations.lean`.

For a profile `g : X → ℝ` on a finite type, the **scaled log-partition function**
`(1/n)·log ∑ₓ exp(n·g x)` converges, as the inverse temperature `n → ∞`, to the
max-plus integral `supₓ g x`.  Specialising `g(x) = λ·val(x) + w(x)` recovers the
**idempotent cumulant generating function** `idempotentCGF` as a zero-temperature
limit, and `g(x) = φ(x) + w(x)` recovers the **max-plus integral** `maxPlusIntegral`
(the idempotent Varadhan lemma).

## Bridge (Extra Bridge Mandate, v16b)

This file combines two different catalog domains:

* **Idempotent measure theory / LDP** — `Catalog/Tropical/MeasureTheory/Basic.lean`
  and `Catalog/Tropical/MeasureTheory/LargeDeviations.lean` (the objects
  `maxPlusIntegral`, `idempotentCGF`).
* **Neural-network log-sum-exp dequantization** —
  `Catalog/Tropical/NeuralNetworks/NDimLogSumExp.lean` (the soft-max / log-sum-exp
  temperature analysis, in particular `scaled_logsumexp_dequant`).

The new connection: the soft-max (log-sum-exp) operator used in tropical neural
networks is, in the zero-temperature limit, exactly the cumulant generating
function of an idempotent probability measure.  `cgf_dequant_two_point` derives the
two-point quantitative dequantization bound for `idempotentCGF` *directly from* the
neural-network lemma `NDimLogSumExp.scaled_logsumexp_dequant`, while
`idempotentCGF_zero_temp_limit` upgrades it to the full `n`-point limit.

## Main results

* `finite_laplace_principle` — `(1/n) log ∑ exp(n g) → supₓ g` as `n → ∞`.
* `idempotentCGF_zero_temp_limit` — the idempotent CGF as a zero-temperature limit.
* `maxPlusIntegral_zero_temp_limit` — the max-plus integral as a zero-temperature
  limit (idempotent Varadhan lemma).
* `cgf_dequant_two_point` — quantitative two-point bridge to the neural-network
  dequantization lemma.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The idempotent CGF and max-plus integral of the LDP
  development should each be the exact `T → 0` (`n → ∞`) limit of a *classical*
  Boltzmann log-partition function, making the idempotent LDP a genuine
  dequantization of classical statistical mechanics.  Surprising sub-claim: the
  convergence is uniform with an explicit `log(card X)/n` rate, independent of the
  profile `g`, so the dequantization error depends only on the *cardinality* of the
  state space, never on the energies.
Experiment (Experimenter): Sandwiched `∑ₓ exp(n g x)` between `exp(n·max g)` (one
  summand) and `card·exp(n·max g)` (every summand ≤ the max), took logs, divided by
  `n`, and squeezed.  The lower bound gives `max g ≤ (1/n)log∑`, the upper bound
  `(1/n)log∑ ≤ max g + log(card)/n`; `tendsto` follows by the squeeze theorem since
  `log(card)/n → 0`.  For the two-point case the catalog lemma
  `NDimLogSumExp.scaled_logsumexp_dequant` is applied verbatim.
Analysis (Analyst): The conjecture SURVIVES with the predicted `log(card)/n` rate,
  uniform in `g`.  This is why the idempotent LDP is *sharp*: the smoothing error of
  the classical `log/exp` vanishes at the universal rate `log(card)/n`, and the
  max-plus integral is its exact limit.  The two surprising halves (CGF and integral)
  are the *same* theorem instantiated at two profiles.
Critique (Critic): The bounds are non-vacuous (`card ≥ 1`, `log card ≥ 0`), the
  limit uses a real squeeze (not `decide`), and the two-point corollary genuinely
  consumes the neural-network domain result rather than re-deriving it, satisfying
  the bridge mandate.
-- !-- end Lab Notes -- !--
-/

import Mathlib
import Catalog.Tropical.MeasureTheory.Basic
import Catalog.Tropical.MeasureTheory.LargeDeviations
import Catalog.Tropical.NeuralNetworks.NDimLogSumExp

namespace TropicalLDP.Laplace

open TropicalMeasureTheory TropicalLDP Finset Real

variable {X : Type*} [Fintype X] [Nonempty X]

/-- The classical **log-partition function** at inverse temperature `n` for a
profile `g : X → ℝ`: `log ∑ₓ exp(n · g x)`. -/
noncomputable def logPartition (g : X → ℝ) (n : ℕ) : ℝ :=
  Real.log (∑ x, Real.exp ((n : ℝ) * g x))

/-- The **scaled log-partition function** `(1/n)·log ∑ₓ exp(n g x)`: the classical
free energy whose `n → ∞` limit is the max-plus integral. -/
noncomputable def scaledLogPartition (g : X → ℝ) (n : ℕ) : ℝ :=
  (n : ℝ)⁻¹ * logPartition g n

/-
The partition sum is strictly positive.
-/
theorem partition_pos (g : X → ℝ) (n : ℕ) :
    0 < ∑ x, Real.exp ((n : ℝ) * g x) := by
  exact Finset.sum_pos ( fun x _ => Real.exp_pos _ ) Finset.univ_nonempty

/-
**Lower bound**: the max-plus value never exceeds the scaled log-partition
function (`exp(n·max g)` is one of the summands).
-/
theorem sup'_le_scaledLogPartition (g : X → ℝ) {n : ℕ} (hn : 1 ≤ n) :
    Finset.univ.sup' Finset.univ_nonempty g ≤ scaledLogPartition g n := by
  -- By definition of $scaledLogPartition$, we have $scaledLogPartition g n = (n : ℝ)⁻¹ * (Real.log (∑ x, Real.exp ((n : ℝ) * g x)))$.
  unfold scaledLogPartition;
  unfold logPartition; rw [ inv_mul_eq_div, le_div_iff₀ ( by positivity ) ] ;
  convert Real.log_le_log ?_ ( show ∑ x, Real.exp ( n * g x ) ≥ Real.exp ( n * ( univ.sup' Finset.univ_nonempty g ) ) from ?_ ) using 1;
  rw [ Real.log_exp, mul_comm ];
  · positivity;
  · obtain ⟨ x₀, hx₀ ⟩ := Finset.exists_mem_eq_sup' ( Finset.univ_nonempty ) g;
    exact le_trans ( by aesop ) ( Finset.single_le_sum ( fun x _ => Real.exp_nonneg ( n * g x ) ) ( Finset.mem_univ x₀ ) )

/-
**Upper bound** with explicit dequantization rate: the scaled log-partition
function exceeds the max-plus value by at most `log(card X)/n` (every summand is
≤ the maximal one).
-/
theorem scaledLogPartition_le (g : X → ℝ) {n : ℕ} (hn : 1 ≤ n) :
    scaledLogPartition g n ≤
      Finset.univ.sup' Finset.univ_nonempty g
        + Real.log (Fintype.card X) / n := by
  -- Let m = Finset.univ.sup' Finset.univ_nonempty g.
  set m := Finset.univ.sup' Finset.univ_nonempty g;
  -- By definition of $m$, we know that for all $x \in X$, $g x \leq m$.
  have h_le_m : ∀ x, g x ≤ m := by
    exact fun x => Finset.le_sup' ( fun x => g x ) ( Finset.mem_univ x );
  -- Hence $\sum_{x \in X} \exp(n g(x)) \leq \sum_{x \in X} \exp(n m) = |X| \exp(n m)$.
  have h_sum_le : ∑ x, Real.exp ((n : ℝ) * g x) ≤ (Fintype.card X : ℝ) * Real.exp ((n : ℝ) * m) := by
    exact le_trans ( Finset.sum_le_sum fun _ _ => Real.exp_le_exp.mpr ( mul_le_mul_of_nonneg_left ( h_le_m _ ) ( Nat.cast_nonneg _ ) ) ) ( by simp +decide );
  -- Taking the logarithm of both sides of the inequality $\sum_{x \in X} \exp(n g(x)) \leq |X| \exp(n m)$, we get $\log(\sum_{x \in X} \exp(n g(x))) \leq \log(|X| \exp(n m))$.
  have h_log_sum_le : Real.log (∑ x, Real.exp ((n : ℝ) * g x)) ≤ Real.log ((Fintype.card X : ℝ) * Real.exp ((n : ℝ) * m)) := by
    exact Real.log_le_log ( Finset.sum_pos ( fun _ _ => Real.exp_pos _ ) Finset.univ_nonempty ) h_sum_le;
  convert mul_le_mul_of_nonneg_left h_log_sum_le ( inv_nonneg.mpr ( Nat.cast_nonneg n ) ) using 1 ; ring;
  rw [ Real.log_mul ( by positivity ) ( by positivity ), Real.log_exp ] ; ring;
  rw [ mul_assoc, mul_inv_cancel₀ ( by positivity ), mul_one ]

/-
**Finite Laplace principle (Maslov dequantization).**  The scaled
log-partition function converges to the max-plus integral as the inverse
temperature `n → ∞`.
-/
theorem finite_laplace_principle (g : X → ℝ) :
    Filter.Tendsto (fun n => scaledLogPartition g n) Filter.atTop
      (nhds (Finset.univ.sup' Finset.univ_nonempty g)) := by
  refine' ( tendsto_of_tendsto_of_tendsto_of_le_of_le' tendsto_const_nhds _ _ _ );
  refine' fun n => Finset.univ.sup' Finset.univ_nonempty g + Real.log ( Fintype.card X ) / n;
  · exact le_trans ( tendsto_const_nhds.add ( tendsto_const_nhds.div_atTop tendsto_natCast_atTop_atTop ) ) ( by norm_num );
  · filter_upwards [ Filter.eventually_ge_atTop 1 ] with n hn using sup'_le_scaledLogPartition g hn;
  · filter_upwards [ Filter.eventually_ge_atTop 1 ] with n hn using scaledLogPartition_le g hn

/-! ## Dequantization of the idempotent cumulant generating function -/

/-
**Idempotent CGF as a zero-temperature limit.**  The idempotent cumulant
generating function `Λ(λ) = supₓ (λ·val x + w x)` is the `n → ∞` limit of the
classical scaled log-partition function of the same exponents.
-/
theorem idempotentCGF_zero_temp_limit (P : MaxPlusMeasure X) (val : X → ℝ) (lam : ℝ) :
    Filter.Tendsto
      (fun n => scaledLogPartition (fun x => lam * val x + P.weight x) n)
      Filter.atTop (nhds (idempotentCGF P val lam)) := by
  convert finite_laplace_principle ( fun x => lam * val x + P.weight x ) using 1

/-
**Max-plus integral as a zero-temperature limit (idempotent Varadhan lemma).**
The max-plus integral `∫⁺ φ dP = supₓ (φ x + w x)` is the `n → ∞` limit of the
classical scaled log-partition function of the exponents `φ(x) + w(x)`.
-/
theorem maxPlusIntegral_zero_temp_limit (P : MaxPlusMeasure X) (φ : X → ℝ) :
    Filter.Tendsto
      (fun n => scaledLogPartition (fun x => φ x + P.weight x) n)
      Filter.atTop (nhds (maxPlusIntegral φ P)) := by
  convert finite_laplace_principle ( fun x => φ x + P.weight x ) using 1

/-! ## Quantitative two-point bridge to the neural-network dequantization lemma -/

/-
**Two-point dequantization bridge.**  For a two-state profile, the scaled
log-partition function approximates the max-plus value within `log 2 / n`.  This is
proved by *directly invoking* the neural-network catalog lemma
`NDimLogSumExp.scaled_logsumexp_dequant`, exhibiting the soft-max/log-sum-exp
operator of tropical neural networks as the finite-temperature cumulant generating
function of an idempotent law.
-/
theorem cgf_dequant_two_point (g : Fin 2 → ℝ) {n : ℕ} (hn : 1 ≤ n) :
    |scaledLogPartition g n - max (g 0) (g 1)| ≤ Real.log 2 / n := by
  convert NDimLogSumExp.scaled_logsumexp_dequant ( g 0 ) ( g 1 ) n ( by positivity ) using 1 ; norm_num [ scaledLogPartition, logPartition ]

/-
**Bridge theorem.**  For a two-state idempotent law `P` with observable `val`,
the classical scaled log-partition function approximates the *idempotent cumulant
generating function* `idempotentCGF P val λ` within `log 2 / n`.  A single statement
combining the LDP measure-theory domain (the object `idempotentCGF` of
`Catalog/Tropical/MeasureTheory/LargeDeviations.lean`) with the neural-network
dequantization domain (`NDimLogSumExp.scaled_logsumexp_dequant`, consumed through
`cgf_dequant_two_point`): the tropical-network soft-max operator *is* the
finite-temperature idempotent CGF, up to the universal error `log 2 / n`.
-/
theorem idempotentCGF_dequant_two_point (P : MaxPlusMeasure (Fin 2)) (val : Fin 2 → ℝ)
    (lam : ℝ) {n : ℕ} (hn : 1 ≤ n) :
    |scaledLogPartition (fun i => lam * val i + P.weight i) n
        - idempotentCGF P val lam| ≤ Real.log 2 / n := by
  convert cgf_dequant_two_point ( fun i => lam * val i + P.weight i ) hn using 1

end TropicalLDP.Laplace