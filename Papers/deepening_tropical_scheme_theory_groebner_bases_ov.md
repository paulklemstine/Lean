# Computational Evidence

All claims below were first probed numerically (min-plus arithmetic over `ℤ ∪ {∞}`
with `∞ = 10^6` as a sentinel) before being formalized.  Everything that survived
the numerics is now a theorem with a complete Lean proof; the one item that
*failed* the numerics became the counterexample theorem
`TropicalElimination.intersection_not_satisfiesElimination`.

Notation: for a coefficient vector `c` and a tropical vector `x` on a ground set
`E`, the *value vector* is `val_i = c_i + x_i`, and
`x ∈ H(c) :⇔ the minimum of val is attained at least twice` (with the all-`∞`
vector always in `H(c)`).

## 1. Elimination for a single tropical hyperplane

Test: for every pair `x, y ∈ H(c)` and every coordinate `e` with
`x_e = y_e ≠ ∞`, does there exist `z ∈ H(c)` with `z_e = ∞`,
`z ≥ min(x,y)` coordinatewise, and `z_i = min(x_i, y_i)` whenever `x_i ≠ y_i`?

| ground set | coefficient vectors tested | entries of `x,y,z` | pairs tested | failures |
|---|---|---|---|---|
| `|E| = 4` | all `c ∈ {0,1,2}^4` | `{0,1,2,3, ∞}` | all | **0** |

Observed structural pattern that became the proof: the naive candidate
`z⁰ = (min(x,y) off e, ∞ at e)` already works *unless* the value vector of `z⁰`
has a strictly unique minimum, and in that case the unique minimizing coordinate
`i₀` always satisfied `x_{i₀} = y_{i₀}` in every sampled instance.  That
observation is exactly the rigidity lemma
`TropicalElimination.tropVanishing_eq_of_unique_min`, and raising the lonely
coordinate `i₀` up to the second-smallest value closes the argument.

## 2. Counterexample hunt: intersections of two hyperplanes

Test: same elimination test for `V = H(c₁) ∩ H(c₂)`, with `z` ranging over all
vectors that satisfy the forced constraints (`z_e = ∞`, `z_i = min(x_i,y_i)` on
coordinates where `x,y` differ, `z_i ≥ min(x_i,y_i)` elsewhere) with entries in
`{0,1,2,3,∞}`.

First failure found (search over `c₁, c₂ ∈ {0,1,2}^4`):

```
c₁ = (0,0,0,0)   c₂ = (0,0,0,1)
x  = (0,0,1,0)   y  = (0,0,1,1)   e = 0
```

Both `x` and `y` lie in `H(c₁) ∩ H(c₂)`, and `x_0 = y_0 = 0`.  Elimination forces
`z_0 = ∞`, `z_3 = 0`, and allows `z_1 ≥ 0`, `z_2 ≥ 1`.  Membership in `H(c₁)`
then forces `z_1 = 0` (the minimum `0` must be attained twice and `z_2 ≥ 1`), and
membership in `H(c₂)` at coordinate `1` becomes impossible, because the competing
values are `∞`, `z_2 ≥ 1` and `1 + 0 = 1`, all `> 0`.  The argument is
value-range independent, and is the formal proof in
`Catalog/Tropical/TropicalLinearSpaceOperations.lean`.

## 3. Multiplicativity of tropical vanishing

Test: for random tropical polynomials `f` (vanishing at `w`) and `g` (arbitrary)
in two variables with 3–5 terms and integer coefficients in `[-3, 3]`, the
minimum of `f·g` at `w` was attained at least twice in every instance.

Pattern extracted: if `a₁ ≠ a₂` are two minimizing monomials of `f` and `b` is
any minimizing monomial of `g`, then `a₁ + b` and `a₂ + b` are two *distinct*
minimizing monomials of `f·g`, and the minimum value is the sum of the minima.
This is the proof of `TropicalPointIdeal.vanishesAt_mul_left`; note it needs no
monomial order, only cancellation of exponents.

## 4. Circuits of a tropical hyperplane

Test: enumerate the supports of nonzero members of `H(c)` for `|E| ≤ 5` and
finite `c`; record the minimal ones.

Result: the minimal supports were always exactly the `binom(n,2)` two-element
subsets — the circuits of the uniform matroid `U_{n-1,n}`.  Formalized as
`TropicalElimination.tropVanishing_isCircuit_iff` (both directions), and lifted
to the degreewise matroid of the tropical ideal of a point in
`TropicalPointIdeal.truncation_isCircuit_iff`.

No OEIS sequence is involved; the only counting statement here
(`#circuits = binom(n,2)`) is immediate from the circuit characterization.
