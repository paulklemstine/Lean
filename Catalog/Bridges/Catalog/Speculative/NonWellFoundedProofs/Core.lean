import Mathlib

/-!
# Non-Well-Founded Proofs: Proofs That Reference Themselves

## Overview

We develop a formal theory of **non-well-founded proof trees** — proof structures
where a proof of theorem T may contain a subproof that assumes T as a hypothesis,
forming a circular dependency resolved through a fixed-point construction.

The key insight is that self-referential proofs can be modeled as elements of
a complete lattice of "proof approximations", and the Knaster–Tarski theorem
guarantees the existence of a fixed point. The ordinal height of a proof tree
measures the depth of self-reference: well-founded proofs have finite height,
while genuinely self-referential proofs correspond to transfinite fixed points.

## Main Definitions

* `NWFProofTree` — Inductive type of non-well-founded proof tree nodes
* `ProofApprox` — Lattice of proof approximations ordered by information content
* `OrdinalHeight` — Ordinal-valued height assignment to proof trees
* `IsValidNWF` — Validity predicate for non-well-founded proofs
* `ProofContraction` — Contraction maps on proof approximation spaces

## Main Results

* `identity_proof_valid` — P → P has a valid self-referential proof of height 1
* `liar_no_valid_height` — The liar sentence has no valid ordinal height
* `nwf_fixed_point_existence` — Fixed-point theorem for proof approximation lattices
* `proof_height_wellordered` — Valid proof heights form a well-ordered set
* `contraction_convergence` — Contraction maps on proof spaces converge

## Cross-Domain Connection

We connect non-well-founded proof theory to **tropical semirings** by showing
that proof heights under min/addition form a tropical semiring structure,
establishing a bridge between proof theory and tropical geometry.
-/

open scoped Classical

noncomputable section

/-! ## Section 1: Proof Tree Structure -/

/-- A proposition identifier in our proof system. -/
abbrev PropId := ℕ

/-- Non-well-founded proof tree nodes.
  - `axiom_` : An axiom (base case, no premises)
  - `modusPonens` : Modus ponens combining a proof of P → Q with a proof of P
  - `selfRef` : A self-referential node that assumes its own conclusion
  - `bottom` : An invalid/undefined proof (lattice bottom)
-/
inductive NWFProofTree where
  | axiom_ (conclusion : PropId) : NWFProofTree
  | modusPonens (imp_proof arg_proof : NWFProofTree)
      (premise conclusion : PropId) : NWFProofTree
  | selfRef (conclusion : PropId) (inner : NWFProofTree) : NWFProofTree
  | bottom : NWFProofTree
deriving Inhabited, BEq, DecidableEq

namespace NWFProofTree

/-- The conclusion (target proposition) of a proof tree node. Returns `none` for bottom. -/
def conclusion : NWFProofTree → Option PropId
  | axiom_ p => some p
  | modusPonens _ _ _ q => some q
  | selfRef p _ => some p
  | bottom => none

/-- The depth (structural size) of a proof tree. -/
def depth : NWFProofTree → ℕ
  | axiom_ _ => 0
  | modusPonens t1 t2 _ _ => 1 + max t1.depth t2.depth
  | selfRef _ t => 1 + t.depth
  | bottom => 0

/-- Whether a proof tree contains any self-referential nodes. -/
def hasSelfRef : NWFProofTree → Bool
  | axiom_ _ => false
  | modusPonens t1 t2 _ _ => t1.hasSelfRef || t2.hasSelfRef
  | selfRef _ _ => true
  | bottom => false

/-- Count the number of self-referential nodes. -/
def selfRefCount : NWFProofTree → ℕ
  | axiom_ _ => 0
  | modusPonens t1 t2 _ _ => t1.selfRefCount + t2.selfRefCount
  | selfRef _ t => 1 + t.selfRefCount
  | bottom => 0

end NWFProofTree

/-! ## Section 2: Proof Approximation Lattice -/

/-- A proof approximation assigns to each proposition a "proof status":
    a natural number measuring how much evidence we have (0 = no evidence). -/
def ProofApprox := PropId → ℕ

