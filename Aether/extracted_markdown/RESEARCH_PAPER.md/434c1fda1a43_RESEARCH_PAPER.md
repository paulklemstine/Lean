# The Factorization Diamond: Structural Hierarchy in Counterfactual Number Theory

## Abstract

We develop a framework for studying "generalized primes" — subsets of ℕ≥2 that serve as generators for multiplicative factorization — and discover a strict diamond-shaped hierarchy among three natural weakening conditions of unique factorization. Specifically, we introduce the notion of a **multiplicative basis** (MulBasis) and prove that **product-freeness** and **collision-freeness** are incomparable properties, each strictly weaker than unique factorization, and whose conjunction is itself strictly weaker than unique factorization. We further prove a **Coprime Basis Theorem** characterizing when pairwise coprime sets have unique factorization (if and only if they are product-free), and a **Prime-Power Collapse Theorem** showing that any set containing both a prime p and a power pᵏ (k ≥ 2) fails unique factorization. All results are formalized in Lean 4 with machine-verified proofs.

**Keywords:** Unique factorization, multiplicative basis, Cramér model, product-free sets, factorization hierarchy.

---

## 1. Introduction

The Fundamental Theorem of Arithmetic — that every natural number n ≥ 2 has a unique factorization into primes — is among the most fundamental results in mathematics. Yet the question of *why* unique factorization holds has deeper ramifications than might first appear.

Cramér's 1936 probabilistic model of primes proposed replacing the actual primes with a random subset S ⊂ ℕ where each n ≥ 2 is included independently with probability 1/ln(n). This model reproduces the prime density (the Prime Number Theorem) and the distribution in arithmetic progressions (Dirichlet's theorem), but loses unique factorization.

The present work asks: *precisely what structural conditions separate primes from their random counterparts?* We identify three natural conditions — unique factorization (UF), collision-freeness (CF), and product-freeness (PF) — and prove they form a strict diamond:

```
            UF
           / \
         CF   PF
           \ /
          (∅)
```

where UF implies both CF and PF, neither CF nor PF implies the other, and CF ∧ PF does not imply UF.

### 1.1 Contributions

1. **The Factorization Diamond Theorem** (Theorem 4): A complete characterization of the relationships among UF, CF, and PF, with explicit separating examples.
2. **The Coprime Basis Theorem** (Theorem 6): For pairwise coprime sets, UF ↔ PF.
3. **The Prime-Power Collapse Theorem** (Theorem 5): If S contains both p and pᵏ, UF fails.
4. **The MulBasis structure**: A novel algebraic framework for studying generalized factorization.
5. Complete formalization in Lean 4 with all proofs machine-verified.

---

## 2. Definitions

**Definition 1** (S-Factorization). For S ⊆ ℕ, an *S-factorization* of n ∈ ℕ is a multiset f of elements from S, each ≥ 2, with ∏f = n.

**Definition 2** (Unique S-Factorization). A set S has *unique S-factorization* (UF) if for every n, any two S-factorizations of n are equal as multisets.

**Definition 3** (Product-Freeness). A set S is *product-free* (PF) if for all a, b ∈ S with a, b ≥ 2, we have a · b ∉ S.

**Definition 4** (Product Collision). A *product collision* in S is a quadruple (a, b, c, d) with a, b, c, d ∈ S, all ≥ 2, such that a · b = c · d and {a, b} ≠ {c, d} as multisets.

**Definition 5** (Collision-Freeness). A set S is *collision-free* (CF) if it has no product collision.

**Definition 6** (Multiplicative Basis). A *multiplicative basis* is a pair (S, proof) where S ⊆ ℕ with all elements ≥ 2, and the proof witnesses that S has unique S-factorization.

**Definition 7** (Factorization Width). The *factorization width* of n over S is the cardinality of the set of distinct S-factorizations of n:
$$w_S(n) = |\{f \text{ multiset} : f \text{ is an S-factorization of } n\}|$$

**Definition 8** (Factorization Depth). The *factorization depth* of n over S is the number of distinct lengths achievable:
$$d_S(n) = |\{k \in \mathbb{N} : \exists f, |f| = k \text{ and } f \text{ is an S-factorization of } n\}|$$

---

## 3. Main Results

### 3.1 The Forward Implications

**Theorem 1** (UF ⟹ PF). If S has unique S-factorization, then S is product-free.

*Proof sketch.* If a, b ∈ S with a, b ≥ 2 and a · b ∈ S, then a · b has two S-factorizations: {a · b} (length 1) and {a, b} (length 2). These have different cardinalities, hence are different multisets, contradicting UF. □

**Theorem 2** (UF ⟹ CF). If S has unique S-factorization, then S is collision-free.

*Proof sketch.* A product collision (a, b, c, d) immediately provides two distinct S-factorizations {a, b} and {c, d} of the number a · b = c · d. □

### 3.2 The Separating Examples

**Theorem 3** (CF ⟹̸ PF). The set {2, 3, 6} is collision-free but not product-free.

