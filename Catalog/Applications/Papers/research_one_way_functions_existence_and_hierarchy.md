# The Lattice of Cryptographic Hardness Assumptions: Formalized Reductions and Separation Structure

## Abstract

We present a formal mathematical treatment of the cryptographic hardness hierarchy—the chain of implications connecting one-way functions (OWF), pseudorandom generators (PRG), pseudorandom functions (PRF), and semantically secure encryption (ENC). Our formalization captures the combinatorial core of classical cryptographic reductions through precise, machine-verifiable theorems. We introduce a novel **SecurityProfile** structure that tracks security degradation through reduction chains, prove the multiplicative composition of security loss factors by induction, and establish separation results via counting arguments. Key results include: (1) the lossy collision bound showing that functions with small images must have collisions; (2) the hybrid argument triangle inequality with matching tightness; (3) fiber partition analysis for preimage counting; (4) the GGM tree image bound; and (5) an end-to-end security degradation theorem. We also state a falsifiable conjecture on collision density in stretching functions.

**Keywords**: one-way functions, pseudorandom generators, cryptographic reductions, hardness hierarchy, formal verification

## 1. Introduction

The foundational results of theoretical cryptography establish a remarkable hierarchy of hardness assumptions: the existence of one-way functions is both necessary and sufficient for constructing pseudorandom generators [HILL99], which in turn suffice for pseudorandom functions [GGM86], which suffice for semantically secure encryption [GM84]. This hierarchy is one of the crowning achievements of complexity-based cryptography.

Despite the importance of these results, their proofs have traditionally been presented informally, relying on probabilistic arguments that are difficult to verify mechanically. Our work addresses this gap by formalizing the *combinatorial skeleton* of these reductions—the counting arguments, structural bounds, and algebraic relationships that underpin the probabilistic constructions.

### 1.1 Contributions

1. **Hardness lattice formalization**: We define `CryptoLevel` as a four-element type with a strict total order reflecting the implication structure, and prove strictness (no two distinct levels are equivalent).

2. **Lossy function collision bounds**: We formalize the `LossyFunction` structure and prove that functions with image size smaller than domain size must have collisions (Theorem `lossy_collision_exists`).

3. **PRG stretch analysis**: We prove non-surjectivity of stretching functions and establish the output gap theorem quantifying unreachable outputs.

4. **Hybrid argument**: We formalize `HybridSequence` and prove both the upper bound (triangle inequality) and lower bound (tightness) for advantage decomposition.

5. **GGM tree construction**: We define the GGM tree recursively and prove the image bound.

6. **Fiber partition theory**: We prove the fiber sum identity and derive the large fiber existence theorem via pigeonhole.

7. **SecurityProfile** (novel): We introduce a mathematical structure capturing security degradation through reduction chains and prove the end-to-end bound by induction.

8. **Collision density conjecture**: We state a falsifiable conjecture on the structure of stretching functions.

## 2. Definitions

### 2.1 Cryptographic Hardness Levels

We model the cryptographic hierarchy as a four-element enumerated type:

```
CryptoLevel := OWF | PRG | PRF | ENC
```

with a rank function `rank : CryptoLevel → ℕ` assigning OWF → 0, PRG → 1, PRF → 2, ENC → 3. The ordering `A ≤ B` is defined as `B.rank ≤ A.rank`, capturing that higher-rank primitives are stronger assumptions that imply weaker ones.

### 2.2 Lossy Functions

A `LossyFunction α β` consists of a function `f : α → β` together with an upper bound `imageSize` on `|Im(f)|`. This models the "lossy mode" of cryptographic functions where the image is deliberately compressed.

### 2.3 Hybrid Sequences

A `HybridSequence` consists of:
- `numSteps : ℕ` — the number of hybrid transitions
- `stepAdvantage : Fin numSteps → ℚ` — the distinguishing advantage at each step
- `step_nonneg` — proof that all advantages are non-negative

The total advantage is `∑ᵢ stepAdvantage(i)`.

### 2.4 GGM Tree

The GGM tree is defined recursively:

```
GGMTree G seed [] = seed
GGMTree G seed (b :: bs) = if b then (G (GGMTree G seed bs)).2
                                 else (G (GGMTree G seed bs)).1
```

This captures the standard GGM construction where `G : α → α × α` is a length-doubling PRG.

