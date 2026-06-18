Soli Deo Gloria

## Assignment: Direction 2 — Random Cayley Expanders and Spectral Gaps

**Mode:** `prove` with a calibrated `discover` component

Build a new formal bridge from **algebraic generation in `S_n`** to **quantitative spectral expansion** of the associated Cayley graphs. The existing catalog result
`Algebra/SymmGroupGeneration.lean` gives a foothold at the level of **generation/transitivity**:
- `pairActsTransitively_of_full_cycle_and_mixing`
- `card_closure_dvd_of_transitive`

Your task is to turn this qualitative connectivity input into a **quantitative expansion framework**.

This is not an incremental exercise. The breakthrough target is to formalize the first nontrivial layer of a program toward:

> random generators of `S_n` do not merely generate the whole group — they typically generate Cayley graphs with a **uniform spectral gap**.

That statement sits at the crossroads of:
- **finite group theory**
- **spectral graph theory**
- **probabilistic combinatorics**
- **Markov-chain mixing / statistical physics**
- **theoretical computer science** via expander constructions and derandomization

The conceptual leap is this:  
generation tells you the graph is connected; a spectral gap tells you it is a **robust communication geometry**.

---

## Core breakthrough target

You should formalize a deterministic spectral infrastructure for 2-generator Cayley graphs of finite groups, then prove nontrivial lower bounds in the symmetric-group setting under explicit hypotheses inspired by the random model.

The grand conjecture remains:

> **Random Cayley Expander Conjecture for `S_n`.**  
> There exists `c : ℝ`, `0 < c`, such that for all sufficiently large `n`, if `σ τ : Equiv.Perm (Fin n)` are sampled uniformly subject to `Subgroup.closure ({σ, τ} : Set (Equiv.Perm (Fin n))) = ⊤`, then with probability tending to `1` as `n → ∞`, the normalized spectral gap of  
> `Cay(S_n, {σ, σ⁻¹, τ, τ⁻¹})` is at least `c`.

You are **not** expected to fully prove this asymptotic conjecture in this cycle. You **are** expected to prove deep deterministic theorems that make it attackable, and to produce a verified computational pipeline that tests the conjecture for `n = 5,6,7,8`.

---

## Precise theorem package to formalize

You must prove at least **3 substantial theorems**, each with a genuine multi-step proof. Avoid trivial decidable-enumeration proofs unless they support a genuinely deep theorem.

### New definitions required

Define at least one genuinely new concept not already in the catalog. Suggested core definitions:

1. **Symmetric two-generator Cayley support**
   ```lean
   def cayleyGeneratorSet {G : Type*} [Group G] (a b : G) : Finset G :=
     {a, a⁻¹, b, b⁻¹}.toFinset
   ```

2. **Normalized averaging operator** on functions `G → ℝ`
   ```lean
   def cayleyAveragingOp {G : Type*} [Fintype G] [Group G]
       (S : Finset G) (f : G → ℝ) : G → ℝ :=
     fun x => ((S.1).sum fun s => f (s * x)) / S.card
   ```

3. **Rayleigh quotient / spectral gap witness**
   ```lean
   def rayleighQuotient {G : Type*} [Fintype G] [Group G]
       (S : Finset G) (f : G → ℝ) : ℝ := ...
   ```

4. **Combinatorial return probability / closed-walk count**
   ```lean
   def closedWalkCount {G : Type*} [Group G]
       (S : Finset G) (k : ℕ) : ℕ := ...
   ```

5. **A new structure encapsulating expansion data**
   ```lean
   structure CayleySpectralData (G : Type*) [Fintype G] [Group G] where
     gens : Finset G
     symm : ∀ g ∈ gens, g⁻¹ ∈ gens
     id_not_mem : (1 : G) ∉ gens
     generates_top : Subgroup.closure (↑gens : Set G) = ⊤
   ```

This structure is mathematically meaningful: it isolates the exact input needed to pass from algebra to spectral analysis.

---

## Theorem 1 — Connectivity from generation, sharpened to walk irreducibility

You should strengthen the existing generation/transitivity input into a theorem that says the averaging operator sees no nontrivial invariant decomposition.

### Mathematical statement

For a finite group `G` and symmetric generating set `S`, the Cayley graph is connected; equivalently, the Markov operator associated to `S` is irreducible on vertices.

