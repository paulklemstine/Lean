## Assignment Mode: **prove**

### Program Title
**Proof-Theoretic Symbolic Dynamics via Cellular Automata Zeta Functions, Star-Free Spacetime, and Linear Recurrence Rigidity**

Prove genuinely new theorems at the interface of symbolic dynamics, automata theory, algebraic combinatorics, and proof theory. Build on any existing catalog results about finite-ring periodic-point counting, de Bruijn graph constructions, regularity of spacetime languages, transfer matrices, and additive/permutative CA. Minimize sorry by isolating finite-state lemmas first and then lifting to global dynamical statements.

---

## Research Direction
# Future Directions: Proof-Theoretic Symbolic Dynamics

The overarching goal is to turn one-dimensional nearest-neighbor cellular automata into a **certified finite-state dynamical calculus**: zeta functions from transfer matrices, logical complexity from syntactic monoids, and recurrence order from linear algebra over finite fields. The breakthrough is not merely to classify a few rules, but to establish that deep dynamical invariants of CA are governed by **finite automata shadows** of spacetime.

This would open a new field line: **formal symbolic dynamics with complexity-theoretic semantics**. Rationality of zeta functions becomes a recognizability theorem; star-freeness becomes a first-order definability theorem; polynomial recurrence order becomes a spectral theorem for additive dynamics.

Application keywords: **symbolic dynamics, cellular automata, Artin–Mazur zeta function, shifts of finite type, sofic shifts, transfer matrices, de Bruijn graphs, star-free languages, aperiodic monoids, descriptive complexity, additive CA, finite fields, linear recurrences, automata theory, dynamical systems, formal verification**.

---

## Theorem Cluster A: Transfer-Matrix Rationality for Periodic-Point Counting

### Target Theorem A1: Rationality for finite-window realizability
For any one-dimensional nearest-neighbor CA over a finite alphabet, the language of admissible spacetime cylinders of fixed temporal height is regular, and its counting sequence over cyclic width is governed by a transfer matrix.

This is the finite-state backbone needed before any global zeta statement.

### Precise theorem statement
Let `α` be a finite type with decidable equality, and let a nearest-neighbor local rule be
`f : α → α → α → α`.
For a fixed height `h : ℕ`, define the set `Col_h := Fin h → α` of height-`h` columns. Define a binary compatibility relation on columns saying that two adjacent columns can occur in some spacetime diagram of height `h` for the CA rule `f`. Let `A_h` be the adjacency matrix of this compatibility graph on `Col_h`.

Then for every `n ≥ 1`, the number of cyclic width-`n` spacetime diagrams of height `h` equals `trace (A_h^n)`.

Equivalently, the generating series
\[
Z_h(z) := \sum_{n\ge 1} \frac{\mathrm{trace}(A_h^n)}{n} z^n
\]
satisfies
\[
\exp(Z_h(z)) = \frac{1}{\det(I - zA_h)}.
\]

### Lean 4 formalization target
A realistic first formal target is the counting identity rather than the full analytic zeta package.

```lean
theorem cyclic_spacetime_count_eq_trace_pow
  {α : Type} [Fintype α] [DecidableEq α]
  (f : α → α → α → α) (h n : ℕ) :
  let Col := Fin h → α
  let A : Matrix Col Col ℕ := spacetimeAdjMatrix f h
  Nat.card (CyclicSpacetimeDiagrams f h n) =
    Matrix.trace (A ^ n) := by
  sorry
```

A second theorem can package rationality in the formal power series ring:

```lean
theorem spacetime_zeta_is_rational
  {α : Type} [Fintype α] [DecidableEq α]
  (f : α → α → α → α) (h : ℕ) :
  IsRationalFormalPowerSeries (spacetimeZeta f h) := by
  sorry
```

If Mathlib lacks the exact determinant/FPS API, prove instead that the coefficient sequence satisfies a linear recurrence of order at most `(Fintype.card (Fin h → α))^2`.

