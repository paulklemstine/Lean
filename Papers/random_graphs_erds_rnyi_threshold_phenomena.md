# Computational Evidence — General Clique `K_r` Thresholds in `G(n,p)`

This note records the small-case checks that motivated and de-risked the formal
results in `Algebra/ErdosRenyi/Cliques.lean`. The central claim is the exact
first-moment identity

  𝔼[#K_r in G(n,p)] = C(n,r) · p^{C(r,2)}.

All checks below were run in Lean via `#eval` over concrete `Finset`s, so they
reflect the *same* objects (`powersetCard`) used in the proofs.

## 1. The two combinatorial ingredients

The identity factors through exactly two cardinalities, both `Finset.card_powersetCard`:

* number of potential edges of `K_n` = number of 2-subsets of `[n]` = `C(n,2)`;
* number of copies of `K_r` = number of `r`-subsets of `[n]` = `C(n,r)`;
* edges spanned by one `K_r` = 2-subsets of an `r`-set = `C(r,2)` (the exponent).

| object                                   | eval                                  | expected (`C`)        |
|------------------------------------------|---------------------------------------|-----------------------|
| `#edges(K_n)`, n = 0..5                   | `[0,0,1,3,6,10]`                      | `C(n,2)`              |
| `#r`-subsets of `[5]`, r = 0..5          | `[1,5,10,10,5,1]`                     | `C(5,r)`              |
| edges spanned by a 4-set in `Fin 6`      | `6`                                  | `C(4,2)=6`            |
| exponent `C(r,2)`, r = 0..5              | `[0,0,1,3,6,10]`                     | `C(r,2)`              |

These match exactly, confirming `expected_cliques` reduces to `C(n,r)·p^{C(r,2)}`.

## 2. Threshold scaling sanity (no fractional exponents)

The classical `K_r` appearance threshold is `p = n^{-2/(r-1)}`. Because
`C(r,2) = r(r-1)/2`, we have the *integer-power* identity

  n^r = (n^{2/(r-1)})^{C(r,2)},   hence   n^r · p^{C(r,2)} = (n^{2/(r-1)} · p)^{C(r,2)}.

So the condition `n^r · pₙ^{C(r,2)} → 0` used in `subcritical_cliques_vanish`
is *equivalent* to the textbook `n^{2/(r-1)} pₙ → 0`, but stated with integer
exponents only — which is what makes the squeeze `0 ≤ C(n,r) pₙ^{C(r,2)} ≤
n^r pₙ^{C(r,2)}` (via `C(n,r) ≤ n^r`, `Nat.choose_le_pow`) discharge it.

Specialisations recovered:
* `r = 3`: `C(n,3) p^3`, threshold `1/n` — matches the catalog's
  `ErdosRenyiConcrete.expected_triangles` / `subcritical_triangles_vanish`.
* `r = 2`: `C(n,2) p` (expected edges), threshold `1/n^2`.

## 3. Counterexample hunt

No counterexample is expected: the main statement is an *exact identity* plus an
elementary squeeze, both fully proved in Lean with only `propext`,
`Classical.choice`, `Quot.sound`. The brute-force `#eval`s above were the
de-risking step; the table entries all agree with the closed forms.

## 4. OEIS

The expectation polynomial coefficients are the binomial triangle entries
`C(n,r)` (OEIS A007318, Pascal's triangle) with the exponent `C(r,2)` running
through the triangular numbers `0,0,1,3,6,10,...` (OEIS A000217 on the relevant
slice). No new integer sequence is introduced.
