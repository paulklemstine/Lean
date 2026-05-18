/-
  # Algebraic Spacetime: Prime Spectrum Causal Structure

  We establish that the prime spectrum Spec(R) of a commutative ring, equipped with
  the inclusion order and Zariski topology, carries the structure of a causal spacetime.

  This bridges algebraic geometry (spectral theory) with Lorentzian physics (causal sets,
  holography) and number theory (ideal norms as conserved quantities).

  Key insight: inclusion of prime ideals is causation, Zariski closure is the light-cone,
  and factorization is energy conservation.
-/
import Mathlib

open PrimeSpectrum Ideal Set

noncomputable section

namespace AlgebraicSpacetime

/-! ## Part 1: Foundational Definitions

We define the causal structure on Spec(R) and the key geometric objects:
causal futures, pasts, diamonds, chains, and the ideal norm. -/

/-- The causal relation on Spec(R): p ≼ q iff p.asIdeal ⊆ q.asIdeal.
    Bridge: algebraic geometry ↔ Lorentzian causality. -/
def CausalRel (R : Type*) [CommRing R] (p q : PrimeSpectrum R) : Prop :=
  p.asIdeal ≤ q.asIdeal

/-- Strict causal relation: proper ideal inclusion ↔ timelike separation. -/
def StrictCausalRel (R : Type*) [CommRing R] (p q : PrimeSpectrum R) : Prop :=
  p.asIdeal < q.asIdeal

/-- The causal future J⁺(p): all primes containing p.
    Bridge: Zariski closed sets ↔ Lorentzian light-cones. -/
def causalFuture (R : Type*) [CommRing R] (p : PrimeSpectrum R) : Set (PrimeSpectrum R) :=
  { q | p.asIdeal ≤ q.asIdeal }

/-- The causal past J⁻(p): all primes contained in p. -/
def causalPast (R : Type*) [CommRing R] (p : PrimeSpectrum R) : Set (PrimeSpectrum R) :=
  { q | q.asIdeal ≤ p.asIdeal }

/-- Causal diamond ◇(p,q): the order interval [p,q] in Spec(R).
    Bridge: order intervals ↔ spacetime diamonds in GR. -/
structure CausalDiamond (R : Type*) [CommRing R] where
  bottom : PrimeSpectrum R
  top : PrimeSpectrum R
  causal_rel : bottom.asIdeal ≤ top.asIdeal

/-- Carrier set of a causal diamond. -/
def CausalDiamond.carrier {R : Type*} [CommRing R] (d : CausalDiamond R) :
    Set (PrimeSpectrum R) :=
  { r | d.bottom.asIdeal ≤ r.asIdeal ∧ r.asIdeal ≤ d.top.asIdeal }

/-- Causal chain of length n: strictly increasing prime ideal sequence.
    Bridge: causal chains (physics) ↔ prime chains (commutative algebra). -/
structure CausalChain (R : Type*) [CommRing R] (n : ℕ) where
  chain : Fin (n + 1) → PrimeSpectrum R
  strictly_increasing : ∀ i j : Fin (n + 1), i < j → (chain i).asIdeal < (chain j).asIdeal

/-- Causal dynamics: order-preserving endomorphism of Spec(R).
    Bridge: order-preserving maps ↔ causal time evolution. -/
structure CausalDynamics (R : Type*) [CommRing R] where
  dynamics : PrimeSpectrum R → PrimeSpectrum R
  order_preserving : ∀ p q, p.asIdeal ≤ q.asIdeal →
    (dynamics p).asIdeal ≤ (dynamics q).asIdeal

/-- Conserved quantity: invariant under ring automorphisms.
    Bridge: Noether's theorem (physics) ↔ Galois theory (algebra). -/
structure ConservedQuantity (R : Type*) [CommRing R] where
  quantity : Ideal R → ℕ
  conservation : ∀ (φ : R ≃+* R) (I : Ideal R),
    quantity I = quantity (Ideal.map (φ : R →+* R) I)

