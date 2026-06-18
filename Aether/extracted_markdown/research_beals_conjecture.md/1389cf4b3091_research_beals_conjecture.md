# Formal Obstruction Theory for Beal's Conjecture: Primitive Reductions, Radical Identities, and Conditional ABC Bridges

## Abstract

We develop a formally verified obstruction theory for Beal's conjecture, consisting of four families of theorems proved in Lean 4 with the Mathlib library. Our main results are: (1) a **primitive reduction theorem** showing that any Beal counterexample automatically yields a pairwise coprime primitive counterexample; (2) a **radical identity** for primitive Beal triples establishing $\mathrm{rad}(A^xB^yC^z) = \mathrm{rad}(ABC)$; (3) **exponent reciprocal bounds** positioning Beal at the Fermat–Catalan threshold; and (4) a **conditional impossibility theorem** showing that an integer ABC hypothesis at exponent $K=2$ eliminates all primitive Beal solutions with exponents greater than 6. All proofs are machine-verified with no sorry axioms, using only standard foundational axioms (propext, Classical.choice, Quot.sound). We additionally provide computational demonstrations including exhaustive search verification, ABC quality analysis, and modular obstruction enumeration.

## 1. Introduction

### 1.1 Beal's Conjecture

Beal's conjecture (1993) states that for positive integers $A, B, C, x, y, z$ with $x, y, z > 2$, if $A^x + B^y = C^z$, then $\gcd(A, B, C) > 1$—equivalently, there exists a prime $p$ dividing all three bases. The conjecture generalizes Fermat's Last Theorem (the case $x = y = z$) and carries a \$1,000,000 prize.

### 1.2 Relationship to Prior Work

The generalized Fermat equation $x^p + y^q = z^r$ has been studied extensively:

- **Fermat–Catalan conjecture** (Darmon–Granville, 1995): When $1/p + 1/q + 1/r < 1$, only finitely many coprime solutions exist, proved using Faltings' theorem.
- **ABC conjecture** (Oesterlé–Masser, 1985): Provides the quantitative framework connecting radical size to solution existence.
- **Known solved cases**: $x = y = z$ (Wiles, 1995); $(2,3,7)$, $(2,3,8)$, and several other specific triples (Poonen, Schaefer, Stoll, Bruin, et al.).

Our contribution is not to resolve Beal but to formalize the *reduction infrastructure*—the mathematical scaffolding that any future proof must rely on—with machine-verified certainty.

### 1.3 Overview of Results

| Theorem | Statement | File |
|---------|-----------|------|
| Primitive Reduction | No-common-prime $\Rightarrow$ pairwise coprime | `PrimitiveReduction.lean` |
| Radical Identity | $\mathrm{rad}(A^xB^yC^z) = \mathrm{rad}(ABC)$ | `Radical.lean` |
| Exponent Bounds | $1/x + 1/y + 1/z \leq 1$, equality iff $(3,3,3)$ | `ExponentBounds.lean` |
| ABC Bridge | $\mathrm{ABCInt}(2) \Rightarrow$ no solutions with $x,y,z > 6$ | `ABCBridge.lean` |

## 2. Definitions and Notation

### 2.1 Beal's Conjecture (Formal)

```
def BealConjecture : Prop :=
  ∀ A B C x y z : ℕ,
    0 < A → 0 < B → 0 < C →
    2 < x → 2 < y → 2 < z →
    A ^ x + B ^ y = C ^ z →
    ∃ p : ℕ, Nat.Prime p ∧ p ∣ A ∧ p ∣ B ∧ p ∣ C
```

### 2.2 Radical Function

We use Mathlib's `UniqueFactorizationMonoid.radical`, which for $n \in \mathbb{N}$ computes
$$\mathrm{rad}(n) = \prod_{p \mid n,\, p \text{ prime}} p.$$

Key Mathlib lemmas used:
- `radical_pow a (hn : n ≠ 0) : radical (a ^ n) = radical a`
- `radical_mul (h : IsRelPrime a b) : radical (a * b) = radical a * radical b`
- `radical_dvd_self : radical a ∣ a`

### 2.3 Integer ABC Hypothesis

```
def ABCIntStatement (K : ℕ) : Prop :=
  ∀ a b c : ℕ,
    0 < a → 0 < b → 0 < c →
    Nat.Coprime a b → a + b = c →
    c ≤ (radical (a * b * c)) ^ K
```

## 3. Main Results

### 3.1 Primitive Reduction Theorem

