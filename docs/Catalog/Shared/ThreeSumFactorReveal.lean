import Mathlib

set_option maxRecDepth 40000

/-!
# 3SUM modulo a prime factor reveals that factor

Let `N = p * q` be a semiprime.  Any natural number `s` with

* `0 < s < N`, and
* `p ∣ s`

satisfies `Nat.gcd s N = p`: the gcd *reveals* the factor `p`, and no side
condition `¬ q ∣ s` is needed — it is automatic, because `q ∣ s` together with
`p ∣ s` would force `N ∣ s`, contradicting `s < N`.

Applied to `s = a + b + c` this is the *3SUM mod-p factor reveal*: a triple whose
sum vanishes modulo `p` but whose integer sum is a nonzero number below `N`
produces `p` by one gcd computation.  The same argument is given for `r`-sums
(sums over an arbitrary `Finset`) and for *collisions*, where the revealing
quantity is a difference of two sums.

The final section contains machine-checked counts for `N = 143 = 11 * 13`
(Lab Notes).

Main results:

* `gcd_eq_prime_of_dvd_of_lt` — the reveal lemma.
* `threeSum_gcd_reveal` — 3SUM form.
* `sumFinset_gcd_reveal` — general `r`-sum form.
* `collision_gcd_reveal` — collision (difference of two sums) form.
* `threeSum_reveal_or_equal` — dichotomy for a modular collision of two triples.
-/

namespace ThreeSumReveal

/-! ## The reveal lemma -/

/-- **Factor reveal.**  If `N = p * q` is a product of two distinct primes and
`s` is a nonzero natural number below `N` divisible by `p`, then
`gcd s N = p`.  The hypothesis `¬ q ∣ s` usually imposed in the literature is
redundant: it follows from `s < N`. -/
theorem gcd_eq_prime_of_dvd_of_lt {p q s : ℕ} (hp : p.Prime) (hq : q.Prime)
    (hs0 : 0 < s) (hsN : s < p * q) (hps : p ∣ s) :
    Nat.gcd s (p * q) = p := by
  set N := p * q with hN
  set g := Nat.gcd s N with hg
  have hgN : g ∣ N := Nat.gcd_dvd_right _ _
  have hgs : g ∣ s := Nat.gcd_dvd_left _ _
  have hpg : p ∣ g := Nat.dvd_gcd hps ⟨q, rfl⟩
  obtain ⟨d, hd⟩ := hpg
  have hdq : d ∣ q := by
    have : p * d ∣ p * q := by rw [← hd]; exact hgN
    exact (mul_dvd_mul_iff_left (a := p) hp.ne_zero).mp this
  rcases (Nat.Prime.eq_one_or_self_of_dvd hq d hdq) with h1 | hqd
  · rw [hd, h1, mul_one]
  · exfalso
    have hgN' : g = N := by rw [hd, hqd]
    have : N ∣ s := hgN' ▸ hgs
    exact absurd (Nat.le_of_dvd hs0 this) (not_le.mpr hsN)

/-- **3SUM mod-`p` factor reveal.**  A triple `(a, b, c)` whose sum is divisible
by `p`, nonzero, and smaller than `N = p * q`, exposes `p` by a single gcd. -/
theorem threeSum_gcd_reveal {p q a b c : ℕ} (hp : p.Prime) (hq : q.Prime)
    (hpos : 0 < a + b + c) (hlt : a + b + c < p * q) (hdvd : p ∣ a + b + c) :
    Nat.gcd (a + b + c) (p * q) = p :=
  gcd_eq_prime_of_dvd_of_lt hp hq hpos hlt hdvd

/-- **`r`-SUM factor reveal.**  Same statement for a sum over an arbitrary index
set: the reveal phenomenon is not special to triples. -/
theorem sumFinset_gcd_reveal {ι : Type*} {s : Finset ι} {f : ι → ℕ} {p q : ℕ}
    (hp : p.Prime) (hq : q.Prime) (hpos : 0 < ∑ i ∈ s, f i)
    (hlt : (∑ i ∈ s, f i) < p * q) (hdvd : p ∣ ∑ i ∈ s, f i) :
    Nat.gcd (∑ i ∈ s, f i) (p * q) = p :=
  gcd_eq_prime_of_dvd_of_lt hp hq hpos hlt hdvd

/-- **Collision form.**  A *collision* `s ≡ t (mod p)` between two integer
quantities `t < s < N` reveals `p` through `gcd (s - t) N`.  This is the shape
produced by sumset (`a + b ≡ c + d`) and by 3SUM (`a + b + c ≡ d + e + f`)
searches. -/
theorem collision_gcd_reveal {p q s t : ℕ} (hp : p.Prime) (hq : q.Prime)
    (hts : t < s) (hlt : s < p * q) (hdvd : p ∣ s - t) :
    Nat.gcd (s - t) (p * q) = p := by
  refine gcd_eq_prime_of_dvd_of_lt hp hq (Nat.sub_pos_of_lt hts) ?_ hdvd
  exact lt_of_le_of_lt (Nat.sub_le _ _) hlt

