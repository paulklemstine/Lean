# Computational Evidence — C4: classifying the ternary Pythagorean trees

Setting. The **node set** is `N = {(m,n) ∈ ℤ² : 1 ≤ n < m, gcd(m,n) = 1, m+n odd}` with root
`(2,1)`; these are the Euclid parameters of primitive Pythagorean triples via
`(m,n) ↦ (m²−n², 2mn, m²+n²)`. A matrix `M = (a,b;c,d)` acts by `(m,n) ↦ (am+bn, cm+dn)`.
A **ternary tree** is a triple `T : Fin 3 → IntMap` that preserves `N`, never hits the root,
covers every non-root node, and does so injectively (jointly).

All numbers below were produced by `evidence.py` (output in `evidence.log`); the scripts
`search.py`, `search2.py`, `search3.py` (log: `search3.log`) are the earlier exploratory runs.

---

## 1. Admissible matrices: growth and determinant spectrum

The formal characterisation proved in `Catalog/Physics/TernaryPythagoreanTrees/Basic.lean`
(`preserves_iff`) says `M` preserves `N` iff

* `a+c` odd and `b+d` odd (parity),
* no odd prime divides `det M` (equivalently `|det M|` is a power of two),
* `c ≥ 0`, `c+d ≥ 0`, `(c,d) ≠ (0,0)` (the image stays in the cone `n ≥ 1`),
* `a−c ≥ 0`, `(a−c)+(b−d) ≥ 0`, `(a−c, b−d) ≠ (0,0)` (the image stays in the cone `n < m`).

Enumerating all `(2R+1)⁴` matrices with `|entries| ≤ R`:

| R | # admissible | set of `|det|` values observed |
|---|--------------|---------------------------------|
| 1 | 1            | {1} |
| 2 | 8            | {1, 2, 4} |
| 3 | 18           | {1, 2, 4, 8} |
| 4 | 39           | {1, 2, 4, 8, 16} |
| 5 | 67           | {1, 2, 4, 8, 16, 32} |
| 6 | 93           | {1, 2, 4, 8, 16, 32} |
| 7 | 138          | {1, 2, 4, 8, 16, 32} |
| 8 | 197          | {1, 2, 4, 8, 16, 32, 64} |

**Only powers of two ever occur.** This is the "`±2` obstruction" in its raw form, and it is
now a theorem: `Preserves.det_natAbs_eq_two_pow` in `Basic.lean`.

## 2. Cross-check of the characterisation against brute force

For every one of the `13⁴ = 28561` matrices with `|entries| ≤ 6` we compared the predicate
above against a direct check that `M` maps every node with `m ≤ 120` to a node.

```
tested 28561 matrices, mismatches: 0
```

So the finite characterisation is exactly right on this range — which is what
`preserves_iff` proves in general.

## 3. Counterexample hunt for the odd-prime obstruction

If an odd prime `p` divides `det M`, some node must be destroyed. Sample witnesses:

| `M` | `det` | first node killed |
|-----|-------|-------------------|
| `(3,0;1,1)` | 3 | `(2,1)` |
| `(1,3;0,3)` | 3 | `(2,1)` |
| `(3,3;1,2)` | 3 | `(3,2)` |
| `(5,0;1,1)` | 5 | `(3,2)` |

The formal proof (`Preserves.not_odd_prime_dvd_det`) constructs such a witness in general:
either `(p+1, p)` or a node `(m,1)` with `m` even solving a linear congruence mod `p`.

## 4. Exhaustive tree search

Take all 197 admissible matrices with `|entries| ≤ 8`, discard those whose image already
leaves the non-root node set with `m ≤ 200` (196 survive), and search all
`C(196,3) = 1 240 620` triples for a partition of `{(m,n) ∈ N : m ≤ 200} \ {(2,1)}`:

```
TREE ((1,1,0,2),(2,0,1,-1),(2,0,1,1))   dets [ 2, -2,  2]   Σ 1/(a(a+b)) = 1
TREE ((1,2,0,1),(2,-1,1,0),(2,1,1,0))   dets [ 1,  1, -1]   Σ 1/(a(a+b)) = 1
TREE ((1,3,0,2),(2,-1,1,0),(2,0,1,-1))  dets [ 2,  1, -2]   Σ 1/(a(a+b)) = 1
number of trees: 3
```

**Exactly three trees, not two.** The first is Price's, the second is Berggren's, and the
third — `{(1,3;0,2), (2,−1;1,0), (2,0;1,−1)}`, with mixed determinants `2, 1, −2` — is a
*hybrid* that the assignment's conjecture does not allow. It uses one Berggren branch, one
Price branch, and one new matrix `(1,3;0,2)`.

This refutation is now formal: `TernaryTree.mixed_isTernaryTree` verifies the hybrid is a
genuine ternary tree, and `TernaryTree.berggren_price_classification_false` states that the
Berggren/Price dichotomy fails.

## 5. Sanity check on the first generations

Growing each tree four generations from the root:

| tree | generation sizes | all images are nodes | all `1+3+9+27+81 = 121` distinct |
|------|------------------|----------------------|-----------------------------------|
| Berggren | 3, 9, 27, 81 | yes | yes |
| Price    | 3, 9, 27, 81 | yes | yes |
| Mixed    | 3, 9, 27, 81 | yes | yes |

## 6. The density identity

The final column of §4 records `Σ_i 1/(a_i(a_i+b_i)) = 1` for each tree. The quantity
`1/(a(a+b))` is the area proportion of `{(x,y) : 0 < y < x, ax+by ≤ B}` inside `{0 < y < x ≤ B}`,
i.e. the asymptotic density of the branch's image in the node cone; the identity is exactly
the statement that the three branches partition the cone. Per-tree:

* Berggren: `1/2 + 1/6 + 1/3 = 1`
* Price:    `1/2 + 1/4 + 1/4 = 1`
* Mixed:    `1/4 + 1/2 + 1/4 = 1`

Formalised as an exact rational identity in `Density.lean`
(`TernaryTree.branch_density_sum_one`).

The determinant absolute values also separate the three trees:
`{1,1,1}` (sum 3), `{2,2,2}` (sum 6), `{1,2,2}` (sum 5) — `TernaryTree.det_natAbs_sum_mem`.

## 7. OEIS

No OEIS lookup was performed (the working environment has no network access), so no claim is
made about whether the counts of admissible matrices `1, 8, 18, 39, 67, 93, 138, 197` appear
in OEIS. They are recorded here purely as raw data; note that the sequence depends on the
cut-off convention `|entries| ≤ R`. The generation sizes are the powers of three.

---

### What the evidence supports, and what it does not

* Supported and now proved: only powers of two occur as `|det|`; exactly three trees exist;
  every branch has `|det| ≤ 2`.
* Supported but **not** proved: the density interpretation of `1/(a(a+b))` as a genuine
  asymptotic lattice-point count (only the algebraic identity is formal).
* Refuted: the conjecture that the Berggren and Price triples are the only trees.
