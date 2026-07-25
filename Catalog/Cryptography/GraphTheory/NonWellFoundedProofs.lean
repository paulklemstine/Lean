import Mathlib
import Logic.StrangeLoops.Core

/-!
# Guarded Circular Proof Graphs

Circular proof diagrams are separated here from their mathematical justification.
A diagram may contain back-edges, but an ordinal certificate must strictly decrease
along every dependency. This gives a precise boundary: guarded diagrams unfold to
ordinary derivations, while a genuine self-loop has no ordinal certificate.

The central positive example is the derivation of `P ⟶ P`: its root has ordinal
height one and its unique child is the height-zero assumption of `P`. The example is
not a genuine cycle. This distinction prevents the ordinary implication-introduction
argument from being misidentified as self-justification.
-/

namespace NonWellFoundedProofs

/-- Propositional formulas used by the proof-graph calculus. -/
inductive Formula (Atom : Type*) where
  | atom : Atom → Formula Atom
  | imp : Formula Atom → Formula Atom → Formula Atom
  deriving DecidableEq, Repr

infixr:55 " ⟶ " => Formula.imp

/-- Ordinary natural-deduction derivability for implication. -/
inductive Derives {Atom : Type*} : List (Formula Atom) → Formula Atom → Prop where
  | assumption {Γ A} : A ∈ Γ → Derives Γ A
  | impIntro {Γ A B} : Derives (A :: Γ) B → Derives Γ (A ⟶ B)

/-- Local instructions carried by nodes of a finite or infinite proof diagram. -/
inductive Rule (Atom Node : Type*) where
  | assumption
  | impIntro (antecedent consequent : Formula Atom) (child : Node)

/-- A proof graph records sequents and local instructions without assuming that its
underlying dependency graph is well founded. -/
structure ProofGraph (Atom Node : Type*) where
  context : Node → List (Formula Atom)
  conclusion : Node → Formula Atom
  rule : Node → Rule Atom Node

/-- Every node satisfies the local typing condition of its instruction. -/
def ProofGraph.WellTyped {Atom Node : Type*} (G : ProofGraph Atom Node) : Prop :=
  ∀ n, match G.rule n with
    | .assumption => G.conclusion n ∈ G.context n
    | .impIntro A B child =>
        G.conclusion n = A ⟶ B ∧
        G.context child = A :: G.context n ∧
        G.conclusion child = B

/-- An ordinal ranking guards every back-reference by strict descent. -/
def ProofGraph.Guarded {Atom Node : Type*} (G : ProofGraph Atom Node)
    (rank : Node → Ordinal) : Prop :=
  ∀ n, match G.rule n with
    | .assumption => True
    | .impIntro _ _ child => rank child < rank n

/-- Guarded local proof graphs unfold to ordinary natural-deduction derivations. -/
theorem guarded_graph_sound {Atom Node : Type*} (G : ProofGraph Atom Node)
    (rank : Node → Ordinal) (typed : G.WellTyped) (guarded : G.Guarded rank) :
    ∀ n, Derives (G.context n) (G.conclusion n) := by
  intro n
  let dependency : Node → Node → Prop := fun a b => rank a < rank b
  have dependency_wf : WellFounded dependency := InvImage.wf rank Ordinal.lt_wf
  apply dependency_wf.induction n
  intro current ih
  have local_typed := typed current
  have local_guarded := guarded current
  cases rule_eq : G.rule current with
  | assumption =>
      exact Derives.assumption (by simpa [ProofGraph.WellTyped, rule_eq] using local_typed)
  | impIntro A B child =>
      have facts : G.conclusion current = A ⟶ B ∧
          G.context child = A :: G.context current ∧ G.conclusion child = B := by
        simpa [ProofGraph.WellTyped, rule_eq] using local_typed
      have child_decreases : dependency child current := by
        simpa [ProofGraph.Guarded, dependency, rule_eq] using local_guarded
      have child_derivation := ih child child_decreases
      rw [facts.2.1, facts.2.2] at child_derivation
      rw [facts.1]
      exact Derives.impIntro child_derivation

/-
No strict ordinal ranking can certify a direct self-reference.
-/
theorem no_guarded_self_reference {Node : Type*} (rank : Node → Ordinal) (n : Node) :
    ¬ rank n < rank n := by
  lia

