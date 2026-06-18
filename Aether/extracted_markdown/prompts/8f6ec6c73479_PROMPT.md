## Mode: prove

Aristotle, do not treat this as a routine extension from two voices to four. Treat it as the birth of a formal **tropical theory of polyphonic optimization**: a bridge between species counterpoint, min-plus dynamic programming, weighted constraint satisfaction, and tensor factorization. The key is to isolate exactly what decomposes, what merely subadditively bounds, and what additional local penalties preserve certifiable optimality.

## Breakthrough Objective

Formalize and prove a **four-voice decomposition theorem** for chorale cost functionals, showing that when the global cost is assembled from pairwise voice-interaction terms and unary spacing/register penalties, the optimization problem admits a tropical factorization and a zero-cost rigidity theorem.

This opens a new field direction: **certified algorithmic harmony via tropical algebra**. If done correctly, this becomes a reusable formal framework for:
- polyphonic music generation with proof certificates,
- weighted CSP / factor graph optimization in Lean,
- min-plus tensor methods,
- formal dynamic programming over finite product state spaces,
- tropical analogues of partition functions and message passing.

Application keywords: `tropical dynamic programming`, `polyphonic optimization`, `weighted CSP`, `min-plus tensor`, `formal music theory`, `factor graphs`, `Viterbi decomposition`, `certified optimization`, `constraint satisfaction`, `tropical algebra`.

---

## Core Definitions to Introduce

Work with a concrete finite-time model. If the existing `Melody n` is already in the codebase, reuse it. Otherwise define or adapt around its API. The crucial abstraction is that a chorale is a 4-tuple of melodies indexed by `Fin 4`.

```lean
def Chorale (n : ℕ) := Fin 4 → Melody n
```

Let the six unordered voice pairs be represented by a fixed finite list or `Finset`:
```lean
def voicePairs : Finset (Fin 4 × Fin 4) :=
  {⟨0,1⟩, ⟨0,2⟩, ⟨0,3⟩, ⟨1,2⟩, ⟨1,3⟩, ⟨2,3⟩}
```
or better, define them intrinsically with `i.1 < j.1` to avoid hard-coded numerals.

Assume or define:
- `pairCost : Melody n → Melody n → ℝ`
- `spacingPenalty : Fin 4 → Melody n → ℝ`
- possibly `registerPenalty`, `crossingPenalty`, or `adjacentSpacingPenalty`

Then define the full cost:
```lean
def choraleCost {n : ℕ} (C : Chorale n) : ℝ :=
  (∑ p in voicePairs, pairCost (C p.1) (C p.2))
  + ∑ i : Fin 4, spacingPenalty i (C i)
```

If the intended spacing penalty depends on adjacent pairs only, split this carefully:
```lean
def adjacentPairs : Finset (Fin 4 × Fin 4) := ...
def spacingCost {n : ℕ} (C : Chorale n) : ℝ := ...
```

Do **not** hide structure. The theorem will only be true under explicit hypotheses such as nonnegativity and pairwise vanishing conditions.

---

## Theorem 1: Four-Voice Zero-Cost Rigidity

The first target should be a precise zero-cost theorem reducing to two-voice vanishing on each pair.

### Mathematical statement

Assume:
1. every pairwise cost is nonnegative,
2. every spacing penalty is nonnegative,
3. a chorale has zero pairwise cost on each of the six voice pairs,
4. a chorale has zero spacing penalty on each voice.

Then the total chorale cost is zero.

This sounds easy, but the nontrivial version is the converse rigidity statement:

> If the total chorale cost is zero and every summand is nonnegative, then every pairwise interaction cost and every spacing penalty vanishes individually.

That converse is the real structural theorem: it turns a global optimum certificate into six local certificates plus unary certificates.

### Lean 4 type signatures

Forward direction:
```lean
theorem choraleCost_eq_zero_of_pairwise_zero
    {n : ℕ} (C : Chorale n)
    (hpair_nonneg : ∀ i j : Fin 4, i ≠ j → 0 ≤ pairCost (C i) (C j))
    (hspace_nonneg : ∀ i : Fin 4, 0 ≤ spacingPenalty i (C i))
    (hpair_zero : ∀ i j : Fin 4, i.1 < j.1 → pairCost (C i) (C j) = 0)
    (hspace_zero : ∀ i : Fin 4, spacingPenalty i (C i) = 0) :
    choraleCost C = 0
```

