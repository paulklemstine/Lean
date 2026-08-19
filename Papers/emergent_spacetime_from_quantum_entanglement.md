# Computational evidence for the ER=EPR throat/metric theorems

All numbers below were produced by running rational-arithmetic replicas of the
formal definitions (`cutWeight`, min-cut `entropy`, `throat`) inside Lean 4 with
`#eval`, on small finite geometries.  They are *exploratory* data used to select
the conjectures; the theorems themselves are proved in the `.lean` files and do
not depend on these computations.

Replica definitions used (over `ℚ`, cells `Fin n`):

```lean
cutQ W f  = (∑ u, ∑ v, (if f u = f v then 0 else 1) * W u v) / 2
capQ W u v = min { cutQ W f : f u = true, f v = false }         -- throat capacity
entQ W b A = min { cutQ W f : ∀ v, b v → f v = A v }            -- min-cut entropy
IQ  W u v  = S({u}) + S({v}) − S({u,v})                         -- mutual information
```

## 1. A four-cell geometry with all cells on the boundary

Weights (symmetric, zero diagonal):

| | 0 | 1 | 2 | 3 |
|---|---|---|---|---|
|0| 0 | 5 | 0 | 1 |
|1| 5 | 0 | 1 | 0 |
|2| 0 | 1 | 0 | 3 |
|3| 1 | 0 | 3 | 0 |

Computed capacities `capQ` (diagonal is the sentinel `1000`, i.e. "no separating
surface exists"; the formal convention is `cap u u = 0`):

```
[[1000,    6,    2,    2],
 [   6, 1000,    2,    2],
 [   2,    2, 1000,    4],
 [   2,    2,    4, 1000]]
```

Mutual informations `IQ`:

```
[[6, 10,  0,  2],
 [10, 6,  2,  0],
 [ 0, 2,  4,  6],
 [ 2, 0,  6,  4]]
```

Checks (all `true`):

* ultrametric/Gomory–Hu inequality `min(cap u v, cap v w) ≤ cap u w` for `u ≠ w`
  over all `4³` triples — **true**;
* `I(u:v) ≤ 2 · cap(u,v)` over all pairs — **true**
  (e.g. `I(0:1) = 10 ≤ 12 = 2·6`; the bound is *not* tight in general).

Note the isosceles pattern predicted by `cap_isosceles`: the three capacities of
`{0,1,2}` are `6, 2, 2` — the two smallest coincide.

## 2. A five-cell geometry with hidden bulk cells

Cells `0,1,2` are boundary; `3,4` are hidden bulk.  Weights: `w(0,3)=2`,
`w(1,3)=3`, `w(2,4)=5`, `w(3,4)=4`, all others `0`.

* min-cut entropies of the single boundary cells: `S(0)=2, S(1)=3, S(2)=4`;
* mutual informations `I(u:v)` for `u,v ∈ {0,1,2}`:

```
[[2, 1, 3],
 [1, 3, 5],
 [3, 5, 4]]      (diagonal entries are 2S(u) − S(u,u) bookkeeping, off-diagonal is I)
```

* capacities `cap(0,1)=2`, `cap(0,2)=2`, `cap(1,2)=3`;
* `I(A:B) ≤ 2·cap(A,B)` for all boundary pairs — **true**
  (`I(1:2) = 5 ≤ 6`);
* `cap(u,v) ≤ min(S(u), S(v))` for all boundary pairs — **true**, and *tight* at
  `cap(1,2) = 3 = min(3,4)`.

This pair of experiments is what suggested the two-sided sandwich
`I/2 ≤ throat ≤ min(S,S)` (`throat_sandwich`) and the Gomory–Hu inequality
(`cap_min_le`) that makes the emergent distance an ultrametric.

## 3. Counterexample hunt

* Replacing `exp(-cap)` by `1/(1+cap)` still gives a metric but the *proof* of
  the max-inequality no longer produces the sharp comparison with `I`, so `exp`
  was kept; no numerical counterexample to ultrametricity of either choice was
  found (both are order-reversing reparametrisations, so both are ultrametrics).
* The inequality `min(cap u v, cap v w) ≤ cap u w` **fails** if `u = w` is
  allowed (then the left side can be positive while `cap u u = 0`); this is why
  `cap_min_le` carries the hypothesis `u ≠ w` and why the diagonal of
  `bridgeDist` is defined separately.
* No sequence-like invariant appeared, so no OEIS search was applicable.

## 4. Second cycle: coarse-graining experiments

Hand-computed min cuts on the four-cell path `0 — 1 — 2 — 3` with areas
`w(0,1) = w(2,3) = 5`, `w(1,2) = 1` (the "thin waist"):

| geometry | separating surfaces of `0` from the far end | areas | min cut |
|---|---|---|---|
| fine (`Fin 4`) | `{0}`, `{0,1}`, `{0,2}`, `{0,1,2}` | `5, 1, 10, 5` | `1` |
| coarse (merge `1,2`) | `{0}`, `{0,a}` | `5, 5` | `5` |

So merging the two waist cells raises the throat from `1` to `5`, i.e. the
emergent distance drops from `exp(-1) ≈ 0.368` to `exp(-5) ≈ 0.0067`.  Both
numbers are now theorems (`rgExample_cap_le_one`,
`rgExample_pushGraph_cap_eq_five`), the second by exhausting the two coarse
surfaces.

Counterexample hunt for the reverse inequality: no merging was found that
*lowers* a capacity — consistent with `cap_le_cap_pushGraph`, which proves this
is impossible, since every coarse surface pulls back to a fine surface of equal
area.  Merging two cells that are *not* separated by the minimal surface leaves
the throat unchanged (e.g. merging `0,1` above keeps the min cut at `1`), which
is why the strict example merges exactly the two waist cells.
