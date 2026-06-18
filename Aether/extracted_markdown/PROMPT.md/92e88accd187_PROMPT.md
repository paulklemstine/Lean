## Assignment: Direction 4: Certified Tropical Polynomial Normal Form

**Mode:** prove

Prove a genuinely foundational theorem: tropical polynomial syntax admits a certified canonical normal form, and equality of the induced tropical functions is decidable through that normal form after removing inessential monomials. This is not just a cleanup lemma about syntax. It is the algebraic compiler theorem for tropical mathematics in Lean: every tropical expression can be reduced to a Newton-polytope-level certificate, and semantic equality becomes a finite combinatorial statement.

This would open a formal bridge between:
- tropical algebra and convex geometry,
- symbolic normalization and certified optimization,
- tropical circuit equivalence and mechanized complexity theory,
- Newton polytope semantics and explainable ML models in min-plus form.

### Exact Target

Work with tropical polynomials in `n` variables over `ℝ`, interpreted as finite pointwise infima of affine forms
\[
x \mapsto c + \sum_{i=1}^n w_i x_i
\qquad\text{with } c \in \mathbb R,\; w_i \in \mathbb N.
\]
A canonical normal form should be a finite set of monomials, but **not merely the expanded support**: completeness at the semantic level requires quotienting out dominated monomials. The right canonical object is the set of lower-envelope vertices of the lifted Newton polytope.

### Core Definitions to Introduce

You should define a syntactic tropical expression type, for fixed `n : ℕ`, with constants, variables, tropical addition (`min`), and tropical multiplication (`+` classically, i.e. affine addition of exponents). A minimal skeleton:

```lean
inductive TropExpr (n : ℕ) where
  | const : ℝ → TropExpr n
  | var   : Fin n → TropExpr n
  | add   : TropExpr n → TropExpr n → TropExpr n   -- tropical addition = min
  | mul   : TropExpr n → TropExpr n → TropExpr n   -- tropical multiplication = +
deriving DecidableEq
```

Monomials and normal forms:

```lean
abbrev TropMonom (n : ℕ) := ℝ × (Fin n → ℕ)
abbrev TropPolyNF (n : ℕ) := Finset (TropMonom n)
```

Evaluation of a monomial and normal form:

```lean
def evalMonom {n : ℕ} (m : TropMonom n) (x : Fin n → ℝ) : ℝ :=
  m.1 + ∑ i, ((m.2 i : ℝ) * x i)

def evalNF {n : ℕ} (s : TropPolyNF n) (x : Fin n → ℝ) : ℝ :=
  s.inf' (by
    -- nonemptiness hypothesis or use Option/WithTop variant for zero polynomial design
  ) (fun m => evalMonom m x)
```

If handling the empty normal form is awkward, either:
1. restrict to nonempty tropical expressions and nonempty normal forms, or
2. represent evaluation in `WithTop ℝ`, where the empty infimum is `⊤`, or
3. add a distinguished `∞` constant to syntax.

A normalization function should first expand distributivity, then collect duplicate exponent vectors by retaining the smallest coefficient, then remove dominated monomials.

### Precise Theorem Statement

There are really **three theorem layers**, and the breakthrough is to complete all three.

#### Theorem A: Sound normalization
Every expression normalizes to a finite tropical polynomial with identical semantics.

Suggested Lean shape:

```lean
def normalize : TropExpr n → TropPolyNF n

theorem normalize_sound {n : ℕ} :
  ∀ (e : TropExpr n) (x : Fin n → ℝ),
    evalNF (normalize e) x = evalExpr e x
```

where `evalExpr` is the recursive semantics of `TropExpr`.

#### Theorem B: Algebraic completeness up to semantic reduction
Raw expanded support is not complete semantically, because distinct supports can define the same lower envelope. So define a canonical reduction:

```lean
def essentialize : TropPolyNF n → TropPolyNF n
```

such that `essentialize s` removes exactly those monomials never attaining the infimum at any point. Then prove:

```lean
theorem essentialize_sound {n : ℕ} :
  ∀ (s : TropPolyNF n) (x : Fin n → ℝ),
    evalNF (essentialize s) x = evalNF s x
```

and the key completeness theorem:

```lean
theorem essentialize_complete {n : ℕ} :
  ∀ {s t : TropPolyNF n},
    (∀ x : Fin n → ℝ, evalNF s x = evalNF t x) →
    essentialize s = essentialize t
```

This is the real theorem. It says tropical polynomial functions over `ℝ` have unique reduced Newton representation.

#### Theorem C: Canonical semantic normal form for syntax
Combine the two:

```lean
theorem normalize_complete {n : ℕ} :
  ∀ {e₁ e₂ : TropExpr n},
    (∀ x : Fin n → ℝ, evalExpr e₁ x = evalExpr e₂ x) →
    essentialize (normalize e₁) = essentialize (normalize e₂)
```

