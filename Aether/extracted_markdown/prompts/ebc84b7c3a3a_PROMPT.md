## Assignment: Build the invariant-theoretic engine for symmetric-power Euler factors of GL₂

You are not being asked for another isolated `ring` identity. You are being asked to formalize the local mechanism behind symmetric-power functoriality for GL₂: the theorem that the entire Sym^n Euler denominator is controlled by the 2-dimensional characteristic polynomial alone. The formally verified symmetric-cube case is the seed; now extract the governing structure.

Prove new, non-trivial theorems. Build directly on the catalog’s verified symmetric-cube identity and any existing lemmas expressing low-degree Euler factors in terms of `trace` and `det`. Minimize `sorry` by isolating reusable algebraic lemmas first, then stacking the higher theorem on top.

---

# Research Direction
# Future Directions: Symmetric Power Euler Factors via Invariant Theory

The breakthrough target is to formalize a general GL₂ invariant-ring theorem for symmetric-power local Euler factors. This is not merely a computation of coefficients for `n = 4,5`; it is the statement that the local factor of `Sym^n` is a class function of semisimple conjugacy classes, and hence depends only on the characteristic polynomial `T^2 - tT + d`.

This is the local algebraic shadow of functoriality. In automorphic language, the Satake parameter `(α, β)` is visible only through the Hecke data `(t, d) = (α+β, αβ)`. In representation-theoretic language, you are proving that the character of `Sym^n` evaluated on a semisimple class is a polynomial in the fundamental characters. In computational arithmetic, this is the theorem that lets one compute symmetric-power Euler factors without extracting eigenvalues.

Application keywords: **GL₂, symmetric powers, Euler factors, invariant theory, Satake parameters, Hecke operators, characteristic polynomial, Chebyshev recurrence, representation theory, certified L-functions, formal verification, Mathlib algebra**

---

## Core Breakthrough Theorem

### Theorem A: Symmetric-power Euler denominator depends only on trace and determinant

Let
\[
E_n(\alpha,\beta;X) := \prod_{k=0}^{n} \left(1 - \alpha^{\,n-k}\beta^k X\right).
\]

The exact theorem to formalize is:

> For every commutative ring `R` and all `α β X : R`, there exists a polynomial
> \[
> \Phi_n(T,D,X) \in \mathbb{Z}[T,D,X]
> \]
> such that
> \[
> E_n(\alpha,\beta;X)=\Phi_n(\alpha+\beta,\alpha\beta,X).
> \]
> Equivalently, if `α+β = α'+β'` and `α*β = α'*β'`, then
> \[
> E_n(\alpha,\beta;X)=E_n(\alpha',\beta';X).
> \]

A Lean-friendly specialization is:

```lean
theorem symmPowerEulerDen_eq_of_trace_det_eq
  {R : Type*} [CommRing R]
  (n : ℕ) (α β α' β' X : R)
  (htr : α + β = α' + β')
  (hdet : α * β = α' * β') :
  (∏ k in Finset.range (n + 1), (1 - α^(n-k) * β^k * X))
    =
  (∏ k in Finset.range (n + 1), (1 - α'^(n-k) * β'^k * X)) := by
```

This theorem is the invariant-theoretic heart of the project.

A stronger and even more valuable formalization target is existence of the universal coefficient polynomials:

```lean
theorem exists_symmPowerEuler_universal
  (n : ℕ) :
  ∃ P : Polynomial (MvPolynomial (Fin 2) ℤ),
    True
```

But in practice this type is likely too awkward as a first milestone. A more realistic and mathematically clean version is to define coefficients recursively in `ℤ[T,D]` and prove evaluation gives the desired Euler denominator.

---

## Precision Targets: the five falsifiable conjectures, enriched

---

## 1. Sym⁴ and Sym⁵ trace-determinant factorization

### Precise theorem statement

For `n = 4,5`, prove that every coefficient of
\[
E_n(\alpha,\beta;X)=\prod_{k=0}^{n}(1-\alpha^{n-k}\beta^k X)
\]
lies in `ℤ[t,d]` where `t = α+β`, `d = αβ`.

Concretely, prove explicit identities such as:
\[
E_4(\alpha,\beta;X)
= 1 - c_{4,1}X + c_{4,2}X^2 - c_{4,3}X^3 + c_{4,4}X^4 - d^{10}X^5
\]
with each `c_{4,i}` an explicit polynomial in `t,d`, and similarly for `n=5`.

