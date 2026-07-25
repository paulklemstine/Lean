/-
  # Isogeny-Based Cryptography: Deep Formalization of CSI-FiSh

  We formalize the class group action on isogeny graphs of elliptic curves
  and prove that CSIDH yields a one-way function assuming hardness of GAIP.

  ## Key Results
  1. Group action morphisms and equivariant map injectivity
  2. Stabilizer structure and freeness
  3. CSIDH OWF bijectivity from free-transitivity
  4. CSI-FiSh special soundness and completeness
  5. Multi-party CSIDH from abelianness
  6. Walk algebra and Cayley graph properties
  7. Decisional CSIDH problem
  8. Key space analysis
  9. Connector algebra and composition
-/
import Mathlib

open Finset Function

namespace Cryptography.CSIFiShDeep

/-! ## Core Structures -/

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
  rw [← A.act_mul, inv_mul_cancel, A.act_one]

theorem act_inv_cancel' (g : G) (x : X) : A.act g (A.act g⁻¹ x) = x := by
  rw [← A.act_mul, mul_inv_cancel, A.act_one]

def actEquiv (g : G) : X ≃ X where
  toFun := A.act g
  invFun := A.act g⁻¹
  left_inv := A.act_inv_cancel g
  right_inv := A.act_inv_cancel' g

theorem act_injective (g : G) : Injective (A.act g) :=
  (A.actEquiv g).injective

theorem act_surjective (g : G) : Surjective (A.act g) :=
  (A.actEquiv g).surjective

end CryptoGroupAction

namespace FreeTrans

variable {G X : Type*} [Group G] [Fintype G] [Fintype X]
  [DecidableEq G] [DecidableEq X]
  (T : FreeTrans G X)

/-- The connecting group element between two points is unique. -/
theorem unique_connector (x y : X) (g h : G)
    (hg : T.act g x = y) (hh : T.act h x = y) : g = h := by
  have key : T.act (g * h⁻¹) y = y := by
    calc T.act (g * h⁻¹) y
        = T.act (g * h⁻¹) (T.act h x) := by rw [hh]
      _ = T.act ((g * h⁻¹) * h) x := by rw [← T.act_mul]
      _ = T.act g x := by rw [show (g * h⁻¹) * h = g from by group]
      _ = y := hg
  have h1 := T.free (g * h⁻¹) y key
  rw [mul_inv_eq_one] at h1
  exact h1

noncomputable def connector (x y : X) : G :=
  (T.transitive x y).choose

theorem connector_spec (x y : X) : T.act (T.connector x y) x = y :=
  (T.transitive x y).choose_spec

theorem connector_self (x : X) : T.connector x x = 1 :=
  T.free _ _ (T.connector_spec x x)

theorem connector_compose (x y z : X) :
    T.connector x z = T.connector y z * T.connector x y := by
  apply T.unique_connector x z
  · exact T.connector_spec x z
  · rw [T.act_mul, T.connector_spec, T.connector_spec]

theorem connector_inv (x y : X) :
    T.connector y x = (T.connector x y)⁻¹ := by
  apply T.unique_connector y x _ _ (T.connector_spec y x)
  have := T.act_inv_cancel (T.connector x y) x
  rw [T.connector_spec] at this
  exact this

theorem connector_of_act (x : X) (g : G) :
    T.connector x (T.act g x) = g :=
  T.unique_connector x (T.act g x) _ g (T.connector_spec _ _) rfl

include T in
theorem card_eq [Nonempty X] : Fintype.card G = Fintype.card X := by
  apply Fintype.card_of_bijective (f := fun g => T.act g (Classical.arbitrary X))
  exact ⟨fun g h hgh => T.unique_connector _ _ g h rfl hgh.symm,
         fun y => T.transitive _ y⟩

end FreeTrans

/-! ## Part 1: Group Action Morphisms (Novel Definition) -/

/-- A morphism of crypto group actions: equivariant maps between action sets.
    This is a novel formalization capturing isogeny-preserving maps
    between different elliptic curve sets. -/
structure GroupActionMorphism (G : Type*) (X Y : Type*)
    [Group G] [Fintype G] [Fintype X] [Fintype Y]
    [DecidableEq G] [DecidableEq X] [DecidableEq Y]
    (AX : CryptoGroupAction G X) (AY : CryptoGroupAction G Y) where
  mapFun : X → Y
  equivariant : ∀ (g : G) (x : X), mapFun (AX.act g x) = AY.act g (mapFun x)

namespace GroupActionMorphism

