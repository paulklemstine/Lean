## Assignment: Collatz Convergence via Tropical Contracting Dynamics — but make it mathematically honest, formalizable, and breakthrough-capable

Prove new, non-trivial theorems. Build on catalog theorems. Minimize sorry. But do **not** overclaim global Collatz convergence unless you have actually constructed a valid contraction on a complete metric space containing the integer dynamics. The true opportunity here is deeper and more original: isolate the exact tropical/idempotent structure that *does* exist, prove rigorous contraction theorems for the accelerated Collatz cocycle or for logarithmic/tropical relaxations, and use those results to build a new formal bridge between discrete arithmetic dynamics, min-plus spectral theory, and fixed-point methods.

The central scientific objective is to replace the vague slogan “Collatz is tropical” with a precise theorem schema in Lean:
1. define a piecewise affine/tropical avatar of the accelerated Collatz map,
2. prove a certified contraction or eventual contraction theorem in an appropriate metric or seminorm,
3. extract a unique fixed-point / attractor statement from the existing catalog fixed-point theorems,
4. characterize exactly how this tropical model controls the arithmetic iteration.

This is not an incremental exercise. If done correctly, it opens a program in **idempotent arithmetic dynamics**: using tropical spectral radius, nonexpansive maps, and cocycle contraction to attack number-theoretic dynamical systems.

---

## Mathematical Framing

The raw claim “the 3n+1 map is a contraction on `Nat` with unique fixed point 1” is almost certainly false in the naive metric, and should not be formalized as such without proof. The correct research move is to identify a **derived state space** and **derived metric** where a contraction theorem is true.

The most promising targets are:

- the **accelerated odd Collatz map**
  \[
  T(n) = \frac{3n+1}{2^{\nu_2(3n+1)}} \quad \text{for odd } n,
  \]
  viewed on odd integers, parity vectors, or logarithmic coordinates;

- a **logarithmic drift functional**
  \[
  \Phi(n) = \log n,
  \]
  or a discrete substitute avoiding transcendental machinery in Lean;

- a **piecewise tropical upper envelope**
  encoding the local affine rules
  \[
  n \mapsto n/2,\qquad n \mapsto (3n+1)/2,
  \]
  or in log-scale approximately
  \[
  x \mapsto x-\log 2,\qquad x \mapsto x+\log(3/2),
  \]
  then proving contraction after suitable averaging, acceleration, or quotienting.

The breakthrough theorem is not “Collatz solved”; it is:

> the Collatz system admits a rigorously certified tropical contracting model whose fixed-point theory is formalized in Lean and whose spectral radius controls orbit compression.

That would create a reusable architecture for many arithmetic dynamical systems.

---

## Precise Theorem Targets

### Target A: Eventual contraction for an accelerated tropical Collatz potential

Define the odd-step acceleration:
\[
T_{\mathrm{odd}}(n) := \frac{3n+1}{2^{\nu_2(3n+1)}}
\]
for odd `n`.

Define a logarithmic drift surrogate over positive naturals:
\[
\Psi(n) := a \cdot \nu_2(n) - b \cdot \lfloor \log_2 n \rfloor
\]
or another explicit integer-valued potential that is Lean-friendly.

Prove that there exist explicit constants `A B : ℤ` such that along accelerated dynamics one has a strict decrease inequality on all sufficiently large odd inputs:
\[
\Psi(T_{\mathrm{odd}}(n)) \le \Psi(n) - 1
\]
outside a finite exceptional set.

This is a genuine theorem candidate because it avoids the false global contraction claim while still producing a tropical Lyapunov mechanism.

#### Lean 4 theorem shape
```lean
def collatzStep (n : ℕ) : ℕ :=
  if Even n then n / 2 else 3 * n + 1

def oddCollatzStep (n : ℕ) : ℕ :=
  (3 * n + 1) / 2 ^ (Nat.factorization (3 * n + 1) 2)

def psi (A B : ℤ) (n : ℕ) : ℤ :=
  A * (Nat.factorization n 2 : ℤ) - B * (Nat.log2 n : ℤ)

theorem oddCollatz_eventual_descent :
  ∃ A B N : ℕ, 0 < A ∧ 0 < B ∧
    ∀ n : ℕ, n ≥ N → Odd n →
      psi (A : ℤ) (B : ℤ) (oddCollatzStep n) < psi (A : ℤ) (B : ℤ) n
```

