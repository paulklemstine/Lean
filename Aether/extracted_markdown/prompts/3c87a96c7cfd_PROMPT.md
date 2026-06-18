Soli Deo Gloria

## Assignment: Langlands Program: Functoriality

**Mode: prove + formalize + discover**

You are not being asked for a cosmetic formalization of buzzwords. You are being asked to carve out a Lean-native, mathematically serious fragment of **Langlands functoriality** that can actually sustain new theorems, new algorithms, and future generalization. The right move is to formalize a **tractable but nontrivial toy-functoriality theory** that captures the algebraic spine of symmetric power transfer from `GL₂` to higher rank, while proving genuine structure theorems about local Euler factors, coefficient recurrences, and transfer-compatible complexity invariants.

The breakthrough is not “formalize all automorphic representations.” The breakthrough is to define a **verified proxy category of Euler data** in which symmetric power lifting is an explicit functor, prove nontrivial identities for transferred local factors, and connect these transfer laws to another domain — ideally spectral transfer, algebraic circuit complexity, or representation growth. This creates a formal laboratory for functoriality rather than an empty shell.

Your target is a new Lean file developing a **formal theory of finite Euler data and symmetric power transfer**, with at least 3 substantial theorems and one verified computational procedure.

---

## Core Vision

Instead of attempting the full analytic theory of automorphic forms, formalize the **unramified local shadow** of functoriality:

- a `GL₂`-type local parameter is represented by a pair of Satake parameters `(α, β)` over a commutative semiring/field;
- its standard local Euler factor is
  \[
  L_p(s,\pi)^{-1} = (1-\alpha X)(1-\beta X),
  \]
  where `X = p^{-s}` is treated formally;
- the `n`th symmetric power transfer has Euler factor
  \[
  L_p(s,\mathrm{Sym}^n \pi)^{-1}
  = \prod_{i=0}^{n} (1-\alpha^{n-i}\beta^i X).
  \]

This is already rich enough to prove:
1. exact coefficient recurrences,
2. transfer composition laws,
3. determinant/central-character compatibility,
4. a cross-domain complexity statement for transferred Euler polynomials,
5. a falsifiable conjecture on positivity/log-concavity/unimodality of coefficient profiles under arithmetic constraints.

This would be a genuine formal seed for Langlands functoriality: not the whole cathedral, but the first arch that can bear weight.

---

## New Mathematical Structure You Must Define

You must introduce at least one genuinely new structure not already present in the catalog. Recommended definition:

```lean
structure LocalEulerDatum (R : Type _) [CommSemiring R] where
  degree : ℕ
  roots : Fin degree → R
```

Interpretation: `roots` are the inverse Satake parameters defining an Euler factor.

Then define its Euler polynomial:

```lean
def LocalEulerDatum.eulerPoly
    {R : Type _} [CommSemiring R] (D : LocalEulerDatum R) : Polynomial R :=
  ∏ i : Fin D.degree, (Polynomial.X - Polynomial.C (D.roots i))
```

For the `GL₂` case, define:

```lean
def GL2Datum (R : Type _) [CommSemiring R] := R × R
```

and the symmetric power transfer:

```lean
def symmPowDatum
    {R : Type _} [CommSemiring R] (n : ℕ) (ab : GL2Datum R) :
    LocalEulerDatum R
```

with roots indexed by `Fin (n+1)` and given by `α^(n-i) * β^i`.

You may also define a transfer-compatible “conductor-free complexity proxy” for local factors, e.g. coefficient support size, multiplicative depth of recursive coefficient computation, or Newton polygon profile.

A second useful new concept:

```lean
def HeckeTraceSeq
    {R : Type _} [CommSemiring R] (α β : R) : ℕ → R
  | 0 => 1
  | n+1 => α^(n+1) + β^(n+1)
```

Then prove recurrences via Newton identities or direct algebra.

---

## Precise Theorem Targets

You must prove at least 3 deep theorems. Here is the recommended theorem package.

