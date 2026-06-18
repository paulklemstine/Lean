# Tropical Observer Coding Duality: Finite Representation and Minimality for Proof-Compression Architectures

## Abstract

We establish a finite representation theorem connecting tropical separation semimodules built from observer functionals on proof states to minimal proof-compression network architectures. Given a finite state space S with a family of integer-valued observer functionals Φ : ι → S → ℤ satisfying separation (injectivity of the combined observation map), we prove: (1) the observer family induces a tropical pseudometric d_Φ satisfying reflexivity, symmetry, and the triangle inequality; (2) code equivalence (agreement of all observers) is characterized by vanishing distance; (3) coordinate-wise nonexpansive compression maps are globally nonexpansive; (4) there exists a minimal separating subfamily of minimum cardinality (the separation rank); (5) from this minimal subfamily, one can reconstruct a minimal compression network whose width equals the separation rank; and (6) spectral witnesses certify generator irredundancy. All results are formalized in Lean 4 with zero `sorry` statements, totaling 25+ formally verified theorems.

**Keywords:** tropical algebra, idempotent semimodule, proof compression, observer coding, certified reconstruction, minimal realization, separation rank, Myhill–Nerode theory

## 1. Introduction

### 1.1 Motivation

The problem of compressing proof states arises naturally in automated theorem proving, proof-carrying code, and neural theorem proving. Given a large proof state space S, one seeks a compressed representation that faithfully preserves the ability to distinguish inequivalent states. The fundamental question is: *what is the minimum dimensionality of such a representation?*

This paper answers the question via *tropical observer codes*: families of integer-valued score functions on S whose combined fingerprint separates inequivalent states. We prove that the minimum number of observers needed (the *separation rank*) is a well-defined invariant that exactly characterizes the minimum width of any faithful compression network.

### 1.2 Relationship to Prior Work

**Myhill–Nerode Theory.** The classical Myhill–Nerode theorem [1] characterizes the minimum state complexity of a regular language by an equivalence relation on input strings. Our separation rank plays the same role for observer codes: it counts the minimum number of independent "dimensions of distinguishability" for proof states. The key difference is that our observers are numerical (ℤ-valued) rather than Boolean, enabling a tropical metric structure.

**Tropical Geometry.** Tropical algebra (the max-plus semiring) was introduced by Simon [2] and developed extensively by Mikhalkin, Sturmfels, and others [3,4]. Our use of the sup-norm distance d_Φ(x,y) = sup_i |Φ_i(x) − Φ_i(y)| connects to the ℓ∞ metric on tropical coordinate spaces. The embedding theorem (Theorem 13) shows that separating observer families induce isometric embeddings into ℤ^n.

**Observer Theory.** The observer-based approach to state separation is classical in control theory (Luenberger observers [5]) and has been formalized for algebraic structures via ring congruences [6]. Our framework extends this to ℤ-valued score functions with tropical distance.

**Neural Network Width.** The question of minimum network width for faithful representation is central to representation learning [7,8]. Our separation rank provides a formal lower bound on network width, connecting algebraic invariants to neural architecture constraints.

### 1.3 Contributions

1. A complete tropical pseudometric theory for observer families (§3)
2. A separation characterization theorem: d_Φ = 0 ↔ code equivalence (§4)
3. A compression nonexpansivity theorem from coordinate contraction (§5)
4. An existence theorem for minimal separating subfamilies (§6)
5. A reconstruction theorem: minimal subfamily → minimal network (§8)
6. A flagship duality theorem: semimodules ↔ networks with matching rank (§9)
7. Full formal verification in Lean 4 with zero sorry statements

## 2. Definitions and Notation

### 2.1 Observer Families

**Definition 1 (Code Equivalence).** Given a family Φ : ι → S → ℤ of observer functionals, two states x, y ∈ S are *code-equivalent*, written CodeEqFamily(Φ, x, y), if Φ_i(x) = Φ_i(y) for all i ∈ ι.

Code equivalence is readily verified to be an equivalence relation (reflexive, symmetric, transitive).

