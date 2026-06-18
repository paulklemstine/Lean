# Equivariant Impossibility Spectra: An Algebraic Framework for Impossibility Theorems

## Abstract

We introduce the **impossibility spectrum**, a new algebraic invariant for pairs of G-sets that captures exactly which subgroup symmetries obstruct the existence of equivariant maps. For a group G acting on sets X and Y, the impossibility spectrum Σ(X, Y) is the collection of subgroups H ≤ G for which no H-equivariant map f: X → Y exists. We establish the fundamental structural properties of this invariant: upward closure in the subgroup lattice, preservation under conjugation, a transfer principle for isomorphic G-sets, and fixed-point and orbit-theoretic obstructions. We introduce the equivariance defect as a quantitative relaxation and prove its basic properties. All results are formalized and machine-verified in Lean 4 with the Mathlib library.

**Keywords:** equivariant maps, group actions, impossibility theorems, subgroup lattice, upper sets, equivariance defect

## 1. Introduction

Impossibility theorems are among the most profound results in mathematics. From the unsolvability of the quintic by radicals (Abel-Ruffini) to the undecidability of the halting problem (Turing), these results establish absolute limits on mathematical constructions. Despite their diversity, many impossibility theorems share a common structural feature: they arise from symmetry constraints that are incompatible with a desired transformation.

This paper formalizes this observation by introducing the **impossibility spectrum**, an algebraic invariant that captures the precise set of symmetry subgroups creating equivariant obstructions. Our framework unifies several disparate impossibility phenomena under a single algebraic roof and provides systematic tools for establishing new impossibility results.

### 1.1 Main Contributions

1. **Definition of the impossibility spectrum** Σ(X, Y) as a subset of Sub(G), the lattice of subgroups of G (Section 3).

2. **Upward Closure Theorem** (Theorem 3.1): Σ(X, Y) is an upper set in Sub(G). Impossibility propagates from subgroups to supergroups.

3. **Fixed-Point Obstruction** (Theorem 4.1): A cardinality mismatch between fixed-point sets provides a sufficient condition for membership in the spectrum.

4. **Orbit Preservation** (Theorem 4.2): Equivariant maps preserve the orbit decomposition, yielding counting obstructions.

5. **Stabilizer Monotonicity** (Theorem 4.3): G-equivariant maps induce a monotone map on stabilizers.

6. **Conjugation Invariance** (Theorem 5.1): The spectrum is invariant under conjugation of subgroups.

7. **Transfer Principle** (Theorem 5.2): Isomorphic G-sets have identical impossibility spectra.

8. **Equivariance Defect** (Section 6): A quantitative measure of symmetry breaking with formal properties.

All theorems are machine-verified in Lean 4 (v4.28.0) using the Mathlib library.

## 2. Preliminaries

### 2.1 Group Actions

Let G be a group and X a set. A (left) **group action** of G on X is a map G × X → X, written (g, x) ↦ g · x, satisfying:
- 1 · x = x for all x ∈ X
- (gh) · x = g · (h · x) for all g, h ∈ G and x ∈ X

A pair (X, ·) is called a **G-set**.

### 2.2 Equivariant Maps

Given G-sets X and Y and a subgroup H ≤ G, a function f: X → Y is **H-equivariant** if:

f(h · x) = h · f(x) for all h ∈ H, x ∈ X

When H = G, we simply say f is G-equivariant or equivariant.

### 2.3 Subgroup Lattice

The subgroups of G form a lattice Sub(G) under inclusion, with meet H ∧ K = H ∩ K and join H ∨ K = ⟨H ∪ K⟩. An **upper set** (or up-set, filter base) in Sub(G) is a subset S ⊆ Sub(G) such that if H ∈ S and H ≤ K, then K ∈ S.

## 3. The Impossibility Spectrum

### Definition 3.1

For a group G acting on sets X and Y, the **impossibility spectrum** is:

Σ(X, Y) = { H ≤ G : ¬∃ f: X → Y, f is H-equivariant }

### Theorem 3.1 (Upward Closure)

*The impossibility spectrum Σ(X, Y) is an upper set in Sub(G).*

**Proof sketch.** If H ≤ K and f is K-equivariant, then f is automatically H-equivariant (the equivariance condition for K includes all constraints from H as a special case). Contrapositively, if no H-equivariant map exists, no K-equivariant map exists. □

**Formalization:**
```lean
theorem ImpossibilitySpectrum.upward_closed {G : Type*} [Group G]
    {X Y : Type*} [MulAction G X] [MulAction G Y]
    {H K : Subgroup G} (hHK : H ≤ K)
    (hH : H ∈ ImpossibilitySpectrum G X Y) :
    K ∈ ImpossibilitySpectrum G X Y
```

