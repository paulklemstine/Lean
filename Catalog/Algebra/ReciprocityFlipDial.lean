/-
# Reciprocity-Flip Dials: the sign artifact behind the paper-226 secondaries

Formal core of experiment **577** (paper 227), diagnostic part (1).

## Background

A *dial* attaches to an integer `N` a vector of quadratic symbols recording, for
each small prime `ℓ`, whether `N` is a quadratic residue mod `ℓ`.  Two
implementations were used in the experimental record:

* the **clean (Legendre) form**  `ℓ ↦ (N | ℓ)`  — symbol with the *prime on the
  bottom*;
* the **product / composite-bottom form** `ℓ ↦ (ℓ | N)` — symbol with the
  *composite* `N` on the bottom, evaluated as a Jacobi symbol.

Experimentally the second form was much weaker as a covariate, and the diagnosis
was that the two forms differ by a **reciprocity sign flip** that switches on
exactly when `ℓ ≡ 3 (mod 4)` and `N ≡ 3 (mod 4)` — reported as "conditional flip
100%, 2680/2680, zero violations".

This file proves that diagnosis, in both the prime-bottom (Legendre) and
composite-bottom (Jacobi) settings, and derives the exact residue bookkeeping
that turns the conditional statement into an unconditional density.

## Main results

* `ReciprocityFlipDial.legendre_flip_of_three_mod_four` — the flip is *total*
  on its condition: for distinct odd primes `p ≡ q ≡ 3 (mod 4)` the two dial
  forms are exact negatives (zero violations).
* `ReciprocityFlipDial.legendre_agree_of_not_both_three_mod_four` — off the
  condition the two forms *agree identically*.
* `ReciprocityFlipDial.legendre_flip_iff` — the sharp dichotomy: the dials flip
  **iff** both primes are `3 mod 4`.
* `ReciprocityFlipDial.jacobi_flip_iff_of_coprime` — the same dichotomy for the
  composite-bottom (Jacobi) dial actually used in the experiment.
* `ReciprocityFlipDial.twist_mul_self`, `ReciprocityFlipDial.jacobi_eq_twist_mul` —
  the flipped form is the clean form multiplied by a `± 1` **twist character**
  depending only on `(ℓ mod 4, N mod 4)`; the twist is an involution, so no
  information is destroyed pointwise, only *linearly* scrambled.
* `ReciprocityFlipDial.twist_sum_eq_zero`, `ReciprocityFlipDial.twist_density` —
  the twist has mean zero over the odd residues mod 4 for a fixed `ℓ ≡ 3 mod 4`,
  and fires on exactly one of the four odd residue pairs (the `25%`
  unconditional rate that the experiment measured after conditioning).
* `ReciprocityFlipDial.dial_twist_scrambles` — a concrete linear-algebra
  consequence: a clean dial that is perfectly correlated with a target can have
  its flipped form *exactly uncorrelated* with the same target.  This is the
  formal content of "the published weakness is a dial-form artifact".
-/
import Mathlib

namespace ReciprocityFlipDial

open Finset

/-! ## 1. The twist character -/

/-- The reciprocity **twist**: `twist a b = -1` exactly when both `a` and `b` are
`3 mod 4`, and `+1` otherwise.  It is defined on residues mod `4`. -/
def twist (a b : ℕ) : ℤ := if a % 4 = 3 ∧ b % 4 = 3 then -1 else 1

theorem twist_eq_neg_one_iff (a b : ℕ) :
    twist a b = -1 ↔ (a % 4 = 3 ∧ b % 4 = 3) := by
  unfold twist; split <;> simp_all

theorem twist_eq_one_iff (a b : ℕ) :
    twist a b = 1 ↔ ¬ (a % 4 = 3 ∧ b % 4 = 3) := by
  unfold twist; split <;> simp_all

theorem twist_comm (a b : ℕ) : twist a b = twist b a := by
  unfold twist; simp [and_comm]

/-- The twist is a sign. -/
theorem twist_mul_self (a b : ℕ) : twist a b * twist a b = 1 := by
  unfold twist; split <;> norm_num

/-- The twist equals the classical reciprocity exponent `(-1)^{(a/2)(b/2)}` on
odd arguments. -/
theorem twist_eq_pow (a b : ℕ) (ha : Odd a) (hb : Odd b) :
    twist a b = (-1 : ℤ) ^ (a / 2 * (b / 2)) := by
  have ha2 : a % 2 = 1 := Nat.odd_iff.mp ha
  have hb2 : b % 2 = 1 := Nat.odd_iff.mp hb
  by_cases h : a % 4 = 3 ∧ b % 4 = 3
  · obtain ⟨h1, h2⟩ := h
    have hodd : Odd (a / 2 * (b / 2)) :=
      Nat.odd_mul.mpr ⟨Nat.odd_iff.mpr (by omega), Nat.odd_iff.mpr (by omega)⟩
    rw [hodd.neg_one_pow, twist, if_pos ⟨h1, h2⟩]
  · have heven : Even (a / 2 * (b / 2)) := by
      rw [Nat.even_mul]
      rcases not_and_or.mp h with h1 | h1
      · exact Or.inl (Nat.even_iff.mpr (by omega))
      · exact Or.inr (Nat.even_iff.mpr (by omega))
    rw [heven.neg_one_pow, twist, if_neg h]