*Proof.* Not product-free: 2 · 3 = 6 ∈ S. Collision-free: the six possible products of pairs (including self-pairs) are 4, 6, 9, 12, 18, 36 — all distinct, hence no collision exists. The Lean proof enumerates all 81 combinations of (a, b, c, d) ∈ {2, 3, 6}⁴ and verifies no collision occurs. □

**Theorem (PF ⟹̸ CF).** The set {6, 10, 21, 35} is product-free but has the collision 6 × 35 = 10 × 21 = 210. Product-freeness follows since all pairwise products (60, 126, 210, 350, 735, ...) are well above 35. □

**Theorem (CF ∧ PF ⟹̸ UF).** The set {2, 8} is both collision-free and product-free, but 8 has two distinct S-factorizations: {8} and {2, 2, 2}.

*Proof.* Product-free: 2·2 = 4, 2·8 = 16, 8·8 = 64, none in {2, 8}. Collision-free: the products 4, 16, 64 are all distinct. But 8 = 2³ gives the factorization {2, 2, 2} alongside the singleton {8}, and these have different cardinalities (3 vs 1), hence are distinct. □

This last example reveals the crucial phenomenon of **depth collisions**: factorizations of different lengths can coincide in value, and this obstruction is invisible to both pairwise product-freeness and pairwise collision-freeness.

### 3.3 The Factorization Diamond

**Theorem 4** (The Factorization Diamond). The following all hold simultaneously:
1. UF ⟹ CF and UF ⟹ PF
2. ∃ S: CF(S) ∧ ¬PF(S)  (witnessed by {2, 3, 6})
3. ∃ S: PF(S) ∧ ¬CF(S)  (witnessed by {6, 10, 21, 35})
4. ∃ S: CF(S) ∧ PF(S) ∧ ¬UF(S)  (witnessed by {2, 8})

*This is formalized as `factorization_diamond` in Lean 4.* □

### 3.4 Prime-Power Collapse

**Theorem 5.** If S contains both a prime p and pᵏ for some k ≥ 2, then S does not have unique factorization.

*Proof.* The number pᵏ has two S-factorizations: the singleton {pᵏ} and the k-fold repetition Multiset.replicate(k, p). These have cardinalities 1 and k ≥ 2, hence are distinct. □

This theorem implies that any multiplicative basis must be "power-free" in a strong sense.

### 3.5 The Coprime Basis Theorem

**Theorem 6.** Let S ⊆ ℕ≥2 be pairwise coprime (gcd(a, b) = 1 for all distinct a, b ∈ S). Then:
$$\text{HasUniqueSFactorization}(S) \iff \text{IsProdFree}(S)$$

*Proof sketch.* The forward direction is Theorem 1. For the reverse: suppose S is product-free and pairwise coprime. Given two S-factorizations f₁, f₂ of n, we show f₁ = f₂ by induction on |f₁|.

Base case: f₁ = ∅ implies n = 1, which forces f₂ = ∅ (all elements ≥ 2).

Inductive step: Let f₁ = a :: rest. Then a | n = ∏f₂. Since a is coprime to every element of f₂ that differs from a, and a ≥ 2, the divisibility forces a to appear in f₂ (otherwise a | gcd(a, ∏f₂) = 1, contradiction). Remove one copy of a from both factorizations and apply the inductive hypothesis. □

**Corollary.** The Fundamental Theorem of Arithmetic follows from the Coprime Basis Theorem: primes are pairwise coprime (distinct primes share no factor) and product-free (a product of primes is composite), hence they have unique factorization.

### 3.6 Additional Results

**Theorem 7** (Product-Free Length-2 Exclusion). If S is product-free and n ∈ S with n ≥ 2, then n has no S-factorization of length exactly 2.

*Proof.* A length-2 factorization {a, b} with a · b = n ∈ S contradicts product-freeness.

*Remark.* This does NOT extend to length ≥ 3: {2, 8} is product-free but 8 has the length-3 factorization {2, 2, 2}. □

**Theorem 8** (Product Count Bound). For a finite set S, the number of distinct pairwise products from S is at most |S|².

**Theorem 9** (Primes Form a MulBasis). The set of primes has unique S-factorization.

**Theorem 10** (Width Monotonicity). If S ⊆ T, then w_S(n) ≤ w_T(n) for all n. Adding generators can only increase factorization multiplicity.

---

## 4. The Cramér Model and Counterfactual Analysis

### 4.1 Which Theorems Survive?

In Cramér's probabilistic model, each n ≥ 2 is included in S independently with probability 1/ln(n):

| Classical Theorem | Survival | Reason |
|---|---|---|
| Prime Number Theorem | ✓ | By construction (density matches) |
| Dirichlet's theorem | ✓ | Pigeonhole: dense sets hit all residue classes |
| Unique Factorization | ✗ | Product closure occurs with probability 1 |
| Euler product formula | ✗ | Requires multiplicative independence |

