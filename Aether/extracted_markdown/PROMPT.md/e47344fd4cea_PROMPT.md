Soli Deo Gloria

## Assignment: Direction 1 — Many-Sorted and Higher-Order Convergent Optimization

**Mode:** prove

Build a genuinely new formal theory of **many-sorted convergent normalization** that lifts the catalog’s single-sorted optimizer architecture to the setting where syntax, semantics, and rewriting are indexed by sorts. Do not produce a cosmetic generalization. Produce the theorem that turns rewrite-based optimization into a semantic compilation principle for the algebraic structures mathematicians and scientists actually use: rings acting on modules, semirings acting on weighted automata, typed tensor expressions, and eventually simply-typed lambda calculi with algebraic operators.

The guiding breakthrough is this:

> **Master Theorem, many-sorted form.** If a rewrite system on many-sorted terms is terminating and confluent, and every rewrite step is sound in every model of a many-sorted equational theory \(E\), then the induced normal-form map preserves denotation in every many-sorted \(\Sigma\)-algebra satisfying \(E\).

This is not merely a stronger version of `nf_preserves_eval`. It is the missing bridge from quotient optimizers on raw terms to **typed symbolic optimization** across algebra, program semantics, and representation theory.

---

## Why this would be a breakthrough

The catalog theorem `nf_preserves_eval` in `Pythagorean/ConvergentRewriteOptimizer.lean` shows that convergent normalization preserves evaluation in a single-sorted setting. That is already powerful, but mathematically most natural structures are **many-sorted**:

- a ring sort and a module sort,
- an object sort and a morphism sort,
- scalar, vector, and tensor sorts,
- proposition, term, and proof-like syntactic strata,
- simply-typed syntax indexed by types.

A verified many-sorted master theorem would open an entire field of **typed certified algebraic optimization**. It would provide a reusable formal substrate for:

- normalization of expressions in module and representation theory,
- simplification of typed symbolic computations,
- semantics-preserving compilation for algebraic DSLs,
- certified optimization in physics-inspired tensor calculi,
- eventually higher-order rewriting and typed lambda-normalization with algebraic structure.

This is the point where universal algebra, type theory, and symbolic computation stop being adjacent and become one formal machine.

---

## Exact formal target

You should create a new file extending the catalog architecture, for example:

- `Pythagorean/ManySortedConvergentRewriteOptimizer.lean`

and, if needed for typed extensions:

- `Pythagorean/SimplyTypedConvergentRewriteOptimizer.lean`

Build explicitly on:

- `Pythagorean/ConvergentRewriteOptimizer.lean`
  - `nf_preserves_eval`
  - `ConvergentOptimizer`
  - `CertifiedNormalizer`

---

## Core new definitions you must introduce

You must define at least one genuinely new structure absent from the catalog. The following is the minimum acceptable novelty.

### 1. Many-sorted signatures and terms
Introduce a many-sorted signature with operation symbols carrying typed arities and codomains.

A plausible Lean shape:

```lean
structure ManySortedSignature (Sort : Type u) where
  Op : Type v
  arity : Op → List Sort
  result : Op → Sort
```

Then define terms indexed by output sort:

```lean
inductive ManySortedTerm (Σ : ManySortedSignature Sort) (Var : Sort → Type w) :
    Sort → Type (max u v w)
| var : ∀ {s : Sort}, Var s → ManySortedTerm Σ Var s
| app : ∀ (f : Σ.Op),
    HVector (fun s => ManySortedTerm Σ Var s) (Σ.arity f) →
    ManySortedTerm Σ Var (Σ.result f)
```

If `HVector` is inconvenient, define a custom dependent vector over a list of sorts.

### 2. Many-sorted algebras and evaluation
Define a semantic structure assigning a carrier to each sort and an interpretation to each operation.

```lean
structure ManySortedAlgebra (Σ : ManySortedSignature Sort) where
  Carrier : Sort → Type u
  interp :
    ∀ (f : Σ.Op),
      HVector Carrier (Σ.arity f) → Carrier (Σ.result f)
```

Then define evaluation:

```lean
def ManySortedTerm.eval
  (A : ManySortedAlgebra Σ)
  (ρ : ∀ s, Var s → A.Carrier s) :
  ∀ {s}, ManySortedTerm Σ Var s → A.Carrier s
```

