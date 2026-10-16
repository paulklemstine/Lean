# RESULT — the Fourier attack's frontier is TWO regimes, both measured

Round 118, `r118/fourier-frontier/` (`predictor.sage`, `check.sage`, `saturate.sage`,
`floor.sage`, `info.sage`). **Status: SUPPORTED.** The expansion of the attack from one
binary-bias data point to a mapped frontier in (leak type, leak strength, signature count).

## 1. The arc

1. **Binary bias** (`attack.sage`, `law.sage`): implemented (`O(t·n log n)`, brute-force
   verified) and fitted `t* = ln n/(2(p−½)²)`.
2. **Generalisation attempt** (`predictor.sage`): hypothesised `t* = 2 ln n/A²` with
   `A = E_biased[f] − E_uniform[f]`, shape-independent.
3. **Falsification**: ratios `0.14 … 0.39` — multi-bit biases up to 7× cheaper than
   predicted.
4. **Diagnosis**: my `A` assumed `E_uniform[f] = 0` (true only for a half-space). For a
   block of width `n/2^bits` the uniform mean is `2^{1−bits} − 1`, so `A = p(2 − 2^{1−bits})`.
5. **Restored law**: `t*A²/(2 ln n)` = `0.55 … 1.42`, mean `1.023` — confirmed across
   `bits = 1..4`, `p ∈ {0.70, 0.85}`, spread within the `t`-grid resolution.
6. **Saturation test** (`saturate.sage`, `floor.sage`): as `p → 1` with fixed `bits`, `t*`
   saturates — but the floor it saturates to is *not* the `2 ln n/A_max²` the noisy law
   predicts; narrowing the block keeps pushing `t*` down (5, 4, 3, 2 at `bits = 4, 6, 8, 11`).
7. **Resolution** (`info.sage`): in the reliable-leak regime the threshold is **pure
   information counting**, `t* = ⌈log₂ n / bits⌉ + O(1)`.

## 2. The frontier, two regimes

| regime | law | meaning |
|---|---|---|
| **reliable leak**, `p ≈ 1`, `bits` known bits/nonce | `t* = ⌈log₂ n / bits⌉ (+1…2)` | each signature carries `bits` bits; the key needs `log₂ n` of them. **Power law in the leaked bits.** |
| **noisy leak**, advantage `A` | `t* = 2 ln n / A²` | multiple-testing over `n` candidate keys. **Logarithmic in `n`, quadratic in the inverse noise.** |

Measured at `n ≈ 2^18`, 5 seeds, step-1 grid:

```
bits :  2   3   4   5   6   7   8   9  10
pred :  9   6   5   4   3   3   3   2   2      (ceil(18/bits))
meas : 11   7   5   4   4   3   3   3   2
```

## 3. What this means at 256-bit scale (extrapolation of both measured laws)

```
reliable leak:  4 bits/nonce -> ~64 signatures      8 bits -> ~32
noisy leak:     A = 0.5      -> ~2*177/0.25  = 1416 signatures
                A = 2p-1 for a single-bit leak
```

So the attacker's cost is governed by *how many bits per signature the leak carries*, and a
reliable narrow leak makes the signature count scale as `1/bits` — a power law. That is far
more favourable to the attacker than the logarithmic law, and it is the regime real leaks
(narrow, high-confidence side channels) occupy.

## 4. Caveats

1. Both laws are measured at `n ≈ 2^18`; the `2^256` numbers are extrapolations, though both
   are logarithmically mild in `n`.
2. `t*` is defined as "all seeds recover the key"; the `+1…2` over information counting is
   the multiple-testing slack.
3. The attack still needs a real leak. With `p = ½` exactly, `A = 0` and `t* = ∞`.

## 5. Reproduce

