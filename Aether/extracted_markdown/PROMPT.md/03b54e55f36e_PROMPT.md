## Assignment: Cross-Domain Payoff — Certified Tropical Perron–Frobenius for Discrete-Event Systems

Prove a genuinely new bridge theorem connecting tropical linear algebra, max-plus control theory, and formally verified scheduling guarantees.

The target is not a toy “eigenvalue exists” lemma. The target is a certified throughput theorem for finite-state discrete-event systems, formalized in Lean 4 using concrete matrix types over `ℝ`, with an explicit reduction from long-run schedule growth to a tropical spectral quantity.

This would open a formal pipeline from algebraic certification to real-time systems verification: manufacturing lines, packet-switching pipelines, synchronous dataflow, railway timetables, and static worst-case throughput certification for processor microarchitectures.

### Research Direction
**Control theory and scheduling**: In max-plus / tropical models of discrete-event systems, the tropical eigenvalue is the asymptotic cycle time, and its inverse is the throughput. A certified Perron–Frobenius theorem in Lean would turn this classical systems insight into machine-checked performance guarantees.

You should aim to formalize a theorem of the following shape:

- finite weighted directed system encoded by a real matrix `A : Matrix (Fin n) (Fin n) ℝ`
- system evolution `x_{k+1} = A ⊗ x_k` in max-plus semantics
- asymptotic growth rate is the maximum cycle mean of the precedence graph
- therefore throughput bounds are certified by a finite combinatorial optimization problem

This is a breakthrough because it fuses:
- tropical spectral theory,
- graph cycle optimization,
- discrete-event systems,
- certified scheduling,
- and eventually formal methods for cyber-physical systems.

### Mathematical Framing
Work in the max-plus semiring viewpoint, but use ordinary `ℝ` plus explicitly defined tropical operations to avoid semiring engineering overhead if needed.

Define:
- tropical matrix-vector action by
  `((A ⊗ x) i) = max_j (A i j + x j)`
- tropical matrix powers recursively
- cycle mean of a directed cycle
- maximum cycle mean `λ(A)`

Then prove that `λ(A)` governs asymptotic linear growth of iterates.

A finite, formalizable first breakthrough target is:

### Precise Theorem Statement
For a finite square real matrix `A`, define the tropical action
`T_A(x)_i = max_j (A i j + x_j)`.

Assume every row has at least one enabled predecessor, so the system is nondegenerate. Then there exists a scalar `λ : ℝ` and vector `v` such that
`T_A v = λ + v`,
and `λ` equals the maximum cycle mean of the weighted digraph associated to `A`.

This is the tropical Perron–Frobenius theorem specialized to finite real matrices, in a form directly usable for scheduling.

A stronger operational theorem you should target:

> **Certified throughput theorem.**
> For irreducible `A : Matrix (Fin n) (Fin n) ℝ`, if `x_{k+1} = T_A(x_k)`, then there exists `C : ℝ` such that for every coordinate `i`,
> `|x_k i - (k * λ + c_i)| ≤ C` eventually, where `λ` is the maximum cycle mean. Hence the asymptotic average completion time per step is `λ`, and throughput is `1 / λ` when `0 < λ`.

Even a weaker, fully formalized theorem saying
`∃ v λ, T_A v = λ + v ∧ λ = maxCycleMean A`
would already be substantial.

### Suggested Lean 4 Target Signatures
You may need to define some objects first. Concrete possible signatures:

```lean
def tropMatVec {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) (x : Fin n → ℝ) : Fin n → ℝ :=
  fun i => Finset.univ.sup fun j : Fin n => A i j + x j
```

If `sup` over `ℝ` via `Finset` is awkward, use `Finset.max'` with a nonempty witness.

```lean
def cycleWeightMean {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) :
    List (Fin n) → ℝ
```

```lean
def maxCycleMean {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) : ℝ
```

```lean
def IsTropicalEigenpair {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ)
    (λ : ℝ) (v : Fin n → ℝ) : Prop :=
  ∀ i, tropMatVec A v i = λ + v i
```

Primary theorem target:

```lean
theorem exists_tropical_eigenpair_eq_maxCycleMean
    {n : ℕ} (hn : 0 < n)
    (A : Matrix (Fin n) (Fin n) ℝ)
    (hirr : IrreduciblePrecedence A) :
    ∃ λ v, IsTropicalEigenpair A λ v ∧ λ = maxCycleMean A
```

Operational scheduling theorem target:

```lean
theorem tropical_throughput_certified
    {n : ℕ} (hn : 0 < n)
    (A : Matrix (Fin n) (Fin n) ℝ)
    (hirr : IrreduciblePrecedence A) :
    ∃ λ, λ = maxCycleMean A ∧
      ∀ v, IsTropicalEigenpair A λ v →
      ∀ i, tropMatVec A v i = λ + v i
```

If the full asymptotic theorem is too heavy in one cycle, prove a finite-step lower/upper bound theorem:

```lean
theorem maxCycleMean_le_average_growth
    {n : ℕ} (hn : 0 < n)
    (A : Matrix (Fin n) (Fin n) ℝ)
    (hirr : IrreduciblePrecedence A) :
    ∀ k > 0, maxCycleMean A ≤
      (1 : ℝ) / k * maxEntry (tropPow A k)
```

and then refine toward eigenpairs.

### Definitions You May Need
Use concrete, minimal definitions.

- `Edge A i j : Prop := True` if all entries are enabled, or a thresholded predicate if using `-∞` is simulated
- `WalkWeight A p`
- `CycleWeight A c`
- `CycleMean A c = CycleWeight A c / c.length`
- `IrreduciblePrecedence A` meaning the digraph is strongly connected
- tropical power `tropPow A k`
- `maxEntry`

A good engineering move is to start with **complete graphs over finite reals**. This removes missing-edge headaches and still captures many scheduling models after using large negative constants as disabled arcs.

### 2–3 Proof Strategy Paths

#### Strategy A: Cycle-mean → finite optimization → eigenpair extraction
1. Define weighted cycles on `Fin n` and prove the set of simple cycles is finite.
2. Show `maxCycleMean A` exists as a maximum over finitely many simple cycles.
3. Construct an eigenvector using path-balance / potential normalization relative to a critical node, then prove `T_A v = λ + v`.

Why promising:
- Fully finite and combinatorial.
- Avoids topological fixed-point machinery.
- Fits Lean well because finiteness on `Fin n` is strong.

Main challenge:
- Clean formalization of cycles and simple cycles.

#### Strategy B: Tropical Collatz–Wielandt principle
1. Define
   `cwUpper A x = max_i (tropMatVec A x i - x i)` and
   `cwLower A x = min_i (tropMatVec A x i - x i)`.
2. Prove for all `x`, `cwLower A x ≤ maxCycleMean A ≤ cwUpper A x`.
3. Show equality is attained by a critical potential `v`, yielding an eigenpair.

Why promising:
- Conceptually elegant and very close to Perron–Frobenius.
- Produces both theorem and certification bounds useful in applications.

Why revolutionary:
- Gives a formal optimization certificate for throughput, not just existence.

Main challenge:
- Need finite max/min lemmas and careful algebra on `Finset`.

#### Strategy C: Dynamic programming / longest-path growth
1. Interpret `(tropPow A k) i j` as maximum weight of a length-`k` walk from `j` to `i`.
2. Prove subadditivity / superadditivity relations for maximal walk weights.
3. Extract asymptotic slope as maximum cycle mean, then derive an eigenpair from eventual affine growth.

Why promising:
- Most directly tied to scheduling semantics.
- Gives immediate systems interpretation.

Most promising overall:
**Strategy A first, Strategy B second.**
A gives the cleanest Lean entry point and a concrete theorem. B should then be developed as the conceptual upgrade that turns the theorem into a reusable certification framework.

### Build Explicitly on Catalog Theorems
The injected catalog is sparse and partially cross-domain, but still use it deliberately.

- `tropical_eigenvalue_determines_char`  
  Use this as evidence that the catalog already recognizes “tropical eigenvalue determines structure.” Generalize that philosophy from character-theoretic determination to control-theoretic determination: here the tropical eigenvalue determines throughput. Even if the theorem is in a different subdomain, cite it as a structural pattern to emulate in naming and statement design.

- `tropical_mirror_theorem : max a a = a`  
  Tiny but useful as a canonical simplification rule in max-plus calculations. Use aggressively in simp-normal forms for tropical action identities.

- `tropical_fundamental_theorem_of_arithmetic`  
  Mine its proof style if it contains finite combinatorial decomposition arguments. The relevant lesson is not arithmetic content but Lean architecture for finite constructive existence.

- `tropical_and_bound`  
  Potentially useful as a pattern for certified inequalities. Your throughput theorem should also culminate in an explicit bound theorem, not just an existence statement.

- `tropical_fundamental_theorem`  
  Use as a naming precedent for boldness. Your theorem should aspire to be a foundational bridge theorem in the same spirit.

### Cross-Domain Connections
Do not present this as isolated tropical algebra. Connect it to at least one additional domain in the theorem statements, examples, or future directions.