This is the certified decision principle for tropical expression equivalence.

---

## Why this is a breakthrough

This is the tropical analogue of a Gröbner-normal-form theorem, but with a convex-geometric semantic quotient built in. It would give Lean a machine-checkable equivalence engine for min-plus expressions and make the Newton polytope—not syntax—the certified invariant of meaning.

It opens:
- certified simplifiers for tropical optimization pipelines,
- formal equivalence checking for tropical neural networks and dynamic programs,
- semantic compression of min-plus circuits,
- a route to tropical proof-carrying code,
- formal convex-geometric semantics for algebraic ML.

This is especially powerful because the catalog already contains evidence that semantic profiles can be complete invariants in bounded settings: build conceptually on  
`tropical_profile_complete_for_bounded_architecture_congruence`
from `Bridges/AlgebraMachineLearning/OperadicTropicalization.lean`.  
That theorem suggests a pattern: bounded architecture semantics can admit complete profile invariants. Here the ambition is stronger: a complete invariant for **all** tropical polynomial expressions in fixed finite arity.

---

## Lean 4 Formalization Targets

A realistic formal progression is:

1. Define `TropExpr`, `evalExpr`, `TropMonom`, `evalMonom`, `evalNF`.
2. Define a raw expansion:
   ```lean
   def expand : TropExpr n → TropPolyNF n
   ```
   where tropical `add` becomes union and tropical `mul` becomes Minkowski-style addition of exponent vectors plus coefficient addition.
3. Define coefficient minimization on equal exponent vectors:
   ```lean
   def collect : TropPolyNF n → TropPolyNF n
   ```
4. Define semantic reduction:
   ```lean
   def dominated (s : TropPolyNF n) (m : TropMonom n) : Prop :=
     ∀ x, evalNF s x < evalMonom m x
     -- or ≤ with strict witness elsewhere; tune carefully
   ```

   Better: define `m` inessential if removing it preserves evaluation everywhere:
   ```lean
   def inessential (s : TropPolyNF n) (m : TropMonom n) : Prop :=
     ∀ x, evalNF (s.erase m) x = evalNF s x
   ```

   Then:
   ```lean
   def essentialize (s : TropPolyNF n) : TropPolyNF n :=
     s.filter (fun m => ¬ inessential s m)
   ```
   If decidability of `inessential` is too hard directly, first prove existence/uniqueness abstractly, then later derive an algorithmic criterion via convex geometry.

5. Set
   ```lean
   def normalize (e : TropExpr n) : TropPolyNF n := essentialize (collect (expand e))
   ```

---

## Proof Strategy Paths

### Strategy A: Direct semiring-normalization + geometric essentialization
This is the most balanced and likely the best first route.

**Step 1.** Prove expansion soundness by structural recursion on syntax:
- `const c` expands to singleton `(c, 0)`;
- `var i` expands to singleton `(0, e_i)`;
- `add` expands to union;
- `mul` expands to pairwise monomial addition.

Then show:
```lean
theorem expand_sound :
  ∀ e x, evalNF (expand e) x = evalExpr e x
```

**Step 2.** Prove `collect` is semantics-preserving:
if two monomials have the same exponent vector, only the smallest coefficient matters under infimum. This is a clean finite combinatorial lemma.

**Step 3.** Prove essentialization completeness:
a monomial is essential iff it attains the lower envelope somewhere. Then prove two reduced supports defining the same function must coincide. This is where convex separation enters: if an affine form is in one reduced set but not the other, there exists `x` where it is uniquely active or at least strictly needed, contradicting equality of functions.

Why promising: it modularizes the hard part into a single geometric uniqueness theorem.

---

### Strategy B: Legendre–Fenchel / convex duality route
This is conceptually deeper and could yield the strongest theorem.

Interpret a tropical polynomial
\[
f(x)=\min_{w \in S}(c_w+\langle w,x\rangle)
\]
as a polyhedral concave/convex object (depending on sign convention). The reduced support is exactly the set of affine pieces appearing in the lower envelope, equivalently the set recovered from the conjugate/epigraph geometry.

**Step 1.** Formalize the lower-envelope function from a finite set of affine forms.

**Step 2.** Show the essential monomials are precisely those defining exposed faces of the lifted Newton polytope:
\[
\operatorname{conv}\{(w,c_w)\} \subset \mathbb R^n \times \mathbb R.
\]

**Step 3.** Prove equality of functions implies equality of exposed lower hulls, hence equality of reduced supports.

Why revolutionary: this connects tropical normalization to certified convex duality and opens the door to tropical Fenchel transforms in Lean.  
Why harder: Mathlib convex geometry support may help, but formalizing exactly the lower-hull extraction may be substantial.

---

### Strategy C: Piecewise-linear region decomposition
This route is algorithmic and may be ideal if you want a decision procedure.