Converse rigidity:
```lean
theorem pairwise_zero_of_choraleCost_eq_zero
    {n : ℕ} (C : Chorale n)
    (hpair_nonneg : ∀ i j : Fin 4, i ≠ j → 0 ≤ pairCost (C i) (C j))
    (hspace_nonneg : ∀ i : Fin 4, 0 ≤ spacingPenalty i (C i))
    (hzero : choraleCost C = 0) :
    (∀ i j : Fin 4, i.1 < j.1 → pairCost (C i) (C j) = 0) ∧
    (∀ i : Fin 4, spacingPenalty i (C i) = 0)
```

If the current library already has a two-voice theorem of the form
```lean
theorem totalCost_eq_zero_iff ...
```
then prove the four-voice theorem by rewriting the chorale cost as a finite sum of those two-voice costs plus unary penalties.

### Why this is a breakthrough

This is a formal **local-to-global optimality certificate** for polyphonic writing. In optimization language, it says that a zero global energy in a nonnegative factor graph forces each factor to vanish. In music language, it turns “perfect chorale” into a finite family of certifiable local constraints. In theorem-proving language, it gives a reusable pattern for decomposable objective functions.

---

## Theorem 2: Tropical Tensor Decomposition of Four-Voice Optimization

Now aim much higher. The DP statement should not be written vaguely as “min over S,A,T,B equals iterated mins.” That equality alone is just associativity/commutativity of `inf` over a finite product. The breakthrough theorem is that a cost assembled from local factors can be optimized by a **tropical tensor product** of those factors.

### Define a tropical tensor product

For finite state spaces `α`, `β`, and cost kernels `f : α → ℝ`, `g : β → ℝ`, define:
```lean
def tropTensor {α β : Type} [Fintype α] [Fintype β] (f : α → ℝ) (g : β → ℝ) :
    α × β → ℝ
| (a, b) => f a + g b
```

The tropical contraction / minimization should be:
```lean
def tropMin {α : Type} [Fintype α] (f : α → ℝ) : ℝ :=
  Finset.inf' Finset.univ (by simp) f
```
If `ℝ` causes order-theoretic friction with `Finset.inf'`, use `ℝ∞` (`ENNReal` is not right for subtraction, so maybe `WithTop ℝ` if needed), or simply formulate with `IsGreatest` / `∃ x, ... ≤ ...`. But for finite sets, `Finset.min'` on a linear order may be easiest if the codomain is a subtype or if you carry witnesses.

### Fundamental tensor-min theorem

For finite spaces:
```lean
theorem tropMin_tropTensor
    {α β : Type} [Fintype α] [Fintype β]
    [DecidableEq α] [DecidableEq β]
    (f : α → ℝ) (g : β → ℝ) :
    tropMin (tropTensor f g) = tropMin f + tropMin g
```
This is the true min-plus analogue of multiplicativity of partition functions under tensor products. It is the theorem that turns product-state optimization into additive scalar minima.

A more implementation-friendly witness form may be easier:
```lean
theorem exists_argmin_tropTensor
    {α β : Type} [Fintype α] [Fintype β]
    [DecidableEq α] [DecidableEq β]
    (f : α → ℝ) (g : β → ℝ) :
    ∃ a b, ∀ x : α × β,
      tropTensor f g (a,b) ≤ tropTensor f g x
```
and then derive the scalar equality.

### Chorale decomposition theorem

Suppose each voice has a local state space `State`, and the four-voice cost at one time step decomposes as a sum of unary and pairwise factors:
```lean
def localChoraleEnergy (x : Fin 4 → State) : ℝ :=
  (∑ p in voicePairs, φ p.1 p.2 (x p.1) (x p.2)) +
  ∑ i : Fin 4, ψ i (x i)
```

Then define a staged factorization, for example by grouping `(S,A)` and `(T,B)`:
```lean
def SA_cost (sa : State × State) : ℝ := ...
def TB_cost (tb : State × State) : ℝ := ...
def cross_cost (sa : State × State) (tb : State × State) : ℝ := ...
```

The ambitious theorem is:

```lean
theorem min_localChoraleEnergy_decomposes
    {State : Type} [Fintype State] [DecidableEq State] :
    (tropMin (fun x : (Fin 4 → State) => localChoraleEnergy x))
    =
    tropMin (fun sa : State × State =>
      SA_cost sa + tropMin (fun tb : State × State => TB_cost tb + cross_cost sa tb))
```

This is not merely “min_S min_A ...”; it is a certified elimination theorem for factorized energies, the formal core of variable elimination / junction-tree DP in tropical algebra.

If that is too large for one cycle, first prove the product-space minimization identity:
```lean
theorem tropMin_prod
    {α β : Type} [Fintype α] [Fintype β]
    [DecidableEq α] [DecidableEq β]
    (f : α × β → ℝ) :
    tropMin f = tropMin (fun a => tropMin (fun b => f (a,b)))
```
Then instantiate `α = State × State`, `β = State × State`.

