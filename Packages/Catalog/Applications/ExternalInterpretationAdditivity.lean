/-
# The Definability Boundary, IV: The Meaning-Loss Exponent

Continuation of `Catalog/Applications/ExternalInterpretationDefinability.lean`,
`…Graphs.lean` and `…LogicalInvariance.lean`.

`card_interpretations_split` isolated the exponent

  `ℓ(M) = |M| − #orbits`

as the exact amount of external meaning that structural truth destroys: the
recoverable interpretations form a `|V|^{ℓ(M)}`-fold smaller family than all
interpretations.  This file develops `ℓ` as a structural invariant.

* `sumQuotEquiv` : the orbit space of a disjoint union of two models is the
  disjoint union of their orbit spaces, hence `card_orbits_sum`.
* `meaningLoss_sum` : **additivity**, `ℓ(M ⊕ N) = ℓ(M) + ℓ(N)`.
* `meaningLoss_eq_zero_iff_rigid` : `ℓ(M) = 0` exactly for rigid models, those in
  which structurally indistinguishable elements are equal; equivalently, every
  external interpretation is recoverable
  (`meaningLoss_eq_zero_iff_all_recoverable`).
* `meaningLoss_eq_sum_orbits` : `ℓ(M) = Σ_{orbits O} (|O| − 1)`, so the exponent
  counts exactly the "duplicate" elements inside orbits.
-/

import Catalog.Applications.ExternalInterpretationLogicalInvariance

namespace ExternalInterpretationAdditivity

open MulAction ExternalInterpretationDefinability ExternalInterpretationLogicalInvariance

universe u v w

variable {G : Type u} [Group G] {M N : Type v} [MulAction G M] [MulAction G N]

/-! ## Orbit spaces of disjoint unions -/

/-- The orbit space of a disjoint union of two `G`-models is the disjoint union of
the two orbit spaces. -/
def sumQuotEquiv (G : Type u) [Group G] (M N : Type v) [MulAction G M] [MulAction G N] :
    orbitRel.Quotient G (M ⊕ N) ≃ orbitRel.Quotient G M ⊕ orbitRel.Quotient G N where
  toFun := Quotient.lift
    (fun x => Sum.elim (fun a => Sum.inl (Quotient.mk (orbitRel G M) a))
      (fun b => Sum.inr (Quotient.mk (orbitRel G N) b)) x) (by
      intro a b hab
      have hr : (orbitRel G (M ⊕ N)) a b := hab
      rw [MulAction.orbitRel_apply, MulAction.mem_orbit_iff] at hr
      obtain ⟨g, hg⟩ := hr
      subst hg
      cases b with
      | inl b => exact congrArg Sum.inl (Quotient.sound ⟨g, rfl⟩)
      | inr b => exact congrArg Sum.inr (Quotient.sound ⟨g, rfl⟩))
  invFun := Sum.elim
    (Quotient.lift (fun a => Quotient.mk (orbitRel G (M ⊕ N)) (Sum.inl a)) (by
      intro a b hab
      have hr : (orbitRel G M) a b := hab
      rw [MulAction.orbitRel_apply, MulAction.mem_orbit_iff] at hr
      obtain ⟨g, hg⟩ := hr
      exact Quotient.sound ⟨g, by rw [← hg]; rfl⟩))
    (Quotient.lift (fun b => Quotient.mk (orbitRel G (M ⊕ N)) (Sum.inr b)) (by
      intro a b hab
      have hr : (orbitRel G N) a b := hab
      rw [MulAction.orbitRel_apply, MulAction.mem_orbit_iff] at hr
      obtain ⟨g, hg⟩ := hr
      exact Quotient.sound ⟨g, by rw [← hg]; rfl⟩))
  left_inv := by
    intro q
    induction q using Quotient.inductionOn with
    | h x => cases x <;> rfl
  right_inv := by
    rintro (q | q) <;> induction q using Quotient.inductionOn <;> rfl

/-- Orbits add across a disjoint union of models. -/
theorem card_orbits_sum [Fintype (orbitRel.Quotient G (M ⊕ N))]
    [Fintype (orbitRel.Quotient G M)] [Fintype (orbitRel.Quotient G N)] :
    Fintype.card (orbitRel.Quotient G (M ⊕ N))
      = Fintype.card (orbitRel.Quotient G M) + Fintype.card (orbitRel.Quotient G N) := by
  rw [Fintype.card_congr (sumQuotEquiv G M N), Fintype.card_sum]

/-! ## The meaning-loss exponent -/

/-- The **meaning-loss exponent** of a finite model: the number of elements minus
the number of automorphism orbits.  By `card_interpretations_split` the family of
recoverable interpretations is `|V|^{ℓ(M)}` times smaller than the family of all
interpretations. -/
def meaningLoss (G : Type u) (M : Type v) [Group G] [MulAction G M] [Fintype M]
    [Fintype (orbitRel.Quotient G M)] : ℕ :=
  Fintype.card M - Fintype.card (orbitRel.Quotient G M)

