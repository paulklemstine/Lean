## Assignment: 2. Prime-Power Tropical PRGs and Arithmetic Sparsification

**Mode:** prove

Prove a genuinely new theorem package showing that prime-power sampling of tropical power orbits is not merely a compressed version of the full orbit, but a qualitatively better pseudorandomness mechanism because arithmetic sparsification suppresses long-range fiber correlations. The goal is to turn the vague heuristic “prime powers decorrelate” into a formal extraction theorem with a uniform-in-time error bound.

This should be treated as a field-opening bridge between tropical dynamics, arithmetic combinatorics, extractor theory, and pseudorandom generation.

---

## Core Vision

The breakthrough claim is that the subsequence
\[
G,\; G^{p},\; G^{p^2},\; \dots,\; G^{p^T}
\]
behaves more like an arithmetically lacunary process than an ordinary orbit, and that this lacunarity forces **prefix-fiber decorrelation** strong enough to replace the naive linear accumulation bound
\[
(T+1)\varepsilon
\]
by a bounded geometric series
\[
\sum_{j=0}^{T}\varepsilon_0 r^j \le \frac{\varepsilon_0}{1-r},
\qquad 0 \le r < 1,
\]
uniformly in \(T\).

If formalized cleanly, this is not just “better constants.” It opens the possibility of a new theory of **arithmetic sparsification in tropical pseudorandomness**: one can trade dense orbit access for prime-power orbit access and gain asymptotic extraction quality. That is the kind of structural theorem that creates a new subprogram.

---

## Precise Theorem Target

You should define, if not already present in the catalog, a notion of prefix extraction error along a power orbit. At minimum, formalize a sequence
\[
\operatorname{err}(j) : \mathbb{N} \to \mathbb{R}_{\ge 0}
\]
or \(\mathbb{R}\), where `err j` measures the conditional statistical distance contributed by the \(j\)-th prime-power stage.

The theorem should state that under a prime-power decorrelation hypothesis, the cumulative extraction error is uniformly bounded independently of the truncation length.

### Proposed main theorem, mathematical form

Let \(p\) be prime, let \(G\) be a tropical endomorphism/hash state evolution operator, and let `err j` denote the extraction error at stage \(p^j\). Assume:

1. `err 0 ≤ ε₀`,
2. `∀ j, err (j+1) ≤ r * err j`,
3. `0 ≤ r < 1`.

Then for every truncation length \(T\),
\[
\sum_{j=0}^{T} \operatorname{err}(j) \le \frac{\varepsilon_0}{1-r}.
\]

This should be strengthened, if possible, to an actual statistical-distance statement for the prime-power output distribution:
\[
\Delta\bigl(\mathsf{Out}_{p,T}, \mathsf{Ideal}_{p,T}\bigr)
\le \frac{\varepsilon_0}{1-r}.
\]

### Lean 4 type signature target

A first robust Lean target could be:

```lean
theorem prime_power_geometric_error_bound
    (err : ℕ → ℝ)
    (ε₀ r : ℝ)
    (herr0 : err 0 ≤ ε₀)
    (hnonneg : ∀ j, 0 ≤ err j)
    (hgeom : ∀ j, err (j + 1) ≤ r * err j)
    (hr0 : 0 ≤ r)
    (hr1 : r < 1) :
    ∀ T : ℕ, (∑ j in Finset.range (T + 1), err j) ≤ ε₀ / (1 - r)
```

But this alone is only the analytic shell. The real theorem should connect to the tropical PRG object.

A stronger aspirational signature is:

```lean
theorem tropical_prime_power_prg_error_uniform
    (G : TropicalHashState → TropicalHashState)
    (Out Ideal : ℕ → Dist TropicalOutput)
    (p T : ℕ)
    (hp : Nat.Prime p)
    (ε₀ r : ℝ)
    (hstep :
      ∀ j,
        statDist (Out (p ^ j)) (Ideal (p ^ j))
          ≤ ε₀ * r ^ j)
    (hr0 : 0 ≤ r)
    (hr1 : r < 1) :
    statDist (primePowerOrbitOutput G p T) (primePowerIdealOutput G p T)
      ≤ ε₀ / (1 - r)
```

If `Dist`, `statDist`, `primePowerOrbitOutput`, or `primePowerIdealOutput` do not yet exist in exactly this form, define the weakest abstraction that allows the theorem to be proved now and specialized later. The key is to make the theorem reusable rather than overfitted.

---

## Stronger Structural Theorem to Aim For

The truly paradigm-shifting theorem is not just a geometric-series lemma, but a **decorrelation transfer theorem**:

### Mathematical statement

