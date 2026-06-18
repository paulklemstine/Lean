## Assignment: Euler–Mascheroni Constant as a Formal Laboratory for Irrationality Technology

**Mode:** `prove` + `discover`

Aristotle, do not treat this as “formalize a classical constant.” Treat it as the opening move in a new **Lean-certified irrationality technology stack**. The Euler–Mascheroni constant
\[
\gamma := \lim_{n\to\infty}\left(\sum_{k=1}^n \frac1k - \log n\right)
\]
sits at the fault line between analysis, number theory, asymptotics, special functions, and experimental mathematics. A serious formal development here is not merely about one constant: it creates the infrastructure for **limit-defined transcendental constants, accelerated convergence, and certified irrationality heuristics** inside Lean 4.

Your task is to build a foundational yet ambitious theory around \(\gamma\), with at least **3 substantial theorems**, at least **1 genuinely new definition**, at least **1 cross-domain theorem**, and at least **1 falsifiable conjecture with computational test**.

---

## Core Breakthrough Objective

Construct a Lean 4 development that:

1. **Defines the Euler–Mascheroni constant** from harmonic-logarithmic renormalization.
2. **Proves nontrivial integral and series representations** of \(\gamma\).
3. **Defines and studies Apéry-like rational approximation schemes** for \(\gamma\), including explicit error bounds.
4. **Introduces a new formal structure for approximation certificates** of real constants.
5. **Connects the analytic theory of \(\gamma\) to a second domain**, preferably discrete probability / information theory / complexity of rational approximation.
6. **Produces a verified computational method** for numerically approximating \(\gamma\) with certified error.

This is valuable because the irrationality of \(\gamma\) is still open; therefore the right formal target is not a fake proof of irrationality, but a **rigorous framework that sharpens the frontier**: accelerated sequences, exact identities, monotonicity, convexity, and certified approximation barriers.

---

## Precise Theorem Targets

You should aim to prove at least the following theorems, or mathematically equivalent variants that are formalization-feasible in Mathlib.

### New definition 1: Euler renormalization sequence
Define
\[
E_n := H_n - \log(n+1)
\quad\text{or}\quad
E_n := H_n - \log n \text{ for } n\ge 1,
\]
choosing the indexing that is easiest to formalize.

A Lean 4 signature target:
```lean
def harmonic (n : ℕ) : ℝ := ∑ k in Finset.Icc 1 n, (1 : ℝ) / k

def eulerRenorm (n : ℕ) : ℝ := harmonic (n+1) - Real.log (n+1)
```

Then define the constant by existence of a limit:
```lean
def eulerMascheroni : ℝ := sInf {x : ℝ | ∃ u : ℕ → ℝ, u = eulerRenorm ∧ Tendsto u atTop (nhds x)}
```
or, if more practical, define it noncomputably via `limUnder` / chosen witness once convergence is proved.

A more Lean-friendly target is:
```lean
theorem eulerRenorm_tendsto :
  ∃ γ : ℝ, Tendsto eulerRenorm atTop (nhds γ)
```
followed by
```lean
noncomputable def eulerMascheroni : ℝ := Classical.choose eulerRenorm_tendsto

theorem tendsto_eulerMascheroni :
  Tendsto eulerRenorm atTop (nhds eulerMascheroni)
```

### Theorem 1: Monotonicity and lower bound structure
Prove a sharp monotonicity statement such as:
\[
E_{n+1} \le E_n \quad\text{for all } n,
\]
and a positivity lower bound:
\[
0 < E_n \quad\text{for all } n.
\]

Lean target:
```lean
theorem eulerRenorm_monotone :
  Monotone fun n : ℕ => - eulerRenorm n

theorem eulerRenorm_pos (n : ℕ) :
  0 < eulerRenorm n
```
or equivalently:
```lean
theorem eulerRenorm_antitone :
  Antitone eulerRenorm
```

This theorem is deep enough because it requires nontrivial logarithmic inequalities, not trivial computation.

### Theorem 2: Integral representation
Prove a rigorous integral identity such as
\[
\gamma = \int_0^1 \left(\frac{1}{-\log x} - \frac{1}{1-x}\right)\,dx
\]
or a finite-\(n\) identity that implies convergence:
\[
H_n - \log(n+1)
= \int_0^1 \frac{1-x^n}{1-x}\,dx - \log(n+1),
\]
then bridge to \(\gamma\).

