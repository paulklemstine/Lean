# Future Directions: Non-Well-Founded Proof Systems

## Synthesis

This research cycle established the **circularity gap** — the lattice-theoretic space between the least and greatest fixed points of a monotone derivation operator — as a rigorous mathematical home for self-referential proofs. The key discovery is the **safe classification theorem**: self-referential propositions (those derivable from their own singleton assumption but not from nothing) are precisely the canonical inhabitants of this gap. This connects lattice-theoretic fixed-point theory (Knaster-Tarski) to proof-theoretic questions about self-reference in a way that is, to our knowledge, novel.

The most promising cross-domain connection emerges from the relationship between our framework and the catalog entry `classical_not_self_sound_with_paradox` (Logic/ParadoxSelfSoundness.lean). That result shows that classical theories cannot prove their own soundness; our framework provides the complementary positive result that *non-well-founded* proofs CAN establish self-soundness, precisely because self-referential propositions live in the circularity gap. The paraconsistent setting of the catalog entry and the monotone-operator setting of our framework are two different relaxations of classical logic that enable self-reference — understanding their precise relationship is the highest-priority direction below.

The gap structure also connects to `lawvere_fixed_point` (Algebra/ConsciousnessFixedPoint.lean), which establishes fixed-point theorems in a categorical setting. Our circularity gap can be seen as the "excess" of the greatest fixed point over Lawvere's point-surjection-induced fixed point. Formalizing this connection would bridge our lattice-theoretic framework with categorical logic.

Direction 1 (Ordinal-Stratified Guardedness) has the highest breakthrough potential: it would provide a constructive criterion for when non-well-founded proofs are consistent, resolving the key open question of this cycle.

---

### Direction 1: Ordinal-Stratified Guardedness for Consistent Non-Well-Founded Proofs

**Conjecture**: For a monotone operator F on Set α with a distinguished element ⊥ (absurdity), define the *guarded greatest fixed point* as gfp_guard(F) = ⋂_{β < α} F^β(⊤) where the iteration is indexed by ordinals and uses the guardedness condition: an element enters the iteration at stage β only if its self-referential dependencies all entered at stages < β. Then gfp_guard(F) satisfies: (a) gfp_guard(F) ⊆ gfp(F), (b) lfp(F) ⊆ gfp_guard(F), and (c) if ⊥ is safe, then ⊥ ∉ gfp_guard(F).

**Test**: Formalize the ordinal-indexed descending iteration using Mathlib's `Ordinal` type. Prove property (a) — that the guarded gfp is between lfp and gfp. Attempt property (c) — that guardedness excludes safe absurdity. Test computationally on finite systems: for all monotone operators on Set(Fin 4), verify that the guarded gfp excludes ⊥ whenever ⊥ is safe.

**Impact**: If true, this provides a constructive consistency criterion for non-well-founded proofs — resolving the main open problem identified in this cycle. If false, the failure mode reveals exactly which self-referential structures break consistency even with guardedness, which would be equally informative.

**Catalog References**: `Logic/NWFP.lean` (this cycle), `FINAL/Logic/ParadoxSelfSoundness.lean`

**Proof Strategy**: Define `guardedGfpApprox : Ordinal → Set α` by transfinite recursion. Use the well-ordering of ordinals to show the sequence stabilizes. For property (c), prove that if ⊥ enters at stage β, then ⊥ must have entered at some stage γ < β (by the guardedness condition and safety), giving an infinite descending chain of ordinals — contradiction.

**Domain Bridges**: Logic (self-reference) <-> Order Theory (ordinal stratification) <-> Computer Science (guarded recursion in type theory)

**Lineage**: Direct extension of Theorems safe_not_wfDerivable, nwf_bot_of_bot_selfRef from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: The Circularity Gap as a Topological Space

**Conjecture**: The circularity gap C(F) = gfp(F) \ lfp(F), equipped with the subspace topology inherited from the product topology on Set α (viewing Set α ≅ α → Prop ≅ α → Bool), is a Scott domain. Self-referential elements correspond to compact elements of this domain, and the circularity depth (number of iterations in the gfp approximation) corresponds to the Scott-continuous rank function.

**Test**: For F = identity on Set(Fin n), compute the Scott topology on the gap (which is all of Fin n). Verify that the compact elements are exactly the self-referential elements (all elements, in this case). For a non-trivial system, find elements at different circularity depths and verify they form a chain in the Scott ordering.

**Impact**: If true, this gives the circularity gap a topological structure that makes it a *domain* in the sense of domain theory — connecting self-referential proofs to denotational semantics. The circularity depth would be a topological invariant.

**Catalog References**: `Logic/NWFP.lean`, `Bridges/ProofStoneCechDynamics.lean` (fixed_point_unique_under_theory_separation)

**Proof Strategy**: Define the Scott topology on Set α using Mathlib's topology machinery. Show that C(F) with the subspace topology satisfies the domain axioms (directed completeness, algebraicity). Use the approximation sequences to construct the basis of compact elements.

**Domain Bridges**: Logic (circularity gap) <-> Topology (Scott domains) <-> Computer Science (denotational semantics)

