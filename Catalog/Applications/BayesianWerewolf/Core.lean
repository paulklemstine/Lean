import Mathlib
import Applications.IsingModel.Model

/-!
# Bayesian decisions in social-deduction games

This study separates a valid local principle from a commonly asserted global one.  Given a
finite posterior distribution, eliminating a maximum-a-posteriori suspect maximizes the
probability that the day's elimination is correct.  The same action maximizes eventual win
probability only under an additional symmetry assumption: the continuation value must depend
on whether the elimination was correct, but not on the identity selected.

The results also identify the posterior's centered score `2p-1` with an Ising spin.  Bayesian
complementation becomes global spin flip, providing a bridge between finite decision theory
and the symmetry language of statistical mechanics.
-/

open scoped BigOperators
open Finset

namespace BayesianWerewolf

variable {ι E : Type*} [Fintype ι]

/-- Unnormalised Bayesian weight of a role hypothesis after observing evidence. -/
def bayesWeight (prior likelihood : ι → ℝ) (i : ι) : ℝ := prior i * likelihood i

/-- Total evidence mass in a finite Bayesian model. -/
noncomputable def evidenceMass (prior likelihood : ι → ℝ) : ℝ :=
  ∑ i, bayesWeight prior likelihood i

/-- The posterior obtained by normalising prior-times-likelihood weights. -/
noncomputable def posterior (prior likelihood : ι → ℝ) (i : ι) : ℝ :=
  bayesWeight prior likelihood i / evidenceMass prior likelihood

/-- A suspect is maximum-a-posteriori (MAP) when no posterior coordinate is larger. -/
def IsMAP (p : ι → ℝ) (a : ι) : Prop := ∀ i, p i ≤ p a

/-
Finite Bayesian normalisation: posterior probabilities sum to one.
-/
theorem posterior_sum_one (prior likelihood : ι → ℝ)
    (hmass : evidenceMass prior likelihood ≠ 0) :
    ∑ i, posterior prior likelihood i = 1 := by
  unfold posterior evidenceMass;
  rw [ ← Finset.sum_div, div_self ] ; simp_all +decide [ evidenceMass ]

/-
With positive evidence mass, posterior ordering is exactly ordering by
prior-times-likelihood score.
-/
theorem posterior_le_iff_weight_le (prior likelihood : ι → ℝ)
    (hmass : 0 < evidenceMass prior likelihood) (i j : ι) :
    posterior prior likelihood i ≤ posterior prior likelihood j ↔
      bayesWeight prior likelihood i ≤ bayesWeight prior likelihood j := by
  rw [ posterior, posterior, div_le_div_iff_of_pos_right hmass ]

/-
Every nonempty finite suspect set has a MAP action.
-/
theorem exists_map [Nonempty ι] (p : ι → ℝ) : ∃ a, IsMAP p a := by
  exact Finset.exists_max_image Finset.univ p ( Finset.univ_nonempty ) |> fun ⟨ a, ha ⟩ => ⟨ a, fun i => ha.2 i ( Finset.mem_univ i ) ⟩

variable [DecidableEq ι]

/-- Utility of eliminating `a` when the hidden werewolf is `w`. -/
def correctnessUtility (a w : ι) : ℝ := if a = w then 1 else 0

/-- Expected utility under a finite posterior. -/
noncomputable def expectedUtility (p : ι → ℝ) (u : ι → ι → ℝ) (a : ι) : ℝ :=
  ∑ w, p w * u a w

/-
The expected correctness of eliminating a suspect is exactly that suspect's posterior.
-/
theorem expected_correctness (p : ι → ℝ) (a : ι) :
    expectedUtility p correctnessUtility a = p a := by
  unfold expectedUtility; simp +decide [ correctnessUtility ] ;

/-
**Local MAP optimality.** A MAP vote maximizes the probability that the current
elimination is correct.
-/
theorem map_maximizes_immediate_correctness (p : ι → ℝ) {a : ι} (ha : IsMAP p a) :
    ∀ b, expectedUtility p correctnessUtility b ≤
      expectedUtility p correctnessUtility a := by
  intro b; exact (by
  rw [ BayesianWerewolf.expected_correctness, BayesianWerewolf.expected_correctness ] ; exact ha b);

/-- A symmetric continuation utility: `good` follows a correct elimination and `bad`
follows an incorrect elimination, independently of the selected identity. -/
def symmetricContinuation (good bad : ℝ) (a w : ι) : ℝ :=
  if a = w then good else bad

/-
Expected symmetric continuation value is affine in the selected posterior coordinate.
-/
theorem expected_symmetricContinuation (p : ι → ℝ) (hsum : ∑ i, p i = 1)
    (good bad : ℝ) (a : ι) :
    expectedUtility p (symmetricContinuation good bad) a =
      bad + (good - bad) * p a := by
  unfold expectedUtility symmetricContinuation; simp +decide [ Finset.sum_add_distrib, Finset.mul_sum, Finset.sum_mul, mul_assoc, mul_comm, mul_left_comm, sub_mul, hsum ] ; ring;
  simp +decide [ Finset.sum_ite, Finset.filter_eq, Finset.filter_ne, hsum ] ; ring;
  rw [ ← Finset.mul_sum _ _ _, hsum, mul_one, neg_add_eq_sub ]

