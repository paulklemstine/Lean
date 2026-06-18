## Assignment: Direction 2: Equality Saturation Extraction Correctness

**Mode:** prove

Prove a genuinely new theorem cluster establishing that equality saturation extraction is a **certified optimization procedure**, not merely a heuristic search over rewrites. The conceptual leap is this:

> move from **normalization as a canonical-choice theorem** to **e-graph extraction as an optimization theorem over quotient semantics**.

The catalog already gives a quotient-normal-form route for convergent rewriting. Your task is to show that equality saturation, when complete for a convergent system, computes the same semantic quotient, and that any cost-guided extractor selecting a representative from each saturated e-class is sound.

This is not just a compiler lemma. It is a bridge theorem between:
- **term rewriting**: confluence, normalization, equivalence generation,
- **quotient semantics**: semantic invariance on `EqvGen`,
- **optimization theory**: extraction as argmin over an equivalence class,
- **automated reasoning / SMT**: e-graphs as finite certificates of equational closure,
- **program synthesis**: cheapest equivalent program extraction.

If successful, this opens a formal theory of **semantic optimization by quotient search**, with immediate extensions to superoptimization, algebraic simplification, and cost-aware synthesis.

---

## Precise theorem target

Build on:

- `Pythagorean/ConvergentRewriteOptimizer.lean`
  - `nf_constant_on_eqvGen`
  - `quotientNf_mk`
  - `eval_eq_of_nf_eq`

The breakthrough theorem should have the following shape:

### New core definitions to introduce

You must define at least one genuinely new structure. Recommended definitions:

1. **Saturated extraction structure**
```lean
structure SaturatedEGraphExtractor
    (α : Type u) [DecidableEq α]
    (R : RewriteSystem α) where
  carrier : Set α
  sameClass : α → α → Prop
  complete_on : Set α
  sound_sameClass :
    ∀ {a b}, sameClass a b → EqvGen R.rel a b
  complete_sameClass :
    ∀ {a b}, a ∈ complete_on → b ∈ complete_on →
      EqvGen R.rel a b → sameClass a b
  extract : α → α
  extract_mem_class :
    ∀ {a}, a ∈ complete_on → sameClass a (extract a)
```

2. **Cost-monotone extractor**
```lean
structure CostModel (α : Type u) where
  cost : α → Nat

def IsCheapestInClass
    {α : Type u} (c : CostModel α) (C : Set α) (x : α) : Prop :=
  x ∈ C ∧ ∀ y ∈ C, c.cost x ≤ c.cost y
```

3. **Semantic model for rewrite terms**
```lean
structure TermModel (α : Type u) (β : Type v) where
  eval : α → β
  respects :
    ∀ {a b}, EqvGen R.rel a b → eval a = eval b
```

You may refine these signatures to fit the existing catalog abstractions, but the mathematical role must remain: finite e-graph relation, completeness on a saturated domain, and extraction as representative choice.

---

## Main theorem statements

### Theorem 1: Extraction soundness from saturation completeness
This is the central theorem.

**Mathematical statement**

Let `R` be a convergent rewrite system on terms. Let `G` be an e-graph whose `sameClass` relation is sound and complete for `EqvGen R.rel` on a saturated set `S`. Let `extract` choose any representative from the e-class of each term in `S`. Then for every semantic model respecting `EqvGen R.rel`, extraction preserves denotation on `S`.

**Lean 4 target signature**
```lean
theorem extraction_semantics_preserved
    {α : Type u} [DecidableEq α]
    {β : Type v}
    (R : RewriteSystem α)
    (M : α → β)
    (hM : ∀ {a b}, EqvGen R.rel a b → M a = M b)
    (E : SaturatedEGraphExtractor α R)
    {t : α}
    (ht : t ∈ E.complete_on) :
    M (E.extract t) = M t
```

A stronger symmetric form is even better:
```lean
theorem extraction_eq_any_representative
    {α : Type u} [DecidableEq α]
    {β : Type v}
    (R : RewriteSystem α)
    (M : α → β)
    (hM : ∀ {a b}, EqvGen R.rel a b → M a = M b)
    (E : SaturatedEGraphExtractor α R)
    {t u : α}
    (ht : t ∈ E.complete_on)
    (hu : u ∈ E.complete_on)
    (hclass : E.sameClass t u) :
    M (E.extract t) = M u
```

