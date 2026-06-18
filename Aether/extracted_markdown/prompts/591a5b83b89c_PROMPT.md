## Assignment: Reversible Computing and Thermodynamic Efficiency

Mode: **prove** + **formalize**

Prove genuinely new theorems that make the thermodynamics of computation mathematically rigid in Lean 4. Do not settle for folklore restatements. The target is a formal bridge between **logical reversibility**, **information loss**, **entropy production**, and **algorithmic complexity** that is strong enough to support optimality theorems for concrete reversible implementations.

Minimize sorry. If a theorem is too ambitious in one shot, isolate the exact reversible-combinatorial core and prove that first.

---

## Research Direction

Establish a theorem schema of the following form:

> **Logical irreversibility is exactly the source of Landauer dissipation**, and bijective finite-state computations saturate the zero-erasure case.  
> Moreover, among implementations of a fixed finite function, reversible embeddings with minimal garbage/ancilla realize the sharp entropy lower bound predicted by the catalog entropy-complexity bridge.

This should not remain philosophical. Formalize it over finite types and explicit maps.

You should aim to prove three layers:

1. **Zero-loss theorem for reversible maps**: bijections preserve Shannon entropy exactly, hence incur zero Landauer cost.
2. **Landauer lower bound from fiber multiplicity**: non-injective maps lose at least the entropy of the conditional ambiguity of inputs given outputs.
3. **Optimal reversible embedding theorem**: every finite computation can be implemented reversibly by adjoining ancilla/work bits, and the number of erased bits required by any implementation is bounded below by a precise combinatorial quantity (ideally logarithm of maximal fiber size, or entropy defect), with equality for a canonical construction on common examples.

This is a breakthrough direction because it would convert the slogan “information is physical” into a reusable Lean-certified theorem stack linking:
- finite combinatorics,
- entropy inequalities,
- reversible circuit synthesis,
- complexity lower bounds,
- and the existing catalog bridge theorems such as  
  `complexity_bound_implies_finite_entropy_bound` and `tropical_landauer_bound`.

---

## Precise Theorem Targets

Work over finite types with `Fintype` and probability mass functions `PMF` where possible. If PMF infrastructure becomes awkward, start with uniform distributions on finite fibers and then generalize.

### Target Theorem A: Entropy invariance under reversible computation

**Mathematical statement**

For finite types `α`, `β`, if `f : α → β` is bijective, then pushing a distribution `p` forward along `f` preserves entropy.

This is the formal thermodynamic statement that reversible computation has zero information-theoretic dissipation.

**Lean 4 target signature sketch**
```lean
theorem entropy_map_eq_of_bijective
  {α β : Type} [Fintype α] [Fintype β] [DecidableEq α] [DecidableEq β]
  (p : PMF α) (f : α → β) (hf : Function.Bijective f) :
  entropy (p.map f) = entropy p
```

If `PMF.map` requires measurability-like hypotheses or a different API, adapt to the exact Mathlib signature. If Shannon entropy is not already packaged for `PMF`, define a finite entropy functional:
```lean
noncomputable def finiteEntropy {α : Type} [Fintype α] [DecidableEq α] (p : PMF α) : ℝ := ...
```

**Why it matters**
This is the exact theorem saying: **reversible circuits saturate Landauer’s bound in the no-erasure regime**. It is the formal nucleus from which all stronger thermodynamic optimality statements grow.

---

### Target Theorem B: Entropy loss lower-bounds erasure cost for non-injective maps

**Mathematical statement**

For a finite map `f : α → β` and input distribution `p`, the entropy drop
\[
H(X) - H(f(X))
\]
is nonnegative, and equals zero iff `f` is injective on the support of `p`. This is the information lost by coarse-graining. Interpret this as the minimal heat-producing erasure cost up to the Landauer constant.

A weaker but still excellent first theorem is:
\[
H(f_* p) \le H(p).
\]

A stronger theorem is:
\[
H(p) - H(f_*p) = H(X \mid f(X)).
\]

**Lean 4 target signature sketch**
```lean
theorem entropy_map_le
  {α β : Type} [Fintype α] [Fintype β] [DecidableEq α] [DecidableEq β]
  (p : PMF α) (f : α → β) :
  entropy (p.map f) ≤ entropy p
```

