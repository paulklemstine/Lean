## Assignment: Hypothesis 3 — Base-Invariance for Benford Phenomena in Prime-Indexed Dynamical Sequences

**Mode:** `prove`

You are not being asked for a cosmetic extension. You are being asked to formalize a mechanism: that Benford behavior is not an accident of decimal notation, but a rigidity phenomenon forced by logarithmic equidistribution modulo 1. If this is done correctly, it opens a new formal bridge between arithmetic dynamics, uniform distribution theory, and computational detection of scale-invariant statistics.

The target is to turn the vague slogan

> “Benford in one multiplicatively independent base should imply Benford in all such bases”

into **precise Lean theorems, a formal criterion, and a verified computational pipeline**.

The phrase “Impact. Base-invariance is predicted by the equidistribution me...” is the right instinct but not yet mathematics. Your task is to identify the exact equidistribution mechanism and prove a theorem that would make this prediction rigorous under explicit hypotheses.

---

## Core Vision

The true object is not “leading digits” directly. It is the sequence of fractional parts

\[
\{\log_b |T_c^{(n)}(p)|\} \in \mathbb{R}/\mathbb{Z}.
\]

Benford in base \(b\) is equivalent to equidistribution mod 1 of this logarithmic sequence. Therefore the breakthrough theorem should show that **equidistribution of \(\alpha x_n\) mod 1 for one irrational scale \(\alpha\)** forces equidistribution for all irrational scales in a structurally meaningful class, provided the underlying sequence \(x_n\) itself has the right equidistribution property.

This is not just about one recurrence. It is about formalizing a **base-transfer principle**.

---

## Precise Theorem Targets

You must prove at least **3 nontrivial theorems** with genuine proof structure. At least one should be a new definition and at least one should connect to another domain.

### New Definition 1: Base-Benford transferability
Define a structure capturing when a positive real sequence has base-invariant Benford behavior.

Suggested Lean concept:
```lean
def BenfordBaseInvariant (u : ℕ → ℝ) : Prop :=
  ∀ b₁ b₂ : ℕ,
    2 ≤ b₁ →
    2 ≤ b₂ →
    Irrational (Real.log b₁ / Real.log 2) →
    Irrational (Real.log b₂ / Real.log 2) →
    BenfordInBase u b₁ ↔ BenfordInBase u b₂
```

You will likely need to define `BenfordInBase` first in terms of equidistribution of fractional parts:
```lean
def BenfordInBase (u : ℕ → ℝ) (b : ℕ) : Prop :=
  2 ≤ b ∧
  (∀ n, 0 < u n) ∧
  EquidistributedModOne (fun n => Real.log (u n) / Real.log b)
```

If `EquidistributedModOne` does not exist in exactly this form, define a suitable formal wrapper around whatever Mathlib provides for uniform distribution modulo 1.

---

### Theorem 1: Benford criterion via logarithmic equidistribution
This is the conceptual foundation.

**Statement.**
For every positive sequence \(u : \mathbb{N} \to \mathbb{R}_{>0}\) and base \(b \ge 2\), if the sequence
\[
n \mapsto \frac{\log(u_n)}{\log b}
\]
is equidistributed modulo \(1\), then the leading-digit distribution of \(u_n\) in base \(b\) is Benford.

Suggested Lean-style signature:
```lean
theorem benford_of_log_equidistributed
    (u : ℕ → ℝ) (b : ℕ)
    (hb : 2 ≤ b)
    (hu : ∀ n, 0 < u n)
    (heq : EquidistributedModOne (fun n => Real.log (u n) / Real.log b)) :
    BenfordInBase u b
```

This theorem should not be tautological: if your `BenfordInBase` is defined via digit frequencies rather than directly via equidistribution, then this becomes a genuine theorem. That is the more valuable route.

**Why breakthrough:** It converts a statistical statement into a theorem of harmonic analysis / uniform distribution, creating a reusable certification pipeline.

---

### Theorem 2: Base-transfer theorem from equidistribution of natural logarithms
This is the main theorem you should aim to make as strong as possible.

**Mathematical statement.**
Let \(u : \mathbb{N} \to \mathbb{R}_{>0}\). Assume the sequence \(n \mapsto \log(u_n)\) is equidistributed modulo 1 after multiplication by every nonzero real scalar in some irrationality class, or more concretely assume a sufficient criterion implying that for every base \(b\) with \(\log b / \log 2 \notin \mathbb{Q}\), the sequence
\[
n \mapsto \frac{\log(u_n)}{\log b}
\]
is equidistributed mod 1. Then \(u\) is BenfordBaseInvariant.

