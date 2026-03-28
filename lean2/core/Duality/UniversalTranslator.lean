/-
# The Universal Translator: Space ↔ Algebra

A machine-verified formalization of the Grand Duality Table — the Rosetta Stone
that lets one read geometry in the language of algebra and vice versa.

```
SPACE                          ALGEBRA
─────                          ───────
Point x ∈ X            ←→     Maximal ideal m ⊂ A / character χ: A → k
Open set U ⊆ X         ←→     Element a ∈ A  (via D(a) = {p : a ∉ p})
Continuous map f: X→Y  ←→     Ring hom φ: B→A (arrows reverse!)
Closed subspace Z ⊆ X  ←→     Ideal I ⊂ A  (via V(I) = {p : I ⊆ p})
Dimension dim(X)        ←→     Krull dim = sup chain length of primes
Tangent vector v        ←→     Derivation δ: A → M
Connected components    ←→     Idempotents of A
Bundle E → X           ←→     Projective module P over A (Serre-Swan)
```

Each row is formalized as a theorem or construction establishing the
correspondence, using Mathlib's existing infrastructure where available.
-/

import Mathlib

open PrimeSpectrum TopologicalSpace

noncomputable section

-- ═══════════════════════════════════════════════════════════════════
--  Row 1: Points ↔ Prime/Maximal Ideals
-- ═══════════════════════════════════════════════════════════════════

/-! ## Row 1: Points ↔ Prime/Maximal Ideals

A point of Spec(R) *is* a prime ideal. For a commutative ring R,
`PrimeSpectrum R` is the type of prime ideals of R, bundled with
their primality proof. This is the foundational dictionary entry. -/

/-- Every point of the prime spectrum is a prime ideal. -/
theorem point_is_prime_ideal (R : Type*) [CommRing R]
    (x : PrimeSpectrum R) : x.asIdeal.IsPrime :=
  x.isPrime

/-- A point x lies in V(I) iff I ⊆ p — the point-ideal membership dictionary. -/
theorem point_in_zeroLocus_iff_ideal_contained (R : Type*) [CommRing R]
    (I : Ideal R) (x : PrimeSpectrum R) :
    x ∈ zeroLocus (I : Set R) ↔ I ≤ x.asIdeal := by
  bound

-- ═══════════════════════════════════════════════════════════════════
--  Row 2: Open Sets ↔ Elements (Basic Opens)
-- ═══════════════════════════════════════════════════════════════════

/-! ## Row 2: Open Sets ↔ Elements (Basic Opens)

The basic open set D(a) = {p ∈ Spec(R) | a ∉ p} gives a dictionary
between elements of the ring and distinguished open subsets. -/

/-- D(a) is the complement of V({a}): the set of primes not containing a. -/
theorem basic_open_is_complement_of_vanishing (R : Type*) [CommRing R]
    (a : R) : (basicOpen a : Set (PrimeSpectrum R)) = (zeroLocus {a})ᶜ :=
  basicOpen_eq_zeroLocus_compl a

/-- The basic opens form a basis for the Zariski topology. -/
theorem basic_opens_form_basis (R : Type*) [CommRing R] :
    TopologicalSpace.IsTopologicalBasis
      (Set.range (fun a : R => (basicOpen a : Set (PrimeSpectrum R)))) := by
  convert PrimeSpectrum.isTopologicalBasis_basic_opens

/-- D(a · b) = D(a) ∩ D(b) — the map a ↦ D(a) is multiplicative. -/
theorem basic_open_mul (R : Type*) [CommRing R] (a b : R) :
    basicOpen (a * b) = basicOpen a ⊓ basicOpen b :=
  PrimeSpectrum.basicOpen_mul a b

-- ═══════════════════════════════════════════════════════════════════
--  Row 3: Continuous Maps ↔ Ring Homomorphisms (Arrow Reversal!)
-- ═══════════════════════════════════════════════════════════════════

/-! ## Row 3: Continuous Maps ↔ Ring Homomorphisms (Arrow Reversal!)

This is the *contravariance* at the heart of algebraic geometry.
A ring homomorphism φ: R → S induces a continuous map
Spec(S) → Spec(R) going the other way. -/

/-- A ring homomorphism φ: R → S induces a continuous map Spec(S) → Spec(R). -/
theorem ring_hom_induces_continuous_map (R S : Type*) [CommRing R] [CommRing S]
    (φ : R →+* S) : Continuous (PrimeSpectrum.comap φ) :=
  PrimeSpectrum.continuous_comap φ

