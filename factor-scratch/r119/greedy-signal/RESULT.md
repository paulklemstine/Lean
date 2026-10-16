# RESULT — greedy signal discovery: the structural attack is model-agnostic

Round 119, `factor-scratch/r119/greedy-signal/attack.sage`.
**Status: SUPPORTED (8/8 detection at every `D`, 0/24 false positives).** This turns the
structural attack from *model-dependent* into *model-agnostic*, and it dominates the
model-free collision detector found in `r119/endomorphism`.

## The gap it closes

Round 118 established that nonces affine in `D` public signals — `k_i = Σ_j a_j g_j + Δ` —
fall to one linear solve in `D+2` signatures. The catch was that the attacker must *know*
the signals `g_j`. `r119/endomorphism` then found a *model-free* detector (collision counts
reveal structured nonces) but quantified its cost at `t ≳ 3√(2n) = 2^130` signatures on
secp256k1. So the field had: cheap-but-model-dependent, or model-free-but-infeasible.

## The algorithm

Greedy feature selection, testing consistency of an **overdetermined** system after each
addition:

```
for deg = 1, 2, 3, ...:
    build the system with features (z, z², …, z^deg) and (deg+2)+1 signatures
    if the system is CONSISTENT: model found, stop
```

With `(D+2)+1` equations and `(D+2)` unknowns, a non-affine nonce set satisfies the system
with probability `≈ 1/n`, so a consistency hit is essentially certain evidence.

## Measurement (secp256k1, `n = 2^256`, real signatures, `d·G = Q` ground truth available)

```
 true D   t available   additions needed   detection
   1         4/6/9            0            8/8
   2         5/7/10           1            8/8
   3         6/8/11           2            8/8
   4         7/9/12           3            8/8
NULL CONTROL (non-affine nonces): 0/24 false positives (predicted ≈ 1/n = 2^-256)
```

- **Additions needed = `D − 1`** — the model is discovered at degree exactly `D`, after
  `D−1` failed additions. Total cost `D` linear solves.
- **Detection is perfect** (8/8) and **independent of how many extra signatures** are
  available (`t = D+3` suffices; more does not help, because the system is already
  over-determined by one equation).
- **False-positive rate ≈ 1/n**, measured at 0/24.

## The resulting trade-off

| detector | needs the model? | signatures needed |
|---|---|---|
| collision counts (`r119/endomorphism`) | no | `t ≳ 2^130` on secp256k1 — infeasible |
| **greedy consistency (this file)** | no (discovers it) | **`t = D+3`, cost `D` linear solves** |

So the model-free route *is* practical — it just isn't the statistical one. The greedy
consistency test subsumes it and works at ECDSA scale.

## What it means

- **Offensively:** an attacker with a signature corpus and no knowledge of the nonce design
  discovers the vulnerable structure in `D` linear solves and then breaks the key. The
  structural attack no longer needs a prior on the RNG.
- **Defensively:** the same test is an *audit*. A defender can run it over a signature corpus
  to find out whether their nonces are affine in anything public — a free, model-agnostic
  vulnerability check with a `2^-256` false-positive rate.
- **The catalog connection is real:** this is exactly the greedy-selection procedure
  formalized in `Cryptography/UniversalRedundancy*.lean` (`greedySeq`,
  `shtarkov_submodular`, `greedy_one_sub_inv_exp_le`) — there over libraries and mutual
  information, here over signal features and algebraic consistency. The transfer is a
  comment, not a proof; the honest statement is that the algorithm shape is the same.

## Precondition and limitation

- The signal family must be *polynomial in the message hash* (or in any public feature the
  attacker can enumerate). If the true signal is a non-polynomial public function, greedy
  over monomials will not find it — though any feature set can be substituted in the same
  loop, so the method degrades to "you must be able to enumerate candidates."
- The nonce must be *exactly* affine; per-signature noise is fatal (`r118/structural-noise`).
