import Novelty.Basic

/-!
# Three-term progressions in the Anti-Fibonacci sequence ↔ Pythagorean triples

Fibonacci is *addition-driven*; the anti-Fibonacci sequence of `Novelty.Basic`
(`antiFib 0 = 1`, `antiFib (n+1) = antiFib n + n`, closed form `2·antiFib n + n = n²+2`)
is not.  Nevertheless it carries a rich *additive* structure of its own, and this file
identifies it exactly:

> **Three anti-Fibonacci terms are in arithmetic progression if and only if the
> associated triple `(a + c - 1, c - a, 2b - 1)` is a Pythagorean triple.**

This is a genuine bridge between the (quadratic, addition-avoiding) anti-Fibonacci
sequence and classical Diophantine geometry: every Pythagorean triple with an odd
hypotenuse manufactures a three-term progression of anti-Fibonacci numbers, and
conversely.  We then contrast this with Fibonacci, where three-term progressions are
*rigid*: they are forced to be `F(b-2), F b, F(b+1)`, a one-parameter family, whereas
the anti-Fibonacci progressions form the two-parameter Pythagorean family.

## Main results

* `AntiFibonacciAP.antiFib_AP_iff_pythagoreanTriple` — the bridge, stated with
  Mathlib's `PythagoreanTriple` and free of any hypotheses (all arithmetic in `ℤ`).
* `AntiFibonacciAP.AP_of_pythagorean` — every Pythagorean triple `x² + y² = z²` with
  `1 ≤ y < x` and `z` odd produces a **nondegenerate** progression
  `antiFib a < antiFib b < antiFib c` with `a < b < c`.
* `AntiFibonacciAP.antiFib_AP_family` — the explicit infinite family coming from the
  triples `(2k+1, 2k²+2k, 2k²+2k+1)`:
  `antiFib (k²) + antiFib ((k+1)²) = 2 · antiFib (k²+k+1)`.
* `AntiFibonacciAP.common_difference_eq_pyramidal` — the common difference of that
  progression is `3·(1² + 2² + ⋯ + k²)`, i.e. three times a square-pyramidal number.
* `AntiFibonacciAP.exists_AP_above` — there are progressions with arbitrarily large
  entries (infinitely many of them).
* `AntiFibonacciAP.fib_AP_rigid` — the Fibonacci contrast: for `3 ≤ a < b < c`,
  `F a + F c = 2 F b` forces `c = b + 1` and `a = b - 2`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): "avoiding addition" should not mean "no additive structure".
Since `antiFib n = 1 + n(n-1)/2`, an arithmetic progression among its values is a
quadratic Diophantine condition, and quadratic conditions in two variables are usually
Pythagorean in disguise.

Experiment (Experimenter): brute force over index triples `1 ≤ a < b < c < 30`
(`apTriples` below) returns `(1,3,4) : 1,4,7`, `(1,15,21) : 1,106,211`,
`(2,8,11) : 2,29,56`, `(3,13,18) : 4,79,154`, `(4,7,9) : 7,22,37`, ….  The sub-family
`(k², k²+k+1, (k+1)²)` — `(1,3,4)`, `(4,7,9)`, `(9,13,16)`, … — is visible inside it,
and each remaining solution matches a further Pythagorean triple, e.g.
`(2,8,11) ↔ (12,9,15)` and `(1,15,21) ↔ (21,20,29)`.

Analysis (Analyst): `antiFib a + antiFib c = 2 antiFib b` is, after clearing the closed
form, `(a+c-1)² + (c-a)² = (2b-1)²`.  So progressions are *precisely* Pythagorean
triples with odd hypotenuse `2b-1`, the two legs having opposite parity automatically.
The Pythagorean family `(2k+1, 2k²+2k, 2k²+2k+1)` then yields the explicit progression
indexed by consecutive squares, with common difference `k(k+1)(2k+1)/2`.

Critique (Critic): the `ℕ`-subtractions `c - a` and `2b - 1` are traps, so the bridge is
stated over `ℤ`, where it needs **no** side conditions; the `ℕ`-level corollary carries
the explicit guards `1 ≤ y < x`, `z` odd.  Degenerate progressions (`a = b = c`) satisfy
both sides, so nondegeneracy is proved separately from `y ≥ 1`.
-/

