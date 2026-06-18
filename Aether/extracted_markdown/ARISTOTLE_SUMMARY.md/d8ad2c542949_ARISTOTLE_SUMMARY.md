# Summary of changes for run 64a23dc1-297c-47da-8e81-2e84ea4073dc
# Non-Well-Founded Proof Systems: Self-Referential Proofs as Fixed Points

## Novel Mathematical Structure: Guarded Recursive Proof Systems (GRPS)

This research cycle introduces the **circularity gap** — the lattice-theoretic space between the least and greatest fixed points of a monotone derivation operator — as a rigorous mathematical framework for self-referential proofs. The key insight: a proof system is modeled as a monotone operator `derive : Set α → Set α`. Its **least fixed point** (lfp) captures well-founded proofs; its **greatest fixed point** (gfp) captures non-well-founded proofs that may involve circular reasoning. The gap `gfp \ lfp` contains genuinely self-referential proofs.

## Machine-Verified Results (22 theorems, 0 sorries)

All theorems in `Logic/NWFP.lean` are fully proved with standard axioms only (propext, Classical.choice, Quot.sound):

### Core Classification Theorems
1. **safe_not_wfDerivable**: Safe propositions (derivable only when assumed) have no well-founded proofs
2. **selfRef_in_nwfDeriv**: Self-referential propositions have non-well-founded proofs (via coinduction)
3. **selfRef_in_circGap**: Self-referential propositions live in the circularity gap — the central result
4. **circGap_nonempty**: The gap is non-empty for the identity system on any inhabited type

### Structural Results
5. **postFixedPoints_iUnion_closed**: Self-consistent theories are closed under arbitrary unions
6. **selfRef_minimal_witness**: The singleton {a} is the minimal self-consistent theory containing a
7. **liar_no_fixedPoint**: No P ↔ ¬P — the liar paradox is excluded by anti-monotonicity of negation

### System Analysis
8. **constant_circGap_empty**: Constant systems have zero circularity gap (boundary case)
9. **wfDeriv_mono / nwfDeriv_mono**: Both closures are monotone in the derivation operator
10. **circGap_eq_nwf_of_allSafe**: When all elements are safe, the gap equals the entire NWF closure
11. **Approximation sequences**: gfpApprox is antitone, lfpApprox is monotone, and lfpApprox ≤ gfpApprox pointwise

### Key Insight (Consistency Asymmetry)
- Well-founded proofs of safe systems are always consistent (wf_consistent)
- Non-well-founded proofs CAN "prove" absurdity via circular reasoning (nwf_bot_of_bot_selfRef)
- This asymmetry motivates guardedness conditions (see Future Directions)

## Deliverables
- **Logic/NWFP.lean**: 405 lines, 22 theorems, fully verified
- **ARTICLE.md**: Popular-science article (~1500 words) on the mathematics of self-reference
- **RESEARCH_PAPER.md**: Technical paper (~3500 words) with definitions, proofs, PEGB analysis, algorithms
- **FUTURE_DIRECTIONS.md**: 5 research directions including ordinal-stratified guardedness (grand challenge) and categorical generalization
- **demo.py**: 6 interactive demonstrations of proof systems
- **algorithms.py**: Type-hinted implementations of gap computation and classification
- **viz_circularity_gap.py**: Matplotlib visualizations
- **PACKAGE.json**: Complete bundle with 3 interactive HTML widgets (Circularity Gap Explorer, Self-Reference Visualizer, Liar Paradox Exclusion)

## Cross-Connections
- Connects to `classical_not_self_sound_with_paradox` (Logic/ParadoxSelfSoundness): our Theorem 6 (liar_no_fixedPoint) provides the monotonicity-based explanation for why classical self-soundness fails
- Connects to `lawvere_fixed_point` (Algebra/ConsciousnessFixedPoint): the circularity gap generalizes Lawvere's categorical fixed-point construction