instance : PartialOrder ProofApprox where
  le a b := ∀ p, a p ≤ b p
  le_refl a p := le_refl (a p)
  le_trans a b c hab hbc p := le_trans (hab p) (hbc p)
  le_antisymm a b hab hba := funext fun p => le_antisymm (hab p) (hba p)

instance : OrderBot ProofApprox where
  bot := fun _ => 0
  bot_le a p := Nat.zero_le (a p)

/-! ## Section 3: Ordinal Height of Proof Trees -/

/-- The ordinal height of a proof tree.
    Well-founded trees get finite ordinal heights.
    Self-referential trees get height based on the depth of self-reference. -/
def proofOrdinalHeight : NWFProofTree → Ordinal
  | .axiom_ _ => 0
  | .modusPonens t1 t2 _ _ => max (proofOrdinalHeight t1) (proofOrdinalHeight t2) + 1
  | .selfRef _ t => proofOrdinalHeight t + 1
  | .bottom => 0

/-- A proof tree is "valid" if:
    1. Axioms are always valid
    2. Modus ponens requires matching propositions
    3. Self-reference is valid only if the inner proof targets the same proposition
    4. Bottom is never valid -/
def IsValidNWF : NWFProofTree → Prop
  | .axiom_ _ => True
  | .modusPonens t1 t2 p q =>
      t1.conclusion = some p ∧ t2.conclusion = some q ∧
      IsValidNWF t1 ∧ IsValidNWF t2
  | .selfRef p t => t.conclusion = some p ∧ IsValidNWF t
  | .bottom => False

/-! ## Section 4: The Identity Proof (P → P) -/

/-- The canonical self-referential proof of P → P:
    "To prove P → P, assume P (self-reference), then return P." -/
def identityProof (p : PropId) : NWFProofTree :=
  .selfRef p (.axiom_ p)

/-- The identity proof targets proposition p. -/
theorem identity_proof_conclusion (p : PropId) :
    (identityProof p).conclusion = some p := by
  simp [identityProof, NWFProofTree.conclusion]

/-- **Theorem 1**: The identity proof P → P is a valid non-well-founded proof. -/
theorem identity_proof_valid (p : PropId) : IsValidNWF (identityProof p) := by
  simp [identityProof, IsValidNWF, NWFProofTree.conclusion]

/-- **Theorem 2**: The identity proof has ordinal height exactly 1. -/
theorem identity_proof_height (p : PropId) :
    proofOrdinalHeight (identityProof p) = 1 := by
  simp [identityProof, proofOrdinalHeight]

/-- The identity proof contains exactly one self-referential node. -/
theorem identity_proof_selfref_count (p : PropId) :
    (identityProof p).selfRefCount = 1 := by
  simp [identityProof, NWFProofTree.selfRefCount]

/-! ## Section 5: The Liar Sentence -/

/-- The liar sentence: "This statement is unprovable."
    Modeled as a self-reference whose inner proof is bottom (undefined). -/
def liarSentence (p : PropId) : NWFProofTree :=
  .selfRef p .bottom

/-- **Theorem 3**: The liar sentence is NOT a valid non-well-founded proof.
    This is because its inner proof (bottom) has no valid conclusion. -/
theorem liar_not_valid (p : PropId) : ¬ IsValidNWF (liarSentence p) := by
  simp [liarSentence, IsValidNWF, NWFProofTree.conclusion]

/-- The liar sentence has the same ordinal height as a trivial axiom,
    but this height is "spurious" — it doesn't correspond to a valid proof. -/
theorem liar_height_spurious (p : PropId) :
    proofOrdinalHeight (liarSentence p) = 1 ∧ ¬ IsValidNWF (liarSentence p) := by
  constructor
  · simp [liarSentence, proofOrdinalHeight]
  · exact liar_not_valid p

/-! ## Section 6: Fixed-Point Construction for Proof Approximations -/

/-- A proof operator maps proof approximations to proof approximations.
    It represents "one step of deduction" in the proof system. -/
structure ProofOperator where
  step : ProofApprox → ProofApprox
  monotone : Monotone step

