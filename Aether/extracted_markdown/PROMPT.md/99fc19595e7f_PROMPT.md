## Assignment: Tropical Eigenvalue as Minimum Cycle Mean — from Definition to a Tropical Spectral Theory

Work in **mode: prove + formalize**.

This is not a request for a cosmetic definition. It is a call to crystallize a genuine tropical spectral invariant in Lean 4 and push it far enough that it becomes a reusable engine for tropical linear algebra, min-plus dynamics, weighted automata, graph optimization, and tropical Langlands/Fourier interfaces already hinted at in the catalog.

You should **define the tropical eigenvalue of a finite weighted directed graph / matrix as the minimum cycle mean**, prove its foundational invariance and extremal properties, and connect it to the existing theorem `tropical_rayleigh_eigenvalue` as a tropical analogue of the Rayleigh quotient principle.

The central insight is this:

> In min-plus algebra, the correct “spectral value” of a matrix is not extracted from roots of a characteristic polynomial, but from the asymptotic geometry of cycles.  
> Formalizing this cleanly in Lean creates the missing bridge between combinatorial optimization and tropical spectral analysis.

---

## Core Mathematical Target

Let `W : Matrix (Fin n) (Fin n) ℝ` be a weight matrix, interpreted as the weighted complete directed graph on `Fin n` where traversing edge `i → j` costs `W i j`.

For a directed cycle
\[
c = (v_0,\dots,v_{k-1},v_0),
\]
define its cost
\[
\operatorname{cycCost}_W(c) = \sum_{t=0}^{k-1} W(v_t, v_{t+1}),
\]
and its mean weight
\[
\operatorname{cycMean}_W(c) = \frac{\operatorname{cycCost}_W(c)}{k}.
\]

Define the **tropical eigenvalue**
\[
\lambda_{\mathrm{trop}}(W) := \inf \{ \operatorname{cycMean}_W(c) : c \text{ is a nonempty directed cycle}\}.
\]
Since the vertex set is finite, this infimum should in fact be a minimum over a finite family of simple cycles, once the right finite encoding is chosen.

Your mission is to formalize a robust version of this definition and prove breakthrough-level foundational theorems.

---

## Precise Theorem Statements to Target

You should choose a Lean-friendly encoding of cycles first. The most promising formal route is to encode a cycle by:
- a length `k : ℕ` with `0 < k`,
- a map `v : Fin (k+1) → Fin n`,
- a closure condition `v 0 = v ⟨k, hk⟩`.

Optionally, impose simplicity on the first `k` vertices later when proving minimization over simple cycles.

### 1. Definition package

Define:
- `cycleCost`
- `cycleMean`
- `isCycle`
- `tropicalEigenvalue`

A plausible Lean 4 skeleton:

```lean
import Mathlib.Data.Matrix.Basic
import Mathlib.Data.Real.Basic
import Mathlib.Data.Finset.Basic
import Mathlib.Algebra.BigOperators.Basic

open BigOperators

def IsClosedWalk {n k : ℕ} (v : Fin (k+1) → Fin n) : Prop :=
  v 0 = v ⟨k, Nat.lt_succ_self k⟩

def cycleCost {n k : ℕ} (W : Matrix (Fin n) (Fin n) ℝ)
    (v : Fin (k+1) → Fin n) : ℝ :=
  ∑ i : Fin k, W (v ⟨i.1, Nat.lt_trans i.2 (Nat.lt_succ_self k)⟩)
                  (v ⟨i.1 + 1, Nat.succ_lt_succ i.2⟩)

def cycleMean {n k : ℕ} (W : Matrix (Fin n) (Fin n) ℝ)
    (hk : 0 < k) (v : Fin (k+1) → Fin n) : ℝ :=
  cycleCost W v / k

def tropicalEigenvalueSet (W : Matrix (Fin n) (Fin n) ℝ) : Set ℝ :=
  {x | ∃ k (hk : 0 < k) (v : Fin (k+1) → Fin n), IsClosedWalk v ∧ x = cycleMean W hk v}

def tropicalEigenvalue {n : ℕ} (W : Matrix (Fin n) (Fin n) ℝ) : ℝ :=
  sInf (tropicalEigenvalueSet W)
```

If `sInf` becomes cumbersome, define first a finite-cycle-restricted version over bounded lengths `1 ≤ k ≤ n`, then prove equivalence with all cycles via cycle reduction. That may be the decisive formalization move.

---

### 2. Minimum attained on a simple cycle

