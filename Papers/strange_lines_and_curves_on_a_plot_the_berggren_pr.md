# Computational evidence: stars and curves in the hyperbolic plot of the Berggren tree

Every number below was computed inside Lean with `#eval`
(`Catalog/MachineLearning/BerggrenAudit.lean`), and every pattern it suggests is *proved*
in the accompanying `.lean` files. Nothing here is claimed on the strength of the
evaluation alone; the `#eval` outputs are reproduced verbatim.

## 1. The three generator branches

Berggren / Barning–Hall generators acting on `(a,b,c)`:

| generator | action | first five iterates from `(3,4,5)` |
|---|---|---|
| `mA` | `(a−2b+2c, 2a−b+2c, 2a−2b+3c)` | `(3,4,5), (5,12,13), (7,24,25), (9,40,41), (11,60,61)` |
| `mB` | `(a+2b+2c, 2a+b+2c, 2a+2b+3c)` | `(3,4,5), (21,20,29), (119,120,169), (697,696,985), (4059,4060,5741)` |
| `mC` | `(−a+2b+2c, −2a+b+2c, −2a+2b+3c)` | `(3,4,5), (15,8,17), (35,12,37), (63,16,65), (99,20,101)` |

Observations, all subsequently proved:

* **`mA` branch**: `c − b = 1` for every iterate, and `c = 5, 13, 25, 41, 61` has constant
  second difference `4`: a *quadratic* polynomial in the step number, the fingerprint of a
  rank-3 unipotent (parabolic) Jordan block. Proved: `mA_iterate`, `mA_branch`.
* **`mC` branch**: `c − a = 2` throughout, `c = 5, 17, 37, 65, 101` (constant second
  difference `8`), again quadratic.
  Proved: `mC_iterate`, `mC_branch`.
* **`mB` branch**: `#eval` of `a − b` gives `[-1, 1, -1, 1, -1]`; the sign alternates and
  `|a−b| = 1` is conserved. Hypotenuses `5, 29, 169, 985, 5741` (OEIS **A001653**,
  "numbers `n` with `2n²−1` a square", the Pell/NSW hypotenuses) satisfy
  `c_{k+2} = 6c_{k+1} − c_k`, ratio `→ 3 + 2√2 = 5.8284…`. Exponential, hyperbolic
  behaviour, with `a/c → √2/2`. Proved: `mB_iterate_charge`, `mB_hyp_recurrence`,
  `mB_ray_bound`, `mB_ray_tendsto`.

Numerically `a_k/c_k` along the `mB` branch: `0.6, 0.7241, 0.70414, 0.707614, 0.707020, …`
against `√2/2 = 0.7071068…`; the error behaves like `1/c_k`, i.e. geometric with ratio
`≈ 1/5.83`, matching the proved bound `|a_k/c_k − √2/2| ≤ |a−b| / (3^k c)`.

## 2. Charges (the spoke labels) at the ideal point `(1,0)`

`#eval` of `c − a` for `spoke n (n+1) = ((n+1)²−n², 2(n+1)n, (n+1)²+n²)`, `n = 0..5`:

```
[0, 2, 8, 18, 32, 50]        (= 2n²)
```

Exhaustive scan of *all* primitive triples with hypotenuse `≤ 200`
(`chargesUpTo`, `chargesEvenUpTo`):

```
odd  first leg :  [2, 8, 18, 32, 50, 72, 98, 128, 162]      (= 2n²)
even first leg :  [1, 9, 25, 49, 81, 121, 169]              (= odd squares)
```

and no charge in `[3, 4, 5, 6, 7, 10, 11, 12]` occurs for any primitive triple with odd
first leg and hypotenuse `≤ 1000` (the filtered list is empty). Exactly this dichotomy is
proved: `charge_quantization_odd_leg`, `charge_quantization_even_leg`,
`charge_spectrum`, `charge_spectrum_odd_leg`. Since the Berggren tree consists of triples
with odd first leg, the spokes of the star it draws at `(1,0)` are labelled precisely
`2, 8, 18, 32, 50, …` — a set of density zero, which is why the star looks sparse.

## 3. Counterexample hunt

* *Can a plotted triple sit exactly at the `π/4` ideal point?* No: `a/c` is rational and
  `√2/2` is not (`no_triple_direction_at_pi_div_four`); the numerics above approach it but
  never reach it.
* *Can the charge be an arbitrary positive integer?* No, see the scan above; the
  quantization theorem explains it.
* *Is the parabolic approach ever exponentially fast?* No: `1 − a_k/c_k = 2/c_k` with
  `c_k = 5 + 8k + 4k²` on the `mC` branch from the root, so it decays like `Θ(k^{-2})`
  (`mC_ray_poly_lower`), in sharp contrast with the `mB` branch.

## 4. What the plot shows, and why

* curves running into `(1,0)` and `(0,1)`, one per charge — the **stars**, with order-2
  (horocyclic) contact with the circle: `c·(b/c)² → 4n²` (`spoke_tangency`);