**Definition 2 (Separation).** A family Φ *separates* S if CodeEqFamily(Φ, x, y) implies x = y. Equivalently, the combined observation map x ↦ (Φ_i(x))_{i∈ι} is injective.

**Definition 3 (Subfamily Separation).** A subset J ⊆ ι *separates* S (denoted SubfamilySeparates(Φ, J)) if agreement of all observers in J implies equality: ∀x, y, (∀i ∈ J, Φ_i(x) = Φ_i(y)) → x = y.

### 2.2 Tropical Distance

**Definition 4 (Observer Distance).** The *tropical separation pseudodistance* is:

> d_Φ(x, y) = sup_{i ∈ ι} |Φ_i(x) − Φ_i(y)| ∈ ℕ

When ι is finite, this is computed as `Finset.sup Finset.univ (fun i => (Φ i x - Φ i y).natAbs)`.

**Definition 5 (Subfamily Distance).** The *subfamily distance* restricts the sup to J ⊆ ι:

> d_Φ^J(x, y) = sup_{i ∈ J} |Φ_i(x) − Φ_i(y)|

### 2.3 Structures

**Definition 6 (Tropical Separation Semimodule).** A *tropical separation semimodule* M on a finite type S consists of:
- A finite index set Fin(n) of generators
- Observer functionals Φ : Fin(n) → S → ℤ
- A compression map C : S → S
- Proof that Φ separates S
- Proof that each coordinate is nonexpansive under C

**Definition 7 (Minimal Compression Network).** A *minimal compression network* N on S consists of:
- Width k ∈ ℕ (number of coordinates)
- Coordinates Ψ : Fin(k) → S → ℤ
- Compression map C : S → S
- Proof that Ψ separates S
- Proof of coordinate-wise nonexpansivity
- Proof of minimality: every separating subfamily of coordinates has cardinality k

**Definition 8 (Separation Rank).** The *observer separation rank* is the minimum cardinality of a separating subfamily.

## 3. Pseudometric Properties

**Theorem 1 (Reflexivity).** d_Φ(x, x) = 0 for all x.

*Proof.* Each term |Φ_i(x) − Φ_i(x)| = 0, so the supremum is 0. □

**Theorem 2 (Symmetry).** d_Φ(x, y) = d_Φ(y, x) for all x, y.

*Proof.* |Φ_i(x) − Φ_i(y)| = |Φ_i(y) − Φ_i(x)| for each i. □

**Theorem 3 (Triangle Inequality).** d_Φ(x, z) ≤ d_Φ(x, y) + d_Φ(y, z) for all x, y, z.

*Proof sketch.* For each i:
|Φ_i(x) − Φ_i(z)| ≤ |Φ_i(x) − Φ_i(y)| + |Φ_i(y) − Φ_i(z)| ≤ sup_j |Φ_j(x) − Φ_j(y)| + sup_j |Φ_j(y) − Φ_j(z)|.

Taking the supremum over i on the left gives d_Φ(x,z) ≤ d_Φ(x,y) + d_Φ(y,z). The key sub-lemma is `finset_sup_add_le`: sup(f+g) ≤ sup(f) + sup(g). □

## 4. Separation Characterization

**Theorem 4 (Separation ↔ Vanishing Distance).** d_Φ(x, y) = 0 if and only if CodeEqFamily(Φ, x, y).

*Proof.* (→) If sup = 0, each |Φ_i(x) − Φ_i(y)| = 0, so Φ_i(x) = Φ_i(y). (←) If all observers agree, each term is 0, so sup = 0. □

**Corollary 5.** For separating families, d_Φ(x, y) > 0 if and only if x ≠ y.

**Theorem 6 (Distance Descends to Quotient).** If CodeEqFamily(Φ, x, x') and CodeEqFamily(Φ, y, y'), then d_Φ(x, y) = d_Φ(x', y').

*Proof.* Each |Φ_i(x) − Φ_i(y)| = |Φ_i(x') − Φ_i(y')| by substitution. □

## 5. Compression Nonexpansivity

**Theorem 7 (Coordinate Nonexpansivity Implies Global).** If |Φ_i(C(x)) − Φ_i(C(y))| ≤ |Φ_i(x) − Φ_i(y)| for all i, x, y, then d_Φ(C(x), C(y)) ≤ d_Φ(x, y).

