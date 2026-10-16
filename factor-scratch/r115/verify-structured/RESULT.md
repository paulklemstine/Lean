# VERIFICATION NOTE — structured-nonce worker (r115/hnp-structured-nonce)

Independent re-check by the lead. Every verdict below was re-verified, and where my first
independent implementation disagreed with the worker I traced the disagreement to **my own
construction**, not theirs.

## Verdicts: all four confirmed

| sub-axis | worker verdict | verified? |
|---|---|---|
| I1 r-statistics detector | REFUTED | **confirmed** (mechanism, see below) |
| I2 LCG, known `a` | SUPPORTED | **confirmed** — re-ran their `exp_i2.sage` |
| I2 LCG, secret `a` | REFUTED | **confirmed** — re-ran their `exp_i2b.sage` |
| I6 GLV sublattice embedding | REFUTED | **confirmed** (with a precision correction) |

### I2 (known multiplier) — the positive, reproduced

Re-run of `exp_i2.sage 20 20261014 909090` (toy curve, `n` 61 bits, `m = 59`):

```
ell=0:  t=3 0/20 | t=4 18/20 | t=5 19/20 | t=6 20/20 | t=8 20/20   (LCG)
        plain HNP at ell=0: 0/20 at every t -- and it can NEVER work at ell=0
ell=1:  t=4 20/20 ... plain 0/20
ell=16: t=3 20/20 | t=4 19/20 | t=5 20/20 ... plain needs t>=4
```

So the claim holds: **known multiplier + zero nonce leakage recovers the key from 4–6
signatures**, and it is not vacuous (the plain HNP needs ~61 signatures at ℓ=1, i.e.
`t·ℓ ≈ 61`, and is hopeless at ℓ=0).

**My independent attempt refuted this and I was wrong.** I implemented the closed form
`k_i = a^i k_0 + b·Σ_i`, which makes the carry unknowns `q_i ~ a^i/2^m` grow like `2^{m(i−1)}`
— at `m=59, t=4` that is `2^177`, so the target vector is not short and no lattice can find
it. I measured 0/12 and nearly reported the worker's positive as unverified. Their
construction uses the **second difference** `k_{i+2} − k_{i+1} = a(k_{i+1} − k_i)`, whose
coefficients are bounded by `a` (not `a^i`) and whose known parts cancel, so the recurrences
constrain the unknown residues alone and the target stays short. **The lesson generalises:
a "failed reproduction" of a lattice claim must be checked for a formulation that cannot
represent the target before it is read as a null.**

### I2 (secret multiplier) — refuted, reproduced

`exp_i2b.sage`: the linearised lattice over `(ε, γ, a, b, d)` is 0/20 at every parameter
point, including `ℓ=8, t=16` and `ℓ=16, t=4` where the plain HNP on the *same instances* is
20/20. The bilinear term `a·ε_i` has to be linearised away and the resulting
`γ_i = a·ε_i ~ 2^{2m}` dominates the solution vector. Confirmed.

### I1 — refuted; the mechanism is worth stating precisely

The `r`-value does carry a large fingerprint (TV ≈ 0.98 against uniform), and for a reason
that is a **property of the curve, not of the nonce**: `r = x(kG) mod n`, and only about
half of `F_p`'s elements are valid x-coordinates at all. The nonce-dependent term is
`2c(n−c)/(pn)` with `c = #E`-dependent structure — the worker's measured value
`2^-126.65`, i.e. ~10^77 signatures are needed. No feasible sample size separates a uniform
nonce from a biased one, so the detector is dead even though the *statistic* is large.

### I6 — refuted, but the "density exactly 1.0" phrasing needs correcting

The empirical result stands: at matched leakage the GLV sublattice embedding is 0/40 where
the plain range embedding is 31–40/40.

On the density claim, three separate measurements:

- The worker's own script reports `|image|/n = 0.488, 0.504` for their 15-bit curves,
  `1.000000` for all four of their 16-bit curves, and `~1/2` (with a closed-form collision
  count `2^{(2h+2)}/n = 2`) for the realistic 61-bit case — whose comment reads
  *"1 bit per signature of genuine constraint -- and this is the BEST case"*.
- My independent enumeration over primes with a genuine `λ` (`λ²+λ+1 = 0 mod n`,
  `side = ceil(√n)`) gives coverage `0.896, 0.878, 0.831, 1.000` (mean `0.901`).

So the summary email's "density exactly 1.0" is accurate for the four nb-even curves the
worker enumerated but **generalises badly**: the density is `0.5 … 1.0` depending on the
curve. The conclusion is unaffected — even the best case gives at most ~1 bit of constraint
per signature, and a "sublattice" constraint that excludes half of the group is not a
sublattice constraint. But the number to quote is a range, not `1.000`.

## Net effect on the campaign

- The one **positive** in this round is I2: **a published LCG multiplier in the nonce
  generator is a genuine full break** — the private key falls in 4–6 signatures with zero
  side-channel leakage. That is an implementation-level finding of the kind that actually
  matters, and it is now verified end to end.
- The three refutations (secret multiplier, GLV sublattice, r-statistics) close the
  "structured nonce" family and are consistent with the round-117 mechanism: all three are
  cases where the structure either cannot be linearised (bilinear), is empty (GLV box), or
  is a property of the curve rather than the nonce.
