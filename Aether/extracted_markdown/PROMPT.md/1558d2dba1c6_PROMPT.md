## Assignment: Tropical Convexity and Helly Theorem

Mode: **prove**

You are not being asked for a cosmetic tropical rephrasing of a classical theorem. You are being asked to create the formal nucleus of a new bridge between **tropical convexity, finite-dimensional optimization, and combinatorial geometry** in Lean 4.

The correct target is not “some tropical Helly statement.” The target is a theorem with an exact finite-dimensional witness structure, stated on concrete types, that can become the first certified engine for tropical feasibility checking.

---

## Research Direction

Formalize a concrete notion of tropical convexity on `Fin n → ℝ`, prove a **finite-family tropical Helly theorem for tropical halfspaces / tropically convex polyhedra**, and derive an **algorithmic feasibility corollary**: global feasibility is certified by checking subfamilies of bounded size.

This is a breakthrough because classical Helly theory is one of the central compression principles of convexity: infeasibility of arbitrarily large systems is witnessed by a small subsystem. A tropical version, formalized in Lean, would open a path to:

- certified tropical linear programming,
- min-plus constraint solving,
- combinatorial optimization over idempotent semirings,
- formal links between tropical geometry and static program analysis / shortest-path semantics.

Do **not** settle for a vague abstract formulation if a finite-dimensional polyhedral one is provable.

---

## Precise Mathematical Target

Work in the min-plus / max-plus real tropical setting on `Fin n → ℝ`. Since Mathlib has rich finite-dimensional linear and order infrastructure over `ℝ`, define tropical convex combinations concretely via coordinatewise `inf`/`sup` plus translations.

A robust formal target is:

### Definition targets
1. Define tropical scaling and tropical addition on vectors:
   - min-plus model:
     - `(a ⊙ x) i = a + x i`
     - `(x ⊞ y) i = min (x i) (y i)`
2. Define a set `S : Set (Fin n → ℝ)` to be **tropically convex** if it is closed under binary tropical combination and tropical scaling.
3. Define tropical halfspaces by inequalities of the form
   \[
   \min_i (a_i + x_i) \le \min_j (b_j + x_j),
   \]
   or dually in max-plus form. Choose one convention and stick to it.
4. Define a tropical polyhedron as a finite intersection of tropical halfspaces.

Then prove a Helly theorem in a finite-dimensional form.

---

## Primary Theorem Statement

A realistic and powerful theorem to target is:

> **Finite Tropical Helly for Polyhedra.**  
> Let `n : ℕ`. Let `F : Finset (Set (Fin n → ℝ))` be a finite family of tropically convex polyhedra in tropical dimension `n`. If every subfamily of cardinality at most `n+1` has nonempty intersection, then the whole family has nonempty intersection.

This is the right level of ambition: finite-dimensional, concrete, algorithmic, and recognizably Helly-type.

### Lean 4 theorem signature candidate
You will likely need to build definitions first, but the intended endpoint is close to:

```lean
theorem tropical_helly_polyhedron
    {n : ℕ}
    (F : Finset (Set (Fin n → ℝ)))
    (hpoly : ∀ s ∈ F, IsTropicalPolyhedron s)
    (hsmall :
      ∀ G : Finset (Set (Fin n → ℝ)),
        G ⊆ F →
        G.card ≤ n + 1 →
        (⋂ s ∈ G, s).Nonempty) :
    (⋂ s ∈ F, s).Nonempty
```

If finite intersections over `Finset` are cumbersome, use an equivalent formulation with explicit witnesses:

```lean
theorem tropical_helly_polyhedron'
    {n : ℕ}
    (F : Finset (Set (Fin n → ℝ)))
    (hpoly : ∀ s ∈ F, IsTropicalPolyhedron s)
    (hsmall :
      ∀ G : Finset (Set (Fin n → ℝ)),
        G ⊆ F →
        G.card ≤ n + 1 →
        ∃ x : Fin n → ℝ, ∀ s ∈ G, x ∈ s) :
    ∃ x : Fin n → ℝ, ∀ s ∈ F, x ∈ s
```

This witness form is often easier in Lean.

---

## Foundational Lemma Targets

You will probably need a staircase of lemmas. These are not busywork; they are the real architecture.

### 1. Tropical convexity of tropical halfspaces
```lean
theorem isTropicallyConvex_tropicalHalfspace
    {n : ℕ} (a b : Fin n → ℝ) :
    IsTropicallyConvex (tropicalHalfspace a b)
```

This proves your basic geometric atoms are valid.

