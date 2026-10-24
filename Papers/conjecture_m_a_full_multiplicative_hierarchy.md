# Computational evidence for Conjecture M (multiplicative hierarchy of the spectrum `t_r`)

`t_r` = number of `G`-orbits of injective `r`-tuples (catalog: `FibreSpectrum.injOrbits G X r`).

**Status of this file.** Everything in Sections 1–3 came from an exploratory Python script (shown in
Section 4). It is supporting evidence only and has **not** been checked in Lean. The one exception is
the counterexample to the coarse conjecture (trivial group on 3 points, `r = 1`, `s = 2`). That case
is checked in Lean by `coarse_conjecture_false` / `injOrbits_coarse_conjecture_false`, which use
the theorem `tInj_of_trivial : t_r = |X|^{(r)}`.

The script uses Burnside's formula on injective tuples: an injective tuple is fixed by `g` exactly
when all of its entries are fixed points of `g`. So
`t_r = (1/|G|) Σ_g fix(g)^{(r)}`, where `m^{(r)}` is the falling factorial.

## 1. Small-case spectra `t_0, t_1, …, t_n`

| action | \|G\| | spectrum |
|---|---|---|
| trivial on 3 | 1 | [1, 3, 6, 6] |
| C_3 | 3 | [1, 1, 2, 2] |
| S_3 | 6 | [1, 1, 1, 1] |
| trivial on 4 | 1 | [1, 4, 12, 24, 24] |
| C_4 | 4 | [1, 1, 3, 6, 6] |
| D_4 | 8 | [1, 1, 2, 3, 3] |
| S_4 | 24 | [1, 1, 1, 1, 1] |
| C_5 | 5 | [1, 1, 4, 12, 24, 24] |
| D_5 | 10 | [1, 1, 2, 6, 12, 12] |
| C_6 | 6 | [1, 1, 5, 20, 60, 120, 120] |
| D_6 | 12 | [1, 1, 3, 10, 30, 60, 60] |
| C_7 | 7 | [1, 1, 6, 30, 120, 360, 720, 720] |
| D_7 | 14 | [1, 1, 3, 15, 60, 180, 360, 360] |
| C_2 on {0,1}, fixing 2,3,4 | 2 | [1, 4, 13, 33, 60, 60] |
| C_3 on 3 points + 3 fixed points | 3 | [1, 4, 14, 44, 120, 240, 240] |
| C_2 × C_2 on 2+2 | 4 | [1, 2, 4, 6, 6] |
| C_2 × C_3 on 2+3 | 6 | [1, 2, 5, 11, 20, 20] |

(The script covered trivial, cyclic, dihedral and symmetric groups for `n = 3..7`, plus four
intransitive actions: 24 actions in all.)

OEIS: the trivial-action rows are falling factorials `n^{(r)}` (A008279). The `C_n` rows with
`r ≥ 1` are `(n−1)^{(r−1)}`, which matches the free-action formula
`t_{1+s} = t_1·(n−1)^{(s)}` proved in Lean (`tInj_add_eq_of_free`).

## 2. Counterexample hunt over all 525 pairs `(r, s)` with `r + s ≤ n`

| inequality | violations |
|---|---|
| coarse `t_{r+s} ≥ t_r (t_s − r)` (the conjecture as stated) | **68** (e.g. trivial on 3, `r=1, s=2`: `6 < 15`; also the transitive group `C_5`, `r=2, s=3`: `24 < 40`) |
| hierarchy `t_{r+s} ≥ t_r (t_1 − r)^{(s)}` | 0 (equality in 175 pairs) |
| upper bound `t_{r+s} ≤ t_r (n − r)^{(s)}` | 0 |
| repaired coarse `t_{r+s} ≥ t_r (t_s − (n^{(s)} − (n−r)^{(s)}))` | 0 |

All four rows are now settled by Lean theorems. The coarse inequality is refuted; the other three
are proved for every finite action.

## 3. Pattern seen in the data

The coarse bound fails because `r` is the right correction only when `s = 1`. The number of orbits
of `s`-tuples that cannot avoid a fixed `r`-tuple is bounded by the number of injective `s`-tuples
that meet it, which is `n^{(s)} − (n−r)^{(s)}`. When `s = 1` this equals `r`.

## 4. Script (exploratory; run with Python 3)

```python
from math import prod
def closure(gens,n):
    idp=tuple(range(n)); G={idp}; frontier=[idp]
    while frontier:
        new=[]
        for g in frontier:
            for h in gens:
                c=tuple(h[g[i]] for i in range(n))
                if c not in G: G.add(c); new.append(c)
        frontier=new
    return G
def ff(m,r): return prod(m-i for i in range(r)) if r<=m else 0
def spectrum(G,n):
    fixes=[sum(1 for i in range(n) if g[i]==i) for g in G]
    return [sum(ff(f,r) for f in fixes)//len(G) for r in range(n+1)]
# groups generated from cycles / reflections / transpositions; then every (r,s) with r+s<=n
# is tested against the four inequalities in the table above.
```
