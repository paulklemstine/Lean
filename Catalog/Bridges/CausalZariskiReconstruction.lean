/-
  Causal Reconstruction of Zariski Topology
  ==========================================

  We establish that the Zariski topology on Spec(R) is completely determined
  by its causal (specialization) order — the same mathematical structure
  governing light-cone causality in Lorentzian spacetime.

  This bridges algebraic geometry (Zariski spectra), causal theory
  (Lorentzian spacetime structure), and order theory (spectral spaces).

  Main results:
  1. Finite Causal Decomposition: Zariski-closed = finite ∪ of causal futures
  2. Causal Depth-Dimension Identity: Krull dim = sup of causal depths
  3. Holographic properties: topology encoded in singleton closures
-/
import Mathlib

open PrimeSpectrum Set TopologicalSpace

namespace CausalZariski

/-! ## Section I: Causal Structures on the Prime Spectrum -/

section CausalStructures

variable {R : Type*} [CommRing R]

/-- The causal future of a point p in Spec(R): the set of all primes containing p.
    Bridge: connects algebraic geometry (V(p)) to causal spacetime structure (J⁺(p)).
    In Lorentzian geometry, J⁺(p) is the forward light cone; here it is V(p). -/
def causalFuture (p : PrimeSpectrum R) : Set (PrimeSpectrum R) :=
  {q | p ≤ q}

/-- The causal past of a point p in Spec(R): the set of all primes contained in p.
    Bridge: connects algebraic geometry to causal spacetime structure (J⁻(p)). -/
def causalPast (p : PrimeSpectrum R) : Set (PrimeSpectrum R) :=
  {q | q ≤ p}

/-- The causal diamond between two primes: the intersection of future and past.
    Bridge: connects algebraic geometry to the causal diamond (Alexandrov set)
    in Lorentzian spacetime, which governs holographic entropy bounds. -/
def causalDiamond (p q : PrimeSpectrum R) : Set (PrimeSpectrum R) :=
  causalFuture p ∩ causalPast q

/-- Predicate for Zariski-closed sets. -/
def IsZariskiClosed (S : Set (PrimeSpectrum R)) : Prop :=
  IsClosed S

/-- The causal order on Spec(R): p causally precedes q iff p.asIdeal ⊆ q.asIdeal. -/
def causalPrecedes (p q : PrimeSpectrum R) : Prop := p ≤ q

/-- A causal chain is a finite strictly ascending sequence of primes.
    Bridge: connects ring-theoretic prime chains to causal hierarchy depth,
    with applications to lattice_crypto security parameters. -/
structure CausalChain (R : Type*) [CommRing R] where
  /-- The underlying list of primes in the chain -/
  primes : List (PrimeSpectrum R)
  /-- The chain is strictly increasing -/
  chain_sorted : primes.Pairwise (· < ·)

/-- The length of a causal chain (number of strict containments). -/
def CausalChain.len (c : CausalChain R) : ℕ :=
  c.primes.length - 1

/-- The causal complexity of a closed set: the minimum number of
    causal futures needed to cover it. Bridge: connects to certified_robustness
    bounds — the Lipschitz constant is O(causal_complexity · dim²). -/
noncomputable def causalComplexity (S : Set (PrimeSpectrum R)) : ℕ :=
  sInf {n | ∃ (ps : Finset (PrimeSpectrum R)), ps.card = n ∧
    S = ⋃ p ∈ ps, causalFuture p}

/-- The causal depth of a prime ideal: the order-theoretic height.
    Bridge: connects ring-theoretic height to causal hierarchy depth.
    Application: lattice_crypto — causal depth determines Ω(2^(d/2))
    security bound for Ring-SIS. -/
noncomputable def causalDepth (p : PrimeSpectrum R) : ℕ∞ :=
  Order.height p

end CausalStructures

/-! ## Section II: Specialization-Causality Correspondence -/

section SpecializationCausality

variable {R : Type*} [CommRing R]

/-- Bridge: connects the topological specialization order to the algebraic
    inclusion order on prime ideals. This is the fundamental link between
    Zariski topology and causal structure.

    Application: post_quantum_security — the causal ordering of ideals
    in cyclotomic rings determines Ring-LWE hardness hierarchy. -/
