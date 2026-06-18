
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

**Title**: Formalize Baker–Norine's tropical Riemann-Roch theorem: for a divisor D on a met
**Domain**: Bridges
**Mathematical framing**: # Future Directions: Tropical Brill–Noether Theory

## 1. Full Tropical Riemann-Roch Theorem

Formalize Baker–Norine's tropical Riemann-Roch theorem: for a divisor D on a metric graph Γ of genus g, r(D) − r(K − D) = deg(D) − g + 1 where K is the canonical divisor of degree 2g−2. The key insight is that our `chipFiring_degree_invariant` and `Divisor` infrastructure already provides the chip-firing foundation — the remaining challenge is formalizing q-reduced divisors and the Dhar burning algorithm as a certified decision procedure for rank computation. Why now? The existing `chipFire`/`Divisor.degree` formalization handles the low-level graph combinatorics, and the Serre duality `rho_serre_duality` already captures the expected dimension identity at the BN-number level.

## 2. CDPR Lattice Path Characterization with Genericity

Extend the allocation/tableau equivalence to a full lattice-path characterization on metric chains of loops with generic edge lengths. The key insight is that our `CDPRAllocation` structure exactly encodes the endpoint of a Weyl-chamber walk, and the generic-edge-length condition (formalized as `MetricChainOfLoops.IsGeneric` in `Defs.lean`) should ensure a bijection between rank-r divisors and lattice paths staying in the Weyl chamber. Why now? Both the allocation existence theorem (`allocation_iff_rho_nonneg`) and the Weyl chamber machinery (`InWeylChamber`, `initialState_inWeylChamber`) are fully formalized, so the missing piece is the geometric injection from divisor classes to lattice paths.

## 3. Tropical Abel-Jacobi and Jacobian Structure

Formalize the tropical Jacobian J(Γ) = ℝ^g / Λ as a real torus and prove the Abel-Jacobi theorem: the chip-firing equivalence classes of degree-0 divisors on Γ form a group isomorphic to J(Γ). The key insight is that `chipFiring_degree_invariant` proves the degree is well-defined on equivalence classes, and the quotient ℝ^g/Λ structure should follow from the cycle space of the graph. Why now? The chip-firing formalization is complete and degree-invariant, providing the algebraic foundation; the Jacobian construction requires only the lattice quotient machinery already available in Mathlib (`AddCircle`, `ZSpan`).

## 4. Effective Brill-Noether via Displacement Tableaux Counting

Prove that the number of CDPR displacement tableaux of shape (r+1) × (g−d+r) with entries in {0,...,g−1} equals the number of standard Young tableaux of the corresponding shape, establishing a bijection with the Robinson-Schensted correspondence. The key insight is that `displacementTableau_exists_iff` reduces existence to a cardinality bound, but the exact count should match the hook-length formula — connecting tropical geometry to enumerative combinatorics. Why now? The tableau infrastructure (`DisplacementTableau`, row-strictness, injectivity) is complete, and Mathlib's `Fintype.card` machinery can support explicit counting arguments.

## 5. Specialization to Algebraic Geometry via Berkovich Analytification

Strengthen the `SpecializationDatum` interface to capture the full content of Baker's specialization lemma: for a smooth proper curve X over a discretely-valued field with stable reduction, the tropicalization map trop: Div(X) → Div(Γ) satisfies rank(trop(D)) ≥ rank(D). The key insight is that the abstract interface already proves `specialization_preserves_existence`, but a concrete instantiation using Berkovich skeleta would give a machine-verified bridge between algebraic and tropical Brill-Noether theory. Why now? The abstract interface is proven and ready for instantiation; the main barrier is formalizing enough valuation theory and stable reduction to construct the concrete specialization map.

**Concept description**: # Future Directions: Tropical Brill–Noether Theory

## 1. Full Tropical Riemann-Roch Theorem

Formalize Baker–Norine's tropical Riemann-Roch theorem: for a divisor D on a metric graph Γ of genus g, r(D) − r(K − D) = deg(D) − g + 1 where K is the canonical divisor of degree 2g−2. The key insight is that our `chipFiring_degree_invariant` and `Divisor` infrastructure already provides the chip-firing foundation — the remaining challenge is formalizing q-reduced divisors and the Dhar burning algorithm as a certified decision procedure for rank computation. Why now? The existing `chipFire`/`Divisor.degree` formalization handles the low-level graph combinatorics, and the Serre duality `rho_serre_duality` already captures the expected dimension identity at the BN-number level.

## 2. CDPR Lattice Path Characterization with Genericity

Extend the allocation/tableau equivalence to a full lattice-path characterization on metric chains of loops with generic edge lengths. The key insight is that our `CDPRAllocation` structure exactly encodes the endpoint of a Weyl-chamber walk, and the generic-edge-length condition (formalized as `MetricChainOfLoops.IsGeneric` in `Defs.lean`) should ensure a bijection between rank-r divisors and lattice paths staying in the Weyl chamber. Why now? Both the allocation existence theorem (`allocation_iff_rho_nonneg`) and the Weyl chamber machinery (`InWeylChamber`, `initialState_inWeylChamber`) are fully formalized, so the missing piece is the geometric injection from divisor classes to lattice paths.

## 3. Tropical Abel-Jacobi and Jacobian Structure

Formalize the tropical Jacobian J(Γ) = ℝ^g / Λ as a real torus and prove the Abel-Jacobi theorem: the chip-firing equivalence classes of degree-0 divisors on Γ form a group isomorphic to J(Γ). The key insight is that `chipFiring_degree_invariant` proves the degree is well-defined on equivalence classes, and the quotient ℝ^g/Λ structure should follow from the cycle space of the graph. Why now? The chip-firing formalization is complete and degree-invariant, providing the algebraic foundation; the Jacobian construction requires only the lattice quotient machinery already available in Mathlib (`AddCircle`, `ZSpan`).

## 4. Effective Brill-Noether via Displacement Tableaux Counting

Prove that the number of CDPR displacement tableaux of shape (r+1) × (g−d+r) with entries in {0,...,g−1} equals the number of standard Young tableaux of the corresponding shape, establishing a bijection with the Robinson-Schensted correspondence. The key insight is that `displacementTableau_exists_iff` reduces existence to a cardinality bound, but the exact count should match the hook-length formula — connecting tropical geometry to enumerative combinatorics. Why now? The tableau infrastructure (`DisplacementTableau`, row-strictness, injectivity) is complete, and Mathlib's `Fintype.card` machinery can support explicit counting arguments.

## 5. Specialization to Algebraic Geometry via Berkovich Analytification

Strengthen the `SpecializationDatum` interface to capture the full content of Baker's specialization lemma: for a smooth proper curve X over a discretely-valued field with stable reduction, the tropicalization map trop: Div(X) → Div(Γ) satisfies rank(trop(D)) ≥ rank(D). The key insight is that the abstract interface already proves `specialization_preserves_existence`, but a concrete instantiation using Berkovich skeleta would give a machine-verified bridge between algebraic and tropical Brill-Noether theory. Why now? The abstract interface is proven and ready for instantiation; the main barrier is formalizing enough valuation theory and stable reduction to construct the concrete specialization map.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Bridges
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
