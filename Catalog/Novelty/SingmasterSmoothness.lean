/-
# Numbers with a large prime factor occur exactly twice in Pascal's triangle

This file extends the Singmaster development of `Combinatorics.SingmasterOccurrences`,
`Combinatorics.SingmasterParity` and `Combinatorics.SingmasterMaxBelowMillion` with a
*multiplicative* criterion for multiplicity two.  The catalog already knows that
`N(p) = 2` for every odd prime `p` (`Singmaster.mult_odd_prime`); that statement is a
single point of a whole half-plane of numbers whose multiplicity is forced.

## The mechanism (an arithmetic-geometric cross-cut)

Two facts about a nontrivial occurrence `C(n,k) = t` with `2 ≤ k ≤ n - 2` are combined:

* *geometry of the triangle*: the entry is at least the second entry of its row, so
  `n(n-1) ≤ 2t` (`Catalog.Novelty.SingmasterSmooth.row_mul_pred_le_of_interior`);
* *arithmetic of the entry*: every prime factor of a binomial coefficient `C(n,k)` is at
  most `n`, since `C(n,k) ∣ n!`
  (`Catalog.Novelty.SingmasterSmooth.prime_le_row_of_dvd_choose`).

Together: any prime factor `p` of a number `t` admitting a nontrivial occurrence obeys
`p(p-1) ≤ n(n-1) ≤ 2t`.  Hence a number possessing a prime factor larger than roughly
`√(2t)` has *no* nontrivial occurrence at all, so `N(t) = 2` exactly.

## Results

* `prime_le_row_of_dvd_choose` — prime factors of `C(n,k)` are at most `n`;
* `row_mul_pred_le_of_interior` — a nontrivial occurrence caps its own row;
* `mult_eq_two_of_large_prime_factor` — **`N(t) = 2` whenever `t ≥ 3` has a prime factor
  `p` with `2t < p(p-1)`**;
* `prime_factor_bound_of_three_le_mult` — the contrapositive *smoothness theorem*: if
  `N(t) ≥ 3` then *every* prime factor `p` of `t` satisfies `p(p-1) ≤ 2t`, hence
  `p ≤ √(2t) + 1`;
* `mult_eq_two_of_prime_mul` — `N(c·p) = 2` for every `c ≥ 1` and every prime
  `p > 2c + 1`; this contains `Singmaster.mult_odd_prime` as the case `c = 1`;
* `infinite_mult_eq_two_dvd` — for every `c ≥ 1` there are infinitely many multiples of
  `c` of multiplicity exactly two, so the multiplicity-two numbers meet every
  divisibility class.
-/
import Mathlib
import Combinatorics.SingmasterOccurrences
import Combinatorics.SingmasterParity
import Combinatorics.SingmasterMaxBelowMillion

open Finset

namespace Catalog.Novelty.SingmasterSmooth

open Singmaster

/-! ## Arithmetic input: prime factors of a binomial coefficient are small -/

/-- **Every prime factor of `C(n,k)` is at most `n`.**  Indeed `C(n,k)` divides `n!`, and
a prime dividing `n!` is at most `n`. -/
theorem prime_le_row_of_dvd_choose {n k p : ℕ} (hp : p.Prime) (hk : k ≤ n)
    (h : p ∣ n.choose k) : p ≤ n := by
  have key : n.choose k * Nat.factorial k * Nat.factorial (n - k) = Nat.factorial n :=
    Nat.choose_mul_factorial_mul_factorial hk
  have hfac : p ∣ Nat.factorial n := by
    rw [← key]
    exact ((h.mul_right (Nat.factorial k)).mul_right _)
  exact (Nat.Prime.dvd_factorial hp).1 hfac

/-! ## Geometric input: a nontrivial occurrence caps its row -/

