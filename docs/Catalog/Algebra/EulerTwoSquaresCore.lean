import Mathlib

/-!
# Euler's factorization method: the exact algebra of the combination step

Euler's factorisation method takes an integer `N` presented in **two essentially different
ways** as a sum of two squares,

`N = a² + b² = c² + d²`,

and extracts a nontrivial factor of `N` from the *cross term* `a*d - b*c`, namely
`gcd(a*d - b*c, N)`.  Conceptually the cross term is `Im (z₁ * conj z₂)` for the two Gaussian
integers `z₁ = a + b i`, `z₂ = c + d i` of norm `N`.

This file proves the algebraic core of the method, **unconditionally on any primality
assumption**:

* `EulerTwoSquares.rigidity` — the rigidity lemma: `a*d = b*c` together with
  `a*c + b*d = a² + b²` forces `(c,d) = (a,b)`.  This is the equality case of
  Cauchy–Schwarz over `ℤ`, proved by pure linear algebra.
* `EulerTwoSquares.not_dvd_cross` — `N` never divides the cross term unless the two
  representations coincide.
* `EulerTwoSquares.not_isCoprime_cross` — the cross term is never coprime to `N` unless the
  two representations coincide after a swap.
* `EulerTwoSquares.euler_gcd_proper` — **the main theorem**: for positive `a,b,c,d` with
  `a² + b² = c² + d² = N` and the two representations essentially distinct,
  `1 < gcd(a*d - b*c, N) < N`.  So Euler's extraction *always* produces a proper nontrivial
  divisor; no primality, no smoothness, no genericity hypothesis is needed.
* `EulerTwoSquares.euler_extraction_semiprime` — for `N = p*q` a product of two primes the
  extracted divisor is exactly `p` or `q`.
* `EulerTwoSquares.prime_rep_unique` — as an immediate corollary, a prime has an essentially
  unique representation as a sum of two squares.

The proofs use only the two Brahmagupta–Fibonacci identities and integrality; in particular
they do not use unique factorisation in `ℤ[i]`.
-/

namespace EulerTwoSquares

/-! ## The two Brahmagupta–Fibonacci identities -/

/-- Brahmagupta–Fibonacci, "minus" branch. -/
theorem brahmagupta_sub (a b c d : ℤ) :
    (a ^ 2 + b ^ 2) * (c ^ 2 + d ^ 2) = (a * c + b * d) ^ 2 + (a * d - b * c) ^ 2 := by
  ring

/-- Brahmagupta–Fibonacci, "plus" branch. -/
theorem brahmagupta_add (a b c d : ℤ) :
    (a ^ 2 + b ^ 2) * (c ^ 2 + d ^ 2) = (a * c - b * d) ^ 2 + (a * d + b * c) ^ 2 := by
  ring

/-- The product of the two cross terms is a multiple of `a² + b²` whenever the two
representations have the same value: this is the divisibility that drives Euler's method. -/
theorem dvd_cross_mul_cross {a b c d : ℤ} (h : c ^ 2 + d ^ 2 = a ^ 2 + b ^ 2) :
    (a ^ 2 + b ^ 2) ∣ (a * d - b * c) * (a * d + b * c) :=
  ⟨a ^ 2 - c ^ 2, by linear_combination a ^ 2 * h⟩

/-! ## Rigidity: the equality case of Cauchy–Schwarz over `ℤ` -/

/-- **Rigidity.**  If the "imaginary part" `a*d - b*c` of `z₁ * conj z₂` vanishes and the
"real part" `a*c + b*d` attains the maximal value `a² + b²`, then `z₂ = z₁`.
Only `0 < a² + b²` is needed; no relation between the norms is assumed. -/
theorem rigidity {a b c d : ℤ} (hpos : 0 < a ^ 2 + b ^ 2) (hcross : a * d = b * c)
    (hdot : a * c + b * d = a ^ 2 + b ^ 2) : c = a ∧ d = b := by
  have hne : (a ^ 2 + b ^ 2) ≠ 0 := ne_of_gt hpos
  have hc : (a ^ 2 + b ^ 2) * c = (a ^ 2 + b ^ 2) * a := by
    linear_combination a * hdot - b * hcross
  have hca : c = a := mul_left_cancel₀ hne hc
  refine ⟨hca, ?_⟩
  rcases eq_or_ne b 0 with hb | hb
  · have ha : a ≠ 0 := by
      intro h; rw [h, hb] at hpos; simp at hpos
    have hd0 : a * d = 0 := by rw [hcross, hb]; ring
    have hdz := (mul_eq_zero.1 hd0).resolve_left ha
    rw [hdz, hb]
  · have hbd : b * d = b * b := by rw [hca] at hdot; linear_combination hdot
    exact mul_left_cancel₀ hb hbd