This theorem is already scientifically meaningful: it is the finite exactness theorem behind dynamic programming.

---

## Recommended Lean 4 statement hierarchy

Pursue the results in this order.

### A. Pure finite minimization theorem
```lean
theorem finset_min_product
    {α β : Type} [Fintype α] [Fintype β]
    [DecidableEq α] [DecidableEq β]
    (f : α × β → ℝ) :
    tropMin f = tropMin (fun a => tropMin (fun b => f (a,b)))
```

### B. Tropical tensor additive theorem
```lean
theorem tropMin_tropTensor
    {α β : Type} [Fintype α] [Fintype β]
    [DecidableEq α] [DecidableEq β]
    (f : α → ℝ) (g : β → ℝ) :
    tropMin (fun x : α × β => f x.1 + g x.2) = tropMin f + tropMin g
```

### C. Four-voice zero-cost theorem
```lean
theorem choraleCost_eq_zero_of_pairwise_zero
    {n : ℕ} (C : Chorale n) ... : choraleCost C = 0
```

### D. Four-voice rigidity converse
```lean
theorem pairwise_zero_of_choraleCost_eq_zero
    {n : ℕ} (C : Chorale n) ... :
    (∀ i j : Fin 4, i.1 < j.1 → pairCost (C i) (C j) = 0) ∧
    (∀ i : Fin 4, spacingPenalty i (C i) = 0)
```

### E. Variable-elimination decomposition for local chorale energies
```lean
theorem chorale_min_elim_SA_TB
    {State : Type} [Fintype State] [DecidableEq State]
    (φ : Fin 4 → Fin 4 → State → State → ℝ)
    (ψ : Fin 4 → State → ℝ) :
    ...
```

---

## Proof Strategies

## Strategy A: Finite-sum rigidity via nonnegativity decomposition
Most promising for the zero-cost theorem.

1. Rewrite `choraleCost C` as a finite sum over six pair terms plus four unary terms.
2. Use `Finset.sum_eq_zero_iff_of_nonneg` or a custom lemma: if all summands are nonnegative and the total sum is zero, then each summand is zero.
3. For the forward theorem, simply substitute the local zero hypotheses and evaluate the sum.
4. For the converse theorem, extract vanishing of each term from total zero.

Why this is promising: it is robust, elementary, and should survive changes in the exact cost model. It also turns into a general reusable theorem for decomposable nonnegative energies.

## Strategy B: Product-space minimization by explicit argmin witnesses
Best for the tropical DP theorem.

1. Since the state spaces are finite, use `Fintype.exists_min_image` or `Finset.min'_mem` to choose minimizers.
2. Show that a minimizer of `f : α × β → ℝ` yields an outer minimizer in `α` and an inner minimizer in `β`.
3. Prove both inequalities:
   - global min ≤ iterated min by evaluating at the chosen pair,
   - iterated min ≤ global min because every pair is admissible for the nested minimization.
4. Specialize to `f (a,b) = g a + h b` to derive `tropMin_tropTensor`.

Why this is promising: it avoids sophisticated order theory and is natural in Lean over finite types.

## Strategy C: Tropical-semiring abstraction
Most visionary, but only pursue if the concrete ℝ version is stable.

1. Abstract `tropTensor` and `tropMin` as operations in the min-plus semiring or an idempotent semiring-like interface.
2. Prove the product/min theorems at this abstract level.
3. Instantiate to `ℝ`, `WithTop ℝ`, or a custom tropical type.

Why this is revolutionary: it lifts chorale optimization into general certified tropical linear algebra. But it may create typeclass overhead. Use only after the concrete theorems land.

---

## How to Build on Catalog Theorems

The injected catalog theorems are not directly about chorales, but they provide a narrative and algebraic bridge.

- `tropical_product_to_sum` should motivate the semantic move from ordinary multiplicative composition to additive tropical composition. Use it conceptually when introducing `⊗_trop`: in tropicalization, tensor/product structure becomes additive energy composition.
- `tropical_mirror_theorem` (`max a a = a`) is the idempotence signal. Even if your optimization is min-plus rather than max-plus, this is evidence that the codebase already tolerates tropical idempotent reasoning. Mirror this style for min-idempotent lemmas.
- `tropical_fundamental_theorem` and the GL₃ Satake file are especially important conceptually: they show the repository is willing to certify nontrivial tropical correspondences. Frame your chorale theorem as a **tropical representation theorem for polyphony**: four voices form a finite factor graph whose energy tropicalizes to a min-plus elimination calculus.
- `tropical_and_bound` suggests oracle / bound style arguments. If exact decomposition becomes difficult, prove sharp lower/upper bounds first:
  ```lean
  theorem tropMin_prod_le ...
  theorem le_tropMin_iterated ...
  ```
  then close equality.

