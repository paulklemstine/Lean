## Assignment: Direction 4: Derived Compression Invariants

**Mode:** prove / discover

Build a cohomological theory of compression from the existing `compressionDefect` infrastructure. Do not settle for a cosmetic extension of κ. The target is a genuinely new mathematical layer: a theory in which compression behaves like a derived functor, with obstruction classes, connecting morphisms, and computable witnesses of non-additivity.

You should aim to make precise — and then either prove or sharply refute with counterexamples plus a repaired definition — the idea that compression defect is the degree-zero shadow of a higher obstruction theory.

## Core Vision

The existing catalog gives a zeroth-order invariant:
- `Pythagorean/ProbeComplexity/CompressionFiltration.lean` — `compressionDefect`
- `Catalog/Pythagorean/ProbeComplexity/CoproductSubadditivity.lean` — `compressionDefect_nonneg`

The breakthrough is to define **higher compression invariants** `κⁿ` that detect failure of local compression data to glue globally, in exact analogy with sheaf cohomology and derived functors. If successful, this would create a new field: **cohomological information complexity**.

This is not “another defect measure.” It is the claim that compression admits:
1. a degree-zero quantity,
2. a first obstruction to additive decomposition,
3. higher obstruction layers,
4. exactness principles under short exact sequences,
5. computable tests on finite examples.

That would open a bridge between:
- probe complexity,
- homological algebra,
- sheaf theory,
- topological data analysis,
- and quantum-information-style multipartite correlation measures.

## Precise Formal Target

Your first task is to **formalize a tractable finite-model version** of the conjecture. Do not begin with arbitrary presheaves if that blocks progress. Start with a finite combinatorial compression system where exactness can be stated and tested.

### New definitions to introduce

Define a new structure encoding a finite compression datum together with a defect functional and a notion of short exact extension.

A plausible Lean-facing scaffold is:

```lean
structure CompressionSystem where
  Obj : Type
  size : Obj → ℕ
  compress : Obj → ℕ
  defect : Obj → ℤ := fun X => (compress X : ℤ) - (size X : ℤ)

structure ShortExactCompression (C : Type) [AddCommGroup C] where
  A B Q : C
  ι : A →+ B
  π : B →+ Q
  exact₁ : ∀ a, π (ι a) = 0
  exact₂ : ∀ b, π b = 0 → ∃ a, ι a = b
```

If the catalog’s actual `compressionDefect` lives on a different object type, adapt this scaffold to that type rather than forcing the catalog to fit this structure. The point is to define a reusable interface for higher invariants.

Then define a first derived candidate. For a short exact sequence `E : ShortExactCompression C`, introduce:

```lean
def kappa0 (X : C) : ℤ := compressionDefect X

def kappa1 {C : Type} [AddCommGroup C]
    (κ : C → ℤ) (E : ShortExactCompression C) : ℤ :=
  κ E.A + κ E.Q - κ E.B
```

This `κ¹` is the first obstruction candidate: vanishing means κ is additive on the extension.

You should also define a notion of **chain of extensions** or **two-step extension** so that a second-order obstruction can be stated. One possible route:

```lean
structure ExtensionChain (C : Type) [AddCommGroup C] where
  X₀ X₁ X₂ : C
  e₁ : ShortExactCompression C
  e₂ : ShortExactCompression C
```

or, more concretely, define a “boundary of defects” on composable extension data.

## Primary Theorem Targets

You must prove at least 3 nontrivial theorems. The following are the minimum viable core, and they should be stated with Lean 4 type signatures as closely as possible.

### Theorem 1: Nonnegativity of first derived compression under subadditivity
If κ is subadditive on short exact extensions, then the first derived invariant is nonnegative.

```lean
theorem kappa1_nonneg
    {C : Type} [AddCommGroup C]
    (κ : C → ℤ)
    (hsub : ∀ (E : ShortExactCompression C), κ E.B ≤ κ E.A + κ E.Q)
    (E : ShortExactCompression C) :
    0 ≤ kappa1 κ E := by
```

**Mathematical statement:**  
For every short exact compression extension `0 → A → B → Q → 0`, if
`κ(B) ≤ κ(A) + κ(Q)`, then
`κ¹(E) = κ(A) + κ(Q) - κ(B) ≥ 0`.

