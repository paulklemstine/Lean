# Future Directions — Diophantine Approximation on ReLU Networks

Derived from the verified results in `RationalClosure.lean` and `LeibnizRate.lean`:

* **Rational closure / impossibility** (`reluNet_ne_pi`): a one-hidden-layer
  `reluNet` with rational parameters at a rational input outputs a rational, so
  it can *never equal* `π`.
* **Leibniz rate** (`leibniz_error`, `leibniz_error_lower`): the partial sums
  obey `2/((2n+1)(2n+3)) ≤ |π/4 − Lₙ| ≤ 1/(2n+1)` — convergence is **polynomial**,
  bracketed between `Θ(1/n²)` and `Θ(1/n)`.
* **Synthesis** (`exists_rational_reluNet_near_pi`): for every `ε>0` there is a
  rational network `f` with `0 < |f(1) − π| < ε` — arbitrarily close, never exact.

The cycle *falsified* the mission conjecture that the Leibniz route gives
`O(log log(1/ε))` depth / exponentially fast convergence: the lower bound makes
that impossible for Leibniz. The conjectures below are the natural next probes.

---

### Conjecture 1 — Best-rational-approximation lower bound for depth-`L` width-`w` nets
For a ReLU network with rational parameters of total bit-complexity `B`, the
output at a rational input is a rational of denominator `≤ 2^{O(B)}`; hence
`|f(1) − π| ≥ c · 2^{−O(B)}` by the (effective) irrationality measure of `π`.
So the achievable accuracy is `ε = 2^{−Θ(parameters)}`, i.e. **error decays at
most exponentially in the parameter bit-budget, never faster.**

- **The key insight is** that exactness is blocked not by expressivity but by a
  *number-theoretic* obstruction: rational nets live in `ℚ`, and `π`'s finite
  irrationality measure converts "denominator size" directly into an accuracy
  floor — Diophantine approximation, not approximation theory, sets the limit.
- **Why now?** `RatPt.reluNet` already certifies the rationality of the output;
  pairing it with Mathlib's growing `Irrational`/`Liouville` API (irrationality
  measures) makes the quantitative denominator bound formalizable today.

### Conjecture 2 — Machin-type acceleration beats Leibniz exponentially
Replacing Leibniz by a Machin-type identity (e.g. `π/4 = 4·arctan(1/5) −
arctan(1/239)`) yields rational partial sums with error `Θ(ρ^{−n})` for some
`ρ>1`, so accuracy `ε` needs only `n = O(log(1/ε))` terms — **a rational ReLU
net of `O(log(1/ε))` size suffices**, restoring (for size, not naive depth) the
logarithmic scaling the Leibniz route provably cannot achieve.

- **The key insight is** that the polynomial wall in `leibniz_error_lower` is an
  artifact of the *slowly shrinking terms* `1/(2n+1)`; geometric `arctan` series
  shrink like `5^{−2n}`, decoupling "how many terms" from "how slow each term".
- **Why now?** Mathlib has `Real.arctan` and its power-series tools; the
  alternating-series bracketing lemmas reused here apply verbatim to the
  `arctan(1/m)` series, so the upgraded rate is within reach.

### Conjecture 3 — `e` and `√2` separate from `π` by representation class
`√2` is an *algebraic* irrational of degree 2, so it admits rational nets with
error `Θ(2^{−Θ(parameters)})` *and* a clean continued-fraction construction;
`e` and `π` are transcendental, with `e` enjoying the *fastest* rational rate of
the three (factorial series, super-exponential per term). Conjecture: the optimal
rational-net size for accuracy `ε` is `Θ(log(1/ε)/log log(1/ε))` for `e`,
`Θ(log(1/ε))` for `√2`, and `Θ(log(1/ε))` for `π` via Machin — **a strict
hierarchy `e ≺ {√2, π}` in network size.**

- **The key insight is** that the right complexity measure for a constant is the
  growth rate of the *denominators of its best rational series*, not its
  algebraic/transcendental status — `e` beats algebraic `√2` despite being
  transcendental.
- **Why now?** All three series (factorial for `e`, CF for `√2`, Machin for `π`)
  are alternating/positive series whose partial sums are `RatPt`, so the exact
  same `RatPt.reluNet` + bracketing toolkit transfers across constants.

### Conjecture 4 — Depth genuinely helps only via Horner/iterated composition
A depth-`L` ReLU net can evaluate a degree-`2^L` polynomial by repeated squaring,
so it can realize a partial sum of `N = 2^{Θ(L)}` series terms with width `O(1)`.
Conjecture: **for the Machin series, depth-`L` width-`O(1)` rational nets reach
accuracy `ε = 2^{−2^{Θ(L)}}`, i.e. `L = Θ(log log(1/ε))` depth suffices** — the
*only* regime in which the mission's `log log` prediction is actually correct,
and only because composition (not addition) is doing the work.

- **The key insight is** that addition of `N` terms costs width `Θ(N)` but
  *composition* costs only depth `Θ(log N)`; the conjectured `log log` depth is
  real for the multiplicative/Horner encoding and false for the additive one
  studied here (`reluNet` with `n=0` is purely additive).
- **Why now?** The catalog's `MachineLearning.ReLUDepthWidth` line already
  formalizes depth-driven oscillation counts (`tent^[k]`, `2^k` crossings); the
  same iterated-composition machinery is exactly what a Horner evaluator needs.

### Conjecture 5 — A Liouville-style "hardest constant" for ReLU nets
There exists a transcendental `α ∈ (3,4)` (a Liouville-type number) for which
*every* rational ReLU net of parameter-budget `B` has `|f(1) − α| ≥ 2^{−2^{o(B)}}`
**but** a tailored net hits `|f(1) − α| ≤ 2^{−2^{Ω(B)}}`: the achievable rate is
doubly-exponential in `B`, dramatically faster than for `π`. Conjecture: the
optimal ReLU approximation rate of a constant is governed precisely by its
irrationality measure.

- **The key insight is** that Liouville numbers are *defined* by extremely good
  rational approximations, so they are paradoxically the *easiest* targets for
  rational nets — inverting the intuition that "more transcendental = harder".
- **Why now?** Mathlib formalizes `Liouville` numbers and their approximation
  property; combined with `RatPt.reluNet` this gives a direct route to a
  separation theorem between `π` and a Liouville constant.
