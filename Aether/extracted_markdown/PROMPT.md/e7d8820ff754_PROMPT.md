## Soli Deo Gloria

## Assignment: Direction 3: Multi-Sorted Quotient Optimizers — The Interaction Principle

Prove new, non-trivial theorems. Build on catalog theorems. Minimize sorry.

## Depth Requirements (MANDATORY)

Your output must satisfy ALL of these:

1. **NO trivial proofs**: Do NOT prove statements by `native_decide`, `decide`, `norm_num`, or `rfl` unless the statement itself is genuinely important. If the only proof tactic is enumeration, the theorem is not worth formalizing.

2. **At least 3 theorems with deep proof tactics**: Your file must contain at least 3 theorems proven using induction, rcases, by_contra, field_simp, or multi-step calc reasoning.

3. **Novel definitions**: Define at least one new mathematical structure or concept that does not already exist in the Catalog. Check the catalog references to confirm novelty.

4. **Cross-domain connections**: Include at least one theorem that connects your domain to a different mathematical domain (e.g., number theory + tropical geometry, algebra + physics).

5. **Conjecture with testable prediction**: State at least one falsifiable conjecture with a clear computational test that could disprove it.

---

### Research Direction: The Interaction Principle in Multi-Sorted Quotient Optimization

**Central Discovery Target**: The passage from single-sorted to multi-sorted quotient optimizers is NOT merely a generalization — it reveals a fundamentally new phenomenon: **sort interaction**. When operations mix sorts (e.g., scalar multiplication `R × M → M`), a congruence on one sort propagates through mixed operations to create *derived* identities on other sorts, without the second sort carrying any congruence of its own. The key theorem is that **partial normalization** (normalizing only some sorts) still preserves evaluation, but this preservation is mediated by the compatibility condition in a way that has no single-sorted analogue.

**Precise Theorem Statement (Lean 4 type signature)**:

```lean
-- A multi-sorted signature: operations have input sorts and a result sort
structure MultiSortedSig (σ : Type*) where
  ops : Type*
  arity : ops → List σ
  resultSort : ops → σ

-- A multi-sorted algebra over signature Σ
structure MultiSortedAlg {σ : Type*} (Σ : MultiSortedSig σ) where
  carrier : σ → Type*
  interp : (f : Σ.ops) →
    ((i : Fin (Σ.arity f).length) → carrier (Σ.arity f).get i) →
    carrier (Σ.resultSort f)

-- Sort-indexed congruences with compatibility
structure SortCongruence {σ : Type*} {Σ : MultiSortedSig σ} (A : MultiSortedAlg Σ) where
  rel : ∀ s : σ, A.carrier s → A.carrier s → Prop
  is_equiv : ∀ s, Equivalence (rel s)
  compatible : ∀ (f : Σ.ops) (args₁ args₂ : (i : Fin (Σ.arity f).length) → A.carrier (Σ.arity f).get i),
    (∀ i, (rel (Σ.arity f).get i) (args₁ i) (args₂ i)) →
    (rel (Σ.resultSort f)) (A.interp f args₁) (A.interp f args₂)

-- Sort-indexed normalization (may be defined only on a subset of sorts)
structure PartialNorm {σ : Type*} {Σ : MultiSortedSig σ} (A : MultiSortedAlg Σ) (C : SortCongruence A) where
  active : σ → Bool  -- which sorts have active normalization
  norm : ∀ s : σ, A.carrier s → A.carrier s
  norm_sound : ∀ s, C.rel s (norm s · ·) · ·  -- normalization preserves congruence class
  norm_idem : ∀ s, active s = true → norm s (norm s · ·) = norm s · ·  -- idempotent on active sorts
  norm_inactive : ∀ s, active s = false → norm s = id  -- identity on inactive sorts

-- THE MAIN THEOREM: Partial normalization preserves evaluation
theorem partial_norm_preserves_eval
    {σ : Type*} {Σ : MultiSortedSig σ} {A : MultiSortedAlg Σ}
    {C : SortCongruence A} {N : PartialNorm A C}
    {s : σ} (env : ∀ s', ℕ → A.carrier s') (t : MWTerm Σ s) :
    MWEval (normEnv N.norm env) t = N.norm s (MWEval env t) ∨
    (N.active s = false ∧ MWEval (normEnv N.norm env) t = MWEval env t) := by
  -- Proof by structural induction on well-sorted terms
  sorry
```

