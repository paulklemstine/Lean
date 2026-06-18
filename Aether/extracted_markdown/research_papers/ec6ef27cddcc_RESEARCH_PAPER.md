# Galois Theory of Cellular Automata: Reversibility Groups and Orbital Structure

## Abstract

We develop a Galois-theoretic framework for reversible cellular automata (CAs) on finite periodic configurations. The **reversibility group** — the group of shift-equivariant permutations of the configuration space — is identified with the centralizer of the shift permutation in the symmetric group (Theorem 3.1). We prove that this group preserves the orbital structure of the shift (Theorem 4.2), and introduce a novel **CA Galois Correspondence** connecting subgroups of the reversibility group to families of invariant subsets (Section 5). All main results are formalized and verified in the Lean 4 proof assistant with the Mathlib library. Computational experiments demonstrate that the reversibility ratio |Rev|/|Sym| exhibits super-exponential decay, and we characterize the six reversible elementary CA rules as generators of an abelian group.

**Keywords**: cellular automata, reversibility, shift-equivariance, centralizer, Galois correspondence, formal verification

---

## 1. Introduction

A cellular automaton (CA) on a periodic lattice ℤ/nℤ over alphabet *A* transforms configurations *c*: ℤ/nℤ → *A* by simultaneously updating each cell based on a local rule applied to its neighborhood. The fundamental question of **reversibility** — whether the global map is bijective — connects to computation theory [1], thermodynamics [2], and algebraic dynamics [3].

By the Curtis-Hedlund-Lyndon theorem [4], a CA map on the full shift ℤ is continuous and shift-equivariant if and only if it is defined by a local rule. For finite periodic configurations, the analogous characterization identifies CAs with shift-equivariant maps. We study the group structure of the reversible (bijective) CAs.

### 1.1 Main Contributions

1. **Centralizer Identification** (Theorem 3.1): The reversibility group equals the centralizer of the shift in the symmetric group, established by proving that commuting with the single shift generator implies commuting with all shifts.

2. **Orbital Structure Theorems** (Section 4): Shift-equivariant permutations preserve shift orbits (Theorem 4.2), map fixed configurations to fixed configurations (Theorem 4.3), and descend to well-defined actions on the orbit space (Theorem 4.4).

3. **CA Galois Correspondence** (Section 5): A novel Galois connection between subgroups of the reversibility group and families of shift-invariant subsets, with monotonicity (Theorem 5.1) and a stabilizer construction.

4. **Quantitative Analysis** (Section 6): The reversibility index [Sym : Rev] exhibits super-exponential growth, computed exactly via the centralizer formula.

---

## 2. Definitions

### 2.1 Configuration Space and Shift

Let *A* be a finite alphabet and *n* ≥ 1 an integer. The **configuration space** is the set *A*^(ℤ/nℤ) of functions from ℤ/nℤ to *A*.

**Definition 2.1** (Shift). For *k* ∈ ℤ/nℤ, the **shift operator** σ_k: *A*^(ℤ/nℤ) → *A*^(ℤ/nℤ) is defined by σ_k(c)(i) = c(i + k).

The shift satisfies σ₀ = id and σ_k ∘ σ_l = σ_{l+k}.

### 2.2 Shift-Equivariance

**Definition 2.2** (Shift-Equivariance). A map *F*: *A*^(ℤ/nℤ) → *A*^(ℤ/nℤ) is **shift-equivariant** if F ∘ σ_k = σ_k ∘ F for all *k* ∈ ℤ/nℤ.

### 2.3 Reversibility Group

**Definition 2.3** (Reversibility Group). The **reversibility group** Rev(n, A) is the subgroup of Sym(*A*^(ℤ/nℤ)) consisting of all shift-equivariant permutations.

**Theorem 2.4** (Group Structure). Rev(n, A) is indeed a subgroup:
- (Identity) The identity is shift-equivariant.
- (Closure) The composition of shift-equivariant maps is shift-equivariant.
- (Inverse) The inverse of a shift-equivariant bijection is shift-equivariant.

The non-trivial part is the closure under inverses. The proof uses the equation:
e(σ_k(c)) = σ_k(e(c)) implies e⁻¹(σ_k(d)) = σ_k(e⁻¹(d)) by substituting d = e(c).

