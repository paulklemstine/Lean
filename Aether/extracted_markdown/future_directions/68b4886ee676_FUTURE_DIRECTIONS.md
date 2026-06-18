# Future Directions — Hodge–Laplacian Message Passing as a Discrete Heat Semigroup

## Synthesis

This cycle closes the conceptual loop opened by the two preceding Hodge cycles in the
catalog. `HodgeSpectralThreshold.lean` showed that the up/down Hodge Laplacian
`Δ = up + down` partitions cochain space into a depth-invariant *harmonic*
(cohomology) block — characterized intrinsically by `ker_hodgeLaplacian`
(`ker Δ = ker up ⊓ ker down`) — and a geometrically suppressed *non-harmonic* block.
`HodgeMessagePassingConvergence.lean` sharpened "suppression" into a genuine
contraction estimate `⟪Tᵏr, Tᵏr⟫ ≤ ρᵏ⟪r,r⟫` (`mpStep_iterate_contraction`), with an
optimal spectral step `α = 1/λ` and rate `1 − μ/λ` (`contraction_factor_at_optimal`,
`contraction_factor_optimal`).

The new file `HodgeHeatSemigroup.lean` recognizes that all of this is the behaviour of
a single object: the linearized layer `T = 1 − t·Δ` is **exactly the explicit Euler
step of the heat flow `∂x/∂t = −Δx`**. Once `T` is viewed as an element of the monoid
`Module.End ℝ E`, the three defining axioms of a (discrete) heat semigroup fall out by
*composing* the parent cycles rather than re-deriving anything:

* **Semigroup law** (`depthMap_semigroup`): `T^(a+b) = T^a ∘ T^b` — the algebraic
  shadow of `e^{−(a+b)Δ} = e^{−aΔ}e^{−bΔ}`. Depth is one-parameter discrete time.
* **Lyapunov dissipation** (`mpStep_energy_nonincreasing`): the Dirichlet energy
  `⟪x,x⟫` never increases under a normalized layer (the `μ = 0` reading of the
  contraction bound). The flow is non-expansive.
* **Optimal spectral rate** (`mpStep_optimal_rate`): at the spectral step `α = 1/λ`
  the residual energy decays as `(1 − μ/λ)ᵏ`, the cleanest possible rate.
* **Convergence to cohomology** (`mpStep_tendsto_harmonic`): the depth-`k` output of a
  harmonic-plus-residual input converges *in the norm topology* of `E` to its harmonic
  component. The steady state of the flow **is** the harmonic part.

