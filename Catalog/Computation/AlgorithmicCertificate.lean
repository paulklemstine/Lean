import Mathlib

/-!
# Algorithmic Certificates: A Unified Framework

This file formalizes the abstract meta-theorem that unifies binary search, Dijkstra's algorithm,
and NTT/FFT as instances of a single paradigm:

* A **state transition system** with a step function
* An **invariant** preserved by each step
* A **potential function** that strictly decreases on each non-terminal step
* A **semantic extraction** that yields the correct answer at termination

The main theorem `correctness_of_decreasing_potential` shows that any such system
terminates within `potential(init)` steps and produces a correct answer.

This is the formal backbone of the "algorithms as dynamical systems with monotone certificates"
paradigm.
-/

open Function

noncomputable section

/-- An algorithmic certificate bundles a state transition system with
an invariant, a potential function, a termination predicate, and a
specification extraction map. -/
structure AlgorithmicCertificate (State Spec : Type*) where
  /-- The step function advances the state. -/
  step : State → State
  /-- The invariant that must be preserved. -/
  invariant : State → Prop
  /-- The potential / ranking function, a natural number that decreases. -/
  potential : State → ℕ
  /-- Whether the state is terminal (search complete). -/
  terminal : State → Bool
  /-- Extracts the answer from a terminal state. -/
  extract : State → Spec

/-- The specification predicate: what it means for the output to be correct. -/
def CorrectSpec {Spec : Type*} (correctness : Spec → Prop) (s : Spec) : Prop :=
  correctness s

/-- Iterated step function. -/
def AlgorithmicCertificate.iterStep {State Spec : Type*}
    (A : AlgorithmicCertificate State Spec) (n : ℕ) (s : State) : State :=
  A.step^[n] s

/-
The main meta-theorem: any state machine with a preserved invariant,
strictly decreasing potential on non-terminal steps, and correct extraction
at terminal states, terminates within `potential(init)` steps with a correct output.
-/
theorem correctness_of_decreasing_potential
    {State Spec : Type*}
    (A : AlgorithmicCertificate State Spec)
    (correctness : Spec → Prop)
    (init : State)
    (hInv0 : A.invariant init)
    (hPres : ∀ s, A.invariant s → A.terminal s = false → A.invariant (A.step s))
    (hDec : ∀ s, A.invariant s → A.terminal s = false →
        A.potential (A.step s) < A.potential s)
    (hSpec : ∀ s, A.invariant s → A.terminal s = true → correctness (A.extract s)) :
    ∃ t, t ≤ A.potential init ∧
      A.terminal (A.step^[t] init) = true ∧
      correctness (A.extract (A.step^[t] init)) := by
  -- By steps_bounded_by_potential, there exists some $t \leq A.potential init$ such that $A.terminal (A.step^[t] init) = true$.
  obtain ⟨t, ht₁, ht₂⟩ : ∃ t ≤ A.potential init, A.terminal (A.step^[t] init) = true := by
    by_contra! h;
    -- By repeatedly applying the step function, we can construct a sequence of states with strictly decreasing potential.
    have h_seq : ∀ n ≤ A.potential init, A.invariant (A.step^[n] init) ∧ A.potential (A.step^[n] init) ≤ A.potential init - n := by
      intro n hn;
      induction' n with n ih;
      · exact ⟨ hInv0, le_rfl ⟩;
      · simp_all +decide [ Function.iterate_succ_apply' ];
        exact ⟨ hPres _ ( ih ( Nat.le_of_lt hn ) |>.1 ) ( h _ ( Nat.le_of_lt hn ) ), Nat.le_sub_one_of_lt ( lt_of_lt_of_le ( hDec _ ( ih ( Nat.le_of_lt hn ) |>.1 ) ( h _ ( Nat.le_of_lt hn ) ) ) ( ih ( Nat.le_of_lt hn ) |>.2 ) ) ⟩;
    specialize h_seq ( A.potential init ) le_rfl;
    grind +splitImp;
  have h_inv : ∀ t ≤ A.potential init, (∀ i < t, A.terminal (A.step^[i] init) = false) → A.invariant (A.step^[t] init) := by
    intro t ht₁ ht₂; induction' t with t ih <;> simp_all +decide [ Function.iterate_succ_apply' ] ;
    exact hPres _ ( ih ( Nat.le_of_lt ht₁ ) fun i hi => ht₂ i ( Nat.le_of_lt hi ) ) ( ht₂ t le_rfl );
  -- Let's choose the smallest such $t$.
  obtain ⟨t, ht₁, ht₂⟩ : ∃ t ≤ A.potential init, A.terminal (A.step^[t] init) = true ∧ ∀ i < t, A.terminal (A.step^[i] init) = false := by
    exact ⟨ Nat.find ( ⟨ t, ht₁, ht₂ ⟩ : ∃ t ≤ A.potential init, A.terminal ( A.step^[t] init ) = true ), Nat.find_spec ( ⟨ t, ht₁, ht₂ ⟩ : ∃ t ≤ A.potential init, A.terminal ( A.step^[t] init ) = true ) |>.1, Nat.find_spec ( ⟨ t, ht₁, ht₂ ⟩ : ∃ t ≤ A.potential init, A.terminal ( A.step^[t] init ) = true ) |>.2, fun i hi => by_contra fun hi' => Nat.find_min ( ⟨ t, ht₁, ht₂ ⟩ : ∃ t ≤ A.potential init, A.terminal ( A.step^[t] init ) = true ) hi ⟨ Nat.le_trans ( Nat.le_of_lt hi ) ( Nat.find_spec ( ⟨ t, ht₁, ht₂ ⟩ : ∃ t ≤ A.potential init, A.terminal ( A.step^[t] init ) = true ) |>.1 ), by simpa using hi' ⟩ ⟩;
  exact ⟨ t, ht₁, ht₂.1, hSpec _ ( h_inv _ ht₁ ht₂.2 ) ht₂.1 ⟩

