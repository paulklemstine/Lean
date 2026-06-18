Soli Deo Gloria

## Assignment: Direction 1: Bounded Quantifier Extension and Verified Hrushovski Stabilizers

**Mode:** prove

Prove genuinely new, non-trivial theorems in Lean 4, building directly on the pseudofinite transfer infrastructure in:

- `Catalog/Algebra/PseudofiniteTransfer.lean`

especially the certified building blocks

- `los_exists_bounded`
- `los_restrictedFormula`
- `mem_ultraSet_iff_eventually`

Your goal is not a cosmetic extension of syntax. Your goal is to create the first formal bridge from inductive Łoś transfer to the stabilizer language that underlies Hrushovski’s approximate subgroup theory. If successful, this opens a route from ultraproduct model theory to **quantitative geometric group theory**, and eventually to a verified architecture for approximate groups, finite tripling, and model-theoretic structure theorems.

The breakthrough target is this: **extend the restricted first-order language by bounded quantifiers over definable sets, prove an inductive Łoś theorem for the extended language, and use it to formalize a transfer-ready stabilizer predicate expressive enough to encode the first Hrushovski-style “definable subgroup controls a large part of A” statement.**

This is not merely syntax engineering. It is the moment where formal model theory becomes expressive enough to talk about the objects geometric group theorists actually use.

---

## Core Mathematical Objective

### New language feature
Introduce an extension of the existing restricted formula language by bounded quantifiers of the form

- `∃ x ∈ D, φ(x)`
- `∀ x ∈ D, φ(x)`

where `D` is a definable set in the ambient structure.

The key conceptual theorem is that **bounded quantification over definable sets is not an extra semantic primitive**: it is reducible to the unbounded case together with definable membership, and therefore should inherit Łoś transfer.

---

## Precise theorem statements to formalize

You should introduce at least one genuinely new definition not already in the catalog. A natural choice is an extended syntax and/or a definable bounded formula evaluator.

### 1. Extended syntax and semantics
Define a new formula type, for example:

```lean
inductive BoundedRestrictedFormula (L : FirstOrder.Language) : ℕ → Type
| falsum : BoundedRestrictedFormula L n
| equal : Fin n → Fin n → BoundedRestrictedFormula L n
| rel   : ∀ {k}, L.Relations k → (Fin k → Fin n) → BoundedRestrictedFormula L n
| and   : BoundedRestrictedFormula L n → BoundedRestrictedFormula L n → BoundedRestrictedFormula L n
| or    : BoundedRestrictedFormula L n → BoundedRestrictedFormula L n → BoundedRestrictedFormula L n
| not   : BoundedRestrictedFormula L n → BoundedRestrictedFormula L n
| exists_ : BoundedRestrictedFormula L (n+1) → BoundedRestrictedFormula L n
| forall_ : BoundedRestrictedFormula L (n+1) → BoundedRestrictedFormula L n
| boundedExists :
    DefinableSet L n → BoundedRestrictedFormula L (n+1) → BoundedRestrictedFormula L n
| boundedForall :
    DefinableSet L n → BoundedRestrictedFormula L (n+1) → BoundedRestrictedFormula L n
```

If `DefinableSet` already has a nearby catalog representation, use that instead of inventing a conflicting one; but if no exact notion exists, define it carefully and prove the connection lemmas.

Then define semantics:

```lean
def BoundedRestrictedFormula.Realize
  {L : FirstOrder.Language} {M : Type*} [L.Structure M] :
  BoundedRestrictedFormula L n → (Fin n → M) → Prop
```

with bounded clauses interpreting `x ∈ D` through the realization of the definable set.

### 2. Reduction of bounded quantifiers to unbounded quantifiers
Prove a translation theorem from bounded formulas to ordinary restricted formulas.

A precise target:

```lean
def eraseBounded :
  BoundedRestrictedFormula L n → RestrictedFormula L n

theorem realize_eraseBounded
  {L : FirstOrder.Language} {M : Type*} [L.Structure M]
  (φ : BoundedRestrictedFormula L n) (v : Fin n → M) :
  φ.Realize v ↔ (eraseBounded φ).Realize v
```