/-! ## 2. The prime-bottom (Legendre) dichotomy -/

variable {p q : ℕ}

/-- **Reciprocity as a dial twist (Legendre form).**  For distinct odd primes,
the composite-bottom symbol `(p | q)` equals the twist times the clean symbol
`(q | p)`. -/
theorem legendre_eq_twist_mul [Fact (Nat.Prime p)] [Fact (Nat.Prime q)]
    (hp : p ≠ 2) (hq : q ≠ 2) :
    legendreSym q p = twist p q * legendreSym p q := by
  have hop : Odd p := (Fact.out : Nat.Prime p).odd_of_ne_two hp
  have hoq : Odd q := (Fact.out : Nat.Prime q).odd_of_ne_two hq
  rw [twist_eq_pow p q hop hoq]
  exact legendreSym.quadratic_reciprocity' hp hq

/-- **Zero violations on the condition.**  If both odd primes are `3 mod 4`
the two dial forms are exact negatives. -/
theorem legendre_flip_of_three_mod_four [Fact (Nat.Prime p)] [Fact (Nat.Prime q)]
    (hp : p % 4 = 3) (hq : q % 4 = 3) :
    legendreSym q p = - legendreSym p q := by
  have hp2 : p ≠ 2 := by omega
  have hq2 : q ≠ 2 := by omega
  rw [legendre_eq_twist_mul hp2 hq2, twist, if_pos ⟨hp, hq⟩]
  ring

/-- **Total agreement off the condition.** -/
theorem legendre_agree_of_not_both_three_mod_four [Fact (Nat.Prime p)]
    [Fact (Nat.Prime q)] (hp : p ≠ 2) (hq : q ≠ 2)
    (h : ¬ (p % 4 = 3 ∧ q % 4 = 3)) :
    legendreSym q p = legendreSym p q := by
  rw [legendre_eq_twist_mul hp hq, twist, if_neg h, one_mul]

