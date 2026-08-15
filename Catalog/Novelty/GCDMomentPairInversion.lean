import Mathlib
import Novelty.GCDMomentTraceWitness

/-!
# Inverting the gcd moments: which moment identifies the factorisation?

Companion to `Novelty.GCDMomentTraceWitness`.  There the gcd moment of a semiprime was shown
to be a polynomial `F_k(N, s)` in the modulus `N = pq` and the trace `s = p + q`.  Here we
study the *inversion problem* an adversary actually faces:

> given the modulus `N` and the observed value of the `k`-th gcd moment, how many candidate
> factorisations `N = a·b` (`2 ≤ a ≤ b`) reproduce that value?

For a candidate pair `(a,b)` the predicted moment is
`pairMoment k a b = a^k(b−1) + b^k(a−1) + (a−1)(b−1) + (ab)^k`, which for a genuine prime pair
agrees with `gcdMoment k (p*q)` (`pairMoment_eq_gcdMoment`).

## Main results

* `pairMoment_two_eq` — at `k = 2` the prediction depends on the pair only through `N` and the
  trace `a + b`.
* `pairMoment_two_collision_iff` — **exact collision law at `k = 2`**: two factorisations of the
  same `N` give the same second moment iff they have the same trace or *complementary* traces,
  `(a+b) + (c+d) = N − 1`.  This is the `s ↦ N − 1 − s` symmetry of the moment polynomial,
  now visible on genuine factorisations.
* `pairMoment_two_collision_28`, `pairMoment_two_collision_36` — the collision is not vacuous:
  `28 = 2·14 = 4·7` and `36 = 2·18 = 3·12` are honest counterexamples to identifiability
  at `k = 2`.
* `two_collision_classification` — **and these two are the only ones, over all moduli**: the
  collision equation forces `N ≤ 36`, after which a finite check finishes.
* `bracket_pos`, `pairMoment_three_identity`, `pairMoment_three_spread_strict` — **the third
  moment is strictly monotone in the spread of the factorisation**: if `a < c ≤ d < b` and
  `ab = cd`, then `pairMoment 3 c d < pairMoment 3 a b`.
* `pairMoment_three_injective` — consequently the third moment *does* identify the
  factorisation: no two distinct factorisations of the same `N` share a third moment.
  The `k = 2` ambiguity disappears at `k = 3`, with no size cut needed.
* `gcdMoment_three_identifies_factors` — the arithmetic payoff: for a semiprime `N = pq`, the
  observed third gcd moment singles out `(p,q)` among *all* nontrivial factorisations.

The contrast `k = 2` (ambiguous, needs the size cut `2s < N − 1`) versus `k = 3` (unambiguous)
is the correct form of the informal "root ambiguity" question: the ambiguity is real at `k = 2`
and disappears at `k = 3`, while the *cost* of computing the moment (Ω(N) gcds, and a variance
that grows like `N^{2k−1}`) only gets worse — which is why no member of the family factors.
-/

namespace GCDMoment

/-- The moment predicted by a candidate factorisation `N = a·b`. -/
def pairMoment (k : ℕ) (a b : ℤ) : ℤ :=
  a ^ k * (b - 1) + b ^ k * (a - 1) + (a - 1) * (b - 1) + (a * b) ^ k

/-- For a genuine prime pair the prediction is the true gcd moment. -/
theorem pairMoment_eq_gcdMoment {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q) (k : ℕ) :
    pairMoment k (p : ℤ) (q : ℤ) = (gcdMoment k (p * q) : ℤ) := by
  rw [gcdMoment_semiprime_four_terms hp hq hpq, pairMoment]; ring

/-! ### `k = 2`: the collision law -/

/-- At `k = 2` the predicted moment is a function of `N = ab` and the trace `a + b` alone. -/
theorem pairMoment_two_eq (a b : ℤ) :
    pairMoment 2 a b = (a * b) ^ 2 + 3 * (a * b) + 1 + (a * b - 1) * (a + b) - (a + b) ^ 2 := by
  rw [pairMoment]; ring

