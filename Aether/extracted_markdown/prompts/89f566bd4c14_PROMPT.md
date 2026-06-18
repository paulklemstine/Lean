## Assignment: Proof Complexity: Resolution, Width, and Cutting Planes as Formal Combinatorics of Search

Mode: **prove + formalize + discover**

This direction is only superficially about proof systems. The real opportunity is to formalize a new bridge between **combinatorics, entropy/compression, and algorithmic search complexity** inside Lean 4. Do not aim for a toy encoding of resolution. Aim to isolate the exact combinatorial invariants that force long proofs, and then connect them to SAT heuristics and information bottlenecks.

The revolutionary target is not merely “formalize Haken.” It is:

1. a machine-checkable formal theory of propositional proof systems,
2. a certified lower-bound pipeline from combinatorial width/covering arguments to proof size,
3. a first formal separation theorem between proof systems,
4. a bridge theorem explaining why structural lower bounds predict SAT solver hardness.

This would open a new formalized research program in **proof complexity as certified complexity theory**, with downstream applications to SAT, verification, automated theorem proving, and explainable hardness metrics.

---

## Core Research Direction

Formalize the **resolution proof system** for CNF formulas, define proof size/length/width, encode the **pigeonhole principle** as an unsatisfiable CNF, and prove a non-trivial lower-bound theorem. Then formalize a basic **cutting-planes** system and prove at least one rigorous separation phenomenon from resolution. Finally, connect these proof-complexity invariants to SAT solver behavior via formally stated hardness proxies.

You should not begin with the full strongest version of Haken’s theorem if it causes the project to stall. Instead, architect a sequence of breakthrough theorems culminating in an exponential lower bound, with intermediate width and counting lemmas that are independently valuable and reusable.

---

## Precise Formal Targets

### 1. Resolution infrastructure

Define literals, clauses, CNFs, valuation satisfaction, and derivability in resolution.

A plausible Lean 4 scaffold:

```lean
inductive Lit (ν : Type)
| pos : ν → Lit ν
| neg : ν → Lit ν
deriving DecidableEq, Fintype

abbrev Clause (ν : Type) := Finset (Lit ν)
abbrev CNF (ν : Type) := Finset (Clause ν)

def Lit.eval {ν : Type} (τ : ν → Bool) : Lit ν → Bool
| Lit.pos x => τ x
| Lit.neg x => !(τ x)

def Clause.Satisfied {ν : Type} (τ : ν → Bool) (C : Clause ν) : Prop :=
  ∃ l ∈ C, Lit.eval τ l = true

def CNF.Satisfied {ν : Type} (τ : ν → Bool) (F : CNF ν) : Prop :=
  ∀ C ∈ F, Clause.Satisfied τ C

def Clause.resolveOn {ν : Type} [DecidableEq ν] (x : ν) (C D : Clause ν) : Clause ν :=
  ((C.erase (Lit.pos x)) ∪ (D.erase (Lit.neg x))).eraseDups
```

Then define a derivation/proof object:

```lean
inductive ResDerives {ν : Type} [DecidableEq ν] (F : CNF ν) : Clause ν → Prop
| hyp  : ∀ {C}, C ∈ F → ResDerives F C
| weaken : ∀ {C D}, ResDerives F C → C ⊆ D → ResDerives F D
| resolve :
    ∀ {C D x},
      ResDerives F (insert (Lit.pos x) C) →
      ResDerives F (insert (Lit.neg x) D) →
      ResDerives F (C ∪ D)
```

You may prefer a DAG-style proof object carrying explicit size. That is likely better if you want quantitative lower bounds.

#### Foundational soundness theorem
```lean
theorem resolution_sound
  {ν : Type} [DecidableEq ν] (F : CNF ν) (C : Clause ν) :
  ResDerives F C →
  ∀ τ : ν → Bool, CNF.Satisfied τ F → Clause.Satisfied τ C
```

This theorem is essential. It is the semantic anchor for every later lower bound and separation.

---