/-
Helper: the invariant is preserved through iteration.
-/
theorem invariant_preserved_iter
    {State Spec : Type*}
    (A : AlgorithmicCertificate State Spec)
    (init : State)
    (hInv0 : A.invariant init)
    (hPres : ∀ s, A.invariant s → A.terminal s = false → A.invariant (A.step s))
    (hDec : ∀ s, A.invariant s → A.terminal s = false →
        A.potential (A.step s) < A.potential s)
    (t : ℕ) (ht : t ≤ A.potential init)
    (hNotTerm : ∀ i, i < t → A.terminal (A.step^[i] init) = false) :
    A.invariant (A.step^[t] init) := by
  induction' t with t ih;
  · exact hInv0;
  · simpa only [ Function.iterate_succ_apply' ] using hPres _ ( ih ( Nat.le_of_succ_le ht ) fun i hi => hNotTerm i ( Nat.lt_succ_of_lt hi ) ) ( hNotTerm t ( Nat.lt_succ_self t ) )

/-
Helper: the potential strictly decreases through non-terminal iterations.
-/
theorem potential_decreases_iter
    {State Spec : Type*}
    (A : AlgorithmicCertificate State Spec)
    (init : State)
    (hInv0 : A.invariant init)
    (hPres : ∀ s, A.invariant s → A.terminal s = false → A.invariant (A.step s))
    (hDec : ∀ s, A.invariant s → A.terminal s = false →
        A.potential (A.step s) < A.potential s)
    (t : ℕ)
    (hNotTerm : ∀ i, i < t → A.terminal (A.step^[i] init) = false) :
    A.potential (A.step^[t] init) + t ≤ A.potential init := by
  nontriviality;
  induction' h : A.potential init using Nat.strong_induction_on with m ih generalizing init t;
  rcases t with ( _ | t ) <;> simp_all +decide [ Function.iterate_succ_apply' ];
  specialize ih ( A.potential ( A.step init ) ) ( by linarith [ hDec init hInv0 ( hNotTerm 0 bot_le ) ] ) ( A.step init ) ( hPres init hInv0 ( hNotTerm 0 bot_le ) ) t ( fun i hi => by simpa [ ← Function.iterate_succ_apply' ] using hNotTerm ( i + 1 ) ( by linarith ) ) rfl;
  erw [ Function.iterate_succ_apply' ] at ih ; linarith [ hDec init hInv0 ( hNotTerm 0 bot_le ) ]

/-
A complexity bound follows from the potential: the number of steps
is at most the initial potential value.
-/
theorem steps_bounded_by_potential
    {State Spec : Type*}
    (A : AlgorithmicCertificate State Spec)
    (init : State)
    (hInv0 : A.invariant init)
    (hPres : ∀ s, A.invariant s → A.terminal s = false → A.invariant (A.step s))
    (hDec : ∀ s, A.invariant s → A.terminal s = false →
        A.potential (A.step s) < A.potential s) :
    ∀ t, (∀ i, i < t → A.terminal (A.step^[i] init) = false) →
      t ≤ A.potential init := by
  -- By definition of potential, we know that potential(extract^(t) init) ≥ 0.
  have ht_nonneg : ∀ (t : ℕ), (A.potential (A.step^[t] init)) ≥ 0 := by
    exact fun t => Nat.zero_le _;
  exact fun t ht => by linarith [ potential_decreases_iter A init hInv0 hPres hDec t ht, ht_nonneg t ] ;

end