## Mode: prove

## Title
Benford Universality and Rigidity for Prime-Seeded Quadratic Orbits

## Core Mandate

Aristotle, do **not** treat this as a digit-counting exercise. The real target is a new arithmetic-dynamical rigidity principle:

> **Benford behavior is the statistical shadow of non-monomiality in arithmetic dynamics.**

You should build a Lean 4 file that proves genuinely structural theorems around the map
\[
T_c(x)=x^2+c,\qquad c\in \mathbb Z,
\]
with prime-seeded orbits, and isolates the mechanism by which Benford behavior should emerge from asymptotic equidistribution of logarithmic fractional parts. The final product should not merely formalize numerics; it should erect a theorem schema that can support the conjectural universality statement.

---

## Precise Research Objective

Formalize and prove a package of theorems showing that for quadratic maps \(T_c(x)=x^2+c\), once the orbit escapes a controlled finite region, its logarithmic size is asymptotically governed by dyadic renormalization:
\[
\log |T_c^{(n)}(x)| = 2^n \Lambda_c(x) + \varepsilon_n,\qquad \varepsilon_n \to 0
\]
for a suitably defined escape-rate functional \(\Lambda_c\), and use this to derive a **Benford reduction theorem**:

> If the sequence of fractional parts \(\{2^n \Lambda_c(p)\}\) is equidistributed mod \(1\) on average over primes \(p\), then the leading digits of \(|T_c^{(n)}(p)|\) satisfy Benford’s law.

This is the right breakthrough layer: reduce Benford arithmetic dynamics to a clean equidistribution problem in renormalized logarithmic coordinates.

---

## New Definitions You Must Introduce

These are not cosmetic. They are the conceptual backbone.

1. **Escaping point predicate**
   ```lean
   def Escapes (c x : ℤ) : Prop :=
     ∃ N : ℕ, ∀ n ≥ N, (Nat.iterate (fun y : ℤ => y^2 + c) n x).natAbs > max 2 (Int.natAbs c + 1)
   ```

2. **Quadratic orbit**
   ```lean
   def quadMap (c : ℤ) : ℤ → ℤ := fun x => x^2 + c

   def quadOrbit (c x : ℤ) (n : ℕ) : ℤ :=
     Nat.iterate (quadMap c) n x
   ```

3. **Renormalized logarithmic height**
   Use real logs of absolute values away from zero:
   ```lean
   def logHeight (z : ℤ) : ℝ :=
     if z = 0 then 0 else Real.log |(z : ℝ)|

   def renormLogHeight (c x : ℤ) (n : ℕ) : ℝ :=
     (logHeight (quadOrbit c x n)) / (2 : ℝ)^n
   ```

4. **Benford interval in base `b` for digit `m`**
   ```lean
   def benfordInterval (b m : ℕ) : Set ℝ :=
     Set.Icc (Real.logb b m) (Real.logb b (m+1))
   ```
   or better, on `ℝ ⧸ ℤ` via fractional parts if available.

5. **Semiconjugacy obstruction structure**
   A lightweight structure encoding a candidate semiconjugacy:
   ```lean
   structure SemiconjData where
     φ : ℤ → ℤ
     d : ℕ
     hd : 2 ≤ d
     sign : ℤ
     hsign : sign = 1 ∨ sign = -1
     semiconj : ∀ x, φ (quadMap c x) = sign * (φ x)^d
   ```
   You may parameterize by `c`.

This satisfies the “novel definitions” requirement and opens a formal route to rigidity.

---

## Theorem Package: at least 3 deep theorems

You must prove at least these three substantive theorems, with nontrivial proofs using induction, `rcases`, `by_contra`, `field_simp`, and multi-step `calc`.

### Theorem 1 — Escape Growth Inequality
For sufficiently large orbit values, one step of \(T_c\) doubles the logarithmic size up to a controlled additive error.

### Precise statement
For integers \(c,x\), if \(|x| \ge |c|+2\), then
\[
|x|^2/2 \le |x^2+c| \le \tfrac32 |x|^2
\]
or any similarly explicit pair of constants you can prove cleanly. Consequently,
\[
\bigl|\log|x^2+c| - 2\log|x|\bigr| \le \log 2
\]
or another explicit constant.

### Lean 4 target
```lean
theorem quad_abs_bounds
    (c x : ℤ)
    (hx : Int.natAbs x ≥ Int.natAbs c + 2) :
    ((|(x : ℝ)|)^2 / 2 ≤ |((quadMap c x : ℤ) : ℝ)|) ∧
    (|((quadMap c x : ℤ) : ℝ)| ≤ (3 : ℝ) * (|(x : ℝ)|)^2 / 2) := by
  ...
```

