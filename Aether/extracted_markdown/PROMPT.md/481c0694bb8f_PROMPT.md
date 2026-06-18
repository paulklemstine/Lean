## Assignment: Direction 1: Morita Invariance of κ

**Mode:** `prove`

Prove a genuinely new theorem program around **Morita invariance of the probe-compression invariant `κ`** for finite categories. This is not a routine extension of equivalence invariance: it is an attempt to show that `κ` is not merely a categorical invariant of a presentation, but a **topos-theoretic observable**. If successful, this would elevate `κ` from a combinatorial statistic on small categories to a new invariant of presheaf toposes, with immediate relevance to site presentations in algebraic geometry, idempotent completion in representation theory, and observational complexity in categorical semantics.

The breakthrough target is:

> **Morita Invariance Conjecture.**  
> For finite categories `C` and `D`, if their presheaf categories are equivalent,
> \[
> [C^{op}, \mathbf{Set}] \simeq [D^{op}, \mathbf{Set}],
> \]
> then
> \[
> \kappa(C) = \kappa(D).
> \]

This would mean `κ` depends only on the presheaf topos and not on the chosen site. That is a radical strengthening of the catalog theorem `compressionNumber_eq_of_equivalence`, and it opens the possibility of a whole **theory of computational/topological invariants of toposes with explicit finite formulas**.

---

## Precise Formal Target

You should formalize a theorem package that factors the conjecture through **Cauchy completion / Karoubi envelope**, because Morita equivalence of small categories is governed by idempotent splitting.

### Core theorem statement

A mathematically precise target is:

> **Theorem A (idempotent-splitting invariance).**  
> Let `C` be a finite category and let `Kar(C)` denote its Karoubi envelope (Cauchy completion). Then
> \[
> \kappa(C)=\kappa(\mathrm{Kar}(C)).
> \]

> **Theorem B (Morita invariance via Cauchy completion).**  
> Let `C D` be finite categories. If `Kar(C) ≌ Kar(D)`, then
> \[
> \kappa(C)=\kappa(D).
> \]

> **Corollary C (presheaf-Morita invariance).**  
> If `[Cᵒᵖ, \mathbf{Set}] ≌ [Dᵒᵖ, \mathbf{Set}]`, then
> \[
> \kappa(C)=\kappa(D),
> \]
> assuming the standard theorem that presheaf equivalence implies equivalence of Cauchy completions.

If the full presheaf-category statement is too heavy to complete in one cycle, you must still prove Theorem A and Theorem B, and explicitly isolate the remaining imported Morita-to-Cauchy bridge as a formalization frontier.

---

## Lean 4 formalization targets

You must write precise Lean targets, even if exact Mathlib names need slight adjustment after import inspection. Aim for signatures of the following shape:

```lean
/-- A finite-category probe complexity invariant extending the catalog κ/compression number. -/
def kappa (C : Type u) [Category.{v} C] [Fintype C]
    [FiniteHom C] : ℕ := ...

/-- The Karoubi envelope / Cauchy completion restricted to finite categories. -/
def KaroubiFinite (C : Type u) [Category.{v} C] := CategoryTheory.Karoubi C
```

### Main target theorem signatures

```lean
theorem kappa_eq_of_equivalence
    (C : Type u) (D : Type u)
    [Category.{v} C] [Category.{v} D]
    [Fintype C] [Fintype D]
    [FiniteHom C] [FiniteHom D]
    (e : C ≌ D) :
    kappa C = kappa D := ...
```

This should build directly on the catalog theorem in
`Pythagorean/ProbeComplexity/NonDiscreteCompression.lean`.

Then the new targets:

```lean
theorem kappa_eq_karoubi
    (C : Type u) [Category.{v} C]
    [Fintype C] [FiniteHom C] :
    kappa C = kappa (CategoryTheory.Karoubi C) := ...
```

```lean
theorem kappa_eq_of_karoubi_equivalence
    (C : Type u) (D : Type u)
    [Category.{v} C] [Category.{v} D]
    [Fintype C] [Fintype D]
    [FiniteHom C] [FiniteHom D]
    (e : CategoryTheory.Karoubi C ≌ CategoryTheory.Karoubi D) :
    kappa C = kappa D := ...
```

And, if you can formalize the Morita bridge:

```lean
theorem kappa_eq_of_presheaf_equivalence
    (C : Type u) (D : Type u)
    [Category.{v} C] [Category.{v} D]
    [Fintype C] [Fintype D]
    [FiniteHom C] [FiniteHom D]
    (e : (Cᵒᵖ ⥤ Type w) ≌ (Dᵒᵖ ⥤ Type w)) :
    kappa C = kappa D := ...
```

If universe or `Type` issues obstruct this exact statement, use a finite-set-valued presheaf replacement or explicitly state a theorem with the needed smallness assumptions. But do not weaken the mathematics without saying exactly why.

---

## New definitions you should introduce

You are required to define at least one genuinely new concept not already in the catalog. The right move is to define a structure that captures the combinatorics of probe families under idempotent splitting.

### Suggested new definition 1: split-stable probe family

Define a notion expressing that a probe family on `C` extends canonically to the Karoubi envelope without increasing size.

```lean
structure SplitStableProbeFamily
    (C : Type u) [Category.{v} C] [Fintype C] [FiniteHom C] where
  probes : Finset ...
  separates : ...
  stable_under_retracts :
    ∀ {X Y : CategoryTheory.Karoubi C}, ... 
```

The key idea: a probe family is **split-stable** if whenever an object of `Kar(C)` is a retract of an object from `C`, the probe data induced from the ambient object still separates it optimally.

### Suggested new definition 2: retract profile

Define a finite combinatorial invariant recording how each object is observed through retract embeddings.

```lean
def retractProfile
    (C : Type u) [Category.{v} C] [Fintype C] [FiniteHom C]
    (X : CategoryTheory.Karoubi C) : Finset ... := ...
```

Then prove that `κ` depends only on retract profiles up to equivalence. This gives a new bridge between categorical complexity and idempotent completion.

This is the kind of definition that can later support an entire theory: **observational complexity under completion operations**.

---

## Proof architecture: 3 viable strategies

You must pursue at least two of these in the file, even if one becomes the primary path.

### Strategy A: explicit probe transport through retracts
**Most promising.**

1. Start from a minimal probe family on `C`.
2. For each object `(X,e)` in `Kar(C)`, use the retract diagram
   \[
   (X,e) \xrightarrow{i} X \xrightarrow{p} (X,e), \quad p i = 1, \quad i p = e
   \]
   to define induced probe observations on `(X,e)` from probes on `X`.
3. Prove that if probes separate objects/morphisms in `C`, then the induced family separates in `Kar(C)` with no increase in cardinality.
4. Conversely, restrict any probe family on `Kar(C)` along the fully faithful embedding `C → Kar(C)` to get a probe family on `C`.
5. Conclude by two inequalities:
   \[
   \kappa(\mathrm{Kar}(C)) \le \kappa(C), \qquad \kappa(C) \le \kappa(\mathrm{Kar}(C)).
   \]

Why this is strongest: it is constructive, algorithmic, and directly yields a verified computation method. It also produces the demo machinery naturally.

### Strategy B: characterize κ via representables in the presheaf topos
**More conceptual, potentially revolutionary.**

1. Reinterpret probe families as finite separating families of representable presheaves or finite combinations thereof.
2. Show that the quantity defining `κ(C)` can be expressed entirely inside the presheaf category `[Cᵒᵖ, Set]`.
3. Since Morita-equivalent categories have equivalent presheaf categories, infer invariance immediately.

Why this matters: if successful, this is the real conceptual breakthrough — `κ` becomes a genuine topos invariant, not merely something preserved by a special completion. But it may require more infrastructure than one cycle.

### Strategy C: matrix/combinatorial encoding of finite categories
**Good for experimentation and counterexample search.**

1. Encode a finite category by its incidence data: object set, hom-cardinality matrix, and composition constraints.
2. Define a computable `κ`-certificate and prove that splitting an idempotent corresponds to a controlled refinement of the matrix that preserves the optimum.
3. Use this for exhaustive search on categories with 2–4 objects and ≤ 10 morphisms.

Why this is important: even if the full theorem stalls, this yields a verified algorithm and can produce either strong evidence or a counterexample. It is also the best route for `demo.py`.

---

## Required theorem slate

You must prove **at least 3 substantial theorems** with nontrivial proof structure. The following is a recommended minimal slate:

1. **Embedding lower bound theorem**
   ```lean
   theorem kappa_le_kappa_karoubi
       (C : Type u) [Category.{v} C] [Fintype C] [FiniteHom C] :
       kappa C ≤ kappa (CategoryTheory.Karoubi C) := ...
   ```
   Proof should use restriction along the canonical embedding, with `rcases`, multi-step `calc`, and a contradiction argument for failure of separation.

2. **Retract extension upper bound theorem**
   ```lean
   theorem kappa_karoubi_le_kappa
       (C : Type u) [Category.{v} C] [Fintype C] [FiniteHom C] :
       kappa (CategoryTheory.Karoubi C) ≤ kappa C := ...
   ```
   Proof should use explicit retract decomposition, induced probes, and at least one induction or case decomposition over finite witnesses.

3. **Karoubi invariance theorem**
   ```lean
   theorem kappa_eq_karoubi
       (C : Type u) [Category.{v} C] [Fintype C] [FiniteHom C] :
       kappa C = kappa (CategoryTheory.Karoubi C) := by
     exact le_antisymm ... ...
   ```

4. **Morita consequence theorem**
   ```lean
   theorem kappa_eq_of_karoubi_equivalence
       (C D : Type u)
       [Category.{v} C] [Category.{v} D]
       [Fintype C] [Fintype D]
       [FiniteHom C] [FiniteHom D]
       (e : CategoryTheory.Karoubi C ≌ CategoryTheory.Karoubi D) :
       kappa C = kappa D := ...
   ```
   Build this from `kappa_eq_karoubi`, the catalog equivalence theorem, and transitivity.

5. **Cross-domain theorem**
   Connect to another area. A strong option:
   ```lean
   theorem kappa_invariant_under_idempotent_completion_of_finite_semiring_category
       ...
   ```
   or a theorem relating `κ` to finite-state observation complexity of automata categories / representation categories.

---

## Cross-domain connections you must exploit

This project becomes revolutionary only if you explicitly connect it beyond category theory.

### 1. Topos theory / algebraic geometry
Presheaf toposes admit many site presentations. If `κ` is Morita invariant, then it is an **observable of the topos itself**, not of the chosen site. That suggests a new finite complexity lens on:
- choice of generators in a topos,
- comparison of different affine covers / site presentations,
- invariants of combinatorial geometries presented as presheaf categories.

### 2. Homological algebra / representation theory
Karoubi completion is ubiquitous because idempotent splitting creates direct summands. If `κ` survives passage to the idempotent completion, then `κ` behaves like a **summand-stable complexity invariant**, analogous in spirit to how K-theoretic data ignores presentation artifacts and sees stable structure.

### 3. Computer science / automata semantics
Finite categories and presheaf semantics encode transition systems, structured state spaces, and observational equivalence. Morita invariance of `κ` would imply that observational complexity is unchanged under completion by latent retract states. This is a categorical analogue of **state minimization invariance under semantic completion**.

### 4. Mathematical physics
Idempotent completion appears in extended TQFT and defect theory, where splitting idempotents corresponds to adding emergent sectors/superselection components. If `κ` is preserved, it suggests that the “observable complexity” of a theory is unchanged when hidden projector sectors are made explicit.

---

## Concrete computational program

You must not only prove theorems but also produce a verified algorithm and empirical evidence.

### Verified algorithm requirement
Implement an algorithm that:
1. accepts a finite category `C`,
2. computes or upper/lower bounds `κ(C)`,
3. constructs `Kar(C)`,
4. computes `κ(Kar(C))`,
5. compares the two and returns a proof-relevant certificate when they agree.

If exact computation is expensive, implement a certified search for minimal probe families with pruning by isomorphism classes and retract-profile compression.

### `demo.py` requirement
`demo.py` must:
- construct explicit examples of finite categories with 2–4 objects,
- build their Karoubi envelopes or equivalent retract completions,
- compute `κ` on both sides,
- print comparison tables,
- visualize probe families or observation matrices.

Suggested examples:
- a one-object category from a finite monoid with a nontrivial idempotent,
- a two-object category with a split idempotent added,
- a category and a skeleton of its Karoubi envelope,
- tiny poset categories where idempotent splitting is trivial, as controls.

---

## Testable conjectures and predictions

You must include at least one falsifiable conjecture with a clear computational test. Preferably include 3–5 in `FUTURE_DIRECTIONS.md`. Here are strong candidates:

1. **Morita invariance conjecture**
   > For every finite categories `C, D`, if `[Cᵒᵖ, Set] ≌ [Dᵒᵖ, Set]`, then `κ(C)=κ(D)`.
   **Test:** Exhaustive search over finite categories with ≤ 4 objects and ≤ 10 morphisms, grouped by Karoubi-equivalence heuristics.

2. **Retract-profile sufficiency conjecture**
   > `κ(C)` is determined by the multiset of retract profiles of representables in `Kar(C)`.
   **Test:** Search for categories with identical retract-profile multisets but different computed `κ`.

3. **Semiring-monoid stability conjecture**
   > For one-object categories arising from finite monoids `M`, `κ(M)` depends only on the Karoubi envelope of `M`, equivalently only on the idempotent-splitting structure of principal ideals.
   **Test:** Compare nonisomorphic monoids with equivalent Karoubi envelopes.

4. **Subadditivity under finite coproduct conjecture**
   > `κ(C ⊔ D) = max (κ(C)) (κ(D))` or at worst `≤ κ(C)+κ(D)`.
   **Test:** Compute examples and search for strict inequalities.

5. **Topos-generator conjecture**
   > `κ(C)` equals the minimal size of a finite separating family of representables in `[Cᵒᵖ, Set]`.
   **Test:** Compute both sides directly for small categories.

These are scientifically valuable because any counterexample teaches you exactly what extra structure, beyond Morita type, controls observational complexity.

---

## Catalog theorem to build on

Use:
- `Pythagorean/ProbeComplexity/NonDiscreteCompression.lean`

In particular, leverage the theorem analogous to:
- `compressionNumber_eq_of_equivalence`

Do not merely cite it; **factor your new proof through it**:
1. prove `kappa C = kappa (Karoubi C)`,
2. use equivalence invariance on `Karoubi C ≌ Karoubi D`,
3. conclude Morita invariance.

This is the correct lineage: **equivalence invariance → idempotent-splitting invariance → Morita invariance**.

---

## Implementation guidance in Lean

You must minimize `sorry`. If external Morita-to-Cauchy machinery is unavailable, formalize the strongest internal statement you can fully verify.

Use nontrivial proof tactics:
- `rcases` for unpacking retract data,
- `by_contra` for separation arguments,
- `induction` over finite search structures or probe family construction,
- `field_simp` if rational/combinatorial weighting appears in auxiliary lemmas,
- multi-step `calc` for inequality chaining.

Avoid trivial theorem statements whose proof is only `rfl`/`decide`/`native_decide`. The point is to create a theorem architecture with genuine mathematical content.

---

## Deliverables you must produce

You must produce **all** of the following:

1. **Lean file(s)** with theorems, definitions, and a verified algorithmic component.
2. **`FUTURE_DIRECTIONS.md`** containing **3–5 falsifiable scientific hypotheses**, each with:
   - a precise conjecture,
   - what computation or theorem would test it,
   - what a counterexample would mean.
3. **`RESEARCH_PAPER.md`** as a standalone scientific paper:
   - problem statement,
   - theorem statements,
   - proof ideas,
   - computational experiments,
   - significance and open problems.
   It must be understandable without access to the code.
4. **`ARTICLE.md`** in Scientific American style:
   - broad audience,
   - why Morita invariance is surprising,
   - why “same topos, same complexity” matters,
   - no focus on verification machinery.
5. **A verified algorithm or computational method**, not just theorem statements.
6. **`demo.py`** demonstrating the result interactively on explicit finite categories.

---

## Application keywords

Morita equivalence; presheaf topos; Cauchy completion; Karoubi envelope; idempotent splitting; finite categories; observational complexity; probe complexity; categorical semantics; finite-state systems; representation theory; algebraic geometry; topological invariants of toposes; retracts; generator complexity; semantic compression; extended TQFT; superselection sectors.

---

## Standard of success

A merely formal statement of `kappa_eq_of_karoubi_equivalence` is not enough. The real success criterion is:

- a new **definition** that captures split-stable observation,
- at least **3 nontrivial theorems**,
- a **constructive proof path** for Karoubi invariance,
- a **computational pipeline** testing the conjecture,
- and a clear argument that this opens a new field:  
  **the study of finitary, computable invariants of toposes and Morita types**.

This is the moment to turn `κ` from a catalog invariant into a bridge between finite category theory, topos semantics, and computational complexity.

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