/-- **Exact collision law at `k = 2`.**  Two factorisations of the same modulus predict the same
second moment precisely when their traces agree or are complementary, `s + s' = N − 1`. -/
theorem pairMoment_two_collision_iff {a b c d : ℤ} (h : a * b = c * d) :
    pairMoment 2 a b = pairMoment 2 c d ↔ (a + b = c + d ∨ a + b + c + d = a * b - 1) := by
  rw [pairMoment_two_eq, pairMoment_two_eq, ← h]
  constructor
  · intro hEq
    have hfac : ((a + b) - (c + d)) * (a * b - 1 - (a + b) - (c + d)) = 0 := by linarith [hEq]
    rcases mul_eq_zero.1 hfac with h1 | h1
    · left; linarith
    · right; linarith
  · rintro (h1 | h1)
    · linear_combination (a * b - 1 - (a + b) - (c + d)) * h1
    · linear_combination (c + d - a - b) * h1

/-- The ambiguity at `k = 2` is real: `28 = 2·14 = 4·7`, and both factorisations predict the
same second moment. -/
theorem pairMoment_two_collision_28 :
    (2 : ℤ) * 14 = 4 * 7 ∧ pairMoment 2 2 14 = pairMoment 2 4 7 ∧ (2 : ℤ) ≠ 4 := by
  refine ⟨by norm_num, ?_, by norm_num⟩
  rw [pairMoment_two_eq, pairMoment_two_eq]; norm_num

/-- A second collision at `k = 2`: `36 = 2·18 = 3·12`. -/
theorem pairMoment_two_collision_36 :
    (2 : ℤ) * 18 = 3 * 12 ∧ pairMoment 2 2 18 = pairMoment 2 3 12 ∧ (2 : ℤ) ≠ 3 := by
  refine ⟨by norm_num, ?_, by norm_num⟩
  rw [pairMoment_two_eq, pairMoment_two_eq]; norm_num

/-- **Complete classification of the `k = 2` ambiguity.**  `N = 28 = 2·14 = 4·7` and
`N = 36 = 2·18 = 3·12` are the *only* second-moment collisions, over all moduli: the collision
equation `a + b + c + d = N − 1` forces `N ≤ 36`, and a finite check finishes. -/
theorem two_collision_classification {a b c d : ℕ} (ha : 2 ≤ a) (hab : a ≤ b)
    (hcd : c ≤ d) (hac : a < c) (hprod : a * b = c * d)
    (hcoll : pairMoment 2 (a : ℤ) (b : ℤ) = pairMoment 2 (c : ℤ) (d : ℤ)) :
    (a = 2 ∧ b = 14 ∧ c = 4 ∧ d = 7) ∨ (a = 2 ∧ b = 18 ∧ c = 3 ∧ d = 12) := by
  have hprodZ : (a : ℤ) * b = (c : ℤ) * d := by exact_mod_cast hprod
  rcases (pairMoment_two_collision_iff hprodZ).1 hcoll with h1 | h1
  · exfalso
    have hsum : a + b = c + d := by exact_mod_cast h1
    obtain ⟨h2, -⟩ := sum_prod_determines_pair hprod hsum hab hcd
    omega
  · have hsum : a + b + c + d + 1 = a * b := by
      have h0 : ((a + b + c + d : ℕ) : ℤ) = (a : ℤ) * b - 1 := by push_cast at h1 ⊢; linarith
      have h2 : ((a + b + c + d : ℕ) : ℤ) + 1 = ((a * b : ℕ) : ℤ) := by
        push_cast at h0 ⊢; linarith
      exact_mod_cast h2
    have hc3 : 3 ≤ c := by omega
    have h1' : 2 * (a + b) ≤ 4 + a * b := by nlinarith
    have h2' : 3 * (c + d) ≤ 9 + c * d := by nlinarith
    have hN36 : a * b ≤ 36 := by omega
    have haa : a * a ≤ 36 := by nlinarith
    have ha6 : a ≤ 6 := by nlinarith
    have hcc : c * c ≤ 36 := by nlinarith
    have hc6 : c ≤ 6 := by nlinarith
    interval_cases a <;> interval_cases c <;> omega

/-! ### `k = 3`: strict monotonicity in the spread, and identifiability -/

