# Tropical Additive Combinatorics: A Formal Framework Connecting Min-Plus Convolution to Sumset Theory

## Abstract

We develop a rigorous framework for tropical (min-plus) additive combinatorics over the natural numbers, establishing exact equivalence theorems between sumset membership and the vanishing of tropical convolutions of set indicator functions. Our framework is formalized and machine-verified.

The main contributions are:
1. **Tropical-additive equivalence**: For sets $A, B \subseteq \mathbb{N}$ and $n \in \mathbb{N}$, the tropical convolution $(\mathbf{1}_A^{\mathrm{trop}} \star_T \mathbf{1}_B^{\mathrm{trop}})(n) = 0$ if and only if $n \in A + B$.
2. **Goldbach reformulation**: Goldbach's conjecture is equivalent to the vanishing of the tropical self-convolution of the prime indicator on all even numbers $> 2$.
3. **Boundedness obstruction**: If any Goldbach counterexample exists, the tropical Goldbach function is unbounded.
4. **Cofinite basis theorem**: Cofinite subsets of $\mathbb{N}$ have eventually vanishing tropical self-convolution with an explicit threshold.
5. **Sumset correspondence**: The zero locus of a tropical indicator convolution exactly equals the Minkowski sum of the underlying finite sets.

All results are formalized in Lean 4 with complete, sorry-free proofs depending only on standard axioms (propext, Classical.choice, Quot.sound).

## 1. Introduction

### 1.1 Motivation

Additive combinatorics studies the structure of sumsets $A + B = \{a + b : a \in A, b \in B\}$ for subsets $A, B$ of abelian groups. Central questions include: which elements belong to $A + B$? How large is $|A + B|$? When does iterated summation $hA = A + A + \cdots + A$ cover all sufficiently large integers?

Goldbach's conjecture — that every even integer $> 2$ is a sum of two primes — is the most famous instance: it asks whether $\mathbb{P} + \mathbb{P}$ contains all even integers $> 2$, where $\mathbb{P}$ denotes the set of primes.

Tropical (min-plus) algebra replaces the usual arithmetic operations: "addition" becomes minimum, "multiplication" becomes ordinary addition. This framework has deep connections to optimization, algebraic geometry, and automata theory. We show that it also provides a natural and exact reformulation of additive combinatorial questions.

### 1.2 Related Work

**Tropical mathematics.** The tropical semiring $(\mathbb{R} \cup \{\infty\}, \min, +)$ has been studied extensively in combinatorial optimization (shortest paths, assignment problems), algebraic geometry (tropical varieties, Newton polytopes), and theoretical computer science (weighted automata). See Maclagan–Sturmfels (2015) for a comprehensive treatment.

**Min-plus convolution.** The min-plus convolution $(f \star g)(n) = \min_{a+b=n} (f(a) + g(b))$ arises in computational geometry (Frechet distance), dynamic programming, and signal processing. Its computational complexity — whether it can be computed in truly subquadratic time — is a major open problem connected to APSP and other fine-grained complexity questions.

**Additive number theory.** Schnirelmann's theorem (1930) showed that the primes form an asymptotic additive basis of finite order. Vinogradov (1937) proved the ternary Goldbach conjecture for sufficiently large odd integers, recently made effective by Helfgott (2013). The binary Goldbach conjecture remains open.

### 1.3 Our Contribution

We bridge these areas by showing that additive representation theory translates exactly into tropical convolution theory. This is not an approximation or analogy — it is a precise mathematical equivalence. The translation preserves all information: sumset membership becomes tropical vanishing, and conversely.

## 2. Definitions and Notation

### 2.1 The Tropical Cost Semiring

We work in $\mathbb{N}_\top = \mathbb{N} \cup \{\top\}$ (denoted `WithTop ℕ` in Lean 4), the natural numbers extended with a top element $\top$. This is a linearly ordered commutative monoid under addition, where $\top + x = x + \top = \top$ for all $x$.

The semilattice structure $(\mathbb{N}_\top, \min)$ provides an infimum operation. The pair $(\mathbb{N}_\top, \min, +)$ is the tropical semiring we use.

### 2.2 Tropical Indicator

