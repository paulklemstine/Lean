# Computational evidence

Numerical exploration carried out before formalizing the five conjectures FD1–FD5.
All *claims* in the project are backed by the Lean proofs in `Catalog/Logic/`; the
tables below are exploratory only and were used to pick witnesses and to check that
no conjecture was false in an unnoticed way.

## FD1 — necessity of subexponentiality

The counterexample hunt was structural rather than numerical.  If `L` fails
subexponentiality at rate `δ`, i.e. `L k > exp(δ k)` for infinitely many `k`, then
with `q = (e^{-δ}+1)/2 ∈ (e^{-δ},1)` one has `q e^{δ} > 1`, hence on those `k`

    L k · (4q)^k > e^{δ k} 4^k q^k = 4^k (q e^{δ})^k ≥ 4^k .

So `r k = 4^k` on the bad set and `0` elsewhere satisfies the loss-bounded hypothesis
while `sup_k (r k)^{1/k} = 4`.  Sanity check with `δ = log 2`, bad set = all `k`:
`q = (1/2+1)/2 = 3/4`, `q e^{δ} = 3/2 > 1`.  Formalized as
`RamseyBounds.not_absorbableLoss_of_not_subexponentialLoss`.

## FD2 — root test

Root sequences examined:

| `r k`            | `(r k)^{1/k}`     | `limsup` | sub-four bound? |
|------------------|-------------------|----------|-----------------|
| `3^k`            | `3`               | `3`      | yes             |
| `k^d · 3^k`      | `→ 3`             | `3`      | yes             |
| `C(2k,k)`        | `→ 4`             | `4`      | no              |
| `k^k`            | `k` (unbounded)   | `∞`      | no              |

The last row is the falsifying case for the *real-valued* `limsup`: in `ℝ` the set
`{a | eventually (r k)^{1/k} ≤ a}` is empty and `sInf ∅ = 0`, so the naive invariant
reports `0 < 4`.  This motivated formalizing the conjecture with the `ℝ≥0∞`-valued
`limsup` and separately proving the real-valued version false.

## FD3 — binomial versus entropy base

Ratio `(n+1) · C(n,s) · s^s · t^t / n^n` (the quantity proved `≥ 1`), and the raw
ratio `C(n,s) s^s t^t / n^n`:

| `n`  | `s`  | `(n+1)·C·s^s·t^t/n^n` | `C·s^s·t^t/n^n` |
|------|------|-----------------------|------------------|
| 10   | 2    | 3.322                 | 0.302            |
| 10   | 3    | 2.935                 | 0.267            |
| 10   | 5    | 2.707                 | 0.246            |
| 50   | 12   | 6.687                 | 0.1311           |
| 50   | 16   | 6.131                 | 0.1202           |
| 50   | 25   | 5.726                 | 0.1123           |
| 200  | 50   | 13.071                | 0.06503          |
| 200  | 66   | 12.041                | 0.05991          |
| 200  | 100  | 11.326                | 0.05635          |

The second column stays comfortably above `1` (in fact it grows like `√n`), and the
third decays only polynomially — exactly the polynomial-loss regime that cannot be
converted into a proportional saving.  Formalized (in the sharp `≥ 1` form) as
`RamseyBounds.pow_self_le_succ_mul_choose_mul`.

## FD4 — tabulated diagonal Ramsey bounds

Table used: `r(2)=2, r(3)=6, r(4)=18, r(5)=48` (the classical values/upper bounds for
`R(k,k)`; OEIS A212954 / A120414 record the diagonal Ramsey data, the exactly known
diagonal values being `2, 6, 18`).

| `k` | `r(k)` | `r(k)^{1/k}` | gap `4 - r(k)^{1/k}` |
|-----|--------|--------------|----------------------|
| 2   | 2      | 1.4142       | **2.5858**           |
| 3   | 6      | 1.8171       | 2.1829               |
| 4   | 18     | 2.0598       | 1.9402               |
| 5   | 48     | 2.1689       | **1.8311**           |

The gaps are strictly decreasing, so the *smallest* small-case gap sits at the top of
the range (`k = 5`), not at `k = 2`.  The integer certificates actually used in Lean are
`2^3 < 6^2`, `6^4 < 18^3`, `18^5 < 48^4` (all verified: `8 < 36`, `1296 < 5832`,
`1889568 < 5308416`).  Consequently `min(ε₁, 4 - r(2)^{1/2})` can exceed the admissible
uniform constant; with `ε₁ = 2` it equals `2` and already fails at `k = 5`
(`48 > 2^5 = 32`).

## FD5 — unbounded base

Witness `R(s,t) = (s+t+1)^{s+t}`, `β(s,t) = (s+t)+2`, all pairs.  The additive gap holds
with `ε = 1` exactly.  Testing the proportional bound `R ≤ (qβ)^n`:

| `q`     | `n = 5` | `n = 20` | `n = 50` | `n = 500` | `1/(1-q)` |
|---------|---------|----------|----------|-----------|-----------|
| 0.9     | holds   | fails    | fails    | fails     | 10        |
| 0.99    | holds   | holds    | holds    | fails     | 100       |

So no fixed `q < 1` works, and the failure threshold matches the predicted `n ≳ 1/(1-q)`.
Formalized as `RamseyBounds.fd_not_hasProportionalSaving₂`.
