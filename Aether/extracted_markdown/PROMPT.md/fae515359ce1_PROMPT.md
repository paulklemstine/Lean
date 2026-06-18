Soli Deo Gloria

## Assignment: Direction 3 — P-adic Orbital Period Valuation

**Mode:** `prove`

Prove genuinely new theorems that turn the heuristic “Kepler periods carry arithmetic depth” into a precise p-adic/tropical correspondence. Do not settle for the obvious valuation identity alone. The breakthrough target is to **manufacture an arithmetic celestial mechanics invariant** and show it is recoverable from tropical orbit data.

Build explicitly on:

- `Catalog/Pythagorean/TropicalKeplerOrbits.lean`
  - `tropicalVal_mul`
  - `tropicalVal_pow`
  - `tropicalVal_inv`

Minimize `sorry`. The file should contain a small but coherent theory, not isolated lemmas.

---

## Core Vision

The naive physical period
\[
T = 2\pi \, a^{3/2}\mu^{-1/2}
\]
is not itself rational in general, so its p-adic valuation is only directly meaningful after passing to a rationalized orbital invariant. The right move is not to dodge this subtlety, but to **elevate it into the theorem statement**.

Define the **rationalized Kepler period invariant**
\[
\Theta(a,\mu) := \left(\frac{T}{2\pi}\right)^2 = \frac{a^3}{\mu}.
\]
This is always rational for \(a,\mu \in \mathbb Q\), and its p-adic valuation is canonically defined. Then recover the “half-valuation” formula exactly in the even-parity/square-root-admissible regime.

This gives two layers:

1. **Unconditional arithmetic invariant:** \(v_p(\Theta)=3v_p(a)-v_p(\mu)\).
2. **Conditional orbital period law:** if square roots exist in the rational/p-adic regime with even valuation parity, then
   \[
   v_p(T/2\pi)=\frac{3}{2}v_p(a)-\frac{1}{2}v_p(\mu).
   \]

The second theorem should be presented as a corollary of the first plus a square-root valuation lemma.

This is stronger and cleaner than the original conjecture. It transforms an ambiguous irrational expression into a robust arithmetic object, then shows how the original formula emerges when the arithmetic permits it.

---

## Precise Formal Targets

You should introduce at least one genuinely new definition, preferably two:

### New Definitions

1. **Rationalized orbital period**
   ```lean
   def orbitalPeriodSquared (a μ : ℚ) : ℚ := a^3 / μ
   ```

2. **Vertex depth profile for a tropicalized orbital datum**
   ```lean
   def orbitalVertexDepth (p : ℕ) (x : ℚ) : ℤ := tropicalVal p x
   ```

3. **Admissibility predicate for half-valuations**
   ```lean
   def EvenValuationPair (p : ℕ) (a μ : ℚ) : Prop :=
     Even (tropicalVal p a) ∧ Even (tropicalVal p μ)
   ```

If the catalog already contains nearby notions, refine the names but keep the mathematical novelty: the new concept should be the **orbital arithmetic invariant**, not merely a wrapper.

---

## Theorem 1: Unconditional p-adic Kepler cubic law

### Mathematical statement
For prime \(p\), nonzero rationals \(a,\mu\),
\[
v_p\!\left(\frac{a^3}{\mu}\right)=3v_p(a)-v_p(\mu).
\]

This is the true arithmetic core. It is not just a formal manipulation: it identifies a **conserved valuation law** for Kepler scaling, independent of analytic square-root issues.

### Suggested Lean 4 type signature
```lean
theorem tropicalVal_orbitalPeriodSquared
    {p : ℕ} (hp : Nat.Prime p) {a μ : ℚ}
    (ha : a ≠ 0) (hμ : μ ≠ 0) :
    tropicalVal p (orbitalPeriodSquared a μ)
      = 3 * tropicalVal p a - tropicalVal p μ
```

If subtraction on the right is inconvenient, phrase it via addition and inverse:
```lean
theorem tropicalVal_orbitalPeriodSquared'
    {p : ℕ} (hp : Nat.Prime p) {a μ : ℚ}
    (ha : a ≠ 0) (hμ : μ ≠ 0) :
    tropicalVal p (orbitalPeriodSquared a μ)
      = tropicalVal p (a^3) + tropicalVal p μ⁻¹
```
and then simplify using catalog lemmas.

