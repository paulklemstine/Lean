/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Compact Congruence Nuclei and Prime Congruence Spectra

This file establishes the comparison theorem between the nucleus spectrum
(constructed from compact congruence nuclei) and the prime congruence spectrum
for coherent idempotent semirings.

## Main definitions

* `CoherentIdemSemiring`: typeclass for commutative idempotent semirings whose
  compact congruences form a coherent basis (closed under ⊓ and ⊔).
* `CompactCongruence`: order-theoretic compactness for ring congruences.
* `CongruenceNucleus`: the compact saturation nucleus on `RingCon S`.
* `IsPrimeCongruence`: primality for congruences with respect to compact elements.
* `PrimeCongruencePoint`: a prime congruence that is nucleus-fixed.

## Main results

* `CongruenceNucleus_monotone`, `CongruenceNucleus_extensive`,
  `CongruenceNucleus_idem`: the nucleus laws.
* `primeCongruence_point_bijective`: the set-theoretic bijection.
* `nucleusSpectrum_homeomorphic_primeSpectrum`: the homeomorphism.

## Mathematical significance

This theorem is the comparison principle between the pointfree/nuclear language
of spectral locales and the point-set/algebraic language of prime congruence
spectra. For coherent idempotent semirings, the compact saturation nucleus
is the identity (by the algebraic lattice / compactly generated condition),
so every congruence is nucleus-fixed. This means prime congruence points
are exactly prime congruences, and the two spectra coincide as topological spaces.
-/

import Mathlib

open scoped Classical

noncomputable section

/-! ## Compact Congruences -/

/-- A ring congruence is compact if it is a compact element in the complete lattice
of ring congruences. This is the order-theoretic notion: `R` is compact if whenever
`R ≤ sSup D` for a directed set `D`, there exists `K ∈ D` with `R ≤ K`. -/
abbrev CompactCongruence {S : Type*} [Add S] [Mul S] (R : RingCon S) : Prop :=
  IsCompactElement R

/-! ## Coherent Idempotent Semiring -/

/-- A coherent idempotent semiring is a commutative idempotent semiring
whose ring congruence lattice satisfies coherence: compact congruences
are closed under finite meets and joins, and `⊤`/`⊥` are compact.
The lattice is also algebraic (compactly generated).

This captures exactly the hypotheses needed for the compact-open/prime-spectrum
comparison theorem. -/
class CoherentIdemSemiring (S : Type*) extends IdemCommSemiring S where
  /-- The infimum of two compact congruences is compact. -/
  compact_inf : ∀ {R T : RingCon S}, CompactCongruence R → CompactCongruence T →
    CompactCongruence (R ⊓ T)
  /-- The supremum of two compact congruences is compact. -/
  compact_sup : ∀ {R T : RingCon S}, CompactCongruence R → CompactCongruence T →
    CompactCongruence (R ⊔ T)
  /-- The top congruence is compact. -/
  compact_top : CompactCongruence (⊤ : RingCon S)
  /-- The bottom congruence is compact. -/
  compact_bot : CompactCongruence (⊥ : RingCon S)
  /-- Every congruence is the supremum of compact congruences below it
      (algebraic lattice / compactly generated condition). -/
  compactly_generated : ∀ (R : RingCon S),
    R = sSup {K : RingCon S | CompactCongruence K ∧ K ≤ R}

variable {S : Type*} [CoherentIdemSemiring S]

/-! ## The Congruence Nucleus -/

/-- The congruence nucleus: compact saturation of a ring congruence.
This is the supremum of all compact congruences contained in `R`.
In a compactly generated (algebraic) lattice, this equals `R` itself. -/
def CongruenceNucleus (R : RingCon S) : RingCon S :=
  sSup {K : RingCon S | CompactCongruence K ∧ K ≤ R}

/-- The compact congruence basis: the set of compact elements in `RingCon S`. -/
def CompactCongruenceBasis (S : Type*) [CoherentIdemSemiring S] : Set (RingCon S) :=
  {R : RingCon S | CompactCongruence R}

