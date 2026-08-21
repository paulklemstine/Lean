# Computational Evidence — Berggren ⟷ Markoff Transfer

All numbers below were computed by direct enumeration before any Lean formalization, and
every structural pattern they suggested is now a machine-checked theorem in
`Catalog/Cryptography/MarkoffTransfer/`.  (OEIS identifiers are quoted from memory; no
online lookup was possible in this environment, so treat the identifiers — not the
numerical data — as unverified.)

## 1. Level counts: ternary vs binary

Berggren tree (root pair `(2,1)`, three moves `A, B, C` of the catalog's `actGen`):

| depth n | 0 | 1 | 2 | 3 | 4 | 5 |
|---|---|---|---|---|---|---|
| # nodes | 1 | 3 | 9 | 27 | 81 | 243 |

Markoff tree (root `(1,2,5)`, two ascending Vieta moves):

| depth n | 0 | 1 | 2 | 3 | 4 | 5 | 6 |
|---|---|---|---|---|---|---|---|
| # nodes | 1 | 2 | 4 | 8 | 16 | 32 | 64 |

No collisions occurred at any computed depth on either side (all `3^n` resp. `2^n` nodes
were pairwise distinct).  Formalized as `bLevel_card` (`= 3^n`) and `mLevel_card` (`= 2^n`),
whence the isomorphism conjectured in the mission statement is false
(`no_local_tree_iso`, `no_injective_level_map`).

## 2. Markoff levels (first nodes at each depth)

```
0: (1,2,5)
1: (1,5,13)  (2,5,29)
2: (1,13,34) (2,29,169) (5,13,194) (5,29,433)
3: (1,34,89) (2,169,985) (5,194,2897) (5,433,6466) ...
```
Every triple listed satisfies `x²+y²+z² = 3xyz` (checked exhaustively to depth 6).

## 3. The two spines

* Markoff golden spine (`x = 1`):  `1, 1, 2, 5, 13, 34, 89, 233, 610, 1597, 4181, 10946`
  — odd-index Fibonacci numbers (A001519), recursion `u(n+2) = 3u(n+1) − u(n)`,
  growth rate `(3+√5)/2 = φ²`.
  Formalized: `markoffSpine_isMarkoff`, `markoffSpine_succ_eq_fib`.

* Berggren silver spine (iterate the hyperbolic generator `B` from `(2,1)`, take
  hypotenuses `m²+n²`): `5, 29, 169, 985, 5741, …` (A001653), recursion
  `u(n+2) = 6u(n+1) − u(n)`, growth rate `3+2√2` = (silver ratio)².
  Formalized: `bHyp_rec`, matching the catalog's `M₂.charpoly = (X+1)(X²−6X+1)`.

The two characteristic polynomials `X²−3X+1` and `X²−6X+1` have distinct traces, and
`√5 ∉ ℚ(√2)`: formalized as `spine_not_conjugate` and `sqrt_five_notMem_silver_field`.

## 4. The unexpected coincidence found while hunting for a transfer

The Berggren silver-spine hypotenuses `5, 29, 169, 985` are exactly the entries of the
Markoff triples whose smallest coordinate is `2`:

```
(2, 5, 29), (2, 29, 169), (2, 169, 985), (2, 985, 5741), …
```

because the Markoff Vieta move over the fixed coordinate `x = 2` is `z ↦ 6y − z`, the very
recursion of the Berggren spine.  Both directions of this coincidence are now theorems:
`bHyp_isMarkoff` (Berggren ⇒ Markoff) and `markoff_min_two_classification` (Markoff ⇒
Berggren), combined in `berggren_hyp_iff_markoff_two`.

## 5. Counterexample hunt

* *Ternary/binary*: searched for any Markoff node with three distinct Vieta children —
  none exists; the two children of a strictly ordered node are distinct and there are only
  two (`childL_ne_childR`, `parent_child`).
* *Linearity of the Vieta move*: fitting a `3×3` matrix to the map `(x,y,z) ↦ (x,y,3xy−z)`
  on the four triples `(1,1,1), (1,2,5), (1,5,13), (2,5,29)` gives the inconsistent system
  `p+q+r=2, p+2q+5r=1, p+5q+13r=2, 2p+5q+29r=1` (the first three force
  `(p,q,r) = (0,3,−1)`, which yields `−14 ≠ 1` on the fourth).  Formalized as
  `vieta_not_linear`.
* *Uniqueness*: for all triples computed to depth 6, the pair (minimum, maximum)
  determined the triple, in agreement with the proved `markoff_middle_unique`; no
  counterexample to the open Markoff uniqueness conjecture was found (none expected).