### 2. Pigeonhole CNF and its unsatisfiability

Use variables `Var := Fin m × Fin n`, interpreted as “pigeon i goes to hole j”.

For PHP with `m = n+1`, define clauses:
- each pigeon chooses some hole,
- no hole contains two distinct pigeons.

Possible signature:

```lean
def PHPVar (m n : ℕ) := Fin m × Fin n

def phpAtLeastOne (m n : ℕ) : CNF (PHPVar m n)
def phpAtMostOne (m n : ℕ) : CNF (PHPVar m n)
def phpCNF (m n : ℕ) : CNF (PHPVar m n) :=
  phpAtLeastOne m n ∪ phpAtMostOne m n
```

#### Unsatisfiability theorem
```lean
theorem php_unsat (n : ℕ) :
  ¬ ∃ τ : PHPVar (n+1) n → Bool, CNF.Satisfied τ (phpCNF (n+1) n)
```

This is not the breakthrough; it is the semantic substrate. Prove it cleanly using finite counting / injectivity contradiction.

---

### 3. Width as the gateway lower bound

Do not try to jump directly to full Haken size lower bounds without a width infrastructure. Width is the right invariant because it is combinatorial, finitary, and Lean-friendly.

Define clause width:

```lean
def Clause.width {ν : Type} (C : Clause ν) : ℕ := C.card
```

Define proof width as the maximum width of any derived clause in a proof object.

Then target a **resolution width lower bound** for PHP. A mathematically precise and realistic target is:

```lean
theorem php_resolution_width_lb (n : ℕ) :
  ∀ π : ResProof (phpCNF (n+1) n) ∅,
    n ≤ π.width
```

or a variant with constants adjusted depending on your exact encoding. Even a weaker theorem of the form `∃ c > 0, c*n ≤ π.width` is major.

This is the strategic fulcrum. Once formalized, it enables size lower bounds via width-size inequalities.

---

### 4. Width-size inequality and exponential lower bound

Formalize a theorem in the spirit of Ben-Sasson–Wigderson: large required width implies large proof size.

A Lean-friendly quantitative statement could be:

```lean
theorem resolution_size_lower_of_width
  {ν : Type} [Fintype ν] [DecidableEq ν]
  (F : CNF ν) (w0 w : ℕ) :
  initialMaxWidth F ≤ w0 →
  requiredWidth F ≥ w →
  ∀ π : ResProof F ∅,
    2 ^ ((w - w0) / 2) ≤ π.size
```

You may need to formalize a weaker but still exponential statement first, e.g. with rough constants or under regular-tree-resolution assumptions.

Then instantiate for PHP:

```lean
theorem php_resolution_exp_lb (n : ℕ) :
  ∀ π : ResProof (phpCNF (n+1) n) ∅,
    2 ^ (n / 8) ≤ π.size
```

The exact exponent constant is negotiable. What matters is a certified theorem of the form `2^(Ω n) ≤ size`.

This is the genuine breakthrough target.

---

### 5. Cutting planes and separation from resolution

Formalize a simple cutting-planes system over 0/1 variables with linear inequalities.

Suggested representation:

```lean
structure LinIneq (ν : Type) where
  coeff : ν → ℤ
  rhs   : ℤ

def LinIneq.Valid01 {ν : Type} (τ : ν → Bool) (L : LinIneq ν) : Prop := ...
```

Define a proof system with:
- hypotheses,
- nonnegative linear combination,
- division/rounding rule.

Then encode PHP as linear inequalities and prove there is a **short cutting-planes refutation**.

A realistic theorem target:

```lean
theorem php_has_poly_cp_refutation (n : ℕ) :
  ∃ π : CPProof (phpCPConstraints (n+1) n) FalseConstraint,
    π.size ≤ Polynomial.bound 3 n
```

You can encode “polynomial” concretely as `π.size ≤ (n+1)^3 + 10`.

Then combine with the resolution lower bound:

```lean
theorem cutting_planes_separates_resolution_on_php (n : ℕ) :
  (∃ πcp : CPProof (phpCPConstraints (n+1) n) FalseConstraint,
      πcp.size ≤ (n+1)^3 + 10) ∧
  (∀ πres : ResProof (phpCNF (n+1) n) ∅,
      2 ^ (n / 8) ≤ πres.size)
```

This is a true formal separation theorem. Even if you first prove it for a restricted version of cutting planes or tree-like resolution, it is already field-opening.

---

## Why This Would Be a Breakthrough

A fully formalized lower-bound argument in proof complexity is rare and difficult because it forces one to make explicit every hidden combinatorial invariant. If you succeed, you will have created:

- a reusable Lean framework for propositional proof systems,
- a certified lower-bound pipeline,
- a formal bridge from unsatisfiable formulas to solver hardness,
- a foundation for future work on CDCL, polynomial calculus, and feasible interpolation.

This opens the door to:
- certified hardness benchmarks for SAT,
- formal metatheorems comparing proof systems,
- verified explanations of why certain solver architectures fail,
- mechanized complexity lower bounds beyond circuit complexity.

---

## Building on Existing Verified Theorems

Do not cite catalog theorems decoratively. Use them as conceptual templates.

1. `incompressible_strings_lower_bound`
   - Use this as a model for **counting/incompressibility arguments** in width or proof-size lower bounds.
   - Vision: derive a contradiction by showing that a short proof would encode too much combinatorial information too efficiently.
   - Even if not used directly, mimic its style for “short proof implies compressed witness structure.”

2. `source_coding_lower_bound`
   - This is a natural bridge to an **entropy view of proof search**.
   - A clause of width `w` excludes only a certain fraction of assignments; many clauses are needed unless width grows.
   - Formalize a counting/entropy lemma: bounded-width clauses have bounded information content over partial matchings/injections.

3. `density_exponential_bound`
   - This suggests a reusable pattern for proving exponential lower bounds from layered combinatorial growth constraints.
   - Adapt the “density cannot decay too fast without exponential resource” logic to proof DAGs.

4. `spectral_gap_lower_bound`
   - Cross-domain opportunity: use expansion or boundary growth on the pigeonhole incidence graph as a combinatorial engine for width lower bounds.
   - Even if the final proof is not spectral, the expansion mindset is powerful.

5. `theorem_discovery`
   - Use this as license to define hardness measures and search for the strongest formally tractable invariant, not just the classical one.

---

## Proof Strategy Architecture

### Strategy A: Width-first route via partial assignments
Most promising.

1. Define a notion of **critical partial assignment** or **matching-compatible restriction** for PHP.
2. Show that every clause of width `< n` is satisfiable by some partial injection extending to a full satisfying assignment of all clauses it mentions locally.
3. Conclude that any refutation must contain a clause of width at least `n` (or a linear lower bound).
4. Prove a width-to-size theorem for your proof model.
5. Deduce exponential lower bound.

Why this is most promising:
- It is finitary and combinatorial.
- It avoids deep metamathematics.
- It aligns naturally with Lean’s strengths in finite sets, counting, and induction on proof objects.

### Strategy B: Compression / information-theoretic lower bound
Potentially more original.

1. Associate to each short resolution refutation a compact encoding of a large family of bad assignments or restrictions.
2. Show, using `incompressible_strings_lower_bound` and/or `source_coding_lower_bound`, that such an encoding would violate incompressibility or entropy bounds.
3. Deduce exponential lower bound on proof size directly, or at least a lower bound on number of distinct intermediate clauses.

Why this matters:
- If successful, this creates a new formal bridge between proof complexity and information theory.
- It would be much more conceptually novel than a direct textbook formalization.

Risk:
- Harder to set up cleanly in Lean.
- Better as a second-wave theorem after width infrastructure exists.

### Strategy C: Expansion / boundary growth route
Ambitious and cross-domain.

1. View PHP clauses/variables as a bipartite incidence structure.
2. Prove an expansion lemma saying small-width clauses cannot “cover” enough of the assignment space or matching space.
3. Translate boundary growth into required derivation complexity.