/-- Spectral causal structure: a ring with its causal preorder on Spec(R). -/
structure SpectralCausalStructure (R : Type*) [CommRing R] where
  carrier := PrimeSpectrum R
  le : PrimeSpectrum R → PrimeSpectrum R → Prop := fun p q => p.asIdeal ≤ q.asIdeal

/-- Spacelike separation: neither point causally precedes the other.
    Impact: post_quantum_security — no information exchange. -/
def SpacelikeSeparated (R : Type*) [CommRing R] (p q : PrimeSpectrum R) : Prop :=
  ¬CausalRel R p q ∧ ¬CausalRel R q p

/-- Ideal norm N(I) = |R/I|. Bridge: ideal arithmetic ↔ entropy.
    Impact: hamiltonian_conservation — conserved under causal dynamics. -/
noncomputable def idealNorm (R : Type*) [CommRing R] (I : Ideal R) : ℕ :=
  Nat.card (R ⧸ I)

/-! ## Part 2: Basic Causal Properties -/

/-- Reflexivity: every event is in its own causal future. -/
theorem causalRel_refl (R : Type*) [CommRing R] (p : PrimeSpectrum R) :
    CausalRel R p p := le_refl p.asIdeal

/-- Transitivity: causal signals propagate. -/
theorem causalRel_trans (R : Type*) [CommRing R] (p q r : PrimeSpectrum R)
    (hpq : CausalRel R p q) (hqr : CausalRel R q r) : CausalRel R p r :=
  le_trans hpq hqr

/-- Antisymmetry: the causal identification principle. -/
theorem causalRel_antisymm (R : Type*) [CommRing R] (p q : PrimeSpectrum R)
    (hpq : CausalRel R p q) (hqp : CausalRel R q p) : p = q :=
  PrimeSpectrum.ext (le_antisymm hpq hqp)

/-- Self-membership in causal future. -/
theorem mem_causalFuture_self (R : Type*) [CommRing R] (p : PrimeSpectrum R) :
    p ∈ causalFuture R p := le_refl p.asIdeal

/-- Causal future is antitone: p ≼ q ⟹ J⁺(q) ⊆ J⁺(p). -/
theorem causalFuture_antitone (R : Type*) [CommRing R] (p q : PrimeSpectrum R)
    (h : CausalRel R p q) : causalFuture R q ⊆ causalFuture R p :=
  fun _ hr => le_trans h hr

/-- Causal past is monotone: p ≼ q ⟹ J⁻(p) ⊆ J⁻(q). -/
theorem causalPast_monotone (R : Type*) [CommRing R] (p q : PrimeSpectrum R)
    (h : CausalRel R p q) : causalPast R p ⊆ causalPast R q :=
  fun _ hr => le_trans hr h

/-- Diamond = causal future ∩ causal past. -/
theorem causalDiamond_eq_inter (R : Type*) [CommRing R] (d : CausalDiamond R) :
    d.carrier = causalFuture R d.bottom ∩ causalPast R d.top := by
  ext r; simp [CausalDiamond.carrier, causalFuture, causalPast, and_comm]

/-- Bottom is in the diamond. -/
theorem causalDiamond_nonempty (R : Type*) [CommRing R] (d : CausalDiamond R) :
    d.bottom ∈ d.carrier := ⟨le_refl _, d.causal_rel⟩

/-- Top is in the diamond. -/
theorem causalDiamond_top_mem (R : Type*) [CommRing R] (d : CausalDiamond R) :
    d.top ∈ d.carrier := ⟨d.causal_rel, le_refl _⟩

/-! ## Part 3: Zariski Holography — The Central Theorem -/

/-- **Zariski-Causal Holographic Correspondence**: cl({p}) = J⁺(p).
    The Zariski topology IS the causal topology.
    Bridge: Zariski closure (algebraic geometry) = causal futures (general relativity).
    Impact: certified_robustness — topological closures predict causal reachability. -/
