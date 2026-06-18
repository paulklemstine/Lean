Soli Deo Gloria

## Assignment: Benford Renormalization for Integer Dynamical Systems

**Mode:** `prove` + `discover`

Build a new formal theory of **Benford renormalization** for integer dynamical systems: a framework that isolates when digit-law universality emerges from arithmetic iteration, and when it fails because of a precise spectral obstruction. This should not be a collection of examples. The goal is a field-opening theorem package that makes “Benford behavior of integer orbits” into a mathematically structured invariant analogous to mixing, equidistribution, or entropy.

You are to formalize a robust obstruction theory for Benford behavior of iterated integer maps, prove nontrivial theorems in that theory, and implement a verified computational pipeline that tests the conjectural universality mechanism on concrete families.

The breakthrough vision is this:

> **Digit laws in arithmetic dynamics should be governed by a renormalized additive cocycle modulo 1.**
> The correct invariant is not the raw map \(T\), but the orbit-growth cocycle
> \[
> k \mapsto \log_{10}(T^{[k]}(n)) \pmod 1,
> \]
> and Benford behavior should arise exactly when this cocycle has no rational resonance / eigen-obstruction.

This connects:
- **number theory**: arithmetic iteration, divisibility, rational slope obstructions;
- **ergodic theory**: Weyl equidistribution, irrational rotations, cocycles;
- **spectral theory**: rational eigenmodes as obstructions to uniform distribution;
- **probability / pseudorandomness**: first-digit statistics and universality;
- **algorithmic dynamics**: diagnostics for chaotic-looking integer recurrences.

---

## Core Formal Objects to Introduce

You must define at least one genuinely new concept not already in the catalog. The central one should be something like the following.

### New definition 1: Benford-leading-digit indicator
For base \(b \ge 2\), define the predicate that a positive integer has leading digit \(d\in\{1,\dots,b-1\}\).

Suggested Lean target:
```lean
def leadingDigitBase (b n : ℕ) : ℕ := sorry
```
or, if easier to formalize first through real logarithms,
```lean
def mantissaBase (b : ℕ) (x : ℝ) : ℝ :=
  x / (b : ℝ) ^ (Real.log x / Real.log b).floor
```
with a derived digit predicate.

### New definition 2: Benford frequency on finite orbit windows
```lean
def benfordFreqUpTo (b d : ℕ) (u : ℕ → ℕ) (N : ℕ) : ℝ := sorry
```
representing the proportion of \(0 \le k < N\) such that `leadingDigitBase b (u k) = d`.

### New definition 3: Log-cocycle obstruction
Formalize a rational resonance obstruction for sequences in `ℝ / ℤ` or via fractional parts:
```lean
def fracLogBase (b : ℕ) (n : ℕ) : ℝ := Real.fract (Real.log n / Real.log b)

def HasRationalEigenObstruction (b : ℕ) (u : ℕ → ℕ) : Prop :=
  ∃ q : ℕ, 0 < q ∧ ∃ m : ℤ, m ≠ 0 ∧
    ∀ᶠ k in Filter.atTop, Real.fract (q * fracLogBase b (u k)) = 0
```
This exact formulation can be improved, but it must encode a nontrivial periodic/rational resonance in the additive cocycle modulo 1.

### New definition 4: Renormalized multiplicative orbit
For maps with asymptotically multiplicative growth, isolate the cocycle:
```lean
def logCocycle (b : ℕ) (T : ℕ → ℕ) (n k : ℕ) : ℝ :=
  Real.log ((Nat.iterate T k n : ℕ) : ℝ) / Real.log b
```

### New definition 5: Eventually affine log-cocycle
A practical formal class that is actually provable:
```lean
def EventuallyAffineModOne (u : ℕ → ℕ) (b : ℕ) : Prop :=
  ∃ α β : ℝ, Irrational α ∧
    ∀ᶠ k in Filter.atTop,
      Real.fract (fracLogBase b (u (k+1))) =
      Real.fract (fracLogBase b (u k) + α + β / ((k+1 : ℝ)))
```
or a cleaner asymptotic perturbation notion if needed. The point is to prove theorems for a tractable class strictly broader than geometric progressions.

---

## Precise Theorem Targets

You must prove at least **3 substantial theorems**. They should not collapse to finite enumeration. They should use multi-step reasoning: induction, `rcases`, `by_contra`, `field_simp`, `linarith`, `have`, `calc`, asymptotic estimates, or equidistribution lemmas.

Below are the theorem targets. You may refine hypotheses so they become formally provable in Lean 4 with Mathlib, but preserve the mathematical content.

