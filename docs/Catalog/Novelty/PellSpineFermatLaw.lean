/-
# A Fermat law for the Pell spine

`Novelty.PellSpineDivisibility.not_prime_dvd_pellP_pred` and
`Novelty.PellSpineApparition.not_pellRank_dvd_sub_one` refuted the naive guess
`p ∣ P (p-1)`.  This file proves the **correct** law, and thereby explains the
counterexample `p = 3`:

> for every odd prime `p`,  `p ∣ P (p-1) · P (p+1)`,
> equivalently `pellRank p ∣ p - 1` **or** `pellRank p ∣ p + 1`.

## Method — Frobenius inside `ℤ[√2]`, with no characteristic-`p` ring

Work in `Zsqrtd 2 = ℤ[√2]`.  The silver unit is `u = 1 + √2` and `uⁿ = ⟨Q n, P n⟩`
(`silver_zsqrtd_pow`).  Mathlib's `exists_add_pow_prime_eq` gives, in *any* commutative
semiring, `(x+y)^p = x^p + y^p + p·x·y·r`.  Applied to `x = 1`, `y = √2` and combined with
`(√2)^(2m+1) = 2^m √2` (`sqrtd_pow_odd`), the `√2`-component reads

`P p = 2^((p-1)/2) + p · (something)`,

i.e. `P p ≡ 2^((p-1)/2) (mod p)`: **Euler's criterion appears on the spine**
(`pellP_prime_congr`).  Squaring and using Fermat's little theorem gives `P p² ≡ 1`
(`pellP_prime_sq_congr`), and the factorisation `P (p-1) · P (p+1) = Q p² - P p² = P p² - 1`
(from the Pell equation at the odd index `p`) closes the argument.

## Results

* `silver_zsqrtd_pow`, `sqrtd_pow_odd` — the spine inside `ℤ[√2]`;
* `pellP_prime_congr` — `P p ≡ 2^((p-1)/2) (mod p)`;
* `pellP_prime_sq_congr` — `P p² ≡ 1 (mod p)`;
* `pell_fermat_law` — `p ∣ P (p-1) · P (p+1)`;
* `pell_fermat_law_or` — `p ∣ P (p-1) ∨ p ∣ P (p+1)`;
* `pellRank_dvd_sub_or_add` — `pellRank p ∣ p-1 ∨ pellRank p ∣ p+1`, the repaired form of the
  refuted conjecture.  For `p = 3` the second alternative is the true one (`pellRank 3 = 4`).
-/
import Novelty.PellSpineApparition

namespace Catalog.Novelty.PellSpine

/-! ## The spine inside `ℤ[√2]` -/

/-- The silver unit `1 + √2` inside `ℤ[√2]` generates the spine:
`(1 + √2)ⁿ = ⟨Q n, P n⟩`. -/
theorem silver_zsqrtd_pow (n : ℕ) :
    ((1 : Zsqrtd 2) + Zsqrtd.sqrtd) ^ n = ⟨(pellQ n : ℤ), (pellP n : ℤ)⟩ := by
  induction n with
  | zero => rfl
  | succ n ih =>
      rw [pow_succ, ih]
      refine Zsqrtd.ext ?_ ?_
      · have h : pellQ (n + 1) = pellQ n + 2 * pellP n := pellQ_succ n
        simp [Zsqrtd.re_mul, h]
      · have h : pellP (n + 1) = pellP n + pellQ n := pellP_succ n
        simp [Zsqrtd.im_mul, h]
        ring

/-- Odd powers of `√2`: `(√2)^(2m+1) = 2^m √2`. -/
theorem sqrtd_pow_odd (m : ℕ) :
    (Zsqrtd.sqrtd : Zsqrtd 2) ^ (2 * m + 1) = ⟨0, 2 ^ m⟩ := by
  induction m with
  | zero => refine Zsqrtd.ext ?_ ?_ <;> simp
  | succ m ih =>
      have hidx : 2 * (m + 1) + 1 = (2 * m + 1) + 2 := by ring
      rw [hidx, pow_add, ih]
      refine Zsqrtd.ext ?_ ?_ <;> simp [Zsqrtd.re_mul, Zsqrtd.im_mul, pow_succ]