**Step 1.** For a finite support `s`, define the region where monomial `m` is active:
\[
R_m = \{x : \forall m' \in s,\; evalMonom\ m\ x \le evalMonom\ m'\ x\}.
\]

**Step 2.** Show `m` is essential iff `R_m` is nonempty.

**Step 3.** Prove if two reduced supports induce the same function, then each active region from one support must correspond to the same affine piece in the other, forcing equality of monomials.

Why promising: it avoids heavier convex-hull machinery and stays close to finite linear inequalities.  
Why delicate: you need a lemma that two affine forms equal on a set with enough spread implies coefficient and exponent equality. Over `ℝ^n`, this is true and should be provable by testing basis vectors and `0`.

---

## Most Promising Route

**Strategy A with a Strategy C-style completeness lemma** is probably the optimal first attack.

Reason:
- structural normalization is straightforward in Lean;
- duplicate collection is finite and algebraic;
- completeness can be reduced to a concrete lemma about finite sets of affine forms and active regions, without importing full convex duality;
- later, once the theorem is established, Strategy B can be formalized as the conceptual explanation and used to generalize.

---

## Critical Mathematical Insight: Raw support is not complete

Do **not** try to prove:
> if two finite supports evaluate equally for all `x`, then the supports are equal.

This is false without reduction. Example in one variable:
\[
\min(x, 0, x+1)=\min(x,0),
\]
so the monomial `x+1` is semantically invisible.

Therefore the true theorem must identify the **essential support**, i.e. the set of monomials that occur on the lower envelope somewhere. That is the canonical Newton representation. This correction is the difference between an incremental exercise and a field-opening result.

---

## Key Lemmas You Will Need

1. **Affine equality rigidity**
   ```lean
   theorem affine_eq_of_eval_eq_univ
     {a b : TropMonom n} :
     (∀ x : Fin n → ℝ, evalMonom a x = evalMonom b x) → a = b
   ```
   Proof: evaluate at `0` to get coefficients, then at basis vectors to recover exponents.

2. **Duplicate elimination**
   ```lean
   theorem collect_sound {n : ℕ} :
     ∀ (s : TropPolyNF n) (x : Fin n → ℝ),
       evalNF (collect s) x = evalNF s x
   ```

3. **Essential monomial witness**
   For reduced `s`, every `m ∈ s` has some witness `x` with
   ```lean
   evalNF s x = evalMonom m x
   ```
   and ideally strict inequality against all other monomials if you define a stronger genericity notion.

4. **Reduced uniqueness**
   If `s` and `t` are reduced and define the same function, then every `m ∈ s` belongs to `t`, by witness extraction and affine rigidity.

5. **Finiteness support lemma**
   You may be able to conceptually echo
   `finite_support_of_depth_bounded`
   from `Tropical/GL3SatakeFiniteGen.lean`:
   that theorem suggests a pattern for extracting finite support from bounded combinatorial generation. Here expansion automatically gives finite support from syntax depth; cite it as inspiration for managing finite combinatorial growth.

---

## Cross-Domain Connections

This theorem is not isolated tropical algebra. It has immediate bridges to:

- **Convex geometry:** essential monomials are lower-hull vertices of the lifted Newton polytope.
- **Program equivalence:** tropical expressions are weighted dynamic programs; normal form becomes a certificate of semantic equality.
- **Machine learning:** min-plus linear regions underlie morphological and tropicalized networks; canonical forms enable certified compression and interpretability.
- **Information theory:** tropicalization of variational formulas often yields infima of affine families; canonical lower-envelope extraction parallels extremal representation. The theorem `tropical_kl_pointwise_bound` in `Tropical/InformationTheory/Core.lean` hints at a broader program where tropical functionals are certified via pointwise affine bounds.
- **Logic/circuit complexity:** `bool_and_as_tropical_max` and `tropical_and_bound` show Boolean and oracle behavior can already be encoded tropically. Your normal form theorem would turn these encodings into canonical certificates, potentially enabling lower-bound style arguments through support complexity.
- **Operadic semantics / architecture invariants:** build philosophically on
  `tropical_profile_complete_for_bounded_architecture_congruence`; your result upgrades “profile completeness for bounded architectures” to “canonical semantic normal form for tropical polynomial syntax.”

---

## Suggested Lean Type Signatures

These are aspirational but precise enough to target:

```lean
inductive TropExpr (n : ℕ) where
  | const : ℝ → TropExpr n
  | var   : Fin n → TropExpr n
  | add   : TropExpr n → TropExpr n → TropExpr n
  | mul   : TropExpr n → TropExpr n → TropExpr n
deriving DecidableEq

abbrev TropMonom (n : ℕ) := ℝ × (Fin n → ℕ)
abbrev TropPolyNF (n : ℕ) := Finset (TropMonom n)

def evalExpr : TropExpr n → (Fin n → ℝ) → ℝ
def evalMonom : TropMonom n → (Fin n → ℝ) → ℝ
def evalNF : TropPolyNF n → (Fin n → ℝ) → WithTop ℝ

def expand : TropExpr n → TropPolyNF n
def collect : TropPolyNF n → TropPolyNF n
def essentialize : TropPolyNF n → TropPolyNF n
def normalize : TropExpr n → TropPolyNF n

theorem expand_sound {n : ℕ} :
  ∀ (e : TropExpr n) (x : Fin n → ℝ),
    evalNF (expand e) x = evalExpr e x

theorem collect_sound {n : ℕ} :
  ∀ (s : TropPolyNF n) (x : Fin n → ℝ),
    evalNF (collect s) x = evalNF s x

theorem essentialize_sound {n : ℕ} :
  ∀ (s : TropPolyNF n) (x : Fin n → ℝ),
    evalNF (essentialize s) x = evalNF s x

theorem affine_eq_of_eval_eq_univ {n : ℕ} {m₁ m₂ : TropMonom n} :
  (∀ x : Fin n → ℝ, evalMonom m₁ x = evalMonom m₂ x) → m₁ = m₂

theorem essentialize_complete {n : ℕ} :
  ∀ {s t : TropPolyNF n},
    (∀ x : Fin n → ℝ, evalNF s x = evalNF t x) →
    essentialize s = essentialize t

theorem normalize_sound {n : ℕ} :
  ∀ (e : TropExpr n) (x : Fin n → ℝ),
    evalNF (normalize e) x = evalExpr e x

theorem normalize_complete {n : ℕ} :
  ∀ {e₁ e₂ : TropExpr n},
    (∀ x : Fin n → ℝ, evalExpr e₁ x = evalExpr e₂ x) →
    normalize e₁ = normalize e₂
```

If `normalize_complete` is too strong because `normalize` includes only abstractly-defined `essentialize`, then prove:
```lean
theorem normalize_complete_mod_semantics ...
```
or use `essentialize (expand e)` explicitly.

---

## Implementation Advice

- Use `Fin n → ℕ` rather than `ℕ → ℕ`; finite arity is crucial for recoverability and finite summation.
- Consider `WithTop ℝ` if you want a true empty infimum and a zero tropical polynomial.
- If `Finset.inf'` becomes cumbersome, define normal forms as `Multiset` plus nonemptiness, or package a nonempty finset:
  ```lean
  structure TropPolyNF₊ (n : ℕ) where
    terms : Finset (TropMonom n)
    nonempty : terms.Nonempty
  ```
- Keep “collect duplicate exponents” separate from “remove inessential monomials.”
- Prove semantic lemmas first for arbitrary finite supports, then specialize to normalized syntax.

---

## What to Build on from the Catalog

1. **`tropical_profile_complete_for_bounded_architecture_congruence`**  
   Use it as a conceptual template: semantics can admit complete finite invariants. Your theorem seeks the invariant explicitly as reduced Newton data.

2. **`finite_support_of_depth_bounded`**  
   Use the philosophy of bounded generation implies finite support. Your syntax recursion should give a cleaner finite-support theorem for tropical expressions.

3. **`tropical_kl_pointwise_bound`**  
   The proof style may help: pointwise equality/inequality statements over all inputs can often be turned into certified functional identities. Your normalization theorem is exactly such a global pointwise certification problem.

4. **`bool_and_as_tropical_max`** and **`tropical_and_bound`**  
   These suggest that tropical semantics already serves as a representation language for logical/computational structure. A canonical normal form would upgrade these embeddings into certifiable symbolic normalizers.

---

## Deliverables

1. A new Lean file implementing the syntax, semantics, normalization, and theorems above.
2. Proofs with minimal `sorry`; if one hard convex-geometric lemma remains, isolate it sharply behind the best possible interface.
3. A short module-level docstring explaining why essential support, not raw support, is the correct canonical notion.
4. **A required `FUTURE_DIRECTIONS.md`** with 3–5 concrete next steps at breakthrough scale.

### Required FUTURE_DIRECTIONS.md items
Include specific next projects such as:
1. decision procedure for tropical expression equivalence via polyhedral active-region computation;
2. extension from polynomial to rational tropical expressions / residuated min-plus algebra;
3. canonical normal forms for matrix-valued tropical expressions and weighted automata;
4. tropical Fenchel duality in Lean, recovering normal forms from convex conjugates;
5. complexity bounds on normalized support size, linking tropical circuit size to Newton polytope complexity.

## Application keywords
tropical algebra, Newton polytope, lower hull, canonical normal form, semantic completeness, min-plus circuits, convex geometry, formal verification, program equivalence, tropical machine learning, polyhedral semantics, Lean 4, Mathlib, certified symbolic computation

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
