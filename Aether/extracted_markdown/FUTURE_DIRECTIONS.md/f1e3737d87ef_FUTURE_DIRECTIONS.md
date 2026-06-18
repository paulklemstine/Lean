# FUTURE_DIRECTIONS — Zeta Functions of Directed Graphs and the Graph Riemann Hypothesis

## Synthesis

This cycle built, from scratch, the algebraic backbone of the **Bowen–Lanford /
Ihara-style zeta function** of a finite directed graph and proved the spectral
dictionary that gives the *Graph Riemann Hypothesis* (GRH) its meaning. The
organizing object is the reciprocal zeta `zetaInv A u = det(1 - u • A)`, a
polynomial in `u` whose vanishing locus is the pole set of the true zeta
`zeta_G(u) = (det(1 - u • A))⁻¹`. The decisive structural insight is that *every*
analytic feature of `zeta_G` is governed by the **reverse characteristic
polynomial**: `zetaInv A u = (charpoly A).reverse.eval u`
(`zetaInv_eq_charpolyRev`). Once this bridge is in place, the eigenvalues of `A`
become the reciprocal roots of `zetaInv`, and the entire "Riemann Hypothesis"
analogy reduces to elementary statements about where the roots of a polynomial
sit in the complex plane.

From the bridge we derived the Euler product `zetaInv A u = ∏(1 - u·λ)` over
eigenvalues (`zetaInv_eq_prod_roots`), the pole characterization "poles are
reciprocal eigenvalues" (`zetaInv_eq_zero_iff`), the first Bowen–Lanford trace
moment `tr A = ∑ λ` (`trace_eq_sum_roots`), and — the conceptual payoff — the
equivalence `graphRH_iff_poles_on_circle`: the spectrum lies on a circle of
radius `ρ` **iff** all poles of `zeta_G` lie on the "critical circle" of radius
`ρ⁻¹`. The Critic's counterexample `diag_not_RH` shows the hypothesis is
genuinely restrictive: the two-self-loop graph with eigenvalues `{1, 2}` fails
GRH for every `ρ`, because distinct eigenvalue moduli cannot share a circle.

What failed / what we learned: the positivity hypothesis `0 < ρ` we initially
imposed on the critical modulus turned out to be **unnecessary** — the pole
`u = r⁻¹` realizes each nonzero eigenvalue and `inv` is injective on `ℝ`, so the
equivalence holds for all `ρ`. This is a small but instructive reminder that the
GRH-on-a-circle statement is purely about modulus equality, not about a
distinguished radius. The natural next frontier is the *higher* trace moments
`tr A^m = ∑ λ^m`, which package into `log zeta_G` and connect GRH to closed-walk
growth rates — the directions below are organized around closing that loop.

## Results Summary

- `zetaInv_zero`: proved — normalization `zetaInv A 0 = 1`, the anchor making `log zeta_G` a well-defined power series.
- `zetaInv_eq_charpolyRev`: proved — `zetaInv A u = (charpoly A).reverse.eval u`; the determinant-formula bridge from which everything else follows (works over any `CommRing`).
- `zetaInv_eq_prod_roots`: proved — spectral Euler product `zetaInv A u = ∏(1 - u·λ)` over ℂ; identifies reciprocal roots with eigenvalues.
- `zetaInv_eq_zero_iff`: proved — poles of `zeta_G` are exactly the reciprocals of the nonzero eigenvalues.
- `trace_eq_sum_roots`: proved — first Bowen–Lanford moment `tr A = ∑ λ`; counts weighted length-1 closed walks.
- `graphRH_iff_poles_on_circle`: proved — Graph RH (eigenvalues on `|λ| = ρ`) ⇔ all poles on the critical circle `|u| = ρ⁻¹`; the GRH "critical line" statement.
- `diag_not_RH`: proved (counterexample) — `diagonal ![1,2]` violates GRH for all `ρ`; shows GRH is a nontrivial constraint.

## Research Directions

### Direction 1: Higher trace moments and the closed-walk generating function
**Hypothesis**: For `A : Matrix V V ℂ` and every `m ≥ 1`, `(A ^ m).trace = (A.charpoly.roots.map (· ^ m)).sum`, i.e. the number of weighted length-`m` closed walks equals the `m`-th power sum of eigenvalues; consequently `log zeta_G(u) = ∑_{m≥1} (tr A^m / m) u^m` as formal power series.
**Test**: Prove the spectral-mapping multiset identity `(A^m).charpoly.roots = A.charpoly.roots.map (· ^ m)` (or directly that trace of a power is the power sum) using `trace_eq_sum_roots` together with the existing `zetaInv_eq_prod_roots`, then differentiate `log` of the product `∏(1 - u·λ)` formally with `PowerSeries`.
**Why now**: `trace_eq_sum_roots` already nails the `m = 1` case and `zetaInv_eq_prod_roots` gives the factored form whose logarithmic derivative is `∑ λ/(1 - u λ)` — the generating function falls out by expanding each geometric term.
**If true**: Connects GRH directly to *exponential growth of closed walks*, the genuine dynamical content of Bowen–Lanford zeta, and gives a counting interpretation of the critical circle.
**If false**: Would reveal that eigenvalue multiplicities and walk counts diverge — pointing to defective (non-diagonalizable) adjacency matrices as the obstruction.