Sharper equality criterion:
```lean
theorem entropy_map_eq_iff_injective_on_support
  {α β : Type} [Fintype α] [Fintype β] [DecidableEq α] [DecidableEq β]
  (p : PMF α) (f : α → β) :
  entropy (p.map f) = entropy p ↔
    Set.InjOn f {x | p x ≠ 0}
```

Landauer-form corollary:
```lean
theorem landauer_cost_lower_bound
  {α β : Type} [Fintype α] [Fintype β] [DecidableEq α] [DecidableEq β]
  (p : PMF α) (f : α → β) :
  0 ≤ entropy p - entropy (p.map f)
```

And if you define a thermodynamic cost functional:
```lean
noncomputable def landauerCost
  (T kB : ℝ) {α β : Type} [Fintype α] [Fintype β] [DecidableEq α] [DecidableEq β]
  (p : PMF α) (f : α → β) : ℝ :=
  kB * T * Real.log 2 * (entropy p - entropy (p.map f))
```
then prove:
```lean
theorem landauerCost_nonneg
  (T kB : ℝ) (hT : 0 ≤ T) (hkB : 0 ≤ kB)
  {α β : Type} [Fintype α] [Fintype β] [DecidableEq α] [DecidableEq β]
  (p : PMF α) (f : α → β) :
  0 ≤ landauerCost T kB p f
```

**Why it matters**
This is the theorem that turns Landauer’s principle into a finite certified inequality, suitable for composition with the catalog theorem `tropical_landauer_bound`.

---

### Target Theorem C: Reversible embedding of arbitrary finite computations

**Mathematical statement**

Every function `f : α → β` on finite types admits a reversible realization on an enlarged state space. The canonical model is:
\[
R_f(x,y) = (x, y \oplus \mathrm{enc}(f(x)))
\]
on a product with an auxiliary register, where `⊕` is an involutive group action such as XOR on bit-vectors or addition on a finite abelian group.

For a finite additive codomain, this map is bijective.

**Lean 4 target signature sketch**

Use a finite additive commutative group if bitvectors are inconvenient:
```lean
theorem reversible_lift_bijective
  {α β : Type}
  [Fintype α] [Fintype β]
  [DecidableEq α] [DecidableEq β]
  [AddCommGroup β]
  (f : α → β) :
  Function.Bijective (fun z : α × β => (z.1, z.2 + f z.1))
```

If finite additive groups are too abstract for the intended circuit reading, specialize to `Fin n → Bool` vectors or `Fin n → ZMod 2`.

Then prove that projection recovers the original computation:
```lean
theorem reversible_lift_realizes_f
  {α β : Type}
  [Fintype α] [Fintype β]
  [DecidableEq α] [DecidableEq β]
  [AddCommGroup β]
  (f : α → β) (x : α) :
  ((fun z : α × β => (z.1, z.2 + f z.1)) (x, 0)).2 = f x
```

**Why it matters**
This is the formal skeleton of Bennett-style reversible computation. It gives a certified reversible implementation paradigm for arbitrary finite algorithms.

---

### Target Theorem D: Optimality lower bound via fiber size / support compression

A strong theorem with major significance would be:

> For a finite function `f : α → β`, any implementation that computes `f` and then resets enough workspace to return to a standard state must erase at least `⌈log₂ M⌉` bits, where
> \[
> M = \max_{y \in β} |\{x : f(x)=y\}|.
> \]

This is a combinatorial Landauer theorem: many-to-one collapse forces irrecoverable information loss.

**Lean 4 target signature sketch**
```lean
noncomputable def maxFiberCard
  {α β : Type} [Fintype α] [Fintype β] [DecidableEq α] [DecidableEq β]
  (f : α → β) : Nat := ...

theorem erasure_bits_lower_bound_of_fiber
  {α β γ : Type}
  [Fintype α] [Fintype β] [Fintype γ]
  [DecidableEq α] [DecidableEq β] [DecidableEq γ]
  (f : α → β)
  (R : α × γ → α × γ) -- or a more refined implementation type
  (hR : Function.Bijective R)
  (hrealizes : ∀ x, ∃ g, R (x, default) = (g x, encode (f x))) :
  Nat.log2 (maxFiberCard f) ≤ erasedBitsOfImplementation R
```

