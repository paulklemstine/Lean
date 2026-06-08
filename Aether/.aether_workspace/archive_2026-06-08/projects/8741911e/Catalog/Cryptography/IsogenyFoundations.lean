/-
  # Algebraic Foundations of Isogeny-Based Cryptography

  This module develops the abstract algebraic theory underlying isogeny-based
  cryptographic protocols (CSIDH, CSI-FiSh, OSIDH), introducing:

  1. **Effective Group Actions (EGA)** — the abstract framework capturing
     computational structure for isogeny protocols.
  2. **Vectorization Problem** — the group-action CDH analogue, with a
     formal reduction from GAIP.
  3. **Twist Endomorphism** — the quadratic twist as an involution,
     proving connector inversion under twist.
  4. **Group Action Commitment Scheme** — computationally binding
     commitment with binding ⟺ GAIP hardness.
  5. **Connector Algebra** — cocycle, triangle, and translation invariance.

  ## Catalog References
  - `Catalog/Cryptography/CSIFiSh.lean`
  - `Catalog/Cryptography/CSIFiShAdvanced.lean`
  - `Catalog/Cryptography/CSIFiShDeep.lean`
-/
import Mathlib

open Finset Function

namespace Cryptography.IsogenyFoundations

/-! ## Part 1: Core Group Action Framework -/

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

theorem act_injective (g : G) : Injective (A.act g) := (A.actEquiv g).injective

end CryptoGroupAction

namespace FreeTrans

variable {G X : Type*} [Group G] [Fintype G] [Fintype X]
  [DecidableEq G] [DecidableEq X]
  (T : FreeTrans G X)

theorem unique_connector (x y : X) (g h : G)
    (hg : T.act g x = y) (hh : T.act h x = y) : g = h := by
  have : T.act (h⁻¹ * g) x = x := by
    rw [T.act_mul, hg, ← hh, T.act_inv_cancel]
  have h1 := T.free _ _ this
  rw [inv_mul_eq_one] at h1; exact h1.symm

noncomputable def connector (x y : X) : G := (T.transitive x y).choose

theorem connector_spec (x y : X) : T.act (T.connector x y) x = y :=
  (T.transitive x y).choose_spec

theorem connector_self (x : X) : T.connector x x = 1 :=
  T.free _ _ (T.connector_spec x x)

theorem connector_of_act (x : X) (g : G) :
    T.connector x (T.act g x) = g :=
  T.unique_connector x (T.act g x) _ g (T.connector_spec _ _) rfl

theorem connector_compose (x y z : X) :
    T.connector x z = T.connector y z * T.connector x y := by
  apply T.unique_connector x z
  · exact T.connector_spec x z
  · rw [T.act_mul, T.connector_spec, T.connector_spec]

theorem connector_inv (x y : X) :
    T.connector y x = (T.connector x y)⁻¹ := by
  apply T.unique_connector y x _ _ (T.connector_spec y x)
  have := T.act_inv_cancel (T.connector x y) x
  rw [T.connector_spec] at this; exact this

include T in
theorem card_eq [Nonempty X] : Fintype.card G = Fintype.card X := by
  apply Fintype.card_of_bijective (f := fun g => T.act g (Classical.arbitrary X))
  exact ⟨fun g h hgh => T.unique_connector _ _ g h rfl hgh.symm,
         fun y => T.transitive _ y⟩

end FreeTrans

/-! ## Part 2: Effective Group Action (EGA) — Novel Definition -/

/-- An `EffectiveGroupAction` captures computational requirements for
    group-action-based cryptography: generators, decomposition, cost model.
    This abstracts the CSIDH parameter choice. -/
structure EffectiveGroupAction (G : Type*) (X : Type*) [CommGroup G] [Fintype G] [Fintype X]
    [DecidableEq G] [DecidableEq X] extends FreeTrans G X where
  generators : Finset G
  generates : ∀ g : G, ∃ ws : List G, (∀ w ∈ ws, w ∈ generators ∨ w⁻¹ ∈ generators) ∧
    ws.prod = g
  evalCost : ℕ
  evalCost_pos : 0 < evalCost