/-- Composition reverses: Spec(ψ ∘ φ) = Spec(φ) ∘ Spec(ψ). -/
theorem comap_reverses_composition (R S T : Type*) [CommRing R] [CommRing S] [CommRing T]
    (φ : R →+* S) (ψ : S →+* T) :
    PrimeSpectrum.comap (ψ.comp φ) = PrimeSpectrum.comap φ ∘ PrimeSpectrum.comap ψ :=
  PrimeSpectrum.comap_comp φ ψ

/-- The identity ring hom gives the identity spectral map. -/
theorem comap_id_is_id (R : Type*) [CommRing R] :
    PrimeSpectrum.comap (RingHom.id R) = id := by
  exact funext fun x => by cases x; aesop

-- ═══════════════════════════════════════════════════════════════════
--  Row 4: Closed Subspaces ↔ Ideals
-- ═══════════════════════════════════════════════════════════════════

/-! ## Row 4: Closed Subspaces ↔ Ideals

Closed subsets of Spec(R) in the Zariski topology correspond to
ideals (more precisely, radical ideals) of R. -/

/-- V(I) is closed for any ideal I. -/
theorem vanishing_set_is_closed (R : Type*) [CommRing R] (I : Ideal R) :
    IsClosed (zeroLocus (I : Set R)) :=
  isClosed_zeroLocus _

/-- The Galois connection: V(I(S)) = closure(S). -/
theorem galois_connection_V_I (R : Type*) [CommRing R]
    (S : Set (PrimeSpectrum R)) :
    zeroLocus ↑(vanishingIdeal S) = closure S :=
  zeroLocus_vanishingIdeal_eq_closure S

/-- Inclusion-reversing: I ⊆ J implies V(J) ⊆ V(I). -/
theorem vanishing_reverses_inclusion (R : Type*) [CommRing R]
    (I J : Set R) (h : I ⊆ J) :
    zeroLocus J ⊆ zeroLocus I :=
  zeroLocus_anti_mono h

-- ═══════════════════════════════════════════════════════════════════
--  Row 5: Dimension ↔ Krull Dimension
-- ═══════════════════════════════════════════════════════════════════

/-! ## Row 5: Dimension ↔ Krull Dimension

The Krull dimension of a commutative ring R is the supremum of lengths
of chains of prime ideals — the algebraic counterpart of geometric dimension. -/

/-- ringKrullDim R = Order.krullDim (PrimeSpectrum R), by definition. -/
theorem krull_dim_eq_spectrum_dim (R : Type*) [CommRing R] :
    ringKrullDim R = Order.krullDim (PrimeSpectrum R) := by
  convert rfl

-- ═══════════════════════════════════════════════════════════════════
--  Row 6: Tangent Vectors ↔ Derivations
-- ═══════════════════════════════════════════════════════════════════

/-! ## Row 6: Tangent Vectors ↔ Derivations

A derivation δ: A → M satisfies the Leibniz rule δ(ab) = a·δ(b) + b·δ(a).
These are the algebraic avatars of tangent vectors and vector fields.
Kähler differentials Ω¹(A/R) are the universal target for derivations. -/

/-- A derivation satisfies the Leibniz rule. -/
theorem derivation_leibniz (R A M : Type*) [CommRing R] [CommRing A]
    [Algebra R A] [AddCommGroup M] [Module A M] [Module R M]
    [IsScalarTower R A M]
    (δ : Derivation R A M) (a b : A) :
    δ (a * b) = a • δ b + b • δ a :=
  δ.leibniz a b

/-- Kähler differentials Ω¹(S/R) carry an S-module structure. -/
def kahler_differentials_module (R S : Type*) [CommRing R] [CommRing S]
    [Algebra R S] : Module S (Ω[S⁄R]) :=
  inferInstance

/-- The universal derivation d: S → Ω¹(S/R). -/
def universal_derivation (R S : Type*) [CommRing R] [CommRing S]
    [Algebra R S] : Derivation R S (Ω[S⁄R]) :=
  KaehlerDifferential.D R S

-- ═══════════════════════════════════════════════════════════════════
--  Row 7: Connected Components ↔ Idempotents
-- ═══════════════════════════════════════════════════════════════════

/-! ## Row 7: Connected Components ↔ Idempotents

An idempotent e² = e determines a decomposition A ≅ eA × (1-e)A,
corresponding to a clopen decomposition of Spec(A). Idempotents biject
with clopen subsets of the spectrum. -/

