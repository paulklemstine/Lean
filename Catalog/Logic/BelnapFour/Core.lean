import Mathlib

/-!
# Belnap's FOUR: the smallest non-trivial distributive bilattice (Core)

This file develops Belnap's four-valued logic `FOUR` as an *interlaced distributive
bilattice with negation and conflation*. The four truth values are

* `N` — "none"  (no information; the bottom of the knowledge order),
* `F` — "false",
* `T` — "true",
* `B` — "both"  (contradictory information; the top of the knowledge order).

Two distinct lattice orders live on this set:

* the **truth order** `tle` with meet `tand` (∧) and join `tor` (∨):
  `F ≤ N ≤ T` and `F ≤ B ≤ T`, with `N`, `B` incomparable;
* the **knowledge / information order** `kle` with meet `kand` (⊗) and join `kor` (⊕):
  `N ≤ F ≤ B` and `N ≤ T ≤ B`, with `F`, `T` incomparable.

Together with negation `neg` (reverses truth, preserves knowledge) and conflation
`conf` (reverses knowledge, preserves truth), this is the prototypical bilattice.

Because the carrier is a four–element `Fintype` with `DecidableEq`, every universally
quantified algebraic identity below is *decidable*, so the proofs are obtained by the
kernel-checked `decide`.  The mathematical content is in choosing the right tables and
in the structural theorems (interlacing, De Morgan, homomorphism behaviour).

-- !-- Lab Notebook -- !--
Hypothesis: Belnap's FOUR is a bilattice, i.e. two lattices share one carrier, linked
  by negation/conflation, and the whole structure is *interlaced* and *distributive*.
Result: All four binary operations are commutative, associative, idempotent and satisfy
  the absorption laws; the meets/joins compute the glb/lub of the two declared orders;
  negation is an order-reversing involution of the truth lattice that is simultaneously
  a homomorphism of the knowledge lattice (and dually for conflation).
Insight: Encoding the two orders by Boolean tables `tleb`/`kleb` and the operations by
  explicit tables makes the *entire* algebraic theory decidable, turning deep bilattice
  facts (12 interlacing distributive laws) into one `decide`.
Failure analysis: Trying to register two `Lattice` instances on one type fails — a type
  has a single `≤`. The fix is to keep the orders as plain relations and prove the
  lattice axioms as theorems, which is exactly what a bilattice needs.
-/

namespace BelnapFour

/-- Belnap's four truth values. `N` = none/⊥ₖ, `F` = false, `T` = true, `B` = both/⊤ₖ. -/
inductive Belnap
  | N | F | T | B
deriving DecidableEq, Fintype, Repr

namespace Belnap

/-! ## The two orders (as Boolean-valued, hence decidable, relations) -/

/-- Truth order `a ≤_t b`: `F ≤ N ≤ T`, `F ≤ B ≤ T`, with `N`, `B` incomparable. -/
def tleb : Belnap → Belnap → Bool
  | F, _ => true
  | _, T => true
  | N, N => true
  | B, B => true
  | _, _ => false

/-- Knowledge order `a ≤_k b`: `N ≤ F ≤ B`, `N ≤ T ≤ B`, with `F`, `T` incomparable. -/
def kleb : Belnap → Belnap → Bool
  | N, _ => true
  | _, B => true
  | F, F => true
  | T, T => true
  | _, _ => false

/-- Truth order as a `Prop`. -/
def tle (a b : Belnap) : Prop := tleb a b = true
/-- Knowledge order as a `Prop`. -/
def kle (a b : Belnap) : Prop := kleb a b = true

instance (a b : Belnap) : Decidable (tle a b) := inferInstanceAs (Decidable (_ = true))
instance (a b : Belnap) : Decidable (kle a b) := inferInstanceAs (Decidable (_ = true))

/-! ## The four binary operations -/

/-- Truth meet `∧` (greatest lower bound in the truth order). -/
def tand : Belnap → Belnap → Belnap
  | F, _ => F | _, F => F
  | T, x => x | x, T => x
  | N, N => N | B, B => B
  | N, B => F | B, N => F

/-- Truth join `∨` (least upper bound in the truth order). -/
def tor : Belnap → Belnap → Belnap
  | T, _ => T | _, T => T
  | F, x => x | x, F => x
  | N, N => N | B, B => B
  | N, B => T | B, N => T

/-- Knowledge meet `⊗` (consensus; glb in the knowledge order). -/
def kand : Belnap → Belnap → Belnap
  | N, _ => N | _, N => N
  | B, x => x | x, B => x
  | F, F => F | T, T => T
  | F, T => N | T, F => N

/-- Knowledge join `⊕` (gullibility; lub in the knowledge order). -/
def kor : Belnap → Belnap → Belnap
  | B, _ => B | _, B => B
  | N, x => x | x, N => x
  | F, F => F | T, T => T
  | F, T => B | T, F => B

