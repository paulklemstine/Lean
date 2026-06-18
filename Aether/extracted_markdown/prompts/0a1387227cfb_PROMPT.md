## Mode: prove

## Title
**Arithmetic Topological Signatures in Modular Collatz Dynamics: a Phase Transition Program for Persistent Homology of Preimage Graphs Modulo Primes**

You should not treat this as a numerical experiment with a theorem-shaped wrapper. The target is to create a new arithmetic-topological theory: persistent homology as a detector of congruence-controlled dynamical phases in modular Collatz systems. The breakthrough is not “some barcode varies with \(p\).” The breakthrough is to isolate explicit arithmetic mechanisms forcing topological features of inverse-branch complexes, and to prove rigorous congruence-sensitive theorems that make the large-scale conjecture plausible and testable.

The core vision is this: the accelerated Collatz map modulo primes is not merely a finite dynamical system. Its inverse-branch geometry is an arithmetic hypergraph, and the topology of its clique complex should encode residue-theoretic obstructions and symmetries that standard orbit statistics miss. If you can prove even the first nontrivial congruence-controlled persistent \(H_1\) separation theorem, you open a field connecting Collatz dynamics, finite field arithmetic, random simplicial complexes, and topological data analysis.

---

## Precise formal target

Work with odd primes \(p \neq 3\). Formalize a modular inverse-branch model for the accelerated Collatz map on \(\mathbb{F}_p^\times\), not by importing the 2-adic valuation directly, but by encoding **admissible inverse branches** through congruence conditions:
\[
y = \frac{2^k x - 1}{3} \pmod p,
\]
with \(k \ge 1\), \(y \neq 0\), and an admissibility predicate expressing that this branch corresponds to an odd preimage class and is nondegenerate modulo \(p\).

You need a new structure capturing branch multiplicity and filtration.

### Novel definitions to introduce
Define at least one genuinely new concept; ideally all of the following.

1. **Branch profile**
   For \(x \in \mathbb{F}_p^\times\), define
   \[
   \mathrm{BranchProfile}_p(x;K) := \{k \in \{1,\dots,K\} : \exists y \in \mathbb{F}_p^\times,\ 3y+1 \equiv 2^k x \pmod p\}.
   \]
   Then define the **inverse-branch multiplicity**
   \[
   \mu_{p,K}(x) := |\mathrm{BranchProfile}_p(x;K)|.
   \]

2. **Collatz preimage graph modulo \(p\)**
   Directed graph \(G_{p,K}\) on \(\mathbb{F}_p^\times\) with edge \(y \to x\) iff there exists \(k \in \{1,\dots,K\}\) such that
   \[
   3y+1 \equiv 2^k x \pmod p.
   \]

3. **Multiplicity filtration**
   On the undirected symmetrization \(G^{\mathrm{sym}}_{p,K}\), define the threshold graph
   \[
   G^{(\ell)}_{p,K}
   \]
   on vertices \(x\) with \(\mu_{p,K}(x)\ge \ell\), or alternatively on edges weighted by the number of branch exponents \(k\) witnessing adjacency. Build the flag complex \(X^{(\ell)}_{p,K}\).

4. **Arithmetic phase signature**
   A barcode summary statistic \(S_{p,K}\) extracted from the persistent \(H_1\) module of the filtration \(\{X^{(\ell)}_{p,K}\}_\ell\). You should define at least one exact, Lean-friendly summary such as Euler characteristic profile, first Betti number profile, or total persistence surrogate based on finite sums.

This is the right level of abstraction: enough to state structural theorems exactly, but still finite/combinatorial enough to formalize in Lean.

---

## Minimum theorem package

You must prove **at least 3 nontrivial theorems** with real proof architecture. Do not settle for computational lemmas. The ideal package is:

### Theorem 1: Periodicity of branch profiles from the order of 2 mod \(p\)
For \(p\) odd prime, \(p \neq 3\), and \(d = \mathrm{ord}_p(2)\), the admissible branch relation is periodic in \(k\) modulo \(d\). Consequently the branch multiplicity \(\mu_{p,K}(x)\) is controlled by the residue classes of \(k\) mod \(d\), and for fixed \(x\),
\[
\mu_{p,K}(x) = \sum_{r \in R_p(x)} \left\lfloor \frac{K-r}{d}\right\rfloor + O(1),
\]
for an explicit residue set \(R_p(x)\subseteq \{1,\dots,d\}\).

**Why it matters:** this is the first arithmetic compression theorem. It shows that the filtration is not arbitrary; it is governed by the multiplicative order of 2, hence by congruence information about \(p\).

#### Lean 4 target signature
```lean
theorem branch_periodic_mod_order
  {p K : ℕ} (hp : Nat.Prime p) (hpodd : p ≠ 2) (hp3 : p ≠ 3) :
  let d := orderOf (2 : ZMod p)
  ∀ x : ZMod p,
    ∀ k : ℕ,
      branchAdmissible p x k ↔ branchAdmissible p x (k + d)
```

and a counting corollary such as
```lean
theorem branchMultiplicity_controlled_by_order
  {p K : ℕ} (hp : Nat.Prime p) (hpodd : p ≠ 2) (hp3 : p ≠ 3) :
  ∃ C : ℕ,
    ∀ x : ZMod p,
      branchMultiplicity p K x ≤ K / orderOf (2 : ZMod p) + C
```

If exact asymptotics are too heavy in Lean, prove rigorous upper/lower bounds with explicit constants.

---

### Theorem 2: Congruence forcing of distinct multiplicity spectra
Prove that there exist explicit congruence classes of primes for which the branch multiplicity profile is qualitatively different. A strong and realistic target is to separate primes by the parity or divisibility properties of \(\mathrm{ord}_p(2)\), or by whether \(-3\) lies in the subgroup generated by 2.

A concrete theorem:

For infinitely many primes \(p\equiv a \pmod M\), there exists a positive proportion of vertices with branch multiplicity at least 2; for infinitely many primes \(p\equiv b \pmod M\), the proportion of such vertices is strictly smaller, with an explicit gap.

This can be phrased via subgroup intersection in \(\mathbb{F}_p^\times\).

**Why it matters:** this is the first phase-separation statement. It converts arithmetic information into a topological filtration input.

#### Lean 4 target signature
```lean
theorem exists_congruence_classes_with_distinct_branch_density :
  ∃ M a b : ℕ,
    a < M ∧ b < M ∧ a ≠ b ∧
    (InfinitelyManyPrimesInClass a M) ∧
    (InfinitelyManyPrimesInClass b M) ∧
    ∃ ε : ℚ, 0 < ε ∧
      ∀ᶠ p in primesInClass a M, branchDenseInvariant p ≥ ε + branchDenseInvariant' p ∧
      ∀ᶠ p in primesInClass b M, branchDenseInvariant' p ≤ branchDenseInvariant p
```

If the exact “infinitely many primes in class” infrastructure is too heavy, prove a finite-field version parameterized by subgroup hypotheses:
```lean
theorem subgroup_condition_for_branch_gap
  {p : ℕ} (hp : Nat.Prime p) (hpodd : p ≠ 2) (hp3 : p ≠ 3)
  (hA : (- (3 : ZMod p)) ∈ Subgroup.zpowers (2 : ZMod p)) :
  lowerBranchDensityBound p
```
and separately connect the subgroup hypothesis to congruence classes in the paper and demo.

---

### Theorem 3: Topological cycle criterion from arithmetic branch collisions
Prove a theorem that forces nontrivial \(H_1\) in the flag complex once enough arithmetic collisions occur among inverse branches.