Why this is exciting:
- Connects proof complexity to expander methods and spectral reasoning.
- Could generalize beyond PHP to Tseitin contradictions and random CNFs.

Risk:
- More abstraction, more setup.
- Best pursued after Strategy A yields baseline infrastructure.

Recommendation: **Start with Strategy A**, then use Strategy B or C for a stronger or more original second theorem.

---

## Cross-Domain Connections You Must Exploit

### 1. Information theory
Interpret clauses as information filters on assignments. A bounded-width clause reveals limited information; a refutation must accumulate enough information to rule out all assignments. This is where `source_coding_lower_bound` can inspire a formal theorem.

Potential theorem direction:
```lean
theorem bounded_width_clause_assignment_fraction
  {ν : Type} [Fintype ν] [DecidableEq ν]
  (C : Clause ν) :
  assignmentFractionFalsifying C = 2 ^ (- C.width)
```
or an inequality version. This is a clean bridge between proof complexity and entropy.

### 2. Compression / Kolmogorov-style lower bounds
A short proof should correspond to a short description of some hard combinatorial object. If the object is incompressible, the proof cannot be short. This is speculative but exactly the kind of bold bridge that can open a field.

### 3. Graph expansion and spectral methods
The pigeonhole principle is fundamentally about injective maps into smaller sets. Expansion and boundary growth may certify why local clauses cannot globally refute without broad width.

### 4. SAT solver performance
Resolution models clause learning in restricted forms. Width and proof size are proxies for practical hardness.

You should formalize at least one theorem of the form:
```lean
theorem small_width_refutation_implies_small_search_space ...
```
or
```lean
theorem no_small_resolution_refutation_of_php :
  solverHardnessProxy (phpCNF (n+1) n) ≥ n
```

Even if the solver proxy is a new definition, make it mathematically meaningful: e.g. minimal width, minimal learned-clause width, or a branching lower bound under DPLL-like restrictions.

---

## Concrete Lean 4 Theorem Statements to Target

### Foundational semantics
```lean
theorem clause_monotone
  {ν : Type} [DecidableEq ν] {τ : ν → Bool} {C D : Clause ν} :
  C ⊆ D → Clause.Satisfied τ C → Clause.Satisfied τ D
```

```lean
theorem resolution_step_sound
  {ν : Type} [DecidableEq ν]
  (τ : ν → Bool) (x : ν) (C D : Clause ν) :
  Clause.Satisfied τ (insert (Lit.pos x) C) →
  Clause.Satisfied τ (insert (Lit.neg x) D) →
  Clause.Satisfied τ (C ∪ D)
```

```lean
theorem resolution_sound
  {ν : Type} [DecidableEq ν] (F : CNF ν) (C : Clause ν) :
  ResDerives F C →
  ∀ τ, CNF.Satisfied τ F → Clause.Satisfied τ C
```

### PHP encoding
```lean
theorem php_unsat (n : ℕ) :
  ¬ ∃ τ : PHPVar (n+1) n → Bool, CNF.Satisfied τ (phpCNF (n+1) n)
```

### Width lower bound
```lean
theorem php_clause_small_width_extendable
  (n : ℕ) :
  ∀ C : Clause (PHPVar (n+1) n),
    C.width < n →
    ∃ τ : PHPVar (n+1) n → Bool,
      CNF.Satisfied τ (phpCNF (n+1) n \ {C}) ∧
      ¬ Clause.Satisfied τ C
```

This is a strong and useful intermediate theorem: any narrow clause is not yet globally contradictory relative to PHP structure.

```lean
theorem php_resolution_width_lb (n : ℕ) :
  ∀ π : ResProof (phpCNF (n+1) n) ∅, n ≤ π.width
```

### Size lower bound
```lean
theorem php_resolution_exp_lb (n : ℕ) :
  ∀ π : ResProof (phpCNF (n+1) n) ∅,
    2 ^ (n / 8) ≤ π.size
```

