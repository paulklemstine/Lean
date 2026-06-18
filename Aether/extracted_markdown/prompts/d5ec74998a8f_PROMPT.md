Soli Deo Gloria

## Assignment: Odd Perfect Numbers as a Multiplicative Rigidity Program

**Mode:** prove

You are not being asked for another summary of folklore obstructions. You are being asked to turn the odd perfect number problem into a **formal multiplicative rigidity theory** in Lean 4: isolate the exact structural mechanisms that force an odd perfect number, if it exists, into an impossibly thin region of arithmetic phase space.

The immediate target is not “solve the whole conjecture by brute force formalization.” The real breakthrough target is stronger: create a **new certified framework** in which the known Eulerian shape, divisor-sum multiplicativity, parity constraints, and prime-support constraints interact as a coherent theory, and then push that theory to derive nontrivial exclusion theorems and a verified search/elimination algorithm.

## Core Vision

An odd perfect number \(n\) would satisfy
\[
\sigma(n)=2n,\qquad n\ \text{odd}.
\]
This is a fixed-point equation for the abundancy index
\[
I(n):=\frac{\sigma(n)}{n},
\]
and because \(I\) is multiplicative on coprime inputs, odd perfect numbers are exactly the odd integers whose prime-power local factors multiply to \(2\). That reframes the problem as a **global balancing law for local Euler factors**
\[
I(p^a)=1+\frac1p+\cdots+\frac1{p^a}.
\]
The program is to formalize and exploit the fact that for odd \(p\), these factors are highly constrained, and the equation
\[
\prod_{p^a\parallel n} I(p^a)=2
\]
is an extreme rigidity condition.

This should produce new theorems of the form:

- exact parity and congruence restrictions on prime-power divisor-sum factors,
- sharp monotonicity and comparison principles for abundancy factors,
- lower-bound/exclusion mechanisms based on the number of distinct prime factors,
- a new “deficiency gap” object measuring how far an odd Euler-form candidate is from perfection,
- a verified computational elimination method for broad families of candidates.

## New Definitions You Must Introduce

At least one genuinely new concept is mandatory. I want **all** of the following unless Mathlib already contains a substantially identical notion under another name:

1. **Local abundancy factor**
   \[
   \operatorname{localAbundancy}(p,a):=\frac{\sigma(p^a)}{p^a}\in \mathbb{Q}.
   \]
   This should be formalized as a rational-valued function.

2. **Odd-perfect candidate in Euler form**
   A structure expressing
   \[
   n = p^k m^2,\quad p\ \text{prime},\quad p\equiv 1 \pmod 4,\quad k\equiv 1 \pmod 4,\quad \gcd(p,m)=1,\quad n\ \text{odd}.
   \]
   This should be a new structure, not just a conjunction reused ad hoc.

3. **Deficiency gap**
   For an odd Euler candidate \(n\), define
   \[
   \operatorname{gap}(n):=2-\frac{\sigma(n)}{n}\in \mathbb{Q}.
   \]
   The point is to prove positivity/lower bounds under structural assumptions.

4. **Prime-support profile**
   A function or structure encoding the multiset/list/finset of prime divisors of \(n\) together with exponents, designed to state and prove factor-count theorems.

These definitions should become the backbone of the file, not decorative add-ons.

## Precise Theorem Targets

You must prove at least 3 substantial theorems with multi-step proofs. The following are the core targets.

---

### Theorem 1: Euler-form necessity as a formal decomposition theorem

**Mathematical statement.**  
If \(n\) is an odd perfect number, then there exist \(p,k,m\in\mathbb N\) such that:

- \(p\) is prime,
- \(p \equiv 1 \pmod 4\),
- \(k \equiv 1 \pmod 4\),
- \(n = p^k m^2\),
- \(\gcd(p,m)=1\).

This is the canonical Euler form, but the important formal advance is to derive it through a reusable factorization architecture tied to multiplicative functions.

**Lean 4 target signature sketch**
```lean
theorem odd_perfect_has_euler_form
    {n : ℕ}
    (hodd : Odd n)
    (hperf : Nat.divisors.sum id n = 2 * n) :
    ∃ p k m : ℕ,
      Nat.Prime p ∧
      p % 4 = 1 ∧
      k % 4 = 1 ∧
      n = p ^ k * m ^ 2 ∧
      Nat.Coprime p m := by
```
If `Nat.divisors.sum id n` is inconvenient, define a certified `sigma : ℕ → ℕ` and use that.

**Why this matters.**  
Not because Euler’s theorem is new, but because a robust Lean formalization of it creates the central portal through which every later exclusion theorem must pass. This turns the odd perfect number conjecture into a theorem schema on Euler-form candidates.

---

### Theorem 2: Multiplicative local-factor decomposition of perfection

