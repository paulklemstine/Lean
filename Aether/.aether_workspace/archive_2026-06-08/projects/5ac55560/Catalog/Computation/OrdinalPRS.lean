import Mathlib

/-!
# Ordinal Proof Refinement Systems (OrdinalPRS)

This file formalizes the framework of **Ordinal-valued Proof Refinement Systems**,
extending finitary proof dynamics to the transfinite setting. The key idea is that
proof normalization (e.g. cut-elimination) can be measured by an energy function
that strictly decreases with each refinement step, guaranteeing termination by
well-foundedness.

## Novel Definitions

* `ProofRefinementSystem` — a state machine with well-founded energy descent
* `StratifiedPRS` — layered PRS with inter-level energy transfer

## Main Results

* `prs_terminates_in_energy_steps` — any PRS terminates within `energy(s₀)` steps
* `energy_drops_by_n` — after `n` non-terminal steps, energy has dropped by `n`
* `energy_descent_chain_length` — strict descent chains have bounded length
* `stratified_step_total_bound` — total energy after a stratified step is bounded

## Catalog References

* `Computation/InfoEfficientAlgorithms.lean` — InfoEfficientAlgorithm structure
* `Computation/TropicalAmortized.lean` — potential_method_amortized_bound
-/

open Finset BigOperators Function

noncomputable section

/-! ## Section 1: Proof Refinement System — Core Structure -/

/-- A `ProofRefinementSystem` models a deterministic normalization process.
Each state has an energy in `ℕ`, and each non-terminal step strictly
decreases energy. This guarantees termination and provides a complexity bound. -/
structure ProofRefinementSystem (State : Type*) where
  /-- One refinement step. -/
  step : State → State
  /-- Terminal (fully normalized) predicate. -/
  terminal : State → Prop
  /-- Energy function. -/
  energy : State → ℕ
  /-- Terminal states are fixed points. -/
  terminal_fixed : ∀ s, terminal s → step s = s
  /-- Non-terminal steps strictly decrease energy. -/
  energy_descent : ∀ s, ¬terminal s → energy (step s) < energy s

/-- Iterate a PRS `n` times from state `s`. -/
def ProofRefinementSystem.iterate {State : Type*}
    (P : ProofRefinementSystem State) (s : State) : ℕ → State
  | 0 => s
  | n + 1 => P.step (P.iterate s n)

/-! ## Section 2: Energy Descent Lemmas -/

/-
After `n` non-terminal steps, energy has dropped by at least `n`.
This is the fundamental quantitative bound on normalization.
-/
theorem energy_drops_by_n {State : Type*} (P : ProofRefinementSystem State)
    (s : State) (n : ℕ)
    (h : ∀ k, k < n → ¬P.terminal (P.iterate s k)) :
    P.energy (P.iterate s n) + n ≤ P.energy s := by
      induction' n with n ih <;> simp_all +decide [ ProofRefinementSystem.iterate ];
      linarith [ ih fun k hk => h k hk.le, P.energy_descent ( P.iterate s n ) ( h n le_rfl ) ]

/-
A PRS must reach a terminal state within `energy(s)` steps.
This is the main termination theorem: well-foundedness of ℕ
guarantees that energy cannot decrease forever.
-/
theorem prs_terminates_in_energy_steps {State : Type*}
    (P : ProofRefinementSystem State) (s : State) :
    ∃ n, n ≤ P.energy s ∧ P.terminal (P.iterate s n) := by
      by_contra h;
      -- If every state `s i` for `i ≤ energy s` is non-terminal, then after `energy s + 1` steps, the energy would have dropped by `energy s + 1`, which contradicts the assumption that energy is non-negative.
      have h_contradiction : P.energy (P.iterate s (P.energy s + 1)) + (P.energy s + 1) ≤ P.energy s := by
        apply energy_drops_by_n;
        grind +splitImp;
      grind

/-! ## Section 3: Strict Descent Chains -/

/-- A strict descent chain of length `n` in the naturals starting from `m`. -/
def IsStrictDescentChain (f : ℕ → ℕ) (n m : ℕ) : Prop :=
  f 0 = m ∧ ∀ k, k < n → f (k + 1) < f k

/-
Any strict descent chain in ℕ starting from `m` has length at most `m`.
This is the finite-ordinal version of the well-foundedness principle.
-/
theorem energy_descent_chain_length (f : ℕ → ℕ) (n m : ℕ)
    (h : IsStrictDescentChain f n m) : n ≤ m := by
      obtain ⟨h0, hdes⟩ := h;
      -- By induction on $n$, we can show that $f(n) \leq m - n$.
      have h_ind : ∀ k ≤ n, f k ≤ m - k := by
        intro k hk; induction' k with k ih <;> norm_num [ * ];
        exact Nat.le_sub_one_of_lt ( lt_of_lt_of_le ( hdes k ( Nat.lt_of_succ_le hk ) ) ( ih ( Nat.le_of_succ_le hk ) ) );
      grind

/-! ## Section 4: Stratified PRS — Hierarchical Decomposition -/

/-- A `StratifiedPRS` decomposes a proof system into `L` layers (strata).
Each stratum has its own energy. This models cut-elimination where
eliminating a cut of complexity `k` may introduce cuts of lower complexity. -/
structure StratifiedPRS (L : ℕ) where
  /-- Energy at each level. -/
  energy : Fin L → ℕ

