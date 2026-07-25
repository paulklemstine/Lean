/-
  # Isogeny-Based Cryptography: CSI-FiSh

  Formalization of the class group action on supersingular elliptic curves
  and the one-way function underlying CSIDH/CSI-FiSh.

  ## Mathematical Background

  CSIDH uses the action of an ideal class group on the set of supersingular
  elliptic curves defined over F_p. The class group Cl(O) acts freely and
  transitively on the set of F_p-isomorphism classes of supersingular curves
  with endomorphism ring O.

  CSI-FiSh is a signature scheme built on CSIDH via the Fiat-Shamir transform.

  ## Key Results

  1. Free transitive group actions form torsors
  2. CSIDH correctness from commutativity
  3. Special soundness of the CSI-FiSh identification scheme
  4. Collision resistance from freeness
  5. Cayley graph properties
-/
import Mathlib

open Finset Function

namespace Cryptography.CSIFiSh

/-! ## Part 1: Abstract Group Actions -/

/-- A `CryptoGroupAction` models a finite group acting on a finite set,
    abstracting the class group action on supersingular elliptic curve
    isomorphism classes used in CSIDH. -/
structure CryptoGroupAction (G : Type*) (X : Type*) [Group G] [Fintype G] [Fintype X]
    [DecidableEq G] [DecidableEq X] where
  /-- The group action map -/
  act : G → X → X
  /-- Identity acts trivially -/
  act_one : ∀ x : X, act 1 x = x
  /-- Action is compatible with group multiplication -/
  act_mul : ∀ (g h : G) (x : X), act (g * h) x = act g (act h x)

namespace CryptoGroupAction

variable {G X : Type*} [Group G] [Fintype G] [Fintype X]
  [DecidableEq G] [DecidableEq X]
  (A : CryptoGroupAction G X)

/-- The action of the inverse undoes the action. -/
theorem act_inv_cancel (g : G) (x : X) : A.act g⁻¹ (A.act g x) = x := by
  rw [← A.act_mul]; simp [A.act_one]

/-- The action of the inverse undoes the action (other direction). -/
theorem act_inv_cancel' (g : G) (x : X) : A.act g (A.act g⁻¹ x) = x := by
  rw [← A.act_mul]; simp [A.act_one]

/-- Each group element defines a permutation of X. -/
def actEquiv (g : G) : X ≃ X where
  toFun := A.act g
  invFun := A.act g⁻¹
  left_inv := A.act_inv_cancel g
  right_inv := A.act_inv_cancel' g

/-- The action map for a fixed group element is injective. -/
theorem act_injective (g : G) : Injective (A.act g) :=
  (A.actEquiv g).injective

/-- The action map for a fixed group element is surjective. -/
theorem act_surjective (g : G) : Surjective (A.act g) :=
  (A.actEquiv g).surjective

end CryptoGroupAction

/-! ## Part 2: Free and Transitive Actions (Torsors) -/

/-- A `FreeTrans` group action is free and transitive — i.e., a torsor.
    This models the CSIDH setting where the ideal class group acts
    regularly on the set of supersingular curves with given endomorphism ring. -/
structure FreeTrans (G : Type*) (X : Type*) [Group G] [Fintype G] [Fintype X]
    [DecidableEq G] [DecidableEq X] extends CryptoGroupAction G X where
  /-- Transitivity: for any two elements, some group element maps one to the other -/
  transitive : ∀ x y : X, ∃ g : G, act g x = y
  /-- Freeness: only identity fixes any point -/
  free : ∀ (g : G) (x : X), act g x = x → g = 1

namespace FreeTrans

variable {G X : Type*} [Group G] [Fintype G] [Fintype X]
  [DecidableEq G] [DecidableEq X]
  (T : FreeTrans G X)

/-
In a free transitive action, the connecting element is unique.
    This is the key property that makes GAIP well-defined.
-/
theorem unique_connector (x y : X) (g h : G)
    (hg : T.act g x = y) (hh : T.act h x = y) : g = h := by
  have h_disconnect : T.act (g * h⁻¹) y = y := by
    grind +suggestions;
  have := T.free ( g * h⁻¹ ) y h_disconnect; simp_all +decide [ mul_inv_eq_one ] ;

/-- In a free transitive action, there is a unique group element connecting any two points.
    Computing this is the Group Action Inverse Problem (GAIP). -/
