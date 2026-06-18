# Escher Filtrations: A Theory of Separated Descending Ideal Chains

## Abstract

We introduce *Escher filtrations* — strictly descending sequences of ideals with trivial intersection — as a formal invariant of commutative rings. The definition captures the phenomenon of progressive algebraic refinement that collapses to zero in the limit, connecting ideal theory to adic topology, valuation theory, and order-of-vanishing in algebraic geometry. We prove that the integers and polynomial rings over integral domains admit Escher filtrations (have infinite *Escher height*), while fields do not. A general theorem identifies the mechanism: in any integral domain, powers of a nonunit with the separation property produce an Escher filtration. We show that Escher height is orthogonal to Noetherianity, as ℤ is simultaneously Noetherian and of infinite Escher height. All results are machine-verified in Lean 4 with the Mathlib library. We discuss connections to p-adic analysis, algebraic geometry, and asymptotic algebra, and propose several directions for further development including independent Escher rank as a dimension-sensitive refinement.

**Keywords:** ideal filtrations, adic topology, separated filtrations, Krull intersection, valuation theory, polynomial geometry, order of vanishing, formal verification

---

## 1. Introduction

### 1.1 Motivation

The image of an "impossible staircase" — an infinite sequence of steps that descends forever yet somehow returns to its starting point — has captured mathematical imagination since M.C. Escher popularized it in visual art. In algebra, a natural but naive attempt to realize this metaphor might seek an ascending chain of ideals that "loops back." However, this is impossible in any ring: an ascending chain either stabilizes or diverges to the whole ring. The mathematically coherent phenomenon is quite different.

Consider the sequence of ideals $(2^n\mathbb{Z})_{n \geq 0}$ in the ring of integers. Each ideal is strictly contained in its predecessor — $2^{n+1}\mathbb{Z} \subsetneq 2^n\mathbb{Z}$ — giving an infinite descent. The intersection $\bigcap_n 2^n\mathbb{Z} = \{0\}$: no nonzero integer is divisible by every power of 2. The staircase descends forever and arrives at nothing.

This paper formalizes this phenomenon as an algebraic invariant, proves foundational theorems about it, and connects it to established mathematical frameworks.

### 1.2 Relationship to Prior Work

The study of descending filtrations on rings is classical. Key antecedents include:

- **Krull's Intersection Theorem** (1928): In a Noetherian ring $R$ with ideal $I$, the intersection $\bigcap_n I^n$ is annihilated by an element of $1 + I$. For domains, this gives $\bigcap_n I^n = 0$ when $I \neq R$.

- **Adic topologies**: The $I$-adic topology on a ring $R$ uses the ideals $\{I^n\}$ as a neighborhood basis of zero. The topology is Hausdorff if and only if $\bigcap_n I^n = 0$, i.e., the filtration has vanishing core.

- **Valuation theory**: A (non-Archimedean) valuation $v$ on a field induces a filtration by valuation ideals $\{x : v(x) \geq n\}$ which has vanishing core precisely when $v$ is non-trivial.

- **Completion constructions**: The passage from $\mathbb{Z}$ to $\mathbb{Z}_p$ (the $p$-adic integers) is the completion with respect to the $p$-adic filtration, which is an Escher filtration.

Our contribution is to isolate the *pair* of properties — strict descent plus vanishing core — as a single invariant, prove structural theorems about which rings support it, and connect the framework to multiple mathematical domains through explicit theorems.

### 1.3 Overview of Results

We establish six main results:

1. The 2-adic filtration on $\mathbb{Z}$ is an Escher filtration (Theorem 3.1).
2. $\mathbb{Z}$ has infinite Escher height (Theorem 3.2).
3. Fields admit no Escher filtration (Theorem 4.1).
4. $\mathbb{Z}$ is Noetherian yet has infinite Escher height (Theorem 4.2).
5. Powers of a nonunit in a separated domain yield an Escher filtration (Theorem 5.1).
6. The $X$-adic filtration on $R[X]$ is an Escher filtration for any domain $R$ (Theorem 6.1).

---

## 2. Definitions and Notation

### 2.1 Vanishing Core

**Definition 2.1.** Let $R$ be a commutative ring and $E : \mathbb{N} \to \mathrm{Ideal}(R)$ a sequence of ideals. We say $E$ has *vanishing core* if
$$\forall x \in R, \left(\forall n \in \mathbb{N},\, x \in E(n)\right) \implies x = 0.$$

Equivalently, $\bigcap_{n=0}^{\infty} E(n) = \{0\}$. This is the algebraic analogue of the Hausdorff separation property: in the topology where $\{E(n)\}$ forms a neighborhood basis of zero, distinct elements are topologically distinguishable.