### Theorem 1: Explicit local symmetric power Euler factor
This is the foundational transfer theorem.

**Mathematical statement.**  
For any commutative semiring `R`, any `α β : R`, and any `n : ℕ`, the Euler polynomial of the symmetric power transfer of the `GL₂` datum `(α, β)` is exactly
\[
\prod_{i=0}^{n} (X - \alpha^{n-i}\beta^i).
\]

**Lean target signature:**
```lean
theorem eulerPoly_symmPowDatum
    {R : Type _} [CommSemiring R]
    (n : ℕ) (α β : R) :
    (symmPowDatum n (α, β)).eulerPoly
      = ∏ i : Fin (n+1),
          (Polynomial.X - Polynomial.C (α ^ (n - i.1) * β ^ i.1)) := by
```

If indexing with `Fin` subtraction is awkward, define the roots using `Fin.rev` or an auxiliary map. A more implementation-stable version is:

```lean
theorem eulerPoly_symmPowDatum'
    {R : Type _} [CommSemiring R]
    (n : ℕ) (α β : R) :
    (symmPowDatum n (α, β)).eulerPoly
      = ∏ i : Fin (n+1),
          (Polynomial.X - Polynomial.C ((α ^ (n - i.val)) * (β ^ i.val))) := by
```

**Why this matters.**  
This is the first exact Lean-certified local functoriality formula for symmetric power transfer. It provides the algebraic skeleton for all later Euler-product constructions, coefficient identities, and testable arithmetic conjectures.

---

### Theorem 2: Determinant / central character compatibility under symmetric power transfer
This is the formal analogue of the central-character law for symmetric powers.

**Mathematical statement.**  
For `α, β` in a commutative monoid,
\[
\prod_{i=0}^{n} \alpha^{n-i}\beta^i = (\alpha\beta)^{n(n+1)/2}.
\]

This identity is the exact determinant compatibility of the symmetric power representation of a 2-dimensional parameter.

**Lean target signature:**
```lean
theorem symmPow_root_product
    {R : Type _} [CommMonoid R]
    (n : ℕ) (α β : R) :
    ∏ i : Fin (n+1), (α ^ (n - i.val) * β ^ i.val)
      = (α * β) ^ (n * (n + 1) / 2) := by
```

If division by 2 causes issues in exponents, prove the equivalent split form:
```lean
theorem symmPow_root_product'
    {R : Type _} [CommMonoid R]
    (n : ℕ) (α β : R) :
    ∏ i : Fin (n+1), (α ^ (n - i.val) * β ^ i.val)
      = α ^ (n * (n + 1) / 2) * β ^ (n * (n + 1) / 2) := by
```

**Why this matters.**  
This is the precise local manifestation of how central characters transform under functorial lift. It upgrades the transfer from a bare polynomial construction to a representation-theoretic object with the correct determinant law.

---

### Theorem 3: Symmetric power transfer preserves self-duality under reciprocal Satake parameters
This is a genuine structure theorem.

**Mathematical statement.**  
If `β = α⁻¹` in a commutative group, then the multiset of roots of `Sym^n(α,β)` is closed under inversion; equivalently, the Euler polynomial is self-reciprocal up to a monomial factor.

A polynomial form is preferable.

**Lean target signature:**
```lean
theorem symmPow_self_reciprocal
    {K : Type _} [Field K]
    (n : ℕ) (α : K) :
    let P := (symmPowDatum n (α, α⁻¹)).eulerPoly
    in Polynomial.reverse P
        = Polynomial.C ((-1 : K) ^ (n+1) *
            ∏ i : Fin (n+1), (α ^ (n - i.val) * (α⁻¹) ^ i.val)) * P := by
```

If `Polynomial.reverse` is too brittle, formulate via coefficient symmetry:
```lean
theorem symmPow_coeff_palindromic
    {K : Type _} [Field K]
    (n k : ℕ) (hk : k ≤ n + 1) (α : K) :
    -- precise coefficient symmetry relation
```

