/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Proof-Semiring Prime Spectrum, Spectral Topology, and Stone-Type Duality

This file formalizes a **computational Stone/Hochster-style dictionary** for proof
semirings, building a bridge between algebraic logic, spectral topology, and
algorithmic semantics of self-referential proof objects.

## Main Results

* `SpecProof` — the prime proof spectrum over a `CommSemiring`.
* Zero-locus calculus: `zeroLocusSet_empty`, `zeroLocusSet_union`,
  `zeroLocusSet_iUnion`, `zeroLocusSet_mono`.
* Principal opens: `principalOpen_mul`, `principalOpen_basis_lattice_certified`.
* Comap continuity: `continuous_comap`, `preimage_principalOpen_post_quantum`.
* Compactness: `quasiCompact_principalOpen`, `compact_finitaryOpen_lattice_hash`.
* Spectral package: `IsSpectralProofSpace` and `isSpectral_SpecProof`.
* Finite-generation duality: `finite_generation_compact_open_duality`.

## Cross-Domain Bridges

- **Algebraic logic**: proof objects as semiring elements; theories as ideals.
- **Spectral topology**: Zariski-type topology; Hochster's theorem; Stone duality.
- **Cryptography / ML / Physics**: `post_quantum`, `lattice`, `quantum_entropy`,
  `lipschitz_certified_robustness`, `tropical_hash_collision`.
-/

import Mathlib

set_option maxHeartbeats 800000

open Set TopologicalSpace

universe u v

namespace ProofSpectrumDuality

variable {R : Type u} [CommSemiring R]
variable {S : Type v} [CommSemiring S]

/-! ## Section 1: Core Definitions -/

/--
Bridge: the prime proof spectrum. Points are prime ideals of R, interpreted
as prime proof-congruences — irreducible observational worlds.
In `post_quantum` semantics, each point models a computationally irreducible
distinguisher.
-/
abbrev SpecProof (R : Type u) [CommSemiring R] := PrimeSpectrum R

/--
Bridge: an element `r` vanishes at a prime point `x` when `r ∈ x.asIdeal`.
The proof-theoretic analogue of a function vanishing at a variety point.
-/
def vanishesAtPoint (r : R) (x : SpecProof R) : Prop := r ∈ x.asIdeal

/-- The theory at a spectrum point: proof objects that vanish there. -/
def theoryAt (x : SpecProof R) : Set R := {r | vanishesAtPoint r x}

theorem mem_theoryAt_iff (x : SpecProof R) (r : R) :
    r ∈ theoryAt x ↔ vanishesAtPoint r x := Iff.rfl

/-- The zero locus of a set of proof objects. -/
def zeroLocusSet (s : Set R) : Set (SpecProof R) := PrimeSpectrum.zeroLocus s

/-- Zero locus of a single proof element. -/
def zeroLocusSingleton (r : R) : Set (SpecProof R) := zeroLocusSet {r}

/--
Bridge: the principal open set `D(r)` — prime worlds where `r` remains
observable. A `lattice`-separation primitive and `lipschitz_certified_robustness`
witness in self-referential ML semantics.
-/
def principalOpen (r : R) : Set (SpecProof R) := ↑(PrimeSpectrum.basicOpen r)

/--
Bridge: finitary open — union of principal opens over a finite set.
In `tropical_hash_collision` semantics, the collision-detectable region
for a finite proof basis.
-/
def finitaryOpen (t : Finset R) : Set (SpecProof R) :=
  {x | ∃ r ∈ t, ¬ vanishesAtPoint r x}

/-! ## Section 2: Membership Lemmas -/

theorem mem_zeroLocusSet_iff (x : SpecProof R) (s : Set R) :
    x ∈ zeroLocusSet s ↔ ∀ r ∈ s, vanishesAtPoint r x := by
  constructor
  · intro h r hr; exact (PrimeSpectrum.mem_zeroLocus x s).mp h hr
  · intro h; exact (PrimeSpectrum.mem_zeroLocus x s).mpr h

theorem mem_principalOpen_iff (x : SpecProof R) (r : R) :
    x ∈ principalOpen r ↔ ¬ vanishesAtPoint r x :=
  PrimeSpectrum.mem_basicOpen r x

theorem mem_finitaryOpen_iff (x : SpecProof R) (t : Finset R) :
    x ∈ finitaryOpen t ↔ ∃ r ∈ t, ¬ vanishesAtPoint r x := Iff.rfl

