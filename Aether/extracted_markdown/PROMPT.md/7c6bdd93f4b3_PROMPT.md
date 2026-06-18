
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


## Concept

**Title**: **Causal Integration Algebra** — a rigorous Lean 4 fo
**Domain**: Computation
**Mathematical framing**: # Future Directions: Causal Integration Algebra

## What We Built

This cycle established the **Causal Integration Algebra** — a rigorous Lean 4 formalization of Integrated Information Theory (IIT) that identifies Φ with the minimum cut of a weighted directed graph. We proved 8 theorems sorry-free:

- **Nonnegativity** (`phi_nonneg`): Φ ≥ 0 always
- **Symmetrization invariance** (`crossInfo_symmetrize`, `phi_symmetrize`): directed and symmetrized systems have identical Φ
- **Monotonicity** (`phi_mono_of_weight_le`): increasing edge weights cannot decrease Φ
- **Scaling** (`phi_scale`): Φ(cC) = cΦ(C) for c ≥ 0
- **Disconnection** (`phi_zero_of_disconnected`): systems with a zero-cut bipartition have Φ = 0
- **Upper bound** (`phi_le_totalWeight`): Φ never exceeds total edge weight

The framework connects IIT to classical graph theory via a clean algebraic interface.

---

### Direction 1: Spectral Lower Bound via Fiedler Value

For symmetric causal systems, the algebraic connectivity λ₂(L) of the graph Laplacian should provide a polynomial-time computable lower bound on Φ. The key insight is that the Rayleigh quotient characterization of λ₂ directly relates to the minimum bisection problem — any indicator vector for a bipartition gives a Rayleigh quotient that upper-bounds λ₂, and the minimum over all such vectors is precisely Φ (up to normalization). This would import Cheeger-type inequalities into integration theory.

**Conjecture**: λ₂(L) ≤ Φ(C) ≤ n · λ₂(L) / 4 for symmetric systems on n vertices.

**Why now?** Our `phi_symmetrize` theorem shows that every directed system can be reduced to a symmetric one without changing Φ. This means spectral methods (which require symmetric matrices) apply to the full generality of directed causal systems. The Laplacian formalization in Lean would build on our `CausalSystem` structure by extracting the degree matrix and adjacency matrix.

**Test**: Compute both Φ (brute-force) and λ₂ (eigenvalue) for all connected weighted graphs on 4–5 vertices with integer weights 1–3.

---

### Direction 2: Supermodularity of Cross-Information

The cross-information function may exhibit supermodularity properties on the lattice of bipartitions, which would give tight bounds on Φ via the Lovász extension and submodular optimization.

The key insight is that cross-information, viewed as a set function on the power set of vertices, should satisfy crossInfo(A∪B) + crossInfo(A∩B) ≥ crossInfo(A) + crossInfo(B) for nested pairs — this is because edges counted in both A and B cuts are counted at least as much in the union/intersection cuts. If true, submodular minimization algorithms (polynomial time) would compute Φ exactly.

**Conjecture**: The function S ↦ crossInfo(C, S) is submodular on the lattice of subsets of Fin n.

**Why now?** Our `crossInfo_mono` and `crossInfo_scale` theorems establish that crossInfo behaves well under the two simplest lattice operations (ordering and scaling). Submodularity is the natural next structural property. Lean's `Finset` API has strong support for set operations needed for the proof.

**Test**: Verify the submodularity inequality for all pairs of subsets on graphs with 4–5 vertices.

---

### Direction 3: K-Partition Refinement and Integration Spectrum

Generalizing from bipartitions to k-partitions creates an "integration spectrum" Φ_k that captures multi-way decomposition. The minimum k-way cut gives richer structural information than the minimum bisection.

