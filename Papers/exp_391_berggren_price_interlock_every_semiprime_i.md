# Computational evidence (Experiment 391 — Berggren–Price interlock)

All claims below were first checked numerically and are now **formally proved** in
`Catalog/Algebra/BerggrenPriceInterlock/` (five files, no `sorry`, no extra axioms).
Only the exploratory numbers are reported here; the Lean files are the authority.

## 1. The vertex set and the two generator triples

Nodes are Euclid parameters `(m,n)` with `1 ≤ n < m`, `gcd(m,n) = 1`, `m + n` odd.

| tree | generators on `(m,n)` | 2×2 determinants |
|---|---|---|
| Berggren (Barning–Hall) | `(2m−n, m)`, `(2m+n, m)`, `(m+2n, n)` | `+1, −1, +1` |
| Price | `(2m, m−n)`, `(2m, m+n)`, `(m+n, 2n)` | `−2, +2, +2` |

A brute-force scan of all nodes with `m ≤ 400` found:

* every non-root node is hit by **exactly one** generator applied to exactly one node
  (0 missing, 0 duplicated) — for **both** triples of generators;
* the root `(2,1)` is in the image of no generator.

Formalised as `berg_tree` / `price_tree` (unique word for every node).

## 2. The N-node

For `N = p·q` with `p,q` odd coprime, `1 ≤ p < q`, the Fermat pair
`(m,n) = ((p+q)/2, (q−p)/2)` is a node and

```
odd leg  m² − n² = (m−n)(m+n) = p·q = N     even leg 2mn = (q²−p²)/2
hypotenuse m² + n² = (p²+q²)/2
```

Checked on all coprime odd pairs with `q < 400` (never failed) and on random 14–23 bit
prime pairs. Formalised as `isNode_fermatNode`, `oddLeg_fermatNode`,
`hypot_fermatNode`, `evenLeg_fermatNode`, and (in both trees) `berg_N_node`,
`price_N_node`.

## 3. Shared edges of the two descents

Scanning all nodes with `m < 2000`, the Berggren parent equals the Price parent for
exactly **two** nodes: `(3,2)` and `(4,1)` — the two children of the root.
Formalised (for all nodes, no bound) as `shared_edges`, with non-vacuity witnessed by
`shared_edges_exist`.

## 4. Depth data

| family | Berggren depth | Price depth |
|---|---|---|
| `(2^(i+2), 1)` | `2^(i+1) − 1` (exponential) | `i + 1` (linear) |
| `(2k+2, 1)` | `k` | — |

Verified for `i ≤ 12` by direct descent; proved for all `i` in `depth_duality` and
`berg_depth_line`.

Ratio law: for all nodes with `m < 300`, `m ≤ (2·d_B + 3)·n` held with no exception, and
the trade-off `2·s·(2·d_B+3)² ≥ m` (with `s = m − ⌊√N⌋` the Fermat scan length) held with
no exception. Proved as `berg_ratio_bound` and `berg_depth_fermat_tradeoff`.

## 5. Hypotenuse probe is empty for 15, 21, 35, 77, 91

No node with `m ≤ 400` has `N ∣ m² + n²` for these `N`. Reason (now proved): each of
`15, 21, 35, 77, 91` has a prime factor `≡ 3 (mod 4)`, and primitivity forbids such a
prime from dividing `m² + n²` (`not_dvd_hypot_of_prime_three_mod_four`, via the Legendre
symbol `(−1/p) = −1`). This is a *theorem for all nodes*, not a sample.

## 6. Leg swap on triples

With `S` the leg swap `(a,b,c) ↦ (b,a,c)` and the classical `3×3` generators,
`S·B₁·S = B₃`, `S·B₂·S = B₂`, `S·B₃·S = B₁` (3/3 hits) while for the three Price
matrices `S·P·S` is never a Price matrix (0/3 hits; the `(1,0)` entry becomes odd).
Determinants: Berggren `±1`, Price `±8 = (±2)³` — consistent with the Veronese lift of
the `2×2` maps. Formalised as `swap_bergT_*`, `swap_priceT_ne`, `bergT_action`,
`priceT_action`.
