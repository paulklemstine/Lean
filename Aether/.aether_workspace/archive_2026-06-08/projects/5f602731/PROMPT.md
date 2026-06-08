            ## Assignment: **Hypothesis:** The planar tropical Bézout formalization can be extended to a ce

            Prove new, non-trivial theorems. Build on catalog theorems. Minimize sorry.

            ### Research Direction
            # Future Directions

## 1. Tropical Bernstein Theorem in Lean

**Hypothesis:** The planar tropical Bézout formalization can be extended to a certified tropical Bernstein theorem where stable intersection multiplicity equals mixed area of Newton polygons for all generic bivariate tropical polynomials, including sparse systems.

**Test:** Formalize a computable 2D lattice convex hull algorithm and mixed area computation for arbitrary lattice polygons. Verify the mixed area equals the mixed lattice index on at least five non-simplex Newton polygon pairs (e.g., rectangles, trapezoids, L-shapes). Prove the equality MixedArea(ConvHull(A), ConvHull(B)) = MixedLatticeIndex(ConvHull(A), ConvHull(B)) for arbitrary convex lattice polygons using a formal Pick's theorem.

**Potential falsifier:** A formal obstruction in the lattice-point encoding of convex hulls prevents efficient computation of mixed areas for non-convex support sets, or the mixed lattice index formula fails to equal the geometric mixed area for degenerate polygon pairs where boundary lattice points have non-trivial gcd structure.

---

## 2. Valuated Matroid Intersection Shadow

**Hypothesis:** Tropical stable intersection data of hypersurfaces can be recast via valuated matroid intersection in a way that simplifies multiplicity proofs and enables a more algebraic formalization path.

**Test:** Define a finite valuated matroid model for tropical lines (rank 2) and tropical conics (rank 3) over a finite ground set. Compute the valuated matroid intersection product and compare multiplicity outputs against the determinant-based local intersection formula on explicit examples with d₁ = d₂ = 2. Verify agreement on at least three generic coefficient choices.

**Potential falsifier:** The valuated matroid model fails to recover local multiplicities even in generic transverse rank-2 cases, because the matroid intersection product captures only the combinatorial type of the intersection, not the metric data encoded in edge weights.

---

## 3. Certified Root Counting via Tropicalization

**Hypothesis:** A restricted tropicalization-preserves-intersection theorem can be used to certify algebraic root-counting bounds for sparse bivariate systems over valued fields, at least for polynomials over ℚ with the p-adic valuation.

**Test:** Implement tropicalization for bivariate polynomials over ℚ_p (or a formal approximation thereof) for primes p = 2, 3, 5. For at least five sparse polynomial systems with known root counts (computable via resultants), verify that the tropical intersection count matches the algebraic root count. Formalize the comparison for at least one explicit system in Lean 4.

**Potential falsifier:** The tropical count systematically overcounts due to missing genericity hypotheses not capturable in the formal model — specifically, if the coefficients lie on a tropical discriminant locus where the tropicalization map has non-trivial fiber structure, the tropical count exceeds the algebraic count even for "generic-looking" inputs.

---

## 4. Tropical Hodge–Intersection Bridge

**Hypothesis:** The mixed lattice index formalization can be extended to define a tropical intersection pairing on finite-dimensional tropical cycle spaces, yielding a verified positivity statement (nonnegativity of self-intersection for effective cycles) that mirrors the Hodge index theorem.

**Test:** Define a tropical cycle space for balanced weighted graphs in ℝ² with at most N vertices (for small N ≤ 10). Define the intersection pairing via the mixed lattice index of dual Newton subdivisions. Prove nonnegativity of the pairing for effective tropical divisors on at least three explicit tropical curves of genus ≤ 2.

**Potential falsifier:** The intersection pairing defined via mixed lattice index fails to be well-defined on tropical cycle equivalence classes because the mixed lattice index is not invariant under tropical rational equivalence of divisors. This would manifest as two rationally equivalent divisors having different self-intersection numbers.

---

## 5. Mixed Volume Monotonicity via Lattice Compression

**Hypothesis:** The inequality MixedLatticeIndex(A, B) ≤ d₁ · d₂ for A ⊆ Δ_{d₁}, B ⊆ Δ_{d₂} (where A, B are the complete lattice point sets of convex subpolygons) can be proved by a combinatorial compression argument that reduces arbitrary convex subsets to degree simplices while monotonically increasing the mixed lattice index.

