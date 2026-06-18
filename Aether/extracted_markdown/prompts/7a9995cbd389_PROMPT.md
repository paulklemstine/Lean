## Assignment: Amortized Complexity via Tropical Amortization

Mode: **prove**

Aristotle, this is not a cosmetic reinterpretation of amortized analysis. The target is to **rebuild the logic of data-structure complexity inside the tropical semiring**, so that amortized bounds become algebraic invariants in min-plus geometry. If you succeed, you open a bridge between:

- amortized complexity,
- shortest-path / dynamic programming algebra,
- idempotent semiring methods,
- tropical convexity,
- and formal resource verification.

The breakthrough is to show that the classical potential/accounting methods are not merely analogous to tropical reasoning: they **are tropical linear inequalities** over operation sequences.

You should aim for a formal development that makes future mechanized amortized analysis of algorithms look like semiring algebra rather than ad hoc combinatorics.

---

### Core Definitions to Introduce

Work with concrete types first, preferably `ℕ` for exact discrete costs and `ℝ` for analytic variants.

Suggested file-local definitions:

```lean
def tropAdd (a b : ℕ) : ℕ := min a b
def tropMul (a b : ℕ) : ℕ := a + b

def seqCost (c : ℕ → ℕ) (n : ℕ) : ℕ :=
  ∑ i in Finset.range n, c i

def amortizedCost (c Φ : ℕ → ℕ) (n : ℕ) : ℕ :=
  c n + Φ (n+1) - Φ n

def prefixAmortizedCost (c Φ : ℕ → ℕ) (n : ℕ) : ℤ :=
  ∑ i in Finset.range n, ((c i : ℤ) + Φ (i+1) - Φ i)

def tropicalConv (f g : ℕ → ℕ) (n : ℕ) : ℕ :=
  Finset.inf' (Finset.range (n+1)).toFinset
    (by simp)
    (fun k => f k + g (n-k))
```

For `ℕ`, subtraction is awkward for potentials, so the most robust formalization may use:
- state potential `Φ : ℕ → ℤ`, actual costs `c : ℕ → ℤ`, or
- inequalities in `ℕ` phrased without subtraction:
  `c i ≤ a i + Φ i - Φ (i+1)` rewritten as `c i + Φ (i+1) ≤ a i + Φ i`.

That second formulation is likely best for theorem statements that stay close to order-theoretic tropical algebra.

---

## Precise Theorem Targets

### Theorem 1: Potential method telescopes exactly

This is the foundational bridge theorem. It certifies that the potential method is a tropical linear certificate for sequence bounds.

**Mathematical statement.**  
Let `c : ℕ → ℤ` be actual operation costs, `a : ℕ → ℤ` amortized charges, and `Φ : ℕ → ℤ` a potential. Assume for every step `i`,
\[
c(i) + \Phi(i+1) - \Phi(i) \le a(i).
\]
Then for every `n`,
\[
\sum_{i < n} c(i) \le \sum_{i < n} a(i) + \Phi(0) - \Phi(n).
\]
In particular, if `Φ(0) = 0` and `0 ≤ Φ(n)` for all `n`, then
\[
\sum_{i < n} c(i) \le \sum_{i < n} a(i).
\]

**Lean 4 target signature.**
```lean
theorem potential_method_telescoping
    (c a Φ : ℕ → ℤ)
    (hstep : ∀ i, c i + Φ (i+1) - Φ i ≤ a i) :
    ∀ n,
      (∑ i in Finset.range n, c i)
        ≤
      (∑ i in Finset.range n, a i) + Φ 0 - Φ n
```

And the corollary:

```lean
theorem potential_method_amortized_bound
    (c a Φ : ℕ → ℤ)
    (hstep : ∀ i, c i + Φ (i+1) - Φ i ≤ a i)
    (hinit : Φ 0 = 0)
    (hnonneg : ∀ n, 0 ≤ Φ n) :
    ∀ n, (∑ i in Finset.range n, c i) ≤ ∑ i in Finset.range n, a i
```

**Why this matters.**  
This turns the potential method into a reusable algebraic certificate. Once formalized, every amortized proof in verified algorithms can reduce to producing a tropical potential satisfying local inequalities.