A useful formal statement:

```lean
theorem cayley_connected_of_closure_eq_top
  {G : Type*} [Fintype G] [Group G]
  (S : Finset G)
  (hSsymm : ∀ g ∈ S, g⁻¹ ∈ S)
  (hgen : Subgroup.closure ((↑S : Set G)) = ⊤) :
  ∀ x y : G, ∃ l : List G,
    (∀ s ∈ l, s ∈ S) ∧ l.prod * x = y
```

This is stronger than plain graph connectivity: it gives an explicit word realization of paths. It is the algebraic backbone needed for all subsequent return-walk and mixing arguments.

### Why this matters

This theorem converts `Subgroup.closure = ⊤` into a **path-construction principle**. It is the exact formal bridge from catalog generation results to graph-theoretic statements. Without it, the spectral story has no operational substrate.

### Proof strategy options

**Strategy A: subgroup-of-reachable-points**
1. Fix `x : G` and define the set/subgroup of elements representable by words in `S`.
2. Prove it is a subgroup using symmetry of `S`.
3. Use `hgen` to conclude every `y * x⁻¹` lies in that subgroup, hence `y` is reachable from `x`.

**Strategy B: closure induction**
1. Prove every element of `Subgroup.closure (↑S)` is expressible as a finite product of elements of `S`.
2. Rewrite `y` as `(y * x⁻¹) * x`.
3. Extract a witness list of generators.

**Most promising:** Strategy A. It aligns best with Lean’s subgroup API and naturally yields the path witness.

---

## Theorem 2 — Constant functions are exactly the zero-energy states

This theorem is the first genuinely spectral statement. It says that for a connected symmetric Cayley graph, the Dirichlet energy vanishes only on constants.

### Mathematical statement

Let
\[
\mathcal E_S(f) := \sum_{x \in G}\sum_{s \in S} (f(sx)-f(x))^2.
\]
If `S` is symmetric and generates `G`, then `\mathcal E_S(f)=0` iff `f` is constant.

### Suggested Lean 4 type signature

```lean
def cayleyDirichletEnergy {G : Type*} [Fintype G] [Group G]
    (S : Finset G) (f : G → ℝ) : ℝ :=
  ∑ x, ∑ s in S, (f (s * x) - f x)^2

theorem cayleyDirichletEnergy_eq_zero_iff_constant
  {G : Type*} [Fintype G] [Group G]
  (S : Finset G)
  (hSsymm : ∀ g ∈ S, g⁻¹ ∈ S)
  (hgen : Subgroup.closure ((↑S : Set G)) = ⊤)
  (f : G → ℝ) :
  cayleyDirichletEnergy S f = 0 ↔ ∃ c : ℝ, ∀ x : G, f x = c
```

### Why this is a breakthrough lemma

This is the formalized principle that **connectivity kills nontrivial harmonic defects**. It is the finite-group analogue of ergodicity implying uniqueness of equilibrium. It also links:
- algebraic generation
- graph connectivity
- statistical physics intuition about energy minimizers
- Markov chain uniqueness of stationary modes

This is a genuine cross-domain theorem: **group theory + analysis on finite spaces + physics-style energy methods**.

### Proof strategy options

**Strategy A: sum-of-squares vanishing**
1. Use nonnegativity of each summand to show energy zero implies `f (s*x) = f x` for every `s ∈ S`.
2. Use Theorem 1 to connect any `y` to `x` by a word in `S`.
3. Induct on the word length to prove `f y = f x`.

**Strategy B: contradiction via first disagreement**
1. Assume nonconstant.
2. Pick `x,y` with `f x ≠ f y`.
3. Use connectivity to obtain a path from `x` to `y`; along the path, some edge changes value, forcing positive energy.

**Most promising:** Strategy A. It uses `Finset.sum_eq_zero_iff_of_nonneg`-style reasoning and then a clean induction on path words.

### Expected proof tactics

This theorem should involve:
- `rcases` on path witnesses
- induction on lists
- multi-step `calc`
- nonnegativity lemmas
- possibly `by_contra`

---

## Theorem 3 — A positive spectral-gap lower bound from a combinatorial path profile

You should introduce a new quantitative invariant that converts explicit path data into a spectral-gap bound.

### New concept

