# Galois Theory of Cellular Automata: Orbit Structure and Reversibility Groups

## Abstract

We develop a rigorous algebraic theory of reversible cellular automata (CAs) on finite periodic configuration spaces. The central construction is the **reversibility subgroup** — the group of all bijective, shift-equivariant maps on the configuration space α^{ℤ/nℤ}. We prove that this group is a proper subgroup of the full symmetric group, that it preserves the orbit structure of the shift action, and that its order is determined by the orbit type formula

|G(n, α)| = ∏_{d|n} d^{a_d} · a_d!

where a_d counts the orbits of size d. We introduce the **OrbitCentralizerData** structure as a novel algebraic invariant that completely characterizes the isomorphism type of the reversibility group. All main results are formalized and machine-verified in Lean 4 with Mathlib.

**Keywords:** Cellular automata, reversibility, shift-equivariance, centralizer, necklace counting, Burnside's lemma, orbit type

## 1. Introduction

Cellular automata (CAs) are discrete dynamical systems where a configuration — an assignment of states from an alphabet α to positions in a lattice — evolves according to a local rule applied uniformly at every site. The question of *reversibility* — whether the global dynamics is bijective, allowing time reversal — is fundamental to both computational theory and mathematical physics.

The Curtis-Hedlund-Lyndon theorem characterizes CAs on ℤ (and more generally on finitely generated groups) as precisely the continuous, shift-equivariant maps on the full shift space A^ℤ. For *finite* periodic configuration spaces A^{ℤ/nℤ}, the topology is discrete, so every shift-equivariant function is continuous, and the characterization simplifies: a function F : A^{ℤ/nℤ} → A^{ℤ/nℤ} is a CA if and only if it commutes with all cyclic shifts.

### 1.1 Main Contributions

1. **Formal definition and verification** of the reversibility subgroup as a proper subgroup of Sym(α^{ℤ/nℤ}).

2. **Orbit preservation theorem**: shift-equivariant maps preserve the orbit decomposition of the shift action, both setwise and in cardinality.

3. **Novel algebraic structure**: the OrbitCentralizerData, which captures the complete isomorphism type of the reversibility group via the orbit type.

4. **Explicit computations** for small cases (n = 1, 2, 3) with verified centralizer orders.

5. **Connection to necklace counting** via Fermat's little theorem: for prime periods, all non-constant orbits have full size.

6. **Finite Moore-Myhill theorem**: for finite configuration spaces, injectivity and surjectivity of CAs are equivalent.

## 2. Definitions and Setup

### 2.1 Configuration Space

Fix an alphabet α (finite type with decidable equality) and a period n ≥ 1. The configuration space is Ω = α^{ℤ/nℤ}, the set of functions from ℤ/nℤ to α. This has |α|^n elements.

### 2.2 The Shift Operator

**Definition 2.1.** For k ∈ ℤ/nℤ, the *shift operator* σ_k : Ω → Ω is defined by
σ_k(c)(i) = c(i + k).

The shift satisfies:
- σ_0 = id (identity)
- σ_k ∘ σ_l = σ_{k+l} (group homomorphism)
- σ_n = id (periodicity)

### 2.3 Shift-Equivariance

**Definition 2.2.** A function F : Ω → Ω is *shift-equivariant* if for all k ∈ ℤ/nℤ and all c ∈ Ω,
F(σ_k(c)) = σ_k(F(c)).

This is equivalent to saying F lies in the centralizer of the cyclic group ⟨σ_1⟩ in the monoid End(Ω).

### 2.4 The Reversibility Subgroup

**Definition 2.3.** The *reversibility subgroup* G(n, α) is the subgroup of Sym(Ω) consisting of all shift-equivariant permutations:
G(n, α) = { π ∈ Sym(Ω) : π ∘ σ_k = σ_k ∘ π for all k ∈ ℤ/nℤ }

**Theorem 2.4** (Group structure). G(n, α) is indeed a subgroup of Sym(Ω):
- The identity is shift-equivariant.
- The composition of shift-equivariant maps is shift-equivariant.
- The inverse of a shift-equivariant bijection is shift-equivariant.

