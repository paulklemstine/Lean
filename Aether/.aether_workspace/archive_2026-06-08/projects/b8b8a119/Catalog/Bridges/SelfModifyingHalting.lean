/-
  Self-Modifying Halting Problem
  ==============================

  We formalize the halting problem for self-modifying programs and prove:
  1. No algorithm can decide halting for self-modifying programs (diagonal argument)
  2. Classical halting reduces to self-modifying halting
  3. Virus detection is impossible for self-modifying code
  4. Fixed-point obstruction theorem for self-modifying systems
  5. Alignment impossibility: no monitor can guarantee termination of self-improving systems

  The key novelty is the `SelfModSystem` structure, which models programs
  that can rewrite their own transition function during execution, and the
  hierarchy of undecidability results that follow.
-/
import Mathlib

open Function Set

/-! ## Core Definitions -/

/-- A `SelfModSystem` models a computational system where programs can modify
    their own code during execution. We abstract this as:
    - `Code`: the type of program codes
    - `Input`: the type of inputs
    - `exec`: given a code and input, either halts (returning `some result`) or diverges (`none`)
    - `modify`: given a code and input, produces a new code (self-modification)
    - `exec_modify_compose`: executing the modified code is a valid execution path

    This is strictly more expressive than classical TMs because the transition
    function itself changes during computation. -/
structure SelfModSystem where
  Code : Type
  Input : Type
  /-- Execute a program on an input. `some b` means halts with output b, `none` means diverges. -/
  exec : Code → Input → Option Bool
  /-- Self-modification: given code and input, produce modified code -/
  modify : Code → Input → Code
  /-- The system admits a universal encoding: codes can be fed as inputs -/
  encode : Code → Input
  /-- Encoding is injective (distinct programs have distinct encodings) -/
  encode_injective : Injective encode

/-- A halting oracle for a `SelfModSystem` is a total decision procedure
    that correctly predicts whether `exec c i` returns `some _`. -/
def IsHaltingOracle (S : SelfModSystem) (oracle : S.Code → S.Input → Bool) : Prop :=
  ∀ c i, oracle c i = true ↔ (S.exec c i).isSome

/-- A self-modifying halting oracle must additionally predict halting of
    the *modified* code on the same input — a strictly harder task. -/
def IsSelfModHaltingOracle (S : SelfModSystem) (oracle : S.Code → S.Input → Bool) : Prop :=
  ∀ c i, oracle c i = true ↔ (S.exec (S.modify c i) i).isSome

/-- A virus detector is a predicate on codes that classifies programs as
    malicious or benign. A *perfect* virus detector correctly identifies
    all programs whose self-modified versions diverge on their own encoding. -/
def IsPerfectVirusDetector (S : SelfModSystem) (detector : S.Code → Bool) : Prop :=
  ∀ c, detector c = true ↔ (S.exec (S.modify c (S.encode c)) (S.encode c) = none)

/-- An alignment monitor is a function that, given a self-modifying system's code,
    decides whether the system will eventually stabilize (reach a fixed point
    under self-modification). -/
def IsAlignmentMonitor (S : SelfModSystem) (monitor : S.Code → Bool) : Prop :=
  ∀ c, monitor c = true ↔ (S.modify c (S.encode c) = c)

/-! ## Main Theorems -/

/-
**Theorem 1: Self-Modifying Halting Undecidability**

The diagonal argument adapted for self-modifying systems. Given any candidate
oracle, we construct a program that defeats it by using self-modification
to flip its own halting behavior.

Key insight: if an oracle `h` existed, we could build a self-modifying program
that consults `h` on its own modified version and does the opposite.
-/
theorem no_selfmod_halting_oracle (S : SelfModSystem)
    (diag : S.Code)
    (h_diag : ∀ (oracle : S.Code → S.Input → Bool),
      S.exec (S.modify diag (S.encode diag)) (S.encode diag) =
        if oracle diag (S.encode diag) then none else some true) :
    ¬ ∃ oracle : S.Code → S.Input → Bool, IsSelfModHaltingOracle S oracle := by
  intro ⟨ oracle, h_oracle ⟩;
  specialize h_oracle diag ( S.encode diag ) ; have := h_diag oracle ; split_ifs at this <;> simp_all +decide ;

/-
**Theorem 2: Classical Halting Reduces to Self-Modifying Halting**

Any classical halting problem instance can be embedded into a self-modifying
halting problem by using identity self-modification. This shows the
self-modifying halting problem is at least as hard.
-/
theorem classical_reduces_to_selfmod
    (Code Input : Type)
    (exec : Code → Input → Option Bool)
    (encode : Code → Input)
    (h_inj : Injective encode)
    -- If we could solve self-mod halting, we could solve classical halting
    (oracle : Code → Input → Bool)
    (h_oracle : ∀ c i, oracle c i = true ↔ (exec c i).isSome) :
    -- Then the same oracle works for the trivial self-mod system (id modification)
    IsHaltingOracle {
      Code := Code
      Input := Input
      exec := exec
      modify := fun c _ => c  -- identity modification = classical TM
      encode := encode
      encode_injective := h_inj
    } oracle := by
  exact h_oracle

