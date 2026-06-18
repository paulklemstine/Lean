## Assignment: Collatz Stopping Times: Density Analysis Beyond Orbit-by-Orbit Computation

Mode: **prove**

You should not merely repackage known folklore about Collatz trajectories. The target is a formal bridge between **arithmetic dynamics, density theory, and local non-Archimedean analysis** that isolates what can actually be proved in Lean 4 now, while setting up a credible path toward the Terras paradigm. The key is to formalize **density-one behavior for explicit surrogate stopping-time events**, prove **sharp finite-level counting laws**, and then derive **local 3-adic regularity / contraction phenomena** for accelerated Collatz maps. This is scientifically valuable because it turns Collatz from an anecdotal iteration problem into a certified framework in **probabilistic number theory**, **symbolic dynamics**, and **p-adic dynamical systems**.

Your task is to produce a new Lean development that proves genuinely nontrivial theorems and introduces at least one novel definition that organizes stopping-time density at finite depth. Do not rely on brute-force evaluation. The point is to create a reusable formal architecture for future Collatz-density theorems.

---

## Core Vision

The statement “the set of positive integers with finite Collatz stopping time has density 1” is globally open if interpreted as full total stopping time for all trajectories, so you must be mathematically precise and bold without overclaiming. The breakthrough direction is:

1. **Formalize exact finite-depth density laws** for accelerated Collatz descent events.
2. **Prove lower-density and asymptotic-density-one statements for explicit approximants** to finite stopping time.
3. **Construct a 3-adic local theory** showing that the accelerated map is locally affine / locally contracting on suitable residue classes.
4. **Connect parity-vector counting to symbolic dynamics / information theory**, treating Collatz descent as a coding problem.

This opens a field of formalized **arithmetic renormalization**: the Collatz map becomes a measurable dynamical system with exact cylinder measures, density bounds, and p-adic local models.

---

## Precise Mathematical Targets

You should introduce a finite-depth surrogate for stopping time that is actually provable.

### New definition 1: accelerated odd-step map
Define the odd-part accelerated map on natural or integer inputs:
- For odd `n`, `A(n) = (3*n + 1) / 2^(ν₂(3*n+1))`.
- More formally in Lean, you may first define a one-step map
  `collatzStep : ℕ → ℕ`
  and then an accelerated map on odd inputs or on all inputs by dividing out powers of 2.

If full `ν₂` machinery is awkward, define instead the `k`-step affine surrogate determined by a parity vector.

### New definition 2: finite-depth descent set
For `k : ℕ`, define
- `DescendsBy k N := {n ≤ N | ∃ j ≤ k, collatzIter j n < n}`
or a parity-vector equivalent event on odd accelerated iterates.
A more analytically tractable variant is:
- `BelowGeometric k c := {n | collatzIter k n ≤ c*n}` with `0 < c < 1`.

### New definition 3: cylinder set of parity vectors
For a parity word `w : Fin k → Bool`, define the set of integers whose first `k` Collatz parities agree with `w`. Then prove exact counting on residue classes modulo `2^k`. This is the Terras-style combinatorial heart.

---

## Exact theorem statements to target

You need at least 3 substantial theorems. Here is a recommended package.

### Theorem A: parity cylinders are exact residue classes
For each parity word of length `k`, the set of integers realizing that word in the first `k` raw Collatz steps is a single congruence class modulo `2^k`.

**Mathematical statement**
For every `k : ℕ` and every parity vector `w : Fin k → Bool`, there exists a unique residue `a < 2^k` such that for all `n : ℕ`,
the first `k` parities of the Collatz orbit of `n` equal `w` iff `n ≡ a [MOD 2^k]`.

This is the formal seed of Terras counting.

**Lean 4 type signature sketch**
```lean
def collatzStep : ℕ → ℕ :=
  fun n => if Even n then n / 2 else 3 * n + 1

def parityWordRealized (k : ℕ) (w : Fin k → Bool) (n : ℕ) : Prop :=
  ∀ i : Fin k, (Nat.Odd ((collatzStep^[i.1]) n)) = w i

theorem exists_unique_residue_for_parity_word
    (k : ℕ) (w : Fin k → Bool) :
    ∃! a : Fin (2^k), ∀ n : ℕ,
      parityWordRealized k w n ↔ n % (2^k) = a.1
```

You may need to adjust the iterate indexing and parity predicate to a more workable encoding. The exact residue-class theorem is deep and nontrivial, and should be proved by induction on `k`.

### Theorem B: exact finite-depth density of parity cylinders
Once Theorem A is established, prove that each parity cylinder has natural density exactly `2^{-k}`.