A precise graph-theoretic target:
If there exist distinct vertices \(x_1,x_2,x_3,x_4\) with edges forming an induced 4-cycle in \(G^{\mathrm{sym}}_{p,K}\), then the flag complex has nontrivial \(H_1\). Then prove arithmetic conditions guaranteeing such induced 4-cycles from distinct branch exponents \(k_1,k_2,k_3,k_4\).

This is ideal because:
- the topological part is exact and formalizable;
- the arithmetic part can be reduced to solvability/non-solvability of explicit congruences;
- together they produce a true number-theory + topology theorem.

#### Lean 4 target signatures
```lean
theorem induced_four_cycle_gives_nontrivial_H1
  {V : Type*} [Fintype V] [DecidableEq V]
  (G : SimpleGraph V) :
  HasInducedFourCycle G → Nonempty (FirstHomologyNontrivial (flagComplex G))
```

and the arithmetic realization:
```lean
theorem arithmetic_collision_yields_induced_four_cycle
  {p K : ℕ} (hp : Nat.Prime p) (hpodd : p ≠ 2) (hp3 : p ≠ 3) :
  explicitCollisionCondition p K →
  HasInducedFourCycle (collatzSymGraph p K)
```

If full homology is not already in convenient catalog form, use a rigorous surrogate theorem:
- non-chordality of the graph,
- existence of a cycle not bounded by 2-simplices,
- Betti lower bound via Euler characteristic under triangle exclusions.

That still counts if done mathematically correctly.

---

## A stronger theorem if the library supports it

### Theorem 4: Congruence-sensitive Betti gap
Prove there exist explicit residue classes \(a,b \pmod M\), constants \(K,\delta>0\), and infinitely many primes in each class such that
\[
\beta_1(X^{(\ell)}_{p,K}) - \beta_1(X^{(\ell)}_{q,K}) \ge \delta p
\]
for suitable \(p\equiv a \pmod M\), \(q\equiv b \pmod M\), at a common filtration level \(\ell\).

Even a weaker linear-vs-zero lower bound would be major. This is the theorem that would transform the conjectural phase transition into a rigorous asymptotic separation result.

#### Lean-style aspirational signature
```lean
theorem congruence_class_betti_gap
  :
  ∃ M a b K ℓ : ℕ, a < M ∧ b < M ∧ a ≠ b ∧
    ∃ c : ℚ, 0 < c ∧
      ∀ᶠ p in primesInClass a M,
        c * p ≤ firstBetti (collatzFlagComplexAtLevel p K ℓ)
```

---

## Proof strategy architecture

You must give Aristotle multiple routes. Here are the best ones.

### Strategy A: Finite-field harmonic analysis via multiplicative order
**Most promising for the first breakthrough.**

1. Rewrite inverse-branch existence as a linear congruence
   \[
   y = (2^k x - 1)/3
   \]
   in \(\mathbb{F}_p\), valid since \(3\) is invertible mod \(p\neq 3\).

2. Observe that all dependence on \(k\) is through \(2^k\), hence through the cyclic subgroup \(\langle 2\rangle \le \mathbb{F}_p^\times\). This makes branch structure periodic with period \(\mathrm{ord}_p(2)\).

3. Use subgroup membership conditions to characterize collisions:
   \[
   \frac{3y_i+1}{x} \in \langle 2\rangle.
   \]
   This turns graph adjacency into arithmetic incidence between affine translates and multiplicative subgroups.

4. Derive density statements by counting intersections of affine images of \(\langle 2\rangle\). Even weak lower bounds already imply different multiplicity spectra for different subgroup configurations.

**Why most promising:** it reduces the Collatz complexity to finite cyclic group structure, which Lean handles better than asymptotic probabilistic TDA. It gives exact theorems with clean algebraic proofs.

---

### Strategy B: Graph-theoretic topology via induced cycles and chordality obstructions
**Most promising for the topology theorem.**

1. Define the symmetrized modular Collatz graph and its flag complex.