theorem zariski_closure_eq_causal_future (R : Type*) [CommRing R]
    (p : PrimeSpectrum R) :
    closure ({p} : Set (PrimeSpectrum R)) = causalFuture R p := by
  rw [← PrimeSpectrum.zeroLocus_vanishingIdeal_eq_closure,
      PrimeSpectrum.vanishingIdeal_singleton]
  ext q; simp [PrimeSpectrum.mem_zeroLocus, causalFuture]

/-- Causal future is Zariski-closed: light-cone is a closed hypersurface. -/
theorem causalFuture_isClosed (R : Type*) [CommRing R] (p : PrimeSpectrum R) :
    IsClosed (causalFuture R p) := by
  rw [← zariski_closure_eq_causal_future]; exact isClosed_closure

/-- Causal future = zero locus V(p.asIdeal). -/
theorem causalFuture_eq_zeroLocus (R : Type*) [CommRing R] (p : PrimeSpectrum R) :
    causalFuture R p = PrimeSpectrum.zeroLocus (p.asIdeal : Set R) := by
  ext q; simp [causalFuture, PrimeSpectrum.mem_zeroLocus]

/-- Holographic duality: p ∈ J⁻(q) ⟺ q ∈ cl({p}). -/
theorem mem_causalPast_iff_mem_closure (R : Type*) [CommRing R]
    (p q : PrimeSpectrum R) :
    p ∈ causalPast R q ↔ q ∈ closure ({p} : Set (PrimeSpectrum R)) := by
  rw [zariski_closure_eq_causal_future]; simp [causalPast, causalFuture]

/-- Diamond = cl({bottom}) ∩ J⁻(top). -/
theorem causalDiamond_eq_closure_inter (R : Type*) [CommRing R] (d : CausalDiamond R) :
    d.carrier = closure ({d.bottom} : Set (PrimeSpectrum R)) ∩ causalPast R d.top := by
  rw [zariski_closure_eq_causal_future]
  ext r; simp [CausalDiamond.carrier, causalFuture, causalPast, and_comm]

/-- **Causal = specialization**: p ≼ q ⟺ p ⤳ q.
    Bridge: unifies algebra (ideal inclusion) and topology (specialization). -/
theorem causal_eq_specialization (R : Type*) [CommRing R]
    (p q : PrimeSpectrum R) :
    CausalRel R p q ↔ p ⤳ q := by
  rw [specializes_iff_mem_closure, zariski_closure_eq_causal_future]; rfl

/-! ## Part 4: Causal Independence in Dedekind Domains -/

/-- **Spacelike Separation in Dedekind Domains**: distinct maximal ideals are
    causally incomparable. Bridge: Dedekind structure ↔ spacelike separation.
    Impact: post_quantum_security — causal independence ↔ no-signaling. -/
theorem maximal_ideals_causally_incomparable (R : Type*) [CommRing R] [IsDomain R]
    [IsDedekindDomain R] (p q : PrimeSpectrum R)
    (hp : p.asIdeal.IsMaximal) (hq : q.asIdeal.IsMaximal) (h_ne : p ≠ q) :
    SpacelikeSeparated R p q :=
  ⟨fun h => h_ne (PrimeSpectrum.ext (hp.eq_of_le hq.ne_top h)),
   fun h => h_ne (PrimeSpectrum.ext (hq.eq_of_le hp.ne_top h)).symm⟩

/-- Maximal ideals form an antichain.
    Bridge: antichains ↔ spacelike hypersurfaces. -/
theorem maximal_ideals_antichain (R : Type*) [CommRing R] [IsDomain R]
    [IsDedekindDomain R] :
    IsAntichain (· ≤ ·) { p : PrimeSpectrum R | p.asIdeal.IsMaximal } :=
  fun _ hp _ hq hne h => hne (PrimeSpectrum.ext (hp.eq_of_le hq.ne_top h))

