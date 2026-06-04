# The Periodic Table of Finite Groups: A Chemical-Algebraic Classification Framework

## Abstract

We introduce the *solvability spectrum*, a novel invariant for finite solvable groups that decomposes the group order into a sequence of "abelian layer sizes" determined by the derived series. Analogous to an atom's electron shell configuration, the solvability spectrum σ_G : ℕ → ℕ measures the index ratios of consecutive derived subgroups: σ_G(n) = |D_n(G)| / |D_{n+1}(G)|. We develop a systematic classification framework—the "periodic table of finite groups"—that organizes groups by solvability depth (row), family type (column), and spectrum pattern (fingerprint). We prove 13 theorems establishing the structural theory of this framework, including: (1) the solvability gap theorem (non-nilpotent solvable groups have depth ≥ 2), (2) strict descent of the derived series within the depth, (3) positivity of spectrum entries, (4) the Frattini-commutator containment for nilpotent groups, and (5) that nontrivial normal subgroups of nilpotent groups always meet the center. All proofs are formally verified in Lean 4 with Mathlib, relying only on the standard axioms (propext, Classical.choice, Quot.sound).

## 1. Introduction

The classification of finite groups is one of the central problems in algebra. While the Classification of Finite Simple Groups (CFSG) provides a complete catalog of the "atoms" of group theory, understanding how these atoms combine into the vast landscape of all finite groups remains deeply challenging. For perspective, there are approximately 49 billion groups of order 1024 alone.

We propose a structural framework inspired by the periodic table of chemical elements. Just as Mendeleev organized elements by atomic number (row) and chemical behavior (column), we organize finite groups by:
- **Solvability depth** d(G): the number of steps in the derived series before reaching trivial. This serves as the "period" (row number).
- **Group family**: a classification by structural type (noble gas, alkali metal, etc.). This serves as the "group" (column).
- **Solvability spectrum** σ_G: the sequence of quotient sizes at each derived level. This serves as the "electron configuration."

### 1.1 Notation

Throughout, G denotes a finite group, D_n(G) = derivedSeries G n the n-th derived subgroup, γ_n(G) = lowerCentralSeries G n the n-th term of the lower central series, and Φ(G) = frattini G the Frattini subgroup. We write |G| for the order (Fintype.card G) and Z(G) for the center (Subgroup.center G).

## 2. The Solvability Spectrum

**Definition 2.1** (Solvability Depth). For a solvable group G, the *solvability depth* is:
$$d(G) = \min\{n \in \mathbb{N} : D_n(G) = 1\}$$

**Definition 2.2** (Solvability Spectrum). For a finite group G, the *solvability spectrum* at level n is:
$$\sigma_G(n) = |D_n(G)| / |D_{n+1}(G)|$$

The spectrum captures the "abelian layer sizes" of G: each entry σ_G(n) is the order of the abelian group D_n(G)/D_{n+1}(G) (the n-th abelian factor in the derived series).

**Example 2.3**.
- Z/12Z: σ = (12). One layer (abelian).
- S₃: σ = (2, 3). Two layers.
- S₄: σ = (2, 3, 4). Three layers.
- D₄: σ = (2, 2). Two equal layers (nilpotent).
- A₄: σ = (3, 4). Two layers.

## 3. Main Results

### 3.1 Derived–Central Interleaving

**Theorem 3.1** (`derived_le_lower_central`). For any group G and n ∈ ℕ:
$$D_n(G) \leq \gamma_n(G)$$

*Proof sketch*. Induction on n. The base case D_0 = G = γ_0 is trivial. For the inductive step:
$$D_{n+1} = [D_n, D_n] \leq [\gamma_n, \gamma_n] \leq [\gamma_n, G] = \gamma_{n+1}$$
using the inductive hypothesis and commutator monotonicity. □

