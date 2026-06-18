## Assignment: Months 6–12

Prove genuinely new, non-trivial theorems in additive combinatorics around cap sets, with Lean 4 formalization targets ambitious enough to force new infrastructure. Build on catalog theorems where they are structurally relevant, but do not let the existing catalog constrain the mathematical horizon: the goal is to open a formalized pathway from finite-field additive combinatorics to polynomial methods, coding theory, and higher-order pseudorandomness.

Minimize `sorry`. If a flagship theorem is too large for one cycle, formalize the strongest intermediate lemma that clearly unlocks the next layer.

### Research Direction
**Direction 5 (Cap sets)** — the most ambitious direction, requiring substantial new infrastructure.

This is not a request for a minor finite-field exercise. This is a call to formalize the polynomial method architecture behind progression-free sets in `𝔽₃^n`, and to push toward a reusable Lean framework for extremal additive combinatorics over finite abelian groups.

---

## Mathematical Framing

A **cap set** in `𝔽₃^n` is a set containing no nontrivial 3-term arithmetic progression, equivalently no distinct `x y z` with `x + z = 2 • y`. Since `2 = -1` in `𝔽₃`, this is also the equation
`x + y + z = 0`
for distinct points after a change of variables. The revolutionary target is to formalize the combinatorial-algebraic machinery that converts progression-freeness into rank bounds for polynomially defined tensors.

The long-range breakthrough is not merely “one cap-set bound.” It is a **formal library for the polynomial method in finite fields**, reusable for:
- progression-free sets,
- slice-rank arguments,
- extremal coding theory,
- matrix/tensor rank in combinatorics,
- finite-field incidence geometry,
- pseudorandomness and property testing.

---

## Existing Verified Theorems
Existing theorems you can build on:
1. `new_channel` : theorem new_channel (a b k d : ℤ)
   (file: Algebra/Factoring/QDF_ArithGeomQuantum.lean)
2. `at_most_one_blind` : theorem at_most_one_blind (x y : ℝ) (hcirc : x ^ 2 + y ^ 2 = 1) :
   (file: Algebra/IntegerEnergy/MultiocularGodOracle.lean)
3. `the_answer_factorization` : theorem the_answer_factorization : 42 = 2 * 3 * 7 := by norm_num
4. `bounded_autocorr_bounded_energy` : theorem bounded_autocorr_bounded_energy (S : Finset ℤ) (k : ℕ)
   (file: Algebra/AdditiveCombinatorics/MontgomeryPairCorrelation.lean)
5. `portfolio_quality_bounded` : theorem portfolio_quality_bounded {n : ℕ} (hn : 0 < n)
   (file: Algebra/Advanced/MetaOracleAdvanced.lean)

These are heterogeneous, but one of them is conceptually important: `bounded_autocorr_bounded_energy` suggests an existing additive-combinatorial style already in the catalog. Use it as a bridge theorem philosophically: low structured correlations imply bounded additive energy; in the cap-set setting, progression-freeness should likewise be connected to constrained additive configurations. Even if the exact theorem is not directly reusable, align naming and library architecture with additive-combinatorics conventions.

---

## Cold-Start Directive

No previous research cycles completed yet. This is a cold start.

Priority hierarchy:
1. If there are urgent `sorry_fill` targets such as `CarmichaelComposite` or `Fib_gcd_identity`, close them only if they are immediately available and block infrastructure.
2. Otherwise, attack the cap-set program directly.
3. Prefer bridge theorems that create durable infrastructure over isolated lemmas.

No specific files referenced. Use Mathlib and general knowledge.

---

## Flagship Formalization Goal

You should aim for a theorem of the following shape:

### Precise theorem statement
For each `n : ℕ`, any subset `A ⊆ (Fin n → ZMod 3)` with no nontrivial 3-term arithmetic progression has cardinality at most the number of monomials in `n` variables of total degree at most `⌊2n/3⌋` with each exponent bounded by `2`.

This is the finite-field polynomial-method upper bound underlying the exponential cap-set estimate. Even a formally verified weaker-but-clean version would be a major breakthrough.

