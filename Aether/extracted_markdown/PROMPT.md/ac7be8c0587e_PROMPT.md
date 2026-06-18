## Assignment: Direction 2: Multi-Sorted Signatures and Typed Rewriting

Prove new, non-trivial theorems. Build on catalog theorems. Minimize sorry.

## Depth Requirements (MANDATORY)

Your output must satisfy ALL of these:

1. **NO trivial proofs**: Do NOT prove statements by `native_decide`, `decide`, `norm_num`, or `rfl` unless the statement itself is genuinely important. If the only proof tactic is enumeration, the theorem is not worth formalizing.

2. **At least 3 theorems with deep proof tactics**: Your file must contain at least 3 theorems proven using induction, rcases, by_contra, field_simp, or multi-step calc reasoning.

3. **Novel definitions**: Define at least one new mathematical structure or concept that does not already exist in the Catalog. Check the catalog references to confirm novelty.

4. **Cross-domain connections**: Include at least one theorem that connects your domain to a different mathematical domain (e.g., number theory + tropical geometry, algebra + physics).

5. **Conjecture with testable prediction**: State at least one falsifiable conjecture with a clear computational test that could disprove it.

---

### Research Direction: Multi-Sorted Master Theorem — Subject Reduction Meets Convergent Rewriting

**Core Theorem (Multi-Sorted Master Theorem)**. Let $\Sigma = (S, \Omega)$ be a multi-sorted signature with sort set $S$ and typed operations $\Omega$, and let $R$ be a convergent, sort-preserving rewrite system over $\Sigma$. For any $\Sigma$-algebra $A$ satisfying the equations encoded by $R$, and any well-sorted term $t : \mathsf{MultiTerm}\ \Sigma\ s$, evaluation is invariant under normalization:

$$\mathsf{eval}_A(\mathsf{nf}_R(t), \rho) = \mathsf{eval}_A(t, \rho)$$

where $\rho$ is a sorted environment and $\mathsf{nf}_R$ denotes the normal form under $R$.

**Lean 4 Type Signatures**:

```lean
-- Multi-sorted signature
structure MultiSig where
  Sort : Type*
  numOps : ℕ
  arity : Fin numOps → ℕ
  argSorts : (f : Fin numOps) → Fin (arity f) → Sort
  resultSort : (f : Fin numOps) → Sort

-- Well-sorted terms (dependent inductive type)
inductive MultiTerm (Σ : MultiSig) : Σ.Sort → Type*
  | var : (s : Σ.Sort) → ℕ → MultiTerm Σ s
  | op : (f : Fin Σ.numOps) → 
         (args : (i : Fin (Σ.arity f)) → MultiTerm Σ (Σ.argSorts f i)) →
         MultiTerm Σ (Σ.resultSort f)

-- Multi-sorted algebra
structure MultiSigAlgebra (Σ : MultiSig) where
  carrier : Σ.Sort → Type*
  interp : (f : Fin Σ.numOps) → 
           ((i : Fin (Σ.arity f)) → carrier (Σ.argSorts f i)) →
           carrier (Σ.resultSort f)

-- Sort-preserving rewrite system
structure SortPreservingRewriteSystem (Σ : MultiSig) extends RewriteSystem (MultiTerm Σ) where
  sort_preserving : ∀ {s : Σ.Sort} {t₁ t₂ : MultiTerm Σ s}, 
                     Reduces t₁ t₂ → ∃ h : t₂.sort = s, cast h t₂ = t₂

-- Master theorem
theorem convergent_nf_preserves_eval_multi_sorted 
    {Σ : MultiSig} {R : SortPreservingRewriteSystem Σ}
    (h_convergent : R.IsConvergent)
    {A : MultiSigAlgebra Σ} (h_A_models : A ⊨ R.equations)
    {s : Σ.Sort} {t : MultiTerm Σ s} {ρ : SortedEnv Σ A} :
    (nf R t).eval A ρ = t.eval A ρ := by
  sorry
```

**Key Sub-Theorems** (build these first):

```lean
-- 1. Sort-preservation of one-step reduction
theorem one_step_preserves_sort {Σ : MultiSig} {R : SortPreservingRewriteSystem Σ}
    {s : Σ.Sort} {t₁ : MultiTerm Σ s} {t₂ : MultiTerm Σ ?m} 
    (h : Reduces t₁ t₂) : t₂.sort = s

-- 2. Substitution respects sorts (the technical crux)
theorem subst_respects_sorts {Σ : MultiSig} {s : Σ.Sort} {t : MultiTerm Σ s}
    {σ : (s' : Σ.Sort) → ℕ → MultiTerm Σ s'} 
    (h_well_sorted : ∀ s' n, (σ s' n).sort = s') :
    (t.subst σ).sort = s

-- 3. Evaluation commutes with sort-preserving substitution
theorem eval_subst_comm {Σ : MultiSig} {A : MultiSigAlgebra Σ}
    {s : Σ.Sort} {t : MultiTerm Σ s}
    {σ : (s' : Σ.Sort) → ℕ → MultiTerm Σ s'}
    {ρ : SortedEnv Σ A} :
    t.eval A (substEnv σ ρ) = (t.subst σ).eval A ρ
```

