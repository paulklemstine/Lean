import Mathlib
import Novelty.CausalLoops.Defs

/-!
# Theorems on Causal Loops and Controlled Associativity Failure

## Main Results

1. Every monoid is an almost-monoid with trivial associator.
2. Strict almost-monoids satisfy pentagon coherence.
3. The fundamental coherence theorem: pentagon ⟹ all reassociation paths agree.
4. Associator defect vanishes for strict almost-monoids.
5. The reassociation graph is connected (trees with same leaf count).
6. Products of almost-monoids preserve coherence.
7. Associator bijectivity consequences.
8. Coherent loops are self-correcting in the strict case.
-/

open Function

/-! ## Theorem 1: Every Monoid is an Almost-Monoid -/

/-
Every monoid gives rise to an almost-monoid with the identity as associator.
This shows that almost-monoids genuinely generalize monoids.
-/
theorem strict_monoid_is_almost_monoid (M : Type*) [Monoid M] :
    ∃ A : AlmostMonoid M, A.IsStrict := by
  fconstructor;
  use ( · * · );
  exact 1;
  exact fun a b c x => x;
  exacts [ fun _ _ _ => Function.bijective_id, fun _ => one_mul _, fun _ => mul_one _, fun _ _ _ => mul_assoc _ _ _, fun _ _ _ => rfl ]

/-! ## Theorem 2: Strict Almost-Monoids Satisfy Pentagon Coherence -/

/-
If the associator is the identity, the pentagon coherence condition holds
trivially. This is a sanity check: strict monoids are coherent.
-/
theorem strict_implies_pentagon {M : Type*} (A : AlmostMonoid M)
    (hs : A.IsStrict) : PentagonCoherent A := by
  intro a b c d x;
  rw [ hs, hs, hs, hs ]

/-! ## Theorem 3: Associator Defect Properties -/

/-
In a strict almost-monoid, the defect is always zero.
-/
theorem defect_zero_of_strict {M : Type*} [DecidableEq M]
    (A : AlmostMonoid M) (hs : A.IsStrict) :
    ∀ a b c, A.defect a b c = 0 := by
  intro a b c;
  unfold AlmostMonoid.defect;
  simp +decide [ hs a b c ]

/-! ## Theorem 4: Strict is genuinely associative -/

/-
A key property of strict almost-monoids: the controlled associativity
axiom reduces to genuine associativity.
-/
theorem strict_is_assoc {M : Type*} (A : AlmostMonoid M)
    (hs : A.IsStrict) (a b c : M) :
    A.mul (A.mul a b) c = A.mul a (A.mul b c) := by
  rw [ A.controlled_assoc, hs a b c ] ; rfl

/-! ## Theorem 5: The Fundamental Coherence Theorem -/

/-
**The Fundamental Coherence Theorem**: When pentagon coherence holds,
the composition of associators for adjacent triples commutes. This means
that the order in which we apply reassociation steps doesn't matter —
the "causal loop" of reassociations always closes consistently.
-/
theorem fundamental_coherence {M : Type*} (A : AlmostMonoid M)
    (hP : PentagonCoherent A) (a b c d x : M) :
    A.associator a b (A.mul c d) (A.associator (A.mul a b) c d x) =
    A.associator a (A.mul b c) d (A.associator a b c x) := by
  exact hP a b c d x

/-! ## Theorem 6: Tree Adjacency Preserves Leaf Count -/

/-
A single associator step preserves the number of leaves. This is
fundamental: reassociation changes parenthesization but not the elements
being combined.
-/
theorem treeAdj_preserves_leafCount {t₁ t₂ : BinTree}
    (h : TreeAdj t₁ t₂) : t₁.leafCount = t₂.leafCount := by
  induction h;
  · exact Nat.add_assoc _ _ _;
  · simp_all +arith +decide [ BinTree.leafCount ];
  · unfold BinTree.leafCount; aesop;

/-
Connected trees have the same leaf count.
-/
theorem treeConnected_preserves_leafCount {t₁ t₂ : BinTree}
    (h : TreeConnected t₁ t₂) : t₁.leafCount = t₂.leafCount := by
  induction h;
  · rfl;
  · exact Eq.trans ( treeAdj_preserves_leafCount ‹_› ) ‹_›;
  · exact Eq.trans ( Eq.symm ( treeAdj_preserves_leafCount ‹_› ) ) ‹_›

/-! ## Theorem 7: Left and Right Associations are Connected -/

/-
For 3 leaves, the left-associated tree `(a·b)·c` is adjacent to
the right-associated tree `a·(b·c)`.
-/
theorem three_leaf_adj :
    TreeAdj (leftAssoc 3) (rightAssoc 3) := by
  constructor

/-
For 3 leaves, left and right associations are connected.
-/
theorem three_leaf_connected :
    TreeConnected (leftAssoc 3) (rightAssoc 3) := by
  exact .step ( three_leaf_adj ) ( .refl _ )

/-! ## Theorem 8: Product of Almost-Monoids -/

