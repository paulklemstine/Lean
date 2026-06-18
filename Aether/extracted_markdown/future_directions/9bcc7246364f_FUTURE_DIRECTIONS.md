# Future Directions: Non-Abelian Arithmetic Phase Classification

## Synthesis

The results in this work — the order profile invariant, the D₄/Q₈ counterexample, and the p-perfectness theory — establish a foundation for a comprehensive obstruction theory of abelianization-detectable torsion. The five directions below form a coherent research program: Direction 1 (spectral sequence formalization) provides the theoretical backbone, Direction 2 (supersolvable completeness) tests the boundaries of the theory, Direction 3 (derived abelianization) seeks the "right" generalization, Direction 4 (Iwasawa-theoretic analog) bridges to number theory, and Direction 5 (computational classification) provides the empirical base for all conjectures.

Each direction is designed to be independently valuable while contributing to the whole. The grand challenges (Directions 3 and 4) are deliberately ambitious — they would represent paradigm shifts if achieved — while the extensions (Directions 1, 2, 5) build directly on verified results and have clear next steps.

---

## Direction 1: Lyndon-Hochschild-Serre Spectral Sequence Formalization

**Conjecture:** For the group extension 1 → [G,G] → G → G^ab → 1, the E² page of the LHS spectral sequence has E²_{s,t} = H_s(G^ab; H_t([G,G]; ℤ)). When [G,G] is p-perfect, the p-primary part of E²_{0,1} vanishes, and the edge homomorphism H_1(G; ℤ/p) → H_1(G^ab; ℤ/p) is an isomorphism.

**Test:** Verify computationally for all groups of order ≤ 48 using GAP's group homology package. For each group G:
1. Compute H_1(G; ℤ/p) and H_1(G^ab; ℤ/p) for all primes p dividing |G|.
2. Check whether they agree when [G,G]^ab has no p-torsion.
3. If any counterexample is found, the conjecture is disproved.

**Impact:** Would provide the first machine-verified formalization of a spectral sequence collapse theorem, establishing infrastructure for future formalization of algebraic topology in Lean.

**Catalog References:** `Pythagorean/AbelianizationPhase.lean` (isPPerfect_of_coprime_order, orderProfileAt_mulEquiv)

**Proof Strategy:** Formalize the LHS spectral sequence as a filtered chain complex in Lean. Prove collapse at E² under the p-perfectness hypothesis by showing the relevant differentials vanish. Use the five lemma to conclude the edge homomorphism is an isomorphism.

**Domain Bridges:** Algebraic topology ↔ formal verification ↔ homological algebra

**Lineage:** Extends `isPPerfect_of_coprime_order` from single-prime coprimality to the full spectral sequence collapse.

**Ambition:** solid_extension

---

## Direction 2: Supersolvable Abelianization Completeness

**Conjecture:** For finite supersolvable groups G with p ∤ |[G,G]^ab|, the p-primary order profile of G is completely determined by G^ab. Specifically, for all n ∈ ℕ: OrderProfile_G(p^n) depends only on G^ab and p.

**Test:**
1. Enumerate all supersolvable groups of order ≤ 120 using GAP.
2. For each pair of supersolvable groups with isomorphic abelianizations, check whether their p-primary order profiles agree whenever p ∤ |[G,G]^ab|.
3. The conjecture predicts agreement in all cases.

**Disproof protocol:** Find a supersolvable group G with p ∤ |[G,G]^ab| but OrderProfile_G(p^k) ≠ OrderProfile_{G^ab}(p^k) for some k. The smallest candidate is p = 3 for S₄ (but S₄ is not supersolvable, so look at semidirect products Z/p ⋊ Z/q).

**Impact:** Would establish the precise boundary of abelianization sufficiency for the most well-behaved class of non-abelian groups.

**Catalog References:** `Pythagorean/AbelianizationPhase.lean` (orderProfileAt_prod, involutionCount_odd_of_odd_order, D4_Q8_disagree_at_2)

**Proof Strategy:** For supersolvable groups, the composition series has cyclic factors. Use induction on the composition length, applying the product formula at each step. The key lemma: for a normal subgroup N ◁ G with G/N cyclic and N^ab having no p-torsion, OrderProfile_{G}(p^k) = OrderProfile_{G/N}(p^k) · |N|.

**Domain Bridges:** Group theory ↔ number theory (Sylow theory, solvability)

**Lineage:** Directly tests the limits of `D4_Q8_not_isomorphic` — asks "is D₄/Q₈ the only type of failure?"

**Ambition:** solid_extension

---

## Direction 3: Derived Abelianization Functor

