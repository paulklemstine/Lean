## Assignment: 3. Tropical One-Way Functions from Matrix Powering

**Mode:** prove

You should treat this as a foundational cryptography-from-tropical-algebra project, not a routine extension. The goal is to carve out a formally precise *complexity-theoretic interface* inside Lean 4 that can support future hardness, pseudorandomness, and orbit-hash security results. The breakthrough is not merely “another tropical theorem”; it is the creation of a mathematically clean reduction framework showing that tropical matrix powering behaves like a candidate one-way primitive in the min-plus world.

This is scientifically radical because tropical matrix powers encode bounded-length path structure, dynamic programming, semiring linear algebra, and discrete control all at once. If we can prove rigorous inversion barriers and security reductions, we open a tropical cryptography program parallel to classical hardness from exponentiation, lattice problems, and graph problems — but in an idempotent semiring geometry native to shortest paths, scheduling, and neural max-plus dynamics.

---

## Precise Theorem Targets

You should formalize theorems at three layers:

1. **Structural semantics of tropical powering**
2. **Reduction from path recovery / shortest-path-style inversion to powering inversion**
3. **PRG-style security transfer from inversion hardness to orbit-hash unpredictability**

The deepest point: in Lean, “one-wayness” itself may be too complexity-heavy to fully certify immediately. So prove mathematically exact *reduction theorems* that isolate the complexity assumption into an abstract predicate. This is the right formalization architecture.

---

## Core Definitions to Introduce

Work over tropical matrices with min-plus multiplication. If the existing catalog already has a tropical matrix type, reuse it; otherwise define a lightweight finite matrix model over `ℝ∞`, `WithTop ℝ`, or whichever min-plus carrier is already available in Mathlib / the project.

You need:

- `tropMul` / tropical matrix multiplication
- `tropPow : Matrix (Fin n) (Fin n) α → ℕ → Matrix (Fin n) (Fin n) α`
- path semantics: `(tropPow G k) i j` is the minimum weight of a length-`k` walk from `i` to `j`
- inversion relation:
  - exact preimage recovery of `(G,k)` from `Y = tropPow G k`
  - or weaker witness extraction: recover some shortest-path / edge-structure information from `Y`

A good abstract interface is:

```lean
def TropMat (n : ℕ) := Matrix (Fin n) (Fin n) (WithTop ℤ)

def tropicalPow {n : ℕ} : TropMat n → ℕ → TropMat n
```

and an abstract inversion predicate:

```lean
def IsPowerImage {n : ℕ} (Y : TropMat n) : Prop :=
  ∃ (G : TropMat n) (k : ℕ), tropicalPow G k = Y

def PowerInverter {n : ℕ} := TropMat n → Option (TropMat n × ℕ)
```

Then define correctness of an inverter:

```lean
def InvertsPower {n : ℕ} (A : PowerInverter) : Prop :=
  ∀ Y, IsPowerImage Y →
    ∃ G k, A Y = some (G,k) ∧ tropicalPow G k = Y
```

For the reduction theorem, you can abstract “shortest path solver” similarly.

---

## Main Theorem 1: Tropical powering realizes exact bounded-length path semantics

This is the indispensable theorem. Without it, no hardness statement has semantic force.

### Statement
For any weighted directed graph encoded by a tropical adjacency matrix `G`, the `(i,j)` entry of `G^{⊗ k}` equals the minimum weight of any length-exactly-`k` walk from `i` to `j`.

### Lean 4 type signature sketch
```lean
theorem tropical_pow_entry_eq_min_weight_walks
  {n : ℕ} (G : TropMat n) :
  ∀ k : ℕ, ∀ i j : Fin n,
    (tropicalPow G k) i j =
      sInf {w | ∃ p : Fin (k+1) → Fin n,
        p 0 = i ∧ p ⟨k, Nat.lt_succ_self k⟩ = j ∧
        w = ∑ t : Fin k, edgeWeight G (p (Fin.castSucc t)) (p t.succ)} := by
```

You may need to adapt the indexing of paths to something easier in Lean, e.g. lists or vectors of intermediate vertices.

