/-
# Termination certificates for finite cop-win pruning algorithms

Many implementations of the `k`-copwin recognition algorithm repeatedly delete
positions that fail a local survival test.  The local test varies between
implementations, but the global termination argument depends only on one fact:
each round returns a subset of the current finite state space.  This chapter
isolates that invariant and gives a sharp stabilization bound.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): Ranked by expected impact, the cycle tested six
  conjectures: (1) contracting elimination stabilizes within the initial
  cardinality; (2) monotone elimination computes the greatest fixed candidate
  set below its input; (3) asynchronous fair deletion has the same kernel;
  (4) a product-state `k`-cop game inherits a polynomial round bound; (5) the
  finite theorem extends to well-founded infinite candidate spaces; and (6)
  deletion certificates can be replayed independently of move ordering.  The
  first two were selected for full investigation because together they isolate
  termination and semantic maximality.
Experiment (Experimenter): The update was abstracted as a function on finite
  candidate sets with a subset certificate.  Cardinality is a ranking function;
  a non-fixed round is a strict inclusion and therefore decreases cardinality.
  The paper signal contrasting theory with implementation motivated separating
  this representation-independent certificate from the local game operator.
Analysis (Analyst): The resulting bound is independent of graph representation,
  cop count, move ordering, and the local domination predicate.  This separates
  the graph-theoretic correctness obligation from the algorithmic termination
  obligation and connects finite combinatorics with well-founded rewriting.
Critique (Critic): The subset hypothesis is essential: on two states, an update
  swapping the two singleton sets never stabilizes.  The bound is sharp for an
  update deleting exactly one candidate per round.  Empty candidate sets and a
  zero-round bound are included, so no hidden nonemptiness assumption remains.
Synthesis (Principal Investigator): Contracting cop-win pruning has both a
  well-founded transition certificate and a cardinality-bounded fixed point.
  Concrete deletion examples attain the bound, while an explicit oscillation
  records the boundary beyond contraction.
-- !-- Lab Notes -- !--
-/

import Shared.PosetTheory.TreeComplexity
import Mathlib

open Finset

namespace KCopwinTermination

variable {α : Type*}

/-- Iteration of one pruning round. -/
def rounds (F : Finset α → Finset α) : ℕ → Finset α → Finset α
  | 0, S => S
  | n + 1, S => F (rounds F n S)

/-- A contracting update never introduces a candidate. -/
def Contracting (F : Finset α → Finset α) : Prop :=
  ∀ S, F S ⊆ S

/-- A monotone update preserves inclusion of candidate sets. -/
def MonotoneUpdate (F : Finset α → Finset α) : Prop :=
  ∀ ⦃S T⦄, S ⊆ T → F S ⊆ F T

/-
Every later round is contained in the preceding round.
-/
lemma rounds_succ_subset (F : Finset α → Finset α) (hF : Contracting F)
    (n : ℕ) (S : Finset α) :
    rounds F (n + 1) S ⊆ rounds F n S := by
  exact hF _

/-
Once a round is fixed, all later rounds have the same value.
-/
lemma rounds_fixed_forever (F : Finset α → Finset α) {n : ℕ} {S : Finset α}
    (hfix : rounds F (n + 1) S = rounds F n S) (m : ℕ) :
    rounds F (n + m) S = rounds F n S := by
  induction m <;> simp_all +decide [rounds]

/-
A proper deletion step strictly decreases finite cardinality.
-/
lemma strict_card_descent {S T : Finset α} (h : T ⊂ S) : T.card < S.card := by
  exact Finset.card_lt_card h

/-
Proper-deletion execution is well-founded, by reuse of the catalog's generic
natural-valued termination principle.
-/
theorem strict_deletion_wellFounded :
    WellFounded (fun T S : Finset α => T ⊂ S) := by
  apply Learning.TreeComplexity.terminates Finset.card (fun S T : Finset α => T ⊂ S)
  intro S T h
  exact strict_card_descent h

