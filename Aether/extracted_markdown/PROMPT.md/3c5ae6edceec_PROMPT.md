Soli Deo Gloria

## Assignment: Direction 5 — Weighted and Multi-Objective Hypergraph Transversals as a Gateway to Certified Multi-Criteria Optimization

You are not being asked for a cosmetic generalization of unweighted transversal bounds. You are being asked to formalize a structural theory: **cost-sensitive and multi-objective hypergraph covering admits provable, algorithmically extractable rounding laws**. If this succeeds, it opens a verified bridge from extremal combinatorics to operations research, welfare economics, and algorithmic mechanism design.

The existing catalog theorem
- `Pythagorean/HypergraphTransversal.lean`
  - `integrality_gap_upper`
  - `threshold_isTransversal`
  - `threshold_card_bound`

should be treated as the 1-dimensional shadow of a much richer phenomenon. Your goal is to expose the full geometry.

---

## Core Vision

For a finite hypergraph `H` on vertex type `α`, the classical transversal LP minimizes a linear cost over fractional vertex weights subject to edge-cover constraints. In the unweighted case, threshold rounding at scale `1 / d_max` gives an integral transversal with approximation factor `d_max`.

The breakthrough direction is to show that this is not merely a counting trick but a **robust geometric rounding principle** that survives:
1. **vertex costs** (`w : α → ℚ≥0` or `ℝ≥0`),
2. **edge demands / multiplicities**,
3. **multi-objective cost vectors**,
4. and, ideally, **Pareto-supported scalarizations**.

This is the kind of result that makes a research mathematician say: “hypergraph transversals are not just combinatorial objects — they are a certified laboratory for multi-criteria optimization geometry.”

---

## Precise Formal Targets

You must introduce at least one genuinely new definition, and the best candidates are:

### New definitions to introduce
1. **Weighted fractional transversal**
   - a fractional assignment `x : α → ℝ`
   - feasibility: `0 ≤ x v` and every edge is covered
   - objective value measured against `w : α → ℝ`

2. **Demanded hypergraph cover constraint**
   - for each edge `e`, instead of `∑ v∈e, x v ≥ 1`, allow a demand `δ e ≥ 1`
   - or, if the existing catalog setup fixes unit edge coverage, encode demand-sensitive threshold scaling through replicated/weighted edges

3. **Multi-objective fractional transversal**
   - objective family `costs : Fin k → α → ℝ`
   - feasible set as above
   - define **supported Pareto point** via scalarization by `λ : Fin k → ℝ≥0`

4. **Threshold rounding operator**
   - from a fractional solution and threshold `θ`, produce the set `{v | θ ≤ x v}` or weighted variant
   - prove monotonicity and feasibility lemmas as reusable API

---

## Theorem 1: Weighted Threshold Rounding Bound

This theorem is the heart of the project. State it with full quantifiers and prove it nontrivially.

### Mathematical statement
Let `H` be a finite hypergraph with maximum edge size at most `d`. Let `w : α → ℝ≥0` be nonnegative vertex costs. If `x : α → ℝ≥0` is a feasible fractional transversal, then the threshold-rounded set
\[
S := \{v : x(v) \ge 1/d\}
\]
is an integral transversal and satisfies
\[
\sum_{v\in S} w(v) \le d \sum_v w(v)x(v).
\]
Consequently, the minimum weighted integral transversal cost is at most `d` times the minimum weighted fractional cost.

This is deeper than the catalog result because it isolates the **linearity of cost and combinatorial density of constraints** as the true source of the gap bound.

### Suggested Lean 4 type signature
You may need to adapt to the exact hypergraph API in the catalog, but target something morally of the following form:

```lean
theorem weighted_threshold_cost_bound
  {α : Type*} [Fintype α] [DecidableEq α]
  (H : Finset (Finset α))
  (d : ℕ)
  (hd : ∀ e ∈ H, e.card ≤ d)
  (x : α → ℝ)
  (hx_nonneg : ∀ v, 0 ≤ x v)
  (hx_cover : ∀ e ∈ H, 1 ≤ ∑ v in e, x v)
  (w : α → ℝ)
  (hw_nonneg : ∀ v, 0 ≤ w v) :
  let S : Finset α := Finset.univ.filter (fun v => (1 : ℝ) / d ≤ x v)
  (∀ e ∈ H, (e ∩ S).Nonempty) ∧
  (∑ v in S, w v ≤ d * ∑ v, w v * x v)
```

