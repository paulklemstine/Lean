import Mathlib

/-!
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

Each row is stated as a theorem or construction establishing the
correspondence, using Mathlib's existing infrastructure where available.
All statements are left as `sorry` — the formalization records the
precise dictionary; proofs are deferred.
-/

open PrimeSpectrum TopologicalSpace

noncomputable section

-- ═══════════════════════════════════════════════════════════════════════
--  Row 1: Points ↔ Prime / Maximal Ideals
-- ═══════════════════════════════════════════════════════════════════════

/-! ## Row 1 · Points ↔ Prime / Maximal Ideals

A point of Spec(R) **is** a prime ideal.  For a commutative ring R,
`PrimeSpectrum R` is the type of prime ideals of R bundled with their
primality proof.  This is the foundational dictionary entry.

For the *maximal* spectrum the dictionary reads: maximal ideals
correspond to closed points (points whose singleton is Zariski-closed).
-/

/-
PROBLEM
Every point of the prime spectrum is a prime ideal.

PROVIDED SOLUTION
The primality proof is stored in x.2 (the second component of the PrimeSpectrum bundled type).
-/
theorem point_is_prime_ideal (R : Type*) [CommRing R]
    (x : PrimeSpectrum R) : x.asIdeal.IsPrime :=
  by
    exact x.2

/-
A point x lies in V(I) iff I ⊆ p — the point-ideal membership dictionary.
-/
theorem point_in_zeroLocus_iff_ideal_contained (R : Type*) [CommRing R]
    (I : Ideal R) (x : PrimeSpectrum R) :
    x ∈ zeroLocus (I : Set R) ↔ I ≤ x.asIdeal :=
  by
    bound

/-
A maximal ideal gives a closed point of Spec(R).
-/
theorem maximal_ideal_is_closed_point (R : Type*) [CommRing R]
    (x : PrimeSpectrum R) (hm : x.asIdeal.IsMaximal) :
    IsClosed ({x} : Set (PrimeSpectrum R)) :=
  by
    rw [ PrimeSpectrum.isClosed_singleton_iff_isMaximal ] ; tauto

-- ═══════════════════════════════════════════════════════════════════════
--  Row 2: Open Sets ↔ Elements  (Basic Opens)
-- ═══════════════════════════════════════════════════════════════════════

/-! ## Row 2 · Open Sets ↔ Elements (Basic Opens)

The basic open set D(a) = {p ∈ Spec(R) | a ∉ p} gives a dictionary
between elements of the ring and distinguished open subsets of the
spectrum.  Every open set is a union of basic opens.
-/

/-
PROBLEM
D(a) is the complement of V({a}): the set of primes not containing a.

PROVIDED SOLUTION
This should follow from PrimeSpectrum.basicOpen_eq_zeroLocus_compl or similar Mathlib lemma.
-/
theorem basic_open_is_complement_of_vanishing (R : Type*) [CommRing R]
    (a : R) : (basicOpen a : Set (PrimeSpectrum R)) = (zeroLocus {a})ᶜ :=
  by
    simp +decide [ basicOpen, zeroLocus ];
    rfl

/-
The basic opens form a basis for the Zariski topology.
-/
theorem basic_opens_form_basis (R : Type*) [CommRing R] :
    TopologicalSpace.IsTopologicalBasis
      (Set.range (fun a : R => (basicOpen a : Set (PrimeSpectrum R)))) :=
  by
    exact?

/-
PROBLEM
D(a · b) = D(a) ∩ D(b) — the map a ↦ D(a) is multiplicative.

PROVIDED SOLUTION
Use PrimeSpectrum.basicOpen_mul from Mathlib.
-/
theorem basic_open_mul (R : Type*) [CommRing R] (a b : R) :
    basicOpen (a * b) = basicOpen a ⊓ basicOpen b :=
  by
    simp +decide [ basicOpen, Set.ext_iff ];
    intro x; exact ⟨ fun h => ⟨ fun ha => h ( Ideal.mul_mem_right _ _ ha ), fun hb => h ( Ideal.mul_mem_left _ _ hb ) ⟩, fun h => fun h' => h.1 ( x.2.mem_or_mem h' |>.resolve_right h.2 ) ⟩ ;

/-
PROBLEM
D(1) = Spec(R) — the whole space corresponds to the unit.

PROVIDED SOLUTION
Use PrimeSpectrum.basicOpen_one from Mathlib.
-/
theorem basic_open_one (R : Type*) [CommRing R] :
    basicOpen (1 : R) = ⊤ :=
  by
    aesop

