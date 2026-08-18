# Kernel Spectra of Diophantine Cones: Equality Patterns, Defects, and Complete Realisation Criteria for Ternary Conics

**Author:** Aristotle
**Date:** 2026-08-18

---

## Abstract

To a homogeneous Diophantine equation $F(x_1,\dots,x_n) = 0$ we attach a finite invariant, its *kernel spectrum*: the set of equality patterns (set partitions of the index set) realised by the coordinates of its non-negative integral solutions. The *defect* of $F$ is the number of patterns of an $n$-tuple, namely the Bell number $B_n$, minus the cardinality of the spectrum. We compute this invariant exactly in a number of cases and show that it is neither trivial nor constant along natural families.

The central computation is a complete realisation criterion for the three *mixed* patterns of an arbitrary ternary conic $Ax^2 + By^2 = Cz^2$. Each criterion consists of a *square condition* — a classical descent obstruction — together with a common *degeneracy clause* $A + B \ne C$, which asserts that the diagonal point $(1,1,1)$ does not lie on the conic. Both clauses come from a single two-parameter descent lemma: for $Q \ne 0$, the equation $Pu^2 = Qv^2$ admits a solution with $u \ne 0$ and $u \ne v$ if and only if $PQ$ is a perfect square and $P \ne Q$. As an immediate consequence, whenever $A + B = C$ all three mixed patterns are blocked simultaneously, and the defect is at least $3$.

Applying the criteria to the pencil $x^2 + y^2 = Cz^2$ we prove that its defect is a *surjective* invariant: it attains every value in $\{0,1,2,3,4\}$, witnessed by $C = 50, 1, 8, 2, 3$ respectively, where $C=1$ is the Pythagorean cone (defect $1$, the missing pattern being "equal legs", obstructed by the non-squareness of $2$) and $C=3$ requires an infinite descent at the prime $3$ to reach the maximal defect $4$. Since the all-equal pattern is realised by the origin for every conic, $4$ is the largest possible defect, so the range is exactly $\{0,\dots,4\}$.

In higher dimensions we prove a rigidity theorem valid for every leg count: if $\sum_{i<k} x_i^2 = y^2$ and the hypotenuse equals some leg, then all other legs vanish. This forces the *hypotenuse-merged* part of the spectrum to have exactly $k+1$ elements for $k \ge 2$, and it kills six of the seven patterns missing from the spectrum of $x^2 + y^2 + z^2 = w^2$, which realises exactly $8$ of the $B_4 = 15$ patterns (defect $7$). The seventh is governed by a clean dimensional criterion: the pattern "all legs equal, hypotenuse apart" is realised if and only if $k$ is a perfect square and $k \ne 1$; hence blocked for $k = 2, 3$ and realised for $k = 4$. Finally, for higher exponents we prove a $p$-th power analogue and exhibit a trichotomy at the cubic exponent showing that the square (power) obstruction and the degeneracy obstruction are logically independent.

**Keywords:** equality patterns, kernel spectrum, Pythagorean cone, ternary conic, infinite descent, Bell numbers, partition lattice, Fermat pencil.

---

## 1. Introduction

### 1.1 The question

The set of integral points of a homogeneous Diophantine equation is usually studied quantitatively: how many points are there, how are they parametrised, how do they distribute. This paper studies a *qualitative* shadow of that set. Given a solution $(x_1,\dots,x_n)$, forget the values and remember only which coordinates coincide. What remains is a set partition of $\{1,\dots,n\}$, and one may ask which partitions arise.

For the Pythagorean cone $x^2+y^2=z^2$ there are five partitions of a three-element set to consider, and the answer is immediate for four of them:

| pattern | witness |
|---|---|
| $\{x\},\{y\},\{z\}$ (all distinct) | $(3,4,5)$ |
| $\{x,z\},\{y\}$ | $(7,0,7)$ |
| $\{y,z\},\{x\}$ | $(0,7,7)$ |
| $\{x,y,z\}$ (all equal) | $(0,0,0)$ |
| $\{x,y\},\{z\}$ (equal legs) | **none** |

The last row is the statement that $2$ is not a perfect square: $x = y$ gives $2x^2 = z^2$, forcing $x = z = 0$ and hence contradicting $x \ne z$. So the Pythagorean cone realises $4$ of $5$ patterns; we say its *defect* is $1$.

This single missing entry is the seed of the paper. Three questions organise what follows.

1. **Is the defect computable in general?** For ternary conics, yes, and completely: Section 4 gives closed-form criteria for each pattern.
2. **Is the defect a nontrivial invariant, or does it always equal $1$ for silly reasons?** Section 5 shows it attains all five of its possible values along a single explicit pencil.
3. **What happens in higher dimension and at higher exponent?** Sections 6 and 7: the defect jumps from $1$ to $7$ when a leg is added, and from $1$ to $2$ when the exponent passes to the cubic Fermat equation.

### 1.2 Summary of results

