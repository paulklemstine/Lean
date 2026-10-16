# RESULT — Axis M/N: the 2-parameter leakage threshold surface, and the small-key question

Round 116, `factor-scratch/r116/mn-threshold-surface/`.
**Status: the round-116 headline claim is REFUTED, and the refutation is quantitative and
reproducible.** The measured threshold is `t·ℓ ≈ c(t) · log₂ n` with
`c(2)=1.03, c(4)=1.125, c(8)=1.25` — **independent of the key entropy `b`**.

## 1. What was claimed and what was measured

The brief (reasoning from the lattice-point count in the box
`{d < 2^b, K_i < 2^m}`) predicted:

> `#(lattice points in box) ≈ 2^b · 2^{tm} / n^t < 1 ⟺ b + t·m < t·nbits ⟺ t·ℓ > b`
> so a key with `b` bits of entropy needs only `b` bits of nonce leakage.

**Measured (nbits = 256 throughout, 12 seeds/point, seeds 0–11):**

```
key entropy b :  16   32   64  128  192  256      <- l swept up to 160, i.e. PAST b
l* (t=4)      :  72   72   72   72   72   72
t·l* (t=4)    : 288  288  288  288  288  288       (ratio 1.125 × 256)

key entropy b :  16   32   64  128  192  256
l* (t=2)      : 132  132  132  132  132  132
t·l* (t=2)    : 264  264  264  264  264  264       (ratio 1.031 × 256)
```

`l*` is *exactly constant* in `b` over a 16-fold range of key entropy. The predicted
`t·ℓ > b` boundary is real as a counting statement but is **not the binding constraint**:
even at `b = 16` and `t·ℓ = 64` (leakage 16× the key entropy) the attack fails.

## 2. Why — the binding constraint is the SVP gap, not the count

The target vector of the Kannan embedding is
`v* = (d, K_1·2^ℓ, …, K_t·2^ℓ, B)` with `|d| ≤ 2^b`, `K_i < 2^{nbits−ℓ}` and `B = 2^{nbits}`.
Because the scaling is `S_i = 2^ℓ`, the scaled nonce coordinates satisfy
`K_i·2^ℓ ≤ 2^{nbits−ℓ}·2^ℓ = 2^{nbits}` — **so `‖v*‖ ≈ √t · 2^{nbits−1}` whatever `b` and
whatever `ℓ` are.** The key's entropy contributes one coordinate out of `t+2` and is
swamped by the nonce coordinates. The det of the embedded basis is
`n^t · B · ∏S_i = 2^{t·nbits + nbits + t·ℓ}`, and the Gaussian-heuristic condition
`‖v*‖ ≲ λ_1 ≈ det^{1/(t+2)}` becomes

```
t·ℓ ≳ nbits − (t+2) + ½(t+2)·log₂t − (t+2)·log₂C ,  C = sqrt((t+2)/(2πe))
```

which contains **no `b` at all**. Numerically it predicts `t·ℓ ≳ 256.2` for `t=4` and
`≳ 257.7` for `t=8`; the measured values are 288 and 320, so the model gets the
independence and the right order but under-predicts the growing overhead. That
residual is the reduction-quality term (LLL degrades with dimension) and it is the
same `(1.03, 1.125, 1.25)` law the round-115 baseline measured — which is the
consistency check: **round 115 measured the `b = nbits` slice of this surface, and the
slice turned out to be the whole surface.**

## 3. Controls

- **Integration check** (demanded by the brief): with `dbits = nbits`, the extended
  harness reproduces every round-115 threshold exactly —
  `(64,2)=33, (64,4)=18, (64,8)=12, (96,4)=28, (128,4)=36, (192,8)=27, (256,4)=72`:
  **7/7 MATCH**. Without this, any change in the harness could hide behind the new result.
- **Negative controls:** `b=128, t=4` at `ℓ = 0` → 0/12; at `ℓ = 32` (`t·ℓ = 128 = b`,
  the predicted boundary) → 0/12; at `ℓ = 64` (`t·ℓ = 256`) → 0/12.
- **Positive control:** same point at `ℓ = 128` (`t·ℓ = 512`) → 12/12.

## 4. Falsifier

The refuted claim would be *revived* if some `b < nbits` shifted `l*` below `72`. The
decisive experiment is exactly the `ℓ > b` sweep above: with `ℓ` swept to 160 while
`b` ranges from 16 to 256, `l*` is 72 in all six cells. The claim is dead for this
construction. (A different lattice scaling that puts the *key* coordinate in the
dominant position is the only obvious way out, and it is not clear one exists — the
nonces are the unknowns that carry the bit-width.)

## 5. Deployment consequence (the useful part)

For a population of `b`-bit keys, the two threats do **not** compose:

| threat | cost | depends on `b`? |
|---|---|---|
| interval/kangaroo DLP on `d` | `2^{b/2}` group operations | **yes** — this is the b-bit threat |
| lattice attack from nonce leakage | `t·ℓ ≈ (1.03…1.25)·log₂ n` bits of side channel | **no** — key entropy buys nothing |

So a low-entropy key is exposed to *kangaroo*, and reducing its entropy does **not**
make it easier to attack with lattice methods. That is the opposite of the brief's
guess, and it means a brainwallet is a 2^(b/2)-work problem and not a
half-cost side-channel problem.

## 6. Reproduce

```
cd /home/raver1975/lean/factor-scratch/r116/mn-threshold-surface
/home/raver1975/sage_mamba/envs/sage/bin/sage integrate.sage   # 7/7 match vs round 115
/home/raver1975/sage_mamba/envs/sage/bin/sage sweep.sage        # controls + 2D surface
/home/raver1975/sage_mamba/envs/sage/bin/sage saturate.sage     # decisive b-independence test
```
`lib.sage` is the round-115 harness extended by one parameter (`dbits`); the extension
is 3 lines and the integration test above is what justifies it.

## 7. Traps hit

- The counting argument is seductive and wrong here: it bounds the *number of
  candidate solutions*, but LLL does not need the solution to be unique in the box —
  it needs the solution to be the *shortest vector*, which is a comparison against
  `det^{1/(t+2)}`, not against 1. Two different questions; the measured threshold
  answers the second one.
- The `ℓ > b` regime is perfectly meaningful (you can leak more bits than the key has
  entropy) and it is what makes the b-independence visible. Sweeping only `0 ≤ ℓ ≤ b`
  would have produced a *false* `t·ℓ ≈ b` boundary at `b = 256` and invisible
  saturation everywhere else. That framing error was in the brief.
