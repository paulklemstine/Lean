# Computational Evidence: Generalized Mertens Recursion Identity

We test the claim

> For all integers `x ≥ 2` and `u` with `⌊√x⌋ < u < x`,
> `M(x) = ∑_{k=1}^{⌊x/u⌋} μ(k)·S(⌊x/k⌋, u)`,

where `M(x) = ∑_{n≤x} μ(n)` is the Mertens function and

`S(y,u) = 1 − ∑_{n=⌊y/u⌋+1}^{κ_y} M(⌊y/n⌋) + κ_y·M(⌊√y⌋) − ∑_{n=1}^{⌊√y⌋} ⌊y/n⌋·μ(n)`,
`κ_y = ⌊y/(⌊√y⌋+1)⌋`.

## 1. Exhaustive small-case verification

Using the exact integer definitions (Möbius via Mathlib's `ArithmeticFunction.moebius`),
the identity was checked for **every** valid pair `(x, u)` with `2 ≤ x < 60` and
`⌊√x⌋ < u < x`. All instances matched `M(x)`; no counterexample was found.

Sample of `M(x)` values (Mertens function, OEIS **A002321**):

| x | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 |
|---|---|---|---|---|---|---|---|---|---|----|
| M(x) | 1 | 0 | −1 | −1 | −2 | −1 | −2 | −2 | −2 | −1 |

These agree with A002321.

## 2. Key structural discovery (drives the formal proof)

Empirically (checked for all `1 ≤ y < 80` and `⌊√y⌋ < u`), the elaborate summand
collapses:

> **`S(y, u) = ∑_{j=1}^{⌊y/u⌋} M(⌊y/j⌋)`** whenever `u > ⌊√y⌋`.

(The only failure is the degenerate `y = 0`, which never occurs in the theorem since
`⌊x/k⌋ ≥ 1` throughout.) This collapse is exactly `Sfun_eq` in the Lean development,
and it reduces the whole identity to a Möbius double-sum reindexing.

## 3. Supporting identities (verified for `1 ≤ y < 60`)

* **Fundamental identity:** `∑_{k=1}^{y} M(⌊y/k⌋) = 1`.
* **Hyperbola split:** `∑_{k=1}^{κ_y} M(⌊y/k⌋) + ∑_{m=1}^{ν_y} ⌊y/m⌋·μ(m) − κ_y·M(ν_y) = 1`,
  with `ν_y = ⌊√y⌋`.

Both hold in every tested case and are proved formally (`mertens_fundamental`,
`hyperbola_split`).

## 4. Counterexample hunt

No counterexamples to the main identity, the `S`-collapse, the fundamental identity, or
the hyperbola split were found in the ranges above. All checks were performed with exact
integer arithmetic (no floating point), so the evidence is decisive for the tested range.
The formal proof in `MertensRecursion.lean` then establishes the identity for all `x, u`.
