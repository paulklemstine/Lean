/-
Copyright (c) 2025. All rights reserved.

# Tropical Valuation Functor from Commutative Semirings to Closure-Stable Probe Systems

The central construction: every tropical valuation v : R → ℕ∞ on a commutative
semiring canonically induces a closure operator on subsets of R whose closure-stable
probes are **exactly** those observables that factor through v.

## Main Results

* `levelSetClosure_extensive` — valuation closure is extensive
* `levelSetClosure_mono` — valuation closure is monotone
* `levelSetClosure_idem_eq` — valuation closure is idempotent
* `closure_stable_iff_factors` — a probe is closure-stable iff it factors
  through the valuation
* `thresholdProbe_closure_stable` — threshold probes are closure-stable
* `mul_closure_compatible` — level-set closure respects multiplication
* `closure_eq_iff_level_sets_eq` — complete characterization of closure equivalence
* `morphism_preserves_closure` — valuation-preserving maps preserve closures
* `tropical_valuation_closure_bridge` — main bridge theorem
-/

import Mathlib

open Set

noncomputable section

namespace TropicalValuationClosureBridge

/-! ## §1. Tropical Valuation — The Fundamental Structure -/

/-- A **tropical valuation** on a commutative semiring `R`.
Maps `R` into `ℕ∞ = WithTop ℕ` viewed as the tropical semiring. -/
structure TropicalValuation (R : Type*) [CommMonoidWithZero R] [Add R] where
  val : R → ℕ∞
  val_zero : val 0 = ⊤
  val_one : val 1 = 0
  val_mul : ∀ a b, val (a * b) = val a + val b
  val_add_le : ∀ a b, min (val a) (val b) ≤ val (a + b)

/-! ## §2. Level-Set Closure Operator -/

/-- The **level-set closure** induced by a valuation function.
`levelSetClosure v S = {x | ∃ s ∈ S, v x = v s}` -/
def levelSetClosure {σ : Type*} (v : σ → ℕ∞) (S : Set σ) : Set σ :=
  {x | ∃ s ∈ S, v x = v s}

/-! ## §3. Closure Axioms -/

/-- **Extensivity**: every set is contained in its level-set closure. -/
theorem levelSetClosure_extensive {σ : Type*} (v : σ → ℕ∞) (S : Set σ) :
    S ⊆ levelSetClosure v S :=
  fun x hx => ⟨x, hx, rfl⟩

/-- **Monotonicity**: the level-set closure is order-preserving on sets. -/
theorem levelSetClosure_mono {σ : Type*} (v : σ → ℕ∞) :
    Monotone (levelSetClosure v) :=
  fun _ _ hST _ ⟨s, hs, hv⟩ => ⟨s, hST hs, hv⟩

/-- **Idempotence** (⊆ direction): the closure chains valuation equalities. -/
theorem levelSetClosure_idem {σ : Type*} (v : σ → ℕ∞) (S : Set σ) :
    levelSetClosure v (levelSetClosure v S) ⊆ levelSetClosure v S :=
  fun _ ⟨_, ⟨s, hs, hvy⟩, hvx⟩ => ⟨s, hs, hvx.trans hvy⟩

/-- **Idempotence** (equality form): `cl(cl(S)) = cl(S)`. -/
theorem levelSetClosure_idem_eq {σ : Type*} (v : σ → ℕ∞) (S : Set σ) :
    levelSetClosure v (levelSetClosure v S) = levelSetClosure v S :=
  Subset.antisymm (levelSetClosure_idem v S)
    (levelSetClosure_mono v (levelSetClosure_extensive v S))

/-- The level-set closure of the empty set is empty. -/
theorem levelSetClosure_empty {σ : Type*} (v : σ → ℕ∞) :
    levelSetClosure v ∅ = ∅ := by
  ext x; simp [levelSetClosure]

/-! ## §4. Closure System Abstraction -/

/-- A **closure system** on a type. -/
structure ClosureSystem (σ : Type*) where
  closure : Set σ → Set σ
  extensive : ∀ S, S ⊆ closure S
  mono : ∀ ⦃S T⦄, S ⊆ T → closure S ⊆ closure T
  idem : ∀ S, closure (closure S) ⊆ closure S

/-- Every valuation function induces a closure system. -/
def valuationClosureSystem {σ : Type*} (v : σ → ℕ∞) : ClosureSystem σ where
  closure := levelSetClosure v
  extensive := levelSetClosure_extensive v
  mono := fun {_S} {_T} h => levelSetClosure_mono v h
  idem := levelSetClosure_idem v

