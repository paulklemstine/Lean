/-! # CatalogBuild.Speculative.Other.UniversalTranslator

Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 31
-/

import Mathlib

noncomputable section

/-- [Section: # CatalogBuild.Speculative.Other.UniversalTranslator
Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 31] -/
theorem point_is_prime_ideal (R : Type*) [CommRing R]
    (x : PrimeSpectrum R) : x.asIdeal.IsPrime :=
  by
    exact x.2



theorem point_in_zeroLocus_iff_ideal_contained (R : Type*) [CommRing R]
    (I : Ideal R) (x : PrimeSpectrum R) :
    x ∈ zeroLocus (I : Set R) ↔ I ≤ x.asIdeal :=
  by
    bound



theorem maximal_ideal_is_closed_point (R : Type*) [CommRing R]
    (x : PrimeSpectrum R) (hm : x.asIdeal.IsMaximal) :
    IsClosed ({x} : Set (PrimeSpectrum R)) :=
  by
    rw [ PrimeSpectrum.isClosed_singleton_iff_isMaximal ] ; tauto

-- ═══════════════════════════════════════════════════════════════════════
--  Row 2: Open Sets ↔ Elements  (Basic Opens)
-- ═══════════════════════════════════════════════════════════════════════



theorem basic_open_is_complement_of_vanishing (R : Type*) [CommRing R]
    (a : R) : (basicOpen a : Set (PrimeSpectrum R)) = (zeroLocus {a})ᶜ :=
  by
    simp +decide [ basicOpen, zeroLocus ];
    rfl



theorem basic_opens_form_basis (R : Type*) [CommRing R] :
    TopologicalSpace.IsTopologicalBasis
      (Set.range (fun a : R => (basicOpen a : Set (PrimeSpectrum R)))) :=
  by
    exact?



theorem basic_open_mul (R : Type*) [CommRing R] (a b : R) :
    basicOpen (a * b) = basicOpen a ⊓ basicOpen b :=
  by
    simp +decide [ basicOpen, Set.ext_iff ];
    intro x; exact ⟨ fun h => ⟨ fun ha => h ( Ideal.mul_mem_right _ _ ha ), fun hb => h ( Ideal.mul_mem_left _ _ hb ) ⟩, fun h => fun h' => h.1 ( x.2.mem_or_mem h' |>.resolve_right h.2 ) ⟩ ;



theorem basic_open_one (R : Type*) [CommRing R] :
    basicOpen (1 : R) = ⊤ :=
  by
    aesop



theorem basic_open_zero (R : Type*) [CommRing R] :
    basicOpen (0 : R) = ⊥ :=
  by
    simp +decide [ basicOpen ]

-- ═══════════════════════════════════════════════════════════════════════
--  Row 3: Continuous Maps ↔ Ring Homomorphisms  (Arrow Reversal!)
-- ═══════════════════════════════════════════════════════════════════════



theorem ring_hom_induces_continuous_map (R S : Type*) [CommRing R] [CommRing S]
    (φ : R →+* S) : Continuous (PrimeSpectrum.comap φ) :=
  by
    exact?



theorem comap_reverses_composition (R S T : Type*) [CommRing R] [CommRing S] [CommRing T]
    (φ : R →+* S) (ψ : S →+* T) :
    PrimeSpectrum.comap (ψ.comp φ) =
      PrimeSpectrum.comap φ ∘ PrimeSpectrum.comap ψ :=
  by
    aesop_cat



theorem comap_id_is_id (R : Type*) [CommRing R] :
    PrimeSpectrum.comap (RingHom.id R) = id :=
  by
    funext x
    simp [comap]



theorem comap_preimage_basic_open (R S : Type*) [CommRing R] [CommRing S]
    (φ : R →+* S) (a : R) :
    PrimeSpectrum.comap φ ⁻¹' (basicOpen a : Set (PrimeSpectrum R)) =
      basicOpen (φ a) :=
  by
    ext; simp [PrimeSpectrum.comap]

