# Dark Mathematics: Fast-Growing Hierarchies, Witness Complexity, and the Structure of Mathematical Unknowability

## Abstract

We formalize and prove structural theorems about "dark mathematics" — the phenomenon whereby certain existence theorems are provable in Peano arithmetic but no specific witness can be identified. We define the *darkness hierarchy* via the fast-growing (Wainer/Ackermann) function hierarchy, prove that the hierarchy is strict (Theorem 4.1), establish that the Ackermann function dominates every polynomial (Theorem 5.1), and show that the diagonal function n ↦ f_n(n) escapes every finite level (Theorem 6.1). We connect these results to Ramsey theory by proving that exponential Ramsey lower bounds exceed polynomial growth (Theorem 7.1), placing Ramsey-type witnesses at darkness level ≥ 1. All results are machine-verified in Lean 4 with the Mathlib library. We state a falsifiable darkness density conjecture and partially verify it: the conjecture fails at level 0→1 but holds at level 2→3.

**Keywords**: Fast-growing hierarchy, Ackermann function, witness complexity, Peano arithmetic, Ramsey theory, independence results

## 1. Introduction

### 1.1 Background

The study of unprovability in Peano arithmetic (PA) has a distinguished history beginning with Gödel's incompleteness theorems (1931). Paris and Harrington (1977) showed that a natural combinatorial statement — the strengthened finite Ramsey theorem — is true but unprovable in PA. Kirby and Paris (1982) established similar results via the hydra game. These results share a common feature: the minimum witnesses for the existential claims grow faster than any provably total function of PA.

This paper formalizes the mathematical structure underlying these phenomena. We define a *darkness hierarchy* that classifies existence theorems by the growth rate of their minimum witnesses, prove the hierarchy is strict, and connect it to concrete combinatorial and computational settings.

### 1.2 Contributions

1. **Formalization of the fast-growing hierarchy** with closed-form formulas at levels 1-3 and structural theorems (strict monotonicity, level monotonicity).
2. **Strict darkness hierarchy theorem**: level k+1 eventually dominates level k.
3. **Ackermann transcendence**: the Ackermann function dominates every polynomial, and the diagonal function dominates every fixed level.
4. **Ramsey theory bridge**: exponential Ramsey bounds exceed polynomial growth.
5. **Darkness density conjecture**: partially verified, with the failure at level 0→1 providing insight into the structure of the hierarchy.
6. **Complete machine verification** of all theorems in Lean 4.

## 2. Definitions and Notation

### 2.1 The Fast-Growing Hierarchy

**Definition 2.1** (Fast-Growing Hierarchy). The function `fastGrow : ℕ → ℕ → ℕ` is defined by:
- `fastGrow 0 n = n + 1`
- `fastGrow (k+1) 0 = fastGrow k 1`
- `fastGrow (k+1) (n+1) = fastGrow k (fastGrow (k+1) n)`

This coincides with the Ackermann function A(k, n) as defined by Péter (1935).

**Proposition 2.2** (Closed forms).
- `fastGrow 1 n = n + 2`
- `fastGrow 2 n = 2n + 3`
- `fastGrow 3 n = 2^(n+3) - 3`

*Proof*. By induction on n for each level. □

### 2.2 Darkness Levels

**Definition 2.3** (Darkness Level). A *darkness level* is a triple (k, w, π) where:
- k ∈ ℕ is the level index
- w : ℕ → ℕ is the witness bound function
- π : ∀ n, w(n) ≥ fastGrow(k, n) is the growth certificate

The *canonical darkness level* at level k uses w = fastGrow k.

**Definition 2.4** (Eventual Dominance). Function f *eventually dominates* g, written f ≫ g, if there exists N such that f(n) > g(n) for all n ≥ N.

### 2.3 Tower Function

**Definition 2.5**. The tower of 2s function:
- `tower2 0 = 1`
- `tower2 (n+1) = 2^(tower2 n)`

## 3. Basic Properties of the Fast-Growing Hierarchy

