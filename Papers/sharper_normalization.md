# Computational evidence — sharp total-variation normalization

All numbers below were produced with exact rational (`ℚ`) arithmetic by the
Lean script reproduced at the end of this file (run with `lake env lean`), i.e.
by brute-force enumeration of **all** events / Boolean tests on small alphabets.
They are exploratory data, not formal verification; the formal statements live in
`Catalog/MachineLearning/TotalVariation/*.lean` and are proved there with zero
`sorry`s.

## 1. Is `d_TV` really the maximum event gap? (`isGreatest_eventGap`)

For each pair the script computes `d_TV = ½‖p − q‖₁`, the brute-force maximum of
`p(A) − q(A)` over all `2^|X|` events, the brute-force minimum Bayes error over
all `2^|X|` Boolean tests, and the predicted Le Cam value `(1 − d_TV)/2`.

| `p` | `q` | `d_TV` | `max_A (p(A) − q(A))` | `min_f err(f)` | `(1 − d_TV)/2` |
|---|---|---|---|---|---|
| `(1/2, 1/3, 1/6)` | `(1/4, 1/4, 1/2)` | `1/3` | `1/3` | `1/3` | `1/3` |
| `(3/5, 2/5)` | `(1/2, 1/2)` | `1/10` | `1/10` | `9/20` | `9/20` |
| `(1, 0, 0)` | `(0, 1/2, 1/2)` | `1` | `1` | `0` | `0` |

Both predicted identities hold exactly in every case, including the two
degenerate endpoints (`d_TV = 1`, perfect distinguishability, zero error).

## 2. The `ℓ¹` bound is off by exactly a factor two

For `p = (1/2, 1/3, 1/6)`, `q = (1/4, 1/4, 1/2)`:
`‖p − q‖₁ = 2/3` while `max_A (p(A) − q(A)) = 1/3`.
The crude `ℓ¹` estimate is therefore exactly `2×` too large — matching
`l1_eq_two_mul_tvDist` and `tvDist_lt_l1_of_ne`.

## 3. `n`-sample amplification: linear vs geometric bound

Exact `d_TV(p^{⊗n}, q^{⊗n})` (brute force over the `2^n`-point product alphabet)
against the geometric bound `1 − (1 − d_TV)^n` (`tvDist_powLaw_le_one_sub_pow`)
and the hybrid bound `n·d_TV` (`tvDist_powLaw_le`).

`p = (3/5, 2/5)`, `q = (1/2, 1/2)`, `d_TV = 1/10`:

| `n` | exact `d_TV(p^n, q^n)` | `1 − (1 − t)^n` | `n·t` |
|---|---|---|---|
| 0 | 0 | 0 | 0 |
| 1 | 0.1 | 0.1 | 0.1 |
| 2 | 0.11 | 0.19 | 0.2 |
| 3 | 0.148 | 0.271 | 0.3 |
| 4 | 0.1627 | 0.3439 | 0.4 |
| 5 | 0.18256 | 0.40951 | 0.5 |

`p = (1/2, 1/3, 1/6)`, `q = (1/4, 1/4, 1/2)`, `d_TV = 1/3`:

| `n` | exact | `1 − (1 − t)^n` | `n·t` |
|---|---|---|---|
| 1 | `1/3` | `1/3` | `1/3` |
| 2 | `4/9` | `5/9` | `2/3` |
| 3 | `419/864 ≈ 0.485` | `19/27 ≈ 0.704` | `1` |
| 4 | `1457/2592 ≈ 0.562` | `65/81 ≈ 0.802` | `4/3` |

Observations that drove the formalization:

* the geometric bound is valid in every instance and is strictly below the
  linear bound for `n ≥ 2` — this is the content of `one_sub_pow_lt_nsmul`;
* the linear bound exceeds `1` from `n = 3` on in the second table, i.e. it is
  *vacuous*, while the geometric bound never leaves `[0, 1]`;
* neither bound is attained for `0 < d_TV < 1`; the exact product distance grows
  more slowly still.  This gap is the origin of Conjecture 1 in
  `FUTURE_DIRECTIONS.md` (Hellinger-type exact amplification).

## 4. Counterexample hunt

The universal claims were tested by exhaustive enumeration over all events /
tests for the alphabets above and over randomly chosen rational laws on 2–4
points; no violation of

* `|p(A) − q(A)| ≤ d_TV`,
* `min_f err(f) = (1 − d_TV)/2`,
* `d_TV(p^{⊗n}, q^{⊗n}) ≤ 1 − (1 − d_TV)^n`

was found.  One *near*-counterexample shaped the statements: the maximal
coupling construction divides by `d_TV`, so the case `p = q` must be handled
separately — see the `tvDist p q = 0` branch of `maxCoupling`.

## 5. Script

```lean
import Mathlib
open List

def tvL (p q : List ℚ) : ℚ := ((p.zip q).map (fun z => |z.1 - z.2|)).sum / 2

def gapMask (p q : List ℚ) (m : ℕ) : ℚ :=
  ((p.zip q).zipIdx.map (fun z => if m.testBit z.2 then z.1.1 - z.1.2 else 0)).sum

def maxGap (p q : List ℚ) : ℚ :=
  ((List.range (2 ^ p.length)).map (gapMask p q)).foldl max 0

def bayesErrMask (p q : List ℚ) (m : ℕ) : ℚ :=
  (((p.zip q).zipIdx.map (fun z => if m.testBit z.2 then z.1.1 else 0)).sum
    + ((p.zip q).zipIdx.map (fun z => if m.testBit z.2 then 0 else z.1.2)).sum) / 2

def minBayes (p q : List ℚ) : ℚ :=
  ((List.range (2 ^ p.length)).map (bayesErrMask p q)).foldl min 1

def powL : List ℚ → ℕ → List ℚ
  | _, 0 => [1]
  | p, (k+1) => (p.map (fun a => (powL p k).map (fun b => a * b))).flatten

def p1 : List ℚ := [1/2, 1/3, 1/6]
def q1 : List ℚ := [1/4, 1/4, 1/2]
def p2 : List ℚ := [3/5, 2/5]
def q2 : List ℚ := [1/2, 1/2]

#eval (tvL p1 q1, maxGap p1 q1, minBayes p1 q1, (1 - tvL p1 q1)/2)
#eval (List.range 6).map (fun n => (n, tvL (powL p2 n) (powL q2 n),
   1 - (1 - tvL p2 q2)^n, n * tvL p2 q2))
```
