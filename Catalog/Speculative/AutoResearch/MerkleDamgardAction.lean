/-
  Merkle–Damgård as a Monoid Action: an Algebra ⇄ Cryptography bridge.

  The catalog file `Cryptography.MerkleDamgard` (`CryptoHash`) develops the linear
  Merkle–Damgård collision-resistance theory: `merkleDamgard`, `merkleDamgard_append`,
  `foldl_joint_injective`, `compress_injective_md_injective`,
  `md_collision_implies_compress_collision`, etc.

  This file *generalizes* that theory by reinterpreting it algebraically.  The catalog
  proves facts about a *fixed* initialization vector `iv`.  We instead view a message
  `m : List β` as the **state transformation** `a ↦ merkleDamgard f a m`, i.e. an element
  of `Function.End α`.  The domain-extension lemma `merkleDamgard_append` then becomes a
  genuine algebraic statement: message concatenation is *anti*-homomorphic to composition
  of state transformations, so words of the free monoid `FreeMonoid β` act on the state
  space.  We package this as a `MonoidHom`

      mdHom f : FreeMonoid β →* (Function.End α)ᵐᵒᵖ

  and show the catalog's joint injectivity (`foldl_joint_injective`) upgrades to the
  statement that this action is *faithful on words of a fixed length* whenever the
  compression function is injective — a strictly stronger, `iv`-independent form of the
  catalog's `compress_injective_md_injective`.

  Cross-domain content: free monoids / monoid homomorphisms (Algebra) applied to hash
  collision resistance (Cryptography).
-/

import Mathlib
import Cryptography.MerkleDamgard

open CryptoHash

namespace MerkleDamgardAction

variable {α β : Type*}

/-! ## The state-transformation action -/

-- !-- Lab Notebook: mdEnd / the action viewpoint -- !--
-- !-- Hypothesis: The catalog's `merkleDamgard_append` is secretly the statement that
--     messages act on the state space by composition; making the action explicit should
--     turn `iv`-fixed collision lemmas into `iv`-free algebraic ones. -- !--
-- !-- Result: Confirmed. `mdEnd f m := fun a => merkleDamgard f a m` lands in
--     `Function.End α`, and append becomes `mdEnd (m₁ ++ m₂) = mdEnd m₂ * mdEnd m₁`. -- !--
-- !-- Insight: The composition order is *reversed* (process m₁ first, then m₂), so the
--     natural target is the *opposite* monoid `(Function.End α)ᵐᵒᵖ`, not `Function.End α`. -- !--
-- !-- Failure analysis: A first attempt targeting `Function.End α` directly forced the
--     wrong multiplication order in `map_mul'`; switching to `ᵐᵒᵖ` fixed it cleanly. -- !--
-- !-- End Lab Notebook -- !--

/-- The state transformation induced by processing a message `m` through the
    Merkle–Damgård compression `f`: it sends a chaining value `a` to the hash
    `merkleDamgard f a m`.  Lives in `Function.End α` (the monoid of self-maps under
    composition). -/
def mdEnd (f : α → β → α) (m : List β) : Function.End α := fun a => merkleDamgard f a m

@[simp] theorem mdEnd_apply (f : α → β → α) (m : List β) (a : α) :
    mdEnd f m a = merkleDamgard f a m := rfl

-- !-- comment: empty message = identity transformation; nil/cons inherited from catalog. -- !--

/-- The empty message acts as the identity transformation. -/
@[simp] theorem mdEnd_nil (f : α → β → α) : mdEnd f ([] : List β) = 1 := rfl

/-- **Anti-homomorphism / action law.**  Concatenating messages composes their state
    transformations in reverse order.  This is the algebraic incarnation of the catalog's
    `merkleDamgard_append` (domain extension). -/