/-
A cyclic dependency relation admitting a strict ordinal ranking is acyclic along
all nonempty finite dependency paths.
-/
theorem no_ranked_dependency_cycle {Node : Type*} (edge : Node → Node → Prop)
    (rank : Node → Ordinal) (decreases : ∀ a b, edge a b → rank b < rank a) :
    ∀ n : ℕ, 0 < n → ∀ path : Fin (n + 1) → Node,
      (∀ i : Fin n, edge (path ⟨i, Nat.lt_trans i.isLt (Nat.lt_succ_self n)⟩)
        (path ⟨i + 1, Nat.succ_lt_succ i.isLt⟩)) → path 0 ≠ path ⟨n, Nat.lt_succ_self n⟩ := by
  intro n hn path hpath;
  -- By induction on $i$, we can show that $rank(path(i)) < rank(path(0))$ for all $i > 0$.
  have h_ind : ∀ i : Fin (n + 1), i ≠ 0 → rank (path i) < rank (path 0) := by
    intro i hi; induction i using Fin.inductionOn <;> simp_all +decide ;
    grind;
  exact fun h => ne_of_lt ( h_ind ⟨ n, Nat.lt_succ_self _ ⟩ ( ne_of_gt ( Nat.pos_of_ne_zero hn.ne' ) ) ) ( by simp +decide [ h ] )

section Identity

variable {Atom : Type*} (P : Formula Atom)

/-- The two nodes of the height-one identity derivation: root `false`, leaf `true`. -/
def identityGraph : ProofGraph Atom Bool where
  context
    | false => []
    | true => [P]
  conclusion
    | false => P ⟶ P
    | true => P
  rule
    | false => .impIntro P P true
    | true => .assumption

/-- Ordinal height of the identity graph. -/
def identityRank : Bool → Ordinal
  | false => 1
  | true => 0

/-
The identity diagram is locally typed.
-/
theorem identityGraph_wellTyped : (identityGraph P).WellTyped := by
  intro n;
  cases n <;> tauto

/-
The identity diagram is guarded by the ordinal ranking `1 > 0`.
-/
theorem identityGraph_guarded : (identityGraph P).Guarded identityRank := by
  intro n;
  cases n <;> simp +decide [ identityGraph, identityRank ]

/-
**Height-one identity theorem.** The root has ordinal height one, its assumption
leaf has height zero, and unfolding the guarded graph yields `P ⟶ P`.
-/
theorem identity_height_one :
    identityRank false = 1 ∧ identityRank true = 0 ∧ Derives [] (P ⟶ P) := by
  refine ⟨rfl, rfl, ?_⟩
  exact guarded_graph_sound (identityGraph P) (identityRank : Bool → Ordinal.{0})
    (identityGraph_wellTyped P) (identityGraph_guarded (P := P)) false

end Identity

/-
A pure self-loop is rejected by every ordinal guard. This is the structural
obstruction shared by unproductive circular arguments and liar-style loops.
-/
theorem pure_loop_has_no_ordinal_height (n : Unit) :
    ¬ ∃ rank : Unit → Ordinal, rank n < rank n := by
  grind +qlia

/-
In a sound diagonal system, the Gödel sentence asserting its own unprovability
is unprovable. This imports the semantic diagonal obstruction and places it beside
the structural ordinal obstruction above.
-/
theorem diagonal_liar_unprovable (L : StrangeLoop) :
    ¬ L.Provable L.goedelSentence := by
  exact StrangeLoop.goedel_true_unprovable L |>.2

/-
-- !-- Lab Notes -- !--

HYPOTHESIS (Hypothesizer):
  H1 [cross-domain, proof theory × ordinal theory]: every locally typed proof graph
     with strictly decreasing ordinal dependencies unfolds to an ordinary derivation.
  H2 [cross-domain, domain theory × logic]: productive circular proofs should be
     describable as least fixed points of finite approximants.
  H3 [bold, topology × proof theory]: observational proof trees form an algebraic
     Scott domain whose compact elements are finite unfoldings.
  H4 [Gödel program]: liar-style negative self-reference cannot carry a decreasing
     ordinal certificate.
  H5 [P versus NP program]: polynomially checkable guarded cyclic certificates do
     not yield polynomial certificates for arbitrary coNP tautologies.
  H6 [cryptography × proof complexity]: guarded recursive security reductions admit
     finite ordinal certificates stable under protocol composition.

EXPERIMENT (Experimenter):
  H1 was reduced to well-founded induction on ordinal rank. The concrete identity
  graph was tested at ranks one and zero. Direct self-reference was tested against
  irreflexivity, and arbitrary finite return paths against transitivity of descent.

ANALYSIS (Analyst):
  H1 and H4 survive. The proposed self-referential reading of `P ⟶ P` fails: its
  valid height-one proof is an ordinary two-node tree, not a cycle. A genuine cycle
  cannot decrease at every edge in any ordinal. H2 and H3 need a choice between
  least-fixed-point semantics, which rejects unsupported loops, and greatest-fixed-
  point semantics, which admits them and therefore needs an independent productivity
  or trace condition.

CRITIQUE (Critic):
  No theorem treats circularity as justification. Local typing alone is deliberately
  insufficient; ordinal descent is the load-bearing condition. The liar result uses
  soundness and a diagonal specification, while the graph result proves only the
  precise structural claim that a self-loop has no decreasing ordinal rank. These
  two claims are not conflated.

SYNTHESIS (Principal Investigator):
  The consistent core is a guarded-proof principle: non-tree syntax is harmless only
  when every dependency decreases in a well-founded rank. Such a certificate erases
  apparent circularity by unfolding it into an ordinary derivation. Unsupported
  self-reference is excluded rather than promoted to a new proof rule.
-/

end NonWellFoundedProofs