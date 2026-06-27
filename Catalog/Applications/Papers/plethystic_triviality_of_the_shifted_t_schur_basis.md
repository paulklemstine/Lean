# Computational Evidence — Plethystic Triviality of the Shifted t-Schur Basis

All objects live in `Lam = MvPolynomial ℕ K`, `K = ℚ(t)`, with `X k = p_{2k+1}` the
`(2k+1)`-st odd power sum, `t = RatFunc.X`, and `cc k = 1 - t^{2k+1}`.

The plethysm is `φ_t : p_{2k+1} ↦ (1 - t^{2k+1}) p_{2k+1}`.

## 1. Small-case one-row functions `q_n = Q_{(n)}`

Using the Newton recursion `n q_n = ∑_k 2 p_{2k+1} q_{n-1-2k}` (definition `qGen`/`q`):

| n | q_n                       |
|---|---------------------------|
| 0 | `1`                       |
| 1 | `2 p_1`        (`= 2 X 0`)|
| 2 | `2 p_1^2`      (`= 2 X 0^2`) |

`q_1 = 2 X 0` is verified as the Lean theorem `Qfun_singleton : Qfun [1] = C 2 * X 0`.

## 2. Direct verification of `S^t_λ = φ_t(Q_λ)` (the falsifiability test)

The claim is "falsifiable by coefficient comparison in the finite odd power-sum ring of
degree at most |λ|". We realize this test as compiled Lean theorems.

* `λ = (1)` (degree 1):
  * `Q_{(1)} = 2 p_1`            — theorem `Qfun_singleton`
  * `S^t_{(1)} = 2(1 - t) p_1`   — theorem `Sfun_singleton` (`= C (2 * cc 0) * X 0`)
  * `φ_t(Q_{(1)}) = 2(1 - t) p_1` since `φ_t(p_1) = (1 - t) p_1`.
  * **Match.** Coefficient comparison: the `p_1`-coefficient transforms `2 ↦ 2(1-t)`,
    exactly multiplication by `cc 0 = 1 - t`.

* General `λ` (all degrees): rather than checking finitely many cases, the identity is
  proved for **every** list of parts by `Sfun_eq_phiT_Qfun`, via the operator
  intertwining `Bt_phiT : Bt n (φ_t f) = φ_t (B n f)`. No counterexample exists.

## 3. Counterexample hunt

Searched for a strict partition `λ` with `S^t_λ ≠ φ_t(Q_λ)`: none can exist, because the
identity is an algebraic consequence of `Bt_phiT` (annihilation chain rule + creation
intertwining `qt = φ_t ∘ q`) for arbitrary `λ`. The only way to break triviality is to
break invertibility of `φ_t`, i.e. to work over a ring where some `1 - t^{n}` vanishes
(e.g. `t` a root of unity); over `K = ℚ(t)` this never happens (`cc_ne`).

## 4. Diagonal/scaling structure (operator evidence)

`φ_t` is diagonal in the monomial basis: `φ_t(p_n^m) = (1 - t^n)^m p_n^m`
(theorem `phiT_monomial_pow`). Hence a monomial `p_{n_1}^{a_1} ⋯ p_{n_r}^{a_r}` is scaled
by `∏ (1 - t^{n_i})^{a_i}` and never moved to a different degree
(theorem `phiT_isHomogeneous`). This is the operator-level explanation of why the
deformation is a pure rescaling of the Schur-`Q` basis.

## 5. OEIS

No distinguished integer sequence is forced by the rational-function coefficients here
(the data are polynomials in `t`), so an OEIS lookup is not informative for this claim.
The leading rational coefficients `q_n = 2 p_1^n / ...` reflect the `Q_{(n)}`
normalization rather than a combinatorial counting sequence.
