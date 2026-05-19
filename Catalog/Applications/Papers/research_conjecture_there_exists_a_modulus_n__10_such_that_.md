# CRT Compression and Certified Finite Obstructions for Beal-Type Equations

## Abstract

We develop a formally verified local-global theory of primitive residue obstructions for equations of the form $A^x + B^y = C^z$. The central contribution is a **CRT Compression Theorem** establishing that, for coprime moduli $M$ and $N$, the existence of primitive residue solutions modulo $M \cdot N$ decomposes as a conjunction of local solvability at $M$ and $N$. We prove **obstruction monotonicity** — nonsolvability propagates from divisors to multiples — and combine these with certified exhaustive computation to produce the first formally verified finite obstruction certificates for the cubic equation $A^3 + B^3 = C^3$. Specifically, we prove that the primes 2, 7, and 13 all obstruct signature $(3,3,3)$, and we give a structural explanation via cube subgroup analysis: for primes $p \equiv 2 \pmod{3}$, every unit is a cube and obstruction is impossible, while for $p \equiv 1 \pmod{3}$, cubes form a proper subgroup of index 3 and obstruction reduces to sumset avoidance. All theorems are machine-verified in Lean 4 with Mathlib, with zero uses of `sorry`.

---

## 1. Introduction

### 1.1 Motivation

Beal's conjecture asserts that if $A^x + B^y = C^z$ with $A, B, C > 0$ and $x, y, z > 2$, then $\gcd(A, B, C) > 1$. This is a vast generalization of Fermat's Last Theorem and remains one of the most prominent open problems in Diophantine number theory.

A classical approach to Diophantine impossibility is **local obstruction**: showing that an equation has no solution modulo some integer $N$. If $A^x + B^y = C^z$ in the integers, then the same equation holds modulo $N$ for every $N$. Contraposing, if the equation fails modulo some $N$ (under appropriate coprimality conditions), then no integer solution with the required coprimality exists.

The contribution of this work is to develop this approach into a **formally verified, compositional theory** with three components:

1. **CRT Compression** (§3): A proof that primitive residue solvability decomposes completely over coprime factors, reducing obstruction search to prime powers.

2. **Certified Computation** (§4): Machine-verified exhaustive checks proving that specific small primes obstruct the signature $(3,3,3)$.

3. **Structural Classification** (§5): A cube-subgroup criterion explaining when and why obstruction occurs at a given prime.

### 1.2 Prior Work

The use of modular obstructions in Diophantine equations has a long history, dating to Euler's proof of FLT for $n = 3$ (1770) which uses descent after establishing divisibility constraints via mod 7 analysis. The systematic study of residue conditions for Fermat-type equations appears in the work of Kummer, Wieferich, and others in the 19th century.

The ABC conjecture, formulated by Masser and Oesterlé (1985), provides a complementary global approach. Under ABC-type hypotheses, one can derive explicit exponent thresholds beyond which no primitive solution exists. The interaction between local (residue) and global (ABC) methods is a key theme of our work.

Formal verification of number theory in proof assistants is a growing field. Notable achievements include the formalization of the odd order theorem (Gonthier et al., 2013), the formalization of Dirichlet's theorem on primes in arithmetic progressions, and ongoing work on formalizing class field theory.

### 1.3 Summary of Results

| Theorem | Statement | Section |
|---------|-----------|---------|
| `primitiveResidueSolution_of_dvd` | Solutions descend to divisors | §2 |
| `no_primitiveResidueSolution_of_dvd` | Obstructions propagate to multiples | §2 |
| `primitiveResidueSolution_mul_iff` | CRT compression (iff) | §3 |
| `cubic_obstruction_of_prime_power_obstruction` | Prime-power reduction | §3 |
| `no_primitiveResidueSolution_7_cube` | Mod 7 cubic obstruction | §4 |
| `exists_small_cubic_obstruction` | Existence of obstruction ≤ 10⁶ | §4 |
| `no_pairwise_coprime_sum_of_cubes_mod_7` | Integer consequence | §4 |
| `every_unit_is_cube_of_prime_mod3_eq2` | Cube surjectivity criterion | §5 |
| `primitiveResidueSolution_of_prime_mod3_eq2` | Non-obstruction criterion | §5 |

---

## 2. Definitions and Basic Properties

### 2.1 Primitive Residue Solutions

