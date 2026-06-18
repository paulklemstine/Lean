Develop a self-contained Lean 4 formalization in proof complexity, centered on the concrete theorem that for every `k ≥ 1` there exists a p-degree strictly between `powSystem k` and `powSystem (k+1)`. Work in the domain already established by `SimulationPreorder`, `SimulationDegrees`, and `DegreeLattice`, and do not mix in the previous spectral-gap/Hodge-Laplacian storyline unless it is directly reused as a formal dependency.

Target file: `Catalog/Logic/ProofComplexity/LadderDensity.lean`.

Mathematical objective:
1. Define an explicit witness `interPowSys k`, ideally via a parity-based size function that uses the upper growth rate on even inputs and the lower growth rate on odd inputs.
2. Prove a lower separation theorem showing `powSystem k < interPowSys k` for all relevant `k` (or with the exact side conditions required by the existing ladder theory).
3. Prove an upper separation theorem showing `interPowSys k < powSystem (k+1)`.
4. Bundle these into an existential theorem such as `exists_strictly_between_powSystem : ∀ k ≥ 1, ∃ S, powSystem k < S ∧ S < powSystem (k+1)`.
5. If the proof naturally factors through a general domination/gluing principle, isolate that as a reusable lemma, but only if it materially simplifies the final development.

Required standards:
- The file must be sorry-free and compile against the existing catalog.
- State all theorem hypotheses precisely; do not rely on informal phrases like “all large n” without a formal quantified lemma.
- Prefer exact reuse of existing notions and order relations from the proof-complexity catalog rather than introducing parallel abstractions.
- Include concise module documentation explaining the construction and the proof idea, but keep claims aligned with what is actually formalized.

Why this revision: the previous attempt appears mathematically promising but was presented as a truncated, mixed artifact. This cycle should narrow to one falsifiable theorem package whose completeness can be directly audited. The key insight is that parity-gluing should create a genuine intermediate degree between consecutive ladder rungs by preserving enough upper-growth behavior to beat the lower rung while leaving infinitely many sparse inputs that block domination of the upper rung. Why now? The catalog already seems to contain the exact ingredients needed: the ladder systems `powSystem k`, the simulation preorder framework, and gap lemmas strong enough to choose witnesses of prescribed parity.

Deliverables:
- A complete Lean file with the definitions and theorems above.
- Clear final theorem names and statements suitable for reuse in future density/order-type developments.
- No unrelated appendices or concatenated experimental code.