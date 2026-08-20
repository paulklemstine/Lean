/-
# Cyclic quotients of `ℤⁿ`: the Solomon coefficients are Jordan totients

This file settles Conjecture **C2** of `FUTURE_DIRECTIONS.md`.  For every modulus `m ≥ 1` and
every rank `n`, the `Aut`-weighted Solomon coefficient of the free lattice `ℤⁿ` at the cyclic
quotient type `ℤ/m` is the Jordan totient

  `φ(m) · #{N ≤ ℤⁿ : ℤⁿ/N ≅ ℤ/m}  =  J_n(m)  =  Σ_{d ∣ m} μ(d) · (m/d)ⁿ`.

The incidence-algebra Möbius function of the submodule poset of `ℤ/m` is thereby *carried onto*
the classical arithmetic Möbius function: the number-theoretic `μ` is the output, not an input.

The proof combines three ingredients that were already verified in this development:

* the prime-power case `φ(pᵉ)·#{…} = (pᵉ)ⁿ - (p^{e-1})ⁿ` (`totient_mul_quotIsoCount_zmod_prime_pow`);
* multiplicativity across coprime quotient types (`quotIsoCount_prod_of_coprime`), transported
  along the Chinese remainder isomorphism `ℤ/(ab) ≅ ℤ/a × ℤ/b` by `quotIsoCount_congr_right`;
* Mathlib's theory of multiplicative arithmetic functions: two multiplicative functions that
  agree on prime powers are equal.

Main results:
* `SolomonZeta.solomonCyclicCoeff` — the arithmetic function `m ↦ φ(m)·#{N : ℤⁿ/N ≅ ℤ/m}`;
* `SolomonZeta.isMultiplicative_solomonCyclicCoeff` — it is multiplicative;
* `SolomonZeta.solomonCyclicCoeff_eq_moebius_mul_pow` — it equals the Dirichlet convolution
  `μ * Idⁿ`;
* `SolomonZeta.totient_mul_quotIsoCount_zmod_eq_jordan` — the explicit divisor-sum formula.
-/
import Catalog.Shared.SolomonZeta.CyclicPPower
import Catalog.Shared.SolomonZeta.Invariance
import Catalog.Shared.SolomonZeta.Multiplicativity

namespace SolomonZeta

open Finset ArithmeticFunction

/-! ### The cyclic Solomon coefficient as an arithmetic function -/

/-- Multiplication by `m` annihilates `ℤ/m`. -/
theorem zmod_annihilated (m : ℕ) (x : ZMod m) : (m : ℤ) • x = 0 := by
  simp [zsmul_eq_mul]

