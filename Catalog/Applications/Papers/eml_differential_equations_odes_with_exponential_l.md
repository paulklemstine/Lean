# Computational Evidence — EML Differential Equations Cycle

Concise numerical/structural checks performed before formalizing the Lean theorems
in `EMLDifferentialGalois.lean`, `EMLKovacicSharp.lean`, `EMLWronskianGalois.lean`.

## 1. Kovacic parity test on the cleared Riccati identity

The cleared Riccati identity for `y″ = f·y` is

    p′·q − p·q′ + p² = f·q²      (v = p/q, q ≠ 0).

Degree count of the left side: `deg(p²) = 2·deg p`, `deg(p′q − pq′) ≤ deg p + deg q − 1`.
Right side: `deg(f·q²) = deg f + 2·deg q`.

| f          | deg f | parity | rational Riccati solution? |
|------------|-------|--------|----------------------------|
| X          | 1     | odd    | NONE (Airy)                |
| X³         | 3     | odd    | NONE                       |
| X^(2k+1)   | 2k+1  | odd    | NONE (generalized Airy)    |
| X² + 1     | 2     | even   | v = X  (explicit!)         |

Verification of the even witness `f = X²+1`, `v = X` (p = X, q = 1):

    p′·q − p·q′ + p² = 1·1 − X·0 + X² = X² + 1 = f·q².  ✓

This `v = X` is the logarithmic derivative of `y = e^{x²/2}`, which solves
`y″ = (x² + 1)·y` — an EML-solvable equation, confirming the odd-degree hypothesis
is genuinely necessary. Both rows are formalized:
`EMLKovacicSharp.no_rational_riccati_genAiry` (odd, impossible) and
`EMLKovacicSharp.riccati_evenDeg_solvable` (even, witnessed).

## 2. Constants subfield closure (spot check of the field axioms)

For a derivation `D` with `Da = Db = 0`:
- `D(a+b) = 0`, `D(ab) = a·Db + b·Da = 0`, `D(-a) = 0`, `D(a⁻¹) = -a⁻²·Da = 0`.
All four close, so `{x | x′ = 0}` is a subfield — formalized as
`EMLDiffGalois.constantsSubfield`.

## 3. Wronskian linear-independence detector (2×2 determinant check)

A constant dependence `c₁y₁ + c₂y₂ = 0` differentiates to `c₁y₁′ + c₂y₂′ = 0`
(constants drop out). The 2×2 system in `(c₁, c₂)` has a nontrivial solution, so its
determinant — the Wronskian `W = y₁y₂′ − y₂y₁′` — vanishes:

    c₁·W = (c₁y₁)y₂′ − y₂(c₁y₁′) = −c₂y₂y₂′ + c₂y₂y₂′ = 0,  similarly c₂·W = 0.

Nontriviality of `(c₁, c₂)` ⇒ `W = 0`. Formalized as
`EMLWronskianGalois.wronskian_eq_zero_of_linDep`; the contrapositive gives the
independence detector.

## OEIS

No new integer sequence arises; the relevant invariant is the *parity* of `deg f`
(A000035 applied to polynomial degree), which is exactly the Kovacic decision bit.