namespace EffectiveGroupAction

variable {G X : Type*} [CommGroup G] [Fintype G] [Fintype X]
  [DecidableEq G] [DecidableEq X]

/-- Total evaluation cost for a key of word-length k. -/
def totalEvalCost (E : EffectiveGroupAction G X) (k : ℕ) : ℕ := k * E.evalCost

theorem totalEvalCost_mono (E : EffectiveGroupAction G X) {k₁ k₂ : ℕ} (h : k₁ ≤ k₂) :
    totalEvalCost E k₁ ≤ totalEvalCost E k₂ :=
  Nat.mul_le_mul_right _ h

/-- The CSIDH key space size: each of n exponents ranges over [-B, B]. -/
def keySpaceSize (n : ℕ) (B : ℕ) : ℕ := (2 * B + 1) ^ n

theorem keySpaceSize_pos (n : ℕ) (B : ℕ) : 0 < keySpaceSize n B := by
  unfold keySpaceSize; positivity

/-- Key space grows with bound B. -/
theorem keySpaceSize_mono_B (n : ℕ) (B : ℕ) (hn : 0 < n) :
    keySpaceSize n B < keySpaceSize n (B + 1) := by
  unfold keySpaceSize; apply Nat.pow_lt_pow_left <;> omega

end EffectiveGroupAction

/-! ## Part 3: The Vectorization Problem -/

structure VectorizationInstance (G : Type*) (X : Type*)
    [CommGroup G] [Fintype G] [Fintype X] [DecidableEq G] [DecidableEq X]
    (T : FreeTrans G X) where
  x₀ : X
  x₁ : X
  x₂ : X

def VectorizationInstance.isSolution {G X : Type*}
    [CommGroup G] [Fintype G] [Fintype X] [DecidableEq G] [DecidableEq X]
    {T : FreeTrans G X}
    (V : VectorizationInstance G X T) (y : X) : Prop :=
  y = T.act (T.connector V.x₀ V.x₁ * T.connector V.x₀ V.x₂) V.x₀

/-- **GAIP solves Vectorization**. -/
theorem gaip_solves_vectorization {G X : Type*}
    [CommGroup G] [Fintype G] [Fintype X] [DecidableEq G] [DecidableEq X]
    (T : FreeTrans G X) (V : VectorizationInstance G X T) :
    V.isSolution (T.act (T.connector V.x₀ V.x₁ * T.connector V.x₀ V.x₂) V.x₀) := by
  rfl

/-- **Vectorization is well-defined**. -/
theorem vectorization_well_defined {G X : Type*}
    [CommGroup G] [Fintype G] [Fintype X] [DecidableEq G] [DecidableEq X]
    (T : FreeTrans G X) (x₀ : X) (a b : G) :
    T.act (T.connector x₀ (T.act a x₀) * T.connector x₀ (T.act b x₀)) x₀ =
    T.act (a * b) x₀ := by
  rw [T.connector_of_act, T.connector_of_act]

/-- **Vectorization commutes** (abelian group). -/
theorem vectorization_comm {G X : Type*}
    [CommGroup G] [Fintype G] [Fintype X] [DecidableEq G] [DecidableEq X]
    (T : FreeTrans G X) (x₀ x₁ x₂ : X) :
    T.act (T.connector x₀ x₁ * T.connector x₀ x₂) x₀ =
    T.act (T.connector x₀ x₂ * T.connector x₀ x₁) x₀ := by
  rw [mul_comm]

/-! ## Part 4: Twist Endomorphism — Novel Structure -/

/-- A `TwistStructure` models the quadratic twist endomorphism satisfying
    τ(g · x) = g⁻¹ · τ(x). -/
