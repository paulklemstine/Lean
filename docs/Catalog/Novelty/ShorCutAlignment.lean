import Novelty.ShorCutRankSharp
import Novelty.ShorQFTOutputState

/-! # Aligned cuts, and why Shor's register never has one

The sharp rank formulas `schmidtRank_combCut_sharp` (QFT input) and
`schmidtRank_outputCut` (QFT output) say that the cut `x = b + B·c` costs bond
dimension `min C (r / gcd(r, B))` at the input and `min C (m / gcd(m, B))` at
the output, where `Q = r · m`.

This file settles two questions raised by those formulas.

* `schmidtRank_eq_one_of_aligned` : if the block size `B` is a common multiple of
  *both* `r` and `m` then **both** endpoints of the QFT are product states across
  that cut.  In particular the conjecture that the two endpoint ranks are
  *complementary* — that no cut can compress both — is **false**:
  `not_complementary_ranks` exhibits `r = m = B = C = 6` with both ranks equal
  to one.

* `schmidtRank_combCut_pow_two_of_odd` and `two_le_schmidtRank_combCut_pow_two` :
  for an *odd* order `r > 1` no power-of-two block size is aligned
  (`not_dvd_pow_two_of_odd`), and the rank across every power-of-two cut is the
  full `min C r`.  Shor's register is a qubit register, so the collapse above is
  unreachable for the odd orders that factoring produces: the escape hatch found
  by the counterexample is exactly the classically easy regime.
-/

open Finset

namespace ShorIrreducible

open IITTensorNetwork

section Alignment

variable {B C r m x0 j Q : ℕ} {amp : ℝ}

/-- The cut period degenerates exactly on aligned cuts. -/
lemma cutPeriod_eq_one_of_dvd (hr : 0 < r) (h : r ∣ B) : cutPeriod r B = 1 := by
  rw [cutPeriod, Nat.gcd_eq_left h, Nat.div_self hr]

/-- **An aligned cut collapses both endpoints of the QFT.**  If the block size is
a common multiple of the period `r` of the input comb and of the period `m` of
the output comb, then the state is a product state across that cut at *both*
ends of the transform. -/
theorem schmidtRank_eq_one_of_aligned [NeZero r] [NeZero m] (hamp : amp ≠ 0)
    (hr : 0 < r) (hm : 0 < m) (hB : 0 < B) (hC : 0 < C) (hrB : r ∣ B) (hmB : m ∣ B) :
    schmidtRank (combCutMatrix B C r x0 amp) = 1 ∧
      schmidtRank (outputCutMatrix B C m j Q amp) = 1 := by
  constructor
  · rw [schmidtRank_combCut_sharp hamp hr (Nat.le_of_dvd hB hrB),
      cutPeriod_eq_one_of_dvd hr hrB]
    exact min_eq_right hC
  · rw [schmidtRank_outputCut hamp hm (Nat.le_of_dvd hB hmB),
      cutPeriod_eq_one_of_dvd hm hmB]
    exact min_eq_right hC

/-- **The input/output complementarity conjecture is false.**  For the register
size `Q = 36` with `r = m = 6` and the cut `B = C = 6`, the QFT input comb *and*
the QFT output state are both product states across the cut: a single cut can
compress both endpoints. -/
theorem not_complementary_ranks (hamp : amp ≠ 0) :
    schmidtRank (combCutMatrix 6 6 6 x0 amp) = 1 ∧
      schmidtRank (outputCutMatrix 6 6 6 j Q amp) = 1 :=
  schmidtRank_eq_one_of_aligned hamp (by norm_num) (by norm_num) (by norm_num)
    (by norm_num) dvd_rfl dvd_rfl

/-- An odd number `> 1` never divides a power of two: no power-of-two cut of the
exponent register is aligned with an odd order. -/
theorem not_dvd_pow_two_of_odd {k : ℕ} (hodd : Odd r) (h1 : 1 < r) : ¬ r ∣ 2 ^ k := by
  intro hdvd
  have hcop : Nat.Coprime r (2 ^ k) :=
    ((Nat.coprime_two_left.mpr hodd).pow_left k).symm
  have hone : r ∣ 1 := by
    have := Nat.dvd_gcd (dvd_refl r) hdvd
    rwa [hcop] at this
  exact absurd (Nat.dvd_one.mp hone) (by omega)

/-- **Every power-of-two cut of an odd-order comb is maximally entangled.**  For
odd `r` the qubit cuts of Shor's register carry the full rank `r`. -/
theorem schmidtRank_combCut_pow_two_of_odd {k : ℕ} [NeZero r] (hamp : amp ≠ 0)
    (hodd : Odd r) (hr : 0 < r) (hB : r ≤ 2 ^ k) (hC : r ≤ C) :
    schmidtRank (combCutMatrix (2 ^ k) C r x0 amp) = r :=
  schmidtRank_combCut_eq_of_coprime hamp hr hB hC
    ((Nat.coprime_two_left.mpr hodd).pow_left k)

/-- Consequently, for an odd order `r > 1` no qubit cut of the exponent register
is a product cut: the collapse of `not_complementary_ranks` cannot occur in
Shor's algorithm. -/
theorem two_le_schmidtRank_combCut_pow_two {k : ℕ} [NeZero r] (hamp : amp ≠ 0)
    (hodd : Odd r) (h1 : 1 < r) (hB : r ≤ 2 ^ k) (hC : r ≤ C) :
    2 ≤ schmidtRank (combCutMatrix (2 ^ k) C r x0 amp) := by
  rw [schmidtRank_combCut_pow_two_of_odd hamp hodd (by omega) hB hC]
  exact h1

end Alignment

end ShorIrreducible