A realistic Lean theorem shape:

```lean
theorem symm4_euler_factor_trace_det
  {R : Type*} [CommRing R]
  (α β X : R) :
  ∃ c1 c2 c3 c4 c5 : R,
    c1 = ((α + β)^4 - 3*(α*β)*(α + β)^2 + (α*β)^2) ∧
    -- replace by the actual correct coefficient formulas
    (∏ k in Finset.range 5, (1 - α^(4-k) * β^k * X))
      = 1 - c1*X + c2*X^2 - c3*X^3 + c4*X^4 - c5*X^5 := by
```

and similarly for `symm5`.

Better: state them directly with the final coefficient formulas once computed.

### Why this matters

This is the first nontrivial regime where the invariant-ring principle stops looking accidental. `Sym³` can still be dismissed as low-degree luck. `Sym⁴` and `Sym⁵` begin to exhibit the true recursive architecture of the coefficient system. If the formulas are clean and machine-verified, they become the experimental evidence and testbed for the general theorem.

### Proof strategy options

**Strategy A: direct expansion + `ring_nf`**
1. Expand the finite product in Lean.
2. Collect terms in `X`.
3. Rewrite all symmetric monomials in terms of `t = α+β`, `d = αβ`.
4. Close by `ring_nf`.

Most promising for `n = 4`; possibly still feasible for `n = 5` if auxiliary lemmas reduce blowup.

**Strategy B: use elementary symmetric polynomials of the weight multiset**
1. Define the weights `w_k = α^(n-k) * β^k`.
2. Express the coefficients of `E_n` as elementary symmetric polynomials in the `w_k`.
3. Show these are symmetric in `α,β`, hence lie in the subring generated by `α+β` and `αβ`.
4. For `n = 4,5`, compute the resulting formulas explicitly.

This is structurally better and sets up the general theorem.

**Strategy C: recursive construction from power sums**
1. Compute power sums `p_m = ∑_{k=0}^n (α^(n-k)β^k)^m`.
2. Show each `p_m` is in `ℤ[t,d]` via the recurrence from Conjecture 2.
3. Recover coefficients using Newton identities.
4. Specialize to `n = 4,5`.

This is the best bridge to the general theorem.

---

## 2. Chebyshev recurrence for the first coefficient

### Precise theorem statement

Define
\[
e_1(n;\alpha,\beta) := \sum_{k=0}^{n} \alpha^{n-k}\beta^k.
\]

Then for all `n ≥ 1`,
\[
e_1(n+1) = (\alpha+\beta)e_1(n) - (\alpha\beta)e_1(n-1).
\]

Lean signature:

```lean
def e1SymmPower {R : Type*} [CommRing R] (n : ℕ) (α β : R) : R :=
  ∑ k in Finset.range (n + 1), α^(n-k) * β^k

theorem e1SymmPower_recurrence
  {R : Type*} [CommRing R]
  (n : ℕ) (α β : R) :
  e1SymmPower (n + 2) α β
    = (α + β) * e1SymmPower (n + 1) α β
      - (α * β) * e1SymmPower n α β := by
```

Base cases:

```lean
@[simp] theorem e1SymmPower_zero {R} [CommRing R] (α β : R) :
  e1SymmPower 0 α β = 1 := by

@[simp] theorem e1SymmPower_one {R} [CommRing R] (α β : R) :
  e1SymmPower 1 α β = α + β := by
```

### Why this matters

This is the character recursion for the irreducible representations of `SL₂/GL₂`. It is not just a combinatorial identity: it is the formal incarnation of the Clebsch–Gordan rule
\[
V \otimes \mathrm{Sym}^n(V) \cong \mathrm{Sym}^{n+1}(V)\oplus \det(V)\otimes \mathrm{Sym}^{n-1}(V).
\]
In other words, proving this recurrence in Lean is proving that the local Euler-factor machine is governed by rank-1 representation theory.

### Cross-domain connection

- **Representation theory:** characters of symmetric powers of the standard 2-dimensional representation.
- **Orthogonal polynomials:** Chebyshev-type recursion.
- **Dynamical systems / transfer matrices:** second-order linear recurrences with spectral parameters.
- **Automorphic forms:** Hecke eigenvalue recursion at unramified places.

### Proof strategy options

