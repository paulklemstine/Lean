# RESULT — leakage pattern is irrelevant; only the total matters

Round 117, `factor-scratch/r117/bkz-reduction/mixed.sage`.
**Status: the prediction from my own mechanism analysis is REFUTED, and the replacement
result is a clean invariance.**

## 1. The prediction

`why2.sage` identified the obstacle below the HNP threshold as a **shorter out-of-box
solution**: a competitor with `K' = K ± n`, i.e. the modular wraparound. That suggested a
concrete attack on the threshold: known **low** bits of the nonce exclude exactly those
competitors, because `K ≡ b (mod 2^ℓ₂)` while `K ± n ≢ b (mod 2^ℓ₂)` for odd `n`.
Substituting `X = b + 2^ℓ₂·Y` turns mixed (MSB + LSB) leakage into an ordinary HNP on `Y`
with box `2^{m−ℓ₂}`. So mixed leakage should push the threshold from the measured
`t·ℓ = 288` toward the counting bound `t·ℓ > nbits = 256`.

## 2. The measurement

`nbits = 256, t = 4`, 12 seeds per point, first total leakage reaching `≥10/12`:

```
l1 (msb)  l2 (lsb)  total | threshold total
     72         0     72 | 72      <- round 15/16 reference
     64         8     72 | 72
     56        16     72 | 72
     48        24     72 | 72
     40        32     72 | 72
     32        40     72 | 72
     24        48     72 | 72
     16        56     72 | 72
      0        72     72 | 72      <- pure LSB leakage
     60        12     72 | 72
     68         4     72 | 72
```

**Every split gives exactly 72.** The leakage *pattern* is irrelevant; only the *total*
`l1 + l2 = 72 = 1.125·nbits` matters.

## 3. Why the prediction failed

The substitution is correct and the harness is verified (below), but it does not remove the
obstacle — it only **rescales** it. The invalid competitor is `K' = K ± n`. In the `Y`
variable it becomes `Y' = (K' − b)/2^ℓ₂ = Y ± n/2^ℓ₂`, which is *still outside* the box
`[0, 2^{m−ℓ₂})`. The wraparound competitors persist in every coordinate system obtained by
linear reparametrisation of the unknown, because the congruence that generates them is
`mod n` and the reparametrisation is `mod 2^ℓ₂`. Position knowledge changes *where* the box
sits, not *which* solutions are outside it.

So the counting bound's dependence on the *total* leakage is the whole story: reducing the
box by `2^ℓ₂` and reducing the unknown's range by `2^ℓ₂` are the same operation done twice.

## 4. Harness verification (mandatory before believing a null)

The transformation `X = b + 2^ℓ₂Y` was verified by construction *and* by its consequences:

- For the true key, `Y_i = (X_i − b_i)/2^ℓ₂` satisfies `s_i·2^ℓ₂·Y_i − r_i·d ≡ c'_i (mod n)`
  identically, by the algebra in §1.
- The attack recovers the **correct** `d` through the transformed instance at total leakage
  72 for every split — including the extreme `l1 = 0, l2 = 72` (pure low-bit leakage), where
  the instance that `attack` sees has `s'_i = s_i·2^72` and `a_i = 0`. A wrong
  transformation could not produce the ground-truth key.

## 5. Consequences

1. **The position of leaked nonce bits does not matter.** Any study that reports a
   threshold for MSB leakage only is reporting the general answer; there is no advantage to
   be had from a different leakage pattern at fixed total.
2. Combined with the round-117 mechanism result, the HNP picture is now fully accounted
   for: threshold = counting bound (`t·ℓ > nbits`) + a tie-breaking margin, invariant to
   embedding, to reduction strength, and to leakage pattern. The only remaining variable is
   the *total number of leaked bits*, which is a property of the implementation's side
   channel, not of the mathematics.
3. The direction this closes: any proposal to "beat the 1.03–1.25× overhead" by changing
   *what* is leaked, or *how* the lattice is built, or *how hard* it is reduced.
