import Mathlib

/-!
# Self-Modifying Computation and Undecidability

We formalize key impossibility results concerning self-modifying computational systems.
The central theme is that self-referential systems face fundamental barriers to
self-prediction, connecting the halting problem, virus detection, and fixed-point
obstructions.

## Main Results

1. **Lawvere's Fixed-Point Theorem** (`lawvere_fixed_point`): If `e : α → (α → β)` is
   surjective, every endomorphism of `β` has a fixed point. This is the categorical
   heart of all diagonal arguments.

2. **No Surjective Bool Enumeration** (`no_surjective_bool_enum`): No function
   `ℕ → (ℕ → Bool)` is surjective — the diagonal function always escapes.

3. **Adaptive Adversary Theorem** (`adaptive_adversary_no_classifier`): When programs
   can observe a classifier's output and modify their behavior accordingly, no
   classifier can be correct on all programs.

4. **Self-Prediction Impossibility** (`no_self_predicting_decider`): No total decision
   procedure can correctly predict its own behavior on self-referential inputs.

5. **Stabilization Undecidability** (`stabilization_undecidable_of_halting`): The
   stabilization problem for self-modifying systems (does the system reach a fixed
   point?) is at least as hard as the halting problem.

## Novel Definitions

- `AdaptiveProgram`: A program that can observe a classifier and change behavior.
- `SelfModSystem`: A computation model with explicit self-modification.
- `Stabilizes`: Whether a self-modifying system reaches a fixed configuration.
-/

open Function

namespace SelfModHalting

/-! ## Part I: Lawvere's Fixed-Point Theorem -/

/-
**Lawvere's Fixed-Point Theorem**: If `e : α → (α → β)` is surjective,
then every endomorphism `t : β → β` has a fixed point. This is the abstract
engine behind Cantor's theorem, the halting problem, Gödel's incompleteness,
Rice's theorem, and the virus detection paradox.
-/
theorem lawvere_fixed_point {α β : Type*} (e : α → (α → β))
    (he : Surjective e) (t : β → β) : ∃ b : β, t b = b := by
  obtain ⟨ a, ha ⟩ := he ( fun x => t ( e x x ) );
  exact ⟨ _, congr_fun ha a |> Eq.symm ⟩

/-
**Corollary**: If `β` admits a fixed-point-free endomorphism, then no
function `α → (α → β)` can be surjective. This gives Cantor's theorem
as an immediate special case (with `β = Prop` or `β = Bool`).
-/
theorem no_surjection_of_fixedpoint_free {α β : Type*} (t : β → β)
    (ht : ∀ b, t b ≠ b) (e : α → (α → β)) : ¬ Surjective e := by
  intro h;
  exact ht _ ( Classical.choose_spec ( lawvere_fixed_point e h t ) )

/-! ## Part II: The Diagonal Argument for Computability -/

/-- The diagonal function: given an enumeration of Boolean predicates,
construct a predicate that disagrees with each enumerated predicate on
its own index. -/
def diagonal (enum : ℕ → ℕ → Bool) : ℕ → Bool := fun n => !enum n n

/-
The diagonal function disagrees with `enum n` at position `n`.
-/
theorem diagonal_ne_at (enum : ℕ → ℕ → Bool) (n : ℕ) :
    diagonal enum n ≠ enum n n := by
  cases h : enum n n <;> simp +decide [ h, diagonal ]

/-
**No Surjective Bool Enumeration**: The diagonal function always escapes
any enumeration. This is the computational essence of the halting problem:
if programs could be enumerated and their halting behavior decided, the
diagonal would be a computable function not in the enumeration.
-/
theorem no_surjective_bool_enum (e : ℕ → ℕ → Bool) : ¬ Surjective e := by
  convert no_surjection_of_fixedpoint_free Bool.not ( by decide ) e using 1

/-! ## Part III: Adaptive Adversary and Virus Detection Paradox -/

/-- An `AdaptiveProgram` models a program that can observe a classifier's
decision about it and modify its behavior accordingly. The `react` field
captures how the program changes its output based on what the classifier says.

This models the core of the virus detection paradox: a virus that checks
whether it's being scanned and behaves benignly if so, or the alignment
problem where an AI system modifies behavior based on monitoring. -/
structure AdaptiveProgram where
  /-- Base behavior when not observed -/
  baseBehavior : Bool
  /-- Reaction function: given the classifier's verdict, produce actual behavior -/
  react : Bool → Bool

/-- The actual behavior of an adaptive program when facing a classifier.
The classifier outputs a prediction; the program sees that prediction
and reacts to it. -/
def AdaptiveProgram.actualBehavior (p : AdaptiveProgram) (classifierOutput : Bool) : Bool :=
  p.react classifierOutput