/-- Negation: swaps `T` and `F`, fixes `N` and `B`. -/
def neg : Belnap → Belnap
  | T => F | F => T | N => N | B => B

/-- Conflation: swaps `N` and `B`, fixes `F` and `T`. -/
def conf : Belnap → Belnap
  | N => B | B => N | F => F | T => T

@[inherit_doc] scoped infixl:70 " ⊓ₜ " => tand
@[inherit_doc] scoped infixl:65 " ⊔ₜ " => tor
@[inherit_doc] scoped infixl:70 " ⊗ₖ " => kand
@[inherit_doc] scoped infixl:65 " ⊕ₖ " => kor

/-! ## Theorem 1 — both reducts are lattices (the bilattice axioms) -/

-- !-- Both `(Belnap, ⊓ₜ, ⊔ₜ)` and `(Belnap, ⊗ₖ, ⊕ₖ)` satisfy the lattice axioms
-- (commutative, associative, idempotent, absorptive); finite case check. -- !--
/-- **Theorem 1.** The truth reduct `(Belnap, ⊓ₜ, ⊔ₜ)` is a lattice: both operations are
commutative, associative, idempotent and obey the two absorption laws. -/
theorem truth_lattice_axioms :
    (∀ a b : Belnap, a ⊓ₜ b = b ⊓ₜ a) ∧
    (∀ a b c : Belnap, (a ⊓ₜ b) ⊓ₜ c = a ⊓ₜ (b ⊓ₜ c)) ∧
    (∀ a : Belnap, a ⊓ₜ a = a) ∧
    (∀ a b : Belnap, a ⊔ₜ b = b ⊔ₜ a) ∧
    (∀ a b c : Belnap, (a ⊔ₜ b) ⊔ₜ c = a ⊔ₜ (b ⊔ₜ c)) ∧
    (∀ a : Belnap, a ⊔ₜ a = a) ∧
    (∀ a b : Belnap, a ⊓ₜ (a ⊔ₜ b) = a) ∧
    (∀ a b : Belnap, a ⊔ₜ (a ⊓ₜ b) = a) := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩ <;> decide

/-- **Theorem 1′.** The knowledge reduct `(Belnap, ⊗ₖ, ⊕ₖ)` is a lattice. -/
theorem knowledge_lattice_axioms :
    (∀ a b : Belnap, a ⊗ₖ b = b ⊗ₖ a) ∧
    (∀ a b c : Belnap, (a ⊗ₖ b) ⊗ₖ c = a ⊗ₖ (b ⊗ₖ c)) ∧
    (∀ a : Belnap, a ⊗ₖ a = a) ∧
    (∀ a b : Belnap, a ⊕ₖ b = b ⊕ₖ a) ∧
    (∀ a b c : Belnap, (a ⊕ₖ b) ⊕ₖ c = a ⊕ₖ (b ⊕ₖ c)) ∧
    (∀ a : Belnap, a ⊕ₖ a = a) ∧
    (∀ a b : Belnap, a ⊗ₖ (a ⊕ₖ b) = a) ∧
    (∀ a b : Belnap, a ⊕ₖ (a ⊗ₖ b) = a) := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩ <;> decide

-- !-- The operations compute the glb/lub of the declared orders: `a ⊓ₜ b = a ↔ a ≤_t b`,
-- and similarly for the join and for the knowledge order. -- !--
/-- **Theorem 1″.** The order/operation compatibility: each meet is the glb and each join
the lub of the corresponding order. -/
theorem orders_match_operations :
    (∀ a b : Belnap, tle a b ↔ a ⊓ₜ b = a) ∧
    (∀ a b : Belnap, tle a b ↔ a ⊔ₜ b = b) ∧
    (∀ a b : Belnap, kle a b ↔ a ⊗ₖ b = a) ∧
    (∀ a b : Belnap, kle a b ↔ a ⊕ₖ b = b) := by
  refine ⟨?_, ?_, ?_, ?_⟩ <;> decide

/-- The two orders are genuine partial orders (reflexive, antisymmetric, transitive). -/
theorem orders_are_partial_orders :
    (∀ a : Belnap, tle a a) ∧
    (∀ a b : Belnap, tle a b → tle b a → a = b) ∧
    (∀ a b c : Belnap, tle a b → tle b c → tle a c) ∧
    (∀ a : Belnap, kle a a) ∧
    (∀ a b : Belnap, kle a b → kle b a → a = b) ∧
    (∀ a b c : Belnap, kle a b → kle b c → kle a c) := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_⟩ <;> decide

/-! ## Theorem 2 — interlacing & distributivity -/

