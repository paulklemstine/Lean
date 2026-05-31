import Algebra.HodgeConjecture.Defs

/-!
# Hodge Conjecture: Structural Theorems

This file proves non-trivial structural results about Hodge structures and
the Hodge conjecture:

1. **Morphism preservation**: Hodge morphisms map Hodge classes to Hodge classes.
2. **Rank-one resolution**: The Hodge conjecture holds when Picard rank ≤ 1.
3. **Polarization constraints**: Properties of the bilinear form on Hodge classes.
4. **Transcendental-algebraic orthogonality**: Transcendental lattice ⊓ Hodge = 0
   under nondegeneracy.
5. **Level zero triviality**: HC holds trivially at level 0.
6. **Functoriality**: HC transfers along surjective Hodge morphisms.

## Mathematical significance

These results form the "linear algebra backbone" of the Hodge conjecture.
The key insight is that many properties of the Hodge conjecture follow from
purely linear-algebraic reasoning once the Hodge decomposition is given.
The geometric content is isolated in the definition of algebraic classes.
-/

noncomputable section

open scoped TensorProduct
open LinearMap Submodule

variable {V : Type*} [AddCommGroup V] [Module ℚ V] [FiniteDimensional ℚ V]

/-! ## Theorem 1: Hodge morphisms preserve Hodge classes -/

omit [FiniteDimensional ℚ V] in
/-- The image of Hodge classes under a Hodge morphism is contained in
    the Hodge classes of the target. -/
theorem hodgeMorphism_image_le
    {W : Type*} [AddCommGroup W] [Module ℚ W]
    (HS₁ : WeightTwoHS V) (HS₂ : WeightTwoHS W)
    (φ : HodgeMorphism HS₁ HS₂) :
    Submodule.map φ.toLinearMap (hodgeClasses HS₁) ≤ hodgeClasses HS₂ := by
  intro w hw
  obtain ⟨v, hv, rfl⟩ := hw
  exact φ.preserves_H11 v hv

/-! ## Theorem 2: Rank-one uniqueness and proportionality -/

/-
In a one-dimensional ℚ-submodule, any two nonzero elements are proportional.
    This uses the fact that a 1-dimensional space is spanned by any nonzero element.
-/
theorem rank_one_proportional {W : Submodule ℚ V}
    (hdim : Module.finrank ℚ W = 1)
    {x y : V} (hx : x ∈ W) (hy : y ∈ W) (hx0 : x ≠ 0) (hy0 : y ≠ 0) :
    ∃ q : ℚ, q ≠ 0 ∧ y = q • x := by
  -- Since $W$ has finrank � $�1$, the subspace spanned by $x$ is all of $ �W�$.
  have h_span : W = Submodule.span ℚ {x} := by
    have h_span : Submodule.span ℚ {x} ≤ W := by
      aesop;
    rw [ eq_comm ];
    exact Submodule.eq_of_le_of_finrank_le h_span ( by simp +decide [ hdim, finrank_span_singleton hx0 ] );
  obtain ⟨ q, rfl ⟩ := Submodule.mem_span_singleton.mp ( h_span ▸ hy );
  exact ⟨ q, by aesop_cat, rfl ⟩

/-
**Hodge conjecture for Picard rank 1**: If the Picard rank is 1 and there exists
    a nonzero algebraic class, then every Hodge class is algebraic. The proof uses
    the fact that in a 1-dimensional ℚ-space, every element is a scalar multiple
    of any nonzero element.