**The Interaction Lemma** (the key non-trivial fact with no single-sorted analogue):

```lean
-- When an operation f : (..., sᵢ, ...) → s mixes an actively-normalized sort sᵢ
-- with an inactive sort, the result on s is still determined by the
-- normalized inputs — the compatibility condition propagates the normalization.
theorem sort_interaction_lemma
    {σ : Type*} {Σ : MultiSortedSig σ} {A : MultiSortedAlg Σ}
    {C : SortCongruence A} {N : PartialNorm A C}
    (f : Σ.ops) (args : (i : Fin (Σ.arity f).length) → A.carrier (Σ.arity f).get i) :
    A.interp f (normArgs N.norm args) = A.interp f args ∨
    C.rel (Σ.resultSort f) (A.interp f (normArgs N.norm args)) (A.interp f args) := by
  -- Uses compatibility condition: normalizing each argument preserves
  -- the congruence class of the result, even for mixed-sort operations
  sorry
```

**Proof Strategy (3 paths, ranked by promise)**:

**Strategy A — Sort-by-Sort Structural Induction** [MOST PROMISING]:
1. Define well-sorted terms `MWTerm Σ s` by structural induction: variables of sort `s`, and operator applications `f t₁ ... tₙ` where each `tᵢ` has sort `(Σ.arity f).get i`.
2. Define evaluation `MWEval` and the normalized environment `normEnv`.
3. Prove by strong induction on term depth: for each sort `s`, if the theorem holds for all proper subterms, then it holds for the whole term. The operation case uses the `compatible` field of `SortCongruence` to propagate normalization through mixed-sort operations.
4. Key technical lemma: if `active s = false`, then `normEnv` does not alter variables of sort `s`, so the theorem holds trivially for sort-`s` variables. For operations targeting sort `s`, the inactive normalization on `s` means the result needs no normalization, but the *inputs* may have been normalized — this is where compatibility saves us.
5. **Why most promising**: Directly generalizes the single-sorted proof in `Pythagorean/QuotientOptimizer.lean`. The `preserves_eval` theorem there is proven by induction on terms; we follow the same skeleton but track sorts.

**Strategy B — Categorical/Functorial Approach** [ELEGANT BUT HARDER TO FORMALIZE]:
1. View multi-sorted algebras as product-preserving functors `F : Lawv(Σ) → Type*` where `Lawv(Σ)` is the Lawvere theory generated by `Σ`.
2. Show that a `SortCongruence` corresponds to a quotient functor `Q : Lawv(Σ) → Lawv(Σ/C)` and a natural transformation `η : F ⇒ F` corresponding to normalization.
3. Prove that `η` is a cartesian natural transformation (preserves pullbacks), which gives `preserves_eval` as the statement that `η` commutes with evaluation.
4. **Why harder**: Requires building Lawvere theory infrastructure in Lean, which doesn't exist in Mathlib yet.

**Strategy C — Initial Algebra + Universal Property** [THE "RIGHT" MATH APPROACH]:
1. Construct the initial multi-sorted term algebra `T_Σ` as the algebra of well-sorted terms.
2. Show that normalization lifts to `T_Σ` by the universal property: the congruence on `T_Σ` induced by `C` gives a quotient algebra `T_Σ/C`, and normalization picks canonical representatives.
3. Use initiality: for any algebra `A` and environment `ρ`, there is a unique homomorphism `h : T_Σ → A`, and `preserves_eval` follows from `h` being a homomorphism that respects the congruence.
4. **Why promising for clean math but risky for Lean**: Initial algebra constructions in dependent type theory are notoriously subtle (well-founded recursion on term depth, quotients of inductive types).

