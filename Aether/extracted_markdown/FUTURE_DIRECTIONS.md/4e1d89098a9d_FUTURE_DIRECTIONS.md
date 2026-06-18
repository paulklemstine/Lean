# Future Directions: Triadic Hardness Transport

## 1. Tropical Data-Processing Inequalities as Security Transport

**Hypothesis**: The data-processing inequality (DPI) in information theory has a tropical analogue: if a channel map decreases tropical KL divergence, then security guarantees propagate through the channel. This would give a *functorial security pipeline* where any processing step that respects tropical contraction automatically preserves security bounds.

**Proof Strategy**: 
- Formalize tropical channels as maps between tropical probability simplices.
- Prove that tropical KL divergence is non-increasing under tropical-linear maps (tropical DPI).
- Compose with `tropical_kl_security_bound` to obtain automatic security propagation.
- The key technical challenge is defining the correct notion of "tropical channel" that admits a clean DPI.

**Cross-domain Connections**: Links information geometry, tropical convexity, and post-quantum cryptography. A tropical DPI would unify Shannon's classical DPI with lattice-based security reductions.

---

## 2. Categorical Semantics of Hardness Reductions

**Hypothesis**: The `TheoryMorphism` framework is the object-level data of a category `HardnessTransport` whose objects are `TheorySpec`s and whose morphisms are `TheoryMorphism`s. This category admits:
- A monoidal structure (tensor product of theories)
- A functorial embedding of classical complexity-class reductions
- A notion of "hardness amplification" as endomorphisms with c > 1

**Proof Strategy**:
- Prove that `TheoryMorphism.comp` is associative (up to equality of the map, c, a fields).
- Construct identity morphisms (c = 1, a = 0, map = id).
- Verify the category axioms and explore enrichment over the ordered monoid (ℝ, *, ≤).
- Connect to the existing formalization of category theory in Mathlib.

**Cross-domain Connections**: This would connect reduction theory from computational complexity to categorical logic, potentially yielding new insights into the structure of NP-hardness reductions through algebraic invariants.

---

## 3. Reverse Transport: Cryptographic Hardness Implies Learning Impossibility

**Hypothesis**: The affine morphism chain is invertible under additional convexity assumptions. If the morphisms are *bi-Lipschitz* (both upper and lower affine bounds), then cryptographic hardness assumptions (e.g., LWE, SVP) yield provable lower bounds on learning complexity.

**Proof Strategy**:
- Define `BiTheoryMorphism` with both `A.inv x ≤ c * B.inv (map x) + a` and `B.inv (map x) ≤ c' * A.inv x + a'`.
- Prove that composition preserves the bi-Lipschitz property.
- Instantiate: if LWE is hard (security parameter ≥ λ), then any learner that could break the corresponding learning problem must have sample complexity ≥ f(λ).

**Cross-domain Connections**: This is the learning-theoretic analogue of cryptographic hardness assumptions. It would formalize the folklore intuition that "if you can't break crypto, you can't learn certain functions efficiently."

---

## 4. Entropy/Height Dualities

**Hypothesis**: There is a formal duality between arithmetic height of algebraic numbers and entropy of their Galois orbits. Specifically, the Weil height h(α) of an algebraic number α equals the entropy of the uniform distribution on conjugates of α, normalized by degree.

**Proof Strategy**:
- Formalize the connection between Mahler measure and entropy (this is the Lehmer-Smyth direction).
- Show that `key_dimension_lower_bound_from_height` can be reinterpreted as an entropy lower bound.
- Compose with tropical KL bounds to get: height ≥ H implies entropy ≥ H implies security ≥ f(H).

**Cross-domain Connections**: Links algebraic number theory (heights, Lehmer's conjecture) to information theory (entropy) and cryptography (key generation from algebraic objects). Could yield new constructions of pseudorandom generators from algebraic number fields.

---

## 5. Tropical Mutual Information as a Universal Hardness Invariant

**Hypothesis**: Define tropical mutual information I_trop(X; Y) = D_trop(P_{XY} || P_X ⊗ P_Y) using tropical KL divergence. This quantity serves as a universal measure of "hardness correlation" between two domains: if I_trop(Learning; Security) > 0, then hardness in Learning implies hardness in Security, with the transport constant determined by I_trop.

**Proof Strategy**:
- Define tropical joint distributions and marginals in the existing `TropicalInformation` framework.
- Prove basic properties: non-negativity, chain rule, data-processing inequality.
- Show that `TheoryMorphism` existence between two theories implies I_trop > 0 for their invariant distributions.
- Use this to derive new transfer theorems "for free" from information-theoretic principles.

**Cross-domain Connections**: Unifies the entire triadic framework under a single information-theoretic invariant. Would connect to rate-distortion theory (how much hardness can be "compressed" across domain boundaries) and channel capacity (what is the maximum rate of hardness transport between two theories).

---

## Implementation Priorities

| Direction | Difficulty | Impact | Dependencies |
|-----------|-----------|--------|--------------|
| 1. Tropical DPI | Medium | High | tropical_kl_security_bound |
| 2. Categorical semantics | Low-Medium | Medium | TheoryMorphism.comp |
| 3. Reverse transport | High | Very High | BiTheoryMorphism (new) |
| 4. Entropy/height | High | High | Mahler measure in Mathlib |
| 5. Tropical MI | Medium | Very High | Direction 1 |

**Recommended order**: 2 → 1 → 5 → 4 → 3

Direction 2 is foundational and relatively easy — it validates the categorical structure. Direction 1 unlocks Direction 5, which provides the universal framework. Directions 3 and 4 are the deepest mathematically and should build on the infrastructure from 1, 2, and 5.
