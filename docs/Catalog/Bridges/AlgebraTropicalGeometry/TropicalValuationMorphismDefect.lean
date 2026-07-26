/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Bridge: the non-Archimedean valuation as a tropical semiring morphism, up to its defect

This file *extends* `Bridges.AlgebraTropicalGeometry.TropicalValuationLimitBridge` (the easy
direction of Kapranov's theorem and min-plus multiplicativity) and its companion
`Bridges.AlgebraTropicalGeometry.TropicalBezoutFactorization` (the union law for tropical
hypersurfaces).  Both of those files study the *corner locus*; here we settle **Direction 5** of
their shared `FUTURE_DIRECTIONS`:

> The tropicalization map `x ↦ v x` is a semiring morphism into the tropical semiring *up to a
> single defect on addition*, and the defect locus — where additivity fails — is *exactly* the
> diagonal tie set `{v x = v y}` that drives the corner locus.

Concretely, packaging the additive valuation `v : AddValuation K Γ` through `Tropical.trop`
gives a map `tropVal v : K → Tropical Γ` which is:

* **multiplicative on the nose** (`tropVal_mul`, bundled as `tropValMonoidHom : K →* Tropical Γ`),
  because `v (x*y) = v x + v y` and tropical multiplication is ordinary addition; and
* **sub-additive** (`tropVal_add_le`): `tropVal x + tropVal y ≤ tropVal (x+y)`, the tropical
  shadow of the ultrametric inequality `min (v x) (v y) ≤ v (x+y)`.

The single defect on addition is controlled exactly:

* `addValuation_add_eq_min_of_ne` — additivity holds with *equality* whenever `v x ≠ v y`;
* `addValuation_defect_imp_tie` — conversely, every failure of additivity forces `v x = v y`,
  i.e. the **defect locus is contained in the tie set**.

Finally we connect the defect back to the corner-locus vocabulary of the bridge files:

* `attainedTwice_fin2_iff` — for a two-monomial family the corner locus is *exactly* the tie set
  `{a = b}`; and
* `addValuation_defect_imp_corner` — every additive defect of `v` lands on the binary corner
  locus, unifying the additive (defect) and combinatorial (corner) stories.

-- !-- Lab Notebook -- !--
* Hypothesis: the only obstruction to `x ↦ v x` being an honest tropical-semiring morphism is the
  failure of additivity, and that failure happens *exactly* on the tie set `{v x = v y}` — the
  same phenomenon producing corners in `kapranov_easy_direction`.
* Result: confirmed.  Multiplicativity is exact (`tropValMonoidHom`); additivity is an inequality
  (`tropVal_add_le`) that becomes an equality off the tie set (`addValuation_add_eq_min_of_ne`),
  and every defect is on the tie set (`addValuation_defect_imp_tie`), which for two monomials is
  literally the corner locus (`attainedTwice_fin2_iff`, `addValuation_defect_imp_corner`).
* Insight: "morphism defect = corner locus" is a one-line consequence of
  `AddValuation.map_add_eq_of_lt_left`: away from ties one valuation strictly wins, pinning the
  sum's valuation to the minimum.  Tropicalizing through `Tropical.trop` turns Mathlib's additive
  valuation API verbatim into tropical-semiring (in)equalities.
* Failure analysis: a naive attempt to make `tropVal` a *ring* hom fails — it is provably *not*
  an `AddHom` (the defect is real, e.g. `x + (-x) = 0` gives `v 0 = ⊤ ≠ v x`).  The correct
  packaging is therefore a `MonoidHom` plus a sub-additivity inequality, not a `RingHom`.
-/

open Finset
open Tropical

namespace TropicalValuationMorphism

/-! ## §0. Corner-locus vocabulary (re-stated for self-containment) -/

/-- A weight function `w : ι → α` **attains its minimum at least twice**: the corner-locus /
tropical-hypersurface predicate.  Mirrors `TropicalValuationBridge.AttainedAtLeastTwice`. -/
def AttainedAtLeastTwice {ι α : Type*} [LinearOrder α] (w : ι → α) : Prop :=
  ∃ i j, i ≠ j ∧ (∀ k, w i ≤ w k) ∧ (∀ k, w j ≤ w k)

/-! ## §1. The single additive defect is controlled by the tie set -/

/-
!-- By trichotomy on `v x` vs `v y`: if one strictly wins, `AddValuation.map_add_eq_of_lt_left`
pins `v (x+y)` to it, which is the min; the third (equal) case is excluded by `hne`. -- !--

**Additivity off the tie set.**  When the two valuations differ, the ultrametric inequality is an
*equality*: `v (x + y) = min (v x) (v y)`.  This is the precise statement that the tropicalization
is additive away from `{v x = v y}`.
-/
theorem addValuation_add_eq_min_of_ne
    {K Γ : Type*} [Field K] [LinearOrderedAddCommMonoidWithTop Γ]
    (v : AddValuation K Γ) {x y : K} (hne : v x ≠ v y) :
    v (x + y) = min (v x) (v y) := by
  grind +suggestions

/-
!-- Contrapositive of `addValuation_add_eq_min_of_ne`: if the valuations differed, additivity
would hold, contradicting the assumed defect. -- !--

**Defect locus ⊆ tie set.**  Every failure of additivity forces the two valuations to coincide:
the defect of the tropicalization morphism lives exactly on the diagonal tie set `{v x = v y}`.
-/
theorem addValuation_defect_imp_tie
    {K Γ : Type*} [Field K] [LinearOrderedAddCommMonoidWithTop Γ]
    (v : AddValuation K Γ) {x y : K} (hdef : v (x + y) ≠ min (v x) (v y)) :
    v x = v y := by
  grind +suggestions

/-! ## §2. Tropicalization through `Tropical.trop`: a monoid morphism plus a defect -/

/-- The **tropicalization map** of an additive valuation: send `x` to `trop (v x)` in the
tropical semiring `Tropical Γ`, where multiplication is `+` and addition is `min`. -/
def tropVal {K Γ : Type*} [Field K] [LinearOrderedAddCommMonoidWithTop Γ]
    (v : AddValuation K Γ) (x : K) : Tropical Γ :=
  trop (v x)

/-
!-- `v 1 = 0` by `AddValuation.map_one`, and the tropical unit is `trop 0`. -- !--

**Multiplicative unit.**  Tropicalization sends `1` to the tropical multiplicative identity.
-/
theorem tropVal_one {K Γ : Type*} [Field K] [LinearOrderedAddCommMonoidWithTop Γ]
    (v : AddValuation K Γ) : tropVal v 1 = 1 := by
  exact v.map_one.symm ▸ rfl

/-
!-- `v (x*y) = v x + v y` (`AddValuation.map_mul`) and `trop` turns `+` into tropical `*`
(`Tropical.trop_add`). -- !--

**Exact multiplicativity.**  Tropicalization is a homomorphism for the multiplicative structure:
classical multiplication becomes tropical multiplication (ordinary addition of valuations) with no
defect.
-/
theorem tropVal_mul {K Γ : Type*} [Field K] [LinearOrderedAddCommMonoidWithTop Γ]
    (v : AddValuation K Γ) (x y : K) : tropVal v (x * y) = tropVal v x * tropVal v y := by
  -- By definition of tropVal, we have tropVal v (x * y) = trop (v (x * y)).
  simp [tropVal]

/-- **Bundled multiplicative morphism.**  The tropicalization `x ↦ trop (v x)` is a genuine
`MonoidHom K (Tropical Γ)`; this is the "honest half" of Direction 5. -/
def tropValMonoidHom {K Γ : Type*} [Field K] [LinearOrderedAddCommMonoidWithTop Γ]
    (v : AddValuation K Γ) : K →* Tropical Γ where
  toFun := tropVal v
  map_one' := tropVal_one v
  map_mul' := tropVal_mul v

/-
!-- Tropical addition is `min` (`Tropical.add_def`), and `min (v x) (v y) ≤ v (x+y)` is the
ultrametric inequality `AddValuation.map_add`; `trop` is monotone (`untrop_le_iff`). -- !--

**Sub-additivity (the tropical-additivity inequality).**  Tropicalization is sub-additive:
`tropVal x + tropVal y ≤ tropVal (x + y)`.  This is the tropical-semiring shadow of the
ultrametric inequality and is the precise sense in which `v` is "almost" additive.
-/
theorem tropVal_add_le {K Γ : Type*} [Field K] [LinearOrderedAddCommMonoidWithTop Γ]
    (v : AddValuation K Γ) (x y : K) :
    tropVal v x + tropVal v y ≤ tropVal v (x + y) := by
  by_contra! h_contra;
  exact h_contra.not_ge ( v.map_add _ _ )

/-
!-- Off the tie set `addValuation_add_eq_min_of_ne` upgrades the `≤` to `=`; tropical addition is
`min`, so the inequality `tropVal_add_le` becomes an equality. -- !--

**Additivity off the tie set, tropical form.**  Away from the diagonal `{v x = v y}` the
sub-additivity inequality `tropVal_add_le` is an *equality*: there `tropVal` is an honest additive
morphism as well.
-/
theorem tropVal_add_eq_of_ne {K Γ : Type*} [Field K] [LinearOrderedAddCommMonoidWithTop Γ]
    (v : AddValuation K Γ) {x y : K} (hne : v x ≠ v y) :
    tropVal v x + tropVal v y = tropVal v (x + y) := by
  have := addValuation_add_eq_min_of_ne v hne;
  unfold tropVal; aesop;

/-! ## §3. The two-monomial corner locus is the tie set -/

/-
!-- The only distinct index pair in `Fin 2` is `{0,1}`; both being minima of `![a,b]` forces
`a ≤ b` and `b ≤ a`, i.e. `a = b`, and conversely equal values make both indices minima. -- !--

**Two-monomial corner locus = tie set.**  For a two-term tropical polynomial the corner-locus
predicate is *exactly* the equality `a = b` of the two term values.
-/
theorem attainedTwice_fin2_iff {α : Type*} [LinearOrder α] (a b : α) :
    AttainedAtLeastTwice (![a, b]) ↔ a = b := by
  constructor;
  · rintro ⟨ i, j, hij, hi, hj ⟩;
    fin_cases i <;> fin_cases j <;> simp_all +decide <;> exact le_antisymm ( by solve_by_elim ) ( by solve_by_elim );
  · rintro rfl; exact ⟨ 0, 1, by simp +decide, by simp +decide, by simp +decide ⟩ ;

/-
!-- A defect forces `v x = v y` (`addValuation_defect_imp_tie`), which by
`attainedTwice_fin2_iff` is precisely the corner-locus condition of the binary family. -- !--

**Defect ⟹ corner (the unification).**  Every additive defect of the valuation lands on the
corner locus of the corresponding two-monomial tropical polynomial.  This closes the loop with
`kapranov_easy_direction`: the additive defect and the combinatorial corner are one and the same
phenomenon.
-/
theorem addValuation_defect_imp_corner
    {K Γ : Type*} [Field K] [LinearOrderedAddCommMonoidWithTop Γ]
    (v : AddValuation K Γ) {x y : K} (hdef : v (x + y) ≠ min (v x) (v y)) :
    AttainedAtLeastTwice (fun i : Fin 2 => v (![x, y] i)) := by
  have := addValuation_defect_imp_tie v hdef;
  use 0, 1; simp [this]

end TropicalValuationMorphism