### Why this is a breakthrough
This theorem turns tropical powering from an algebraic operation into a certified dynamic-programming primitive. It is the semantic bridge needed for every later cryptographic reduction: inversion of powering becomes inversion of bounded path aggregation.

---

## Main Theorem 2: Any exact inverter for tropical powering yields a solver for edge-recovery / bounded shortest-path witness extraction

The user’s original statement “inverting tropical matrix powering is at least as hard as tropical shortest path” is too ambitious if phrased as a raw complexity theorem in Lean. Make it precise as a *uniform reduction theorem*: an exact inverter for `Y = G^{⊗k}` can be used to recover enough structure to solve a bounded-length path extraction problem.

### Suggested exact theorem
Fix `k = 2` first. Show that if one can invert `Y = G ⊗ G`, then one can solve a tropical factorization / midpoint recovery problem:

> Given `Y`, `i`, `j`, recover a vertex `m` such that  
> `Y i j = G i m + G m j` whenever such a minimizer is unique.

This is already highly nontrivial and mathematically crisp.

### Lean 4 type signature sketch
```lean
def UniqueMidpointWitness {n : ℕ} (G : TropMat n) (i j : Fin n) (m : Fin n) : Prop :=
  (tropicalPow G 2) i j = G i m + G m j ∧
  ∀ m' : Fin n, (tropicalPow G 2) i j = G i m' + G m' j → m' = m

theorem inverter_yields_midpoint_recovery
  {n : ℕ} (A : PowerInverter) :
  InvertsPower A →
  ∀ (G : TropMat n) (i j m : Fin n),
    UniqueMidpointWitness G i j m →
    ∃ G' k,
      A (tropicalPow G 2) = some (G', k) ∧
      k = 2 := by
```

That is still weak, so strengthen it to show transport of the witness through exact inversion:

```lean
theorem exact_inversion_recovers_unique_midpoints
  {n : ℕ} (A : PowerInverter) :
  InvertsPower A →
  ∀ (G : TropMat n) (i j m : Fin n),
    UniqueMidpointWitness G i j m →
    let Y := tropicalPow G 2
    ∃ G', A Y = some (G', 2) ∧ UniqueMidpointWitness G' i j m := by
```

If equality of preimages is too strong because factorization need not be unique, then define a canonical class of graphs, e.g. strictly separated edge weights or diagonal-normalized matrices, where uniqueness holds. Then prove:

```lean
theorem power_square_inversion_unique_on_separated_instances
  {n : ℕ} :
  ∀ G₁ G₂ : TropMat n,
    SeparatedInstance G₁ →
    tropicalPow G₁ 2 = tropicalPow G₂ 2 →
    G₁ = G₂ := by
```

This is actually a more powerful theorem: it gives injectivity on a natural subclass, making inversion mathematically meaningful.

### Why this is a breakthrough
This creates the first certified hardness skeleton: inversion of tropical powering is not a vague slogan but controls reconstruction of hidden geodesic structure in weighted graphs. It links cryptography to shortest paths, matrix factorization, and min-plus rigidity.

---

## Main Theorem 3: Security transfer theorem for orbit-hash / PRG-style construction under abstract one-wayness

Do **not** overclaim “cryptographically secure PRG” unless you formalize security via an abstract adversary-success predicate. The right theorem is a reduction theorem:

> If there exists a distinguisher for the orbit-hash output with advantage `ε`, then there exists an inverter for tropical powering with success bounded below by a function of `ε`.

This is exactly the kind of theorem Lean can support abstractly, even if machine-level polynomial time is postponed.

### Abstract theorem statement
Define:
- an orbit hash generator from iterated tropical powers
- a distinguisher advantage
- an inverter success predicate

Then prove a hybrid-style implication.

### Lean 4 type signature sketch
```lean
def OrbitHash {n : ℕ} := TropMat n → List ℕ → List (TropMat n)

def DistAdvantage {α : Type} (D : α → Bool) (X U : Finset α) : ℚ := ...

def InverterSuccess {n : ℕ} (A : PowerInverter) (S : Finset (TropMat n × ℕ)) : ℚ := ...

theorem distinguisher_implies_inverter
  {n : ℕ}
  (H : OrbitHash n)
  (D : List (TropMat n) → Bool) :
  ∀ ε > 0,
    DistinguishesWithAdvantage H D ε →
    ∃ A : PowerInverter,
      InverterSuccess A (powerImageSample n) ≥ ε / (sampleLength H) := by
```