**Why it matters:**  
This proves that the first derived invariant is not arbitrary noise: it is an honest obstruction quantity.

### Theorem 2: Vanishing of κ¹ on split extensions
Show that if an extension splits and κ is additive on biproducts/coproducts, then κ¹ vanishes.

```lean
theorem kappa1_of_split
    {C : Type} [AddCommGroup C]
    (κ : C → ℤ)
    (hadd : ∀ X Y : C, κ (X + Y) = κ X + κ Y)
    (E : ShortExactCompression C)
    (hsplit : ∃ s : E.Q →+ E.B, E.π.comp s = AddMonoidHom.id E.Q) :
    kappa1 κ E = 0 := by
```

If the ambient category does not literally identify split extensions with `B ≃ A ⊕ Q`, adapt the statement to the available notion of direct-sum decomposition.

**Mathematical statement:**  
If `0 → A → B → Q → 0` splits and κ is additive on the corresponding direct-sum decomposition, then
`κ(A) + κ(Q) = κ(B)`.

**Why it matters:**  
This identifies κ¹ as an extension obstruction. It is the exact analog of how Ext¹ vanishes on split extensions.

### Theorem 3: Functorial invariance of κ¹ under isomorphism of extensions
Define isomorphism of short exact compression data and prove κ¹ is invariant.

```lean
structure ShortExactCompressionIso {C : Type} [AddCommGroup C]
    (E₁ E₂ : ShortExactCompression C) where
  isoA : E₁.A ≃+ E₂.A
  isoB : E₁.B ≃+ E₂.B
  isoQ : E₁.Q ≃+ E₂.Q
  comm₁ : ∀ a, isoB (E₁.ι a) = E₂.ι (isoA a)
  comm₂ : ∀ b, isoQ (E₁.π b) = E₂.π (isoB b)

theorem kappa1_iso_invariant
    {C : Type} [AddCommGroup C]
    (κ : C → ℤ)
    (hiso : ∀ {X Y : C}, Nonempty (X ≃+ Y) → κ X = κ Y)
    {E₁ E₂ : ShortExactCompression C}
    (e : ShortExactCompressionIso E₁ E₂) :
    kappa1 κ E₁ = kappa1 κ E₂ := by
```

**Why it matters:**  
Without this, κ¹ depends on presentation rather than geometry/information content.

### Theorem 4: A finite exactness surrogate
A full long exact sequence may be too ambitious in the first cycle. Prove at least a **degree-0/1 exactness surrogate**:

```lean
theorem kappa0_kappa1_exact_surrogate
    {C : Type} [AddCommGroup C]
    (κ : C → ℤ)
    (E : ShortExactCompression C) :
    κ E.B = κ E.A + κ E.Q - kappa1 κ E := by
```

This is algebraically simple, but its significance is conceptual: κ¹ is exactly the correction term measuring failure of exact additivity.

This theorem alone is not deep enough; it must sit beside the deeper invariance/splitting/functoriality results above.

### Theorem 5: Two-step obstruction identity
Define a second-order candidate on composable extension data and prove at least one coherence theorem. For example, if `κ²` is defined as the defect of additivity of `κ¹` across a compatible pair of extensions, prove vanishing on doubly split chains or invariance under chain isomorphism.

A possible signature:

```lean
def kappa2
    {C : Type} [AddCommGroup C}
    (κ : C → ℤ) (T : ExtensionChain C) : ℤ := ...

theorem kappa2_of_doubly_split
    {C : Type} [AddCommGroup C]
    (κ : C → ℤ)
    (hadd : ∀ X Y : C, κ (X + Y) = κ X + κ Y)
    (T : ExtensionChain C)
    (hsplit₁ : ...)
    (hsplit₂ : ...) :
    kappa2 κ T = 0 := by
```

This would be the first genuine evidence for a higher hierarchy.

## Most Promising Mathematical Strategy

### Strategy A: Derived-obstruction-by-defect calculus
This is the most promising route.