noncomputable def connector (x y : X) : G :=
  (T.transitive x y).choose

theorem connector_spec (x y : X) : T.act (T.connector x y) x = y :=
  (T.transitive x y).choose_spec

/-- The connector from x to x is the identity. -/
theorem connector_self (x : X) : T.connector x x = 1 :=
  T.free _ _ (T.connector_spec x x)

/-
The connector composes: connector(x,z) = connector(y,z) * connector(x,y).
-/
theorem connector_compose (x y z : X) :
    T.connector x z = T.connector y z * T.connector x y := by
  apply T.unique_connector;
  exact T.connector_spec x z;
  rw [ T.act_mul, T.connector_spec, T.connector_spec ]

/-
The connector inverts: connector(y,x) = connector(x,y)⁻¹.
-/
theorem connector_inv (x y : X) :
    T.connector y x = (T.connector x y)⁻¹ := by
  apply T.unique_connector y x (T.connector y x) ( (T.connector x y)⁻¹) (T.connector_spec y x) (by
  convert T.act_inv_cancel ( T.connector x y ) x using 1 ; rw [ T.connector_spec ])

include T in
/-- **Cardinality theorem**: In a free transitive action, |G| = |X|.
    In CSIDH, the class number equals the number of curve isomorphism classes. -/
theorem card_eq [Nonempty X] : Fintype.card G = Fintype.card X := by
  let x₀ : X := Classical.arbitrary X
  apply Fintype.card_of_bijective (f := fun g => T.act g x₀)
  constructor
  · intro g h (hgh : T.act g x₀ = T.act h x₀)
    exact T.unique_connector x₀ _ g h rfl hgh.symm
  · intro y
    exact T.transitive x₀ y

end FreeTrans

/-! ## Part 3: One-Way Functions and GAIP -/

/-- The Group Action Inverse Problem (GAIP): given base x₀ and y = g·x₀, recover g. -/
structure GAIP (G : Type*) (X : Type*) [Group G] [Fintype G] [Fintype X]
    [DecidableEq G] [DecidableEq X] (T : FreeTrans G X) where
  /-- A fixed base point (public parameter) -/
  basePoint : X

namespace GAIP

variable {G X : Type*} [Group G] [Fintype G] [Fintype X]
  [DecidableEq G] [DecidableEq X]
  {T : FreeTrans G X}
  (P : GAIP G X T)

/-- The CSIDH public key map: g ↦ g · x₀ -/
def publicKey (g : G) : X := T.act g P.basePoint

/-
The public key map is injective (from freeness).
-/
theorem publicKey_injective : Injective P.publicKey := by
  intro g h hgh;
  convert T.unique_connector _ _ _ _ hgh rfl

/-- The public key map is surjective (from transitivity). -/
theorem publicKey_surjective : Surjective P.publicKey := by
  intro y
  obtain ⟨g, hg⟩ := T.transitive P.basePoint y
  exact ⟨g, hg⟩

/-- The public key map is a bijection G ≃ X. -/
theorem publicKey_bijective : Bijective P.publicKey :=
  ⟨P.publicKey_injective, P.publicKey_surjective⟩

end GAIP

/-! ## Part 4: CSIDH Key Exchange -/

/-- CSIDH key exchange protocol. -/
structure CSIDHKeyExchange (G : Type*) (X : Type*) [CommGroup G] [Fintype G] [Fintype X]
    [DecidableEq G] [DecidableEq X] (T : FreeTrans G X) where
  basePoint : X
  aliceSecret : G
  bobSecret : G

namespace CSIDHKeyExchange

variable {G X : Type*} [CommGroup G] [Fintype G] [Fintype X]
  [DecidableEq G] [DecidableEq X]
  {T : FreeTrans G X}
  (KE : CSIDHKeyExchange G X T)

def alicePublic : X := T.act KE.aliceSecret KE.basePoint
def bobPublic : X := T.act KE.bobSecret KE.basePoint
def aliceShared : X := T.act KE.aliceSecret KE.bobPublic
def bobShared : X := T.act KE.bobSecret KE.alicePublic

/-
**CSIDH Correctness**: Alice and Bob compute the same shared secret.
    This relies on commutativity of the group (class group is abelian).