You may need to formulate this with `ℝ` instead of `ℚ`, and with explicit finite sample spaces to avoid measure-theoretic overhead.

### How to connect to catalog theorems
Build explicitly on:

1. `birthday_bound_tropical_hash`  
   Use it to bound collision probability in hybrids. This gives the non-degenerate regime where orbit states are sufficiently separated for a reduction to be meaningful.

2. `tropical_security_from_norm_bound`  
   This sounds like a norm-based security transfer theorem. Use it as a black-box lemma to convert metric separation of orbit states into adversarial uncertainty bounds.

3. `tropical_hash_prime_power_amplification`  
   Use it as an amplification lemma: powering along prime exponents may create a sparse hybrid schedule with better distinguishability-to-inversion conversion.

Do not merely cite these. Architect the chain:
- path semantics of powers → orbit state structure
- collision/norm bounds from catalog → distinguishability control
- hybrid argument over exponent steps → inverter extraction

### Why this is a breakthrough
This would be one of the first formally verified cryptographic reduction frameworks in a tropical semiring setting. It opens a new direction: *idempotent cryptography*, where hardness comes from dynamic-programming aggregation rather than group inversion.

---

## Most Promising Intermediate Theorem

If the full reduction is too large for one cycle, the highest-value theorem is:

```lean
theorem tropical_square_injective_on_strictly_separated_graphs
  {n : ℕ} :
  ∀ G H : TropMat n,
    StrictlySeparated G →
    tropicalPow G 2 = tropicalPow H 2 →
    G = H := by
```

Here `StrictlySeparated G` should mean every candidate midpoint for every pair `(i,j)` has a unique minimizer gap. This theorem is powerful because:

- it converts inversion from impossible-by-nonuniqueness into a real reconstruction problem,
- it provides a clean restricted-domain one-way candidate,
- it makes future reductions to recovery exact rather than approximate.

This is likely more tractable and more original than trying to formalize polynomial-time hardness directly.

---

## Proof Strategy Architecture

### Strategy A: Dynamic-programming semantics → unique minimizer rigidity
**Most promising.**

1. Prove the path semantics theorem for tropical powers.
2. Introduce a “strict separation” condition ensuring each minimum in the min-plus convolution is unique.
3. Use uniqueness to show equality of squares forces equality of edge weights entrywise, hence injectivity on separated instances.

Why this is strongest: it is fully structural, formalizable in Lean without external complexity theory, and creates a mathematically clean one-way candidate domain.

---

### Strategy B: Reduction through tropical factorization
1. Formalize tropical square roots / factorization instances `Y = G ⊗ G`.
2. Show any exact inverter gives a solver for a midpoint factorization problem.
3. Show midpoint factorization subsumes bounded shortest-path witness extraction.

Why this matters: it ties one-wayness to a concrete reconstruction problem. It is more reduction-theoretic, but may require careful handling of non-uniqueness.

---

### Strategy C: Hybrid security transfer for orbit hash
1. Define orbit hash from iterated powers `G, G², G⁴, ...` or prime powers.
2. Use `birthday_bound_tropical_hash` and `tropical_security_from_norm_bound` to bound collision and closeness events.
3. Perform a standard hybrid argument: a distinguisher between real and ideal orbit outputs identifies a step where one power transition leaks structure, yielding an inverter.

Why this is visionary: it transforms algebraic powering hardness into pseudorandomness. But it depends on having a clean abstract security model and may be the most engineering-heavy.

---

## Cross-Domain Connections You Should Exploit

### 1. Graph algorithms and dynamic programming
Tropical powers are shortest-path operators for exact path length. This connects cryptographic hardness to:
- min-plus convolution,
- APSP-style phenomena,
- path reconstruction and hidden geodesics,
- weighted automata.

### 2. Complexity theory
Even if Lean does not formalize P/poly today, structure the theorem statements so they are *ready* for future complexity wrappers:
- exact inversion oracle,
- witness extraction oracle,
- distinguisher-to-inverter reductions,
- injective subclasses as candidate hard families.