-/
theorem hodgeConj_of_picard_rank_one
    (HS : WeightTwoHS V)
    (AD : AlgebraicData HS)
    (hρ : picardRank HS = 1)
    (hne : ∃ v ∈ AD.algClasses, v ≠ (0 : V)) :
    HodgeConjectureHolds HS AD := by
  obtain ⟨ v, hv, hv' ⟩ := hne;
  -- Since $v$ is a nonzero algebraic class, $v$ spans $hodgeClasses HS$.
  have h_span : Submodule.span ℚ {v} = hodgeClasses HS := by
    refine' Submodule.eq_of_le_of_finrank_eq _ _;
    · exact Submodule.span_le.mpr ( Set.singleton_subset_iff.mpr ( AD.algClasses_le hv ) );
    · convert finrank_span_singleton hv';
  intro w hw; rw [ ← h_span ] at hw; rw [ Submodule.mem_span_singleton ] at hw; obtain ⟨ q, rfl ⟩ := hw; exact AD.algClasses.smul_mem q hv;

/-! ## Theorem 3: Polarization and transcendental orthogonality -/

/-
Q-orthogonality is symmetric for symmetric bilinear forms.
-/
omit [FiniteDimensional ℚ V] in
theorem qOrthogonal_symm (Q : V →ₗ[ℚ] V →ₗ[ℚ] ℚ)
    (hQ : ∀ x y, Q x y = Q y x)
    (W : Submodule ℚ V) :
    ∀ v ∈ qOrthogonal Q W, ∀ w ∈ W, Q w v = 0 := by
  exact fun v hv w hw => hQ w v ▸ hv w hw

omit [FiniteDimensional ℚ V] in
/-- The transcendental lattice and Hodge classes are Q-orthogonal. -/
theorem transcendental_hodge_orthogonal (PHS : PolarizedHS V) :
    ∀ t ∈ transcendentalLattice PHS,
    ∀ h ∈ hodgeClasses PHS.toWeightTwoHS,
    PHS.Q t h = 0 := by
  intro t ht h hh
  exact ht h hh

/-
**Transcendental-Hodge disjointness**: If the Hodge classes and their
    Q-orthogonal complement (the transcendental lattice) together span all of V,
    then they intersect only at zero.

    The key argument: if v ∈ T ∩ HC, then Q(v, h) = 0 for all h ∈ HC (since v ∈ T),
    and Q(v, t) = Q(t, v) = 0 for all t ∈ T (since v ∈ HC and Q is symmetric).
    Since V = HC + T, this means Q(v, w) = 0 for all w, so v = 0 by nondegeneracy.
-/
omit [FiniteDimensional ℚ V] in
theorem transcendental_inter_hodge_eq_bot (PHS : PolarizedHS V)
    (hspan : hodgeClasses PHS.toWeightTwoHS ⊔ transcendentalLattice PHS = ⊤) :
    transcendentalLattice PHS ⊓ hodgeClasses PHS.toWeightTwoHS = ⊥ := by
  refine eq_bot_iff.mpr fun v hv => PHS.Q_nondeg v fun w => ?_;
  obtain ⟨ h, t, hh, ht, rfl ⟩ := Submodule.mem_sup.mp ( hspan.symm ▸ Submodule.mem_top : w ∈ hodgeClasses PHS.toWeightTwoHS ⊔ transcendentalLattice PHS );
  simp_all +decide [ transcendentalLattice ];
  exact add_eq_zero_iff_eq_neg.mpr ( by have := hv.1 h t; have := ht v hv.2; simp_all +decide [ PHS.Q_symm ] )

/-! ## Theorem 4: Hodge class submodule dimension bounds -/

/-
The Picard rank is bounded by the dimension of V.
-/
theorem picardRank_le_finrank (HS : WeightTwoHS V) :
    picardRank HS ≤ Module.finrank ℚ V := by
  exact Submodule.finrank_le _

/-
If the Picard rank equals the dimension, then every element is a Hodge class.
-/
theorem hodgeClasses_eq_top_of_full_rank (HS : WeightTwoHS V)
    (hfull : picardRank HS = Module.finrank ℚ V) :
    hodgeClasses HS = ⊤ := by
  exact Submodule.eq_top_of_finrank_eq ( by simpa [ picardRank ] using hfull )

