# RESULT — calibration against the published thresholds: the baseline is the *floor* of the family

Round 118, `r118/published-thresholds/`. **Status: SUPPORTED, and it corrects an
over-strong conclusion from round 17.**

## 1. What was measured

On the **verified** round-15 harness (12 seeds per point, first `ℓ` reaching `≥10/12`),
the per-signature threshold `ℓ*` and total threshold `t·ℓ*`:

```
nbits=128:  t=16  -> ℓ*=10  t·ℓ*=160  ratio 1.250
            t=32  -> ℓ*=10  t·ℓ*=320  ratio 2.500
            t=64  -> ℓ*= 5  t·ℓ*=320  ratio 2.500
            t=128 -> ℓ*= 5  t·ℓ*=640  ratio 4.995
nbits=256:  t=32  -> ℓ*=10  t·ℓ*=320  ratio 1.250
            t=64  -> ℓ*=10  t·ℓ*=640  ratio 2.500
            t=128 -> ℓ*=10  t·ℓ*=1280 ratio 5.000
```

Two things fall out:

1. **`ℓ*` is roughly constant in `t` — of order 5–10 bits of leakage per signature** — so
   the total threshold `t·ℓ*` grows *linearly* in `t` at ~10 bits per extra signature, not
   1 bit. The information-theoretic floor is `t·ℓ ≈ n` (e.g. 128 bits total); the plain-HNP
   lattice needs ~10× that at large `t`.
2. The ratio `t·ℓ*/n` grows with the lattice dimension (1.25 → 2.5 → 5.0), i.e. the
   dimension-penalty from round 15 (`1.03 … 1.50` at `t ≤ 16`) becomes severe at `t ≥ 128`.

## 2. The published claims, in the same currency

```
claim                                  n    t     l    t·l   ratio  our ℓ*   our t·ℓ*
Nguyen–Shparlinski (160b,100 sigs,3b) 160   100   3     300   1.875     10      1000
Mulder et al (384b,4000 sigs,5b)      384   4000  5   20000 52.083     10     40000
Mulder scaled (128b,256 sigs,4b)      128   256   4    1024  8.000     10      2560
LadderLeak style (128b,128 sigs,1b)   128   128   1     128  1.000     10      1280
```

**Every published claim sits *below* the plain-HNP threshold measured here** — by 2×
(Mulder), 3.3× (Nguyen–Shparlinski), and 10× (LadderLeak) in bits of leakage per signature.

## 3. The finding, and the self-correction

**The plain-HNP lattice is the *floor* of the leakage-attack family, not its best member.**
The published methods — Fourier analysis (LadderLeak, Mulder), lattice sieving with
predicate (Xu–Dai–Wu–Lin), the wNAF "tale of three signatures" (De Micheli–Piau–Pierrot) —
operate at 1–5 bits per signature, against the ~10 bits per signature the plain HNP lattice
needs. My harness measures only the plain lattice, so any statement of the form "the
minimum leakage is X" made from it is a statement about *that attack*.

**This overrides part of round 17's conclusion.** Round 17 established that the plain-HNP
threshold cannot be improved by choice of embedding (20-point `(σ, β)` sweep) or by
reduction strength (LLL through exact SVP), and I closed the avenue with "beating the
overhead needs better reduction; the residual is intrinsic." The first half stands — the
*plain lattice's* overhead really is intrinsic. The second half was too strong: **the
literature does beat it, by 2–10× in per-signature leakage, using different algorithms
(Fourier/sieving) rather than better lattices.** The correct statement is:

> the plain HNP lattice's threshold is `~10` bits of leakage per signature at large `t`,
> intrinsic to that lattice; the best known threshold is `1–5` bits per signature.

## 4. Consequences

1. The round-15 baseline table (`1.03–1.25 × log₂ n`) is valid but is **not** the attack
   frontier; it is the floor. Never quote it as "the minimum leakage required".
2. The campaign's own literature table quotes those published claims without a
   same-harness check; this file supplies the check and the correction.
3. The right next step is now the one this campaign has *not* done and cannot fake:
   re-implement the Fourier/sieving attacks **in this harness** and re-measure their
   thresholds against this calibration, which would give the campaign a like-for-like
   frontier rather than a floor.

## 5. Reproduce

```
cd /home/raver1975/lean/factor-scratch/r118/published-thresholds
/home/raver1975/sage_mamba/envs/sage/bin/sage pub.sage
```

## 6. Traps

1. `ℓ*` is read off a grid of step `nᵇⁱᵗˢ//24` (5 bits at `n=128`, 10 at `n=256`), so
   `ℓ* = 5` and `ℓ* = 10` mean "`(5, 10]`" and "`(10, 15]`" respectively. The claim "≈10
   bits per signature" is an upper bound at that resolution.
2. The published claims use *different curves and different attacks*, so this is a
   calibration in the same currency (bits of leakage per signature), not a reproduction of
   their algorithms. That is precisely why the conclusion is "they are below our floor",
   not "they are wrong".
