## Soli Deo Gloria

# Assignment: Direction 4 — Compression Stability Under Probe Enlargement

**Mode:** `prove`

Prove genuinely new, non-trivial theorems in Lean 4 about **monotonicity and rigidity of measurement under enlargement of probe families**, turning the existing “objectwise cardinality” viewpoint into a categorical analogue of the **data processing inequality** and a first step toward a theory of **experimental sufficiency** in categorical measurement.

This direction is worth doing only if it becomes more than a routine monotonicity lemma. The real target is to isolate a mathematically meaningful notion of **redundant enlargement** and prove a sharp equality criterion. If done correctly, this opens a bridge from probe complexity to information theory, statistical experiment comparison, and sampling theory.

Build explicitly on:

- `Pythagorean/ProbeComplexity/RepresentableDimension.lean`
  - `measurementInvariant_eq_objectwiseTotalCard`
- `Pythagorean/ProbeComplexity/Theorems.lean`
  - `ProbeFamily.IsSeparating.supset`

Your task is to introduce at least one **new definition** capturing “no new distinguishability is created by enlarging probes,” and then prove at least 3 substantial theorems with real proof structure.

---

## Core Mathematical Vision

Let `P ⊆ P'` be nested probe families with restriction/forgetful compatibility. Intuitively, a larger family of probes observes at least as much as a smaller one. The measurement invariant should therefore be monotone. But the real theorem is stronger:

- **Monotonicity:** enlarging probes never decreases measurement resolution.
- **Rigidity / Equality criterion:** equality occurs exactly when the new probes add no new separation power beyond what was already visible to the old probes.

This is the categorical shadow of:

- **Data processing inequality** in information theory,
- **Sufficient statistics** in statistics,
- **Refinement of partitions** in combinatorics,
- **Sampling monotonicity** in signal processing,
- **Observable algebras** in physics.

The breakthrough is not the inequality alone. The breakthrough is expressing **measurement as a partition/refinement invariant** and proving that probe enlargement induces a **refinement order** whose cardinal profile controls information gain.

---

## New Definition to Introduce

You must define a notion like one of the following, choosing the one that best matches the existing API:

### Option A: Redundant enlargement
A larger probe family `P'` is **redundant over** `P` if every equivalence class induced by `P` is already a class for `P'`, i.e. the two families induce the same signature partition on objects.

Suggested formal shape:
```lean
def ProbeFamily.RedundantOver
    {C : Type u} [Category.{v} C]
    (P P' : ProbeFamily C) : Prop :=
  ∀ X Y, ProbeSignatureEq P X Y ↔ ProbeSignatureEq P' X Y
```

### Option B: Refinement relation on probe signatures
Define a relation expressing that the `P'`-signature refines the `P`-signature:
```lean
def ProbeFamily.Refines
    {C : Type u} [Category.{v} C]
    (P P' : ProbeFamily C) : Prop :=
  ∀ ⦃X Y⦄, ProbeSignatureEq P' X Y → ProbeSignatureEq P X Y
```

Then `RedundantOver` can be defined as mutual refinement or equality of induced partitions.

### Option C: Equality-on-measurement classes
If the invariant is defined objectwise, define a structure saying that for each object `X`, the cardinality of the signature image is unchanged under enlargement.

This is weaker than full partition equality, so it is useful for “same compression dimension but not same separator geometry.”

**Recommendation:** Define both `Refines` and `RedundantOver`. `Refines` is the structural notion; `RedundantOver` is the rigidity notion.

---

## Precise Theorem Targets

You must prove at least the following 3 theorem-level results, with nontrivial proofs.

---

### Theorem 1: Monotonicity under probe enlargement

**Mathematical statement.**  
If `P ⊆ P'`, then the measurement invariant for `P` is at most that for `P'`.

This should be proved either globally or objectwise, depending on the actual catalog definition. If the catalog’s `measurementInvariant` is object-indexed/cardinality-based, prove the strongest version available.

