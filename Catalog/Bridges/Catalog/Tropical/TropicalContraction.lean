/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Tropical Contraction and Support Truncation

This file establishes the formal bridge between **support contraction** of multivariate
polynomials, **tropicalization** of coefficients/exponents, and **truncation of Newton
support/polytopes**. The central result is that contraction — removing one unit of mass
in a chosen coordinate direction — commutes with the passage to tropical (exponent-level)
data, and preserves the M-convex exchange structure.

## Main Definitions

* `TropicalSupport` — A tropical polynomial represented by its finite support and weight
* `exponentContract` — Contract an exponent vector by removing one unit in coordinate `i`
* `supportContract` — Contract a finite set of exponent vectors in direction `i`
* `tropicalTruncate` — Truncate a tropical support in direction `i`
* `MConvexExchangeFinsupp` — M-convex exchange property on `Finset (σ →₀ ℕ)`

## Main Results

1. `supp_tropicalTruncate_eq_contract` — Tropical truncation support equals support contraction
2. `supportContract_mem_iff` — Membership characterization of support contraction
3. `image_supportContract_add_single_eq_filter` — Inverse image characterization
4. `MConvexExchangeFinsupp.supportContract` — Exchange preserved under contraction

## References

* Murota, "Discrete Convex Analysis", SIAM, 2003
* Maclagan–Sturmfels, "Introduction to Tropical Geometry", AMS, 2015
-/

open Finset Finsupp BigOperators

noncomputable section

namespace TropicalContraction

variable {σ : Type*} [DecidableEq σ]

/-! ## Section 1: Core Definitions -/

/-- A tropical support is a finite set of exponent vectors with integer weights.
    This captures the tropical shadow of a multivariate polynomial: we retain
    only the support (which monomials appear) and a weight function (the tropical
    valuation of each coefficient). -/
structure TropicalSupport (σ : Type*) [DecidableEq σ] where
  /-- The finite support: exponent vectors of monomials that appear. -/
  supp : Finset (σ →₀ ℕ)
  /-- Weight function: the tropical valuation of each monomial's coefficient. -/
  weight : (σ →₀ ℕ) → ℤ
  /-- Weights are zero outside the support. -/
  weight_mem : ∀ m, m ∉ supp → weight m = 0

/-- Contract an exponent vector in direction `i`: subtract one from coordinate `i`
    if it is positive, returning `none` if the coordinate is already zero.

    Mathematically: given `m ∈ ℕ^σ` and `i ∈ σ`,
    - if `m(i) > 0`, return `m - e_i`
    - if `m(i) = 0`, return `none` -/
def exponentContract (i : σ) (m : σ →₀ ℕ) : Option (σ →₀ ℕ) :=
  if m i = 0 then none
  else some (m.update i (m i - 1))

/-- Support contraction in direction `i`: filter to exponents with positive `i`-coordinate,
    then subtract `e_i` from each. -/
def supportContract (i : σ) (S : Finset (σ →₀ ℕ)) : Finset (σ →₀ ℕ) :=
  (S.filter (fun m => 0 < m i)).image (fun m => m.update i (m i - 1))

/-- Truncate a tropical support in direction `i`: contract the support and
    propagate weights from the original exponent vectors. -/
def tropicalTruncate (i : σ) (T : TropicalSupport σ) : TropicalSupport σ where
  supp := supportContract i T.supp
  weight := fun m' =>
    if m' ∈ supportContract i T.supp then
      T.weight (m'.update i (m' i + 1))
    else 0
  weight_mem := fun m hm => by simp [hm]

/-! ## Section 2: Characterization Lemmas -/

omit [DecidableEq σ] in
theorem exponentContract_none_iff {i : σ} {m : σ →₀ ℕ} :
    exponentContract i m = none ↔ m i = 0 := by
  unfold exponentContract; split <;> simp_all