A more formal and achievable theorem is:

```lean
theorem benford_base_invariant_of_scaled_log_equidistribution
    (u : ℕ → ℝ)
    (hu : ∀ n, 0 < u n)
    (hscale :
      ∀ b : ℕ, 2 ≤ b →
        Irrational (Real.log b / Real.log 2) →
        EquidistributedModOne (fun n => Real.log (u n) / Real.log b)) :
    BenfordBaseInvariant u
```

This theorem is extremely important because it isolates the exact transfer principle. It says: once you can certify the equidistribution criterion uniformly over admissible bases, base-invariance is automatic.

**Why breakthrough:** It separates the arithmetic-dynamical difficulty from the digit-law consequence. This creates a modular theory: prove equidistribution once, get Benford in all bases.

---

### Theorem 3: A cross-domain theorem linking multiplicative independence to irrational logarithmic ratios
This is the required cross-domain connection: number theory + real analysis / dynamical systems.

**Statement.**
If \(a,b \in \mathbb{N}\), \(a,b \ge 2\), and \(a,b\) are multiplicatively independent, then
\[
\frac{\log a}{\log b} \notin \mathbb{Q}.
\]

Suggested Lean signature:
```lean
def MultiplicativelyIndependent (a b : ℕ) : Prop :=
  ∀ m n : ℕ, a^m = b^n → m = 0 ∧ n = 0

theorem irrational_log_ratio_of_multiplicative_independence
    {a b : ℕ} (ha : 2 ≤ a) (hb : 2 ≤ b)
    (hmi : MultiplicativelyIndependent a b) :
    Irrational (Real.log a / Real.log b)
```

This is not merely auxiliary. It formalizes the number-theoretic meaning of “base independent of 2” and lets you replace an analytic irrationality condition with a discrete algebraic one.

**Proof skeleton:** by contradiction, assume rational ratio; write \(\log a / \log b = m/n\); derive \(a^n = b^m\) using `Real.rpow_natCast` / exponential identities; contradict multiplicative independence.

**Why breakthrough:** This theorem converts the empirical base-selection criterion into a mathematically structural notion. It is exactly the kind of theorem that lets arithmetic dynamics talk to Benford theory.

---

### Theorem 4: Transfer theorem specialized to prime-indexed dynamical sequences
You need at least one theorem tied to the actual research object \(T_c^{(n)}(p)\), even if under explicit hypotheses.

If the exact catalog definition of `T_c⁽ⁿ⁾(p)` already exists, use it. If not, define a wrapper notation consistent with the existing file. The theorem should not assert full Benford for that sequence unless you can prove the equidistribution input. Instead prove a **reduction theorem**.

**Statement.**
If the logarithmic orbit sequence of the prime-indexed dynamical values is equidistributed modulo 1 in one admissible base, and if the orbit admits a base-change equidistribution transfer criterion, then Benford holds in every admissible base.

Suggested Lean signature:
```lean
theorem benford_all_admissible_bases_of_prime_orbit_transfer
    (c n : ℤ)
    (u : ℕ → ℝ)
    (hu_def : u = fun k => |T c n (primeSeq k)|)
    (hu_pos : ∀ k, 0 < u k)
    (htransfer :
      ∀ b : ℕ, 2 ≤ b →
        Irrational (Real.log b / Real.log 2) →
        EquidistributedModOne (fun k => Real.log (u k) / Real.log b)) :
    BenfordBaseInvariant u
```

If the exact prime enumeration object in Mathlib differs, adapt accordingly. The point is to **reduce the prime-orbit conjecture to a clean equidistribution statement**.

**Why breakthrough:** This gives a formal “if and only if the dynamical logarithms equidistribute” theorem, which is exactly the research architecture needed for future analytic number theory attacks.

---

## Proof Strategy Architecture

You must provide at least 2–3 proof strategy paths in the code comments or paper, and execute the most promising one in Lean.

### Strategy A: Equidistribution-first reduction
1. Define Benford in base \(b\) via asymptotic frequency of significand intervals \([1,d)\).
2. Show these digit events are exactly fractional-part events:
   \[
   \text{leading significand} < s
   \iff \{\log_b u_n\} < \log_b s.
   \]
3. Push equidistribution mod 1 through interval frequencies to get Benford.

**Why promising:** This is conceptually clean and modular. It isolates all hard arithmetic into `EquidistributedModOne`.

---