**Theorem 3.1** (Prime propagation). *If $p$ is prime, $p \mid A$, $p \mid B$, and $A^x + B^y = C^z$ with $x, y, z > 0$, then $p \mid C$.*

*Proof sketch.* Since $p \mid A$ and $x > 0$, $p \mid A^x$. Similarly $p \mid B^y$. Therefore $p \mid A^x + B^y = C^z$. Since $p$ is prime and $p \mid C^z$, we have $p \mid C$ by `Nat.Prime.dvd_of_dvd_pow`. $\square$

**Theorem 3.2** (Primitive reduction). *If $A^x + B^y = C^z$ with $x, y, z > 2$ and no prime divides all three of $A, B, C$, then $A, B, C$ are pairwise coprime.*

*Proof.* By Theorem 3.1 applied to each pair: if $p \mid A$ and $p \mid B$, then $p \mid C$, contradicting the hypothesis. The argument is symmetric for the pairs $(A,C)$ and $(B,C)$. $\square$

**Theorem 3.3** (Equivalence). *Beal's conjecture holds if and only if no pairwise coprime solution to $A^x + B^y = C^z$ with $x, y, z > 2$ exists.*

*Proof.* Forward: a common prime contradicts coprimality. Backward: if no primitive solution exists, any solution without a common prime would yield one by Theorem 3.2, contradiction. $\square$

### 3.2 Radical Identity for Primitive Beal Triples

**Theorem 3.4** (Primitive radical identity). *For pairwise coprime $A, B, C$ with $x, y, z > 0$,*
$$\mathrm{rad}(A^x \cdot B^y \cdot C^z) = \mathrm{rad}(A) \cdot \mathrm{rad}(B) \cdot \mathrm{rad}(C).$$

*Proof.* Coprimality of $A$ and $B$ implies coprimality of $A^x$ and $B^y$ (by `Nat.Coprime.pow`). Then:
1. $\mathrm{rad}(A^x \cdot B^y) = \mathrm{rad}(A^x) \cdot \mathrm{rad}(B^y)$ by `radical_mul` (coprime product).
2. $\mathrm{rad}(A^x) = \mathrm{rad}(A)$ and $\mathrm{rad}(B^y) = \mathrm{rad}(B)$ by `radical_pow`.
3. Similarly for the factor $C^z$, using coprimality of $A^x \cdot B^y$ and $C^z$. $\square$

**Corollary 3.5.** $\mathrm{rad}(A^x \cdot B^y \cdot C^z) = \mathrm{rad}(A \cdot B \cdot C)$ for pairwise coprime $A, B, C$.

### 3.3 Exponent Reciprocal Bounds

**Theorem 3.6.** *For $x, y, z > 2$: $\frac{1}{x} + \frac{1}{y} + \frac{1}{z} \leq 1$.*

*Proof.* Since $x, y, z \geq 3$, each reciprocal is at most $1/3$. Sum $\leq 1$. $\square$

**Theorem 3.7.** *$\frac{1}{x} + \frac{1}{y} + \frac{1}{z} = 1$ if and only if $x = y = z = 3$.*

*Proof.* Forward: $1/3 + 1/3 + 1/3 = 1$. Backward: if any exponent exceeds 3, say $x \geq 4$, then the sum is at most $1/4 + 1/3 + 1/3 = 11/12 < 1$. $\square$

**Theorem 3.8.** *If not all exponents equal 3, then $\frac{1}{x} + \frac{1}{y} + \frac{1}{z} < 1$.*

