## Assignment: Random matrix counting as a tropical-orbit rigidity program

Prove a genuinely new theorem family about **fiber bounds for orbit-prefix maps of tropical matrix actions**, and formalize it in Lean 4 with concrete finite types. The core vision is this:

> If a matrix-to-prefix map is combinatorially rich enough to hit many prefixes, then no single prefix fiber can be too large; conversely, explicit enumeration of tropical split data gives universal upper bounds on multiplicities.

This is not just counting matrices. It is a prototype for a **non-archimedean entropy principle**: surjectivity of a tropical dynamical encoding forces anti-concentration of preimages. That opens a bridge between tropical geometry, random matrix products, symbolic dynamics, orbit complexity, and proof-oriented machine learning.

### Precise theorem target

Work with finite tropical matrices encoded over `ℕ` using row/column split parameters, so that counting is finitary and Lean-friendly.

Define a concrete prefix model first. A very robust target is to encode a length-`e` orbit prefix by a pair of split parameters summing to `e`; this uses the verified theorem

- `tropical_split_count : theorem tropical_split_count (e : ℕ) : (Finset.range (e + 1)).card = e + 1`

as the counting skeleton.

You should introduce a finite “matrix code” type whose elements model combinatorial tropical matrix data of total energy/valuation `e`, and a prefix map to a finite prefix type of size `e+1`.

A strong first breakthrough theorem is:

```lean
theorem exists_large_prefix_fiber
  (e : ℕ)
  (M P : Finset (ℕ × ℕ))
  (hM : M.card = (e + 1)^2)
  (hP : P.card = e + 1)
  (φ : (ℕ × ℕ) → (ℕ × ℕ))
  (hφ : ∀ x ∈ M, φ x ∈ P) :
  ∃ p ∈ P, (M.filter fun x => φ x = p).card ≥ e + 1 := by
  sorry
```

This is the finite pigeonhole lower-bound form: if there are `(e+1)^2` matrix codes and only `e+1` prefixes, some prefix has fiber at least `e+1`.

But do not stop there. The more interesting theorem is the **uniform upper bound under canonical prefix coding**. Define the canonical map
`prefixOf e : (ℕ × ℕ) → ℕ` by `prefixOf e (a,b) = a` on the constrained domain `a+b=e`. Then prove exact fiber cardinality.

```lean
def splitDomain (e : ℕ) : Finset (ℕ × ℕ) :=
  (Finset.range (e + 1)).map
    ⟨fun a => (a, e - a), by
      intro a b h; simpa using Prod.mk.inj_iff.mp h⟩

def prefixOf : ℕ × ℕ → ℕ := fun x => x.1

theorem splitDomain_card (e : ℕ) :
  (splitDomain e).card = e + 1 := by
  sorry

theorem prefix_fiber_card_exact
  (e a : ℕ) (ha : a ≤ e) :
  ((splitDomain e).filter fun x => prefixOf x = a).card = 1 := by
  sorry
```

This says: in the canonical split model, the prefix map is perfectly rigid; each admissible prefix has exactly one preimage. That is a strong anti-concentration phenomenon.

Then prove the orbit-counting theorem that better matches the research direction:

```lean
def twoStepDomain (e : ℕ) : Finset ((ℕ × ℕ) × (ℕ × ℕ)) :=
  ((splitDomain e).product (splitDomain e))

def prefixSum : ((ℕ × ℕ) × (ℕ × ℕ)) → ℕ :=
  fun x => x.1.1 + x.2.1

theorem prefixSum_fiber_bound
  (e s : ℕ) :
  ((twoStepDomain e).filter fun x => prefixSum x = s).card ≤ e + 1 := by
  sorry
```

Interpretation: a two-step tropical matrix code produces a prefix statistic `s`, and even though many pairs of matrices exist, each prefix fiber is bounded by `e+1`. This is the first genuinely nontrivial combinatorial orbit-prefix upper bound.

If you can push further, prove the exact formula:

```lean
theorem prefixSum_fiber_card_exact
  (e s : ℕ) :
  ((twoStepDomain e).filter fun x => prefixSum x = s).card =
    if s ≤ e then s + 1 else if s ≤ 2*e then 2*e - s + 1 else 0 := by
  sorry
```

This is a discrete triangular law. It is mathematically significant because it identifies the exact distribution of a prefix statistic arising from tropical split composition. It is the combinatorial seed of a tropical local limit theory.

