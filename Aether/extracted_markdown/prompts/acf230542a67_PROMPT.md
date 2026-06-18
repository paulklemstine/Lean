Soli Deo Gloria

## Assignment: Direction 1: Cost-Minimality of Convergent Normal Forms — Tropical Foundations for Optimal Rewriting

Prove new, non-trivial theorems. Build on catalog theorems. Minimize sorry.

## Depth Requirements (MANDATORY)

Your output must satisfy ALL of these:

1. **NO trivial proofs**: Do NOT prove statements by `native_decide`, `decide`, `norm_num`, or `rfl` unless the statement itself is genuinely important.
2. **At least 3 theorems with deep proof tactics**: Your file must contain at least 3 theorems proven using induction, rcases, by_contra, field_simp, or multi-step calc reasoning.
3. **Novel definitions**: Define at least one new mathematical structure or concept that does not already exist in the Catalog.
4. **Cross-domain connections**: Include at least one theorem that connects your domain to a different mathematical domain.
5. **Conjecture with testable prediction**: State at least one falsifiable conjecture with a clear computational test that could disprove it.

---

### Visionary Context

Convergent rewriting is the algorithmic backbone of compiler optimization, symbolic simplification, and automated theorem proving. The Church-Rosser theorem guarantees *uniqueness* of normal forms. But uniqueness is not enough for practice — we need *optimality*. This research establishes that convergent rewriting is not merely correct but **information-theoretically optimal**: the normal form is the cost-minimal representative of its equivalence class under any cost model compatible with the termination ordering. This transforms the rewrite theorist's slogan "normalize to simplify" into a theorem: "normalize to **optimally** simplify."

The deeper insight is that cost-compatible functions on terms form a **tropical semiring** under pointwise min and addition, and the normalization map is a **tropical homomorphism** — it preserves the tropical structure. This opens a bridge between rewrite theory and tropical geometry, with consequences for understanding the geometry of optimization landscapes in program spaces.

---

### Core Theorem: Cost-Minimality of Normal Forms

**Theorem (normal_form_cost_minimal):** For a convergent rewrite system R with reduction relation →_R, and a cost function c : Term(Σ) → ℕ that is strictly decreasing along every reduction step (c(s) > c(t) whenever s →_R t), the normal form of any term t is cost-minimal among all R-equivalent terms:

```
∀ t u, EqvGen (→_R) t u → IsNormalForm R u → c (nf R t) ≤ c u
```

**Lean 4 Type Signature:**

```lean
theorem normal_form_cost_minimal
    {α : Type*} {R : RewriteSystem α}
    (h_conv : IsConvergent R)
    (c : Term α → ℕ)
    (h_compat : ∀ s t, ReducesTo R s t → c s > c t) :
  ∀ t u, EqvGen (ReducesTo R) t u → IsNormalForm R u → c (nf R t h_conv.2 t) ≤ c u
```

**Proof Strategy A (Contradiction via Confluence — RECOMMENDED):**
1. Assume ∃ u equivalent to nf(t) with c(u) < c(nf(t)).
2. By confluence: since nf(t) ~_R u, both must join at some common reduct v. But nf(t) is a normal form, so nf(t) cannot reduce; thus v = nf(t).
3. Therefore u →*_R nf(t). By iterating h_compat across the reduction sequence: c(u) > c(u₁) > ... > c(nf(t)).
4. Contradiction with c(u) < c(nf(t)). ∎

This is the most promising strategy because it reduces the problem to the **diamond property** of confluence and the **strict monotonicity** of cost along reduction sequences, both of which are well-understood.

**Proof Strategy B (Well-founded Induction on Cost):**
1. Fix t. Define P(n) := "for all u equivalent to t with c(u) = n, c(nf(t)) ≤ c(u)."
2. Base case: c(u) = 0. Then u is irreducible (since any reduction would produce a term of negative cost, impossible). So u = nf(t) by uniqueness.
3. Inductive step: if u →_R v, then c(v) < c(u), so P(c(v)) holds. But nf(v) = nf(u) = nf(t), so c(nf(t)) ≤ c(v) < c(u). ∎

This strategy is elegant but requires proving that cost-0 terms are irreducible, which needs the strict positivity of cost (c(s) > c(t) ≥ 0 for all reductions).

**Proof Strategy C (Order-Theoretic — connects to domain theory):**
1. Observe that →_R ⊂ {(s,t) | c(s) > c(t)} ⊂ {(s,t) | c(s) ≥ c(t)}.
2. The cost function c induces a well-order on each equivalence class (since costs are in ℕ).
3. The normal form is the unique →_R-minimal element, and →_R-minimal implies c-minimal because c is antitone with respect to →_R.
4. Formalize using `WellFounded.min` from Mathlib. ∎

