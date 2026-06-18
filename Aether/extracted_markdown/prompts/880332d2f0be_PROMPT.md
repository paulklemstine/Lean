## Assignment: Direction 4: Core-Collapse Acceleration Hypothesis

**Mode:** prove

Prove genuinely new, non-trivial theorems that turn the current qualitative common-core collapse principle into a quantitative information-theoretic law. The target is not merely to restate `semanticGraph_complete_of_common_core`, but to expose a mechanism: **low feature entropy forces metric concentration, and metric concentration forces early complete-graph collapse**.

This direction is promising because it creates a new bridge between:
- proof-theoretic topology,
- information theory,
- concentration of measure,
- random graph thresholds,
- and statistical learning notions of diversity/compressibility.

If successful, this would elevate the semantic graph program from a structural observation (“shared cores cause collapse”) to a predictive theory with measurable invariants. That is the difference between a descriptive framework and a science.

---

## Core Vision

The existing catalog theorems suggest the following causal chain:

1. A family of statements sharing a large common core has small pairwise semantic distance.
2. Small pairwise semantic distance implies that the semantic graph becomes complete at small threshold.
3. Low entropy in feature usage should imply the existence of a large modal/core feature set.
4. Therefore low entropy should accelerate collapse.

Your task is to formalize a mathematically precise version of this chain, with explicit constants and verifiable bounds.

The crucial move is to **replace vague entropy heuristics by a finite combinatorial inequality**: if most feature mass is concentrated on a small subset, then all (or most) statements lie within bounded symmetric-difference radius of a canonical core. Once that radius is controlled, the catalog theorems should force completeness.

---

## Required New Definitions

You must introduce at least one genuinely new concept not already present in the catalog. Recommended definitions:

### 1. Feature entropy of a finite family
For a finite family `S : Finset (Finset β)` of feature sets, define empirical feature frequency
\[
p_S(f) := \frac{|\{s \in S : f \in s\}|}{|S|}.
\]
Then define entropy
\[
H(S) := \sum_{f \in U(S)} h(p_S(f)), \qquad h(p) := -p \log p - (1-p)\log(1-p),
\]
or, if real logs are too analytically heavy for the first pass, define a **collision entropy surrogate**
\[
H_2(S) := \sum_{f \in U(S)} p_S(f)(1-p_S(f)).
\]
This surrogate is especially promising because it is polynomial/algebraic and naturally controls average disagreement.

### 2. Core radius
For a chosen core `c : Finset β`, define
\[
\operatorname{coreRadius}(S,c) := \sup_{s \in S} d_{\triangle}(s,c),
\]
where `d_△` is symmetric-difference cardinality or the catalog’s semantic distance analogue.

### 3. Mean pairwise disagreement
Define
\[
\operatorname{avgPairDist}(S) := \frac{1}{|S|^2}\sum_{s,t \in S} d_{\triangle}(s,t).
\]
This is the natural bridge quantity between entropy and graph thresholds.

These definitions are not cosmetic. They are the backbone of the program: entropy should control average disagreement; average disagreement should control a radius/core; radius should control collapse.

---

## Precise Theorem Targets

You should prove at least **3 substantial theorems**. The following are the right targets.

### Theorem 1: Entropy/disagreement identity or inequality
For finite families of finite feature sets, prove that the average pairwise symmetric-difference count is exactly or bounded by a simple function of the empirical frequencies.

A very strong target is:
\[
\sum_{s,t \in S} |s \triangle t|
=
2 |S|^2 \sum_{f \in U(S)} p_S(f)(1-p_S(f)).
\]

This is the finite-feature analogue of variance decomposition, and it is the cleanest formal bridge from information/diversity to semantic geometry.

#### Lean 4 target signature (suggested)
```lean
theorem sum_symmDiff_card_eq_two_mul_card_sq_mul_collisionEntropy
  {β : Type*} [DecidableEq β]
  (S : Finset (Finset β)) :
  ∑ x in S, ∑ y in S, ((x \ y).card + (y \ x).card)
    = 2 * S.card^2 * collisionEntropyNumerator S
```