### Lean 4 formalization target

Use concrete, finite objects only:
- `Finset`
- pairs/products of `ℕ`
- optionally `Matrix (Fin n) (Fin n) ℕ` later, once the counting skeleton works

A stronger matrix-flavored target, if feasible, is to define diagonal or rank-one tropical matrix codes and map them to prefix valuations. But the finite split-domain theorem above should be the non-negotiable core.

Suggested Lean signatures:

```lean
def splitDomain (e : ℕ) : Finset (ℕ × ℕ) := ...

def twoStepDomain (e : ℕ) : Finset ((ℕ × ℕ) × (ℕ × ℕ)) := ...

def prefixOf : ℕ × ℕ → ℕ := ...

def prefixSum : ((ℕ × ℕ) × (ℕ × ℕ)) → ℕ := ...

theorem splitDomain_card (e : ℕ) :
  (splitDomain e).card = e + 1 := by
  sorry

theorem prefix_fiber_card_exact
  (e a : ℕ) (ha : a ≤ e) :
  ((splitDomain e).filter fun x => prefixOf x = a).card = 1 := by
  sorry

theorem prefixSum_fiber_bound
  (e s : ℕ) :
  ((twoStepDomain e).filter fun x => prefixSum x = s).card ≤ e + 1 := by
  sorry

theorem prefixSum_fiber_card_exact
  (e s : ℕ) :
  ((twoStepDomain e).filter fun x => prefixSum x = s).card =
    if s ≤ e then s + 1 else if s ≤ 2 * e then 2 * e - s + 1 else 0 := by
  sorry
```

### How to build on the catalog theorems

1. **`tropical_split_count`**  
   This is your anchor theorem. It already certifies that the number of elementary tropical split choices at level `e` is `e+1`. Use it to avoid reproving the basic cardinality of `Finset.range (e+1)` and to motivate `splitDomain`.

2. **`tropical_sort_complexity_bound`**  
   Use this conceptually to argue that orbit-prefix extraction is a low-complexity statistic: sorting/valuation extraction compresses matrix data into a coarse combinatorial invariant. This supports the thesis that “prefix maps” should have controlled fibers. Even if the theorem is not directly imported into the proof, cite it in `ARTICLE.md` or `FUTURE_DIRECTIONS.md` as evidence that tropical prefix extraction is algorithmically tame.

3. **`ultrametric_orbit_tail_bound`** and **`contraction_orbit_bound`**  
   These suggest a dynamical interpretation: tails of orbits are constrained under ultrametric/contraction hypotheses. Your counting theorem becomes the discrete front-end of that story: the number of initial prefixes with a given code is controlled before asymptotic contraction even begins. This is a bridge theorem between finite combinatorial enumeration and dynamical rigidity.

4. **`step_count_bound`**  
   This can inspire induction on the number of composition steps. After proving the two-step exact formula, propose and maybe prove an `N`-step support bound or quasipolynomial fiber bound. The `step_count_bound` theorem gives a precedent for quantitative control over iteration length.

### Proof strategy options

#### Strategy A: Direct finite combinatorics on constrained pairs
Most promising for Lean.

1. Define `splitDomain e = {(a,b) : a ∈ [0,e], b = e-a}` and show every element is uniquely determined by `a`.
2. Rewrite fibers of `prefixOf` or `prefixSum` as filtered ranges over `a`.
3. Count solutions to equations like `a₁ + a₂ = s` with `0 ≤ aᵢ ≤ e`, obtaining the triangular formula.

Why this is most promising:
- stays entirely in `Nat` and `Finset`
- avoids dependent finite types unless desired
- exact cardinality formulas are accessible with `Finset.filter`, `Finset.product`, and arithmetic lemmas

#### Strategy B: Encode domains as `Fin (e+1)` and transport cardinality
Cleaner conceptual structure, slightly more abstract.

1. Define an equivalence between `splitDomain e` and `Fin (e+1)` via `a ↦ (a, e-a)`.
2. Transport the prefix statistic to addition on `Fin`-indexed naturals.
3. Count fibers by counting bounded integer solutions.

Why useful:
- makes the exact cardinality theorem feel canonical
- prepares later generalization to `n`-step convolution and simplices

Potential issue:
- coercions between `Fin`, `Nat`, and `Finset` can cost time in Lean

