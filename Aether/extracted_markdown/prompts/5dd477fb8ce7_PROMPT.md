Soli Deo Gloria

## Assignment: Direction 4 — Probe Complexity as Categorical Dimension

**Mode:** `prove`

You are not being asked to tidy up an existing local lemma. You are being asked to create a new categorical invariant with the potential to sit beside global dimension, Krull dimension, Loewy length, and representation type.

The guiding vision is this:

> **Probe complexity measures how many “test objects” are needed to distinguish all morphisms by precomposition.**
>
> In semisimple or finite-length settings, this should collapse to a structural invariant governed by simple objects.

This is not a small extension of the catalog. If done correctly, it opens a new program: **categorical tomography**, where objects play the role of measurement devices and complexity is the minimal measurement basis.

Build explicitly on:

- `Pythagorean/ProbeComplexity/Theorems.lean`
  - `probeComplexity_le_card`
  - `card_hom_le_profile_capacity`

Your task is to turn the current combinatorial probe framework into a mathematically meaningful invariant in algebra and representation theory.

---

## Core Definitions to Introduce

You must define at least one genuinely new concept not already present in the catalog. The most promising package is:

### 1. Separating family of probes
For a category `C`, a family of objects `S : Finset C` is **separating by precomposition** if for every pair of parallel morphisms `f g : X ⟶ Y`, whenever
`h ≫ f = h ≫ g` for all `P ∈ S` and all `h : P ⟶ X`, then `f = g`.

A Lean-facing form may be:

```lean
def PrecomposeSeparatingFamily
  {C : Type u} [Category.{v} C] (S : Finset C) : Prop :=
  ∀ ⦃X Y : C⦄ (f g : X ⟶ Y),
    (∀ P, P ∈ S → ∀ h : P ⟶ X, h ≫ f = h ≫ g) → f = g
```

If `Finset C` is inconvenient due to object equality / fintype issues, use `Set C`, `Finite`, or a structure carrying a finite list plus nodup witness. Do not get trapped by implementation details; choose the formalization that makes the theorem architecture robust.

### 2. Probe dimension / probe complexity of a category
Define the minimal cardinality of a finite separating family when it exists.

A flexible Lean signature could be:

```lean
def categoryProbeComplexity
  {C : Type u} [Category.{v} C] : WithTop ℕ := ...
```

using `⊤` for “no finite separating family”.

### 3. Simple-generated probe basis
For abelian / semisimple categories, define the finite set of simple-object isomorphism classes used as probes. If quotienting by isomorphism is too heavy, define a predicate saying a chosen family consists of pairwise nonisomorphic simples and is representation-complete.

Possible interface:

```lean
def IsSimpleProbeBasis
  {C : Type u} [Category.{v} C] [Abelian C]
  (S : Finset C) : Prop := ...
```

This concept is new and mathematically substantive.

---

## Precise Theorem Targets

You should prove at least **3 deep theorems**, and they must not be trivialized by computation. Use induction, `rcases`, `by_contra`, structured `calc`, and categorical reasoning.

### Theorem 1: One-dimensional probe suffices in finite-dimensional vector spaces

**Mathematical statement.**
Let `k` be a field. In the category of finite-dimensional `k`-vector spaces, the one-dimensional space `k` is a separating probe. Hence the probe complexity is at most `1`, and in any nontrivial such category it is exactly `1`.

The key mechanism is that maps `k ⟶ V` are in bijection with vectors of `V`; equality on all such probes forces equality on all vectors.

**Lean 4 target signature (suggested):**
```lean
theorem FVect_singleton_precompose_separating
  (k : Type u) [Field k] :
  PrecomposeSeparatingFamily
    ({⟨ModuleCat.of k k⟩} : Finset (ModuleCat k)) := by
  ...
```

A more practical theorem, avoiding finite-dimensional subcategory issues, is:

```lean
theorem ModuleCat_field_k_precompose_separates
  (k : Type u) [Field k] :
  ∀ ⦃V W : ModuleCat k⦄ (f g : V ⟶ W),
    (∀ h : ModuleCat.of k k ⟶ V, h ≫ f = h ≫ g) → f = g := by
  ...
```

Then derive the finite-dimensional corollary if you formalize the relevant subcategory.

**Breakthrough significance.**
This identifies probe complexity with “rank-one tomography” in linear algebra: every linear transformation is recoverable from its action on one-dimensional probes. It is the first nontrivial bridge from the catalog’s abstract probe formalism to classical algebra.

---

### Theorem 2: Finite semisimple categories admit a separating family given by simples

**Mathematical statement.**
Let `C` be a semisimple abelian category with finitely many isomorphism classes of simple objects, represented by a family `S = {S₁, …, Sₙ}`. Then `S` is precomposition-separating. Consequently,
\[
\operatorname{categoryProbeComplexity}(C) \le n.
\]