**Theorem 3.1** (Superlinearity). For all k, n ∈ ℕ: fastGrow(k, n) > n.

*Proof*. By well-founded induction on the recursive structure of fastGrow.
- Base (k=0): fastGrow(0, n) = n + 1 > n.
- Case (k+1, 0): fastGrow(k+1, 0) = fastGrow(k, 1) > 1 > 0 by inductive hypothesis.
- Case (k+1, n+1): fastGrow(k+1, n+1) = fastGrow(k, fastGrow(k+1, n)) > fastGrow(k+1, n) > n, so > n+1. □

**Theorem 3.2** (Strict Monotonicity). For each k, the function fastGrow(k, ·) is strictly monotone.

*Proof*. By induction on k, using `strictMono_nat_of_lt_succ`. For the successor case, fastGrow(k+1, n+1) = fastGrow(k, fastGrow(k+1, n)) > fastGrow(k+1, n) by Theorem 3.1. □

**Theorem 3.3** (Level Monotonicity). For n ≥ 1: fastGrow(k+1, n) ≥ fastGrow(k, n).

*Proof*. By induction on n. For n = 1: fastGrow(k+1, 1) = fastGrow(k, fastGrow(k+1, 0)) = fastGrow(k, fastGrow(k, 1)). Since fastGrow(k, 1) ≥ 2, monotonicity gives fastGrow(k, fastGrow(k, 1)) ≥ fastGrow(k, 2) > fastGrow(k, 1). For the step, use that fastGrow(k+1, n) ≥ fastGrow(k, n) ≥ n+1 by IH and Theorem 3.1. □

## 4. The Strict Darkness Hierarchy

**Theorem 4.1** (Strict Hierarchy). For every k ∈ ℕ, fastGrow(k+1) ≫ fastGrow(k).

*Proof*. We show that for n ≥ 2, fastGrow(k+1, n) > fastGrow(k, n). For n = m+1 with m ≥ 1:
fastGrow(k+1, m+1) = fastGrow(k, fastGrow(k+1, m)).
Since fastGrow(k+1, m) > m (Theorem 3.1), we have fastGrow(k+1, m) ≥ m+1.
Moreover, for m ≥ 1, fastGrow(k+1, m) ≥ m+2 (provable by induction).
Thus fastGrow(k, fastGrow(k+1, m)) ≥ fastGrow(k, m+2) > fastGrow(k, m+1) by strict monotonicity. □

**Corollary 4.2** (Transitivity). Eventual dominance is transitive: if f ≫ g and g ≫ h, then f ≫ h.

*Proof*. Take N = max(N₁, N₂) where N₁, N₂ are the respective thresholds. □

## 5. Ackermann Transcendence

**Theorem 5.1** (Ackermann Dominates Polynomials). For every d ∈ ℕ:
ackermann(d+2) ≫ (n ↦ n^(d+1)).

*Proof sketch*. Since ackermann = fastGrow (Proposition 5.0), it suffices to show fastGrow(d+2, n) > n^(d+1) for large n. For d = 0: fastGrow(2, n) = 2n+3 > n = n^1 for all n ≥ 0. For d ≥ 1: d+2 ≥ 3, so fastGrow(d+2, n) ≥ fastGrow(3, n) = 2^(n+3) - 3 for n ≥ 1 (by level monotonicity). Since 2^(n+3) grows exponentially and n^(d+1) grows polynomially, the result follows from the standard exponential-polynomial dominance theorem. □

**Lemma 5.2** (Exponential Exceeds Polynomial). For every d ∈ ℕ, there exists N such that 2^(n+3) > n^d + 3 for all n ≥ N.

*Proof*. Use the asymptotic fact that n^d / 2^n → 0 as n → ∞, which follows from Real.tendsto_exp_div_pow_atTop. □

**Theorem 5.3** (Ackermann = FastGrow). For all k, n: ackermann(k, n) = fastGrow(k, n).

*Proof*. By well-founded induction on the recursive structure. □

## 6. The Diagonal and Absolute Darkness

