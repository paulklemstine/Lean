## Assignment: Goldbach via Tropical Additive Combinatorics — Recast, Refine, and Break Ground

Your original direction reaches for a legendary statement, but as written it conflates a genuinely open classical problem with tropical language that, unless defined with extreme care, risks becoming a mere reformulation rather than a mathematically fertile theorem. Do not spend the cycle pretending to solve binary Goldbach outright. Instead, use Goldbach as the organizing myth and extract a new formal theory of **tropical additive prime energies** that is provable in Lean, structurally deep, and capable of supporting future attacks on additive problems.

Your task is to build a formal bridge between:

- classical additive combinatorics on `ℕ`,
- min-plus convolution and tropical semiring methods,
- Schnirelmann-type density ideas,
- and certificate theorems that reduce Goldbach-type assertions to bounded verification plus structural inequalities.

The goal is not incremental number theory. The goal is to create a new formal language in which additive prime phenomena become tropical optimization statements.

---

## Mode: `prove`

## Core Research Program

### Step 1: Define the tropical prime cost function

Let the prime indicator be encoded as a cost function
\[
\pi^\trop : \mathbb N \to \mathbb N_\infty,
\qquad
\pi^\trop(n) :=
\begin{cases}
0 & \text{if } n \text{ is prime},\\
\top & \text{otherwise}.
\end{cases}
\]
Then define the min-plus convolution
\[
(\pi^\trop \star_{\min,+} \pi^\trop)(n)
:= \inf_{a+b=n}\bigl(\pi^\trop(a)+\pi^\trop(b)\bigr).
\]
In this encoding, the statement
\[
(\pi^\trop \star_{\min,+} \pi^\trop)(2m)=0
\]
is equivalent to the existence of a Goldbach decomposition of `2m`.

This equivalence itself is elementary, but the breakthrough direction is to prove **structural theorems about tropical additive costs** that turn Goldbach-type assertions into compositional inequalities, monotonicity statements, and finite verification principles.

---

## Primary Theorem Targets

### Theorem A: Exact tropical equivalence of binary additive representability

Formalize the exact bridge between min-plus convolution and additive decomposition over a predicate.

#### Mathematical statement
For any set `A : ℕ → Prop`, define its tropical cost
\[
c_A(n)=
\begin{cases}
0 & A(n),\\
\top & \neg A(n).
\end{cases}
\]
Then for all `n : ℕ`,
\[
(c_A \star_{\min,+} c_A)(n)=0
\iff
\exists a b,\ a+b=n \land A(a)\land A(b).
\]

This is the universal theorem behind the tropical Goldbach reformulation. Specialize to `A := Nat.Prime`.

#### Lean 4 type signature
```lean
open scoped BigOperators

def tropPredCost (A : ℕ → Prop) (n : ℕ) : WithTop ℕ :=
  if A n then 0 else ⊤

def minplusConv (f g : ℕ → WithTop ℕ) (n : ℕ) : WithTop ℕ :=
  sInf {c | ∃ a b : ℕ, a + b = n ∧ c = f a + g b}

theorem minplusConv_tropPredCost_eq_zero_iff
    (A : ℕ → Prop) (n : ℕ) :
    minplusConv (tropPredCost A) (tropPredCost A) n = 0 ↔
      ∃ a b : ℕ, a + b = n ∧ A a ∧ A b := by
  sorry

theorem goldbach_tropical_exact_iff (n : ℕ) :
    minplusConv (tropPredCost Nat.Prime) (tropPredCost Nat.Prime) (2*n) = 0 ↔
      ∃ p q : ℕ, p + q = 2*n ∧ Nat.Prime p ∧ Nat.Prime q := by
  sorry
```

#### Why this matters
This theorem turns additive representation into a tropical optimization primitive. Once formalized, any theorem about min-plus convolution immediately induces a theorem about additive representation. This is the correct foundational move.

---

### Theorem B: Tropical support-sum theorem for Schnirelmann-style additive closure

Do not claim “tropical Schnirelmann density of primes is 1/2” without a rigorous definition and proof framework. Instead, prove a **general support-sum theorem**: if two tropical cost functions vanish on sets with additive covering properties, then their convolution vanishes on the sumset. This is the correct abstract theorem from which density-like statements may later descend.