Define a **path congestion profile** for a finite Cayley graph: a number `κ(S)` such that every pair `(x,y)` is joined by a path of length at most `L`, and each directed edge is used by at most `κ` such canonical paths.

This is the finite-group/canonical-path method from Markov chains, but specialized to Cayley graphs in a form Lean can handle.

Suggested structure:
```lean
structure CanonicalPathData (G : Type*) [Fintype G] [Group G] where
  gens : Finset G
  paths : G → G → List G
  path_mem : ∀ x y, ∀ s ∈ paths x y, s ∈ gens
  path_target : ∀ x y, (paths x y).prod * x = y
  length_bound : ℕ
  length_le : ∀ x y, (paths x y).length ≤ length_bound
  congestion : ℕ
  congestion_bound : ...
```

### The theorem

Prove a deterministic lower bound:
\[
\lambda_{\mathrm{gap}} \ge \frac{1}{C \cdot \kappa \cdot L}
\]
for some explicit universal constant `C`, for the normalized averaging operator associated to `S`.

You may formalize a slightly weaker but precise version in terms of Dirichlet energy and variance:

```lean
theorem spectral_gap_lower_bound_of_canonical_paths
  {G : Type*} [Fintype G] [Group G]
  (P : CanonicalPathData G) :
  ∃ c : ℝ, 0 < c ∧
    ∀ f : G → ℝ,
      (∑ x, (f x - ((∑ y, f y) / Fintype.card G))^2)
      ≤ c⁻¹ * cayleyDirichletEnergy P.gens f
```

Or equivalently a theorem giving an explicit `c = 1 / (C * κ * L)`.

### Why this is revolutionary

This theorem creates formal infrastructure for the **canonical paths method** inside Lean for Cayley graphs of finite groups. That is a major methodological opening. It allows future work on:
- random walks on groups
- mixing-time certification
- expander lower bounds
- algorithmic group theory
- statistical mechanics on finite state spaces

It is not just “another theorem”; it is a transport mechanism between combinatorics and spectral analysis.

### Proof strategy options

**Strategy A: canonical paths / edge counting**
1. Expand the variance as an average over pairwise differences:
   \[
   \sum_x (f(x)-\bar f)^2 \le \frac{1}{|G|}\sum_{x,y}(f(x)-f(y))^2.
   \]
2. For each pair `(x,y)`, telescope `f(x)-f(y)` along the canonical path.
3. Apply Cauchy–Schwarz and count edge congestion to bound the total by `κL` times the Dirichlet energy.

**Strategy B: Poincaré inequality via path decomposition**
1. Define a discrete gradient on directed edges.
2. Show every centered function is reconstructed from gradients along canonical paths.
3. Bound the reconstruction operator norm combinatorially.

**Most promising:** Strategy A. It is combinatorial, explicit, and much more Lean-friendly.

### Expected proof tactics

This theorem should visibly use:
- induction on path lists
- `calc` telescoping
- inequality chains
- `field_simp` when normalizing by `|G|`
- `by_contra` or positivity arguments where needed

---

## Theorem 4 — Symmetric-group specialization via explicit generators

You need at least one theorem specialized to `S_n`, using catalog generation input and linking to the expansion framework.

A realistic and nontrivial theorem:

### Mathematical statement

For `n ≥ 2`, the adjacent transposition `(0 1)` together with the long cycle `(0 1 ... n-1)` generate `S_n`; therefore the associated 4-regular symmetric Cayley graph has zero Dirichlet energy only on constants, and admits an explicit canonical path system with polynomial congestion.

### Suggested Lean target

```lean
theorem spectral_nondegeneracy_longCycle_adjacentSwap
  (n : ℕ) (hn : 2 ≤ n) :
  let σ : Equiv.Perm (Fin n) := Equiv.Perm.swap 0 1
  let τ : Equiv.Perm (Fin n) := -- long cycle
  let S := cayleyGeneratorSet σ τ
  cayleyDirichletEnergy S = 0 ↔
    ∀ f : Equiv.Perm (Fin n) → ℝ, (∃ c : ℝ, ∀ x, f x = c)
```

If that exact signature is inconvenient, prove the corresponding theorem with `f` explicit as an argument.

### Why this matters