### Proof Strategy

**Strategy A: Dependent-Type Direct Generalization** (Most promising — exploits Lean 4's type system)

The proof follows the single-sorted structure from `Pythagorean/ConvergentRewriteSystems.lean` but every lemma acquires sort-indexed dependencies. The key insight is that Lean 4's dependent type system *is* the proof-relevant version of sort constraints:

1. **Define `MultiTerm` as a dependent inductive** indexed by `Σ.Sort`. Well-sortedness is enforced by construction — ill-typed terms simply cannot be constructed. This eliminates an entire class of proof obligations that would arise in an untyped encoding.

2. **Prove substitution respects sorts** via induction on `MultiTerm`. The dependent pattern matching in Lean 4 makes this almost automatic: when `t = op f args`, the induction hypothesis gives `args i : MultiTerm Σ (argSorts f i)`, so substitution produces terms of the correct sorts. The critical technical lemma is `subst_respects_sorts`.

3. **Adapt the evaluation-preservation proof** by replacing the single `carrier : Type*` with the sorted `carrier : Σ.Sort → Type*`. The `convergent_nf_preserves_eval` proof structure carries over verbatim because substitution commutes with evaluation (by `eval_subst_comm`), and normalization only produces sort-preserving rewrites.

**Why this works**: The dependent types make sort-preservation *definitionally true* for well-typed terms, reducing the proof burden to showing that the rewrite system itself respects sorts (which is a property of $R$, not of individual terms).

**Strategy B: Coproduct Encoding Reduction** (Elegant but requires encoding faithfulness)

Encode $\Sigma = (S, \Omega)$ as a single-sorted signature $\Sigma'$ with carrier $C = \bigsqcup_{s \in S} s$ and operations that check sort tags at runtime. Prove:
- The encoding $\Sigma \mapsto \Sigma'$ preserves convergence
- Normal forms in $\Sigma'$ project to normal forms in $\Sigma$
- Evaluation in $\Sigma'$-algebras restricts to evaluation in $\Sigma$-algebras

Then invoke the existing single-sorted Master Theorem. The encoding theorem itself is non-trivial and interesting.

**Strategy C: Categorical/Lawvere Theory Approach** (Deepest insight, hardest to formalize)

Multi-sorted $\Sigma$-algebras are models of a multi-sorted Lawvere theory $\mathcal{L}_\Sigma$, which is a category with finite products whose objects are $S$-indexed finite powers. The term algebra is the free model, and convergent rewriting gives a natural isomorphism between the identity and normalization functors on the category of models satisfying $R$. This gives the cleanest proof but requires substantial category-theoretic infrastructure.

**Recommended approach**: Strategy A for the main formalization, with Strategy B proved as a corollary showing the two approaches are equivalent.

### Cross-Domain Connections

**1. Type Theory ↔ Universal Algebra (Subject Reduction Theorem)**:

The sort-preservation condition `∀ {s} {t₁ t₂ : MultiTerm Σ s}, Reduces t₁ t₂ → t₂.sort = s` is *exactly* the subject reduction theorem from type theory (a.k.a. type preservation). Prove:

```lean
-- Subject reduction for multi-sorted rewriting
-- This bridges rewriting theory and type theory
theorem subject_reduction {Σ : MultiSig} {R : SortPreservingRewriteSystem Σ}
    {s : Σ.Sort} {t : MultiTerm Σ s} {t' : MultiTerm Σ s}
    (h_step : Reduces R t t') : t'.sort = s
```

This connects to the Curry-Howard correspondence: well-sorted terms are proofs, and sort-preserving rewriting is proof normalization.

**2. Category Theory ↔ Programming Languages (Lawvere Theories and Monads)**:

Multi-sorted algebras are algebras for a monad on `Type* → Type*` (the sorted-set functor). Prove the multi-sorted Eilenberg-Moore adjunction:

```lean
-- Free algebra is left adjoint to forgetful
theorem free_forget_adjunction (Σ : MultiSig) :
    Adjunction (freeAlgebraFunctor Σ) (forgetfulFunctor Σ)
```

This connects to monadic semantics of effectful programming languages (Wadler's monads for effects).

**3. Algebraic Geometry ↔ Rewriting (Sorted Gröbner Bases)**:

For a multi-sorted signature with sorts for scalars and vectors, convergent rewrite systems correspond to sorted Gröbner bases. The sort constraints ensure polynomial operations respect the vector/scalar distinction. Prove:

```lean
-- Multi-sorted Buchberger criterion
theorem sorted_buchberger_criterion {K : Type*} [Field K] :
    IsConvergent R ↔ ∀ p q : SortedBasisElement, 
      SortedSPair p q ∈ SortedIdeal (R.basis) → 
      SortedNF (SortedSPair p q) R = 0
```

### Novel Definitions Required

1. **`MultiSig`**: Multi-sorted signature with dependent operation types (does not exist in catalog)
2. **`MultiTerm`**: Dependently-typed term algebra indexed by sorts (novel use of Lean 4's dependent inductives)
3. **`SortPreservingRewriteSystem`**: Rewrite system with subject reduction property (bridges PL theory and universal algebra)
4. **`SortedGradedMonoid`**: A graded monoid structure on sorts where composition respects the grading (connects to homological algebra)

### Conjecture with Testable Prediction

**Conjecture (Sorted Confluence Complexity)**: For a multi-sorted signature with $|S|$ sorts and maximum operation arity $a$, the number of sort-respecting critical pairs is at most $\binom{|S|}{2} \cdot a^2 \cdot |R|^2$ where $|R|$ is the number of rewrite rules. Moreover, if the rewrite system is sort-decreasing (the result sort of each rule is ≤ the source sort in a partial order on $S$), then the number of critical pairs is at most $|S| \cdot a^2 \cdot |R|^2$.

**Test**: Generate 100 random multi-sorted signatures with 2–5 sorts and 5–20 operations. For each, generate random sort-preserving rewrite systems with 3–10 rules. Count the actual number of sort-respecting critical pairs and compare against the bound. The conjecture is falsified if any signature exceeds the bound.

**Impact**: This gives polynomial bounds on completion algorithms for multi-sorted systems, directly applicable to type-preserving compiler optimizations and automated theorem proving in multi-sorted logics.

### Revolutionary Significance

This work opens three fields simultaneously:

1. **Certified type-preserving compilation**: Every compiler IR is a multi-sorted algebra. The Master Theorem gives a *proof-relevant* guarantee that optimization passes (convergent rewrite systems) preserve semantics. This is the formal foundation for verified compilers like CompCert and MLIR.

2. **Multi-sorted algebraic geometry**: Sorted Gröbner bases enable computational algebra over mixed-type polynomial systems (e.g., scalar-vector polynomial equations arising in robotics and quantum mechanics).

3. **Categorical universal algebra**: The Lawvere theory perspective unifies multi-sorted rewriting with monadic computation, connecting algebraic specification languages (CASL, Maude) to categorical semantics (Lawvere theories, operads).

**Application Keywords**: `subject-reduction`, `type-preservation`, `many-sorted-algebra`, `Lawvere-theory`, `sorted-Gröbner-basis`, `verified-compilation`, `algebraic-specification`, `dependent-type-theory`

### Catalog References

- `Pythagorean/ConvergentRewriteSystems.lean`: `Sig`, `Term`, `SigAlgebra`, `convergent_nf_preserves_eval` — the single-sorted foundation to generalize
- `Mathlib.Algebra.Category.Module.Monoidal`: Monoidal structure on modules — pattern for sorted carrier types
- `Mathlib.Category.Theory.Adjunction`: For the free-forgetful adjunction
- `Mathlib.Algebra.GradedMonoid`: For sorted graded structures

### Required Deliverables

(a) **FUTURE_DIRECTIONS.md** with 3–5 testable hypotheses including:
   - The Sorted Confluence Complexity conjecture above
   - A conjecture on the relationship between sort-decreasing systems and termination orderings
   - A conjecture connecting multi-sorted rewriting to operad composition

(b) **RESEARCH_PAPER.md** — standalone scientific document presenting the Multi-Sorted Master Theorem, its proof via dependent types, and the connections to type theory, categorical algebra, and computational algebra

(c) **ARTICLE.md** — Scientific American style, framing the result as: "Why Type Systems and Algebra Are the Same Thing — And Why That Matters for Software Correctness"

(d) A verified `multi_sorted_nf` algorithm that computes normal forms for multi-sorted terms with sort-preservation proofs

(e) **demo.py** — generates random multi-sorted signatures, random sort-preserving rewrite systems, computes normal forms, and verifies evaluation preservation experimentally

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