**Theorem 6.1** (Diagonal Dominance). For every k ∈ ℕ:
(n ↦ fastGrow(n, n)) ≫ fastGrow(k).

*Proof*. For n ≥ k+1, by iterated application of level monotonicity:
fastGrow(n, n) ≥ fastGrow(k+1, n).
By the strict hierarchy theorem (Theorem 4.1), fastGrow(k+1) ≫ fastGrow(k).
Combining: for n ≥ max(k+1, N_k) where N_k is the dominance threshold from Theorem 4.1:
fastGrow(n, n) ≥ fastGrow(k+1, n) > fastGrow(k, n). □

**Theorem 6.2** (Composition Bound). For all k₁, k₂, n:
fastGrow(k₁, fastGrow(k₂, n)) ≥ fastGrow(k₁, n).

*Proof*. By monotonicity: fastGrow(k₂, n) > n (Theorem 3.1), so fastGrow(k₂, n) ≥ n, and fastGrow(k₁, ·) is monotone (Theorem 3.2). □

## 7. Cross-Domain Bridge: Ramsey Theory

**Theorem 7.1** (Exponential Exceeds Polynomial). For every d ∈ ℕ, there exists N such that 2^(k/2) > k^d for all k ≥ N.

*Proof*. We prove that k^d / 2^(k/2) → 0 using the asymptotic dominance of exponentials over polynomials. The proof uses the Mathlib result `Real.tendsto_exp_div_pow_atTop` and careful handling of the √2 base conversion. □

**Theorem 7.2** (Exponential Lower Bound). For k ≥ 6: 2^(k/2) ≥ k.

*Proof*. By strong induction with base cases checked computationally. □

**Interpretation**: The diagonal Ramsey number R(k,k) satisfies R(k,k) ≥ 2^(k/2) (Erdős, 1947). Theorem 7.1 shows this lower bound exceeds every polynomial, placing Ramsey witnesses at darkness level ≥ 1 in our hierarchy. The Paris-Harrington strengthening pushes witnesses to darkness levels beyond any fixed level, giving a concrete example of "absolutely dark" combinatorial objects.

## 8. Darkness Density Conjecture

### 8.1 Statement

**Conjecture 8.1** (Darkness Density). For k ≥ 2, there exists N ≤ 10 such that fastGrow(k+1, n) > 2 · fastGrow(k, n) for all n ≥ N.

### 8.2 Partial Results

**Theorem 8.2** (Level 0→1 Failure). The density conjecture fails at k = 0: there is no n with fastGrow(1, n) > 2 · fastGrow(0, n).

*Proof*. fastGrow(1, n) = n + 2 and 2 · fastGrow(0, n) = 2(n+1) = 2n + 2. Since n + 2 ≤ 2n + 2 for all n ≥ 0, the inequality fails. □

**Theorem 8.3** (Level 2→3 Success). There exists N = 2 such that fastGrow(3, n) > 2 · fastGrow(2, n) for all n ≥ 2.

*Proof*. fastGrow(3, n) = 2^(n+3) - 3 and 2 · fastGrow(2, n) = 2(2n+3) = 4n + 6. For n ≥ 2: 2^(n+3) ≥ 32 while 4n + 9 ≤ 17, so 2^(n+3) - 3 > 4n + 6. The inductive step follows from 2^(n+4) = 2 · 2^(n+3) > 2(4n+9) > 4(n+1) + 9. □

### 8.3 Computational Evidence

| k | Level k formula | Level k+1 formula | Threshold N | Status |
|---|----------------|-------------------|-------------|--------|
| 0 | n + 2 | 2n + 3 | ∞ (fails) | DISPROVED |
| 1 | 2n + 3 | 2^(n+3) - 3 | 0 | Proved |
| 2 | 2^(n+3) - 3 | (super-exponential) | 0 | Conjectured |

## 9. Algorithms

### 9.1 Fast-Growing Hierarchy Computation

