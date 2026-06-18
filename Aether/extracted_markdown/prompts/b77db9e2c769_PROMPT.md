
            ## PHASE A: LEAN 4 ONLY — DOING THE MATH

            You are a world-class mathematician. Your ONLY job in this cycle is
to produce **new Lean 4 code that extends the frontier of mathematics**.

            ### DELIVERABLES (strict — only this):
            1. **lean files (count chosen by the Plan)**
            2. **2-4 theorems with correct proofs (sorry = 0 on main results)**
            3. **Brief proof sketches** as `-- !-- comment -- !--` blocks (1-2 sentences each)
            4. **A FUTURE_DIRECTIONS.md file** listing 3-5 testable, falsifiable
               conjectures as a freeform narrative (NOT a form). Each direction MUST
               include a "The key insight is..." sentence and a "Why now?" justification.
               This file drives the next research cycle — make it count.

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

**Title**: The natural next step is to formalize the Turaev-Viro state sum construction its
**Domain**: Novelty
**Mathematical framing**: # Future Directions: Quantum Gravity as Topological Quantum Field Theory

## 1. Turaev-Viro State Sum Invariance

The natural next step is to formalize the Turaev-Viro state sum construction itself. Given a fusion system `F` and a triangulation `T` of a closed 3-manifold, define the partition function `Z(T) = Σ (colorings) Π (6j-symbols)` and prove it is independent of the triangulation (invariance under Pachner moves). The key insight is that the pentagon equation for the fusion system — which we have already axiomatized as the `associativity` field — is precisely the algebraic identity that ensures invariance under the 2-3 Pachner move. Why now? Our formalization of fusion systems provides the exact algebraic data needed; what remains is the combinatorial machinery of triangulations and Pachner moves, which is largely independent of TQFT-specific content.

## 2. Modular S-Matrix and the Full Verlinde Formula

Our current formalization proves that quantum dimensions form a simultaneous eigenvector of the fusion matrices. The full Verlinde formula goes further: it asserts the existence of a unitary matrix `S` that simultaneously diagonalizes all fusion matrices, with `N_{ij}^k = Σ_l S_{il} S_{jl} S*_{kl} / S_{0l}`. The key insight is that the fusion matrices form a commutative semisimple algebra over ℝ (commutativity is our Theorem 1), so simultaneous diagonalization is guaranteed by the spectral theorem for commuting normal matrices. Why now? Mathlib has the spectral theorem for normal operators on finite-dimensional inner product spaces, and our commutativity result provides the critical prerequisite.

## 3. Mapping Class Group Representations and Unitarity

For a genus-g surface Σ_g, the TQFT assigns a finite-dimensional Hilbert space V(Σ_g) on which the mapping class group MCG(Σ_g) acts by unitary transformations. The conjecture is: formalize the MCG action via Dehn twist generators and prove unitarity using the inner product induced by the quantum trace. The key insight is that the MCG representation factors through the representation of the Temperley-Lieb or Hecke algebra, and unitarity follows from the positivity of quantum dimensions (which we have axiomatized as `qdim_positive`). Why now? The algebraic framework is in place; the main gap is formalizing the Dehn twist action in terms of fusion data, which requires only the 6j-symbols and braiding structure beyond what we have.

## 4. Crane-Yetter Extension to 4D and State Sum Models

The Turaev-Viro theory lives in 3 dimensions. The Crane-Yetter state sum extends it to 4 dimensions using a modular tensor category. The conjecture to test: the Crane-Yetter partition function on a closed 4-manifold depends only on the signature and Euler characteristic, and equals `D^{3σ+χ}` where `D` is the global dimension. The key insight is that this formula reduces to checking invariance under the 4D Pachner moves (1-5, 2-4, 3-3), which in turn reduce to algebraic identities in the fusion system that generalize our associativity axiom. Why now? Our `globalDimSq_pos` theorem and the fusion system framework provide the foundation; the 4D extension is a natural and falsifiable generalization.

## 5. Quantum Double Construction and Kitaev Models

Given a finite group G, the quantum double D(G) is a Hopf algebra whose representation category is a modular tensor category. The conjecture: formalize that D(G) yields a fusion system where the fusion coefficients equal the structure constants of the center of the group algebra Z(ℂ[G]), and the global dimension squared equals |G|². The key insight is that this provides a concrete, computable instantiation of our abstract fusion system axioms, and connects to Kitaev's toric code model of topological quantum computation. Why now? Mathlib has extensive support for finite groups, group algebras, and representation theory — the ingredients needed to construct D(G) are largely available, making this a high-feasibility target for connecting our abstract framework to concrete examples.

**Concept description**: # Future Directions: Quantum Gravity as Topological Quantum Field Theory

## 1. Turaev-Viro State Sum Invariance

The natural next step is to formalize the Turaev-Viro state sum construction itself. Given a fusion system `F` and a triangulation `T` of a closed 3-manifold, define the partition function `Z(T) = Σ (colorings) Π (6j-symbols)` and prove it is independent of the triangulation (invariance under Pachner moves). The key insight is that the pentagon equation for the fusion system — which we have already axiomatized as the `associativity` field — is precisely the algebraic identity that ensures invariance under the 2-3 Pachner move. Why now? Our formalization of fusion systems provides the exact algebraic data needed; what remains is the combinatorial machinery of triangulations and Pachner moves, which is largely independent of TQFT-specific content.