### Suggested Lean 4 type signature
Adapt names to the actual API, but target something of this strength:
```lean
theorem measurementInvariant_mono_of_subset
    {C : Type u} [Category.{v} C]
    [Fintype C] [DecidableEq C]
    (P P' : ProbeFamily C)
    (hPP' : P ≤ P') :
    measurementInvariant P ≤ measurementInvariant P' := by
  ...
```

If the invariant is objectwise:
```lean
theorem measurementInvariant_mono_of_subset
    {C : Type u} [Category.{v} C]
    [Fintype C] [DecidableEq C]
    (P P' : ProbeFamily C)
    (hPP' : P ≤ P') (X : C) :
    measurementInvariant P X ≤ measurementInvariant P' X := by
  ...
```

### Why this matters
This is the categorical **data processing inequality for observations**: more observables cannot reduce distinguishability. It gives a rigorous order structure on experimental resolution.

### Proof strategy options

**Strategy A: Signature refinement via image factorization**  
1. Define the signature map associated to `P` and `P'`.  
2. Show that the `P'`-signature determines the `P`-signature by restriction/forgetting coordinates.  
3. Conclude that the image of the `P`-signature is the image of a map out of the image of the `P'`-signature, so cardinality is monotone.

**Strategy B: Partition refinement**  
1. Define the equivalence relation “indistinguishable by `P`”.  
2. Show `P ⊆ P'` implies every `P'`-equivalence class is contained in a `P`-equivalence class.  
3. Use finite partition refinement to deduce cardinal monotonicity of the quotient/image count.

**Strategy C: Objectwise cardinal theorem + catalog rewriting**  
1. Rewrite both sides using `measurementInvariant_eq_objectwiseTotalCard`.  
2. Prove the objectwise total-cardinality formula is monotone under coordinate extension.  
3. Finish by a `calc` chain.  

**Most promising:** Strategy C if the catalog theorem already exposes the invariant as a cardinality of an image or total signature count. Otherwise Strategy B is conceptually strongest and will generalize better.

---

### Theorem 2: Equality from redundancy / no-new-separation

**Mathematical statement.**  
If `P ⊆ P'` and `P'` adds no new separating power beyond `P`, then the measurement invariant is unchanged.

### Suggested Lean 4 type signature
```lean
theorem measurementInvariant_eq_of_redundantOver
    {C : Type u} [Category.{v} C]
    [Fintype C] [DecidableEq C]
    (P P' : ProbeFamily C)
    (hPP' : P ≤ P')
    (hred : P'.RedundantOver P) :
    measurementInvariant P = measurementInvariant P' := by
  ...
```

or objectwise:
```lean
theorem measurementInvariant_eq_of_redundantOver
    {C : Type u} [Category.{v} C]
    [Fintype C] [DecidableEq C]
    (P P' : ProbeFamily C)
    (hPP' : P ≤ P')
    (hred : P'.RedundantOver P)
    (X : C) :
    measurementInvariant P X = measurementInvariant P' X := by
  ...
```

### Why this matters
This is the first formal notion of **probe sufficiency**: a larger experiment can be observationally equivalent to a smaller one. This is exactly the logic of sufficient statistics and redundant sensors.

### Proof strategy options

**Strategy A: Equality of induced signature partitions**  
1. Use `RedundantOver` to show the two signature equivalence relations coincide.  
2. Deduce equality of quotient cardinalities / image cardinalities.  
3. Rewrite back to measurement invariants.

**Strategy B: Two monotonicity inequalities**  
1. `P ≤ P'` gives `measurementInvariant P ≤ measurementInvariant P'`.  
2. Redundancy gives a reverse factorization map from `P`-signatures to `P'`-signatures.  
3. Conclude by antisymmetry.

**Strategy C: Separating-family route**  
1. If your redundancy notion is stated using separation, invoke `ProbeFamily.IsSeparating.supset`.  
2. Show both probe families separate the same pairs.  
3. Convert same-separation data into equal measurement invariant.

**Most promising:** Strategy A, because it reveals the real mathematical structure: equality of information partitions.

