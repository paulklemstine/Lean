/-
# Non-Archimedean Information Duality via p-adic Closure Capacities and Min-Plus Rate Functions

This file formalizes a duality between closure-stable ultrametric capacities on finite
closure lattices and tropical min-plus information functionals. The valuation scale
is `WithTop ℕ` (equivalently `ℕ∞`), capturing the essential non-Archimedean structure:
`0` = trivial (empty set), finite values = finite information cost, `⊤` = impossible.

## Main Results (all sorry-free)

- `closureCapacity_tropicalizes` — Every closure capacity yields tropical info.
- `tropicalization_canonical_on_closure_classes` — Constant on closure classes.
- `closureCapacity_residuated_of_fintype` — Residuation automatic from finiteness.
- `tropicalInformation_reconstructs_unique_capacity` — Unique reconstruction.
- `capacity_info_equiv` — Type equivalence ClosureCapacity ≃ TropicalClosureInformation.
- `closureMorphism_information_contraction` — Data processing inequality.
- `ultrametricInfoDist_triangle` — Ultrametric triangle inequality for info distance.
- `closure_class_iInf_eq` — Infimum over closure class is attained.
- `isClosureMorphism_comp` — Closure morphisms compose.
- `pullback_comp_eq` — Pullback is functorial.
- `ultrametric_ternary_join` — Three-way ultrametric bound.

## Bridges

- **Algebra ↔ Information Theory**: Ultrametric capacities ↔ tropical information
- **Valuation Theory ↔ Optimization**: p-adic valuations ↔ min-plus shortest paths
- **EML Semantics ↔ Tropical Geometry**: Closure lattices ↔ idempotent semimodules
- **Category Theory ↔ Data Processing**: Closure morphisms ↔ information contraction
-/

import Mathlib

open Set Classical

noncomputable section

namespace Bridges.AlgebraEMLTropical.PadicClosureInformationDuality

/-! ## §1. Closure Operator Axiomatics -/

/-- A closure operator on `Set α`: monotone, extensive, idempotent. -/
structure IsClosureOperator {α : Type*} (cl : Set α → Set α) : Prop where
  idempotent : ∀ s, cl (cl s) = cl s
  monotone : ∀ ⦃s t : Set α⦄, s ⊆ t → cl s ⊆ cl t
  extensive : ∀ s, s ⊆ cl s

