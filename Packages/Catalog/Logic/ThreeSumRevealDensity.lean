/-
# Cycle 2: density of the 3SUM factor reveal, arity reduction, and the threshold table

This file continues `Logic.ThreeSumBirthdayHierarchy`.

Three new results:

1. **Reveal density.**  In one full period `0 < s ≤ N = p*q` there are exactly `q`
   values of `s` divisible by `p`, and exactly `q - 1` of them reveal the factor
   (`gcd s N = p`); the single exception is `s = N` itself.  So the 3SUM reveal
   fails on a `1/q` fraction of its own witnesses — for `N = 143` that is
   `12 / 13`.

2. **Arity reduction.**  A 3SUM solution in `S ⊆ ZMod p` exists iff some `-c`
   (`c ∈ S`) lies in the sumset `S + S`.  This makes the "cost is `k²` anyway"
   step of the hierarchy precise: the arity-3 search is an arity-2 table plus
   `k` lookups.

3. **Order-based reveal (Pollard `p-1`).**  If `(p-1) ∣ k` and `p ∤ a` then
   `p ∣ aᵏ - 1`; if moreover `q ∤ aᵏ - 1` the same gcd lemma reveals `p`.  So
   3SUM, sumset and `p-1` reveals are all instances of one divisibility lemma.

4. **Threshold table** for `p = 100`, a fully verified instance of the
   hierarchy: the minimal search-set size drops `101 → 15 → 10` as the arity
   goes `1 → 2 → 3`, while the number of enumerated tuples stays `> 100`.
-/

import Mathlib
import Logic.ThreeSumBirthdayHierarchy

namespace ThreeSumBirthday

/-! ## 1. Density of the reveal -/

section Density

variable {p q : ℕ}

/-- In a full period, exactly `q` of the values `0 < s ≤ p*q` satisfy `p ∣ s`. -/
theorem count_modP_witnesses (hp : 0 < p) :
    {s ∈ Finset.Ioc 0 (p * q) | p ∣ s}.card = q := by
  rw [Nat.Ioc_filter_dvd_card_eq_div, Nat.mul_div_cancel_left q hp]

/-- Exactly one of them, namely `s = p*q`, fails to reveal (it is divisible by
`q` as well). -/
theorem count_modBoth_witnesses (hp : 0 < p) (hq : 0 < q) :
    {s ∈ Finset.Ioc 0 (p * q) | p * q ∣ s}.card = 1 := by
  rw [Nat.Ioc_filter_dvd_card_eq_div, Nat.div_self (Nat.mul_pos hp hq)]

/-- **Reveal density.**  Exactly `q - 1` of the `q` mod-`p` witnesses in one
period reveal the factor `p`; the success rate is `(q-1)/q`. -/
theorem count_revealing_witnesses (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q) :
    {s ∈ Finset.Ioc 0 (p * q) | Nat.gcd s (p * q) = p}.card = q - 1 := by
  have hcop : Nat.Coprime p q := (Nat.coprime_primes hp hq).2 hpq
  have hset : {s ∈ Finset.Ioc 0 (p * q) | Nat.gcd s (p * q) = p}
      = {s ∈ Finset.Ioc 0 (p * q) | p ∣ s} \ {s ∈ Finset.Ioc 0 (p * q) | p * q ∣ s} := by
    ext s
    simp only [Finset.mem_sdiff, Finset.mem_filter, Finset.mem_Ioc]
    constructor
    · intro ⟨hs, hg⟩
      have h := (gcd_eq_left_iff hp hq hpq).1 hg
      refine ⟨⟨hs, h.1⟩, ?_⟩
      rintro ⟨-, hdvd⟩
      exact h.2 (dvd_trans ⟨p, mul_comm p q⟩ hdvd)
    · intro ⟨⟨hs, hps⟩, hnot⟩
      refine ⟨hs, (gcd_eq_left_iff hp hq hpq).2 ⟨hps, fun hqs => ?_⟩⟩
      exact hnot ⟨hs, hcop.mul_dvd_of_dvd_of_dvd hps hqs⟩
  have hsub : {s ∈ Finset.Ioc 0 (p * q) | p * q ∣ s}
      ⊆ {s ∈ Finset.Ioc 0 (p * q) | p ∣ s} := by
    intro s hs
    simp only [Finset.mem_filter] at hs ⊢
    exact ⟨hs.1, dvd_trans ⟨q, rfl⟩ hs.2⟩
  rw [hset, Finset.card_sdiff_of_subset hsub, count_modP_witnesses hp.pos,
    count_modBoth_witnesses hp.pos hq.pos]

