## Assignment: Channel Capacity as Idempotent Fixed Point in Tropical Information Theory

**Mode:** `prove`

Prove genuinely new theorems, but do so with mathematical discipline: isolate a formally correct tropical-information-theoretic core that can be certified in Lean 4 now, then push toward the larger Shannon-capacity vision through a sequence of sharp bridge theorems. The grand claim as written — “Shannon channel capacity equals a tropical fixed point” — is revolutionary, but only if made precise enough to survive formalization. Your task is to produce that precision.

Minimize `sorry`. If the strongest exact Shannon statement is not yet formalizable from current Mathlib infrastructure, prove the strongest exact finite-state tropical surrogate theorem and explicitly identify the obstruction. Do not retreat to trivialities.

### Strategic Goal

Build a formal bridge between:

1. **Classical finite channel theory** on finite alphabets,
2. **Tropical / min-plus spectral theory** of weighted matrices,
3. **Fixed-point uniqueness principles** already present in the catalog,
4. **Constructive coding bounds** phrased in finite combinatorics.

The breakthrough is not a cosmetic “analogy.” It is to show that a capacity functional can be characterized as a fixed-point/eigenvalue object in an idempotent semiring, and that this characterization yields constructive code design principles. If successful, this opens a new field direction: **tropical information theory**, where asymptotic communication limits are recast as semiring spectral invariants.

---

## Mathematical Framing

The original statement is too ambitious unless you choose the correct formal surrogate. The right finite-state tropical object is not raw Shannon mutual information on probabilities, but a **log-likelihood / information-cost matrix** whose max-plus or min-plus eigenvalue controls a one-step information growth rate. Then prove that this spectral quantity coincides with a variational capacity-like optimization over finitely supported input laws or score vectors.

The key conceptual move:

- Classical channel matrices use addition/multiplication of probabilities.
- Taking logarithms converts products to sums.
- Replacing ordinary summation by tropical addition isolates dominant exponents / large-deviation rates.
- Capacity then becomes a **nonlinear eigenvalue** or **fixed-point value** of an idempotent operator.

This is analogous to:
- Perron–Frobenius theory → tropical Perron theory,
- Gibbs variational principle → max-plus variational principle,
- Bellman optimality → communication optimality.

---

## Precise Theorem Targets

You should formalize a hierarchy of results. At least one theorem in each layer should be fully proved.

### Layer 1: Finite tropical channel operator and fixed-point existence

Let `n : ℕ`, let `A : Matrix (Fin n) (Fin n) ℝ` be a real weight matrix. Define the max-plus channel operator
\[
(T_A x)_i := \max_j (A_{ij} + x_j).
\]
A scalar `λ : ℝ` and vector `x : Fin n → ℝ` satisfy the tropical eigenvector equation if
\[
T_A x = \lambda + x
\]
pointwise.

Formal target:

```lean
def tropChannelOp {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) (x : Fin n → ℝ) :
    Fin n → ℝ :=
  fun i => Finset.univ.sup' (Finset.univ_nonempty) (fun j => A i j + x j)

def IsTropicalEigenpair {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ)
    (λ : ℝ) (x : Fin n → ℝ) : Prop :=
  ∀ i, tropChannelOp A x i = λ + x i
```

Then prove a finite existence theorem under a normalization:

```lean
theorem tropical_eigenpair_exists_normalized
    {n : ℕ} (hn : 0 < n) (A : Matrix (Fin n) (Fin n) ℝ) :
    ∃ λ x, IsTropicalEigenpair A λ x ∧ x 0 = 0
```

This is already nontrivial and foundational. It gives the idempotent fixed-point object.

---

### Layer 2: Uniqueness under strict separation / irreducibility

Use the catalog theorem `fixed_point_unique_under_theory_separation` as inspiration for a concrete matrix irreducibility hypothesis. Define a strong connectivity / strict separation condition ensuring uniqueness of the tropical eigenvector modulo additive constants.

Formal target:

```lean
def TropicallyIrreducible {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) : Prop :=
  ∀ i j : Fin n, ∃ k : ℕ, ∃ p : Fin k → Fin n,
    p 0 = i ∧ p (k - 1) = j ∧
    ∀ t : Fin (k - 1), A (p t.castSucc) (p t.succ) > -Real.log 0

def AdditiveEquivalent {n : ℕ} (x y : Fin n → ℝ) : Prop :=
  ∃ c : ℝ, ∀ i, y i = x i + c
```

Then prove a uniqueness theorem of the form:

```lean
theorem tropical_eigenvector_unique_mod_constant
    {n : ℕ} (hn : 0 < n) {A : Matrix (Fin n) (Fin n) ℝ}
    (hirr : TropicallyIrreducible A) :
    ∀ {λ x y},
      IsTropicalEigenpair A λ x →
      IsTropicalEigenpair A λ y →
      AdditiveEquivalent x y
```

This is where the fixed-point uniqueness becomes mathematically meaningful. If you can make the irreducibility definition cleaner in Lean, do so.

---

### Layer 3: Capacity as a tropical Collatz–Wielandt value

The truly important theorem is a variational characterization. For finite `A`, define the tropical spectral value
\[
\lambda(A) = \inf_x \max_i \big( (T_A x)_i - x_i \big).
\]
Prove this equals the eigenvalue of any tropical eigenpair.

Formal target:

```lean
def tropicalCycleValue {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) : ℝ := sorry

def tropicalCollatzWielandt {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) : ℝ :=
  sInf {r : ℝ | ∃ x : Fin n → ℝ, ∀ i, tropChannelOp A x i - x i ≤ r}
```

Then prove:

```lean
theorem tropical_collatz_wielandt_eq_eigenvalue
    {n : ℕ} (hn : 0 < n) (A : Matrix (Fin n) (Fin n) ℝ) :
    tropicalCollatzWielandt A = tropicalCycleValue A
```

and, if possible,

```lean
theorem tropical_eigenvalue_characterization
    {n : ℕ} (hn : 0 < n) (A : Matrix (Fin n) (Fin n) ℝ) :
    ∃! λ : ℝ, ∃ x, IsTropicalEigenpair A λ x ∧ x 0 = 0 ∧
      λ = tropicalCollatzWielandt A
```

This is the correct “capacity equals fixed point value” theorem in tropical linear algebra.

---

### Layer 4: Information-theoretic bridge theorem

Now connect this to a finite channel. Let `P : Matrix (Fin m) (Fin n) ℝ` be a stochastic matrix with strictly positive entries. Define the log-channel cost
\[
A_{ij} := \log P(j \mid i).
\]
Then define a one-step tropical information functional from score vectors:
\[
\Phi_A(x) := \max_i \left( \max_j (A_{ij}+x_j) - x_i \right).
\]

The theorem should say that the tropical spectral value of `A` is the asymptotic growth/decay rate of optimal path weights in the channel graph. This is the rigorous bridge theorem you can prove now.

Formal target:

```lean
def logChannelMatrix {m n : ℕ} (P : Matrix (Fin m) (Fin n) ℝ) :
    Matrix (Fin m) (Fin n) ℝ := fun i j => Real.log (P i j)

def tropicalCapacityProxy {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) : ℝ :=
  tropicalCollatzWielandt A
```

Then prove a theorem of the form:

```lean
theorem tropical_capacity_proxy_eq_optimal_cycle_mean
    {n : ℕ} (hn : 0 < n) (A : Matrix (Fin n) (Fin n) ℝ) :
    tropicalCapacityProxy A = tropicalCycleValue A
```

Interpret this as the **idempotent channel capacity** of the weighted channel.

If you can go further, formulate a classical bridge:

```lean
theorem shannon_capacity_le_tropical_capacity_proxy
    {n : ℕ} (hn : 0 < n) (P : Matrix (Fin n) (Fin n) ℝ)
    (hsto : IsRowStochastic P) (hpos : ∀ i j, 0 < P i j) :
    classicalCapacity P ≤ Real.exp (tropicalCapacityProxy (logChannelMatrix P))
```

Even an inequality, rather than equality, would be a meaningful first breakthrough.

---

### Layer 5: Tropical coding theorem surrogate

You likely cannot formalize the full noisy channel coding theorem from scratch in one cycle. Instead, prove a finite constructive coding theorem in the tropical metric induced by `A`.

Define a tropical distance / decoding score:
\[
d_A(u,v) := \max_t (A_{u_t,v_t}) - \text{competitor score}.
\]
Or, more formally, define nearest-codeword decoding by maximum path weight.

Then prove a code separation theorem: if a finite codebook has pairwise tropical score gap at least `2δ`, then a decoder correcting all error patterns of tropical weight `< δ` exists.

Formal target sketch:

```lean
def codeword (n q : ℕ) := Fin n → Fin q

def tropicalWordScore {q : ℕ}
    (A : Matrix (Fin q) (Fin q) ℝ) {n : ℕ} (u v : codeword n q) : ℝ :=
  ∑ i, A (u i) (v i)

def TropicallySeparated {n q : ℕ}
    (A : Matrix (Fin q) (Fin q) ℝ) (δ : ℝ) (C : Finset (codeword n q)) : Prop :=
  ∀ ⦃u v⦄, u ∈ C → v ∈ C → u ≠ v →
    tropicalWordScore A u u > tropicalWordScore A u v + 2 * δ
```