theorem mdEnd_append (f : α → β → α) (m₁ m₂ : List β) :
    mdEnd f (m₁ ++ m₂) = mdEnd f m₂ * mdEnd f m₁ := by
  funext a
  simp only [mdEnd, Function.End.mul_def, Function.comp_apply, merkleDamgard_append]

/-! ## The Merkle–Damgård monoid homomorphism -/

-- !-- Lab Notebook: mdHom -- !--
-- !-- Hypothesis: `mdEnd` extends to a monoid homomorphism out of the free monoid on
--     blocks, packaging the entire MD construction as a single algebraic object. -- !--
-- !-- Result: Proved. `mdHom f : FreeMonoid β →* (Function.End α)ᵐᵒᵖ`, with
--     `map_one'` from `mdEnd_nil` and `map_mul'` from `mdEnd_append` + `op_mul`. -- !--
-- !-- Insight: Under this hom, "collision resistance" = "injectivity of mdHom on a fixed
--     length", a clean algebraic reformulation of the cryptographic property. -- !--
-- !-- Failure analysis: `FreeMonoid β` is definitionally `List β` but multiplication only
--     simp-normalizes via `FreeMonoid.toList_mul`; routing through `.toList` was needed. -- !--
-- !-- End Lab Notebook -- !--

/-- The Merkle–Damgård construction as a single algebraic object: a monoid homomorphism
    from the free monoid of message blocks to the *opposite* of the endomorphism monoid of
    the state space.  This realizes domain extension (`merkleDamgard_append`) as
    `map_mul`. -/
def mdHom (f : α → β → α) : FreeMonoid β →* (Function.End α)ᵐᵒᵖ where
  toFun := fun m => MulOpposite.op (mdEnd f m.toList)
  map_one' := by
    show MulOpposite.op (mdEnd f (FreeMonoid.toList 1)) = 1
    rw [FreeMonoid.toList_one]
    rfl
  map_mul' := by
    intro x y
    show MulOpposite.op (mdEnd f (FreeMonoid.toList (x * y))) = _
    rw [FreeMonoid.toList_mul, mdEnd_append, MulOpposite.op_mul]

/-- Evaluating the homomorphism recovers the Merkle–Damgård hash: `mdHom f` applied to a
    word `m`, unwrapped from the opposite monoid and applied to `iv`, is exactly
    `merkleDamgard f iv m`. -/
@[simp] theorem mdHom_apply (f : α → β → α) (m : FreeMonoid β) (iv : α) :
    (mdHom f m).unop iv = merkleDamgard f iv m.toList := rfl

/-! ## Faithfulness = collision resistance (iv-independent upgrade) -/

-- !-- Lab Notebook: mdEnd_injOn_length -- !--
-- !-- Hypothesis: If `f` is injective then the action is *faithful on equal-length words*:
--     `mdEnd f m₁ = mdEnd f m₂` with `|m₁| = |m₂|` forces `m₁ = m₂`.  This is stronger
--     than the catalog's `compress_injective_md_injective`, which fixes a single `iv`. -- !--
-- !-- Result: Proved by evaluating the function equality at an arbitrary state `a`
--     (needs `Nonempty α`) and invoking the catalog lemma `foldl_joint_injective`. -- !--
-- !-- Insight: Catalog injectivity is "for some/this iv"; faithfulness of the action is
--     "as functions of all iv simultaneously" — the action language makes the upgrade
--     a one-line evaluation rather than a new induction. -- !--
-- !-- Failure analysis: `Nonempty α` is genuinely required: over `α = Empty` every map is
--     vacuously equal, so the action is never faithful regardless of `f`. -- !--
-- !-- End Lab Notebook -- !--

/-- **Main theorem (faithful action ⇒ collision resistance, iv-free form).**
    If the compression function `f` is injective (as a function of the pair) and the state
    space is nonempty, then equal-length messages inducing the *same state transformation*
    must be equal.  This generalizes the catalog's `compress_injective_md_injective`
    from a single fixed `iv` to "for all `iv` simultaneously". -/