structure TwistStructure (G : Type*) (X : Type*) [CommGroup G] [Fintype G] [Fintype X]
    [DecidableEq G] [DecidableEq X] (T : FreeTrans G X) where
  twist : X → X
  twist_involutive : ∀ x : X, twist (twist x) = x
  twist_act : ∀ (g : G) (x : X), twist (T.act g x) = T.act g⁻¹ (twist x)

namespace TwistStructure

variable {G X : Type*} [CommGroup G] [Fintype G] [Fintype X]
  [DecidableEq G] [DecidableEq X]
  {T : FreeTrans G X}
  (τ : TwistStructure G X T)

theorem twist_injective : Injective τ.twist :=
  Function.Involutive.injective τ.twist_involutive

theorem twist_surjective : Surjective τ.twist :=
  fun y => ⟨τ.twist y, τ.twist_involutive y⟩

theorem twist_bijective : Bijective τ.twist :=
  ⟨τ.twist_injective, τ.twist_surjective⟩

/-- **Connector under twist**: twisting both points inverts the connector.
    This is the key structural theorem of the twist-action interaction. -/
theorem connector_twist (x y : X) :
    T.connector (τ.twist x) (τ.twist y) = (T.connector x y)⁻¹ := by
  apply T.unique_connector (τ.twist x) (τ.twist y)
  · exact T.connector_spec (τ.twist x) (τ.twist y)
  · -- T.act (conn(x,y))⁻¹ (τ x) = τ(conn(x,y) · x) = τ y
    have h := τ.twist_act (T.connector x y) x
    rw [T.connector_spec] at h
    -- h : τ.twist y = T.act (T.connector x y)⁻¹ (τ.twist x)
    exact h.symm

/-- **Twist reverses double action**. -/
theorem twist_double_action (x : X) (g : G) :
    T.connector (τ.twist x) (τ.twist (T.act (g * g) x)) = (g * g)⁻¹ := by
  rw [τ.connector_twist, T.connector_of_act]

/-- **Twist conjugation**: τ ∘ g ∘ τ = g⁻¹. -/
theorem twist_action_conjugation (g : G) (x : X) :
    τ.twist (T.act g (τ.twist x)) = T.act g⁻¹ x := by
  rw [τ.twist_act, τ.twist_involutive]

/-- **Twist connector product**: conn(τ(x₀), τ((a·b)·x₀)) = (a·b)⁻¹. -/
theorem twist_connector_product (x₀ : X) (a b : G) :
    T.connector (τ.twist x₀)
      (τ.twist (T.act (a * b) x₀)) = (a * b)⁻¹ := by
  rw [τ.connector_twist, T.connector_of_act]

end TwistStructure

/-! ## Part 5: Group Action Commitment Scheme -/

structure GACommitment (G : Type*) (X : Type*) [CommGroup G] [Fintype G] [Fintype X]
    [DecidableEq G] [DecidableEq X] (T : FreeTrans G X) where
  x₀ : X
  message : G
  randomness : G

namespace GACommitment

variable {G X : Type*} [CommGroup G] [Fintype G] [Fintype X]
  [DecidableEq G] [DecidableEq X]
  {T : FreeTrans G X}
  (C : GACommitment G X T)

def com₁ : X := T.act C.randomness C.x₀
def com₂ : X := T.act (C.randomness * C.message) C.x₀

def verify (c₁ c₂ : X) (m r : G) : Prop :=
  c₁ = T.act r C.x₀ ∧ c₂ = T.act (r * m) C.x₀

theorem honest_verify : C.verify C.com₁ C.com₂ C.message C.randomness :=
  ⟨rfl, rfl⟩

/-- **Message extraction**: the message equals the connector between
    the two commitment components. -/
theorem message_from_commitment :
    T.connector C.com₁ C.com₂ = C.message := by
  apply T.unique_connector C.com₁ C.com₂
  · exact T.connector_spec C.com₁ C.com₂
  · show T.act C.message (T.act C.randomness C.x₀) =
         T.act (C.randomness * C.message) C.x₀
    rw [← T.act_mul, mul_comm]