open AntiFibonacci

namespace AntiFibonacciAP

/-- Integer closed form of the anti-Fibonacci sequence. -/
theorem antiFib_closed_int (n : ℕ) : 2 * (antiFib n : ℤ) + n = (n : ℤ) ^ 2 + 2 := by
  have h : ((2 * antiFib n + n : ℕ) : ℤ) = ((n * n + 2 : ℕ) : ℤ) := by
    exact_mod_cast congrArg (fun x : ℕ => (x : ℤ)) (antiFib_closed n)
  push_cast at h
  linarith [h]

/-- **The bridge.**  Anti-Fibonacci values at indices `a, b, c` are in arithmetic
progression exactly when `(a + c - 1, c - a, 2b - 1)` is a Pythagorean triple.
No hypotheses are needed: the statement lives in `ℤ`. -/
theorem antiFib_AP_iff_pythagoreanTriple (a b c : ℕ) :
    antiFib a + antiFib c = 2 * antiFib b ↔
      PythagoreanTriple ((a : ℤ) + (c : ℤ) - 1) ((c : ℤ) - (a : ℤ)) (2 * (b : ℤ) - 1) := by
  have ha := antiFib_closed_int a
  have hb := antiFib_closed_int b
  have hc := antiFib_closed_int c
  rw [PythagoreanTriple]
  constructor
  · intro h
    have hz : (antiFib a : ℤ) + antiFib c = 2 * antiFib b := by exact_mod_cast h
    nlinarith [ha, hb, hc, hz]
  · intro h
    have hz : (antiFib a : ℤ) + antiFib c = 2 * antiFib b := by nlinarith [ha, hb, hc, h]
    exact_mod_cast hz

/-- **Every Pythagorean triple with odd hypotenuse manufactures a progression.**
If `x² + y² = z²` with `1 ≤ y < x` and `z = 2b - 1` odd, then setting
`a = (x - y + 1)/2` and `c = (x + y + 1)/2` we get `a < b < c` and
`antiFib a + antiFib c = 2 · antiFib b`. -/
theorem AP_of_pythagorean {x y z a b c : ℕ}
    (hxy : y < x) (hy : 1 ≤ y) (hpyth : x * x + y * y = z * z)
    (hz : z = 2 * b - 1) (hzodd : z % 2 = 1) (hb : 1 ≤ b)
    (ha : 2 * a = x - y + 1) (hc : 2 * c = x + y + 1) :
    a < b ∧ b < c ∧ antiFib a + antiFib c = 2 * antiFib b := by
  have hxz : x < z := by nlinarith [hpyth, hy, hxy]
  have hzx : z ≤ x + y := by nlinarith [hpyth, hy, hxy]
  have hzn : (z : ℤ) = 2 * (b : ℤ) - 1 := by
    have h2b : 2 * b = z + 1 := by omega
    omega
  have haz : 2 * (a : ℤ) = (x : ℤ) - (y : ℤ) + 1 := by
    have : (2 * a : ℕ) = x - y + 1 := ha
    have h1 : ((2 * a : ℕ) : ℤ) = ((x - y + 1 : ℕ) : ℤ) := by exact_mod_cast this
    push_cast [Nat.cast_sub (le_of_lt hxy)] at h1
    linarith [h1]
  have hcz : 2 * (c : ℤ) = (x : ℤ) + (y : ℤ) + 1 := by
    have h1 : ((2 * c : ℕ) : ℤ) = ((x + y + 1 : ℕ) : ℤ) := by exact_mod_cast hc
    push_cast at h1
    linarith [h1]
  have hpz : (x : ℤ) * x + (y : ℤ) * y = (z : ℤ) * z := by exact_mod_cast hpyth
  refine ⟨?_, ?_, ?_⟩
  · -- `2a = x - y + 1 < z + 1 = 2b`
    have h2 : (2 * a : ℤ) < 2 * (b : ℤ) := by nlinarith [haz, hzn, hxz, hpz]
    have : (a : ℤ) < (b : ℤ) := by linarith
    exact_mod_cast this
  · have h2 : (2 * b : ℤ) < 2 * (c : ℤ) := by nlinarith [hcz, hzn, hzx]
    have : (b : ℤ) < (c : ℤ) := by linarith
    exact_mod_cast this
  · rw [antiFib_AP_iff_pythagoreanTriple, PythagoreanTriple]
    have e1 : (a : ℤ) + (c : ℤ) - 1 = (x : ℤ) := by linarith [haz, hcz]
    have e2 : (c : ℤ) - (a : ℤ) = (y : ℤ) := by linarith [haz, hcz]
    rw [e1, e2, show 2 * (b : ℤ) - 1 = (z : ℤ) by linarith [hzn]]
    exact hpz