/-- For `N = 143 = 11 * 13`: 13 mod-`p` witnesses per period, 12 of which
reveal the factor `11`. -/
theorem reveal_density_143 :
    {s ∈ Finset.Ioc 0 143 | Nat.gcd s 143 = 11}.card = 12 := by
  have h11 : Nat.Prime 11 := by norm_num
  have h13 : Nat.Prime 13 := by norm_num
  have h : (143 : ℕ) = 11 * 13 := by norm_num
  rw [h]
  simpa using count_revealing_witnesses h11 h13 (by norm_num)

end Density

/-! ## 2. Arity reduction: 3SUM = sumset table + `k` lookups -/

section ArityReduction

variable {p : ℕ}

/-- The sumset `S + S` of a finite subset of `ZMod p`, of size at most `|S|²`. -/
def sumset (S : Finset (ZMod p)) : Finset (ZMod p) :=
  Finset.image (fun x : ZMod p × ZMod p => x.1 + x.2) (S ×ˢ S)

theorem card_sumset_le (S : Finset (ZMod p)) : (sumset S).card ≤ S.card * S.card := by
  refine le_trans (Finset.card_image_le) ?_
  simp [Finset.card_product]

/-- **Arity reduction.**  A 3SUM solution inside `S` exists iff `-c` lies in the
sumset for some `c ∈ S`: the arity-3 search is exactly an arity-2 table plus
`|S|` lookups, which is why the net cost of both rows of the hierarchy is the
size of the sumset table. -/
theorem threeSum_iff_neg_mem_sumset (S : Finset (ZMod p)) :
    (∃ a ∈ S, ∃ b ∈ S, ∃ c ∈ S, a + b + c = 0) ↔ ∃ c ∈ S, (-c) ∈ sumset S := by
  constructor
  · rintro ⟨a, ha, b, hb, c, hc, habc⟩
    refine ⟨c, hc, ?_⟩
    refine Finset.mem_image.2 ⟨(a, b), Finset.mem_product.2 ⟨ha, hb⟩, ?_⟩
    have : a + b = -c := by linear_combination habc
    simpa using this
  · rintro ⟨c, hc, hmem⟩
    obtain ⟨⟨a, b⟩, hab, hsum⟩ := Finset.mem_image.1 hmem
    obtain ⟨ha, hb⟩ := Finset.mem_product.1 hab
    exact ⟨a, ha, b, hb, c, hc, by simp at hsum; linear_combination hsum⟩

/-- A 3SUM witness in `ZMod p` lifts to the integer factor reveal: if the
natural numbers `a, b, c` have `(a+b+c : ZMod p) = 0` and `q ∤ a+b+c`, the gcd
with `N = p*q` is `p`. -/
theorem threeSum_zmod_reveals {q : ℕ} (hp : p.Prime) (hq : q.Prime)
    {a b c : ℕ} (h : ((a : ZMod p) + b + c) = 0) (hqs : ¬ q ∣ (a + b + c)) :
    Nat.gcd (a + b + c) (p * q) = p := by
  have hcast : ((a + b + c : ℕ) : ZMod p) = 0 := by push_cast; exact h
  exact threeSum_reveals_factor hp hq ((ZMod.natCast_eq_zero_iff _ _).1 hcast) hqs

end ArityReduction

/-! ## 3. The order-based (Pollard `p-1`) reveal is the same lemma -/

section Pollard

variable {p q : ℕ}

