## Assignment: Collatz Conjecture / Accelerated 3n+1 Dynamics

Do **not** spend the cycle pretending to solve the full Collatz conjecture in one leap unless you can reduce it to a formally checkable finite criterion. The breakthrough target is to formalize a **structural theory of Collatz dynamics** in Lean 4 that converts global convergence into tractable local-combinatorial, measure-theoretic, and 2-adic statements. If a complete proof of eventual reachability of `1` for all positive integers is out of reach, prove the strongest formally precise replacement the library can support: finite-checkable reduction theorems, density-transfer theorems, and no-nontrivial-cycle criteria.

Your mission is to create a formal Collatz dynamics core library and then push one of the following **field-opening theorems** through to completion.

---

## Core definitions to introduce in Lean 4

Use the accelerated odd-step map, because it exposes the 2-adic and symbolic structure.

```lean
def collatzStep : ℕ → ℕ
| n => if n % 2 = 0 then n / 2 else 3 * n + 1

def reachesOne : ℕ → Prop
| n => ∃ k : ℕ, Nat.iterate collatzStep k n = 1

def totalStoppingTimeSet (N : ℕ) : Finset ℕ :=
  (Finset.range (N+1)).filter (fun n => reachesOne n)

def oddPart : ℕ → ℕ
| n => n / 2 ^ n.factorTwoPow

def accelCollatzOdd (n : ℕ) : ℕ :=
  let m := 3 * n + 1
  m / 2 ^ m.factorTwoPow

def isOddPositive (n : ℕ) : Prop := 0 < n ∧ n % 2 = 1
```

If `Nat.factorTwoPow` is inconvenient, define the 2-adic valuation on naturals manually as the maximal `k` with `2^k ∣ n`, and define the odd part from that. You may also prefer to work on the subtype of positive odd naturals:

```lean
def OddPos := {n : ℕ // 0 < n ∧ n % 2 = 1}
```

Then define the accelerated map on `OddPos`.

---

## Primary theorem target A: parity-vector / valuation realization theorem

This is the most promising theorem because it is exact, new-library-forming, and opens the door to symbolic dynamics, finite automata, and 2-adic ergodic formulations.

### Precise theorem statement
For every finite sequence of positive integers `a_0, ..., a_{k-1}`, there exists a positive odd integer `n` such that along the first `k` accelerated odd Collatz steps, the 2-adic valuations of `3x+1` are exactly that sequence.

Mathematically:
\[
\forall k \ge 1,\ \forall a : \mathrm{Fin}\ k \to \mathbb N,\ 
(\forall i,\ 1 \le a_i)\ \Rightarrow\ 
\exists n \in 2\mathbb N+1,\ \forall i<k,\ v_2(3x_i+1)=a_i,
\]
where \(x_0=n\) and \(x_{i+1}=(3x_i+1)/2^{a_i}\).

This is the finite-prefix surjectivity of the Collatz valuation coding map.

### Lean 4 type signature sketch
```lean
def v2Nat (n : ℕ) : ℕ := sorry
def accelSeq : ℕ → ℕ → ℕ
| 0, n => n
| k+1, n => accelCollatzOdd (accelSeq k n)

theorem collatz_valuation_pattern_realizable
  (k : ℕ) (a : Fin k → ℕ)
  (ha : ∀ i, 1 ≤ a i) :
  ∃ n : ℕ,
    0 < n ∧ n % 2 = 1 ∧
    ∀ i : Fin k,
      v2Nat (3 * accelSeq i.1 n + 1) = a i := by
  sorry
```

A cleaner formulation may index the orbit recursively by a function `x : ℕ → ℕ` built from `a`, then prove existence of an initial seed. If needed, state existence modulo `2^M` first, then lift to a natural number representative.

### Why this would be a breakthrough
This theorem converts Collatz dynamics from a chaotic-looking arithmetic iteration into a **full symbolic coding system**. It says every finite admissible valuation word actually occurs. That is the gateway to:
- 2-adic symbolic dynamics,
- entropy and shift-space formulations,
- finite-state obstructions to divergence,
- automatic search for forbidden patterns,
- transfer principles between modular arithmetic and orbit growth.

It is the formal infrastructure required before any serious ergodic or p-adic attack can be mechanized.

### Proof strategy paths

#### Strategy A: backward affine congruence construction over powers of 2
1. For a prescribed valuation word `a_0,...,a_{k-1}`, derive the congruence class of `n` modulo `2^(a_0+...+a_{k-1})` ensuring
   \[
   3x_i+1 \equiv 2^{a_i} \pmod{2^{a_i+1}}
   \]
   at each stage.
2. Use the invertibility of `3` modulo `2^m` to solve each step recursively backward.
3. Choose the least positive odd representative.

