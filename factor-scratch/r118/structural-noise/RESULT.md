# RESULT — the structural attack is exact, not approximate

Round 118, `factor-scratch/r118/structural-noise/attack.sage`.
**Status: SUPPORTED, and it scopes the attack precisely.** The structural (affine-span)
attack's power is its exactness; this measures what exactness buys and what it costs.

## The dichotomy

Two kinds of imperfection in the nonce, two opposite outcomes, on secp256k1 with `D = 1`
signals, 12 trials per cell, ground truth `d·G = Q`:

**(a) Shared noise — absorbed.** `k_s = Σ_j a_j g_j(s) + Δ + E` with `E` one more unknown
constant:

```
|E|      t = D+3     recovery
2^8       4          12/12
2^32      4          12/12
2^64      4          12/12
2^128     4          12/12
```

The noise becomes one more unknown, so the threshold is simply `D+3`, and the attack is
**completely insensitive to the size of the shared noise** — an offset of `2^128` bits
(half the modulus) costs exactly one extra signature.

**(b) Per-signature noise — destroys.** `k_s = Σ_j a_j g_j(s) + Δ + e_s` with `e_s` unknown
per signature:

```
|e_s|    t = D+2     recovery          t = D+3 (overdetermined)
2^4        3           2/12                 --
2^8        3           0/12                0/12 (inconsistent)
2^16       3           0/12                 --
2^128      3           0/12                0/12
```

The exactly-determined solve returns values fitting the *noised* nonces, not the true ones;
with an extra equation the system is inconsistent and the solve has no solution at all.

## What this means

1. **The structural attack is exact, not approximate.** It does not degrade gracefully with
   noise; it switches off. That is the opposite of the distributional attacks, whose
   thresholds are *statistical* and therefore degrade smoothly.
2. **It targets deterministic nonce bugs, not jitter.** The attack applies when the nonce is
   exactly — or exactly-plus-a-shared-offset — affine in public signals: a counter, a
   timestamp-collapsed value, a polynomial recurrence, a seeded stream. Per-instance jitter
   (an RNG with any per-call variation) kills it.
3. **The shared-noise result is more useful than it looks.** "Shared" includes a per-key
   offset, a device constant, or a global salt — all of which are absorbed at a cost of one
   signature each. In the shared-structure setting, one shared noise term across `L` keys
   costs one signature *in total*.

## The scoping statement for the campaign

| leak | behaviour with noise |
|---|---|
| distributional (Fourier / lattice) | statistical threshold, degrades smoothly |
| structural (affine span) | **exact**: shared noise absorbed (+1 signature each), per-signature noise fatal |
