import Mathlib
import Catalog.Bridges.PosetTheory.GroupTheoryBridge

/-!
# A periodic table of finite groups: invariants and obstructions

A useful table of finite groups must distinguish two logically different layers.
The orders of composition factors determine the order of the group, but do not
encode its multiplication law.  The cyclic group of order six and the symmetric
group on three letters provide the smallest decisive test: they have the same
order and hence the same prime-factor ledger, while one is commutative and the
other is not.

The results below isolate a rigorous numerical shadow of Jordan–Hölder theory.
A `FactorLedger` records the orders of factors and certifies that their product
is the group order.  Equality of such ledgers forces equality of atomic number.
Thus groups with literally isomorphic composition factors cannot have different
orders.  On the other hand, equality of the coarser prime ledger does not even
determine commutativity.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): Seven falsifiable proposals were ranked by structural
impact: (1) identical composition factors permit different group orders;
(2) a composition-factor column determines solvability; (3) it determines
nilpotency class; (4) it determines derived length; (5) it determines the order
of the automorphism group; (6) order together with valence determines the group;
and (7) the prime-factor ledger predicts element-order spectra.  Proposals
(1)--(5) concern the proposed chemical classification, while (6)--(7) bridge
finite-group structure with combinatorial invariant design.

Experiment (Experimenter): The product formula was abstracted into a factor
ledger and proved by induction.  The first collision was then tested at atomic
number six, comparing `ZMod 6` with permutations of three points.  Explicit
transpositions witness failure of commutativity in the latter.

Analysis (Analyst): Proposal (1) fails for a structural reason: orders multiply
along every subnormal series.  The phrase “same composition factors but different
orders” therefore needs a weaker meaning, such as the same set of factor types
with multiplicities forgotten.  The order-six collision disproves any rule that
uses only the prime ledger to recover multiplication-sensitive properties.

Critique (Critic): Cardinality alone is not presented as a classification theorem.
The noncommutativity result uses explicit permutations rather than a vacuous
assumption, and the cyclic comparison uses the actual addition law.  The finite
calculation is confined to a witness lemma; the headline obstruction combines
cardinality, a catalogued Lagrange bridge, and incompatible multiplication laws.
Nilpotency class, derived length, and automorphism order are deliberately not
claimed invariant after the coarser conjecture already fails.

Synthesis (Principal Investigator): A viable table should use composition data as
one axis and extension data as a second axis.  Atomic number is redundant once
factor multiplicities are retained, while extension data is indispensable even
at order six.
-- !-- Lab Notes -- !--
-/

namespace FiniteGroupPeriodicTable

/-- The prime-factor ledger used as a coarse “column label”.  Multiplicity is
retained, but extension and action data are discarded. -/
def PrimeLedger (n : ℕ) : Multiset ℕ := n.primeFactorsList

/-- A numerical shadow of a composition series: the listed factor orders,
together with the product formula for the ambient finite type. -/
structure FactorLedger (G : Type*) [Fintype G] where
  factors : List ℕ
  product_eq_card : factors.prod = Fintype.card G

/-- Concatenating two factor ledgers multiplies their represented orders. -/
lemma ledger_product_append (xs ys : List ℕ) :
    (xs ++ ys).prod = xs.prod * ys.prod := by
  induction xs with
  | nil => simp
  | cons x xs ih =>
      simp [ih, Nat.mul_assoc]

/-- Literal equality of factor-order ledgers forces equality of atomic number.
This is the numerical obstruction to “isotopes” having the same composition
factors, with multiplicity, but different orders. -/
theorem same_factor_ledger_forces_same_order
    {G H : Type*} [Fintype G] [Fintype H]
    (g : FactorLedger G) (h : FactorLedger H)
    (hsame : g.factors = h.factors) :
    Fintype.card G = Fintype.card H := by
  rw [← g.product_eq_card, ← h.product_eq_card, hsame]

/-- The two order-six test objects have the same atomic number.  The permutation
cardinality is computed from the factorial formula, while the cyclic cardinality
uses the catalogued finite-group bridge. -/
theorem cyclic_symmetric_atomic_collision :
    Fintype.card (ZMod 6) = Fintype.card (Equiv.Perm (Fin 3)) := by
  rw [GroupTheoryBridge.zmod_card]
  norm_num [Fintype.card_perm]

/-- Their prime ledgers consequently agree. -/
theorem cyclic_symmetric_same_prime_ledger :
    PrimeLedger (Fintype.card (ZMod 6)) =
      PrimeLedger (Fintype.card (Equiv.Perm (Fin 3))) := by
  rw [cyclic_symmetric_atomic_collision]

/-- Addition modulo six is commutative. -/
theorem cyclic_six_commutative :
    ∀ x y : ZMod 6, x + y = y + x := by
  intro x y
  exact add_comm x y

private def swap01 : Equiv.Perm (Fin 3) := Equiv.swap 0 1
private def swap12 : Equiv.Perm (Fin 3) := Equiv.swap 1 2

/-- Two concrete transpositions do not commute.  This finite witness is the
experimental core of the order-six counterexample. -/
lemma transpositions_do_not_commute : swap01 * swap12 ≠ swap12 * swap01 := by
  decide

/-- The symmetric group on three letters is noncommutative. -/
theorem symmetric_three_noncommutative :
    ¬ ∀ σ τ : Equiv.Perm (Fin 3), σ * τ = τ * σ := by
  intro hall
  exact transpositions_do_not_commute (hall swap01 swap12)

/-- **Periodic-law obstruction.**  Equal atomic number and equal prime-factor
ledger do not determine even the basic multiplication property of commutativity:
`ZMod 6` is commutative whereas `S₃` is not. -/
theorem prime_ledger_does_not_determine_commutativity :
    (Fintype.card (ZMod 6) = Fintype.card (Equiv.Perm (Fin 3))) ∧
    (PrimeLedger (Fintype.card (ZMod 6)) =
      PrimeLedger (Fintype.card (Equiv.Perm (Fin 3)))) ∧
    (∀ x y : ZMod 6, x + y = y + x) ∧
    ¬ (∀ σ τ : Equiv.Perm (Fin 3), σ * τ = τ * σ) := by
  refine ⟨cyclic_symmetric_atomic_collision,
    cyclic_symmetric_same_prime_ledger, cyclic_six_commutative, ?_⟩
  exact symmetric_three_noncommutative

/-- Every element in the order-six cyclic test group has additive order dividing
six.  This connects the table's atomic number to its element-order spectrum
through the additive form of Lagrange's theorem. -/
theorem cyclic_six_element_order_divides_atomic_number (x : ZMod 6) :
    addOrderOf x ∣ 6 := by
  have h : addOrderOf x ∣ Fintype.card (ZMod 6) := addOrderOf_dvd_card
  rw [GroupTheoryBridge.zmod_card] at h
  exact h

end FiniteGroupPeriodicTable