## Assignment: Benford Renormalization for Prime-Generated Dynamical Orbits

**Mode:** prove

Prove genuinely new theorems, not cosmetic variants. The target is a rigorous arithmetic-dynamical Benford principle for prime-seeded nonlinear orbits, with at least one fully formalized non-exceptional family in Lean 4 and a clean exceptional-family obstruction theorem. Minimize sorry. If the full conjecture is too ambitious in one cycle, carve out the strongest theorem whose proof architecture clearly scales.

---

## Breakthrough Objective

Establish that for nonlinear maps of degree at least `2`, the **Benford behavior of orbit values generated from prime seeds** is governed by **equidistribution of logarithmic growth phases modulo 1**, and that the only persistent obstructions come from rigid multiplicative/semiconjugate structures.

This is not a digit curiosity. It is a proposed universality law linking:

- **arithmetic dynamics** (iteration of polynomial/rational maps),
- **prime statistics** (sampling over prime initial conditions),
- **uniform distribution mod 1**,
- **digital laws / Benford phenomena**,
- and potentially **renormalization-style asymptotics** for iterated growth.

If true even in one robust family, this opens a new field: **digital arithmetic dynamics**.

---

## Primary Theorem Target

Start with a theorem that is both formalizable and conceptually decisive: a **Benford criterion from mod-1 equidistribution**, then instantiate it for a concrete non-exceptional family where asymptotic growth is sufficiently rigid.

### Theorem A — Benford criterion for prime-generated dynamical arrays

Let `b ≥ 2` be an integer base. Let `T : ℤ → ℤ` be a polynomial map of degree `d ≥ 2`. For primes `p` and times `n`, define
`a(p,n) = T^[n] p`, restricted to indices with `a(p,n) ≠ 0`.

Assume:

1. there exists a real constant `c > 0` such that for all sufficiently large `|x|`,
   `|log |T x| - d * log |x|| ≤ c / |x|`,
   hence iteratively `log |T^[n] p| = d^n log p + ε(p,n)` with `ε(p,n)` controlled;

2. the doubly-indexed set
   `({(d^n * log_b p) mod 1 : p prime, p ≤ X, 1 ≤ n ≤ N})`
   is equidistributed mod `1` as `X, N → ∞` along some cofinal regime;

3. the error term `ε(p,n)` is negligible in Weyl sums after division by `log b`.

Then the leading-digit distribution of `|T^[n] p|` in base `b`, averaged over primes `p ≤ X` and times `1 ≤ n ≤ N`, converges to Benford’s law:
\[
\lim_{X,N\to\infty}
\frac{1}{\pi(X)N}
\#\{(p,n): p\le X,\ p \text{ prime},\ 1\le n\le N,\ \operatorname{leadDigit}_b(|T^{(n)}(p)|)=m\}
=
\log_b(1+1/m)
\]
for each digit `m ∈ {1, …, b-1}`.

### Lean-oriented type signature sketch

You will likely need to define a finite-sample frequency first. A realistic formal target is:

```lean
def leadDigitBase (b : ℕ) (z : ℤ) : ℕ := sorry

def primeOrbitCount
    (T : ℤ → ℤ) (X N m b : ℕ) : ℕ :=
  ((Finset.range (N + 1)).biUnion fun n =>
    (((Finset.range (X + 1)).filter Nat.Prime).filter fun p =>
      leadDigitBase b ((T^[n]) (p : ℤ)).natAbs = m)).card

theorem benford_of_log_modOne_equidistributed
    (T : ℤ → ℤ) (d b m : ℕ)
    (hb : 2 ≤ b) (hd : 2 ≤ d) (hm : 1 ≤ m ∧ m < b)
    (hGrowth : ∃ C N0, ∀ p n, Nat.Prime p → N0 ≤ p →
      ‖Real.log (|(T^[n]) (p : ℤ)|) - (d^n : ℕ) * Real.log p‖ ≤ C)
    (hEquidist : -- precise mod 1 equidistribution hypothesis on ((d^n : ℝ) * log p / log b)
      True)
    :
    Filter.Tendsto
      (fun k : ℕ =>
        (primeOrbitCount T k k m b : ℝ) /
          (((((Finset.range (k + 1)).filter Nat.Prime).card : ℕ) * (k + 1)) : ℝ))
      Filter.atTop
      (nhds (Real.log (1 + 1 / (m : ℝ)) / Real.log b)) := sorry
```