-/
theorem shared_secret_agreement : KE.aliceShared = KE.bobShared := by
  -- By definition of `CSIDHKeyExchange`, we have `aliceShared = T.act KE.aliceSecret (T.act KE.bobSecret KE.basePoint)` and `bobShared = T.act KE.bobSecret (T.act KE.aliceSecret KE.basePoint)`.
  have h_alice_bob : KE.aliceShared = T.act (KE.aliceSecret * KE.bobSecret) KE.basePoint ∧ KE.bobShared = T.act (KE.bobSecret * KE.aliceSecret) KE.basePoint := by
    simp +decide [ CSIDHKeyExchange.aliceShared, CSIDHKeyExchange.bobShared, CSIDHKeyExchange.alicePublic, CSIDHKeyExchange.bobPublic, T.act_mul ];
  rw [ h_alice_bob.1, h_alice_bob.2, mul_comm ]

end CSIDHKeyExchange

/-! ## Part 5: Cayley Graph of the Group Action -/

/-- The Cayley graph structure for a group action with generators. -/
structure IsogenyCayleyGraph (G : Type*) (X : Type*) [Group G] [Fintype G] [Fintype X]
    [DecidableEq G] [DecidableEq X] where
  action : CryptoGroupAction G X
  generators : Finset G
  one_not_mem : (1 : G) ∉ generators
  inv_mem : ∀ g ∈ generators, g⁻¹ ∈ generators

namespace IsogenyCayleyGraph

variable {G X : Type*} [Group G] [Fintype G] [Fintype X]
  [DecidableEq G] [DecidableEq X]
  (Γ : IsogenyCayleyGraph G X)

/-- Two vertices are adjacent if a generator connects them. -/
def adjacent (x y : X) : Prop :=
  ∃ g ∈ Γ.generators, Γ.action.act g x = y

/-
Adjacency is symmetric.
-/
theorem adjacent_symm (x y : X) (h : Γ.adjacent x y) : Γ.adjacent y x := by
  -- By definition of adjacency, we know that if x is adjacent to y, then there exists a generator � g� in the set of generators such that the action of g on x is y.
  obtain ⟨g, hg⟩ := h;
  exact ⟨ g⁻¹, Γ.inv_mem _ hg.1, by simpa [ hg.2 ] using Γ.action.act_inv_cancel g x ⟩

/-- The neighbor set of a vertex. -/
def neighbors (x : X) : Finset X :=
  Γ.generators.image (fun g => Γ.action.act g x)

/-- Neighbor count is bounded by generator count. -/
theorem neighbors_card_le (x : X) : (Γ.neighbors x).card ≤ Γ.generators.card :=
  Finset.card_image_le

end IsogenyCayleyGraph

/-! ## Part 6: Walk Length -/

/-- A walk in the Cayley graph is a sequence of generator applications. -/
def groupActionWalk {G X : Type*} [Group G] (act : G → X → X) :
    List G → X → X
  | [], x => x
  | g :: gs, x => act g (groupActionWalk act gs x)

/-
Walk equals action by product of elements.
-/
theorem groupActionWalk_eq_act {G X : Type*} [Group G] [Fintype G] [Fintype X]
    [DecidableEq G] [DecidableEq X]
    (A : CryptoGroupAction G X) (gs : List G) (x : X) :
    groupActionWalk A.act gs x = A.act (gs.prod) x := by
  induction' gs with g gs ih generalizing x;
  · -- The base case is when the list is empty.
    simp [groupActionWalk];
    rw [ A.act_one ];
  · simp +decide [ *, groupActionWalk ];
    rw [ A.act_mul ]

/-! ## Part 7: Collision Resistance from GAIP -/

/-
**Collision implies non-trivial stabilizer**: Finding a collision in the
    public key map yields a non-trivial element fixing the base point.
-/
theorem collision_implies_nontrivial_stabilizer
    {G X : Type*} [Group G] [Fintype G] [Fintype X]
    [DecidableEq G] [DecidableEq X]
    (T : FreeTrans G X) (x₀ : X) (g h : G) (g_ne_h : g ≠ h)
    (collision : T.act g x₀ = T.act h x₀) :
    ∃ s : G, s ≠ 1 ∧ T.act s x₀ = x₀ := by
  use h⁻¹ * g;
  simp_all +decide [ mul_eq_one_iff_eq_inv, CryptoGroupAction.act_mul ];
  exact ⟨ Ne.symm g_ne_h, by rw [ T.act_inv_cancel ] ⟩