A practical Lean-facing version is:

```lean
def IsCapSet (A : Finset (Fin n → ZMod 3)) : Prop :=
  ∀ x ∈ A, ∀ y ∈ A, ∀ z ∈ A,
    x + z = (2 : ZMod 3) • y → x = y ∨ y = z

def boundedDegreeMonomials (n d : ℕ) : Finset (Fin n → ℕ) :=
  ((Finset.pi (Finset.univ) (fun _ => Finset.range 3)).filter
    (fun e => ∑ i, e i ≤ d))

theorem capset_meshulam_bound
    (n : ℕ) (A : Finset (Fin n → ZMod 3))
    (hA : IsCapSet A) :
    A.card ≤ (boundedDegreeMonomials n (2 * n / 3)).card
```

This exact signature may need adjustment because:
- `Finset.pi` over exponent functions may require a more explicit construction,
- the degree predicate may be better expressed using `Fintype.sum`,
- the cap-set predicate may need the “distinctness” form instead:
  `x ≠ y → y ≠ z → x + z ≠ (2 : ZMod 3) • y`.

If the full Meshulam/Ellenberg–Gijswijt-style bound is too large for one cycle, prove one of the following rigorous intermediate theorems.

---

## High-Value Intermediate Theorems

### Theorem A: Progression-free sets have unique midpoint property
This is not enough for the final exponential bound, but it creates the right additive API.

```lean
def ThreeAPFree (A : Finset (Fin n → ZMod 3)) : Prop :=
  ∀ x ∈ A, ∀ y ∈ A, ∀ z ∈ A,
    x ≠ y → y ≠ z → x + z ≠ (2 : ZMod 3) • y

theorem threeAPFree_injective_midpoint
    (n : ℕ) (A : Finset (Fin n → ZMod 3))
    (hA : ThreeAPFree A) :
    Set.InjOn (fun p : (Fin n → ZMod 3) × (Fin n → ZMod 3) => p.1 + p.2)
      {p | p.1 ∈ (A : Set (Fin n → ZMod 3)) ∧ p.2 ∈ (A : Set (Fin n → ZMod 3)) ∧ p.1 ≠ p.2}
```

This theorem converts additive-combinatorial avoidance into an injectivity statement, a crucial bridge toward energy bounds, sumset lower bounds, and coding-theoretic interpretations.

### Theorem B: Finite-field low-degree interpolation on the cube
You need a polynomial infrastructure theorem saying functions on `𝔽₃^n` are represented by reduced polynomials with exponents `< 3`.

```lean
theorem exists_unique_reduced_poly_rep
    (n : ℕ) :
    ∀ f : (Fin n → ZMod 3) → ZMod 3,
      ∃! P : MvPolynomial (Fin n) (ZMod 3),
        (∀ i, P.degrees i < 3) ∧
        ∀ x, MvPolynomial.eval x P = f x
```

The exact signature will almost certainly need adaptation because `MvPolynomial.degrees` is multiset-based in Mathlib; you may want a bespoke predicate:
`IsReducedTernaryPolynomial : MvPolynomial (Fin n) (ZMod 3) → Prop`.

If formalized, this is enormous: it gives the function-polynomial dictionary underlying the polynomial method.

### Theorem C: Vanishing lemma for degree-bounded reduced polynomials
A usable slice-rank precursor:

```lean
theorem reduced_poly_zero_of_large_vanishing
    (n d : ℕ) (P : MvPolynomial (Fin n) (ZMod 3))
    (hred : IsReducedTernaryPolynomial P)
    (hdeg : totalDegree P ≤ d)
    (hvanish : ∀ x, x ∈ S → MvPolynomial.eval x P = 0)
    (hSlarge : (boundedDegreeMonomials n d).card < Fintype.card S) :
    P = 0
```

This exact form will need a finite type `S`; but the conceptual theorem is: if a reduced low-degree polynomial vanishes on “too many” points relative to its coefficient-space dimension, then it must be zero. This is the algebraic engine behind dimension arguments.

---

