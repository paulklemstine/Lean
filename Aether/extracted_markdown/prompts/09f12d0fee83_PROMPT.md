## Assignment: We have formally verified:

Prove new, non-trivial theorems. Build on catalog theorems. Minimize sorry.

### Research Direction
# Future Directions: Perfect Cuboid Euler Product Sieve

## Summary of Established Results

We have formally verified:
- **CRT multiplicativity**: `survivorCount(m·n) = survivorCount(m) · survivorCount(n)` for coprime `m, n`.
- **Certified prime counts**: Exact survivor counts at primes `2, 3, 5, 7, 11, 13` (with computational verification through `31`).
- **Mod-105 factorization**: `survivorCount(105) = 7 × 37 × 55 = 14,245`, density ≈ `1.23%`.
- **Mod-1155 factorization**: `survivorCount(1155) = 7 × 37 × 55 × 151 = 2,150,995`, density ≈ `0.14%`.
- **Density product formula**: The mod-1155 density equals the product of local densities at `3, 5, 7, 11`.
- **Bridge theorem**: Any integer perfect cuboid reduces to a cuboid survivor modulo every `n`.
- **Quartic fiber reduction**: The cuboid surface equation reduces to  
  `W² = r²s⁴ + (r⁴+1)s² + r²` under Pythagorean parametrization.
- **Quartic factorization**:  
  `W² = (r²s² + 1)(s² + r²)`, revealing product-of-quadratics structure.

---

## Visionary Target Theorem

The next breakthrough should not be another finite computation. It should be a **structural local obstruction theorem** converting the cuboid problem into a genuine Euler-product sieve with provable decay. The factorization
\[
W^2=(r^2s^2+1)(s^2+r^2)
\]
is the key: it turns the perfect cuboid condition into a coupled quadratic-character problem over finite fields. This is exactly the interface between Diophantine geometry, character sums, and probabilistic local-global heuristics.

### Main theorem to formalize and prove

For odd primes `p`, let `survivorCount p` count residue classes of cuboid parameters modulo `p` surviving all square constraints. Prove a theorem of the following shape:

\[
\exists \delta > 0,\ \forall p \text{ prime},\ p \ge 3 \to survivorCount(p) \le (1-\delta)p^3.
\]

A concrete ambitious target is `δ = 7/10`, but the real breakthrough is any explicit uniform `δ > 0`.

### Lean 4 type signature target

You should aim for a theorem as close as possible to:

```lean
theorem survivorCount_prime_uniform_gap :
  ∃ δ : ℚ, 0 < δ ∧
    ∀ p : ℕ, Nat.Prime p → 3 ≤ p →
      (survivorCount p : ℚ) ≤ (1 - δ) * p^3
```

If coercions become awkward, a more implementation-friendly version is:

```lean
theorem survivorCount_prime_uniform_gap_rat :
  ∃ δ : ℚ, 0 < δ ∧
    ∀ p : ℕ, Nat.Prime p → 3 ≤ p →
      ((survivorCount p : ℚ) / p^3) ≤ 1 - δ
```

And if the full theorem is too far in one cycle, prove a decisive intermediate theorem that isolates the character-sum geometry:

```lean
theorem quarticFiber_survivor_bound_prime :
  ∃ δ : ℚ, 0 < δ ∧
    ∀ p : ℕ, Nat.Prime p → 3 ≤ p →
      let S := {x : (ZMod p)^3 // CuboidSurvivorPred p x}
      ((Fintype.card S : ℚ) / p^3) ≤ 1 - δ
```

This is not merely a bound. It would be the first formal theorem showing that the perfect cuboid local conditions impose a **uniform entropy loss at every odd prime**.

---

## Stronger asymptotic theorem to pursue if the uniform gap lands

The true field-opening statement is an asymptotic local density law:

\[
\exists C \in \mathbb{R},\ \forall \varepsilon > 0,\ \exists P,\ \forall p \ge P,\ p\ \text{prime} \to
\left| \frac{survivorCount(p)}{p^3} - C \right| \le \varepsilon.
\]

A more arithmetic version:

\[
survivorCount(p)=Cp^3+O(p^{5/2})
\]
for primes `p`, where `C` is determined by quadratic-character averages attached to the two factors
\[
r^2s^2+1,\qquad s^2+r^2.
\]

### Lean 4 formalization target

You may not formalize full analytic asymptotics in one pass, but you can formalize the finite-field identity from which the asymptotic emerges:

```lean
theorem survivorCount_prime_character_decomposition
  (p : ℕ) [Fact (Nat.Prime p)] (hp : 3 ≤ p) :
  ∃ mainTerm error : ℚ,
    (survivorCount p : ℚ) = mainTerm + error ∧
    |error| ≤ p^(5/2 : ℚ)
```

If `p^(5/2)` is awkward in Lean, replace by a weaker but still revolutionary algebraic-combinatorial form:

```lean
theorem survivorCount_prime_main_error_split
  (p : ℕ) [Fact (Nat.Prime p)] (hp : 3 ≤ p) :
  ∃ M E : ℤ,
    survivorCount p = M + E ∧
    |E| ≤ p^3 ∧
    -- M is defined by explicit quadratic-character averages
    True
```

The point is to force the local density into an explicit **character-sum decomposition** that can later support asymptotic analysis.

---

## Why this is a breakthrough

If you prove a uniform prime-local density gap, then combined with CRT multiplicativity you obtain:

\[
\frac{survivorCount(N)}{N^3}
= \prod_{p\mid N}\frac{survivorCount(p)}{p^3}
\le \prod_{p\mid N}(1-\delta).
\]

As `N` ranges over primorials, this tends to `0` exponentially in `π(N)`. This would create the first formally verified **Euler-product sieve heuristic** against perfect cuboids. Not a proof of nonexistence — something more interesting: a rigorous local obstruction machine that makes the global conjecture quantitatively believable.

This opens:
- formal Diophantine sieves in Lean,
- finite-field obstruction theory for rational points,
- certified arithmetic statistics for elusive Diophantine varieties,
- a template for attacking other “ancient impossible object” problems.

---

## Precise intermediate theorem: character expansion of square indicators

The quartic factorization suggests the exact local square constraints can be rewritten using the quadratic character `χ_p`. Over `𝔽_p`, for odd `p`, the square-indicator satisfies
\[
1_{\square}(a)=\frac{1+\chi_p(a)}{2}
\]
away from zero, with a corrected formula at zero. The cuboid survivor condition is therefore a finite combination of products of character evaluations of quadratic polynomials in `(r,s,...)`.

### Formal target

Introduce a finite-field square-indicator and prove a decomposition theorem.

```lean
def squareIndicator {p : ℕ} [Fact (Nat.Prime p)] (x : ZMod p) : ℚ := ...

theorem squareIndicator_eq_char_formula
  (p : ℕ) [Fact (Nat.Prime p)] (hp : 3 ≤ p) :
  ∀ x : ZMod p,
    squareIndicator x =
      ((1 : ℚ) + quadChar p x + zeroCorrection p x) / 2
```

Then derive:

```lean
theorem cuboidSurvivorPred_expands_to_character_sum
  (p : ℕ) [Fact (Nat.Prime p)] (hp : 3 ≤ p) :
  ∃ terms : Finset (((ZMod p)^3) → ℚ),
    ∀ x, indicator (CuboidSurvivorPred p x) =
      ∑ f in terms, f x
```

This theorem would be the formal bridge from Diophantine constraints to harmonic analysis on finite fields.

---

## Proof strategy architecture

### Strategy A: Direct finite-field character expansion + cancellation
**Most promising.**

1. **Rewrite every square condition as a quadratic-character indicator.**  
   Use the quartic factorization
   \[
   W^2=(r^2s^2+1)(s^2+r^2)
   \]
   to express survival as conjunctions of “is square” predicates on explicit polynomials.

2. **Expand the conjunction into a finite linear combination of character sums.**  
   The main term comes from the constant contribution; the nontrivial terms are sums like
   \[
   \sum_{r,s} \chi(f(r,s)),\qquad \sum_{r,s,t}\chi(f(r,s,t))\chi(g(r,s,t)).
   \]

3. **Show at least one nonconstant term contributes a negative average or that the main term is strictly below `1`.**  
   For a first theorem, you do not need sharp Weil bounds. It may suffice to prove that the zero-loci and nonsquare fibers occupy a uniform positive proportion, forcing a gap.

Why this is best: it directly exploits your verified quartic factorization and naturally interfaces with Lean’s finite sum machinery.

---

### Strategy B: Fiberwise geometry over `𝔽_p`
1. **Fix one parameter and study fibers of the quartic surface.**  
   For each `r`, analyze
   \[
   W^2=(r^2s^2+1)(s^2+r^2)
   \]
   as a genus-1 or hyperelliptic-type fiber over `s`.