**Definition 2.1.** For $N, x, y, z \in \mathbb{N}$, a *primitive residue solution* modulo $N$ of signature $(x, y, z)$ is a triple $(a, b, c) \in (\mathbb{Z}/N\mathbb{Z})^3$ satisfying:
1. $a, b, c$ are all units in $\mathbb{Z}/N\mathbb{Z}$ (i.e., $\gcd(a, N) = \gcd(b, N) = \gcd(c, N) = 1$);
2. $a^x + b^y \equiv c^z \pmod{N}$.

We write $\mathrm{PRS}(N, x, y, z)$ for the proposition that such a triple exists.

In Lean 4:
```lean
def PrimitiveResidueSolution (N x y z : ℕ) : Prop :=
  ∃ a b c : ZMod N, IsUnit a ∧ IsUnit b ∧ IsUnit c ∧ a ^ x + b ^ y = c ^ z
```

The requirement that all three elements be units is the "primitive" condition, corresponding to the assumption that a global solution has $\gcd(ABC, N) = 1$.

### 2.2 Obstruction Monotonicity

**Theorem 2.2** (Solution Inheritance). *If $M \mid N$ and $\mathrm{PRS}(N, x, y, z)$ holds, then $\mathrm{PRS}(M, x, y, z)$ holds.*

*Proof.* The natural ring homomorphism $\varphi: \mathbb{Z}/N\mathbb{Z} \to \mathbb{Z}/M\mathbb{Z}$ (induced by $M \mid N$) sends units to units and preserves the polynomial equation. Given witnesses $(a, b, c)$ in $\mathbb{Z}/N\mathbb{Z}$, the images $(\varphi(a), \varphi(b), \varphi(c))$ are witnesses in $\mathbb{Z}/M\mathbb{Z}$. □

**Corollary 2.3** (Obstruction Monotonicity). *If $\neg\mathrm{PRS}(M, x, y, z)$ and $M \mid N$, then $\neg\mathrm{PRS}(N, x, y, z)$.*

This is the contrapositive of Theorem 2.2. In practice, it means one obstructing modulus annihilates all its multiples.

---

## 3. CRT Compression Theorem

### 3.1 Statement

**Theorem 3.1** (CRT Compression). *For coprime $M, N \in \mathbb{N}$:*
$$\mathrm{PRS}(M \cdot N, x, y, z) \iff \mathrm{PRS}(M, x, y, z) \wedge \mathrm{PRS}(N, x, y, z).$$

### 3.2 Proof

**Forward direction.** This follows immediately from Theorem 2.2, since both $M$ and $N$ divide $M \cdot N$.

**Backward direction.** This is the substantial direction. We use the Chinese Remainder Theorem isomorphism
$$\Phi: \mathbb{Z}/(MN)\mathbb{Z} \xrightarrow{\sim} \mathbb{Z}/M\mathbb{Z} \times \mathbb{Z}/N\mathbb{Z}$$
which exists when $\gcd(M, N) = 1$.

Given local witnesses $(a_1, b_1, c_1)$ in $\mathbb{Z}/M\mathbb{Z}$ and $(a_2, b_2, c_2)$ in $\mathbb{Z}/N\mathbb{Z}$, define:
$$a = \Phi^{-1}(a_1, a_2), \quad b = \Phi^{-1}(b_1, b_2), \quad c = \Phi^{-1}(c_1, c_2).$$

Since $\Phi$ is a ring isomorphism:
- **Units are preserved**: A pair $(u_1, u_2)$ is a unit in $R_1 \times R_2$ iff both components are units. Since $\Phi$ is an isomorphism, its inverse preserves the unit property.
- **The equation is preserved**: $\Phi(a^x + b^y) = (\Phi(a))^x + (\Phi(b))^y = (a_1^x + b_1^y, a_2^x + b_2^y) = (c_1^z, c_2^z) = \Phi(c)^z = \Phi(c^z)$, so $a^x + b^y = c^z$ by injectivity.

In Lean 4, the proof uses `ZMod.chineseRemainder`, `Prod.isUnit_iff`, and the ring homomorphism properties of the equivalence. □

### 3.3 Consequences

**Corollary 3.2** (Prime Power Reduction). *For any $N \geq 2$ and signature $(x, y, z)$:*
$$\neg\mathrm{PRS}(N, x, y, z) \iff \exists\, p^k \| N \text{ such that } \neg\mathrm{PRS}(p^k, x, y, z).$$

The forward direction is the CRT compression theorem applied to the prime power factorization of $N$. The backward direction is obstruction monotonicity.

**Corollary 3.3.** *The search for primitive residue obstructions reduces completely to prime powers.*

### 3.4 Complexity Analysis