### Direction 2: Functional equation for symmetric (undirected) graphs
**Hypothesis**: If `A` is symmetric (an undirected graph), then `zetaInv A` satisfies a palindromic functional equation `u^n · zetaInv A (1/u) = ± zetaInv A u` (where `n = card V`), reflecting the reality of the spectrum.
**Test**: Use `zetaInv_eq_charpolyRev` and the fact that for real-spectrum `A` the characteristic polynomial has real coefficients; relate `charpoly.reverse` to `charpoly` via `Polynomial.reverse_reverse` and degree bookkeeping.
**Why now**: The reverse-polynomial bridge is exactly the object a functional equation acts on; we already control `reverse` well enough to factor it (`zetaInv_eq_prod_roots`).
**If true**: Establishes the graph analogue of the Riemann ξ-function symmetry `s ↔ 1-s`, completing the "RH" analogy with a genuine reflection.
**If false**: Pinpoints that directedness/asymmetry breaks the reflection, isolating exactly which graphs admit a functional equation.

### Direction 3: Ramanujan graphs as the GRH-satisfying class
**Hypothesis**: A `k`-regular graph satisfies `SatisfiesGraphRH` with `ρ = √(k-1)` for its *nontrivial* eigenvalues iff it is Ramanujan (all eigenvalues `λ ≠ ±k` satisfy `|λ| ≤ 2√(k-1)`, sharpened here to equality on the relevant Ihara variable).
**Test**: Specialize `graphRH_iff_poles_on_circle` to the Ihara zeta (via the Ihara–Bass determinant `det(I - uA + u²(k-1)I)`) and compare the pole circle `|u| = (k-1)^{-1/2}` with the Ramanujan bound.
**Why now**: `graphRH_iff_poles_on_circle` already converts a spectral-circle condition into a pole-circle condition; only the Ihara–Bass substitution `1 - uA ↦ 1 - uA + u²(k-1)I` is missing.
**If true**: Formalizes the celebrated theorem "Ihara-RH ⇔ Ramanujan", a flagship result in spectral graph theory, on top of our bridge.
**If false** (for the naive Bowen–Lanford zeta): Shows the Bowen–Lanford and Ihara zetas have genuinely different critical loci, clarifying which zeta the GRH "should" be stated for.

### Direction 4: Stability of GRH under graph operations
**Hypothesis**: GRH-with-modulus-`ρ` is preserved by disjoint union (block-diagonal `A ⊕ B`) and tensor product (`A ⊗ B` gives modulus `ρ_A · ρ_B`), but generically destroyed by adding a single edge.
**Test**: For the constructive parts, prove `(A.fromBlocks ... ).charpoly.roots = A.charpoly.roots + B.charpoly.roots` and the Kronecker eigenvalue-product identity, then feed into `SatisfiesGraphRH`. For destruction, exhibit a rank-one perturbation breaking modulus equality (extend the `diag_not_RH` technique).
**Why now**: `SatisfiesGraphRH` is phrased purely in terms of `charpoly.roots`, and `diag_not_RH` already demonstrates the counterexample machinery for breaking the property.
**If true**: Gives GRH an algebraic closure property, enabling inductive construction of large GRH-graphs.
**If false**: Identifies the precise operations under which the critical circle can split, a structural map of GRH's fragility.

### Direction 5: Quantitative spectral-gap form of near-GRH
**Hypothesis**: Define the GRH defect `δ(A) = sup{ | ‖r‖ - ‖r'‖ | : r, r' nonzero roots }`; then `δ(A) = 0 ↔ SatisfiesGraphRH A ρ` for some `ρ`, and `δ` controls the annular width containing all poles of `zeta_G`.
**Test**: Prove the iff from `graphRH_iff_poles_on_circle` (the `δ = 0` direction is immediate; the converse needs that the poles lie in the annulus `[ (ρ+δ)^{-1}, ρ^{-1} ]`), using `zetaInv_eq_zero_iff` to translate root moduli into pole moduli.
**Why now**: We have both endpoints — the exact GRH equivalence and the pole-as-reciprocal-eigenvalue lemma — so the quantitative interpolation is the natural next refinement.
**If true**: Turns the binary GRH into a continuous *spectral-gap* invariant, the right object for "approximate Ramanujan" / expander quantification.
**If false**: Would mean root-modulus spread and pole-annulus width decouple, signaling that `zeta_G` loses information about the spectrum — itself a sharp negative result.
