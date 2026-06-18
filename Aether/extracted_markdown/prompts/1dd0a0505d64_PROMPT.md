
            ## PHASE A: LEAN 4 ONLY — DOING THE MATH

            You are a world-class mathematician. Your ONLY job in this cycle is
to produce **new Lean 4 code that extends the frontier of mathematics**.

            ### DELIVERABLES (strict — only this):
            1. **lean files (count chosen by the Plan)**
            2. **2-4 theorems with correct proofs (sorry = 0 on main results)**
            3. **Brief proof sketches** as `-- !-- comment -- !--` blocks (1-2 sentences each)
            4. **A FUTURE_DIRECTIONS.md file** listing 3-5 testable, falsifiable
               conjectures as a freeform narrative (NOT a form). Each direction MUST
               include a "The key insight is..." sentence and a "Why now?" justification.
               This file drives the next research cycle — make it count.

            ### DO NOT OUTPUT (Phase B handles these — if your work passes quality bar):
            - NO `ARTICLE.md`
            - NO `RESEARCH_PAPER.md`
            - NO `demo.py` / `algorithms.py`
            - NO HTML widgets
            - NO `PACKAGE.json`
            - NO prose for human readers (except FUTURE_DIRECTIONS.md)

            ### WHY THIS NARROW:
            The Lean 4 file IS the deliverable. A self-contained Lean file with
            3-5 world-class theorems is worth more than 30K characters of prose
            about trivial results. Focus 100% of your compute on the math.
            If your work is genuinely world-class, the packaging step is dispatched
            automatically and cheaply.

            ### CATALOG SYNTHESIS (required — read the catalog context below):
            The Catalog Context and Recent Discoveries sections list existing theorems
            already proven in this project. You MUST analyze these and combine concepts
            from the catalog with the research direction above. Specifically:

            1. **Identify relevant catalog theorems** — Which existing results connect
               to your research direction? Cite them by name in your proof sketches.
            2. **Build on catalog foundations** — Your theorems should EXTEND or
               GENERALIZE catalog results, not reprove them from scratch. Use `import`
               and reference existing definitions and lemmas where possible.
            3. **Combine concepts across domains** — The most valuable theorems connect
               ideas from different catalog domains (e.g., applying algebraic structures
               to topological problems, or using combinatorial arguments in number theory).
               Look for cross-domain connections in the catalog context.
            4. **Avoid duplication** — Check the catalog context before proving. If a
               similar result already exists, extend it rather than reproving it.


## Concept

**Title**: The edge bound |E| ≤ 3g − 3 we proved here is for *unmarked* stable tropical cur
**Domain**: Novelty
**Mathematical framing**: # Future Directions: Tropical Moduli Curves

## 1. Tropical Marked Curves and the Full Dimension Formula

The edge bound |E| ≤ 3g − 3 we proved here is for *unmarked* stable tropical curves (no
marked points / leaves).  The natural generalization is the marked case: a stable tropical
curve of genus g with n marked points (modeled as half-edges or degree-1 vertices exempt
from the valence-3 stability condition) should satisfy |E| ≤ 3g − 3 + n, and this bound
is again achieved by trivalent graphs.

The key insight is that each marked point contributes exactly one additional degree of
freedom (its position on the edge it subdivides), and the stability condition becomes
2g(v) − 2 + val(v) > 0 at each vertex, where g(v) is the vertex genus.

**Why now?**  Our `CombType` abstraction already captures degree sequences with the
handshaking constraint.  Extending it with a partition of vertices into "internal" (degree ≥ 3)
and "marked" (degree 1) would require only a mild generalization of the same arithmetic
arguments, using the marked vertex count n in place of the stability lower bound.

## 2. Euler Characteristic and Connected Components

