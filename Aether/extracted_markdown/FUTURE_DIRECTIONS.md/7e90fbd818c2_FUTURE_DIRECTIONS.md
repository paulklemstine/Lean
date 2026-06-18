# Future Research Directions: The Periodic Table of Finite Groups

## Synthesis

This research cycle established six machine-verified theorems forming the backbone of a "periodic table" framework for finite groups. The **Derived–Central Series Inequality** (derivedSeries ≤ lowerCentralSeries at every step) provides the fundamental structural ordering between two notions of group complexity. The **Product Decomposition Theorem** shows that derived series distribute perfectly over direct products, giving clean formulas for how complexity behaves under group combination. The **Quantitative Periodic Law** — that derived depth is bounded by Ω(|G|), the number of prime factors with multiplicity — is the sharpest result, providing a hard ceiling on how complex a solvable group of given order can be.

The most promising cross-domain connection is between **group valence** (minimal normal subgroup count) and **representation theory**. The socle of a finite group decomposes as a direct product of minimal normal subgroups, and this decomposition is intimately connected to the structure of the character table and the Burnside ring. Formalizing the socle decomposition and connecting it to representation-theoretic invariants would bridge two of the richest areas of finite group theory. Additionally, the Quantitative Periodic Law connects to **number theory** through the Ω function, suggesting that analytic number theory tools (e.g., bounds on Ω, distribution of smooth numbers) could yield statistical predictions about group structure.

The direction with the highest breakthrough potential is **Direction 1** (Characterizing Equality in the Quantitative Periodic Law), because it would identify the extremal groups — the "heaviest elements" — and connect their structure to iterated wreath products, a construction that bridges group theory with combinatorics and automata theory.

---

### Direction 1: Characterizing Equality in the Quantitative Periodic Law

**Conjecture**: A finite solvable group G achieves d(G) = Ω(|G|) if and only if G is isomorphic to a direct product of copies of Z/pZ for various primes p. Equivalently, the bound is achieved only by elementary abelian groups — except wait, those have derived depth 0 or 1. The correct conjecture: d(G) = Ω(|G|) if and only if |G| is a prime (so d(G) = 1 = Ω(|G|) trivially, since the only solvable group of prime order is cyclic). For |G| composite, d(G) < Ω(|G|) strictly. In other words, the Quantitative Periodic Law is *never tight* for composite-order groups.

**Test**: Compute d(G) and Ω(|G|) for all groups of order ≤ 200 using GAP or SageMath. Check whether any composite-order group achieves equality. Expected outcome: no composite-order group achieves equality, because each derived quotient has order ≥ 2, but the "spending" of prime factors is inefficient — the quotients tend to have order much larger than 2.

Counter-test: The iterated wreath product Z/2Z ≀ Z/2Z ≀ ··· ≀ Z/2Z (k copies) has order 2^(2^k - 1) and derived depth k. So Ω(|G|) = 2^k - 1 while d(G) = k, giving a ratio d/Ω → 0. This confirms the bound is far from tight for wreath products.

**Impact**: If true, this would mean the Quantitative Periodic Law is a *strict* inequality for all interesting groups, and the natural question becomes: what is the best constant c < 1 such that d(G) ≤ c · Ω(|G|) for all solvable G of sufficiently large order?

**Catalog References**: `EML/PeriodicTableGroups.lean` (quantitative_periodic_law_conjecture, derivedDepth)

**Proof Strategy**: 
1. Show that for any group G with d(G) = Ω(|G|), every derived quotient D^i/D^{i+1} must have prime order.
2. Use the structure theory of solvable groups with all abelian factors of prime order to show these are supersolvable.
3. Classify supersolvable groups with this property — show they must be cyclic of prime order.

Key lemma needed: If G is solvable and every derived quotient has prime order, then G is supersolvable.

**Domain Bridges**: Number Theory (prime factorization, Ω function) <-> Group Theory (derived series, solvability) <-> Combinatorics (wreath product structure)

**Lineage**: Builds on quantitative_periodic_law_conjecture from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Socle Decomposition and Representation-Theoretic Valence

**Conjecture**: For a finite group G, the group valence v(G) equals the number of irreducible G-modules appearing in the socle Soc(G) viewed as a G-module under conjugation. In particular, for solvable groups, v(G) equals the number of minimal normal subgroups, each of which is an elementary abelian p-group for some prime p, and the representation-theoretic decomposition of Soc(G) determines v(G).

**Test**: For all groups of order ≤ 100, compute v(G) both combinatorially (count minimal normal subgroups) and representation-theoretically (decompose Soc(G) as a G-module). Verify they agree.

**Impact**: This would bridge the "periodic table" framework to representation theory, opening the door to character-theoretic tools for studying group valence. It would also connect to the Burnside ring, where the minimal normal subgroups correspond to primitive idempotents.

**Catalog References**: `EML/PeriodicTableGroups.lean` (Subgroup.IsMinimalNormal, groupValence, simple_group_valence_eq_one)

**Proof Strategy**:
1. Formalize the socle as the join of minimal normal subgroups in Lean.
2. Prove the socle is a direct product of minimal normal subgroups (for finite groups).
3. Show each minimal normal subgroup is characteristically simple (direct product of isomorphic simple groups).
4. Connect to the G-module structure: each minimal normal subgroup is an irreducible G-module under conjugation.

Key infrastructure needed: Formalize the socle in Lean, prove its direct product decomposition.

**Domain Bridges**: Group Theory (socle, minimal normal subgroups) <-> Representation Theory (irreducible modules, character table) <-> Ring Theory (Burnside ring, primitive idempotents)