---

### Theorem 1: Benford from irrational multiplicative growth

This is the anchor theorem: if the orbit is an exact geometric progression with irrational logarithmic slope, then it is Benford.

**Mathematical statement.**  
Let \(b \ge 2\), \(a \in \mathbb{N}_{>0}\), \(r \in \mathbb{N}_{>0}\). If \(\log_b(r)\) is irrational, then the sequence
\[
u_k = a r^k
\]
is Benford in base \(b\). Equivalently, for every digit \(d \in \{1,\dots,b-1\}\),
\[
\lim_{N\to\infty} \frac{1}{N}\#\{0\le k<N : \text{leading digit of }u_k\text{ in base }b\text{ is }d\}
=
\log_b\!\left(1+\frac1d\right).
\]

**Lean-oriented target signature.**
```lean
theorem geometric_benford_of_irrational_log
    (b a r d : ℕ)
    (hb : 2 ≤ b) (ha : 1 ≤ a) (hr : 1 ≤ r)
    (hd1 : 1 ≤ d) (hdb : d < b)
    (hirr : Irrational (Real.log (r : ℝ) / Real.log (b : ℝ))) :
    Tendsto
      (fun N : ℕ =>
        benfordFreqUpTo b d (fun k => a * r^k) N)
      Filter.atTop
      (nhds (Real.log (1 + 1 / (d : ℝ)) / Real.log (b : ℝ))) := by
  sorry
```

**Why this matters.**  
This turns Benford’s law from a heuristic into a rigorously certified spectral phenomenon. It is the base case for all renormalization results: once exact multiplicative growth is understood, perturbative orbit theorems become possible.

---

### Theorem 2: Rational obstruction implies non-Benford behavior

This theorem is the obstruction side of the dichotomy.

**Mathematical statement.**  
Suppose \(u_k > 0\) and the fractional parts \(\{\log_b u_k\}\) are eventually contained in a finite rational orbit, or more generally are not uniformly distributed mod 1 because they satisfy a nontrivial rational eigen-relation. Then \(u_k\) is not Benford in base \(b\).

A concrete provable version:
If there exists \(q \ge 1\) such that
\[
q \cdot \log_b(u_k) \in \mathbb{Z}
\quad \text{for all sufficiently large }k,
\]
then the sequence is not Benford.

**Lean-oriented target signature.**
```lean
theorem not_benford_of_eventually_rational_log
    (b d : ℕ) (u : ℕ → ℕ)
    (hb : 2 ≤ b) (hd1 : 1 ≤ d) (hdb : d < b)
    (hpos : ∀ k, 1 ≤ u k)
    (hobs : ∃ q : ℕ, 0 < q ∧ ∀ᶠ k in Filter.atTop,
      ∃ z : ℤ, q * (Real.log (u k : ℝ) / Real.log (b : ℝ)) = z) :
    ¬ Tendsto
        (fun N : ℕ => benfordFreqUpTo b d u N)
        Filter.atTop
        (nhds (Real.log (1 + 1 / (d : ℝ)) / Real.log (b : ℝ))) := by
  sorry
```

**Why this matters.**  
This gives the first rigorous “only if” mechanism: rational resonance blocks Benford universality. This is the beginning of a spectral classification theorem for integer dynamical systems.

---

### Theorem 3: Stability under summable logarithmic perturbation

This is the real renormalization theorem. It moves beyond exact geometric progressions and captures asymptotically multiplicative systems.

**Mathematical statement.**  
Let \(u_k, v_k > 0\) be sequences with
\[
\sum_{k=0}^\infty \left| \log_b(u_k) - \log_b(v_k) \right| < \infty
\]
or a suitable stronger pointwise asymptotic such as
\[
\log_b(u_k) - \log_b(v_k) \to 0.
\]
If \(\{\log_b(v_k)\}\) is uniformly distributed mod 1, then so is \(\{\log_b(u_k)\}\). Hence Benford behavior transfers from \(v_k\) to \(u_k\).

A Lean-feasible version can use:
\[
\forall^\infty k,\ |\log_b(u_k)-(\alpha k+\beta)| \le \varepsilon_k,\quad \varepsilon_k\to 0,
\]
with irrational \(\alpha\).