We defined genus as g = |E| − |V| + 1, which is correct only for connected graphs.
For disconnected graphs, the first Betti number is β₁ = |E| − |V| + c, where c is
the number of connected components.  Formalizing the connected-component count c and
proving β₁ ≥ 0 for arbitrary (possibly disconnected) graphs would require either
formalizing spanning forests or an inductive argument on edge deletion.

The key insight is that β₁ = 0 characterizes *forests* (acyclic graphs), generalizing
our genus-0-iff-tree result.  This connects directly to Mathlib's `SimpleGraph.IsAcyclic`
and would provide a bridge between our abstract `CombType` formulation and Mathlib's
graph theory library.

**Why now?**  Mathlib has `SimpleGraph.IsTree.card_edgeFinset` proving |E| + 1 = |V| for
trees, and `SimpleGraph.IsAcyclic` / `SimpleGraph.Connected`.  A formal proof that
connected + |E| = |V| − 1 implies tree (the converse of `card_edgeFinset`) would close
an important gap in the library and serve as the foundation for cycle rank computations.

## 3. Tropical Balancing Condition in ℤ^n

A tropical curve embedded in ℝ^n carries integer slope vectors on each edge.  The
*balancing condition* at each vertex states that the sum of outgoing primitive integer
direction vectors (weighted by edge multiplicities) equals zero in ℤ^n.  Formalizing
this requires defining:
- An embedding: edges → ℤ^n (primitive direction vectors)
- Edge multiplicities: edges → ℕ
- The balancing condition: at each vertex, ∑ w_e · d_e = 0 over incident edges

The key insight is that the balancing condition is what makes a metric graph into a
*tropical subvariety* of ℝ^n, analogous to the Cauchy–Riemann equations making a
smooth map into a holomorphic one.  This is the bridge between combinatorial tropical
curves and tropical algebraic geometry.

**Why now?**  The `CombType` structure already tracks vertex-edge incidence via degrees.
Adding direction vectors and multiplicities is a natural extension, and the balancing
condition is a finite linear algebra statement over ℤ that Lean can verify directly.

## 4. Contraction Morphisms and the Poset of Combinatorial Types

The combinatorial types of stable tropical curves of genus g form a partially ordered
set under *edge contraction*: contracting an edge e of a graph Γ yields a graph Γ/e
with one fewer edge and (unless e is a loop) one fewer vertex.  The genus is preserved
under contraction.

The key insight is that this poset structure directly mirrors the face poset of the
cone complex M_g^trop: contracting an edge corresponds to taking a codimension-1 face
of a cone.  Proving that contraction preserves genus and stability, and that the poset
is graded by the number of edges (= cone dimension), would formalize the combinatorial
structure of the tropical moduli space.

**Why now?**  Our `CombType` abstraction needs to be extended with an explicit edge
contraction operation.  The key lemma — genus is preserved under contraction — is a
simple Euler characteristic argument: contracting a non-loop edge decreases both |E|
and |V| by 1, so g = |E| − |V| + 1 is unchanged.

## 5. Tropical Torelli Map and the Metric Graph Laplacian

The tropical Torelli map sends a tropical curve to its *tropical Jacobian*, defined
via the Laplacian of the metric graph.  For a graph Γ with edge lengths, the
Laplacian L is a |V| × |V| matrix with L_{ij} = −1/ℓ(ij) for adjacent vertices
and L_{ii} = Σ_j 1/ℓ(ij).  The tropical Jacobian is the torus ℝ^g / Im(L^†),
where L^† is a generalized inverse.

The key insight is that the tropical Torelli map is *not* injective for g ≥ 3
(unlike the classical Torelli theorem), and the failure of injectivity is
controlled by the combinatorial type of the graph.  Formalizing the Laplacian
and the rank of the period matrix would make this failure precise.

**Why now?**  The `TropicalCurve` structure already carries edge lengths.  Defining
the graph Laplacian requires Mathlib's matrix API (`Matrix.of`), and computing its
rank is a finite-dimensional linear algebra problem.  The key obstruction is that
Mathlib's matrix theory over ℝ is well-developed, making this tractable.

