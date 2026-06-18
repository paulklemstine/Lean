## Assignment: **prove**

### Title
**Rank–Entropy Laws, Tropical Fiber Entropy, and Reversible Thermodynamics over Finite Fields**

Prove genuinely new theorems that weld together finite linear algebra, information theory, reversible computation, and tropical semantics. The target is not a routine identity: it is a formal bridge showing that rank deficiency is literally entropy production, that fiber geometry controls erasure cost, and that tropicalization extracts the worst-case thermodynamic shadow of a computation.

Minimize `sorry`. Build explicitly on catalog lemmas about finite entropy, complexity bounds, reversible implementations, and any existing `tropical_landauer_bound`-style results in the repository.

---

## Core Breakthrough Theorem

### Theorem A: Exact rank–entropy law for finite-field linear maps

Let `q` be a prime power, let `K := GF q` when available in Mathlib as a finite field, and let
`A : V →ₗ[K] W` be a linear map between finite-dimensional finite `K`-vector spaces. If `X` is uniformly distributed on `V`, then the pushforward `A(X)` is uniformly distributed on `LinearMap.range A`, and the entropy drop is exactly the kernel dimension times `log q`.

This is the algebraic Landauer principle for linear maps.

### Precise mathematical statement
For finite-dimensional `K`-vector spaces `V, W` over a finite field `K` with `Fintype V` and `Fintype W`,
\[
H(X)-H(A(X)) = \dim_K(\ker A)\,\log |K|.
\]
Equivalently, since `H(X)=\dim_K(V)\log|K|` and `H(A(X))=\dim_K(\operatorname{range} A)\log|K|`,
\[
H(A(X)) = \operatorname{finrank}_K(\operatorname{range} A)\,\log |K|.
\]

### Lean 4 type-signature target
You may need to adapt to the exact entropy API in the catalog, but the theorem should aim at something structurally like:

```lean
theorem entropy_drop_linearMap_uniform_eq_finrank_ker_mul_log_card
  (K V W : Type*)
  [Field K] [Fintype K] [DecidableEq K]
  [AddCommGroup V] [Module K V] [FiniteDimensional K V] [Fintype V] [DecidableEq V]
  [AddCommGroup W] [Module K W] [FiniteDimensional K W] [Fintype W] [DecidableEq W]
  (A : V →ₗ[K] W) :
  entropy (uniformOn (Set.univ : Set V))
    - entropy (pushforward (uniformOn (Set.univ : Set V)) A)
    = (FiniteDimensional.finrank K A.ker : ℝ) * Real.log (Fintype.card K)
```

A more robust intermediate theorem, likely easier to prove and then feed into entropy, is:

```lean
theorem pushforward_uniform_linearMap_eq_uniformOn_range
  (K V W : Type*)
  [Field K] [Fintype K] [DecidableEq K]
  [AddCommGroup V] [Module K V] [FiniteDimensional K V] [Fintype V] [DecidableEq V]
  [AddCommGroup W] [Module K W] [FiniteDimensional K W] [Fintype W] [DecidableEq W]
  (A : V →ₗ[K] W) :
  pushforward (uniformOn (Set.univ : Set V)) A = uniformOn (Set.range A)
```

and the exact fiber cardinality statement:

```lean
theorem card_fiber_linearMap_eq_card_ker
  (K V W : Type*)
  [Field K] [Fintype K] [DecidableEq K]
  [AddCommGroup V] [Module K V] [FiniteDimensional K V] [Fintype V] [DecidableEq V]
  [AddCommGroup W] [Module K W] [FiniteDimensional K W] [Fintype W] [DecidableEq W]
  (A : V →ₗ[K] W) (y : W) (hy : y ∈ Set.range A) :
  Fintype.card {x : V // A x = y} = Fintype.card A.ker
```

Then derive the entropy identity via rank-nullity and cardinality formulas:
```lean
Fintype.card V = (Fintype.card K) ^ (FiniteDimensional.finrank K V)
Fintype.card A.ker = (Fintype.card K) ^ (FiniteDimensional.finrank K A.ker)
```