### Why this is a breakthrough
This theorem converts Kepler’s third law into a valuation-theoretic conservation principle. It says the orbital period carries an arithmetic signature linear in the valuations of semimajor axis and gravitational parameter. That is the first step toward an **arithmetic dynamics of celestial systems**.

---

## Theorem 2: Half-valuation period law in the square-root-admissible regime

### Mathematical statement
Assume \(a,\mu \in \mathbb Q^\times\), and their p-adic valuations are even so that the half-valuation expression lands in \(\mathbb Z\) after division by 2. Then, whenever the square-root normalization is defined in your formal setup,
\[
v_p(T/2\pi)=\frac{3}{2}v_p(a)-\frac{1}{2}v_p(\mu).
\]

In Lean, since \(T\) itself may not live naturally in `ℚ`, the best formal version is often a theorem **about existence of an integer \(k\)** whose doubling equals the valuation of the rationalized invariant:
\[
2k = 3v_p(a)-v_p(\mu).
\]
Then define \(k\) as the orbital half-valuation.

### Suggested Lean 4 type signature
A robust arithmetic formulation:
```lean
def orbitalHalfValuation (p : ℕ) (a μ : ℚ) : ℤ :=
  (3 * tropicalVal p a - tropicalVal p μ) / 2
```

Then prove integrality under parity assumptions:
```lean
theorem orbitalHalfValuation_spec
    {p : ℕ} (hp : Nat.Prime p) {a μ : ℚ}
    (ha : a ≠ 0) (hμ : μ ≠ 0)
    (hev : EvenValuationPair p a μ) :
    2 * orbitalHalfValuation p a μ
      = 3 * tropicalVal p a - tropicalVal p μ
```

If you manage a square-root formalization over rationals for exact squares, aim higher:
```lean
theorem tropicalVal_keplerPeriod_half
    {p : ℕ} (hp : Nat.Prime p) {a μ α β : ℚ}
    (ha : a ≠ 0) (hμ : μ ≠ 0)
    (hα : α^2 = a) (hβ : β^2 = μ) :
    tropicalVal p (a * α / β)
      = (3 * tropicalVal p a - tropicalVal p μ) / 2
```
or some algebraically equivalent formulation. The exact encoding may vary, but the theorem must isolate the square-root issue rather than hide it.

### Why this matters
This theorem upgrades the cubic law into an actual “period valuation law” in arithmetic regimes where the square roots are visible. It creates a precise bridge between **classical orbital mechanics** and **non-Archimedean valuation geometry**.

---

## Theorem 3: Tropical depth recovery theorem

### Mathematical statement
If an orbital tropicalization records coefficient depths by p-adic valuation, then the depth profile of the tropical orbit determines the valuation of the rationalized period invariant:
\[
v_p(\Theta(a,\mu))
=
3\,\mathrm{depth}(a)-\mathrm{depth}(\mu).
\]

This theorem should not merely restate Theorem 1. It should connect a new “depth profile” structure to the arithmetic invariant and show **read-off recoverability** from tropical data.

### Suggested Lean 4 type signature
```lean
structure OrbitalDepthProfile where
  depthA : ℤ
  depthMu : ℤ

def periodDepthInvariant (D : OrbitalDepthProfile) : ℤ :=
  3 * D.depthA - D.depthMu

theorem periodDepthInvariant_correct
    {p : ℕ} (hp : Nat.Prime p) {a μ : ℚ}
    (ha : a ≠ 0) (hμ : μ ≠ 0) :
    periodDepthInvariant
      { depthA := tropicalVal p a, depthMu := tropicalVal p μ }
    = tropicalVal p (orbitalPeriodSquared a μ)
```

This theorem is your **tropical geometry bridge**: the arithmetic invariant is encoded in a combinatorial depth profile.

### Why this is revolutionary
It says the p-adic orbital invariant is not hidden in transcendental dynamics; it is visible in the tropical shadow. That is exactly the sort of statement that can open a new field: **arithmetic tropical celestial mechanics**.

---

## Theorem 4: Scaling covariance under rational dilation

