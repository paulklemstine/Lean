## Assignment: Direction 3: Sparse Matrix Structure Preservation

**Mode:** `prove`

Prove genuinely new structural theorems about sparsity invariants for the tensor/matrix rewrite language in `Pythagorean/TensorSortedRewrite.lean`, extending semantic-correctness results to **resource-sensitive semantics**. The goal is not merely to show that normalization preserves denotation, but that it preserves a mathematically meaningful **computational geometry of support**. This is the point where symbolic algebra begins to speak to sparse numerical linear algebra.

The original conjecture, as stated, is too optimistic if interpreted for arbitrary matrix addition: the sum of two `s`-sparse rows can have up to `2s` nonzeros. So the first task is to **repair the conjecture into a sharp theorem** and then prove the strongest true statement.

---

## Core Vision

The distributivity rewrite system in the current fragment has no matrix-matrix multiplication. That means normalization should not create qualitatively new fill-in by propagation through products. But addition can still enlarge row support unless one tracks support combinatorics carefully. The breakthrough is to formalize a **support-sensitive denotational invariant**:

- exact preservation under scalar multiplication and syntactic reassociation/reordering,
- controlled growth under addition,
- and a global theorem that normalized terms satisfy an explicit **row-support bound determined by variable occurrence geometry**.

This would open a new direction: **formal support analysis for symbolic linear algebra**, with applications to finite element assembly, graph operators, sparse autodiff, and compiler optimization for scientific computing.

---

## New Mathematical Objects to Introduce

You must define at least one genuinely new concept not already in the catalog. I recommend introducing all of the following:

1. **Row sparsity predicate on semantic matrices**
   ```lean
   def RowSparse {n : ℕ} (s : ℕ) (A : Matrix (Fin n) (Fin n) ℝ) : Prop :=
     ∀ i : Fin n, {j : Fin n | A i j ≠ 0}.Finite ∧
       ({j : Fin n | A i j ≠ 0}.Finite.toFinset.card ≤ s)
   ```
   If `Finite.toFinset` causes friction, define row support as a `Finset` directly:
   ```lean
   def rowSupport {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) (i : Fin n) : Finset (Fin n) :=
     Finset.univ.filter (fun j => A i j ≠ 0)

   def RowSparse {n : ℕ} (s : ℕ) (A : Matrix (Fin n) (Fin n) ℝ) : Prop :=
     ∀ i : Fin n, (rowSupport A i).card ≤ s
   ```

2. **Support-bounded environments**
   ```lean
   def EnvRowSparse {n : ℕ} (ρ : String → Matrix (Fin n) (Fin n) ℝ) (s : ℕ) : Prop :=
     ∀ x, RowSparse s (ρ x)
   ```

3. **Occurrence-count / additive complexity of a term**
   This is the crucial corrective invariant.
   ```lean
   def matVarCount : TensorRewrite → ℕ
   ```
   or better, a support-sensitive count of matrix leaves contributing to each summand after distributive expansion. If the syntax supports matrix variables, scalar actions, and addition, define a recursively computable bound:
   ```lean
   def rowSparsityBudget : TensorRewrite → ℕ
   ```
   with intended meaning:
   - matrix variable contributes `1`,
   - scalar multiplication preserves budget,
   - addition adds budgets,
   - rewrites preserve or reduce the same budget up to equality.

4. Optionally, a stronger disjoint-support notion:
   ```lean
   def RowDisjoint {n : ℕ} (A B : Matrix (Fin n) (Fin n) ℝ) : Prop :=
     ∀ i j, A i j ≠ 0 → B i j = 0
   ```
   This allows proving exact `s`-preservation in a nontrivial special case.

These definitions are not bureaucratic; they are the language needed to state the true theorem.

---

## Precise Theorem Targets

You must prove **at least 3 substantial theorems**. The following are the right targets.

### Theorem 1: Addition gives controlled support growth
This is the foundational combinatorial lemma.

**Mathematical statement.**  
For all `n`, matrices `A B : Matrix (Fin n) (Fin n) ℝ`, and naturals `s t`, if `A` is row-`s`-sparse and `B` is row-`t`-sparse, then `A + B` is row-`(s+t)`-sparse.

**Lean 4 type signature**
```lean
theorem RowSparse.add
    {n s t : ℕ}
    {A B : Matrix (Fin n) (Fin n) ℝ} :
    RowSparse s A →
    RowSparse t B →
    RowSparse (s + t) (A + B)
```

**Why this matters.**  
This theorem isolates the only real source of fill-in in the fragment: union of supports under addition. It turns a vague sparsity-preservation hope into a precise support calculus.

---

### Theorem 2: Scalar multiplication preserves row sparsity
This is structurally simple but mathematically essential.