This theorem should be deep enough that its proof genuinely uses induction over formula structure, and the bounded quantifier cases should require nontrivial manipulation of definable-set membership.

### 3. Inductive Łoś theorem for bounded formulas
This is the central breakthrough theorem.

A target signature, adapted to the catalog’s actual ultraproduct conventions:

```lean
theorem los_boundedRestrictedFormula
  {L : FirstOrder.Language}
  {ι : Type*} {M : ι → Type*}
  [∀ i, L.Structure (M i)]
  (U : Filter ι) [U.IsUltra]
  (φ : BoundedRestrictedFormula L n)
  (a : Fin n → Ultraproduct M U) :
  φ.Realize a ↔ Filter.Eventually U (fun i => φ.Realize (fun j => Representative (a j) i))
```

You will need to adapt names like `Ultraproduct`, `Representative`, and `IsUltra` to the catalog’s exact API. The theorem statement must be exact in your file, even if this sketch needs syntactic adjustment.

This theorem should be proved by induction on `φ`, with the bounded existential case using `los_exists_bounded` and the bounded universal case reduced either by direct argument or by duality through negation.

### 4. Transfer of a stabilizer-style definable subgroup predicate
Define a formal predicate expressing a first-order approximation to:

> “There exists a definable subgroup `H ≤ G` such that `[A : A ∩ H] ≤ C`.”

Because literal subgroup indices may not be directly first-order, begin with a bounded finite-cover proxy that is expressible and transfer-ready.

For example, define a predicate saying:

> there exist elements `g₁, …, g_C` such that every `a ∈ A` lies in some `g_j * H`, and `H` is closed under multiplication and inverse on a bounded ambient domain.

This is already the language of approximate stabilizers.

A Lean-facing target could look like:

```lean
def CoversByLeftCosets
  (A H : DefinableSet GroupLanguage 1) (C : ℕ) : Prop := ...
```

and then prove a transfer theorem:

```lean
theorem los_stabilizer_cover
  {C : ℕ}
  (A H : DefinableSet GroupLanguage 1)
  (hφ : StabilizerCoverFormula A H C) :
  HoldsInUltraproduct hφ ↔ Filter.Eventually U (fun i => HoldsInFactor (hφ) i)
```

Again, adapt exact APIs to the catalog. The point is to produce a **verified algorithmic transfer principle for a genuine Hrushovski-style bounded-cover statement**, not merely a syntax theorem.

### 5. Cross-domain theorem: model theory ↔ geometric group theory
Prove at least one theorem that explicitly connects definability transfer to a group-combinatorial invariant.

For example:

```lean
theorem bounded_cover_implies_small_doubling_proxy
  {G : Type*} [Group G]
  (A H : Set G) (C : ℕ)
  (hcov : CoversByLeftCosets A H C)
  (hH : IsApproxSubgroupProxy H) :
  SmallDoublingProxy A (f C)
```

This need not be the sharpest theorem. What matters is that you connect **first-order definability machinery** to a **group growth / combinatorial covering consequence**. This is the cross-domain bridge: model theory ↔ geometric group theory, with possible spillover to additive combinatorics.

---

## Why this would be a breakthrough

Hrushovski’s stabilizer method is one of the great conceptual machines of modern mathematics: it turns combinatorial regularity into algebraic structure using model theory. But formal libraries typically stop at generic Łoś transfer and never reach the language of stabilizers, coset covers, and approximate subgroups. Extending the language by bounded quantifiers is exactly the missing move.

If you succeed, you create:

- the first verified syntax/semantics layer capable of expressing **definable bounded search** in ultraproduct arguments;
- a formal gateway from **pseudofinite transfer** to **approximate group structure theory**;
- infrastructure for future formalizations of:
  - Hrushovski stabilizer theorems,
  - Breuillard–Green–Tao style approximate subgroup classification,
  - pseudofinite dimension arguments,
  - definable amenability and NIP-flavored transfer statements.

