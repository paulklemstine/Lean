import Mathlib

/-!
# The Eckmann-Hilton Argument

We formalize the Eckmann-Hilton argument: two binary operations on a type that share
a common identity element and satisfy the interchange law must be equal and commutative.
This is the algebraic core of why higher homotopy groups are abelian.

## Main definitions

* `HoTT.BinarySystem` — A type with a binary operation and two-sided identity
* `HoTT.InterchangeLaw` — The interchange law between two binary systems

## Main results

* `HoTT.eckmann_hilton_ops_eq` — Under interchange with shared unit, the operations coincide
* `HoTT.eckmann_hilton_comm` — The common operation is commutative
* `HoTT.group_self_interchange_comm` — Generalization: self-interchange implies commutativity
* `HoTT.eckmann_hilton_nontrivial_witness` — Boundary: EH cannot strengthen to triviality

## References

* Eckmann, B. and Hilton, P.J. (1962), "Group-like structures in general categories I"
-/

namespace HoTT

/-- A binary system is a type equipped with a binary operation and a two-sided identity element.
    This is the minimal algebraic structure needed for the Eckmann-Hilton argument. -/
structure BinarySystem (α : Type u) where
  /-- The binary operation -/
  op : α → α → α
  /-- The identity element -/
  e : α
  /-- Left identity law -/
  op_left_id : ∀ a, op e a = a
  /-- Right identity law -/
  op_right_id : ∀ a, op a e = a

/-- The interchange law between two binary systems S and T states that
    T.op (S.op a b) (S.op c d) = S.op (T.op a c) (T.op b d).
    This expresses compatibility between the two operations analogous to
    the interchange of horizontal and vertical composition of 2-cells. -/
def InterchangeLaw {α : Type u} (S T : BinarySystem α) : Prop :=
  ∀ a b c d, T.op (S.op a b) (S.op c d) = S.op (T.op a c) (T.op b d)

/-
!-- Proof of ops_eq: Instantiate the interchange law with (a, e_S, e_S, b).
The LHS simplifies to T.op a b via S's identity laws.
The RHS simplifies to S.op a b via T's identity laws (using hunit to
rewrite e_S to e_T). Hence T.op a b = S.op a b. -- !--

**Eckmann-Hilton Theorem (Part 1)**: Two binary operations sharing a common
    identity element and satisfying the interchange law must be pointwise equal.

    This is one of the most fundamental results in higher algebra. In homotopy
    type theory, it shows that the horizontal and vertical compositions of 2-paths
    coincide.
-/
theorem eckmann_hilton_ops_eq {α : Type u} (S T : BinarySystem α)
    (hunit : S.e = T.e) (h : InterchangeLaw S T) :
    ∀ a b, S.op a b = T.op a b := by
  -- Apply the interchange law with $a$, $e_S$, $e_S$, and $b$.
  intros a b
  have := h a S.e S.e b
  simp [S.op_left_id] at this;
  grind +suggestions

/-
!-- Proof of commutativity: Instantiate interchange with (e_S, a, b, e_S).
LHS: T.op (S.op e_S a) (S.op b e_S) = T.op a b (by S identity laws).
RHS: S.op (T.op e_S b) (T.op a e_S) = S.op b a (by T identity laws + hunit).
So T.op a b = S.op b a. Combined with ops_eq, S.op a b = S.op b a. -- !--

**Eckmann-Hilton Theorem (Part 2)**: Under the hypotheses of Part 1, both
    operations are commutative. This is why π_n(X) is abelian for n ≥ 2:
    the horizontal and vertical compositions of 2-loops interchange, forcing
    commutativity by Eckmann-Hilton.
-/
theorem eckmann_hilton_comm {α : Type u} (S T : BinarySystem α)
    (hunit : S.e = T.e) (h : InterchangeLaw S T) :
    ∀ a b, S.op a b = S.op b a := by
  intros a b
  have h_eq : T.op a b = S.op b a := by
    convert h S.e a b S.e using 1;
    · rw [ S.op_left_id, S.op_right_id ];
    · rw [ hunit, T.op_left_id, T.op_right_id ]
  exact (by
  rw [ ← h_eq, eckmann_hilton_ops_eq S T hunit h ])

