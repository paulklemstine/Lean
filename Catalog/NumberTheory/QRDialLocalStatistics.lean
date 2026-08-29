import Mathlib

/-!
# The quadratic-residue dial of `x² − N`: exact local statistics

This file is the rigorous local half of the round-73 #4 (exp 562) finding
**SCALE-SMOOTHNESS-DEVIATION / RANDOM-AT-SCALE**: numerically the `B`-smoothness
probability of the quadratic-sieve polynomial `x² − N` was found to be
indistinguishable from that of size-matched random integers
(`r(u) = 1.011, 0.949, 0.900, 1.200` at `u ≈ 5.96, 6.95, 7.93, 8.26`, all
confidence intervals covering `1`, tightest bound `|r − 1| ≤ 0.217`), while a
*per-`N`* overdispersion `D = 1.61 [1.50, 1.73]` and a QR-dial correlation were
observed at the low-`u` face.

The mechanism behind both observations is completely local and completely
computable: for a prime `p` the polynomial `x² − N` hits `0 mod p` on

  `dial p N := #{x ∈ ZMod p | x² = N}`

residues instead of the "random" single residue.  This file computes the
distribution of that dial exactly.

## Main results

* `dial_of_sq`, `dial_eq_two_iff`, `dial_eq_zero_iff`, `dial_zero` — the
  **dichotomy**: for an odd prime `p` the dial is `2` on nonzero squares, `0` on
  nonsquares, and `1` at `N = 0`.
* `sum_dial` — **first moment is exactly random**: `∑_N dial p N = p`, i.e. the
  dial has mean exactly `1`, the same local density as a random integer.  This
  is the exact statement that quadratic structure gives *no* first-order
  smoothness edge.
* `sum_dial_sq` — **second moment**: `∑_N (dial p N)² = 2p − 1`.
* `localFactor` — the induced multiplicative correction
  `(p − dial p N)/(p − 1)` to the local non-divisibility density, and
  `sum_localFactor` (mean exactly `1`), `sum_localFactor_sq`
  (`= p + 1/(p−1)`), and `sum_localFactor_centred_sq` (variance exactly
  `1/(p(p−1))` per prime).

The variance `1/(p(p−1))` is the seed of the observed per-`N` overdispersion;
it is summed over primes in `Catalog.NumberTheory.ScaleSmoothnessDispersion`.
-/

namespace ScaleSmoothness

open Finset

/-- The **QR dial** of `N` at `p`: the number of roots of `x² − N` in `ZMod p`,
i.e. the number of residues on which `p` divides a value of the quadratic-sieve
polynomial.  A random integer has "dial `1`" on average. -/
def dial (p : ℕ) [NeZero p] (N : ZMod p) : ℕ :=
  #{x : ZMod p | x ^ 2 = N}

theorem dial_def (p : ℕ) [NeZero p] (N : ZMod p) :
    dial p N = #(univ.filter fun x : ZMod p => x ^ 2 = N) := rfl

section OddPrime

variable (p : ℕ) [Fact p.Prime]

/-- An odd prime is at least `3`. -/
theorem three_le_of_ne_two (hp : p ≠ 2) : 3 ≤ p := by
  have h2 := (Fact.out : p.Prime).two_le
  rcases (Fact.out : p.Prime).eq_two_or_odd' with h | h
  · exact absurd h hp
  · obtain ⟨k, hk⟩ := h; omega

/-- In an odd prime characteristic `2 ≠ 0`. -/
theorem two_ne_zero_of_ne_two (hp : p ≠ 2) : (2 : ZMod p) ≠ 0 := by
  have h : ((2 : ℕ) : ZMod p) = 0 ↔ p ∣ 2 := CharP.cast_eq_zero_iff (ZMod p) p 2
  simp only [Nat.cast_ofNat] at h
  intro hzero
  exact hp ((Nat.prime_dvd_prime_iff_eq (Fact.out : p.Prime) Nat.prime_two).1 (h.1 hzero))

theorem neg_eq_self_iff (hp : p ≠ 2) {x : ZMod p} : x = -x ↔ x = 0 := by
  constructor
  · intro h
    have h2 : (2 : ZMod p) * x = 0 := by linear_combination h
    rcases mul_eq_zero.1 h2 with h' | h'
    · exact absurd h' (two_ne_zero_of_ne_two p hp)
    · exact h'
  · rintro rfl; simp

/-- The root set of `x² = c²` is `{c, -c}`. -/
theorem sq_root_set (x : ZMod p) :
    (univ.filter fun y : ZMod p => y ^ 2 = x ^ 2) = {x, -x} := by
  ext y
  simp [sq_eq_sq_iff_eq_or_eq_neg]

