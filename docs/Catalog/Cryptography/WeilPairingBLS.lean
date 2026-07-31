import Mathlib.AlgebraicGeometry.EllipticCurve.Affine.Point
import Mathlib.Data.Finset.Card

/-!
# Weil pairings and the algebraic security core of BLS signatures

This development uses Mathlib's nonsingular affine points of a `WeierstrassCurve`.
A `WeilPairing` is the standard algebraic interface on the `n`-torsion subgroup:
bilinearity, alternation, image torsion, and nondegeneracy.  The BLS result is the
algebraic EUF-CMA-to-CDH reduction under the explicit fresh-message random-oracle
programming event.  Aggregate correctness and constant group-element size are also proved.
-/

open scoped BigOperators
open Finset

namespace Cryptography.WeilBLS

universe u v

variable {F : Type u} [Field F] [DecidableEq F]

/-- The existing Mathlib elliptic-curve point group for an affine Weierstrass curve. -/
abbrev CurvePoint (W : WeierstrassCurve F) := W.toAffine.Point

/-- The `n`-torsion subgroup of the Mathlib elliptic-curve point group. -/
def torsionPoints (W : WeierstrassCurve F) (n : ℕ) : AddSubgroup (CurvePoint W) where
  carrier := {P | n • P = 0}
  zero_mem' := nsmul_zero n
  add_mem' := by
    intro P Q hP hQ
    change n • (P + Q) = 0
    rw [nsmul_add, hP, hQ, add_zero]
  neg_mem' := by
    intro P hP
    change n • (-P) = 0
    rw [smul_neg, hP, neg_zero]

/-- A Weil pairing on elliptic-curve `n`-torsion.  `Additive μ` lets the two additive
homomorphisms encode a multiplicative pairing without reintroducing bilinearity axioms. -/
structure WeilPairing (W : WeierstrassCurve F) (n : ℕ) (μ : Type v) [CommGroup μ] where
  hom : torsionPoints W n →+ torsionPoints W n →+ Additive μ
  alternating : ∀ P : torsionPoints W n, hom P P = 0
  image_torsion : ∀ P Q : torsionPoints W n, (Additive.toMul (hom P Q)) ^ n = 1
  nondegenerate_left : ∀ P : torsionPoints W n,
    (∀ Q : torsionPoints W n, hom P Q = 0) → P = 0
  nondegenerate_right : ∀ Q : torsionPoints W n,
    (∀ P : torsionPoints W n, hom P Q = 0) → Q = 0

namespace WeilPairing

variable {W : WeierstrassCurve F} {n : ℕ} {μ : Type v} [CommGroup μ]
    (e : WeilPairing W n μ)

/-- Multiplicative notation for the pairing. -/
def pair (P Q : torsionPoints W n) : μ := Additive.toMul (e.hom P Q)

@[simp] theorem pair_zero_left (Q : torsionPoints W n) : e.pair 0 Q = 1 := by
  change Additive.toMul (e.hom 0 Q) = 1
  simp

@[simp] theorem pair_zero_right (P : torsionPoints W n) : e.pair P 0 = 1 := by
  change Additive.toMul (e.hom P 0) = 1
  simp

/-- Additivity in the first argument. -/
theorem pair_add_left (P Q R : torsionPoints W n) :
    e.pair (P + Q) R = e.pair P R * e.pair Q R := by
  change Additive.toMul (e.hom (P + Q) R) = _
  rw [map_add]
  rfl

/-- Additivity in the second argument. -/
theorem pair_add_right (P Q R : torsionPoints W n) :
    e.pair P (Q + R) = e.pair P Q * e.pair P R := by
  change Additive.toMul (e.hom P (Q + R)) = _
  rw [map_add]
  rfl

/-- Weil-pairing bilinearity in the first argument. -/
theorem bilinear_left (a : ℕ) (P Q : torsionPoints W n) :
    e.pair (a • P) Q = e.pair P Q ^ a := by
  induction a with
  | zero => simp
  | succ a ih =>
      rw [succ_nsmul, e.pair_add_left, ih, pow_succ]