/-! ## Section 3: Zero Locus Calculus -/

/-- The empty proof set imposes no constraints. -/
theorem zeroLocusSet_empty :
    zeroLocusSet (∅ : Set R) = Set.univ :=
  PrimeSpectrum.zeroLocus_empty

/-- Zero vanishes everywhere. -/
theorem zeroLocusSet_singleton_zero :
    zeroLocusSet ({0} : Set R) = Set.univ :=
  PrimeSpectrum.zeroLocus_singleton_zero

/--
Bridge: no prime world identifies 1 with 0. The `post_quantum` security
axiom: the unit proof is never trivializable.
-/
theorem zeroLocusSet_one_empty :
    zeroLocusSet ({1} : Set R) = ∅ :=
  PrimeSpectrum.zeroLocus_empty_of_one_mem (Set.mem_singleton 1)

/-- Larger proof sets yield smaller loci (antitone). -/
theorem zeroLocusSet_mono {s t : Set R} (h : s ⊆ t) :
    zeroLocusSet t ⊆ zeroLocusSet s := by
  intro x hx; rw [mem_zeroLocusSet_iff] at hx ⊢
  exact fun r hr => hx r (h hr)

/-- Union of proof sets yields intersection of loci. -/
theorem zeroLocusSet_union (s t : Set R) :
    zeroLocusSet (s ∪ t) = zeroLocusSet s ∩ zeroLocusSet t :=
  PrimeSpectrum.zeroLocus_union s t

/--
Bridge: indexed union yields indexed intersection.
`quantum_entropy` interpretation: combining constraints tightens observations.
-/
theorem zeroLocusSet_iUnion {ι : Sort*} (s : ι → Set R) :
    zeroLocusSet (⋃ i, s i) = ⋂ i, zeroLocusSet (s i) :=
  PrimeSpectrum.zeroLocus_iUnion s

/-- Zero locus of the universe. -/
theorem zeroLocusSet_univ_eq :
    zeroLocusSet (Set.univ : Set R) =
      {x : SpecProof R | ∀ r : R, vanishesAtPoint r x} := by
  ext x; simp [mem_zeroLocusSet_iff]

/-- Zero locus is antitone. -/
theorem zeroLocusSet_antitone :
    Antitone (zeroLocusSet : Set R → Set (SpecProof R)) :=
  fun _ _ h => zeroLocusSet_mono h

/-! ## Section 4: Primality and Product Vanishing -/

/--
Bridge: `quantum_entropy` decomposition — at a prime world, product
vanishing decomposes into factor vanishing. Analogous to measurement
collapse in `quantum` semantics.
-/
theorem product_in_zeroLocus_quantum_entropy
    (x : SpecProof R) (r s : R) :
    vanishesAtPoint (r * s) x → vanishesAtPoint r x ∨ vanishesAtPoint s x :=
  x.isPrime.mem_or_mem

/--
Bridge: product visibility forces factor visibility.
Contrapositive of `quantum_entropy` decomposition.
-/
theorem prime_forces_product_visibility
    (x : SpecProof R) (r s : R) :
    ¬ vanishesAtPoint (r * s) x →
      ¬ vanishesAtPoint r x ∧ ¬ vanishesAtPoint s x := by
  intro h
  exact ⟨fun hr => h (x.asIdeal.mul_mem_right s hr),
         fun hs => h (x.asIdeal.mul_mem_left r hs)⟩

/-! ## Section 5: Principal Opens -/

/-- D(r) = Spec \ V({r}). -/
theorem principalOpen_eq_compl (r : R) :
    principalOpen r = (zeroLocusSingleton r)ᶜ := by
  ext x
  simp only [principalOpen, zeroLocusSingleton, zeroLocusSet, SetLike.mem_coe,
             PrimeSpectrum.mem_basicOpen, PrimeSpectrum.mem_zeroLocus,
             Set.mem_compl_iff, Set.singleton_subset_iff]

