## Assignment: Homotopy Type Theory via Tropical Higher Inductive Types

**Mode:** `prove`

Prove genuinely new, non-trivial theorems in Lean 4 that extract a rigorous, computable “tropical shadow” of path structure. Do **not** attempt to formalize full HoTT or true higher inductive types inside Lean’s kernel. Instead, build a mathematically sharp surrogate theory on concrete combinatorial types (`Finset`, `List`, `Matrix`, weighted graphs, finitely supported functions) in which:

- “path types” are replaced by **min-plus equidistance relations**,
- “equivalences” are replaced by **weight-preserving bijections / tropical isometries**,
- “univalence” becomes the theorem that equality of tropical codes is equivalent to existence of a tropical isometry,
- higher constructors are modeled by quotient-free canonical normal forms wherever possible, to minimize sorry.

This is not a toy analogy. The goal is to create the first Lean-certified **computational skeleton of HoTT** in tropical algebra: a setting where identity, transport, and equivalence become decidable min-plus statements.

---

## Core Vision

Classical HoTT encodes identity via path spaces, but path spaces are topologically rich and computationally difficult. Your task is to show that for a large class of finitely generated combinatorial objects, there is a tropical shadow in which:

1. identity is replaced by a min-plus equidistance invariant,
2. equivalence is replaced by a computable tropical isometry,
3. a univalence-like principle becomes a decidable algebraic criterion.

If successful, this opens a field: **tropical synthetic homotopy**, where homotopy-theoretic structure is compressed into combinatorial optimization and min-plus linear algebra. This could connect type theory, shortest-path geometry, phylogenetics, program equivalence, and certified reasoning about state spaces.

---

## Mathematical Framing

Work with finite weighted structures first. A highly promising object class is finite tropical metric spaces encoded by symmetric matrices with zero diagonal and min-plus path closure. These are concrete enough for Lean, yet rich enough to support a univalence analogue.

Interpretation guide:

- **Type** ↦ finite weighted space / tropical code
- **Path between x and y** ↦ value of a tropical distance `d x y`
- **Indiscernibility / identity shadow** ↦ equidistance profile equality
- **Equivalence of types** ↦ bijection preserving tropical distance
- **Univalence shadow** ↦ equality of canonical tropical codes iff tropical isometry

This is the right level of abstraction: high enough to be revolutionary, low enough to formalize.

---

## Precise Theorem Targets

### Theorem 1: Tropical path-indiscernibility is an equivalence relation

Define the **equidistance profile** of a point `x` in a finite tropical metric space `d : α → α → ℝ` by
`profile d x = fun z => d x z`.

Define tropical path-indiscernibility:
`x ≈ₜ y :↔ ∀ z, d x z = d y z`.

Prove this is an equivalence relation, and that it coincides with equality under a separation axiom.

#### Lean 4 target shape
```lean
def TropicallyIndiscernible {α : Type*} (d : α → α → ℝ) (x y : α) : Prop :=
  ∀ z, d x z = d y z

theorem tropicallyIndiscernible_refl
    {α : Type*} (d : α → α → ℝ) (x : α) :
    TropicallyIndiscernible d x x := by

theorem tropicallyIndiscernible_symm
    {α : Type*} (d : α → α → ℝ) {x y : α} :
    TropicallyIndiscernible d x y → TropicallyIndiscernible d y x := by

theorem tropicallyIndiscernible_trans
    {α : Type*} (d : α → α → ℝ) {x y z : α} :
    TropicallyIndiscernible d x y →
    TropicallyIndiscernible d y z →
    TropicallyIndiscernible d x z := by

theorem tropicallyIndiscernible_eq_of_separating
    {α : Type*} [Fintype α] (d : α → α → ℝ)
    (hsep : ∀ x y, (∀ z, d x z = d y z) → x = y) :
    ∀ x y, TropicallyIndiscernible d x y ↔ x = y := by
```

### Why this matters
This gives a concrete replacement for identity/path collapse: two points are “the same in the tropical shadow” iff they have identical min-plus interaction with all other points. This is the first step toward a tropical identity type.

---

### Theorem 2: Canonical tropical codes classify finite weighted spaces up to tropical isometry

For a finite type `α`, encode each point by its row in the distance matrix. Define the **code** of the space to be the multiset / sorted list of all rows. Then prove:

> Two finite weighted spaces have equal canonical codes iff there exists a bijection preserving distances.

This is the true univalence-shadow theorem.

