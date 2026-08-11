/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The Collatz parity-vector bijection on `ℤ/2^k`

This file proves the *exact* 2-adic structure theorem underlying every spectral
statement about the Collatz map: the map sending a residue `n mod 2^k` to the
binary word recording the parities of the first `k` iterates of the accelerated
Collatz map is a **bijection** of `ℤ/2^k` onto itself.

## Why this is the right object

The companion file `MachineLearning.CollatzSpectralGap` shows that the naive
exponential sum `∑_{n ≤ N} e(ω · T(n)/n)` admits **no** spectral gap: being a
continuous function of `ω` equal to `N` at `ω = 0`, its modulus comes arbitrarily
close to `N` at irrational frequencies. The obstruction is that the frequency
variable is *archimedean*. Replacing the archimedean frequency by a **2-adic**
one — i.e. Fourier analysis on the finite group `ℤ/2^k` applied to the parity
word — turns the failure into a theorem with *perfect* cancellation
(see `MachineLearning.CollatzSpectral.ParitySpectrum`).

## Main results

* `terras` — the exact affine transport formula
  `T^[k] (n + 2^k m) = T^[k] n + 3^{s_k(n)} m`, together with invariance of the
  first `k` parity bits under `n ↦ n + 2^k m`.
* `pbit_flip` — adding `2^k` flips exactly the `k`-th parity bit.
* `parityWord_injective_mod` — the parity word determines the residue mod `2^k`.
* `parityWord_bijOn` / `parityWord_surjective` — every one of the `2^k` binary
  words of length `k` is realised by exactly one residue class mod `2^k`.
* `exists_all_odd_prefix`, `exists_all_even_prefix` — the two extreme words are
  realised, so at every scale there are maximally expanding and maximally
  contracting residue classes.
-/

import Mathlib

open Finset

namespace CollatzParity

/-! ## §1. The accelerated Collatz map and its parity word -/

/-- The **accelerated Collatz map** `T n = n/2` for even `n` and `(3n+1)/2` for
odd `n`. It is the standard Collatz map with the forced even step after an odd
step already performed. -/
def T (n : ℕ) : ℕ := if n % 2 = 0 then n / 2 else (3 * n + 1) / 2

/-- The unaccelerated Collatz map, for comparison. -/
def collatz (n : ℕ) : ℕ := if n % 2 = 0 then n / 2 else 3 * n + 1

/-- `T` is one step of the accelerated map: on odd inputs it is two Collatz
steps, on even inputs it is one. This pins down the relationship with the
classical `3n+1` map. -/
theorem T_eq_collatz : ∀ n : ℕ,
    T n = if n % 2 = 0 then collatz n else collatz (collatz n) := by
  intro n
  unfold T collatz
  by_cases h : n % 2 = 0
  · simp [h]
  · have h1 : n % 2 = 1 := by omega
    have h2 : (3 * n + 1) % 2 = 0 := by omega
    simp [h, h2]

/-- The `j`-th parity bit of the orbit of `n` under the accelerated map. -/
def pbit (n j : ℕ) : ℕ := (T^[j] n) % 2

/-- The **parity word** of length `k`: the first `k` parity bits of the orbit of
`n`, packed little-endian into a natural number `< 2^k`. -/
def parityWord (k n : ℕ) : ℕ := ∑ j ∈ Finset.range k, pbit n j * 2 ^ j

/-- The number of odd steps among the first `k` steps of the orbit of `n`. -/
def onesCount (k n : ℕ) : ℕ := ∑ j ∈ Finset.range k, pbit n j

lemma pbit_le_one (n j : ℕ) : pbit n j ≤ 1 := by unfold pbit; omega

lemma pbit_eq_zero_or_one (n j : ℕ) : pbit n j = 0 ∨ pbit n j = 1 := by
  unfold pbit; omega

lemma onesCount_succ (k n : ℕ) : onesCount (k + 1) n = onesCount k n + pbit n k := by
  unfold onesCount; rw [Finset.sum_range_succ]

lemma parityWord_succ (k n : ℕ) :
    parityWord (k + 1) n = parityWord k n + pbit n k * 2 ^ k := by
  unfold parityWord; rw [Finset.sum_range_succ]

lemma onesCount_le (k n : ℕ) : onesCount k n ≤ k := by
  unfold onesCount
  calc ∑ j ∈ Finset.range k, pbit n j ≤ ∑ _j ∈ Finset.range k, 1 :=
        Finset.sum_le_sum (fun j _ => pbit_le_one n j)
    _ = k := by simp

/-! ## §2. The exact transport formula -/

