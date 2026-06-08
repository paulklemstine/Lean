            ## Assignment: **Conjecture:** For every `n : ℕ`, every point in the tropical convex hull of a 

            Prove new, non-trivial theorems. Build on catalog theorems. Minimize sorry.

            ### Research Direction
            # Future Directions

## [Tropical Carathéodory Compression]

**Conjecture:** For every `n : ℕ`, every point in the tropical convex hull of a finite subset of `Fin n → ℝ` (defined as the closure under tropical combinations `fun i => min (a + x i) (b + y i)`) lies in the tropical convex hull of some subfamily of cardinality at most `n + 1`.

**Why it matters:** The classical Carathéodory theorem is the foundation of the entire Carathéodory → Radon → Helly implication chain. A formal tropical Carathéodory theorem would enable a clean, conceptual proof of the tropical Helly theorem (replacing ad hoc arguments with structural theory) and would open the door to tropical analogs of linear programming duality, where optimal solutions are determined by a bounded number of active constraints.

**Test:** Formalize the tropical convex hull for `n = 2, 3` over rational coefficients. Enumerate all tropical combinations of 4-5 points in dimension 2 and verify that each lies in the tropical hull of at most 3 of them. Attempt a general inductive proof by projecting along one coordinate and applying the lower-dimensional result.

---

## [Minimal Infeasible Tropical Systems]

**Conjecture:** Every minimal infeasible finite family of tropical halfspaces in `Fin n → ℝ` has cardinality at most `2n + 1`. Moreover, for the special case of difference constraints (`x_i - x_j ≤ w`), the bound improves to `n`, and the minimal infeasible subsystem forms a negative-weight cycle in the constraint graph.

**Why it matters:** This conjecture gives the tight Helly number for tropical halfspaces and provides a structural characterization of infeasibility certificates. For difference constraints, it connects the Helly theorem directly to the Bellman-Ford algorithm, establishing that negative-cycle detection is not just an algorithm but a manifestation of a deep compression principle.

**Test:** Implement a brute-force search over systems of 5-10 tropical halfspaces in dimensions 2-4 with rational coefficients. For each infeasible system, find the minimal infeasible subsystem and track its size. Compare against the conjectured bounds. For difference constraints, verify that every minimal infeasible subsystem is indeed a simple negative cycle.

---

## [Tropical LP Witness Attainment]

**Conjecture:** Every feasible bounded tropical linear program in dimension `n` — defined as minimizing `max_k (c_k + x_{i_k})` subject to tropical halfspace constraints — admits an optimal solution determined by at most `n + 1` active tropical constraints. The active constraints form a tropical basic feasible solution analogous to the vertices of classical linear programming polytopes.

**Why it matters:** This would establish the foundation for a certified tropical simplex method, where optimization proceeds by moving between tropical basic feasible solutions. Combined with the Helly theorem (which provides feasibility certificates), this would give a complete framework for certified tropical linear programming — a critical tool for verified scheduling, shortest-path optimization, and min-plus constraint solving.

**Test:** Define a finite tropical LP model in dimensions 2 and 3. Enumerate feasible solutions for small instances with rational data. For each optimal solution, identify the set of active constraints and verify that at most `n + 1` are needed. Implement a tropical simplex pivot rule and test convergence on random instances.

---

## [Tropical Radon Implies Helly]

**Conjecture:** A formal tropical Radon theorem — stating that any set of `2n + 2` points in tropical `ℝ^n` can be partitioned into two groups whose tropical convex hulls intersect — implies the tropical Helly theorem via the classical implication chain adapted to tropical convexity. Specifically, the proof requires only: (1) tropical Radon, (2) tropical convexity is preserved under intersection, and (3) standard finite set combinatorics.

**Why it matters:** The Carathéodory-Radon-Helly chain is one of the most elegant structural patterns in combinatorial geometry. Establishing this chain in the tropical setting would unify the tropical convexity theory into a single coherent framework, rather than requiring separate ad hoc proofs for each result. It would also identify the precise Helly number (which depends on the Radon partition number) and could reveal whether tropical geometry has a richer or more restrictive combinatorial structure than classical geometry.

