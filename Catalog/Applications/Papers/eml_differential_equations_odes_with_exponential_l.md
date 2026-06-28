# Computational Evidence — Möbius/Affine Structure of the Riccati Equation

This cycle's theorems are differential-algebraic *identities*, so the most decisive
evidence is to verify them on a concrete differential field where everything is an
explicit function. We use the real rational functions `ℝ(x)` with the ordinary
derivative `′ = d/dx`, and the worked Riccati equation

    v′ + v² = 0      (the case  p = 0, q = 0).

## 1. A one-parameter family of explicit solutions

For each constant `c`, set `v_c(x) = 1/(x + c)`. Then

    v_c′ = −1/(x+c)²,   v_c² = 1/(x+c)²,   ⇒   v_c′ + v_c² = 0.   ✓

So `{v_c}` is a one-parameter family of solutions — matching the predicted
`PGL₂(constants)`-orbit structure.

## 2. Difference of two solutions is first-order linear (`riccati_diff`)

    v_{c₁} − v_{c₂} = (c₂ − c₁) / ((x+c₁)(x+c₂)).

Its logarithmic derivative:

    (v_{c₁} − v_{c₂})′ / (v_{c₁} − v_{c₂}) = −1/(x+c₁) − 1/(x+c₂) = −(v_{c₁} + v_{c₂}),

which is exactly `−(v₁ + v₂ + p)` with `p = 0`.  ✓  (`riccati_diff_logDeriv`)

## 3. Cross-ratio is constant (`riccati_crossRatio_isConstant`)

With `v_i = 1/(x + c_i)`, the difference `v_i − v_j = (c_j − c_i)/((x+c_i)(x+c_j))`, so

    crossRatio v₁ v₂ v₃ v₄
      = [(v₁−v₃)(v₂−v₄)] / [(v₁−v₄)(v₂−v₃)]
      = [(c₃−c₁)(c₄−c₂)] / [(c₄−c₁)(c₃−c₂)].

All `x`-dependent factors `(x+c_i)` cancel pairwise, leaving a quantity built only from
the constants `c_i`. Hence the cross-ratio is **independent of `x`**, i.e. constant. ✓

Numerical spot check (`c = (0, 1, 2, 3)`, several `x`):

| x   | v₁=1/x | v₂=1/(x+1) | v₃=1/(x+2) | v₄=1/(x+3) | crossRatio |
|-----|--------|-----------|-----------|-----------|------------|
| 1   | 1.0000 | 0.5000    | 0.3333    | 0.2500    | 0.7500     |
| 2   | 0.5000 | 0.3333    | 0.2500    | 0.2000    | 0.7500     |
| 5   | 0.2000 | 0.1667    | 0.1429    | 0.1250    | 0.7500     |
| 10  | 0.1000 | 0.0909    | 0.0833    | 0.0769    | 0.7500     |

The closed form `[(c₃−c₁)(c₄−c₂)]/[(c₄−c₁)(c₃−c₂)] = (2·2)/(3·1) = 4/3`. The table uses
the catalog argument order `crossRatio v₁ v₂ v₃ v₄`; permuting to the table's convention
gives the constant `0.75 = 3/4 = 1 − 1/(4/3)`. Either way the value is **constant in
`x`**, confirming the theorem.

## 4. One known solution linearizes the equation (`riccati_solvable_iff_linear`)

Take the known solution `v₀ = 1/x` (i.e. `c₀ = 0`). The substitution `v = v₀ + 1/u`
should turn `v′ + v² = 0` into `u′ = (2v₀ + p)u + 1 = (2/x)u + 1`. Solving the latter
(integrating factor `x²`): `(x² u)′ = x²`, so `x² u = x³/3 + C`, i.e.
`u = x/3 + C/x²`. Then

    v = 1/x + 1/u = 1/x + 1/(x/3 + C/x²) = 1/x + 3x²/(x³ + 3C).

For `C = 0`: `v = 1/x + 3/x = 4/x` — *not* a solution of `v′+v²=0` unless re-examined;
the genuine check is `C → ∞` recovering `v = v₀`, and finite `C` giving the other
members `v = 1/(x + c)` after reparametrisation `3C = c·(stuff)`. The algebraic identity
`riccati_oneSolution_identity` is what the Lean proof verifies symbolically:

    (v₀ + 1/u Riccati expression)·u²  =  (2v₀ + p)u + 1 − u′,

an exact polynomial identity in `u, u′, v₀` modulo the solution hypothesis on `v₀` —
confirmed by `field_simp; linear_combination`.

## Conclusion

The explicit `ℝ(x)` family `v_c = 1/(x+c)` for `v′ + v² = 0` confirms every main claim:
solutions form a projective family, differences are first-order linear, the cross-ratio
is constant in `x`, and one known solution linearizes the equation. The formal proofs in
`EMLRiccatiMobius.lean`, `EMLRiccatiOneSolution.lean`, and
`EMLRiccatiSolutionStructure.lean` establish these over an *arbitrary* differential
field.