Then derive:

```lean
theorem weighted_integrality_gap_upper
  {α : Type*} [Fintype α] [DecidableEq α]
  (H : Finset (Finset α))
  (d : ℕ)
  (hd : ∀ e ∈ H, e.card ≤ d) :
  weighted_transversal_number H ≤ d * weighted_fractional_transversal_number H
```

If the infimum/minimization layer is too heavy for one cycle, prove the **rounding theorem for arbitrary feasible `x`** and then separately formalize the optimization corollary using an argmin/`sInf` wrapper only if the library support is mature. The rounding theorem itself is already significant.

### Why this is a breakthrough
This theorem says the classical `d_max` gap is not tied to cardinality minimization; it is a **cost-agnostic approximation law**. That is exactly what one needs in facility location surrogates, resource allocation, and cost-sharing models.

### Proof strategy options

#### Strategy A — Direct threshold summation via indicator domination
Most promising.

1. Define `S := {v | 1/d ≤ x v}`.
2. Prove transversal feasibility by contradiction:
   - if some edge `e` avoids `S`, then every `v ∈ e` has `x v < 1/d`,
   - hence `∑ v∈e, x v < e.card / d ≤ 1`, contradicting feasibility.
3. Prove the cost bound vertexwise:
   \[
   1_{v\in S} \le d\,x(v)
   \]
   because if `v ∈ S`, then `1 ≤ d x(v)`, and otherwise the indicator is `0`.
   Multiply by `w(v) ≥ 0`, sum over all vertices, and use finite-sum monotonicity.

This route should use `by_contra`, `calc`, `nlinarith`/linear arithmetic, and finset sum inequalities.

#### Strategy B — Edgewise averaging then dual-style aggregation
Potentially elegant if you want stronger API.

1. Show each bad edge would violate the average lower bound.
2. Interpret threshold rounding as selecting vertices where the scaled fractional solution dominates the integral indicator.
3. Package the cost proof as a domination lemma:
   ```lean
   theorem threshold_indicator_le_scaled
   ```
4. Reuse it to prove weighted and unweighted bounds uniformly.

This is good if you want a reusable combinatorial optimization library.

#### Strategy C — LP-dual flavored proof
Ambitious, less likely to be fastest.

1. Formalize the primal weighted fractional cover.
2. Use weak duality with edge packings.
3. Show threshold rounding gives an integral solution with cost bounded by `d` times primal optimum.

Conceptually beautiful, but likely heavier than needed unless Mathlib LP infrastructure is already aligned with the catalog.

**Recommendation:** Strategy A first, then refactor into Strategy B-style reusable lemmas.

---

## Theorem 2: Weighted Monotonicity / Stability Under Cost Domination

You need a second theorem that is not just bookkeeping. Prove that the weighted optimum is monotone under pointwise increase of costs, and ideally that the threshold-rounding certificate respects this monotonicity.

### Mathematical statement
If `w₁(v) ≤ w₂(v)` for all vertices, then
\[
\tau_{w_1}(H) \le \tau_{w_2}(H)
\quad\text{and}\quad
\tau^*_{w_1}(H) \le \tau^*_{w_2}(H).
\]
Moreover, for any fixed feasible fractional transversal `x`, the threshold-rounded set `S(x)` satisfies
\[
\mathrm{cost}_{w_1}(S(x)) \le \mathrm{cost}_{w_2}(S(x)).
\]

### Suggested Lean 4 type signature
```lean
theorem weighted_transversal_mono
  {α : Type*} [Fintype α] [DecidableEq α]
  (H : Finset (Finset α))
  (w₁ w₂ : α → ℝ)
  (hmono : ∀ v, w₁ v ≤ w₂ v) :
  weighted_transversal_number H w₁ ≤ weighted_transversal_number H w₂
```

and a pointwise rounded-set version:

```lean
theorem threshold_cost_mono
  {α : Type*} [Fintype α] [DecidableEq α]
  (x : α → ℝ) (θ : ℝ)
  (w₁ w₂ : α → ℝ)
  (hmono : ∀ v, w₁ v ≤ w₂ v) :
  let S : Finset α := Finset.univ.filter (fun v => θ ≤ x v)
  ∑ v in S, w₁ v ≤ ∑ v in S, w₂ v
```

