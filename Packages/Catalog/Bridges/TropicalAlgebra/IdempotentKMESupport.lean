/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license.

# Support Duality and Identifiability for Idempotent Kernel Mean Embeddings

This file develops the support theory and identifiability results for tropical
(max-plus) kernel mean embeddings of maxitive measures on finite discrete spaces.

## Main results

* `MaxitiveMeasure.suppDiscrete` — discrete support definition
* `MaxitiveMeasure.measure_eq_biSup_singletons` — singleton decomposition
* `MaxitiveMeasure.ext_of_singletons` — extensionality from singletons
* `tropKME_injective_of_separating` — KME injectivity under separating kernel
* `tropKME_eq_imp_supp_eq` — KME equality implies support equality
* `identifiability_finite` — full identifiability
* `not_mem_weightSupp_iff_witness` — witness characterization of non-support
* `supp_eq_suppDiscrete` — topological = discrete support on discrete spaces

## Mathematical significance

These results establish that the tropical KME is **support-faithful** and,
under a separating kernel, **fully identifiable**. This upgrades the tropical
KME pipeline from representation theory to inverse theory.
-/

import Mathlib

open scoped BigOperators

/-! ## Maxitive Measures on Finite Types -/

/-- A maxitive measure on a type `α` with values in `EReal`. -/
structure MaxitiveMeasure (α : Type*) where
  toFun : Set α → EReal
  empty' : toFun ∅ = ⊥
  maxitive' : ∀ (A B : Set α), toFun (A ∪ B) = toFun A ⊔ toFun B

namespace MaxitiveMeasure

variable {α : Type*}

instance : CoeFun (MaxitiveMeasure α) (fun _ => Set α → EReal) where
  coe μ := μ.toFun

@[simp] theorem empty_eq (μ : MaxitiveMeasure α) : μ ∅ = ⊥ := μ.empty'

theorem maxitive_eq (μ : MaxitiveMeasure α) (A B : Set α) :
    μ (A ∪ B) = μ A ⊔ μ B := μ.maxitive' A B

theorem mono (μ : MaxitiveMeasure α) {A B : Set α} (h : A ⊆ B) :
    μ A ≤ μ B := by
  have : B = A ∪ B := (Set.union_eq_right.mpr h).symm
  rw [this, μ.maxitive_eq]; exact le_sup_left

theorem ext {μ ν : MaxitiveMeasure α} (h : ∀ s : Set α, μ s = ν s) : μ = ν := by
  cases μ; cases ν; congr; exact funext h

/-! ## Discrete Support -/

def suppDiscrete (μ : MaxitiveMeasure α) : Set α :=
  {x | μ {x} ≠ ⊥}

theorem mem_suppDiscrete_iff (μ : MaxitiveMeasure α) (x : α) :
    x ∈ μ.suppDiscrete ↔ μ {x} ≠ ⊥ := Iff.rfl

theorem not_mem_suppDiscrete_iff (μ : MaxitiveMeasure α) (x : α) :
    x ∉ μ.suppDiscrete ↔ μ {x} = ⊥ := by simp [suppDiscrete]

/-! ## Singleton Decomposition -/