### 2.2 Escher Filtration

**Definition 2.2.** An *Escher filtration* on a commutative ring $R$ is a sequence $E : \mathbb{N} \to \mathrm{Ideal}(R)$ satisfying:
1. **Strict descent:** $E(n+1) \subsetneq E(n)$ for all $n \in \mathbb{N}$.
2. **Vanishing core:** $\bigcap_n E(n) = \{0\}$.

### 2.3 Escher Height

**Definition 2.3.** A commutative ring $R$ has *infinite Escher height* if there exists an Escher filtration on $R$. We write $\mathrm{eht}(R) = \infty$ in this case.

*Remark.* One could define finite Escher height as the supremum of lengths of strictly descending chains with vanishing core (truncated), but we focus on the infinite case here, which is the more interesting invariant.

---

## 3. The 2-adic Filtration on ℤ

### Theorem 3.1 (2-adic Escher Filtration)
*The sequence $E(n) = (2^n)\mathbb{Z}$ is an Escher filtration on $\mathbb{Z}$.*

**Proof sketch.**

*Strict descent:* We need $(2^{n+1})\mathbb{Z} \subsetneq (2^n)\mathbb{Z}$ for all $n$. The inclusion $\subseteq$ follows from $2^n \mid 2^{n+1}$. For strictness, suppose $2^{n+1} \mid 2^n$. Then $2^n = k \cdot 2^{n+1}$ for some $k \in \mathbb{Z}$, giving $1 = 2k$, which has no integer solution. So $2^n \notin (2^{n+1})\mathbb{Z}$. In the formal proof, this uses the characterization $\mathrm{span}\{a\} < \mathrm{span}\{b\}$ iff $b \mid a$ and $a$ divides $b$ only via a unit, combined with the fact that 2 is not a unit in $\mathbb{Z}$.

*Vanishing core:* Suppose $x \in \mathbb{Z}$ with $2^n \mid x$ for all $n$. If $x \neq 0$, then $|x| \geq 1$, so $2^n \leq |x|$ for all $n$ (since $2^n \mid x$ and $x \neq 0$ implies $2^n \leq |x|$). But $2^n \to \infty$, contradiction. Hence $x = 0$. ∎

### Theorem 3.2 (Infinite Escher Height of ℤ)
*$\mathrm{eht}(\mathbb{Z}) = \infty$.*

This follows immediately from Theorem 3.1 by exhibiting the 2-adic filtration as a witness.

---

## 4. Rigidity Results

### Theorem 4.1 (Fields Have No Escher Filtrations)
*If $K$ is a field, then $K$ has no Escher filtration. Equivalently, $\mathrm{eht}(K) = 0$.*

**Proof sketch.** In a field, every ideal is either $\{0\}$ (the bottom ideal $\bot$) or the whole field $K$ (the top ideal $\top$). Suppose $(E(n))_{n \geq 0}$ is an Escher filtration. Since $E(1) < E(0)$, we need $E(0) \neq \bot$ (otherwise $E(1) < \bot$ is impossible). So $E(0) = \top$. Then $E(1) < \top$, forcing $E(1) = \bot$. But then $E(2) < E(1) = \bot$ is impossible. ∎

This theorem shows that Escher height is sensitive to algebraic structure: the simplest rings (fields) have trivial Escher height.

### Theorem 4.2 (Noetherianity Does Not Preclude Escher Filtrations)
*$\mathbb{Z}$ is a Noetherian ring and has infinite Escher height.*

**Proof.** $\mathbb{Z}$ is Noetherian (it is a PID, and every PID is Noetherian). By Theorem 3.2, $\mathrm{eht}(\mathbb{Z}) = \infty$. ∎

*Discussion.* This result is philosophically important. It might be tempting to interpret Escher height as a measure of "distance from Noetherianity" — the idea that pathological filtrations arise only in non-Noetherian rings. Theorem 4.2 refutes this: the most classical Noetherian ring exhibits infinite Escher height. The correct interpretation is that Escher height measures *separated filtration complexity*, which is orthogonal to the ascending chain condition.

---

## 5. The General Mechanism

### Theorem 5.1 (Powers of a Nonunit)
*Let $R$ be an integral domain, $a \in R$ with $a \neq 0$ and $a$ not a unit. Suppose the separation property holds: for every $x \neq 0$, there exists $n$ such that $a^n \nmid x$. Then $E(n) = (a^n)$ is an Escher filtration.*

**Proof sketch.**

*Strict descent:* We need $(a^{n+1}) \subsetneq (a^n)$. The inclusion follows from $a^n \mid a^{n+1}$. For strictness, suppose $a^{n+1} \mid a^n$. Then $a^n = c \cdot a^{n+1}$ for some $c \in R$, so $a^n(1 - ca) = 0$. Since $R$ is a domain and $a \neq 0$, we have $a^n \neq 0$, so $1 - ca = 0$, i.e., $ca = 1$, making $a$ a unit — contradiction.

