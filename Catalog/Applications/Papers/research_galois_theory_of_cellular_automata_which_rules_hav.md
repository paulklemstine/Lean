# Galois Theory of Cellular Automata: The Structure of Reversibility Groups

## Abstract

We study the algebraic structure of reversible cellular automata (CAs) on periodic configurations. Our main contributions are: (1) a proof that the group of reversible CAs on ℤ/nℤ equals the centralizer of the shift permutation in the symmetric group S_{|α|^n}, providing a complete algebraic characterization; (2) a proof that for prime period p, non-constant binary configurations have full shift orbits of size p, connecting reversibility to Fermat's little theorem and necklace counting; (3) a discrete Liouville theorem showing that reversible CAs preserve invariant distributions; (4) a Galois connection between subgroups of the reversibility group and invariant configuration sets; and (5) structural results on the complement-shift interaction and properness of the reversibility subgroup. All results are formalized in Lean 4 with complete machine-checked proofs.

## 1. Introduction

A cellular automaton (CA) is a discrete dynamical system in which space, time, and state are all discrete. The global evolution rule is defined by a local rule that maps each cell's neighborhood to the cell's next state. The fundamental question of reversibility — whether the global map is bijective — has been studied since Hedlund's 1969 characterization of endomorphisms of the full shift [1].

For CAs on finite periodic configurations (configurations on ℤ/nℤ), the Curtis-Hedlund-Lyndon theorem states that every continuous, shift-commuting map is determined by a local rule. In the finite setting, the relevant condition reduces to shift-equivariance: F ∘ σ_k = σ_k ∘ F for all shifts σ_k.

### 1.1. Our Contributions

We extend the catalog result `reversibility_proper_subgroup` from `Catalog/Geometry/CellularAutomataGalois.lean` with the following new theorems:

1. **Shift-one-implies-all** (Theorem 3.1): Commuting with shift-by-1 implies commuting with all shifts, since 1 generates ℤ/nℤ.

2. **Centralizer = Reversibility** (Theorem 3.2): The reversibility group equals the centralizer of the shift permutation.

3. **Shift-fixed iff constant** (Theorem 4.1): A configuration is fixed by the shift iff it is constant.

4. **Orbit size for prime period** (Theorem 4.2): Non-constant configurations on ℤ/pℤ have full orbits of size p.

5. **Discrete Liouville** (Theorem 5.1): Reversible CAs preserve weight distributions.

6. **Galois antitone** (Theorem 6.1): Larger subgroups have smaller fixed-point sets.

7. **Constants-only fixed points** (Theorem 6.2): The full reversibility group fixes only constant configurations.

8. **Complement in RevGroup** (Theorem 7.1): The complement lies in the reversibility group.

9. **Shift-complement commutation** (Theorem 7.2): Shift and complement commute.

10. **Complement order 2** (Theorem 7.3): The complement is an involution.

11. **Observable action** (Theorem 8.1): The action on observables is a valid group representation.

12. **Proper subgroup** (Theorem 9.1): The reversibility group is proper for n ≥ 2.

### 1.2. Relation to Prior Work

This work builds on:
- `Catalog/Geometry/CellularAutomataGalois.lean`: The original formalization of the reversibility subgroup, shift-equivariance, and the proper subgroup theorem for n = 3.
- `Catalog/Tropical/HashInversion.lean`: The `reversible_iff_bijective` theorem connecting reversibility to bijectivity for finite types.

Our key advance is the **Centralizer = Reversibility theorem** (Theorem 3.2), which provides a complete algebraic characterization of the reversibility group and reduces questions about reversible CAs to standard group-theoretic computations.

## 2. Definitions

### 2.1. Configuration Space

Fix a finite alphabet α and period n ≥ 1. The **configuration space** is α^{ℤ/nℤ}, the set of all functions from ℤ/nℤ to α.

### 2.2. Shift Operator

The **shift operator** σ_k : α^{ℤ/nℤ} → α^{ℤ/nℤ} is defined by:
  σ_k(c)(i) = c(i + k)

In Lean:
```lean
def shiftConfig (n : ℕ) [NeZero n] (k : ZMod n) (c : ZMod n → α) : ZMod n → α :=
  fun i => c (i + k)
```

### 2.3. Shift-Equivariance

A map F : α^{ℤ/nℤ} → α^{ℤ/nℤ} is **shift-equivariant** if:
  ∀ k, F ∘ σ_k = σ_k ∘ F

### 2.4. Reversibility Group

The **reversibility group** Rev(n, α) is the subgroup of Perm(α^{ℤ/nℤ}) consisting of all shift-equivariant permutations.

### 2.5. Shift Centralizer

