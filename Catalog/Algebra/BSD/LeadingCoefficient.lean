import Mathlib

/-!
# Formal consequences of the Birch--Swinnerton-Dyer leading-coefficient formula

The full Birch--Swinnerton-Dyer conjecture is open.  This file therefore does not claim a
proof of it.  Instead it packages the numerical invariants occurring in its leading-term
formula and proves a chain of nontrivial consequences of that formula.  In particular, all
positivity and nonvanishing side conditions are derived explicitly.
-/

namespace BSD

/-- Numerical data appearing on the arithmetic side of the BSD leading-coefficient formula.
`shaCard` represents the (conjecturally finite) Tate--Shafarevich group order, `tamagawa`
its local Tamagawa numbers, `torsionCard` the rational torsion subgroup order, and the two
real quantities are the regulator and period. -/
structure ArithmeticData where
  shaCard : ℕ
  tamagawa : Finset ℕ
  torsionCard : ℕ
  regulator : ℝ
  period : ℝ

namespace ArithmeticData

/-- Product of all local Tamagawa numbers in a finite bad-prime set. -/
def tamagawaProduct (d : ArithmeticData) : ℕ := ∏ v ∈ d.tamagawa, v

/-- The arithmetic quantity predicted by BSD to be the first nonzero Taylor coefficient. -/
noncomputable def arithmeticLeadingCoefficient (d : ArithmeticData) : ℝ :=
  d.regulator * d.period * (d.shaCard : ℝ) * (d.tamagawaProduct : ℝ) /
    (d.torsionCard : ℝ) ^ 2

/-- Positive local Tamagawa numbers have positive global product. -/
theorem tamagawaProduct_pos (d : ArithmeticData)
    (hTam : ∀ v ∈ d.tamagawa, 0 < v) : 0 < d.tamagawaProduct := by
  simp only [tamagawaProduct]
  exact Finset.prod_pos hTam

/-- The arithmetic BSD leading coefficient is positive when each constituent invariant has
its expected positivity and the finite group orders are nonzero. -/
theorem arithmeticLeadingCoefficient_pos (d : ArithmeticData)
    (hReg : 0 < d.regulator) (hPeriod : 0 < d.period)
    (hSha : 0 < d.shaCard) (hTam : ∀ v ∈ d.tamagawa, 0 < v)
    (hTors : 0 < d.torsionCard) : 0 < d.arithmeticLeadingCoefficient := by
  unfold arithmeticLeadingCoefficient
  apply div_pos
  · exact mul_pos
      (mul_pos (mul_pos hReg hPeriod) (Nat.cast_pos.mpr hSha))
      (Nat.cast_pos.mpr (tamagawaProduct_pos d hTam))
  · exact pow_pos (Nat.cast_pos.mpr hTors) 2

/-- Consequently, the arithmetic side of the BSD formula cannot vanish. -/
theorem arithmeticLeadingCoefficient_ne_zero (d : ArithmeticData)
    (hReg : 0 < d.regulator) (hPeriod : 0 < d.period)
    (hSha : 0 < d.shaCard) (hTam : ∀ v ∈ d.tamagawa, 0 < v)
    (hTors : 0 < d.torsionCard) : d.arithmeticLeadingCoefficient ≠ 0 := by
  exact ne_of_gt (arithmeticLeadingCoefficient_pos d hReg hPeriod hSha hTam hTors)

end ArithmeticData

/-- A compact abstract statement of the two assertions in BSD: analytic rank equals
Mordell--Weil rank, and the first nonzero coefficient equals the arithmetic expression. -/
structure Formula (d : ArithmeticData) (mordellWeilRank analyticRank : ℕ)
    (leadingCoefficient : ℝ) : Prop where
  rank_eq : analyticRank = mordellWeilRank
  leading_eq : leadingCoefficient = d.arithmeticLeadingCoefficient

/-- Under the BSD formula and standard positivity hypotheses, the analytic leading
coefficient is positive. -/
theorem Formula.leadingCoefficient_pos {d : ArithmeticData} {mwRank analyticRank : ℕ}
    {leadingCoefficient : ℝ} (hBSD : Formula d mwRank analyticRank leadingCoefficient)
    (hReg : 0 < d.regulator) (hPeriod : 0 < d.period)
    (hSha : 0 < d.shaCard) (hTam : ∀ v ∈ d.tamagawa, 0 < v)
    (hTors : 0 < d.torsionCard) : 0 < leadingCoefficient := by
  rw [hBSD.leading_eq]
  exact d.arithmeticLeadingCoefficient_pos hReg hPeriod hSha hTam hTors

/-- The BSD formula therefore identifies a genuinely nonzero first Taylor coefficient. -/
theorem Formula.leadingCoefficient_ne_zero {d : ArithmeticData} {mwRank analyticRank : ℕ}
    {leadingCoefficient : ℝ} (hBSD : Formula d mwRank analyticRank leadingCoefficient)
    (hReg : 0 < d.regulator) (hPeriod : 0 < d.period)
    (hSha : 0 < d.shaCard) (hTam : ∀ v ∈ d.tamagawa, 0 < v)
    (hTors : 0 < d.torsionCard) : leadingCoefficient ≠ 0 := by
  exact ne_of_gt (hBSD.leadingCoefficient_pos hReg hPeriod hSha hTam hTors)

/-- If the functional equation sign is `(-1)^analyticRank`, BSD transfers this parity
statement from analytic rank to Mordell--Weil rank. -/
theorem Formula.rootNumber_eq_rankParity {d : ArithmeticData} {mwRank analyticRank : ℕ}
    {leadingCoefficient rootNumber : ℝ}
    (hBSD : Formula d mwRank analyticRank leadingCoefficient)
    (hSign : rootNumber = (-1 : ℝ) ^ analyticRank) :
    rootNumber = (-1 : ℝ) ^ mwRank := by
  rw [hSign, hBSD.rank_eq]

/-- In particular, an even Mordell--Weil rank forces root number `+1`. -/
theorem Formula.rootNumber_eq_one_of_even_rank {d : ArithmeticData}
    {mwRank analyticRank : ℕ} {leadingCoefficient rootNumber : ℝ}
    (hBSD : Formula d mwRank analyticRank leadingCoefficient)
    (hSign : rootNumber = (-1 : ℝ) ^ analyticRank) (hEven : Even mwRank) :
    rootNumber = 1 := by
  rw [hBSD.rootNumber_eq_rankParity hSign]
  exact hEven.neg_one_pow

/-- Dually, an odd Mordell--Weil rank forces root number `-1`. -/
theorem Formula.rootNumber_eq_neg_one_of_odd_rank {d : ArithmeticData}
    {mwRank analyticRank : ℕ} {leadingCoefficient rootNumber : ℝ}
    (hBSD : Formula d mwRank analyticRank leadingCoefficient)
    (hSign : rootNumber = (-1 : ℝ) ^ analyticRank) (hOdd : Odd mwRank) :
    rootNumber = -1 := by
  rw [hBSD.rootNumber_eq_rankParity hSign]
  exact hOdd.neg_one_pow

end BSD