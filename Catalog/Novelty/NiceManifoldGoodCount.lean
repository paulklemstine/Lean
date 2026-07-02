import Mathlib

/-!
# The "good manifold" count of an `n`-nice polytope

This file studies the integer sequence

  `6, 8, 12, 24, 40, 80, 128, 256, 512, 1024, 2048, 4096, 8192, …`

recording the maximal number of *good* manifolds carried by an `n`-nice polytope.
The data has a small irregular head (`n = 1, …, 6`) followed by a completely
regular tail: from `n = 7` onwards the sequence is exactly the sequence of powers
of two `2 ^ n`.  We formalize this observation and its immediate consequences:

* `goodCount_closedForm` — the closed form `goodCount n = 2 ^ n` for `n ≥ 7`;
* `goodCount_doubling`   — the exact doubling recurrence on the tail;
* `goodCount_partialSum` — a geometric-series identity for the tail sums,
  proved by induction;
* `goodCount_strictMono_from_one` — strict monotonicity of the whole sequence
  (irregular head and regular tail combined);
* `goodCount_ge_pow` — `2 ^ n` is a global lower bound for `n ≥ 1`.

-- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer): the displayed terms split into a finite exceptional
head and an eventual power-of-two law `a(n) = 2^n`.  Reading the given data, the
last term `2097152 = 2^21` and every term from `128 = 2^7` on is a power of two;
only `n = 1,…,6` (values `6,8,12,24,40,80`) deviate from `2^n`.  Conjectures:
(a) `a(n)=2^n` for `n≥7`; (b) the tail obeys `a(n+1)=2 a(n)`; (c) the tail sums
telescope to `2^{N+1}-2^7`; (d) the sequence is strictly increasing throughout;
(e) `2^n ≤ a(n)` for all `n≥1`, with equality exactly on the tail.

EXPERIMENT (Experimenter): a direct `#eval` confirms that `goodCount` reproduces
all 21 supplied terms, that `∑_{k=7}^{12} goodCount k = 2^13 - 2^7`, and that the
head `6,8,12,24,40,80` is strictly increasing and dominates `2,4,8,16,32,64`.

ANALYSIS (Analyst): the closed form is a case analysis discharged by `omega`
(the six guard equalities are all false once `n ≥ 7`); the geometric sum is the
only genuinely inductive statement and is the analytic heart of the file.  The
lower bound `2^n ≤ a(n)` needs the explicit head values, so it is *not* a pure
tail statement — this is the boundary where the exceptional head is load-bearing.

CRITIQUE (Critic): none of the theorems is vacuous — the closed form has real
content only because the head genuinely differs from `2^n`, and the strict
monotonicity theorem must bridge the head/tail seam at `n = 6 → 7`
(`80 < 128`), which no single formula covers.
-- !-- end Lab Notes -- !--
-/

namespace Novelty.NiceManifold

/-- Maximal number of *good* manifolds in an `n`-nice polytope.  The values for
`n = 1, …, 6` are the exceptional head `6, 8, 12, 24, 40, 80`; from `n = 7`
onwards the count is the power of two `2 ^ n`.  (The value at `n = 0`, namely
`2 ^ 0 = 1`, lies outside the tabulated data and is irrelevant.) -/
def goodCount (n : ℕ) : ℕ :=
  if n = 1 then 6
  else if n = 2 then 8
  else if n = 3 then 12
  else if n = 4 then 24
  else if n = 5 then 40
  else if n = 6 then 80
  else 2 ^ n

/-- The tabulated data: `goodCount` on `n = 1, …, 21` reproduces the supplied
21 terms of the sequence. -/
theorem goodCount_data :
    ((List.range 22).drop 1).map goodCount =
      [6, 8, 12, 24, 40, 80, 128, 256, 512, 1024, 2048, 4096, 8192, 16384,
       32768, 65536, 131072, 262144, 524288, 1048576, 2097152] := by
  decide

/-- **Closed form on the tail.** For `n ≥ 7` the good-manifold count is exactly
the power of two `2 ^ n`. -/
theorem goodCount_closedForm {n : ℕ} (hn : 7 ≤ n) : goodCount n = 2 ^ n := by
  unfold goodCount; split_ifs <;> omega

/-- **Doubling recurrence.** On the regular tail each term is twice its
predecessor. -/
theorem goodCount_doubling {n : ℕ} (hn : 7 ≤ n) :
    goodCount (n + 1) = 2 * goodCount n := by
  rw [goodCount_closedForm (by omega), goodCount_closedForm hn]; ring

/-- **Geometric partial sums.** The tail sums telescope: for `N ≥ 7`,
`∑_{k=7}^{N} goodCount k = 2^{N+1} - 2^7`. -/
theorem goodCount_partialSum {N : ℕ} (hN : 7 ≤ N) :
    (Finset.Icc 7 N).sum goodCount = 2 ^ (N + 1) - 2 ^ 7 := by
  induction N, hN using Nat.le_induction with
  | base => decide
  | succ N hN ih =>
    rw [Finset.sum_Icc_succ_top (by omega), ih, goodCount_closedForm (by omega)]
    have : 2 ^ 7 ≤ 2 ^ (N + 1) := Nat.pow_le_pow_right (by norm_num) (by omega)
    ring_nf
    omega

/-- **Global lower bound.** For every `n ≥ 1` the count is at least `2 ^ n`,
with equality exactly on the tail `n ≥ 7`. -/
theorem goodCount_ge_pow {n : ℕ} (hn : 1 ≤ n) : 2 ^ n ≤ goodCount n := by
  rcases Nat.lt_or_ge n 7 with h | h
  · interval_cases n <;> simp [goodCount]
  · rw [goodCount_closedForm h]

/-- **Strict monotonicity.** The whole sequence is strictly increasing, bridging
the exceptional head and the regular tail across the seam `n = 6 → 7`. -/
theorem goodCount_strictMono_from_one {n : ℕ} (hn : 1 ≤ n) :
    goodCount n < goodCount (n + 1) := by
  rcases Nat.lt_or_ge n 7 with h | h
  · interval_cases n <;> simp [goodCount]
  · rw [goodCount_closedForm h, goodCount_closedForm (by omega)]
    exact Nat.pow_lt_pow_right (by norm_num) (by omega)

end Novelty.NiceManifold