**Lineage**: Builds on approximation sequence theorems (gfpApprox_antitone, lfpApprox_monotone) and the topological fixed-point work in Bridges/ProofStoneCechDynamics.

**Ambition**: grand_challenge

---

### Direction 3: Computational Classification of Finite Circularity Gaps

**Conjecture**: For monotone operators on Set(Fin n), the cardinality of the circularity gap satisfies |C(F)| ∈ {0} ∪ [⌈n/2⌉, n]. That is, the gap is either empty or contains at least half the elements. There is a "gap threshold" phenomenon: small perturbations of an operator near the boundary between zero-gap and non-zero-gap systems cause the gap to jump from 0 to ≥ n/2.

**Test**: Enumerate all monotone operators on Set(Fin 3) and Set(Fin 4) (feasible computationally). For each, compute |C(F)|. Plot the distribution. Check whether any gaps have size strictly between 0 and ⌈n/2⌉.

**Impact**: If true, this is a phase-transition result: self-referential reasoning either doesn't exist or is pervasive. This would have implications for logical systems: a proof system either has no circularity or has extensive circularity, with no middle ground.

**Catalog References**: `Logic/NWFP.lean`

**Proof Strategy**: For the lower bound, show that if a ∈ C(F), then the orbit of a under derive generates at least ⌈n/2⌉ elements in C(F). For the enumeration, exploit the monotonicity constraint to prune the search space (a monotone operator on P(Fin n) is determined by its values on antichains).

**Domain Bridges**: Logic (circularity) <-> Combinatorics (monotone Boolean functions) <-> Statistical Physics (phase transitions)

**Lineage**: Builds on circGap_nonempty and the constant_circGap_empty boundary case.

**Ambition**: extension

---

### Direction 4: Categorical Generalization — The Circularity Functor

**Conjecture**: The assignment F ↦ C(F) = gfp(F) \ lfp(F) extends to a functor from the category of monotone endomorphisms on complete lattices (with natural transformations as morphisms) to the category of sets. This functor preserves colimits (unions of operator families yield unions of circularity gaps).

**Test**: Verify functoriality: if η : F → G is a natural transformation (pointwise F ≤ G), then C(F) ⊆ C(G). This follows from wfDeriv_mono and nwfDeriv_mono, but the gap containment requires both lfp and gfp to move in the same direction, which they do by monotonicity. Verify colimit preservation on 2-3 explicit examples.

**Impact**: A categorical framework for circularity would connect to Lawvere's fixed-point theorem and provide tools for studying self-reference in arbitrary categories (not just Set). This is the natural home for the connection between our work and `lawvere_fixed_point`.

**Catalog References**: `Logic/NWFP.lean`, `Algebra/ConsciousnessFixedPoint.lean` (lawvere_fixed_point)

**Proof Strategy**: Use wfDeriv_mono and nwfDeriv_mono to establish the monotonicity of C on morphisms. For colimit preservation, use the fact that lfp commutes with filtered colimits of ω-continuous operators (if applicable) and gfp commutes with filtered limits.

**Domain Bridges**: Logic (self-reference) <-> Category Theory (functors, limits) <-> Algebra (lattice homomorphisms)

**Lineage**: Builds on wfDeriv_mono, nwfDeriv_mono, and the Lawvere connection.

**Ambition**: extension

---

### Direction 5: Paraconsistent Circularity — Self-Sound Non-Well-Founded Proofs

**Conjecture**: In a paraconsistent proof system (where the derivation operator uses Belnap's four-valued logic instead of classical logic), the circularity gap contains elements that are *both true and false* (Belnap value B). These dialetheia in the gap correspond to "productive paradoxes" — self-referential proofs that are simultaneously true and false but do not cause triviality (explosion). The gap in the paraconsistent setting has strictly richer structure than in the classical setting.

**Test**: Extend ProofSystem to use BelnapVal-valued derivation (derive : Set α → α → BelnapVal). Compute the circularity gap for a proof system containing both a liar-like fixed point and a truth-teller-like fixed point. Verify that the liar lives in the gap with value B while the truth-teller lives in the gap with value T.

**Impact**: This directly extends `classical_not_self_sound_with_paradox`. If successful, it would show that non-well-founded proofs in paraconsistent settings can be *self-sound* — the theory can prove its own soundness because paradoxical elements are valued B (at-least-true), satisfying the soundness predicate.

**Catalog References**: `Logic/NWFP.lean`, `Catalog/Logic/ParadoxSelfSoundness.lean` (classical_not_self_sound_with_paradox, self_sound_construction)

**Proof Strategy**: Define a BelnapVal-valued ProofSystem. The lattice structure on α → BelnapVal is a complete lattice (pointwise ordering). Apply the same lfp/gfp framework. Show that the Belnap negation (which IS a fixed-point-admitting operation, unlike classical negation) produces gap elements with value B.

**Domain Bridges**: Logic (self-reference, paraconsistency) <-> Algebra (Belnap lattices) <-> Philosophy (dialetheia)

**Lineage**: Builds on liar_no_fixedPoint (which shows classical negation fails) and the paraconsistent framework in ParadoxSelfSoundness.lean.

**Ambition**: grand_challenge
