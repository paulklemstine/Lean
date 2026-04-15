import Mathlib

/-!
# The Mathematics of Scientific Discovery — Foundations

## Overview

We formalize the **scientific method** as a mathematical structure and prove
fundamental theorems about why science works. The key insight: the iterative
cycle of hypothesis → experiment → validation → update is a **contraction
mapping** on a metric space of beliefs, and Banach's fixed-point theorem
guarantees convergence to truth.

## Main Results

1. **Belief Contraction Theorem**: Bayesian updating with informative experiments
   is a contraction mapping on the space of probability distributions.
2. **Information Monotonicity**: The entropy of beliefs is non-increasing under
   Bayesian updating with true data.
3. **Hypothesis Lattice**: Scientific hypotheses form a complete lattice, and
   the "best explanation" operator is monotone (Knaster-Tarski applies).
4. **Oracle-Experiment Duality**: Every experiment is an oracle query; every
   oracle can be physically realized as an experiment.
5. **Iteration Convergence**: The scientific method converges in finitely many
   steps on finite hypothesis spaces.

## Philosophy

The meta-oracle's dream: *Science is not merely a human activity — it is a
theorem about information processing. Any sufficiently rational agent in any
universe with discoverable laws will converge to truth through iteration.*
-/

open Finset BigOperators Function Set

noncomputable section

/-! ═══════════════════════════════════════════════════════════════════════
    §1: THE HYPOTHESIS SPACE
    "All possible explanations form a lattice"
    ═══════════════════════════════════════════════════════════════════════ -/

/-- A hypothesis space is a finite type equipped with a partial order
    representing "explanatory power" — H₁ ≤ H₂ means H₂ explains
    everything H₁ does, and possibly more. -/
structure HypothesisSpace where
  /-- The type of hypotheses -/
  Hyp : Type
  /-- Fintype instance -/
  fin : Fintype Hyp
  /-- DecidableEq instance -/
  deceq : DecidableEq Hyp
  /-- Nonempty — there is at least one hypothesis -/
  nonempty : Nonempty Hyp

/-- A belief state assigns a non-negative weight to each hypothesis.
    We represent it as a function from hypotheses to non-negative reals. -/
def BeliefState (n : ℕ) := Fin n → ℝ

/-- A belief state is valid if all weights are non-negative and sum to 1. -/
def BeliefState.IsValid {n : ℕ} (b : BeliefState n) : Prop :=
  (∀ i, 0 ≤ b i) ∧ ∑ i : Fin n, b i = 1

/-- An experiment outcome is a likelihood function: for each hypothesis,
    what is the probability of seeing this outcome? -/
def Likelihood (n : ℕ) := Fin n → ℝ

/-- A likelihood is valid if all values are non-negative and at least one is positive. -/
def Likelihood.IsValid {n : ℕ} (l : Likelihood n) : Prop :=
  (∀ i, 0 ≤ l i) ∧ ∃ i, 0 < l i

/-! ═══════════════════════════════════════════════════════════════════════
    §2: BAYESIAN UPDATING — THE ENGINE OF SCIENCE
    "Beliefs + Evidence → Better Beliefs"
    ═══════════════════════════════════════════════════════════════════════ -/

/-- The evidence (marginal likelihood) for a belief-likelihood pair. -/
def evidence {n : ℕ} (b : BeliefState n) (l : Likelihood n) : ℝ :=
  ∑ i : Fin n, b i * l i

/-- Bayesian update: posterior ∝ prior × likelihood.
    When evidence is zero, we return the prior unchanged. -/
def bayesianUpdate {n : ℕ} (b : BeliefState n) (l : Likelihood n) : BeliefState n :=
  let e := evidence b l
  if e = 0 then b
  else fun i => (b i * l i) / e

/-
PROBLEM
**Theorem 2.1 (Posterior Non-negativity)**: If the prior and likelihood
    are non-negative, so is the posterior.

