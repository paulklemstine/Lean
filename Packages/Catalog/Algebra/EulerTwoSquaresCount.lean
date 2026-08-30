import Algebra.EulerTwoSquaresCore

/-!
# The eligibility class of Euler's method: exactly two representations, or none

Euler's factorisation method needs **two essentially distinct** representations of `N` as a
sum of two squares.  For `N = p*q` a product of two distinct odd primes this file settles
exactly when such a pair exists, and how many representations there are:

* `EulerTwoSquares.exactly_two_reps` — if `p ≠ q` are primes with `p ≡ q ≡ 1 [MOD 4]`, then
  `p*q` has **exactly two** essentially distinct representations as a sum of two positive
  squares: there are explicit `A,B,C,D` such that the ordered positive representations are
  precisely `(A,B), (B,A), (C,D), (D,C)`.
* `EulerTwoSquares.no_rep_of_three_mod_four` — if some prime `r ≡ 3 [MOD 4]` divides `n`
  exactly once, then `n` has **no** representation at all.  This kills the classes
  `(1,3), (3,1), (3,3)` and `(2,3)` of the semiprime table.
* `EulerTwoSquares.euler_works_iff_both_one_mod_four` — the resulting dichotomy for
  `N = p*q` with `p ≠ q` odd primes: two essentially distinct representations exist iff both
  primes are `1 mod 4`.

The "at most two" half is proved by a *class argument* powered by the extraction theorem of
`EulerTwoSquaresCore`: fixing representations `p = e²+f²` and `q = g²+h²`, every
representation `(a,b)` of `p*q` gets a pair of bits

`(⟦p ∣ a f - b e⟧, ⟦q ∣ a h - b g⟧) ∈ Bool × Bool`,

two representations with the same bits have `N ∣ a₁b₂ - a₂b₁`, and then
`EulerTwoSquares.not_dvd_cross` forces them to be equal.  Since `Bool × Bool` has four
elements there are at most four ordered representations, i.e. at most two up to order — and
the Brahmagupta construction produces four.  So the count is exact.
-/

namespace EulerTwoSquares

set_option synthInstance.maxSize 1000 in
set_option synthInstance.maxHeartbeats 1000000 in
/-- Five pairwise distinct elements of `Bool × Bool` cannot exist. -/
theorem pigeonhole_four_classes :
    ∀ v₁ v₂ v₃ v₄ v₅ : Bool × Bool, v₁ ≠ v₂ → v₁ ≠ v₃ → v₁ ≠ v₄ → v₁ ≠ v₅ → v₂ ≠ v₃ →
      v₂ ≠ v₄ → v₂ ≠ v₅ → v₃ ≠ v₄ → v₃ ≠ v₅ → v₄ ≠ v₅ → False := by decide

/-! ## Elementary facts about representations of a prime -/

/-- A prime is not a perfect square. -/
theorem prime_ne_sq {p b : ℕ} (hp : p.Prime) : p ≠ b ^ 2 := by
  intro h
  have hb : b ∣ p := ⟨b, by rw [h]; ring⟩
  rcases hp.eq_one_or_self_of_dvd b hb with h1 | h1
  · rw [h1] at h; simp at h; exact absurd h hp.one_lt.ne'
  · rw [h1] at h; nlinarith [hp.two_le]

/-- Both parts of a two-square representation of a prime are positive. -/
theorem prime_rep_pos {p : ℕ} (hp : p.Prime) {a b : ℕ} (h : a ^ 2 + b ^ 2 = p) :
    0 < a ∧ 0 < b := by
  constructor
  · rcases Nat.eq_zero_or_pos a with ha | ha
    · exact absurd (by rw [ha] at h; simpa using h.symm) (prime_ne_sq (b := b) hp)
    · exact ha
  · rcases Nat.eq_zero_or_pos b with hb | hb
    · exact absurd (by rw [hb] at h; simpa using h.symm) (prime_ne_sq (b := a) hp)
    · exact hb