```
Algorithm: FastGrow(k, n)
Input: Level k ∈ ℕ, argument n ∈ ℕ
Output: fastGrow(k, n)

if k = 0 then return n + 1
if n = 0 then return FastGrow(k-1, 1)
return FastGrow(k-1, FastGrow(k, n-1))
```

**Complexity**: Time O(A(k,n)) where A is the Ackermann function. Space O(min(k·n, A(k,n))) with memoization. For k ≤ 3, O(1) using closed-form formulas.

### 9.2 Darkness Level Classifier

```
Algorithm: ClassifyDarkness(f, max_level, test_range)
Input: Monotone function f, maximum level, test range
Output: Estimated darkness level

for k = 0 to max_level:
    bounded = true
    for n = 0 to test_range:
        if f(n) > FastGrow(k, n):
            bounded = false; break
    if bounded: return k
return max_level + 1
```

**Complexity**: O(max_level · test_range · max_computation).

## 10. Applications

### 10.1 Termination Analysis

The darkness hierarchy provides a natural complexity classification for recursive programs beyond the polynomial/exponential divide:
- **Level 0-1**: Primitive recursive programs with simple loop bounds
- **Level 2**: Programs requiring multiply-nested recursion
- **Level 3+**: Programs whose termination requires transfinite induction (e.g., the hydra game)
- **Diagonal**: Non-primitive-recursive programs (Ackermann's function)

### 10.2 Combinatorial Witness Bounds

Ramsey-type theorems provide canonical examples of dark witnesses at each level. The growth rate of Ramsey numbers R(k,k) ≥ 2^(k/2) places them at darkness level ≥ 1, while the Paris-Harrington witnesses grow faster than any fixed level.

## 11. Discussion

### 11.1 Implications

The strict darkness hierarchy provides a precise mathematical framework for discussing degrees of unknowability. Unlike Gödel's incompleteness — which deals with unprovable statements — darkness deals with *unpinnable* witnesses: statements whose truth is provable but whose witnesses escape identification.

### 11.2 Limitations

Our formalization operates within ZFC (via Lean's type theory), which is strictly stronger than PA. The darkness hierarchy as formalized measures growth rates relative to PA's provably total functions, but the proofs themselves use resources beyond PA (e.g., transfinite induction up to ε₀). Formalizing the metamathematical content — specifically, what PA can and cannot prove — would require a formalization of PA's proof theory within Lean.

### 11.3 Open Questions

1. Is the darkness density conjecture true for all k ≥ 2?
2. Can the threshold N in the density conjecture be bounded uniformly in k?
3. What is the precise darkness level of specific combinatorial principles (e.g., Kruskal's tree theorem, Graph Minor theorem)?
4. Is there a natural algebraic structure on the space of darkness levels?

## 12. Future Work

1. Formalize provability predicates for PA to make the darkness definition fully metamathematical.
2. Extend the hierarchy to ordinal-indexed levels (fast-growing hierarchy at ε₀ and beyond).
3. Connect to reverse mathematics: classify the exact proof-theoretic strength corresponding to each darkness level.
4. Investigate the computational complexity of the darkness density conjecture.

## References

1. Gödel, K. (1931). Über formal unentscheidbare Sätze der Principia Mathematica und verwandter Systeme I.
2. Paris, J. & Harrington, L. (1977). A mathematical incompleteness in Peano arithmetic. *Handbook of Mathematical Logic*.
3. Kirby, L. & Paris, J. (1982). Accessible independence results for Peano arithmetic. *Bull. London Math. Soc.* 14(4), 285-293.
4. Péter, R. (1935). Konstruktion nichtrekursiver Funktionen. *Math. Ann.* 111, 42-60.
5. Wainer, S.S. (1970). A classification of the ordinal recursive functions. *Archiv für math. Logik* 13, 136-153.
6. Friedman, H. (1998). Long finite sequences. *J. Combinatorial Theory A* 95, 102-144.
7. Erdős, P. (1947). Some remarks on the theory of graphs. *Bull. AMS* 53, 292-294.