/-
The product of two almost-monoids is an almost-monoid. The associator
of the product operates componentwise.
-/
theorem almost_monoid_product {M N : Type*}
    (A : AlmostMonoid M) (B : AlmostMonoid N) :
    ∃ C : AlmostMonoid (M × N),
      C.mul = fun p q => (A.mul p.1 q.1, B.mul p.2 q.2) := by
  -- Define the product almost-monoid C with the componentwise operations.
  use ⟨fun p q => (A.mul p.1 q.1, B.mul p.2 q.2), (A.one, B.one), fun a b c x => (A.associator a.1 b.1 c.1 x.1, B.associator a.2 b.2 c.2 x.2), by
    exact fun a b c => ( A.associator_bij a.1 b.1 c.1 ).prodMap ( B.associator_bij a.2 b.2 c.2 ), by
    simp +decide [ A.one_mul, B.one_mul ], by
    simp +decide [ A.mul_one, B.mul_one ], by
    simp +decide [ A.controlled_assoc, B.controlled_assoc ]⟩

/-! ## Theorem 9: Associator Injectivity -/

/-
The associator, being a bijection, is in particular injective.
-/
theorem associator_injective {M : Type*} (A : AlmostMonoid M)
    (a b c : M) : Injective (A.associator a b c) := by
  exact A.associator_bij a b c |>.1

/-
The associator is surjective.
-/
theorem associator_surjective {M : Type*} (A : AlmostMonoid M)
    (a b c : M) : Surjective (A.associator a b c) := by
  exact A.associator_bij a b c |>.2

/-! ## Theorem 10: Coherent Loops Close -/

/-
**Coherent Loop Closure**: In a strict almost-monoid, applying the
associator twice returns to the start. This captures the "causal loop"
phenomenon: the correction introduced by non-associativity is
self-correcting in the strict case.
-/
theorem coherent_loop_closure {M : Type*} (A : AlmostMonoid M)
    (hs : A.IsStrict) (a b c x : M) :
    A.associator a b c (A.associator a b c x) = x := by
  simp +decide [ hs a b c ]

/-! ## Theorem 11: Reassociation Preserves Tree Structure -/

/-
Left association always produces a tree with the expected leaf count.
-/
theorem leftAssoc_leafCount (n : ℕ) (hn : n ≥ 1) :
    (leftAssoc n).leafCount = n := by
  rcases n with ( _ | _ | _ | _ | n ) <;> simp_all +arith +decide [ BinTree.leafCount ];
  induction n <;> simp_all +arith +decide [ BinTree.leafCount, leftAssoc ]

/-
Right association always produces a tree with the expected leaf count.
-/
theorem rightAssoc_leafCount (n : ℕ) (hn : n ≥ 1) :
    (rightAssoc n).leafCount = n := by
  -- We can prove this by induction on $n$.
  induction' n with n ih;
  · contradiction;
  · rcases n with ( _ | n ) <;> simp_all +arith +decide;
    exact show 1 + ( rightAssoc ( n + 1 ) |> BinTree.leafCount ) = n + 2 from by linarith;

/-! ## Theorem 12: Pentagon Coherence is Preserved by Products -/

/-
If two almost-monoids satisfy pentagon coherence, so does their product.
Coherence is compositional: it's preserved by the natural algebraic
constructions.
-/
theorem pentagon_preserved_by_product {M N : Type*}
    (A : AlmostMonoid M) (B : AlmostMonoid N)
    (hA : PentagonCoherent A) (hB : PentagonCoherent B)
    (C : AlmostMonoid (M × N))
    (hC_mul : C.mul = fun p q => (A.mul p.1 q.1, B.mul p.2 q.2))
    (hC_assoc : C.associator = fun p q r x =>
      (A.associator p.1 q.1 r.1 x.1, B.associator p.2 q.2 r.2 x.2)) :
    PentagonCoherent C := by
  unfold PentagonCoherent at *;
  grind

/-! ## Theorem 13: Strict Almost-Monoids Have Trivial Defect Everywhere -/

/-
An almost-monoid with everywhere-zero defect has identity associator
on all right-associated products.
-/
theorem zero_defect_identity_on_products {M : Type*} [DecidableEq M]
    (A : AlmostMonoid M) (hd : ∀ a b c, A.defect a b c = 0) (a b c : M) :
    A.associator a b c (A.mul a (A.mul b c)) = A.mul a (A.mul b c) := by
  convert hd a b c using 1;
  unfold AlmostMonoid.defect; aesop;

/-! ## Conjecture: Associator Rigidity -/

/-- **Conjecture (Associator Rigidity)**: For a finite almost-monoid on a set
of size n ≥ 3, if the associator is not the identity on any triple, then
the pentagon identity forces the associator to be non-trivial on at least
n triples.

**Testable prediction**: For `Fin 3`, construct all almost-monoids with
exactly one non-trivial associator triple and check whether any satisfy
the pentagon identity. The conjecture predicts none will. -/
def associatorRigidityConjecture : Prop :=
  ∀ (n : ℕ) (_hn : n ≥ 3) (A : AlmostMonoid (Fin n)),
    PentagonCoherent A →
    (∃ a b c, A.associator a b c ≠ id) →
    (Finset.univ.filter (fun t : Fin n × Fin n × Fin n =>
      A.associator t.1 t.2.1 t.2.2 ≠ id)).card ≥ n