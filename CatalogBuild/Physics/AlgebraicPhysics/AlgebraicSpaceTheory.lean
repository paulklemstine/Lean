/-! # CatalogBuild.Physics.AlgebraicPhysics.AlgebraicSpaceTheory

Auto-generated from theorem catalog database.
Domain: Physics/AlgebraicPhysics
Declarations: 12
-/

import Mathlib

theorem spec_contravariant {R S : Type*} [CommRing R] [CommRing S]
    (f : R →+* S) : Continuous (PrimeSpectrum.comap f) := by
  exact?

/-
For a field k, Spec(k) has exactly one point: the zero ideal.
    Algebraically: a field has exactly one prime ideal.
-/

theorem spec_field_unique (k : Type*) [Field k] :
    ∀ (p : PrimeSpectrum k), p = ⟨⊥, Ideal.isPrime_bot⟩ := by
  all_goals generalize_proofs at *;
  intro p
  generalize_proofs at *;
  ext x; exact (by
  by_cases hx : x = 0 <;> simp +decide [ hx ];
  exact fun h => p.2.ne_top ( by rw [ Ideal.eq_top_iff_one ] ; simpa using p.asIdeal.mul_mem_left x⁻¹ h |> fun h' => by simpa [ hx ] using h' ));


theorem zeroLocus_antitone (R : Type*) [CommRing R] (I J : Ideal R)
    (h : I ≤ J) :
    PrimeSpectrum.zeroLocus (J : Set R) ⊆ PrimeSpectrum.zeroLocus (I : Set R) := by
  intro p hp; intro x hx; exact hp (h hx) |> fun h => by aesop;

/-
The empty set is the zero locus of the whole ring.
-/

theorem zeroLocus_top (R : Type*) [CommRing R] :
    PrimeSpectrum.zeroLocus (Set.univ : Set R) = ∅ := by
  ext ⟨ x, hx ⟩ ; aesop;


theorem krull_dim_field (k : Type*) [Field k] :
    ringKrullDim k = 0 := by
  rw [ eq_comm ] ; aesop;

/-
A PID that is not a field has Krull dimension 1 (algebraic dimension
    of a line/curve). This captures the fact that ℤ and k[x] are
    1-dimensional.
-/

theorem krull_dim_pid (R : Type*) [CommRing R] [IsDomain R]
    [IsPrincipalIdealRing R] (h : ¬ IsField R) :
    ringKrullDim R = 1 := by
  exact?

/-
Isomorphic rings have equal Krull dimension — dimension is an
    algebraic invariant.
-/

theorem krull_dim_iso {R S : Type*} [CommRing R] [CommRing S]
    (e : R ≃+* S) : ringKrullDim R = ringKrullDim S := by
  exact?


theorem spec_comp {R S T : Type*} [CommRing R] [CommRing S] [CommRing T]
    (f : R →+* S) (g : S →+* T) :
    PrimeSpectrum.comap (g.comp f) = (PrimeSpectrum.comap f) ∘ (PrimeSpectrum.comap g) := by
  exact?

/-
The identity ring homomorphism gives the identity map on Spec.
-/

theorem spec_id (R : Type*) [CommRing R] :
    PrimeSpectrum.comap (RingHom.id R) = id := by
  aesop


theorem derivation_leibniz {R A M : Type*}
    [CommRing R] [CommRing A] [Algebra R A]
    [AddCommGroup M] [Module R M] [Module A M] [IsScalarTower R A M]
    (D : Derivation R A M) (a b : A) :
    D (a * b) = a • D b + b • D a := by
  convert D.leibniz a b using 1


theorem isIdempotentElem_iff (R : Type*) [Ring R] (e : R) :
    IsIdempotentElem e ↔ e * e = e := by
  exact?

/-
In a connected ring (no nontrivial idempotents), the spectrum
    is a connected topological space.
-/

theorem spec_connected_of_no_idempotents (R : Type*) [CommRing R]
    [Nontrivial R]
    (h : ∀ e : R, IsIdempotentElem e → e = 0 ∨ e = 1) :
    IsConnected (Set.univ : Set (PrimeSpectrum R)) := by
  -- Assume for contradiction that the spectrum is not connected.
  by_contra h_not_connected;
  -- Then there exist two non-empty clopen subsets $U$ and $V$ of $\operatorname{Spec}(R)$ such that $U \cup V = \operatorname{Spec}(R)$ and $U \cap V = \emptyset$.
  obtain ⟨U, V, hU_nonempty, hV_nonempty, hU_clopen, hV_clopen, hUV_union, hUV_disjoint⟩ : ∃ U V : Set (PrimeSpectrum R), U.Nonempty ∧ V.Nonempty ∧ IsClopen U ∧ IsClopen V ∧ U ∪ V = Set.univ ∧ Disjoint U V := by
    simp_all +decide [ IsConnected, IsPreconnected ];
    obtain ⟨ U, hU, V, hV, hUV, hU', hV', hUV' ⟩ := h_not_connected; use U, hU', V, hV'; simp_all +decide [ Set.disjoint_iff_inter_eq_empty ] ;
    simp_all +decide [ Set.ext_iff, IsClopen ];
    simp_all +decide [ Set.Nonempty, IsClosed ];
    exact ⟨ by rw [ show U = Vᶜ by ext x; specialize hUV x; aesop ] ; exact hV.isClosed_compl, by rw [ show V = Uᶜ by ext x; specialize hUV x; aesop ] ; exact hU.isClosed_compl ⟩;
  -- Since $U$ and $V$ are clopen, there exist idempotent elements $e$ and $f$ in $R$ such that $U = V(e)$ and $V = V(f)$.
  obtain ⟨e, he⟩ : ∃ e : R, IsIdempotentElem e ∧ U = PrimeSpectrum.zeroLocus {e} := by
    have hU_clopen : IsClopen U → ∃ e : R, IsIdempotentElem e ∧ U = PrimeSpectrum.zeroLocus {e} := by
      intro hU_clopen
      obtain ⟨I, hI⟩ : ∃ I : Ideal R, U = PrimeSpectrum.zeroLocus (I : Set R) := by
        obtain ⟨I, hI⟩ : ∃ I : Ideal R, U = PrimeSpectrum.zeroLocus (I : Set R) := by
          have h_closed : IsClosed U := hU_clopen.isClosed
          obtain ⟨ I, hI ⟩ := h_closed;
          use Ideal.span I;
          simp_all +decide [ Set.ext_iff, PrimeSpectrum.mem_zeroLocus ];
        use I;
      obtain ⟨J, hJ⟩ : ∃ J : Ideal R, Uᶜ = PrimeSpectrum.zeroLocus (J : Set R) := by
        have h_compl : IsClosed Uᶜ := by
          exact hU_clopen.isOpen.isClosed_compl;
        obtain ⟨ J, hJ ⟩ := h_compl;
        use Ideal.span J;
        simp_all +decide [ Set.ext_iff, PrimeSpectrum.mem_zeroLocus ];
      exact?;
    exact hU_clopen ‹_›
  obtain ⟨f, hf⟩ : ∃ f : R, IsIdempotentElem f ∧ V = PrimeSpectrum.zeroLocus {f} := by
    exact?;
  cases h e he.1 <;> cases h f hf.1 <;> simp_all +decide [ Set.ext_iff ]