**Mathematical statement.**  
For any \(n = \prod p_i^{a_i}\), one has
\[
\frac{\sigma(n)}{n}=\prod_i \frac{\sigma(p_i^{a_i})}{p_i^{a_i}},
\]
and in particular for an odd perfect number
\[
\prod_i \operatorname{localAbundancy}(p_i,a_i)=2.
\]

This should not be a mere restatement of multiplicativity; it should be packaged as a theorem about the exact balancing law for odd perfect candidates.

**Lean 4 target signature sketch**
```lean
def localAbundancy (p a : ℕ) : ℚ :=
  (sigma (p ^ a) : ℚ) / (p ^ a : ℚ)

theorem odd_perfect_local_factorization
    {n : ℕ} {s : Finset ℕ} {a : ℕ → ℕ}
    (hfac :
      n = ∏ p in s, p ^ a p)
    (hprime : ∀ p ∈ s, Nat.Prime p)
    (hdistinct : s.Pairwise (· ≠ ·))
    (hperf : sigma n = 2 * n) :
    (sigma n : ℚ) / n = ∏ p in s, localAbundancy p (a p) := by
```
If the factorization API wants a different encoding, adapt; the theorem content is what matters.

**Why this matters.**  
This is the conceptual bridge from additive divisor sums to multiplicative energy balancing. It is the theorem that lets you convert structural information about prime exponents into inequalities excluding perfection.

---

### Theorem 3: Monotonicity and strict upper bounds for odd local abundancy factors

**Mathematical statement.**  
For odd prime \(p\) and exponent \(a\),
\[
1 < I(p^a) < \frac{p}{p-1},
\]
and \(I(p^a)\) is strictly increasing in \(a\). Equivalently:
\[
1+\frac1p \le I(p^a) < 1+\frac1{p-1}.
\]

**Lean 4 target signature sketch**
```lean
theorem localAbundancy_lt_geom_limit
    {p a : ℕ} (hp : Nat.Prime p) (hodd : p ≠ 2) :
    localAbundancy p a < (p : ℚ) / (p - 1) := by

theorem localAbundancy_strictMono
    {p : ℕ} (hp : Nat.Prime p) :
    StrictMono (fun a : ℕ => localAbundancy p a) := by

theorem localAbundancy_gt_one
    {p a : ℕ} (hp : Nat.Prime p) :
    1 < localAbundancy p (a+1) := by
```

**Why this matters.**  
These inequalities are the fuel for every prime-support exclusion argument. They let you bound the total abundancy of an odd integer by controlling its prime set and exponents.

---

### Theorem 4: Square-part rigidity of odd perfect candidates

**Mathematical statement.**  
If \(n\) is odd perfect and \(n = p^k m^2\) is in Euler form, then every prime \(q \neq p\) dividing \(n\) occurs to an even exponent, and the unique odd exponent belongs to the Euler prime \(p\). Package this as a uniqueness theorem for the “special prime.”

**Lean 4 target signature sketch**
```lean
theorem odd_perfect_unique_special_prime
    {n p k m : ℕ}
    (hp : Nat.Prime p)
    (hdecomp : n = p ^ k * m ^ 2)
    (hcop : Nat.Coprime p m)
    (hperf : sigma n = 2 * n)
    (hodd : Odd n) :
    ∀ q : ℕ, Nat.Prime q → q ∣ n →
      ((Nat.factorization n q) % 2 = 1 ↔ q = p) := by
```

**Why this matters.**  
This upgrades Euler form from existence to uniqueness of the odd-exponent prime. That is the exact kind of theorem a later exclusion algorithm can exploit.

---

### Theorem 5: Deficiency-gap lower bound from truncated prime support

This is where I want actual novelty.

**Mathematical statement.**  
Let \(n\) be an odd Euler-form candidate with prime support \(S\). If
\[
\prod_{p\in S}\frac{p}{p-1} < 2,
\]
then \(n\) is not perfect. More strongly, define
\[
\operatorname{gap}(n)=2-\frac{\sigma(n)}{n}.
\]
Then under the same support condition,
\[
\operatorname{gap}(n) \ge 2-\prod_{p\in S}\frac{p}{p-1} > 0.
\]

This gives a certified exclusion principle based only on the prime support, independent of exact exponents.

**Lean 4 target signature sketch**
```lean
def deficiencyGap (n : ℕ) : ℚ :=
  2 - (sigma n : ℚ) / n

theorem deficiencyGap_lower_bound_of_support
    {n : ℕ} {s : Finset ℕ}
    (hodd : Odd n)
    (hsupport : ∀ p, p ∈ s ↔ Nat.Prime p ∧ p ∣ n)
    (hbound : ∏ p in s, ((p : ℚ) / (p - 1 : ℕ)) < 2) :
    deficiencyGap n > 0 := by
```
You may need to rewrite the product term to avoid coercion issues.