### 4.2 Quantitative Failure

For a Cramér random set S up to N:

- **Product closure probability**: E[#{(a,b) : a·b ∈ S}] ~ N²/(ln N)³ → ∞
- **Collision probability**: By birthday paradox on ~N²/(ln N)² products in [1, N²]
- **Depth collision**: E[#{n : n, n^(1/k) ∈ S}] ~ N^(1-1/k)/(ln N)² > 0 for k ≥ 3

All three mechanisms activate with probability tending to 1, confirming the structural necessity of each diamond condition.

---

## 5. The Factorization Diamond Conjecture

We state the following falsifiable conjecture:

**Conjecture.** A set S ⊆ ℕ≥2 has unique S-factorization if and only if:
1. S is k-product-free for all k ≥ 2 (no k-fold product of elements lies in S), AND
2. Any two multisets of elements from S with the same product are equal.

**Computational test:** Enumerate all subsets S ⊆ {2, ..., 30} of size ≤ 4. For each, check UF by brute force and verify it equals the conjunction of conditions (1) and (2).

Note that condition (2) is stronger than collision-freeness: it applies to pairs of multisets of *arbitrary* (possibly different) lengths, not just pairs of length 2.

---

## 6. PEGB Analysis

### 6.1 The Factorization Diamond (Theorem 4)

- **P** (Proof): Complete Lean 4 proof, all cases verified.
- **E** (Example): {2, 3, 5, 7} satisfies UF ⟹ CF ∧ PF. {2, 3, 6} satisfies CF ∧ ¬PF. {6, 10, 21, 35} satisfies PF ∧ ¬CF. {2, 8} satisfies CF ∧ PF ∧ ¬UF.
- **G** (Generalization): The diamond extends to any monoid with a concept of "generating set" and "unique decomposition."
- **B** (Boundary): The diamond has no further refinements at this level; all 2³ = 8 combinations of (UF, CF, PF) that are logically consistent are realized.

### 6.2 The Coprime Basis Theorem (Theorem 6)

- **P** (Proof): Lean 4 proof by induction on factorization length, using coprime divisibility.
- **E** (Example): {2, 3, 5, 7} is coprime and product-free ⟹ UF. {6, 35, 143} (= {2·3, 5·7, 11·13}) is coprime and product-free ⟹ UF.
- **G** (Generalization): Extends to any UFD where "coprime" is defined via the GCD structure.
- **B** (Boundary): Fails without coprimality: {4, 6, 9} is product-free but not UF (36 = 4·9 = 6·6, and gcd(4,6) = 2 ≠ 1).

### 6.3 The Prime-Power Collapse (Theorem 5)

- **P** (Proof): Lean 4 proof using replicate multisets.
- **E** (Example): {2, 4}: 4 = 2² has factorizations {4} and {2, 2}. {3, 27}: 27 = 3³ has factorizations {27} and {3, 3, 3}.
- **G** (Generalization): More generally, if a ∈ S and aⁿ · b ∈ S with b ∈ S, then the product aⁿ · b has multiple factorizations.
- **B** (Boundary): Does not hold for a, b ∈ S with a ≠ b^k for any k — the obstruction is specifically about power relations.

---

## 7. Connections to Existing Results

This work builds on the product collision framework established in `Catalog/Cryptography/ProductCollisions.lean`, which proved:
- Primes are collision-free (reformulation of FTA)
- The hierarchy UF ⟹ CF, with {6, 10, 21, 35} separating PF from CF

Our contribution extends this by:
- Proving CF and PF are incomparable (the {2, 3, 6} example)
- Proving CF ∧ PF ⟹̸ UF (the {2, 8} example)
- The Coprime Basis Theorem (a positive characterization)
- The MulBasis structure (unifying framework)

---

## 8. Discussion and Future Work

The Factorization Diamond reveals that unique factorization is a *deep* property — not reducible to any finite conjunction of pairwise conditions. The hierarchy of obstructions (product closure, pairwise collision, depth collision) suggests a connection to the **collision spectrum** of a set, defined as the set of levels k at which distinct k-length factorizations coincide.

Key open questions:
1. Is UF equivalent to having empty collision spectrum at all levels AND being k-product-free for all k?
2. What is the asymptotic density of collision-free subsets of [2, N]?
3. Does the Factorization Diamond extend to factorization in algebraic number fields, where unique factorization of ideals replaces unique factorization of elements?

---

## References

1. Cramér, H. (1936). "On the order of magnitude of the difference between consecutive prime numbers." *Acta Arithmetica*, 2, 23-46.
2. Hardy, G.H. and Wright, E.M. (2008). *An Introduction to the Theory of Number Theory*, 6th edition. Oxford University Press.
3. Granville, A. (1995). "Harald Cramér and the distribution of prime numbers." *Scandinavian Actuarial Journal*, 1, 12-28.
4. Tao, T. and Vu, V.H. (2006). *Additive Combinatorics*. Cambridge University Press.
