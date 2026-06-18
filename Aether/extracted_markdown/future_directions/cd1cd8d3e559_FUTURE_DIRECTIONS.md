# Future Directions — Universal `Θ(1/gap)` Scaling of Minimal PDE Solvers

## Synthesis

`Novelty/SpectralGapScaling.lean` turns the informal conjecture *"the cost of a minimal
neural/iterative PDE solver blows up as the operator spectrum closes its gap"* into a
fully proven, two-sided complexity law. Modeling an SPD discretized solution operator by
its extremal eigenvalues `g ≤ L` (with the spectral gap to zero being `g`, closing as the
control parameter `λ → λc`), the optimally damped Richardson / steepest-descent iteration
contracts the error per step by `rho L g = (L-g)/(L+g)`. We proved:

* the exact gap law `1 - rho = 2g/(L+g)` (deficit linear in the gap);
* the conditioning identity `rho = (κ-1)/(κ+1)`, `κ = L/g`;
* a **sufficiency** bound `iter_upper`: `n ≥ (L+g)/(2g)·log(1/ε)` iterations reach error `ε`;
* a **necessity** bound `iter_lower`: any `n` reaching error `ε` obeys `n ≥ (L-g)/(2g)·log(1/ε)`;
* a concrete blow-up `cond_blowup`: `L/λ → +∞` as the gap `λ → 0⁺`.

Together the two bounds sandwich the iteration count at `Θ((1/g)·log(1/ε))`: the cost of a
minimal solver diverges **exactly like the reciprocal of the gap** — the "universal scaling
at operator-spectrum closing" of the title, now a theorem rather than a heuristic. The
single engine is the two-sided logarithm inequality `1 - 1/x ≤ log x ≤ x - 1`, used in one
direction for the upper bound and in the other for the lower bound.

## Results Summary

| Theorem | Statement | Role |
|---|---|---|
| `one_sub_rho` | `1 - rho = 2g/(L+g)` | exact gap law |
| `rho_eq_cond` | `rho = (κ-1)/(κ+1)` | conditioning link |
| `iter_upper` | gap → `O((1/g)log(1/ε))` iterations suffice | upper frontier |
| `iter_lower` | gap → `Ω((1/g)log(1/ε))` iterations necessary | lower frontier (tight) |
| `cond_blowup` | `L/λ → +∞` as `λ → 0⁺` | concrete closing |

## Research Directions

### 1. Krylov / conjugate-gradient acceleration changes the exponent to `1/√g`

The Richardson bound is `Θ(1/g)`. Conjugate gradients should instead give
`Θ(1/√g · log(1/ε))`, because the relevant contraction is governed by `√κ` via Chebyshev
polynomials, not `κ`. **Conjecture:** there is a polynomial `p` of degree `n` with `p(0)=1`
and `sup_{[g,L]} |p| ≤ 2·((√κ-1)/(√κ+1))^n`, yielding iteration count
`n = Θ((√L/√g)·log(1/ε))`. *The key insight is* that the optimal residual polynomial for
the whole spectral interval is the scaled-and-shifted Chebyshev polynomial, whose extremal
growth depends on `√κ` rather than `κ`, so the gap penalty is square-rooted. *Why now?* The
present file already isolates "contraction factor ⇒ iteration count" as a clean log-based
lemma; replacing `rho` by the Chebyshev minimax value reuses that exact scaffold, and
Mathlib now has enough Chebyshev-polynomial API to attempt the minimax bound.

### 2. Preconditioning collapses the scaling to `Θ(log(1/ε))`

A spectrally equivalent preconditioner `M` with `c·M ⪯ A ⪯ C·M` (constants independent of
`λ`) makes the preconditioned operator's gap bounded below, so iteration count becomes
`Θ(log(1/ε))` — gap-independent. **Conjecture:** if `g_M ≥ c > 0` uniformly in `λ`, then
`iter_upper` applied to the preconditioned spectrum gives a bound with **no** `1/g` factor.
*The key insight is* that preconditioning does not shrink the true gap but replaces the
effective `κ` by the constant `C/c`, which the `iter_upper` lemma consumes verbatim. *Why
now?* `iter_upper`/`iter_lower` are stated purely in terms of abstract `(L,g)`, so a
"uniform spectral equivalence" hypothesis can be bolted on as a separate lemma feeding the
existing bound — a low-risk formalization that demonstrates the practical escape from the
blow-up.

### 3. Weakly nonlinear operators: the gap law survives to first order

For a weakly nonlinear elliptic operator `A(u) = A₀ + ε·N(u)`, Newton's method solves a
sequence of linearized SPD systems whose gaps perturb by `O(ε)` from `A₀`'s gap. **Conjecture
(falsifiable):** the per-Newton-step inner iteration count is
`Θ((1/(g₀ - O(ε)))·log(1/tol))`, and the bound degrades *continuously* (no discontinuity)
until `ε` is large enough to close `g₀`. *The key insight is* that Weyl's eigenvalue
perturbation bound `|λ_k(A) - λ_k(B)| ≤ ‖A-B‖` keeps the gap Lipschitz in the nonlinearity
strength, so the linear scaling law transfers with a perturbed gap. *Why now?* Mathlib has
the Hermitian eigenvalue/`Min-Max` machinery needed for the Weyl bound, and our scaling law
is the exact downstream consumer — pairing them closes the linear-to-nonlinear bridge.

### 4. Tightness of the constant: the `(L+g)` vs `(L-g)` gap is unavoidable

Our upper and lower constants differ by the denominators `(L+g)` and `(L-g)`. **Conjecture:**
neither denominator can be improved to the geometric mean `√(L²-g²)` using only the
log-convexity inequality; the true asymptotic constant is `1/2` (both bounds → `(1/2g)L·log`
as `g→0`), and the higher-order term is `±g²/(3L²)`. *The key insight is* that the exact
`-log rho = log((L+g)/(L-g)) = 2·artanh(g/L)` has a Taylor series `2(x + x³/3 + …)`, so the
two surrogate bounds are the first under- and over-estimates of the same `artanh`. *Why now?*
This is a pure-analysis sharpening directly atop `one_sub_rho`; formalizing `artanh`'s series
would convert the current `Θ` into an asymptotic equality with explicit error term.

### 5. Spectral-gap closing rate ↔ critical exponent of the control parameter

If the gap closes algebraically, `g(λ) ∼ c·(λc - λ)^β` near the critical parameter, then
solver cost scales as `(λc-λ)^{-β}·log(1/ε)`. **Conjecture (falsifiable):** the observable
"iterations vs `(λc-λ)`" on log-log axes has slope exactly `-β`, giving a *measurable*
critical exponent of the discretized PDE family. *The key insight is* that composing
`cond_blowup`'s `1/g` divergence with a power-law gap-closing model converts a spectral
property of the operator into a power law in the *physical* control parameter, which is what
an experimentalist actually varies. *Why now?* `cond_blowup` already provides the `1/g`
limit as a Mathlib `Tendsto`; substituting `g = c·(λc-λ)^β` and chaining tendsto lemmas
yields the critical-exponent statement with little new machinery, making it an immediate,
testable next step.