### 3. Control theory and max-plus systems
Tropical powers describe discrete event systems and reachability costs. A one-way primitive here would connect cryptography to control and scheduling: recovering the generator from long-horizon behavior.

### 4. Neural and attention-style tropical computation
`hard_attention_any_target` suggests the codebase already contains expressive tropical / hard-attention constructions. There may be a route where tropical matrix powering encodes iterative attention dynamics, making inversion akin to recovering latent transition structure from rollout summaries.

### 5. Algebraic geometry and idempotent analysis
`classical_add_not_idempotent` is a reminder that tropical algebra is not just a deformation of classical algebra; idempotence radically changes inversion. Make this conceptual point explicit: one-wayness here is not imported from groups but born from minimization geometry.

---

## Concrete Lean Targets

You should aim to produce at least one fully proved theorem of the following form, with minimal sorry:

```lean
theorem tropical_pow_two_entry
  {n : ℕ} (G : TropMat n) (i j : Fin n) :
  (tropicalPow G 2) i j = ⨅ m : Fin n, (G i m + G m j) := by
```

Then build:

```lean
theorem tropical_square_injective_on_strictly_separated_graphs
  {n : ℕ} :
  ∀ G H : TropMat n,
    StrictlySeparated G →
    tropicalPow G 2 = tropicalPow H 2 →
    G = H := by
```

And, if feasible:

```lean
theorem orbit_hash_distinguisher_yields_power_inverter
  {n : ℕ} :
  ∀ (D : List (TropMat n) → Bool),
    HasNontrivialOrbitHashAdvantage D →
    ∃ A : PowerInverter, NontrivialInversionSuccess A := by
```

Even if the last theorem is abstract and parameterized, that is acceptable. The key is to make the reduction mathematically exact.

---

## How to Use Existing Verified Theorems

- **`tropical_hash_prime_power_amplification`**  
  Use this to justify an orbit-hash schedule based on prime or sparse exponents. It can amplify distinguishability gaps or separation between trajectories.

- **`birthday_bound_tropical_hash`**  
  Use this to control collisions among orbit outputs. In a hybrid proof, collision control is the barrier to turning distinguishers into structural information.

- **`tropical_security_from_norm_bound`**  
  Use this as the bridge from metric separation of tropical states to adversarial advantage bounds. This may let you avoid reproving generic security lemmas.

- **`hard_attention_any_target`**  
  Consider whether tropical matrix products can encode target-selective routing. This could give a surprising reduction from recovering powering structure to recovering attention paths.

- **`classical_add_not_idempotent`**  
  Use conceptually, not technically, to emphasize that idempotent semiring cryptography is a genuinely different universe.

---

## What Would Count as a Landmark Result

A result counts as field-opening if you prove one of these:

1. **Injective-domain theorem:** tropical powering is injective on a natural separated family;
2. **Witness-recovery reduction:** exact inversion of tropical powers yields shortest-path witness extraction;
3. **Security transfer theorem:** any orbit-hash distinguisher induces a tropical power inverter.

Any one of these, done cleanly in Lean, would establish the first real infrastructure for tropical one-way functions.

---

## Application Keywords

tropical cryptography; one-way functions; min-plus algebra; tropical matrix powering; shortest paths; dynamic programming hardness; tropical factorization; pseudorandom generators; orbit hash; hybrid argument; idempotent semirings; weighted automata; control theory; graph reconstruction; formal cryptographic reductions

---

## Deliverables

1. Implement the core tropical matrix power semantics.
2. Prove at least one nontrivial structural theorem with no sorry or minimal sorry.
3. If full cryptographic reduction is too large, prioritize the injective-domain theorem.
4. Explicitly document all assumptions defining the “hard instance family.”
5. Produce `FUTURE_DIRECTIONS.md` with **3–5 concrete breakthrough next steps**, for example:
   - average-case hardness for random separated tropical graphs,
   - tropical trapdoor families,
   - min-plus PRG constructions from orbit iteration,
   - reductions from tropical factorization to control-system identification,
   - formal complexity classes for semiring computation in Lean.

Be bold: the true objective is to found a new branch of formally verified cryptography where hardness emerges from tropical geometry and dynamic programming rather than classical algebraic inversion.

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
