# Future Directions: Hyperbolic Arithmetic

## Synthesis

This cycle established the formal foundations of arithmetic on the one-dimensional Poincaré disk using Möbius addition a ⊕ b = (a+b)/(1+ab). The key discovery was that real Möbius addition is **fully associative**, making ((-1,1), ⊕) an abelian group isomorphic to (ℝ, +) via artanh. This is in sharp contrast to the complex case, where the gyration operator makes the disk a non-associative gyrogroup. We proved monotone convergence of Möbius iterates, exponential lattice growth (2^{n+1} - 1 points in the ball of radius n), orbit separation for distinct generators, absence of interior fixed points, and zeta summand reversal.

The most promising cross-domain connection is the **Pythagorean–Hyperbolic bridge**: every Pythagorean triple (a,b,c) gives a rational disk point a/c, and these are closed under Möbius addition. This connects the Berggren tree of primitive Pythagorean triples (studied in `Cryptography/BerggrenDiophantineLattice.lean` and `Algebra/Berggren.lean`) with hyperbolic lattice theory. A second major connection is to **tropical arithmetic** via the artanh isomorphism, which linearizes Möbius addition just as the logarithm linearizes multiplication—suggesting that hyperbolic arithmetic is a "multiplicative shadow" of tropical semiring operations (see `Tropical/TropicalFactoring.lean`).

The highest breakthrough potential lies in the **complex gyrogroup extension** (Direction 1): proving that the 2D Möbius gyrogroup has no faithful linear representation would establish a fundamentally new algebraic phenomenon with implications for representation theory, special relativity, and quantum information.

---

### Direction 1: Complex Möbius Gyrogroup — Non-Associative Arithmetic in 2D

**Conjecture**: The complex Möbius addition z ⊕ w = (z+w)/(1+z̄w) on the unit disk 𝔻 ⊂ ℂ defines a gyrogroup that is **not** isomorphic to any group. Specifically, there exist z, w, u ∈ 𝔻 such that gyr[z,w](u) ≠ u, where gyr[z,w](u) = -(z⊕w) ⊕ (z ⊕ (w⊕u)).

**Test**: Compute gyr[i/2, (1+i)/3](i/4) and verify it differs from i/4. This requires complex Möbius addition with conjugation in the denominator.

**Impact**: If formalized, this would give the first machine-verified example of a natural mathematical structure that is a gyrogroup but not a group. It would open the door to formalizing Thomas precession in special relativity and to studying non-associative analogs of representation theory.

**Catalog References**: `Bridges/HyperbolicArithmetic.lean` (1D associativity proof), `Algebra/Foundations.lean` (critical_line_implies_unit_disk)

**Proof Strategy**: 
1. Define complex Möbius addition with conjugation: z ⊕ w = (z+w)/(1+conj(z)*w).
2. Define the gyration gyr[z,w] and prove it is a rotation.
3. Exhibit a concrete triple (z,w,u) where gyr[z,w](u) ≠ u using norm_num with complex arithmetic.
4. Prove the gyrogroup axioms (left loop property, left gyroassociative law).

**Domain Bridges**: Algebra <-> Geometry, Physics <-> NumberTheory

**Lineage**: Builds on the 1D associativity result (moebius_assoc) from this cycle, extending to 2D where associativity fails.

**Ambition**: grand_challenge

---

### Direction 2: Berggren Tree as Hyperbolic Lattice

**Conjecture**: The Berggren tree of primitive Pythagorean triples, when mapped to the Poincaré disk via (a,b,c) ↦ a/c, produces a lattice whose word metric is quasi-isometric to the tree metric of the ternary Berggren tree. Specifically, the hyperbolic distance d_H(a₁/c₁, a₂/c₂) is bounded above and below by linear functions of the tree distance in the Berggren tree.

**Test**: Compute d_H for all pairs of Pythagorean triples at Berggren depth ≤ 5 (at most 3^5 = 243 triples). Plot d_H vs tree distance and fit a linear regression. The conjecture predicts R² > 0.8.

**Impact**: This would establish that Pythagorean number theory has an intrinsic hyperbolic geometry, explaining the exponential growth of the Berggren tree as a consequence of negative curvature. It could lead to new bounds on the distribution of Pythagorean primes via hyperbolic methods.

**Catalog References**: `Algebra/Berggren.lean` (applyB₁, A_iter, A_closed), `Cryptography/BerggrenDiophantineLattice.lean` (lorentzForm, IsPythagoreanVec), `Bridges/HyperbolicArithmetic.lean` (pyth_abs_ratio_lt_one, pyth_moebius_closure)

**Proof Strategy**:
1. Define the map φ: PrimPythTriple → DiskPoint by φ(a,b,c) = a/c.
2. Show φ is injective (since distinct primitive triples give distinct ratios).
3. Express the three Berggren generators B₁, B₂, B₃ as compositions of Möbius additions.
4. Prove the quasi-isometry bound: C₁ · d_tree ≤ d_H(φ(t₁), φ(t₂)) ≤ C₂ · d_tree for explicit constants C₁, C₂.

**Domain Bridges**: NumberTheory <-> Geometry, Algebra <-> Cryptography

