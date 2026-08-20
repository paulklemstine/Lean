import Physics.PlanckFoamTopology

/-!
# The universal property and the combinatorial skeleton of Planck foam

This file continues `Physics.PlanckFoamTopology` with two structural results
about the Wheeler foam `Foam X S ι`.

1. **Hausdorff invisibility (universal property).**  The macroscopic projection
   `proj : Foam X S ι → X` is a quotient map, and when the branch locus has
   empty interior *every* continuous map from the foam to a Hausdorff space
   factors uniquely through `X` (`exists_unique_hausdorff_factorization`).  In
   other words, `X` is the universal Hausdorff-valued receptacle of the foam:
   no Hausdorff-valued observable can see the Planck-scale branching, even
   though the foam is not homeomorphic to `X`.

2. **Combinatorial skeleton.**  As a set the foam splits as
   `Sᶜ ⊕ (S × ι)` (`foamEquiv`), whence the counting formula
   `Nat.card (Foam X S ι) = Nat.card Sᶜ + Nat.card S * Nat.card ι`
   (`card_foam`).  The "excess" of the foam over the base is exactly one extra
   point per branch point per extra sheet.

3. **Position in the separation hierarchy.**  A foam with a non-interior branch
   point is T1 but fails even the weaker axiom R1 (`not_r1Space_foam`), so its
   failure of Hausdorffness is not repairable by passing to the Kolmogorov
   quotient.
-/

open Set Topology Filter

namespace PlanckFoam

variable {X : Type*} [TopologicalSpace X] {ι : Type*} [TopologicalSpace ι]
  [DiscreteTopology ι] {S : Set X}

/-! ### The projection is a quotient map -/

theorem isQuotientMap_proj [Nonempty ι] : IsQuotientMap (proj S ι) := by
  refine isQuotientMap_iff.2 ⟨surjective_proj, fun U => ⟨fun hU => hU.preimage continuous_proj, ?_⟩⟩
  intro hU
  have := (isOpen_iff (proj S ι ⁻¹' U)).1 hU (Classical.arbitrary ι)
  simpa using this

/-- **Hausdorff invisibility of the foam.** If the branch locus has empty
interior, every continuous map from the foam into a Hausdorff space factors
uniquely and continuously through the macroscopic projection. -/
theorem exists_unique_hausdorff_factorization [Nonempty ι] (hS : interior S = ∅)
    {Y : Type*} [TopologicalSpace Y] [T2Space Y] {f : Foam X S ι → Y} (hf : Continuous f) :
    ∃! g : X → Y, Continuous g ∧ f = g ∘ proj S ι := by
  classical
  set i₀ := Classical.arbitrary ι with hi₀
  refine ⟨f ∘ sheet S i₀, ⟨hf.comp (continuous_sheet i₀), ?_⟩, ?_⟩
  · funext u
    obtain ⟨i, x, rfl⟩ := exists_sheet u
    exact (eq_of_continuous_t2 hf (by simp [hS])).symm
  · rintro g ⟨-, hg⟩
    funext x
    have := congrFun hg (sheet S i₀ x)
    simpa using this.symm

omit [DiscreteTopology ι] in
/-- The foam is *not* homeomorphic to its Hausdorff shadow: a branch point with
non-open branch locus yields two distinct points with the same image. -/
theorem proj_not_injective [Nontrivial ι] {x : X} (hx : x ∈ S) :
    ¬ Function.Injective (proj S ι) := by
  obtain ⟨i, j, hij⟩ := exists_pair_ne ι
  intro h
  exact sheet_ne_sheet hij hx (h (by simp))

/-! ### The combinatorial skeleton -/

/-- The map assembling the foam out of the non-branching part `Sᶜ` and `|ι|`
copies of the branch locus `S`. -/
def skeletonMap (S : Set X) (i₀ : ι) : (↥(Sᶜ) ⊕ (↥S × ι)) → Foam X S ι
  | Sum.inl x => sheet S i₀ (x : X)
  | Sum.inr p => sheet S p.2 (p.1 : X)

omit [DiscreteTopology ι] in
theorem skeletonMap_bijective (i₀ : ι) : Function.Bijective (skeletonMap S i₀) := by
  constructor
  · rintro (⟨x, hx⟩ | ⟨⟨x, hx⟩, i⟩) (⟨y, hy⟩ | ⟨⟨y, hy⟩, j⟩) hEq <;>
      simp only [skeletonMap] at hEq
    · exact congrArg Sum.inl (Subtype.ext (sheet_eq_sheet.1 hEq).1)
    · obtain ⟨rfl, -⟩ := sheet_eq_sheet.1 hEq
      exact absurd hy hx
    · obtain ⟨rfl, -⟩ := sheet_eq_sheet.1 hEq
      exact absurd hx hy
    · obtain ⟨rfl, hc⟩ := sheet_eq_sheet.1 hEq
      have : i = j := hc.resolve_right (not_not.2 hx)
      subst this
      rfl
  · intro u
    obtain ⟨i, x, rfl⟩ := exists_sheet u
    by_cases hx : x ∈ S
    · exact ⟨Sum.inr ⟨⟨x, hx⟩, i⟩, rfl⟩
    · exact ⟨Sum.inl ⟨x, hx⟩, sheet_eq_sheet_of_notMem hx⟩

/-- **Skeleton decomposition.** As a set, the Wheeler foam is the disjoint union
of the non-branching part of `X` and `|ι|` copies of the branch locus. -/
noncomputable def foamEquiv (i₀ : ι) : (↥(Sᶜ) ⊕ (↥S × ι)) ≃ Foam X S ι :=
  Equiv.ofBijective _ (skeletonMap_bijective i₀)

omit [DiscreteTopology ι] in
/-- Counting formula for a finite foam. -/
theorem card_foam [Finite X] [Finite ι] [Nonempty ι] :
    Nat.card (Foam X S ι) = Nat.card ↥(Sᶜ) + Nat.card ↥S * Nat.card ι := by
  rw [← Nat.card_congr (foamEquiv (S := S) (Classical.arbitrary ι)), Nat.card_sum,
    Nat.card_prod]

/-! ### Position in the separation hierarchy -/

/-- A foam with a branch point outside the interior of the branch locus is not
even R1: distinct, topologically distinguishable points have non-disjoint
neighbourhood filters. -/
theorem not_r1Space_foam [T1Space X] [Nontrivial ι] {x : X} (hx : x ∈ S)
    (hx' : x ∉ interior S) : ¬ R1Space (Foam X S ι) := by
  obtain ⟨i, j, hij⟩ := exists_pair_ne ι
  intro h
  haveI : T1Space (Foam X S ι) := t1Space_foam_iff.2 ‹T1Space X›
  rcases h.specializes_or_disjoint_nhds (sheet S i x) (sheet S j x) with hspec | hdisj
  · exact sheet_ne_sheet hij hx hspec.eq
  · exact nhds_branch_not_disjoint hx' hdisj

/-- Consequently a Planck foam with a non-interior branch point is not regular
either, so Urysohn's metrization theorem fails for it through the failure of
regularity, not of second countability. -/
theorem not_regularSpace_foam [T1Space X] [Nontrivial ι] {x : X} (hx : x ∈ S)
    (hx' : x ∉ interior S) : ¬ RegularSpace (Foam X S ι) := by
  intro h
  haveI := h
  exact not_r1Space_foam (S := S) (ι := ι) hx hx' inferInstance

end PlanckFoam