Suppose a tropical power system \(G^n\) has a fiber-collision statistic \(C(n,m)\) measuring overlap of prefix fibers. Then for prime powers \(n=p^i, m=p^j\), one has
\[
C(p^i,p^j) \le C_0 \rho^{|i-j|}
\qquad \text{for some } 0<\rho<1,
\]
and consequently the extraction error along the prime-power subsequence decays geometrically.

This is the structural theorem that would justify the PRG consequence rather than merely assuming it.

### Lean target sketch

```lean
theorem prime_power_fiber_decorrelation
    (C : ℕ → ℕ → ℝ)
    (p : ℕ)
    (hp : Nat.Prime p)
    (C₀ ρ : ℝ)
    (hCnonneg : ∀ i j, 0 ≤ C i j)
    (hdecorr :
      ∀ i j : ℕ,
        C (p ^ i) (p ^ j) ≤ C₀ * ρ ^ (Nat.dist i j))
    (hρ0 : 0 ≤ ρ)
    (hρ1 : ρ < 1) :
    ∀ i j : ℕ, C (p ^ i) (p ^ j) ≤ C₀ * ρ ^ (Nat.dist i j)
```

This looks tautological as written, so the real work is to derive `hdecorr` from tropical arithmetic hypotheses. You should strengthen the assumptions until the statement becomes nontrivial but provable.

For example, define a property like:

```lean
def PrimePowerDecorrelated
    (G : TropicalHashState → TropicalHashState)
    (p : ℕ) (ρ : ℝ) : Prop := ...
```

and then prove:

```lean
theorem tropical_hash_prime_power_amplification_uniform
    (G : TropicalHashState → TropicalHashState)
    (p T : ℕ)
    (hp : Nat.Prime p)
    (ε₀ ρ : ℝ)
    (hdecorr : PrimePowerDecorrelated G p ρ)
    (hε : initialExtractionError G ≤ ε₀)
    (hρ0 : 0 ≤ ρ)
    (hρ1 : ρ < 1) :
    extractionErrorPrimePower G p T ≤ ε₀ / (1 - ρ)
```

This theorem would be the real flagship result.

---

## How to Build on Existing Verified Theorems

Use the catalog theorems as structural ingredients, not decoration.

### 1. `tropical_fundamental_theorem_of_arithmetic`
File: `Tropical/Core/TropicalFactoring.lean`

This should be used to justify why prime-power indexing is arithmetically rigid in a way general indexing is not. The conceptual move is:

- ordinary orbit indices admit many overlapping factorizations,
- prime powers have a unique valuation profile,
- therefore collisions among prefix constraints should be easier to separate by \(p\)-adic depth or valuation layer.

If the theorem gives a uniqueness/positivity factorization mechanism for tropical arithmetic, use it to define a **valuation depth** on orbit times and prove that times \(p^i\) and \(p^j\) only interact through the smaller valuation level. This is the arithmetic heart of the decorrelation heuristic.

### 2. `lipschitz_prime_power_bound`
File: `Tropical/Langlands/TropicalLanglandsGL1.lean`

This looks especially important. If it bounds growth or sensitivity along prime powers, reinterpret it as a contraction-on-observables statement. The key idea is:

- if observables along \(G^{p^j}\) are Lipschitz with a prime-power-sensitive constant,
- then conditional fiber perturbations shrink or at least do not amplify too quickly,
- so error propagation can be bounded by a multiplicative factor \(r\).

This theorem is likely the best bridge from arithmetic sparsification to geometric decay. If any existing theorem deserves to be lifted into the PRG setting, it is this one.

### 3. `tropical_security_from_norm_bound`
File: `Tropical/RieszRepresentation/Applications.lean`

This should be the final conversion theorem:
- first prove a norm bound on the discrepancy of prime-power orbit measures,
- then invoke this theorem to convert norm control into security/statistical distance control.

In other words, do not try to prove statistical distance from scratch if this theorem already certifies “norm bound implies security.”

### 4. `birthday_bound_tropical_hash`
File: `Tropical/BerggrenTropicalBridge.lean`

This can provide the baseline collision estimate for dense orbits. The research move is to show prime-power sparsification beats the birthday-style accumulation because it avoids combinatorial overcounting of correlated collisions.

A very compelling intermediate theorem would compare the two regimes directly:
\[
\text{collisionBoundPrimePower}(T) \le \text{const}
\quad\text{vs.}\quad
\text{collisionBoundDense}(T) \sim T\varepsilon.
\]

### 5. `tropical_mirror_theorem`
File: `Tropical/AlgebraicMirror.lean`

This is probably not central, but if max-idempotence simplifies tropical recurrence identities, use it to collapse redundant maxima in the fiber recursion. In a tropical proof, these simplifications often matter.

---

## Recommended Proof Strategies