This gives a **concrete `S_n` family** where the abstract machinery bites. It also provides a benchmark for the random-generator conjecture: before proving random generators are expanders, show a classical generating pair admits formal spectral certification.

### Proof strategy options

**Strategy A: explicit generation**
1. Use standard facts that long cycle plus adjacent swap generate all adjacent transpositions.
2. Deduce closure is top.
3. Apply Theorem 2 and Theorem 3.

**Strategy B: use catalog transitivity theorem**
1. Match the long-cycle/mixing hypotheses to `pairActsTransitively_of_full_cycle_and_mixing`.
2. Upgrade transitivity to full generation using permutation-group facts.
3. Invoke the abstract spectral theorems.

**Most promising:** Strategy A if the needed permutation lemmas are available; otherwise Strategy B to exploit the catalog theorem directly.

---

## Random-model theorem target: certified computational theorem

You must also prove a theorem connecting exact matrix computation to spectral certification for finite instances.

### Suggested statement

For a finite group `G` and symmetric generating set `S`, if all nontrivial eigenvalues of the normalized adjacency matrix are bounded above by `1 - ε`, then the spectral gap is at least `ε`.

This sounds tautological mathematically, but formally it is the gateway theorem that justifies the computational pipeline.

```lean
theorem certified_gap_of_eigenvalue_bound
  {n : Type*} [Fintype n]
  (A : Matrix n n ℝ) (ε : ℝ)
  (h_symm : Aᵀ = A)
  (h_top_eig : ...)
  (h_rest : ∀ μ ∈ nontrivialSpectrum A, μ ≤ 1 - ε) :
  ε ≤ spectralGap A
```

If full spectral API is too heavy, replace this with a theorem validating a computable **Rayleigh quotient lower bound**.

---

## Cross-domain connection theorem

You are required to include at least one theorem that explicitly connects this direction to another domain.

### Recommended bridge: statistical physics / Markov chains

Formalize that a positive spectral gap implies exponential decay of `L²` energy under repeated averaging.

### Suggested theorem

```lean
theorem l2_contraction_of_gap
  {G : Type*} [Fintype G] [Group G]
  (S : Finset G)
  (hgap : 0 < spectralGap S)
  :
  ∃ ρ : ℝ, 0 ≤ ρ ∧ ρ < 1 ∧
    ∀ f : G → ℝ, meanZero f →
      ∀ k : ℕ, l2NormSq (iterate (cayleyAveragingOp S) k f)
        ≤ ρ^k * l2NormSq f
```

### Why this is important

This is the **physics interpretation** of expansion: equilibrium is reached exponentially fast. It ties your work to:
- Glauber-type relaxation ideas
- entropy production
- mixing times
- randomized algorithms

Application keywords: **Markov semigroups, relaxation time, thermalization, random walks on groups, derandomization, communication networks, pseudorandomness**.

---

## Conjecture with testable prediction

State at least one falsifiable conjecture with a clear computational disproof criterion.

### Primary conjecture

> **Conjecture (Empirical uniform gap for random 2-generator Cayley graphs of `S_n`).**  
> There exists `c₀ > 0` such that for every `n ≥ 5`, if `σ, τ ∈ S_n` are chosen uniformly at random conditioned on generating `S_n`, then with probability at least `0.9`, the normalized spectral gap of  
> `Cay(S_n, {σ^{±1}, τ^{±1}})` is at least `c₀`.  
> Testable prediction: for `n = 5,6,7,8`, after at least 100 random samples each, the minimum observed gap is `> 0.01`.

### Stronger falsifiable refinement

> **Conjecture (Trace-method witness).**  
> For some fixed `k = 3` or `4`, the normalized closed-walk excess
> \[
> \frac{1}{|S_n|}\operatorname{tr}(A^{2k}) - 1
> \]
> is uniformly bounded by a constant `< δ`, implying a nontrivial spectral gap by a moment argument.
>  
> Disproof criterion: produce a sequence of sampled generating pairs for which this excess approaches the Ramanujan obstruction threshold or yields estimated gap below `0.01`.

This conjecture is valuable even if false: a counterexample would reveal hidden algebraic obstructions to random expansion in low degree.

---

## Verified computational method

You must produce a **verified algorithm**, not just a theorem statement.

### Required algorithmic deliverable