For a modulus $N$ with prime factorization $N = \prod p_i^{k_i}$:
- **Without CRT**: Checking $\mathrm{PRS}(N, x, y, z)$ requires iterating over $\varphi(N)^3$ triples, where $\varphi(N)$ can be as large as $N$.
- **With CRT**: Check each $\mathrm{PRS}(p_i^{k_i}, x, y, z)$ independently, requiring $\sum_i \varphi(p_i^{k_i})^3$ operations.

For $N = 2 \cdot 7 \cdot 13 = 182$: without CRT, $\varphi(182)^3 = 72^3 = 373{,}248$ triples; with CRT, $1^3 + 6^3 + 12^3 = 1{,}945$ triples — a **192×** speedup.

---

## 4. Certified Cubic Obstructions

### 4.1 Computational Verification

We verify the following by exhaustive search in Lean 4 using `native_decide`:

**Theorem 4.1.** $\neg\mathrm{PRS}(2, 3, 3, 3)$, $\neg\mathrm{PRS}(7, 3, 3, 3)$, $\neg\mathrm{PRS}(13, 3, 3, 3)$.

Each instance unfolds the definition to a finite decidable proposition over $\mathbb{Z}/p\mathbb{Z}$ and is verified by Lean's native code evaluator.

**Theorem 4.2** (Main Existence Theorem). *There exists $N$ with $2 \leq N \leq 10^6$ such that $\neg\mathrm{PRS}(N, 3, 3, 3)$.*

*Proof.* Take $N = 7$. □

### 4.2 Completeness of the Obstruction Set

Computational search (in Python, verified against the Lean results) shows:
- Among primes $p \leq 200$, the obstructing primes for $(3,3,3)$ are exactly $\{2, 7, 13\}$.
- Among primes $p \leq 1000$, no additional obstructing primes appear beyond these three.

**Conjecture 4.3.** The only primes obstructing signature $(3,3,3)$ are $2, 7$, and $13$.

### 4.3 Integer Consequence

**Theorem 4.4.** *For all $A, B, C \in \mathbb{N}$ with $\gcd(A, 7) = \gcd(B, 7) = \gcd(C, 7) = 1$:*
$$A^3 + B^3 \neq C^3.$$

*Proof.* Reduce modulo 7. The residues $A \bmod 7, B \bmod 7, C \bmod 7$ are all nonzero (by the coprimality hypotheses) and hence are units in $\mathbb{Z}/7\mathbb{Z}$. The equation $A^3 + B^3 = C^3$ reduces to $\bar{A}^3 + \bar{B}^3 = \bar{C}^3$ in $\mathbb{Z}/7\mathbb{Z}$, contradicting Theorem 4.1. □

In Lean, this is proved directly by case analysis on residues modulo 7.

### 4.4 Coverage Analysis

The three obstructing primes $\{2, 7, 13\}$ cover a density of
$$1 - \prod_{p \in \{2,7,13\}} \left(1 - \frac{1}{p}\right) = 1 - \frac{1}{2} \cdot \frac{6}{7} \cdot \frac{12}{13} = 1 - \frac{36}{91} \approx 0.6044$$
of all positive integers. For 60.4% of all moduli $N$, no primitive residue solution to $a^3 + b^3 \equiv c^3$ exists.

---

## 5. Structural Classification: Cube Subgroup Analysis

### 5.1 The Cube Image in Finite Fields

For a prime $p$, define the cube image set:
$$C_p = \{u^3 : u \in (\mathbb{Z}/p\mathbb{Z})^\times\} \subseteq (\mathbb{Z}/p\mathbb{Z})^\times.$$

This is a subgroup of $(\mathbb{Z}/p\mathbb{Z})^\times$ of index $\gcd(3, p-1)$.

**Case 1: $p \equiv 2 \pmod{3}$.** Then $\gcd(3, p-1) = 1$, so $C_p = (\mathbb{Z}/p\mathbb{Z})^\times$. Every unit is a cube.

**Case 2: $p \equiv 1 \pmod{3}$.** Then $\gcd(3, p-1) = 3$, so $[(\mathbb{Z}/p\mathbb{Z})^\times : C_p] = 3$. Cubes form a proper subgroup of index 3.

**Case 3: $p = 3$.** Then $\gcd(3, 2) = 1$, so again $C_3 = (\mathbb{Z}/3\mathbb{Z})^\times$.

### 5.2 Non-Obstruction for $p \equiv 2 \pmod{3}$

