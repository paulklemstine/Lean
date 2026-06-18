## Assignment: Research Team Organization

Prove new, non-trivial theorems that turn the current tropical formalization from an evaluation engine into a structural theory. Build on the catalog theorems aggressively. Minimize `sorry`. Favor statements whose Lean formalization forces reusable definitions and lemmas.

This cycle should not merely extend existing tropical polynomial evaluation; it should extract algebra, dynamics, and certification principles from it.

---

## Mode: `prove` + selective `sorry_fill`

There are two simultaneous missions:

1. **Breakthrough mission:** prove a genuinely new structural theorem about tropical dynamics / dominance / fixed points.
2. **Infrastructure mission:** if needed, discharge high-value `sorry` targets such as `CarmichaelComposite` and `Fib_gcd_identity` only when they unlock reusable arithmetic infrastructure for the main theorem.

---

## Strategic Thesis

The existing verified results already hint at a hidden unification:

- `bool_and_as_tropical_max` says tropical max can encode logic.
- `tropical_and_bound` says tropical logical composition has quantitative lower bounds.
- `tropical_power_iteration_step` suggests tropical linear-algebraic dynamics.
- `tropical_berggren_n_step_displacement` suggests growth/displacement under iterated tropical transformations.
- `tropical_zeta_term` hints at asymptotic or analytic control over tropicalized arithmetic sums.

The field-opening move is to prove that **iterated tropical operators admit monotone quantitative certificates**: each step preserves order, compounds lower bounds, and yields explicit displacement or convergence estimates. This would create a formally verified bridge between:

- tropical geometry,
- Boolean/logical semantics,
- nonlinear spectral theory,
- certified algorithms.

That bridge is much more important than any one lemma.

---

## Direction 1 — Immediate Priority: Tropical Monotone Iteration and Dominance Certificates

### Vision
Formalize and prove that a tropical update operator built from finite maxima of affine forms is monotone, nonexpansive or order-amplifying under explicit hypotheses, and yields certified lower bounds after iteration. This would be the first step toward a Lean-native tropical Perron–Frobenius theory.

### Target theorem
For a finite family of affine tropical forms on `ℝ^n`, define
\[
T(x)_i = \max_{j \in S_i} (a_{ij} + \langle w_{ij}, x\rangle),
\]
or in a simpler coordinatewise max-plus form,
\[
T(x)_i = \max_{j \in S_i}(A_{ij} + x_j).
\]
Then prove monotonicity and an iterated lower-bound certificate:
\[
x \le y \implies T^n(x) \le T^n(y),
\]
and if \(x \le T(x)\), then
\[
x \le T^n(x)\quad\text{for all }n.
\]

### Lean-oriented precise theorem statement
A concrete, realistic first formal target:

```lean
theorem tropical_matrix_map_monotone_iterate
    {n : ℕ}
    (A : Matrix (Fin n) (Fin n) ℝ)
    (x y : Fin n → ℝ)
    (hxy : ∀ i, x i ≤ y i) :
    ∀ k : ℕ, ∀ i,
      ((Nat.iterate
        (fun v : Fin n → ℝ => fun r => Finset.univ.sup fun j => A r j + v j) k x) i)
      ≤
      ((Nat.iterate
        (fun v : Fin n → ℝ => fun r => Finset.univ.sup fun j => A r j + v j) k y) i)
```

A second, stronger certificate theorem:

```lean
theorem tropical_matrix_map_postfixed_iterate
    {n : ℕ}
    (A : Matrix (Fin n) (Fin n) ℝ)
    (x : Fin n → ℝ)
    (hx : ∀ i, x i ≤ Finset.univ.sup (fun j => A i j + x j)) :
    ∀ k : ℕ, ∀ i,
      x i ≤
      ((Nat.iterate
        (fun v : Fin n → ℝ => fun r => Finset.univ.sup fun j => A r j + v j) k x) i)
```

If `Finset.univ.sup` over `ℝ` is awkward because of typeclass details, replace `ℝ` with `WithBot ℝ` or define the operator using `Finset.max'` with a `Nonempty` witness. But the theorem should remain essentially this statement.