/-- Weil-pairing bilinearity in the second argument. -/
theorem bilinear_right (b : ℕ) (P Q : torsionPoints W n) :
    e.pair P (b • Q) = e.pair P Q ^ b := by
  induction b with
  | zero => simp
  | succ b ih =>
      rw [succ_nsmul, e.pair_add_right, ih, pow_succ]

/-- Full Weil-pairing bilinearity: `e(aP,bQ) = e(P,Q)^(a*b)`. -/
theorem bilinear (a b : ℕ) (P Q : torsionPoints W n) :
    e.pair (a • P) (b • Q) = e.pair P Q ^ (a * b) := by
  rw [e.bilinear_left, e.bilinear_right, ← pow_mul, Nat.mul_comm]

/-- The pairing is alternating. -/
theorem pair_self (P : torsionPoints W n) : e.pair P P = 1 := by
  change Additive.toMul (e.hom P P) = 1
  rw [e.alternating]
  rfl

/-- Alternation and bilinearity imply skew-symmetry. -/
theorem skew_symmetric (P Q : torsionPoints W n) :
    e.pair P Q = (e.pair Q P)⁻¹ := by
  have h := e.pair_self (P + Q)
  rw [e.pair_add_left, e.pair_add_right, e.pair_add_right,
    e.pair_self, e.pair_self, mul_one, one_mul] at h
  exact eq_inv_of_mul_eq_one_left h

end WeilPairing

/-! ## BLS signatures and CDH reduction -/

section BLS

variable {W : WeierstrassCurve F} {n : ℕ} {μ : Type v} [CommGroup μ]

/-- Public BLS parameters over elliptic-curve torsion. -/
structure BLSParams (W : WeierstrassCurve F) (n : ℕ) (μ : Type v) [CommGroup μ] where
  pairing : WeilPairing W n μ
  generator : torsionPoints W n
  pairing_generator_injective : Function.Injective (fun P => pairing.pair P generator)

namespace BLSParams

variable (P : BLSParams W n μ)

/-- Public-key generation from a natural scalar. -/
def publicKey (sk : ℕ) : torsionPoints W n := sk • P.generator

/-- BLS signing in the hash-to-curve abstraction. -/
def sign (_P : BLSParams W n μ) (sk : ℕ) (hashPoint : torsionPoints W n) :
    torsionPoints W n := sk • hashPoint

/-- Pairing-based BLS verification. -/
def verifies (pk hashPoint signature : torsionPoints W n) : Prop :=
  P.pairing.pair signature P.generator = P.pairing.pair hashPoint pk

/-- Correctness of BLS verification follows from Weil bilinearity. -/
theorem verifies_sign (sk : ℕ) (hashPoint : torsionPoints W n) :
    P.verifies (P.publicKey sk) hashPoint (P.sign sk hashPoint) := by
  unfold verifies publicKey sign
  rw [P.pairing.bilinear_left, P.pairing.bilinear_right]

/-- Verification under an honest key accepts exactly the honest signature. -/
theorem verifies_iff_eq_sign (sk : ℕ) (hashPoint signature : torsionPoints W n) :
    P.verifies (P.publicKey sk) hashPoint signature ↔ signature = P.sign sk hashPoint := by
  constructor
  · intro h
    apply P.pairing_generator_injective
    change P.pairing.pair signature P.generator =
      P.pairing.pair (P.sign sk hashPoint) P.generator
    rw [h]
    exact (P.verifies_sign sk hashPoint).symm
  · rintro rfl
    exact P.verifies_sign sk hashPoint

/-- A computational Diffie--Hellman challenge in additive notation. -/
structure CDHChallenge (P : BLSParams W n μ) where
  publicA : torsionPoints W n
  publicB : torsionPoints W n
  secretA : ℕ
  publicA_eq : publicA = P.publicKey secretA

/-- The CDH target. -/
def CDHChallenge.target (C : CDHChallenge P) : torsionPoints W n :=
  C.secretA • C.publicB

/-- The standard BLS reduction's fresh-message oracle-programming event. -/
structure ProgrammedFreshChallenge (P : BLSParams W n μ) (Message : Type*)
    [DecidableEq Message] where
  challenge : CDHChallenge P
  hashToCurve : Message → torsionPoints W n
  targetMessage : Message
  queriedMessages : Finset Message
  fresh : targetMessage ∉ queriedMessages
  programmed : hashToCurve targetMessage = challenge.publicB