**Mathematical statement.**  
For all scalars `c ≠ 0`, if `A` is row-`s`-sparse then `c • A` is row-`s`-sparse. If you want a cleaner theorem, prove preservation for all scalars with `≤ s`; exact support equality for `c ≠ 0` can be a stronger lemma.

**Lean 4 type signature**
```lean
theorem RowSparse.smul
    {n s : ℕ}
    {c : ℝ}
    {A : Matrix (Fin n) (Fin n) ℝ} :
    RowSparse s A →
    RowSparse s (c • A)
```

**Stronger optional lemma**
```lean
theorem rowSupport_smul_eq
    {n : ℕ} {c : ℝ} (hc : c ≠ 0)
    (A : Matrix (Fin n) (Fin n) ℝ) (i : Fin n) :
    rowSupport (c • A) i = rowSupport A i
```

**Why this matters.**  
Distributive normalization pushes scalars through terms. If scalar action changed support unpredictably, the whole rewrite analysis would fail.

---

### Theorem 3: Semantic support bound for all terms
This is the real breakthrough theorem.

**Mathematical statement.**  
There exists a recursively computable syntactic quantity `rowSparsityBudget : TensorRewrite → ℕ` such that for every environment `ρ` whose matrix variables are row-`s`-sparse, evaluation of any term `t` is row-`(rowSparsityBudget t * s)`-sparse.

This theorem should be stated for the actual syntax of `TensorRewrite` in the catalog file. Adjust constructors accordingly.

**Lean 4 type signature (schematic)**
```lean
theorem evalMat_rowSparse_bound
    {n s : ℕ}
    (ρ : String → Matrix (Fin n) (Fin n) ℝ)
    (hρ : EnvRowSparse ρ s) :
    ∀ t : TensorRewrite,
      RowSparse (rowSparsityBudget t * s) (evalMat ρ t)
```

If `evalMat` also depends on scalar/vector environments, use the actual parameter list from the file:
```lean
theorem evalMat_rowSparse_bound
    {n s : ℕ}
    (ρM : String → Matrix (Fin n) (Fin n) ℝ)
    (ρV : String → (Fin n → ℝ))
    (ρS : String → ℝ)
    (hρM : EnvRowSparse ρM s) :
    ∀ t : TensorRewrite,
      RowSparse (rowSparsityBudget t * s) (evalMat ρS ρV ρM t)
```

**Why this is a breakthrough.**  
This upgrades semantic equality to **quantitative semantics**. The normal form is no longer just correct; it comes with a machine-checkable complexity certificate. This is exactly what sparse scientific computing needs.

---

### Theorem 4: Rewrite-step invariance of the budget
You should prove this if the rewrite relation is explicit.

**Mathematical statement.**  
Every one-step rewrite preserves `rowSparsityBudget`.

**Lean 4 type signature (schematic)**
```lean
theorem rewrite_preserves_rowSparsityBudget
    {t u : TensorRewrite} :
    RewriteStep t u →
    rowSparsityBudget t = rowSparsityBudget u
```

If equality is too strict, prove `≤` in the direction needed for normalization:
```lean
theorem rewrite_preserves_rowSparsityBudget
    {t u : TensorRewrite} :
    RewriteStep t u →
    rowSparsityBudget u ≤ rowSparsityBudget t
```

**Why this matters.**  
This is the bridge from term syntax to normalization: the sparsity certificate survives rewriting itself.

---

### Theorem 5: Normalization inherits the same support bound
This theorem ties everything together.

**Mathematical statement.**  
For every term `t`, the normalized term `normalize t` evaluates to a matrix with the same row-sparsity budget as `t`.

**Lean 4 type signature (schematic)**
```lean
theorem normalize_rowSparse_bound
    {n s : ℕ}
    (ρ : String → Matrix (Fin n) (Fin n) ℝ)
    (hρ : EnvRowSparse ρ s) :
    ∀ t : TensorRewrite,
      RowSparse (rowSparsityBudget t * s) (evalMat ρ (normalize t))
```

Using semantic correctness plus Theorem 3:
```lean
theorem normalize_rowSparse_bound
    {n s : ℕ}
    (ρ : String → Matrix (Fin n) (Fin n) ℝ)
    (hρ : EnvRowSparse ρ s) :
    ∀ t : TensorRewrite,
      RowSparse (rowSparsityBudget t * s) (evalMat ρ (normalize t))
```

---

### Theorem 6: Exact preservation under rowwise disjoint support
This recovers the spirit of the original conjecture under a sharp hypothesis.

**Mathematical statement.**  
If all additions occurring in a term combine matrices whose row supports are pairwise disjoint, then evaluation preserves the original row sparsity bound `s` rather than inflating it.