### 3. Sorted rewrite rules and normalization data
Define typed rewrite rules:

```lean
structure MSRule (Σ : ManySortedSignature Sort) (Var : Sort → Type w) where
  sort : Sort
  lhs : ManySortedTerm Σ Var sort
  rhs : ManySortedTerm Σ Var sort
```

Then define one-step reduction and its reflexive-transitive closure, plus the convergence package analogous to `ConvergentOptimizer`.

### 4. A new concept: semantic soundness across all sorts
This is the novel conceptual heart:

```lean
def MSSound
  (A : ManySortedAlgebra Σ)
  (R : Set (MSRule Σ Var)) : Prop :=
  ∀ r ∈ R, ∀ ρ,
    ManySortedTerm.eval A ρ r.lhs =
    ManySortedTerm.eval A ρ r.rhs
```

And then a theory-level version quantifying over all models of an equational class.

This is not just bookkeeping: it is the exact many-sorted analogue of equational soundness that makes the master theorem meaningful.

---

## Precise theorem statements to prove

You must prove at least **3 substantial theorems**. At least one should be the full master theorem, one should establish soundness along multi-step reduction, and one should instantiate the framework in a cross-domain algebraic setting.

Below are target statements. Adjust universes/details as needed, but keep the mathematical content.

### Theorem 1: One-step soundness implies semantic preservation of reduction closure
```lean
theorem ms_reduction_preserves_eval
  {Σ : ManySortedSignature Sort}
  {Var : Sort → Type w}
  (A : ManySortedAlgebra Σ)
  (R : Set (MSRule Σ Var))
  (hSound : MSSound A R) :
  ∀ {s : Sort} {t u : ManySortedTerm Σ Var s},
    RTC (ms_rewrite_step R) t u →
    ∀ ρ, ManySortedTerm.eval A ρ t = ManySortedTerm.eval A ρ u
```

**Meaning:** any finite reduction sequence preserves denotation in every sort.

This theorem should require real proof structure: induction on reflexive-transitive closure, careful dependent transport over sorts, and multi-step `calc`.

---

### Theorem 2: Many-sorted normal forms preserve semantics
Assuming a certified normalizer obtained from convergence:

```lean
theorem ms_nf_preserves_eval
  {Σ : ManySortedSignature Sort}
  {Var : Sort → Type w}
  (A : ManySortedAlgebra Σ)
  (R : Set (MSRule Σ Var))
  (nf : ∀ {s}, ManySortedTerm Σ Var s → ManySortedTerm Σ Var s)
  (hconv : MSConvergent R nf)
  (hSound : MSSound A R) :
  ∀ {s : Sort} (t : ManySortedTerm Σ Var s) (ρ : ∀ s, Var s → A.Carrier s),
    ManySortedTerm.eval A ρ (nf t) = ManySortedTerm.eval A ρ t
```

This is the many-sorted lift of `nf_preserves_eval`.

If your convergence structure packages normal-form reachability and irreducibility differently, adjust the statement, but the theorem must explicitly quantify over **all sorts**, **all terms**, and **all environments**.

---

### Theorem 3: Equational-model version of the master theorem
Abstract over a many-sorted equational theory \(E\), and prove semantic preservation in every model of \(E\) once each rule is derivably valid in \(E\).

A target form:

```lean
theorem ms_nf_preserves_eval_in_models
  {Σ : ManySortedSignature Sort}
  {Var : Sort → Type w}
  (E : Set (MSEquation Σ Var))
  (R : Set (MSRule Σ Var))
  (nf : ∀ {s}, ManySortedTerm Σ Var s → ManySortedTerm Σ Var s)
  (hconv : MSConvergent R nf)
  (hderiv : ∀ r ∈ R, E ⊢ₘₛ (⟨r.lhs, r.rhs⟩)) :
  ∀ (A : ManySortedModel Σ E) {s : Sort}
    (t : ManySortedTerm Σ Var s)
    (ρ : ∀ s, Var s → A.Carrier s),
    ManySortedTerm.eval A.toAlgebra ρ (nf t) =
    ManySortedTerm.eval A.toAlgebra ρ t
```