/-- The trivial module has a unique presentation as a quotient of `ℤⁿ`. -/
theorem quotIsoCount_zmod_one (n : ℕ) : quotIsoCount ℤ (Fin n → ℤ) (ZMod 1) = 1 := by
  have h := homEqCount_top_eq_autCard_mul_quotIsoCount (R := ℤ) (M := Fin n → ℤ) (X := ZMod 1)
  rw [autCard_zmod 1] at h
  simp only [Nat.totient_one, one_mul] at h
  rw [← h, homEqCount_top_free_eq_card_spanning]
  have : Unique {v : Fin n → ZMod 1 // Submodule.span ℤ (Set.range v) = ⊤} :=
    ⟨⟨fun _ => 0, Subsingleton.elim _ _⟩, fun v => Subsingleton.elim _ _⟩
  simp

/-- **Multiplicativity in the modulus.**  For coprime `a, b` the weighted cyclic Solomon
coefficients multiply; this is the Chinese remainder decomposition of the quotient type. -/
theorem totient_mul_quotIsoCount_zmod_mul (n a b : ℕ) (ha : a ≠ 0) (hb : b ≠ 0)
    (hab : Nat.Coprime a b) :
    (((a * b).totient : ℤ)) * (quotIsoCount ℤ (Fin n → ℤ) (ZMod (a * b)) : ℤ)
      = ((a.totient : ℤ) * (quotIsoCount ℤ (Fin n → ℤ) (ZMod a) : ℤ))
        * ((b.totient : ℤ) * (quotIsoCount ℤ (Fin n → ℤ) (ZMod b) : ℤ)) := by
  haveI : NeZero a := ⟨ha⟩
  haveI : NeZero b := ⟨hb⟩
  haveI : NeZero (a * b) := ⟨by positivity⟩
  have e : ZMod (a * b) ≃ₗ[ℤ] (ZMod a × ZMod b) :=
    AddEquiv.toIntLinearEquiv (ZMod.chineseRemainder hab).toAddEquiv
  rw [← autCard_zmod a, ← autCard_zmod b, ← autCard_zmod (a * b),
    autCard_congr e, quotIsoCount_congr_right (M := Fin n → ℤ) e]
  exact quotIsoCount_prod_of_coprime a b hab (zmod_annihilated a) (zmod_annihilated b)

/-- The arithmetic function `m ↦ φ(m) · #{N ≤ ℤⁿ : ℤⁿ/N ≅ ℤ/m}`: the cyclic part of the
Solomon zeta function of the free lattice of rank `n`. -/
noncomputable def solomonCyclicCoeff (n : ℕ) : ArithmeticFunction ℤ :=
  ⟨fun m => (m.totient : ℤ) * (quotIsoCount ℤ (Fin n → ℤ) (ZMod m) : ℤ), by simp⟩

@[simp] theorem solomonCyclicCoeff_apply (n m : ℕ) :
    solomonCyclicCoeff n m = (m.totient : ℤ) * (quotIsoCount ℤ (Fin n → ℤ) (ZMod m) : ℤ) := rfl

theorem isMultiplicative_solomonCyclicCoeff (n : ℕ) :
    (solomonCyclicCoeff n).IsMultiplicative := by
  refine ArithmeticFunction.IsMultiplicative.iff_ne_zero.2 ⟨?_, ?_⟩
  · simp [quotIsoCount_zmod_one n]
  · intro a b ha hb hab
    simpa using totient_mul_quotIsoCount_zmod_mul n a b ha hb hab

/-! ### The Dirichlet convolution `μ * Idⁿ` -/

/-- Value of the convolution `μ * Idⁿ` at a prime power. -/
theorem moebius_mul_pow_prime_pow (n p i : ℕ) (hp : p.Prime) (hi : i ≠ 0) :
    ((moebius * (↑(ArithmeticFunction.pow n) : ArithmeticFunction ℤ)) (p ^ i))
      = ((p : ℤ) ^ i) ^ n - ((p : ℤ) ^ (i - 1)) ^ n := by
  rw [ArithmeticFunction.mul_apply, Nat.sum_divisorsAntidiagonal
    (fun x y => (moebius x : ℤ) * ((↑(ArithmeticFunction.pow n) : ArithmeticFunction ℤ) y)),
    Nat.sum_divisors_prime_pow hp]
  have hp0 : p ≠ 0 := hp.pos.ne'
  have hzero : ∀ j ∈ Finset.range (i + 1), j ∉ ({0, 1} : Finset ℕ) →
      (moebius (p ^ j) : ℤ) *
        ((↑(ArithmeticFunction.pow n) : ArithmeticFunction ℤ) (p ^ i / p ^ j)) = 0 := by
    intro j _ hj2
    simp only [Finset.mem_insert, Finset.mem_singleton, not_or] at hj2
    rw [ArithmeticFunction.moebius_apply_prime_pow hp hj2.1]
    simp [hj2.2]
  rw [← Finset.sum_subset (s₁ := ({0, 1} : Finset ℕ)) ?_ hzero]
  · rw [Finset.sum_insert (by simp)]
    simp only [Finset.sum_singleton, pow_zero, pow_one]
    rw [ArithmeticFunction.moebius_apply_one, ArithmeticFunction.moebius_apply_prime hp]
    have h2 : p ^ i / p = p ^ (i - 1) := by
      conv_lhs => rw [show i = (i - 1) + 1 by omega]
      rw [pow_succ, Nat.mul_div_cancel _ hp.pos]
    rw [Nat.div_one, h2]
    simp only [ArithmeticFunction.natCoe_apply, ArithmeticFunction.pow_apply]
    rw [if_neg (fun h => absurd h.2 (pow_ne_zero _ hp0)),
      if_neg (fun h => absurd h.2 (pow_ne_zero _ hp0))]
    push_cast
    ring
  · intro x hx
    simp only [Finset.mem_insert, Finset.mem_singleton] at hx
    simp only [Finset.mem_range]
    omega

/-- **Solomon coefficients of cyclic quotients = Jordan totients.**  As arithmetic functions,
`m ↦ φ(m)·#{N ≤ ℤⁿ : ℤⁿ/N ≅ ℤ/m}` is the Dirichlet convolution `μ * Idⁿ`. -/
theorem solomonCyclicCoeff_eq_moebius_mul_pow (n : ℕ) :
    solomonCyclicCoeff n = moebius * (↑(ArithmeticFunction.pow n) : ArithmeticFunction ℤ) := by
  refine (ArithmeticFunction.IsMultiplicative.eq_iff_eq_on_prime_powers _
    (isMultiplicative_solomonCyclicCoeff n) _
    (ArithmeticFunction.isMultiplicative_moebius.mul
      ArithmeticFunction.isMultiplicative_pow.natCast)).2 ?_
  intro p i hp
  rcases Nat.eq_zero_or_pos i with rfl | hi
  · simp [(isMultiplicative_solomonCyclicCoeff n).1,
      (ArithmeticFunction.isMultiplicative_moebius.mul
        ArithmeticFunction.isMultiplicative_pow.natCast).1]
  haveI : Fact p.Prime := ⟨hp⟩
  rw [moebius_mul_pow_prime_pow n p i hp hi.ne']
  have hkey := totient_mul_quotIsoCount_zmod_prime_pow p i n hi
  have hle : (p ^ (i - 1)) ^ n ≤ (p ^ i) ^ n :=
    Nat.pow_le_pow_left (Nat.pow_le_pow_right hp.pos (by omega)) n
  have hcast : ((Nat.totient (p ^ i) * quotIsoCount ℤ (Fin n → ℤ) (ZMod (p ^ i)) : ℕ) : ℤ)
      = (((p ^ i) ^ n - (p ^ (i - 1)) ^ n : ℕ) : ℤ) := by rw [hkey]
  rw [solomonCyclicCoeff_apply]
  push_cast [Nat.cast_sub hle] at hcast ⊢
  linarith

/-- **Explicit Jordan totient formula.**  For `m ≥ 1` and every rank `n`,

  `φ(m) · #{N ≤ ℤⁿ : ℤⁿ/N ≅ ℤ/m} = Σ_{d ∣ m} μ(d) · (m/d)ⁿ`. -/
theorem totient_mul_quotIsoCount_zmod_eq_jordan (m n : ℕ) (hm : m ≠ 0) :
    (m.totient : ℤ) * (quotIsoCount ℤ (Fin n → ℤ) (ZMod m) : ℤ)
      = ∑ d ∈ m.divisors, (moebius d : ℤ) * ((m / d : ℕ) : ℤ) ^ n := by
  have h := congrArg (fun f : ArithmeticFunction ℤ => f m) (solomonCyclicCoeff_eq_moebius_mul_pow n)
  simp only [solomonCyclicCoeff_apply] at h
  rw [h, ArithmeticFunction.mul_apply, Nat.sum_divisorsAntidiagonal
    (fun x y => (moebius x : ℤ) * ((↑(ArithmeticFunction.pow n) : ArithmeticFunction ℤ) y))]
  refine Finset.sum_congr rfl fun d hd => ?_
  have hdvd : d ∣ m := (Nat.mem_divisors.1 hd).1
  have hne : m / d ≠ 0 := Nat.div_ne_zero_iff.2 ⟨Nat.pos_of_mem_divisors hd |>.ne', Nat.le_of_dvd
    (Nat.pos_of_ne_zero hm) hdvd⟩
  simp only [ArithmeticFunction.natCoe_apply, ArithmeticFunction.pow_apply]
  rw [if_neg (fun h => hne h.2)]
  push_cast
  ring

/-! ### Consistency checks -/

/-- Rank one: `ζ_ℤ(s) = ζ(s)`, i.e. `φ(m) = Σ_{d ∣ m} μ(d)·(m/d)`, recovered from the
Solomon coefficient of `ℤ` (whose value is `1` for every modulus). -/
theorem totient_eq_jordan_one (m : ℕ) (hm : 0 < m) :
    (m.totient : ℤ) = ∑ d ∈ m.divisors, (moebius d : ℤ) * ((m / d : ℕ) : ℤ) := by
  haveI : NeZero m := ⟨hm.ne'⟩
  have h := totient_mul_quotIsoCount_zmod_eq_jordan m 1 hm.ne'
  have hweight : mobiusWeight ℤ (Fin 1 → ℤ) (ZMod m) = mobiusWeight ℤ ℤ (ZMod m) :=
    mobiusWeight_congr_left (X := ZMod m) (LinearEquiv.funUnique (Fin 1) ℤ ℤ)
  rw [← autCard_mul_quotIsoCount_eq_mobiusWeight, ← autCard_mul_quotIsoCount_eq_mobiusWeight,
    autCard_zmod m, quotIsoCount_int_zmod m hm] at hweight
  rw [hweight] at h
  simpa using h

/-- Rank two, modulus six: there are exactly `12` sublattices of `ℤ²` with quotient `ℤ/6`,
in agreement with `σ(6) = 12` (every index six sublattice of `ℤ²` has cyclic quotient). -/
theorem quotIsoCount_rank_two_six : quotIsoCount ℤ (Fin 2 → ℤ) (ZMod 6) = 12 := by
  have h2 : moebius 2 = -1 := ArithmeticFunction.moebius_apply_prime Nat.prime_two
  have h3 : moebius 3 = -1 := ArithmeticFunction.moebius_apply_prime Nat.prime_three
  have h6 : moebius 6 = 1 := by
    rw [show (6 : ℕ) = 2 * 3 from rfl,
      ArithmeticFunction.isMultiplicative_moebius.map_mul_of_coprime (by norm_num), h2, h3]
    norm_num
  have h := totient_mul_quotIsoCount_zmod_eq_jordan 6 2 (by norm_num)
  norm_num [show Nat.divisors 6 = {1, 2, 3, 6} from rfl, ArithmeticFunction.moebius_apply_one,
    h2, h3, h6, show Nat.totient 6 = 2 from rfl] at h
  omega

end SolomonZeta