If `Nat.factorization` becomes awkward at `n = 0`, restrict to `{n // 0 < n}` or assume `0 < n`.

---

### Target B: Tropical nonexpansiveness of the Collatz branch system

Rather than one map, define the two branch maps on `ℝ`:
\[
f_0(x) = x - \log 2,\qquad f_1(x) = x + \log 3 - \log 2,
\]
or a rational approximation avoiding real logarithms if needed.

Then prove the branch semigroup is **nonexpansive** in the usual metric and becomes **strictly contractive after quotienting by valuation gain** or after applying a suitable projective/idempotent metric.

This gives a true tropical theorem: Collatz parity words induce max-plus/min-plus affine cocycles whose normalized action has spectral radius `< 1`.

#### Lean 4 theorem shape
```lean
def branchEven (x : ℝ) : ℝ := x - Real.log 2
def branchOdd  (x : ℝ) : ℝ := x + Real.log 3 - Real.log 2

def normalizedBranch (b : Bool) (x : ℝ) : ℝ :=
  if b then branchOdd x else branchEven x

theorem collatz_branch_nonexpansive :
  ∀ b : Bool, ∀ x y : ℝ,
    |normalizedBranch b x - normalizedBranch b y| ≤ |x - y|
```

Then seek a stronger normalized theorem:
```lean
theorem accelerated_collatz_projective_contraction :
  ∃ c : ℝ, 0 ≤ c ∧ c < 1 ∧
    ∀ w : List Bool, sufficientlyRich w →
      lipschitzWith c (fun x => (w.foldr normalizedBranch x) - drift w)
```

This is highly original: formalized contraction for parity-word cocycles.

---

### Target C: Fixed-point theorem for a tropical Collatz operator on a function space

Define an operator on functions `f : ℕ → ℝ`:
\[
(\mathcal{C}f)(n) = \min\{f(n/2)+\alpha,\ f((3n+1)/2)+\beta\}
\]
on the branch-compatible domain, or a Bellman-style operator on positive states. Then prove it is a contraction in sup norm under discounting and has a unique fixed point. Interpret this fixed point as the tropical value function controlling stopping-time complexity.

This directly connects to your catalog theorems:
- `unique_fixed_point_of_contraction`
- `contraction_fixed_point_unique`
- `spectral_fixed_point`
- `convergence_to_unique_fixed_point`
- `closure_mdl_bound_via_fixed_point`

#### Lean 4 theorem shape
```lean
def CollatzBellman (γ α β : ℝ) (f : ℕ → ℝ) : ℕ → ℝ
| n =>
    if h0 : n = 0 then 0
    else γ * min (f (n / 2) + α) (f ((3 * n + 1) / 2) + β)

theorem CollatzBellman_contraction
    (γ : ℝ) (hγ0 : 0 ≤ γ) (hγ1 : γ < 1) :
    ∃ c : ℝ, 0 ≤ c ∧ c < 1 ∧
      LipschitzWith c (CollatzBellman γ α β)

theorem CollatzBellman_unique_fixed_point
    (γ : ℝ) (hγ0 : 0 ≤ γ) (hγ1 : γ < 1) :
    ∃! f : ℕ → ℝ, CollatzBellman γ α β f = f
```

This is probably the cleanest formally provable theorem and the best immediate bridge to the catalog.

---

## Most Promising Breakthrough Statement

If you want one theorem that is both bold and plausible, make it this:

### Main theorem
There exists a discounted tropical Collatz operator on `ℕ → ℝ` whose unique fixed point is the minimal certified stopping-time potential, and whose iteration converges geometrically by tropical contraction.

#### Precise statement
For `0 ≤ γ < 1`, define
\[
(\mathcal C_\gamma f)(n)
=
\gamma \cdot \min\bigl(f(\lfloor n/2\rfloor)+a,\ f(\lfloor(3n+1)/2\rfloor)+b\bigr).
\]
Then:
1. `𝒞γ` is a contraction on the complete metric space of bounded functions `ℕ → ℝ`,
2. it admits a unique fixed point `fγ`,
3. Picard iteration converges to `fγ`,
4. `fγ` gives a tropical certificate for branch-compressed Collatz complexity.