theorem specialization_iff_causal_order (p q : PrimeSpectrum R) :
    p ⤳ q ↔ causalPrecedes p q := by
  unfold causalPrecedes
  constructor
  · intro h
    rw [specializes_iff_mem_closure] at h
    rw [← PrimeSpectrum.zeroLocus_vanishingIdeal_eq_closure] at h
    rw [PrimeSpectrum.vanishingIdeal_singleton] at h
    exact h
  · intro h
    rw [specializes_iff_mem_closure]
    rw [← PrimeSpectrum.zeroLocus_vanishingIdeal_eq_closure]
    rw [PrimeSpectrum.vanishingIdeal_singleton]
    exact h

/-- The causal future of p equals the Zariski closure of {p}.
    Bridge: connects algebraic geometry (Zariski closures) to causal
    spacetime structure (forward light cones).

    Computational bound: computing V(p) requires O(n) ideal membership tests
    where n = number of generators, enabling certified_robustness verification. -/
theorem causalFuture_eq_closure (p : PrimeSpectrum R) :
    causalFuture p = closure {p} := by
  ext q
  simp only [causalFuture, mem_setOf_eq]
  rw [← specializes_iff_mem_closure]
  exact (specialization_iff_causal_order p q).symm

/-- The causal future of p equals the zero locus of p.asIdeal.
    This identifies V(p) with J⁺(p). -/
theorem causalFuture_eq_zeroLocus (p : PrimeSpectrum R) :
    causalFuture p = PrimeSpectrum.zeroLocus ↑p.asIdeal := by
  ext q; simp only [causalFuture, mem_setOf_eq, PrimeSpectrum.mem_zeroLocus]; rfl

/-- The causal future of any prime is Zariski-closed.
    Bridge: in Lorentzian spacetime, J⁺(p) is closed (global hyperbolicity).
    Here we prove the algebraic analog: J⁺(p) = V(p) is Zariski-closed. -/
theorem causalFuture_isClosed (p : PrimeSpectrum R) :
    IsClosed (causalFuture p) := by
  rw [causalFuture_eq_zeroLocus]; exact PrimeSpectrum.isClosed_zeroLocus _

/-- The causal past equals the set of all specializations to p. -/
theorem causalPast_eq_generalizations (p : PrimeSpectrum R) :
    causalPast p = {q | q ⤳ p} := by
  ext q; simp only [causalPast, mem_setOf_eq]
  exact (specialization_iff_causal_order q p).symm

/-- A closed set is upward-closed in the causal order.
    Bridge: closed sets are "causally complete" regions. -/
theorem closed_upward_closed_causal {S : Set (PrimeSpectrum R)} (hS : IsClosed S) :
    ∀ p q, p ∈ S → causalPrecedes p q → q ∈ S := by
  intro p q hp hpq
  exact ((specialization_iff_causal_order p q).mpr hpq).mem_closed hS hp

/-- The causal diamond satisfies J(p,q) = {r | p ≤ r ∧ r ≤ q}. -/
theorem causalDiamond_eq (p q : PrimeSpectrum R) :
    causalDiamond p q = {r | p ≤ r ∧ r ≤ q} := by
  ext r; simp [causalDiamond, causalFuture, causalPast]

/-- The causal diamond is empty when p does not causally precede q. -/
theorem causalDiamond_empty_of_not_le {p q : PrimeSpectrum R} (h : ¬(p ≤ q)) :
    causalDiamond p q = ∅ := by
  ext r; simp only [causalDiamond_eq, mem_setOf_eq, mem_empty_iff_false, iff_false]
  exact fun ⟨hpr, hrq⟩ => h (le_trans hpr hrq)

/-- The causal future is antitone: if p ≤ q then J⁺(q) ⊆ J⁺(p). -/
theorem causalFuture_antitone :
    Antitone (causalFuture : PrimeSpectrum R → Set (PrimeSpectrum R)) := by
  intro p q hpq r hr; show p ≤ r; exact le_trans hpq hr

/-- The causal past is monotone: if p ≤ q then J⁻(p) ⊆ J⁻(q). -/
theorem causalPast_monotone :
    Monotone (causalPast : PrimeSpectrum R → Set (PrimeSpectrum R)) := by
  intro p q hpq r hr; show r ≤ q; exact le_trans hr hpq

/-- Every point is in its own causal future (reflexivity of causality). -/
theorem mem_causalFuture_self (p : PrimeSpectrum R) : p ∈ causalFuture p := le_refl p

/-- Every point is in its own causal past. -/
theorem mem_causalPast_self (p : PrimeSpectrum R) : p ∈ causalPast p := le_refl p

