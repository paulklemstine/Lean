# Future Directions: Generator Complexity of Presheaves

## Synthesis

The results in this cycle establish the foundational quantitative theory of presheaf generator complexity: an upper bound from fiber sizes (Theorem 1), an exact formula for discrete categories (Theorem 2), and a strict compression criterion from restriction redundancy (Theorem 3). Together, these reveal a clean dichotomy: morphisms are the sole mechanism enabling compression below the brute-force bound.

The five directions below form a coherent program to extend this foundation. Direction 1 (Strict Dichotomy) completes the characterization by proving that restriction-closure is the *only* obstruction. Direction 2 (Probe-Generator Bridge) connects two previously independent quantitative theories. Direction 3 (Categorical Products) builds the algebraic calculus of complexity under categorical operations. Direction 4 (Sheaf Compression) extends from presheaves to sheaves, where covering conditions introduce new phenomena. Direction 5 (Algorithmic Complexity) attacks the computational question: can g(F) be computed efficiently?

Each direction is grounded in proven catalog results and can be tested computationally before formal proof attempts.

---

## Direction 1: The Strict Dichotomy Conjecture

**Conjecture:** For any finite category C and finite-valued presheaf F : C^op → Type,
$$g(F) = \sum_Y |F(\mathrm{op}\, Y)| \iff \neg\,\mathrm{RestrictionRedundant}(F).$$

**Test:** Enumerate all categories with ≤ 5 objects, ≤ 20 morphisms, and fiber sizes ≤ 4. For each presheaf:
1. Compute g(F) by exhaustive search.
2. Check whether RestrictionRedundant(F) holds.
3. Verify the biconditional.
A single counterexample — a presheaf with g(F) < ∑|F| but no restriction-redundant element — disproves the conjecture.

**Impact:** If true, this would establish restriction-closure as the complete compression theory for presheaves: no hidden mechanisms exist. It would also prove the greedy algorithm is optimal for one-step redundancy elimination.

**Catalog References:**
- `Pythagorean/ProbeComplexity/GeneratorComplexity.lean` — `exists_smaller_cover_of_restriction_redundancy` (forward direction), `discrete_no_restriction_redundancy` (discrete case)

**Proof Strategy:** The forward direction follows from Theorem 3 (contrapositive). For the reverse, show: if no element is restriction-redundant, then every generating family must contain a distinct generator for each fiber element. Key step: prove that without restriction-redundancy, any generator (Y, x) can only contribute x at object Y via the identity morphism, making the injection argument from Theorem 2 applicable even in the non-discrete case.

**Domain Bridges:** Analogous to the question in compressed sensing: "is coherence the only obstruction to sparse recovery?" And in database theory: "is functional dependency the only source of schema redundancy?"

**Lineage:** Builds directly on Theorems 2 and 3 from this cycle.

**Ambition:** Grand challenge — would establish a complete characterization theorem.

---

## Direction 2: Probe-Generator Complexity Bridge

**Conjecture:** For a finite category C with probe complexity π(C) and any finite-valued presheaf F with max fiber size m:
$$g(F) \le \pi(C) \cdot m^{\pi(C)}$$
More precisely, if P is a separating probe family of size k, then g(F) ≤ k · m^k.

**Test:** For categories with ≤ 6 objects:
1. Compute π(C) using the existing probe complexity framework.
2. For presheaves with varying fiber sizes, compute g(F).
3. Check whether g(F) ≤ π(C) · m^{π(C)}.
A counterexample would require g(F) to exceed this bound.

**Impact:** Would connect two independent quantitative theories (probe complexity from Defs.lean/Theorems.lean and generator complexity from GeneratorComplexity.lean) into a unified framework. Would provide a bound on generator complexity controlled by the intrinsic "measurement cost" of the category.

**Catalog References:**
- `Pythagorean/ProbeComplexity/Theorems.lean` — `probeComplexity`, `card_hom_le_profile_capacity`
- `Pythagorean/ProbeComplexity/GeneratorComplexity.lean` — `repFinGen_bound_n_mul_m`

**Proof Strategy:** A separating probe family P of size k allows distinguishing morphisms via profiles. Each fiber element at object Y is determined by its "profile" — its images under restriction to probe objects. The profile space has size ≤ m^k, giving at most k · m^k effective generators across all probe objects.

**Domain Bridges:** In compressed sensing: the number of measurements needed (probes) bounds the dictionary size needed for recovery. In sensor networks: the number of monitoring points constrains the state codebook.

**Lineage:** Extends both the probe complexity framework and the generator complexity framework.

**Ambition:** Solid extension — bridges existing catalog components.

---

## Direction 3: Generator Complexity Under Categorical Operations