/-- A prime `p ≡ 1 [MOD 4]` is a sum of two *distinct* positive squares. -/
theorem exists_prime_rep {p : ℕ} (hp : p.Prime) (hp4 : p % 4 = 1) :
    ∃ e f : ℤ, 0 < e ∧ 0 < f ∧ e ≠ f ∧ e ^ 2 + f ^ 2 = (p : ℤ) := by
  haveI := Fact.mk hp
  obtain ⟨a, b, hab⟩ := Nat.Prime.sq_add_sq (p := p) (by omega)
  obtain ⟨ha, hb⟩ := prime_rep_pos hp hab
  refine ⟨(a : ℤ), (b : ℤ), by exact_mod_cast ha, by exact_mod_cast hb, ?_, by exact_mod_cast hab⟩
  intro hEq
  have hab' : a = b := by exact_mod_cast hEq
  subst hab'
  have h2 : 2 ∣ p := ⟨a ^ 2, by omega⟩
  have : 2 = p := (Nat.prime_dvd_prime_iff_eq Nat.prime_two hp).1 h2
  omega

/-- A prime does not divide either part of one of its two-square representations. -/
theorem prime_not_dvd_part {p : ℕ} {e f : ℤ} (he : 0 < e) (hf : 0 < f)
    (h : e ^ 2 + f ^ 2 = (p : ℤ)) : ¬ ((p : ℤ) ∣ e) := by
  intro hdvd
  have hlt : e < (p : ℤ) := by nlinarith
  have := Int.le_of_dvd he hdvd
  omega

/-! ## The class bits attached to a representation -/

variable {p q : ℕ}

/-- For a representation `p = e² + f²` and a representation `a² + b² = p*q`, the prime `p`
divides one of the two "cross terms" `a f ∓ b e`. -/
theorem prime_dvd_cross_or (hp : p.Prime) {e f a b : ℤ}
    (hef : e ^ 2 + f ^ 2 = (p : ℤ)) (hab : a ^ 2 + b ^ 2 = (p : ℤ) * q) :
    (p : ℤ) ∣ (a * f - b * e) ∨ (p : ℤ) ∣ (a * f + b * e) := by
  have hprod : (p : ℤ) ∣ (a * f - b * e) * (a * f + b * e) :=
    ⟨f ^ 2 * q - b ^ 2, by linear_combination f ^ 2 * hab - b ^ 2 * hef⟩
  exact (Nat.prime_iff_prime_int.mp hp).2.2 _ _ hprod

/-- ... and it divides exactly one of them. -/
theorem prime_not_dvd_cross_both (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q) (hp4 : p % 4 = 1)
    {e f a b : ℤ} (he : 0 < e) (hf : 0 < f)
    (hef : e ^ 2 + f ^ 2 = (p : ℤ)) (hab : a ^ 2 + b ^ 2 = (p : ℤ) * q) :
    ¬ ((p : ℤ) ∣ (a * f - b * e) ∧ (p : ℤ) ∣ (a * f + b * e)) := by
  rintro ⟨h1, h2⟩
  have hpi : Prime (p : ℤ) := Nat.prime_iff_prime_int.mp hp
  have hpe : ¬ ((p : ℤ) ∣ e) := prime_not_dvd_part he hf hef
  have hpf : ¬ ((p : ℤ) ∣ f) := prime_not_dvd_part hf he (by linarith)
  have hp2 : ¬ ((p : ℤ) ∣ 2) := by
    intro hd
    have h' : (p : ℤ) ≤ 2 := Int.le_of_dvd (by norm_num) hd
    have h'' : p ≤ 2 := by exact_mod_cast h'
    have := hp.two_le
    omega
  have h2af : (p : ℤ) ∣ 2 * (a * f) := by
    have hrw : 2 * (a * f) = (a * f - b * e) + (a * f + b * e) := by ring
    rw [hrw]; exact dvd_add h1 h2
  have h2be : (p : ℤ) ∣ 2 * (b * e) := by
    have hrw : 2 * (b * e) = (a * f + b * e) - (a * f - b * e) := by ring
    rw [hrw]; exact dvd_sub h2 h1
  have ha : (p : ℤ) ∣ a :=
    (hpi.dvd_mul.1 ((hpi.dvd_mul.1 h2af).resolve_left hp2)).resolve_right hpf
  have hb : (p : ℤ) ∣ b :=
    (hpi.dvd_mul.1 ((hpi.dvd_mul.1 h2be).resolve_left hp2)).resolve_right hpe
  obtain ⟨a', rfl⟩ := ha
  obtain ⟨b', rfl⟩ := hb
  have hpne : (p : ℤ) ≠ 0 := by
    have := hp.two_le; positivity
  have hcancel : (p : ℤ) * ((p : ℤ) * (a' ^ 2 + b' ^ 2)) = (p : ℤ) * (q : ℤ) := by
    linear_combination hab
  have hq' : (p : ℤ) * (a' ^ 2 + b' ^ 2) = (q : ℤ) := mul_left_cancel₀ hpne hcancel
  have hpdq : (p : ℤ) ∣ (q : ℤ) := ⟨a' ^ 2 + b' ^ 2, hq'.symm⟩
  have : p ∣ q := by exact_mod_cast hpdq
  exact hpq ((Nat.prime_dvd_prime_iff_eq hp hq).1 this)