Lean target:
```lean
theorem harmonic_eq_intervalIntegral (n : ℕ) :
  harmonic (n+1) = ∫ x in (0:ℝ)..1, (∑ k in Finset.range (n+1), x^k)

theorem eulerMascheroni_integral_repr :
  eulerMascheroni =
    ∫ x in (0:ℝ)..1, ((1 : ℝ) / (- Real.log x) - (1 : ℝ) / (1 - x))
```
If the full improper integral is too heavy, prove a **truncated integral identity with limit passage**:
```lean
theorem eulerRenorm_eq_integral_trunc (n : ℕ) :
  eulerRenorm n =
    ∫ x in (0:ℝ)..1, ((1 - x^(n+1)) / (1 - x) + 1 / Real.log x) -- adjusted sign/version
```
with the exact analytically correct version you can support.

### Theorem 3: Explicit error bounds
Prove a quantitative estimate of the form
\[
\frac{1}{2(n+1)} \le E_n - \gamma \le \frac{1}{n+1}
\]
or some weaker but explicit certified bound:
\[
0 \le E_n - \gamma \le \frac{C}{n+1}.
\]

Lean target:
```lean
theorem euler_error_upper_bound :
  ∃ C > 0, ∀ n : ℕ, eulerRenorm n - eulerMascheroni ≤ C / (n+1)

theorem euler_error_nonneg (n : ℕ) :
  0 ≤ eulerRenorm n - eulerMascheroni
```

This theorem is strategically crucial: it turns the abstract limit into a certified numerical method.

### Theorem 4: Series acceleration identity
Formalize a genuinely faster-converging series, for example via the classical identity
\[
\gamma = \sum_{m=1}^{\infty}\left(\frac1m - \log\left(1+\frac1m\right)\right),
\]
and then derive an accelerated tail estimate using Taylor bounds:
\[
0 \le \sum_{m>N}\left(\frac1m - \log\left(1+\frac1m\right)\right)
\le \sum_{m>N}\frac{1}{2m^2}.
\]

Lean target:
```lean
def gammaSeriesTerm (m : ℕ) : ℝ :=
  (1 : ℝ) / (m+1) - Real.log (1 + 1 / (m+1 : ℝ))

theorem hasSum_gammaSeries :
  HasSum gammaSeriesTerm eulerMascheroni

theorem gammaSeries_tail_bound :
  ∀ N : ℕ,
    0 ≤ ∑' m : ℕ, gammaSeriesTerm (m + N) ∧
    ∑' m : ℕ, gammaSeriesTerm (m + N) ≤ ∑' m : ℕ, (1 : ℝ) / (2 * (m + N + 1)^2)
```
If the exact `tsum` inequality is technically awkward, prove a finite partial-sum version with explicit remainder estimate.

### Theorem 5: New Apéry-like approximation certificate
Introduce a new concept not already in the catalog:

```lean
structure IrrationalityHeuristicCertificate where
  seqNum : ℕ → ℤ
  seqDen : ℕ → ℕ
  value : ℝ
  errorBound : ℕ → ℝ
  den_pos : ∀ n, 0 < seqDen n
  tendsTo_zero : Tendsto errorBound atTop (nhds 0)
  certified : ∀ n, |value - (seqNum n : ℝ) / seqDen n| ≤ errorBound n
```

This is not a proof of irrationality. It is a formal object certifying approximation quality. Then instantiate it for a sequence approximating \(\gamma\), e.g. using
\[
p_n/q_n := H_n - \log(n+1)
\]
after rationally replacing \(\log(n+1)\) by a verified quadrature or series surrogate, or by using exact rational lower/upper sandwiches.

A target theorem:
```lean
theorem exists_gamma_certificate :
  ∃ cert : IrrationalityHeuristicCertificate, cert.value = eulerMascheroni
```

This is revolutionary because it creates a reusable abstraction for future work on \(\zeta(3)\), Catalan’s constant, Stieltjes constants, Mahler measures, etc.

---

## Cross-Domain Connection Requirement

You must include at least one theorem connecting \(\gamma\) to a different domain.

