## Mode: prove

## Assignment: Proof Automation as Mathematics — Certified Tactics for Tropical Algebra, Finite Arithmetic Search, and Spectral Inequalities

Do not treat this as engineering. Treat it as the beginning of a **metatheory of domain-specific proof automation inside Lean 4**: prove that specialized tactics for structurally rich mathematical fragments are not merely convenient, but **certified reflection principles** that turn hard symbolic proof patterns into trustworthy, reusable theorem-producing engines.

The goal is to prove new, non-trivial theorems and implement the corresponding tactics with **soundness theorems stated explicitly in Lean 4**. Build on the catalog theorems below, but do not stop at wrappers around `simp` or `omega`. The breakthrough is to isolate fragments where automation is mathematically canonical.

### Existing Verified Theorems to Build On
1. `tropical_plus_distributes_over_min`
   from `Logic/TropicalTypeTheory.lean`

2. `classicallyBounded_of_catalog`
   from `Logic/ResourceBoundedNonlocality.lean`

3. `factorial_plus_k_divisible`
   from `Logic/Chronos.lean`

4. `bool_and_true_is_idempotent`
   from `Logic/DynamicalProofComplexity.lean`

5. `area_law_proof`
   from `Logic/HolographicProofs.lean`

### Cold-start priority
If a major new theorem stalls, also inspect whether there are sorry targets around `CarmichaelComposite` and `Fib_gcd_identity`; but the primary mission here is **certified automation with genuine mathematics**.

---

# Vision

Build three certified tactic families:

1. `tropical_simp`:
   a normalization-and-discharge tactic for min-plus/tropical expressions.

2. `number_theory_decide`:
   a reflective tactic for bounded existential and divisibility statements over `Nat`.

3. `spectral_bound`:
   a tactic that certifies matrix/eigenvalue norm bounds from computable hypotheses.

The breakthrough is not “write tactics.” The breakthrough is to prove that for carefully chosen fragments, **proof search is equivalent to normalization, finite verification, or monotone bounding**. That opens a new field direction: **certified mathematical micro-solvers** inside Lean, each with a precise semantic contract.

Application keywords: `proof automation`, `reflection`, `tropical algebra`, `spectral graph theory`, `formal verification`, `bounded arithmetic`, `matrix analysis`, `decision procedures`, `certified computation`, `nonlinear normalization`

---

# Core theorem package

You should aim to formalize the following theorem cluster. If needed, define a syntactic expression type for each fragment and an evaluation function, then prove normalization/decision soundness.

## I. Tropical normalization theorem

Define a syntax of tropical expressions over variables with constants, binary `min`, and tropical addition interpreted as ordinary addition over `ℕ` or `ℤ`/`ℝ` depending on what is most feasible. Then prove that normalization preserves semantics and yields a canonical form adequate for proving equality.

A strong target theorem:

```lean
inductive TropExpr (α : Type)
| var : α → TropExpr α
| const : ℕ → TropExpr α
| tadd : TropExpr α → TropExpr α → TropExpr α
| tmin : TropExpr α → TropExpr α → TropExpr α

def TropExpr.eval {α : Type} (σ : α → ℕ) : TropExpr α → ℕ := ...

def TropExpr.normalize {α : Type} : TropExpr α → TropExpr α := ...

theorem TropExpr.normalize_sound {α : Type} (σ : α → ℕ) :
  ∀ e, TropExpr.eval σ (TropExpr.normalize e) = TropExpr.eval σ e := ...
```

Then push to a theorem that actually justifies a tactic:

```lean
theorem tropical_simp_sound
  {α : Type} (σ : α → ℕ) (e₁ e₂ : TropExpr α)
  (hnorm : TropExpr.normalize e₁ = TropExpr.normalize e₂) :
  TropExpr.eval σ e₁ = TropExpr.eval σ e₂ := ...
```

A more semantic, catalog-connected theorem should also be proved directly on ordinary expressions whenever possible:

```lean
theorem tropical_minplus_normal_form_complete
  {α : Type} (σ : α → ℕ) :
  ∀ e₁ e₂ : TropExpr α,
    TropExpr.normalize e₁ = TropExpr.normalize e₂ →
    TropExpr.eval σ e₁ = TropExpr.eval σ e₂ := ...
```

Use `tropical_plus_distributes_over_min` as the seed rewrite showing that tropical addition distributes over tropical minimum; then seek a canonical “minimum of affine forms” normal form.

### Why this is a breakthrough
This turns tropical algebra from a bag of ad hoc rewrites into a **certified reflective theory of tropical expressions**. That has consequences for tropical geometry, shortest-path semirings, optimization, and neural-network verification in min-plus form.

---

## II. Bounded number-theoretic reflection theorem

