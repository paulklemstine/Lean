## Assignment: Perfect Numbers as a Multiplicative Geometry of Divisor Mass

Mode: **formalize + prove**

This project should not be treated as a routine number-theory transcription. The real target is to turn “perfectness” into a formally usable multiplicative invariant theory around the divisor-sum operator `σ`, and then push far enough that Euclid–Euler becomes the first nontrivial classification theorem inside a reusable ecosystem. The breakthrough is not just to show one classical equivalence, but to create a Lean-native framework in which perfect, abundant, deficient, and odd-perfect obstructions become statements about multiplicative structure, prime-power local factors, and rational inequalities.

You should aim to formalize a coherent theory with three layers:

1. **Local layer:** exact formulas for `σ(p^k)` and normalized local abundancy.
2. **Global multiplicative layer:** coprime multiplicativity of `σ` and abundancy factorization.
3. **Classification/obstruction layer:** Euclid–Euler for even perfects, and rigorous lower-bound machinery for odd perfect numbers.

The most revolutionary aspect is to make abundancy index a first-class formal object. Once done, perfect numbers become a gateway to formal multiplicative analytic number theory: superabundant numbers, Robin-type inequalities, Euler factors, and arithmetic optimization.

### Primary Theorem Targets

#### Target A: Euclid–Euler theorem for even perfect numbers

You should formalize the exact equivalence:

> For `n : ℕ`,  
> `Perfect n ∧ Even n` if and only if there exists `p : ℕ` such that `Nat.Prime p`, `Nat.Prime (2^p - 1)`, and  
> `n = 2^(p-1) * (2^p - 1)`.

A Lean-facing formulation should be split into tractable components.

Suggested definitions:
```lean
def sigma (n : ℕ) : ℕ := n.divisors.sum id

def Perfect (n : ℕ) : Prop := 0 < n ∧ sigma n = 2 * n

def AbundancyIndex (n : ℕ) : ℚ := sigma n / n
```

More robustly, since division by zero is awkward:
```lean
def AbundancyIndex (n : ℕ) : ℚ := if h : n = 0 then 0 else (sigma n : ℚ) / n
```

Suggested theorem signatures:
```lean
theorem sigma_eq_sum_divisors (n : ℕ) :
  sigma n = n.divisors.sum id := rfl

theorem perfect_iff_sigma_eq_two_mul {n : ℕ} :
  Perfect n ↔ 0 < n ∧ sigma n = 2 * n := by
  rfl
```

The Euclid direction:
```lean
theorem euclid_even_perfect
    {p : ℕ}
    (hp : Nat.Prime p)
    (hM : Nat.Prime (2^p - 1)) :
    Perfect (2^(p-1) * (2^p - 1)) := by
```

The Euler direction:
```lean
theorem euler_even_perfect_classification
    {n : ℕ}
    (hperf : Perfect n)
    (heven : Even n) :
    ∃ p : ℕ, Nat.Prime p ∧ Nat.Prime (2^p - 1) ∧
      n = 2^(p-1) * (2^p - 1) := by
```

Combined equivalence:
```lean
theorem even_perfect_iff_euclid_euler {n : ℕ} :
    Perfect n ∧ Even n ↔
    ∃ p : ℕ, Nat.Prime p ∧ Nat.Prime (2^p - 1) ∧
      n = 2^(p-1) * (2^p - 1) := by
```

A cleaner variant may use `∃ k, n = 2^k * m ∧ Odd m` as a factorization step, then prove `k+1` is prime and `m = 2^(k+1)-1`.

---

#### Target B: Prime-power divisor-sum and multiplicativity infrastructure

You will likely need a reusable theorem package around `sigma`.

Core theorem statements to formalize:

```lean
theorem sigma_prime_pow
    {p k : ℕ}
    (hp : Nat.Prime p) :
    sigma (p^k) = ∑ i in Finset.range (k+1), p^i := by
```

```lean
theorem sigma_prime_pow_closed_form
    {p k : ℕ}
    (hp : Nat.Prime p) :
    (p - 1) * sigma (p^k) = p^(k+1) - 1 := by
```