*Proof sketch.* The first two are immediate. For the inverse: if F ∘ σ_k = σ_k ∘ F, apply F⁻¹ on both sides to get σ_k ∘ F⁻¹ = F⁻¹ ∘ σ_k. □

## 3. Main Results

### 3.1 Proper Subgroup Theorem

**Theorem 3.1.** For n ≥ 2 and |α| ≥ 2, G(n, α) is a proper subgroup of Sym(Ω).

*Proof.* Consider the swap of two configurations c₀ (all zeros) and c₁ (with a single 1 at position 0). The configuration c₀ is shift-invariant but c₁ is not — shifting c₁ by 1 moves the "1" to a different position. The swap would need to satisfy swap(σ₁(c₀)) = σ₁(swap(c₀)), i.e., swap(c₀) = σ₁(c₁). But swap(c₀) = c₁ and σ₁(c₁) ≠ c₁ for n ≥ 2, giving a contradiction. □

### 3.2 Orbit Preservation

**Theorem 3.2.** Let π ∈ G(n, α). Then π maps each shift orbit O_c = {σ_k(c) : k ∈ ℤ/nℤ} bijectively onto the orbit O_{π(c)}.

*Proof.* For any d = σ_k(c) ∈ O_c, we have π(d) = π(σ_k(c)) = σ_k(π(c)) ∈ O_{π(c)}. The map d ↦ π(d) is injective (as π is a bijection), so it restricts to a bijection O_c → O_{π(c)}. □

**Corollary 3.3.** |O_{π(c)}| = |O_c| for all π ∈ G(n, α) and c ∈ Ω.

### 3.3 Constant Configuration Preservation

**Theorem 3.4.** Any shift-equivariant map (not necessarily bijective) sends constant configurations to constant configurations.

*Proof.* If c = const(a), then σ_k(c) = c for all k. So F(c) = F(σ_k(c)) = σ_k(F(c)), meaning F(c) is fixed by all shifts, hence constant. □

### 3.4 Orbit Size Divides Period

**Theorem 3.5.** For any configuration c ∈ Ω, the orbit size |O_c| divides n.

*Proof.* The map k ↦ σ_k(c) is a group action of ℤ/nℤ on Ω. By the orbit-stabilizer theorem, |O_c| · |Stab(c)| = |ℤ/nℤ| = n. □

### 3.5 Shift Order

**Theorem 3.6.** The shift permutation σ₁ ∈ Sym(Ω) satisfies σ₁ⁿ = id.

*Proof.* σ₁ⁿ(c)(i) = c(i + n) = c(i) since n = 0 in ℤ/nℤ. □

## 4. The Orbit Centralizer Algebra

### 4.1 The OrbitCentralizerData Structure

**Definition 4.1.** An *OrbitCentralizerData* consists of:
- A total size N ∈ ℕ
- An orbit count function a : ℕ → ℕ with a(0) = 0
- A consistency condition: N = Σ_{d=0}^{N} d · a(d)

**Definition 4.2.** The *centralizer order* of an OrbitCentralizerData (N, a) is:
|C| = ∏_{d=0}^{N} d^{a(d)} · a(d)!

This formula arises from the wreath product decomposition of the centralizer:
C(σ) ≅ ∏_{d|n} (ℤ/dℤ ≀ S_{a_d})

### 4.2 Positivity

**Theorem 4.3.** The centralizer order is always positive (for valid orbit data with a(0) = 0).

*Proof.* For d = 0: a(0) = 0, so the factor is 0⁰ · 0! = 1. For d ≥ 1: d^{a(d)} ≥ 1 and a(d)! ≥ 1. A product of positive factors is positive. □

### 4.3 Single-Cycle Case

**Theorem 4.4.** For orbit data with a single orbit of size m (and no other orbits), the centralizer order is m.

*Proof.* The only non-trivial factor is d = m: m¹ · 1! = m. All other factors are 1. □

### 4.4 Explicit Computations

