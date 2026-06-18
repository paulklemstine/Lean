## Assignment: Decomposition

Mode: **prove**

You are not being asked for a cosmetic refactor. You are being asked to turn “decomposition” into a mathematically sharp principle that can organize several disparate catalog results into a reusable architecture. The right target is a theorem that decomposes a global tropical/combinatorial object into directional local data and then reconstructs a global invariant. This is the kind of result that becomes infrastructure.

The strongest cold-start direction is to build a **directional decomposition theorem for tropical dragon dynamics**, then connect it to additive/probabilistic factorization principles and finite-generation phenomena. This leverages the one genuinely structural catalog theorem we have:

- `step_on_each_dir_is_translation` from `Algebra/TropicalDragon.lean`

and cross-pollinates with:

- `bayes_theorem` as a decomposition/reweighting identity,
- `idempotent_hilbert_basis_theorem` as a finite-generation/compression principle,
- `divisor_gap_theorem` as a discrete separation principle.

The meta-vision: prove that a complicated iterated system is determined by its one-step directional translation data, and formalize this as a decomposition theorem over `Finset Dir`. If successful, this opens a program in **tropical dynamics, idempotent finite-generation, and certifiable symbolic compression of discrete dynamical systems**.

---

## Primary Theorem Target

Define and prove a theorem of the following form in Lean 4.

### Mathematical statement

Let `Dir` be the direction type already present in `Algebra/TropicalDragon.lean`. Suppose each directional step acts by translation. Then any finite composition of directional steps acts by translation by the sum of its directional translation vectors. In particular, the global orbit map of any finite word in directions decomposes into an additive accumulation of local directional contributions.

This is not merely “composition of translations is translation.” The breakthrough is to package the theorem so that:

1. it is stated for an arbitrary finite directional word,
2. the displacement is extracted canonically,
3. the theorem becomes a reusable decomposition API for later tropical/dynamical work.

### Lean 4 formalization target

You will need to inspect the exact definitions in `Algebra/TropicalDragon.lean`, but the theorem should look as close as possible to one of these signatures.

If the state space is something additive like `ℤ × ℤ`, `Fin 2 → ℤ`, or another additive type:

```lean
theorem fold_steps_is_translation
    (t : Bool) :
    ∃ δ : Dir → State,
      (∀ d : Dir, ∀ x : State, step d t x = x + δ d) ∧
      ∀ (ds : List Dir), ∃ Δ : State,
        (∀ x : State, (ds.foldl (fun s d => step d t s) x) = x + Δ)
```

A stronger canonical version:

```lean
def dirDisp (t : Bool) (d : Dir) : State := ...

def wordDisp (t : Bool) (ds : List Dir) : State :=
  (ds.map (dirDisp t)).sum

theorem fold_steps_eq_translate_by_wordDisp
    (t : Bool) (ds : List Dir) (x : State) :
    (ds.foldl (fun s d => step d t s) x) = x + wordDisp t ds
```

If the actual theorem available is already existential over translations, package the displacement as a witness:

```lean
theorem exists_word_translation
    (t : Bool) (ds : List Dir) :
    ∃ Δ : State, ∀ x : State,
      (ds.foldl (fun s d => step d t s) x) = x + Δ
```

If `State` is not literally additive, replace `x + Δ` by the appropriate translation action, e.g. `Δ + x`, `x - Δ`, or an affine action. But keep the theorem canonical and compositional.

---

## Why this is a breakthrough

This theorem upgrades a one-step local fact into a finite-word decomposition principle. That matters because it turns a bespoke dynamical artifact into an algebraic object:

- words in directions become elements of a translation monoid;
- dynamics factor through a displacement map;
- orbit equivalence and periodicity reduce to vanishing of accumulated displacement;
- finite-generation questions become accessible via idempotent/Hilbert-basis style arguments.

This is the bridge from “interesting theorem in one file” to “new research program.”

It also creates a formal pathway toward:
- tropical symbolic dynamics,
- compression of iterated geometric rules,
- probabilistic reweighting of path ensembles,
- semiring-based dynamic programming over directional systems.

---

## Break the theorem into helper lemmas