This is field-opening because it changes what kinds of modern model-theoretic mathematics can be formalized at all.

---

## Proof architecture: 3 viable strategies

### Strategy A: Primitive bounded syntax + direct inductive Łoś proof
1. Define `BoundedRestrictedFormula` with `boundedExists` and `boundedForall`.
2. Define semantics directly.
3. Prove `los_boundedRestrictedFormula` by induction on formulas.
4. In the bounded existential case, invoke `los_exists_bounded`.
5. In the bounded universal case, either argue directly via eventual universal satisfaction or reduce to existential failure using negation.

**Why promising:** This is the most faithful to the conjecture and gives the cleanest final API. It also produces the strongest induction principle for future stabilizer arguments.

**Risk:** The bounded universal case may become technically unpleasant unless negation and definable complements are set up cleanly.

### Strategy B: Desugar bounded quantifiers into ordinary restricted formulas
1. Define a translation `eraseBounded`.
2. Prove semantics preservation `realize_eraseBounded`.
3. Deduce `los_boundedRestrictedFormula` immediately from `los_restrictedFormula`.
4. Use bounded syntax only as ergonomic sugar for writing stabilizer statements.

**Why promising:** This is probably the most robust route in Lean. It minimizes semantic duplication and uses the catalog’s existing induction engine.

**Most promising overall:** **Strategy B**. It exploits certified infrastructure instead of rebuilding it, and the semantics-preservation theorem is mathematically illuminating: bounded quantification over definable sets is not new logical power, but a disciplined notational layer over ordinary first-order logic.

### Strategy C: Definable-set algebra first, syntax second
1. Build an API for definable sets under Boolean operations and fiber/projection operations.
2. Show bounded existential quantification corresponds to projection of a definable subset.
3. Reconstruct bounded formula semantics from definable-set closure properties.
4. Derive Łoś from transfer of definable-set membership.

**Why interesting:** This aligns more closely with geometric model theory, where formulas and definable sets are dual views of the same object.

**Risk:** More elegant mathematically, but likely heavier than necessary for the current cycle.

---

## Key technical lemmas you should target

These are not optional niceties; they are the spine of the development.

1. **Definable membership transfer**
   ```lean
   theorem los_mem_definableSet ...
   ```
   using `mem_ultraSet_iff_eventually`.

2. **Bounded existential realization equivalence**
   ```lean
   theorem realize_boundedExists_iff
     (D : DefinableSet L n) (φ : BoundedRestrictedFormula L (n+1)) (v : Fin n → M) :
     (BoundedRestrictedFormula.boundedExists D φ).Realize v
       ↔ ∃ x, x ∈ D.Realize v ∧ φ.Realize (Fin.snoc v x)
   ```

3. **Bounded universal via complement**
   ```lean
   theorem realize_boundedForall_iff_not_exists_not ...
   ```

4. **Translation correctness**
   ```lean
   theorem realize_eraseBounded ...
   ```

5. **Łoś for bounded formulas**
   ```lean
   theorem los_boundedRestrictedFormula ...
   ```

6. **Transfer-ready stabilizer cover formula**
   ```lean
   theorem los_stabilizer_cover ...
   ```

At least 3 of your theorems must require real proof structure: induction on formulas, `rcases` for existential witnesses, `by_contra` for universal/failure arguments, and multi-step `calc` chains for semantic equivalences.

---

## New definitions to introduce

You must define at least one novel mathematical structure or concept absent from the catalog. Strong candidates:

- `BoundedRestrictedFormula`
- `DefinableSet`
- `StabilizerCoverFormula`
- `CoversByLeftCosets`
- `ApproximateSubgroupProxy`
- `BoundedlyDefinableSubgroup`

A particularly powerful new concept would be:

```lean
structure BoundedlyDefinableSubgroup (G : Type*) [Group G] where
  carrier : DefinableSet GroupLanguage 1
  one_mem : ...
  mul_mem : ...
  inv_mem : ...
  domain_bound : DefinableSet GroupLanguage 1
```