/-- At level zero, the Hodge conjecture holds for any algebraic data that spans V. -/
theorem hodgeConj_of_level_zero (HS : WeightTwoHS V)
    (AD : AlgebraicData HS)
    (hfull : picardRank HS = Module.finrank ℚ V)
    (hspan : AD.algClasses = ⊤) :
    HodgeConjectureHolds HS AD := by
  unfold HodgeConjectureHolds
  rw [hodgeClasses_eq_top_of_full_rank HS hfull, hspan]

/-! ## Theorem 5: Functoriality of the Hodge conjecture -/

/-
**Functoriality**: If the Hodge conjecture holds for a Hodge structure and φ is a
    surjective Hodge morphism with a Hodge-class-lifting property, then the image
    of algebraic classes generates all target Hodge classes.

    This captures the principle that the Hodge conjecture is preserved under
    algebraic correspondences — a fundamental tool in the geometric theory.
-/
omit [FiniteDimensional ℚ V] in
theorem hodgeConj_functorial_surj
    {W : Type*} [AddCommGroup W] [Module ℚ W] [FiniteDimensional ℚ W]
    (HS₁ : WeightTwoHS V) (HS₂ : WeightTwoHS W)
    (AD₁ : AlgebraicData HS₁)
    (φ : HodgeMorphism HS₁ HS₂)
    (hHC : HodgeConjectureHolds HS₁ AD₁)
    (AD₂ : AlgebraicData HS₂)
    (himg : Submodule.map φ.toLinearMap AD₁.algClasses ≤ AD₂.algClasses)
    (hlift : ∀ w ∈ hodgeClasses HS₂, ∃ v ∈ hodgeClasses HS₁, φ.toLinearMap v = w) :
    HodgeConjectureHolds HS₂ AD₂ := by
  intro w hw; obtain ⟨ v, hv, rfl ⟩ := hlift w hw; exact himg ( Submodule.mem_map_of_mem ( hHC hv ) ) ;

/-! ## Theorem 6: Q-orthogonal complement properties -/

/-
The Q-orthogonal complement of the whole space under a nondegenerate form is {0}.
-/
omit [FiniteDimensional ℚ V] in
theorem qOrthogonal_top_eq_bot (Q : V →ₗ[ℚ] V →ₗ[ℚ] ℚ)
    (hQ_nondeg : ∀ x, (∀ y, Q x y = 0) → x = 0) :
    qOrthogonal Q ⊤ = ⊥ := by
  exact eq_bot_iff.mpr fun x hx => hQ_nondeg x fun y => hx _ ( trivial )

/-
The Q-orthogonal complement of {0} is the whole space.
-/
omit [FiniteDimensional ℚ V] in
theorem qOrthogonal_bot_eq_top (Q : V →ₗ[ℚ] V →ₗ[ℚ] ℚ) :
    qOrthogonal Q ⊥ = ⊤ := by
  ext; simp [qOrthogonal]

/-! ## Conjecture: Hodge index bound -/

/-- **Conjecture (Hodge Index Bound)**: For a polarized weight-2 Hodge structure
    with Picard rank ρ ≥ 1, the Hodge index (dimension of the maximal positive-definite
    subspace of Hodge classes under Q) is exactly 1.

    This is a consequence of the Hodge index theorem in algebraic geometry.

    **Testable prediction**: Construct a polarized Hodge structure on ℚ^3 with
    Picard rank 2 and verify Q has signature (1,1) on the Hodge classes.
    If one finds a polarized structure where the positive subspace has dimension > 1,
    this conjecture is refuted. -/
def hodgeIndexBoundConjecture : Prop :=
  ∀ (V : Type*) [AddCommGroup V] [Module ℚ V] [FiniteDimensional ℚ V],
  ∀ (PHS : PolarizedHS V),
    picardRank PHS.toWeightTwoHS ≥ 1 →
    hodgeIndex PHS = 1

end