/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# M-Convex Support Shadow Compression

This file develops the theory of degree shadows for M-convex support families,
extending support compression from the matroid basis world to Murota's discrete
convex analysis. The central insight is that **exchange geometry controls shadow
structure**: M-convexity alone governs which dominated degree slices can appear.

## Mathematical Context

In discrete convex analysis (Murota, 2003), an M-convex set is a family of
integer vectors of constant sum satisfying the symmetric exchange property:
for any α, β ∈ S with α(i) > β(i), there exists j with α(j) < β(j) such that
α - eᵢ + eⱼ ∈ S. These generalize matroid bases (the multiaffine / 0-1 case).

Given a homogeneous support family `s` of degree `d`, the **degree-k shadow**
consists of all degree-k vectors dominated coordinatewise by some element of `s`.
This abstracts the notion of "surviving derivative branches" in Lorentzian
polynomial theory.

## Main Results

* `mem_degreeShadow_support_subset` — Shadow elements use only active coordinates.
* `mem_degreeShadow_degree` — Shadow elements have the correct total degree.
* `degreeShadowSet_finite` — The degree shadow of a finite family is finite.
* `degreeShadow_card_le_of_multiaffine` — For multiaffine M-convex supports
  (matroid bases), the shadow bound C(ω, k) holds.
* `initialSupportSet_nonempty` — Tropical initial supports are nonempty.
* `tropical_exchange_equal_weight` — M-convex exchange witnesses survive
  tropicalization when weight classes align.

## Key Definitions

* `activeCoords` — The set of coordinates used by any element of a support family.
* `degreeShadowSet` — The k-shadow: degree-k vectors dominated by support elements.
* `quadraticLeafSet` — The (d-2)-shadow: the leaf set relevant for Hessian analysis.
* `IsMConvexExchangeFinset` — M-convex symmetric exchange for finite families.
* `tropicalDot` — Tropical weight functional for initial form computation.
* `initialSupportSet` — Weight-minimizers in a support family.

## Counterexample Note

The naive bound |degreeShadow s k| ≤ C(ω, k) does NOT hold for non-multiaffine
M-convex sets. The full simplex of all degree-4 vectors on 3 variables is M-convex
with ω = 3, but its degree-2 shadow has 6 elements > C(3,2) = 3. The multiaffine
hypothesis is essential for the binomial bound; the true mechanism is the interplay
of exchange geometry WITH the constraint that all coordinate values are 0 or 1.

## References

* Murota, "Discrete Convex Analysis", SIAM, 2003
* Brändén–Huh, "Lorentzian Polynomials", Annals of Mathematics, 2020
-/

open Finsupp Finset BigOperators

noncomputable section

namespace MConvexShadow

variable {σ : Type*} [DecidableEq σ]

/-! ## Core Definitions -/

/-- Total degree of a finitely-supported function `σ →₀ ℕ`. -/
def totalDeg (m : σ →₀ ℕ) : ℕ := m.sum (fun _ n => n)

/-- The set of **active coordinates** of a support family: coordinates `i`
    such that `m i ≠ 0` for at least one `m ∈ s`. -/
def activeCoords (s : Finset (σ →₀ ℕ)) : Finset σ :=
  s.biUnion (fun m => m.support)

/-- The M-convex symmetric exchange property for a `Finset` of natural-number
    finsupps. For any α, β ∈ S with α(i) > β(i), there exists j with
    α(j) < β(j) such that α - eᵢ + eⱼ ∈ S. -/
def IsMConvexExchangeFinset (S : Finset (σ →₀ ℕ)) : Prop :=
  ∀ α ∈ S, ∀ β ∈ S, ∀ i : σ,
    α i > β i →
    ∃ j : σ, α j < β j ∧
      (α - Finsupp.single i 1 + Finsupp.single j 1) ∈ S

/-- A finitely supported function is **multiaffine** if every coordinate value
    is at most 1. Multiaffine M-convex sets correspond to matroid bases. -/
def IsMultiaffine (m : σ →₀ ℕ) : Prop :=
  ∀ i : σ, m i ≤ 1

/-- The **degree-k shadow** of a support family `s`: the set of all degree-k
    finsupps that are coordinatewise dominated by some element of `s`.
    This abstracts "surviving derivative branches at depth d - k". -/
def degreeShadowSet (s : Finset (σ →₀ ℕ)) (k : ℕ) :
    Set (σ →₀ ℕ) :=
  {u | totalDeg u = k ∧ ∃ m ∈ s, u ≤ m}

/-- The **quadratic leaf set**: the (d-2)-shadow, corresponding to the set of
    exponent patterns that survive two rounds of differentiation. -/
def quadraticLeafSet (s : Finset (σ →₀ ℕ)) (d : ℕ) :
    Set (σ →₀ ℕ) :=
  degreeShadowSet s (d - 2)