**Why this is a breakthrough**

This theorem turns equality saturation into a certified semantic optimizer. It says the extractor need not compute the normal form; it only needs to pick a representative of the correct quotient class. That separates **semantic correctness** from **search strategy**, which is exactly what modern e-graph systems need.

---

### Theorem 2: Cheapest extraction is sound
Now add optimization content.

**Mathematical statement**

Assume the extractor returns a cheapest representative in the e-class of `t` with respect to a cost model `c`. Then extraction is both semantically sound and cost-optimal within the equivalence class.

**Lean 4 target signature**
```lean
theorem cheapest_extraction_sound_and_optimal
    {α : Type u} [DecidableEq α]
    {β : Type v}
    (R : RewriteSystem α)
    (c : CostModel α)
    (M : α → β)
    (hM : ∀ {a b}, EqvGen R.rel a b → M a = M b)
    (E : SaturatedEGraphExtractor α R)
    (hcheap :
      ∀ {t}, t ∈ E.complete_on →
        IsCheapestInClass c {x | E.sameClass t x ∧ x ∈ E.complete_on} (E.extract t))
    {t u : α}
    (ht : t ∈ E.complete_on)
    (hu : u ∈ E.complete_on)
    (heq : EqvGen R.rel t u) :
    M (E.extract t) = M t ∧ c.cost (E.extract t) ≤ c.cost u
```

This theorem is the formal analogue of “the extractor is a certified optimizer.”

---

### Theorem 3: Agreement with quotient normal form
This is the bridge back to the catalog and the strongest conceptual connection.

**Mathematical statement**

For a convergent rewrite system, if the e-graph is complete for `EqvGen`, then the extracted representative is semantically equal to the canonical normal form representative on the quotient. Hence extraction factors through the same quotient map as `nf`.

**Lean 4 target signature**
```lean
theorem extraction_agrees_with_quotient_nf_semantically
    {α : Type u} [DecidableEq α]
    {β : Type v}
    (R : RewriteSystem α)
    (hconv : Convergent R)
    (M : α → β)
    (hM : ∀ {a b}, EqvGen R.rel a b → M a = M b)
    (E : SaturatedEGraphExtractor α R)
    {t : α}
    (ht : t ∈ E.complete_on) :
    M (E.extract t) = M (nf R t)
```

If the catalog’s exact `nf` signature differs, adapt accordingly. The point is to use `nf_constant_on_eqvGen`, `quotientNf_mk`, and `eval_eq_of_nf_eq` to prove that extraction and normal-form computation define the same semantic quotient representative.

This theorem is strategically vital because it identifies equality saturation as **quotient normalization without canonicality**.

---

## Stronger optional theorem if feasible

If you can formalize bounded saturation:

```lean
theorem bounded_saturation_complete_of_finite_class
    {α : Type u} [Fintype α] [DecidableEq α]
    (R : RewriteSystem α)
    (hconv : Convergent R)
    (E₀ : InitialEGraph α)
    ∃ n : Nat, SaturationCompleteUpTo R E₀ n
```

This would connect abstract completeness to an actual finite algorithm. Even a weaker theorem for finite reachable closures would be important.

---

## Proof architecture: 3 viable strategies

### Strategy A: Quotient-factorization route — most promising
This is the best path because the catalog already contains the quotient-normal-form machinery.

1. **Show extraction lands in the same `EqvGen` class.**  
   From `extract_mem_class` and `sound_sameClass`, derive
   ```lean
   EqvGen R.rel t (E.extract t)
   ```
   for every saturated term `t`.

2. **Apply semantic invariance on `EqvGen`.**  
   Use `hM` directly to conclude:
   ```lean
   M t = M (E.extract t)
   ```
   This proves soundness with almost no dependence on confluence.

3. **Use convergent normal forms only for the bridge theorem.**  
   Invoke `nf_constant_on_eqvGen` to show
   ```lean
   M (E.extract t) = M (nf R t)
   ```
   because both lie in the same equivalence class. Then combine with `quotientNf_mk` to express extraction as a section of the quotient.