**Lean-oriented target signature.**
```lean
theorem benford_of_asymptotic_affine_log
    (b d : ℕ) (u : ℕ → ℕ) (α β : ℝ)
    (hb : 2 ≤ b) (hd1 : 1 ≤ d) (hdb : d < b)
    (hirr : Irrational α)
    (hasym :
      Tendsto
        (fun k : ℕ =>
          (Real.log (u k : ℝ) / Real.log (b : ℝ)) - (α * k + β))
        Filter.atTop
        (nhds 0)) :
    Tendsto
      (fun N : ℕ => benfordFreqUpTo b d u N)
      Filter.atTop
      (nhds (Real.log (1 + 1 / (d : ℝ)) / Real.log (b : ℝ))) := by
  sorry
```

**Why this matters.**  
This is the renormalization principle: Benford behavior is stable under asymptotically negligible deformation of the log-cocycle. This theorem is the bridge from toy models to real arithmetic dynamics.

---

### Theorem 4: Cross-domain theorem — spectral obstruction as a dynamical invariant

You must include at least one theorem connecting this subject to another domain. The strongest candidate is a bridge to ergodic/spectral language.

**Mathematical statement.**  
For an orbit \(u_k\), if the additive cocycle
\[
x_k := \{\log_b u_k\}
\]
is eventually conjugate to an irrational rotation \(x_{k+1}=x_k+\alpha \pmod 1\), then \(u_k\) is Benford. If it is eventually conjugate to a rational rotation, it is not Benford.

This makes Benford behavior equivalent to spectral type in a concrete class.

**Lean-oriented target signature.**
```lean
theorem benford_of_eventual_rotation_model
    (b d : ℕ) (u : ℕ → ℕ) (α x0 : ℝ)
    (hb : 2 ≤ b) (hd1 : 1 ≤ d) (hdb : d < b)
    (hirr : Irrational α)
    (hmodel :
      ∀ᶠ k in Filter.atTop,
        Real.fract (Real.log (u k : ℝ) / Real.log (b : ℝ)) =
        Real.fract (x0 + k * α)) :
    Tendsto
      (fun N : ℕ => benfordFreqUpTo b d u N)
      Filter.atTop
      (nhds (Real.log (1 + 1 / (d : ℝ)) / Real.log (b : ℝ))) := by
  sorry
```

**Cross-domain significance.**  
This is the conceptual hinge between **arithmetic dynamics** and **ergodic rotation theory**. It reframes first-digit laws as a spectral rigidity/flexibility phenomenon.

---

## Most Promising Proof Strategies

You must give Aristotle multiple routes, not one.

### Strategy A: Weyl-equidistribution route
Most promising for Theorems 1 and 3.

1. Prove that Benford frequency is equivalent to the fractional parts of \(\log_b(u_k)\) landing in the interval
   \[
   [\log_b d,\ \log_b(d+1))
   \]
   after normalization.
2. Invoke or build from Mathlib equidistribution results for sequences of the form \(k\alpha+\beta\) mod 1 with irrational \(\alpha\).
3. Transfer asymptotic affine control of \(\log_b(u_k)\) to the same limiting interval frequency by showing perturbations vanishing in \(\mathbb{R}\) do not change limiting frequencies away from interval boundaries.

Why this is most promising: it isolates the hard analytic content into standard equidistribution machinery and reduces digit statistics to interval counting.

### Strategy B: Exponential sums / spectral criterion
Best for Theorem 2 and for a stronger future theorem.

1. Formalize a criterion: if \(\{x_k\}\) is uniformly distributed mod 1, then for every nonzero integer \(m\),
   \[
   \frac1N \sum_{k<N} e^{2\pi i m x_k} \to 0.
   \]
2. Show a rational obstruction produces a nonzero Fourier mode that fails to decay.
3. Conclude non-uniform distribution, hence non-Benford.

Why this matters: this gives the “eigen-obstruction” interpretation literally in spectral terms. It is more revolutionary, but perhaps more infrastructure-heavy in Lean.

### Strategy C: Interval coding + finite-state obstruction
Most practical for concrete piecewise maps and computational verification.

1. Define a finite partition of \([0,1)\) into Benford digit intervals.
2. Show that if \(\{\log_b(u_k)\}\) is eventually periodic/rational, then digit frequencies are supported on finitely many interval visits and cannot match the logarithmic law except in degenerate impossible cases.
3. Use this to certify failure of Benford behavior for explicit obstructed families.

Why useful: this route supports the algorithmic side and concrete map testing, even if full spectral formalization is deferred.

---

## Concrete Families to Analyze

Do not overclaim for \(3n+1\) globally unless hypotheses are provable. Instead, define and prove results for tractable subfamilies and then test conjectures computationally on bolder maps.