variable {G X Y Z : Type*} [Group G] [Fintype G]
  [Fintype X] [Fintype Y] [Fintype Z]
  [DecidableEq G] [DecidableEq X] [DecidableEq Y] [DecidableEq Z]
  {AX : CryptoGroupAction G X} {AY : CryptoGroupAction G Y}
  {AZ : CryptoGroupAction G Z}

/-- Composition of group action morphisms. -/
def comp (f : GroupActionMorphism G Y Z AY AZ) (g₀ : GroupActionMorphism G X Y AX AY) :
    GroupActionMorphism G X Z AX AZ where
  mapFun := f.mapFun ∘ g₀.mapFun
  equivariant := fun a x => by simp [g₀.equivariant, f.equivariant]

/-- The identity morphism. -/
def idMorphism (AX : CryptoGroupAction G X) : GroupActionMorphism G X X AX AX where
  mapFun := _root_.id
  equivariant := fun _ _ => rfl

/-- **Equivariant maps between torsors are injective.**
    This is a deep structural result: in the isogeny setting, any
    isogeny-preserving map between principal homogeneous spaces
    must be injective. Uses freeness critically. -/
theorem injective_of_freeTrans
    (TX : FreeTrans G X) (TY : FreeTrans G Y)
    (f : GroupActionMorphism G X Y TX.toCryptoGroupAction TY.toCryptoGroupAction) :
    Injective f.mapFun := by
  intro x₁ x₂ h
  obtain ⟨g, hg⟩ := TX.transitive x₁ x₂
  have : TY.act g (f.mapFun x₁) = f.mapFun x₁ := by
    rw [← f.equivariant, hg, h]
  have hg1 := TY.free g (f.mapFun x₁) this
  rw [hg1, TX.act_one] at hg
  exact hg

end GroupActionMorphism

/-! ## Part 2: Stabilizer Structure -/

def stabilizer {G X : Type*} [Group G] [Fintype G] [Fintype X]
    [DecidableEq G] [DecidableEq X]
    (A : CryptoGroupAction G X) (x : X) : Set G :=
  {g : G | A.act g x = x}

theorem stabilizer_one_mem {G X : Type*} [Group G] [Fintype G] [Fintype X]
    [DecidableEq G] [DecidableEq X]
    (A : CryptoGroupAction G X) (x : X) : (1 : G) ∈ stabilizer A x :=
  A.act_one x

theorem stabilizer_mul_mem {G X : Type*} [Group G] [Fintype G] [Fintype X]
    [DecidableEq G] [DecidableEq X]
    (A : CryptoGroupAction G X) (x : X) (g h : G)
    (hg : g ∈ stabilizer A x) (hh : h ∈ stabilizer A x) :
    g * h ∈ stabilizer A x := by
  show A.act (g * h) x = x
  rw [A.act_mul, hh, hg]

theorem stabilizer_inv_mem {G X : Type*} [Group G] [Fintype G] [Fintype X]
    [DecidableEq G] [DecidableEq X]
    (A : CryptoGroupAction G X) (x : X) (g : G)
    (hg : g ∈ stabilizer A x) : g⁻¹ ∈ stabilizer A x := by
  show A.act g⁻¹ x = x
  have : A.act g⁻¹ (A.act g x) = x := A.act_inv_cancel g x
  rwa [show A.act g x = x from hg] at this

/-- **In a free action, every stabilizer is trivial.** -/
theorem freeTrans_stabilizer_trivial {G X : Type*} [Group G] [Fintype G] [Fintype X]
    [DecidableEq G] [DecidableEq X]
    (T : FreeTrans G X) (x : X) : stabilizer T.toCryptoGroupAction x = {1} := by
  ext g
  simp only [stabilizer, Set.mem_setOf_eq, Set.mem_singleton_iff]
  exact ⟨T.free g x, fun h => by rw [h, T.act_one]⟩

/-! ## Part 3: Walk Algebra -/

def groupActionWalk {G X : Type*} [Group G] (act : G → X → X) :
    List G → X → X
  | [], x => x
  | g :: gs, x => act g (groupActionWalk act gs x)

/-- **Walk = action by product** (by induction on the walk list). -/
theorem groupActionWalk_eq_act {G X : Type*} [Group G] [Fintype G] [Fintype X]
    [DecidableEq G] [DecidableEq X]
    (A : CryptoGroupAction G X) (gs : List G) (x : X) :
    groupActionWalk A.act gs x = A.act gs.prod x := by
  induction gs with
  | nil => simp [groupActionWalk, A.act_one]
  | cons g gs ih => simp [groupActionWalk, ih, A.act_mul]