You should aim for **3–8 helper lemmas**. A strong decomposition is:

### Helper Lemma 1: Extract a canonical displacement for one direction
Use `step_on_each_dir_is_translation` to define or obtain a displacement for each `d : Dir`.

Possible shape:
```lean
def dirDisp (t : Bool) (d : Dir) : State := ...

theorem step_eq_add_dirDisp
    (t : Bool) (d : Dir) (x : State) :
    step d t x = x + dirDisp t d
```

If the existing theorem is existential, use choice/classical locally but expose a clean API.

### Helper Lemma 2: Composition of two directional steps adds displacements
```lean
theorem step_step_eq_add_two_disps
    (t : Bool) (d₁ d₂ : Dir) (x : State) :
    step d₂ t (step d₁ t x) = x + (dirDisp t d₁ + dirDisp t d₂)
```

This is the atomic compositional law.

### Helper Lemma 3: Fold over a list preserves the additive decomposition
```lean
theorem foldl_steps_eq_add_sum
    (t : Bool) (ds : List Dir) (x : State) :
    (ds.foldl (fun s d => step d t s) x)
      = x + (ds.map (dirDisp t)).sum
```

This is the main induction engine.

### Helper Lemma 4: Empty and concatenated words
```lean
theorem wordDisp_nil (t : Bool) : wordDisp t [] = 0

theorem wordDisp_append
    (t : Bool) (ds₁ ds₂ : List Dir) :
    wordDisp t (ds₁ ++ ds₂) = wordDisp t ds₁ + wordDisp t ds₂
```

This upgrades the construction into a monoid homomorphism in spirit.

### Helper Lemma 5: Orbit equality criterion via equal displacement
```lean
theorem fold_steps_eq_iff_wordDisp_eq
    (t : Bool) (ds₁ ds₂ : List Dir)
    (h : wordDisp t ds₁ = wordDisp t ds₂) :
    ∀ x : State,
      (ds₁.foldl (fun s d => step d t s) x)
      =
      (ds₂.foldl (fun s d => step d t s) x)
```

This is where decomposition becomes a classification theorem.

### Helper Lemma 6: Periodicity criterion
```lean
theorem fold_steps_fixed_iff_zero_disp
    (t : Bool) (ds : List Dir) :
    (∀ x : State, (ds.foldl (fun s d => step d t s) x) = x)
    ↔ wordDisp t ds = 0
```

This is scientifically valuable: periodicity becomes linear algebra/additive combinatorics.

### Optional Helper Lemma 7: Finset/count decomposition
If `Dir` is finite and displacement depends only on direction counts:
```lean
theorem wordDisp_eq_sum_counts_smul
    (t : Bool) (ds : List Dir) :
    wordDisp t ds = ∑ d, (ds.count d) • dirDisp t d
```
Use only if instances and decidable equality cooperate.

---

## Precise theorem statement with Lean-oriented type signatures

Because the exact `State` and `step` definitions are unknown, you should adapt to the file’s concrete types. But the target should resemble this family:

```lean
-- Adapt `State` and additive notation to the actual file.
def wordDisp (t : Bool) (ds : List Dir) : State :=
  (ds.map (dirDisp t)).sum

theorem fold_steps_eq_translate_by_wordDisp
    (t : Bool) (ds : List Dir) (x : State) :
    (ds.foldl (fun s d => step d t s) x) = x + wordDisp t ds
```

and then the corollaries:

```lean
theorem wordDisp_append
    (t : Bool) (ds₁ ds₂ : List Dir) :
    wordDisp t (ds₁ ++ ds₂) = wordDisp t ds₁ + wordDisp t ds₂

theorem fold_steps_fixed_iff_wordDisp_eq_zero
    (t : Bool) (ds : List Dir) :
    (∀ x : State, (ds.foldl (fun s d => step d t s) x) = x)
      ↔ wordDisp t ds = 0
```

If the translation theorem is expressed using a predicate like `IsTranslation`, then formalize first:

```lean
def IsTranslation (f : State → State) : Prop :=
  ∃ Δ : State, ∀ x, f x = x + Δ
```

then prove:

```lean
theorem fold_steps_is_translation
    (t : Bool) (ds : List Dir) :
    IsTranslation (fun x => ds.foldl (fun s d => step d t s) x)
```

This weaker theorem is still meaningful and may be the right first formalization layer.

---

## Proof strategies

### Strategy A: Direct induction on the direction list
This is the most promising route.

1. **Base case**: `[]` gives identity, hence translation by `0`.
2. **Inductive step**: assume the tail acts by translation by `Δ`; combine with `step_eq_add_dirDisp` for the head and use associativity/commutativity of addition.
3. **Package the displacement canonically** as `wordDisp`.

Why this is most promising:
- It matches Lean’s strengths.
- It uses the catalog theorem in the simplest way.
- It yields a clean reusable API immediately.

### Strategy B: Build a monoid homomorphism from words to translations
Abstract the action of a direction word as an element of the endomorphism monoid of `State`, then show the image lands in the submonoid of translations.

1. Define `evalWord : List Dir → State → State`.
2. Prove translations are closed under composition.
3. Show each generator maps into that submonoid using `step_on_each_dir_is_translation`.

Why this is powerful:
- It reveals structure: words factor through a translation monoid.
- It prepares future work on quotienting by equal displacement, normal forms, and automata.

Why it is less immediately promising:
- It may require more infrastructure around submonoids of functions and extensionality.

### Strategy C: Count-vector decomposition over a finite direction type
If `Dir` has `Fintype` and `DecidableEq`, compress words to count vectors.

1. Show displacement depends only on direction multiplicities.
2. Rewrite `wordDisp` as a finite sum over `Dir`.
3. Derive orbit classification from count equality rather than word equality.

Why this is revolutionary:
- It collapses symbolic dynamics to finite-dimensional additive data.
- It hints at a Hilbert-basis/finitely-generated cone picture.

Why it is secondary:
- Requires more assumptions and list-count lemmas.
- Best attempted after Strategy A succeeds.

---

## How to build on the catalog theorems

### 1. `step_on_each_dir_is_translation`
This is the cornerstone. Do not merely invoke it ad hoc. Extract from it a canonical directional displacement API. The entire research value comes from turning that theorem into a compositional language.

### 2. `idempotent_hilbert_basis_theorem`
Use this conceptually, and if possible formally, to motivate a finite-generation corollary:

> The set of all attainable displacements from direction words should be studied as an idempotent/additive semigroup generated by finitely many directional displacements.

Even if you cannot fully prove the semiring theorem in this cycle, include a corollary or conjectural formal scaffold showing that reachable displacements are finitely generated by `{dirDisp t d | d ∈ univ}` when `Dir` is finite.

This is the deep bridge:
- local directional generators,
- global displacement semigroup,
- finite generation / basis extraction.

### 3. `bayes_theorem`
Use this as a cross-domain analogy and possible formal extension:
- directional decomposition is to dynamics what posterior factorization is to inference;
- a path probability on words should decompose into local contributions;
- future theorem: posterior over endpoint displacement can be computed by summing over words with equal `wordDisp`.

Even if no formal dependence occurs this cycle, articulate the bridge in `FUTURE_DIRECTIONS.md`.

### 4. `divisor_gap_theorem`
Use this as a separation principle:
- distinct displacement classes may induce orbit separation;
- if two words produce sufficiently separated arithmetic invariants, they cannot be orbit-equivalent.

This suggests future arithmetic-dynamical rigidity theorems.

### 5. `insufficient_qubits_theorem`
This is a conceptual bridge to resource lower bounds:
- if words compress to displacement vectors, then simulating the dynamics may require only the displacement summary, not the whole word;
- conversely, if richer invariants are needed, this can lead to lower-bound theorems on compressed representation size.

This is speculative but genuinely cross-domain.

---

## Cross-domain connections you should explicitly surface

### Tropical geometry
Translations are the primitive affine symmetries of tropical objects. A finite-word translation theorem says the dragon dynamics is secretly linear in the tropical/idempotent sense.

### Symbolic dynamics
Words in `Dir` define a shift-like symbolic system; `wordDisp` is a factor map from symbolic sequences to an additive state space.

### Semiring / idempotent algebra
The displacement semigroup generated by directions is a finite generator system, resonating with Hilbert-basis phenomena over idempotent structures.