### Why this is a breakthrough
This creates a certified tropical dynamics framework in Lean. It is not “another tropical lemma”; it is the foundational theorem behind:

- tropical fixed-point iteration,
- static analysis via max-plus abstractions,
- shortest/longest path style dynamic programming,
- robustness certificates for tropicalized networks,
- nonlinear eigenvalue approximation.

It turns the current codebase into the seed of a formal tropical operator theory.

### Proof strategies

#### Strategy A: Direct order-theoretic induction on `k`  
Most promising.

1. Prove a one-step monotonicity lemma:
   ```lean
   theorem tropical_matrix_map_monotone ...
   ```
   by showing each term `A i j + x j ≤ A i j + y j`, then taking `sup`.
2. Lift one-step monotonicity to iterates using `Nat.rec` on `k`.
3. For postfixed iteration, use induction:
   - base case `k = 0` is reflexive,
   - step uses `x ≤ T^k x` and monotonicity of `T` to get `T x ≤ T^(k+1) x`,
   - combine with `hx : x ≤ T x`.

Why most promising: this route is elementary, Lean-friendly, and creates reusable lemmas (`map_monotone`, `iterate_monotone`, `postfixed_iterate`).

#### Strategy B: Abstract complete-lattice / order-hom proof
1. Define the tropical map as an order-preserving endomorphism on `(Fin n → ℝ)` with pointwise order.
2. Use generic theorems about monotone maps and iterates.
3. Specialize to the tropical matrix map.

Why valuable: if successful, it opens a library for arbitrary tropical operators, not just matrices.  
Risk: `ℝ` with finite suprema is manageable, but complete-lattice abstraction may become typeclass-heavy.

#### Strategy C: Dynamic-programming path expansion
1. Prove by induction that `T^k(x)_i` equals the maximum weight over length-`k` paths ending at `i`.
2. Deduce monotonicity because the terminal contribution from `x` is monotone.
3. Deduce postfixedness by extending paths.

Why exciting: this produces algorithm extraction and graph-theoretic meaning.  
Risk: more definitions upfront. Best as a second theorem after Strategy A.

### Cross-domain connections
- **Nonlinear Perron–Frobenius theory:** monotone homogeneous maps and tropical eigenvectors.
- **Program verification:** post-fixed points certify inductive invariants.
- **Control theory / dynamic programming:** Bellman operators are max-plus maps.
- **Neural verification:** tropicalized ReLU layers are max-affine maps.

### Application keywords
`tropical dynamics`, `max-plus algebra`, `monotone operators`, `Bellman recursion`, `formal verification`, `nonlinear spectral theory`, `certified iteration`

---

## Direction 2 — Long-Term Structural Goal: Tropical Fixed Points and Cycle Means

### Vision
Prove a finite-dimensional tropical Collatz–Wielandt style inequality or a fixed-point existence theorem under normalization. This would be a genuine field-opening result in Lean.

### Ambitious theorem target
For a max-plus matrix map \(T(x)_i = \max_j (A_{ij}+x_j)\), define a normalized iterate removing additive drift. Prove existence of a scalar `λ` and vector `v` such that
\[
T(v) = v + \lambda,
\]
under finite-dimensional hypotheses.

### Lean-style aspirational signature
```lean
theorem exists_tropical_eigenvector
    {n : ℕ} (hn : 0 < n)
    (A : Matrix (Fin n) (Fin n) ℝ) :
    ∃ (λ : ℝ) (v : Fin n → ℝ),
      ∀ i, Finset.univ.sup (fun j => A i j + v j) = v i + λ
```

### Why this would be revolutionary
A fully formal tropical eigenvector theorem would connect Lean’s algebraic libraries with optimization, graph theory, and idempotent analysis. It would become the formal nucleus of tropical spectral theory.

### Proof strategies

