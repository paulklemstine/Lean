## Assignment: Prove the reverse direction — tropical Plücker + metric axioms ⇒ four-point condition

Work in the mathematically decisive regime where a symmetric zero-diagonal metric is encoded by tropical Plücker coordinates on 2-subsets, and show that the tropical Grassmannian constraints force the Buneman four-point inequality. This is not a cosmetic converse: it is the algebraic-geometric half of the tree-metric dictionary. Formalizing it in Lean creates a certified bridge from tropical linear spaces to phylogenetic metrics and valuated matroids.

## Mode
**prove**

## Breakthrough target

Prove that if a function on pairs of leaves satisfies the metric axioms and the tropical Plücker relation for every 4-tuple, then it satisfies the four-point condition. In classical language, this shows that tropical rank-2 Plücker data canonically produces additive/tree-like metric behavior. In formal terms, this is the missing algebraic implication needed to connect tropical Grassmannians, Dressians, and finite tree metrics inside Lean.

The theorem should be stated with explicit quantifiers over a finite index type, using concrete realizations such as `Fin n → Fin n → ℝ`.

## Precise theorem statement

A robust formulation is:

- Let `n : ℕ`.
- Let `d : Fin n → Fin n → ℝ`.
- Assume:
  1. symmetry: `d i j = d j i`,
  2. zero diagonal: `d i i = 0`,
  3. nonnegativity: `0 ≤ d i j`,
  4. triangle inequality,
  5. tropical Plücker relation on quadruples, encoded via
     `p i j := -d i j` on unordered pairs.

Then prove the four-point condition:
for all distinct `i j k l`, the three sums
`d i j + d k l`, `d i k + d j l`, `d i l + d j k`
have the property that the maximum is attained at least twice.
Equivalently, one of them is less than or equal to the max of the other two.

A Lean-friendly inequality version is usually easiest:

```lean
theorem tropical_plucker_metric_implies_four_point
    {n : ℕ} (d : Fin n → Fin n → ℝ)
    (hsym : ∀ i j, d i j = d j i)
    (hdiag : ∀ i, d i i = 0)
    (hnonneg : ∀ i j, 0 ≤ d i j)
    (htri : ∀ i j k, d i k ≤ d i j + d j k)
    (hplucker :
      ∀ a b c e : Fin n,
        let s1 := d a b + d c e
        let s2 := d a c + d b e
        let s3 := d a e + d b c
        s1 ≤ max s2 s3) :
    FourPointCondition d
```

If `FourPointCondition` is already defined, adapt the conclusion exactly to that definition. If the existing definition uses distinctness hypotheses explicitly, produce the theorem in that shape:

```lean
theorem tropical_plucker_metric_implies_four_point_distinct
    {n : ℕ} (d : Fin n → Fin n → ℝ)
    (hsym : ∀ i j, d i j = d j i)
    (hdiag : ∀ i, d i i = 0)
    (hnonneg : ∀ i j, 0 ≤ d i j)
    (htri : ∀ i j k, d i k ≤ d i j + d j k)
    (hplucker :
      ∀ a b c e : Fin n,
        d a b + d c e ≤ max (d a c + d b e) (d a e + d b c)) :
    ∀ a b c e : Fin n, FourPointCondition d
```

But the genuinely stronger and more elegant target is the “two largest among the three pair-sums are equal” formulation:

```lean
def FourPointMaxTwoEqual (d : Fin n → Fin n → ℝ) : Prop :=
  ∀ a b c e,
    let s1 := d a b + d c e
    let s2 := d a c + d b e
    let s3 := d a e + d b c
    (s1 ≤ max s2 s3) ∧ (s2 ≤ max s1 s3) ∧ (s3 ≤ max s1 s2)

theorem tropical_plucker_equiv_four_point
    {n : ℕ} (d : Fin n → Fin n → ℝ)
    (hsym : ∀ i j, d i j = d j i) :
    (∀ a b c e, d a b + d c e ≤ max (d a c + d b e) (d a e + d b c)) ↔
    FourPointMaxTwoEqual d
```

This equivalence theorem is especially valuable: it isolates the algebraic core and may make later tree-reconstruction results much cleaner.

## Why this is a breakthrough

This theorem is the formal hinge between:
- **tropical algebraic geometry**: tropical Plücker relations defining the tropical Grassmannian / Dressian,
- **metric geometry**: four-point characterization of tree-like metrics,
- **phylogenetics**: distance-based reconstruction of trees,
- **matroid theory**: valuated matroids of rank 2,
- **combinatorial optimization**: submodular and max-plus structures.