### Why this is a breakthrough
This turns linear rank deficiency into an exact thermodynamic state function. It says: for finite-field linear computation, information lost is not metaphorically related to kernel dimension; it **is** kernel dimension, measured in entropy units. That opens a formal route from coding theory and network coding directly into reversible computing lower bounds and finite thermodynamics.

This is the right theorem because it is exact, structural, compositional, and machine-checkable.

---

## Expansion Theorem

### Theorem B: Tropical entropy loss equals max fiber log-cardinality, and coincides with classical loss for uniform-fiber maps

For any function `f : α → β` between finite types, define tropical entropy loss
\[
L_{\mathrm{trop}}(f) := \log \max_{y \in \operatorname{im}(f)} |f^{-1}(y)|.
\]
For uniform input on `α`, classical entropy loss is
\[
L_{\mathrm{Sh}}(f) := H(X)-H(f(X)).
\]

Prove:

1. **Lower-bound theorem**
   \[
   L_{\mathrm{Sh}}(f) \le L_{\mathrm{trop}}(f).
   \]
   because the average fiber size is at most the maximum fiber size, and for uniform input
   \[
   L_{\mathrm{Sh}}(f)=\log |\alpha|-\log |\operatorname{im}(f)|
   = \log \frac{|\alpha|}{|\operatorname{im}(f)|}.
   \]

2. **Uniform-fiber equality**
   If all nonempty fibers of `f` have the same cardinality, then
   \[
   L_{\mathrm{Sh}}(f)=L_{\mathrm{trop}}(f).
   \]

3. **Linear specialization**
   For linear maps over finite fields,
   \[
   L_{\mathrm{trop}}(A)=\dim\ker(A)\,\log |K| = L_{\mathrm{Sh}}(A).
   \]

This is crucial: linear maps are exactly the regime where classical and tropical entropy coincide. That makes linear algebra the testing ground for a future tropical information theory.

### Lean 4 type-signature target
Again adapt to the exact entropy definitions in the codebase, but aim for something like:

```lean
def tropicalEntropyLoss (f : α → β) : ℝ :=
  Real.log <| sSup {n : ℝ | ∃ y : β, n = Fintype.card {x : α // f x = y}}

theorem shannon_entropy_loss_le_tropicalEntropyLoss_uniform
  (α β : Type*) [Fintype α] [Fintype β] [DecidableEq α] [DecidableEq β]
  (f : α → β) :
  entropy (uniformOn (Set.univ : Set α))
    - entropy (pushforward (uniformOn (Set.univ : Set α)) f)
    ≤ tropicalEntropyLoss f
```

and

```lean
theorem tropicalEntropyLoss_linearMap_eq_finrank_ker_mul_log_card
  (K V W : Type*)
  [Field K] [Fintype K] [DecidableEq K]
  [AddCommGroup V] [Module K V] [FiniteDimensional K V] [Fintype V] [DecidableEq V]
  [AddCommGroup W] [Module K W] [FiniteDimensional K W] [Fintype W] [DecidableEq W]
  (A : V →ₗ[K] W) :
  tropicalEntropyLoss A = (FiniteDimensional.finrank K A.ker : ℝ) * Real.log (Fintype.card K)
```

### Why this is a breakthrough
This theorem isolates a **min-plus shadow of entropy**. In classical information theory, entropy is an average. In tropical information theory, the controlling quantity is worst-case fiber thickness. Showing that these coincide exactly for finite-field linear maps is a nontrivial unification of average-case and worst-case semantics. It suggests a new research program: tropicalized Landauer principles, tropical channel capacity, and max-fiber invariants as thermodynamic obstructions.

---

## Reversible-computing theorem

### Theorem C: Reversible implementation cost is controlled by fiber entropy, with strict improvement under compressible garbage

Suppose `f : α → β` is implemented by a reversible map on `α × γ`, and the garbage component factors through an injective compressor to a finite type of cardinality `2^k` (or more generally cardinality `≤ M`). Then the thermodynamic/description-complexity overhead is bounded by the compressed garbage size rather than the raw garbage size.

Target a theorem that sharpens any existing catalog lemma of the form
`compressor_gives_complexity_bound` or `complexity_bound_implies_finite_entropy_bound`.