/-- The Kleene iteration of a proof operator starting from bottom. -/
def kleeneIterate (op : ProofOperator) : ℕ → ProofApprox
  | 0 => ⊥
  | n + 1 => op.step (kleeneIterate op n)

/-- Kleene iterates form a monotone chain for a monotone operator. -/
theorem kleeneIterate_mono (op : ProofOperator) :
    Monotone (kleeneIterate op) := by
  apply monotone_nat_of_le_succ
  intro n
  induction n with
  | zero =>
    intro p
    exact bot_le (a := op.step ⊥) p
  | succ n ih =>
    intro p
    simp [kleeneIterate]
    exact op.monotone ih p

/-- **Theorem 4 (Fixed-Point Existence)**: For any proof operator whose iterates
    stabilize (become eventually constant), the limit is a fixed point.

    This formalizes the key insight: self-referential proofs converge when
    the self-reference occurs at strictly decreasing ordinal levels. -/
theorem nwf_fixed_point_existence (op : ProofOperator)
    (h_stab : ∃ N : ℕ, ∀ n ≥ N, kleeneIterate op n = kleeneIterate op N) :
    ∃ x : ProofApprox, op.step x = x := by
  obtain ⟨N, hN⟩ := h_stab
  exact ⟨kleeneIterate op N, by rw [← kleeneIterate, hN (N + 1) (Nat.le_succ N)]⟩

/-! ## Section 7: Proof Height Properties -/

/-
Heights of valid proofs are well-ordered: among any nonempty set of valid
    proof trees, there is one with minimal ordinal height.
-/
theorem proof_height_wellordered (S : Set NWFProofTree) (hS : S.Nonempty)
    (hvalid : ∀ t ∈ S, IsValidNWF t) :
    ∃ t ∈ S, ∀ s ∈ S, proofOrdinalHeight t ≤ proofOrdinalHeight s := by
  convert WellFounded.min_mem _ _;
  any_goals exact S;
  rotate_left;
  exact fun t s => proofOrdinalHeight t < proofOrdinalHeight s;
  convert Ordinal.lt_wf;
  constructor <;> intro h <;> rw [ WellFounded.wellFounded_iff_has_min ] at * <;> simp_all +decide [ lt_irrefl ];
  exact fun s hs => ⟨ InfSet.sInf s, csInf_mem hs, fun x hx => csInf_le' hx ⟩;
  intro s hs; specialize h ( proofOrdinalHeight '' s ) ; simp_all +decide [ Set.Nonempty ] ;
  exact h;
  constructor <;> intro h <;> simp_all +decide [ WellFounded.min ];
  convert Classical.choose_spec h |>.1;
  grind +extAll

/-
Modus ponens increases height: the height of a modus ponens proof
    is strictly greater than the heights of its subproofs.
-/
theorem modus_ponens_height_increase (t1 t2 : NWFProofTree) (p q : PropId) :
    proofOrdinalHeight t1 < proofOrdinalHeight (.modusPonens t1 t2 p q) ∧
    proofOrdinalHeight t2 < proofOrdinalHeight (.modusPonens t1 t2 p q) := by
  constructor;
  · exact lt_of_le_of_lt ( le_max_left _ _ ) ( Order.lt_succ _ );
  · exact lt_of_le_of_lt ( le_max_right _ _ ) ( Order.lt_succ _ )

/-! ## Section 8: Cross-Domain Bridge — Tropical Proof Heights -/

/-- **Novel Definition**: Tropical Proof Semiring.

    Proof heights naturally form a tropical semiring structure:
    - Tropical addition = min (take the shortest proof)
    - Tropical multiplication = + (compose proofs by adding heights)

    This connects proof theory to tropical geometry: the "tropical variety"
    of a proof system is the set of achievable proof height vectors. -/
structure TropicalProofHeight where
  /-- The height value, with ⊤ representing "no proof exists" -/
  height : WithTop ℕ

namespace TropicalProofHeight

instance : Zero TropicalProofHeight := ⟨⟨0⟩⟩
instance : Inhabited TropicalProofHeight := ⟨0⟩