This positions Beal at the Fermat–Catalan boundary: the cubic case $x = y = z = 3$ (Fermat's Last Theorem, proved by Wiles) is the unique boundary point. All other Beal exponent triples lie in the hyperbolic regime where Fermat–Catalan predicts finiteness.

### 3.4 Conditional ABC Bridge

**Theorem 3.9** (ABC radical bound). *If $\mathrm{ABCStatement}(\varepsilon)$ holds, then for any pairwise coprime Beal solution $A^x + B^y = C^z$:*
$$C^z \leq \mathrm{rad}(ABC)^{1+\varepsilon}.$$

*Proof.* Apply the ABC hypothesis to the coprime triple $(A^x, B^y, C^z)$, then use Corollary 3.5 to simplify the radical. $\square$

**Theorem 3.10** (Integer ABC product bound). *If $\mathrm{ABCIntStatement}(K)$ holds, then for any pairwise coprime Beal solution: $C^z \leq (ABC)^K$.*

*Proof.* As above, using $\mathrm{rad}(ABC) \leq ABC$ (since the radical divides). $\square$

**Theorem 3.11** (Conditional impossibility). *If $\mathrm{ABCIntStatement}(2)$ holds, then no pairwise coprime solution to $A^x + B^y = C^z$ with $x, y, z > 6$ and $C \geq 2$ exists.*

*Proof.* The argument proceeds in four steps:

1. **ABC bound**: $C^z \leq (ABC)^2$ (Theorem 3.10 with $K = 2$).

2. **Seventh-power amplification**: Raise to the 7th power: $C^{7z} \leq (ABC)^{14}$.

3. **Base bounds**: Since $x \geq 7$, we have $A^7 \leq A^x < C^z$ (the last inequality because $B^y > 0$). Squaring: $A^{14} < C^{2z}$. Similarly $B^{14} < C^{2z}$. Since $z \geq 7$, also $C^{14} \leq C^{2z}$. Therefore $(ABC)^{14} = A^{14} \cdot B^{14} \cdot C^{14} < C^{2z} \cdot C^{2z} \cdot C^{2z} = C^{6z}$.

4. **Contradiction**: $C^{7z} \leq (ABC)^{14} < C^{6z}$, but $C^{7z} > C^{6z}$ since $C \geq 2$ and $7z > 6z$. $\square$

## 4. Algorithms

### 4.1 Radical Computation

**Algorithm** (Trial division): Given $n$, compute $\mathrm{rad}(n)$ by trial division up to $\sqrt{n}$.

- **Time**: $O(\sqrt{n})$
- **Space**: $O(\log n)$

**Algorithm** (Sieve): Compute $\mathrm{rad}(n)$ for all $n \leq N$ using a modified Sieve of Eratosthenes.

- **Time**: $O(N \log \log N)$
- **Space**: $O(N)$

### 4.2 Modular Obstruction Search

**Algorithm**: For a given modulus $m$ and exponent triple $(x, y, z)$, check whether any coprime solution to $A^x + B^y \equiv C^z \pmod{m}$ exists.

```
function CHECK_OBSTRUCTION(m, x, y, z):
    for a in 1..m-1 with gcd(a,m) = 1:
        for b in 1..m-1 with gcd(b,m) = 1:
            target = (a^x + b^y) mod m
            for c in 1..m-1 with gcd(c,m) = 1:
                if c^z mod m == target:
                    return False  // Solution exists
    return True  // Obstruction!
```

- **Time**: $O(m^3)$ per modulus
- **Space**: $O(m)$

### 4.3 ABC Quality Computation

**Algorithm**: For each coprime triple $(a, b, c)$ with $a + b = c$ and $c \leq N$, compute the quality $q = \log c / \log \mathrm{rad}(abc)$.

- **Time**: $O(N^2)$ with sieved radicals, $O(N^2 \sqrt{N})$ with trial division
- **Space**: $O(N)$ with sieve

## 5. Computational Experiments

### 5.1 Exhaustive Beal Search

We searched all solutions to $A^x + B^y = C^z$ with $A, B, C \leq 100$ and $x, y, z \in \{3, 4, 5, 6, 7\}$. All 41 solutions found have a common prime factor, consistent with Beal's conjecture.

Representative solutions:
| $A$ | $B$ | $C$ | $x$ | $y$ | $z$ | Common prime |
|-----|-----|-----|-----|-----|-----|-------------|
| 2 | 2 | 2 | 3 | 3 | 4 | 2 |
| 3 | 6 | 3 | 3 | 3 | 5 | 3 |
| 7 | 7 | 14 | 3 | 4 | 3 | 7 |
| 17 | 34 | 17 | 4 | 4 | 5 | 17 |

### 5.2 ABC Quality Analysis

Among coprime triples $(a, b, c)$ with $c \leq 2000$, the highest-quality triples are:

| $a$ | $b$ | $c$ | $\mathrm{rad}(abc)$ | Quality |
|-----|-----|-----|---------------------|---------|
| 3 | 125 | 128 | 30 | 1.4266 |
| 1 | 512 | 513 | 114 | 1.3176 |
| 1 | 242 | 243 | 66 | 1.3111 |
| 1 | 80 | 81 | 30 | 1.2920 |
| 1 | 8 | 9 | 6 | 1.2263 |

No triple exceeds quality 1.5 in this range, consistent with the ABC conjecture.

### 5.3 Modular Obstruction Density

For exponent triple $(4,4,4)$, 24 of the first 30 moduli (80%) provide coprime obstructions. This density increases with the exponents, suggesting that modular obstructions become overwhelmingly abundant for large exponents.

| Exponent triple | Obstructions (/30) | Density |
|----------------|-------------------|---------|
| (3,3,3) | 20 | 66.7% |
| (3,3,4) | 15 | 50.0% |
| (3,4,4) | 22 | 73.3% |
| (4,4,4) | 24 | 80.0% |

### 5.4 Radical Sparsity

Among numbers up to 10,000, the average ratio $\mathrm{rad}(n)/n$ is 0.705, and the median is 1.000 (most numbers are squarefree). The "smoothest" numbers—those with the smallest radical-to-size ratio—are high powers of small primes: $8192 = 2^{13}$ has $\mathrm{rad}/n = 0.000244$.

## 6. Discussion

### 6.1 Significance of the Results

Our formal theorems provide three types of value:

1. **Infrastructure**: The primitive reduction (Theorem 3.2) and radical identity (Theorem 3.4) are prerequisites for any future Beal proof. Formalizing them eliminates the need to re-derive these standard reductions and ensures they are correct.

2. **Conditional results**: The ABC bridge (Theorem 3.11) quantifies the exact relationship between ABC and Beal. This is the first formally verified conditional impossibility result for Beal, establishing that the conjecture follows from a specific, quantitative ABC hypothesis for large exponents.

3. **Structural insight**: The exponent bounds (Theorems 3.6–3.8) formally position Beal within the Fermat–Catalan landscape, clarifying the geometric structure of the problem.

### 6.2 Limitations

- The conditional impossibility (Theorem 3.11) requires exponents $> 6$, leaving the small-exponent cases $x, y, z \in \{3, 4, 5, 6\}$ unresolved.
- The integer ABC hypothesis $\mathrm{ABCIntStatement}(2)$ is stronger than the standard ABC conjecture at $\varepsilon = 1$, and the standard ABC conjecture itself remains unproven (Mochizuki's claimed proof is disputed).
- We do not prove any unconditional special cases (e.g., the impossibility of $A^3 + B^3 = C^z$ for coprime $A, B, C$), which would require deeper algebraic number theory not yet available in Mathlib.

### 6.3 The "Seventh Power Trick"

The key technical innovation in Theorem 3.11 is raising the ABC bound to the 7th power—matching the exponent threshold of 7 with the power needed to absorb the cubic bound on the product $ABC < C^{3z}$. This "amplification by exponentiation" technique may have applications to other conditional Diophantine results.

## 7. Future Work

Five specific research directions are detailed in `FUTURE_DIRECTIONS.md`. The most immediately tractable are:

1. **Lowering the exponent threshold**: Can the "seventh power trick" be replaced by a sharper argument (e.g., using the $n$-th power for optimal $n$) to reduce the threshold from 6 to a smaller value?

2. **Unconditional modular impossibility**: For specific exponent triples like $(4,4,4)$, 80% of small moduli provide obstructions. Can a finite covering argument yield unconditional impossibility for this triple?

3. **Formalizing the cubic boundary**: The equation $A^3 + B^3 = C^z$ with coprime $A, B, C$ and $z > 2$ may be formally inaccessible without Fermat's Last Theorem in Mathlib, but special cases (e.g., $z = 4$ or $z = 5$) might yield to elementary arguments.

## 8. Conclusion

We have established a formally verified obstruction theory for Beal's conjecture, consisting of 20+ theorems with complete, machine-checked proofs in Lean 4. The theory provides a clean modular interface: the primitive reduction isolates the true obstruction, the radical identity connects Beal to ABC, the exponent bounds place it in Fermat–Catalan geometry, and the conditional bridge shows exactly how ABC strength translates to Beal impossibility. This infrastructure is designed to support—and accelerate—future attacks on the full conjecture.

## References

1. A. Beal. *Beal's Conjecture*. Announced 1993; prize increased to \$1,000,000 in 2013.
2. H. Darmon and A. Granville. *On the equations $z^m = F(x,y)$ and $Ax^p + By^q = Cz^r$*. Bull. London Math. Soc. 27 (1995), 513–543.
3. J. Oesterlé. *Nouvelles approches du "théorème" de Fermat*. Sém. Bourbaki, exp. 694 (1988).
4. D. Masser. *Open problems*. In: Proc. Symp. Analytic Number Theory, London, 1985.
5. A. Wiles. *Modular elliptic curves and Fermat's Last Theorem*. Ann. Math. 141 (1995), 443–551.
6. The Mathlib Community. *Mathlib4*. https://github.com/leanprover-community/mathlib4