A Lean proof here opens the door to a fully formal theorem that rank-2 tropical linear spaces are exactly finite tree metrics up to standard normalization. That is not just another lemma — it is the first certified infrastructure for machine-checked tropical-phylogenetic geometry.

## Proof strategy architecture

### Strategy A: Direct cyclic permutation of the Plücker inequality
Most promising.

1. **Define the three pair-sums**
   ```lean
   s1 := d a b + d c e
   s2 := d a c + d b e
   s3 := d a e + d b c
   ```
2. **Use the given Plücker inequality once**
   This already gives `s1 ≤ max s2 s3`.
3. **Obtain the other two inequalities by reindexing**
   Apply `hplucker` to permuted quadruples, e.g.
   - `(a, c, b, e)` to get `s2 ≤ max s1 s3`,
   - `(a, e, b, c)` to get `s3 ≤ max s1 s2`,
   then simplify using `hsym` and commutativity/associativity of addition.
4. **Package these three inequalities into `FourPointCondition`**
   Depending on the existing definition, either:
   - conclude directly, or
   - prove a helper lemma that these three inequalities imply “the maximum is achieved at least twice”.

Why this is best: the theorem is fundamentally an orbit argument under the `S₄` action on quadruples. The proof is short, conceptual, and extremely formalization-friendly.

### Strategy B: Translate through tropical rank-2 Plücker coordinates
More conceptual, slightly heavier.

1. Define tropical Plücker coordinates `p i j := - d i j`.
2. Rewrite the tropical Plücker relation in min-plus or max-plus convention carefully.
3. Show that the relation “minimum attained at least twice” for
   `p ab + p ce`, `p ac + p be`, `p ae + p bc`
   is equivalent, after negation, to the four-point condition for `d`.
4. Use the metric axioms only for normalization and compatibility with the intended geometric interpretation.

Why useful: this proof makes the theorem immediately reusable for future formalizations of tropical Grassmannians and valuated matroids. It is the right abstraction if you expect follow-up work on rank-`r` tropical linear spaces.

### Strategy C: Max-attained-twice lemma as an abstract order-theoretic fact
Good as a library-building route.

1. Prove an auxiliary lemma for linearly ordered additive commutative monoids:
   if `x ≤ max y z`, `y ≤ max x z`, and `z ≤ max x y`, then the maximum of `{x,y,z}` is attained at least twice.
2. Derive the three inequalities from reindexed Plücker relations.
3. Instantiate the abstract lemma with `ℝ`.

Why useful: this creates a reusable theorem for future tropical arguments where “attained twice” appears repeatedly.

## Key helper lemmas to prove first

These may dramatically reduce friction:

```lean
lemma plucker_perm_1
    {n : ℕ} (d : Fin n → Fin n → ℝ)
    (hsym : ∀ i j, d i j = d j i)
    (hplucker :
      ∀ a b c e, d a b + d c e ≤ max (d a c + d b e) (d a e + d b c)) :
    ∀ a b c e, d a c + d b e ≤ max (d a b + d c e) (d a e + d b c)
```

```lean
lemma plucker_perm_2
    {n : ℕ} (d : Fin n → Fin n → ℝ)
    (hsym : ∀ i j, d i j = d j i)
    (hplucker :
      ∀ a b c e, d a b + d c e ≤ max (d a c + d b e) (d a e + d b c)) :
    ∀ a b c e, d a e + d b c ≤ max (d a b + d c e) (d a c + d b e)
```

```lean
lemma three_pair_sums_four_point
    {x y z : ℝ}
    (hx : x ≤ max y z)
    (hy : y ≤ max x z)
    (hz : z ≤ max x y) :
    -- adapt to the exact encoding of FourPointCondition
    True
```

If `FourPointCondition` is encoded directly as one inequality per quadruple, then this abstract helper may not be needed.

## Mathematical insight to exploit

The rank-2 tropical Plücker relation is already the four-point relation in disguise. For a metric `d`, the three quantities
- `d ab + d cd`,
- `d ac + d bd`,
- `d ad + d bc`
are exactly the pairings of a 4-set into 2+2 partitions. The tropical Grassmannian condition says these three expressions satisfy a balancing law; the four-point condition says the two largest are equal, or equivalently each one is bounded by the max of the other two. The reverse direction is thus not deep analytically — but it is deep structurally. It identifies a geometric moduli condition with a metric-tree condition.