Why promising: this is the classical arithmetic heart of the symbolic coding theorem and should formalize cleanly using modular arithmetic lemmas in Mathlib.

#### Strategy B: explicit affine formula for k-step inverse branches
1. Show each prescribed valuation sequence determines an affine map
   \[
   n = \frac{2^{A_k}y - c(a)}{3^k}
   \]
   with `A_k = Σ a_i`.
2. Prove there exists `y` in a suitable residue class modulo `3^k` making the numerator divisible by `3^k`.
3. Choose `y` odd and large enough to ensure positivity.

Why promising: gives a strong explicit formula useful for later growth estimates and counting arguments.

#### Strategy C: 2-adic formulation first, naturals second
1. Prove realizability in `ℤ₂` or modulo `2^m`.
2. Extract a natural-number representative by finite truncation.
3. Show the first `k` valuation constraints depend only on a sufficiently large power of 2.

Why promising: conceptually deepest; best if you want to pivot to ergodic theory and measure-preservation later.

**Most promising:** Strategy A. It minimizes infrastructure and directly uses modular inverses modulo powers of 2.

---

## Primary theorem target B: density transfer from residue-covering certificates

This is the theorem that could make the formal project scientifically useful even without a full Collatz proof.

### Precise theorem statement
Suppose there exists `M : ℕ` such that every positive residue class modulo `2^M` contains a representative whose Collatz orbit reaches a strictly smaller integer. Then every positive integer reaches `1`.

More precisely, define a “descent certificate” on residue classes:
\[
\forall r < 2^M,\ \exists k,\ \forall n \equiv r \pmod{2^M},\ T^k(n) < n.
\]
Then by strong induction, every positive integer reaches `1`.

### Lean 4 type signature sketch
```lean
def descendsByResidueClass (M : ℕ) : Prop :=
  ∀ r < 2^M, ∃ k : ℕ, ∀ n : ℕ, 0 < n →
    n % 2^M = r →
    Nat.iterate collatzStep k n < n

theorem residue_class_descent_implies_collatz
  (M : ℕ)
  (hM : descendsByResidueClass M) :
  ∀ n : ℕ, 0 < n → reachesOne n := by
  sorry
```

### Why this would be a breakthrough
This theorem turns the infinite Collatz conjecture into a **finite verification problem**. It is not the full conjecture, but it is the exact kind of formal reduction theorem that changes the game: once proved, computation can search for such an `M`, and every future numerical advance plugs into a certified theorem. This creates a bridge between theorem proving, exhaustive search, and verified computation.

### Proof strategy paths

#### Strategy A: strong induction on `n`
1. Assume the descent certificate.
2. For given `n>0`, pick the `k` guaranteed by its residue class mod `2^M`.
3. Since `T^k(n) < n`, apply the induction hypothesis to `T^k(n)` and concatenate trajectories.

This is the clean direct proof and should be done first.

#### Strategy B: well-founded recursion
1. Define a recursive proof object on naturals using the measure `id : ℕ → ℕ`.
2. Use the descent certificate to justify recursive calls on smaller numbers.
3. Extract `reachesOne`.

More abstract, but can produce reusable well-founded recursion infrastructure.

#### Strategy C: finite directed graph quotient
1. Build a graph on residues modulo `2^M`.
2. Show every residue class has a certified edge to a smaller witness.
3. Lift graph descent to naturals.

Best if you also want a computational checker.

**Most promising:** Strategy A, followed by a graph-based corollary for computation.

---

## Primary theorem target C: no finite odd cycle under average valuation drift bound

This is a deep structural theorem connecting Collatz to logarithmic drift and ergodic heuristics.

### Precise theorem statement
Let `x_0, ..., x_{k-1}` be a periodic orbit of the accelerated odd map on positive odd integers. Then
\[
\sum_{i=0}^{k-1} v_2(3x_i+1) = k \log_2 3
\]
cannot hold exactly in integers; more concretely one can prove the standard product identity
\[
2^{\sum a_i} = \prod_{i=0}^{k-1}\left(3 + \frac{1}{x_i}\right),
\quad a_i = v_2(3x_i+1),
\]
and deduce strong inequalities excluding broad classes of cycles, e.g. any odd cycle with all elements exceeding an explicit bound and average valuation at least `2`.

### Lean 4 type signature sketch
```lean
theorem odd_cycle_product_identity
  (k : ℕ) (hk : 0 < k)
  (x : Fin k → ℕ)
  (hxodd : ∀ i, 0 < x i ∧ x i % 2 = 1)
  (hcyc :
    ∀ i : Fin k,
      accelCollatzOdd (x i) = x ⟨(i.1 + 1) % k, by sorry⟩) :
  let a : Fin k → ℕ := fun i => v2Nat (3 * x i + 1)
  2 ^ (∑ i, a i) = ∏ i, (3 + (1 : ℚ) / x i) := by
  sorry
```