You need at least one theorem that shows this invariant behaves nontrivially under orbital rescaling.

### Mathematical statement
For nonzero rational \(\lambda\),
\[
v_p\!\left(\Theta(\lambda a,\mu)\right)
=
v_p(\Theta(a,\mu)) + 3v_p(\lambda).
\]

Or alternatively,
\[
v_p\!\left(\Theta(a,\lambda \mu)\right)
=
v_p(\Theta(a,\mu)) - v_p(\lambda).
\]

### Suggested Lean 4 type signature
```lean
theorem tropicalVal_orbitalPeriodSquared_scale_a
    {p : ℕ} (hp : Nat.Prime p) {a μ λ : ℚ}
    (ha : a ≠ 0) (hμ : μ ≠ 0) (hλ : λ ≠ 0) :
    tropicalVal p (orbitalPeriodSquared (λ * a) μ)
      = tropicalVal p (orbitalPeriodSquared a μ) + 3 * tropicalVal p λ
```

### Significance
This identifies a renormalization law: scaling semimajor axis shifts orbital arithmetic depth by exactly triple the scaling valuation. This is the valuation-theoretic analogue of Kepler scaling symmetry.

---

## Theorem 5: Cross-domain bridge — valuation conservation as a tropical Hamiltonian shadow

You are required to include a theorem that explicitly connects to another domain. The cleanest bridge is to **min-plus / tropical linearity**.

Define a “Kepler valuation energy”
```lean
def keplerValuationCharge (p : ℕ) (a μ : ℚ) : ℤ :=
  3 * tropicalVal p a - tropicalVal p μ
```

Then prove this is additive under tropical product composition of independent orbital data:
\[
Q_p(a_1a_2,\mu_1\mu_2)=Q_p(a_1,\mu_1)+Q_p(a_2,\mu_2).
\]

### Suggested Lean 4 type signature
```lean
theorem keplerValuationCharge_mul
    {p : ℕ} (hp : Nat.Prime p)
    {a₁ a₂ μ₁ μ₂ : ℚ}
    (ha₁ : a₁ ≠ 0) (ha₂ : a₂ ≠ 0)
    (hμ₁ : μ₁ ≠ 0) (hμ₂ : μ₂ ≠ 0) :
    keplerValuationCharge p (a₁ * a₂) (μ₁ * μ₂)
      = keplerValuationCharge p a₁ μ₁
      + keplerValuationCharge p a₂ μ₂
```

### Cross-domain interpretation
This is a bridge between:

- **Number theory:** p-adic valuations
- **Celestial mechanics:** Kepler scaling law
- **Tropical geometry:** linearization via valuation
- **Mathematical physics:** additive conserved charge / Hamiltonian shadow

It suggests a tropicalized conservation law for composite orbital systems.

---

## Proof Strategy Architecture

You must give Aristotle multiple proof routes and then choose the most promising.

### Strategy A — Direct valuation algebra from catalog lemmas
Most promising for Theorems 1, 3, 4, 5.

1. Expand
   \[
   \Theta(a,\mu)=a^3\mu^{-1}.
   \]
2. Apply:
   - `tropicalVal_mul`
   - `tropicalVal_pow`
   - `tropicalVal_inv`
3. Rearrange with `ring`, `linarith`, or explicit integer arithmetic.
4. Use `field_simp` only where needed for rational identities before valuation is applied.

**Why best:** It is structurally aligned with the catalog and minimizes analytic complications.

### Strategy B — Introduce a valuation-charge homomorphism
Best for conceptual organization and the cross-domain theorem.

1. Define
   \[
   Q_p(a,\mu)=3v_p(a)-v_p(\mu).
   \]
2. Prove `Q_p` is additive on multiplicative pairs.
3. Show
   \[
   Q_p(a,\mu)=v_p(a^3/\mu).
   \]
4. Derive scaling and depth-recovery as corollaries.

**Why powerful:** It packages the whole theory as a homomorphism from orbital parameter space to `ℤ`, making later extensions easier.

### Strategy C — Square-root descent via parity and exact squares
Use for Theorem 2 only.

1. Prove parity lemmas: if `Even (tropicalVal p a)` and `Even (tropicalVal p μ)`, then
   \[
   3v_p(a)-v_p(\mu)
   \]
   is even.