```lean
theorem sigma_mul_of_coprime
    {a b : ℕ}
    (hcop : Nat.Coprime a b) :
    sigma (a * b) = sigma a * sigma b := by
```

```lean
theorem sigma_two_pow (k : ℕ) :
    sigma (2^k) = 2^(k+1) - 1 := by
```

These are the true engine room. Once formalized, the Euclid proof becomes conceptually inevitable rather than ad hoc.

---

#### Target C: Abundancy index as a rational multiplicative invariant

Define the normalized ratio and prove factorization properties. This is the bridge from elementary number theory to multiplicative optimization.

Suggested theorem statements:
```lean
theorem abundancyIndex_pos {n : ℕ} (hn : 0 < n) :
    0 < AbundancyIndex n := by
```

```lean
theorem abundancyIndex_eq_two_iff_perfect {n : ℕ} (hn : 0 < n) :
    AbundancyIndex n = 2 ↔ Perfect n := by
```

```lean
theorem abundancyIndex_mul_of_coprime
    {a b : ℕ}
    (ha : 0 < a) (hb : 0 < b)
    (hcop : Nat.Coprime a b) :
    AbundancyIndex (a * b) = AbundancyIndex a * AbundancyIndex b := by
```

```lean
theorem abundancy_prime_pow
    {p k : ℕ}
    (hp : Nat.Prime p) :
    AbundancyIndex (p^k) =
      ((∑ i in Finset.range (k+1), (p : ℚ)^i) / (p : ℚ)^k) := by
```

If this framework is done cleanly, you have built a formal “Euler product without analysis” for divisor mass.

---

#### Target D: Odd perfect obstruction framework

The Nielsen bound “an odd perfect number must have at least 101 prime factors” is a major theorem and likely too large for a clean cold-start formalization unless imported as a staged endpoint. Do not fake it. Instead, architect the framework so that progressively stronger lower bounds can be formalized and eventually upgraded.

You should define at least two counting invariants:

```lean
def primeFactorsFinset (n : ℕ) : Finset ℕ := n.factors.toFinset

def bigOmega (n : ℕ) : ℕ := n.factors.length

def littleOmega (n : ℕ) : ℕ := primeFactorsFinset n |>.card
```

Then target formally realistic obstruction theorems such as:

```lean
theorem odd_perfect_not_prime_power
    {n : ℕ}
    (hperf : Perfect n)
    (hodd : Odd n) :
    ¬ ∃ p k : ℕ, Nat.Prime p ∧ n = p^k := by
```

```lean
theorem odd_perfect_has_at_least_two_distinct_prime_factors
    {n : ℕ}
    (hperf : Perfect n)
    (hodd : Odd n) :
    2 ≤ littleOmega n := by
```

```lean
theorem odd_perfect_has_nontrivial_square_part
    {n : ℕ}
    (hperf : Perfect n)
    (hodd : Odd n) :
    ∃ a b : ℕ, 1 < a ∧ 1 < b ∧ n = a^2 * b := by
```

And, if feasible, Euler’s classical structural theorem:

> Any odd perfect number has the form `n = q^(4k+1) * m^2` where `q ≡ 1 [MOD 4]` and `Nat.Coprime q m`.

A Lean-style target:
```lean
theorem odd_perfect_euler_shape
    {n : ℕ}
    (hperf : Perfect n)
    (hodd : Odd n) :
    ∃ q k m : ℕ,
      Nat.Prime q ∧
      q % 4 = 1 ∧
      n = q^(4*k+1) * m^2 ∧
      Nat.Coprime q m := by
```

This would be a major achievement and a genuine launchpad toward stronger lower bounds on `littleOmega n` or `bigOmega n`.

If you mention Nielsen’s 101 bound, do so as a declared long-range theorem target:
```lean
theorem odd_perfect_bigOmega_ge_101
    {n : ℕ}
    (hperf : Perfect n)
    (hodd : Odd n) :
    101 ≤ bigOmega n := by
```
—but only if you can decompose it into a sequence of formally tractable lemmas and clearly mark dependencies. The honest breakthrough here is the scaffold.

