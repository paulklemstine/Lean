# Future Directions — Quantum Thermodynamics: Landauer's Principle at the Nanoscale

## Synthesis

This cycle built the **finite-temperature, probabilistic** backbone of Landauer's
principle and connected it, end to end, from a single convexity primitive
(`1 + t ≤ exp t`, equivalently `log y ≤ y - 1`) to the headline limit
`⟨W⟩ ≥ kT log 2`.  The structural discovery is that **one inequality does all the
work twice**: applied to ratios `q/p` it yields Gibbs/Klein non-negativity of relative
entropy (`relEntropy_nonneg`), and applied to the Jarzynski average it yields Jensen's
inequality for `exp` (`exp_average_le`), from which the second law
`⟨W⟩ ≥ ΔF` (`jarzynski_jensen_second_law`) and the generalized erasure bound
`⟨W⟩ ≥ kT log N` (`landauer_work_bound`) follow.  Logical irreversibility and
thermodynamic irreversibility are thereby shown to be two readings of the *same*
convexity fact: a deterministic memory has zero Shannon entropy
(`shannonEntropy_pointMass_eq_zero`), a uniform bit has entropy `log 2`
(`shannonEntropy_uniform_eq_log_card`), and the maximum-entropy principle
`H(p) ≤ log |ι|` (`shannonEntropy_le_log_card`, an arbitrary-`Fintype`
generalization of `VonNeumannEntropy.shannonEntropyFin_le_log_card`) caps the
information that erasure can destroy.

What worked: keeping the entire development at the level of finite probability vectors
over an arbitrary `Fintype` (rather than `Fin n` or `ZMod`/density matrices) made every
step a one- or two-line consequence of a clean lemma, and let the headline bit-bound be
a literal instantiation `N := 2` of the general bound.  What surprised us: the positivity
hypothesis `0 < N` on the cell count turned out to be **derivable** from the Jarzynski
ratio constraint itself (`Z > 0` and `Z ≤ 1/N` force `N > 0`), so the general bound is
strictly cleaner than its textbook statement.  What we deliberately deferred: the *exact*
finite-size correction (the gap `⟨W⟩ - ΔF` as an explicit relative entropy) and the
genuinely *quantum* (non-commuting density-matrix) version, both flagged below.

These directions tie together into one narrative: we have the *lower bound* (the second
law) sharply; the frontier is the *equality structure* — exactly how much is dissipated,
when the bound is saturated, and how the classical picture deforms into the quantum and
zero-temperature regimes already present elsewhere in the catalog.

## Results Summary

- `term_bound`: proved — the tangent-line inequality `p - q ≤ p·log(p/q)`, the single convexity seed for everything downstream.
- `relEntropy_nonneg`: proved — Gibbs/Klein inequality `0 ≤ D(p‖q)`, the master inequality behind all Landauer-type bounds.
- `shannonEntropy_pointMass_eq_zero`: proved — a deterministic (logically irreversible) memory state carries zero entropy.
- `shannonEntropy_uniform_eq_log_card`: proved — a uniform memory has entropy `log|ι|` (so a uniform bit has `log 2`).
- `shannonEntropy_le_log_card`: proved — maximum-entropy principle on an arbitrary `Fintype`, generalizing the catalog's `Fin n` version.
- `exp_average_le`: proved — Jensen's inequality for `exp`, the convexity engine of the Jarzynski bound.
- `jarzynski_jensen_second_law`: proved — `⟨W⟩ ≥ ΔF = -(1/β)log Z`, the second law from the Jarzynski average.
- `landauer_work_bound`: proved — `⟨W⟩ ≥ kT log N` whenever the Jarzynski ratio is `≤ 1/N` (cell-count positivity is derived, not assumed).
- `landauer_bit_kT_log_two`: proved — the headline Landauer limit `⟨W⟩ ≥ kT log 2` for erasing one bit, as the `N = 2` instance.

## Research Directions

### Direction 1: The exact finite-size correction is a relative entropy
**Hypothesis**: For an erasure protocol with actual final distribution `p_fin` relative
to the equilibrium reference `p_eq`, the dissipated work satisfies the *equality*
`β(⟨W⟩ - ΔF) = D(p_fin ‖ p_eq)`, so the slack in `landauer_work_bound` is exactly the
relative entropy of the achieved state from equilibrium.
**Test**: State `dissipated_work_eq_relEntropy` and prove the gap term equals
`relEntropy p_fin p_eq`; numerically (`#eval` on `ℚ`-valued toy distributions) check that
`landauer_work_bound`'s slack matches `relEntropy` for several `N` and `β`.
**Why now**: We already have both halves — `relEntropy_nonneg` and the chain producing
`⟨W⟩ ≥ ΔF` — sharing the *same* tangent-line lemma `term_bound`; the equality just keeps
the tangent gap instead of discarding it. The key insight is that the inequality
`term_bound` becomes an equality exactly at `p = q`, so tracking its defect upgrades the
bound to an identity.
**If true**: Landauer's bound becomes an *exact accounting* — every nat of dissipated
work is charged to a nat of distance-from-equilibrium, the cleanest possible statement of
"thermodynamic = logical irreversibility."
**If false**: the discrepancy localizes which idealization (instantaneous quench,
Markovianity) breaks the equality, sharpening the hypotheses of the finite-size theory.