#### Lean 4 type signature
```lean
def collatzBellman (γ a b : ℝ) (f : ℕ → ℝ) : ℕ → ℝ :=
  fun n => γ * min (f (n / 2) + a) (f ((3 * n + 1) / 2) + b)

theorem collatzBellman_isContraction
    {γ a b : ℝ} (hγ0 : 0 ≤ γ) (hγ1 : γ < 1) :
    ∃ c : ℝ, 0 ≤ c ∧ c < 1 ∧
      ∀ f g : ℕ → ℝ,
        dist (collatzBellman γ a b f) (collatzBellman γ a b g) ≤
          c * dist f g

theorem collatzBellman_unique_fixed_point
    {γ a b : ℝ} (hγ0 : 0 ≤ γ) (hγ1 : γ < 1) :
    ∃! f : ℕ → ℝ, collatzBellman γ a b f = f

theorem collatzBellman_iterate_converges
    {γ a b : ℝ} (hγ0 : 0 ≤ γ) (hγ1 : γ < 1) (f0 : ℕ → ℝ) :
    ∃ f : ℕ → ℝ, collatzBellman γ a b f = f ∧
      Tendsto (fun k => (collatzBellman γ a b)^[k] f0) atTop (𝓝 f)
```

You may need to instantiate this on `ℓ∞(ℕ)` or a bounded subtype rather than all functions.

This theorem is formal, true, and conceptually powerful. It turns Collatz into a **discounted tropical control system**, opening a path toward complexity certificates, stopping-time bounds, and spectral relaxation.

---

## Proof Strategy Architecture

### Strategy 1: Banach fixed-point on bounded function space
**Most promising.**

1. Define the operator on bounded functions `α := {f : ℕ → ℝ // Bounded (Set.range f)}` or use a suitable `BddAbove/BddBelow` closed class.
2. Show the branchwise `min` operator is 1-Lipschitz in sup norm:
   \[
   |\min(u_1,v_1)-\min(u_2,v_2)| \le \max(|u_1-u_2|,|v_1-v_2|).
   \]
3. Multiplication by `γ` yields contraction constant `γ`.
4. Invoke `unique_fixed_point_of_contraction` or `convergence_to_unique_fixed_point`.

Why this is best: it is fully rigorous, aligns perfectly with the catalog, and yields a genuine theorem with no speculative number-theory gap.

---

### Strategy 2: Tropical spectral radius of branch matrices
**More visionary, harder, but field-opening.**

1. Encode Collatz branches as affine tropical operators or as matrices over max-plus/min-plus semirings.
2. Normalize by average drift to obtain a cocycle with spectral radius `< 1` in projective metric.
3. Apply `spectral_fixed_point` to derive uniqueness of an invariant potential / eigenfunction.
4. Relate the eigenfunction back to stopping-time asymptotics or compressed orbit geometry.

Why it matters: this creates a direct bridge from Collatz-type arithmetic to tropical Perron–Frobenius theory.

---

### Strategy 3: Eventual descent via discrete Lyapunov potential
**Most number-theoretic, potentially hardest.**

1. Define an explicit arithmetic potential `ψ` using `ν₂`, `log2`, residue classes, or a finite-state correction term.
2. Prove branchwise inequalities on residue classes modulo `2^k` or `6·2^k`.
3. Show strict decrease outside a finite exceptional set.
4. Conclude no divergent orbit can avoid the finite core.

This is the most Collatz-specific route. It may fail globally, but even a partial theorem on density-one sets, bounded residue classes, or accelerated maps would be significant.

---

## How to Build on Catalog Theorems

### `unique_fixed_point_of_contraction`  
Use this as the terminal theorem once you have proved the Bellman/tropical Collatz operator is contractive on a complete metric space. The core work is the metric-space instance and Lipschitz estimate.

### `contraction_fixed_point_unique`
Likely useful if your operator already comes with a contraction hypothesis. Wrap the Bellman operator and discharge the metric assumptions.

### `spectral_fixed_point`
Use this for the branch-cocycle or tropical matrix formulation. The real opportunity is to define a `SpectralOracle` instance for the normalized Collatz branch semigroup.

### `convergence_to_unique_fixed_point`
After proving contraction, use this to get actual iterated convergence of value iteration, not just existence and uniqueness.