**Corollary 3.2** (`solDepth_le_nilpotencyClass`). For nilpotent G:
$$d(G) \leq \text{nilpotencyClass}(G)$$

### 3.2 The Solvability Gap Theorem

**Theorem 3.3** (`solvable_not_nilpotent_depth_ge_two`). If G is finite, solvable, and not nilpotent, then d(G) ≥ 2.

*Proof sketch*. Contrapositive: if d(G) ≤ 1, then either d(G) = 0 (G is trivial, hence nilpotent) or d(G) = 1 (D₁(G) = 1, so G is abelian, hence nilpotent). □

**Theorem 3.4** (`depth_le_one_imp_nilpotent`). If G is finite solvable with d(G) ≤ 1, then G is nilpotent.

This establishes a "gap" in the periodic table: the first row (depth ≤ 1) consists entirely of nilpotent groups. Non-nilpotent solvable groups appear only from row 2 onwards.

### 3.3 Strict Descent and Spectrum Positivity

**Theorem 3.5** (`derivedSeries_strictMono_lt_solDepth`). For n + 1 ≤ d(G):
$$D_{n+1}(G) < D_n(G)$$
(strict inequality as subgroups).

*Proof sketch*. If D_{n+1} = D_n, then by induction D_m = D_n for all m ≥ n. But D_{d(G)} = 1 while D_n ≠ 1 (since n < d(G)), contradiction. □

**Theorem 3.6** (`solvSpectrum_pos`). For finite solvable G and n < d(G):
$$\sigma_G(n) > 1$$

*Proof sketch*. By Theorem 3.5, |D_n| > |D_{n+1}|. Since D_{n+1} ≤ D_n as subgroups, Lagrange gives |D_{n+1}| | |D_n|. So σ_G(n) = |D_n|/|D_{n+1}| ≥ 2 > 1. □

### 3.4 The Frattini–Commutator Duality

**Theorem 3.7** (`commutator_le_frattini_of_nilpotent`). For finite nilpotent G:
$$D_1(G) = [G, G] \leq \Phi(G)$$

*Proof sketch*. For each maximal subgroup M of G: since G is nilpotent, M is normal with G/M cyclic of prime order (hence abelian). So [G, G] ≤ ker(G → G/M) = M. Since Φ(G) = ∩{M : M maximal}, we get [G, G] ≤ Φ(G). □

This is the group-theoretic version of noble gas stability: the "reactive" commutator is shielded within the "inert" Frattini subgroup.

### 3.5 Nilpotent Groups Meet the Center

**Theorem 3.8** (`nilpotent_normal_meets_center`). In a nilpotent group G, every nontrivial normal subgroup N satisfies:
$$Z(G) \cap N \neq 1$$

*Proof sketch*. Consider the upper central series Z_0 = 1 ⊂ Z_1 = Z(G) ⊂ ⋯ ⊂ Z_c = G. There exists a smallest k with Z_k ∩ N ≠ 1. If k ≥ 2, then for x ∈ (Z_k ∩ N) \ Z_{k-1} and any g ∈ G, the commutator [x,g] ∈ Z_{k-1} ∩ N = 1 (by minimality). So x ∈ Z_1, contradicting x ∉ Z_{k-1}. Therefore k = 1. □

### 3.6 Product Decomposition

**Theorem 3.9** (`derivedSeries_prod'`). For all n:
$$D_n(G \times H) = D_n(G) \times D_n(H)$$

*Proof sketch*. Induction using the fact that commutators in a product decompose componentwise: [A × B, C × D] = [A,C] × [B,D]. □

### 3.7 Functoriality

**Theorem 3.10** (`solDepth_quotient_le`). For normal N ⊴ G:
$$d(G/N) \leq d(G)$$

**Theorem 3.11** (`solDepth_congr`). For isomorphic groups G ≅ H:
$$d(G) = d(H)$$

**Theorem 3.12** (`derivedSeries_map_surjective`). For surjective f: G → H:
$$D_n(H) \leq f(D_n(G))$$

