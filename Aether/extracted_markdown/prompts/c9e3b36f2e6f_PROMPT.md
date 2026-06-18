## Assignment: Phase 2 (Short-term, 1–2 months)

Prove genuinely new, non-trivial theorems that create a bridge between optimal transport, tropical algebra, and symmetry/invariance. Build aggressively on Mathlib and the catalog lemmas already certified. Minimize `sorry`, but do not minimize ambition.

This cycle should not merely “formalize Wasserstein distance” or “define min-plus matrices.” It should produce at least one theorem that makes those definitions interact in a mathematically surprising way.

---

## Mode: prove + formalize

You should pursue two tightly coupled thrusts:

1. **Team C — Optimal transport as a symmetry-sensitive metric geometry**
2. **Team D — Tropical linear algebra as a min-plus spectral theory**

The breakthrough target is to show that both theories are governed by the same invariance principle: **cost-preserving relabelings act isometrically**, and tropical matrix operations encode optimization dynamics compatible with transport-style minimization.

---

## Primary Breakthrough Objective A: Wasserstein invariance under isometries/permutations

### Precise theorem target

Formalize a discrete Wasserstein-1 distance on finitely supported probability measures over a finite type with a cost function, then prove invariance under cost-preserving bijections.

A concrete Lean-friendly first target is the finite-support, finite-state version using `Fin n → ℝ` as probability vectors.

### Core mathematical statement

Let `α` be a finite type, let `c : α → α → ℝ` be a cost function, and let `e : α ≃ α` be a bijection such that
`∀ x y, c (e x) (e y) = c x y`.
Define pushforward of a distribution `μ : α → ℝ` by `e` via `μ ∘ e.symm`.
Then the discrete Wasserstein distance is invariant:
\[
W_c(\mu,\nu)=W_c(e_*\mu,e_*\nu).
\]

This is not just a sanity check. It is the foundational theorem that says Wasserstein geometry is intrinsic to the metric/cost structure rather than to labels. Once formalized, it opens the door to quotienting transport spaces by symmetry groups, transport on orbit spaces, and tropicalized optimization over couplings.

### Lean 4 type signature target

You may need to define some supporting notions first, but aim for a theorem with a shape close to:

```lean
def IsProbVec {n : ℕ} (μ : Fin n → ℝ) : Prop :=
  (∀ i, 0 ≤ μ i) ∧ (∑ i, μ i = 1)

def transportPlans {n : ℕ} (μ ν : Fin n → ℝ) : Set (Fin n → Fin n → ℝ) :=
  {π | (∀ i j, 0 ≤ π i j) ∧
       (∀ i, ∑ j, π i j = μ i) ∧
       (∀ j, ∑ i, π i j = ν j)}

def transportCost {n : ℕ} (c : Fin n → Fin n → ℝ) (π : Fin n → Fin n → ℝ) : ℝ :=
  ∑ i, ∑ j, π i j * c i j

def wasserstein1 {n : ℕ} (c : Fin n → Fin n → ℝ) (μ ν : Fin n → ℝ) : ℝ :=
  sInf (transportCost c '' transportPlans μ ν)

def pushforwardEquiv {n : ℕ} (e : Fin n ≃ Fin n) (μ : Fin n → ℝ) : Fin n → ℝ :=
  fun i => μ (e.symm i)

theorem wasserstein1_invariant_under_equiv
    {n : ℕ} (c : Fin n → Fin n → ℝ) (μ ν : Fin n → ℝ)
    (hμ : IsProbVec μ) (hν : IsProbVec ν)
    (e : Fin n ≃ Fin n)
    (hc : ∀ i j, c (e i) (e j) = c i j) :
    wasserstein1 c (pushforwardEquiv e μ) (pushforwardEquiv e ν) =
    wasserstein1 c μ ν := by
  sorry
```

If `sInf` over arbitrary sets becomes technically heavy, replace the first theorem by a finite minimum over an explicitly finite type of couplings in a bounded rational/discrete setting, or prove the **plan correspondence theorem** first:

```lean
theorem transportPlans_equiv_bijection
    {n : ℕ} (μ ν : Fin n → ℝ) (e : Fin n ≃ Fin n) :
    Set.BijOn
      (fun π i j => π (e.symm i) (e.symm j))
      (transportPlans μ ν)
      (transportPlans (pushforwardEquiv e μ) (pushforwardEquiv e ν)) := by
  sorry
```

