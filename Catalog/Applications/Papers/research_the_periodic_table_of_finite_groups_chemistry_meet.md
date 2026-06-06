# The Group Genome: A Chemical Classification Framework for Finite Groups

## Abstract

We introduce the **Group Genome**, a novel invariant system for finite groups inspired by the periodic table of chemical elements. The framework consists of three main components: (1) the **derived depth**, a formally defined invariant measuring the minimum number of steps for the derived series to reach the trivial subgroup; (2) a **chemical classification** that partitions finite groups into seven structural families (vacuum, noble gas, alkali, alkaline earth, halogen, transition metal, compound); and (3) the **genome tuple** itself, a compact fingerprint encoding key group-theoretic properties. We prove 16 theorems establishing fundamental properties of this framework, including characterization theorems for derived depth (depth 0 ↔ trivial; depth ≤ 1 ↔ abelian), the Stability Hierarchy Chain (cyclic → abelian → nilpotent → solvable), strict monotonicity of the derived series below the derived depth, product stability theorems, and genome consistency results. All proofs are machine-verified in Lean 4 with the Mathlib library.

## 1. Introduction

The classification of finite groups is one of the central problems of abstract algebra. While the classification of finite simple groups — completed through the combined efforts of over 100 mathematicians across several decades — provides the "atoms" of group theory, the organizational challenge remains: how to systematically understand the vast zoo of finite groups built from these atoms.

The number of groups of a given order grows explosively. There are 267 groups of order 64, but 49,487,365,422 groups of order 1024. For orders up to 2000, the total exceeds 10^15. No enumeration-based approach can handle this diversity. What is needed is a structural classification — an organizing principle analogous to Mendeleev's periodic table.

### 1.1 Contributions

This paper makes the following contributions:

1. **Derived Depth** (Definition 2.1): A formally defined invariant `derivedDepth(G)` — the minimum `n` such that the `n`-th derived subgroup is trivial — with complete characterization theorems.

2. **Chemical Classification** (Definition 3.1): A seven-class taxonomy of finite groups based on structural properties, with consistency theorems ensuring each class has the expected algebraic properties.

3. **Group Genome** (Definition 4.1): A tuple of invariants `(order, chemClass, isSolvable, isNilpotent, isAbelian, isCyclic, isSimple)` serving as a structural fingerprint.

4. **Stability Hierarchy Theorem** (Theorem 5.1): A formally verified chain Cyclic ⊂ Abelian ⊂ Nilpotent ⊂ Solvable.

5. **Strict Monotonicity** (Theorem 6.1): The derived series is strictly decreasing at each step below the derived depth.

6. **Product Stability** (Theorems 7.1-7.3): The genome behaves predictably under direct products.

## 2. Derived Depth

### 2.1 Definition

Let G be a group. The **derived series** of G is defined inductively:
- `G^(0) = G`
- `G^(n+1) = [G^(n), G^(n)]` (the commutator subgroup of `G^(n)` with itself)

A group G is **solvable** if there exists `n` such that `G^(n) = {e}`.

**Definition 2.1** (Derived Depth). For a solvable group G, the **derived depth** `d(G)` is the minimum `n ∈ ℕ` such that `G^(n) = {e}`.

Formally, `derivedDepth(G) = Nat.find(⟨n, G^(n) = ⊥⟩)`, where the existence witness comes from the solvability hypothesis.

### 2.2 Characterization Theorems

**Theorem 2.2** (Depth-Zero Characterization). `d(G) = 0` if and only if G is trivial.

*Proof sketch.* Forward: if `d(G) = 0`, then `G^(0) = ⊥`, i.e., `G = {e}`. Backward: if G is trivial, then `G^(0) = G = {e} = ⊥`, so `d(G) ≤ 0`. ∎

**Theorem 2.3** (Abelian Characterization). `d(G) ≤ 1` if and only if G is abelian.

*Proof sketch.* Forward: `d(G) ≤ 1` means `G^(1) = ⊥`, i.e., `[G,G] = {e}`. This means all commutators `[a,b] = aba⁻¹b⁻¹` are trivial, so `ab = ba` for all a,b. Backward: if G is abelian, then `[G,G] = {e}`, so `G^(1) = ⊥` and `d(G) ≤ 1`. ∎

