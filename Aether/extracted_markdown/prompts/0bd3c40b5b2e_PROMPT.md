## Assignment: theorem `symmCube_denominator_in_trace_det (α β X : ℂ)`

**Mode:** `prove`

Prove a genuinely new structural theorem, not just an expansion exercise: the symmetric-cube local Euler denominator for a rank-2 Satake parameter depends only on the conjugacy invariants
\[
t := \alpha+\beta,\qquad d := \alpha\beta,
\]
and hence is a universal polynomial in `t`, `d`, and `X`. This is the first nontrivial case of the full principle that all symmetric-power Euler factors factor through the invariant ring of `GL₂`, i.e. through trace and determinant alone.

This is not merely a computational identity. It is the algebraic seed of **functoriality-by-invariants**: the local factor of `Sym^n` should be definable without choosing eigenvalues, only from the semisimple conjugacy class. The `n = 3` case is the first place where the coefficient pattern becomes genuinely nonlinear and begins to reflect the recurrence structure of λ-ring / character theory.

---

## Precise target theorem

Let
\[
t = \alpha+\beta,\qquad d=\alpha\beta.
\]
Then
\[
(1-\alpha^3X)(1-\alpha^2\beta X)(1-\alpha\beta^2X)(1-\beta^3X)
=
1-(t^3-2td)X+(dt^4-3d^2t^2+2d^3)X^2-d^3(t^3-2td)X^3+d^6X^4.
\]

A cleaner invariant expression is obtained by first observing the multiset of roots:
\[
\{\alpha^3,\alpha^2\beta,\alpha\beta^2,\beta^3\}.
\]
Their elementary symmetric polynomials are:
- \(e_1=\alpha^3+\alpha^2\beta+\alpha\beta^2+\beta^3=t^3-2td\),
- \(e_2=d(\alpha^4+\alpha^3\beta+2\alpha^2\beta^2+\alpha\beta^3+\beta^4)=dt^4-3d^2t^2+2d^3\),
- \(e_3=d^3(\alpha+\beta)(\alpha^2+\beta^2)=d^3(t^3-2td)\),
- \(e_4=(\alpha\beta)^6=d^6\).

So the theorem should be formalized exactly as:

```lean
theorem symmCube_denominator_in_trace_det (α β X : ℂ) :
    (1 - α^3 * X) * (1 - α^2 * β * X) * (1 - α * β^2 * X) * (1 - β^3 * X) =
      1
        - (((α + β)^3 - 2 * (α + β) * (α * β)) * X)
        + (((α * β) * (α + β)^4 - 3 * (α * β)^2 * (α + β)^2 + 2 * (α * β)^3) * X^2)
        - (((α * β)^3 * ((α + β)^3 - 2 * (α + β) * (α * β))) * X^3)
        + ((α * β)^6 * X^4) := by
  ...
```

You should also strongly consider proving the polynomial version first, which is mathematically superior and likely easier to reuse:

```lean
theorem symmCube_denominator_poly_in_trace_det (α β : ℂ) :
    (Polynomial.C : ℂ →+* Polynomial ℂ) 1
      - Polynomial.C (α^3) * Polynomial.X |> sorry
```

But because the API for direct polynomial expansion can be annoying, the scalar identity in `ℂ` at arbitrary `X` may be the best first deliverable.

---

## Stronger structural formulation you should aim for

Do not stop at the bare identity. Package the phenomenon as an invariant-ring statement:

```lean
def symmCubeEulerDen (α β X : ℂ) : ℂ :=
  (1 - α^3 * X) * (1 - α^2 * β * X) * (1 - α * β^2 * X) * (1 - β^3 * X)

theorem symmCubeEulerDen_eq_trace_det_formula (α β X : ℂ) :
  ∃ P : ℂ → ℂ → ℂ → ℂ,
    symmCubeEulerDen α β X = P (α + β) (α * β) X := by
  ...
```

Even better, define the explicit universal polynomial:
```lean
def symmCubeTraceDetPoly (t d X : ℂ) : ℂ :=
  1 - (t^3 - 2 * t * d) * X
    + (d * t^4 - 3 * d^2 * t^2 + 2 * d^3) * X^2
    - (d^3 * (t^3 - 2 * t * d)) * X^3
    + d^6 * X^4
```
and prove
```lean
theorem symmCubeEulerDen_trace_det (α β X : ℂ) :
  symmCubeTraceDetPoly (α + β) (α * β) X =
    (1 - α^3 * X) * (1 - α^2 * β * X) * (1 - α * β^2 * X) * (1 - β^3 * X) := by
  ...
```

This formulation is what will scale to `Sym^n`.

---

## Why this is a breakthrough

This is the first Lean-certified instance of a broad and deep principle:

> **Symmetric power local factors for rank-2 parameters factor through the invariant ring `ℤ[α,β]^{S₂} = ℤ[t,d]`.**

That is the algebraic core of local Langlands functoriality for `GL₂` symmetric powers. Once formalized, it opens several directions:

1. **Conjugacy-class formulation of Euler factors.**  
   You can define local factors from trace and determinant of semisimple matrices, bypassing explicit eigenvalue choices.

