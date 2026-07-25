import Mathlib

/-!
# Probability of Consistent Sheaf Imputation

The research conjecture states that the probability a random database can be
consistently filled in (i.e. its local sections glue) is
`P(sheaf) = (1 - r)^{C}` where `r` is the missing/conflict rate and `C` is
the number of *overlapping constraints*.

The honest combinatorial reading: with `k` local feature-subsets (sub-views)
there is one overlap-agreement constraint per *unordered pair* of subsets, so
the number of overlapping constraints is `C = C(k,2) = k.choose 2`. If each
constraint is independently satisfied with probability `1 - r`, the
probability that *all* constraints hold is the product
`(1 - r)^{k.choose 2}` (`sheaf_prob_eq`).

We then make the conjecture's slogan "drops exponentially with the number of
constraints" precise: the probability is antitone in the number of subsets
(`sheaf_prob_antitone`), is dominated by `exp(-r·C(k,2))`
(`sheaf_prob_exp_bound`), and tends to `0` as the database widens
(`sheaf_prob_tendsto_zero`). Since `C(k,2) ~ k²/2`, consistency decays
*super-exponentially* in the number of sub-views — a sharpening of the
conjecture.

-- !-- Lab Notes -- !--
* **Hypothesis (Hypothesizer).** `P(sheaf) = (1-r)^C`. The dubious part is
  the meaning of `C`. Conjecture: `C` is the number of overlap constraints,
  one per pair of local views, i.e. `C = C(k,2)`.
* **Experiment (Experimenter).** Realised the product of independent
  Bernoulli successes as `∏ over (powersetCard 2) (1 - r)` and evaluated it
  to `(1-r)^{k.choose 2}`. Proved the analytic decay statements.
* **Analysis (Analyst).** The exponent is `k.choose 2`, *not* `k` — the
  decay in the number of sub-views is super-exponential, faster than the
  conjecture's naive reading suggests. The "rate" `r` here is the *conflict*
  rate per overlap, which is the right per-constraint quantity, distinct from
  the per-cell missing rate.
* **Critique (Critic).** The exponential bound needs `0 ≤ r ≤ 1` (a genuine
  probability); without `r ≤ 1` the base `1-r` can be negative and the
  monotonicity fails. We carry these hypotheses explicitly. The product law
  itself holds for all real `r` (it is an algebraic identity).
* **Synthesis (PI).** Consistency probability `= (1-r)^{C(k,2)}`, decaying
  super-exponentially; data imputation is governed by the *number of overlap
  constraints*, exactly the sheaf-condition count other methods ignore.
-/

open Classical

namespace SheafImputationProbability

/-- **Exact consistency probability.** Modelling each of the `C(k,2)` overlap
constraints (one per unordered pair of the `k` local views) as an independent
event of probability `1 - r`, the probability that *all* constraints hold is
`(1 - r)^{k.choose 2}`. -/
theorem sheaf_prob_eq (r : ℝ) (k : ℕ) :
    ∏ _p ∈ (Finset.univ : Finset (Fin k)).powersetCard 2, (1 - r)
      = (1 - r) ^ (k.choose 2) := by
  rw [Finset.prod_const, Finset.card_powersetCard, Finset.card_univ,
    Fintype.card_fin]

/-- **Exponential domination.** For a conflict rate `r ≤ 1` (so that the base
`1 - r` is nonnegative), the consistency probability is bounded by
`exp(-r · C(k,2))`, i.e. it decays at least exponentially in the number of
overlap constraints. -/
theorem sheaf_prob_exp_bound (r : ℝ) (k : ℕ) (h1 : r ≤ 1) :
    (1 - r) ^ (k.choose 2) ≤ Real.exp (-(r * (k.choose 2))) := by
  refine le_trans (pow_le_pow_left₀ (by linarith)
    (show 1 - r ≤ Real.exp (-r) by linarith [Real.add_one_le_exp (-r)]) _) ?_
  rw [← Real.exp_nat_mul]; ring_nf; norm_num

/-- **Monotonicity in the number of constraints.** More overlap constraints
never increases the consistency probability. -/
theorem sheaf_prob_antitone {r : ℝ} (h0 : 0 ≤ r) (h1 : r ≤ 1) {m n : ℕ}
    (hmn : m ≤ n) : (1 - r) ^ n ≤ (1 - r) ^ m :=
  pow_le_pow_of_le_one (by linarith) (by linarith) hmn

/-- **Vanishing.** For any positive conflict rate, the probability of global
consistency tends to `0` as the database acquires more sub-views (since the
number of constraints `C(k,2) → ∞`). -/
theorem sheaf_prob_tendsto_zero {r : ℝ} (h0 : 0 < r) (h1 : r ≤ 1) :
    Filter.Tendsto (fun k : ℕ => (1 - r) ^ (k.choose 2))
      Filter.atTop (nhds 0) := by
  refine tendsto_pow_atTop_nhds_zero_of_lt_one ?_ ?_
      |> Filter.Tendsto.comp <| Filter.tendsto_atTop_atTop.mpr ?_
  · linarith
  · linarith
  · intro b; use b + 2; intro a ha; induction ha <;> simp_all +decide [Nat.choose]
    · grind
    · linarith

end SheafImputationProbability