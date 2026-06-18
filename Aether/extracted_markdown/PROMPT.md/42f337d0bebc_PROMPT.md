Soli Deo Gloria

## Assignment: Direction 1 — Exponential Convergence via Spectral Gap

**Mode:** `prove`

Aristotle, this is not a request for a routine asymptotic sharpening. This is a chance to turn a combinatorial curvature-flow estimate into a genuine spectral theorem: to show that greedy discrete uniformization is governed by a hidden Laplacian gap, and therefore converges on the natural diffusive timescale \(n^2\), not by crude one-step dissipation. If successful, this would connect discrete conformal geometry, spectral graph theory, and mixing-time theory in a way that feels structurally new, not merely stronger.

The target is to upgrade the existing polynomial-style convergence theorem in

- `Pythagorean/CurvatureFlow/Convergence.lean : FlowSystem.convergence`

using the pairwise-variance identity from

- `Pythagorean/CurvatureFlow/Defs.lean : pairwise_sq_diff_eq`

into a multiplicative decay theorem driven by a discrete Poincaré / spectral-gap mechanism.

---

## Core Breakthrough Goal

### Precise theorem statement

Let \(T\) be a triangulated surface with vertex set \(V\), \(|V| = n\), and let \(K_k : V \to \mathbb{R}\) be the curvature vector after \(k\) greedy curvature-flow steps. Let
\[
\bar K := \frac{1}{n}\sum_{v \in V} K_k(v)
\]
(which is flow-invariant if total curvature is preserved), and define the variance energy
\[
\mathcal V(K_k) := \sum_{v \in V} (K_k(v)-\bar K)^2.
\]

The breakthrough theorem is:

> **Spectral-gap exponential convergence theorem.**  
> There exists a universal constant \(C>0\) such that for every admissible triangulated surface flow system \(F\) with \(n \ge 2\), if \(V_k := F.varianceAt\; k\), then for all \(k\),
> \[
> V_{k+1} \le \left(1 - \frac{C}{n^2}\right)V_k,
> \]
> and hence
> \[
> V_k \le \left(1 - \frac{C}{n^2}\right)^k V_0.
> \]

This is the mathematically meaningful form of `exponential_convergence_conjecture`: one-step multiplicative contraction, from which the global estimate follows by induction.

### Suggested Lean 4 type signature

You will likely need to introduce a refined structure encoding the ingredients that make the theorem true. A plausible target is:

```lean
/-- A flow system equipped with a spectral-gap lower bound at scale `1 / n^2`. -/
structure SpectralGapFlowSystem (α : Type _) extends FlowSystem α where
  card_vertices_pos : 0 < Fintype.card α
  gap_constant : ℝ
  gap_constant_pos : 0 < gap_constant
  poincare_step :
    ∀ k : ℕ,
      varianceAt (k+1) ≤ (1 - gap_constant / (Fintype.card α : ℝ)^2) * varianceAt k
```

Then the central theorem can be stated as:

```lean
theorem varianceAt_le_exponential
    {α : Type _} [Fintype α] [DecidableEq α]
    (F : SpectralGapFlowSystem α) :
    ∀ k : ℕ,
      F.varianceAt k ≤
        ((1 - F.gap_constant / (Fintype.card α : ℝ)^2) ^ k) * F.varianceAt 0
```

A more ambitious universal-constant form is:

```lean
theorem exponential_convergence_universal
    {α : Type _} [Fintype α] [DecidableEq α]
    (F : FlowSystem α)
    (hAdmissible : F.Admissible)
    (hSpectral : F.HasUniversalSpectralGap)
    (k : ℕ) :
    F.varianceAt k ≤
      ((1 - hSpectral.C / (Fintype.card α : ℝ)^2) ^ k) * F.varianceAt 0
```

where `HasUniversalSpectralGap` is a new concept you define.

---

## New definitions you should introduce

You are required to add at least one genuinely new mathematical concept. Here are the right ones.

### 1. Spectral dissipation profile
Define a quantity measuring the edgewise Dirichlet energy of a curvature state:

```lean
def dirichletEnergy (κ : α → ℝ) : ℝ := ...
```

with intended meaning
\[
\mathcal E(\kappa) := \sum_{\{i,j\}\in E} (\kappa(i)-\kappa(j))^2.
\]

Then define a spectral lower-bound predicate:

```lean
def HasPoincareConstant (F : FlowSystem α) (λ : ℝ) : Prop := ...
```

encoding
\[
\mathcal V(\kappa) \le \lambda^{-1}\mathcal E(\kappa)
\quad\text{for all curvature states }\kappa\text{ arising along the flow.}
\]

### 2. Greedy multiplicative progress
Formalize the idea that the greedy move captures a definite fraction of the available Dirichlet energy:

```lean
def GreedyCapturesDirichlet (F : FlowSystem α) (c : ℝ) : Prop := ...
```

meaning
\[
\mathcal V(K_k)-\mathcal V(K_{k+1}) \ge c\,\mathcal E(K_k).
\]

This is the crucial bridge from combinatorial local move to global spectral decay.

### 3. Universal spectral-gap class
A bold but natural abstraction:

```lean
def HasUniversalSpectralGap (F : FlowSystem α) : Prop := ∃ C > 0, ...
```

where the quantified statement should force
\[
\lambda_1(F_k) \ge C/n^2
\]
uniformly along the flow, or at least the weaker Poincaré inequality sufficient for variance decay.

This is not catalog boilerplate. It creates a reusable interface for future theorems on mixing, entropy decay, and cutoff.

---

## Theorem package: at least 3 deep theorems

Your file must contain at least three substantial theorems, proved with real mathematical structure. Here is the package to target.

### Theorem 1: One-step variance drop from Dirichlet capture
This is the engine.

```lean
theorem variance_step_le_of_dirichlet_control
    {α : Type _} [Fintype α] [DecidableEq α]
    (F : FlowSystem α)
    (c : ℝ)
    (hcap : F.GreedyCapturesDirichlet c)
    (k : ℕ) :
    F.varianceAt (k+1) ≤ F.varianceAt k - c * F.dirichletAt k
```

**Mathematical content:**
\[
V_{k+1} \le V_k - c\,E_k.
\]

This theorem should use multi-step `calc`, unpacking the new definitions and the existing variance identities. It is nontrivial because it converts local greedy choice into a quantitative energy inequality.

### Theorem 2: Spectral-gap contraction
Combine Poincaré with Theorem 1.

```lean
theorem variance_step_contracts
    {α : Type _} [Fintype α] [DecidableEq α]
    (F : FlowSystem α)
    (c λ : ℝ)
    (hcap : F.GreedyCapturesDirichlet c)
    (hP : F.HasPoincareConstant λ)
    (hc : 0 ≤ c)
    (hλ : 0 < λ)
    (k : ℕ) :
    F.varianceAt (k+1) ≤ (1 - c * λ) * F.varianceAt k
```

**Mathematical content:**
if \(V_k \le \lambda^{-1} E_k\), then
\[
V_{k+1} \le V_k - cE_k \le (1-c\lambda)V_k.
\]

This is where the proof should use `nlinarith`, `field_simp` where needed, and a careful positivity argument.

### Theorem 3: Iterated exponential decay
Now iterate the contraction.

```lean
theorem variance_le_geometric
    {α : Type _} [Fintype α] [DecidableEq α]
    (F : FlowSystem α)
    (ρ : ℝ)
    (hρ0 : 0 ≤ ρ)
    (hρ1 : ρ ≤ 1)
    (hstep : ∀ k : ℕ, F.varianceAt (k+1) ≤ (1 - ρ) * F.varianceAt k) :
    ∀ k : ℕ, F.varianceAt k ≤ (1 - ρ)^k * F.varianceAt 0
```

This should be an honest induction theorem, not a one-line library invocation.

### Theorem 4: Universal \(n^{-2}\) corollary
The headline theorem.