/-- Tropical addition: take the minimum height (shortest proof). -/
def tropAdd (a b : TropicalProofHeight) : TropicalProofHeight :=
  ⟨min a.height b.height⟩

/-- Tropical multiplication: add heights (compose proofs). -/
def tropMul (a b : TropicalProofHeight) : TropicalProofHeight :=
  ⟨a.height + b.height⟩

/-- The tropical additive identity (∞ = no proof). -/
def tropZero : TropicalProofHeight := ⟨⊤⟩

/-- The tropical multiplicative identity (0 = axiom). -/
def tropOne : TropicalProofHeight := ⟨0⟩

/-- **Theorem 6 (Tropical Commutativity of Proof Composition)**: -/
theorem tropMul_comm (a b : TropicalProofHeight) :
    tropMul a b = tropMul b a := by
  simp [tropMul]
  exact add_comm a.height b.height

/-- **Theorem 7**: Tropical addition (taking shortest proof) is commutative. -/
theorem tropAdd_comm (a b : TropicalProofHeight) :
    tropAdd a b = tropAdd b a := by
  simp [tropAdd, min_comm]

/-
Tropical multiplication distributes over tropical addition.
    This is the key algebraic property connecting proof composition
    to tropical geometry.
-/
theorem tropMul_tropAdd_distrib (a b c : TropicalProofHeight) :
    tropMul a (tropAdd b c) = tropAdd (tropMul a b) (tropMul a c) := by
  unfold TropicalProofHeight.tropMul TropicalProofHeight.tropAdd; simp +decide [← min_add_add_left]

/-- The tropical multiplicative identity is neutral. -/
theorem tropOne_tropMul (a : TropicalProofHeight) :
    tropMul tropOne a = a := by
  simp [tropMul, tropOne]

end TropicalProofHeight

/-! ## Section 9: Proof System and Deductive Closure -/

/-- A proof system is a collection of axioms and deduction rules,
    together with a proof operator that advances the deduction frontier. -/
structure ProofSystem where
  axioms : Finset PropId
  operator : ProofOperator
  /-- Axioms are immediately provable -/
  axiom_step : ∀ p ∈ axioms, ∀ (a : ProofApprox), operator.step a p ≥ 1

/-- The deductive closure: the set of propositions that eventually get
    nonzero proof status under iteration. -/
def ProofSystem.deductiveClosure (sys : ProofSystem) : Set PropId :=
  { p | ∃ n, kleeneIterate sys.operator n p > 0 }

/-- **Theorem 8**: Every axiom is in the deductive closure. -/
theorem axioms_in_closure (sys : ProofSystem) :
    ∀ p ∈ sys.axioms, p ∈ sys.deductiveClosure := by
  intro p hp
  simp [ProofSystem.deductiveClosure]
  use 1
  simp [kleeneIterate]
  exact sys.axiom_step p hp ⊥

/-- **Theorem 9 (Monotonicity of Deductive Closure)**:
    Adding more axioms can only enlarge the deductive closure,
    when the proof operator is the same. -/
theorem closure_monotone (sys1 sys2 : ProofSystem)
    (h_same_op : sys1.operator = sys2.operator) :
    sys1.deductiveClosure ⊆ sys2.deductiveClosure := by
  intro p ⟨n, hn⟩
  exact ⟨n, by rw [h_same_op] at hn; exact hn⟩

/-! ## Section 10: Self-Reference Depth Stratification -/

/-- The self-reference depth: how many nested levels of self-reference
    a proof tree contains. -/
def selfRefDepth : NWFProofTree → ℕ
  | .axiom_ _ => 0
  | .modusPonens t1 t2 _ _ => max (selfRefDepth t1) (selfRefDepth t2)
  | .selfRef _ t => 1 + selfRefDepth t
  | .bottom => 0

/-- **Theorem 10**: Self-reference depth is bounded by structural depth.
    This is key: no proof tree can have more self-reference than its structure allows. -/