/-! ## The two failure modes are impossible -/

/-- The cross term is never divisible by `N` unless the two representations are literally
equal.  (Equivalently: `gcd(a*d - b*c, N) < N`.) -/
theorem not_dvd_cross {a b c d : ℤ} (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) (hd : 0 < d)
    (hN : c ^ 2 + d ^ 2 = a ^ 2 + b ^ 2) (hne : ¬(c = a ∧ d = b)) :
    ¬ (a ^ 2 + b ^ 2) ∣ (a * d - b * c) := by
  intro hdvd
  set N : ℤ := a ^ 2 + b ^ 2 with hNdef
  have hNpos : 0 < N := by positivity
  have key : (a * c + b * d) ^ 2 + (a * d - b * c) ^ 2 = N ^ 2 := by
    have := brahmagupta_sub a b c d
    rw [hN] at this
    linarith [this]
  obtain ⟨k, hk⟩ := hdvd
  have hk2 : (a * c + b * d) ^ 2 + N ^ 2 * k ^ 2 = N ^ 2 := by
    rw [hk] at key; linarith [key, sq_nonneg (N * k)]
  have hdotpos : 0 < a * c + b * d := by positivity
  have hkzero : k = 0 := by
    by_contra hk0
    have h1 : 1 ≤ k ^ 2 := by
      rcases lt_or_gt_of_ne hk0 with h | h
      · nlinarith
      · nlinarith
    nlinarith [sq_nonneg (a * c + b * d)]
  have hcross : a * d = b * c := by
    have : a * d - b * c = 0 := by rw [hk, hkzero, mul_zero]
    linarith
  have hdot : a * c + b * d = N := by
    have h0 : (a * c + b * d) ^ 2 = N ^ 2 := by
      rw [hk, hkzero, mul_zero] at key; linarith
    nlinarith [hdotpos, hNpos]
  exact hne (rigidity hNpos hcross hdot)

/-- The *conjugate* cross term `a*d + b*c` is never divisible by `N` unless the two
representations agree after a swap.  (Equivalently: `gcd(a*d + b*c, N) < N`.) -/
theorem not_dvd_cross_add {a b c d : ℤ} (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) (hd : 0 < d)
    (hN : c ^ 2 + d ^ 2 = a ^ 2 + b ^ 2) (hne : ¬(d = a ∧ c = b)) :
    ¬ (a ^ 2 + b ^ 2) ∣ (a * d + b * c) := by
  intro hdvd
  set N : ℤ := a ^ 2 + b ^ 2 with hNdef
  have hNpos : 0 < N := by positivity
  have key : (a * c - b * d) ^ 2 + (a * d + b * c) ^ 2 = N ^ 2 := by
    have := brahmagupta_add a b c d
    rw [hN] at this
    linarith [this]
  have hpos : 0 < a * d + b * c := by positivity
  have hle : N ≤ a * d + b * c := Int.le_of_dvd hpos hdvd
  have hge : a * d + b * c ≤ N := by nlinarith [sq_nonneg (a * c - b * d)]
  have heq : a * d + b * c = N := le_antisymm hge hle
  have hz : a * c - b * d = 0 := by
    have hsq : (a * c - b * d) ^ 2 = 0 := by rw [heq] at key; linarith
    exact pow_eq_zero_iff (n := 2) (by norm_num) |>.1 hsq
  exact hne (rigidity hNpos (by linarith) heq)