### Why this matters
This theorem is not glamorous on its own, but it is structurally essential: it turns your weighted theory into a **comparison calculus**. That is what applications need when prices change, penalties are reweighted, or one objective scalarization dominates another.

### Proof strategy
1. For the rounded-set theorem, use direct sum monotonicity on a filtered finset.
2. For the optimization theorem, compare costs on every feasible integral transversal and pass to the infimum/minimum.
3. If full optimum formalization is too expensive, at minimum prove the pointwise monotonicity for every candidate transversal and every fractional solution.

This theorem should involve nontrivial use of `rcases`, finite-set coercions, and sum monotonicity lemmas.

---

## Theorem 3: Supported Pareto Solutions for Two Objectives Exist via Scalarization

This is the cross-domain theorem. It connects hypergraph transversal theory to convex geometry and welfare economics.

### Mathematical statement
Let `c₁, c₂ : α → ℝ≥0` be two nonnegative cost functions, and let `F` be the set of feasible fractional transversals. For every `λ ∈ [0,1]`, any minimizer of the scalarized objective
\[
x \mapsto \lambda \sum_v c_1(v)x(v) + (1-\lambda)\sum_v c_2(v)x(v)
\]
is a supported Pareto-optimal point of the image set
\[
\{(\sum_v c_1(v)x(v),\sum_v c_2(v)x(v)) : x \in F\}.
\]

This is a genuine conceptual upgrade: hypergraph transversals become a certified example of **Pareto geometry emerging from combinatorial optimization**.

### Suggested Lean 4 type signature
You may want to formulate a theorem at the level of arbitrary feasible sets first, then instantiate it for fractional transversals.

A workable hypergraph-specific statement:

```lean
def weighted_obj
  {α : Type*} [Fintype α] (c : α → ℝ) (x : α → ℝ) : ℝ :=
  ∑ v, c v * x v

def is_fractional_transversal
  {α : Type*} [Fintype α] [DecidableEq α]
  (H : Finset (Finset α)) (x : α → ℝ) : Prop :=
  (∀ v, 0 ≤ x v) ∧ ∀ e ∈ H, 1 ≤ ∑ v in e, x v

def pareto_optimal_pair
  (A : Set (ℝ × ℝ)) (p : ℝ × ℝ) : Prop :=
  p ∈ A ∧ ¬ ∃ q ∈ A, q.1 ≤ p.1 ∧ q.2 ≤ p.2 ∧ (q.1 < p.1 ∨ q.2 < p.2)

theorem scalarized_minimizer_is_supported_pareto
  {α : Type*} [Fintype α] [DecidableEq α]
  (H : Finset (Finset α))
  (c₁ c₂ : α → ℝ)
  (hc₁ : ∀ v, 0 ≤ c₁ v)
  (hc₂ : ∀ v, 0 ≤ c₂ v)
  (λ : ℝ)
  (hλ0 : 0 ≤ λ)
  (hλ1 : λ ≤ 1)
  (x : α → ℝ)
  (hx_feas : is_fractional_transversal H x)
  (hx_min : ∀ y, is_fractional_transversal H y →
    λ * weighted_obj c₁ x + (1 - λ) * weighted_obj c₂ x
      ≤ λ * weighted_obj c₁ y + (1 - λ) * weighted_obj c₂ y) :
  pareto_optimal_pair
    {p | ∃ y, is_fractional_transversal H y ∧
        p = (weighted_obj c₁ y, weighted_obj c₂ y)}
    (weighted_obj c₁ x, weighted_obj c₂ x)
```

### Why this is a breakthrough
This theorem imports a central principle from multi-objective optimization into a combinatorial setting already rich with rounding structure. Once formalized, it becomes possible to ask:
- which Pareto points are supportable by linear prices?
- how does threshold rounding move supported Pareto points?
- can one certify approximation of the Pareto frontier by rounded supported points?

That is a new research corridor, not a minor extension.

### Proof strategy options

#### Strategy A — Pure convex-order contradiction
Most realistic.

1. Assume `x` is not Pareto-optimal.
2. Then there exists feasible `y` weakly improving both objectives and strictly improving one.
3. Multiply inequalities by `λ` and `1-λ`, add them, and contradict scalarized minimality.

This is clean, formalizable, and mathematically sharp.