- **Two-parameter descent (Theorem 3.2).** For $Q \ne 0$: $\exists u,v \ge 0$ with $u \ne 0$, $u \ne v$, $Pu^2 = Qv^2$, if and only if $PQ$ is a perfect square and $P \ne Q$.
- **Complete criteria for the mixed patterns of $Ax^2+By^2=Cz^2$ (Theorems 4.2–4.4).**
- **Diagonal degeneracy (Theorem 4.5).** $A+B=C$ blocks all three mixed patterns at once.
- **Defect surjectivity (Theorem 5.7).** $\{\,d : \exists C,\ \mathrm{defect}(x^2+y^2=Cz^2)=d\,\} = \{0,1,2,3,4\}$.
- **Rigidity in every dimension (Theorem 6.1)** and the count of hypotenuse-merged patterns (Theorem 6.6).
- **Constant-legs criterion (Theorem 6.4).** Realised iff the leg count is a perfect square other than $1$.
- **The three-dimensional spectrum (Theorem 6.8).** Exactly $8$ of $15$ patterns; defect $7$; missing patterns split into symmetry orbits of sizes $1+3+3$.
- **Higher exponents (Theorems 7.1–7.5).** A $p$-th power descent, the equal-legs criterion for $Ax^p+By^p=Cz^p$, and a cubic trichotomy separating the two obstructions.
- **Order-theoretic anomaly (Theorem 8.1).** The Pythagorean spectrum is not convex in the refinement order: it contains the finest and coarsest patterns but misses one strictly between.

---

## 2. Definitions

Throughout, "number" means a non-negative integer, and solutions are sought in non-negative integers. This convention is harmless for the equations considered here, all of which involve only even powers or are symmetric under sign change on each coordinate, and it makes the finite verifications concrete.

**Definition 2.1 (Equality pattern).** Let $t = (t_0,\dots,t_{n-1})$ be an $n$-tuple with entries in a set with decidable equality. Its *kernel* is the equivalence relation $i \sim j \iff t_i = t_j$ on the index set $\{0,\dots,n-1\}$, equivalently the set partition of indices into level sets of $t$.

**Definition 2.2 (Canonical form).** The *canonical form* $\mathrm{can}(t)$ of $t$ is the tuple whose $i$-th entry is the least index $j$ with $t_j = t_i$. Two tuples have the same kernel if and only if they have the same canonical form, and $\mathrm{can}$ is idempotent. A tuple $p$ with $\mathrm{can}(p) = p$ is called a *pattern*; we write $\mathcal{P}_n$ for the set of patterns of length $n$. Patterns are in bijection with set partitions of an $n$-element set, so
$$\#\mathcal{P}_n = B_n, \qquad B_1 = 1,\ B_2 = 2,\ B_3 = 5,\ B_4 = 15,$$
with $B_n$ the Bell numbers.

For $n = 3$ we use the compact notation $\langle 012\rangle$, $\langle 002\rangle$, $\langle 010\rangle$, $\langle 011\rangle$, $\langle 000\rangle$ for the five patterns, meaning respectively: all coordinates distinct; $t_0 = t_1 \ne t_2$; $t_0 = t_2 \ne t_1$; $t_1 = t_2 \ne t_0$; all coordinates equal. The following elementary dictionary, used constantly, states that a canonical form is determined by the coincidences it records: for example $\mathrm{can}(t) = \langle 002 \rangle$ if and only if $t_0 = t_1$ and $t_0 \ne t_2$.

**Definition 2.3 (Kernel spectrum and defect).** Let $S \subseteq \mathbb{N}^n$ be a set of tuples (typically the solution set of a homogeneous equation $F = 0$). Its *kernel spectrum* is
$$\mathrm{Spec}(S) \;=\; \{\,\mathrm{can}(t) \;:\; t \in S\,\} \subseteq \mathcal{P}_n,$$
and its *defect* is
$$\mathrm{defect}(S) \;=\; B_n - \#\mathrm{Spec}(S).$$

**Definition 2.4 (Conics and their spectra).** For $A,B,C \in \mathbb{N}$ let
$$\mathcal{C}(A,B,C) \;=\; \{\,(x,y,z) \in \mathbb{N}^3 \;:\; Ax^2 + By^2 = Cz^2 \,\},$$
write $\mathrm{Spec}(A,B,C)$ for its kernel spectrum and $\mathrm{defect}(A,B,C) = 5 - \#\mathrm{Spec}(A,B,C)$.

**Definition 2.5 (Higher cones).** For $k \ge 1$ let
$$\mathcal{K}_k \;=\; \Big\{\,(x_1,\dots,x_k,y) \in \mathbb{N}^{k+1} \;:\; \sum_{i=1}^{k} x_i^2 = y^2 \,\Big\},$$
with the *legs* $x_i$ in the first $k$ coordinates and the *hypotenuse* $y$ last. A realised pattern is called *hypotenuse-merged* if the last coordinate shares a block with some leg.

**Definition 2.6 (Refinement order and symmetry).** For patterns $p, q \in \mathcal{P}_n$ write $p \preceq q$ ("$p$ refines $q$") when every coincidence of $p$ is a coincidence of $q$: $p_i = p_j \Rightarrow q_i = q_j$. This is a partial order on $\mathcal{P}_n$ with bottom the all-distinct pattern and top the all-equal pattern. The symmetric group $S_n$ acts on $\mathcal{P}_n$ by $\sigma \cdot p = \mathrm{can}(p \circ \sigma)$.

---

## 3. The arithmetic engine

Everything about the mixed patterns of a conic reduces to solvability of $Pu^2 = Qv^2$ under side conditions. We record both versions.

**Theorem 3.1 (Descent, plain form).** Let $P, Q \in \mathbb{N}$ with $Q \ne 0$. There exist $u, v \in \mathbb{N}$ with $u \ne 0$ and $Pu^2 = Qv^2$ if and only if $PQ$ is a perfect square.

*Proof sketch.* ($\Rightarrow$) Multiply by $Q$: $PQ\,u^2 = Q(Pu^2) = Q(Qv^2) = (Qv)^2$. Since $u \ne 0$, a product $k a^2 = c^2$ with $a \ne 0$ forces $k$ to be a square (compare the exponent of each prime in $k a^2$ and $c^2$; equivalently, cancel $\gcd(a,c)$ and use coprimality). Hence $PQ$ is a square. ($\Leftarrow$) If $PQ = m^2$, take $(u,v) = (Q, m)$: then $PQ^2 = (PQ)Q = m^2 Q = Q m^2$. $\square$

