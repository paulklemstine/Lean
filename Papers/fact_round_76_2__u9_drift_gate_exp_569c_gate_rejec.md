# Computational evidence — U9-DRIFT-GATE round (paper 222, Pythagorean domain)

All numbers below were produced with `#eval` inside this Lean project, against the same
`hypSolutions` definition that the theorems use
(`Catalog/Pythagorean/DriftGateHypotenuseMultiplicity.lean`).  `#eval` output is
exploratory, not kernel-checked; every claim that the round *relies on* is proved as a
theorem, and the one small table entry that is used inside a proof
(`hypSolutions 5 = {(3,4),(4,3)}`) is discharged by `decide`.

## 1. Hypotenuse cluster sizes (ordered positive leg pairs with `a² + b² = c²`)

`(c, #hypSolutions c)` for the nonzero clusters with `c < 130`:

```
(5,2) (10,2) (13,2) (15,2) (17,2) (20,2) (25,4) (26,2) (29,2) (30,2) (34,2) (35,2)
(37,2) (39,2) (40,2) (41,2) (45,2) (50,4) (51,2) (52,2) (53,2) (55,2) (58,2) (60,2)
(61,2) (65,8) (68,2) (70,2) (73,2) (74,2) (75,4) (78,2) (80,2) (82,2) (85,8) (87,2)
(89,2) (90,2) (91,2) (95,2) (97,2) (100,4) (101,2) (102,2) (104,2) (105,2) (106,2)
(109,2) (110,2) (111,2) (113,2) ...
```

* Record holder for `c ≤ 200`: `c = 65` with `8` ordered hits (four right triangles).
* Total hits over `c ≤ 200`: `254`, i.e. a mean cluster size of `≈ 1.26` against a
  maximum of `8`.  **The empirical max/mean ratio is already `> 6` at this tiny scale**,
  which is the overdispersion signature the round measured at `u ≈ 11`.
* Halving our ordered counts gives `0,0,0,0,1,0,…,1,…,2 (at 25),…,4 (at 65)`, the usual
  "number of right triangles with hypotenuse `n`" sequence (OEIS A046080).  We did not
  re-verify the OEIS entry itself here; it is quoted only as an orientation.

## 2. The explicit construction behind `exists_hypotenuse_multiplicity`

`C_k = ∏_{v < k} ((v+2)² + 1)`:

| `k` | `C_k` | proved lower bound | measured `#hypSolutions C_k` |
|---|---|---|---|
| 1 | 5 | ≥ 1 | 2 |
| 2 | 50 | ≥ 2 | 4 |
| 3 | 850 | ≥ 3 | 14 |
| 4 | 22100 | ≥ 4 | (not evaluated — search space `4.9·10⁸` pairs) |
| 5 | 817700 | ≥ 5 | (not evaluated) |

The construction is therefore **correct but loose**: the true multiplicity of `C_k` grows
much faster than the `k` the proof extracts (it is governed by the number of prime
divisors `≡ 1 mod 4` of `C_k`).  The theorem only needs unboundedness, so the loose bound
is fine; sharpening it is Future Direction 1.

## 3. Counterexample hunt against the resolution floor

The floor claim `share − 1/m ≤ relClusterSD` was tested numerically before formalising,
on the recorded arbiter profile (`m = 128`, top cluster `600`, total `40617`):

```
600/40617 − 1/128           = 0.006960     (proved floor)
stored cut_1e6 half-width   = 0.048250     ((1.1016 − 1.0051)/2)
√(0.025² / 3)               = 0.014434     (3-seed pooled SE)
```

* The stored interval is `≈ 7×` wider than the cluster floor, so **audit item 3 is
  consistent**: the reported CI is not narrower than the cluster structure allows.  (Had
  the half-width come out *below* the floor, the interval would have been provably
  mis-stated.)
* The three-seed pooled standard error `0.0144 < 0.02` confirms the round's named
  follow-up condition is reachable; this is `three_seed_pooling_reaches_target`.
* No counterexample to the floor inequality was found in randomised search over small
  cluster vectors before formalisation, and the general statement is now proved.

## 4. Sign-flip arithmetic

```
pilot / G1 / B (seed 20260824, cut_1e6):  0.9468, 0.988, 0.9623   (all < 1)
arbiter (seed 20260825):  40617/38594 = 1.05242…,  2598/2252 = 1.15364…   (both > 1)
```

Both directions are strict, so the disagreement is directional, not one of magnitude:
this is `arbiter_sign_flip`, and `recorded_no_joint_coverage` turns it into a proof that
the two nominal 95% coverage claims cannot both hold of one estimand.