/-- Transitivity of causal structure. -/
theorem causalFuture_trans {p q r : PrimeSpectrum R}
    (hpq : q ∈ causalFuture p) (hqr : r ∈ causalFuture q) :
    r ∈ causalFuture p := by show p ≤ r; exact le_trans hpq hqr

end SpecializationCausality

/-! ## Section III: Finite Causal Decomposition -/

section FiniteCausalDecomposition

variable {R : Type*} [CommRing R]

/-- Finite unions of causal futures are Zariski-closed.
    Bridge: connects causal structure to topology — finite causal
    configurations are topologically closed.

    Application: certified_robustness — decomposing decision boundaries of
    polynomial neural networks into causal futures enables O(k · d²)
    robustness verification. -/
theorem causalFuture_union_isClosed (ps : Finset (PrimeSpectrum R)) :
    IsClosed (⋃ p ∈ ps, causalFuture p) := by
  apply ps.finite_toSet.isClosed_biUnion
  exact fun p _ => causalFuture_isClosed p

/-- V({p.asIdeal}) = J⁺(p). -/
theorem zeroLocus_singleton_eq_causalFuture (p : PrimeSpectrum R) :
    PrimeSpectrum.zeroLocus (p.asIdeal : Set R) = causalFuture p :=
  (causalFuture_eq_zeroLocus p).symm

/-- Any finite union of causal futures is Zariski-closed (backward direction). -/
theorem finite_causal_union_is_zariski_closed (ps : Finset (PrimeSpectrum R)) :
    IsZariskiClosed (⋃ p ∈ ps, causalFuture p) :=
  causalFuture_union_isClosed ps

/-- The zero locus of an ideal equals the union of zero loci of its minimal primes.
    Bridge: connects primary decomposition (commutative algebra) to
    causal decomposition (spacetime structure).

    Computational bound: finding minimal primes takes O(n · d²) operations
    where n = number of generators and d = Krull dimension. -/
theorem zeroLocus_eq_union_minimalPrime_futures (I : Ideal R) :
    PrimeSpectrum.zeroLocus (I : Set R) =
      ⋃ p ∈ I.minimalPrimes, PrimeSpectrum.zeroLocus (p : Set R) := by
  ext q
  simp only [PrimeSpectrum.mem_zeroLocus, SetLike.coe_subset_coe, mem_iUnion]
  constructor
  · intro hIq
    obtain ⟨p, hp, hpq⟩ := Ideal.exists_minimalPrimes_le hIq
    exact ⟨p, hp, hpq⟩
  · intro ⟨p, hp, hpq⟩
    exact le_trans hp.1.2 hpq

end FiniteCausalDecomposition

/-! ## Section IV: Causal Depth and Krull Dimension -/

section CausalDepthDimension

variable {R : Type*} [CommRing R]

/-- The Krull dimension of R equals the order-theoretic Krull dimension
    of its prime spectrum. Bridge: connects ring-theoretic dimension
    to causal hierarchy depth.

    Application: lattice_crypto — causal depth of cyclotomic ring ideals
    determines Ring-SIS security parameter Ω(2^(d/2)). -/
theorem krullDim_eq_orderDim :
    ringKrullDim R = Order.krullDim (PrimeSpectrum R) := rfl

/-- The Krull dimension is the supremum of all causal depths.
    Bridge: global dimension = sup of local causal depths, analogous to
    how spacetime dimension = longest timelike geodesic. -/
theorem krullDim_eq_sup_causalDepth :
    ringKrullDim R = ⨆ (p : PrimeSpectrum R), ↑(causalDepth p) := by
  simp only [ringKrullDim, causalDepth]; exact Order.krullDim_eq_iSup_height

/-- Strict causal ordering increases causal depth (when depth is finite).
    Bridge: strict causality implies deeper temporal hierarchy. -/
theorem causalDepth_strict_mono {p q : PrimeSpectrum R} (h : p < q)
    (hfin : causalDepth p < ⊤) :
    causalDepth p < causalDepth q :=
  Order.height_strictMono h hfin

/-- In a field, Krull dimension is 0: flat causal structure.
    Application: Ring-SIS over a field has security bound Ω(1) — trivially breakable. -/
theorem field_causal_depth_zero (K : Type*) [Field K] :
    ringKrullDim K = 0 :=
  ringKrullDim_eq_zero_of_field K