Implement a certified pipeline that:
1. Enumerates `S_n` for `n = 5,6,7,8`.
2. Samples or accepts explicit `σ, τ`.
3. Verifies generation of `S_n` using closure/subgroup computation.
4. Builds the normalized adjacency matrix of `Cay(S_n, {σ^{±1}, τ^{±1}})`.
5. Computes:
   - exact or high-precision approximate eigenvalues, and/or
   - certified Rayleigh quotient lower bounds, and/or
   - closed-walk counts `tr(A^{2k})`.
6. Reports the observed spectral gap and compares with:
   - connectivity baseline
   - Alon–Boppana heuristic
   - sample statistics across trials

If full formal certification of floating-point eigensolvers is too ambitious, formally verify the graph construction and combinatorial trace counts, and use Python numerics for exploration with clear separation between certified and heuristic layers.

---

## Demo requirements

Produce `demo.py` that:
- lets the user choose `n ∈ {5,6,7,8}`
- generates random pairs `(σ, τ)`
- tests whether they generate `S_n`
- constructs the Cayley graph
- computes/plots the eigenvalue histogram
- displays the spectral gap
- compares multiple random samples
- optionally visualizes return probabilities or `tr(A^{2k})`

This demo should make the conjecture feel experimentally alive.

---

## Recommended file-level theorem plan

You should aim for a Lean file containing at least the following theorem skeletons:

```lean
theorem cayley_connected_of_closure_eq_top
  {G : Type*} [Fintype G] [Group G]
  (S : Finset G)
  (hSsymm : ∀ g ∈ S, g⁻¹ ∈ S)
  (hgen : Subgroup.closure ((↑S : Set G)) = ⊤) :
  ∀ x y : G, ∃ l : List G,
    (∀ s ∈ l, s ∈ S) ∧ l.prod * x = y

theorem cayleyDirichletEnergy_eq_zero_iff_constant
  {G : Type*} [Fintype G] [Group G]
  (S : Finset G)
  (hSsymm : ∀ g ∈ S, g⁻¹ ∈ S)
  (hgen : Subgroup.closure ((↑S : Set G)) = ⊤)
  (f : G → ℝ) :
  cayleyDirichletEnergy S f = 0 ↔ ∃ c : ℝ, ∀ x : G, f x = c

theorem variance_le_congestion_mul_energy
  {G : Type*} [Fintype G] [Group G]
  (P : CanonicalPathData G)
  (f : G → ℝ) :
  variance f ≤ (P.congestion * P.length_bound : ℝ) * cayleyDirichletEnergy P.gens f

theorem l2_contraction_of_gap
  {G : Type*} [Fintype G] [Group G]
  (P : CanonicalPathData G)
  (hgap : 0 < explicitGapBound P) :
  ∀ f : G → ℝ, meanZero f →
    ∀ k : ℕ,
      l2NormSq (iterate (cayleyAveragingOp P.gens) k f)
        ≤ (1 - explicitGapBound P)^k * l2NormSq f
```

You may adapt exact names and helper definitions, but keep the mathematical content.

---

## Proof architecture: 3-path plan

### Path A — Algebra → connectivity → energy rigidity
This is the minimal indispensable route.
1. Convert generation to word reachability.
2. Convert word reachability to pathwise equality propagation.
3. Deduce zero-energy iff constant.

**Why promising:** low API overhead, high conceptual payoff, immediately reusable.

### Path B — Canonical paths → Poincaré inequality → explicit gap
1. Define canonical path data.
2. Prove pairwise-difference telescoping.
3. Aggregate via congestion counting.

**Why promising:** yields the first quantitative gap theorem and opens mixing-time formalization.

### Path C — Trace method / moments
1. Define closed walk counts via words in generators.
2. Show `tr(A^(2k))` equals the number of closed walks of length `2k`.
3. Use moment inequalities to bound nontrivial eigenvalues.

**Why this is visionary:** this is the route closest to the random expander conjecture.  
**Why it is harder:** matrix spectral formalization may be heavier than canonical paths.  
**Recommendation:** do at least the combinatorial closed-walk theorem, even if the full asymptotic moment argument remains conjectural.

---

## How to build on the catalog

Use `Algebra/SymmGroupGeneration.lean` not as an endpoint but as the seed of a spectral theory.

