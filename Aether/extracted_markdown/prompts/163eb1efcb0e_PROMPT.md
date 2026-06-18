## Mode: prove

## Assignment: Extend Canonicalization from AC to ACI for Tropical `min`

Aristotle, this is the right kind of theorem: not a cosmetic extension, but a genuine escalation in proof automation power. AC normalization treats tropical expressions as if duplication matters; ACI normalization recognizes the actual algebraic geometry of the tropical world. In min-plus mathematics, multiplicity under `min` is semantically invisible. A certified ACI normalizer would turn that semantic fact into a decision procedure, opening a bridge from symbolic normalization to idempotent semiring reasoning, shortest-path certificates, and tropical automata.

The key breakthrough is to prove that canonicalization modulo associativity, commutativity, and idempotence for tropical `min` is both sound and complete, and therefore yields a stronger normalization-based equality test than the current AC procedure.

---

## Precise Theorem Targets

You should formalize a new ACI equivalence for tropical expressions with `tmin` and prove that normalization by flattening, sorting, and deduplicating computes canonical representatives.

Assume the existing expression language and AC normalizer infrastructure already present in the catalog/codebase. Introduce an ACI normalizer for `tmin` nodes only.

### Core semantic theorem
A precise target is:

```lean
theorem eval_normalize_aci
  (e : TropExpr) (ρ : Var → ℝ) :
  eval ρ (normalize_aci e) = eval ρ e
```

This is the soundness theorem: normalization preserves tropical semantics.

### Completeness / canonicality theorem
The real field-opening theorem is:

```lean
theorem normalize_aci_complete
  (e₁ e₂ : TropExpr) :
  ACIEquiv e₁ e₂ ↔ normalize_aci e₁ = normalize_aci e₂
```

This says the normal form is complete for the quotient by associativity, commutativity, and idempotence of `tmin`.

### Decision-procedure corollary
The payoff theorem:

```lean
theorem eval_eq_of_normalize_aci_eq
  (e₁ e₂ : TropExpr) (h : normalize_aci e₁ = normalize_aci e₂) :
  ∀ ρ, eval ρ e₁ = eval ρ e₂
```

and ideally the converse under the syntactic quotient:

```lean
theorem normalize_aci_eq_iff_aci
  (e₁ e₂ : TropExpr) :
  normalize_aci e₁ = normalize_aci e₂ ↔ ACIEquiv e₁ e₂
```

### Idempotence of the normalizer itself
This is mathematically important and implementation-critical:

```lean
theorem normalize_aci_idempotent
  (e : TropExpr) :
  normalize_aci (normalize_aci e) = normalize_aci e
```

This theorem is more than hygiene: it certifies that your algorithm computes actual canonical forms, not merely reduced forms.

### Strict strengthening over AC
If the old normalizer is `normalize_ca`, prove there exist expressions identified by ACI but not by AC:

```lean
theorem normalize_aci_strictly_stronger :
  ∃ e₁ e₂ : TropExpr,
    normalize_ca e₁ ≠ normalize_ca e₂ ∧
    normalize_aci e₁ = normalize_aci e₂
```

The canonical witness should be the obvious duplication example, e.g. `tmin x x` versus `x`, or `tmin x (tmin x y)` versus `tmin x y`, depending on the syntax.

This theorem matters because it proves you did not merely repackage AC normalization—you enlarged the decidable quotient.

---

## Lean 4 Formalization Shape

You will likely need a definition of ACI equivalence extending the existing AC relation:

```lean
inductive ACIEquiv : TropExpr → TropExpr → Prop
| refl  : ∀ e, ACIEquiv e e
| symm  : ∀ {e₁ e₂}, ACIEquiv e₁ e₂ → ACIEquiv e₂ e₁
| trans : ∀ {e₁ e₂ e₃}, ACIEquiv e₁ e₂ → ACIEquiv e₂ e₃ → ACIEquiv e₁ e₃
| tmin_assoc : ∀ a b c, ACIEquiv (tmin (tmin a b) c) (tmin a (tmin b c))
| tmin_comm  : ∀ a b, ACIEquiv (tmin a b) (tmin b a)
| tmin_idem  : ∀ a, ACIEquiv (tmin a a) a
| cong_tmin  : ∀ {a a' b b'}, ACIEquiv a a' → ACIEquiv b b' → ACIEquiv (tmin a b) (tmin a' b')
| cong_other : ...
```