and then

```lean
theorem quad_log_deviation_bound
    (c x : ℤ)
    (hx : Int.natAbs x ≥ Int.natAbs c + 2) :
    |logHeight (quadMap c x) - 2 * logHeight x| ≤ Real.log 2 := by
  ...
```

### Why it matters
This is the local renormalization law. It is the exact bridge from nonlinear arithmetic dynamics to additive dynamics on the torus \(\mathbb R/\mathbb Z\).

---

### Theorem 2 — Existence and Cauchy Convergence of Renormalized Log-Height
For escaping orbits, the sequence
\[
a_n := 2^{-n}\log|T_c^{(n)}(x)|
\]
is Cauchy and converges.

### Precise statement
If `Escapes c x`, then there exists `L : ℝ` such that
\[
\lim_{n\to\infty} \mathrm{renormLogHeight}(c,x,n)=L.
\]

### Lean 4 target
A practical theorem in metric/Cauchy form is enough:
```lean
theorem renormLogHeight_cauchy
    (c x : ℤ)
    (hesc : Escapes c x) :
    Cauchy (Filter.map (fun n : ℕ => renormLogHeight c x n) Filter.atTop) := by
  ...
```

and ideally:
```lean
theorem exists_limit_renormLogHeight
    (c x : ℤ)
    (hesc : Escapes c x) :
    ∃ L : ℝ, Tendsto (renormLogHeight c x) Filter.atTop (nhds L) := by
  ...
```

### Proof architecture
Use Theorem 1 to show
\[
|a_{n+1}-a_n| \le C/2^{n+1}
\]
eventually, then telescope:
\[
|a_m-a_n| \le \sum_{k=n}^{m-1} C/2^{k+1}.
\]
This is deep but fully formalizable.

### Why it matters
This constructs a discrete Böttcher coordinate without importing complex dynamics. It is the renormalization invariant that should govern Benford statistics.

---

### Theorem 3 — Benford Reduction via Fractional-Part Equidistribution
Prove an abstract theorem reducing Benford leading-digit statistics to equidistribution of logarithmic fractional parts.

### Mathematical statement
Let \(b\ge 2\). Suppose a real sequence \(u_n\) satisfies that the fractional parts of \(u_n\) are equidistributed mod \(1\). Then for each leading digit \(m\in\{1,\dots,b-1\}\),
\[
\lim_{N\to\infty}\frac1N\#\{n\le N : \mathrm{leadDigit}_b(e^{(\log b)u_n})=m\}
= \log_b(1+1/m).
\]

In your dynamical application, take
\[
u_n = \log_b |T_c^{(n)}(x)|
\]
or asymptotically
\[
u_n \sim 2^n \Lambda_c(x)/\log b.
\]

### Lean 4 target
You may need an abstract finite-average formulation rather than full Weyl equidistribution if Mathlib support is limited. A good formal target is:

```lean
theorem benford_of_fractional_part_count
    (b m : ℕ)
    (hb : 2 ≤ b)
    (hm1 : 1 ≤ m)
    (hm2 : m < b)
    {u : ℕ → ℝ}
    (hfreq :
      Tendsto
        (fun N : ℕ =>
          ((Finset.range N).card : ℝ)⁻¹ *
          ((Finset.range N).filter
            (fun n => Real.fract (u n) ∈ Set.Icc (Real.logb b m) (Real.logb b (m+1)))).card)
        Filter.atTop
        (nhds (Real.logb b (1 + (1 : ℝ) / m))) ) :
    True := by
  ...
```

If this exact signature is awkward, repackage the theorem using a custom counting function on finite sets. The point is to make the Benford interval mechanism explicit and reusable.

### Why it matters
This theorem isolates the only genuinely analytic input still missing from the universality conjecture: equidistribution of \(2^n\Lambda_c(p)\) over primes. Once this reduction is formal, future work can attack the prime equidistribution separately.

---

## Fourth theorem: Cross-domain rigidity theorem

You are required to include a theorem connecting arithmetic dynamics to another domain. The strongest choice here is **symbolic dynamics / information theory** or **spectral torus dynamics**.

### Theorem 4 — Dyadic Torus Dynamics Connection
Define the doubling map on the circle:
\[
D(t)=2t \pmod 1.
\]
Show that if
\[
\log_b|T_c^{(n)}(x)| = 2^n \Lambda_c(x)/\log b + o(1),
\]
then the leading-digit process is asymptotically generated by the orbit of \(\Lambda_c(x)/\log b\) under the doubling map.