---

### Novel Definition: Tropical Cost Algebra

```lean
/-- A tropical cost algebra over a signature Σ is a cost function
    equipped with the tropical semiring structure (min, +) on costs,
    satisfying context-monotonicity: reductions in any subterm decrease total cost. -/
structure TropicalCostAlgebra (α : Type*) where
  cost : Term α → ℕ
  -- Tropical addition: pointwise min
  trop_add : Term α → Term α → ℕ
  -- Tropical multiplication: pointwise sum  
  trop_mul : Term α → Term α → ℕ
  -- The cost function is a tropical valuation
  cost_trop_add : ∀ s t, trop_add s t = min (cost s) (cost t)
  cost_trop_mul : ∀ s t, trop_mul s t = cost s + cost t
  -- Context-monotonicity: reductions in any position decrease cost
  context_mono : ∀ C s t, ReducesTo R s t → cost (C.fill s) > cost (C.fill t)
```

The key insight: context-monotonicity is strictly stronger than rule-level compatibility (c(l) > c(r) for each rule). It ensures that reducing *any subterm* of a term decreases cost. Standard cost functions like term size, term depth, and weighted symbol count are all context-monotone.

---

### Theorem 2 (Strict Minimality): Normal Forms Are Strictly Cheaper Than Non-Normal Equivalents

```lean
theorem normal_form_strictly_cheaper
    {α : Type*} {R : RewriteSystem α}
    (h_conv : IsConvergent R)
    (c : Term α → ℕ)
    (h_compat : ∀ s t, ReducesTo R s t → c s > c t) :
  ∀ t u, EqvGen (ReducesTo R) t u → IsNormalForm R u → u ≠ nf R t → c (nf R t) < c u
```

This strengthens the main theorem from ≤ to <. The proof uses the fact that u ≠ nf(t) implies u →*_R nf(t) with at least one step, so c(u) > c(nf(t)) strictly.

---

### Theorem 3 (Cross-Domain: Tropical Valuation on the Rewrite Monoid)

This is the cross-domain bridge. The equivalence classes under R form a monoid (the quotient monoid T(Σ)/~_R). The cost of the normal form descends to a **tropical valuation** on this quotient monoid, making it a **tropical semiring**.

```lean
/-- The cost of the normal form defines a tropical valuation on the
    quotient monoid of terms modulo R-equivalence. -/
theorem nf_cost_is_tropical_valuation
    {α : Type*} {R : RewriteSystem α}
    (h_conv : IsConvergent R)
    (c : Term α → ℕ)
    (h_compat : ∀ s t, ReducesTo R s t → c s > c t)
    (h_subst : ∀ s t, c (subst s t) = c s + c t) :
  ∀ [s] [t] : Quotient (EqvGen.setoid (ReducesTo R)),
    c (nf_rep [s ⊹ [t]]) = min (c (nf_rep [s])) (c (nf_rep [t]))
    ∧ c (nf_rep [s ⊗ [t]]) = c (nf_rep [s]) + c (nf_rep [t])
```

Here ⊹ and ⊗ are the monoid operations (substitution and concatenation) on the quotient. The proof requires showing that the normal form map `nf_rep : Quotient → Term` is well-defined (which follows from uniqueness of normal forms) and that it respects the tropical operations (which requires the substitution cost axiom h_subst).

**Cross-domain significance:** This connects rewrite theory to **tropical geometry** — the quotient monoid becomes a tropical variety, and the normal form map is a tropicalization functor. This suggests that the space of all convergent rewrite systems over a fixed signature has a natural tropical geometric structure, opening connections to tropical Hilbert bases, tropical Gröbner fans, and the tropical nullstellensatz.

---

### Theorem 4 (Cross-Domain: Information-Theoretic Lower Bound)

The cost of the normal form provides a **Kolmogorov-style lower bound** on the complexity of representing any member of the equivalence class.

```lean
/-- The cost of the normal form is a lower bound on the description
    complexity of any term in the equivalence class, for any
    cost-compatible description system. -/
theorem nf_cost_lower_bound
    {α : Type*} {R : RewriteSystem α}
    (h_conv : IsConvergent R)
    (c : Term α → ℕ)
    (h_compat : ∀ s t, ReducesTo R s t → c s > c t) :
  ∀ t u, EqvGen (ReducesTo R) t u → c (nf R t) ≤ c u
```

This is the main theorem restated with an information-theoretic interpretation: the normal form is the **minimum description length** (MDL) representative of its equivalence class under any cost model compatible with the rewrite system. This connects to **algorithmic information theory** (Kolmogorov complexity, MDL principle) and provides a formal foundation for the widespread intuition that "simplified = optimal."

---

### Falsifiable Conjecture: Tropical Universality of Linear Cost Functions

