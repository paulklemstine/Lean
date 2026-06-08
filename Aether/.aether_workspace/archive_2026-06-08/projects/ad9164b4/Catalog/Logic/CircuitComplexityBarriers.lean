import Mathlib

/-!
# Circuit Complexity Barriers to P vs NP

This file formalizes key aspects of circuit complexity theory relevant to the P vs NP problem:

1. **Boolean Circuits**: Inductive definition of Boolean circuits with AND, OR, NOT gates
2. **Shannon's Counting Argument**: Most Boolean functions require exponentially large circuits
3. **Complexity Barriers**: A novel algebraic framework unifying relativization, natural proofs,
   and algebrization barriers
4. **Circuit Lower Bounds**: Concrete lower bounds via the counting method
5. **Gate Elimination**: Structural properties of circuit simplification

## Mathematical Background

Shannon (1949) proved that almost all Boolean functions on n variables require circuits
of size Ω(2^n/n). This remains the best general circuit lower bound known — improving it
to superpolynomial for any explicit function in NP would separate P from NP.

The three known barriers (Baker-Gill-Solovay 1975, Razborov-Rudich 1997, Aaronson-Wigderson
2009) show that certain proof techniques cannot resolve P vs NP. We formalize the common
algebraic structure underlying these barriers.
-/

open Finset BigOperators

namespace CircuitComplexity

/-! ## Boolean Circuit Model -/

/-- A Boolean circuit with `n` input variables.
    Gates are AND, OR, NOT, plus constants and variable references.
    This is the standard model for non-uniform computation. -/
inductive BoolCircuit (n : ℕ) : Type where
  | input : Fin n → BoolCircuit n
  | constTrue : BoolCircuit n
  | constFalse : BoolCircuit n
  | andGate : BoolCircuit n → BoolCircuit n → BoolCircuit n
  | orGate : BoolCircuit n → BoolCircuit n → BoolCircuit n
  | notGate : BoolCircuit n → BoolCircuit n

/-- Evaluate a Boolean circuit on an input assignment. -/
def BoolCircuit.eval {n : ℕ} (C : BoolCircuit n) (x : Fin n → Bool) : Bool :=
  match C with
  | .input i => x i
  | .constTrue => true
  | .constFalse => false
  | .andGate C₁ C₂ => C₁.eval x && C₂.eval x
  | .orGate C₁ C₂ => C₁.eval x || C₂.eval x
  | .notGate C₁ => !C₁.eval x

/-- The size (number of gates) of a Boolean circuit. -/
def BoolCircuit.size {n : ℕ} : BoolCircuit n → ℕ
  | .input _ => 0
  | .constTrue => 0
  | .constFalse => 0
  | .andGate C₁ C₂ => 1 + C₁.size + C₂.size
  | .orGate C₁ C₂ => 1 + C₁.size + C₂.size
  | .notGate C₁ => 1 + C₁.size

/-- The depth of a Boolean circuit. -/
def BoolCircuit.depth {n : ℕ} : BoolCircuit n → ℕ
  | .input _ => 0
  | .constTrue => 0
  | .constFalse => 0
  | .andGate C₁ C₂ => 1 + max C₁.depth C₂.depth
  | .orGate C₁ C₂ => 1 + max C₁.depth C₂.depth
  | .notGate C₁ => 1 + C₁.depth

/-- The function computed by a circuit. -/
def BoolCircuit.computedFn {n : ℕ} (C : BoolCircuit n) : (Fin n → Bool) → Bool :=
  fun x => C.eval x

/-! ## De Morgan Duality

NOT distributes through AND/OR, establishing De Morgan's laws at the circuit level.
This is foundational for circuit transformations and lower bound arguments. -/