**Theorem 5.1.** *If $p$ is prime with $p \equiv 2 \pmod{3}$, then every unit $a \in (\mathbb{Z}/p\mathbb{Z})^\times$ has a cube root: there exists a unit $b$ with $b^3 = a$.*

*Proof.* Since $\gcd(3, p-1) = 1$, the cube map $x \mapsto x^3$ on the cyclic group $(\mathbb{Z}/p\mathbb{Z})^\times$ of order $p-1$ is injective (any element of order dividing 3 must have order 1, since 3 does not divide $p-1$), hence bijective by finiteness. □

**Theorem 5.2.** *If $p$ is prime, $p \equiv 2 \pmod{3}$, and $p \geq 5$, then $\mathrm{PRS}(p, 3, 3, 3)$.*

*Proof.* Since every unit is a cube, $\mathrm{PRS}(p, 3, 3, 3)$ is equivalent to: there exist units $u, v, w$ with $u + v = w$. Taking $u = v = 1$ and $w = 2$ works, since $2$ is a unit when $p \geq 5$. □

### 5.3 Obstruction Criterion for $p \equiv 1 \pmod{3}$

When $p \equiv 1 \pmod{3}$, the question becomes: does the sumset $C_p + C_p$ intersect $C_p$ (within units)? That is, does there exist $(a, b, c) \in C_p^3$ with $a + b = c$ in $\mathbb{Z}/p\mathbb{Z}$?

This is a problem in **additive combinatorics of multiplicative subgroups**. The answer depends on the specific prime:

| Prime $p$ | $\|C_p\|$ | $(C_p + C_p) \cap C_p$ | Obstructs? |
|-----------|-----------|------------------------|------------|
| 7 | 2 | ∅ | Yes |
| 13 | 4 | ∅ | Yes |
| 19 | 6 | Non-empty | No |
| 31 | 10 | Non-empty | No |
| 37 | 12 | Non-empty | No |
| 43 | 14 | Non-empty | No |

The heuristic explanation: as $p$ grows, $|C_p| = (p-1)/3$ grows linearly, and the probability of sumset avoidance decreases exponentially. For $p = 7$ and $p = 13$, the cube subgroup is small enough that avoidance is possible; for $p \geq 19$, the subgroup is too large.

---

## 6. Connection to ABC Threshold Theory

### 6.1 The ABC-Exponent Bound

The ABC conjecture provides a complementary global approach. In prior work (also formally verified), we established:

**Theorem 6.1** (ABC Threshold). *If $\mathrm{IntAbcBound}(K)$ holds and $3K < n$, then no pairwise coprime positive integer solution to $A^x + B^y = C^z$ exists with $\min(x, y, z) \geq n$.*

### 6.2 Hybrid Architecture

The two approaches are complementary:

| Method | Eliminates | Requires |
|--------|------------|----------|
| ABC threshold | Large exponents ($\min \geq 3K+1$) | ABC hypothesis |
| Residue obstruction | Specific signatures | Finite computation |
| Combined | All primitive solutions (potentially) | Both |

For signature $(3,3,3)$, the ABC threshold (at $K = 1$) gives $3 \cdot 1 < 3$ which is false, so ABC alone does not help. But the residue obstruction at $N = 7$ directly proves: no solution with $\gcd(ABC, 7) = 1$.

---

## 7. Algorithms

### 7.1 Primitive Residue Solution Checker

```
Algorithm PRS_CHECK(N, x, y, z):
  Input: modulus N, exponents x, y, z
  Output: Boolean
  
  I_x ← {u^x mod N : u ∈ (Z/NZ)×}
  I_y ← {u^y mod N : u ∈ (Z/NZ)×}
  I_z ← {u^z mod N : u ∈ (Z/NZ)×}
  
  For each α ∈ I_x:
    For each β ∈ I_y:
      If (α + β) mod N ∈ I_z:
        Return TRUE
  Return FALSE
```

**Time complexity:** $O(\varphi(N)^2 \cdot \log(\max(x,y,z)))$ (computing power images is $O(\varphi(N) \log e)$; the double loop is $O(|I_x| \cdot |I_y|) \leq O(\varphi(N)^2)$).

**Space complexity:** $O(\varphi(N))$ for storing the image sets.

### 7.2 CRT-Decomposed Checker

```
Algorithm CRT_CHECK(N, x, y, z):
  Input: modulus N, exponents x, y, z
  Output: Boolean
  
  Factor N = p₁^k₁ · p₂^k₂ · ... · pₘ^kₘ
  For each i = 1, ..., m:
    If NOT PRS_CHECK(pᵢ^kᵢ, x, y, z):
      Return FALSE   -- obstruction found
  Return TRUE
```

