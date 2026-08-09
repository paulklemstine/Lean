/-
# A smoothness hierarchy: the more often a number occurs, the smoother it must be

`Catalog.Novelty.SingmasterSmoothness` proves that a number occurring three or more
times in Pascal's triangle has all its prime factors below roughly `√(2t)`.  That is the
first level of an infinite hierarchy, which this file establishes:

> if `N(t) ≥ 2m + 2` then every prime factor `p` of `t` satisfies `C(p, m+1) ≤ t`,
> i.e. `p ≲ m + ((m+1)!·t)^{1/(m+1)}`.

So a number occurring six times is essentially `t^{1/3}`-smooth, a number occurring
eight times is essentially `t^{1/4}`-smooth, and so on: Singmaster's phenomenon of
"very repetitive" numbers can only happen at *extremely* smooth integers.  For
`t = 3003 = 3·7·11·13`, which occurs eight times, the bound at `m = 3` reads
`C(13,4) = 715 ≤ 3003`, and it already forbids any prime factor `≥ 18`
(`C(18,4) = 3060 > 3003`).

## Mechanism

Two independent ingredients meet:

* *counting the occurrences* (`exists_big_column_of_mult`): by the reflection
  decomposition `N(t) = 2 + 2·#leftInt(t) + #centerOcc(t)`, a multiplicity of at least
  `2m+2` produces at least `m` left interior occurrences; column uniqueness makes their
  columns pairwise distinct and `≥ 2`, so *some* occurrence sits in a column `≥ m+1`;
* *arithmetic of binomial coefficients* (`Catalog.Novelty.SingmasterSmooth.prime_le_row_of_dvd_choose`):
  every prime factor `p` of `C(n,k)` is at most `n`, and `C(p,m+1) ≤ C(n,m+1) ≤ C(n,k)`
  by monotonicity in the row and unimodality along the row.

## Results

* `exists_big_column_of_mult` — a multiplicity `≥ 2m+2` forces an occurrence in column
  `≥ m+1`;
* `choose_prime_le_of_mult` — **the hierarchy**: `C(p, m+1) ≤ t` for every prime `p ∣ t`;
* `pow_sub_le_of_mult` — the quantitative form `(p - m)^{m+1} ≤ (m+1)!·t`;
* `descFactorial_three_le_of_six_le_mult` — the case `m = 2`: numbers occurring at least
  six times satisfy `p(p-1)(p-2) ≤ 6t` for all prime factors `p`;
* `prime_factor_lt_eighteen_of_3003` — the hierarchy applied to `3003`.
-/
import Mathlib
import Combinatorics.SingmasterOccurrences
import Combinatorics.SingmasterParity
import Combinatorics.SingmasterMaxBelowMillion
import Combinatorics.SingmasterCentralBinomialExtended
import Combinatorics.SingmasterExactCounts
import Novelty.SingmasterSmoothness

open Finset

namespace Catalog.Novelty.SmoothHierarchy

open Singmaster Catalog.Novelty.SingmasterSmooth

/-! ## Counting occurrences: a high multiplicity needs a deep column -/