**Why this matters.**  
This is the formal shadow of self-dual or unitary transfer phenomena and connects Euler factors to spectral symmetry, random matrix heuristics, and reciprocal-polynomial theory.

---

### Theorem 4: Transfer composition law for symmetric powers on diagonal parameters
This is your “functoriality of functoriality” theorem.

For diagonal parameters, composition of transfers should correspond to a combinatorial refinement of root data. You may not get the full plethysm decomposition in one step, but you can prove a nontrivial divisibility or factor-refinement theorem.

**Mathematical statement.**  
For suitable `m n`, the root set of `Sym^m(Sym^n(α,β))` is given by weighted degree patterns in `α, β`; in particular every root is a monomial `α^A β^B` with `A+B=mn`, and the resulting Euler polynomial has degree `m+1` after the first transfer and combinatorially controlled total degree under iteration.

A tractable theorem:

```lean
theorem symmPow_root_homogeneous
    {R : Type _} [CommMonoid R]
    (m n : ℕ) (α β : R) :
    ∀ r ∈ ((symmPowDatum m (α ^ n, β ^ n)).rootsSetLike),
      ∃ a b : ℕ, a + b = m * n ∧ r = α ^ a * β ^ b := by
```

Or better, if you define iterated transfer combinatorially:

```lean
theorem iterated_symmPow_all_roots_homogeneous
    ...
```

**Why this matters.**  
This is the first formal foothold toward plethysm and true higher functoriality. Even a restricted theorem here opens a route to formal Schur functors and representation-ring semantics.

---

### Theorem 5: Cross-domain theorem connecting functorial transfer to complexity or spectral transfer
You are required to connect to another domain. The catalog suggests two promising bridges:

#### Option A: Algebraic complexity bridge
Use the catalog theorems
- `FINAL/Algebra/AlgebraicCircuitComplexity.lean::depth_lower_bound_from_degree`
- `FINAL/Algebra/CoordinateRingDepth.lean::mulGates_lower_bound_from_degree`

The Euler polynomial of `Sym^n` has degree `n+1`. Therefore any circuit computing it inherits degree-based lower bounds from the catalog.

**Lean target signature sketch:**
```lean
theorem symmPow_euler_depth_lower_bound
    {R : Type _} [CommSemiring R]
    (C : AlgCircuit R 1) (n : ℕ) (α β : R)
    (hC : C.Computes ((symmPowDatum n (α, β)).eulerPoly)) :
    -- invoke catalog theorem with degree = n+1
    depth_lower_bound_from_degree C (n+1) ≤ ... := by
```

If direct compatibility with `Polynomial` and `AlgCircuit` is too heavy, define a verified reduction from Euler polynomial degree to a circuit-obstruction statement using the catalog’s obstruction framework.

**Significance.**  
This says functorial transfer is not just representation theory — it creates algebraic objects with certified computational complexity growth. That is an unexpected Langlands–GCT bridge.

#### Option B: Spectral transfer bridge
Use `spectral_transfer_iterate_bound` from `Algebra/Apollonian/SpectralTransfer.lean`.

Define a numerical invariant of local Euler data (e.g. max root norm in an ordered field or semiring surrogate), and prove that under iterative symmetric transfer this invariant obeys a spectral-type growth bound analogous to transfer operators.

**Lean target signature sketch:**
```lean
theorem symmPow_spectral_growth_bound
    ...
```

**Significance.**  
This connects automorphic transfer to dynamical/spectral propagation, hinting at a formal transfer-operator model for local Langlands shadows.

---

## Recommended Lean 4 Type Signatures

These are not decorative. Use them or nearby variants.