A bridge lemma `hodge_heat_semigroup_fixed` records that harmonic cochains (closed and
coclosed, via the catalog's `harmonic_iff`) are the exact fixed points of every layer
at every depth — the `t → ∞` invariants of the semigroup are precisely discrete
cohomology.

## Results Summary

| Theorem | Statement | Built from |
|---|---|---|
| `depthMap_semigroup` | `T^(a+b) = T^a ∘ₗ T^b` | `depthMap`, `pow_add` |
| `mpStep_energy_nonincreasing` | `⟪Tx,Tx⟫ ≤ ⟪x,x⟫` (normalized step) | `mpStep_contraction` at `μ=0` |
| `mpStep_optimal_rate` | `⟪Tᵏr,Tᵏr⟫ ≤ (1−μ/λ)ᵏ⟪r,r⟫` at `α=1/λ` | `contraction_factor_at_optimal`, `mpStep_iterate_contraction` |
| `mpStep_tendsto_harmonic` | `Tᵏ(h+r) → h` in norm | `mpStep_dist_to_harmonic_bound`, squeeze |
| `hodge_heat_semigroup_fixed` | harmonic ⇒ `Tᵏ x = x` | `harmonic_iff`, `mpStep_iterate_harmonic_fixed` |

All five are proved sorry-free and depend only on `propext`, `Classical.choice`,
`Quot.sound`. The unifying observation — *deep Hodge message passing is a contracting
discrete heat semigroup whose unique steady state on each input is its cohomology
part* — is now fully formal.

## Research Directions

### 1. The exact steady-state operator is the orthogonal harmonic projection

The convergence theorem `mpStep_tendsto_harmonic` shows `Tᵏ(h+r) → h`, but it takes the
splitting `x = h + r` (`L h = 0`) as *given*. The natural completion is to prove that on
a finite-dimensional (or complete) inner-product space the limit map `x ↦ lim Tᵏ x`
exists for *every* `x` and **equals the orthogonal projection `orthogonalProjection
(ker L)`**. The key insight is that `mpStep_energy_nonincreasing` already makes `T` a
non-expansive self-adjoint operator, so its powers form a bounded family that is the
identity on the harmonic block (eigenvalue `1`) and a strict contraction on every other
spectral block; hence the limit is the spectral projector onto eigenvalue `1`, which is
exactly `orthogonalProjection (ker L)`. Why now? The catalog already supplies the
harmonic characterization `ker_hodgeLaplacian` and the per-block contraction, and
Mathlib's `orthogonalProjection` together with
`Submodule.isCompl_orthogonal_of_completeSpace` close the remaining gap — turning the
"steady state = projection" slogan into a theorem rather than a heuristic.

### 2. Energy is *strictly* monotone off the harmonic block (a discrete Łojasiewicz bound)

`mpStep_energy_nonincreasing` gives `⟪Tx,Tx⟫ ≤ ⟪x,x⟫`; the falsifiable strengthening is a
**strict, quantitative** drop: if `x ⟂ ker L` and `μ` is the spectral gap, then
`⟪x,x⟫ − ⟪Tx,Tx⟫ ≥ c·⟪x,x⟫` for an explicit `c = αμ(2 − αλ) > 0`. The key insight is that
the contraction factor `1 − αμ(2 − αλ)` from `mpStep_contraction` is *already* the right
Lyapunov decrement — it only needs to be re-read as a coercivity (gradient-domination)
inequality on the orthogonal complement, the discrete analogue of a Łojasiewicz–Polyak
inequality for the Dirichlet energy. Why now? Coercivity is the single missing ingredient
that upgrades the qualitative `Tendsto` of Direction 1 into an *exponential* convergence-
rate certificate with a fully explicit constant, and the needed inequality is one
`nlinarith` away from the existing contraction lemma.

### 3. Nonlinear message passing: contraction survives 1-Lipschitz activations

Real message-passing layers interleave the linear step `T = 1 − αΔ` with a coordinatewise
nonlinearity `σ` (ReLU, tanh). The conjecture: if `σ` is `1`-Lipschitz and fixes the
harmonic subspace pointwise (`σ(h) = h` for `Δh = 0`), then the composite layer `σ ∘ T` is
still a contraction toward `ker Δ` with the same spectral rate `1 − μ/λ`. The key insight
is that `mpStep_iterate_contraction` only ever uses the *energy* recursion
`⟪T(·),T(·)⟫ ≤ ρ⟪·,·⟫`, and a `1`-Lipschitz `σ` fixing the harmonic part composes
multiplicatively with that bound without touching linearity — so the proof skeleton
transfers almost verbatim once `T` is replaced by `σ ∘ T` and a harmonic-fixed-point lemma
is re-established for `σ`. Why now? This is the first direction that genuinely *exits* the
linear theory and connects the cycle to practical (nonlinear) simplicial/graph neural
networks, yet it costs almost no new infrastructure because the contraction machinery is
energy-based, not operator-based.

### 4. A continuous-time bridge: `Tᵏ` is the Lie–Trotter discretization of `e^{−tΔ}`

Having proved the discrete semigroup law `depthMap_semigroup`, the next unification is to
connect it to the *continuous* heat semigroup `e^{−tΔ}` on a finite-dimensional `E`. The
conjecture: `(1 − (t/n)·Δ)ⁿ → e^{−tΔ}` strongly as `n → ∞`, and the harmonic projection is
the common `t → ∞` limit of both. The key insight is that on finite-dimensional `E` the
operator exponential (Mathlib's `NormedSpace.exp`) and the binomial expansion of
`(1 − (t/n)Δ)ⁿ` agree term-by-term in the limit, so the discrete-to-continuous passage is
a `Tendsto` of matrix power series — and the steady states match because `Δ` is PSD with
kernel `ker Δ`. Why now? It places the combinatorial/learning object (`depthMap`) and the
analytic object `exp(−tΔ)` under one roof, exactly the "special case of a deeper truth"
this engine is configured to seek, and Mathlib's `NormedSpace.exp` plus `tendsto_pow`
supply the analytic backbone.

### 5. Closing the Carmichael tail: a height bound for the primitive part

Orthogonally to the Hodge thread, the catalog's `CarmichaelComposite.lean` /
`Shared/CarmichaelProof.lean` still contains a load-bearing `sorry`: the *infinite tail*
of Carmichael's primitive-divisor theorem — every composite `n > 10000` has a Fibonacci
primitive prime divisor (the range `13 ≤ n ≤ 10000` is already settled by
`native_decide`). The key insight is that the primitive part `Φₙ` of `Fₙ` admits a
cyclotomic factorization `Fₙ = ∏_{d∣n} Φ_d`, and a Carmichael/Zsygmondy height bound
`|Φₙ| > n` (using `Fₙ ≥ φ^{n−2}` and a lifting-the-exponent control of the unique possibly
imprimitive prime) forces `Φₙ > 1`, hence a primitive divisor; this purely *analytic*
lower bound is exactly what `primPart`/`fibCoprimePart` compute. Why now? The combinatorial
scaffolding (entry-point theory, `fib_dvd_gcd`, the coprime-part algorithm and its
correctness lemmas) is already proved sorry-free in the catalog — the *only* missing piece
is the growth/height estimate, a self-contained real-analysis lemma that can be developed
independently and then dropped into the existing `fib_carmichael_composite` skeleton to
eliminate the project's last open `sorry`.