2. Define the half-valuation as integer division by 2 and prove exactness.
3. If exact square roots `α^2 = a`, `β^2 = μ` are available, transport valuation identities through them.

**Why secondary:** It is more delicate and depends on how much square-root infrastructure is practical in Lean over `ℚ`.

---

## Required Deep Proof Tactics

At least 3 theorems must use genuinely nontrivial proof structure. Concretely:

- Use `rcases` to unpack parity assumptions and existential witnesses.
- Use `calc` chains to move from `orbitalPeriodSquared` to valuation formulas.
- Use `field_simp` when normalizing rational expressions such as `a^3 / μ`.
- Use `by_contra` at least once, e.g. to show a denominator or scaled parameter cannot vanish under assumptions.
- Use induction if you generalize from exponent `3` to arbitrary natural exponents:
  ```lean
  theorem tropicalVal_orbitalPower
      {p : ℕ} (hp : Nat.Prime p) {a μ : ℚ} (n : ℕ)
      (ha : a ≠ 0) (hμ : μ ≠ 0) :
      tropicalVal p (a^n / μ)
        = (n : ℤ) * tropicalVal p a - tropicalVal p μ
  ```
  Then recover the cubic law as `n = 3`.

Do not let the file collapse into one-line simp proofs.

---

## Cross-Domain Connections to Make Explicit

You are required to state and exploit at least one connection beyond number theory.

### 1. Number Theory ↔ Celestial Mechanics
Kepler’s third law becomes an arithmetic conservation law:
\[
\Theta = a^3/\mu
\]
has valuation determined by orbital parameters.

### 2. P-adic Analysis ↔ Tropical Geometry
Valuation converts multiplicative orbital data into additive depth data. The tropical orbit is not merely a visualization; it is a **lossless arithmetic compression** for the period invariant.

### 3. Mathematical Physics ↔ Min-plus Algebra
The quantity
\[
Q_p(a,\mu)=3v_p(a)-v_p(\mu)
\]
behaves like an additive charge under multiplicative composition. This is a tropical/Hamiltonian shadow of scaling symmetries.

### 4. Arithmetic Dynamics ↔ Computational Experiment
Your conjecture testing over primes \(p<1000\) and bounded rational parameters is not a toy exercise. It probes whether orbital arithmetic invariants exhibit hidden congruence patterns or exceptional prime behavior.

---

## Computational/Algorithmic Deliverable

You must produce a verified computational method, not just theorem statements.

### Required algorithm
Implement a procedure that, for prime `p` and rationals `a, μ`, computes:

1. `tropicalVal p a`
2. `tropicalVal p μ`
3. `orbitalPeriodSquared a μ = a^3 / μ`
4. `tropicalVal p (orbitalPeriodSquared a μ)`
5. `3 * tropicalVal p a - tropicalVal p μ`

and certifies equality when assumptions hold.

If feasible, add parity detection and report whether the half-valuation formula is admissible.

### Demo requirements
`demo.py` should:

- enumerate primes \(p<1000\),
- enumerate rational pairs \(a=m/n\), \(\mu=r/s\) with \(1 \le m,n,r,s \le 100\),
- verify the cubic valuation law,
- filter cases with even valuations,
- test the half-valuation prediction,
- display interesting extremal cases and any failures to assumptions.

---

## Falsifiable Conjectures for FUTURE_DIRECTIONS.md

You must include 3–5 hypotheses, each with a concrete disproof test. At least one should be computationally attacked now. Here are strong candidates:

### Conjecture A — Prime-uniform orbital depth law
For every prime \(p\) and all nonzero \(a,\mu \in \mathbb Q\),
\[
v_p(a^3/\mu)=3v_p(a)-v_p(\mu).
\]
**Test:** exhaustive search over bounded rationals and primes; a single counterexample disproves it.

### Conjecture B — Square-root admissibility criterion
If \(v_p(a)\) and \(v_p(\mu)\) are even, then the orbital half-valuation is always integral and matches the valuation of any p-adically defined square-root period normalization.
**Test:** for bounded rational squares and p-adically admissible examples, compare the computed half-valuation against explicit square-root constructions.

