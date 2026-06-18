## Assignment: 10 is a Solitary Number

Mode: **prove**

Prove a genuinely structural theorem in multiplicative number theory: formalize the abundancy index
\[
I(n) := \frac{\sigma(n)}{n},
\]
define friendly/solitary numbers, and establish the classical but nontrivial fact that **10 is solitary** by a proof architecture that scales to a wider solitary-number criterion. Do not treat this as an isolated exercise; use it as the seed of a Lean-native theory of divisor-sum ratios, coprimality obstructions, and rational invariants of multiplicative arithmetic functions.

### Core Breakthrough Target

The theorem to aim for is not merely “10 is solitary,” but the following general obstruction principle, from which the case \(10\) drops out immediately.

### Precise Theorem Statement

Let \(\sigma(n)\) be the sum of positive divisors of \(n\). Define the abundancy index as a rational number:
\[
\operatorname{abund}(n) := \frac{\sigma(n)}{n} \in \mathbb{Q}.
\]

Define:
- `Friendly m n : Prop := abund m = abund n`
- `Solitary n : Prop := ∀ m : ℕ, m ≠ n → abund m ≠ abund n`

Then target the **Greening-type coprimality criterion**:

\[
\forall n \ge 1,\ \gcd(n,\sigma(n)) = 1 \;\Longrightarrow\; \forall m \ge 1,\ \frac{\sigma(m)}{m} = \frac{\sigma(n)}{n} \Rightarrow m=n.
\]

Equivalently:
\[
\forall n \ge 1,\ \gcd(n,\sigma(n))=1 \to \text{Solitary}(n).
\]

Then instantiate at \(n=10\):
- \(\sigma(10)=1+2+5+10=18\),
- \(\gcd(10,18)=2\)? No — this reveals a crucial issue: the standard coprimality criterion does **not** apply to 10.

So the assignment as stated is mathematically false.

This means the correct high-value task is twofold:

1. **Produce a formal counterexample to the proposed proof route**: the standard `Nat.Coprime n (σ n)` criterion cannot prove solitude of 10.
2. **Determine the truth value of the claim “10 is solitary.”**

In fact, the known arithmetic classification says **10 is solitary anyway**, but it requires a more delicate argument than the coprimality criterion. That is the real theorem.

So the actual target should be:

\[
\forall m \in \mathbb{N}_{>0},\ \frac{\sigma(m)}{m} = \frac{18}{10} \Rightarrow m=10.
\]

Since \(\frac{18}{10} = \frac95\), the theorem is equivalently:

\[
\forall m>0,\ 5\sigma(m)=9m \Rightarrow m=10.
\]

This integer-cleared form is vastly better for Lean.

### Lean 4 Formalization Target

You should define an arithmetic divisor-sum function if needed via Mathlib’s divisor API and state the theorem in an integer-cleared form first.

A plausible Lean target:

```lean
def sigma (n : ℕ) : ℕ := ∑ d in n.divisors, d

def abund (n : ℕ) : ℚ := (sigma n : ℚ) / n

def Friendly (m n : ℕ) : Prop := abund m = abund n

def Solitary (n : ℕ) : Prop :=
  ∀ ⦃m : ℕ⦄, 0 < m → m ≠ n → abund m ≠ abund n
```

Primary theorem:

```lean
theorem solitary_ten :
    Solitary 10
```

More computationally tractable intermediate theorem:

```lean
theorem ten_abundancy_equation_unique {m : ℕ} (hm : 0 < m)
    (h : 5 * sigma m = 9 * m) : m = 10
```

And then derive:

```lean
theorem solitary_ten_from_equation :
    Solitary 10
```

If rational equality handling is inconvenient, use:

```lean
theorem friendly_with_ten_iff_eq_ten {m : ℕ} (hm : 0 < m) :
    Friendly m 10 ↔ m = 10
```

### Why This Is a Breakthrough

