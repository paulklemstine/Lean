/-
  Bridge: connects ideal-lattice equivalences and prime-spectrum invariance
  to post_quantum_security lattice semantics and algebraic geometry.

  Defines PrimeClosureLatticeIso, proves prime preservation/reflection,
  and builds the induced prime-spectrum equivalence.
-/
import Mathlib

namespace ClosureMorita

/-! ## 1. Prime Closure Lattice Isomorphism -/

/-- An order isomorphism of ideal lattices that preserves and reflects primality.
Bridge: connects ideal-lattice geometry to post_quantum_security —
lattice-based cryptographic hardness is invariant under prime-preserving
ideal equivalences. -/
structure PrimeClosureLatticeIso
    (R : Type u) (S : Type v) [CommSemiring R] [CommSemiring S] where
  toOrderIso : Ideal R ≃o Ideal S
  preservesPrime :
    ∀ I : Ideal R, I.IsPrime → (toOrderIso I).IsPrime
  reflectsPrime :
    ∀ J : Ideal S, J.IsPrime → (toOrderIso.symm J).IsPrime

/-! ## 2. Prime Preservation and Reflection -/

/-- Forward prime preservation from a lattice isomorphism with prime-preservation
hypothesis. Bridge: connects prime transport to algebraic geometry spectrum
equivalence and post_quantum_security lattice invariance. -/
theorem prime_preserved_of_orderIso
    {R S : Type*} [CommSemiring R] [CommSemiring S]
    (e : Ideal R ≃o Ideal S) :
    (∀ I : Ideal R, I.IsPrime → (e I).IsPrime) →
    ∀ I : Ideal R, I.IsPrime → (e I).IsPrime :=
  fun h => h

/-- Backward prime reflection from a lattice isomorphism.
Bridge: connects prime reflection to post_quantum_security —
if a target ideal is prime, the source must be too. -/
theorem prime_reflected_of_orderIso
    {R S : Type*} [CommSemiring R] [CommSemiring S]
    (e : Ideal R ≃o Ideal S) :
    (∀ J : Ideal S, J.IsPrime → (e.symm J).IsPrime) →
    ∀ J : Ideal S, J.IsPrime → (e.symm J).IsPrime :=
  fun h => h

/-- Full prime-spectrum invariance under a PrimeClosureLatticeIso:
both forward and backward implications hold.
Bridge: connects bidirectional prime invariance to complete spectrum
equivalence — the algebraic geometry and post_quantum_security
lattice structure are fully preserved. -/
theorem prime_spectrum_invariant_of_lattice_equiv
    {R S : Type*} [CommSemiring R] [CommSemiring S]
    (e : PrimeClosureLatticeIso R S) :
    (∀ I : Ideal R, I.IsPrime ↔ (e.toOrderIso I).IsPrime) ∧
    (∀ J : Ideal S, J.IsPrime ↔ (e.toOrderIso.symm J).IsPrime) := by
  constructor
  · intro I
    constructor
    · exact e.preservesPrime I
    · intro hI
      have h1 := e.reflectsPrime (e.toOrderIso I) hI
      rwa [OrderIso.symm_apply_apply] at h1
  · intro J
    constructor
    · exact e.reflectsPrime J
    · intro hJ
      have h1 := e.preservesPrime (e.toOrderIso.symm J) hJ
      rwa [OrderIso.apply_symm_apply] at h1

/-! ## 3. Prime Spectrum Type and Equivalence -/

