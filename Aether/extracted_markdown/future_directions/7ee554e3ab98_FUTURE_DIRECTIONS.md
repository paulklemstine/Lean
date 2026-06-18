# Future Directions: Vampire Numbers and Arithmetic Creatures

## Synthesis

This research cycle established a rigorous structural theory of digit-balanced factorizations (vampire numbers) and proved six non-trivial theorems about them. The most significant finding is the **mod-3 fang exclusion principle**: the casting-out-nines law xy ≡ x + y (mod 9) propagates to a mod-3 constraint that eliminates one-third of candidate fangs. This connects modular arithmetic to digit combinatorics in a way that could generalize to arbitrary bases, where the constraint becomes mod-(b-1) and its divisors.

The **digit count additivity theorem** provides the deepest structural insight: it shows that digit-balanced factorizations correspond precisely to multiset partitions with an arithmetic constraint. This bridges number theory to combinatorial partition theory, suggesting that techniques from partition enumeration (generating functions, asymptotic analysis) could yield density results for vampire numbers.

The most promising direction for breakthrough is **base-generalized vampire theory** (Direction 1). In base b, the mod-9 constraint becomes mod-(b-1), and the structure of (ℤ/(b-1)ℤ)* determines which fang residue pairs are admissible. For prime bases b, the group (ℤ/(b-1)ℤ)* has particularly clean structure, potentially yielding closed-form density estimates.

---

### Direction 1: Base-Generalized Vampire Numbers and the (b-1)-Residue Theorem

**Conjecture**: For a base-b vampire number v = x × y with digit multiset equality in base b, the constraint xy ≡ x + y (mod (b-1)) holds. The fraction of admissible fang residue pairs modulo (b-1) equals φ(b-1)/(b-1)², where φ is Euler's totient. For prime b, this simplifies to (b-2)/(b-1)².

A base-b vampire number v has 2n digits in base b, with n-digit fangs x, y satisfying: (i) v = xy, (ii) the multiset of base-b digits of v equals the union of base-b digit multisets of x and y. The digit sum in base b is congruent to the number mod (b-1) (generalized casting out nines), so xy ≡ x + y (mod (b-1)).

**Test**: Formalize `IsVampireBase (b : ℕ) (v : ℕ)` using `Nat.digits b v`. Prove the mod-(b-1) constraint for arbitrary b ≥ 2. Enumerate base-b vampires for b = 2, 3, ..., 16 and verify the admissible residue pair count matches φ(b-1).

**Impact**: If the density formula is correct, it would give the first closed-form expression for the "residue sieve" that constrains vampire numbers in any base. For b = 2 (binary), φ(1) = 1 and (b-1)² = 1, giving ratio 1 — meaning all binary pairs are admissible (no modular constraint). For b = 10, φ(9)/81 = 6/81, matching our computed result exactly.

**Catalog References**: `Geometry/VampireNumbers/Theorems.lean` (vampire_mod9_constraint), `Geometry/VampireNumbers/DeepTheory.lean` (fang_mod3_from_mod9)

**Proof Strategy**: Generalize `digitSum_modEq_nine` to `digitSum_modEq_base_minus_one` using `Nat.modEq_digits_sum`. The key Mathlib lemma is `Nat.modEq_digits_sum (b-1) b (by omega) n`, which requires b ≥ 2. The fang residue classification then follows from the group structure of (ℤ/(b-1)ℤ)*.

**Domain Bridges**: Number Theory <-> Abstract Algebra (group theory of units mod b-1) <-> Combinatorics (multiset partition enumeration in base b)

**Lineage**: Extends vampire_mod9_constraint and fang_mod3_from_mod9 from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Asymptotic Density via Generating Functions

**Conjecture**: The number of 2n-digit vampire numbers (base 10) grows as Θ(10^(2n) / (n · 10^n)) = Θ(10^n / n). Equivalently, the density among 2n-digit numbers is Θ(1/(n · 10^n)) · 10^n = Θ(1/n).

The heuristic: there are about 9 · 10^(n-1) choices for each n-digit fang, giving ~81 · 10^(2n-2) pairs. For each pair (x,y), the probability that the digit multiset of xy matches the union of digit multisets of x and y is approximately (2n)! / (10^(2n) · ∏(mᵢ!)) where mᵢ are digit multiplicities. By Stirling, this is ~C/√n for a constant C. So the expected count is ~C · 10^(2n-2) / √n, giving density ~C / (√n · 10²).

**Test**: Compute exact vampire counts for 4, 6, 8, 10-digit numbers. Fit the density function f(n) = a/n^b and determine b. If b ≈ 0.5, the √n heuristic is supported.

**Impact**: A rigorous asymptotic would be the first non-trivial density result for vampire numbers, resolving a question open since Pickover's 1994 definition. Even a formalized upper or lower bound would be significant.

**Catalog References**: `Geometry/VampireNumbers/DeepTheory.lean` (vampire_product_lower_bound, vampire_product_upper_bound, fang_search_space_bound)

**Proof Strategy**: Use the multinomial coefficient formula for digit multiset equality probability. Formalize the generating function for digit arrangements: G(z) = ∑ z^d / d! for d in {0,...,9}. The coefficient extraction [z^(2n)] G(z)^(2n) gives the expected number of valid multiset matches. Apply the saddle-point method for asymptotics.