**Test:** State the tropical Radon theorem as an axiom/hypothesis in a formal proof. Derive the tropical Helly theorem from it using the standard inductive argument (induction on family size, using Radon to close the inductive step). Identify exactly which intermediate lemmas are needed and verify that no additional tropical-specific hypotheses are required beyond Radon and intersection closure.

---

## [Shortest-Path Certificate Compression]

**Conjecture:** Infeasibility of a finite system of min-plus difference constraints (inequalities of the form `x_i ⊕ a ≤ x_j ⊕ b`, equivalently `min(x_i, a) ≤ min(x_j, b)`) admits a witness subsystem of size bounded by `O(n)` in ambient dimension `n`. Furthermore, this witness subsystem can be extracted in polynomial time from a Bellman-Ford-style negative cycle detection, and the extraction procedure produces a certificate that is independently verifiable in `O(n)` time.

**Why it matters:** This conjecture connects the abstract tropical Helly theorem to concrete algorithmic practice. In verified compilation, static analysis, and certified optimization, one needs not just a yes/no feasibility answer but a *certificate* that can be independently checked. The conjecture asserts that such certificates are always small and efficiently extractable, which would enable certified solvers for min-plus constraint systems — a class of problems that includes shortest-path feasibility, timing verification, and mean-payoff game solving.

**Test:** Formalize a restricted difference-constraint fragment (`x_i - x_j ≤ w`) in a proof assistant. Implement Bellman-Ford with negative cycle extraction. For random infeasible systems of size 10-100 in dimensions 3-10, measure the size of the extracted negative cycle and compare against the `n` bound. Implement a certificate verifier that checks the cycle independently and measure verification time. Connect the extraction to the formally proved `negCycle_infeasible` theorem to create an end-to-end certified pipeline.


            ### Mathematical Framing
            # Future Directions

## [Tropical Carathéodory Compression]

**Conjecture:** For every `n : ℕ`, every point in the tropical convex hull of a finite subset of `Fin n → ℝ` (defined as the closure under tropical combinations `fun i => min (a + x i) (b + y i)`) lies in the tropical convex hull of some subfamily of cardinality at most `n + 1`.

**Why it matters:** The classical Carathéodory theorem is the foundation of the entire Carathéodory → Radon → Helly implication chain. A formal tropical Carathéodory theorem would enable a clean, conceptual proof of the tropical Helly theorem (replacing ad hoc arguments with structural theory) and would open the door to tropical analogs of linear programming duality, where optimal solutions are determined by a bounded number of active constraints.

**Test:** Formalize the tropical convex hull for `n = 2, 3` over rational coefficients. Enumerate all tropical combinations of 4-5 points in dimension 2 and verify that each lies in the tropical hull of at most 3 of them. Attempt a general inductive proof by projecting along one coordinate and applying the lower-dimensional result.

---

## [Minimal Infeasible Tropical Systems]

**Conjecture:** Every minimal infeasible finite family of tropical halfspaces in `Fin n → ℝ` has cardinality at most `2n + 1`. Moreover, for the special case of difference constraints (`x_i - x_j ≤ w`), the bound improves to `n`, and the minimal infeasible subsystem forms a negative-weight cycle in the constraint graph.

**Why it matters:** This conjecture gives the tight Helly number for tropical halfspaces and provides a structural characterization of infeasibility certificates. For difference constraints, it connects the Helly theorem directly to the Bellman-Ford algorithm, establishing that negative-cycle detection is not just an algorithm but a manifestation of a deep compression principle.

**Test:** Implement a brute-force search over systems of 5-10 tropical halfspaces in dimensions 2-4 with rational coefficients. For each infeasible system, find the minimal infeasible subsystem and track its size. Compare against the conjectured bounds. For difference constraints, verify that every minimal infeasible subsystem is indeed a simple negative cycle.

---

## [Tropical LP Witness Attainment]

**Conjecture:** Every feasible bounded tropical linear program in dimension `n` — defined as minimizing `max_k (c_k + x_{i_k})` subject to tropical halfspace constraints — admits an optimal solution determined by at most `n + 1` active tropical constraints. The active constraints form a tropical basic feasible solution analogous to the vertices of classical linear programming polytopes.

