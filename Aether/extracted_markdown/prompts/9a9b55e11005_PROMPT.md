## Assignment: Direction 3: Multi-Sorted Quotient Optimizers — Fibrational Correctness and Sort-Selective Normalization

Prove new, non-trivial theorems. Build on catalog theorems. Minimize sorry.

## Depth Requirements (MANDATORY)

Your output must satisfy ALL of these:

1. **NO trivial proofs**: Do NOT prove statements by `native_decide`, `decide`, `norm_num`, or `rfl` unless the statement itself is genuinely important.
2. **At least 3 theorems with deep proof tactics**: Your file must contain at least 3 theorems proven using induction, rcases, by_contra, field_simp, or multi-step calc reasoning.
3. **Novel definitions**: Define at least one new mathematical structure or concept that does not already exist in the Catalog.
4. **Cross-domain connections**: Include at least one theorem that connects your domain to a different mathematical domain.
5. **Conjecture with testable prediction**: State at least one falsifiable conjecture with a clear computational test that could disprove it.

---

### The Visionary Theorem

**Main Theorem (Fibrational Correctness of Sort-Selective Normalization):** Let $(\Sigma, S)$ be a multi-sorted signature with sort set $S = \{S_1, \ldots, S_k\}$, let $\mathcal{A}$ be a $\Sigma$-algebra with carrier family $\{A_s\}_{s \in S}$, and let $\{\sim_s\}_{s \in S}$ be a sort-indexed family of congruences where $\sim_s$ is the identity relation for $s \notin T \subseteq S$ (the "normalized sorts"). If $\text{norm}_s : A_s \to A_s$ is a normalization function satisfying (i) $\text{norm}_s(a) \sim_s a$ for all $a \in A_s$, and (ii) $\text{norm}_s$ is the identity for $s \notin T$, then for every well-sorted term $t$ of sort $s$ and every sort-respecting environment $\rho$:

$$\llbracket t \rrbracket_{\mathcal{A}}(\rho) \sim_s \llbracket \text{normalize}(t) \rrbracket_{\mathcal{A}}(\rho)$$