**Theorem (cycle reduction / attainment).**  
For `n > 0`, the tropical eigenvalue is attained by a cycle of length between `1` and `n`.

Mathematically:
\[
\forall n>0,\ \forall W,\ \exists k,\ 1 \le k \le n,\ \exists v,\ \text{IsClosedWalk}(v),\ 
\lambda_{\mathrm{trop}}(W)=\operatorname{cycMean}_W(v).
\]

Lean target:

```lean
theorem tropicalEigenvalue_attained
    {n : ℕ} (hn : 0 < n) (W : Matrix (Fin n) (Fin n) ℝ) :
    ∃ k, 0 < k ∧ k ≤ n ∧
      ∃ v : Fin (k+1) → Fin n,
        IsClosedWalk v ∧
        tropicalEigenvalue W = cycleMean W ‹0 < k› v
```

This is the first real breakthrough theorem: it converts an infinitary spectral definition into a finite combinatorial certificate.

---

### 3. Restriction to simple cycles

**Theorem (minimum cycle mean reduces to simple cycles).**  
Every closed walk contains a simple cycle whose mean is no greater. Therefore:
\[
\lambda_{\mathrm{trop}}(W)=\min\{\operatorname{cycMean}_W(c): c \text{ simple cycle}\}.
\]

Lean target, likely in two stages:

```lean
theorem exists_simple_cycle_mean_le
    {n k : ℕ} (W : Matrix (Fin n) (Fin n) ℝ)
    (hk : 0 < k) (v : Fin (k+1) → Fin n) (hclosed : IsClosedWalk v) :
    ∃ m, 0 < m ∧ m ≤ n ∧
      ∃ u : Fin (m+1) → Fin n,
        IsClosedWalk u ∧
        cycleMean W ‹0 < m› u ≤ cycleMean W hk v
```

and then derive the equality theorem for `tropicalEigenvalue`.

This is the combinatorial heart. Once formalized, it becomes reusable for tropical Perron–Frobenius theory, Karp-style algorithms, and asymptotic semigroup growth.

---

### 4. Diagonal / self-loop formula

If the graph allows self-loops, then 1-cycles are valid, and for diagonal matrices the tropical eigenvalue collapses to the minimum diagonal entry.

**Theorem.**
\[
\lambda_{\mathrm{trop}}(W_{\mathrm{diag}})=\min_i W_{ii}.
\]

Lean target:

```lean
theorem tropicalEigenvalue_diagonal
    {n : ℕ} (hn : 0 < n) (d : Fin n → ℝ) :
    tropicalEigenvalue (Matrix.diagonal d) = Finset.univ.inf' hn d
```

If `Finset.inf'` over `ℝ` is awkward, formulate via `∃ i, ...` and pair of inequalities:
- `tropicalEigenvalue ≤ d i` for all `i`,
- `Finset.univ.inf' hn d ≤ tropicalEigenvalue`.

This gives the first computable closed form and a sanity check for the definition.

---

### 5. Uniform shift invariance

This is conceptually essential: adding a constant to every edge shifts every cycle mean by that constant.

**Theorem.**
For any `a : ℝ`,
\[
\lambda_{\mathrm{trop}}(W + a\mathbf{1}) = \lambda_{\mathrm{trop}}(W) + a.
\]

Lean target:

```lean
def constMatrix {n : ℕ} (a : ℝ) : Matrix (Fin n) (Fin n) ℝ := fun _ _ => a

theorem tropicalEigenvalue_add_const
    {n : ℕ} (hn : 0 < n) (W : Matrix (Fin n) (Fin n) ℝ) (a : ℝ) :
    tropicalEigenvalue (W + constMatrix a) = tropicalEigenvalue W + a
```

This is the tropical analogue of spectral shift. It should be one of the flagship theorems of the file.

---

### 6. Monotonicity