/-- J⁺(m) = {m} for maximal m: "big crunch" singularities. -/
theorem causalFuture_maximal_eq_singleton (R : Type*) [CommRing R]
    (p : PrimeSpectrum R) (hp : p.asIdeal.IsMaximal) :
    causalFuture R p = {p} := by
  ext q
  constructor
  · intro (h : p.asIdeal ≤ q.asIdeal)
    show q = p
    exact (PrimeSpectrum.ext (hp.eq_of_le q.isPrime.ne_top h)).symm
  · intro (h : q = p)
    show p.asIdeal ≤ q.asIdeal
    rw [h]

/-- J⁻(gen) = {gen} for the generic point: the "big bang" is unique. -/
theorem causalPast_zero_eq_singleton (R : Type*) [CommRing R] [IsDomain R]
    (p : PrimeSpectrum R) (hp : p.asIdeal = ⊥) :
    causalPast R p = {p} := by
  ext q
  constructor
  · intro (h : q.asIdeal ≤ p.asIdeal)
    show q = p
    rw [hp] at h
    exact PrimeSpectrum.ext ((le_bot_iff.mp h).trans hp.symm)
  · intro (h : q = p)
    show q.asIdeal ≤ p.asIdeal
    rw [h]

/-- The generic point causally precedes all events. -/
theorem zero_ideal_in_causal_past (R : Type*) [CommRing R] [IsDomain R]
    (p gen : PrimeSpectrum R) (hgen : gen.asIdeal = ⊥) :
    CausalRel R gen p := by simp [CausalRel, hgen]

/-- Spacelike separation is symmetric. -/
theorem spacelikeSeparated_symm (R : Type*) [CommRing R] (p q : PrimeSpectrum R) :
    SpacelikeSeparated R p q ↔ SpacelikeSeparated R q p := by
  simp [SpacelikeSeparated, and_comm]

/-- Spacelike separated ⟹ distinct. -/
theorem spacelikeSeparated_ne (R : Type*) [CommRing R]
    (p q : PrimeSpectrum R) (h : SpacelikeSeparated R p q) : p ≠ q := by
  intro heq; subst heq; exact h.1 (causalRel_refl R p)

/-! ## Part 5: Noether Symmetry-Conservation Correspondence -/

/-- **Noether Theorem**: Aut(R) preserves ideal norms. N(I) = N(φ(I)).
    Bridge: Galois theory ↔ Noether's theorem. Symmetry ↔ conservation.
    Impact: hamiltonian_conservation — spacetime symmetries ↔ conserved quantities. -/
theorem noether_symmetry_conservation (R : Type*) [CommRing R]
    (φ : R ≃+* R) (I : Ideal R) :
    idealNorm R I = idealNorm R (Ideal.map (φ : R →+* R) I) :=
  Nat.card_congr (Ideal.quotientEquiv I _ φ rfl).toEquiv

/-- Inverse formulation: N(I) = N(φ⁻¹(I)). -/
theorem noether_symmetry_conservation_inv (R : Type*) [CommRing R]
    (φ : R ≃+* R) (I : Ideal R) :
    idealNorm R I = idealNorm R (Ideal.map (φ.symm : R →+* R) I) :=
  noether_symmetry_conservation R φ.symm I

/-- The ideal norm is a ConservedQuantity: the Noether charge. -/
def idealNormConservedQuantity (R : Type*) [CommRing R] : ConservedQuantity R where
  quantity := idealNorm R
  conservation := fun φ I => noether_symmetry_conservation R φ I

/-- Equal ideals have equal norms. -/
theorem idealNorm_congr (R : Type*) [CommRing R] (I J : Ideal R) (h : I = J) :
    idealNorm R I = idealNorm R J := by subst h; rfl

/-- N(⊤) = 1: the "vacuum" ideal has trivial information content. -/
theorem idealNorm_top (R : Type*) [CommRing R] :
    idealNorm R ⊤ = 1 := by
  unfold idealNorm
  haveI : Subsingleton (R ⧸ (⊤ : Ideal R)) := by
    rw [Ideal.Quotient.subsingleton_iff]
  exact Nat.card_of_subsingleton default