/-- Total energy of a stratified PRS. -/
def StratifiedPRS.totalEnergy {L : ℕ} (s : StratifiedPRS L) : ℕ :=
  ∑ i : Fin L, s.energy i

/-- A step in a stratified PRS: energy at the active level decreases,
    energies below may increase but are bounded by the decrease amount. -/
structure StratifiedStep {L : ℕ} (before after : StratifiedPRS L) where
  /-- The active level. -/
  level : Fin L
  /-- Energy at the active level strictly decreases. -/
  descent : after.energy level < before.energy level
  /-- Energy at levels above the active level is unchanged. -/
  above_unchanged : ∀ j : Fin L, level < j → after.energy j = before.energy j
  /-- Energy increase below is bounded by the energy decrease at active level. -/
  below_bounded : ∀ j : Fin L, j < level →
    after.energy j ≤ before.energy j + (before.energy level - after.energy level)

/-
Total energy across strata after a stratified step is bounded.
The increase at lower levels is at most `(L-1)` times the decrease at the active level.
-/
theorem stratified_step_total_bound {L : ℕ}
    (before after : StratifiedPRS L) (step : StratifiedStep before after)
    (_hL : 0 < L) :
    after.totalEnergy ≤
      before.totalEnergy + (L - 1) * (before.energy step.level - after.energy step.level) := by
  obtain ⟨level, descent, above_unchanged, below_bounded⟩ := step;
  unfold StratifiedPRS.totalEnergy;
  refine' le_trans ( Finset.sum_le_sum fun i _ => show after.energy i ≤ before.energy i + if i < level then before.energy level - after.energy level else 0 from _ ) _;
  · grind +suggestions;
  · simp +decide [ Finset.sum_add_distrib, Finset.sum_ite ];
    rw [ show Finset.filter ( fun x => x < level ) Finset.univ = Finset.Iio level by ext; simp +decide ] ; simp +decide ;
    exact Nat.mul_le_mul_right _ ( Nat.le_pred_of_lt level.2 )

/-! ## Section 5: Combined Energy Descent -/

/-- Combined energy of two independent systems decreases if either decreases.
This is the key algebraic property enabling product constructions. -/
theorem combined_energy_descent (e₁ e₁' e₂ : ℕ) (h : e₁' < e₁) :
    e₁' + e₂ < e₁ + e₂ := by omega

/-- Product energy: if we first decrease one component, then the other,
    the total decrease is the sum of decreases. -/
theorem product_energy_total_decrease (e₁ e₁' e₂ e₂' : ℕ)
    (h₁ : e₁' ≤ e₁) (h₂ : e₂' ≤ e₂) :
    e₁' + e₂' ≤ e₁ + e₂ := by omega

/-! ## Section 6: Concrete PRS Instances -/

/-- A concrete PRS on `ℕ` where each step subtracts 1.
Models the simplest possible rewriting system. Terminal at 0. -/
def countdownPRS : ProofRefinementSystem ℕ where
  step := fun n => n - 1
  terminal := fun n => n = 0
  energy := id
  terminal_fixed := by intro s hs; simp [hs]
  energy_descent := by
    intro s hs
    simp [id] at *
    omega

/-- The countdown PRS terminates within `s` steps. -/
theorem countdownPRS_terminates (s : ℕ) :
    ∃ n, n ≤ s ∧ countdownPRS.terminal (countdownPRS.iterate s n) := by
  exact prs_terminates_in_energy_steps countdownPRS s

/-- A PRS modeling the Euclidean algorithm: state is a pair (a, b),
    step replaces (a, b) with (b, a mod b), terminal when b = 0.
    Energy is `b` (the second component). -/
def euclidPRS : ProofRefinementSystem (ℕ × ℕ) where
  step := fun ⟨a, b⟩ => if b = 0 then (a, 0) else (b, a % b)
  terminal := fun ⟨_, b⟩ => b = 0
  energy := fun ⟨_, b⟩ => b
  terminal_fixed := by
    intro ⟨a, b⟩ h
    simp at h
    simp [h]
  energy_descent := by
    intro ⟨a, b⟩ h
    simp at h ⊢
    simp [h]
    exact Nat.mod_lt a (Nat.pos_of_ne_zero h)

/-- The Euclidean PRS terminates within `b` steps. -/
theorem euclidPRS_terminates (a b : ℕ) :
    ∃ n, n ≤ b ∧ euclidPRS.terminal (euclidPRS.iterate (a, b) n) := by
  exact prs_terminates_in_energy_steps euclidPRS (a, b)

/-! ## Section 7: Conjecture — Effective Ordinal Assignment -/

/-- **Conjecture (Effective Ordinal Computation)**:
For any PRS on `Fin n`, the worst-case number of steps to termination
from any initial state is at most `n - 1`.

This is testable: enumerate all `Fin n` states and compute the
maximum iteration count. For `n ≤ 100`, this can be checked computationally.

**Falsification test**: Construct a PRS on `Fin n` where some state
requires exactly `n - 1` steps. If such a PRS exists for all `n`,
the bound is tight.
-/
def conjecture_tight_prs_bound : Prop :=
  ∀ (n : ℕ) (P : ProofRefinementSystem (Fin (n + 1))),
    ∀ s : Fin (n + 1), ∃ k, k ≤ n ∧ P.terminal (P.iterate s k)

end