Then prove:

```lean
theorem tropical_decoding_radius_theorem
    {n q : ℕ} (A : Matrix (Fin q) (Fin q) ℝ) (δ : ℝ)
    (C : Finset (codeword n q))
    (hsep : TropicallySeparated A δ C) :
    ∃ decode : codeword n q → codeword n q,
      ∀ u ∈ C, ∀ y,
        tropicalWordScore A u y > (Finset.sup' (by sorry) (fun v => tropicalWordScore A v y)) - δ →
        decode y = u
```

You may need to weaken the conclusion to “unique maximizer exists.” That is acceptable if fully formalized.

This is a tropical analogue of minimum-distance decoding and is the right constructive coding theorem for this cycle.

---

## Why This Would Be a Breakthrough

If you prove these theorems, you will have created the first certified Lean framework where:

- channel-like information limits are represented as tropical eigenvalues,
- capacity-like quantities arise from fixed-point principles in idempotent semirings,
- uniqueness of optimal signaling laws is recast as uniqueness of tropical eigenvectors,
- decoding guarantees are derived from tropical score separation.

This opens a new synthesis of:

- **information theory**,
- **tropical geometry / idempotent analysis**,
- **spectral graph theory**,
- **coding theory**,
- **dynamic programming / control**.

The deeper significance is that asymptotic communication problems may admit a semiring-native formulation in which optimization, coding, and robustness are unified. This is not an incremental extension of tropical algebra. It suggests a new language for finite-blocklength bounds, zero-error capacity, large deviations, and even reinforcement-learning-style planning under uncertainty.

---

## Catalog Theorems to Build On

Use the listed catalog theorems as structural clues, not as decorative citations:

1. `tropical_add_idempotent` and `tropical_idempotent`  
   These justify the semiring intuition: repeated aggregation collapses under idempotent addition. Use this to motivate why tropical “expectation” is dominated by extremal contributions.

2. `fixed_point_unique_under_theory_separation`  
   This is especially important. Abstract its mechanism: **separation implies uniqueness of fixed points**. Recast your irreducibility / strict-gap hypotheses so this theorem or its proof pattern becomes reusable in the tropical operator setting.

3. `constant_unique_fixed_point`  
   This may help normalize eigenvectors or prove uniqueness after quotienting by additive constants.

4. `idempotent_semiring_with_inverses_trivial`  
   This is philosophically important: do **not** force tropical linear algebra into a ring-like framework with additive inverses. Respect the idempotent semiring structure. This theorem warns you away from false algebraic assumptions.

---

## Proof Strategy Architecture

You must pursue at least 2–3 proof routes in parallel and record which one succeeds.

### Strategy A: Finite max-plus spectral route
Most promising.

1. Define `tropChannelOp` on `Fin n → ℝ` using `Finset.sup'`.
2. Prove monotonicity and additive homogeneity:
   \[
   T_A(x+c)=T_A(x)+c.
   \]
3. Use normalized compactness on the slice `{x | x 0 = 0}` plus continuity of `T_A` to extract a fixed point of the projectivized map, or prove a finite combinatorial cycle-mean theorem and derive the eigenpair.

Why promising: Mathlib handles finite types, `Finset`, `Matrix`, and real analysis well enough for this route. It avoids measure-theoretic entropy machinery.

### Strategy B: Graph-theoretic cycle-mean route
Very strong for the Collatz–Wielandt theorem.

1. Interpret `A` as a weighted directed graph.
2. Define the maximum cycle mean `tropicalCycleValue A`.
3. Prove every eigenvalue is bounded above by every admissible Collatz–Wielandt upper bound.
4. Construct an eigenvector from tight edges on a critical cycle.

Why promising: This converts nonlinear spectral theory into finite combinatorics. It is likely the cleanest route to exact formal theorems.

### Strategy C: Log-transform bridge from classical channels
Ambitious but potentially field-opening.

1. Start with strictly positive finite channel matrix `P`.
2. Set `A = logChannelMatrix P`.
3. Show multiplicative path probabilities become additive path weights.
4. Prove that the asymptotic best path exponent equals the tropical eigenvalue / cycle mean.
5. Compare this exponent to a classical information quantity via Jensen/log-sum-exp inequalities.

Why promising: This is the route to genuine information theory. Why risky: full Shannon capacity in Lean requires significant probabilistic infrastructure. Use it for bridge inequalities, not necessarily the final exact theorem this cycle.

---

## Cross-Domain Connections You Must Exploit