**Lineage**: Builds on pyth_moebius_closure and the Berggren tree formalization in Algebra/Berggren.lean.

**Ambition**: extension

---

### Direction 3: Hyperbolic Zeta Function Convergence

**Conjecture**: For a hyperbolic lattice Γ in the Poincaré disk with exponential growth rate δ (i.e., |B_Γ(R)| ~ C·e^{δR}), the hyperbolic zeta function ζ_Γ(s) = Σ_{γ ∈ Γ, γ≠0} |γ|^{-2s} converges for Re(s) > δ/2 and diverges for Re(s) < δ/2. The abscissa of convergence is exactly δ/2.

**Test**: For the binary tree lattice (δ = log 2), compute partial sums of ζ_Γ(s) for s = 0.3, 0.35, 0.4 (straddling log(2)/2 ≈ 0.347). Verify convergence above and divergence below.

**Impact**: This would give the first rigorous convergence result for a hyperbolic zeta function, establishing the analog of the abscissa of convergence for Dirichlet series. It connects lattice geometry (growth rate) to analytic number theory (convergence).

**Catalog References**: `Bridges/HyperbolicArithmetic.lean` (hyp_zeta_summand_diverges, orbit_growth_lower_bound, wordBall_exact)

**Proof Strategy**:
1. Define ζ_Γ(s) as a formal sum over lattice points with |γ|_H > ε.
2. Use wordBall_exact to count lattice points at each distance shell.
3. Bound the sum by a comparison with ∫ e^{δR} · e^{-2sR} dR = ∫ e^{(δ-2s)R} dR, which converges iff 2s > δ.
4. For the lower bound, use the sphere count to show divergence when 2s < δ.

**Domain Bridges**: NumberTheory <-> Geometry, Computation <-> Algebra

**Lineage**: Builds on the zeta summand reversal results and exponential growth theorem from this cycle.

**Ambition**: grand_challenge

---

### Direction 4: Möbius Iteration as Dynamical System

**Conjecture**: The map T_a: x ↦ a ⊕ x on (-1,1) has no periodic orbits other than the fixed point at the boundary. Equivalently, for a ≠ 0, the equation moebiusIterate(a, n) = moebiusIterate(a, m) has no solution with n ≠ m.

**Test**: For a = 1/3 and n, m ≤ 1000 with n ≠ m, verify |moebiusIterate(a,n) - moebiusIterate(a,m)| > 0.

**Impact**: This would complete the dynamical classification of Möbius iteration on the real disk: the system is topologically conjugate to a translation on ℝ via artanh, which has no periodic orbits. Formalizing this conjugacy would provide a template for studying more complex dynamical systems on hyperbolic spaces.

**Catalog References**: `Bridges/HyperbolicArithmetic.lean` (moebius_no_interior_fixed_point, moebius_iterate_strict_mono)

**Proof Strategy**:
1. Use the artanh isomorphism: moebiusIterate(a, n) = tanh(n · artanh(a)).
2. Since artanh(a) ≠ 0 for a ≠ 0, the values n · artanh(a) are all distinct.
3. Since tanh is injective, the iterates are all distinct.
4. This requires formalizing the artanh isomorphism tanh(artanh(a) + artanh(b)) = a ⊕ b, which is a Real.tanh/artanh identity.

**Domain Bridges**: Algebra <-> Physics (dynamical systems)

**Lineage**: Builds on moebius_no_interior_fixed_point (the n=1 case of no periodicity) and moebius_iterate_strict_mono from this cycle.

**Ambition**: extension

---

### Direction 5: Tropical-Hyperbolic Duality

**Conjecture**: There exists a natural functor from the category of tropical semirings to the category of Möbius gyrogroups, such that tropical addition (min/max) corresponds to a limiting case of Möbius addition as curvature → ∞.

**Test**: Define the rescaled Möbius addition a ⊕_κ b = (a+b)/(1+κab) where κ is a curvature parameter. Show that as κ → 0, a ⊕_κ b → a + b (flat/Euclidean), and study the behavior as κ → ∞ to see if a tropical-like structure emerges.

**Impact**: This would establish a formal bridge between tropical geometry and hyperbolic geometry, two areas that share the theme of "deformation of classical arithmetic." It could lead to tropical proofs of hyperbolic results and vice versa.

**Catalog References**: `Tropical/TropicalFactoring.lean` (tropical_fundamental_theorem_of_arithmetic), `Bridges/HyperbolicArithmetic.lean` (moebiusAdd, moebius_assoc)

**Proof Strategy**:
1. Define the κ-parametric family a ⊕_κ b = (a+b)/(1+κab).
2. Prove disk preservation for the appropriate κ-dependent disk.
3. Study the limit κ → ∞: show that the operation concentrates on {−1, 0, 1}, resembling a tropical structure.
4. Formalize the tropical-hyperbolic correspondence as a diagram of algebraic morphisms.

**Domain Bridges**: Tropical <-> Geometry, Algebra <-> NumberTheory

**Lineage**: Builds on the artanh isomorphism insight and tropical_fundamental_theorem_of_arithmetic.

**Ambition**: extension