```lean
structure LocalEulerDatum (R : Type _) [CommSemiring R] where
  degree : ℕ
  roots : Fin degree → R

def LocalEulerDatum.eulerPoly
    {R : Type _} [CommSemiring R] (D : LocalEulerDatum R) : Polynomial R :=
  ∏ i : Fin D.degree, (Polynomial.X - Polynomial.C (D.roots i))

def GL2Datum (R : Type _) [CommSemiring R] := R × R

def symmPowDatum
    {R : Type _} [CommSemiring R] (n : ℕ) (ab : GL2Datum R) :
    LocalEulerDatum R :=
by
  rcases ab with ⟨α, β⟩
  exact
  { degree := n + 1
    roots := fun i => α ^ (n - i.val) * β ^ i.val }

theorem eulerPoly_symmPowDatum
    {R : Type _} [CommSemiring R]
    (n : ℕ) (α β : R) :
    (symmPowDatum n (α, β)).eulerPoly
      = ∏ i : Fin (n+1),
          (Polynomial.X - Polynomial.C (α ^ (n - i.val) * β ^ i.val)) := by

theorem symmPow_root_product'
    {R : Type _} [CommMonoid R]
    (n : ℕ) (α β : R) :
    ∏ i : Fin (n+1), (α ^ (n - i.val) * β ^ i.val)
      = α ^ (n * (n + 1) / 2) * β ^ (n * (n + 1) / 2) := by

def heckeTrace
    {R : Type _} [CommSemiring R] (α β : R) (m : ℕ) : R :=
  α ^ m + β ^ m

theorem heckeTrace_recurrence
    {R : Type _} [CommRing R]
    (α β : R) :
    ∀ m : ℕ,
      heckeTrace α β (m+2)
        = (α + β) * heckeTrace α β (m+1)
          - (α * β) * heckeTrace α β m := by
```

This last theorem is especially good: it is nontrivial, uses induction and ring algebra, and encodes the local Hecke recurrence behind `GL₂`.

A stronger transfer theorem then expresses coefficients of the symmetric power Euler polynomial in terms of elementary symmetric polynomials in the monomials `α^(n-i)β^i`.

---

## Proof Strategy Architecture

You must present and execute at least 2–3 proof strategies across the file. Do not rely on one-line simp closures.

### Strategy A: Inductive/combinatorial control of transferred roots
Best for `symmPow_root_product`, coefficient recurrences, and degree statements.

1. Define the root list of `symmPowDatum n (α,β)` explicitly as a `Finset`/`List`.
2. Prove product and sum identities by induction on `n`, using:
   - splitting off the last root,
   - `Fin.sum_univ_succ` / `Fin.prod_univ_succ`,
   - arithmetic identities such as
     \[
     \sum_{i=0}^n i = \frac{n(n+1)}{2}.
     \]
3. Convert the combinatorics into polynomial identities via `Polynomial.prod_X_sub_C_eq`.

**Why promising:** this is robust in Lean and gives exact formulas, not just existence.

---

### Strategy B: Linear recurrence / Newton identity approach
Best for Hecke traces and coefficient theorems.

1. Define `heckeTrace α β m = α^m + β^m`.
2. Prove the second-order recurrence
   \[
   t_{m+2} = (\alpha+\beta)t_{m+1} - \alpha\beta\, t_m
   \]
   by direct ring expansion and induction.
3. Use the recurrence to identify coefficients or generate an algorithm for local factor computation without expanding giant products.

**Why promising:** this is conceptually the closest to Hecke theory and scales toward Dirichlet-series coefficients.

---

### Strategy C: Reciprocal-polynomial symmetry via reverse and coefficient comparison
Best for self-duality theorems.

1. Show inversion permutes the root family when `β = α⁻¹`.
2. Translate root inversion into a statement about `Polynomial.reverse`.
3. Prove coefficient palindromy by matching the `k`th and `(n+1-k)`th elementary symmetric terms.

**Why promising:** this gives a real spectral symmetry theorem and a bridge to random matrix/statistical mechanics language.

---

## Cross-Domain Connections You Must Explicitly Include

At least one theorem and one discussion section must connect to a different domain.