---

### Theorem 2: Accounting method is equivalent to nonnegative tropical potential

This is the conceptual theorem: accounting and potential are the same object seen from two coordinate systems.

**Mathematical statement.**  
Let `c a : ℕ → ℤ`. The following are equivalent:

1. There exists `Φ : ℕ → ℤ` with `Φ 0 = 0`, `0 ≤ Φ n` for all `n`, and
   \[
   c(i) + \Phi(i+1) - \Phi(i) \le a(i)
   \quad \forall i.
   \]

2. For every `n`,
   \[
   \sum_{i<n} c(i) \le \sum_{i<n} a(i).
   \]

A canonical witness is
\[
\Phi(n) := \sum_{i<n} a(i) - \sum_{i<n} c(i).
\]

**Lean 4 target signature.**
```lean
theorem accounting_potential_equiv
    (c a : ℕ → ℤ) :
    ((∃ Φ : ℕ → ℤ,
        Φ 0 = 0 ∧
        (∀ n, 0 ≤ Φ n) ∧
        (∀ i, c i + Φ (i+1) - Φ i ≤ a i)))
    ↔
    (∀ n, (∑ i in Finset.range n, c i) ≤ ∑ i in Finset.range n, a i)
```

A stronger constructive version is even better:

```lean
def accountingPotential (c a : ℕ → ℤ) (n : ℕ) : ℤ :=
  (∑ i in Finset.range n, a i) - (∑ i in Finset.range n, c i)

theorem accountingPotential_spec
    (c a : ℕ → ℤ)
    (hprefix : ∀ n, (∑ i in Finset.range n, c i) ≤ ∑ i in Finset.range n, a i) :
    let Φ := accountingPotential c a
    Φ 0 = 0 ∧
    (∀ n, 0 ≤ Φ n) ∧
    (∀ i, c i + Φ (i+1) - Φ i = a i)
```

**Why this is a breakthrough.**  
This proves that amortized complexity admits a **duality theorem**: global prefix domination is equivalent to existence of a local potential certificate. That is the exact form one wants for automation, synthesis, and eventually optimization of amortized proofs.

---

### Theorem 3: Min-plus convolution gives optimal sequential amortized schedule

This is the genuinely tropical theorem. It pushes beyond telescoping into sequence optimization.

Let `f n` be the least cost to process a prefix of length `n` by one strategy, and `g n` the least cost by another strategy or deferred restructuring phase. Then the cost of combining them over a split point is min-plus convolution:
\[
(f \star_{\min,+} g)(n) = \min_{0 \le k \le n} (f(k) + g(n-k)).
\]

You should prove a dynamic-programming optimality theorem showing that this convolution computes the optimal amortized bound under compositional splitting.

**Mathematical statement.**  
For any `f g : ℕ → ℕ` and `n : ℕ`,
\[
(\mathrm{tropicalConv}\ f\ g)(n)
=
\min_{0\le k\le n}(f(k)+g(n-k)),
\]
and if `h n` is any function satisfying
\[
h(n) \le f(k)+g(n-k) \quad \forall k \le n,
\]
then
\[
h(n) \le (\mathrm{tropicalConv}\ f\ g)(n).
\]

More ambitiously, define a recursively specified sequence cost and prove it equals an iterated tropical convolution.

**Lean 4 target signature.**
```lean
theorem tropicalConv_le_split
    (f g : ℕ → ℕ) (n k : ℕ) (hk : k ≤ n) :
    tropicalConv f g n ≤ f k + g (n-k)

theorem le_tropicalConv_of_le_all_splits
    (f g h : ℕ → ℕ)
    (hh : ∀ n k, k ≤ n → h n ≤ f k + g (n-k)) :
    ∀ n, h n ≤ tropicalConv f g n
```

If `Finset.inf'` becomes unpleasant over `ℕ`, define a bounded minimum via `Finset.min'` on the image set:
```lean
def tropicalConv' (f g : ℕ → ℕ) (n : ℕ) : ℕ :=
  ((Finset.range (n+1)).image (fun k => f k + g (n-k))).min' (by ...)
```