-- ═══════════════════════════════════════════════════════════════════════
--  Row 4: Closed Subspaces ↔ Ideals
-- ═══════════════════════════════════════════════════════════════════════



theorem vanishing_set_is_closed (R : Type*) [CommRing R] (I : Ideal R) :
    IsClosed (zeroLocus (I : Set R)) :=
  by
    -- The zero locus of an ideal is closed by definition.
    apply PrimeSpectrum.isClosed_zeroLocus



theorem galois_connection_V_I (R : Type*) [CommRing R]
    (S : Set (PrimeSpectrum R)) :
    zeroLocus ↑(vanishingIdeal S) = closure S :=
  by
    exact?



theorem vanishing_reverses_inclusion (R : Type*) [CommRing R]
    (I J : Set R) (h : I ⊆ J) :
    zeroLocus J ⊆ zeroLocus I :=
  by
    exact?



theorem vanishing_of_whole_ring (R : Type*) [CommRing R] :
    zeroLocus (Set.univ : Set R) = ∅ :=
  by
    ext x; exact ⟨by aesop, by aesop⟩;



theorem vanishing_of_empty (R : Type*) [CommRing R] :
    zeroLocus (∅ : Set R) = Set.univ :=
  by
    aesop_cat



theorem vanishing_of_intersection_eq_union (R : Type*) [CommRing R]
    (I J : Ideal R) :
    zeroLocus ((I ⊓ J : Ideal R) : Set R) =
      zeroLocus (I : Set R) ∪ zeroLocus (J : Set R) :=
  by
    exact?

-- ═══════════════════════════════════════════════════════════════════════
--  Row 5: Dimension ↔ Krull Dimension
-- ═══════════════════════════════════════════════════════════════════════



theorem krull_dim_eq_spectrum_dim (R : Type*) [CommRing R] :
    ringKrullDim R = Order.krullDim (PrimeSpectrum R) :=
  by
    convert rfl



theorem field_has_krull_dim_zero (k : Type*) [Field k] :
    ringKrullDim k = 0 :=
  by
    rw [ eq_comm ] ; aesop;

-- ═══════════════════════════════════════════════════════════════════════
--  Row 6: Tangent Vectors ↔ Derivations
-- ═══════════════════════════════════════════════════════════════════════



def kahler_differentials_module (R S : Type*) [CommRing R] [CommRing S]
    [Algebra R S] : Module S (Ω[S⁄R]) :=
  inferInstance



def universal_derivation (R S : Type*) [CommRing R] [CommRing S]
    [Algebra R S] : Derivation R S (Ω[S⁄R]) :=
  KaehlerDifferential.D R S



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



theorem free_module_is_projective (R M : Type*) [Ring R]
    [AddCommGroup M] [Module R M] [Module.Free R M] :
    Module.Projective R M :=
  by
    infer_instance

-- ═══════════════════════════════════════════════════════════════════════
--  The Spec Functor  (Summary)
-- ═══════════════════════════════════════════════════════════════════════



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



def gelfand_duality (X : Type*) (𝕜 : Type*) [TopologicalSpace X]
    [CompactSpace X] [T2Space X] [RCLike 𝕜] :
    X ≃ₜ WeakDual.characterSpace 𝕜 C(X, 𝕜) :=
  WeakDual.CharacterSpace.homeoEval X 𝕜

-- ═══════════════════════════════════════════════════════════════════════
--  Bonus: Nullstellensatz  (The Bridge's Strongest Plank)
-- ═══════════════════════════════════════════════════════════════════════



theorem weak_nullstellensatz (k : Type*) [Field k] [IsAlgClosed k]
    (I : Ideal (Polynomial k))
    (hI : (zeroLocus (I : Set (Polynomial k)) : Set (PrimeSpectrum (Polynomial k))) = ∅) :
    I = ⊤ :=
  by
    exact?



end