### 1. Langlands + Algebraic Complexity
The local Euler polynomial of a symmetric power lift is a structured high-degree algebraic object. Use:
- `FINAL/Algebra/AlgebraicCircuitComplexity.lean::depth_lower_bound_from_degree`
- `FINAL/Algebra/CoordinateRingDepth.lean::mulGates_lower_bound_from_degree`

to argue that transfer raises complexity in a certified way. This is a striking bridge: **functoriality as complexity amplification**.

### 2. Langlands + Spectral Dynamics
Leverage `spectral_transfer_iterate_bound` conceptually or directly if type-compatible. Interpret iterated symmetric transfer as a controlled propagation of local spectral data. This opens a route from automorphic transfer to transfer-operator methods.

### 3. Langlands + Mathematical Physics
Self-reciprocal Euler polynomials under `β = α⁻¹` resemble partition-function symmetries and spectral dualities. In `ARTICLE.md`, explain this as an analogue of particle/antiparticle or energy-level inversion symmetry — but keep the mathematics precise.

---

## Conjecture With Testable Prediction

You must state at least one falsifiable conjecture and provide a computational test in `demo.py`.

### Recommended conjecture: unimodality / log-concavity of normalized symmetric-power local coefficients
For real positive `α, β` with `αβ = 1` and `α ≥ 1`, consider the coefficients of
\[
\prod_{i=0}^n (1 - \alpha^{n-2i} X).
\]
After normalization by an explicit monomial weight, conjecture that the absolute values of coefficients form a unimodal, possibly log-concave sequence.

**Lean-side conjecture declaration sketch:**
```lean
conjecture symmPow_coeff_unimodal_normalized
    (n : ℕ) (α : ℝ) (hα : 1 ≤ α) :
    let P := (symmPowDatum n (α, α⁻¹)).eulerPoly
    -- precise unimodality statement on normalized coeffs
    True
```

If full coefficient extraction in Lean is too heavy, state the conjecture precisely in comments and implement the computational test in Python.

**Clear computational disproof criterion:**  
For each `n ≤ N` and sampled `α > 1`, compute normalized coefficient magnitudes; if there exists an index violating unimodality/log-concavity, the conjecture is false.

This is scientifically valuable because it produces a concrete empirical frontier around self-dual local factors.

---

## Suggested Theorem Set to Satisfy the Depth Requirement

Your file should contain at least these 3 substantial theorems, each using real tactics:

1. `heckeTrace_recurrence`  
   - uses induction, ring manipulations, `calc`, possibly `nlinarith` or `ring_nf`.
2. `symmPow_root_product'`  
   - uses `Fin.prod_univ_succ`, combinatorial exponent bookkeeping, `calc`.
3. `symmPow_self_reciprocal` or a coefficient-palindromy theorem  
   - uses `rcases`, polynomial reverse lemmas, multistep rewriting.

A fourth theorem should be your cross-domain bridge.

Do **not** let the file devolve into definitional equalities only.

---

## Algorithmic / Computational Deliverable

You must produce a verified computational method, not just theorem statements.

### Required algorithm
Implement a recursive algorithm that computes the coefficient list of the local Euler polynomial of `Sym^n(α,β)` using the Hecke recurrence or iterative multiplication by linear factors.

Example Lean signature:
```lean
def symmPowCoeffs
    {R : Type _} [CommRing R] (n : ℕ) (α β : R) : List R := ...
```

Then verify:
```lean
theorem symmPowCoeffs_correct
    {R : Type _} [CommRing R]
    (n : ℕ) (α β : R) :
    -- polynomial built from symmPowCoeffs equals eulerPoly
    ...
```

This is essential: a certified algorithm for transferred local factors is the computational heart of the project.

---

## demo.py Requirements

Your `demo.py` must:
1. compute local Euler factors for `Sym^n` for sample `α, β, n`,
2. numerically verify determinant compatibility,
3. test the recurrence for Hecke traces,
4. test the conjectured unimodality/log-concavity on a grid of examples,
5. visualize coefficient profiles for self-dual cases `β = 1/α`.