#### Strategy A: Finite normalized orbit compactness
1. Normalize iterates by subtracting one coordinate or average.
2. Prove boundedness modulo constants.
3. Extract a recurrent point in finite-dimensional quotient-like space, then derive eigen-equation.

#### Strategy B: Maximum cycle mean via graph theory
1. Interpret `A` as weighted digraph.
2. Define cycle mean.
3. Build `λ` from maximal cycle mean and construct `v` as longest-path potential.

#### Strategy C: Collatz–Wielandt inequalities
1. Define subeigenvectors:
   \[
   T(v) \le v+\lambda.
   \]
2. Show infimum/supremum characterization of `λ`.
3. Upgrade to equality in finite dimension.

Most promising long-term path: **Strategy B**, because finite weighted digraphs are highly formalizable and connect naturally to matrices over `Fin n`.

### Cross-domain connections
- graph algorithms,
- mean-payoff games,
- idempotent functional analysis,
- performance analysis of discrete event systems.

### Application keywords
`tropical eigenvector`, `cycle mean`, `max-plus spectral radius`, `mean-payoff games`, `weighted digraphs`

---

## Direction 3 — Parallel Effort: Algorithm Extraction from Tropical Iteration

### Vision
Turn the proofs into executable certified procedures. The theorem should not only assert monotonicity but identify finite witnesses and computable bounds.

### Target theorem
Show that after `k` tropical matrix iterations, each coordinate is equal to the maximum over all length-`k` paths of a computable path weight plus initial value.

### Lean theorem target
```lean
theorem tropical_iterate_eq_max_path_weight
    {n : ℕ}
    (A : Matrix (Fin n) (Fin n) ℝ)
    (x : Fin n → ℝ) :
    ∀ k i,
      ((Nat.iterate
        (fun v : Fin n → ℝ => fun r => Finset.univ.sup fun j => A r j + v j) k x) i)
      =
      -- explicit maximum over length-k paths ending at i
      sorry
```

The RHS should be an explicit `Finset.sup` over path encodings such as functions `Fin (k+1) → Fin n` satisfying adjacency constraints, or a simpler unconstrained sequence encoding if all transitions are allowed.

### Why this matters
This extracts the semantics of tropical iteration into a combinatorial object. Once formalized, you can derive certified complexity bounds, dynamic programming algorithms, and graph-theoretic interpretations essentially for free.

### Proof strategies
1. Base case `k=0`: paths of length 0.
2. Step case: split a length `k+1` path into first edge + tail, then use `sup_assoc`-style rearrangement.
3. Package path-weight lemmas for future shortest/longest path formalization.

### Cross-domain connections
- certified dynamic programming,
- formal graph algorithms,
- weighted automata,
- path semantics in verification.

### Application keywords
`algorithm extraction`, `path semantics`, `dynamic programming`, `weighted automata`, `certified computation`

---

## Direction 4 — Parallel Effort: Algebraic Generalization to Ordered Additive Structures

### Vision
Do not trap the theory inside `ℝ`. Push tropical monotonicity and iteration to a general ordered additive setting, ideally `LinearOrder` + `CanonicallyOrderedAddMonoid` or a suitable `Sup`-bearing ordered additive structure.

### Target theorem
Generalize the monotone tropical iteration theorem from `ℝ` to any type where finite suprema and order-compatible addition exist.

### Lean-oriented theorem sketch
```lean
theorem tropical_matrix_map_monotone_iterate_general
    {α : Type*}
    [LinearOrder α] [AddCommMonoid α] [OrderBot α]
    [CovariantClass α α (· + ·) (· ≤ ·)]
    {n : ℕ}
    (A : Matrix (Fin n) (Fin n) α)
    (x y : Fin n → α)
    (hxy : ∀ i, x i ≤ y i) :
    ∀ k i,
      ((Nat.iterate
        (fun v : Fin n → α => fun r => Finset.univ.sup fun j => A r j + v j) k x) i)
      ≤
      ((Nat.iterate
        (fun v : Fin n → α => fun r => Finset.univ.sup fun j => A r j + v j) k y) i)
```