/-! ## Euler's criterion on the spine -/

/-- **Frobenius on the spine.**  For an odd prime `p = 2m+1`,
`P p ≡ 2^m` and `Q p ≡ 1` modulo `p`.  The first congruence *is* Euler's criterion for `2`. -/
theorem pell_frobenius {p : ℕ} (hp : Nat.Prime p) {m : ℕ} (hm : p = 2 * m + 1) :
    ((pellP p : ℕ) : ZMod p) = (2 : ZMod p) ^ m ∧ ((pellQ p : ℕ) : ZMod p) = 1 := by
  subst hm
  obtain ⟨r, hr⟩ := exists_add_pow_prime_eq hp (1 : Zsqrtd 2) Zsqrtd.sqrtd
  rw [silver_zsqrtd_pow (2 * m + 1), one_pow, sqrtd_pow_odd m] at hr
  have hp0 : (2 * (m : ZMod (2 * m + 1)) + 1) = 0 := by
    have h1 : ((2 * m + 1 : ℕ) : ZMod (2 * m + 1)) = 0 := ZMod.natCast_self _
    push_cast at h1
    exact h1
  constructor
  · have him := congrArg Zsqrtd.im hr
    simp [Zsqrtd.im_mul, Zsqrtd.re_mul] at him
    have hz := congrArg (fun z : ℤ => (z : ZMod (2 * m + 1))) him
    push_cast at hz
    rw [hz, hp0]
    ring
  · have hre := congrArg Zsqrtd.re hr
    simp [Zsqrtd.im_mul, Zsqrtd.re_mul] at hre
    have hz := congrArg (fun z : ℤ => (z : ZMod (2 * m + 1))) hre
    push_cast at hz
    rw [hz, hp0]
    ring

/-- **`P p ≡ 2^((p-1)/2) (mod p)`** for odd primes `p`: the Legendre symbol of `2` shows up
as the `p`-th Pell number. -/
theorem pellP_prime_congr {p : ℕ} (hp : Nat.Prime p) {m : ℕ} (hm : p = 2 * m + 1) :
    ((pellP p : ℕ) : ZMod p) = (2 : ZMod p) ^ m := (pell_frobenius hp hm).1

/-- The companion sequence satisfies `Q p ≡ 1 (mod p)`. -/
theorem pellQ_prime_congr {p : ℕ} (hp : Nat.Prime p) {m : ℕ} (hm : p = 2 * m + 1) :
    ((pellQ p : ℕ) : ZMod p) = 1 := (pell_frobenius hp hm).2

/-- Squaring Euler's criterion and applying Fermat's little theorem: `P p ² ≡ 1 (mod p)`. -/
theorem pellP_prime_sq_congr {p : ℕ} (hp : Nat.Prime p) (hodd : p ≠ 2) :
    (((pellP p : ℕ) : ZMod p)) ^ 2 = 1 := by
  haveI : Fact (Nat.Prime p) := ⟨hp⟩
  obtain ⟨m, hm⟩ : ∃ m, p = 2 * m + 1 := by
    rcases hp.eq_two_or_odd' with h | h
    · exact absurd h hodd
    · obtain ⟨k, hk⟩ := h; exact ⟨k, by omega⟩
  rw [pellP_prime_congr hp hm, ← pow_mul]
  have h2 : (2 : ZMod p) ≠ 0 := by
    intro h
    have hdvd : p ∣ 2 := (ZMod.natCast_eq_zero_iff (2 : ℕ) p).mp (by exact_mod_cast h)
    exact hodd ((Nat.prime_dvd_prime_iff_eq hp Nat.prime_two).mp hdvd)
  have : m * 2 = p - 1 := by omega
  rw [this]
  exact ZMod.pow_card_sub_one_eq_one h2

/-! ## The Fermat law -/