/-- Two representations of `p*q` with the same `p`-bit satisfy `p ∣ a₁b₂ - a₂b₁`. -/
theorem cross_dvd_of_same_class (hp : p.Prime) {e f a₁ b₁ a₂ b₂ : ℤ} (he : 0 < e) (hf : 0 < f)
    (hef : e ^ 2 + f ^ 2 = (p : ℤ)) (hr1 : a₁ ^ 2 + b₁ ^ 2 = (p : ℤ) * q)
    (hr2 : a₂ ^ 2 + b₂ ^ 2 = (p : ℤ) * q)
    (hsame : ((p : ℤ) ∣ (a₁ * f - b₁ * e)) ↔ ((p : ℤ) ∣ (a₂ * f - b₂ * e))) :
    (p : ℤ) ∣ (a₁ * b₂ - a₂ * b₁) := by
  have hpi : Prime (p : ℤ) := Nat.prime_iff_prime_int.mp hp
  have hpf : ¬ ((p : ℤ) ∣ f) := prime_not_dvd_part hf he (by linarith)
  have key : (p : ℤ) ∣ (a₁ * b₂ - a₂ * b₁) * f := by
    by_cases h1 : (p : ℤ) ∣ (a₁ * f - b₁ * e)
    · have h2 := hsame.1 h1
      have hrw : (a₁ * b₂ - a₂ * b₁) * f = b₂ * (a₁ * f - b₁ * e) - b₁ * (a₂ * f - b₂ * e) := by
        ring
      rw [hrw]; exact dvd_sub (h1.mul_left b₂) (h2.mul_left b₁)
    · have h2 : ¬ ((p : ℤ) ∣ (a₂ * f - b₂ * e)) := fun hh => h1 (hsame.2 hh)
      have h1' := (prime_dvd_cross_or (q := q) hp hef hr1).resolve_left h1
      have h2' := (prime_dvd_cross_or (q := q) hp hef hr2).resolve_left h2
      have hrw : (a₁ * b₂ - a₂ * b₁) * f = b₂ * (a₁ * f + b₁ * e) - b₁ * (a₂ * f + b₂ * e) := by
        ring
      rw [hrw]; exact dvd_sub (h1'.mul_left b₂) (h2'.mul_left b₁)
  exact (hpi.dvd_mul.1 key).resolve_right hpf

/-- **Injectivity of the class map.**  Two positive representations of `p*q` carrying the same
pair of class bits are equal. -/
theorem rep_eq_of_same_classes (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q)
    {e f g h a₁ b₁ a₂ b₂ : ℤ} (he : 0 < e) (hf : 0 < f) (hg : 0 < g) (hh : 0 < h)
    (hef : e ^ 2 + f ^ 2 = (p : ℤ)) (hgh : g ^ 2 + h ^ 2 = (q : ℤ))
    (ha₁ : 0 < a₁) (hb₁ : 0 < b₁) (ha₂ : 0 < a₂) (hb₂ : 0 < b₂)
    (hr1 : a₁ ^ 2 + b₁ ^ 2 = (p : ℤ) * q) (hr2 : a₂ ^ 2 + b₂ ^ 2 = (p : ℤ) * q)
    (hsp : ((p : ℤ) ∣ (a₁ * f - b₁ * e)) ↔ ((p : ℤ) ∣ (a₂ * f - b₂ * e)))
    (hsq : ((q : ℤ) ∣ (a₁ * h - b₁ * g)) ↔ ((q : ℤ) ∣ (a₂ * h - b₂ * g))) :
    a₂ = a₁ ∧ b₂ = b₁ := by
  have hdp : (p : ℤ) ∣ (a₁ * b₂ - a₂ * b₁) :=
    cross_dvd_of_same_class (q := q) hp he hf hef hr1 hr2 hsp
  have hr1' : a₁ ^ 2 + b₁ ^ 2 = (q : ℤ) * p := by rw [hr1]; ring
  have hr2' : a₂ ^ 2 + b₂ ^ 2 = (q : ℤ) * p := by rw [hr2]; ring
  have hdq : (q : ℤ) ∣ (a₁ * b₂ - a₂ * b₁) :=
    cross_dvd_of_same_class (q := p) hq hg hh hgh hr1' hr2' hsq
  have hcop : IsCoprime ((p : ℤ)) ((q : ℤ)) := by
    rw [Int.isCoprime_iff_gcd_eq_one]
    simpa using (Nat.coprime_primes hp hq).2 hpq
  have hdvd : ((p : ℤ) * q) ∣ (a₁ * b₂ - a₂ * b₁) := hcop.mul_dvd hdp hdq
  by_contra hcon
  have hN : a₂ ^ 2 + b₂ ^ 2 = a₁ ^ 2 + b₁ ^ 2 := by rw [hr1, hr2]
  refine not_dvd_cross ha₁ hb₁ ha₂ hb₂ hN hcon ?_
  rw [hr1]
  have hrw : a₁ * b₂ - b₁ * a₂ = a₁ * b₂ - a₂ * b₁ := by ring
  rw [hrw]
  exact hdvd