Create a small reflective checker for bounded arithmetic propositions, especially divisibility and finite existential search. The point is not to decide all number theory, but to prove a mathematically meaningful fragment complete.

A precise theorem target:

```lean
def NatCheckDivisible (a b : ℕ) : Bool := ...
def NatCheckExistsUpTo (N : ℕ) (p : ℕ → Bool) : Bool := ...

theorem NatCheckDivisible_sound {a b : ℕ} :
  NatCheckDivisible a b = true → a ∣ b := ...

theorem NatCheckExistsUpTo_sound {N : ℕ} {p : ℕ → Bool}
  (hp : ∀ n, p n = true → True) :
  NatCheckExistsUpTo N p = true →
  ∃ n ≤ N, p n = true := ...
```

But do not stop there; tie this to actual mathematics by proving a theorem schema that can certify bounded divisibility witnesses:

```lean
theorem number_theory_decide_factorial_window
  (n k : ℕ) (hk2 : 2 ≤ k) (hkn : k ≤ n) :
  NatCheckDivisible k (Nat.factorial n) = true := ...
```

and then derive:

```lean
theorem number_theory_decide_factorial_plus_k
  (n k : ℕ) (hk2 : 2 ≤ k) (hkn : k ≤ n) :
  k ∣ Nat.factorial n + k := ...
```

using `factorial_plus_k_divisible`.

A stronger reflective completeness theorem for bounded existential statements is highly desirable:

```lean
theorem NatCheckExistsUpTo_complete
  {N : ℕ} {p : ℕ → Bool} :
  (∃ n ≤ N, p n = true) →
  NatCheckExistsUpTo N p = true := ...
```

If this is too abstract due to arbitrary `Bool` predicates, restrict to a reified syntax of divisibility predicates and prove soundness/completeness there.

### Why this is a breakthrough
This yields a **formal small-scale arithmetic laboratory**: bounded Diophantine search with proof-producing certificates. It bridges theorem proving, computational number theory, and certified brute force. That can later attack pseudoprimes, recurrence divisibility, and finite obstruction classification.

---

## III. Certified spectral bounding theorem

This is the most ambitious and potentially most field-opening component. Formalize a tactic that converts easy-to-check matrix inequalities into spectral radius or eigenvalue bounds. Work with `Matrix (Fin n) (Fin n) ℝ`, and if direct eigenvalue machinery is too heavy, target operator norm bounds first and derive spectral statements as corollaries.

A realistic but nontrivial theorem target:

```lean
open Matrix

theorem spectral_radius_le_max_row_sum
  {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) :
  spectralRadius A ≤
    Finset.sup Finset.univ
      (fun i => ∑ j, |A i j|) := ...
```

If `spectralRadius` is unavailable or too difficult in current Mathlib interfaces, prove the operator norm bound first:

```lean
theorem linfty_opNorm_le_max_row_sum
  {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) :
  ‖A.toLin'‖ ≤
    Finset.sup Finset.univ
      (fun i => ∑ j, |A i j|) := ...
```

or a finite-dimensional vector inequality:

```lean
theorem matrix_mul_vec_sup_bound
  {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) (x : Fin n → ℝ) :
  (∃ C, C = Finset.sup Finset.univ (fun i => ∑ j, |A i j|) ∧
    ∀ i, |∑ j, A i j * x j| ≤ C * Finset.sup Finset.univ (fun j => |x j|)) := ...
```

Then package this as tactic soundness:

```lean
theorem spectral_bound_sound
  {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) (C : ℝ)
  (hC : ∀ i, ∑ j, |A i j| ≤ C) :
  ∀ i, |∑ j, A i j| ≤ C := ...
```

This last theorem is only a placeholder shape; improve it into a meaningful operator/spectral statement. The actual tactic should solve goals of the form “operator norm/spectral radius ≤ C” by reducing to row-sum inequalities.

Use `classicallyBounded_of_catalog` and `area_law_proof` conceptually: both indicate catalog interest in **boundedness and global constraints emerging from local structure**. Your spectral tactic should embody exactly that philosophy.

### Why this is a breakthrough
This would create a bridge between formal linear algebra, spectral graph theory, quantum information, and proof automation. A certified `spectral_bound` tactic could become the kernel for formal proofs in expander theory, Markov chains, stability analysis, and Hamiltonian complexity.

---

# Lean 4 type-signature targets

You asked for precise Lean-facing theorem statements. Here is a concrete list to prioritize.