## Proof Strategy Architecture

### Strategy A: Multiplicative divisor-sum engine first
This is the most promising route.

1. Define `sigma` via `n.divisors.sum id` and prove exact formulas for `sigma (p^k)`.
2. Prove multiplicativity on coprime products using divisor decomposition from Mathlib.
3. Factor an even perfect `n` as `2^k * m` with `m` odd, compute
   `sigma n = sigma (2^k) * sigma m`, and force
   `m = 2^(k+1)-1`, then show `m` prime and `k+1` prime.

Why this is strongest: it gives a reusable arithmetic API rather than a one-off proof. It also naturally yields the abundancy-index formalism.

### Strategy B: Abundancy-index rigidity
This is more conceptual and opens future analytic directions.

1. Define `I(n) = σ(n)/n` in `ℚ`.
2. Show `I` is multiplicative on coprime products and compute local factors
   `I(p^k) = 1 + 1/p + ... + 1/p^k`.
3. For `n = 2^k * m` odd `m`, use `I(n)=2` to deduce
   `I(m) = 2 / (2 - 1/2^k) = (2^(k+1)) / (2^(k+1)-1)`,
   then prove this forces `m = 2^(k+1)-1` prime.

Why it matters: this reframes perfectness as exact factor balance of local Euler factors, which is the right language for later odd-perfect obstructions.

### Strategy C: Prime-factor contradiction route for the converse direction
Useful if Euler classification gets stuck.

1. Assume `n` even perfect and write `n = 2^k * m` with `m` odd.
2. Use `sigma (2^k) = 2^(k+1)-1` and perfectness to show `(2^(k+1)-1) ∣ m`.
3. Show if `m` had any extra odd prime factorization beyond `2^(k+1)-1`, then `σ(n) > 2n`.
4. Conclude equality forces `m` itself to be prime and equal to `2^(k+1)-1`.

This route is less elegant but often easier to formalize because divisibility inequalities can be simpler than rational identities.

## Cross-Domain Connections You Should Exploit

### 1. Multiplicative number theory ↔ formal algebraic geometry of invariants
Treat `sigma` as a multiplicative measure on the divisor poset. The abundancy index behaves like a normalized mass functional. This creates a bridge to algebraic invariants: perfect numbers are precisely the fixed points of divisor-mass doubling. Even if the catalog theorems listed are not directly relevant mathematically, use their spirit: extract invariant-based proof patterns and package divisor identities as reusable invariant lemmas.

### 2. Analytic number theory ↔ discrete optimization
The local factor
\[
I(p^k)=1+\frac1p+\cdots+\frac1{p^k}
\]
is an optimization object. Odd perfect obstruction results become combinatorial optimization over prime multisets subject to exact product constraints. This opens formal search methods, branch-and-bound proofs, and certified exclusion arguments.

### 3. Perfect numbers ↔ information geometry / statistical mechanics
Abundancy index is a partition-function-like quantity over divisors:
\[
Z(n)=\sum_{d\mid n} d.
\]
Normalized by `n`, it is a scale-free energy statistic. Perfectness is the exact critical value `I(n)=2`. This is not decorative language: it suggests future formalization of entropy-like monotonicity over factorization types, and could inspire algorithmic theorem proving via energy barriers for odd perfect candidates.

### 4. Arithmetic structure ↔ computational complexity
Once `sigma_prime_pow` and `sigma_mul_of_coprime` are formalized, one can derive certified algorithms for checking perfectness from factorization data. This links classical number theory to verified arithmetic decision procedures.

## Concrete Lean Engineering Recommendations

- Check whether Mathlib already has:
  - `Nat.divisors`
  - lemmas about divisors of prime powers
  - `Nat.arithmetic_function` infrastructure
  - multiplicative arithmetic functions such as `ArithmeticFunction.sigma`
  
  If Mathlib’s arithmetic-function API is mature enough, do **not** rebuild everything from scratch. Instead, bridge the API to a concrete `sigma : ℕ → ℕ` theorem layer.