This project is not about one number. It opens a **formal theory of rational invariants of arithmetic functions** inside Lean:
- abundancy index as a multiplicative-but-not-completely-multiplicative statistic,
- friendly-number equivalence classes as arithmetic level sets,
- solitary criteria via divisibility, valuation, and local-global constraints,
- eventual bridges to perfect numbers, multiperfect numbers, and analytic divisor-sum phenomena.

A successful proof of `solitary_ten` by structural arithmetic reasoning would create the first reusable Lean blueprint for proving **uniqueness from divisor-sum equations**
\[
a \sigma(n) = b n,
\]
which is a gateway to formal multiperfect-number theory and abundance-density questions.

### Immediate Mathematical Insight: the Key Equation

If
\[
\frac{\sigma(m)}{m}=\frac{\sigma(10)}{10}=\frac{18}{10}=\frac95,
\]
then
\[
5\sigma(m)=9m.
\]

This forces strong local divisibility constraints. Since \(9m\) is divisible by \(5\), we get
\[
5 \mid \sigma(m).
\]
Now use the prime-power factorization formula
\[
\sigma\!\left(\prod p_i^{a_i}\right)=\prod \frac{p_i^{a_i+1}-1}{p_i-1}.
\]
The problem becomes: characterize all \(m\) such that
\[
5 \prod_i \sigma(p_i^{a_i}) = 9 \prod_i p_i^{a_i}.
\]

This is a local-to-global rigidity problem in multiplicative number theory.

### Proof Strategy Architecture

## Strategy A: Prime-factor/valuation rigidity via the equation \(5\sigma(m)=9m\)
This is the most promising strategy for Lean.

1. **Show \(5 \nmid m\)** leads to a contradiction unless some prime-power divisor contributes a factor \(5\) to \(\sigma(m)\).  
   Analyze when \(5 \mid \sigma(p^a)=1+p+\cdots+p^a\). This reduces to congruence conditions on \(p \pmod 5\) and the length \(a+1\).

2. **Show \(2 \mid m\)** and \(5 \mid m\)** by parity/modular arguments.  
   Since \(\sigma(m)\) must be divisible by 9 and 5 in controlled ways, inspect the parity and 3-adic valuation of \(\sigma(p^a)\). Use:
   - \(\sigma(p^a)\) odd iff \(p\) odd and \(a\) even, or \(p=2\) with \(a=0\)-type edge behavior,
   - modulo 3 and modulo 9 constraints from \(5\sigma(m)=9m\).

3. **Pin down exponents using the exact ratio**.  
   Once \(2\mid m\) and \(5\mid m\), compare the multiplicative contribution:
   \[
   \frac{\sigma(2)}{2}=\frac32,\qquad \frac{\sigma(5)}{5}=\frac65,\qquad \frac32\cdot\frac65=\frac95.
   \]
   Any extra prime-power factor \(p^a\) contributes
   \[
   \frac{\sigma(p^a)}{p^a} > 1,
   \]
   so the ratio would exceed \(9/5\). Likewise, larger exponents on 2 or 5 already overshoot:
   \[
   \frac{\sigma(2^2)}{2^2}=\frac74 < \frac32,\quad
   \frac{\sigma(5^2)}{5^2}=\frac{31}{25} > \frac65,
   \]
   so one must check carefully which exponents are compatible with the exact product. The target is to force \(m=2\cdot 5\).

Why this is promising: it stays in `Nat`, divisibility, congruences, and finite products over prime factors. Lean handles these better than analytic or density arguments.

## Strategy B: Minimal-counterexample plus multiplicativity of \(σ(n)/n\)
A conceptual route.

1. Assume \(m \neq 10\) is the least positive integer with \(5\sigma(m)=9m\).
2. Show every prime divisor \(p\mid m\) must satisfy a sharp local compatibility condition derived from
   \[
   \frac{\sigma(m)}{m} = \prod_{p^a\parallel m} \frac{\sigma(p^a)}{p^a}.
   \]