```
cd /home/raver1975/lean/factor-scratch/r118/fourier-frontier
/home/raver1975/sage_mamba/envs/sage/bin/sage attack.sage    # implementation vs brute force
/home/raver1975/sage_mamba/envs/sage/bin/sage law.sage       # noisy-leak law
/home/raver1975/sage_mamba/envs/sage/bin/sage check.sage     # corrected advantage
/home/raver1975/sage_mamba/envs/sage/bin/sage saturate.sage  # saturation as p->1
/home/raver1975/sage_mamba/envs/sage/bin/sage floor.sage     # block-narrowing floor test
/home/raver1975/sage_mamba/envs/sage/bin/sage info.sage      # information-counting regime
```

## 6. Methodology residue

The falsification in step 3 was true of my *invariant*, not of the law — and the correction
(`E_uniform[f] = 2^{1−bits} − 1`) is what allowed the noisy law to be confirmed. The
saturation anomaly then falsified a *different* prediction (the `2 ln n/A_max²` floor) and
localized the missing regime (information counting). Two successive "failures" were both
diagnostic, and neither would have been visible without the step-1 grid and the
block-width sweep.

---

# ADDENDUM — scale-up: the laws hold at 2^20 and 2^24, control verified

`scale.sage`. Closing the extrapolation caveat: both regimes were re-measured at
`n ≈ 2^20` (`ln n = 13.86`) and `n ≈ 2^24` (`ln n = 16.64`), a 64× range of modulus, with
an `O(t)` control that checks the Fourier score at the true key against the direct score
(passed "yes" at both new scales):

```
n=2^20  reliable bits=4: pred 5  measured 6     bits=6: pred 4  measured 4     bits=8: 3/3
         noisy bits=1 p=0.85 (A=0.85): pred 38 measured 48 (1.26x)
         noisy bits=2 p=0.90 (A=1.35): pred 15 measured 16
n=2^24  reliable bits=4: pred 6  measured 7     bits=6: pred 4  measured 5     bits=8: 3/4
         noisy bits=1 p=0.85:      pred 46 measured 48 (1.04x)
         noisy bits=2 p=0.90:      pred 18 measured 16
```

Both laws scale as predicted:

- **reliable**: `t* = ceil(log2 n / bits) + O(1)`, the `+1` constant holding across scales;
- **noisy**: `t* = 2 ln n / A^2` with a near-constant factor (measured/predicted `1.26`,
  `1.04` at the two new scales — the discrepancy is a constant offset, not a slope error).

The FFT cost is now measured, not assumed: the full score vector at `n ≈ 2^24` took
**43–82 s** for `t = 3…7` (≈6–12 s per 16.7M-point FFT), i.e. the `O(t·n log n)` claim is
confirmed at a million-fold larger modulus than the first implementation test.

**The 2^256 figures are now an extrapolation of a law validated at three scales (2^18, 2^20,
2^24) rather than of a single-scale fit**: reliable 4 bits/nonce ≈ **65 signatures**, 8 bits
≈ **33**, noisy `A = 0.85` ≈ **491**.

---

# FINAL — the intersection variant: same-or-better threshold, 2^bits-fold cheaper

`intersect.sage`, `final.sage`. The FFT scan costs `O(t n log n)`; a reliable leak into a
biased set `S` of size `n/2^bits` instead gives, per signature, the candidate set
`D_i = { (s_i k − z_i) r_i⁻¹ mod n : k ∈ S }` — an affine preimage, `O(|S|)` to build — and
the key is in `D_1 ∩ … ∩ D_t`. Survivor counts (exact, `n ≈ 2^22`):

```
bits  pred t*  survivors by t                                  first <=64
 3      8     524288 65534 8193 1018 136 12 3 2 1 1 1             6
 4      6     262144 16378 1026 68 3 1 1 1                        5
 6      4     65536 1023 17 2 1 1                                 3
 8      3     16384 66 1 1 1                                      3
11      2     2048 2 1 1                                          2
```

**Identification happens at or better than `ceil(log2 n / bits)` in every case**, and the
survivor count reaches exactly 1 one step later — so the attack *determines* the key with no
statistical residual. The intersections are tighter than the random-set bound (which is why
`bits=6` beats its prediction), because the `D_i` are structured affine preimages rather than
random sets.