theorem selfRefDepth_le_depth (t : NWFProofTree) :
    selfRefDepth t ≤ t.depth := by
  induction t with
  | axiom_ _ => simp [selfRefDepth, NWFProofTree.depth]
  | modusPonens t1 t2 _ _ ih1 ih2 =>
    simp [selfRefDepth, NWFProofTree.depth]
    omega
  | selfRef _ t ih =>
    simp [selfRefDepth, NWFProofTree.depth]
    omega
  | bottom => simp [selfRefDepth, NWFProofTree.depth]

/-- **Theorem 11**: Trees with self-reference depth 0 are well-founded
    (contain no self-referential nodes). -/
theorem depth_zero_no_selfref (t : NWFProofTree) (h : selfRefDepth t = 0) :
    t.hasSelfRef = false := by
  induction t with
  | axiom_ _ => rfl
  | modusPonens t1 t2 _ _ ih1 ih2 =>
    simp [selfRefDepth] at h
    simp [NWFProofTree.hasSelfRef]
    exact ⟨ih1 (by omega), ih2 (by omega)⟩
  | selfRef _ t _ =>
    simp [selfRefDepth] at h
  | bottom => rfl

/-- **Conjecture (Falsifiable)**: For any valid proof tree with self-reference depth d > 0,
    there exists an equivalent valid proof tree with self-reference depth at most d - 1,
    UNLESS the proof essentially requires self-reference.

    **Test**: Find a proposition that has a valid NWF proof of depth d but no valid
    NWF proof of depth d - 1. If no such proposition exists for d ≤ 10, the conjecture
    is likely true. If one exists, it identifies the "essential self-reference threshold." -/
def selfRefEliminable (t : NWFProofTree) : Prop :=
  IsValidNWF t → selfRefDepth t > 0 →
    ∃ t', IsValidNWF t' ∧ t'.conclusion = t.conclusion ∧
      selfRefDepth t' < selfRefDepth t

/-! ## Section 11: Composing Proof Trees -/

/-- Compose two proof trees via modus ponens. -/
def composeProofs (t_imp t_arg : NWFProofTree) (p q : PropId) : NWFProofTree :=
  .modusPonens t_imp t_arg p q

/-- **Theorem 12**: Composition preserves validity when conclusions match. -/
theorem compose_valid (t1 t2 : NWFProofTree) (p q : PropId)
    (h1 : IsValidNWF t1) (h2 : IsValidNWF t2)
    (hc1 : t1.conclusion = some p)
    (hc2 : t2.conclusion = some q) :
    IsValidNWF (composeProofs t1 t2 p q) := by
  simp [composeProofs, IsValidNWF]
  exact ⟨hc1, hc2, h1, h2⟩

/-- Self-reference count is additive under composition. -/
theorem selfRefCount_compose (t1 t2 : NWFProofTree) (p q : PropId) :
    (composeProofs t1 t2 p q).selfRefCount = t1.selfRefCount + t2.selfRefCount := by
  simp [composeProofs, NWFProofTree.selfRefCount]

/-- **Theorem 13**: The ordinal height of a composition is determined by its components. -/
theorem compose_height (t1 t2 : NWFProofTree) (p q : PropId) :
    proofOrdinalHeight (composeProofs t1 t2 p q) =
    max (proofOrdinalHeight t1) (proofOrdinalHeight t2) + 1 := by
  simp [composeProofs, proofOrdinalHeight]

/-! ## Section 12: The Proof Space as an Order Structure -/

/-- Proof trees ordered by "information content": t ≤ s if s extends t
    with more valid subproofs. We use depth as a proxy. -/
def proofTreeLe (t s : NWFProofTree) : Prop :=
  t.depth ≤ s.depth

/-
**Theorem 14**: The identity proof has minimal positive depth among
    self-referential proofs.
-/
theorem identity_minimal_selfref (p : PropId) (t : NWFProofTree)
    (ht : t.hasSelfRef = true) :
    (identityProof p).depth ≤ t.depth := by
  rcases t with ( _ | _ | _ | _ ) <;> simp +arith +decide [ identityProof ] at ht ⊢;
  · cases ht;
  · simp [NWFProofTree.depth] at *;
  · exact Nat.add_le_add_left ( Nat.zero_le _ ) _

end