Here `collisionEntropyNumerator S` should be a natural/rational-valued version such as
```lean
def collisionEntropyNumerator (S : Finset (Finset β)) : ℕ := ...
```
or a `ℚ`/`ℝ` quantity if you prefer. A normalized version is also acceptable.

#### Why this is a breakthrough
This theorem converts an information statistic into a graph-geometric observable. It means semantic collapse can be predicted from feature marginals alone, without inspecting all pairwise distances. That opens the door to scalable threshold prediction.

---

### Theorem 2: Low collision entropy implies existence of a concentrated core
Prove that if the disagreement surrogate is small, then there exists a statement-independent core around which every statement lies in bounded radius, or at minimum that **most** statements lie near such a core.

A realistic theorem:
\[
\operatorname{avgPairDist}(S) \le 2R \quad \Longrightarrow \quad \exists c,\ \forall s \in S,\ d_\triangle(s,c)\le R'
\]
for an explicit `R'` under an additional hypothesis such as coordinatewise majority stability.

A more robust theorem, easier and still deep:
\[
\exists c,\ \frac{1}{|S|}\sum_{s\in S} d_\triangle(s,c)
\le
\sum_f \min\{p_f,1-p_f\}.
\]
The natural choice of `c` is the majority core:
\[
f \in c \iff p_f \ge \tfrac12.
\]

#### Lean 4 target signature (suggested)
```lean
def majorityCore {β : Type*} [DecidableEq β] (S : Finset (Finset β)) : Finset β := ...

theorem avg_dist_to_majorityCore_le_sum_minorityMass
  {β : Type*} [DecidableEq β]
  (S : Finset (Finset β)) :
  ∑ s in S, symmDiffCard s (majorityCore S)
    ≤ S.card * minorityMassNumerator S
```

A stronger pointwise theorem may require an extra hypothesis:

```lean
def pointwiseStableAtRadius
  {β : Type*} [DecidableEq β] (S : Finset (Finset β)) (R : ℕ) : Prop := ...

theorem low_entropy_and_stability_imply_core_radius_bound
  {β : Type*} [DecidableEq β]
  (S : Finset (Finset β)) {R : ℕ}
  (hH : collisionEntropyNumerator S ≤ K)
  (hstab : pointwiseStableAtRadius S R) :
  coreRadius S (majorityCore S) ≤ R + K
```

#### Why this matters
This theorem extracts a canonical “latent theorem schema” from feature statistics. It is a semantic analogue of a centroid/majority vote in coding theory and learning theory.

---

### Theorem 3: Quantitative complete-graph collapse from entropy
Use the catalog results
- `semanticGraph_complete_of_common_core`
- `semanticDist_le_twice_of_common_core`

to derive an explicit complete-threshold bound in terms of entropy surrogate or minority mass.

A strong target:
\[
\varepsilon_{\mathrm{complete}}(S) \le 2\,\operatorname{coreRadius}(S,\operatorname{majorityCore}(S)),
\]
and hence, via Theorem 2,
\[
\varepsilon_{\mathrm{complete}}(S) \le 2\,\Phi(H_2(S))
\]
for an explicit monotone function `Φ`.

#### Lean 4 target signature (suggested)
```lean
theorem complete_threshold_le_two_mul_coreRadius
  {α β : Type*} [DecidableEq α] [DecidableEq β]
  (S : Finset α) (F : α → Finset β) :
  semanticCompleteThreshold S F
    ≤ 2 * coreRadiusImage S F (majorityCore (S.image F))
```

and then the entropy consequence:

```lean
theorem complete_threshold_le_entropy_bound
  {α β : Type*} [DecidableEq α] [DecidableEq β]
  (S : Finset α) (F : α → Finset β) :
  semanticCompleteThreshold S F
    ≤ 2 * entropyRadiusBound (S.image F)
```

You may need to define `semanticCompleteThreshold` if the catalog has only graph-completeness lemmas and not a named threshold object. That is acceptable and desirable.

