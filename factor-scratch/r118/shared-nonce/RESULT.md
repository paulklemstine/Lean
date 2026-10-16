# RESULT — a shared nonce structure breaks L keys with ~1 signature each

Round 118, `factor-scratch/r118/shared-nonce/` (`attack.sage`, `asym.sage`).
**Status: SUPPORTED (12/12 and 5/5 configurations, ground truth `d_k·G = Q_k` verified).**
This is the strongest amplification in the campaign, and it follows from the structural-nonce
results rather than from any new machinery.

## The setup

If `L` keys are signed from **one** nonce stream — `k_s = Σ_j a_j g_j(s) + Δ` with the *same*
`(a_j, Δ)` for every key (one badly-seeded RNG, a restored VM snapshot, a shared device state)
— then all the signature equations are linear in

```
unknowns: (a_1..a_D, Δ, d_1..d_L)     = D + 1 + L
equations: one per available signature
```

so the threshold is `Σ_i t_i ≥ D + 1 + L`, and the *average* cost per key is
`1 + (D+1)/L`, which tends to **one signature per key**.

## The asymmetric allocation — the real payoff

The bound is on the *total*, so the allocation need not be uniform. Giving `D+1` keys two
signatures and the rest one, for a total of exactly `L+2`:

```
 L    total sig   bound L+2   keys broken   broken from ONE signature
 3        5           5         3/3              1/1
 5        7           7         5/5              3/3
 8       10          10         8/8              6/6
10       12          12        10/10             8/8
20       22          22        20/20           18/18
```

**Every key falls, including the `L−2` keys that contributed only one signature.** At `L=20`,
22 signatures destroy 20 private keys, with 18 of them recovered from a single signature
each. The mechanism is exactly the algebra: `D+1` equations determine the shared structure
`(a_j, Δ)` jointly, and *then each key's `d_k` is pinned by a single equation* — the shared
structure supplies the rest of the information.

## Contrast with the single-key case

| | signatures per key |
|---|---|
| one key alone, structural leak | `D + 2` (measured exactly) |
| `L` keys sharing the structure | `1 + (D+1)/L` → **1** as `L → ∞` |

## What it means

A service that draws all its nonces from one shared stream — a single seeded RNG, a
restored-VM snapshot, a shared hardware module, or a forked cloud instance — does not lose
one key if its nonces leak; it loses **all of them, at roughly one signature each**. This is
the amplification that makes structural leaks categorically worse than distributional ones:
the distributional threshold scales with `n`, and this one scales with `1/L`.

## Precondition

The `D` signals `g_j(s)` must be public (they can be counters, timestamps, or previous
signature values), the affine parameters must be *shared* across the keys, and the
`(D+2)×(D+2)`-shaped systems must be invertible mod `n`.

## Ground-truth note

The first run reported `a` and `Δ` recovered but **zero** keys broken, which is impossible
for an exactly-determined system with invertible `r_i`. The cause was a ground-truth bug in
the instance generator (a list comprehension drew a different random for the tuple's first
element than the `d` used to build the public key, so the signing key and the checked public
key did not correspond). Fixed before any claim was made — the same class of error as the
four false nulls earlier in this campaign.
