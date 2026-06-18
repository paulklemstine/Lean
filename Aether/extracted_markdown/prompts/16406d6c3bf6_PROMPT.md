## Soli Deo Gloria

## Assignment: Certified Knuth-Bendix Completion — Automated Synthesis of Convergent Rewrite Systems

### The Vision

The catalog already proves that *manually constructed* convergent rewrite systems induce certified optimizers (`convergent_rewrite_induces_optimizer`). But manual construction is a bottleneck. The Knuth-Bendix completion procedure *automates* this: feed it equations, get a convergent system. The breakthrough is to **close the loop**: equations → completion → convergence certificate → certified optimizer, all verified in Lean 4. This transforms the catalog from a library of *examples* into an engine of *automated discovery*.

---

### Precise Theorem Targets with Lean 4 Signatures

**Core Definition — Critical Pairs:**
```lean
/-- A critical pair arises from an overlap of rule r₁ into a non-variable
    position of rule r₂, producing the divergent pair (r₂[r₁σ]ₚ, r₂'σ). -/
def criticalPair {F V : Type} (r₁ r₂ : Rule F V) (p : Position) 
    (σ : Substitution F V) (h_overlap : r₂.lhs.σ = r₁.lhs.replaceAt p r₁.rhs.σ) :
    Term F V × Term F V
```

**Theorem 1 — Critical Pair Lemma (the deep one):**
```lean
/-- A terminating rewrite system is confluent iff every critical pair is joinable.
    This is the NEWMAN LEMMA + LOCAL CONFLUENCE CHARACTERIZATION.
    Proof requires induction on term structure and well-founded descent. -/
theorem critical_pair_lemma {F V : Type} {R : RewriteSystem F V}
    (h_term : IsTerminating R)
    (h_cps : ∀ cp ∈ R.criticalPairs, IsJoinable R cp.1 cp.2) :
    IsConfluent R
```

**Theorem 2 — Completion Preserves Equational Theory:**
```lean
/-- Each KB completion step preserves the equational theory.
    Proof by case analysis on step type + calc chains for rewrite sequences. -/
theorem completion_step_preserves_eq_theory {F V : Type} 
    {S S' : CompletionState F V} (h_step : KBStep S S') :
    EqTheory (S.rules ∪ S.equations) = EqTheory (S'.rules ∪ S'.equations)
```

**Theorem 3 — Terminated Completion Yields Convergence (the capstone):**
```lean
/-- If KB completion terminates with empty pending equations, the resulting
    system is convergent and has the same equational theory as the input.
    Composing with the catalog's convergent_rewrite_induces_optimizer gives
    AUTOMATED CERTIFIED OPTIMIZER SYNTHESIS. -/
theorem kb_completion_produces_convergent {F V : Type} 
    {E : List (Equation F V)} {ord : ReductionOrdering F V}
    {final : RewriteSystem F V}
    (h_complete : kbCompletes E ord = some final)
    (h_fair : kbFair E ord) :
    IsConvergent final ∧ EqTheory final = EqTheory E
```

**Theorem 4 — Cross-Domain Bridge to Group Word Problem:**
```lean
/-- For a finite group presentation ⟨S | R⟩, if KB completion terminates on
    the group axioms ∪ R, the resulting convergent system decides the word problem:
    two words represent the same group element iff they reduce to the same normal form.
    Connects universal algebra → computational group theory. -/
theorem kb_solves_word_problem {G : Type} [Group G] {S : Finset G} {R : Finset (SWord S)}
    {final : RewriteSystem GroupSig GroupVar}
    (h_complete : kbCompletes (groupAxioms ∪ R) groupOrder = some final) :
    ∀ w₁ w₂ : SWord S, (w₁ = w₂ : Prop G) ↔ (normalForm final w₁ = normalForm final w₂)
```

---

### Proof Strategies (Ranked by Promise)