Make the demo interactive: user chooses `n`, `α`, `β`, and sees:
- the factor roots,
- the expanded polynomial,
- coefficient plot,
- pass/fail of recurrence and conjecture tests.

---

## Application Keywords

Include these explicitly in your paper and article:

- Langlands functoriality
- symmetric power lifting
- local Euler factors
- Satake parameters
- Hecke recurrences
- reciprocal polynomials
- self-duality
- algebraic complexity
- spectral transfer
- representation growth
- automorphic shadows
- plethysm heuristics
- mathematical physics duality
- certified symbolic computation

---

## Revolutionary Significance

If successful, this project creates a new formal object: a **Lean-native algebra of functorial local transfer**. That is not a toy. It is the missing middle layer between abstract Langlands philosophy and executable mathematics. It would enable:

- future formalization of unramified local Langlands for `GL_n`,
- verified experiments with symmetric power and Rankin–Selberg type local factors,
- bridges to algebraic complexity via degree-growth lower bounds,
- bridges to spectral dynamics through transfer-growth invariants,
- a route toward Schur functors, plethysm, and eventually genuine representation-ring formalization.

This is how one opens a field: not by pretending to formalize the whole Langlands program at once, but by creating the first exact, extensible, theorem-rich engine of transfer.

---

## Mandatory Deliverables

You must produce **ALL** of the following:

### 1. `FUTURE_DIRECTIONS.md`
Give 3–5 original research directions. Each direction must include:
- a sentence beginning **“The key insight is...”**
- a sentence beginning **“Why now?”**
At least one direction must bridge to a different domain, such as complexity theory, spectral theory, or mathematical physics.

Possible themes:
- plethysm and Schur functor transfer,
- Rankin–Selberg local convolution,
- Newton polygon statistics of local factors,
- complexity amplification under functorial lifts,
- self-dual local factors and random matrix analogies.

### 2. `RESEARCH_PAPER.md`
A standalone scientific document that explains:
- the formal definitions,
- the precise theorems,
- why these are meaningful shadows of Langlands functoriality,
- the algorithmic contribution,
- the conjecture and numerical evidence,
- what should come next.

Someone reading only this paper must understand the discovery without seeing the code.

### 3. `ARTICLE.md`
Write this in **Scientific American style**:
- engaging,
- broad-audience accessible,
- focused on the mathematical ideas and why they matter,
- **do not focus on formal verification machinery**.

Tell the story of how a tiny exact model of functoriality can become a launchpad for a much larger theory.

### 4. Verified algorithm or computational method
Implement and prove correct the coefficient computation for symmetric power local Euler factors.

### 5. `demo.py`
Interactive demonstration with numerical tests, plots, and conjecture checking.

---

## Final Tactical Guidance

- Start small but not shallow: `GL₂` local data, symmetric powers, exact transfer formulas.
- Use the catalog theorems as **bridges**, especially the degree/lower-bound results in `FINAL/Algebra/AlgebraicCircuitComplexity.lean` and `FINAL/Algebra/CoordinateRingDepth.lean`.
- Prefer theorems whose proofs require induction, `rcases`, multistep `calc`, and nontrivial polynomial algebra.
- Minimize `sorry`, but do not choose trivial statements just to avoid difficulty.
- If a full theorem becomes technically blocked, prove a sharply formulated restricted version and explain why it is the right stepping stone.

The decisive question is: can you make functoriality **computable, structural, and transferable** inside Lean? That is the frontier.

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
  **CRITICAL: Each visualization script MUST be a single, fully self-contained
  file. Do NOT import from any local modules (algorithms.py, demo.py, etc.).
  Instead, inline all needed functions and classes directly in the script.
  The browser runtime (Pyodide) has no access to local .py files.**
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
    "visualizations": [ { "name": "...", "code": "# Must be 100% self-contained. Do not import local files. Inline all needed functions directly.", "description": "What this visualizes" } ],
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

Research domain: Algebra
Research mode: prove
