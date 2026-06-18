Soli Deo Gloria

## Assignment: Direction 5: Universal Certified Algebraic Computation Framework

**Mode:** prove

You are not being asked for another optimizer for another syntax. You are being asked to isolate the *mathematical invariant* behind certified algebraic computation itself.

The target is a field-opening theorem schema:

> **Universal Certified Algebraic Computation Principle.**  
> For a finitely presented equational theory, certified optimization can be obtained either by a terminating confluent rewrite presentation, or by a quotient-respecting normalization map whose correctness factors through the equational congruence.  
> In other words: *rewriting and quotient normalization are not competing paradigms, but two faces of the same certified algebraic semantics.*

If established cleanly in Lean, this would not be “one more verified optimizer.” It would be a unification theorem for compiler optimization, symbolic algebra, SMT simplification, equality saturation extraction, Gröbner-style reduction, and operator normal-ordering in physics.

---

## Core mathematical vision

The breakthrough is to formalize a **single abstraction layer** that separates:

1. the **equational content** of a theory,
2. the **computational content** of normalization/optimization,
3. the **certification interface** proving semantic preservation.

The right abstraction is not merely “a rewrite system.” It is a certified bridge between:
- a raw syntax,
- an equational congruence,
- a semantic interpretation,
- and a computable canonicalization procedure.

The conjectural unification is:

- **Complete case:** if completion succeeds and yields a terminating confluent system, optimization is canonical and complete.
- **Incomplete case:** even if completion fails, any quotient-compatible normalizer still yields a certified optimizer, though completeness becomes relative to the quotient semantics or a partial normal-form fragment.
- **Master theorem:** certified optimization is exactly a section/retraction phenomenon over the quotient by the equational theory.

This is mathematically deeper than rewriting alone: it says the essence of optimization is **constructing computational representatives of congruence classes**.

---

## Precise theorem targets

You must formalize at least one new structure and prove at least 3 substantial theorems. The following is the recommended theorem package.

### New definitions to introduce

Define a new structure, genuinely novel relative to the catalog:

```lean
structure CertifiedTheory (α : Type u) where
  Reduces : α → α → Prop
  Equiv : α → α → Prop
  nf : α → α
  sound_step : ∀ {a b}, Reduces a b → Equiv a b
  nf_complete : ∀ a, Equiv a (nf a)
  nf_idem : ∀ a, nf (nf a) = nf a
  nf_respects : ∀ {a b}, Equiv a b → nf a = nf b
```

This is intentionally stronger than a bare rewrite system: it packages the quotient-normalizer interface.

Then define a refinement for the convergent case:

```lean
structure ConvergentCertifiedTheory (α : Type u) extends CertifiedTheory α where
  normal_iff_nf : ∀ a, (¬ ∃ b, Reduces a b) ↔ nf a = a
  confluent_like :
    ∀ {a b c}, Relation.ReflTransGen Reduces a b →
               Relation.ReflTransGen Reduces a c →
               ∃ d, Relation.ReflTransGen Reduces b d ∧
                    Relation.ReflTransGen Reduces c d
  terminates : WellFounded Reduces
```

Also define a quotient-based optimizer interface:

```lean
structure QuotientNormalizer (α : Type u) (E : α → α → Prop) where
  nf : α → α
  sound : ∀ a, E a (nf a)
  complete : ∀ {a b}, E a b → nf a = nf b
  idem : ∀ a, nf (nf a) = nf a
```

This is the key new mathematical concept: **a quotient normalizer as a computational section of the quotient map**.

---

## Theorem 1: Master theorem for certified optimization

This is the conceptual heart.

### Informal statement
If `nf` is sound, complete with respect to an equivalence `Equiv`, and idempotent, then optimization by `nf` is semantically correct and canonical on equivalence classes. In particular, two terms are equivalent if and only if their normal forms coincide.

### Lean 4 type signature
```lean
theorem nf_eq_iff_equiv
  {α : Type u} (T : CertifiedTheory α) :
  ∀ {a b : α}, T.Equiv a b ↔ T.nf a = T.nf b
```

You may need to split this into assumptions ensuring `Equiv` is symmetric/transitive or package `Setoid α` instead:

```lean
structure CertifiedTheory' (α : Type u) where
  S : Setoid α
  nf : α → α
  nf_sound : ∀ a, S.r a (nf a)
  nf_complete : ∀ {a b}, S.r a b → nf a = nf b
  nf_idem : ∀ a, nf (nf a) = nf a
```