/-! ## The Brahmagupta construction: four ordered representations -/

/-- A product of two distinct primes is never a perfect square. -/
theorem prime_mul_prime_ne_sq (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q) {A : ℤ} :
    A ^ 2 ≠ (p : ℤ) * q := by
  intro hA
  have hpi : Prime (p : ℤ) := Nat.prime_iff_prime_int.mp hp
  have hdvd : (p : ℤ) ∣ A ^ 2 := ⟨(q : ℤ), hA⟩
  have hpA : (p : ℤ) ∣ A := hpi.dvd_of_dvd_pow hdvd
  obtain ⟨k, rfl⟩ := hpA
  have hpne : (p : ℤ) ≠ 0 := by have := hp.two_le; positivity
  have hcancel : (p : ℤ) * ((p : ℤ) * k ^ 2) = (p : ℤ) * (q : ℤ) := by linear_combination hA
  have hq' : (p : ℤ) * k ^ 2 = (q : ℤ) := mul_left_cancel₀ hpne hcancel
  have hpdq : (p : ℤ) ∣ (q : ℤ) := ⟨k ^ 2, hq'.symm⟩
  have : p ∣ q := by exact_mod_cast hpdq
  exact hpq ((Nat.prime_dvd_prime_iff_eq hp hq).1 this)