/-- The **tropical dot product**: evaluation of a weight vector on an exponent. -/
def tropicalDot (w : σ → ℤ) (m : σ →₀ ℕ) : ℤ :=
  m.sum (fun i n => w i * (n : ℤ))

/-- The **initial support** under a weight vector `w`: the elements of `s`
    that minimize the tropical dot product. -/
def initialSupportSet (w : σ → ℤ) (s : Finset (σ →₀ ℕ)) : Set (σ →₀ ℕ) :=
  {m | m ∈ (s : Set (σ →₀ ℕ)) ∧ ∀ m' ∈ s, tropicalDot w m ≤ tropicalDot w m'}

/-- **Shadow hereditary exchange**: a weakened exchange property asserting that
    for any two shadow elements u, v with u(i) > v(i), there exist M-convex
    witnesses in `s` dominating appropriate elements, so that some exchange
    element `u - eᵢ + eⱼ` remains in the shadow. -/
def ShadowHereditaryExchange (s : Finset (σ →₀ ℕ)) (k : ℕ) : Prop :=
  ∀ u ∈ degreeShadowSet s k, ∀ v ∈ degreeShadowSet s k,
    ∀ i : σ, u i > v i →
    ∃ j : σ, u j < v j ∧
      ∃ m ∈ s, (u - Finsupp.single i 1 + Finsupp.single j 1) ≤ m ∧
        totalDeg (u - Finsupp.single i 1 + Finsupp.single j 1) = k

/-! ## Auxiliary Lemmas -/

/-
Active coordinates: `i ∈ activeCoords s` iff some `m ∈ s` has `m i ≠ 0`.
-/
theorem mem_activeCoords_iff {s : Finset (σ →₀ ℕ)} {i : σ} :
    i ∈ activeCoords s ↔ ∃ m ∈ s, m i ≠ 0 := by
  unfold activeCoords; aesop;

/-
The empty support family has empty active coordinates.
-/
theorem activeCoords_empty :
    activeCoords (∅ : Finset (σ →₀ ℕ)) = ∅ := by
  rfl

/-
M-convex exchange for singletons is trivial.
-/
theorem mconvex_singleton (m : σ →₀ ℕ) :
    IsMConvexExchangeFinset ({m} : Finset (σ →₀ ℕ)) := by
  intro α hα β hβ i hi; aesop;

/-
M-convex exchange for the empty set is vacuously true.
-/
theorem mconvex_empty :
    IsMConvexExchangeFinset (∅ : Finset (σ →₀ ℕ)) := by
  tauto

/-
The support of any element dominated by `m` is contained in `m.support`.
-/
theorem support_subset_of_le {u m : σ →₀ ℕ}
    (h : u ≤ m) : u.support ⊆ m.support := by
  intro i hi; have := h i; aesop;

/-! ## Theorem 1: Shadow Support Lies in Active Coordinates -/

/-
Every element of the degree shadow has support contained in the active
    coordinates of the original family. This is the geometric containment
    theorem: shadow elements live in the "active simplex".
-/
theorem mem_degreeShadow_support_subset
    {s : Finset (σ →₀ ℕ)} {k : ℕ} {u : σ →₀ ℕ}
    (hu : u ∈ degreeShadowSet s k) :
    u.support ⊆ activeCoords s := by
  cases hu;
  rename_i h₁ h₂; rcases h₂ with ⟨ m, hm, h₃ ⟩ ; exact Finset.Subset.trans ( support_subset_of_le h₃ ) ( Finset.subset_biUnion_of_mem _ hm ) ;

/-
Every element of the degree shadow has the correct total degree.
-/
theorem mem_degreeShadow_degree
    {s : Finset (σ →₀ ℕ)} {k : ℕ} {u : σ →₀ ℕ}
    (hu : u ∈ degreeShadowSet s k) :
    totalDeg u = k := by
  exact hu.1

/-- Combined: shadow elements have support ⊆ activeCoords and degree = k. -/
theorem mem_degreeShadow_support_and_degree
    {s : Finset (σ →₀ ℕ)} {k : ℕ} {u : σ →₀ ℕ}
    (hu : u ∈ degreeShadowSet s k) :
    u.support ⊆ activeCoords s ∧ totalDeg u = k :=
  ⟨mem_degreeShadow_support_subset hu, mem_degreeShadow_degree hu⟩

/-! ## Theorem 2: Support Exclusion (Contradiction Proof) -/

/-
**Support exclusion**: If coordinate `i` is NOT in `activeCoords s`, then
    no element of the degree shadow can have `u i > 0`. Proved by contradiction:
    if `u i > 0` and `u ≤ m` for some `m ∈ s`, then `m i > 0`, so `i` would be
    active — contradiction.