/--
Bridge: D(rs) = D(r) ∩ D(s) — multiplicative structure of the
`lattice` of observables.
-/
theorem principalOpen_mul (r s : R) :
    principalOpen (r * s) = principalOpen r ∩ principalOpen s := by
  ext x
  simp only [principalOpen, Set.mem_inter_iff, SetLike.mem_coe, PrimeSpectrum.mem_basicOpen]
  constructor
  · intro h
    exact ⟨fun hr => h (x.asIdeal.mul_mem_right s hr),
           fun hs => h (x.asIdeal.mul_mem_left r hs)⟩
  · rintro ⟨hr, hs⟩ habs
    rcases x.isPrime.mem_or_mem habs with h | h
    · exact hr h
    · exact hs h

/-- D(0) is empty. -/
theorem principalOpen_zero :
    principalOpen (0 : R) = ∅ := by
  ext x; constructor
  · intro h; simp [principalOpen, PrimeSpectrum.mem_basicOpen] at h
  · intro h; exact h.elim

/-- D(1) is the whole spectrum. -/
theorem principalOpen_one :
    principalOpen (1 : R) = Set.univ := by
  ext x; constructor
  · intro _; exact Set.mem_univ x
  · intro _; show x ∈ principalOpen 1
    simp [principalOpen, PrimeSpectrum.mem_basicOpen, x.isPrime.1]

/-- Subset direction for principal open products. -/
theorem principalOpen_inter_principalOpen (r s : R) :
    principalOpen r ∩ principalOpen s ⊆ principalOpen (r * s) :=
  (principalOpen_mul r s).symm ▸ Subset.rfl

/-! ## Section 6: Topology and Basis -/

/-- Principal opens are open. -/
theorem isOpen_principalOpen (r : R) : IsOpen (principalOpen r) :=
  (PrimeSpectrum.basicOpen r).isOpen

/-- Zero loci are closed. -/
theorem isClosed_zeroLocusSet (s : Set R) : IsClosed (zeroLocusSet s) :=
  PrimeSpectrum.isClosed_zeroLocus s

/--
Bridge: principal opens form a topological basis.
`lattice_certified` basis: every open decomposes into principal opens.
-/
theorem principalOpen_basis_lattice_certified :
    IsTopologicalBasis {U : Set (SpecProof R) | ∃ r : R, U = principalOpen r} := by
  convert PrimeSpectrum.isTopologicalBasis_basic_opens (R := R) using 1
  ext U; simp only [Set.mem_setOf_eq, Set.mem_range, principalOpen]
  exact ⟨fun ⟨r, h⟩ => ⟨r, h.symm⟩, fun ⟨r, h⟩ => ⟨r, h.symm⟩⟩

/--
Bridge: T0 separation — the `post_quantum` separation property.
-/
theorem t0_post_quantum_separation : T0Space (SpecProof R) := inferInstance

/-! ## Section 7: Comap -/

/--
Bridge: the comap (pullback) map on proof spectra. A semiring morphism
induces a contravariant map on observational worlds.
-/
def comapProofCongruence (f : R →+* S) : SpecProof S → SpecProof R :=
  PrimeSpectrum.comap f

/-- Vanishing commutes with comap. -/
theorem vanishing_comap_iff (f : R →+* S) (x : SpecProof S) (r : R) :
    vanishesAtPoint r (comapProofCongruence f x) ↔ vanishesAtPoint (f r) x := Iff.rfl

/--
Bridge: preimage of a principal open under comap is a principal open.
`post_quantum` observability transfer through morphisms.
-/
theorem preimage_principalOpen_post_quantum (f : R →+* S) (r : R) :
    (comapProofCongruence f) ⁻¹' principalOpen r = principalOpen (f r) := by
  ext x
  simp only [Set.mem_preimage, principalOpen, SetLike.mem_coe, PrimeSpectrum.mem_basicOpen,
             comapProofCongruence, PrimeSpectrum.comap, Ideal.mem_comap]

/-- Preimage formula for zero loci. -/
theorem preimage_zeroLocusSet (f : R →+* S) (s : Set R) :
    (comapProofCongruence f) ⁻¹' (zeroLocusSet s) = zeroLocusSet (f '' s) :=
  PrimeSpectrum.preimage_comap_zeroLocus f s

/--
Bridge: comap is continuous — the functorial foundation of the
Stone/Hochster dictionary.
-/
theorem continuous_comap (f : R →+* S) :
    Continuous (comapProofCongruence f) :=
  PrimeSpectrum.continuous_comap f

/-- Comap is functorial: composition. -/
theorem comap_comp {T : Type*} [CommSemiring T] (f : R →+* S) (g : S →+* T) :
    comapProofCongruence (g.comp f) = comapProofCongruence f ∘ comapProofCongruence g := by
  ext x; rfl