/-- The cross term is never coprime to `N` unless the two representations agree after a
swap.  (Equivalently: `1 < gcd(a*d - b*c, N)`.) -/
theorem not_isCoprime_cross {a b c d : ℤ} (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) (hd : 0 < d)
    (hN : c ^ 2 + d ^ 2 = a ^ 2 + b ^ 2) (hne : ¬(d = a ∧ c = b)) :
    ¬ IsCoprime (a * d - b * c) (a ^ 2 + b ^ 2) := fun hcop =>
  not_dvd_cross_add ha hb hc hd hN hne
    ((hcop.symm).dvd_of_dvd_mul_left (dvd_cross_mul_cross hN))

/-- Dually, the conjugate cross term is never coprime to `N` unless the two representations
are literally equal. -/
theorem not_isCoprime_cross_add {a b c d : ℤ} (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hd : 0 < d) (hN : c ^ 2 + d ^ 2 = a ^ 2 + b ^ 2) (hne : ¬(c = a ∧ d = b)) :
    ¬ IsCoprime (a * d + b * c) (a ^ 2 + b ^ 2) := fun hcop =>
  not_dvd_cross ha hb hc hd hN hne
    ((hcop.symm).dvd_of_dvd_mul_right (dvd_cross_mul_cross hN))

/-! ## Euler's extraction theorem -/

/-- **Euler's extraction theorem.**  If a positive integer `N` has two essentially distinct
representations `N = a² + b² = c² + d²` with all parts positive, then
`gcd(a*d - b*c, N)` is a *proper nontrivial* divisor of `N`.

The hypotheses are exactly "the two representations are essentially distinct": they are not
equal, and they are not equal after swapping the two squares. -/
theorem euler_gcd_proper {a b c d : ℤ} (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) (hd : 0 < d)
    (hN : c ^ 2 + d ^ 2 = a ^ 2 + b ^ 2) (hne1 : ¬(c = a ∧ d = b)) (hne2 : ¬(d = a ∧ c = b)) :
    1 < Int.gcd (a * d - b * c) (a ^ 2 + b ^ 2) ∧
      ((Int.gcd (a * d - b * c) (a ^ 2 + b ^ 2) : ℤ) < a ^ 2 + b ^ 2) := by
  set N : ℤ := a ^ 2 + b ^ 2 with hNdef
  have hNpos : 0 < N := by positivity
  set g : ℕ := Int.gcd (a * d - b * c) N with hg
  have hgdvdN : (g : ℤ) ∣ N := Int.gcd_dvd_right _ _
  have hgdvdc : (g : ℤ) ∣ (a * d - b * c) := Int.gcd_dvd_left _ _
  have hg1 : 1 < g := by
    rcases Nat.lt_or_ge 1 g with h | h
    · exact h
    · interval_cases g
      · exfalso
        have : N = 0 := by
          have := Int.gcd_eq_zero_iff.1 hg.symm
          exact this.2
        omega
      · exact absurd (Int.isCoprime_iff_gcd_eq_one.2 hg.symm)
          (not_isCoprime_cross ha hb hc hd hN hne2)
  refine ⟨hg1, ?_⟩
  rcases lt_or_eq_of_le (Int.le_of_dvd hNpos hgdvdN) with h | h
  · exact h
  · exfalso
    have hdvdN : N ∣ (a * d - b * c) := by rw [← h]; exact hgdvdc
    exact not_dvd_cross ha hb hc hd hN hne1 hdvdN

