# Future Directions — Hawking Radiation & the Information Paradox

## Synthesis

`Catalog/Physics/HawkingInformation.lean` reduces the black hole information paradox to a
single austere primitive: an evolution operator `U` on a finite-dimensional complex Hilbert
space `Matrix n n ℂ` is *unitary* exactly when `Uᴴ * U = 1`. From this one equation the file
derives the full dichotomy and then **extends** the original concept's conjectural future
directions into proven theorems. Unitary evolution recovers the infalling state through the
adjoint decoder (`unitary_recovery`), is injective so no information is lost
(`unitary_preserves_information`), and the mixed-state conjugation channel `ρ ↦ U ρ Uᴴ` is
reversible and trace-preserving (`unitary_conj_recovery`, `unitary_conj_preserves_trace`).
Conversely, any evolution mapping two distinct infalling states to identical radiation cannot
be unitary (`information_loss_implies_nonunitary`), and the biconditional
`unitary_iff_recoverable` packages the whole thing as an exact either/or.

This cycle adds three genuinely new strands that were previously only narrative directions:

* **Isometry** — `unitary_inner_preserve` / `unitary_norm_preserve`: unitary evolution
  preserves the Hilbert-space inner product, so information preservation literally *is* metric
  preservation.
* **Uniqueness of the decoder** — `decoder_eq_adjoint` / `decoder_unique`: the adjoint is *the*
  recovery map, turning "where did the information go?" into a question with a single answer.
* **The monoid of evaporation** — `IsUnitary.mul`, `IsUnitary.one`, `IsUnitary.conjTranspose`,
  together with the catalog bridge `permMatrix_isUnitary`: products of unitaries are unitary,
  so an arbitrarily long evaporation history stays recoverable iff each step is.

The 2-qubit `SWAP` gate (`swap_isUnitary`, `swap_selfInverse`, `swap_recovery`) instantiates
everything as an explicit, fully-recoverable, decidable toy black hole.

## Results Summary

- `unitary_recovery` — the adjoint decodes radiation back to the infalling state.
- `unitary_preserves_information` — unitary evaporation is injective.
- `information_loss_implies_nonunitary` — information loss forbids unitarity.
- `unitary_iff_recoverable` — unitarity ⇔ universal adjoint-recoverability (the dichotomy).
- `unitary_conj_recovery`, `unitary_conj_preserves_trace` — the mixed-state channel is
  reversible and conserves total probability.
- `unitary_inner_preserve`, `unitary_norm_preserve` — unitary evolution is an isometry.
- `decoder_eq_adjoint`, `decoder_unique` — the recovery map is unique.
- `IsUnitary.mul`, `IsUnitary.one`, `IsUnitary.conjTranspose` — closure (monoid) structure.
- `permMatrix_isUnitary` — every permutation matrix is unitary (catalog bridge).
- `swap_isUnitary`, `swap_recovery`, `swap_selfInverse` — a concrete 2-qubit model.

All results are `sorry`-free and depend only on `propext`, `Classical.choice`, `Quot.sound`.

## Research Directions

### 1. Spectrum invariance and the Page curve
Conjecture: for unitary `U` and density operator `ρ`, the conjugated state `U ρ Uᴴ` has the
same spectrum as `ρ`, hence `tr((U ρ Uᴴ)^k) = tr(ρ^k)` for every `k : ℕ`, and consequently
every spectral functional — purity `tr(ρ²)`, von Neumann entropy, all Rényi entropies — is
conserved. The key insight is that `unitary_conj_preserves_trace` is exactly the `k = 1` case
of a single cyclicity identity `tr((U ρ Uᴴ)^k) = tr(U ρ^k Uᴴ) = tr(ρ^k)`, so the whole
spectrum-invariance result is a clean induction on `k` over the *already proven* trace lemma
rather than new machinery. Why now? `unitary_conj_recovery` and `unitary_conj_preserves_trace`
give the base case and the conjugation algebra for free, and Mathlib's `Matrix.trace_mul_cycle`
already powers the degree-1 proof; lifting it to all powers is the formal seed of the **Page
curve** (the global state stays pure while subsystems thermalize) and directly extends
`Physics/HolevoCapacity.lean`'s entropy machinery.