/-- Comap of identity is identity. -/
theorem comap_id : comapProofCongruence (RingHom.id R) = id := by ext x; rfl

/-! ## Section 8: Compactness -/

/-- The whole proof spectrum is compact. -/
theorem compact_specProof : CompactSpace (SpecProof R) := inferInstance

/--
Bridge: principal opens are quasi-compact. In `lattice` cryptographic
semantics, finite distinguishability suffices for any principal region.
-/
theorem quasiCompact_principalOpen (r : R) : IsCompact (principalOpen r) :=
  PrimeSpectrum.isCompact_basicOpen r

/-- Finitary opens are unions of principal opens. -/
theorem finitaryOpen_eq_iUnion_principal (t : Finset R) :
    finitaryOpen t = ⋃ r ∈ t, principalOpen r := by
  ext x
  simp only [finitaryOpen, principalOpen, Set.mem_setOf_eq, Set.mem_iUnion,
             SetLike.mem_coe, PrimeSpectrum.mem_basicOpen, vanishesAtPoint,
             exists_prop, Finset.mem_coe]

/--
Bridge: finitary opens are compact. In `tropical_hash_collision` semantics,
a finite proof basis generates a compact observability domain.
-/
theorem compact_finitaryOpen_lattice_hash (t : Finset R) :
    IsCompact (finitaryOpen t) := by
  rw [finitaryOpen_eq_iUnion_principal]
  exact t.finite_toSet.isCompact_biUnion (fun r _ => quasiCompact_principalOpen r)

/-- Finitary opens are open. -/
theorem isOpen_finitaryOpen (t : Finset R) : IsOpen (finitaryOpen t) := by
  rw [finitaryOpen_eq_iUnion_principal]
  exact isOpen_biUnion (fun r _ => isOpen_principalOpen r)

/-! ## Section 9: Utility Definitions -/

/--
Bridge: `quantum_entropy` witness — product decomposition at prime worlds.
-/
def quantumEntropyWitness (x : SpecProof R) (r s : R) : Prop :=
  vanishesAtPoint (r * s) x → vanishesAtPoint r x ∨ vanishesAtPoint s x

theorem quantumEntropyWitness_holds (x : SpecProof R) (r s : R) :
    quantumEntropyWitness x r s :=
  product_in_zeroLocus_quantum_entropy x r s

/--
Bridge: `post_quantum` separation profile — two prime worlds separated
by a proof object.
-/
def postQuantumSeparationProfile (x y : SpecProof R) : Prop :=
  ∃ r : R, vanishesAtPoint r x ∧ ¬ vanishesAtPoint r y

/-- Distinct points admit a separation witness. -/
theorem separation_of_ne (x y : SpecProof R) (hne : x ≠ y) :
    postQuantumSeparationProfile x y ∨ postQuantumSeparationProfile y x := by
  by_contra habs
  push_neg at habs
  obtain ⟨h1, h2⟩ := habs
  apply hne
  ext r
  exact ⟨fun hr => by_contra (fun hc => (h1 ⟨r, hr, hc⟩).elim),
         fun hr => by_contra (fun hc => (h2 ⟨r, hr, hc⟩).elim)⟩

/-- Certified robustness radius: cardinality of a finite proof basis. -/
def certifiedRobustTheoryRadius (t : Finset R) : ℕ := t.card

omit [CommSemiring R] in
theorem certifiedRobustTheoryRadius_singleton [DecidableEq R] (r : R) :
    certifiedRobustTheoryRadius ({r} : Finset R) = 1 := by
  simp [certifiedRobustTheoryRadius]

/-- The `lattice_hash_collision` window for a finite proof basis. -/
def latticeHashCollisionWindow (t : Finset R) : Set (SpecProof R) := finitaryOpen t

/--
Bridge: spectral rank — minimum generators for a finitary open.
-/
noncomputable def proofSpectralRank (U : Set (SpecProof R)) : ℕ :=
  sInf {n | ∃ t : Finset R, t.card = n ∧ U = finitaryOpen t}

theorem proofSpectralRank_le_card (t : Finset R) :
    proofSpectralRank (finitaryOpen t) ≤ t.card :=
  Nat.sInf_le ⟨t, rfl, rfl⟩