Then prove:

```lean
theorem nf_eq_iff_setoid
  {α : Type u} (T : CertifiedTheory' α) :
  ∀ {a b : α}, T.S.r a b ↔ T.nf a = T.nf b
```

### Why this is a breakthrough
This theorem says that canonical computation is exactly the same thing as deciding equality in the quotient by comparing normal forms. That is the common skeleton behind:
- constant folding,
- Gröbner normal forms,
- equality saturation extraction,
- compiler peephole simplification,
- symbolic simplification modulo algebraic laws.

This is the “one theorem to rule them all.”

### Proof strategy
1. **Forward direction:** use `nf_complete`.
2. **Backward direction:** use `nf_sound` twice and transitivity of the setoid relation; rewrite via the equality `nf a = nf b`.
3. **Canonicality layer:** prove that `nf` factors through `Quotient (T.S)` and induces an injective representative selector on its image.

Use `rcases`, multi-step `calc`, and explicit transitivity reasoning. Do not trivialize.

---

## Theorem 2: Convergent rewriting induces a quotient normalizer

This theorem connects rewriting theory to the abstract optimizer theorem.

### Informal statement
If a reduction relation is terminating and confluent, then selecting the unique normal form yields a quotient normalizer for the equivalence closure generated by rewrite steps.

### Lean 4 type signature
A realistic formal target:

```lean
theorem convergent_gives_certified_theory
  {α : Type u}
  (R : α → α → Prop)
  (hWf : WellFounded R)
  (hconf :
    ∀ {a b c},
      Relation.ReflTransGen R a b →
      Relation.ReflTransGen R a c →
      ∃ d, Relation.ReflTransGen R b d ∧ Relation.ReflTransGen R c d)
  (nf : α → α)
  (hnf_sound : ∀ a, Relation.ReflTransGen R a (nf a))
  (hnf_normal : ∀ a, ¬ ∃ b, R (nf a) b) :
  ∃ T : CertifiedTheory' α,
    T.nf = nf
```

A sharper version, if you define convertibility:
```lean
def Converts (R : α → α → Prop) : α → α → Prop := ...

theorem convergent_nf_complete
  {α : Type u} {R : α → α → Prop}
  (hWf : WellFounded R)
  (hconf : ...)
  (nf : α → α)
  (hnf_sound : ∀ a, Relation.ReflTransGen R a (nf a))
  (hnf_normal : ∀ a, ¬ ∃ b, R (nf a) b) :
  ∀ {a b}, Converts R a b → nf a = nf b
```

### Why this matters
This theorem upgrades catalog rewriting results into a universal interface theorem. It tells you that *every convergent rewrite engine is automatically a certified optimizer* once phrased at the right abstraction level.

This is the bridge from `Pythagorean/ConvergentRewriteOptimizer.lean` to the grand architecture.

### Proof strategy
1. Define convertibility/equational closure generated by rewrite steps.
2. Use confluence plus normality of `nf a` and `nf b` to show all reducts from convertible terms must join at equal normal forms.
3. Use well-founded recursion or existing normal-form existence machinery from the catalog to justify normalization.

Most promising path: **factor through the existing main theorems in `Pythagorean/ConvergentRewriteOptimizer.lean`**, extracting only the abstraction you need rather than reproving Newman's lemma from scratch.

---

## Theorem 3: Quotient factorization theorem for partial completion

This is the nontrivial theorem that makes the whole program universal rather than restricted to successful completion.

### Informal statement
Suppose a rewrite system `R` is sound for an equational theory `E`, but not necessarily complete. If a function `nf` is constant on `E`-classes and every rewrite step preserves `E`, then `nf` defines a certified optimizer for the quotient semantics, even when `R` is only a partial completion.

This theorem formalizes the fallback mechanism when Knuth–Bendix fails.

### Lean 4 type signature
```lean
theorem quotient_factorized_optimizer
  {α : Type u} (E : Setoid α) (nf : α → α)
  (h_sound : ∀ a, E.r a (nf a))
  (h_complete : ∀ {a b}, E.r a b → nf a = nf b)
  (h_idem : ∀ a, nf (nf a) = nf a) :
  ∃ T : CertifiedTheory' α, T.S = E ∧ T.nf = nf
```

