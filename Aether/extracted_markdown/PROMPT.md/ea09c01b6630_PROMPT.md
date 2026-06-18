## Assignment: Odd Perfect Numbers — from impossible target to formal obstruction theory

**Mode:** `prove` with a strategic `formalize` subprogram.

Do **not** spend the cycle merely restating folklore. The headline conjecture “there are no odd perfect numbers” is almost certainly beyond a single cycle, and formalizing known lower bounds alone is not a breakthrough. The real opportunity is to build a **formal obstruction framework for odd perfect numbers** inside Lean 4: a machine-checkable architecture showing that any odd perfect number would have to satisfy a rapidly tightening web of multiplicative, congruential, and valuation constraints. This creates a reusable theory of “perfect obstruction certificates” for multiplicative Diophantine problems.

Your goal is to prove at least one genuinely new structural theorem and formalize several deep necessary conditions in a way that can later support computational elimination and contradiction extraction.

---

## Core Vision

Let `σ : ℕ → ℕ` be the sum-of-divisors function. An odd perfect number is an odd `n` such that `σ n = 2 * n`.

The classical Euler form says that any odd perfect number must be of the shape
\[
n = p^{\alpha} m^2
\]
where `p` is prime, `p ≡ α ≡ 1 [MOD 4]`, and `gcd p m = 1`.

That alone is not enough. The breakthrough direction is to formalize and then sharpen the interaction between:

- multiplicativity of `σ`,
- `p`-adic valuations of `σ(q^e)`,
- congruence restrictions modulo small bases,
- the squarefree/square decomposition forced by perfectness,
- lower bounds on the number of distinct prime divisors and total prime multiplicity.

This should culminate in a theorem family of the form:

> **Any odd perfect number induces a finite obstruction certificate consisting of one Euler prime and a collection of local valuation inequalities whose aggregate defect is impossible below enormous complexity thresholds.**

Even if you do not close the conjecture, that is field-opening: it converts the problem from folklore number theory into a formal, compositional theory of multiplicative obstructions.

---

## Precise theorem targets

You should aim to formalize the following theorems in Lean 4, with exact statements as close as possible to the signatures below.

### 1. Euler decomposition theorem for odd perfect numbers

This is foundational and should be proved cleanly and reusable.

```lean
theorem odd_perfect_has_euler_form
    {n : ℕ}
    (hodd : n % 2 = 1)
    (hperf : Nat.divisors.sum id n = 2 * n) :
    ∃ p a m : ℕ,
      Nat.Prime p ∧
      a % 2 = 1 ∧
      p % 4 = 1 ∧
      a % 4 = 1 ∧
      n = p ^ a * m ^ 2 ∧
      Nat.Coprime p m
```

If `Nat.divisors.sum id n` is inconvenient, define:

```lean
def sigma (n : ℕ) : ℕ := n.divisors.sum id
def Perfect (n : ℕ) : Prop := sigma n = 2 * n
```

and then state:

```lean
theorem odd_perfect_has_euler_form'
    {n : ℕ} (hodd : Odd n) (hperf : Perfect n) :
    ∃ p a m : ℕ,
      Nat.Prime p ∧ Odd a ∧ p % 4 = 1 ∧ a % 4 = 1 ∧
      n = p ^ a * m ^ 2 ∧ Nat.Coprime p m
```

This is not just bookkeeping: it is the portal through which every later obstruction enters.

---

### 2. Uniqueness of the nonsquare prime exponent

Push beyond the standard decomposition and show uniqueness at the level of factorization parity.

```lean
theorem odd_perfect_unique_odd_exponent_prime
    {n : ℕ}
    (hodd : Odd n)
    (hperf : Perfect n) :
    ∃! p : ℕ,
      Nat.Prime p ∧
      Odd (n.factorization p)
```

This theorem is conceptually stronger than Euler form as a factorization invariant. It reframes odd perfect numbers as having exactly one “parity defect” in the prime-exponent vector.

This is a beautiful formal theorem because it links:
- perfectness,
- arithmetic function multiplicativity,
- factorization parity geometry in `ℕ →₀ ℕ`.

If proved, it becomes the canonical API theorem for future work.

---

### 3. Sigma parity classification for odd numbers

A key local theorem that makes Euler form almost inevitable:

```lean
theorem sigma_odd_iff_square_or_twice_square
    {n : ℕ} :
    Odd (sigma n) ↔ ∃ k : ℕ, n = k^2 ∨ n = 2 * k^2
```

Then derive the odd case:

```lean
theorem odd_sigma_odd_iff_square
    {n : ℕ} (hodd : Odd n) :
    Odd (sigma n) ↔ ∃ k : ℕ, n = k^2
```

This is a major structural theorem in its own right. For an odd perfect number, `sigma n = 2n` has controlled parity, and the prime-power decomposition then forces exactly one odd exponent.

This theorem is a gateway result for many multiplicative-function projects, not only odd perfect numbers.

---

### 4. A valuation obstruction theorem for Euler components

This is the most visionary target. Define the local sigma factor:

```lean
def sigmaPP (p a : ℕ) : ℕ := ∑ i in Finset.range (a+1), p^i
```

For `n = p^a * m^2` with `Nat.Coprime p m`, prove a theorem constraining valuations of the sigma factors contributed by primes dividing `m`.

A useful first precise target:

```lean
theorem odd_perfect_euler_component_divisibility
    {n p a m : ℕ}
    (hp : Nat.Prime p)
    (ha : Odd a)
    (hcop : Nat.Coprime p m)
    (hn : n = p^a * m^2)
    (hperf : Perfect n) :
    sigmaPP p a ∣ 2 * m^2
```

and, using coprimality,

```lean
theorem odd_perfect_euler_component_divides_square_part
    {n p a m : ℕ}
    (hp : Nat.Prime p)
    (ha : Odd a)
    (hcop : Nat.Coprime p m)
    (hoddp : Odd p)
    (hn : n = p^a * m^2)
    (hperf : Perfect n) :
    sigmaPP p a ∣ m^2
```

This is not folklore fluff: it says the Euler factor’s sigma value is absorbed entirely by the square part. That creates a mechanism for forcing many prime divisors of `m`, and it is a clean formal stepping stone to lower-bound the number of prime factors.

---

### 5. Distinct-prime lower bound via sigma-factor support

You may not reach “at least 101 prime factors” formally this cycle, but you should prove a theorem schema that turns divisibility of sigma prime-power factors into lower bounds on support size.

A good theorem statement is:

```lean
theorem prime_support_lower_bound_from_sigma_factors
    {p a m : ℕ}
    (hp : Nat.Prime p)
    (ha : 1 ≤ a)
    (hcop : Nat.Coprime p m)
    (hdiv : sigmaPP p a ∣ m^2) :
    (sigmaPP p a).factorization.support.card ≤ m.factorization.support.card
```

This exact inequality may need refinement, e.g. replacing `sigmaPP p a` by its squarefree kernel/radical. If radical is easier to define:

```lean
def rad (n : ℕ) : ℕ := ∏ q in n.factorization.support, q

theorem rad_sigmaPP_dvd_m
    {p a m : ℕ}
    (hp : Nat.Prime p)
    (ha : 1 ≤ a)
    (hcop : Nat.Coprime p m)
    (hdiv : sigmaPP p a ∣ m^2) :
    rad (sigmaPP p a) ∣ m
```

This is extremely promising. It transforms perfectness into a support-growth law. Once formalized, it opens a route to iterative lower bounds on the number of prime divisors.

---

## Most promising proof strategies

### Strategy A: factorization-parity route through sigma parity
**Best first path.**

1. Prove `sigma_odd_iff_square_or_twice_square` by reducing to prime powers:
   - `sigma (p^a) = 1 + p + ... + p^a`
   - for odd prime `p`, this sum is odd iff `a` is even
   - use multiplicativity of `sigma` on coprime products.

2. Apply to odd `n` with `Perfect n`:
   - `sigma n = 2n`, so parity and square-structure become rigid.
   - deduce that all but one prime exponent in `n.factorization` are even.

3. Extract Euler form and uniqueness of the odd exponent prime.

**Why this is best:** it is structurally clean, mostly elementary, and turns a classical argument into a reusable factorization API in Lean.

---

### Strategy B: valuation-theoretic decomposition of perfectness
**Best for originality and future leverage.**

1. Write `n = p^a * m^2` using Strategy A or factorization directly.