The proof idea: if `f ≠ g`, then `d := f - g ≠ 0`. Since `d` is nonzero, its image is a nonzero object. In a semisimple category, the image contains a simple subobject `Sᵢ`, and semisimplicity lets one lift a nonzero map from some simple into the domain detecting `d`.

**Lean 4 target signature (schematic):**
```lean
theorem semisimple_simples_precompose_separating
  {C : Type u} [Category.{v} C] [Abelian C]
  (S : Finset C)
  (hS_simple : ∀ X, X ∈ S → Simple X)
  (hS_complete : ∀ X : C, Simple X → ∃ Y ∈ S, Nonempty (Y ≅ X))
  (hsemisimple : ∀ X : C, -- choose a formal semisimplicity hypothesis
      ...)
  :
  PrecomposeSeparatingFamily S := by
  ...
```

If a fully general semisimple-category interface is too expensive in Lean, specialize to a concrete semisimple category already available in Mathlib, e.g. finite-dimensional modules over a field, or representations of a finite group in the semisimple characteristic-not-dividing case once the algebraic infrastructure permits.

**Breakthrough significance.**
This would establish probe complexity as a representation-theoretic invariant controlled by simple objects in semisimple worlds. It is the categorical analogue of reconstructing a state from irreducible measurement channels.

---

### Theorem 3: Lower bound via simple-object necessity in semisimple categories

**Mathematical statement.**
Let `C` be a semisimple abelian category and let `S₁, …, Sₙ` be representatives of distinct simple isomorphism classes. Any precomposition-separating family must contain, up to isomorphism, every simple class. Therefore:
\[
n \le \operatorname{categoryProbeComplexity}(C).
\]
Combined with Theorem 2, this yields exact equality:
\[
\operatorname{categoryProbeComplexity}(C) = n.
\]

**Lean 4 target signature (schematic):**
```lean
theorem semisimple_probe_complexity_lower_bound
  {C : Type u} [Category.{v} C] [Abelian C]
  (simples : Finset C)
  (hpair : ∀ X ∈ simples, ∀ Y ∈ simples, X ≠ Y → ¬ Nonempty (X ≅ Y))
  (hsimple : ∀ X, X ∈ simples → Simple X)
  (hcomplete : ∀ X : C, Simple X → ∃ Y ∈ simples, Nonempty (Y ≅ X))
  :
  ∀ T : Finset C, PrecomposeSeparatingFamily T → simples.card ≤ T.card := by
  ...
```

You may need a weaker but still substantial theorem if exact cardinal lower bounds are too difficult in full generality. A highly acceptable substitute is:

> For each simple object `S`, any separating family must contain some probe admitting a nonzero morphism into `S`, and in semisimple categories this forces coverage of each simple isomorphism class.

**Breakthrough significance.**
Upper bounds alone are cheap. A lower bound showing **minimality** is what upgrades probe complexity from an ad hoc notion to a genuine dimension-like invariant.

---

## Strong Secondary Theorem Targets

If the full semisimple exact-equality theorem is too ambitious in one cycle, prove one or more of these as stepping stones.

### Theorem 4: Monotonicity under faithful exact functors
If `F : C ⥤ D` is faithful and reflects equality of morphisms appropriately, then separating families in `C` push forward to separating families in `D`, or conversely pull back under suitable density assumptions.

This would connect probe complexity to categorical embeddings and realization functors.

Possible signature:
```lean
theorem PrecomposeSeparatingFamily.map_of_faithful
  {C D : Type u} [Category C] [Category D]
  (F : C ⥤ D) [Faithful F]
  ...
  : PrecomposeSeparatingFamily S → PrecomposeSeparatingFamily (S.image F.obj) := by
  ...
```

### Theorem 5: Product / biproduct subadditivity
For categories with finite products or biproducts, show probe complexity behaves subadditively under categorical products or finite direct-sum decompositions of “component theories”.

### Theorem 6: Representation category of a finite group over a splitting field
For finite `G` and field `k` with `char k ∤ |G|`, prove the probe complexity of the semisimple representation category is the number of irreducible `k`-representations up to isomorphism.

This is the first true representation-theoretic application.

---

## Proof Strategy Architecture

You must present and execute **2–3 viable proof routes**. Do not just mention them; choose one as primary and explain why.

### Strategy A: Direct Yoneda-style vector test maps for `ModuleCat k`
**Best for Theorem 1.**
1. Show any element `v : V` determines a linear map `hv : k ⟶ V` by `a ↦ a • v`.
2. Assume `h ≫ f = h ≫ g` for all `h : k ⟶ V`.
3. Evaluate on `1 : k`; then for each `v`, the associated `hv` gives `f(v) = g(v)`.
4. Conclude equality of linear maps by extensionality.