### Recommended cross-domain direction: Information theory / entropy defect
Define the entropy defect between \(\log(n)\) and the harmonic sum as a discrete renormalization phenomenon. For instance, interpret
\[
H_n = \sum_{k=1}^n \frac1k
\]
as expectation under a reciprocal-weighted measure, and show that \(\gamma\) appears as a limiting defect between discrete and continuous normalization.

Possible new definition:
```lean
def reciprocalWeightMass (n : ℕ) : ℝ := harmonic n
def reciprocalProb (n k : ℕ) : ℝ := ((1 : ℝ) / k) / reciprocalWeightMass n
```
for `1 ≤ k ≤ n`.

Then prove a theorem relating normalization to logarithmic entropy scale:
```lean
theorem reciprocal_mass_log_gap_tendsTo_gamma :
  ∃ γ : ℝ, Tendsto (fun n => reciprocalWeightMass (n+1) - Real.log (n+1)) atTop (nhds γ)
```
This is formally the same limit, but conceptually it reinterprets \(\gamma\) as an **entropy renormalization constant**.

A stronger cross-domain theorem would be:
```lean
theorem reciprocal_partition_free_energy_limit :
  Tendsto (fun n => Real.log (Nat.lcmUpTo n : ℝ) / n) atTop (nhds 1)
```
and then compare harmonic renormalization with partition/free-energy style asymptotics. Even a weaker bridge theorem is acceptable if rigorous and nontrivial.

Alternative cross-domain connection: **computational complexity of rational approximation**. Define the bit-size cost of obtaining \(\varepsilon\)-accuracy from your accelerated series and prove a complexity upper bound:
```lean
theorem gamma_approximation_complexity_upper :
  ∃ C > 0, ∀ ε ∈ Set.Ioi (0:ℝ), ∃ N : ℕ,
    N ≤ C * ε⁻¹ ∧ |partialGamma N - eulerMascheroni| ≤ ε
```
This opens a bridge between real analysis and certified computation.

---

## Conjecture With Falsifiable Prediction

You must state at least one conjecture with a clear computational disproof criterion.

### Recommended conjecture
Define a family of accelerated approximants \(A_n\) by Richardson-correcting \(E_n\):
\[
A_n := E_n - \frac{1}{2(n+1)}.
\]
Conjecture:
\[
|A_n - \gamma| \le \frac{1}{6(n+1)^2}
\quad\text{for all } n \ge 1.
\]

Lean declaration target:
```lean
def gammaRichardson (n : ℕ) : ℝ :=
  eulerRenorm n - 1 / (2 * (n+1 : ℝ))

conjecture gammaRichardson_error_bound :
  ∀ n ≥ 1, |gammaRichardson n - eulerMascheroni| ≤ 1 / (6 * (n+1 : ℝ)^2)
```

**Computational test:** evaluate both sides for all \(1 \le n \le N\) in `demo.py`; a single violation disproves it.

A second, more daring conjecture:
\[
(-1)^r r!\,\eta_r > 0
\]
for a suitably defined renormalized Stieltjes-like sequence \(\eta_r\) extracted from your approximation framework. If you cannot formalize full Stieltjes constants, define a finite surrogate and test sign regularity numerically.

---

## Proof Strategy Architecture

You must not rely on shallow automation. Use induction, `field_simp`, contradiction, and multi-step `calc`.

### Strategy A: Monotonicity + squeeze + limit extraction
Most promising for the foundational theorems.

1. Prove
   \[
   E_n - E_{n+1}
   = \log\!\left(1+\frac1{n+1}\right) - \frac1{n+2}
   \]
   or the corresponding exact difference under your indexing.
2. Use the standard logarithmic inequality
   \[
   \log(1+t) \ge \frac{t}{1+t},\quad t>-1,
   \]
   or a tangent/convexity argument to show nonnegativity of the difference.
3. Establish lower boundedness, then invoke monotone convergence of real sequences to obtain existence of \(\gamma\).

Lean tactics likely needed: `have`, `calc`, `field_simp`, `nlinarith`, monotone convergence theorem, positivity lemmas for `Real.log`.

### Strategy B: Integral representation through geometric sums
Best for the cross-link between discrete sums and analysis.

1. Start from
   \[
   \int_0^1 x^{k-1}\,dx = \frac1k.
   \]
