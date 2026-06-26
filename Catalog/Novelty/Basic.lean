import Mathlib

/-!
# Monotone Boolean circuit complexity: foundations

We formalize *monotone Boolean circuits* over an arbitrary index type `ι` of input
variables.  A monotone circuit is built from input variables, the two constants,
and the two binary gates AND and OR (no negation).  We define evaluation, size,
depth and the set of variables read, and prove the foundational structural
results of monotone circuit complexity:

* `eval_monotone` — every monotone circuit computes a monotone Boolean function;
* `eval_eq_of_agree_on_vars` — a circuit only depends on the variables it reads;
* `dependsOn_mem_vars` — a *relevant* variable must appear in the circuit;
* `card_vars_le_size` — the number of distinct variables read is a lower bound on
  the size, hence the number of relevant variables lower-bounds the size
  (the elementary "relevant-variable" circuit lower bound).

These results are reused by the Karchmer–Wigderson connection
(`KarchmerWigderson.lean`) and the CLIQUE lower bound (`Clique.lean`).

-- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer): monotone circuits compute exactly the monotone Boolean
functions, and the set of variables physically read by a circuit controls both
which functions it can compute and its size.

EXPERIMENT (Experimenter): define circuits as an inductive type over a generic
index `ι` and prove the four structural lemmas by structural induction.

ANALYSIS (Analyst): all four go through by induction; the subtle point is that the
"relevant variable" notion (`DependsOn`) must be phrased with `Function.update` so
that the agreement lemma applies on the two updated inputs.

CRITIQUE (Critic): none of the lemmas is vacuous — `eval_monotone` genuinely uses
the AND/OR semantics, and `card_vars_le_size` is a true (if elementary) lower
bound that is later instantiated to give a quadratic lower bound for CLIQUE.

SYNTHESIS (PI): these foundations support both the KW depth/communication
correspondence and the relevant-variable size lower bound for CLIQUE.
-/

namespace CircuitComplexity

/-- A monotone Boolean circuit over input variables indexed by `ι`:
variables, the two constants, and the AND/OR gates. -/
inductive MCircuit (ι : Type*) where
  | var : ι → MCircuit ι
  | top : MCircuit ι
  | bot : MCircuit ι
  | and : MCircuit ι → MCircuit ι → MCircuit ι
  | or  : MCircuit ι → MCircuit ι → MCircuit ι
  deriving Repr

namespace MCircuit

variable {ι : Type*}

/-- Boolean value computed by a monotone circuit on an input assignment. -/
def eval : MCircuit ι → (ι → Bool) → Bool
  | var i, x => x i
  | top, _ => true
  | bot, _ => false
  | and a b, x => eval a x && eval b x
  | or a b, x => eval a x || eval b x

/-- Size of a circuit: the number of nodes (gates and leaves). -/
def size : MCircuit ι → ℕ
  | var _ => 1
  | top => 1
  | bot => 1
  | and a b => size a + size b + 1
  | or a b => size a + size b + 1

/-- Depth of a circuit: the longest path from the output to a leaf. -/
def depth : MCircuit ι → ℕ
  | var _ => 0
  | top => 0
  | bot => 0
  | and a b => max (depth a) (depth b) + 1
  | or a b => max (depth a) (depth b) + 1

/-- The finite set of variables that occur in the circuit. -/
def vars [DecidableEq ι] : MCircuit ι → Finset ι
  | var i => {i}
  | top => ∅
  | bot => ∅
  | and a b => vars a ∪ vars b
  | or a b => vars a ∪ vars b

@[simp] theorem eval_var (i : ι) (x : ι → Bool) : (var i).eval x = x i := rfl
@[simp] theorem eval_top (x : ι → Bool) : (top : MCircuit ι).eval x = true := rfl
@[simp] theorem eval_bot (x : ι → Bool) : (bot : MCircuit ι).eval x = false := rfl
@[simp] theorem eval_and (a b : MCircuit ι) (x : ι → Bool) :
    (and a b).eval x = (a.eval x && b.eval x) := rfl
@[simp] theorem eval_or (a b : MCircuit ι) (x : ι → Bool) :
    (or a b).eval x = (a.eval x || b.eval x) := rfl

/-
**Monotone circuits compute monotone functions.**  If `x` is pointwise below
`y` (every variable true in `x` is true in `y`), then a true output on `x` forces
a true output on `y`.
-/
theorem eval_monotone (C : MCircuit ι) {x y : ι → Bool}
    (h : ∀ i, x i = true → y i = true) :
    C.eval x = true → C.eval y = true := by
  induction' C with i a b ih_a ih_b;
  · exact h i;
  · exact fun _ => rfl;
  · exact fun h => by cases h;
  · simp_all +decide [ MCircuit.eval ];
  · intro hxy; simp_all +decide [ MCircuit.eval ] ;
    grobner

/-
A circuit only depends on the variables it actually reads: assignments that
agree on `C.vars` produce the same output.
-/
theorem eval_eq_of_agree_on_vars [DecidableEq ι] (C : MCircuit ι) {x y : ι → Bool}
    (h : ∀ i ∈ C.vars, x i = y i) : C.eval x = C.eval y := by
  induction' C with i a b ih_a ih_b;
  · exact h i ( by simp +decide [ MCircuit.vars ] );
  · rfl;
  · rfl;
  · simp_all +decide [ MCircuit.vars ];
  · grind +locals

/-- A variable `i` is *relevant* to a Boolean function `f` if flipping it (with all
other coordinates held fixed at some assignment) can change the output. -/
def DependsOn [DecidableEq ι] (f : (ι → Bool) → Bool) (i : ι) : Prop :=
  ∃ x : ι → Bool, f (Function.update x i true) ≠ f (Function.update x i false)

/-
Every relevant variable of the function computed by `C` must occur in `C`.
-/
theorem dependsOn_mem_vars [DecidableEq ι] (C : MCircuit ι) {i : ι}
    (h : DependsOn C.eval i) : i ∈ C.vars := by
  contrapose! h;
  intro x;
  obtain ⟨ x, hx ⟩ := x
  have h_agree : ∀ j ∈ C.vars, Function.update x i true j = Function.update x i false j := by
    grind +splitImp;
  exact hx ( eval_eq_of_agree_on_vars C h_agree )

/-
The number of distinct variables read is a lower bound on the circuit size.
-/
theorem card_vars_le_size [DecidableEq ι] (C : MCircuit ι) :
    C.vars.card ≤ C.size := by
  -- We proceed by induction on the structure of the circuit `C`.
  induction' C with i a b ha hb;
  · exact Finset.card_singleton i ▸ by rfl;
  · exact Nat.zero_le _;
  · exact Nat.zero_le _;
  · grind +locals;
  · rename_i a b ha hb;
    exact le_trans ( Finset.card_union_le _ _ ) ( by linarith [ show ( a.or b ).size = a.size + b.size + 1 from rfl ] )

/-
**Relevant-variable lower bound.**  If every variable in a finite set `R` is
relevant to the function computed by `C`, then `|R| ≤ size C`.
-/
theorem card_le_size_of_relevant [DecidableEq ι] (C : MCircuit ι) (R : Finset ι)
    (hR : ∀ i ∈ R, DependsOn C.eval i) : R.card ≤ C.size := by
  refine' le_trans _ ( card_vars_le_size C );
  exact Finset.card_le_card fun i hi => dependsOn_mem_vars C ( hR i hi )

end MCircuit
end CircuitComplexity