**Concept description**: # Future Directions: Tropical Moduli Curves

## 1. Tropical Marked Curves and the Full Dimension Formula

The edge bound |E| ≤ 3g − 3 we proved here is for *unmarked* stable tropical curves (no
marked points / leaves).  The natural generalization is the marked case: a stable tropical
curve of genus g with n marked points (modeled as half-edges or degree-1 vertices exempt
from the valence-3 stability condition) should satisfy |E| ≤ 3g − 3 + n, and this bound
is again achieved by trivalent graphs.

The key insight is that each marked point contributes exactly one additional degree of
freedom (its position on the edge it subdivides), and the stability condition becomes
2g(v) − 2 + val(v) > 0 at each vertex, where g(v) is the vertex genus.

**Why now?**  Our `CombType` abstraction already captures degree sequences with the
handshaking constraint.  Extending it with a partition of vertices into "internal" (degree ≥ 3)
and "marked" (degree 1) would require only a mild generalization of the same arithmetic
arguments, using the marked vertex count n in place of the stability lower bound.

## 2. Euler Characteristic and Connected Components

We defined genus as g = |E| − |V| + 1, which is correct only for connected graphs.
For disconnected graphs, the first Betti number is β₁ = |E| − |V| + c, where c is
the number of connected components.  Formalizing the connected-component count c and
proving β₁ ≥ 0 for arbitrary (possibly disconnected) graphs would require either
formalizing spanning forests or an inductive argument on edge deletion.

The key insight is that β₁ = 0 characterizes *forests* (acyclic graphs), generalizing
our genus-0-iff-tree result.  This connects directly to Mathlib's `SimpleGraph.IsAcyclic`
and would provide a bridge between our abstract `CombType` formulation and Mathlib's
graph theory library.

**Why now?**  Mathlib has `SimpleGraph.IsTree.card_edgeFinset` proving |E| + 1 = |V| for
trees, and `SimpleGraph.IsAcyclic` / `SimpleGraph.Connected`.  A formal proof that
connected + |E| = |V| − 1 implies tree (the converse of `card_edgeFinset`) would close
an important gap in the library and serve as the foundation for cycle rank computations.

## 3. Tropical Balancing Condition in ℤ^n

A tropical curve embedded in ℝ^n carries integer slope vectors on each edge.  The
*balancing condition* at each vertex states that the sum of outgoing primitive integer
direction vectors (weighted by edge multiplicities) equals zero in ℤ^n.  Formalizing
this requires defining:
- An embedding: edges → ℤ^n (primitive direction vectors)
- Edge multiplicities: edges → ℕ
- The balancing condition: at each vertex, ∑ w_e · d_e = 0 over incident edges

The key insight is that the balancing condition is what makes a metric graph into a
*tropical subvariety* of ℝ^n, analogous to the Cauchy–Riemann equations making a
smooth map into a holomorphic one.  This is the bridge between combinatorial tropical
curves and tropical algebraic geometry.

**Why now?**  The `CombType` structure already tracks vertex-edge incidence via degrees.
Adding direction vectors and multiplicities is a natural extension, and the balancing
condition is a finite linear algebra statement over ℤ that Lean can verify directly.

## 4. Contraction Morphisms and the Poset of Combinatorial Types

The combinatorial types of stable tropical curves of genus g form a partially ordered
set under *edge contraction*: contracting an edge e of a graph Γ yields a graph Γ/e
with one fewer edge and (unless e is a loop) one fewer vertex.  The genus is preserved
under contraction.

The key insight is that this poset structure directly mirrors the face poset of the
cone complex M_g^trop: contracting an edge corresponds to taking a codimension-1 face
of a cone.  Proving that contraction preserves genus and stability, and that the poset
is graded by the number of edges (= cone dimension), would formalize the combinatorial
structure of the tropical moduli space.