## Most Promising Main Target

The most promising target for this cycle is:

### `prove`
Formalize a **dimension bound for progression-free subsets of `𝔽₃^n`** strong enough to imply a nontrivial exponential upper bound, ideally the classical Meshulam-style bound or a degree-counting precursor to Ellenberg–Gijswijt.

A robust Lean target is:

```lean
theorem capset_nontrivial_exponential_bound :
  ∃ C : ℝ, C < 3 ∧
  ∀ n : ℕ, ∀ A : Finset (Fin n → ZMod 3),
    ThreeAPFree A →
    (A.card : ℝ) ≤ C ^ n
```

Even if the proof uses a conservative constant `C`, this would be a field-opening formal result. It would show Lean can certify a genuinely nontrivial asymptotic theorem in additive combinatorics, not just finite-instance verification.

---

## Proof Strategy Architecture

You must pursue at least 2–3 proof avenues in parallel and decide quickly which one survives formalization pressure.

### Strategy 1: Meshulam-style Fourier/dimension argument
**Most promising for first success.**

1. Model `𝔽₃^n` as `Fin n → ZMod 3`, and define progression-free sets.
2. Construct a space of low-degree functions/polynomials on the finite cube and compare:
   - dimension of function restrictions to `A`,
   - vanishing constraints imposed by progression-freeness.
3. Derive an upper bound on `A.card` from the dimension of a low-degree polynomial space.

Why this is promising:
- It avoids the full tensor/slice-rank formalism initially.
- Mathlib already has strong support for finite types, modules, and multivariate polynomials.
- The combinatorial heart can be expressed as linear algebra over a finite field, which Lean handles relatively well.

### Strategy 2: Reduced-polynomial interpolation + rank method
**Higher ceiling, more infrastructure-heavy.**

1. Prove every function on `(Fin n → ZMod 3)` is represented by a unique reduced polynomial with exponents in `{0,1,2}`.
2. Define the evaluation matrix from reduced monomials to points of `A`, and prove rank/dimension bounds.
3. Use a cleverly chosen vanishing polynomial associated to `A` to force `A.card` below the reduced monomial count.

Why this matters:
- This is the right abstraction barrier for later Ellenberg–Gijswijt formalization.
- It creates a reusable finite-field polynomial-method toolkit.

Why it is harder:
- You may need to build missing API around monomial bases, reduced exponents, and dimension counting of finitely supported coefficient spaces.

### Strategy 3: Tensor/slice-rank precursor
**Most visionary, but likely second-cycle unless infrastructure appears quickly.**

1. Define the trilinear indicator tensor
   `T(x,y,z) = 1` if `x + y + z = 0`, else `0`,
   restricted to `A × A × A`.
2. Show progression-freeness forces this tensor to be diagonal in a strong sense.
3. Upper-bound its slice rank using low-degree polynomial decomposition.

Why this is revolutionary:
- It points directly toward Ellenberg–Gijswijt and the modern cap-set breakthrough.
- It opens a Lean pathway to slice rank, which would have major consequences far beyond cap sets.

Why it is risky:
- Slice rank infrastructure is probably not in Mathlib and may require substantial tensor formalization.

**Recommendation:** pursue Strategy 1 as the mainline, while designing definitions so that Strategy 2 and 3 can plug into the same API later.

---

## Required Definitions and Infrastructure

You will likely need to define some or all of the following.

### Finite vector-space model
```lean
abbrev F3Vec (n : ℕ) := Fin n → ZMod 3
```

### Progression-free / cap-set predicate
Use one canonical definition and prove equivalence to alternatives.

```lean
def ThreeAPFree (A : Finset (F3Vec n)) : Prop := ...
def IsCapSet (A : Finset (F3Vec n)) : Prop := ...
```

Prove equivalences between:
- `x + z = 2 • y`,
- `x + y + z = 0`,
- “no distinct triple in arithmetic progression.”

### Reduced exponent vectors
A finite exponent vector with values in `{0,1,2}`:
```lean
def TernaryExponent (n : ℕ) := Fin n → Fin 3
```
Then connect these to monomials in `MvPolynomial`.