You may need to define `MSEquation`, `ManySortedModel`, and a derivability relation. If a full proof-theoretic derivability relation is too expensive, you may replace `hderiv` by a semantic assumption “all rules are valid in all models of E,” but the theorem must still be formulated theory-first, not model-first.

This theorem is the true research target.

---

### Theorem 4: Cross-domain instantiation — ring/module normalization
You must include a concrete two-sorted theory with:
- sort `Scal`
- sort `Vec`

operations such as:
- scalar addition/multiplication,
- vector addition,
- scalar action `smul : Scal × Vec → Vec`,
- zero elements.

Define a rewrite system capturing at least a fragment of module laws, for example:
- `smul 0 v → 0`
- `smul a 0 → 0`
- `smul 1 v → v`
- `smul a (v₁ + v₂) → smul a v₁ + smul a v₂`
- `(a + b) • v → a • v + b • v`

Then prove a semantic preservation theorem for every concrete module model satisfying those laws.

A target Lean statement:

```lean
theorem module_nf_preserves_eval
  (A : ModuleStyleAlgebra)
  (hA : ModuleStyleLaws A) :
  ∀ (t : ManySortedTerm ModuleSig Var Vec)
    (ρ : ∀ s, Var s → A.Carrier s),
    ManySortedTerm.eval A.toManySortedAlgebra ρ (module_nf t) =
    ManySortedTerm.eval A.toManySortedAlgebra ρ t
```

This theorem is your **cross-domain connection**:
- universal algebra ↔ module theory ↔ representation theory,
and computationally also ↔ symbolic linear algebra.

---

## Lean 4 type-signature guidance

You asked for precise signatures. Use these as architectural anchors, not as rigid syntax if implementation details differ.

```lean
structure ManySortedSignature (Sort : Type u) where
  Op : Type v
  arity : Op → List Sort
  result : Op → Sort
```

```lean
inductive HVector {α : Type u} (β : α → Type v) : List α → Type (max u v)
| nil : HVector β []
| cons : β a → HVector β l → HVector β (a :: l)
```

```lean
inductive ManySortedTerm
  (Σ : ManySortedSignature Sort) (Var : Sort → Type w) :
  Sort → Type (max u v w)
| var : ∀ {s}, Var s → ManySortedTerm Σ Var s
| app : ∀ f, HVector (fun s => ManySortedTerm Σ Var s) (Σ.arity f) →
    ManySortedTerm Σ Var (Σ.result f)
```

```lean
structure ManySortedAlgebra (Σ : ManySortedSignature Sort) where
  Carrier : Sort → Type u
  interp : ∀ f, HVector Carrier (Σ.arity f) → Carrier (Σ.result f)
```

```lean
def ManySortedTerm.eval
  (A : ManySortedAlgebra Σ)
  (ρ : ∀ s, Var s → A.Carrier s) :
  ∀ {s}, ManySortedTerm Σ Var s → A.Carrier s
```

```lean
structure MSRule (Σ : ManySortedSignature Sort) (Var : Sort → Type w) where
  sort : Sort
  lhs : ManySortedTerm Σ Var sort
  rhs : ManySortedTerm Σ Var sort
```

```lean
def MSSound
  (A : ManySortedAlgebra Σ)
  (R : Set (MSRule Σ Var)) : Prop := ...
```

```lean
theorem ms_reduction_preserves_eval ... : ...
theorem ms_nf_preserves_eval ... : ...
theorem ms_nf_preserves_eval_in_models ... : ...
```

If you go one level higher and formalize simply-typed syntax as many-sorted syntax where `Sort := Ty`, that is excellent. A simply-typed extension theorem would be a major bonus.

---

## Proof architecture: 3 viable strategies

You must not just attack this with one proof idea. Architect the theory with multiple routes.

### Strategy A — Direct lift of the single-sorted quotient argument
1. Define many-sorted syntax, semantics, and rewrite closure sort-indexedly.
2. Prove one-step semantic soundness implies multi-step semantic invariance by induction on reduction closure.
3. Package convergence as “every term reduces to `nf t`,” then conclude by transitivity.

**Why promising:** It is the closest structural analogue of `nf_preserves_eval`, so the catalog proof ideas should transfer. This is the fastest path to a first breakthrough theorem.

---