#### Lean 4 target shape
A practical implementation should avoid multisets if they become painful; use sorted lists over `Fin n → ℝ` or finite matrices over `Fin n`.

One robust version:
```lean
def IsTropicalIsometry {α β : Type*}
    (dα : α → α → ℝ) (dβ : β → β → ℝ) (f : α → β) : Prop :=
  Function.Bijective f ∧ ∀ x y, dβ (f x) (f y) = dα x y

theorem tropical_code_univalence_fin
    {n : ℕ}
    (D E : Matrix (Fin n) (Fin n) ℝ)
    (hDsym : D.IsSymm) (hEsym : E.IsSymm)
    (hDdiag : ∀ i, D i i = 0) (hEdiag : ∀ i, E i i = 0) :
    canonicalCode D = canonicalCode E ↔
    ∃ σ : Equiv.Perm (Fin n), ∀ i j, E (σ i) (σ j) = D i j := by
```

You will need to define `canonicalCode`. A promising definition is: sort the rows of `D` lexicographically after sorting entries relative to a fixed finite index order. If lexicographic sorting on real vectors is cumbersome, switch to `ℕ`-weighted spaces first:

```lean
theorem tropical_code_univalence_fin_nat
    {n : ℕ}
    (D E : Matrix (Fin n) (Fin n) ℕ)
    ... :
    canonicalCodeNat D = canonicalCodeNat E ↔
    ∃ σ : Equiv.Perm (Fin n), ∀ i j, E (σ i) (σ j) = D i j := by
```

This `ℕ` version is likely the best first breakthrough because decidability and sorting are much cleaner.

### Why this is a breakthrough
This is a concrete, machine-checkable univalence principle:
- equality of canonical tropical codes,
- equivalent to existence of a structure-preserving equivalence,
- fully decidable on finite spaces.

That is not just an analogy to HoTT. It is a new computational semantics for equivalence.

---

### Theorem 3: Tropical univalence is decidable

Once canonical codes are defined on finite weighted spaces, prove the existence of a decision procedure for tropical equivalence.

#### Lean 4 target shape
```lean
theorem tropical_univalence_decidable
    {n : ℕ} (D E : Matrix (Fin n) (Fin n) ℕ) :
    Decidable (∃ σ : Equiv.Perm (Fin n), ∀ i j, E (σ i) (σ j) = D i j) := by
```

A stronger formulation:
```lean
def tropicallyEquivalent
    {n : ℕ} (D E : Matrix (Fin n) (Fin n) ℕ) : Prop :=
  ∃ σ : Equiv.Perm (Fin n), ∀ i j, E (σ i) (σ j) = D i j

theorem tropicallyEquivalent_iff_code_eq
    {n : ℕ} (D E : Matrix (Fin n) (Fin n) ℕ) :
    tropicallyEquivalent D E ↔ canonicalCodeNat D = canonicalCodeNat E := by

instance tropicalEquivalentDecidable
    {n : ℕ} (D E : Matrix (Fin n) (Fin n) ℕ) :
    Decidable (tropicallyEquivalent D E) := by
```

### Why this matters
This theorem is the computational core: univalence becomes executable. It creates a bridge from type-theoretic identity to graph isomorphism-like but metric-sensitive decision procedures.

---

## Stronger Higher-Structure Target

If the above succeeds, define a **tropical pushout code** for finite weighted graphs/spaces and prove invariance under isometry. This would be a first tropical shadow of a higher inductive constructor.

### Candidate statement
Let `attachPoint : α → β → ...` define a gluing operation on finite weighted spaces along designated points. Prove:
```lean
theorem canonicalCode_gluing_invariant
    ...
    (hisoA : ...)
    (hisoB : ...) :
    canonicalCodeNat (glue D₁ E₁ i₁ j₁) =
    canonicalCodeNat (glue D₂ E₂ i₂ j₂) := by
```

This would model the idea that a higher inductive attachment has a tropical skeleton preserved by equivalence.

---

## Recommended Definitions

### 1. Tropical metric-like structure
Use a concrete predicate, not a typeclass at first:
```lean
def IsTropicalPseudoMetric {α : Type*} (d : α → α → ℝ) : Prop :=
  (∀ x, d x x = 0) ∧
  (∀ x y, d x y = d y x) ∧
  (∀ x y z, d x z ≤ d x y + d y z)
```

For finite matrix formulations:
```lean
def IsTropicalDistanceMatrix {n : ℕ} (D : Matrix (Fin n) (Fin n) ℕ) : Prop := ...
```