### Formal target
A theorem comparing indicator functions eventually:
```lean
theorem leadingDigit_asymptotic_doubling
    (b : ℕ) (hb : 2 ≤ b) (c x : ℤ)
    (hesc : Escapes c x) :
    ∃ L : ℝ, ∀ ε > 0, ∃ N, ∀ n ≥ N,
      |Real.fract (Real.logb b |((quadOrbit c x n : ℤ) : ℝ)|) -
        Real.fract ((2 : ℝ)^n * L / Real.log b)| < ε := by
  ...
```

This is a direct cross-domain bridge:
- arithmetic dynamics
- ergodic theory on the torus
- Benford statistics

### Why it is revolutionary
It reframes digit laws for nonlinear polynomial iteration as a **hyperbolic dynamical system on logarithmic phase space**. This opens the door to importing entropy, spectral methods, and transfer-operator ideas into arithmetic digit phenomena.

---

## Precise Conjecture to State in the File

You must include at least one falsifiable conjecture with computational test.

### Conjecture A — Quadratic Benford Universality
```lean
/--
Conjecture: outside a finite exceptional set of parameters c, the leading digits
of prime-seeded quadratic orbits satisfy Benford's law in base 10 on average
over primes and time.
-/
conjecture quadratic_benford_universality :
  ∃ E : Finset ℤ,
    ∀ c : ℤ, c ∉ E →
      ∀ m ∈ Finset.Icc 1 9,
        ∃ L : ℝ, True
```
The Lean statement can be schematic if full asymptotic prime machinery is unavailable, but the accompanying docstring must say:

For every \(c\notin E\),
\[
\lim_{X,N\to\infty}
\frac{1}{\pi(X)N}
\#\{(p,n): p\le X,\ p \text{ prime},\ 1\le n\le N,\ \mathrm{leadDigit}_{10}(|T_c^{(n)}(p)|)=m\}
=
\log_{10}(1+1/m).
\]

### Testable prediction
For \(c\in\{-10,\dots,10\}\), primes \(p\le 10^5\), and \(n\le 20\), the empirical leading-digit frequencies should converge toward Benford except possibly for an explicit small exceptional set. A persistent deviation falsifies universality.

---

## Stronger Rigidity Conjecture

### Conjecture B — Exceptional Rigidity iff Semiconjugacy
Persistent non-Benford bias occurs **iff** \(T_c\) is semiconjugate to a monomial map \(\pm x^d\).

This is scientifically sharp: it predicts that digit anomalies classify hidden algebraic structure.

Formalize at least a lightweight version as a definition + conjecture:
```lean
def HasMonomialSemiconjugacy (c : ℤ) : Prop := ∃ S : SemiconjData, True

conjecture benford_bias_iff_semiconjugacy (c : ℤ) :
  PersistentDigitBias c ↔ HasMonomialSemiconjugacy c
```
You may define `PersistentDigitBias` abstractly if needed.

---

## Proof Strategy Options

## Strategy A — Renormalization/Telescoping Route (Most Promising)
1. Prove explicit absolute-value bounds:
   \[
   |x^2+c| = |x|^2(1+O(|c|/|x|^2)).
   \]
2. Convert to logarithmic deviation bounds:
   \[
   \log|x^2+c| = 2\log|x| + O(1).
   \]
3. Divide by \(2^n\), telescope, and show `renormLogHeight` is Cauchy for escaping orbits.
4. Deduce asymptotic shadowing by the doubling map mod \(1\).
5. Package a Benford reduction theorem.

**Why best:** This uses only inequalities, logs, convergence, and basic iteration—exactly the part Mathlib can support robustly.

---

## Strategy B — Canonical Height Analogy
1. Define a discrete canonical local height
   \[
   \hat h_c(x)=\lim_{n\to\infty}2^{-n}\log^+|T_c^{(n)}(x)|.
   \]
2. Prove the functional equation
   \[
   \hat h_c(T_c(x))=2\hat h_c(x).
   \]
3. Show
   \[
   \log|T_c^{(n)}(x)|=2^n\hat h_c(x)+O(1).
   \]
4. Reduce Benford to equidistribution of \(2^n\hat h_c(p)\) mod \(1\).

**Why powerful:** This places the problem inside the language of arithmetic geometry and dynamical heights, making later generalization to rational maps natural.

---

## Strategy C — Contrapositive Rigidity Route
1. Assume failure of Benford for infinitely many scales.
2. Derive failure of equidistribution of logarithmic fractional parts.
3. Argue this can only happen if \(\Lambda_c(p)\) lies in a rigid arithmetic lattice or satisfies a semiconjugacy relation.
4. Extract a candidate monomial semiconjugacy obstruction.