private lemma bracket_expand (p w n : ℤ) :
    (((2 + p) ^ 2 + (2 + p) * (3 + p + w) + (3 + p + w) ^ 2)
        * ((2 + p) ^ 2 + (2 + p) * (3 + p + w + n) + (3 + p + w + n) ^ 2) + (2 + p) ^ 2)
      + (85 + (88 * n + 11 * n ^ 2 + 176 * w + 86 * w * n + 8 * w * n ^ 2 + 86 * w ^ 2
        + 24 * w ^ 2 * n + w ^ 2 * n ^ 2 + 16 * w ^ 3 + 2 * w ^ 3 * n + w ^ 4 + 311 * p
        + 209 * p * n + 22 * p * n ^ 2 + 418 * p * w + 156 * p * w * n + 11 * p * w * n ^ 2
        + 156 * p * w ^ 2 + 33 * p * w ^ 2 * n + p * w ^ 2 * n ^ 2 + 22 * p * w ^ 3
        + 2 * p * w ^ 3 * n + p * w ^ 4 + 352 * p ^ 2 + 162 * p ^ 2 * n + 12 * p ^ 2 * n ^ 2
        + 324 * p ^ 2 * w + 81 * p ^ 2 * w * n + 3 * p ^ 2 * w * n ^ 2 + 81 * p ^ 2 * w ^ 2
        + 9 * p ^ 2 * w ^ 2 * n + 6 * p ^ 2 * w ^ 3 + 179 * p ^ 3 + 52 * p ^ 3 * n
        + 2 * p ^ 3 * n ^ 2 + 104 * p ^ 3 * w + 13 * p ^ 3 * w * n + 13 * p ^ 3 * w ^ 2
        + 43 * p ^ 4 + 6 * p ^ 4 * n + 12 * p ^ 4 * w + 4 * p ^ 5))
      = (2 + p) * (3 + p + w) * (3 + p + w + n) * ((2 + p) + (3 + p + w))
          * ((2 + p) + (3 + p + w + n)) := by
  ring

/-- The cubic bracket controlling the third moment is strictly positive on the admissible
range `2 ≤ a < c ≤ d`.  (Positivity fails at `a = 1`, i.e. for the trivial factorisation.) -/
theorem bracket_pos {a c d : ℤ} (ha : 2 ≤ a) (hac : a < c) (hcd : c ≤ d) :
    0 < a * c * d * (a + c) * (a + d) - (a ^ 2 + a * c + c ^ 2) * (a ^ 2 + a * d + d ^ 2)
      - a ^ 2 := by
  obtain ⟨p, hp, rfl⟩ : ∃ p : ℤ, 0 ≤ p ∧ a = 2 + p := ⟨a - 2, by linarith, by ring⟩
  obtain ⟨w, hw, rfl⟩ : ∃ w : ℤ, 0 ≤ w ∧ c = 3 + p + w := ⟨c - 3 - p, by linarith, by ring⟩
  obtain ⟨n, hn, rfl⟩ : ∃ n : ℤ, 0 ≤ n ∧ d = 3 + p + w + n :=
    ⟨d - 3 - p - w, by linarith, by ring⟩
  have h := bracket_expand p w n
  have hrest : (0 : ℤ) ≤ 88 * n + 11 * n ^ 2 + 176 * w + 86 * w * n + 8 * w * n ^ 2 + 86 * w ^ 2
      + 24 * w ^ 2 * n + w ^ 2 * n ^ 2 + 16 * w ^ 3 + 2 * w ^ 3 * n + w ^ 4 + 311 * p
      + 209 * p * n + 22 * p * n ^ 2 + 418 * p * w + 156 * p * w * n + 11 * p * w * n ^ 2
      + 156 * p * w ^ 2 + 33 * p * w ^ 2 * n + p * w ^ 2 * n ^ 2 + 22 * p * w ^ 3
      + 2 * p * w ^ 3 * n + p * w ^ 4 + 352 * p ^ 2 + 162 * p ^ 2 * n + 12 * p ^ 2 * n ^ 2
      + 324 * p ^ 2 * w + 81 * p ^ 2 * w * n + 3 * p ^ 2 * w * n ^ 2 + 81 * p ^ 2 * w ^ 2
      + 9 * p ^ 2 * w ^ 2 * n + 6 * p ^ 2 * w ^ 3 + 179 * p ^ 3 + 52 * p ^ 3 * n
      + 2 * p ^ 3 * n ^ 2 + 104 * p ^ 3 * w + 13 * p ^ 3 * w * n + 13 * p ^ 3 * w ^ 2
      + 43 * p ^ 4 + 6 * p ^ 4 * n + 12 * p ^ 4 * w + 4 * p ^ 5 := by positivity
  linarith