and derive cost preservation + infimum equality from that.

### Why this is a breakthrough

This creates the first rigorous bridge in your Lean development between:
- **transport theory** as optimization over couplings,
- **group actions** as symmetries of state spaces,
- **finite combinatorics** via `Fin n`, `Matrix`, and `Equiv`,
- and later **tropical optimization**, where minima over weighted assignments are the native language.

This theorem is the seed for formal equivariant optimal transport, orbit reduction, and eventually tropical transport duality.

### Proof strategy options

#### Strategy A: Pushforward of transport plans by reindexing
1. Define the transported plan
   \[
   \pi'(i,j)=\pi(e^{-1}i,e^{-1}j).
   \]
2. Prove row and column sums transform correctly using finite sum reindexing over `Fin n`.
3. Prove transport cost is preserved by the cost-invariance hypothesis `hc`, then conclude the image of admissible plans has the same set of attainable costs, hence equal infima.

**Why promising:** This is the most direct and Lean-native route. It uses finite sums and equivalences, which Mathlib handles well.

#### Strategy B: Matrix formulation
1. Represent plans as matrices `Matrix (Fin n) (Fin n) ℝ`.
2. Express marginal constraints as row-sum and column-sum equations.
3. Show conjugation by permutation matrices preserves admissibility and cost.

**Why promising:** Best if you want immediate downstream reuse for Team D, because tropical matrix algebra will also live naturally in matrix form.

#### Strategy C: Finite linear-program symmetry
1. Package the transport problem as a finite-dimensional feasible polytope with linear objective.
2. Prove the permutation action sends feasible points to feasible points and preserves objective values.
3. Conclude equality of minima by optimization invariance.

**Why promising:** Most conceptually powerful, but may require more setup than is ideal for a 1–2 month cycle.

**Recommendation:** Start with Strategy A, then refactor toward Strategy B if you want matrix interoperability.

---

## Primary Breakthrough Objective B: Tropical matrix powers and min-plus subadditivity

### Precise theorem target

Define min-plus matrix multiplication over `ℝ` (or a tropicalized extended type if needed), and prove that diagonal entries of tropical powers satisfy subadditive inequalities, yielding a route toward tropical eigenvalue / cycle-mean theory.

### Core mathematical statement

For a square matrix `A`, define tropical multiplication by
\[
(A \otimes B)_{ij} = \min_k (A_{ik}+B_{kj}).
\]
Then for each index `i`, the sequence
\[
a_n := (A^{\otimes n})_{ii}
\]
satisfies
\[
a_{m+n} \le a_m + a_n.
\]
This is a genuine spectral foothold: by Fekete-style reasoning, it suggests the existence of asymptotic cycle means and tropical eigenvalues.

### Lean 4 type signature target

A plausible Lean target is:

```lean
def tropMul {n : ℕ} (A B : Matrix (Fin n) (Fin n) ℝ) : Matrix (Fin n) (Fin n) ℝ :=
  fun i j => Finset.inf' Finset.univ (by simp) (fun k => A i k + B k j)

def tropPow {n : ℕ} : Matrix (Fin n) (Fin n) ℝ → ℕ → Matrix (Fin n) (Fin n) ℝ
  | A, 0 => fun i j => if i = j then 0 else 0  -- replace by proper tropical identity if using EReal/WithTop
  | A, m+1 => tropMul (tropPow A m) A

theorem tropPow_diag_subadditive
    {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) (i : Fin n) :
    ∀ m k : ℕ,
      tropPow A (m + k) i i ≤ tropPow A m i i + tropPow A k i i := by
  sorry
```

If the tropical identity over plain `ℝ` is awkward, use a simpler theorem first that avoids the zero-th power and proves the one-step composition inequality:

```lean
theorem tropMul_diag_le
    {n : ℕ} (A B : Matrix (Fin n) (Fin n) ℝ) (i : Fin n) :
    tropMul A B i i ≤ A i i + B i i := by
  sorry
```

Then derive the power subadditivity inductively.

### Why this is a breakthrough

This theorem is the formal kernel of tropical spectral theory. It turns “compute eigenvalues” from a slogan into a structural program:
- subadditivity,
- asymptotic average weights,
- minimum cycle means,
- tropical eigenvectors as fixed points up to additive scaling.