2. **Classify degenerate fibers and show they are sparse.**  
   Away from a bounded exceptional set in `r`, the polynomial in `s²` is non-square and has controlled value distribution.

3. **Average over fibers to obtain a global density bound.**

Why it matters: this reveals the cuboid surface as a family of finite-field curves, connecting local cuboid sieves to arithmetic geometry. This strategy may yield stronger constants and explain observed oscillations in densities by residue class of `p`.

---

### Strategy C: Combinatorial incidence bound via paired square constraints
1. **Forget exact asymptotics; prove incompatible square conditions force entropy loss.**
2. **Show the two factors**
   \[
   r^2s^2+1,\qquad s^2+r^2
   \]
   cannot both land in square classes too often unless `(r,s)` lies in a structured exceptional set.
3. **Bound the exceptional set explicitly and deduce a uniform `δ`.**

Why this is useful: if character machinery in Lean becomes too heavy, this route may still deliver the uniform gap theorem using only counting, residue classes, and finite-field algebra.

---

## Cross-domain connections you should exploit

### 1. Arithmetic statistics / Ekedahl-sieve philosophy
The theorem is an instance of a general principle: a global Diophantine object can be suppressed by a product of local densities. Formalizing this for perfect cuboids could seed a Lean library for **arithmetic statistics of varieties**.

### 2. Finite-field harmonic analysis
The square-indicator/character expansion is a finite-field Fourier analysis problem in disguise. The cuboid survivor density is a low-complexity correlation of multiplicative characters of quadratic forms. This connects your work to:
- Weil bounds,
- Deligne-style square-root cancellation heuristics,
- additive combinatorics over finite fields.

### 3. Algebraic geometry of surfaces
The quartic factorization turns the cuboid surface into a family whose local fibers are controlled by the arithmetic of a reducible norm-form-type expression. This suggests a bridge to:
- rational points on conic bundles,
- Brauer-Manin-style local obstructions,
- certified local solubility profiles of algebraic surfaces.

### 4. Statistical mechanics / entropy language
The local density gap is an **entropy defect per prime**. CRT multiplicativity then converts local entropy loss into global exponential suppression. This is exactly the same mathematical architecture as partition-function decay in statistical mechanics. Formalizing this analogy could inspire a general Lean theory of multiplicative constraint systems.

### 5. Complexity-theoretic viewpoint
`survivorCount(p)` measures the acceptance rate of a finite algebraic constraint system. A uniform gap theorem says the cuboid predicate is a low-density language modulo every prime. This invites connections to:
- algebraic pseudorandomness,
- CSP density decay,
- certified average-case hardness for arithmetic predicates.

---

## Concrete theorem ladder

Do not jump directly to the final asymptotic. Build a staircase.

### Stage 1: Exact algebraic decomposition
Prove a formal expansion of the survivor predicate into square indicators / character terms.

```lean
theorem survivor_indicator_explicit_expansion :
  ∀ p : ℕ, Nat.Prime p → 3 ≤ p →
  ∃ F : Finset (((ZMod p)^3) → ℚ),
    ∀ x, survivorIndicator p x = ∑ f in F, f x
```

### Stage 2: Nontrivial upper bound below `1`
Prove a universal constant `c < 1` such that for all odd primes,
\[
survivorCount(p) \le c p^3.
\]

```lean
theorem survivorCount_prime_density_lt_one :
  ∃ c : ℚ, c < 1 ∧
    ∀ p : ℕ, Nat.Prime p → 3 ≤ p →
      (survivorCount p : ℚ) ≤ c * p^3
```

### Stage 3: Multiplicative decay on squarefree moduli
Combine with CRT multiplicativity.

```lean
theorem survivorDensity_squarefree_decay :
  ∃ c : ℚ, 0 < c ∧ c < 1 ∧
    ∀ n : ℕ, Squarefree n →
      ((survivorCount n : ℚ) / n^3) ≤ c ^ (Nat.cardFactors n)
```

This is already a publishable formal insight: every added prime divisor kills a fixed proportion of survivors.

### Stage 4: Primorial extinction
Deduce decay along primorials.

```lean
theorem survivorDensity_primorial_tendsto_zero :
  Tendsto
    (fun k : ℕ => ((survivorCount (primorial k) : ℚ) / (primorial k)^3))
    atTop
    (𝓝 0)
```

This would be a landmark theorem: a fully formal Euler-product extinction law for perfect cuboid local survivors.

