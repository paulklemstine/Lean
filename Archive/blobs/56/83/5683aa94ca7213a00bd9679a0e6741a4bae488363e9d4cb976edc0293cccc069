# Future Directions — The Discrete Heat Semigroup of Hodge Message Passing

## Synthesis

This cycle closed the conceptual loop opened by the spectral-depth / message-passing
work in `Catalog/Speculative/AutoResearch/HodgeMessagePassingConvergence.lean`. That file
established *geometric residual decay* `⟪Tᵏr, Tᵏr⟫ ≤ ρᵏ ⟪r, r⟫` for the gradient
message-passing layer `T = 1 − α·L` of a symmetric positive-semidefinite Hodge Laplacian
`L`. The new file
`Catalog/Speculative/AutoResearch/HodgeHeatSemigroupDissipation.lean`
upgrades that *convergence* picture to a full *dissipative semigroup* picture, proving four
new sorry-free theorems:

* `mpStep_semigroup` — depth is additive, `T^{j+k} = T^j ∘ T^k` (discrete analogue of
  `e^{-(s+t)L} = e^{-sL} e^{-tL}`);
* `mpStep_energy_antitone` — the residual energy is monotonically non-increasing in depth;
* `mpStep_energy_summable` + `mpStep_total_dissipation_bound` — the total dissipated energy
  over infinite depth is finite and bounded by `⟪r, r⟫ / (1 − ρ)`;
* `mpStep_tendsto_harmonic` — the depth-`k` output of `h + r` converges (in the energy
  sense) exactly to the harmonic/cohomology component `h`.

The decisive structural fact is that the spectral gap `1 − ρ` plays a *double* role: it is
both the convergence **rate** and the reciprocal of the **total dissipated energy**. This
mirrors the catalog's Fibonacci primitive-divisor theory, where a single arithmetic
invariant (the rank of apparition, `Catalog/Applications/RankOfApparition.lean`) governs an
entire divisibility lattice. The file is self-contained against Mathlib because the catalog's
`Speculative` import graph is currently fragmented: `HodgeMessagePassingConvergence.lean`
transitively imports a non-existent `HodgeSpectralThreshold.lean`, so the dissipation theory
restates the short `mpStep` core to stand on its own.

## Results Summary

| Theorem | Statement | Status |
|---|---|---|
| `mpStep_semigroup` | `T^{j+k} = T^j ∘ T^k` | proved, `sorry = 0` |
| `mpStep_energy_succ_le` / `mpStep_energy_antitone` | energy non-increasing in depth | proved, `sorry = 0` |
| `mpStep_energy_summable` | `∑ₖ ⟪Tᵏr, Tᵏr⟫` summable for `ρ < 1` | proved, `sorry = 0` |
| `mpStep_total_dissipation_bound` | `∑ₖ ⟪Tᵏr, Tᵏr⟫ ≤ ⟪r,r⟫/(1−ρ)` | proved, `sorry = 0` |
| `mpStep_tendsto_harmonic` | `Tᵏ(h+r) → h` in energy | proved, `sorry = 0` |

All main results use only `propext`, `Classical.choice`, `Quot.sound`.

## Research Directions

### 1. The total-dissipation bound is sharp exactly for single-mode residuals

Conjecture: `∑ₖ ⟪Tᵏr, Tᵏr⟫ = ⟪r,r⟫/(1−ρ)` (equality in `mpStep_total_dissipation_bound`)
holds **iff** the residual `r` is an eigenvector of `L` with `Lr = ((1−ρ)/α)·r`, i.e. the
per-layer contraction is tight at every depth. For a generic residual the inequality is
strict, with the deficit equal to the variance of the spectral measure of `r`.
The key insight is that equality in a geometric-series comparison forces *term-by-term*
equality `⟪Tᵏ⁺¹r⟫ = ρ⟪Tᵏr⟫`, which propagates the single-mode condition through every
depth — so sharpness is a spectral-rigidity statement, not an analytic accident.
Why now? The bound `mpStep_total_dissipation_bound` is already formalized with the exact
geometric majorant `⟪r,r⟫/(1−ρ)`, so its equality case is a self-contained next step that
needs only the eigenvector characterization of equality in `mul_le_mul`, with no new
infrastructure.

### 2. The depth-limit operator is the orthogonal projection onto cohomology

