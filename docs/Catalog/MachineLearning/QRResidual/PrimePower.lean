import MachineLearning.QRResidual.FootprintWeight

/-!
# Hensel lifting: the footprint of a prime *power* is still `2/p^k`

`FootprintWeight` proved the `2/0` dichotomy for the sieve hit count at an odd prime `p`:
over one period of sieve locations, `x² − N` is divisible by `p` at exactly two locations
when `N` is a quadratic residue mod `p`, and at none otherwise.  A real quadratic sieve
also accumulates the higher prime powers `p^k`, and the natural conjecture (direction D3 of
the previous cycle) is that Hensel lifting keeps the local root count at `2`.

This file proves it, from scratch, by an explicit lifting bijection: the reduction map
`x ↦ x mod p^k` is a bijection from the roots mod `p^{k+1}` onto the roots mod `p^k`.
Existence of the lift solves the linear congruence `2 a t ≡ −m (mod p)`, which is solvable
because `p` is odd and `p ∤ a`; uniqueness comes from `p ∤ (x + y)`.

Main results.

* `dvd_sq_sub_congr` — the sieve-divisibility condition only depends on `x` mod the modulus.
* `hitCount_pow_succ` — **the Hensel step**: `hitCount N p^{k+1} = hitCount N p^k`.
* `hitCount_prime_pow` — hence `hitCount N p^k = hitCount N p` for every `k ≥ 1`.
* `hitCount_prime_pow_eq_two`, `hitCount_prime_pow_eq_zero` — the `2/0` dichotomy at prime
  powers.
* `footprint_density_prime_pow` — **the D3 statement**: the local density of hits of the
  modulus `p^k` is exactly `2/p^k` for admissible `p`, and `0` otherwise.
-/

namespace QRResidual

open Finset

/-! ## Two elementary lemmas -/

/-- The sieve-divisibility condition depends only on the residue of the location. -/
theorem dvd_sq_sub_congr {m a b N : ℤ} (h : m ∣ a - b) :
    (m ∣ a ^ 2 - N) ↔ (m ∣ b ^ 2 - N) := by
  constructor
  · intro hd
    have hrw : b ^ 2 - N = (a ^ 2 - N) - (a - b) * (a + b) := by ring
    rw [hrw]
    exact dvd_sub hd (h.mul_right _)
  · intro hd
    have hrw : a ^ 2 - N = (b ^ 2 - N) + (a - b) * (a + b) := by ring
    rw [hrw]
    exact dvd_add hd (h.mul_right _)

/-- `x − (x mod m) = m · (x / m)`, cast to `ℤ`. -/
theorem cast_sub_mod (x m : ℕ) :
    (x : ℤ) - ((x % m : ℕ) : ℤ) = ((m : ℕ) : ℤ) * ((x / m : ℕ) : ℤ) := by
  have h : ((m : ℕ) : ℤ) * ((x / m : ℕ) : ℤ) + ((x % m : ℕ) : ℤ) = (x : ℤ) := by
    exact_mod_cast congrArg (fun n : ℕ => (n : ℤ)) (Nat.div_add_mod x m)
  linarith

/-- A location hit by an odd prime `p` with `p ∤ N` is itself prime to `p`. -/
theorem not_dvd_of_sieve_hit {p : ℕ} {N x : ℤ} (hpN : ¬ (p : ℤ) ∣ N)
    (hx : (p : ℤ) ∣ (x ^ 2 - N)) : ¬ (p : ℤ) ∣ x := by
  intro hdvd
  apply hpN
  have h2 : (p : ℤ) ∣ x ^ 2 := Dvd.dvd.pow hdvd (by norm_num)
  have : N = x ^ 2 - (x ^ 2 - N) := by ring
  rw [this]
  exact dvd_sub h2 hx

/-- An odd prime does not divide `2 x` when it does not divide `x`. -/
theorem not_dvd_two_mul {p : ℕ} {x : ℤ} (hp : p.Prime) (hp2 : p ≠ 2)
    (hx : ¬ (p : ℤ) ∣ x) : ¬ (p : ℤ) ∣ 2 * x := by
  intro h
  rcases (Nat.prime_iff_prime_int.1 hp).2.2 2 x h with h2 | hx'
  · have hdvd2 : p ∣ 2 := by exact_mod_cast h2
    have hle : p ≤ 2 := Nat.le_of_dvd (by norm_num) hdvd2
    have hge : 2 ≤ p := hp.two_le
    exact hp2 (by omega)
  · exact hx hx'

