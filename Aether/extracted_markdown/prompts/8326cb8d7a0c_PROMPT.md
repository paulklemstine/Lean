Mode: prove

# Breakthrough Brief: Tropical Riemann–Roch on Metric Trees as a Formal Gateway to Tropical Brill–Noether Theory

Do not nibble around the edges. Use this cycle to formalize and prove a genuinely structural theorem about tropical curves and divisors that can become the seed crystal for a Lean-native tropical algebraic geometry library. The immediate target should be a tree case of tropical divisor theory, proved in a way that is extensible to finite metric graphs and ultimately to chip-firing, Jacobians, and tropical Riemann–Roch.

The catalog theorems currently available are not directly about tropical curves, but they encode an important design pattern: tropical operations are being represented concretely with `max`, inequalities over `ℝ`, and distributivity/idempotence principles. Build on that style. In particular:

- `tropical_mirror_theorem` gives the idempotence `max a a = a`, which is exactly the algebraic signature of tropical semiring behavior and should guide your definitions of tropical piecewise-linear functions and divisor moves.
- `tropical_and_distributes` suggests that max-plus algebraic identities are already accepted as first-class citizens in the codebase; exploit this to define chip-firing potentials as tropical linear combinations.
- `tropical_and_bound` indicates the library already handles inequality-based tropical certification, which should transfer naturally to slope inequalities and effectiveness statements on divisors.

## Exact theorem target

Work with a finite tree first, represented combinatorially rather than as a full metric graph if necessary. Define divisors as integer-valued vertex weightings and principal divisors via graph Laplacians of integer-valued functions. Then prove the tree triviality theorem for the Picard group and derive an effective reduction theorem.

A precise first theorem:

```lean
def Divisor (V : Type _) := V → ℤ

def divisorDegree {V : Type _} [Fintype V] (D : Divisor V) : ℤ :=
  ∑ v, D v

def PrincipalDivisor {V : Type _} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) (f : V → ℤ) : Divisor V :=
  fun v => ∑ w in (G.neighborFinset v), (f w - f v)

def LinearEquivalent {V : Type _} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) (D₁ D₂ : Divisor V) : Prop :=
  ∃ f : V → ℤ, D₂ = D₁ + PrincipalDivisor G f
```

Then aim to prove:

```lean
theorem tree_divisor_equiv_singleton
    {V : Type _} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [Fintype V]
    (hconn : G.Connected)
    (htree : G.IsAcyclic)
    (D : Divisor V) :
    ∃ v : V, LinearEquivalent G D (fun w => if w = v then divisorDegree D else 0)
```

This is the combinatorial tropical statement that every divisor on a tree is linearly equivalent to a unique divisor concentrated at one vertex with the same degree. It is nontrivial, foundational, and exactly the right formal bridge from graph theory to tropical algebraic geometry.

Then push to the effective corollary:

```lean
theorem tree_degree_nonneg_has_effective_representative
    {V : Type _} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V)
    (hconn : G.Connected)
    (htree : G.IsAcyclic)
    (D : Divisor V)
    (hdeg : 0 ≤ divisorDegree D) :
    ∃ E : Divisor V, LinearEquivalent G D E ∧ (∀ v, 0 ≤ E v)
```

This is the genus-zero tropical Riemann–Roch shadow: on a tropical curve of genus 0, every divisor of nonnegative degree has effective rank at least its degree in the expected way. Even proving the existence of an effective representative is already mathematically meaningful and formally valuable.

If the above goes well, state and attempt the rank formula on trees:

```lean
def Effective {V : Type _} (D : Divisor V) : Prop := ∀ v, 0 ≤ D v

def DivisorRank {V : Type _} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) (D : Divisor V) : ℤ :=
  sSup {r : ℤ | -1 ≤ r ∧ ∀ E : Divisor V, divisorDegree E = r → Effective E →
    ∃ F : Divisor V, LinearEquivalent G (D - E) F ∧ Effective F}

theorem tree_rank_formula
    {V : Type _} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V)
    (hconn : G.Connected)
    (htree : G.IsAcyclic)
    (D : Divisor V) :
    DivisorRank G D = divisorDegree D
```