2. **Hecke recursion and certified coefficient formulas.**  
   The coefficients become universal Hecke polynomials in the standard Hecke eigenvalue and nebentypus/determinant.

3. **Gateway to `Sym^n` formalization.**  
   The `n=3` case is the first one rich enough to expose the correct recurrence structures, Newton identities, and plethystic patterns.

4. **Bridge between representation theory and computer algebra.**  
   This creates a machine-checked pipeline from characters / Schur functors to explicit Euler factors.

---

## Proof strategy architecture

### Strategy A: Direct expansion + symmetric polynomial reduction
**Most immediate, probably the fastest in Lean for `n = 3`.**

1. Expand the fourfold product into
   \[
   1 - e_1 X + e_2 X^2 - e_3 X^3 + e_4 X^4
   \]
   where `e_i` are the elementary symmetric polynomials in
   `α^3, α^2*β, α*β^2, β^3`.

2. Prove the coefficient identities separately:
   - `α^3 + α^2*β + α*β^2 + β^3 = (α+β)^3 - 2*(α+β)*(α*β)`
   - `... = (α*β)*(α+β)^4 - 3*(α*β)^2*(α+β)^2 + 2*(α*β)^3`
   - `... = (α*β)^3 * ((α+β)^3 - 2*(α+β)*(α*β))`
   - `... = (α*β)^6`

3. Finish with `ring` or `ring_nf`.

**Why promising:** Over `ℂ`, commutativity is enough, and Lean’s `ring` tactics are very effective once powers are normalized. This is the best route if your immediate goal is a theorem with minimal API overhead.

---

### Strategy B: Factor pairing via reciprocal symmetry
**Conceptually sharper; reveals hidden structure.**

Observe:
\[
(1-\alpha^3X)(1-\beta^3X)=1-(\alpha^3+\beta^3)X+(\alpha\beta)^3X^2
\]
and
\[
(1-\alpha^2\beta X)(1-\alpha\beta^2X)=1-\alpha\beta(\alpha+\beta)X+(\alpha\beta)^3X^2.
\]

Then multiply these two quadratics:
- rewrite `α^3 + β^3 = (α+β)^3 - 3αβ(α+β)`,
- rewrite the middle pair coefficient as `d t`,
- multiply
  \[
  (1-(t^3-3td)X+d^3X^2)(1-dtX+d^3X^2)
  \]
  and simplify to the target formula.

**Why promising:** This reduces a 4-factor quartic expansion to a product of two structured quadratics. It makes the `e₃ = d^3 e₁` symmetry transparent and suggests the general pattern of self-reciprocal behavior up to determinant twist. This may be the best route if you want the theorem to look like representation theory rather than brute force algebra.

---

### Strategy C: Character-theoretic / λ-ring viewpoint
**Most visionary; best for follow-on `Sym^n`.**

Interpret the roots as weights of `Sym^3` applied to a 2-dimensional semisimple parameter with eigenvalues `α, β`. Then:
- the coefficient of `X` is the character `χ_{Sym^3}(α,β) = α^3+α^2β+αβ^2+β^3`,
- this equals the Schur polynomial for highest weight `3`, which for rank 2 is a universal polynomial in `t, d`,
- the remaining coefficients are elementary symmetric functions of the weights, hence also invariant under swapping `α,β`, therefore lying in `ℤ[t,d]`.

For the actual Lean proof, you will likely still instantiate this with explicit algebraic identities, but framing it this way prepares the `Sym^n` theorem and ties directly to representation theory.

**Why promising:** This is the mathematically right abstraction. Even if not the shortest proof for `n=3`, it is the route that opens the field.

---

## Recommended execution plan

1. Define:
   ```lean
   def traceParam (α β : ℂ) : ℂ := α + β
   def detParam (α β : ℂ) : ℂ := α * β
   def symmCubeEulerDen (α β X : ℂ) : ℂ :=
     (1 - α^3 * X) * (1 - α^2 * β * X) * (1 - α * β^2 * X) * (1 - β^3 * X)
   ```

2. Prove helper lemmas:
   ```lean
   lemma cube_sum_in_trace_det (α β : ℂ) :
     α^3 + β^3 = (α + β)^3 - 3 * (α + β) * (α * β) := by
     ring

   lemma symmCube_coeff1 (α β : ℂ) :
     α^3 + α^2 * β + α * β^2 + β^3 =
       (α + β)^3 - 2 * (α + β) * (α * β) := by
     ring

   lemma symmCube_coeff2 (α β : ℂ) :
     α^5*β + α^4*β^2 + 2*α^3*β^3 + α^2*β^4 + α*β^5 =
       (α * β) * (α + β)^4 - 3 * (α * β)^2 * (α + β)^2 + 2 * (α * β)^3 := by
     ring
   ```
   or, better, derive coefficient 2 from the quadratic-pair factorization to avoid ugly monomial sums.

3. Prove the main theorem with `ring_nf`.

This decomposition will minimize `sorry` and maximize reuse.

---

## Building on catalog-style theorems and likely Mathlib ingredients