/-! ## §5. Closure-Stable Probes: The Characterization Theorem -/

/-- A probe `p` **factors through** the valuation `v`. -/
def FactorsThroughVal {σ : Type*} {K : Type*} (v : σ → ℕ∞) (p : σ → K) : Prop :=
  ∀ x y, v x = v y → p x = p y

/-- A probe is **closure-stable** for the level-set closure. -/
def IsClosureStable {σ : Type*} {K : Type*} (v : σ → ℕ∞) (p : σ → K) : Prop :=
  ∀ S : Set σ, ∀ x ∈ levelSetClosure v S, ∃ y ∈ S, p x = p y

/-- **Main Characterization Theorem**: A probe is closure-stable iff
it factors through the valuation.

(→) Singleton sets force p to be constant on v-fibers.
(←) The valuation witness from the closure directly gives the probe equality. -/
theorem closure_stable_iff_factors {σ : Type*} {K : Type*}
    (v : σ → ℕ∞) (p : σ → K) :
    IsClosureStable v p ↔ FactorsThroughVal v p := by
  constructor
  · intro hstable x y hv
    have hx : x ∈ levelSetClosure v {y} := ⟨y, rfl, hv⟩
    obtain ⟨z, hz_mem, hz_eq⟩ := hstable {y} x hx
    rwa [hz_mem] at hz_eq
  · intro hfact S x ⟨s, hs, hv⟩
    exact ⟨s, hs, hfact x s hv⟩

/-! ## §6. Threshold Probes Are Closure-Stable -/

/-- The **threshold probe** at level `n`: returns 1 if valuation ≤ n, else 0. -/
def thresholdProbe {σ : Type*} (v : σ → ℕ∞) (n : ℕ∞) : σ → ℕ :=
  fun x => if v x ≤ n then 1 else 0

/-- Threshold probes factor through the valuation. -/
theorem thresholdProbe_factors {σ : Type*} (v : σ → ℕ∞) (n : ℕ∞) :
    FactorsThroughVal v (thresholdProbe v n) :=
  fun _ _ hv => by simp [thresholdProbe, hv]

/-- **Threshold probes are closure-stable**. -/
theorem thresholdProbe_closure_stable {σ : Type*} (v : σ → ℕ∞) (n : ℕ∞) :
    IsClosureStable v (thresholdProbe v n) :=
  (closure_stable_iff_factors v _).mpr (thresholdProbe_factors v n)

/-- Every probe in the threshold family is closure-stable. -/
theorem thresholdProbeFamily_all_stable {σ : Type*} (v : σ → ℕ∞) :
    ∀ n : ℕ∞, IsClosureStable v (thresholdProbe v n) :=
  thresholdProbe_closure_stable v

/-! ## §7. Multiplicative Compatibility (Tropical Functoriality)

Products of closure elements lie in the closure of the product:
v(xy) = v(x) + v(y) = v(a) + v(b) = v(ab). -/

/-- **Multiplicative compatibility**: the level-set closure respects
the semiring multiplication. -/
theorem mul_closure_compatible {R : Type*} [CommMonoidWithZero R] [Add R]
    (tv : TropicalValuation R) {a b : R} (x y : R)
    (hx : x ∈ levelSetClosure tv.val {a})
    (hy : y ∈ levelSetClosure tv.val {b}) :
    x * y ∈ levelSetClosure tv.val {a * b} := by
  obtain ⟨a', ha', hva⟩ := hx
  obtain ⟨b', hb', hvb⟩ := hy
  refine ⟨a * b, rfl, ?_⟩
  change a' = a at ha'; change b' = b at hb'
  subst ha'; subst hb'
  rw [tv.val_mul, tv.val_mul, hva, hvb]

/-! ## §8. The Closure Determines the Valuation -/

/-- **The closure determines level sets**: if two valuations induce the
same closure operator, they have the same level-set partition. -/
theorem closure_determines_level_sets {σ : Type*} (v₁ v₂ : σ → ℕ∞)
    (h : levelSetClosure v₁ = levelSetClosure v₂) :
    ∀ x y, v₁ x = v₁ y ↔ v₂ x = v₂ y := by
  intro x y
  have h1 : levelSetClosure v₁ {y} = levelSetClosure v₂ {y} := congr_fun h {y}
  constructor
  · intro hv1
    have : x ∈ levelSetClosure v₁ {y} := ⟨y, rfl, hv1⟩
    rw [h1] at this
    obtain ⟨s, hs, hvs⟩ := this
    rwa [hs] at hvs
  · intro hv2
    have : x ∈ levelSetClosure v₂ {y} := ⟨y, rfl, hv2⟩
    rw [← h1] at this
    obtain ⟨s, hs, hvs⟩ := this
    rwa [hs] at hvs