/-- **Uniqueness of the two-square representation of a prime.**  A direct corollary of
Euler's extraction theorem: a second essentially distinct representation would produce a
proper nontrivial divisor of the prime. -/
theorem prime_rep_unique {p : ℕ} (hp : p.Prime) {a b c d : ℤ} (ha : 0 < a) (hb : 0 < b)
    (hc : 0 < c) (hd : 0 < d) (h1 : a ^ 2 + b ^ 2 = (p : ℤ)) (h2 : c ^ 2 + d ^ 2 = (p : ℤ)) :
    (c = a ∧ d = b) ∨ (d = a ∧ c = b) := by
  by_contra hcon
  push_neg at hcon
  obtain ⟨hne1, hne2⟩ := hcon
  have hne1' : ¬(c = a ∧ d = b) := fun h => hne1 h.1 h.2
  have hne2' : ¬(d = a ∧ c = b) := fun h => hne2 h.1 h.2
  have hN : c ^ 2 + d ^ 2 = a ^ 2 + b ^ 2 := by rw [h1, h2]
  obtain ⟨hlow, hhigh⟩ := euler_gcd_proper ha hb hc hd hN hne1' hne2'
  set g : ℕ := Int.gcd (a * d - b * c) (a ^ 2 + b ^ 2) with hg
  have hgdvd : (g : ℤ) ∣ (a ^ 2 + b ^ 2) := Int.gcd_dvd_right _ _
  rw [h1] at hgdvd hhigh
  have : g ∣ p := by exact_mod_cast hgdvd
  rcases (Nat.Prime.eq_one_or_self_of_dvd hp g this) with h | h
  · omega
  · rw [h] at hhigh; simp at hhigh