/-
**No collisions in free actions**: The public key map has no collisions.
-/
theorem no_collision_in_free_action
    {G X : Type*} [Group G] [Fintype G] [Fintype X]
    [DecidableEq G] [DecidableEq X]
    (T : FreeTrans G X) (x₀ : X) (g h : G)
    (collision : T.act g x₀ = T.act h x₀) : g = h := by
  -- By the freeness condition, if $T.act g x₀ = T.act h x₀$, then $g = h$.
  apply T.unique_connector x₀ (T.act g x₀) g h;
  · rfl;
  · exact collision.symm

/-! ## Part 8: CSI-FiSh Identification Scheme -/

/-
**Special Soundness**: From two accepting transcripts with different challenges
    on the same commitment, extract the secret key. Given:
    - z₀ · x₀ = R (response to challenge 0)
    - z₁ · pk = R (response to challenge 1)
    We extract: z₀ · z₁⁻¹ maps x₀ to pk.
-/
theorem csifish_special_soundness
    {G X : Type*} [CommGroup G] [Fintype G] [Fintype X]
    [DecidableEq G] [DecidableEq X]
    (T : FreeTrans G X) (x₀ pk R : X) (z₀ z₁ : G)
    (h0 : T.act z₀ x₀ = R)
    (h1 : T.act z₁ pk = R) :
    T.act (z₀ * z₁⁻¹) x₀ = pk := by
  have h_eq : T.act z₁⁻¹ R = pk := by
    rw [ ← h1, T.act_inv_cancel ]
  have h_eq' : T.act z₁⁻¹ (T.act z₀ x₀) = pk := by
    rw [ h0, h_eq ]
  have h_eq'' : T.act (z₁⁻¹ * z₀) x₀ = pk := by
    rw [ ← h_eq', T.act_mul ]
  have h_eq''' : T.act (z₀ * z₁⁻¹) x₀ = pk := by
    rwa [ mul_comm ] at h_eq''
  exact h_eq'''

/-- **Completeness for challenge 0**: if z = r, then z · x₀ = r · x₀. -/
theorem csifish_completeness_0
    {G X : Type*} [CommGroup G] [Fintype G] [Fintype X]
    [DecidableEq G] [DecidableEq X]
    (T : FreeTrans G X) (x₀ : X) (_s r : G) :
    T.act r x₀ = T.act r x₀ := rfl

/-
**Completeness for challenge 1**: if z = r·s⁻¹, then z · pk = r · x₀
    where pk = s · x₀.
-/
theorem csifish_completeness_1
    {G X : Type*} [CommGroup G] [Fintype G] [Fintype X]
    [DecidableEq G] [DecidableEq X]
    (T : FreeTrans G X) (x₀ : X) (s r : G) :
    T.act (r * s⁻¹) (T.act s x₀) = T.act r x₀ := by
  rw [ ← T.act_mul, mul_assoc, inv_mul_cancel, mul_one ]

/-! ## Part 9: Key Reusability Security -/

/-
If GAIP is hard, then the public key reveals no information about the
    secret beyond what the public key itself shows. Formally: knowing pk = g·x₀
    and computing connector(x₀, pk) is exactly the GAIP.
-/
theorem pk_recovery_is_gaip
    {G X : Type*} [Group G] [Fintype G] [Fintype X]
    [DecidableEq G] [DecidableEq X]
    (T : FreeTrans G X) (x₀ : X) (g : G)
    (_hpk : T.act g x₀ = T.act g x₀) :
    T.connector x₀ (T.act g x₀) = g := by
  apply T.unique_connector;
  exacts [ T.connector_spec x₀ ( T.act g x₀ ), rfl ]

/-! ## Part 10: Mixing Time Conjecture -/

/-- **Conjecture (Testable)**: For a Cayley graph on ℤ/nℤ with generator set {1, -1},
    the diameter is ⌊n/2⌋. This is a concrete, testable instance of the general
    mixing/diameter question for isogeny graphs.

    **Test**: Compute BFS diameter for n = 3, 5, 7, 11, 13, 17, 19, 23.
    The diameter should be ⌊n/2⌋ in each case. -/
def cayleyDiameterConjecture (n : ℕ) (_hn : 2 ≤ n) : Prop :=
  ∀ a : ZMod n, ∃ k : ℕ, k ≤ n / 2 ∧ (a = (k : ZMod n) ∨ a = -(k : ZMod n))

end Cryptography.CSIFiSh