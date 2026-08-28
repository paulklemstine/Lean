# Computational evidence — ECM "self-destruction wall" (exp 568 audit)

Script: `ecm_wall_evidence.py` (self-contained, no external dependencies).
It implements guarded affine Weierstrass arithmetic mod `N = p·q`, a true-lcm
stage-1 schedule (`k(B1) = ∏_{r ≤ B1} r^{⌊log_r B1⌋} = lcm(1..B1)`), and classifies
every trial into the separated buckets `{found_p, found_q, dead, nothing, skipped}`
by the gcd revealed at the first non-invertible denominator.  `dead` is recorded
when the accumulating point reaches the point at infinity **mod `N`** (simultaneous
vanishing mod `p` and mod `q`) or when the revealed gcd equals `N`.

## 1. Outcome-separated grid (seed 20260827, 40 curves/cell, 600 trials)

`q = nextprime(3p + U[1,200))`, `B1 = ⌊ratio · p⌋`.

```
      p         q   B1/p      B1  found_p  found_q  dead  nothing  skipped
   1009      3163  0.125     126       22       12     0        6        0
   1009      3163   0.25     252       19       16     1        4        0
   1009      3163    0.5     504       20       20     0        0        0
   1009      3163    0.9     908       22       15     1        2        0
   1009      3163   1.05    1059       24       16     0        0        0
   4001     12071  0.125     500       15       19     0        6        0
   4001     12071   0.25    1000       19       19     0        2        0
   4001     12071    0.5    2000       19       20     0        1        0
   4001     12071    0.9    3600       26       14     0        0        0
   4001     12071   1.05    4201       23       17     0        0        0
   8191     24709  0.125    1023       20       14     0        6        0
   8191     24709   0.25    2047       24       15     0        1        0
   8191     24709    0.5    4095       25       13     0        2        0
   8191     24709    0.9    7371       20       19     1        0        0
   8191     24709   1.05    8600       21       19     0        0        0
```

Readings.

* **A nontrivial factor is found in 567/600 trials (94.5 %)**, and in **40/40**
  in all three cells at `B1/p = 1.05` — exactly where the wall is recorded.  The
  per-cell find rate rises with `B1/p` (34–35/40 at `0.125`, 38–40/40 at `≥ 0.5`):
  nothing degrades as `B1/p` crosses `1`; the alleged wall region is the best region.
* **`dead` = 3/600 (0.5 %)**, and — importantly — the three `dead` events sit at
  `B1/p = 0.25` and `0.9`, not preferentially at the top of the grid.  This is a
  refinement of the recorded exp-568 result (zero `dead`): with `q ≈ 3p` rather
  than `q ≫ p`, simultaneous degeneracy is possible but rare, exactly as the
  formal bound `dead rate ≤ B^{ω(m)}/m` (`ECMWall.dead_rate_le`) allows.
* `found_q` is large here (≈ 40 %) because `q ≈ 3p`, so `B1 ≈ p` is already a
  substantial fraction of `q`.  Outcome separation is what makes this visible;
  a conflated ledger would report it as generic "success" or, if `found_q` runs
  were misfiled, as failure.

## 2. Direct check of the mechanism sentence

For each `p`, with `B1 = p + 1 + 2⌊√p⌋ + 2` (past the top of the Hasse window):

```
p=13:   every Hasse-window order in [7,21]     divides lcm(1..22):   True
p=101:  every Hasse-window order in [81,123]   divides lcm(1..124):  True
p=1009: every Hasse-window order in [947,1073] divides lcm(1..1074): True
```

This is the sentence paper 159 reads as destruction.  Formally it is
`ECMWall.wall_forces_firing` together with `ECMWall.stage1Scalar_eq_lcmUpTo`, and
its consequence is *guaranteed* firing mod `p`, hence `found_p` whenever the mod-`q`
side does not fire simultaneously (`ECMWall.wall_yields_foundP`).

## 3. Threshold spot-checks (also theorems)

| order `n` | largest prime power ‖ `n` | least `B` with `n ∣ lcm(1..B)` |
|---|---|---|
| 12 = 2²·3 | 4 | 4  (`ECMWall.twelve_fires_iff`) |
| 13 (prime) | 13 | 13 (`ECMWall.thirteen_fires_iff`) |
| 720 = 2⁴·3²·5 | 16 | 16 (computed, not formalized) |

The success indicator of a fixed order is a single upward step in `B`; no downward
step exists at any scale (`ECMWall.firingThreshold_isLeast`,
`ECMWall.success_never_drops`).

## 4. Collision baseline

At `B1/p = 1/8` the folklore per-curve collision rate `1 − exp(−1.44·B1/p) ≤ 0.18`,
while the observed `found_p` share in the low-edge cells of exp 568 was `0.68`.
Formalized as `ECMWall.collision_baseline_below_observed`; the linear majorant
`1 − exp(−x) ≤ x` is `ECMWall.collision_baseline_le_linear`.

## 5. Caveats

* Toy scale (`p` up to 2¹³, `N` up to ~2²⁸); the grid uses 40 curves/cell, so cell
  rates carry ±0.08 binomial noise at 1 s.d.
* The script uses affine arithmetic with a single guarded inversion per step, as in
  the audited experiment; Montgomery/Edwards arithmetic would change the constant in
  the collision baseline but none of the divisibility statements.
* Only the divisibility statements are *proved*; the table above is evidence, not
  proof.  Every claim marked as a theorem in the tables is proved sorry-free in
  `Catalog/Physics/EcmStage2Wall.lean` and `Catalog/Physics/EcmWallSharpThreshold.lean`.