### Direction 2: Saturation / reversibility characterization
**Hypothesis**: Equality `0 = relEntropy p q` holds **iff** `p = q` pointwise; equivalently
`⟨W⟩ = ΔF` (zero dissipation) holds iff the protocol is quasi-static (achieved state equals
equilibrium), which is the formal meaning of a *reversible* erasure saturating `kT log 2`.
**Test**: Prove `relEntropy_eq_zero_iff : relEntropy p q = 0 ↔ p = q` under the standing
positivity/normalization hypotheses, by upgrading `term_bound` to its strict form
(`Real.log_lt_sub_one_of_ne`/strict convexity of `exp`).
**Why now**: `relEntropy_nonneg` is proved by summing non-negative tangent gaps; the
equality case is precisely "every gap vanishes," which is a strict-inequality refinement
of the *same* lemma. The key insight is that strict convexity of `exp` converts the
existing non-strict per-coordinate bound into an iff with essentially no new machinery.
**If true**: gives the reversible-limit endpoint, completing the second law into a
necessary-and-sufficient dissipation criterion.
**If false** (e.g. boundary `p_i = 0` subtleties): exposes exactly how the `log 0 = 0`
convention interacts with the equality case, a known delicate point in entropy formalization.

### Direction 3: Quantum (von Neumann) Klein inequality and quantum Landauer
**Hypothesis**: The classical `relEntropy_nonneg` lifts to density matrices:
`0 ≤ Tr ρ(log ρ - log σ)` for density matrices `ρ, σ` with `σ ≻ 0` (quantum Klein
inequality), and hence the quantum erasure bound `⟨W⟩ ≥ kT log 2` holds for a qubit.
**Test**: Working from `Physics/VonNeumannEntropy.lean`'s `DensityMatrix`,
`vonNeumannEntropy`, and `diagonalDensity`, first prove the *diagonal* case reduces to our
`relEntropy_nonneg`, then attempt the non-commuting case via the Peierls–Bogoliubov or
Golden–Thompson inequality.
**Why now**: `VonNeumannEntropy.lean` already supplies the density-matrix API and proves
`vonNeumannEntropy_eq_shannon_diagonal`, so the diagonal bridge is immediate; our classical
result becomes the commuting special case. The key insight is that the diagonal (classical)
sector is *exactly* the theory we just built, so the quantum statement only needs the
genuinely non-commuting increment.
**If true**: unifies the two Physics-catalog entropy developments and yields a fully
quantum nanoscale Landauer bound.
**If false at the non-commuting step**: pinpoints that Golden–Thompson (not yet in this
toolchain) is the true missing ingredient, a concrete Mathlib-gap to fill.

### Direction 4: Zero-temperature limit bridges to the tropical bound
**Hypothesis**: As `β → ∞` (`T → 0`), `landauer_work_bound` degenerates into the purely
combinatorial `Physics/Landauer.tropical_landauer_finite`: the energetic cost `kT log N`
collapses onto the tropical entropy-defect `log N` measuring cardinality collapse.
**Test**: Formalize a limiting statement relating `(1/β)·log N` rescaled by `β` to the
`entropyDefect` of an erasure map; alternatively prove that the *minimum* over admissible
work distributions of `β⟨W⟩` tends to `log N`, matching `entropyDefect` of a constant map.
**Why now**: both endpoints now exist in the catalog — our finite-`T` bound and the
existing tropical (`T=0`) bound — and they share the literal constant `log N`. The key
insight is that the tropical min-plus algebra is the `β → ∞` shadow of the
log-partition-function, so the two Landauer theorems are the two ends of one one-parameter
family.
**If true**: produces a rare *formal* classical-limit bridge linking min-plus geometry to
statistical thermodynamics inside the catalog.
**If false**: reveals that the naive `β → ∞` limit drops a subextensive term, clarifying
the boundary between combinatorial and thermodynamic erasure costs.

### Direction 5: Multi-bit additivity and the cost of erasing a register
**Hypothesis**: Erasing a register of `k` independent uniform bits costs at least
`k · kT log 2`; more generally `shannonEntropy` is additive on product distributions, so
the Landauer cost is extensive in the number of erased bits.
**Test**: Prove `shannonEntropy_prod : shannonEntropy (p ⊗ q) = shannonEntropy p +
shannonEntropy q` over `ι × κ`, then derive `landauer_register : ⟨W⟩ ≥ kT · k · log 2`
by instantiating `landauer_work_bound` with `N = 2^k` over `Fin k → Bool`.
**Why now**: `landauer_work_bound` is already stated for arbitrary `N` and arbitrary
`Fintype`, so `N = 2^k` over a product type is a direct instantiation once additivity of
`shannonEntropy` is in hand. The key insight is that our `Fintype`-level generality (not
`Fin n`) makes product indexing `ι × κ` free, so additivity is the only new lemma needed.
**If true**: scales the single-bit result to realistic memory registers, the regime where
nanoscale Landauer dissipation actually matters.
**If false** (correlated bits): the failure quantifies how mutual information *reduces*
erasure cost, opening the door to a Landauer theory with correlations.