### Strategy B: Contrapositive via rational log-ratio obstruction
1. Formalize multiplicative independence.
2. Prove rationality of \(\log a/\log b\) implies a power relation \(a^m=b^n\).
3. Use this to characterize admissible bases and transfer any theorem stated in irrational-ratio form into a number-theoretic one.

**Why promising:** This gives a discrete theorem with robust Lean proof tactics (`by_contra`, `rcases`, `field_simp`, exponent manipulations). It also supplies the cross-domain theorem required by the brief.

---

### Strategy C: Weyl-criterion-inspired formal wrapper
1. Introduce a weaker formal notion, e.g. interval equidistribution on `[0,1)`.
2. Prove Benford from interval equidistribution alone, avoiding full Fourier-analytic Weyl machinery.
3. Use this as the interface theorem for computations and future strengthening.

**Why promising:** If Mathlib’s full equidistribution API is awkward, this creates a formally manageable intermediate notion. It is especially useful if you need executable tests in `demo.py`.

**Most promising route:** combine **A + B**. Strategy A proves the Benford mechanism; Strategy B gives the arithmetic meaning of admissible bases. Strategy C is a fallback if the exact equidistribution library interface is cumbersome.

---

## Required Deep Proof Tactics

Your file must contain at least 3 theorems whose proofs genuinely use multi-step reasoning. Target the following patterns:

- `by_contra` in the irrational-log-ratio theorem.
- `rcases` to unpack a rational witness \(q = m/n\).
- `field_simp` when clearing denominators in rational/log-ratio manipulations.
- `calc` chains for rewriting leading-digit conditions into logarithmic interval conditions.
- induction if you define iterates \(T_c^{(n)}\) recursively and need positivity/growth lemmas.

Do **not** hide the substance behind `simp` or definitional equality.

---

## Cross-Domain Connections You Must Make Explicit

1. **Number theory ↔ Benford law**  
   Multiplicative independence of integer bases becomes irrationality of logarithmic ratios, which controls digit statistics.

2. **Arithmetic dynamics ↔ ergodic/equidistribution theory**  
   Prime-indexed iterates \(T_c^{(n)}(p)\) become a dynamical source of logarithmic phases mod 1.

3. **Formal proof ↔ scientific computation**  
   The Lean theorem should produce a verified criterion, while `demo.py` empirically measures KL divergence and searches for refutations.

4. **Information theory ↔ digit laws**  
   KL divergence to the Benford distribution is a quantitative defect functional; this connects asymptotic distribution theory with statistical hypothesis testing.

Application keywords: `Benford law`, `equidistribution mod 1`, `arithmetic dynamics`, `multiplicative independence`, `prime orbits`, `uniform distribution`, `information theory`, `KL divergence`, `formal verification`, `scientific computing`.

---

## Build on Existing Verified Theorems

You mentioned:
- `exists_refinement_c...`

You must inspect the exact catalog theorem name and use it concretely, not ceremonially. If it concerns refinement or decomposition in the existing `T_c` framework, use it to:
- pass from coarse orbit structure to a logarithmic subsequence criterion,
- or define a canonical refinement of the prime-indexed family on which equidistribution is easier to state,
- or transfer positivity/growth bounds needed to define logarithms safely.

In the paper, explicitly state:
- the exact imported theorem names,
- the file paths,
- and how each theorem is used in the proof architecture.

If the catalog already contains positivity/growth lemmas for `T_c⁽ⁿ⁾(p)`, they should feed directly into hypotheses like `∀ n, 0 < u n`.

---

## Formalization Targets in Lean 4

Your Lean development should include:

1. A new definition of Benford-in-base or an equivalent interval-frequency notion.
2. A new definition of multiplicative independence of natural bases if absent.
3. At least 3 substantive theorems, ideally among the 4 listed above.
4. A computational interface theorem that can justify the empirical test code.

Suggested signatures to adapt:

```lean
def MultiplicativelyIndependent (a b : ℕ) : Prop :=
  ∀ m n : ℕ, a^m = b^n → m = 0 ∧ n = 0

def BenfordInBase (u : ℕ → ℝ) (b : ℕ) : Prop := ...

def BenfordBaseInvariant (u : ℕ → ℝ) : Prop := ...

theorem irrational_log_ratio_of_multiplicative_independence
    {a b : ℕ} (ha : 2 ≤ a) (hb : 2 ≤ b)
    (hmi : MultiplicativelyIndependent a b) :
    Irrational (Real.log a / Real.log b)

theorem benford_of_log_equidistributed
    (u : ℕ → ℝ) (b : ℕ)
    (hb : 2 ≤ b)
    (hu : ∀ n, 0 < u n)
    (heq : EquidistributedModOne (fun n => Real.log (u n) / Real.log b)) :
    BenfordInBase u b

theorem benford_base_invariant_of_scaled_log_equidistribution
    (u : ℕ → ℝ)
    (hu : ∀ n, 0 < u n)
    (hscale :
      ∀ b : ℕ, 2 ≤ b →
        Irrational (Real.log b / Real.log 2) →
        EquidistributedModOne (fun n => Real.log (u n) / Real.log b)) :
    BenfordBaseInvariant u
```

