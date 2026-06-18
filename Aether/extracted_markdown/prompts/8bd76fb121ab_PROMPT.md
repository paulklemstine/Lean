## Assignment: Direction 2: Nondeterministic Branching Program Lower Bounds via Tropical Certificates

**Mode:** prove

Prove a genuinely new lower-bound theorem that forges a structural bridge between tropical min-plus complexity and nondeterministic computation models. The goal is not to define yet another certificate parameter, but to show that a tropical notion of informational cost forces exponential-size lower bounds for nondeterministic branching programs.

### Core Breakthrough Target

The central theorem should be formulated at two levels: a formally tractable Lean theorem for a finite Boolean setting, and a stronger mathematical theorem stated in research language.

#### Mathematical theorem statement
Let `n : ℕ`, let `f : (Fin n → Bool) → Bool`, and let `w : Fin n → ℕ` be a coordinate cost function. Define the **tropical certificate cost** of an input `x` to be the minimum, over all partial assignments `σ` consistent with `x` that force the value of `f`, of the tropical weight
\[
\operatorname{tcost}_w(\sigma)=\sum_{i \in \operatorname{dom}(\sigma)} w(i),
\]
viewed as additive cost in the min-plus semiring. Define
\[
\operatorname{TropCert}(f,w):=\min_{x} \operatorname{tcost}_w(x)
\]
for one-sided acceptance certificates, or more powerfully
\[
\operatorname{TropCert}^{\forall}(f,w):=\inf_x \operatorname{tcost}_w(x)
\]
depending on the exact formalization.

Then prove a theorem of the following shape:

> **Target Theorem.** There exists a universal constant `C > 0` such that for every Boolean function `f` and weight function `w`, if every accepting tropical certificate for `f` has cost at least `L`, then every nondeterministic branching program computing `f` has at least `2^(L / C)` nodes.

A sharper and more Lean-realistic variant is:

> **Layered / read-once variant.** For every `n`, every finite acyclic nondeterministic branching program `B` over variables `Fin n`, if `B` computes `f` and all accepting tropical certificates of `f` have weighted cost at least `L`, then
\[
\log_2(\mathrm{size}(B)) \ge L/C,
\]
equivalently
\[
\mathrm{size}(B) \ge 2^{L/C}.
\]

If the full theorem is too ambitious at first pass, prove one of the following breakthrough footholds:

1. **Read-once NBP lower bound** with `C = max_i w(i)` or a related explicit constant.
2. **Syntactic NBP lower bound** for programs where each source-to-sink path induces a consistent partial assignment.
3. **Rectangular / path-cover theorem**: every accepting path yields a tropical certificate, and the set of all accepting paths must form a cover whose cardinality is at least exponential in tropical certificate complexity.

This is already field-opening if done cleanly.

---

## Precise Lean 4 Formalization Target

You should define finite Boolean functions and a finite branching-program model in Lean 4, then prove an explicit theorem. A plausible type-signature target is:

```lean
def BoolFun (n : ℕ) := (Fin n → Bool) → Bool

structure PartialAssign (n : ℕ) where
  dom : Finset (Fin n)
  val : Fin n → Bool
  coherent : ∀ i, i ∉ dom → val i = false  -- or replace by Option-valued map

def agrees {n : ℕ} (σ : PartialAssign n) (x : Fin n → Bool) : Prop :=
  ∀ i ∈ σ.dom, x i = σ.val i

def forces {n : ℕ} (f : BoolFun n) (σ : PartialAssign n) (b : Bool) : Prop :=
  ∀ x, agrees σ x → f x = b

def tropicalCost {n : ℕ} (w : Fin n → ℕ) (σ : PartialAssign n) : ℕ :=
  ∑ i in σ.dom, w i

def isAcceptingCertificate {n : ℕ} (f : BoolFun n) (w : Fin n → ℕ) (L : ℕ) : Prop :=
  ∀ σ, forces f σ true → L ≤ tropicalCost w σ

structure NBP (n : ℕ) where
  State : Type
  [fintype_State : Fintype State]
  start accept : State
  step : State → List (Option (Fin n × Bool) × State)
  acyclic : Prop
  -- add semantic well-formedness predicates as needed

def NBP.size {n : ℕ} (B : NBP n) : ℕ := Fintype.card B.State

def Computes {n : ℕ} (B : NBP n) (f : BoolFun n) : Prop := ...

theorem nbp_size_lower_bound_of_tropical_certificate
  {n : ℕ} (f : BoolFun n) (w : Fin n → ℕ) (L C : ℕ) (B : NBP n)
  (hC : 0 < C)
  (hcomp : Computes B f)
  (hcert : isAcceptingCertificate f w L)
  (hpath : ∀ p, AcceptingPath B p → tropicalCost w (pathCertificate p) ≤ C * Nat.log2 (NBP.size B + 1)) :
  2 ^ (L / C) ≤ B.size := by
  ...
```