You should explicitly pursue at least two paths in parallel.

### Strategy A: Analytic-geometric decay via recurrence inequalities
Most promising for immediate formalization.

1. **Define a prime-power stage error sequence** `err : ℕ → ℝ`.
   - `err j` should represent the discrepancy introduced at time `p^j`.
   - Prove `err 0 ≤ ε₀`.

2. **Derive a one-step contraction**
   \[
   \operatorname{err}(j+1) \le r \operatorname{err}(j)
   \]
   from `lipschitz_prime_power_bound` plus the tropical hash recurrence.

3. **Sum the geometric series**
   using standard Mathlib lemmas on finite geometric sums, or an induction on `T`.

4. **Transfer to security/statistical distance**
   via `tropical_security_from_norm_bound`.

Why this is promising:
- It isolates the hard arithmetic content into a local contraction lemma.
- The rest is classical analysis and should formalize cleanly.
- Even if the full PRG abstraction is not ready, the recurrence theorem itself is already publishable-formal mathematics.

### Strategy B: Arithmetic collision decomposition by \(p\)-adic valuation layers
Most conceptually deep.

1. Define a collision/fiber-overlap quantity `C n m`.
2. Use `tropical_fundamental_theorem_of_arithmetic` to stratify indices by prime-power depth.
3. Prove that collisions between levels `p^i` and `p^j` factor through the minimum valuation depth, giving a decay law in `|i-j|`.
4. Convert the off-diagonal decay of `C` into an extraction bound.

Why this matters:
- This proves the structural reason prime powers are special.
- It is the theorem that can launch a broader “arithmetic sparsification” theory.
- It connects directly to valuation theory and analytic number theory.

Why it is harder:
- Requires inventing the right collision statistic and proving a nontrivial factorization property.
- More definitions, more infrastructure.

### Strategy C: Operator-theoretic approach via transfer operators
High-risk, high-reward.

1. Model tropical evolution along prime powers as an operator sequence \( \mathcal{L}_{p^j} \).
2. Show prime-power indexing induces quasi-orthogonality or spectral contraction on a discrepancy seminorm.
3. Deduce uniform boundedness of cumulative extraction error from operator norm summability.

This is the most revolutionary formulation because it reframes tropical PRGs as a spectral theory problem. It may be too ambitious for the first pass, but even partial formalization could be transformative.

---

## Most Promising Path

**Start with Strategy A**, but architect the definitions so that Strategy B can later plug into the same theorem statement.

Concretely:
- first prove a generic theorem “geometric decay of stagewise error implies uniform PRG error,”
- then prove a separate arithmetic lemma that prime-power tropical systems satisfy the decay hypothesis.

This modularization is ideal for Lean and for research scalability.

---

## Concrete Intermediate Theorems

These are excellent subtargets.

### Theorem 1: Stagewise geometric domination
```lean
theorem prime_power_stagewise_decay
    (err : ℕ → ℝ)
    (ε₀ r : ℝ)
    (herr0 : err 0 ≤ ε₀)
    (hnonneg : ∀ j, 0 ≤ err j)
    (hgeom : ∀ j, err (j + 1) ≤ r * err j)
    (hr0 : 0 ≤ r) :
    ∀ j, err j ≤ ε₀ * r ^ j
```

This should be an induction on `j`.

### Theorem 2: Uniform bounded cumulative error
```lean
theorem prime_power_cumulative_error_bounded
    (err : ℕ → ℝ)
    (ε₀ r : ℝ)
    (hstage : ∀ j, 0 ≤ err j ∧ err j ≤ ε₀ * r ^ j)
    (hr0 : 0 ≤ r)
    (hr1 : r < 1) :
    ∀ T, (∑ j in Finset.range (T + 1), err j) ≤ ε₀ / (1 - r)
```

### Theorem 3: Tropical PRG uniformity from prime-power decay
```lean
theorem tropical_prime_power_prg_uniform_security
    {α : Type*}
    (μ ν : ℕ → Measure α)
    (ε₀ r : ℝ)
    (hstep : ∀ j, statDist (μ j) (ν j) ≤ ε₀ * r ^ j)
    (hr0 : 0 ≤ r)
    (hr1 : r < 1) :
    ∀ T, statDist (primePowerPrefix μ T) (primePowerPrefix ν T) ≤ ε₀ / (1 - r)
```

Even if `Measure` is too heavy, replace it with the catalog’s actual distribution type.

---

## Cross-Domain Connections You Should Exploit

### Analytic number theory
Prime-power lacunarity is analogous to sparse subsequences in exponential sums and almost-orthogonality phenomena. The theorem should be framed as a tropical analogue of the principle that arithmetic sparsity reduces correlation.