---

## 3. The Centralizer Identification

### 3.1 Main Theorem

**Theorem 3.1** (Reversibility = Centralizer). Rev(n, A) equals the centralizer of the shift permutation σ₁ in Sym(*A*^(ℤ/nℤ)):

Rev(n, A) = C_{Sym}(σ₁) = {e ∈ Sym(*A*^(ℤ/nℤ)) | e ∘ σ₁ = σ₁ ∘ e}

*Proof sketch.* The forward direction (Rev ⊆ C) is immediate: take k = 1 in the shift-equivariance condition. The reverse direction (C ⊆ Rev) requires showing that commuting with σ₁ implies commuting with σ_k for all k. We prove by induction on m ∈ ℕ that e ∘ σ^m = σ^m ∘ e, using the fact that σ^m = σ_m on configurations. Since every k ∈ ℤ/nℤ is represented by some m < n, this gives the full result.

### 3.2 Centralizer Formula

By the centralizer formula for symmetric groups, if σ₁ has cycle type (d₁^{m₁}, d₂^{m₂}, ..., d_r^{m_r}), then:

|Rev(n, A)| = |C_{Sym}(σ₁)| = Π_i (d_i^{m_i} · m_i!)

### 3.3 Cycle Type of the Shift

The cycle type of σ₁ on {0,1}^(ℤ/nℤ) is determined by the number of binary necklaces of each period. The number of orbits of length *d* (where *d* | *n*) equals the number of binary strings of length *n* with minimal period *d*, divided by *d*:

m_d = (1/d) Σ_{e|d} μ(d/e) · 2^e

where μ is the Möbius function.

**Example** (n = 3): The shift on {0,1}³ has cycle type (1², 3²):
- 2 fixed points: 000, 111
- 2 orbits of size 3: {001, 010, 100}, {011, 110, 101}
- |Rev(3, {0,1})| = 1² · 2! · 3² · 2! = 36

---

## 4. Orbital Structure

### 4.1 Shift Orbits

**Definition 4.1** (Shift Orbit). The **shift orbit** of *c* is O(c) = {σ_k(c) | k ∈ ℤ/nℤ}.

**Theorem 4.2** (Orbit Image). For any e ∈ Rev(n, A), e(O(c)) = O(e(c)). Shift-equivariant permutations map orbits to orbits bijectively.

*Proof.* (⊆) If d = σ_k(c), then e(d) = e(σ_k(c)) = σ_k(e(c)) ∈ O(e(c)). (⊇) If d = σ_k(e(c)), then d = e(σ_k(c)) by shift-equivariance, and σ_k(c) ∈ O(c). □

### 4.2 Fixed Configurations

**Definition 4.3** (Shift-Fixed). A configuration *c* is **shift-fixed** if σ_k(c) = c for all *k*, equivalently, *c* is constant.

**Theorem 4.4** (Fixed Point Preservation). For any e ∈ Rev(n, A), if *c* is shift-fixed then so is e(c).

*Proof.* σ_k(e(c)) = e(σ_k(c)) = e(c). □

**Theorem 4.5** (Fixed Point Count). For binary configurations, |Fix| = 2 (the all-zeros and all-ones configurations), regardless of *n*.

### 4.3 Action Descent

**Theorem 4.6** (Descent to Orbits). Shift equivalence (c ~ d iff d ∈ O(c)) is an equivalence relation, and the action of Rev(n, A) descends to a well-defined action on the quotient space *A*^(ℤ/nℤ)/~ (the orbit space).

---

## 5. The CA Galois Correspondence

### 5.1 Definition

**Definition 5.1** (Invariant Sets). For a subgroup *H* ≤ Rev(n, A):
Inv(H) = {S ⊆ *A*^(ℤ/nℤ) | S is shift-invariant and ∀ e ∈ H, e(S) ⊆ S}

**Definition 5.2** (Stabilizer Subgroup). For a family *F* of subsets:
Stab(F) = {e ∈ Rev(n, A) | ∀ S ∈ F, e(S) ⊆ S}

### 5.2 Galois Connection Properties

