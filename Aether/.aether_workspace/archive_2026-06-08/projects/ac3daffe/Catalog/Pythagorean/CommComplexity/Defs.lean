import Mathlib

/-!
# Communication Complexity: Definitions for Powerset Verification

This module defines deterministic and randomized one-round communication protocols,
the powerset fingerprint polynomial, and related structures for studying the
deterministic-randomized gap in communication complexity.

## Main Definitions

* `OneRoundDetProtocol` — A deterministic one-round communication protocol
* `OneRoundRandProtocol` — A randomized public-coin one-round communication protocol
* `powersetFingerprintPoly` — The fingerprint polynomial for subset verification
* `CommGapRatio` — Structure capturing the communication gap between protocols

## Mathematical Context

In communication complexity, Alice holds input `x ∈ α` and Bob holds input `y ∈ β`.
They wish to compute some function `f(x, y)`. In a one-round protocol, Alice sends
a single message to Bob, who then outputs the answer.

For the equality function `EQ(x, y) = (x = y)`, there is a fundamental gap between
deterministic and randomized protocols: deterministic protocols require Ω(log |α|) bits,
while randomized protocols achieve O(log log |α|) bits using polynomial fingerprinting.
-/

open Polynomial Finset

/-! ## Protocol Definitions -/

/-- A deterministic one-round communication protocol: Alice sends a message
    (encoded as a list of booleans) depending on her input; Bob decides based on
    his input and Alice's message. -/
structure OneRoundDetProtocol (α β : Type) where
  /-- Alice's message function mapping her input to a binary string -/
  aliceMsg : α → List Bool
  /-- Bob's decision function given his input and Alice's message -/
  bobDecide : β → List Bool → Bool
  /-- Worst-case communication bound (max message length) -/
  commBound : ℕ
  /-- All messages respect the communication bound -/
  hbound : ∀ a, (aliceMsg a).length ≤ commBound

/-- A one-round randomized public-coin communication protocol: Alice sends a message
    depending on her input and shared randomness; Bob decides based on
    his input, the message, and the same randomness. -/
structure OneRoundRandProtocol (α β : Type) where
  /-- The type of shared randomness -/
  R : Type
  /-- Alice's message function -/
  aliceMsg : α → R → List Bool
  /-- Bob's decision function -/
  bobDecide : β → List Bool → R → Bool
  /-- Worst-case communication bound -/
  commBound : ℕ
  /-- All messages respect the bound -/
  hbound : ∀ a r, (aliceMsg a r).length ≤ commBound
  /-- The randomness space is finite -/
  [hR : Fintype R]

attribute [instance] OneRoundRandProtocol.hR

/-- A deterministic protocol is correct for equality if it accepts iff inputs are equal. -/
def OneRoundDetProtocol.isCorrectEq {α : Type}
    (proto : OneRoundDetProtocol α α) : Prop :=
  ∀ x y : α, (proto.bobDecide y (proto.aliceMsg x) = true ↔ x = y)

/-- The communication gap ratio between deterministic lower bound and
    randomized upper bound for a communication problem. -/
structure CommGapRatio where
  /-- Deterministic communication lower bound -/
  detLower : ℕ
  /-- Randomized communication upper bound -/
  randUpper : ℕ
  /-- The randomized bound is positive -/
  hrand_pos : randUpper > 0

/-! ## Fingerprint Polynomial -/

/-- The fingerprint polynomial for a subset S ⊆ Fin n: this is the polynomial
    P_S(X) = Σ_{i ∈ S} X^i. When evaluated at a random point r in a finite field,
    it serves as a probabilistic fingerprint of S. -/
noncomputable def powersetFingerprintPoly (n : ℕ) {R : Type*} [CommSemiring R]
    (S : Finset (Fin n)) : Polynomial R :=
  S.sum fun i => Polynomial.X ^ (i : ℕ)

/-- The evaluation of the fingerprint polynomial at a point. -/
noncomputable def powersetFingerprint (n : ℕ) {R : Type*} [CommSemiring R]
    (S : Finset (Fin n)) (r : R) : R :=
  Polynomial.eval r (powersetFingerprintPoly n S)

/-- The difference polynomial Δ_{S,T}(X) = P_S(X) - P_T(X), whose roots correspond
    to fingerprint collisions. -/
noncomputable def fingerprintDiffPoly (n : ℕ) {R : Type*} [CommRing R]
    (S T : Finset (Fin n)) : Polynomial R :=
  powersetFingerprintPoly n S - powersetFingerprintPoly n T