/-- The key algebraic identity: modulo the relation `ab = cd`, the difference of third moments
factors through the bracket, with the explicit cofactor `(c−a)(d−a)/a³`. -/
theorem pairMoment_three_identity {a b c d : ℤ} (h : a * b = c * d) :
    a ^ 3 * (pairMoment 3 a b - pairMoment 3 c d) =
      (c - a) * (d - a) * (a * c * d * (a + c) * (a + d)
        - (a ^ 2 + a * c + c ^ 2) * (a ^ 2 + a * d + d ^ 2) - a ^ 2) := by
  have h3 : (a * b) ^ 3 = (c * d) ^ 3 := by rw [h]
  simp only [pairMoment]
  linear_combination (a ^ 5 + a ^ 3 - a ^ 2) * h + (a ^ 3 + a - 1) * h3

/-- **Strict monotonicity in the spread.**  Among the factorisations of a fixed modulus, the
third moment strictly increases as the factorisation gets more lopsided. -/
theorem pairMoment_three_spread_strict {a b c d : ℤ} (ha : 2 ≤ a) (hac : a < c) (hcd : c ≤ d)
    (h : a * b = c * d) : pairMoment 3 c d < pairMoment 3 a b := by
  have hid := pairMoment_three_identity h
  have hbr := bracket_pos ha hac hcd
  have hca : 0 < c - a := by linarith
  have hda : 0 < d - a := by linarith
  have hpos : 0 < (c - a) * (d - a) * (a * c * d * (a + c) * (a + d)
      - (a ^ 2 + a * c + c ^ 2) * (a ^ 2 + a * d + d ^ 2) - a ^ 2) :=
    mul_pos (mul_pos hca hda) hbr
  have ha3 : 0 < a ^ 3 := by positivity
  nlinarith [hid, hpos, ha3]

/-- **Identifiability at `k = 3`.**  Two nontrivial factorisations of the same modulus with the
same third moment are equal.  In particular no size cut is needed at `k = 3`, in contrast with
`k = 2`. -/
theorem pairMoment_three_injective {a b c d : ℤ} (ha : 2 ≤ a) (hab : a ≤ b) (hc : 2 ≤ c)
    (hcd : c ≤ d) (h : a * b = c * d) (hm : pairMoment 3 a b = pairMoment 3 c d) :
    a = c ∧ b = d := by
  have hac : a = c := by
    rcases lt_trichotomy a c with hlt | heq | hgt
    · exact absurd hm (by have := pairMoment_three_spread_strict ha hlt hcd h; linarith)
    · exact heq
    · exact absurd hm.symm
        (by have := pairMoment_three_spread_strict hc hgt hab h.symm; linarith)
  refine ⟨hac, ?_⟩
  have ha0 : a ≠ 0 := by linarith
  have : a * b = a * d := by rw [h, hac]
  exact mul_left_cancel₀ ha0 this