2. Prove a purely combinatorial lemma: an induced \(n\)-cycle with \(n \ge 4\) in a graph produces nontrivial \(H_1\) in the clique complex, provided no 2-simplices fill it.

3. Translate explicit arithmetic branch-collision conditions into an induced 4-cycle or 5-cycle in the graph.

4. Use Euler characteristic or explicit simplicial chain arguments to certify \(\beta_1>0\).

**Why valuable:** it yields rigorous persistent-homology consequences from finite arithmetic certificates. It is the right bridge theorem between number theory and TDA.

---

### Strategy C: Character sums / pseudorandomness heuristic upgraded to rigorous partial results
**More ambitious, perhaps for the paper and conjecture support.**

1. Model the set of admissible branch exponents through multiplicative characters on \(\mathbb{F}_p^\times\).

2. Estimate branch-collision counts using orthogonality or subgroup equidistribution.

3. Compare the resulting graph to a random intersection graph or inhomogeneous Erdős–Rényi model.

4. Use known heuristics from random flag complexes to predict \(H_1\) birth/death windows and formulate a falsifiable congruence-sensitive phase transition law.

**Why not first:** this is mathematically powerful but heavier to formalize completely. It is ideal for the scientific narrative, conjecture sharpening, and demo-guided discovery, while the formal core should rely on exact subgroup/cycle lemmas.

---

## Cross-domain connections you must explicitly build

This project is only revolutionary if you make the bridges explicit.

### 1. Number theory × Topological data analysis
The modular inverse-branch graph is an arithmetic object; persistent homology extracts mesoscale structure invisible to orbit length or cycle counting. This is the central bridge.

### 2. Finite dynamical systems × Random simplicial complexes
Once branch incidences are expressed through subgroup intersections, the resulting flag complexes can be compared to random clique complexes. This suggests phase transitions in \(\beta_1\) as \(p\) varies through congruence classes.

### 3. Additive combinatorics × Arithmetic dynamics
Adjacency conditions are affine images of multiplicative subgroups. This links the problem to sum-product phenomena, subgroup intersections, and character-sum estimates.

### 4. Spectral graph theory × Persistence
You should define and test whether branch multiplicity filtration correlates with spectral gap, cycle counts, or expansion proxies of \(G^{\mathrm{sym}}_{p,K}\). Even one theorem bounding cycle creation from degree variance would be powerful.

### 5. Statistical physics / phase transitions
The conjectured congruence-class concentration of barcode summaries is naturally interpreted as an arithmetic phase transition: residue classes of primes act like control parameters selecting different topological phases.

---

## Precise conjecture to formalize and test

State this sharply in the code and paper.

### Conjecture: arithmetic concentration of barcode summaries
There exist integers \(M \ge 2\), \(K \ge 2\), a finite set \(C \subseteq (\mathbb{Z}/M\mathbb{Z})^\times\), and a barcode summary \(S_{p,K}\) such that for each \(c \in C\) there exists a probability measure \(\nu_c\) on a finite-dimensional summary space with:
\[
S_{p,K} \xrightarrow[p\to\infty,\ p\equiv c \!\!\!\pmod M]{} \nu_c
\]
outside a zero-density exceptional set of primes, and for some \(c_1 \neq c_2\),
\[
d(\nu_{c_1},\nu_{c_2}) > 0
\]
for a concrete metric \(d\).

### Falsifiable prediction
For fixed \(K\) and summary \(S_{p,K}\), if one clusters primes by \(p \bmod M\), then:
- within-class variance of \(S_{p,K}\) should decrease with \(p\),
- between at least two classes the empirical distance should stay bounded away from 0.

A single infinite subsequence of primes in one residue class with persistent failure of concentration refutes the conjecture.

Make this computationally precise in `demo.py`.

---

## Lean 4 formalization targets

You asked for exact type signatures. Here are realistic targets. Adjust names to actual Mathlib APIs, but keep the mathematical content.