### 2. Finite intersections preserve tropical convexity
```lean
theorem isTropicallyConvex_iInter_finset
    {n : ℕ} {F : Finset (Set (Fin n → ℝ))}
    (hF : ∀ s ∈ F, IsTropicallyConvex s) :
    IsTropicallyConvex {x | ∀ s ∈ F, x ∈ s}
```

### 3. Tropical polyhedra are tropically convex
```lean
theorem isTropicallyConvex_of_isTropicalPolyhedron
    {n : ℕ} {s : Set (Fin n → ℝ)}
    (h : IsTropicalPolyhedron s) :
    IsTropicallyConvex s
```

### 4. Small-subfamily infeasibility witness
A contrapositive Helly form may be easier:
```lean
theorem tropical_helly_polyhedron_contrapositive
    {n : ℕ}
    (F : Finset (Set (Fin n → ℝ)))
    (hpoly : ∀ s ∈ F, IsTropicalPolyhedron s)
    (hempty : ¬ ∃ x : Fin n → ℝ, ∀ s ∈ F, x ∈ s) :
    ∃ G : Finset (Set (Fin n → ℝ)),
      G ⊆ F ∧
      G.card ≤ n + 1 ∧
      ¬ ∃ x : Fin n → ℝ, ∀ s ∈ G, x ∈ s
```

This is algorithmically stronger and often more natural.

---

## Secondary Theorem: Tropical Convex Hull / Optimization Bridge

Do not stop at Helly. Connect it to optimization immediately.

Define the tropical convex hull of a finite set `P : Finset (Fin n → ℝ)` as the closure under finite tropical combinations. Then prove a feasibility/optimization bridge such as:

> If a finite family of tropical halfspaces has nonempty intersection, then a point in the intersection may be searched for inside the tropical convex hull of a finite witness set extracted from boundary data.

Or a weaker but formalizable theorem:

### Lean target
```lean
theorem tropical_feasibility_has_small_certificate
    {n : ℕ}
    (F : Finset (Set (Fin n → ℝ)))
    (hpoly : ∀ s ∈ F, IsTropicalPolyhedron s)
    (hfeas : ∃ x : Fin n → ℝ, ∀ s ∈ F, x ∈ s) :
    ∃ G : Finset (Set (Fin n → ℝ)),
      G ⊆ F ∧
      G.card ≤ n + 1 ∧
      ∃ x : Fin n → ℝ, ∀ s ∈ G, x ∈ s
```

This theorem itself is easy, but it sets up a stronger next-cycle theorem: **minimal tropical certificates**. More interestingly, if you can define a tropical objective
\[
f(x) = \max_{k \in K} (c_k + x_{i_k}) - \max_{\ell \in L}(d_\ell + x_{j_\ell}),
\]
prove that feasibility of a finite tropical system implies attainment of a minimum over a bounded witness hull. That would be the optimization bridge.

---

## Proof Strategy Options

## Strategy A: Reduction to classical Helly via logarithmic / order-convex encoding
This is the most promising if you can encode tropical halfspaces as ordinary convex sets in a higher-dimensional space.

Steps:
1. Show each tropical halfspace can be represented as a finite union/intersection of classical linear inequalities after introducing selector data for minima/maxima.
2. Refine to a polyhedral complex decomposition where each tropical polyhedron becomes a finite union of ordinary convex polyhedra.
3. Apply classical finite-dimensional Helly on each cell or on a lifted representation, then descend.

Why promising:
- Mathlib already knows a lot more about ordinary finite-dimensional convexity than tropical convexity.
- A successful reduction lets you import a mature theorem rather than proving tropical Helly from first principles.
- This creates a bridge to polyhedral combinatorics and LP duality.

Risk:
- Tropical sets may become unions rather than convex lifts, making direct Helly transfer delicate.
- You may need a carefully chosen lifted formulation.

---

## Strategy B: Contrapositive via minimal infeasible subsystem
This is likely the best Lean-native path.

Steps:
1. Assume the full family is infeasible and choose a minimal infeasible subfamily by finite-cardinality well-foundedness on `Finset.card`.
2. Prove every proper subfamily is feasible by minimality.
3. Show any minimal infeasible family of tropical polyhedra has cardinality at most `n+1`, by extracting `n+1` active constraints / sectors / types from tropical geometry.

Why promising:
- Finite minimal counterexample arguments are Lean-friendly.
- The theorem naturally becomes algorithmic: infeasibility has a small witness.
- This mirrors classical Helly proofs via Radon/Carathéodory-type compression.

Risk:
- The crucial dimension bound `≤ n+1` is the hard geometric step.
- You must define “active type” or another combinatorial invariant cleanly.

---