/-- The Brahmagupta–Fibonacci construction applied to representations of `p` and `q`
produces four pairwise distinct ordered representations of `p*q`. -/
theorem exists_four_reps (hp : p.Prime) (hq : q.Prime) (hp4 : p % 4 = 1) (hq4 : q % 4 = 1)
    (hpq : p ≠ q) :
    ∃ e f g h A B C D : ℤ,
      (0 < e ∧ 0 < f ∧ 0 < g ∧ 0 < h ∧ e ^ 2 + f ^ 2 = (p : ℤ) ∧ g ^ 2 + h ^ 2 = (q : ℤ)) ∧
      (0 < A ∧ 0 < B ∧ 0 < C ∧ 0 < D) ∧
      (A ^ 2 + B ^ 2 = (p : ℤ) * q ∧ C ^ 2 + D ^ 2 = (p : ℤ) * q) ∧
      (A ≠ B ∧ A ≠ C ∧ A ≠ D ∧ B ≠ C ∧ B ≠ D ∧ C ≠ D) := by
  obtain ⟨e, f, he, hf, hef', hef⟩ := exists_prime_rep hp hp4
  obtain ⟨g, h, hg, hh, hgh', hgh⟩ := exists_prime_rep hq hq4
  have hid1 : (e * g + f * h) ^ 2 + (e * h - f * g) ^ 2 = (p : ℤ) * q := by
    linear_combination (g ^ 2 + h ^ 2) * hef + (p : ℤ) * hgh
  have hid2 : (e * g - f * h) ^ 2 + (e * h + f * g) ^ 2 = (p : ℤ) * q := by
    linear_combination (g ^ 2 + h ^ 2) * hef + (p : ℤ) * hgh
  have hu : e * h - f * g ≠ 0 := by
    intro hz
    rw [hz] at hid1
    exact prime_mul_prime_ne_sq hp hq hpq (A := e * g + f * h) (by linarith)
  have hv : e * g - f * h ≠ 0 := by
    intro hz
    rw [hz] at hid2
    exact prime_mul_prime_ne_sq hp hq hpq (A := e * h + f * g) (by linarith)
  have hAB : (e * g + f * h) ^ 2 + |e * h - f * g| ^ 2 = (p : ℤ) * q := by rw [sq_abs]; exact hid1
  have hCD : |e * g - f * h| ^ 2 + (e * h + f * g) ^ 2 = (p : ℤ) * q := by rw [sq_abs]; exact hid2
  have hApos : (0:ℤ) < e * g + f * h := by positivity
  have hDpos : (0:ℤ) < e * h + f * g := by positivity
  have hBpos : (0:ℤ) < |e * h - f * g| := abs_pos.2 hu
  have hCpos : (0:ℤ) < |e * g - f * h| := abs_pos.2 hv
  -- `p*q` is odd, so a representation never has two equal parts
  have hodd : ∀ X : ℤ, X ^ 2 + X ^ 2 ≠ (p : ℤ) * q := by
    intro X hX
    have h2 : (2 : ℤ) ∣ ((p * q : ℕ) : ℤ) := ⟨X ^ 2, by push_cast; linarith⟩
    have h2' : 2 ∣ p * q := by exact_mod_cast h2
    rcases (Nat.Prime.dvd_mul Nat.prime_two).1 h2' with hd | hd
    · have := (Nat.prime_dvd_prime_iff_eq Nat.prime_two hp).1 hd; omega
    · have := (Nat.prime_dvd_prime_iff_eq Nat.prime_two hq).1 hd; omega
  have hACne : e * g + f * h ≠ |e * g - f * h| := by
    have : |e * g - f * h| < e * g + f * h := by
      rw [abs_lt]; constructor <;> nlinarith
    linarith
  have hBDne : |e * h - f * g| ≠ e * h + f * g := by
    have : |e * h - f * g| < e * h + f * g := by
      rw [abs_lt]; constructor <;> nlinarith
    linarith
  have hADne : e * g + f * h ≠ e * h + f * g := by
    intro hEq
    have hz : (e - f) * (g - h) = 0 := by linear_combination hEq
    rcases mul_eq_zero.1 hz with hz' | hz'
    · exact hef' (by linarith)
    · exact hgh' (by linarith)
  refine ⟨e, f, g, h, e * g + f * h, |e * h - f * g|, |e * g - f * h|, e * h + f * g,
    ⟨he, hf, hg, hh, hef, hgh⟩, ⟨hApos, hBpos, hCpos, hDpos⟩, ⟨hAB, hCD⟩,
    ?_, hACne, hADne, ?_, hBDne, ?_⟩
  · -- `A ≠ B`
    intro hEq
    exact hodd |e * h - f * g| (by rw [hEq] at hAB; exact hAB)
  · -- `B ≠ C`
    intro hEq
    have hAD : (e * g + f * h) ^ 2 = (e * h + f * g) ^ 2 := by rw [hEq] at hAB; linarith [hCD]
    exact hADne (by nlinarith [hApos, hDpos])
  · -- `C ≠ D`
    intro hEq
    exact hodd (e * h + f * g) (by rw [hEq] at hCD; exact hCD)

/-! ## Exactly two representations -/