theorem CompactCongruenceBasis_inf_closed :
    ∀ {R T : RingCon S}, R ∈ CompactCongruenceBasis S → T ∈ CompactCongruenceBasis S →
      (R ⊓ T) ∈ CompactCongruenceBasis S :=
  fun hR hT => CoherentIdemSemiring.compact_inf hR hT

theorem CompactCongruenceBasis_sup_closed :
    ∀ {R T : RingCon S}, R ∈ CompactCongruenceBasis S → T ∈ CompactCongruenceBasis S →
      (R ⊔ T) ∈ CompactCongruenceBasis S :=
  fun hR hT => CoherentIdemSemiring.compact_sup hR hT

theorem CompactCongruenceBasis_top_mem :
    (⊤ : RingCon S) ∈ CompactCongruenceBasis S :=
  CoherentIdemSemiring.compact_top

theorem CompactCongruenceBasis_bot_mem :
    (⊥ : RingCon S) ∈ CompactCongruenceBasis S :=
  CoherentIdemSemiring.compact_bot

/-! ## Nucleus Laws -/

/-- The congruence nucleus is monotone. -/
theorem CongruenceNucleus_monotone :
    Monotone (CongruenceNucleus (S := S)) := by
  intro R T hRT
  apply sSup_le_sSup
  intro K ⟨hK, hKR⟩
  exact ⟨hK, le_trans hKR hRT⟩

/-- The congruence nucleus is extensive: `R ≤ CongruenceNucleus R`.
In fact, by the compactly generated axiom, `R = CongruenceNucleus R`. -/
theorem CongruenceNucleus_extensive (R : RingCon S) :
    R ≤ CongruenceNucleus R := by
  unfold CongruenceNucleus
  nth_rw 1 [CoherentIdemSemiring.compactly_generated R]

/-- The nucleus is bounded above by the original congruence:
`CongruenceNucleus R ≤ R`, since every compact `K ≤ R` contributes to the sSup. -/
theorem CongruenceNucleus_le (R : RingCon S) : CongruenceNucleus R ≤ R := by
  apply sSup_le
  exact fun K ⟨_, hKR⟩ => hKR

/-- The congruence nucleus is the identity on a compactly generated lattice. -/
theorem CongruenceNucleus_eq (R : RingCon S) :
    CongruenceNucleus R = R :=
  le_antisymm (CongruenceNucleus_le R) (CongruenceNucleus_extensive R)

/-- The congruence nucleus is idempotent. -/
theorem CongruenceNucleus_idem (R : RingCon S) :
    CongruenceNucleus (CongruenceNucleus R) = CongruenceNucleus R := by
  rw [CongruenceNucleus_eq]

/-- The congruence nucleus preserves meets. -/
theorem CongruenceNucleus_meet (R T : RingCon S) :
    CongruenceNucleus (R ⊓ T) = CongruenceNucleus R ⊓ CongruenceNucleus T := by
  simp only [CongruenceNucleus_eq]

/-! ## Prime Congruences -/

/-- A ring congruence `P` is prime if it is proper (not `⊤`) and for any two
compact congruences whose meet is below `P`, at least one of them is below `P`.

This captures the "prime" condition in the spectral locale sense: the corresponding
point sends meets to meets, which for a two-valued frame homomorphism means
the "not contained" filter is prime. -/
def IsPrimeCongruence (P : RingCon S) : Prop :=
  P ≠ ⊤ ∧ ∀ {R T : RingCon S}, CompactCongruence R → CompactCongruence T →
    R ⊓ T ≤ P → R ≤ P ∨ T ≤ P

/-- A prime congruence point consists of a congruence that is both prime and
nucleus-fixed (equal to its compact saturation). These are the points of the
spectral locale attached to the compact congruence nucleus.

