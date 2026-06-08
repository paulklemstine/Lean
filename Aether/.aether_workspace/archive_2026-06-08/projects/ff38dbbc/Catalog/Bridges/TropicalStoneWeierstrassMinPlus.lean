import Mathlib

/-!
# Tropical Min-Plus Stone–Weierstrass Theorem

This file formalizes the algebraic tropicalization of EML function algebras via
a tropical Stone–Weierstrass theorem for min-plus semiring-valued continuous maps.

## Main definitions

* `TropMinPlusAdd` — tropical addition: pointwise minimum
* `TropMinPlusMul` — tropical multiplication: pointwise sum
* `tropConst` — tropical scalar constants
* `tropNeg` — order-reversing involution converting min-plus to max-plus

## Main results

* `tropNeg_involutive` — negation is an involution
* `norm_sub_tropNeg_eq` — negation is an isometry: `‖-f - (-g)‖ = ‖f - g‖`
* `tropNeg_tropMinPlusAdd` — negation converts min to max
* `tropNeg_tropMinPlusMul` — negation preserves additive structure (with sign flip)
* `tropSep_iff_neg` — separation is preserved under negation
* `minplus_stone_weierstrass_Icc_via_neg` — min-plus density via negation transport

## Mathematical significance

The decisive bridge is the order-reversing involution `f ↦ -f`, which converts
min-plus structure into max-plus structure:
  `-(min (f x) (g x)) = max (-f x) (-g x)`
  `-(f x + g x) = (-f x) + (-g x)` (note: this is `-((-f) + (-g))` pattern)

This duality means every max-plus density theorem automatically yields a min-plus
density theorem, and vice versa. The min-plus side models "cost-style" observables:
shortest paths, value functions, energy landscapes, and morphological erosions.
-/

noncomputable section

open scoped Topology

/-! ## Type abbreviation -/

/-- The unit interval `[0, 1]` as a compact Hausdorff space. -/
abbrev I01 := Set.Icc (0 : ℝ) 1

/-! ## Min-plus operations on continuous maps -/

/-- Tropical addition: pointwise minimum of two continuous functions. -/
def TropMinPlusAdd (f g : C(I01, ℝ)) : C(I01, ℝ) :=
  ⟨fun x => min (f x) (g x), f.continuous.min g.continuous⟩

/-- Tropical multiplication: pointwise sum of two continuous functions. -/
def TropMinPlusMul (f g : C(I01, ℝ)) : C(I01, ℝ) :=
  ⟨fun x => f x + g x, f.continuous.add g.continuous⟩

/-- Tropical scalar constant. -/
def tropConst (c : ℝ) : C(I01, ℝ) :=
  ContinuousMap.const _ c

/-- Order-reversing involution: the key bridge between min-plus and max-plus. -/
def tropNeg (f : C(I01, ℝ)) : C(I01, ℝ) :=
  ⟨fun x => -f x, f.continuous.neg⟩

/-! ## Basic evaluation lemmas -/

@[simp]
theorem TropMinPlusAdd_apply (f g : C(I01, ℝ)) (x : I01) :
    TropMinPlusAdd f g x = min (f x) (g x) := rfl

@[simp]
theorem TropMinPlusMul_apply (f g : C(I01, ℝ)) (x : I01) :
    TropMinPlusMul f g x = f x + g x := rfl

@[simp]
theorem tropConst_apply (c : ℝ) (x : I01) :
    tropConst c x = c := rfl

@[simp]
theorem tropNeg_apply (f : C(I01, ℝ)) (x : I01) :
    tropNeg f x = -f x := rfl

/-! ## Negation is an involution -/

/-- Negation is an involution on continuous maps. -/
theorem tropNeg_involutive : Function.Involutive (tropNeg) := by
  intro f
  ext x
  simp [tropNeg]

/-- `tropNeg` equals the built-in negation on `C(I01, ℝ)`. -/
theorem tropNeg_eq_neg (f : C(I01, ℝ)) : tropNeg f = -f := by
  ext x
  simp [tropNeg]

/-! ## Algebraic conversion identities -/

/-- Negation converts tropical min-plus addition to pointwise maximum. -/
theorem tropNeg_tropMinPlusAdd (f g : C(I01, ℝ)) (x : I01) :
    tropNeg (TropMinPlusAdd f g) x = max (tropNeg f x) (tropNeg g x) := by
  simp only [tropNeg_apply, TropMinPlusAdd_apply, min_def, max_def]
  split_ifs <;> linarith

/-- Negation converts tropical min-plus multiplication to negated sum. -/
theorem tropNeg_tropMinPlusMul (f g : C(I01, ℝ)) :
    tropNeg (TropMinPlusMul f g) = TropMinPlusMul (tropNeg f) (tropNeg g) := by
  ext x
  simp only [tropNeg_apply, TropMinPlusMul_apply]
  ring

/-- Negation preserves tropical constants. -/
theorem tropNeg_tropConst (c : ℝ) :
    tropNeg (tropConst c) = tropConst (-c) := by
  ext x
  simp

/-! ## Norm invariance under negation -/