Once this exists in Lean, you are positioned to formalize Karp’s theorem, max-plus/min-plus Perron–Frobenius theory, and shortest-path asymptotics.

### Proof strategy options

#### Strategy A: Direct witness in the infimum
1. Expand `tropMul`.
2. Use the specific witness `k = i` in the finite infimum.
3. Obtain
   \[
   (A \otimes B)_{ii} \le A_{ii}+B_{ii}.
   \]
4. Induct on powers.

**Why promising:** Elementary, robust, and ideal for first formalization.

#### Strategy B: Path interpretation
1. Interpret `(A^{⊗n}) i j` as minimum weight of a length-`n` path from `i` to `j`.
2. Concatenate a minimal `m`-path and a minimal `k`-path through `i`.
3. Conclude subadditivity for closed walks.

**Why promising:** This is the best conceptual route if you want immediate graph-theoretic applications.

#### Strategy C: Semiring abstraction
1. Build tropical multiplication as matrix multiplication over an idempotent semiring.
2. Prove the diagonal inequality abstractly from order/idempotence.
3. Specialize to min-plus `ℝ`.

**Why promising:** Most reusable, but may be too ambitious unless Mathlib’s semiring/order interfaces align smoothly.

**Recommendation:** Prove the concrete `ℝ` theorem first by Strategy A, then abstract later.

---

## Secondary Bridge Objective C: Tropicalization of transport cost under permutation couplings

This is the cross-domain theorem that could make the cycle memorable.

### Vision

In discrete transport between uniform measures on `Fin n`, permutation couplings are special transport plans. Their costs are assignment costs:
\[
\sum_i c(i,\sigma(i)).
\]
In tropical language, minima over assignments are exactly the native optimization objects of min-plus algebra.

### Theorem target

Prove that for uniform measures, the transport cost of a permutation coupling is invariant under simultaneous relabeling, and package the family of permutation costs as a tropical optimization problem.

A manageable first theorem:

```lean
def uniformProb (n : ℕ) : Fin n → ℝ := fun _ => (n : ℝ)⁻¹

def permPlan {n : ℕ} (σ : Fin n ≃ Fin n) : Fin n → Fin n → ℝ :=
  fun i j => if σ i = j then (n : ℝ)⁻¹ else 0

theorem permPlan_is_transportPlan
    {n : ℕ} (hn : 0 < n) (σ : Fin n ≃ Fin n) :
    permPlan σ ∈ transportPlans (uniformProb n) (uniformProb n) := by
  sorry

theorem permPlan_cost_relabel_invariant
    {n : ℕ} (c : Fin n → Fin n → ℝ) (σ e : Fin n ≃ Fin n) :
    transportCost c (permPlan (e.trans σ.trans e.symm)) =
    transportCost (fun i j => c (e i) (e j)) (permPlan σ) := by
  sorry
```

This theorem turns symmetry of couplings into a tropical/combinatorial assignment statement.

### Why this matters

This is the gateway to:
- Birkhoff polytope formalization,
- assignment problem duality,
- Hungarian algorithm verification,
- tropical determinants/permanents,
- and eventually transport-tropical duality.

---

## How to build on the existing verified theorems

The catalog theorems are not endpoints; they are motifs. Use them as algebraic intuition and naming precedent.

1. `tropical_plus_distributes_over_min`
   - Use this as the prototype for proving compatibility of addition with min-based optimization.
   - It should inform your simplification lemmas for `tropMul`, especially when pushing constants through finite infima.

2. `bool_or_as_tropical_min`
   - This suggests a logic-to-tropical correspondence.
   - Use it conceptually when encoding feasibility constraints: admissibility of transport plans can be viewed as an optimization-compatible logical structure.

3. `tropical_lattice_min_max`
   - Use this to guide order-theoretic lemmas for min/max interactions in matrix algebra and transport objective bounds.

4. `tropical_duality_min_to_max`
   - This is the conceptual bridge to duality.
   - Once the primal Wasserstein minimization is in place, this theorem hints at future Kantorovich duality or min/max dual formulations.

5. `tropical_sinc_optimal_interpolant`
   - This indicates your library already tolerates optimization flavored statements over `ℝ`.
   - Reuse the proof style and patterns for existence/optimality statements.

Even if these theorems are not directly imported line-by-line into the proof, they should shape the architecture and naming conventions of your new development.

---

## Suggested implementation architecture