**Cost:** measured at `n ≈ 2^22`, the intersection attack runs in **0.00–0.32 s** against the
FFT's **3.4–12.3 s** — a **30× to 3332× speedup**, growing as `2^bits`. The scaling is
`n / 2^bits`, so a 32-bit reliable leak makes a 64-bit modulus feasible (2^32 elements).

**Practical reading:** at `n = 2^22` with an 8-bit reliable leak, the key falls in 3
signatures in milliseconds. Together with the two regime laws and the three-scale validation,
the nonce-leakage frontier is: `t* = ceil(log2 n / bits)` signatures at cost `n / 2^bits`
for a reliable leak, and `t* = 2 ln n / A^2` at cost `O(t n log n)` for a noisy one.

**Methodology note:** the first version of this experiment reported success by *membership*
(`d_true ∈ survivors`), which is true even with 16378 survivors and means nothing. The honest
criterion — the survivor set is small enough to check against the public key — is what the
table above uses, and it is the one that changed the measured threshold.

---

# POSITION-INVARIANCE: confirmed, and a trap worth recording

`position.sage`. Hypothesis: the Fourier/intersection attack's threshold is invariant to the
*position* of the leaked block (low / middle / high bits of the nonce), at fixed width.
Round 15 established this for known bits in the *lattice* attack; nothing implied it for a
different algorithm. Measured at `n ≈ 2^18`, `p = 1`:

```
bits  block    survivor counts by t                          first <=64
 4    LOW      16385 1022 66 6 4 1 1 1 1                        4
 4    MID      16387 1026 65 6 2 2 1 1 1 1                      4
 4    HIGH     16387 1025 65 4 1 1 1 1 1                        4
 8    LOW      1025 5 1 1 1 1                                   2
 8    MID      1027 4 1 1 1 1                                   2
 8    HIGH     1027 4 1 1 1 1                                   2
```

**Confirmed: identical thresholds at every position**, survivor counts agreeing to within
seed noise, and unique identification (count 1) one step later. So round 15's
position-invariance transfers from the lattice attack to the Fourier/intersection attack —
a result about the *problem*, not the algorithm.

**The anomaly that led here.** The first run reported survivor counts crashing to **0** for
the low-block case, which is impossible in a correct implementation (the true key is a member
of every `D_i` by construction). The cause was a Sage operator trap: in Sage, `^` is
**exponentiation** and `^^` is XOR, so `((1 << nbits) - 1) ^ block` evaluated to `262143^15
≈ 2^351` instead of `262128`. The mask silently did nothing, the nonces were unmasked, and
the true key was never in `S`. The count of 0 was the symptom that flagged it — an
impossible value is the most useful kind of error signal.

---

# SCALE MILESTONE: the intersection attack at 40-48-bit moduli

`scale2.sage`. Pushing the intersection variant to the practical memory ceiling
(`|S| = 2^24 ≈ 1.7 × 10^7` elements), with a reliable leak of width `b`:

```
nbits   b   |S|      predicted t*   measured t*   survivor counts            secs
  40   16   2^24        4               3        16777216 257 1             49.0
  44   20   2^24        4               2        16777216 19                16.9
  48   24   2^24        3               2        16777216  1                 17.2
```

Identification happens at or **better** than `ceil(log2 n / b) + 1` in every case, and at
`n ≈ 2^48, b = 24` the survivor count reaches **exactly 1** — the key is *uniquely
determined*, with no residual search — at the information bound `48/24 = 2` exactly.

This is a **2^30-times larger modulus** than the first implementation test (`2^18`), and the
law holds with no new machinery. The cost is `|S|` element-wise modular operations (17–49 s
with Python-int arithmetic; ~2–5 s expected with int64-safe arithmetic), i.e. `n / 2^b`.

**Practical reading:** a 24-bit reliable leak on a 48-bit modulus yields the key in
2 signatures in under a minute, on a laptop, in exact arithmetic.