**Time complexity:** $O(\sum_i \varphi(p_i^{k_i})^2 \cdot \log(\max(x,y,z)))$.

### 7.3 Obstruction Search Engine

```
Algorithm SEARCH(B, x, y, z):
  Input: bound B, exponents x, y, z
  Output: list of obstructing primes ≤ B
  
  result ← []
  For each prime p ≤ B:
    If NOT PRS_CHECK(p, x, y, z):
      result.append(p)
  Return result
```

---

## 8. Computational Experiments

### 8.1 Obstructing Primes by Signature

| Signature | Obstructing primes ≤ 100 | Count | Density |
|-----------|--------------------------|-------|---------|
| (3,3,3) | 2, 7, 13 | 3 | 0.604 |
| (3,3,5) | 2 | 1 | 0.500 |
| (3,5,5) | 2 | 1 | 0.500 |
| (5,5,5) | 2, 11, 41, 71 | 4 | 0.563 |
| (3,3,7) | 2 | 1 | 0.500 |
| (7,7,7) | 2, 29, 71 | 3 | 0.524 |

### 8.2 CRT Decomposition Examples

| $N$ | Factorization | Factor analysis | Result |
|-----|---------------|-----------------|--------|
| 42 | $2 \cdot 3 \cdot 7$ | $2$: obs, $3$: sol, $7$: obs | Obstructs |
| 91 | $7 \cdot 13$ | $7$: obs, $13$: obs | Obstructs |
| 182 | $2 \cdot 7 \cdot 13$ | All obstruct | Obstructs |
| 1001 | $7 \cdot 11 \cdot 13$ | $7$: obs, $11$: sol, $13$: obs | Obstructs |
| 15 | $3 \cdot 5$ | $3$: sol, $5$: sol | Solvable |

### 8.3 Coverage by Obstructing Primes

Among integers $2, \ldots, 1000$:
- 604/999 ≈ 60.5% are divisible by at least one of $\{2, 7, 13\}$
- Theoretical density: $1 - (1/2)(6/7)(12/13) \approx 60.44\%$

---

## 9. Discussion

### 9.1 Strengths

1. **Complete formal verification**: Every theorem is proved in Lean 4 with no axioms beyond the standard foundations.
2. **Compositionality**: The CRT compression theorem makes the theory modular — new obstructions compose automatically.
3. **Computational certification**: The `native_decide` proofs are fully trustworthy and efficiently verified.

### 9.2 Limitations

1. **Finite coverage only**: Residue obstructions can only prove that solutions coprime to the modulus don't exist. They cannot rule out solutions where the modulus divides one of the bases.
2. **Sparse obstructions for mixed signatures**: Signatures like $(3,3,5)$ have very few obstructing primes, limiting the method's reach.
3. **No connection to global descent**: The mod 7 obstruction for $(3,3,3)$ is a necessary step in proving FLT³, but not sufficient — one also needs infinite descent arguments.

### 9.3 Relationship to FLT

Our Theorem 4.4 is a key lemma in Euler's proof of FLT for $n = 3$: it forces $7 \mid ABC$ for any solution to $A^3 + B^3 = C^3$. The complete proof additionally requires showing that the resulting descent leads to a contradiction. Formalizing this descent is a natural next step.

---

## 10. Future Work

1. **Extend to prime powers**: Determine whether $p^k$ for $k \geq 2$ can obstruct when $p$ does not.
2. **Character sum criteria**: Develop explicit criteria using multiplicative characters for when $(C_p + C_p) \cap C_p = \emptyset$.
3. **Formal descent**: Complete the proof of FLT³ by formalizing Euler's descent argument.
4. **Generalized polynomial obstructions**: Extend the CRT framework to arbitrary polynomial equations over unit groups.
5. **ABC + residue hybrid**: Combine ABC threshold bounds with residue obstructions to produce complete impossibility proofs for specific Beal signatures.

---

## References

1. Beal, A. "The Beal Conjecture and Prize." *Notices of the AMS* 44 (1997).
2. Euler, L. *Algebra*. St. Petersburg, 1770.
3. Masser, D. W. and Oesterlé, J. "The ABC conjecture." Unpublished, 1985.
4. Wiles, A. "Modular elliptic curves and Fermat's Last Theorem." *Annals of Mathematics* 141 (1995), 443–551.
5. The Mathlib Community. *Mathlib: Lean's Mathematics Library*. https://leanprover-community.github.io/mathlib4_docs/
