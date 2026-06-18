# Summary of changes for run 95ad381e-8ad0-43ae-b53e-1c39ed24a262
## Research Cycle: Dialectical Algebras — A Novel Framework for Paradox-Tolerant Logic

### Novel Mathematical Structure: Dialectical Algebra
Introduced **dialectical algebras** (`Novelty/DialecticalAlgebra.lean`), a new algebraic structure consisting of a set with two partial orderings (truth and knowledge), an involutive negation, and bounded elements. The negation reverses truth order and preserves knowledge order. The knowledge-extremal elements are negation fixpoints, and the structure is non-trivial (the extremes are distinct).

**Canonical example**: Belnap's four-valued logic BVal = {T, F, B, N} with truth ordering F ≤ B,N ≤ T and knowledge ordering N ≤ T,F ≤ B.

### Key Theorems (all sorry-free, machine-verified)

1. **Fixpoint Classification** (`belnap_fixpoint_classification`): The negation fixpoints of BVal are exactly {B, N} — the knowledge-extremal elements.

2. **Fixpoints = Knowledge Extremals** (`belnap_fixpoints_are_knowledge_extremal`): A value is a negation fixpoint iff it is knowledge-maximal or knowledge-minimal. This connects truth-theoretic (fixpoint) and information-theoretic (extremal) properties.

3. **Fixpoint Sublattice Theorem** (`fixpoint_closed_under_kMeet`, `fixpoint_closed_under_kJoin`): Negation fixpoints are closed under knowledge-meet and knowledge-join, forming a sublattice.

4. **Fixpoint Truth Non-Closure** (`fixpoint_not_closed_under_tMeet`, `fixpoint_not_closed_under_tJoin`): Fixpoints are NOT closed under truth operations. tMeet(B,N) = F and tJoin(B,N) = T, which are not fixpoints. This asymmetry is the algebraic core of why paradoxes are info-coherent but truth-incoherent.

5. **Dialectical Collapse Theorem** (`dialectical_collapse`): Any dialectical algebra satisfying excluded middle is impossible (leads to contradiction). This gives an algebraic proof that paradox tolerance requires non-classical logic.

6. **Rank = Paradox Count** (`rank_eq_paradox_count`): The dialectical rank (sum of per-sentence ranks) exactly equals the number of paradoxical sentences.

7. **Rank Zero ↔ Classical** (`rank_zero_iff_classical`): A theory has rank 0 iff every sentence is T or F.

8. **Paradox Independence** (`paradox_independence_classification`): Independent paradoxical sentences must be one B and one N — a glut and a gap.

9. **Liar is Paradoxical** (`liar_is_paradoxical`): Any Liar sentence (truth = neg(truth)) has a fixpoint value.

10. **Self-Soundness Characterization** (`self_sound_iff_in_upper`): A theory is self-sound iff provable sentences have values in {T, B}. B is at-least-true, so paradoxes don't break soundness.

11. **Knowledge Upward Closure** (`at_least_true_know_upward`): The at-least-true set is upward-closed in knowledge order — gaining information preserves soundness.

12. **Product Representation** (`belnap_bool_pair_iso_left/right`, `neg_in_product`, `knowledge_order_product`): BVal ≅ Bool × Bool, with negation = swap and knowledge order = componentwise ≤.

13. **Dialectical Completeness** (`dialectical_completeness`): Every paradox spectrum (nB values B, nN values N, nB+nN ≤ n) is realizable.

### Deliverables
- **Lean 4 proofs**: `Novelty/DialecticalAlgebra.lean` — 588 lines, 17+ non-trivial theorems, zero sorry
- **ARTICLE.md**: Popular-science article on the ideas (no mention of formal verification)
- **RESEARCH_PAPER.md**: Full research paper with definitions, theorems, PEGB analysis
- **FUTURE_DIRECTIONS.md**: 5 directions including continuous dialectical algebras and error-correction connections
- **demo.py**: Interactive demonstration of all key results
- **algorithms.py**: Type-hinted implementations of all algorithms
- **visualize_bilattice.py**, **visualize_rank.py**: Matplotlib visualizations
- **PACKAGE.json**: Full artifact bundle with 2 interactive HTML widgets (Bilattice Explorer and Rank Calculator)