### Corollary 3.2

*The impossibility spectrum forms an `IsUpperSet` in the subgroup lattice.*

### Theorem 3.3 (Trivial Subgroup Exclusion)

*If Y is nonempty, then ⊥ ∉ Σ(X, Y). The trivial subgroup never creates an obstruction.*

**Proof.** Any function f: X → Y is ⊥-equivariant, since the only element of ⊥ is the identity, and f(1 · x) = f(x) = 1 · f(x). □

### Theorem 3.4 (Self-Spectrum)

*Σ(X, X) = ∅. The identity map is always equivariant.*

## 4. Obstruction Theory

### 4.1 Fixed-Point Obstruction

**Definition.** The **fixed-point set** of H ≤ G acting on X is X^H = { x ∈ X : h · x = x for all h ∈ H }.

**Lemma 4.0 (Fixed-Point Preservation).** If f is H-equivariant, then f maps X^H into Y^H.

*Proof.* If x ∈ X^H and h ∈ H, then h · f(x) = f(h · x) = f(x), so f(x) ∈ Y^H. □

**Theorem 4.1 (Fixed-Point Cardinality Obstruction).** If X^H ≠ ∅ and Y^H = ∅, then H ∈ Σ(X, Y).

*Proof.* Any H-equivariant f would send elements of X^H to Y^H, but Y^H is empty. □

**Formalization:**
```lean
theorem ImpossibilitySpectrum.of_fixedPoint_empty {G : Type*} [Group G]
    {X Y : Type*} [MulAction G X] [MulAction G Y]
    {H : Subgroup G}
    (hX : ∃ x : X, ∀ h : G, h ∈ H → h • x = x)
    (hY : ∀ y : Y, ∃ h : G, h ∈ H ∧ h • y ≠ y) :
    H ∈ ImpossibilitySpectrum G X Y
```

### 4.2 Orbit Preservation

**Theorem 4.2.** If f is H-equivariant and y is in the H-orbit of x, then f(y) is in the H-orbit of f(x).

*Proof.* If y = h · x for some h ∈ H, then f(y) = f(h · x) = h · f(x). □

### 4.3 Stabilizer Monotonicity

**Theorem 4.3.** If f is G-equivariant, then Stab_G(x) ≤ Stab_G(f(x)) for all x.

*Proof.* If g ∈ Stab_G(x), then g · f(x) = f(g · x) = f(x). □

### 4.4 Orbit Size Obstruction

**Theorem 4.4.** If f is a G-equivariant bijection between finite G-sets, then |Orb_G(x)| = |Orb_G(f(x))| for all x.

*Proof.* The map y ↦ f(y) restricts to a bijection from Orb_G(x) to Orb_G(f(x)). This follows from orbit preservation (both directions, using f and f⁻¹). □

### 4.5 Free Action Obstruction

**Theorem 4.5.** If X has an H-fixed point, H ≠ {1}, and H acts freely on Y (no non-identity element fixes any point), then H ∈ Σ(X, Y).

This is an immediate corollary of the fixed-point obstruction.

## 5. Structural Properties

### 5.1 Conjugation Invariance

**Theorem 5.1.** For any g ∈ G, H ∈ Σ(X, Y) if and only if gHg⁻¹ ∈ Σ(X, Y).

*Proof.* If f is (gHg⁻¹)-equivariant, define f'(x) = g⁻¹ · f(g · x). For h ∈ H:
f'(h · x) = g⁻¹ · f(g · h · x) = g⁻¹ · f((ghg⁻¹) · g · x) = g⁻¹ · (ghg⁻¹) · f(g · x) = h · g⁻¹ · f(g · x) = h · f'(x)
So f' is H-equivariant. □

**Corollary.** The impossibility spectrum descends to a well-defined invariant on conjugacy classes of subgroups.

### 5.2 Transfer Principle

**Theorem 5.2.** If φ: X → X' is a G-equivariant bijection, then Σ(X, Y) = Σ(X', Y).

*Proof.* For the forward direction: if f': X' → Y is H-equivariant, then f' ∘ φ: X → Y is H-equivariant (composition of equivariant maps). For the reverse: using φ⁻¹, if f: X → Y is H-equivariant, then f ∘ φ⁻¹: X' → Y is H-equivariant (φ⁻¹ is G-equivariant since φ is a bijective G-map). □

### 5.3 Composition Properties

**Theorem 5.3.** The composition of H-equivariant maps is H-equivariant.

**Theorem 5.4 (Target Monotonicity).** If H ∈ Σ(X, Y) and there is a surjective H-equivariant map g: Y' → Y, then H ∈ Σ(X, Y').

## 6. Equivariance Defect