### Strategy B — Family-of-quotients / fiberwise initial algebra method
1. Regard each sort as a fiber and the term system as a dependent W-type / initial algebra in a presheaf-like category over `Sort`.
2. Show rewrite soundness induces a congruence on each fiber, compatible with operations.
3. Prove the normal-form map is a canonical representative selector preserving the unique homomorphism into any model.

**Why it matters:** This is conceptually deeper. It turns the theorem from “a rewrite proof” into “a theorem about initial semantics in many-sorted universal algebra.” If successful, this would make the simply-typed and higher-order extension dramatically easier.

**Most visionary path:** This is the mathematically richest route, though probably heavier in Lean.

---

### Strategy C — Typed logical-relations proof for simply-typed extension
1. Interpret sorts as types and terms by dependent recursion.
2. Define a typed reduction relation and prove semantic invariance by logical relations over sorts.
3. Specialize to first-order many-sorted syntax as the base case.

**Why interesting:** This sets up the next frontier: **higher-order convergent optimization**. It connects rewriting to normalization-by-evaluation, typed lambda calculi, and denotational semantics.

**Best use:** Pursue this if Strategy A succeeds early. It could yield a second file with a theorem that first-order many-sorted normalization is a corollary of a typed semantic invariance principle.

---

## Concrete cross-domain connections you should exploit

Do not present this as “just rewriting.” It is the formal skeleton of typed mathematics.

### 1. Universal algebra ↔ module theory
A two-sorted theory of scalars and vectors is the canonical first testbed. It immediately supports symbolic linear algebra and representation-theoretic simplification.

### 2. Type theory ↔ semantics of programming languages
Many-sorted terms are a first-order shadow of simply-typed syntax. Your definitions should be designed so that `Sort` can later be replaced by object-language types.

### 3. Representation theory ↔ compiler optimization
A rewrite system for module expressions is simultaneously:
- an algebraic normalizer,
- a typed optimizer,
- a semantics-preserving compiler pass for linear-algebra DSLs.

### 4. Mathematical physics ↔ tensor expressions
If your sorted signature includes scalar, vector, and tensor sorts, the framework can normalize symbolic expressions in mechanics and quantum theory. Even mentioning this carefully in the paper matters: it signals that the theorem is an infrastructure result for scientific symbolic computation.

### 5. Category theory ↔ many-sorted algebra
Objects, morphisms, and composable typing constraints naturally form many-sorted syntax. This framework could become a stepping stone to normalization in internal languages of categories.

---

## Required nontrivial proof content

Your file must contain at least 3 theorems whose proofs genuinely use deep tactics or proof patterns such as:
- induction on terms or reduction closure,
- `rcases` on dependent vectors / heterogeneous lists,
- `by_contra` where normal-form uniqueness or confluence arguments require contradiction,
- `field_simp` if you instantiate scalar models over `ℚ`,
- multi-step `calc` chains combining rewrite soundness with algebraic laws.

Avoid vacuous statements whose proof is definitional equality. The theorem should remain mathematically meaningful even if the proof were written on paper.

---

## Concrete experimental testbed

You are required to instantiate the theory on a two-sorted ring/module-like system and test it computationally.

### Suggested models
At minimum, test 5 concrete models such as:
1. `ℤ` acting on `ℤ × ℤ`
2. `ℤ` acting on `ℤ × ℤ × ℤ`
3. `ℚ` acting on `Fin 2 → ℚ`
4. `ℚ` acting on `Fin 3 → ℚ`
5. `ℤ/5ℤ` acting on `(Fin 2 → ZMod 5)`

If exact module instances are cumbersome, define finite-dimensional vector-like carriers manually, but keep the semantics honest.

### Computational test
Generate 10,000 random well-sorted terms per model, normalize them, and compare evaluations before and after normalization.

This is not a side quest. It is the empirical falsification harness for the theory and the source of scientifically meaningful hypotheses.

---

## Falsifiable conjectures for FUTURE_DIRECTIONS.md

You must include **3–5 testable scientific hypotheses**. At least one should be a genuine next-step conjecture. Here are strong candidates.

### Hypothesis 1 — Sortwise canonical forms are unique
> For the two-sorted module rewrite system, every term of vector sort reduces to a unique linear-combination normal form, modulo coefficient normalization.