/-- `2 * C(n,2) = n(n-1)`, in a form free of natural-number division. -/
theorem two_mul_choose_two (n : ℕ) : 2 * n.choose 2 = n * (n - 1) := by
  cases n with
  | zero => simp
  | succ m =>
    rw [Nat.choose_two_right]
    simp only [Nat.add_sub_cancel]
    have heven : 2 ∣ (m + 1) * m := by
      rcases Nat.even_or_odd m with he | ho
      · obtain ⟨r, rfl⟩ := he; exact ⟨(r + r + 1) * r, by ring⟩
      · obtain ⟨r, rfl⟩ := ho; exact ⟨(r + 1) * (2 * r + 1), by ring⟩
    omega

/-- **A nontrivial occurrence caps its own row.**  If `C(n,k) = t` with `2 ≤ k ≤ n - 2`
then `n(n-1) ≤ 2t`: the row index is at most about `√(2t)`. -/
theorem row_mul_pred_le_of_interior {n k t : ℕ} (hk : 2 ≤ k) (hk2 : k + 2 ≤ n)
    (h : n.choose k = t) : n * (n - 1) ≤ 2 * t := by
  have hle : n.choose 2 ≤ t := by rw [← h]; exact choose_two_le_choose hk hk2
  have := two_mul_choose_two n
  omega

/-- The combination of the two inputs: any prime factor of a number admitting a
nontrivial occurrence is at most about `√(2t)`. -/
theorem prime_mul_pred_le_of_interior {n k t p : ℕ} (hp : p.Prime) (hpt : p ∣ t)
    (hk : 2 ≤ k) (hk2 : k + 2 ≤ n) (h : n.choose k = t) : p * (p - 1) ≤ 2 * t := by
  have hpn : p ≤ n := prime_le_row_of_dvd_choose hp (by omega) (h ▸ hpt)
  have hmono : p * (p - 1) ≤ n * (n - 1) :=
    Nat.mul_le_mul hpn (Nat.sub_le_sub_right hpn 1)
  exact hmono.trans (row_mul_pred_le_of_interior hk hk2 h)

/-! ## The multiplicity criterion -/

/-- **Main theorem.**  If `t ≥ 3` has a prime factor `p` with `2t < p(p-1)` then `t`
occurs exactly twice in Pascal's triangle, namely as `C(t,1)` and `C(t,t-1)`. -/
theorem mult_eq_two_of_large_prime_factor {t p : ℕ} (ht : 3 ≤ t) (hp : p.Prime)
    (hpt : p ∣ t) (hbig : 2 * t < p * (p - 1)) : mult t = 2 := by
  have ht2 : 2 ≤ t := by omega
  have hleft : leftInt t = ∅ := by
    rw [Finset.eq_empty_iff_forall_notMem]
    rintro ⟨n, k⟩ hmem
    rw [mem_leftInt ht2] at hmem
    obtain ⟨⟨hkn, hck⟩, hlt, hk2⟩ := hmem
    have := prime_mul_pred_le_of_interior hp hpt hk2 (by omega) hck
    omega
  have hcenter : centerOcc t = ∅ := by
    rw [Finset.eq_empty_iff_forall_notMem]
    rintro ⟨n, k⟩ hmem
    rw [mem_centerOcc, mem_occ_iff ht2] at hmem
    obtain ⟨⟨hkn, hck⟩, hn⟩ := hmem
    have hk2 : 2 ≤ k := by
      by_contra hcon
      interval_cases k
      · simp at hck; omega
      · subst hn; norm_num at hck; omega
    have := prime_mul_pred_le_of_interior hp hpt hk2 (by omega) hck
    omega
  rw [mult_eq_two_add_two_mul_leftInt ht, hleft, hcenter]
  simp

/-- **Smoothness theorem** (contrapositive form).  A number occurring at least three
times in Pascal's triangle has no large prime factor: every prime factor `p` of `t`
satisfies `p(p-1) ≤ 2t`. -/
theorem prime_factor_bound_of_three_le_mult {t p : ℕ} (ht : 3 ≤ t) (hmul : 3 ≤ mult t)
    (hp : p.Prime) (hpt : p ∣ t) : p * (p - 1) ≤ 2 * t := by
  by_contra hcon
  rw [mult_eq_two_of_large_prime_factor ht hp hpt (by omega)] at hmul
  omega

