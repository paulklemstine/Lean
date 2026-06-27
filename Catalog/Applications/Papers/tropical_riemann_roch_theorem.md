# Computational Evidence — Tropical (Baker–Norine) Riemann–Roch

All claims below are *verified in Lean* in this directory; the tables are the
small-case calculations that guided the formalization.

## 1. Setup recap

For a finite loopless graph `G` with symmetric edge-multiplicity `adj`:

* `deg D = Σ_v D v`
* `prin f w = Σ_v adj(v,w)·(f w − f v)`   (firing / graph Laplacian image)
* `D ~ D'  ⇔  D' = D + prin f` for some integer firing vector `f`
* `K(v) = deg(v) − 2`  (canonical divisor),   `g = |E| − |V| + 1`  (genus)
* `rank D = −1` if `D` is not equivalent to an effective divisor, else the
  largest `n` with: every effective `E` of degree `n` keeps `D − E` effective-equivalent.

## 2. The path graph `P₂` (two vertices, one edge) — genus 0

`adj(0,1) = 1`. Vertex degrees `(1,1)`, so `K = (−1,−1)`, `deg K = −2`,
`totalEdges = 2`, `g = 2/2 − 2 + 1 = 0`.

Because the only spanning tree is the graph itself, **the principal lattice equals
the whole degree-0 lattice**, so two divisors are equivalent iff they have equal
degree. Hence `rank D = deg D` for `deg D ≥ 0`, else `−1`.

Riemann–Roch `r(D) − r(K−D) = deg D − g + 1 = deg D + 1`:

| `D`      | `deg D` | `r(D)` | `K−D`     | `deg(K−D)` | `r(K−D)` | LHS | `deg D + 1` |
|----------|---------|--------|-----------|------------|----------|-----|-------------|
| `(0,0)`  | 0       | 0      | `(−1,−1)` | −2         | −1       | 1   | 1           |
| `(1,0)`  | 1       | 1      | `(−2,−1)` | −3         | −1       | 2   | 2           |
| `(2,3)`  | 5       | 5      | `(−3,−4)` | −7         | −1       | 6   | 6           |
| `(−1,0)` | −1      | −1     | `(0,−1)`  | −1         | −1       | 0   | 0           |
| `(−2,−1)`| −3      | −1     | `(1,0)`   | 1          | 1        | −2  | −2          |

Every row satisfies the identity. Formalized as `riemann_roch_pathTwo`.

## 3. The 2-cycle `C₂` (two vertices, double edge) — genus 1

`adj(0,1) = 2`. Vertex degrees `(2,2)`, `totalEdges = 4`, `g = 4/2 − 2 + 1 = 1`.

Principal divisors are exactly `(2t, −2t)`. The degree-0 lattice is `(a,−a)`, so the
**Jacobian (degree-0 Picard group) is `ℤ/2ℤ`**, index = number of spanning trees = 2.

Counterexample hunt for `hsurj` (equal degree ⇒ equivalent): the divisors `(1,0)`
and `(0,1)` both have degree `1` but their difference `(1,−1)` requires `2t = 1`,
impossible. So `hsurj` *fails*. Formalized as `cycleTwo_hsurj_fails`.

This is exactly why `genus G = 0` is a load-bearing hypothesis in
`riemann_roch_genus_zero`: under `hsurj` with both ranks positive one computes
`r(D) − r(K−D) = 2·deg D − (2g−2)`, which equals `deg D − g + 1` **iff `g = 0`**.

## 4. OEIS note

The number of spanning trees of the multigraph `C_n^{(2 edges)}` is not the focus;
the relevant invariant here is the *index of the principal lattice in the degree-0
lattice*, which equals the number of spanning trees (Kirchhoff). For `P₂` it is `1`
(A000012, all ones) and for `C₂` it is `2`. No single OEIS sequence is claimed.

## 5. Why this is enough evidence

The general identity reduces (after the rank formula) to a finite case split on the
signs of `deg D` and `deg(K−D)`, discharged by `omega`. The two graphs above
exercise the genus-0 success case and the genus-1 obstruction, which are the two
qualitatively distinct regimes.