#### Why this is the key theorem
This is the actual acceleration law. It says entropy is not merely correlated with collapse; it upper-bounds the collapse threshold through a mechanized theorem. That is the bridge from qualitative topology to predictive theory.

---

## Stronger Ambition: An Inverse or Contrapositive Theorem

If possible, go beyond the original conjecture and prove a contrapositive-style statement:

\[
\varepsilon_{\mathrm{complete}}(S) > \tau
\quad \Longrightarrow \quad
H_2(S) \ge c(\tau, |U(S)|).
\]

This would show that a wide mesoscopic window forces diversity. That is scientifically powerful because it turns observed topology into a diagnostic for latent semantic richness.

Suggested Lean target:
```lean
theorem large_complete_threshold_implies_collisionEntropy_lower_bound
  {α β : Type*} [DecidableEq α] [DecidableEq β]
  (S : Finset α) (F : α → Finset β) :
  τ < semanticCompleteThreshold S F →
  lowerEntropyBound τ (S.image F) ≤ collisionEntropy (S.image F)
```

---

## Proof Strategy Architecture

You must not rely on trivial automation. Use induction, `rcases`, `by_contra`, `field_simp`, and substantial `calc` chains.

### Strategy A: Coordinatewise counting identity -> majority core -> catalog collapse
**Most promising.**

1. Expand pairwise symmetric-difference cardinality as a sum over features:
   \[
   |s \triangle t| = \sum_f 1_{\{f \in s \triangle t\}}.
   \]
   Swap sums over pairs and features.

2. For each feature `f`, count ordered pairs `(s,t)` where membership differs. This count is
   \[
   2 n_f (N-n_f),
   \]
   where `n_f = |\{s : f \in s\}|`.
   This yields the exact disagreement identity.

3. Define the majority core coordinatewise. Show that the total distance to this core is exactly the sum of minority counts:
   \[
   \sum_{s} d_\triangle(s,c_{\mathrm{maj}})
   =
   \sum_f \min(n_f, N-n_f).
   \]

4. Convert this to a radius or average bound; then invoke
   `semanticDist_le_twice_of_common_core`
   and `semanticGraph_complete_of_common_core`.

**Why best:** It is fully finite, combinatorial, and avoids difficult real-analysis entropy formalization in the first pass. It should be Lean-friendly and produce exact formulas, not soft estimates.

---

### Strategy B: Jensen/concavity route with binary entropy
1. Formalize binary entropy `h(p)`.
2. Show `min(p,1-p) ≤ h(p)` and `p(1-p) ≤ h(p)` on `[0,1]`.
3. Use majority-core disagreement bounds controlled by `∑ min(p_f,1-p_f)`, then dominate this by `H(S)`.

**Why useful:** This yields the exact form of the original conjectural narrative involving Shannon entropy, not just the quadratic surrogate.

**Risk:** Real logarithms, concavity, and interval estimates may create Lean overhead. Use only if the combinatorial surrogate theorems are already secured.

---

### Strategy C: Probabilistic model / Dirichlet-generated families
1. Formalize an expected disagreement formula under independent Bernoulli or Dirichlet-mixed feature models.
2. Show expected complete threshold is bounded by expected collision entropy.
3. Derive a testable asymptotic slope law.

**Why interesting:** This connects directly to the computational experiment and universality claim.

**Risk:** Harder to complete formally unless probability infrastructure is already convenient. Best as a second-wave theorem or as the basis for `demo.py`.

---

## How to Build on Catalog Theorems

You must explicitly leverage:

### `semanticDist_le_twice_of_common_core`
Use this as the metric engine. Once you produce a core `c` with every statement within radius `r` of `c`, the catalog theorem should imply pairwise semantic distance at most `2r`. This is exactly the bridge from concentration to graph diameter.

### `semanticGraph_complete_of_common_core`
Use this as the threshold engine. After bounding all pairwise distances by `2r`, conclude that the semantic graph is complete at threshold `2r` (or whatever normalization the theorem uses).