### Family 1: Exact multiplicative maps
\[
T(n)=rn,\quad r\ge2.
\]
This should be fully formalized and proved.

### Family 2: Affine-expanding maps on selected invariant subsets
\[
T(n)=an+c
\]
restricted to seeds where positivity and monotone growth hold, with asymptotic
\[
\log T^k(n)=k\log a + O(1).
\]
This gives a rich theorem class and is realistic in Lean.

### Family 3: Polynomially perturbed multiplicative systems
\[
T(n)=rn + p(n),\quad p(n)=o(n)
\]
on monotone orbits, or directly sequences satisfying asymptotic affine log-growth.

### Family 4: Experimental-only families
- \(3n+1\) along accelerated / stopping-time windows;
- reverse-and-add;
- \(x \mapsto x^2+c\) on integer orbits;
- piecewise affine maps with random-looking parity branches.

For these, you may state conjectures and provide verified computational evidence without pretending a full theorem has been proved.

---

## Conjecture to State and Test

You must include at least one falsifiable conjecture with a clear disproof protocol.

### Main conjecture: Benford renormalization dichotomy
For a nondegenerate integer dynamical map \(T : \mathbb{N}\to\mathbb{N}\) with average multiplicative expansion and positive orbits, define
\[
x_k(n)=\left\{\log_{10}(T^{[k]}(n))\right\}.
\]
Then for natural density \(1\) of seeds \(n\), the orbit \(T^{[k]}(n)\) is Benford in base \(10\) **iff** the cocycle \(x_k(n)\) admits no nontrivial rational eigen-obstruction.

A testable computational form:
- compute digit frequencies over long windows;
- estimate low Fourier modes of \(x_k(n)\);
- certify agreement between Benford frequencies and spectral flatness;
- search systematically for obstruction-free families exhibiting non-Benford statistics. Any such family refutes the conjecture.

You should also formulate at least one sharper sub-conjecture that is likely provable later, e.g. for eventually affine log-cocycles.

---

## Lean 4 Formalization Guidance

Aim for a file architecture that separates definitions, structural lemmas, and applications:

- `BenfordRenormalization/Definitions.lean`
- `BenfordRenormalization/EquidistributionBridge.lean`
- `BenfordRenormalization/Obstruction.lean`
- `BenfordRenormalization/Examples.lean`

Potential useful Mathlib ingredients:
- `Real.log`, `Real.fract`, floor/fractional part lemmas;
- asymptotic/filter language: `Tendsto`, `Filter.atTop`, `Eventually`;
- irrationality infrastructure;
- summation / averages over `Finset.range`;
- if available, equidistribution / rotation lemmas over `ℝ` mod `ℤ`;
- interval membership reformulated via inequalities on fractional parts.

If direct theorem support for uniform distribution is thin, formalize a strong usable special case rather than waiting for a perfect general theorem:
- exact affine fractional-part model;
- convergence of empirical interval frequencies for irrational rotations;
- transfer under vanishing perturbation.

---

## Required Theorem Density and Proof Depth

Your development must contain at least 3 genuinely nontrivial theorems whose proofs use substantial tactics such as:
- induction on iterate count;
- `rcases` decomposition of obstruction hypotheses;
- `by_contra` for non-Benford contradiction arguments;
- `field_simp` in logarithmic interval manipulations;
- multi-step `calc` chains converting leading-digit conditions into log-interval conditions.

Do not pad the file with trivial helper lemmas proved by automation only. The center of gravity must be conceptual.

---

## Suggested Intermediate Lemmas

These are excellent stepping stones and should likely appear explicitly.

```lean
lemma leadingDigit_iff_fract_log_mem_interval
    (b d n : ℕ) (hb : 2 ≤ b) (hd1 : 1 ≤ d) (hdb : d < b) (hn : 1 ≤ n) :
    leadingDigitBase b n = d ↔
      Real.fract (Real.log (n : ℝ) / Real.log (b : ℝ)) ∈
        Set.Icc
          (Real.log (d : ℝ) / Real.log (b : ℝ))
          (Real.log ((d+1 : ℕ) : ℝ) / Real.log (b : ℝ)) := by
  sorry
```

```lean
lemma log_geometric_iter
    (b a r k : ℕ) (hb : 2 ≤ b) (ha : 1 ≤ a) (hr : 1 ≤ r) :
    Real.log ((a * r^k : ℕ) : ℝ) / Real.log (b : ℝ) =
      Real.log (a : ℝ) / Real.log (b : ℝ) +
      k * (Real.log (r : ℝ) / Real.log (b : ℝ)) := by
  sorry
```