**Test:** Randomly generate terms and compare normal forms from different rewrite schedules. A counterexample disproves confluence/canonicity.

### Hypothesis 2 — Many-sorted normalization yields asymptotic compression
> For random module expressions of size \(n\), the expected size of normal form grows sublinearly relative to the raw distributive expansion baseline.

**Test:** Measure normalized size vs naive expanded size across random ensembles.

### Hypothesis 3 — Typed extension to simply-typed signatures is conservative
> When simply-typed syntax is restricted to first-order operation symbols with no binders, the higher-order semantic preservation theorem reduces exactly to `ms_nf_preserves_eval`.

**Test:** Implement both semantics and compare outputs on a shared first-order fragment.

### Hypothesis 4 — Representation-theoretic normal forms expose invariant subexpressions
> In module expressions carrying a group action, normal forms statistically increase detection of invariant vectors/submodules compared with raw syntax.

**Test:** Add a small finite group action model and compare invariant-detection rates before and after normalization.

### Hypothesis 5 — Tensor-sorted extension supports symbolic physics simplification
> Extending the sort system to scalars, vectors, and rank-2 tensors yields a convergent rewrite fragment whose normal forms preserve bilinear energy expressions across all tested numerical models.

**Test:** Implement a tensor fragment and numerically compare energies before/after normalization.

These are falsifiable, computationally testable, and point directly to the next cycle.

---

## Deliverables you must produce

You must produce **all** of the following.

### 1. Lean formalization
A new Lean file with theorems and definitions above, minimizing `sorry` and prioritizing the core semantic-preservation theorems.

### 2. Verified algorithm / computational method
Implement an actual many-sorted normalizer, not just an existence theorem. It can be:
- a structurally recursive normalizer for a concrete convergent fragment, or
- a certified wrapper around a normalization function with proof of semantic preservation.

This is mandatory.

### 3. `demo.py`
Provide an interactive demo that:
- generates random many-sorted terms,
- computes normal forms,
- evaluates both raw and normalized terms in each concrete model,
- reports agreement statistics and representative examples.

### 4. `RESEARCH_PAPER.md`
A **standalone scientific document**. Someone reading only this paper must understand:
- the many-sorted master theorem,
- the new definitions,
- why the result is mathematically nontrivial,
- the module-theoretic instantiation,
- the computational tests,
- the future scientific program.

Do not assume access to code.

### 5. `ARTICLE.md`
Write this in a **Scientific American** style. Explain the discovery as a conceptual leap:
typed algebraic expressions can be optimized without changing meaning, across entire families of mathematical structures. Do **not** focus on verification machinery. Focus on the mathematics, the ideas, and the applications.

### 6. `FUTURE_DIRECTIONS.md`
Include **3–5 testable, falsifiable hypotheses** with explicit computational tests, as above or stronger.

---

## Recommended implementation order

1. Re-read `Pythagorean/ConvergentRewriteOptimizer.lean`, especially:
   - `nf_preserves_eval`
   - `ConvergentOptimizer`
   - `CertifiedNormalizer`
2. Build the many-sorted syntax/evaluation layer first.
3. Prove one-step and multi-step semantic preservation.
4. Lift the normal-form preservation theorem.
5. Instantiate the framework for a two-sorted module theory.
6. Build the random-testing harness and gather evidence.
7. If time permits, add the simply-typed extension.

---

## What success looks like

The ideal outcome is not “a generalized theorem exists.” It is this:

- You produce the first reusable many-sorted analogue of the catalog’s optimizer theorem.
- You show it works on a concrete algebraic theory that mathematicians actually care about.
- You demonstrate empirically that the framework behaves robustly across diverse models.
- You leave behind a blueprint for typed symbolic optimization in algebra, representation theory, and scientific computing.

If you can push even partway into simply-typed or higher-order territory, this ceases to be a generalization and becomes a new research platform.

---

## Application keywords

many-sorted universal algebra; convergent rewriting; typed normalization; equational theories; module theory; representation theory; symbolic linear algebra; semantics-preserving optimization; initial algebra semantics; typed DSL compilation; tensor calculus; denotational semantics; higher-order rewriting; logical relations; scientific symbolic computation

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