```lean
theorem spacetime_count_linear_recurrence
  {α : Type} [Fintype α] [DecidableEq α]
  (f : α → α → α → α) (h : ℕ) :
  ∃ k > 0, ∃ c : Fin k → ℤ,
    ∀ᶠ n : ℕ in Filter.atTop,
      spacetimeCount f h (n + k) =
        ∑ i : Fin k, (c i).natAbs * spacetimeCount f h (n + i) := by
  sorry
```

### Why this is a breakthrough
This theorem turns spacetime realizability into a certified finite-state trace formula. It is the exact bridge between CA dynamics and the algebraic formalism of graph zeta functions. Once formalized, it becomes a reusable engine for every subsequent theorem on periodic points, logical definability, and complexity bounds.

### Proof strategies
**Strategy A: direct de Bruijn / column graph construction**
1. Define columns of height `h` and a local compatibility predicate using the CA rule.
2. Prove that a cyclic width-`n` spacetime diagram is exactly a closed walk of length `n` in the column graph.
3. Invoke the standard trace-counts-closed-walks identity for finite adjacency matrices.

This is the most promising because it is purely finite and combinatorial.

**Strategy B: NFA-to-matrix semantics**
1. Build a finite automaton recognizing valid width words over the alphabet `Col_h`.
2. Convert the automaton to a transition matrix.
3. Use standard automata counting identities to derive rationality.

This is useful if the catalog already contains regular-language counting machinery.

**Strategy C: relation-algebra encoding**
1. Encode local spacetime consistency as a finite relation on boundary states.
2. Show width concatenation corresponds to relation composition.
3. Use matrix representation of finite relations to obtain the trace formula.

This may align best with any existing catalog theorem about transfer matrices.

### Cross-domain connections
- **Algebraic geometry:** `1 / det(I - zA)` is the same algebraic shape as Ihara and Artin–Mazur zeta functions.
- **Automata theory:** regularity and rationality of generating functions are two faces of the same finite-state phenomenon.
- **Statistical mechanics:** the transfer matrix is literally the partition-function operator for a one-dimensional constrained system.
- **Proof theory:** finite-state certificates for realizability are formal proofs with bounded local checking depth.

---

## Theorem Cluster B: Star-Free Spacetime Languages for One-Sided Permutative CA

### Refined conjectural target
The original conjecture is bold. Make the first breakthrough theorem sharp and falsifiable:

### Target Theorem B1: Definite language theorem for one-sided permutative rules
For every one-sided permutative nearest-neighbor CA and every fixed height `h`, the width language of realizable height-`h` spacetime strips is **locally testable**, hence star-free.

This is stronger than regularity and gives an explicit logical complexity class.

### Precise theorem statement
Fix finite alphabet `α` and local rule `f : α → α → α → α`. Assume `f` is right-permutative:
for every `a b : α`, the map `c ↦ f a b c` is bijective.

For each height `h`, let `L_h ⊆ (Fin h → α)^*` be the language of finite width words of columns that extend to a valid height-`h` spacetime strip.

Then `L_h` is star-free; more strongly, there exists `k = k(h)` such that membership in `L_h` depends only on:
- the prefix of length `k`,
- the suffix of length `k`,
- and the set of length-`k` factors.

This is local testability.

### Lean 4 formalization target
If “star-free” is not yet in Mathlib, formalize the stronger finite-check property directly.

```lean
def LocallyTestable (L : Language α) : Prop :=
  ∃ k : ℕ, ∀ w₁ w₂ : List α,
    samePrefixSuffixFactors k w₁ w₂ → (w₁ ∈ L ↔ w₂ ∈ L)

theorem spacetime_language_locally_testable_of_rightPermutative
  {α : Type} [Fintype α] [DecidableEq α]
  (f : α → α → α → α)
  (h : ℕ)
  (hperm : ∀ a b : α, Function.Bijective (fun c : α => f a b c)) :
  LocallyTestable (spacetimeColumnLanguage f h) := by
  sorry
```

A weaker but still excellent theorem if local testability is too ambitious:

```lean
theorem spacetime_language_star_free_of_rightPermutative
  {α : Type} [Fintype α] [DecidableEq α]
  (f : α → α → α → α)
  (h : ℕ)
  (hperm : ∀ a b : α, Function.Bijective (fun c : α => f a b c)) :
  StarFree (spacetimeColumnLanguage f h) := by
  sorry
```