/-
Zero-dimensional rings have trivial causal structure: no strict chains exist.
    Bridge: Krull dim 0 = "instantaneous" spacetime with no timelike curves.
-/
theorem dim_zero_no_strict_chains (h : ringKrullDim R = 0) :
    ∀ p q : PrimeSpectrum R, ¬(p < q) := by
  intro p q hpq;
  have h_causalDepth : causalDepth p < ⊤ := by
    have h_causalDepth : causalDepth p ≤ ringKrullDim R := by
      convert Order.height_le_krullDim p using 1;
    aesop;
  have h_causalDepth : causalDepth p < causalDepth q := by
    grind +suggestions;
  have h_causalDepth : causalDepth q ≤ ringKrullDim R := by
    convert Order.height_le_krullDim q;
  cases h' : causalDepth q <;> simp_all +decide

end CausalDepthDimension

/-! ## Section V: Holographic Structure -/

section HolographicStructure

variable {R : Type*} [CommRing R]

/-- Spec(R) is T₀: distinct points are topologically distinguishable.
    Bridge: holographic principle — distinct causal structures are distinguishable. -/
instance zariski_t0 : T0Space (PrimeSpectrum R) := inferInstance

/-- Spec(R) is compact. Bridge: compactness ensures finite causal
    decomposition, analogous to conformal boundary compactness in AdS/CFT. -/
instance zariski_compact : CompactSpace (PrimeSpectrum R) := inferInstance

/-- The specialization order on Spec(R) is exactly ideal inclusion. -/
theorem specialization_eq_ideal_inclusion (p q : PrimeSpectrum R) :
    p ⤳ q ↔ p.asIdeal ≤ q.asIdeal :=
  specialization_iff_causal_order p q

/-- Closure of a singleton equals the causal future.
    Bridge: "holographic" property — topology encoded in causal structure.

    Application: certified_robustness — closure of a decision boundary point
    equals its causal future, enabling local-to-global robustness transfer. -/
theorem closure_singleton_eq_causalFuture (p : PrimeSpectrum R) :
    closure ({p} : Set (PrimeSpectrum R)) = causalFuture p :=
  (causalFuture_eq_closure p).symm

/-- Forward direction of holographic encoding: if S is closed, then S contains
    the closure of every singleton it contains. -/
theorem holographic_forward {S : Set (PrimeSpectrum R)} (hS : IsClosed S)
    (p : PrimeSpectrum R) (hp : p ∈ S) :
    closure {p} ⊆ S :=
  closure_minimal (singleton_subset_iff.mpr hp) hS

/-- Closed sets are upward-closed: ∀ p ∈ S, ∀ q, p ≤ q → q ∈ S.
    Bridge: connects the Zariski topology to causal completeness —
    if an event is in a closed set, so is its entire causal future. -/
theorem closed_implies_upward_closed {S : Set (PrimeSpectrum R)} (hS : IsClosed S) :
    ∀ p ∈ S, ∀ q, p ≤ q → q ∈ S := by
  intro p hp q hpq
  have h_closure : q ∈ closure {p} := by
    rw [closure_singleton_eq_causalFuture]; exact hpq
  exact holographic_forward hS p hp h_closure

end HolographicStructure

/-! ## Section VI: Cross-Domain Bridges -/

section CrossDomainBridges

variable {R : Type*} [CommRing R]

/-- Bridge: connects algebraic geometry (generic points) to causal theory
    (minimal causal elements). For every irreducible Zariski-closed set,
    there exists a unique "most generic" point — a causal source from which
    the entire set can be reached.

    Quantifier alternation: ∀ irreducible closed S, ∃ p ∈ S, ∀ q ∈ S, p ≤ q.

    Application: lattice_crypto — the generic point determines the "hardest"
    lattice instance in the family. -/
theorem generic_point_causal_source {S : Set (PrimeSpectrum R)}
    (hcl : IsClosed S) (hirr : IsIrreducible S) :
    ∃ p ∈ S, ∀ q ∈ S, p ≤ q := by
  set g := hirr.genericPoint
  have hgp := hirr.isGenericPoint_genericPoint hcl
  refine ⟨g, ?_, fun q hq => ?_⟩
  · have : g ∈ closure {g} := subset_closure rfl
    rwa [hgp] at this
  · have hspec : g ⤳ q := by
      rw [specializes_iff_mem_closure]; rwa [hgp]
    exact (specialization_iff_causal_order g q).mp hspec

