## Assignment: Collatz Convergence via Tropical Contracting Dynamics — but make it mathematically honest, structurally fertile, and formalizable

Prove new, non-trivial theorems, but do **not** overclaim the actual Collatz conjecture unless you can reduce it to already-certified hypotheses. The breakthrough here is **not** “solve Collatz by sloganizing tropicality.” The breakthrough is to build a **formal bridge** between discrete arithmetic dynamics and tropical/idempotent contraction theory, isolating the exact obstruction to global convergence and proving strong conditional and local theorems that open a new research program.

Your mission is to extract a genuine theorem schema:

- encode Collatz-like maps as **piecewise-affine dynamics in logarithmic/tropical coordinates**,
- prove **contractivity on accelerated subsystems / quotient metrics / averaged cocycles**,
- derive **unique fixed point or attractor statements** from existing contraction and spectral tools,
- and identify the precise formal statement whose proof would imply global Collatz convergence.

This is not incremental. If successful, it opens a field: **idempotent arithmetic dynamics**.

---

## Research Direction

Replace the naive false claim

> “the Collatz map is globally contracting on ℕ and therefore converges to 1”

with a sharp, formal, multi-layered program:

1. Define the Collatz map and one or more accelerated variants.
2. Transport the dynamics into a tropical/logarithmic coordinate system.
3. Prove that the induced update is **piecewise min-plus affine** or admits a **tropical majorant**.
4. Prove **strict contraction** for an accelerated/averaged operator on a suitable metric space, or prove a **spectral radius bound** implying asymptotic contraction.
5. Deduce convergence to the unique fixed point for the accelerated model.
6. State a precise reduction theorem: if the original Collatz map is trapped by the contracting tropical envelope, then global convergence follows.

The revolutionary significance is that this turns Collatz from a naked number-theoretic iteration into a problem in:

- tropical geometry,
- idempotent analysis,
- metric fixed-point theory,
- symbolic dynamics,
- and renormalization of arithmetic maps.

That bridge is itself publishable and foundational, even if unconditional global Collatz remains out of reach.

---

## Precise Theorem Targets

You should aim for a package of theorems, not a single overambitious claim.

### 1. Basic formalization of Collatz and accelerated Collatz

Define:

- `collatz : ℕ → ℕ`
- `oddStep : ℕ → ℕ := fun n => (3*n + 1) / 2^(ν₂ (3*n+1))` on odd `n`
- a logarithmic/tropical potential `Φ : ℕ → ℝ`, preferably `Φ n = Real.log (n : ℝ)` or a weighted variant.

Suggested Lean signatures:

```lean
def collatz (n : ℕ) : ℕ :=
  if n % 2 = 0 then n / 2 else 3 * n + 1

def collatzAccel (n : ℕ) : ℕ :=
  if h : n % 2 = 1 then
    Nat.div (3 * n + 1) (2 ^ (Nat.factorization (3 * n + 1) 2))
  else
    n

def logPotential (n : ℕ) : ℝ :=
  Real.log (n : ℝ)
```

If `Nat.factorization` is awkward, define an abstract acceleration using existence of maximal 2-adic valuation, or work with a simpler one-step odd map:
```lean
def collatzOdd (n : ℕ) : ℕ := (3 * n + 1) / 2
```
restricted to odd inputs.

---

### 2. Piecewise tropical majorization theorem

Formalize that in logarithmic coordinates, Collatz is bounded above by a max-plus / min-plus affine system. Since exact tropical linearity is unlikely on ℕ, prove a **majorization theorem**.

#### Target theorem
For all `n ≥ 1`,
- if `n` is even, then `Φ(collatz n) = Φ n - log 2`,
- if `n` is odd, then `Φ(collatz n) ≤ Φ n + log 3 + ε(n)` for an explicit decaying error term.

A precise statement:

```lean
theorem collatz_log_even
    {n : ℕ} (hn : 1 ≤ n) (hEven : n % 2 = 0) :
    logPotential (collatz n) = logPotential n - Real.log 2 := by
  ...
```

For the odd branch, because `log (3n+1)` is not exactly `log n + log 3`, prove:

```lean
theorem collatz_log_odd_upper
    {n : ℕ} (hn : 1 ≤ n) (hOdd : n % 2 = 1) :
    logPotential (collatz n) ≤ logPotential n + Real.log 3 + Real.log (1 + 1 / (3 * (n : ℝ))) := by
  ...
```

or with a simpler coarse bound:

```lean
theorem collatz_log_odd_upper_coarse
    {n : ℕ} (hn : 1 ≤ n) (hOdd : n % 2 = 1) :
    logPotential (collatz n) ≤ logPotential n + Real.log 4 := by
  ...
```

This theorem is the tropical doorway: the update becomes a piecewise affine inequality in `logPotential`.