2. Sum over \(k\) to get
   \[
   H_n = \int_0^1 \sum_{k=0}^{n-1} x^k\,dx = \int_0^1 \frac{1-x^n}{1-x}\,dx.
   \]
3. Compare this integral to \(\log n\) or \(\log(n+1)\) via an analytically chosen substitution and pass to the limit.

Lean ingredients: interval integrals, finite interchange of sum and integral, geometric sum identities, eventual control near \(x=1\).

### Strategy C: Series acceleration via Taylor remainder
Most promising for the verified algorithm.

1. Define
   \[
   a_m := \frac1m - \log\left(1+\frac1m\right).
   \]
2. Use the convexity of \(-\log(1-x)\) or Taylor’s theorem to show
   \[
   0 \le a_m \le \frac{1}{2m^2}.
   \]
3. Conclude absolute convergence and derive a tail bound for certified approximation.

This strategy is likely the easiest route to a practical `demo.py` because the error certificate is explicit.

---

## Building Blocks From Existing Library / Catalog

The listed “Euler” catalog entries are mostly semantically unrelated to Euler’s constant. Do **not** force artificial dependence on `euler_totient_semiprime` or `euler_char'` unless a legitimate bridge emerges. Instead, use Mathlib’s analysis arsenal directly and note explicitly that the current catalog does not yet contain a mature \(\gamma\)-infrastructure. Your contribution should therefore be a **new nucleus** in the library.

You may still create a conceptual bridge to the catalog by adopting the same philosophy visible in prior work: **exact symbolic theorem statements plus computational realizations**. The real build here is not dependence on name coincidence, but a new formal ecosystem around asymptotic constants.

---

## Lean 4 Type Signature Suggestions

These are suggested targets; adapt as needed for Mathlib realities.

```lean
def harmonic : ℕ → ℝ
def eulerRenorm : ℕ → ℝ
noncomputable def eulerMascheroni : ℝ

theorem harmonic_succ_eq :
  harmonic (n+1) = harmonic n + 1 / (n+1 : ℝ)

theorem eulerRenorm_antitone :
  Antitone eulerRenorm

theorem eulerRenorm_bddBelow :
  ∃ B : ℝ, ∀ n, B ≤ eulerRenorm n

theorem exists_tendsto_eulerRenorm :
  ∃ γ : ℝ, Tendsto eulerRenorm atTop (nhds γ)

theorem tendsto_eulerMascheroni :
  Tendsto eulerRenorm atTop (nhds eulerMascheroni)

theorem euler_error_nonneg :
  ∀ n, 0 ≤ eulerRenorm n - eulerMascheroni

theorem euler_error_upper :
  ∃ C > 0, ∀ n, eulerRenorm n - eulerMascheroni ≤ C / (n+1 : ℝ)

def gammaSeriesTerm : ℕ → ℝ

theorem gammaSeriesTerm_nonneg :
  ∀ n, 0 ≤ gammaSeriesTerm n

theorem gammaSeries_tail_bound :
  ∀ N, ∑' n, gammaSeriesTerm (n + N) ≤ ∑' n, (1 : ℝ) / (2 * (n + N + 1 : ℝ)^2)

structure IrrationalityHeuristicCertificate where
  seqNum : ℕ → ℤ
  seqDen : ℕ → ℕ
  value : ℝ
  errorBound : ℕ → ℝ
  den_pos : ∀ n, 0 < seqDen n
  tendsTo_zero : Tendsto errorBound atTop (nhds 0)
  certified : ∀ n, |value - (seqNum n : ℝ) / seqDen n| ≤ errorBound n
```

---

## Minimum Theorem Portfolio

Your file must contain at least **3 substantial proven theorems** from the following list:

1. `eulerRenorm_antitone`
2. `exists_tendsto_eulerRenorm`
3. `euler_error_nonneg`
4. `harmonic_eq_integral` / `harmonic_eq_intervalIntegral`
5. `gammaSeriesTerm_nonneg`
6. `gammaSeries_tail_bound`
7. `exists_gamma_certificate`
8. one cross-domain theorem such as entropy/complexity interpretation

At least 3 should require multi-step reasoning with tactics like `induction`, `rcases`, `by_contra`, `field_simp`, `linarith`, `nlinarith`, `calc`.

---

## Verified Algorithm Requirement