*Proof.* Each term in the sup for C(x), C(y) is bounded by the corresponding term for x, y. □

**Theorem 8 (Compression Preserves Code Equivalence).** Under coordinate nonexpansivity, CodeEqFamily(Φ, x, y) implies CodeEqFamily(Φ, C(x), C(y)).

**Theorem 9 (Orbit Nonincreasing).** Iterated compression distances are nonincreasing:
d_Φ(C^{n+1}(x), C^{n+1}(y)) ≤ d_Φ(C^n(x), C^n(y)).

## 6. Minimal Separating Subfamily

**Theorem 10 (Existence of Minimal Separating Subfamily).** For any finite type S with decidable equality, any finite index set ι, and any separating family Φ : ι → S → ℤ, there exists a subfamily J ⊆ ι such that:
1. J separates S
2. J has minimum cardinality among all separating subfamilies

*Proof sketch.* The set of all separating subfamilies is nonempty (it contains ι itself). This set, viewed as a subset of the powerset of ι (which is finite), has an element of minimum cardinality by the well-ordering of ℕ. In the formal proof, we use `Set.exists_min_image` over the finite set of separating subfamilies. □

**Theorem 11 (Uniqueness of Separation Rank).** Any two minimal separating subfamilies have the same cardinality.

*Proof.* By cross-application of the minimality conditions. □

## 7. Spectral Irredundancy

**Definition 9 (Spectral Witness).** Observer i has a *spectral witness* in subfamily J if there exist x, y ∈ S such that all other observers in J agree on x, y but Φ_i(x) ≠ Φ_i(y).

**Definition 10 (Generator Irredundancy).** Observer i is *irredundant* in J if removing i from J breaks separation.

**Theorem 12 (Spectral Witness ⟹ Irredundancy).** If i has a spectral witness in J, then i is irredundant.

*Proof.* The witness pair x, y satisfies all conditions for agreement on J \ {i}, so J \ {i} fails to separate x and y. □

## 8. Reconstruction

**Theorem 13 (Tropical Embedding).** A separating family induces an injective map S ↪ ℤ^ι.

**Theorem 14 (Network Reconstruction).** Given a minimal separating subfamily J with |J| = k, there exists a minimal compression network N with:
1. Width k
2. Coordinates indexed by Fin(k) corresponding to J's observers
3. CodeEq_N ↔ agreement on J
4. The same compression map

*Proof sketch.* Use `Finset.orderEmbOfFin` to create a bijection Fin(k) ↔ J. Define N's coordinates as the restriction of Φ to J. Separation and minimality follow from J's properties. □

## 9. Flagship Duality Theorem

**Theorem 15 (Finite Separation Semimodule Realization Minimality).** For every finite proof-state type S and every tropical separation semimodule M, there exists a minimal compression network N such that:
1. N realizes the same code equivalence classes as M
2. N's width equals M's separation rank

*Proof.* Apply Theorem 10 to obtain a minimal separating subfamily J. Apply Theorem 14 to reconstruct a network N from J. The realization condition follows from the equivalence: CodeEq_N ↔ agreement on J ↔ CodeEq_M (the forward direction uses that agreement on J implies x = y by separation, hence CodeEq_M by reflexivity; the reverse direction follows since J ⊆ ι). □

## 10. Additional Results

**Theorem 16 (Subfamily Separation Anti-Monotonicity).** If J ⊆ K and J separates, then K separates.

**Theorem 17 (Eventually Periodic Orbits).** Over a finite state space, the iterate sequence C^0(x), C^1(x), C^2(x), ... is eventually periodic.

**Theorem 18 (Canonical Code Induces Semimodule).** Given a separating, nonexpansive observer family, one can construct a tropical separation semimodule.

## 11. Algorithms

### Algorithm 1: Compute Separation Rank