The key insight is that Φ₂ = Φ (our current definition) is just the first level of a hierarchy. Defining Φ_k as the minimum total inter-part flow over all k-partitions, we should have Φ₂ ≤ Φ₃ ≤ ... ≤ Φ_n, with equality Φ_k = Φ_n exactly when the system cannot be decomposed into fewer than n parts without losing information. The rate of growth of this spectrum encodes the "complexity" of the system's causal structure.

**Conjecture**: For a strongly connected system on n vertices, Φ_k is strictly increasing for k = 2, ..., n, and Φ_n = totalWeight(C).

**Why now?** Our `phi_le_totalWeight` theorem provides the natural upper bound. The k-partition generalization reuses our `crossInfo` infrastructure with minimal new definitions. This connects to the multiway cut problem in combinatorial optimization.

**Test**: Compute the full spectrum {Φ₂, ..., Φ_n} for random strongly connected systems on n = 4, 5.

---

### Direction 4: Duality Between Integration and Exclusion

There should be a duality between the minimum cut (integration) and the maximum flow (exclusion) in causal systems, analogous to the max-flow min-cut theorem.

The key insight is that IIT's "exclusion postulate" — which says only the partition achieving the minimum information partition (MIP) matters — can be formalized as a dual optimization problem. The max-flow min-cut theorem would then say that the maximum "coherent information flow" through the system equals Φ. This would give Φ a constructive interpretation: it measures the bottleneck capacity of the system's information processing.

**Conjecture**: For symmetric causal systems, Φ(C) equals the maximum concurrent flow value, where each vertex pair (i,j) demands flow equal to w(i,j).

**Why now?** Our framework already identifies Φ with the minimum cut. The max-flow min-cut duality for undirected graphs is well-established in combinatorics, and `phi_symmetrize` lets us reduce to the symmetric case. Formalizing this would import network flow theory into IIT.

**Test**: For small graphs (n = 3, 4), verify that the LP relaxation of the concurrent flow problem has optimal value equal to Φ.

---

### Direction 5: Compositional Integration via Direct Sums

When two causal systems are composed (direct sum with inter-system edges), how does Φ of the composite relate to Φ of the components? A precise composition formula would solve the "combination problem" — how consciousness of parts relates to consciousness of wholes.

The key insight is that for the direct sum C₁ ⊕ C₂ (block-diagonal weight matrix), our `phi_zero_of_disconnected` already shows Φ = 0. But when inter-system edges are added, Φ should grow monotonically (by `phi_mono_of_weight_le`) and satisfy Φ(C₁ ⊕ C₂ + E) ≥ min(Φ(C₁), Φ(C₂), cross(E)) where cross(E) is the minimum cut of the inter-system edges alone.

**Conjecture**: Φ(C₁ ⊕ C₂ + E) = min(Φ(C₁) + cross₁(E), Φ(C₂) + cross₂(E), cross(E)) where crossᵢ(E) is the contribution of inter-system edges to cuts within component i.

**Why now?** Our monotonicity and disconnection theorems provide the boundary conditions. The formula would follow from analyzing how the minimum cut of the composite system must either (a) separate within C₁, (b) separate within C₂, or (c) separate between C₁ and C₂.

**Test**: Construct pairs of small systems (n₁ = n₂ = 2, 3) with varying inter-system edge weights and verify the formula.

**Concept description**: # Future Directions: Causal Integration Algebra

## What We Built

This cycle established the **Causal Integration Algebra** — a rigorous Lean 4 formalization of Integrated Information Theory (IIT) that identifies Φ with the minimum cut of a weighted directed graph. We proved 8 theorems sorry-free:

- **Nonnegativity** (`phi_nonneg`): Φ ≥ 0 always
- **Symmetrization invariance** (`crossInfo_symmetrize`, `phi_symmetrize`): directed and symmetrized systems have identical Φ
- **Monotonicity** (`phi_mono_of_weight_le`): increasing edge weights cannot decrease Φ
- **Scaling** (`phi_scale`): Φ(cC) = cΦ(C) for c ≥ 0
- **Disconnection** (`phi_zero_of_disconnected`): systems with a zero-cut bipartition have Φ = 0
- **Upper bound** (`phi_le_totalWeight`): Φ never exceeds total edge weight