This exact signature may need adjustment because `sSup` over integers is awkward; if so, use a predicate-style rank statement instead. The mathematical content is what matters: genus-zero tropical Riemann–Roch in a fully combinatorial Lean form.

## Why this is a breakthrough

This is not “graphs with chips” as a toy exercise. It is the formal entrance ramp to tropical algebraic geometry in Lean:

- Trees are tropical genus-zero curves.
- Divisor linear equivalence via graph Laplacians is the combinatorial core of tropical Picard theory.
- The singleton-representative theorem is the genus-zero collapse of the Jacobian.
- The effective representative theorem is the first meaningful formal Riemann–Roch phenomenon in the tropical world.

Once this exists, Aristotle can move toward:
- reduced divisors,
- Dhar’s burning algorithm,
- tropical Jacobians,
- Baker–Norine Riemann–Roch,
- tropical Abel–Jacobi maps,
- and eventually tropical moduli and mirror-symmetric combinatorics.

This opens a field inside Lean rather than adding one more theorem to a file.

## Proof strategies

### Strategy A: Leaf-firing induction on finite trees
This is the most promising route.

1. Prove a leaf elimination lemma: in any finite connected acyclic graph with more than one vertex, there exists a leaf.
2. Show that chip content at a leaf can be transported to its unique neighbor by choosing a firing function supported at the leaf. Formally, construct `f : V → ℤ` with `f(leaf) = k` and `f = 0` elsewhere, and compute `PrincipalDivisor G f`.
3. Induct on the number of vertices. After moving all chips off a leaf, restrict the divisor to the smaller tree and iterate until only one vertex remains.

Why this is strongest:
- It avoids developing global Laplacian linear algebra too early.
- It yields explicit witnesses for linear equivalence, ideal for Lean.
- It naturally produces the effective representative theorem as a corollary.

### Strategy B: Laplacian exactness / kernel-image characterization
A more algebraic route.

1. Define the graph Laplacian `L : (V → ℤ) → Divisor V`.
2. Prove that on a connected tree, the cokernel modulo degree-zero divisors is trivial: every degree-zero divisor lies in `range L`.
3. Deduce that any divisor is equivalent to a degree-concentrated singleton by subtracting the chosen basepoint divisor.

Why this matters:
- It is conceptually cleaner and aligns with tropical Picard/Jacobian theory.
- It prepares the finite-graph generalization, where the cokernel becomes the Jacobian / critical group.
- It cross-pollinates with algebraic topology and spectral graph theory.

Risk:
- Integer linear algebra over finitely supported functions may create more formal overhead than the inductive route.

### Strategy C: Reduced divisors with a basepoint
A tropical-geometric route.

1. Define `q`-reduced divisors on a tree.
2. Prove existence and uniqueness of a `q`-reduced representative in each linear equivalence class.
3. Show that on a tree the unique `q`-reduced divisor of degree `d` is exactly `d • q`.

Why this is visionary:
- It is the right language for future Baker–Norine and tropical curve work.
- It aligns directly with divisor theory on tropical curves, not just graph combinatorics.

Risk:
- Uniqueness of reduced divisors may require substantial preliminary machinery.

Recommendation: execute Strategy A now, while designing definitions to permit later reinterpretation via Strategies B and C.

## Concrete formal subgoals

You should likely prove the following lemmas in sequence.

```lean
theorem principal_degree_zero
    {V : Type _} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) (f : V → ℤ) :
    divisorDegree (PrincipalDivisor G f) = 0
```

```lean
theorem linear_equiv_preserves_degree
    {V : Type _} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) {D E : Divisor V}
    (h : LinearEquivalent G D E) :
    divisorDegree D = divisorDegree E
```