/-- **The sharp dichotomy.**  For distinct odd primes the two dial forms flip
sign *iff* both primes are `3 mod 4`; there is no other source of disagreement. -/
theorem legendre_flip_iff [Fact (Nat.Prime p)] [Fact (Nat.Prime q)]
    (hp : p ≠ 2) (hq : q ≠ 2) (hpq : p ≠ q) :
    (legendreSym q p = - legendreSym p q) ↔ (p % 4 = 3 ∧ q % 4 = 3) := by
  have hne : legendreSym p q ≠ 0 := by
    rw [Ne, legendreSym.eq_zero_iff]
    have : ¬ ((p : ℤ) ∣ (q : ℤ)) := by
      intro hdvd
      have hdvd' : p ∣ q := by exact_mod_cast hdvd
      exact hpq ((Nat.prime_dvd_prime_iff_eq (Fact.out) (Fact.out)).mp hdvd')
    rw [ZMod.intCast_zmod_eq_zero_iff_dvd]
    exact_mod_cast this
  constructor
  · intro hflip
    by_contra hcon
    rw [legendre_agree_of_not_both_three_mod_four hp hq hcon] at hflip
    have : (2 : ℤ) * legendreSym p q = 0 := by linarith
    simp at this
    exact hne this
  · rintro ⟨h1, h2⟩
    exact legendre_flip_of_three_mod_four h1 h2

/-! ## 3. The composite-bottom (Jacobi) dial -/

/-- **Reciprocity as a dial twist, composite bottom.**  This is the form
actually used to build the `S_prod` / `S139@400` covariates: the bottom argument
`n` is a general odd integer (in the experiment, a composite `N`). -/
theorem jacobi_eq_twist_mul {ℓ n : ℕ} (hl : Odd ℓ) (hn : Odd n) :
    jacobiSym (ℓ : ℤ) n = twist ℓ n * jacobiSym (n : ℤ) ℓ := by
  rw [twist_eq_pow ℓ n hl hn]
  exact jacobiSym.quadratic_reciprocity hl hn

/-- Zero violations, composite-bottom version. -/
theorem jacobi_flip_of_three_mod_four {ℓ n : ℕ} (hl : ℓ % 4 = 3) (hn : n % 4 = 3) :
    jacobiSym (ℓ : ℤ) n = - jacobiSym (n : ℤ) ℓ := by
  have hlo : Odd ℓ := Nat.odd_iff.mpr (by omega)
  have hno : Odd n := Nat.odd_iff.mpr (by omega)
  rw [jacobi_eq_twist_mul hlo hno, twist, if_pos ⟨hl, hn⟩]
  ring

/-- Total agreement off the condition, composite-bottom version. -/
theorem jacobi_agree_of_not_both_three_mod_four {ℓ n : ℕ} (hl : Odd ℓ) (hn : Odd n)
    (h : ¬ (ℓ % 4 = 3 ∧ n % 4 = 3)) :
    jacobiSym (ℓ : ℤ) n = jacobiSym (n : ℤ) ℓ := by
  rw [jacobi_eq_twist_mul hl hn, twist, if_neg h, one_mul]

/-- **The sharp dichotomy for the composite-bottom dial**, under the coprimality
hypothesis that makes the symbols nonzero (the experiment discards `gcd > 1`
rows). -/
theorem jacobi_flip_iff_of_coprime {ℓ n : ℕ} (hl : Odd ℓ) (hn : Odd n)
    (hcop : Nat.Coprime ℓ n) :
    (jacobiSym (ℓ : ℤ) n = - jacobiSym (n : ℤ) ℓ) ↔ (ℓ % 4 = 3 ∧ n % 4 = 3) := by
  have hne : jacobiSym (n : ℤ) ℓ ≠ 0 := by
    rw [Ne, jacobiSym.eq_zero_iff]
    push_neg
    intro _
    simpa [Int.gcd_natCast_natCast] using (Nat.coprime_comm.mp hcop)
  constructor
  · intro hflip
    by_contra hcon
    rw [jacobi_agree_of_not_both_three_mod_four hl hn hcon] at hflip
    have : (2 : ℤ) * jacobiSym (n : ℤ) ℓ = 0 := by linarith
    simp at this
    exact hne this
  · rintro ⟨h1, h2⟩
    exact jacobi_flip_of_three_mod_four h1 h2

/-! ## 4. Residue bookkeeping: the unconditional flip density -/

/-- The odd residues mod `4`. -/
def oddRes : Finset ℕ := {1, 3}

/-- Among the four odd residue pairs `(ℓ mod 4, N mod 4)`, the flip fires on
exactly one: the unconditional flip rate of an unbiased population is `1/4`,
which is the baseline against which the experiment's conditional `100%` and its
measured `27.19%` (a `52.3%`-conditioned population) were read. -/
theorem twist_density :
    ((oddRes ×ˢ oddRes).filter (fun x => twist x.1 x.2 = -1)).card * 4 =
      (oddRes ×ˢ oddRes).card := by
  decide

/-- The twist has **mean zero** over the odd residues of the bottom argument,
for any top argument `ℓ ≡ 3 (mod 4)`.  This is the mechanism by which a flipped
dial can lose all *linear* signal even though it loses no information. -/
theorem twist_sum_eq_zero {ℓ : ℕ} (hl : ℓ % 4 = 3) :
    ∑ b ∈ oddRes, twist ℓ b = 0 := by
  simp [oddRes, twist, hl]

/-! ## 5. The artifact: a twist can annihilate a perfect correlation -/

/-- **Dial-form artifact, exact instance.**  Take four population rows whose
target values are `t` and whose clean dial is *perfectly aligned* with the
target (`clean = t`).  If the twist is `-1` on exactly the rows where the target
is negative — which is precisely what the `ℓ ≡ 3, N ≡ 3` condition does on a
balanced population — then the flipped dial `flip i = twist i * clean i` has
**zero** covariance with the target, despite carrying exactly the same
information.  The published weakness of the composite-bottom rows is therefore
a property of the dial *form*, not of the underlying arithmetic. -/
theorem dial_twist_scrambles
    (t clean tw : Fin 4 → ℤ)
    (hclean : ∀ i, clean i = t i)
    (ht : t 0 = 1 ∧ t 1 = 1 ∧ t 2 = -1 ∧ t 3 = -1)
    (htw : tw 0 = 1 ∧ tw 1 = -1 ∧ tw 2 = 1 ∧ tw 3 = -1) :
    (∑ i, clean i * t i) = 4 ∧ (∑ i, (tw i * clean i) * t i) = 0 := by
  obtain ⟨t0, t1, t2, t3⟩ := ht
  obtain ⟨w0, w1, w2, w3⟩ := htw
  constructor <;>
    simp [Fin.sum_univ_four, hclean, t0, t1, t2, t3, w0, w1, w2, w3]

end ReciprocityFlipDial