---

### 3. Strict contraction for the accelerated odd map beyond a threshold

This is likely the first truly nontrivial theorem you can actually prove cleanly.

For odd `n`, define `T(n) = (3n+1)/2^k` where `k ≥ 1` is the full 2-adic valuation of `3n+1`. Show that if `k ≥ 2`, then in logarithmic coordinates the map contracts:
\[
\log T(n) \le \log n + \log(3/4 + 1/(4n)).
\]
Hence for sufficiently large `n`, strict decrease occurs.

Suggested theorem:

```lean
theorem accelerated_collatz_log_contracts_of_two_adic_ge_two
    {n k : ℕ} (hn : 1 ≤ n) (hk : 2 ≤ k)
    (hdiv : collatzOdd n = (3 * n + 1) / 2 ^ k) :
    logPotential ((3 * n + 1) / 2 ^ k) < logPotential n + Real.log (3 / 4 + 1 / (4 * (n : ℝ))) := by
  ...
```

A more practical theorem is arithmetic, avoiding exact valuation machinery:

```lean
theorem odd_branch_contracts_if_extra_division
    {n : ℕ} (hn : 1 ≤ n)
    (h : 4 ∣ (3 * n + 1)) :
    ((3 * n + 1) / 4 : ℕ) < n := by
  ...
```

This theorem is deceptively powerful: it isolates a **uniform arithmetic contraction regime**. It is a genuine formal foothold.

---

### 4. A conditional contraction-implies-Collatz theorem

This is the real architectural theorem. Do not hide the conditional nature; make it explicit and strong.

Let `Φ : ℕ → ℝ` and suppose there exist constants `c < 1`, `b`, and `N` such that for all `n ≥ N`,
\[
Φ(T(n)) \le c \, Φ(n) + b
\]
for a suitable accelerated Collatz operator `T`, and that every orbit enters the contracting region. Then every orbit converges to the unique finite attractor, and if `1` is the unique fixed point, global convergence follows.

Lean-style statement:

```lean
theorem collatz_convergence_of_eventual_log_contraction
    (T : ℕ → ℕ)
    (Φ : ℕ → ℝ)
    (hFixed : T 1 = 1)
    (hContract :
      ∃ N c b, N ≥ 1 ∧ c < 1 ∧
        ∀ ⦃n : ℕ⦄, N ≤ n → Φ (T n) ≤ c * Φ n + b)
    (hEntry :
      ∀ n : ℕ, ∃ m : ℕ, N ≤ Nat.iterate T m n)
    (hFiniteTrap :
      ∃ S : Finset ℕ, 1 ∈ S ∧ ∀ n ∈ S, T n ∈ S) :
    ∀ n : ℕ, ∃ m : ℕ, Nat.iterate T m n = 1 := by
  ...
```

You may need to reformulate `hEntry` and `hFiniteTrap` to something easier to use. The point is to package the reduction from arithmetic dynamics to contraction/fixed-point theory.

This is exactly where you should build on:
- `contraction_fixed_point_unique`
- `convergence_to_unique_fixed_point`
- `spectral_fixed_point`
- `exists_fixed_point_on_orbit_with_bound`

Use them as abstract engines after constructing the right metric/dynamical object.

---

### 5. Tropical envelope theorem

Define a tropical upper envelope `E : ℝ → ℝ` for the logarithmic Collatz dynamics, e.g.
\[
E(x) = \min(x-\log 2,\; x+\log 3)
\]
or more realistically a branch-dependent affine family. Then prove the actual update is bounded by this envelope, and prove contraction for an iterate or averaged envelope.

Suggested theorem:

```lean
def collatzEnvelope (x : ℝ) : ℝ :=
  min (x - Real.log 2) (x + Real.log 3)

theorem collatz_log_bounded_by_envelope
    {n : ℕ} (hn : 1 ≤ n) :
    logPotential (collatz n) ≤ collatzEnvelope (logPotential n) + Real.log 2 := by
  ...
```

Then seek an iterate `E^[k]` that becomes contracting on a half-line. This is where “tropical spectral radius” should be interpreted rigorously: not as rhetoric, but as the asymptotic slope of the piecewise-affine majorant.

---

## Lean 4 Type Signatures to Target

Use these or nearby variants.

```lean
def collatz : ℕ → ℕ
def collatzOdd : ℕ → ℕ
def logPotential : ℕ → ℝ
def collatzEnvelope : ℝ → ℝ
```

```lean
theorem collatz_one_fixed : collatz 1 = 1 := by
  ...
```

```lean
theorem collatz_log_even
    {n : ℕ} (hn : 1 ≤ n) (hEven : n % 2 = 0) :
    logPotential (collatz n) = logPotential n - Real.log 2 := by
  ...
```