Exploit any existing catalog lemmas on:
- `ring`, `ring_nf`, `noncomm_ring` simplification,
- `pow_succ`, `pow_two`, `pow_three`, `pow_four`,
- polynomial identities if you move to `Polynomial ℂ`,
- characteristic polynomial / trace / determinant identities if you push toward matrix invariance next.

If there are already catalog theorems for symmetric square formulas, imitate their packaging:
- define the local Euler factor as a product over weights,
- prove coefficient formulas as separate lemmas,
- then package the invariant dependence theorem.

In particular, if a catalog theorem already established the `Sym²` denominator as
\[
(1-\alpha^2X)(1-\alpha\beta X)(1-\beta^2X)
\]
rewritten in terms of `t` and `d`, then the `Sym³` result should explicitly cite that paradigm and generalize the **trace-det sufficiency** principle.

---

## Cross-domain connections to emphasize in the formalization

1. **Invariant theory / Galois theory**  
   The fact that the coefficients are symmetric in `α,β` means they lie in the invariant ring `ℤ[α,β]^{S₂}`. This is the concrete `GL₂` shadow of the fundamental theorem of symmetric polynomials.

2. **Representation theory**  
   The roots are weights of `Sym³(V)` for a 2-dimensional representation `V`. The coefficient of `X` is the character of `Sym³`, and the full denominator is the Euler factor of the induced representation.

3. **Automorphic forms / Langlands program**  
   The theorem certifies that local factors of symmetric-cube lifts depend only on semisimple conjugacy data. This is exactly what must hold for functorial transfers.

4. **Algorithmic number theory**  
   Once coefficients are in `ℤ[t,d]`, one can compute local factors from Hecke eigenvalues directly, without factoring characteristic polynomials over extension fields.

5. **Formal methods / certified symbolic computation**  
   This is a benchmark theorem showing Lean can certify nontrivial plethystic identities central to arithmetic geometry.

---

## Application keywords

`symmetric power L-functions`, `Langlands functoriality`, `Satake parameters`, `trace-determinant invariants`, `GL₂ representation theory`, `Schur functors`, `invariant theory`, `Euler factors`, `Hecke eigenvalues`, `formalized algebra`, `local Langlands`, `character polynomials`, `certified symbolic computation`

---

## Next theorem if this succeeds

Immediately after proving `symmCube_denominator_in_trace_det`, attack the universal statement:

```lean
def symmPowerParameter (n : ℕ) (α β : ℂ) : Fin (n+1) → ℂ :=
  fun i => α^(n - i.1) * β^(i.1)

-- informal target:
-- the product ∏ i : Fin (n+1), (1 - symmPowerParameter n α β i * X)
-- has coefficients in ℤ[α+β, α*β].
```

For `n = 3`, extract the recurrence pattern suggesting a proof via Newton identities or character recursion:
\[
\chi_{Sym^{n+1}} = t\chi_{Sym^n} - d\chi_{Sym^{n-1}}.
\]
This is the real door to the full theorem.

---

## Deliverables

1. The exact theorem `symmCube_denominator_in_trace_det`.
2. At least 2-4 helper lemmas for the coefficient identities.
3. A clean definition packaging the trace/determinant polynomial.
4. Minimal `sorry`, ideally none.
5. A structured `FUTURE_DIRECTIONS.md` containing **3–5 falsifiable hypotheses** with explicit tests.

---

## Required `FUTURE_DIRECTIONS.md`

Include **3–5 testable scientific hypotheses**, each falsifiable and with a clear test. For example:

1. **Hypothesis:** For every `n : ℕ`, the `Sym^n` Euler denominator of a rank-2 parameter has coefficients in `ℤ[t,d]`.  
   **Test:** Prove the theorem in Lean for `n = 4` and `n = 5`; if the current API blocks the general proof, isolate the obstruction precisely.

2. **Hypothesis:** The coefficient of `X` in the `Sym^n` denominator satisfies the recurrence
   \[
   a_{n+1}=t a_n - d a_{n-1}.
   \]
   **Test:** Define these coefficients in Lean and verify the recurrence for `n ≤ 6`.

3. **Hypothesis:** The full `Sym^n` Euler denominator is determined functorially by the characteristic polynomial `T^2 - tT + d` of the underlying semisimple class.  
   **Test:** Formalize equality for two pairs `(α,β)` and `(α',β')` with equal trace and determinant.

4. **Hypothesis:** For diagonalizable `2×2` complex matrices, the symmetric-cube Euler factor is conjugacy invariant and computable directly from matrix trace and determinant.  
   **Test:** Build a matrix-level theorem for diagonal matrices first, then extend via `charpoly` invariance under conjugation.

5. **Hypothesis:** The `Sym^n` coefficient polynomials coincide with rank-2 Schur / plethysm character formulas already implicit in Mathlib’s polynomial infrastructure.  
   **Test:** Identify and compare explicit formulas for `n = 3,4` with character recurrences formalized in Lean.

Push this as the opening move toward a certified theory of symmetric-power local factors. The theorem is small enough to prove now, but deep enough to reorganize the whole formalization landscape around invariant-theoretic functoriality.

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