This exact signature may need adaptation, but the theorem should be stated with explicit quantifiers and a limit target in `ℝ`.

---

## Concrete Family Theorem You Should Actually Try to Prove

The general conjecture is grand. For this cycle, aim to **prove one nontrivial family theorem completely**.

### Theorem B — Quadratic polynomial asymptotic Benford reduction

For `T_c(x) = x^2 + c` with fixed integer `c`, there exist constants `C_c, P_c > 0` such that for every prime `p ≥ P_c` and every `n ≥ 0`:
\[
\left| \log |T_c^{(n)}(p)| - 2^n \log p \right| \le C_c 2^n/p.
\]
Consequently, if the array
\[
\left\{ \frac{2^n \log p}{\log 10} \bmod 1 : p \le X,\ p \text{ prime},\ 1\le n\le N \right\}
\]
is equidistributed mod `1`, then the decimal leading digits of `|T_c^{(n)}(p)|` are Benford.

This theorem is powerful because it isolates the arithmetic-dynamical content into a clean growth-renormalization lemma and pushes the remaining difficulty into a pure equidistribution statement.

### Lean 4 type signature sketch

```lean
theorem log_iterate_quad_close
    (c : ℤ) :
    ∃ C P : ℝ, 0 < C ∧ 0 < P ∧
      ∀ p : ℕ, Nat.Prime p → (P : ℕ) ≤ p →
      ∀ n : ℕ,
        ‖Real.log (|((fun z : ℤ => z^2 + c)^[n]) (p : ℤ)|) -
          (2^n : ℕ) * Real.log p‖
        ≤ C * (2^n : ℝ) / p := sorry
```

and then:

```lean
theorem benford_quad_of_equidist_log_primes
    (c m : ℤ) :
    -- explicit digit assumptions and equidistribution hypothesis
    True := sorry
```

Even if the second theorem remains hypothesis-driven, the first is already a serious formal contribution.

---

## Exceptional-Class Obstruction Theorem

Do not only prove positive results. Also isolate the obstruction mechanism.

### Theorem C — Monomial/powering obstruction

For `T(x) = ±x^d` or more generally maps semiconjugate to a monomial/powering map in the sense that
\[
\phi \circ T = M \circ \phi,\quad M(x)=\pm x^d
\]
on an invariant domain, the sequence of fractional parts of `log_b |T^[n](p)|` is contained in a finite-rank additive progression generated by `log_b |p|` and constants from the semiconjugacy, hence may fail to be equidistributed for structured prime subsets. In particular, the Benford law is not automatic and requires extra Diophantine assumptions.

This theorem gives the conjecture its sharpness: it identifies the exact rigid source of non-universality.

### Lean target sketch

```lean
theorem monomial_iterate_log_affine
    (d : ℕ) (hd : 2 ≤ d) :
    ∀ p n : ℕ,
      Real.log ((p : ℝ) ^ (d^n)) = (d^n : ℕ) * Real.log p := sorry
```

Then use it to show the digit law reduces to distribution of `(d^n * log_b p) mod 1` with no smoothing error. This is the “rigid exceptional” model.

---

## Proof Architecture: 3 Possible Strategies

### Strategy A — Renormalized logarithmic cocycle analysis
**Most promising for this cycle.**

1. Prove a one-step growth estimate for `T(x)=a_dx^d+...+a_0`:
   \[
   \log |T(x)| = d\log|x| + \log|a_d| + O(1/|x|)
   \]
   for large `|x|`.

2. Iterate the estimate to obtain:
   \[
   \log|T^{(n)}(p)| = d^n \log p + \frac{d^n-1}{d-1}\log|a_d| + O(d^n/p).
   \]

3. Reduce Benford to equidistribution of the affine phase
   \[
   d^n \log_b p + \frac{d^n-1}{d-1}\log_b|a_d| \pmod 1.
   \]

Why this is strongest: it separates the problem into a formalizable deterministic dynamical estimate and a modular equidistribution input. The first part is highly Lean-friendly and already groundbreaking.

---

### Strategy B — Weyl-sum criterion over the prime-time array

1. Define the empirical measure on phases
   \[
   \mu_{X,N} = \frac{1}{\pi(X)N}\sum_{p\le X,\ p\text{ prime}}\sum_{n\le N}\delta_{\{\log_b|T^{(n)}(p)|\}}.
   \]

