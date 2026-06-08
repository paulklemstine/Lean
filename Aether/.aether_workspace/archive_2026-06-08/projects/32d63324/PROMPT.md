            ## Assignment: **Conjecture.** The combinatorial heart of the CDPR theorem—that displacement ta

            Prove new, non-trivial theorems. Build on catalog theorems. Minimize sorry.

            ### Research Direction
            # Future Directions: Tropical Brill–Noether Theory

## Hypothesis 1: Displacement Tableaux Admit a Clean Formalization Via Semi-Standard Young Tableaux

**Conjecture.** The combinatorial heart of the CDPR theorem—that displacement tableaux of type (g, d, r) exist if and only if ρ(g, r, d) ≥ 0—can be formalized in Lean 4 by reducing to a well-studied counting problem on semi-standard Young tableaux fitting inside a rectangular box.

**Test.** Define a "CDPR filling" as a function `Fin (r+1) → Fin g → Fin 2` satisfying: (i) each row j has a prescribed number of 1-entries determined by a per-strand net displacement, (ii) the "state vector" at each column stays in the Weyl chamber, (iii) an intermediate nonnegativity condition. Prove that the existence of such a filling for parameters (g, d, r) is equivalent to ρ ≥ 0 by establishing a bijection with lattice paths in a staircase region. Verify computationally for all g ≤ 12, r ≤ 4.

**Impact.** This would yield the first machine-checked proof of the tropical Brill–Noether existence theorem, completing the sorry-free formalization of the CDPR result.

---

## Hypothesis 2: Baker–Norine Rank Admits a Tropical Linear Algebra Upper Bound

**Conjecture.** There exists a functorial construction sending divisors on a chain of g loops to tropical matrices such that the Baker–Norine divisor rank is bounded above by the tropical matrix rank (Barvinok rank) of the image.

**Test.** For genera g ≤ 6 and all v₀-reduced divisors of degree d ≤ 2g, construct the candidate matrix M(D) ∈ ℝ_trop^{(g+1)×(g+1)} whose (i,j)-entry encodes the tropical distance between chip positions. Compare the computed Barvinok rank of M(D) with the divisor rank r(D) on exhaustive samples. A valid bound would give Barvinok_rank(M(D)) ≥ r(D) for all D.

**Impact.** This would create a new bridge between tropical linear algebra and divisor theory, potentially yielding faster rank computation algorithms and new structural insights into the Baker–Norine rank function.

---

## Hypothesis 3: The Full CDPR Theorem Is Formalizable Without Metric Data

**Conjecture.** The tropical Brill–Noether existence theorem on a chain of g loops can be stated and proved purely combinatorially, without any reference to edge lengths or genericity conditions, by working directly with reduced divisors and chip-firing equivalence classes on the combinatorial (non-metric) chain of loops graph.

**Test.** Define the chain-of-loops as a multigraph (not a metric graph). Define Baker–Norine rank via chip-firing. State and attempt to prove: for the chain of g loops, a divisor of degree d and rank ≥ r exists iff ρ(g,r,d) ≥ 0. The key challenge is that without genericity, the theorem may fail—check computationally whether the combinatorial chain of loops (with unit edge weights) satisfies the BN theorem for g ≤ 8.

**Impact.** If true, this would dramatically simplify the formalization by eliminating all real-number infrastructure. If false, the counterexamples would clarify exactly which metric data is essential.

---

## Hypothesis 4: Specialization Inequality Can Be Fully Formalized for Semistable Degenerations

**Conjecture.** An abstract algebraic interface consisting of (i) a "specialization map" from algebraic to tropical divisors, (ii) degree preservation, and (iii) a rank inequality `r_X(D) ≤ r_Γ(τ*(D))`, suffices to prove a machine-checked theorem linking classical and tropical Brill–Noether theory, without requiring scheme theory, formal models, or Berkovich spaces.

**Test.** Define a Lean typeclass `SpecializationData` with the three axioms above. Prove that the existence direction of tropical BN follows formally from classical BN + specialization. Check that all proof obligations reduce to pure divisor/graph lemmas. Attempt to instantiate the typeclass for the chain-of-loops model by defining a concrete specialization map from hyperelliptic curves.

**Impact.** This would create the first formal bridge between algebraic geometry and tropical geometry in a proof assistant, opening the door to machine-certified degeneration arguments.

---

## Hypothesis 5: Genericity Conditions Can Be Weakened to a Single Non-Vanishing Determinant

**Conjecture.** The full tropical Brill–Noether existence theorem on chains of loops remains valid under a weaker explicit condition than pairwise ratio distinctness: it suffices that a single (r+1) × (r+1) determinant formed from the edge-length ratios is nonzero.

**Test.** For fixed r ∈ {1, 2, 3} and g ≤ 10, enumerate all divisors of degree d and rank ≥ r on chains of g loops with random edge lengths satisfying the weaker determinantal condition but NOT the pairwise distinctness condition. Check whether the BN existence theorem still holds. Search for counterexamples among low-genus metric chains satisfying the weak condition but violating the strong condition.

**Impact.** A weaker genericity condition would enlarge the class of tropical curves for which the BN theorem holds, potentially enabling applications to specific families of curves (e.g., those arising from particular degenerations of moduli spaces).


            ### Mathematical Framing
            # Future Directions: Tropical Brill–Noether Theory

## Hypothesis 1: Displacement Tableaux Admit a Clean Formalization Via Semi-Standard Young Tableaux

**Conjecture.** The combinatorial heart of the CDPR theorem—that displacement tableaux of type (g, d, r) exist if and only if ρ(g, r, d) ≥ 0—can be formalized in Lean 4 by reducing to a well-studied counting problem on semi-standard Young tableaux fitting inside a rectangular box.

