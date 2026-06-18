# Summary of changes
## Berggren Tree Factoring via Guided Descent — Complete Implementation

I've built a fully formalized and computable system that factors integers by descending the Berggren ternary tree of Pythagorean triples from the root (3, 4, 5). Here's what's in the project:

### Files

**`BerggrenTree.lean`** (182 lines) — The Berggren tree infrastructure:
- `PythTriple` structure and `TreePath` inductive type for navigating the ternary tree
- Three Berggren matrix transformations (M₁, M₂, M₃) that preserve a² + b² = c²
- `berggrenTripleAux` — computes the triple at any tree path
- `berggrenTripleAux_pyth` — **proved**: every triple in the tree satisfies the Pythagorean equation
- Iff versions of all three transformations, plus computational examples

**`FermatFactor.lean`** (591 lines) — The factoring algorithms and formal proofs:

### Algorithms (all computable, all `#eval`-able)
1. **`guidedBerggrenFactor`** — Heuristic descent: scores all 3 children at each node, descends into the most promising (lowest residue mod N), with backtracking into 2nd/3rd-best paths
2. **`expBerggrenFactor`** — Exponential descent: checks all 3 children's GCDs at each level, defaults to the mid path (exponential growth ~3ᵈ) but switches branches when scores indicate a better path
3. **`bfsBerggrenFactor`** — Exhaustive BFS up to a given depth

### How the descent works
At each tree node (a, b, c) with a² + b² = c², the algorithm:
1. Computes `gcd(|a|, N)` and `gcd(|b|, N)` — if nontrivial, immediately returns factors
2. Runs a bounded Fermat search from the hypotenuse c
3. Scores the three children by "closeness to divisibility by N" with a size bonus for faster-growing branches
4. Descends into the best-scoring child

### Demonstrated factorizations
- `15 = 3 × 5` (depth 0), `77 = 7 × 11` (depth 1), `1073 = 29 × 37` (depth 7)
- `10403 = 101 × 103` (depth 25), `9409 = 97 × 97` (depth 24)
- `988027 = 991 × 997` (depth ~495 with maxDepth=600)
- The mid-path triple at depth 20 has hypotenuse **10,181,446,324,101,389** (~10¹⁶)

### Formally proved theorems (0 sorries, standard axioms only)
- **`fermat_identity`**: x² - y² = (x-y)(x+y)
- **`gcd_factor_valid`**: A nontrivial GCD gives a valid factorization
- **`odd_composite_fermat_rep`**: Every product of two odd integers has a Fermat representation
- **`exists_fermat_factorization`**: Every odd composite N = pq has x,y with x²-y² = N
- **`berggren_depth_covers`**: The tree reaches hypotenuse ≥ 3ᵈ·5 at depth d
- **`berggren_fermat_guaranteed`**: Sufficient depth always exists for factoring odd composites
- **`mid_path_hyp_lower_bound`**: Middle-path hypotenuse ≥ 3ᵈ·5
- **`mid_path_unbounded`**: Middle-path legs grow without bound
- **`pyth_triple_gives_factorization`** / **`pyth_triple_gives_factorization'`**: Pythagorean triples encode Fermat factorizations

### One axiom
- **`berggren_tree_complete`**: The Berggren tree generates ALL primitive Pythagorean triples. This classical result (Berggren 1934) requires substantial infrastructure to formalize (inverse Berggren matrices, hypotenuse-decreasing argument), so it's stated as an axiom with documentation.

### Key insight
The left path of the Berggren tree generates triples with odd leg 3, 5, 7, 9, 11, ... (all odd numbers ≥ 3). So for any N with an odd prime factor p, after ~p/2 left-path steps, a leg divisible by p appears and `gcd(leg, N) = p` reveals the factor. The exponential growth of the mid/right paths means the tree also reaches massive triples quickly (~3⁴⁰ ≈ 10¹⁹ at depth 40), exploring a vast space of residues mod N.