In a coherent idempotent semiring with a compactly generated congruence lattice,
every congruence is nucleus-fixed, so the nucleus-fixed condition is automatic. -/
structure PrimeCongruencePoint (S : Type*) [CoherentIdemSemiring S] where
  /-- The underlying congruence. -/
  asCongruence : RingCon S
  /-- The congruence is prime. -/
  is_prime : IsPrimeCongruence asCongruence
  /-- The congruence is a nucleus fixed point. -/
  is_nucleus_fixed : CongruenceNucleus asCongruence = asCongruence

@[ext]
theorem PrimeCongruencePoint.ext {x y : PrimeCongruencePoint S}
    (h : x.asCongruence = y.asCongruence) : x = y := by
  cases x; cases y; simp only [mk.injEq] at h ⊢; exact h

/-! ## Key intermediate theorem -/

/-- Every congruence is a nucleus fixed point in a compactly generated lattice. -/
theorem nucleus_fixed_always (P : RingCon S) :
    CongruenceNucleus P = P :=
  CongruenceNucleus_eq P

/-- The nucleus–prime characterization: the nucleus-fixed condition is equivalent
to compact detection. Since the nucleus is the identity, both sides are trivially true. -/
theorem nucleus_fixed_iff_prime_detects_compacts (P : RingCon S) :
    CongruenceNucleus P = P ↔
    ∀ R : RingCon S, CompactCongruence R → (R ≤ P ↔ CongruenceNucleus R ≤ P) := by
  constructor
  · intro _ R _; rw [CongruenceNucleus_eq]
  · intro _; exact CongruenceNucleus_eq P

/-! ## Maps between prime congruences and prime points -/

