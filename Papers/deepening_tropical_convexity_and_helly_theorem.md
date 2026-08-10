# Computational Evidence — Tropical Helly / Cramer dependence

All numbers below were produced by an exploratory Lean `#eval` script (exact
rational arithmetic, `ℚ`) run against the same construction that is formally
verified in `Catalog/Tropical/TropicalConvexity/HellyNumber.lean`.  The `#eval`
runs are *exploratory*: they are what motivated the formal statements, and the
statements themselves are proved (no `sorry`, no `native_decide`) in the Lean
files.

## 1. The script

```lean
/-- max-plus determinant of a square matrix given as a list of rows -/
def tropdet (M : List (List ℚ)) : ℚ :=
  let n := M.length
  let perms := (List.range n).permutations
  let vals := perms.map (fun p => ((M.zip p).map (fun rp => rp.1.getD rp.2 0)).sum)
  vals.foldr max (vals.headD 0)

/-- Cramer weights: delete row k, take the tropical determinant of the minor -/
def cramer (A : List (List ℚ)) : List ℚ :=
  (List.range A.length).map (fun k => tropdet (A.eraseIdx k))

/-- for each column: (value of the max, number of rows attaining it) -/
def colStats (A : List (List ℚ)) : List (ℚ × Nat) :=
  let lam := cramer A
  let d := (A.headD []).length
  (List.range d).map (fun i =>
    let vals := (A.zip lam).map (fun rl => (rl.1.getD i 0) + rl.2)
    let m := vals.foldr max (vals.headD 0)
    (m, (vals.filter (fun v => v == m)).length))
```

## 2. Small-case calculations: `d + 1` points in `ℝ^d`

| rows `A` (points) | `d` | Cramer weights `lam` | per-column `(max, #maximisers)` |
|---|---|---|---|
| `[0,0], [1,3], [4,1]` | 2 | `[7, 4, 3]` | `[(7,2), (7,2)]` |
| `[2,5], [2,5], [0,0]` | 2 | — | `[(7,3), (10,2)]` |
| `[0,0,0], [3,1,4], [1,5,9], [2,6,5]` | 3 | `[18, 15, 10, 12]` | `[(18,2), (18,2), (19,2)]` |
| `[-1,2,0], [3,-2,1], [0,0,-5], [4,4,4]` | 3 | — | `[(9,2), (9,2), (7,3)]` |
| `[0,1,2,3], [3,2,1,0], [1,0,0,1], [-2,4,-1,2], [5,5,0,0]` | 4 | — | `[(15,2), (15,2), (13,3), (14,2)]` |

**Observation.** In every instance each column maximum is attained at least
twice — exactly the tropical dependence statement
`TropicalDependence.trop_dependence_fin`, now proved in general.

## 3. Counterexample hunt: is `d + 1` needed?

Running the same construction on only `d` points in `ℝ^d`:

| rows `A` | `d` | per-column `(max, #maximisers)` |
|---|---|---|
| `[0,0], [1,3]` | 2 | `[(1,2), (3,1)]` |
| `[0,0,0], [3,1,4], [1,5,9]` | 3 | `[(8,2), (8,2), (12,1)]` |

A column with a **unique** maximiser appears.  So `d` points are in general
tropically *independent*: the hypothesis "`d + 1` points" in the dependence
theorem — and hence the Helly number `d` — cannot be lowered by this route.
This is confirmed by the formal sharpness theorems
`tropical_helly_number_sharp` and `caratheodory_cone_sharp`.

## 4. Sharpness family, explicit witness

For `d = 3` the extremal cones are `C_k = {x : ∃ j ≠ k, x_k + 1 ≤ x_j}`.

* `x = (0,-1,-1)` lies in `C_1 ∩ C_2` (its coordinates 1 and 2 are beaten by
  coordinate 0), and by symmetry every pair of the three cones meets;
* no `x` lies in all three: the largest coordinate `x_k` would have to satisfy
  `x_k + 1 ≤ x_j ≤ x_k`.

Formally: `TropicalHellyNumber.hellyTightSet_small_inter` and
`TropicalHellyNumber.hellyTightSet_iInter_empty`.

## 5. Sequences / OEIS

The only integer sequences appearing here are the Helly number `d`, the
Carathéodory number `d` and the tropically convex (affine chart) Helly number
`d + 1`; these are linear and carry no OEIS content.