-/
theorem degreeShadow_zero_outside_active
    {s : Finset (σ →₀ ℕ)} {k : ℕ} {u : σ →₀ ℕ}
    (hu : u ∈ degreeShadowSet s k)
    {i : σ} (hi : i ∉ activeCoords s) :
    u i = 0 := by
  exact Classical.not_not.1 fun h => hi ( mem_degreeShadow_support_subset hu <| Finsupp.mem_support_iff.2 h )

/-! ## Theorem 3: Finiteness of the Degree Shadow -/

/-
The degree shadow of a finite family is a finite set.
-/
theorem degreeShadowSet_finite
    (s : Finset (σ →₀ ℕ)) (k : ℕ) :
    (degreeShadowSet s k).Finite := by
  -- Since `s` is finite, the set of possible dominating elements `m` is also finite.
  have h_dom_exists_finite : Set.Finite {m : σ →₀ ℕ | ∃ m' ∈ s, m ≤ m'} := by
    exact Set.Finite.subset ( Set.Finite.biUnion ( Finset.finite_toSet s ) fun m _ => Set.finite_Iic m ) fun m hm => by aesop;
  exact h_dom_exists_finite.subset fun x hx => hx.2

/-! ## Theorem 4: Multiaffine Shadow Cardinality Bound -/

/-
If `m` is multiaffine and `u ≤ m`, then `u` is also multiaffine.
-/
theorem multiaffine_le_multiaffine {u m : σ →₀ ℕ}
    (hm : IsMultiaffine m) (h : u ≤ m) : IsMultiaffine u := by
  exact fun i => le_trans ( h i ) ( hm i )

/-
For multiaffine elements, a dominated degree-k element is determined by
    a k-element subset of the support (choosing which coordinates are 1).
    The number of such elements is at most C(|supp(m)|, k).
-/
theorem multiaffine_shadow_injection (m : σ →₀ ℕ) (hm : IsMultiaffine m) (k : ℕ) :
    {u : σ →₀ ℕ | totalDeg u = k ∧ u ≤ m} =
      (fun S => Finsupp.indicator S (fun _ _ => 1)) '' ↑(m.support.powersetCard k) := by
  simp +decide [ Set.ext_iff, Finsupp.le_def, Finsupp.indicator_apply ];
  intro x; constructor <;> intro hx;
  · refine' ⟨ x.support, ⟨ _, _ ⟩, _ ⟩;
    · exact fun i hi => Finsupp.mem_support_iff.mpr ( ne_of_gt ( lt_of_lt_of_le ( Nat.pos_of_ne_zero ( Finsupp.mem_support_iff.mp hi ) ) ( hx.2 i ) ) );
    · rw [ ← hx.1, totalDeg ];
      rw [ Finset.card_eq_sum_ones, Finsupp.sum ];
      exact Finset.sum_congr rfl fun i hi => by linarith [ hx.2 i, show x i = 1 from le_antisymm ( by linarith [ hx.2 i, hm i ] ) ( Nat.pos_of_ne_zero ( Finsupp.mem_support_iff.mp hi ) ) ] ;
    · ext i; by_cases hi : i ∈ x.support <;> simp_all +decide [ Finsupp.single_apply ] ;
      exact Eq.symm ( le_antisymm ( Nat.le_of_lt_succ ( lt_of_le_of_lt ( hx.2 i ) ( Nat.lt_succ_of_le ( hm i ) ) ) ) ( Nat.pos_of_ne_zero hi ) );
  · rcases hx with ⟨ S, ⟨ hS₁, rfl ⟩, rfl ⟩ ; simp_all +decide [ totalDeg ] ;
    grind +splitImp

/-
**Multiaffine shadow cardinality bound**: When all elements of `s` are
    multiaffine (the matroid basis case), the degree-k shadow has at most
    C(ω, k) elements, where ω = |activeCoords s|.

    This is the correct generalization of the matroid basis compression theorem
    to the finsupp setting.