/-- Quantitative form of the smoothness theorem: if `N(t) ≥ 3` then every prime factor
of `t` is at most `√(2t) + 1`. -/
theorem prime_factor_le_sqrt_of_three_le_mult {t p : ℕ} (ht : 3 ≤ t) (hmul : 3 ≤ mult t)
    (hp : p.Prime) (hpt : p ∣ t) : p ≤ Nat.sqrt (2 * t) + 1 := by
  have hkey := prime_factor_bound_of_three_le_mult ht hmul hp hpt
  by_contra hcon
  push_neg at hcon
  have h1 : Nat.sqrt (2 * t) + 1 ≤ p - 1 := by omega
  have h2 : (Nat.sqrt (2 * t) + 1) * (Nat.sqrt (2 * t) + 1) ≤ p * (p - 1) :=
    Nat.mul_le_mul (by omega) h1
  have h3 : 2 * t < (Nat.sqrt (2 * t) + 1) * (Nat.sqrt (2 * t) + 1) := by
    have := Nat.lt_succ_sqrt' (2 * t)
    simpa [pow_two, Nat.succ_eq_add_one] using this
  omega

/-! ## Families of numbers of multiplicity exactly two -/

/-- For every `c ≥ 1` and every prime `p > 2c + 1`, the number `c · p` occurs exactly
twice.  Taking `c = 1` recovers `Singmaster.mult_odd_prime` for `p ≥ 5`. -/
theorem mult_eq_two_of_prime_mul {c p : ℕ} (hc : 1 ≤ c) (hp : p.Prime)
    (hbig : 2 * c + 1 < p) : mult (c * p) = 2 := by
  have hp2 : 2 ≤ p := hp.two_le
  refine mult_eq_two_of_large_prime_factor ?_ hp ⟨c, by ring⟩ ?_
  · calc 3 ≤ 1 * 4 := by norm_num
      _ ≤ c * p := Nat.mul_le_mul hc (by omega)
  · have : 2 * c * p < (p - 1) * p := Nat.mul_lt_mul_of_lt_of_le (by omega) (le_refl p)
      (by omega)
    calc 2 * (c * p) = 2 * c * p := by ring
      _ < (p - 1) * p := this
      _ = p * (p - 1) := by ring

/-- Every prime `p ≥ 5` occurs exactly twice — the `c = 1` case, re-derived from the
general criterion. -/
theorem mult_eq_two_of_five_le_prime {p : ℕ} (hp : p.Prime) (h5 : 5 ≤ p) : mult p = 2 := by
  have := mult_eq_two_of_prime_mul (c := 1) (p := p) le_rfl hp (by omega)
  simpa using this

/-- `N(2p) = 2` for every prime `p ≥ 7`: the doubled primes are of multiplicity two,
even though `2 · 3 = 6` and `2 · 5 = 10` are not (`N(6) = 3`, `N(10) = 4`). -/
theorem mult_two_mul_prime {p : ℕ} (hp : p.Prime) (h7 : 7 ≤ p) : mult (2 * p) = 2 :=
  mult_eq_two_of_prime_mul (by norm_num) hp (by omega)

/-- **Multiplicity two is unavoidable in every divisibility class.**  For each `c ≥ 1`
there are infinitely many multiples of `c` occurring exactly twice. -/
theorem infinite_mult_eq_two_dvd {c : ℕ} (hc : 1 ≤ c) :
    {t : ℕ | mult t = 2 ∧ c ∣ t}.Infinite := by
  apply Set.infinite_of_not_bddAbove
  rintro ⟨M, hM⟩
  obtain ⟨p, hpge, hp⟩ := Nat.exists_infinite_primes (max (2 * c + 2) (M + 1))
  have hple : c * p ≤ M := hM ⟨mult_eq_two_of_prime_mul hc hp (by
      have := le_trans (le_max_left (2 * c + 2) (M + 1)) hpge; omega), ⟨p, rfl⟩⟩
  have hpM : M + 1 ≤ p := le_trans (le_max_right (2 * c + 2) (M + 1)) hpge
  have : p ≤ c * p := Nat.le_mul_of_pos_left p (by omega)
  omega

end Catalog.Novelty.SingmasterSmooth