/-- **The Fermat law of the Pell spine**: every odd prime divides `P (p-1) · P (p+1)`.
The naive `p ∣ P (p-1)` (refuted at `p = 3`) is only the `(2/p) = 1` half of this. -/
theorem pell_fermat_law {p : ℕ} (hp : Nat.Prime p) (hodd : p ≠ 2) :
    p ∣ pellP (p - 1) * pellP (p + 1) := by
  haveI : Fact (Nat.Prime p) := ⟨hp⟩
  have hppos : 0 < p := hp.pos
  obtain ⟨n, hn⟩ : ∃ n, p = n + 1 := ⟨p - 1, by omega⟩
  have hp1 : p - 1 = n := by omega
  -- `Q p = P p + P (p-1)` and `P (p+1) = P p + Q p`
  have hQ : pellQ p = pellP p + pellP n := by rw [hn]; exact pellQ_succ_eq_add n
  have hP1 : pellP (p + 1) = pellP p + pellQ p := pellP_succ p
  -- the Pell equation at the odd index `p`
  have hpe : ((pellQ p : ℤ)) ^ 2 - 2 * ((pellP p : ℤ)) ^ 2 = -1 := by
    have h := pell_equation p
    have : ((-1 : ℤ)) ^ p = -1 := by
      rcases hp.eq_two_or_odd' with h2 | h2
      · exact absurd h2 hodd
      · exact Odd.neg_one_pow h2
    rw [this] at h
    exact h
  -- everything modulo `p`
  have hgoal : (((pellP (p - 1) * pellP (p + 1) : ℕ)) : ZMod p) = 0 := by
    have hsq := pellP_prime_sq_congr hp hodd
    have hQz : ((pellQ p : ℕ) : ZMod p) = ((pellP p : ℕ) : ZMod p) + ((pellP n : ℕ) : ZMod p) := by
      exact_mod_cast congrArg (fun k : ℕ => (k : ZMod p)) hQ
    have hP1z : ((pellP (p + 1) : ℕ) : ZMod p)
        = ((pellP p : ℕ) : ZMod p) + ((pellQ p : ℕ) : ZMod p) := by
      exact_mod_cast congrArg (fun k : ℕ => (k : ZMod p)) hP1
    have hpez : ((pellQ p : ℕ) : ZMod p) ^ 2 - 2 * ((pellP p : ℕ) : ZMod p) ^ 2 = -1 := by
      have : (((pellQ p : ℤ)) ^ 2 - 2 * ((pellP p : ℤ)) ^ 2 : ℤ) = -1 := hpe
      have := congrArg (fun z : ℤ => (z : ZMod p)) this
      push_cast at this
      exact this
    push_cast [hp1, hP1z, hQz]
    -- `P n = Q p - P p` and `P (p+1) = P p + Q p`, so the product is `Q p ² - P p ² = P p ² - 1`
    have hPn : ((pellP n : ℕ) : ZMod p)
        = ((pellQ p : ℕ) : ZMod p) - ((pellP p : ℕ) : ZMod p) := by
      rw [hQz]; ring
    rw [hPn]
    push_cast at hsq ⊢
    linear_combination hpez + hsq
  exact (ZMod.natCast_eq_zero_iff _ _).mp hgoal

/-- Sharpened: an odd prime divides `P (p-1)` or `P (p+1)`. -/
theorem pell_fermat_law_or {p : ℕ} (hp : Nat.Prime p) (hodd : p ≠ 2) :
    p ∣ pellP (p - 1) ∨ p ∣ pellP (p + 1) :=
  (Nat.Prime.dvd_mul hp).mp (pell_fermat_law hp hodd)

/-- **Repaired form of the refuted conjecture**: the rank of apparition of an odd prime
divides `p - 1` or `p + 1`.  At `p = 3` the second alternative holds (`pellRank 3 = 4`),
which is exactly why `Novelty.PellSpineApparition.not_pellRank_dvd_sub_one` succeeds. -/
theorem pellRank_dvd_sub_or_add {p : ℕ} (hp : Nat.Prime p) (hodd : p ≠ 2) :
    pellRank p ∣ (p - 1) ∨ pellRank p ∣ (p + 1) := by
  have hppos : 0 < p := hp.pos
  rcases pell_fermat_law_or hp hodd with h | h
  · exact Or.inl ((dvd_pellP_iff_pellRank_dvd hppos _).mp h)
  · exact Or.inr ((dvd_pellP_iff_pellRank_dvd hppos _).mp h)