This lets you formalize “subgroup-like” objects inside a bounded logical language, which is exactly the right intermediate object before full subgroup transfer.

---

## Cross-domain connections to make explicit

This project must include at least one theorem and surrounding exposition connecting model theory to another field. You already have the natural bridge:

- **Model theory ↔ geometric group theory**

But push further. Explicitly mention and, if possible, lightly formalize one of these connections:

- **Model theory ↔ additive combinatorics**: bounded coset covers as a proxy for small doubling and approximate algebraic structure.
- **Model theory ↔ descriptive complexity**: bounded quantifiers correspond to controlled witness search, suggesting a complexity-sensitive hierarchy of transfer principles.
- **Model theory ↔ topological dynamics**: definable stabilizers foreshadow definable compactifications and amenability phenomena.
- **Model theory ↔ information theory**: bounded witness extraction resembles constrained decoding; definable concentration statements could become transfer principles for entropy-like invariants.

A good theorem here would show that a definable bounded-cover statement yields a finite combinatorial covering bound in each component structure after transfer.

---

## Conjecture with falsifiable computational test

You must state at least one falsifiable conjecture and provide a computational test that could disprove it.

### Conjecture
For every fixed bounded formula complexity `k` and cover parameter `C`, there exists a uniform translation size bound `f(k, C)` such that every bounded stabilizer-cover formula of complexity at most `k` is equivalent to an ordinary restricted formula of size at most `f(k, C)`.

This predicts a **controlled blowup theorem** for bounded quantifier elimination into the restricted language.

### Testable prediction
Implement a procedure that:
1. randomly generates bounded formulas up to complexity `k`,
2. translates them via `eraseBounded`,
3. measures formula size growth,
4. searches for counterexamples to candidate bounds `f(k,C)`.

A disproof would be immediate if the observed translated size exceeds the conjectured bound.

A second, more group-theoretic conjecture:

### Conjecture
Any definable bounded-cover witness for a symmetric set `A` in finite groups of uniformly bounded tripling produces, in ultraproduct, a boundedly definable subgroup proxy whose pullback covers `A` by `O_C(1)` cosets.

### Test
Use `demo.py` to generate finite groups (e.g. matrix groups over small fields or permutation groups), sample symmetric subsets with small tripling, and search algorithmically for bounded-cover witnesses matching the formal predicate. Failure on a family would refute an overly optimistic uniform statement.

---

## Algorithmic deliverable

You must produce a **verified algorithm or computational method**, not just theorem statements.

Required target:

### Verified translator and evaluator
Implement a Lean function that compiles bounded formulas into ordinary restricted formulas:

```lean
def compileBounded :
  BoundedRestrictedFormula L n → RestrictedFormula L n
```

and prove:

```lean
theorem compileBounded_correct
  (φ : BoundedRestrictedFormula L n) (v : Fin n → M) :
  φ.Realize v ↔ (compileBounded φ).Realize v
```

Then expose a computational evaluator for small finite structures, and connect it to Python in `demo.py`.

This is scientifically important: it turns the theorem into an executable bridge from syntax with bounded quantifiers to transfer-certified ordinary formulas.

---

## Demo requirements

Your `demo.py` should do something mathematically meaningful, not merely print theorem names. At minimum:

1. Build small finite group examples.
2. Encode sample bounded formulas representing:
   - bounded existential membership,
   - bounded universal closure,
   - a stabilizer-cover proxy.
3. Compile them to ordinary restricted formulas.
4. Evaluate both versions on sample structures and verify agreement.
5. Experimentally test the conjectured translation-size growth and/or bounded-cover transfer patterns.

A compelling demo would visualize:
- formula size before/after compilation,
- witness extraction frequency,
- small-group examples where stabilizer-cover predicates hold or fail.

---

## Application keywords

Model theory; ultraproducts; Łoś theorem; bounded quantifiers; definable sets; pseudofinite methods; approximate groups; Hrushovski stabilizer; geometric group theory; additive combinatorics; finite cover properties; definable subgroup proxies; quantifier compilation; witness extraction; transfer principles; structural algebra.