### Conjecture C — Tropical sufficiency
The valuation of the rationalized period is completely determined by the tropical vertex depth profile, with no additional arithmetic data required.
**Test:** search for two orbital parameter pairs with identical depth profiles but different period valuations.

### Conjecture D — Composite-orbit additivity
For independent orbital data,
\[
Q_p(a_1a_2,\mu_1\mu_2)=Q_p(a_1,\mu_1)+Q_p(a_2,\mu_2)
\]
extends to a monoidal tropical mechanics formalism.
**Test:** brute-force verify over bounded rational tuples.

### Conjecture E — Exceptional-prime rigidity
If \(Q_p(a,\mu)=0\) for infinitely many primes \(p\), then \(a^3/\mu = \pm 1\).
**Test:** search for rational pairs with many vanishing valuation charges but \(a^3/\mu \neq \pm 1\).

This last one is especially exciting: it points toward a local-global principle for orbital arithmetic invariants.

---

## Lean File Expectations

Your Lean development should include:

- one new structure or concept (`OrbitalDepthProfile`, `keplerValuationCharge`, or equivalent),
- at least 3 substantial theorems,
- at least one theorem using `rcases`,
- at least one theorem using `field_simp`,
- at least one theorem using multi-step `calc`,
- no trivialization by mere computation.

A strong file would have this narrative:

1. Define orbital arithmetic invariants.
2. Prove the cubic valuation law.
3. Prove scaling covariance and additive charge behavior.
4. Prove tropical depth recovery.
5. Prove parity/half-valuation results in the admissible regime.
6. Export computational checks.

---

## Suggested Theorem List

A compelling minimal set is:

1. `tropicalVal_orbitalPeriodSquared`
2. `periodDepthInvariant_correct`
3. `keplerValuationCharge_mul`
4. `tropicalVal_orbitalPeriodSquared_scale_a`
5. `orbitalHalfValuation_spec`

If time permits, generalize exponent `3` to arbitrary `n`.

---

## Revolutionary Significance

If you succeed, you will have formalized the first credible instance of an **arithmetic orbital invariant** extracted from tropical data. This opens a field, not just a lemma chain:

- **Arithmetic celestial mechanics:** classify orbits by local valuation signatures.
- **Tropical dynamics:** recover physically meaningful invariants from combinatorial depth.
- **Non-Archimedean physics:** reinterpret scaling laws as valuation charges.
- **Algorithmic discovery:** search for exceptional-prime behavior and local-global principles in orbital systems.

The real prize is not the formula itself. It is the emergence of a new doctrine:

> classical dynamical laws admit tropical-arithmetic shadows that are computable, compositional, and experimentally testable.

That doctrine can propagate far beyond Kepler—to Hamiltonian systems, resonance phenomena, and arithmetic invariants of integrable mechanics.

---

## Mandatory Deliverables

You must produce **all** of the following:

1. **A structured `FUTURE_DIRECTIONS.md`**
   - Include **3–5 falsifiable scientific hypotheses**
   - Each must have a clear computational or theoretical disproof test

2. **A standalone `RESEARCH_PAPER.md`**
   - Explain the definitions, main theorems, proof ideas, significance, and next questions
   - It must be readable without the codebase

3. **An `ARTICLE.md` in Scientific American style**
   - Engaging and accessible
   - Focus on the mathematics and scientific significance
   - **Do not focus on formal verification machinery**

4. **A verified algorithm or computational method**
   - Not just theorem statements
   - Must compute and certify the orbital valuation invariant

5. **A `demo.py`**
   - Interactive or exploratory
   - Must demonstrate the theorem on concrete examples and bounded searches

---

## Application Keywords

- p-adic valuation
- tropical geometry
- Kepler’s third law
- arithmetic dynamics
- celestial mechanics
- non-Archimedean analysis
- min-plus algebra
- valuation invariants
- tropicalized Hamiltonian systems
- local-global principles
- orbital scaling symmetry
- arithmetic physics

Be bold: do not merely show that valuations distribute over multiplication. Show that **orbital mechanics has an arithmetic tropical shadow**, and make that shadow computable, structural, and reusable.

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

Research domain: Pythagorean
Research mode: prove