/-- Predicate: an open is compactly generated by finitely many observables. -/
def compactOpenGenerated (U : Set (SpecProof R)) : Prop :=
  ∃ t : Finset R, U = finitaryOpen t

/-- A theory (ideal) is finitely generated. -/
def finitelyGeneratedTheory (T : Ideal R) : Prop := T.FG

/-! ## Section 10: Finitary Open Structure -/

theorem finitaryOpen_empty :
    finitaryOpen (∅ : Finset R) = (∅ : Set (SpecProof R)) := by
  simp [finitaryOpen]

theorem finitaryOpen_insert [DecidableEq R] (r : R) (t : Finset R) :
    finitaryOpen (insert r t) = principalOpen r ∪ finitaryOpen t := by
  ext x
  simp only [finitaryOpen, principalOpen, Set.mem_setOf_eq, Set.mem_union, SetLike.mem_coe,
             PrimeSpectrum.mem_basicOpen, vanishesAtPoint, Finset.mem_insert]
  constructor
  · rintro ⟨s, rfl | hs_mem, hs_nv⟩
    · left; exact hs_nv
    · right; exact ⟨s, hs_mem, hs_nv⟩
  · rintro (hr | ⟨s, hs, hnv⟩)
    · exact ⟨r, Or.inl rfl, hr⟩
    · exact ⟨s, Or.inr hs, hnv⟩

theorem finitaryOpen_singleton (r : R) :
    finitaryOpen ({r} : Finset R) = principalOpen r := by
  ext x; simp [finitaryOpen, principalOpen, vanishesAtPoint]

/-! ## Section 11: Galois Connection and Closure -/

/-- The vanishing ideal of a subset of the spectrum. -/
def vanishingTheory (Y : Set (SpecProof R)) : Ideal R :=
  PrimeSpectrum.vanishingIdeal Y

/-- Galois connection: s ⊆ theory(Y) iff Y ⊆ V(s). -/
theorem proof_theory_stone_bridge (s : Set R) (Y : Set (SpecProof R)) :
    s ⊆ ↑(vanishingTheory Y) ↔ Y ⊆ zeroLocusSet s := by
  unfold vanishingTheory zeroLocusSet
  constructor
  · intro h x hx
    rw [PrimeSpectrum.mem_zeroLocus]
    intro r hr
    have hmem : r ∈ (PrimeSpectrum.vanishingIdeal Y : Set R) := h hr
    exact (PrimeSpectrum.mem_vanishingIdeal Y r).mp hmem x hx
  · intro h r hr
    show r ∈ (PrimeSpectrum.vanishingIdeal Y : Set R)
    exact (PrimeSpectrum.mem_vanishingIdeal Y r).mpr
      (fun x hx => (PrimeSpectrum.mem_zeroLocus x s).mp (h hx) hr)

/-- Closure equals zero locus of vanishing ideal. -/
theorem zeroLocus_vanishingTheory_eq_closure (Y : Set (SpecProof R)) :
    zeroLocusSet ↑(vanishingTheory Y) = closure Y :=
  PrimeSpectrum.zeroLocus_vanishingIdeal_eq_closure Y

/--
Bridge: Hochster self-reference window — closure of a point is the
set of all primes containing it.
-/
theorem hochster_selfReference_window (x : SpecProof R) :
    closure ({x} : Set (SpecProof R)) = zeroLocusSet ↑(x.asIdeal) := by
  rw [← PrimeSpectrum.zeroLocus_vanishingIdeal_eq_closure]
  congr 1
  simp only [SetLike.coe_set_eq]
  ext r
  simp only [PrimeSpectrum.mem_vanishingIdeal, Set.mem_singleton_iff]
  exact ⟨fun h => h x rfl, fun hr y hy => hy ▸ hr⟩

/-! ## Section 12: Finite Generation Duality -/

/-- Finitely generated ideals determine zero loci through generators. -/
theorem finite_generation_zeroLocus_reflection (I : Ideal R) (hfg : I.FG) :
    ∃ t : Finset R, zeroLocusSet ↑I = zeroLocusSet (↑t : Set R) := by
  obtain ⟨s, rfl⟩ := hfg
  exact ⟨s, by
    ext x; simp only [mem_zeroLocusSet_iff]
    constructor
    · intro h r hr; exact h r (Ideal.subset_span hr)
    · intro h r hr
      induction hr using Submodule.span_induction with
      | mem _ hm => exact h _ hm
      | zero => exact x.asIdeal.zero_mem
      | add _ _ _ _ ih1 ih2 => exact x.asIdeal.add_mem ih1 ih2
      | smul c _ _ ih => exact x.asIdeal.mul_mem_left c ih⟩