Then add a theorem showing any step-sound partial rewrite relation can be integrated:

```lean
theorem partial_completion_sound
  {α : Type u} (E : Setoid α) (R : α → α → Prop) (nf : α → α)
  (hstep : ∀ {a b}, R a b → E.r a b)
  (h_sound : ∀ a, E.r a (nf a))
  (h_complete : ∀ {a b}, E.r a b → nf a = nf b)
  (h_idem : ∀ a, nf (nf a) = nf a) :
  ∀ {a b}, Relation.ReflTransGen R a b → nf a = nf b
```

### Why this is revolutionary
This theorem says failed completion is not failure of certification. It transforms incomplete rewriting from a dead end into a principled stage of a larger certified architecture.

This is exactly what equality saturation, SMT simplification, and many symbolic algebra systems need: not always a complete canonical system, but always a quotient-correct simplifier.

### Proof strategy
1. Prove `ReflTransGen R a b → E.r a b` by induction on the closure derivation.
2. Use `h_complete` to deduce equal normal forms.
3. Package the result into `CertifiedTheory'`.

This theorem should use **induction** on `Relation.ReflTransGen`, not automation.

---

## Theorem 4: Semantic preservation via interpreter transport

This is where you connect to the compiler architecture in the catalog.

### Informal statement
Any interpreter that respects the equational relation is invariant under certified normalization.

### Lean 4 type signature
A generic version:
```lean
theorem interpreter_invariant_under_nf
  {α β : Type u}
  (T : CertifiedTheory' α)
  (interp : α → β)
  (h_interp : ∀ {a b}, T.S.r a b → interp a = interp b) :
  ∀ a, interp (T.nf a) = interp a
```

A more ambitious version should explicitly build on:
- `Catalog/Pythagorean/VerifiedCompilerSynthesis.lean`
- `InterpreterSpec`
- `adjoint_semantics_principle`

For example:
```lean
theorem certified_optimizer_refines_interpreter
  {Expr Val : Type _}
  (T : CertifiedTheory' Expr)
  (I : InterpreterSpec Expr Val)
  (h_respect : ∀ {a b}, T.S.r a b → I.eval a = I.eval b) :
  ∀ e, I.eval (T.nf e) = I.eval e
```

### Why this matters
This is the point where abstract rewriting becomes certified compilation and symbolic execution. It connects equational reasoning to actual semantics-preserving program optimization.

### Proof strategy
1. Obtain `T.S.r a (T.nf a)` from soundness.
2. Apply interpreter congruence.
3. If using `adjoint_semantics_principle`, show normalization is a semantics-preserving endomorphism in the appropriate adjoint setup.

Most promising path: leverage the catalog’s semantics transport theorem rather than redoing interpreter correctness from scratch.

---

## Theorem 5: Cross-domain bridge — operator normal ordering / polynomial reduction / Boolean simplification

You are required to include at least one theorem connecting domains. Do not make this cosmetic. Make the abstraction visibly transport across subjects.

### Recommended bridge theorem
Define a tiny expression language with two unrelated semantics:
- a commutative semiring semantics,
- a Boolean algebra semantics,
or
- a noncommutative “operator word” semantics with a toy normal-ordering relation.

Then prove that the same `CertifiedTheory'` interface certifies optimization in both domains.

### Lean 4 type signature
For example:
```lean
theorem same_normalizer_two_semantics
  {α β γ : Type u}
  (T : CertifiedTheory' α)
  (interp₁ : α → β)
  (interp₂ : α → γ)
  (h₁ : ∀ {a b}, T.S.r a b → interp₁ a = interp₁ b)
  (h₂ : ∀ {a b}, T.S.r a b → interp₂ a = interp₂ b) :
  ∀ a, interp₁ (T.nf a) = interp₁ a ∧ interp₂ (T.nf a) = interp₂ a
```

Or a more domain-specific theorem:
```lean
theorem normal_ordering_is_certified_optimization
  (T : CertifiedTheory' OperatorExpr)
  (hCCR : ∀ {a b}, T.S.r a b → physSem a = physSem b) :
  ∀ e, physSem (T.nf e) = physSem e
```

### Cross-domain significance
This is the moment the framework stops being “about term rewriting” and becomes a mathematical architecture spanning:
- compiler optimization,
- symbolic algebra,
- theorem proving,
- quantum circuit simplification,
- operator algebra in physics.