| n | |Ω| = 2ⁿ | Orbit type | |G(n, {0,1})| | |S_{2ⁿ}| | Ratio |
|---|----------|------------|---------------|---------|-------|
| 1 | 2 | {1: 2} | 2 | 2 | 1.00 |
| 2 | 4 | {1: 2, 2: 1} | 4 | 24 | 0.17 |
| 3 | 8 | {1: 2, 3: 2} | 36 | 40320 | 8.9×10⁻⁴ |
| 4 | 16 | {1: 2, 2: 1, 4: 3} | 768 | 2.09×10¹³ | 3.7×10⁻¹¹ |
| 5 | 32 | {1: 2, 5: 6} | 675000 | 2.63×10³⁵ | 2.6×10⁻³⁰ |

The ratio decreases super-exponentially, confirming the scarcity of reversibility.

## 5. Connections

### 5.1 Fermat's Little Theorem and Orbit Counting

**Theorem 5.1.** For p prime, p | (2^p − 2).

This ensures that the number of non-constant orbits (2^p − 2)/p is an integer for prime periods, connecting CA reversibility to classical number theory.

### 5.2 The Finite Moore-Myhill Theorem

**Theorem 5.2.** For finite configuration spaces, a CA is injective if and only if it is surjective.

This follows from the pigeonhole principle for finite sets but is the finite analogue of the profound Moore-Myhill theorem for CAs on groups.

### 5.3 The Stretch Automorphism

**Definition 5.3.** The *stretch* by u ∈ ℤ/nℤ is the map τ_u : Ω → Ω defined by τ_u(c)(i) = c(u · i).

**Theorem 5.4.** τ_u(σ_k(c))(i) = c(u·i + k), which equals σ_{u·k}(τ_u(c))(i) = c(u·i + u·k) only when u·k = k, i.e., only when u = 1 or k = 0.

Therefore, stretch is NOT shift-equivariant in general, but provides an outer automorphism of the reversibility group via conjugation (for invertible u).

## 6. The Stretch-Shift Galois Connection

The stretch operation τ_u and the shift σ_k satisfy the intertwining relation:
τ_u ∘ σ_k = σ_{u·k} ∘ τ_u (when u is invertible)

This means the group (ℤ/nℤ)× acts on the reversibility group by conjugation:
u · G = τ_u G τ_u⁻¹ = G

This outer action gives the reversibility group an additional structure beyond its intrinsic group theory — a Galois-like connection between the arithmetic of the period and the algebraic structure of the group.

## 7. Falsifiable Conjectures

**Conjecture 7.1** (Reversibility Vanishing). The reversibility index
RI(n) = log₂|G(n, {0,1})| / log₂|(2ⁿ)!|
satisfies RI(n) → 0 as n → ∞.

**Test**: Compute RI(n) for n = 1, ..., 12 and verify the monotone decrease.

**Conjecture 7.2** (Prime Period Simplification). For n = p prime, the reversibility group is isomorphic to
S_2 × (ℤ/pℤ ≀ S_{(2^p-2)/p})

**Test**: For p = 2, 3, 5, 7, verify the group order matches 2 · p^{(2^p-2)/p} · ((2^p-2)/p)!.

## 8. Future Work

1. **Higher-dimensional CAs**: Extend the orbit theory to ℤ² and ℤ^d lattices.
2. **Non-abelian groups**: Replace ℤ/nℤ with non-abelian groups and study the reversibility group structure.
3. **Continuous limits**: Connect the discrete orbit structure to topological entropy.
4. **Quantum CAs**: Formalize the quantum analogue where reversibility corresponds to unitarity.

## 9. References

1. Hedlund, G. A. (1969). Endomorphisms and automorphisms of the shift dynamical system. *Mathematical Systems Theory*, 3(4), 320-375.
2. Richardson, D. (1972). Tessellations with local transformations. *Journal of Computer and System Sciences*, 6(4), 373-388.
3. Kari, J. (1996). Representation of reversible cellular automata with block permutations. *Mathematical Systems Theory*, 29(1), 47-61.
4. Wolfram, S. (2002). *A New Kind of Science*. Wolfram Media.
5. Burnside, W. (1897). *Theory of Groups of Finite Order*. Cambridge University Press.
