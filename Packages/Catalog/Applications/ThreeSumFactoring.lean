/-
# 3SUM mod `p` reveals a factor of `N = p*q`

Let `N = p * q` be a semiprime with `p ≠ q` two primes.  If a triple `(a,b,c)`
satisfies

* `a + b + c ≡ 0 (mod p)`, and
* `a + b + c ≢ 0 (mod q)`,

then `gcd(a+b+c, N) = p`: the triple *reveals* the factor `p`.

The file proves the general gcd lemma behind this observation, the 3SUM
specialisation, and a *guaranteed reveal* theorem which explains the experimental
observation that no small triple is ever divisible by both primes: any positive
sum smaller than `N` that is divisible by `p` is automatically **not** divisible
by `q`, hence always reveals `p`.  A concrete `N = 143 = 11 * 13` census is
verified by kernel computation.

Companion file: `Catalog/Applications/BirthdayBoundHierarchy.lean`, which shows
that the *cost* of finding such a triple obeys the same `√N` barrier as every
other collision-based factoring method.
-/
import Mathlib

namespace ThreeSumFactoring

/-! ## The core arithmetic lemma -/

/-- **Factor reveal.**  If `p, q` are distinct primes, `p ∣ s` and `¬ q ∣ s`,
then `gcd(s, p*q) = p`.  The nontrivial content is that the gcd cannot be the
full modulus `p*q`, which is exactly the failure of divisibility by `q`. -/
theorem gcd_eq_of_dvd_of_not_dvd {p q s : ℕ} (hp : p.Prime) (hq : q.Prime)
    (hps : p ∣ s) (hqs : ¬ q ∣ s) : Nat.gcd s (p * q) = p := by
  set d := Nat.gcd s (p * q) with hd
  have hpd : p ∣ d := Nat.dvd_gcd hps (dvd_mul_right p q)
  have hdN : d ∣ p * q := Nat.gcd_dvd_right _ _
  obtain ⟨m, hm⟩ := hpd
  have hmq : m ∣ q := by
    have : p * m ∣ p * q := by rw [← hm]; exact hdN
    exact (mul_dvd_mul_iff_left hp.pos.ne').1 this
  rcases (Nat.Prime.eq_one_or_self_of_dvd hq m hmq) with h1 | hq'
  · rw [hm, h1, mul_one]
  · exfalso
    apply hqs
    refine dvd_trans ?_ (Nat.gcd_dvd_left s (p * q))
    rw [← hd, hm, hq']
    exact dvd_mul_left q p

/-- A revealed gcd is a genuine nontrivial factor of `N = p*q`. -/
theorem gcd_nontrivial_of_reveal {p q s : ℕ} (hp : p.Prime) (hq : q.Prime)
    (hps : p ∣ s) (hqs : ¬ q ∣ s) :
    1 < Nat.gcd s (p * q) ∧ Nat.gcd s (p * q) < p * q := by
  rw [gcd_eq_of_dvd_of_not_dvd hp hq hps hqs]
  refine ⟨hp.one_lt, ?_⟩
  have h1 : 1 < q := hq.one_lt
  have h2 : 0 < p := hp.pos
  nlinarith

/-! ## The 3SUM specialisation -/

/-- **3SUM mod-`p` factor reveal.**  A triple whose sum vanishes mod `p` but not
mod `q` exposes the factor `p` of `N = p*q` through a single gcd. -/
theorem threeSum_gcd_eq {p q a b c : ℕ} (hp : p.Prime) (hq : q.Prime)
    (hps : p ∣ a + b + c) (hqs : ¬ q ∣ a + b + c) :
    Nat.gcd (a + b + c) (p * q) = p :=
  gcd_eq_of_dvd_of_not_dvd hp hq hps hqs

/-- **No sum below `N` is divisible by both primes.**  This is the structural
reason the experimental "mod-both" census is always empty for small triples. -/
theorem not_dvd_both_of_lt {p q s : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q)
    (h0 : 0 < s) (hlt : s < p * q) : ¬ (p ∣ s ∧ q ∣ s) := by
  rintro ⟨h1, h2⟩
  have hcop : Nat.Coprime p q := (Nat.coprime_primes hp hq).2 hpq
  have : p * q ∣ s := hcop.mul_dvd_of_dvd_of_dvd h1 h2
  exact absurd (Nat.le_of_dvd h0 this) (not_le.2 hlt)

/-- **Guaranteed reveal.**  Every *positive* multiple of `p` below `N = p*q`
reveals `p`; no extra hypothesis mod `q` is needed.  In particular every
3SUM-mod-`p` triple with small entries is a factoring witness. -/
theorem reveal_of_pos_lt {p q s : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q)
    (h0 : 0 < s) (hlt : s < p * q) (hps : p ∣ s) : Nat.gcd s (p * q) = p := by
  refine gcd_eq_of_dvd_of_not_dvd hp hq hps (fun hqs => ?_)
  exact not_dvd_both_of_lt hp hq hpq h0 hlt ⟨hps, hqs⟩

/-- Small-entry 3SUM version of `reveal_of_pos_lt`. -/
theorem threeSum_reveal_of_small {p q a b c : ℕ} (hp : p.Prime) (hq : q.Prime)
    (hpq : p ≠ q) (h0 : 0 < a + b + c) (hlt : a + b + c < p * q)
    (hps : p ∣ a + b + c) : Nat.gcd (a + b + c) (p * q) = p :=
  reveal_of_pos_lt hp hq hpq h0 hlt hps

/-! ## Concrete census for `N = 143 = 11 * 13` -/

/-- Strictly increasing triples from `{1,…,12}` whose sum vanishes mod `11`. -/
def triples143 : Finset (ℕ × ℕ × ℕ) :=
  ((Finset.Icc 1 12) ×ˢ (Finset.Icc 1 12) ×ˢ (Finset.Icc 1 12)).filter
    (fun t => t.1 < t.2.1 ∧ t.2.1 < t.2.2 ∧ 11 ∣ (t.1 + t.2.1 + t.2.2))

set_option maxRecDepth 20000 in
/-- The mod-`11`-only census: there are `20` such triples. -/
theorem card_triples143 : triples143.card = 20 := by decide

set_option maxRecDepth 20000 in
/-- The mod-both census is empty. -/
theorem card_triples143_modBoth :
    (triples143.filter (fun t => 13 ∣ (t.1 + t.2.1 + t.2.2))).card = 0 := by decide

/-- **Every triple of the census reveals the factor `11` of `143`.**
Proved from the general theorem, not by enumeration. -/
theorem triples143_reveal (t : ℕ × ℕ × ℕ) (ht : t ∈ triples143) :
    Nat.gcd (t.1 + t.2.1 + t.2.2) 143 = 11 := by
  simp only [triples143, Finset.mem_filter, Finset.mem_product, Finset.mem_Icc] at ht
  obtain ⟨⟨⟨h1, h2⟩, ⟨h3, h4⟩, ⟨h5, h6⟩⟩, _, _, hdvd⟩ := ht
  have h143 : (143 : ℕ) = 11 * 13 := by norm_num
  rw [h143]
  exact reveal_of_pos_lt (by norm_num) (by norm_num) (by norm_num)
    (by omega) (by omega) hdvd

end ThreeSumFactoring