/-
# CONVERSE-COST-CURVE, part II: the zero-divisor scan and its exact cost

The W2 witness of the converse-cost experiment is the *first hit* of the
zero-divisor scan: walk `x = 1, 2, 3, …` and stop at the first `x` with
`gcd(x, N) > 1`.  The experiment measured `cost = min(p, q)` in `60/60` runs.
This file proves that measurement is a theorem, and surrounds it with the
combinatorial cost data of the scan plane:

* `ConverseCost.firstHit_isLeast` — the scan stops exactly at `min p q`
  (`IsLeast`, so both "it stops there" and "it cannot stop earlier").
* `ConverseCost.hits_card` — the scan sees exactly `p + q - 1` hits among the
  `N` residues (stated additively).
* `ConverseCost.misses_card` — it wastes `φ(N) = (p-1)(q-1)` probes.
* `ConverseCost.random_probe_cost` — the hit density is at most `2 / min p q`,
  so a *uniform random* probe strategy also pays `Ω(min p q)` probes on average.
* `ConverseCost.balanced_scan_cost` — for a balanced semiprime the scan cost is
  at least `√(N/2)`: exponential in the bit length `log N`.  This is the formal
  "no poly(log N) route" statement for the W2 definition route.
* `ConverseCost.firstHit_reveals_pair` — and the cost buys the factorisation:
  `{min p q, N / min p q} = {p, q}`.
-/
import Mathlib

namespace ConverseCost

open Finset

/-- The residues below `N` on which the zero-divisor scan *hits*. -/
def hits (N : ℕ) : Finset ℕ := (Finset.range N).filter (fun x => 1 < Nat.gcd x N)

/-- A hit of the scan on a semiprime is a multiple of `p` or of `q`. -/
theorem hit_iff_dvd {p q x : ℕ} (hp : p.Prime) (hq : q.Prime) :
    1 < Nat.gcd x (p * q) ↔ (p ∣ x ∨ q ∣ x) := by
  constructor
  · intro h
    obtain ⟨r, hr, hrd⟩ := Nat.exists_prime_and_dvd (n := Nat.gcd x (p * q)) (by omega)
    have hrx : r ∣ x := hrd.trans (Nat.gcd_dvd_left _ _)
    have hrN : r ∣ p * q := hrd.trans (Nat.gcd_dvd_right _ _)
    rcases (Nat.Prime.dvd_mul hr).mp hrN with h1 | h1
    · exact Or.inl (((Nat.prime_dvd_prime_iff_eq hr hp).mp h1) ▸ hrx)
    · exact Or.inr (((Nat.prime_dvd_prime_iff_eq hr hq).mp h1) ▸ hrx)
  · have hgpos : 0 < Nat.gcd x (p * q) :=
      Nat.gcd_pos_of_pos_right x (Nat.mul_pos hp.pos hq.pos)
    rintro (h | h)
    · exact lt_of_lt_of_le hp.one_lt (Nat.le_of_dvd hgpos (Nat.dvd_gcd h ⟨q, rfl⟩))
    · exact lt_of_lt_of_le hq.one_lt
        (Nat.le_of_dvd hgpos (Nat.dvd_gcd h ⟨p, Nat.mul_comm p q⟩))

/-! ## The exact stopping point of the scan -/

/-- **W2, the measured cost.**  The zero-divisor scan over `x = 1, 2, …` on a
semiprime `N = p q` stops exactly at `x = min p q`: this residue is a hit, and
no smaller positive residue is.  (`IsLeast` packages both halves.) -/
theorem firstHit_isLeast {p q : ℕ} (hp : p.Prime) (hq : q.Prime) :
    IsLeast {x : ℕ | 0 < x ∧ 1 < Nat.gcd x (p * q)} (min p q) := by
  constructor
  · refine ⟨lt_min hp.pos hq.pos, (hit_iff_dvd hp hq).mpr ?_⟩
    rcases le_total p q with h | h
    · exact Or.inl (by rw [min_eq_left h])
    · exact Or.inr (by rw [min_eq_right h])
  · rintro x ⟨hx0, hx⟩
    rcases (hit_iff_dvd hp hq).mp hx with h | h
    · exact le_trans (min_le_left _ _) (Nat.le_of_dvd hx0 h)
    · exact le_trans (min_le_right _ _) (Nat.le_of_dvd hx0 h)