**Theorem 2.4** (Positive Depth). If G is nontrivial and solvable, then `d(G) ≥ 1`.

*Proof.* If `d(G) = 0`, then G is trivial by Theorem 2.2, contradicting nontriviality. ∎

## 3. Chemical Classification

### 3.1 Definition

**Definition 3.1** (Chemical Class). We define seven structural classes for finite groups:

| Class | Chemical Analogue | Algebraic Condition |
|-------|------------------|-------------------|
| Vacuum | — | Trivial (subsingleton) |
| Noble Gas | He, Ne, Ar | Cyclic |
| Alkali | Li, Na, K | Abelian, non-cyclic |
| Alkaline Earth | Be, Mg, Ca | Nilpotent, non-abelian |
| Halogen | F, Cl, Br | Solvable, non-nilpotent |
| Transition Metal | Fe, Co, Ni | Simple, non-abelian |
| Compound | — | Non-solvable, non-simple |

The classification is implemented as a decision procedure: groups are tested against each condition in order, with earlier matches taking priority (e.g., a simple abelian group like ℤ/pℤ is classified as noble gas, not transition metal).

### 3.2 Consistency Theorems

**Theorem 3.2** (Noble Gas Consistency). If `classifyGroup(G) = nobleGas`, then G is cyclic.

**Theorem 3.3** (Transition Metal Consistency). If `classifyGroup(G) = transitionMetal`, then G is simple and non-abelian.

**Theorem 3.4** (Halogen Consistency). If `classifyGroup(G) = halogen`, then G is solvable and not nilpotent.

**Theorem 3.5** (Transition Metal Uniqueness). If G is simple and non-abelian, then `classifyGroup(G) = transitionMetal`.

These theorems ensure the classification is well-defined and captures the intended algebraic properties. Each is proved by case analysis on the `if-then-else` decision tree defining `classifyGroup`.

## 4. The Group Genome

### 4.1 Definition

**Definition 4.1** (Group Genome). The **genome** of a finite group G is the tuple:

```
genome(G) = (|G|, chemClass(G), isSolvable, isNilpotent, isAbelian, isCyclic, isSimple)
```

where each boolean flag records whether G has the corresponding property.

### 4.2 Examples

| Group | Order | Class | Solv | Nilp | Abel | Cyc | Simp |
|-------|-------|-------|------|------|------|-----|------|
| {e} | 1 | Vacuum | ✓ | ✓ | ✓ | ✓ | ✗ |
| ℤ/5ℤ | 5 | Noble Gas | ✓ | ✓ | ✓ | ✓ | ✓ |
| ℤ/2ℤ × ℤ/2ℤ | 4 | Alkali | ✓ | ✓ | ✓ | ✗ | ✗ |
| Q₈ | 8 | Alkaline Earth | ✓ | ✓ | ✗ | ✗ | ✗ |
| S₃ | 6 | Halogen | ✓ | ✗ | ✗ | ✗ | ✗ |
| A₅ | 60 | Transition Metal | ✗ | ✗ | ✗ | ✗ | ✓ |
| S₅ | 120 | Compound | ✗ | ✗ | ✗ | ✗ | ✗ |

## 5. The Stability Hierarchy

### 5.1 The Main Chain

**Theorem 5.1** (Stability Chain). For any group G:

```
IsCyclic(G) ⟹ IsAbelian(G) ⟹ IsNilpotent(G) ⟹ IsSolvable(G)
```

Each implication is strict: there exist groups satisfying the right property but not the left.

*Proof.* 
- Cyclic ⟹ Abelian: If G = ⟨g⟩, then for any a = g^m, b = g^n, we have ab = g^{m+n} = g^{n+m} = ba.
- Abelian ⟹ Nilpotent: If [a,b] = e for all a,b, then the lower central series reaches {e} in one step, giving nilpotency class ≤ 1.
- Nilpotent ⟹ Solvable: Standard result; the lower central series refines the derived series. ∎