### 2.5 Fiber

The fiber of `f` at `y` is `{x ∈ univ | f(x) = y}`, the preimage set.

### 2.6 Security Profile (Novel)

A `SecurityProfile` consists of:
- `depth : ℕ` — number of reduction levels
- `securityAtLevel : Fin (depth + 1) → ℚ` — security parameter at each level
- `degradation : Fin depth → ℚ` — degradation factor at each transition
- Constraints: all security parameters positive, all degradation factors ≥ 1
- Chain condition: `securityAtLevel(i) ≤ degradation(i) · securityAtLevel(i+1)` for all i

## 3. Main Results

### 3.1 Hierarchy Strictness (Theorem `hierarchy_strict`)

**Statement**: For all distinct cryptographic levels A ≠ B, it is not the case that both A ≤ B and B ≤ A.

**Proof sketch**: If A ≤ B and B ≤ A, then rank(A) = rank(B) by antisymmetry. Case analysis on all pairs of levels shows rank equality implies A = B, contradicting A ≠ B.

### 3.2 Lossy Collision Existence (Theorem `lossy_collision_exists`)

**Statement**: If L is a lossy function with imageSize < |α|, then ∃ x ≠ y with L.f(x) = L.f(y).

**Proof**: By contradiction. If no collisions exist, f is injective, so |Im(f)| = |α| > imageSize, contradicting the image bound. Uses `by_contra` and `push_neg`.

### 3.3 PRG Stretch Non-Surjectivity (Theorem `prg_stretch_not_surjective`)

**Statement**: If |α| < |β|, then no function f : α → β is surjective.

**Proof**: Surjectivity implies |α| ≥ |β| by `Fintype.card_le_of_surjective`, contradicting |α| < |β|.

### 3.4 Hybrid Triangle Inequality (Theorem `hybrid_advantage_triangle`)

**Statement**: If each step advantage ≤ maxAdv, then totalAdvantage ≤ numSteps · maxAdv.

**Proof**: Replace each summand by its upper bound, then compute the constant sum.

### 3.5 Fiber Partition (Theorem `fiber_sum_eq_card`)

**Statement**: ∑_{y ∈ Im(f)} |fiber(f, y)| = |α|.

**Proof**: The fibers partition the domain: every element belongs to exactly one fiber (the fiber at its image). The sum of partition sizes equals the total.

### 3.6 Large Fiber Existence (Theorem `large_fiber_exists`)

**Statement**: If |Im(f)| < |α|, then ∃ y ∈ Im(f) with |fiber(f, y)| ≥ 2.

**Proof**: By contradiction. If all fibers have size ≤ 1, then by the partition identity, |α| = ∑ |fiber(y)| ≤ |Im(f)| · 1 = |Im(f)| < |α|, a contradiction.

### 3.7 Collision from Large Fiber (Theorem `collision_from_large_fiber`)

**Statement**: If |fiber(f, y)| ≥ 2, then ∃ x₁ ≠ x₂ with f(x₁) = y and f(x₂) = y.

**Proof**: Extract two distinct elements from the fiber using `Finset.one_lt_card`.

### 3.8 Reduction Composition (Theorem `reduction_compose_loss`)

**Statement**: If adv_B ≤ L₁ · adv_A and adv_C ≤ L₂ · adv_B, then adv_C ≤ L₁L₂ · adv_A.

**Proof**: Direct calculation using transitivity and monotonicity of multiplication.

### 3.9 End-to-End Security (Theorem `end_to_end_security`)

**Statement**: securityAtLevel(0) ≤ totalDegradation · securityAtLevel(depth).

**Proof**: By induction on depth. Base case is trivial (empty product = 1). Inductive step: use the chain condition at level 0 and apply the inductive hypothesis to the remaining levels.

### 3.10 Injective Collision-Free (Theorem `injective_all_collision_free`)

**Statement**: For injective f : Fin N → Fin M, collisionFreeOutputs(f) = N.

**Proof**: When f is injective, every image element has exactly one preimage. The set of collision-free outputs equals the image, which has cardinality N.

## 4. The SecurityProfile: A Novel Structure

The SecurityProfile is our main novel contribution. It abstracts the common pattern in cryptographic reduction chains where security degrades multiplicatively through each step.

### 4.1 Motivation

