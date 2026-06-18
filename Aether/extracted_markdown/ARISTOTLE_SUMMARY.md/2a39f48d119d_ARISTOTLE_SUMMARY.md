# Summary of changes for run 83014639-b2fa-489c-b9d4-f3608602d169
## The Topology of Argumentation: Why Debates Have Holes

### Research Summary

I established a rigorous mathematical connection between Dung's argumentation frameworks (a foundational model in AI) and algebraic topology, proving that conflict-free sets form a simplicial complex and deriving structural theorems about the interplay between topology and argumentation semantics.

### Lean 4 Proofs (Novelty/ArgumentationTopology.lean)

All 17 theorems compile without `sorry` and use only standard axioms. Key results:

1. **Simplicial Complex Structure** (`conflictFree_subset_closed`): Conflict-free sets are downward closed — the defining property of an abstract simplicial complex.

2. **Self-Attack Puncture** (`self_attack_not_in_conflictFree`, `self_attack_excluded`): Self-attacking arguments are excluded from all conflict-free and admissible sets, creating topological "punctures."

3. **Defense Monotonicity** (`defense_monotone`): If S defends an argument and S ⊆ T, then T also defends it. Defense grows with the defending set.

4. **Direction Invariance** (`conflictFree_reverse_iff`): The conflict-free complex is invariant under reversing all attack directions — the topology captures symmetric conflict structure, not asymmetric power dynamics.

5. **Euler Characteristic Counterexample** (`euler_conjecture_false`): The conjectured formula χ(K) = |preferred extensions| − |grounded size| is **disproved** using a single-argument framework.

6. **Admissible Growth** (`admissible_insert`): Admissible sets grow by inserting defended, compatible arguments — the constructive mechanism for building preferred extensions.

7. **Isolated Vertex Cone** (`isolated_vertex_cone`): Isolated arguments make the complex a cone (contractible), collapsing all topology.

8. **Unattacked Inclusion** (`unattacked_in_complete`): Unattacked arguments must belong to every complete extension.

### Deliverables

- **Novelty/ArgumentationTopology.lean** — 17 formally verified theorems, zero sorries
- **Novelty/ARTICLE.md** — Popular science article (Scientific American style)
- **Novelty/RESEARCH_PAPER.md** — Full research paper with PEGB analysis for main theorems
- **Novelty/FUTURE_DIRECTIONS.md** — 5 research directions including persistent homology, Betti number bounds, weighted frameworks, admissible sub-complex homotopy, and matroid connections
- **Novelty/demo.py** — Numerical demonstrations on 7 example frameworks
- **Novelty/algorithms.py** — Type-hinted Python implementations
- **Novelty/visualize_complex.py** — Matplotlib visualization of Hasse diagrams
- **Novelty/PACKAGE.json** — Complete package with 3 interactive HTML widgets:
  1. Interactive Argumentation Complex Explorer (build frameworks, see topology live)
  2. Direction Invariance Demonstrator (same topology, different semantics)
  3. Self-Attack Puncture Visualizer (toggle self-attacks, watch vertices vanish)

### Key Insight

The **topological-semantic gap**: the conflict-free complex captures symmetric conflict structure (invariant under reversing attacks) while the preferred extensions capture asymmetric power dynamics. Neither determines the other, but each constrains the other. This gap is the central structural insight of this work.