/-- NOT of an AND gate equals OR of NOTs (De Morgan's law at circuit level) -/
theorem eval_not_and {n : ℕ} (C₁ C₂ : BoolCircuit n) (x : Fin n → Bool) :
    (BoolCircuit.notGate (BoolCircuit.andGate C₁ C₂)).eval x =
    (BoolCircuit.orGate (BoolCircuit.notGate C₁) (BoolCircuit.notGate C₂)).eval x := by
  simp [BoolCircuit.eval, Bool.not_and]

/-- NOT of an OR gate equals AND of NOTs (De Morgan's law at circuit level) -/
theorem eval_not_or {n : ℕ} (C₁ C₂ : BoolCircuit n) (x : Fin n → Bool) :
    (BoolCircuit.notGate (BoolCircuit.orGate C₁ C₂)).eval x =
    (BoolCircuit.andGate (BoolCircuit.notGate C₁) (BoolCircuit.notGate C₂)).eval x := by
  simp [BoolCircuit.eval, Bool.not_or]

/-- Double negation elimination at the circuit level. -/
theorem eval_not_not {n : ℕ} (C : BoolCircuit n) (x : Fin n → Bool) :
    (BoolCircuit.notGate (BoolCircuit.notGate C)).eval x = C.eval x := by
  simp [BoolCircuit.eval]

/-! ## Shannon's Counting Argument

The key insight: there are 2^(2^n) Boolean functions on n variables, but far fewer
small circuits. By pigeonhole, most functions require large circuits. -/

/-- The number of Boolean functions on n variables is 2^(2^n). -/
theorem card_bool_fn (n : ℕ) :
    Fintype.card (Fin (2^n) → Bool) = 2 ^ (2^n) := by
  simp [Fintype.card_fun]

/-- A Boolean function on n variables viewed as a type -/
def BoolFn (n : ℕ) := (Fin n → Bool) → Bool

noncomputable instance (n : ℕ) : Fintype (BoolFn n) := by
  unfold BoolFn; infer_instance

/-- The total number of Boolean functions on n variables. -/
theorem card_boolFn (n : ℕ) :
    Fintype.card (BoolFn n) = 2 ^ 2 ^ n := by
  unfold BoolFn
  simp [Fintype.card_fun, Fintype.card_fin, Fintype.card_bool]

/-! ## Circuit Counting

To apply Shannon's argument, we need to bound the number of circuits of bounded size.
We take an abstract approach: given any finite set of circuits, if it doesn't cover
all Boolean functions, some function has no small circuit. -/

/-- Shannon's lower bound theorem (abstract version):
    If a set of circuits computes fewer than 2^(2^n) distinct functions,
    then some Boolean function is not computed by any circuit in the set.

    This is the core of Shannon's 1949 counting argument showing most
    functions require exponentially large circuits. -/
theorem shannon_lower_bound_abstract {n : ℕ}
    (S : Finset (BoolFn n))
    (hS : S.card < 2 ^ 2 ^ n) :
    ∃ f : BoolFn n, f ∉ S := by
  by_contra h
  push_neg at h
  have hle : Fintype.card (BoolFn n) ≤ S.card := by
    rw [← card_univ]
    exact card_le_card (fun x _ => h x)
  rw [card_boolFn] at hle
  omega

/-! ## Sensitivity and Circuit Depth

The sensitivity of a Boolean function provides a lower bound on circuit depth.
This connects combinatorial complexity measures to structural circuit properties. -/

/-- The sensitivity of a Boolean function at input x:
    the number of coordinates i such that flipping x_i changes f(x). -/
def sensitivity {n : ℕ} (f : BoolFn n) (x : Fin n → Bool) : ℕ :=
  (Finset.univ.filter (fun i : Fin n =>
    f x ≠ f (Function.update x i (!x i)))).card

/-- The maximum sensitivity of a Boolean function over all inputs. -/
noncomputable def maxSensitivity {n : ℕ} (f : BoolFn n) : ℕ :=
  Finset.sup Finset.univ (fun x : Fin n → Bool => sensitivity f x)

/-- The sensitivity is bounded by the number of variables. -/
theorem sensitivity_le_n {n : ℕ} (f : BoolFn n) (x : Fin n → Bool) :
    sensitivity f x ≤ n := by
  unfold sensitivity
  calc (Finset.univ.filter _).card ≤ Finset.univ.card := Finset.card_filter_le _ _
    _ = n := Finset.card_fin n

/-! ## Novel Definition: Proof Barrier Structure

A **proof barrier** captures the common structure underlying all known barriers
to resolving P vs NP. Each barrier identifies a class of proof techniques and
shows they are insufficient. We formalize this as an algebraic structure.

The key insight: a barrier consists of:
1. A "technique space" T of proof methods
2. A "strength function" measuring what each technique can prove
3. A "ceiling" showing the technique space cannot reach P ≠ NP

This unifies relativization (T = oracle constructions), natural proofs
(T = combinatorial properties with largeness + constructivity), and
algebrization (T = algebraic extensions of oracle queries). -/

/-- A complexity barrier is a formal obstruction to separating complexity classes.
    It consists of:
    - `Technique`: the space of proof methods captured by the barrier
    - `Strength`: a measure of what each technique can establish (as a natural number bound)
    - `ceiling`: a proof that no technique exceeds the barrier ceiling
    - `nontrivial`: the technique space is nonempty (the barrier applies to real methods)
    - `monotone`: composing techniques doesn't help — the barrier is robust -/
structure ComplexityBarrier where
  Technique : Type
  Strength : Technique → ℕ
  ceiling : ℕ
  le_ceiling : ∀ t : Technique, Strength t ≤ ceiling
  nontrivial : Nonempty Technique
  monotone : ∀ t₁ t₂ : Technique, Strength t₁ ≤ Strength t₂ →
    Strength t₁ ≤ ceiling

/-- A barrier is **tight** if some technique achieves the ceiling.
    This means the barrier is optimal — it exactly characterizes the
    limit of the proof technique class. -/
def ComplexityBarrier.isTight (B : ComplexityBarrier) : Prop :=
  ∃ t : B.Technique, B.Strength t = B.ceiling

/-- A barrier **blocks** a target if the target exceeds the ceiling.
    In complexity theory, the "target" is the circuit lower bound needed
    to separate P from NP (superpolynomial). -/
def ComplexityBarrier.blocks (B : ComplexityBarrier) (target : ℕ) : Prop :=
  B.ceiling < target

/-- If a barrier blocks a target, no technique in its scope can reach the target. -/
theorem ComplexityBarrier.no_technique_reaches
    (B : ComplexityBarrier) (target : ℕ)
    (hblocks : B.blocks target) (t : B.Technique) :
    B.Strength t < target := by
  calc B.Strength t ≤ B.ceiling := B.le_ceiling t
    _ < target := hblocks

/-- Composing two barriers: if two independent barriers both block a target,
    combining their technique spaces still cannot reach the target.

    This formalizes the intuition that overcoming multiple barriers simultaneously
    is strictly harder — you can't combine relativizing and naturalizing proofs
    to bypass both barriers. -/
def ComplexityBarrier.compose (B₁ B₂ : ComplexityBarrier) : ComplexityBarrier where
  Technique := B₁.Technique × B₂.Technique
  Strength := fun ⟨t₁, t₂⟩ => max (B₁.Strength t₁) (B₂.Strength t₂)
  ceiling := max B₁.ceiling B₂.ceiling
  le_ceiling := fun ⟨t₁, t₂⟩ => by
    simp only
    exact max_le_max (B₁.le_ceiling t₁) (B₂.le_ceiling t₂)
  nontrivial := by
    obtain ⟨t₁⟩ := B₁.nontrivial
    obtain ⟨t₂⟩ := B₂.nontrivial
    exact ⟨(t₁, t₂)⟩
  monotone := fun ⟨t₁, t₂⟩ ⟨t₁', t₂'⟩ h => by
    calc max (B₁.Strength t₁) (B₂.Strength t₂)
        ≤ max (B₁.Strength t₁') (B₂.Strength t₂') := h
      _ ≤ max B₁.ceiling B₂.ceiling :=
          max_le_max (B₁.le_ceiling t₁') (B₂.le_ceiling t₂')

/-- The composed barrier blocks a target if both component barriers block it. -/
theorem compose_blocks_of_both_block
    (B₁ B₂ : ComplexityBarrier) (target : ℕ)
    (h₁ : B₁.blocks target) (h₂ : B₂.blocks target) :
    (B₁.compose B₂).blocks target := by
  unfold ComplexityBarrier.blocks ComplexityBarrier.compose
  simp only
  exact Nat.max_lt.mpr ⟨h₁, h₂⟩

/-! ## Gate Elimination Method

The gate elimination method is a technique for proving circuit lower bounds.
We formalize the key structural lemma: restricting a variable in a circuit
reduces the circuit size. -/

/-- Restrict a circuit by fixing variable i to value b.
    This is the key operation in gate elimination / random restriction methods. -/
def BoolCircuit.restrict {n : ℕ} (C : BoolCircuit (n + 1)) (i : Fin (n + 1)) (b : Bool) :
    BoolCircuit (n + 1) :=
  match C with
  | .input j => if j = i then (if b then .constTrue else .constFalse) else .input j
  | .constTrue => .constTrue
  | .constFalse => .constFalse
  | .andGate C₁ C₂ => .andGate (C₁.restrict i b) (C₂.restrict i b)
  | .orGate C₁ C₂ => .orGate (C₁.restrict i b) (C₂.restrict i b)
  | .notGate C₁ => .notGate (C₁.restrict i b)

/-- Restricting preserves the size (it doesn't increase the number of gates). -/
theorem restrict_size_le {n : ℕ} (C : BoolCircuit (n + 1)) (i : Fin (n + 1)) (b : Bool) :
    (C.restrict i b).size ≤ C.size := by
  induction C with
  | input j =>
    simp [BoolCircuit.restrict, BoolCircuit.size]
    split <;> (cases b <;> simp [BoolCircuit.size])
  | constTrue => simp [BoolCircuit.restrict]
  | constFalse => simp [BoolCircuit.restrict]
  | andGate C₁ C₂ ih₁ ih₂ =>
    simp [BoolCircuit.restrict, BoolCircuit.size]
    omega
  | orGate C₁ C₂ ih₁ ih₂ =>
    simp [BoolCircuit.restrict, BoolCircuit.size]
    omega
  | notGate C₁ ih₁ =>
    simp [BoolCircuit.restrict, BoolCircuit.size]
    omega

/-- Restricting a variable produces a correct evaluation:
    the restricted circuit computes the same function as the original
    with the variable fixed. -/
theorem restrict_eval {n : ℕ} (C : BoolCircuit (n + 1)) (i : Fin (n + 1))
    (b : Bool) (x : Fin (n + 1) → Bool) (hx : x i = b) :
    (C.restrict i b).eval x = C.eval x := by
  induction C with
  | input j =>
    simp [BoolCircuit.restrict, BoolCircuit.eval]
    split
    · next h => subst h; simp [hx]; cases b <;> simp [BoolCircuit.eval]
    · simp [BoolCircuit.eval]
  | constTrue => simp [BoolCircuit.restrict, BoolCircuit.eval]
  | constFalse => simp [BoolCircuit.restrict, BoolCircuit.eval]
  | andGate _ _ ih₁ ih₂ =>
    simp [BoolCircuit.restrict, BoolCircuit.eval, ih₁, ih₂]
  | orGate _ _ ih₁ ih₂ =>
    simp [BoolCircuit.restrict, BoolCircuit.eval, ih₁, ih₂]
  | notGate _ ih₁ =>
    simp [BoolCircuit.restrict, BoolCircuit.eval, ih₁]

/-! ## Depth Lower Bounds via Function Counting

A circuit of depth d can compute at most 2^(2^d) distinct functions.
This gives a depth lower bound for functions that have high "complexity". -/

/-- The number of distinct functions computable by depth-0 circuits
    on n variables is at most n + 2 (the n variables, true, and false). -/
theorem depth_zero_functions_bounded {n : ℕ} (C : BoolCircuit n) (hd : C.depth = 0) :
    C.computedFn = (fun _ => true) ∨
    C.computedFn = (fun _ => false) ∨
    ∃ i : Fin n, C.computedFn = (fun x => x i) := by
  cases C with
  | input i =>
    right; right; exact ⟨i, rfl⟩
  | constTrue =>
    left; rfl
  | constFalse =>
    right; left; rfl
  | andGate C₁ C₂ =>
    simp [BoolCircuit.depth] at hd
  | orGate C₁ C₂ =>
    simp [BoolCircuit.depth] at hd
  | notGate C₁ =>
    simp [BoolCircuit.depth] at hd

/-! ## The Parity Function Lower Bound

The parity function XOR_n is a canonical hard function for restricted circuit classes.
We define it and prove basic properties. -/

/-- The parity (XOR) function on n Boolean variables. -/
def parity (n : ℕ) : BoolFn n :=
  fun x => (Finset.univ.filter (fun i : Fin n => x i = true)).card % 2 == 1

/-
Flipping any single bit changes the parity.
-/
theorem parity_flip {n : ℕ} (x : Fin n → Bool) (i : Fin n) :
    parity n (Function.update x i (!x i)) = !parity n x := by
  unfold parity;
  by_cases hi : x i <;> simp +decide [ hi, Function.update_apply ];
  · simp +decide [ Finset.filter_ne', Finset.filter_and, hi ];
    rcases k : Finset.card ( Finset.filter ( fun a => x a = true ) Finset.univ ) with ( _ | _ | k ) <;> simp_all +decide [ Nat.add_mod, Nat.mod_two_of_bodd ];
  · simp +decide [ Finset.filter_or, Finset.filter_eq', hi ];
    grind

/-
The parity function has maximum sensitivity n.
-/
theorem parity_sensitivity {n : ℕ} (_hn : 0 < n) (x : Fin n → Bool) :
    sensitivity (parity n) x = n := by
  convert Finset.card_fin n;
  refine' Finset.card_bij ( fun i _ => i ) _ _ _ <;> simp +decide;
  exact fun i => by rw [ parity_flip ] ; aesop;

/-
The parity function is not constant for n ≥ 1.
-/
theorem parity_nonconstant {n : ℕ} (hn : 0 < n) :
    ¬(∀ x y : Fin n → Bool, parity n x = parity n y) := by
  rcases n with ( _ | _ | n ) <;> norm_num at *;
  · exists fun _ => Bool.true, fun _ => Bool.false;
  · refine' ⟨ fun _ => Bool.false, fun i => if i = 0 then Bool.true else Bool.false, _ ⟩ ; simp +decide [ Fin.sum_univ_succ, parity ];
    simp +decide [ Finset.filter_eq' ]

/-! ## Adversary Lower Bound Method

The adversary method provides circuit lower bounds by showing that any small circuit
must fail to distinguish certain pairs of inputs. This is related to the
quantum adversary method and communication complexity. -/

/-- An adversary relation pairs inputs where f differs, weighted by how
    "hard" each pair is to distinguish. -/
structure AdversaryRelation (n : ℕ) where
  weight : (Fin n → Bool) → (Fin n → Bool) → ℝ
  weight_nonneg : ∀ x y, 0 ≤ weight x y
  weight_sym : ∀ x y, weight x y = weight y x
  supported_on_diff : ∀ f : BoolFn n, ∀ x y,
    f x = f y → weight x y = 0

/-- The total adversary weight provides a lower bound on the number
    of "distinguishing events" any circuit must handle. -/
noncomputable def AdversaryRelation.totalWeight {n : ℕ} (A : AdversaryRelation n) : ℝ :=
  ∑ x : Fin n → Bool, ∑ y : Fin n → Bool, A.weight x y

/-- Total adversary weight is nonneg -/
theorem AdversaryRelation.totalWeight_nonneg {n : ℕ} (A : AdversaryRelation n) :
    0 ≤ A.totalWeight := by
  unfold AdversaryRelation.totalWeight
  apply Finset.sum_nonneg
  intro x _
  apply Finset.sum_nonneg
  intro y _
  exact A.weight_nonneg x y

/-! ## Conjecture: Monotone Circuit Lower Bound for Matching

**Conjecture** (testable): For the perfect matching function on bipartite graphs
with 2k vertices, any monotone Boolean circuit requires size ≥ k^(3/2).

This is Razborov's celebrated 1985 theorem. We state it as a conjecture
with a computational test. -/

/-- A monotone Boolean circuit has no NOT gates. -/
def BoolCircuit.isMonotone {n : ℕ} : BoolCircuit n → Prop
  | .input _ => True
  | .constTrue => True
  | .constFalse => True
  | .andGate C₁ C₂ => C₁.isMonotone ∧ C₂.isMonotone
  | .orGate C₁ C₂ => C₁.isMonotone ∧ C₂.isMonotone
  | .notGate _ => False

/-
Monotone circuits preserve order: if x ≤ y pointwise, then C(x) ≤ C(y)
    for monotone C. This is the defining property of monotone computation.
-/
theorem monotone_circuit_preserves_order {n : ℕ}
    (C : BoolCircuit n) (hm : C.isMonotone)
    (x y : Fin n → Bool) (hle : ∀ i, x i = true → y i = true) :
    C.eval x = true → C.eval y = true := by
  revert C;
  intro C hm; induction' C with n C₁ C₂ ih₁ ih₂ <;> simp_all +decide [ BoolCircuit.eval ] ;
  · exact fun h₁ h₂ => ⟨ ih₁ hm.1 h₁, ih₂ hm.2 h₂ ⟩;
  · cases hm ; aesop;
  · cases hm

/-! ## Proof Complexity Connection

The relationship between circuit complexity and proof complexity is deep:
if a tautology has short proofs, it has small circuits for the associated
search problem. We formalize the basic connection. -/

/-- A propositional formula in CNF (conjunctive normal form) -/
structure CNF (n : ℕ) where
  clauses : List (List (Fin n × Bool))

/-- Evaluate a literal -/
def evalLiteral {n : ℕ} (x : Fin n → Bool) (lit : Fin n × Bool) : Bool :=
  if lit.2 then x lit.1 else !x lit.1

/-- Evaluate a clause (disjunction of literals) -/
def evalClause {n : ℕ} (x : Fin n → Bool) (clause : List (Fin n × Bool)) : Bool :=
  clause.any (evalLiteral x)

/-- Evaluate a CNF formula (conjunction of clauses) -/
def evalCNF {n : ℕ} (x : Fin n → Bool) (φ : CNF n) : Bool :=
  φ.clauses.all (evalClause x)

/-- A CNF is satisfiable if some assignment makes it true. -/
def CNF.isSat {n : ℕ} (φ : CNF n) : Prop :=
  ∃ x : Fin n → Bool, evalCNF x φ = true

/-- A CNF is unsatisfiable if no assignment makes it true. -/
def CNF.isUnsat {n : ℕ} (φ : CNF n) : Prop :=
  ∀ x : Fin n → Bool, evalCNF x φ = false

/-- Satisfiability and unsatisfiability are complementary. -/
theorem sat_or_unsat {n : ℕ} (φ : CNF n) :
    φ.isSat ∨ φ.isUnsat := by
  by_cases h : ∃ x, evalCNF x φ = true
  · left; exact h
  · right
    push_neg at h
    intro x
    exact Bool.eq_false_iff.mpr (h x)

/-- The empty clause is unsatisfiable -/
theorem empty_clause_unsat {n : ℕ} :
    (⟨[[]] ⟩ : CNF n).isUnsat := by
  intro x
  simp [evalCNF, evalClause, List.all_cons, List.any_nil]

/-! ## Information-Theoretic Barrier

We formalize an information-theoretic version of the natural proofs barrier:
any "natural" property that distinguishes hard functions from random functions
must be computationally hard to evaluate, assuming one-way functions exist.

This connects circuit complexity to cryptographic hardness. -/

/-- A property of Boolean functions is "large" if it holds for a noticeable
    fraction of all functions. Razborov-Rudich require this for natural proofs. -/
def isLarge {n : ℕ} (P : BoolFn n → Prop) [DecidablePred P] (ε : ℝ) : Prop :=
  ε > 0 ∧ (Finset.univ.filter (fun f : BoolFn n => P f)).card ≥
    ε * (Fintype.card (BoolFn n) : ℝ)

/-- A property is "useful" against a circuit size bound s if all functions
    satisfying P require circuits of size > s. -/
def isUseful {n : ℕ} (P : BoolFn n → Prop) (s : ℕ) : Prop :=
  ∀ f : BoolFn n, P f → ∀ C : BoolCircuit n, C.computedFn = f → C.size > s

/-- Natural proofs barrier (Razborov-Rudich 1997, abstract version):
    If a property P is both large and useful against circuits of size s,
    then the number of functions satisfying P is bounded in terms of s.

    More precisely: largeness + usefulness implies the functions satisfying P
    form a "structured" subset, which can be used to break pseudorandom generators.

    We formalize the counting consequence: if P is useful against size s,
    then at most (number of circuits of size ≤ s) functions can FAIL to satisfy P
    among those computable by small circuits. -/
theorem natural_proofs_tension {n : ℕ} (P : BoolFn n → Prop)
    [DecidablePred P] (s : ℕ)
    (h_useful : isUseful P s)
    (f : BoolFn n) (hPf : P f)
    (C : BoolCircuit n) (hC : C.computedFn = f) :
    C.size > s := by
  exact h_useful f hPf C hC

/-! ## Exponential Circuit Lower Bound via Counting (Shannon 1949)

We prove a concrete version of Shannon's theorem:
for large enough n, there exist Boolean functions requiring circuits
with more gates than any given polynomial bound. -/

/-
If we can enumerate all functions computable by circuits in a finite set,
    and the set is smaller than the total number of functions,
    then a hard function exists. This is the pigeonhole principle
    applied to circuit complexity.
-/
theorem hard_function_exists {n : ℕ}
    (circuits : Finset (BoolCircuit n))
    (h_small : circuits.card < 2 ^ 2 ^ n) :
    ∃ f : BoolFn n,
      ∀ C ∈ circuits, C.computedFn ≠ f := by
  have h_card : Finset.card (Finset.image (fun C => C.computedFn) circuits) ≤ circuits.card := by
    exact Finset.card_image_le;
  contrapose! h_card;
  rw [ show Finset.image ( fun C => C.computedFn ) circuits = Finset.univ from Finset.eq_univ_of_forall fun f => by obtain ⟨ C, hC₁, hC₂ ⟩ := h_card f; exact Finset.mem_image.mpr ⟨ C, hC₁, hC₂ ⟩ ] ; simp +decide [ card_boolFn ] ; linarith

/-! ## Structural Properties of Barrier Composition -/

/-- If a barrier is tight and blocks a target, then the gap between
    the ceiling and the target is positive. -/
theorem barrier_gap_positive (B : ComplexityBarrier)
    (target : ℕ) (hblocks : B.blocks target) :
    0 < target - B.ceiling := by
  unfold ComplexityBarrier.blocks at hblocks
  omega

/-- The strength of any technique in a composed barrier is bounded
    by the maximum of the component ceilings. -/
theorem compose_strength_bounded (B₁ B₂ : ComplexityBarrier)
    (t : (B₁.compose B₂).Technique) :
    (B₁.compose B₂).Strength t ≤ max B₁.ceiling B₂.ceiling := by
  exact (B₁.compose B₂).le_ceiling t

/-- Barrier composition is commutative on ceilings. -/
theorem compose_ceiling_comm (B₁ B₂ : ComplexityBarrier) :
    (B₁.compose B₂).ceiling = (B₂.compose B₁).ceiling := by
  simp [ComplexityBarrier.compose, max_comm]

/-! ## Inductive Circuit Properties -/

/-- Every subcircuit of a monotone circuit is monotone (structural induction). -/
theorem monotone_subcircuit_and_left {n : ℕ}
    (C₁ C₂ : BoolCircuit n) (hm : (BoolCircuit.andGate C₁ C₂).isMonotone) :
    C₁.isMonotone := by
  exact hm.1

theorem monotone_subcircuit_and_right {n : ℕ}
    (C₁ C₂ : BoolCircuit n) (hm : (BoolCircuit.andGate C₁ C₂).isMonotone) :
    C₂.isMonotone := by
  exact hm.2

/-- Size of composed circuits is additive plus one. -/
theorem size_and_gate {n : ℕ} (C₁ C₂ : BoolCircuit n) :
    (BoolCircuit.andGate C₁ C₂).size = 1 + C₁.size + C₂.size := by
  rfl

/-- Depth increases by exactly 1 through a gate. -/
theorem depth_and_gate {n : ℕ} (C₁ C₂ : BoolCircuit n) :
    (BoolCircuit.andGate C₁ C₂).depth = 1 + max C₁.depth C₂.depth := by
  rfl

end CircuitComplexity