* one fast line into the irrational ideal point at angle `π/4` — the **geodesic** of the
  hyperbolic generator, reaching the circle exponentially fast (`mB_ray_bound`);
* by transport under the tree monoid a copy of the star at the ideal point of *every* node
  (`star_at_every_tree_node`), hence — by Barning–Hall completeness, proved here as
  `tree_complete` — at every primitive rational ideal point
  (`star_at_every_primitive_ideal_point`); and those are dense in the arc
  (`star_centres_dense`).

## 5. Second cycle: the spoke index and the branch-growth sandwich

All figures below are verbatim `#eval` output from
`Catalog/MachineLearning/BerggrenAudit.lean`.

**Euclid parameters along the three pure branches** (node, and its charge `−⟨v,(1,0,1)⟩`
at the ideal point `(1,0)`):

```
mA :  [((3,4,5),2), ((5,12,13),8), ((7,24,25),18), ((9,40,41),32), ((11,60,61),50), ((13,84,85),72)]
mC :  [((3,4,5),2), ((15,8,17),2), ((35,12,37),2), ((63,16,65),2), ((99,20,101),2), ((143,24,145),2)]
mB :  [((3,4,5),2), ((21,20,29),8), ((119,120,169),50), ((697,696,985),288),
       ((4059,4060,5741),1682), ((23661,23660,33461),9800)]
```

The charges are `2n²` with `n = 1,2,3,4,5,6` on the `mA` branch (index grows by one per
level), `n = 1` throughout on the `mC` branch (the index is frozen — a single spoke), and
`n = 1,2,5,12,29,70` on the `mB` branch: the **Pell numbers**, OEIS A000129
(`1, 2, 5, 12, 29, 70, 169, …`), satisfying `P_{k+1} = 2P_k + P_{k−1}`.  Both facts are
proved: `mA_iterate_root_eu`, `mC_iterate_eu`, `mB_iterate_root_eu`.

**The depth sandwich `2^k ≤ n < 2·3^k` on the hyperbolic branch** (`#eval` of
`(2^k, pell k, 2·3^k)`):

```
[(1,1,2), (2,2,6), (4,5,18), (8,12,54), (16,29,162), (32,70,486), (64,169,1458)]
```

Every middle entry is inside its interval, as `spoke_index_log_sandwich` asserts.  The
lower bound `n < 2·3^k` holds for *every* address, not just this branch
(`spoke_index_depth_lower_bound`), so the `n`-th spoke of the star is invisible above
depth `log₃(n/2)`.

**The branch-growth sandwich `5·3^{#B} ≤ c ≤ 5·7^{len}`** for four mixed addresses
`[A,B,C]`, `[B,B,C]`, `[C,C,C]`, `[B,A,B,C]` (`#eval` of `(lower, c, upper)`):

```
[(15,277,1715), (45,565,1715), (5,65,1715), (45,1565,12005)]
```

Again every observed hypotenuse lies inside the proved window
(`branch_growth_sandwich`).  The `B`-free address `[C,C,C]` sits at the bottom of the
window (`65` against a lower bound of `5`), consistent with the polynomial regime; the
`B`-heavy addresses are pushed up by the `3^{#B}` factor.

## Cycle 3: multiplicity of a single star

**The spokes of the star at `(1,0)` drawn by the tree.**  Row `n` lists the first four
nodes of the family `mC^j (mA^n root)` together with their charge `−⟨v,(1,0,1)⟩`
(`#eval` in `Catalog/MachineLearning/BerggrenAudit.lean`):

```
[[((3, 4, 5), 2),   ((15, 8, 17), 2),   ((35, 12, 37), 2),   ((63, 16, 65), 2)],
 [((5, 12, 13), 8), ((45, 28, 53), 8),  ((117, 44, 125), 8), ((221, 60, 229), 8)],
 [((7, 24, 25), 18),((91, 60, 109), 18),((247, 96, 265), 18),((475, 132, 493), 18)],
 [((9, 40, 41), 32),((153, 104, 185), 32),((425, 168, 457), 32),((825, 232, 857), 32)]]
```

The charge is constant `2(n+1)² = 2, 8, 18, 32, …` along each row (that is exactly the
horocycle condition, `treeSpoke_charge`) and the hypotenuse grows along the row
(`treeSpoke_hyp_ge`), so each row is one visible curve running into the boundary point
`(1,0)`.  Different rows have different charges, so all of these curves are distinct:
this is the computational shadow of `star_multiplicity_at_e1`, and the charge list

```
[2, 8, 18, 32, 50]
```

is the beginning of `2n²` (OEIS A001105), which `tree_spoke_charge_spectrum` proves is
*exactly* the set of spoke charges of the tree at `(1,0)` — nothing else occurs.  No
counterexample was found in the exhaustive scans of the previous cycle: the scan of all
primitive triples with odd first leg and hypotenuse `c ≤ 1000` returned only charges in
`2n²`, and the candidate values `[3,4,5,6,7,10,11,12]` were provably absent.
