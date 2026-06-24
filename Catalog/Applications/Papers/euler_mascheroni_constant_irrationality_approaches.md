# Computational Evidence — Euler–Mascheroni constant, irrationality approaches

Concise numerical support for the formal results in
`Catalog/EulerMascheroni/Irrationality.lean` and `.../EffectiveBounds.lean`.
`γ = 0.5772156649…`.

## 1. Bracketing sequences (small cases)

`seq n = H_n − log(n+1)`,  `seq' n = H_n − log n`,  with `seq n < γ < seq' n`.

| n | H_n (=harmonic n) | seq n | seq' n | width = log(n+1)−log n |
|---|-------------------|-------|--------|------------------------|
| 1 | 1       | 0.30685 | 1.00000 | 0.69315 |
| 2 | 3/2     | 0.40546 | 0.80685 | 0.40546 |
| 6 | 49/20   | 0.50575 | 0.65067 | 0.15415 |
| 10| 7381/2520| 0.53107 | 0.62638 | 0.09531 |

All rows satisfy `seq n < 0.57722 < seq' n`, and `width = seq' n − seq n`
(verified symbolically by `eulerMascheroni_trap_width_eq`).  Row n=6 shows the
Mathlib bounds `1/2 < γ < 2/3`.

## 2. Convergence rate

`width(n) = log(1 + 1/n) ≈ 1/n − 1/(2n²)`.  This is only **linear** decay
(`~1/n`), far slower than the geometric rates used in the irrationality proofs of
`e` and `ζ(3)`.  Hence the bracketing certifies `γ` to high precision but does
**not** by itself yield irrationality — and crucially the endpoints are
transcendental (they contain `log`), not rational, so they cannot be fed to the
integer-linear-form engine `irrational_iff_forall_eps_linear_form`.

## 3. Irrationality-engine sanity check

The engine says: `x` irrational ⇔ for all `ε>0` there are integers `q≥1, p` with
`0 < |qx − p| < ε`.  For a rational test value `x = 49/20` (denominator 20),
no nonzero form beats `1/20`: e.g. `q=1..19` give `|qx − round| ≥ 1/20`,
confirming the rational floor `|qx−p| ≥ 1/den` used in the backward direction.

## 4. OEIS

The harmonic numerators/denominators are OEIS A001008 / A002805.  No new
integer sequence is introduced by this cycle.

## 5. Counterexample hunt

The engine `irrational_iff_forall_eps_linear_form` is a proven *iff* (no
counterexample possible).  The γ-specific theorem is a faithful instantiation and
makes no unproven universal claim about γ itself.
