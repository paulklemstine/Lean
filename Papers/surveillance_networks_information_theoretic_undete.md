# Computational Evidence — Information-Theoretic Undetectability of Surveillance

We record the small-case computations that motivated the theorems in
`RateDistortion.lean`.

## 1. Counting the configuration space

A directed social network on `n` nodes is an adjacency relation
`Fin n → Fin n → Bool`, so the number of instantaneous configurations is

| n | # configurations = 2^(n·n) | bits = n·n |
|---|-----------------------------|------------|
| 1 | 2                           | 1          |
| 2 | 16                          | 4          |
| 3 | 512                         | 9          |
| 4 | 65536                       | 16         |
| 5 | 33 554 432                  | 25         |

The bit count `n²` is exactly `log₂` of the configuration count, confirming the
prediction of the reconstruction bound `directed_network_bits`.

## 2. Perfect reconstruction forces an injective channel

For `n = 1` there are two configurations (the self-loop present or absent). An
observation channel `obs` into an alphabet of size `1` cannot separate them, so
no decoder recovers the network — matching `privacy_no_recon`. With an alphabet
of size `2`, the identity channel reconstructs perfectly, matching the tightness
statement `exists_surveillance_iff` (`|S| ≤ |M|`).

## 3. Rate–distortion covering, sampled

Take the Hamming dissimilarity `d(x,y) = #{edges where x, y differ}` on the
`n = 2` network space (`|S| = 16`).

* Distortion budget `D = 0`: every ball is a single point (`B = 1`), so the
  covering bound gives `rate ≥ 16` — perfect surveillance.
* Distortion budget `D = 1`: each ball (a configuration together with its
  single-edge neighbours) has `B = 1 + 4 = 5`, so `rate ≥ ⌈16/5⌉ = 4`.
* Distortion budget `D = 4`: one ball already covers all `16` configurations
  (`B = 16`), so `rate ≥ 1` — perfect privacy becomes feasible.

This is precisely the `rate = 1` corner isolated by `privacy_forces_ball_cover`:
a private observer can meet a distortion budget only once a single ball swallows
the whole network.

## 4. Counterexample hunt

We searched for a channel on a two-configuration network that is simultaneously
constant (perfectly private) and injective (perfectly surveilling). None exists:
a constant map identifies the two configurations while an injective map separates
them, a direct contradiction. This is the finite-network mutual-exclusivity
theorem `privacy_surv_exclusive`, and no counterexample was found for any tested
`n ≥ 1`.
