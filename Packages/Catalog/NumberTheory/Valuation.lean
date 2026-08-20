/-
# A `q`-analogue of Kummer's theorem

Let `q ≥ 2` and let `ℓ` be a prime not dividing `q`.  Write `d` for the multiplicative order of
`q` modulo `ℓ` and `e = v_ℓ([d]_q)` for the `ℓ`-adic valuation of the `d`-th `q`-integer
(equivalently `v_ℓ(q^d - 1)` when `d > 1`).

This file proves:

* `QKummer.qFact_padicValNat` : `v_ℓ([n]_q!) = e * ⌊n/d⌋ + v_ℓ(⌊n/d⌋ !)`;
* `QKummer.qBinom_padicValNat` : the `q`-Kummer formula
  `v_ℓ(binom(n,k)_q) = e * c + v_ℓ(binom(⌊n/d⌋, ⌊k/d⌋)) + c * v_ℓ(⌊(n-k)/d⌋ + 1)`,
  where `c ∈ {0,1}` is the carry produced when adding `k` and `n-k` in the "base `d`" digit,
  i.e. `c = 1` iff `k % d + (n-k) % d ≥ d`;
* `QKummer.qBinom_padicValNat_carries` : the fully combinatorial form, in which the classical
  binomial term is expanded by Kummer's theorem into a count of base-`ℓ` carries.  Hence
  `v_ℓ(binom(n,k)_q)` is `e` times the base-`d` carry plus the number of carries when adding
  `⌊k/d⌋` and `⌊(n-k)/d⌋` in base `ℓ` (plus the correction `c * v_ℓ(⌊(n-k)/d⌋+1)`).

The engine is the notion `QKummer.IsQRegular q ℓ d e`, which isolates the exact input needed:
the `ℓ`-adic valuation of `[m]_q` vanishes unless `d ∣ m`, in which case it is `e + v_ℓ(m/d)`.
`QKummer.isQRegular_of_odd_prime` establishes this for every odd prime `ℓ ∤ q` by lifting the
exponent, and `Catalog/NumberTheory/QKummer/Examples.lean` shows that the hypothesis `ℓ` odd
cannot be dropped.
-/
import Catalog.NumberTheory.QKummer.Basic

namespace QKummer

open Nat

/-- `IsQRegular q ℓ d e` records that the `ℓ`-adic valuations of the `q`-integers `[m]_q` are
"regular of period `d` with offset `e`": they vanish unless `d ∣ m`, and for `m = d t` they
equal `e + v_ℓ(t)`.  This is the `q`-analogue of the trivial statement `v_ℓ(m) = v_ℓ(m)` that
underlies Legendre's formula, and it is all that the `q`-Kummer theorem needs. -/
structure IsQRegular (q ℓ d e : ℕ) : Prop where
  pos : 0 < d
  val : ∀ m : ℕ, 0 < m →
    padicValNat ℓ (qNat q m) = if d ∣ m then e + padicValNat ℓ (m / d) else 0

section Regular

variable {q ℓ d e : ℕ} [hp : Fact ℓ.Prime]