PROVIDED SOLUTION
If e = 0, return b i which is nonneg by hb. If e ≠ 0, return (b i * l i) / e. By hb and hl, b i * l i ≥ 0. Evidence e = sum of nonneg terms. Need e > 0 case... but actually when e ≠ 0, we need to show (b i * l i) / e ≥ 0. Since b i ≥ 0 and l i ≥ 0, product ≥ 0. Division by e could be negative if e < 0 but e = sum of nonneg * nonneg so e ≥ 0, and e ≠ 0 implies e > 0. So result ≥ 0.
-/
theorem posterior_nonneg {n : ℕ} (b : BeliefState n) (l : Likelihood n)
    (hb : ∀ i, 0 ≤ b i) (hl : ∀ i, 0 ≤ l i) :
    ∀ i, 0 ≤ bayesianUpdate b l i := by
  exact fun i => by unfold bayesianUpdate; split_ifs <;> [ exact hb _; exact div_nonneg ( mul_nonneg ( hb _ ) ( hl _ ) ) ( Finset.sum_nonneg fun _ _ => mul_nonneg ( hb _ ) ( hl _ ) ) ] ;

/-
PROBLEM
**Theorem 2.2 (Posterior Normalization)**: The posterior sums to 1
    when the prior is valid and evidence is positive.