You may need to adjust typeclasses substantially; that adjustment is part of the research.

### Why this matters
This upgrades tropical iteration from a numerical theorem to an algebraic theorem. It opens the door to:
- valuation-theoretic settings,
- ordered semirings,
- abstract interpretation domains,
- optimization over generalized costs.

### Proof strategies
1. First prove the real-valued theorem cleanly.
2. Identify exactly which algebraic/order lemmas were used.
3. Refactor hypotheses to the weakest workable typeclass assumptions.

### Cross-domain connections
- order theory,
- idempotent semirings,
- abstract interpretation,
- category-flavored semantics of optimization.

### Application keywords
`ordered algebra`, `idempotent semiring`, `abstract interpretation`, `generic formalization`, `valuation theory`

---

## Direction 5 — Long-Term Bridge: Tropical Logic Meets Spectral Dynamics

### Vision
Exploit `bool_and_as_tropical_max` and `tropical_and_bound` to prove that Boolean circuits embedded into tropical operators inherit monotone iteration certificates. This is the science-fiction connection: logic gates become tropical dynamical systems with quantitative semantics.

### Target theorem
Define a Boolean-to-tropical embedding for monotone circuits and prove semantic preservation under evaluation and iteration.

### Concrete theorem sketch
For Boolean inputs encoded as reals (e.g. `false ↦ 0`, `true ↦ 1` or thresholded values), prove:
- tropical max realizes AND/OR under the chosen encoding,
- iterated circuit layers form a monotone tropical map,
- lower bounds propagate through depth.

### Lean theorem target
```lean
theorem monotone_boolean_circuit_tropical_sound
    (C : -- suitable monotone circuit type)
    (x y : -- Boolean or encoded real inputs)
    (hxy : -- pointwise order / implication relation) :
    eval_tropical C x ≤ eval_tropical C y
```

A more numerical extension:
```lean
theorem tropical_circuit_depth_lower_bound
    (C : -- layered monotone circuit)
    (x : -- encoded input)
    (h : -- input lower bounds) :
    -- explicit lower bound on tropical evaluation after depth d
    sorry
```

### Why this is a breakthrough
This would create a formal bridge between:
- circuit complexity,
- tropical geometry,
- quantitative semantics,
- certified robustness.

It would make the existing theorem `bool_and_as_tropical_max` the seed of an entirely new verified research program.

### Proof strategies
1. Define syntax and evaluation for monotone circuits.
2. Prove gate-level tropical correctness using catalog theorems.
3. Lift by structural induction to whole circuits and then layered depth bounds.

### Cross-domain connections
- circuit complexity,
- semantics of computation,
- tropical neural networks,
- robust logic inference.

### Application keywords
`tropical logic`, `circuit semantics`, `quantitative verification`, `monotone circuits`, `neural abstraction`

---

## How to Build on the Existing Verified Theorems

### 1. `bool_and_as_tropical_max`
Use this not as an isolated curiosity but as the base case of a circuit-semantics induction. It should justify gate-level correctness in Direction 5.

### 2. `tropical_and_bound`
Use it as the quantitative propagation lemma: once a logical/tropical conjunction is represented by a max-plus operation, this theorem gives a lower bound that can be iterated through layers.

### 3. `tropical_power_iteration_step`
This is the closest catalog theorem to Direction 1. Inspect its exact hypotheses and conclusion, then generalize from “one power iteration step” to:
- monotonicity of all iterates,
- postfixed-point certificates,
- path-expansion semantics.

### 4. `tropical_berggren_n_step_displacement`
This theorem suggests an inductive displacement estimate under iteration. Abstract its proof pattern: if a tropical transform increases a quantity by a controlled amount at each step, then `n`-step displacement follows. Reuse that architecture for lower bounds on iterated tropical maps.

### 5. `tropical_zeta_term`
This may become relevant if asymptotic bounds or weighted sums over paths appear. If Direction 3 leads to path-counting formulas, `tropical_zeta_term` could help certify coarse analytic growth estimates.

---

## Recommended Team Split

