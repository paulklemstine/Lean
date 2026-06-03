/-
# Fully Homomorphic Encryption: Core Definitions

This file defines the abstract algebraic framework for noise-bounded
homomorphic encryption schemes, formalizing key concepts from
Gentry's FHE construction and the BGV scheme.

## Main Definitions

* `ArithCircuit` — Arithmetic circuits (addition + multiplication trees)
* `NoiseBoundedHE` — Abstract HE scheme with noise tracking
* `CorrectHE` — HE with correctness guarantees for homomorphic ops
* `BootstrappableHE` — Scheme supporting noise refresh (bootstrapping)

## Key Insight

The central insight of Gentry (2009) is that if a "somewhat homomorphic"
encryption scheme can evaluate its own decryption circuit homomorphically
(with room to spare for one more gate), then it can be "bootstrapped"
into a fully homomorphic scheme supporting unlimited computation.
We formalize this as the condition `bootstrapNoise² < maxNoise`.
-/

import Mathlib

/-! ## Arithmetic Circuits -/

/-- An arithmetic circuit: a tree of additions and multiplications over inputs. -/
inductive ArithCircuit (α : Type*) : Type _
  | input : α → ArithCircuit α
  | add : ArithCircuit α → ArithCircuit α → ArithCircuit α
  | mul : ArithCircuit α → ArithCircuit α → ArithCircuit α

namespace ArithCircuit

/-- The multiplicative depth: longest chain of multiplications from root to leaf. -/
def depth : ArithCircuit α → ℕ
  | input _ => 0
  | add c₁ c₂ => max c₁.depth c₂.depth
  | mul c₁ c₂ => max c₁.depth c₂.depth + 1

/-- Size (number of nodes) of a circuit. -/
def size : ArithCircuit α → ℕ
  | input _ => 1
  | add c₁ c₂ => c₁.size + c₂.size + 1
  | mul c₁ c₂ => c₁.size + c₂.size + 1

/-- Collect all input leaves. -/
def inputs : ArithCircuit α → List α
  | input a => [a]
  | add c₁ c₂ => c₁.inputs ++ c₂.inputs
  | mul c₁ c₂ => c₁.inputs ++ c₂.inputs

/-- Map a function over inputs. -/
def mapInputs {α β : Type*} (f : α → β) : ArithCircuit α → ArithCircuit β
  | input a => input (f a)
  | add c₁ c₂ => add (c₁.mapInputs f) (c₂.mapInputs f)
  | mul c₁ c₂ => mul (c₁.mapInputs f) (c₂.mapInputs f)

/-- Depth is preserved by mapInputs. -/
@[simp]
theorem depth_mapInputs {f : α → β} (c : ArithCircuit α) :
    (c.mapInputs f).depth = c.depth := by
  induction c with
  | input _ => simp [mapInputs, depth]
  | add c₁ c₂ ih₁ ih₂ => simp [mapInputs, depth, ih₁, ih₂]
  | mul c₁ c₂ ih₁ ih₂ => simp [mapInputs, depth, ih₁, ih₂]

end ArithCircuit

/-! ## Noise-Bounded Homomorphic Encryption -/

/-- A noise-bounded homomorphic encryption scheme.

This abstracts LWE/RLWE-based HE schemes. Each ciphertext carries
a noise level; decryption succeeds when noise is below `maxNoise`.
Homomorphic operations increase noise predictably. -/
structure NoiseBoundedHE where
  P : Type
  C : Type
  SK : Type
  noise : SK → C → ℕ
  maxNoise : ℕ
  enc : SK → P → C
  dec : SK → C → P
  hAdd : C → C → C
  hMul : C → C → C
  pAdd : P → P → P
  pMul : P → P → P
  freshNoise : ℕ
  fresh_noise_bound : ∀ sk m, noise sk (enc sk m) ≤ freshNoise
  fresh_lt_max : freshNoise < maxNoise
  dec_enc : ∀ sk m, dec sk (enc sk m) = m
  noise_add : ∀ sk c₁ c₂, noise sk (hAdd c₁ c₂) ≤ noise sk c₁ + noise sk c₂
  noise_mul : ∀ sk c₁ c₂, noise sk (hMul c₁ c₂) ≤ noise sk c₁ * noise sk c₂

/-- A ciphertext is valid when its noise is below the decryption threshold. -/
def NoiseBoundedHE.valid (S : NoiseBoundedHE) (sk : S.SK) (c : S.C) : Prop :=
  S.noise sk c < S.maxNoise

/-! ## Correct Homomorphic Evaluation -/

/-- A correct HE scheme: homomorphic operations on valid ciphertexts
    decrypt to the corresponding plaintext operations. -/
structure CorrectHE extends NoiseBoundedHE where
  add_correct : ∀ sk c₁ c₂,
    noise sk c₁ + noise sk c₂ < maxNoise →
    dec sk (hAdd c₁ c₂) = pAdd (dec sk c₁) (dec sk c₂)
  mul_correct : ∀ sk c₁ c₂,
    noise sk c₁ * noise sk c₂ < maxNoise →
    dec sk (hMul c₁ c₂) = pMul (dec sk c₁) (dec sk c₂)

/-! ## Bootstrappable Scheme -/

/-- A bootstrappable HE scheme has a `refresh` operation that reduces noise
    to a fixed level `bNoise`, preserving the encrypted value.

    The key condition for fully homomorphic computation is:
    `bNoise * bNoise < maxNoise` (can do one more multiplication after refresh)
    and `bNoise + bNoise < maxNoise` (can do one more addition after refresh). -/
structure BootstrappableHE extends CorrectHE where
  refresh : SK → C → C
  bNoise : ℕ
  refresh_noise : ∀ sk c, noise sk c < maxNoise →
    noise sk (refresh sk c) ≤ bNoise
  refresh_correct : ∀ sk c, noise sk c < maxNoise →
    dec sk (refresh sk c) = dec sk c
  bNoise_lt_max : bNoise < maxNoise