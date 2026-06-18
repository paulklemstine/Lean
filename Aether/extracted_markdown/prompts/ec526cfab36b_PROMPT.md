## Assignment: Direction 2: Equality Saturation Extraction Correctness

Prove new, non-trivial theorems. Build on catalog theorems. Minimize sorry.

## Depth Requirements (MANDATORY)

Your output must satisfy ALL of these:

1. **NO trivial proofs**: Do NOT prove statements by `native_decide`, `decide`, `norm_num`, or `rfl` unless the statement itself is genuinely important. If the only proof tactic is enumeration, the theorem is not worth formalizing.

2. **At least 3 theorems with deep proof tactics**: Your file must contain at least 3 theorems proven using induction, rcases, by_contra, field_simp, or multi-step calc reasoning.

3. **Novel definitions**: Define at least one new mathematical structure or concept that does not already exist in the Catalog. Check the catalog references to confirm novelty.

4. **Cross-domain connections**: Include at least one theorem that connects your domain to a different mathematical domain (e.g., number theory + tropical geometry, algebra + physics).

5. **Conjecture with testable prediction**: State at least one falsifiable conjecture with a clear computational test that could disprove it.

---

### Research Direction

**Conjecture:** For a convergent rewrite system R and an e-graph G saturated by R, extracting the cheapest representative from each e-class yields a term semantically equivalent to any other representative — i.e., the extraction function is a certified optimizer in the sense of the Master Optimizer Theorem.

**Test:** Implement bounded e-graph saturation for 100 random convergent systems. For each system, saturate an e-graph with 1000 random terms, extract cheapest representatives using a monotone cost model, and compare eval(extract(t)) with eval(t) across 100 random algebras. Any mismatch refutes the soundness claim.

**Impact:** Would provide the first machine-verified correctness proof for equality saturation extraction, connecting the e-graph literature (Willsey et al., 2021) to the convergent rewriting framework. This certifies that the egg library's core extraction algorithm is semantics-preserving — a result that compiler engineers have assumed but never formally proven.

---

### Precise Theorem Statements with Lean 4 Type Signatures

```lean
/-- An e-graph is an equivalence relation on terms that is sound
    with respect to a rewrite system and closed under rewrites. -/
structure EGraph (α : Type) [DecidableEq α] where
  /-- The equivalence relation represented by the e-graph -/
  eq : Term α → Term α → Prop
  eqv_refl : ∀ t, eq t t
  eqv_symm : ∀ {t₁ t₂}, eq t₁ t₂ → eq t₂ t₁
  eqv_trans : ∀ {t₁ t₂ t₃}, eq t₁ t₂ → eq t₂ t₃ → eq t₁ t₃
  /-- Soundness: e-graph equivalence implies R-equivalence -/
  sound : ∀ {t₁ t₂}, eq t₁ t₂ → EqvGen R.step t₁ t₂
  /-- Saturation: closed under all R-rewrites -/
  saturated : ∀ {t₁ t₂}, R.step t₁ t₂ → eq t₁ t₂

/-- A cost model is monotone if rewriting never increases cost -/
def MonotoneCost (R : RewriteSystem α) (cost : Term α → ℕ) : Prop :=
  ∀ {t₁ t₂}, R.step t₁ t₂ → cost t₁ ≥ cost t₂

/-- THEOREM 1 (Completeness): For a convergent system, a saturated e-graph
    computes exactly the equivalence closure. This is the bridge between
    the operational notion (saturation) and the denotational notion (EqvGen). -/
theorem egraph_complete_of_convergent
    {R : RewriteSystem α} [DecidableEq α]
    (h_conv : R.IsConvergent)
    {G : EGraph α} (h_sat : G.saturated) :
    ∀ {t₁ t₂}, EqvGen R.step t₁ t₂ → G.eq t₁ t₂ := by
  -- Proof by induction on EqvGen derivation
  -- Key: confluence guarantees that saturation doesn't miss equivalences
  -- Uses: eqv_refl, eqv_trans, saturated, and confluence
  sorry

/-- THEOREM 2 (Extraction Preserves Semantics): The central result.
    Extraction under a monotone cost model preserves evaluation. -/
theorem extract_preserves_eval
    {R : RewriteSystem α} [DecidableEq α]
    {cost : Term α → ℕ} (h_mono : MonotoneCost R cost)
    {G : EGraph α} (h_sat : G.saturated)
    (h_conv : R.IsConvergent)
    (t : Term α) :
    eval (extract cost G t) = eval t := by
  -- Strategy: show extract(t) and t are in the same e-class
  -- By egraph_complete_of_convergent, they are R-equivalent
  -- By nf_constant_on_eqvGen, they have the same normal form
  -- By eval_eq_of_nf_eq, they evaluate identically
  sorry

/-- THEOREM 3 (Cross-Domain: E-graph Saturation as Fixed Point):
    The saturation operator is a monotone function on the complete lattice
    of equivalence relations. Saturation computes the least fixed point
    above the identity relation — connecting e-graphs to the Knaster-Tarski
    theorem and domain theory. -/
theorem saturation_is_least_fixpoint
    (R : RewriteSystem α) [DecidableEq α] :
    IsLeast {E : EGraph α | E.saturated}
            (saturate R init_egraph) ∧
    ∀ E : EGraph α, E.saturated ↔
      saturate R init_egraph ≤ E := by
  -- Proof: saturation is monotone (adding equivalences preserves saturation)
  -- The lattice of equivalence relations is complete (Knaster-Tarski)
  -- The least fixed point is exactly the equivalence closure
  sorry

/-- THEOREM 4 (Cross-Domain: Extraction as Quotient Section):
    Extraction is a section of the quotient map Quot.mk (EqvGen R.step).
    This connects e-graph extraction to universal algebra: the extraction
    function descends to a function on the quotient algebra. -/
theorem extract_is_quotient_section
    {R : RewriteSystem α} [DecidableEq α]
    {cost : Term α → ℕ} (h_mono : MonotoneCost R cost)
    {G : EGraph α} (h_sat : G.saturated)
    (h_conv : R.IsConvergent) :
    ∀ t, Quot.mk (EqvGen R.step) (extract cost G t) =
          Quot.mk (EqvGen R.step) t := by
  -- Follows from egraph_complete_of_convergent and the definition of extract
  sorry
```