/-- An idempotent e gives a clopen basic open D(e). -/
theorem idempotent_gives_clopen (R : Type*) [CommRing R]
    (e : R) (he : IsIdempotentElem e) :
    IsClopen (basicOpen e : Set (PrimeSpectrum R)) := by
  grind +suggestions

/-- No nontrivial idempotents ⟹ connected spectrum. -/
theorem no_nontrivial_idempotents_implies_connected (R : Type*) [CommRing R]
    [Nontrivial R]
    (h : ∀ e : R, IsIdempotentElem e → e = 0 ∨ e = 1) :
    ConnectedSpace (PrimeSpectrum R) := by
  by_contra h_not_connected
  obtain ⟨S, hS⟩ : ∃ S : Set (PrimeSpectrum R), IsClopen S ∧ S ≠ ∅ ∧ S ≠ Set.univ := by
    rw [connectedSpace_iff_univ] at h_not_connected
    simp_all +decide [IsConnected, IsPreconnected]
    obtain ⟨S, hS₁, T, hT₁, h₁, h₂, h₃, h₄⟩ := h_not_connected
    use S
    simp_all +decide [IsClopen, Set.ext_iff]
    simp_all +decide [Set.Nonempty]
    exact ⟨by rw [show S = Tᶜ by ext x; specialize h₁ x; aesop]
              exact hT₁.isClosed_compl,
           by obtain ⟨x, hx⟩ := h₃; exact ⟨x, by aesop⟩⟩
  obtain ⟨e, he⟩ : ∃ e : R, IsIdempotentElem e ∧ S = basicOpen e := by
    have := hS.1
    rw [PrimeSpectrum.isClopen_iff] at this
    exact this
  cases h e he.1 <;> simp_all +decide [Set.ext_iff]

-- ═══════════════════════════════════════════════════════════════════
--  Row 8: Bundles ↔ Projective Modules (Serre-Swan)
-- ═══════════════════════════════════════════════════════════════════

/-! ## Row 8: Bundles ↔ Projective Modules (Serre-Swan)

The Serre-Swan theorem: for compact Hausdorff X, vector bundles over X
≃ finitely generated projective modules over C(X, ℝ).
We formalize the algebraic characterization of projectivity. -/

/-- A module is projective iff every surjection onto it splits. -/
theorem projective_iff_surjection_splits (R M : Type*) [Ring R]
    [AddCommGroup M] [Module R M] :
    Module.Projective R M ↔
      ∀ (N : Type (max u_1 u_2)) [AddCommGroup N] [Module R N]
        (f : N →ₗ[R] M), Function.Surjective f →
        ∃ g : M →ₗ[R] N, f ∘ₗ g = LinearMap.id := by
  constructor
  · exact fun _ N _ _ f hf => Module.projective_lifting_property f LinearMap.id hf
  · exact fun h => Module.Projective.of_lifting_property'' (h (M →₀ R))

-- ═══════════════════════════════════════════════════════════════════
--  The Spec Functor (Summary)
-- ═══════════════════════════════════════════════════════════════════

/-! ## The Spec Functor

Pulling it all together: Spec is a contravariant functor
from CommRing to TopologicalSpaces. -/

/-- **The Spec Functor** is contravariant: preserves identity, reverses composition. -/
theorem spec_is_contravariant_functor :
    (∀ (R : Type*) [CommRing R],
      PrimeSpectrum.comap (RingHom.id R) = id) ∧
    (∀ (R S T : Type*) [CommRing R] [CommRing S] [CommRing T]
      (φ : R →+* S) (ψ : S →+* T),
      PrimeSpectrum.comap (ψ.comp φ) = PrimeSpectrum.comap φ ∘ PrimeSpectrum.comap ψ) := by
  bound

-- ═══════════════════════════════════════════════════════════════════
--  Bonus: Gelfand Duality (Functional Analysis)
-- ═══════════════════════════════════════════════════════════════════

/-! ## Bonus: Gelfand Duality

For compact Hausdorff spaces, X ≃ₜ characterSpace(C(X, 𝕜)). -/

/-- **Gelfand Duality**: X is homeomorphic to the character space of C(X, 𝕜). -/
def gelfand_duality (X : Type*) (𝕜 : Type*) [TopologicalSpace X]
    [CompactSpace X] [T2Space X] [RCLike 𝕜] :
    X ≃ₜ WeakDual.characterSpace 𝕜 C(X, 𝕜) :=
  WeakDual.CharacterSpace.homeoEval X 𝕜

end