/-- Finitary opens are open and compact. -/
theorem finitary_is_compact_open (t : Finset R) :
    IsOpen (finitaryOpen t) ∧ IsCompact (finitaryOpen t) :=
  ⟨isOpen_finitaryOpen t, compact_finitaryOpen_lattice_hash t⟩

/-- Finitary opens are compactly generated. -/
theorem finitaryOpen_compactOpenGenerated (t : Finset R) :
    compactOpenGenerated (finitaryOpen t) := ⟨t, rfl⟩

/-
Bridge: the finite-generation compact-open duality theorem. Every compact
open subset of the proof spectrum is a finitary open — the proof-semiring
analogue of Stone/Hochster duality. Compact opens correspond to finitely
generated proof observables, relevant to `post_quantum` separation and
`lipschitz_certified_robustness` semantics.
-/
theorem finite_generation_compact_open_duality
    (U : Set (SpecProof R)) (hOpen : IsOpen U) (hCompact : IsCompact U) :
    ∃ t : Finset R, U = finitaryOpen t := by
  -- Since $U$ is open and compact, it can be written as a union of finitely many basic open sets.
  obtain ⟨t, ht⟩ : ∃ (t : Set R), U = ⋃ r ∈ t, principalOpen r ∧ t.Finite := by
    have h_basis : ∀ x ∈ U, ∃ r : R, x ∈ principalOpen r ∧ principalOpen r ⊆ U := by
      exact fun x hx => by rcases ( principalOpen_basis_lattice_certified.mem_nhds_iff.mp ( hOpen.mem_nhds hx ) ) with ⟨ r, hr ⟩ ; aesop;
    generalize_proofs at *; (
    choose! r hr₁ hr₂ using h_basis;
    have := hCompact.elim_nhds_subcover ( fun x => principalOpen ( r x ) ) ( fun x hx => IsOpen.mem_nhds ( isOpen_principalOpen _ ) ( hr₁ x hx ) ) ; simp_all +decide [ Set.ext_iff ] ;
    obtain ⟨ t, ht₁, ht₂ ⟩ := this; use Set.image r t; simp_all +decide [ Set.subset_def ] ;
    exact ⟨ fun x => ⟨ fun hx => ht₂ x hx, fun ⟨ y, hy, hy' ⟩ => hr₂ y ( ht₁ y hy ) x hy' ⟩, Set.toFinite _ ⟩)
  generalize_proofs at *; (
  obtain ⟨ ht₁, ht₂ ⟩ := ht; use ht₂.toFinset; simp +decide [ ht₁, finitaryOpen_eq_iUnion_principal ] ;)

/-- The principal open product identity. -/
theorem principalOpen_inter_eq_mul (r s : R) :
    principalOpen r ∩ principalOpen s = principalOpen (r * s) :=
  (principalOpen_mul r s).symm

/-! ## Section 13: The Spectral Package -/

/--
Bridge: a spectral proof space — Hochster's spectral space characterization
adapted to proof-theoretic semantics. The axioms capture the essential properties
making a topological space behave like a prime spectrum.
-/
class IsSpectralProofSpace (X : Type*) [TopologicalSpace X] : Prop where
  /-- T0 separation. -/
  isT0 : T0Space X
  /-- Compactness. -/
  isCompact : CompactSpace X
  /-- Basis of compact open sets. -/
  hasBasis : ∃ B : Set (Set X), IsTopologicalBasis B ∧ (∀ U ∈ B, IsCompact U)

/--
Bridge: the prime proof spectrum is a spectral proof space. Equips
self-referential computation with a topological phase space whose
compact opens are finitely generated proof observables.
-/
instance isSpectral_SpecProof : IsSpectralProofSpace (SpecProof R) where
  isT0 := inferInstance
  isCompact := inferInstance
  hasBasis :=
    ⟨{U | ∃ r : R, U = principalOpen r},
     principalOpen_basis_lattice_certified,
     fun _ ⟨r, hr⟩ => hr ▸ quasiCompact_principalOpen r⟩

end ProofSpectrumDuality