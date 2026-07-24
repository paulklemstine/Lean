import Catalog.Novelty.Basic

/-!
# The Anti-Fibonacci Sequence — Partial Sums and the Square Spectrum

Building on `Novelty.Basic`, where the anti-Fibonacci sequence is defined by
`antiFib 0 = 1`, `antiFib (n+1) = antiFib n + n` (values `1, 1, 2, 4, 7, 11, 16, …`,
with closed form `antiFib n = 1 + n(n-1)/2`), this file adds two new *arithmetic*
counterpoints to Fibonacci:

* `antiFib_sum_closed` — a cubic **partial-sum identity**
  `6 * (∑_{k=0}^{n} antiFib k) = n³ + 5·n + 6`.  Whereas the Fibonacci partial sums
  satisfy `∑_{k≤n} F k = F (n+2) - 1` (an *exponential* closed form), the
  anti-Fibonacci partial sums are an exact *cubic* polynomial in `n`.

* `antiFib_mem_iff` — the **square spectrum**: a natural number `m` occurs in the
  anti-Fibonacci sequence **iff** `8·m - 7` is a perfect square, phrased
  subtraction-free as `∃ k, k² + 7 = 8·m`.  (Equivalently: `m` is anti-Fibonacci iff
  `m - 1` is a triangular number.)  This is the arithmetic fingerprint distinguishing
  anti-Fibonacci values from arbitrary integers, and it has *density → 0*: only
  `~ √(m/2)` of the first `m` integers are anti-Fibonacci numbers.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the anti-Fibonacci sequence is "addition-avoiding"; its
partial sums and its value-set should therefore have *polynomial* fingerprints,
in sharp contrast to Fibonacci's exponential `∑ F = F(n+2)-1` and Binet form.
Two falsifiable sub-claims: (S1) `∑_{k≤n} antiFib k` is a fixed cubic in `n`;
(S2) membership `m ∈ range(antiFib)` is governed by a single quadratic Diophantine
condition on `m`.

Experiment (Experimenter): `#eval` gives
`6·∑_{k≤n} antiFib k = 6,12,24,48,90,156,252,384,…` which matches
`n³+5n+6 = 6,12,24,48,90,156,252,384,…` exactly (S1 confirmed).  For membership,
`m ∈ {1,2,4,7,11,16,…}` coincides bit-for-bit with `{m : ∃k, k²+7 = 8m}` on the
first 10 values (S2 confirmed).

Analysis (Analyst): with `antiFib n = 1 + n(n-1)/2`, telescoping and the sum of the
first `n` triangular numbers give `∑_{k≤n} antiFib k = (n³+5n+6)/6`; the `/6` is
absorbed by proving the subtraction-free identity `6·∑ = n³+5n+6` by induction and
one `ring`-style step.  For membership, `8·antiFib n = (2n-1)² + 7`, so every value
lands on `k²+7`; conversely `k²+7 = 8m` forces `k` odd, `k = 2j+1`, and then
`antiFib (j+1) = m`.

Critique (Critic): both statements must avoid `ℕ`-subtraction traps.  We therefore
state the sum identity multiplied through by `6` and the membership condition as
`k²+7 = 8m` (never `8m-7`).  The `1 ≤ m` guard is *unnecessary*: for `m = 0` both
sides are false (`antiFib` is always positive; `k²+7 = 0` is impossible), so the
`iff` holds vacuously — we deliberately drop the hypothesis for maximal generality.

Synthesis: the anti-Fibonacci partial sums are the cubic `(n³+5n+6)/6`, and the
anti-Fibonacci value-set is exactly `{m : 8m-7 is a square}` — two clean polynomial
/ Diophantine fingerprints that a genuinely addition-driven sequence can never have.
-- !-- Lab Notes -- !--
-/

open Finset

namespace AntiFibonacci

/--
**Partial-sum identity.** `6 · ∑_{k=0}^{n} antiFib k = n³ + 5·n + 6`.
Unlike Fibonacci (`∑_{k≤n} F k = F(n+2) − 1`, exponential), the anti-Fibonacci partial
sums are an exact cubic polynomial in `n`.
-/
theorem antiFib_sum_closed (n : ℕ) :
    6 * (∑ k ∈ Finset.range (n + 1), antiFib k) = n ^ 3 + 5 * n + 6 := by
  induction n <;> simp_all +decide [ Finset.sum_range_succ ];
  rename_i n ih; rw [ show antiFib ( n + 1 ) = antiFib n + n by rfl ] ; linarith [ AntiFibonacci.antiFib_closed n ] ;

/--
Helper: `8 · antiFib n = (2n − 1)² + 7`, written subtraction-free.
For `n = 0` this reads `8 = 1 + 7`; for `n ≥ 1`, `8·antiFib n = (2n−1)² + 7`.
-/
theorem eight_antiFib (n : ℕ) : 8 * antiFib n + 4 * n = 4 * n ^ 2 + 8 := by
  convert congr_arg ( · * 4 ) ( AntiFibonacci.antiFib_closed n ) using 1 <;> ring

/--
**Square spectrum.** A natural number `m` is an anti-Fibonacci value iff `8m − 7`
is a perfect square (`∃ k, k² + 7 = 8·m`).  Equivalently, `m − 1` is triangular.
No positivity hypothesis on `m` is needed: for `m = 0` both sides are false.
-/
theorem antiFib_mem_iff (m : ℕ) :
    (∃ n, antiFib n = m) ↔ ∃ k, k ^ 2 + 7 = 8 * m := by
  constructor;
  · rintro ⟨ n, rfl ⟩;
    rcases n with ( _ | _ | n ) <;> simp_all +arith +decide;
    · exists 1;
    · exact ⟨ 2 * n + 3, by linarith! [ AntiFibonacci.antiFib_closed ( n + 2 ) ] ⟩;
  · rintro ⟨ k, hk ⟩;
    rcases Nat.even_or_odd' k with ⟨ j, rfl | rfl ⟩;
    · grind;
    · exact ⟨ j + 1, by nlinarith [ antiFib_closed ( j + 1 ) ] ⟩

/--
**Strict monotonicity past the initial repeat.** `antiFib` takes the value `1` at both
`n = 0` and `n = 1`, but is strictly increasing on indices `≥ 1`: if `1 ≤ a < b` then
`antiFib a < antiFib b`.  Hence, apart from the single duplicated value `1`, every
anti-Fibonacci number is attained exactly once — the square spectrum is hit injectively.
-/
theorem antiFib_strictMono_from_one {a b : ℕ} (ha : 1 ≤ a) (hab : a < b) :
    antiFib a < antiFib b := by
  induction hab <;> simp_all +decide [ antiFib_succ ];
  · grind;
  · linarith

end AntiFibonacci