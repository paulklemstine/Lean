## Assignment: Circuit Lower Bounds from Tropical Spectral Theory

**Mode: prove**

Aristotle, do not treat this as an incremental “complexity via tropical methods” exercise. The real target is a new bridge theorem: **extract lower bounds on computational depth from min-plus linear algebraic obstructions** in a way that is both formally certifiable in Lean 4 and conceptually strong enough to suggest a new route toward class separation. The breakthrough is not merely another depth measure; it is a **spectral semantics of circuits** where obstruction to shallow computation appears as a tropical eigenvalue/permanent phenomenon.

Your task is to formalize and prove the first nontrivial instances of this program using concrete finite matrices over `ℕ` or `ℝ`, finite DAG-style circuit encodings, and depth functionals that are actually provable in Mathlib.

---

## Core Breakthrough Goal

Build a Lean-certified theorem schema showing that for a class of finite circuit matrices `M`, a tropical spectral obstruction (expressed via min-plus cycle means, diagonal gap conditions, or min-plus permanent lower bounds) implies a **lower bound on circuit depth**. The theorem does not need to separate `P` from `NP` today; it must establish a rigorous and reusable bridge:

> **tropical matrix invariant** ⟹ **depth lower bound for encoded computation**

This opens a field: **idempotent complexity theory**, where tropical linear algebra supplies machine-checkable obstructions to small-depth computation.

---

## Precise Theorem Targets

You should define a concrete notion of circuit matrix first. The cleanest formal starting point is a weighted adjacency matrix of a finite acyclic layered computation graph.

Let:
- `n : ℕ`
- `M : Matrix (Fin n) (Fin n) ℕ` or `ℝ`
- `depthOfMatrix M : ℕ` be the longest-path depth of the directed graph encoded by finite weights satisfying your admissibility conditions
- `minPlusPerm M : ℕ∞` or `WithTop ℕ` be the min over permutations of assignment costs
- `diagGap M : ℕ` or `ℝ` be a tropical spectral-gap surrogate such as
  `min off-diagonal weight - min diagonal weight`, or a layered separation quantity
- `LayeredCircuitMatrix M` be a predicate asserting upper-triangular / acyclic / layer-respecting structure

You should prove at least one theorem in each of the following two families.

### Theorem A: Min-plus permanent controls depth

A concrete first statement:

```lean
def LayeredCircuitMatrix {n : ℕ} (M : Matrix (Fin n) (Fin n) ℕ) : Prop := 
  ∀ i j, j ≤ i → M i j = 0

def depthOfMatrix {n : ℕ} (M : Matrix (Fin n) (Fin n) ℕ) : ℕ :=
  -- longest strictly increasing reachable chain, to be defined

def minPlusPerm {n : ℕ} (M : Matrix (Fin n) (Fin n) ℕ) : ℕ :=
  Finset.inf' Finset.univ
    (by simp)
    (fun σ : Equiv.Perm (Fin n) =>
      ∑ i, M i (σ i))
```

Target theorem:

```lean
theorem minPlusPerm_le_depth_bound
  {n : ℕ} (M : Matrix (Fin n) (Fin n) ℕ)
  (hM : LayeredCircuitMatrix M) :
  minPlusPerm M ≤ n * depthOfMatrix M
```

This is the entry theorem. It is not yet super-polynomial, but it creates the certified bridge from a tropical matrix invariant to depth.

Then push to a nontrivial corollary for an explicit language family encoded by matrices `M_n`:

```lean
theorem explicit_family_depth_lower_bound
  (F : ℕ → Σ n, Matrix (Fin n) (Fin n) ℕ)
  (h_layered : ∀ k, LayeredCircuitMatrix (F k).2)
  (h_perm_growth : ∀ k, k^2 ≤ minPlusPerm (F k).2) :
  ∀ k, k ≤ depthOfMatrix (F k).2
```

or a logarithmic/exponential variant depending on your normalization. The point is: **growth of min-plus permanent forces depth growth**.

### Theorem B: Tropical gap obstruction implies depth lower bound

You likely need a more tractable spectral invariant than a full tropical eigenvalue formalization in the first pass. Define a “gap” quantity for layered matrices that measures how much more expensive nontrivial transitions are than layer-preserving ones.

For example:

```lean
def tropicalGap {n : ℕ} (M : Matrix (Fin n) (Fin n) ℕ) : ℕ :=
  sInf ((Finset.univ.product Finset.univ).image (fun p => M p.1 p.2))
  - sInf (Finset.univ.image (fun i => M i i))
```