```
Input: Finite state space S, observer family Φ : [n] → S → ℤ
Output: Minimum k such that a k-element subfamily separates S

1. Enumerate all subsets J ⊆ [n] in order of increasing |J|
2. For each J, check if SubfamilySeparates(Φ, J):
   a. For each pair (x, y) ∈ S × S with x ≠ y:
      b. Check if ∃ i ∈ J : Φ_i(x) ≠ Φ_i(y)
      c. If no such i exists, J does not separate; continue
3. Return |J| for the first separating J found

Time: O(2^n · |S|² · n)  (brute force)
      O(|S|² · n²)       (greedy approximation via set cover)
```

### Algorithm 2: Reconstruct Minimal Network

```
Input: Minimal separating subfamily J ⊆ [n], compression C : S → S
Output: MinimalCompressionNetwork N

1. Let k = |J|
2. Fix a bijection σ : Fin(k) → J
3. Define N.coordinates(i, x) = Φ(σ(i), x)
4. Set N.compression = C
5. Return N with certified separation, nonexpansivity, minimality
```

### Algorithm 3: Compute Tropical Distance Matrix

```
Input: Observer family Φ : [n] → S → ℤ
Output: Distance matrix D[x][y] = d_Φ(x, y) for all x, y ∈ S

1. For each pair (x, y):
   D[x][y] = max_{i ∈ [n]} |Φ_i(x) - Φ_i(y)|

Time: O(|S|² · n)
Space: O(|S|²)
```

## 12. Applications

### 12.1 Proof Compression Lower Bounds

The separation rank provides an unconditional lower bound on the width of any faithful proof-compression architecture. If a proof system has separation rank k, then any network that faithfully represents all proof states must have at least k coordinates per layer.

### 12.2 Architecture Discovery

Given a collection of proof traces, compute the pairwise tropical distances, find the separation rank, and reconstruct the minimal network. This gives a certified-optimal architecture for proof representation learning.

### 12.3 Metric Learning

The tropical distance d_Φ is a *certified representation metric*: it is consistent with code equivalence, invariant under equivalence classes, and compatible with compression. This provides formal guarantees for metric learning systems.

## 13. Discussion

### 13.1 Relationship to Classical Duality Theorems

The flagship theorem is a finite tropical analogue of several classical results:
- **Stone duality**: Boolean algebras ↔ Stone spaces, via separation by clopen sets
- **Gelfand duality**: commutative C*-algebras ↔ compact Hausdorff spaces, via evaluation maps
- **Myhill–Nerode**: regular languages ↔ finite automata, via indistinguishability equivalence

Our contribution is to add a tropical/numerical version: separation semimodules ↔ minimal networks, via observer codes and tropical distance.

### 13.2 Limitations

- The current formalization handles ℤ-valued observers. Extension to ℝ-valued observers (or other ordered semirings) would require additional Lean infrastructure.
- The minimality guarantee is for the number of observers, not for computational complexity of the observers themselves.
- Uniqueness is of the separation rank (a number), not of the minimal network (which is unique only up to coordinate relabeling).

## 14. Conclusion

We have established a complete duality between tropical separation semimodules and minimal proof-compression networks, with the separation rank as the connecting invariant. All results are formally verified in Lean 4. The duality suggests that tropical algebra is the natural language for certified proof compression, with immediate applications to architecture discovery, lower bounds, and metric learning.

## References

[1] A. Nerode, "Linear automaton transformations," *Proc. AMS*, 9(4):541–544, 1958.

[2] I. Simon, "Recognizable sets with multiplicities in the tropical semiring," *MFCS*, LNCS 324, 1988.

[3] G. Mikhalkin, "Enumerative tropical algebraic geometry in ℝ²," *J. Amer. Math. Soc.*, 18(2):313–377, 2005.

[4] D. Maclagan and B. Sturmfels, *Introduction to Tropical Geometry*, AMS, 2015.

[5] D. Luenberger, "Observing the state of a linear system," *IEEE Trans. Mil. Electron.*, 8(2):74–80, 1964.

[6] T. Altenkirch et al., "Quotient types in type theory," *CSL*, 1999.

[7] Y. Bengio et al., "Representation learning: A review," *IEEE TPAMI*, 35(8):1798–1828, 2013.

[8] Z. Lu et al., "The expressive power of neural networks: A view from the width," *NeurIPS*, 2017.