**Test.** Define a "CDPR filling" as a function `Fin (r+1) → Fin g → Fin 2` satisfying: (i) each row j has a prescribed number of 1-entries determined by a per-strand net displacement, (ii) the "state vector" at each column stays in the Weyl chamber, (iii) an intermediate nonnegativity condition. Prove that the existence of such a filling for parameters (g, d, r) is equivalent to ρ ≥ 0 by establishing a bijection with lattice paths in a staircase region. Verify computationally for all g ≤ 12, r ≤ 4.

**Impact.** This would yield the first machine-checked proof of the tropical Brill–Noether existence theorem, completing the sorry-free formalization of the CDPR result.

---

## Hypothesis 2: Baker–Norine Rank Admits a Tropical Linear Algebra Upper Bound

**Conjecture.** There exists a functorial construction sending divisors on a chain of g loops to tropical matrices such that the Baker–Norine divisor rank is bounded above by the tropical matrix rank (Barvinok rank) of the image.

**Test.** For genera g ≤ 6 and all v₀-reduced divisors of degree d ≤ 2g, construct the candidate matrix M(D) ∈ ℝ_trop^{(g+1)×(g+1)} whose (i,j)-entry encodes the tropical distance between chip positions. Compare the computed Barvinok rank of M(D) with the divisor rank r(D) on exhaustive samples. A valid bound would give Barvinok_rank(M(D)) ≥ r(D) for all D.

**Impact.** This would create a new bridge between tropical linear algebra and divisor theory, potentially yielding faster rank computation algorithms and new structural insights into the Baker–Norine rank function.

---

## Hypothesis 3: The Full CDPR Theorem Is Formalizable Without Metric Data

**Conjecture.** The tropical Brill–Noether existence theorem on a chain of g loops can be stated and proved purely combinatorially, without any reference to edge lengths or genericity conditions, by working directly with reduced divisors and chip-firing equivalence classes on the combinatorial (non-metric) chain of loops graph.

**Test.** Define the chain-of-loops as a multigraph (not a metric graph). Define Baker–Norine rank via chip-firing. State and attempt to prove: for the chain of g loops, a divisor of degree d and rank ≥ r exists iff ρ(g,r,d) ≥ 0. The key challenge is that without genericity, the theorem may fail—check computationally whether the combinatorial chain of loops (with unit edge weights) satisfies the BN theorem for g ≤ 8.

**Impact.** If true, this would dramatically simplify the formalization by eliminating all real-number infrastructure. If false, the counterexamples would clarify exactly which metric data is essential.

---

## Hypothesis 4: Specialization Inequality Can Be Fully Formalized for Semistable Degenerations

**Conjecture.** An abstract algebraic interface consisting of (i) a "specialization map" from algebraic to tropical divisors, (ii) degree preservation, and (iii) a rank inequality `r_X(D) ≤ r_Γ(τ*(D))`, suffices to prove a machine-checked theorem linking classical and tropical Brill–Noether theory, without requiring scheme theory, formal models, or Berkovich spaces.

**Test.** Define a Lean typeclass `SpecializationData` with the three axioms above. Prove that the existence direction of tropical BN follows formally from classical BN + specialization. Check that all proof obligations reduce to pure divisor/graph lemmas. Attempt to instantiate the typeclass for the chain-of-loops model by defining a concrete specialization map from hyperelliptic curves.

**Impact.** This would create the first formal bridge between algebraic geometry and tropical geometry in a proof assistant, opening the door to machine-certified degeneration arguments.

---

## Hypothesis 5: Genericity Conditions Can Be Weakened to a Single Non-Vanishing Determinant

**Conjecture.** The full tropical Brill–Noether existence theorem on chains of loops remains valid under a weaker explicit condition than pairwise ratio distinctness: it suffices that a single (r+1) × (r+1) determinant formed from the edge-length ratios is nonzero.

**Test.** For fixed r ∈ {1, 2, 3} and g ≤ 10, enumerate all divisors of degree d and rank ≥ r on chains of g loops with random edge lengths satisfying the weaker determinantal condition but NOT the pairwise distinctness condition. Check whether the BN existence theorem still holds. Search for counterexamples among low-genus metric chains satisfying the weak condition but violating the strong condition.

**Impact.** A weaker genericity condition would enlarge the class of tropical curves for which the BN theorem holds, potentially enabling applications to specific families of curves (e.g., those arising from particular degenerations of moduli spaces).



            ### Existing Verified Theorems
            Existing theorems you can build on:
  1. `exists_minimal_graph_from_rank_data` : theorem exists_minimal_graph_from_rank_data (R : TropRankData)
     (file: Bridges/AlgebraTropicalGeometry/TropicalPersistenceRealizationDuality.lean)
  2. `exists_minimal_graph_from_rank_data` : theorem exists_minimal_graph_from_rank_data (R : TropRankData)
     (file: FINAL/Bridges/TropicalPersistenceRealizationDuality.lean)
  3. `weighted_tropical_data_admits_twin_free_models` : theorem weighted_tropical_data_admits_twin_free_models :
     (file: FINAL/Tropical/SieveEnergetics.lean)
  4. `key_dimension_lower_bound_from_height` : theorem key_dimension_lower_bound_from_height
     (file: Speculative/AutoResearch/AlgebraicInvariantCryptography.lean)
  5. `fixed_point_entropy_upper_bound` : theorem fixed_point_entropy_upper_bound
     (file: Speculative/AutoResearch/ThermodynamicClosureCore.lean)

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