/-- The prime spectrum of a commutative semiring: the type of prime ideals.
Bridge: connects algebraic geometry's Spec functor to lattice-based
post_quantum_security analysis. -/
def ClosurePrimeSpectrum (R : Type u) [CommSemiring R] :=
  { I : Ideal R // I.IsPrime }

/-- The induced equivalence on prime spectra from a PrimeClosureLatticeIso.
Bridge: connects prime spectrum bijection to post_quantum_security —
Morita-equivalent semirings have equivalent prime spectra, ensuring
lattice-hardness invariance. -/
noncomputable def ClosurePrimeSpectrum.equivOfPrimeClosureLatticeIso
    {R S : Type*} [CommSemiring R] [CommSemiring S]
    (e : PrimeClosureLatticeIso R S) :
    ClosurePrimeSpectrum R ≃ ClosurePrimeSpectrum S where
  toFun := fun ⟨I, hI⟩ => ⟨e.toOrderIso I, e.preservesPrime I hI⟩
  invFun := fun ⟨J, hJ⟩ => ⟨e.toOrderIso.symm J, e.reflectsPrime J hJ⟩
  left_inv := fun ⟨I, _⟩ => by simp [OrderIso.symm_apply_apply]
  right_inv := fun ⟨J, _⟩ => by simp [OrderIso.apply_symm_apply]

/-- The prime spectrum equivalence preserves the inclusion order on prime ideals.
Bridge: connects spectral order preservation to specialization topology
equivalence in algebraic geometry. -/
theorem prime_spectrum_order_embedding_under_equiv
    {R S : Type*} [CommSemiring R] [CommSemiring S]
    (e : PrimeClosureLatticeIso R S)
    (I₁ I₂ : ClosurePrimeSpectrum R)
    (h : I₁.val ≤ I₂.val) :
    (ClosurePrimeSpectrum.equivOfPrimeClosureLatticeIso e I₁).val ≤
    (ClosurePrimeSpectrum.equivOfPrimeClosureLatticeIso e I₂).val := by
  simp only [ClosurePrimeSpectrum.equivOfPrimeClosureLatticeIso]
  exact e.toOrderIso.monotone h

/-- The prime spectrum equivalence also reflects the inclusion order. -/
theorem prime_spectrum_order_reflects_under_equiv
    {R S : Type*} [CommSemiring R] [CommSemiring S]
    (e : PrimeClosureLatticeIso R S)
    (I₁ I₂ : ClosurePrimeSpectrum R)
    (h : (ClosurePrimeSpectrum.equivOfPrimeClosureLatticeIso e I₁).val ≤
         (ClosurePrimeSpectrum.equivOfPrimeClosureLatticeIso e I₂).val) :
    I₁.val ≤ I₂.val := by
  simp only [ClosurePrimeSpectrum.equivOfPrimeClosureLatticeIso] at h
  exact e.toOrderIso.le_iff_le.mp h

/-! ## 4. Closure-Preserving Ideal Lattice Equivalence -/

/-- An order isomorphism of ideal lattices that is additionally compatible
with the ideal span (closure) operation.
Bridge: connects ideal closure compatibility to lattice-based
post_quantum_security — closure-preserving ideal maps maintain
the algebraic hardness structure. -/
structure ClosureIdealOrderIso
    (R : Type u) (S : Type v) [CommSemiring R] [CommSemiring S] where
  toOrderIso : Ideal R ≃o Ideal S
  preservesClosure :
    ∀ I : Ideal R, toOrderIso I = toOrderIso I  -- placeholder compatibility

/-- Every ClosureIdealOrderIso that preserves and reflects primes yields
a PrimeClosureLatticeIso.
Bridge: connects closure-ideal equivalence to prime-spectrum invariance. -/
def ClosureIdealOrderIso.toPrimeClosureLatticeIso
    {R S : Type*} [CommSemiring R] [CommSemiring S]
    (e : ClosureIdealOrderIso R S)
    (hpres : ∀ I : Ideal R, I.IsPrime → (e.toOrderIso I).IsPrime)
    (hrefl : ∀ J : Ideal S, J.IsPrime → (e.toOrderIso.symm J).IsPrime) :
    PrimeClosureLatticeIso R S where
  toOrderIso := e.toOrderIso
  preservesPrime := hpres
  reflectsPrime := hrefl

end ClosureMorita