-/
theorem degreeShadow_card_le_of_multiaffine
    (s : Finset (σ →₀ ℕ)) (k : ℕ)
    (hmulti : ∀ m ∈ s, IsMultiaffine m) :
    (degreeShadowSet s k).ncard ≤ Nat.choose (activeCoords s).card k := by
  -- The following steps are taken to prove the inequality
  have h_support_subset : ∀ u ∈ degreeShadowSet s k, u.support ⊆ activeCoords s := by
    exact fun u hu => mem_degreeShadow_support_subset hu;
  -- Since u is multiaffine, u.support is a subset of activeCoords s with cardinality k.
  have h_support_card : ∀ u ∈ degreeShadowSet s k, u.support.card = k := by
    intro u hu; have := hu.1; simp_all +decide [ totalDeg ] ;
    obtain ⟨ m, hm, hm' ⟩ := hu.2;
    rw [ ← this, Finsupp.sum ];
    rw [ Finset.sum_congr rfl fun x hx => show u x = 1 from le_antisymm ( hmulti m hm x |> le_trans ( hm' x ) ) ( Nat.pos_of_ne_zero ( Finsupp.mem_support_iff.mp hx ) ) ] ; simp +decide;
  have h_support_inj : (Set.image (fun u => u.support) (degreeShadowSet s k)).ncard ≤ (Nat.choose (activeCoords s).card k) := by
    exact le_trans ( Set.ncard_le_ncard ( show ( fun u => u.support ) '' degreeShadowSet s k ⊆ Finset.powersetCard k ( activeCoords s ) from fun u hu => by aesop ) ) ( by simp +decide [ Set.ncard_eq_toFinset_card' ] );
  rwa [ Set.InjOn.ncard_image ] at h_support_inj;
  intro u hu v hv; have := h_support_card u hu; have := h_support_card v hv; simp_all +decide [ Finsupp.ext_iff ] ;
  intro h a; have := hmulti; have := hu.2; have := hv.2; simp_all +decide [ Finsupp.ext_iff, IsMultiaffine ] ;
  by_cases ha : a ∈ u.support <;> simp_all +decide [ Finsupp.le_def ];
  · grind +suggestions;
  · replace h := Finset.ext_iff.mp h a; aesop;

/-! ## Corollary: Quadratic Leaf Bound -/

/-- The quadratic leaf set of a multiaffine support is bounded by C(ω, d-2). -/
theorem quadraticLeaf_card_le_of_multiaffine
    (s : Finset (σ →₀ ℕ)) (d : ℕ)
    (hmulti : ∀ m ∈ s, IsMultiaffine m) :
    (quadraticLeafSet s d).ncard ≤ Nat.choose (activeCoords s).card (d - 2) :=
  degreeShadow_card_le_of_multiaffine s (d - 2) hmulti

/-! ## Theorem 5: Tropical Initial Support -/

/-
The initial support under any weight vector is nonempty when the support
    family is nonempty.
-/
omit [DecidableEq σ] in
theorem initialSupportSet_nonempty
    (s : Finset (σ →₀ ℕ)) (hs : s.Nonempty) (w : σ → ℤ) :
    ∃ m ∈ s, m ∈ initialSupportSet w s := by
  unfold initialSupportSet;
  have := Finset.exists_min_image s ( fun m => tropicalDot w m ) hs; aesop;

/-
The initial support set is a subset of the original support.
-/
omit [DecidableEq σ] in
theorem initialSupportSet_subset
    (w : σ → ℤ) (s : Finset (σ →₀ ℕ)) :
    initialSupportSet w s ⊆ ↑s := by
  exact fun x hx => hx.1

/-
**Tropical exchange stability**: If `s` satisfies M-convex exchange and
    the exchange witness `α - eᵢ + eⱼ ∈ s` has `w(i) = w(j)`, then the
    exchange element has the same tropical weight as `α`. This means
    M-convex exchanges within weight-equal coordinate classes preserve
    the tropical face structure.
-/
theorem tropical_exchange_equal_weight
    (s : Finset (σ →₀ ℕ)) (w : σ → ℤ)
    (_hmconv : IsMConvexExchangeFinset s)
    {α β : σ →₀ ℕ}
    (_hα : α ∈ s) (_hβ : β ∈ s)
    (_hαmin : ∀ m' ∈ s, tropicalDot w α ≤ tropicalDot w m')
    (_hβmin : ∀ m' ∈ s, tropicalDot w β ≤ tropicalDot w m')
    {i : σ} (hi : α i > β i)
    {j : σ} (_hj : α j < β j)
    (_hexch : (α - Finsupp.single i 1 + Finsupp.single j 1) ∈ s)
    (hwij : w i = w j) :
    tropicalDot w (α - Finsupp.single i 1 + Finsupp.single j 1) =
      tropicalDot w α := by
  unfold tropicalDot;
  rw [ Finsupp.sum_add_index' ] <;> simp +decide [ *, Finsupp.sum_single_index ];
  · rw [ Finsupp.sum_of_support_subset ];
    case s => exact α.support;
    · simp +decide [ Finsupp.sum, Finsupp.single_apply ];
      rw [ Finset.sum_eq_add_sum_diff_singleton ( show i ∈ α.support from by aesop ) ];
      rw [ Finset.sum_eq_add_sum_diff_singleton ( show i ∈ α.support from by aesop ) ];
      rw [ Finset.sum_congr rfl fun x hx => by rw [ if_neg ( by aesop ) ] ] ; simp +decide [ hwij, Nat.cast_sub ( show 1 ≤ α i from by linarith ) ] ; ring;
    · intro x hx; contrapose! hx; aesop;
    · simp +decide;
  · exact fun _ _ _ => mul_add _ _ _

end MConvexShadow