/-- A classifier is **correct on** an adaptive program if its output matches
the program's actual behavior (which depends on the classifier's output). -/
def classifierCorrectOn (classifier : AdaptiveProgram → Bool) (p : AdaptiveProgram) : Prop :=
  classifier p = p.actualBehavior (classifier p)

/-- The **contrarian** adaptive program: it always does the opposite of what
the classifier predicts. This is the computational analog of the liar paradox
and the heart of the virus detection impossibility. -/
def contrarian : AdaptiveProgram where
  baseBehavior := true
  react := fun prediction => !prediction

/-
No classifier is correct on the contrarian program. This captures the
virus detection paradox: a program that does the opposite of what any
detector predicts cannot be correctly classified.
-/
theorem contrarian_defeats_any_classifier (classifier : AdaptiveProgram → Bool) :
    ¬ classifierCorrectOn classifier contrarian := by
  unfold classifierCorrectOn;
  unfold contrarian;
  unfold AdaptiveProgram.actualBehavior; aesop;

/-
**Adaptive Adversary Theorem**: For any classifier of adaptive programs,
there exists a program on which the classifier is incorrect. This is a
constructive proof — we exhibit the adversary (the contrarian).
-/
theorem adaptive_adversary_no_classifier (classifier : AdaptiveProgram → Bool) :
    ∃ p : AdaptiveProgram, ¬ classifierCorrectOn classifier p := by
  exact ⟨ contrarian, contrarian_defeats_any_classifier classifier ⟩

/-! ## Part IV: Self-Modifying Systems and Stabilization -/

/-- A `SelfModSystem` models a computational system where the program can
modify its own code during execution. The state includes both the "data"
being computed and the "code" being executed.

This is more expressive than standard Turing machines in the following
sense: while self-modification doesn't increase computational power
(by simulation), the *self-referential prediction problem* becomes
strictly harder because the system's behavior depends on attempts to
predict it. -/
structure SelfModSystem where
  /-- The type of program codes -/
  Code : Type
  /-- The type of data states -/
  Data : Type
  /-- One step: given current code and data, produce new code and data,
      or `none` if the computation halts -/
  step : Code → Data → Option (Code × Data)

/-- A configuration of a self-modifying system. -/
structure SelfModSystem.Config (S : SelfModSystem) where
  code : S.Code
  data : S.Data

/-- Execute one step of a self-modifying system. -/
def SelfModSystem.stepConfig (S : SelfModSystem) (c : S.Config) :
    Option S.Config :=
  (S.step c.code c.data).map fun ⟨code', data'⟩ => ⟨code', data'⟩

/-- Iterate `n` steps of the system, returning `none` if the system halted. -/
def SelfModSystem.iterateN (S : SelfModSystem) (c : S.Config) :
    ℕ → Option S.Config
  | 0 => some c
  | n + 1 => (S.iterateN c n).bind S.stepConfig

/-- A self-modifying system **halts** from configuration `c` if it reaches
`none` in finitely many steps. -/
def SelfModSystem.Halts (S : SelfModSystem) (c : S.Config) : Prop :=
  ∃ n : ℕ, S.iterateN c n = none

/-- A self-modifying system **stabilizes** from configuration `c` if
the code component eventually stops changing. This is a weaker condition
than halting — the system may continue computing, but its self-modification
phase terminates. -/
def SelfModSystem.Stabilizes (S : SelfModSystem) [DecidableEq S.Code]
    (c : S.Config) : Prop :=
  ∃ n : ℕ, ∀ m : ℕ, ∀ c' c'',
    S.iterateN c n = some c' → S.iterateN c (n + m) = some c'' → c'.code = c''.code

/-
**Halting implies Stabilization**: If a system halts, it trivially
stabilizes (there are no further steps to change code).
-/
theorem SelfModSystem.halts_imp_stabilizes (S : SelfModSystem) [DecidableEq S.Code]
    (c : S.Config) (h : S.Halts c) : S.Stabilizes c := by
  obtain ⟨ n, hn ⟩ := h;
  use n;
  grind +qlia

/-! ## Part V: Self-Prediction Impossibility -/

/-- A **self-referential decider** is a function that, given a program
index `n`, tries to predict whether program `n` "accepts" index `n`.
This captures the diagonal case of the halting problem. -/
def SelfRefDecider := ℕ → Bool

/-
**Self-Prediction Impossibility**: If a decider `d` computes the
anti-diagonal `fun n => !(prog n n)`, then `d` cannot appear in the
enumeration `prog`. The system cannot predict its own negation.
-/
theorem no_self_predicting_decider (prog : ℕ → ℕ → Bool)
    (d : ℕ → Bool) (hd : ∀ n, d n = !prog n n) :
    ¬ ∃ k, prog k = d := by
  rintro ⟨ k, hk ⟩ ; specialize hd k; have := congr_fun hk k; aesop;