/-- **`q`-Legendre formula.**  Under regularity, the valuation of the `q`-factorial is
`e * ⌊n/d⌋ + v_ℓ(⌊n/d⌋!)`. -/
theorem qFact_padicValNat (h : IsQRegular q ℓ d e) (n : ℕ) :
    padicValNat ℓ (qFact q n) = e * (n / d) + padicValNat ℓ (n / d).factorial := by
  induction n with
  | zero => simp
  | succ n ih =>
      rw [qFact_succ, padicValNat.mul (qNat_pos q (Nat.succ_pos n)).ne'
        (qFact_pos q n).ne', ih, h.val (n + 1) (Nat.succ_pos n)]
      by_cases hd : d ∣ (n + 1)
      · have hstep : (n + 1) / d = n / d + 1 := by
          rw [Nat.succ_div]
          simp [hd]
        rw [if_pos hd, hstep, Nat.factorial_succ,
          padicValNat.mul (Nat.succ_ne_zero (n / d)) (Nat.factorial_ne_zero (n / d))]
        ring
      · have hstep : (n + 1) / d = n / d := by
          rw [Nat.succ_div]
          simp [hd]
        rw [if_neg hd, hstep, Nat.zero_add]

/-- Valuation form of the exactness `[k]_q! [n-k]_q! binom(n,k)_q = [n]_q!`. -/
theorem qBinom_padicValNat_add (h : IsQRegular q ℓ d e) {n k : ℕ} (hk : k ≤ n) :
    padicValNat ℓ (qBinom q n k)
        + (e * (k / d) + padicValNat ℓ (k / d).factorial)
        + (e * ((n - k) / d) + padicValNat ℓ ((n - k) / d).factorial)
      = e * (n / d) + padicValNat ℓ (n / d).factorial := by
  have hid := qFact_mul_qBinom q n k hk
  have hv : padicValNat ℓ (qFact q k) + padicValNat ℓ (qFact q (n - k))
      + padicValNat ℓ (qBinom q n k) = padicValNat ℓ (qFact q n) := by
    rw [← hid, padicValNat.mul (Nat.mul_pos (qFact_pos q k) (qFact_pos q (n - k))).ne'
        (qBinom_pos hk).ne',
      padicValNat.mul (qFact_pos q k).ne' (qFact_pos q (n - k)).ne']
  rw [qFact_padicValNat h k, qFact_padicValNat h (n - k), qFact_padicValNat h n] at hv
  omega

end Regular

/-- The base-`d` carry: `⌊(a+b)/d⌋ = ⌊a/d⌋ + ⌊b/d⌋ + c` with `c = 1` exactly when the residues
of `a` and `b` mod `d` sum to at least `d`. -/
theorem div_add_div_add_carry {d : ℕ} (hd : 0 < d) (a b : ℕ) :
    (a + b) / d = a / d + b / d + (if d ≤ a % d + b % d then 1 else 0) :=
  Nat.add_div hd

section Main

variable {q ℓ d e : ℕ} [hp : Fact ℓ.Prime]

/-- Splitting the classical factorial valuation according to a carry `c ≤ 1`. -/
theorem padicValNat_factorial_split {A B c : ℕ} (hc : c ≤ 1) :
    padicValNat ℓ (A + B + c).factorial
      = padicValNat ℓ ((A + B + c).choose A) + padicValNat ℓ A.factorial
        + padicValNat ℓ B.factorial + c * padicValNat ℓ (B + 1) := by
  have hAle : A ≤ A + B + c := by omega
  have hkey := Nat.choose_mul_factorial_mul_factorial hAle
  have hsub : A + B + c - A = B + c := by omega
  rw [hsub] at hkey
  interval_cases c
  · have hA0 : A ≤ A + B := Nat.le_add_right A B
    simp only [Nat.add_zero, Nat.zero_mul] at hkey ⊢
    rw [← hkey,
      padicValNat.mul (Nat.mul_ne_zero (Nat.choose_pos hA0).ne' (Nat.factorial_ne_zero A))
        (Nat.factorial_ne_zero B),
      padicValNat.mul (Nat.choose_pos hA0).ne' (Nat.factorial_ne_zero A)]
  · rw [Nat.factorial_succ] at hkey
    rw [← hkey,
      padicValNat.mul (Nat.mul_ne_zero (Nat.choose_pos hAle).ne' (Nat.factorial_ne_zero A))
        (Nat.mul_ne_zero (Nat.succ_ne_zero B) (Nat.factorial_ne_zero B)),
      padicValNat.mul (Nat.choose_pos hAle).ne' (Nat.factorial_ne_zero A),
      padicValNat.mul (Nat.succ_ne_zero B) (Nat.factorial_ne_zero B)]
    ring

/-- **The `q`-analogue of Kummer's theorem, carry form.**

If the base-`d` addition of `k` and `n-k` produces the carry `c ≤ 1`, i.e.
`⌊n/d⌋ = ⌊k/d⌋ + ⌊(n-k)/d⌋ + c`, then

`v_ℓ(binom(n,k)_q) = e * c + v_ℓ(binom(⌊n/d⌋, ⌊k/d⌋)) + c * v_ℓ(⌊(n-k)/d⌋ + 1)`. -/
theorem qBinom_padicValNat_of_carry (h : IsQRegular q ℓ d e) {n k c : ℕ} (hk : k ≤ n)
    (hc1 : c ≤ 1) (hN : n / d = k / d + (n - k) / d + c) :
    padicValNat ℓ (qBinom q n k)
      = e * c + padicValNat ℓ ((n / d).choose (k / d))
        + c * padicValNat ℓ ((n - k) / d + 1) := by
  have hfact : padicValNat ℓ (n / d).factorial
      = padicValNat ℓ ((n / d).choose (k / d)) + padicValNat ℓ (k / d).factorial
        + padicValNat ℓ ((n - k) / d).factorial + c * padicValNat ℓ ((n - k) / d + 1) := by
    rw [hN]
    exact padicValNat_factorial_split hc1
  have hmain := qBinom_padicValNat_add h hk
  rw [hfact] at hmain
  have hexp : e * (n / d) = e * (k / d) + e * ((n - k) / d) + e * c := by rw [hN]; ring
  rw [hexp] at hmain
  omega

/-- **The `q`-analogue of Kummer's theorem.**

For a regular datum `(d, e)` — e.g. `d` the multiplicative order of `q` mod `ℓ` and
`e = v_ℓ([d]_q)`, see `isQRegular_of_odd_prime` — the `ℓ`-adic valuation of the Gaussian
binomial coefficient is

`v_ℓ(binom(n,k)_q) = e * c + v_ℓ(binom(⌊n/d⌋, ⌊k/d⌋)) + c * v_ℓ(⌊(n-k)/d⌋ + 1)`,

where `c ∈ {0,1}` is the carry out of the base-`d` digit when adding `k` and `n-k`. -/
theorem qBinom_padicValNat (h : IsQRegular q ℓ d e) {n k : ℕ} (hk : k ≤ n) :
    padicValNat ℓ (qBinom q n k)
      = e * (if d ≤ k % d + (n - k) % d then 1 else 0)
        + padicValNat ℓ ((n / d).choose (k / d))
        + (if d ≤ k % d + (n - k) % d then 1 else 0) * padicValNat ℓ ((n - k) / d + 1) := by
  refine qBinom_padicValNat_of_carry h hk (by split <;> simp) ?_
  have hn : k + (n - k) = n := by omega
  conv_lhs => rw [← hn]
  exact div_add_div_add_carry h.pos k (n - k)

end Main

section OddPrime

variable {q ℓ : ℕ} [hp : Fact ℓ.Prime]

/-- The order of `q` in `ZMod ℓ` detects divisibility of `q^m - 1` by `ℓ`. -/
theorem orderOf_dvd_iff_dvd_pow_sub_one (hq : 2 ≤ q) (m : ℕ) :
    orderOf (q : ZMod ℓ) ∣ m ↔ ℓ ∣ q ^ m - 1 := by
  rw [orderOf_dvd_iff_pow_eq_one]
  have h1 : ((q : ZMod ℓ)) ^ m = ((q ^ m : ℕ) : ZMod ℓ) := by push_cast; ring
  have h2 : ((1 : ℕ) : ZMod ℓ) = (1 : ZMod ℓ) := by push_cast; ring
  rw [h1, ← h2, ZMod.natCast_eq_natCast_iff]
  have hpow : 1 ≤ q ^ m := Nat.one_le_pow _ _ (by omega)
  constructor
  · intro h
    exact (Nat.modEq_iff_dvd' hpow).mp h.symm
  · intro h
    exact ((Nat.modEq_iff_dvd' hpow).mpr h).symm

/-- Valuation of `q^s - 1` in terms of the `q`-integer `[s]_q`. -/
theorem padicValNat_pow_sub_one (hq : 2 ≤ q) {s : ℕ} (hs : 0 < s) :
    padicValNat ℓ (q ^ s - 1) = padicValNat ℓ (q - 1) + padicValNat ℓ (qNat q s) := by
  rw [← sub_one_mul_qNat (by omega : 1 ≤ q) s,
    padicValNat.mul (by omega) (qNat_pos q hs).ne']

/-- **Regularity of `q`-integer valuations at an odd prime.**

For an odd prime `ℓ ∤ q` with `q ≥ 2`, the `ℓ`-adic valuations of the `q`-integers are
regular with period `d = ord_ℓ(q)` and offset `e = v_ℓ([d]_q)`.  The proof is lifting the
exponent applied to `x = q^d`. -/
theorem isQRegular_of_odd_prime (hodd : Odd ℓ) (hq : 2 ≤ q) (hnd : ¬ ℓ ∣ q) :
    IsQRegular q ℓ (orderOf (q : ZMod ℓ)) (padicValNat ℓ (qNat q (orderOf (q : ZMod ℓ)))) := by
  set d := orderOf (q : ZMod ℓ) with hd
  have hq0 : (q : ZMod ℓ) ≠ 0 := by
    rw [Ne, ZMod.natCast_eq_zero_iff]
    exact hnd
  have hdpos : 0 < d := by
    rw [hd, orderOf_pos_iff]
    exact isOfFinOrder_iff_pow_eq_one.mpr
      ⟨ℓ - 1, by have := hp.out.two_le; omega, ZMod.pow_card_sub_one_eq_one hq0⟩
  have hdvd : ∀ m, d ∣ m ↔ ℓ ∣ q ^ m - 1 := orderOf_dvd_iff_dvd_pow_sub_one hq
  refine ⟨hdpos, ?_⟩
  intro m hm
  by_cases hdm : d ∣ m
  · obtain ⟨t, rfl⟩ := hdm
    have ht : t ≠ 0 := by rintro rfl; simp at hm
    have hx1 : 1 < q ^ d := Nat.one_lt_pow hdpos.ne' (by omega)
    have hxdvd : ℓ ∣ q ^ d - 1 := (hdvd d).mp dvd_rfl
    have hxnd : ¬ ℓ ∣ q ^ d := fun h => hnd (hp.out.dvd_of_dvd_pow h)
    have key := padicValNat.pow_sub_pow (p := ℓ) hodd (y := 1) hx1 (by simpa using hxdvd) hxnd ht
    rw [one_pow, ← pow_mul] at key
    rw [padicValNat_pow_sub_one hq (Nat.mul_pos hdpos (Nat.pos_of_ne_zero ht)),
      padicValNat_pow_sub_one hq hdpos] at key
    rw [if_pos ⟨t, rfl⟩, Nat.mul_div_cancel_left t hdpos]
    omega
  · rw [if_neg hdm]
    refine padicValNat.eq_zero_of_not_dvd fun hcon => hdm ?_
    rw [hdvd m, ← sub_one_mul_qNat (by omega : 1 ≤ q) m]
    exact Dvd.dvd.mul_left hcon _

/-- **The `q`-analogue of Kummer's theorem for an odd prime `ℓ ∤ q`.**

With `d = ord_ℓ(q)` the multiplicative order of `q` modulo `ℓ` and `e = v_ℓ([d]_q)`, the
`ℓ`-adic valuation of the Gaussian binomial coefficient `binom(n,k)_q` equals
`e * c + v_ℓ(binom(⌊n/d⌋,⌊k/d⌋)) + c * v_ℓ(⌊(n-k)/d⌋+1)`, where `c ∈ {0,1}` is the carry out
of the base-`d` digit when `k` and `n-k` are added. -/
theorem qBinom_padicValNat_orderOf (hodd : Odd ℓ) (hq : 2 ≤ q) (hnd : ¬ ℓ ∣ q) {n k : ℕ}
    (hk : k ≤ n) :
    padicValNat ℓ (qBinom q n k)
      = padicValNat ℓ (qNat q (orderOf (q : ZMod ℓ)))
          * (if orderOf (q : ZMod ℓ) ≤ k % orderOf (q : ZMod ℓ)
                + (n - k) % orderOf (q : ZMod ℓ) then 1 else 0)
        + padicValNat ℓ ((n / orderOf (q : ZMod ℓ)).choose (k / orderOf (q : ZMod ℓ)))
        + (if orderOf (q : ZMod ℓ) ≤ k % orderOf (q : ZMod ℓ)
              + (n - k) % orderOf (q : ZMod ℓ) then 1 else 0)
            * padicValNat ℓ ((n - k) / orderOf (q : ZMod ℓ) + 1) :=
  qBinom_padicValNat (isQRegular_of_odd_prime hodd hq hnd) hk

/-- **Fully combinatorial form.**  Combining the `q`-Kummer formula with the classical Kummer
theorem, the term `v_ℓ(binom(⌊n/d⌋,⌊k/d⌋))` is the number of carries when `⌊k/d⌋` and
`⌊n/d⌋ - ⌊k/d⌋` are added in base `ℓ`. -/
theorem qBinom_padicValNat_carries {d e : ℕ} (h : IsQRegular q ℓ d e) {n k c b : ℕ}
    (hk : k ≤ n) (hc1 : c ≤ 1) (hN : n / d = k / d + (n - k) / d + c)
    (hb : Nat.log ℓ (n / d) < b) :
    padicValNat ℓ (qBinom q n k)
      = e * c
        + ((Finset.Ico 1 b).filter
              (fun i => ℓ ^ i ≤ (k / d) % ℓ ^ i + (n / d - k / d) % ℓ ^ i)).card
        + c * padicValNat ℓ ((n - k) / d + 1) := by
  have hkle : k / d ≤ n / d := by
    rw [hN]
    exact le_trans (Nat.le_add_right _ _) (Nat.le_add_right _ _)
  rw [qBinom_padicValNat_of_carry h hk hc1 hN, padicValNat_choose hkle hb]

end OddPrime

end QKummer