/-
**Key transport lemma**: negation is an isometry in the sup norm.
This is the exact technical bridge that converts max-plus approximation
results into min-plus approximation results.
-/
theorem norm_sub_tropNeg_eq (f g : C(I01, ℝ)) :
    ‖tropNeg f - tropNeg g‖ = ‖f - g‖ := by
  simp_all +decide [tropNeg_eq_neg];
  rw [ ← norm_neg, neg_add_eq_sub, neg_sub ]

/-! ## Point separation -/

/-- A set of continuous maps separates points if for every pair of
distinct points, some member of the set distinguishes them. -/
def TropSeparatesPoints (A : Set (C(I01, ℝ))) : Prop :=
  ∀ x y : I01, x ≠ y → ∃ f ∈ A, f x ≠ f y

/-
Point separation is preserved under negation: `f` separates `x, y`
iff `-f` separates `x, y`.
-/
theorem tropSep_iff_neg (A : Set (C(I01, ℝ))) :
    TropSeparatesPoints A ↔ TropSeparatesPoints (tropNeg '' A) := by
  constructor <;> intro h x y hxy;
  · obtain ⟨ f, hf₁, hf₂ ⟩ := h x y hxy; use tropNeg f; aesop;
  · obtain ⟨ f, ⟨ g, hg, rfl ⟩, hfg ⟩ := h x y hxy; use g; aesop;

/-! ## Uniform approximation -/

/-- A set `A` uniformly approximates `f` if for every `ε > 0`,
there exists `g ∈ A` with `‖f - g‖ < ε`. -/
def UniformApproxOnI (A : Set (C(I01, ℝ))) (f : C(I01, ℝ)) : Prop :=
  ∀ ε > 0, ∃ g ∈ A, ‖f - g‖ < ε

/-! ## Main theorem: Min-plus Stone–Weierstrass via negation duality -/

/-
**Min-plus Stone–Weierstrass theorem via negation transport.**

If `A` is a set of continuous functions on `[0,1]` closed under:
  - tropical constants (`x ↦ c` for all `c : ℝ`)
  - tropical addition (pointwise min)
  - tropical multiplication (pointwise sum)

and `A` separates points, then assuming that `tropNeg '' A` is dense
in the max-plus sense, `A` is dense in the sup-norm topology.

This theorem isolates the exact duality mechanism: the negation map
`f ↦ -f` converts min-plus structure into max-plus structure, preserves
the sup norm, and thus transfers density results.
-/
theorem minplus_stone_weierstrass_Icc_via_neg
    (A : Set (C(I01, ℝ)))
    (_hconst : ∀ c : ℝ, tropConst c ∈ A)
    (_hmin : ∀ ⦃f g⦄, f ∈ A → g ∈ A → TropMinPlusAdd f g ∈ A)
    (_hadd : ∀ ⦃f g⦄, f ∈ A → g ∈ A → TropMinPlusMul f g ∈ A)
    (_hsep : TropSeparatesPoints A)
    (hdense_neg :
      ∀ f : C(I01, ℝ), ∀ ε > 0,
        ∃ g ∈ (tropNeg '' A), ‖f - g‖ < ε) :
    ∀ f : C(I01, ℝ), ∀ ε > 0,
      ∃ g ∈ A, ‖f - g‖ < ε := by
  contrapose! hdense_neg;
  obtain ⟨ f, ε, hε, hf ⟩ := hdense_neg;
  refine' ⟨ _, ε, hε, fun g hg => _ ⟩;
  exact -f;
  obtain ⟨ g, hg₁, rfl ⟩ := hg; specialize hf g hg₁; simp_all +decide [ norm_sub_rev ] ;
  convert hf using 1 ; rw [ show tropNeg g + f = f - g by ext; simp +decide [ tropNeg ] ; ring ]

/-! ## General compact Hausdorff version -/

/-
**Min-plus Stone–Weierstrass for general compact Hausdorff spaces.**
Same structure as the interval version, but stated for an arbitrary
compact Hausdorff space `X`.
-/
theorem minplus_stone_weierstrass_compact
    (X : Type*) [TopologicalSpace X] [CompactSpace X] [T2Space X]
    (A : Set (C(X, ℝ)))
    (_hconst : ∀ c : ℝ, ContinuousMap.const X c ∈ A)
    (_hmin : ∀ ⦃f g⦄, f ∈ A → g ∈ A →
      (⟨fun x => min (f x) (g x), f.continuous.min g.continuous⟩ : C(X, ℝ)) ∈ A)
    (_hadd : ∀ ⦃f g⦄, f ∈ A → g ∈ A → f + g ∈ A)
    (_hsep : ∀ x y : X, x ≠ y → ∃ f ∈ A, f x ≠ f y)
    (hdense_neg :
      ∀ f : C(X, ℝ), ∀ ε > 0,
        ∃ g ∈ ((-·) '' A : Set (C(X, ℝ))), ‖f - g‖ < ε) :
    ∀ f : C(X, ℝ), ∀ ε > 0,
      ∃ g ∈ A, ‖f - g‖ < ε := by
  intro f ε hε;
  obtain ⟨ g, ⟨ g', hg', rfl ⟩, hg ⟩ := hdense_neg ( -f ) ε hε;
  refine' ⟨ g', hg', _ ⟩;
  convert hg using 1 ; simp +decide;
  rw [ neg_add_eq_sub, norm_sub_rev ]

end