2. Use multiplicativity:
   \[
   \sigma(n)=\sigma(p^a)\sigma(m^2)=2p^a m^2.
   \]

3. Use coprimality lemmas to show `gcd(p^a, σ(p^a)) = 1`, hence `σ(p^a) | 2m^2`; if `p` is odd then in fact `σ(p^a) | m^2`.

4. Pass to radicals or support cardinalities:
   every prime dividing `σ(p^a)` must divide `m`.

This path can yield genuinely new support-growth theorems and is the bridge to computational elimination.

**Why it matters:** this is where “odd perfect numbers” becomes a theory of local obstruction propagation.

---

### Strategy C: congruence and modular obstruction synthesis
**Use if valuation lemmas are blocked.**

1. Formalize congruence properties of `sigmaPP p a` modulo `4`, `8`, and selected small primes.
2. Combine with Euler form and perfectness to constrain `p`, `a`, and prime divisors of `m`.
3. Build contradiction schemas for bounded support or bounded smallest prime.

For example, derive that if `n = p^a m^2` is odd perfect, then:
- `p ≡ 1 (mod 4)`,
- `a ≡ 1 (mod 4)`,
- every prime dividing `sigmaPP p a` must occur in `m`,
- hence `m` must carry a growing congruence burden.

This strategy is weaker in isolation but ideal for creating machine-searchable contradiction certificates.

---

## Lean 4 formalization guidance

You should define a small internal API rather than proving everything ad hoc.

### Suggested definitions

```lean
def sigma (n : ℕ) : ℕ := n.divisors.sum id
def Perfect (n : ℕ) : Prop := sigma n = 2 * n
def OddPerfect (n : ℕ) : Prop := Odd n ∧ Perfect n

def sigmaPP (p a : ℕ) : ℕ := ∑ i in Finset.range (a+1), p^i

def rad (n : ℕ) : ℕ := ∏ q in n.factorization.support, q
```

### Suggested helper lemmas

```lean
theorem sigma_eq_sum_divisors (n : ℕ) : sigma n = n.divisors.sum id := rfl

theorem sigma_multiplicative
    {a b : ℕ} (hcop : Nat.Coprime a b) :
    sigma (a * b) = sigma a * sigma b

theorem sigma_prime_pow
    {p a : ℕ} (hp : Nat.Prime p) :
    sigma (p^a) = sigmaPP p a

theorem sigmaPP_odd_iff_even_exp
    {p a : ℕ} (hp : Nat.Prime p) (hoddp : Odd p) :
    Odd (sigmaPP p a) ↔ Even a
```

If existing Mathlib names differ, adapt, but keep the theorem architecture.

---

## How to use the catalog theorems

The listed catalog theorems are not directly about perfect numbers, so do not force artificial dependencies. Instead, use them as inspiration for proof style and bridge-building.

- `prime_power_liars_bound` suggests there is already infrastructure around prime powers and arithmetic bounds. Mine its local lemmas and conventions for handling prime powers in `ℕ`.
- `prime_soundness` and `prime_congruence_kernel_eq_obsIndist` point toward a **cross-domain observer/kernel viewpoint**: a global arithmetic object is constrained by local prime observables. Use that philosophy explicitly in your writeup.
- `krull_height_theorem_security_prime` can inspire a speculative bridge: the support of prime factorizations behaves like a height/complexity parameter. Your support-growth theorems for odd perfect numbers can be framed as a “height explosion” phenomenon.
- `euler_four_square` is not directly relevant, but it suggests a broader Eulerian theme: algebraic composition laws can force arithmetic structure. Mention this in ARTICLE.md if produced.

Do **not** add fake dependencies just to cite the catalog. Build authentic bridges.

---

## Cross-domain connections to emphasize

### 1. Multiplicative functions ↔ information propagation
The equation
\[
\sigma(n)=2n
\]
is a global conservation law, while prime-power sigma factors are local emissions. The theorem `sigmaPP p a ∣ m^2` says local data from the Euler prime must be absorbed by the square part. This resembles **flow conservation** or **error-correcting redundancy propagation**.

### 2. Valuation geometry ↔ sparse combinatorics
The prime factorization of `n` is a vector in a free commutative monoid. Odd perfectness imposes:
- one odd coordinate,
- all others even,
- support growth under sigma-factor divisibility.