/-- **Algebraic EUF-CMA-to-CDH reduction.** Under fresh-message oracle programming,
every valid BLS forgery is the CDH solution. -/
theorem forgery_solves_cdh {Message : Type*} [DecidableEq Message]
    (game : ProgrammedFreshChallenge P Message)
    (forgedSignature : torsionPoints W n)
    (valid : P.verifies game.challenge.publicA
      (game.hashToCurve game.targetMessage) forgedSignature) :
    forgedSignature = game.challenge.target := by
  rw [game.challenge.publicA_eq, game.programmed] at valid
  exact (P.verifies_iff_eq_sign game.challenge.secretA game.challenge.publicB forgedSignature).mp valid

/-- CDH hardness against a specified class of attainable outputs.  This formulation keeps
the computational assumption explicit instead of pretending that it is an algebraic fact. -/
def CDHHardFor (C : CDHChallenge P) (attainable : torsionPoints W n → Prop) : Prop :=
  ¬ attainable C.target

/-- **Existential unforgeability consequence under CDH.** If the forger's attainable
outputs cannot contain the CDH target, then it cannot contain a valid signature for the
fresh, programmed message. -/
theorem no_existential_forgery_of_cdh {Message : Type*} [DecidableEq Message]
    (game : ProgrammedFreshChallenge P Message)
    (attainable : torsionPoints W n → Prop)
    (hard : CDHHardFor P game.challenge attainable) :
    ¬ ∃ forgedSignature, attainable forgedSignature ∧
      P.verifies game.challenge.publicA
        (game.hashToCurve game.targetMessage) forgedSignature := by
  rintro ⟨forgedSignature, hAttainable, hValid⟩
  apply hard
  rw [← P.forgery_solves_cdh game forgedSignature hValid]
  exact hAttainable

/-- Aggregate a finite family of signatures by elliptic-curve addition. -/
def aggregate {ι : Type*} (s : Finset ι) (signature : ι → torsionPoints W n) :
    torsionPoints W n := ∑ i ∈ s, signature i

/-- Pairing an aggregate equals the product of individual pairings. -/
theorem pair_aggregate {ι : Type*} (s : Finset ι)
    (signature : ι → torsionPoints W n) :
    P.pairing.pair (aggregate s signature) P.generator =
      ∏ i ∈ s, P.pairing.pair (signature i) P.generator := by
  classical
  induction s using Finset.induction_on with
  | empty => simp [aggregate]
  | @insert a s ha ih =>
      simp only [aggregate, sum_insert ha, prod_insert ha]
      rw [P.pairing.pair_add_left]
      exact congrArg (fun x => P.pairing.pair (signature a) P.generator * x)
        (by simpa only [aggregate] using ih)

/-- One aggregate group element verifies a finite family of BLS signatures. -/
theorem aggregate_verifies {ι : Type*} (s : Finset ι)
    (sk : ι → ℕ) (hashPoint : ι → torsionPoints W n) :
    P.pairing.pair (aggregate s (fun i => P.sign (sk i) (hashPoint i))) P.generator =
      ∏ i ∈ s, P.pairing.pair (hashPoint i) (P.publicKey (sk i)) := by
  rw [P.pair_aggregate]
  apply Finset.prod_congr rfl
  intro i hi
  exact P.verifies_sign (sk i) (hashPoint i)

/-- Aggregate signatures are short: any finite family is represented by one element of
the original elliptic-curve subgroup, while retaining the full product verification law. -/
theorem aggregate_is_one_group_element {ι : Type*} (s : Finset ι)
    (signature : ι → torsionPoints W n) :
    ∃ σ : torsionPoints W n, σ = aggregate s signature ∧
      P.pairing.pair σ P.generator =
        ∏ i ∈ s, P.pairing.pair (signature i) P.generator := by
  refine ⟨aggregate s signature, rfl, ?_⟩
  exact P.pair_aggregate s signature

end BLSParams
end BLS

end Cryptography.WeilBLS