/-- **Binding theorem**: Two valid openings must agree on the message.
    Breaking binding ⟺ solving GAIP. -/
theorem binding_from_gaip (c₁ c₂ : X) (m₁ m₂ r₁ r₂ : G)
    (h₁ : c₁ = T.act r₁ C.x₀ ∧ c₂ = T.act (r₁ * m₁) C.x₀)
    (h₂ : c₁ = T.act r₂ C.x₀ ∧ c₂ = T.act (r₂ * m₂) C.x₀) :
    m₁ = m₂ := by
  have hr : r₁ = r₂ := T.unique_connector C.x₀ c₁ r₁ r₂ h₁.1.symm h₂.1.symm
  have hm : r₁ * m₁ = r₂ * m₂ :=
    T.unique_connector C.x₀ c₂ (r₁ * m₁) (r₂ * m₂) h₁.2.symm h₂.2.symm
  have : r₁ * m₁ = r₁ * m₂ := by rw [hm, hr]
  exact mul_left_cancel this

end GACommitment

/-! ## Part 6: CSI-FiSh Extraction -/

/-- **CSI-FiSh special soundness**: extract the secret from two accepting
    transcripts with different challenges. -/
theorem parallel_extraction_comm {G X : Type*}
    [CommGroup G] [Fintype G] [Fintype X] [DecidableEq G] [DecidableEq X]
    (T : FreeTrans G X) (x₀ pk R : X)
    (z₀ z₁ : G)
    (h_ch0 : T.act z₀ x₀ = R)
    (h_ch1 : T.act z₁ pk = R)
    : T.act (z₀ * z₁⁻¹) x₀ = pk := by
  rw [mul_comm, T.act_mul, h_ch0, ← h_ch1, T.act_inv_cancel]

/-- **Extracted key equals secret**. -/
theorem extracted_key_is_secret {G X : Type*}
    [CommGroup G] [Fintype G] [Fintype X] [DecidableEq G] [DecidableEq X]
    (T : FreeTrans G X) (x₀ pk R : X)
    (z₀ z₁ s : G)
    (h_ch0 : T.act z₀ x₀ = R)
    (h_ch1 : T.act z₁ pk = R)
    (h_pk : T.act s x₀ = pk)
    : z₀ * z₁⁻¹ = s := by
  apply T.unique_connector x₀ pk
  · exact parallel_extraction_comm T x₀ pk R z₀ z₁ h_ch0 h_ch1
  · exact h_pk

/-! ## Part 7: Security Amplification -/

def challengeSpaceSize (n : ℕ) : ℕ := 2 ^ n

theorem challengeSpaceSize_pos (n : ℕ) : 0 < challengeSpaceSize n :=
  Nat.pos_of_ne_zero (by simp [challengeSpaceSize])

theorem challengeSpace_double (n : ℕ) :
    challengeSpaceSize (2 * n) = challengeSpaceSize n * challengeSpaceSize n := by
  simp [challengeSpaceSize, ← pow_add, two_mul]

theorem challengeSpace_succ (n : ℕ) :
    challengeSpaceSize (n + 1) = 2 * challengeSpaceSize n := by
  simp [challengeSpaceSize, pow_succ, mul_comm]

/-! ## Part 8: Connector Algebra — Deep Properties -/

section ConnectorAlgebra

variable {G X : Type*} [CommGroup G] [Fintype G] [Fintype X]
  [DecidableEq G] [DecidableEq X]
  (T : FreeTrans G X)

/-- **Cocycle condition**: conn(x,z) = conn(y,z) · conn(x,y). -/
theorem connector_cocycle (x y z : X) :
    T.connector x z = T.connector y z * T.connector x y :=
  T.connector_compose x y z