/-- **Sumset collision (`a + b ≡ c + d`).**  If two pairs have congruent sums
modulo `p`, the smaller sum being strictly smaller as an integer, then the
difference reveals `p`. -/
theorem sumset_collision_reveal {p q a b c d : ℕ} (hp : p.Prime) (hq : q.Prime)
    (hlt : c + d < a + b) (hbound : a + b < p * q)
    (hcong : (a + b) % p = (c + d) % p) :
    Nat.gcd ((a + b) - (c + d)) (p * q) = p := by
  refine collision_gcd_reveal hp hq hlt hbound ?_
  exact (Nat.modEq_iff_dvd' hlt.le).mp hcong.symm

/-- **3SUM collision dichotomy.**  If two triples have congruent sums mod `p`
and both sums are below `N = p * q`, then either the collision is *trivial*
(the two integer sums agree, so no information is produced) or the gcd of the
difference is exactly `p`. -/
theorem threeSum_reveal_or_equal {p q a b c a' b' c' : ℕ} (hp : p.Prime)
    (hq : q.Prime) (hbound : a + b + c < p * q) (hbound' : a' + b' + c' < p * q)
    (hcong : (a + b + c) % p = (a' + b' + c') % p) :
    a + b + c = a' + b' + c' ∨
      Nat.gcd (max (a + b + c) (a' + b' + c') - min (a + b + c) (a' + b' + c'))
        (p * q) = p := by
  set s := a + b + c with hs
  set t := a' + b' + c' with ht
  rcases lt_trichotomy s t with h | h | h
  · right
    rw [max_eq_right h.le, min_eq_left h.le]
    exact collision_gcd_reveal hp hq h hbound' ((Nat.modEq_iff_dvd' h.le).mp hcong)
  · exact Or.inl h
  · right
    rw [max_eq_left h.le, min_eq_right h.le]
    exact collision_gcd_reveal hp hq h hbound ((Nat.modEq_iff_dvd' h.le).mp hcong.symm)

/-! ## No triple below `N` can be divisible by both factors

This is the structural reason the "mod-both" column of the experiment is empty. -/

/-- If `0 < s < p * q` with `p`, `q` distinct primes, then `s` cannot be
divisible by both `p` and `q`. -/
theorem not_dvd_both_of_lt {p q s : ℕ} (hp : p.Prime) (hq : q.Prime)
    (hpq : p ≠ q) (hs0 : 0 < s) (hsN : s < p * q) : ¬ (p ∣ s ∧ q ∣ s) := by
  rintro ⟨h1, h2⟩
  have : p * q ∣ s := Nat.Coprime.mul_dvd_of_dvd_of_dvd
    ((Nat.coprime_primes hp hq).mpr hpq) h1 h2
  exact absurd (Nat.le_of_dvd hs0 this) (not_le.mpr hsN)

/-! ## Lab Notes: `N = 143 = 11 * 13`

Machine-checked counts over all triples `1 ≤ a < b < c ≤ 12`:

* `19`-style census: `20` triples have `11 ∣ a + b + c` and `13 ∤ a + b + c`;
* `0` triples have both `11 ∣ a + b + c` and `13 ∣ a + b + c`
  (forced by `not_dvd_both_of_lt`, since every such sum is `< 143`).

(The count `20` is for the range `1 ≤ a < b < c ≤ 12`; for `1 ≤ a < b < c ≤ 11`
the count is `15`.  The exact range is what fixes the number.) -/

/-- Ordered triples `1 ≤ a < b < c ≤ n`, as a `Finset`. -/
def triples (n : ℕ) : Finset (ℕ × ℕ × ℕ) :=
  ((Finset.Icc 1 n) ×ˢ (Finset.Icc 1 n) ×ˢ (Finset.Icc 1 n)).filter
    (fun x => x.1 < x.2.1 ∧ x.2.1 < x.2.2)

/-- Sum of a triple. -/
def tsum (x : ℕ × ℕ × ℕ) : ℕ := x.1 + x.2.1 + x.2.2

/-- **Lab note (mod-`p`-only census).**  For `N = 143 = 11 * 13` there are `20`
triples `1 ≤ a < b < c ≤ 12` with `11 ∣ a+b+c` and `13 ∤ a+b+c`. -/
theorem census_143_modp_only :
    ((triples 12).filter (fun x => tsum x % 11 = 0 ∧ tsum x % 13 ≠ 0)).card = 20 := by
  decide

/-- **Lab note (mod-both census).**  No triple `1 ≤ a < b < c ≤ 12` has its sum
divisible by both `11` and `13`. -/
theorem census_143_mod_both :
    ((triples 12).filter (fun x => tsum x % 11 = 0 ∧ tsum x % 13 = 0)).card = 0 := by
  decide

/-- The mod-both census is empty *for every* range in which the sums stay below
`143`, not just by computation: this is the qualitative form of
`census_143_mod_both`. -/
theorem census_143_mod_both_reason (n : ℕ) (hn : 3 * n < 143) :
    ((triples n).filter (fun x => tsum x % 11 = 0 ∧ tsum x % 13 = 0)).card = 0 := by
  rw [Finset.card_eq_zero, Finset.filter_eq_empty_iff]
  rintro x hx ⟨h11, h13⟩
  simp only [triples, Finset.mem_filter, Finset.mem_product, Finset.mem_Icc] at hx
  obtain ⟨⟨⟨ha1, ha2⟩, ⟨hb1, hb2⟩, hc1, hc2⟩, -, -⟩ := hx
  refine not_dvd_both_of_lt (by norm_num) (by norm_num) (by norm_num)
    (show 0 < tsum x by simp only [tsum]; omega)
    (show tsum x < 11 * 13 by simp only [tsum]; omega)
    ⟨Nat.dvd_of_mod_eq_zero h11, Nat.dvd_of_mod_eq_zero h13⟩

/-- The reveal lemma in action on `N = 143`: `gcd (a+b+c) 143 = 11` for every
triple counted by `census_143_modp_only`. -/
theorem reveal_143 {a b c : ℕ} (h0 : 0 < a + b + c) (h : a + b + c < 143)
    (h11 : 11 ∣ a + b + c) : Nat.gcd (a + b + c) 143 = 11 := by
  have : (143 : ℕ) = 11 * 13 := by norm_num
  rw [this]
  exact threeSum_gcd_reveal (by norm_num) (by norm_num) h0 (by omega) h11

end ThreeSumReveal