import Cryptography.PairingCryptanalysis
import Cryptography.BLSCorrected

/-!
# Computational evidence for the Weil-pairing development

Exhaustive finite verifications of the statements proved abstractly in
`Cryptography.WeilPairingDeterminant`, `Cryptography.WeilPairingStructure` and
`Cryptography.BLSAggregate`.  Each is a closed `decide` computation over a small
determinant model, so it is checked by the kernel and not merely evaluated.

The corresponding numerical tables are recorded in `ComputationalEvidence.md`.
-/

namespace Cryptography.WeilBLS

/-- Exhaustive nondegeneracy check on `(ZMod 5)²` (625 pairs): every nonzero vector is
paired nontrivially with some vector.  Instance of `detPairing_nondegenerate_left`. -/
theorem detForm_nondegenerate_zmod_five :
    ∀ v : ZMod 5 × ZMod 5, v ≠ 0 → ∃ w : ZMod 5 × ZMod 5, detForm 5 v w ≠ 0 := by
  decide

/-- Exhaustive skew-symmetry check on `(ZMod 6)²`, including the composite modulus case
where `ZMod 6` is not a field. -/
theorem detForm_skew_zmod_six :
    ∀ v w : ZMod 6 × ZMod 6, detForm 6 v w = - detForm 6 w v := by
  decide

/-- Exhaustive check of the cyclic-degeneracy phenomenon behind
`WeilPairing.torsion_trivial_of_cyclic`: on multiples of a single vector the pairing is
identically trivial, over `(ZMod 5)²`. -/
theorem detForm_cyclic_degenerate_zmod_five :
    ∀ (a b : Fin 5) (v : ZMod 5 × ZMod 5),
      detForm 5 ((a : ℕ) • v) ((b : ℕ) • v) = 0 := by
  decide

/-- Exhaustive check of the endomorphism determinant law `detForm_linMap` over
`(ZMod 3)²`, ranging over all 81 endomorphisms and all 81 pairs of vectors. -/
theorem detForm_linMap_zmod_three :
    ∀ (a b c d : ZMod 3) (v w : ZMod 3 × ZMod 3),
      detForm 3 (linMap 3 a b c d v) (linMap 3 a b c d w)
        = (a * d - b * c) * detForm 3 v w := by
  decide

/-- Exhaustive check of the rogue-key attack identity (`BLSParams.rogue_key_attack`) in
the additive determinant model with generator `G = (1,0)` over `(ZMod 5)²`: the forged
aggregate `y • H`, which uses no secret key, always satisfies the two-signer
verification equation. -/
theorem rogue_key_identity_zmod_five :
    ∀ (y : Fin 5) (H pk : ZMod 5 × ZMod 5),
      detForm 5 ((y : ℕ) • H) ((1 : ZMod 5), (0 : ZMod 5))
        = detForm 5 H pk
          + detForm 5 H ((y : ℕ) • ((1 : ZMod 5), (0 : ZMod 5)) - pk) := by
  decide

/-! ## An end-to-end BLS run in the corrected model over `ZMod 7` -/

/-- The concrete corrected BLS setting over `(ZMod 7)²`. -/
noncomputable abbrev blsSeven : BLSSetting (ZMod 7 × ZMod 7) (Multiplicative (ZMod 7)) 7 :=
  detBLSSetting 7

/-- Exhaustive correctness check: for all 49 key/message-hash pairs the honest signature
is accepted by the pairing verification equation. -/
theorem bls_correct_zmod_seven : ∀ sk h : Fin 7,
    blsSeven.pairing.pair (blsSeven.sign sk h) blsSeven.gen₂
      = blsSeven.pairing.pair (blsSeven.hashPoint h) (blsSeven.publicKey sk) := by
  decide

/-- Exhaustive soundness check (343 cases): among the seven candidate signatures
`s • gen₁`, exactly the honest exponent `s ≡ sk·h (mod 7)` is accepted.  This is the
numerical form of `BLSSetting.verifies_iff_modEq`, i.e. of the signature-uniqueness
property that the catalog's `BLSParams` could not achieve. -/
theorem bls_unique_signature_zmod_seven : ∀ sk h s : Fin 7,
    (blsSeven.pairing.pair ((s : ℕ) • blsSeven.gen₁) blsSeven.gen₂
        = blsSeven.pairing.pair (blsSeven.hashPoint h) (blsSeven.publicKey sk))
      ↔ (s : ℕ) = ((sk : ℕ) * (h : ℕ)) % 7 := by
  decide

end Cryptography.WeilBLS