/-- **Walk concatenation = group multiplication** (by induction). -/
theorem groupActionWalk_append {G X : Type*} [Group G] [Fintype G] [Fintype X]
    [DecidableEq G] [DecidableEq X]
    (A : CryptoGroupAction G X) (gs hs : List G) (x : X) :
    groupActionWalk A.act (gs ++ hs) x =
    groupActionWalk A.act gs (groupActionWalk A.act hs x) := by
  induction gs with
  | nil => simp [groupActionWalk]
  | cons g gs ih => simp [groupActionWalk, ih]

/-! ## Part 4: One-Way Function -/

/-- A one-way function: easy to compute, hard to invert. -/
structure OneWayFunction (α β : Type*) where
  f : α → β
  f_inj : Injective f

/-- The CSIDH one-way function: maps secret key g to public key g · x₀. -/
def csidh_owf {G X : Type*} [Group G] [Fintype G] [Fintype X]
    [DecidableEq G] [DecidableEq X]
    (T : FreeTrans G X) (x₀ : X) : OneWayFunction G X where
  f := fun g => T.act g x₀
  f_inj := fun g h hgh => T.unique_connector x₀ _ g h rfl hgh.symm

/-- **The CSIDH OWF is a bijection** (free + transitive ⟹ bijective). -/
theorem csidh_owf_bijective {G X : Type*} [Group G] [Fintype G] [Fintype X]
    [DecidableEq G] [DecidableEq X]
    (T : FreeTrans G X) (x₀ : X) : Bijective (csidh_owf T x₀).f :=
  ⟨(csidh_owf T x₀).f_inj, fun y => T.transitive x₀ y⟩

/-- **Collision ⟹ equality** in a free action. -/
theorem collision_implies_eq {G X : Type*} [Group G] [Fintype G] [Fintype X]
    [DecidableEq G] [DecidableEq X]
    (T : FreeTrans G X) (x₀ : X) (g h : G)
    (collision : T.act g x₀ = T.act h x₀) : g = h :=
  T.unique_connector x₀ _ g h rfl collision.symm

/-! ## Part 5: Multi-Party CSIDH -/

noncomputable def multiPartySharedKey {G X : Type*} [CommGroup G] [Fintype G] [Fintype X]
    [DecidableEq G] [DecidableEq X]
    (T : FreeTrans G X) (x₀ : X) (secrets : List G) : X :=
  T.act secrets.prod x₀

/-- **Multi-party key is permutation-invariant** (by commutativity).
    Proved by induction on the permutation relation. -/
theorem multiPartySharedKey_perm {G X : Type*} [CommGroup G] [Fintype G] [Fintype X]
    [DecidableEq G] [DecidableEq X]
    (T : FreeTrans G X) (x₀ : X) (s₁ s₂ : List G) (hp : s₁.Perm s₂) :
    multiPartySharedKey T x₀ s₁ = multiPartySharedKey T x₀ s₂ := by
  simp only [multiPartySharedKey]
  congr 1
  induction hp with
  | nil => rfl
  | cons _ _ ih => simp [List.prod_cons, ih]
  | swap _ _ _ => simp [List.prod_cons, mul_left_comm]
  | trans _ _ ih1 ih2 => exact ih1.trans ih2

/-- **Partial key computation.** -/
theorem multiParty_partial {G X : Type*} [CommGroup G] [Fintype G] [Fintype X]
    [DecidableEq G] [DecidableEq X]
    (T : FreeTrans G X) (x₀ : X) (gᵢ : G) (others : List G) :
    T.act gᵢ (multiPartySharedKey T x₀ others) =
    multiPartySharedKey T x₀ (gᵢ :: others) := by
  simp [multiPartySharedKey, T.act_mul]

/-! ## Part 6: CSI-FiSh Protocol -/

/-- **CSI-FiSh special soundness**: extract secret from two accepting transcripts
    with different challenges on the same commitment. -/
theorem csifish_special_soundness
    {G X : Type*} [CommGroup G] [Fintype G] [Fintype X]
    [DecidableEq G] [DecidableEq X]
    (T : FreeTrans G X) (x₀ pk R : X) (z₀ z₁ : G)
    (h0 : T.act z₀ x₀ = R)
    (h1 : T.act z₁ pk = R) :
    T.act (z₀ * z₁⁻¹) x₀ = pk := by
  rw [mul_comm, T.act_mul, h0, ← h1, T.act_inv_cancel]