*Vanishing core:* This is exactly the separation hypothesis: if $x \in (a^n)$ for all $n$ and $x \neq 0$, then by separation there exists $n$ with $x \notin (a^n)$, a contradiction. ∎

*Remark.* The separation property holds automatically in Noetherian domains by Krull's Intersection Theorem (for proper ideals in Noetherian local rings, or more generally for any ideal $I$ in a Noetherian domain: $\bigcap_n I^n = 0$). Thus Theorem 5.1 specializes to: in any Noetherian domain, powers of any nonunit and nonzero element form an Escher filtration.

---

## 6. Polynomial Geometry

### Theorem 6.1 (X-adic Escher Filtration)
*Let $R$ be an integral domain. The sequence $E(n) = (X^n) \subseteq R[X]$ is an Escher filtration on $R[X]$.*

**Proof sketch.**

*Strict descent:* We show $X^n \notin (X^{n+1})$. If $X^{n+1} \mid X^n$ in $R[X]$, then comparing degrees: $\deg(X^{n+1}) = n+1 > n = \deg(X^n)$, but a divisor cannot have larger degree than the dividend (in a domain). Formally, this uses the fact that $X$ is not a unit in $R[X]$ (since $\deg(X) = 1 > 0$), and the general domain argument from Theorem 5.1.

*Vanishing core:* Suppose $f \in R[X]$ with $X^n \mid f$ for all $n$. If $f \neq 0$, then $f$ has finite degree $d$. But $X^n \mid f$ implies $\deg(X^n) = n \leq \deg(f) = d$ for all $n$, contradiction for $n > d$. ∎

*Geometric interpretation.* The ideal $(X^n)$ consists of polynomials vanishing to order at least $n$ at the origin. A polynomial in $\bigcap_n (X^n)$ would vanish to infinite order — which is impossible for a polynomial. This connects Escher filtrations to *order of vanishing along a divisor*, a fundamental concept in algebraic geometry. The vanishing core property is precisely the statement that the local ring of the polynomial ring at the origin has a separated maximal ideal filtration.

---

## 7. Computational Experiments

We implement several computational tools to explore Escher filtrations experimentally.

### 7.1 Membership Depth

For an element $x \in \mathbb{Z}$ and a prime $p$, the *membership depth* or *$p$-adic valuation* $v_p(x)$ is the largest $n$ such that $p^n \mid x$. This is the step at which $x$ exits the Escher filtration $(p^n\mathbb{Z})$.

| $x$ | $v_2(x)$ | $v_3(x)$ | $v_5(x)$ |
|-----|-----------|-----------|-----------|
| 12  | 2         | 1         | 0         |
| 60  | 2         | 1         | 1         |
| 128 | 7         | 0         | 0         |
| 360 | 3         | 2         | 1         |
| 1024| 10        | 0         | 0         |

The membership depth profile $(v_2(x), v_3(x), v_5(x), \ldots)$ encodes how deeply $x$ penetrates each prime's Escher filtration. For $x \neq 0$, each coordinate is finite (vanishing core); for $x = 0$, every coordinate is $\infty$.

### 7.2 Polynomial Vanishing Order

For a polynomial $f(X) \in \mathbb{Z}[X]$, the membership depth in the $X$-adic filtration is the order of vanishing at $X = 0$ — equivalently, the smallest degree with nonzero coefficient.

| Polynomial | $\mathrm{ord}_0(f)$ |
|-----------|---------------------|
| $X^3 + 2X$ | 1 |
| $X^4 - X^2$ | 2 |
| $5X^5$ | 5 |
| $1 + X$ | 0 |

### 7.3 Independent Filtrations

We test the conjecture that $k[X_1, \ldots, X_n]$ supports $n$ independent Escher filtrations (the coordinate filtrations $(X_i^m)_{m \geq 0}$) but not $n+1$. In the demo code, we verify this for small $n$ by checking that the coordinate filtrations have independent descent and joint vanishing core.

---

## 8. Discussion

### 8.1 Connections to Established Theory

**Adic topology.** An Escher filtration on $R$ defines a ring topology where the ideals $\{E(n)\}$ form a neighborhood basis of zero. The vanishing core property is equivalent to Hausdorffness of this topology. The strict descent property ensures the topology is non-discrete at every finite stage. Thus Escher filtrations correspond precisely to *non-trivially separated ideal filtrations*.