#### Strategy B — General abstract lemma about scalarization
1. Prove an abstract theorem for any feasible set `A : Set β` and two objective maps `f g : β → ℝ`.
2. Instantiate with `β := α → ℝ` and `A := {x | is_fractional_transversal H x}`.

This is more reusable and philosophically preferable if time permits.

#### Strategy C — Convex-geometric exposed-face language
Elegant but likely too much infrastructure.

**Recommendation:** prove Strategy A concretely, then optionally refactor into an abstract theorem.

---

## Theorem 4 (Optional but High-Value): Rounding Supported Pareto Points with Uniform Bi-Objective Distortion

If you can push one step further, prove a theorem of the following flavor:

### Mathematical statement
Let `x` be a feasible fractional transversal and `S` its threshold rounding at `1/d`. Then for each nonnegative objective `c_i`,
\[
\mathrm{cost}_{c_i}(S) \le d \cdot \mathrm{cost}_{c_i}(x).
\]
Hence threshold rounding maps any feasible fractional point to an integral point that simultaneously `d`-approximates **every** nonnegative linear objective.

This is extremely strong: a single rounded set approximates all objectives at once. That is the exact kind of theorem that matters in robust optimization and welfare design.

### Lean-style signature
```lean
theorem threshold_simultaneous_multiobjective_bound
  {α : Type*} [Fintype α] [DecidableEq α]
  (H : Finset (Finset α))
  (d : ℕ)
  (hd : ∀ e ∈ H, e.card ≤ d)
  (x : α → ℝ)
  (hx_nonneg : ∀ v, 0 ≤ x v)
  (hx_cover : ∀ e ∈ H, 1 ≤ ∑ v in e, x v)
  (costs : Fin k → α → ℝ)
  (hcosts : ∀ i v, 0 ≤ costs i v) :
  let S : Finset α := Finset.univ.filter (fun v => (1 : ℝ) / d ≤ x v)
  ∀ i : Fin k, ∑ v in S, costs i v ≤ d * ∑ v, costs i v * x v
```

### Why this is revolutionary
This turns threshold rounding into a **universal objective-preserving compression map**. In economics language: one decision simultaneously controls multiple welfare criteria. In OR language: one combinatorial design certifies a whole family of linear budgets. In game theory language: one allocation controls multiple cost shares.

---

## About the “demand” parameter in the conjecture

Be careful: the proposed expression
\[
\tau_w(H) \le d_{\max}\,\tau^*_w(H)
\]
with edge demands `d(e) > 0` and threshold involving both `d_max` and `max_e d(e)` is mathematically under-specified unless the LP constraints are explicitly modified. You should **not** blindly formalize a potentially false statement.

You have two principled options:

### Option 1 — Formalize replicated-demand edges
Interpret integer demand `δ(e)` by repeating edge `e`, or by requiring `∑_{v∈e} x(v) ≥ δ(e)`. Then derive the threshold appropriate to the normalized demand. This may require stronger assumptions such as bounded edge size and feasible scaling.

### Option 2 — Produce a counterexample to the naive demand-threshold rule
If the exact proposed threshold law is false, this is scientifically valuable. Construct a small hypergraph where the naive weighted-demand threshold fails to produce a transversal or fails the claimed bound. This would satisfy the “counterexample” mode and prevent a dead end.

A good falsifiable conjecture here is:

> **Conjecture.** For every finite hypergraph `H` with edge size at most `d`, every feasible fractional transversal `x`, and every family of nonnegative objective functions `costs : Fin k → α → ℝ`, threshold rounding at `1/d` yields a simultaneous `d`-approximation for all `k` objectives.

This is testable computationally and could fail only if some hidden formalization issue arises. It is stronger and cleaner than the original demand phrase.

---

## Cross-Domain Connections You Must Explicitly Develop

At least one theorem and one discussion section must bridge to another domain.

### 1. Operations Research
Hypergraph transversals model:
- facility placement,
- sensor placement,
- set cover with heterogeneous costs,
- survivability constraints.

Your weighted theorem is a certified approximation guarantee for cost-sensitive covering.

### 2. Welfare Economics
The Pareto theorem above formalizes a basic principle of social choice and multi-criteria planning:
- `c₁` and `c₂` can be interpreted as competing welfare losses,
- supported Pareto points arise from linear prices or social welfare weights.

### 3. Algorithmic Game Theory
Weighted transversals can encode cost-sharing instances. A simultaneous multi-objective approximation theorem suggests one can balance:
- total cost,
- fairness proxy,
- congestion proxy,
with a single rounded solution.

