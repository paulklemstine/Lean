/-
  # Advanced CSI-FiSh: Class Group Actions, Security Reductions, and Isogeny Graphs

  This module formalizes:
  1. **IsogenyDegreeMap**: Novel structure for isogeny degree multiplicativity
  2. **Multi-Party CSIDH**: n-party key exchange with permutation invariance
  3. **Security Reductions**: Collision resistance, GAIP ↔ one-wayness
  4. **Orbit-Stabilizer**: Free action ↔ trivial stabilizer
  5. **CSI-FiSh**: 2-special soundness and completeness
  6. **Cayley Graph**: Regularity of isogeny graphs

  ## Catalog References
  - `Catalog/Cryptography/CSIFiSh.lean`: Base formalization
  - `Catalog/Cryptography/EllipticCurve/Basic.lean`: Elliptic curve arithmetic
-/
import Mathlib

open Finset Function BigOperators

namespace Cryptography.CSIFiShAdvanced

/-! ## Abstract Group Action -/

structure CryptoGroupAction (G : Type*) (X : Type*) [Group G] [Fintype G] [Fintype X]
    [DecidableEq G] [DecidableEq X] where
  act : G → X → X
  act_one : ∀ x : X, act 1 x = x
  act_mul : ∀ (g h : G) (x : X), act (g * h) x = act g (act h x)

structure FreeTrans (G : Type*) (X : Type*) [Group G] [Fintype G] [Fintype X]
    [DecidableEq G] [DecidableEq X] extends CryptoGroupAction G X where
  transitive : ∀ x y : X, ∃ g : G, act g x = y
  free : ∀ (g : G) (x : X), act g x = x → g = 1

namespace CryptoGroupAction

variable {G X : Type*} [Group G] [Fintype G] [Fintype X]
  [DecidableEq G] [DecidableEq X]
  (A : CryptoGroupAction G X)

theorem act_inv_cancel (g : G) (x : X) : A.act g⁻¹ (A.act g x) = x := by
  have h := A.act_mul g⁻¹ g x; rw [inv_mul_cancel, A.act_one] at h; exact h.symm

theorem act_inv_cancel' (g : G) (x : X) : A.act g (A.act g⁻¹ x) = x := by
  have h := A.act_mul g g⁻¹ x; rw [mul_inv_cancel, A.act_one] at h; exact h.symm

def actEquiv (g : G) : X ≃ X where
  toFun := A.act g
  invFun := A.act g⁻¹
  left_inv := A.act_inv_cancel g
  right_inv := A.act_inv_cancel' g

theorem act_injective (g : G) : Injective (A.act g) := (A.actEquiv g).injective
theorem act_surjective (g : G) : Surjective (A.act g) := (A.actEquiv g).surjective

end CryptoGroupAction

namespace FreeTrans

variable {G X : Type*} [Group G] [Fintype G] [Fintype X]
  [DecidableEq G] [DecidableEq X]
  (T : FreeTrans G X)