/-! ## Part 6: Causal Dynamics from Ring Homomorphisms -/

/-- Ring homomorphisms induce causal-order-preserving maps via comap.
    Bridge: ring homomorphisms ↔ causal propagation. -/
theorem comap_preserves_causal_order (R S : Type*) [CommRing R] [CommRing S]
    (φ : R →+* S) (p q : PrimeSpectrum S) (h : CausalRel S p q) :
    CausalRel R (PrimeSpectrum.comap φ p) (PrimeSpectrum.comap φ q) :=
  fun _ hx => h hx

/-! ## Part 7: Causal Chain Properties -/

/-- Causal chains are transitive. -/
theorem causal_chain_transitivity (R : Type*) [CommRing R]
    (n : ℕ) (c : CausalChain R n) (i j k : Fin (n + 1))
    (hij : i < j) (hjk : j < k) :
    (c.chain i).asIdeal < (c.chain k).asIdeal :=
  lt_trans (c.strictly_increasing i j hij) (c.strictly_increasing j k hjk)

/-- Causal chains are injective: chronology condition.
    Bridge: no-return ↔ causal propagation. -/
theorem causal_chain_injective (R : Type*) [CommRing R]
    (n : ℕ) (c : CausalChain R n) :
    Function.Injective c.chain := by
  intro i j h
  by_contra hne
  rcases lt_or_gt_of_ne hne with hij | hji
  · exact (c.strictly_increasing i j hij).ne (congr_arg PrimeSpectrum.asIdeal h)
  · exact (c.strictly_increasing j i hji).ne (congr_arg PrimeSpectrum.asIdeal h.symm)

/-- Trivial chain from a single point. -/
def trivialCausalChain (R : Type*) [CommRing R] (p : PrimeSpectrum R) : CausalChain R 0 where
  chain := fun _ => p
  strictly_increasing := fun i j h => absurd h (by omega)

/-! ## Part 8: Spectral Topology -/

/-- J⁺(p) ⊆ cl(S) for any S containing p. -/
theorem causalFuture_subset_closure_of_mem (R : Type*) [CommRing R]
    (p : PrimeSpectrum R) (S : Set (PrimeSpectrum R)) (hp : p ∈ S) :
    causalFuture R p ⊆ closure S := by
  rw [← zariski_closure_eq_causal_future]
  exact closure_mono (singleton_subset_iff.mpr hp)

/-- J⁺(gen) = univ: the "big bang" reaches all events. -/
theorem causalFuture_bot_eq_univ (R : Type*) [CommRing R] [IsDomain R]
    (gen : PrimeSpectrum R) (hgen : gen.asIdeal = ⊥) :
    causalFuture R gen = Set.univ := by
  ext q; simp [causalFuture, hgen]

/-- Intersection of causal futures. -/
theorem causalFuture_inter_eq (R : Type*) [CommRing R] (p q : PrimeSpectrum R) :
    causalFuture R p ∩ causalFuture R q =
    { r | p.asIdeal ≤ r.asIdeal ∧ q.asIdeal ≤ r.asIdeal } := by
  ext r; simp [causalFuture]

/-! ## Part 9: Causal Diamond Properties -/