-- !-- A bilattice is *interlaced* when each operation is monotone w.r.t. the other order;
-- here every one of the 12 cross-distributive laws holds, so FOUR is distributive. -- !--
/-- **Theorem 2.** FOUR is a *distributive* bilattice: all twelve distributive laws
relating the four operations hold. -/
theorem distributive_bilattice :
    (∀ a b c : Belnap, a ⊓ₜ (b ⊔ₜ c) = (a ⊓ₜ b) ⊔ₜ (a ⊓ₜ c)) ∧
    (∀ a b c : Belnap, a ⊔ₜ (b ⊓ₜ c) = (a ⊔ₜ b) ⊓ₜ (a ⊔ₜ c)) ∧
    (∀ a b c : Belnap, a ⊗ₖ (b ⊕ₖ c) = (a ⊗ₖ b) ⊕ₖ (a ⊗ₖ c)) ∧
    (∀ a b c : Belnap, a ⊕ₖ (b ⊗ₖ c) = (a ⊕ₖ b) ⊗ₖ (a ⊕ₖ c)) ∧
    (∀ a b c : Belnap, a ⊓ₜ (b ⊗ₖ c) = (a ⊓ₜ b) ⊗ₖ (a ⊓ₜ c)) ∧
    (∀ a b c : Belnap, a ⊓ₜ (b ⊕ₖ c) = (a ⊓ₜ b) ⊕ₖ (a ⊓ₜ c)) ∧
    (∀ a b c : Belnap, a ⊔ₜ (b ⊗ₖ c) = (a ⊔ₜ b) ⊗ₖ (a ⊔ₜ c)) ∧
    (∀ a b c : Belnap, a ⊔ₜ (b ⊕ₖ c) = (a ⊔ₜ b) ⊕ₖ (a ⊔ₜ c)) ∧
    (∀ a b c : Belnap, a ⊗ₖ (b ⊓ₜ c) = (a ⊗ₖ b) ⊓ₜ (a ⊗ₖ c)) ∧
    (∀ a b c : Belnap, a ⊗ₖ (b ⊔ₜ c) = (a ⊗ₖ b) ⊔ₜ (a ⊗ₖ c)) ∧
    (∀ a b c : Belnap, a ⊕ₖ (b ⊓ₜ c) = (a ⊕ₖ b) ⊓ₜ (a ⊕ₖ c)) ∧
    (∀ a b c : Belnap, a ⊕ₖ (b ⊔ₜ c) = (a ⊕ₖ b) ⊔ₜ (a ⊕ₖ c)) := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩ <;> decide

/-! ## Theorem 3 — negation and conflation -/

-- !-- Negation is an involution, reverses the truth order, preserves the knowledge order,
-- satisfies De Morgan for ∧/∨ and is a homomorphism for ⊗/⊕. -- !--
/-- **Theorem 3.** Negation `neg` is an order-reversing involution of the truth lattice
that is simultaneously an order-preserving homomorphism of the knowledge lattice. -/
theorem negation_laws :
    (∀ a : Belnap, neg (neg a) = a) ∧
    (∀ a b : Belnap, neg (a ⊓ₜ b) = neg a ⊔ₜ neg b) ∧
    (∀ a b : Belnap, neg (a ⊔ₜ b) = neg a ⊓ₜ neg b) ∧
    (∀ a b : Belnap, neg (a ⊗ₖ b) = neg a ⊗ₖ neg b) ∧
    (∀ a b : Belnap, neg (a ⊕ₖ b) = neg a ⊕ₖ neg b) ∧
    (∀ a b : Belnap, tle a b ↔ tle (neg b) (neg a)) ∧
    (∀ a b : Belnap, kle a b ↔ kle (neg a) (neg b)) := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_⟩ <;> decide

-- !-- Conflation is the dual: an involution reversing the knowledge order, preserving the
-- truth order, De Morgan for ⊗/⊕, homomorphism for ∧/∨, and it commutes with negation. -- !--
/-- **Theorem 3′.** Conflation `conf` is the knowledge-order dual of negation, and the two
operations commute. -/
theorem conflation_laws :
    (∀ a : Belnap, conf (conf a) = a) ∧
    (∀ a b : Belnap, conf (a ⊗ₖ b) = conf a ⊕ₖ conf b) ∧
    (∀ a b : Belnap, conf (a ⊕ₖ b) = conf a ⊗ₖ conf b) ∧
    (∀ a b : Belnap, conf (a ⊓ₜ b) = conf a ⊓ₜ conf b) ∧
    (∀ a b : Belnap, conf (a ⊔ₜ b) = conf a ⊔ₜ conf b) ∧
    (∀ a b : Belnap, kle a b ↔ kle (conf b) (conf a)) ∧
    (∀ a b : Belnap, tle a b ↔ tle (conf a) (conf b)) ∧
    (∀ a : Belnap, neg (conf a) = conf (neg a)) := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩ <;> decide

end Belnap
end BelnapFour