**Lean 4 type signature (schematic)**
```lean
theorem evalMat_rowSparse_exact_of_disjoint
    {n s : ℕ}
    (ρ : String → Matrix (Fin n) (Fin n) ℝ)
    (hρ : EnvRowSparse ρ s) :
    ∀ t : TensorRewrite,
      TermRowDisjoint ρ t →
      RowSparse s (evalMat ρ t)
```

**Why this matters.**  
This identifies the exact mechanism by which fill-in is avoided: not distributivity alone, but disjointness of support. This is highly relevant to graph coloring, block assembly, and finite element locality.

---

## Corrected Conjecture and Falsifiable Prediction

The original conjecture should be replaced by a testable and mathematically plausible version:

### Conjecture A: Budget-sharp sparsity theorem
For every term `t`, the smallest universal row-sparsity bound for `evalMat ρ t` over all row-`s`-sparse environments is exactly `rowSparsityBudget t * s`.

This is falsifiable: search for terms where the observed maximal row support exceeds or is strictly smaller than the predicted budget. If many terms are strictly smaller, the budget is not sharp and should be refined.

### Conjecture B: Typical-case subadditivity under random supports
For random `s`-sparse environments with low collision probability, the expected row support after normalization grows like
`Θ(s * effective_leaf_count)` only until collision saturation, then transitions to a coupon-collector regime strictly below the worst-case bound.

This links symbolic normalization to probabilistic combinatorics on supports.

**Computational test.**
Generate 5,000 random CSR matrices with `n = 100`, `s = 5`, and random terms of depth 4. For each term:
- compute `rowSparsityBudget t`,
- evaluate all intermediate and normalized terms,
- record maximum row support,
- compare observed maximum to predicted bound `rowSparsityBudget t * s`,
- estimate average collision factor
  ```text
  observed_max_row_support / (rowSparsityBudget t * s).
  ```
A counterexample is any observed row support exceeding the bound.

---

## Proof Strategy Architecture

You must present and pursue at least 2–3 proof paths. Here are the best ones.

### Strategy A: Direct support-set combinatorics
**Most promising.**

1. Define `rowSupport A i := Finset.univ.filter (fun j => A i j ≠ 0)`.
2. Prove set-theoretic containments:
   - `rowSupport (A + B) i ⊆ rowSupport A i ∪ rowSupport B i`
   - `rowSupport (c • A) i ⊆ rowSupport A i`
   - equality in the scalar case if `c ≠ 0`.
3. Convert containments into cardinality bounds using `Finset.card_le_card`, `Finset.card_union_le`, and recursive induction on terms.

**Why this is best.**  
It is local, constructive, and aligns perfectly with Lean’s finite combinatorics library. It also yields explicit algorithms for support extraction.

---

### Strategy B: Induction on syntax with a weighted semiring invariant
1. Define `rowSparsityBudget` recursively on `TensorRewrite`.
2. Prove by structural induction that `evalMat` maps terms into matrices bounded by this budget.
3. Use rewrite preservation lemmas to transfer the bound to normal forms.

**Why this is strong.**  
This exposes normalization as a semantics in the semiring of resource bounds. It is conceptually deeper and scales to future invariants: bandwidth, block sparsity, graph treewidth proxies.

---

### Strategy C: Graph-theoretic interpretation of support
1. Interpret each matrix as a directed graph on `Fin n`, with row support equal to out-neighborhood size.
2. Show addition corresponds to union of edge sets and scalar multiplication preserves edge sets up to deletion at zero scalar.
3. Interpret terms as graph expressions and prove degree bounds via graph union combinatorics.

**Why this matters.**  
This is the cross-domain bridge: sparse matrices are graphs. A theorem about symbolic matrix normalization becomes a theorem about graph degree growth under algebraic rewrites. This could seed later work on Laplacians, message passing, and sparse PDE discretizations.

---

## Required Deep Tactics

At least 3 theorems must use nontrivial proof structure. Concretely:

- Use **induction** on `TensorRewrite` for `evalMat_rowSparse_bound`.
- Use **rcases** on term constructors or support membership proofs.
- Use **by_contra** for support containment lemmas: if `j ∉ rowSupport A i ∪ rowSupport B i` but `j ∈ rowSupport (A+B) i`, derive contradiction from `A i j = 0` and `B i j = 0`.
- Use **calc** blocks for cardinality estimates.
- If scalars introduce rational expressions or ring-side normalization, use `field_simp` where genuinely needed, but do not manufacture algebra just to satisfy the requirement.

Avoid all trivial closure by automation. The point is to build a reusable proof architecture.

---

## Cross-Domain Connections You Must Make Explicit