```lean
theorem variance_le_exp_nsq
    {α : Type _} [Fintype α] [DecidableEq α]
    (F : FlowSystem α)
    (C : ℝ)
    (hC : 0 < C)
    (hGap : F.HasUniversalSpectralGapWith C)
    (k : ℕ) :
    F.varianceAt k ≤
      (1 - C / (Fintype.card α : ℝ)^2)^k * F.varianceAt 0
```

This theorem should not be vacuous: `HasUniversalSpectralGapWith C` must itself encode substantive hypotheses, not the conclusion restated.

---

## Proof architecture: 3 viable strategies

You must pursue one main route, but record at least 2–3 plausible proof programs in the paper and future directions.

### Strategy A — Direct spectral-Poincaré route
**Most promising.**

1. Use `pairwise_sq_diff_eq` to rewrite variance in pairwise-difference form:
   \[
   \sum_i (f_i-\bar f)^2 = \frac{1}{2n}\sum_{i,j}(f_i-f_j)^2.
   \]
   This is the right algebraic portal because it turns variance into a sum over pairs, compatible with graph-path arguments.

2. Prove a combinatorial comparison inequality between all-pairs energy and edge energy:
   \[
   \sum_{i,j}(f_i-f_j)^2 \le \mathrm{diam}(G)\cdot |E| \cdot \sum_{(u,v)\in E}(f_u-f_v)^2,
   \]
   or some weaker but uniform \(O(n^2)\) estimate sufficient to get
   \[
   V(f)\le C^{-1}n^2 E(f).
   \]

3. Show the greedy flip decreases variance by at least a fixed fraction of the local edge discrepancy selected by the greedy rule; then lower-bound that local discrepancy by a fraction of total Dirichlet energy.

4. Combine to get
   \[
   V_{k+1}\le V_k - cE_k \le \left(1-\frac{C}{n^2}\right)V_k.
   \]

**Why best:** it uses the exact catalog lineage you already have, especially `pairwise_sq_diff_eq`, and keeps the argument finite, algebraic, and compatible with Lean.

### Strategy B — Comparison with random-walk heat flow
1. Define an auxiliary averaging operator \(P\) on curvature states, analogous to one step of lazy random walk on the 1-skeleton.
2. Show greedy flow dominates \(P\) in variance dissipation:
   \[
   V(\text{greedy step}) \le V(P\kappa).
   \]
3. Import or prove the standard spectral estimate for \(P\):
   \[
   V(P^k\kappa) \le (1-\lambda_1)^kV(\kappa).
   \]
4. Compare \(\lambda_1\) with \(n^{-2}\) using graph geometry of triangulations.

**Why interesting:** this reveals the flow as a nonlinear accelerated heat equation. It opens direct bridges to Markov-chain mixing and cutoff phenomena.

### Strategy C — Canonical paths / congestion argument
1. Use shortest paths in the triangulation graph to express each pairwise difference \(f(i)-f(j)\) as a telescoping sum over edges.
2. Apply Cauchy–Schwarz to bound pairwise energy by path length times edge energy.
3. Sum over all pairs and control edge congestion to derive a Poincaré inequality.

**Why useful:** this avoids explicit spectral linear algebra and may be easier to formalize if the graph-theoretic side of Mathlib is more convenient than eigenvalue machinery.

---

## How to build on the catalog

### From `pairwise_sq_diff_eq`
Do not cite this passively. Use it as the exact variance-to-pairwise-energy conversion. The intended move is:

- start from `F.varianceAt k`;
- rewrite it as a normalized all-pairs sum;
- compare all-pairs differences to edgewise differences via path decomposition;
- derive the Poincaré inequality.

This theorem is the algebraic hinge of the whole program.

### From `FlowSystem.convergence`
The existing theorem likely gives additive descent or eventual convergence. Your mission is to isolate the exact place where the proof loses multiplicativity. Replace that coarse step by the new spectral estimate. Ideally, your final theorem should strictly subsume the existing result:

- old bound: \(O(V_0/\varepsilon)\),
- new bound: \(O(n^2\log(V_0/\varepsilon))\).

If possible, prove a corollary:

```lean
theorem steps_to_eps_bound
    ...
    (hε : 0 < ε) :
    ∃ N ≤ ⌈((Fintype.card α : ℝ)^2 / C) * Real.log (F.varianceAt 0 / ε)⌉₊,
      F.varianceAt N ≤ ε
```

This would convert the asymptotic theorem into an algorithmic stopping-time guarantee.

---

## Cross-domain connections you must explicitly include

This project becomes field-opening only if you make the hidden equivalences explicit.

### 1. Spectral Graph Theory ↔ Discrete Curvature Flow
The variance is a Laplacian energy defect; the greedy flow is selecting a direction of maximal local Rayleigh quotient decrease. This reframes curvature equalization as spectral smoothing.

### 2. Markov Chain Theory ↔ Geometric Algorithms
Once you prove multiplicative contraction, the flow acquires a **mixing-time style estimate**:
\[
t_{\mathrm{mix}}(\varepsilon)\sim O(n^2\log(1/\varepsilon)).
\]
This is structurally the same complexity class as diffusive relaxation and random walk on 2D meshes.

### 3. Statistical Physics ↔ Triangulated Surfaces
The variance functional is an analogue of free-energy excess; the greedy move is a zero-temperature steepest descent, while the spectral gap is the linear response rate around equilibrium. This suggests a future stochastic curvature-flow theory with entropy production.

### 4. Discrete Uniformization ↔ Numerical PDE
Your theorem would say the greedy combinatorial flow behaves like an explicit discretization of heat flow with a mesh-dependent CFL scale \(n^2\). That opens the door to certified solvers and preconditioned algorithms for discrete conformal flattening.

### 5. Topology ↔ Dynamics
Because genus enters only through admissibility and total curvature constraints, a universal \(n^{-2}\) law across genera \(0,1,2\) would strongly suggest that topology changes the equilibrium manifold, not the relaxation exponent. That is a mathematically sharp scientific claim.

**Application keywords:** spectral gap, discrete Poincaré inequality, triangulated surfaces, combinatorial curvature, edge-flip dynamics, mixing time, Dirichlet energy, discrete uniformization, Laplacian comparison, geometric Markov chains, numerical geometry, statistical mechanics of meshes.

---

## Lean-specific formalization targets

You asked for precise type signatures. Here are additional targets worth implementing.

### Pairwise-to-edge comparison
```lean
theorem variance_le_card_sq_mul_dirichlet
    {α : Type _} [Fintype α] [DecidableEq α]
    (G : SimpleGraph α)
    (f : α → ℝ) :
    variance G f ≤ (Fintype.card α : ℝ)^2 * dirichletEnergy G f
```

Even a weaker explicit polynomial constant is useful if universal. If you can get `4 * card^2`, take it. The science is in the scaling law.

### Greedy progress lower bound
```lean
theorem greedy_step_decrease_ge_max_edge_drop
    {α : Type _} [Fintype α] [DecidableEq α]
    (F : FlowSystem α)
    (k : ℕ) :
    ∃ e,
      e ∈ F.activeEdges k ∧
      F.varianceAt k - F.varianceAt (k+1) ≥ localEdgeDrop F k e
```

Then compare `localEdgeDrop` to average edge discrepancy.

### Geometric iteration lemma
```lean
theorem geom_decay_iter
    (a ρ : ℝ) (k : ℕ)
    (hρ0 : 0 ≤ ρ) (hρ1 : ρ ≤ 1) :
    ((fun m => (1 - ρ)^m * a) (k+1)) = (1 - ρ) * ((1 - ρ)^k * a)
```

This is minor but useful scaffolding for a clean induction proof.

---

## Conjectures with testable predictions

You must include at least one falsifiable conjecture with a concrete disproof protocol. Include these in `FUTURE_DIRECTIONS.md`.

### Conjecture A — Universal spectral gap
There exists \(C>0\) such that every admissible triangulated-surface greedy curvature flow with \(n\) vertices satisfies
\[
V_{k+1}\le \left(1-\frac{C}{n^2}\right)V_k.
\]

