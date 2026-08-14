/-
# ECM-PARITY, symmetric face: a Jacobi residue dial for the parity of the ECM order

The generic ECM curve is `E₀ : y² = x³ + x + 1`, whose cubic has discriminant
`Δ = -4 - 27 = -31`.  Combining the parity dichotomy (`ECMParityCore`) with the
cubic parity law (`ECMParityFrobenius`) and quadratic reciprocity we obtain a
**residue dial**: a condition on `N mod 31` alone which *forces* the order of
`E₀` to be even at one of the two prime factors of a semiprime `N = p q`.

* `ECMParity.legendreSym_neg_of_three_mod_four` — for `ℓ ≡ 3 (mod 4)` prime,
  `(-ℓ | p) = (p | ℓ)`; with `ℓ = 31` this is the reciprocity step
  `(Δ|p) = (p mod 31 | 31)`.
* `ECMParity.two_dvd_E0Card_of_legendre_31` — if `(p | 31) = -1` then
  `2 ∣ #E₀(𝔽_p)`; the transposition face is `(Δ|p)`-pinned.
* `ECMParity.or_two_dvd_E0Card_of_jacobi` — **the symmetric shadow**: if the
  Jacobi symbol `(N | 31) = -1` for `N = p q`, then `2 ∣ #E₀(𝔽_p)` or
  `2 ∣ #E₀(𝔽_q)`.  This is exactly the empirical `P(OR | (Δ|N) = -1) = 1`.
* `ECMParity.or_two_dvd_E0Card_of_residue` — the dial only reads `N mod 31`.

The last section proves the exact **Jensen deficit identity** behind the
observed compression `P(OR | (Δ|N) = +1) < 7/9`: for a non-flat fork the union
probability drops below its flat value by exactly the variance of the fork.
-/
import Mathlib
import Algebra.ECMParityCore
import Algebra.ECMParityFrobenius

namespace ECMParity

open Finset

instance fact_prime_31 : Fact (Nat.Prime 31) := ⟨by norm_num⟩

/-! ## 1. Reciprocity: `(-ℓ | p) = (p | ℓ)` for `ℓ ≡ 3 (mod 4)` -/

theorem legendreSym_neg_of_three_mod_four {l : ℕ} [Fact l.Prime] (hl : l % 4 = 3)
    {p : ℕ} [Fact p.Prime] (hp : p ≠ 2) :
    legendreSym p (-(l : ℤ)) = legendreSym l p := by
  have hl2 : l ≠ 2 := by omega
  have hmul : legendreSym p (-(l : ℤ)) = legendreSym p (-1) * legendreSym p l := by
    rw [← legendreSym.mul]; norm_num
  have hpodd : p % 2 = 1 :=
    (Nat.Prime.eq_two_or_odd (Fact.out : p.Prime)).resolve_left hp
  have hp4 : p % 4 = 1 ∨ p % 4 = 3 := by omega
  rcases hp4 with h4 | h4
  · rw [hmul, legendreSym.at_neg_one hp, ZMod.χ₄_nat_one_mod_four h4, one_mul,
      legendreSym.quadratic_reciprocity_one_mod_four h4 hl2]
  · rw [hmul, legendreSym.at_neg_one hp, ZMod.χ₄_nat_three_mod_four h4,
      legendreSym.quadratic_reciprocity_three_mod_four h4 hl, neg_one_mul]

/-! ## 2. The generic ECM curve `E₀ : y² = x³ + x + 1` -/

variable {p : ℕ} [Fact p.Prime]

/-- The order of the generic ECM curve `E₀ : y² = x³ + x + 1` over `𝔽_p`. -/
def E0Card (p : ℕ) [Fact p.Prime] : ℕ := curveCard (1 : ZMod p) 1

theorem disc_E0 : disc (1 : ZMod p) 1 = ((-31 : ℤ) : ZMod p) := by
  push_cast [disc]
  ring

