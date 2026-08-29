import Cryptography.BerggrenModular.NullCone

/-!
# The ambient null: the Berggren hypotenuse stream cannot see primes `≡ 3 (mod 4)`

The modular-dynamics experiment (exp 555) reports that the mod-`N` Berggren orbit
*under-samples factor-revealing residues* relative to random Pythagorean points.
This file isolates a hard, exact structural reason for a large part of that
deficit, and proves it.

Every node of the Berggren tree is a **primitive** Pythagorean triple
(`Cryptography.BerggrenModular.NullCone.Prim_applyWord`).  A classical fact —
proved here from scratch — is that the hypotenuse of a primitive Pythagorean
triple has *only* prime divisors `≡ 1 (mod 4)`.  Consequently a "dive" that
inspects `gcd(c, N)` along the tree

* can never expose a prime factor `p ≡ 3 (mod 4)` of `N`, and
* is **completely blind** on Blum integers `N = pq`, `p ≡ q ≡ 3 (mod 4)` — the
  moduli used in Rabin/Blum–Blum–Shub and a positive-density share of RSA-like
  moduli — no matter how deep the traversal goes.

## Main results

* `hyp_not_even` — the hypotenuse of a primitive Pythagorean triple is odd.
* `prime_not_dvd_leg` — a prime dividing the hypotenuse divides neither leg.
* `prime_dvd_hyp_mod_four` — **every prime divisor of the hypotenuse of a
  primitive Pythagorean triple is `≡ 1 (mod 4)`.**
* `berggren_hyp_prime_divisors_one_mod_four` — the same for every node of the
  Berggren tree.
* `berggren_gcd_eq_one_of_all_prime_factors_three_mod_four` — the hypotenuse of
  every node is coprime to any modulus all of whose prime factors are `≡ 3 (4)`.
* `berggren_dive_blind_on_blum` — **Blum-integer immunity**: for `N = p*q` with
  `p ≡ q ≡ 3 (mod 4)` the hypotenuse dive reveals nothing at any depth.
* `berggren_dive_undersamples` — for `N = p*q` with `p ≡ 3 (mod 4)` the only
  factor the dive can ever return is `q`: half of the factor-revealing residues
  are structurally unreachable.
-/

namespace Cryptography
namespace BerggrenModular

/-! ## Primitive Pythagorean triples: the hypotenuse is `1 (mod 4)`-smooth -/

/-- The hypotenuse of a primitive Pythagorean triple is odd. -/
theorem hyp_not_even {a b c : ℤ} (hpy : a ^ 2 + b ^ 2 = c ^ 2)
    (hprim : ∀ d : ℤ, d ∣ a → d ∣ b → d ∣ c → IsUnit d) : ¬ ((2 : ℤ) ∣ c) := by
  rintro ⟨k, rfl⟩
  rcases Int.even_or_odd a with ⟨s, rfl⟩ | ⟨s, rfl⟩ <;>
    rcases Int.even_or_odd b with ⟨t, rfl⟩ | ⟨t, rfl⟩
  · have h := hprim 2 ⟨s, by ring⟩ ⟨t, by ring⟩ ⟨k, rfl⟩
    rw [Int.isUnit_iff] at h; omega
  · have h4 : (4 : ℤ) ∣ 1 := ⟨k ^ 2 - s ^ 2 - t ^ 2 - t, by linarith [hpy]⟩
    norm_num at h4
  · have h4 : (4 : ℤ) ∣ 1 := ⟨k ^ 2 - s ^ 2 - s - t ^ 2, by linarith [hpy]⟩
    norm_num at h4
  · have h4 : (4 : ℤ) ∣ 2 := ⟨k ^ 2 - s ^ 2 - s - t ^ 2 - t, by linarith [hpy]⟩
    norm_num at h4

/-- A prime dividing the hypotenuse of a primitive triple divides neither leg. -/
theorem prime_not_dvd_leg {a b c : ℤ} (hpy : a ^ 2 + b ^ 2 = c ^ 2)
    (hprim : ∀ d : ℤ, d ∣ a → d ∣ b → d ∣ c → IsUnit d)
    {p : ℕ} (hp : p.Prime) (hd : (p : ℤ) ∣ c) : ¬ ((p : ℤ) ∣ a) := by
  intro hda
  have hdb : (p : ℤ) ∣ b := by
    have hb2 : (p : ℤ) ∣ b ^ 2 := by
      have hbe : b ^ 2 = c ^ 2 - a ^ 2 := by linarith
      rw [hbe]
      exact dvd_sub (dvd_pow hd two_ne_zero) (dvd_pow hda two_ne_zero)
    exact Int.Prime.dvd_pow' (by exact_mod_cast hp) hb2
  have hu := hprim p hda hdb hd
  rw [Int.isUnit_iff] at hu
  have := hp.two_le
  omega