/-- **Additivity.**  Meaning loss is additive over disjoint unions of models. -/
theorem meaningLoss_sum [Fintype M] [Fintype N]
    [Fintype (orbitRel.Quotient G (M ⊕ N))]
    [Fintype (orbitRel.Quotient G M)] [Fintype (orbitRel.Quotient G N)] :
    meaningLoss G (M ⊕ N) = meaningLoss G M + meaningLoss G N := by
  have h1 : Fintype.card (orbitRel.Quotient G M) ≤ Fintype.card M := card_orbits_le
  have h2 : Fintype.card (orbitRel.Quotient G N) ≤ Fintype.card N := card_orbits_le
  have hsum := card_orbits_sum (G := G) (M := M) (N := N)
  unfold meaningLoss
  rw [hsum, Fintype.card_sum]
  omega

/-- **Rigidity criterion.**  The meaning-loss exponent vanishes exactly for rigid
models: those in which structural indistinguishability is equality. -/
theorem meaningLoss_eq_zero_iff_rigid [Fintype M] [Fintype (orbitRel.Quotient G M)] :
    meaningLoss G M = 0 ↔ ∀ x y : M, Indist G x y → x = y := by
  have hsurj : Function.Surjective (Quotient.mk (orbitRel G M)) := Quotient.mk_surjective
  have hle : Fintype.card (orbitRel.Quotient G M) ≤ Fintype.card M := card_orbits_le
  constructor
  · intro h x y hxy
    have hcard : Fintype.card M = Fintype.card (orbitRel.Quotient G M) := by
      unfold meaningLoss at h; omega
    have hbij : Function.Bijective (Quotient.mk (orbitRel G M)) :=
      (Fintype.bijective_iff_surjective_and_card _).mpr ⟨hsurj, hcard⟩
    exact hbij.1 (Quotient.sound (indist_iff_orbitRel.mp (indist_symm hxy)))
  · intro h
    have hinj : Function.Injective (Quotient.mk (orbitRel G M)) := by
      intro x y hxy
      have hr : (orbitRel G M) x y := Quotient.exact hxy
      rw [MulAction.orbitRel_apply, MulAction.mem_orbit_iff] at hr
      obtain ⟨g, hg⟩ := hr
      exact (h y x ⟨g, hg⟩).symm
    have hcard : Fintype.card M ≤ Fintype.card (orbitRel.Quotient G M) :=
      Fintype.card_le_of_injective _ hinj
    unfold meaningLoss
    omega

/-- Equivalently: nothing is lost precisely when *every* external interpretation
is recoverable from structural truth. -/
theorem meaningLoss_eq_zero_iff_all_recoverable [Fintype M] [Fintype (orbitRel.Quotient G M)]
    {V : Type w} (x₀ y₀ : V) (hne : x₀ ≠ y₀) :
    meaningLoss G M = 0 ↔ ∀ I : M → V, Recoverable G I := by
  classical
  rw [meaningLoss_eq_zero_iff_rigid]
  constructor
  · intro h I
    rw [recoverable_iff_orbitConstant]
    intro x y hxy
    rw [h x y hxy]
  · intro h x y hxy
    by_contra hne'
    have hI := h (fun z => if z = x then x₀ else y₀)
    rw [recoverable_iff_orbitConstant] at hI
    have h2 : (if x = x then x₀ else y₀) = (if y = x then x₀ else y₀) := hI hxy
    rw [if_pos rfl, if_neg (Ne.symm hne')] at h2
    exact hne h2

/-- **Orbit decomposition of the exponent.**  Meaning loss counts the duplicate
elements inside orbits: `ℓ(M) = Σ_{orbits O} (|O| − 1)`. -/
theorem meaningLoss_eq_sum_orbits [Fintype M] [Fintype (orbitRel.Quotient G M)]
    [∀ ω : orbitRel.Quotient G M, Fintype (orbit G (Quotient.out ω))] :
    meaningLoss G M
      = ∑ ω : orbitRel.Quotient G M, (Fintype.card (orbit G (Quotient.out ω)) - 1) := by
  classical
  have hcard : Fintype.card M
      = ∑ ω : orbitRel.Quotient G M, Fintype.card (orbit G (Quotient.out ω)) := by
    rw [Fintype.card_congr (MulAction.selfEquivSigmaOrbits G M), Fintype.card_sigma]
  have hpos : ∀ ω : orbitRel.Quotient G M, 1 ≤ Fintype.card (orbit G (Quotient.out ω)) := by
    intro ω
    exact Fintype.card_pos_iff.mpr ⟨⟨_, MulAction.mem_orbit_self _⟩⟩
  have hsub : ∀ (s : Finset (orbitRel.Quotient G M)),
      ∑ ω ∈ s, (Fintype.card (orbit G (Quotient.out ω)) - 1)
        = (∑ ω ∈ s, Fintype.card (orbit G (Quotient.out ω))) - s.card := by
    intro s
    induction s using Finset.induction with
    | empty => simp
    | insert a s ha ih =>
      rw [Finset.sum_insert ha, Finset.sum_insert ha, Finset.card_insert_of_notMem ha]
      have h1 : 1 ≤ Fintype.card (orbit G (Quotient.out a)) := hpos a
      have h3 : s.card ≤ ∑ ω ∈ s, Fintype.card (orbit G (Quotient.out ω)) := by
        calc s.card = ∑ _ω ∈ s, 1 := by simp
          _ ≤ _ := Finset.sum_le_sum fun ω _ => hpos ω
      rw [ih]
      omega
  unfold meaningLoss
  rw [hsub Finset.univ, ← hcard, Finset.card_univ]

end ExternalInterpretationAdditivity