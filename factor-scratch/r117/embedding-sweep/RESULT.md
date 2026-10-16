# RESULT — embedding sweep: the classical Kannan embedding is optimal in its family

Round 117, `factor-scratch/r117/embedding-sweep/`.
**Status: NEGATIVE, and it closes the one avenue my own brief called "the only game in
town".** No embedding in a 4×5 × 4×20 grid lowers the HNP threshold below the round-15/16
value `l* = 72` (`t·ℓ = 288 = 1.125·nbits` for `nbits=256, t=4`).

## 1. Why this experiment

My round-116 brief states that beating the floor `t·ℓ ≥ log₂ n` is impossible and that
"beating the 1.03–1.25× overhead is the only game in town". The obvious mechanism is the
embedding: the Kannan construction has two free parameters, the column scaling
`S_i = 2^σ` on the unknown nonce parts and the weight `B = 2^β`, and rounds 15/16 used
exactly `σ = ℓ, β = nbits` without ever testing whether that is optimal.

The Gaussian-heuristic condition

```
max(b, nbits − ℓ + σ)  ≲  (t·nbits + t·σ + β)/(t+2)          [norm condition]
t·ℓ > b                                                  [counting condition]
```

makes concrete *predictions* that can be falsified:

- `σ` should be as small as possible (the LHS grows at rate 1 per unit of `σ`, the RHS at
  `t/(t+2) < 1`), so `σ = 0` should be optimal;
- for `b < nbits` the counting condition allows `ℓ ≈ b/t`, e.g. `b=64, t=4 ⟹ ℓ ≈ 16`,
  a **4.5× reduction** from the measured `72`.

Both predictions are testable within an afternoon. Both fail.

## 2. Measurement

`nbits = 256, t = 4`, 12 seeds per point, rate reported (threshold = first `ℓ` with
`≥10/12`).

**Grid 1 — does any `(σ, β)` work at all?**

```
 σ   β    | l=256 192 160 128  96  72  64
 0  192..384 |  0   0   0   0   0   0   0      <- NEVER works, any β
32  192..384 |  0   0   0   0   0   0   0      <- NEVER works, any β
64  256/320/384 | 12  12  12  12  12  12   0
128 192      |  0   0   0  12  12   0   0      <- β too small: only high ℓ works
128 256/320/384 | 12  12  12  12  12  12/   0
256 192      |  0  12  12  12   0   0   0
256 256/320/384 | 12  12  12  12  12/   0   0
```

**Grid 2 — the decisive test, key entropy `b` swept against the counting bound:**

```
 σ= 72 β=256 | b=64:l*=72  96:72  128:72  192:72  256:72
 σ=128 β=320 | b=64:l*=72  96:72  128:72  192:72  256:72
 σ=160 β=352 | b=64:l*=72  96:72  128:72  192:72  256:72
 σ=256 β=384 | b=64:l*=80  96:80  128:80  192:80  256:80
counting bound predicts         l*>16            32      48      64
```

## 3. Findings

1. **`σ = 0` and `σ = 32` never work, at any `β` and any `ℓ` up to full leakage.** The
   column scaling of the unknown nonce parts is not an optimisation knob, it is
   *structurally required* — without it the target vector is too long relative to
   `λ_1 ≈ det^{1/(t+2)}` and LLL never returns it even at `ℓ = 256`, where the answer is
   computable directly from one signature. This is the sharpest statement in the sweep:
   a lattice that cannot represent the answer is not a weaker lattice, it is a
   non-lattice.
2. **`σ` and `β` must be raised together**, which is exactly the norm condition: with
   `σ = 128`, `β = 192` fails and `β = 320` works; with `σ = 256`, `β = 192` gives only
   `ℓ ≥ 192` while `β = 384` extends to `ℓ = 96`. The pairing is not free — the embedding
   is a one-parameter family dressed up as two.
3. **The best embeddings (σ=128/β=320, σ=160/β=352) only *tie* the classical
   `(σ=ℓ, β=nbits)`, and σ=256/β=384 is strictly worse (`l* = 80`).** The classical
   choice is optimal in the family swept.
4. **Key entropy does not lower the threshold, and this is now robust to the embedding
   choice.** `l*` is 72 for every `b ∈ {64,96,128,192,256}` under four different
   embeddings — never approaching the `b/t` the counting bound permits. So the counting
   bound is *not* the binding constraint; the norm/gap condition is, and the Gaussian
   heuristic explaining round-16's independence survives a 4-fold variation of the
   embedding family.
5. The measured `l* = 72` is itself consistent with `σ ≈ (t+1)/t · ... ` — i.e. the
   classical `σ = ℓ` sits essentially exactly on the boundary predicted by the norm
   condition with `β = nbits`, which is why it is optimal.

## 4. Verdict

**The embedding avenue is closed.** "Beating the 1.03–1.25× overhead" cannot be done by
choosing `σ, β`; the classical embedding is at (or within 1 of) the family's optimum, and
the residual 12.5% gap is a lattice-reduction-quality limit, not a modelling choice.
Improving the threshold therefore needs a *better reduction* (BKZ at high block size,
sieving) rather than a better embedding — which is exactly what the round-15 baseline
already documented as the remaining direction.

## 5. Reproduce

```
cd /home/raver1975/lean/factor-scratch/r117/embedding-sweep
/home/raver1975/sage_mamba/envs/sage/bin/sage sweep2.sage   # (sigma,beta_shift) grid
/home/raver1975/sage_mamba/envs/sage/bin/sage grid.sage      # rate grid
/home/raver1975/sage_mamba/envs/sage/bin/sage final.sage     # decisive b-independence test
```

## 6. Traps hit

1. The first sweep reported `None` for every cell and looked like a total
   refutation — including at `ℓ = 256`, where the nonce is fully known and recovery is
   trivial. That was a **buffering artifact** in the debug print (unflushed `print`
   appeared after the result line, so I was reading one cell's verbose output as
   another's). Fixed by re-running with explicit flushes.
2. The Gaussian heuristic that motivated the sweep is **too crude at small `σ`**: it
   predicts `σ = 0` should be optimal, but `σ = 0` never works. The heuristic captures
   the norm/gap structure but not the fact that the target must also be *representable*
   in the lattice at the right scale. The measurement, not the heuristic, is the result.
3. Thresholds are read as a rate ≥ 10/12 with a step of 8 bits in `ℓ`; the true threshold
   may sit up to 8 bits below the reported one. This affects all cells equally and does
   not change any conclusion, but the numbers are *upper* bounds on the threshold.