**Building on Catalog**: The existing `Pythagorean/QuotientOptimizer.lean` defines:
```
structure QuotientOptimizer (α : Type*) [CommMonoid α] where
  rel : α → α → Prop
  norm : α → α
  ...
  preserves_eval : ∀ (env : ℕ → α) (t : Term), eval (norm ∘ env) t = norm (eval env t)
```
The multi-sorted version replaces `α` with a sort-indexed family `carrier : σ → Type*`, replaces the single `rel` with a `SortCongruence`, and replaces the single `norm` with a `PartialNorm`. The proof structure mirrors the original but must handle the `active`/`inactive` distinction and the compatibility condition for mixed-sort operations.

**The Concrete Test Case: Modules over Commutative Rings**:

```lean
-- Two-sorted signature: R (ring) and M (module)
def ModuleOverRingSig : MultiSortedSig (Fin 2) where
  ops := Fin 8  -- add_R, mul_R, zero_R, neg_R, smul, add_M, zero_M, neg_M
  arity := ![[], [], [0, 0], [0, 0], [0], [0, 1], [1, 1], [1]]
  resultSort := ![0, 0, 0, 0, 0, 1, 1, 1]

-- Commutativity congruence on R only (active sort = 0)
-- Inactive on M (active sort = 1 = false)
-- Theorem: normalizing ring variables (e.g., sorting products a*b → min(a,b)*max(a,b))
-- preserves evaluation of mixed ring-module expressions like (r₁ * r₂) · m + r₃ · (m₁ + m₂)
```

**Cross-Domain Connections**:

1. **Universal Algebra → Quantum Circuit Optimization**: In quantum circuits, sorts correspond to qubit types (data vs. ancilla). Commutativity of phase gates on data qubits (active sort) can be exploited without touching ancilla qubits (inactive sort). The interaction lemma says: normalizing phase gates preserves overall circuit semantics, even for gates that mix data and ancilla qubits (e.g., CNOT).

2. **Universal Algebra → Database Query Optimization**: Multi-sorted algebras are the foundation of relational algebra (sorts = table schemas, operations = joins, selections). Commutativity of joins (active sort = join operations) can be exploited to reorder queries. The interaction lemma says: reordering joins preserves query results even when joins are mixed with sort-specific operations (selections on specific tables).

3. **Universal Algebra → Representation Theory**: The module-over-ring example IS the starting point of representation theory. Normalizing ring elements to canonical representatives of conjugacy classes (active sort) while leaving module elements untouched (inactive sort) is exactly what happens in modular representation theory when reducing to p-regular classes. The theorem says: the representation-theoretic evaluation (trace, character values) is preserved under this normalization.

4. **Universal Algebra → Dependent Type Theory**: Multi-sorted terms are well-typed terms of a simply-typed language. The `SortCongruence` is a type-preserving definitional equality. The `PartialNorm` is a partial evaluation strategy that normalizes only certain types. This connects to normalization-by-evaluation (NbE) in type theory.

**Application Keywords**: `partial-evaluation`, `multi-sorted-algebra`, `sort-interaction`, `Lawvere-theory`, `quantum-circuit-optimization`, `query-optimization`, `modular-representation-theory`, `normalization-by-evaluation`

---

### Specific Theorems to Prove (in order of depth)

**Theorem 1 — Compatibility Propagation** (cross-domain: algebra → topology):
```lean
-- If a congruence on sort sᵢ is compatible with operation f, and f targets sort sⱼ,
-- then the kernel of f restricted to sᵢ-equivalence classes is well-defined on sⱼ.
-- This is the algebraic shadow of the topological fact that a quotient map
-- composed with a continuous map factors through the quotient.
theorem compatibility_propagation
    {σ : Type*} {Σ : MultiSortedSig σ} {A : MultiSortedAlg Σ}
    {C : SortCongruence A} (f : Σ.ops) (sᵢ : σ) (hᵢ : sᵢ ∈ Σ.arity f)
    (x y : A.carrier sᵢ) (h_rel : C.rel sᵢ x y) :
    C.rel (Σ.resultSort f) (A.interp f (replaceArg args hᵢ x))
                           (A.interp f (replaceArg args hᵢ y)) := by
  -- Proof: use C.compatible with args where only position hᵢ differs
  sorry
```

