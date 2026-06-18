# Future Directions: Local Hamiltonian Complexity in Lean 4

The module `Catalog/Physics/LocalHamiltonianQMA.lean` formalizes the linear-algebraic
backbone of the *k-Local Hamiltonian Problem* — the canonical QMA-complete problem of
quantum Hamiltonian complexity. We made machine-checked the energy functional `qform`,
the reality of Hermitian expectation values (`IsHermitian.qform_self_conj`), the
**additive composition** of certified energy lower bounds over local terms
(`energyLB_add`, `energyLB_sum`), the Hermiticity of the total local Hamiltonian
(`isHermitian_sum`), the logical consistency of the promise gap
(`promise_gap_consistent`), and a concrete *frustration* witness
(`frustration_no_common_ground_state`) showing two single-qubit terms with individual
ground energy `0` that share no common zero-energy state.

Below are five testable, falsifiable research directions that extend this work. Each
builds directly on the catalog: the energy-certificate calculus generalizes the
interval-bound composition of `Physics.CertifiedMassGapBounds`, the variational angle
connects to `Physics.V12_VariationalPrinciples`, and the frustration phenomenon links
to the spectral-gap material throughout the Physics library.

## Direction 1: Quantitative frustration energy (super-additivity made numeric)

Conjecture: for the frustration witness `H = Hz + Hx`, the ground energy is exactly
`(2 - √2)/2 ≈ 0.293`, strictly above the sum `0 + 0 = 0` of the local ground energies.
Formally, `EnergyLB (Hz + Hx) ((2 - Real.sqrt 2)/2)` holds and is tight: there is a
normalized state achieving it.

The key insight is that `frustration_no_common_ground_state` is the *qualitative*
shadow of a *quantitative* spectral gap — proving the exact constant turns a
non-existence statement into a certified, optimal lower bound that the promise-gap
machinery (`promise_gap_consistent`) can then consume directly. Why now? We already
have `qform_Hz` and `qform_Hx` as closed-form perfect squares, so the Rayleigh quotient
`qform (Hz+Hx) x / normSq2 x` is an explicit two-variable real-rational function whose
minimum is a finite optimization Lean's `polyrith`/`nlinarith` can certify.

## Direction 2: Tensor (locality) embedding and the `2`-local structure

Conjecture: an operator `A ⊗ I` on `(Fin d → Fin 2)`-indexed qubit space is Hermitian
iff `A` is, and `EnergyLB A λ → EnergyLB (A ⊗ I) λ` (padding with identity preserves
energy bounds). More generally a genuinely *k-local* term is `A` acting on `k`
coordinates tensored with identity on the rest.

The key insight is that locality is *structurally invisible* to the energy-certificate
calculus — `energyLB_sum` never inspects which qubits a term touches — so k-locality can
be added as a thin `Matrix.kroneckerMap` layer on top of the already-proven additivity
without reproving any energy algebra. Why now? Mathlib's `Matrix.kroneckerMap`,
`Matrix.kronecker_assoc`, and `IsHermitian` API are mature enough to push quadratic
forms through tensor products, making the embedding lemmas pure bookkeeping over results
we already have.

## Direction 3: Variational ground energy as an infimum and the QMA verifier bound

Conjecture: define `groundEnergy H := ⨅ x : {v // normSq2 v = 1}, (qform H x).re`. Then
`EnergyLB H λ ↔ λ ≤ groundEnergy H` (for Hermitian `H`), and the YES/NO promise reduces
to comparing `groundEnergy` against the thresholds `a < b`.

The key insight is that `EnergyLB` is exactly the *lower-set characterization* of an
infimum, so the entire promise-gap analysis collapses to the order theory of `⨅`,
making `promise_gap_consistent` a one-line corollary of `csInf` monotonicity. Why now?
This bridges to `Physics.V12_VariationalPrinciples` (which already treats energy as a
variational functional) and to `Physics.CertifiedMassGapBounds` (whose certified bounds
are exactly elements below this infimum), unifying three catalog modules under one
`groundEnergy` definition.

## Direction 4: The clock/history-state Hamiltonian (Kitaev reduction skeleton)

Conjecture: for a length-`T` sequence of unitaries, the Feynman–Kitaev *history state*
`|η⟩ = (1/√(T+1)) ∑_{t} U_t⋯U_1|ψ⟩⊗|t⟩` is a zero-energy eigenstate of the propagation
Hamiltonian `H_prop = ∑_t ½(I - U_t⊗|t⟩⟨t-1| - U_t†⊗|t-1⟩⟨t|)`, and `H_prop` is a sum
of `2`-local (on the clock+work registers) Hermitian terms via `isHermitian_sum`.

The key insight is that the hardest half of QMA-completeness — *completeness*,
i.e. exhibiting a low-energy witness for YES instances — is a single explicit
eigenvector computation that `qform` plus `energyLB_sum` can verify term by term,
deferring the harder *soundness* gap to Direction 1's quantitative methods. Why now?
With Hermiticity-of-sums and the energy functional already formalized, the history-state
construction needs only finite indexed sums over the clock register, which Lean handles
natively with `Finset.sum`; no new analytic machinery is required to state and check the
zero-energy property.

## Direction 5: Promise-gap amplification and robustness

Conjecture: if `EnergyLB H b` and `H` admits a YES witness at threshold `a`, then for
the rescaled Hamiltonian `c • H` (`c > 0`) the gap scales as `c·(b - a)`, and
`promise_gap_consistent` lifts to a *quantitative margin* `(qform (c•H) x).re ≥ c·b`
for every NO instance. Iterating gives gap amplification analogous to error reduction
for QMA verifiers.

The key insight is that positive scaling is an order-automorphism of the
energy-certificate semiring, so amplification is *free* once `energyLB_smul_nonneg` (a
two-line companion to `energyLB_add`) is in place — the complexity-theoretic content
(boosting a `1/poly` gap) becomes a statement about multiplying a real inequality by a
constant. Why now? The additive structure (`energyLB_add`, `energyLB_sum`) is already
proven; closing the semiring with nonnegative scalar multiplication is the minimal
missing axiom needed to make the gap a genuine, tunable resource, and it directly
strengthens the existing `promise_gap_consistent` theorem.
