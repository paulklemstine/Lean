/-
# Approximate Tower Rigidity — Definitions

This file introduces the definitions for approximate depth rigidity of
iterated exponentials (tower functions). The key concept is *relative
approximation*: a function `g` ε-relatively-approximates `iterExp n` on
`[a, b]` if `|iterExp(n, x) - g(x)| < ε · |iterExp(n, a)|` for all
`x ∈ [a, b]`.

## Key Definitions

- `RelApproximatesOn f g ε a b`: relative approximation on [a, b]
- `approxDepthBound n ε`: computable lower bound on DAG depth for ε-approximation
- `TowerGap n D`: the ratio measuring the inherent tower separation

## Significance

The approximate rigidity theorem shows that even allowing exponentially
small relative error, one cannot shortcut the depth hierarchy of iterated
exponentials by more than O(log log(1/ε)) levels. This quantifies the
approximation-theoretic rigidity of tower functions.
-/
-- This file re-exports definitions from the Theorems file.
-- See Pythagorean.ApproxTowerRigidity.Theorems for the full development.
import Pythagorean.ApproxTowerRigidity.Theorems