/-- Symmetric version: the prime divides neither leg. -/
theorem prime_not_dvd_leg' {a b c : ℤ} (hpy : a ^ 2 + b ^ 2 = c ^ 2)
    (hprim : ∀ d : ℤ, d ∣ a → d ∣ b → d ∣ c → IsUnit d)
    {p : ℕ} (hp : p.Prime) (hd : (p : ℤ) ∣ c) : ¬ ((p : ℤ) ∣ b) := by
  refine prime_not_dvd_leg (a := b) (b := a) (by linarith) ?_ hp hd
  intro d h1 h2 h3
  exact hprim d h2 h1 h3

/-- **The hypotenuse of a primitive Pythagorean triple is `1 (mod 4)`-smooth.**
Every prime divisor of `c` is congruent to `1` modulo `4`.  The proof: such a
prime is odd (else `2 ∣ c` contradicts primitivity mod `4`), it divides neither
leg, and `a² ≡ -b² (mod p)` with `b` invertible makes `-1` a square mod `p`. -/
theorem prime_dvd_hyp_mod_four {a b c : ℤ} (hpy : a ^ 2 + b ^ 2 = c ^ 2)
    (hprim : ∀ d : ℤ, d ∣ a → d ∣ b → d ∣ c → IsUnit d)
    {p : ℕ} (hp : p.Prime) (hd : (p : ℤ) ∣ c) : p % 4 = 1 := by
  haveI : Fact p.Prime := ⟨hp⟩
  have h2 : p ≠ 2 := by
    rintro rfl
    exact hyp_not_even hpy hprim (by exact_mod_cast hd)
  have hnb : ¬ ((p : ℤ) ∣ b) := prime_not_dvd_leg' hpy hprim hp hd
  have hc0 : ((c : ℤ) : ZMod p) = 0 := (ZMod.intCast_zmod_eq_zero_iff_dvd c p).2 hd
  have hA : ((a : ZMod p)) ^ 2 + ((b : ZMod p)) ^ 2 = 0 := by
    have h := congrArg (fun z : ℤ => ((z : ZMod p))) hpy
    push_cast at h
    rw [h, hc0]; ring
  have hbne : ((b : ZMod p)) ≠ 0 := fun h => hnb ((ZMod.intCast_zmod_eq_zero_iff_dvd b p).1 h)
  have hsq : IsSquare (-1 : ZMod p) := by
    refine ⟨(a : ZMod p) * ((b : ZMod p))⁻¹, ?_⟩
    field_simp
    linear_combination -hA
  have h3 := (ZMod.exists_sq_eq_neg_one_iff (p := p)).1 hsq
  have hodd : p % 2 = 1 := Nat.odd_iff.1 (hp.odd_of_ne_two h2)
  omega

/-! ## Transport to the Berggren tree -/

/-- The Pythagorean identity at every node of the Berggren tree. -/
theorem pyth_applyWord (u : List Move) :
    (applyWord u root).1 ^ 2 + (applyWord u root).2.1 ^ 2 = (applyWord u root).2.2 ^ 2 := by
  have h := lorentz_applyWord u
  simp only [lorentz] at h
  linarith

/-- **Every prime divisor of a Berggren hypotenuse is `≡ 1 (mod 4)`.** -/
theorem berggren_hyp_prime_divisors_one_mod_four (u : List Move) {p : ℕ} (hp : p.Prime)
    (hd : (p : ℤ) ∣ (applyWord u root).2.2) : p % 4 = 1 :=
  prime_dvd_hyp_mod_four (pyth_applyWord u) (Prim_applyWord u) hp hd

/-- The natural-number hypotenuse of a node of the Berggren tree. -/
def hypNat (u : List Move) : ℕ := (applyWord u root).2.2.toNat

theorem hypNat_pos (u : List Move) : 0 < hypNat u := by
  have h := (applyWord_valid u root_valid).2.2.1
  simpa [hypNat] using h

theorem coe_hypNat (u : List Move) : ((hypNat u : ℕ) : ℤ) = (applyWord u root).2.2 := by
  have h := (applyWord_valid u root_valid).2.2.1
  simp [hypNat, Int.toNat_of_nonneg h.le]

/-- Natural-number form: every prime factor of `hypNat u` is `≡ 1 (mod 4)`. -/
theorem hypNat_prime_factors_one_mod_four (u : List Move) {p : ℕ} (hp : p.Prime)
    (hd : p ∣ hypNat u) : p % 4 = 1 := by
  refine berggren_hyp_prime_divisors_one_mod_four u hp ?_
  rw [← coe_hypNat u]
  exact_mod_cast hd

/-! ## Blindness of the hypotenuse dive -/