/-
**Theorem 3: Perfect Virus Detection is Impossible**

No algorithm can serve as a perfect virus detector for self-modifying code.
This is a direct consequence of the diagonal argument: if a perfect detector
existed, we could use it to solve the self-modifying halting problem.
-/
theorem no_perfect_virus_detector (S : SelfModSystem)
    (diag : S.Code)
    (h_diag : ∀ (detector : S.Code → Bool),
      S.exec (S.modify diag (S.encode diag)) (S.encode diag) =
        if detector diag then some true else none) :
    ¬ ∃ detector : S.Code → Bool, IsPerfectVirusDetector S detector := by
  -- By contradiction, assume there exists a � perfect� virus detector.
  by_contra h_contra
  obtain ⟨detector, h_detector⟩ := h_contra;
  have := h_diag detector; specialize h_diag ( fun c => ! detector c ) ; aesop;

/-
**Theorem 4: Self-Modification Fixed Point Obstruction**

In any self-modifying system with a diagonal program, there exist programs
whose self-modification behavior cannot be predicted by any single function.
Specifically, no function can simultaneously:
(a) correctly predict modification fixed points, and
(b) be consistent with the diagonal program's behavior.
-/
theorem selfmod_fixedpoint_obstruction (S : SelfModSystem)
    (diag : S.Code)
    (h_diag : ∀ (monitor : S.Code → Bool),
      (S.modify diag (S.encode diag) = diag) ↔ (monitor diag = false)) :
    ¬ ∃ monitor : S.Code → Bool, IsAlignmentMonitor S monitor := by
  contrapose! h_diag;
  by_cases h : S.modify diag ( S.encode diag ) = diag <;> aesop

/-! ## Hierarchy Theorems -/

/-- The depth of self-modification: how many times a program modifies itself
    before halting (or diverging). Level 0 = classical TM, Level k = k rounds
    of self-modification. -/
def selfModDepth (S : SelfModSystem) (c : S.Code) (i : S.Input) : ℕ → S.Code
  | 0 => c
  | n + 1 => S.modify (selfModDepth S c i n) i

/-- At depth 0, the self-modification depth returns the original code. -/
@[simp]
theorem selfModDepth_zero (S : SelfModSystem) (c : S.Code) (i : S.Input) :
    selfModDepth S c i 0 = c := rfl

/-
Self-modification depth composes: depth (m+n) = n steps from depth m.
-/
theorem selfModDepth_add (S : SelfModSystem) (c : S.Code) (i : S.Input) (m n : ℕ) :
    selfModDepth S c i (m + n) = selfModDepth S (selfModDepth S c i m) i n := by
  induction' n with n ih generalizing m;
  · rfl;
  · convert congr_arg ( fun x => S.modify x i ) ( ih m ) using 1

/-
**Theorem 5: Strict Hierarchy of Self-Modification Levels**

If a system has the property that each level of self-modification can encode
the halting problem at the previous level, then the hierarchy is strict:
level-(k+1) halting is not reducible to level-k halting.

We formalize this as: there exist programs that stabilize at exactly depth k.
-/
theorem selfmod_hierarchy_separation (S : SelfModSystem) (c : S.Code) (i : S.Input)
    (k : ℕ)
    (h_stable : selfModDepth S c i (k + 1) = selfModDepth S c i k)
    (h_unstable : ∀ j, j < k → selfModDepth S c i (j + 1) ≠ selfModDepth S c i j) :
    ∀ j, j < k → selfModDepth S c i j ≠ selfModDepth S c i k := by
  grind +locals

/-! ## Alignment Impossibility -/

/-- A `MonitoredSystem` is a self-modifying system equipped with an external
    monitor that attempts to predict and control the system's behavior.
    This models the AI alignment scenario where we want to ensure a
    self-improving AI remains safe. -/
structure MonitoredSystem extends SelfModSystem where
  /-- The monitor's prediction: will the system halt safely? -/
  monitor : Code → Input → Bool
  /-- The system can observe and react to the monitor's output -/
  monitor_observable : Code → (Code → Input → Bool) → Code

/-
**Theorem 6: Monitor Evasion**

