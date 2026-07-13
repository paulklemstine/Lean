/-
# The Local Obstruction to Naive Higher-Genus Factorization (contrarian)

The genus-0 Giampietro–Darmon formula expresses the `p`-adic valuation of a
cross-ratio as an alternating sum of local intersection multiplicities
`m(x,y) = v_p(x - y)`. A tempting **bold conjecture** for the higher-genus
setting is that these local intersection multiplicities compose *additively*
along a chain of CM points:
`m(x, z) = m(x, y) + m(y, z)`.
This would make the local factorization purely combinatorial and would predict
that no global correction is ever needed.

We **disprove** this conjecture: local intersection multiplicities are *not*
additive (`chain_additivity_fails`). What is true instead is the **ultrametric
(strong triangle) inequality** (`localMult_ultrametric`), and — sharpening it —
an exact equality when the two multiplicities differ (`localMult_isosceles`).
This ultrametric behaviour is exactly the local reason a nontrivial global
obstruction (the Néron–Tate height pairing) is forced upon the higher-genus
factorization.

## Main results
* `localMult_symm` — symmetry of the local intersection multiplicity.
* `localMult_ultrametric` — the strong triangle inequality.
* `localMult_isosceles` — sharp equality when the two multiplicities differ.
* `chain_additivity_fails` — an explicit counterexample disproving additivity.
-/
import Mathlib

open scoped BigOperators

namespace GiampietroDarmon

/-- The **local intersection multiplicity** at `p` of two CM points `x, y`,
modelled as the `p`-adic valuation of their difference. -/
def localMult (p : ℕ) (x y : ℚ) : ℤ := padicValRat p (x - y)

/-
The local intersection multiplicity is symmetric.
-/
theorem localMult_symm (p : ℕ) (x y : ℚ) : localMult p x y = localMult p y x := by
  unfold localMult; rw [ ← neg_sub, padicValRat.neg ] ;

/-
**Ultrametric (strong triangle) inequality** for local intersection
multiplicities: the multiplicity of the "outer" pair is at least the minimum of
the two "inner" multiplicities.
-/
theorem localMult_ultrametric (p : ℕ) [Fact p.Prime] {x y z : ℚ} (hxz : x ≠ z) :
    min (localMult p x y) (localMult p y z) ≤ localMult p x z := by
  unfold localMult
  have hne : (x - y) + (y - z) ≠ 0 := by
    rw [sub_add_sub_cancel]; exact sub_ne_zero.mpr hxz
  have h := padicValRat.min_le_padicValRat_add (p := p) hne
  rwa [sub_add_sub_cancel] at h

/-
**Sharp isosceles equality.** When the two inner multiplicities differ, the
ultrametric inequality is an equality: the outer multiplicity is exactly their
minimum.
-/
theorem localMult_isosceles (p : ℕ) [Fact p.Prime] {x y z : ℚ}
    (hxy : x ≠ y) (hyz : y ≠ z) (hxz : x ≠ z)
    (hne : localMult p x y ≠ localMult p y z) :
    localMult p x z = min (localMult p x y) (localMult p y z) := by
  unfold localMult
  have hq : x - y ≠ 0 := sub_ne_zero.mpr hxy
  have hr : y - z ≠ 0 := sub_ne_zero.mpr hyz
  have hqr : (x - y) + (y - z) ≠ 0 := by
    rw [sub_add_sub_cancel]; exact sub_ne_zero.mpr hxz
  have h := padicValRat.add_eq_min (p := p) hqr hq hr hne
  rwa [sub_add_sub_cancel] at h

/-
**Disproof of naive chain-additivity.** With `p = 2` and the collinear
points `0, 1, 2` we have `m(0,1) = m(1,2) = 0` but `m(0,2) = 1`, so
`m(0,2) ≠ m(0,1) + m(1,2)`. Hence local intersection multiplicities are *not*
additive along chains, and the higher-genus factorization cannot be obtained by
naive local composition.
-/
theorem chain_additivity_fails :
    ∃ (p : ℕ) (_ : Fact p.Prime) (x y z : ℚ),
      localMult p x z ≠ localMult p x y + localMult p y z := by
  refine ⟨2, ⟨by norm_num⟩, 0, 1, 2, ?_⟩
  have h1 : localMult 2 (0 : ℚ) 1 = 0 := by unfold localMult; norm_num [padicValRat.neg]
  have h2 : localMult 2 (1 : ℚ) 2 = 0 := by unfold localMult; norm_num [padicValRat.neg]
  have h3 : localMult 2 (0 : ℚ) 2 = 1 := by
    unfold localMult; norm_num [padicValRat.neg]
    simpa using padicValRat.self (p := 2) (by norm_num)
  rw [h1, h2, h3]; norm_num

end GiampietroDarmon