### Why this would be revolutionary
This would place spacetime languages of permutative CA inside **first-order logic over words**, not merely inside finite automata. That is a profound rigidity result: reversible local information flow collapses global realizability to a low logical complexity class. It would connect CA to Schützenberger–McNaughton–Papert theory and suggest that some dynamical systems admit **proof-theoretically weak certificates**.

### Proof strategies
**Strategy A: bounded-memory reconstruction**
1. Use right-permutativity to show each new column is uniquely determined from bounded boundary data.
2. Prove that realizability of a width word is equivalent to consistency of finitely many local boundary constraints.
3. Conclude local testability from bounded overlap checking.

This is the most conceptually powerful route.

**Strategy B: syntactic monoid collapse**
1. Construct the DFA of the spacetime column language.
2. Show every transition acts eventually idempotently because permutativity eliminates long-range counting obstructions.
3. Deduce aperiodicity of the syntactic monoid, hence star-freeness.

This is best if you can compute transition semigroups effectively.

**Strategy C: first-order interpretation of spacetime**
1. Express valid strips by a first-order formula over positions with predicates for column types.
2. Use the fixed height to quantify only over bounded neighborhoods.
3. Apply the McNaughton–Papert theorem to infer star-freeness.

This route gives the strongest logic connection and may be ideal for the paper narrative.

### Cross-domain connections
- **Descriptive complexity:** star-free = FO[<]-definable.
- **Semigroup theory:** aperiodicity of syntactic monoids.
- **Krohn–Rhodes theory:** complexity collapse for permutative CA.
- **Program verification:** bounded-window consistency checks correspond to certifiable trace properties.

---

## Theorem Cluster C: Polynomial Recurrence Order for Additive CA over `𝔽_p`

The third conjecture should be sharpened into an explicit linear-recursive statement. This is the place to get a truly formal theorem with spectral content.

### Target Theorem C1: Linear recurrence of periodic-point counts on rings
Let `T` be an additive nearest-neighbor CA over `𝔽_p` with local rule
\[
f(x,y,z)=ax+by+cz.
\]
For each time iterate `m`, let `Fix_m(n)` be the number of configurations on the cyclic ring `ℤ/nℤ` fixed by `T^m`. Then for each fixed `m`, the sequence `n ↦ Fix_m(n)` satisfies a linear recurrence with constant coefficients, of order bounded explicitly by `p^{O(m)}` or, ideally, by the degree of a companion polynomial derived from `aU^{-1}+b+cU`.

A stronger and more elegant theorem is possible:

### Precise theorem statement
Let `P(U) = a U^{-1} + b + c U ∈ 𝔽_p[U,U^{-1}]`. On the cyclic ring of size `n`, `T` acts as multiplication by `P(U)` in `𝔽_p[U]/(U^n - 1)`. Therefore
\[
|\mathrm{Fix}(T^m \text{ on } (\mathbb F_p)^n)| = p^{\deg \gcd(P(U)^m - 1,\; U^n - 1)}
\]
after clearing Laurent denominators appropriately.

Consequently, for fixed `m`, the sequence
\[
n \mapsto \log_p |\mathrm{Fix}(T^m \text{ on } (\mathbb F_p)^n)|
\]
is ultimately periodic in `n`, hence `|\mathrm{Fix}(T^m)|` is a multiplicative-exponential sequence with finite range exponents and therefore satisfies a linear recurrence.

### Lean 4 formalization target
A fully formal polynomial-gcd theorem may be ambitious, but here is the right shape:

```lean
theorem additiveCA_fix_count_eq_pow_card_gcd
  (p : ℕ) [Fact p.Prime]
  (a b c : ZMod p) (m n : ℕ) :
  fixCountAdditiveCA a b c m n =
    p ^ natDegree (Polynomial.gcd
      ((additiveCAPolynomial a b c) ^ m - 1)
      (X^n - 1)) := by
  sorry
```

If Laurent polynomials are inconvenient, multiply by a power of `X` first and prove an equivalent statement for ordinary polynomials.

A second theorem should isolate recurrence:

```lean
theorem additiveCA_fixCount_eventuallyLinearRecursive
  (p : ℕ) [Fact p.Prime]
  (a b c : ZMod p) (m : ℕ) :
  ∃ k > 0, ∃ c : Fin k → ℤ,
    ∀ᶠ n : ℕ in Filter.atTop,
      fixCountAdditiveCA a b c m (n + k) =
        ∑ i : Fin k, c i * fixCountAdditiveCA a b c m (n + i) := by
  sorry
```

An even better theorem, if reachable:

```lean
theorem additiveCA_logFixCount_ultimatelyPeriodic
  (p : ℕ) [Fact p.Prime]
  (a b c : ZMod p) (m : ℕ) :
  UltimatelyPeriodic (fun n => logFixCountAdditiveCA a b c m n) := by
  sorry
```

### Why this is a breakthrough
This would identify periodic-point counts of additive CA with **arithmetic of cyclotomic factors**. The dynamical invariant is no longer mysterious: it is controlled by gcd degrees in finite-field polynomial rings. That creates a direct bridge between CA, finite-field arithmetic, and linear recurrence theory.

### Proof strategies
**Strategy A: module-theoretic diagonalization over the cyclic ring**
1. Identify configurations on the ring `ℤ/nℤ` with `𝔽_p[U]/(U^n-1)`.
2. Show `T` acts by multiplication by the Laurent polynomial `P(U)`.
3. Fixed points of `T^m` are the kernel of multiplication by `P(U)^m - 1`, whose dimension is the degree of the gcd with `U^n-1`.

This is the cleanest and most canonical route.

**Strategy B: circulant matrix / Smith normal form**
1. Represent `T^m - I` as a circulant matrix over `𝔽_p`.
2. Use the discrete Fourier/cyclotomic decomposition of circulants.
3. Extract kernel dimension and recurrence from factor behavior of eigenpolynomials.

This is useful if matrix APIs are stronger than polynomial quotient APIs.

**Strategy C: rational generating series via automata on roots of unity**
1. Track whether `P(ζ)^m = 1` on roots `ζ` of `U^n=1`.
2. Show the count of such roots is ultimately periodic in `n`.
3. Lift to recurrence for fixed-point counts.

This route gives the strongest number-theoretic interpretation.

### Cross-domain connections
- **Finite-field arithmetic:** gcds with cyclotomic polynomials.
- **Coding theory:** additive CA fixed points are cyclic codes.
- **Spectral graph theory:** circulant operators and Fourier modes.
- **Arithmetic dynamics:** periodic points counted via algebraic factorization.
- **Complexity theory:** eventual periodicity gives subexponential certificate complexity for fixed-point counting.

---

## Ambitious Global Conjecture: Zeta Rationality vs SFT/Sofic Factor Structure

Your original Conjecture 1 is too coarse as stated: “factor of an SFT” is dangerously broad because every sofic shift is a factor of an SFT, and many CA live naturally on full shifts while their periodic-point structure may reflect the image subshift or spacetime soficity rather than factorhood alone. The likely breakthrough is to sharpen the invariant.

### Better global theorem to target
For a one-dimensional nearest-neighbor CA `T` on the full shift, if for every temporal height `h` the cyclic strip-counting zeta function is rational via a uniformly bounded family of transfer matrices, then the spacetime subshift is sofic; conversely, if the spacetime subshift is sofic, then every fixed-height strip zeta function is rational.

This replaces a potentially false “iff factor of an SFT” with a structurally natural theorem about the **spacetime shift itself**.

### Lean-flavored statement sketch
```lean
theorem strip_zeta_rational_of_spacetime_sofic
  {α : Type} [Fintype α] [DecidableEq α]
  (f : α → α → α → α) :
  SpacetimeSofic f →
  ∀ h : ℕ, IsRationalFormalPowerSeries (spacetimeZeta f h) := by
  sorry
```

And, if possible, a converse with the right uniformity hypothesis:
```lean
theorem spacetime_sofic_of_uniform_strip_recognizers
  {α : Type} [Fintype α] [DecidableEq α]
  (f : α → α → α → α) :
  (∃ K, ∀ h, ∃ M, Fintype.card M ≤ K ^ h ∧
      stripLanguageRecognizedBy f h M) →
  SpacetimeSofic f := by
  sorry
```