/-- **Converse**: valuations with the same level sets give the same closure. -/
theorem same_level_sets_same_closure {σ : Type*} (v₁ v₂ : σ → ℕ∞)
    (h : ∀ x y, v₁ x = v₁ y ↔ v₂ x = v₂ y) :
    levelSetClosure v₁ = levelSetClosure v₂ := by
  funext S; ext x
  simp only [levelSetClosure, mem_setOf_eq]
  constructor
  · rintro ⟨s, hs, hv⟩; exact ⟨s, hs, (h x s).mp hv⟩
  · rintro ⟨s, hs, hv⟩; exact ⟨s, hs, (h x s).mpr hv⟩

/-- **Complete characterization**: two valuations give the same closure
iff they partition the domain identically. -/
theorem closure_eq_iff_level_sets_eq {σ : Type*} (v₁ v₂ : σ → ℕ∞) :
    levelSetClosure v₁ = levelSetClosure v₂ ↔
    (∀ x y, v₁ x = v₁ y ↔ v₂ x = v₂ y) :=
  ⟨closure_determines_level_sets v₁ v₂, same_level_sets_same_closure v₁ v₂⟩

/-! ## §9. Functoriality Under Valuation-Preserving Morphisms -/

/-- Valuation-preserving maps send closures into closures. -/
theorem morphism_preserves_closure {σ τ : Type*} {v : σ → ℕ∞} {w : τ → ℕ∞}
    (f : σ → τ) (hf : ∀ x, w (f x) = v x) (S : Set σ) :
    f '' (levelSetClosure v S) ⊆ levelSetClosure w (f '' S) := by
  rintro _ ⟨x, ⟨s, hs, hvxs⟩, rfl⟩
  exact ⟨f s, ⟨s, hs, rfl⟩, by rw [hf, hf, hvxs]⟩

/-- If f is surjective and preserves valuations, image of closure = closure of image. -/
theorem surj_morphism_closure_eq {σ τ : Type*} {v : σ → ℕ∞} {w : τ → ℕ∞}
    (f : σ → τ) (hf : ∀ x, w (f x) = v x) (hfsurj : Function.Surjective f)
    (S : Set σ) :
    f '' (levelSetClosure v S) = levelSetClosure w (f '' S) := by
  apply Subset.antisymm (morphism_preserves_closure f hf S)
  rintro t ⟨ft_s, ⟨s, hs, rfl⟩, hwt⟩
  obtain ⟨x, rfl⟩ := hfsurj t
  refine ⟨x, ⟨s, hs, ?_⟩, rfl⟩
  rw [hf, hf] at hwt; exact hwt

/-! ## §10. Refinement Ordering -/

/-- If v is finer than w (separates more), then cl_v ⊆ cl_w. -/
theorem finer_val_smaller_closure {σ : Type*} (v w : σ → ℕ∞)
    (h : ∀ x y, v x = v y → w x = w y) (S : Set σ) :
    levelSetClosure v S ⊆ levelSetClosure w S :=
  fun _ ⟨s, hs, hv⟩ => ⟨s, hs, h _ _ hv⟩

/-! ## §11. The p-Adic Tropical Valuation Instance -/

/-- The p-adic tropical valuation on ℕ, via extended multiplicity. -/
def padicTropVal (p : ℕ) [hp : Fact (Nat.Prime p)] : TropicalValuation ℕ where
  val := emultiplicity p
  val_zero := emultiplicity_zero p
  val_one := hp.out.emultiplicity_one
  val_mul := fun _a _b => emultiplicity_mul hp.out.prime
  val_add_le := fun _ _ => min_le_emultiplicity_add

/-- The p-adic closure system on ℕ. -/
def padicClosureSystem (p : ℕ) [Fact (Nat.Prime p)] : ClosureSystem ℕ :=
  valuationClosureSystem (padicTropVal p).val

/-! ## §12. Absorption Profile -/

/-- The closure of a singleton is exactly its v-fiber. -/
theorem singleton_closure_fiber {σ : Type*} (v : σ → ℕ∞) (a : σ) :
    levelSetClosure v {a} = {x | v x = v a} := by
  ext x; simp [levelSetClosure]