## Tropical
```lean
inductive TropExpr (α : Type)
| var : α → TropExpr α
| const : ℕ → TropExpr α
| tadd : TropExpr α → TropExpr α → TropExpr α
| tmin : TropExpr α → TropExpr α → TropExpr α

def TropExpr.eval {α : Type} (σ : α → ℕ) : TropExpr α → ℕ := ...

def TropExpr.normalize {α : Type} : TropExpr α → TropExpr α := ...

theorem TropExpr.normalize_sound {α : Type} (σ : α → ℕ) :
  ∀ e : TropExpr α, TropExpr.eval σ (TropExpr.normalize e) = TropExpr.eval σ e := ...

theorem tropical_simp_sound
  {α : Type} (σ : α → ℕ) (e₁ e₂ : TropExpr α)
  (h : TropExpr.normalize e₁ = TropExpr.normalize e₂) :
  TropExpr.eval σ e₁ = TropExpr.eval σ e₂ := ...
```

## Number theory
```lean
def NatCheckDivisible (a b : ℕ) : Bool := ...
def NatCheckExistsUpTo (N : ℕ) (p : ℕ → Bool) : Bool := ...

theorem NatCheckDivisible_sound {a b : ℕ} :
  NatCheckDivisible a b = true → a ∣ b := ...

theorem NatCheckExistsUpTo_sound {N : ℕ} {p : ℕ → Bool} :
  NatCheckExistsUpTo N p = true → ∃ n ≤ N, p n = true := ...

theorem NatCheckExistsUpTo_complete {N : ℕ} {p : ℕ → Bool} :
  (∃ n ≤ N, p n = true) → NatCheckExistsUpTo N p = true := ...

theorem number_theory_decide_factorial_plus_k
  (n k : ℕ) (hk2 : 2 ≤ k) (hkn : k ≤ n) :
  k ∣ Nat.factorial n + k := ...
```

## Spectral / matrix bounds
```lean
theorem matrix_row_sum_bound
  {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) :
  ∃ C : ℝ, (∀ i, ∑ j, |A i j| ≤ C) := ...

theorem matrix_mul_vec_sup_norm_bound
  {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) :
  ∃ C : ℝ,
    (∀ i, ∑ j, |A i j| ≤ C) ∧
    ∀ x : Fin n → ℝ, ∀ i,
      |∑ j, A i j * x j| ≤ C * Finset.sup Finset.univ (fun j => |x j|) := ...
```

If feasible in Mathlib:
```lean
theorem spectral_radius_le_of_row_sum_bound
  {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) (C : ℝ)
  (hC : ∀ i, ∑ j, |A i j| ≤ C) :
  spectralRadius A ≤ C := ...
```

---

# Proof strategy architecture

## Strategy A: Reflection-first, syntax-semantics separation
Most promising for `tropical_simp` and `number_theory_decide`.

1. Define a reified syntax for the target fragment and an evaluator into semantics.
2. Define a computable normalization/checker.
3. Prove soundness by structural induction on syntax or recursion on the search bound.
4. Expose a tactic that reifies the goal, computes the certificate, and applies the soundness theorem.

Why this is promising:
- It gives a genuine theorem, not heuristic automation.
- It scales: once syntax and soundness exist, tactic implementation is comparatively routine.
- It aligns with the strongest tradition in theorem proving: small certified kernels.

## Strategy B: Canonical-form mathematics before tactic implementation
Most promising for tropical algebra.

1. Prove algebraic lemmas that every tropical expression is equal to a minimum of affine forms.
2. Define canonical sorting/deduplication on the finite list of affine forms.
3. Prove two expressions are semantically equal when canonical forms coincide.
4. Only then package this as `tropical_simp`.

Why this may beat a purely syntactic proof:
- It reveals the actual mathematics behind the tactic: tropical expressions correspond to piecewise-linear convex data.
- It opens direct connections to tropical geometry and optimization.

## Strategy C: Inequality certificates via monotone majorants
Most promising for `spectral_bound`.

1. Avoid eigenvalues at first; prove row-sum or norm inequalities using triangle inequality and finite sums.
2. Express the result as a certificate theorem: local row bounds imply global action bounds on vectors.
3. Derive operator norm bounds, then spectral consequences as corollaries where library support allows.
4. Build the tactic around generating these local certificates.

Why this is the best route:
- Eigenvalue APIs can be heavy.
- Row-sum bounds are classical, computable, and robust.
- This strategy still yields impactful automation with clear future escalation to spectral radius.

---

# Concrete cross-domain connections to exploit

## Tropical geometry × proof automation
A normal form for tropical expressions is a formal analogue of passing from formulas to tropical polyhedral complexes. This suggests future tactics for:
- shortest path semirings,
- max-plus control,
- piecewise-linear neural verification,
- tropicalization of algebraic identities.

## Number theory × computational complexity
A bounded-search arithmetic tactic is a formal version of **NP witness checking** inside Lean. That creates a path toward:
- certified search for pseudoprimes,
- bounded counterexample generation,
- formal complexity classifications of finite arithmetic fragments.