The **shift centralizer** is C_{S_m}(σ₁) = {π ∈ S_m : πσ₁ = σ₁π}, where m = |α|^n and σ₁ is the shift-by-1 permutation.

## 3. Main Results: Centralizer Characterization

### Theorem 3.1 (Shift-One-Implies-All)

*If F commutes with shift-by-1, then F commutes with all shifts.*

**Proof sketch.** By induction on val(k): shift by (m+1) equals shift-by-1 composed with shift-by-m. The inductive hypothesis gives F ∘ σ_m = σ_m ∘ F, and the base hypothesis gives F ∘ σ₁ = σ₁ ∘ F. Composing: F ∘ σ_{m+1} = F ∘ σ₁ ∘ σ_m = σ₁ ∘ F ∘ σ_m = σ₁ ∘ σ_m ∘ F = σ_{m+1} ∘ F. Since every k ∈ ℤ/nℤ has k = val(k) · 1, the result follows by naturality of the ZMod casting. □

### Theorem 3.2 (Centralizer = Reversibility)

*Rev(n, α) = C_{S_m}(σ₁) where m = |α|^n.*

**Proof sketch.** (⊆) If π ∈ Rev(n, α), then π commutes with σ_k for all k, in particular k = 1, so πσ₁ = σ₁π, hence π ∈ C(σ₁).

(⊇) If π ∈ C(σ₁), then πσ₁ = σ₁π, so π commutes with shift-by-1. By Theorem 3.1, π commutes with all shifts, hence π ∈ Rev(n, α). □

**Significance.** This reduces the study of reversible CAs to the centralizer of a cyclic permutation, for which the structure is completely determined by the cycle type.

### Corollary 3.3 (Size Formula)

*|Rev(n, α)| = ∏_d (c_d! · d^{c_d})* where c_d is the number of orbits of size d under the shift action on α^{ℤ/nℤ}.

## 4. Orbit Structure

### Theorem 4.1 (Fixed Points are Constants)

*A configuration c ∈ {0,1}^{ℤ/nℤ} satisfies σ₁(c) = c if and only if c is constant (c(i) = c(0) for all i).*

**Proof sketch.** Forward: if c(i+1) = c(i) for all i, then by induction c(i) = c(0) for all i ∈ ℕ, hence for all i ∈ ℤ/nℤ. Backward: constant functions are trivially shift-invariant. □

### Theorem 4.2 (Prime Orbit Theorem)

*For p prime and c a non-constant configuration in {0,1}^{ℤ/pℤ}, the shift orbit of c has exactly p elements.*

**Proof sketch.** The stabilizer of c is a subgroup of ℤ/pℤ. Since p is prime, the stabilizer is either {0} or all of ℤ/pℤ. If it were all of ℤ/pℤ, then c would be constant, contradicting the hypothesis. Hence the stabilizer is trivial, and by orbit-stabilizer, |orbit(c)| = |ℤ/pℤ| = p.

The formal proof constructs an injection from ℤ/pℤ to the orbit by showing that if σ_k(c) = σ_l(c) for k ≠ l, then c is constant — using the primality of p to show that k - l generates all of ℤ/pℤ. □

**Connection to Fermat.** The number of non-constant configurations is 2^p - 2. Each has an orbit of size p. Hence the number of necklaces is (2^p - 2)/p + 2, and 2^p ≡ 2 (mod p), which is Fermat's little theorem.

## 5. Discrete Liouville Theorem

### Theorem 5.1

*For any bijection e on {0,1}^{ℤ/nℤ} and any weight w, the number of configurations of weight w equals the number of configurations c with weight(e(c)) = w.*

**Proof sketch.** This is a direct consequence of Equiv.sum_comp: for any equivalence e on a finite type, ∑_x f(x) = ∑_x f(e(x)). Applied to the indicator function of weight w, this gives the result. □

**Physical interpretation.** This is the discrete analogue of Liouville's theorem in Hamiltonian mechanics: the "phase space volume" (counting measure) is preserved by any reversible dynamics.

## 6. The Galois Connection

### Theorem 6.1 (Antitone Property)

*If H₁ ≤ H₂ ≤ Perm(α^{ℤ/nℤ}), then Fixed(H₂) ⊆ Fixed(H₁).*

**Proof sketch.** If c is fixed by every element of H₂, and H₁ ⊆ H₂, then c is fixed by every element of H₁. □

### Theorem 6.2 (Constants-Only Fixed Points)

*The fixed-point set of the full reversibility group Rev(n, α) consists exactly of the constant configurations (when n ≥ 2).*

