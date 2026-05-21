/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Schnorr–Fiat–Shamir: Algebraic Witness Extraction

This file proves the correctness and uniqueness of witness extraction from
forked Schnorr transcripts.

## Main results

* `schnorr_extract_eq_witness` — If two accepting transcripts share a commitment
  and have distinct challenges, the extracted value equals the secret witness `x`.
* `schnorr_extract_recovers_pubkey` — The extracted witness recovers the public key:
  `(schnorrExtract ft) * gen = pub`.
* `schnorr_witness_unique` — Under a nonzero generator, the witness is uniquely
  determined by the public key.

## Proof strategy

The algebraic extraction works by subtracting the two verification equations:
  z₁ * gen = a + c₁ * pub
  z₂ * gen = a + c₂ * pub
to get (z₁ - z₂) * gen = (c₁ - c₂) * pub = (c₁ - c₂) * x * gen.
Since gen ≠ 0 and ZMod q is a field, we can cancel gen and invert (c₁ - c₂).
-/
import Cryptography.SchnorrForkingLemma.Defs

open Finset BigOperators

variable {q : ℕ} [Fact q.Prime]

/-
Key algebraic lemma: subtracting two verification equations yields
    a relation between the response difference and the challenge difference.
-/
theorem schnorr_verification_subtract
    (gen pub : ZMod q)
    (ft : ForkedTranscript q)
    (hacc₁ : schnorrVerifies gen pub ⟨ft.a, ft.c₁, ft.z₁⟩)
    (hacc₂ : schnorrVerifies gen pub ⟨ft.a, ft.c₂, ft.z₂⟩) :
    (ft.z₁ - ft.z₂) * gen = (ft.c₁ - ft.c₂) * pub := by
  convert congr_arg₂ ( · - · ) hacc₁ hacc₂ using 1 ; ring;
  ring!

/-
If `pub = x * gen` and two transcripts verify, then the extracted witness
    equals the secret `x`. This is the core algebraic theorem of Schnorr extraction.
-/
theorem schnorr_extract_eq_witness
    (gen : ZMod q) (hgen : gen ≠ 0)
    (x : ZMod q)
    (pub : ZMod q) (hpub : pub = x * gen)
    (ft : ForkedTranscript q)
    (hacc₁ : schnorrVerifies gen pub ⟨ft.a, ft.c₁, ft.z₁⟩)
    (hacc₂ : schnorrVerifies gen pub ⟨ft.a, ft.c₂, ft.z₂⟩) :
    schnorrExtract ft = x := by
  -- Use schnorrVerifies to get (z₁ - z₂) * gen = (c₁ - c₂) * pub. Substitute pub = x * gen to get (z₁ - z₂) * gen = (c₁ - c₂) * x * gen.
  have h_eq : (ft.z₁ - ft.z₂) * gen = (ft.c₁ - ft.c₂) * x * gen := by
    convert schnorr_verification_subtract gen pub ft hacc₁ hacc₂ using 1 ; ring;
    rw [ hpub, mul_assoc, mul_assoc ];
  -- Use schnorr_witness_unique (gen ≠ 0) to cancel gen: z₁ - z₂ = (c₁ - c₂) * x.
  have h_cancel : ft.z₁ - ft.z₂ = (ft.c₁ - ft.c₂) * x := by
    exact mul_right_cancel₀ hgen h_eq;
  convert congr_arg ( fun y => y * ( ft.c₁ - ft.c₂ ) ⁻¹ ) h_cancel using 1;
  rw [ mul_right_comm, mul_inv_cancel₀ ( sub_ne_zero_of_ne ft.hneq ), one_mul ]

/-
The extracted witness recovers the public key via multiplication with the generator.
-/
theorem schnorr_extract_recovers_pubkey
    (gen : ZMod q) (hgen : gen ≠ 0)
    (x : ZMod q)
    (pub : ZMod q) (hpub : pub = x * gen)
    (ft : ForkedTranscript q)
    (hacc₁ : schnorrVerifies gen pub ⟨ft.a, ft.c₁, ft.z₁⟩)
    (hacc₂ : schnorrVerifies gen pub ⟨ft.a, ft.c₂, ft.z₂⟩) :
    schnorrExtract ft * gen = pub := by
  exact hpub ▸ by rw [ schnorr_extract_eq_witness gen hgen x pub hpub ft hacc₁ hacc₂ ] ;

/-
Uniqueness: in ZMod q with a nonzero generator, the discrete log is unique.
    If `x * gen = y * gen` and `gen ≠ 0`, then `x = y`.
-/
theorem schnorr_witness_unique
    (gen : ZMod q) (hgen : gen ≠ 0)
    (x y : ZMod q) (h : x * gen = y * gen) : x = y := by
  grind