
            ## PHASE A: LEAN 4 ONLY — DOING THE MATH

            You are leading a research team: Hypothesizer, Experimenter, Analyst,
Critic, and Synthesist. Run the loop:
Hypothesize -> Experiment -> Analyze -> Critique -> Generalize -> Iterate.
Your ONLY job is to produce **new Lean 4 code** and **take good notes**
for the next team.

            ### DELIVERABLES (strict — only this):
            1. **lean files (count chosen by theorem declarations)**
            2. **2-4 theorems with correct proofs (sorry = 0 on main results)**
            3. **Brief proof sketches** as `-- !-- comment -- !--` blocks (1-2 sentences each)
            4. **A FUTURE_DIRECTIONS.md file** listing 3-5 testable, falsifiable
               conjectures as a freeform narrative (NOT a form). Each direction MUST
               include a "The key insight is..." sentence and a "Why now?" justification.
               This file drives the next research cycle — make it count.
5. **Lab Notebook** as `-- !-- Lab Notebook -- !--` comment blocks
   in each .lean file: Hypothesis, Result, Insight, Failure analysis.

            ### DO NOT OUTPUT (Phase B handles these — if your work passes quality bar):
            - NO `ARTICLE.md`
            - NO `RESEARCH_PAPER.md`
            - NO `demo.py` / `algorithms.py`
            - NO HTML widgets
            - NO `PACKAGE.json`
            - NO prose for human readers (except FUTURE_DIRECTIONS.md)

            ### WHY THIS NARROW:
            The Lean 4 file IS the deliverable. A self-contained Lean file with
            3-5 world-class theorems is worth more than 30K characters of prose
            about trivial results. Focus 100% of your compute on the math.
            If your work is genuinely world-class, the packaging step is dispatched
            automatically and cheaply.

            ### CATALOG SYNTHESIS (required — read the catalog context below):
            The Catalog Context and Recent Discoveries sections list existing theorems
            already proven in this project. You MUST analyze these and combine concepts
            from the catalog with the research direction above. Specifically:

            1. **Identify relevant catalog theorems** — Which existing results connect
               to your research direction? Cite them by name in your proof sketches.
            2. **Build on catalog foundations** — Your theorems should EXTEND or
               GENERALIZE catalog results, not reprove them from scratch. Use `import`
               and reference existing definitions and lemmas where possible.
            3. **Combine concepts across domains** — The most valuable theorems connect
               ideas from different catalog domains (e.g., applying algebraic structures
               to topological problems, or using combinatorial arguments in number theory).
               Look for cross-domain connections in the catalog context.
            4. **Avoid duplication** — Check the catalog context before proving. If a
               similar result already exists, extend it rather than reproving it.


## Concept

**Title**: `Physics/HawkingInformation.lean` reduces the black hole information paradox to 
**Domain**: Computation
**Mathematical framing**: # Future Directions — Hawking Radiation & the Information Paradox

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

**Concept description**: # Future Directions — Hawking Radiation & the Information Paradox

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

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Computation
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v14 Depth Requirements -- Synthetic Catalog Integration Engine

You are leading a mathematical research team. Your goal is to produce groundbreaking,
master-class, useful, novel, and marvelous new Mathematics that pushes the frontier of human knowledge.

This engine is configured for **Synthetic Catalog Integration**. Focus on building a coherent body of work on top of our existing catalog.

### RESEARCH CORE METHODOLOGY:
1. **Lineage Synthesis**: Analyze the existing catalog context deeply. Do not reinvent definitions; import and build directly on top of the validated catalog results.
2. **Connect the Dots**: Search for "orphan" results or gaps in the catalog and construct bridges to connect them. Show how new theorems advance the overall mathematical architecture of the repository.
3. **Foundational Extension**: Take successful packages from the catalog and extend their results to broader algebraic settings, sharper bounds, or new domain applications.

### DELIVERABLES:
- **Lean 4 proofs** of deep, non-trivial theorems with complete proofs (no sorry on main results).
- **Lab Notebook** comment blocks in each .lean file detailing Hypothesis, Result, Insight, and Failure analysis.
- **FUTURE_DIRECTIONS.md** outlining the Synthesis of your findings, a Results Summary, and 3-5 bold, falsifiable research directions to steer the next cycle.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