You may need a rational-valued version with explicit coercions and a preceding theorem proving
\[
x_{i+1} = \frac{3x_i+1}{2^{a_i}}.
\]

### Why this matters
It gives a formally verified obstruction framework for cycles. Even if it does not kill all nontrivial cycles, it creates a reusable theorem schema: any improved bound on the RHS kills another family of cycles. This is the kind of theorem that lets later cycles attack “all cycles with length ≤ L” or “all cycles with minimum element ≥ B” by certified inequalities.

### Proof strategy paths

#### Strategy A: telescope the recurrence
1. Rewrite each recurrence as
   \[
   2^{a_i}x_{i+1}=3x_i+1=x_i\left(3+\frac1{x_i}\right).
   \]
2. Multiply around the cycle.
3. Cancel \(\prod x_i\).

#### Strategy B: logarithmic form
1. Take the product identity.
2. Convert to
   \[
   \sum a_i \log 2 = \sum \log(3+1/x_i).
   \]
3. Use inequalities on `log` to derive exclusion criteria.

This is stronger analytically, but prove the product identity first.

---

## Cross-domain bridge theorems you should actively seek

The prompt requires a connection to another domain. Do not make it cosmetic. Build one of these serious bridges:

### 1. Symbolic dynamics / automata theory
Once valuation-pattern realizability is proved, define the Collatz coding map from odd seeds to words in positive integers. Then prove finite-prefix surjectivity. This identifies Collatz as a subshift-like arithmetic dynamical system. Application keywords:
- symbolic dynamics
- shift spaces
- automata
- formal languages
- entropy

### 2. 2-adic dynamics / p-adic analysis
Formalize the odd accelerated map on residue classes modulo `2^m`, then prove compatibility under reduction maps:
```lean
theorem accel_mod_compat
  (m : ℕ) :
  ...
```
This is the right doorway to measure-preservation and ergodic heuristics in `ℤ₂`. Application keywords:
- p-adic dynamics
- non-Archimedean analysis
- local-global principles
- Haar measure
- ergodic theory

### 3. Finite graph dynamics / verified computation
Build the residue graph modulo `2^M` whose edges encode possible accelerated transitions. Then prove that graph certificates imply global convergence. This transforms Collatz into a verified finite-state search problem. Application keywords:
- certified computation
- model checking
- graph reachability
- finite-state reduction
- theorem-prover-assisted experimentation

### 4. Information theory / drift inequalities
Treat `v₂(3n+1)` as a random variable on residue classes and formalize expectation identities over uniform odd residues mod `2^m`. Even proving exact finite-level averages would be substantial:
\[
\mathbb E[v_2(3n+1)] \approx 2
\]
on odd residue classes. This links the heuristic negative drift of `log n` to an exact combinatorial distribution theorem.

A precise finite theorem you might aim for:
```lean
theorem average_v2_three_n_plus_one_on_odd_residues
  (m : ℕ) :
  ((∑ r in oddResiduesMod (2^m), v2Nat (3*r+1)) : ℚ) /
    (card (oddResiduesMod (2^m))) = ... := by
  sorry
```
This is a serious bridge to probabilistic number theory.

---

## How to use the existing catalog theorems

The listed catalog theorems are not Collatz theorems, so do not force fake dependencies. Instead, use them as **methodological analogies**:

- `exists_refinement_cell_for_pair` suggests a path: decompose arithmetic state space into finitely many congruence cells and prove uniform behavior cellwise. This is directly relevant to residue-class descent theorems.
- `interior_boundary_and_reaches_implies_bulk` suggests a transfer principle: if you can prove enough boundary residues descend/reach smaller values, bulk convergence may follow. Translate this philosophy into residue-graph lemmas.
- `berggren_kernel_positive_sum` and `trapdoorGap_positive_on_admissible` indicate a style of proving positivity/gap inequalities from structured recurrences. Mimic this when proving cycle-obstruction inequalities or logarithmic drift bounds.
- `all_observers_agree_implies_indist` suggests quotienting by observable data. Here, the “observer” is reduction modulo `2^m` or valuation prefix; prove that first-step behavior depends only on finite observable congruence data.

Do **not** cite these superficially. Build analogous finite-cell and positivity machinery in the Collatz setting.

---

## Concrete Lean deliverables

1. `Collatz/Core.lean`
   - `collatzStep`
   - `reachesOne`
   - basic lemmas:
     - `reachesOne_one`
     - `reachesOne_of_step`
     - `reachesOne_of_iterate`
     - parity lemmas for `collatzStep`