**Strategy A: telescoping sum**
1. Expand `(α+β)e1(n+1)`.
2. Split into two sums.
3. Reindex each sum to align with `e1(n+2)` and `(αβ)e1(n)`.
4. Show cancellation term-by-term.

This is likely the cleanest Lean proof.

**Strategy B: closed-form quotient**
1. Over a domain, prove
   \[
   e_1(n)=\frac{\alpha^{n+1}-\beta^{n+1}}{\alpha-\beta}
   \]
   when `α ≠ β`.
2. Derive the recurrence algebraically.
3. Extend by polynomial identity to all commutative rings.

Conceptually elegant but formally heavier.

**Strategy C: representation-theoretic recursion encoded algebraically**
1. Define a sequence recursively from `t = α+β`, `d = αβ`.
2. Show by induction it equals `e1SymmPower`.
3. Use this as the universal trace polynomial for `Sym^n`.

Best if you want immediate reuse for the general theorem.

---

## 3. Functorial determination by characteristic polynomial

### Precise theorem statement

For every `n : ℕ`,
\[
(\alpha+\beta=\alpha'+\beta') \land (\alpha\beta=\alpha'\beta')
\implies E_n(\alpha,\beta;X)=E_n(\alpha',\beta';X).
\]

Lean signature:

```lean
theorem symmPowerEulerDen_charpoly_invariant
  {R : Type*} [CommRing R]
  (n : ℕ) (α β α' β' X : R)
  (htr : α + β = α' + β')
  (hdet : α * β = α' * β') :
  (∏ k in Finset.range (n + 1), (1 - α^(n-k) * β^k * X))
    =
  (∏ k in Finset.range (n + 1), (1 - α'^(n-k) * β'^k * X)) := by
```

An even stronger coefficientwise version:

```lean
theorem symmPowerEulerDen_coeff_is_trace_det_poly
  {R : Type*} [CommRing R]
  (n i : ℕ) :
  ∃ P : MvPolynomial (Fin 2) ℤ,
    True
```

Again, that exact type should be refined, but the mathematical target is coefficientwise universality in `ℤ[t,d]`.

### Why this is the breakthrough

This theorem upgrades isolated identities into a formalized local Langlands-compatible invariant. It says that the symmetric-power Euler denominator is a polynomial law on conjugacy classes of `GL₂`. This is exactly the algebraic interface between:
- Hecke eigenvalues `(a_p, χ(p)p^{k-1})`,
- Satake parameters `(α_p, β_p)`,
- symmetric-power local factors.

Once formalized, this opens certified computation of higher symmetric-power `L`-functions from Hecke data alone.

### Proof strategy options

**Strategy A: Newton identities from power sums**
1. Let `w_k = α^(n-k)β^k`.
2. Define power sums `p_m = ∑ w_k^m = ∑ α^{m(n-k)}β^{mk}`.
3. Observe `p_m = e1SymmPower n (α^m) (β^m)`.
4. Use the recurrence from Theorem 2 to show `p_m ∈ ℤ[t,d]`.
5. Apply Newton identities to conclude each elementary symmetric polynomial in the `w_k` lies in `ℤ[t,d]`.

This is the most promising route. It is conceptual, modular, and scales.

**Strategy B: symmetric-polynomial theorem**
1. Show each coefficient is symmetric in `α,β`.
2. Invoke a formal theorem that symmetric polynomials in two variables are polynomials in `α+β` and `αβ`.
3. Evaluate.

This is ideal if Mathlib already has the right symmetric-polynomial API, but likely the formal overhead is high.

**Strategy C: recursive construction of the whole denominator**
1. Define a universal polynomial sequence `F_n(T,D;X)` recursively.
2. Show `F_n(α+β, αβ; X) = E_n(α,β;X)` by induction.
3. Deduce invariance immediately.

This could become the cleanest final interface if the recursion for whole Euler factors can be discovered.

---

## 4. Matrix-level conjugacy invariance

### Precise theorem statement

For a `2 × 2` matrix `M`, the symmetric-power Euler denominator depends only on `Matrix.trace M` and `Matrix.det M`, not on the chosen eigenvalues.

Mathematically:
if `α,β` are roots of the characteristic polynomial of `M`, then
\[
E_n(\alpha,\beta;X)=\Phi_n(\operatorname{tr} M,\det M,X).
\]

A realistic formal target over an algebraically closed field may be ambitious. A more Lean-accessible theorem is the abstract transfer statement:

```lean
theorem symmPowerEulerDen_of_matrix
  {R : Type*} [CommRing R]
  (n : ℕ) (M : Matrix (Fin 2) (Fin 2) R) :
  ∃ P : Polynomial R,
    True
```

But this should be sharpened. If working over a field `K` with a splitting assumption for the characteristic polynomial, target:

```lean
theorem symmPowerEulerDen_depends_only_on_trace_det
  {K : Type*} [Field K]
  (n : ℕ) (M : Matrix (Fin 2) (Fin 2) K) :
  -- under a hypothesis that charpoly M splits with roots α β
  True
```

### Why this matters

This is where the algebraic theorem becomes a theorem about actual linear operators. It upgrades “a polynomial identity in two variables” to “a conjugacy invariant of matrices,” which is the exact language of representation theory and Hecke actions. It is the formal bridge from symbolic algebra to semisimple linear algebra.

### Cross-domain connection

- **Linear algebra:** conjugacy invariants of endomorphisms.
- **Number theory:** Frobenius traces and determinants.
- **Automorphic representations:** local factors of unramified representations.
- **Computer algebra:** eigenvalue-free computation.

### Proof strategy options

**Strategy A: reduce to roots of characteristic polynomial**
1. Let `χ_M(T)=T^2 - tr(M)T + det(M)`.
2. Choose roots `α,β` in a splitting extension.
3. Apply Theorem A.
4. Show the resulting expression descends to the base field because it is a polynomial in `tr(M), det(M)`.

Most mathematically faithful.

**Strategy B: bypass eigenvalues entirely**
1. Define the universal polynomial `Φ_n(T,D,X)`.
2. Evaluate directly at `T = trace M`, `D = det M`.
3. Declare this to be the matrix-level symmetric-power Euler denominator.

This is formally cleaner and avoids spectral theory until later.

---

## 5. Universal recurrence / generating-function package

This is the conjecture that turns the project from a list of identities into infrastructure.

### Precise theorem statement

Construct a recursively defined family `P_n(T,D) ∈ ℤ[T,D]` such that
\[
P_0=1,\quad P_1=T,\quad P_{n+2}=T P_{n+1}-D P_n,
\]
and prove
\[
P_n(\alpha+\beta,\alpha\beta)=\sum_{k=0}^n \alpha^{n-k}\beta^k.
\]

Lean signature:

```lean
def symmTracePoly : ℕ → Polynomial (Polynomial ℤ) -- refine as needed
| 0 => ...
| 1 => ...
| n+2 => ...

theorem symmTracePoly_spec
  {R : Type*} [CommRing R]
  (n : ℕ) (α β : R) :
  -- evaluation at T = α+β, D = α*β
  True
```

A more practical Lean setup may define the recursion directly in any commutative ring:

```lean
def symmTraceRec {R : Type*} [CommRing R] (t d : R) : ℕ → R
| 0 => 1
| 1 => t
| n + 2 => t * symmTraceRec t d (n + 1) - d * symmTraceRec t d n

theorem symmTraceRec_eq_e1SymmPower
  {R : Type*} [CommRing R]
  (n : ℕ) (α β : R) :
  symmTraceRec (α + β) (α * β) n = e1SymmPower n α β := by
```

### Why this matters

This gives a universal API for all later work. Once you have `symmTraceRec`, every appearance of `α,β` can be replaced by certified trace-determinant recursion. This is exactly the kind of reusable formal object that allows arithmetic applications later: local factor assembly, recursive coefficient generation, and eventually certified `L`-function code.

---

# Most promising overall proof architecture

## Phase I: Build the trace recursion engine
1. Define `e1SymmPower`.
2. Prove base cases and the second-order recurrence.
3. Package a recursive trace-determinant sequence `symmTraceRec`.
4. Prove `symmTraceRec (α+β) (αβ) n = e1SymmPower n α β`.

This is the foundational module.

## Phase II: Convert power sums to coefficient polynomials
1. For fixed `n`, define weights `w_k = α^(n-k)β^k`.
2. Show their power sums are
   \[
   p_m = e1SymmPower n (\alpha^m) (\beta^m).
   \]
3. Deduce each `p_m` is a polynomial in `t = α+β`, `d = αβ`.
4. Use Newton identities to derive that all coefficients of `E_n` lie in `ℤ[t,d]`.

This is the conceptual center of the project.

