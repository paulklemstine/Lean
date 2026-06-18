## Assignment: Tropical corner critical points

**Mode:** prove

Prove a genuinely new tropical Morse-theoretic theorem for piecewise-linear tropical loss landscapes, centered on **corner critical points**: points on the corner locus where adjacent affine cells induce mutually obstructing descent directions, so that any strict decrease requires crossing the corner locus.

This should not be a vague exploration. I want a formal theorem package that could become the seed of a new field: **tropical Morse theory for optimization landscapes**.

---

## Core Vision

A tropical loss function is piecewise affine. Classical smooth Morse theory cannot see what matters most here: the singular geometry of the corner locus, where optimization trajectories change combinatorial regime. The right analogue of a critical point is therefore not “gradient = 0” but rather:

- multiple affine pieces are active,
- their directional derivatives along admissible tangent directions conflict,
- and there is no local descent direction staying within the same stratum without crossing the corner set.

This is exactly the geometric mechanism behind regime change, phase transition, and grokking-like behavior in tropicalized models.

Your mission is to formalize and prove the first rigorous theorems of this kind.

---

## Precise Theorem Targets

Work first in a mathematically clean finite-dimensional model over `Fin n → ℝ`, with tropical functions represented as finite suprema of affine forms.

### Definition target: tropical piecewise-affine function

Use a representation of the form
\[
f(x) = \max_{i \in I} (\ell_i(x) + c_i),
\]
where each `ℓ_i` is linear. The **corner locus** is the set of points where at least two distinct indices attain the maximum.

You should define a notion of **corner critical point** at a point `x` in the corner locus by requiring that, for the active affine pieces, every tangent direction to the local corner stratum has nonnegative directional derivative for at least one active branch and nonpositive directional derivative for at least one active branch, so no strict descent is available without changing active set.

A workable formal surrogate is pairwise and should be Lean-friendly.

---

## Main theorem A: existence of a corner critical point on forced transition paths

This theorem should connect directly to the catalog theorem
`no_grokking_without_corner_crossing` from `MachineLearning/TropicalGrokking.lean`.

### Mathematical statement

If a continuous path in parameter space connects two regions on which different affine pieces are uniquely active, and if every decrease of the tropical loss along the path requires a corner crossing, then there exists a point on the path that is corner critical.

This is a tropical nonsmooth analogue of “a transition path must pass through a critical barrier.”

### Lean 4 type signature target

A first formal version can be phrased with a finite family of affine maps:

```lean
structure AffinePiece (n : ℕ) where
  lin  : (Fin n → ℝ) →ₗ[ℝ] ℝ
  bias : ℝ

def evalPiece {n : ℕ} (p : AffinePiece n) (x : Fin n → ℝ) : ℝ :=
  p.lin x + p.bias

def tropicalMax {n : ℕ} (S : Finset (AffinePiece n)) (x : Fin n → ℝ) : ℝ :=
  S.sup' (by sorry) (fun p => evalPiece p x)

def activePieces {n : ℕ} (S : Finset (AffinePiece n)) (x : Fin n → ℝ) :
    Finset (AffinePiece n) :=
  S.filter (fun p => evalPiece p x = tropicalMax S x)

def cornerLocus {n : ℕ} (S : Finset (AffinePiece n)) : Set (Fin n → ℝ) :=
  {x | 2 ≤ (activePieces S x).card}

def pairOpposesOnTangent {n : ℕ} (p q : AffinePiece n) (v : Fin n → ℝ) : Prop :=
  p.lin v * q.lin v ≤ 0

def cornerCritical {n : ℕ} (S : Finset (AffinePiece n)) (x : Fin n → ℝ) : Prop :=
  x ∈ cornerLocus S ∧
  ∀ v : Fin n → ℝ,
    (∀ p ∈ activePieces S x, p.lin v = 0) ∨
    ∃ p ∈ activePieces S x, ∃ q ∈ activePieces S x, p.lin v * q.lin v ≤ 0
```

Then aim for a theorem morally of the form:

```lean
theorem exists_cornerCritical_on_transition_path
  {n : ℕ} (S : Finset (AffinePiece n))
  (γ : ℝ → Fin n → ℝ)
  (i j : AffinePiece n)
  (hiS : i ∈ S) (hjS : j ∈ S) (hij : i ≠ j)
  (t0 t1 : ℝ) (ht : t0 < t1)
  (hcont : Continuous γ)
  (hi_start : ∀ k ∈ S, k ≠ i → evalPiece k (γ t0) < evalPiece i (γ t0))
  (hj_end   : ∀ k ∈ S, k ≠ j → evalPiece k (γ t1) < evalPiece j (γ t1)) :
  ∃ t ∈ Set.Icc t0 t1, cornerCritical S (γ t)
```

This statement may need refinement if `Finset.sup'` becomes annoying; if so, define tropical max using a nonempty indexed family or a list plus nonemptiness witness.

### Why this is a breakthrough

This would be the first theorem turning tropical “corner crossing” from a geometric slogan into a certified critical-point principle. It converts a combinatorial change of active monomial into a bona fide variational obstruction.

It opens the door to:
- barrier theorems for training trajectories,
- lower bounds on transition complexity,
- stratified optimization invariants for neural networks,
- tropical analogues of mountain-pass arguments.

---

## Main theorem B: local sign-count index for codimension-1 corner critical points

Restrict to the clean codimension-1 case first: exactly two affine pieces are active near the corner, so the corner locus is locally a tropical hyperplane wall.

### Mathematical statement

Let
\[
f(x)=\max(\ell_1(x)+c_1,\ell_2(x)+c_2)
\]
and let `x` lie on the wall where the two pieces are equal. If the projected directional derivatives of `ℓ₁` and `ℓ₂` along the wall have opposite sign, then `x` is a corner critical point. Moreover, the tropical Morse index at `x` is `1`.

Then generalize: if finitely many adjacent cells meet and the projected gradients along the corner stratum split into opposite-sign classes, define the tropical Morse index as the number of opposing-sign adjacency pairs and prove nonnegativity / invariance under local reordering of the active family.

### Lean 4 type signature target

First prove the codimension-1 theorem:

```lean
def wallEq {n : ℕ} (p q : AffinePiece n) : Set (Fin n → ℝ) :=
  {x | evalPiece p x = evalPiece q x}

def tropicalMorseIndexPair {n : ℕ} (p q : AffinePiece n) (x : Fin n → ℝ) : ℕ :=
  if x ∈ wallEq p q then 1 else 0

theorem cornerCritical_of_opposite_sign_on_wall
  {n : ℕ} (p q : AffinePiece n) (x v : Fin n → ℝ)
  (hwall : x ∈ wallEq p q)
  (hopp : p.lin v * q.lin v ≤ 0) :
  cornerCritical ({p, q} : Finset (AffinePiece n)) x
```

Then prove the index theorem:

```lean
def signOpposingPairs {n : ℕ}
    (A : Finset (AffinePiece n)) (v : Fin n → ℝ) : ℕ :=
  ((A.product A).filter (fun pq => pq.1.lin v * pq.2.lin v < 0)).card

theorem tropicalMorseIndex_eq_opposingPairs
  {n : ℕ} (S : Finset (AffinePiece n)) (x v : Fin n → ℝ)
  (hcrit : cornerCritical S x) :
  ∃ m : ℕ, m = signOpposingPairs (activePieces S x) v
```

You may need a cleaner index definition to make the theorem true and useful. If so, define the index **to be** the opposing-pair count and prove that in the two-piece wall case it equals `1`, and that it vanishes off the corner locus.

### Why this is a breakthrough

This creates the first computable local invariant for tropical singular optimization. It is the missing discrete analogue of the Hessian signature in smooth Morse theory.

This could become the primitive for:
- certifying transition severity,
- counting unavoidable regime changes,
- comparing training landscapes by singularity complexity,
- stratified stability analysis under perturbation.

---

## Main theorem C: a weak tropical Morse inequality

Do not overreach to full tropical homology immediately. First prove a weak but rigorous counting theorem in a finite polyhedral complex model.

### Mathematical statement

For a finite tropical polyhedral complex equipped with a tropical piecewise-affine function satisfying a nondegeneracy condition on corner critical points, the number of corner critical points of index `0` and `1` bounds a combinatorial topological invariant such as the Euler characteristic of the corner complex, or the rank of `H₀` / `H₁` of the adjacency graph.

A realistic first theorem is:
\[
\#\mathrm{Crit}_{corner} \ge |\chi(K)|
\]
for a finite connected 1-dimensional tropical complex `K`, or
\[
\#\mathrm{Crit}^{(0)}_{corner} - \#\mathrm{Crit}^{(1)}_{corner} = \chi(K)
\]
under a sufficiently strong genericity assumption.

