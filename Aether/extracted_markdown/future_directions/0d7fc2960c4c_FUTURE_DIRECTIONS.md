# Future Directions — Hawking Radiation & the Information Paradox

## Synthesis

`Physics/HawkingInformation.lean` reduces the black hole information paradox to a
single, austere primitive: an evolution operator `U` on a finite-dimensional
Hilbert space is *unitary* exactly when `Uᴴ * U = 1`. From this one equation we
derive the entire dichotomy at the heart of the paradox. If evolution is unitary,
the infalling state is recovered from the Hawking radiation by the adjoint decoder
(`unitary_recovery`), the evaporation map is injective so no information is lost
(`unitary_preserves_information`), and the mixed-state conjugation channel
`ρ ↦ U ρ Uᴴ` is reversible and trace-preserving (`unitary_conj_recovery`,
`unitary_conj_preserves_trace`). Conversely, any evolution that maps two distinct
infalling states to identical radiation *cannot* be unitary
(`information_loss_implies_nonunitary`): semiclassical information destruction and
quantum mechanics are formally incompatible. The biconditional
`unitary_iff_recoverable` packages this as a clean either/or. An explicit 2-qubit
toy black hole — the `SWAP` gate — instantiates the abstract theory with full,
exact recovery of the infalling state from the radiation.

## Results Summary

- `unitary_recovery` — the adjoint decodes the radiation back to the input state.
- `unitary_preserves_information` — unitary evaporation is injective.
- `information_loss_implies_nonunitary` — information loss forbids unitarity.
- `unitary_iff_recoverable` — unitarity ⇔ universal recoverability (the dichotomy).
- `unitary_conj_recovery`, `unitary_conj_preserves_trace` — mixed-state channel is
  reversible and conserves total probability.
- `swap_isUnitary`, `swap_recovery`, `swap_selfInverse` — a concrete 2-qubit model.

All main results are `sorry`-free and depend only on the standard axioms
`propext`, `Classical.choice`, `Quot.sound`.

## Research Directions

### 1. Norm and inner-product preservation ⇒ no-cloning bridge
Unitary evolution should preserve the Hilbert-space inner product
`⟪U ψ, U φ⟫ = ⟪ψ, φ⟫`, and in particular norms (probabilities). The key insight is
that *information preservation is metric preservation*: an isometry of a finite
inner-product space is automatically the bijection our injectivity theorem already
produces, so inner-product preservation and recoverability are two faces of the
same `Uᴴ * U = 1`. Why now? The recovery and injectivity scaffolding is in place;
adding `Matrix.dotProduct`/`star` preservation lets us derive a **no-cloning**
corollary (a unitary cannot duplicate an unknown state) directly from unitarity,
linking this file to `Physics/StabilizerBounds.lean`'s error-correction setting.

### 2. Entropy invariance and the Page curve
The von Neumann entropy `S(ρ) = -tr(ρ log ρ)` of a state should be invariant under
unitary conjugation, since `U ρ Uᴴ` has the same spectrum as `ρ`. The key insight
is that *unitarity preserves the eigenvalue multiset*, so every spectral functional
(entropy, purity, Rényi entropies) is conserved — the global state stays pure even
as subsystems thermalize. Why now? `unitary_conj_preserves_trace` already proves the
degree-1 spectral invariant (trace); generalizing the cyclicity argument to
`tr((U ρ Uᴴ)^k) = tr(ρ^k)` for all `k` gives spectrum invariance, the formal seed of
the **Page curve** and a direct extension of `Physics/HolevoCapacity.lean`'s entropy
machinery.

### 3. Partial trace and the subsystem information flow
Model black hole + radiation as a tensor product `ℂ^a ⊗ ℂ^b` and define the partial
trace onto the radiation subsystem. The key insight is that *information is global,
not local*: the partial trace of a unitarily evolved pure state can look thermal on
the radiation alone while the joint state remains perfectly recoverable. Why now?
With recoverability proven for the full state, formalizing `partialTrace` and showing
`tr_B (U |ψ⟩⟨ψ| Uᴴ)` can be maximally mixed while the global state is pure makes the
"thermal radiation yet unitary evolution" resolution mathematically explicit.

### 4. The decoder is unique
We use the adjoint `Uᴴ` as the canonical decoder, but uniqueness deserves a theorem:
if `D ∘ U = id` and `D' ∘ U = id` on all states then `D = D'` on the image of `U`.
The key insight is that *recovery is deterministic*: a left inverse of an injective
finite-dimensional map is unique on the range, so "where did the information go" has a
single well-defined answer. Why now? `unitary_iff_recoverable` already isolates the
decoder; a short uniqueness lemma turns the decoder from "a" recovery map into "the"
recovery map, sharpening the paradox's resolution.

### 5. Composition of evaporation steps stays unitary (semigroup of recovery)
Evaporation is many small unitary steps `U = U_k ⋯ U_1`. The key insight is that
*recoverability is compositional*: the product of unitaries is unitary, with decoder
`U_1ᴴ ⋯ U_kᴴ` in reversed order, so information survives an arbitrarily long
evaporation history exactly when each step is unitary. Why now? `IsUnitary` and
`IsUnitary.mul_conjTranspose` give the algebraic closure properties for free;
proving `IsUnitary U → IsUnitary V → IsUnitary (U * V)` and the reversed-decoder
identity establishes a **monoid/group** structure on evaporation channels, connecting
to the catalog's matrix-group results (`Algebra/MatrixGroupGeneration.lean`).