/-- The column of a left interior occurrence determines the occurrence. -/
theorem leftInt_col_injective {t : ℕ} (ht : 2 ≤ t) :
    Set.InjOn Prod.snd (leftInt t : Set (ℕ × ℕ)) := by
  rintro ⟨n, k⟩ h1 ⟨n', k'⟩ h2 (hkk : k = k')
  simp only [Finset.mem_coe, mem_leftInt ht] at h1 h2
  obtain ⟨⟨hkn, hck⟩, hlt, hk2⟩ := h1
  obtain ⟨⟨hkn', hck'⟩, hlt', hk2'⟩ := h2
  subst hkk
  have : n = n' := row_unique (by omega) hkn hkn' (by rw [hck, hck'])
  simp [this]

/-- **A multiplicity of at least `2m+2` forces an occurrence in a column `≥ m+1`.** -/
theorem exists_big_column_of_mult {t m : ℕ} (ht : 3 ≤ t) (hm : 1 ≤ m)
    (hmul : 2 * m + 2 ≤ mult t) :
    ∃ n k : ℕ, k ≤ n ∧ n.choose k = t ∧ 2 * k < n ∧ m + 1 ≤ k := by
  classical
  have ht2 : 2 ≤ t := by omega
  have hdec := mult_eq_two_add_two_mul_leftInt ht
  have hcen := centerOcc_card_le_one ht2
  have hcard : m ≤ (leftInt t).card := by omega
  -- the columns are distinct, so they cannot all be `≤ m`
  set S := (leftInt t).image Prod.snd with hS
  have hScard : (leftInt t).card = S.card :=
    (Finset.card_image_of_injOn (leftInt_col_injective ht2)).symm
  have hex : ∃ k ∈ S, m + 1 ≤ k := by
    by_contra hcon
    push_neg at hcon
    have hsub : S ⊆ Finset.Icc 2 m := by
      intro k hk
      rw [Finset.mem_Icc]
      refine ⟨?_, by have := hcon k hk; omega⟩
      rw [hS, mem_image] at hk
      obtain ⟨⟨n, j⟩, hmem, rfl⟩ := hk
      rw [mem_leftInt ht2] at hmem
      exact hmem.2.2
    have := Finset.card_le_card hsub
    rw [Nat.card_Icc] at this
    omega
  obtain ⟨k, hkS, hkm⟩ := hex
  rw [hS, mem_image] at hkS
  obtain ⟨⟨n, j⟩, hmem, rfl⟩ := hkS
  rw [mem_leftInt ht2] at hmem
  exact ⟨n, j, hmem.1.1, hmem.1.2, hmem.2.1, hkm⟩

/-! ## The hierarchy -/

/-- **Smoothness hierarchy.**  If `t` occurs at least `2m+2` times in Pascal's triangle
then every prime factor `p` of `t` satisfies `C(p, m+1) ≤ t`. -/
theorem choose_prime_le_of_mult {t p m : ℕ} (ht : 3 ≤ t) (hm : 1 ≤ m)
    (hmul : 2 * m + 2 ≤ mult t) (hp : p.Prime) (hpt : p ∣ t) : p.choose (m + 1) ≤ t := by
  obtain ⟨n, k, hkn, hck, hlt, hkm⟩ := exists_big_column_of_mult ht hm hmul
  have hpn : p ≤ n := prime_le_row_of_dvd_choose hp hkn (hck ▸ hpt)
  calc p.choose (m + 1) ≤ n.choose (m + 1) := Nat.choose_mono _ hpn
    _ ≤ n.choose k := choose_le_choose_of_le_fold hkn (by omega)
    _ = t := hck

/-- Quantitative form of the hierarchy: `(p - m)^{m+1} ≤ (m+1)! · t`, so the prime
factors of a number of multiplicity `≥ 2m+2` are at most `m + ((m+1)!·t)^{1/(m+1)}`. -/
theorem pow_sub_le_of_mult {t p m : ℕ} (ht : 3 ≤ t) (hm : 1 ≤ m)
    (hmul : 2 * m + 2 ≤ mult t) (hp : p.Prime) (hpt : p ∣ t) :
    (p - m) ^ (m + 1) ≤ Nat.factorial (m + 1) * t := by
  have h1 : (p + 1 - (m + 1)) ^ (m + 1) ≤ p.descFactorial (m + 1) :=
    Nat.pow_sub_le_descFactorial p (m + 1)
  have h2 : p.descFactorial (m + 1) = Nat.factorial (m + 1) * p.choose (m + 1) :=
    Nat.descFactorial_eq_factorial_mul_choose p (m + 1)
  have h3 : p.choose (m + 1) ≤ t := choose_prime_le_of_mult ht hm hmul hp hpt
  have h4 : p + 1 - (m + 1) = p - m := by omega
  rw [h4] at h1
  calc (p - m) ^ (m + 1) ≤ p.descFactorial (m + 1) := h1
    _ = Nat.factorial (m + 1) * p.choose (m + 1) := h2
    _ ≤ Nat.factorial (m + 1) * t := Nat.mul_le_mul_left _ h3

/-- The case `m = 2`: a number occurring at least six times has `p(p-1)(p-2) ≤ 6t` for
each of its prime factors — it is essentially `t^{1/3}`-smooth. -/
theorem descFactorial_three_le_of_six_le_mult {t p : ℕ} (ht : 3 ≤ t) (hmul : 6 ≤ mult t)
    (hp : p.Prime) (hpt : p ∣ t) : p.descFactorial 3 ≤ 6 * t := by
  have h3 : p.choose 3 ≤ t := choose_prime_le_of_mult ht (m := 2) (by omega) (by omega) hp hpt
  have h2 : p.descFactorial 3 = Nat.factorial 3 * p.choose 3 :=
    Nat.descFactorial_eq_factorial_mul_choose p 3
  have hfac : Nat.factorial 3 = 6 := by decide
  rw [h2, hfac]
  exact Nat.mul_le_mul_left _ h3

/-- The hierarchy in action: since `N(3003) = 8 = 2·3 + 2`, every prime factor `p` of
`3003` satisfies `C(p,4) ≤ 3003`, and therefore `p ≤ 17`.  (In fact `3003 = 3·7·11·13`.)
-/
theorem prime_factor_le_seventeen_of_3003 {p : ℕ} (hp : p.Prime) (hpt : p ∣ 3003) :
    p ≤ 17 := by
  have hkey : p.choose 4 ≤ 3003 :=
    choose_prime_le_of_mult (t := 3003) (m := 3) (by norm_num) (by omega)
      (by rw [mult_3003]) hp hpt
  by_contra hcon
  push_neg at hcon
  have h18 : (18 : ℕ).choose 4 ≤ p.choose 4 := Nat.choose_mono 4 (by omega)
  have : (18 : ℕ).choose 4 = 3060 := by decide
  omega

end Catalog.Novelty.SmoothHierarchy