**Theorem.**
If `W i j ≤ W' i j` for all `i,j`, then
\[
\lambda_{\mathrm{trop}}(W) \le \lambda_{\mathrm{trop}}(W').
\]

Lean target:

```lean
theorem tropicalEigenvalue_mono
    {n : ℕ} (hn : 0 < n)
    {W W' : Matrix (Fin n) (Fin n) ℝ}
    (h : ∀ i j, W i j ≤ W' i j) :
    tropicalEigenvalue W ≤ tropicalEigenvalue W'
```

This gives order-theoretic control and makes the invariant useful in optimization and robustness.

---

### 7. Rayleigh-principle bridge theorem

The catalog already contains:

- `tropical_rayleigh_eigenvalue`
- `tropical_eigenvalue_determines_char`

You should not merely cite them. Build a bridge theorem showing that your cycle-mean eigenvalue is compatible with the existing tropical spectral notion, at least under a precise hypothesis.

A strong target:

**Theorem (bridge to tropical Rayleigh eigenvalue).**  
For finite `α`, if the catalog’s `tropical_rayleigh_eigenvalue` defines the min-plus spectral value of a matrix/operator `W`, then for the matrix realization on `Fin n` it equals the minimum cycle mean:
\[
\lambda_{\mathrm{Rayleigh}}(W)=\lambda_{\mathrm{trop}}(W).
\]

Because I do not know the exact type of `tropical_rayleigh_eigenvalue`, you must inspect it and tailor the theorem accordingly. The point is not decorative compatibility; the point is to prove that **the combinatorial cycle invariant and the analytic tropical spectral invariant coincide**.

This is the theorem that turns a graph-theoretic object into a spectral object.

---

## Suggested Lean 4 Type Signatures

These are not mandatory if inspection of Mathlib suggests better encodings, but they should guide the implementation.

```lean
def IsClosedWalk {n k : ℕ} (v : Fin (k+1) → Fin n) : Prop := ...
def cycleCost {n k : ℕ} (W : Matrix (Fin n) (Fin n) ℝ) (v : Fin (k+1) → Fin n) : ℝ := ...
def cycleMean {n k : ℕ} (W : Matrix (Fin n) (Fin n) ℝ) (hk : 0 < k) (v : Fin (k+1) → Fin n) : ℝ := ...

def tropicalEigenvalue {n : ℕ} (W : Matrix (Fin n) (Fin n) ℝ) : ℝ := ...

theorem tropicalEigenvalue_attained
    {n : ℕ} (hn : 0 < n) (W : Matrix (Fin n) (Fin n) ℝ) :
    ∃ k, 0 < k ∧ k ≤ n ∧
      ∃ v : Fin (k+1) → Fin n,
        IsClosedWalk v ∧
        tropicalEigenvalue W = cycleMean W ‹0 < k› v := ...

theorem exists_simple_cycle_mean_le
    {n k : ℕ} (W : Matrix (Fin n) (Fin n) ℝ)
    (hk : 0 < k) (v : Fin (k+1) → Fin n) (hclosed : IsClosedWalk v) :
    ∃ m, 0 < m ∧ m ≤ n ∧
      ∃ u : Fin (m+1) → Fin n,
        IsClosedWalk u ∧
        cycleMean W ‹0 < m› u ≤ cycleMean W hk v := ...

theorem tropicalEigenvalue_add_const
    {n : ℕ} (hn : 0 < n) (W : Matrix (Fin n) (Fin n) ℝ) (a : ℝ) :
    tropicalEigenvalue (W + fun _ _ => a) = tropicalEigenvalue W + a := ...

theorem tropicalEigenvalue_mono
    {n : ℕ} (hn : 0 < n)
    {W W' : Matrix (Fin n) (Fin n) ℝ}
    (h : ∀ i j, W i j ≤ W' i j) :
    tropicalEigenvalue W ≤ tropicalEigenvalue W' := ...

theorem tropicalEigenvalue_diagonal
    {n : ℕ} (hn : 0 < n) (d : Fin n → ℝ) :
    tropicalEigenvalue (Matrix.diagonal d) = Finset.univ.inf' hn d := ...
```

If the dependence on `hk` causes elaboration pain, define:

```lean
def cycleMean' {n k : ℕ} (W : Matrix (Fin n) (Fin n) ℝ) (v : Fin (k+1) → Fin n) : ℝ :=
  cycleCost W v / k
```

and only use it under assumptions `0 < k`.

---

## Proof Strategy Architecture

You must provide at least 2–3 viable proof routes in the implementation notes and choose one as primary.

### Strategy A: Cycle surgery / repeated-vertex elimination
1. Prove that any closed walk of length `k > n` repeats a vertex among the first `k` positions.
2. Split the walk at two equal vertices into two shorter closed walks.
3. Show the weighted average identity:
   \[
   \frac{a+b}{m+\ell} = \frac{m}{m+\ell}\frac{a}{m} + \frac{\ell}{m+\ell}\frac{b}{\ell},
   \]
   hence at least one subcycle has mean no greater than the original.
4. Iterate until obtaining a simple cycle of length `≤ n`.

**Why this is promising:** it is purely finite/combinatorial, avoids advanced topology/order completeness, and gives the strongest reusable theorem (`exists_simple_cycle_mean_le`).

### Strategy B: Finite minimization over bounded-length cycles
1. Prove by cycle reduction that every candidate mean is bounded below by one from a cycle of length `≤ n`.
2. Encode all cycles of lengths `1,...,n` as a finite set.
3. Define `tropicalEigenvalue` as a `Finset.inf'` over this finite set.
4. Derive all core properties from finite infimum calculus.

**Why this is promising:** once the finite encoding is in place, monotonicity and shift invariance become straightforward. This may be the best formal strategy overall, even if the mathematical proof still relies on Strategy A first.

### Strategy C: Bridge through tropical Rayleigh quotient
1. Inspect `tropical_rayleigh_eigenvalue` and identify its variational formula.
2. Show any cycle yields a test object for the Rayleigh side, giving one inequality.
3. Construct from a minimizing tropical potential / subeigenvector a cycle saturation argument giving the reverse inequality.

**Why this is revolutionary:** this turns a graph combinatorics theorem into a spectral equivalence theorem.  
**Why it is harder:** it depends on the exact catalog statement and may require significant adaptation.  
**Recommendation:** do this after A+B establish a stable core.

**Most promising order:** A → B → core theorems → C.

---

## How to Build on the Existing Verified Theorems

Do not name-drop the catalog; exploit it.

1. **`tropical_rayleigh_eigenvalue`**  
   Use this as the analytic/spectral endpoint. Once your cycle-mean theory is established, prove coincidence under matrix realization hypotheses. This is the highest-value bridge theorem in the current context.

2. **`tropical_eigenvalue_determines_char`**  
   Once your `tropicalEigenvalue` is shown to agree with the spectral notion used there, you potentially obtain a corollary that cycle-mean data determines a tropical character in the GL₁/Langlands formalization. That is not just a cute consequence: it suggests that combinatorial cycle data can classify arithmetic/tropical spectral objects.

3. **`bigOmega_eq_tropical_weight`**  
   If this theorem identifies an arithmetic valuation/weight with a tropical weight, use it to motivate examples where the tropical eigenvalue becomes an asymptotic arithmetic growth rate on a weighted transition graph built from factorizations. Even a lemma or example file would be a major cross-domain signal.

4. **`tropical_integral_sup_weight`**  
   This hints at a measure-theoretic tropical extremal principle. After proving monotonicity and finite attainment, investigate whether the tropical eigenvalue can be expressed as a supremal/integral tropical weight in a finite-state setting. Even if not completed now, this belongs in `FUTURE_DIRECTIONS.md`.

5. **`tropical_identity_cost`**  
   Trivial on its face, but useful for simplification of constant-shift and identity-cost examples in Lean.

---

## Cross-Domain Connections You Must Exploit

Do not keep this trapped inside graph theory. Make the brief scientifically ambitious.

### 1. Combinatorial optimization
The minimum cycle mean is the backbone of:
- Karp’s algorithm,
- policy iteration,
- mean-payoff games,
- shortest-path asymptotics.

Your formalization would make Lean a credible environment for certified tropical optimization.

### 2. Dynamical systems and control
The tropical eigenvalue is the asymptotic average cost per step in deterministic min-plus dynamics:
\[
x_{t+1}(i)=\min_j (W_{ij}+x_t(j)).
\]
This is the discrete Hamilton–Jacobi / optimal control perspective. Formalizing it opens the door to certified ergodic control in min-plus algebra.

### 3. Weighted automata and formal languages
Cycles govern long-run average weight of automata runs. Your theorem becomes a certified statement about asymptotic automaton cost, linking Lean formalization to verification and semantics.

### 4. Tropical geometry and non-Archimedean spectral theory
Cycle means are tropical analogues of valuations of eigenvalues/slopes. A successful bridge to `tropical_rayleigh_eigenvalue` could seed a true tropical spectral geometry.

### 5. Arithmetic/Langlands
With `tropical_eigenvalue_determines_char`, there is a tantalizing route from combinatorial spectral invariants to tropical Hecke characters. Even one precise compatibility theorem would be field-opening.

---

## Concrete Development Plan

### Phase I: Definitions and easy lemmas
- Define closed walks, cycle cost, cycle mean.
- Prove:
  - cost under constant shift,
  - mean under constant shift,
  - diagonal 1-cycle evaluation,
  - monotonicity of cost and mean under pointwise matrix order.

### Phase II: Cycle reduction theorem
- Formalize repeated-vertex decomposition.
- Prove one subcycle has mean ≤ original mean.
- Derive existence of a simple cycle minimizer.

### Phase III: Define tropical eigenvalue via finite minimization
If `sInf` is awkward, define:
- a finite family of candidate cycles of lengths `1..n`,
- tropical eigenvalue as `Finset.inf'` over their means.

Then prove equivalence with the conceptual `sInf` version if desired.

### Phase IV: Spectral bridge
- Inspect and connect with `tropical_rayleigh_eigenvalue`.
- Attempt a theorem equating both notions for matrices on `Fin n`.

### Phase V: Examples and arithmetic/tropical interface
- Diagonal matrices,
- constant matrices,
- 2×2 explicit formula if feasible,
- example inspired by `bigOmega_eq_tropical_weight`.

---

## High-Value Auxiliary Lemmas

You will likely need lemmas of the following shape:

```lean
theorem cycleCost_add_const
    {n k : ℕ} (W : Matrix (Fin n) (Fin n) ℝ)
    (v : Fin (k+1) → Fin n) (a : ℝ) :
    cycleCost (W + fun _ _ => a) v = cycleCost W v + k * a := ...

theorem cycleMean_add_const
    {n k : ℕ} (W : Matrix (Fin n) (Fin n) ℝ)
    (hk : 0 < k) (v : Fin (k+1) → Fin n) (a : ℝ) :
    cycleMean (W + fun _ _ => a) hk v = cycleMean W hk v + a := ...

theorem cycleCost_mono
    {n k : ℕ} {W W' : Matrix (Fin n) (Fin n) ℝ}
    (h : ∀ i j, W i j ≤ W' i j) (v : Fin (k+1) → Fin n) :
    cycleCost W v ≤ cycleCost W' v := ...

theorem cycleMean_mono
    {n k : ℕ} (hk : 0 < k)
    {W W' : Matrix (Fin n) (Fin n) ℝ}
    (h : ∀ i j, W i j ≤ W' i j) (v : Fin (k+1) → Fin n) :
    cycleMean W hk v ≤ cycleMean W' hk v := ...
```

These are not filler. They are the algebraic backbone for the main spectral theorems.

---

## What Would Make This a Breakthrough

If you stop at “definition exists,” this is nothing.  
If you prove the attainment, simple-cycle reduction, shift invariance, monotonicity, and a bridge to `tropical_rayleigh_eigenvalue`, then you have created:

- a certified tropical spectral invariant,
- a reusable finite-combinatorial engine for min-plus linear algebra,
- a bridge between graph optimization and tropical spectral theory,
- a launching point for formalized mean-payoff games and tropical dynamics.

That is a new research axis, not a minor library addition.

---

## Deliverables

Required:
1. Lean 4 code with minimal `sorry`.
2. A coherent file implementing the definition and at least the core theorems:
   - `tropicalEigenvalue_attained`
   - `exists_simple_cycle_mean_le`
   - `tropicalEigenvalue_add_const`
   - `tropicalEigenvalue_mono`
   - `tropicalEigenvalue_diagonal`
3. A structured `FUTURE_DIRECTIONS.md`.

Optional but highly encouraged:
- `ARTICLE.md` explaining the mathematics and formalization choices,
- a small example file with explicit `2×2` and diagonal computations.

---

## Required FUTURE_DIRECTIONS.md

You must produce `FUTURE_DIRECTIONS.md` with **3–5 concrete next theorems**, each containing:
- precise theorem statement,
- why it matters,
- likely proof strategy,
- cross-domain connection.

The next steps should be breakthrough-level, for example:

1. **Tropical Collatz–Wielandt theorem**  
   Characterize `tropicalEigenvalue W` as the infimum of `μ` such that there exists `x` with  
   `∀ i, min_j (W i j + x j) ≤ μ + x i`.

2. **Karp algorithm correctness in Lean**  
   Formalize an algorithm computing minimum cycle mean and prove correctness.

3. **Mean-payoff game value = tropical eigenvalue**  
   For one-player deterministic games first, then two-player variants.

4. **Bridge theorem with `tropical_rayleigh_eigenvalue`**  
   Full equivalence with the catalog spectral invariant.

5. **Tropical characteristic data from cycle structure**  
   Use `tropical_eigenvalue_determines_char` to derive character rigidity from cycle means.

---

## Application Keywords

tropical algebra, min-plus spectral theory, minimum cycle mean, Karp algorithm, weighted digraphs, mean-payoff games, optimal control, Hamilton–Jacobi, weighted automata, tropical Rayleigh quotient, non-Archimedean spectral theory, tropical Langlands, certified optimization, formal verification, Lean 4, Mathlib

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