where $\text{normalize}$ applies $\text{norm}_{s'}$ to every subterm of sort $s' \in T$.

**In Lean 4 (two-sorted specialization — Module over Ring):**

```lean
structure TwoSortedQuotientOptimizer (R M : Type*) [Ring R] [AddCommGroup M] [Module R M] where
  ring_norm : R → R
  ring_congr : R → R → Prop
  ring_norm_sound : ∀ r, ring_congr (ring_norm r) r
  ring_congr_equiv : Equivalence ring_congr
  ring_congr_add : ∀ a b, ring_congr a b → ring_congr (a + c) (b + c)
  ring_congr_mul : ∀ a b, ring_congr a b → ring_congr (a * c) (b * c)
  -- Key: ring congruence is compatible with module action
  ring_congr_smul : ∀ (r₁ r₂ : R) (m : M), ring_congr r₁ r₂ → r₁ • m = r₂ • m

theorem sort_selective_preserves_eval {R M : Type*} [CommRing R] [AddCommGroup M] [Module R M]
    (opt : TwoSortedQuotientOptimizer R M)
    (e : RingModuleExpr R M)  -- expression language mixing both sorts
    (env : RingModuleEnv R M)  -- sort-respecting environment
    : evalExpr e env ≈ evalExpr (normalizeExpr opt.ring_norm e) env
```

where `≈` is the pointwise equivalence induced by `ring_congr` on R-sorted subterms and propositional equality on M-sorted subterms.

### Why This Is a Breakthrough

The single-sorted `QuotientOptimizer` is a known pattern. But **sort-selective normalization** — normalizing *only some sorts* while preserving correctness of expressions that mix multiple sorts — is the key enabling technology for:

1. **Verified compiler passes for typed languages**: You can normalize the "base type" computations (integers, booleans) without re-verifying the "container type" computations (lists, trees).
2. **Modular proof transport**: If you change the ring implementation but the module is abstract, you don't need to re-verify module-level theorems.
3. **Fibrational semantics**: The family `{norm_s}_{s∈S}` defines a *cartesian section* of the fibration of algebras over their sort-indexed carriers — this is Grothendieck fibrational algebra, but now computationally realized.

### Proof Strategies

**Strategy A: Sort-by-Sort Structural Induction (Most Promising)**
1. Define `normalizeExpr` recursively: for each subterm of sort $s \in T$, apply `norm_s`; for $s \notin T$, leave unchanged.
2. Prove `preserves_eval` by structural induction on the expression `e`.
3. The inductive step for an operation $f : S_{i_1} \times \cdots \times S_{i_n} \to S_j$ requires showing: if each argument is preserved up to $\sim_{S_{i_k}}$, then $f(\text{norm}(a_1), \ldots, \text{norm}(a_n)) \sim_{S_j} f(a_1, \ldots, a_n)$.
4. **Critical lemma**: `ring_congr_smul` — the ring congruence is compatible with the scalar action on the module. This is the *only* non-trivial cross-sort condition.
5. This is most promising because it reduces to one key cross-sort lemma, and the rest follows by the same pattern as the single-sorted case.

**Strategy B: Functorial Semantics Approach**
1. View the multi-sorted algebra as a product-preserving functor $F : \mathcal{C}_\Sigma \to \mathbf{Set}$ where $\mathcal{C}_\Sigma$ is the syntactic category of the signature.
2. The normalization family defines a natural transformation $\eta : F \Rightarrow F$ with $\eta_s = \text{norm}_s$.
3. Prove that $\eta$ is idempotent (normalization is idempotent) and that $\eta$ preserves evaluation because it is a natural transformation.
4. **Challenge**: Formalizing the syntactic category in Lean is heavy. Better to use Strategy A and *state* the functorial interpretation as a remark.

**Strategy C: Quotient-Certified Transport**
1. Define the quotient algebra $\mathcal{A}/\!\!\sim$ where $\sim$ is the sort-indexed congruence.
2. Show that normalization defines a *section* of the quotient map: $q \circ \text{norm}_s = \text{id}$ in the quotient.
3. Evaluation in $\mathcal{A}/\!\!\sim$ is preserved trivially; lift back to $\mathcal{A}$ via the section.
4. **Challenge**: Requires quotient construction for multi-sorted algebras, which Mathlib may not have directly. Build it for the two-sorted case.

**Recommendation**: Use Strategy A as the primary proof, with Strategy C as a supporting construction (define the quotient ring $R/\text{ring\_congr}$ and show `ring_congr_smul` means the module descends to $R/\text{ring\_congr}$).

### Cross-Domain Connections

**Connection 1: Change of Rings (Algebra → Module Theory)**
The condition `ring_congr_smul` is exactly the condition that the module $M$ descends to a module over the quotient ring $R/\!\!\sim$. This is the classical *change of rings* construction. Prove:

```lean
theorem descends_to_quotient_module (opt : TwoSortedQuotientOptimizer R M) :
    ∃ (M' : Type*) (_ : AddCommGroup M') (_ : Module (Quotient opt.ring_congr_setoid) M'),
      Nonempty (M ≃+ M')
```

**Connection 2: Categorical Fibrations (Universal Algebra → Category Theory)**
The family `{norm_s}` is a *cartesian morphism* in the Grothendieck construction of the indexed family `{A_s : Type*}_{s ∈ S}`. State and prove that the normalization section satisfies the Beck-Chevalley condition for pullbacks along sort-preserving maps.

**Connection 3: Programming Language Semantics (Algebra → PL)**
The two-sorted case models a typed lambda calculus with base types (Ring) and effect types (Module). Sort-selective normalization is exactly *type-directed partial evaluation* (TDPE), a known technique in partial evaluation. Prove that TDPE preserves observational equivalence when the base-type normalizer is correct.

### Required Definitions (Novel Structures)

```lean
/-- A two-sorted expression language mixing ring and module operations -/
inductive RingModuleExpr (R M : Type*) where
  | ring_lit : R → RingModuleExpr R M           -- ring literal
  | mod_lit : M → RingModuleExpr R M            -- module literal
  | ring_add : RingModuleExpr R M → RingModuleExpr R M → RingModuleExpr R M
  | ring_mul : RingModuleExpr R M → RingModuleExpr R M → RingModuleExpr R M
  | mod_add : RingModuleExpr R M → RingModuleExpr R M → RingModuleExpr R M
  | smul : RingModuleExpr R M → RingModuleExpr R M → RingModuleExpr R M
  -- Sort annotation via a function:
  | «sort» : RingModuleExpr R M → SortTag

inductive SortTag where | ring | module

/-- Sort-respecting environment -/
structure RingModuleEnv (R M : Type*) where
  ring_env : R
  mod_env : M

/-- Pointwise equivalence mixing ring congruence and module equality -/
def ExprEquiv (opt : TwoSortedQuotientOptimizer R M)
    (e₁ e₂ : RingModuleExpr R M) : Prop :=
  match e₁.sort, e₂.sort with
  | SortTag.ring, SortTag.ring => opt.ring_congr (evalExpr e₁ default).ring (evalExpr e₂ default).ring
  | SortTag.module, SortTag.module => evalExpr e₁ default = evalExpr e₂ default
  | _, _ => False
```

### Required Theorems (Deep Proofs)

1. **`sort_selective_preserves_eval`** — The main theorem. Proof by structural induction on `e`. The `smul` case requires `ring_congr_smul`. The `ring_add` and `ring_mul` cases require the congruence compatibility lemmas. **Tactics**: `induction`, `rcases`, `calc`.

2. **`normalize_idempotent`** — `normalizeExpr norm (normalizeExpr norm e) = normalizeExpr norm e` when `norm` is idempotent. Proof by structural induction. **Tactics**: `induction`, `simp`.

3. **`quotient_module_exists`** — The cross-domain theorem: if `ring_congr_smul` holds, then $M$ carries a canonical $R/\!\!\sim$-module structure. Proof requires constructing the scalar action on the quotient and verifying axioms. **Tactics**: `rcases`, `field_simp`, multi-step `calc`.

4. **`preserves_eval_functorial`** — If `norm₁ ≤ norm₂` (pointwise in the congruence order), then the normalized evaluation of `norm₂` is a refinement of `norm₁`. **Tactics**: `by_contra`, `constructor`.

### Falsifiable Conjecture with Computational Test

**Conjecture (Partial Normalization Completeness):** For any two-sorted algebra $(R, M)$ with $R$ a commutative ring and $M$ a free $R$-module of rank $n$, if `ring_norm` is a complete rewriting system for $R$ (every $R$-element reduces to a unique normal form), then sort-selective normalization with `ring_norm` achieves *full* observational equivalence: for all expressions $e_1, e_2$ of module sort, $\llbracket e_1 \rrbracket = \llbracket e_2 \rrbracket$ iff `normalizeExpr` produces syntactically identical expressions.

**Test**: Instantiate $R = \mathbb{Z}/6\mathbb{Z}$, $M = (\mathbb{Z}/6\mathbb{Z})^3$ (free module of rank 3), `ring_norm` = canonical representative in $\{0, 1, 2, 3, 4, 5\}$. Generate 5,000 random mixed expressions. For each pair of expressions that evaluate to the same module element, check whether normalization produces the same normalized expression. **If any pair evaluates equally but normalizes differently, the conjecture is falsified.** (Expected: the conjecture is FALSE — different expressions producing the same module element need not normalize identically, revealing that sort-selective normalization is sound but incomplete for observational equivalence.)

### Catalog Building Blocks

From `Pythagorean/QuotientOptimizer.lean`:
- `QuotientOptimizer` structure: Extend the field list from `{carrier, rel, norm, ...}` to a sort-indexed family.
- `preserves_eval`: The proof pattern (structural induction + congruence compatibility) generalizes directly.
- Build on `norm_sound : ∀ a, rel (norm a) a` — now we need one per sort, with the identity for unnormalized sorts.

### Mandatory Deliverables

(a) **FUTURE_DIRECTIONS.md** with 5 testable hypotheses:
   1. Partial normalization completeness for free modules (the conjecture above).
   2. Three-sorted extension: ring-module-homomorphism sorts, with normalization only on the ring.
   3. Computational complexity: sort-selective normalization reduces verification cost by a factor of $|T|/|S|$ compared to full normalization.
   4. Fibrational Beck-Chevalley: the normalization section satisfies the Beck-Chevalley condition for reindexing along sort-preserving maps.
   5. Connection to dependent type theory: multi-sorted QuotientOptimizer gives a normalization result for PTS-style type theories.

(b) **RESEARCH_PAPER.md**: Standalone paper titled "Sort-Selective Normalization and Fibrational Correctness for Multi-Sorted Algebras" — must include the main theorem, the quotient module descent result, the connection to change of rings, and the falsified completeness conjecture.

(c) **ARTICLE.md**: Scientific American style — "When Can You Simplify Just Part of a Calculation? The Mathematics of Selective Normalization" — explain via the analogy: you can simplify the recipe without changing the dish, as long as the ingredients interact the same way.

(d) **Verified algorithm**: `normalizeExpr` with a certified `sort_selective_preserves_eval` theorem.

(e) **demo.py**: Interactive demo showing sort-selective normalization on $\mathbb{Z}/6\mathbb{Z}$-module expressions, displaying the normalized forms and verifying evaluation preservation on random inputs. Include a counterexample generator for the completeness conjecture.

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