---

## Concrete file-level expectations

Create a new Lean file, ideally adjacent to the catalog infrastructure, such as:

- `Catalog/Algebra/BoundedPseudofiniteTransfer.lean`
or
- `Catalog/ModelTheory/BoundedRestrictedFormula.lean`

and import the exact catalog files needed from `PseudofiniteTransfer`.

Your file must contain:
- at least one new inductive type or structure,
- at least 3 substantial theorem proofs,
- minimal `sorry`,
- one cross-domain theorem,
- one explicit conjecture in comments or markdown with a computational refutation protocol.

---

## Mandatory deliverables

You must produce **all** of the following:

### 1. `FUTURE_DIRECTIONS.md`
Provide 3–5 original research directions unlocked by this work.  
Each direction must include the exact sentences:

- **“The key insight is...”**
- **“Why now?”**

At least one direction must bridge to a different domain beyond model theory and group theory.

Strong candidate directions:
- pseudofinite dimension and stabilizer rank bounds,
- verified approximate subgroup classification in special families,
- bounded quantifier transfer for NIP-style combinatorics,
- definable entropy or complexity invariants,
- applications to expander obstructions or growth in finite simple groups.

### 2. `RESEARCH_PAPER.md`
A standalone scientific paper explaining:
- the new bounded language,
- the translation or direct Łoś theorem,
- the stabilizer-cover formalization,
- why this matters for Hrushovski’s program,
- the cross-domain implications,
- precise future conjectures.

A reader with no access to code must still understand the mathematics and significance.

### 3. `ARTICLE.md`
Write in **Scientific American style**:
- engaging,
- concept-driven,
- broad-audience accessible.

Do **not** focus on formal verification machinery. Focus on the ideas: bounded search, hidden algebraic structure, and why stabilizers emerge from combinatorial chaos.

### 4. Verified algorithm / computational method
Implement the bounded-formula compiler and prove it correct.

### 5. `demo.py`
Provide an interactive demonstration of:
- bounded formula compilation,
- semantic agreement on finite examples,
- exploratory tests of the conjecture.

---

## Final call to action

Do not stop at “bounded quantifiers can be added.” That is only the entry point. The true target is to make the language of stabilizers **transferable**. If you can express and transfer even a first nontrivial bounded-cover subgroup proxy, you will have created the formal seed of Hrushovski’s method inside Lean.

This is how one opens a field: not by polishing a theorem already in reach, but by building the exact logical instrument that lets an entire class of modern arguments become formalizable for the first time.

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
- **Visualization scripts** — Produce up to 3 self-contained Python scripts
  that visually illustrate the core mathematical concepts discovered. Use
  matplotlib for static plots (heatmaps, curves, surfaces) or plotly for
  interactive charts. Available libraries: numpy, matplotlib, plotly.
  If using matplotlib, the script must call plt.savefig() — the system
  captures the output as a PNG. If using plotly, assign the figure to a
  variable named `fig` — the system captures fig.to_html(). Each script
  must include a comment header explaining what it visualizes and why.
  **CRITICAL: Each visualization script MUST be a single, fully self-contained
  file. Do NOT import from any local modules (algorithms.py, demo.py, etc.).
  Instead, inline all needed functions and classes directly in the script.
  The browser runtime (Pyodide) has no access to local .py files.**
- **Interactive HTML demos** — Produce up to 3 self-contained HTML snippets
  (with inline CSS/JS, no external dependencies) that demonstrate the
  mathematical concepts interactively — sliders, animations, dynamic SVG,
  or canvas drawing. Each demo must be a complete <div> fragment that
  works when inserted into a page. No <html>, <head>, or <body> tags —
  just the content div with its inline styles and scripts.

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
    "visualizations": [ { "name": "...", "code": "# Must be 100% self-contained. Do not import local files. Inline all needed functions directly.", "description": "What this visualizes" } ],
    "interactive_demos": [ { "name": "...", "html": "<div>...</div>", "description": "What this demonstrates" } ],
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