### 2. Partial trace and "thermal radiation, unitary evolution"
Conjecture: modelling black hole ⊗ radiation as `(Fin a × Fin b → ℂ)`, there exists a unitary
`U` and a pure state `ψ` whose partial trace onto the radiation factor, `tr_B (U |ψ⟩⟨ψ| Uᴴ)`,
is the maximally mixed (thermal) state, even though the global state remains exactly
recoverable by `unitary_recovery`. The key insight is that information is *global, not local*:
recoverability of the full state (already proven) is logically independent of the radiation
subsystem looking maximally entropic, so the apparent paradox dissolves into two compatible
facts. Why now? With full-state recovery in hand, the only missing primitive is a formal
`partialTrace : Matrix (m × k) (m × k) ℂ → Matrix m m ℂ` defined by summing over the traced
index; once defined, the maximally-mixed witness can be produced explicitly from the SWAP /
Bell-state construction already available in this file.

### 3. No-cloning as a corollary of isometry
Conjecture: there is no unitary `U` on `(n → ℂ) ⊗ (n → ℂ)` with a fixed blank `e` such that
`U (ψ ⊗ e) = ψ ⊗ ψ` for *all* `ψ`, because such a `U` would violate inner-product preservation
(`⟪ψ,φ⟫ = ⟪ψ,φ⟫²` forces `⟪ψ,φ⟫ ∈ {0,1}`, impossible for generic non-orthogonal states). The
key insight is that no-cloning is not a new physical law but a direct algebraic consequence of
`unitary_inner_preserve`: the cloning equation applied to two states yields a quadratic
constraint on their overlap that only orthogonal or identical states can satisfy. Why now? The
isometry theorem `unitary_inner_preserve` proved this cycle is precisely the hypothesis the
argument consumes; the remaining work is a two-state inner-product calculation, linking this
file to the error-correction setting of `Physics/StabilizerBounds.lean`.

### 4. The unitary group and the evaporation-history homomorphism
Conjecture: the unitary matrices form a subgroup of `GLₙ(ℂ)`, and the map sending a finite
evaporation history `[U₁, …, U_k]` to its composite `U_k * ⋯ * U₁` is a monoid homomorphism
into that subgroup whose canonical decoder is `U₁ᴴ * ⋯ * U_kᴴ` in reversed order. The key
insight is that the closure lemmas `IsUnitary.one`, `IsUnitary.mul`, and `IsUnitary.conjTranspose`
proven this cycle are exactly the three axioms of a subgroup, so packaging them as a
`Subgroup (GL n ℂ)` (or `Submonoid` plus inverses) is bookkeeping rather than new mathematics.
Why now? The algebraic closure is already established and `permMatrix_isUnitary` shows the
classical permutation group embeds inside it, so this direction concretely bridges to
`Algebra/MatrixGroupGeneration.lean` by exhibiting the unitary group as a generation target.

### 5. Approximate recovery and the Hayden–Preskill stability bound
Conjecture: recovery is robust — if `‖Uᴴ U - 1‖ ≤ ε` (near-unitary evolution) then the recovery
error is controlled, `‖Uᴴ (U ψ) - ψ‖ ≤ ε ‖ψ‖`, so information is *approximately* preserved in
proportion to how close the dynamics are to exactly unitary. The key insight is that the exact
identity `Uᴴ(Uψ) - ψ = (UᴴU - 1)ψ` (a one-line rewrite already implicit in `unitary_recovery`)
converts the abstract recovery statement into a quantitative operator-norm estimate, upgrading
the all-or-nothing dichotomy to a continuous stability statement. Why now? `unitary_recovery`
gives the `ε = 0` endpoint and the rewrite `Uᴴ(Uψ) - ψ = (UᴴU - 1)ψ` is the entire content of
the bound; with Mathlib's `Matrix` operator-norm API this becomes the formal analogue of the
**Hayden–Preskill** "information escapes a perturbed black hole" result.