/-
**Uniqueness of connector**: fundamental consequence of freeness.
-/
theorem unique_connector (x y : X) (g h : G)
    (hg : T.act g x = y) (hh : T.act h x = y) : g = h := by
  -- By the freeness property, � we� have that $g * h⁻¹ = 1$.
  have hgh_inv : g * h⁻¹ = 1 := by
    apply T.free;
    rw [ T.act_mul, CryptoGroupAction.act_inv_cancel' ];
    rw [ inv_inv, hg, hh ];
  simpa using eq_inv_of_mul_eq_one_left hgh_inv

noncomputable def connector (x y : X) : G := (T.transitive x y).choose
theorem connector_spec (x y : X) : T.act (T.connector x y) x = y :=
  (T.transitive x y).choose_spec

theorem connector_self (x : X) : T.connector x x = 1 :=
  T.free _ _ (T.connector_spec x x)

/-
connector(y,x) = connector(x,y)⁻¹
-/
theorem connector_inv (x y : X) :
    T.connector y x = (T.connector x y)⁻¹ := by
      apply T.unique_connector y x (T.connector y x) (T.connector x y)⁻¹;
      · exact T.connector_spec y x;
      · have := T.connector_spec x y; have := T.act_inv_cancel ( T.connector x y ) x; aesop;

/-
connector(x,z) = connector(y,z) · connector(x,y)
-/
theorem connector_compose (x y z : X) :
    T.connector x z = T.connector y z * T.connector x y := by
      -- By the property of connector, we know that T.act (T.connector x z) x = z and T.act (T.connector y z * T.connector x y) x = z.
      have h1 : T.act (T.connector x z) x = z := by
        exact T.connector_spec x z
      have h2 : T.act (T.connector y z * T.connector x y) x = z := by
        rw [ T.act_mul, T.connector_spec, T.connector_spec ];
      exact T.unique_connector _ _ _ _ h1 h2

include T in
/-- |G| = |X| for a free transitive action. -/
theorem card_eq [Nonempty X] : Fintype.card G = Fintype.card X := by
  -- To show that f is bijective, we need to prove that it's both injective and surjective.
  have h_inj : Function.Injective (fun g : G => T.act g (Classical.arbitrary X)) := by
    exact fun g h hgh => T.unique_connector _ _ _ _ hgh rfl;
  refine' le_antisymm _ _;
  · exact Fintype.card_le_of_injective _ h_inj;
  · exact Fintype.card_le_of_surjective ( fun g => T.act g ( Classical.arbitrary X ) ) ( fun x => by rcases T.transitive ( Classical.arbitrary X ) x with ⟨ g, hg ⟩ ; exact ⟨ g, hg ⟩ )

end FreeTrans

/-! ## Isogeny Degree Map — Novel Structure -/

structure IsogenyDegreeMap (G : Type*) [Group G] where
  degree : G → ℕ
  degree_one : degree 1 = 1
  degree_mul : ∀ g h : G, degree (g * h) = degree g * degree h
  degree_pos : ∀ g : G, 0 < degree g

namespace IsogenyDegreeMap

variable {G : Type*} [Group G] (D : IsogenyDegreeMap G)

/-- All degrees = 1 in a group with ℕ-valued multiplicative degree. -/
theorem degree_eq_one (g : G) : D.degree g = 1 := by
  have h : D.degree g * D.degree g⁻¹ = 1 := by
    rw [← D.degree_mul, mul_inv_cancel, D.degree_one]
  exact Nat.eq_one_of_mul_eq_one_right h

theorem degree_inv (g : G) : D.degree g⁻¹ = D.degree g := by
  rw [D.degree_eq_one g, D.degree_eq_one g⁻¹]

/-- degree(gⁿ) = degree(g)ⁿ — by induction. -/
theorem degree_pow (g : G) (n : ℕ) : D.degree (g ^ n) = D.degree g ^ n := by
  induction n with
  | zero => simp [D.degree_one]
  | succ n ih => rw [pow_succ, pow_succ, ← ih, ← D.degree_mul]

def isSmooth (B : ℕ) (g : G) : Prop := D.degree g ≤ B

theorem smooth_mul_bound (B₁ B₂ : ℕ) (g h : G)
    (hg : D.isSmooth B₁ g) (hh : D.isSmooth B₂ h) :
    D.isSmooth (B₁ * B₂) (g * h) := by
  unfold isSmooth at *; rw [D.degree_mul]; exact Nat.mul_le_mul hg hh

def smoothSet [Fintype G] [DecidableEq G] (B : ℕ) : Finset G :=
  Finset.univ.filter (fun g => D.degree g ≤ B)

theorem eventually_smooth [Fintype G] [DecidableEq G] (g : G) :
    g ∈ D.smoothSet (D.degree g) := by simp [smoothSet]

end IsogenyDegreeMap

/-! ## Multi-Party CSIDH -/

section MultiParty

variable {G X : Type*} [CommGroup G] [Fintype G] [Fintype X]
  [DecidableEq G] [DecidableEq X]
  (T : FreeTrans G X)

def applyActions (acts : List G) (x : X) : X :=
  acts.foldl (fun acc g => T.act g acc) x

/-
Sequential application = acting by the product.
-/
theorem applyActions_eq_act_prod (acts : List G) (x : X) :
    applyActions T acts x = T.act acts.prod x := by
      induction' acts using List.reverseRecOn with g gs ih generalizing x <;> simp_all +decide [ applyActions ];
      · grind +suggestions;
      · rw [ ← T.act_mul, mul_comm ]

/-- **Multi-Party CSIDH**: Permutation invariance. -/
theorem multiparty_csidh_correctness
    (secrets perm : List G) (x₀ : X) (hperm : secrets.Perm perm) :
    applyActions T secrets x₀ = applyActions T perm x₀ := by
  rw [applyActions_eq_act_prod, applyActions_eq_act_prod]
  congr 1; exact List.Perm.prod_eq hperm

theorem multiparty_split (gs hs : List G) (x₀ : X) :
    applyActions T (gs ++ hs) x₀ = applyActions T gs (applyActions T hs x₀) := by
  convert applyActions_eq_act_prod T ( gs ++ hs ) x₀ using 1;
  convert T.act_mul ( List.prod gs ) ( List.prod hs ) x₀ |> Eq.symm using 1;
  · rw [ applyActions_eq_act_prod, applyActions_eq_act_prod ];
  · rw [ List.prod_append ]

end MultiParty

/-! ## Security Reductions -/

section Security

variable {G X : Type*} [Group G] [Fintype G] [Fintype X]
  [DecidableEq G] [DecidableEq X]

/-
**Collision resistance is unconditional** in free actions (by_contra).
-/
theorem collision_resistance_unconditional
    (T : FreeTrans G X) (x₀ : X) (g h : G)
    (collision : T.act g x₀ = T.act h x₀) : g = h := by
      have h_cancel : T.act (h⁻¹ * g) x₀ = x₀ := by
        rw [ T.act_mul, collision, T.act_inv_cancel ];
      have := T.free ( h⁻¹ * g ) x₀ h_cancel; simp_all +decide [ mul_eq_one_iff_eq_inv ] ;

/-- **Inverter solves GAIP**. -/
theorem inverter_solves_gaip
    (T : FreeTrans G X) (x₀ : X) (inverter : X → G)
    (h_inv : ∀ y : X, T.act (inverter y) x₀ = y) :
    ∀ g : G, inverter (T.act g x₀) = g := by
  intro g; exact T.unique_connector x₀ _ _ _ (h_inv (T.act g x₀)) rfl

/-- Public key map is bijective. -/
theorem publicKey_is_bijection (T : FreeTrans G X) (x₀ : X) :
    Bijective (fun g => T.act g x₀) :=
  ⟨fun g h hgh => T.unique_connector x₀ _ g h rfl hgh.symm,
   fun y => T.transitive x₀ y⟩

end Security

/-! ## Orbit-Stabilizer -/

section OrbitStabilizer

variable {G X : Type*} [Group G] [Fintype G] [Fintype X]
  [DecidableEq G] [DecidableEq X]
  (A : CryptoGroupAction G X)

def stabilizer (x : X) : Set G := {g : G | A.act g x = x}

theorem one_mem_stabilizer (x : X) : (1 : G) ∈ stabilizer A x := A.act_one x

theorem stabilizer_mul_mem (x : X) (g h : G)
    (hg : g ∈ stabilizer A x) (hh : h ∈ stabilizer A x) :
    g * h ∈ stabilizer A x := by
  show A.act (g * h) x = x
  have := A.act_mul g h x; rw [this, show A.act h x = x from hh, show A.act g x = x from hg]

theorem stabilizer_inv_mem (x : X) (g : G)
    (hg : g ∈ stabilizer A x) : g⁻¹ ∈ stabilizer A x := by
  show A.act g⁻¹ x = x
  conv_lhs => rw [show x = A.act g x from (hg : A.act g x = x).symm]
  exact A.act_inv_cancel g x

def orbit (x : X) : Finset X := Finset.univ.image (fun g => A.act g x)

theorem mem_orbit_self (x : X) : x ∈ orbit A x := by
  simp [orbit]; exact ⟨1, A.act_one x⟩

/-- Free action ↔ trivial stabilizer. -/
theorem free_iff_trivial_stabilizer :
    (∀ (g : G) (x : X), A.act g x = x → g = 1) ↔
    (∀ x : X, stabilizer A x = {1}) := by
  constructor
  · intro hfree x; ext g
    simp only [stabilizer, Set.mem_setOf_eq, Set.mem_singleton_iff]
    exact ⟨hfree g x, fun h => h ▸ A.act_one x⟩
  · intro hstab g x hgx
    have : g ∈ stabilizer A x := hgx
    rw [hstab x] at this; exact this

/-
In a free action, the orbit map is injective.
-/
theorem orbit_map_injective_of_free
    (hfree : ∀ (g : G) (x : X), A.act g x = x → g = 1)
    (x : X) : Injective (fun g => A.act g x) := by
      intro g h; have := hfree ( g * h⁻¹ ) x; simp_all +decide [ CryptoGroupAction.act_mul ] ;
      have := hfree ( g⁻¹ * h ) x; simp_all +decide [ CryptoGroupAction.act_mul ] ;
      intro hgh; specialize this ( by
        rw [ ← hgh, CryptoGroupAction.act_inv_cancel ] ) ; simp_all +decide [ mul_eq_one_iff_eq_inv ] ;

/-- In a free action, orbit size = group size. -/
theorem orbit_card_eq_of_free [Nonempty X]
    (hfree : ∀ (g : G) (x : X), A.act g x = x → g = 1)
    (x : X) : (orbit A x).card = Fintype.card G := by
  rw [orbit, Finset.card_image_of_injective _ (orbit_map_injective_of_free A hfree x),
      Finset.card_univ]

end OrbitStabilizer

/-! ## CSI-FiSh Signature Scheme -/

section CSIFiSh

variable {G X : Type*} [CommGroup G] [Fintype G] [Fintype X]
  [DecidableEq G] [DecidableEq X]

/-
**2-Special Soundness**: Extract the secret from two transcripts.
-/
theorem csifish_2_special_soundness
    (T : FreeTrans G X) (x₀ pk R : X) (z₀ z₁ : G)
    (h0 : T.act z₀ x₀ = R) (h1 : T.act z₁ pk = R) :
    T.act (z₀ * z₁⁻¹) x₀ = pk := by
      have h_inv_cancel : T.act z₁⁻¹ R = pk := by
        rw [ ← h1, CryptoGroupAction.act_inv_cancel ];
      rw [ ← h_inv_cancel, ← h0, T.act_mul ];
      rw [ ← T.act_mul, ← T.act_mul ] ; simp +decide [ mul_comm ] ;

/-- **Extracted key = secret**. -/
theorem extracted_key_is_connector
    (T : FreeTrans G X) (x₀ pk R : X) (z₀ z₁ s : G)
    (h0 : T.act z₀ x₀ = R) (h1 : T.act z₁ pk = R)
    (h_pk : T.act s x₀ = pk) :
    z₀ * z₁⁻¹ = s :=
  T.unique_connector x₀ pk _ _
    (csifish_2_special_soundness T x₀ pk R z₀ z₁ h0 h1) h_pk

/-
**Completeness**: Honest prover with z = r·s⁻¹ succeeds.
-/
theorem csifish_complete_1
    (T : FreeTrans G X) (x₀ : X) (s r : G) :
    T.act (r * s⁻¹) (T.act s x₀) = T.act r x₀ := by
      rw [ ← T.act_mul, mul_assoc, inv_mul_cancel, mul_one ]

end CSIFiSh

/-! ## Cayley Graph -/

section CayleyGraph

variable {G X : Type*} [Group G] [Fintype G] [Fintype X]
  [DecidableEq G] [DecidableEq X]

structure CayleyGraph (G : Type*) (X : Type*) [Group G] [Fintype G] [Fintype X]
    [DecidableEq G] [DecidableEq X] where
  action : CryptoGroupAction G X
  generators : Finset G
  one_not_gen : (1 : G) ∉ generators
  inv_closed : ∀ g ∈ generators, g⁻¹ ∈ generators

namespace CayleyGraph

variable (Γ : CayleyGraph G X)

def adjacent (x y : X) : Prop := ∃ g ∈ Γ.generators, Γ.action.act g x = y

/-- Adjacency is symmetric (rcases + inv_closed). -/
theorem adjacent_symm (x y : X) (h : Γ.adjacent x y) : Γ.adjacent y x := by
  rcases h with ⟨g, hg_mem, hg_act⟩
  exact ⟨g⁻¹, Γ.inv_closed g hg_mem, by rw [← hg_act]; exact Γ.action.act_inv_cancel g x⟩

def neighbors (x : X) : Finset X :=
  Γ.generators.image (fun g => Γ.action.act g x)

theorem degree_le_generators (x : X) :
    (Γ.neighbors x).card ≤ Γ.generators.card := Finset.card_image_le

/-
In a free action, the graph is regular.
-/
theorem degree_eq_generators_of_free
    (hfree : ∀ (g : G) (x : X), Γ.action.act g x = x → g = 1)
    (x : X) : (Γ.neighbors x).card = Γ.generators.card := by
      refine' Finset.card_image_of_injOn _;
      intro g hg h hh hgh;
      specialize hfree ( h⁻¹ * g ) x ; simp_all +decide [ CryptoGroupAction.act_mul ];
      simp_all +decide [ mul_eq_one_iff_eq_inv, CryptoGroupAction.act_inv_cancel ]

end CayleyGraph

end CayleyGraph

/-! ## Walk Composition -/

section WalkComposition

variable {G X : Type*} [Group G] [Fintype G] [Fintype X]
  [DecidableEq G] [DecidableEq X] (A : CryptoGroupAction G X)

def groupWalk (gs : List G) (x : X) : X :=
  gs.foldl (fun acc g => A.act g acc) x

theorem groupWalk_nil (x : X) : groupWalk A [] x = x := rfl

theorem groupWalk_append (gs hs : List G) (x : X) :
    groupWalk A (gs ++ hs) x = groupWalk A hs (groupWalk A gs x) := by
  simp [groupWalk, List.foldl_append]

end WalkComposition

/-! ## One-Way Function -/

section OneWay

variable {G X : Type*} [Group G] [Fintype G] [Fintype X]
  [DecidableEq G] [DecidableEq X]

structure GroupActionOWF (T : FreeTrans G X) where basePoint : X

theorem owf_injective (T : FreeTrans G X) (owf : GroupActionOWF T) :
    Injective (fun g => T.act g owf.basePoint) :=
  fun g h hgh => T.unique_connector owf.basePoint _ g h rfl hgh.symm

theorem owf_surjective (T : FreeTrans G X) (owf : GroupActionOWF T) :
    Surjective (fun g => T.act g owf.basePoint) :=
  fun y => T.transitive owf.basePoint y

end OneWay

/-! ## Testable Conjecture: Cayley Diameter

**Conjecture**: For ℤ/nℤ with generators {1, -1}, the diameter is ⌊n/2⌋.

**Test**: For n ∈ {5, 7, 11, 13, 17, 19, 23, 29}, compute BFS diameter.
Each should equal ⌊n/2⌋. -/

def CayleyDiameterConj (n : ℕ) (_ : 2 ≤ n) : Prop :=
  ∀ a : ZMod n, ∃ k : ℕ, k ≤ n / 2 ∧ (a = (k : ZMod n) ∨ a = -(k : ZMod n))

/-! ## Abelianness -/

section Abelianness

variable {G X : Type*} [CommGroup G] [Fintype G] [Fintype X]
  [DecidableEq G] [DecidableEq X] (T : FreeTrans G X)

/-
Actions commute in an abelian group.
-/
theorem actions_commute (g h : G) (x : X) :
    T.act g (T.act h x) = T.act h (T.act g x) := by
      rw [ ← T.act_mul, ← T.act_mul, mul_comm ]

/-
connector(x, g·y) = g · connector(x, y)
-/
theorem connector_act_right (x y : X) (g : G) :
    T.connector x (T.act g y) = g * T.connector x y := by
      -- By definition of connector, we know that T.connector x (T.act g y) is the unique element such that T.act (T.connector x (T.act g y)) x = T.act g y.
      have h_connector : T.act (T.connector x (T.act g y)) x = T.act g y := by
        exact T.connector_spec x _;
      -- By definition of connector, we know that T.act (T.connector x y) x = y.
      have h_connector2 : T.act (T.connector x y) x = y := by
        exact T.connector_spec x y;
      apply T.unique_connector;
      exact h_connector;
      rw [ T.act_mul, h_connector2 ]

end Abelianness

/-! ## Repeated Action -/

section PowerAction

variable {G X : Type*} [Group G] [Fintype G] [Fintype X]
  [DecidableEq G] [DecidableEq X] (A : CryptoGroupAction G X)

def repeatAction (g : G) : ℕ → X → X
  | 0, x => x
  | n + 1, x => A.act g (repeatAction g n x)

/-
Repeated action = g^n action, by induction.
-/
theorem repeatAction_eq_pow (g : G) (n : ℕ) (x : X) :
    repeatAction A g n x = A.act (g ^ n) x := by
      induction' n with n ih generalizing x;
      · simp +decide [ repeatAction ];
        exact Eq.symm ( A.act_one x );
      · convert congr_arg ( fun y => A.act g y ) ( ih x ) using 1;
        rw [ pow_succ', A.act_mul ]

end PowerAction

end Cryptography.CSIFiShAdvanced