```lean
/-- Admissible inverse branch exponent for modular accelerated Collatz. -/
def branchAdmissible (p : ℕ) (x : ZMod p) (k : ℕ) : Prop :=
  ∃ y : ZMod p, y ≠ 0 ∧ (3 : ZMod p) * y + 1 = (2 : ZMod p)^k * x

/-- Number of admissible branch exponents up to K. -/
def branchMultiplicity (p K : ℕ) (x : ZMod p) : ℕ :=
  Fintype.card {k : Fin (K+1) // branchAdmissible p x k.1}

/-- Symmetrized modular Collatz graph. -/
def collatzSymGraph (p K : ℕ) : SimpleGraph (ZMod p) :=
  -- edge x y iff x ≠ y and some branch relation connects x and y in either direction
  ...

/-- Vertex-threshold filtration level by branch multiplicity. -/
def collatzLevelGraph (p K ℓ : ℕ) : SimpleGraph {x : ZMod p // ℓ ≤ branchMultiplicity p K x} :=
  SimpleGraph.induce (fun x => ℓ ≤ branchMultiplicity p K x) (collatzSymGraph p K)
```

### Core theorem signatures
```lean
theorem branch_periodic_mod_order
  {p : ℕ} (hp : Nat.Prime p) (hp2 : p ≠ 2) (hp3 : p ≠ 3) :
  let d := orderOf (2 : ZMod p)
  ∀ x : ZMod p, ∀ k : ℕ,
    branchAdmissible p x k ↔ branchAdmissible p x (k + d)

theorem branchMultiplicity_residue_bound
  {p K : ℕ} (hp : Nat.Prime p) (hp2 : p ≠ 2) (hp3 : p ≠ 3) :
  ∃ C : ℕ, ∀ x : ZMod p,
    branchMultiplicity p K x ≤ K / orderOf (2 : ZMod p) + C

theorem arithmetic_collision_yields_cycle
  {p K : ℕ} (hp : Nat.Prime p) (hp2 : p ≠ 2) (hp3 : p ≠ 3) :
  explicitCollisionCondition p K →
  ∃ v₁ v₂ v₃ v₄ : ZMod p,
    IsInducedCycle4 (collatzSymGraph p K) v₁ v₂ v₃ v₄

theorem induced_cycle4_implies_nontrivial_cycle_space
  {V : Type*} [Fintype V] [DecidableEq V] (G : SimpleGraph V) :
  (∃ v₁ v₂ v₃ v₄, IsInducedCycle4 G v₁ v₂ v₃ v₄) →
  graphCycleRank G > 0
```

If full simplicial homology APIs are available and manageable, replace the last theorem by a genuine \(H_1 \neq 0\) statement for the flag complex.

---

## Catalog-building guidance

Build on existing Mathlib facts in these directions:
- `ZMod p` field structure for prime \(p\),
- `orderOf` and subgroup lemmas in finite cyclic groups,
- `SimpleGraph`, induced subgraphs, walks/cycles/chordality-related lemmas,
- finite set/cardinality lemmas for branch counting,
- linear algebra or simplicial APIs if available for cycle-space / homology surrogates.

Do not overcommit to unavailable high-level persistent homology machinery in Lean. Formalize the exact filtration and prove theorems about:
- monotonicity of filtration,
- cycle creation criteria,
- Betti surrogates,
- explicit graph invariants extracted from the filtration.

Then compute actual barcodes in Python.

---

## What would count as a genuine breakthrough

Any one of the following would already be field-opening:

1. **A rigorous congruence-sensitive lower bound on \(H_1\)** for infinitely many primes in one class and not another.
2. **A theorem showing branch multiplicity filtration is controlled by \(\mathrm{ord}_p(2)\)** and hence by arithmetic of the prime.
3. **An explicit arithmetic criterion producing induced cycles** in the modular Collatz graph, thus forcing nontrivial topological structure.
4. **A verified algorithm that predicts topological phase from residue class data** with mathematically justified invariants.