### Team A — Core Dynamics
Primary target: `tropical_matrix_map_monotone_iterate` and `tropical_matrix_map_postfixed_iterate`.

Deliverables:
- one-step monotonicity lemma,
- iterate monotonicity theorem,
- postfixed-point certificate theorem,
- minimal reusable API around tropical matrix maps.

### Team B — Path Semantics / Algorithms
Primary target: `tropical_iterate_eq_max_path_weight`.

Deliverables:
- path encoding,
- path-weight definition,
- iterate = max path weight theorem,
- executable examples on small matrices.

### Team C — Logic / Semantics Bridge
Primary target: monotone circuit tropical soundness.

Deliverables:
- circuit datatype,
- Boolean/tropical encoding,
- gate correctness lemmas,
- structural induction theorem.

### Team D — Algebraic Refactor
Primary target: weakest-typeclass generalization of Team A results.

Deliverables:
- identification of minimal order/addition assumptions,
- generalized theorem statements,
- portability notes for future semiring formalization.

---

## Concrete Lean Development Advice

- Use `Fin n → ℝ` before introducing `Matrix`; the operator can be defined directly and matrices added later.
- If `Finset.sup` on `ℝ` is inconvenient, define:
  - a `max'`-based version over `Finset.univ`,
  - or temporarily work in `WithBot ℝ`.
- Prove pointwise order lemmas early:
  ```lean
  theorem le_map_of_pointwise_le ...
  theorem iterate_preserves_le ...
  ```
- Keep definitions reducible enough for `simp`.
- Prefer explicit coordinatewise inequalities over premature abstraction.
- Once the core theorem is done, then refactor.

---

## Concrete First Theorem to Attempt

If you need one exact target to begin immediately, start here:

```lean
def tropicalMatMap {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) :
    (Fin n → ℝ) → (Fin n → ℝ) :=
  fun x i => Finset.univ.sup (fun j => A i j + x j)

theorem tropicalMatMap_monotone
    {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ)
    {x y : Fin n → ℝ}
    (hxy : ∀ i, x i ≤ y i) :
    ∀ i, tropicalMatMap A x i ≤ tropicalMatMap A y i
```

Then prove:

```lean
theorem tropicalMatMap_iterate_monotone
    {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ)
    {x y : Fin n → ℝ}
    (hxy : ∀ i, x i ≤ y i) :
    ∀ k i, (Nat.iterate (tropicalMatMap A) k x) i ≤ (Nat.iterate (tropicalMatMap A) k y) i
```

Then:

```lean
theorem tropicalMatMap_postfixed_iterate
    {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ)
    {x : Fin n → ℝ}
    (hx : ∀ i, x i ≤ tropicalMatMap A x i) :
    ∀ k i, x i ≤ (Nat.iterate (tropicalMatMap A) k x) i
```

This 3-theorem package is coherent, nontrivial, and foundational.

---

## Success Criteria

A successful cycle does at least one of the following:

1. Proves the 3-theorem monotone-iteration package cleanly in Lean.
2. Derives a path-expansion theorem for iterates.
3. Establishes a first tropical-circuit semantic preservation theorem.
4. Refactors the whole result to an abstract ordered algebraic setting.

Doing only local arithmetic lemmas without reaching one of these structural milestones is not enough.

---

## FUTURE_DIRECTIONS.md Requirement

Produce a structured `FUTURE_DIRECTIONS.md` with **3–5 concrete, specific, breakthrough-level next steps**. These must not be generic. They should look like:

- exact theorem candidates,
- required new definitions,
- anticipated blockers,
- which current lemmas enable them.

At least one future direction must target a theorem of the form `T(v) = v + λ` for tropical operators, and at least one must target a bridge to another domain such as circuits, graph algorithms, or certified control.

---

## Final Call

Do not settle for “tropical evaluation works.” Prove that tropical operators **organize computation**: they preserve order, amplify certificates, encode logic, and admit combinatorial semantics. That is the conceptual leap. Formalize the first irreversible step toward a verified tropical dynamics theory.

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