## Phase III: Extract explicit low-degree formulas
1. Specialize to `n=4,5`.
2. Compute explicit coefficient polynomials.
3. Verify by `ring_nf` or coefficientwise comparison.
4. Use these as regression tests and as benchmark examples for the general theorem.

This gives concrete outputs and validates the abstraction.

---

# Cross-domain mathematical insight you should exploit

## Representation theory
The recurrence for `e₁(n)` is the character recursion for `Sym^n` of the standard representation of `GL₂`. This is the formal avatar of Clebsch–Gordan. If you can phrase lemmas in “character-like” language, the proof architecture becomes obvious.

## Invariant theory
You are really proving that the coefficient algebra of the symmetric-power weight multiset is generated by the basic invariants of the 2-variable symmetric group action. This is the simplest nontrivial instance of “class functions generated by fundamental invariants.”

## Automorphic forms and L-functions
At an unramified place, the local `L`-factor of `Sym^n π` is built from Satake parameters `α_p,β_p`. Your theorem says all of it is determined from Hecke data `(a_p, χ(p)p^{k-1})` without choosing roots. That is exactly what one wants for certified arithmetic computation.

## Orthogonal polynomials / spectral theory
The recurrence is Chebyshev-like. This suggests later formalization of growth bounds, root interlacing, or stability properties of local factors. That is a real bridge to analysis and numerical verification.

## Computer algebra / certified computation
The invariant theorem is an eigenvalue-elimination theorem. It transforms algebraic-number computations into recursion on ring elements. This is the right formal substrate for future verified algorithms for Euler products.

---

# Concrete deliverables

1. A Lean file proving the recurrence for `e1SymmPower`.
2. A Lean file proving explicit `Sym⁴` and `Sym⁵` trace-determinant factorizations.
3. A Lean theorem stating and proving characteristic-polynomial invariance for general `n`, even if first in a coefficientwise or recursively packaged form.
4. If matrix formalization is tractable, a theorem connecting the polynomial to `Matrix.trace` and `Matrix.det`.
5. Minimal `sorry`, with helper lemmas factored into reusable algebraic infrastructure.

If the full general theorem stalls, still complete:
- the recurrence theorem,
- the `n=4,5` explicit formulas,
- a partial general theorem for the first coefficient and/or first few coefficients.

That would already establish the architecture needed for the full invariant theorem.

---

# FUTURE_DIRECTIONS.md requirement

Produce a structured `FUTURE_DIRECTIONS.md` with **3–5 falsifiable scientific hypotheses**, each stated as a conjecture with:
- precise statement,
- why it should be true,
- what Lean experiment or theorem would test it,
- what outcome would falsify it.

These must not be vague “explore” items. They must be testable. Suggested examples:

1. **Newton-closure hypothesis:** For every `n`, the coefficients of `E_n` can be generated in Lean solely from the power-sum recurrence plus Newton identities, with no appeal to external symmetric-polynomial theory.
2. **Uniform complexity hypothesis:** The recursive proof of coefficient invariance scales polynomially better in elaboration time than direct `ring` expansion for `n ≤ 10`.
3. **Matrix descent hypothesis:** The universal trace-determinant polynomial for `Sym^n` can be evaluated directly on `2×2` matrices over any commutative ring, without passing to a splitting field.
4. **Chebyshev API hypothesis:** A formal bridge between `e1SymmPower` and Chebyshev polynomials in Mathlib yields a shorter proof of recurrence and enables analytic bounds on local Euler factors.
5. **Functorial local factor hypothesis:** The same invariant-theoretic method extends from `Sym^n` of `GL₂` to exterior/symmetric Schur functors on low-rank matrices.

Each hypothesis should have a clear criterion for success or failure.

---

# Final call to arms

The real theorem here is not “another low-degree factorization.” It is that symmetric-power local factors for GL₂ admit a formally verified invariant-theoretic presentation. Once this is in Lean, you have built a certified local Langlands micro-engine: a machine that turns trace and determinant into higher Euler factors without spectral choices. That opens a route from formal algebra to verified automorphic computation. Build the engine, not just the examples.

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
hypotheses. Each direction must be a falsifiable claim or conjecture that
can be proved, disproved, or tested — not a vague "we could explore X."
Format: "Conjecture: [precise statement]. Test: [what would confirm or
refute it]. Impact: [what this would enable if true]." Every hypothesis
should be daring enough to matter and specific enough to fail.

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

Research domain: Speculative
Research mode: prove