This statement is deliberately architected so that the hard combinatorial lemma is isolated in hypothesis `hpath` first. Then you can aim to discharge `hpath` for specific NBP classes in a second theorem.

A second, more conceptual theorem should target:

```lean
theorem readOnce_nbp_size_lower_bound_of_tropical_certificate
  {n : ℕ} (f : BoolFun n) (w : Fin n → ℕ) (L : ℕ) (B : ReadOnceNBP n)
  (hcomp : Computes B.toNBP f)
  (hcert : isAcceptingCertificate f w L)
  (hw : ∀ i, 1 ≤ w i) :
  2 ^ (L / B.branchCostBound) ≤ B.size := by
  ...
```

Even if `branchCostBound` is initially a crude constant extracted from path structure, this is a nontrivial theorem.

---

## Definitions You Must Get Right

The theorem lives or dies on exact definitions. Be extremely careful here.

### 1. Tropical certificate
A tropical certificate should not just be “a set of queried variables.” It should be a **partial assignment** whose consistency class is monochromatic for `f`. The tropical cost is the min-plus analogue of query complexity:
- min over certificates,
- plus over queried coordinates.

This is not ornamental semiring language: it is the mechanism by which combinatorial information cost becomes additive along a path and minimizable over witnesses.

### 2. Nondeterministic branching program semantics
A nondeterministic branching program accepts input `x` iff there exists a start-to-accept path whose edge labels are all consistent with `x`. This existential path semantics is exactly what aligns with one-sided certificates.

### 3. Path certificate extraction
For each accepting path `p`, extract the partial assignment consisting of all variable tests encountered along `p`, provided the path is consistent. Then prove:
- the extracted assignment is a valid accepting certificate for `f`,
- its tropical cost is bounded in terms of structural complexity of the path/program.

This is the fulcrum.

---

## Proof Architecture: 3 Strategic Routes

### Strategy A: Path-to-certificate extraction + counting
This is the most promising first route.

**Step 1.** Formalize accepting paths and extract from each path a partial assignment `σ_p`.  
Show that if the branching program computes `f`, then every accepting path induces `forces f σ_p true`.

**Step 2.** Bound certificate cost by path complexity.  
In a read-once or syntactic setting, each queried variable appears at most once per path, so
\[
\operatorname{tropicalCost}(σ_p) \le \sum_{i \text{ queried on } p} w(i).
\]
Then show this is at most `C * log₂(size B)` or at most `C * pathLength`, depending on the exact structural lemma you can prove.

**Step 3.** Contrapositive lower bound.  
If all accepting certificates have cost at least `L`, then every accepting path must encode at least `L/C` bits of branching information. A DAG with `s` states supports only `O(log s)` independent branching depth per witness class unless it has at least `2^{L/C}` states. Conclude:
\[
size(B) \ge 2^{L/C}.
\]

**Why this is best:** It turns the theorem into a clean extraction argument with one combinatorial bottleneck, ideal for Lean. You can first prove the theorem for restricted branching programs and then generalize.

---

### Strategy B: Tropical communication rectangles hidden inside NBPs
This is more radical and potentially more revolutionary.

**Step 1.** Associate to each state `q` the set of inputs reaching `q` and the set of accepting continuations from `q`.  
This gives a decomposition of the accepted language into state-indexed “rectangular” pieces in a certificate-like lattice.

**Step 2.** Show each such piece has bounded tropical certificate complexity unless the state space is large.  
This is analogous to lower bounds via rectangle covers in communication complexity, but now in the min-plus world.

**Step 3.** Derive an exponential lower bound by proving that any cover of the accepting set by low-cost tropical pieces requires exponentially many pieces.

**Why this matters:** This would not merely prove an NBP lower bound; it would create a new tropical rectangle method, potentially exportable to communication complexity, proof complexity, and monotone computation.

---

### Strategy C: Entropy / information-cost interpretation of tropical certificates
This is the highest-risk, highest-upside route.