## Strategy C: Tropical Carathéodory/Radon first, Helly second
This is the most conceptually powerful route.

Steps:
1. Define tropical convex hull of a finite set.
2. Prove a tropical Carathéodory theorem: any point in the tropical convex hull of a set in dimension `n` lies in the hull of at most `n+1` points.
3. Derive tropical Radon, then derive Helly by the standard convexity implication chain.

Why promising:
- This opens an entire formal theory, not just one theorem.
- Helly becomes part of a larger tropical convexity package.
- This is the route with the highest long-term scientific value.

Risk:
- It is the heaviest lift formally.
- If no tropical Radon/Carathéodory infrastructure exists in Mathlib, you will need to build a lot.

Recommendation:
- **Start with Strategy B** for a first certified theorem.
- If progress is strong, pivot to **Strategy C** so the project becomes field-opening rather than theorem-isolated.

---

## Concrete Lean Design Advice

Use concrete types:
- ambient space: `Fin n → ℝ`
- finite families: `Finset`
- set predicates: `Set (Fin n → ℝ)`

Suggested core definitions:

```lean
def tropScale {n : ℕ} (a : ℝ) (x : Fin n → ℝ) : Fin n → ℝ :=
  fun i => a + x i

def tropAdd {n : ℕ} (x y : Fin n → ℝ) : Fin n → ℝ :=
  fun i => min (x i) (y i)

def IsTropicallyConvex {n : ℕ} (s : Set (Fin n → ℝ)) : Prop :=
  ∀ ⦃x y : Fin n → ℝ⦄, x ∈ s → y ∈ s →
    ∀ a b : ℝ, tropAdd (tropScale a x) (tropScale b y) ∈ s
```

For halfspaces, one practical definition is:

```lean
def tropMin {n : ℕ} (a x : Fin n → ℝ) : ℝ :=
  Finset.inf' Finset.univ (by simp) (fun i => a i + x i)

def tropicalHalfspace {n : ℕ} (a b : Fin n → ℝ) : Set (Fin n → ℝ) :=
  {x | tropMin a x ≤ tropMin b x}
```

This avoids quotient-like structures and stays computable.

You may also want a finite-family intersection encoding:
```lean
def InAll {α : Type _} (F : Finset (Set α)) (x : α) : Prop :=
  ∀ s ∈ F, x ∈ s
```

Then formulate all Helly statements using `InAll`.

---

## How to Build on Catalog Theorems

The current catalog theorems are not directly Helly-theoretic, but they can still play a role as certified algebraic sanity checks and thematic anchors.

1. `tropical_mirror_theorem`  
   Use it to simplify idempotent tropical expressions where duplicate terms appear. Any proof that manipulates coordinatewise `max`/`min` should exploit self-idempotence explicitly.

2. `tropical_and_bound`  
   If this theorem provides a lower-bound interaction for tropical conjunction-like operations, use it in feasibility lemmas that combine two tropical inequalities into one bounded witness statement.

3. `tropical_fundamental_theorem` and `master_tropical_hodge_theorem`  
   These are likely too high-level for direct proof reuse, but they should be cited in `ARTICLE.md` as evidence that your tropical convexity package is the missing finite-dimensional combinatorial substrate beneath more sophisticated tropical representation-theoretic and Hodge-theoretic structures.

4. `tropical_fundamental_theorem_of_arithmetic`  
   Probably not directly useful, but if you create a semiring-style namespace for tropical algebraic identities, this theorem helps justify the catalog’s consistency across algebraic layers.

Do not force these into the proof. Use them where they naturally simplify tropical algebra. The true value here is building the next layer of the tropical formal stack.

---

## Cross-Domain Connections You Must Exploit

This project becomes revolutionary only if you make the external connections explicit.

### 1. Optimization / Operations Research
Tropical halfspaces encode min-plus constraints closely related to:
- shortest path feasibility,
- difference constraints,
- Bellman-type fixed point inequalities,
- mean-payoff and scheduling systems.

Helly then becomes a **small certificate theorem for infeasibility** of tropical optimization systems.

### 2. Static Analysis / Program Semantics
Min-plus and max-plus convexity arise in abstract interpretation and cost semantics. A formal tropical Helly theorem would imply:
- finite obstruction sets for infeasible cost constraints,
- certified pruning rules in static analyzers,
- compressed counterexample extraction.

### 3. Combinatorics / Oriented Matroids / Polyhedral Geometry
Tropical convexity is controlled by combinatorial types. If you can characterize minimal infeasible subfamilies combinatorially, you create a formal bridge to:
- tropical oriented matroids,
- regular subdivisions,
- polyhedral complexes.