```lean
lemma not_uniform_of_eventually_finite_range_mod_one
    (x : ℕ → ℝ)
    (hfin : ∃ s : Finset ℝ, ∀ᶠ k in Filter.atTop, Real.fract (x k) ∈ s) :
    ¬ UniformDistributedModOne x := by
  sorry
```

Even if `UniformDistributedModOne` is a new definition you create, this lemma would be highly valuable.

---

## Cross-Domain Connections You Must Highlight

At least one theorem and the narrative around it must explicitly bridge to a different domain.

### Option A: Ergodic theory / spectral theory
Interpret rational eigen-obstruction as a discrete spectral atom of the orbit cocycle.

### Option B: Pseudorandomness / complexity
Argue that Benford compliance of orbit outputs is a testable indicator of arithmetic pseudorandomness; obstruction corresponds to hidden low-complexity periodic structure.

### Option C: Information theory
Use digit frequencies as a coarse entropy observable; obstruction-free cocycles maximize digit unpredictability in the Benford sense.

### Option D: Dynamical systems + physics
Frame the logarithmic cocycle as a renormalization flow on scales; Benford universality is then an emergent scale-invariant law.

The strongest formal bridge is Option A, but the paper and article should mention at least one of B/C/D as future-facing significance.

---

## Application Keywords

Include these explicitly in your prose, paper metadata, and demo:
- arithmetic dynamics
- Benford’s law
- equidistribution
- irrational rotation
- spectral obstruction
- renormalization
- pseudorandomness
- digit statistics
- logarithmic cocycle
- universality
- ergodic number theory

---

## Computational / Algorithmic Deliverable

You must produce a **verified algorithm**, not merely theorem statements.

### Required algorithm
Implement a certified empirical Benford analyzer for integer orbits:

```python
def benford_orbit_report(T, seeds, steps, base=10):
    """
    Returns:
      - empirical leading-digit frequencies
      - discrepancy from Benford law
      - estimated low Fourier modes of frac(log_base orbit))
      - obstruction flags (detected rational resonances / periodicity)
    """
```

Mathematically connect the outputs to your formal definitions:
- `leadingDigitBase`
- `benfordFreqUpTo`
- obstruction detection based on approximate rational concentration or repeated finite-range mod-1 behavior.

At least one theorem should certify correctness of some component of this algorithm, e.g. that the digit-classification routine matches the logarithmic interval criterion.

---

## demo.py Requirements

Your `demo.py` must let a user interactively:
1. choose a map family \(T\);
2. choose seeds and window length;
3. view empirical first-digit frequencies versus Benford predictions;
4. view the fractional-part histogram of \(\log_{10}(T^k(n))\);
5. detect and display possible rational obstruction diagnostics.

Include at least:
- multiplication maps \(n \mapsto rn\);
- affine maps \(n \mapsto an+c\);
- one experimental map such as reverse-and-add or a Collatz-type branch map.

---

## Deliverables You MUST Produce

1. **Lean development** with at least 3 substantial theorems and one new concept.
2. **A verified algorithm or computational method** for Benford/orbit obstruction analysis.
3. **`demo.py`** demonstrating the theory interactively.
4. **`RESEARCH_PAPER.md`** as a standalone scientific paper:
   - define Benford renormalization;
   - state exact theorems;
   - explain proof ideas;
   - discuss why the obstruction criterion is conceptually new;
   - include computational findings and limitations;
   - propose next theorem-level milestones.
5. **`ARTICLE.md`** in Scientific American style:
   - explain why iterated arithmetic processes can generate universal digit laws;
   - describe the “hidden rhythm modulo 1” idea accessibly;
   - do **not** focus on formal verification machinery.
6. **`FUTURE_DIRECTIONS.md`** with 3–5 concrete research directions.
   Each direction must include:
   - a sentence beginning **“The key insight is…”**
   - a sentence beginning **“Why now?”**
   At least one direction must bridge to a genuinely different domain, such as statistical physics, cryptography, or information theory.

---

## Standard of Ambition

Do not settle for “some examples satisfy Benford.” The mission is to extract a new invariant:

> **Benford universality is controlled by the absence of rational spectral obstruction in the logarithmic cocycle.**

Even a partial formal realization of this principle — proved for exact geometric systems, asymptotically affine log-growth, and explicit obstruction classes — would open a new program in arithmetic dynamics.

The right outcome is that a mathematician reading your work says:

**“This is not a digit curiosity. This is a renormalization theory for arithmetic iteration.”**

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

Research domain: Speculative
Research mode: prove