/-! ### PEGB: Example — Integer addition as a self-interchanging binary system -/

/-- Integer addition forms a binary system with identity 0. -/
def intAddSystem : BinarySystem ℤ where
  op := (· + ·)
  e := 0
  op_left_id := zero_add
  op_right_id := add_zero

/-
!-- Self-interchange for addition follows from commutativity and associativity:
(a + b) + (c + d) = a + b + c + d = a + c + b + d = (a + c) + (b + d). -- !--

Integer addition satisfies the interchange law with itself.
    This witnesses the Example component of PEGB for the Eckmann-Hilton theorem.
-/
theorem int_add_self_interchange : InterchangeLaw intAddSystem intAddSystem := by
  -- By definition of interchange law, we need to show that for all integers a, b, c, and d, (a + b) + (c + d) = (a + c) + (b + d).
  intros a b c d
  simp [intAddSystem];
  grind

/-! ### PEGB: Generalization — Self-interchange implies commutativity for groups -/

/-
!-- Proof: specialize the interchange h to (1, a, b, 1).
Then (1 * a) * (b * 1) = (1 * b) * (a * 1), i.e., a * b = b * a. -- !--

**Generalization of Eckmann-Hilton**: Any group whose multiplication satisfies
    the self-interchange law `(a * b) * (c * d) = (a * c) * (b * d)` is abelian.

    This is strictly more general than the basic Eckmann-Hilton theorem because
    it requires only one operation (not two) — the interchange is with itself.
    The group structure provides inverses, which are not assumed in BinarySystem.
-/
theorem group_self_interchange_comm {G : Type u} [Group G]
    (h : ∀ a b c d : G, (a * b) * (c * d) = (a * c) * (b * d)) :
    ∀ a b : G, a * b = b * a := by
  intro a b; have := h 1 a b 1; simp_all +decide [ mul_assoc ] ;

/-! ### PEGB: Boundary — Eckmann-Hilton cannot be strengthened to triviality -/

/-
!-- ℤ under addition satisfies all EH hypotheses with itself (shared unit 0,
self-interchange), yet has nontrivial operation: 1 + 1 ≠ 0. This shows
EH is tight — it gives commutativity but not triviality. -- !--

**Boundary case**: The Eckmann-Hilton conclusion cannot be strengthened to show
    that the operation is trivial (i.e., op a b = e for all a, b). Integer addition
    is a concrete witness: it satisfies all EH hypotheses yet 1 + 1 ≠ 0.
-/
theorem eckmann_hilton_nontrivial_witness :
    ∃ (α : Type) (S T : BinarySystem α),
      S.e = T.e ∧ InterchangeLaw S T ∧ ∃ a b, S.op a b ≠ S.e := by
  fconstructor;
  exact ℤ;
  refine' ⟨ _, _, _, _, 1, 1, _ ⟩;
  exacts [ intAddSystem, intAddSystem, rfl, int_add_self_interchange, by decide ]

/-! ### Cross-connection: Commutative monoids yield self-interchanging binary systems -/

/-- Any commutative monoid gives rise to a binary system. -/
def BinarySystem.ofCommMonoid (M : Type u) [CommMonoid M] : BinarySystem M where
  op := (· * ·)
  e := 1
  op_left_id := one_mul
  op_right_id := mul_one

/-
!-- The self-interchange for a commutative monoid follows from commutativity
and associativity: (a*b)*(c*d) = a*(b*c)*d = a*(c*b)*d = (a*c)*(b*d). -- !--

**Cross-connection to Mathlib algebra**: Every commutative monoid satisfies
    the self-interchange law. This is the converse direction of Eckmann-Hilton:
    EH shows interchange → commutative; here we show commutative → self-interchange.
    Together, these establish that for a single binary system, commutativity and
    self-interchange are equivalent.
-/
theorem commMonoid_self_interchange (M : Type u) [CommMonoid M] :
    InterchangeLaw (BinarySystem.ofCommMonoid M) (BinarySystem.ofCommMonoid M) := by
  intros a b c d; exact (by
  convert mul_mul_mul_comm a b c d using 1)

end HoTT