theorem disc_E0_ne_zero (hp31 : p ≠ 31) : disc (1 : ZMod p) 1 ≠ 0 := by
  rw [disc_E0]
  intro h
  have h31 : ((31 : ℕ) : ZMod p) = 0 := by push_cast at h ⊢; linear_combination -h
  rw [ZMod.natCast_eq_zero_iff] at h31
  have hp' : p.Prime := Fact.out
  exact hp31 ((Nat.prime_dvd_prime_iff_eq hp' (by norm_num)).1 h31)

/-- **The `(Δ|p)`-pinned face for `E₀`.**  If `p` is a non-residue mod `31`, then the
order of `E₀` over `𝔽_p` is even. -/
theorem two_dvd_E0Card_of_legendre_31 (hp2 : p ≠ 2) (hp31 : p ≠ 31)
    (h : legendreSym 31 p = -1) : 2 ∣ E0Card p := by
  refine two_dvd_curveCard_of_legendre_eq_neg_one hp2 1 1 (-31) disc_E0.symm
    (disc_E0_ne_zero hp31) ?_
  rw [show ((-31 : ℤ)) = -((31 : ℕ) : ℤ) by norm_num,
    legendreSym_neg_of_three_mod_four (by norm_num) hp2]
  exact h

/-! ## 3. The symmetric shadow on a semiprime -/

/-- **Symmetric Jacobi shadow.**  For a semiprime `N = p q` with `p, q` odd primes
different from `31`, if the Jacobi symbol `(N | 31)` equals `-1`, then the order of
`E₀` is even over `𝔽_p` or over `𝔽_q`.

Note `(N|31) = (p|31)(q|31) = (Δ|p)(Δ|q) = (Δ|N)`: this is the measured
`P(OR | (Δ|N) = -1) = 1` — an exact theorem, not a statistical excess. -/
theorem or_two_dvd_E0Card_of_jacobi {q : ℕ} [Fact q.Prime] (hp2 : p ≠ 2) (hq2 : q ≠ 2)
    (hp31 : p ≠ 31) (hq31 : q ≠ 31) (h : jacobiSym ((p * q : ℕ) : ℤ) 31 = -1) :
    2 ∣ E0Card p ∨ 2 ∣ E0Card q := by
  have hsplit : jacobiSym ((p * q : ℕ) : ℤ) 31 = legendreSym 31 p * legendreSym 31 q := by
    push_cast
    rw [jacobiSym.mul_left, ← jacobiSym.legendreSym.to_jacobiSym, ← jacobiSym.legendreSym.to_jacobiSym]
  rw [hsplit] at h
  have hpne : ((p : ℤ) : ZMod 31) ≠ 0 := by
    have : (p : ZMod 31) ≠ 0 := by
      intro hz
      rw [ZMod.natCast_eq_zero_iff] at hz
      have hp' : p.Prime := Fact.out
      exact hp31 (((Nat.prime_dvd_prime_iff_eq (by norm_num) hp').1 hz).symm)
    simpa using this
  have hqne : ((q : ℤ) : ZMod 31) ≠ 0 := by
    have : (q : ZMod 31) ≠ 0 := by
      intro hz
      rw [ZMod.natCast_eq_zero_iff] at hz
      have hq' : q.Prime := Fact.out
      exact hq31 (((Nat.prime_dvd_prime_iff_eq (by norm_num) hq').1 hz).symm)
    simpa using this
  rcases legendreSym.eq_one_or_neg_one 31 hpne with hpl | hpl
  · rcases legendreSym.eq_one_or_neg_one 31 hqne with hql | hql
    · rw [hpl, hql] at h; norm_num at h
    · exact Or.inr (two_dvd_E0Card_of_legendre_31 hq2 hq31 hql)
  · exact Or.inl (two_dvd_E0Card_of_legendre_31 hp2 hp31 hpl)

/-- **The dial reads only `N mod 31`.**  If `N = p q` and `N ≡ r (mod 31)` with
`(r | 31) = -1`, then the ECM order is even at one of the two factors. -/
theorem or_two_dvd_E0Card_of_residue {q : ℕ} [Fact q.Prime] (hp2 : p ≠ 2) (hq2 : q ≠ 2)
    (hp31 : p ≠ 31) (hq31 : q ≠ 31) (r : ℤ) (hr : ((p * q : ℕ) : ℤ) % 31 = r % 31)
    (hjac : jacobiSym r 31 = -1) : 2 ∣ E0Card p ∨ 2 ∣ E0Card q := by
  refine or_two_dvd_E0Card_of_jacobi hp2 hq2 hp31 hq31 ?_
  rw [jacobiSym.mod_left' (b := 31) (by exact_mod_cast hr)]
  exact hjac

/-! ## 4. The Jensen deficit of a non-flat fork -/

/-- **Exact Jensen deficit identity.**  Let `θ i` be the conditional probability that the
order is even in residue class `i`.  For two factors drawn in the *same* class the
union probability is `1 - (1/n) ∑ (1 - θ i)²`; the identity says it equals the flat
value `1 - (1 - mean)²` minus exactly the variance of the fork.  In particular a
non-flat fork compresses the union. -/
theorem jensen_union_deficit {n : ℕ} (hn : 0 < n) (θ : Fin n → ℝ) :
    1 - (∑ i, (1 - θ i) ^ 2) / n
      = (1 - (1 - (∑ i, θ i) / n) ^ 2) - (∑ i, (θ i - (∑ i, θ i) / n) ^ 2) / n := by
  have hn' : (n : ℝ) ≠ 0 := Nat.cast_ne_zero.2 hn.ne'
  have hexp : ∀ c : ℝ, (∑ i, (θ i - c) ^ 2)
      = (∑ i, (θ i) ^ 2) - 2 * c * (∑ i, θ i) + n * c ^ 2 := by
    intro c
    have hterm : ∀ i, (θ i - c) ^ 2 = (θ i) ^ 2 - 2 * c * θ i + c ^ 2 := by
      intro i; ring
    simp only [hterm, Finset.sum_add_distrib, Finset.sum_sub_distrib, ← Finset.mul_sum,
      Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
  have h1 : (∑ i, (1 - θ i) ^ 2) = (∑ i, (θ i) ^ 2) - 2 * (∑ i, θ i) + n := by
    have : ∀ i, (1 - θ i) ^ 2 = (θ i) ^ 2 - 2 * θ i + 1 := by intro i; ring
    simp only [this, Finset.sum_add_distrib, Finset.sum_sub_distrib, ← Finset.mul_sum,
      Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul, mul_one]
  rw [h1, hexp ((∑ i, θ i) / n)]
  field_simp
  ring

/-- The union probability of a fork never exceeds its flat value: the deficit is the
variance.  (`P(OR) ≤ 1 - (1 - mean)²`, with equality iff the fork is flat.) -/
theorem union_le_flat {n : ℕ} (hn : 0 < n) (θ : Fin n → ℝ) :
    1 - (∑ i, (1 - θ i) ^ 2) / n ≤ 1 - (1 - (∑ i, θ i) / n) ^ 2 := by
  rw [jensen_union_deficit hn θ]
  have hvar : 0 ≤ (∑ i, (θ i - (∑ i, θ i) / n) ^ 2) / n := by
    apply div_nonneg _ (Nat.cast_nonneg n)
    exact Finset.sum_nonneg fun i _ => sq_nonneg _
  linarith

end ECMParity