### Lean 4 type signature target

A graph-theoretic version is likely most formalizable:

```lean
structure TropicalWallGraph where
  V : Type
  [fintypeV : Fintype V]
  [decV : DecidableEq V]
  E : Finset (V × V)

def eulerChar (G : TropicalWallGraph) : ℤ :=
  Fintype.card G.V - G.E.card

def isCornerCriticalVertex (G : TropicalWallGraph) (φ : G.V → ℝ) (v : G.V) : Prop :=
  ∃ u₁ u₂,
    (u₁, v) ∈ G.E ∧ (u₂, v) ∈ G.E ∧
    φ u₁ ≤ φ v ∧ φ u₂ ≤ φ v

theorem weak_tropical_morse_inequality_graph
  (G : TropicalWallGraph) (φ : G.V → ℝ) :
  Int.natAbs (eulerChar G) ≤
    Fintype.card {v // isCornerCriticalVertex G φ v}
```

If this exact graph theorem is false as stated, adjust it to a tree, path, or connected acyclic wall graph first. Better a correct foundational theorem than an overclaimed slogan.

### Why this is a breakthrough

This would be the first certified bridge from tropical optimization singularities to topological complexity. Even a graph-level theorem would be a major conceptual beachhead: it says the number of tropical transition bottlenecks is controlled by topology, not just local algebra.

That opens a path toward:
- topological lower bounds on optimization difficulty,
- complexity measures for network loss surfaces,
- combinatorial tropical analogues of Morse inequalities,
- eventually a formalized tropical persistent homology of training.

---

## Proof Strategy Architecture

You must provide at least 2-3 viable proof routes and choose the most promising one.

### Strategy A: intermediate-value crossing of active-piece gaps
Most promising for Main theorem A.

1. For distinct pieces `i, j`, define the gap function
   \[
   g_{ij}(t)=\mathrm{evalPiece}(i,\gamma(t))-\mathrm{evalPiece}(j,\gamma(t)).
   \]
   By continuity of `γ` and linearity of affine pieces, `g_{ij}` is continuous.

2. Use unique activity of `i` at `t0` and `j` at `t1` to show some gap changes sign on `[t0,t1]`. By the intermediate value theorem there exists `t*` with equality of active values, hence `γ(t*)` lies on the corner locus.

3. Upgrade corner-locus membership to corner-criticality by showing that if all active directional derivatives had the same strict sign along the local stratum, then one could locally continue a descent path without genuine corner obstruction, contradicting the transition hypothesis / `no_grokking_without_corner_crossing`.

Why this is promising: it uses only continuity, affine evaluation, and sign arguments—exactly the kind of mathematics Lean handles well.

### Strategy B: Clarke subdifferential reinterpretation
Conceptually deepest, useful if you want a future generalization.

1. For `f = max_i a_i`, the Clarke subdifferential at `x` is the convex hull of gradients of active pieces.

2. A corner critical point corresponds to `0` belonging to the tangent-projected convex hull, or more weakly to sign conflict among active directional derivatives.

3. Prove the theorem by a nonsmooth variational argument: a forced transition path must pass through a point where the projected subdifferential contains no strict descent certificate.

Why this matters: this connects tropical optimization directly to nonsmooth analysis, variational geometry, and certified optimization. It is more ambitious, but may be harder to formalize from scratch unless Mathlib’s convexity toolkit is enough for a minimal version.

### Strategy C: combinatorial wall graph / Reeb graph reduction
Most promising for Main theorem C.

1. Encode the adjacency of active regions by a finite graph whose vertices are cells or wall intersections.

2. Define corner critical vertices combinatorially by sign changes of affine slopes on incident edges.

3. Prove an Euler-characteristic bound by discrete Morse-style counting on the graph.

Why this is promising: it avoids heavy tropical homology formalization while still delivering a true Morse inequality prototype.

---

## How to Build on the Catalog Theorems

Use the existing verified theorem
`no_grokking_without_corner_crossing`
from `MachineLearning/TropicalGrokking.lean`
as the bridge from optimization-transition language to geometric corner-crossing inevitability.

