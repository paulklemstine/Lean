import Mathlib
import Applications.EML.Transseries
import Bridges.PosetTheory.EMLInterpolation

/-!
# Contrarian results for EML transseries

This file tests two bold versions of the transseries program against the concrete
Hahn-series model in `Applications.EML.Transseries`.

* The chosen value group is not divisible, so this Hahn field is **not** real
  closed.  A monomial whose first growth coordinate is `1` cannot be a square:
  the order of a square has an even first coordinate.
* Unrestricted point evaluation of EML syntax is **not** injective.  At `0`, the
  variable and the constant zero agree, despite being distinct expressions.

It also strengthens formal asymptotic comparison by showing that every unequal
pair has a unique first disagreement rank.
-/

noncomputable section

open HahnSeries

namespace EMLTransseries

/-- A growth rank with odd first coordinate. -/
def oddExponentialRank : GrowthRank := (1, (0, 0))

/-- No doubled growth rank equals `oddExponentialRank`. -/
theorem two_mul_rank_ne_oddExponentialRank (rank : GrowthRank) :
    rank + rank ≠ oddExponentialRank := by
  intro h
  have hfirst := congrArg (fun z : GrowthRank => z.1) h
  change rank.1 + rank.1 = 1 at hfirst
  omega

/-- A nonzero Hahn series square has twice the order of its square root. -/
theorem order_sq_of_ne_zero {f : Transseries} (hf : f ≠ 0) :
    (f * f).order = f.order + f.order := by
  exact HahnSeries.order_mul hf hf

/-- The monomial at the odd exponential rank is not a square. -/
theorem oddExponentialMonomial_not_isSquare :
    ¬ IsSquare (monomial oddExponentialRank 1) := by
  rintro ⟨f, hf⟩
  have hmono : monomial oddExponentialRank 1 ≠ 0 := monomial_ne_zero one_ne_zero
  have hfnz : f ≠ 0 := by
    intro hz
    apply hmono
    rw [hf, hz]
    simp
  have hord := congrArg HahnSeries.order hf
  rw [order_sq_of_ne_zero hfnz] at hord
  unfold monomial at hord
  rw [HahnSeries.order_single (a := oddExponentialRank) one_ne_zero] at hord
  exact two_mul_rank_ne_oddExponentialRank f.order hord.symm

/-- The negative of the odd-rank monomial is not a square either. -/
theorem neg_oddExponentialMonomial_not_isSquare :
    ¬ IsSquare (-monomial oddExponentialRank 1) := by
  rintro ⟨f, hf⟩
  have hneg : -monomial oddExponentialRank 1 ≠ 0 := neg_ne_zero.mpr (monomial_ne_zero one_ne_zero)
  have hfnz : f ≠ 0 := by
    intro hz
    apply hneg
    rw [hf, hz]
    simp
  have hord := congrArg HahnSeries.order hf
  have hsingle : -monomial oddExponentialRank 1 = monomial oddExponentialRank (-1) := by
    simp [monomial, ← HahnSeries.single_neg]
  rw [order_sq_of_ne_zero hfnz, hsingle] at hord
  unfold monomial at hord
  rw [HahnSeries.order_single (a := oddExponentialRank)
    (by norm_num : (-1 : ℝ) ≠ 0)] at hord
  exact two_mul_rank_ne_oddExponentialRank f.order hord.symm

/-- **Disproof of the naive real-closedness conjecture.**  The Hahn field with
integer lexicographic growth ranks is not real closed.  Real closed fields make
one of `a` and `-a` a square, contradicted by the odd-rank monomial. -/
theorem transseries_not_realClosed : ¬ IsRealClosed Transseries := by
  intro hrc
  letI : IsRealClosed Transseries := hrc
  rcases IsRealClosed.isSquare_or_isSquare_neg
      (monomial oddExponentialRank 1) with h | h
  · exact oddExponentialMonomial_not_isSquare h
  · exact neg_oddExponentialMonomial_not_isSquare h

/-- Two first-disagreement witnesses for the same pair must have the same rank. -/
theorem first_disagreement_rank_unique {f g : Transseries} {r s : GrowthRank}
    (hr : AgreeBelow f g r) (hrne : f.coeff r ≠ g.coeff r)
    (hs : AgreeBelow f g s) (hsne : f.coeff s ≠ g.coeff s) : r = s := by
  rcases lt_trichotomy r s with hrs | hrs | hrs
  · exact False.elim (hrne (hs r hrs))
  · exact hrs
  · exact False.elim (hsne (hr s hrs))

/-- Strengthened asymptotic comparison: unequal transseries possess exactly one
rank below which they agree and at which they first differ. -/
theorem exists_unique_first_disagreement {f g : Transseries} (hfg : f ≠ g) :
    ∃! rank, AgreeBelow f g rank ∧ f.coeff rank ≠ g.coeff rank := by
  obtain ⟨rank, hbelow, hne⟩ := exists_first_disagreement hfg
  refine ⟨rank, ⟨hbelow, hne⟩, ?_⟩
  intro s hs
  exact (first_disagreement_rank_unique (f := f) (g := g)
    (r := rank) (s := s) hbelow hne hs.1 hs.2).symm

end EMLTransseries

namespace EMLExpr

/-- The variable expression and constant zero have the same value at zero. -/
theorem var_eval_zero_eq_const_zero :
    EMLExpr.var.eval 0 = (EMLExpr.const 0).eval 0 := by
  simp [EMLExpr.eval]

/-- The variable expression is syntactically distinct from constant zero. -/
theorem var_ne_const_zero : EMLExpr.var ≠ EMLExpr.const 0 := by
  intro h
  cases h

/-- **Counterexample to unrestricted semantic uniqueness.** Point evaluation at
`0` does not uniquely determine an EML expression. -/
theorem eval_at_zero_not_injective :
    ¬ Function.Injective (fun e : EMLExpr => e.eval 0) := by
  intro hinj
  exact var_ne_const_zero (hinj var_eval_zero_eq_const_zero)

end EMLExpr