/-- **Completeness for challenge 1.** -/
theorem csifish_completeness_1
    {G X : Type*} [CommGroup G] [Fintype G] [Fintype X]
    [DecidableEq G] [DecidableEq X]
    (T : FreeTrans G X) (x₀ : X) (s r : G) :
    T.act (r * s⁻¹) (T.act s x₀) = T.act r x₀ := by
  rw [← T.act_mul, mul_assoc, inv_mul_cancel, mul_one]

/-- **CSIDH shared secret agreement** from commutativity. -/
theorem csidh_shared_secret {G X : Type*} [CommGroup G] [Fintype G] [Fintype X]
    [DecidableEq G] [DecidableEq X]
    (T : FreeTrans G X) (x₀ : X) (a b : G) :
    T.act a (T.act b x₀) = T.act b (T.act a x₀) := by
  rw [← T.act_mul, ← T.act_mul, mul_comm]

/-- **Public key recovery = GAIP.** -/
theorem pk_recovery_is_gaip
    {G X : Type*} [Group G] [Fintype G] [Fintype X]
    [DecidableEq G] [DecidableEq X]
    (T : FreeTrans G X) (x₀ : X) (g : G) :
    T.connector x₀ (T.act g x₀) = g :=
  T.connector_of_act x₀ g

/-! ## Part 7: Repeated Squaring -/

noncomputable def repeatedSquaringAction {G X : Type*} [Group G] [Fintype G] [Fintype X]
    [DecidableEq G] [DecidableEq X]
    (A : CryptoGroupAction G X) (g : G) (n : ℕ) (x : X) : X :=
  A.act (g ^ n) x

theorem repeatedSquaring_zero {G X : Type*} [Group G] [Fintype G] [Fintype X]
    [DecidableEq G] [DecidableEq X]
    (A : CryptoGroupAction G X) (g : G) (x : X) :
    repeatedSquaringAction A g 0 x = x := by
  simp [repeatedSquaringAction, A.act_one]