/-- **Exactly two essentially distinct representations.**  For distinct primes
`p ≡ q ≡ 1 [MOD 4]`, the number `p*q` has exactly two representations as a sum of two positive
squares up to order: there are `A,B,C,D` with `A²+B² = C²+D² = p*q`, essentially distinct, and
*every* representation of `p*q` by two positive squares is `(A,B)`, `(B,A)`, `(C,D)` or
`(D,C)`. -/
theorem exactly_two_reps (hp : p.Prime) (hq : q.Prime) (hp4 : p % 4 = 1) (hq4 : q % 4 = 1)
    (hpq : p ≠ q) :
    ∃ A B C D : ℤ, 0 < A ∧ 0 < B ∧ 0 < C ∧ 0 < D ∧
      A ^ 2 + B ^ 2 = (p : ℤ) * q ∧ C ^ 2 + D ^ 2 = (p : ℤ) * q ∧
      ¬(C = A ∧ D = B) ∧ ¬(D = A ∧ C = B) ∧
      ∀ a b : ℤ, 0 < a → 0 < b → a ^ 2 + b ^ 2 = (p : ℤ) * q →
        (a = A ∧ b = B) ∨ (a = B ∧ b = A) ∨ (a = C ∧ b = D) ∨ (a = D ∧ b = C) := by
  obtain ⟨e, f, g, h, A, B, C, D, ⟨he, hf, hg, hh, hef, hgh⟩, ⟨hA, hB, hC, hD⟩, ⟨hAB, hCD⟩,
    hAneB, hAneC, hAneD, hBneC, hBneD, hCneD⟩ := exists_four_reps hp hq hp4 hq4 hpq
  have hBA : B ^ 2 + A ^ 2 = (p : ℤ) * q := by linarith
  have hDC : D ^ 2 + C ^ 2 = (p : ℤ) * q := by linarith
  refine ⟨A, B, C, D, hA, hB, hC, hD, hAB, hCD, fun hx => hAneC hx.1.symm,
    fun hx => hAneD hx.1.symm, ?_⟩
  intro a b ha hb hab
  by_contra hcon
  have key : ∀ x₁ y₁ x₂ y₂ : ℤ, 0 < x₁ → 0 < y₁ → 0 < x₂ → 0 < y₂ →
      x₁ ^ 2 + y₁ ^ 2 = (p : ℤ) * q → x₂ ^ 2 + y₂ ^ 2 = (p : ℤ) * q → ¬(x₂ = x₁ ∧ y₂ = y₁) →
      ((decide ((p : ℤ) ∣ (x₁ * f - y₁ * e)), decide ((q : ℤ) ∣ (x₁ * h - y₁ * g))) :
          Bool × Bool) ≠
        (decide ((p : ℤ) ∣ (x₂ * f - y₂ * e)), decide ((q : ℤ) ∣ (x₂ * h - y₂ * g))) := by
    intro x₁ y₁ x₂ y₂ h1 h2 h3 h4 hr1 hr2 hne hEq
    exact hne (rep_eq_of_same_classes hp hq hpq he hf hg hh hef hgh h1 h2 h3 h4 hr1 hr2
      (decide_eq_decide.1 (congrArg Prod.fst hEq)) (decide_eq_decide.1 (congrArg Prod.snd hEq)))
  exact pigeonhole_four_classes _ _ _ _ _
    (key a b A B ha hb hA hB hab hAB (fun hx => hcon (Or.inl ⟨hx.1.symm, hx.2.symm⟩)))
    (key a b B A ha hb hB hA hab hBA (fun hx => hcon (Or.inr (Or.inl ⟨hx.1.symm, hx.2.symm⟩))))
    (key a b C D ha hb hC hD hab hCD
      (fun hx => hcon (Or.inr (Or.inr (Or.inl ⟨hx.1.symm, hx.2.symm⟩)))))
    (key a b D C ha hb hD hC hab hDC
      (fun hx => hcon (Or.inr (Or.inr (Or.inr ⟨hx.1.symm, hx.2.symm⟩)))))
    (key A B B A hA hB hB hA hAB hBA (fun hx => hAneB hx.1.symm))
    (key A B C D hA hB hC hD hAB hCD (fun hx => hAneC hx.1.symm))
    (key A B D C hA hB hD hC hAB hDC (fun hx => hAneD hx.1.symm))
    (key B A C D hB hA hC hD hBA hCD (fun hx => hBneC hx.1.symm))
    (key B A D C hB hA hD hC hBA hDC (fun hx => hBneD hx.1.symm))
    (key C D D C hC hD hD hC hCD hDC (fun hx => hCneD hx.1.symm))

/-! ## The empty cells: a prime `3 mod 4` to an odd power -/