**Why this matters.**  
This theorem says amortized complexity composition is not just additive; it is a **tropical optimizer**. That is the bridge to shortest paths, Bellman equations, parsing, scheduling, and semiring program analysis.

---

## Proof Strategy Architecture

### Strategy A: Telescoping-first, then derive tropical interpretation
Most promising for a clean Lean development.

1. Prove finite telescoping identities for `∑ (Φ (i+1) - Φ i)`.
   - Use `Finset.range` induction.
   - Isolate a lemma:
     ```lean
     theorem sum_range_telescoping
         (Φ : ℕ → ℤ) :
         ∀ n, ∑ i in Finset.range n, (Φ (i+1) - Φ i) = Φ n - Φ 0
     ```
2. Add the stepwise inequalities and combine with the telescoping identity.
3. Define the accounting potential from prefix sums and show it satisfies the local equality exactly.
4. Only after the classical theorem is stable, package the min-plus convolution definitions and prove order-theoretic lemmas.

**Why this is best:** Lean handles finite sum algebra and induction reliably; once the telescoping core is done, the rest is nearly categorical.

---

### Strategy B: Prefix-sum duality as a Galois-style equivalence
This is more conceptual and could become the centerpiece theorem.

1. Define the prefix slack:
   \[
   \Phi(n) := A(n) - C(n),
   \quad A(n)=\sum_{i<n} a(i),\ C(n)=\sum_{i<n} c(i).
   \]
2. Show:
   - `Φ 0 = 0`,
   - `Φ n ≥ 0` iff prefix domination holds,
   - `Φ (i+1) - Φ i = a(i) - c(i)`.
3. Conclude equivalence between global accounting and local potential.
4. Reinterpret `Φ` as tropical stored credit, i.e. an idempotent semiring valuation on prefixes.

**Why this is powerful:** It gives a duality theorem rather than a one-way bound, and sets up later automation by witness synthesis.

---

### Strategy C: Dynamic programming / semiring route for convolution
Use this for the field-opening tropical part.

1. Define bounded min-plus convolution on `ℕ → ℕ`.
2. Prove basic universal properties:
   - lower than every split cost,
   - greatest lower bound among such bounds.
3. Show associativity if feasible:
   ```lean
   theorem tropicalConv_assoc
       (f g h : ℕ → ℕ) :
       tropicalConv (tropicalConv f g) h = tropicalConv f (tropicalConv g h)
   ```
   extensional equality over `n`.
4. Interpret this as compositional amortized scheduling.

**Why this matters:** Associativity would be a major conceptual upgrade: amortized composition becomes a semiring-level algebra of algorithmic phases.

---

## Catalog Building Blocks to Use

The repeated theorem
```lean
tropical_plus_distributes_over_min
```
from the listed files should be used as the algebraic signal that existing infrastructure already understands the min-plus viewpoint. Even if your main proofs are over `Finset` and order lemmas, explicitly connect your convolution algebra to this theorem:

- use it to rewrite expressions of the form
  `a + min b c = min (a+b) (a+c)`,
- show that local tropical combination distributes over split minimization,
- motivate semiring composition laws for amortized bounds.

The theorem
```lean
tropical_and_bound
```
may also support lower-bound style reasoning where two independent tropical constraints combine into a stronger certificate.

Do not merely cite these results; use them to justify that your amortized inequalities live naturally in the same algebraic universe as the verified tropical library.

---

## Cross-Domain Connections You Must Exploit

### 1. Dynamic programming and shortest paths
Min-plus convolution is the algebra of shortest paths. Your theorem says amortized complexity certificates can be composed exactly like path costs in weighted graphs. This suggests:

- amortized analysis as path optimization in a state graph,
- automatic synthesis of potentials via shortest-path algorithms,
- verified resource analysis by semiring closure.

### 2. Idempotent analysis / tropical geometry
Potential functions become tropical affine functions on execution prefixes. Prefix-cost envelopes resemble tropical convex hulls. This is the seed of a new subject: **tropical complexity geometry**.

### 3. Formal verification and program logics
A local inequality
\[
c(i) + \Phi(i+1) - \Phi(i) \le a(i)
\]
is a Hoare-style resource invariant. Your theorem converts local proof obligations into global complexity guarantees. This could feed directly into:
- verified data structures,
- certified compilers,
- cost-aware separation logic.

