/-
# ECM-PARITY, robustness: the Jacobi dial for every cubic of prime discriminant `-ℓ`

`ECMParitySymmetric` treats the generic ECM curve `E₀ : y² = x³ + x + 1`
(`Δ = -31`).  Nothing in the argument is special to `31`: what is used is that
`Δ = -ℓ` with `ℓ` a prime `≡ 3 (mod 4)`, so that quadratic reciprocity turns the
Legendre symbol `(Δ|p)` into the residue dial `(p mod ℓ | ℓ)`.

This file proves the general statement and instantiates it twice:

* `ECMParity.or_two_dvd_cubicCardZ_of_jacobi` — general semiprime shadow for any
  integral depressed cubic with `-4a³ - 27b² = -ℓ`;
* `ECMParity.or_two_dvd_E0` — the `Δ = -31` face (`x³ + x + 1`);
* `ECMParity.or_two_dvd_E1` — the `Δ = -23` robustness face (`x³ - x + 1`),
  the second curve of the experiment.
-/
import Mathlib
import Algebra.ECMParityCore
import Algebra.ECMParityFrobenius
import Algebra.ECMParitySymmetric

namespace ECMParity

open Finset

/-- The order of `y² = x³ + a x + b` (integral coefficients) reduced mod `p`. -/
def cubicCardZ (a b : ℤ) (p : ℕ) [Fact p.Prime] : ℕ :=
  curveCard ((a : ZMod p)) ((b : ZMod p))

variable {p : ℕ} [Fact p.Prime]

theorem disc_cast (a b : ℤ) : disc ((a : ZMod p)) ((b : ZMod p))
    = (((-4 * a ^ 3 - 27 * b ^ 2 : ℤ)) : ZMod p) := by
  push_cast [disc]
  ring

theorem natCast_ne_zero_of_prime_ne {l : ℕ} [Fact l.Prime] (hpl : p ≠ l) :
    ((l : ℕ) : ZMod p) ≠ 0 := by
  intro h
  rw [ZMod.natCast_eq_zero_iff] at h
  have hp' : p.Prime := Fact.out
  have hl' : l.Prime := Fact.out
  exact hpl ((Nat.prime_dvd_prime_iff_eq hp' hl').1 h)

theorem disc_ne_zero_of_eq_neg_prime {l : ℕ} [Fact l.Prime] {a b : ℤ}
    (hab : -4 * a ^ 3 - 27 * b ^ 2 = -(l : ℤ)) (hpl : p ≠ l) :
    disc ((a : ZMod p)) ((b : ZMod p)) ≠ 0 := by
  rw [disc_cast, hab]
  intro h
  refine natCast_ne_zero_of_prime_ne (l := l) hpl ?_
  push_cast at h ⊢
  linear_combination -h

/-- **`(Δ|p)`-pinned face, general form.**  If `-4a³ - 27b² = -ℓ` with `ℓ` a prime
`≡ 3 (mod 4)` and `p` is a non-residue mod `ℓ`, then `2 ∣ #E(𝔽_p)`. -/
theorem two_dvd_cubicCardZ_of_legendre {l : ℕ} [Fact l.Prime] (hl : l % 4 = 3) {a b : ℤ}
    (hab : -4 * a ^ 3 - 27 * b ^ 2 = -(l : ℤ)) (hp2 : p ≠ 2) (hpl : p ≠ l)
    (h : legendreSym l p = -1) : 2 ∣ cubicCardZ a b p := by
  have hd : disc ((a : ZMod p)) ((b : ZMod p)) ≠ 0 := disc_ne_zero_of_eq_neg_prime hab hpl
  refine two_dvd_curveCard_of_legendre_eq_neg_one hp2 _ _ (-4 * a ^ 3 - 27 * b ^ 2)
    (disc_cast a b).symm hd ?_
  rw [hab, legendreSym_neg_of_three_mod_four hl hp2]
  exact h

/-- **Symmetric Jacobi shadow, general form.**  For a semiprime `N = p q` with
`(N | ℓ) = -1`, the order of `y² = x³ + a x + b` is even at `p` or at `q`. -/
theorem or_two_dvd_cubicCardZ_of_jacobi {l : ℕ} [Fact l.Prime] (hl : l % 4 = 3) {a b : ℤ}
    (hab : -4 * a ^ 3 - 27 * b ^ 2 = -(l : ℤ)) {q : ℕ} [Fact q.Prime]
    (hp2 : p ≠ 2) (hq2 : q ≠ 2) (hpl : p ≠ l) (hql : q ≠ l)
    (h : jacobiSym ((p * q : ℕ) : ℤ) l = -1) :
    2 ∣ cubicCardZ a b p ∨ 2 ∣ cubicCardZ a b q := by
  have hsplit : jacobiSym ((p * q : ℕ) : ℤ) l = legendreSym l p * legendreSym l q := by
    push_cast
    rw [jacobiSym.mul_left, ← jacobiSym.legendreSym.to_jacobiSym,
      ← jacobiSym.legendreSym.to_jacobiSym]
  rw [hsplit] at h
  have hpne : ((p : ℤ) : ZMod l) ≠ 0 := by
    have hp : (p : ZMod l) ≠ 0 := natCast_ne_zero_of_prime_ne (p := l) (l := p) (Ne.symm hpl)
    simpa using hp
  have hqne : ((q : ℤ) : ZMod l) ≠ 0 := by
    have hq : (q : ZMod l) ≠ 0 := natCast_ne_zero_of_prime_ne (p := l) (l := q) (Ne.symm hql)
    simpa using hq
  rcases legendreSym.eq_one_or_neg_one l hpne with hpl' | hpl'
  · rcases legendreSym.eq_one_or_neg_one l hqne with hql' | hql'
    · rw [hpl', hql'] at h; norm_num at h
    · exact Or.inr (two_dvd_cubicCardZ_of_legendre hl hab hq2 hql hql')
  · exact Or.inl (two_dvd_cubicCardZ_of_legendre hl hab hp2 hpl hpl')

/-! ## Two instances: `Δ = -31` and the `Δ = -23` robustness face -/

instance fact_prime_23' : Fact (Nat.Prime 23) := ⟨by norm_num⟩

/-- `E₀ : y² = x³ + x + 1`, discriminant `-31`. -/
theorem or_two_dvd_E0 {q : ℕ} [Fact q.Prime] (hp2 : p ≠ 2) (hq2 : q ≠ 2)
    (hp31 : p ≠ 31) (hq31 : q ≠ 31) (h : jacobiSym ((p * q : ℕ) : ℤ) 31 = -1) :
    2 ∣ cubicCardZ 1 1 p ∨ 2 ∣ cubicCardZ 1 1 q :=
  or_two_dvd_cubicCardZ_of_jacobi (l := 31) (by norm_num) (by norm_num) hp2 hq2 hp31 hq31 h

/-- `E₁ : y² = x³ - x + 1`, discriminant `-23`: the robustness face of the experiment. -/
theorem or_two_dvd_E1 {q : ℕ} [Fact q.Prime] (hp2 : p ≠ 2) (hq2 : q ≠ 2)
    (hp23 : p ≠ 23) (hq23 : q ≠ 23) (h : jacobiSym ((p * q : ℕ) : ℤ) 23 = -1) :
    2 ∣ cubicCardZ (-1) 1 p ∨ 2 ∣ cubicCardZ (-1) 1 q :=
  or_two_dvd_cubicCardZ_of_jacobi (l := 23) (by norm_num) (by norm_num) hp2 hq2 hp23 hq23 h

end ECMParity