/-- If a prime `r ≡ 3 [MOD 4]` divides `n` exactly once, then `n` is not a sum of two squares. -/
theorem no_rep_of_three_mod_four {r n : ℕ} (hr : r.Prime) (hr4 : r % 4 = 3) (hdvd : r ∣ n)
    (hsq : ¬ (r ^ 2 ∣ n)) (a b : ℤ) : a ^ 2 + b ^ 2 ≠ (n : ℤ) := by
  intro hab
  haveI := Fact.mk hr
  have hrn : (r : ℤ) ∣ (a ^ 2 + b ^ 2) := by
    rw [hab]; exact_mod_cast Int.natCast_dvd_natCast.2 hdvd
  have h0 : ((a : ZMod r)) ^ 2 + ((b : ZMod r)) ^ 2 = 0 := by
    have := (ZMod.intCast_zmod_eq_zero_iff_dvd (a ^ 2 + b ^ 2) r).2 hrn
    push_cast at this
    exact this
  have ha0 : ((a : ZMod r)) = 0 := by
    by_contra hne
    exact ZMod.mod_four_ne_three_of_sq_eq_neg_sq (y := (b : ZMod r)) hne
      (by linear_combination h0) hr4
  have hb0 : ((b : ZMod r)) = 0 := by
    by_contra hne
    exact ZMod.mod_four_ne_three_of_sq_eq_neg_sq' (x := (a : ZMod r)) hne
      (by linear_combination h0) hr4
  have hra : (r : ℤ) ∣ a := (ZMod.intCast_zmod_eq_zero_iff_dvd a r).1 ha0
  have hrb : (r : ℤ) ∣ b := (ZMod.intCast_zmod_eq_zero_iff_dvd b r).1 hb0
  obtain ⟨a', rfl⟩ := hra
  obtain ⟨b', rfl⟩ := hrb
  have : ((r : ℤ)) ^ 2 ∣ (n : ℤ) := ⟨a' ^ 2 + b' ^ 2, by linear_combination -hab⟩
  exact hsq (by exact_mod_cast this)

/-- **The dichotomy of the semiprime table.**  For distinct odd primes `p ≠ q`, the number
`p*q` admits two essentially distinct two-square representations (the input Euler's method
needs) if and only if both primes are `1 mod 4`.  In every other class the eligible set is
empty. -/
theorem euler_works_iff_both_one_mod_four (hp : p.Prime) (hq : q.Prime) (hp2 : p ≠ 2)
    (hq2 : q ≠ 2) (hpq : p ≠ q) :
    (∃ a b c d : ℤ, 0 < a ∧ 0 < b ∧ 0 < c ∧ 0 < d ∧ a ^ 2 + b ^ 2 = (p : ℤ) * q ∧
        c ^ 2 + d ^ 2 = (p : ℤ) * q ∧ ¬(c = a ∧ d = b) ∧ ¬(d = a ∧ c = b)) ↔
      (p % 4 = 1 ∧ q % 4 = 1) := by
  have hpodd : p % 4 = 1 ∨ p % 4 = 3 := by
    have : p % 2 = 1 := by
      rcases hp.eq_two_or_odd with h | h
      · exact absurd h hp2
      · exact h
    omega
  have hqodd : q % 4 = 1 ∨ q % 4 = 3 := by
    have : q % 2 = 1 := by
      rcases hq.eq_two_or_odd with h | h
      · exact absurd h hq2
      · exact h
    omega
  constructor
  · rintro ⟨a, b, c, d, ha, hb, hc, hd, hab, hcd, hne1, hne2⟩
    have hcast : a ^ 2 + b ^ 2 = ((p * q : ℕ) : ℤ) := by push_cast; exact hab
    constructor
    · rcases hpodd with h | h
      · exact h
      · exfalso
        refine no_rep_of_three_mod_four hp h (Dvd.intro q rfl) ?_ a b hcast
        intro hdvd
        have : p ∣ q := by
          have h2 : p * p ∣ p * q := by
            rcases hdvd with ⟨k, hk⟩; exact ⟨k, by rw [hk]; ring⟩
          exact (mul_dvd_mul_iff_left hp.pos.ne').1 h2
        exact hpq ((Nat.prime_dvd_prime_iff_eq hp hq).1 this)
    · rcases hqodd with h | h
      · exact h
      · exfalso
        refine no_rep_of_three_mod_four hq h (Dvd.intro_left p rfl) ?_ a b hcast
        intro hdvd
        have : q ∣ p := by
          have h2 : q * q ∣ q * p := by
            rcases hdvd with ⟨k, hk⟩; exact ⟨k, by rw [mul_comm q p, hk]; ring⟩
          exact (mul_dvd_mul_iff_left hq.pos.ne').1 h2
        exact hpq ((Nat.prime_dvd_prime_iff_eq hq hp).1 this).symm
  · rintro ⟨hp4, hq4⟩
    obtain ⟨A, B, C, D, hA, hB, hC, hD, hAB, hCD, h1, h2, -⟩ :=
      exactly_two_reps hp hq hp4 hq4 hpq
    exact ⟨A, B, C, D, hA, hB, hC, hD, hAB, hCD, h1, h2⟩

end EulerTwoSquares