## 2. Modular S-Matrix and the Full Verlinde Formula

Our current formalization proves that quantum dimensions form a simultaneous eigenvector of the fusion matrices. The full Verlinde formula goes further: it asserts the existence of a unitary matrix `S` that simultaneously diagonalizes all fusion matrices, with `N_{ij}^k = Σ_l S_{il} S_{jl} S*_{kl} / S_{0l}`. The key insight is that the fusion matrices form a commutative semisimple algebra over ℝ (commutativity is our Theorem 1), so simultaneous diagonalization is guaranteed by the spectral theorem for commuting normal matrices. Why now? Mathlib has the spectral theorem for normal operators on finite-dimensional inner product spaces, and our commutativity result provides the critical prerequisite.

## 3. Mapping Class Group Representations and Unitarity

For a genus-g surface Σ_g, the TQFT assigns a finite-dimensional Hilbert space V(Σ_g) on which the mapping class group MCG(Σ_g) acts by unitary transformations. The conjecture is: formalize the MCG action via Dehn twist generators and prove unitarity using the inner product induced by the quantum trace. The key insight is that the MCG representation factors through the representation of the Temperley-Lieb or Hecke algebra, and unitarity follows from the positivity of quantum dimensions (which we have axiomatized as `qdim_positive`). Why now? The algebraic framework is in place; the main gap is formalizing the Dehn twist action in terms of fusion data, which requires only the 6j-symbols and braiding structure beyond what we have.

## 4. Crane-Yetter Extension to 4D and State Sum Models

The Turaev-Viro theory lives in 3 dimensions. The Crane-Yetter state sum extends it to 4 dimensions using a modular tensor category. The conjecture to test: the Crane-Yetter partition function on a closed 4-manifold depends only on the signature and Euler characteristic, and equals `D^{3σ+χ}` where `D` is the global dimension. The key insight is that this formula reduces to checking invariance under the 4D Pachner moves (1-5, 2-4, 3-3), which in turn reduce to algebraic identities in the fusion system that generalize our associativity axiom. Why now? Our `globalDimSq_pos` theorem and the fusion system framework provide the foundation; the 4D extension is a natural and falsifiable generalization.

## 5. Quantum Double Construction and Kitaev Models

Given a finite group G, the quantum double D(G) is a Hopf algebra whose representation category is a modular tensor category. The conjecture: formalize that D(G) yields a fusion system where the fusion coefficients equal the structure constants of the center of the group algebra Z(ℂ[G]), and the global dimension squared equals |G|². The key insight is that this provides a concrete, computable instantiation of our abstract fusion system axioms, and connects to Kitaev's toric code model of topological quantum computation. Why now? Mathlib has extensive support for finite groups, group algebras, and representation theory — the ingredients needed to construct D(G) are largely available, making this a high-feasibility target for connecting our abstract framework to concrete examples.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Novelty
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v7 Depth Requirements — Structured Proofs with Completeness Gates

You are producing Lean 4 code on the mathematical frontier. Your output must
be COMPILABLE and your proofs must be COMPLETE. A single correct proof of a
non-trivial result is worth more than 5 theorems with `sorry`.

### STEP 1: THEOREM DECLARATIONS (required — before any code)

List every theorem you intend to prove. For each, state:
- **Name**: The Lean declaration name
- **Statement**: One-sentence informal statement
- **Status**: `proved` | `conjecture` | `proved_with_lemma_sorry`
- **Why non-trivial**: One sentence on the key mathematical insight

Example:
1. `cantorPairing_surjective`: Cantor pairing is surjective — proved — constructive inverse
2. `cantorPairing_injective`: Cantor pairing is injective — proved — diagonal argument
3. `cantorPairing_bijection`: Cantor pairing is a bijection — proved_with_lemma_sorry — follows from 1+2

### STEP 2: PROVE THEOREMS (completeness gate)

Every theorem declared as `proved` MUST have a complete, compiling Lean proof.
No `sorry` on the main result. If you cannot complete a proof, change its status
to `conjecture` or `proved_with_lemma_sorry` and explain why.

For `proved_with_lemma_sorry`:
- The theorem statement must be complete (no sorry in the statement)
- `sorry` is allowed ONLY in supporting lemmas, never the main proof
- A comment must explain what the sorry replaces and why it's deferred

For your BEST theorem, also provide:
- A generalization or strengthening (can use sorry if proving would take too long)
- A boundary case or counterexample showing where the result fails

### STEP 3: Anti-patterns (reject these)

These tactics indicate trivial proofs:
- `native_decide` / `decide` / `norm_num` / `rfl` — unless genuinely proving a numeric fact
- `simp only []` with no simp set specified
- `sorry` on any theorem declared as `proved`

`omega`, `linarith`, and `Aesop` are fine for supporting lemmas.
`sorry` is fine for conjectures and generalizations.

### STEP 4: Novelty

Your theorems must be genuinely new. If a statement appears in a textbook,
generalize it. If you cannot formalize a concept rigorously, pick a different topic.

### Output format

Your output must include:
1. `.lean` files with the proofs (structured as declared in Step 1)
2. `FUTURE_DIRECTIONS.md` with 3-5 research conjectures extending the work

Both are required. Missing FUTURE_DIRECTIONS.md = automatic quality penalty.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