**Theorem 2 — Partial Normalization Correctness** (the main theorem):
```lean
theorem partial_norm_preserves_eval
    {σ : Type*} {Σ : MultiSortedSig σ} {A : MultiSortedAlg Σ}
    {C : SortCongruence A} {N : PartialNorm A C}
    {s : σ} (env : ∀ s', ℕ → A.carrier s') (t : MWTerm Σ s) :
    MWEval (normEnv N.norm env) t = N.norm s (MWEval env t) ∨
    (N.active s = false ∧ MWEval (normEnv N.norm env) t = MWEval env t) := by
  -- Proof: strong induction on term depth
  sorry
```

**Theorem 3 — Interaction Coherence** (no single-sorted analogue):
```lean
-- If we normalize sort sᵢ but not sort sⱼ, and f : (sᵢ, sⱼ) → sₖ is a mixed operation,
-- then normalizing the sᵢ-input preserves the congruence class of the result on sₖ,
-- EVEN THOUGH sₖ may be inactive.
theorem interaction_coherence
    {σ : Type*} {Σ : MultiSortedSig σ} {A : MultiSortedAlg Σ}
    {C : SortCongruence A} {N : PartialNorm A C}
    (f : Σ.ops) (args : (i : Fin (Σ.arity f).length) → A.carrier (Σ.arity f).get i)
    (i : Fin (Σ.arity f).length) (h_active : N.active (Σ.arity f).get i = true) :
    C.rel (Σ.resultSort f) (A.interp f (normArgs N.norm args)) (A.interp f args) := by
  -- Uses C.compatible pointwise: normalizing one argument preserves congruence
  sorry
```

**Theorem 4 — Cross-Domain: Algebraic to Topological** (connects universal algebra to topology):
```lean
-- A sort-respecting congruence induces a pseudometric on each sort:
-- d_s(x, y) = 0 if C.rel s x y, else 1
-- The compatibility condition makes every operation 1-Lipschitz.
-- This connects algebraic quotient optimization to metric space theory.
theorem operation_lipschitz
    {σ : Type*} {Σ : MultiSortedSig σ} {A : MultiSortedAlg Σ}
    {C : SortCongruence A} (f : Σ.ops)
    (args₁ args₂ : (i : Fin (Σ.arity f).length) → A.carrier (Σ.arity f).get i)
    (h : ∀ i, congruenceMetric (C.rel (Σ.arity f).get i) (args₁ i) (args₂ i) = 0) :
    congruenceMetric (C.rel (Σ.resultSort f)) (A.interp f args₁) (A.interp f args₂) = 0 := by
  -- The metric d(x,y) = 0 iff x ~ y is a pseudometric.
  -- Compatibility says: if all inputs are equivalent, so is the output.
  -- This is exactly Lipschitz-1 for the sup metric on the product.
  sorry
```

---

### Falsifiable Conjecture with Computational Test

**Conjecture (Normalization Space Collapse)**: For a free module `R^m` over a commutative ring `R` with `n` generators, where `R` has a commutativity congruence with normalization (sorting products), the number of distinct evaluations of well-typed mixed ring-module terms of depth `d` is reduced by a factor of at least `⌊n/2⌋!` compared to unnormalized evaluation, for all `d ≥ 3`.

