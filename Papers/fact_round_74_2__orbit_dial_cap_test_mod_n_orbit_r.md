# Computational Evidence — ORBIT-DIAL-CAP-TEST (Tropical cycle)

All numbers below were produced by `#eval` inside Lean 4 (Mathlib v4.28.0) on the same
definitions used in the formal files.  They are *exploratory computations*, not proofs;
the statements they motivated are proved (0 sorries) in `Catalog/Tropical/OrbitDial*.lean`
and are listed at the end.

## 1. Berggren root component: enumerated residue sets

Root `(3,4,5)`, moves `B₁, B₂, B₃` (the three Berggren matrices), full tree to depth 8:

```
number of nodes to depth 8 : 9841   (= (3^9 - 1)/2)
all nodes Pythagorean       : true
all nodes satisfy 3 ∣ a·b   : true
```

Revealed residue sets `{(a mod m, b mod m, c mod m)}` over the whole depth-8 component:

| m  | # distinct revealed triples | comment |
|----|-----------------------------|---------|
| 3  | 4  | one leg always `≡ 0` |
| 4  | **2** | exactly `{(3,0,1), (1,0,1)}` |
| 5  | 12 | |
| 7  | 24 | |
| 8  | 4  | `{(3,4,5), (5,4,5), (7,0,1), (1,0,1)}` |
| 16 | 16 | |

The mod-4 set is the *two-point* set `{(1,0,1), (3,0,1)}` — it does not grow with depth,
and, since nothing in the enumeration depends on any target `N`, it is the same table for
every `N`.  This is the computational shadow of the experiment's design amendment
("root revealed set N-INVARIANT across all 800 N at all six moduli").

Formalised as: `Berggren.inTree_congruence` (a odd, `4 ∣ b`, `c ≡ 1 mod 4`) and
`Berggren.revealed_mod4_eq` (the revealed set is exactly that two-point table).

The mod-8 data shows the two-point structure is special to modulus 4: at `m = 8` the
second coordinate takes both values `0, 4`, consistent with `4 ∣ b` but not `8 ∣ b`.

## 2. The filter-cost law at `θ = 1/2`

With the cost model `dialCost s θ = 1 - s + s θ` (unfiltered sweep normalised to 1):

| dial | soundness `s` | retention `θ` | cost | speedup |
|------|---------------|---------------|------|---------|
| exchangeable (RAND-MATCH) | 1/2 | 1/2 | 3/4 | **4/3 = 1.3333** |
| deterministic (ORBIT / parity skip) | 1 | 1/2 | 1/2 | **2** |

The experiment measured `1.3387 CI[1.3008, 1.382]` for the matched-random arm and
`2.0000 CI[2.0,2.0]` for the orbit arm; the model reproduces both to the stated
precision, and the cap `1/(1-θ+θ²) ≤ 4/3` is attained exactly at `θ = 1/2`.

## 3. Wheel dials (structural exclusions of higher modulus)

`M/φ(M)` for the first primorials:

```
M = 2    : 2
M = 6    : 3
M = 30   : 15/4  = 3.75
M = 210  : 35/8  = 4.375
M = 2310 : 77/16 = 4.8125
```

The growth is slow (`~ e^γ log log M`) but unbounded, and every one of these dials is
computable from `N` by a single gcd, i.e. carries zero per-`N` information.  This is the
computational motivation for `Wheel.wheel_speedup_unbounded`.

## 4. Counterexample hunt

* *Is the mod-4 revealed set a singleton?*  **No** — the root itself gives `(3,0,1)` while
  its `B₁`-child `(5,12,13)` gives `(1,0,1)`.  An earlier draft of the theorem claimed a
  singleton and was corrected to the two-point set before proving.
* *Does some modulus reveal an `N`-dependent set?*  Not for the root component: the
  enumeration never involves `N`, and the revealed sets saturate immediately.  Counts by
  depth `d = 0 … 6`: modulus 4 gives `[1, 2, 2, 2, 2, 2, 2]`, modulus 3 gives
  `[1, 3, 4, 4, 4, 4, 4]`.
* *Can an exchangeable dial beat `4/3`?*  An exact rational grid search over
  `θ ∈ {1/20, …, 19/20}` of `1/(1-θ+θ²)` returns the maximiser `(1/2, 4/3)`; the proof
  (`exchangeable_never_fires`: `θ(1-θ) ≤ 1/4`) shows no `θ` can do better.

## 5. What is actually proved (0 sorries)

* `OrbitDialCap.exchangeable_cap`, `exchangeable_cap_eq_iff`, `speedup_gt_four_thirds_iff`,
  `soundness_excess_of_gt_cap`.
* `OrbitDialCap.Berggren.inTree_isPT`, `inTree_congruence`, `revealed_mod4_eq`,
  `three_dvd_leg_mul`, `parity_dial_sound`.
* `OrbitDialCap.Info.mutualInfo_of_constant`, `mutualInfo_nonneg`,
  `perfectPair_one_bit`, `orbit_dial_constant_shave`.
* `OrbitDialCap.Wheel.wheel_dial_sound`, `wheelSpeedup_prod`, `wheel_speedup_unbounded`.
* `OrbitDialCap.Trop.tropWeight_mul`, `tropWeight_unbounded`, `tropical_scope_note`.
* `OrbitDialCap.Dich.fixed_dial_uniform_prior_capped`, `supported_prior_soundness_one`,
  `parity_pool_density`.