/-! ### The explicit infinite family -/

/-- The Pythagorean triples `(2k+1, 2k²+2k, 2k²+2k+1)`. -/
theorem pythagorean_family (k : ℕ) :
    (2 * k + 1) * (2 * k + 1) + (2 * k * k + 2 * k) * (2 * k * k + 2 * k)
      = (2 * k * k + 2 * k + 1) * (2 * k * k + 2 * k + 1) := by
  ring

/-- **The infinite family of anti-Fibonacci progressions**, indexed by consecutive
squares: `antiFib (k²) + antiFib ((k+1)²) = 2 · antiFib (k² + k + 1)`. -/
theorem antiFib_AP_family (k : ℕ) :
    antiFib (k ^ 2) + antiFib ((k + 1) ^ 2) = 2 * antiFib (k ^ 2 + k + 1) := by
  rw [antiFib_AP_iff_pythagoreanTriple, PythagoreanTriple]
  push_cast
  ring

/-- The indices of the family are strictly increasing for `k ≥ 1`. -/
theorem antiFib_AP_family_indices {k : ℕ} (hk : 1 ≤ k) :
    k ^ 2 < k ^ 2 + k + 1 ∧ k ^ 2 + k + 1 < (k + 1) ^ 2 := by
  constructor
  · omega
  · have : (k + 1) ^ 2 = k ^ 2 + 2 * k + 1 := by ring
    omega

/-- The common difference of the `k`-th progression is `3·(1² + 2² + ⋯ + k²)`,
three times the `k`-th square-pyramidal number. -/
theorem common_difference_eq_pyramidal (k : ℕ) :
    antiFib (k ^ 2 + k + 1) = antiFib (k ^ 2) + 3 * ∑ i ∈ Finset.range (k + 1), i ^ 2 := by
  have hsum : 6 * ∑ i ∈ Finset.range (k + 1), i ^ 2 = k * (k + 1) * (2 * k + 1) := by
    induction k with
    | zero => simp
    | succ n ih =>
        rw [Finset.sum_range_succ, Nat.mul_add]
        rw [ih]
        ring
  have h1 := antiFib_closed (k ^ 2 + k + 1)
  have h2 := antiFib_closed (k ^ 2)
  nlinarith [h1, h2, hsum]

/-- **Progressions with arbitrarily large entries.**  For every bound `M` there is a
nondegenerate three-term progression of anti-Fibonacci numbers all of whose indices
exceed `M`; in particular there are infinitely many such progressions. -/
theorem exists_AP_above (M : ℕ) :
    ∃ a b c : ℕ, M < a ∧ a < b ∧ b < c ∧ antiFib a + antiFib c = 2 * antiFib b := by
  refine ⟨(M + 1) ^ 2, (M + 1) ^ 2 + (M + 1) + 1, (M + 2) ^ 2, ?_, ?_, ?_, ?_⟩
  · nlinarith
  · omega
  · have : (M + 2) ^ 2 = (M + 1) ^ 2 + 2 * (M + 1) + 1 := by ring
    omega
  · have h := antiFib_AP_family (M + 1)
    have hrw : (M + 1) + 1 = M + 2 := by omega
    rw [hrw] at h
    exact h