/-
PROBLEM
D(0) = ∅ — the zero element corresponds to the empty set.

PROVIDED SOLUTION
Use PrimeSpectrum.basicOpen_zero from Mathlib.
-/
theorem basic_open_zero (R : Type*) [CommRing R] :
    basicOpen (0 : R) = ⊥ :=
  by
    simp +decide [ basicOpen ]

-- ═══════════════════════════════════════════════════════════════════════
--  Row 3: Continuous Maps ↔ Ring Homomorphisms  (Arrow Reversal!)
-- ═══════════════════════════════════════════════════════════════════════

/-! ## Row 3 · Continuous Maps ↔ Ring Homomorphisms (Arrow Reversal!)

This is the **contravariance** at the heart of algebraic geometry.
A ring homomorphism φ : R → S induces a continuous map
Spec(S) → Spec(R) going the other way.  Functoriality says this
assignment preserves identities and reverses composition.
-/

/-
PROBLEM
A ring homomorphism φ : R → S induces a continuous map Spec(S) → Spec(R).

PROVIDED SOLUTION
Use PrimeSpectrum.comap_continuous from Mathlib.
-/
theorem ring_hom_induces_continuous_map (R S : Type*) [CommRing R] [CommRing S]
    (φ : R →+* S) : Continuous (PrimeSpectrum.comap φ) :=
  by
    exact?

/-
Composition reverses: Spec(ψ ∘ φ) = Spec(φ) ∘ Spec(ψ).
-/
theorem comap_reverses_composition (R S T : Type*) [CommRing R] [CommRing S] [CommRing T]
    (φ : R →+* S) (ψ : S →+* T) :
    PrimeSpectrum.comap (ψ.comp φ) =
      PrimeSpectrum.comap φ ∘ PrimeSpectrum.comap ψ :=
  by
    aesop_cat

/-
The identity ring hom gives the identity spectral map.
-/
theorem comap_id_is_id (R : Type*) [CommRing R] :
    PrimeSpectrum.comap (RingHom.id R) = id :=
  by
    funext x
    simp [comap]

/-
Preimages of basic opens: comap φ ⁻¹(D(a)) = D(φ(a)).
-/
theorem comap_preimage_basic_open (R S : Type*) [CommRing R] [CommRing S]
    (φ : R →+* S) (a : R) :
    PrimeSpectrum.comap φ ⁻¹' (basicOpen a : Set (PrimeSpectrum R)) =
      basicOpen (φ a) :=
  by
    ext; simp [PrimeSpectrum.comap]

-- ═══════════════════════════════════════════════════════════════════════
--  Row 4: Closed Subspaces ↔ Ideals
-- ═══════════════════════════════════════════════════════════════════════

/-! ## Row 4 · Closed Subspaces ↔ Ideals

Closed subsets of Spec(R) in the Zariski topology are exactly the
vanishing sets V(I) = {p | I ⊆ p}.  Radical ideals biject with closed
subsets: V and I form a Galois connection.
-/

/-
PROBLEM
V(I) is closed for any ideal I.

PROVIDED SOLUTION
Use PrimeSpectrum.isClosed_zeroLocus from Mathlib.
-/
theorem vanishing_set_is_closed (R : Type*) [CommRing R] (I : Ideal R) :
    IsClosed (zeroLocus (I : Set R)) :=
  by
    -- The zero locus of an ideal is closed by definition.
    apply PrimeSpectrum.isClosed_zeroLocus

/-
The Galois connection: V(I(S)) = closure(S).
-/
theorem galois_connection_V_I (R : Type*) [CommRing R]
    (S : Set (PrimeSpectrum R)) :
    zeroLocus ↑(vanishingIdeal S) = closure S :=
  by
    exact?

/-
PROBLEM
Inclusion-reversing: I ⊆ J implies V(J) ⊆ V(I).

PROVIDED SOLUTION
Use PrimeSpectrum.zeroLocus_anti_mono from Mathlib.
-/
theorem vanishing_reverses_inclusion (R : Type*) [CommRing R]
    (I J : Set R) (h : I ⊆ J) :
    zeroLocus J ⊆ zeroLocus I :=
  by
    exact?

/-
V(R) = ∅ — the whole ring vanishes nowhere.
-/
theorem vanishing_of_whole_ring (R : Type*) [CommRing R] :
    zeroLocus (Set.univ : Set R) = ∅ :=
  by
    ext x; exact ⟨by aesop, by aesop⟩;