### 4. Mathematical Physics / Idempotent Analysis
Tropicalization is a zero-temperature / semiclassical shadow. A Helly theorem in this setting suggests a finite-obstruction principle for zero-temperature energy landscapes. Even a modest formal theorem here can seed future work in:
- idempotent functional analysis,
- large deviations,
- control theory.

---

## Application Keywords

Include these in `ARTICLE.md`, theorem docstrings, and commit messages where appropriate:

- tropical convexity
- Helly theorem
- min-plus geometry
- max-plus algebra
- tropical polyhedra
- finite infeasibility certificate
- certified optimization
- idempotent analysis
- combinatorial geometry
- abstract interpretation
- shortest paths
- tropical linear programming
- witness extraction
- formalized convexity

---

## Concrete Deliverables

1. **Lean file(s)** defining:
   - `tropScale`
   - `tropAdd`
   - `IsTropicallyConvex`
   - `tropicalHalfspace`
   - `IsTropicalPolyhedron`

2. A proved theorem in one of these forms:
   - `tropical_helly_polyhedron`
   - `tropical_helly_polyhedron_contrapositive`

3. At least 3–5 supporting lemmas on closure, intersection, and witness extraction.

4. A short `ARTICLE.md` explaining:
   - the chosen tropical convention,
   - relation to classical Helly,
   - optimization significance.

5. A mandatory `FUTURE_DIRECTIONS.md` with **3–5 falsifiable scientific hypotheses**.

---

## Required FUTURE_DIRECTIONS.md Content

Each direction must be a genuine conjecture with a clear test.

Use this format exactly:

### [Hypothesis name]
**Conjecture:** precise statement.  
**Why it matters:** one paragraph.  
**Test:** explicit Lean experiment, brute-force search, or finite-dimensional formalization target that could confirm or refute it.

You must include hypotheses of the following flavor:

### [Tropical Carathéodory Compression]
**Conjecture:** For every `n : ℕ`, every point in the tropical convex hull of a finite subset of `Fin n → ℝ` lies in the tropical convex hull of some subfamily of cardinality at most `n+1`.  
**Test:** Formalize tropical convex hull for `n ≤ 3`, brute-force finite rational examples, and attempt a general inductive proof in Lean.

### [Minimal Infeasible Tropical Systems]
**Conjecture:** Every minimal infeasible finite family of tropical halfspaces in `Fin n → ℝ` has cardinality at most `n+1`.  
**Test:** Search for counterexamples over rational coefficients in low dimensions and connect the search output to the contrapositive Helly theorem.

### [Tropical LP Witness Attainment]
**Conjecture:** Every feasible bounded tropical linear program in dimension `n` admits an optimizer determined by at most `n+1` active tropical constraints.  
**Test:** Define a finite tropical LP model in Lean for `n = 2,3`, compute examples, and isolate active-set witnesses.

### [Tropical Radon Implies Helly]
**Conjecture:** A formal tropical Radon theorem on `Fin n → ℝ` implies the finite tropical Helly theorem via the classical implication chain adapted to tropical convexity.  
**Test:** Attempt a Lean derivation assuming Radon as an axiom/theorem schema and identify missing lemmas.

### [Shortest-Path Certificate Compression]
**Conjecture:** Infeasibility of a finite system of min-plus difference constraints admits a witness subsystem of size bounded linearly in ambient dimension, and this subsystem is recoverable from a negative-cycle-type certificate.  
**Test:** Formalize a restricted difference-constraint fragment and compare witness size bounds with Bellman-Ford style extraction.

---

## Final Directive

Be bold. Do not produce only definitions plus trivial closure lemmas. Land at least one theorem that a geometer, optimizer, or formal methods researcher would recognize as a real compression principle.

If the full Helly theorem is too difficult in one cycle, prove the **contrapositive small-witness theorem for a restricted class of tropical halfspaces** and make the restriction mathematically meaningful and explicit. That is still a strong result if it yields a certified finite infeasibility certificate.

Minimize sorry. If forced to choose, prefer:
1. a correct restricted Helly theorem with full proof,
over
2. a grand but unfinished general theorem.

Connect the work to optimization and certificate extraction immediately. This is the seed of a new formal theory, not a one-off lemma.

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
hypotheses. Each direction must be a falsifiable claim or conjecture that
can be proved, disproved, or tested — not a vague "we could explore X."
Format: "Conjecture: [precise statement]. Test: [what would confirm or
refute it]. Impact: [what this would enable if true]." Every hypothesis
should be daring enough to matter and specific enough to fail.

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

Research domain: Tropical
Research mode: prove