/-! ### Contrast: Fibonacci progressions are rigid -/

/-- **Fibonacci rigidity.**  For `3 ≤ a < b < c`, a three-term Fibonacci progression
`F a + F c = 2 · F b` forces `c = b + 1` and `a = b - 2`: a *one*-parameter family,
in sharp contrast with the two-parameter Pythagorean family of anti-Fibonacci
progressions. -/
theorem fib_AP_rigid {a b c : ℕ} (ha : 3 ≤ a) (hab : a < b) (hbc : b < c)
    (h : Nat.fib a + Nat.fib c = 2 * Nat.fib b) : c = b + 1 ∧ a + 2 = b := by
  have hb2 : 2 ≤ b := by omega
  have hfa : 1 ≤ Nat.fib a := Nat.fib_pos.2 (by omega)
  -- `c ≥ b + 2` is impossible.
  have hcb : c = b + 1 := by
    by_contra hne
    have hcge : b + 2 ≤ c := by omega
    have hmono : Nat.fib (b + 2) ≤ Nat.fib c := by
      rcases eq_or_lt_of_le hcge with heq | hlt
      · rw [heq]
      · exact le_of_lt ((Nat.fib_lt_fib (by omega)).2 hlt)
    have hsplit : Nat.fib (b + 2) = Nat.fib b + Nat.fib (b + 1) := Nat.fib_add_two
    have hgrow : Nat.fib b < Nat.fib (b + 1) := Nat.fib_lt_fib_succ hb2
    omega
  subst hcb
  refine ⟨rfl, ?_⟩
  -- Now `F a = 2 F b - F (b+1) = F (b-2)`.
  obtain ⟨d, hd⟩ : ∃ d, b = d + 2 := ⟨b - 2, by omega⟩
  subst hd
  rw [show d + 2 + 1 = d + 3 from rfl] at h
  have hsplit : Nat.fib (d + 2) = Nat.fib d + Nat.fib (d + 1) := Nat.fib_add_two
  have hsplit2 : Nat.fib (d + 3) = Nat.fib (d + 1) + Nat.fib (d + 2) := Nat.fib_add_two
  have hfa_eq : Nat.fib a = Nat.fib d := by omega
  have hd3 : 3 ≤ d + 2 := by omega
  have had : a = d := by
    rcases lt_trichotomy a d with hlt | heq | hgt
    · have : Nat.fib a < Nat.fib d := (Nat.fib_lt_fib (by omega)).2 hlt
      omega
    · exact heq
    · have hdge : 2 ≤ d := by
        by_contra hcon
        push_neg at hcon
        have hle : Nat.fib 3 ≤ Nat.fib a := Nat.fib_mono (by omega)
        have h3 : Nat.fib 3 = 2 := by norm_num [Nat.fib]
        have h0 : Nat.fib 0 = 0 := rfl
        have h1 : Nat.fib 1 = 1 := rfl
        interval_cases d <;> omega
      have : Nat.fib d < Nat.fib a := (Nat.fib_lt_fib (by omega)).2 hgt
      omega
  omega

/-! ### Experimental data -/

section Evidence

/-- All index triples `a < b < c ≤ 20` giving an anti-Fibonacci progression. -/
def apTriples (M : ℕ) : List (ℕ × ℕ × ℕ) :=
  (List.range M).flatMap fun a0 =>
    let a := a0 + 1
    (List.range M).flatMap fun b =>
      (List.range M).filterMap fun c =>
        if a < b ∧ b < c ∧ antiFib a + antiFib c = 2 * antiFib b then some (a, b, c) else none

/-- info: [(1, 3, 4), (1, 15, 21), (2, 8, 11), (3, 13, 18), (4, 7, 9)] -/
#guard_msgs in #eval (apTriples 30).take 5

/-- info: [(1, 4, 7), (1, 106, 211), (2, 29, 56), (4, 79, 154), (7, 22, 37)] -/
#guard_msgs in
#eval ((apTriples 30).take 5).map fun t => (antiFib t.1, antiFib t.2.1, antiFib t.2.2)

end Evidence

end AntiFibonacciAP