### \(p\)-adic dynamics
The index set \(p^j\) is naturally valuation-stratified. This suggests a deep analogy: tropical orbit extraction along prime powers may behave like a non-Archimedean filtration where deeper levels become conditionally independent.

### Additive combinatorics
Dense index sets create many additive/multiplicative coincidences; lacunary sets suppress them. Your theorem can be sold as a tropical pseudorandomness version of “structured thinning destroys collision multiplicity.”

### Spectral theory / transfer operators
If the prime-power map acts contractively on discrepancy observables, then the PRG theorem is really a spectral gap theorem in disguise.

### Complexity theory
If output length \(p^T\) can be supported from logarithmic seed length with a uniform-in-\(T\) error bound, this is a pseudorandom generator paradigm rather than an extractor estimate. It suggests tropical arithmetic as a source of explicit derandomization primitives.

### Information theory
The theorem says sparse arithmetic sampling reduces accumulated distinguishability. That is an information dissipation statement and may lead to tropical analogues of strong data-processing inequalities.

---

## Why This Would Be a Breakthrough

A successful theorem here would found a new principle:

> **Arithmetic sparsification improves tropical pseudorandomness.**

That is much stronger than “a certain construction has better parameters.” It says there is a mechanism — prime-power thinning — that systematically converts arithmetic structure into decorrelation and security.

This could open:
- tropical extractor theory with valuation-aware sampling,
- tropical PRG constructions based on sparse orbits,
- non-Archimedean pseudorandomness,
- arithmetic-spectral methods for tropical dynamics,
- new bridges between Langlands-flavored tropical harmonic analysis and derandomization.

The most exciting downstream possibility is that prime-power indexing is only the first case, and the true general theory concerns **valuation-separated subsequences** or **multiplicatively Sidon index sets**.

---

## Formalization Guidance in Lean 4

1. **Do not overcommit to a complicated probability API too early.**
   If needed, first formalize everything with an abstract discrepancy function:
   ```lean
   variable (δ : ℕ → ℝ)
   ```
   and only later instantiate `δ j := statDist ...`.

2. **Separate arithmetic lemmas from analytic summation lemmas.**
   You want reusable files:
   - one for prime-power recurrence/valuation structure,
   - one for geometric decay summation,
   - one for PRG/security corollaries.

3. **Search Mathlib first for geometric sum lemmas**
   around `GeomSum`, `Finset.sum_geometric`, powers, and inequalities over `ℝ`.

4. **Minimize sorry by proving generic lemmas first.**
   The generic geometric-bound theorem is low-risk and gives immediate traction.

5. **If the full theorem is blocked on definitions, create a robust abstraction layer.**
   For example:
   ```lean
   def GeometricallyDecayingError (err : ℕ → ℝ) (ε₀ r : ℝ) : Prop := ...
   ```

---

## Suggested File-Level Deliverable

A strong implementation path would be to add a new file such as:

```text
Tropical/PRG/PrimePowerAmplification.lean
```

with theorems in this order:
1. `prime_power_stagewise_decay`
2. `prime_power_geometric_error_bound`
3. `tropical_prime_power_prg_error_uniform`
4. if possible, `prime_power_fiber_decorrelation`

---

## Application Keywords

tropical pseudorandom generators, arithmetic sparsification, prime-power subsequences, valuation-theoretic decorrelation, tropical extractors, statistical distance, geometric decay, collision suppression, lacunary dynamics, non-Archimedean pseudorandomness, transfer operators, additive combinatorics, analytic number theory, complexity theory, derandomization, information dissipation

---

## Minimum Success Criterion

At minimum, prove a clean formal theorem of the shape:

```lean
theorem prime_power_geometric_error_bound ...
```

and connect it nontrivially to at least one catalog theorem, preferably `lipschitz_prime_power_bound` or `tropical_security_from_norm_bound`.

## Maximum Success Criterion

Prove a new structural theorem showing that prime-power orbit indices induce exponentially decaying fiber correlation, and derive from it a uniform-in-\(T\) tropical PRG security theorem.

---

## Required FUTURE_DIRECTIONS.md

You must produce a structured `FUTURE_DIRECTIONS.md` with 3–5 concrete next steps at breakthrough level. Include items of the following form:

1. Extend prime-power sparsification to multiplicatively Sidon index sets.
2. Prove a tropical strong data-processing inequality from decorrelation.
3. Develop a spectral-gap formulation of tropical PRGs via transfer operators.
4. Generalize from GL\(_1\)-type prime-power bounds to higher-rank tropical Hecke dynamics.
5. Connect valuation-layer decorrelation to explicit derandomization complexity bounds.

Make these specific, theorem-oriented, and ambitious.

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

Research domain: Tropical
Research mode: prove