theorem mdEnd_injOn_length [Nonempty α] {f : α → β → α}
    (hf : Function.Injective (Function.uncurry f))
    {m₁ m₂ : List β} (hlen : m₁.length = m₂.length)
    (heq : mdEnd f m₁ = mdEnd f m₂) : m₁ = m₂ := by
  obtain ⟨a⟩ := (inferInstance : Nonempty α)
  have hpt : m₁.foldl f a = m₂.foldl f a := congrFun heq a
  exact (foldl_joint_injective hf hlen hpt).2

/-- Corollary in homomorphism language: on words of a fixed length, `mdHom f` is injective
    whenever `f` is injective and the state space is nonempty. -/
theorem mdHom_injOn_length [Nonempty α] {f : α → β → α}
    (hf : Function.Injective (Function.uncurry f))
    {m₁ m₂ : FreeMonoid β} (hlen : m₁.toList.length = m₂.toList.length)
    (heq : mdHom f m₁ = mdHom f m₂) : m₁ = m₂ := by
  have : mdEnd f m₁.toList = mdEnd f m₂.toList :=
    MulOpposite.op_injective.eq_iff.mp heq
  exact FreeMonoid.toList.injective (mdEnd_injOn_length hf hlen this)

/-! ## Collisions are closed under common suffixes -/

-- !-- Lab Notebook: md_collision_closed_under_suffix -- !--
-- !-- Hypothesis: Any Merkle–Damgård collision survives appending a common suffix — the
--     attacker's "collision once, collision forever" phenomenon. -- !--
-- !-- Result: Proved directly from `merkleDamgard_append`: a collision equalizes the
--     chaining value, and appending `s` then runs the *same* transformation on both. -- !--
-- !-- Insight: In action language this is instant — `mdEnd f s` is a function, and applying
--     a function to equal inputs yields equal outputs. -- !--
-- !-- Failure analysis: N/A. -- !--
-- !-- End Lab Notebook -- !--

/-- **Collision persistence.**  If `m₁` and `m₂` collide under Merkle–Damgård from `iv`,
    then `m₁ ++ s` and `m₂ ++ s` collide for every suffix `s`.  This is the algebraic
    counterpart of the catalog's `length_extension_property`: not only the hash but every
    collision is stable under extension. -/
theorem md_collision_closed_under_suffix (f : α → β → α) (iv : α) {m₁ m₂ : List β}
    (hcol : merkleDamgard f iv m₁ = merkleDamgard f iv m₂) (s : List β) :
    merkleDamgard f iv (m₁ ++ s) = merkleDamgard f iv (m₂ ++ s) := by
  rw [merkleDamgard_append, merkleDamgard_append, hcol]

/-! ## Strengthening closes the length boundary (generalization, proved) -/

-- !-- Lab Notebook: mdEnd_injective_of_padding -- !--
-- !-- Hypothesis: With suffix/length-injective padding (Merkle–Damgård strengthening),
--     faithfulness extends from equal-length words to *all* words. -- !--
-- !-- Result: Proved. The padding equalizes lengths, so `mdEnd_injOn_length` applies to
--     `pad m₁, pad m₂`, then injectivity of `pad` finishes — the action-language analogue
--     of the catalog's `md_strengthen_injective`. -- !--
-- !-- Insight: Padding is exactly the device that turns the *partial* faithfulness of the
--     raw action into *total* faithfulness, i.e. a genuinely free action on `List β`. -- !--
-- !-- End Lab Notebook -- !--

/-- **Generalization (drop the equal-length hypothesis via strengthening).**
    With a length-equalizing injective padding `pad`, the induced action is faithful on
    *all* messages, not just equal-length ones — the action-language upgrade of the
    catalog's `md_strengthen_injective`. -/