**Why this matters.**  
This is the first genuinely algorithmic theorem in the file: it turns a hard existential arithmetic question into a finite support-checking certificate. It is exactly the kind of theorem that scales computationally.

---

### Theorem 6: Cross-domain theorem — odd perfect numbers and analytic/multiplicative energy

You must include at least one theorem connecting to a different domain. The cleanest path is to connect number theory to **analysis/ordered algebra** via logarithms or convexity-inspired inequalities on Euler factors, or to **combinatorics** via support counting.

A good target is:

**Mathematical statement.**  
For an odd perfect candidate with distinct prime divisors \(p_1,\dots,p_r\),
\[
\log 2 = \sum_{i=1}^r \log I(p_i^{a_i}),
\]
hence if one has certified upper bounds
\[
\log I(p_i^{a_i}) \le \log\!\left(\frac{p_i}{p_i-1}\right),
\]
then one gets a lower bound on \(r\) from any finite prime set. Even if you do not fully formalize real logarithms, you can prove the combinatorial inequality
\[
2 = \prod_i I(p_i^{a_i}) \le \prod_i \frac{p_i}{p_i-1},
\]
and interpret it as an “energy barrier.”

**Lean 4 target signature sketch**
```lean
theorem odd_perfect_support_energy_barrier
    {n : ℕ} {s : Finset ℕ} {a : ℕ → ℕ}
    (hfac : n = ∏ p in s, p ^ a p)
    (hprime : ∀ p ∈ s, Nat.Prime p)
    (hoddp : ∀ p ∈ s, p ≠ 2)
    (hperf : sigma n = 2 * n) :
    (2 : ℚ) ≤ ∏ p in s, ((p : ℚ) / (p - 1 : ℕ)) := by
```

**Cross-domain connection.**  
This is number theory meeting ordered algebra / analytic inequality theory / statistical mechanics intuition: perfection becomes a partition-function balancing law, and the support-energy barrier says only sufficiently rich prime spectra can reach the critical value 2.

## Most Promising Proof Strategies

You asked for 2–3 proof strategy steps. Here are the principal architectures.

### Strategy A: Factorization-first multiplicative rigidity
Most promising.

1. Define `sigma`, `localAbundancy`, `deficiencyGap`, and a robust interface to `Nat.factorization`.
2. Prove multiplicativity of `sigma` on coprime products and derive the exact product formula for `localAbundancy`.
3. Prove prime-power inequalities:
   - geometric-series expression for `sigma (p^a)`,
   - upper bound by infinite geometric limit,
   - strict monotonicity in exponent.
4. Push these bounds through finite products to obtain support-based exclusion theorems and the energy barrier.
5. Use parity/factorization arguments to isolate the unique odd exponent and package Euler form.

**Why this is best:** it converts the whole conjectural landscape into reusable lemmas on multiplicative functions and prime support. It is the strongest platform for future work.

### Strategy B: Valuation-parity route
Also strong, especially for Euler form and uniqueness of the special prime.

1. Express exponents via `Nat.factorization n p`.
2. Analyze parity of exponents using square decomposition and oddness assumptions.
3. Show that if \(\sigma(n)=2n\) with \(n\) odd, then exactly one prime exponent is odd.
4. Upgrade the resulting decomposition to Euler form using congruence information mod 4.

**Why useful:** this is the cleanest path to the special-prime uniqueness theorem and square-part structure.

### Strategy C: Finite-support optimization / certified elimination
Best for the algorithmic deliverable.

1. For a finite set of odd primes \(S\), compute the support upper bound
   \[
   U(S)=\prod_{p\in S}\frac{p}{p-1}.
   \]
2. Prove that if \(U(S)<2\), then no odd perfect number has exactly that prime support.
3. Refine with partial exponent information using exact local factors \(I(p^a)\).
4. Build a search procedure that prunes candidate supports and Euler primes.

**Why useful:** this produces a demo and a verified computational method, not just static theorem statements.

## Existing Catalog Results to Build On

Use the catalog aggressively, but explain how.

- `multiplicative_prime_partition`
  - file: `FINAL/Algebra/CausalCertification.lean`
  - Use it to split multiplicative data across coprime prime-supported pieces. Even if originally stated in a different context, the key idea is partitioning multiplicative structure along prime support. This is likely useful when separating the Euler prime from the square part.

- `prime_ne_two_odd`
  - file: `Algebra/Goldbach/Theorems.lean`
  - Use it whenever deriving oddness of prime divisors distinct from 2. This should simplify local factor inequalities for odd primes.

- `prime_odd_mod`
  - file: `Algebra/QuadraticReciprocity/Core.lean`
  - Useful for reducing congruence conditions and obtaining `% 2 = 1` facts needed in parity-sensitive arguments.