This is not incremental Collatz work. It is the creation of arithmetic TDA for discrete dynamical systems.

---

## Required computational method

You must produce a verified computational pipeline, not just theorem statements.

### Algorithmic deliverable
Implement a certified procedure that:
1. constructs \(G_{p,K}\) and its undirected symmetrization;
2. computes branch multiplicity filtration levels;
3. builds the flag complex at each level;
4. computes at least \(\beta_0,\beta_1\) or a reliable cycle-rank surrogate;
5. outputs barcode summaries and residue-class comparisons.

The correctness theorem should state that the algorithm’s branch multiplicity and adjacency outputs match the formal definitions.

Suggested formal/computational split:
- Lean verifies the branch relation, periodicity, and graph construction correctness.
- Python computes barcode summaries for large primes and visualizes clustering by \(p \bmod M\).

---

## demo.py requirements

`demo.py` must be interactive and scientific, not a toy.
It should:
- allow the user to choose \(K\), modulus classes, and prime range;
- compute \(G_{p,K}\), filtration profiles, and summary statistics;
- plot branch multiplicity histograms;
- plot \(\beta_1\) or cycle-rank across primes;
- cluster summary vectors by \(p \bmod M\);
- explicitly test the falsifiable prediction:
  within-class variance vs between-class distance.

Bonus if it visualizes representative graphs/complexes for two distinct congruence classes.

---

## Application keywords

Use these explicitly in the paper and metadata:
**Collatz dynamics, arithmetic dynamics, finite fields, modular graphs, inverse branches, multiplicative order, subgroup intersections, flag complexes, clique complexes, persistent homology, Betti numbers, topological data analysis, phase transition, congruence classes of primes, random simplicial complexes, additive combinatorics, spectral graph theory, arithmetic topology**

---

## Deliverables you must produce

You must produce **all** of the following.

### 1. `FUTURE_DIRECTIONS.md`
Give 3–5 concrete research directions. Each direction must include:
- a sentence beginning **“The key insight is...”**
- a sentence beginning **“Why now?”**
At least one direction must bridge to a different domain, such as statistical physics, coding theory, or quantum information.

Examples of acceptable future directions:
- replace the Collatz inverse-branch graph by a family attached to general affine semigroup dynamics;
- compare modular Collatz flag complexes to random clique complexes with matched degree profile;
- investigate whether residue-class-dependent barcode laws reflect Artin-style primitive root phenomena;
- define entropy or mutual-information-like invariants of arithmetic filtrations.

### 2. `RESEARCH_PAPER.md`
A standalone scientific paper. Someone reading only this document must understand:
- the definitions,
- the main theorems,
- why the results are new,
- what was computed,
- what conjectures remain,
- why this opens a new area.

Do not rely on the code for exposition.

### 3. `ARTICLE.md`
Write it in **Scientific American** style. Make it vivid and concept-driven. Explain why modular Collatz systems can carry hidden topological fingerprints of prime arithmetic. **Do not focus on formal verification or theorem proving infrastructure.** The story is the mathematics.

### 4. Verified algorithm or computational method
Not optional. Provide the correctness statement and implementation.

### 5. `demo.py`
Interactive exploration of the conjecture and theorems.

---

## Final directive

Be bold. Do not merely formalize a graph definition and count edges. Force a theorem that says the topology of modular Collatz preimages is arithmetically organized. If full persistent homology is too heavy to formalize end-to-end, prove the exact arithmetic-to-cycle mechanism in Lean and let the Python experiments reveal the barcode phase diagram. The crucial point is to produce a mathematically certified bridge from congruence classes of primes to topological signatures of Collatz inverse dynamics. That bridge does not currently exist. Build it.

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

Research domain: Speculative
Research mode: prove