### 2. Equidistance profile
```lean
def profile {α : Type*} (d : α → α → ℝ) (x : α) : α → ℝ := fun z => d x z
```

### 3. Canonical code
For `Matrix (Fin n) (Fin n) ℕ`, define row extraction:
```lean
def rowVec {n : ℕ} (D : Matrix (Fin n) (Fin n) ℕ) (i : Fin n) : Fin n → ℕ := fun j => D i j
```
Then encode rows as lists in index order and sort the list of rows lexicographically.

This turns isometry classification into a theorem about row multisets.

---

## Building on Catalog Theorems

You have repeated availability of variants of:

```lean
tropical_plus_distributes_over_min
```

Use these not decoratively, but structurally. They are signals that the min-plus semiring viewpoint is already available in the catalog. In particular:

1. **For gluing constructions:** shortest-path distances after attachment will naturally be expressed via `min (a + c) (b + c)`-type formulas. Distribution of tropical addition over min will simplify canonical forms.

2. **For path composition semantics:** if a tropical “path constructor” is represented by concatenation cost, then composition corresponds to addition and path choice corresponds to `min`. The catalog theorem provides the algebraic normalization needed to prove invariance of path cost expressions.

3. **For decidability / normalization:** canonical codes for glued objects will often involve min-plus normal forms. Use the distribution theorem to prove extensional equality of these normal forms.

A concrete follow-up theorem using the catalog:
```lean
theorem glued_distance_normal_form
    (a b c : ℕ) :
    min (a + c) (b + c) = min a b + c := by
  simpa [Nat.add_comm, Nat.add_left_comm, Nat.add_assoc]
    using tropical_plus_distributes_over_min a b c
```
or the corresponding `ℝ` version.

This is not the end goal, but it is a critical local engine for all tropical path-composition arguments.

---

## Proof Strategy Architecture

### Strategy A: Finite matrix classification via row codes
**Most promising.** It avoids full type-theoretic overhead and gives a sharp univalence theorem.

1. **Define canonical row codes** for `Matrix (Fin n) (Fin n) ℕ` using ordered row lists.
2. **Prove permutation invariance:** applying a simultaneous row/column permutation preserves canonical code.
3. **Prove completeness:** if codes are equal, reconstruct a permutation by matching equal rows, using symmetry and diagonal-zero hypotheses to show row matching induces full matrix isometry.

Why this is best: everything is finite, decidable, and close to graph isomorphism technology. Lean handles `Fin n`, `Matrix`, permutations, and sorting well enough.

---

### Strategy B: Quotient by tropical indiscernibility, then classify separated spaces
1. Define `x ≈ₜ y` by equality of profiles.
2. Show this is an equivalence relation.
3. Work with spaces satisfying separation (`profile x = profile y → x = y`), and classify them by profile sets.
4. Derive univalence as “equality of profile sets iff isometry”.

Why this is powerful: it mirrors the HoTT intuition more faithfully. Identity is first weakened to indiscernibility, then sharpened by separation. It gives conceptual clarity and may generalize to pseudo-metrics and coarse spaces.

Risk: quotient constructions may create Lean friction. Prefer set-level/profile-level statements over actual quotient types if needed.

---

### Strategy C: Weighted graph semantics and tropical shortest paths
1. Start from finite weighted graphs with edge weights in `ℕ`.
2. Define tropical path distance as shortest path weight.
3. Prove graph isomorphisms preserve the induced distance matrix.
4. Show canonical shortest-path matrices classify graph skeletons up to tropical equivalence.

Why this is exciting: it connects directly to combinatorial homotopy, network science, phylogenetics, and verification. It also makes “path type” interpretation vivid.

Risk: shortest-path formalization may be heavier than matrix-first classification unless relevant graph infrastructure is already in the catalog/Mathlib.

---

## Cross-Domain Connections

This project should explicitly connect to at least one of the following domains:

### 1. Graph isomorphism and algorithmic symmetry
Your tropical univalence theorem is a metric-sensitive canonical labeling theorem. This links HoTT-style equivalence to canonical forms used in graph algorithms.

### 2. Phylogenetics
Tropical metrics already encode tree-like combinatorics. Tropical indiscernibility corresponds to taxon redundancy/equivalent placement. A decidable univalence theorem could classify phylogenetic skeletons.

### 3. Program semantics / verification
Weighted transition systems have shortest-path or cost-to-go metrics. Tropical equivalence becomes a decidable criterion for behavioral equivalence of states/modules.