Then prove a theorem of the form:

```lean
theorem tropicalGap_depth_lb
  {n : ℕ} (M : Matrix (Fin n) (Fin n) ℕ)
  (hM : LayeredCircuitMatrix M)
  (hgap : d ≤ tropicalGap M) :
  d ≤ depthOfMatrix M + 1
```

A stronger and more visionary version, if definitions cooperate:

```lean
theorem spectral_gap_implies_depth_obstruction
  {n : ℕ} (M : Matrix (Fin n) (Fin n) ℝ)
  (hM : LayeredCircuitMatrixReal M)
  (hacyc : AcyclicSupport M)
  (hsep : γ ≤ tropicalSpectralGap M) :
  complexityDepth M ≥ ⌈γ⌉
```

Even if the full “tropical eigenvalue” notion is difficult in Lean this cycle, define a **provable surrogate** and explicitly frame it as the first certified spectral obstruction theorem.

---

## Why This Would Be a Breakthrough

Complexity lower bounds usually rely on combinatorial restrictions, communication arguments, switching lemmas, monotone measures, or algebraic rank methods. What is missing is a robust, machine-verifiable language connecting:

- **circuit structure**
- **weighted path geometry**
- **idempotent spectral invariants**
- **depth obstructions**

If you prove even a first-generation theorem saying that a tropical permanent or gap invariant lower-bounds circuit depth for explicit matrix-encoded computations, you create a new program:

1. **Tropical complexity measures** become formal lower-bound tools.
2. **Constructive obstructions** replace existential counting arguments.
3. **Lean-certified lower bounds** become plausible for explicit families.
4. This opens the possibility of transporting ideas from:
   - max-plus control theory,
   - scheduling theory,
   - tropical geometry,
   - formal language growth,
   into structural complexity.

This is exactly the kind of theorem that makes a complexity theorist say: “I did not expect idempotent spectral theory to say anything concrete about depth.”

---

## Build Explicitly on Catalog Theorems

You are not starting from nothing. Use the catalog results as scaffolding:

1. **`tropical_plus_distributes_over_min`**
   - Use this to normalize min-plus expressions and simplify path-cost recurrences.
   - It should become a rewriting lemma in the algebraic core of `minPlusPerm` or path composition.

2. **`spectral_gap_lower_bound`**
   - Even if stated in a different context, mine its proof pattern.
   - Look for a reusable inequality skeleton: gap parameter gives lower bound on a structural quantity.
   - Abstract that architecture to tropical matrices.

3. **`tropical_and_bound`**
   - This may encode a compositional lower-bound phenomenon.
   - Use it to model how combining subcircuits cannot reduce the tropical obstruction below the minimum of constituent costs.

4. **`exponential_space_linear_depth`**
   - This is strategically important: it suggests a complexity-theoretic transfer theorem already exists in the catalog.
   - Connect your matrix depth lower bound to this theorem to derive a corollary for explicit high-space computations.

5. **`tropical_layer_depth_lb`**
   - This is likely your nearest neighbor.
   - Generalize or repackage it as the core inductive lemma relating layer semantics to path-length or tropical cost.
   - If this theorem already proves a lower bound from tropical layering, your mission is to **upgrade it to a spectral/permanent statement**.

---

## Lean 4 Type Signatures to Aim For

These signatures are deliberately concrete and should be adapted as needed.

```lean
import Mathlib.Data.Matrix.Basic
import Mathlib.Data.Matrix.Notation
import Mathlib.Data.Finset.Basic
import Mathlib.GroupTheory.Perm.Fin
import Mathlib.Data.Real.Basic
import Mathlib.Data.Nat.Basic
import Mathlib.Order.MinMax
```

### Core definitions

