# Future Directions — Entropy Power Inequality, Sharp Version

## Synthesis

This cycle isolated the *algebraic skeleton* of the Entropy Power Inequality (EPI)
and proved it from first principles, with no measure theory. The central object is
the `EntropySystem`: an abstract family of "laws of random vectors" carrying a
differential entropy `H`, a convolution `conv`, and a dilation action `scale`,
subject only to the **dilation law** `H(a•X) = H(X) + n·log a` (plus the two action
axioms `scale 1 = id`, `scale a ∘ scale b = scale (ab)`).

From these three axioms alone we proved the **Dembo–Cover–Thomas / Lieb equivalence**
(`EntropySystem.sumForm_iff_concaveForm`) between the two textbook forms of the EPI:

* **Sum form**: `N(X) + N(Y) ≤ N(X+Y)`, the superadditivity of the entropy power
  `N(X) = exp(2H(X)/n)`;
* **Concavity form**: `t·H(X) + (1-t)·H(Y) ≤ H(√t X + √(1-t) Y)`, the concavity of
  entropy along the Gaussian interpolation.

The forward direction is weighted AM–GM; the reverse direction is the *optimal
interpolation* `t = N(X)/(N(X)+N(Y))`, at which the concavity bound collapses to the
exact log-identity `log(N(X)+N(Y))`. We then instantiated the framework with the
one-dimensional centered Gaussians (`gaussSystem`), proving the **equality case**:
`N(X+Y) = N(X) + N(Y)` exactly (`gaussian_epi_equality`), recovering the textbook
identity `N(Gaussian) = σ²` (`gaussian_normalizedPower`), and deriving the concavity
form for Gaussians *for free* through the abstract equivalence
(`gaussSystem_concaveForm`).

## Results Summary

| Result | File | Statement |
|---|---|---|
| `EntropySystem.N_scale` | Core | entropy power scales as `a²` under dilation |
| `EntropySystem.concave_of_sum` | Core | sum form ⟹ concavity form (weighted AM–GM) |
| `EntropySystem.sum_of_concave` | Core | concavity form ⟹ sum form (optimal `t`) |
| `EntropySystem.sumForm_iff_concaveForm` | Core | the full EPI equivalence |
| `gaussSystem` | Gaussian | the Gaussian model of `EntropySystem` |
| `gaussian_normalizedPower` | Gaussian | `(2πe)⁻¹·N = σ²` |
| `gaussian_epi_equality` | Gaussian | EPI holds with equality for Gaussians |
| `gaussSystem_concaveForm` | Gaussian | concavity form for Gaussians via the equivalence |

All results are axiom-clean (`propext`, `Classical.choice`, `Quot.sound` only).

## Research Directions

### 1. Uniqueness of the Gaussian extremizer (rigidity)

We proved that Gaussians *achieve* equality in the sum form. The converse — that they
are the *only* extremizers — is the rigidity statement: in a system enriched with a
suitable "non-degeneracy" predicate, `N(X+Y) = N(X) + N(Y)` should force `X` and `Y`
to be dilated copies of a common Gaussian. The key insight is that equality in the
abstract proof forces equality in the single weighted AM–GM step, and AM–GM is an
equality exactly when its two arguments coincide — so rigidity of the EPI reduces to
rigidity of AM–GM applied to `N(X)` and `N(Y)`. **Why now?** The equality case is
already formalized as `gaussian_epi_equality`; turning the inequality proof's unique
AM–GM bottleneck into an iff is a self-contained next step that needs no new analysis.

### 2. A quantitative *stability* EPI

Stability asks: if `N(X+Y) ≤ N(X) + N(Y) + ε`, how close must `(X,Y)` be to a
Gaussian pair? In the abstract framework this becomes a *deficit* inequality: define
`δ(X,Y) = N(X+Y) - N(X) - N(Y) ≥ 0`, and bound the gap in the internal AM–GM step
`t·N(X) + (1-t)·N(Y) - N(X)^t N(Y)^{1-t}` from below by a modulus of the ratio
`N(X)/N(Y)`. The key insight is that the entire EPI deficit is controlled by a single
scalar AM–GM deficit, which has an explicit quadratic lower bound near the diagonal
(`p - q`)². **Why now?** Mathlib already carries `Real.add_pow_le_pow_mul_pow_of_sq_le`
and `inner_le_nnorm`-style stability lemmas; the scalar deficit bound is the only
missing ingredient and is elementary.

### 3. The Brunn–Minkowski bridge as a sibling `SizeSystem`

The EPI and Brunn–Minkowski (`vol(A+B)^{1/n} ≥ vol(A)^{1/n} + vol(B)^{1/n}`) share
the same skeleton: a functional that scales as a power of the dilation and is
superadditive under a Minkowski-type sum. Abstract a `SizeSystem` with scaling
`S(a•A) = a^k S(A)` and prove that the `1/k`-power superadditivity of `S` is
equivalent to a Prékopa–Leindler-style concavity form — *exactly* the proof we gave,
with the exponent `2` replaced by `k`. The key insight is that EPI (`k = 2` on
entropy power) and Brunn–Minkowski (`k = n` on volume) are the **same theorem at two
exponents**, both consequences of weighted AM–GM plus a dilation law. **Why now?**
The `Core` proof never used `2` essentially — generalizing the exponent is a
mechanical refactor that immediately yields a unified EPI/BM statement.

### 4. Multi-variable / `n`-fold superadditivity and the entropy-power "simplex"

Generalize from two summands to `m`: `N(X₁ + … + X_m) ≥ Σ N(X_i)`, and more sharply
the *fractional* EPI `N(Σ X_i) ≥ Σ_{S} c_S N(Σ_{i∈S} X_i)` for fractional packings
`c_S`. The key insight is that the two-variable equivalence iterates: associativity of
`conv` plus the proven base case yields the `m`-fold bound by induction, and the
optimal interpolation weights become barycentric coordinates on the simplex. **Why
now?** The associativity hook is already a field of `EntropySystem` away (`conv` only
needs an added `conv_assoc` axiom), and the Gaussian instance satisfies it trivially,
giving an immediate sanity model.

### 5. Fisher information and the de Bruijn identity as the *derivative* of the EPI

The EPI is the integrated form of the Fisher-information inequality
`1/I(X+Y) ≥ 1/I(X) + 1/I(Y)` via the de Bruijn identity `d/dt h(X + √t Z) = ½ I(X_t)`.
Introduce an abstract `HeatFlow` on an `EntropySystem` — a one-parameter family
`flow t X` with `flow`-derivative of `H` equal to a "Fisher" functional `I` — and
prove that concavity of `H` along the flow (which our `ConcaveForm` is the secant
version of) is equivalent to the reciprocal-superadditivity of `I`. The key insight is
that `ConcaveForm` is precisely the chord inequality whose tangent limit is the Fisher
EPI, so the two are linked by one mean-value argument. **Why now?** With the secant
(concavity) form already proven, the tangent form is one differentiation away, and it
opens the door to the *monotonicity of entropy along the CLT*, the deepest payoff of
this circle of ideas.