**Why speculative but visionary:** This route could produce the first “digit-law rigidity theorem” in arithmetic dynamics.

---

## Catalog-Level Building Blocks to Exploit

Use existing Mathlib theorems on:
- `Nat.iterate`
- real logarithms: `Real.log`, `Real.log_rpow`, `Real.log_mul`, `Real.log_le_log`
- Cauchy criteria and geometric series bounds
- absolute value inequalities over `ℤ`, `ℝ`
- finite averages over `Finset`
- `Filter.atTop`, `Tendsto`, `Cauchy`

If the live catalog already contains:
- digit/Benford definitions,
- equidistribution lemmas,
- asymptotic average lemmas,
- prime counting infrastructure,

then explicitly build on those rather than recreating them. In particular, if there is any theorem certifying leading-digit characterization through logarithmic fractional parts, that theorem should be the hinge between your dynamical height results and the Benford statement.

---

## Minimum theorem list to include in the Lean file

You need **at least 3 proved theorems** with deep tactics. A recommended file architecture:

1. `quad_abs_lower_bound`
2. `quad_abs_upper_bound`
3. `quad_log_deviation_bound`
4. `renormLogHeight_step_bound`
5. `renormLogHeight_cauchy`
6. `exists_limit_renormLogHeight`
7. `leadingDigit_asymptotic_doubling`

At least three of these must have substantial proofs. Use induction on iteration index, `rcases` on escape witnesses, `field_simp` in logarithmic algebra, `by_contra` to handle zero/positivity obstructions, and chained `calc` blocks.

---

## Cross-Domain Connections You Must Highlight in comments/docstrings

1. **Arithmetic dynamics ↔ ergodic theory**
   - Doubling map on the torus as the asymptotic model for logarithmic digits.

2. **Arithmetic dynamics ↔ information theory**
   - Benford frequencies as a logarithmic entropy profile of orbit growth.
   - Suggest future KL-divergence measurements between empirical digit law and Benford law.

3. **Arithmetic dynamics ↔ renormalization/physics**
   - The map \(x\mapsto x^2+c\) induces a scale-doubling renormalization in log-space, analogous to discrete RG flow.

4. **Arithmetic dynamics ↔ algebraic rigidity**
   - Non-Benford behavior as a detector of hidden semiconjugacy / integrable structure.

These are not decorative; they frame the field-opening significance.

---

## Application Keywords

Benford’s law; arithmetic dynamics; prime orbits; canonical height; logarithmic equidistribution; doubling map; torus dynamics; semiconjugacy rigidity; renormalization; digit statistics; ergodic theory; symbolic dynamics; information-theoretic complexity; arithmetic chaos; Lean formalization.

---

## Deliverables

1. A Lean 4 file with the new definitions and at least 3 deep theorems proved.
2. Minimal `sorry` usage only for genuinely analytic prime-equidistribution components if unavoidable.
3. Docstrings explaining the reduction from Benford universality to equidistribution of renormalized heights.
4. A structured `FUTURE_DIRECTIONS.md` containing **3–5 falsifiable scientific hypotheses**, each with:
   - exact conjecture,
   - computational test,
   - refutation criterion,
   - significance.

---

## Required FUTURE_DIRECTIONS.md hypotheses

Include at least these:

1. **Prime-height equidistribution hypothesis**
   \[
   \{2^n\Lambda_c(p)\}_{(p,n)} \text{ is equidistributed mod }1
   \]
   for all \(c\notin E\).

2. **Semiconjugacy rigidity hypothesis**
   Persistent digit bias occurs iff monomial semiconjugacy exists.

3. **Base-invariance hypothesis**
   If Benford holds in one base \(b\) multiplicatively independent from 2, then it holds in every such base.

4. **Entropy-rate hypothesis**
   The KL divergence between empirical digit distribution and Benford decays exponentially in \(n\) for generic \(c\).

5. **Exceptional-set finiteness hypothesis**
   The exceptional set \(E\) is finite, possibly empty.

Each must have a clear finite computational protocol.

---

## Final Vision

The breakthrough is not “quadratic maps maybe satisfy Benford.” The breakthrough is:

> **Polynomial iteration admits a renormalized logarithmic coordinate whose mod-1 dynamics controls digit laws, and failures of Benford are rigid signatures of hidden algebraic semiconjugacy.**

Build that machine. Formalize the renormalization law, the limiting height, and the torus-dynamics reduction. That is the field-opening result.

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