### 5.2 Connection to Derived Depth

The stability chain translates to derived depth constraints:
- Noble Gas (cyclic): `d(G) ≤ 1`
- Alkali (abelian, non-cyclic): `d(G) ≤ 1`  
- Alkaline Earth (nilpotent, non-abelian): `d(G) ≥ 2`
- Halogen (solvable, non-nilpotent): `d(G) ≥ 2`

## 6. Strict Monotonicity of the Derived Series

### 6.1 Main Result

**Theorem 6.1** (Strict Derived Series Decrease). For a solvable group G, if `n + 1 ≤ d(G)`, then:

```
G^(n+1) ⊊ G^(n)
```

(strict inclusion, not just inclusion).

*Proof sketch.* Suppose for contradiction that `G^(n+1) = G^(n)`. Then `G^(n) = [G^(n), G^(n)]`, which means the derived series stabilizes at `G^(n)`. Since the series eventually reaches ⊥, we get `G^(n) = ⊥`. But `n < d(G)` (since `n + 1 ≤ d(G)`), which contradicts the minimality of d(G). ∎

This theorem shows that the derived series is not just weakly decreasing but strictly decreasing at each step before termination—analogous to the strict ordering of electron energy levels in atomic physics.

## 7. Product Stability

### 7.1 Results

**Theorem 7.1** (Product Solvability). If G and H are solvable, then G × H is solvable.

**Theorem 7.2** (Product Nilpotency). If G and H are nilpotent, then G × H is nilpotent.

**Theorem 7.3** (Product Order). `|G × H| = |G| · |H|`.

### 7.2 Implications for the Genome

These results establish that chemical class is "upward closed" under products within the stability hierarchy: the product of two noble gases is at most an alkali; the product of two alkaline earths is at most an alkaline earth.

## 8. Bridge to Simple Group Theory

### 8.1 Connection to Valence

The **valence** of a group—defined as the number of minimal normal subgroups—connects our framework to the existing catalog result `simple_group_valence_eq_one`.

**Theorem 8.1** (Simple Normal Dichotomy). For a simple group G and normal subgroup N ◁ G, either N = {e} or N = G.

This is the foundation of the "transition metal" classification: simple groups have valence 1 because they have exactly one minimal normal subgroup (themselves).

## 9. Discussion

### 9.1 Strengths

The Group Genome framework provides:
- A systematic classification that is both intuitive (via the chemistry analogy) and rigorous (via machine-verified proofs).
- A bridge between the abstract theory of solvability/nilpotency and concrete computational invariants.
- A predictive framework: knowing a group's composition factors constrains its possible genomes.

### 9.2 Limitations

- The genome is coarser than isomorphism: many non-isomorphic groups share the same genome.
- The derived depth is defined only for solvable groups, leaving the "right half" of the periodic table less structured.
- For non-solvable groups, finer invariants (chief length, Fitting height) would be needed.

### 9.3 Comparison to Prior Work

The idea of organizing groups by structural properties has appeared in various forms:
- The Burnside classification of groups by order uses prime factorization.
- The concept of "group variety" organizes groups by laws they satisfy.
- Our contribution is the specific combination of derived depth with chemical classification, formalized with machine-verified proofs.

## 10. Future Work

1. **Quantitative bounds**: Establish tight bounds on derived depth in terms of the prime factorization of |G|.
2. **Fitting height integration**: Extend the genome to include the Fitting height for non-solvable groups.
3. **Computational classification**: Implement genome computation for all groups of order ≤ 100 and verify the predictions of the framework.
4. **Composition factor signatures**: Formalize the connection between genome invariants and composition factor multisets via the Jordan-Hölder theorem.

## References

1. Dixon, J.D. and Mortimer, B. (1996). *Permutation Groups*. Springer.
2. Robinson, D.J.S. (1996). *A Course in the Theory of Groups*. Springer.
3. Rotman, J.J. (1995). *An Introduction to the Theory of Groups*. Springer.
4. The mathlib Community (2020). The Lean mathematical library. *CPP 2020*.