**Computational Test**: 
1. Generate all well-typed terms up to depth `d = 4` with `n = 4` ring generators `r₀, r₁, r₂, r₃` and `m = 2` module generators `m₀, m₁`.
2. For each term, evaluate with and without ring normalization (sorting products).
3. Count distinct evaluations in both cases.
4. Verify the ratio is at least `⌊4/2⌋! = 2! = 2`.
5. Run with `n = 6` and verify ratio ≥ `3! = 6`.
6. If the ratio falls below the predicted floor for any `d ≥ 3`, the conjecture is falsified.

**Why This Matters**: If true, this gives a quantitative bound on how much partial normalization (normalizing only some sorts) compresses the evaluation space. This is directly applicable to compiler optimization: it tells you how much you gain by exploiting algebraic identities on some types but not others.

---

### Mandatory Deliverables

(a) **FUTURE_DIRECTIONS.md**: 3-5 testable scientific hypotheses:
   - H1: The normalization space collapse conjecture (test as above)
   - H2: For multi-sorted signatures with `k` sorts and `n` generators per sort, the sort-interaction lemma implies that normalizing any single sort reduces the evaluation space by a factor polynomial in `n`, regardless of the total number of sorts (test: measure collapse factor for increasing `k` with fixed `n`)
   - H3: The pseudometric induced by a sort-congruence makes every operation contractive (Lipschitz constant ≤ 1) with respect to the sup metric on the product of sort carriers (test: compute Lipschitz constants for random operations in the module-over-ring example)
   - H4: Multi-sorted quotient optimizers compose: if `N₁` normalizes sorts in `S₁ ⊆ σ` and `N₂` normalizes sorts in `S₂ ⊆ σ` with `S₁ ∩ S₂ = ∅`, then the composed normalization `N₁ ∘ N₂` is also a valid partial norm (test: verify composition preserves the correctness theorem for two independent congruences on different sorts)
   - H5: The interaction coherence theorem fails if the compatibility condition is weakened: there exists a multi-sorted algebra with a sort-congruence that is NOT compatible, and a partial norm that is sound on each sort individually, but for which `preserves_eval` fails (test: construct explicit counterexample with a 2-sorted signature)

(b) **RESEARCH_PAPER.md**: Standalone scientific document titled "The Interaction Principle: How Partial Normalization in Multi-Sorted Algebras Preserves Evaluation Through Sort Compatibility". Must explain: what the interaction principle is, why it has no single-sorted analogue, the precise theorem, the proof strategy, the module-over-ring example, and the normalization space collapse conjecture. A reader with NO access to the code must understand the discovery.

(c) **ARTICLE.md**: Scientific American style. Title suggestion: "When Half a Rule Is Enough: How Optimizing Some Types But Not Others Still Gets the Right Answer." Explain the interaction principle through the module-over-ring example: normalizing ring elements (putting products in sorted order) doesn't change what scalar multiplication does to module elements, because the ring's algebraic rules (commutativity) are baked into the operation's behavior. **TABOO**: Do NOT mention formal verification, Lean, or machine-checked proofs. Write about the IDEAS.

(d) **Verified algorithm**: Implement the partial normalization evaluation algorithm for the module-over-ring signature. The algorithm takes a well-typed mixed term, an environment, and a partial norm specification, and returns the normalized evaluation. Verify that the algorithm's output matches the theorem's guarantee.

(e) **demo.py**: Interactive demonstration:
   - Let the user construct mixed ring-module expressions (e.g., `(r0 * r1) · m0 + r2 · m1`)
   - Show evaluation with and without ring normalization
   - Visualize the normalization space collapse: count distinct evaluations for increasing term depth
   - Highlight the interaction: show that normalizing `r0 * r1` to `min(r0,r1) * max(r0,r1)` preserves the module operations

---

**Remember**: The deep insight here is NOT "multi-sorted generalizes single-sorted" — that is obvious and incremental. The deep insight is the **Interaction Principle**: when sorts interact through mixed operations, partial normalization on one sort propagates correctness guarantees to other sorts through the compatibility condition, creating derived identities that exist NOWHERE in the single-sorted theory. This is the theorem that makes multi-sorted quotient optimization fundamentally different, not just more general.

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