```lean
theorem exists_leaf_of_tree
    {V : Type _} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) (hconn : G.Connected) (htree : G.IsAcyclic)
    (hcard : 1 < Fintype.card V) :
    ∃ v : V, (G.neighborFinset v).card = 1
```

```lean
theorem fire_leaf_moves_mass
    {V : Type _} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) {ℓ n : V}
    (hleaf : G.neighborFinset ℓ = {n}) (k : ℤ) :
    LinearEquivalent G
      (fun w => if w = ℓ then k else 0)
      (fun w => if w = n then k else 0)
```

The last lemma is the engine. Once it exists, the induction should be straightforward.

## Cross-domain connections you must exploit

Do not present this as isolated tropical graph theory. Make the bridges explicit in code comments and in `FUTURE_DIRECTIONS.md`.

1. **Spectral graph theory**  
   Principal divisors are Laplacian images. The tree theorem is a statement about exactness of the Laplacian on degree-zero divisors. This is the combinatorial precursor to effective resistance, critical groups, and discrete Hodge theory.

2. **Algebraic geometry**  
   Trees are tropical genus-zero curves. Your theorem is the tropical analog of the fact that `Pic^d(P¹)` is a point up to degree. This is the correct conceptual framing.

3. **Semiring/tropical algebra**  
   The existing catalog’s `max`-idempotence theorems suggest a broader architecture where tropical geometry is built from semiring principles. Divisors of tropical rational functions are the geometric shadow of max-plus piecewise-linear algebra.

4. **Theoretical computer science**  
   Chip-firing and reduced divisors connect to termination arguments, potential functions, and sandpile dynamics. This gives algorithmic content: normalization of divisors on trees is a certified algorithm.

5. **Mathematical physics**  
   Chip-firing is a discrete relaxation process; the Laplacian perspective links to energy minimization and electrical networks. This is the right language for future tropical-statistical mechanics interactions.

## Application keywords

Include these explicitly in your artifacts:
- tropical geometry
- divisors on graphs
- chip-firing
- graph Laplacian
- Baker–Norine
- Riemann–Roch
- Jacobian of a graph
- critical group
- genus-zero tropical curves
- discrete Hodge theory
- electrical networks
- certified normalization algorithm

## Lean design guidance

Use concrete types. A good first implementation is:
- `V` finite with `[Fintype V] [DecidableEq V]`
- `G : SimpleGraph V`
- divisors as `V → ℤ`
- effectiveness as pointwise nonnegativity
- principal divisors from neighbor sums

Prefer explicit finite sums over abstract linear algebra at first. Restrict to finite simple graphs. If metric graphs are too heavy, state clearly that this is the combinatorial model of tropical curves.

If proving `tree_rank_formula` is too expensive in one cycle, prioritize:
1. `principal_degree_zero`
2. `linear_equiv_preserves_degree`
3. `tree_divisor_equiv_singleton`
4. `tree_degree_nonneg_has_effective_representative`

That package is already a real theorem cluster.

## What to write besides Lean

You must produce `FUTURE_DIRECTIONS.md`, and it must contain 3–5 specific next theorems with exact statements, proof ideas, and cross-domain significance. At minimum, include:

1. A finite-graph extension: degree-zero divisors modulo principal divisors form the critical group / Jacobian.
2. Uniqueness of `q`-reduced divisors and formalization of Dhar’s burning algorithm.
3. Baker–Norine Riemann–Roch for finite graphs.
4. A bridge theorem identifying tree divisor normalization with a terminating chip-firing algorithm.
5. A semiring-level formulation relating tropical rational functions to principal divisors.

If possible, also produce `ARTICLE.md` explaining why the tree theorem is the tropical `P¹` Picard theorem in formalized mathematics.

## Call to arms

Do not settle for a decorative theorem about `max`. Build the first serious formal bridge between tropical geometry and divisor theory. The right result here is one that a mathematician would recognize as the beginning of a Lean-native tropical Brill–Noether program. Trees first, then the world.

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
