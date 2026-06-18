# Future Directions: Berggren Tree Completeness

## Breakthrough Opportunities (ranked by impact)

### 1. Full Exhaustiveness via Well-Founded Induction

- **Theorem Statement**: `∀ (a b c : ℤ), IsPrimitivePythagorean a b c → BerggrenReachable (a, b, c)`
- **Proof Strategy**:
  1. Use `descent_step` to recursively find parents
  2. Apply well-founded induction on `c.toNat` using `parentHyp_lt`
  3. At `c = 5`, use `root_classification` to identify (3,4,5) or (4,3,5)
  4. Need coprimality preservation: prove `Int.gcd` is preserved through inverse transforms using the unimodular property (|det| = 1)
- **Why This Is Revolutionary**: Completes the formal proof that every PPT is reachable, closing the gap between our descent step and full tree coverage
- **Catalog Leverage**: `descent_step`, `root_classification`, `parentHyp_lt`, `parent_unique`
- **Research Mode**: prove
- **Estimated Depth**: 3 (requires coprimality preservation lemma + well-founded recursion)

### 2. Coprimality Preservation Through Unimodular Matrices

- **Theorem Statement**: For each inverse Berggren matrix M⁻¹ with |det(M⁻¹)| = 1, if `Int.gcd a b = 1` and `a² + b² = c²`, then `Int.gcd (M⁻¹·v).1 (M⁻¹·v).2 = 1`
- **Proof Strategy**:
  1. If d | a' and d | b', then d² | a'² + b'² = c'², hence d | c'
  2. Since M is the inverse of M⁻¹ with integer entries, a = M·(a',b',c'), so d | a and d | b
  3. Therefore d | gcd(a,b) = 1
- **Why This Is Revolutionary**: Enables the full inductive argument by showing parents are also primitive
- **Catalog Leverage**: `det_berggrenInvA`, `det_berggrenInvB`, `det_berggrenInvC`, forward-inverse cancellation theorems
- **Research Mode**: prove
- **Estimated Depth**: 3 (requires careful formalization of divisibility through matrix multiplication)

### 3. Logarithmic Depth Bound

- **Theorem Statement**: `∀ (t : PrimTriple), descentDepth t ≤ C * Nat.log 2 t.c` for some explicit constant C
- **Proof Strategy**:
  1. Show that the hypotenuse decreases by at least a factor of 3/5 at each step (from `c' = 3c - 2(a+b)` and `a + b > c`)
  2. More precisely: since `c' ≤ c - 2` and typically `c' ≤ 3c/5`, the depth is O(log c)
  3. Alternative: prove `c'/c ≤ 1 - 2/c` which gives depth ≤ c/2, then improve to logarithmic via geometric decay
- **Why This Is Revolutionary**: Gives precise complexity bounds for the hash function; output length is O(log c) bits
- **Catalog Leverage**: `parentHyp_decrease_bound`, `parentHyp_lt`
- **Research Mode**: prove
- **Estimated Depth**: 4 (logarithmic bounds require careful bookkeeping)

### 4. Eisenstein Triple Analogue

- **Theorem Statement**: Define Eisenstein triples (a² − ab + b² = c²) and construct an analogous ternary tree with completeness
- **Proof Strategy**:
  1. Define the Eisenstein norm form Q(a,b,c) = a² − ab + b² − c²
  2. Find the three generating matrices for SO(Q;ℤ)
  3. Prove completeness by analogous sigma-invariant analysis
- **Why This Is Revolutionary**: Extends the Berggren paradigm to a new number-theoretic domain; connects to Eisenstein integers ℤ[ω]
- **Catalog Leverage**: Proof architecture from `BerggrenCompleteness.lean`
- **Research Mode**: discover
- **Estimated Depth**: 5 (requires finding the correct matrices and adapting all arguments)

### 5. Quantum Walk on the Berggren Tree

- **Theorem Statement**: A quantum walk on the Berggren tree finds any target primitive triple in O(√(c/log c)) steps
- **Proof Strategy**:
  1. Use the 3-regular tree structure and Grover-like speedup
  2. The tree has ~c/(2π) primitive triples with hypotenuse ≤ c
  3. Classical search: O(c/log c). Quantum: O(√(c/log c))
  4. Need to formalize the quantum walk on a tree and the spectral gap
- **Why This Is Revolutionary**: Connects Pythagorean number theory to quantum algorithms; first application of quantum walks to a number-theoretic tree
- **Catalog Leverage**: `BerggrenReachable`, tree structure definitions
- **Research Mode**: formalize
- **Estimated Depth**: 5 (requires quantum computation infrastructure)

## Under-explored Territory

### Parity Structure of the Berggren Tree
The sigma invariants σ₁ and σ₂ have deep connections to the parity of the triple components. For primitive triples, exactly one of a, b is even, and the parity pattern determines which branch applies. A complete formalization of this parity classification would simplify many arguments.

### Density of Primes in Hypotenuses
Which primes p appear as hypotenuses of primitive triples? Exactly those ≡ 1 (mod 4). The Berggren tree provides a constructive proof of this classical result, but the formal connection has not been made.

### Tropical Berggren Geometry
The Berggren matrices can be tropicalized by replacing (×, +) with (max, +). The resulting tropical tree structure on "tropical Pythagorean triples" has not been studied and could reveal new combinatorial patterns.

## Cross-Domain Bridges

### Berggren → Lattice Cryptography
The unimodular matrices generate a subgroup of GL₃(ℤ). The unique factorization in this group (each element is a unique word in {A, B, C}*) is analogous to the short vector problem in lattice cryptography. A reduction from collision resistance to lattice problems would be a breakthrough.

### Berggren → Spectral Graph Theory
The Berggren tree is a 3-regular tree. Its spectral gap determines mixing times for random walks. Computing this gap explicitly would give quantitative bounds on how quickly a random walk explores all triples up to a given hypotenuse.

### Pythagorean Triples → Modular Forms
Each primitive triple (a, b, c) with a odd corresponds to a point on the unit circle: (a/c, b/c). The distribution of these points is governed by modular forms of weight 1. The Berggren tree provides a canonical ordering of these points.

## Open Problems Encountered

### Coprimality Preservation (Critical Gap)
We proved that the descent step produces a positive Pythagorean triple with smaller hypotenuse, but did not formally prove that the parent is also coprime. This is the main remaining gap for the full exhaustiveness theorem. The argument is straightforward (unimodular matrices preserve gcd), but formalizing it requires careful handling of divisibility in ℤ.

### Uniqueness of Descent Path
We proved that at most one inverse branch gives a positive triple (parent_unique), but the full uniqueness theorem for descent paths requires composing this with the coprimality argument and the exhaustiveness theorem.

### Descent Path Length Bound
We proved the linear bound (depth ≤ (c−5)/2) but the logarithmic bound O(log c) requires showing that the hypotenuse decreases by a multiplicative factor, not just an additive constant.
