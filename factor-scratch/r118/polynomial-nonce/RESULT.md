# RESULT — structural nonce leaks: `t* = D + 2` by linear algebra, cost independent of `n`

Round 118, `factor-scratch/r118/polynomial-nonce/attack.sage`.
**Status: SUPPORTED, and the generalization of the affine-nonce result to a theorem with a
sharp threshold and a cost that does not scale with the modulus.**

## The theorem and its measurement

If the nonce lies in an affine span of `D` public signals,

```
k_i = Σ_{j=1..D} a_j g_j(i) + Δ        (g_j public; a_1..a_D, Δ and the key d secret)
```

then the signature equation `s_i k_i = z_i + r_i d (mod n)` is **linear in the `D+2`
unknowns** `(a_1..a_D, Δ, d)`, so `t ≥ D+2` signatures determine the key by one linear solve.

Measured on secp256k1 (`D+2` unknowns, 12 trials per cell, ground truth `d·G = Q`):

```
 D   t=D+1        t=D+2        t=D+3     solve time
 1    0/12       12/12        12/12     0.003 s
 2    0/12       12/12        12/12     0.003 s
 3    0/12       12/12        12/12     0.004 s
 4    0/12       12/12        12/12     0.005 s
```

**`t* = D+2` exactly** — the information-theoretic minimum, achieved — with the secret
constants `Δ` and `a_j` recovered alongside the key, and the solve time **independent of the
256-bit group order** (3–10 ms throughout).

## The two frontier families, side by side

| leak type | threshold | cost |
|---|---|---|
| **distributional** (Fourier / lattice) | `⌈log₂ n / b⌉` (reliable) or `2 ln n / A²` (noisy) | `n / 2^b` or `O(t·n log n)` — **grows with `n`** |
| **structural** (affine span of public signals) | `D + 2` signatures | **`O(D³)`, independent of `n`** |

For a 256-bit modulus the structural route is 2–3 signatures and a 3 ms linear solve; the
statistical route is 33–65 signatures (reliable 4–8 bits) and `2^248`-`2^232` element
operations. **Structure is not merely another leak type — it is an asymptotically cheaper
one, because its cost is fixed by the number of unknowns rather than by the modulus.**

## What it covers

- `D = 1`: counter + secret offset (the round-118 affine result), `t* = 3`.
- `D = 2+`: a polynomial in a public index — an RNG whose state advances by a polynomial
  recurrence in a counter, a timestamp-driven nonce, or any combination of public signals
  (time, counter, message length).
- Any linear combination of known public sequences, whatever the sources.

## Precondition

The `D` signals `g_j(i)` must be **public and distinct enough** that the `t × (D+2)` system
is invertible (`det ≠ 0 mod n`), and every secret in the nonce must be one of the `D+1`
affine parameters. If the nonce also contains a hidden nonlinear term, this does not apply.

## Methodology note

This was found by asking what makes the affine case cheap, rather than by tuning it: the
answer is that the unknowns are *linear*, so the cost is a matrix solve. That question —
"is the leak distributional or structural?" — is what separated this family from everything
the campaign's statistics could detect.