/-
V(∅) = Spec(R) — the empty set vanishes everywhere.
-/
theorem vanishing_of_empty (R : Type*) [CommRing R] :
    zeroLocus (∅ : Set R) = Set.univ :=
  by
    aesop_cat

/-
V(I ∩ J) = V(I) ∪ V(J) — intersecting ideals gives union of closed sets.
-/
theorem vanishing_of_intersection_eq_union (R : Type*) [CommRing R]
    (I J : Ideal R) :
    zeroLocus ((I ⊓ J : Ideal R) : Set R) =
      zeroLocus (I : Set R) ∪ zeroLocus (J : Set R) :=
  by
    exact?

-- ═══════════════════════════════════════════════════════════════════════
--  Row 5: Dimension ↔ Krull Dimension
-- ═══════════════════════════════════════════════════════════════════════

/-! ## Row 5 · Dimension ↔ Krull Dimension

The Krull dimension of a commutative ring R is the supremum of lengths
of chains of prime ideals — the algebraic counterpart of geometric
dimension.  A field has Krull dimension 0; ℤ and k[x] have dimension 1.
-/

/-
ringKrullDim R = Order.krullDim (PrimeSpectrum R), by definition.
-/
theorem krull_dim_eq_spectrum_dim (R : Type*) [CommRing R] :
    ringKrullDim R = Order.krullDim (PrimeSpectrum R) :=
  by
    convert rfl

/-
A field has Krull dimension 0.
-/
theorem field_has_krull_dim_zero (k : Type*) [Field k] :
    ringKrullDim k = 0 :=
  by
    rw [ eq_comm ] ; aesop;

-- ═══════════════════════════════════════════════════════════════════════
--  Row 6: Tangent Vectors ↔ Derivations
-- ═══════════════════════════════════════════════════════════════════════

/-! ## Row 6 · Tangent Vectors ↔ Derivations

A derivation δ : A → M satisfies the Leibniz rule
  δ(ab) = a · δ(b) + b · δ(a).
These are the algebraic avatars of tangent vectors and vector fields.
Kähler differentials Ω¹(S/R) are the universal target for derivations.
-/

/-
PROBLEM
A derivation satisfies the Leibniz rule.

PROVIDED SOLUTION
Use Derivation.leibniz from Mathlib.
-/
theorem derivation_leibniz (R A M : Type*) [CommRing R] [CommRing A]
    [Algebra R A] [AddCommGroup M] [Module A M] [Module R M]
    [IsScalarTower R A M]
    (δ : Derivation R A M) (a b : A) :
    δ (a * b) = a • δ b + b • δ a :=
  by
    exact?

/-
Kähler differentials Ω¹(S/R) carry an S-module structure.
-/
def kahler_differentials_module (R S : Type*) [CommRing R] [CommRing S]
    [Algebra R S] : Module S (Ω[S⁄R]) :=
  inferInstance

/-
The universal derivation d : S → Ω¹(S/R).
-/
def universal_derivation (R S : Type*) [CommRing R] [CommRing S]
    [Algebra R S] : Derivation R S (Ω[S⁄R]) :=
  KaehlerDifferential.D R S

/-
The universal property: every derivation factors uniquely through d.
-/
theorem universal_property_of_kahler (R S M : Type*) [CommRing R] [CommRing S]
    [Algebra R S] [AddCommGroup M] [Module S M] [Module R M]
    [IsScalarTower R S M] :
    ∀ δ : Derivation R S M,
      ∃! f : (Ω[S⁄R]) →ₗ[S] M,
        δ = (f.compDer (KaehlerDifferential.D R S)) :=
  by
    intro δ;
    obtain ⟨f, hf⟩ : ∃ f : Ω[S⁄R] →ₗ[S] M, δ = f.compDer (KaehlerDifferential.D R S) := by
      refine' ⟨ _, _ ⟩;
      exact?;
      exact?;
    refine' ⟨ f, hf, _ ⟩;
    aesop

-- ═══════════════════════════════════════════════════════════════════════
--  Row 7: Connected Components ↔ Idempotents
-- ═══════════════════════════════════════════════════════════════════════

/-! ## Row 7 · Connected Components ↔ Idempotents

An idempotent e² = e determines a decomposition A ≅ eA × (1-e)A,
corresponding to a clopen decomposition of Spec(A).  Idempotents biject
with clopen subsets of the spectrum.  No nontrivial idempotents means
the spectrum is connected.
-/