### Team C files
- `OptimalTransport/Discrete/Wasserstein.lean`
- `OptimalTransport/Discrete/Pushforward.lean`
- `OptimalTransport/Discrete/Invariance.lean`

### Team D files
- `Tropical/Matrix/MinPlus.lean`
- `Tropical/Matrix/Powers.lean`
- `Tropical/Matrix/Spectral.lean`

### Bridge files
- `Bridges/TransportTropical/Assignment.lean`
- `Bridges/TransportTropical/PermutationCouplings.lean`

Keep definitions small, theorem statements explicit, and reusable lemmas isolated.

---

## 2–3 concrete proof strategy steps to execute immediately

### For Wasserstein invariance
1. **Define finite transport plans** on `Fin n` with row/column marginal constraints and nonnegativity.
2. **Prove reindexing by an equivalence preserves admissibility** using `Finset.univ.map`/sum reindexing.
3. **Show cost preservation under cost-invariant relabeling**, then conclude equality of `sInf` or finite minima.

### For tropical matrix powers
1. **Define min-plus multiplication** with `Finset.inf'` over `Fin n`.
2. **Prove the diagonal witness lemma** by choosing the witness `k = i`.
3. **Induct on powers** to derive subadditivity of diagonal entries.

### For the bridge theorem
1. **Define permutation plans** and verify their marginals are uniform.
2. **Compute their transport cost explicitly** as an assignment sum.
3. **Show simultaneous relabeling conjugates permutations and preserves assignment cost**.

---

## Cross-domain connections you must exploit

Do not leave these as vague metaphors; make them mathematically operative.

### 1. Optimal transport × group actions
Wasserstein invariance under `Equiv` is the finite precursor to equivariant transport on homogeneous spaces and quotient metric geometry.

### 2. Tropical algebra × graph theory
Min-plus matrix powers encode shortest paths and cycle means. Your subadditivity theorem is a disguised graph theorem.

### 3. Optimal transport × combinatorial optimization
Permutation couplings are assignment problems. This links Wasserstein geometry to matching theory, the Birkhoff polytope, and linear programming.

### 4. Tropical algebra × analysis
Subadditivity of tropical powers points toward asymptotic limits, ergodic behavior, and nonlinear spectral theory.

### 5. Transport × tropical duality
Both are minimization theories with hidden convex duals. Long-term, this suggests a formalized tropical Kantorovich duality.

---

## Application keywords

`optimal transport`, `Wasserstein distance`, `equivariance`, `group actions`, `finite probability`, `transport plans`, `assignment problem`, `Birkhoff polytope`, `tropical algebra`, `min-plus matrix multiplication`, `tropical eigenvalue`, `cycle mean`, `shortest paths`, `idempotent analysis`, `nonlinear spectral theory`, `combinatorial optimization`, `formal verification`, `Lean 4`, `Mathlib`

---

## Deliverables

Required:
- Lean 4 files implementing the new definitions and proving at least one flagship theorem from Objective A or B
- a serious attempt at the bridge theorem in Objective C
- `FUTURE_DIRECTIONS.md`

Optional but encouraged:
- `ARTICLE.md`
- `RESEARCH_PAPER.md`
- `diagram.svg` showing the relation between transport plans, permutation couplings, and tropical matrix optimization
- `demo.py` for small numerical experiments on `Fin 3` or `Fin 4`

---

## Non-negotiable requirement: FUTURE_DIRECTIONS.md

You must produce `FUTURE_DIRECTIONS.md` with **3–5 concrete, theorem-level next steps**, each containing:
1. an explicit theorem statement,
2. a Lean-style type signature sketch,
3. a proof strategy,
4. a cross-domain significance note.

The next steps should be breakthrough-level, not incremental. Strong candidates include:
- finite Kantorovich duality,
- Birkhoff–von Neumann decomposition for doubly stochastic matrices,
- tropical cycle-mean = eigenvalue theorem,
- Hungarian algorithm correctness,
- Wasserstein quotient invariance under finite group actions.

---

## Final call to arms

Do not treat Team C and Team D as separate chores. The real opportunity is to show that **transport minimization and tropical minimization are manifestations of one formal optimization language**. If you can prove a symmetry theorem for Wasserstein distance and a subadditivity theorem for tropical powers in the same cycle, you will have created the backbone of a new verified interface between metric geometry, combinatorial optimization, and idempotent algebra. That is the standard for this phase.

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
