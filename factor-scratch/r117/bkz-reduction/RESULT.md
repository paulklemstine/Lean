# RESULT — why the HNP threshold is what it is: invalid solutions, not reduction quality

Round 117, `factor-scratch/r117/bkz-reduction/`.
**Status: the round-117 claim "the residual overhead is a reduction-quality limit" is
REFUTED and replaced by a measured, mechanistic explanation.** The threshold
`t·ℓ* ≈ (1.03 … 1.25)·nbits` is the counting bound `t·ℓ > nbits` plus a tie-breaking
margin, and the obstruction below it is a *shorter invalid solution*, not a weaker
reduction.

## 1. What was claimed and what was measured

Round 117's embedding sweep concluded that the classical embedding is optimal in its
family and that the residual overhead was "a lattice-reduction-quality limit". That claim
is only worth anything if it is measured, so:

**Experiment 1 — sweep reduction strength.** At `(nbits, t) = (128, 4)` and `(256, 4)`,
threshold `l*` for LLL vs BKZ blocks 8, 10, 14, 20, 30, 40:

```
nbits=128, t=4:  lll 40 | bkz8 40 | bkz10 40 | bkz14 40 | bkz20 40 | bkz30 40
nbits=256, t=4:  lll 72 | bkz10 72 | bkz20 72 | bkz30 72 | bkz40 72
```

**No reduction strength changes the threshold at all.** At dimension `t+2 = 6` a BKZ
block ≥ 6 is *exact* SVP, so this is not "BKZ wasn't strong enough" — exact SVP fails
below the threshold too. Reduction quality is refuted as the explanation.

**Experiment 2 — find the obstruction.** The embedded target vector is
`v* = (d, K_i·2^ℓ, …, B)` with `B = 2^nbits`, so
`|v*|² = B² + EXCESS`, `EXCESS = d² + Σ(K_i2^ℓ)² ≈ 2^{2·nbits}`. Every candidate
solution therefore has norm within a factor `√2` of `B`, and the competition between
them is decided entirely by the lower-order `EXCESS` term. Computing the exact-SVP
shortest `±B` vector and comparing its excess with the true solution's:

```
   l   t*l |  shortest EXCESS is shorter than the true one by   shortest vector valid?
  56   224 |  16.00 bits                                        no (invalid)
  60   240 |   8.00 bits                                        no (invalid)
  64   256 |   0.00 bits (a tie)                                no (invalid)
  68   272 |   0.00 bits                                        -   <- attack starts working
  72   288 |   0.00 bits                                        -   <- round-15 threshold
  80   320 |   0.00 bits                                        -   <- attack works
```

The deficit is **exactly `2·(nbits/t − ℓ)`** — 16, 8, 0 bits for `nbits/t = 64`. At `ℓ = 64`
the competitor merely *ties* the true solution, and a tie is not enough: LLL returns one
of the tied vectors, and the attack fails.

## 2. The mechanism, stated precisely

1. The congruences `s_i K_i − r_i d ≡ c_i (mod n)` have many integer solutions; exactly
   one of them lies in the box `d ∈ [0,n), K_i ∈ [0, 2^m)`. The counting bound
   `#points ≈ 2^n · 2^{tm}/n^t < 1 ⟺ t·ℓ > n` is the condition for that uniqueness.
2. The embedding's `±B` rows realize *all* integer solutions, including the ones **outside
   the box**. An out-of-box solution can be shorter than the true one, because its
   coordinates are free to be near-zero in a way the true one's are not.
3. Below the threshold such a competitor exists and is shorter by `2(nbits/t − ℓ)` bits, so
   exact SVP returns it instead of the key. At the counting bound they tie; a few more bits
   of `ℓ` make the true solution strictly shortest and the attack lands.
4. Hence the measured threshold `t·ℓ* ≈ (1.03 … 1.25)·nbits`: the `0.03 … 0.25` is the
   margin needed to make the true solution *strictly* rather than merely *uniquely* shortest.

## 3. What this closes, and what it leaves open

**Closed.** Both avenues I tested for beating the overhead:
- *embedding choice* (round-117 sweep, 20-point grid): the classical `(σ=ℓ, β=nbits)` is
  optimal in its family, and `σ ≤ 32` never works at all;
- *reduction quality* (this file, LLL → exact SVP): no effect whatsoever.

Both fail for the same reason: the deficit comes from the instance, not from the algorithm.

**Still open, and now precisely targeted.** The obstruction is a *shorter invalid
solution*. The way around it is not a better lattice but a **tighter box** — leakage whose
constraint excludes the out-of-box competitors. Concretely: knowing bits of `k` in the
*middle* (the extended/interval HNP) constrains `K` to an annulus rather than a ball and
would exclude exactly the competitors that beat the true solution. That is the one
direction this analysis points at, and it is a statement about *leakage pattern*, not about
lattice technique. (It overlaps the structured-nonce axis; if that worker reports its
thresholds, re-measure the middle-bit pattern against this mechanism.)

## 4. Reproduce

```
cd /home/raver1975/lean/factor-scratch/r117/bkz-reduction
/home/raver1975/sage_mamba/envs/sage/bin/sage bkz.sage   # reduction-strength sweep
/home/raver1975/sage_mamba/envs/sage/bin/sage why2.sage  # invalid-competitor deficit
```

## 5. Traps

1. The first attempt compared `|v*|` with `λ_1` directly and printed nonsense
   (`|v*| = 256.00 bits` at every `ℓ`). The target's norm is *dominated by `B` and is
   therefore constant in `ℓ`* — the comparison that matters is between the `EXCESS`
   terms. Without that correction the measurement is unreadable.
2. "Shortest `±B` vector" is not the same as "shortest *valid* solution"; the whole
   point is that below the threshold the shortest `±B` vector is invalid. The validity
   test must be applied after the SVP, not before.