/-- Union absorption: cl(S ∪ T) ⊇ cl(S) ∪ cl(T). -/
theorem closure_union_absorbs {σ : Type*} (v : σ → ℕ∞) (S T : Set σ) :
    levelSetClosure v S ∪ levelSetClosure v T ⊆ levelSetClosure v (S ∪ T) := by
  intro x hx
  rcases hx with ⟨s, hs, hv⟩ | ⟨t, ht, hv⟩
  · exact ⟨s, Or.inl hs, hv⟩
  · exact ⟨t, Or.inr ht, hv⟩

/-! ## §13. Threshold Filtration -/

/-- The **threshold closure** at scale n: adds elements of valuation ≤ n. -/
def thresholdClosure {σ : Type*} (v : σ → ℕ∞) (n : ℕ∞) (S : Set σ) : Set σ :=
  {x | v x ≤ n} ∪ S

/-- Threshold closure is extensive. -/
theorem thresholdClosure_extensive {σ : Type*} (v : σ → ℕ∞) (n : ℕ∞) (S : Set σ) :
    S ⊆ thresholdClosure v n S :=
  subset_union_right

/-- Threshold closure is monotone in sets. -/
theorem thresholdClosure_mono_set {σ : Type*} (v : σ → ℕ∞) (n : ℕ∞) :
    Monotone (thresholdClosure v n) :=
  fun _ _ h => union_subset_union_right _ h

/-- Threshold closure is idempotent. -/
theorem thresholdClosure_idem {σ : Type*} (v : σ → ℕ∞) (n : ℕ∞) (S : Set σ) :
    thresholdClosure v n (thresholdClosure v n S) = thresholdClosure v n S := by
  ext x; simp only [thresholdClosure, mem_union, mem_setOf_eq]
  tauto

/-- Threshold closure is monotone in scale. -/
theorem thresholdClosure_mono_scale {σ : Type*} (v : σ → ℕ∞)
    {m n : ℕ∞} (h : m ≤ n) (S : Set σ) :
    thresholdClosure v m S ⊆ thresholdClosure v n S := by
  intro x hx
  simp only [thresholdClosure, mem_union, mem_setOf_eq] at *
  rcases hx with hx | hx
  · exact Or.inl (le_trans hx h)
  · exact Or.inr hx

/-- **Absorption**: cl_n(cl_m(S)) = cl_n(S) for m ≤ n. -/
theorem thresholdClosure_absorption {σ : Type*} (v : σ → ℕ∞)
    {m n : ℕ∞} (h : m ≤ n) (S : Set σ) :
    thresholdClosure v n (thresholdClosure v m S) = thresholdClosure v n S := by
  simp only [thresholdClosure]
  ext x; simp only [mem_union, mem_setOf_eq]
  constructor
  · rintro (hx | hx | hx)
    · exact Or.inl hx
    · exact Or.inl (le_trans hx h)
    · exact Or.inr hx
  · rintro (hx | hx)
    · exact Or.inl hx
    · exact Or.inr (Or.inr hx)

/-! ## §14. Main Bridge Theorem -/

/-- **Main Bridge Theorem**: A tropical valuation on a commutative semiring
canonically induces a closure system whose stable probes are exactly
the v-factoring observables. -/
theorem tropical_valuation_closure_bridge {R : Type*} [CommSemiring R]
    (tv : TropicalValuation R) :
    (∀ S : Set R, S ⊆ levelSetClosure tv.val S) ∧
    (Monotone (levelSetClosure tv.val)) ∧
    (∀ S : Set R, levelSetClosure tv.val (levelSetClosure tv.val S) =
      levelSetClosure tv.val S) ∧
    (∀ n : ℕ∞, IsClosureStable tv.val (thresholdProbe tv.val n)) ∧
    (∀ (K : Type*) (p : R → K),
      IsClosureStable tv.val p ↔ FactorsThroughVal tv.val p) := by
  refine
    ⟨levelSetClosure_extensive tv.val,
     levelSetClosure_mono tv.val,
     levelSetClosure_idem_eq tv.val,
     thresholdProbe_closure_stable tv.val,
     fun _ p => closure_stable_iff_factors tv.val p⟩

/-! ## §15. Threshold Separation -/

/-
**Threshold separation**: threshold probes separate elements with
distinct valuations.
-/
theorem threshold_separates {σ : Type*} (v : σ → ℕ∞) (x y : σ) (h : v x ≠ v y) :
    ∃ n : ℕ∞, thresholdProbe v n x ≠ thresholdProbe v n y := by
  cases' lt_or_gt_of_ne h with h h;
  · use v x; simp [thresholdProbe, h];
  · use v y; simp [thresholdProbe, h]

end TropicalValuationClosureBridge