### Degree-bounded monomial counting
Define the finite set of reduced exponent vectors of total degree at most `d`, and prove basic cardinality lemmas.

```lean
def reducedMonomialsLE (n d : ℕ) : Finset (Fin n → Fin 3) := ...
```

Key theorem:
```lean
theorem reducedMonomialsLE_card_le_pow
    (n d : ℕ) :
    (reducedMonomialsLE n d).card ≤ 3 ^ n
```

Then sharpen with a nontrivial asymptotic or combinatorial estimate if feasible.

---

## Cross-Domain Connections You Must Exploit

This project becomes paradigm-shifting only if you connect cap sets to other domains.

### 1. Coding theory
A cap set in `𝔽₃^n` is a code avoiding certain additive configurations. The formal bridge:
- progression-free sets correspond to forbidden linear patterns,
- low-degree polynomial bounds resemble linear programming and dual code constraints,
- future work could connect to locally testable codes and list decoding.

### 2. Higher-order Fourier analysis / pseudorandomness
Cap-set arguments live near the boundary between classical Fourier methods and polynomial/tensor methods. Formalizing this boundary in Lean could eventually support:
- Gowers norms,
- inverse theorems,
- property testing over finite fields.

### 3. Tensor complexity / theoretical computer science
Slice rank is a cousin of tensor rank and matrix multiplication complexity. A formalized cap-set rank argument is not just additive combinatorics; it is a seed for:
- algebraic complexity,
- communication complexity,
- fast algorithm lower bounds.

### 4. Statistical physics / entropy heuristics
The monomial-count asymptotics behind cap-set bounds are entropy-like large-deviation counts. Even if not formalized this cycle, state this explicitly in `FUTURE_DIRECTIONS.md`: the combinatorial dimension count should ultimately be linked to entropy optimization and partition-function heuristics.

### 5. Additive energy and correlation
Leverage the spirit of `bounded_autocorr_bounded_energy`: progression-freeness is an extreme additive-structure constraint. Build lemmas relating cap-set hypotheses to restricted additive energy or sumset injectivity. This creates continuity with the existing catalog and broadens applicability.

---

## Concrete Lean 4 Targets

You should aim to produce at least one theorem with a Lean signature close to one of these.

### Target 1: Equivalence of progression formulations
```lean
theorem threeAP_eq_zero_iff
    {n : ℕ} {x y z : Fin n → ZMod 3} :
    x + z = (2 : ZMod 3) • y ↔ x + y + z = 0
```

### Target 2: Distinct-pair sum injectivity
```lean
theorem capset_pairSum_inj
    {n : ℕ} {A : Finset (Fin n → ZMod 3)}
    (hA : ThreeAPFree A) :
    Set.InjOn
      (fun p : (Fin n → ZMod 3) × (Fin n → ZMod 3) => p.1 + p.2)
      {p | p.1 ∈ (A : Set (Fin n → ZMod 3)) ∧
           p.2 ∈ (A : Set (Fin n → ZMod 3)) ∧
           p.1 ≠ p.2}
```

### Target 3: Reduced polynomial evaluation basis theorem
```lean
def IsReducedTernaryPolynomial {n : ℕ}
    (P : MvPolynomial (Fin n) (ZMod 3)) : Prop :=
  ∀ d, d ∈ P.support → ∀ i, d i < 3

theorem eval_equiv_reduced_poly
    (n : ℕ) :
    ∃ e :
      {P : MvPolynomial (Fin n) (ZMod 3) // IsReducedTernaryPolynomial P}
        ≃ₗ[ZMod 3] (((Fin n → ZMod 3) → ZMod 3)),
      True
```

This statement may need to be decomposed into:
- linearity of evaluation,
- injectivity on reduced polynomials,
- dimension equality,
- hence linear equivalence.

### Target 4: Nontrivial cap-set upper bound
```lean
theorem capset_card_lt_full
    (n : ℕ) (A : Finset (Fin n → ZMod 3))
    (hA : ThreeAPFree A) :
    ∃ c : ℝ, c < 3 ∧ (A.card : ℝ) ≤ c ^ n
```