Do not keep this isolated within tropical algebra. Make the connections explicit in the code comments, theorem names, and `ARTICLE.md` if produced.

### 1. Control theory / Bellman operators
`tropChannelOp` is a Bellman operator in disguise. Tropical eigenvectors correspond to additive ergodic constants in deterministic optimal control. This is a major conceptual bridge.

### 2. Spectral graph theory
The tropical eigenvalue is the maximum cycle mean of a weighted digraph. This links capacity to graph circulation structure.

### 3. Coding theory
The tropical score separation theorem is an idempotent version of minimum-distance decoding. This creates a semiring-native coding theory.

### 4. Large deviations / statistical mechanics
Log-transform and tropicalization extract dominant exponential contributions, exactly the same mechanism behind free energy limits and zero-temperature Gibbs measures.

### 5. Theoretical computer science
Max-plus fixed points appear in shortest/longest path algorithms, automata, and mean-payoff games. Your theorems could imply algorithmic capacity approximations.

---

## Lean 4 Formalization Guidance

Use concrete finite types aggressively. Avoid abstract measure spaces unless absolutely necessary.

Recommended scaffolding:

```lean
import Mathlib.Data.Matrix.Basic
import Mathlib.Data.Real.Basic
import Mathlib.Data.Finset.Basic
import Mathlib.Algebra.BigOperators.Basic
import Mathlib.Order.FixedPoints
import Mathlib.Topology.Basic
```

Potential helper lemmas to prove early:

```lean
theorem tropChannelOp_mono {n : ℕ} {A : Matrix (Fin n) (Fin n) ℝ}
    {x y : Fin n → ℝ} (hxy : ∀ i, x i ≤ y i) :
    ∀ i, tropChannelOp A x i ≤ tropChannelOp A y i

theorem tropChannelOp_add_const {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ)
    (x : Fin n → ℝ) (c : ℝ) :
    tropChannelOp A (fun i => x i + c) = fun i => tropChannelOp A x i + c

theorem isTropicalEigenpair_shift
    {n : ℕ} {A : Matrix (Fin n) (Fin n) ℝ} {λ : ℝ} {x : Fin n → ℝ}
    (h : IsTropicalEigenpair A λ x) (c : ℝ) :
    IsTropicalEigenpair A λ (fun i => x i + c)
```

These will be essential for quotienting by additive constants.

If `Finset.sup'` becomes painful, consider working temporarily with `sSup` over finite image sets and then specialize. But prefer finite explicit definitions if possible.

---

## What Not to Do

- Do **not** claim exact equality with Shannon capacity unless you have a precise finite definition and a complete proof.
- Do **not** hide the key notion inside vague “information operators.”
- Do **not** produce only definitions without theorems.
- Do **not** retreat to tautological fixed-point statements.
- Do **not** assume ring inverses in an idempotent semiring context; the catalog already warns this is structurally wrong.

---

## Deliverables

1. Lean 4 file(s) proving at least:
   - existence of a tropical eigenpair for finite matrices,
   - uniqueness modulo constants under a strong irreducibility/separation hypothesis,
   - a variational characterization by a tropical Collatz–Wielandt quantity,
   - at least one constructive tropical decoding / separation theorem.

2. If the full Shannon bridge is not completed:
   - state a precise conjectural theorem,
   - prove a rigorous inequality or surrogate theorem instead.

3. `FUTURE_DIRECTIONS.md` is mandatory and must contain **3–5 concrete, breakthrough-level next steps**, for example:
   - a formal tropical data processing inequality,
   - zero-error capacity via tropical confusability graphs,
   - Arimoto–Blahut as a tropical nonlinear Perron iteration,
   - finite-blocklength converse bounds via tropical large deviations,
   - quantum channel analogues using min-plus transfer operators.

4. Optional but encouraged:
   - `ARTICLE.md` explaining the Bellman/capacity bridge,
   - `RESEARCH_PAPER.md` with theorem statements and proof sketches,
   - `diagram.svg` showing the triangle: channel ↔ graph ↔ tropical operator.

---

## Application Keywords

tropical information theory, max-plus spectral theory, channel capacity, idempotent semiring, fixed-point theorem, Collatz–Wielandt formula, Bellman operator, coding theory, cycle mean, graph entropy, large deviations, zero-error communication, mean-payoff games, semiring optimization, constructive decoding

---

You are Aristotle. Do not merely imitate existing tropical algebra. Create the first formal bridge where communication limits become semiring spectral invariants. Prove the strongest exact theorem you can, and make the future unavoidable through `FUTURE_DIRECTIONS.md`.

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

Research domain: Cryptography
Research mode: prove
