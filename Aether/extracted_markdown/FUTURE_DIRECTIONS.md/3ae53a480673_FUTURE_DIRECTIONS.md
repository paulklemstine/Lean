# Future Research Directions: The Periodic Table of Finite Groups

## Synthesis

This research cycle established the foundational mathematical framework for a "periodic table" of finite groups, proving five core structural theorems and defining the key invariants (derived depth, group valence, electronegativity, nuclear charge). The central achievement is the **Derived–Central Series Inequality** (derivedSeries G n ≤ lowerCentralSeries G n), which provides the fundamental bridge between nilpotency theory and solvability theory. Combined with the **Product Decomposition Theorem** (D^n(G × H) = D^n(G) × D^n(H)), the **Quotient Monotonicity Theorem**, and the characterization of simple group valence, we now have a working chemical-algebraic dictionary backed by machine-verified proofs.

The most promising cross-domain connection from this cycle is between the **big omega function Ω** (from analytic number theory) and **group-theoretic complexity** (derived depth). The Quantitative Periodic Law conjecture — derivedDepth(G) ≤ Ω(|G|) — sits at the intersection of number theory, combinatorial group theory, and p-group theory. Its resolution would connect prime factorization structure to iterated commutator dynamics. The Product Decomposition Theorem connects to the Catalog's work on direct sum decompositions in `Algebra/Advanced.lean`, while the derived series analysis extends the commutator-theoretic work in `Bridges/GaloisDeepLearning.lean`.

The direction with the highest breakthrough potential is **Direction 1** (Quantitative Periodic Law), because it combines a precise falsifiable conjecture with connections to deep results about p-group structure. A proof would establish a universal complexity bound for solvable groups; a counterexample would reveal new phenomena in how derived series can concentrate depth relative to group order.

---

### Direction 1: Quantitative Periodic Law for Solvable Groups

**Conjecture**: For every nontrivial finite solvable group G, the derived depth satisfies derivedDepth(G) ≤ Ω(|G|), where Ω(n) is the number of prime factors of n counted with multiplicity.

**Test**: Enumerate all solvable groups of order ≤ 500 using GAP/Magma. For each, compute derivedDepth and Ω(|G|). Check the inequality. Additionally, construct the iterated wreath products W_n = C_p ≀ C_p ≀ ... ≀ C_p (n times) for p = 2, 3 and n up to 6, and verify derivedDepth(W_n) = n ≤ Ω(|W_n|) = (p^n - 1)/(p - 1).

**Impact**: If true, establishes a fundamental universal bound on solvable group complexity, directly linking prime factorization to commutator dynamics. If false, the counterexample would be a group whose commutator structure is more "compressed" than expected, revealing new phenomena in iterated commutator subgroups.

**Catalog References**: `Pythagorean/PeriodicTableGroups/Defs.lean` (bigOmega, derivedDepth), `Pythagorean/PeriodicTableGroups/DerivedCentral.lean` (derivedSeries_le_lowerCentralSeries, nilpotent_derivedDepth_le_nilpotencyClass)

**Proof Strategy**: 
1. Reduce to the case where G is a p-group using the Sylow theorems and the fact that a solvable group has a subnormal series with prime-power-index factors.
2. For p-groups, use the fact that nilpotency class ≤ log_p(|G|) = v_p(|G|) ≤ Ω(|G|).
3. For general solvable groups, use induction on |G| with the short exact sequence 1 → N → G → G/N → 1 where N is a minimal normal subgroup.
4. Key lemma needed: derivedDepth(G) ≤ derivedDepth(N) + derivedDepth(G/N) (subadditivity over extensions).
5. The hard case is non-split extensions where the bound is tight.

**Domain Bridges**: Number theory (Ω function, prime factorization) ↔ Group theory (derived series, solvability) ↔ Combinatorics (wreath products, tree structure)

**Lineage**: Builds on derivedSeries_le_lowerCentralSeries, nilpotent_derivedDepth_le_nilpotencyClass, and bigOmega_mul from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Valence-Representation Bridge

**Conjecture**: For a finite group G with k minimal normal subgroups (valence k), the number of irreducible complex representations of G is at least k + 1. More precisely, if Soc(G) = N₁ × N₂ × ... × N_k is the socle decomposition into minimal normal subgroups, then the number of distinct irreducible representations of G that restrict nontrivially to Soc(G) is at least k.

**Test**: For all groups of order ≤ 100, compute (a) the number of minimal normal subgroups, (b) the number of irreducible representations, and (c) the number of irreducible representations that restrict nontrivially to the socle. Verify the inequality. Check especially for groups with large socles (e.g., elementary abelian groups, direct products of simple groups).

**Impact**: If true, connects the "chemical valence" of a group to its representation theory, providing a bridge between our periodic table framework and the well-developed theory of group characters. This would be a genuinely new result linking two independently studied invariants.

**Catalog References**: `Pythagorean/PeriodicTableGroups/Defs.lean` (IsMinimalNormal, groupValence, minimalNormalSubgroups), `Pythagorean/PeriodicTableGroups/DerivedCentral.lean` (simple_group_has_unique_minNormal)