/-- The scan cost pays for the whole factorisation: the stopping point is one
prime and the cofactor is the other. -/
theorem firstHit_reveals_pair {p q : ℕ} (hp : p.Prime) (hq : q.Prime) :
    min p q * max p q = p * q ∧ (p * q) / min p q = max p q := by
  have hmin : 0 < min p q := lt_min hp.pos hq.pos
  rcases le_total p q with h | h
  · rw [min_eq_left h, max_eq_right h]
    exact ⟨rfl, Nat.mul_div_cancel_left q hp.pos⟩
  · rw [min_eq_right h, max_eq_left h]
    refine ⟨Nat.mul_comm q p, ?_⟩
    rw [Nat.mul_comm p q]
    exact Nat.mul_div_cancel_left p hq.pos

/-! ## How much of the scan plane is useful -/

/-- Multiples of `p` below `p * q`: there are `q` of them. -/
theorem card_multiples {p q : ℕ} (hp : 0 < p) :
    ((Finset.range (p * q)).filter (fun x => p ∣ x)).card = q := by
  have hset : (Finset.range (p * q)).filter (fun x => p ∣ x)
      = (Finset.range q).image (fun i => p * i) := by
    ext x
    simp only [mem_filter, mem_range, mem_image]
    constructor
    · rintro ⟨hx, i, rfl⟩
      exact ⟨i, lt_of_mul_lt_mul_left hx (Nat.zero_le p), rfl⟩
    · rintro ⟨i, hi, rfl⟩
      exact ⟨(Nat.mul_lt_mul_left hp).mpr hi, ⟨i, rfl⟩⟩
  rw [hset, Finset.card_image_of_injective _ (mul_right_injective₀ hp.ne'),
    Finset.card_range]

/-- **The hit count.**  Exactly `p + q - 1` of the `N` residues are hits
(stated additively: `hits + 1 = p + q`).  Only a `Θ(1/√N)` fraction of the scan
plane carries any factor information. -/
theorem hits_card {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hne : p ≠ q) :
    (hits (p * q)).card + 1 = p + q := by
  have hpq : Nat.Coprime p q := (Nat.coprime_primes hp hq).mpr hne
  classical
  have hA : (Finset.range (p * q)).filter (fun x => p ∣ x)
      ∪ (Finset.range (p * q)).filter (fun x => q ∣ x) = hits (p * q) := by
    ext x
    simp only [hits, mem_union, mem_filter, mem_range]
    constructor
    · rintro (⟨hx, h⟩ | ⟨hx, h⟩)
      · exact ⟨hx, (hit_iff_dvd hp hq).mpr (Or.inl h)⟩
      · exact ⟨hx, (hit_iff_dvd hp hq).mpr (Or.inr h)⟩
    · rintro ⟨hx, h⟩
      rcases (hit_iff_dvd hp hq).mp h with h' | h'
      · exact Or.inl ⟨hx, h'⟩
      · exact Or.inr ⟨hx, h'⟩
  have hI : (Finset.range (p * q)).filter (fun x => p ∣ x)
      ∩ (Finset.range (p * q)).filter (fun x => q ∣ x) = {0} := by
    ext x
    simp only [mem_inter, mem_filter, mem_range, Finset.mem_singleton]
    constructor
    · rintro ⟨⟨hx, hpx⟩, ⟨-, hqx⟩⟩
      have hdvd : p * q ∣ x := Nat.Coprime.mul_dvd_of_dvd_of_dvd hpq hpx hqx
      rcases Nat.eq_zero_or_pos x with h | h
      · exact h
      · exact absurd (Nat.le_of_dvd h hdvd) (not_le.mpr hx)
    · rintro rfl
      exact ⟨⟨Nat.mul_pos hp.pos hq.pos, dvd_zero _⟩,
        ⟨Nat.mul_pos hp.pos hq.pos, dvd_zero _⟩⟩
  have hcard := Finset.card_union_add_card_inter
    ((Finset.range (p * q)).filter (fun x => p ∣ x))
    ((Finset.range (p * q)).filter (fun x => q ∣ x))
  rw [hA, hI, Finset.card_singleton, card_multiples hp.pos] at hcard
  have hq' : ((Finset.range (p * q)).filter (fun x => q ∣ x)).card = p := by
    have hcomm : p * q = q * p := Nat.mul_comm _ _
    rw [hcomm, card_multiples hq.pos]
  rw [hq'] at hcard
  omega

/-- **The wasted probes.**  The scan walks past `φ(N) = (p-1)(q-1)` residues
that carry no information whatsoever: every one of them is coprime to `N`. -/
theorem misses_card {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hne : p ≠ q) :
    ((Finset.range (p * q)).filter (fun x => Nat.gcd x (p * q) = 1)).card
      = (p - 1) * (q - 1) := by
  have hpq : Nat.Coprime p q := (Nat.coprime_primes hp hq).mpr hne
  have h : (Finset.range (p * q)).filter (fun x => Nat.gcd x (p * q) = 1)
      = (Finset.range (p * q)).filter ((p * q).Coprime ·) := by
    ext x
    simp only [mem_filter, mem_range, Nat.Coprime, Nat.gcd_comm]
  rw [h, ← Nat.totient, Nat.totient_mul hpq, Nat.totient_prime hp, Nat.totient_prime hq]

/-! ## No poly(log N) route through the scan plane -/

/-- **Random probing does not help.**  The hit density is at most `2 / min p q`:
`card(hits) * min p q ≤ 2 N`.  Hence a uniformly random probe succeeds with
probability `≤ 2 / min p q`, and the expected number of probes is
`Ω(min p q)` — the same wall as the deterministic scan. -/
theorem random_probe_cost {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hne : p ≠ q) :
    (hits (p * q)).card * min p q ≤ 2 * (p * q) := by
  have hcard := hits_card hp hq hne
  have hp2 := hp.two_le
  have hq2 := hq.two_le
  rcases le_total p q with h | h
  · rw [min_eq_left h]
    nlinarith [hcard, hp2, hq2, h]
  · rw [min_eq_right h]
    nlinarith [hcard, hp2, hq2, h]

/-- **The `√N` wall.**  For a balanced semiprime (`p ≤ q ≤ 2p`) the scan cost
`min p q` satisfies `2 · cost² ≥ N`, i.e. `cost ≥ √(N/2)`.  Since `N = 2^{log₂ N}`
this is exponential in the bit length: the W2 definition route is *not*
`poly(log N)`. -/
theorem balanced_scan_cost {p q : ℕ} (hpq : p ≤ q) (hbal : q ≤ 2 * p) :
    p * q ≤ 2 * (min p q * min p q) := by
  rw [min_eq_left hpq]
  nlinarith [hpq, hbal]

/-- Conversely the cost never exceeds `√N`: `min p q ≤ √(p q)`, so the scan
route sits exactly on the `√N` scale of the classical methods. -/
theorem scan_cost_le_sqrt {p q : ℕ} : min p q * min p q ≤ p * q := by
  rcases le_total p q with h | h
  · rw [min_eq_left h]; exact Nat.mul_le_mul_left p h
  · rw [min_eq_right h]; exact Nat.mul_le_mul_right q h

/-! ## Lab notes -/

/-- `N = 143 = 11·13`: the scan stops at `11` and sees `11 + 13 - 1 = 23` hits. -/
example : (hits 143).card = 23 := by decide

example : (hits (3 * 5)).card = 7 := by decide

/-- The scan on `N = 143` really does not stop before `11`. -/
example : ∀ x ∈ Finset.range 11, 0 < x → Nat.gcd x 143 = 1 := by decide

end ConverseCost