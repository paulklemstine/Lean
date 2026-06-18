# Future Directions — Spectral Chain Framework: L²(π) Two-Sided Spectral Bounds

## Synthesis

The previous cycle built the `L²(π)` operator layer (`Computation/SpectralChain/L2Operator.lean`):
detailed balance *is* self-adjointness of the Markov operator `P`, the Dirichlet form is
the quadratic form of `I - P`, and a Poincaré gap `γ` gives the one-sided Rayleigh
contraction `⟨Pf,f⟩_π ≤ (1-γ)⟨f,f⟩_π` on mean-zero observables. That cycle then *disproved*
the squared variance contraction `Var(Pf) ≤ (1-γ)²·Var(f)` via the bipartite swap chain
(eigenvalue `-1`), and its lab notebook diagnosed the exact missing ingredient: an
**absolute lower spectral bound** `⟨Pf,f⟩_π ≥ -⟨f,f⟩_π`.

This cycle supplies that ingredient and develops its consequences in a new self-contained
module `Computation/SpectralChain/L2Contraction.lean`. The structural insight is a **duality**:
the standard Dirichlet form `½∑ πᵢ Pᵢⱼ (fᵢ-fⱼ)²` equals `⟨f,f⟩ - ⟨Pf,f⟩` and controls the
*upper* end of the spectrum, while a *dual* form `additiveEnergy = ½∑ πᵢ Pᵢⱼ (fᵢ+fⱼ)²` equals
`⟨f,f⟩ + ⟨Pf,f⟩` and controls the *lower* end. Because `additiveEnergy` is a manifest sum of
squares, the absolute lower bound is immediate, and the two halves together prove that `P`
is an `L²(π)` contraction on the Rayleigh quotient (`|⟨Pf,f⟩| ≤ ⟨f,f⟩`, spectrum in `[-1,1]`).
We then introduce the **lazy chain** `P' = ½(I+P)` and prove it is positive semidefinite
(`0 ≤ ⟨P'f,f⟩_π`) — precisely the property whose absence (an eigenvalue at `-1`) broke the
squared contraction last cycle. Nothing failed in this cycle; the swap-chain counterexample
turned out to be exactly the configuration where `additiveEnergy` vanishes, confirming the
lower bound is tight and that laziness is the genuine repair.

The takeaway for the next team: the additive/subtractive Dirichlet duality cleanly separates
upper- and lower-spectrum control, and the lazy chain's PSD-ness is the missing structural
hypothesis that should now let the squared variance contraction be *proved* (not disproved)
for lazy chains. The pieces (`lazyChain_psd`, the two-sided bound) are in place; what remains
is a Cauchy–Schwarz step on the PSD form `⟨P'·,·⟩` to turn the quadratic-form bounds into a
genuine `Var(P'f) ≤ ρ²·Var(f)` contraction.

## Results Summary

- `innerPi_additive_energy`: proved — the dual energy identity `⟨f,f⟩_π + ⟨Pf,f⟩_π = ½∑πᵢPᵢⱼ(fᵢ+fⱼ)²`, the `+` mirror of the Dirichlet form.
- `innerPi_applyP_lower_bound`: proved — the absolute lower spectral bound `-⟨f,f⟩_π ≤ ⟨Pf,f⟩_π`, the ingredient missing last cycle, free from the sum-of-squares structure.
- `innerPi_applyP_upper_bound`: proved — `⟨Pf,f⟩_π ≤ ⟨f,f⟩_π`, equivalent to energy nonnegativity.
- `applyP_inner_abs_bound`: proved — `|⟨Pf,f⟩_π| ≤ ⟨f,f⟩_π`; `P` is an `L²(π)` contraction, Rayleigh spectrum in `[-1,1]`.
- `lazyChain` (+ `lazyChain_applyP`): proved — the lazy chain `P' = ½(I+P)` is a reversible chain with the same `π`, acting as `(P'f)(i) = ½(fᵢ + (Pf)ᵢ)`.
- `lazyChain_psd`: proved — the lazy operator is positive semidefinite, `0 ≤ ⟨P'f,f⟩_π`, separating its spectrum from `-1`.

## Research Directions

### Direction 1: Squared variance contraction for lazy chains
**Hypothesis**: If `C` has a Poincaré certificate with gap `γ`, then the lazy chain satisfies
`Var(P'f) ≤ (1 - γ/2)²·Var(f)` for all observables `f`.
**Test**: Prove it in Lean. The route: `lazyChain_psd` gives `0 ≤ ⟨P'g,g⟩` for all `g`; the
inherited gap (the lazy Dirichlet form is `½` the original) gives `⟨P'f,f⟩ ≤ (1-γ/2)⟨f,f⟩` on
mean-zero `f`; a Cauchy–Schwarz inequality for the PSD bilinear form `B(x,y)=⟨P'x,y⟩` upgrades
the Rayleigh bound to the operator-square bound `⟨(P')²f,f⟩ ≤ (1-γ/2)²⟨f,f⟩ = Var(P'f)`.
**Why now**: This cycle proved exactly the two facts that route needs — PSD-ness of `P'` and the
two-sided Rayleigh bound — and last cycle proved `Var(g) = ⟨g,g⟩ - mean(g)²` plus `mean(P'f)=mean(f)`.
**If true**: it closes the loop opened by last cycle's disproof, giving the first *provable*
geometric variance contraction in this framework and a clean mixing-time corollary.
**If false**: the failure must come from the `mean` interaction; it would show that PSD-ness alone
is insufficient and that aperiodicity must be quantified differently.