```lean
def supportEdge {n : ℕ} (M : Matrix (Fin n) (Fin n) ℕ) (i j : Fin n) : Prop :=
  0 < M i j

def LayeredCircuitMatrix {n : ℕ} (M : Matrix (Fin n) (Fin n) ℕ) : Prop :=
  ∀ i j, supportEdge M i j → i < j

def pathCost {n : ℕ} (M : Matrix (Fin n) (Fin n) ℕ) : List (Fin n) → ℕ
  | [] => 0
  | [_] => 0
  | i :: j :: t => M i j + pathCost M (j :: t)

def admissiblePath {n : ℕ} (M : Matrix (Fin n) (Fin n) ℕ) : List (Fin n) → Prop
  | [] => True
  | [_] => True
  | i :: j :: t => supportEdge M i j ∧ admissiblePath M (j :: t)

def depthOfMatrix {n : ℕ} (M : Matrix (Fin n) (Fin n) ℕ) : ℕ :=
  sSup {d | ∃ p : List (Fin n), admissiblePath M p ∧ p.length = d + 1}

def permCost {n : ℕ} (M : Matrix (Fin n) (Fin n) ℕ) (σ : Equiv.Perm (Fin n)) : ℕ :=
  ∑ i, M i (σ i)

def minPlusPerm {n : ℕ} (M : Matrix (Fin n) (Fin n) ℕ) : ℕ :=
  Finset.inf' Finset.univ (by simp) (permCost M)

def tropicalGap {n : ℕ} (M : Matrix (Fin n) (Fin n) ℕ) : ℕ :=
  (Finset.univ.product Finset.univ).inf' (by simp) (fun p => M p.1 p.2) -
  Finset.univ.inf' (by simp) (fun i => M i i)
```

### Main theorem candidates

```lean
theorem path_length_le_depth
  {n : ℕ} {M : Matrix (Fin n) (Fin n) ℕ} {p : List (Fin n)}
  (hp : admissiblePath M p) :
  p.length ≤ depthOfMatrix M + 1
```

```lean
theorem minPlusPerm_le_depth_bound
  {n : ℕ} (M : Matrix (Fin n) (Fin n) ℕ)
  (hM : LayeredCircuitMatrix M)
  (hpos : ∀ i j, supportEdge M i j → 1 ≤ M i j) :
  minPlusPerm M ≤ n * depthOfMatrix M
```

```lean
theorem tropicalGap_depth_lb
  {n : ℕ} (M : Matrix (Fin n) (Fin n) ℕ)
  (hM : LayeredCircuitMatrix M)
  (hdiag : ∀ i, M i i = 0)
  (hoff : ∀ i j, i ≠ j → d ≤ M i j) :
  d ≤ depthOfMatrix M + 1
```

```lean
theorem explicit_language_family_superlinear_depth
  (F : ℕ → Σ n, Matrix (Fin n) (Fin n) ℕ)
  (h_layered : ∀ k, LayeredCircuitMatrix (F k).2)
  (h_gap : ∀ k, k ≤ tropicalGap (F k).2) :
  ∀ k, k ≤ depthOfMatrix (F k).2 + 1
```

If “super-polynomial” is too ambitious for the first fully formal theorem, prove the strongest unconditional asymptotic statement your definitions support for an explicit family. Then state the super-polynomial separation as a conjectural extension in `FUTURE_DIRECTIONS.md`.

---

## Proof Strategy Architecture

You must pursue at least 2-3 approaches in parallel and choose the one Lean can sustain.

### Strategy A: Layered longest-path induction
Most promising for this cycle.

1. Define `LayeredCircuitMatrix` so support edges always increase index.
2. Prove every admissible path has length at most `n`, and more sharply is bounded by `depthOfMatrix M`.
3. Show any permutation contributing to `minPlusPerm` must pay at least one unit per nontrivial layer transition, so total permutation cost is controlled by depth times number of vertices.
4. Convert large tropical gap assumptions into forced multi-layer traversal, yielding `gap ≤ depth + 1`.

**Why promising:** this aligns with existing theorem `tropical_layer_depth_lb` and avoids heavy tropical eigenvalue formalization while preserving the spectral narrative via a gap surrogate.

### Strategy B: Assignment-problem / Hall-type encoding
Potentially stronger but more technical.

1. Interpret `minPlusPerm` as an assignment cost on the circuit graph.
2. Prove that a shallow circuit matrix admits a low-cost matching because few layers constrain the assignment geometry.
3. Contrapose: if every permutation has high min-plus cost, then no shallow layering can realize the matrix.
4. Use finite combinatorics on `Fin n`, `Equiv.Perm (Fin n)`, and `Finset` sums.

**Why interesting:** this connects tropical permanent to matching theory and could lead to stronger lower bounds than path induction.

### Strategy C: Tropical operator semantics
Most visionary; maybe partial formalization this cycle.

1. Associate to `M` the min-plus linear operator `T_M(x)_i = inf_j (M i j + x_j)`.
2. Define a one-step contraction/separation property induced by `tropicalGap M`.
3. Prove that shallow circuit realization would force too-small iterate separation, contradicting the gap.
4. Deduce depth lower bounds from the number of iterates needed to propagate information.

**Why revolutionary:** this looks like a tropical analogue of spectral expansion or semigroup growth. Even a partial theorem here would seed a new subfield.