#### Mathematical statement
For predicates `A B : ℕ → Prop`, let
\[
S_A = \{n : c_A(n)=0\}, \qquad S_B = \{n : c_B(n)=0\}.
\]
Then
\[
(c_A \star_{\min,+} c_B)(n)=0
\iff
n \in S_A + S_B.
\]
In particular,
\[
\{n : (c_A \star_{\min,+} c_B)(n)=0\} = A+B
\]
as sumsets.

This gives a tropicalization of additive combinatorics at the support level.

#### Lean 4 type signature
```lean
def addSumset (A B : ℕ → Prop) (n : ℕ) : Prop :=
  ∃ a b : ℕ, a + b = n ∧ A a ∧ B b

theorem zero_locus_minplusConv_tropPredCost
    (A B : ℕ → Prop) (n : ℕ) :
    minplusConv (tropPredCost A) (tropPredCost B) n = 0 ↔
      addSumset A B n := by
  sorry
```

#### Why this matters
This theorem says tropical convolution is not just a rephrasing: it is an exact support functor from additive combinatorics into tropical algebra. That is a reusable formal object.

---

### Theorem C: Monotone tropical majorization yields additive covering certificates

You need a theorem with real mathematical teeth: a way to certify representation by comparison with a simpler cost function.

Suppose `f ≤ g` pointwise in `WithTop ℕ`. Then
\[
f \star g \le f' \star g'
\]
under suitable monotone hypotheses. Use this to derive finite verification principles: if a cost function for primes is bounded above by a surrogate cost with known additive vanishing, then Goldbach-type representation follows on a range.

#### Mathematical statement
For min-plus convolution on `WithTop ℕ`,
\[
f_1 \le f_2,\ g_1 \le g_2 \implies
f_1 \star g_1 \le f_2 \star g_2.
\]
Then prove a certificate theorem: if `s : ℕ → WithTop ℕ` vanishes on a set `S`, and every sufficiently large even number belongs to `S+S`, then every sufficiently large even number has tropical cost `0` under `s ⋆ s`.

#### Lean 4 type signature
```lean
theorem minplusConv_mono
    {f₁ f₂ g₁ g₂ : ℕ → WithTop ℕ}
    (hf : ∀ n, f₁ n ≤ f₂ n)
    (hg : ∀ n, g₁ n ≤ g₂ n) :
    ∀ n, minplusConv f₁ g₁ n ≤ minplusConv f₂ g₂ n := by
  sorry

theorem eventual_zero_of_eventual_sumset
    (A : ℕ → Prop) (N : ℕ)
    (hcov : ∀ n ≥ N, Even n → addSumset A A n) :
    ∀ n ≥ N, Even n →
      minplusConv (tropPredCost A) (tropPredCost A) n = 0 := by
  sorry
```

#### Why this matters
This is the first genuinely useful structural theorem in the program. It isolates the tropical mechanism from the arithmetic input. Once proven, any future partial Goldbach result, sieve estimate, or computational verification can plug into it.

---

## Ambitious but Realistic Goldbach-Adjacent Theorem

You should not claim to prove full Goldbach unless you actually do. Instead, prove the exact reduction theorem below.

### Theorem D: Finite verification reduction for tropical Goldbach

If every even `n` with `4 ≤ n ≤ B` has a prime decomposition, and if a separately proved additive covering theorem implies every even `n > B` lies in a sumset of a prime-rich set `A` with `A ⊆ primes`, then tropical Goldbach follows globally.

This is abstract, but formal and powerful: it cleanly separates computation, sieve input, and tropical algebra.

#### Lean 4 type signature
```lean
theorem goldbach_from_finite_check_and_cover
    (B : ℕ)
    (hsmall :
      ∀ n, 4 ≤ n → n ≤ B → Even n →
        ∃ p q : ℕ, p + q = n ∧ Nat.Prime p ∧ Nat.Prime q)
    (A : ℕ → Prop)
    (hA_prime : ∀ n, A n → Nat.Prime n)
    (hlarge : ∀ n, B < n → Even n → addSumset A A n) :
    ∀ n, 4 ≤ n → Even n →
      minplusConv (tropPredCost Nat.Prime) (tropPredCost Nat.Prime) n = 0 := by
  sorry
```

#### Why this would be a breakthrough
Not because it solves Goldbach by itself, but because it creates a **formal architecture for hybrid theorem proving in additive prime theory**: exact arithmetic verification on a finite range plus structural asymptotic input plus tropical transport. This is the kind of theorem that can scale.

---

## Definitions You Must Make Precise