---

## Specific build-on points from the catalog

Use the existing certified results as anchors, not endpoints.

- **From CRT multiplicativity**: upgrade exact factorization on coprime moduli into an abstract multiplicative-density framework.
- **From the mod-105 and mod-1155 factorizations**: extract the conceptual lesson that local densities already behave independently enough to support an Euler-product law.
- **From the bridge theorem**: immediately convert any global perfect cuboid into membership in every local survivor set, so every local density theorem becomes global negative evidence.
- **From quartic fiber reduction and factorization**: this is the crucial new engine. The factorization is not just simplification; it exposes the finite-field square-class geometry.

---

## What to watch for mathematically

1. **Zero values of the factors**  
   The formula `1_square(a) = (1 + χ(a))/2` fails at `a = 0` without correction. You must isolate the zero locus carefully. This is likely a low-dimensional exceptional set and should not affect the density main term.

2. **Dependence between the two factors**  
   They are not independent Bernoulli variables. The theorem will come from proving enough non-independence in the “bad” direction, or from showing the structured coincidence set is too small.

3. **Prime splitting behavior**
   Expect density variation depending on `p mod 4` or finer residue data. This is not a nuisance; it may reveal the constant `C` in the asymptotic formula as an average over Frobenius classes.

4. **Exceptional small primes**
   Handle `p = 2` separately and maybe `p = 3, 5` by computation. State the structural theorem for `p ≥ 7` if needed, then patch small cases by `native_decide`.

---

## Application keywords

perfect cuboid, Euler product sieve, local-global obstruction, finite-field character sums, quadratic residues, arithmetic statistics, conic bundles, Diophantine geometry, CRT multiplicativity, entropy decay, formalized number theory, Lean 4, Mathlib, certified asymptotics, algebraic surfaces, local density, square-class correlation, arithmetic pseudorandomness

---

## Deliverables

1. **A Lean theorem file** proving at least one structural local density theorem, ideally `survivorCount_prime_uniform_gap`.
2. **A decomposition file** expressing the cuboid survivor predicate via square indicators or character sums.
3. **A primorial-decay corollary** combining the new theorem with CRT multiplicativity.
4. **Minimal sorry**: computational lemmas may use `native_decide`, but the central structural theorem should be genuinely proved.

---

## Required FUTURE_DIRECTIONS.md

You must also produce a structured `FUTURE_DIRECTIONS.md` with **3–5 falsifiable scientific hypotheses**, each with:
- a precise conjecture,
- a clear computational or formal test,
- what it would mean if true,
- what it would mean if false.

At least these hypotheses should be included in sharpened form:

### Hypothesis 1: Uniform prime density gap
There exists explicit `δ > 0` such that for all odd primes `p`,
\[
\frac{survivorCount(p)}{p^3} \le 1-\delta.
\]
**Test:** certify all primes up to a bound and prove a symbolic theorem for all sufficiently large primes, or find a counterexample.

### Hypothesis 2: Prime-density limit
There exists `C ∈ (0,1)` such that
\[
\frac{survivorCount(p)}{p^3} \to C
\]
as `p → ∞` through primes.
**Test:** compute certified densities for primes up to at least `1000`; fit candidate constants by congruence classes; compare with the character-sum main term.

### Hypothesis 3: Congruence-class fluctuation law
There exist constants `C_a` indexed by residue classes `a mod m` such that
\[
\frac{survivorCount(p)}{p^3} \to C_a
\quad\text{for primes } p \equiv a \pmod m.
\]
**Test:** stratify prime data by `p mod 4`, `p mod 8`, `p mod 12`, etc. A stable split would indicate Frobenius-sensitive local geometry.

### Hypothesis 4: Squarefree exponential suppression
For squarefree `n`,
\[
\frac{survivorCount(n)}{n^3} \le \exp(-c\,\omega(n))
\]
for some `c > 0`.
**Test:** verify on products of the first `k` odd primes and compare against the product of certified local densities.

### Hypothesis 5: Character-sum error term
There exists `A > 0` such that
\[
\left|survivorCount(p)-Cp^3\right| \le A p^{5/2}
\]
for all odd primes `p`.
**Test:** compute residuals numerically and compare against `p^{5/2}` scaling; if false, search for a weaker exponent and identify geometric degeneracies.

This is the moment to convert perfect cuboids from an isolated Diophantine curiosity into a formally verified theory of local density extinction.

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