Do not merely cite them. Engineer your new definitions so they feed directly into these results:
- `majorityCore` should instantiate the “common core” object.
- `coreRadius` should provide the radius parameter needed by the theorem.
- `collisionEntropyNumerator` or `minorityMassNumerator` should upper-bound `coreRadius`.

That composition is the heart of the paper.

---

## Cross-Domain Connections You Must Surface

At least one theorem must explicitly connect proof-theoretic topology to another domain.

### Recommended bridge theorem: coding theory / learning theory
Interpret each statement as a binary codeword over features. Then:
- pairwise semantic distance = Hamming distance,
- majority core = coordinatewise median/decoder,
- low entropy = low code dispersion.

A theorem phrased this way would connect theorem-family collapse to:
- error-correcting codes,
- VC-style diversity,
- prototype learning,
- rate-distortion heuristics.

Possible statement:
```lean
theorem semantic_distance_equals_hamming_distance_of_feature_encoding
  {β : Type*} [DecidableEq β]
  (s t : Finset β) :
  semanticDist s t = symmDiffCard s t
```
or an equivalent theorem in your framework.

### Additional bridges
- **Statistical mechanics:** low entropy families behave like low-temperature phases collapsing into a dominant macrostate.
- **Information geometry:** majority core acts as an `L¹` Fréchet mean on the hypercube.
- **Random graph theory:** collapse threshold is a deterministic analogue of connectivity threshold driven by latent coordinate concentration.

Include these explicitly in the mathematical narrative and in `RESEARCH_PAPER.md`.

---

## Refined Conjecture to State and Test

The original `C / H(S)` law may be too optimistic or dimensionally unstable. You should sharpen it into a falsifiable form that your theorems support.

### Recommended conjecture
For finite families `S` of feature sets with universe size `m`,
\[
\varepsilon_{\mathrm{complete}}(S)
\le
2 \sum_{f} \min(p_f,1-p_f)
\le
2 H(S),
\]
and under sparse-core concentration models,
\[
\varepsilon_{\mathrm{complete}}(S) \asymp H_2(S).
\]

This is better than `C/H(S)` because:
- it is monotone in the right direction,
- it vanishes as entropy vanishes,
- it matches the combinatorial counting identities,
- and it is directly testable.

### Falsifiable prediction
In Dirichlet-generated feature families with concentration parameter `η`,
\[
\mathbb E[\varepsilon_{\mathrm{complete}}] \approx k_m \,\mathbb E[H_2(S)],
\]
with `k_m` approaching a universal constant for moderate `m`.

**Disproof test:** simulate families for varying `η`; if the ratio
\[
\varepsilon_{\mathrm{complete}} / H_2(S)
\]
fails to stabilize across `m` and sample size, the universality claim is false.

---

## Lean 4 Formalization Targets

You should aim to create a file with new definitions and at least three deep theorems. Suggested file:

`Speculative/ProofTheoreticTopology/CoreCollapseEntropy.lean`

Suggested definitions:
```lean
def symmDiffCard {β : Type*} [DecidableEq β] (s t : Finset β) : ℕ :=
  (s \ t).card + (t \ s).card

def featureSupport {β : Type*} [DecidableEq β] (S : Finset (Finset β)) : Finset β := ...

def featureCount {β : Type*} [DecidableEq β] (S : Finset (Finset β)) (f : β) : ℕ := ...

def minorityCount {β : Type*} [DecidableEq β] (S : Finset (Finset β)) (f : β) : ℕ := ...

def collisionEntropyNumerator {β : Type*} [DecidableEq β] (S : Finset (Finset β)) : ℕ := ...

def majorityCore {β : Type*} [DecidableEq β] (S : Finset (Finset β)) : Finset β := ...

def coreRadius {β : Type*} [DecidableEq β] (S : Finset (Finset β)) (c : Finset β) : ℕ := ...
```