**Definition 2.1** (Tropical Indicator). For $A \subseteq \mathbb{N}$, define $\mathbf{1}_A^T : \mathbb{N} \to \mathbb{N}_\top$ by
$$\mathbf{1}_A^T(n) = \begin{cases} 0 & \text{if } n \in A \\ \top & \text{if } n \notin A \end{cases}$$

```lean
noncomputable def tropInd (A : Set ℕ) (n : ℕ) : WithTop ℕ :=
  if n ∈ A then 0 else ⊤
```

### 2.3 Tropical Convolution

**Definition 2.2** (Tropical Convolution). For $f, g : \mathbb{N} \to \mathbb{N}_\top$, define
$$(f \star_T g)(n) = \inf_{a \in \{0, \ldots, n\}} \bigl(f(a) + g(n - a)\bigr)$$

```lean
noncomputable def tropConvNat (f g : ℕ → WithTop ℕ) (n : ℕ) : WithTop ℕ :=
  Finset.inf (Finset.range (n + 1)) (fun a => f a + g (n - a))
```

The infimum is taken over the finite set $\{0, \ldots, n\}$, using the `Finset.inf` operation which takes the minimum in the lattice $(\mathbb{N}_\top, \leq)$ where $\top$ is the top element.

### 2.4 Prime Cost and Goldbach Function

**Definition 2.3.** The *prime cost function* is $\mathbf{1}_{\mathbb{P}}^T$, and the *tropical Goldbach function* is its self-convolution:
$$G_T(n) = (\mathbf{1}_{\mathbb{P}}^T \star_T \mathbf{1}_{\mathbb{P}}^T)(n) = \min_{a+b=n} (\mathbf{1}_{\mathbb{P}}^T(a) + \mathbf{1}_{\mathbb{P}}^T(b))$$

```lean
def primeCost (n : ℕ) : WithTop ℕ := if Nat.Prime n then 0 else ⊤

noncomputable def goldbachTrop (n : ℕ) : WithTop ℕ :=
  tropConvNat primeCost primeCost n
```

## 3. Main Results

### 3.1 Tropical-Additive Equivalence (Theorem 1)

**Theorem 3.1.** For $A, B \subseteq \mathbb{N}$ and $n \in \mathbb{N}$:
$$(\mathbf{1}_A^T \star_T \mathbf{1}_B^T)(n) = 0 \iff \exists\, a \in A,\, b \in B : a + b = n$$

*Proof sketch.* Each summand $\mathbf{1}_A^T(a) + \mathbf{1}_B^T(n-a)$ is either $0$ (if $a \in A$ and $n-a \in B$) or $\top$ (otherwise). The infimum of a finite set of values in $\{0, \top\}$ is $0$ iff at least one value is $0$.

For the forward direction: if the infimum is $0$, then some $a \in \{0, \ldots, n\}$ satisfies $\mathbf{1}_A^T(a) + \mathbf{1}_B^T(n-a) = 0$, hence $a \in A$ and $n-a \in B$.

For the backward direction: if $a \in A$, $b \in B$, $a + b = n$, then $a \leq n$, so $a \in \{0, \ldots, n\}$ and $\mathbf{1}_A^T(a) + \mathbf{1}_B^T(n-a) = 0 + 0 = 0$. The infimum is at most this value, hence $\leq 0$, hence $= 0$.

**Theorem 3.2** (Complement). Under the same hypotheses:
$$(\mathbf{1}_A^T \star_T \mathbf{1}_B^T)(n) = \top \iff \neg\exists\, a \in A,\, b \in B : a + b = n$$

This follows immediately from Theorem 3.1 and the fact that the convolution takes values in $\{0, \top\}$.

### 3.2 Goldbach–Tropical Equivalence (Theorem 2)

**Theorem 3.3.** For all $n \in \mathbb{N}$:
$$G_T(n) = 0 \iff \exists\, p, q \text{ prime} : p + q = n$$

*Proof.* Since `primeCost` agrees pointwise with `tropInd (setOf Nat.Prime)`, this is a direct instance of Theorem 3.1 with $A = B = \mathbb{P}$.