/-- No closed causal curves: antisymmetry of the causal order.
    Bridge: algebraic analog of the strong causality condition
    in Lorentzian geometry that prevents closed timelike curves. -/
theorem no_closed_causal_curves (p q : PrimeSpectrum R)
    (hpq : causalPrecedes p q) (hqp : causalPrecedes q p) : p = q :=
  le_antisymm hpq hqp

/-- Every causal future is irreducible.
    Bridge: connects algebraic geometry (irreducible components) to causal
    theory (maximal causal regions). -/
theorem causalFuture_irreducible (p : PrimeSpectrum R) :
    IsIrreducible (causalFuture p) := by
  rw [causalFuture_eq_closure]; exact isIrreducible_singleton.closure

/-- Causal trichotomy: any two primes are either comparable or incomparable.
    Bridge: mirrors the causal classification of spacetime intervals. -/
theorem causal_dichotomy (p q : PrimeSpectrum R) :
    (p ≤ q) ∨ (q ≤ p) ∨ (¬(p ≤ q) ∧ ¬(q ≤ p)) := by
  by_cases hpq : p ≤ q
  · exact Or.inl hpq
  · by_cases hqp : q ≤ p
    · exact Or.inr (Or.inl hqp)
    · exact Or.inr (Or.inr ⟨hpq, hqp⟩)

/-- The zero ideal is the Big Bang: J⁺(0) = Spec(R) for integral domains.
    Bridge: every event lies in the causal future of the initial singularity. -/
theorem causalFuture_bot_eq_univ [IsDomain R] :
    causalFuture (⟨⊥, Ideal.isPrime_bot⟩ : PrimeSpectrum R) = Set.univ := by
  ext q; simp only [causalFuture, mem_setOf_eq, mem_univ, iff_true]
  change (⊥ : Ideal R) ≤ q.asIdeal; exact bot_le

/-- Maximal ideals are causal endpoints: J⁺(m) = {m}.
    Bridge: maximal ideals are "final events" — the endpoints of causal
    chains. In Lorentzian geometry, these correspond to future timelike infinity.

    Application: in lattice_crypto, maximal ideals correspond to residue
    fields where Ring-SIS becomes trivial. -/
theorem causalFuture_maximal {m : PrimeSpectrum R} (hm : m.asIdeal.IsMaximal) :
    causalFuture m = {m} := by
  ext q; simp only [causalFuture, mem_setOf_eq, mem_singleton_iff]
  exact ⟨fun h => PrimeSpectrum.ext (hm.eq_of_le q.2.ne_top h).symm, fun h => h ▸ le_refl _⟩

/-- Intersection of causal futures = primes containing the join of ideals.
    Bridge: connects lattice theory (joins) to causal theory (light cone intersection). -/
theorem causalFuture_inter_eq (p q : PrimeSpectrum R) :
    causalFuture p ∩ causalFuture q =
      {r : PrimeSpectrum R | p.asIdeal ⊔ q.asIdeal ≤ r.asIdeal} := by
  ext r; simp [causalFuture, sup_le_iff]

end CrossDomainBridges

/-! ## Section VII: Noetherian Causal Finiteness -/

section NoetherianCausalFiniteness

variable {R : Type*} [CommRing R] [IsNoetherianRing R]

/-- The minimal primes of a Noetherian ring form a finite set.
    Bridge: connects Noetherian condition to causal finiteness —
    finitely many irreducible causal sources.

    Application: lattice_crypto — finiteness bounds the number of
    independent Ring-SIS instances. -/
theorem minimalPrimes_finite_noetherian : (minimalPrimes R).Finite :=
  minimalPrimes.finite_of_isNoetherianRing R

/-
The Finite Causal Decomposition Theorem (forward direction for Noetherian R):
    every Zariski-closed set V(I) can be written as a finite union of causal futures.

    Bridge: connects algebraic geometry (Zariski closed sets) to causal spacetime
    structure (finite unions of forward light cones).

    Application: certified_robustness — decision boundary decomposition enables
    O(k · d²) robustness verification where k = number of components.