### 4. Convex Geometry / Polyhedral Combinatorics
The set of feasible fractional transversals is a polyhedron; objective images form a convex region. Supported Pareto points are exposed boundary points. This is the geometric language behind your theorem.

### Application keywords
Use these explicitly in comments, paper, and article:
- weighted set cover
- hypergraph covering
- LP rounding
- Pareto frontier
- multi-objective optimization
- welfare economics
- cost-sharing
- facility location
- polyhedral combinatorics
- certified approximation
- scalarization
- robust decision-making

---

## Required File-Level Deliverables

You must produce **all** of the following.

### 1. Lean file with at least 3 substantial theorems
Requirements:
- at least 3 theorem proofs using nontrivial tactics such as:
  - induction
  - `rcases`
  - `by_contra`
  - `field_simp`
  - multi-step `calc`
- no trivial theorem chosen merely because `native_decide`, `decide`, `norm_num`, or `rfl` can close it
- at least one new definition not already in the catalog
- minimize sorry aggressively

### 2. Verified algorithm / computational method
Implement a certified or semi-certified computational routine for:
- constructing threshold-rounded transversals from fractional solutions,
- evaluating weighted objective values,
- exploring scalarized objectives over a grid of `λ ∈ [0,1]`.

If exact LP solving inside Lean is unrealistic, verify the **rounding-and-checking layer** and use Python for optimization input generation.

### 3. `demo.py`
Must demonstrate interactively:
- random weighted hypergraph generation on `n = 20`,
- random nonnegative costs,
- approximate or exact fractional solutions (via `scipy.optimize.linprog` or equivalent),
- threshold rounding,
- empirical verification of the weighted `d_max` gap over 1000 trials,
- two-objective scalarization sweep and visualization of supported Pareto points.

Also include:
- a search for small counterexamples to any overly optimistic demand-based conjecture,
- plots of fractional vs rounded costs.

### 4. `RESEARCH_PAPER.md`
This must be a standalone scientific paper. A reader with no access to code must understand:
- the exact definitions,
- the main theorems,
- why weighted and multi-objective extensions matter,
- proof ideas,
- experiments,
- conjectures and next steps.

Do not write this as notes. Write it as an actual paper.

### 5. `ARTICLE.md`
Scientific American style. Explain:
- why covering problems become richer with heterogeneous costs,
- what a Pareto frontier means,
- why one rounded solution controlling multiple objectives is surprising.

TABOO: do not focus on formal verification machinery. Focus on the mathematics and why it matters.

### 6. `FUTURE_DIRECTIONS.md`
Include 3–5 original research directions.
Each direction must include the exact sentences:
- **“The key insight is...”**
- **“Why now?”**

At least one direction must bridge to a different domain, for example:
- mechanism design,
- statistical physics,
- biological network design,
- tropical or discrete convex geometry.

Write original prose, not a template.

---

## Concrete Proof Architecture

Here is the most promising implementation order.

### Step 1 — API extraction from the catalog
Inspect:
- `Pythagorean/HypergraphTransversal.lean`
  - `integrality_gap_upper`
  - `threshold_isTransversal`
  - `threshold_card_bound`

Determine:
- exact hypergraph representation,
- existing notion of transversal,
- existing threshold operator,
- whether objective functions are currently cardinality-only.

Your first task is to factor reusable lemmas from the unweighted proof:
- threshold membership implies `1 ≤ d * x v`
- edge not hit by threshold implies all vertices are below threshold
- filtered-sum domination lemma

### Step 2 — Define weighted cost and prove pointwise domination
Prove a lemma of the form:
```lean
theorem weighted_indicator_bound
  {α : Type*} [Fintype α] [DecidableEq α]
  (x : α → ℝ) (w : α → ℝ) (d : ℕ)
  (hx_nonneg : ∀ v, 0 ≤ x v)
  (hw_nonneg : ∀ v, 0 ≤ w v) :
  let S := Finset.univ.filter (fun v => (1 : ℝ) / d ≤ x v)
  ∀ v, (if v ∈ S then w v else 0) ≤ d * (w v * x v)
```
This is the local inequality from which the global weighted theorem falls out.

### Step 3 — Prove weighted threshold feasibility
This is where `by_contra` should appear. Assume an edge is missed; derive:
\[
\sum_{v\in e} x(v) < \frac{|e|}{d} \le 1,
\]
contradicting feasibility.