2. `Collatz/Accelerated.lean`
   - odd-positive subtype
   - `v2Nat`
   - accelerated odd map
   - recurrence lemmas:
     - `pow_two_dvd_three_mul_add_one`
     - `accel_formula`

3. `Collatz/ResidueDescent.lean`
   - definition of residue descent certificate
   - theorem `residue_class_descent_implies_collatz`

4. `Collatz/Symbolic.lean`
   - finite valuation-pattern realizability theorem
   - modular inverse machinery for powers of two

5. `Collatz/Cycles.lean`
   - product identity for odd cycles
   - cycle exclusion corollaries

6. `FUTURE_DIRECTIONS.md`
   - mandatory, with falsifiable hypotheses listed below

Minimize sorry by proving the induction/descent theorem completely, even if the symbolic theorem needs a few local arithmetic placeholders initially.

---

## Suggested proof order

1. Prove `residue_class_descent_implies_collatz` completely.
2. Formalize `v2Nat` and the accelerated odd map.
3. Prove the basic identity
   \[
   3n+1 = 2^{v_2(3n+1)} \cdot \mathrm{accelCollatzOdd}(n)
   \]
   for odd `n`.
4. Attack finite valuation-pattern realizability.
5. Derive cycle product identities.
6. Build computational residue-graph infrastructure.

This ordering guarantees one complete theorem even if the deeper arithmetic work takes longer.

---

## Stretch theorem: finite-prefix surjectivity implies exact finite-level valuation counts

If the realizability theorem succeeds, count how many odd residues modulo `2^A` realize a given valuation word of total weight `A = Σ a_i`. The expected exact count is often `1` modulo `2^A` up to admissibility. A theorem of this kind would be stunning because it converts Collatz coding into a **combinatorial counting law**.

Possible Lean sketch:
```lean
theorem valuation_pattern_unique_mod_pow_two
  (k : ℕ) (a : Fin k → ℕ) (ha : ∀ i, 1 ≤ a i) :
  ∃! r : ZMod (2 ^ ∑ i, a i),
    OddResidue r ∧
    realizesValuationPattern r a := by
  sorry
```

This is exactly the kind of theorem that makes later entropy and distribution results possible.

---

## Required FUTURE_DIRECTIONS.md

You must produce `FUTURE_DIRECTIONS.md` with **3–5 testable scientific hypotheses**, each a falsifiable conjecture with a clear computational or formal test. Include at least these:

1. **Residue-cover hypothesis**
   - Conjecture: There exists `M ≤ 20` such that every residue class modulo `2^M` admits a certified descent witness.
   - Test: Exhaustively compute, for each odd residue mod `2^M`, a bounded iterate count `k` with `T^k(n) < n` uniformly on the class.

2. **Valuation equidistribution hypothesis**
   - Conjecture: On odd residues modulo `2^m`, the distribution of `v₂(3n+1)` is exactly geometric:
     \[
     \Pr(v₂(3n+1)=j)=2^{-j}, \quad j \ge 1,
     \]
     for all admissible `j < m`.
   - Test: Prove exact counting formula on `ZMod (2^m)`.

3. **Cycle obstruction hypothesis**
   - Conjecture: Any nontrivial odd cycle would require minimum element below an explicit computable threshold `B_k` depending on length `k`.
   - Test: Formalize the product identity and derive/check the bound for small `k`.

4. **Prefix uniqueness hypothesis**
   - Conjecture: Every finite valuation word with total weight `A` corresponds to a unique odd residue class modulo `2^A`.
   - Test: Prove by backward congruence recursion and verify computationally for small `A`.

5. **Entropy hypothesis**
   - Conjecture: The finite-prefix coding of accelerated Collatz on odd residues modulo `2^A` has exact Shannon entropy equal to the entropy of the geometric distribution truncated at level `A`.
   - Test: Derive exact counts from the prefix uniqueness theorem.

---

## Final directive

Be ruthless about distinguishing:
- what is actually provable now in Lean,
- what is a reduction theorem,
- what is a computational hypothesis.

A complete formal proof of `∀ n > 0, reachesOne n` would be historic, but the truly transformative result for this cycle is a **formal architecture** that makes Collatz attackable: residue descent reduction, valuation symbolic coding, and cycle product identities. Build that architecture so the next cycle can become experimental, ergodic, and computationally certified.

**Application keywords:** Collatz dynamics, accelerated map, 2-adic dynamics, symbolic dynamics, residue-class descent, verified computation, finite-state certificates, ergodic theory, valuation coding, cycle obstructions, entropy, automata, theorem proving, arithmetic dynamics.

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