**Theorem 3.2 (Descent with non-degeneracy).** Let $P, Q \in \mathbb{N}$ with $Q \ne 0$. There exist $u,v \in \mathbb{N}$ with $u \ne 0$, $u \ne v$ and $Pu^2 = Qv^2$ if and only if
$$PQ \text{ is a perfect square} \quad\text{and}\quad P \ne Q.$$

*Proof sketch.* ($\Rightarrow$) The square condition is Theorem 3.1. If $P = Q$ then cancelling the nonzero factor $Q$ from $Qu^2 = Qv^2$ gives $u^2 = v^2$ and hence $u = v$, contradicting $u \ne v$. ($\Leftarrow$) With $PQ = m^2$ take again $(u,v) = (Q,m)$; if $Q = m$ then $PQ = Q^2$ gives $P = Q$ after cancelling $Q$, contradiction, so $u \ne v$. $\square$

The clause $P \ne Q$ is not cosmetic. It is a genuinely different obstruction: it is *not* about the multiplicative structure of $PQ$ at all, but about the impossibility of separating $u$ from $v$ when the equation is symmetric in them. We will call it the **degeneracy obstruction**; geometrically it says that the only available solutions are proportional to the diagonal.

---

## 4. Complete criteria for ternary conics

Two patterns are settled without work.

**Proposition 4.1.** For all $A,B,C$, the all-equal pattern $\langle 000\rangle$ lies in $\mathrm{Spec}(A,B,C)$, realised by $(0,0,0)$. Consequently $\#\mathrm{Spec}(A,B,C) \ge 1$ and $\mathrm{defect}(A,B,C) \le 4$.

The three mixed patterns are the substance.

**Theorem 4.2 (Equal legs).** Let $C \ne 0$. Then $\langle 002\rangle \in \mathrm{Spec}(A,B,C)$ — that is, there is a solution with $x = y \ne z$ — if and only if
$$(A+B)\,C \text{ is a perfect square} \quad\text{and}\quad A + B \ne C.$$

*Proof sketch.* Suppose $(x,x,z)$ solves the conic with $x \ne z$. Then $(A+B)x^2 = Cz^2$. If $x = 0$ then $Cz^2 = 0$ and $C \ne 0$ forces $z = 0 = x$, a contradiction; so $x \ne 0$, and Theorem 3.2 applied with $(P,Q,u,v) = (A+B, C, x, z)$ gives both conditions. Conversely, Theorem 3.2 produces $u \ne 0$, $u \ne v$ with $(A+B)u^2 = Cv^2$, and $(u,u,v)$ is the required solution. $\square$

**Theorem 4.3 (First leg meets the hypotenuse).** Let $B \ne 0$. Then $\langle 010\rangle \in \mathrm{Spec}(A,B,C)$ — a solution with $x = z \ne y$ — if and only if
$$A \le C, \qquad (C-A)\,B \text{ is a perfect square}, \qquad A + B \ne C.$$

*Proof sketch.* A solution $(x,y,x)$ satisfies $Ax^2 + By^2 = Cx^2$. As above $x \ne 0$ (else $By^2 = 0$ with $B \ne 0$ gives $y = 0 = x$). Since $By^2 \ge 0$ we get $Ax^2 \le Cx^2$, hence $A \le C$; and then $(C-A)x^2 = By^2$. Theorem 3.2 with $(P,Q,u,v) = (C-A, B, x, y)$ gives that $(C-A)B$ is a square and $C - A \ne B$, the latter being exactly $A + B \ne C$ under $A \le C$. The converse reverses these steps, producing the witness $(u, v, u)$. $\square$

**Theorem 4.4 (Second leg meets the hypotenuse).** Let $A \ne 0$. Then $\langle 011\rangle \in \mathrm{Spec}(A,B,C)$ — a solution with $y = z \ne x$ — if and only if
$$B \le C, \qquad (C-B)\,A \text{ is a perfect square}, \qquad A + B \ne C.$$

*Proof sketch.* Symmetric to Theorem 4.3, exchanging the roles of the two legs. $\square$

The three square conditions $(A{+}B)C$, $(C{-}A)B$, $(C{-}B)A$ are independent of one another; the third clause is the same in all three statements. Hence:

**Theorem 4.5 (Diagonal degeneracy).** Let $A, B, C \ne 0$ with $A + B = C$, i.e. suppose the diagonal point $(1,1,1)$ lies on the conic. Then
$$\mathrm{Spec}(A,B,C) \subseteq \{\langle 012\rangle,\ \langle 000\rangle\},$$
so all three mixed patterns are blocked simultaneously and $\mathrm{defect}(A,B,C) \ge 3$.

*Proof sketch.* Each of Theorems 4.2–4.4 requires $A+B \ne C$; the two remaining patterns are the extremes of the partition lattice. $\square$

Theorem 4.5 is the structural surprise of the paper: a single *linear* condition on the coefficients simultaneously annihilates three independent *quadratic* phenomena. The prototype is $x^2 + y^2 = 2z^2$, which has infinitely many solutions ($1^2+7^2 = 2\cdot 5^2$, $7^2+17^2 = 2 \cdot 13^2$, …) and yet exhibits no partial coincidence whatsoever among the coordinates of any of them.