- `r2_prime_1mod4_divisor_structure`
  - file: `Algebra/Factoring/Quantum.lean`
  - Even if not directly about perfect numbers, it suggests a certified route to prime \( \equiv 1 \pmod 4 \) divisor structure. Mine it for congruence reasoning patterns that can help prove the Euler prime satisfies \(p \equiv 1 \pmod 4\).

Do **not** force irrelevant catalog theorems into the proof. Use them where they genuinely compress a parity or factorization step.

## Conjecture with Testable Prediction

State at least one falsifiable conjecture and connect it to a computational test.

### Conjecture: Support-deficiency amplification
For every odd Euler-form candidate
\[
n = p^k m^2,
\]
if the distinct prime divisors of \(n\) are \(q_1<\cdots<q_r\), then
\[
\frac{\sigma(n)}{n}
<
\prod_{i=1}^{r-1}\frac{q_i}{q_i-1}\cdot \operatorname{localAbundancy}(p,k),
\]
and for the first \(100\) odd primes this product never reaches \(2\) unless \(r\) exceeds a large explicit threshold.

**Testable prediction:** a verified search over all finite supports contained in the first \(N\) odd primes, with Euler-prime choices and bounded special exponents, will certify `deficiencyGap n > 0` for every candidate encountered. A counterexample would immediately falsify the conjecture.

You may include a stronger computational conjecture if experiments support it:
- among supports of size at most 100, the maximal possible abundancy upper bound remains \(<2\) under additional congruence restrictions on the Euler prime;
- or, the minimal support size compatible with the energy barrier exceeds known lower bounds when one incorporates exact small-prime local factors.

## Verified Algorithm / Computational Method

This is mandatory.

Build a certified procedure that, given a finite set of odd primes \(S\), computes the upper bound
\[
U(S)=\prod_{p\in S}\frac{p}{p-1}
\]
and returns a proof that if \(U(S)<2\), then no odd perfect number has prime support exactly \(S\).

Then extend it to Euler-form candidates:
- input: `p, k, T` where candidate shape is `p^k * (∏ q in T, q^(2*b q))`,
- compute exact/upper local abundancy product,
- return either:
  - a proof of exclusion via `deficiencyGap > 0`, or
  - “undetermined.”

This is not optional. The point is to create a machine-checkable arithmetic sieve driven by theorem-level guarantees.

## demo.py

Mandatory. It should:
1. let the user input a finite odd-prime support,
2. compute the support-energy upper bound,
3. explain whether the support is excluded,
4. optionally scan Euler-prime candidates and exponents,
5. visualize how the product of local abundancy factors approaches but fails to reach 2.

Make the demo mathematically explanatory, not just computational.

## Deliverables

You must produce **all** of the following.

### 1. Lean file
Containing:
- the new definitions,
- at least 3 substantial theorems with nontrivial proof tactics,
- at least one cross-domain theorem,
- one conjecture with computational test,
- minimal sorry usage.

### 2. `FUTURE_DIRECTIONS.md`
3–5 original research directions.  
Each direction must include the exact sentences:
- **“The key insight is...”**
- **“Why now?”**

At least one direction must bridge to a different domain, such as:
- analytic number theory,
- probabilistic combinatorics,
- dynamical systems via multiplicative flows,
- statistical mechanics via partition-function analogies,
- computational complexity of multiplicative certificates.

### 3. `RESEARCH_PAPER.md`
A standalone scientific paper. Someone reading only this must understand:
- the new definitions,
- the main theorems,
- why multiplicative rigidity is the right lens,
- the algorithmic elimination principle,
- what the conjecture predicts next.

Do not write it like code documentation. Write it like a real mathematics paper.

### 4. `ARTICLE.md`
Scientific American style.  
Explain the ideas to a broad audience:
- what a perfect number is,
- why odd perfect numbers are mysterious,
- how local prime factors act like interacting components,
- why the new “energy barrier” viewpoint matters.

**Taboo:** do **not** focus on formal verification machinery. Focus on the mathematics and significance.

### 5. Verified algorithm / computational method
As specified above.

### 6. `demo.py`
Interactive demonstration as specified above.

## Application Keywords

odd perfect numbers; divisor-sum function; multiplicative functions; abundancy index; Euler form; prime factorization; parity rigidity; support exclusion; analytic inequalities; certified search; arithmetic energy barrier; finite support optimization; algorithmic number theory; congruence obstructions; multiplicative combinatorics; statistical mechanics analogy

## Final Standard

Do not give me a weak file that merely encodes folklore statements. Build a **formal theory of multiplicative rigidity for odd perfect numbers**. The theorem statements should be sharp enough that, if the full conjecture remains open, the resulting framework still changes how one attacks it.

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