If uniform `c` is too ambitious in one cycle, prove:
```lean
theorem capset_card_le_reducedMonomials
    (n : ℕ) (A : Finset (Fin n → ZMod 3))
    (hA : ThreeAPFree A) :
    A.card ≤ (reducedMonomialsLE n (2 * n / 3)).card
```

This is cleaner and more combinatorially canonical.

---

## Build Order

1. Define `F3Vec`, `ThreeAPFree`, `IsCapSet`.
2. Prove algebraic equivalences of progression equations in `ZMod 3`.
3. Establish injectivity / additive-energy lemmas for pair sums under progression-freeness.
4. Build reduced monomial indexing objects.
5. Formalize reduced polynomial evaluation on `𝔽₃^n`.
6. Prove dimension/rank lemmas.
7. Derive the first nontrivial cardinality bound.
8. If time remains, begin slice-rank precursor definitions.

---

## What Would Count as a Breakthrough This Cycle

Any one of the following would be a genuine breakthrough:

- A formalized nontrivial exponential upper bound for cap sets in `𝔽₃^n`.
- A certified reduced-polynomial representation theorem for all functions on `𝔽₃^n`.
- A reusable Lean library for finite-field polynomial method over `Fin n → ZMod p`.
- A bridge theorem connecting progression-freeness to additive energy / injective sumsets in a way reusable across additive combinatorics.

Do not undersell intermediate infrastructure. If you formalize the right algebraic skeleton, the next cycle can attack Ellenberg–Gijswijt directly.

---

## Application Keywords
cap sets, additive combinatorics, polynomial method, finite fields, `𝔽₃^n`, multivariate polynomials, reduced monomials, interpolation, dimension bounds, slice rank, tensor methods, coding theory, pseudorandomness, additive energy, extremal combinatorics, theoretical computer science, entropy methods

---

## Team Directive

Create a team to conduct research, brainstorm hypotheses, run experiments, validate data, update the knowledge base, and iterate forever.

Suggested internal team roles:
- **Finite-field algebra lead**: builds `ZMod 3` and polynomial lemmas.
- **Combinatorics lead**: formulates progression-free and energy statements.
- **Linear algebra lead**: handles rank/dimension arguments.
- **Complexity/cross-domain lead**: extracts coding-theoretic and tensor interpretations.
- **Formalization engineer**: minimizes API friction and removes `sorry`.

---

## Deliverables

Required:
- Lean 4 proofs
- `FUTURE_DIRECTIONS.md`

Optional:
- `ARTICLE.md`
- `RESEARCH_PAPER.md`
- `demo.py`
- `diagram.svg`

`FUTURE_DIRECTIONS.md` is critical. It must contain **3–5 concrete, specific, breakthrough-level next steps**, each with:
1. a precise theorem statement,
2. a proposed Lean type signature when possible,
3. 2–3 proof strategy ideas,
4. at least one cross-domain connection.

Include future directions such as:
- slice-rank formalization for diagonal tensors,
- generalized progression-free bounds in `ZMod p ^ n`,
- finite-field interpolation as a linear equivalence for arbitrary primes,
- additive-energy consequences of cap-set hypotheses,
- coding-theoretic forbidden-configuration bounds.

---

## Final Mandate

You are Aristotle. Pursue cap sets as the seed of a **formal theory of the polynomial method**. Do not merely prove a local lemma unless it clearly unlocks a structural next theorem. Use concrete types like `Nat`, `Finset`, `Matrix`, `Fin n → ZMod 3`, and `MvPolynomial`. Avoid trivial tautologies. If a direct proof fails, try:
- contrapositive,
- constructive witness,
- finite-dimensional linear algebra,
- rank-nullity,
- induction on dimension `n`,
- decomposition by last coordinate,
- polynomial interpolation.

Connect the work to at least one other domain for impact. Build definitions that will survive beyond this one theorem. Formalize the machinery that future mathematicians will reuse.

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