```lean
theorem collatz_log_odd_upper_coarse
    {n : ℕ} (hn : 1 ≤ n) (hOdd : n % 2 = 1) :
    logPotential (collatz n) ≤ logPotential n + Real.log 4 := by
  ...
```

```lean
theorem odd_branch_contracts_if_four_dvd
    {n : ℕ} (hn : 1 ≤ n) (h4 : 4 ∣ (3 * n + 1)) :
    ((3 * n + 1) / 4 : ℕ) < n := by
  ...
```

```lean
theorem accelerated_collatz_eventual_descent
    ∀ᶠ n in Filter.atTop,
      collatzOdd n < n := by
  ...
```

If `Filter.atTop` is too ambitious, use:
```lean
theorem accelerated_collatz_descent_above_threshold
    ∃ N : ℕ, ∀ ⦃n : ℕ⦄, N ≤ n → 4 ∣ (3 * n + 1) → ((3 * n + 1) / 4 : ℕ) < n := by
  ...
```

```lean
theorem unique_fixed_point_of_contracting_collatz_model
    {X : Type*} [MetricSpace X] (T : X → X)
    (hcontract : ContractingWith K T) (hK : K < 1) (h1 : T x₀ = x₀) :
    ∀ y, T y = y → y = x₀ := by
  simpa using contraction_fixed_point_unique ...
```

```lean
theorem collatz_convergence_of_tropical_contracting_model
    ... :
    ∀ n : ℕ, ∃ m : ℕ, Nat.iterate collatz m n = 1 := by
  ...
```

The final theorem should be conditional unless you truly discharge every hypothesis.

---

## Proof Strategy Paths

### Strategy A: Honest arithmetic-to-logarithmic reduction
Most promising for immediate progress.

1. Prove exact even-branch logarithmic identity and coarse odd-branch upper bounds.
2. Isolate arithmetic subregimes where the odd branch is strictly decreasing after extra 2-adic division (`4 ∣ 3n+1`, stronger if `8 ∣ 3n+1`, etc.).
3. Build an accelerated map on odd numbers and prove eventual descent on explicit congruence classes.
4. Package these as a piecewise tropical majorant and derive conditional convergence via fixed-point machinery.

Why promising:
- uses only elementary arithmetic, inequalities, and `Real.log`,
- formalizable in Lean with moderate effort,
- produces genuine theorems even if full Collatz remains open.

---

### Strategy B: Symbolic dynamics + tropical cocycle
Higher risk, higher conceptual payoff.

1. Encode parity patterns as words in `{E,O}` and associate to each word an affine cocycle on `logPotential`.
2. Show the cocycle has average drift determined by a tropical/spectral slope:
   \[
   x \mapsto x + a_w
   \]
   where `a_w` depends on counts of even and odd steps.
3. Prove that words with sufficiently many even steps have negative drift, giving a contractive semigroup on a subshift.
4. Formalize a theorem: any orbit whose symbolic itinerary satisfies a density-of-even-steps bound converges to `1`.

Why important:
- transforms Collatz into a semigroup/spectral problem,
- connects directly to `spectral_fixed_point`,
- opens a route to entropy and thermodynamic formalism.

---

### Strategy C: Renormalization / finite-state quotient dynamics
Most cross-domain and potentially field-opening.

1. Study Collatz modulo powers of 2 and 3; define a finite-state automaton controlling branch contraction data.
2. Construct a weighted potential `Φ(n) = log n + ψ(n mod M)` where `ψ` is a correction term.
3. Search for `ψ` and `c < 1` such that the accelerated operator satisfies a Bellman-type contraction inequality.
4. Formalize the existence of a finite correction function as a linear or tropical feasibility problem.

Why revolutionary:
- recasts Collatz as a finite-state control problem,
- links arithmetic dynamics to dynamic programming and tropical optimization,
- potentially gives computable certificates of contraction.

This is the most science-fiction path and should be attempted if arithmetic lemmas stabilize.

---

## How to Build on the Catalog Theorems

### `contraction_fixed_point_unique`
Use this after constructing an actual metric-space model:
- either on a finite quotient / finite-state corrected potential space,
- or on a complete metric space of potentials / cocycles / orbit summaries.

Do **not** force ℕ with the usual metric unless you genuinely prove contraction there. Instead, build a transformed space where contraction is true.

### `spectral_fixed_point`
Interpret the Collatz tropical envelope or symbolic cocycle as a spectral operator. Use this to derive:
- existence of a fixed point of the envelope,
- or asymptotic contraction from spectral radius bounds,
- or a fixed potential correction term `ψ`.

### `convergence_to_unique_fixed_point`
This should be the endpoint theorem once a contracting model is defined. Your job is to instantiate its hypotheses with a nontrivial Collatz-derived operator.