### Direction 2: Cauchy–Schwarz for the chain's PSD form
**Hypothesis**: For any reversible `C`, the form `B(f,g) = ⟨f,f⟩_π·⟨g,g⟩_π` dominates
`⟨(I+P)f, g⟩_π²` up to the additive-energy normalization; concretely
`(⟨f,g⟩_π + ⟨Pf,g⟩_π)² ≤ (⟨f,f⟩_π + ⟨Pf,f⟩_π)·(⟨g,g⟩_π + ⟨Pg,g⟩_π)`.
**Test**: Prove the discriminant of `t ↦ additiveEnergy C (f + t·g)` (a nonnegative quadratic in `t`)
is `≤ 0`, exactly as classical Cauchy–Schwarz is derived.
**Why now**: `additiveEnergy` is now defined and proven equal to `⟨f,f⟩+⟨Pf,f⟩` and nonnegative,
so it is literally a positive-semidefinite quadratic form ready for the discriminant argument.
**If true**: it is the reusable engine behind Direction 1 and any operator-norm estimate.
**If false**: it would mean the additive energy is *not* a genuine inner product (e.g. degenerate),
flagging a missing positivity hypothesis on `P`.

### Direction 3: Spectral radius bound and the contraction constant `ρ`
**Hypothesis**: Define `ρ(C) := sup over mean-zero unit f of |⟨Pf,f⟩_π|`. Then `applyP_inner_abs_bound`
gives `ρ ≤ 1`, a Poincaré gap gives the upper part `≤ 1-γ`, and laziness gives the lower part bounded
away from `1`; the sharp variance contraction rate is exactly `ρ`.
**Test**: Formalize `ρ` as a supremum over the (compact) mean-zero unit sphere and prove
`Var(Pf) ≤ ρ²·Var(f)` from the definition; then specialize to the swap chain (`ρ = 1`) and lazy
chains (`ρ < 1`).
**Why now**: the two-sided bound `|⟨Pf,f⟩| ≤ ⟨f,f⟩` proved here is precisely the statement that this
supremum is `≤ 1` and finite, making the definition well-posed.
**If true**: it unifies the swap-chain disproof and the lazy-chain proof under one scalar invariant.
**If false**: the supremum is not attained or not equal to the contraction rate, revealing that the
finite-dimensional spectral theorem is doing more work than the Rayleigh quotient captures.

### Direction 4: Tensorization / product chains
**Hypothesis**: For the product chain `C₁ ⊗ C₂` (independent coordinates) the absolute lower bound and
PSD-ness tensorize: `additiveEnergy_{C₁⊗C₂}` factors, so `lazyChain` of a product is PSD iff each factor is.
**Test**: Define the product `ReversibleChain` on `V₁ × V₂` and prove `innerPi`, `applyP`, and
`additiveEnergy` are multiplicative/additive across the product, then transport `lazyChain_psd`.
**Why now**: every object used here (`innerPi`, `additiveEnergy`, `applyP`) is a plain finite sum, so the
product structure is a direct Fubini computation rather than an operator-theoretic argument.
**If true**: it yields dimension-free spectral bounds for high-dimensional chains (e.g. product/Glauber dynamics).
**If false**: the cross term in `additiveEnergy` fails to factor, identifying where independence breaks the duality.

### Direction 5: Quantitative aperiodicity from a strictly positive lazy bound
**Hypothesis**: If `min_i P_ii ≥ α > 0` (a quantitative laziness), then `⟨Pf,f⟩_π ≥ (2α - 1)⟨f,f⟩_π`,
strictly improving the absolute lower bound `-⟨f,f⟩` whenever `α > 0`.
**Test**: Strengthen `innerPi_applyP_lower_bound` by isolating the diagonal `i=j` contribution of
`additiveEnergy` (which contributes `2 P_ii fᵢ²`) before discarding the off-diagonal squares.
**Why now**: the proof of the lower bound here discards *all* the sum-of-squares slack; the diagonal
terms are exactly the laziness, sitting unused in `additiveEnergy`, ready to be harvested.
**If true**: it gives a closed-form lower spectral bound from a one-line hypothesis, making Direction 1
unconditional for `α`-lazy chains.
**If false**: the off-diagonal terms can conspire against the diagonal gain, showing the bound needs the
full kernel and not just its diagonal.
