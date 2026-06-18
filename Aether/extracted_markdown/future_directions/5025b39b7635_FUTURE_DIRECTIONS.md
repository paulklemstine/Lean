# Future Directions — Chaos as a Computable Shadow

## Synthesis

`Catalog/Geometry/ShadowingLemma.lean` establishes a complete, axiom-clean,
quantitative shadowing theory for **Lipschitz maps** on an arbitrary
pseudometric space. The backbone is a single affine error recursion,
`eₙ₊₁ ≤ δ + L·eₙ` with `e₀ = 0`, solved in closed form to
`eₙ ≤ δ · Σ_{k<n} Lᵏ`. From this we derive:

- a uniform (all-time) shadow `δ/(1-L)` for contractions (`L < 1`),
- the textbook ε–δ shadowing lemma with the explicit *linear* modulus
  `δ = ε·(1-L)`,
- a sharpness theorem proving the geometric bound is attained with equality on
  `ℝ` by `t ↦ L·t`, and
- a capstone interpreting floating-point round-off as an automatically shadowed
  pseudo-orbit.

The work is deliberately adversarial: the sharpness theorem marks the exact
frontier where the *easy* (forward, contracting) theory dies. For `L ≥ 1` the
bound `δ·Σ Lᵏ` diverges, so the forward orbit through the first computed point is
useless as a shadow — which is precisely why the genuine hyperbolic shadowing
lemma must solve a global/backward problem. This connects to the
discrete-induction methodology already in `Geometry/Convergence.lean`, recasting
its Lyapunov-energy recursion as an error recursion.

## Results Summary

| Theorem | Statement |
|---|---|
| `pseudoOrbit_error_bound` | `dist (xₙ) (f^[n] x₀) ≤ δ · Σ_{k<n} Lᵏ` for `L`-Lipschitz `f` |
| `contraction_uniform_shadow` | `L < 1 ⇒ dist (xₙ) (f^[n] x₀) ≤ δ/(1-L)` for all `n` |
| `shadowing_lemma_contraction` | `∀ ε>0 ∃ δ>0`, every `δ`-pseudo-orbit is `ε`-shadowed |
| `error_bound_sharp` | The bound is attained with equality by `t ↦ L·t` on `ℝ` |
| `floatingPoint_is_shadowed` | Round-off computation of a contraction is shadowed |

## Research Directions

### 1. The expanding fixed-point shadow: turning sharpness into a positive theorem
The sharpness example `xₙ = δ·Σ_{k<n} Lᵏ` for `f(t) = L·t` looks like a failure
when `L > 1` — the forward orbit through `x₀ = 0` runs away. But choosing
`y₀ = δ/(L-1)` gives `f^[n] y₀ = Lⁿ·δ/(L-1)`, and a direct computation shows
`|xₙ - f^[n] y₀| = δ/(L-1)` for **all** `n`. The conjecture: every linear (and,
more generally, affinely hyperbolic) map admits a *bounded* shadow even in the
expanding regime, with modulus `δ/(L-1)`.
**The key insight is** that shadowing for expanding maps is solved not by
iterating forward but by selecting the unique initial condition whose entire
future cancels the accumulated push — a fixed-point/backward equation rather
than a recursion. **Why now?** The forward machinery is already formalized and
axiom-clean; the expanding case is the *same algebra read backward*, so it is the
cheapest possible extension that crosses the contraction barrier, and it is
falsifiable by a one-line `ℝ` computation if the modulus is wrong.

### 2. Hyperbolic splitting: shadowing for `L = L_s ⊕ L_u` saddle maps
Generalize from pure contraction/expansion to a product space `E_s × E_u` where
`f` contracts the stable factor (`L_s < 1`) and expands the unstable factor
(`L_u > 1`). Conjecture: every `δ`-pseudo-orbit is `ε`-shadowed with
`ε = δ·max(1/(1-L_s), 1/(L_u-1))`, by combining the forward shadow on `E_s` with
the backward shadow from Direction 1 on `E_u`.
**The key insight is** that hyperbolic shadowing factors as a *direct sum* of two
already-proven one-dimensional shadows — stability handled forward, instability
handled backward. **Why now?** Both summands are reducible to lemmas in the
current file (`contraction_uniform_shadow` and the Direction-1 dual), so the
hyperbolic case becomes assembly rather than new analysis, and the explicit
constant makes it falsifiable on `ℝ²`.

### 3. Finite-window shadowing and the polynomial shadowing-time conjecture
The current results are infinite-horizon for contractions. For general Lipschitz
`L` and a *finite* window of length `N`, the forward bound gives
`ε(N) = δ·(Lᴺ-1)/(L-1)`. Conjecture: to shadow `N` steps to accuracy `ε` it
suffices to take `δ = ε·(L-1)/(Lᴺ-1)`, i.e. the shadowing time `N(ε,δ)` grows
only **logarithmically** in `1/δ` (not polynomially, as the original concept
guessed) for fixed expansion `L`.
**The key insight is** that the much-cited "polynomial shadowing time" is, for
uniformly Lipschitz maps, actually a *logarithmic* law `N ≈ log(1/δ)/log L`,
because error accumulates geometrically, not algebraically. **Why now?** The
closed-form `δ·Σ Lᵏ` is already a theorem, so inverting it for `δ(N,ε)` is pure
algebra, and the logarithmic-vs-polynomial claim is sharply falsifiable.

### 4. From Lipschitz to mean-Lipschitz: shadowing under non-uniform expansion
Replace the global constant `L` with step-dependent constants `Lₙ`
(`dist (f a) (f b) ≤ Lₙ · dist a b` along the orbit). The error recursion becomes
`eₙ₊₁ ≤ δ + Lₙ·eₙ`, whose solution is `eₙ ≤ δ·Σ_{k<n} Π_{k<j<n} Lⱼ`. Conjecture:
a pseudo-orbit is uniformly shadowed whenever the *Lyapunov-type* average
`limsup (1/n)·Σ log Lₖ < 0`, even if individual `Lₖ > 1`.
**The key insight is** that shadowing is governed by the *geometric mean* of the
local expansion rates, not their pointwise size — transient expansion is
forgiven as long as the orbit is contracting on average. **Why now?** The
inductive proof of `pseudoOrbit_error_bound` never uses constancy of `L`; it
generalizes verbatim to the product form, making this a low-risk, high-yield
bridge toward non-uniformly hyperbolic (Pesin-theoretic) shadowing.

### 5. The logistic map: certified shadowing on an invariant subinterval
Specialize to the headline example `f(x) = 4x(1-x)`. It is *not* globally
Lipschitz with constant `< 1`, but it is Lipschitz with an explicit local
constant on subintervals away from the critical point `x = 1/2`. Conjecture: on
any forward-invariant compact set bounded away from `1/2`, the logistic map
satisfies a quantitative shadowing estimate with a *computable* constant, and
hence every double-precision orbit avoiding a neighborhood of `1/2` is shadowed
to within `≈ 10⁻¹⁰` at machine epsilon `≈ 10⁻¹⁶`.
**The key insight is** that the only obstruction to shadowing the logistic map is
the critical point; everywhere else the map is effectively hyperbolic and the
general theory applies with an honest, machine-checkable Lipschitz constant.
**Why now?** With the abstract Lipschitz shadowing theorems in hand, the logistic
case reduces to bounding `|f'(x)| = |4 - 8x|` on an explicit interval — a
`norm_num`/`interval_cases`-style computation that is directly falsifiable
against a numerical experiment.
