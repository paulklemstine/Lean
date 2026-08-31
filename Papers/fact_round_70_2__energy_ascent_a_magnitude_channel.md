# Computational Evidence — ENERGY-ASCENT (round-70 #2)

All numbers below were produced by direct enumeration before the Lean
formalisation, and every claim they support is now a machine-checked theorem in
`Catalog/Combinatorics/EnergyAscent*.lean`.  Exact-integer arithmetic
throughout; floating point is used only for the square root inside the Fermat
offset, and every offset statement that enters a theorem is re-certified in
Lean by the integral criterion `(q−p)⁴ ≤ 64 W² p q` or by `balanced_implies_hit`.

## 1. Small cases: the Berggren tree and its ratio bands

Root `(3,4,5)`; generators (Barning–Hall)

```
B₁(a,b,c) = ( a−2b+2c,  2a−b+2c,  2a−2b+3c)
B₂(a,b,c) = ( a+2b+2c,  2a+b+2c,  2a+2b+3c)
B₃(a,b,c) = (−a+2b+2c, −2a+b+2c, −2a+2b+3c)
```

Ratio band of a leg pair: `0` if `4a < 3b`, `2` if `4b < 3a`, else `1`.

| depth | triples | band ≠ last generator |
|-------|---------|-----------------------|
| 1–12  | 797 160 | **0** |

So on the entire enumerated tree the leg-ratio band recovers the last generator
exactly (this is the empirical "ratio-band → b₁ exact 3000/3000" control, here
at 265× the sample size).  Formalised, for *all* triples, as
`EnergyAscent.branchLetter_B1/B2/B3` and `EnergyAscent.branchLetter_eq_descent`.

Word decoder check: 20 000 random generator words of length 1–14 applied to the
root, then decoded by iterating the band-selected descent — **20 000 / 20 000**
words recovered exactly, each run terminating back at `(3,4,5)`.  Formalised for
all words as `EnergyAscent.readWord_applyWord`.

Depth-1 children of the root: `(5,12,13)` band 0, `(21,20,29)` band 1,
`(15,8,17)` band 2 — one per generator, as predicted.

## 2. Hit rate of the Fermat window, by letter

`offset(p,q) = (p+q)/2 − √(pq)`; a "hit" is `offset ≤ W`.  Restricting to the
regime `q ≥ 112·W` in which the sensor is proved clean:

| `W`  | letter 0 | letter 1 | letter 2 | cells |
|------|----------|----------|----------|-------|
| 1    | 0.000    | 0.0210   | 0.000    | ≈ 265 700 per letter |
| 16   | 0.000    | 0.0578   | 0.000    | ≈ 265 600 per letter |
| 4096 | 0.000    | 0.3781   | 0.000    | ≈ 250 000 per letter |

The reported experimental table `{0.000, 0.019, 0.673}` has exactly this shape:
the outer letters are *identically* zero (now a theorem,
`EnergyAscent.hit_implies_middle_band`), the middle letter has a positive but
sub-unit rate (now a theorem in both directions:
`EnergyAscent.bridge_nonvacuous` and `EnergyAscent.noisy_not_hit`).

## 3. Counterexample hunt: is the letter a residue statistic?

For each modulus `M`, compare the root `(3,4,5)` with
`(m²−1, 2m, m²+1)`, `m = 2 + 2M`:

| `M` | residues agree mod `M` | primitive | letters |
|-----|------------------------|-----------|---------|
| 3   | yes | yes | 1 vs 2 |
| 9   | yes | yes | 1 vs 2 |
| 27  | yes | yes | 1 vs 2 |
| 81  | yes | yes | 1 vs 2 |
| 16  | yes | yes | 1 vs 2 |
| 105 | yes | yes | 1 vs 2 |

The hunt for a residue oracle fails at every modulus tested, and the failure is
uniform in `M` — formalised as `EnergyAscent.residue_seal` and
`EnergyAscent.branchLetter_not_residue_function` for **every** `M ≥ 1`
(replicating and generalising the `N mod 3^k` seal).

## 4. The two extremal families

`B₂`-spine (iterate the middle generator from the root):

| n | triple | leg gap | offset |
|---|--------|---------|--------|
| 0 | (3,4,5)            | 1 | 0.0359 |
| 1 | (21,20,29)         | 1 | 0.0061 |
| 2 | (119,120,169)      | 1 | 0.0010 |
| 3 | (697,696,985)      | 1 | 0.00018 |
| 4 | (4059,4060,5741)   | 1 | 0.000031 |
| 5 | (23661,23660,33461)| 1 | 0.000005 |

(the leg pairs are the NSW / Pell numbers; the hypotenuses `5, 29, 169, 985,
5741, 33461` are OEIS A001653, the leg pairs A001652/A046090.)  Every member is
a hit for the smallest possible window `W = 1`: `EnergyAscent.spine_invariants`,
`EnergyAscent.bridge_nonvacuous`.

`noisy k = (20k²+4k, 21k²+10k+1, 29k²+10k+1)` (middle band, growing gap):

| k | Pythagorean | gcd | band | offset |
|---|-------------|-----|------|--------|
| 2 | yes | 1 | 1 | 0.375 |
| 4 | yes | 1 | 1 | 0.590 |
| 8 | yes | 1 | 1 | 1.167 |
| 16| yes | 1 | 1 | 2.907 |
| 32| yes | 1 | 1 | 8.728 |

so the middle band contains, at every scale, triples the window cannot see:
`EnergyAscent.noisy_not_hit`.  This is the formal ceiling behind the honest
"value bounded ≈ 19%" caveat.

## 5. Sharpness search for the scale constant

Over the letter-0 family `(6k²+2k, 8k²+6k+1, 10k²+6k+1)` (ratio → 4/3 from the
outer side) we minimised the window `W` certified by `(q−p)⁴ ≤ 64W²pq` and
maximised `q/W`:

* best found: `k = 354`, `p = 752604`, `q = 1004653`, `c = 1255285`,
  `W = 9133`, `q/W = 110.0025`, `gcd(p,q) = 1`, band `0`.

Hence no threshold below `110·W` can make "hit ⇒ middle band" true, while
`112·W` provably does: the constant in `EnergyAscent.hit_implies_middle_band`
is sharp to within two units.  The witness is verified inside Lean in
`EnergyAscent.threshold_sharp` (no floating point: the integral criterion
`hit_of_quartic_criterion` is used).