Conjecture: in finite dimensions, the iterates `Tᵏ` converge in operator norm to the
orthogonal projection `P` onto `ker L`, i.e. `‖Tᵏ − P‖ → 0`, and the limit is independent of
the step `α` within the contraction window `0 < α < 2/λ_max`. This strengthens
`mpStep_tendsto_harmonic` (which fixes an input split `h + r`) to a *uniform* statement over
all inputs. The key insight is that `T` is self-adjoint with spectrum in `[1−αλ_max, 1]`,
so `T = P + S` with `S` supported on `(ker L)ᗮ` and `‖S‖ ≤ ρ < 1`, whence `Tᵏ = P + Sᵏ`
and `‖Sᵏ‖ ≤ ρᵏ`. Why now? The energy-level convergence is already proved; promoting it to
operator convergence only requires the spectral decomposition of a finite-dimensional
self-adjoint operator, which Mathlib supports (`LinearMap.IsSymmetric.spectral theorem`).

### 3. Chebyshev-accelerated message passing converges at rate √ρ

Conjecture: replacing the single-step layer `T = 1 − αL` by the second-order recurrence
`xₖ₊₁ = ωₖ(xₖ − αLxₖ) + (1−ωₖ)xₖ₋₁` with Chebyshev coefficients `ωₖ` accelerates the
residual decay from `ρᵏ` to `O(k · ρ^{k/2})` — a quadratic speed-up in the spectral gap.
The key insight is that the residual after `k` accelerated steps is `pₖ(T)r` for a degree-`k`
Chebyshev polynomial `pₖ`, and `‖pₖ‖` on the spectral interval `[1−αλ_max, 1−αλ_min]` decays
like the Chebyshev minimax rate `√ρ`, not `ρ`. Why now? The dissipation file already isolates
the per-layer contraction factor `1 − αμ(2 − αλ)` and proves the spectral step is optimal;
the accelerated scheme is the natural sequel, and Mathlib has Chebyshev polynomials
(`Polynomial.Chebyshev`) to anchor the minimax estimate.

### 4. Carmichael's composite tail via the homogeneous-cyclotomic lower bound (Zsygmondy)

The only genuine open `sorry` in the catalog is the infinite tail of Carmichael's primitive
divisor theorem, `fib_carmichael_composite` for composite `n > 10000`
(`Catalog/Shared/CarmichaelProof.lean`); the entire `fib_carmichael` chain in
`Catalog/Speculative/AutoResearch/CarmichaelComposite.lean` and
`Catalog/Speculative/AutoResearch/FibPrimitive.lean` rests on it. Conjecture (the precise
target to formalize): the *primitive part* `Φ*(n) = ∏_{d ∣ n} F_d^{μ(n/d)}` satisfies
`Φ*(n) > n` for every `n ∉ {1,2,6,12}`, and the only prime that can divide `Φ*(n)` without
being primitive is the largest prime factor of `n`, contributing a factor at most `n`; hence
`Φ*(n) > 1` forces a primitive prime divisor. The key insight is the homogeneous-cyclotomic
identity `F_n = ∏_{d ∣ n} Φ_d(φ, ψ)` evaluated at the golden-ratio conjugates, giving the
lower bound `|Φ_n(φ,ψ)| ≥ (φ^{φ(n)})/(intrinsic factor)` that separates "primitive" from
"intrinsic" growth — exactly the Zsygmondy mechanism. Why now? The catalog has already
reduced the *entire* theorem to this single tail and verified it computationally up to
`50000` (`fib_primitive_le_50000`); building homogeneous cyclotomic evaluation and the
lifting-the-exponent bound (Mathlib's `padicValNat.pow_sub_pow` plus
`Polynomial.cyclotomic`) is the one missing brick that would make `fib_carmichael` fully
`sorry`-free.

### 5. A dissipation–apparition dictionary: spectral gap as an arithmetic "rank"

Conjecture: the rank-of-apparition machinery of
`Catalog/Applications/RankOfApparition.lean` and the heat-semigroup dissipation of this
cycle are two instances of one template — a monotone invariant on a graded poset (depth /
divisibility) whose minimal generator (spectral gap / entry point) controls a whole
sublattice of decay/divisibility classes. Concretely: for the cyclic-graph Hodge Laplacian
`L = I − (S + Sᵀ)/2` on `ℤ/Nℤ` (whose eigenvalues are `1 − cos(2πj/N)`), the contraction
factors `ρ_j` are indexed by the *same* residues `j` that index Fibonacci apparition modulo
`N`, and the smallest nonzero gap is realized at the residue generating the apparition
lattice. The key insight is that both objects are governed by the multiplicative order of a
root of unity (graph Fourier mode / Pisano period), so the spectral-gap optimum and the
entry-point minimum are the same extremal problem in two languages. Why now? Both halves now
exist in the catalog as fully `sorry`-free theories (`RankOfApparition`,
`HodgeHeatSemigroupDissipation`), so a concrete cyclic-graph bridge theorem can be stated and
tested directly, falsifiable by a single mismatched eigenvalue/residue computation.