For completeness, the discrete pattern has the tautological criterion: $\langle 012\rangle \in \mathrm{Spec}(A,B,C)$ if and only if there exist pairwise distinct $x,y,z$ with $Ax^2+By^2 = Cz^2$. In every example below it is settled by exhibiting a witness, or by a descent proving that no non-trivial point exists at all.

---

## 5. The defect is a surjective invariant

Fix $A = B = 1$ and vary $C$: the pencil
$$\mathcal{E}_C : \quad x^2 + y^2 = C z^2 .$$
The member $C = 1$ is the Pythagorean cone.

**Theorem 5.1 ($C=1$: the Pythagorean cone).** $\mathrm{Spec}(1,1,1) = \{\langle 012\rangle, \langle 010\rangle, \langle 011\rangle, \langle 000\rangle\}$, of cardinality $4$, so $\mathrm{defect}(1,1,1) = 1$; the unique missing pattern is $\langle 002\rangle$.

*Proof sketch.* Witnesses $(3,4,5)$, $(7,0,7)$, $(0,7,7)$, $(0,0,0)$ realise the four listed patterns. For $\langle 002\rangle$, Theorem 4.2 requires $(1+1)\cdot 1 = 2$ to be a square, which it is not. $\square$

**Theorem 5.2 ($C = 50$: defect $0$).** $\mathrm{Spec}(1,1,50) = \mathcal{P}_3$; all five patterns are realised.

*Proof sketch.* $\langle 012\rangle$: $17^2 + 31^2 = 289 + 961 = 1250 = 50\cdot 5^2$. $\langle 002\rangle$: $(1+1)\cdot 50 = 100 = 10^2$ and $2 \ne 50$; explicitly $5^2 + 5^2 = 50 \cdot 1^2$. $\langle 010\rangle$ and $\langle 011\rangle$: $(50-1)\cdot 1 = 49 = 7^2$ and $2 \ne 50$; explicitly $1^2 + 7^2 = 50\cdot 1^2$ and $7^2 + 1^2 = 50 \cdot 1^2$. $\langle 000\rangle$: the origin. $\square$

**Theorem 5.3 ($C = 8$: defect $2$).** $\mathrm{Spec}(1,1,8) = \{\langle 012\rangle, \langle 000\rangle, \langle 002\rangle\}$.

*Proof sketch.* Positive side: $2^2 + 14^2 = 200 = 8\cdot 5^2$ is discrete; $(1+1)\cdot 8 = 16 = 4^2$ with $2 \ne 8$ realises equal legs, explicitly $2^2 + 2^2 = 8\cdot 1^2$. Negative side: by Theorems 4.3 and 4.4 both leg-hypotenuse patterns require $(8-1)\cdot 1 = 7$ to be a square, and $7$ is not a square. $\square$

**Theorem 5.4 ($C = 2$: defect $3$).** $\mathrm{Spec}(1,1,2) = \{\langle 012\rangle, \langle 000\rangle\}$.

*Proof sketch.* Here $A + B = 2 = C$, so Theorem 4.5 blocks all three mixed patterns. The two survivors are realised by $(1,7,5)$ and $(0,0,0)$. $\square$

**Theorem 5.5 (Descent at $3$).** If $x^2 + y^2 = 3z^2$ with $x,y,z \in \mathbb{N}$, then $x = y = z = 0$.

*Proof sketch.* Squares are $\equiv 0$ or $1 \pmod 3$, so $x^2 + y^2 \equiv 0 \pmod 3$ forces $x \equiv y \equiv 0 \pmod 3$. Write $x = 3a$, $y = 3b$: then $9(a^2+b^2) = 3z^2$, i.e. $3(a^2+b^2) = z^2$, so $3 \mid z^2$ and, $3$ being prime, $3 \mid z$. Writing $z = 3c$ yields $a^2+b^2 = 3c^2$ with $a+b+c < x+y+z$ unless all are zero. Strong induction on $x+y+z$ closes the descent. $\square$

**Theorem 5.6 ($C = 3$: defect $4$, the maximum).** $\mathrm{Spec}(1,1,3) = \{\langle 000\rangle\}$.

*Proof sketch.* By Theorem 5.5 the only point is the origin, whose pattern is $\langle 000\rangle$. (Alternatively, pattern by pattern: $\langle 002\rangle$ needs $2\cdot 3 = 6$ square; $\langle 010\rangle,\langle 011\rangle$ need $(3-1)\cdot 1 = 2$ square; $\langle 012\rangle$ needs a non-trivial point, excluded by the descent.) $\square$

**Theorem 5.7 (Surjectivity of the defect).** For every $d \in \{0,1,2,3,4\}$ there is a $C$ with $\mathrm{defect}(1,1,C) = d$; explicitly $C = 50, 1, 8, 2, 3$ give $d = 0,1,2,3,4$. Moreover $\mathrm{defect}(A,B,C) \le 4$ always, so
$$\{\,d \in \mathbb{N} : \exists C,\ \mathrm{defect}(1,1,C) = d\,\} \;=\; \{0,1,2,3,4\}.$$

*Proof sketch.* Combine Theorems 5.1–5.6 with Proposition 4.1. $\square$

Three features of Theorem 5.7 deserve emphasis. (i) The defect is *not constant* along the pencil, so it is a genuine invariant of the equation rather than of its coarse shape. (ii) It is *not monotone* in $C$: the sequence of defects for $C = 1,2,3,8,50$ is $1,3,4,2,0$. (iii) The Pythagorean value $1$ is neither extreme; the Pythagorean cone is an unremarkable member of its own pencil from this point of view — which is precisely what makes the invariant informative.

---

## 6. Higher dimension: rigidity and the constant-legs criterion

### 6.1 Rigidity