2. Use Weyl’s criterion: it suffices to show for every nonzero integer `k`,
   \[
   \frac{1}{\pi(X)N}\sum_{p\le X}\sum_{n\le N} e^{2\pi i k \log_b |T^{(n)}(p)|}\to 0.
   \]

3. Replace `log_b|T^{(n)}(p)|` by the renormalized phase from Strategy A and estimate the difference via the growth lemma.

This is more analytic and conceptually elegant. It will likely be harder to fully formalize in one shot, but it provides the correct theorem statement and future scaling.

---

### Strategy C — Symbolic-dynamical / transfer-operator viewpoint
1. Interpret the map on logarithmic scale as an expanding affine cocycle plus a decaying perturbation.
2. Study the induced action on the torus `ℝ/ℤ`, where the Benford digit event is an interval test.
3. Show the transfer operator drives smooth observables toward Haar measure except in resonant exceptional cases.

This is the most visionary route. It may not be the first Lean theorem, but it is the route to a field-opening “renormalization principle” paper.

---

## Most Promising Immediate Deliverable

Prioritize the following chain:

1. **Formalize the deterministic growth-renormalization lemma** for `T_c(x)=x^2+c`.
2. **Formalize the Benford-from-equidistribution criterion** for general positive sequences.
3. **State the prime equidistribution input as a hypothesis**, and derive Benford for quadratic prime orbits.
4. If time permits, prove a toy equidistribution theorem for a simplified seed set (not necessarily primes) to validate the mechanism end-to-end.

This creates a durable scaffold: the arithmetic dynamics part becomes certified, and the analytic number theory input can be upgraded later.

---

## Lean-Formalizable Intermediate Theorems

### Theorem D — Benford interval criterion
For any positive real sequence `u_n`, if `frac (log_b u_n)` is equidistributed mod `1`, then `u_n` is Benford in base `b`.

```lean
theorem benford_of_equidistributed_log
    (u : ℕ → ℝ) (b m : ℕ)
    (hb : 2 ≤ b) (hm : 1 ≤ m ∧ m < b)
    (hu : ∀ n, 0 < u n)
    (hEq : -- equidistribution of fun n => fract (Real.log (u n) / Real.log b)
      True) :
    Filter.Tendsto
      (fun N =>
        ((Finset.range N).filter
          (fun n => leadDigitBase b (Int.ofNat (Nat.floor (u n))) = m)).card / (N : ℝ))
      Filter.atTop
      (nhds (Real.log (1 + 1 / (m : ℝ)) / Real.log b)) := sorry
```

### Theorem E — Stability of Benford under multiplicative perturbation
If `u_n, v_n > 0` and `log u_n - log v_n → 0 mod 1` in discrepancy sense, then `u_n` is Benford iff `v_n` is.

This theorem is the renormalization backbone: digit laws are stable under asymptotically negligible logarithmic perturbations.

### Theorem F — Quadratic iterate growth lower bound
For `T_c(x)=x^2+c`, for sufficiently large `x`,
\[
|T_c(x)| \ge \frac12 x^2.
\]
Hence all sufficiently large prime seeds generate strictly increasing unbounded orbits.

This is easy, useful, and should be formalized first.

---

## How to Use Existing Catalog Theorems

You mentioned:

- `sq_eq_one_mod_prime : theorem sq_eq_one_mod_prime (p x : ℕ) (hp : Nat.Prime p) (hx : x ^ 2 ≡ 1 [MOD p]) : ...`

Even though this theorem is not directly Benford-theoretic, it can still be leveraged in the following way:

1. In exceptional or structured families, congruence restrictions can force orbit values into thin residue classes.
2. Thin residue-class support can interact with digit bias through local obstructions.
3. Use `sq_eq_one_mod_prime` as a seed for proving that certain orbit congruence patterns are highly rigid, strengthening the case that monomial-like maps are genuinely exceptional.

This is not the main engine, but it is useful for constructing or excluding structured counterexamples.

---

## Cross-Domain Connections You Should Exploit

### 1. Arithmetic dynamics × uniform distribution
The central bridge is:
\[
\text{Benford} \iff \text{equidistribution of } \log_b |T^{(n)}(p)| \bmod 1.
\]
This translates a nonlinear orbit-growth problem into torus dynamics.