The framework connects IIT to classical graph theory via a clean algebraic interface.

---

### Direction 1: Spectral Lower Bound via Fiedler Value

For symmetric causal systems, the algebraic connectivity λ₂(L) of the graph Laplacian should provide a polynomial-time computable lower bound on Φ. The key insight is that the Rayleigh quotient characterization of λ₂ directly relates to the minimum bisection problem — any indicator vector for a bipartition gives a Rayleigh quotient that upper-bounds λ₂, and the minimum over all such vectors is precisely Φ (up to normalization). This would import Cheeger-type inequalities into integration theory.

**Conjecture**: λ₂(L) ≤ Φ(C) ≤ n · λ₂(L) / 4 for symmetric systems on n vertices.

**Why now?** Our `phi_symmetrize` theorem shows that every directed system can be reduced to a symmetric one without changing Φ. This means spectral methods (which require symmetric matrices) apply to the full generality of directed causal systems. The Laplacian formalization in Lean would build on our `CausalSystem` structure by extracting the degree matrix and adjacency matrix.

**Test**: Compute both Φ (brute-force) and λ₂ (eigenvalue) for all connected weighted graphs on 4–5 vertices with integer weights 1–3.

---

### Direction 2: Supermodularity of Cross-Information

The cross-information function may exhibit supermodularity properties on the lattice of bipartitions, which would give tight bounds on Φ via the Lovász extension and submodular optimization.

The key insight is that cross-information, viewed as a set function on the power set of vertices, should satisfy crossInfo(A∪B) + crossInfo(A∩B) ≥ crossInfo(A) + crossInfo(B) for nested pairs — this is because edges counted in both A and B cuts are counted at least as much in the union/intersection cuts. If true, submodular minimization algorithms (polynomial time) would compute Φ exactly.

**Conjecture**: The function S ↦ crossInfo(C, S) is submodular on the lattice of subsets of Fin n.

**Why now?** Our `crossInfo_mono` and `crossInfo_scale` theorems establish that crossInfo behaves well under the two simplest lattice operations (ordering and scaling). Submodularity is the natural next structural property. Lean's `Finset` API has strong support for set operations needed for the proof.

**Test**: Verify the submodularity inequality for all pairs of subsets on graphs with 4–5 vertices.

---

### Direction 3: K-Partition Refinement and Integration Spectrum

Generalizing from bipartitions to k-partitions creates an "integration spectrum" Φ_k that captures multi-way decomposition. The minimum k-way cut gives richer structural information than the minimum bisection.

The key insight is that Φ₂ = Φ (our current definition) is just the first level of a hierarchy. Defining Φ_k as the minimum total inter-part flow over all k-partitions, we should have Φ₂ ≤ Φ₃ ≤ ... ≤ Φ_n, with equality Φ_k = Φ_n exactly when the system cannot be decomposed into fewer than n parts without losing information. The rate of growth of this spectrum encodes the "complexity" of the system's causal structure.

**Conjecture**: For a strongly connected system on n vertices, Φ_k is strictly increasing for k = 2, ..., n, and Φ_n = totalWeight(C).

**Why now?** Our `phi_le_totalWeight` theorem provides the natural upper bound. The k-partition generalization reuses our `crossInfo` infrastructure with minimal new definitions. This connects to the multiway cut problem in combinatorial optimization.

**Test**: Compute the full spectrum {Φ₂, ..., Φ_n} for random strongly connected systems on n = 4, 5.

---

### Direction 4: Duality Between Integration and Exclusion

There should be a duality between the minimum cut (integration) and the maximum flow (exclusion) in causal systems, analogous to the max-flow min-cut theorem.