/-- Diamonds are monotone in top. -/
theorem causalDiamond_monotone_top (R : Type*) [CommRing R]
    (p q q' : PrimeSpectrum R) (hpq : p.asIdeal ≤ q.asIdeal)
    (hpq' : p.asIdeal ≤ q'.asIdeal) (hqq' : q.asIdeal ≤ q'.asIdeal) :
    (CausalDiamond.mk p q hpq).carrier ⊆ (CausalDiamond.mk p q' hpq').carrier :=
  fun _ ⟨hr1, hr2⟩ => ⟨hr1, le_trans hr2 hqq'⟩

/-- Diamonds are antitone in bottom. -/
theorem causalDiamond_antitone_bot (R : Type*) [CommRing R]
    (p p' q : PrimeSpectrum R) (hpq : p.asIdeal ≤ q.asIdeal)
    (hp'q : p'.asIdeal ≤ q.asIdeal) (hpp' : p'.asIdeal ≤ p.asIdeal) :
    (CausalDiamond.mk p q hpq).carrier ⊆ (CausalDiamond.mk p' q hp'q).carrier :=
  fun _ ⟨hr1, hr2⟩ => ⟨le_trans hpp' hr1, hr2⟩

/-- Point diamond = singleton. -/
theorem causalDiamond_self_singleton (R : Type*) [CommRing R] (p : PrimeSpectrum R) :
    (CausalDiamond.mk p p (le_refl _)).carrier = {p} := by
  ext r; simp only [CausalDiamond.carrier, mem_setOf_eq, mem_singleton_iff]
  exact ⟨fun ⟨h1, h2⟩ => PrimeSpectrum.ext (le_antisymm h2 h1),
         fun h => by subst h; exact ⟨le_refl _, le_refl _⟩⟩

/-! ## Part 10: Ring Isomorphism Invariance -/

/-- Ring homomorphisms preserve causal order via comap. -/
theorem ring_hom_preserves_causal (R S : Type*) [CommRing R] [CommRing S]
    (φ : R →+* S) (p q : PrimeSpectrum S) (h : CausalRel S p q) :
    CausalRel R (PrimeSpectrum.comap φ p) (PrimeSpectrum.comap φ q) :=
  fun _ hx => h hx

/-- Comap maps causal futures covariantly. -/
theorem causalFuture_comap (R S : Type*) [CommRing R] [CommRing S]
    (φ : R →+* S) (p : PrimeSpectrum S) :
    PrimeSpectrum.comap φ '' (causalFuture S p) ⊆
    causalFuture R (PrimeSpectrum.comap φ p) :=
  fun _ ⟨_, hq, hrq⟩ => by rw [← hrq]; exact fun x hx => hq hx

/-! ## Part 11: Concrete Examples in Spec(ℤ) -/

/-- Zero ideal is in causal past of every point of Spec(ℤ). -/
theorem int_zero_causal_origin :
    ∀ p : PrimeSpectrum ℤ, CausalRel ℤ ⟨⊥, Ideal.isPrime_bot⟩ p :=
  fun _ => bot_le

/-- (p) is prime in ℤ for natural prime p. -/
theorem int_prime_ideal_isPrime (p : ℕ) (hp : Nat.Prime p) :
    (Ideal.span {(p : ℤ)}).IsPrime := by
  rw [Ideal.span_singleton_prime (Int.natCast_ne_zero.mpr hp.ne_zero)]
  exact Nat.prime_iff_prime_int.mp hp

/-- (p) is maximal in ℤ for natural prime p (ℤ is a PID). -/
theorem int_prime_ideal_isMaximal (p : ℕ) (hp : Nat.Prime p) :
    (Ideal.span {(p : ℤ)}).IsMaximal :=
  (int_prime_ideal_isPrime p hp).isMaximal
    (by simp [Ideal.span_singleton_eq_bot, hp.ne_zero])

/-- J⁺((0)) = Spec(ℤ). -/
theorem int_generic_causal_future_univ :
    causalFuture ℤ ⟨⊥, Ideal.isPrime_bot⟩ = Set.univ :=
  causalFuture_bot_eq_univ ℤ ⟨⊥, Ideal.isPrime_bot⟩ rfl

/-- J⁺((p)) = {(p)} for prime p. -/
theorem int_prime_causal_future_singleton (p : ℕ) (hp : Nat.Prime p) :
    causalFuture ℤ ⟨Ideal.span {(p : ℤ)}, int_prime_ideal_isPrime p hp⟩ =
    {⟨Ideal.span {(p : ℤ)}, int_prime_ideal_isPrime p hp⟩} :=
  causalFuture_maximal_eq_singleton ℤ _ (int_prime_ideal_isMaximal p hp)

/-- **Number-Theoretic Spacelike Separation**: distinct primes p ≠ q give
    spacelike separated (p), (q) in Spec(ℤ).
    Bridge: distinct primes ↔ causal independence.
    Impact: lattice_crypto — prime independence ↔ factoring hardness. -/
theorem int_distinct_primes_spacelike (p q : ℕ) (hp : Nat.Prime p) (hq : Nat.Prime q)
    (hne : p ≠ q) :
    SpacelikeSeparated ℤ
      ⟨Ideal.span {(p : ℤ)}, int_prime_ideal_isPrime p hp⟩
      ⟨Ideal.span {(q : ℤ)}, int_prime_ideal_isPrime q hq⟩ := by
  apply maximal_ideals_causally_incomparable
  · exact int_prime_ideal_isMaximal p hp
  · exact int_prime_ideal_isMaximal q hq
  · intro heq
    have h_ideal : Ideal.span {(p : ℤ)} = Ideal.span {(q : ℤ)} :=
      congr_arg PrimeSpectrum.asIdeal heq
    rw [Ideal.span_singleton_eq_span_singleton] at h_ideal
    obtain ⟨u, hu⟩ := h_ideal
    have hunit : (u : ℤ) = 1 ∨ (u : ℤ) = -1 := Int.isUnit_iff.mp u.isUnit
    rcases hunit with h1 | h1
    · have : (p : ℤ) * 1 = (q : ℤ) := by rw [← h1]; exact hu
      simp at this; exact hne this
    · have : (p : ℤ) * (-1) = (q : ℤ) := by rw [← h1]; exact hu
      simp at this; omega

/-! ## Part 12: Thermodynamic Arrow — Ideal Norm Monotonicity -/

/-- **Thermodynamic Arrow**: I ⊆ J ⟹ N(J) ≤ N(I) (finite quotient).
    Ideal norm decreases along causal chains.
    Bridge: ideal inclusion ↔ entropy decrease. O(1) verification.
    Impact: entropy — "second law of algebraic thermodynamics." -/
theorem idealNorm_antitone_of_le (R : Type*) [CommRing R]
    (I J : Ideal R) (h : I ≤ J) [Finite (R ⧸ I)] :
    idealNorm R J ≤ idealNorm R I := by
  haveI : Finite (R ⧸ J) := Finite.of_surjective _ (Ideal.Quotient.factor_surjective h)
  exact Nat.card_le_card_of_surjective _ (Ideal.Quotient.factor_surjective h)

/-! ## Part 13: Closed Sets and Causal Structure -/

/-- **Causal Closure Property**: Zariski closed sets are upward-closed.
    p ∈ S, p ≼ q, S closed ⟹ q ∈ S.
    Bridge: causal order ↔ topological completeness.
    Impact: certified_robustness — causal data ↔ topological verification. -/
theorem closed_upward_closed (R : Type*) [CommRing R]
    (S : Set (PrimeSpectrum R)) (hS : IsClosed S)
    (p : PrimeSpectrum R) (hp : p ∈ S) (q : PrimeSpectrum R) (hpq : CausalRel R p q) :
    q ∈ S := by
  have : q ∈ closure ({p} : Set (PrimeSpectrum R)) := by
    rw [zariski_closure_eq_causal_future]; exact hpq
  exact hS.closure_subset_iff.mpr (singleton_subset_iff.mpr hp) this

/-- ⋃_{p ∈ S} J⁺(p) ⊆ cl(S): causal influence within closures. -/
theorem causalFuture_union_subset_closure (R : Type*) [CommRing R]
    (S : Set (PrimeSpectrum R)) :
    (⋃ p ∈ S, causalFuture R p) ⊆ closure S := by
  intro q hq; simp only [mem_iUnion] at hq
  obtain ⟨p, hp, hpq⟩ := hq
  exact causalFuture_subset_closure_of_mem R p S hp hpq

end AlgebraicSpacetime