**Domain Bridges**: Number Theory <-> Analytic Combinatorics (generating functions, saddle-point method) <-> Probability Theory (random digit models)

**Lineage**: Extends vampire_digitSum_bound and fang_search_space_bound from this cycle.

**Ambition**: grand_challenge

---

### Direction 3: Multi-Fanged Vampires and Factorization Multiplicity

**Conjecture**: For every k ≥ 1, there exists a vampire number with at least k distinct fang pairs. The smallest vampire with k fang pairs grows at most exponentially in k.

The number 125460 has two fang pairs (204×615, 246×510). Computational search suggests that multi-fanged vampires become more common among larger numbers as the factorization space grows.

**Test**: Enumerate all 6-digit and 8-digit vampire numbers, recording fang pair counts. Find the first vampire with 3, 4, 5 distinct fang pairs. Prove the existence of a vampire with 3 fang pairs by explicit construction.

**Impact**: Multi-fanged vampires connect to the theory of smooth numbers and highly composite numbers. A number with many fang pairs must have many factorizations into equal-length factors, connecting to the divisor function τ(n) and its behavior on highly composite numbers.

**Catalog References**: `Geometry/VampireNumbers/DeepTheory.lean` (vampire_125460, four_distinct_vampires)

**Proof Strategy**: For existence, search computationally and verify by `native_decide`. For the growth bound, use the fact that a k-fanged vampire needs at least k distinct factorizations into n-digit pairs, and numbers with many factorizations are well-studied (highly composite number theory).

**Domain Bridges**: Vampire Number Theory <-> Multiplicative Number Theory (divisor function, highly composite numbers)

**Lineage**: Extends vampire_125460 and four_distinct_vampires.

**Ambition**: extension

---

### Direction 4: Tropical Vampire Numbers — Digit Operations in the Min-Plus Semiring

**Conjecture**: Define a "tropical vampire number" as v where the tropical product (digit-wise minimum) of x and y's digit sequences equals v's digit sequence, with tropical sum (digit-wise maximum) giving the reconstruction. Then tropical vampires form a lattice under the digit-wise min/max operations.

In the min-plus (tropical) semiring, "addition" is min and "multiplication" is +. A tropical vampire would be a number whose digit sequence can be decomposed into two sequences whose element-wise operations reconstruct the original. This connects the combinatorial digit structure of vampires to tropical geometry.

**Test**: Formalize tropical digit operations on lists over ℕ. Define IsVampireTropical and enumerate examples. Prove or disprove that the set of tropical vampires is closed under tropical multiplication.

**Impact**: If tropical vampires form a structured algebraic object, this would be a genuine bridge between recreational number theory and tropical algebraic geometry. The min-plus structure could provide new tools for analyzing digit patterns.

**Catalog References**: `Tropical/` (tropical optimization framework), `Geometry/VampireNumbers/Defs.lean` (digit multiset framework)

**Proof Strategy**: Define tropical digit operations as pointwise min/max on digit lists (padded to equal length). Translate the multiset equality condition to a tropical condition. Use the lattice structure of (ℕ^k, min, max) to analyze closure properties.

**Domain Bridges**: Recreational Number Theory <-> Tropical Geometry <-> Lattice Theory

**Lineage**: New direction bridging this cycle's vampire theory with the existing Tropical catalog.

**Ambition**: extension

---

### Direction 5: The Ghost Density Conjecture and Digit Coverage

**Conjecture**: The density of ghost numbers among k-digit numbers approaches 0 as k → ∞. Specifically, for k-digit v, the probability that a random factorization v = xy has digit sets of x, y disjoint from v's digit set is O(c^k) for some c < 1.

As numbers grow larger, they use more distinct digits (a k-digit number uses on average min(10, Θ(log k / log log k)) distinct digits by the coupon collector heuristic). When v uses all 10 digits, ghost factorization is impossible. Numbers using 9 or fewer digits become exponentially rare among k-digit numbers for large k.

**Test**: Compute the fraction of k-digit numbers that are ghost numbers for k = 1, 2, ..., 8. Fit an exponential decay model. Prove that any number using all 10 digits cannot be a ghost number (this should be straightforward from the definition).

**Impact**: A formalized ghost density bound would complement the vampire density analysis and complete the picture for the "arithmetic creature bestiary."

**Catalog References**: `Geometry/VampireNumbers/DeepTheory.lean` (no_balanced_ghost_factorization, digit_le_nine), `Geometry/VampireNumbers/Defs.lean` (IsGhostNumber)

**Proof Strategy**: First prove that if digitSet(v) = {0,1,...,9}, then v cannot be a ghost number (since x and y must use some digit in {0,...,9}). Then bound the probability that a random k-digit number avoids some digit, using inclusion-exclusion over the 10 digit values.

**Domain Bridges**: Number Theory <-> Probability Theory (coupon collector, inclusion-exclusion) <-> Combinatorics (digit coverage)

**Lineage**: Extends no_balanced_ghost_factorization and ghost number analysis from this cycle.

**Ambition**: extension