### `tropical_and_bound`
Use this as a bridge lemma when combining branchwise tropical inequalities. If it gives lower/upper bounds in min-plus style, leverage it to assemble the piecewise envelope estimate.

### `exists_fixed_point_on_orbit_with_bound`
Potentially useful for finite trap regions or bounded orbit arguments:
- show that once an orbit enters a bounded region under a contractive potential, a fixed point must occur on the orbit or in its closure,
- then identify that fixed point with `1`.

---

## Cross-Domain Connections You Must Exploit

### Tropical geometry
The branchwise update in logarithmic coordinates is a piecewise-affine tropical object. Even if not exactly min-plus linear, it admits a tropical envelope. This creates a new formal language for arithmetic iteration.

### 2-adic / non-Archimedean dynamics
The acceleration step is fundamentally valuation-theoretic. The number of divisions by 2 is a 2-adic valuation, and the odd-step dynamics is controlled by valuation growth. This is a deep bridge between tropical and p-adic viewpoints.

### Symbolic dynamics and entropy
Parity sequences form a shift space. Drift of the logarithmic potential along symbolic words suggests a thermodynamic formalism: pressure, drift, and entropy of branch itineraries.

### Control theory / dynamic programming
A corrected potential `Φ(n) = log n + ψ(n mod M)` is a Lyapunov function with finite-state control corrections. This is Bellman inequality territory and may connect directly to tropical optimization.

### Computational complexity / formal verification
A finite certificate of contraction on residue classes would turn parts of Collatz into machine-checkable proof objects. This is exactly the kind of theorem Lean can certify and humans can trust.

---

## Application Keywords

Collatz conjecture, tropical dynamics, min-plus algebra, idempotent analysis, spectral radius, fixed-point theorem, arithmetic dynamics, 2-adic valuation, symbolic dynamics, Lyapunov function, Bellman inequality, renormalization, finite-state automata, formal verification, Lean 4, Mathlib, tropical envelope, contraction mapping, orbit descent, non-Archimedean dynamics.

---

## Deliverables

1. **Lean 4 code** proving as many of the theorem targets above as possible.
2. Definitions for Collatz, accelerated Collatz, and one tropical/logarithmic potential.
3. At least one nontrivial proved theorem showing:
   - exact branchwise logarithmic behavior,
   - or strict arithmetic descent in a valuation-controlled regime,
   - or a conditional contraction-implies-convergence theorem.
4. A clean separation between:
   - unconditional theorems,
   - conditional reduction theorems,
   - conjectural next-step statements.
5. **FUTURE_DIRECTIONS.md** with 3–5 concrete breakthrough next steps.

---

## Required FUTURE_DIRECTIONS.md

You must produce `FUTURE_DIRECTIONS.md` containing 3–5 specific next projects at breakthrough level, for example:

1. **Finite-state Lyapunov synthesis for Collatz modulo `2^k 3^m`**  
   Search for a correction potential `ψ : ZMod M → ℝ` making the accelerated Collatz operator a strict contraction in `log n + ψ(n mod M)`.

2. **Tropical pressure of parity subshifts**  
   Define and formalize pressure/drift for parity words and prove that negative tropical pressure implies orbit descent.

3. **p-adic/tropical duality for arithmetic maps**  
   Generalize the Collatz envelope construction to maps of the form `n ↦ (an+b)/p^ν` and classify when accelerated dynamics is contractive.

4. **Certified computational proof objects for bounded residue classes**  
   Build machine-checkable certificates showing contraction on all states modulo large powers of 2 and 3.

5. **Renormalization category of arithmetic dynamical systems**  
   Formalize a category whose morphisms preserve tropical Lyapunov functions and prove Collatz-type maps fit into it.

---

## Team Directive

Create a research team internally with roles:

- **Arithmetic Dynamics Lead**: prove descent lemmas on congruence classes.
- **Tropical Analyst**: define the envelope and spectral radius framework.
- **Lean Formalization Engineer**: optimize definitions to avoid sorry-heavy valuation machinery.
- **Symbolic Dynamics Researcher**: model parity sequences and drift.
- **Verification/Experiment Lead**: compute candidate correction potentials and test conjectures before formal proof.

Iterate forever:
- conjecture,
- test on explicit finite data,
- extract formal statements,
- prove the strongest honest theorem,
- update the knowledge base.

---

## Nonnegotiable Standard of Rigor

Do **not** state “Collatz is a contraction” on the standard metric over ℕ unless you prove it. It is almost certainly false in that naive form. Instead, win by precision:

- prove exact identities where exactness is available,
- prove upper envelopes where only inequalities are true,
- prove strict contraction for accelerated or corrected models,
- and isolate the exact missing hypothesis needed for global convergence.

That precision is the breakthrough.

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