**Corollary 3.4** (Goldbach Equivalence).
$$\bigl(\forall n > 2,\, 2 \mid n \implies G_T(n) = 0\bigr) \iff \text{Goldbach's conjecture}$$

### 3.3 Boundedness Obstruction (Theorem 3)

**Theorem 3.5.** If there exists an even $n > 2$ with no prime pair summing to $n$, then $G_T(n) = \top$.

*Proof.* By Theorem 3.3, $G_T(n) \neq 0$. By the dichotomy (Theorem 3.2), $G_T(n) = \top$.

**Corollary 3.6.** If Goldbach's conjecture is false, then for no $C \in \mathbb{N}$ does $G_T(n) \leq C$ hold for all even $n > 2$.

*Proof.* If $G_T(n_0) = \top$ for some even $n_0 > 2$, then $G_T(n_0) = \top > C$ for any $C \in \mathbb{N}$.

This theorem establishes that the tropical formulation admits no "softening": boundedness of the tropical Goldbach function is equivalent to Goldbach's conjecture, not a weaker approximation.

### 3.4 Cofinite Basis Theorem (Theorem 4)

**Theorem 3.7** (Quantitative). Let $A \subseteq \mathbb{N}$ with $\{n : n \notin A\} \subseteq \{0, \ldots, M-1\}$. Then:
$$\forall n \geq 2M : (\mathbf{1}_A^T \star_T \mathbf{1}_A^T)(n) = 0$$

*Proof.* For $n \geq 2M$, take the witness $a = M$. Then $M \leq n$, $M \geq M$ so $M \in A$, and $n - M \geq M$ so $n - M \in A$. Hence $\mathbf{1}_A^T(M) + \mathbf{1}_A^T(n - M) = 0$.

**Corollary 3.8** (Qualitative). If $A^c$ is finite, then $\exists\, N : \forall n \geq N,\, (\mathbf{1}_A^T \star_T \mathbf{1}_A^T)(n) = 0$.

*Proof.* Take $M = \max(A^c) + 1$ and $N = 2M$.

The bound $2M$ is tight: if $A = \{M, M+1, \ldots\}$, then $2M - 1$ cannot be decomposed as $a + b$ with $a, b \geq M$.

### 3.5 Sumset Correspondence (Theorem 5)

**Theorem 3.9.** For finite sets $A, B \subseteq \mathbb{N}$ and $N > \max(A) + \max(B)$:
$$\{n < N : (\mathbf{1}_A^T \star_T \mathbf{1}_B^T)(n) = 0\} = A + B$$

This follows from Theorem 3.1 by filtering both sides over $\{0, \ldots, N-1\}$.

### 3.6 Commutativity

**Theorem 3.10.** Tropical convolution is commutative: $(f \star_T g)(n) = (g \star_T f)(n)$ for all $f, g, n$.

*Proof.* The map $a \mapsto n - a$ is a bijection on $\{0, \ldots, n\}$, and addition on $\mathbb{N}_\top$ is commutative.

## 4. Algorithms

### 4.1 Naive Tropical Convolution

**Algorithm 1**: Tropical convolution at a point.

```
Input: cost functions f, g; target n
Output: (f ⋆_T g)(n)

result ← ⊤
for a = 0 to n:
    val ← f(a) + g(n - a)   // ⊤ + x = ⊤
    result ← min(result, val)
return result
```

**Complexity**: $O(n)$ time, $O(1)$ space.

### 4.2 Batch Tropical Convolution

**Algorithm 2**: Compute $(f \star_T g)(n)$ for all $n = 0, \ldots, N-1$.

```
Input: cost functions f, g; bound N
Output: array result[0..N-1]

for n = 0 to N-1:
    result[n] ← ⊤
    for a = 0 to n:
        result[n] ← min(result[n], f(a) + g(n-a))
return result
```

**Complexity**: $O(N^2)$ time, $O(N)$ space.

Note: Whether tropical convolution admits a truly subquadratic algorithm (i.e., $O(N^{2-\varepsilon})$ for some $\varepsilon > 0$) is a major open problem in fine-grained complexity theory, equivalent to fundamental questions about All-Pairs Shortest Paths.

### 4.3 Goldbach Tropical Verification

**Algorithm 3**: Verify $G_T(n) = 0$ for all even $n \in [4, N]$.

```
Input: bound N
Output: (verified, counterexamples)

is_prime ← sieve_of_eratosthenes(N)
counterexamples ← []
for n = 4, 6, ..., N:
    found ← false
    for p = 2 to n/2:
        if is_prime[p] and is_prime[n-p]:
            found ← true; break
    if not found:
        counterexamples.append(n)
return (counterexamples = [], counterexamples)
```

**Complexity**: $O(N^2 / \log^2 N)$ time (using prime density), $O(N)$ space.

## 5. Computational Experiments

### 5.1 Goldbach Verification

We computed $G_T(n)$ for all even $n \in [4, 10000]$. Result: $G_T(n) = 0$ for all tested values, consistent with Goldbach's conjecture. The representation count $r(n)$ — the number of unordered prime pairs summing to $n$ — grows roughly as $n / (\log n)^2$, consistent with the Hardy–Littlewood asymptotic.

### 5.2 Cofinite Threshold Verification

For $A = \mathbb{N} \setminus \{0, 1, 2, 3, 4\}$ ($M = 5$), the tropical self-convolution vanishes for all $n \geq 10 = 2M$, confirming Theorem 3.7. Below the threshold: the convolution is $\top$ for $n \in \{0, \ldots, 9\}$ and $0$ for $n \geq 10$.

### 5.3 Sumset Correspondence

For $A = \{1, 4, 7\}$, $B = \{2, 3, 8\}$: the zero locus of the tropical convolution is $\{3, 4, 6, 7, 9, 10, 12, 15\}$, exactly matching $A + B$.

## 6. Discussion

### 6.1 What the Framework Achieves

The tropical-additive equivalence theorem provides a certified, bidirectional translation between classical additive combinatorics and tropical algebra. This creates several new capabilities:

1. **Precision**: The equivalence is exact — no information is lost in translation.
2. **Machinery access**: Results from tropical geometry, optimization, and semiring theory become available for additive number theory.
3. **Formal verification**: All theorems are machine-checked, providing the highest level of mathematical certainty.

### 6.2 What It Does Not Achieve

The framework does not prove Goldbach's conjecture. Theorem 3.3 shows that Goldbach is equivalent to a tropical statement, but the tropical statement is exactly as hard as the original conjecture. The framework provides no new information about the distribution of primes.

The counterexample theorem (3.5–3.6) shows that certain naive strategies — proving "bounded" tropical costs as a stepping stone — are provably futile.

### 6.3 Implications for Future Research

The framework suggests several research directions:

- **Tropical density theory**: Define tropical analogues of Schnirelmann and asymptotic density and prove comparison theorems.
- **Finite-group tropicalization**: Extend the framework to $\mathbb{Z}/p\mathbb{Z}$ and prove tropical versions of Cauchy–Davenport.
- **Weighted costs**: Replace binary indicators with graded cost functions encoding multiplicative structure.
- **Analytic transfer**: Formulate how circle method estimates on representation functions imply tropical vanishing.

## 7. Future Work

See `FUTURE_DIRECTIONS.md` for a detailed roadmap of next steps, including specific theorem candidates, implementation plans, and Mathlib dependencies.

## 8. References

1. Goldbach, C. Letter to L. Euler, June 7, 1742.
2. Helfgott, H.A. "The ternary Goldbach conjecture is true." *arXiv:1312.7748*, 2013.
3. Maclagan, D. and Sturmfels, B. *Introduction to Tropical Geometry*. Graduate Studies in Mathematics, vol. 161, AMS, 2015.
4. Nathanson, M.B. *Additive Number Theory: The Classical Bases*. Graduate Texts in Mathematics, vol. 164, Springer, 1996.
5. Schnirelmann, L.G. "Über additive Eigenschaften von Zahlen." *Math. Ann.* 107 (1933), 649–690.
6. Simon, I. "Recognizable sets with multiplicities in the tropical semiring." *MFCS 1988*, Lecture Notes in Computer Science, vol. 324, Springer, 1988.
7. Tao, T. and Vu, V.H. *Additive Combinatorics*. Cambridge Studies in Advanced Mathematics, vol. 105, Cambridge University Press, 2006.