This is how to make the project feel native to the catalog rather than isolated.

---

## Cross-Domain Connections You Should Explicitly Exploit

1. **Weighted CSP / Factor Graphs**  
   Your chorale cost is exactly a factor graph energy:
   - variables = voices or voice-time states,
   - unary factors = spacing/register penalties,
   - pairwise factors = contrapuntal interactions.
   The zero-cost theorem becomes a satisfiability certificate; the min theorem becomes exact variable elimination.

2. **Statistical Mechanics / Zero-Temperature Limit**  
   `min` is the zero-temperature limit of `log-sum-exp`. Your tropical tensor product is the zero-temperature analogue of factorized partition functions. State this explicitly: chorale optimization is a formal zero-temperature Gibbs theory on polyphonic state spaces.

3. **Dynamic Programming / Viterbi Semiring**  
   The theorem `min_{x,y} f(x,y) = min_x min_y f(x,y)` is the semantic heart of Bellman elimination over finite spaces. Once formalized, it can be reused for sequence models, HMMs, and symbolic music generation.

4. **Tensor Networks**  
   Grouping voices into `(S,A)` and `(T,B)` is a tropical tensor-network contraction. If you prove exact elimination identities, you are effectively formalizing a min-plus tensor contraction calculus.

5. **Constraint-Based Music Theory**  
   The converse rigidity theorem means a globally perfect chorale must satisfy every local rule exactly. This is the formal bridge between optimization-based composition and rule-based counterpoint.

---

## Concrete Technical Advice

- Prefer `Fin 4` over a custom voice type initially; you can later add notation for `S`, `A`, `T`, `B`.
- For unordered pairs, avoid duplicate counting. Either:
  - sum over `i<j`, or
  - define a symmetric `pairCost` and divide the duplicated sum if working over `ℝ`.
  The `i<j` version is cleaner.
- If `Finset.inf'` over `ℝ` is annoying, prove existence of minimizers first, then define:
  ```lean
  noncomputable def argmin ...
  ```
  and derive equations from witness properties.
- If melody length `n` is irrelevant to the cost decomposition, parametrize everything over `Melody n` but prove the finite minimization theorem independently of music objects.
- Separate theorems into:
  1. generic finite tropical optimization lemmas,
  2. music-specific instantiations.
  This is essential for reuse and publication-level clarity.

---

## A Stronger Theorem If Time Permits

If pairwise costs themselves decompose over time:
```lean
pairCost m₁ m₂ = ∑ t : Fin n, localPairCost (m₁ t) (m₂ t)
```
and spacing penalties are also time-local, then prove a **time-slice decomposition theorem**:
```lean
theorem choraleCost_time_decomposes
    {n : ℕ} (C : Chorale n) :
    choraleCost C = ∑ t : Fin n, localTimeCost (fun i => C i t)
```
This would be a major leap: it reduces global polyphonic optimization to a chain-structured DP over time, opening the door to Viterbi-style certified chorale generation.

That theorem is far more revolutionary than a static four-voice extension, because it links tropical factorization across both:
- voice dimension,
- time dimension.

---

## Deliverables

1. Lean definitions:
   - `Chorale`
   - `voicePairs`
   - `choraleCost`
   - `tropTensor`
   - `tropMin` or equivalent witness-based minimization notion

2. Lean theorems:
   - `choraleCost_eq_zero_of_pairwise_zero`
   - `pairwise_zero_of_choraleCost_eq_zero`
   - `finset_min_product` or equivalent
   - `tropMin_tropTensor`
   - if possible, `chorale_min_elim_SA_TB`

3. A structured `FUTURE_DIRECTIONS.md` with 3–5 concrete next steps. Required topics:
   - time-dependent chorale DP,
   - abstract tropical factor graphs,
   - zero-temperature statistical mechanics formalization,
   - certified generation algorithms,
   - extension from 4 voices to arbitrary finite ensembles.

Make `FUTURE_DIRECTIONS.md` specific, theorem-oriented, and bold. Not “explore X”; instead write things like:
- “Prove that tree-structured tropical factor graphs admit exact belief propagation in Lean.”
- “Formalize a zero-temperature limit theorem connecting `logSumExp` and tropical minimization.”
- “Prove NP-hardness reductions for unrestricted chorale optimization, identifying exactly which local restrictions restore tractability.”

This is the frontier: not just formal music, but a certified tropical science of structured optimization.

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
