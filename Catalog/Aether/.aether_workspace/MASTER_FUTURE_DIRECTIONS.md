# MASTER FUTURE DIRECTIONS — Accumulated Research Wisdom

*Last updated: 2026-05-09 04:38*

## Breakthrough Opportunities (ranked by impact)

### 1. Berggren-Stern-Brocot Bijection (Complete Formal Proof)

**Theorem Statement**: The map φ(a,b,c) = (c+b)/a is a bijection from primitive Pythagorean triples to rationals > 1 with odd numerator+denominator sum, preserving the tree structure.

**Proof Strategy**:
- *Approach A*: Direct matrix factorization — decompose each Berggren generator as a product of Stern-Brocot generators L, R in PSL(2,ℤ). This reduces to verifying 3 matrix identities.
- *Approach B*: Structural induction — prove that depth-d Berggren nodes map bijectively to depth-(d+1) Stern-Brocot nodes.
- *Approach C*: Via Euclidean algorithm — show that the continued fraction of (c+b)/a encodes the Berggren descent path.

**Why This Is Revolutionary**: Establishes a formal bridge between the classification of Pythagorean triples and the modular group, enabling transfer of deep results between number theory and hyperbolic geometry. Opens the door to formal modular form computations.

**Catalog Leverage**: Build on `berggren_stern_map_gt_one`, `berggren_children_distinct`, `word_preserves_minkowski`.

**Research Mode**: prove  
**Estimated Depth**: 4

### 2. Geodesic Length = Tree Depth Isometry

**Theorem Statement**: For any primitive triple t at Berggren depth d, the hyperbolic geodesic length from φ(3,4,5) to φ(t) in the Farey triangulation equals d + 1.

**Proof Strategy**:
- Define the Farey graph formally as a metric graph on ℚ ∪ {∞}
- Prove each Berggren step moves exactly one edge in the Farey graph
- Use `wordMatrix_append` and `word_preserves_minkowski` to track depth

**Why This Is Revolutionary**: This would be the first formal proof that tree depth equals geodesic distance, connecting combinatorial tree metrics to differential-geometric quantities. Applications to certified robustness become quantitative.

**Catalog Leverage**: `berggren_stern_map_root`, `berggren_stern_map_A`, `exp_tree_dist_antitone`, `farey_det_left`.

**Research Mode**: prove  
**Estimated Depth**: 5

### 3. Formal Lattice SVP Bounds from Pell Solutions

**Theorem Statement**: For the n-th Pell solution (mₙ, nₙ), the lattice Λₙ = ℤ·(mₙ, nₙ) + ℤ·(nₙ, mₙ) has shortest vector length λ₁(Λₙ) ≥ (3+2√2)^(n/2).

**Proof Strategy**:
- Formalize the lattice construction from Pell solutions
- Use `pell_norm_growth` to bound vector lengths
- Connect to Minkowski's theorem for lattice packing density

**Why This Is Revolutionary**: Provides the first formally verified exponential SVP lower bounds for a natural family of lattices. This has direct implications for post-quantum cryptography parameter selection.

**Catalog Leverage**: `pell_recurrence`, `pell_norm_growth`, `pell_matrix_det`, `berggren_svp_lower`.

**Research Mode**: prove  
**Estimated Depth**: 3

### 4. Trace Formula and Selberg Zeta Function

**Theorem Statement**: The Selberg zeta function Z(s) = Π_{geodesics γ} Π_{k=0}^∞ (1 - exp(-(s+k)ℓ(γ))) converges for Re(s) > 1, where the product is over primitive closed geodesics of ℍ/PSL(2,ℤ) and ℓ(γ) is the geodesic length.

**Proof Strategy**:
- Use `partition_function_identity` and `partition_decay` as building blocks
- Bound the number of geodesics of length ≤ L using `berggren_node_count`
- Apply analytic continuation via the functional equation

**Why This Is Revolutionary**: Connects the Berggren enumeration to deep analytic number theory. The zeros of Z(s) are eigenvalues of the Laplacian on the modular surface — a bridge to quantum chaos.

**Catalog Leverage**: `partition_function_identity`, `partition_decay`, `trace_B_sequence`.

**Research Mode**: prove  
**Estimated Depth**: 5

### 5. Tropical Berggren Correspondence

**Theorem Statement**: The tropicalization of the Berggren matrices (replacing (×, +) with (max, +)) produces a tropical semiring action on tropical Pythagorean triples, and the tropical analogue of φ is a bijection to the tropical Stern-Brocot tree.

**Proof Strategy**:
- Define tropical 3×3 matrix action
- Verify tropical Minkowski preservation: max(a,b) + max(a,b) = max(c,c) tropically
- Show tropical φ(a,b,c) = max(c,b) - a preserves tropical tree structure

**Why This Is Revolutionary**: Opens a new field of "tropical Pythagorean geometry" with applications to optimization and discrete geometry.

**Catalog Leverage**: `pythagorean_product_identity`, `wordMatrix_append`.

**Research Mode**: discover  
**Estimated Depth**: 3