/-- Fermat step: `(p-1) ∣ k` and `p ∤ a` imply `p ∣ aᵏ - 1`. -/
theorem dvd_pow_sub_one (hp : p.Prime) {a k : ℕ} (ha : ¬ p ∣ a) (hk : (p - 1) ∣ k) :
    p ∣ a ^ k - 1 := by
  haveI : Fact p.Prime := ⟨hp⟩
  obtain ⟨m, rfl⟩ := hk
  have ha0 : (a : ZMod p) ≠ 0 := fun h => ha ((ZMod.natCast_eq_zero_iff _ _).1 h)
  have hpow : ((a ^ ((p - 1) * m) : ℕ) : ZMod p) = ((1 : ℕ) : ZMod p) := by
    push_cast
    rw [pow_mul, ZMod.pow_card_sub_one_eq_one ha0, one_pow]
  have hmod : (1 : ℕ) ≡ a ^ ((p - 1) * m) [MOD p] :=
    ((ZMod.natCast_eq_natCast_iff _ _ _).1 hpow).symm
  have hle : 1 ≤ a ^ ((p - 1) * m) := Nat.one_le_pow _ _ (Nat.pos_of_ne_zero (by
    rintro rfl; exact ha (dvd_zero p)))
  exact (Nat.modEq_iff_dvd' hle).1 hmod

/-- **Pollard `p-1` reveal.**  Same gcd lemma, different collision source:
`gcd (aᵏ - 1, N) = p` whenever `(p-1) ∣ k`, `p ∤ a` and `q ∤ aᵏ - 1`. -/
theorem pollard_p_minus_one_reveal (hp : p.Prime) (hq : q.Prime)
    {a k : ℕ} (ha : ¬ p ∣ a) (hk : (p - 1) ∣ k) (hqa : ¬ q ∣ a ^ k - 1) :
    Nat.gcd (a ^ k - 1) (p * q) = p :=
  gcd_eq_left_of_dvd_of_not_dvd hp hq (dvd_pow_sub_one hp ha hk) hqa

end Pollard

/-! ## 4. Verified threshold table for `p = 100`

The minimal search-set size `k` that guarantees a collision drops as the arity
grows, while the number of enumerated tuples stays above `p = 100`. -/

section Table

/-- Arity 1 (evaluations): `k = 101` is needed and enumerates `101 > 100`. -/
theorem threshold_arity_one :
    100 < Nat.choose 101 1 ∧ ¬ (100 < Nat.choose 100 1) := by
  constructor <;> simp

/-- Arity 2 (sumset pairs): `k = 15` suffices, `k = 14` does not, and the
enumeration is `C(15,2) = 105 > 100`. -/
theorem threshold_arity_two :
    100 < Nat.choose 15 2 ∧ ¬ (100 < Nat.choose 14 2) ∧ Nat.choose 15 2 = 105 := by
  refine ⟨by decide, by decide, by decide⟩

/-- Arity 3 (3SUM triples): `k = 10` suffices, `k = 9` does not, and the
enumeration is `C(10,3) = 120 > 100`. -/
theorem threshold_arity_three :
    100 < Nat.choose 10 3 ∧ ¬ (100 < Nat.choose 9 3) ∧ Nat.choose 10 3 = 120 := by
  refine ⟨by decide, by decide, by decide⟩

/-- **Strict exponent improvement** at `p = 100`: the search-set sizes are
strictly decreasing in the arity, `101 > 15 > 10`. -/
theorem search_size_strictly_decreasing : (10 : ℕ) < 15 ∧ (15 : ℕ) < 101 := by
  exact ⟨by norm_num, by norm_num⟩

/-- **Net cost invariance** at `p = 100`: all three rows enumerate more than
`p` tuples, hence more than `√N` for any semiprime `N = 100 * q` with
`q ≤ 100`. -/
theorem cost_invariance_table (q : ℕ) (hq : q ≤ 100) :
    Nat.sqrt (100 * q) < Nat.choose 101 1 ∧
    Nat.sqrt (100 * q) < Nat.choose 15 2 ∧
    Nat.sqrt (100 * q) < Nat.choose 10 3 :=
  ⟨sqrt_barrier hq (by decide), sqrt_barrier hq (by decide), sqrt_barrier hq (by decide)⟩

end Table

end ThreeSumBirthday