#### Strategy C: Convolution viewpoint / generating functions
Best for future expansion, maybe not first formal proof.

1. Interpret `splitDomain e` as a uniform discrete measure on `{0,…,e}`.
2. Show the two-step prefix distribution is the self-convolution of the interval indicator.
3. Derive the triangular law by coefficient extraction.

Why it matters:
- this is the conceptual bridge to random matrix products, entropy, and local limit laws
- suggests general `k`-step theorems via iterated convolution

Why not first:
- Lean formalization of generating functions may be overkill unless you already see a smooth route

### Cross-domain connections to emphasize

1. **Tropical geometry ↔ random matrix products**  
   Prefix statistics of tropical matrix multiplication behave like valuation profiles of products. Counting fibers is a finite analogue of understanding how many products realize a given valuation pattern.

2. **Symbolic dynamics ↔ orbit complexity**  
   Prefix maps encode early orbit behavior. Fiber bounds imply that orbit languages are not arbitrarily degenerate, a kind of combinatorial expansiveness.

3. **Information theory ↔ anti-concentration**  
   A surjective prefix map with bounded fibers implies lower bounds on output entropy and upper bounds on collision probability. This is the tropical/non-archimedean analogue of “compression without excessive collisions.”

4. **Ultrametric dynamics ↔ proof learning**  
   The verified ultrametric/contraction theorems suggest that finite prefix control may feed into long-time orbit regularity. This could seed a new formal theory of proof-state orbit compression.

5. **Additive combinatorics ↔ tropical convolution**  
   The exact triangular law is a baby case of sumset counting. Generalizing from 2-step to `k`-step domains leads directly to Ehrhart-type and discrete Brunn–Minkowski phenomena in tropical settings.

### What would make this a breakthrough

If you prove the exact fiber law for two-step tropical split codes and package it as a statement about orbit-prefix multiplicities, you create a new certified bridge:

- from tropical matrix combinatorics
- to anti-concentration/entropy principles
- to dynamical orbit encoding
- to scalable `k`-step counting theorems

That is field-opening because it reframes tropical dynamics not just as geometry, but as a **counting theory of information flow through valuation collapse**.

The next leap after this would be to replace split pairs by actual finite tropical matrix families and prove that valuation-prefix statistics obey the same triangular or simplex-count laws. That begins a formal theory of **tropical random matrix universality**.

### Concrete execution plan

1. Formalize `splitDomain`, `twoStepDomain`, `prefixOf`, `prefixSum`.
2. Prove `splitDomain_card` using `tropical_split_count` or a direct map from `Finset.range (e+1)`.
3. Prove `prefix_fiber_card_exact`.
4. Prove `prefixSum_fiber_bound`.
5. If possible, prove `prefixSum_fiber_card_exact`.
6. Add comments explaining the orbit-prefix interpretation.
7. Create `FUTURE_DIRECTIONS.md` with 3–5 specific next theorems.

### Required FUTURE_DIRECTIONS.md

You must produce `FUTURE_DIRECTIONS.md` with 3–5 concrete next steps, each including:
- exact theorem statement
- why it would matter
- proof strategy sketch
- cross-domain connection

At minimum, include candidates like:

1. **k-step simplex fiber formula**  
   Count `k`-tuples in `splitDomain e` with fixed prefix sum; expected answer is a truncated polynomial/Ehrhart coefficient.

2. **Entropy lower bound from fiber upper bound**  
   For uniform sampling on `twoStepDomain e`, show collision probability of `prefixSum` is bounded by an explicit rational function of `e`.

3. **Matrix realization theorem**  
   Define a finite family of `2×2` tropical matrices over `ℕ` whose valuation-prefix map realizes the same triangular law.

4. **Ultrametric orbit bridge**  
   Combine finite prefix multiplicity bounds with `ultrametric_orbit_tail_bound` or `contraction_orbit_bound` to obtain a finite-to-asymptotic orbit rigidity theorem.

5. **Algorithmic counting theorem**  
   Use `tropical_sort_complexity_bound` to derive an efficient certified algorithm for computing prefix multiplicities.

### Application keywords

tropical geometry, random matrices, orbit complexity, anti-concentration, entropy, symbolic dynamics, ultrametric dynamics, additive combinatorics, discrete convolution, valuation theory, formalized mathematics, Lean 4, Mathlib, non-archimedean information theory

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

Research domain: Speculative
Research mode: prove