/-
If the first `n` rounds all change the candidate set, at least `n`
candidates have disappeared.
-/
lemma card_rounds_add_le (F : Finset α → Finset α) (hF : Contracting F)
    (S : Finset α) (n : ℕ)
    (hchange : ∀ i < n, rounds F (i + 1) S ≠ rounds F i S) :
    (rounds F n S).card + n ≤ S.card := by
  induction' n with n ih <;> simp_all +decide [ rounds ];
  have h_card : #(F (rounds F n S)) < #(rounds F n S) := by
    exact Finset.card_lt_card ( lt_of_le_of_ne ( hF _ ) ( hchange _ le_rfl ) );
  linarith [ ih fun i hi => hchange i hi.le ]

/-
**Sharp finite stabilization theorem.** Every contracting finite-state
pruning algorithm reaches a fixed point in at most as many rounds as there are
initial candidates.
-/
theorem exists_fixed_round_le_card (F : Finset α → Finset α) (hF : Contracting F)
    (S : Finset α) :
    ∃ n ≤ S.card, rounds F (n + 1) S = rounds F n S := by
  by_contra! h;
  convert card_rounds_add_le F hF S ( S.card + 1 ) _ using 1;
  · grind;
  · exact fun i hi => h i ( Nat.le_of_lt_succ hi )

/-
A fixed-point certificate also describes every subsequent implementation
round, not merely the first repeated pair.
-/
theorem eventual_constancy (F : Finset α → Finset α) (hF : Contracting F)
    (S : Finset α) :
    ∃ n ≤ S.card, ∀ m, rounds F (n + m) S = rounds F n S := by
  obtain ⟨ n, hn ⟩ := exists_fixed_round_le_card F hF S;
  exact ⟨ n, hn.1, fun m => rounds_fixed_forever F hn.2 m ⟩

/-
A fixed set initially contained in the candidates survives every round of
monotone pruning.
-/
lemma fixed_subset_rounds (F : Finset α → Finset α) (hmono : MonotoneUpdate F)
    {T S : Finset α} (hfix : F T = T) (hTS : T ⊆ S) (n : ℕ) :
    T ⊆ rounds F n S := by
  induction' n with n ih;
  · exact hTS;
  · exact hfix ▸ hmono ih

/-
**Greatest fixed-kernel theorem.** For a contracting monotone update, the
bounded stabilization result computes not just some fixed point but the greatest
fixed candidate set lying below the initial set.
-/
theorem exists_greatest_fixed_kernel (F : Finset α → Finset α)
    (hcontract : Contracting F) (hmono : MonotoneUpdate F) (S : Finset α) :
    ∃ K ⊆ S, F K = K ∧ ∀ T ⊆ S, F T = T → T ⊆ K := by
  obtain ⟨ n, hn, h ⟩ := exists_fixed_round_le_card F hcontract S;
  refine' ⟨ rounds F n S, _, _, _ ⟩;
  · exact Nat.recOn n ( by tauto ) fun n ihn => by exact Finset.Subset.trans ( rounds_succ_subset F hcontract n S ) ihn;
  · exact h;
  · intro T hTS hT
    exact fixed_subset_rounds F hmono hT hTS n

/-- Deleting the least natural candidate models a maximally slow serial
implementation. -/
def deleteMin (S : Finset ℕ) : Finset ℕ :=
  if h : S.Nonempty then S.erase (S.min' h) else S

lemma deleteMin_contracting : Contracting deleteMin := by
  intro S;
  unfold deleteMin;
  grind

/-- Concrete example: serial deletion from four candidates takes four changing
rounds before the empty fixed point is reached. -/
example : rounds deleteMin 4 {0, 1, 2, 3} = ∅ ∧
    ∀ i < 4, rounds deleteMin (i + 1) {0, 1, 2, 3} ≠
      rounds deleteMin i {0, 1, 2, 3} := by
  native_decide

/-- Boundary example: without contraction, even a two-state update can oscillate
forever between singleton candidate sets. -/
def swapSingleton (S : Finset (Fin 2)) : Finset (Fin 2) :=
  if S = {0} then {1} else {0}

example : ∀ n, rounds swapSingleton (2 * n) {0} = {0} ∧
    rounds swapSingleton (2 * n + 1) {0} = {1} := by
  intro n; induction n <;> simp_all +decide [ Nat.mul_succ, rounds ] ;

end KCopwinTermination