/-- One accelerated step under an even perturbation. -/
lemma T_add_two_mul (x m : ℕ) :
    T (x + 2 * m) = if x % 2 = 0 then T x + m else T x + 3 * m := by
  unfold T
  rcases Nat.even_or_odd x with h | h
  · have hx : x % 2 = 0 := Nat.even_iff.mp h
    simp [hx, Nat.add_mul_mod_self_left]
    omega
  · have hx : x % 2 = 1 := Nat.odd_iff.mp h
    have hx2 : (x + 2 * m) % 2 = 1 := by omega
    simp [hx, hx2]
    omega

/-- **Terras' transport formula.** Shifting `n` by a multiple of `2^k` leaves the
first `k` parity bits untouched and translates the `k`-th iterate by exactly
`3^{s} m`, where `s = onesCount k n` is the number of odd steps taken.

This single statement is the arithmetic heart of the whole file: it says the
`k`-step accelerated Collatz map is an *affine* map on each residue class
mod `2^k`, with slope `3^s / 2^k` — a genuinely multiplicative datum. -/
theorem terras (k : ℕ) : ∀ n m : ℕ,
    T^[k] (n + 2 ^ k * m) = T^[k] n + 3 ^ onesCount k n * m ∧
      ∀ j < k, pbit (n + 2 ^ k * m) j = pbit n j := by
  induction k with
  | zero => intro n m; simp [onesCount]
  | succ k ih =>
    intro n m
    have h2 : n + 2 ^ (k + 1) * m = n + 2 ^ k * (2 * m) := by ring
    obtain ⟨h1, hb⟩ := ih n (2 * m)
    rw [h2]
    have heven : 3 ^ onesCount k n * (2 * m) = 2 * (3 ^ onesCount k n * m) := by ring
    have hbits : ∀ j < k + 1, pbit (n + 2 ^ k * (2 * m)) j = pbit n j := by
      intro j hj
      rcases Nat.lt_succ_iff_lt_or_eq.mp hj with hj' | rfl
      · exact hb j hj'
      · unfold pbit; rw [h1, heven]; omega
    refine ⟨?_, hbits⟩
    rw [Function.iterate_succ_apply', Function.iterate_succ_apply', h1, heven,
      T_add_two_mul]
    by_cases hp : T^[k] n % 2 = 0
    · simp [hp, onesCount_succ, pbit]
    · have hp1 : T^[k] n % 2 = 1 := by omega
      rw [if_neg hp, onesCount_succ, show pbit n k = 1 from hp1]
      ring

/-- The first `k` parity bits are a function of `n mod 2^k`. -/
theorem pbit_period (k n m j : ℕ) (hj : j < k) : pbit (n + 2 ^ k * m) j = pbit n j :=
  (terras k n m).2 j hj

/-- The parity word of length `k` only depends on `n mod 2^k`. -/
theorem parityWord_period (k n m : ℕ) : parityWord k (n + 2 ^ k * m) = parityWord k n :=
  Finset.sum_congr rfl fun j hj => by
    rw [pbit_period k n m j (Finset.mem_range.mp hj)]

/-- The ones-count of length `k` only depends on `n mod 2^k`. -/
theorem onesCount_period (k n m : ℕ) : onesCount k (n + 2 ^ k * m) = onesCount k n :=
  Finset.sum_congr rfl fun j hj => pbit_period k n m j (Finset.mem_range.mp hj)

/-- **Bit-flip lemma.** Adding `2^k` flips the `k`-th parity bit, because
`3^s` is odd. This is the injectivity engine. -/
theorem pbit_flip (k n : ℕ) : pbit (n + 2 ^ k) k ≠ pbit n k := by
  have h := (terras k n 1).1
  simp only [mul_one] at h
  unfold pbit
  rw [h]
  have hodd : Odd (3 ^ onesCount k n) := Odd.pow (by decide)
  rw [Nat.odd_iff] at hodd
  omega

/-! ## §3. The bijection -/

/-- Parity words of length `k` are exactly the naturals `< 2^k`. -/
theorem parityWord_lt (k n : ℕ) : parityWord k n < 2 ^ k := by
  induction k with
  | zero => simp [parityWord]
  | succ k ih =>
    rw [parityWord_succ]
    have h0 := pbit_le_one n k
    have h1 : pbit n k * 2 ^ k ≤ 2 ^ k := by
      nlinarith [pow_pos (by norm_num : (0:ℕ) < 2) k]
    have h2 : (2 : ℕ) ^ (k + 1) = 2 ^ k + 2 ^ k := by ring
    omega