**Theorem 5.3** (Antitonicity). The map H ↦ Inv(H) is antitone: if H ≤ K then Inv(K) ⊆ Inv(H).

*Proof.* If S is preserved by all of K, it is preserved by all of H ⊆ K. □

**Theorem 5.4** (Stabilizer is a Subgroup). Stab(F) is indeed a subgroup of Rev(n, A). The non-trivial part is closure under inverses: since e is a bijection and maps the finite set S into itself, e restricted to S is surjective, so e⁻¹ also maps S into S.

### 5.3 Interpretation

The Galois correspondence encodes a hierarchy of observational granularity:
- **Trivial subgroup** {id}: Inv({id}) contains all shift-invariant sets.
- **Full group** Rev: Inv(Rev) contains only the orbits preserved by all reversible CAs — the coarsest partition.
- **Intermediate subgroups**: capture intermediate levels of dynamical structure.

This is directly analogous to the classical Galois correspondence where larger subgroups correspond to smaller (less resolved) intermediate fields.

---

## 6. Quantitative Analysis

### 6.1 Reversibility Index

| n | |A^n| | # Orbits | |Rev| | |Sym| | [Sym:Rev] |
|---|-------|----------|-------|-------|-----------|
| 1 | 2     | 2        | 2     | 2     | 1         |
| 2 | 4     | 3        | 4     | 24    | 6         |
| 3 | 8     | 4        | 36    | 40320 | 1120      |
| 4 | 16    | 6        | 1536  | 2.1×10¹³ | 1.4×10¹⁰ |
| 5 | 32    | 8        | 2.3×10⁷ | 2.6×10³⁵ | 1.2×10²⁸ |
| 6 | 64    | 14       | 2.6×10¹⁴ | 1.3×10⁸⁹ | 4.8×10⁷⁴ |

The reversibility index grows super-exponentially, confirming that reversible CAs become vanishingly rare as the configuration space grows.

### 6.2 Reversible Elementary CAs

Among the 256 elementary CA rules (radius 1, binary), exactly 6 are reversible: Rules 15, 51, 85, 170, 204, 240. These correspond to:
- Identity (Rule 204)
- Left shift (Rule 170) and right shift (Rule 240)
- Complement (Rule 51)
- Complement + left shift (Rule 85) and complement + right shift (Rule 15)

These generate a group isomorphic to S₃ or ℤ/6ℤ depending on the period.

---

## 7. Related Work

The Curtis-Hedlund-Lyndon theorem [4] provides the topological foundation. Kari [5] showed that reversibility is decidable for 1D CAs but undecidable in dimension ≥ 2. The algebraic structure of reversible CAs was studied by Ceccherini-Silberstein and Coornaert [6] in the context of group theory. Our contribution is the explicit Galois correspondence and the formalized centralizer identification.

---

## 8. Future Directions

1. **Higher-dimensional CAs**: Does the centralizer identification generalize to ℤ^d lattices, where the shift is replaced by d commuting translations?

2. **Infinite configurations**: Extending the Galois correspondence to the full shift space ℤ requires topological considerations (compact-open topology on the automorphism group).

3. **Wreath product decomposition**: Making explicit the isomorphism Rev(n, A) ≅ Π_d (ℤ/dℤ ≀ S_{m_d}) in the formal proof.

4. **Computational complexity**: What is the complexity of computing the orbit structure and Rev(n, A) for given n and |A|?

---

## References

[1] T. Toffoli, "Computation and construction universality of reversible cellular automata," J. Comput. Syst. Sci., 1977.

[2] E. Fredkin and T. Toffoli, "Conservative logic," Int. J. Theor. Phys., 1982.

[3] G. A. Hedlund, "Endomorphisms and automorphisms of the shift dynamical system," Math. Syst. Theory, 1969.

[4] M. Ceccherini-Silberstein and M. Coornaert, *Cellular Automata and Groups*, Springer, 2010.

[5] J. Kari, "Reversibility and surjectivity problems of cellular automata," J. Comput. Syst. Sci., 1994.

[6] D. Lind and B. Marcus, *An Introduction to Symbolic Dynamics and Coding*, Cambridge, 1995.