This would be a genuinely field-opening theorem.

---

## Recommended execution order

1. **Formalize finite strip compatibility and trace-counting**  
   This is the keystone. It will likely unlock all later counting theorems.

2. **Do the additive CA ring theorem**  
   This gives a concrete deep theorem with algebraic punch and likely manageable formal proof structure.

3. **Attack star-freeness/local testability for permutative CA**  
   Even a theorem for one-sided or affine-permutative rules would be significant.

4. **Reassess the global zeta/SFT conjecture**  
   Either prove a corrected theorem or produce a counterexample. Both outcomes are valuable.

---

## Specific build-on points from likely catalog infrastructure
Use any existing catalog theorems about:
- finite-ring periodic point counts for CA,
- transfer matrices or de Bruijn graphs,
- regularity of fixed-height spacetime languages,
- additive CA as linear maps over finite modules,
- recurrence theorems for matrix power traces,
- automata minimization or syntactic monoid constructions.

In particular:
- If there is already a theorem counting admissible words by adjacency-matrix powers, instantiate it on the column graph.
- If there is a theorem that fixed-height spacetime languages are regular, strengthen it to star-free by proving the transition monoid is aperiodic.
- If there is a theorem representing additive CA on finite rings by circulant matrices, push it through polynomial quotient rings to get gcd formulas.

---

## What would count as a genuine breakthrough
A result in any one of the following forms would already be major:
1. A formally verified transfer-matrix theorem for cyclic spacetime strip counts with rational zeta corollary.
2. A formally verified star-free or locally testable classification for a nontrivial class of CA spacetime languages.
3. A formally verified polynomial/gcd formula for periodic-point counts of additive CA on cyclic rings.
4. A counterexample that decisively refutes the naive zeta-rationality/SFT-factor equivalence and replaces it with the correct sofic-spacetime theorem.

---

## Deliverables
Produce:
- Lean theorems with minimal sorry,
- one short note explaining which conjecture was strengthened, corrected, or refuted,
- and a structured `FUTURE_DIRECTIONS.md`.

## Required `FUTURE_DIRECTIONS.md`
Include **3–5 testable scientific hypotheses**, each a falsifiable conjecture with a concrete test protocol. For example:

1. **Uniform aperiodicity hypothesis for permutative CA**  
   Conjecture: for every right-permutative nearest-neighbor CA, the syntactic monoid of `spacetimeColumnLanguage f h` is aperiodic for all `h`.  
   Test: compute minimal DFAs and syntactic monoids for all binary radius-1 right-permutative rules up to `h = 6`; refute by finding a nontrivial subgroup.

2. **Cyclotomic support hypothesis for additive CA**  
   Conjecture: for additive CA over `𝔽_p`, the eventual period of `n ↦ log_p |Fix(T^m on n)|` divides the lcm of orders of roots of irreducible factors of `P(U)^m - 1`.  
   Test: factor `P(U)^m - 1` for small `p,m`, compare predicted period with computed data.

3. **Sofic spacetime equivalence hypothesis**  
   Conjecture: a one-dimensional nearest-neighbor CA has sofic spacetime subshift iff every fixed-height strip language is recognized by an automaton of size exponential in height with a uniform base.  
   Test: prove for additive/permutative families; search computationally for counterexamples among small nonlinear rules.

4. **Zeta rigidity hypothesis**  
   Conjecture: if the cyclic strip counts satisfy a recurrence of order polynomial in `|α|^h` uniformly in `h`, then the spacetime subshift is sofic.  
   Test: estimate minimal recurrence orders numerically for representative CA families.

5. **FO-definability threshold hypothesis**  
   Conjecture: for binary radius-1 CA, star-freeness of all fixed-height strip languages is equivalent to one-sided permutativity up to topological conjugacy.  
   Test: exhaustive search over elementary CA, computing syntactic monoids for heights `h ≤ 5`.

Make these hypotheses crisp enough that the next cycle can either prove them or kill them.

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