### Precise statement idea
If there exists a reversible implementation
\[
R : \alpha \times \gamma \xrightarrow{\sim} \alpha \times \gamma
\]
realizing `f` together with garbage `g(a)`, and an injective compressor
\[
C : \operatorname{range}(g) \hookrightarrow \delta,
\]
then the erasure/complexity cost of the garbage is bounded by `log |δ|`, not `log |γ|`.

For parity on `Fin n → Bool`, construct an explicit compressor removing one redundant bit from the garbage representation and prove a strict improvement.

### Lean target
Something like:

```lean
theorem reversible_garbage_compression_improves_complexity_bound
  (α β γ δ : Type*)
  [Fintype α] [Fintype β] [Fintype γ] [Fintype δ]
  (f : α → β)
  (g : α → γ)
  (C : Set.range g ↪ δ)
  (hR : ∃ R : α × γ ≃ α × γ, True) :
  complexityBound f ≤ Real.log (Fintype.card δ)
```

This may need to be recast in the exact language of the catalog. The key demand is not the exact API but the sharpened theorem: **injective compressibility of garbage yields a strictly stronger thermodynamic bound**.

### Why this matters
This would formalize the slogan “predictable garbage is cheap to erase.” That is a decisive conceptual move in reversible computing: not all ancilla are equal. Structured ancilla have lower effective thermodynamic cost. This has direct relevance to circuit synthesis, quantum compilation, and low-dissipation architecture design.

---

## Proof architecture: 3 viable strategies

### Strategy A: Fiber-counting → uniform-on-range → entropy
This is the most promising route for Theorem A.

1. Prove every nonempty fiber of a linear map `A` is an affine translate of `A.ker`, hence has cardinality `card A.ker`.
2. Deduce that the pushforward of the uniform measure on `V` is uniform on `Set.range A`.
3. Compute entropy of a uniform distribution on a finite set as `log(card set)`, then invoke rank-nullity and finite-field cardinality formulas.

Why this is strongest: it separates the algebra from the probability cleanly and uses standard Mathlib machinery (`LinearMap.ker`, `LinearMap.range`, `FiniteDimensional.finrank`, `Fintype.card`, rank-nullity).

### Strategy B: Quotient-space proof via `V ⧸ ker A`
Potentially cleaner and more conceptual.

1. Use the first isomorphism theorem to identify `V ⧸ A.ker ≃ₗ[K] LinearMap.range A`.
2. Show uniform measure on `V` descends to uniform measure on the quotient by equal-sized cosets.
3. Transport entropy through the linear equivalence and compute cardinalities using quotient dimension.

Why this is powerful: it reveals entropy loss as quotienting by indistinguishable states, exactly the thermodynamic interpretation. If Mathlib’s quotient-space/cardinality API is cooperative, this proof is conceptually superior.

### Strategy C: Cardinality identity first, entropy later
Best for reducing dependence on the probability library.

1. Prove `|range A| = |V| / |ker A|` by rank-nullity or direct finite-field cardinality algebra.
2. Define entropy loss for uniform input as `log |V| - log |range A|`.
3. Conclude
   \[
   \log |V| - \log |range A| = \log |ker A| = \dim \ker A \cdot \log |K|.
   \]

Why this may be easiest in Lean: if entropy APIs are awkward, prove the combinatorial theorem first and wrap the probabilistic corollary afterward.

---

## Concrete build plan in Lean

### Phase 1: ZMod 2 pilot theorem
Start with the fully explicit finite case:
```lean
theorem entropy_drop_matrix_ZMod2
  (m n : ℕ) (A : Matrix (Fin m) (Fin n) (ZMod 2)) :
  ...
```
Verify computationally for all `2 × 3` matrices over `ZMod 2`. This is not the final theorem, but it de-risks the API and gives executable evidence.

### Phase 2: Abstract finite-field linear map theorem
Generalize from matrices to arbitrary finite-dimensional spaces over finite fields.

Key supporting lemmas likely needed:
- fibers of linear maps are cosets of kernels,
- `Fintype.card` of finite-dimensional vector spaces over finite fields,
- entropy of uniform distribution on finite support,
- image/range finite cardinality formula.

### Phase 3: Tropicalization layer
Define `tropicalEntropyLoss` in a way that is easy to compute from finite fibers. Prove:
- `classical ≤ tropical` for arbitrary finite maps under uniform input,
- equality for constant-fiber maps,
- exact equality for linear maps.

