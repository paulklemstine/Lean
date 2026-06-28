# Computational Evidence — Jacobian Conjecture, degree 2 and 3

All computations below were reproduced symbolically inside Lean (via
`MvPolynomial.pderiv` and `ring`) and are the content of the verified theorems in
`Druzkowski.lean`, `DegreeTwo.lean`, and `Counterexamples.lean`. This note records
the small-case hand computations that motivated the formal statements.

## 1. Jacobian determinants of small maps

For a 2-variable map `F = (F₀, F₁)`, `det(JF) = ∂F₀/∂X₀ · ∂F₁/∂X₁ − ∂F₀/∂X₁ · ∂F₁/∂X₀`.

| Map `F(X₀,X₁)`                              | `det(JF)`              | constant? | conclusion                |
|--------------------------------------------|------------------------|-----------|---------------------------|
| `(X₀ + a·X₁² + b·X₁, X₁)` (triangular)     | `1`                    | yes       | automorphism (verified)   |
| `(X₀ + (X₀−X₁)³, X₁ + (X₀−X₁)³)` Drużkowski| `1`                    | yes       | automorphism (verified)   |
| `(X₀ + X₁², X₁ + X₀²)` symmetric deg 2     | `1 − 4·X₀·X₁`          | **no**    | fails hypothesis          |
| `(X₀ + X₁³, X₁ + X₀³)` symmetric deg 3     | `1 − 9·X₀²·X₁²`        | **no**    | fails hypothesis          |

3-variable triangular `F = (X₀, X₁+X₀², X₂+X₀·X₁)` has unit upper-triangular
Jacobian, hence `det(JF) = 1` (verified).

## 2. Explicit inverses (back-substitution)

* Triangular 2D: `F = (X₀ + a X₁² + b X₁, X₁)`, inverse `G = (X₀ − a X₁² − b X₁, X₁)`.
* Drużkowski 2D: since `F₀ − F₁ = X₀ − X₁` is preserved, set `t = X₀ − X₁`; then
  `G = (X₀ − t³, X₁ − t³)`.  Verified `aeval G (F i) = X i` and conversely.
* Triangular 3D: `X₂ = Y₂ − X₀X₁ = Y₂ − Y₀(Y₁ − Y₀²)`, giving the correction
  term `+(X₀)³` in `G₂ = X₂ − X₀X₁ + X₀³`.  Verified both compositions.

## 3. Nilpotency check (Drużkowski structure)

For `A = !![1,−1; 1,−1]` we have `A·A = !![1−1, −1+1; 1−1, −1+1] = 0`, so `A` is
nilpotent of index 2.  The Jacobian of the cubic part `H = ((X₀−X₁)³,(X₀−X₁)³)`
is `J(H) = 3(X₀−X₁)²·A`, hence `J(H)·J(H) = 9(X₀−X₁)⁴·A² = 0`.  Verified as
`druzkowski_nilpotent`.

## 4. Counterexample hunt (constancy test)

The two symmetric candidates were eliminated by evaluating `det(JF)` at two
points:

* `1 − 4·X₀·X₁`: value `1` at `(0,0)`, value `−3` at `(1,1)` ⇒ not constant.
* `1 − 9·X₀²·X₁²`: value `1` at `(0,0)`, value `−8` at `(1,1)` ⇒ not constant.

No counterexample to the Jacobian Conjecture was found (none is expected: it is
open). What the search *does* establish is the precise boundary: naive symmetric
monomial maps are excluded by the constancy hypothesis, whereas the
cubic-linear/nilpotent construction produces genuine candidates that here turn
out to be honest automorphisms.

## OEIS

No integer sequence is naturally attached to these finite symbolic computations,
so no OEIS lookup applies.