You may need to replace this with a cleaner first version:
- define `maxFiberCard`,
- prove `maxFiberCard f = 1 ↔ Function.Injective f`,
- prove non-injective maps have positive combinatorial erasure burden,
- then formulate an implementation-level lower bound.

**Why it matters**
This would be a field-opening theorem: a precise lower bound on irreversible cost in terms of computational many-to-one structure, directly connectable to complexity and compression.

---

## Build Explicitly on Catalog Theorems

You are not starting from zero. Use the existing verified results as bridge components.

### 1. `complexity_bound_implies_finite_entropy_bound`
**Use**: once you define reversible implementations and a complexity measure for them, show that reversible realizability plus bounded description complexity yields finite entropy control on reachable state ensembles. This can turn combinatorial reversible constructions into entropy-certified thermodynamic statements.

### 2. `rational_affine_encodable_gives_entropy_bound`
**Use**: if you model reversible gates as affine transformations over finite vector spaces (`ZMod 2`, `Fin n → ZMod 2`), this theorem may provide a route from explicit encodability of circuit states to entropy bounds. This is especially promising for Toffoli/CNOT-like universality formalizations.

### 3. `compressor_gives_complexity_bound`
**Use**: connect garbage minimization in reversible circuits with compressibility. If a reversible implementation produces structured garbage, a compressor reduces its complexity, and the theorem can certify a corresponding complexity bound. This suggests a theorem of the form: “compressible garbage implies entropy slack below the worst-case Landauer lower bound.”

### 4. `tropical_and_bound`
**Use**: likely as a technical stepping stone in oracle/tropical complexity estimates if you model logical conjunction cost in a tropicalized thermodynamic semiring. Even if not central, it can provide a cross-domain bridge to decision procedures over reversible Boolean circuits.

### 5. `tropical_landauer_bound`
**Use**: this is the most provocative bridge. After proving classical finite entropy monotonicity under many-to-one maps, seek a theorem showing that your finite reversible/irreversible cost functional specializes to or implies a tropical lower bound in the catalog. That is the kind of unexpected synthesis that opens a new subfield: **tropical thermodynamics of computation**.

---

## Proof Strategy Architecture

### Strategy A: Finite entropy via convexity and partition refinement
Most promising for Theorems A and B.

1. Define entropy on finite `PMF` explicitly as
   \[
   H(p) = -\sum_x p(x)\log p(x)
   \]
   with the convention `0 log 0 = 0`.
2. For `entropy_map_le`, observe that `p.map f` groups probabilities by fibers of `f`. Entropy decreases under coarse-graining; prove this via concavity of `-x log x` or a finite log-sum inequality.
3. For bijective `f`, fibers are singletons, so the grouped sum is a permutation of the original sum; conclude equality.

Why promising: finite grouping/permutation arguments are very Lean-friendly, and avoid measure-theoretic overhead.

---

### Strategy B: Uniform-distribution first, then general PMF
Most promising for the reversible-implementation theorem.

1. Start with the uniform distribution on a finite type `α`. Then entropy is `log |α|`.
2. For a map `f : α → β`, show
   \[
   H(f_*u_\alpha) \le \log |α|,
   \]
   with strict drop when fibers are nontrivial.
3. Interpret reversible embeddings as cardinality-preserving bijections on enlarged spaces; derive zero entropy production before projection/erasure.

Why promising: cardinality arguments on `Fintype.card` and explicit bijections are much easier than full PMF entropy. This gives publishable core theorems quickly and supports later generalization.

---

### Strategy C: Algebraic reversible circuits over finite groups
Most promising for constructive implementations.

1. Model registers as finite abelian groups, e.g. `β = (Fin n → ZMod 2)`.
2. Define reversible lifts by addition of `f x` into a target register:
   \[
   (x,y) \mapsto (x, y + f(x)).
   \]
3. Prove bijectivity by explicit inverse `(x,y) ↦ (x, y - f(x))`, then instantiate to common algorithms:
   parity, prefix xor, finite linear transforms, maybe matrix-vector multiplication over `ZMod 2`.

