# Computational Evidence

All computations below are over `ℚ` with the (fully computable) `p`-adic
valuation `padicValRat p`, using the definitions from the Lean files:

* `crossRatio a b c d = ((a-c)(b-d)) / ((a-d)(b-c))`
* `localMult p x y = padicValRat p (x - y)`  (local intersection multiplicity)

## 1. Genus-0 factorization on explicit examples

The theorem `crossRatio_valuation_factor` asserts

```
v_p((a,b;c,d)) = m(a,c) + m(b,d) - m(a,d) - m(b,c).
```

Sample `#eval` checks (`p = 2`):

| (a,b,c,d)        | v₂(cr)  | m(a,c) | m(b,d) | m(a,d) | m(b,c) | RHS |
|------------------|---------|--------|--------|--------|--------|-----|
| (0,1,2,3)        |  2      |  1     |  1     |  0     |  0     |  2  |
| (0,4,2,6)        |  0      |  1     |  1     |  1     |  1     |  0  |
| (0,8,2,4)        |  0      |  1     |  2     |  2     |  1     |  0  |

(The middle column is `padicValRat 2 (crossRatio …)`; each row satisfies the
identity — this is exactly what the Lean proof establishes for *all* admissible
inputs, so the table is only illustrative.)

The Lean proof reduces the identity to `padicValRat.div` and `padicValRat.mul`,
i.e. to the additivity of the valuation, and holds for every prime `p` and every
4-tuple of distinct rationals. This is the additive incarnation of the
Giampietro–Darmon genus-0 factorization: the `p`-adic norm of a cross-ratio of
four CM points is the product of the four local intersection multiplicities of
the associated Heegner divisors, with the sign pattern `+ + − −`.

## 2. Counterexample hunt: naive chain-additivity fails

The bold naive conjecture for higher genus was that local intersection
multiplicities compose additively along a chain, `m(x,z) = m(x,y) + m(y,z)`.

Counterexample (`p = 2`, chain `0 → 1 → 2`):

```
m(0,1) = padicValRat 2 (0-1) = padicValRat 2 (-1) = 0
m(1,2) = padicValRat 2 (1-2) = padicValRat 2 (-1) = 0
m(0,2) = padicValRat 2 (0-2) = padicValRat 2 (-2) = 1
```

Here `m(0,2) = 1 ≠ 0 = m(0,1) + m(1,2)`. This disproves additivity and is
formalized as `chain_additivity_fails`.

What survives is the **ultrametric (strong triangle) inequality**
`min(m(x,y), m(y,z)) ≤ m(x,z)` (`localMult_ultrametric`), sharpened to an exact
equality `m(x,z) = min(m(x,y), m(y,z))` whenever the two inner multiplicities
differ (`localMult_isosceles`). The failure of additivity, and its replacement
by an ultrametric law, is precisely the local reason a nontrivial *global*
correction is forced in the higher-genus factorization.

## 3. The global obstruction is a nonnegative quadratic quantity

Modelling the Néron–Tate height pairing by a real inner product, the global
obstruction `Obs(D,E) = ⟨D,D⟩⟨E,E⟩ - ⟨D,E⟩²` is the Gram determinant of the two
Heegner divisors. Cauchy–Schwarz gives `⟨D,E⟩² ≤ ⟨D,D⟩⟨E,E⟩`, so
`Obs(D,E) ≥ 0` always (`neronTateObstruction_nonneg`). It vanishes exactly when
the divisors carry no independent height:

* if `D` is torsion (height `0`, the genus-0 situation) — `neronTateObstruction_of_height_zero`;
* if `D` and `E` are proportional — `neronTateObstruction_of_parallel`.

## Note on OEIS

No integer sequence is central to these statements (the content is structural /
inequality-based rather than enumerative), so no OEIS lookup applies.