### 1. Numerical linear algebra ↔ graph theory
A row-sparse matrix is a bounded-outdegree graph. Your support theorems become degree-growth theorems under graph union.

### 2. Sparse symbolic algebra ↔ finite element methods
Element stiffness matrices are sparse because basis functions have local support. Rewrite systems used to simplify operator expressions are only useful if they preserve this locality structure.

### 3. Compiler verification ↔ scientific computing
A rewrite engine with certified support bounds is effectively a verified sparse-optimization pass for tensor algebra DSLs.

### 4. Algebraic rewriting ↔ probabilistic combinatorics
Random sparse supports produce collision phenomena; the worst-case theorem and average-case experiments together create a new interface between formal algebra and random graph models.

### 5. Matrix support ↔ physics
Local Hamiltonians and discretized differential operators are sparse because interactions are local. Sparsity-preserving normalization is therefore relevant to lattice models, quantum simulation preprocessing, and operator compression.

---

## Application Keywords

Use these explicitly in your paper and article:

`sparse matrices`, `row support`, `fill-in control`, `symbolic linear algebra`, `finite elements`, `graph Laplacians`, `sparse tensor rewriting`, `locality preservation`, `scientific computing`, `compiler optimization`, `CSR matrices`, `support combinatorics`, `resource-aware normalization`, `operator locality`, `degree-bounded graphs`.

---

## Concrete Lean Work Plan

1. Inspect `Pythagorean/TensorSortedRewrite.lean` and identify:
   - the exact syntax constructors of `TensorRewrite`,
   - the signatures of `evalMat`, `evalVec`, and normalization/rewrite relations.

2. Add support infrastructure:
   - `rowSupport`
   - `RowSparse`
   - `EnvRowSparse`
   - `rowSparsityBudget`

3. Prove support lemmas for semantic operations:
   - zero matrix,
   - matrix variable,
   - scalar multiplication,
   - addition.

4. Prove the induction theorem `evalMat_rowSparse_bound`.

5. Prove rewrite preservation of the budget and transfer the result to normalized terms.

6. If feasible, formalize the exact-preservation theorem under disjoint support.

7. Implement a verified computational checker that computes row supports and validates the proven upper bound on concrete examples.

---

## Deliverables (MANDATORY)

You must produce **all** of the following:

### 1. `FUTURE_DIRECTIONS.md`
Provide 3–5 original research directions. Each direction must include:
- a sentence beginning **“The key insight is...”**
- a sentence beginning **“Why now?”**
At least one direction must bridge to a different domain, such as graph theory, PDEs, statistical physics, or compiler optimization.

Suggested future directions:
- block sparsity and hierarchical matrices,
- bandwidth/treewidth-aware rewrite bounds,
- probabilistic support growth under random environments,
- sparse autodiff and Jacobian compression,
- local Hamiltonian simplification.

### 2. `RESEARCH_PAPER.md`
A standalone scientific paper explaining:
- the corrected conjecture,
- the new support-bounded semantics,
- the main theorems,
- why the original naive sparsity-preservation statement fails,
- how the formal theorem repairs it,
- computational experiments and sharpness questions,
- future research implications.

This document must make sense to a mathematician or numerical analyst reading it without code access.

### 3. `ARTICLE.md`
Write this in Scientific American style. Explain:
- why sparsity is the lifeblood of large-scale computation,
- how symbolic simplification can accidentally destroy locality,
- what your theorem guarantees instead,
- why this matters for simulations, networks, and physics.

Do **not** focus on formal verification machinery; focus on the mathematics and scientific significance.

### 4. Verified algorithm / computational method
Implement a certified procedure that:
- computes `rowSupport`,
- checks `RowSparse s A`,
- computes `rowSparsityBudget t`,
- verifies on concrete inputs that `evalMat ρ t` respects the proven bound.

This must be more than a theorem statement; it must be an executable mathematical method.

### 5. `demo.py`
Create an interactive demo that:
- generates random sparse matrices in CSR-style data,
- builds random tensor terms of bounded depth,
- computes the predicted support bound from syntax,
- evaluates terms before and after normalization,
- visualizes row-support sizes and sparsity ratios,
- flags any violation of the proven theorem.

The demo should also illustrate why the naive “always preserves `s`” conjecture fails, by exhibiting a simple addition example with support growth.

---

## Final Intellectual Goal

Do not merely show that rewriting is semantically correct. Show that it is **structurally disciplined**: it preserves locality up to a sharp, computable support budget. That is a qualitatively different theorem. It transforms tensor normalization from a correctness-only tool into a sparse-scientific-computing principle.

The field-opening move here is to treat rewrite systems as objects with **complexity semantics**. Once that door is open, sparsity is only the first invariant. Bandwidth, block structure, graph expansion, and even PDE locality are next.

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
