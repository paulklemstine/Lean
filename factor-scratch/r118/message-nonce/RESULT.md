# RESULT — message-dependent nonces: `t* = D+2`, `m* = D+1`, and the exact rank law

Round 118, `factor-scratch/r118/message-nonce/` (`attack.sage`, `ranklaw.sage`).
**Status: SUPPORTED, with a complete characterization.** Nonces that are affine in the
message hash are the cleanest structural case — the signals are public and known before
signing — and the algebra turns out to be fully predictable.

## The attack

```
k_i = Σ_{j=1..D} a_j g_j(z_i) + Δ        (g_j public functions of the message hash)
```

Substituting into `s_i k_i = z_i + r_i d (mod n)` gives a system linear in the `D+2` unknowns
`(a_1..a_D, Δ, d)`, and the minimum is reached because there is no seed nonce outside the
family: **`t* = D+2`**.

Measured on secp256k1, 12 trials per cell, `d·G = Q` verified:

```
D   t   recovered        t-1   recovered
1   3     12/12           2      0/12
2   4     12/12           3      0/12
3   5     12/12           4      0/12
```

## The rank law — repeated messages are tolerable, to an exact bound

Each row is `s_i·(λg_i, 1, 0) + r_i·(0,0,−1)`, so the row space is spanned by the distinct
signal directions **plus one** `r`-direction:

```
rank ≤ (distinct messages) + 1
```

The measurement confirms this *and* its tightness — the rank is exactly `m+1` for `m` distinct
messages, and the attack succeeds exactly when `m ≥ D+1`:

```
D   t   m (#distinct msgs)   recovered    rank
1   3   1                     0/12        2
1   3   2                    12/12        3
1   3   3                    12/12        3
2   4   1                     0/12        2
2   4   2                     0/12        3
2   4   3                    12/12        4
3   5   2                     0/12        3
3   5   3                     0/12        4
3   5   4                    12/12        5
```

Every cell matches the law in both directions: `m = D` gives rank `D+1 < D+2` and fails;
`m = D+1` gives rank `D+2` and works.

So the practical rule is:

> **`D+2` signatures on at least `D+1` distinct messages break the key, by one linear solve.**

Repeated messages are *not* fatal — two signatures on each of `D+1` distinct messages work
fine, because the `(s_i, r_i)` variation supplies the missing row direction. What is fatal is
having *fewer than `D+1` distinct messages*, and that failure is a **detectable rank drop**,
not a silent one: the attacker computes the rank first and knows whether the system is solvable.

## Consequence: distinguished points for the attacker

Because the failure is a rank condition on *public* data, an attacker can *check in advance*
whether a signature corpus is attackable, and a defender can check whether it is safe — the
same public information. For `D = 1` (nonce = a·hash + salt): **3 signatures on 2 distinct
messages** break the key.

## Precondition

The nonce must be exactly affine in public functions of the message with the affine
parameters secret and constant. Per-signature noise is fatal (`r118/structural-noise/`).
