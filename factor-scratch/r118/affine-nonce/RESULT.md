# RESULT — a new attack model: nonces affine in a public sequence with one secret offset

Round 118, `factor-scratch/r118/affine-nonce/attack.sage`.
**Status: SUPPORTED (20/20, ground-truth verified). A break that uses no lattice, no Fourier
transform, and no leakage budget.**

## The model and the attack

Signing nonces of the form

```
k_i = c_i + Δ          c_i public (counter, timestamp, message index), Δ secret
```

or, more generally, `k_i = a·c_i + Δ` with `a` public. Substituting into
`s_i k_i = z_i + r_i d (mod n)` gives

```
s_i c_i + s_i Δ − r_i d = z_i (mod n)
```

— a system **linear in the two unknowns `(Δ, d)`**. Two signatures give a 2×2 system,
generically invertible, so the private key falls immediately.

## Measurement (secp256k1, ground truth `d·G = Q` checked)

```
nonce = counter + secret offset :  20/20 trials, 2 or 3 signatures, d*G == Q, Δ recovered
nonce = a*counter + offset (a public) : 20/20 trials, 3 signatures, d*G == Q
```

## Why this matters relative to everything else in the campaign

- **It is invisible to every statistic measured here.** The nonces are uniform-looking, so
  `p = ½`, `A = 0`, and the Fourier attack is inert; there is no MSB bias, so the lattice
  threshold is irrelevant. The leak is not in the nonce's distribution at all — it is in its
  *structure*, and structure is what a distributional test cannot see.
- **It is the special case the campaign blocked for the wrong reason.** The `bias-model` axis
  asked what happens when nonces share an unknown bias and stalled on a lattice construction.
  The affine sub-case needs no construction at all: one unknown offset is a linear unknown.
- **It is a plausible implementation shape.** A counter plus a per-key constant, or an RNG
  seeded per key, produce exactly this. The public sequence needs no secrecy — a timestamp
  or a message counter suffices.

## Precondition

The public sequence must be *known and distinct per signature*, and the offset must be the
*only* secret in the nonce. If `c_i` is itself secret or repeats, this does not apply.