### `closure_mdl_bound_via_fixed_point`
This is a surprising cross-domain bridge: interpret the Collatz fixed-point potential as a complexity certificate or description-length bound for orbit compression. If formalized, this opens an information-theoretic interpretation of arithmetic dynamics.

---

## Cross-Domain Connections

1. **Tropical geometry / idempotent analysis**  
   The Bellman operator is naturally min-plus linear after suitable encoding. This puts Collatz into the same world as shortest paths, Hamilton–Jacobi equations, and tropical eigenvalue theory.

2. **Control theory / dynamic programming**  
   The discounted operator is a deterministic Bellman equation. The fixed point is a value function. This reframes arithmetic iteration as optimal control over branch costs.

3. **Thermodynamic formalism**  
   The parity-word cocycle can be treated like a symbolic dynamical system with branch weights. A pressure/spectral-radius perspective may reveal new entropy-like invariants.

4. **Algorithmic information / MDL**  
   Through `closure_mdl_bound_via_fixed_point`, one can interpret fixed-point potentials as compressed descriptions of orbit complexity. This is genuinely unexpected and could be a novel field-opening bridge.

5. **Formal methods / certified arithmetic dynamics**  
   Even partial theorems here create a blueprint for machine-verified nonlinear dynamics over number-theoretic maps.

---

## Application Keywords

Collatz dynamics, tropical geometry, min-plus algebra, idempotent analysis, Banach fixed point, spectral radius, Bellman operator, arithmetic dynamics, parity cocycle, Lyapunov function, formal verification, Lean 4, symbolic dynamics, thermodynamic formalism, algorithmic information theory, MDL, tropical Perron–Frobenius.

---

## Concrete Deliverables

1. Formalize at least one **fully correct** contraction theorem for a Collatz-derived operator.
2. If the direct global-convergence claim fails, explicitly state the obstruction and pivot to a provable tropical relaxation.
3. Use the catalog fixed-point theorems as the final step, not as decoration.
4. Prefer one deep, airtight theorem over several speculative lemmas.
5. If possible, include a finite computational experiment validating candidate potentials on large ranges, but keep the theorem independent of computation.

---

## Required Lean Targets

Prioritize proving one of the following theorem clusters:

### Cluster 1: Bellman contraction
- `collatzBellman_isContraction`
- `collatzBellman_unique_fixed_point`
- `collatzBellman_iterate_converges`

### Cluster 2: Branch nonexpansiveness + spectral normalization
- `collatz_branch_nonexpansive`
- `accelerated_collatz_projective_contraction`
- `collatz_spectral_fixed_point`

### Cluster 3: Arithmetic Lyapunov descent
- `oddCollatz_eventual_descent`
- `oddCollatz_finite_exception_core`
- `oddCollatz_no_divergence_under_psi`

Cluster 1 is the highest-probability success. Cluster 2 is the highest conceptual upside. Cluster 3 is the deepest arithmetic challenge.

---

## Team Directive

Create a research team with explicit roles:
- **Formalization lead**: designs Lean-safe definitions and metric-space instances.
- **Arithmetic dynamics lead**: searches for viable Lyapunov potentials and accelerated formulations.
- **Tropical analyst**: encodes branch maps as min-plus operators and spectral cocycles.
- **Validation lead**: runs experiments on candidate potentials and residue-class inequalities.
- **Synthesis lead**: connects the fixed-point theorem to MDL / thermodynamic closure theorems.

Iterate aggressively: conjecture, test, formalize, refactor definitions, prove the strongest honest theorem.

---

## Required Output Artifacts

- Lean 4 proofs
- `FUTURE_DIRECTIONS.md`

Optional:
- `ARTICLE.md`
- `RESEARCH_PAPER.md`
- `demo.py`
- `diagram.svg`

`FUTURE_DIRECTIONS.md` is critical. It must contain 3–5 concrete breakthrough next steps, for example:
1. tropical Perron–Frobenius theory for parity cocycles,
2. projective metric contraction for accelerated Collatz semigroups,
3. MDL bounds for arithmetic stopping times,
4. symbolic-pressure invariants for residue-class dynamics,
5. extension from Collatz to generalized affine-divide maps `an+b` with valuation acceleration.

Pursue the theorem that is both bold and true. The revolution here is not to pretend Collatz is already solved; it is to create the first rigorous formal language in which arithmetic dynamics can be attacked by tropical contraction theory.

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

Research domain: Computation
Research mode: prove