If full `EquidistributedModOne` is not available, define a formal surrogate:
```lean
def IntervalEquidistributedModOne (x : ℕ → ℝ) : Prop := ...
```
and prove Benford from that.

---

## Computational/Experimental Deliverable

You must produce a **verified algorithmic method**, not just a theorem.

### Verified computational method
Implement a function that:
1. computes leading-digit frequencies of \(|T_c^{(n)}(p)|\) in base \(b\),
2. computes the Benford reference distribution in base \(b\),
3. computes KL divergence,
4. compares divergences across admissible bases.

The theorem-level formal target should justify that **small KL divergence is evidence for interval equidistribution**, even if not a proof. At minimum, formalize correctness of the digit-extraction routine with respect to the significand definition.

Suggested computational theorem:
```lean
theorem leading_digit_algorithm_correct
    (b : ℕ) (hb : 2 ≤ b) (x : ℝ) (hx : 1 ≤ x) :
    digitExtract b x = d ↔
    -- precise significand interval characterization
```

This is valuable because it ties executable code to the mathematical definition.

---

## Falsifiable Conjecture You Must State

State this cleanly in `FUTURE_DIRECTIONS.md` and in the paper:

**Conjecture (Base-invariant Benford transfer for prime dynamical orbits).**  
For each fixed integer parameter \(c\), if there exists one base \(b_0 \ge 2\) with \(\log b_0 / \log 2 \notin \mathbb{Q}\) such that the sequence \(\{|T_c^{(n)}(p)|\}_{p \text{ prime},\, n\le N}\) is asymptotically Benford in base \(b_0\), then for every base \(b \ge 2\) with \(\log b / \log 2 \notin \mathbb{Q}\), the same sequence is asymptotically Benford in base \(b\).

**Clear computational test:**  
For each \(c \in \{-10,\dots,10\}\), compare KL divergence profiles across
\[
b \in \{3,5,6,7,10,11,12,15\}
\]
using primes \(p \le 10^4\) and \(n \le 15\). Search for a witness \(c,b_1,b_2\) where one admissible base has persistently low KL divergence and another has persistently high KL divergence.

**Refutation criterion:**  
A single such witness refutes the conjecture.

---

## Mandatory Deliverables

You must produce **all** of the following:

1. **Lean file(s)** with at least 3 nontrivial proved theorems, minimal `sorry`, and at least one new definition.
2. **FUTURE_DIRECTIONS.md** with **3–5 falsifiable hypotheses**, each with:
   - precise statement,
   - test protocol,
   - explicit refutation criterion.
3. **RESEARCH_PAPER.md** as a standalone scientific paper:
   - problem statement,
   - theorem statements,
   - proof ideas,
   - computational evidence,
   - significance,
   - next-step conjectures.
4. **ARTICLE.md** in Scientific American style:
   - explain why base-invariance matters,
   - why primes and dynamical sequences are surprising here,
   - what formal proof contributes beyond numerics.
5. **A verified algorithm/computational method**:
   - digit extraction,
   - Benford distribution generation,
   - KL divergence computation,
   - admissible-base comparison.
6. **demo.py**:
   - interactive exploration over \(c\), \(b\), prime cutoff, iterate depth,
   - plots or tables of leading-digit frequencies and KL divergence,
   - automatic search for refuting pairs of bases.

---

## Scientific Significance

If successful, this project does more than verify one conjecture. It establishes a **formal transfer principle for scale-invariant statistics across numeral systems**. That is a new kind of theorem: a rigorously verified bridge from arithmetic dynamics to observable digit laws. It opens the door to:

- Benford universality classes for deterministic sequences,
- formal detection of equidistribution via digit statistics,
- prime-orbit diagnostics in arithmetic dynamics,
- certified computational experiments in experimental number theory,
- and eventually a formalized version of “Benford rigidity” for broad classes of nonlinear recurrences.

Do not settle for “some computations suggest...”. Build the theorem that explains why base should not matter once the right logarithmic phase is equidistributed.

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