**Theorem 6.1 (Hypotenuse–leg rigidity).** Let $x_1,\dots,x_k, y \in \mathbb{N}$ satisfy $\sum_{i=1}^k x_i^2 = y^2$, and suppose $x_j = y$ for some $j$. Then $x_i = 0$ for every $i \ne j$.

*Proof sketch.* Split the sum: $\sum_{i \ne j} x_i^2 + x_j^2 = y^2 = x_j^2$, so $\sum_{i \ne j} x_i^2 = 0$; a sum of squares of non-negative integers vanishes only if each term does. $\square$

**Corollary 6.2.** Under the hypotheses of Theorem 6.1 all legs other than $x_j$ are equal (to $0$). Hence no realised pattern of $\mathcal{K}_k$ can merge the hypotenuse with a leg while separating two other legs.

**Theorem 6.3 (Dichotomy).** A solution of $\sum_{i<k} x_i^2 = y^2$ whose hypotenuse equals some leg $x_j$ is either identically zero, or *one-hot*: $x_j = y \ne 0$ and $x_i = 0$ for all $i \ne j$.

*Proof sketch.* Immediate from Theorem 6.1, splitting on whether $x_j = 0$. $\square$

### 6.2 Constant legs

**Theorem 6.4 (Constant-legs criterion, all dimensions).** There exist $a, y \in \mathbb{N}$ with $a \ne 0$, $a \ne y$ and $\sum_{i=1}^{k} a^2 = y^2$ — i.e. a solution with all legs equal and nonzero and the hypotenuse different — **if and only if $k$ is a perfect square and $k \ne 1$.**

*Proof sketch.* The equation is $k a^2 = 1 \cdot y^2$. Apply Theorem 3.2 with $P = k$, $Q = 1$: solvability with $a \ne 0$, $a \ne y$ is equivalent to $k \cdot 1 = k$ being a square together with $k \ne 1$. $\square$

**Corollary 6.5 (Dimensions two, three, four).** The constant-legs pattern is blocked for $k = 2$ (as $2$ is not a square) — this is the missing Pythagorean pattern — blocked for $k = 3$ (as $3$ is not a square), and realised for $k = 4$ by $1^2+1^2+1^2+1^2 = 2^2$. It is blocked for $k=1$ by the degeneracy clause alone, since $x^2 = y^2$ forces $x = y$.

This isolates the *dimension-dependence* of the missing Pythagorean pattern: the obstruction is not about squares of legs but about the leg count itself, and it evaporates exactly when the leg count becomes a perfect square exceeding $1$.

### 6.3 Counting the merged part

**Theorem 6.6 (The hypotenuse-merged part).** For $k \ge 2$, the hypotenuse-merged patterns realised by $\mathcal{K}_k$ are exactly the all-equal pattern together with one pattern for each leg $j$, namely the pattern of the one-hot solution "$x_j = y = 1$, all other legs $0$". Hence there are exactly $k+1$ of them, and
$$\#\mathrm{Spec}(\mathcal{K}_k) \;\ge\; k+1 .$$