Application keywords: **term rewriting, canonical forms, equality saturation, compiler correctness, Gröbner reduction, SMT simplification, operator normal ordering, quantum circuit optimization, symbolic AI, algebraic effects**.

---

## Recommended file architecture

Create a new Lean file, e.g.

```text
Pythagorean/UniversalCertifiedAlgebraicComputation.lean
```

and import the catalog foundations:

- `Pythagorean/ConvergentRewriteOptimizer.lean`
- `Catalog/Pythagorean/VerifiedCompilerSynthesis.lean`

If needed, create a companion experimental file for examples:
```text
Pythagorean/UniversalCertifiedAlgebraicComputationExamples.lean
```

---

## Proof architecture: 3 strategic routes

### Strategy A: Quotient-first abstraction
1. Define `CertifiedTheory'` around `Setoid`.
2. Prove the master theorem `equiv ↔ equal normal forms`.
3. Show convergent rewriting and partial completion each instantiate this structure.

**Why this is promising:**  
This is the cleanest mathematical route. It isolates the essence early and lets rewriting appear as one implementation of quotient canonicalization.

### Strategy B: Rewrite-first extraction
1. Start from the catalog’s convergent rewrite optimizer theorems.
2. Extract the quotient relation induced by the rewrite system.
3. Package the resulting normalizer into `CertifiedTheory'`.
4. Then generalize to partial completion by weakening completeness.

**Why this is promising:**  
Best if the catalog already provides strong lemmas on normal forms, confluence, and semantic preservation. It minimizes low-level proof burden.

### Strategy C: Semantic-adjoint route
1. Use `InterpreterSpec` and `adjoint_semantics_principle` to define optimizer correctness categorically/semantically.
2. Show rewrite normalizers and quotient normalizers both satisfy the same semantic adjunction law.
3. Derive canonicality as a corollary.

**Why this is bold:**  
This could yield the deepest final statement, tying certified optimization to universal properties. It is the most visionary path, but likely the highest proof overhead.

**Recommendation:**  
Pursue **Strategy A** for the main theorem package, borrow lemmas from **Strategy B**, and reserve **Strategy C** for a final theorem or `FUTURE_DIRECTIONS.md` conjecture if time permits.

---

## Concrete deep-proof requirements

Your file must contain at least 3 genuinely nontrivial theorems proven with multi-step reasoning. Recommended distribution:

1. `nf_eq_iff_setoid`  
   Proof uses `calc`, transitivity, and both directions of the equivalence.

2. `partial_completion_sound`  
   Proof by **induction** on `Relation.ReflTransGen`.

3. `interpreter_invariant_under_nf`  
   Proof uses semantic transport from soundness.

Optional fourth:
4. `convergent_nf_complete`  
   Proof via confluence/joinability/normality.

Use:
- `induction`
- `rcases`
- `by_contra`
- multi-step `calc`
- `field_simp` only if you build a polynomial/rational semantics example

Do **not** hide the mathematics behind `simp` alone.

---

## Computational artifact requirement

You must also produce a verified algorithm, not just theorems.

### Required algorithmic deliverable
Implement a small certified optimizer interface:

```lean
def optimize {α} (T : CertifiedTheory' α) : α → α := T.nf
```

Then provide at least one executable example theory:
- Boolean expressions with identities,
- commutative semiring expressions with constant folding,
- or a toy noncommutative monoid with normal ordering.

Prove:
```lean
theorem optimize_sound ...
theorem optimize_idempotent ...
theorem optimize_complete ...
```

And expose a computational method that can be exercised from Python.

---

## demo.py requirement

Provide `demo.py` that:
1. constructs several expressions from at least two domains,
2. runs the optimizer,
3. prints original term, optimized term, and semantic equality check,
4. reports empirical statistics over randomized terms.

Ideal demo domains:
- Boolean simplification,
- polynomial-like simplification,
- toy circuit/operator normalization.

The Python demo should illustrate the unification thesis: *same certified architecture, different scientific domains*.

---

## Mandatory scientific deliverables

You must produce **all** of the following:

### 1. `FUTURE_DIRECTIONS.md`
Include 3–5 **testable scientific hypotheses**, each falsifiable and computationally checkable.

Recommended hypotheses:

1. **Completion prevalence hypothesis.**  
   Among finitely presented algebraic theories with ≤ 6 axioms over signatures of arity ≤ 2, at least 60% admit a convergent orientation under a simple recursive path ordering.  
   **Test:** enumerate 50 benchmark theories and run completion.

2. **Quotient fallback universality hypothesis.**  
   For at least 90% of benchmark theories where completion fails, a quotient-based normalizer derived from partial completion still yields semantic preservation and idempotence on 10,000 random terms.  
   **Test:** construct partial normalizers and evaluate.

3. **Cross-domain transfer hypothesis.**  
   The same `CertifiedTheory'` interface can certify optimizers in at least four distinct domains: Boolean algebra, semiring simplification, equality saturation extraction, and operator normal ordering.  
   **Test:** instantiate the structure in each domain.

4. **Canonical-form compression hypothesis.**  
   For random expressions in benchmark theories, quotient-based normalization reduces average AST size by at least 20% without changing semantics.  
   **Test:** compare pre/post node counts.

5. **Semantic transport hypothesis.**  
   Any interpreter satisfying the congruence-respect condition automatically yields optimization correctness with no domain-specific proof beyond interpreter congruence.  
   **Test:** instantiate multiple interpreters per syntax.

### 2. `RESEARCH_PAPER.md`
A standalone scientific paper containing:
- problem statement,
- mathematical definitions,
- theorem statements,
- proof ideas,
- computational experiment plan,
- scientific significance,
- limitations,
- next-step conjectures.

A reader with no access to code must understand the discovery.

### 3. `ARTICLE.md`
Scientific American style.  
Explain the idea of a universal optimizer for algebraic reasoning.  
Talk about mathematics, symbolic reasoning, physics, compilers, and AI.  
**Do not focus on formal verification machinery.**

### 4. Verified algorithm / computational method
Not optional. Must include executable optimizer construction and correctness theorems.

### 5. `demo.py`
Interactive demonstration, as described above.

---

## How to build directly on the catalog

### From `Pythagorean/ConvergentRewriteOptimizer.lean`
Use its main theorems as the **complete-case backend**:
- extract or wrap its convergence/canonical-form theorem,
- repackage the result as an instance of `CertifiedTheory'`,
- avoid reproving low-level rewriting facts if the catalog already certifies them.

### From `Catalog/Pythagorean/VerifiedCompilerSynthesis.lean`
Use:
- `InterpreterSpec`
- `adjoint_semantics_principle`

to prove that any certified normalizer transports across semantics-preserving interpreters. The point is to show optimization correctness is not syntax-specific but interpreter-parametric.

---

## Suggested minimal example theories

You should instantiate the framework on at least two of these:

1. **Boolean expressions**
   - identities like `x ∧ true = x`, `x ∨ false = x`, `¬¬x = x`
   - optimizer = simplifier / constant folder

2. **Commutative semiring expressions**
   - `x + 0 = x`, `x * 1 = x`, `0 * x = 0`
   - optimizer = algebraic simplifier

3. **Toy noncommutative operator words**
   - normal ordering relation on words
   - optimizer = operator reordering modulo a chosen theory

4. **Tiny circuit language**
   - gate cancellation / normalization
   - optimizer = circuit simplifier

The goal is not domain size; it is architectural universality.

---

## Standard of ambition

Do not settle for “there exists a normalizer, therefore correctness.”  
The real target is:

> **Certified optimization is quotient canonicalization, and convergent rewriting is one computable realization of that principle.**

If you prove this cleanly, you will have created a reusable mathematical interface for certified algebraic computation across logic, algebra, programming languages, and physics.

That is a genuine new direction.

---

## Final checklist

Your Lean development must include:

- [ ] a new structure such as `CertifiedTheory'` or `QuotientNormalizer`
- [ ] at least 3 nontrivial theorems
- [ ] one theorem connecting to another domain
- [ ] one verified algorithm
- [ ] one falsifiable conjecture with computational test
- [ ] minimal `sorry`
- [ ] direct use of catalog theorems
- [ ] `FUTURE_DIRECTIONS.md`
- [ ] `RESEARCH_PAPER.md`
- [ ] `ARTICLE.md`
- [ ] `demo.py`

**Application keywords:** universal algebra, term rewriting, canonical forms, quotient types, equational reasoning, certified optimization, compiler correctness, symbolic algebra, SMT, equality saturation, Gröbner methods, operator algebras, quantum circuits, semantics transport, adjoint methods.

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