/-- **Injectivity (Terras).** The length-`k` parity word determines the residue
of `n` modulo `2^k`. -/
theorem parityWord_injective_mod (k : ℕ) : ∀ n n' : ℕ,
    parityWord k n = parityWord k n' → n % 2 ^ k = n' % 2 ^ k := by
  induction k with
  | zero => intro n n' _; omega
  | succ k ih =>
    have main : ∀ n n' : ℕ, n ≤ n' → parityWord (k + 1) n = parityWord (k + 1) n' →
        n % 2 ^ (k + 1) = n' % 2 ^ (k + 1) := by
      intro n n' hle h
      rw [parityWord_succ, parityWord_succ] at h
      have h1 := parityWord_lt k n
      have h2 := parityWord_lt k n'
      have hb1 := pbit_le_one n k
      have hb2 := pbit_le_one n' k
      have hw : parityWord k n = parityWord k n' ∧ pbit n k = pbit n' k := by
        rcases Nat.le_one_iff_eq_zero_or_eq_one.mp hb1 with e1 | e1 <;>
          rcases Nat.le_one_iff_eq_zero_or_eq_one.mp hb2 with e2 | e2 <;>
            rw [e1, e2] at h ⊢ <;> omega
      have hmod : n ≡ n' [MOD 2 ^ k] := ih n n' hw.1
      obtain ⟨c, hc⟩ : ∃ c, n' = n + 2 ^ k * c := by
        obtain ⟨c, hc⟩ := (Nat.modEq_iff_dvd' hle).mp hmod
        exact ⟨c, by omega⟩
      rcases Nat.even_or_odd c with hce | hco
      · obtain ⟨d, hd⟩ := hce
        have he : n' = n + 2 ^ (k + 1) * d := by subst hc; rw [hd]; ring
        subst he; simp [Nat.add_mul_mod_self_left]
      · exfalso
        obtain ⟨d, hd⟩ := hco
        have hn' : n' = (n + 2 ^ k) + 2 ^ (k + 1) * d := by subst hc; rw [hd]; ring
        have hEq : pbit n' k = pbit (n + 2 ^ k) k := by
          rw [hn']; exact pbit_period (k + 1) (n + 2 ^ k) d k (by omega)
        exact pbit_flip k n (by rw [← hEq, ← hw.2])
    intro n n' h
    rcases le_total n n' with hle | hle
    · exact main n n' hle h
    · exact (main n' n hle h.symm).symm

/-- The parity word map is injective on a complete residue system. -/
theorem parityWord_injOn (k : ℕ) :
    Set.InjOn (parityWord k) (Finset.range (2 ^ k)) := by
  intro a ha b hb hab
  have h := parityWord_injective_mod k a b hab
  rwa [Nat.mod_eq_of_lt (Finset.mem_range.mp ha),
    Nat.mod_eq_of_lt (Finset.mem_range.mp hb)] at h

/-- **The parity-word bijection.** `n ↦ parityWord k n` maps `{0,…,2^k-1}`
bijectively onto itself: every binary word of length `k` occurs as the parity
prefix of exactly one residue class mod `2^k`. -/
theorem parityWord_image (k : ℕ) :
    Finset.image (parityWord k) (Finset.range (2 ^ k)) = Finset.range (2 ^ k) := by
  apply Finset.eq_of_subset_of_card_le
  · intro x hx
    obtain ⟨a, _, rfl⟩ := Finset.mem_image.mp hx
    exact Finset.mem_range.mpr (parityWord_lt k a)
  · rw [Finset.card_image_of_injOn (parityWord_injOn k)]

theorem parityWord_bijOn (k : ℕ) :
    Set.BijOn (parityWord k) (Finset.range (2 ^ k)) (Finset.range (2 ^ k)) := by
  refine ⟨fun a _ => by exact_mod_cast Finset.mem_range.mpr (parityWord_lt k a),
    parityWord_injOn k, ?_⟩
  intro w hw
  have hw' : w ∈ Finset.range (2 ^ k) := by exact_mod_cast hw
  rw [← parityWord_image k] at hw'
  obtain ⟨a, ha, rfl⟩ := Finset.mem_image.mp hw'
  exact ⟨a, by exact_mod_cast ha, rfl⟩

/-- **Surjectivity**: every binary word of length `k` is realised. -/
theorem parityWord_surjective (k w : ℕ) (hw : w < 2 ^ k) :
    ∃ n < 2 ^ k, parityWord k n = w := by
  have : w ∈ Finset.image (parityWord k) (Finset.range (2 ^ k)) := by
    rw [parityWord_image k]; exact Finset.mem_range.mpr hw
  obtain ⟨n, hn, hnw⟩ := Finset.mem_image.mp this
  exact ⟨n, Finset.mem_range.mp hn, hnw⟩

/-- Reindexing along the bijection: any sum over residues of a function of the
parity word is a sum over all words. -/
theorem sum_over_parityWords {M : Type*} [AddCommMonoid M] (k : ℕ) (g : ℕ → M) :
    ∑ n ∈ Finset.range (2 ^ k), g (parityWord k n)
      = ∑ w ∈ Finset.range (2 ^ k), g w := by
  conv_rhs => rw [← parityWord_image k]
  rw [Finset.sum_image fun a ha b hb h => parityWord_injOn k ha hb h]

/-! ## §4. Extremal parity prefixes -/

/-- The all-ones word of length `k` is `2^k - 1`. -/
lemma sum_range_two_pow (k : ℕ) : ∑ j ∈ Finset.range k, 2 ^ j = 2 ^ k - 1 := by
  induction k with
  | zero => simp
  | succ k ih =>
    rw [Finset.sum_range_succ, ih]
    have h1 : (1 : ℕ) ≤ 2 ^ k := Nat.one_le_two_pow
    have h2 : (2 : ℕ) ^ (k + 1) = 2 ^ k + 2 ^ k := by ring
    omega

/-- A parity word equal to `2^k - 1` forces every one of the first `k` steps to
be odd. -/
theorem all_odd_of_parityWord_eq (k n : ℕ) (h : parityWord k n = 2 ^ k - 1) :
    ∀ j < k, pbit n j = 1 := by
  have hgeom : ∑ j ∈ Finset.range k, 2 ^ j = 2 ^ k - 1 := sum_range_two_pow k
  have hle : ∀ j ∈ Finset.range k, pbit n j * 2 ^ j ≤ 2 ^ j := by
    intro j _
    have := pbit_le_one n j
    nlinarith [pow_pos (by norm_num : (0:ℕ) < 2) j]
  have hsum : ∑ j ∈ Finset.range k, pbit n j * 2 ^ j = ∑ j ∈ Finset.range k, 2 ^ j := by
    rw [hgeom]; exact h
  have := (Finset.sum_eq_sum_iff_of_le hle).mp hsum
  intro j hj
  have hj' := this j (Finset.mem_range.mpr hj)
  have hp : (0:ℕ) < 2 ^ j := pow_pos (by norm_num) j
  nlinarith [pbit_le_one n j]

/-- A vanishing parity word forces every one of the first `k` steps to be even. -/
theorem all_even_of_parityWord_eq_zero (k n : ℕ) (h : parityWord k n = 0) :
    ∀ j < k, pbit n j = 0 := by
  intro j hj
  have hterm : pbit n j * 2 ^ j = 0 := by
    have := Finset.sum_eq_zero_iff.mp h j (Finset.mem_range.mpr hj)
    exact this
  have hp : (0:ℕ) < 2 ^ j := pow_pos (by norm_num) j
  rcases Nat.mul_eq_zero.mp hterm with h1 | h1
  · exact h1
  · omega

/-- **Maximally expanding classes exist at every scale**: for each `k` there is a
residue class mod `2^k` all of whose first `k` accelerated steps are odd, i.e.
whose ones-count is `k`. -/
theorem exists_all_odd_prefix (k : ℕ) :
    ∃ n < 2 ^ k, onesCount k n = k ∧ ∀ j < k, pbit n j = 1 := by
  obtain ⟨n, hn, hw⟩ := parityWord_surjective k (2 ^ k - 1) (by
    have : (1 : ℕ) ≤ 2 ^ k := Nat.one_le_two_pow
    omega)
  refine ⟨n, hn, ?_, all_odd_of_parityWord_eq k n hw⟩
  unfold onesCount
  rw [Finset.sum_congr rfl fun j hj =>
    all_odd_of_parityWord_eq k n hw j (Finset.mem_range.mp hj)]
  simp

/-- **Maximally contracting classes exist at every scale.** -/
theorem exists_all_even_prefix (k : ℕ) :
    ∃ n < 2 ^ k, onesCount k n = 0 ∧ ∀ j < k, pbit n j = 0 := by
  obtain ⟨n, hn, hw⟩ := parityWord_surjective k 0 (pow_pos (by norm_num) k)
  refine ⟨n, hn, ?_, all_even_of_parityWord_eq_zero k n hw⟩
  unfold onesCount
  rw [Finset.sum_congr rfl fun j hj =>
    all_even_of_parityWord_eq_zero k n hw j (Finset.mem_range.mp hj)]
  simp

end CollatzParity