/-! ## The Legendre refinement: which alternative holds -/

/-- **Exact Fermat law.**  For an odd prime `p`, `p ∣ P (p-1)` happens **iff** `2` is a
quadratic residue mod `p`, i.e. iff `p ≡ ±1 (mod 8)`.  This is the sharp form of
`pell_fermat_law`, and it explains every counterexample above: `3 % 8 = 3`. -/
theorem dvd_pellP_pred_iff {p : ℕ} (hp : Nat.Prime p) (hodd : p ≠ 2) :
    p ∣ pellP (p - 1) ↔ p % 8 = 1 ∨ p % 8 = 7 := by
  haveI : Fact (Nat.Prime p) := ⟨hp⟩
  obtain ⟨m, hm⟩ : ∃ m, p = 2 * m + 1 := by
    rcases hp.eq_two_or_odd' with h | h
    · exact absurd h hodd
    · obtain ⟨k, hk⟩ := h; exact ⟨k, by omega⟩
  have hppos : 0 < p := hp.pos
  obtain ⟨n, hn⟩ : ∃ n, p = n + 1 := ⟨p - 1, by omega⟩
  have hp1 : p - 1 = n := by omega
  have hQ : pellQ p = pellP p + pellP n := by rw [hn]; exact pellQ_succ_eq_add n
  have h2ne : (2 : ZMod p) ≠ 0 := by
    intro h
    have hdvd : p ∣ 2 := (ZMod.natCast_eq_zero_iff (2 : ℕ) p).mp (by exact_mod_cast h)
    exact hodd ((Nat.prime_dvd_prime_iff_eq hp Nat.prime_two).mp hdvd)
  have hhalf : p / 2 = m := by omega
  -- `P (p-1) ≡ Q p - P p ≡ 1 - 2^m`
  have hPn : ((pellP n : ℕ) : ZMod p) = 1 - (2 : ZMod p) ^ m := by
    have hQz : ((pellQ p : ℕ) : ZMod p)
        = ((pellP p : ℕ) : ZMod p) + ((pellP n : ℕ) : ZMod p) := by
      exact_mod_cast congrArg (fun k : ℕ => (k : ZMod p)) hQ
    rw [pellQ_prime_congr hp hm, pellP_prime_congr hp hm] at hQz
    linear_combination -hQz
  calc p ∣ pellP (p - 1) ↔ ((pellP n : ℕ) : ZMod p) = 0 := by
        rw [hp1]
        exact (ZMod.natCast_eq_zero_iff _ _).symm
    _ ↔ (2 : ZMod p) ^ (p / 2) = 1 := by
        rw [hPn, hhalf]
        constructor
        · intro h; linear_combination -h
        · intro h; linear_combination -h
    _ ↔ IsSquare (2 : ZMod p) := (ZMod.euler_criterion p h2ne).symm
    _ ↔ p % 8 = 1 ∨ p % 8 = 7 := ZMod.exists_sq_eq_two_iff hodd

/-- **Exact rank law.**  `pellRank p ∣ p - 1` iff `p ≡ ±1 (mod 8)`; otherwise the rank
divides `p + 1`.  This closes the loop with the refutation
`Novelty.PellSpineApparition.not_pellRank_dvd_sub_one`, whose witness `p = 3` has `3 % 8 = 3`. -/
theorem pellRank_dvd_sub_one_iff {p : ℕ} (hp : Nat.Prime p) (hodd : p ≠ 2) :
    pellRank p ∣ (p - 1) ↔ p % 8 = 1 ∨ p % 8 = 7 := by
  rw [← dvd_pellP_iff_pellRank_dvd hp.pos]
  exact dvd_pellP_pred_iff hp hodd

/-- The alternative is genuinely two-sided: at `p = 3` only `pellRank 3 ∣ 3 + 1` holds. -/
theorem pellRank_three_dvd_add : pellRank 3 ∣ (3 + 1) ∧ ¬ pellRank 3 ∣ (3 - 1) := by
  rw [pellRank_three]
  exact ⟨by norm_num, by norm_num⟩

end Catalog.Novelty.PellSpine