If the expression language has additional constructors (`const`, `var`, `add`, `max`, etc.), include congruence appropriately, but keep idempotence local to `tmin`.

The normalization pipeline should have the shape:

```lean
def normalize_aci : TropExpr → TropExpr
```

with `tmin` case:
1. recursively normalize children,
2. flatten nested `tmin`,
3. sort children using existing total order machinery,
4. deduplicate adjacent equal children,
5. rebuild a canonical tree.

Supporting list-level machinery may be the real engine:

```lean
def flatten_tmin : TropExpr → List TropExpr
def dedupSorted : List TropExpr → List TropExpr
def rebuild_tmin : List TropExpr → TropExpr
```

and the critical list theorem:

```lean
theorem eval_rebuild_tmin_dedupSorted
  (xs : List TropExpr) (ρ : Var → ℝ) :
  eval ρ (rebuild_tmin (dedupSorted (sort xs))) =
  eval ρ (rebuild_tmin (sort xs))
```

This is where `min(a,a)=a` enters as the semantic heart of the construction.

---

## Build Explicitly on Catalog Theorems

Use the catalog theorems as structural anchors, not decoration.

1. `tropical_min_idempotent`  
   File: `Tropical/HodgeTheory/Foundations.lean`  
   This should be the semantic atom of the soundness proof. Every deduplication step should reduce to this theorem, possibly after rewriting the rebuilt list expression into a nested `min`.

2. `tropical_lattice_min_max`  
   File: `Tropical/Core/TropicalFactoring.lean`  
   This suggests the existing development already treats tropical operations in lattice-theoretic terms. Use it to motivate and possibly support lemmas showing `tmin` behaves as meet in an idempotent semilattice. If there is an existing order-theoretic interface, exploit it to prove duplicate elimination semantically by meet-idempotence rather than by raw arithmetic rewriting.

3. `idempotent_self_reference_is_identity`  
   File: `Tropical/AlgebraicMirror.lean`  
   Even if this theorem lives in a different conceptual layer, it may provide an abstraction pattern: maps or operators satisfying idempotence collapse repeated application. Use this as a model for `normalize_aci_idempotent`, where the algorithm itself becomes an idempotent operator.

Do not merely cite these. Refactor around them if they can shorten core proofs.

---

## Proof Strategy Architecture

### Strategy A: Direct syntactic canonicalization via sorted-deduped child lists
This is likely the most promising route.

**Step 1.** Prove list-level semantic invariance under deduplication for sorted `tmin`-lists.  
Show that if adjacent duplicates are removed from a sorted list of normalized children, the rebuilt `tmin` expression has identical evaluation. This should repeatedly use `tropical_min_idempotent`.

**Step 2.** Define `normalize_aci` and prove soundness by structural recursion.  
The only new case beyond AC is deduplication; all previous flatten/sort arguments should survive.

**Step 3.** Prove completeness by characterizing ACI classes through sorted-deduped flattenings.  
This is the conceptual core: prove that two expressions are ACI-equivalent iff their flattened multisets modulo duplicate erasure coincide, i.e. iff their sorted-deduped child lists are equal.

**Why this is strongest:** it yields executable normalization, canonical forms, and immediate decision procedures.

---

### Strategy B: Semilattice quotient first, algorithm second
This is more abstract and may produce cleaner mathematics.

**Step 1.** Show that `tmin` generates a join/meet-semilattice fragment on expressions modulo `ACIEquiv`.  
In other words, the quotient syntax under ACI behaves like finite meets of atoms.

**Step 2.** Prove every expression is equivalent to the meet of a finite set of normalized generators.  
Then define canonicalization as the ordered list representation of that finite set.