### 3.8 Abelian Groups

**Theorem 3.13** (`abelian_solDepth_le_one`). For abelian G: d(G) ≤ 1.

**Theorem 3.14** (`abelian_derived_one_eq_bot`). For abelian G: D₁(G) = 1.

### 3.9 Valence Theory

**Definition 3.15** (Group Valence). The *group valence* v(G) is the number of minimal normal subgroups of G.

**Theorem 3.16** (`simple_group_valence_eq_one`). For nontrivial simple G: v(G) = 1.

## 4. The Chemical Classification

We define five "chemical families" of finite groups:

| Family | Chemical Analogue | Definition | Examples |
|--------|------------------|------------|----------|
| Noble Gas | Noble gases | Abelian (commutative) | Z/nZ, (Z/pZ)^k |
| Alkali Metal | Alkali metals | Nilpotent, not abelian | D₄, Q₈, Heisenberg |
| Alkaline Earth | Alkaline earths | Solvable, not nilpotent | S₃, A₄, D_n (n odd) |
| Transition Metal | Transition metals | Simple, not abelian | A₅, PSL(2,7), A_n (n≥5) |
| Halogen | Halogens | Not solvable, not simple | S₅, GL(2,F_p) |

The **periodic law** we establish: groups within the same family share fundamental structural properties, and the family is determined by a finite number of invariants (solvability, nilpotency, simplicity, abelianness).

## 5. Conjectures and Future Directions

### 5.1 Quantitative Periodic Law

**Conjecture 5.1**. For finite solvable G with |G| > 1:
$$d(G) \leq \Omega(|G|)$$
where Ω(n) is the number of prime factors with multiplicity. This is proved in a companion file in the Catalog.

### 5.2 Spectrum Reconstruction

**Conjecture 5.2** (Falsifiable). The solvability spectrum σ_G, together with the composition factor types, determines the isomorphism type of G up to finitely many possibilities.

**Test**: Enumerate all groups of order 72 = 8 × 9 with spectrum (2, 2, 3, 3) and check if they are uniquely determined.

### 5.3 Chemical Analogy Limits

**Conjecture 5.3**. For groups of the same order and same solvability depth, nilpotent and non-nilpotent examples can coexist only when the order has both prime-power and non-prime-power divisor structure.

**Example**: G = Q₈ × Z/3Z (order 24, nilpotent, depth 2) vs. H = S₃ × Z/4Z (order 24, non-nilpotent, depth 2).

## 6. Discussion

### 6.1 What the Analogy Captures

The chemical analogy succeeds in several key respects:
1. **Predictive power**: The solvability gap theorem tells us where to expect non-nilpotent groups.
2. **Structural hierarchy**: The spectrum provides a finer invariant than depth alone.
3. **Product behavior**: Spectra multiply under products, mirroring how electron configurations combine.

### 6.2 Where the Analogy Breaks

Unlike the periodic table of elements, where atomic number uniquely determines the element:
1. Many groups share the same order (atomic number is not unique to a group).
2. The spectrum does not determine the group uniquely.
3. The "families" are not as cleanly separated—there are groups near the boundaries.

### 6.3 Formal Verification

All 13 main theorems are formalized and verified in Lean 4 with Mathlib. The proofs use only the standard axioms (propext, Classical.choice, Quot.sound). This ensures a level of rigor beyond traditional peer review.

## 7. References

1. Rotman, J.J. *An Introduction to the Theory of Groups*. Springer, 1995.
2. Robinson, D.J.S. *A Course in the Theory of Groups*. Springer, 1996.
3. Mathlib. The mathlib4 library. https://leanprover-community.github.io/mathlib4_docs/
4. Gorenstein, D. *Finite Groups*. Chelsea, 1980.
5. Burnside, W. *Theory of Groups of Finite Order*. Cambridge, 1911.