**Why this is most promising:**  
It isolates the hard part — e-graph completeness — into a reusable hypothesis and gives immediate semantic correctness once that hypothesis is established.

---

### Strategy B: Normal-form comparison route
This route uses confluence more explicitly.

1. Prove `EqvGen R.rel t (E.extract t)` from saturation soundness.
2. Use convergence to show both `t` and `E.extract t` reduce to the same normal form:
   ```lean
   nf R t = nf R (E.extract t)
   ```
3. Apply `eval_eq_of_nf_eq` or its equivalent to deduce semantic equality.

**Why useful:**  
This route is stronger if the catalog’s semantic theorems are phrased through equality of normal forms rather than direct `EqvGen` invariance.

---

### Strategy C: Induction on saturation derivations
Use this if you formalize saturation as an explicit iterative closure process.

1. Define a stepwise saturation relation on e-graphs.
2. Prove by induction on the number of saturation steps that every union/merge performed is sound with respect to `EqvGen`.
3. Prove completeness by induction on derivations in `EqvGen` restricted to the explored term universe.
4. Conclude extraction soundness from the final saturated graph.

**Why this matters:**  
This route yields an algorithmic theorem, not just an abstract one. It is harder, but it opens the door to verified implementations of equality saturation engines.

---

## Required deep proof tactics

Your file must contain at least 3 substantial theorems using nontrivial tactics and reasoning. Recommended proof shapes:

- **Induction** on derivations of `EqvGen`, rewrite closure, or saturation steps.
- **`rcases`** to unpack equivalence-generation constructors and saturation certificates.
- **`by_contra`** to prove minimality/optimality of extracted terms.
- **multi-step `calc`** blocks to chain semantic equalities through quotient invariance.
- **case analysis** on saturation completeness vs. soundness hypotheses.
- If algebraic costs involve arithmetic, use `field_simp` only where genuinely structural.

Do not let the file devolve into definitional simplifications.

---

## Catalog leverage: how to use the existing theorems

You must explicitly build on the cited catalog results.

### `nf_constant_on_eqvGen`
Use this as the formal engine for:
- proving extracted representatives and normal forms are semantically aligned,
- showing any representative-selection function constant on equivalence classes preserves semantics.

The conceptual move is:
> extraction is not canonical, but it is class-respecting; `nf` is canonical and class-respecting; therefore they agree semantically.

### `quotientNf_mk`
Use this to express the quotient map induced by `nf`, then compare extraction against that quotient representative. If possible, define a quotient-level extraction map and show commutativity of:
```text
term → quotient by EqvGen → chosen representative
```
with semantic evaluation.

### `eval_eq_of_nf_eq`
Use this when proving that if extraction and original term share normal form, then they share semantics. This is the bridge from rewrite-theoretic equality to denotational equality.

---

## Cross-domain theorem requirement

Include at least one theorem connecting equality saturation to another domain. Recommended choice:

### Cross-domain theorem: optimization as abstract interpretation
Interpret extraction as a semantics-preserving abstraction minimizing a resource measure.

**Statement idea**
If `cost` is interpreted as circuit size / proof length / energy, then equality saturation computes a semantics-preserving resource abstraction on each quotient class.

Lean-style target:
```lean
theorem extraction_induces_resource_abstraction
    {α : Type u} [DecidableEq α]
    (R : RewriteSystem α)
    (c : CostModel α)
    (E : SaturatedEGraphExtractor α R) :
    ∀ {t}, t ∈ E.complete_on →
      ∃ x, E.sameClass t x ∧
        IsCheapestInClass c {y | E.sameClass t y ∧ y ∈ E.complete_on} x
```

Then explain this as a bridge to:
- **compiler optimization**: cheapest equivalent program,
- **SMT / theorem proving**: smallest proof witness in an equivalence class,
- **statistical physics**: minimum-energy state within a symmetry orbit,
- **category theory**: choosing a section of a quotient functor subject to a monoidal cost.

A more daring bridge theorem would relate extraction to **free energy minimization on equivalence classes**: semantics are invariants, cost is energy, extraction is ground-state selection.

---

## Conjecture with falsifiable prediction

You must include at least one explicit conjecture with a computational refutation test.