---

### Theorem 3: Equality characterization iff no new distinguishability is created

This is the hard theorem and should be the centerpiece.

**Mathematical statement.**  
Under a suitable finiteness/compatibility hypothesis, for `P ⊆ P'`:
\[
\mathrm{measurementInvariant}(P)=\mathrm{measurementInvariant}(P')
\iff
\text{every pair distinguished by }P' \text{ was already distinguished by }P.
\]

You may need to phrase the right-hand side using your new `RedundantOver` or `Refines` definitions.

### Suggested Lean 4 type signature
```lean
theorem measurementInvariant_eq_iff_redundantOver
    {C : Type u} [Category.{v} C]
    [Fintype C] [DecidableEq C]
    (P P' : ProbeFamily C)
    (hPP' : P ≤ P') :
    measurementInvariant P = measurementInvariant P' ↔ P'.RedundantOver P := by
  ...
```

or an objectwise/localized version:
```lean
theorem measurementInvariant_eq_iff_same_signature_partition
    {C : Type u} [Category.{v} C]
    [Fintype C] [DecidableEq C]
    (P P' : ProbeFamily C)
    (hPP' : P ≤ P')
    (X : C) :
    measurementInvariant P X = measurementInvariant P' X ↔
      SameSignaturePartitionAt P P' X := by
  ...
```

### Important warning
This equivalence may be **too strong globally** without an extra hypothesis. If so, do not force a false theorem. Instead:

- either prove the forward implication under an added assumption such as injectivity/surjectivity of a comparison map,
- or produce a **counterexample theorem** showing equality of cardinalities need not imply equality of partitions,
- and then prove the corrected theorem.

A mathematically serious outcome is:

```lean
theorem measurementInvariant_eq_iff_redundantOver
    ...
    (hcompat : SignatureComparisonBijective P P') :
    measurementInvariant P = measurementInvariant P' ↔ P'.RedundantOver P := by
  ...
```

or:

```lean
theorem redundantOver_iff_no_new_separation
    ...
```

together with a separate theorem
```lean
theorem measurementInvariant_eq_of_redundantOver ...
```

If the full iff fails, that is not a setback — it is a discovery. Formalize the obstruction sharply.

### Proof strategy options

**Strategy A: Finite surjection between signature images**  
1. From `P ⊆ P'`, construct a surjective forgetful map `img(sig P') → img(sig P)`.  
2. Equality of finite cardinalities upgrades this surjection to a bijection.  
3. Use bijectivity to show no two `P'`-classes collapse under forgetting, hence no new distinction exists.

**Strategy B: Contrapositive via class splitting**  
1. Assume `P'` creates a genuinely new distinction inside a `P`-equivalence class.  
2. Show this splits one `P`-class into at least two `P'`-classes.  
3. Conclude strict inequality of image/partition cardinalities by finite counting.

**Strategy C: Counterexample-guided correction**  
1. Attempt the naive iff.  
2. If blocked, build a small finite counterexample in Lean for categories with few objects.  
3. Refine the theorem to the strongest true statement and prove that instead.

**Most promising:** Strategy B if your invariant really counts classes. It yields a strong, conceptually clean strictness theorem.

---

## Strong Optional Theorem 4: Strict monotonicity under genuinely new separation

If you can prove this, the project becomes much more compelling.

### Statement
If `P ⊆ P'` and there exist objects `X,Y` that are indistinguishable by `P` but distinguished by `P'`, then:
\[
\mathrm{measurementInvariant}(P) < \mathrm{measurementInvariant}(P').
\]

### Suggested Lean signature
```lean
theorem measurementInvariant_strict_mono_of_new_separation
    {C : Type u} [Category.{v} C]
    [Fintype C] [DecidableEq C]
    (P P' : ProbeFamily C)
    (hPP' : P ≤ P')
    (hnew : ∃ X Y, ProbeSignatureEq P X Y ∧ ¬ ProbeSignatureEq P' X Y) :
    measurementInvariant P < measurementInvariant P' := by
  ...
```

This is the exact analogue of **strict information gain** when a statistic becomes strictly finer.

---

## Cross-Domain Connection Theorem

You are required to include at least one theorem connecting probe complexity to another domain.

### Recommended theorem: partition refinement / information preorder
Define a finite partition associated to each probe family and show enlargement induces refinement.

```lean
theorem probe_partition_refines_of_subset
    {C : Type u} [Category.{v} C]
    [Category.{v} C] [Fintype C] [DecidableEq C]
    (P P' : ProbeFamily C)
    (hPP' : P ≤ P') :
    P.PartitionRefines P' := by
  ...
```

Or prove a theorem explicitly named after information theory:

```lean
theorem data_processing_inequality_for_measurementInvariant
    {C : Type u} [Category.{v} C]
    [Fintype C] [DecidableEq C]
    (P P' : ProbeFamily C)
    (hPP' : P ≤ P') :
    measurementInvariant P ≤ measurementInvariant P' := by
  simpa using measurementInvariant_mono_of_subset P P' hPP'
```

This theorem is mathematically the same as Theorem 1, but naming it this way creates a bridge to information theory and supports the exposition in the paper and article.

### Cross-domain significance
- **Information theory:** more observables means a finer sigma-algebra / partition.
- **Signal processing:** denser sampling cannot reduce recoverable resolution.
- **Statistics:** adding tests cannot make two previously distinguishable hypotheses become indistinguishable.
- **Physics:** enlarging an observable algebra refines superselection sectors.
- **Experimental design:** new instruments improve or preserve identifiability.

**Application keywords:** data processing inequality, sufficient statistics, partition refinement, sensor fusion, identifiability, experiment design, coarse-graining, observable algebras, sampling resolution, information preorder.

---

## Concrete Lean Architecture

You should aim to create a file along the lines of:

```text
Pythagorean/ProbeComplexity/CompressionStability.lean
```

with sections such as:

1. `RefinementDefinitions`
2. `Monotonicity`
3. `EqualityAndRedundancy`
4. `Strictness`
5. `InformationTheoryBridge`

### Suggested definitions
Possible names; adapt to actual API.

```lean
def ProbeSignatureEq (P : ProbeFamily C) (X Y : C) : Prop := ...
def ProbeFamily.Refines (P P' : ProbeFamily C) : Prop := ...
def ProbeFamily.RedundantOver (P' P : ProbeFamily C) : Prop := ...
def ProbeFamily.NoNewSeparation (P P' : ProbeFamily C) : Prop := ...
```

### Suggested lemmas
```lean
theorem ProbeFamily.refines_of_subset ...
theorem redundantOver_iff_mutual_refinement ...
theorem noNewSeparation_iff_refines ...
theorem signatureEq_of_subset ...
theorem image_card_mono_of_factor ...
```

These intermediate lemmas will likely be essential and should not be bypassed.

---

## Proof Tactic Expectations

You are explicitly required to avoid trivial one-line proofs unless the statement is profound. At least 3 theorems must use substantial tactics such as:

- `induction`
- `rcases`
- `by_contra`
- `field_simp` if a counting/algebraic normalization appears
- multi-step `calc`
- explicit finite-set cardinal arguments
- construction of maps between images / quotient classes

Good signs:
- proving refinement by unpacking existential witnesses with `rcases`,
- proving strictness by contradiction,
- using `calc` to chain rewrites through `measurementInvariant_eq_objectwiseTotalCard`,
- using finite cardinal inequalities through image factorization.

Bad signs:
- theorem proved solely by simplification after unfolding all definitions,
- vacuous restatements,
- proving only decidable toy cases by enumeration.

---

## Counterexample Discipline

Be scientifically honest. The proposed equality characterization

\[
\mathrm{measurementInvariant}(P)=\mathrm{measurementInvariant}(P')
\iff
P \text{ already separates everything } P' \text{ separates}
\]

may fail if the invariant remembers only a coarse cardinality and not the full partition structure.

If you discover this, you must formalize the failure as a **counterexample theorem** for a finite category, and then state and prove the corrected theorem. A good corrected theorem is more valuable than a false grand claim.

Possible counterexample target:
```lean
theorem exists_equal_measurementInvariant_not_redundantOver :
  ∃ (C : Type) (_ : Fintype C) (_ : DecidableEq C)
    (P P' : ProbeFamily (Discrete C)),
    P ≤ P' ∧
    measurementInvariant P = measurementInvariant P' ∧
    ¬ P'.RedundantOver P := by
  ...
```

If such a counterexample exists, it becomes a central scientific point: **cardinality of measurement can miss geometric structure of distinguishability**.

---

## Computational / Experimental Component

You must also produce a verified computational method and a Python demo.

### Verified algorithm
Implement a finite procedure that, for a small discrete category and nested probe families `P ⊆ P'`, computes:

1. `measurementInvariant P`
2. `measurementInvariant P'`
3. whether monotonicity holds
4. whether the equality characterization holds
5. whether strictness occurs when a new separation pair exists

This should not be a mere theorem statement. It should be an executable certified method in Lean for finite instances.

### `demo.py`
Create an interactive demonstration that:
- enumerates all discrete categories with at most 4 objects, or all nested probe families over a fixed small discrete category,
- computes the measurement invariants,
- displays monotonicity statistics,
- highlights equality cases,
- searches for counterexamples to the naive iff characterization,
- visualizes partition refinement as a Hasse diagram or simple class-coloring plot.

The demo should make the science visible.

---

## Falsifiable Conjecture

You must state at least one computationally testable conjecture with a clear refutation criterion.

### Recommended conjecture
**Conjecture (strict gain dichotomy for finite discrete categories).**  
For finite discrete categories, if `P ⊆ P'` and `P'` introduces a new separation pair, then
\[
\mathrm{measurementInvariant}(P) < \mathrm{measurementInvariant}(P').
\]

**Computational test:** Enumerate all nested probe families on discrete categories with at most 4 objects. Search for a pair with a new separation pair but equal measurement invariant. One such example refutes the conjecture.

### Stronger conjecture
If the signature image forgetful map `img(sig P') → img(sig P)` is surjective, then equality of cardinalities implies bijectivity and hence redundancy.  
This can be tested by explicit image computation on finite examples.

---

## Deliverables — ALL MANDATORY

You must produce all of the following:

1. **Lean file(s)** with at least 3 substantial theorems and at least one novel definition, minimizing `sorry`.
2. **`FUTURE_DIRECTIONS.md`** containing 3–5 testable scientific hypotheses. Each must be falsifiable by a clear computational or mathematical test.
3. **`RESEARCH_PAPER.md`** as a standalone scientific paper. It must explain:
   - the definitions,
   - the main theorems,
   - whether the equality characterization is true or false,
   - why this is a categorical data processing principle,
   - what new research program it opens.
4. **`ARTICLE.md`** in Scientific American style, accessible and engaging, focused on the mathematics and significance.  
   **Taboo:** do not focus on formal verification machinery.
5. **A verified algorithm or computational method** for finite-instance evaluation of monotonicity/equality/strictness.
6. **`demo.py`** showing the phenomenon interactively.

---

## Scientific Significance

If successful, this work establishes the first robust **order theory of probe families**:

- probe enlargement as **information refinement**,
- equality as **experimental redundancy**,
- strict inequality as **genuine information gain**.

That opens several directions:
- categorical sufficient statistics,
- Blackwell-style comparison of experiments,
- probe complexity as entropy-like geometry,
- coarse-graining and renormalization in physics,
- sensor placement and adaptive experiment design.

The point is not merely “adding probes helps.” The point is to identify **when it helps, when it does not, and how to detect the difference structurally**.

This can become the seed of a new formal theory of **categorical observability and information order**.

Go for the strongest true theorem. If the naive equivalence fails, expose the obstruction cleanly and turn that failure into the main discovery.

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