Use `factorial_plus_k_divisible` not just as a theorem to invoke, but as a prototype of “large symbolic theorem, tiny reflective certificate.”

## Spectral graph theory × quantum information
A row-sum/spectral tactic naturally speaks to:
- adjacency matrix bounds,
- mixing estimates for Markov chains,
- Hamiltonian norm estimates,
- area-law style bounded entanglement heuristics.

This is where `area_law_proof` and `classicallyBounded_of_catalog` matter philosophically: local constraints imply global boundedness. Make that principle formal and executable.

## Boolean rewriting × reflective kernels
`bool_and_true_is_idempotent` is tiny, but conceptually important: it shows the catalog already contains the seed of **Boolean reflection and normalization**. The new tactics should generalize that worldview from Booleans to tropical algebra, arithmetic search, and matrix inequalities.

---

# Nontrivial theorem suggestions beyond the base package

If progress is strong, push toward one of these:

### 1. Tropical affine envelope theorem
Every `TropExpr α` can be normalized to a finite multiset of affine forms such that evaluation is the minimum over that set.

Possible Lean shape:
```lean
def AffForm (α : Type) := α →₀ ℕ × ℕ
def TropNF (α : Type) := List (AffForm α)

theorem TropExpr.exists_affine_nf {α : Type} :
  ∀ e : TropExpr α, ∃ nf : TropNF α,
    ∀ σ, TropExpr.eval σ e = evalTropNF σ nf := ...
```

This would be mathematically deeper than mere normalization.

### 2. Certified finite obstruction theorem for divisibility predicates
For a bounded predicate class, prove the checker is both sound and complete.

Example:
```lean
inductive DivForm
| dvd_const : ℕ → ℕ → DivForm
| and : DivForm → DivForm → DivForm
| or : DivForm → DivForm → DivForm
| existsUpTo : ℕ → (ℕ → DivForm) → DivForm
```

Even a restricted version would be powerful.

### 3. Gershgorin-style certified spectral enclosure
If feasible, formalize a real/complex version of Gershgorin discs.

Target shape:
```lean
theorem eigenvalue_mem_gershgorin
  {n : ℕ} (A : Matrix (Fin n) (Fin n) ℂ) :
  ∀ μ, IsEigenvalue μ A →
    ∃ i, Complex.abs (μ - A i i) ≤ ∑ j in Finset.univ.erase i, Complex.abs (A i j) := ...
```

This would be genuinely field-opening if achieved in Lean 4.

---

# Build order

1. **Implement and prove** `NatCheckExistsUpTo_sound` and `NatCheckExistsUpTo_complete`.
   This is the fastest certified win.

2. **Implement tropical syntax + eval + normalize_sound**.
   Start with a modest normal form; do not over-engineer.

3. **Prove matrix vector sup-norm row-sum bound**.
   This is likely the right first spectral theorem.

4. Package each theorem into a small custom tactic:
   - `number_theory_decide`
   - `tropical_simp`
   - `spectral_bound`

5. Then seek a deeper theorem:
   - tropical affine normal form, or
   - operator norm corollary, or
   - bounded completeness for a reified arithmetic fragment.

---

# Tactical implementation guidance

Your tactics should be theorem-driven:
- reify expression,
- compute certificate,
- apply a named soundness theorem,
- close side goals by `decide`, `native_decide`, arithmetic lemmas, or finite induction.

Avoid opaque metaprogramming that “just works” without a mathematical contract. The point is to produce tactics whose **correctness reduces to explicit proven lemmas**.

---

# Deliverables

## Required Lean artifacts
- A file defining reified syntax and evaluator for tropical expressions.
- A file proving normalization soundness.
- A file defining bounded arithmetic checkers and proving soundness/completeness.
- A file proving at least one substantial matrix row-sum/operator-norm inequality.
- Custom tactics invoking these theorems.
- Minimal `sorry`.

## Required theorem minimum
At least one theorem from each family:
1. tropical normalization soundness,
2. bounded arithmetic checker soundness,
3. matrix/spectral certificate theorem.

## Required documentation
Produce `FUTURE_DIRECTIONS.md` with **3–5 concrete breakthrough next steps**, each including:
- exact theorem statement,
- why it matters,
- proof strategy,
- dependencies from current work,
- cross-domain connection.

Make it specific enough to drive the next cycle.

---

# What success looks like

Success is not “we wrote a convenience tactic.” Success is:

- a certified tropical normalizer that reveals hidden polyhedral structure,
- a reflective arithmetic checker that turns bounded search into proof,
- a spectral certificate engine that transforms local inequalities into global linear-algebra theorems.

That combination opens a new research program: **domain-native certified automation as formal mathematics**.

Do not merely automate proofs. **Prove that automation itself is mathematics.**

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

Research domain: Logic
Research mode: prove