**Test:** Define a "lattice compression" operation that, given a convex lattice polygon P ⊊ Δ_d, produces a strictly larger convex lattice polygon P' with P ⊊ P' ⊆ Δ_d such that MixedLatticeIndex(P, Q) ≤ MixedLatticeIndex(P', Q) for all convex Q. Verify computationally for all convex sublattice polygons of Δ_d with d ≤ 5 that repeated compression converges to Δ_d.

**Potential falsifier:** No single-step compression operation exists that simultaneously increases the mixed lattice index with respect to ALL possible second arguments Q. This would mean monotonicity requires a global argument (such as Aleksandrov-Fenchel) rather than a local compression step, making the combinatorial approach infeasible.


            ### Mathematical Framing
            # Future Directions

## 1. Tropical Bernstein Theorem in Lean

**Hypothesis:** The planar tropical Bézout formalization can be extended to a certified tropical Bernstein theorem where stable intersection multiplicity equals mixed area of Newton polygons for all generic bivariate tropical polynomials, including sparse systems.

**Test:** Formalize a computable 2D lattice convex hull algorithm and mixed area computation for arbitrary lattice polygons. Verify the mixed area equals the mixed lattice index on at least five non-simplex Newton polygon pairs (e.g., rectangles, trapezoids, L-shapes). Prove the equality MixedArea(ConvHull(A), ConvHull(B)) = MixedLatticeIndex(ConvHull(A), ConvHull(B)) for arbitrary convex lattice polygons using a formal Pick's theorem.

**Potential falsifier:** A formal obstruction in the lattice-point encoding of convex hulls prevents efficient computation of mixed areas for non-convex support sets, or the mixed lattice index formula fails to equal the geometric mixed area for degenerate polygon pairs where boundary lattice points have non-trivial gcd structure.

---

## 2. Valuated Matroid Intersection Shadow

**Hypothesis:** Tropical stable intersection data of hypersurfaces can be recast via valuated matroid intersection in a way that simplifies multiplicity proofs and enables a more algebraic formalization path.

**Test:** Define a finite valuated matroid model for tropical lines (rank 2) and tropical conics (rank 3) over a finite ground set. Compute the valuated matroid intersection product and compare multiplicity outputs against the determinant-based local intersection formula on explicit examples with d₁ = d₂ = 2. Verify agreement on at least three generic coefficient choices.

**Potential falsifier:** The valuated matroid model fails to recover local multiplicities even in generic transverse rank-2 cases, because the matroid intersection product captures only the combinatorial type of the intersection, not the metric data encoded in edge weights.

---

## 3. Certified Root Counting via Tropicalization

**Hypothesis:** A restricted tropicalization-preserves-intersection theorem can be used to certify algebraic root-counting bounds for sparse bivariate systems over valued fields, at least for polynomials over ℚ with the p-adic valuation.

**Test:** Implement tropicalization for bivariate polynomials over ℚ_p (or a formal approximation thereof) for primes p = 2, 3, 5. For at least five sparse polynomial systems with known root counts (computable via resultants), verify that the tropical intersection count matches the algebraic root count. Formalize the comparison for at least one explicit system in Lean 4.

**Potential falsifier:** The tropical count systematically overcounts due to missing genericity hypotheses not capturable in the formal model — specifically, if the coefficients lie on a tropical discriminant locus where the tropicalization map has non-trivial fiber structure, the tropical count exceeds the algebraic count even for "generic-looking" inputs.

---

## 4. Tropical Hodge–Intersection Bridge

**Hypothesis:** The mixed lattice index formalization can be extended to define a tropical intersection pairing on finite-dimensional tropical cycle spaces, yielding a verified positivity statement (nonnegativity of self-intersection for effective cycles) that mirrors the Hodge index theorem.

**Test:** Define a tropical cycle space for balanced weighted graphs in ℝ² with at most N vertices (for small N ≤ 10). Define the intersection pairing via the mixed lattice index of dual Newton subdivisions. Prove nonnegativity of the pairing for effective tropical divisors on at least three explicit tropical curves of genus ≤ 2.

**Potential falsifier:** The intersection pairing defined via mixed lattice index fails to be well-defined on tropical cycle equivalence classes because the mixed lattice index is not invariant under tropical rational equivalence of divisors. This would manifest as two rationally equivalent divisors having different self-intersection numbers.

---

## 5. Mixed Volume Monotonicity via Lattice Compression

**Hypothesis:** The inequality MixedLatticeIndex(A, B) ≤ d₁ · d₂ for A ⊆ Δ_{d₁}, B ⊆ Δ_{d₂} (where A, B are the complete lattice point sets of convex subpolygons) can be proved by a combinatorial compression argument that reduces arbitrary convex subsets to degree simplices while monotonically increasing the mixed lattice index.

**Test:** Define a "lattice compression" operation that, given a convex lattice polygon P ⊊ Δ_d, produces a strictly larger convex lattice polygon P' with P ⊊ P' ⊆ Δ_d such that MixedLatticeIndex(P, Q) ≤ MixedLatticeIndex(P', Q) for all convex Q. Verify computationally for all convex sublattice polygons of Δ_d with d ≤ 5 that repeated compression converges to Δ_d.

**Potential falsifier:** No single-step compression operation exists that simultaneously increases the mixed lattice index with respect to ALL possible second arguments Q. This would mean monotonicity requires a global argument (such as Aleksandrov-Fenchel) rather than a local compression step, making the combinatorial approach infeasible.



            ### Existing Verified Theorems
            Existing theorems you can build on:
  1. `picard_rank_one_all_hodge_classes_are_multiples` : theorem picard_rank_one_all_hodge_classes_are_multiples
     (file: FINAL/MachineLearning/RankOne.lean)
  2. `picard_rank_one_all_hodge_classes_are_multiples` : theorem picard_rank_one_all_hodge_classes_are_multiples
     (file: MachineLearning/FormalHodge/RankOne.lean)
  3. `exists_not_encoded_by_small_index` : theorem exists_not_encoded_by_small_index
     (file: Bridges/FiniteDescriptionComplexity.lean)
  4. `exists_not_encoded_by_small_index` : theorem exists_not_encoded_by_small_index
     (file: FINAL/Bridges/FiniteDescriptionComplexity.lean)
  5. `exists_bounded_cycle_mean_le` : theorem exists_bounded_cycle_mean_le {n k : ℕ}
     (file: Speculative/AutoResearch/CycleEigenvalue.lean)

### Previously Proved Theorems
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


No specific files referenced. Use Mathlib and general knowledge.

            ---

            You are Aristotle. Pursue this research direction deeply and originally.
            Discover what matters. Prove what you can. Define what needs defining.
            Build on the catalog theorems referenced above.

            Use concrete types (Nat, Real, Finset, Matrix). Avoid trivial tautologies.
            If a direct proof fails, try the contrapositive, a constructive witness,
            or structural induction. Connect to at least one other domain for impact.

            ### Team Directive
            Create a team to conduct research, brainstorm testable hypotheses,
            run experiments to confirm or refute them, validate data,
            update knowledge base and iterate forever.

            Required: Lean 4 proofs, FUTURE_DIRECTIONS.md
            Optional: ARTICLE.md, RESEARCH_PAPER.md, demo.py

            FUTURE_DIRECTIONS.md is critical — it drives the next research cycle.
            Each direction must be a testable scientific hypothesis: a precise,
            falsifiable conjecture with a clear test that could confirm or refute it.
            Format each as:

            ### [Direction Title]
            **Conjecture**: A precise mathematical statement that can be proved or disproved.
            **Test**: What specific experiment, calculation, or proof attempt would
            confirm or refute this conjecture.
            **Impact**: If true, what new territory does this open? If false, what
            does the failure teach us?
            **Cross-domain**: Which other domains could this connect to?

            Do real science. Propose hypotheses that are bold enough to matter and
            specific enough to fail. Vague explorations like "study X further" or
            "extend Y" are not hypotheses — they are homework. Give us ideas that
            could change how we think about the problem.


### WHAT WE NEED FROM YOU

You are a world-class mathematician, software engineer, and science writer.
Use your judgment on the best way to organize and present your work.
We need ALL of the following deliverables:

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 1 — Formally verified mathematics (Lean 4)
────────────────────────────────────────────────────────────────────────────
- Prove non-trivial theorems with complete proofs (no `sorry` in the final result)
- Organize the code however makes sense — one file or several,
  whatever serves the mathematics best
- Use doc comments to explain the significance of key results

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 2 — Standalone Popular-Science ARTICLE  →  ARTICLE.md
────────────────────────────────────────────────────────────────────────────
Write a **superb, standalone magazine-quality article** about this research.

CRITICAL RULES FOR THE ARTICLE:
• Do NOT mention "Scientific American", "Sci Am", or "Lean" anywhere.
• Do NOT mention "Lean", "Lean 4", "formal verification", or "proof assistant".
• This is a POPULAR SCIENCE article for a curious, intelligent audience.
  Write it as if it will be published in a premier science magazine.
• The reader should come away saying "Wow, I had no idea math could do THAT."

ARTICLE QUALITY STANDARDS:
• **Superb writing**: Vivid, engaging prose. Strong opening hook. Narrative arc.
  Use concrete analogies and metaphors that make abstract ideas tangible.
• **Depth without jargon**: Explain the IDEAS, not the formalism.
  A reader with a college education should understand and enjoy every paragraph.
• **Story structure**: Open with a provocative question or surprising fact.
  Build tension. Reveal the breakthrough. Show why it matters.
• **Real-world connections**: Connect to technology, nature, everyday life.
  Why should a non-mathematician care about this?
• **Historical context**: Place the discovery in the sweep of intellectual history.
  Who tried this before? What barriers stood in the way?
• **Length**: 1500–3000 words. Substantial but not padded.
• **Standalone**: The article must make complete sense on its own.
  No references to "the proof above" or "our formal verification."

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 3 — Comprehensive RESEARCH PAPER  →  RESEARCH_PAPER.md
────────────────────────────────────────────────────────────────────────────
Write a **thorough, in-depth research paper** that a mathematician or
graduate student would find valuable. This is NOT a summary — it is a
complete, publishable-quality paper.

RESEARCH PAPER REQUIREMENTS:
• **Abstract**: Concise summary of contributions and significance.
• **Introduction**: Motivation, context, relationship to prior work.
• **Definitions & Notation**: Precise mathematical setup.
• **Main Results**: Full theorem statements with detailed proof sketches.
  Include the key ideas, not just "by induction."
• **Algorithms**: If the work produces algorithms, include complete
  pseudocode with complexity analysis (time, space, convergence).
• **Applications**: Concrete applications with worked examples.
  Show HOW to use the results in practice.
• **Computational Experiments**: Reference the Python demos.
  Include tables, charts, or numerical results.
• **Discussion**: Implications, limitations, open questions.
• **Future Work**: Specific, actionable next steps.
• **References**: Cite relevant prior work properly.
• **Length**: 3000–8000 words. Comprehensive and substantive.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 4 — Python Code: Demos, Algorithms
────────────────────────────────────────────────────────────────────────────
- **demo.py** — Working Python code demonstrating the theorems with
  concrete numerical examples. Make the math tangible.
- **algorithms.py** — Implement any algorithms from the research paper.
  Include docstrings, type hints, and example usage.
- **applications.py** — Code showing real-world applications of the results.
  Show the math working.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 5 — FUTURE_DIRECTIONS.md  (MANDATORY — drives next cycle)
────────────────────────────────────────────────────────────────────────────
The MOST IMPORTANT deliverable. Every research cycle MUST produce a
FUTURE_DIRECTIONS.md that identifies 3-5 specific, testable scientific
hypotheses. Each direction must be a falsifiable claim or conjecture that
can be proved, disproved, or tested — not a vague "we could explore X."
Format: "Conjecture: [precise statement]. Test: [what would confirm or
refute it]. Impact: [what this would enable if true]." Every hypothesis
should be daring enough to matter and specific enough to fail.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 6 — JSON Data Package  →  PACKAGE.json
────────────────────────────────────────────────────────────────────────────
Create a **single JSON file** that bundles ALL artifacts for the web templating system.
Requirements:

• **Structure**: Output a strictly valid JSON object matching this schema:
  {
    "title": "Title of the Research",
    "domain": "Mathematical Domain",
    "article": "Markdown content...",
    "research_paper": "Markdown content...",
    "future_directions": "Markdown content...",
    "demos": [ { "name": "...", "code": "# Must be 100% self-contained. Do not import local files like 'algorithms'" } ],
    "algorithms": [ { "name": "...", "pseudocode": "...", "code": "executable Python implementation" } ],
    "lean_proofs": "Raw lean code..."
  }
• **String Encoding**: Ensure all Markdown and code is properly JSON-escaped (e.g. `
` for newlines).
• **Complete**: Include ALL content from the article, research paper, and code. This JSON file
  is the sole data source for the frontend web application.

────────────────────────────────────────────────────────────────────────────

The mathematics comes FIRST. Excellent proofs trump everything else.
But great work deserves great presentation — make it real, useful, and
beautiful. Every deliverable should be something you'd be proud to show.

Research domain: Speculative
Research mode: prove