---

### Proof Strategies (Three Paths)

**Strategy A: Via Normal Forms (Most Promising)**
1. Prove `egraph_complete_of_convergent`: By induction on the derivation of `EqvGen R.step t₁ t₂`. The reflexive case uses `eqv_refl`, the symmetric case uses `eqv_symm`, the transitive case uses `eqv_trans`, and the step case uses `saturated`. Confluence is needed to handle the overlap between transitivity and step cases.
2. Show that `extract cost G t` and `t` are in the same e-class (they are `G.eq`-related).
3. By `egraph_complete_of_convergent`, they are `EqvGen R.step`-related.
4. By `nf_constant_on_eqvGen` (from catalog), they share a normal form.
5. By `eval_eq_of_nf_eq` (from catalog), they evaluate identically.

This is most promising because it directly chains existing catalog results and the inductive structure of `EqvGen` is well-understood.

**Strategy B: Via Confluence Diagrams**
1. Show that for convergent R, any two equivalent terms have a common reduct (Church-Rosser).
2. Show that extraction under monotone cost reaches the normal form (cost decreases along reduction paths).
3. Use the uniqueness of normal forms to conclude.

This approach requires proving confluence properties that may not be in the catalog, making it harder.

**Strategy C: Via Quotient Induction**
1. Define the quotient type `Quot (EqvGen R.step)`.
2. Show that `extract cost G` descends to a function on this quotient.
3. Use `quotientNf_mk` (from catalog) to show this function coincides with `nf`.
4. Conclude by the universal property of quotients.

This is elegant but requires more Lean 4 quotient machinery.

---

### Cross-Domain Connections

**1. Lattice Theory ↔ E-Graph Saturation (Theorem 3)**
The set of equivalence relations on terms forms a complete lattice under refinement. Saturation is a monotone operator on this lattice. By Knaster-Tarski, it has a least fixed point — exactly the equivalence closure. This bridges e-graphs to domain theory and denotational semantics.

**2. Universal Algebra ↔ Extraction (Theorem 4)**
The quotient `Quot (EqvGen R.step)` is a universal algebra. Extraction picks a canonical representative from each equivalence class, i.e., it is a *section* of the quotient map. This connects to the theory of *term rewriting modulo* and the First Isomorphism Theorem for algebras.

**3. Compiler Optimization ↔ Certified Optimization**
The egg framework uses equality saturation for program optimization. This work proves that the core extraction step is *semantics-preserving* — the first machine-verified guarantee. This bridges formal methods to practical compiler infrastructure.

**4. Category Theory ↔ Fixed Points**
The saturation operator is a monad on the category of equivalence relations. Its least fixed point is the initial algebra for this monad. This connects to categorical semantics of program analysis (abstract interpretation as fixed points).

---

### Falsifiable Conjecture

**Conjecture (Optimality of Extraction):** For a convergent rewrite system R with a monotone cost model c, extraction produces the *globally minimum-cost* term in each equivalence class:

```lean
conjecture extract_is_optimal :
  ∀ {R : RewriteSystem α} [DecidableEq α],
    R.IsConvergent →
    ∀ {cost : Term α → ℕ}, MonotoneCost R cost →
    ∀ {G : EGraph α}, G.saturated →
    ∀ t t', G.eq t t' → cost (extract cost G t) ≤ cost t'
```

**Test:** Generate 100 convergent term rewriting systems (e.g., associative-commutative theories with oriented rules). For each, construct a saturated e-graph, extract representatives under a monotone cost model (e.g., AST size), and exhaustively verify that `cost(extract(t)) ≤ cost(t')` for all `t'` in the same e-class. Any counterexample disproves the conjecture and reveals that monotonicity alone is insufficient — additional conditions (like strong normalization of the cost model) may be needed.

---

### Catalog References
- `Pythagorean/ConvergentRewriteOptimizer.lean`: `nf_constant_on_eqvGen`, `quotientNf_mk`, `eval_eq_of_nf_eq`
- Build directly on these: they establish that normal forms are constant on equivalence classes and preserve evaluation. The e-graph extraction theorem generalizes this from normal forms to *any* section constant on equivalence classes.

---

### Mandatory Deliverables

(a) **FUTURE_DIRECTIONS.md** with 3-5 testable scientific hypotheses, each falsifiable with a concrete computational experiment.

(b) **RESEARCH_PAPER.md** — a standalone scientific document readable without code access. Must explain: what the e-graph extraction correctness theorem says, why it matters for compiler verification, how the proof works, and what to investigate next.

(c) **ARTICLE.md** — Scientific American style, engaging and accessible. Explain how proving that program optimization preserves meaning connects to the deeper question: *can we ever trust a compiler to do what we want, not just what we say?*

(d) **Verified algorithm**: A computable extraction function (not just an existence proof) with a verified correctness guarantee.

(e) **demo.py**: Implement e-graph saturation and extraction for a small convergent system (e.g., integer arithmetic with associativity/commutativity). Show that `eval(extract(t)) == eval(t)` for 1000 random terms, and demonstrate that a *non-saturated* e-graph can violate this property (the soundness counterexample).

---

*Soli Deo Gloria*

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