**Conjecture:** There exists a functorial construction Ab_n : FinGrp → AbGrp (a "derived abelianization") such that:
1. Ab₁(G) = G^ab
2. Ab_n(G) captures all torsion information in H_k(G; ℤ) for k ≤ n
3. Ab_n is computable in time polynomial in |G| for fixed n

Specifically, we conjecture that Ab₂(G) ≅ G^ab ⊕ H₂([G,G]; ℤ)^{G^ab} captures all information lost by ordinary abelianization at the second homological level.

**Test:**
1. Compute Ab₂(G) for all groups of order ≤ 32.
2. Check whether Ab₂ distinguishes D₄ from Q₈ (it should, since H₂(Q₈; ℤ) ≅ Z/2 while H₂(D₄; ℤ) = 0).
3. Check whether Ab₂ is a complete invariant for groups of order ≤ 16.

**Impact:** Would provide a systematic procedure for recovering all information lost by abelianization, analogous to how the Jones polynomial recovers knot information lost by the Alexander polynomial. This would be a paradigm shift in computational group theory.

**Catalog References:** `Pythagorean/AbelianizationPhase.lean` (ArithmeticTorsionInvariant, PhaseClass)

**Proof Strategy:** Define Ab₂(G) using the universal coefficient theorem and the LHS spectral sequence. Show functoriality by naturality of the spectral sequence. Computability follows from the Smith normal form algorithm for group homology.

**Domain Bridges:** Group theory ↔ algebraic topology ↔ category theory ↔ computational algebra

**Lineage:** Extends PhaseClass from an ad hoc construction to a systematic functorial framework.

**Ambition:** grand_challenge

---

## Direction 4: Non-Abelian Iwasawa Theory via Order Profiles

**Conjecture:** For a Z_p-extension K_∞/K with non-abelian Galois group G = Gal(K_∞/K), the Iwasawa μ-invariant of the p-primary part of the class group tower is determined by the order profile of G at p-powers, provided [G,G] is p-perfect.

Specifically, if G₁ and G₂ are two pro-p groups with the same order profile at all p-powers AND both have p-perfect commutator subgroups, then the associated Iwasawa modules have the same μ-invariant.

**Test:**
1. Compute order profiles for Galois groups of cyclotomic Z_p-extensions for small p (p = 2, 3, 5) and small base fields.
2. Compare μ-invariants with order profile predictions.
3. The conjecture predicts equality when the commutator is p-perfect.

**Impact:** Would establish the first connection between finite group torsion invariants and Iwasawa theory, potentially providing new computational approaches to the Iwasawa main conjecture for non-abelian extensions.

**Catalog References:** `Pythagorean/AbelianizationPhase.lean` (isPPerfect_of_same_profile, orderProfileAt_determines_order)

**Proof Strategy:** Use the control theorem for Iwasawa modules to relate the μ-invariant to the p-torsion in H₁(G; Z_p). When [G,G] is p-perfect, apply the spectral sequence collapse (Direction 1) to reduce to the abelian case, where the Iwasawa main conjecture gives the result.

**Domain Bridges:** Number theory ↔ group theory ↔ p-adic analysis ↔ algebraic K-theory

**Lineage:** Extends isPPerfect_of_coprime_order to the pro-p setting, connecting to the deepest open problems in algebraic number theory.

**Ambition:** grand_challenge

---

## Direction 5: Complete Computational Classification up to Order 64

**Conjecture:** The order profile, combined with the abelianization type, is a complete isomorphism invariant for all groups of order ≤ 64, except for at most 5 pairs of non-isomorphic groups with identical invariants.

**Test:**
1. Use GAP to enumerate all groups of order ≤ 64 (267 groups total for orders 1-64).
2. Compute the full order profile and abelianization for each group.
3. Identify pairs with identical (abelianization, order profile) but non-isomorphic structure.
4. The conjecture predicts at most 5 such pairs.

**Impact:** Would provide the first complete census of the discriminating power of the order profile invariant, establishing empirical bounds on its completeness.

**Catalog References:** `Pythagorean/AbelianizationPhase.lean` (orderProfile_not_complete_invariant, D4_Q8_unique_distinction)

**Proof Strategy:** Primarily computational. Use the GAP SmallGroups library for enumeration. For each identified "collision pair," investigate whether adding the center size, derived length, or automorphism group order resolves the collision.

**Domain Bridges:** Computational algebra ↔ group theory ↔ data science (classification algorithms)

**Lineage:** Directly extends the D₄/Q₈ analysis to a systematic survey of all small groups.

**Ambition:** solid_extension