The phrase “tropical Goldbach function is bounded” is currently underspecified. Replace it with a mathematically coherent definition.

### Recommended definition
Define the tropical representation cost
\[
G_\trop(n) := \inf_{a+b=n} \bigl(\pi^\trop(a)+\pi^\trop(b)\bigr).
\]
Since values are in `WithTop ℕ`, “bounded” should mean bounded above by a finite constant on a specified domain. But for the prime-indicator cost this is equivalent to zero on that domain, so boundedness is too close to Goldbach itself.

A better variant is to define a **soft tropical prime cost**:
\[
\pi^\soft_K(n) :=
\begin{cases}
0 & \text{if } n \text{ prime},\\
K & \text{otherwise}.
\end{cases}
\]
or
\[
\pi^\log(n) :=
\begin{cases}
\log n & \text{if } n \text{ prime},\\
\top & \text{otherwise},
\end{cases}
\]
and study whether the convolution is uniformly finite or sublinear on even integers.

This opens a new direction:
- hard cost (`0/⊤`) captures exact representability,
- soft cost captures approximate additive primality,
- asymptotic bounds become meaningful.

You should prove basic comparison theorems between hard and soft costs.

#### Lean 4 target
```lean
def softPrimeCost (K n : ℕ) : ℕ :=
  if Nat.Prime n then 0 else K

theorem tropPredCost_le_softPrimeCost
    (K n : ℕ) :
    -- formulate after coercing `softPrimeCost` into `WithTop ℕ`
    True := by
  trivial
```
Refine this into a nontrivial inequality with explicit coercions.

---

## On “tropical Schnirelmann density”

Do not assert “the tropical Schnirelmann density of primes is 1/2 in the min-plus sense” unless you define a new invariant and prove something substantial about it. Classical Schnirelmann density of the primes is not `1/2`. So as stated, this is mathematically indefensible.

Instead, invent and formalize a **tropical lower covering density**:
\[
\sigma_\trop(A) := \inf_{n\ge1} \frac{1}{n}\,
\min\bigl\{|F| : F \subseteq A,\ [0,n]\subseteq F+[0,n]\bigr\}
\]
or a support-based density-like invariant tailored to tropical convolution. Then prove a theorem such as:

- if `σₜrop(A) > 0`, then repeated tropical self-convolution eventually vanishes on all sufficiently large integers;
- or if `A` contains `1`, tropical support growth is monotone under convolution.

This would be a genuine new concept rather than a broken analogy.

---

## Proof Strategy Architecture

### Strategy A: Exact support-level tropicalization
Most promising for the cycle.

1. Define `tropPredCost`, `minplusConv`, and `addSumset` carefully over `ℕ → WithTop ℕ`.
2. Prove `minplusConv_tropPredCost_eq_zero_iff` by unfolding the definitions and analyzing when an infimum over `WithTop ℕ` can be zero.
3. Derive sumset-support corollaries and monotonicity lemmas.
4. Specialize to primes and even numbers.

Why this is promising:
- fully formalizable in Lean now,
- no deep analytic number theory required,
- creates reusable infrastructure for later additive research.

### Strategy B: Finset-restricted convolution and bounded certificate extraction
Good for computational and finite verification results.

1. Define a truncated convolution over decompositions `a+b=n` with `a ∈ Finset.range (n+1)`.
2. Show the truncated finite minimum equals the `sInf` formulation on `ℕ`.
3. Use `Finset` lemmas to extract explicit witnesses when the minimum is zero.
4. Package this as a decision procedure for bounded Goldbach verification ranges.

Why this matters:
- gives executable artifacts in Lean,
- supports future verified computation,
- interfaces naturally with `decide`, `norm_num`, and finite search.

### Strategy C: Soft tropical energies and additive majorants
Most visionary, but longer-term.

1. Introduce weighted prime costs and prove convolution monotonicity and comparison lemmas.
2. Show that exact support theorems are the zero-level special case of a broader tropical energy formalism.
3. Connect these energies to sieve majorants, entropy-like functionals, or shortest-path semiring methods.

Why this matters:
- opens a new field rather than only formalizing a reformulation,
- connects additive combinatorics with optimization and tropical analysis,
- but likely requires more design work than Strategy A.

Recommendation:
- Execute Strategy A completely.
- Build Strategy B enough to obtain finite-search certificate theorems.
- Begin Strategy C with 1–2 nontrivial lemmas if time permits.

