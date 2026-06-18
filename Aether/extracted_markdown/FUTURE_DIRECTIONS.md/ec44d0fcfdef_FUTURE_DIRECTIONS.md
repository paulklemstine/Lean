# Future Directions: Digit-Morphic Factorization Theory

## Synthesis

This research cycle established the **Digit-Morphic Factorization** framework, generalizing vampire numbers from base 10 to arbitrary bases and introducing the digit defect as a quantitative measure of how far any factorization deviates from digit-preservation. The central discovery is the **Fang Residue Constraint**: for a digit-morphic factorization v = x·y in base b, the pair (x mod (b−1), y mod (b−1)) must satisfy (x−1)(y−1) ≡ 1 (mod b−1), restricting valid pairs to exactly φ(b−1) residue classes. This connection to Euler's totient function is the most promising bridge to deeper number theory.

The cycle also revealed that the "spectral number" concept (near-miss vampires by sorted digit matching) is vacuous — sorting a multiset and converting back is injective, so sorted-digit agreement implies full multiset agreement. This negative result is surprisingly powerful: it eliminates an entire class of potential "almost-vampire" numbers.

The highest breakthrough potential lies in **Direction 1** (Totient Spectrum), which connects digit-morphic theory to the multiplicative structure of ℤ/(b−1)ℤ and could yield results about which bases are "richest" in digit-morphic factorizations. The cross-domain bridge to Euler's totient function and multiplicative number theory is genuine and underexplored.

---

### Direction 1: The Totient Spectrum of Digit-Morphic Bases

**Conjecture**: The ratio φ(b−1)/(b−1) — the "morphic density" of base b — achieves its infimum along the sequence b = p+1 where p is prime (giving φ(p)/p = (p−1)/p → 1), and its supremum at b = 2^k + 1 (giving φ(2^k)/2^k = 1/2). The density of digit-morphic factorizations in base b is monotonically related to φ(b−1)/(b−1)².

**Test**: Compute the morphic density for all bases 2 ≤ b ≤ 1000 and correlate with the actual count of digit-morphic 4-digit numbers in each base. If the correlation coefficient is > 0.8, the conjecture is strongly supported.

**Impact**: If true, this establishes that the "richness" of digit-morphic arithmetic in a base is governed by the prime factorization of b−1, connecting recreational number theory to deep multiplicative number theory. Bases where b−1 is highly composite would be the richest hunting grounds for vampire-like numbers.

**Catalog References**: `Geometry/VampireNumbers/DigitMorphic.lean` (fang_residue_constraint, density_obstruction), `Algebra/CausalCertification.lean` (composite_has_prime_factor)

**Proof Strategy**: 
1. Formalize the bijection between valid fang residue pairs and elements of (ℤ/(b−1)ℤ)×
2. Use Mathlib's `ZMod.card_units_eq_totient` to establish the count
3. Relate the modular density to actual digit-morphic density via a counting argument on digit permutations
4. The key technical challenge is bounding the number of digit multisets that produce a given residue pair