### 4. Persistent homology / topological data analysis
Distance matrices are the input to Vietoris–Rips style constructions. Tropical shadows may preserve the combinatorial essence relevant to barcodes while discarding topological overhead.

### 5. Cryptography and scattering-style min-plus algebra
The catalog already hints at tropical cryptography/scattering duality. If equivalence of tropical codes is decidable, one can ask when tropical signatures are complete invariants versus one-way compressions.

---

## Concrete Lean 4 Deliverables

Produce one or more Lean files, for example:

- `Bridges/TropicalHoTT/TropicalIdentity.lean`
- `Bridges/TropicalHoTT/TropicalUnivalenceFinite.lean`
- `Bridges/TropicalHoTT/TropicalGluing.lean`

Include:
1. core definitions,
2. equivalence-relation theorems,
3. canonical-code invariance under permutation,
4. converse classification theorem,
5. decidability instance,
6. one bridge theorem to another domain.

---

## Suggested First Formal Theorem Sequence

A practical order that minimizes sorry:

1. Prove `TropicallyIndiscernible` is an equivalence relation.
2. Define `tropicallyEquivalent` on `Matrix (Fin n) (Fin n) ℕ`.
3. Prove permutation ⇒ code equality.
4. Define canonical row code with lists.
5. Prove code equality ⇒ existence of a permutation in small finite settings first (`n = 2, 3`) if needed.
6. Generalize to all `n`.
7. Add decidability.
8. Add gluing / higher-constructor shadow theorem.

If the full converse classification is difficult, first prove a weaker but still meaningful theorem:
```lean
theorem tropical_isometry_implies_code_eq ...
```
and then strengthen to iff.

---

## Breakthrough-Level Conjecture to Aim For

If momentum is strong, target this sharper theorem:

```lean
theorem tropical_univalence_separated_spaces
    {α β : Type*} [Fintype α] [Fintype β] [DecidableEq α] [DecidableEq β]
    (dα : α → α → ℕ) (dβ : β → β → ℕ)
    (hsepα : ∀ x y, (∀ z, dα x z = dα y z) → x = y)
    (hsepβ : ∀ x y, (∀ z, dβ x z = dβ y z) → x = y) :
    canonicalProfileCode dα = canonicalProfileCode dβ ↔
    Nonempty {f : α ≃ β // ∀ x y, dβ (f x) (f y) = dα x y} := by
```

This would be a true finite tropical analogue of univalence: equality of canonical identity data iff equivalence.

---

## What Would Make This Paradigm-Shifting

A successful result here would show that one can **extract a computationally decidable identity/equivalence calculus from homotopical ideas** by passing to tropical shadows. This could launch:

- tropical semantics for identity types,
- algorithmic univalence,
- canonical forms for finite metric/type structures,
- new interactions between type theory and optimization,
- formal bridges between HoTT intuition and combinatorial data science.

This is not “HoTT but tropicalized” as metaphor. It is a new doctrine: **equivalence as min-plus geometry**.

---

## Application Keywords

tropical geometry, homotopy type theory, univalence, finite metric spaces, min-plus algebra, canonical forms, graph isomorphism, weighted automata, shortest paths, phylogenetics, program equivalence, combinatorial homotopy, decidable equality, matrix classification, computational semantics

---

## Team Directive

Create a team to conduct research, brainstorm hypotheses, run experiments, validate data, update the knowledge base, and iterate forever.

Assign subteams:
- **Definitions Team:** canonical code design, profile encoding, finite-space abstractions.
- **Proof Team:** permutation invariance, converse reconstruction, decidability.
- **Bridge Team:** graph/phylogenetic/program-semantics applications.
- **Lean Engineering Team:** sorting lemmas, matrix row extraction, finite permutation infrastructure.

Use concrete types (`Nat`, `Real`, `Finset`, `Matrix`). Avoid trivial tautologies. Prefer `ℕ` first for decidability and canonical sorting, then lift to `ℝ` if the theorem architecture stabilizes.

---

## Required Closing Artifact

Produce a structured `FUTURE_DIRECTIONS.md` with **3–5 concrete breakthrough-level next steps**, such as:

1. tropical truncation levels (`(-1)`-truncation as profile collapse),
2. tropical pushouts / HIT constructors via weighted gluing,
3. tropical fundamental groupoid as shortest-path symmetry groupoid,
4. tropical sheaf semantics for local identity data,
5. certified algorithms for equivalence of weighted transition systems via tropical univalence.

Be specific. State theorem targets, not vague topics.

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

Research domain: Logic
Research mode: prove
