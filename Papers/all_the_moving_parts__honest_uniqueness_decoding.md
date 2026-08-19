# Computational Evidence — scan schemes, exact cost, exact optimum

All numbers below were produced with `#eval` inside the project's Lean environment,
against the *same* definitions that the theorems are stated about
(`ScanSchemeDecoding.triangle`, `triangleOpt`, `ScanScheme.decodeCost`).
They are exploratory computations (kernel-reduced `#eval`, not `decide`-certified);
the general statements they suggested are **proved** in
`Catalog/Algebra/ScanSchemeDecoding/*.lean` with no `sorry` and only the standard
axioms `propext, Classical.choice, Quot.sound`.

## 1. The cost of one bucket

`triangle k = 1 + 2 + ⋯ + k` for `k = 0 … 7`:

```
[0, 1, 3, 6, 10, 15, 21, 28]
```

This is OEIS **A000217** (triangular numbers), as expected: decoding every key of a
bucket of size `k` once costs `1 + 2 + ⋯ + k`.

## 2. The candidate optimum

`triangleOpt N 3` for `N = 0 … 12`:

```
[0, 1, 2, 3, 5, 7, 9, 12, 15, 18, 22, 26, 30]
```

First differences `1,1,1,2,2,2,3,3,3,4,4,4` — the `m`-fold repetition pattern that a
balanced profile must have, and the fingerprint of the "quasi-polynomial in `N` with
period `m`" behaviour proved in `triangleOpt_eq`.

## 3. Brute-force minimisation over *all* bucket maps

For each `N` we enumerated **every** function `Fin N → Fin m` (i.e. every scan scheme),
computed `∑ x, decodeCost x` honestly through the intra-bucket index, and took the
minimum and maximum. Tuples are `(N, brute-force min, triangleOpt N m, brute-force max)`.

`m = 2` (up to `2^7 = 128` schemes):

```
[(0,0,0,0), (1,1,1,1), (2,2,2,3), (3,4,4,6), (4,6,6,10), (5,9,9,15), (6,12,12,21), (7,16,16,28)]
```

`m = 3` (up to `3^6 = 729` schemes):

```
[(0,0,0,0), (1,1,1,1), (2,2,2,3), (3,3,3,6), (4,5,5,10), (5,7,7,15), (6,9,9,21)]
```

*Observations.* (i) The brute-force minimum equals `triangleOpt N m` in every case —
this became `scan_optimum` (`IsLeast`). (ii) The brute-force maximum equals
`triangle N` in every case — this became `scan_maximum` (`IsGreatest`), proved from
superadditivity `triangle a + triangle b ≤ triangle (a+b)`.

## 4. Counterexample hunt for the rigidity claim

Conjecture tested: *a scheme is cost-optimal **iff** every bucket size lies in
`{⌊N/m⌋, ⌊N/m⌋+1}`.*  For `N = 6`, `m = 4` we counted the schemes where the two sides
of the equivalence disagree, over all `4^6 = 4096` schemes:

```
0
```

No counterexample. The claim is now the theorem `sum_triangle_eq_opt_iff` /
`ScanScheme.decodeCost_eq_opt_iff`, proved from the exact slack
`triangle k − (T(q) + (q+1)(k−q)) = d(d−1)/2`, `d = k − q`.

## 5. Counting optimal schemes

Number of bucket maps `Fin 5 → Fin 3` attaining `triangleOpt 5 3 = 7`:

```
90
```

which matches `3 · 5!/(2!·2!·1!) = 3 · 30`: choose which of the 3 buckets receives the
single "light" load (3 ways) and then distribute the keys (30 ways). This is consistent
with the rigidity theorem (optimal ⇔ loads `(2,2,1)` in some order) and with the
`Sym(α) × Sym(β)` invariance of the cost proved in
`decodeCost_perm_invariant` / `decodeCost_relabel`.

## 6. End-to-end check of the constructed scheme

`∑ x, (modScheme 10 (0<3)).decodeCost x = 22` and `triangleOpt 10 3 = 22`: the residue
scheme, decoded through the honest intra-bucket index, meets the optimum exactly
(`modScheme_decodeCost`).
