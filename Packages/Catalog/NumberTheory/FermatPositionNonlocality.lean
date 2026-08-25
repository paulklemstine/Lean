/-
# Non-locality of the smooth locus

Fourth companion to `Catalog/NumberTheory/FermatPositionGeometry.lean`.

The previous files established a dichotomy for the sieve polynomial
`v(j) = (b + j)^2 - N`:

* every *local* (finite-modulus) position property — divisibility by a fixed prime, by a
  fixed prime power, or a nontrivial gcd with the base value — is exactly periodic and
  hence has discrepancy at most its modulus in any window
  (`FermatPosition.periodic_block_balance`);
* while the *magnitude* of `v(j)` grows linearly in `j` (`FermatPosition.sieveVal_sandwich`).

This file closes the dichotomy by showing that the smooth locus itself is **not** local:
there is no modulus `T` and no predicate on `ZMod T` describing the positions carrying a
smooth value.  The witness is the degenerate sieve `b = 1`, `N = 0`, whose values are the
squares `(j+1)^2`, `3`-smooth exactly at the powers of two: a block of length `2^n`
starting at `0` carries at least `n + 1` hits while the next block of the same length
carries at most one.

Consequences for the positional-structure question: a small-`j` excess of `E` hits over
an equally long block can only be produced by a local carrier of modulus `T ≥ E`
(`periodic_block_balance`), and cannot be produced by *any* local carrier when the excess
grows with the window — the non-local, magnitude-driven component of smoothness is
unavoidable.

Main results.

* `smooth3_iff` : `n` is `3`-smooth iff `n` is a power of two.
* `degenerate_hit_iff` : the hit positions of the degenerate sieve are `2^k - 1`.
* `smooth_locus_block_imbalance` : block `[0, 2^n)` has at least `n+1` hits, block
  `[2^n, 2^{n+1})` has at most one.
* `smooth_locus_not_local` : for every `T` there is a pair of equal-length blocks whose
  hit counts differ by more than `T`.
* `no_local_description_of_smooth_locus` : consequently no `ZMod T`-predicate describes
  the smooth locus, for any modulus `T`.
-/
import Mathlib
import Catalog.NumberTheory.FermatPositionGeometry
import Catalog.NumberTheory.FermatPositionDensity

namespace FermatPosition

open Finset

