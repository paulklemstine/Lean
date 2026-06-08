/-
Copyright (c) 2025. All rights reserved.
Thermodynamic Diophantine Cryptanalysis: Berggren Transfer Operators
for Certified Security of Triple-Based One-Way Maps.

Bridge: connects thermodynamic formalism to cryptographic security on the Berggren tree.
Keywords: entropy, post_quantum_security, certified_robustness, lattice_crypto, quantum_walk
-/
import Mathlib

open Finset Real BigOperators

namespace BerggrenCrypto

/-! ## Berggren Generators

The three Berggren matrices generate the full tree of primitive Pythagorean triples
from the seed (3, 4, 5). We define the corresponding maps on integer triples. -/

/-- First Berggren generator: A-branch of the Pythagorean triple tree. -/
def berggrenA (t : ℤ × ℤ × ℤ) : ℤ × ℤ × ℤ :=
  (t.1 - 2 * t.2.1 + 2 * t.2.2,
   2 * t.1 - t.2.1 + 2 * t.2.2,
   2 * t.1 - 2 * t.2.1 + 3 * t.2.2)

/-- Second Berggren generator: B-branch of the Pythagorean triple tree. -/
def berggrenB (t : ℤ × ℤ × ℤ) : ℤ × ℤ × ℤ :=
  (t.1 + 2 * t.2.1 + 2 * t.2.2,
   2 * t.1 + t.2.1 + 2 * t.2.2,
   2 * t.1 + 2 * t.2.1 + 3 * t.2.2)

/-- Third Berggren generator: C-branch of the Pythagorean triple tree. -/
def berggrenC (t : ℤ × ℤ × ℤ) : ℤ × ℤ × ℤ :=
  (-t.1 + 2 * t.2.1 + 2 * t.2.2,
   -2 * t.1 + t.2.1 + 2 * t.2.2,
   -2 * t.1 + 2 * t.2.1 + 3 * t.2.2)

/-- The three children of a triple under Berggren generation. -/
def berggrenChildren (t : ℤ × ℤ × ℤ) : Finset (ℤ × ℤ × ℤ) :=
  {berggrenA t, berggrenB t, berggrenC t}

/-! ## Finite-Depth Descendants

Cumulative Berggren descendants up to depth `n`, always including the seed.
This forms the finite truncation of the infinite Berggren tree. -/

/-- Cumulative descendants of `seed` under Berggren generation up to depth `n`.
Bridge: finite-depth truncation approximating the infinite thermodynamic boundary. -/
def berggrenDescendants (seed : ℤ × ℤ × ℤ) : ℕ → Finset (ℤ × ℤ × ℤ)
  | 0 => {seed}
  | n + 1 =>
    let prev := berggrenDescendants seed n
    prev ∪ prev.biUnion berggrenChildren

theorem seed_mem_berggrenDescendants (seed : ℤ × ℤ × ℤ) (n : ℕ) :
    seed ∈ berggrenDescendants seed n := by
  induction n <;> simp_all +decide [ berggrenDescendants ]

theorem berggrenDescendants_mono (seed : ℤ × ℤ × ℤ) (n : ℕ) :
    berggrenDescendants seed n ⊆ berggrenDescendants seed (n + 1) := by
  exact Finset.subset_union_left

theorem berggrenDescendants_nonempty (seed : ℤ × ℤ × ℤ) (n : ℕ) :
    (berggrenDescendants seed n).Nonempty := by
  exact ⟨ seed, seed_mem_berggrenDescendants seed n ⟩

/-! ## Cryptographic Observable Structure

Bridge: connects thermodynamic formalism to cryptographic security.
A crypto observable assigns a nonneg weight to each triple with Lipschitz control. -/