/-- **Dichotomy at a square.**  The dial equals `2` at every nonzero square and
`1` at `0`. -/
theorem dial_of_sq (hp : p ≠ 2) (x : ZMod p) :
    dial p (x ^ 2) = if x = 0 then 1 else 2 := by
  rw [dial_def, sq_root_set]
  by_cases hx : x = 0
  · subst hx; simp
  · rw [if_neg hx, card_insert_of_notMem, card_singleton]
    simp only [mem_singleton]
    intro h
    exact hx ((neg_eq_self_iff p hp).1 h)

theorem dial_zero (hp : p ≠ 2) : dial p (0 : ZMod p) = 1 := by
  have := dial_of_sq p hp 0
  simpa using this

/-- The dial vanishes exactly on the nonsquares. -/
theorem dial_eq_zero_iff {N : ZMod p} : dial p N = 0 ↔ ¬ IsSquare N := by
  rw [dial_def, card_eq_zero, filter_eq_empty_iff]
  constructor
  · rintro h ⟨r, rfl⟩
    exact h (mem_univ r) (by ring)
  · intro h x _ hx
    exact h ⟨x, by rw [← hx]; ring⟩

theorem dial_eq_zero_of_not_isSquare {N : ZMod p} (h : ¬ IsSquare N) : dial p N = 0 :=
  (dial_eq_zero_iff p).2 h

/-- The dial never exceeds `2`: a quadratic has at most two roots. -/
theorem dial_le_two (hp : p ≠ 2) (N : ZMod p) : dial p N ≤ 2 := by
  by_cases h : IsSquare N
  · obtain ⟨r, rfl⟩ := h
    have : r * r = r ^ 2 := by ring
    rw [this, dial_of_sq p hp]
    split <;> omega
  · rw [dial_eq_zero_of_not_isSquare p h]; omega

/-- **The QR dial.**  For nonzero `N` the dial is `2` precisely when `N` is a
quadratic residue — this is the "QR dial" whose grip on the per-`N` smoothness
rate was measured experimentally. -/
theorem dial_eq_two_iff (hp : p ≠ 2) {N : ZMod p} (hN : N ≠ 0) :
    dial p N = 2 ↔ IsSquare N := by
  constructor
  · intro h
    by_contra hsq
    rw [dial_eq_zero_of_not_isSquare p hsq] at h
    exact absurd h (by norm_num)
  · rintro ⟨r, rfl⟩
    have hr : r ≠ 0 := by rintro rfl; exact hN (by simp)
    have : r * r = r ^ 2 := by ring
    rw [this, dial_of_sq p hp, if_neg hr]

end OddPrime

/-! ### Moments of the dial -/

/-- **First moment: exactly random.**  Summed over all `N`, the dial equals `p`,
so its mean is exactly `1` — the same expected number of hit residues as for a
random integer.  No first-order smoothness edge can come from the quadratic
shape of `x² − N`. -/
theorem sum_dial (p : ℕ) [NeZero p] : ∑ N : ZMod p, dial p N = p := by
  have h := Finset.card_eq_sum_card_fiberwise
    (f := fun x : ZMod p => x ^ 2) (s := (univ : Finset (ZMod p)))
    (t := (univ : Finset (ZMod p))) (fun x _ => mem_univ _)
  simp only [dial_def]
  rw [← h]
  simp [ZMod.card]

theorem sum_dial_sq_eq_pairs (p : ℕ) [NeZero p] :
    ∑ N : ZMod p, (dial p N) ^ 2 = #{q : ZMod p × ZMod p | q.1 ^ 2 = q.2 ^ 2} := by
  simp only [dial_def, card_filter, sq, Finset.sum_mul_sum, Fintype.sum_prod_type]
  rw [Finset.sum_comm]
  refine Finset.sum_congr rfl fun x _ => ?_
  rw [Finset.sum_comm]
  refine Finset.sum_congr rfl fun y _ => ?_
  simp