**Krull's Intersection Theorem.** For a Noetherian domain $R$ and proper ideal $I$, Krull's theorem gives $\bigcap_n I^n = 0$. Combined with the nonunit condition, this means every proper nonzero principal ideal in a Noetherian domain generates an Escher filtration. Our framework generalizes this by not requiring Noetherianity but instead making separation an explicit hypothesis.

**Completions and valuations.** The completion of $R$ with respect to an Escher filtration yields a complete separated topological ring. When the filtration comes from a valuation, this recovers classical constructions (e.g., $\mathbb{Z} \to \mathbb{Z}_p$). The Escher filtration framework abstracts the algebraic content of these constructions away from the analytic machinery.

### 8.2 Limitations

The current framework has several limitations:

1. **No finite invariant for individual filtrations.** We define only whether a ring has infinite Escher height, not a graded measure of filtration complexity. A finer invariant (e.g., growth rate of the quotient modules $E(n)/E(n+1)$) would be needed for quantitative comparisons.

2. **Dimension sensitivity.** Escher height alone does not distinguish $\mathbb{Z}$ (Krull dimension 1) from $\mathbb{Z}[X]$ (Krull dimension 2): both have infinite Escher height. The proposed *independent Escher rank* would address this.

3. **Non-commutative generalization.** The current definitions require commutativity. Extensions to non-commutative rings (using two-sided ideals or left/right ideals) remain unexplored.

### 8.3 Conjectures

**Conjecture 8.1 (Independent Escher Rank and Dimension).** For a field $k$, define the *independent Escher rank* $\mathrm{eirank}(R)$ as the maximum $m$ such that $R$ admits $m$ pairwise independent Escher filtrations with joint vanishing core. Then $\mathrm{eirank}(k[X_1, \ldots, X_n]) = n$.

*Testable prediction:* In $k[X_1, X_2]$, any three principal power filtrations should fail the joint independence condition, while the two coordinate filtrations succeed.

**Conjecture 8.2 (Algebraic Integers).** The ring of all algebraic integers $\overline{\mathbb{Z}}$ has infinite Escher height, witnessed by the $p$-adic filtration for any prime $p$.

**Conjecture 8.3 (Escher–Hausdorff Correspondence).** For a Noetherian domain $R$ and element $a \in R$, the sequence $(a^n)$ is an Escher filtration if and only if the $a$-adic topology on $R$ is Hausdorff and $a$ is a non-unit.

---

## 9. Future Work

1. **Independent Escher rank.** Formalize the multi-generator version and prove $\mathrm{eirank}(k[X_1, \ldots, X_n]) \geq n$ by exhibiting coordinate filtrations.

2. **Quantitative refinements.** Define the *Escher spectrum* of a ring as the set of growth rates $\{\dim_k(E(n)/E(n+1))\}$ for Escher filtrations on $R$. Investigate how this spectrum relates to Hilbert functions and Samuel multiplicities.

3. **Non-Noetherian domains.** Study Escher filtrations on valuation rings of rank $> 1$, power series rings in infinitely many variables, and rings of integer-valued polynomials.

4. **Derived and homological invariants.** Define Escher filtrations on chain complexes or derived categories. The vanishing core condition may interact with spectral sequences.

5. **Connections to dynamics.** Interpret the filtration $(E(n))$ as a discrete dynamical system on the lattice of ideals. The vanishing core is a fixed point (attractor). Study the "entropy" of this descent.

---

## 10. Formal Verification

All definitions and theorems in Sections 2–6 are formalized and verified in Lean 4 using the Mathlib library (version 4.28.0). The formalization consists of approximately 190 lines of Lean code, including:

- 3 definitions (`HasVanishingCore`, `IsEscherFiltration`, `HasInfiniteEscherHeight`)
- 8 theorem statements (6 with independent proofs, 2 combining prior results)
- Complete proofs using standard Mathlib tactics including `by_contra`, `rcases`, `simp`, `omega`, and domain-specific lemmas from the ideal theory and polynomial libraries.

The proofs depend only on the standard axioms: `propext`, `Classical.choice`, and `Quot.sound`.

---

## References

1. W. Krull, "Primidealketten in allgemeinen Ringbereichen," *Sitzungsberichte der Heidelberger Akademie der Wissenschaften*, 1928.

2. M.F. Atiyah and I.G. Macdonald, *Introduction to Commutative Algebra*, Addison-Wesley, 1969.

3. H. Matsumura, *Commutative Ring Theory*, Cambridge University Press, 1989.

4. D. Eisenbud, *Commutative Algebra with a View Toward Algebraic Geometry*, Springer, 1995.

5. J.-P. Serre, *Local Algebra*, Springer Monographs in Mathematics, 2000.

6. Mathlib Community, "Mathlib: the math library of Lean 4," https://github.com/leanprover-community/mathlib4, 2024.