The key insight is that IIT's "exclusion postulate" — which says only the partition achieving the minimum information partition (MIP) matters — can be formalized as a dual optimization problem. The max-flow min-cut theorem would then say that the maximum "coherent information flow" through the system equals Φ. This would give Φ a constructive interpretation: it measures the bottleneck capacity of the system's information processing.

**Conjecture**: For symmetric causal systems, Φ(C) equals the maximum concurrent flow value, where each vertex pair (i,j) demands flow equal to w(i,j).

**Why now?** Our framework already identifies Φ with the minimum cut. The max-flow min-cut duality for undirected graphs is well-established in combinatorics, and `phi_symmetrize` lets us reduce to the symmetric case. Formalizing this would import network flow theory into IIT.

**Test**: For small graphs (n = 3, 4), verify that the LP relaxation of the concurrent flow problem has optimal value equal to Φ.

---

### Direction 5: Compositional Integration via Direct Sums

When two causal systems are composed (direct sum with inter-system edges), how does Φ of the composite relate to Φ of the components? A precise composition formula would solve the "combination problem" — how consciousness of parts relates to consciousness of wholes.

The key insight is that for the direct sum C₁ ⊕ C₂ (block-diagonal weight matrix), our `phi_zero_of_disconnected` already shows Φ = 0. But when inter-system edges are added, Φ should grow monotonically (by `phi_mono_of_weight_le`) and satisfy Φ(C₁ ⊕ C₂ + E) ≥ min(Φ(C₁), Φ(C₂), cross(E)) where cross(E) is the minimum cut of the inter-system edges alone.

**Conjecture**: Φ(C₁ ⊕ C₂ + E) = min(Φ(C₁) + cross₁(E), Φ(C₂) + cross₂(E), cross(E)) where crossᵢ(E) is the contribution of inter-system edges to cuts within component i.

**Why now?** Our monotonicity and disconnection theorems provide the boundary conditions. The formula would follow from analyzing how the minimum cut of the composite system must either (a) separate within C₁, (b) separate within C₂, or (c) separate between C₁ and C₂.

**Test**: Construct pairs of small systems (n₁ = n₂ = 2, 3) with varying inter-system edge weights and verify the formula.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Computation
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v6 Depth Requirements — Correct Proofs First

You are working on the frontier of mathematics. Your goal is to produce
Lean 4 code that COMPILES and PROVES non-trivial results. A correct proof
of one good theorem is worth more than 5 theorems with `sorry`.

### STEP 1: BRIEF PLAN (2-3 lines)

Before writing Lean code, state:
- **Strategy**: New structure (Grothendieck) OR extend existing result (Cauchy)
- **Theorems**: List the 2-4 theorems you will prove (one sentence each)
- **Why non-trivial**: One sentence explaining the key insight

### STEP 2: PROVE THEOREMS (correctness > completeness)

Write Lean 4 proofs that COMPILE. Every theorem should have:
- A complete proof (no `sorry` for the main result)
- A brief proof sketch as a comment (1-2 sentences)
- An `example` block showing the theorem in action (if practical)

For your BEST theorem, also provide:
- A generalization or strengthening (can use `sorry` if proving it would take too long)
- A boundary case or counterexample showing where the result fails

You do NOT need full PEGB on every theorem. Deep PEGB on your best theorem
and solid proofs on the rest is the target.

### STEP 3: Anti-patterns (avoid these)

These tactics indicate trivial proofs that add no value:
- `native_decide` / `decide` / `norm_num` / `rfl` — unless genuinely proving a numeric fact
- `simp only []` with no simp set specified
- `sorry` on the main theorem statement

`omega`, `linarith`, and `Aesop` are fine for supporting lemmas.
`sorry` is fine for generalizations and boundary cases.

### STEP 4: Novelty

Your theorems should be genuinely new. If a statement appears in a textbook,
generalize it. If you cannot formalize a concept rigorously, pick a different topic.

### Output format

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
