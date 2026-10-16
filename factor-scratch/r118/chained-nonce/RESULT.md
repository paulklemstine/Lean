# RESULT — chained nonces: the leak can be the signature stream itself

Round 118, `factor-scratch/r118/chained-nonce/attack.sage`.
**Status: SUPPORTED (12/12 for `D = 1…4`, ground truth `d·G = Q` verified). A new attack
class: no side channel of any kind is required.**

## The idea

Every axis in this campaign assumed an *external* leak — a side channel, a bias, a shared
RNG state. But the nonce generator has access to public data too, and if it feeds any of it
back, the leak is *inside the signature stream*:

```
k_{i+1} = Σ_{j=1..D} a_j g_j(r_i, s_i, z_i) + Δ        (g_j public; a_j, Δ secret)
```

e.g. `k_{i+1} = a·r_i + b` — an RNG that mixes the previous signature's `r` value into its
state. The unknowns are exactly the structural family `(a_1..a_D, Δ, d)`, but the *signals*
are published values, so the attack needs **only the signatures**.

## The measurement

The first nonce lies outside the family (it is the RNG seed), so it yields no equation and
the threshold is `D+3` rather than `D+2`. On secp256k1, 12 trials per cell:

```
D    t = D+3      recovery        t = D+2     recovery
1       4         12/12              3          0/12
2       5         12/12              4          0/12
3       6         12/12              5          0/12
4       7         12/12
```

`D+3` signatures, one linear solve, `d·G = Q` verified.

## Why this is a different threat model

| | leak source | attacker needs |
|---|---|---|
| distributional (Fourier/lattice) | nonce *distribution* | a side channel |
| structural (affine span) | nonce *structure* | knowledge of the public signals (+ a seed signature) |
| **chained** | the **signature stream itself** | **only the published signatures** |

The last row is the point: for a chained RNG the "leakage" is data the attacker already has.
There is no side channel to mount, no bias to measure, and no shared state to assume — the
attack is *ciphertext-only* in the signature sense.

## What it covers

Any RNG that mixes public data back into the nonce: the previous `r` or `s` value, the
message hash, a timestamp, or a counter — the plausible shape being a "self-feeding" or
"chained" entropy design that reuses a previous output as its state. With `D = 1` (one public
signal, e.g. the previous `r`), **four signatures break the key**.

## Precondition

The nonce must be *exactly* affine in public values with the affine parameters secret and
*constant* across signatures, and the seed nonce must not itself be in the family (which is
what costs the extra signature). Per-signature noise is fatal, as measured in
`r118/structural-noise/`.