**Computational test:** For random triangulations of genus \(0,1,2\) with \(n\in\{50,100,200,500\}\), estimate
\[
\hat C_k := n^2\left(1-\frac{V_{k+1}}{V_k}\right).
\]
If \(\inf_k \hat C_k\) systematically drifts toward \(0\) as \(n\to\infty\), the conjecture fails.

### Conjecture B — Sharp genus-independent constant
The optimal constant \(C_\ast\) is independent of genus for fixed local move rule.

**Computational test:** Compare empirical lower envelopes of \(\hat C_k\) across genera \(0,1,2\). A stable separation would refute genus-independence.

### Conjecture C — Cutoff-style profile collapse
After rescaling time by \(n^2\), the normalized variance trajectories converge to a universal profile:
\[
\frac{V(\lfloor tn^2\rfloor)}{V(0)} \to e^{-ct}.
\]

**Computational test:** Plot \(\log(V(k)/V_0)\) versus \(k/n^2\) across random triangulations. Lack of profile collapse or persistent curvature in the semilog plot would disprove the conjecture.

### Conjecture D — Entropy/variance equivalence
A discrete entropy functional \(\mathcal H\) exists with
\[
c_1 V \le \mathcal H \le c_2 V
\]
along the flow, implying the same \(n^2\)-scale decay for entropy.

**Computational test:** Define candidate entropies numerically and check bounded ratio \(\mathcal H/V\) along trajectories.

---

## Deliverables you must produce

You must produce **all** of the following.

### 1. Lean development
A new Lean file proving at least 3 substantial theorems, with:
- no trivialized proofs unless the theorem itself is major,
- at least one novel definition,
- at least one cross-domain theorem,
- minimized `sorry`.

### 2. `FUTURE_DIRECTIONS.md`
A structured document containing **3–5 falsifiable scientific hypotheses**, each with:
- exact conjecture statement,
- what data to generate,
- what statistic to measure,
- what outcome would refute it.

### 3. `RESEARCH_PAPER.md`
A **standalone scientific paper** explaining:
- the mathematical problem,
- the spectral-gap mechanism,
- the precise theorem(s),
- proof architecture,
- why the result changes the field,
- what new science now becomes possible.

A reader with no access to the code must still understand the discovery.

### 4. `ARTICLE.md`
A Scientific American–style article explaining the discovery to a broad audience.

**Taboo:** do **not** focus on formal verification machinery. Focus on the mathematics, the geometry, the spectral insight, and why diffusive \(n^2\) relaxation on triangulated surfaces is surprising and important.

### 5. Verified algorithm / computational method
Not just theorem statements: provide an algorithm that, given a triangulation and curvature state,
- computes the variance,
- estimates the Dirichlet energy,
- performs greedy steps,
- outputs an empirical lower bound on the contraction coefficient.

If possible, include a certified stopping criterion from the exponential bound.

### 6. `demo.py`
An interactive demonstration that:
- generates random triangulations for genus \(0,1,2\),
- runs the greedy curvature flow,
- plots \(\log(V(k)/V_0)\) vs \(k/n^2\),
- estimates empirical spectral-gap constants,
- highlights possible counterexample families.

---

## Revolutionary significance

If you can prove this, you do more than improve a convergence rate. You establish that greedy discrete curvature flow belongs to the same universality class as diffusion on 2D geometries. That would:

- give the first spectral-gap interpretation of this edge-flip dynamics,
- provide a principled complexity theory for discrete uniformization algorithms,
- connect deterministic geometric descent with Markov-chain mixing,
- suggest entropy methods, cutoff phenomena, and stochastic perturbations,
- create a reusable formal framework for spectral estimates in nonlinear discrete geometry.

This is the right kind of theorem: not “the same thing but slightly stronger,” but a structural reframing that makes future theorems inevitable.

Go after the multiplicative step inequality first. If you can force
\[
V_{k+1}\le V_k - cE_k
\]
and separately force
\[
V_k\le C^{-1}n^2E_k,
\]
the rest is destiny.

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