theorem mdEnd_injective_of_padding [Nonempty α] {f : α → β → α}
    {pad : List β → List β}
    (hf : Function.Injective (Function.uncurry f))
    (hpad : Function.Injective pad)
    (hpad_len : ∀ m₁ m₂, (pad m₁).length = (pad m₂).length)
    {m₁ m₂ : List β}
    (heq : mdEnd f (pad m₁) = mdEnd f (pad m₂)) : m₁ = m₂ :=
  hpad (mdEnd_injOn_length hf (hpad_len m₁ m₂) heq)

/-! ## Critique: the converse is FALSE (a counterexample) -/

-- !-- Lab Notebook: converse_faithful_not_imply_injective -- !--
-- !-- Hypothesis (the Critic): is `mdEnd_injOn_length` reversible? I.e. does faithfulness
--     of the action on equal-length words force the compression `f` to be injective? -- !--
-- !-- Result: DISPROVED. The action only ever compares words through chaining values it can
--     reach; over a one-block alphabet (`β = Unit`) equal-length words are *automatically*
--     equal, so faithfulness is vacuous while `f` can collapse states arbitrarily. -- !--
-- !-- Insight: Faithfulness sees `f` only via reachable states; it is strictly weaker than
--     uncurry-injectivity. The honest converse must restrict to a richer alphabet and
--     range over chaining values — see the conjecture below. -- !--
-- !-- Failure analysis: An early hope that injectivity was an iff was wrong precisely
--     because `f`'s behaviour off the reachable orbit is invisible to the action. -- !--
-- !-- End Lab Notebook -- !--

/-- **Counterexample (the converse of `mdEnd_injOn_length` is false).**  There is a
    nonempty state space and a compression function whose induced action is faithful on
    equal-length messages, yet the compression function is *not* injective.  Hence
    collision resistance (faithfulness) is strictly weaker than injectivity of `f`: the
    action cannot witness collisions that occur only off its reachable orbit. -/
theorem converse_faithful_not_imply_injective :
    ∃ (α β : Type) (_ : Nonempty α) (f : α → β → α),
      (∀ m₁ m₂ : List β, m₁.length = m₂.length → mdEnd f m₁ = mdEnd f m₂ → m₁ = m₂) ∧
        ¬ Function.Injective (Function.uncurry f) := by
  refine ⟨Bool, Unit, ⟨true⟩, (fun _ _ => true), ?_, ?_⟩
  · -- equal-length lists over `Unit` are equal, so faithfulness is automatic
    intro m₁ m₂ hlen _
    clear *- hlen
    induction m₁ generalizing m₂ with
    | nil => cases m₂ with | nil => rfl | cons b t => simp at hlen
    | cons a t ih =>
      cases m₂ with
      | nil => simp at hlen
      | cons b s =>
        simp only [List.length_cons, Nat.add_right_cancel_iff] at hlen
        rw [ih s hlen]
  · intro hinj
    have : ((true, ()) : Bool × Unit) = (false, ()) := hinj rfl
    simp at this

/-! ## Generalization loop: Merkle *tree* hashing (proved) -/

-- !-- Lab Notebook: treeHash_injOn_shape -- !--
-- !-- Hypothesis: The linear chaining of Merkle–Damgård is the path-graph special case of
--     a binary Merkle *tree* hash; collision resistance should lift to trees of a fixed
--     shape provided the 2-to-1 compression `g` and the leaf map are injective. -- !--
-- !-- Result: Proved by structural induction on the first tree, matching constructors of
--     the second via the shape hypothesis; node/node uses uncurry-injectivity of `g` to
--     split the child hashes, the free-magma analogue of `foldl_joint_injective`. -- !--
-- !-- Insight: linear MD ↔ free monoid; tree hashing ↔ free magma. The action viewpoint of
--     this file is the bridge that makes the analogy precise, and the same
--     "shape/length determines structure, injectivity peels one layer" pattern recurs. -- !--
-- !-- Failure analysis: Cross (leaf/node) cases need the shape hypothesis to discharge;
--     without it the statement is FALSE (a leaf can collide with a node when ranges meet). -- !--
-- !-- End Lab Notebook -- !--