/-- A natural number is `3`-smooth exactly when it is a power of two. -/
theorem smooth3_iff (n : ℕ) : n ∈ Nat.smoothNumbers 3 ↔ ∃ k, n = 2 ^ k := by
  constructor
  · intro h
    have hne : n ≠ 0 := h.1
    rw [Nat.mem_smoothNumbers'] at h
    refine ⟨n.primeFactorsList.length, Nat.eq_prime_pow_of_unique_prime_dvd hne ?_⟩
    intro d hd hdn
    have hlt := h d hd hdn
    have h2 := hd.two_le
    omega
  · rintro ⟨k, rfl⟩
    rw [Nat.mem_smoothNumbers']
    intro p hp hpd
    have h2 := (Nat.prime_dvd_prime_iff_eq hp Nat.prime_two).1 (Nat.Prime.dvd_of_dvd_pow hp hpd)
    omega

/-- The hit predicate of the degenerate sieve `b = 1`, `N = 0` at smoothness bound `3`. -/
def degHit (j : ℤ) : Prop := (sieveVal 1 0 j).natAbs ∈ Nat.smoothNumbers 3

instance : DecidablePred degHit := fun _ => by unfold degHit; infer_instance

/-- At a nonnegative position `i`, the degenerate sieve has a hit exactly when `i + 1` is
a power of two. -/
theorem degenerate_hit_iff (i : ℕ) : degHit (i : ℤ) ↔ ∃ k, i + 1 = 2 ^ k := by
  have hval : (sieveVal 1 0 (i : ℤ)).natAbs = (i + 1) ^ 2 := by
    simp only [sieveVal]
    have : ((1 : ℤ) + (i : ℤ)) ^ 2 - 0 = (((i + 1) ^ 2 : ℕ) : ℤ) := by push_cast; ring
    rw [this, Int.natAbs_natCast]
  unfold degHit
  rw [hval, smooth3_iff]
  constructor
  · rintro ⟨k, hk⟩
    have hpos : 0 < i + 1 := Nat.succ_pos i
    have h2 : (i + 1) ∈ Nat.smoothNumbers 3 := by
      refine Nat.mem_smoothNumbers_of_dvd (m := (i + 1) ^ 2) ?_ ⟨i + 1, by ring⟩
      rw [smooth3_iff]; exact ⟨k, hk⟩
    exact (smooth3_iff _).1 h2
  · rintro ⟨k, hk⟩
    exact ⟨2 * k, by rw [hk]; ring⟩

/-- The first block `[0, 2^n)` of the degenerate sieve carries at least `n + 1` hits. -/
theorem degenerate_first_block_ge (n : ℕ) : n + 1 ≤ posCount degHit 0 (2 ^ n) := by
  classical
  have hsub : ((range (n + 1)).image (fun k => 2 ^ k - 1))
      ⊆ (range (2 ^ n)).filter (fun i : ℕ => degHit (0 + (i : ℤ))) := by
    intro x hx
    simp only [mem_image, mem_range] at hx
    obtain ⟨k, hk, rfl⟩ := hx
    have hpow : (2 : ℕ) ^ k ≤ 2 ^ n := Nat.pow_le_pow_right (by norm_num) (by omega)
    have hpos : 1 ≤ (2 : ℕ) ^ k := Nat.one_le_two_pow
    refine mem_filter.2 ⟨mem_range.2 (by omega), ?_⟩
    have : ((0 : ℤ) + ((2 ^ k - 1 : ℕ) : ℤ)) = ((2 ^ k - 1 : ℕ) : ℤ) := by ring
    rw [this]
    exact (degenerate_hit_iff _).2 ⟨k, by omega⟩
  have hinj : Set.InjOn (fun k => 2 ^ k - 1) (range (n + 1)) := by
    intro a _ b _ hab
    simp only at hab
    have ha : 1 ≤ (2 : ℕ) ^ a := Nat.one_le_two_pow
    have hb : 1 ≤ (2 : ℕ) ^ b := Nat.one_le_two_pow
    have : (2 : ℕ) ^ a = 2 ^ b := by omega
    exact Nat.pow_right_injective (le_refl 2) this
  have hcard : ((range (n + 1)).image (fun k => 2 ^ k - 1)).card = n + 1 := by
    rw [card_image_of_injOn hinj, card_range]
  unfold posCount
  calc n + 1 = ((range (n + 1)).image (fun k => 2 ^ k - 1)).card := hcard.symm
    _ ≤ _ := card_le_card hsub

/-- The second block `[2^n, 2^{n+1})` of the degenerate sieve carries at most one hit. -/
theorem degenerate_second_block_le (n : ℕ) : posCount degHit (2 ^ n) (2 ^ n) ≤ 1 := by
  classical
  have hsub : (range (2 ^ n)).filter (fun i : ℕ => degHit ((2 ^ n : ℤ) + (i : ℤ)))
      ⊆ {2 ^ n - 1} := by
    intro x hx
    simp only [mem_filter, mem_range] at hx
    obtain ⟨hx1, hx2⟩ := hx
    have hcast : ((2 : ℤ) ^ n + (x : ℤ)) = (((2 ^ n + x : ℕ)) : ℤ) := by push_cast; ring
    rw [hcast] at hx2
    obtain ⟨k, hk⟩ := (degenerate_hit_iff _).1 hx2
    have hlow : 2 ^ n < 2 ^ n + x + 1 := by omega
    have hhigh : 2 ^ n + x + 1 ≤ 2 ^ (n + 1) := by
      have : (2 : ℕ) ^ (n + 1) = 2 ^ n + 2 ^ n := by ring
      omega
    have hk1 : 2 ^ n < 2 ^ k := by omega
    have hk2 : (2 : ℕ) ^ k ≤ 2 ^ (n + 1) := by omega
    have hkn : n < k := by
      by_contra hcon
      have : (2 : ℕ) ^ k ≤ 2 ^ n := Nat.pow_le_pow_right (by norm_num) (by omega)
      omega
    have hkn2 : k ≤ n + 1 := by
      by_contra hcon
      have : (2 : ℕ) ^ (n + 2) ≤ 2 ^ k := Nat.pow_le_pow_right (by norm_num) (by omega)
      have h2 : (2 : ℕ) ^ (n + 2) = 2 * 2 ^ (n + 1) := by ring
      have h3 : (1 : ℕ) ≤ 2 ^ (n + 1) := Nat.one_le_two_pow
      omega
    have hkeq : k = n + 1 := by omega
    subst hkeq
    have hpow : (2 : ℕ) ^ (n + 1) = 2 ^ n + 2 ^ n := by ring
    simp only [mem_singleton]
    omega
  unfold posCount
  calc ((range (2 ^ n)).filter (fun i : ℕ => degHit ((2 ^ n : ℤ) + (i : ℤ)))).card
      ≤ ({2 ^ n - 1} : Finset ℕ).card := card_le_card hsub
    _ = 1 := card_singleton _

/-- **Block imbalance of the smooth locus.**  For the degenerate sieve, the block
`[0, 2^n)` carries at least `n` more hits than the equally long block `[2^n, 2^{n+1})`
(indeed at least `n + 1` hits against at most one).  The imbalance is unbounded in `n`. -/
theorem smooth_locus_block_imbalance (n : ℕ) :
    posCount degHit (2 ^ n) (2 ^ n) + n ≤ posCount degHit 0 (2 ^ n) := by
  have h₁ := degenerate_first_block_ge n
  have h₂ := degenerate_second_block_le n
  omega

/-- **The smooth locus is not local.**  For every `T` there are two equally long blocks of
positions whose hit counts differ by more than `T`. -/
theorem smooth_locus_not_local (T : ℕ) :
    ∃ n : ℕ, posCount degHit (2 ^ n) (2 ^ n) + T < posCount degHit 0 (2 ^ n) :=
  ⟨T + 1, by
    have h₁ := degenerate_first_block_ge (T + 1)
    have h₂ := degenerate_second_block_le (T + 1)
    omega⟩

/-- **No finite modulus describes the smooth locus.**  There is no modulus `T` and no
predicate `Q` on `ZMod T` such that a position carries a smooth value exactly when its
residue satisfies `Q`.  Smoothness is genuinely non-local: unlike divisibility carriers,
it cannot be reduced to residue information, and its positional imbalance is unbounded. -/
theorem no_local_description_of_smooth_locus (T : ℕ) [NeZero T] (Q : ZMod T → Prop)
    [DecidablePred Q] (h : ∀ j : ℤ, degHit j ↔ Q (j : ZMod T)) : False := by
  obtain ⟨n, hn⟩ := smooth_locus_not_local T
  set L : ℕ := 2 ^ n with hL
  have hsplit : L = T * (L / T) + L % T := (Nat.div_add_mod L T).symm
  have hr : L % T < T := Nat.mod_lt _ (Nat.pos_of_ne_zero (NeZero.ne T))
  have hbal := periodic_block_balance T degHit Q h 0 ((2 : ℤ) ^ n) (L / T) (L % T) hr
  rw [← hsplit] at hbal
  omega

end FermatPosition