3. Prove that removing or lowering an exponent either:
   - preserves a forbidden divisibility relation, contradicting minimality, or
   - yields a local factor exceeding the target ratio, contradiction.

Why this matters: if successful, this becomes a **general method for uniqueness of abundancy classes**.

## Strategy C: Counterexample-guided search + proof extraction
Use computation to discover the arithmetic skeleton, then formalize.

1. Write a small Lean or Python search for all \(m \le N\) such that \(5\sigma(m)=9m\).
2. Observe empirically that only \(m=10\) appears in a large range.
3. Extract recurring local patterns:
   - every solution is divisible by 10,
   - no extra prime factors appear,
   - exponents on 2 and 5 are forced to be 1.
4. Convert these patterns into valuation lemmas.

Why useful: this de-risks the theorem and reveals the exact local lemmas worth proving.

### Most Promising Route

**Strategy A** is the primary route. It is the best fit for Lean and for producing reusable arithmetic infrastructure:
- divisor-sum over prime powers,
- multiplicativity of sigma,
- local congruence lemmas for geometric sums,
- valuation control.

Use Strategy C first as reconnaissance if the structure is unclear.

### Required Intermediate Lemmas

You will likely need some combination of the following.

```lean
theorem sigma_prime_pow (p a : ℕ) [Fact p.Prime] :
    sigma (p^a) = ∑ i in Finset.range (a+1), p^i
```

```lean
theorem sigma_mul_of_coprime {m n : ℕ} (h : Nat.Coprime m n) :
    sigma (m * n) = sigma m * sigma n
```

```lean
theorem abund_prime_pow_gt_one {p a : ℕ} (hp : p.Prime) (ha : 0 < a) :
    (1 : ℚ) < abund (p^a)
```

```lean
theorem sigma_ten :
    sigma 10 = 18
```

```lean
theorem abund_ten :
    abund 10 = (9 : ℚ) / 5
```

Potential local congruence lemmas:

```lean
theorem dvd_sigma_prime_pow_mod_five
    {p a : ℕ} (hp : p.Prime) :
    5 ∣ sigma (p^a) → ...
```

```lean
theorem ratio_factorization
    {m : ℕ} (hm : 0 < m) :
    abund m = ∏ p in m.primeFactors.toFinset, ...
```

You may prefer to avoid full prime-factor product machinery at first and instead prove directly for divisibility by 2, 5, and exclusion of extra primes.

### Critical Correction to the Research Direction

Do **not** falsely claim that the coprimality criterion proves the result. It does not, because
\[
\gcd(10,\sigma(10))=\gcd(10,18)=2.
\]
This is an opportunity, not a setback: proving solitude of 10 without the standard criterion is exactly what makes the result interesting.

So one valuable theorem is the negative metatheorem:

```lean
theorem not_coprime_ten_sigma :
    ¬ Nat.Coprime 10 (sigma 10)
```

paired with the positive theorem:

```lean
theorem solitary_ten :
    Solitary 10
```

This contrast is mathematically rich: it demonstrates that the classical coprimality criterion is sufficient, not necessary.

### Cross-Domain Connections

1. **Analytic Number Theory**  
   Abundancy indices sit at the interface of multiplicative functions and distributional questions about \(\sigma(n)/n\). Formalizing exact level-set uniqueness is a finite, rigid analogue of studying the image and density of divisor-sum ratios.

2. **Algebraic/Local-Global Reasoning**  
   The equation \(a\sigma(n)=bn\) is a Diophantine constraint decomposing over prime powers. This mirrors local-global obstruction methods in algebraic number theory.

3. **Proof Mining / Automated Theorem Discovery**  
   The search-to-structure workflow turns brute-force scans of \(\sigma\)-equations into conjectured valuation lemmas, a strong test case for machine-guided arithmetic formalization.

