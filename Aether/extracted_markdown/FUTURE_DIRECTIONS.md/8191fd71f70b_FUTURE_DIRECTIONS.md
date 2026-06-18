# Future Directions

## 1. Semiring-Valued Dependency Propagation

**Goal:** Generalize the level function from $\mathbb{N}$ to an arbitrary (complete, idempotent) semiring, enabling weighted dependency metrics such as proof cost, trust scores, compilation time, and complexity bounds.

**Hypothesis:** The locality theorem holds for any function $f : V \to S$ defined by $f(v) = \bigoplus_{u \in \text{pred}(v)} g(f(u))$ over a complete idempotent semiring $(S, \oplus, \otimes, \mathbf{0}, \mathbf{1})$, where $g$ is the "edge weight" operation. The key requirement is that $\oplus$ and $g$ respect the well-founded structure.

**Proof Strategy:** Replace `Finset.sup'` with a general `Finset.fold` over the semiring operation. The locality lemma generalizes directly: if the operands are unchanged, the fold result is unchanged. The well-founded induction argument is identical.

**Cross-Domain Impact:**
- *Build systems:* propagate compilation time estimates, not just dependency depth
- *Trust metrics:* propagate confidence scores through theorem dependency chains
- *Network analysis:* compute aggregated flow/cost metrics incrementally

## 2. Certified Incremental Fixed-Point Theorem for Monotone Dataflow Frameworks

**Goal:** Prove that for monotone functions on finite lattices, the least fixed point is unchanged outside the forward cone of a local operator modification. This subsumes the DAG level theorem as a special case and connects to abstract interpretation.

**Hypothesis:** Let $(L, \sqsubseteq)$ be a finite lattice and $F : (V \to L) \to (V \to L)$ a monotone operator with $F(x)(v)$ depending only on $\{x(u) : u \in \text{pred}(v)\}$. If $F$ is modified to $F'$ with $F(x)(v) = F'(x)(v)$ for all $v$ outside a set $C$ (closed under successor), then $\text{lfp}(F)$ and $\text{lfp}(F')$ agree on $V \setminus C$.

**Proof Strategy:** Use Kleene's fixed-point theorem on finite lattices. Show by induction on the Kleene iteration that each iterate agrees outside $C$. Since the lattice is finite, the iteration terminates, and the fixed points agree.

**Applications:**
- Dataflow analysis in compilers (reaching definitions, live variables)
- Abstract interpretation frameworks with certified update guarantees
- Model checking with incremental state-space exploration

## 3. Executable Recomputation Kernel with Verified Complexity Bounds

**Goal:** Extract a verified executable function `incrementalRecompute` and prove that its time complexity is $O(|\text{cone}| + |E_{\text{cone}}|)$, i.e., proportional to the size of the affected region rather than the whole graph.

**Concrete Deliverable:**
```
def incrementalRecompute (oldLevels : V → ℕ) (pred' : PredFn V)
    (new : V) (cone : Finset V) : V → ℕ
```
with a proof that (1) the output matches global recomputation, and (2) the function inspects only vertices in `cone` and their predecessors.

**Proof Strategy:**
- Define the function by iteration over a topological sort of the cone
- Prove termination using the finite cone size
- Prove correctness by combining the locality theorem with the standard level computation correctness
- Bound the work using `Finset.card` inequalities

**Impact:** This transforms the theorem from a semantic guarantee into an algorithmic one, directly usable in verified build systems and proof checkers.

## 4. Theorem-Dependency Observer Interface and Proof-Carrying Updates

**Goal:** Build a formal framework connecting the locality result to proof-code representations, enabling a "proof-carrying update" protocol: when a theorem is added to a database, generate a certificate that downstream proofs remain valid.

**Design:**
- Define an `Observer` type: a function that extracts data from a dependency graph
- Prove that observers restricted to the complement of the forward cone are invariant under localized updates
- Connect to the Lawvere fixed-point / proof-coding perspective: theorem updates as code transformations that preserve observer outputs

**Concrete Theorem Target:**
```
theorem observer_invariant (obs : Observer V) (hsupp : obs.support ⊆ Cᶜ) :
    obs.eval predOld = obs.eval predNew
```

**Applications:**
- Incremental proof checking for large formal libraries (e.g., Mathlib)
- Certified theorem database maintenance with minimal revalidation
- Proof-carrying software updates where downstream guarantees are preserved

## 5. Causal Semantics of Dependency Systems via Alexandrov Topology

**Goal:** Interpret the forward cone as the Alexandrov future in a finite causal poset, and prove that the locality theorem is an instance of a general "causal support" principle analogous to finite-domain causality in physics and concurrency theory.

**Hypothesis:** The DAG $(V, \text{Reaches})$ is a finite causal set (a finite poset). The Alexandrov topology has open sets that are exactly the upward-closed sets. The level function is "causal" in the sense that $\ell(v)$ depends only on the causal past of $v$. The locality theorem becomes: perturbations localized to the causal future of $n$ do not affect the causal complement.

**Proof Strategy:**
- Define the Alexandrov topology on the Reaches poset
- Show that the support of the perturbation (where pred changes) is an open set
- Prove a general causal propagation theorem: any "causal function" (depending only on the past) is invariant under perturbations supported in the complementary closed set

**Vision:** This creates a bridge between discrete dependency theory and continuous causal structures, opening connections to:
- Event structures in concurrency theory
- Causal sets in quantum gravity
- Sheaf theory on finite posets
- Information flow in distributed systems

The goal is not just a theorem, but a new conceptual vocabulary: **causal semantics of theorem databases**, where knowledge propagation obeys the same structural laws as physical causation.

---

## Summary

| # | Direction | Difficulty | Impact | Timeline |
|---|-----------|-----------|--------|----------|
| 1 | Semiring generalization | Medium | High | 2-4 weeks |
| 2 | Fixed-point theorem | Hard | Very high | 1-3 months |
| 3 | Executable kernel | Medium | High (engineering) | 2-4 weeks |
| 4 | Observer interface | Medium-Hard | High (formal methods) | 1-2 months |
| 5 | Causal semantics | Hard | Breakthrough | 3-6 months |

Each direction is independently valuable and contributes to the overarching goal: a certified theory of local semantic change in dependency systems.