## Cross-domain connections

### Algebraic geometry
This is the rank-2 case of the tropical Grassmannian `Trop(Gr(2,n))`, whose points correspond to valuated matroids and, after metric normalization, to tree metrics. Formalizing this theorem prepares the ground for a certified statement of the Speyer–Sturmfels correspondence.

### Phylogenetics
The four-point condition is the core correctness criterion for additive distances on leaf-labeled trees. Once formalized, one can certify neighbor-joining-style reconstruction theorems from tropical data.

### Matroid theory
Rank-2 valuated matroids are the hidden combinatorial skeleton here. This theorem is the first local certificate that tropical Plücker vectors behave like metric realizations of combinatorial geometries.

### Optimization / discrete convexity
The “max attained at least twice” condition is a tropical balancing constraint akin to local submodularity. This suggests future formal connections with M-convexity, polymatroids, and shortest-path/tree polyhedra.

### Formal methods
A machine-checked bridge between tropical geometry and tree metrics is exactly the kind of theorem that can anchor a larger verified library of moduli spaces, combinatorial geometries, and reconstruction algorithms.

## How to leverage existing catalog theorems

The listed catalog theorems are broad and may not directly solve this theorem, but use them strategically:
- `fundamental_cross_domain_bridge`: inspect whether it already packages a generic “algebraic structure implies combinatorial condition” pattern. If so, mirror its theorem architecture and proof style.
- `tropical_classical_bridge`: likely useful as a design precedent for translating tropical statements into ordinary inequalities on `ℝ`.
- `tropical_fundamental_theorem`: may contain established conventions for min-plus/max-plus normalization. Reuse those conventions to avoid sign mistakes.
- The arithmetic/oracle theorems are less likely to be directly relevant, but may provide imported lemmas or tactics patterns.

Do not force these dependencies if they are orthogonal. Better a clean foundational theorem than an artificial catalog citation.

## Implementation guidance in Lean 4

- Prefer `Fin n → Fin n → ℝ` over abstract types initially.
- Use helper `have` statements to normalize sums after permutations.
- Expect `linarith` to help once symmetry rewrites are done, though much of the proof is pure `simp`/`ring_nf`/`omega`-free algebra.
- Add local simp lemmas:
  ```lean
  @[simp] lemma symm_d ... : d i j = d j i := hsym i j
  ```
- If the current `FourPointCondition` is defined using distinct indices, first prove the unrestricted inequality version, then derive the distinct-index theorem as a corollary.
- If tropical coordinates on unordered pairs are already defined, consider proving a second theorem in that API:
  ```lean
  theorem tropical_plucker_coordinates_imply_four_point ...
  ```
  and derive the metric version from it.

## Stronger follow-up theorem if time permits

Once the reverse direction is done, aim immediately for the equivalence:

```lean
theorem four_point_iff_tropical_plucker_rank_two
    {n : ℕ} (d : Fin n → Fin n → ℝ)
    (hsym : ∀ i j, d i j = d j i)
    (hdiag : ∀ i, d i i = 0) :
    FourPointCondition d ↔
    ∀ a b c e, d a b + d c e ≤ max (d a c + d b e) (d a e + d b c)
```

This would be a genuinely beautiful API theorem: one line expresses the equivalence between tree-metric combinatorics and tropical Grassmannian algebra.

## Application keywords
`tropical geometry`, `tropical Grassmannian`, `Dressian`, `valuated matroid`, `four-point condition`, `tree metric`, `phylogenetics`, `metric geometry`, `max-plus algebra`, `formalized mathematics`, `Lean 4`, `combinatorial optimization`

## Deliverables

1. The main theorem with exact Lean statement adapted to the existing `FourPointCondition`.
2. 2–5 helper lemmas for permutation/reindexing of the Plücker inequality.
3. Minimal sorry count; ideally zero.
4. A short module-level comment explaining the mathematical bridge.
5. A `FUTURE_DIRECTIONS.md` with **3–5 concrete breakthrough next steps**, such as:
   - formalize `Trop(Gr(2,n)) ↔ tree metrics`,
   - prove Buneman reconstruction correctness in Lean,
   - connect rank-2 valuated matroids to finite trees,
   - define and certify the Dressian as a relaxation of the tropical Grassmannian,
   - develop a verified tropical-to-phylogenetic reconstruction pipeline.

Be bold: this theorem is the seed of a fully formal tropical phylogenetic geometry library.

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