**Conjecture (TropicalUniversality):** For every convergent rewrite system R over a finite signature Σ with n function symbols and m rules, there exists a **linear cost function** c(t) = Σᵢ wᵢ · count(fᵢ, t) (weighted symbol counts with wᵢ ∈ ℕ) that is context-monotone with respect to R. Moreover, the dimension of the space of such linear cost functions is at least n - m + 1.

**Computational Test:** For each of 200 randomly generated convergent rewrite systems over signatures with 3 ≤ n ≤ 6 symbols and 3 ≤ m ≤ 10 rules:
1. Verify convergence (termination + confluence) via exhaustive search up to depth 15.
2. Formulate context-monotonicity as a system of linear inequalities over the weights w₁, ..., wₙ.
3. Solve the resulting integer linear program. If any convergent system has no feasible solution, the conjecture is refuted.
4. For systems with feasible solutions, compute the dimension of the solution space and check n - m + 1 ≤ dim.

**Why this matters:** If true, every convergent rewrite system admits a "natural" cost model (a linear one), and the dimension formula reveals a tropical analogue of the rank-nullity theorem. If false, the counterexamples would identify rewrite systems that require "non-linear" cost models, opening the study of **non-linear tropical valuations** on rewrite monoids — potentially connecting to tropical schemes and tropical scheme theory.

---

### Catalog Integration

Build directly on:
- `Pythagorean/ConvergentRewriteOptimizer.lean`: `convergent_rewrite_induces_optimizer` (the existential result that convergent rewriting optimizes something) — extend this to the universal result that it optimizes *everything compatible*.
- `nf_unique_of_confluent` — the uniqueness lemma is the key ingredient in the confluence-based proof strategy.

---

### Application Keywords

`compiler-optimization`, `tropical-geometry`, `program-cost-analysis`, `equality-saturation`, `rewrite-theory`, `tropical-valuation`, `minimum-description-length`, `Kolmogorov-complexity`, `circuit-minimization`, `symbolic-simplification`, `tropical-semiring`, `confluence-theory`

---

### Revolutionary Significance

This work establishes three paradigm shifts simultaneously:

1. **From Correctness to Optimality:** Rewrite theory has always guaranteed that normalization produces a *canonical* form. We prove it produces the *best* form. This transforms the theoretical foundation of every system that uses rewriting for optimization — from GHC's simplifier to Mathematica's algebraic simplifier to egg's equality saturation.

2. **Rewrite Theory Meets Tropical Geometry:** The tropical valuation theorem reveals that the quotient monoid of terms modulo a convergent rewrite system carries natural tropical geometric structure. This suggests that the space of all convergent rewrite systems over a fixed signature is itself a tropical variety, with deep connections to tropical Hilbert bases and tropical Gröbner theory.

3. **Optimization as Information Compression:** The information-theoretic interpretation shows that convergent rewriting is fundamentally an act of *compression* — finding the minimum-description-length representative. This unifies the optimization and compression viewpoints, suggesting that the fundamental limit of any optimizer for a given cost model is precisely the cost of the normal form.

**Follow-on work enabled:**
- Tropical Gröbner bases for non-convergent rewrite systems (where the "normal form" is replaced by the "tropical basis")
- Pareto-optimal extraction from equality saturation graphs using multi-cost tropical valuations
- Quantum rewrite systems where the cost function is replaced by a density matrix and tropical min is replaced by the von Neumann entropy

---

### Mandatory Deliverables

(a) **FUTURE_DIRECTIONS.md** with 3-5 testable scientific hypotheses, each falsifiable with a clear computational test.

(b) **RESEARCH_PAPER.md** — a standalone scientific document. Someone reading ONLY this paper must understand: (i) the cost-minimality theorem and its proof, (ii) the tropical valuation structure on rewrite monoids, (iii) the information-theoretic interpretation, (iv) the tropical universality conjecture and how to test it.

(c) **ARTICLE.md** in Scientific American style — engaging, accessible. TABOO: Do NOT focus on formal verification or machine verification. Write about the *ideas*: "Why is simplification always optimal? Because the math of rewriting and the math of tropical geometry are secretly the same."

(d) A **verified algorithm**: `tropical_cost_extract` that, given a convergent rewrite system and a cost-compatible function, computes the normal form and certifies its cost-minimality by producing a proof certificate.

(e) **demo.py** that: (i) generates random convergent rewrite systems over small signatures, (ii) computes normal forms and their costs, (iii) verifies cost-minimality by exhaustive enumeration of equivalent terms up to bounded depth, (iv) visualizes the tropical cost landscape of each equivalence class (cost on y-axis, terms on x-axis, normal form highlighted as the minimum), and (v) tests the Tropical Universality conjecture by solving the associated linear programs.

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