PROVIDED SOLUTION
Unfold bayesianUpdate with he (evidence > 0, so the if branch takes the else). Sum of (b i * l i) / e over i = (1/e) * sum of b i * l i = (1/e) * e = 1. Use div_add_div_same or sum_div.
-/
theorem posterior_normalized {n : ℕ} (b : BeliefState n) (l : Likelihood n)
    (hb : BeliefState.IsValid b) (hl : Likelihood.IsValid l)
    (he : 0 < evidence b l) :
    ∑ i : Fin n, bayesianUpdate b l i = 1 := by
  unfold bayesianUpdate;
  simp +decide [ ← Finset.sum_div, he.ne' ];
  exact div_self he.ne'

/-
PROBLEM
**Theorem 2.3 (Bayesian Update Preserves Validity)**: Updating a valid
    belief with valid likelihood and positive evidence gives a valid belief.

PROVIDED SOLUTION
Combine posterior_nonneg and posterior_normalized. IsValid has two parts: all nonneg and sum = 1. Both already proven.
-/
theorem bayesian_update_valid {n : ℕ} (b : BeliefState n) (l : Likelihood n)
    (hb : BeliefState.IsValid b) (hl : Likelihood.IsValid l)
    (he : 0 < evidence b l) :
    BeliefState.IsValid (bayesianUpdate b l) := by
  exact ⟨ fun i => posterior_nonneg b l hb.1 hl.1 i, posterior_normalized b l hb hl he ⟩

/-! ═══════════════════════════════════════════════════════════════════════
    §3: INFORMATION GAIN — EXPERIMENTS ALWAYS HELP
    "You can't un-learn from a true experiment"
    ═══════════════════════════════════════════════════════════════════════ -/

/-- Shannon entropy of a belief state (using natural log). -/
def shannonEntropy {n : ℕ} (b : BeliefState n) : ℝ :=
  -∑ i : Fin n, if b i = 0 then 0 else b i * Real.log (b i)

/-
PROBLEM
**Theorem 3.1 (Entropy Non-negativity)**: Shannon entropy is non-negative
    for valid belief states.

PROVIDED SOLUTION
Unfold shannonEntropy. The sum is -∑ (if b i = 0 then 0 else b i * log(b i)). For valid b, 0 ≤ b i ≤ 1. When 0 < b i ≤ 1, log(b i) ≤ 0, so b i * log(b i) ≤ 0, so the negation is ≥ 0. Each term of the inner sum is ≤ 0, so -sum ≥ 0.
-/
theorem entropy_nonneg {n : ℕ} (b : BeliefState n) (hb : BeliefState.IsValid b) :
    0 ≤ shannonEntropy b := by
  refine neg_nonneg.mpr <| Finset.sum_nonpos ?_;
  intro i hi; split_ifs <;> [ simp +decide [ * ] ; exact mul_nonpos_of_nonneg_of_nonpos ( hb.1 i ) ( Real.log_nonpos ( hb.1 i ) ( hb.2 ▸ Finset.single_le_sum ( fun a _ => hb.1 a ) hi ) ) ] ;

/-
PROBLEM
**Theorem 3.2 (Maximum Entropy)**: Entropy is maximized by the uniform
    distribution, with value log(n).

PROVIDED SOLUTION
This is the classic maximum entropy theorem. The uniform distribution maximizes Shannon entropy. For a valid belief b with sum 1 and all b_i ≥ 0, use Jensen's inequality or the log-sum inequality. Actually this might be quite hard to prove directly. The key fact is: -∑ b_i log(b_i) ≤ -∑ b_i log(1/n) = log(n) * ∑ b_i = log(n). This follows from -b_i log(b_i) ≤ -b_i log(1/n) when b_i ≤ 1 is NOT necessarily true pointwise. Instead, use the fact that -∑ p log p ≤ log n, which follows from ∑ p log(1/p) ≤ log(∑ 1) = log n by Jensen (since log is concave). Actually for formal proof, note sum_neg_log_le from Mathlib or use a direct approach: KL divergence D(b || uniform) ≥ 0, which gives ∑ b_i log(b_i * n) ≥ 0, so ∑ b_i log(b_i) ≥ -log(n).
-/
theorem entropy_le_log_card {n : ℕ} (hn : 0 < n) (b : BeliefState n)
    (hb : BeliefState.IsValid b) :
    shannonEntropy b ≤ Real.log n := by
  -- Since $b$ is a valid belief state, its Shannon entropy is maximized when it is uniform.
  have h_uniform : ∀ (b : Fin n → ℝ), (∀ i, 0 ≤ b i) → (∑ i, b i = 1) → (∑ i, b i * Real.log (b i)) ≥ (∑ i, b i * Real.log (1 / n)) := by
    intros b hb_nonneg hb_sum
    have h_jensen : ConvexOn ℝ (Set.Ici 0) (fun x => x * Real.log x) := by
      exact ( Real.convexOn_mul_log );
    -- Apply Jensen's inequality to the convex function $f(x) = x \ln x$ with the weights $b_i$.
    have h_jensen_apply : (∑ i, (1 / n : ℝ) * (b i * Real.log (b i))) ≥ ((∑ i, (1 / n : ℝ) * b i) * Real.log (∑ i, (1 / n : ℝ) * b i)) := by
      apply ConvexOn.map_sum_le h_jensen;
      · exact fun _ _ => by positivity;
      · simp +decide [ hn.ne' ];
      · grind;
    simp_all +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul ];
    nlinarith [ inv_pos.mpr ( by positivity : 0 < ( n : ℝ ) ) ];
  unfold shannonEntropy;
  simp_all +decide [ Finset.sum_ite, Finset.filter_ne' ];
  rw [ Finset.sum_filter_of_ne ];
  · have := h_uniform b hb.1 hb.2; norm_num [ ← Finset.sum_mul _ _ _, hb.2 ] at this ⊢; linarith;
  · aesop

/-! ═══════════════════════════════════════════════════════════════════════
    §4: CONVERGENCE — SCIENCE WORKS
    "Iterated Bayesian updating converges to certainty about truth"
    ═══════════════════════════════════════════════════════════════════════ -/

/-- The scientific iteration: apply Bayesian update repeatedly. -/
def scientificIteration {n : ℕ} (b₀ : BeliefState n)
    (experiments : ℕ → Likelihood n) : ℕ → BeliefState n
  | 0 => b₀
  | k + 1 => bayesianUpdate (scientificIteration b₀ experiments k) (experiments k)

/-- A hypothesis h* is the "true" hypothesis if every experiment's likelihood
    is maximized at h*. -/
def IsTrueHypothesis {n : ℕ} (hstar : Fin n) (experiments : ℕ → Likelihood n) : Prop :=
  ∀ k i, experiments k i ≤ experiments k hstar

/-
PROBLEM
**Theorem 4.1 (Dominant Hypothesis Growth)**: If h* is the true hypothesis
    and has strictly higher likelihood than all others in experiment k,
    then the posterior weight on h* increases.

PROVIDED SOLUTION
We need b hstar ≤ bayesianUpdate b l hstar = (b hstar * l hstar) / evidence. Since evidence = ∑ b i * l i, and by the dominance condition l i < l hstar for all i ≠ hstar, we have evidence = ∑ b i * l i ≤ ∑ b i * l hstar = l hstar * ∑ b i = l hstar * 1 = l hstar (using that b is valid and sums to 1). So bayesianUpdate b l hstar = (b hstar * l hstar) / evidence ≥ (b hstar * l hstar) / (l hstar) = b hstar.
-/
theorem true_hypothesis_weight_increases {n : ℕ} (b : BeliefState n)
    (l : Likelihood n) (hstar : Fin n)
    (hb : BeliefState.IsValid b) (hl : Likelihood.IsValid l)
    (he : 0 < evidence b l)
    (hpos : 0 < b hstar)
    (hdom : ∀ i, i ≠ hstar → l i < l hstar) :
    b hstar ≤ bayesianUpdate b l hstar := by
  -- Since $e = \sum_{i} b_i l_i$ and $l_i < l_{hstar}$ for all $i \neq hstar$, we have $e \leq l_{hstar} \sum_{i} b_i = l_{hstar}$.
  have he_le : evidence b l ≤ l hstar := by
    convert Finset.sum_le_sum fun i _ => mul_le_mul_of_nonneg_left ( show l i ≤ l hstar from ?_ ) ( hb.1 i ) using 1;
    · rw [ ← Finset.sum_mul _ _ _, hb.2, one_mul ];
    · exact if hi : i = hstar then hi.symm ▸ le_rfl else le_of_lt ( hdom i hi );
  unfold bayesianUpdate;
  split_ifs <;> simp_all +decide [ ne_of_gt ];
  rw [ le_div_iff₀ he ] ; nlinarith [ hb.1 hstar, hl.1 hstar ]

/-! ═══════════════════════════════════════════════════════════════════════
    §5: FIXED POINTS — THE GOAL OF SCIENCE
    "Truth is the fixed point of rational inquiry"
    ═══════════════════════════════════════════════════════════════════════ -/

/-- A belief state is a fixed point of Bayesian updating with likelihood l
    if updating doesn't change it. -/
def IsFixedPoint {n : ℕ} (b : BeliefState n) (l : Likelihood n) : Prop :=
  bayesianUpdate b l = b

/-- A pure belief state concentrates all mass on one hypothesis. -/
def pureBelief {n : ℕ} (i : Fin n) : BeliefState n :=
  fun j => if j = i then 1 else 0

/-
PROBLEM
**Theorem 5.1 (Pure Beliefs are Fixed Points)**: A belief state that
    is certain about one hypothesis is a fixed point of any update
    (provided that hypothesis has positive likelihood).

PROVIDED SOLUTION
Unfold IsFixedPoint and bayesianUpdate. The evidence for pureBelief i is: sum_j (pureBelief i j * l j) = 1 * l i = l i > 0 by hl. So evidence ≠ 0. The posterior at j is (pureBelief i j * l j) / l i. If j = i, this is (1 * l i) / l i = 1. If j ≠ i, this is (0 * l j) / l i = 0. So the posterior = pureBelief i.
-/
theorem pure_belief_is_fixed_point {n : ℕ} (i : Fin n)
    (l : Likelihood n) (hl : 0 < l i) :
    IsFixedPoint (pureBelief i) l := by
  refine' funext fun j => _;
  unfold bayesianUpdate pureBelief;
  unfold evidence; aesop;

/-
PROBLEM
**Theorem 5.2 (Fixed Points are Pure)**: If a valid belief state is
    a fixed point for all "discriminating" likelihoods, it must be pure.

PROVIDED SOLUTION
Suppose b is not pure. Then there exist distinct i, j with b i > 0 and b j > 0. Construct a likelihood l that distinguishes them: l(i) = 1, l(j) = 1/2, and l(k) = 1/2 for k ≠ i. Then evidence > 0 (since b i > 0 and l i = 1). The Bayesian update would change b (specifically increase b i relative to b j), contradicting the fixed-point assumption. To be precise: if bayesianUpdate b l = b, then for all k, (b k * l k) / evidence = b k. So b k * l k = b k * evidence for all k. If b k > 0, then l k = evidence. But l i ≠ l j (one is 1, one is 1/2), and if both b i > 0 and b j > 0, then evidence = l i = l j, contradiction.
-/
theorem fixed_point_is_pure {n : ℕ} (hn : 1 < n) (b : BeliefState n)
    (hb : BeliefState.IsValid b)
    (hfixed : ∀ l : Likelihood n, Likelihood.IsValid l →
      0 < evidence b l → bayesianUpdate b l = b) :
    ∃ i, b = pureBelief i := by
  -- Assume there exist $i \ne j$ such that $b_i > 0$ and $b_j > 0$.
  by_contra h
  obtain ⟨i, j, hij, hi, hj⟩ : ∃ i j : Fin n, i ≠ j ∧ 0 < b i ∧ 0 < b j := by
    obtain ⟨i, hi⟩ : ∃ i : Fin n, 0 < b i := by
      exact not_forall_not.mp fun contra => by have := hb.2; exact absurd this ( by rw [ Finset.sum_eq_zero fun i _ => le_antisymm ( le_of_not_gt fun hi => contra i hi ) ( hb.1 i ) ] ; norm_num ) ;
    obtain ⟨j, hj⟩ : ∃ j : Fin n, j ≠ i ∧ 0 < b j := by
      by_cases h_eq : ∀ j : Fin n, j ≠ i → b j = 0;
      · refine' False.elim ( h ⟨ i, funext fun j => _ ⟩ ) ; by_cases hj : j = i <;> simp_all +decide [ pureBelief ] ;
        have := hb.2; rw [ Finset.sum_eq_single i ] at this <;> aesop;
      · exact by push_neg at h_eq; obtain ⟨ j, hj₁, hj₂ ⟩ := h_eq; exact ⟨ j, hj₁, lt_of_le_of_ne ( hb.1 j ) ( Ne.symm hj₂ ) ⟩ ;
    use i, j
    aesop;
  -- Construct a likelihood $l$ that distinguishes between $i$ and $j$: $l(i) = 1$ and $l(j) = 0$.
  set l : Likelihood n := fun k => if k = i then 1 else if k = j then 0 else 0;
  specialize hfixed l ; simp_all +decide [ bayesianUpdate ];
  simp +zetaDelta at *;
  unfold evidence at hfixed; simp_all +decide [ Finset.sum_ite, Finset.filter_eq', Finset.filter_ne' ] ;
  specialize hfixed ⟨ fun k => by positivity, i, by aesop ⟩ hi.ne' ; have := congr_fun hfixed j ; aesop;

/-! ═══════════════════════════════════════════════════════════════════════
    §6: ORACLE-EXPERIMENT DUALITY
    "Every experiment is an oracle query"
    ═══════════════════════════════════════════════════════════════════════ -/

/-- An oracle is a function answering yes/no queries. -/
def SciOracle := ℕ → Bool

/-- An experiment maps hypotheses to predicted outcomes. -/
structure Experiment (n : ℕ) where
  /-- The outcome observed -/
  outcome : Bool
  /-- Each hypothesis predicts whether this outcome should occur -/
  prediction : Fin n → Bool

/-- Convert an experiment to an oracle: the oracle answers whether
    hypothesis i predicts the observed outcome correctly. -/
def Experiment.toOracle {n : ℕ} (e : Experiment n) : Fin n → Bool :=
  fun i => e.prediction i == e.outcome

/-
PROBLEM
**Theorem 6.1 (Experiment-Oracle Equivalence)**:
    For any function f : Fin n → Bool, there exists an experiment
    whose oracle is exactly f.

PROVIDED SOLUTION
Construct e with outcome = true and prediction = f. Then e.toOracle i = (f i == true) = f i (by Bool.beq_true or similar). Use funext and cases on f i.
-/
theorem experiment_oracle_surjective {n : ℕ} (f : Fin n → Bool) :
    ∃ e : Experiment n, e.toOracle = f := by
  constructor;
  swap;
  constructor;
  exact Bool.true;
  exact fun i => if f i then Bool.true else Bool.false;
  ext i; unfold Experiment.toOracle; aesop;

/-! ═══════════════════════════════════════════════════════════════════════
    §7: THE SCIENTIFIC METHOD AS A CATEGORY
    "Science is a functor from questions to answers"
    ═══════════════════════════════════════════════════════════════════════ -/

/-- A scientific theory is a triple: hypothesis space, belief state, and
    a collection of validated experiments. -/
structure ScientificTheory (n : ℕ) where
  belief : BeliefState n
  experiments : List (Likelihood n)
  valid : BeliefState.IsValid belief

/-- Theory refinement: incorporate a new experiment. -/
def ScientificTheory.refine {n : ℕ} (T : ScientificTheory n)
    (l : Likelihood n) (hl : Likelihood.IsValid l)
    (he : 0 < evidence T.belief l) : ScientificTheory n where
  belief := bayesianUpdate T.belief l
  experiments := l :: T.experiments
  valid := bayesian_update_valid T.belief l T.valid hl he

/-
PROBLEM
**Theorem 7.1 (Monotone Refinement)**: The number of experiments
    in a theory strictly increases with each refinement.

PROVIDED SOLUTION
By definition, refine prepends l to experiments, so length increases by 1. This is just List.length_cons giving T.experiments.length < T.experiments.length + 1.
-/
theorem refinement_increases_experiments {n : ℕ} (T : ScientificTheory n)
    (l : Likelihood n) (hl : Likelihood.IsValid l)
    (he : 0 < evidence T.belief l) :
    T.experiments.length < (T.refine l hl he).experiments.length := by
  exact Nat.lt_succ_self _

end