/-- If every prime factor of `N` is `≡ 3 (mod 4)` then the hypotenuse of every
Berggren node is coprime to `N`: the `gcd` dive returns `1` forever. -/
theorem berggren_gcd_eq_one_of_all_prime_factors_three_mod_four (u : List Move) {N : ℕ}
    (hN : ∀ r : ℕ, r.Prime → r ∣ N → r % 4 = 3) : Nat.gcd (hypNat u) N = 1 := by
  by_contra hne
  obtain ⟨r, hr, hrd⟩ := Nat.exists_prime_and_dvd hne
  have h1 : r % 4 = 1 := hypNat_prime_factors_one_mod_four u hr (hrd.trans (Nat.gcd_dvd_left _ _))
  have h3 : r % 4 = 3 := hN r hr (hrd.trans (Nat.gcd_dvd_right _ _))
  omega

/-- A *Blum integer* in the sense used here: a product of two primes, each
`≡ 3 (mod 4)`.  These are exactly the Rabin / Blum–Blum–Shub moduli. -/
def IsBlum (N : ℕ) : Prop :=
  ∃ p q : ℕ, p.Prime ∧ q.Prime ∧ p % 4 = 3 ∧ q % 4 = 3 ∧ N = p * q

/-- **Blum-integer immunity of the Berggren hypotenuse dive.**  For a Blum
modulus the dive's `gcd` is identically `1`, at every node, at every depth: the
modular Berggren descent conveys *zero* information about the factorisation. -/
theorem berggren_dive_blind_on_blum {N : ℕ} (hN : IsBlum N) (u : List Move) :
    Nat.gcd (hypNat u) N = 1 := by
  obtain ⟨p, q, hp, hq, hp3, hq3, rfl⟩ := hN
  refine berggren_gcd_eq_one_of_all_prime_factors_three_mod_four u ?_
  intro r hr hrd
  rcases (Nat.Prime.dvd_mul hr).1 hrd with h | h
  · rw [(Nat.prime_dvd_prime_iff_eq hr hp).1 h]; exact hp3
  · rw [(Nat.prime_dvd_prime_iff_eq hr hq).1 h]; exact hq3

/-- Non-vacuity of `IsBlum`: `21 = 3·7` is a Blum integer, and the dive is blind
on it at every depth. -/
example : IsBlum 21 := ⟨3, 7, by norm_num, by norm_num, by norm_num, by norm_num, by norm_num⟩

example (u : List Move) : Nat.gcd (hypNat u) 21 = 1 :=
  berggren_dive_blind_on_blum
    ⟨3, 7, by norm_num, by norm_num, by norm_num, by norm_num, by norm_num⟩ u

/-- Sharpness: the blindness is caused by the residue `3 (mod 4)`, not by the
search.  For `N = 65 = 5·13` the dive already splits `N` at depth two: the node
`B₃B₂` has hypotenuse `85` and `gcd(85, 65) = 5`. -/
example : hypNat [Move.m3, Move.m2] = 85 := by decide

example : Nat.gcd (hypNat [Move.m3, Move.m2]) 65 = 5 := by decide

/-- Sharpness in the other direction: the `1 (mod 4)` law is a property of the
*hypotenuse* only.  The legs are unconstrained — the node `B₁(3,4,5) = (5,12,13)`
has a leg divisible by `3` — so a leg-based dive is not structurally blind on Blum
moduli.  It is still trial-division-class, by the counting theorems in
`Cryptography.BerggrenModular.TrialDivisionEquivalence`. -/
example : (3 : ℤ) ∣ (applyWord [Move.m1] root).2.1 := by decide

/-- **Structural under-sampling.**  If one of the two prime factors of `N = p*q`
is `≡ 3 (mod 4)`, the hypotenuse dive can never return `p`; the only nontrivial
gcd it can ever produce is `q`.  Half of the factor-revealing residue classes are
unreachable by the orbit. -/
theorem berggren_dive_undersamples {p : ℕ} (hp : p.Prime)
    (hp3 : p % 4 = 3) (u : List Move) : ¬ (p ∣ hypNat u) := by
  intro hd
  have := hypNat_prime_factors_one_mod_four u hp hd
  omega

/-- Consequently the dive's gcd on `N = p*q` (with `p ≡ 3 (4)`) is either `1` or
`q`; it never splits off the prime `p` when `p ≡ 3 (mod 4)`. -/
theorem berggren_dive_gcd_cases {p q : ℕ} (hp : p.Prime) (hq : q.Prime)
    (hp3 : p % 4 = 3) (u : List Move) :
    Nat.gcd (hypNat u) (p * q) = 1 ∨ Nat.gcd (hypNat u) (p * q) = q := by
  set g := Nat.gcd (hypNat u) (p * q) with hg
  have hgd : g ∣ p * q := Nat.gcd_dvd_right _ _
  have hnp : ¬ (p ∣ g) := fun h => berggren_dive_undersamples hp hp3 u
    (h.trans (Nat.gcd_dvd_left _ _))
  have hcop : Nat.Coprime g p := (Nat.Prime.coprime_iff_not_dvd hp).2 hnp |>.symm
  have hgq : g ∣ q := hcop.dvd_of_dvd_mul_left hgd
  exact (Nat.Prime.eq_one_or_self_of_dvd hq g hgq)

end BerggrenModular