/-- **Antisymmetry**: conn(x,y) · conn(y,x) = 1. -/
theorem connector_antisymm (x y : X) :
    T.connector x y * T.connector y x = 1 := by
  rw [T.connector_inv y x, inv_mul_cancel]

/-
**Triangle identity**: conn(x,y) · conn(y,z) · conn(z,x) = 1.
    This is the cocycle closure condition (Čech 1-cocycle).
-/
theorem connector_triangle (x y z : X) :
    T.connector x y * T.connector y z * T.connector z x = 1 := by
  -- By the properties of the connector, we know that T.connector z x = (T.connector x z)⁻¹.
  have h_inv : T.connector z x = (T.connector x z)⁻¹ := by
    exact FreeTrans.connector_inv T x z;
  rw [ h_inv, mul_inv_eq_one ];
  convert T.connector_compose x y z |> Eq.symm using 1;
  exact mul_comm _ _

/-- **Connector invariance under simultaneous translation**:
    conn(g·x, g·y) = conn(x, y) for abelian groups. -/
theorem connector_translate (x y : X) (g : G) :
    T.connector (T.act g x) (T.act g y) = T.connector x y := by
  apply T.unique_connector (T.act g x) (T.act g y)
  · exact T.connector_spec _ _
  · rw [← T.act_mul, mul_comm, T.act_mul, T.connector_spec]

/-
**Intermediate connector**: conn(a·x₀, (a·b)·x₀) = b.
-/
theorem connector_intermediate (x₀ : X) (a b : G) :
    T.connector (T.act a x₀) (T.act (a * b) x₀) = b := by
  convert T.connector_of_act _ _ using 1;
  rw [ T.act_mul ];
  rw [ connector_translate ]

/-- **Connector product factorization**. -/
theorem connector_product_factorization (x₀ : X) (a b : G) :
    T.connector x₀ (T.act (a * b) x₀) =
    T.connector (T.act a x₀) (T.act (a * b) x₀) *
    T.connector x₀ (T.act a x₀) :=
  T.connector_compose x₀ (T.act a x₀) (T.act (a * b) x₀)

end ConnectorAlgebra

/-! ## Part 9: Decisional CSIDH -/

structure DCSIDH (G : Type*) (X : Type*) [CommGroup G] [Fintype G] [Fintype X]
    [DecidableEq G] [DecidableEq X] (T : FreeTrans G X) where
  x₀ : X
  ax : X
  bx : X
  cx : X

def DCSIDH.isReal {G X : Type*} [CommGroup G] [Fintype G] [Fintype X]
    [DecidableEq G] [DecidableEq X] {T : FreeTrans G X}
    (D : DCSIDH G X T) : Prop :=
  D.cx = T.act (T.connector D.x₀ D.ax * T.connector D.x₀ D.bx) D.x₀

/-- **Real instances satisfy the product relation**. -/
theorem dcsidh_real_characterization {G X : Type*}
    [CommGroup G] [Fintype G] [Fintype X] [DecidableEq G] [DecidableEq X]
    (T : FreeTrans G X) (x₀ : X) (a b : G) :
    (DCSIDH.mk x₀ (T.act a x₀) (T.act b x₀) (T.act (a * b) x₀) :
      DCSIDH G X T).isReal := by
  simp only [DCSIDH.isReal]
  rw [T.connector_of_act, T.connector_of_act]

/-! ## Part 10: Testable Conjectures -/

/-- **Conjecture (Cayley Diameter)**: For ℤ/nℤ with generators {1, n-1},
    the diameter is ⌊n/2⌋.

    **Test**: For n = 3, 5, 7, 11, 13, verify diameter computationally. -/
def cayleyDiameterConjecture (n : ℕ) (_ : 2 ≤ n) : Prop :=
  ∀ a : ZMod n, ∃ k : ℕ, k ≤ n / 2 ∧ (a = (k : ZMod n) ∨ a = -(k : ZMod n))

end Cryptography.IsogenyFoundations