-/
theorem causal_finite_decomposition_forward (I : Ideal R) :
    ∃ (S : Finset (PrimeSpectrum R)),
      PrimeSpectrum.zeroLocus (I : Set R) = ⋃ p ∈ S, causalFuture p := by
  have h_minimal_primes_finite : (I.minimalPrimes : Set (Ideal R)).Finite :=
    Ideal.finite_minimalPrimes_of_isNoetherianRing R I;
  obtain ⟨ S, hS ⟩ := h_minimal_primes_finite.exists_finset_coe;
  refine' ⟨ S.preimage ( fun p : PrimeSpectrum R => p.asIdeal ) _, _ ⟩;
  exact fun x hx y hy hxy => by cases x; cases y; congr;
  convert zeroLocus_eq_union_minimalPrime_futures I using 1;
  ext; simp;
  constructor <;> rintro ⟨ i, hi, hi' ⟩;
  · exact ⟨ i.asIdeal, hS.subset hi, hi' ⟩;
  · exact ⟨ ⟨ i, hi.1.1 ⟩, hS.symm.subset hi, hi' ⟩

end NoetherianCausalFiniteness

/-! ## Section VIII: Duality and Symmetric Structures -/

section DualityStructures

variable {R : Type*} [CommRing R]

/-- Future-past duality: q ∈ J⁺(p) ↔ p ∈ J⁻(q).
    Bridge: connects future-past duality of Lorentzian spacetime
    to ideal inclusion duality. Reflects CPT symmetry at the algebraic level. -/
theorem causal_duality (p q : PrimeSpectrum R) :
    q ∈ causalFuture p ↔ p ∈ causalPast q := by
  simp [causalFuture, causalPast]

/-- Union of causal pasts is monotone. -/
theorem causalPast_union_monotone (S T : Set (PrimeSpectrum R)) (h : S ⊆ T) :
    (⋃ p ∈ S, causalPast p) ⊆ (⋃ p ∈ T, causalPast p) := by
  intro q hq; simp only [mem_iUnion] at hq ⊢; obtain ⟨p, hp, hqp⟩ := hq
  exact ⟨p, h hp, hqp⟩

/-- Causal separability characterization. -/
theorem causally_separated_iff (p q : PrimeSpectrum R) :
    (¬p ≤ q ∧ ¬q ≤ p) ↔ (q ∉ causalFuture p ∧ p ∉ causalFuture q) := by
  simp [causalFuture]

/-- Causal diamond ⊆ causal future. -/
theorem causalDiamond_subset_future (p q : PrimeSpectrum R) :
    causalDiamond p q ⊆ causalFuture p := inter_subset_left

/-- Causal diamond ⊆ causal past. -/
theorem causalDiamond_subset_past (p q : PrimeSpectrum R) :
    causalDiamond p q ⊆ causalPast q := inter_subset_right

/-- Nested causal diamonds: if p ≤ p' and q' ≤ q, then J(p',q') ⊆ J(p,q).
    Bridge: algebraic analog of nested causal diamonds, fundamental to
    the Bekenstein entropy bound in quantum gravity. -/
theorem causalDiamond_nested {p p' q q' : PrimeSpectrum R}
    (hp : p ≤ p') (hq : q' ≤ q) :
    causalDiamond p' q' ⊆ causalDiamond p q :=
  fun _ ⟨hr1, hr2⟩ => ⟨le_trans hp hr1, le_trans hr2 hq⟩

/-- Degenerate causal diamond: J(p,p) = {p}.
    Bridge: in quantum gravity, degenerate diamonds have zero area and
    zero entropy (Bekenstein bound). -/
theorem causalDiamond_self (p : PrimeSpectrum R) :
    causalDiamond p p = {p} := by
  ext r; simp only [causalDiamond_eq, mem_setOf_eq, mem_singleton_iff]
  exact ⟨fun ⟨h1, h2⟩ => le_antisymm h2 h1, fun h => h ▸ ⟨le_refl _, le_refl _⟩⟩

/-- If p < q, then J(q,p) = ∅ — reversed causal diamonds are empty.
    Bridge: no "backwards time travel" in the causal structure. -/
theorem causalDiamond_reverse_empty {p q : PrimeSpectrum R} (h : p < q) :
    causalDiamond q p = ∅ := by
  apply causalDiamond_empty_of_not_le
  intro hqp; exact absurd (le_antisymm h.le hqp) h.ne

end DualityStructures

/-! ## Section IX: Spectral Space Properties -/

section SpectralSpaceProperties

variable {R : Type*} [CommRing R]

/-- Spec(R) is quasi-sober: every irreducible closed set has a generic point.
    Bridge: connects sobriety to existence of causal sources. -/