/-
On a `Fintype`, the measure of a set equals the sup over its elements.
-/
theorem measure_eq_biSup_singletons [Fintype α]
    (μ : MaxitiveMeasure α) (s : Set α) :
    μ s = ⨆ x ∈ s, μ ({x} : Set α) := by
      -- Since $s$ is finite, it can be written as a finite union of singletons.
      have h_union : s = ⋃ x ∈ s, {x} := by
        aesop;
      have h_union : ∀ (t : Finset α), μ.toFun (⋃ x ∈ t, {x}) = ⨆ x ∈ t, μ.toFun {x} := by
        intro t
        induction' t using Finset.induction with x t ih;
        all_goals try exact Classical.decEq α;
        · simp +decide [ μ.empty' ];
        · convert μ.maxitive_eq { x } ( ⋃ x_1 ∈ t, { x_1 } ) using 1;
          · simp +decide [ Finset.set_biUnion_insert ];
          · simp +decide [ *, Finset.mem_insert, iSup_or, iSup_sup_eq ];
      convert h_union ( s.toFinset ) using 1;
      simp +decide [ Set.ext_iff ];
      convert rfl;
      swap;
      exacts [ Fintype.ofFinite _, by ext; simp +decide ]

/-- Extensionality from singletons. -/
theorem ext_of_singletons [Fintype α]
    {μ ν : MaxitiveMeasure α} (h : ∀ x : α, μ {x} = ν {x}) : μ = ν := by
  apply ext; intro s
  rw [measure_eq_biSup_singletons μ s, measure_eq_biSup_singletons ν s]
  congr 1; ext v; exact iSup_congr fun _ => h v

/-! ## Construction from Weights -/

noncomputable def ofWeights [Fintype α] (w : α → EReal) : MaxitiveMeasure α where
  toFun s := ⨆ x ∈ s, w x
  empty' := by simp
  maxitive' A B := by
    show (⨆ x ∈ A ∪ B, w x) = (⨆ x ∈ A, w x) ⊔ (⨆ x ∈ B, w x)
    simp only [Set.mem_union, iSup_or, iSup_sup_eq]

theorem ofWeights_singleton [Fintype α] (w : α → EReal) (x : α) :
    (ofWeights w) {x} = w x := by
      unfold ofWeights; aesop;

theorem eq_ofWeights [Fintype α] (μ : MaxitiveMeasure α) :
    μ = ofWeights (fun x => μ {x}) := by
  apply ext_of_singletons; intro x; rw [ofWeights_singleton]

/-! ## Tropical KME -/

noncomputable def tropKME_fun {α : Type*} [Fintype α]
    (k : α → α → ℝ) (w : α → EReal) : α → EReal :=
  fun y => ⨆ x, w x + (k x y : EReal)

theorem le_tropKME_fun {α : Type*} [Fintype α]
    (k : α → α → ℝ) (w : α → EReal) (x y : α) :
    w x + (k x y : EReal) ≤ tropKME_fun k w y :=
  le_iSup (fun x => w x + (k x y : EReal)) x

theorem tropKME_fun_mono {α : Type*} [Fintype α]
    {k : α → α → ℝ} {w₁ w₂ : α → EReal} (h : ∀ x, w₁ x ≤ w₂ x) :
    ∀ y, tropKME_fun k w₁ y ≤ tropKME_fun k w₂ y := by
  intro y; exact iSup_mono fun x => add_le_add_left (by exact_mod_cast h x) _

/-! ## Separating Kernel and Injectivity -/

structure TropSeparatingKernel (α : Type*) [Fintype α] where
  k : α → α → ℝ
  reconstruct : ∀ w : α → EReal, ∀ x,
    w x = ⨅ y, (tropKME_fun k w y) - (k x y : EReal)

theorem tropKME_injective_of_separating {α : Type*} [Fintype α]
    (K : TropSeparatingKernel α) :
    Function.Injective (tropKME_fun K.k) := by
  intro w₁ w₂ h; ext x; rw [K.reconstruct w₁ x, K.reconstruct w₂ x, h]

theorem tropKME_eq_iff {α : Type*} [Fintype α]
    (K : TropSeparatingKernel α) {w₁ w₂ : α → EReal} :
    tropKME_fun K.k w₁ = tropKME_fun K.k w₂ ↔ w₁ = w₂ :=
  ⟨fun h => tropKME_injective_of_separating K h, fun h => h ▸ rfl⟩

/-! ## Support of Weight Profiles -/

def weightSupp (w : α → EReal) : Set α := {x | w x ≠ ⊥}

theorem mem_weightSupp_iff (w : α → EReal) (x : α) :
    x ∈ weightSupp w ↔ w x ≠ ⊥ := Iff.rfl

theorem not_mem_weightSupp_iff (w : α → EReal) (x : α) :
    x ∉ weightSupp w ↔ w x = ⊥ := by simp [weightSupp]

/-! ## Support Identifiability -/

/-- **KME equality implies support equality** under a separating kernel. -/
theorem tropKME_eq_imp_supp_eq {α : Type*} [Fintype α]
    (K : TropSeparatingKernel α) {w₁ w₂ : α → EReal}
    (h : tropKME_fun K.k w₁ = tropKME_fun K.k w₂) :
    weightSupp w₁ = weightSupp w₂ := by
  have := tropKME_injective_of_separating K h; subst this; rfl

/-- Pointwise version. -/
theorem tropKME_eq_imp_mem_supp_iff {α : Type*} [Fintype α]
    (K : TropSeparatingKernel α) {w₁ w₂ : α → EReal}
    (h : tropKME_fun K.k w₁ = tropKME_fun K.k w₂) (x : α) :
    x ∈ weightSupp w₁ ↔ x ∈ weightSupp w₂ := by
  rw [tropKME_eq_imp_supp_eq K h]

/-- **Full identifiability**: KME equality ⟹ weight equality. -/
theorem tropKME_eq_imp_weights_eq {α : Type*} [Fintype α]
    (K : TropSeparatingKernel α) {w₁ w₂ : α → EReal}
    (h : tropKME_fun K.k w₁ = tropKME_fun K.k w₂) :
    w₁ = w₂ := tropKME_injective_of_separating K h

/-- **Maxitive measure identifiability**: KME equality ⟹ measure equality. -/
theorem identifiability_finite [Fintype α]
    (K : TropSeparatingKernel α) {μ ν : MaxitiveMeasure α}
    (h : tropKME_fun K.k (fun x => μ {x}) = tropKME_fun K.k (fun x => ν {x})) :
    μ = ν := by
  apply ext_of_singletons
  exact fun x => congr_fun (tropKME_injective_of_separating K h) x

/-! ## Witness Characterization -/

noncomputable def singletonIndicator [DecidableEq α] (x₀ : α) : α → EReal :=
  fun y => if y = x₀ then 0 else ⊥

@[simp] theorem singletonIndicator_self [DecidableEq α] (x : α) :
    singletonIndicator x x = 0 := by simp [singletonIndicator]

@[simp] theorem singletonIndicator_ne [DecidableEq α] {x y : α} (h : y ≠ x) :
    singletonIndicator x y = ⊥ := by simp [singletonIndicator, h]

theorem tropicalIntegral_singletonIndicator [Fintype α] [DecidableEq α]
    (w : α → EReal) (x : α) :
    (⨆ y, w y + singletonIndicator x y) = w x := by
      refine' le_antisymm _ _;
      · exact iSup_le fun y => by by_cases hy : y = x <;> simp +decide [ hy, singletonIndicator ] ;
      · exact le_iSup_of_le x ( by simp +decide [ singletonIndicator ] )

/-- **Witness characterization of non-support**. -/
theorem not_mem_weightSupp_iff_witness [Fintype α] [DecidableEq α]
    (w : α → EReal) (x : α) :
    x ∉ weightSupp w ↔ (⨆ y, w y + singletonIndicator x y) = ⊥ := by
  rw [not_mem_weightSupp_iff, tropicalIntegral_singletonIndicator]

theorem exists_witness_of_not_mem_supp [Fintype α] [DecidableEq α]
    (w : α → EReal) (x : α) (hx : x ∉ weightSupp w) :
    ∃ φ : α → EReal, φ x = 0 ∧ (∀ y, y ≠ x → φ y = ⊥) ∧
      (⨆ y, w y + φ y) = ⊥ :=
  ⟨singletonIndicator x, singletonIndicator_self x,
   fun y hy => singletonIndicator_ne hy,
   (not_mem_weightSupp_iff_witness w x).mp hx⟩

theorem singleton_witness_exists [DecidableEq α] (x : α) :
    ∃ φ : α → EReal, φ x = 0 ∧ ∀ y, y ≠ x → φ y = ⊥ :=
  ⟨singletonIndicator x, singletonIndicator_self x, fun y hy => singletonIndicator_ne hy⟩

theorem singleton_witness_integral [Fintype α] [DecidableEq α]
    (w : α → EReal) (x : α) (φ : α → EReal)
    (hself : φ x = 0) (hother : ∀ y, y ≠ x → φ y = ⊥) :
    (⨆ y, w y + φ y) = w x := by
      convert tropicalIntegral_singletonIndicator w x using 1;
      exact iSup_congr fun y => by unfold singletonIndicator; aesop;

/-! ## Topological Support -/

def supp [TopologicalSpace α] (μ : MaxitiveMeasure α) : Set α :=
  {x | ∀ s : Set α, IsOpen s → x ∈ s → μ s ≠ ⊥}

theorem supp_eq_suppDiscrete [Fintype α]
    [TopologicalSpace α] [DiscreteTopology α] (μ : MaxitiveMeasure α) :
    μ.supp = μ.suppDiscrete := by
      ext x; simp +decide [ MaxitiveMeasure.suppDiscrete, MaxitiveMeasure.supp ];
      constructor;
      · exact fun h => h _ ( Set.mem_singleton x );
      · exact fun h s hx => ne_of_gt ( lt_of_lt_of_le ( lt_of_le_of_ne bot_le ( Ne.symm h ) ) ( μ.mono ( Set.singleton_subset_iff.mpr hx ) ) )

theorem not_mem_supp_iff_exists_clopen_discrete [Fintype α]
    [TopologicalSpace α] [DiscreteTopology α] (μ : MaxitiveMeasure α) (x : α) :
    x ∉ μ.supp ↔ ∃ s : Set α, IsClopen s ∧ x ∈ s ∧ μ s = ⊥ := by
      unfold MaxitiveMeasure.supp; aesop;

/-! ## Witness Separation -/

theorem tropKME_eq_imp_integral_eq [Fintype α] [DecidableEq α]
    (K : TropSeparatingKernel α) {w₁ w₂ : α → EReal}
    (h : tropKME_fun K.k w₁ = tropKME_fun K.k w₂)
    (φ : α → EReal) :
    (⨆ y, w₁ y + φ y) = (⨆ y, w₂ y + φ y) := by
  have := tropKME_injective_of_separating K h; subst this; rfl

theorem tropKME_eq_imp_singleton_eq [Fintype α] [DecidableEq α]
    (K : TropSeparatingKernel α) {w₁ w₂ : α → EReal}
    (h : tropKME_fun K.k w₁ = tropKME_fun K.k w₂) (x : α) :
    w₁ x = w₂ x := by
  have := tropKME_injective_of_separating K h; subst this; rfl

/-- Distinct weight profiles produce distinct KMEs under a separating kernel. -/
theorem tropKME_witness_separation {α : Type*} [Fintype α]
    (K : TropSeparatingKernel α) {w₁ w₂ : α → EReal}
    (hneq : w₁ ≠ w₂) :
    ∃ y, tropKME_fun K.k w₁ y ≠ tropKME_fun K.k w₂ y := by
  by_contra h; push_neg at h
  exact hneq (tropKME_injective_of_separating K (funext h))

/-! ## Residuation -/

theorem tropKME_residuation_upper {α : Type*} [Fintype α]
    (k : α → α → ℝ) (w : α → EReal) (x : α) :
    w x ≤ ⨅ y, tropKME_fun k w y - (k x y : EReal) := by
      refine' le_iInf fun y => _;
      by_contra h_contra;
      cases h : w x <;> cases h' : tropKME_fun k w y <;> simp_all +decide [ sub_eq_add_neg ];
      · unfold tropKME_fun at h';
        aesop;
      · norm_cast at *;
        rename_i a b;
        have := le_tropKME_fun k w x y;
        rw [ h, h' ] at this ; norm_cast at this ; linarith;
      · exact absurd h' ( ne_of_gt ( lt_of_lt_of_le ( by simp +decide [ h ] ) ( le_tropKME_fun k w x y ) ) );
      · unfold tropKME_fun at h';
        exact absurd ( h' ▸ le_ciSup ( Finite.bddAbove_range fun x => w x + ( k x y : EReal ) ) x ) ( by simp +decide [ h ] )

structure TropWitnessSeparatingKernel (α : Type*) [Fintype α] extends
    TropSeparatingKernel α where
  witness : ∀ w : α → EReal, ∀ x,
    ∃ y, tropKME_fun k w y - (k x y : EReal) ≤ w x

end MaxitiveMeasure