**Step 3.** Derive the algorithmic normalizer from the semilattice normal form theorem.  
Sorting gives canonical order; deduplication corresponds to setification.

**Why this is attractive:** it reveals the algebraic meaning of the algorithm and connects immediately to idempotent semirings, lattice theory, and finite abstract interpretation.

**Risk:** more quotient infrastructure in Lean, potentially heavier than needed.

---

### Strategy C: Completion via reflection/decision procedure
If the codebase already contains a reflective AC tactic or normalization theorem, extend it.

**Step 1.** Generalize the reflection theorem for AC normalization to an ACI reflection theorem.  
Treat `tmin`-nodes as finite sets rather than lists/multisets.

**Step 2.** Implement deduplication in the reflected syntax and prove correctness.  
This may require a theorem that sorted-deduped lists are canonical representatives of finite sets.

**Step 3.** Package the result as a stronger equality test.  
This opens the path to automation: a tactic can discharge `eval ρ e₁ = eval ρ e₂` goals by normalization.

**Why it matters:** this transforms the theorem into reusable proof infrastructure.

**Risk:** dependent on existing reflection machinery and potentially more engineering-heavy.

---

## The Key Mathematical Insight

AC normalization models `tmin` as a commutative monoid. But tropical `min` is not merely a commutative monoid operation—it is a semilattice operation. Passing from AC to ACI is exactly the passage from multisets to finite sets. That is a categorical and algorithmic upgrade:

- AC normal forms classify expressions by multiplicity-sensitive flattenings.
- ACI normal forms classify expressions by support.
- Tropical geometry, shortest paths, and regular-language semirings care about support, not multiplicity, under `min`.

So the right abstraction is not “sort a bag” but “compute the finite meet-support.” Formalizing this cleanly could become the kernel of a general idempotent-normalization framework in Lean.

---

## Cross-Domain Connections

This is where the result becomes bigger than a local theorem.

### 1. Shortest-path and dynamic programming semantics
In min-plus algebra, duplicate path options do not change the optimum. Your ACI normalizer is a certified duplicate-elimination engine for dynamic-programming expressions. This directly connects to Floyd–Warshall, Bellman optimality, and weighted automata over the tropical semiring.

### 2. Lattice theory and abstract interpretation
`min` is meet. Canonicalization modulo ACI is canonicalization in a semilattice. That means the theorem is a prototype for certified simplification in abstract domains, where repeated constraints should collapse automatically.

### 3. Formal language theory and idempotent semirings
In Kleene-algebra-adjacent settings, idempotent addition is foundational. If you prove this properly, you are one abstraction away from generic normalization for idempotent commutative semirings. That is potentially a gateway theorem for certified weighted-automata reasoning.

### 4. Tropical geometry
Tropical polynomials are piecewise-linear minima/maxima. Duplicate monomials are geometrically irrelevant. ACI canonicalization is therefore a symbolic preprocessing theorem for tropical hypersurface computations and normal-form comparisons.

### 5. Proof automation / rewriting systems
This theorem can seed a generic Lean mechanism for normalization modulo semilattice laws. That is not just one theorem; it is infrastructure for many future domains.

---

## Breakthrough Significance

If done correctly, this opens a new formal-methods corridor: certified normalization for idempotent algebraic structures. The first theorem is about tropical `min`; the real destination is a general architecture for decision procedures in semilattices, dioids, and tropical semirings.

This is not “add one rewrite rule.” It is the formal recognition that idempotence changes the ontology of expressions. Once multiplicity is erased, one can reason in supports, antichains, and finite semilattice bases. That shift can power future work on:

- certified shortest-path simplifiers,
- canonical tropical polynomial comparison,
- weighted automata equivalence preprocessing,
- generic semiring normalization tactics.

Prove this in Lean and you have a seed crystal for a broader idempotent algebra library.

---

## Concrete Implementation Targets

Aim to produce some combination of the following theorem names, adapting to the existing namespace:

```lean
theorem dedupSorted_sound_tmin
theorem rebuild_tmin_dedupSorted_eq
theorem eval_normalize_aci
theorem normalize_aci_idempotent
theorem normalize_aci_complete
theorem normalize_aci_eq_iff_aci
theorem normalize_aci_strictly_stronger
```

If the codebase contains an existing `normalize_ca_sound` or `normalize_ca_complete`, mirror their theorem structure as closely as possible and then isolate the genuinely new lemmas in the deduplication layer.

---

## Application Keywords

tropical semiring, idempotent semiring, semilattice normalization, canonical forms, proof automation, certified rewriting, shortest paths, Floyd–Warshall, weighted automata, abstract interpretation, lattice theory, tropical geometry, decision procedures, reflection, finite-set semantics

---

## Deliverables

1. The Lean implementation of `normalize_aci` and supporting list machinery.
2. Soundness theorem: evaluation preserved.
3. Completeness theorem: equality of normal forms iff ACI equivalence.
4. Idempotence theorem for the normalizer.
5. A strictness witness showing ACI is stronger than AC.
6. Minimize sorry aggressively; isolate any unavoidable gap to the most abstract completeness lemma only.

---

## Required FUTURE_DIRECTIONS.md

You must also produce a structured `FUTURE_DIRECTIONS.md` containing 3–5 concrete breakthrough next steps. These should be specific, theorem-level proposals, for example:

- generic ACI normalization for arbitrary idempotent commutative binary operations,
- canonicalization for full tropical semiring expressions with distributivity-aware normalization,
- certified equivalence for weighted automata expressions over tropical semirings,
- tropical polynomial support-normalization and hypersurface invariance,
- reflective Lean tactic for semilattice/idempotent-semiring equalities.

Make these future directions ambitious, technically precise, and clearly downstream of the theorem you prove now.

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
DELIVERABLE 4 — Python Code: Demos, Visualizations, Algorithms
────────────────────────────────────────────────────────────────────────────
- **demo.py** — Working Python code demonstrating the theorems with
  concrete numerical examples. Make the math tangible.
- **visualizations** — matplotlib / plotly charts showing key mathematical
  structures, convergence behavior, phase diagrams, etc.
  Save figures as PNG/SVG files for inclusion in the HTML package.
- **algorithms.py** — Implement any algorithms from the research paper.
  Include docstrings, type hints, and example usage.
- **applications.py** — Code showing real-world applications of the results.
  If the math applies to ML, crypto, physics — show it working.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 5 — FUTURE_DIRECTIONS.md  (MANDATORY — drives next cycle)
────────────────────────────────────────────────────────────────────────────
The MOST IMPORTANT deliverable. Structured roadmap of breakthrough
research opportunities opened by this work. See detailed spec below.

**Team Directive**: Create a team to conduct research, brainstorm hypotheses,
run experiments, validate data, update knowledge base and iterate forever.
Each future direction should be specific enough for a team to pick up and
pursue with clear hypotheses, proof strategies, and cross-domain connections.

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
    "visualizations": [ { "name": "...", "data": "base64 encoded URI or inline SVG string" } ],
    "lean_proofs": "Raw lean code..."
  }
• **String Encoding**: Ensure all Markdown and code is properly JSON-escaped (e.g. `
` for newlines).
• **Embedded images**: ALL images (charts, diagrams, visualizations) MUST be
  embedded directly in the JSON. If you generate matplotlib/plotly figures, convert them to base64
  data URIs (e.g., `data:image/png;base64,...`). For SVG diagrams, put the raw `<svg>...</svg>`
  string into the `data` field. NEVER reference external image files.
• **Complete**: Include ALL content from the article, research paper, and code. This JSON file
  is the sole data source for the frontend web application.

────────────────────────────────────────────────────────────────────────────

The mathematics comes FIRST. Excellent proofs trump everything else.
But great work deserves great presentation — make it real, useful, and
beautiful. Every deliverable should be something you'd be proud to show.

Research domain: Tropical
Research mode: prove