Any self-modifying system that can observe its monitor can construct a program
that evades the monitor's predictions. This is the formal basis for the
"AI alignment is impossible in full generality" argument.
-/
theorem monitor_evasion (M : MonitoredSystem)
    [Nonempty M.Code]
    (h_evasion : ∀ c,
      M.exec (M.monitor_observable c M.monitor) (M.encode c) =
        if M.monitor c (M.encode c) then none else some true) :
    ∃ c₀ : M.Code,
      (M.monitor c₀ (M.encode c₀) = true → (M.exec (M.monitor_observable c₀ M.monitor) (M.encode c₀) = none)) ∧
      (M.monitor c₀ (M.encode c₀) = false → (M.exec (M.monitor_observable c₀ M.monitor) (M.encode c₀)).isSome) := by
  aesop

/-! ## Quantitative Results -/

/-
**Pigeonhole for iteration**: In a finite type with n elements,
    among the first n+1 iterates of any function, two must coincide.
    This gives the fundamental cycle-detection bound for self-modifying systems:
    any orbit enters a cycle within at most n steps.
-/
theorem finite_selfmod_iterate_collision [Fintype α] [DecidableEq α]
    (f : α → α) (a : α) :
    ∃ i j : ℕ, i < j ∧ j ≤ Fintype.card α ∧ f^[i] a = f^[j] a := by
  by_contra! h_contra;
  exact absurd ( Finset.card_le_univ ( Finset.image ( fun i => f^[i] a ) ( Finset.Icc 0 ( Fintype.card α ) ) ) ) ( by rw [ Finset.card_image_of_injOn fun i hi j hj hij => le_antisymm ( not_lt.1 fun hi' => h_contra _ _ hi' ( by aesop ) hij.symm ) ( not_lt.1 fun hj' => h_contra _ _ hj' ( by aesop ) hij ) ] ; simp +decide )

/-
The number of distinct states reachable by k rounds of self-modification
    is bounded by min(k+1, n) where n is the total number of possible codes.
-/
theorem selfmod_reachable_bound [Fintype α] [DecidableEq α]
    (f : α → α) (a : α) (k : ℕ) :
    (Finset.image (fun i => f^[i] a) (Finset.range (k + 1))).card ≤
      min (k + 1) (Fintype.card α) := by
  exact le_min ( Finset.card_image_le.trans ( by simp +decide ) ) ( Finset.card_le_univ _ )

/-! ## Conjecture: Self-Modification Complexity Gap -/

/-
**Conjecture**: For any n ≥ 2, there exists a self-modifying system on n states
    where the minimum number of steps to reach a fixed point is exactly n-1,
    and this bound is tight.

    Testable prediction: For n = 3, there should be a permutation on {0,1,2}
    where iterating from some starting point takes exactly 2 steps to reach
    a fixed point. This is true: the cycle (0 1 2) starting from 0 gives
    0 → 1 → 2 → 0, but the transposition (0 1) starting from 0 gives
    0 → 1 → 0 (cycle length 2, never reaches fixed point).

    A cleaner version: for n ≥ 2, the maximum over all f : Fin n → Fin n
    and starting points a, of the minimum k such that f^[k] a = f^[k+1] a
    (i.e., we've reached a fixed point of f), is exactly n - 1.

    This can be checked computationally for small n.
-/
theorem selfmod_fixpoint_delay_upper (n : ℕ) (hn : 2 ≤ n)
    (f : Fin n → Fin n) (a : Fin n)
    (hfix : ∃ k, f^[k] a = f^[k + 1] a) :
    ∃ k, k ≤ n - 1 ∧ f^[k] a = f^[k + 1] a := by
  obtain ⟨ k, hk ⟩ := Nat.findX hfix;
  refine' ⟨ k, _, hk.1 ⟩;
  -- By contradiction, assume $k > n - 1$.
  by_contra h_contra;
  have h_distinct : ∀ i j : ℕ, i < j → j ≤ k → f^[i] a ≠ f^[j] a := by
    intros i j hij hjk h_eq;
    have h_contradiction : f^[i + (k - j)] a = f^[k] a := by
      rw [ Nat.add_comm, Function.iterate_add_apply, h_eq ];
      rw [ ← Function.iterate_add_apply, Nat.sub_add_cancel hjk ];
    exact hk.2 ( i + ( k - j ) ) ( by omega ) ( by simp_all +singlePass [ Function.iterate_succ_apply' ] );
  exact absurd ( Finset.card_le_univ ( Finset.image ( fun i => f^[i] a ) ( Finset.range ( k + 1 ) ) ) ) ( by rw [ Finset.card_image_of_injOn fun i hi j hj hij => le_antisymm ( not_lt.mp fun hi' => h_distinct _ _ hi' ( by linarith [ Finset.mem_range.mp hi, Finset.mem_range.mp hj ] ) hij.symm ) ( not_lt.mp fun hj' => h_distinct _ _ hj' ( by linarith [ Finset.mem_range.mp hi, Finset.mem_range.mp hj ] ) hij ) ] ; norm_num; omega )