### Probabilistic inference
A distribution on direction words pushes forward along `wordDisp`. This creates a tropical/probabilistic endpoint inference problem analogous to Bayesian marginalization.

### Complexity / compression
If endpoint behavior depends only on `wordDisp`, then long words admit compressed certificates. This suggests formal theorems on succinct verification of orbit properties.

---

## Concrete implementation guidance in Lean

1. **Inspect `Algebra/TropicalDragon.lean` first**:
   - exact type of `Dir`,
   - exact type of the state,
   - exact type of `step`,
   - exact statement of `step_on_each_dir_is_translation`.

2. **Avoid over-generalizing too early**:
   First prove the theorem in the native concrete type of the file.

3. **If the existing theorem is existential**, define:
   - `dirDisp` using `Classical.choose`,
   - `step_eq_add_dirDisp` via `Classical.choose_spec`.

4. **Prefer `List` before `Finset`**:
   The dynamics is word-ordered; `List` induction is the right first layer.
   Move to `Finset` only for count/compression corollaries.

5. **Minimize sorry by proving API lemmas in order**:
   one-step translation → two-step composition → fold over list → append law → fixed-point criterion.

6. **Use concrete types**:
   Keep statements over `List Dir`, `Nat`, `Int`, `Real`, `Finset`, or the file’s native state type. Do not drift into category-theoretic abstractions unless the file already supports them.

---

## Suggested file deliverables

Create a new file if needed, e.g.
- `Algebra/TropicalDragonDecomposition.lean`

or extend the existing file if the architecture is already there.

Include:
- the main theorem,
- 3–8 helper lemmas,
- at least one nontrivial corollary (`append`, `fixed_iff_zero`, or orbit equality from equal displacement).

If possible, add:
- a small theorem showing reachable displacements form a finitely generated additive set when `Dir` is finite.

---

## Ambitious extension theorem

If the main theorem lands cleanly, push once more:

### Finite-generation corollary
If `Dir` is finite, the set of all finite-word displacements is generated by the finite set of one-step displacements.

Lean-style target:
```lean
theorem reachable_displacement_finitely_generated
    (t : Bool) :
    ∃ S : Finset State,
      ∀ Δ : State,
        (∃ ds : List Dir, wordDisp t ds = Δ) →
        Δ ∈ additiveClosure ↑S
```

You may need to define an appropriate closure notion depending on `State`. If too heavy, state and prove a simpler concrete version:
```lean
theorem exists_count_representation
    (t : Bool) (ds : List Dir) :
    ∃ n : Dir → ℕ, wordDisp t ds = ∑ d, n d • dirDisp t d
```

This is already a real bridge to Hilbert-basis thinking.

---

## What would make this field-opening

A successful cycle here does three things:

1. **Creates a certified decomposition calculus** for a nontrivial dynamical object.
2. **Shows symbolic dynamics can collapse to additive invariants** in Lean, opening formal tropical dynamics.
3. **Seeds a new line connecting tropical geometry, Bayesian aggregation, and semiring finite generation**.

That is not incremental. That is infrastructure for a new theory.

---

## Application keywords

tropical dynamics, symbolic dynamics, translation invariance, finite-word decomposition, additive invariants, idempotent algebra, Hilbert basis, semiring geometry, orbit classification, periodicity detection, compressed certification, Bayesian path aggregation, discrete dynamical systems, formal verification, Lean 4, Mathlib

---

## Required output artifacts

You must produce:

1. **Lean 4 code** proving the helper lemmas and the strongest main theorem you can certify.
2. **FUTURE_DIRECTIONS.md** with **3–5 concrete next theorems**, each including:
   - exact theorem statement,
   - proof strategy,
   - cross-domain significance.

The `FUTURE_DIRECTIONS.md` must include at least:
- one theorem about probabilistic pushforwards along `wordDisp`,
- one theorem about finite generation / Hilbert-basis structure,
- one theorem about periodicity or orbit classification,
- one theorem about arithmetic separation or compression complexity.

Do not write a generic wishlist. Write the next research program.

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

Research domain: Algebra
Research mode: prove