**Domain Bridges**: Number Theory (Euler's totient) ↔ Combinatorics (digit permutations) ↔ Applications (digit-morphic factorizations)

**Lineage**: Builds on fang_residue_constraint and density_obstruction from this cycle's DigitMorphic.lean

**Ambition**: grand_challenge

---

### Direction 2: k-Factor Digit Morphisms and the Defect Lattice

**Conjecture**: For k-factor digit-morphic factorizations v = x₁ · x₂ · … · xₖ (where the digit multiset of v equals the union of all factor digit multisets), the fang constraint generalizes to (x₁−1)(x₂−1)···(xₖ−1) ≡ (−1)^{k+1} (mod b−1). Furthermore, the digit defect of a k-factor factorization is always divisible by 2, and the set of achievable defects forms a sublattice of the even naturals.

**Test**: 
1. Verify the generalized constraint computationally for 3-factor factorizations of 6-digit numbers in base 10
2. Check whether digit defect divisibility strengthens (perhaps divisible by 4 for 4-factor factorizations?)
3. Map the set of achievable defects for k = 2, 3, 4 and check for lattice structure

**Impact**: k-factor digit morphisms would unify vampire numbers (k=2) with higher-order digit-preserving factorizations. If the defect lattice has interesting structure, it could connect to the theory of integer partitions.

**Catalog References**: `Geometry/VampireNumbers/DigitMorphic.lean` (digitDefect_even, digitMorphic_mod_constraint)

**Proof Strategy**:
1. Define IsDigitMorphicK for k factors using List or Fin k → ℕ
2. Prove digit sum additivity for k factors (straightforward multiset induction)
3. The mod-(b−1) constraint should follow from telescoping: Π(xᵢ−1) contains the product of residues
4. Digit defect parity should extend by the same multiset cardinality argument

**Domain Bridges**: Algebra (multiplicative structure of products) ↔ Combinatorics (multiset operations) ↔ Applications (k-factor vampires)

**Lineage**: Direct extension of digitDefect_even and digitMorphic_mod_constraint

**Ambition**: extension

---

### Direction 3: Analytic Density of Digit-Morphic Numbers

**Conjecture**: Let V(N) denote the number of digit-morphic numbers ≤ N in base 10. Then V(N) = Θ(N / (log N)^{3/2}). More precisely, among 2n-digit numbers, the fraction that are digit-morphic is asymptotically c · n^{-1/2} for some constant c > 0.

**Test**: 
1. Enumerate all vampire numbers up to 10⁸ (feasible with the fang constraint pruning)
2. Fit the count V(10^{2n}) / 10^{2n} against n^{-α} for various α
3. If α ≈ 0.5, the conjecture is supported; if α significantly differs, the heuristic model needs revision

**Impact**: A rigorous density result would be the first analytic theorem about vampire numbers. The 1/√n heuristic comes from the birthday paradox: the probability that a random permutation of 2n digits splits into two valid n-digit numbers is roughly C(2n,n)·(n!)²/10^{2n} ∼ 1/√(πn). Turning this into a theorem requires understanding the correlation structure of digit constraints.

**Catalog References**: `Geometry/VampireNumbers/DigitMorphic.lean`, `Geometry/VampireNumbers/Theorems.lean` (fang_search_space_bound)

**Proof Strategy**:
1. Formalize the counting argument: for a 2n-digit number v, the number of ways to partition its digit multiset into two n-element sub-multisets is at most C(2n,n)
2. Each partition gives a candidate (x,y) pair; the probability that the partition corresponds to the actual product x·y is roughly 1/10^n
3. Expected number of fang pairs per number: C(2n,n)/10^n ∼ 4^n/(√(πn)·10^n) → 0
4. Use second moment method to show that the number of vampires concentrates around its expectation
5. Key difficulty: correlations between different digit partitions of the same number

**Domain Bridges**: Analytic Number Theory (density results) ↔ Combinatorics (multiset partitions) ↔ Probability (birthday paradox)

**Lineage**: Builds on fang_search_space_bound and the vampire enumeration data from this cycle

**Ambition**: grand_challenge

---

### Direction 4: Ghost Number Density and Digit Coverage

**Conjecture**: The density of ghost numbers among n-digit composite numbers approaches 0 exponentially fast as n → ∞. Specifically, the probability that a random n-digit composite v = x·y has digit sets of x and y disjoint from v is at most (1 − 1/10)^n = (9/10)^n for base 10.

**Test**: 
1. Compute the exact count of ghost numbers in [10^k, 10^{k+1}) for k = 1, …, 8
2. Fit the ratio (ghost count) / (composite count) against c · r^k
3. Determine whether r ≈ 0.9 or some other exponential decay rate

**Impact**: Ghost numbers are the "opposite" of vampire numbers: factors share NO digits with the product. Proving they vanish exponentially would contrast beautifully with the polynomial (1/√n) vanishing of vampires, showing that "digit avoidance" is much harder to achieve than "digit preservation" as numbers grow.

**Catalog References**: `Geometry/VampireNumbers/Defs.lean` (IsGhostNumber), `Geometry/VampireNumbers/Theorems.lean` (ghost_number_distinct_digits)

**Proof Strategy**:
1. An n-digit number uses at least ⌈n/10⌉ distinct digits (pigeonhole in base 10)
2. For large n, the digit set of v covers most of {0,...,9}
3. Any factor x of v with ≥ ⌈log₁₀(x)⌉ digits will almost surely share a digit with v
4. Make this precise using probabilistic arguments about digit distribution

**Domain Bridges**: Probability (digit coverage) ↔ Combinatorics (pigeonhole) ↔ Applications (ghost numbers)

**Lineage**: Builds on ghost_number_distinct_digits from the existing Theorems.lean

**Ambition**: extension

---

### Direction 5: Digit-Morphic Factorizations in Non-Standard Number Systems

**Conjecture**: In the balanced ternary system (digits −1, 0, 1 with base 3), digit-morphic factorizations satisfy x·y ≡ x+y (mod 2) — a parity constraint. Furthermore, balanced ternary vampire numbers are denser than standard ternary vampires because the digit set {−1, 0, 1} is more "balanced" around 0.

**Test**:
1. Implement balanced ternary digit extraction and multiset comparison
2. Enumerate balanced ternary vampires up to 3⁸ = 6561
3. Compare density with standard base-3 vampires in the same range
4. Verify the mod-2 constraint

**Impact**: Extending digit-morphic theory to non-standard positional systems (balanced ternary, factorial base, Fibonacci base) would test which aspects of the theory are genuinely about positional representation vs. which are artifacts of the standard base-b system. If balanced ternary vampires are indeed denser, it would suggest that digit balance (symmetric digit range around 0) promotes digit-morphism — a novel structural insight.

**Catalog References**: `Geometry/VampireNumbers/DigitMorphic.lean` (digitSum_modEq_base — the proof technique should adapt to non-standard bases)

**Proof Strategy**:
1. Define a generalized "digit system" as a pair (base b, digit set D ⊂ ℤ with |D| = b)
2. The casting-out theorem depends only on the base, not the digit set: if all digits d ∈ D satisfy the reconstruction n = Σ dᵢ · bⁱ, then n ≡ Σ dᵢ (mod b−1)
3. For balanced ternary, b = 3, so the constraint is mod 2 — a simple parity constraint
4. The key question is whether the digit multiset equality is easier to satisfy when digits are symmetric

**Domain Bridges**: Number Systems (non-standard bases) ↔ Algebra (modular arithmetic) ↔ Combinatorics (digit permutations)

**Lineage**: Natural extension of the base-b generalization in DigitMorphic.lean

**Ambition**: extension