1. **Abstract the algebra of defect first.**  
   Treat `κ¹(E) = κ(A) + κ(Q) - κ(B)` as a universal obstruction attached to a short exact sequence.
2. **Prove structural laws before chasing full exactness.**  
   Nonnegativity, split vanishing, and isomorphism invariance are the first “axioms” of a cohomology-like theory.
3. **Build κ² from coherent failure of κ¹ to glue over extension chains.**  
   This avoids the enormous burden of constructing projective/injective resolutions in the first pass.

Why this is strongest: it produces publishable mathematics even if the full long exact sequence fails. If exactness collapses, you will still have isolated the right obstruction theory and found the correction terms.

### Strategy B: Finite presheaf model with Čech-style compression cochains
Use finite covers and define:
- `C⁰`: local compression assignments,
- `C¹`: overlap inconsistency penalties,
- `δ`: restriction mismatch,
- `κⁿ`: rank/size/defect of cocycles modulo coboundaries.

Steps:
1. Model a finite presheaf on a finite poset or cover.
2. Define compression-compatible cochains.
3. Show `κ⁰` recovers existing compression defect or bounds it.
4. Prove a Mayer–Vietoris-style exact sequence in low degree.

Why it is revolutionary: this turns “compression” into a literal sheaf cohomology theory.  
Why it is harder: Mathlib support for general sheaf cohomology may be too heavy for one cycle unless you work with explicit finite combinatorics.

### Strategy C: Counterexample-guided repair of the conjectural long exact sequence
Take the user’s candidate definition literally:
`κ¹(E) = κ(A) + κ(Q) - κ(B)`,
compute small examples, and determine whether exactness can possibly hold.

Steps:
1. Build exhaustive finite examples of short exact compression systems.
2. Search for failure of naturality or exactness.
3. If failure occurs, identify the missing term: normalization, sign, rank correction, or Euler-characteristic-style alternation.
4. Prove the repaired version in a finite class.

Why this is scientifically excellent: a decisive counterexample is as valuable as a proof if it reveals the correct invariant.

## Cross-Domain Connections You Must Exploit

### 1. Homological algebra
The central analogy is:
- `κ⁰` behaves like a left-exact size/compression functor,
- `κ¹` measures failure of exactness,
- higher `κⁿ` should behave like derived functors or obstruction groups.

You should explicitly compare:
- split exactness ↔ vanishing of extension obstruction,
- long exact sequence ↔ derived-functor formalism,
- Euler characteristic ↔ alternating compression balance.

### 2. Algebraic topology / sheaf cohomology
Interpret local compression schemes on overlaps as cocycles. Then:
- `κ¹` becomes a consistency obstruction,
- `κ²` measures higher compatibility among overlap corrections.

This suggests a compression-theoretic analog of Čech cohomology for distributed data.

### 3. Quantum information theory
Multipartite entanglement is not captured by pairwise correlations; likewise, higher compression obstructions should detect irreducible multi-overlap structure not visible in κ⁰.

Use this analogy carefully:
- `κ¹` ↔ pairwise extension obstruction,
- `κ²` ↔ genuine tripartite obstruction,
- higher `κⁿ` ↔ nonlocal consistency cost.

### 4. Topological data analysis
Compression on overlaps resembles persistent compatibility of local summaries. A nonzero higher κ could indicate “holes” in summarizability: data that compresses locally but not globally.

## Concrete Lean Guidance

You are required to minimize sorry, but this is not a “fill in easy lemmas” task. You must produce at least 3 substantial proofs using induction, `rcases`, `by_contra`, `field_simp` where relevant, or multi-step `calc`.

Likely proof ingredients:
- `rcases` on split maps / exactness witnesses,
- `calc` chains in `ℤ`,
- `linarith` only as support, not as the entire proof idea,
- induction on finite extension chains if you define iterated obstructions,
- `by_contra` to show nonnegativity consequences from catalog inequalities,
- transport across isomorphism using `congrArg` and extensionality.

If the actual catalog theorem is:

```lean
compressionDefect_nonneg : 0 ≤ compressionDefect X
```

or a variant of subadditivity, then explicitly use it to instantiate `κ := compressionDefect` in at least one theorem, e.g.