/-- **Second moment.**  `∑_N (dial p N)² = 2p − 1` for every odd prime `p`:
the dial is a `{0, 2}`-valued variable (plus the single `N = 0` slot), and this
is exactly what makes the per-`N` smoothness rate overdispersed. -/
theorem sum_dial_sq (p : ℕ) [Fact p.Prime] (hp : p ≠ 2) :
    ∑ N : ZMod p, (dial p N) ^ 2 = 2 * p - 1 := by
  rw [sum_dial_sq_eq_pairs]
  have hcard : #{q : ZMod p × ZMod p | q.1 ^ 2 = q.2 ^ 2} = ∑ x : ZMod p, dial p (x ^ 2) := by
    simp only [dial_def, card_filter, Fintype.sum_prod_type]
    refine Finset.sum_congr rfl fun x _ => Finset.sum_congr rfl fun y _ => ?_
    by_cases h : x ^ 2 = y ^ 2
    · rw [if_pos h, if_pos h.symm]
    · rw [if_neg h, if_neg fun hh => h hh.symm]
  rw [hcard]
  have hval : ∀ x : ZMod p, dial p (x ^ 2) = if x = 0 then 1 else 2 := dial_of_sq p hp
  simp only [hval]
  rw [Finset.sum_ite]
  have hne : ({x : ZMod p | ¬ x = 0} : Finset (ZMod p)) = univ.erase 0 := by
    ext x; simp
  simp only [Finset.filter_eq', mem_univ, if_pos, Finset.sum_const, card_singleton,
    smul_eq_mul, mul_one, hne, Finset.card_erase_of_mem (mem_univ (0 : ZMod p)),
    Finset.card_univ, ZMod.card]
  have h3 := three_le_of_ne_two p hp
  omega

/-! ### The multiplicative local correction factor -/

/-- The **local structure correction** at `p`: the ratio of the probability that
`p` does *not* divide `x² − N` (namely `1 − dial p N / p`) to the corresponding
probability `1 − 1/p` for a random integer.  A random integer has
`localFactor = 1` identically. -/
def localFactor (p : ℕ) [NeZero p] (N : ZMod p) : ℚ :=
  ((p : ℚ) - (dial p N : ℚ)) / ((p : ℚ) - 1)

theorem localFactor_nonneg (p : ℕ) [Fact p.Prime] (hp : p ≠ 2) (N : ZMod p) :
    0 ≤ localFactor p N := by
  have hd : (dial p N : ℚ) ≤ 2 := by exact_mod_cast dial_le_two p hp N
  have h3 : (3 : ℕ) ≤ p := three_le_of_ne_two p hp
  have hpq : (3 : ℚ) ≤ (p : ℚ) := by exact_mod_cast h3
  apply div_nonneg <;> linarith

/-- The local correction factor is strictly positive: at most two of the `p ≥ 3`
residues are killed. -/
theorem localFactor_pos (p : ℕ) [Fact p.Prime] (hp : p ≠ 2) (N : ZMod p) :
    0 < localFactor p N := by
  have hd : (dial p N : ℚ) ≤ 2 := by exact_mod_cast dial_le_two p hp N
  have h3 : (3 : ℕ) ≤ p := three_le_of_ne_two p hp
  have hpq : (3 : ℚ) ≤ (p : ℚ) := by exact_mod_cast h3
  apply div_pos <;> linarith

/-- The value of the local factor at a nonzero quadratic residue. -/
theorem localFactor_of_dial_two (p : ℕ) [NeZero p] {N : ZMod p} (h : dial p N = 2) :
    localFactor p N = ((p : ℚ) - 2) / ((p : ℚ) - 1) := by
  rw [localFactor, h]; norm_num

/-- The value of the local factor at a quadratic nonresidue. -/
theorem localFactor_of_dial_zero (p : ℕ) [NeZero p] {N : ZMod p} (h : dial p N = 0) :
    localFactor p N = (p : ℚ) / ((p : ℚ) - 1) := by
  rw [localFactor, h]; norm_num