/-- **The arithmetic payoff.**  For a semiprime `N = p q` the observed third gcd moment
identifies the factorisation among all nontrivial factorisations of `N`. -/
theorem gcdMoment_three_identifies_factors {p q a b : ℕ} (hp : p.Prime) (hq : q.Prime)
    (hpq : p ≠ q) (hle : p ≤ q) (ha : 2 ≤ a) (hab : a ≤ b) (hprod : a * b = p * q)
    (hm : pairMoment 3 (a : ℤ) (b : ℤ) = (gcdMoment 3 (p * q) : ℤ)) :
    a = p ∧ b = q := by
  have hprodZ : (a : ℤ) * b = (p : ℤ) * q := by exact_mod_cast hprod
  have hmm : pairMoment 3 (a : ℤ) b = pairMoment 3 (p : ℤ) q := by
    rw [hm, pairMoment_eq_gcdMoment hp hq hpq]
  have haZ : (2 : ℤ) ≤ (a : ℤ) := by exact_mod_cast ha
  have habZ : (a : ℤ) ≤ (b : ℤ) := by exact_mod_cast hab
  have hpZ : (2 : ℤ) ≤ (p : ℤ) := by exact_mod_cast hp.two_le
  have hleZ : (p : ℤ) ≤ (q : ℤ) := by exact_mod_cast hle
  obtain ⟨h1, h2⟩ := pairMoment_three_injective haZ habZ hpZ hleZ hprodZ hmm
  exact ⟨by exact_mod_cast h1, by exact_mod_cast h2⟩

/-- **The second moment does factor a genuine semiprime.**  The two collisions of
`two_collision_classification` occur at `N = 28` and `N = 36`, and neither is a product of two
*distinct primes* — in both collisions one of the two factors involved is composite.  Hence for
a distinct-prime semiprime the second-moment oracle is already unambiguous, even though the
`k = 2` moment polynomial has a second root. -/
theorem factorization_from_second_moment {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p < q)
    {a b : ℕ} (ha : 2 ≤ a) (hab : a ≤ b) (hprod : a * b = p * q)
    (hmatch : pairMoment 2 (a : ℤ) (b : ℤ) = (gcdMoment 2 (p * q) : ℤ)) : a = p ∧ b = q := by
  have htrue : pairMoment 2 (p : ℤ) (q : ℤ) = (gcdMoment 2 (p * q) : ℤ) :=
    pairMoment_eq_gcdMoment hp hq (by omega) 2
  have hcoll : pairMoment 2 (a : ℤ) (b : ℤ) = pairMoment 2 (p : ℤ) (q : ℤ) := by
    rw [hmatch, htrue]
  have hac : a = p := by
    rcases lt_trichotomy a p with hlt | heq | hgt
    · rcases two_collision_classification ha hab (le_of_lt hpq) hlt hprod hcoll with
        ⟨-, -, h3, -⟩ | ⟨-, -, -, h4⟩
      · exact absurd (h3 ▸ hp) (by norm_num)
      · exact absurd (h4 ▸ hq) (by norm_num)
    · exact heq
    · rcases two_collision_classification hp.two_le (le_of_lt hpq) hab hgt hprod.symm
        hcoll.symm with ⟨-, h2, -, -⟩ | ⟨-, h2, -, -⟩
      · exact absurd (h2 ▸ hq) (by norm_num)
      · exact absurd (h2 ▸ hq) (by norm_num)
  refine ⟨hac, ?_⟩
  have ha0 : 0 < a := by omega
  have : a * b = a * q := by rw [hprod, hac]
  exact Nat.eq_of_mul_eq_mul_left ha0 this

/-- **The first moment factors a semiprime too**, in the same `pairMoment` language: matching
the first moment forces the candidate trace to equal the true one. -/
theorem factorization_from_first_moment {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p < q)
    {a b : ℕ} (hab : a ≤ b) (hprod : a * b = p * q)
    (hmatch : pairMoment 1 (a : ℤ) (b : ℤ) = (gcdMoment 1 (p * q) : ℤ)) : a = p ∧ b = q := by
  have htrue : pairMoment 1 (p : ℤ) (q : ℤ) = (gcdMoment 1 (p * q) : ℤ) :=
    pairMoment_eq_gcdMoment hp hq (by omega) 1
  have hcoll : pairMoment 1 (a : ℤ) (b : ℤ) = pairMoment 1 (p : ℤ) (q : ℤ) := by
    rw [hmatch, htrue]
  have hprodZ : (a : ℤ) * b = (p : ℤ) * q := by exact_mod_cast hprod
  have hsumZ : (a : ℤ) + b = (p : ℤ) + q := by
    simp only [pairMoment, pow_one] at hcoll
    nlinarith [hcoll, hprodZ]
  have hsum : a + b = p + q := by exact_mod_cast hsumZ
  exact sum_prod_determines_pair hprod hsum hab (le_of_lt hpq)

end GCDMoment