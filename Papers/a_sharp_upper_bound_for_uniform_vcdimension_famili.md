# Computational Evidence — Layered-Star VC Formula

All computations below were produced with Lean `#eval` on the exact definitions used in
the formal files (`Catalog/Novelty/LayeredStarFormula.lean`,
`Catalog/Novelty/UniformVCStar.lean`).

## 1. The layered-star formula on small cases

`Mformula n d = max_{0 ≤ k ≤ ⌊d/2⌋} Σ_{i=0}^k C(n - 2i - 1, d - 2i)`.
Each row is `(n, d, Mformula n d, Mformula n d = layeredSum n d ⌊d/2⌋?, C(n-1,d))`:

```
(2,0,1,true,1)  (3,0,1,true,1)  (4,0,1,true,1)  (5,0,1,true,1)
(4,1,3,true,3)  (5,1,4,true,4)  (6,1,5,true,5)  (7,1,6,true,6)
(6,2,11,true,10)(7,2,16,true,15)(8,2,22,true,21)(9,2,29,true,28)
(8,3,40,true,35)(9,3,62,true,56)(10,3,91,true,84)(11,3,128,true,120)
```

Observations, each later turned into a verified theorem:

* The 4th column is **always `true`**: the maximum over `k` is attained at the top index
  `k = ⌊d/2⌋`.  Formalised as `LayeredStarFormula.Mformula_eq_top`.
* `Mformula n d ≥ C(n-1,d)` (column 3 ≥ column 5), with equality iff `d ≤ 1`.  Formalised
  as `LayeredStarFormula.Mformula_ge_star`.  For `d ≥ 2` the higher layers strictly
  increase the value (`11 > 10`, `40 > 35`, …), showing the star is only the base layer.

## 2. The star construction is a genuine VC restriction

For `d = 1`, `r = d+1 = 2` (graphs).  A generic `2`-uniform family **can** shatter a
`2`-set: vertices `{a,b,c,d}` with edges `{a,b},{a,c},{b,c},{c,d}` shatters `{a,b}`
(`∅ ↦ {c,d}`, `{a} ↦ {a,c}`, `{b} ↦ {b,c}`, `{a,b} ↦ {a,b}`), so VC-dim `= 2 > 1`.
Hence uniformity alone does **not** force VC-dim `≤ d`.  The *star* (all edges through a
fixed vertex `x`) cannot shatter any `2`-set, so its VC-dim is `1 = d`.  This is the
content of `UniformVCStar.star_shatters_card_le` and `star_vcDim_eq`.

## 3. Star size / sharpness sanity check

`#(star x (d+1)) = C(n-1, d)` and, for `n ≥ 2d+1`, `vcDim = d` exactly:

| n | d | C(n-1,d) = #star | 2d+1 ≤ n ? | vcDim |
|---|---|------------------|------------|-------|
| 6 | 2 | C(5,2)=10        | yes        | 2     |
| 7 | 2 | C(6,2)=15        | yes        | 2     |
| 8 | 3 | C(7,3)=35        | yes        | 3     |

Verified symbolically by `UniformVCStar.star_card` and `UniformVCStar.star_vcDim_eq`.

## 4. OEIS note

For fixed `d = 2`, `Mformula (n) = C(n-1,2) + 1` gives `11,16,22,29,…` for `n = 6,7,8,9`,
i.e. `1 + n(n-3)/2 + …`; the star-only subsequence `C(n-1,2) = 10,15,21,28,…` is the
triangular numbers (OEIS A000217 shifted).  No exact match for the full `Mformula`
sequence was pursued, as the two-parameter family is the object of interest.