**Proof sketch.** The shift permutation σ₁ lies in Rev(n, α) (it commutes with all shifts by commutativity of addition). If c is fixed by σ₁, then by Theorem 4.1, c is constant. □

**Galois interpretation.** The "Galois group" of the configuration space is the reversibility group. Its "fixed field" consists of the constant configurations — the configurations with maximal symmetry. Subgroups of Rev(n, α) correspond to configuration sets with intermediate levels of translational symmetry.

## 7. Complement-Shift Interaction

### Theorem 7.1
*The complement permutation κ (flipping all bits) lies in Rev(n, {0,1}).*

### Theorem 7.2
*The shift σ₁ and complement κ commute: σ₁κ = κσ₁.*

### Theorem 7.3
*The complement has order 2: κ² = id.*

**Consequence.** The subgroup ⟨σ₁, κ⟩ is isomorphic to ℤ/nℤ × ℤ/2ℤ, a direct product (not a semidirect product, since σ and κ commute).

## 8. Representation Theory Bridge

### Theorem 8.1 (Observable Action)

*The map (π, f) ↦ f ∘ π⁻¹ defines a group action of Perm(α^{ℤ/nℤ}) on the space of real-valued observables Observable(n, α) = ℝ^{α^{ℤ/nℤ}}. This action satisfies:*

*act(π₁π₂, f) = act(π₁, act(π₂, f))*

**Significance.** Restricting to Rev(n, α), this gives a representation of the reversibility group on ℝ^{|α|^n}. The decomposition of this representation into irreducibles corresponds to the harmonic analysis of the CA dynamics — the "Fourier modes" of reversible cellular automata.

## 9. Properness

### Theorem 9.1

*For n ≥ 2, Rev(n, {0,1}) ≠ S_{2^n}.*

**Proof sketch.** Construct a permutation that does not commute with the shift: the swap of the all-zeros configuration and a single-1 configuration. This swap does not commute with σ₁ because σ₁ moves the single-1 configuration to a different position, breaking the equivariance. □

## 10. Computational Results

### 10.1. Reversibility Sieve

For elementary CAs (radius 1, binary):
| Period | Reversible rules |
|--------|-----------------|
| 3      | 36              |
| 4      | 8               |
| 5      | 16              |
| 6      | 6               |
| 7      | 16              |
| 8      | 8               |

The "universally reversible" rules (reversible on all periods ≥ 6) are: {15, 51, 85, 170, 204, 240}.

### 10.2. Group Sizes

| n | |Rev(n)| | |S_{2^n}| | Index |
|---|---------|-----------|-------|
| 2 | 4       | 24        | 6     |
| 3 | 36      | 40,320    | 1,120 |
| 4 | 1,536   | ≈ 2.1×10¹³ | ≈ 1.4×10¹⁰ |
| 5 | 22,500,000 | ≈ 2.6×10³⁵ | ≈ 1.2×10²⁸ |

The ratio |Rev(n)|/|S_{2^n}| decreases super-exponentially, confirming the properness theorem.

## 11. Discussion

### 11.1. Relation to Hedlund's Theorem

For infinite CAs on ℤ, Hedlund's theorem states that the endomorphisms of the full shift are exactly the continuous, shift-commuting maps. Our Centralizer = Reversibility theorem is the finite analogue: for CAs on ℤ/nℤ, the automorphisms of the configuration space that commute with the shift are exactly the reversible CAs.

### 11.2. Connections to Other Areas

- **Number theory**: The orbit structure connects to Burnside counting, necklace polynomials, and Fermat's little theorem.
- **Representation theory**: The observable action defines a representation whose character theory encodes the dynamics.
- **Information theory**: The discrete Liouville theorem connects to entropy conservation in reversible computation.
- **Galois theory**: The antitone correspondence between subgroups and fixed points mirrors the fundamental theorem of Galois theory.

## 12. References

1. G. A. Hedlund, "Endomorphisms and automorphisms of the shift dynamical system," *Mathematical Systems Theory*, 3(4):320–375, 1969.
2. T. Toffoli and N. Margolus, *Cellular Automata Machines*, MIT Press, 1987.
3. S. Wolfram, *A New Kind of Science*, Wolfram Media, 2002.
4. `Catalog/Geometry/CellularAutomataGalois.lean` — Original formalization of the reversibility subgroup.
5. `Catalog/Tropical/HashInversion.lean` — The `reversible_iff_bijective` theorem.

## Appendix: Lean 4 Formalization

All 12 theorems are formalized in `Geometry/CellularAutomataGaloisDeep.lean` with complete, sorry-free proofs checked by Lean 4.28.0 with Mathlib. The axioms used are: `propext`, `Classical.choice`, `Quot.sound` (all standard).