This is a discrete geometry problem on exponent lattices, not merely classical number theory.

### 3. Formal obstruction theory ↔ cryptographic hardness
A number satisfying many simultaneous local constraints resembles a cryptographic object surviving many distinguishers. The theorem family you prove can be cast as:
> any odd perfect number must evade a growing family of local tests.
This suggests algorithmic elimination procedures and certificate generation.

### 4. Algebraic dynamics of arithmetic functions
Iterating `n ↦ rad(σ(n))` or related operators may generate monotone support growth. This is a new experimental direction with possible consequences beyond perfect numbers.

---

## Application keywords

Use these explicitly in your output artifacts:

- odd perfect numbers
- multiplicative functions
- sum-of-divisors function
- Euler form
- valuation theory
- prime support growth
- arithmetic obstruction certificates
- factorization parity
- formal number theory
- Lean 4
- Mathlib
- computational Diophantine elimination
- local-to-global constraints
- exponent lattice geometry

---

## Concrete deliverables

1. **Lean 4 file(s)** proving as many of the theorem targets above as possible.
2. At minimum, establish:
   - `sigma` API,
   - multiplicativity on coprime arguments,
   - prime-power sigma formula,
   - one substantial odd-perfect structural theorem.
3. Prefer proving `odd_perfect_unique_odd_exponent_prime` over only restating Euler form.
4. If the full classical lower bounds (`> 10^1500`, `≥ 101` prime factors) are too heavy for this cycle, prove a **general lower-bound schema** that could later imply them with additional computational inputs.
5. Minimize `sorry`; if a theorem is deferred, isolate it behind the strongest reusable interface.

---

## If a direct no-go theorem fails

Do **not** fake a proof of “no odd perfect numbers exist.” Instead pivot to one of these stronger-than-folklore formal achievements:

- a uniqueness theorem for the odd exponent prime,
- a radical divisibility theorem `rad (sigmaPP p a) ∣ m`,
- a support lower-bound theorem from sigma factors,
- a contradiction theorem for odd perfect numbers with small support,
- a modular obstruction theorem combining Euler form with sigma-factor congruences.

Any of these would be a meaningful advance in formal arithmetic infrastructure.

---

## Required FUTURE_DIRECTIONS.md

You must produce `FUTURE_DIRECTIONS.md` with **3–5 testable scientific hypotheses**, each a falsifiable conjecture with a clear computational or formal test. Include at least these kinds of hypotheses:

1. **Support-growth hypothesis**  
   Conjecture: for any odd perfect candidate `n = p^a m^2`,  
   `rad (sigmaPP p a)` contains at least `f(a)` distinct primes for some explicit monotone `f`.  
   **Test:** brute-force over odd primes `p` and odd exponents `a ≤ B`.

2. **Valuation absorption hypothesis**  
   Conjecture: every prime divisor `q` of `sigmaPP p a` appears in `m` with valuation at least `1`, and often at least `2` under explicit congruence conditions.  
   **Test:** compute `v_q(sigmaPP p a)` and compare with candidate square-part requirements.

3. **Iterated radical explosion hypothesis**  
   Conjecture: repeated application of `n ↦ rad (sigma n)` to odd perfect candidates strictly increases support until contradiction.  
   **Test:** simulate on Euler-form candidates under size bounds.

4. **Congruence obstruction hypothesis**  
   Conjecture: for fixed residue classes of `p mod M` and `a mod M`, `sigmaPP p a` always introduces a prime divisor in a forbidden residue class for `m`.  
   **Test:** modular computation for small `M`.

5. **Exponent-lattice sparsity impossibility**  
   Conjecture: no odd perfect number can have prime-factor support below an explicit threshold derived from the support of `rad (sigmaPP p a))`.  
   **Test:** formalize and verify for bounded support sizes.

These hypotheses must be specific enough that the next cycle can attack them immediately.

---

## Final directive

Be ambitious but honest. The true breakthrough is not a bluff “proof” of nonexistence; it is the creation of a **formal obstruction calculus for odd perfect numbers** that makes the conjecture attackable by theorem-proving, computation, and local-to-global synthesis. Prove theorems that change the shape of the problem.

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