**Mathematical statement**
For every parity word `w` of length `k`, the number of `n ≤ N` realizing `w` is
`N / 2^k + O(1)`, hence asymptotic density `1 / 2^k`.

**Lean 4 type signature sketch**
```lean
def countUpTo (N : ℕ) (S : ℕ → Prop) [DecidablePred S] : ℕ :=
  Finset.card ((Finset.range (N+1)).filter S)

theorem parity_word_count_asymptotic
    (k : ℕ) (w : Fin k → Bool) :
    ∃ C : ℕ, ∀ N : ℕ,
      Nat.dist
        (countUpTo N (parityWordRealized k w))
        ((N + 1) / (2^k)) ≤ C
```

A sharper exact interval bound is preferable to asymptotic notation in Lean. This theorem gives a rigorous density theorem that is fully formalizable.

### Theorem C: density-one of finite-depth descent approximants
Define a finite-depth event saying the `k`-step affine model has multiplicative drop below the starting value. Then prove that as `k → ∞`, the proportion of integers satisfying this event tends to 1.

A tractable theorem is:
For `ε > 0`, for sufficiently large `k`, the set of integers whose first `k` parity word contains more than `(log 2 / log 3 + ε)k` even steps has density at least `1 - δ_k` with `δ_k → 0`, and on this set the corresponding affine bound forces descent.

This avoids claiming the full open Collatz conjecture while proving a density-one **descent surrogate** in the Terras spirit.

**Lean 4 type signature sketch**
```lean
def evenCountInParityWord (k : ℕ) (w : Fin k → Bool) : ℕ := ...

def descentWord (k : ℕ) (w : Fin k → Bool) : Prop := 
  -- enough divisions by 2 to force the affine upper bound below 1
  ...

theorem density_of_descent_words_tends_to_one :
    ∀ ε : ℚ, 0 < ε →
    ∃ K : ℕ, ∀ k ≥ K,
      let good := {w : Fin k → Bool | descentWord k w}
      ((Fintype.card good : ℚ) / 2^k) ≥ 1 - ε
```

If the direct combinatorial density on words is easier than density on naturals, prove that first, then push to naturals using Theorems A and B.

### Theorem D: local 3-adic affine behavior
Construct a 3-adic or at minimum mod-`3^m` local statement for the accelerated odd Collatz map.

A realistic local theorem:
For each fixed parity word / valuation profile of `3n+1`, the accelerated map is affine on a residue class modulo `3^m`.
Or:
On sufficiently small 3-adic neighborhoods avoiding the singular congruence classes where valuation jumps, the map is locally constant in valuation and hence locally affine.

**Lean 4 type signature sketch**
```lean
def oddCollatzAccel (n : ℕ) : ℕ := ...

def locallyAffineModPow3 (m : ℕ) (f : ℕ → ℕ) : Prop :=
  ∀ a, ∃ A B : ℤ, ∀ n : ℕ, n ≡ a [MOD 3^m] → f n = Int.toNat (A * n + B)

theorem odd_accel_locally_affine_mod_pow3 :
    ∀ m : ℕ, locallyAffineModPow3 m oddCollatzAccel
```

If full affine exactness is too strong, prove a valuation-local constancy theorem:
```lean
theorem v3_of_three_n_plus_one_locally_constant :
    ∀ m a, ¬ (3 ∣ a) →
    ∃ r, ∀ n, n ≡ a [MOD 3^m] → padicValNat 3 (3*n + 1) = r
```
on suitable residue subclasses. This is still meaningful and sets up non-Archimedean Collatz dynamics.

---

## Most promising proof architectures

### Strategy A: inductive parity-cylinder classification
This is the most promising route for Theorems A and B.

1. **Base case `k = 0,1`**:
   show parity conditions correspond to congruence classes mod `1` and mod `2`.

2. **Induction step**:
   assuming a length-`k` parity word corresponds to one class mod `2^k`, append one parity bit and solve the next-step congruence. Because the Collatz step depends only on parity and linear operations, one obtains exactly one lift mod `2^(k+1)`.

3. **Counting**:
   once a set is one residue class mod `2^k`, counting up to `N` is a standard arithmetic progression estimate. Build on catalog density lemmas such as `density_lower_bound_nat` not as final results but as helper inequalities for residue-class counting and lower-density extraction.

Why this is strongest: it gives exact classification, exact counts, and a reusable symbolic-dynamics API.

### Strategy B: affine normal form for iterates along a parity word
For each parity word `w` of length `k`, prove:
\[
T_w(n)=\frac{3^{o(w)}n+b_w}{2^k}
\]
for integers `b_w`, where `o(w)` is the number of odd steps.