**Step 1.** Interpret `w(i)` as information price for revealing coordinate `i`.  
A certificate then has tropical cost equal to total revealed information.

**Step 2.** Show that any nondeterministic branching program of size `s` can only realize accepting witnesses of information content `O(log s)` per accepting branch class.

**Step 3.** Prove a coding inequality:
\[
\text{certificate cost} \le C \cdot \log_2 s
\]
for some universal `C`, hence `s ≥ 2^{L/C}`.

**Why this is revolutionary:** It reframes branching-program lower bounds as a tropical information theory statement. If successful, it opens a route toward semiring-based lower bounds for space complexity.

---

## How to Use Existing Verified Theorems

The current catalog is sparse, but do not ignore it. Use it as algebraic scaffolding and thematic legitimacy.

1. `tropical_plus_distributes_over_min`
   - Use this to normalize tropical-cost manipulations when comparing minimum certificate costs over unions/intersections of witness families.
   - If you define certificate complexity by minimization over partial assignments and then compose certificates along paths, this theorem can simplify the algebraic side of the min-plus structure.

2. `tropical_and_bound`
   - This looks especially useful if you first prove composition lemmas: combining two independent certificate obligations adds costs.
   - Build a lemma that if two subconditions both must hold along a path, tropical cost is bounded below by a suitable combination; this can support path decomposition.

3. `tropical_depth_lower_bound`
   - If this theorem gives a lower bound on tropical depth in terms of problem size, try to map branching-program path complexity to tropical depth.
   - A derived theorem of the form “NBP size controls tropical depth” could combine with `tropical_depth_lower_bound` to obtain lower bounds for explicit functions.

4. `tropical_mirror_theorem`
   - Likely minor directly, but useful for simplifying max/min idempotent expressions in semiring normalization lemmas.

5. `tropical_fundamental_theorem_of_arithmetic`
   - If it encodes factorization or additive decomposition phenomena in tropical arithmetic, mine it for uniqueness/decomposition arguments in certificate composition. This may be unexpectedly relevant if paths decompose into irreducible witness fragments.

Do not force these results superficially. Build one or two genuine bridge lemmas that make them naturally applicable.

---

## Concrete Intermediate Theorems to Formalize First

These are not busywork; they are the staircase to the breakthrough.

### Theorem 1: Path extraction gives certificates
```lean
theorem pathCertificate_forces_true
  {n : ℕ} {B : NBP n} {f : BoolFun n} {p : Path B}
  (hcomp : Computes B f)
  (hacc : AcceptingPath B p)
  (hcons : PathConsistent p) :
  forces f (pathCertificate p) true := by
  ...
```

### Theorem 2: Read-once path cost bound
```lean
theorem tropicalCost_pathCertificate_le_weightSum
  {n : ℕ} (w : Fin n → ℕ) {B : ReadOnceNBP n} {p : Path B}
  (hacc : AcceptingPath B.toNBP p) :
  tropicalCost w (pathCertificate p) ≤ ∑ i in queriedVars p, w i := by
  ...
```

### Theorem 3: Size controls witness complexity in a layered NBP
```lean
theorem layered_path_weight_le_log_size_bound
  {n : ℕ} (w : Fin n → ℕ) {B : LayeredNBP n}
  (hw : ∀ i, 1 ≤ w i) :
  ∀ p, AcceptingPath B.toNBP p →
    tropicalCost w (pathCertificate p) ≤
      B.widthBound * Nat.log2 (B.size + 1) := by
  ...
```

### Theorem 4: Main lower bound
```lean
theorem layered_nbp_size_lower_bound
  {n : ℕ} (f : BoolFun n) (w : Fin n → ℕ) (L : ℕ) {B : LayeredNBP n}
  (hcomp : Computes B.toNBP f)
  (hcert : isAcceptingCertificate f w L)
  (hw : ∀ i, 1 ≤ w i) :
  2 ^ (L / B.widthBound) ≤ B.size + 1 := by
  ...
```

Even proving Theorem 4 for a restricted but nontrivial NBP class would be a serious result.

---

## Critical Mathematical Insight

The key conceptual move is this:

A nondeterministic accepting computation is not just a path; it is a **compressed witness**.  
A tropical certificate is also a witness, but measured in additive min-plus cost.  
Therefore, if every valid witness has high tropical cost, then every accepting computation must carry high witness information. A small branching program cannot host too many such information-rich witness classes without state explosion.