/-- **The QR dial, quantitatively.**  A residue is *harder* to make smooth exactly
when it is a quadratic residue: the local factor at a residue is strictly smaller
than at a nonresidue. -/
theorem localFactor_lt_of_qr (p : ℕ) [Fact p.Prime] (hp : p ≠ 2) {N N' : ZMod p}
    (hN : dial p N = 2) (hN' : dial p N' = 0) : localFactor p N < localFactor p N' := by
  have h3 : (3 : ℕ) ≤ p := three_le_of_ne_two p hp
  have hpq : (3 : ℚ) ≤ (p : ℚ) := by exact_mod_cast h3
  have hden : (0 : ℚ) < (p : ℚ) - 1 := by linarith
  rw [localFactor_of_dial_two p hN, localFactor_of_dial_zero p hN']
  exact div_lt_div_of_pos_right (by linarith) hden

/-- **Mean exactly one.**  Averaged over the residue `N`, the local correction
factor is exactly `1`: quadratic structure is, prime by prime, ensemble-neutral. -/
theorem sum_localFactor (p : ℕ) [Fact p.Prime] (hp : p ≠ 2) :
    ∑ N : ZMod p, localFactor p N = (p : ℚ) := by
  have h3 : (3 : ℕ) ≤ p := three_le_of_ne_two p hp
  have hpq : (3 : ℚ) ≤ (p : ℚ) := by exact_mod_cast h3
  have hne : ((p : ℚ) - 1) ≠ 0 := by linarith
  have hsum : ∑ N : ZMod p, ((dial p N : ℚ)) = (p : ℚ) := by
    have := sum_dial p
    calc ∑ N : ZMod p, ((dial p N : ℚ)) = ((∑ N : ZMod p, dial p N : ℕ) : ℚ) := by push_cast; ring
      _ = (p : ℚ) := by rw [this]
  simp only [localFactor, ← Finset.sum_div, Finset.sum_sub_distrib, hsum]
  rw [Finset.sum_const, Finset.card_univ, ZMod.card]
  field_simp
  ring

/-- **Second moment of the local correction factor**: `p + 1/(p−1)`. -/
theorem sum_localFactor_sq (p : ℕ) [Fact p.Prime] (hp : p ≠ 2) :
    ∑ N : ZMod p, (localFactor p N) ^ 2 = (p : ℚ) + 1 / ((p : ℚ) - 1) := by
  have h3 : (3 : ℕ) ≤ p := three_le_of_ne_two p hp
  have hpq : (3 : ℚ) ≤ (p : ℚ) := by exact_mod_cast h3
  have hne : ((p : ℚ) - 1) ≠ 0 := by linarith
  have hsum : ∑ N : ZMod p, ((dial p N : ℚ)) = (p : ℚ) := by
    have := sum_dial p
    calc ∑ N : ZMod p, ((dial p N : ℚ)) = ((∑ N : ZMod p, dial p N : ℕ) : ℚ) := by push_cast; ring
      _ = (p : ℚ) := by rw [this]
  have hsum2 : ∑ N : ZMod p, ((dial p N : ℚ)) ^ 2 = 2 * (p : ℚ) - 1 := by
    have h := sum_dial_sq p hp
    have h2 : (1 : ℕ) ≤ 2 * p := by omega
    calc ∑ N : ZMod p, ((dial p N : ℚ)) ^ 2
        = ((∑ N : ZMod p, (dial p N) ^ 2 : ℕ) : ℚ) := by push_cast; ring
      _ = ((2 * p - 1 : ℕ) : ℚ) := by rw [h]
      _ = 2 * (p : ℚ) - 1 := by
          have : ((2 * p - 1 : ℕ) : ℚ) = ((2 * p : ℕ) : ℚ) - ((1 : ℕ) : ℚ) := by
            rw [Nat.cast_sub h2]
          rw [this]; push_cast; ring
  have expand : ∀ N : ZMod p, (localFactor p N) ^ 2 =
      ((p : ℚ) ^ 2 - 2 * (p : ℚ) * (dial p N : ℚ) + (dial p N : ℚ) ^ 2) / ((p : ℚ) - 1) ^ 2 := by
    intro N; rw [localFactor, div_pow]; ring_nf
  simp only [expand, ← Finset.sum_div]
  rw [Finset.sum_add_distrib, Finset.sum_sub_distrib, ← Finset.mul_sum, hsum, hsum2,
    Finset.sum_const, Finset.card_univ, ZMod.card]
  field_simp
  ring

/-- **Per-prime variance.**  The local correction factor has variance exactly
`1/(p(p−1))` around its mean `1`.  This nonzero variance — and nothing else — is
what produces the per-`N` clustering (`D > 1`) seen at the low-`u` face. -/
theorem sum_localFactor_centred_sq (p : ℕ) [Fact p.Prime] (hp : p ≠ 2) :
    ∑ N : ZMod p, (localFactor p N - 1) ^ 2 = 1 / ((p : ℚ) - 1) := by
  have h3 : (3 : ℕ) ≤ p := three_le_of_ne_two p hp
  have hpq : (3 : ℚ) ≤ (p : ℚ) := by exact_mod_cast h3
  have hne : ((p : ℚ) - 1) ≠ 0 := by linarith
  have expand : ∀ N : ZMod p, (localFactor p N - 1) ^ 2 =
      (localFactor p N) ^ 2 - 2 * localFactor p N + 1 := by intro N; ring
  simp only [expand]
  rw [Finset.sum_add_distrib, Finset.sum_sub_distrib, ← Finset.mul_sum,
    sum_localFactor p hp, sum_localFactor_sq p hp, Finset.sum_const, Finset.card_univ, ZMod.card]
  field_simp
  ring

end ScaleSmoothness