/-- Divisors of a product of two primes. -/
theorem eq_of_dvd_prime_mul_prime {p q g : ℕ} (hp : p.Prime) (hq : q.Prime) (hg : g ∣ p * q)
    (h1 : 1 < g) (h2 : g < p * q) : g = p ∨ g = q := by
  rcases (Nat.Prime.eq_one_or_self_of_dvd hp (Nat.gcd g p) (Nat.gcd_dvd_right g p)) with hk | hk
  · -- `g` is coprime to `p`, hence divides `q`
    have hcop : Nat.Coprime g p := hk
    have : g ∣ q := (Nat.Coprime.dvd_of_dvd_mul_left hcop hg)
    rcases (Nat.Prime.eq_one_or_self_of_dvd hq g this) with h | h
    · omega
    · exact Or.inr h
  · -- `p ∣ g`
    have hpg : p ∣ g := hk ▸ Nat.gcd_dvd_left g p
    obtain ⟨m, hm⟩ := hpg
    have hmq : m ∣ q := by
      have : p * m ∣ p * q := hm ▸ hg
      exact (mul_dvd_mul_iff_left hp.pos.ne').1 this
    rcases (Nat.Prime.eq_one_or_self_of_dvd hq m hmq) with h | h
    · left; rw [hm, h, mul_one]
    · exfalso; rw [h] at hm; omega

/-- **Euler's method on a semiprime.**  Two essentially distinct representations of `N = p*q`
(`p`, `q` prime) produce, via a single gcd, one of the two prime factors. -/
theorem euler_extraction_semiprime {p q : ℕ} (hp : p.Prime) (hq : q.Prime) {a b c d : ℤ}
    (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) (hd : 0 < d)
    (h1 : a ^ 2 + b ^ 2 = (p * q : ℕ)) (h2 : c ^ 2 + d ^ 2 = (p * q : ℕ))
    (hne1 : ¬(c = a ∧ d = b)) (hne2 : ¬(d = a ∧ c = b)) :
    Int.gcd (a * d - b * c) (a ^ 2 + b ^ 2) = p ∨
      Int.gcd (a * d - b * c) (a ^ 2 + b ^ 2) = q := by
  have hN : c ^ 2 + d ^ 2 = a ^ 2 + b ^ 2 := by rw [h1, h2]
  obtain ⟨hlow, hhigh⟩ := euler_gcd_proper ha hb hc hd hN hne1 hne2
  set g : ℕ := Int.gcd (a * d - b * c) (a ^ 2 + b ^ 2) with hg
  have hgdvd : (g : ℤ) ∣ (a ^ 2 + b ^ 2) := Int.gcd_dvd_right _ _
  rw [h1] at hgdvd hhigh
  have hgN : g ∣ p * q := by exact_mod_cast hgdvd
  have hlt : g < p * q := by exact_mod_cast hhigh
  exact eq_of_dvd_prime_mul_prime hp hq hgN hlow hlt

/-- The conjugate form of Euler's extraction theorem: `gcd(a*d + b*c, N)` is also a proper
nontrivial divisor of `N`. -/
theorem euler_gcd_proper_add {a b c d : ℤ} (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) (hd : 0 < d)
    (hN : c ^ 2 + d ^ 2 = a ^ 2 + b ^ 2) (hne1 : ¬(c = a ∧ d = b)) (hne2 : ¬(d = a ∧ c = b)) :
    1 < Int.gcd (a * d + b * c) (a ^ 2 + b ^ 2) ∧
      ((Int.gcd (a * d + b * c) (a ^ 2 + b ^ 2) : ℤ) < a ^ 2 + b ^ 2) := by
  set N : ℤ := a ^ 2 + b ^ 2 with hNdef
  have hNpos : 0 < N := by positivity
  set g : ℕ := Int.gcd (a * d + b * c) N with hg
  have hgdvdN : (g : ℤ) ∣ N := Int.gcd_dvd_right _ _
  have hgdvdc : (g : ℤ) ∣ (a * d + b * c) := Int.gcd_dvd_left _ _
  have hg1 : 1 < g := by
    rcases Nat.lt_or_ge 1 g with h | h
    · exact h
    · interval_cases g
      · exfalso
        have hz : N = 0 := (Int.gcd_eq_zero_iff.1 hg.symm).2
        omega
      · exact absurd (Int.isCoprime_iff_gcd_eq_one.2 hg.symm)
          (not_isCoprime_cross_add ha hb hc hd hN hne1)
  refine ⟨hg1, ?_⟩
  rcases lt_or_eq_of_le (Int.le_of_dvd hNpos hgdvdN) with h | h
  · exact h
  · exfalso
    have hdvdN : N ∣ (a * d + b * c) := by rw [← h]; exact hgdvdc
    exact not_dvd_cross_add ha hb hc hd hN hne2 hdvdN

/-- **The two gcds recover the whole factorisation.**  For `N = p*q` a product of two distinct
primes, the two cross terms of a pair of essentially distinct representations produce the two
prime factors: `gcd(a*d - b*c, N) * gcd(a*d + b*c, N) = p*q`. -/
theorem euler_gcd_pair_factors {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q)
    {a b c d : ℤ} (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) (hd : 0 < d)
    (h1 : a ^ 2 + b ^ 2 = (p * q : ℕ)) (h2 : c ^ 2 + d ^ 2 = (p * q : ℕ))
    (hne1 : ¬(c = a ∧ d = b)) (hne2 : ¬(d = a ∧ c = b)) :
    Int.gcd (a * d - b * c) (a ^ 2 + b ^ 2) * Int.gcd (a * d + b * c) (a ^ 2 + b ^ 2) = p * q := by
  have hN : c ^ 2 + d ^ 2 = a ^ 2 + b ^ 2 := by rw [h1, h2]
  have hg1 := euler_extraction_semiprime hp hq ha hb hc hd h1 h2 hne1 hne2
  -- the conjugate gcd is also `p` or `q`
  have hg2 : Int.gcd (a * d + b * c) (a ^ 2 + b ^ 2) = p ∨
      Int.gcd (a * d + b * c) (a ^ 2 + b ^ 2) = q := by
    obtain ⟨hlow, hhigh⟩ := euler_gcd_proper_add ha hb hc hd hN hne1 hne2
    set g₂ : ℕ := Int.gcd (a * d + b * c) (a ^ 2 + b ^ 2) with hg₂
    have hgdvd : (g₂ : ℤ) ∣ (a ^ 2 + b ^ 2) := Int.gcd_dvd_right _ _
    rw [h1] at hgdvd hhigh
    exact eq_of_dvd_prime_mul_prime hp hq (by exact_mod_cast hgdvd) hlow (by exact_mod_cast hhigh)
  -- `N` divides the product of the two cross terms, so each prime divides one of the gcds
  have hprod : (a ^ 2 + b ^ 2) ∣ (a * d - b * c) * (a * d + b * c) := dvd_cross_mul_cross hN
  have key : ∀ r : ℕ, r.Prime → (r : ℤ) ∣ (a ^ 2 + b ^ 2) →
      r ∣ Int.gcd (a * d - b * c) (a ^ 2 + b ^ 2) ∨
        r ∣ Int.gcd (a * d + b * c) (a ^ 2 + b ^ 2) := by
    intro r hr hrN
    have hri : Prime (r : ℤ) := Nat.prime_iff_prime_int.mp hr
    rcases hri.2.2 _ _ (hrN.trans hprod) with h | h
    · left
      exact_mod_cast Int.dvd_gcd h hrN
    · right
      exact_mod_cast Int.dvd_gcd h hrN
  have hpN : (p : ℤ) ∣ (a ^ 2 + b ^ 2) := by rw [h1]; exact_mod_cast Dvd.intro q rfl
  have hqN : (q : ℤ) ∣ (a ^ 2 + b ^ 2) := by rw [h1]; exact_mod_cast Dvd.intro_left p rfl
  have hpdvd := key p hp hpN
  have hqdvd := key q hq hqN
  rcases hg1 with e1 | e1
  · rcases hg2 with e2 | e2
    · exfalso
      rcases hqdvd with hqd | hqd
      · rw [e1] at hqd; exact hpq ((Nat.prime_dvd_prime_iff_eq hq hp).1 hqd).symm
      · rw [e2] at hqd; exact hpq ((Nat.prime_dvd_prime_iff_eq hq hp).1 hqd).symm
    · rw [e1, e2]
  · rcases hg2 with e2 | e2
    · rw [e1, e2]; exact Nat.mul_comm q p
    · exfalso
      rcases hpdvd with hpd | hpd
      · rw [e1] at hpd; exact hpq ((Nat.prime_dvd_prime_iff_eq hp hq).1 hpd)
      · rw [e2] at hpd; exact hpq ((Nat.prime_dvd_prime_iff_eq hp hq).1 hpd)

/-! ## The degenerate boundary: representations with a zero part

Nothing in Euler's method really needs the parts to be strictly positive.  The only place
positivity was used above is the strict Cauchy–Schwarz step `0 < a*c + b*d`, and that step
survives on the boundary of the cone: if a scalar product degenerates then the two
representations are supported on complementary coordinates, which is exactly what the
essential-distinctness hypotheses forbid.  (Example: `25 = 5² + 0² = 3² + 4²`,
`gcd(5*4 - 0*3, 25) = 5`.) -/

/-- On the closed cone, the scalar product `a*c + b*d` of two essentially distinct
representations is still strictly positive. -/
theorem dot_pos_of_essentially_distinct {a b c d : ℤ} (ha : 0 ≤ a) (hb : 0 ≤ b) (hc : 0 ≤ c)
    (hd : 0 ≤ d) (hNpos : 0 < a ^ 2 + b ^ 2) (hN : c ^ 2 + d ^ 2 = a ^ 2 + b ^ 2)
    (hne2 : ¬(d = a ∧ c = b)) : 0 < a * c + b * d := by
  rcases lt_or_eq_of_le (by positivity : (0 : ℤ) ≤ a * c + b * d) with h | h
  · exact h
  exfalso
  have hac : a * c = 0 := by nlinarith [mul_nonneg ha hc, mul_nonneg hb hd]
  have hbd : b * d = 0 := by nlinarith [mul_nonneg ha hc, mul_nonneg hb hd]
  rcases mul_eq_zero.1 hac with ha0 | hc0
  · rcases mul_eq_zero.1 hbd with hb0 | hd0
    · rw [ha0, hb0] at hNpos; simp at hNpos
    · -- `a = 0`, `d = 0`: then `c² = b²` and the two representations are swaps
      have hcb : c = b := by
        have hfac : (c - b) * (c + b) = 0 := by rw [ha0, hd0] at hN; linarith
        rcases mul_eq_zero.1 hfac with h1 | h1
        · linarith
        · have : c = 0 := by linarith
          have : b = 0 := by linarith
          omega
      exact hne2 ⟨by rw [hd0, ha0], hcb⟩
  · rcases mul_eq_zero.1 hbd with hb0 | hd0
    · -- `c = 0`, `b = 0`: then `d² = a²`
      have hda : d = a := by
        have hfac : (d - a) * (d + a) = 0 := by rw [hc0, hb0] at hN; linarith
        rcases mul_eq_zero.1 hfac with h1 | h1
        · linarith
        · have : d = 0 := by linarith
          have : a = 0 := by linarith
          omega
      exact hne2 ⟨hda, by rw [hc0, hb0]⟩
    · rw [hc0, hd0] at hN; simp at hN; omega

/-- On the closed cone, the conjugate cross term `a*d + b*c` of two essentially distinct
representations is still strictly positive. -/
theorem cross_add_pos_of_essentially_distinct {a b c d : ℤ} (ha : 0 ≤ a) (hb : 0 ≤ b)
    (hc : 0 ≤ c) (hd : 0 ≤ d) (hNpos : 0 < a ^ 2 + b ^ 2) (hN : c ^ 2 + d ^ 2 = a ^ 2 + b ^ 2)
    (hne1 : ¬(c = a ∧ d = b)) : 0 < a * d + b * c := by
  rcases lt_or_eq_of_le (by positivity : (0 : ℤ) ≤ a * d + b * c) with h | h
  · exact h
  exfalso
  have had : a * d = 0 := by nlinarith [mul_nonneg ha hd, mul_nonneg hb hc]
  have hbc : b * c = 0 := by nlinarith [mul_nonneg ha hd, mul_nonneg hb hc]
  rcases mul_eq_zero.1 had with ha0 | hd0
  · rcases mul_eq_zero.1 hbc with hb0 | hc0
    · rw [ha0, hb0] at hNpos; simp at hNpos
    · -- `a = 0`, `c = 0`: then `d² = b²`
      have hdb : d = b := by
        have hfac : (d - b) * (d + b) = 0 := by rw [ha0, hc0] at hN; linarith
        rcases mul_eq_zero.1 hfac with h1 | h1
        · linarith
        · have : d = 0 := by linarith
          have : b = 0 := by linarith
          omega
      exact hne1 ⟨by rw [hc0, ha0], hdb⟩
  · rcases mul_eq_zero.1 hbc with hb0 | hc0
    · -- `d = 0`, `b = 0`: then `c² = a²`
      have hca : c = a := by
        have hfac : (c - a) * (c + a) = 0 := by rw [hd0, hb0] at hN; linarith
        rcases mul_eq_zero.1 hfac with h1 | h1
        · linarith
        · have : c = 0 := by linarith
          have : a = 0 := by linarith
          omega
      exact hne1 ⟨hca, by rw [hd0, hb0]⟩
    · rw [hc0, hd0] at hN; simp at hN; omega

/-- The cross term is not divisible by `N`, on the closed cone. -/
theorem not_dvd_cross_nonneg {a b c d : ℤ} (ha : 0 ≤ a) (hb : 0 ≤ b) (hc : 0 ≤ c) (hd : 0 ≤ d)
    (hNpos : 0 < a ^ 2 + b ^ 2) (hN : c ^ 2 + d ^ 2 = a ^ 2 + b ^ 2)
    (hne1 : ¬(c = a ∧ d = b)) (hne2 : ¬(d = a ∧ c = b)) :
    ¬ (a ^ 2 + b ^ 2) ∣ (a * d - b * c) := by
  intro hdvd
  set N : ℤ := a ^ 2 + b ^ 2 with hNdef
  have hdotpos : 0 < a * c + b * d :=
    dot_pos_of_essentially_distinct ha hb hc hd hNpos hN hne2
  have key : (a * c + b * d) ^ 2 + (a * d - b * c) ^ 2 = N ^ 2 := by
    have hbr := brahmagupta_sub a b c d
    rw [hN] at hbr
    linarith [hbr]
  obtain ⟨k, hk⟩ := hdvd
  have hkzero : k = 0 := by
    by_contra hk0
    have h1 : 1 ≤ k ^ 2 := by
      rcases lt_or_gt_of_ne hk0 with h | h
      · nlinarith
      · nlinarith
    rw [hk] at key
    nlinarith [sq_nonneg (a * c + b * d)]
  have hcross : a * d = b * c := by
    have hz : a * d - b * c = 0 := by rw [hk, hkzero, mul_zero]
    linarith
  have hdot : a * c + b * d = N := by
    have h0 : (a * c + b * d) ^ 2 = N ^ 2 := by
      rw [hk, hkzero, mul_zero] at key; linarith
    nlinarith [hdotpos, hNpos]
  exact hne1 (rigidity hNpos hcross hdot)

/-- The conjugate cross term is not divisible by `N`, on the closed cone. -/
theorem not_dvd_cross_add_nonneg {a b c d : ℤ} (ha : 0 ≤ a) (hb : 0 ≤ b) (hc : 0 ≤ c)
    (hd : 0 ≤ d) (hNpos : 0 < a ^ 2 + b ^ 2) (hN : c ^ 2 + d ^ 2 = a ^ 2 + b ^ 2)
    (hne1 : ¬(c = a ∧ d = b)) (hne2 : ¬(d = a ∧ c = b)) :
    ¬ (a ^ 2 + b ^ 2) ∣ (a * d + b * c) := by
  intro hdvd
  set N : ℤ := a ^ 2 + b ^ 2 with hNdef
  have hpos : 0 < a * d + b * c :=
    cross_add_pos_of_essentially_distinct ha hb hc hd hNpos hN hne1
  have key : (a * c - b * d) ^ 2 + (a * d + b * c) ^ 2 = N ^ 2 := by
    have hbr := brahmagupta_add a b c d
    rw [hN] at hbr
    linarith [hbr]
  have hle : N ≤ a * d + b * c := Int.le_of_dvd hpos hdvd
  have hge : a * d + b * c ≤ N := by nlinarith [sq_nonneg (a * c - b * d)]
  have heq : a * d + b * c = N := le_antisymm hge hle
  have hz : a * c - b * d = 0 := by
    have hsq : (a * c - b * d) ^ 2 = 0 := by rw [heq] at key; linarith
    exact pow_eq_zero_iff (n := 2) (by norm_num) |>.1 hsq
  exact hne2 (rigidity hNpos (by linarith) heq)

/-- **Euler's extraction theorem on the closed cone.**  The parts of the two representations
need only be non-negative: essential distinctness alone forces `gcd(a*d - b*c, N)` to be a
proper nontrivial divisor of `N`. -/
theorem euler_gcd_proper_nonneg {a b c d : ℤ} (ha : 0 ≤ a) (hb : 0 ≤ b) (hc : 0 ≤ c)
    (hd : 0 ≤ d) (hNpos : 0 < a ^ 2 + b ^ 2) (hN : c ^ 2 + d ^ 2 = a ^ 2 + b ^ 2)
    (hne1 : ¬(c = a ∧ d = b)) (hne2 : ¬(d = a ∧ c = b)) :
    1 < Int.gcd (a * d - b * c) (a ^ 2 + b ^ 2) ∧
      ((Int.gcd (a * d - b * c) (a ^ 2 + b ^ 2) : ℤ) < a ^ 2 + b ^ 2) := by
  set N : ℤ := a ^ 2 + b ^ 2 with hNdef
  set g : ℕ := Int.gcd (a * d - b * c) N with hg
  have hgdvdN : (g : ℤ) ∣ N := Int.gcd_dvd_right _ _
  have hgdvdc : (g : ℤ) ∣ (a * d - b * c) := Int.gcd_dvd_left _ _
  have hg1 : 1 < g := by
    rcases Nat.lt_or_ge 1 g with h | h
    · exact h
    · interval_cases g
      · exfalso
        have hz : N = 0 := (Int.gcd_eq_zero_iff.1 hg.symm).2
        omega
      · exfalso
        have hcop : IsCoprime (a * d - b * c) N := Int.isCoprime_iff_gcd_eq_one.2 hg.symm
        exact not_dvd_cross_add_nonneg ha hb hc hd hNpos hN hne1 hne2
          ((hcop.symm).dvd_of_dvd_mul_left (dvd_cross_mul_cross hN))
  refine ⟨hg1, ?_⟩
  rcases lt_or_eq_of_le (Int.le_of_dvd hNpos hgdvdN) with h | h
  · exact h
  · exfalso
    have hdvdN : N ∣ (a * d - b * c) := by rw [← h]; exact hgdvdc
    exact not_dvd_cross_nonneg ha hb hc hd hNpos hN hne1 hne2 hdvdN

end EulerTwoSquares