Concretely:
- use it to justify the hypothesis that any grokking-type regime change forces entry into the corner locus;
- then strengthen it by proving **crossing implies existence of a corner-critical obstruction point**, not merely some corner contact.

The other listed catalog theorems may be less central, but you should inspect whether:
- `tropical_young_inequality` can provide auxiliary max-plus inequalities for comparing active branches;
- `bool_and_as_tropical_max` can help construct toy examples where logical phase transitions correspond exactly to tropical corner critical points;
- `tropical_and_bound` may support lower-bound style inequalities in Boolean/tropical architectures;
- `exists_fixed_point_on_orbit_with_bound` could inspire compactness-or-orbit arguments if you study recurrent transition dynamics later.

Do not force these into the proof if they are irrelevant. The key is to **genuinely leverage** `no_grokking_without_corner_crossing`.

---

## Formalization Guidance in Lean 4

Start with the simplest robust universe:

- ambient space: `Fin n → ℝ`
- affine pieces: linear map plus bias
- tropical function: finite max over pieces
- corner locus: at least two active pieces
- local criticality: pairwise sign obstruction criterion

Prefer definitions that are:
- computable over `Finset`,
- extensional,
- easy to evaluate on examples,
- compatible with continuity lemmas.

You may want to avoid full tangent-space formalization at first. A strong discrete surrogate is acceptable:
- define corner criticality using existence of opposing active directional derivatives in every tested direction, or
- in codimension-1, use the wall determined by two active pieces and a single witness direction tangent to that wall.

If the universal quantification over all directions is too hard, prove a **certified sufficient condition**:
```lean
def cornerCriticalWitness ... : Prop := ...
theorem cornerCritical_of_witness ... : ...
```
This is still valuable if it is mathematically clean.

---

## Cross-Domain Connections You Should Exploit

This project is powerful because it sits at the intersection of several fields:

- **Tropical geometry:** corner locus, active monomials, polyhedral stratification.
- **Nonsmooth analysis:** Clarke subdifferentials, directional derivatives, variational criticality.
- **Discrete Morse theory:** graph/polyhedral counting of critical strata.
- **Optimization theory:** descent obstruction, barrier points, transition complexity.
- **Machine learning theory:** grokking transitions, mode connectivity, loss-landscape phase changes.
- **Statistical physics:** phase boundaries and metastable transition states in piecewise-linear energy landscapes.
- **Applied topology:** Euler characteristic, homology ranks, stratified topological invariants.

Make these bridges explicit in the theorem comments / documentation. The point is not merely to prove a lemma, but to define a language that others can build on.

---

## Application Keywords

tropical Morse theory, corner critical point, corner locus, piecewise-linear optimization, max-plus geometry, nonsmooth criticality, Clarke subdifferential, grokking transition, phase boundary, stratified loss landscape, polyhedral topology, discrete Morse inequality, tropical homology, Euler characteristic bound, training barrier certificate, singular optimization geometry

---

## Deliverables

1. Formal definitions for:
   - affine tropical pieces,
   - tropical max function,
   - active pieces,
   - corner locus,
   - corner critical point,
   - tropical Morse index or certified proxy.

2. At least one fully proved flagship theorem:
   - preferably `exists_cornerCritical_on_transition_path`, or
   - the codimension-1 wall theorem plus index computation.

3. If the full weak Morse inequality is too ambitious, prove a graph-theoretic prototype with a precise topological lower bound.

4. Include at least one explicit worked example:
   - two-piece max over `ℝ²`,
   - or a small finite wall graph,
   showing the critical point and computed index.

5. Minimize sorry aggressively. If a theorem must be split into helper lemmas, do so.

6. Produce a structured `FUTURE_DIRECTIONS.md` with **3-5 concrete breakthrough next steps**, for example:
   - full tropical Morse inequalities via polyhedral chain complexes,
   - Clarke-subdifferential formalization for tropical neural networks,
   - persistence of corner critical points under perturbation,
   - tropical mountain-pass theorem,
   - certified lower bounds on number of grokking transitions from topology.

---

## Standard of Success

Success is not “some definitions exist.” Success is:
- a precise and reusable formal notion of tropical corner criticality,
- a theorem showing forced transition paths must hit such points,
- a computable local index in the two-branch case,
- and a first topological counting principle.

If you pull this off, you won’t just formalize a concept. You will create the first rigorous scaffold for **tropical singularity theory of learning dynamics**.

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