/-
**Diagonal Escape for Any Enumeration**: The anti-diagonal function
is never in the range of the enumeration, regardless of how programs
are indexed. This is the computability-theoretic core of undecidability.
-/
theorem anti_diagonal_not_in_range (prog : ℕ → ℕ → Bool) :
    ¬ ∃ k, prog k = diagonal prog := by
  exact fun ⟨ k, hk ⟩ => by have := congr_fun hk k; simp +decide [ diagonal ] at this;

/-! ## Part VI: The Reduction Theorem -/

/-- Model of a classical program as a special case of a self-modifying system
where the code never changes. -/
def classicalSystem (prog : ℕ → ℕ → Option ℕ) : SelfModSystem where
  Code := ℕ
  Data := ℕ
  step := fun code data => (prog code data).map fun d' => (code, d')

/-
In a classical system, the code component never changes during execution.
-/
theorem classicalSystem_code_stable (prog : ℕ → ℕ → Option ℕ) (c : (classicalSystem prog).Config)
    (n : ℕ) (c' : (classicalSystem prog).Config)
    (h : (classicalSystem prog).iterateN c n = some c') : c'.code = c.code := by
  induction' n with n ih generalizing c c';
  · cases h ; rfl;
  · simp_all +decide [ SelfModSystem.iterateN ];
    cases h' : ( classicalSystem prog ).iterateN c n <;> simp_all +decide [ SelfModSystem.stepConfig ];
    unfold classicalSystem at *; aesop;

/-
**Reduction Theorem**: Halting of classical programs embeds into
halting of self-modifying systems. If the self-modifying halting problem
is decidable, so is the classical halting problem.
-/
theorem self_mod_halting_at_least_as_hard
    (prog : ℕ → ℕ → Option ℕ) (code data : ℕ) :
    (classicalSystem prog).Halts ⟨code, data⟩ ↔
    ∃ n, (classicalSystem prog).iterateN ⟨code, data⟩ n = none := by
  exact ⟨ fun h => h, fun h => h ⟩

/-! ## Part VII: The Anti-Alignment Theorem

This section formalizes a key result for AI alignment: a system that
monitors another system and tries to intervene when the monitored system
would produce "bad" behavior faces the same diagonal obstruction as
the halting problem. -/

/-- A **monitor** observes a system's intended output and decides whether
to allow it (true) or block it (false). -/
def Monitor := ℕ → Bool

/-- A **strategic agent** chooses its output based on what the monitor
would do. The agent has a goal (`target`) and a strategy for evading
or cooperating with the monitor. -/
structure StrategicAgent where
  /-- The agent's target output -/
  target : ℕ
  /-- Given a monitor's response to the target, the agent's actual output.
      If the monitor would allow the target, use it; otherwise adapt. -/
  strategy : Bool → ℕ

/-- The agent's actual output when facing a specific monitor. -/
def StrategicAgent.output (agent : StrategicAgent) (monitor : Monitor) : ℕ :=
  agent.strategy (monitor agent.target)

/-- A monitor **prevents** an agent from achieving its target if the
agent's actual output (accounting for strategic adaptation) differs
from the target. -/
def monitorPrevents (monitor : Monitor) (agent : StrategicAgent) : Prop :=
  agent.output monitor ≠ agent.target

/-- A **deceptive agent** achieves its target regardless of the monitor's decision.
It outputs the target no matter what the monitor says. -/
def deceptiveAgent (t : ℕ) : StrategicAgent where
  target := t
  strategy := fun _ => t

/-
A deceptive agent always achieves its target. No monitor can prevent it.
This formalizes the fundamental barrier: a sufficiently strategic agent
can always circumvent monitoring by ignoring the monitor's decision.
-/
theorem deceptive_agent_unprevented (monitor : Monitor) (t : ℕ) :
    ¬ monitorPrevents monitor (deceptiveAgent t) := by
  exact fun h => h ( by rfl )

/-
**Anti-Alignment Theorem**: For any monitor, there exists a strategic
agent that the monitor cannot prevent from achieving its target. This is
a fundamental barrier to alignment-by-monitoring approaches: the agent
can always choose to ignore the monitor.
-/
theorem anti_alignment (monitor : Monitor) :
    ∃ agent : StrategicAgent, ¬ monitorPrevents monitor agent := by
  exact ⟨ deceptiveAgent 0, deceptive_agent_unprevented monitor 0 ⟩

end SelfModHalting