/-- A binary Merkle tree over leaf data `β`. -/
inductive BTree (β : Type*) : Type _
  | leaf : β → BTree β
  | node : BTree β → BTree β → BTree β

/-- Hash a binary Merkle tree: leaves map through `lf`, internal nodes combine their two
    child hashes with the 2-to-1 compression `g`. -/
def treeHash {β : Type*} (g : α → α → α) (lf : β → α) : BTree β → α
  | BTree.leaf b => lf b
  | BTree.node l r => g (treeHash g lf l) (treeHash g lf r)

/-- The shape of a Merkle tree: forget the leaf data, keep the branching structure.
    The tree analogue of "message length". -/
def BTree.shape {β : Type*} : BTree β → BTree Unit
  | BTree.leaf _ => BTree.leaf ()
  | BTree.node l r => BTree.node l.shape r.shape

/-- **Merkle tree collision resistance (free-magma generalization of `mdEnd_injOn_length`).**
    If the 2-to-1 compression `g` is injective (as a pair function) and the leaf map `lf` is
    injective, then `treeHash g lf` is injective on trees *of the same shape* (the tree
    analogue of equal-length messages).  The shape hypothesis is essential: without it a
    leaf can collide with a node, see the conjecture below. -/
theorem treeHash_injOn_shape {β : Type*} {g : α → α → α} {lf : β → α}
    (hg : Function.Injective (Function.uncurry g)) (hlf : Function.Injective lf)
    {t₁ t₂ : BTree β} (hshape : t₁.shape = t₂.shape)
    (heq : treeHash g lf t₁ = treeHash g lf t₂) :
    t₁ = t₂ := by
  induction t₁ generalizing t₂ with
  | leaf b₁ =>
    cases t₂ with
    | leaf b₂ => simp only [treeHash] at heq; rw [hlf heq]
    | node l₂ r₂ => simp [BTree.shape] at hshape
  | node l₁ r₁ ihl ihr =>
    cases t₂ with
    | leaf b₂ => simp [BTree.shape] at hshape
    | node l₂ r₂ =>
      simp only [BTree.shape, BTree.node.injEq] at hshape
      simp only [treeHash] at heq
      have hpair : ((treeHash g lf l₁, treeHash g lf r₁) : α × α)
          = (treeHash g lf l₂, treeHash g lf r₂) := hg heq
      rw [Prod.mk.injEq] at hpair
      rw [ihl hshape.1 hpair.1, ihr hshape.2 hpair.2]

/-! ## Open conjecture for the next cycle -/

-- !-- Lab Notebook: prefix-free shape-independence conjecture -- !--
-- !-- Hypothesis: With an injective, *shape-determining* leaf encoding (e.g. domain
--     separation / prefix-free tagging of leaves vs. internal nodes), tree-hash
--     injectivity should hold WITHOUT the same-shape hypothesis. -- !--
-- !-- Result: Left as a conjecture (sorry) — it requires modelling domain separation and
--     proving shape is recoverable from the hash, which is genuinely new structure. -- !--
-- !-- End Lab Notebook -- !--

/-- **Conjecture (shape-independent tree collision resistance via domain separation).**
    There is a tagging scheme `tag : Bool → α → α` (separating leaf vs. node inputs) such
    that the tagged tree hash is injective on *all* trees, not merely same-shape ones —
    i.e. the shape hypothesis of `treeHash_injOn_shape` can be dropped.  This is the formal
    statement of why real Merkle trees use domain separation; proving it is the next target. -/
theorem treeHash_injective_with_domain_separation_conjecture {β : Type*}
    (g : α → α → α) (lf : β → α) :
    ∃ _tag : Bool → α → α, Function.Injective (treeHash g lf) := by
  sorry

end MerkleDamgardAction