**Strategy A: Huet's Invariant Framework (MOST PROMISING)**
Define three invariants maintained by each completion step:
1. `I₁`: Equational theory preservation (straightforward case analysis)
2. `I₂`: Local confluence of oriented rules (requires critical pair tracking)
3. `I₃`: Fairness — every critical pair is eventually considered (requires scheduling argument)

Prove each KB step preserves all three invariants by `rcases` on step type. At termination, `I₁` gives equational soundness, `I₂ + emptiness of pending equations` gives local confluence, and `critical_pair_lemma` lifts local confluence to confluence. **Why most promising**: Decomposes one monster proof into three manageable invariant-preservation lemmas. Each is provable by induction/cases. The invariants compose cleanly.

**Strategy B: Direct Well-Founded Induction on Completion Trace**
Model completion as a well-founded sequence of states. Prove properties of the limit by well-founded induction on the trace length. **Risk**: The limit construction is subtle (need coinduction or classical choice for infinite traces), and well-foundedness of the trace itself requires the termination hypothesis, creating a circular dependency.

**Strategy C: Via Abstract Completion (Bachmair-Dershowitz)**
Formalize the abstract completion framework where completion is a relation on pairs (E, R) satisfying abstract properties. Prove a generic "abstract completion → convergence" theorem, then instantiate for KB. **Advantage**: More general. **Risk**: The abstraction layer adds formalization overhead without simplifying the core difficulty (critical pair lemma).

**Recommendation**: Use Strategy A for the main theorems. Prove the critical pair lemma separately via Strategy C's abstract framework, since it's the most mathematically subtle part and benefits from clean separation.

---

### Novel Definitions Required

1. **`CompletionState`**: State of the KB algorithm = `(rules : RewriteSystem F V) × (pending : List (Equation F V))` — does NOT exist in catalog or Mathlib.

2. **`CriticalOverlap`**: Structure encoding where two rules overlap, at what position, with what unifier — novel computational object.

3. **`KBFairness`**: Predicate on completion traces ensuring every critical pair is eventually processed — this is the key fairness condition that makes completion correct, not just sound.

4. **`CertifiedNormalizerByCompletion`**: Composition of KB completion output with `CertifiedNormalizer` from the catalog — the bridge definition that makes automated optimizer synthesis work.

---

### Cross-Domain Connections

| Domain | Connection | Depth |
|--------|-----------|-------|
| **Computational Group Theory** | KB completion on group axioms solves the word problem for finitely presented groups. Theorem 4 above is the bridge. This was Knuth and Bendix's original motivation (1970). | Deep — requires formalizing free groups and group presentations |
| **Homotopy Type Theory** | Critical pairs are 2-cells; joinability is the Kan filling condition. A convergent rewrite system is a "Kan complex" in the term rewriting 2-category. This opens: *homotopy-coherent rewriting*. | Speculative but profound — connect to Mathlib's simplicial objects |
| **Quantum Circuit Optimization** | The ZX-calculus is an equational theory on quantum circuits. KB completion = automated circuit optimizer. `CertifiedNormalizerByCompletion` = *certified quantum compiler*. | High impact — quantum computing needs verified compilation |
| **Algebraic Geometry** | Completion as "resolution of singularities" for the equational variety. Non-confluent points are "singularities"; completion "resolves" them. | Conceptual — opens tropical-algebraic bridge |

---

### Falsifiable Conjecture with Computational Test

**Conjecture (Bounded Completion for Small Groups):**
> For every finite group G of order |G| ≤ 50, with standard presentation ⟨G | R⟩ where R encodes the multiplication table, KB completion with the recursive path ordering terminates in at most 10,000 steps and produces a rewrite system with at most 3|R| rules.

