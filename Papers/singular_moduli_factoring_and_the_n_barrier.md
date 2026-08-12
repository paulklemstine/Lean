# Computational Evidence — Singular Moduli Factoring and the √N Barrier

All numbers below were produced by exhaustive/Monte-Carlo computation before the
Lean proofs were written; each of the three findings is matched by a theorem in
`Catalog/Geometry/`. Nothing in this file is a formal verification: the formal
statements are the Lean theorems, and this file records the experiments that
suggested them.

Class polynomials used (standard singular moduli):
`H_{-3}=X`, `H_{-4}=X-1728`, `H_{-7}=X+3375`, `H_{-8}=X-8000`, `H_{-11}=X+32768`,
`H_{-19}=X+884736`, `H_{-43}=X+884736000`, `H_{-67}=X+147197952000`,
`H_{-15}=X²+191025X-121287375` (h=2), `H_{-23}` and `H_{-31}` (h=3, cubics).

---

## 1. Exact count of successful evaluation points (72/72 configurations)

For every semiprime `N = p·q` below and every discriminant `D`, the number `|G|`
of residues `j₀ mod N` with `1 < gcd(H_D(j₀), N) < N` was computed by brute force
over all `p·q` residues and compared with the predicted
`r_p (q − r_q) + (p − r_p) r_q`.

**All 72 configurations agree exactly.**  (Theorem
`SingularModuli.card_goodSet` / `SqrtBarrier.card_goodPairs`.)

Representative rows (`h` = class number = deg H_D, `r_p, r_q` = root counts,
`E = N/|G|` = expected number of uniform evaluations):

|     N |  p |  q |   D | h | r_p | r_q |  \|G\| |     E | E/√N | count formula |
|------:|---:|---:|----:|--:|----:|----:|------:|------:|-----:|:--------------|
|   667 | 23 | 29 |  -4 | 1 |   1 |   1 |    50 | 13.34 | 0.517 | exact |
|  1147 | 31 | 37 | -15 | 2 |   2 |   0 |    74 | 15.50 | 0.458 | exact |
|  1763 | 41 | 43 |  -7 | 1 |   1 |   1 |    82 | 21.50 | 0.512 | exact |
|  3599 | 59 | 61 | -15 | 2 |   2 |   2 |   232 | 15.51 | 0.259 | exact |
|  5183 | 71 | 73 |  -4 | 1 |   1 |   1 |   142 | 36.50 | 0.507 | exact |
|  8051 | 83 | 97 | -15 | 2 |   0 |   0 | **0** |   ∞  |   —  | exact |
| 10403 |101 |103 |  -3 | 1 |   1 |   1 |   202 | 51.50 | 0.505 | exact |

Observations.

* For class number one, `E/√N ≈ 0.507` across two orders of magnitude — i.e.
  `E ≈ √N/2`, matching the exact formula `E = N/(h(p+q−2h))` with `h = 1`,
  **not** the informally claimed `√N/(4h) = √N/4`.  The source note's constant
  is off by a factor 2 (`SqrtBarrier.expectedTrials_balanced_eq`).
* For `h = 2` with both primes split (`N = 3599`), `E/√N ≈ 0.259 ≈ 1/(2h)` — the
  `1/h` gain is real *for that discriminant and that N*.
* `N = 8051`, `D = -15`: `r_p = r_q = 0`, so `|G| = 0` and the method **fails
  outright** — no evaluation point can ever factor `N` with this discriminant
  (`SqrtBarrier.goodPairs_eq_empty`).  The claim "`H_D mod p` has `h` roots" is
  false for non-split primes; this is the corner case the informal argument
  omits.

---

## 2. Average number of roots is 1, independent of the class number

Root counts of `H_D mod p` over the 278 primes `100 < p < 2000`:

|   D | h | avg #roots | fraction with h roots | fraction with 0 roots |
|----:|--:|-----------:|----------------------:|----------------------:|
|  -3 | 1 |     1.0000 |                1.0000 |                0.0000 |
|  -4 | 1 |     1.0000 |                1.0000 |                0.0000 |
|  -7 | 1 |     1.0000 |                1.0000 |                0.0000 |
| -15 | 2 |     0.9784 |                0.4892 |                0.5108 |
| -23 | 3 |     1.0000 |                0.1619 |                0.3237 |
| -31 | 3 |     0.9748 |                0.1583 |                0.3417 |