Why promising: the inverse is explicit, the algebra is clean, and it gives concrete algorithm families with immediate circuit meaning.

---

## Concrete Common-Algorithm Targets

Do not stop at abstract existence. Construct provably optimal reversible realizations for simple but nontrivial algorithms.

### Candidate 1: Parity
For `f : (Fin n → ZMod 2) → ZMod 2` defined by sum of bits:
- define reversible lift,
- prove bijectivity,
- prove zero erasure before output cleanup,
- analyze fiber size exactly (`2^(n-1)` for `n > 0`), giving a sharp irreversible lower bound if one insists on discarding the input.

### Candidate 2: Linear maps over `ZMod 2`
For a matrix `A : Matrix (Fin m) (Fin n) (ZMod 2)`, define:
\[
f(x)=Ax.
\]
Then lift reversibly by `(x,y) ↦ (x, y + Ax)`.
Prove:
- bijectivity of the lift,
- exact relation between rank deficiency of `A` and entropy loss of the irreversible projection `x ↦ Ax` under uniform input.

This is excellent because **rank deficiency = lost information dimension**.

### Candidate 3: Boolean AND / OR on two bits
These are tiny but conceptually decisive:
- compute exact fiber multiplicities,
- prove strict entropy drop under uniform input,
- compare to `tropical_and_bound`,
- show the reversible lift restores entropy preservation.

This creates a bridge from logic gates to tropical thermodynamic bounds.

---

## Cross-Domain Connections You Must Exploit

### 1. Information theory × reversible computing
The theorem `entropy_map_le` is the discrete data-processing inequality for deterministic channels. State this explicitly. Reversible circuits are exactly the equality case.

### 2. Linear algebra × thermodynamic cost
For linear maps over finite fields, entropy loss should track kernel dimension / rank deficiency under uniform input. This gives a sharp algebraic thermodynamics:
\[
H(X)-H(AX)=\dim \ker A \cdot \log 2
\]
for uniform `X` over `(ZMod 2)^n` when `A` is linear.  
This is a spectacular theorem if you can formalize it.

Suggested Lean target:
```lean
theorem entropy_linear_map_uniform
  {m n : Nat}
  (A : Matrix (Fin m) (Fin n) (ZMod 2)) :
  entropy (uniformPMF.map (fun x => A.mulVec x)) =
    (Module.finrank (ZMod 2) (LinearMap.range (Matrix.toLinearMap A))) * Real.log 2
```
Adapt to actual available linear-algebra APIs. Even a cardinality/rank version is valuable.

### 3. Complexity theory × thermodynamics
Use `compressor_gives_complexity_bound` and `complexity_bound_implies_finite_entropy_bound` to formulate:
- low-description reversible implementations constrain state entropy,
- irreversibility corresponds to complexity-destroying quotienting/compression,
- garbage management is a complexity-entropy tradeoff.

This is the beginning of a formal **thermodynamic complexity theory**.

### 4. Tropical mathematics × Landauer principle
Leverage `tropical_landauer_bound` as a second semantics of cost. Seek a theorem saying your classical entropy lower bound tropicalizes to a min-plus cost law for irreversible gate composition. This is exactly the kind of unexpected bridge that can define a new research thread.

---

## Suggested Lean Definitions

You will likely need a small formal vocabulary. Keep it concrete.

```lean
def supportPMF {α : Type} [DecidableEq α] (p : PMF α) : Finset α := ...

noncomputable def entropy {α : Type} [Fintype α] [DecidableEq α] (p : PMF α) : ℝ := ...

def isReversible {α β : Type} (f : α → β) : Prop := Function.Bijective f

def reversibleLift
  {α β : Type} [AddGroup β]
  (f : α → β) : α × β → α × β
| (x,y) => (x, y + f x)

noncomputable def fiberCard
  {α β : Type} [Fintype α] [DecidableEq α] [DecidableEq β]
  (f : α → β) (y : β) : Nat :=
  ((Finset.univ.filter fun x => f x = y).card)

noncomputable def maxFiberCard
  {α β : Type} [Fintype α] [Fintype β] [DecidableEq α] [DecidableEq β]
  (f : α → β) : Nat := ...
```