Suggested theorem signatures:
```lean
theorem symmDiffCard_comm
  {β : Type*} [DecidableEq β] (s t : Finset β) :
  symmDiffCard s t = symmDiffCard t s := by
  ...

theorem sum_symmDiffCard_eq_feature_disagreement
  {β : Type*} [DecidableEq β]
  (S : Finset (Finset β)) :
  ∑ s in S, ∑ t in S, symmDiffCard s t
    = 2 * ∑ f in featureSupport S, featureCount S f * (S.card - featureCount S f) := by
  ...

theorem sum_dist_to_majorityCore_eq_sum_minorityCount
  {β : Type*} [DecidableEq β]
  (S : Finset (Finset β)) :
  ∑ s in S, symmDiffCard s (majorityCore S)
    = ∑ f in featureSupport S, minorityCount S f := by
  ...

theorem complete_threshold_le_two_mul_majority_radius
  {α β : Type*} [DecidableEq α] [DecidableEq β]
  (S : Finset α) (F : α → Finset β) :
  semanticCompleteThreshold S F ≤ 2 * coreRadius (S.image F) (majorityCore (S.image F)) := by
  ...
```

If threshold objects are awkward, prove the graph-completeness statement directly:
```lean
theorem semanticGraph_complete_at_two_mul_majority_radius
  {α β : Type*} [DecidableEq α] [DecidableEq β]
  (S : Finset α) (F : α → Finset β) :
  semanticGraph S F (2 * coreRadius (S.image F) (majorityCore (S.image F))).toNat
    = completeGraph S := by
  ...
```

---

## Proof Tactics Expectations

Your theorems must involve real proof architecture, not brute force:
- use `Finset.induction` on families or feature supports,
- use `rcases` to unpack membership cases,
- use `by_contra` for minimality/majority arguments,
- use `field_simp` if you normalize counts into `ℚ` or `ℝ`,
- use `calc` blocks to reorganize double sums and counting identities.

Especially for the disagreement identity, the proof should proceed by decomposing on each feature and counting disagreement pairs. This is exactly the kind of proof that demonstrates mathematical substance.

---

## Revolutionary Significance

If you succeed, this direction opens an entirely new field: **information-theoretic proof topology**.

It would enable:
- predicting topological phase transitions of theorem families from lexical/feature statistics,
- identifying “compressed” mathematical subfields that collapse too quickly to sustain mesoscopic structure,
- designing synthetic theorem corpora with prescribed topological windows,
- importing methods from coding theory and rate-distortion theory into semantic graph analysis,
- and eventually defining entropy-controlled invariants of formal mathematical ecosystems.

This is not an incremental extension. It is a blueprint for a predictive theory of when mathematical meaning becomes topologically trivial.

---

## Mandatory Deliverables

You must produce **all** of the following:

1. **Lean file(s)** with the new definitions and at least 3 substantial theorems, minimizing sorrys.
2. **`FUTURE_DIRECTIONS.md`** with 3–5 testable scientific hypotheses. Each must be falsifiable and include a concrete computational or formal test.
3. **`RESEARCH_PAPER.md`** as a standalone scientific document explaining the theorem, proof architecture, significance, and next questions. A reader without the code must still understand the discovery.
4. **`ARTICLE.md`** in Scientific American style, accessible and vivid, explaining why entropy predicts collapse.
5. **A verified algorithm or computational method** for estimating the majority core, disagreement surrogate, and predicted complete threshold from a family of feature sets.
6. **`demo.py`** that interactively:
   - generates synthetic families from controllable feature distributions,
   - computes entropy surrogate and collapse threshold,
   - plots threshold versus entropy/diversity,
   - and tests the conjectured scaling law.

---

## Application Keywords

proof-theoretic topology, information theory, binary entropy, collision entropy, Hamming geometry, semantic graphs, complete-graph threshold, concentration of measure, coding theory, majority decoding, Fréchet median, random graph phase transition, theorem-family diversity, statistical learning theory, rate-distortion heuristics, low-temperature phase collapse

---

## Final Charge

Do not settle for the weak statement “shared cores imply collapse.” Prove that **diversity itself is the control parameter**. Build the finite combinatorial skeleton first; then, if time permits, lift it to genuine Shannon entropy. The right result here is a theorem that lets one look at a theorem family’s feature histogram and *predict* when its semantic topology dies. That would be a real discovery.

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