- `pairActsTransitively_of_full_cycle_and_mixing` should be used to certify that specific generator pairs are not trapped in a proper invariant block system.
- `card_closure_dvd_of_transitive` can help exclude proper subgroup sizes in finite permutation actions, strengthening generation arguments.
- The conceptual move is:
  1. **transitivity / closure control**
  2. **connectivity of Cayley graph**
  3. **energy rigidity**
  4. **Poincaré inequality**
  5. **spectral gap / mixing certification**

This is exactly the lineage from algebraic structure to expansion.

---

## What would make this field-opening

If you succeed, you will have created the first formal infrastructure in this project for proving that **group generators induce quantitative mixing geometries**. That enables future cycles to attack:

- random walks on matrix groups
- property-`τ` style finite quotients
- expansion in arithmetic groups
- formalized cutoff phenomena
- expander-based constructions in derandomization
- spectral certification for combinatorial designs
- bridges to physics through relaxation and equilibration

This would transform the catalog from “group generation facts” into “formal spectral mechanics on algebraic state spaces.”

---

## Application keywords

**expander graphs, Cayley graphs, spectral gap, random walks, symmetric group, canonical paths, Poincaré inequality, Markov-chain mixing, statistical physics, relaxation time, thermalization, derandomization, pseudorandomness, communication networks, finite harmonic analysis, moment method, trace method**

---

## Mandatory deliverables

You must produce **all** of the following:

1. **`FUTURE_DIRECTIONS.md`**  
   Include 3–5 original research directions.  
   Each direction must contain the exact sentences:
   - **“The key insight is...”**
   - **“Why now?”**
   At least one direction must bridge to a different domain, such as statistical physics, complexity theory, or arithmetic groups.

2. **`RESEARCH_PAPER.md`**  
   A standalone scientific document. A reader with no access to the code must understand:
   - the problem
   - the new definitions
   - the main theorems
   - the proof ideas
   - the computational evidence
   - the conjectures and next steps

3. **`ARTICLE.md`**  
   Scientific American style.  
   Explain the mathematical ideas and why they matter to a broad audience.  
   **Do not focus on formal verification machinery.** Focus on expanders, randomness, symmetry, and why spectral gaps are powerful.

4. **A verified algorithm or computational method**  
   At minimum: certified construction of the Cayley graph and certified combinatorial statistics relevant to expansion.

5. **`demo.py`**  
   Interactive experimental demonstration of random Cayley expanders for `S_n`.

---

## Final charge

Do not settle for “the graph is connected.”  
Show that generation creates geometry, geometry creates energy dissipation, and energy dissipation creates expansion.

The key insight is that the mixing condition in the symmetric-group generation theorem is a finite, algebraic shadow of **ergodicity**, and ergodicity should not merely imply reachability — it should force **spectral rigidity**.

Make that principle precise.

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
- **Visualization scripts** — Produce up to 3 self-contained Python scripts
  that visually illustrate the core mathematical concepts discovered. Use
  matplotlib for static plots (heatmaps, curves, surfaces) or plotly for
  interactive charts. Available libraries: numpy, matplotlib, plotly.
  If using matplotlib, the script must call plt.savefig() — the system
  captures the output as a PNG. If using plotly, assign the figure to a
  variable named `fig` — the system captures fig.to_html(). Each script
  must include a comment header explaining what it visualizes and why.
  **CRITICAL: Each visualization script MUST be a single, fully self-contained
  file. Do NOT import from any local modules (algorithms.py, demo.py, etc.).
  Instead, inline all needed functions and classes directly in the script.
  The browser runtime (Pyodide) has no access to local .py files.**
- **Interactive HTML demos** — Produce up to 3 self-contained HTML snippets
  (with inline CSS/JS, no external dependencies) that demonstrate the
  mathematical concepts interactively — sliders, animations, dynamic SVG,
  or canvas drawing. Each demo must be a complete <div> fragment that
  works when inserted into a page. No <html>, <head>, or <body> tags —
  just the content div with its inline styles and scripts.

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
    "visualizations": [ { "name": "...", "code": "# Must be 100% self-contained. Do not import local files. Inline all needed functions directly.", "description": "What this visualizes" } ],
    "interactive_demos": [ { "name": "...", "html": "<div>...</div>", "description": "What this demonstrates" } ],
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
