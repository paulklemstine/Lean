# Computational Evidence — Hilbert 13 / Kolmogorov superposition cycle

This note records the small-case checks that motivated the formalised theorems in
`Bridges/Hilbert13Superposition.lean`, `Bridges/Hilbert13SeventhDegree.lean`, and
`Bridges/Hilbert13NeuralBridge.lean`. The mathematical claims themselves are
proved unconditionally in Lean (axioms: only `propext`, `Classical.choice`,
`Quot.sound`), so this file is supporting intuition, not the verification.

## 1. Tschirnhaus depression of a concrete septic

Take the split septic with roots `1,…,7`:

```
f(x) = (x-1)(x-2)(x-3)(x-4)(x-5)(x-6)(x-7),  monic, degree 7.
```

* Sub-leading coefficient `a₆ = -(1+2+⋯+7) = -28`.
* The depression shift is `r = -a₆ / 7 = 28/7 = 4`.
* `g := taylor 4 f` has roots `i - 4` for `i = 1..7`, i.e. `{-3,-2,-1,0,1,2,3}`.
* These roots are symmetric about `0`, so their sum is `0`, hence the `x⁶`
  coefficient of `g` is `0`. ✓ (matches `septic_tschirnhaus`).

The root correspondence `f.eval x = 0 ↔ g.eval (x - 4) = 0` is visible directly:
`x ∈ {1..7} ⟺ x-4 ∈ {-3..3}`.

This is the `n = 7`, `char 0` instance of the general lemma `taylor_depresses`,
whose key computation is that the degree-`(n-1)` Hasse derivative of a monic
degree-`n` polynomial is the affine function `a_{n-1} + n·y`.

## 2. Superposition inner layer as a binary fold

For `n = 3`, `φ = (sin, cos, id)`, `x = (a,b,c)`:

```
innerSum φ x = sin a + cos b + c
             = sin a + (cos b + (c + 0))
             = List.foldr (·+·) 0 [sin a, cos b, c].
```

Every aggregation step uses only the single **two-variable** function `(·+·)` —
the precise content of `innerSum_eq_foldr` and the slogan "functions of two
variables suffice" for Hilbert 13 in the continuous category.

## 3. Closure / counterexample hunt

* **Additive closure** (`superposition_add`): a superposition with `m₁` outer
  terms plus one with `m₂` terms is a superposition with `m₁ + m₂` terms. We
  tested whether `m` could stay fixed under addition (i.e. whether the class with
  a *fixed* outer width is additively closed) — it is **not** in general, which is
  exactly why Kolmogorov's universal width bound `2n+1` is a deep theorem rather
  than a triviality. No counterexample to the proved (growing-`m`) statement was
  found.

* **Lipschitz regularity** (`superposition_lipschitz`): for random Lipschitz
  univariate pieces the empirical Lipschitz constant of the assembled
  superposition never exceeded `Σ_q KΦ_q · (Σ_p Kφ_{q,p})`; the bound is attained
  for affine pieces, so it is tight.

## OEIS

The depression shifts `-a_{n-1}/n` and the Kolmogorov width sequence `2n+1`
(`3,5,7,9,…`, OEIS A005408, the odd numbers) appear; no new sequence was needed.
