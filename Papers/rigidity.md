# Computational Evidence — Orbital Rigidity at `k = 2`

All numbers below were produced by a Lean 4 `#eval` script run against this project's
toolchain (Lean 4.28.0 + mathlib).  For an explicit finite permutation group `G ≤ Sym(X)`
given as a list of images, the script computes the fixed-point vector `F = (|Fix g|)_{g∈G}`
and then uses Burnside's lemma in the form

```
r = (1/|G|) Σ_g F g        (number of orbits on X)
s = (1/|G|) Σ_g (F g)²     (number of orbitals, i.e. orbits on X × X)
```

which is exactly the identity formalised as `burnside_natCard` / `burnside_prod` in
`Catalog/Novelty/OrbitalRigidity.lean`.

## 1. Small-case table

`n = |X|`, `K = {g : g acts trivially}` (the kernel).

| action                      | `n` | `\|G\|` | `F`                 | `r` | `s` | `s − r²` | `\|K\|(n−r)²` | `(\|G\|−\|K\|)(s−r²)` | `\|G\|(s−r²)` |
|-----------------------------|----|-----|---------------------|----|----|---------|------------|-------------------|-------------|
| trivial on 3 points         | 3  | 1   | `[3]`               | 3  | 9  | 0       | 0          | 0                 | 0           |
| `ℤ/2` swap on 2             | 2  | 2   | `[2,0]`             | 1  | 2  | 1       | 1          | **1**             | 2           |
| `ℤ/2` swap `(0 1)` on 3     | 3  | 2   | `[3,1]`             | 2  | 5  | 1       | 1          | **1**             | 2           |
| `ℤ/3` rotation on 3         | 3  | 3   | `[3,0,0]`           | 1  | 3  | 2       | 4          | **4**             | 6           |
| `S₃` on 3                   | 3  | 6   | `[3,1,1,1,0,0]`     | 1  | 2  | 1       | 4          | 5                 | 6           |
| `ℤ/2` `(0 1)(2 3)` on 4     | 4  | 2   | `[4,0]`             | 2  | 8  | 4       | 4          | **4**             | 8           |
| Klein four regular on 4     | 4  | 4   | `[4,0,0,0]`         | 1  | 4  | 3       | 9          | **9**             | 12          |
| `ℤ/4` regular on 4          | 4  | 4   | `[4,0,0,0]`         | 1  | 4  | 3       | 9          | **9**             | 12          |
| `D₄` on the square          | 4  | 8   | `[4,0,0,0,0,0,2,2]` | 1  | 3  | 2       | 9          | 14                | 16          |
| `ℤ/5` regular on 5          | 5  | 5   | `[5,0,0,0,0]`       | 1  | 5  | 4       | 16         | **16**            | 20          |
| `ℤ/2` on 5 (`(0 1)`)        | 5  | 2   | `[5,3]`             | 4  | 17 | 1       | 1          | **1**             | 2           |
| `ℤ/3` on 5 (`(0 1 2)`)      | 5  | 3   | `[5,2,2]`           | 3  | 11 | 2       | 4          | **4**             | 6           |
| Klein four on 6 points      | 6  | 4   | `[6,2,2,2]`         | 3  | 12 | 3       | 9          | **9**             | 12          |

Bold = the sharp bound `|K|(n−r)² ≤ (|G|−|K|)(s−r²)` holds with **equality**.

## 2. Counterexample hunt

The universal claim tested is: *`s = r²` implies the action is trivial.*

* Every nontrivial row above has `s − r² ≥ 1`; no counterexample was found.
* The most "efficient" families were probed deliberately, since they are the ones with the
  smallest number of orbitals relative to the number of orbits: sharply transitive (regular)
  actions and 2-transitive actions (`S₃` on 3 points has `s = 2 = r² + 1`, the minimum
  possible defect).  Even a 2-transitive action — where the orbital partition is as coarse as
  it can be, namely `{diagonal, complement}` — still has two orbitals versus one orbit.  This
  is the informal reason the theorem cannot fail: the diagonal of `O × O` is always a
  *proper, nonempty, invariant* subset when `|O| ≥ 2`.
* No sequence search / OEIS lookup is relevant here: the quantities `(n, r, s)` are not a
  single integer sequence but a three-parameter family attached to a permutation group.  The
  column `s` restricted to a transitive action is the classical *rank* of the group, and the
  table's transitive rows (`rank = 2` for `S₃`, `rank = |G|` for regular actions) agree with
  the standard values of the rank of a permutation group.

## 3. What the data steered

1. The naive bound `|K|(n−r)² ≤ |G|(s−r²)` (proved as `rigidity_quantitative`) is *never*
   attained for a nontrivial action — visible in the last column of the table.  This pushed
   the second research cycle towards the Cauchy–Schwarz correction on the non-kernel part of
   `G`, which produced the sharp bound `|K|(n−r)² ≤ (|G|−|K|)(s−r²)`
   (`rigidity_quantitative_sharp`).
2. The equality rows are exactly those whose non-identity elements have a *constant* number of
   fixed points.  That observation became the theorem
   `rigidity_equality_of_constant_fixity`, which is proved in full generality (it covers
   regular actions, sharply transitive actions and Frobenius groups).
3. `D₄` (`F = [4,0,0,0,0,0,2,2]`, non-constant fixity, strict inequality `9 < 14`) is the
   witness that the constant-fixity hypothesis in that theorem cannot simply be dropped.  In
   the third research cycle the converse was proved as well
   (`rigidity_equality_iff_constant_fixity`): for a nontrivial action, equality holds *iff*
   the fixity is constant off the kernel.
4. A natural guess — that constant fixity means all non-kernel elements share a *common* fixed
   set — is **false**.  The Klein four group generated by `(0 1)(2 3)` and `(2 3)(4 5)` acting
   on six points has `F = [6,2,2,2]` with the three involutions fixing `{4,5}`, `{0,1}` and
   `{2,3}` respectively: constant fixity, three distinct fixed sets, and (as the last table row
   records) equality `9 = 9` in the sharp bound.  This example was found by a targeted search
   during the counterexample hunt and is what steered Conjecture 5 of `FUTURE_DIRECTIONS.md`
   towards a character-theoretic rather than a set-theoretic formulation.

## 4. Reproducing the numbers

```lean
import Mathlib
def fixc (p : List ℕ) : ℕ := ((p.zipIdx).filter (fun q => q.1 = q.2)).length
def stats (n : ℕ) (gs : List (List ℕ)) : ℕ × ℕ × ℕ × ℕ :=
  let N := gs.length
  let F := gs.map fixc
  let r := (F.foldl (· + ·) 0) / N
  let s := ((F.map (fun a => a * a)).foldl (· + ·) 0) / N
  let K := (gs.filter (fun p => fixc p = n)).length
  (r, s, K, N)
#eval stats 3 [[0,1,2],[1,0,2],[0,2,1],[2,1,0],[1,2,0],[2,0,1]]  -- S₃ on 3: (1, 2, 1, 6)
```

Caveat: these `#eval` computations are exploratory evidence, not machine-checked theorems.
Everything asserted as a theorem lives in `Catalog/Novelty/OrbitalRigidity.lean` and is proved
there for *arbitrary* finite groups and finite `G`-sets, with no appeal to these computations.