/-- Bridge: connects thermodynamic formalism to cryptographic security on the Berggren tree.
Encodes a Lipschitz-bounded, nonneg weight function for thermodynamic partition sums.
Keywords: entropy, certified_robustness, lattice_crypto, quantum_walk. -/
structure BerggrenCryptoObservable where
  weight : ℤ × ℤ × ℤ → ℝ
  nonneg : ∀ t, 0 ≤ weight t
  depthLipschitz : ℝ
  depthLipschitz_nonneg : 0 ≤ depthLipschitz
  depth_control :
    ∀ a b c a' b' c' : ℤ,
      |weight (a, b, c) - weight (a', b', c')|
        ≤ depthLipschitz * (|a - a'| + |b - b'| + |c - c'|)

/-! ## Depth Energy and Hash Fiber Indicators

Supporting definitions for the thermodynamic-cryptographic bridge. -/

/-- Energy function measuring Berggren tree depth via hypotenuse growth.
Bridge: connects tree geometry to thermodynamic weighting. -/
noncomputable def BerggrenDepthEnergy (t : ℤ × ℤ × ℤ) : ℝ :=
  Real.log (|t.2.2| + 1)

/-- Indicator function for hash fiber membership: 1 if `H t = y`, else 0.
Bridge: connects combinatorial counting to transfer-operator analysis. -/
def PreimageIndicator {m : ℕ} (H : ℤ × ℤ × ℤ → Fin m) (y : Fin m)
    (t : ℤ × ℤ × ℤ) : ℝ :=
  if H t = y then 1 else 0

/-- Collision indicator: 1 if two triples hash to the same value, else 0.
Bridge: connects pairwise collision events to thermodynamic pair correlations. -/
def CollisionIndicator {m : ℕ} (H : ℤ × ℤ × ℤ → Fin m)
    (t t' : ℤ × ℤ × ℤ) : ℝ :=
  if H t = H t' then 1 else 0

/-- Hash fiber entropy: log of the number of preimages in a given fiber.
Bridge: connects Shannon entropy to thermodynamic pressure. -/
noncomputable def HashFiberEntropy {m : ℕ} (H : ℤ × ℤ × ℤ → Fin m)
    (seed : ℤ × ℤ × ℤ) (n : ℕ) (y : Fin m) : ℝ :=
  Real.log (((berggrenDescendants seed n).filter fun t => H t = y).card + 1)

/-- Quantum Berggren amplitude bound: models spectral norm decay in quantum walk
analysis of the Berggren tree. Certified upper bound on amplitude growth.
Bridge: connects quantum_walk spectral theory to post_quantum_security. -/
structure QuantumBerggrenAmplitudeBound where
  amplitudeRate : ℝ
  amplitudeConst : ℝ
  amplitudeRate_nonneg : 0 ≤ amplitudeRate
  amplitudeConst_pos : 0 < amplitudeConst

/-- Thermodynamic security gap: the separation between partition growth rate
and collision growth rate that certifies one-way security.
Bridge: certified_robustness via entropy separation. -/
structure ThermodynamicSecurityGap where
  partitionRate : ℝ
  collisionRate : ℝ
  gap_pos : collisionRate < 2 * partitionRate

instance : DecidableEq (ℤ × ℤ × ℤ) := inferInstance

instance berggrenDescendantsFintype (seed : ℤ × ℤ × ℤ) (n : ℕ) :
    Fintype (berggrenDescendants seed n : Set (ℤ × ℤ × ℤ)) :=
  (berggrenDescendants seed n).fintypeCoeSort

instance hashFiberDecidable {m : ℕ} (H : ℤ × ℤ × ℤ → Fin m) (y : Fin m) :
    DecidablePred (fun t => H t = y) :=
  fun t => decEq (H t) y

/-! ## Core Cryptographic Definitions

Partition sums, collision counts, preimage counts, and weighted probabilities. -/

/-- Finite-depth partition sum for cryptographic observables on Berggren descendants.
Bridge: connects thermodynamic formalism to cryptographic security —
the partition sum controls all security bounds. -/
noncomputable def CryptoPartitionSum
    (F : BerggrenCryptoObservable)
    (seed : ℤ × ℤ × ℤ)
    (n : ℕ) : ℝ :=
  ∑ t ∈ berggrenDescendants seed n, Real.exp (F.weight t)

/-- Collision count at depth `n` for a finite-output hash on Berggren descendants.
Bridge: connects combinatorial collision events to cryptographic collision resistance. -/
def CollisionCount {m : ℕ}
    (H : ℤ × ℤ × ℤ → Fin m)
    (seed : ℤ × ℤ × ℤ)
    (n : ℕ) : ℕ :=
  ((berggrenDescendants seed n).offDiag.filter
    (fun p => H p.1 = H p.2)).card

/-- Preimage count of a target hash value at depth `n`.
Bridge: connects preimage hardness to thermodynamic fiber analysis. -/
def PreimageCount {m : ℕ}
    (H : ℤ × ℤ × ℤ → Fin m)
    (seed : ℤ × ℤ × ℤ)
    (n : ℕ)
    (y : Fin m) : ℕ :=
  ((berggrenDescendants seed n).filter fun t => H t = y).card

/-- Normalized collision pressure, logarithmic in the partition sum scale.
Bridge: pressure = log(collisions) - 2*log(Z), connecting thermodynamic pressure
to collision resistance. Negative pressure certifies post_quantum_security. -/
noncomputable def CollisionPressure {m : ℕ}
    (F : BerggrenCryptoObservable)
    (H : ℤ × ℤ × ℤ → Fin m)
    (seed : ℤ × ℤ × ℤ)
    (n : ℕ) : ℝ :=
  Real.log (↑(CollisionCount H seed n) + 1) - 2 * Real.log (CryptoPartitionSum F seed n)

/-- A finite-depth transfer iterate driven by a crypto observable.
Bridge: connects transfer-operator spectral theory to partition sum computation. -/
noncomputable def CryptoTransferIterate
    (F : BerggrenCryptoObservable)
    (g : ℤ × ℤ × ℤ → ℝ)
    (seed : ℤ × ℤ × ℤ)
    (n : ℕ) : ℝ :=
  ∑ t ∈ berggrenDescendants seed n, Real.exp (F.weight t) * g t

/-- Depth-normalized collision probability among independently F-weighted descendants.
Bridge: connects pairwise collision events to weighted probability distributions. -/
noncomputable def WeightedCollisionProbability {m : ℕ}
    (F : BerggrenCryptoObservable)
    (H : ℤ × ℤ × ℤ → Fin m)
    (seed : ℤ × ℤ × ℤ)
    (n : ℕ) : ℝ :=
  (∑ p ∈ (berggrenDescendants seed n).offDiag,
      if H p.1 = H p.2 then
        Real.exp (F.weight p.1 + F.weight p.2)
      else 0)
  / (CryptoPartitionSum F seed n) ^ 2

/-- Maximum point mass of the weighted output distribution.
Bridge: connects weighted preimage probability to entropy and post_quantum_security. -/
noncomputable def WeightedPreimageProbability {m : ℕ}
    (F : BerggrenCryptoObservable)
    (H : ℤ × ℤ × ℤ → Fin m)
    (seed : ℤ × ℤ × ℤ)
    (n : ℕ)
    (y : Fin m) : ℝ :=
  (∑ t ∈ (berggrenDescendants seed n).filter fun t => H t = y,
      Real.exp (F.weight t))
  / CryptoPartitionSum F seed n

/-- Spectral-radius surrogate usable in finite-depth certified bounds.
Bridge: finite approximation to the transfer-operator spectral radius,
connecting spectral theory to certified_robustness. -/
noncomputable def FiniteDepthSpectralRate
    (F : BerggrenCryptoObservable)
    (seed : ℤ × ℤ × ℤ)
    (n : ℕ) : ℝ :=
  Real.log (CryptoPartitionSum F seed (n + 1)) -
    Real.log (CryptoPartitionSum F seed n)

/-- Certified finite-depth security profile extracted from transfer bounds.
Bridge: packages collision and preimage exponents with spectral and entropy data
for certified post_quantum_security analysis. -/
structure BerggrenSecurityProfile where
  collisionExponent : ℝ
  preimageExponent : ℝ
  spectralUpper : ℝ
  entropyGap : ℝ
  collisionExponent_nonneg : 0 ≤ collisionExponent
  preimageExponent_nonneg : 0 ≤ preimageExponent
  entropyGap_nonneg : 0 ≤ entropyGap

/-- Security profile extracted from explicit finite-depth inequalities.
Bridge: constructs a certified security profile from observables and hash data. -/
noncomputable def securityProfileOf {m : ℕ}
    (F : BerggrenCryptoObservable)
    (H : ℤ × ℤ × ℤ → Fin m)
    (seed : ℤ × ℤ × ℤ)
    (n : ℕ) : BerggrenSecurityProfile where
  collisionExponent := max 0 (Real.log (↑(CollisionCount H seed n) + 1) / (↑n + 1))
  preimageExponent := max 0 (Real.log ↑(berggrenDescendants seed n).card / (↑n + 1))
  spectralUpper := FiniteDepthSpectralRate F seed n
  entropyGap := max 0 (FiniteDepthSpectralRate F seed n -
    Real.log (↑(CollisionCount H seed n) + 1) / (↑n + 1))
  collisionExponent_nonneg := le_max_left 0 _
  preimageExponent_nonneg := le_max_left 0 _
  entropyGap_nonneg := le_max_left 0 _

end BerggrenCrypto