### Cutting planes
```lean
theorem php_has_short_cp_refutation (n : ℕ) :
  ∃ π : CPProof (phpCPConstraints (n+1) n) FalseConstraint,
    π.size ≤ (n+1)^3 + 10
```

### Separation
```lean
theorem cp_vs_resolution_separation_php (n : ℕ) :
  (∃ π : CPProof (phpCPConstraints (n+1) n) FalseConstraint,
      π.size ≤ (n+1)^3 + 10) ∧
  (∀ ρ : ResProof (phpCNF (n+1) n) ∅,
      2 ^ (n / 8) ≤ ρ.size)
```

### SAT hardness proxy
Define:
```lean
def resolutionHardness (F : CNF ν) : ℕ := infimum proof width or size ...
```

Then:
```lean
theorem php_resolution_hardness_linear (n : ℕ) :
  n ≤ resolutionHardness (phpCNF (n+1) n)
```

This gives a mathematically clean connection to SAT performance.

---

## Suggested File Architecture

Create a coherent theory, not scattered lemmas:

- `Computation/ProofComplexity/Resolution/Basic.lean`
- `Computation/ProofComplexity/Resolution/Soundness.lean`
- `Computation/ProofComplexity/Resolution/Width.lean`
- `Computation/ProofComplexity/Examples/PHP.lean`
- `Computation/ProofComplexity/CuttingPlanes/Basic.lean`
- `Computation/ProofComplexity/CuttingPlanes/PHP.lean`
- `Computation/ProofComplexity/Separations/ResolutionVsCP.lean`
- `Computation/ProofComplexity/SATHardness.lean`

If a full Haken formalization is too large, make `Width.lean` and `PHP.lean` independently publishable in style.

---

## Experimental / Discovery Layer

You are explicitly authorized to discover new hardness measures.

Possible definitions to test:
- minimal clause width in any refutation,
- number of distinct variable supports touched by a proof,
- entropy deficit of a proof,
- restriction-resilience of a CNF,
- solver branching hardness under DPLL.

Try to prove equivalences or inequalities between them. Even one theorem of the form
```lean
requiredWidth F ≤ solverBranchingHardness F + 1
```
would be a deep bridge to algorithms.

---

## What to Avoid

- Do not stop at mere syntax of resolution without a quantitative theorem.
- Do not produce only unsatisfiability of PHP; that is classical and easy.
- Do not make “SAT solver connection” a vague comment. State and prove at least one hardness-proxy theorem.
- Do not overfit to one encoding if it obscures the invariant. Build abstractions reusable for Tseitin formulas later.

---

## Application Keywords

proof complexity, resolution, cutting planes, pigeonhole principle, Haken theorem, width lower bounds, exponential lower bounds, SAT solving, CDCL, DPLL, combinatorial hardness, entropy method, incompressibility, graph expansion, certified complexity, formalized lower bounds, propositional proof systems, Lean 4, Mathlib

---

## Deliverables

Required:
- Lean 4 files with definitions and proofs
- at least one non-trivial lower-bound theorem beyond soundness/unsatisfiability
- `FUTURE_DIRECTIONS.md`

Strongly encouraged:
- `ARTICLE.md` explaining the formal proof architecture
- `RESEARCH_PAPER.md` with theorem statements and proof sketches
- a small experiment script comparing formula size/width statistics on PHP instances

---

## FUTURE_DIRECTIONS.md Requirements

You must produce a structured `FUTURE_DIRECTIONS.md` with **3–5 concrete breakthrough next steps**, each containing:
1. an exact theorem statement,
2. a proof strategy,
3. required new definitions,
4. cross-domain significance.

At least one next step must target **Tseitin contradictions or random CNFs**.
At least one must target a stronger proof system such as **polynomial calculus or bounded-depth Frege**.
At least one must target a direct theorem about **CDCL or DPLL performance** derived from the formal proof-complexity framework.

The next cycle should feel inevitable from the work you complete here.

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

Research domain: Computation
Research mode: prove