1. **Formal methods / real-time verification**  
   Throughput certificates become machine-checked liveness/performance guarantees for pipelines and manufacturing cells.

2. **Operations research**  
   Maximum cycle mean is Karp’s classical cycle-time quantity. A Lean theorem here would bridge combinatorial optimization and certified scheduling.

3. **Graph theory / algorithmics**  
   The theorem turns a spectral problem into finite cycle optimization, inviting certified implementations of Karp’s algorithm.

4. **Distributed systems**  
   Event graphs and synchronization networks have asymptotic rates determined by the same tropical spectral quantity.

5. **Network calculus / queueing abstractions**  
   Tropical recurrences are close cousins of min-plus and max-plus service curves; a formal theorem could seed certified performance envelopes.

6. **Semantics of computation**  
   Long-run execution rate of dependency-constrained programs can be recast as tropical spectral growth.

### Concrete Intermediate Lemmas Worth Proving
These are not final goals; they are scaffolding for the breakthrough theorem.

```lean
theorem tropMatVec_mono
    {n : ℕ} {A : Matrix (Fin n) (Fin n) ℝ} :
    Monotone (tropMatVec A)
```

```lean
theorem tropMatVec_add_const
    {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ)
    (x : Fin n → ℝ) (c : ℝ) :
    tropMatVec A (fun i => x i + c) = fun i => tropMatVec A x i + c
```

```lean
theorem tropPow_walk_interpretation
    {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) :
    ∀ k i j, tropPow A k i j =
      maxWeightOfWalkLength A k j i
```

```lean
theorem maxCycleMean_exists_as_max
    {n : ℕ} (hn : 0 < n) (A : Matrix (Fin n) (Fin n) ℝ) :
    ∃ c, IsSimpleCycle c ∧
      maxCycleMean A = cycleWeightMean A c
```

```lean
theorem tropical_eigenpair_gives_linear_growth
    {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ)
    {λ : ℝ} {v : Fin n → ℝ}
    (hEig : IsTropicalEigenpair A λ v) :
    ∀ k, iterate (tropMatVec A) k v = fun i => k * λ + v i
```

That last theorem is especially valuable: once an eigenpair exists, the exact linear growth of a synchronized regime becomes trivial and application-ready.

### What Would Count as a Breakthrough
A result counts as breakthrough-level if it establishes one of the following in Lean:

- existence of a tropical eigenpair for finite irreducible real matrices,
- equality of tropical eigenvalue with maximum cycle mean,
- exact linear growth along an eigenvector orbit,
- or certified throughput bounds for a finite scheduling model.

Any of these would be a serious cross-domain bridge theorem. Doing two in one cycle would create a new formalized research nucleus.

### Implementation Guidance
Use concrete finite index types:
- `Fin n`
- `Matrix (Fin n) (Fin n) ℝ`
- `Finset.univ`

Prefer avoiding `-∞` on the first pass. Model disabled edges later by large negative constants or by a complete graph assumption.

For cycle formalization, you may represent a cycle as:
- a list of vertices with adjacency closure,
- or a function `Fin k → Fin n` with wraparound.

The function encoding may be cleaner for fixed-length arguments; the list encoding may be better for finite enumeration. Choose whichever aligns with Mathlib lemmas on `Finset`, `List`, and finite maxima.

### Application Keywords
tropical Perron–Frobenius, max-plus algebra, discrete-event systems, scheduling theory, throughput certification, maximum cycle mean, Karp algorithm, real-time systems, formal verification, manufacturing systems, processor pipelines, synchronous dataflow, graph optimization, certified control, performance guarantees

### Deliverables
1. Lean file(s) containing definitions and theorem proofs.
2. Minimize sorry; if a proof is blocked, isolate the exact combinatorial lemma needed.
3. Include at least one worked finite example matrix and derive its certified throughput.
4. Produce `FUTURE_DIRECTIONS.md` with **3–5 concrete breakthrough next steps**, such as:
   - certified Karp algorithm for `maxCycleMean`
   - min-plus duality and latency bounds
   - eventual periodicity of tropical powers
   - formal comparison with classical Perron–Frobenius over nonnegative matrices
   - integration with timed automata or synchronous dataflow semantics

`FUTURE_DIRECTIONS.md` is mandatory and should be structured as a research agenda, not vague suggestions.

### Final Charge
Do not settle for a local lemma. Build the first machine-checked theorem that says, in substance:

> the long-run performance of a finite synchronization-constrained system is exactly a tropical spectral invariant, and this fact is formally certified.

That theorem would not just extend the catalog. It would create a new bridge between algebra, optimization, and verification.

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