/-
**Guarded global optimality.** If a correct elimination has at least as much continuation
value as an incorrect one and continuation is identity-symmetric, every MAP action maximizes
eventual value.
-/
theorem map_maximizes_symmetric_continuation (p : ι → ℝ) (hsum : ∑ i, p i = 1)
    {good bad : ℝ} (hgb : bad ≤ good) {a : ι} (ha : IsMAP p a) :
    ∀ b, expectedUtility p (symmetricContinuation good bad) b ≤
      expectedUtility p (symmetricContinuation good bad) a := by
  intros b
  have h_eq : expectedUtility p (symmetricContinuation good bad) b = bad + (good - bad) * p b ∧ expectedUtility p (symmetricContinuation good bad) a = bad + (good - bad) * p a := by
    exact ⟨ expected_symmetricContinuation p hsum good bad b, expected_symmetricContinuation p hsum good bad a ⟩;
  nlinarith [ ha b ]

/-
**Posterior-approximation regret.** Under identity-symmetric continuation, replacing an
action by one whose posterior is at most `ε` lower loses at most `(good - bad) ε` in
continuation value.
-/
theorem symmetric_continuation_regret_bound (p : ι → ℝ) (hsum : ∑ i, p i = 1)
    {good bad ε : ℝ} (hgb : bad ≤ good) {a b : ι} (hb : p a ≤ p b + ε) :
    expectedUtility p (symmetricContinuation good bad) a -
        expectedUtility p (symmetricContinuation good bad) b ≤
      (good - bad) * ε := by
  rw [BayesianWerewolf.expected_symmetricContinuation p hsum good bad a,
    BayesianWerewolf.expected_symmetricContinuation p hsum good bad b]
  nlinarith

/-- Centered posterior score, interpreted as the mean of a `±1` role spin. -/
def spinScore (p : ℝ) : ℝ := 2 * p - 1

/-
Centering preserves posterior order, so MAP voting is equivalently maximum-spin voting.
-/
theorem spinScore_le_iff (p q : ℝ) : spinScore p ≤ spinScore q ↔ p ≤ q := by
  unfold spinScore; constructor <;> intro h <;> linarith;

/-
Complementing a role probability is exactly global Ising spin flip.
-/
theorem spinScore_complement (p : ℝ) : spinScore (1 - p) = -spinScore p := by
  unfold spinScore; ring;

/-
On any finite Ising lattice, a constant Bayesian spin field has magnetization equal to
lattice size times centered posterior score.
-/
theorem constant_spin_magnetization (m n : ℕ) (p : ℝ) :
    Ising.magnetization (fun _ : Ising.Site m n => spinScore p) =
      ((m + 1) * (n + 1) : ℝ) * spinScore p := by
  norm_num [ Ising.magnetization ]

/-
Bayesian complementation and Ising global spin flip induce the same magnetization
transformation.  This explicitly links role-label symmetry to spin symmetry.
-/
theorem posterior_complement_magnetization_flip (m n : ℕ) (p : ℝ) :
    Ising.magnetization (fun _ : Ising.Site m n => spinScore (1 - p)) =
      -Ising.magnetization (fun _ : Ising.Site m n => spinScore p) := by
  convert Ising.magnetization_flip ( fun _ => spinScore p ) using 1;
  exact congr_arg _ ( funext fun _ => by rw [ spinScore_complement ] )

/-
A two-suspect counterexample showing that MAP need not maximize global value when the
reward for a correct elimination depends on identity.  Suspect `0` has posterior `3/5`, but
eliminating suspect `1` has larger expected continuation value because its correct-hit reward
is ten times larger.
-/
theorem map_not_globally_optimal_without_symmetry :
    let p : Fin 2 → ℝ := ![3 / 5, 2 / 5]
    let u : Fin 2 → Fin 2 → ℝ := fun a w =>
      if a = w then (![1 / 10, 1] a) else 0
    IsMAP p 0 ∧ expectedUtility p u 0 < expectedUtility p u 1 := by
  norm_num [ Fin.forall_fin_two, IsMAP, expectedUtility ]

end BayesianWerewolf

-- !-- Lab Notes -- !--
/-
## Lab Notes

**Hypothesis.** Posterior maximization is locally optimal, but it extends to sequential
utility only when continuation rewards are exchangeable across player identities.

**Experiment.** Finite posterior normalization, MAP existence, immediate correctness, and
symmetric continuation utility were separated into independent claims. A two-player model
then tested whether identity-dependent rewards invalidate the global claim.

**Analysis.** Symmetric continuation is affine in the selected posterior coordinate. This
proves exact MAP optimality and a quantitative regret bound for approximate MAP choices.
Centered posterior scores also obey the same complement and magnetization-flip laws as Ising
spins. The identity-dependent example reverses the MAP recommendation.

**Critique.** The positive global result assumes exchangeable continuation values; it does
not establish that strategic Werewolf play has this symmetry. The Ising correspondence is
exact at the one-site and magnetization levels, but correlated role assignments require a
constrained many-spin model.

**Synthesis.** MAP voting is a sound local decision rule and a guarded global rule under
identity symmetry. Approximation error translates linearly into one-step regret, while the
counterexample identifies the precise assumption that cannot be omitted.
-/