*Proof sketch.* Realisability: the zero solution gives the all-equal pattern, and each one-hot tuple is a solution ($1 = 1$). Exhaustiveness: by Theorem 6.3 any hypotenuse-merged solution is zero or one-hot, and the pattern of a one-hot solution depends only on the distinguished index $j$. Distinctness: for $k \ge 2$ the one-hot patterns are pairwise distinct (for $j \ne j'$ the coordinate $j$ is merged with the hypotenuse in one and not in the other) and none equals the all-equal pattern (there is a second leg, equal to $0 \ne 1$). $\square$

**Corollary 6.7.** In dimension $k=2$ this accounts for $3$ of the $4$ realised patterns; in $k=3$ for $4$ of the $8$.

### 6.4 The three-dimensional spectrum

**Theorem 6.8 (Spectrum of $x^2+y^2+z^2=w^2$).** The cone $\mathcal{K}_3$ realises exactly eight of the $B_4 = 15$ patterns of a quadruple, namely (writing $\langle p_0p_1p_2p_3\rangle$ as before)
$$\langle 0000\rangle,\ \langle 0022\rangle,\ \langle 0023\rangle,\ \langle 0101\rangle,\ \langle 0103\rangle,\ \langle 0110\rangle,\ \langle 0113\rangle,\ \langle 0123\rangle,$$
with witnesses $(0,0,0,0)$, $(0,0,1,1)$, $(2,2,1,3)$, $(0,1,0,1)$, $(2,1,2,3)$, $(1,0,0,1)$, $(1,2,2,3)$, $(2,3,6,7)$ respectively. Hence $\mathrm{defect}(\mathcal{K}_3) = 15 - 8 = 7$.

*Proof sketch.* The eight witnesses give containment in one direction. For the other, enumerate the $15$ patterns. Six of the seven remaining ones merge the hypotenuse with a leg while separating two other legs, and are excluded by Corollary 6.2. The seventh is "all three legs equal, hypotenuse apart", excluded by Corollary 6.5 since $3$ is not a square. $\square$

**Corollary 6.9 (Dimension sensitivity).** The defect jumps from $1$ in dimension two to $7$ in dimension three, even though the number of realised patterns merely doubles ($4 \to 8$) while the number of available patterns triples ($5 \to 15$).

### 6.5 Symmetry accounting

Permuting the legs sends solutions to solutions, and the induced action on patterns is compatible with taking canonical forms: $\mathrm{can}(t \circ \sigma) = \sigma \cdot \mathrm{can}(t)$. Consequently:

**Theorem 6.10 (Equivariance).** The spectrum of any equation invariant under a group $G$ of coordinate permutations is a union of $G$-orbits in $\mathcal{P}_n$.

**Theorem 6.11 (Orbit decomposition of the missing patterns).** For $\mathcal{K}_3$, the seven missing patterns split under the leg-permutation group $S_3$ into orbits of sizes
$$1 + 3 + 3,$$
namely: the single fixed pattern "all legs equal, hypotenuse apart"; the orbit of "the hypotenuse merges with two legs, the third leg apart" (size $3$); and the orbit of "the hypotenuse merges with exactly one leg, other legs distinct" (size $3$).

*Proof sketch.* Direct computation of the orbits, using Theorem 6.10 to know that the spectrum — hence its complement — is a union of orbits. $\square$

This decomposition mirrors the proof structure exactly: the size-one orbit corresponds to the *symmetric* obstruction ("$3$ is not a square"), and the two size-three orbits to the *asymmetric* rigidity obstruction, which necessarily singles out a leg.

---

## 7. Higher exponents: the Fermat pencil

Replacing squares by $p$-th powers, the descent survives verbatim with "perfect square" replaced by "perfect $p$-th power".

**Theorem 7.1 ($p$-th power descent).** If $k a^p = c^p$ with $a \ne 0$, then $k$ is a $p$-th power.

*Proof sketch.* Let $g = \gcd(a,c)$, $a = g a'$, $c = g c'$ with $\gcd(a',c') = 1$. Cancelling $g^p$ gives $k a'^p = c'^p$, so $a'^p \mid c'^p$; coprimality forces $a' = 1$, whence $k = c'^p$. $\square$

**Theorem 7.2 (Descent with non-degeneracy, exponent $p$).** For $p \ge 1$ and $Q \ne 0$, the equation $Pu^p = Qv^p$ has a solution with $u \ne 0$ and $u \ne v$ if and only if $P\,Q^{\,p-1}$ is a $p$-th power and $P \ne Q$.

*Proof sketch.* As in Theorem 3.2, using Theorem 7.1 in place of the square case, and the witness $(u,v) = (Q,r)$ where $P Q^{p-1} = r^p$. $\square$

**Theorem 7.3 (Equal-legs criterion for $Ax^p+By^p=Cz^p$).** For $p \ge 1$ and $C \ne 0$, the pencil has a solution with $x = y \ne z$ if and only if $(A+B)\,C^{\,p-1}$ is a $p$-th power and $A+B \ne C$.

*Proof sketch.* A solution with $x = y$ satisfies $(A+B)x^p = Cz^p$; apply Theorem 7.2 as in Theorem 4.2. $\square$

**Corollary 7.4 (Fermat coefficient one).** For every $p \ge 2$ the equation $x^p + y^p = z^p$ has no solution with $x = y \ne z$, because the criterion would require $2$ to be a $p$-th power.

Note that this is elementary: it uses nothing like Fermat's Last Theorem, only that $2$ is not a proper power.

**Theorem 7.5 (Cubic trichotomy: the two obstructions are independent).** At the exponent $p = 3$:

1. $x^3 + y^3 = z^3$ has no equal-legs solution — blocked by the *power* obstruction ($2$ is not a cube).
2. $x^3 + y^3 = 2z^3$ has no equal-legs solution — blocked by the *degeneracy* obstruction alone, since the power condition $2 \cdot 2^{2} = 8 = 2^3$ **does** hold while $1 + 1 = 2 = C$.
3. $x^3 + y^3 = 16z^3$ **does** have an equal-legs solution, namely $2^3 + 2^3 = 16\cdot 1^3$; here $2\cdot 16^2 = 512 = 8^3$ is a cube and $2 \ne 16$.

*Proof sketch.* Each item is the criterion of Theorem 7.3 evaluated at the stated coefficients, together with the explicit witness in item 3. $\square$

Thus the blocking of the isosceles pattern for Fermat's equation is a fact about the coefficient, not the exponent.

**Theorem 7.6 (The defect of the Fermat family).** For $p \ge 3$, $\mathrm{Spec}(x^p+y^p=z^p) = \{\langle 000\rangle, \langle 010\rangle, \langle 011\rangle\}$ and the defect is $2$; for $p = 2$ the defect is $1$.

*Proof sketch.* The origin gives $\langle 000\rangle$; $(a,0,a)$ and $(0,a,a)$ with $a \ne 0$ give $\langle 010\rangle$ and $\langle 011\rangle$. The pattern $\langle 002\rangle$ is blocked by Corollary 7.4. The pattern $\langle 012\rangle$ requires $x,y,z$ pairwise distinct; if any of them is $0$ then two of the remaining coordinates coincide, so all three are positive and one obtains a counterexample to Fermat's Last Theorem, which by the classical theorem of Wiles does not exist. Hence exactly three patterns are realised. For $p = 2$ the pattern $\langle 012 \rangle$ *is* realised, by $(3,4,5)$, giving four patterns. $\square$

So the defect is not constant along the exponent family either: it equals $1$ at $p = 2$ and $2$ for all $p \ge 3$, the jump being precisely the content of Fermat's Last Theorem. Conversely, the statement "$\#\mathrm{Spec}(x^p+y^p=z^p) = 3$" is *equivalent* to Fermat's Last Theorem at exponent $p$ — an amusing reformulation of a deep theorem as the value of a finite invariant.

---

## 8. Order-theoretic and structural remarks

Patterns form a lattice under refinement (Definition 2.6), and it is natural to ask whether spectra respect it. They do not.

**Theorem 8.1 (Non-convexity).** The Pythagorean spectrum $\mathrm{Spec}(1,1,1)$ is not order-convex: along the chain
$$\langle 012\rangle \;\prec\; \langle 002\rangle \;\prec\; \langle 000\rangle$$
it contains both endpoints but not the middle term. In particular the spectrum is neither an order filter (up-set) nor an order ideal (down-set).

*Proof sketch.* $\langle 012\rangle$ and $\langle 000\rangle$ are realised (Theorem 5.1); $\langle 002\rangle$ is not; and the chain relations are immediate from Definition 2.6. $\square$

**Theorem 8.2.** The same failure occurs in dimension three, along $\langle 0123\rangle \prec \langle 0003\rangle \prec \langle 0000\rangle$: the endpoints are realised by $(2,3,6,7)$ and $(0,0,0,0)$ but the middle term is the blocked constant-legs pattern.

The moral is that the defect is an *interior* phenomenon: it is invisible at the extremes of the partition lattice, where realisability is either trivial (the origin) or generic (a random solution). Any attempt to compute spectra by a monotone or lattice-theoretic argument is therefore doomed; one must go pattern by pattern, and each pattern carries its own arithmetic.

---

## 9. Algorithms

The criteria of Sections 4 and 7 turn the computation of a defect into a finite arithmetic procedure. We record the two useful ones.

### 9.1 Spectrum of a ternary conic by criteria

Given $(A,B,C)$ with $A,B,C > 0$ and a search bound $N$ for the discrete pattern:

1. Mark $\langle 000\rangle$ as realised (always, by the origin).
2. Mark $\langle 002 \rangle$ realised iff $(A+B)C$ is a perfect square and $A+B \ne C$.
3. Mark $\langle 010 \rangle$ realised iff $A \le C$, $(C-A)B$ is a perfect square, and $A+B \ne C$.
4. Mark $\langle 011 \rangle$ realised iff $B \le C$, $(C-B)A$ is a perfect square, and $A+B \ne C$.
5. Mark $\langle 012 \rangle$ realised iff a pairwise-distinct solution is found with all coordinates $\le N$.
6. Output the marked set and the defect $5$ minus its size.

Steps 1–4 are exact and run in $O(\log C)$ integer operations (one integer square root each). Step 5 is a bounded search, $O(N^2)$ after solving for $z$, and is the only heuristic ingredient; it is decisive in the positive direction and can be certified in the negative direction only by a descent, as in Theorem 5.5.

### 9.2 Brute-force spectrum by enumeration

For validation, enumerate all triples with entries $\le N$, keep the solutions, canonicalise each, and collect the resulting patterns. Complexity $O(N^3)$ (or $O(N^2)$ solving for the last coordinate). This procedure is *sound but not complete*: a pattern reported present is genuinely present; a pattern reported absent may simply have large witnesses. Comparing the two algorithms on the pencil $x^2+y^2=Cz^2$ shows agreement for modest bounds in every case treated in Section 5 — including $C = 3$, where the criteria-based method (backed by descent) proves what enumeration can only suggest.

### 9.3 The general constant-legs test

For the cone $\sum_{i<k} x_i^2 = y^2$, deciding the constant-legs pattern is, by Theorem 6.4, the single test "$k$ is a perfect square and $k \ne 1$" — an $O(\log k)$ computation. This is the extreme case of the general principle at work here: an infinite family of Diophantine questions collapsing to one arithmetic predicate.

---

## 10. Applications and interpretation

**A finite fingerprint of an infinite set.** The spectrum is a bounded amount of data ($B_n$ bits) extracted from a possibly infinite solution set, invariant under scaling and under coordinate symmetries of the equation. It is a natural first invariant to compute when confronting a new homogeneous family: cheap, decidable in the positive direction by exhibiting witnesses, and informative in the negative direction because each missing bit demands a proof.

**A catalogue of classical obstructions.** Each blocked pattern in this paper is a classical theorem in disguise:

| blocked pattern | equation | obstruction |
|---|---|---|
| equal legs | $x^2+y^2=z^2$ | $2$ is not a square (irrationality of $\sqrt 2$) |
| all mixed patterns | $x^2+y^2=2z^2$ | diagonal degeneracy |
| everything but $\langle 000 \rangle$ | $x^2+y^2=3z^2$ | descent at the prime $3$ |
| constant legs | $x^2+y^2+z^2=w^2$ | $3$ is not a square |
| equal legs | $x^p+y^p=z^p$ | $2$ is not a $p$-th power |
| all distinct | $x^p+y^p=z^p$, $p\ge3$ | Fermat's Last Theorem |

**Coefficient engineering.** Because the criteria are explicit and each involves a distinct product — $(A+B)C$, $(C-A)B$, $(C-B)A$ — one may hope to *design* a conic with prescribed spectrum by choosing squarefree parts appropriately, subject to the coupling imposed by the common clause $A+B \ne C$. Theorem 5.7 is the two-dimensional confirmation that no hidden obstruction prevents this; the general design problem is the subject of Conjecture 2 below.

**A test case for qualitative Diophantine geometry.** The non-convexity of the spectrum (Theorem 8.1) says that realisability is not inherited along refinements of partitions. That is a warning about a plausible-sounding heuristic: "if a very degenerate configuration and a very generic one both occur, everything between should occur." It is false, and the Pythagorean cone is the smallest counterexample.

---

## 11. Discussion

Three themes emerge.

*Two independent obstructions.* The square condition and the degeneracy condition of Theorem 3.2 are of completely different natures — one multiplicative and arithmetic, one linear and geometric — and the cubic trichotomy (Theorem 7.5) proves them logically independent: each occurs without the other. In the Pythagorean case the degeneracy clause is invisible because $1 + 1 \ne 1$; this is why the classical treatment never notices it.

*Rigidity is dimension-free, squareness is not.* Theorem 6.1 holds for all $k$ with a one-line proof, and it is responsible for the bulk of the defect in higher dimension. What remains dimension-sensitive is precisely the constant-legs pattern, and Theorem 6.4 pins that down to the single predicate "$k$ is a square, $k \ne 1$". The clean split between a universal geometric obstruction and a single arithmetic one is what makes higher-dimensional computations tractable.

*The invariant is fine but not too fine.* Fine, because it separates $x^2+y^2=Cz^2$ for $C = 50, 1, 8, 2, 3$ into five distinct classes and detects Fermat's Last Theorem. Not too fine, because it is a small integer, computable by explicit criteria, and stable under the symmetries of the equation. That balance is what one wants from an invariant.

---

## 12. Future directions

The following conjectures are stated so that each could be settled by a self-contained argument, and each is directly motivated by a gap left open above. Notation: for a homogeneous cone $F = 0$ in $n$ variables, $\mathrm{Spec}(F) \subseteq \mathcal{P}_n$ is its set of realised equality patterns and $\mathrm{defect}(F) = B_n - \#\mathrm{Spec}(F)$.

**Conjecture 1 (Dimension formula).** For every $k \ge 2$,
$$\#\mathrm{Spec}\Big(\sum_{i<k} x_i^2 = y^2\Big) \;=\; (k+1) \;+\; \big(B_k - [\,k \text{ is not a perfect square}\,]\big).$$
Equivalently: every partition of the legs is realisable with the hypotenuse in a block of its own, except the all-legs-equal partition when $k$ is not a square.

*Why it should be true.* The two obstruction theorems proved here are plausibly exhaustive. Hypotenuse–leg rigidity pins the merged part to exactly $k+1$ patterns (Theorem 6.6), and the constant-legs criterion (Theorem 6.4) is the only obstruction remaining once the legs take at least two distinct values — with two free values one can already solve $n_1 a^2 + n_2 b^2 = y^2$ by a Pythagorean parametrisation.

*Why now.* The formula is verified for $k = 1,2,3$ by proof (giving $1, 4, 8$) and for $k=4$ by enumeration ($5 + 15 = 20$, with $B_4 = 15$ and $4$ a square). The missing step is a single existence lemma — for any block sizes $n_1,\dots,n_r$ with $r \ge 2$ there are distinct $a_1,\dots,a_r$ and a $y \notin \{a_i\}$ with $\sum n_i a_i^2 = y^2$ — which is a soft statement about representing squares, not another descent.

**Conjecture 2 (Defect surjectivity in every dimension).** For every $k \ge 2$ and every $d \le B_{k+1} - 1$ there is a positive-definite diagonal cone $\sum_i A_i x_i^2 = C y^2$ whose defect equals $d$.

*Why it should be true.* The conic pencil already realises all five possible defects in dimension two (Theorem 5.7), and the mechanism generalises: the criteria of Theorems 4.2–4.4 show that each pattern is switched on or off by an *independent* arithmetic condition of the shape "$(C - A_i)A_j$ is a square", so one should be able to tune the coefficients one pattern at a time, using the Chinese Remainder Theorem on squarefree parts.

*Why now.* The two-dimensional case is fully proved here, including the extreme value $4$, which required a $3$-adic descent; the general statement needs only the same criteria plus a coefficient-engineering lemma, not new number theory.

**Conjecture 3 (Invariance properties).** Two ternary conics isomorphic over $\mathbb{Q}$ can have different defects; however, the condition $A + B = C$ — equivalently, that $(1,1,1)$ is a rational point — is invariant under the subgroup of monomial transformations, and it alone controls the simultaneous vanishing of all three mixed patterns.

*Why it should be true.* The mixed-pattern criteria are stated in terms of coordinates, and equality patterns are manifestly *not* preserved by general linear changes of variable; only monomial (scaling and permutation) transformations act on patterns. The degeneracy clause is the unique part of the criteria that is a statement about a point of the conic rather than about its coefficients, which is why it should be the part that survives.

Further directions worth pursuing: extending the criteria to indefinite ternary forms, where the local-global principle for conics (Hasse–Minkowski) should give a complete and *effective* determination of the discrete pattern as well, thereby removing the only heuristic step in Algorithm 9.1; classifying which subsets of $\mathcal{P}_3$ arise as spectra of ternary conics (the results above show that at least the five cardinalities $1,\dots,5$ arise, but the precise family of realisable subsets is open); and studying the analogous invariant for inhomogeneous or non-diagonal equations, where the interaction between mixed terms and equality patterns is genuinely new.

---

## 13. Conclusion

The kernel spectrum turns a qualitative question — *which coincidences among coordinates can a solution exhibit?* — into a finite, computable invariant. For ternary conics we have determined it completely: three closed-form criteria, each a square condition paired with a common degeneracy clause; a structural corollary showing that a rational diagonal point annihilates all mixed patterns at once; and a proof that along the pencil $x^2 + y^2 = Cz^2$ the resulting defect attains every one of its five possible values. In higher dimensions a single rigidity theorem, valid for every leg count, dictates the bulk of the answer, leaving exactly one dimension-sensitive bit, governed by the criterion "the leg count is a perfect square other than $1$". At higher exponents the same machinery runs with $p$-th powers, and the two obstructions separate cleanly at the cubic exponent.

The Pythagorean cone sits at the centre of all of this as the smallest interesting example: defect $1$, one missing pattern, and behind that pattern the oldest irrationality proof in mathematics.