**Why it matters:** This would establish the foundation for a certified tropical simplex method, where optimization proceeds by moving between tropical basic feasible solutions. Combined with the Helly theorem (which provides feasibility certificates), this would give a complete framework for certified tropical linear programming — a critical tool for verified scheduling, shortest-path optimization, and min-plus constraint solving.

**Test:** Define a finite tropical LP model in dimensions 2 and 3. Enumerate feasible solutions for small instances with rational data. For each optimal solution, identify the set of active constraints and verify that at most `n + 1` are needed. Implement a tropical simplex pivot rule and test convergence on random instances.

---

## [Tropical Radon Implies Helly]

**Conjecture:** A formal tropical Radon theorem — stating that any set of `2n + 2` points in tropical `ℝ^n` can be partitioned into two groups whose tropical convex hulls intersect — implies the tropical Helly theorem via the classical implication chain adapted to tropical convexity. Specifically, the proof requires only: (1) tropical Radon, (2) tropical convexity is preserved under intersection, and (3) standard finite set combinatorics.

**Why it matters:** The Carathéodory-Radon-Helly chain is one of the most elegant structural patterns in combinatorial geometry. Establishing this chain in the tropical setting would unify the tropical convexity theory into a single coherent framework, rather than requiring separate ad hoc proofs for each result. It would also identify the precise Helly number (which depends on the Radon partition number) and could reveal whether tropical geometry has a richer or more restrictive combinatorial structure than classical geometry.

**Test:** State the tropical Radon theorem as an axiom/hypothesis in a formal proof. Derive the tropical Helly theorem from it using the standard inductive argument (induction on family size, using Radon to close the inductive step). Identify exactly which intermediate lemmas are needed and verify that no additional tropical-specific hypotheses are required beyond Radon and intersection closure.

---

## [Shortest-Path Certificate Compression]

**Conjecture:** Infeasibility of a finite system of min-plus difference constraints (inequalities of the form `x_i ⊕ a ≤ x_j ⊕ b`, equivalently `min(x_i, a) ≤ min(x_j, b)`) admits a witness subsystem of size bounded by `O(n)` in ambient dimension `n`. Furthermore, this witness subsystem can be extracted in polynomial time from a Bellman-Ford-style negative cycle detection, and the extraction procedure produces a certificate that is independently verifiable in `O(n)` time.

**Why it matters:** This conjecture connects the abstract tropical Helly theorem to concrete algorithmic practice. In verified compilation, static analysis, and certified optimization, one needs not just a yes/no feasibility answer but a *certificate* that can be independently checked. The conjecture asserts that such certificates are always small and efficiently extractable, which would enable certified solvers for min-plus constraint systems — a class of problems that includes shortest-path feasibility, timing verification, and mean-payoff game solving.

**Test:** Formalize a restricted difference-constraint fragment (`x_i - x_j ≤ w`) in a proof assistant. Implement Bellman-Ford with negative cycle extraction. For random infeasible systems of size 10-100 in dimensions 3-10, measure the size of the extracted negative cycle and compare against the `n` bound. Implement a certificate verifier that checks the cycle independently and measure verification time. Connect the extraction to the formally proved `negCycle_infeasible` theorem to create an end-to-end certified pipeline.



            ### Existing Verified Theorems
            Existing theorems you can build on:
  1. `tropical_feasibility_has_small_certificate` : theorem tropical_feasibility_has_small_certificate
     (file: Speculative/AutoResearch/Tropical/Helly.lean)
  2. `key_dimension_lower_bound_from_height` : theorem key_dimension_lower_bound_from_height
     (file: Speculative/AutoResearch/AlgebraicInvariantCryptography.lean)
  3. `recurrent_fixedpoint_class_preserved_under_time_reversal_quotient` : theorem recurrent_fixedpoint_class_preserved_under_time_reversal_quotient
     (file: Speculative/AutoResearch/UltrametricOracleCapacity.lean)
  4. `bottleneck_set_is_optimal_for_one_step_throughput` : theorem bottleneck_set_is_optimal_for_one_step_throughput
     (file: Bridges/BottleneckUpgrade.lean)
  5. `bottleneck_set_is_optimal_for_one_step_throughput` : theorem bottleneck_set_is_optimal_for_one_step_throughput
     (file: FINAL/Bridges/BottleneckUpgrade.lean)

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