### Definition 6.1

For a finite group G acting on a metric space Y, the **equivariance defect** of f: X → Y at x ∈ X with respect to a subgroup H is:

δ_H(f, x) = sup_{h ∈ H} d(f(h · x), h · f(x))

### Theorem 6.1

*δ_H(f, x) ≥ 0 for all f, x, H.*

### Theorem 6.2

*If f is H-equivariant at x (i.e., f(h · x) = h · f(x) for all h ∈ H), then δ_H(f, x) = 0.*

## 7. Applications and Connections

### 7.1 Social Choice Theory

Arrow's impossibility theorem states that no social welfare function satisfying unanimity, independence of irrelevant alternatives, and non-dictatorship can exist for three or more candidates. In our framework, the symmetry group is the permutation group acting on rankings, and Arrow's conditions impose equivariance constraints. The impossibility spectrum identifies which subgroups of the permutation group create the obstruction.

### 7.2 Crystallography

The 230 crystallographic space groups act on Euclidean space. The impossibility spectrum for the action on Wyckoff positions characterizes which site symmetries are compatible with specific molecular orientations. The upward closure property means that if a molecular orientation breaks a point group symmetry, it automatically breaks all larger symmetries containing that point group.

### 7.3 Equivariant Neural Networks

In machine learning, equivariant neural networks (e.g., SE(3)-equivariant networks for molecular property prediction) must satisfy f(g · x) = g · f(x). The impossibility spectrum constrains which layer architectures can exist: if a desired input-output pair has a non-trivial spectrum, no equivariant layer can implement it.

### 7.4 Gauge Theory

In gauge field theory, gauge transformations act on field configurations. The impossibility spectrum identifies topological obstructions to gauge-equivariant field maps, providing a discrete algebraic counterpart to the topological obstructions captured by characteristic classes.

## 8. Computational Aspects

### 8.1 Algorithm for Finite Groups

For finite groups and finite sets, the impossibility spectrum can be computed by exhaustive search:

1. Enumerate all subgroups H of G.
2. For each H, enumerate all functions f: X → Y.
3. Check H-equivariance for each f.
4. H ∈ Σ if no equivariant f is found.

The complexity is O(|Sub(G)| · |Y|^|X| · |H| · |X|) in the worst case.

### 8.2 Optimizations

- **Upward closure pruning:** If H ∉ Σ, then no subgroup of H is in Σ. Process subgroups top-down.
- **Fixed-point pre-check:** Compute X^H and Y^H first; if X^H ≠ ∅ and Y^H = ∅, immediately conclude H ∈ Σ.
- **Orbit compatibility:** Check orbit size compatibility before exhaustive search.
- **Conjugation reduction:** Only process one representative per conjugacy class.

## 9. Open Problems and Conjectures

### Conjecture 9.1 (Spectral Completeness)

For any finite group G and any upper set S in Sub(G) with ⊥ ∉ S, there exist finite G-sets X, Y such that Σ(X, Y) = S.

**Significance:** If true, this would establish the impossibility spectrum as a *complete* classification — every theoretically possible pattern of obstruction is realized.

### Conjecture 9.2 (Spectral Dimension)

For finite groups, define the **spectral dimension** of G as the maximum size of the impossibility spectrum over all pairs of finite G-sets. Then dim(G) = |Sub(G)| - 1 (every upper set not containing ⊥ is realized).

### Problem 9.3 (Approximate Equivariance)

Characterize the infimum of the equivariance defect over all maps f: X → Y when H ∈ Σ(X, Y). How does this "spectral gap" depend on the group-theoretic properties of H?

## 10. Conclusion

The impossibility spectrum provides a unified algebraic framework for analyzing equivariant obstructions. Its key properties — upward closure, conjugation invariance, the transfer principle — give it the character of a classification theory. The equivariance defect extends the framework to approximate symmetry, bridging the gap between idealized impossibility theorems and practical applications.

The formalization in Lean 4 ensures that all results are machine-verified, providing maximum confidence in the mathematical foundations. The framework is extensible: new obstruction methods (homological, representation-theoretic, topological) can be developed within the same algebraic setting.

## References

1. M. Aschbacher, *Finite Group Theory*, Cambridge University Press, 2000.
2. T. tom Dieck, *Transformation Groups*, de Gruyter, 1987.
3. K. Arrow, "A difficulty in the concept of social welfare," *Journal of Political Economy*, 58(4), 1950.
4. The Mathlib Community, *Mathlib: a unified library of mathematics formalized in Lean 4*, 2024.
5. J. P. Serre, *Linear Representations of Finite Groups*, Springer, 1977.
6. A. Hatcher, *Algebraic Topology*, Cambridge University Press, 2002.