In practice, when we chain reductions OWF → PRG → PRF → ENC, each reduction introduces a loss factor. The HILL construction [HILL99] loses a polynomial factor. The GGM construction [GGM86] loses a factor proportional to the tree depth. The PRF-to-encryption reduction is tight (loss factor 1).

The SecurityProfile captures this pattern abstractly, allowing us to reason about security degradation independently of the specific constructions.

### 4.2 Total Degradation

The total degradation is the product of all individual degradation factors:

```
totalDegradation = ∏ᵢ degradation(i)
```

We prove this is always ≥ 1 (since each factor is ≥ 1), establishing that security never *improves* through reductions.

### 4.3 End-to-End Bound

The key theorem shows that the security at the bottom of the chain (level 0, corresponding to OWF security) is at most totalDegradation times the security at the top (corresponding to encryption security). This gives practitioners a concrete formula for setting parameters.

## 5. Conjecture: PRG Collision Density

**Conjecture**: For any function f : Fin(2ⁿ) → Fin(2ⁿ⁺¹), the number of collision-free outputs (outputs with exactly one preimage) is at least 2ⁿ - n.

**Computational test**: For n = 1, ..., 10, enumerate random functions and compute the minimum collision-free count. If any function achieves fewer than 2ⁿ - n, the conjecture is false.

**Significance**: If true, this would imply that stretching functions are "almost injective" with at most n collision pairs. This has implications for the tightness of birthday-bound attacks on PRG constructions.

## 6. Algorithms

### 6.1 Hybrid Advantage Computation

```python
def compute_hybrid_advantage(step_advantages: list[float]) -> float:
    return sum(step_advantages)
```

### 6.2 Security Parameter Estimation

```python
def estimate_security_parameter(
    target_security: float,
    degradation_factors: list[float]
) -> float:
    total_degradation = 1.0
    for d in degradation_factors:
        total_degradation *= d
    return target_security * total_degradation
```

### 6.3 GGM Tree Evaluation

```python
def ggm_evaluate(G, seed, path: list[bool]):
    node = seed
    for bit in path:
        left, right = G(node)
        node = right if bit else left
    return node
```

## 7. Discussion

### 7.1 Relationship to Existing Work

Our formalization complements existing verified cryptography projects (e.g., CryptoVerif, EasyCrypt) by focusing on the *structural* aspects of the hardness hierarchy rather than specific protocol analyses. While those tools handle probabilistic arguments directly, our approach captures the combinatorial core that underlies all such arguments.

### 7.2 Limitations

Our formalization works over finite types and rational number advantages, avoiding the measure-theoretic complications of full probabilistic cryptography. This is a deliberate design choice: the combinatorial structure is where the mathematical content lives, and the probabilistic layer is a standard (if tedious) wrapping.

### 7.3 Connection to Catalog

This work connects to several existing formalized results:
- The tropical one-way foundations (`TropicalOneWayFoundations.lean`) provide concrete candidate OWF constructions
- The Berggren lattice constructions provide algebraic structure relevant to post-quantum cryptography
- The proof-search one-way functions (`OneWay.lean`) provide a complementary combinatorial approach to OWF security

## 8. Future Work

1. **Probabilistic extension**: Integrate with Mathlib's measure theory to formalize the full probabilistic definitions of OWF, PRG, PRF security.
2. **Concrete instantiations**: Connect the SecurityProfile to specific constructions (HILL PRG, GGM PRF) with computed degradation factors.
3. **Quantum reductions**: Extend the hierarchy to include quantum adversaries and post-quantum primitives.
4. **Tightness results**: Formalize known tightness results showing that certain loss factors are optimal.

## References

- [GM84] S. Goldwasser and S. Micali, "Probabilistic Encryption," JCSS, 1984.
- [GGM86] O. Goldreich, S. Goldwasser, and S. Micali, "How to Construct Random Functions," JACM, 1986.
- [HILL99] J. Håstad, R. Impagliazzo, L.A. Levin, and M. Luby, "A Pseudorandom Generator from any One-way Function," SICOMP, 1999.
- [Gol01] O. Goldreich, "Foundations of Cryptography, Volume 1: Basic Tools," Cambridge University Press, 2001.
- [LR88] M. Luby and C. Rackoff, "How to Construct Pseudorandom Permutations from Pseudorandom Functions," SICOMP, 1988.
