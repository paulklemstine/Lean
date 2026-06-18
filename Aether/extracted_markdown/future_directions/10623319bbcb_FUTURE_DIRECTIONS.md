# Future Directions: Time Travel Consistency

## 1. Multi-Loop Causal Networks

The current formalization handles single closed timelike curves and their pairwise composition. A natural extension is to formalize *networks* of interacting causal loops — where the output of one CTC feeds into the input of another, possibly with feedback cycles. This corresponds to a directed graph where each edge carries a contraction mapping, and consistency requires a simultaneous fixed point of the entire network.

The key insight is that a network of n interacting causal loops with individual contraction constants K₁, ..., Kₙ can be modeled as a single contraction on the product space X₁ × ... × Xₙ, but the effective contraction constant depends on the spectral radius of the network's adjacency matrix weighted by the Kᵢ. When this spectral radius is < 1, the whole network has a unique consistent history.

Why now? The composition theorem (`causal_composition_contracting`) and stability result (`consistent_history_stability`) provide the building blocks. The next step is formalizing the graph structure and proving the spectral radius criterion.

## 2. Non-Contractive Consistency via Topological Fixed-Point Theorems

Our formalization of Edelstein's theorem (`novikov_edelstein`) handles strict contractions on compact spaces. The natural next frontier is proving Novikov-type consistency for merely *continuous* causal evolutions on compact convex subsets of Banach spaces, via the Schauder fixed-point theorem. This would formalize the physical expectation that causal consistency holds even when the evolution operator is not contracting — it merely needs to map a compact convex "state space" into itself.

The key insight is that Schauder's theorem (the infinite-dimensional Brouwer theorem) guarantees existence but not uniqueness, corresponding to the physical possibility of multiple self-consistent histories. Formalizing this would require building or connecting to Mathlib's theory of compact operators and the Schauder theorem.

Why now? Edelstein's theorem is proved in the current work, establishing the pattern. Mathlib's coverage of Schauder/Brouwer fixed-point theorems is growing, making this increasingly tractable.

## 3. Quantitative Paradox Resolution: Information-Theoretic Bounds

The grandfather paradox resolution shows that passing from {0,1} to [0,1] creates a fixed point at 1/2. But *how much* information about the initial discrete state is preserved in the continuous resolution? We conjecture that for an affine causal map x ↦ a + bx with |b| < 1, the entropy of the fixed-point distribution (when the initial state has a prior distribution) decreases by exactly log(1-|b|) bits.

The key insight is that the contraction constant K directly controls the information loss: the unique fixed point a/(1-b) is independent of the initial state, so all initial information is lost (entropy → 0). But for *nearly* non-contracting maps (K close to 1), the convergence to the fixed point is slow, and intermediate iterates retain partial information. This connects Novikov's principle to channel capacity in information theory.

Why now? The affine contraction theorem (`affine_contracting`) and convergence rate (`novikov_convergence_rate`) provide the quantitative foundation. Formalizing the information-theoretic connection would bridge our work to coding theory.

## 4. Causal Evolution Semigroups and Temporal Algebra

Define a *causal semigroup*: the set of all contracting self-maps on a fixed metric space, equipped with composition. Our `causal_composition_contracting` shows this is closed under composition. We conjecture that the map sending each causal evolution to its consistent history (fixed point) is a *continuous semigroup homomorphism* from the causal semigroup (with the sup-metric on maps) to the state space.

The key insight is that `consistent_history_stability` already shows Lipschitz dependence of the fixed point on the map. The homomorphism property would say: the consistent history of the composed evolution T₁ ∘ T₂ equals the result of first applying T₂'s resolution and then T₁'s — but this is false in general! The failure of this homomorphism property is precisely what makes time travel nontrivial: the consistent history of a composition is *not* the composition of consistent histories.

Why now? The stability theorem gives the continuity half. Characterizing exactly when the homomorphism property holds (and proving it fails in general) would yield structural theorems about when time travel "commutes."

## 5. Stochastic Causal Evolutions and Quantum Consistency

Extend the framework from deterministic contractions to *random* causal maps — where the evolution is a random operator T_ω and consistency requires E[T_ω(x)] = x or T_ω(x) = x almost surely. This models quantum-mechanical time travel, where the evolution through a CTC involves measurement uncertainty.

The key insight is that the Banach fixed-point theorem extends to random contractions: if E[K_ω] < 1 (the expected contraction constant is less than 1), then there exists a unique consistent history *in expectation*, even if individual realizations T_ω have K_ω ≥ 1. This is a probabilistic Novikov principle: consistency holds on average even when individual histories may be paradoxical.

Why now? The deterministic theory is now complete with full PEGB. The probabilistic extension would connect to Mathlib's measure theory and probability, and to the physics literature on quantum mechanics in the presence of CTCs (Deutsch's model).