**Computational Test:**
```python
# In demo.py
def test_bounded_completion():
    """For each group of order ≤ 50, run KB completion and check:
    1. Termination within 10,000 steps
    2. Rule count ≤ 3|R|
    3. Convergence (check all critical pairs joinable)
    Returns: (groups_passed, groups_failed, counterexamples)
    """
    counterexamples = []
    for group in all_groups_up_to_order(50):
        rules = group_to_rewrite_rules(group)
        result = kb_complete(rules, max_steps=10000)
        if not result.terminated or len(result.rules) > 3 * len(rules):
            counterexamples.append(group)
    return counterexamples  # Empty list = conjecture holds
```

If a counterexample is found, this refutes the conjecture and reveals which group presentations resist completion — itself a mathematical discovery about the boundary of automated rewriting.

---

### Building on Catalog Theorems

1. **From `Pythagorean/ConvergentRewriteOptimizer.lean`**: Use `CertifiedNormalizer` as the *output type* of completion. The theorem `convergent_rewrite_induces_optimizer` becomes the *final composition step*: `kb_produces_convergent ⟹ convergent_rewrite_induces_optimizer ⟹ CertifiedNormalizer`. This is the pipeline.

2. **From `Catalog/Pythagorean/VerifiedCompilerSynthesis.lean`**: The `adjoint_semantics_principle` ensures that the optimizer preserves semantics. KB completion preserves equational theory (Theorem 2), which is the semantic invariant. Compose: `completion_preserves_eq_theory ⟹ adjoint_semantics_principle ⟹ verified_compiler`.

3. **New bridge**: Define `CertifiedNormalizerByCompletion` that wraps the output of `kbCompletes` through `CertifiedNormalizer`, producing the first *automatically generated* certified normalizer in the catalog.

---

### Mandatory Deliverables

(a) **FUTURE_DIRECTIONS.md** with 5 testable hypotheses:
   1. The bounded completion conjecture above
   2. "KB completion with lexicographic path ordering terminates for all finite free commutative monoid presentations" (test: enumerate presentations up to arity 4)
   3. "The number of critical pairs in the completed system for group G is O(|G|·log|G|)" (test: regression on groups of order 1–100)
   4. "ZX-calculus completion produces circuit normal forms equivalent to the standard form of Van de Wetering (2020)" (test: complete core ZX, compare normal forms)
   5. "Completion time is correlated with the homotopy group π₂ of the critical pair complex" (test: compute π₂ for small examples, measure completion time)

(b) **RESEARCH_PAPER.md**: Standalone paper titled "Certified Knuth-Bendix Completion: Automated Synthesis of Verified Optimizers" with full proofs of the critical pair lemma and the completion-convergence theorem.

(c) **ARTICLE.md**: "When Equations Optimize Themselves: How a 50-Year-Old Algorithm Now Writes Its Own Correctness Proof" — for Scientific American readers, explaining the self-certifying loop.

(d) **Verified algorithm**: The `kbComplete` function with attached proofs of soundness and convergence, plus `CertifiedNormalizerByCompletion` composing with the catalog.

(e) **demo.py**: Interactive demonstration running KB completion on group presentations, Boolean ring axioms, and monoid presentations, with convergence verification and optimizer application.

---

### The Deeper Point

This is not just formalizing an algorithm. It is building the first **self-certifying compilation pipeline**: equational specifications automatically produce not just rewrite systems, but *proofs* that those systems are correct. The loop `equations → completion → convergence certificate → optimizer` closes the gap between *specifying what you want* and *getting a verified implementation*. This is the formalization of the dream that Knuth and Bendix had in 1970, realized 55 years later with machine-checked proofs.

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
hypotheses, including 1-2 grand_challenge paradigm-shifting conjectures
and 2-3 solid extensions building directly on Catalog theorems.
MUST begin with a ## Synthesis section tying all directions together.
Each direction must use the structured format with explicit fields:
**Conjecture**, **Test**, **Impact**, **Catalog References**,
**Proof Strategy**, **Domain Bridges**, **Lineage**, **Ambition**.
Reference specific Catalog theorems by file path. Every hypothesis
must be daring enough to matter and specific enough to fail.


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

Research domain: Pythagorean
Research mode: prove