### Phase 4: Reversible garbage compression
Instantiate existing complexity/entropy theorems in the catalog. The novelty is to replace ambient garbage cardinality by compressed image cardinality via an injective code on structured garbage.

---

## Cross-domain connections you should exploit aggressively

### Coding theory
A linear code’s syndrome map is a linear map. Its kernel dimension is the number of hidden degrees of freedom. Theorem A says syndrome extraction has exact entropy drop equal to redundancy. This reframes parity checks as thermodynamic coarse-graining.

### Statistical mechanics
Kernel cosets are microstates; the image is the macrostate. Entropy drop under `A` is exactly the logarithm of microstate multiplicity per macrostate. This is a finite, formal Boltzmann principle:
\[
S = \log |\text{microstates consistent with macrostate}|.
\]

### Reversible and quantum computing
Garbage compression is the finite classical analogue of reducing ancilla entropy before reset. The theorem suggests a formal pathway from reversible circuit synthesis to resource theories of thermodynamic cost.

### Tropical geometry / min-plus algebra
`max_y log |f^{-1}(y)|` is a tropicalized entropy functional: it replaces averaging by extremal fiber geometry. Linear maps over finite fields are the exact fixed points where tropical and Shannon semantics agree.

### Complexity theory
Fiber size measures nondeterministic ambiguity and information loss. Theorems B/C suggest a bridge from communication complexity and branching-program width to thermodynamic lower bounds.

---

## Application keywords
finite-field entropy, Landauer principle, reversible computing, garbage compression, tropical information theory, rank-nullity thermodynamics, coding theory, affine fibers, coarse-graining, entropy production, finite-state statistical mechanics, min-plus semantics, algorithmic thermodynamics

---

## Specific nontrivial deliverables

1. **A Lean theorem** proving exact entropy drop for finite-field linear maps.
2. **A Lean theorem** proving pushforward of uniform measure by a linear map is uniform on the range.
3. **A Lean definition and theorem suite** for tropical entropy loss.
4. **A Lean theorem** showing equality of tropical and classical entropy loss for constant-fiber maps, and in particular for linear maps.
5. **A sharpened reversible-computing bound** using injective garbage compression.
6. **Executable examples**:
   - all `2 × 3` matrices over `ZMod 2`,
   - parity garbage compression,
   - one nonuniform-fiber finite function showing strict inequality between classical and tropical loss.

---

## What to build on from the catalog
Use any existing theorems with names or shapes resembling:
- `compressor_gives_complexity_bound`
- `complexity_bound_implies_finite_entropy_bound`
- `tropical_landauer_bound`
- entropy lemmas for finite uniform distributions
- cardinality/rank lemmas for `LinearMap.ker`, `LinearMap.range`, and `Module.finrank`

Do not merely cite them. Show exactly how they enter:
- use complexity lemmas to convert compressed garbage cardinality into thermodynamic cost,
- use tropical Landauer-style lemmas to interpret max-fiber size as an erasure lower bound,
- use finite entropy lemmas to compute `H(uniform)` as `log(card)`.

---

## Standards for the final artifact
Produce theorem statements with precise quantifiers and near-compilable Lean 4 signatures. Prefer a chain of strong intermediate lemmas over one giant theorem. If a general finite-field API is awkward, prove the matrix/`ZMod p` theorem first and then abstract.

And crucially: produce a structured `FUTURE_DIRECTIONS.md` with **3–5 falsifiable scientific hypotheses**, each with:
- a precise conjecture,
- a concrete Lean/formal test,
- a criterion for success or refutation.

The hypotheses must be testable, not vague. Examples of the right level:
- a data-processing inequality for tropical entropy loss under composition,
- an exact characterization of maps where tropical and Shannon loss coincide,
- a subadditivity or additivity law for reversible implementations with correlated garbage,
- a coding-theoretic interpretation of entropy loss for parity-check matrices,
- a finite quantum analogue replacing fibers by stabilizer degeneracy.

This is the moment to turn rank-nullity into thermodynamics, fibers into entropy geometry, and reversible computation into a theorem factory.

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

Research domain: Speculative
Research mode: prove
