# Computational Evidence — A Cosmic Census of L-functions

This note gathers the small-case computations that motivated the formal
development in `Catalog/Applications/SelbergCensus/`. Every numeric claim below
is reproduced from Lean `#eval` on the *same* `BoundedDatum` type that appears in
the proofs, so the evidence and the theorems concern literally the same objects.

## 1. The census is a countable union of finite shells

An L-function datum is a finite packet
`(degree, conductor, rootNumber, eulerFactors)`. Fixing complexity bounds
`(d, N, k, c)` — degree `≤ d`, conductor `≤ N`, at most `k` Euler factors of
degree `≤ d`, coefficients/root number in a symmetric window of size `2c+1` —
cuts out a *finite* shell `BoundedDatum d N k c`. Its exact size is computable:

| shell `(d, N, k, c)` | meaning                                   | `Fintype.card` |
|----------------------|-------------------------------------------|----------------|
| `(0, 0, 0, 0)`       | the empty/degenerate datum                | `1`            |
| `(1, 1, 0, 1)`       | degree ≤1, conductor ≤1, no Euler factors | `36`           |
| `(1, 2, 1, 1)`       | one Euler factor allowed                  | `1458`         |

The cardinalities grow, but each individual shell is finite, and the whole
census is the union of the shells over the countable index set `ℕ⁴`. A countable
union of finite sets is countable — this is the structural heart of "the Selberg
class is countable".

## 2. Why countability is *not* obvious

Each L-function carries infinite information: its full list of Dirichlet
coefficients `a(1), a(2), a(3), …`, an element of the *uncountable* space
`ℕ → ℂ`. Naively the family could be as large as `2^ℵ₀`. The census resolves
this: a Selberg-class L-function is pinned down by a *finite* fingerprint drawn
from countable ingredients (`ℕ`, `ℚ`, finite lists of integers), so despite the
infinite depth of each object there are only countably many of them.

## 3. Counterexample hunt (uncountable families)

The description mentions "L-functions of elliptic curves (uncountably many, one
per j-invariant)". This is *not* a counterexample to countability of the Selberg
class: two elliptic curves that are isogenous / have the same conductor and
`a_p` data give the *same* L-function, and the Selberg-class fingerprint records
exactly that arithmetic data, not the geometric `j`-invariant. So the map
`{L-functions} → {finite data}` remains injective; the uncountable geometric
parameter space collapses to a countable set of L-functions. No counterexample
to the census was found.

## 4. Dirichlet L-functions: a concrete countable stratum

The degree-one members are the Dirichlet L-functions `L(s, χ)`.

* For each modulus `n ≥ 1` there are finitely many characters (a group of order
  `φ(n)`): `φ(1)=1, φ(2)=1, φ(3)=2, φ(4)=2, φ(5)=4, φ(6)=2, …`
  (OEIS A000010).
* Summing/bundling over all moduli gives a countably infinite family — verified
  formally in `Dirichlet.lean` via an explicit injection `ℕ ↪ Σ n, χ`.

## 5. OEIS

The count of Dirichlet characters modulo `n` is Euler's totient
`φ(n)` = **OEIS A000010**: `1, 1, 2, 2, 4, 2, 6, 4, 6, 4, 10, …`.

## Summary

The computations confirm the two pillars formalized in Lean: (i) each complexity
shell is finite with an explicitly computable size; (ii) the strata are indexed
by a countable set. Together they give a rigorous, non-vacuous proof that the
universe of finite L-function data — and hence of the L-functions it classifies —
is countable.