**Why promising:** It is concrete, elegant, and directly formalizable in Mathlib’s linear algebra ecosystem.

### Strategy B: Image-of-difference and simple subobject detection
**Best for semisimple / abelian results.**
1. Given `f ≠ g`, set `d = f - g`; by contradiction assume all probes fail to distinguish them.
2. Since `d ≠ 0`, its image is nonzero.
3. In a finite-length or semisimple category, choose a simple subobject of `image d`.
4. Pull this simple back to obtain a probe map detecting `d`, contradicting separation failure.

**Why promising:** This route explains the invariant conceptually: probes detect nonzero images through simple constituents. It is the right bridge to Jordan–Hölder theory.

### Strategy C: Decomposition into simple summands and matrix blocks
**Best for explicit semisimple categories like `Rep(G)` or finite semisimple module categories.**
1. Decompose every object into finite direct sums of simple representatives.
2. Express morphisms as block matrices between isotypic components.
3. Show precomposition by inclusions of simple summands detects each block.
4. Infer that one representative of each simple class suffices and is necessary.

**Why promising:** More computational than Strategy B, but often easier in concrete semisimple settings and naturally yields algorithms.

**Recommendation:**  
- Use **Strategy A** to secure a fully formalized flagship theorem immediately.  
- Use **Strategy B** for the conceptual general theorem.  
- Use **Strategy C** for a computable representation-theoretic demo and algorithm.

---

## Cross-Domain Connections You Must Explicitly Develop

At least one theorem or extended discussion must connect this project to another mathematical domain.

### 1. Homological algebra
Probe complexity should interact with:
- simple objects,
- composition series,
- Jordan–Hölder length,
- Loewy filtrations,
- semisimplicity.

Potential claim to formulate:
> In finite-length categories, probe complexity is bounded above by the number of simple isomorphism classes appearing in generators.

This is a bridge from probe complexity to length theory.

### 2. Algebraic geometry / sheaf theory
Interpret probes as **test objects** in a sheaf category. A small separating family of probes resembles a finite atlas of local models. Even if full sheaf-category formalization is out of scope, the paper must articulate this direction.

### 3. Mathematical physics / TQFT / tomography
This is not rhetorical garnish. In TQFT and quantum information, states and operators are determined by responses to test systems. Probe complexity becomes a **categorified measurement complexity**. In semisimple tensor categories, simples play the role of elementary particle types / superselection sectors.

### 4. Computational complexity
The phrase “categorical dimension” is not metaphorical. Probe complexity is a **description complexity of morphism discrimination**. This suggests links to:
- query complexity,
- black-box operator identification,
- minimal measurement bases,
- compressed sensing in algebraic settings.

You should include these connections in `RESEARCH_PAPER.md` and `ARTICLE.md`.

---

## Application Keywords

Include these explicitly in your writeup and metadata-like headings where appropriate:

**Application keywords:** categorical dimension, probe complexity, semisimple category, simple objects, Jordan–Hölder, representation theory, finite group representations, categorical tomography, Yoneda detection, operator identification, measurement complexity, TQFT, sheaf-theoretic probes, homological algebra, black-box morphism reconstruction.

---

## Computational / Algorithmic Deliverable

You are required to produce not only theorems but a **verified algorithm**.

### Algorithm target
Given a finite semisimple category presented by:
- a finite list of simple representatives,
- decomposition data for objects into simples,
- matrix/block descriptions of morphisms,

implement an algorithm that:
1. constructs the candidate probe basis from simple representatives,
2. tests whether a proposed family is separating,
3. computes the resulting probe complexity in examples.

At minimum, implement this concretely for:
- finite-dimensional vector spaces over `𝔽_q`,
- small semisimple representation categories of finite groups where practical,
- small module categories over finite rings for exploratory experiments.

### Expected theorem-to-algorithm bridge
The theorem should certify correctness of the algorithm:
- if the category is semisimple and complete simple data are supplied, the algorithm returns the exact probe complexity.

### `demo.py`
Your Python demo should:
- let the user choose examples (`FVect(F_q)`, small `Rep(G)`, small `Mod_R` samples),
- display candidate probes,
- test separation on randomly generated morphism pairs,
- compare empirical separation with theorem-predicted complexity.

This is not optional.

---

## Concrete Experimental Program

You must test the conjectural landscape computationally.

### Required tests
1. **`FVect(𝔽_q)`**
   - Expected: probe complexity `= 1`.
   - Test for several small `q`.
   - Empirically verify that the 1-dimensional probe distinguishes random linear maps.

2. **`Rep(G)` over `𝔽_q` with `q ∤ |G|`**
   - Expected: probe complexity `= number of irreducible representations`.
   - Start with groups like `C₂`, `C₃`, `S₃` when feasible.