**Why now?**  Our `CombType` abstraction needs to be extended with an explicit edge
contraction operation.  The key lemma — genus is preserved under contraction — is a
simple Euler characteristic argument: contracting a non-loop edge decreases both |E|
and |V| by 1, so g = |E| − |V| + 1 is unchanged.

## 5. Tropical Torelli Map and the Metric Graph Laplacian

The tropical Torelli map sends a tropical curve to its *tropical Jacobian*, defined
via the Laplacian of the metric graph.  For a graph Γ with edge lengths, the
Laplacian L is a |V| × |V| matrix with L_{ij} = −1/ℓ(ij) for adjacent vertices
and L_{ii} = Σ_j 1/ℓ(ij).  The tropical Jacobian is the torus ℝ^g / Im(L^†),
where L^† is a generalized inverse.

The key insight is that the tropical Torelli map is *not* injective for g ≥ 3
(unlike the classical Torelli theorem), and the failure of injectivity is
controlled by the combinatorial type of the graph.  Formalizing the Laplacian
and the rank of the period matrix would make this failure precise.

**Why now?**  The `TropicalCurve` structure already carries edge lengths.  Defining
the graph Laplacian requires Mathlib's matrix API (`Matrix.of`), and computing its
rank is a finite-dimensional linear algebra problem.  The key obstruction is that
Mathlib's matrix theory over ℝ is well-developed, making this tractable.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Novelty
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v7 Depth Requirements — Structured Proofs with Completeness Gates

You are producing Lean 4 code on the mathematical frontier. Your output must
be COMPILABLE and your proofs must be COMPLETE. A single correct proof of a
non-trivial result is worth more than 5 theorems with `sorry`.

### STEP 1: THEOREM DECLARATIONS (required — before any code)

List every theorem you intend to prove. For each, state:
- **Name**: The Lean declaration name
- **Statement**: One-sentence informal statement
- **Status**: `proved` | `conjecture` | `proved_with_lemma_sorry`
- **Why non-trivial**: One sentence on the key mathematical insight

Example:
1. `cantorPairing_surjective`: Cantor pairing is surjective — proved — constructive inverse
2. `cantorPairing_injective`: Cantor pairing is injective — proved — diagonal argument
3. `cantorPairing_bijection`: Cantor pairing is a bijection — proved_with_lemma_sorry — follows from 1+2

### STEP 2: PROVE THEOREMS (completeness gate)

Every theorem declared as `proved` MUST have a complete, compiling Lean proof.
No `sorry` on the main result. If you cannot complete a proof, change its status
to `conjecture` or `proved_with_lemma_sorry` and explain why.

For `proved_with_lemma_sorry`:
- The theorem statement must be complete (no sorry in the statement)
- `sorry` is allowed ONLY in supporting lemmas, never the main proof
- A comment must explain what the sorry replaces and why it's deferred

For your BEST theorem, also provide:
- A generalization or strengthening (can use sorry if proving would take too long)
- A boundary case or counterexample showing where the result fails

### STEP 3: Anti-patterns (reject these)

These tactics indicate trivial proofs:
- `native_decide` / `decide` / `norm_num` / `rfl` — unless genuinely proving a numeric fact
- `simp only []` with no simp set specified
- `sorry` on any theorem declared as `proved`

`omega`, `linarith`, and `Aesop` are fine for supporting lemmas.
`sorry` is fine for conjectures and generalizations.

### STEP 4: Novelty

Your theorems must be genuinely new. If a statement appears in a textbook,
generalize it. If you cannot formalize a concept rigorously, pick a different topic.

### Output format

Your output must include:
1. `.lean` files with the proofs (structured as declared in Step 1)
2. `FUTURE_DIRECTIONS.md` with 3-5 research conjectures extending the work

Both are required. Missing FUTURE_DIRECTIONS.md = automatic quality penalty.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
