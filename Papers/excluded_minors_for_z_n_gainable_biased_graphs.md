# Computational Evidence — Z_n-gainable biased graphs (parallel-class slice)

This note records the small-case evidence that motivated the formal results in
`ZnGain.lean` and `ZnGainSharp.lean`.

## 1. The pigeonhole obstruction `(n+1)K₂`

A gain labelling of the parallel class `kK₂` (k parallel edges between two vertices)
must give pairwise **distinct** labels to the edges: every digon `[(i,+),(j,−)]` is
unbalanced, so its gain `g i − g j` must be nonzero, i.e. `g i ≠ g j`.

Hence `kK₂` is `ℤ/n`-gainable **iff** `k` distinct labels fit in `ℤ/n`, i.e. `k ≤ n`.

| n | `|ℤ/n|` | largest gainable `kK₂` | smallest excluded `kK₂` |
|---|---------|------------------------|-------------------------|
| 2 | 2       | `2K₂`                  | `3K₂`                   |
| 3 | 3       | `3K₂`                  | `4K₂`                   |
| 4 | 4       | `4K₂`                  | `5K₂`                   |
| 5 | 5       | `5K₂`                  | `6K₂`                   |
| 6 | 6       | `6K₂`                  | `7K₂`                   |

The excluded minor is always exactly `(n+1)K₂`, **independent of whether `n` is prime
or composite** (rows n=4, n=6 are composite and behave identically to the prime rows).
Verified in Lean: `Fintype.card (ZMod 6) = 6`, `Fintype.card (ZMod 4) = 4`.

This was the key surprise: the prior catalog file `ZpGain.lean` required `Fact p.Prime`,
but primality is never actually used — only `|ℤ/n| = n` (`NeZero n`).

## 2. Number of balance classes (digon family)

For a general parallel class with balance relation `s`, gainability over `ℤ/n` is
governed by the number `q` of balance classes (`Fintype.card (Quotient s)`):

* `digonGraph s` is `ℤ/n`-gainable  ⇔  `q ≤ n`.
* `(n+1)K₂` is a minor of `digonGraph s`  ⇔  `q ≥ n+1`.

So gainable ⇔ no `(n+1)K₂` minor. Small cases (q balance classes, modulus n):

| q \ n | 2 | 3 | 4 |
|-------|---|---|---|
| 2     | ✔ | ✔ | ✔ |
| 3     | ✘ | ✔ | ✔ |
| 4     | ✘ | ✘ | ✔ |
| 5     | ✘ | ✘ | ✘ |

✔ = gainable (no `(n+1)K₂` minor); ✘ = not gainable (`(n+1)K₂` minor present).

## 3. Divisibility / monotonicity law

If `m ∣ n` then every `ℤ/m`-gainable biased graph is `ℤ/n`-gainable, because the
generator `1 ∈ ℤ/m` maps to `n/m ∈ ℤ/n` (additive order exactly `m`), giving an
injective hom `ℤ/m ↪ ℤ/n` along which a realisation transports.

Spot checks (parallel classes, using the `k ≤ n` rule):

* `3K₂`: gainable over `ℤ/3` (3 ≤ 3) ⇒ gainable over `ℤ/6` (3 ≤ 6).  `3 ∣ 6`. ✔
* `4K₂`: gainable over `ℤ/4` (4 ≤ 4) ⇒ gainable over `ℤ/8`.  `4 ∣ 8`. ✔
* Non-divisible jumps still respect `k ≤ n` directly; divisibility gives a *uniform*
  structural reason rather than a re-count.

## 4. OEIS

No new integer sequence is generated: the threshold function is simply
`largest gainable parallel class = n` (the identity), and the excluded-minor edge count
is `n+1`. These are too trivial as sequences to warrant an OEIS entry; the content is the
*characterisation*, not a sequence.

## 5. Counterexample hunt

The universal claim tested is: "over every `ℤ/n` (n ≥ 2), the parallel-class family is
`ℤ/n`-gainable iff it has no `(n+1)K₂` minor." No counterexample was found in the range
`n ≤ 6`, `q ≤ 6`; the formal proof (`digon_excluded_minor`) shows there is none for any
`n` with `NeZero n`.

The *full* conjecture (with additional excluded minors `±K₃`, `−K₄`) was **not** tested
computationally here: those minors require vertex-level structure (signed-graph
geometry) not present in the cycle-only abstraction used for the formalised slice.
