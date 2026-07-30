import Mathlib

/-!
# Hahn-series foundations for exponential–logarithmic transseries

A transseries is represented here by a Hahn series.  Its ordered exponent records
three successive growth levels (exponential, polynomial, and logarithmic).  The
central result is the asymptotic comparison principle: equality of every formal
order is equivalent to equality of transseries.  For unequal series, the order of
their difference is proved to be the first order at which their coefficients can
differ.
-/

noncomputable section

open HahnSeries

namespace EMLTransseries

/-- Three lexicographically ordered growth levels.  The coordinates can encode,
respectively, exponential, polynomial, and logarithmic scales. -/
abbrev GrowthRank := ℤ ×ₗ (ℤ ×ₗ ℤ)

/-- Formal EML transseries with real coefficients and three growth levels. -/
abbrev Transseries := HahnSeries GrowthRank ℝ

/-- Two transseries agree strictly below `cut` when all coefficients at smaller
orders coincide. -/
def AgreeBelow (f g : Transseries) (cut : GrowthRank) : Prop :=
  ∀ rank, rank < cut → f.coeff rank = g.coeff rank

/-- Two transseries agree to all orders when every coefficient agrees. -/
def AgreeToAllOrders (f g : Transseries) : Prop :=
  ∀ rank, f.coeff rank = g.coeff rank

/-- A single transmonomial at a specified growth rank. -/
def monomial (rank : GrowthRank) (c : ℝ) : Transseries :=
  HahnSeries.single rank c

/-- Agreement to all orders uniquely determines a transseries. -/
theorem asymptotic_comparison {f g : Transseries} :
    AgreeToAllOrders f g ↔ f = g := by
  constructor
  · intro h
    apply HahnSeries.ext
    funext rank
    exact h rank
  · rintro rfl rank
    rfl

/-- The coefficient of a transmonomial at its own growth rank is its scalar. -/
theorem monomial_coefficient (rank : GrowthRank) (c : ℝ) :
    (monomial rank c).coeff rank = c := by
  exact HahnSeries.coeff_single_same rank c

/-- A nonzero transmonomial is nonzero as a transseries. -/
theorem monomial_ne_zero {rank : GrowthRank} {c : ℝ} (hc : c ≠ 0) :
    monomial rank c ≠ 0 := by
  apply HahnSeries.ne_zero_of_coeff_ne_zero (g := rank)
  simpa [monomial] using hc

/-- Transmonomials at distinct ranks have disjoint coefficient witnesses and
therefore cannot be equal when the first coefficient is nonzero. -/
theorem monomial_ne_monomial_of_rank_ne {r s : GrowthRank} {a b : ℝ}
    (hrs : r ≠ s) (ha : a ≠ 0) : monomial r a ≠ monomial s b := by
  intro h
  have hc := congrArg (fun t : Transseries => t.coeff r) h
  simp [monomial, HahnSeries.coeff_single_same,
    HahnSeries.coeff_single_of_ne hrs] at hc
  exact ha hc

/-- Below the order of a transseries, every coefficient vanishes. -/
theorem coeff_eq_zero_below_order {f : Transseries}
    {rank : GrowthRank} (hrank : rank < f.order) :
    f.coeff rank = 0 := by
  by_contra hcoeff
  have hle : f.order ≤ rank := HahnSeries.order_le_of_coeff_ne_zero hcoeff
  exact (not_le_of_gt hrank) hle

/-- Two transseries agree below the order of their difference. -/
theorem agreeBelow_order_sub (f g : Transseries) :
    AgreeBelow f g (f - g).order := by
  intro rank hrank
  have hz := coeff_eq_zero_below_order hrank
  rw [HahnSeries.coeff_sub] at hz
  exact sub_eq_zero.mp hz

/-- Unequal transseries actually disagree at the order of their difference. -/
theorem coefficient_ne_at_order_sub {f g : Transseries} (hfg : f ≠ g) :
    f.coeff (f - g).order ≠ g.coeff (f - g).order := by
  have hsub : f - g ≠ 0 := sub_ne_zero.mpr hfg
  have hn := HahnSeries.coeff_order_eq_zero.not.mpr hsub
  rw [HahnSeries.coeff_sub] at hn
  exact sub_ne_zero.mp hn

/-- Every unequal pair has a first formal disagreement: all lower coefficients
agree, while the coefficient at the distinguished rank differs. -/
theorem exists_first_disagreement {f g : Transseries} (hfg : f ≠ g) :
    ∃ rank, AgreeBelow f g rank ∧ f.coeff rank ≠ g.coeff rank := by
  exact ⟨(f - g).order, agreeBelow_order_sub f g,
    coefficient_ne_at_order_sub hfg⟩

/-- There are no nonzero flat transseries: vanishing at every formal order forces
vanishing of the whole Hahn series. -/
theorem no_nonzero_flat_transseries {f : Transseries}
    (hflat : ∀ rank, f.coeff rank = 0) : f = 0 := by
  apply HahnSeries.ext
  funext rank
  simpa using hflat rank

/-- Equality of all orders is preserved by addition, expressing compatibility of
formal asymptotic expansions with the additive field operation. -/
theorem agreeToAllOrders_add {f₁ f₂ g₁ g₂ : Transseries}
    (h₁ : AgreeToAllOrders f₁ g₁) (h₂ : AgreeToAllOrders f₂ g₂) :
    AgreeToAllOrders (f₁ + f₂) (g₁ + g₂) := by
  intro rank
  simp only [HahnSeries.coeff_add]
  rw [h₁ rank, h₂ rank]

/-- Equality of all orders is preserved by multiplication, via extensional
uniqueness of the corresponding Hahn series. -/
theorem agreeToAllOrders_mul {f₁ f₂ g₁ g₂ : Transseries}
    (h₁ : AgreeToAllOrders f₁ g₁) (h₂ : AgreeToAllOrders f₂ g₂) :
    AgreeToAllOrders (f₁ * f₂) (g₁ * g₂) := by
  have e₁ : f₁ = g₁ := asymptotic_comparison.mp h₁
  have e₂ : f₂ = g₂ := asymptotic_comparison.mp h₂
  simp [e₁, e₂, AgreeToAllOrders]

end EMLTransseries