---

## Cross-Domain Connections You Must Exploit

### 1. Tropical geometry ↔ additive combinatorics
The zero-locus of min-plus convolution acts like a tropicalized sumset. This is a new formal bridge: additive representation becomes tropical support intersection.

### 2. Optimization / shortest paths ↔ prime decomposition
Min-plus convolution is the algebra of shortest paths and dynamic programming. Goldbach-type representation can be viewed as a zero-cost path problem in a graph whose allowed vertices are primes. This reframes additive number theory as certified discrete optimization.

### 3. Formal verification ↔ computational number theory
The bounded-search version of tropical convolution is executable. This opens a route to verified additive prime experiments inside Lean, not as external numerics but as theorem-producing computation.

### 4. Information theory / idempotent analysis
Soft prime costs suggest a tropical entropy or rate function for additive primality. Even basic inequalities here could seed a new “idempotent additive number theory.”

### 5. Semiring algebra ↔ analytic number theory
Min-plus convolution is a semiring operation. If you formalize its support-level behavior, later analytic estimates can be imported as inequalities on semiring-valued functions. This could become a formal interface layer between sieve bounds and algebraic proof systems.

---

## How to Use the Catalog Theorems

The listed catalog theorems appear mostly orthogonal or playful rather than directly useful for Goldbach. Do not force fake dependencies. But if possible:

- use `smooth_density_min_gap` only if it can be interpreted as a generic positivity/gap lemma in an auxiliary argument;
- use `geometric_sum_powers_of_two'` for finite combinatorial bounding or examples if relevant;
- avoid pretending `r2_prime_bounded` or `fermat_sum_two_sq_5'` are meaningful for the main theorem unless they genuinely instantiate your framework.

A breakthrough brief is not weakened by saying: “the existing catalog is not the right engine for the main theorem; we instead create foundational infrastructure that future catalog theorems can exploit.”

That honesty is mathematically stronger.

---

## Deliverables in Lean

At minimum, produce a file containing:

1. Definitions:
   - `tropPredCost`
   - `minplusConv`
   - `addSumset`
   - optional `softPrimeCost`

2. Core theorems:
   - `minplusConv_tropPredCost_eq_zero_iff`
   - `zero_locus_minplusConv_tropPredCost`
   - `minplusConv_mono`
   - `eventual_zero_of_eventual_sumset`
   - `goldbach_tropical_exact_iff`
   - if possible, `goldbach_from_finite_check_and_cover`

3. Examples:
   - explicit proof that `4, 6, 8, 10, 12` have tropical Goldbach cost `0`
   - finite-search witness extraction for small even numbers

4. Minimal sorry count:
   - prioritize complete proofs for the support-level theorems,
   - permit only strategically isolated sorrys for ambitious asymptotic abstractions if absolutely necessary.

---

## Application Keywords

tropical additive combinatorics, min-plus convolution, Goldbach reformulation, Schnirelmann-type density, sumset support, idempotent semiring, formal verification, certified computation, additive prime energies, shortest-path algebra, tropical optimization, semiring number theory

---

## Required FUTURE_DIRECTIONS.md

You must produce `FUTURE_DIRECTIONS.md` with 3–5 concrete next steps. They must be specific and breakthrough-level, not generic. Include items like:

1. **Tropical ternary Goldbach formalization**:
   formalize a support-level tropical theorem for threefold convolution and connect it to known odd-number decomposition results.

2. **Weighted prime energy inequalities**:
   define soft prime costs and prove subadditivity / monotonicity theorems that mirror sieve majorants.

3. **Verified bounded Goldbach engine in Lean**:
   implement a certified finite search showing zero tropical cost for all even numbers up to a substantial bound.

4. **Tropical sumset growth theorem**:
   prove that repeated self-convolution of positive-density support functions eventually vanishes on intervals, formalizing a tropical analogue of additive basis theory.

5. **Semiring transfer interface for analytic estimates**:
   design theorem statements allowing future import of external prime-distribution estimates as hypotheses yielding tropical vanishing conclusions.

Do not omit this file. It is part of the research artifact.

---

You are not being asked to “solve Goldbach.” You are being asked to build the formal tropical additive architecture in which Goldbach-type statements become semiring-theoretic objects, monotone certificates, and executable verification targets. If you do this cleanly, you open an entirely new lane: **formal idempotent additive number theory**.

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

Research domain: Algebra
Research mode: prove