### 2. Prime number theory × lacunary sequences
The phase `d^n log p` is a **lacunary-in-time, arithmetic-in-seed** sequence. This is reminiscent of:
- Weyl sums,
- Vinogradov-style estimates,
- pseudo-randomness of primes under exponential observables.

### 3. Renormalization × digital statistics
Iteration replaces raw growth by an effective linear cocycle on logarithms:
\[
L_{n+1} = d L_n + \text{small correction}.
\]
This is a renormalization law. Benford emerges as a fixed-point statistical phenomenon on the torus.

### 4. Dynamical rigidity × hidden algebraic structure
Failure of Benford should signal semiconjugacy to multiplicative dynamics. That turns leading-digit statistics into a **diagnostic for hidden rigidity**.

### 5. Potential ML / complexity analogy
Digit-law universality for iterated arithmetic systems resembles universality classes in statistical physics and random matrix theory. If successful, this framework could suggest automated structure-detection heuristics for symbolic dynamical systems.

---

## Application Keywords

- arithmetic dynamics
- Benford’s law
- prime orbits
- uniform distribution mod 1
- Weyl criterion
- lacunary sequences
- renormalization
- semiconjugacy rigidity
- digital statistics
- nonlinear recurrence universality
- logarithmic cocycles
- dynamical number theory

---

## Concrete Execution Plan

### Phase 1: Formal infrastructure
- Define `leadDigitBase`.
- Define iterate notation for integer self-maps if needed.
- Define empirical digit frequencies over finite prime/time windows.
- Prove basic lemmas connecting leading digits to intervals of `fract (log_b x)`.

### Phase 2: Deterministic dynamics
- Prove lower-growth and monotonic escape lemmas for `x^2 + c`.
- Prove `log_iterate_quad_close`.
- Generalize to monic polynomials if feasible.

### Phase 3: Statistical reduction
- Prove Benford-from-equidistribution for generic positive arrays.
- State a 2-parameter equidistribution hypothesis and derive the Benford conclusion.

### Phase 4: Exceptional mechanism
- Formalize monomial/powering exact logarithmic evolution.
- Prove that in these families Benford reduces to a rigid phase problem with no smoothing.

---

## Standard of Success

A successful cycle delivers at least one of:

1. a complete Lean theorem proving the **growth-renormalization estimate** for `x^2+c`,
2. a complete Lean theorem proving **Benford from equidistributed logarithmic mantissae**,
3. a complete theorem combining the two under an explicit equidistribution hypothesis,
4. a rigorous exceptional-family obstruction theorem.

Any one of these is already a nontrivial opening move toward the full conjecture.

---

## Required FUTURE_DIRECTIONS.md

You must produce a structured `FUTURE_DIRECTIONS.md` with **3–5 falsifiable scientific hypotheses**, each with:

- a precise conjectural statement,
- a proposed test,
- what outcome would refute it.

Include hypotheses of the following flavor:

1. **Quadratic universality hypothesis**  
   For every integer `c` outside an explicit finite exceptional set, the prime-seeded orbits of `x^2+c` satisfy Benford in base 10.

2. **Exceptional rigidity hypothesis**  
   Persistent non-Benford bias occurs iff the map is semiconjugate to a monomial/powering map or possesses a rational invariant inducing affine torus phases.

3. **Base-independence hypothesis**  
   For non-exceptional maps, Benford convergence holds simultaneously for all integer bases `b ≥ 2`.

4. **Discrepancy-rate hypothesis**  
   The digit discrepancy is bounded above by a constant multiple of the discrepancy of
   `d^n log_b p mod 1` plus the renormalization error term.

5. **Rational-map extension hypothesis**  
   For rational maps with integer coefficients and no pole encounters on the sampled orbit set, the same Benford law holds after excluding a zero-density exceptional set of seeds.

These must be framed so that numerical experiments or subsequent proofs could genuinely falsify them.

---

## Final Charge

Do not settle for a vague “Benford seems plausible.” Extract the exact deterministic renormalization law behind orbit growth, formalize the digit criterion through mod-1 dynamics, and isolate the exceptional rigid families. The goal is to turn leading digits from a numerical curiosity into a **structural invariant of arithmetic dynamical systems**. If you can certify even the quadratic case with a clean reduction to prime-phase equidistribution, you will have created the first real blueprint for a new subject.

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