Recommendation: **complete Strategy A**, harvest lemmas from **B**, and write definitions toward **C** even if full proofs are deferred.

---

## Cross-Domain Connections You Must Exploit

Do not keep this inside complexity theory. Make the theorem feel inevitable from multiple mathematical worlds.

### 1. Tropical geometry
Interpret `minPlusPerm` as a valuation-style combinatorial invariant. The lower-bound theorem says that **tropical degeneracy obstructs shallow computation**. This suggests analogues of Newton polytope methods for circuit complexity.

### 2. Scheduling / discrete event systems
In max-plus/min-plus control theory, weighted adjacency matrices govern delay propagation and synchronization. Your theorem reframes circuit depth as a **makespan invariant** of an idempotent dynamical system. This is not a metaphor; it is a formal bridge.

### 3. Spectral graph theory
Classical spectral gaps control expansion and mixing. Here, tropical spectral gaps should control **computational propagation length**. Even a surrogate theorem positions tropical complexity as an idempotent analogue of expansion-based lower bounds.

### 4. Formal language theory
For explicit language families, matrix encodings can model automata transitions or layered branching programs. Depth lower bounds from tropical invariants could become lower bounds for restricted recognizers.

### 5. Optimization / assignment theory
The min-plus permanent is an assignment cost. If assignment complexity certifies circuit depth, then lower bounds become optimization obstructions rather than purely combinatorial adversary arguments.

---

## Concrete Research Milestones

1. **Define a usable circuit matrix model**
   - Acyclic, layered, finite, weighted.
   - Keep definitions simple enough for induction on `Fin n`.

2. **Prove foundational graph/path lemmas**
   - admissible paths are strictly increasing in layered matrices
   - path length bounded by `n`
   - path cost monotonicity under edge lower bounds

3. **Formalize min-plus permanent**
   - even if crude at first using `Finset.inf'` over permutations
   - prove basic monotonicity:
     ```lean
     theorem minPlusPerm_mono ...
     ```

4. **Bridge theorem**
   - prove `minPlusPerm_le_depth_bound` or a corrected inequality with constants that are actually true

5. **Explicit family**
   - construct `M_k` where off-diagonal transitions cost at least `k`
   - derive `k ≤ depthOfMatrix M_k + 1`
   - interpret as lower bound for a language/circuit family

6. **Optional visionary layer**
   - define tropical operator iteration and prove one “gap propagation” lemma

---

## Important Caution: Avoid False Grandiosity

The phrase “super-polynomial circuit lower bounds” is a research north star, not a theorem you should bluff into Lean. You must prove statements whose hypotheses genuinely imply the conclusion. If the current framework only yields linear, logarithmic, or polynomial lower bounds for explicit matrix families, that is still a major success **if the bridge is new and reusable**.

If you find that the original conjecture is too optimistic, pivot into a **counterexample-aware refinement**:
- show the naive spectral-gap ⇒ super-polynomial-depth statement is false for arbitrary matrices,
- then isolate the correct restricted class (layered monotone matrices, assignment-rigid matrices, branching-program matrices, etc.),
- and prove the sharp theorem there.

That would be mathematically stronger than forcing an incorrect universal statement.

---

## Application Keywords

Include these explicitly in the development notes and theorem docstrings:

- circuit lower bounds
- tropical spectral theory
- min-plus permanent
- idempotent linear algebra
- structural complexity
- depth lower bounds
- layered DAG semantics
- assignment obstruction
- tropical geometry
- spectral gap analogue
- branching programs
- formal verification of lower bounds

---

## Deliverables

1. Lean 4 file(s) with:
   - concrete definitions
   - at least one nontrivial main theorem fully proved or with minimal sorrys
   - explicit use or extension of catalog theorems where possible

2. A short note in comments explaining:
   - why your chosen invariant deserves the name “tropical spectral obstruction”
   - what restricted circuit model is captured
   - what asymptotic lower bound is actually proved

3. **Required:** produce a structured `FUTURE_DIRECTIONS.md` with **3-5 concrete breakthrough-level next steps**, for example:
   - formalize true tropical eigenvalues/cycle means for finite matrices in Lean
   - derive lower bounds for branching programs via tropical semigroup growth
   - connect tropical permanents to monotone formula size
   - build a certified explicit language family with provable superlinear or polynomial depth lower bounds
   - investigate whether tropical expansion yields NC-vs-P style restricted separations

This must not be generic. Each future direction should include:
- a precise theorem target,
- why it matters,
- which existing theorem from this cycle it builds on.

Be bold, but prove something real. The field-opening move is the bridge itself.

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
