# Computational Evidence — Plethystic Triviality of the Shifted t-Schur Basis

All claims below are *also* fully proved in `PlethysticTriviality.lean`; the numbers
here are a sanity layer computed in exact `ℚ` arithmetic (coefficients of the
underlying generating functions), independent of the proof tactics.

## 1. One-row coefficients `qᵣ = coeff r (oneRowQ x)`

`oneRowQ x = (1 + xT)/(1 - xT)` should have coefficients `q₀ = 1`, `qᵣ = 2xʳ`.

At `x = 3`, coefficients `r = 0..4`:

```
[1, 6, 18, 54, 162]   =   [1, 2·3, 2·3², 2·3³, 2·3⁴]   ✓
```

(matches `oneRowQ_coeff`).

## 2. Plethystic-triviality ODE  `(oneRowQ x)' = oneRowQ x · oddPotential x`

Comparing degree `0..5` coefficients of the formal derivative (LHS) and of the
product `oneRowQ x · oddPotential x` (RHS), where
`oddPotential x = 2∑_{k≥0} x^{2k+1} T^{2k}`:

At `x = 3`:

```
LHS  (derivative):  [6, 36, 162, 648, 2430, 8748]
RHS  (product):     [6, 36, 162, 648, 2430, 8748]   ✓ identical
```

At `x = 2` the full degree-`0..5` coefficient vectors of LHS and RHS are equal
(`true`).  This is exactly `oneRowQ_logDeriv`.

The values `6, 36, 162, …` are `2(n+1)·3^{n+1}`, confirming the closed form
`coeff n (oneRowQ x)' = 2(n+1)x^{n+1}` that underlies the identity.

## 3. Cleared-denominator kernel identity `(1 - xT)·oneRowQ x = 1 + xT`

Coefficients of the product collapse to `[1, x, 0, 0, …]`, i.e. exactly
`1 + xT` (this is `oneRowQ_den`); the higher coefficients telescope
`2x^{m+2} - x·2x^{m+1} = 0`.

## 4. Triviality dictionary for the potential

The log-derivative potential `oddPsumSeries n` has

* odd-degree coefficients `= 0`             (`oddPsumSeries_odd_coeff`), and
* even-degree coefficient at `2k` `= 2·p_{2k+1}`  (`oddPsumSeries_even_coeff`).

So the entire information of the shifted basis' logarithmic derivative is carried
by the **odd** power sums `p₁, p₃, p₅, …` — the precise sense of "plethystic
triviality".

## OEIS note

The single-variable derivative coefficients `2(n+1)` (the `x`-free growth factor)
and the `q`-coefficient pattern `1, 2, 2, 2, …` are too elementary to warrant an
OEIS identifier; no nontrivial integer sequence is claimed.

## Counterexample hunt

No counterexample is possible: every statement is a proved Lean theorem with
clean axioms (`propext`, `Classical.choice`, `Quot.sound`). The numerical checks
above were run only as an independent cross-check of the formal statements.