/-! ## The Hensel step -/

/-- **Hensel step for the sieve hit count.**  For an odd prime `p ∤ N`, reduction mod `p^k`
is a bijection from the sieve hits of `p^{k+1}` onto those of `p^k`; in particular the two
counts agree. -/
theorem hitCount_pow_succ {p k : ℕ} {N : ℤ} (hp : p.Prime) (hp2 : p ≠ 2)
    (hpN : ¬ (p : ℤ) ∣ N) (hk : 1 ≤ k) :
    hitCount N (p ^ (k + 1)) = hitCount N (p ^ k) := by
  classical
  haveI : Fact p.Prime := ⟨hp⟩
  have hppos : 0 < p := hp.pos
  have hkpos : 0 < p ^ k := pow_pos hppos k
  have hcast : ∀ j : ℕ, ((p ^ j : ℕ) : ℤ) = (p : ℤ) ^ j := by
    intro j; push_cast; ring
  unfold hitCount
  refine Finset.card_bij (fun x _ => x % p ^ k) ?_ ?_ ?_
  · -- reduction lands in the smaller root set
    intro x hx
    simp only [mem_filter, mem_range, hcast] at hx ⊢
    obtain ⟨hxlt, hxdvd⟩ := hx
    refine ⟨Nat.mod_lt _ hkpos, ?_⟩
    have hdvd : (p : ℤ) ^ k ∣ ((x : ℤ) ^ 2 - N) :=
      dvd_trans (pow_dvd_pow _ (Nat.le_succ k)) hxdvd
    have hcong : (p : ℤ) ^ k ∣ ((x : ℤ) - ((x % p ^ k : ℕ) : ℤ)) := by
      rw [cast_sub_mod, hcast]
      exact dvd_mul_right _ _
    exact (dvd_sq_sub_congr hcong).1 hdvd
  · -- uniqueness of the lift
    intro x hx y hy hxy
    have hxy' : x % p ^ k = y % p ^ k := hxy
    simp only [mem_filter, mem_range, hcast] at hx hy
    obtain ⟨hxlt, hxdvd⟩ := hx
    obtain ⟨hylt, hydvd⟩ := hy
    have h1 : (x : ℤ) - ((x % p ^ k : ℕ) : ℤ) = ((p ^ k : ℕ) : ℤ) * ((x / p ^ k : ℕ) : ℤ) :=
      cast_sub_mod x _
    have h2 : (y : ℤ) - ((y % p ^ k : ℕ) : ℤ) = ((p ^ k : ℕ) : ℤ) * ((y / p ^ k : ℕ) : ℤ) :=
      cast_sub_mod y _
    rw [hxy', hcast] at h1
    rw [hcast] at h2
    have hdk : (p : ℤ) ^ k ∣ ((x : ℤ) - (y : ℤ)) :=
      ⟨((x / p ^ k : ℕ) : ℤ) - ((y / p ^ k : ℕ) : ℤ), by linear_combination h1 - h2⟩
    obtain ⟨s, hs⟩ := hdk
    -- the difference of squares is divisible by `p^{k+1}`
    have hsq : (p : ℤ) ^ (k + 1) ∣ ((x : ℤ) ^ 2 - (y : ℤ) ^ 2) := by
      have hrw : (x : ℤ) ^ 2 - (y : ℤ) ^ 2 = ((x : ℤ) ^ 2 - N) - ((y : ℤ) ^ 2 - N) := by ring
      rw [hrw]
      exact dvd_sub hxdvd hydvd
    have hfac : (x : ℤ) ^ 2 - (y : ℤ) ^ 2 = (p : ℤ) ^ k * (s * ((x : ℤ) + (y : ℤ))) := by
      linear_combination ((x : ℤ) + (y : ℤ)) * hs
    have hkne : ((p : ℤ) ^ k) ≠ 0 := by positivity
    have hps : (p : ℤ) ∣ s * ((x : ℤ) + (y : ℤ)) := by
      have hd : (p : ℤ) ^ k * (p : ℤ) ∣ (p : ℤ) ^ k * (s * ((x : ℤ) + (y : ℤ))) := by
        rw [← hfac, ← pow_succ]
        exact hsq
      exact (mul_dvd_mul_iff_left hkne).1 hd
    -- `p` does not divide `x + y`
    have hpx : ¬ (p : ℤ) ∣ (x : ℤ) :=
      not_dvd_of_sieve_hit hpN (dvd_trans (dvd_pow_self _ (by omega)) hxdvd)
    have hpxy : ¬ (p : ℤ) ∣ ((x : ℤ) + (y : ℤ)) := by
      intro h
      have hdxy : (p : ℤ) ∣ ((x : ℤ) - (y : ℤ)) :=
        dvd_trans (dvd_pow_self _ (by omega)) ⟨s, hs⟩
      have h2x : (p : ℤ) ∣ 2 * (x : ℤ) := by
        have := dvd_add h hdxy
        have hrw : (x : ℤ) + (y : ℤ) + ((x : ℤ) - (y : ℤ)) = 2 * (x : ℤ) := by ring
        rwa [hrw] at this
      exact not_dvd_two_mul hp hp2 hpx h2x
    have hpdvds : (p : ℤ) ∣ s :=
      ((Nat.prime_iff_prime_int.1 hp).2.2 s _ hps).resolve_right hpxy
    -- and `|s| < p`, so `s = 0`
    have habs : |(x : ℤ) - (y : ℤ)| < (p : ℤ) ^ (k + 1) := by
      have hx' : (x : ℤ) < (p : ℤ) ^ (k + 1) := by exact_mod_cast hxlt
      have hy' : (y : ℤ) < (p : ℤ) ^ (k + 1) := by exact_mod_cast hylt
      have hx0 : (0 : ℤ) ≤ (x : ℤ) := Int.natCast_nonneg x
      have hy0 : (0 : ℤ) ≤ (y : ℤ) := Int.natCast_nonneg y
      rw [abs_lt]
      constructor <;> linarith
    have hsabs : |s| < (p : ℤ) := by
      have hpk : (0 : ℤ) < (p : ℤ) ^ k := by positivity
      have habs2 : (p : ℤ) ^ k * |s| < (p : ℤ) ^ k * (p : ℤ) := by
        calc (p : ℤ) ^ k * |s| = |(p : ℤ) ^ k * s| := by
              rw [abs_mul, abs_of_pos hpk]
          _ = |(x : ℤ) - (y : ℤ)| := by rw [hs]
          _ < (p : ℤ) ^ (k + 1) := habs
          _ = (p : ℤ) ^ k * (p : ℤ) := by ring
      exact lt_of_mul_lt_mul_left habs2 (le_of_lt hpk)
    have hs0 : s = 0 := Int.eq_zero_of_abs_lt_dvd hpdvds hsabs
    rw [hs0, mul_zero] at hs
    have : (x : ℤ) = (y : ℤ) := by linarith
    exact_mod_cast this
  · -- existence of the lift
    intro b hb
    simp only [mem_filter, mem_range, hcast] at hb
    obtain ⟨hblt, hbdvd⟩ := hb
    obtain ⟨m, hm⟩ := hbdvd
    have hpb : ¬ (p : ℤ) ∣ (b : ℤ) :=
      not_dvd_of_sieve_hit hpN (dvd_trans (dvd_pow_self _ (by omega)) ⟨m, hm⟩)
    have hbz : (2 * (b : ZMod p)) ≠ 0 := by
      intro h
      apply not_dvd_two_mul hp hp2 hpb
      rw [← ZMod.intCast_zmod_eq_zero_iff_dvd]
      push_cast
      exact h
    set c : ZMod p := (-(m : ZMod p)) * (2 * (b : ZMod p))⁻¹ with hc
    set t : ℕ := c.val with ht
    have htlt : t < p := ZMod.val_lt c
    have htc : ((t : ℕ) : ZMod p) = c := by
      rw [ht]
      simp [ZMod.natCast_val]
    -- the key congruence `2 b t ≡ −m (mod p)`
    have hlin : (p : ℤ) ∣ (m + 2 * (b : ℤ) * (t : ℤ)) := by
      rw [← ZMod.intCast_zmod_eq_zero_iff_dvd]
      push_cast
      rw [htc, hc]
      linear_combination (-(m : ZMod p)) * mul_inv_cancel₀ hbz
    refine ⟨b + t * p ^ k, ?_, ?_⟩
    · simp only [mem_filter, mem_range, hcast]
      constructor
      · have hb1 : b + t * p ^ k < p ^ k * (t + 1) := by
          have hmul : p ^ k * (t + 1) = t * p ^ k + p ^ k := by ring
          rw [hmul]
          linarith
        have hb2 : p ^ k * (t + 1) ≤ p ^ k * p := Nat.mul_le_mul_left _ (by omega)
        have hb3 : p ^ k * p = p ^ (k + 1) := by ring
        omega
      · -- the lifted location is a root mod `p^{k+1}`
        obtain ⟨u, hu⟩ := hlin
        have hcastx : ((b + t * p ^ k : ℕ) : ℤ) = (b : ℤ) + (t : ℤ) * (p : ℤ) ^ k := by
          push_cast; ring
        rw [hcastx]
        have h2k : (p : ℤ) ^ (k + 1) ∣ (p : ℤ) ^ (2 * k) := pow_dvd_pow _ (by omega)
        obtain ⟨w, hw⟩ := h2k
        refine ⟨u + (t : ℤ) ^ 2 * w, ?_⟩
        linear_combination hm + (p : ℤ) ^ k * hu + (t : ℤ) ^ 2 * hw
    · -- reduction recovers `b`
      show (b + t * p ^ k) % p ^ k = b
      rw [Nat.add_mul_mod_self_right, Nat.mod_eq_of_lt hblt]

/-! ## The `2/0` dichotomy at prime powers -/

/-- **The local root count is insensitive to the exponent.**  For an odd prime `p ∤ N`, the
number of sieve hits of `p^k` in one period of length `p^k` equals the number of hits of
`p` in one period of length `p`. -/
theorem hitCount_prime_pow {p k : ℕ} {N : ℤ} (hp : p.Prime) (hp2 : p ≠ 2)
    (hpN : ¬ (p : ℤ) ∣ N) (hk : 1 ≤ k) :
    hitCount N (p ^ k) = hitCount N p := by
  induction k with
  | zero => omega
  | succ j ih =>
    rcases Nat.eq_or_lt_of_le hk with h | h
    · simp [← h]
    · have hj : 1 ≤ j := by omega
      rw [hitCount_pow_succ hp hp2 hpN hj, ih hj]

/-- Admissible prime powers hit exactly twice per period. -/
theorem hitCount_prime_pow_eq_two {p k : ℕ} {N : ℤ} (hp : p.Prime) (hp2 : p ≠ 2)
    (hpN : ¬ (p : ℤ) ∣ N) (hk : 1 ≤ k) (hqr : IsQR N p) :
    hitCount N (p ^ k) = 2 := by
  rw [hitCount_prime_pow hp hp2 hpN hk]
  exact hitCount_eq_two_of_isQR hp hp2 hpN hqr

/-- Inadmissible prime powers never hit. -/
theorem hitCount_prime_pow_eq_zero {p k : ℕ} {N : ℤ} (hp : p.Prime) (hp2 : p ≠ 2)
    (hpN : ¬ (p : ℤ) ∣ N) (hk : 1 ≤ k) (hqr : ¬ IsQR N p) :
    hitCount N (p ^ k) = 0 := by
  rw [hitCount_prime_pow hp hp2 hpN hk]
  exact hitCount_eq_zero_of_not_isQR hp hp2 hqr

/-- **The prime-power footprint density.**  The local density of sieve hits of the modulus
`p^k` is exactly `2/p^k` when `N` is a quadratic residue mod `p`, and `0` otherwise: the
`2/p` slogan lifts verbatim to prime powers. -/
theorem footprint_density_prime_pow {p k : ℕ} {N : ℤ} (hp : p.Prime) (hp2 : p ≠ 2)
    (hpN : ¬ (p : ℤ) ∣ N) (hk : 1 ≤ k) :
    (hitCount N (p ^ k) : ℚ) / ((p : ℚ) ^ k)
      = if IsQR N p then 2 / ((p : ℚ) ^ k) else 0 := by
  by_cases hqr : IsQR N p
  · rw [if_pos hqr, hitCount_prime_pow_eq_two hp hp2 hpN hk hqr]
    norm_num
  · rw [if_neg hqr, hitCount_prime_pow_eq_zero hp hp2 hpN hk hqr]
    norm_num

/-! ## The even prime is different

The lifting argument above uses that the derivative `2x` is invertible mod `p`, which fails
at `p = 2`.  Indeed the local solvability condition at `2` is not "`N` is a square mod 2"
(every integer is) but the much stronger `N ≡ 1 (mod 8)`, and that obstruction already
kills every power of `2` at once. -/

/-- **The `mod 8` obstruction.**  If `N` is odd and `N ≢ 1 (mod 8)`, then no power `2^k`
with `k ≥ 3` ever divides a sieve value: the even prime contributes nothing at all. -/
theorem hitCount_two_pow_eq_zero {k : ℕ} {N : ℤ} (hN : Odd N) (hk : 3 ≤ k)
    (h8 : ¬ (8 : ℤ) ∣ (N - 1)) : hitCount N (2 ^ k) = 0 := by
  classical
  unfold hitCount
  rw [Finset.card_eq_zero, Finset.filter_eq_empty_iff]
  intro x _ hx
  apply h8
  have hcast : ((2 ^ k : ℕ) : ℤ) = (2 : ℤ) ^ k := by push_cast; ring
  rw [hcast] at hx
  have h8k : (8 : ℤ) ∣ ((x : ℤ) ^ 2 - N) := by
    have h2 : (2 : ℤ) ^ 3 ∣ (2 : ℤ) ^ k := pow_dvd_pow _ hk
    have := dvd_trans h2 hx
    norm_num at this
    exact this
  -- `x` must be odd, and an odd square is `1 mod 8`
  have hxodd : Odd (x : ℤ) := by
    rcases Int.even_or_odd (x : ℤ) with he | ho
    · exfalso
      obtain ⟨m, hm⟩ := he
      obtain ⟨n, hn⟩ := hN
      obtain ⟨c, hc⟩ := h8k
      have hx2 : (x : ℤ) ^ 2 = 4 * (m * m) := by rw [hm]; ring
      have hlin : 4 * (m * m) - N = 8 * c := by rw [← hx2]; exact hc
      omega
    · exact ho
  obtain ⟨m, hm⟩ := hxodd
  have hsq : (x : ℤ) ^ 2 - 1 = 4 * (m * (m + 1)) := by
    rw [hm]; ring
  have hmm : (2 : ℤ) ∣ m * (m + 1) := (Int.even_mul_succ_self m).two_dvd
  obtain ⟨c, hc⟩ := hmm
  have h8sq : (8 : ℤ) ∣ ((x : ℤ) ^ 2 - 1) := ⟨c, by rw [hsq, hc]; ring⟩
  have hrw : N - 1 = ((x : ℤ) ^ 2 - 1) - ((x : ℤ) ^ 2 - N) := by ring
  rw [hrw]
  exact dvd_sub h8sq h8k

section LabNotes

/-! `N = 7` is a quadratic residue mod `3` (`1² = 1 ≡ 7`), and Hensel lifting keeps two
roots at every power: `4² = 16 ≡ 7 (mod 9)` and `5² = 25 ≡ 7 (mod 9)`.  Modulo `5`,
`7 ≡ 2` is a non-residue, and no power of `5` ever hits. -/

example : hitCount 7 3 = 2 := by decide

example : hitCount 7 9 = 2 := by decide

example : hitCount 7 27 = 2 := by decide

example : hitCount 7 5 = 0 := by decide

example : hitCount 7 25 = 0 := by decide

/-! At the even prime the picture changes: `1 ≡ 1 (mod 8)` has **four** square roots modulo
`8` and modulo `16`, while `3` has none — the `mod 8` obstruction of
`hitCount_two_pow_eq_zero`. -/

example : hitCount 1 8 = 4 := by decide

example : hitCount 1 16 = 4 := by decide

example : hitCount 3 8 = 0 := by decide

end LabNotes

end QRResidual