- Prefer theorem decomposition:
  1. divisors of `p^k`
  2. sigma on prime powers
  3. sigma multiplicative
  4. perfect/even classification

- Use `ℚ` for abundancy rather than `ℝ`; exactness matters.

- For odd perfect structure, start from factorization list lemmas on `Nat.factors`.

- If the Nielsen theorem is currently out of reach, formalize a chain of certified lower bounds:
  - odd perfect is not prime
  - not prime power
  - at least two distinct prime factors
  - Euler shape
  - lower bounds on `littleOmega` and `bigOmega`

That staircase is mathematically meaningful and formally sustainable.

## Suggested Intermediate Theorem List

```lean
theorem sigma_one : sigma 1 = 1 := by
```

```lean
theorem sigma_prime {p : ℕ} (hp : Nat.Prime p) :
    sigma p = p + 1 := by
```

```lean
theorem sigma_two_pow' {k : ℕ} :
    sigma (2^k) = 2^(k+1) - 1 := by
```

```lean
theorem mersenne_of_even_perfect
    {n k m : ℕ}
    (hperf : Perfect n)
    (hdecomp : n = 2^k * m)
    (hodd : Odd m) :
    m = 2^(k+1) - 1 := by
```

```lean
theorem mersenne_prime_of_even_perfect
    {n k m : ℕ}
    (hperf : Perfect n)
    (hdecomp : n = 2^k * m)
    (hodd : Odd m) :
    Nat.Prime m := by
```

```lean
theorem exponent_prime_of_even_perfect
    {p : ℕ}
    (hM : Nat.Prime (2^p - 1)) :
    Nat.Prime p := by
```

That last theorem is important and elegant: if a Mersenne number is prime, its exponent is prime. It is a crucial support lemma for Euclid–Euler and independently valuable.

Lean signature:
```lean
theorem prime_of_mersenne_prime
    {p : ℕ}
    (hprime : Nat.Prime (2^p - 1)) :
    Nat.Prime p := by
```

## Revolutionary Significance

If you execute this well, you will have done more than formalize a textbook theorem. You will have created:

- a Lean-native multiplicative divisor-mass theory,
- an exact rational abundancy framework,
- a scalable obstruction engine for odd perfect numbers,
- and a bridge from elementary arithmetic to formal analytic/combinatorial reasoning.

This opens the door to formal work on:
- superperfect and multiperfect numbers,
- Robin-type inequalities and divisor-sum extremality,
- certified computational searches for odd perfect obstructions,
- and arithmetic-function ecosystems in Lean that support deeper multiplicative number theory.

A particularly exciting next step is to connect abundancy index inequalities to verified branch-and-bound searches over prime exponent vectors, making odd perfect number exclusion partially algorithmic and formally certified.

## Application Keywords

perfect numbers; Euclid–Euler theorem; divisor sum; arithmetic functions; abundancy index; multiplicative invariants; Mersenne primes; odd perfect numbers; Eulerian form; certified number theory; formal analytic number theory; divisor optimization; verified arithmetic algorithms

## Deliverables

1. Lean file(s) proving as much of Targets A–D as possible with minimal sorrys.
2. Definitions for `sigma`, `Perfect`, `AbundancyIndex`, `bigOmega`, `littleOmega`.
3. A theorem dependency graph in comments or markdown.
4. `FUTURE_DIRECTIONS.md` with **3–5 concrete breakthrough next steps**, each including:
   - precise theorem statement,
   - expected Lean type signature,
   - proof strategy,
   - why it opens a new field-line.

## FUTURE_DIRECTIONS.md must explicitly include candidate next steps such as

- formalizing Euler’s odd perfect number shape theorem,
- proving monotonicity/optimization lemmas for abundancy index over prime exponent vectors,
- building a certified search/exclusion framework for odd perfect numbers below large bounds,
- formalizing multiperfect numbers `σ(n)=k*n`,
- and connecting abundancy inequalities to analytic estimates over Euler products.

Do not settle for a single classical theorem. Build the arithmetic ecology in which perfectness becomes the first solved case of a much larger formal theory.

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

Research domain: Speculative
Research mode: prove