### Conjecture: bounded completeness threshold for finite convergent systems
For every finite convergent rewrite system `R` over a finite signature and every finite seed set `S`, there exists a saturation bound `B(R,S)` such that bounded equality saturation to depth `B(R,S)` computes exactly the `EqvGen` classes reachable from `S`.

A stronger testable formulation:
> For finite convergent systems with maximal rule size `k`, the required saturation depth grows at most polynomially in the size of the reachable normal-form closure.

**Computational test**
- Generate 100 random finite convergent systems.
- For each, choose 1000 random seed terms.
- Compute:
  1. equivalence by normal form,
  2. equivalence by bounded saturation at increasing depth.
- Search for the smallest depth where the two relations agree.
- Fit growth against reachable closure size; any super-polynomial family is evidence against the stronger conjecture.

This is falsifiable: a single family with provably insufficient bounded saturation refutes the polynomial-growth claim.

---

## Verified algorithm requirement

Do not stop at abstract theorems. Produce a verified computational method:

1. A bounded saturation procedure on finite term universes.
2. A cost-based extractor selecting minimal-cost representatives.
3. A theorem of the form:
```lean
theorem runExtractor_sound :
  -- if bounded saturation reports completeness on the explored universe,
  -- extracted terms preserve semantics
```
4. If full completeness is too hard, certify a **conditional optimizer**:
   - the algorithm returns both an extracted term and a proof certificate that it belongs to the same e-class.

This is scientifically important because it yields a checkable optimizer, not just a theorem about an idealized object.

---

## Concrete file-level theorem cluster to aim for

At minimum, your Lean development should contain at least these three nontrivial theorems:

1. `extraction_semantics_preserved`
2. `cheapest_extraction_sound_and_optimal`
3. `extraction_agrees_with_quotient_nf_semantically`

And preferably one algorithmic theorem such as:

4. `bounded_extractor_sound_of_complete`

---

## Application keywords

equality saturation, e-graphs, convergent rewriting, quotient semantics, certified optimization, superoptimization, compiler correctness, SMT, program synthesis, abstract interpretation, normal forms, proof-producing extraction, algebraic simplification, cost minimization, semantics-preserving optimization

---

## Deliverables (ALL mandatory)

You must produce all of the following:

### 1. Lean formalization
A Lean 4 file proving the theorem cluster above, with minimized `sorry`, and with at least:
- 3 deep theorems,
- 1 novel definition,
- 1 cross-domain theorem,
- 1 explicit falsifiable conjecture in comments/markdown linked to experiments.

### 2. `FUTURE_DIRECTIONS.md`
Include 3–5 **testable scientific hypotheses**, each with:
- a precise conjecture,
- what data/experiment would test it,
- what outcome would falsify it.

These must be real scientific hypotheses, not vague ideas.

### 3. `RESEARCH_PAPER.md`
A standalone scientific paper that explains:
- the exact theorem statements,
- how equality saturation differs from normalization,
- why extraction correctness matters,
- the proof architecture,
- computational implications,
- what future questions are opened.

Someone reading only this paper must understand the discovery without seeing the code.

### 4. `ARTICLE.md`
Write this in **Scientific American style**:
- vivid,
- accessible,
- focused on the mathematical/computational ideas,
- absolutely **no focus on formal verification machinery**.

Explain why picking the “best” representative from a cloud of equivalent expressions is a profound idea with implications for compilers, theorem provers, and automated design.

### 5. Verified algorithm / computational method
Implement a bounded saturation + cheapest extraction procedure with correctness guarantees under explicit hypotheses.

### 6. `demo.py`
Interactive demonstration:
- generate random convergent rewrite systems,
- build bounded e-graphs,
- extract cheapest representatives,
- compare extracted semantics with original semantics over random finite algebras,
- print counterexamples if found,
- visualize class merges and extracted costs.

The demo should directly exercise the falsifiable conjecture and theorem hypotheses.

---

## Final call

Do not merely port known e-graph folklore into Lean. Prove that **optimization by equality saturation is quotient-theoretic semantics in disguise**. If you succeed, you will have created a formal foundation for a whole class of optimizer architectures: not “normalize then simplify,” but “search the semantic orbit, then select the best state.”

That is a field-opening perspective.

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