**Conjecture:** For presheaves F on C and G on D:
1. **Product bound:** $g(F \times G) \le g(F) \cdot g(G)$ (on the product category C × D)
2. **Coproduct bound:** $g(F + G) = g(F) + g(G)$ (on the coproduct/disjoint union)
3. **Pullback inequality:** If H : C → D is a functor, then $g(F \circ H^{op}) \le g(F)$ for any presheaf F on D.

**Test:** For pairs of small categories (≤ 4 objects each):
1. Construct product/coproduct categories.
2. Compute g(F), g(G), and g(F ⊗ G) for random presheaves.
3. Verify the inequalities.

**Impact:** Would establish an "algebra" of generator complexity, analogous to the calculus of entropy in information theory. The product formula would be the categorical analogue of H(X × Y) ≤ H(X) + H(Y).

**Catalog References:**
- `Pythagorean/ProbeComplexity/GeneratorComplexity.lean` — `RepFinGenLE`, `GeneratingFamily`
- `Pythagorean/ProbeComplexity/CoproductSubadditivity.lean` — existing subadditivity results
- `Pythagorean/ProbeComplexity/ProductFormula.lean` — product dimension results

**Proof Strategy:** For the product bound: given generators S for F and T for G, construct generators S × T for F × G. For the coproduct: generators at component C cannot help component D (analogous to the discrete case). For the pullback: pullback of generators via H.

**Domain Bridges:** In coding theory: capacity of product channels. In database theory: join complexity bounds.

**Lineage:** Builds on the product formula and coproduct subadditivity results in the catalog.

**Ambition:** Solid extension — algebraic structure of the invariant.

---

## Direction 4: Sheaf Compression on Sites

**Conjecture:** For a sheaf F on a finite site (C, J) with Grothendieck topology J:
$$g_{\mathrm{sheaf}}(F) \le g_{\mathrm{presheaf}}(F)$$
and there exist sites where the inequality is strict. That is, the sheaf condition provides additional compression beyond what restriction-redundancy alone gives.

**Test:** Construct small sites with non-trivial covering sieves:
1. Compute g(F) treating F as a presheaf.
2. Identify elements that are determined by the sheaf condition (gluing) but not by single restrictions.
3. Check if these provide additional compression.
A positive example would show g_sheaf < g_presheaf.

**Impact:** Would extend the entire generator complexity framework from presheaves to sheaves, opening applications to algebraic geometry and topos theory. The sheaf condition (gluing) is a fundamentally different source of redundancy from single-morphism restriction.

**Catalog References:**
- `Pythagorean/ProbeComplexity/ToposCompressionDefs.lean` — compression definitions in topos context
- `Bridges/Catalog/Pythagorean/ProbeComplexity/SheafCompressionFiniteSite.lean` — sheaf compression on finite sites

**Proof Strategy:** The inequality follows from the fact that every generating family for the presheaf is also generating for the sheaf. For strict inequality, construct a site where gluing provides compression: a presheaf element at an object Y is determined by compatible elements on a covering sieve {U_i → Y}, where each U_i element is already generated, but Y's element is not a single restriction from any one U_i.

**Domain Bridges:** In distributed computing: local data that collectively determines global state via consistency conditions (analogous to gluing). In quantum information: local density matrices constraining global states.

**Lineage:** Extends from presheaves to sheaves, connecting to the topos compression work.

**Ambition:** Grand challenge — fundamentally new compression mechanism.

---

## Direction 5: Computational Complexity of g(F)

**Conjecture:** Computing g(F) exactly is NP-hard (by reduction from Set Cover), but there exists a polynomial-time O(log n)-approximation algorithm.

**Test:**
1. Formalize the reduction from Set Cover to minimum generating family.
2. Implement a randomized LP-rounding algorithm for the relaxed problem.
3. Compare approximation quality against exact solutions on instances with ≤ 20 total fiber elements.
If the LP relaxation consistently achieves ratios within O(log n), this supports the conjecture.

**Impact:** Would place presheaf generator complexity in the landscape of computational complexity theory, providing both hardness lower bounds and practical algorithms for large instances.

**Catalog References:**
- `Pythagorean/ProbeComplexity/GeneratorComplexity.lean` — `RepFinGenLE`, `GeneratingFamily`

**Proof Strategy:** The reduction maps a Set Cover instance (universe U, sets S_1, ..., S_k) to a category where objects are elements of U plus a "source" object, with morphisms encoding set membership. The LP relaxation assigns fractional weights to generators and relaxes the covering constraint.

**Domain Bridges:** In machine learning: dictionary learning is NP-hard but has good heuristics. In database theory: optimal schema design under normal form constraints.

**Lineage:** The greedy algorithm from this cycle is the starting point; this direction asks whether it can be improved or whether hardness prevents it.

**Ambition:** Solid extension with potential for grand challenge if tight bounds are achieved.