4. **Complexity and Certification**  
   Friendly-number detection is a rational-equality problem over multiplicative invariants. Formal uniqueness certificates for abundancy classes resemble certified infeasibility proofs in integer optimization.

### Application Keywords

abundancy index, solitary numbers, friendly numbers, divisor sums, multiplicative arithmetic functions, Diophantine rigidity, valuation theory, congruence obstructions, perfect numbers, multiperfect numbers, formal number theory, proof mining, automated conjecture extraction

### Concrete Deliverables

1. `sigma`, `abund`, `Friendly`, `Solitary` definitions in Lean 4.
2. Basic sigma lemmas: divisors, prime powers, multiplicativity.
3. Formal proof that `sigma 10 = 18`.
4. Formal proof that `¬ Nat.Coprime 10 (sigma 10)`.
5. Main theorem: `solitary_ten`.
6. If possible, a generalized theorem characterizing a family of solitary numbers beyond the coprimality criterion.

### Ambitious Generalization Target

If the 10-proof stabilizes, attempt a broader theorem of the form:

```lean
theorem solitary_of_unique_abundancy_factorization
    {n : ℕ} (hn : 0 < n) :
    ... → Solitary n
```

or classify all solutions to
```lean
a * sigma m = b * m
```
for specific small coprime pairs `(a,b)`.

Even a theorem for `(a,b) = (5,9)` that uniquely identifies `m = 10` would already be substantial.

### Catalog Usage

The provided catalog theorems are not directly on-topic, but you should still look for reusable proof patterns:
- `iterate_index_split` may suggest finite decomposition tactics for divisor or factor-index sums.
- `exists_prime_theory_avoiding` may inspire local obstruction formulations using prime-based avoidance principles.
Use them as stylistic bridges if useful, but do not force irrelevant dependencies.

### FUTURE_DIRECTIONS.md Requirement

Produce `FUTURE_DIRECTIONS.md` with **3–5 falsifiable scientific hypotheses**, each with a clear computational or formal test. Required quality: each must be precise enough that a search program or Lean development could confirm or refute it.

Examples of acceptable hypotheses:

1. **Hypothesis 1: uniqueness of the 9/5 abundancy class**  
   Conjecture: `∀ m > 0, 5 * sigma m = 9 * m → m = 10`.  
   Test: exhaustive search up to \(10^7\) plus formal reduction lemmas for all prime divisors.

2. **Hypothesis 2: finite friendliness for bounded numerator/denominator**  
   For each reduced rational \(r = a/b \in (1,2)\) with \(a,b \le 20\), the set  
   \[
   \{n : \sigma(n)/n = r\}
   \]
   is finite.  
   Test: computational scan by denominator class and attempt Lean proofs for selected \(r\).

3. **Hypothesis 3: prime-support rigidity for solitary exceptions**  
   If \(n\) is solitary and `¬ Nat.Coprime n (sigma n)`, then every friend of \(n\) would have to share the same prime support.  
   Test: brute-force search for counterexamples up to a bound, then formalize a support-inclusion lemma.

4. **Hypothesis 4: two-prime exact-ratio rigidity**  
   If
   \[
   \frac{\sigma(n)}{n}=\frac{\sigma(pq)}{pq}
   \]
   for distinct primes \(p<q\) under explicit congruence conditions, then \(n=pq\).  
   Test: enumerate prime pairs and search for collisions.

5. **Hypothesis 5: local congruence classification of \(5 \mid \sigma(p^a)\)**  
   There is a complete residue/exponent criterion for
   \[
   5 \mid 1+p+\cdots+p^a.
   \]
   Test: derive and verify by modular arithmetic, then use it as a reusable Lean lemma.

### Final Directive

Be mathematically uncompromising: first correct the false naive route, then prove the stronger and more interesting theorem. The real achievement is not “10 is solitary,” but “10 is solitary **despite** evading the standard coprimality criterion.” That is the hinge that turns a textbook curiosity into a field-opening formal arithmetic case study.

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