/-
An idempotent e gives a clopen basic open D(e).
-/
theorem idempotent_gives_clopen (R : Type*) [CommRing R]
    (e : R) (he : IsIdempotentElem e) :
    IsClopen (basicOpen e : Set (PrimeSpectrum R)) :=
  by
    constructor;
    · refine' isClosed_of_closure_subset fun p hp => _;
      rw [ mem_closure_iff ] at hp;
      contrapose! hp;
      grind +suggestions;
    · exact?

/-
No nontrivial idempotents ⟹ connected spectrum.
-/
theorem no_nontrivial_idempotents_implies_connected (R : Type*) [CommRing R]
    [Nontrivial R]
    (h : ∀ e : R, IsIdempotentElem e → e = 0 ∨ e = 1) :
    ConnectedSpace (PrimeSpectrum R) :=
  by
    by_contra h_not_connected;
    -- Then there exists a clopen subset $U$ of $\text{Spec}(R)$ that is neither empty nor the whole space.
    obtain ⟨U, hU_clopen, hU_ne_empty, hU_ne_univ⟩ : ∃ U : Set (PrimeSpectrum R), IsClopen U ∧ U ≠ ∅ ∧ U ≠ Set.univ := by
      rw [ connectedSpace_iff_univ ] at h_not_connected;
      simp_all +decide [ IsConnected ];
      simp_all +decide [ IsPreconnected, Set.ext_iff ];
      obtain ⟨ U, hU, V, hV, hUV, hU', hV', hUV' ⟩ := h_not_connected; use U; simp_all +decide [ Set.Nonempty ] ;
      refine' ⟨ ⟨ _, _ ⟩, _ ⟩;
      · convert hV.isClosed_compl using 1 ; ext x ; specialize hUV x ; aesop;
      · exact hU;
      · exact ⟨ hV'.choose, fun hx => hUV' _ hx hV'.choose_spec ⟩;
    -- Since $U$ is clopen, there exists an idempotent $e \in R$ such that $U = D(e)$.
    obtain ⟨e, he⟩ : ∃ e : R, IsIdempotentElem e ∧ U = basicOpen e := by
      exact?;
    cases h e he.1 <;> simp_all +decide [ Set.ext_iff ]

/-
Connected spectrum ⟹ no nontrivial idempotents.
-/
theorem connected_implies_no_nontrivial_idempotents (R : Type*) [CommRing R]
    [Nontrivial R]
    (hconn : ConnectedSpace (PrimeSpectrum R)) :
    ∀ e : R, IsIdempotentElem e → e = 0 ∨ e = 1 :=
  by
    intro e he;
    -- If $e$ is an idempotent, then $D(e)$ is both open and closed.
    have h_open_closed : IsClopen (basicOpen e : Set (PrimeSpectrum R)) := by
      exact?;
    contrapose! h_open_closed;
    simp_all +decide [ IsClopen, Set.ext_iff ];
    intro h_open h_closed
    have h_empty : zeroLocus {e} = ∅ ∨ zeroLocus {e} = Set.univ := by
      have h_empty : IsClopen (zeroLocus {e} : Set (PrimeSpectrum R)) := by
        constructor <;> assumption;
      grind +suggestions;
    cases' h_empty with h_empty h_empty <;> simp_all +decide [ Set.ext_iff, zeroLocus ];
    · -- Since $e$ is not in any prime ideal, $e$ must be a unit.
      have h_unit : IsUnit e := by
        contrapose! h_empty;
        obtain ⟨ p, hp ⟩ := Ideal.exists_le_maximal ( Ideal.span { e } ) ( mt Ideal.span_singleton_eq_top.mp h_empty );
        exact ⟨ ⟨ p, hp.1.isPrime ⟩, hp.2 ( Ideal.subset_span ( Set.mem_singleton e ) ) ⟩;
      exact h_open_closed.2 ( h_unit.mul_left_inj.mp ( by aesop ) );
    · -- If $e$ is in every prime ideal, then $e$ must be in the nilradical of $R$.
      have h_nilradical : e ∈ nilradical R := by
        rw [ nilradical_eq_sInf ];
        exact Ideal.mem_sInf.mpr fun J hJ => by simpa using h_empty ⟨ J, hJ ⟩ ;
      obtain ⟨ n, hn ⟩ := h_nilradical;
      induction' n with n ih <;> simp_all +decide [ pow_succ, IsIdempotentElem ];
      induction n <;> simp_all +decide [ pow_succ, mul_assoc ]