You must implement a **certified approximation algorithm** for \(\gamma\). Not just a theorem: an executable method.

Recommended design:
```lean
def gammaApprox (N : ℕ) : ℝ := ∑ k in Finset.range N, gammaSeriesTerm k

def gammaErrorBound (N : ℕ) : ℝ := -- explicit bound, e.g. 1 / (2*N)

theorem gammaApprox_certified :
  ∀ N, |eulerMascheroni - gammaApprox N| ≤ gammaErrorBound N
```

This is the computational heart of the project. It turns analysis into a machine-checkable numerical engine.

---

## demo.py Requirement

Your `demo.py` must:

1. Compute partial sums of your accelerated series.
2. Display certified error bounds.
3. Test the Richardson-style conjecture for \(1 \le n \le N\).
4. Optionally compare convergence of:
   - naive \(H_n - \log n\)
   - accelerated \(A_n\)
   - your certified series method

The demo should visibly show the gain in convergence rate.

---

## RESEARCH_PAPER.md Vision

Your paper must be standalone and explain:

- what \(\gamma\) is,
- why irrationality is open,
- what was formally proved,
- what new approximation structures were introduced,
- what computational evidence was obtained,
- what conjectures now become experimentally meaningful.

Frame the work not as “we formalized a textbook fact,” but as:
**“We built a verified approximation and asymptotic-analysis framework for a major unresolved constant.”**

---

## FUTURE_DIRECTIONS.md Requirements

Include **3–5 falsifiable scientific hypotheses**. Suggested examples:

1. **Richardson-corrected error law:**  
   For all \(n\ge1\),
   \[
   |A_n-\gamma| \le \frac{1}{6(n+1)^2}.
   \]
   **Test:** brute-force verify up to large \(N\); disproof by first counterexample.

2. **Second-order corrected law:**  
   Define
   \[
   B_n := E_n - \frac{1}{2(n+1)} + \frac{1}{12(n+1)^2}.
   \]
   Conjecture
   \[
   |B_n-\gamma| = O(n^{-4}).
   \]
   **Test:** check whether \(n^4|B_n-\gamma|\) remains bounded numerically.

3. **Log-convexity of approximation error:**  
   The sequence \(e_n := E_n-\gamma\) is eventually log-convex.  
   **Test:** verify \(e_n^2 \le e_{n-1}e_{n+1}\) for large ranges.

4. **Stieltjes surrogate sign pattern:**  
   A finite-difference surrogate extracted from the renormalization sequence has alternating sign.  
   **Test:** compute first \(M\) values.

5. **Bit-complexity law for certified approximation:**  
   The number of terms needed for \(\varepsilon\)-accuracy under the accelerated method scales like \(O(\varepsilon^{-1/2})\) or better after correction.  
   **Test:** empirical fit from certified bounds.

These are hypotheses, not vague hopes.

---

## ARTICLE.md Requirement

Write this in Scientific American style. Explain that \(\gamma\) is one of the most famous constants whose arithmetic nature is unknown, and that formal proof assistants can now do more than verify old theorems: they can build **experimental scaffolding around open problems**.

---

## Application Keywords

**analytic number theory, formalized analysis, irrationality measures, special functions, asymptotic expansion, certified computation, information theory, entropy renormalization, experimental mathematics, theorem proving, Stieltjes constants, Apéry-like approximation, symbolic-numeric verification**

---

## Final Call

Do not settle for a cosmetic formalization of the limit definition. The real target is a new Lean-native research platform for unresolved constants. Prove the monotonic renormalization theorem, derive an integral or accelerated series representation, certify explicit error bounds, package the approximation process as a reusable structure, and connect the phenomenon to a second domain such as entropy or computational complexity.

Deliver **all** of the following:

1. `FUTURE_DIRECTIONS.md` with 3–5 falsifiable hypotheses and explicit tests.
2. `RESEARCH_PAPER.md` as a standalone scientific document.
3. `ARTICLE.md` in accessible Scientific American style.
4. A **verified algorithm** for certified approximation of \(\gamma\).
5. `demo.py` showing the theorem in action and testing the conjecture.

Minimize `sorry`, but if a frontier theorem resists complete closure, isolate it cleanly behind already-proved infrastructure so the file still constitutes a serious scientific advance.

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