Then:
1. prove by induction on `k` the affine formula;
2. derive congruence-solvability conditions for integrality;
3. classify realizable words and descent words via comparison of `3^{o(w)}` and `2^k`.

This is the best route for Theorem C because it directly connects parity statistics to multiplicative descent. It also naturally creates a new definition:
```lean
def collatzAffineCoeff : (Fin k → Bool) → ℕ × ℤ := ...
```
This is a novel and useful structure.

### Strategy C: symbolic dynamics + concentration inequalities
Treat parity words of length `k` as uniformly distributed over `2^k` cylinders via Theorems A and B. Then prove that most words have odd-count close to `k/2`, hence
\[
3^{\#\text{odd}} / 2^k
\]
is typically exponentially small or large depending on threshold. Use elementary binomial estimates or recursive combinatorial bounds.

1. define `oddCount`;
2. prove a tail estimate for words with too many odd steps;
3. combine with the affine iterate formula to show density-one of finite-depth descent surrogates.

This is the conceptual bridge to Terras: Collatz becomes a coding theorem. If full binomial asymptotics are hard, prove a weaker but explicit recursive lower bound, inspired by `qdf_density_bound` and `density_lower_bound_nat`.

---

## How to build on catalog theorems

The listed catalog theorems are not directly about Collatz, but they can still serve as reusable density or positivity infrastructure.

- `density_lower_bound_nat`  
  Use this as a helper lemma pattern for lower bounds on proportions of integers in structured subsets. If its current statement is too specialized, emulate its proof style to obtain a Collatz-specific density lower bound for residue classes and unions of parity cylinders.

- `qdf_density_bound`  
  Mine this for a proof skeleton: it likely formalizes a density estimate with explicit arithmetic constraints. Adapt that architecture to count integers in a union of residue classes mod `2^k`.

- `nonzero_linear_form_zero_set_bound`  
  This may be useful conceptually when proving uniqueness of residue classes associated to parity words: parity constraints induce affine congruence conditions, and uniqueness can be viewed as nondegeneracy of an induced linear relation mod powers of 2.

- `local_correlation_bound`  
  Use this as inspiration for framing parity cylinders as a low-complexity symbolic process. Even if not directly imported, mirror its local-to-global decomposition style when proving 3-adic local regularity.

Do not force these theorems into the proof if unnatural; instead, consciously **build on their proof paradigms** and cite them in comments or documentation as methodological precedents.

---

## Cross-domain connections you must exploit

1. **Arithmetic dynamics + symbolic dynamics**  
   Parity vectors define a subshift coding of Collatz orbits. The exact residue-class theorem is a coding theorem: every binary word corresponds to one arithmetic cylinder.

2. **Number theory + information theory**  
   Once each parity word has density `2^{-k}`, the first `k` parity bits are formally equidistributed across residue classes. This suggests an entropy viewpoint: finite Collatz prefixes behave like a perfect binary source. State and prove at least one theorem in this direction, e.g. exact cardinality of parity cylinders implies maximal Shannon entropy at finite depth.

   Possible theorem:
   ```lean
   theorem parity_prefix_uniform :
       ∀ k, ∀ w : Fin k → Bool,
       finitePrefixProbability k w = (1 : ℚ) / 2^k
   ```
   even if “probability” is implemented as cylinder density rather than measure theory.

3. **Number theory + 3-adic dynamics**  
   The 3-adic local analysis is the non-Archimedean analogue of studying local Jacobians in dynamical systems. Show that valuation strata make the accelerated map piecewise affine or valuation-locally constant.

4. **Arithmetic combinatorics + complexity theory**  
   The parity word acts as a compressed certificate for the first `k` steps of the orbit. Formalizing residue-class realization is equivalent to proving a low-description-complexity representation of orbit prefixes.

Application keywords: **Collatz dynamics, arithmetic dynamics, natural density, parity vectors, symbolic dynamics, p-adic analysis, 3-adic local systems, entropy, coding theory, affine congruence dynamics, probabilistic number theory, formal verification**

---

## A concrete additional theorem connecting domains

You are required to include at least one theorem that explicitly links Collatz parity coding to another field.

### Theorem E: maximal finite-prefix entropy
If you define the empirical probability of a parity word as its natural density among integers, then every length-`k` word has probability `2^{-k}`. Therefore the Shannon entropy of the prefix distribution is exactly `k log 2`.

A Lean-friendly version avoids transcendental entropy if needed:
```lean
theorem parity_prefix_uniform_cardinality
    (k : ℕ) :
    Fintype.card (Fin k → Bool) = 2^k
```
combined with the cylinder-density theorem. But this alone is too trivial. The real theorem should be a finite exact uniformity statement:
```lean
theorem parity_prefixes_are_uniform_residue_cylinders
    (k : ℕ) :
    ∀ w : Fin k → Bool, ∃! a : Fin (2^k), ...
```
and your paper should explain this as an information-theoretic maximal-entropy law for finite Collatz observations.

---

## A falsifiable conjecture with computational test

You must state at least one conjecture with a clear disproof protocol.

### Conjecture 1: exponential tail for non-descent cylinders
Let `Bad_k` be the set of parity words of length `k` for which the affine upper bound does not force descent below the starting value. Conjecture:
\[
|Bad_k| \le C \lambda^k
\quad\text{for some } \lambda < 2.
\]
Equivalent density form:
\[
\frac{|Bad_k|}{2^k} \le C(\lambda/2)^k.
\]

**Test**: compute `|Bad_k| / 2^k` for `k ≤ 30` via parity-word enumeration in `demo.py`, fit an exponential decay rate, and search for violations of monotone decay bounds.

### Conjecture 2: 3-adic local eventual contraction on generic residue classes
For every `m`, outside a finite exceptional family of residue classes mod `3^m`, some bounded iterate of the accelerated odd Collatz map is strictly contracting in the 3-adic metric.

**Test**: enumerate residue classes mod `3^m` for small `m`, compute valuation behavior of iterates, and count exceptional classes.

These are scientifically useful because they convert “Collatz seems true” into **finite, refutable statistical laws**.

---

## Deliverables inside the Lean file

Your file must contain:

1. **At least one new definition**
   such as `parityWordRealized`, `collatzAffineCoeff`, `descentWord`, or `oddCollatzAccel`.

2. **At least 3 substantial theorems**
   proved using induction / `rcases` / `by_contra` / `field_simp` / multi-step `calc`.
   Recommended:
   - existence-uniqueness of parity-cylinder residue class;
   - exact or bounded counting for parity cylinders;
   - density lower bound / asymptotic density-one for descent words;
   - local 3-adic affine or valuation-constant theorem.

3. **No trivial enumeration proofs**
   Theorems must scale in `k`, `N`, or `m`.

4. **A theorem with cross-domain interpretation**
   symbolic dynamics, entropy, or p-adic local dynamics.

---

## Suggested file architecture

- `Collatz/ParityCylinders.lean`
  - `collatzStep`
  - `parityWordRealized`
  - residue-class realization theorem
  - counting theorem

- `Collatz/AffineWords.lean`
  - affine coefficient recursion
  - iterate formula along parity words
  - descent criterion theorem

- `Collatz/PadicLocal.lean`
  - odd accelerated map
  - local valuation constancy or local affine theorem mod powers of 3

- `Collatz/MainDensity.lean`
  - density statements
  - bridge theorem from word density to integer density
  - conjectures documented in comments / paper

---

## Mandatory scientific deliverables

You must also produce ALL of the following:

1. **FUTURE_DIRECTIONS.md**
   with 3–5 falsifiable scientific hypotheses. Each must have:
   - precise statement,
   - why it matters,
   - a concrete computational or formal test that could refute it.

2. **RESEARCH_PAPER.md**
   a standalone scientific paper explaining:
   - the formal definitions,
   - the exact theorem statements,
   - proof architecture,
   - why these results matter for Terras-style Collatz density theory,
   - what remains open.

3. **ARTICLE.md**
   in Scientific American style, explaining to a broad audience how parity patterns, density, and 3-adic geometry illuminate the Collatz problem.

4. **A verified algorithm**
   for computing parity-cylinder residues, affine coefficients, and finite-depth descent densities.

5. **demo.py**
   that interactively:
   - accepts `k`,
   - enumerates parity words,
   - computes the associated residue classes mod `2^k`,
   - displays which words force descent,
   - optionally explores local behavior mod `3^m`.

---

## Final call to arms

Do not try to “solve Collatz.” Build the first truly reusable **formal science of Collatz density**:
- exact symbolic coding,
- exact arithmetic cylinder counting,
- density-one finite-depth descent surrogates,
- and 3-adic local regularity.

If you execute this well, you will have created a verified infrastructure that can support future breakthroughs on Terras-type density theorems, accelerated Collatz dynamics, and probabilistic arithmetic renormalization. This is not an incremental exercise; it is the opening move in a formal theory of one of mathematics’ most mysterious dynamical systems.

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