-- ═══════════════════════════════════════════════════════════════════════
--  Row 8: Bundles ↔ Projective Modules  (Serre–Swan)
-- ═══════════════════════════════════════════════════════════════════════

/-! ## Row 8 · Bundles ↔ Projective Modules (Serre–Swan)

The Serre–Swan theorem: for compact Hausdorff X, vector bundles over X
≃ finitely generated projective modules over C(X, ℝ).
We state the algebraic characterisation of projectivity. -/

/-
A module is projective iff every surjection onto it splits.
-/
theorem projective_iff_surjection_splits (R M : Type*) [Ring R]
    [AddCommGroup M] [Module R M] :
    Module.Projective R M ↔
      ∀ (N : Type (max u_1 u_2)) [AddCommGroup N] [Module R N]
        (f : N →ₗ[R] M), Function.Surjective f →
        ∃ g : M →ₗ[R] N, f ∘ₗ g = LinearMap.id :=
  by
    refine' ⟨ fun h N _ _ f hf ↦ _, fun h ↦ _ ⟩;
    · exact?;
    · exact?

/-
PROBLEM
A free module is projective.

PROVIDED SOLUTION
Use Module.Projective.of_free or Module.Free.projective from Mathlib.
-/
theorem free_module_is_projective (R M : Type*) [Ring R]
    [AddCommGroup M] [Module R M] [Module.Free R M] :
    Module.Projective R M :=
  by
    infer_instance

-- ═══════════════════════════════════════════════════════════════════════
--  The Spec Functor  (Summary)
-- ═══════════════════════════════════════════════════════════════════════

/-! ## The Spec Functor

Pulling it all together: Spec is a contravariant functor from
CommRing to TopologicalSpaces.  It preserves identity and reverses
composition — the two axioms of a contravariant functor. -/

/-
**The Spec Functor** is contravariant: preserves identity, reverses composition.
-/
theorem spec_is_contravariant_functor :
    (∀ (R : Type*) [CommRing R],
      PrimeSpectrum.comap (RingHom.id R) = id) ∧
    (∀ (R S T : Type*) [CommRing R] [CommRing S] [CommRing T]
      (φ : R →+* S) (ψ : S →+* T),
      PrimeSpectrum.comap (ψ.comp φ) =
        PrimeSpectrum.comap φ ∘ PrimeSpectrum.comap ψ) :=
  by
    aesop

-- ═══════════════════════════════════════════════════════════════════════
--  Bonus: Gelfand Duality  (Functional Analysis Bridge)
-- ═══════════════════════════════════════════════════════════════════════

/-! ## Bonus · Gelfand Duality

For compact Hausdorff spaces X, the evaluation map gives a
homeomorphism X ≃ₜ characterSpace 𝕜 C(X, 𝕜).  This is the
functional-analytic twin of Spec: the space of *characters*
(algebra homomorphisms to the ground field) recovers X. -/

/-
PROBLEM
**Gelfand Duality**: X is homeomorphic to the character space of C(X, 𝕜).

PROVIDED SOLUTION
Use WeakDual.CharacterSpace.homeoEval from Mathlib if available.
-/
def gelfand_duality (X : Type*) (𝕜 : Type*) [TopologicalSpace X]
    [CompactSpace X] [T2Space X] [RCLike 𝕜] :
    X ≃ₜ WeakDual.characterSpace 𝕜 C(X, 𝕜) :=
  WeakDual.CharacterSpace.homeoEval X 𝕜

-- ═══════════════════════════════════════════════════════════════════════
--  Bonus: Nullstellensatz  (The Bridge's Strongest Plank)
-- ═══════════════════════════════════════════════════════════════════════

/-! ## Bonus · Hilbert's Nullstellensatz

For an algebraically closed field k, the maximal ideals of k[x₁,…,xₙ]
correspond bijectively to points of kⁿ.  This is the classical
concrete incarnation of Row 1 for polynomial rings. -/

/-
Over an algebraically closed field, V(I) = ∅ iff I = ⊤ (weak Nullstellensatz).
-/
theorem weak_nullstellensatz (k : Type*) [Field k] [IsAlgClosed k]
    (I : Ideal (Polynomial k))
    (hI : (zeroLocus (I : Set (Polynomial k)) : Set (PrimeSpectrum (Polynomial k))) = ∅) :
    I = ⊤ :=
  by
    exact?

end