omit [DecidableEq σ] in
theorem exponentContract_some_iff {i : σ} {m m' : σ →₀ ℕ} :
    exponentContract i m = some m' ↔ m i ≠ 0 ∧ m' = m.update i (m i - 1) := by
  unfold exponentContract
  split
  · simp_all
  · simp_all; exact Iff.intro Eq.symm Eq.symm

/-- A contracted exponent vector has the correct `i`-coordinate. -/
theorem exponentContract_coord_i {i : σ} {m m' : σ →₀ ℕ}
    (h : exponentContract i m = some m') :
    m' i = m i - 1 := by
  simp [exponentContract] at h
  obtain ⟨_, rfl⟩ := h
  simp

/-- A contracted exponent vector preserves other coordinates. -/
theorem exponentContract_coord_other {i : σ} {m m' : σ →₀ ℕ} {j : σ}
    (h : exponentContract i m = some m') (hij : j ≠ i) :
    m' j = m j := by
  simp [exponentContract] at h
  obtain ⟨_, rfl⟩ := h
  simp [Finsupp.update_apply, hij]

/-- Membership in the contracted support. -/
theorem supportContract_mem_iff {i : σ} {S : Finset (σ →₀ ℕ)} {m' : σ →₀ ℕ} :
    m' ∈ supportContract i S ↔
      ∃ m ∈ S, 0 < m i ∧ m' = m.update i (m i - 1) := by
  simp [supportContract, Finset.mem_image, Finset.mem_filter]
  constructor
  · rintro ⟨m, ⟨hm, hpos⟩, rfl⟩
    exact ⟨m, hm, hpos, rfl⟩
  · rintro ⟨m, hm, hpos, rfl⟩
    exact ⟨m, ⟨hm, hpos⟩, rfl⟩

/-! ## Section 3: Tropical Truncation = Support Contraction -/

/-- **Theorem 1**: The support of a tropical truncation equals the support contraction.
    This is the fundamental compatibility theorem: the algebraic operation (contraction)
    and the tropical operation (truncation) agree at the level of exponent supports. -/
theorem supp_tropicalTruncate_eq_contract
    (i : σ) (T : TropicalSupport σ) :
    (tropicalTruncate i T).supp = supportContract i T.supp := by
  rfl

/-! ## Section 4: Inverse Image Characterization -/

/-
The contraction map `m ↦ m.update i (m i - 1)` is injective on vectors with
    positive `i`-coordinate.
-/
theorem update_sub_one_injOn (i : σ) (S : Finset (σ →₀ ℕ)) :
    Set.InjOn (fun m : σ →₀ ℕ => m.update i (m i - 1))
      (↑(S.filter (fun m => 0 < m i))) := by
  intro m hm m' hm' h; simp_all +decide [ Finsupp.ext_iff ] ; (
  intro a; specialize h a; by_cases ha : a = i <;> simp_all +decide [ Function.update_apply ] ;
  omega)

/-
Adding `e_i` back to a contracted support recovers the filtered original support.
    This is the key invertibility property: contraction is a bijection between
    `{m ∈ S | m(i) > 0}` and `supportContract i S`.
-/
theorem image_supportContract_add_single_eq_filter
    (i : σ) (S : Finset (σ →₀ ℕ)) :
    (supportContract i S).image (fun m => m.update i (m i + 1)) =
      S.filter (fun m => 0 < m i) := by
  ext m;
  simp [supportContract];
  constructor;
  · rintro ⟨ a, ⟨ ha₁, ha₂ ⟩, rfl ⟩;
    simp +decide [ ha₁, ha₂, Nat.sub_add_cancel ha₂ ];
  · exact fun h => ⟨ m, h, by rw [ Nat.sub_add_cancel h.2 ] ; simp +decide ⟩

/-! ## Section 5: M-Convex Exchange Property -/

/-- The M-convex symmetric exchange property for finite support sets in `σ →₀ ℕ`.
    For any `α, β ∈ S` with `α(i) > β(i)`, there exists `j` with `α(j) < β(j)`
    such that `α - e_i + e_j ∈ S`.

    This is the foundational axiom of discrete convex analysis (Murota 2003). -/
def MConvexExchangeFinsupp [Fintype σ] (S : Finset (σ →₀ ℕ)) : Prop :=
  ∀ α ∈ S, ∀ β ∈ S, ∀ k : σ,
    β k < α k →
    ∃ j : σ, α j < β j ∧
      (α.update k (α k - 1)).update j (α j + 1) ∈ S

/-- Alias: tropical exchange is defined as the same exchange property on supports. -/
def TropicalExchange [Fintype σ] (S : Finset (σ →₀ ℕ)) : Prop :=
  MConvexExchangeFinsupp S

omit [DecidableEq σ] in
/-- Tropical exchange and M-convex exchange are definitionally equal. -/
theorem tropicalExchange_iff_mconvexExchange [Fintype σ]
    (S : Finset (σ →₀ ℕ)) :
    TropicalExchange S ↔ MConvexExchangeFinsupp S := by
  rfl

/-! ## Section 6: Contraction Preserves Exchange -/

/-
**Theorem 2**: The M-convex exchange property is preserved under support contraction.

    If `S` satisfies the symmetric exchange axiom, then `supportContract i S` also satisfies
    the symmetric exchange axiom. This is the tropical stability theorem: the discrete convex
    structure is invariant under coordinate contraction/truncation.

    **Proof strategy**: Given `α', β' ∈ supportContract i S` with `α'(k) > β'(k)`,
    lift to `α, β ∈ S` with `α(i) > 0, β(i) > 0`, apply exchange in `S`,
    and project the witness back down through contraction.
-/
theorem MConvexExchangeFinsupp.supportContract [Fintype σ]
    {S : Finset (σ →₀ ℕ)} {i : σ}
    (hS : MConvexExchangeFinsupp S) :
    MConvexExchangeFinsupp (supportContract i S) := by
  intro α' hα' β' hβ' k hk;
  -- Unpack α' and β'. By supportContract_mem_iff, there exist α, β ∈ S with 0 < α i, 0 < β i, α' = α.update i (α i - 1), β' = β.update i (β i - 1).
  obtain ⟨α, hαS, hαi, rfl⟩ := supportContract_mem_iff.mp hα'
  obtain ⟨β, hβS, hβi, rfl⟩ := supportContract_mem_iff.mp hβ';
  -- By hS, there exists j with α j < β j and e := (α.update k (α k - 1)).update j (α j + 1) ∈ S.
  obtain ⟨j, hj₁, hj₂⟩ : ∃ j, α j < β j ∧ (α.update k (α k - 1)).update j (α j + 1) ∈ S := by
    apply hS α hαS β hβS k;
    grind;
  refine' ⟨ j, _, _ ⟩;
  · grind;
  · refine' Finset.mem_image.mpr ⟨ _, Finset.mem_filter.mpr ⟨ hj₂, _ ⟩, _ ⟩;
    · grind;
    · grind

/-- Corollary: Tropical exchange is preserved under support contraction. -/
theorem TropicalExchange.supportContract [Fintype σ]
    {S : Finset (σ →₀ ℕ)} {i : σ}
    (hS : TropicalExchange S) :
    TropicalExchange (supportContract i S) :=
  MConvexExchangeFinsupp.supportContract hS

/-! ## Section 7: Weighted Tropical M-Convexity -/

/-- Weighted tropical M-convexity: an exchange inequality on weights.
    For any `α, β` in support with `α(k) > β(k)`, there exists `j` with `α(j) < β(j)`
    such that `w(α - e_k + e_j) + w(β + e_k - e_j) ≥ w(α) + w(β)`.

    This is the valuated matroid exchange axiom. -/
def TropicalMConvex [Fintype σ] (T : TropicalSupport σ) : Prop :=
  ∀ α ∈ T.supp, ∀ β ∈ T.supp, ∀ k : σ,
    β k < α k →
    ∃ j : σ, α j < β j ∧
      (α.update k (α k - 1)).update j (α j + 1) ∈ T.supp ∧
      T.weight ((α.update k (α k - 1)).update j (α j + 1)) +
        T.weight ((β.update j (β j - 1)).update k (β k + 1)) ≥
        T.weight α + T.weight β

/-! ## Section 8: Support Contraction Properties -/

/-
Support contraction preserves cardinality of the positive-coordinate subset.
-/
theorem supportContract_card (i : σ) (S : Finset (σ →₀ ℕ)) :
    (supportContract i S).card = (S.filter (fun m => 0 < m i)).card := by
  exact Finset.card_image_of_injOn (update_sub_one_injOn i S)

/-
Support contraction is monotone: if `S ⊆ T` then
    `supportContract i S ⊆ supportContract i T`.
-/
theorem supportContract_mono {i : σ} {S T : Finset (σ →₀ ℕ)} (h : S ⊆ T) :
    supportContract i S ⊆ supportContract i T := by
  grind +locals

/-- The empty set contracts to the empty set. -/
@[simp]
theorem supportContract_empty (i : σ) :
    supportContract i (∅ : Finset (σ →₀ ℕ)) = ∅ := by
  simp [supportContract]

/-
A singleton contracts to a singleton or empty set.
-/
theorem supportContract_singleton (i : σ) (m : σ →₀ ℕ) :
    supportContract i {m} = if 0 < m i then {m.update i (m i - 1)} else ∅ := by
  unfold supportContract;
  grind

end TropicalContraction