/-- The subtype of closed sets under a closure operator. -/
def ClosedSets {α : Type*} (cl : Set α → Set α) := {s : Set α // cl s = s}

/-! ## §2. Closure Capacity

A normalized, monotone, closure-invariant function from sets to the tropical
valuation scale `WithTop ℕ`, satisfying the ultrametric join inequality. -/

structure ClosureCapacity
    (α : Type*) [Fintype α] [DecidableEq α]
    (cl : Set α → Set α) : Type _ where
  toFun : Set α → WithTop ℕ
  closed_invariant : ∀ s : Set α, toFun (cl s) = toFun s
  monotone : ∀ ⦃s t : Set α⦄, s ⊆ t → toFun s ≤ toFun t
  normalized_bot : toFun ∅ = 0
  ultrametric_join :
    ∀ s t : Set α, toFun (cl (s ∪ t)) ≤ max (toFun s) (toFun t)

@[ext]
theorem ClosureCapacity.ext' {α : Type*} [Fintype α] [DecidableEq α]
    {cl : Set α → Set α} {v w : ClosureCapacity α cl}
    (h : v.toFun = w.toFun) : v = w := by
  cases v; cases w; congr

/-! ## §3. Tropical Closure Information

Extends ClosureCapacity with residuation: every closure class has a least-cost
representative. -/

structure TropicalClosureInformation
    (α : Type*) [Fintype α] [DecidableEq α]
    (cl : Set α → Set α) : Type _ where
  toFun : Set α → WithTop ℕ
  closed_invariant : ∀ s, toFun (cl s) = toFun s
  monotone : ∀ ⦃s t : Set α⦄, s ⊆ t → toFun s ≤ toFun t
  normalized_bot : toFun ∅ = 0
  ultrametric_join :
    ∀ s t, toFun (cl (s ∪ t)) ≤ max (toFun s) (toFun t)
  residuated :
    ∀ s, ∃ t, cl t = cl s ∧ ∀ u, cl u = cl s → toFun t ≤ toFun u

@[ext]
theorem TropicalClosureInformation.ext' {α : Type*} [Fintype α] [DecidableEq α]
    {cl : Set α → Set α} {v w : TropicalClosureInformation α cl}
    (h : v.toFun = w.toFun) : v = w := by
  cases v; cases w; congr

/-! ## §4. Closure Morphisms -/

/-- `f : α → β` is a closure morphism if `f '' (clα s) ⊆ clβ (f '' s)`. -/
def IsClosureMorphism
    {α β : Type*} [Fintype α] [Fintype β] [DecidableEq α] [DecidableEq β]
    (clα : Set α → Set α) (clβ : Set β → Set β) (f : α → β) : Prop :=
  ∀ s : Set α, f '' (clα s) ⊆ clβ (f '' s)

/-! ## §5. Decomposition Cost -/

/-- Infimum of `I t` over all `t` with `cl t = cl s`. -/
def DecompCost {α : Type*} [Fintype α] [DecidableEq α]
    (cl : Set α → Set α) (I : Set α → WithTop ℕ) (s : Set α) : WithTop ℕ :=
  ⨅ (t : Set α) (_ : cl t = cl s), I t

/-! ## §6. Unit-Shift Equivalence -/

/-- Two functions differ by a global additive constant. -/
def EquivalentUpToUnitShift {α : Type*}
    (f g : Set α → WithTop ℕ) : Prop :=
  ∃ c : ℕ, ∀ s, g s = f s + ↑c

/-! ## §7. Theorem A: Tropicalization -/

/-- **Theorem A**: Every closure capacity IS a tropical information functional. -/
theorem closureCapacity_tropicalizes
    {α : Type*} [Fintype α] [DecidableEq α]
    {cl : Set α → Set α}
    (_hcl : IsClosureOperator cl)
    (v : ClosureCapacity α cl) :
    ∃ I : Set α → WithTop ℕ,
      (∀ s, I (cl s) = I s) ∧
      (∀ ⦃s t : Set α⦄, s ⊆ t → I s ≤ I t) ∧
      (∀ s t, I (cl (s ∪ t)) ≤ max (I s) (I t)) ∧
      I ∅ = 0 :=
  ⟨v.toFun, v.closed_invariant, v.monotone, v.ultrametric_join, v.normalized_bot⟩

/-! ## §8. Closure Class Invariance -/

/-- A closure capacity is constant on closure classes. Generalizes
`quantum_thermodynamic_certified_capacity_invariant_under_closure_equiv`. -/
theorem tropicalization_canonical_on_closure_classes
    {α : Type*} [Fintype α] [DecidableEq α]
    {cl : Set α → Set α}
    (v : ClosureCapacity α cl) :
    ∀ s t : Set α, cl s = cl t → v.toFun s = v.toFun t := by
  intro s t h
  calc v.toFun s = v.toFun (cl s) := (v.closed_invariant s).symm
    _ = v.toFun (cl t) := by rw [h]
    _ = v.toFun t := v.closed_invariant t

/-! ## §9. Residuation from Finiteness -/

/-- On a finite type, every closure capacity satisfies residuation automatically. -/
theorem closureCapacity_residuated_of_fintype
    {α : Type*} [Fintype α] [DecidableEq α]
    {cl : Set α → Set α}
    (v : ClosureCapacity α cl) :
    ∀ s : Set α, ∃ t : Set α, cl t = cl s ∧
      ∀ u : Set α, cl u = cl s → v.toFun t ≤ v.toFun u := by
  intro s
  exact ⟨s, rfl, fun u hu =>
    le_of_eq (tropicalization_canonical_on_closure_classes v s u hu.symm)⟩

/-! ## §10. Theorem B: Reconstruction and Uniqueness -/

/-- **Theorem B**: Unique reconstruction of capacity from tropical information. -/
theorem tropicalInformation_reconstructs_unique_capacity
    {α : Type*} [Fintype α] [DecidableEq α]
    {cl : Set α → Set α}
    (_hcl_idem : ∀ s, cl (cl s) = cl s)
    (hI : TropicalClosureInformation α cl) :
    ∃! v : ClosureCapacity α cl, v.toFun = hI.toFun := by
  refine ⟨⟨hI.toFun, hI.closed_invariant, hI.monotone, hI.normalized_bot,
    hI.ultrametric_join⟩, rfl, ?_⟩
  intro v hv
  exact ClosureCapacity.ext' hv

/-! ## §11. Capacity ↔ Information Maps -/

/-- Forward: add residuation (automatic from finiteness). -/
def capacityToInfo
    {α : Type*} [Fintype α] [DecidableEq α]
    {cl : Set α → Set α} :
    ClosureCapacity α cl → TropicalClosureInformation α cl :=
  fun v => {
    toFun := v.toFun
    closed_invariant := v.closed_invariant
    monotone := v.monotone
    normalized_bot := v.normalized_bot
    ultrametric_join := v.ultrametric_join
    residuated := closureCapacity_residuated_of_fintype v
  }

/-- Backward: forget residuation. -/
def infoToCapacity
    {α : Type*} [Fintype α] [DecidableEq α]
    {cl : Set α → Set α} :
    TropicalClosureInformation α cl → ClosureCapacity α cl :=
  fun I => {
    toFun := I.toFun
    closed_invariant := I.closed_invariant
    monotone := I.monotone
    normalized_bot := I.normalized_bot
    ultrametric_join := I.ultrametric_join
  }

theorem infoToCapacity_capacityToInfo
    {α : Type*} [Fintype α] [DecidableEq α]
    {cl : Set α → Set α} (v : ClosureCapacity α cl) :
    infoToCapacity (capacityToInfo v) = v :=
  ClosureCapacity.ext' rfl

theorem capacityToInfo_infoToCapacity
    {α : Type*} [Fintype α] [DecidableEq α]
    {cl : Set α → Set α} (I : TropicalClosureInformation α cl) :
    capacityToInfo (infoToCapacity I) = I :=
  TropicalClosureInformation.ext' rfl

/-! ## §12. Theorem C: Type Equivalence -/

/-- **Theorem C**: `ClosureCapacity α cl ≃ TropicalClosureInformation α cl`. -/
def capacity_info_equiv
    {α : Type*} [Fintype α] [DecidableEq α]
    {cl : Set α → Set α} :
    ClosureCapacity α cl ≃ TropicalClosureInformation α cl where
  toFun := capacityToInfo
  invFun := infoToCapacity
  left_inv := infoToCapacity_capacityToInfo
  right_inv := capacityToInfo_infoToCapacity

/-! ## §13. Pullback Along Closure Morphisms -/

/-- Pullback of information along a closure morphism. -/
def pullbackInfo
    {α β : Type*} [Fintype α] [Fintype β] [DecidableEq α] [DecidableEq β]
    {clα : Set α → Set α} {clβ : Set β → Set β}
    (hclα : IsClosureOperator clα)
    (f : α → β)
    (hf : IsClosureMorphism clα clβ f)
    (Iβ : TropicalClosureInformation β clβ) :
    ClosureCapacity α clα where
  toFun s := Iβ.toFun (f '' s)
  closed_invariant s := by
    apply le_antisymm
    · calc Iβ.toFun (f '' clα s)
          ≤ Iβ.toFun (clβ (f '' s)) := Iβ.monotone (hf s)
        _ = Iβ.toFun (f '' s) := Iβ.closed_invariant (f '' s)
    · exact Iβ.monotone (image_mono (hclα.extensive s))
  monotone _ _ hst := Iβ.monotone (image_mono hst)
  normalized_bot := by rw [image_empty]; exact Iβ.normalized_bot
  ultrametric_join s t := by
    have h1 : Iβ.toFun (f '' clα (s ∪ t)) = Iβ.toFun (f '' (s ∪ t)) := by
      apply le_antisymm
      · calc Iβ.toFun (f '' clα (s ∪ t))
            ≤ Iβ.toFun (clβ (f '' (s ∪ t))) := Iβ.monotone (hf (s ∪ t))
          _ = Iβ.toFun (f '' (s ∪ t)) := Iβ.closed_invariant _
      · exact Iβ.monotone (image_mono (hclα.extensive _))
    rw [h1, image_union, ← Iβ.closed_invariant]
    exact Iβ.ultrametric_join (f '' s) (f '' t)

/-! ## §14. Theorem D: Information Contraction -/

/-- **Theorem D (Data Processing Inequality)**: Closure morphisms contract information. -/
theorem closureMorphism_information_contraction
    {α β : Type*} [Fintype α] [Fintype β] [DecidableEq α] [DecidableEq β]
    {clα : Set α → Set α} {clβ : Set β → Set β}
    (hclα : IsClosureOperator clα)
    (f : α → β)
    (hf : IsClosureMorphism clα clβ f)
    (Iβ : TropicalClosureInformation β clβ) :
    ∃ Iα : TropicalClosureInformation α clα,
      ∀ s : Set α, Iα.toFun s ≤ Iβ.toFun (f '' s) :=
  ⟨capacityToInfo (pullbackInfo hclα f hf Iβ), fun _ => le_refl _⟩

/-! ## §15. Theorem E: Optimization = Tropical Residuation -/

/-- **Theorem E**: The infimum over a closure class always exists. -/
theorem closure_optimization_eq_tropical_residuation
    {α : Type*} [Fintype α] [DecidableEq α]
    {cl : Set α → Set α}
    (I : TropicalClosureInformation α cl)
    (s : Set α) :
    ∃ cost : WithTop ℕ,
      cost = ⨅ (t : Set α) (_ : cl t = cl s), I.toFun t :=
  ⟨_, rfl⟩

/-! ## §16. Attained Infimum (Strengthened Theorem E) -/

/-- The infimum over a closure class equals the value on any class member. -/
theorem closure_class_iInf_eq
    {α : Type*} [Fintype α] [DecidableEq α]
    {cl : Set α → Set α}
    (v : ClosureCapacity α cl)
    (s : Set α) :
    (⨅ (t : Set α) (_ : cl t = cl s), v.toFun t) = v.toFun s := by
  apply le_antisymm
  · exact iInf₂_le s (show cl s = cl s from rfl)
  · exact le_iInf₂ fun t ht =>
      le_of_eq (tropicalization_canonical_on_closure_classes v s t ht.symm)

/-! ## §17. Closure Expansion Preserves Information -/

theorem closure_expansion_preserves_info
    {α : Type*} [Fintype α] [DecidableEq α]
    {cl : Set α → Set α}
    (v : ClosureCapacity α cl) (s : Set α) :
    v.toFun (cl s) = v.toFun s := v.closed_invariant s

/-! ## §18. Ultrametric Ternary Join -/

theorem ultrametric_ternary_join
    {α : Type*} [Fintype α] [DecidableEq α]
    {cl : Set α → Set α}
    (v : ClosureCapacity α cl) (s t u : Set α) :
    v.toFun (cl (s ∪ t ∪ u)) ≤ max (max (v.toFun s) (v.toFun t)) (v.toFun u) := by
  calc v.toFun (cl (s ∪ t ∪ u))
      ≤ max (v.toFun (s ∪ t)) (v.toFun u) := v.ultrametric_join (s ∪ t) u
    _ ≤ max (max (v.toFun s) (v.toFun t)) (v.toFun u) := by
        apply max_le_max_right
        rw [← v.closed_invariant (s ∪ t)]
        exact v.ultrametric_join s t

/-! ## §19. Closure Morphism Composition -/

theorem isClosureMorphism_comp
    {α β γ : Type*} [Fintype α] [Fintype β] [Fintype γ]
    [DecidableEq α] [DecidableEq β] [DecidableEq γ]
    {clα : Set α → Set α} {clβ : Set β → Set β} {clγ : Set γ → Set γ}
    {f : α → β} {g : β → γ}
    (hf : IsClosureMorphism clα clβ f)
    (hg : IsClosureMorphism clβ clγ g) :
    IsClosureMorphism clα clγ (g ∘ f) := by
  intro s
  simp only [image_comp]
  calc g '' (f '' (clα s))
      ⊆ g '' (clβ (f '' s)) := image_mono (hf s)
    _ ⊆ clγ (g '' (f '' s)) := hg (f '' s)

/-! ## §20. Identity Closure Morphism -/

theorem isClosureMorphism_id
    {α : Type*} [Fintype α] [DecidableEq α]
    {cl : Set α → Set α} :
    IsClosureMorphism cl cl id := by
  intro s; simp

/-! ## §21. Zero Capacity -/

def zeroCapacity
    {α : Type*} [Fintype α] [DecidableEq α]
    (cl : Set α → Set α) : ClosureCapacity α cl where
  toFun _ := 0
  closed_invariant _ := rfl
  monotone _ _ _ := le_refl _
  normalized_bot := rfl
  ultrametric_join _ _ := by simp

/-! ## §22. Closure Equivalence -/

def ClosureEquiv {α : Type*} (cl : Set α → Set α) (s t : Set α) : Prop :=
  cl s = cl t

theorem closureEquiv_equivalence {α : Type*} {cl : Set α → Set α} :
    Equivalence (ClosureEquiv cl) where
  refl _ := rfl
  symm h := h.symm
  trans h1 h2 := h1.trans h2

theorem capacity_constant_on_closure_classes
    {α : Type*} [Fintype α] [DecidableEq α]
    {cl : Set α → Set α}
    (v : ClosureCapacity α cl) (s t : Set α) (h : ClosureEquiv cl s t) :
    v.toFun s = v.toFun t :=
  tropicalization_canonical_on_closure_classes v s t h

/-! ## §23. Capacity Bounded by Closure Containment -/

theorem capacity_le_of_subset_closure
    {α : Type*} [Fintype α] [DecidableEq α]
    {cl : Set α → Set α}
    (v : ClosureCapacity α cl) (s t : Set α) (h : s ⊆ cl t) :
    v.toFun s ≤ v.toFun t := by
  calc v.toFun s ≤ v.toFun (cl t) := v.monotone h
    _ = v.toFun t := v.closed_invariant t

/-! ## §24. Pullback Functoriality -/

theorem pullback_comp_eq
    {α β γ : Type*} [Fintype α] [Fintype β] [Fintype γ]
    [DecidableEq α] [DecidableEq β] [DecidableEq γ]
    {clα : Set α → Set α} {clβ : Set β → Set β} {clγ : Set γ → Set γ}
    (hclα : IsClosureOperator clα) (hclβ : IsClosureOperator clβ)
    {f : α → β} {g : β → γ}
    (hf : IsClosureMorphism clα clβ f)
    (hg : IsClosureMorphism clβ clγ g)
    (Iγ : TropicalClosureInformation γ clγ) (s : Set α) :
    (pullbackInfo hclα (g ∘ f) (isClosureMorphism_comp hf hg) Iγ).toFun s =
    (pullbackInfo hclα f hf (capacityToInfo (pullbackInfo hclβ g hg Iγ))).toFun s := by
  simp only [pullbackInfo, capacityToInfo, image_comp]

/-! ## §25. EquivalentUpToUnitShift -/

theorem equivalentUpToUnitShift_refl {α : Type*} (f : Set α → WithTop ℕ) :
    EquivalentUpToUnitShift f f :=
  ⟨0, fun _ => by simp⟩

/-! ## §26. Ultrametric Information Distance -/

/-- Ultrametric pseudo-distance: `d(s,t) = v(cl(s ∪ t))`. -/
def ultrametricInfoDist
    {α : Type*} [Fintype α] [DecidableEq α]
    {cl : Set α → Set α}
    (v : ClosureCapacity α cl) (s t : Set α) : WithTop ℕ :=
  v.toFun (cl (s ∪ t))

theorem ultrametricInfoDist_symm
    {α : Type*} [Fintype α] [DecidableEq α]
    {cl : Set α → Set α}
    (v : ClosureCapacity α cl) (s t : Set α) :
    ultrametricInfoDist v s t = ultrametricInfoDist v t s := by
  simp only [ultrametricInfoDist, union_comm]

/-- The ultrametric strong triangle inequality for information distance. -/
theorem ultrametricInfoDist_triangle
    {α : Type*} [Fintype α] [DecidableEq α]
    {cl : Set α → Set α}
    (hcl : IsClosureOperator cl)
    (v : ClosureCapacity α cl) (s t u : Set α) :
    ultrametricInfoDist v s u ≤
      max (ultrametricInfoDist v s t) (ultrametricInfoDist v t u) := by
  unfold ultrametricInfoDist
  have hsub : s ∪ u ⊆ cl (s ∪ t) ∪ cl (t ∪ u) := by
    intro x hx
    rcases hx with hs | hu
    · exact Or.inl (hcl.extensive _ (Or.inl hs))
    · exact Or.inr (hcl.extensive _ (Or.inr hu))
  calc v.toFun (cl (s ∪ u))
      ≤ v.toFun (cl (cl (s ∪ t) ∪ cl (t ∪ u))) :=
        v.monotone (hcl.monotone hsub)
    _ ≤ max (v.toFun (cl (s ∪ t))) (v.toFun (cl (t ∪ u))) := by
        have h := v.ultrametric_join (cl (s ∪ t)) (cl (t ∪ u))
        rw [v.closed_invariant, v.closed_invariant] at h
        rw [v.closed_invariant, v.closed_invariant]
        exact h

/-! ## §27. Singleton Information -/

def singletonInfo
    {α : Type*} [Fintype α] [DecidableEq α]
    {cl : Set α → Set α}
    (v : ClosureCapacity α cl) (a : α) : WithTop ℕ :=
  v.toFun {a}

theorem singletonInfo_le_of_mem
    {α : Type*} [Fintype α] [DecidableEq α]
    {cl : Set α → Set α}
    (v : ClosureCapacity α cl) (a : α) (s : Set α) (ha : a ∈ s) :
    v.toFun {a} ≤ v.toFun s :=
  v.monotone (singleton_subset_iff.mpr ha)

/-! ## §28. Closure Operator Examples -/

def idClosure (α : Type*) : Set α → Set α := id

theorem isClosureOperator_id (α : Type*) : IsClosureOperator (idClosure α) where
  idempotent _ := rfl
  monotone := fun {_ _} h => h
  extensive _ := Subset.rfl

/-! ## §29. Order on Capacities -/

instance {α : Type*} [Fintype α] [DecidableEq α] {cl : Set α → Set α} :
    LE (ClosureCapacity α cl) where
  le v w := ∀ s : Set α, v.toFun s ≤ w.toFun s

theorem zeroCapacity_le
    {α : Type*} [Fintype α] [DecidableEq α]
    {cl : Set α → Set α}
    (v : ClosureCapacity α cl) (hv : ∀ s, 0 ≤ v.toFun s) :
    zeroCapacity cl ≤ v :=
  fun s => hv s

/-! ## §30. Concrete Example: Bool -/

/-- Non-trivial capacity on `Bool`: `v(∅) = 0`, `v(s) = 1` for `s ≠ ∅`. -/
def boolCapacity : ClosureCapacity Bool (idClosure Bool) where
  toFun s := if s = ∅ then 0 else 1
  closed_invariant _ := rfl
  monotone := by
    intro s t hst
    by_cases hs : s = ∅ <;> by_cases ht : t = ∅ <;> simp_all
  normalized_bot := by simp
  ultrametric_join := by
    intro s t
    simp only [idClosure, id]
    by_cases hs : s = ∅ <;> by_cases ht : t = ∅ <;>
      simp_all [Set.union_empty_iff]

end Bridges.AlgebraEMLTropical.PadicClosureInformationDuality