### Step 4 — Sum the local inequality
Use `Finset.sum_le_sum`, algebraic rearrangement, and nonnegativity.

### Step 5 — Formalize supported Pareto optimality
First prove the abstract scalarization lemma if possible. Then instantiate it.

### Step 6 — Optional simultaneous multi-objective theorem
Once Theorem 1 is abstracted over an arbitrary nonnegative cost function, Theorem 4 is just “for all `i`”. This gives maximal conceptual payoff per unit effort.

---

## Falsifiable Conjecture with Computational Test

You must include at least one explicit conjecture with a disprovable prediction.

### Preferred conjecture
**Conjecture.** Let `H` be a finite hypergraph with maximum edge size `d`. For every feasible fractional transversal `x` and every finite family of nonnegative objective functions `costs : Fin k → α → ℝ`, threshold rounding at `1/d` produces an integral transversal `S` satisfying
\[
\forall i,\quad \mathrm{cost}_i(S) \le d \cdot \mathrm{cost}_i(x).
\]

### Computational test
For random hypergraphs on `n = 20`:
1. generate `m` random edges with sizes in `{2,3,4}`,
2. solve the fractional LP,
3. sample `k = 2,3` random cost functions,
4. threshold round,
5. check the simultaneous inequality.

A single violating instance disproves the conjecture. If no violations appear in 1000 trials, report empirical support only — not proof.

### Secondary conjecture
**Conjecture.** In the bi-objective case, every supported Pareto-optimal fractional point is mapped by threshold rounding to an integral point lying within coordinatewise factor `d` of the supported frontier.

This is deeper and more geometric; even a computational exploration is valuable.

---

## What would count as a paradigm-shifting outcome?

Any one of the following would be major:

1. A clean formal theorem that **one threshold rounding simultaneously controls all nonnegative linear objectives**.
2. A formalized bridge from fractional hypergraph covers to **supported Pareto optimality**.
3. A counterexample showing the naive demanded-threshold conjecture is false, together with the corrected theorem.
4. A reusable Lean API for **multi-objective combinatorial rounding**.

This is not “weighted set cover again.” This is the beginning of a verified theory of **polyhedral multi-criteria rounding**.

Go build the geometry behind the combinatorics.

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
- **Visualization scripts** — Produce up to 3 self-contained Python scripts
  that visually illustrate the core mathematical concepts discovered. Use
  matplotlib for static plots (heatmaps, curves, surfaces) or plotly for
  interactive charts. Available libraries: numpy, matplotlib, plotly.
  If using matplotlib, the script must call plt.savefig() — the system
  captures the output as a PNG. If using plotly, assign the figure to a
  variable named `fig` — the system captures fig.to_html(). Each script
  must include a comment header explaining what it visualizes and why.
- **Interactive HTML demos** — Produce up to 3 self-contained HTML snippets
  (with inline CSS/JS, no external dependencies) that demonstrate the
  mathematical concepts interactively — sliders, animations, dynamic SVG,
  or canvas drawing. Each demo must be a complete <div> fragment that
  works when inserted into a page. No <html>, <head>, or <body> tags —
  just the content div with its inline styles and scripts.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 5 — FUTURE_DIRECTIONS.md  (MANDATORY — drives next cycle)
────────────────────────────────────────────────────────────────────────────
The MOST IMPORTANT deliverable. Every research cycle MUST produce a
FUTURE_DIRECTIONS.md that identifies 3-5 specific, testable scientific
hypotheses, including 1-2 grand_challenge paradigm-shifting conjectures
and 2-3 solid extensions building directly on Catalog theorems.
MUST begin with a ## Synthesis section tying all directions together.
Each direction must use the structured format with explicit fields:
**Conjecture**, **Test**, **Impact**, **Catalog References**,
**Proof Strategy**, **Domain Bridges**, **Lineage**, **Ambition**.
Reference specific Catalog theorems by file path. Every hypothesis
must be daring enough to matter and specific enough to fail.


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
    "visualizations": [ { "name": "...", "code": "# matplotlib or plotly script, self-contained", "description": "What this visualizes" } ],
    "interactive_demos": [ { "name": "...", "html": "<div>...</div>", "description": "What this demonstrates" } ],
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

Research domain: Pythagorean
Research mode: prove