/-- Every prime congruence gives a prime congruence point, since all congruences
are nucleus-fixed in the compactly generated setting. -/
def primeCongruence_to_point :
    {P : RingCon S // IsPrimeCongruence P} → PrimeCongruencePoint S :=
  fun ⟨P, hP⟩ => ⟨P, hP, CongruenceNucleus_eq P⟩

/-- Every prime congruence point gives a prime congruence (by forgetting the
nucleus-fixed condition). -/
def point_to_primeCongruence :
    PrimeCongruencePoint S → {P : RingCon S // IsPrimeCongruence P} :=
  fun x => ⟨x.asCongruence, x.is_prime⟩

/-- The round-trip from primes to points and back is the identity. -/
theorem point_to_primeCongruence_to_point
    (P : {Q : RingCon S // IsPrimeCongruence Q}) :
    point_to_primeCongruence (primeCongruence_to_point P) = P := by
  ext; simp [primeCongruence_to_point, point_to_primeCongruence]

/-- The round-trip from points to primes and back is the identity. -/
theorem primeCongruence_to_point_to_primeCongruence
    (x : PrimeCongruencePoint S) :
    primeCongruence_to_point (point_to_primeCongruence x) = x := by
  exact PrimeCongruencePoint.ext rfl

/-- The map from prime congruences to prime congruence points is a bijection. -/
theorem primeCongruence_point_bijective :
    Function.Bijective
      (primeCongruence_to_point (S := S)) := by
  exact ⟨
    fun ⟨_, _⟩ ⟨_, _⟩ h => by
      simp [primeCongruence_to_point] at h; exact Subtype.ext h,
    fun x => ⟨point_to_primeCongruence x, primeCongruence_to_point_to_primeCongruence x⟩⟩

/-- The equivalence between prime congruences and prime congruence points. -/
def primeCongruence_point_equiv :
    {P : RingCon S // IsPrimeCongruence P} ≃ PrimeCongruencePoint S where
  toFun := primeCongruence_to_point
  invFun := point_to_primeCongruence
  left_inv := point_to_primeCongruence_to_point
  right_inv := primeCongruence_to_point_to_primeCongruence

/-! ## Compact-prime separation -/

/-- The basic open set of the prime congruence spectrum defined by a congruence `R`:
the set of primes not containing `R`. -/
def PrimeCongruenceBasicOpen (R : RingCon S) :
    Set {P : RingCon S // IsPrimeCongruence P} :=
  {P | ¬ R ≤ P.1}

/-- The basic open set of the point spectrum defined by a congruence `R`. -/
def PointBasicOpen (R : RingCon S) :
    Set (PrimeCongruencePoint S) :=
  {x | ¬ R ≤ x.asCongruence}

/-- If `R` is a compact congruence not contained in a prime `P`, then
`P` itself witnesses a point in the basic open `D(R)`. -/
theorem compact_not_le_prime_separated
    {P : RingCon S} (hP : IsPrimeCongruence P)
    {R : RingCon S} (_hR : CompactCongruence R) :
    ¬ R ≤ P →
    ∃ x, x ∈ PrimeCongruenceBasicOpen R :=
  fun h => ⟨⟨P, hP⟩, h⟩

/-! ## Topologies -/

/-- The topology on the prime congruence spectrum, generated by basic opens
`D(R) = {P prime | R ≰ P}`. This is the analogue of the Zariski topology. -/
instance PrimeCongruenceSpectrum.topologicalSpace :
    TopologicalSpace {P : RingCon S // IsPrimeCongruence P} :=
  TopologicalSpace.generateFrom
    {U | ∃ R : RingCon S, U = PrimeCongruenceBasicOpen R}

/-- The topology on the prime congruence point spectrum, generated by
point basic opens. -/
instance PrimeCongruencePointSpectrum.topologicalSpace :
    TopologicalSpace (PrimeCongruencePoint S) :=
  TopologicalSpace.generateFrom
    {U | ∃ R : RingCon S, U = PointBasicOpen R}

/-! ## Preimage lemmas -/

/-- The preimage of a point basic open under the prime-to-point map
is exactly the prime basic open. -/
theorem primeCongruence_to_point_preimage_basicOpen (R : RingCon S) :
    primeCongruence_to_point ⁻¹' PointBasicOpen R = PrimeCongruenceBasicOpen R := by
  ext ⟨P, hP⟩
  simp [primeCongruence_to_point, PointBasicOpen, PrimeCongruenceBasicOpen]

/-- The preimage of a prime basic open under the point-to-prime map
is exactly the point basic open. -/
theorem point_to_primeCongruence_preimage_basicOpen (R : RingCon S) :
    point_to_primeCongruence ⁻¹' PrimeCongruenceBasicOpen R = PointBasicOpen R := by
  ext x
  simp [point_to_primeCongruence, PrimeCongruenceBasicOpen, PointBasicOpen]

/-! ## Continuity -/

/-- The map from prime congruences to prime points is continuous. -/
theorem primeCongruence_to_point_continuous :
    Continuous (primeCongruence_to_point (S := S)) := by
  rw [continuous_generateFrom_iff]
  intro U ⟨R, hR⟩
  subst hR
  rw [primeCongruence_to_point_preimage_basicOpen]
  exact TopologicalSpace.isOpen_generateFrom_of_mem ⟨R, rfl⟩

/-- The map from prime points to prime congruences is continuous. -/
theorem point_to_primeCongruence_continuous :
    Continuous (point_to_primeCongruence (S := S)) := by
  rw [continuous_generateFrom_iff]
  intro U ⟨R, hR⟩
  subst hR
  rw [point_to_primeCongruence_preimage_basicOpen]
  exact TopologicalSpace.isOpen_generateFrom_of_mem ⟨R, rfl⟩

/-! ## The Homeomorphism -/

/-- **Main theorem.** The nucleus spectrum of a coherent idempotent semiring is
homeomorphic to its prime congruence spectrum.

This establishes the comparison principle between the pointfree/nuclear language
of spectral locales and the point-set/algebraic language of prime congruence
spectra. For coherent idempotent semirings with compactly generated congruence
lattices, the compact saturation nucleus is the identity, making the two
spectra canonically homeomorphic via the natural forgetful/enrichment maps. -/
def nucleusSpectrum_homeomorphic_primeSpectrum :
    PrimeCongruencePoint S ≃ₜ {P : RingCon S // IsPrimeCongruence P} where
  toEquiv := primeCongruence_point_equiv.symm
  continuous_toFun := point_to_primeCongruence_continuous
  continuous_invFun := primeCongruence_to_point_continuous

end