The average is `1` regardless of `h` (as Chebotarev predicts for an irreducible
polynomial), while the *proportion* of primes with the full `h` roots is `≈ 1/h`
(0.49 for h=2, 0.16 for h=3 — the split density in the ring class field).

**Consequence, and the sharpest new claim of this cycle:** the `1/h` speed-up
per useful discriminant is exactly cancelled by the `1/h` density of
discriminants for which the prime splits.  Searching a family of `k`
discriminants costs `Ω(√N)` evaluations independently of `k` and of the class
numbers (`SqrtBarrier.familyExpectedTrials_ge`).

---

## 3. Monte-Carlo: measured evaluation counts vs. the exact prediction

`D = -4`, uniform random `j₀ ∈ [0,N)`, 2000 independent runs per `N`:

|     N | mean evals | predicted N/\|G\| | mean/√N | min | max |
|------:|-----------:|------------------:|--------:|----:|----:|
|   667 |      12.95 |             13.34 |   0.501 |   1 | 122 |
|  1147 |      17.47 |             17.38 |   0.516 |   1 | 129 |
|  1763 |      21.05 |             21.50 |   0.501 |   1 | 168 |
|  3127 |      29.03 |             28.43 |   0.519 |   1 | 239 |
|  3599 |      29.93 |             30.50 |   0.499 |   1 | 254 |
|  5183 |      38.07 |             36.50 |   0.529 |   1 | 237 |
|  8051 |      46.23 |             45.23 |   0.515 |   1 | 417 |
| 10403 |      49.39 |             51.50 |   0.484 |   1 | 359 |

The measured means track `N/|G|` to within sampling error, and the ratio to `√N`
is flat at `≈ 0.5`.  The observed spread (1 … 417 evaluations) is the geometric
distribution's tail, and explains the "1–42 evaluations" reported informally for
small `N`: those are single samples, not expectations.  All measured ratios lie
inside the proved window `[1/(3h), 1/h] = [0.333, 1]`
(`SqrtBarrier.expectedTrials_ge`, `SqrtBarrier.expectedTrials_le`).

---

## 4. Multi-prime composites (cycle 2)

For random 3-prime moduli `N = p₁p₂p₃` and random structured sets, the partition
identity `|G| + ∏ rᵢ + ∏ (pᵢ − rᵢ) = ∏ pᵢ` and the density bound
`|G|/N ≤ ∑ rᵢ/pᵢ` were checked exhaustively over all `N` residues:

| (p₁,p₂,p₃) | (r₁,r₂,r₃) | \|G\| | identity | density | ∑ rᵢ/pᵢ |
|:-----------|:-----------|------:|:---------|--------:|--------:|
| (5,3,13)   | (0,1,1)    |    75 | exact    |  0.3846 |  0.4103 |
| (11,5,3)   | (1,1,2)    |   123 | exact    |  0.7455 |  0.9576 |
| (7,5,13)   | (0,1,0)    |    91 | exact    |  0.2000 |  0.2000 |
| (3,13,5)   | (2,2,0)    |   140 | exact    |  0.7179 |  0.8205 |
| (11,13,7)  | (0,1,2)    |   341 | exact    |  0.3407 |  0.3626 |
| (7,11,13)  | (2,1,1)    |   399 | exact    |  0.3986 |  0.4535 |

8/8 identities exact, 8/8 density bounds satisfied (tight when a single prime
carries all the roots).  Formalised as `MultiPrime.card_goodMulti` and
`MultiPrime.density_le`, giving `E ≥ p_min/(k d)`: the method is a
*smallest-prime-factor* finder, and `√N` is simply what that means for balanced
semiprimes.

---

## 5. Counterexample hunt

* Universal claim "`H_D` has `h` roots mod every prime": **false**, counterexample
  `D = -15`, `p = 83` and `p = 97` (0 roots).  Guarded in Lean by taking root
  counts as parameters `r_p, r_q ≤ d` rather than assuming `r = h`.
* Universal claim "expected evaluations `= √N/(4h)`": **false as stated**; the
  exact value is `N/(h(p+q−2h))`, i.e. `≈ √N/(2h)` for balanced primes, and the
  measured constant is `0.507`, not `0.25`.
* Claim "large class number gives a `1/h` speed-up": **false when averaged over
  discriminants** (Section 2); true only for a single discriminant already known
  to split at both primes — which is information about `p`.