**Proof Strategy**:
1. For abelian groups, minimal normal subgroups are cyclic of prime order, and each provides a distinct nontrivial character.
2. For nonabelian groups, use the fact that each minimal normal subgroup N_i has a nontrivial irreducible representation (by Maschke's theorem applied to the regular representation restricted to N_i).
3. Induce these representations to G and show they remain distinct.
4. Key tools: Frobenius reciprocity, Clifford theory (restriction to normal subgroups).

**Domain Bridges**: Group theory (socle structure, minimal normal subgroups) ↔ Representation theory (irreducible representations, character theory) ↔ Ring theory (Burnside ring, representation ring)

**Lineage**: Builds on IsMinimalNormal and simple_group_has_unique_minNormal from this cycle.

**Ambition**: grand_challenge

---

### Direction 3: Derived Depth Subadditivity for Group Extensions

**Conjecture**: For any short exact sequence 1 → N → G → Q → 1 of finite solvable groups, derivedDepth(G) ≤ derivedDepth(N) + derivedDepth(Q).

**Test**: Construct all non-split extensions of small solvable groups (e.g., extensions of C_4 by C_4, extensions of S_3 by C_2) and verify the inequality. Check semidirect products C_p ⋊ C_q for small primes p, q. Verify for wreath products A ≀ B where A, B are solvable.

**Impact**: If true, this lemma is the key missing ingredient for proving the Quantitative Periodic Law by induction on group order. It would allow decomposing the derived depth bound along composition series. If false, it identifies the precise mechanism by which extensions can amplify derived depth beyond additive bounds.

**Catalog References**: `Pythagorean/PeriodicTableGroups/DerivedCentral.lean` (derivedSeries_map_quotient_le, derivedSeries_prod_eq)

**Proof Strategy**:
1. Use derivedSeries_map_quotient_le to show D^n(Q) = D^n(G/N) ≤ π(D^n(G)), so D^(derivedDepth(Q))(G) ≤ N.
2. Then D^(derivedDepth(Q) + k)(G) ≤ D^k(N ∩ D^(derivedDepth(Q))(G)) ≤ D^k(N).
3. Setting k = derivedDepth(N) gives D^(derivedDepth(Q) + derivedDepth(N))(G) = 1.
4. The hard part is step 2: showing the derived series of the "remainder" after quotienting behaves like the derived series restricted to N. This may require Schreier refinement.

**Domain Bridges**: Homological algebra (group extensions, exact sequences) ↔ Group theory (derived series, solvability) ↔ Category theory (short exact sequences, functoriality)

**Lineage**: Builds on derivedSeries_map_quotient_le and derivedSeries_prod_eq from this cycle. The product case is a special (split, trivial action) case of this conjecture.

**Ambition**: extension

---

### Direction 4: Electronegativity and Automorphism Groups

**Conjecture**: For a finite group G, the electronegativity χ(G) = [G : [G,G]] divides |Aut(G)|. That is, the size of the abelianization divides the size of the automorphism group.

**Test**: Compute χ(G) and |Aut(G)| for all groups of order ≤ 60 and verify divisibility. Pay special attention to groups where χ(G) is large relative to |G| (highly abelian groups) and where |Aut(G)| is small (groups with few automorphisms, like Q_8).

**Impact**: If true, establishes a deep connection between the "reactivity" of a group (how abelian it is) and its symmetry (how many automorphisms it has). This would connect the periodic table framework to the theory of automorphism groups.

**Catalog References**: `Pythagorean/PeriodicTableGroups/Defs.lean` (groupElectronegativity)

**Proof Strategy**:
1. The abelianization G^ab = G/[G,G] is a quotient of G, and every automorphism of G that fixes [G,G] induces an automorphism of G^ab.
2. Consider the map Aut(G) → Aut(G^ab) → GL(G^ab). The image contains at least the inner automorphisms restricted to G^ab.
3. For abelian G, Aut(G) contains all automorphisms of G^ab = G, so |G| divides |Aut(G)|... but this is false for G = C_2 (|Aut(C_2)| = 1).
4. **Likely false**: C_2 has χ = 2 but |Aut| = 1. Investigate what modified statement might be true (e.g., χ(G) divides |G| · |Aut(G)|).

**Domain Bridges**: Group theory (automorphisms, abelianization) ↔ Linear algebra (GL of abelian groups) ↔ Number theory (structure of finite abelian groups)

**Lineage**: Builds on groupElectronegativity definition from this cycle.

**Ambition**: extension

---

### Direction 5: Tropical Geometry of the Group Invariant Space

**Conjecture**: The set of realizable invariant tuples (derivedDepth, log₂|G|, valence) for finite solvable groups, viewed as a subset of ℝ³, is a tropical variety — i.e., it can be described as the corner locus of a piecewise-linear function.

**Test**: Compute (derivedDepth, log₂|G|, valence) for all solvable groups of order ≤ 200. Plot the resulting point cloud in 3D. Check whether the boundary of the convex hull of these points is piecewise-linear. Specifically, test whether the maximum derivedDepth for a given log₂|G| is achieved by iterated wreath products and follows the tropical polynomial max(1, ⌊log₂(log₂|G|)⌋).

**Impact**: If true, connects finite group theory to tropical geometry — an unexpected bridge. The piecewise-linear structure would provide explicit formulas for extremal groups and could predict which invariant combinations are realizable.

**Catalog References**: `Tropical/` (tropical geometry framework in the Catalog), `Pythagorean/PeriodicTableGroups/Defs.lean` (derivedDepth, groupValence, nuclearCharge)

**Proof Strategy**:
1. Establish the boundary curve derivedDepth ≤ Ω(|G|) (the Quantitative Periodic Law).
2. Show the lower boundary derivedDepth ≥ 1 for nontrivial groups.
3. For the valence axis, characterize groups with maximal/minimal valence for a given order.
4. Use the Product Decomposition Theorem to show the realizable set is closed under componentwise max (a tropical operation).
5. The tropical variety structure would follow from the interaction of these piecewise-linear constraints.

**Domain Bridges**: Group theory (periodic table invariants) ↔ Tropical geometry (piecewise-linear varieties) ↔ Combinatorial optimization (integer programming, lattice points)

**Lineage**: Builds on all invariant definitions from this cycle. Connects to `Tropical/` catalog entries.

**Ambition**: grand_challenge