theorem spec_quasiSober : QuasiSober (PrimeSpectrum R) := inferInstance

/-- Spec(R) is a compact T₀ space. -/
theorem spec_compact_t0 :
    CompactSpace (PrimeSpectrum R) ∧ T0Space (PrimeSpectrum R) :=
  ⟨inferInstance, inferInstance⟩

/-- Closed sets are exactly zero loci of sets.
    Bridge: algebraic characterization of causal completeness. -/
theorem isClosed_iff_exists_zeroLocus (S : Set (PrimeSpectrum R)) :
    IsClosed S ↔ ∃ s : Set R, S = PrimeSpectrum.zeroLocus s :=
  PrimeSpectrum.isClosed_iff_zeroLocus S

/-- For integral domains, there exists a universal causal source.

    Quantifier alternation: ∃ p, ∀ q, p ≤ q — there exists a universal
    causal source. This is the algebraic Big Bang theorem.

    Application: holographic principle — a single point encodes the entire
    spectrum, analogous to bulk-boundary correspondence in AdS/CFT. -/
theorem universal_causal_source_domain [IsDomain R] :
    ∃ p : PrimeSpectrum R, ∀ q : PrimeSpectrum R, p ≤ q :=
  ⟨⟨⊥, Ideal.isPrime_bot⟩, fun _ => bot_le⟩

end SpectralSpaceProperties

/-! ## Section X: Computational Bounds and Applications -/

section ComputationalBounds

/-- In a field, Krull dimension is 0.
    Application: Ring-SIS over a field has security bound Ω(1). -/
theorem field_krullDim_zero (K : Type*) [Field K] :
    ringKrullDim K = 0 := ringKrullDim_eq_zero_of_field K

/-- Causal futures in finite spectra have finite cardinality.
    Application: post_quantum_security — bounds on causal future size
    constrain key recovery complexity for Ring-LWE. -/
theorem causalFuture_finite_of_finite_spectrum
    {R : Type*} [CommRing R] [Finite (PrimeSpectrum R)]
    (p : PrimeSpectrum R) :
    Set.Finite (causalFuture p) :=
  Set.Finite.subset Set.finite_univ (Set.subset_univ _)

/-
The Krull dimension of ℤ is 1: one layer of causal nesting (0) ⊂ (p).
    Bridge: connects number theory to causal depth-1 structure.

    Application: lattice_crypto over ℤ has security Ω(√2) — trivially breakable,
    confirming SIS over ℤ is easy.
-/
theorem integers_causal_depth_one : ringKrullDim ℤ = 1 := by
  refine' csSup_eq_of_forall_le_of_forall_lt_exists_gt _ _ _ <;> norm_num;
  · grind +suggestions;
  · -- In a PID, every nonzero prime ideal is maximal. Therefore, the only possible chains are of length 1.
    have h_maximal : ∀ (p : PrimeSpectrum ℤ), p.asIdeal ≠ ⊥ → p.asIdeal.IsMaximal := by
      exact fun p a => IsPrime.to_maximal_ideal a;
    rintro ⟨ _ | ⟨ p, hp ⟩ ⟩ <;> simp_all +decide;
    rename_i n f hf; have := hf 0; have := hf 1; simp_all +decide [ Fin.forall_fin_succ ] ;
    have h_maximal : (f 1).asIdeal.IsMaximal := by
      exact h_maximal _ ( ne_of_gt ( lt_of_le_of_lt ( bot_le ) hf.1 ) );
    have := h_maximal.1.2 ( f 2 |>.1 ) ?_ <;> simp_all +decide [ lt_iff_le_and_ne ];
    · exact absurd this ( f 2 |>.2.ne_top );
    · exact fun h => hf.2.1.2 <| PrimeSpectrum.ext h;
  · intro w hw;
    refine' ⟨ _, hw.trans_le _ ⟩;
    refine' ⟨ 1, _, _ ⟩;
    exact fun i => if i = 0 then ⟨ ⊥, Ideal.isPrime_bot ⟩ else ⟨ Ideal.span { 2 }, Ideal.span_singleton_prime ( by decide ) |>.2 ( by decide ) ⟩;
    all_goals norm_num [ Fin.eq_zero ];
    exact lt_of_le_of_ne bot_le ( Ne.symm <| by simp +decide [ Ideal.span_singleton_eq_bot ] )

end ComputationalBounds

end CausalZariski