# Future Directions: Dream Logic and Paraconsistent Reasoning

## 1. Bilattice Homomorphisms and Preservation of Paraconsistency

We have formalized Belnap's FOUR as a bounded distributive lattice under the truth ordering and proved that paraconsistency is equivalent to the existence of a designated glut. A natural next step is to formalize the *knowledge ordering* as a second lattice structure (making FOUR a bilattice) and characterize which bilattice homomorphisms preserve paraconsistency.

**Conjecture**: A lattice homomorphism φ : FOUR → L preserves paraconsistency if and only if φ(B) is a glut in L (i.e., both φ(B) and ¬φ(B) are designated in L).

The key insight is that the glut-preservation condition should be both necessary and sufficient, connecting the algebraic structure of bilattice morphisms to the metalogical property of explosion failure. Why now? We have the characterization `paraconsistency_iff_glut` as a foundation — the bilattice homomorphism theorem would be its natural functorial lift.

## 2. Dream Space Completion and Topological Defect Measure

We proved that the finite-or-univ dream space on ℕ is non-topological. Every dream space has a natural "topological completion" obtained by closing the opens under arbitrary unions. The *topological defect* measures how far a dream space is from being a topology.

**Conjecture**: For the finite-or-univ dream space on ℕ, the topological completion is the discrete topology, and the topological defect (measured as the cardinality of the set of non-open sets that become open in the completion) has cardinality 2^ℵ₀.

The key insight is that adding arbitrary unions of finite sets forces all countable sets to be open, and then complements of countable sets must also be added, eventually yielding all subsets. Why now? The `dreamNat` construction and `evens_not_dreamOpen` provide concrete machinery for computing which sets are forced open in each completion step.

## 3. Paraconsistent Valuations as Dream Space Points

There should be a formal correspondence between Belnap valuations on a propositional language and points of an associated dream space. Given a set of propositional variables Var, the space of all Belnap valuations v : Var → FOUR carries a natural dream space structure where opens correspond to "finitely specifiable" truth conditions.

**Conjecture**: The dream space of Belnap valuations on countably many variables is non-topological, and its non-topological points correspond precisely to valuations that assign B (both) to infinitely many variables.

The key insight is that each finite restriction of a valuation gives an open set, but the intersection of infinitely many such opens (specifying B on each variable) may fail to be open — mirroring how dream-like reasoning can maintain local consistency while being globally contradictory. Why now? Both the Belnap algebra and dream space infrastructure are in place; the bridge theorem would unify them.

## 4. Graded Paraconsistency and Fuzzy Dream Spaces

Belnap's FOUR has exactly one glut (B) and one gap (N). A natural generalization replaces the 4-element lattice with a continuous family, where the "degree of contradiction" is a real number in [0,1].

**Conjecture**: For any n ≥ 4, there exists a unique (up to isomorphism) bounded distributive lattice with exactly ⌊n/2⌋ − 1 gluts that satisfies the De Morgan laws, and this lattice embeds into the dream space of fuzzy subsets of ℝ with the finite-support dream topology.

The key insight is that the number of gluts in a De Morgan algebra is controlled by the width of the lattice between F and T, and this width determines the "capacity for contradiction" of the logic. Why now? The `glut_iff_B` and `gap_iff_N` characterization theorems provide the template for counting gluts in larger algebras.

## 5. Non-Monotone Belief Revision as Dream Space Dynamics

Dream spaces support a natural notion of "belief revision" where the collection of opens changes over time — opens can be added (learning) or removed (forgetting/retraction). This models dream-like reasoning where previously established facts can be retracted.

**Conjecture**: The category of dream spaces with "revision morphisms" (maps that preserve finite intersections but may fail to preserve unions) is equivalent to the category of Belnap-valued Kripke frames with non-monotone accessibility relations.

The key insight is that removing an open set from a dream space corresponds to retracting a belief, and this retraction is captured in the Kripke frame by a non-monotone step (moving to a world where fewer propositions hold). Why now? The dream space definition is in place, and Kripke frames for modal logic are well-developed in Mathlib — the bridge between them would connect paraconsistent logic to modal logic in a formally verified setting.