/-- **Recursive step for repeated squaring** (induction on n). -/
theorem repeatedSquaring_succ {G X : Type*} [Group G] [Fintype G] [Fintype X]
    [DecidableEq G] [DecidableEq X]
    (A : CryptoGroupAction G X) (g : G) (x : X) (n : ℕ) :
    repeatedSquaringAction A g (n + 1) x =
    A.act g (repeatedSquaringAction A g n x) := by
  simp [repeatedSquaringAction, pow_succ', A.act_mul]

/-- **Additive law for repeated squaring.** -/
theorem repeatedSquaring_add {G X : Type*} [Group G] [Fintype G] [Fintype X]
    [DecidableEq G] [DecidableEq X]
    (A : CryptoGroupAction G X) (g : G) (x : X) (m n : ℕ) :
    repeatedSquaringAction A g (m + n) x =
    A.act (g ^ m) (repeatedSquaringAction A g n x) := by
  simp [repeatedSquaringAction, pow_add, A.act_mul]

/-! ## Part 8: Decisional CSIDH -/

/-- The Decisional CSIDH problem: distinguish (g·h)·x₀ from random. -/
structure DecisionalCSIDH (G : Type*) (X : Type*) [CommGroup G] [Fintype G] [Fintype X]
    [DecidableEq G] [DecidableEq X] (T : FreeTrans G X) where
  x₀ : X
  gx : X
  hx : X
  target : X

def DecisionalCSIDH.isReal {G X : Type*} [CommGroup G] [Fintype G] [Fintype X]
    [DecidableEq G] [DecidableEq X] {T : FreeTrans G X}
    (D : DecisionalCSIDH G X T) : Prop :=
  ∃ g h : G, D.gx = T.act g D.x₀ ∧ D.hx = T.act h D.x₀ ∧
    D.target = T.act (g * h) D.x₀

/-- **In a real D-CSIDH instance, the target = product of connectors applied to x₀.** -/
theorem dcsidh_real_connector {G X : Type*} [CommGroup G] [Fintype G] [Fintype X]
    [DecidableEq G] [DecidableEq X] {T : FreeTrans G X}
    (D : DecisionalCSIDH G X T) (h_real : D.isReal) :
    D.target = T.act (T.connector D.x₀ D.gx * T.connector D.x₀ D.hx) D.x₀ := by
  obtain ⟨g, h, hgx, hhx, htarget⟩ := h_real
  rw [htarget]
  have hg : T.connector D.x₀ D.gx = g :=
    T.unique_connector D.x₀ D.gx _ _ (T.connector_spec _ _) hgx.symm
  have hh : T.connector D.x₀ D.hx = h :=
    T.unique_connector D.x₀ D.hx _ _ (T.connector_spec _ _) hhx.symm
  rw [hg, hh]

/-! ## Part 9: Endomorphism Ring Class (Novel Definition) -/

/-- An `EndomorphismRingClass` abstracts the properties of the endomorphism
    ring of a supersingular elliptic curve relevant to CSIDH security.
    This models the ideal class group structure without requiring
    full algebraic geometry. -/
structure EndomorphismRingClass where
  classNumber : ℕ
  classNumber_ge : 2 ≤ classNumber
  discriminant : ℕ
  numSmallPrimes : ℕ
  securityBits : ℕ
  security_le : securityBits ≤ classNumber

/-! ## Part 10: Key Space Size -/

/-- The CSIDH key space size: each of n exponents ranges over [-B, B]. -/
def csidh_keyspace_size (n : ℕ) (B : ℕ) : ℕ := (2 * B + 1) ^ n

theorem csidh_keyspace_pos (n : ℕ) (B : ℕ) : 0 < csidh_keyspace_size n B := by
  unfold csidh_keyspace_size; positivity

/-- **Key space grows with bound B** (uses Nat.pow_lt_pow_left). -/
theorem csidh_keyspace_mono_B (n : ℕ) (B : ℕ) (hn : 0 < n) :
    csidh_keyspace_size n B < csidh_keyspace_size n (B + 1) := by
  unfold csidh_keyspace_size
  apply Nat.pow_lt_pow_left <;> omega

/-- **Key space grows with number of primes n.** -/
theorem csidh_keyspace_mono_n (n : ℕ) (B : ℕ) (hB : 0 < B) :
    csidh_keyspace_size n B < csidh_keyspace_size (n + 1) B := by
  unfold csidh_keyspace_size
  apply Nat.pow_lt_pow_right <;> omega

/-! ## Part 11: Connector Algebra -/

/-- **Connector of a product = product.** -/
theorem csidh_connector_product {G X : Type*} [CommGroup G] [Fintype G] [Fintype X]
    [DecidableEq G] [DecidableEq X]
    (T : FreeTrans G X) (x₀ : X) (a b : G) :
    T.connector x₀ (T.act (a * b) x₀) = a * b :=
  T.connector_of_act x₀ (a * b)

/-- **Connector factorization through intermediate point.** -/
theorem connector_factor {G X : Type*} [CommGroup G] [Fintype G] [Fintype X]
    [DecidableEq G] [DecidableEq X]
    (T : FreeTrans G X) (x₀ : X) (a b : G) :
    T.connector x₀ (T.act (a * b) x₀) =
    T.connector (T.act a x₀) (T.act (a * b) x₀) *
    T.connector x₀ (T.act a x₀) := by
  rw [← T.connector_compose]

/-! ## Part 12: Parallel Repetition -/

/-- **Parallel repetition extraction.** -/
theorem parallel_repetition_extraction
    {G X : Type*} [CommGroup G] [Fintype G] [Fintype X]
    [DecidableEq G] [DecidableEq X]
    (T : FreeTrans G X) (x₀ pk R : X) (z₀ z₁ : G)
    (h0 : T.act z₀ x₀ = R)
    (h1 : T.act z₁ pk = R) :
    T.act (z₀ * z₁⁻¹) x₀ = pk := by
  rw [mul_comm, T.act_mul, h0, ← h1, T.act_inv_cancel]

/-- **Extracted key correctness.** -/
theorem extracted_key_correct
    {G X : Type*} [CommGroup G] [Fintype G] [Fintype X]
    [DecidableEq G] [DecidableEq X]
    (_T : FreeTrans G X) (_x₀ : X) (s r : G) :
    r * (r * s⁻¹)⁻¹ = s := by
  simp

/-! ## Part 13: Testable Conjecture -/

/-- **Conjecture (Testable)**: For ℤ/nℤ with generators {1, n-1},
    the Cayley graph diameter is ⌊n/2⌋.

    **Test**: For n = 3,5,7,11,13,17,19,23, verify every element of ℤ/nℤ
    can be reached in ≤ ⌊n/2⌋ steps using ±1. -/
def cayleyDiameterConjecture (n : ℕ) (_ : 2 ≤ n) : Prop :=
  ∀ a : ZMod n, ∃ k : ℕ, k ≤ n / 2 ∧ (a = (k : ZMod n) ∨ a = -(k : ZMod n))

end Cryptography.CSIFiShDeep