This is the exact place where tropical algebra meets complexity lower bounds. Do not dilute it into generic certificate complexity. The tropical weighting is the novelty: it lets one tune hardness anisotropically across coordinates, which may eventually capture functions invisible to unweighted methods.

---

## Cross-Domain Connections You Should Explicitly Exploit

1. **Complexity theory / NSPACE**
   - Nondeterministic branching programs model bounded-space computation.
   - Lower bounds here point toward semiring-based methods for space lower bounds.

2. **Tropical geometry / min-plus algebra**
   - Certificates become tropical witnesses; minimization over witnesses is a min-plus optimization problem.
   - This suggests a geometry of accepting regions under tropical cost.

3. **Communication complexity**
   - State decompositions of branching programs resemble rectangle covers.
   - A tropical rectangle-cover method could be a new lower-bound technology.

4. **Information theory**
   - Weighted certificate cost behaves like information acquisition cost.
   - A future “tropical data processing inequality” for computation paths would be transformative.

5. **Proof complexity / knowledge compilation**
   - Branching programs, certificates, and compressed witnesses all live in the same ecosystem.
   - A successful theorem here could migrate to DNNF/OBDD lower bounds and certificate extraction in SAT.

6. **Semiring automata**
   - Branching programs can be viewed as automata over semiring-enriched transitions.
   - Tropical semantics may permit generalization to weighted automata and shortest-path witness models.

---

## High-Value Explicit Function Families

Do not stop at an abstract theorem. If the general theorem is hard, prove it for one explicit family with large tropical certificate complexity.

Promising candidates:
- **Pointer chasing**
- **Set disjointness-inspired finite functions**
- **Address functions with weighted coordinates**
- **Tribes / dual tribes under anisotropic weights**
- **Graph reachability encodings with high witness cost**

A theorem like
\[
\operatorname{TropCert}(f_n,w_n) \ge c n
\quad\Longrightarrow\quad
\mathrm{NBPSize}(f_n) \ge 2^{\Omega(n)}
\]
for an explicit family would already be a major advance.

---

## Lean Engineering Guidance

- Keep the first formal model finite and acyclic.
- Prefer `Fin n → Bool` over bitvectors initially.
- Represent partial assignments with `Finset` + value map, or `Fin → Option Bool`.
- Separate semantic theorems (`forces`, `agrees`) from combinatorial theorems (`pathCertificate`, `size`).
- Prove restricted-class theorems first: read-once, layered, or syntactic NBPs.
- Minimize sorry by modularizing the hard combinatorial lemma as its own target.

If a full universal constant `C` is not immediately accessible, prove a theorem with an explicit structural parameter:
- path width,
- max query repetition,
- layer width,
- variable occurrence multiplicity.

That is still a real theorem, not a placeholder.

---

## What Would Make This Revolutionary

If you succeed, you will have introduced a new lower-bound invariant — tropical certificate complexity — that interacts nontrivially with a central machine model for nondeterministic space. That would open an entire program:

- tropical lower bounds for branching programs,
- tropical communication coverings,
- semiring information complexity,
- anisotropic hardness measures for explicit functions,
- eventually, tropical methods for space complexity barriers.

This is the kind of theorem that creates a vocabulary, not just a lemma.

---

## Deliverables

1. Formal Lean definitions for:
   - partial assignments,
   - tropical certificate cost,
   - forcing semantics,
   - finite acyclic nondeterministic branching programs,
   - accepting paths and extracted certificates.

2. At least one fully formalized nontrivial lower-bound theorem, preferably for a restricted but meaningful NBP class.

3. Supporting lemmas connecting path structure to tropical certificate cost.

4. Explicit notes in comments indicating which assumptions are essential and which are artifacts of the first formalization.

5. A structured `FUTURE_DIRECTIONS.md` with **3–5 concrete breakthrough-level next steps**, for example:
   - extending from read-once to general acyclic NBPs,
   - tropical rectangle-cover lower bounds,
   - explicit hard function families with provable tropical certificate complexity,
   - tropical information inequalities for computational models,
   - transfer to OBDD / DNNF / proof-complexity lower bounds.

---

**Application keywords:** nondeterministic branching programs, tropical certificates, min-plus complexity, certificate complexity, space lower bounds, NSPACE, branching-program lower bounds, tropical information theory, semiring complexity, communication rectangles, weighted witnesses, proof complexity, knowledge compilation, OBDD lower bounds, tropical automata.

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

Research domain: Tropical
Research mode: prove