If entropy is too heavy at first, define and prove cardinality analogues:
```lean
theorem card_range_le_card_domain ...
theorem card_range_eq_card_domain_iff_injective ...
theorem maxFiberCard_eq_one_iff_injective ...
```
Then lift these to entropy under uniform distributions.

---

## Minimal Nontrivial Deliverables

At minimum, produce Lean proofs for a coherent theorem chain such as:

1. `reversible_lift_bijective`
2. `entropy_map_le` for finite distributions or uniform finite distributions
3. `entropy_map_eq_of_bijective`
4. one concrete application:
   - parity,
   - linear maps over `ZMod 2`,
   - or AND/OR exact entropy loss
5. one bridge corollary invoking at least one catalog theorem

A strong package would add:
6. rank/kernel entropy theorem for linear maps over `ZMod 2`
7. implementation lower bound via `maxFiberCard`

---

## Recommended File Architecture

Create something like:
- `Computation/ReversibleLandauer.lean`
- `Computation/ReversibleCircuits.lean`
- `Computation/LinearThermodynamics.lean`

If a bridge theorem to the catalog becomes clean:
- `Computation/ReversibleComplexityBridge.lean`

---

## What Would Count as a Breakthrough

Any one of the following would be major:

- A fully formal proof that deterministic finite maps satisfy entropy monotonicity with equality iff support-injective.
- A certified Bennett-style reversible embedding theorem with explicit inverse and algorithm instances.
- A theorem equating entropy loss of linear finite-field computation with algebraic rank deficiency.
- A formal bridge theorem from reversible implementation complexity to entropy bounds using the existing catalog results.
- A tropical/classical comparison theorem linking your new Landauer formalization to `tropical_landauer_bound`.

These are not incremental. They establish a foundation for a new Lean-certified theory of physical computation.

---

## Application Keywords

reversible computing, Landauer principle, Shannon entropy, deterministic data processing, finite-state thermodynamics, Bennett embedding, reversible circuits, Toffoli universality, entropy production, information erasure, algorithmic complexity, Kolmogorov complexity, tropical thermodynamics, finite-field linear algebra, rank deficiency, compression, logical irreversibility, physical limits of computation

---

## Required FUTURE_DIRECTIONS.md

You must produce `FUTURE_DIRECTIONS.md` with 3–5 **testable scientific hypotheses**, each a falsifiable conjecture with a clear validation method.

Include hypotheses of the following flavor:

1. **Rank-entropy law extension**  
   Conjecture: for any finite field `𝔽_q`, entropy loss of a linear map under uniform input equals `dim ker(A) * log q`.  
   Test: formalize for `ZMod p` prime first, then compare cardinality-derived entropy identities.

2. **Garbage-compression tradeoff**  
   Conjecture: reversible implementations with compressible garbage admit strictly better complexity bounds via `compressor_gives_complexity_bound`.  
   Test: instantiate on parity and small linear circuits, compare complexity and entropy estimates.

3. **Tropicalization hypothesis**  
   Conjecture: the finite entropy loss bound admits a min-plus shadow compatible with `tropical_landauer_bound`.  
   Test: prove on two-input Boolean gates and compare exact classical entropy losses with tropical costs.

4. **Optimal ancilla conjecture**  
   Conjecture: for finite functions with maximal fiber size `M`, minimal irreversible cleanup cost is `⌈log₂ M⌉` bits.  
   Test: exhaustively verify on all Boolean functions of up to 3 bits, then isolate a proof pattern.

5. **Complexity-thermodynamics equivalence**  
   Conjecture: bounded reversible description complexity implies a universal entropy bound on reachable state ensembles stronger than the current catalog theorem in the reversible setting.  
   Test: derive a reversible specialization of `complexity_bound_implies_finite_entropy_bound`.

Make these precise, falsifiable, and connected to code/proof tasks.

---

## Final Directive

Do not write a vague essay on physics. Build a formal theorem ladder:
- finite entropy,
- monotonicity under deterministic maps,
- equality for bijections,
- explicit reversible embeddings,
- exact examples,
- complexity/thermodynamics bridge.

This is the moment to turn reversible computing from folklore into a certified mathematical theory.

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

Research domain: Computation
Research mode: prove