**Lineage**: Builds on groupValence and simple_group_valence_eq_one from this cycle.

**Ambition**: grand_challenge

---

### Direction 3: Derived Depth Statistics for p-Groups

**Conjecture**: Among groups of order p^n (for fixed prime p), the average derived depth grows as Θ(log n). More precisely, if D(p,n) denotes the average derived depth of groups of order p^n, then D(p,n) / log₂(n) → c_p as n → ∞ for some constant c_p depending only on p, with c₂ ≈ 1.

**Test**: Using the small groups library in GAP, compute the average derived depth of all groups of order 2^n for n = 1, 2, ..., 10. Plot D(2,n) vs log₂(n) and check for convergence. For n = 7, there are already 267 groups; for n = 8, there are 2328; this is computationally feasible.

**Impact**: If true, this would establish a "law of large numbers" for group complexity, showing that random p-groups have predictable derived depth. This connects group theory to statistical mechanics — groups of a given order behave like a thermodynamic ensemble.

**Catalog References**: `EML/PeriodicTableGroups.lean` (derivedDepth, quantitative_periodic_law_conjecture)

**Proof Strategy**: 
1. Computationally verify for small n using GAP/SageMath.
2. Use the Higman-Sims asymptotic formula for the number of groups of order p^n to establish the denominator.
3. For the numerator, use the structure theory of p-groups: most p-groups of order p^n have nilpotency class around n/2, and derived depth ≤ nilpotency class (by our Corollary 3.2).
4. Establish matching lower bounds by exhibiting explicit families of p-groups with derived depth Ω(log n).

**Domain Bridges**: Group Theory (p-groups, derived depth) <-> Probability/Statistics (random groups, law of large numbers) <-> Number Theory (counting groups, asymptotic enumeration)

**Lineage**: Builds on derivedDepth_le_nilpotencyClass and the statistical perspective introduced in this cycle.

**Ambition**: extension

---

### Direction 4: Valence Additivity and the Group Periodic Table Layout

**Conjecture**: For finite groups G, H with coprime orders, v(G × H) = v(G) + v(H). This additivity fails in general when gcd(|G|, |H|) > 1 — specifically, there exist groups G, H with gcd(|G|, |H|) > 1 such that v(G × H) ≠ v(G) + v(H).

**Test**: 
- Coprime case: verify for all pairs of groups G, H with |G| · |H| ≤ 100 and gcd(|G|, |H|) = 1.
- Non-coprime counterexample: compute v(Z/4Z × Z/4Z) and compare with v(Z/4Z) + v(Z/4Z). The group Z/4Z has one minimal normal subgroup (its subgroup of order 2), so v(Z/4Z) = 1. But Z/4Z × Z/4Z has three minimal normal subgroups: {(0,0), (2,0)}, {(0,0), (0,2)}, and {(0,0), (2,2)}. So v = 3 ≠ 1 + 1 = 2.

**Impact**: This would determine the exact conditions under which the periodic table's column structure (valence) is additive. The coprime case would give a clean "group-theoretic Hund's rule" for combining groups.

**Catalog References**: `EML/PeriodicTableGroups.lean` (groupValence, derivedSeries_prod, derivedDepth_prod)

**Proof Strategy**:
1. For the coprime case: use the Krull-Schmidt theorem and the fact that minimal normal subgroups of G × H with coprime orders project onto exactly one factor.
2. For the counterexample: direct computation with Z/4Z × Z/4Z.
3. Formalize both results in Lean using Fintype/DecidableEq instances for small abelian groups.

**Domain Bridges**: Group Theory (direct products, minimal normal subgroups) <-> Lattice Theory (subgroup lattice, modular law) <-> Combinatorics (counting configurations)

**Lineage**: Builds on groupValence and derivedDepth_prod from this cycle.

**Ambition**: extension

---

### Direction 5: Tropical Valuation of Derived Series

**Conjecture**: Define the *tropical derived depth* of a group G as the function f_G : ℕ → ℕ ∪ {∞} where f_G(p) = the smallest n such that D^n(G) has trivial Sylow p-subgroup. Then for solvable G: (a) f_G is well-defined (finite for all primes dividing |G|), and (b) max_p f_G(p) = d(G).

**Test**: Compute f_G for symmetric groups S₃, S₄ and all groups of order ≤ 30. Verify that the max over primes gives the derived depth.

**Impact**: This would give a "prime-by-prime" decomposition of derived depth, analogous to tropical geometry's approach of replacing a polynomial by its Newton polygon. It connects the periodic table framework to p-local group theory and could lead to sharper bounds than the global Quantitative Periodic Law.

**Catalog References**: `EML/PeriodicTableGroups.lean` (derivedDepth, derivedSeries_le_lowerCentralSeries), `Tropical/` (tropical semiring framework in the Catalog)

**Proof Strategy**:
1. Define the tropical derived depth function formally.
2. Show f_G(p) ≤ d(G) for all p (since D^{d(G)}(G) = 1 has trivial Sylow p-subgroups).
3. Show d(G) ≤ max_p f_G(p) by proving that if all Sylow p-subgroups of D^n(G) are trivial, then D^n(G) = 1.
4. The key step is (3), which uses the fact that a finite group with all trivial Sylow subgroups is trivial.

**Domain Bridges**: Group Theory (derived series, Sylow theory) <-> Tropical Geometry (valuations, Newton polygons) <-> Number Theory (p-adic decomposition)

**Lineage**: Builds on derivedDepth and the Quantitative Periodic Law from this cycle. Connects to the Catalog's Tropical framework.

**Ambition**: extension