```lean
theorem derived_compression_nonneg
    (E : ShortExactCompression CatalogCompressionObject) :
    0 ≤ kappa1 compressionDefect E := by
```

provided the needed subadditivity theorem is available or can be proved from the catalog setup.

## Falsifiable Conjectures and Computational Tests

You must include at least one conjecture with a genuine computational refutation path. Preferably include 3–5 in `FUTURE_DIRECTIONS.md`, but at minimum the following should appear.

### Conjecture 1: Split-detection conjecture
For finite compression systems,
`kappa1 κ E = 0` if and only if `E` is compression-split.

**Test:** Exhaustively enumerate small finite systems with bounded size parameters and compare vanishing of `κ¹` against existence of a splitting map.

### Conjecture 2: Higher-obstruction stabilization
For compression systems over finite posets of cover dimension `d`, one has `κⁿ = 0` for all `n > d`.

**Test:** Generate finite cover posets of dimensions 1, 2, 3 and compute explicit `κⁿ` candidates.

### Conjecture 3: Euler compression identity
For a finite acyclic compression resolution `R•`,
\[
\sum_n (-1)^n κ^n(R•) = κ^0(\mathrm{global\ object}).
\]

**Test:** Compute on small chain complexes / extension towers and search for violations.

### Conjecture 4: Quantum-style monogamy inequality
If `κ²` detects irreducible three-way compression obstruction, then large `κ²` forces lower total pairwise `κ¹`.

**Test:** On finite triple-overlap examples, numerically compare `κ²` against sums of pairwise `κ¹`.

## What Would Count as a Breakthrough

A theorem package proving:
- `κ¹` is well-defined and isomorphism-invariant,
- `κ¹` is nonnegative under subadditivity,
- `κ¹` vanishes on split extensions,
- a coherent `κ²` exists in finite models and vanishes on doubly split chains,
- plus a tested conjectural exactness law on examples,

would establish the first credible evidence that compression complexity has a derived layer.

That would create an entirely new language:
- **cohomological compression,**
- **extension obstructions to summarization,**
- **higher-order information defects.**

This would not merely extend the catalog. It would redefine the compression framework as part of homological mathematics.

## Deliverables — ALL mandatory

You must produce all of the following:

1. **Lean file(s)** with:
   - at least one new structure or concept not already in the catalog,
   - at least 3 nontrivial theorems with substantial proofs,
   - explicit use of catalog results where applicable,
   - minimal sorry.

2. **`FUTURE_DIRECTIONS.md`** containing **3–5 falsifiable scientific hypotheses**, each with:
   - a precise conjecture,
   - a concrete computational or mathematical test,
   - what outcome would refute it.

3. **`RESEARCH_PAPER.md`** as a **standalone scientific paper**:
   - problem statement,
   - definitions,
   - main theorems,
   - proof ideas,
   - significance,
   - computational experiments,
   - next questions.
   It must make sense to a reader with no access to the code.

4. **`ARTICLE.md`** in **Scientific American style**:
   - broad-audience narrative,
   - why higher compression obstructions matter,
   - cross-domain significance,
   - no focus on formal verification machinery.

5. **A verified algorithm or computational method**:
   - e.g. a procedure computing `κ¹` and candidate `κ²` on finite extension data,
   - or a search algorithm for counterexamples to exactness.

6. **`demo.py`**:
   - interactive demonstration on small finite examples,
   - compute `κ⁰`, `κ¹`, and if possible `κ²`,
   - show split vs non-split behavior,
   - test at least one conjecture experimentally.

## Application Keywords

cohomological information complexity; derived compression; exact sequences; extension obstruction; sheaf compression; Čech-style consistency; higher-order correlation; multipartite information; topological data analysis; algebraic topology; homological algebra; obstruction theory; finite presheaves; distributed data summarization; quantum entanglement analogies; Euler characteristic of compression; categorical complexity measures

## Final Instruction

Do not hide behind the full general conjecture if it is not yet formally tractable. Either:
- prove the low-degree obstruction theory cleanly and convincingly, or
- find the precise obstruction to the conjecture and repair it.

But in either case, produce mathematics that changes the meaning of compression defect from a static quantity into the first layer of a derived theory.

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