3. **`Mod_R` for small rings**
   - Explore rings such as `ℤ/4ℤ`, `𝔽_q[x]/(x^2)`, triangular matrix rings.
   - This is where semisimplicity fails and the invariant becomes scientifically interesting.

### Falsifiable conjecture
State at least one computationally testable conjecture that could fail.

A strong option:

> **Conjecture (finite-length probe = simple support number).**  
> In every finite-length abelian category with finitely many simple isomorphism classes, the probe complexity equals the number of simple isomorphism classes.

**Clear disproof test:** compute examples in non-semisimple module categories over small Artinian rings. A single category where extensions force additional probes or where fewer probes suffice refutes the conjecture.

A more nuanced backup conjecture:

> **Conjecture (semisimple exactness, finite-length upper bound).**  
> In semisimple finite-length categories, probe complexity equals the number of simple isomorphism classes; in arbitrary finite-length categories, it is at most that number.

Again: test with small non-semisimple rings.

---

## Lean Formalization Guidance

Be strategic. Do not overcommit to the most abstract universe if Mathlib infrastructure is thin. It is perfectly acceptable to establish the invariant first in `ModuleCat k` and then formulate more abstract conjectures carefully.

### Recommended formalization ladder
1. Define `PrecomposeSeparatingFamily`.
2. Prove the `ModuleCat k` / field theorem.
3. Derive complexity `≤ 1`, and if possible `= 1` under a nontriviality assumption.
4. Formalize a semisimple-category theorem if existing abstractions suffice.
5. Otherwise formalize a concrete semisimple instance, e.g. finite products of copies of `ModuleCat k` or explicitly decomposed objects.

### Important implementation caution
Do not let quotient-by-isomorphism machinery consume the project. If necessary:
- work with chosen representatives,
- state “complete family of simple representatives” as data,
- prove exactness relative to that chosen family.

This is mathematically honest and Lean-efficient.

---

## Minimum Theorem List You Must Deliver in the Lean File

Your Lean file must contain at least **three nontrivial proved theorems** along lines such as:

1. `ModuleCat_field_k_precompose_separates`
2. `categoryProbeComplexity_ModuleCat_field_eq_one` or at least `≤ 1` plus a nontrivial lower bound
3. A semisimple/simple-probe theorem or a substantial lower-bound theorem about necessity of simple classes

All should require real proof structure, not computation.

---

## What Makes This Revolutionary

If successful, this work does all of the following:

- introduces a **new categorical invariant** with operational meaning,
- links morphism discrimination to **simple objects and decomposition theory**,
- creates a bridge from category theory to **representation theory, tomography, and complexity theory**,
- suggests a new way to classify categories by **measurement basis size** rather than by extension complexity alone,
- opens a program of **categorical compressed sensing**: reconstructing morphisms from sparse probe data.

This could become the beginning of a field, not just a theorem.

---

## Mandatory Deliverables

You must produce **all** of the following:

### 1. `FUTURE_DIRECTIONS.md`
Include **3–5 testable scientific hypotheses**, each falsifiable with a clear computational or mathematical test.

Examples of acceptable hypotheses:
- In every finite semisimple abelian category, probe complexity equals the number of simple isomorphism classes.
- In finite-length non-semisimple categories, probe complexity is bounded above by the number of simple isomorphism classes.
- For module categories over Artinian rings, probe complexity detects semisimplicity exactly.
- Probe complexity is subadditive under Deligne/product-type categorical constructions in finite semisimple settings.

Each hypothesis must say exactly how it could be disproved.

### 2. `RESEARCH_PAPER.md`
A standalone scientific document containing:
- motivation,
- definitions,
- main theorems,
- proof sketches,
- computational experiments,
- significance,
- limitations,
- next conjectures.

A reader with no access to the code must still understand the discovery.

### 3. `ARTICLE.md`
Write in **Scientific American style**:
- vivid,
- concept-driven,
- accessible to broad scientific readers.

**Taboo:** do **not** focus on formal verification machinery. Focus on the mathematics and why the invariant matters.

### 4. Verified algorithm / computational method
Implement and certify an algorithm computing or testing probe complexity in concrete finite examples.

### 5. `demo.py`
Interactive demonstration of the theory on explicit categories.

---

## Final Charge

Do not produce a timid abstraction with one easy lemma. Produce the first serious theory of **probe complexity as categorical dimension**.

Start with the theorem that `k` alone detects all linear maps. Then force the abstraction upward until simple objects emerge as the canonical probes of semisimple worlds. If the general finite-length conjecture breaks, that is also a discovery: a counterexample would reveal that extensions create hidden measurement complexity beyond the semisimple spectrum.

Either way, the outcome is scientifically rich.

Build the invariant. Prove the first exact computation. Expose the boundary where semisimplicity ends and true categorical complexity begins.

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