### 4. Online algorithms and control
Potential is stored energy; amortized charging is a dissipative inequality. There is a control-theoretic analogy with Lyapunov functions:
- local drift inequality,
- global stability / bounded cumulative cost,
- synthesis of potentials by optimization.

If possible, mention that this is a discrete idempotent analogue of Lyapunov analysis.

---

## Concrete Lean Lemmas Worth Proving En Route

These are highly reusable and likely necessary:

```lean
theorem sum_range_sub_eq
    (f g : ℕ → ℤ) (n : ℕ) :
    (∑ i in Finset.range n, (f i - g i))
      =
    (∑ i in Finset.range n, f i) - (∑ i in Finset.range n, g i)
```

```lean
theorem sum_range_succ_shift
    (Φ : ℕ → ℤ) (n : ℕ) :
    (∑ i in Finset.range n, Φ (i+1))
      =
    (∑ i in Finset.range (n+1), Φ i) - Φ 0
```

```lean
theorem sum_range_telescoping
    (Φ : ℕ → ℤ) (n : ℕ) :
    ∑ i in Finset.range n, (Φ (i+1) - Φ i) = Φ n - Φ 0
```

```lean
theorem accountingPotential_zero
    (c a : ℕ → ℤ) :
    accountingPotential c a 0 = 0
```

```lean
theorem accountingPotential_step
    (c a : ℕ → ℤ) (i : ℕ) :
    accountingPotential c a (i+1) - accountingPotential c a i = a i - c i
```

These lemmas will make the final theorems short, canonical, and reusable.

---

## Stretch Theorem: Associativity of bounded tropical convolution

If the basic development succeeds, push for:

```lean
theorem tropicalConv_assoc
    (f g h : ℕ → ℕ) :
    ∀ n, tropicalConv (tropicalConv f g) h n = tropicalConv f (tropicalConv g h) n
```

This is not trivial because bounded splits must be managed carefully. But if proved, it upgrades the project from “amortized analysis reformulated tropically” to “amortized complexity forms a compositional min-plus algebra.”

That would be a field-opening theorem.

---

## Revolutionary Significance

If you deliver these theorems, you create a new formal language for complexity proofs:

- **Potential functions become tropical certificates.**
- **Accounting becomes prefix domination in an idempotent semiring.**
- **Compositional amortized bounds become min-plus convolutions.**

This opens at least four research programs:

1. **Automated amortized analysis by semiring optimization**  
   Synthesize potentials algorithmically.

2. **Verified resource logics with tropical semantics**  
   Integrate with Hoare logic and program verification.

3. **Tropical complexity theory**  
   Study complexity classes and invariants via idempotent algebra.

4. **Bridges to control, scheduling, and online algorithms**  
   Reuse Lyapunov and dynamic-programming ideas in formal complexity proofs.

This is exactly the kind of bridge theorem that can seed an entire library and change how complexity arguments are mechanized.

---

## Deliverables

1. Lean 4 code formalizing the main definitions and at least Theorem 1 and Theorem 2.
2. Preferably one nontrivial tropical convolution theorem from Theorem 3.
3. Minimize `sorry`; if blocked, isolate the bottleneck into explicit helper lemmas.
4. Use concrete examples if possible:
   - constant amortized charge over a variable-cost sequence,
   - a toy dynamic array / stack-style prefix model,
   - a split-cost optimization example showing convolution.

---

## Application Keywords

tropical algebra, min-plus convolution, amortized complexity, potential method, accounting method, idempotent semiring, dynamic programming, shortest paths, Lyapunov functions, resource verification, Hoare logic, formal methods, algorithmic game theory, online algorithms, tropical convexity

---

## Required Final Artifact

Produce a structured `FUTURE_DIRECTIONS.md` with **3–5 concrete breakthrough next steps**, for example:

- synthesis of optimal potentials by linear/tropical optimization,
- associativity and semiring laws for amortized composition,
- verified amortized bounds for concrete data structures,
- tropical Hoare logic for resource invariants,
- shortest-path algorithms that automatically derive amortized proofs.

Make these specific, formalization-ready, and ambitious.

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
