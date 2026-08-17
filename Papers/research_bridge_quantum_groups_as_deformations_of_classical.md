# Quantum Groups as Deformations of Classical Groups: From $U_q(\mathfrak{sl}_2)$ to Braided Categories and the Jones Polynomial

**Author:** Aristotle
**Date:** 2026-08-17

---

## Abstract

We develop, with complete proofs, the bridge running from the $q$-deformed universal enveloping algebra $U_q(\mathfrak{sl}_2)$, through braided tensor structure, to a computable link invariant. Four groups of results are established. **(i) Deformation and degeneration.** We prove the fundamental quadratic identity $[a]_q[b]_q - [a-1]_q[b+1]_q = [b-a+1]_q$ for symmetric quantum integers, exhibit each $[m]_q$ in the denominator-free form $q^{1-m}\sum_{i<m}q^{2i}$, construct the $(n+1)$-dimensional highest-weight modules of $U_q(\mathfrak{sl}_2)$ explicitly, and show that as $q \to 1$ the deformed generators converge to the classical $\mathfrak{sl}_2$ operators — including the delicate $0/0$ Cartan quotient $(K-K^{-1})/(q-q^{-1}) \to h$ — with the limiting operators satisfying the undeformed relations. We prove centrality of the quantum Casimir, compute its spectrum $(q^{n+1}+q^{-(n+1)})/(q-q^{-1})^2$ on the $(n+1)$-dimensional module, and prove that after subtraction of the (divergent) trivial-module value it converges to the classical eigenvalue $n(n+2)/4$. We prove the higher commutator formula $EF^m - F^mE = [m]_q F^{m-1}(q^{-(m-1)}K - q^{m-1}K^{-1})/(q-q^{-1})$ and deduce the existence of singular vectors $F^{n+1}v$. On the combinatorial side we develop Gaussian binomials, prove both $q$-Pascal recursions, reflection symmetry, the $q$-binomial theorem for $q$-commuting variables, and degeneration to the classical binomial theorem. **(ii) Braiding.** From the invariance of the $q$-deformed singlet $\omega = A|01\rangle - A^{-1}|10\rangle$ under the standard coproduct (with $q = A^{-2}$) we obtain Temperley–Lieb generators with loop value $\delta = -A^2-A^{-2} = -[2]_q$, prove the Temperley–Lieb relations for explicit $8\times 8$ matrices, and prove that the Kauffman braiding $g = A\cdot 1 + A^{-1}e$ is invertible and satisfies the Yang–Baxter equation, yielding representations of the braid group $B_3$. We prove that $g$ intertwines the quantum-group action, i.e. the braiding is natural. **(iii) The invariant.** We prove the Temperley–Lieb expansion $g^n = A^n\cdot 1 + b_n e$ with the closed form $\delta b_n = (-1)^nA^{-3n} - A^n$, identify the abstract Markov trace with the quantum trace of the $R$-matrix, and derive a closed form for the bracket of the $(2,n)$ torus links; specialisations give value $1$ for the unknot, $-A^4-A^{-4}$ for the Hopf link, and $V = t + t^3 - t^4$ (with $t = A^{-4}$) for the trefoil, whence the trefoil is distinguished from the unknot. **(iv) Quantum doubles.** We prove that a binary operation satisfies the set-theoretic Yang–Baxter equation if and only if it is self-distributive, instantiate this at group conjugation to obtain a braid-group action attached to the double of a group algebra, and prove modularity for abelian anyons: nondegeneracy of a bicharacter implies invertibility of the $S$-matrix, $S S' = |A|\cdot\mathrm{Id}$.

**Keywords:** quantum group, $U_q(\mathfrak{sl}_2)$, classical limit, quantum integer, Gaussian binomial, Temperley–Lieb algebra, Yang–Baxter equation, braid group, Kauffman bracket, Jones polynomial, quantum double, modular category.

---

## 1. Introduction

A quantum group is not a group. It is a deformation of the algebra of symmetries of a group, depending on a parameter $q$, which recovers the classical object at $q = 1$ but which carries, away from that point, an extra piece of structure: a braiding. The purpose of this paper is to make each step of that sentence precise and provable, for the smallest nontrivial case $\mathfrak{g} = \mathfrak{sl}_2$, and to follow the consequences all the way to a computation that distinguishes the trefoil knot from the unknot.

The narrative has four movements.

1. **Deformation.** We present $U_q(\mathfrak{sl}_2)$ in hypothesis form — as a list of relations satisfied by four elements $E, F, K, K^{-1}$ of an associative algebra — and prove the structural facts one expects of an enveloping algebra: a central Casimir element, a family of finite-dimensional highest-weight modules, higher commutator formulas, and a deformed binomial calculus.

2. **Degeneration.** We prove that as $q \to 1$ every deformed quantity converges to its classical counterpart. The essential difficulty is that the deformed Cartan relation is a quotient of two quantities that both vanish at $q = 1$; we resolve it by a denominator-free rewriting of the quantum integers.

3. **Braiding.** We exhibit the extra structure. From the deformed singlet in $V \otimes V$ we build the Temperley–Lieb algebra, and from it the Kauffman braiding, and prove the Yang–Baxter equation. This is what makes the representation category braided.

4. **Topology.** We close braids using the quantum trace and compute the resulting invariant of the $(2,n)$ torus links in closed form.

Throughout, $k$ denotes a field (in the analytic statements, $\mathbb{R}$), and $R$ or $\mathcal{A}$ an associative unital $k$-algebra.

---

## 2. Quantum integers

### 2.1 Definition and the fundamental identity

**Definition 2.1 (Symmetric quantum integer).** For $q \in k^\times$ with $q \ne q^{-1}$ and $m \in \mathbb{Z}$ set
$$[m]_q \;=\; \frac{q^m - q^{-m}}{q - q^{-1}}.$$

Immediately $[0]_q = 0$, $[1]_q = 1$, $[-m]_q = -[m]_q$, and $[2]_q = q + q^{-1}$.

**Theorem 2.2 (Fundamental quadratic identity).** For all $a, b \in \mathbb{Z}$ and $q \in k^\times$,
$$[a]_q[b]_q - [a-1]_q[b+1]_q = [b-a+1]_q .$$

*Proof sketch.* Clear denominators. The claim is equivalent to the Laurent-polynomial identity
$$(q^a - q^{-a})(q^b - q^{-b}) - (q^{a-1}-q^{1-a})(q^{b+1}-q^{-b-1}) = (q^{b-a+1}-q^{a-b-1})(q-q^{-1}).$$
The first product is $q^{a+b} - q^{a-b} - q^{b-a} + q^{-a-b}$ and the second is $q^{a+b} - q^{a-b-2} - q^{b-a+2} + q^{-a-b}$, so the left side equals $q^{b-a+2} - q^{b-a} + q^{a-b-2} - q^{a-b}$, which is exactly the expansion of the right side. If $q = q^{-1}$ all quantum integers vanish and the identity is trivial. $\square$

Theorem 2.2 is the arithmetic engine of $\mathfrak{sl}_2$ representation theory: it is exactly the statement that the commutator of the deformed raising and lowering operators closes on a Cartan-type operator.

### 2.2 A regular form, and the limit $q\to 1$

The expression in Definition 2.1 is a $0/0$ at $q = 1$. It is nevertheless a Laurent polynomial:

**Theorem 2.3 (Denominator-free form).** For $q \ne 0$ with $q^2 \ne 1$ and $m \in \mathbb{N}$,
$$[m]_q = q^{\,1-m}\sum_{i=0}^{m-1} q^{2i}.$$

*Proof sketch.* Write $q - q^{-1} = q^{-1}(q^2-1)$ and $q^m - q^{-m} = q^{-m}\big((q^2)^m - 1\big)$. The geometric sum identity $\big(\sum_{i<m}(q^2)^i\big)(q^2-1) = (q^2)^m - 1$ converts the quotient into $q^{1-m}\sum_{i<m}q^{2i}$. $\square$

**Corollary 2.4 (Degeneration of quantum integers).** For every $m \in \mathbb{Z}$, $[m]_q \to m$ as $q \to 1$ in $\mathbb{R}$ (limit taken along $q \ne 1$).

*Proof sketch.* For $m \ge 0$ the right-hand side of Theorem 2.3 is continuous at $q=1$ with value $1^{1-m}\cdot m = m$; the two expressions agree on a punctured neighbourhood of $1$, since $q^2 - 1 \ne 0$ there. For $m < 0$ apply $[-m]_q = -[m]_q$. $\square$

---

## 3. The deformed algebra $U_q(\mathfrak{sl}_2)$

**Definition 3.1.** Let $q \in k$ with $q \ne 0$ and $q^2 \ne 1$. Elements $E, F, K, \bar K$ of a $k$-algebra $\mathcal A$ *present $U_q(\mathfrak{sl}_2)$* if
$$K\bar K = \bar K K = 1, \qquad KE = q^2\,EK, \qquad q^2\,KF = FK, \qquad EF - FE = \frac{K - \bar K}{q - q^{-1}}.$$
We write $\bar K = K^{-1}$. Note that $q^2 \ne 1$ forces $q - q^{-1} \ne 0$, so the last relation is meaningful.

The corresponding classical presentation is:

**Definition 3.2.** Elements $e,f,h$ of $\mathcal A$ *present $U(\mathfrak{sl}_2)$* if $he - eh = 2e$, $hf - fh = -2f$, $ef - fe = h$.

### 3.1 The quantum Casimir

**Definition 3.3.** $\displaystyle C_q = FE + \frac{qK + q^{-1}K^{-1}}{(q-q^{-1})^2}$.

**Theorem 3.4 (Centrality).** If $E,F,K,K^{-1}$ present $U_q(\mathfrak{sl}_2)$, then $C_q$ commutes with each of $E$, $F$ and $K$.

*Proof sketch.* From $KE = q^2EK$ one derives $EK = q^{-2}KE$ and $EK^{-1} = q^2K^{-1}E$; symmetrically $FK = q^2KF$ and $FK^{-1} = q^{-2}K^{-1}F$. For the $E$-case, expand $C_qE - EC_q$: the term $FE\cdot E - E\cdot FE$ equals $-(EF-FE)E = -\frac{1}{q-q^{-1}}(K - K^{-1})E$, while commuting $E$ through the Cartan part produces $\frac{1}{(q-q^{-1})^2}\big(q(K E - q^{-2} KE) + q^{-1}(K^{-1}E - q^{2}K^{-1}E)\big)$. The scalar coefficients are $\frac{q(1-q^{-2})}{(q-q^{-1})^2} = \frac{1}{q-q^{-1}}$ and $\frac{q^{-1}(1-q^{2})}{(q-q^{-1})^2} = \frac{-1}{q-q^{-1}}$, which cancel the commutator term exactly. The $F$-case is the mirror image; the $K$-case follows since $K$ commutes with the Cartan part and $KFE = q^{-2}\cdot q^{2}FEK = FEK$. $\square$

The classical shadow: for $e,f,h$ presenting $U(\mathfrak{sl}_2)$ and $\mathrm{char}\,k \ne 2$, the element $C = fe + \tfrac14 h^2 + \tfrac12 h$ commutes with $e$ (and, symmetrically, with $f$ and $h$).

### 3.2 Finite-dimensional modules

Fix $n \in \mathbb{N}$. On the space of coefficient sequences we define operators by their action on a highest-weight ladder $v_0, \dots, v_n$:
$$E\,v_i = [i]_q\,v_{i-1}, \qquad F\,v_i = [n-i]_q\,v_{i+1}, \qquad K\,v_i = q^{\,n-2i}v_i, \qquad K^{-1}v_i = q^{-(n-2i)}v_i.$$

**Theorem 3.5 (Existence of the $(n+1)$-dimensional module).** For every $q \ne 0$ with $q^2 \ne 1$ and every $n$, the operators above present $U_q(\mathfrak{sl}_2)$. Moreover the span of $v_0,\dots,v_n$ is invariant under all four operators.

*Proof sketch.* The relations $KE = q^2EK$, $q^2KF = FK$, $KK^{-1}=1$ are immediate from the exponents: $q^{n-2(i-1)} = q^2 q^{n-2i}$. The commutator relation is Theorem 2.2 with $a = i$, $b = n-i$:
$$[i]_q[n-i+1]_q \;-\; [n-i]_q[i+1]_q \;=\; [\,n-2i\,]_q \;=\; \frac{q^{n-2i} - q^{-(n-2i)}}{q-q^{-1}},$$
which is precisely $(K-K^{-1})/(q-q^{-1})$ acting on $v_i$. Invariance of the span holds because $E$ lowers the index (and kills $v_0$, as $[0]_q = 0$) while the coefficient $[n-i]_q$ in $F v_i$ vanishes exactly at $i = n$. $\square$

In particular the relations of Definition 3.1 are consistent: they have finite-dimensional models for every admissible $q$.

### 3.3 Higher commutators and singular vectors

**Theorem 3.6 (The $[E,F^m]$ formula).** In any presentation of $U_q(\mathfrak{sl}_2)$, for $m \ge 1$,
$$E F^{m} - F^{m}E \;=\; [m]_q\; F^{m-1}\,\frac{q^{-(m-1)}K - q^{\,m-1}K^{-1}}{q - q^{-1}} .$$

*Proof sketch.* Induct on $m$. Moving $K$ past $F^m$ costs $q^{-2m}$ and moving $K^{-1}$ past $F^m$ costs $q^{2m}$ (proved by an immediate induction from $KF = q^{-2}FK$). The inductive step then reduces to the two scalar recursions
$$[m+1]_q\,q^{\,m+2} + 1 = [m+2]_q\,q^{\,m+1}, \qquad [m+1]_q\,q^{-(m+2)} + 1 = [m+2]_q\,q^{-(m+1)},$$
each verified directly from Definition 2.1 by clearing denominators. $\square$

Written out at $m = 2$: $EF^2 - F^2E = (q+q^{-1})\,F\,(q^{-1}K - qK^{-1})/(q-q^{-1})$.

**Corollary 3.7 (Singular vectors).** Let $v$ be a highest-weight vector of weight $n$ in a module: $E\cdot v = 0$, $K\cdot v = q^n v$, $K^{-1}\cdot v = q^{-n}v$. Then $E\cdot(F^{n+1}v) = 0$.

*Proof sketch.* Apply Theorem 3.6 with $m = n+1$. The term $F^{n+1}Ev$ vanishes by hypothesis; in the remaining term the operator $q^{-n}K - q^{n}K^{-1}$ acts on $v$ by the scalar $q^{-n}q^{n} - q^{n}q^{-n} = 0$. $\square$

Thus the Verma module of highest weight $n$ contains the singular vector $F^{n+1}v$, and the quotient by the submodule it generates is the $(n+1)$-dimensional module of Theorem 3.5. The classical shadow of Theorem 3.6 is
$$e f^{m+1} - f^{m+1}e = (m+1)f^m h - m(m+1)f^m,$$
valid in any presentation of $U(\mathfrak{sl}_2)$, proved by the same induction with the quantum integers replaced by ordinary ones.

---

## 4. Degeneration: $U_q(\mathfrak{sl}_2) \to U(\mathfrak{sl}_2)$

We now make the phrase "$q$-deformation" a theorem rather than a slogan. Work over $\mathbb{R}$ and take limits along $q \to 1$, $q \ne 1$.

Define the classical operators on the same ladder: $e\,v_i = i\,v_{i-1}$, $f\,v_i = (n-i)v_{i+1}$, $h\,v_i = (n-2i)v_i$.

**Theorem 4.1 (Convergence of generators).** For every $n$ and every coefficient vector, the deformed raising and lowering operators converge entrywise to the classical ones as $q \to 1$; and the *singular Cartan quotient* converges as well:
$$\frac{K - K^{-1}}{q - q^{-1}}\;\longrightarrow\;h .$$

*Proof sketch.* Entrywise the first two statements are Corollary 2.4 applied to the coefficients $[i]_q$ and $[n-i]_q$. For the third, the quotient acts on $v_i$ by $(q^{n-2i} - q^{-(n-2i)})/(q-q^{-1}) = [\,n-2i\,]_q$, which is a $0/0$ expression only in appearance; by Corollary 2.4 it converges to $n-2i$. $\square$

**Theorem 4.2 (The limit is classical).** The limiting operators $e, f, h$ satisfy the undeformed relations $ef - fe = h$, $he - eh = 2e$, $hf - fh = -2f$.

*Proof sketch.* Direct computation on the ladder: $(ef - fe)v_i = \big[(i+1)(n-i) - (n-i+1)i\big]v_i = (n-2i)v_i$, and similarly for the other two. $\square$

Together, Theorems 4.1 and 4.2 are the precise content of "$U_q(\mathfrak{sl}_2)$ degenerates to $U(\mathfrak{sl}_2)$ as $q \to 1$" at the level of the finite-dimensional modules.

### 4.1 The Casimir spectrum and its limit

**Theorem 4.3 (Quantum Schur's lemma).** On the $(n+1)$-dimensional module, $C_q$ acts by the scalar
$$\Omega_q(n) \;=\; \frac{q^{\,n+1} + q^{-(n+1)}}{(q - q^{-1})^2},$$
independently of the weight.

*Proof sketch.* On $v_i$, $FE$ acts by $[n-i+1]_q[i]_q$ and the Cartan part by $\big(q\,q^{n-2i} + q^{-1}q^{-(n-2i)}\big)/(q-q^{-1})^2$. Clearing the denominator $(q-q^{-1})^2$, the numerator is
$$(q^{\,n-i+1} - q^{-(n-i+1)})(q^{\,i} - q^{-i}) + q^{\,n-2i+1} + q^{-(n-2i+1)},$$
whose four cross terms are $q^{n+1}, -q^{n-2i+1}, -q^{-(n-2i+1)}, q^{-(n+1)}$; the middle two cancel against the Cartan contribution, leaving $q^{n+1} + q^{-(n+1)}$, independent of $i$. $\square$

The scalar $\Omega_q(n)$ diverges as $q \to 1$ because the *normalisation* of $C_q$ does: already on the trivial module ($n = 0$) it equals $(q+q^{-1})/(q-q^{-1})^2 \to \infty$. Subtracting that constant produces a finite limit.

**Theorem 4.4 (Regular form of the shifted Casimir).** For $q \ne 0, \pm 1$,
$$\Omega_q(n) - \frac{q + q^{-1}}{(q-q^{-1})^2} \;=\; q^{\,1-n}\,\frac{\big(\sum_{i<n}q^i\big)\big(\sum_{i<n+2}q^i\big)}{(q+1)^2}.$$

*Proof sketch.* Substitute $q - q^{-1} = (q^2-1)/q$ and the geometric sums $\sum_{i<m}q^i = (q^m-1)/(q-1)$. The left side becomes $q^2\big(q^{\,n+1} + q^{-(n+1)} - q - q^{-1}\big)/(q^2-1)^2$, whose numerator factors as $q^{1-n}(q^n-1)(q^{\,n+2}-1)$. The right side becomes $q^{1-n}(q^n-1)(q^{\,n+2}-1)/\big((q-1)^2(q+1)^2\big)$, and $(q-1)^2(q+1)^2 = (q^2-1)^2$. $\square$

**Corollary 4.5 (Classical Casimir eigenvalue).** As $q \to 1$,
$$\Omega_q(n) - \frac{q+q^{-1}}{(q-q^{-1})^2} \;\longrightarrow\; \frac{n(n+2)}{4},$$
the eigenvalue of the classical Casimir $fe + \tfrac14h^2 + \tfrac12h$ on the spin-$n/2$ representation.

*Proof sketch.* The right-hand side of Theorem 4.4 is continuous at $q=1$, where it equals $1\cdot n(n+2)/2^2$. $\square$

### 4.2 Deformed combinatorics: Gaussian binomials

**Definition 4.6.** The Gaussian binomial coefficients $\binom{n}{j}_q \in k$ are defined by $\binom{n}{0}_q = 1$, $\binom{0}{j+1}_q = 0$, and the $q$-Pascal recursion
$$\binom{n+1}{j+1}_q = q^{\,n-j}\binom{n}{j}_q + \binom{n}{j+1}_q .$$

**Proposition 4.7.** $\binom{n}{j}_q = 0$ for $j > n$; $\binom{n}{n}_q = 1$; and $\binom{n}{1}_q = 1 + q + \cdots + q^{n-1}$.

**Theorem 4.8 (Second $q$-Pascal recursion and symmetry).** For all $n, j$,
$$\binom{n+1}{j+1}_q = \binom{n}{j}_q + q^{\,j+1}\binom{n}{j+1}_q, \qquad\text{and}\qquad \binom{n}{j}_q = \binom{n}{\,n-j\,}_q \ \ (j \le n).$$

*Proof sketch.* Both by induction on $n$. For the dual recursion the base case $j=0$ is the geometric-sum identity $\sum_{i<n+2}q^i = q\sum_{i<n+1}q^i + 1 = \sum_{i<n+1}q^i + q^{n+1}$; the inductive step combines the defining recursion at $(n+1, j+1)$ with the inductive hypotheses at $j$ and $j+1$, using $n-j = (n-j-1)+1$. Symmetry then follows by expanding both $\binom{n+1}{j+1}_q$ and $\binom{n+1}{n-j}_q$ via the two recursions and applying the inductive hypothesis. $\square$

**Theorem 4.9 ($q$-binomial theorem).** Let $x, y$ lie in a $k$-algebra with $yx = q\,(xy)$. Then for all $n$,
$$(x+y)^n = \sum_{j=0}^{n}\binom{n}{j}_q\; x^j y^{\,n-j}.$$

*Proof sketch.* First, $y^m x = q^m\,x y^m$ by induction. Then induct on $n$: multiplying the expansion of $(x+y)^n$ on the right by $x + y$, the $x$-term contributes $q^{\,n-j}\binom{n}{j}_q x^{j+1}y^{n-j}$ (using the commutation to move $x$ past $y^{n-j}$) and the $y$-term contributes $\binom{n}{j}_q x^jy^{n-j+1}$. Re-indexing and combining, the coefficient of $x^{j+1}y^{n-j}$ is exactly $q^{n-j}\binom{n}{j}_q + \binom{n}{j+1}_q = \binom{n+1}{j+1}_q$. $\square$

**Theorem 4.10 (Degeneration).** $\binom{n}{j}_1 = \binom{n}{j}$; each $\binom{n}{j}_q$ is a polynomial in $q$, hence continuous, and $\binom{n}{j}_q \to \binom{n}{j}$ as $q \to 1$. Consequently Theorem 4.9 collapses at $q = 1$ to the classical binomial theorem for commuting $x, y$.

**Proposition 4.11 (Bridge to the quantum group).** The balanced quantum integer is a normalised Gaussian binomial at parameter $q^2$:
$$[m]_q = q^{\,1-m}\binom{m}{1}_{q^2},$$
and since the defining relation $KE = q^2EK$ is a $q^2$-commutation, Theorem 4.9 applies verbatim inside $U_q(\mathfrak{sl}_2)$:
$$(E + K)^n = \sum_{j=0}^{n}\binom{n}{j}_{q^2}\,E^jK^{\,n-j}.$$

The deformation is thus faithful at the level of combinatorics as well as of operators: Pascal's triangle deforms, and un-deforms, together with the algebra.

---

## 5. Braiding

### 5.1 The invariant singlet

Let $V = k^2$ with basis $|0\rangle, |1\rangle$, and take the fundamental representation of $U_q(\mathfrak{sl}_2)$:
$$E = \begin{pmatrix}0&1\\0&0\end{pmatrix},\quad F = \begin{pmatrix}0&0\\1&0\end{pmatrix},\quad K = \begin{pmatrix}q&0\\0&q^{-1}\end{pmatrix}.$$

**Proposition 5.1.** For $q \ne 0$, $q^2 \ne 1$, these matrices present $U_q(\mathfrak{sl}_2)$.

Tensor products of modules use the coproduct
$$\Delta(E) = E\otimes 1 + K\otimes E,\qquad \Delta(F) = F\otimes K^{-1} + 1\otimes F,\qquad \Delta(K) = K\otimes K.$$
The asymmetry of $\Delta$ (the $K$'s) is the hallmark of the deformation; it is what makes the braiding nontrivial.

**Definition 5.2.** Let $A \in k^\times$ and set $q = A^{-2}$. The *deformed singlet* is
$$\omega = A\,|0\rangle\otimes|1\rangle \;-\; A^{-1}|1\rangle\otimes|0\rangle \;\in\; V\otimes V .$$

**Theorem 5.3 (Invariance of the singlet).** With $q = A^{-2}$,
$$\Delta(E)\,\omega = 0, \qquad \Delta(F)\,\omega = 0, \qquad \Delta(K)\,\omega = \omega .$$

*Proof sketch.* Direct computation in the four-dimensional space. For $E$: since $E|1\rangle = |0\rangle$ and $E|0\rangle = 0$, the two contributions to $\Delta(E)\omega$ are $(E\otimes1)(-A^{-1}|1\rangle\otimes|0\rangle) = -A^{-1}|0\rangle\otimes|0\rangle$ and $(K\otimes E)(A|0\rangle\otimes|1\rangle) = Aq\,|0\rangle\otimes|0\rangle$. They cancel precisely when $Aq = A^{-1}$, i.e. $q = A^{-2}$. The $F$-case is the mirror computation using $F|0\rangle = |1\rangle$ and the weight $K^{-1}|0\rangle = q^{-1}|0\rangle$, and cancels under the same substitution. The $K$-case is immediate: $\Delta(K)$ scales both $|0\rangle\otimes|1\rangle$ and $|1\rangle\otimes|0\rangle$ by $q\cdot q^{-1} = 1$. $\square$

Theorem 5.3 is the representation-theoretic origin of everything that follows: it says $V \otimes V$ contains a copy of the trivial module, hence there exist a *cup* $k \to V\otimes V$ and a *cap* $V\otimes V \to k$ commuting with the action, and their composite is an invariant endomorphism $e$ of $V\otimes V$.

### 5.2 Temperley–Lieb algebras

**Definition 5.4.** The *loop value* is $\delta = -A^2 - A^{-2}$. Elements $e_1, e_2$ of a $k$-algebra form a *Temperley–Lieb pair* if
$$e_1^2 = \delta e_1,\qquad e_2^2 = \delta e_2, \qquad e_1e_2e_1 = e_1, \qquad e_2e_1e_2 = e_2 .$$

**Proposition 5.5.** With $q = A^{-2}$, $\delta = -[2]_q$: the loop value is minus the quantum dimension of the fundamental representation.

*Proof sketch.* $[2]_q = q + q^{-1} = A^{-2} + A^{2}$. $\square$

**Theorem 5.6 (Explicit realisation).** Let $c : \{0,1\}^2 \to k$ be the cup coefficients, $c(0,1) = A$, $c(1,0) = -A^{-1}$, else $0$. On $V^{\otimes 3}$ define $8\times8$ matrices
$$(e_1)_{(p_1p_2p_3),(r_1r_2r_3)} = -\,c(p_1,p_2)\,c(r_1,r_2)\,\delta_{p_3r_3},\qquad (e_2)_{(p_1p_2p_3),(r_1r_2r_3)} = -\,\delta_{p_1r_1}\,c(p_2,p_3)\,c(r_2,r_3).$$
Then $(e_1, e_2)$ is a Temperley–Lieb pair for every $A \ne 0$.

*Proof sketch.* Each identity is a finite computation. The key scalar input is $\sum_{i,j}c(i,j)c(i,j) = A^2 + A^{-2} = -\delta$, which gives $e_i^2 = \delta e_i$; the zig-zag identities $e_1e_2e_1 = e_1$, $e_2e_1e_2 = e_2$ follow from the "cap-cup" contraction $\sum_j c(i,j)c(j,l) = -\delta_{il}$, valid because $c$ is the antisymmetric-with-weights form $A$, $-A^{-1}$. $\square$

### 5.3 The Kauffman braiding and Yang–Baxter

**Definition 5.7.** For an element $e$ with $e^2 = \delta e$ put
$$g = A\cdot 1 + A^{-1}e, \qquad \bar g = A^{-1}\cdot 1 + A\,e .$$

**Theorem 5.8 (Reidemeister II).** $g\bar g = \bar g g = 1$.

*Proof sketch.* $g\bar g = 1 + (A^2 + A^{-2})e + e^2 = 1 + (A^2+A^{-2})e + \delta e = 1$, since $\delta = -A^2 - A^{-2}$. $\square$

The computation shows the loop value is *forced*: $g$ is invertible with this inverse exactly when $\delta = -A^2 - A^{-2}$.

**Theorem 5.9 (Braid relation / Yang–Baxter equation).** For a Temperley–Lieb pair $(e_1, e_2)$ and $g_i = A + A^{-1}e_i$,
$$g_1g_2g_1 = g_2g_1g_2 .$$

*Proof sketch.* Expand the eight terms of $g_1g_2g_1$. Four of them are $A^3\cdot1$, $A\,e_2$, $A^{-1}e_1e_2$, $A^{-1}e_2e_1$; the remaining four are multiples of $e_1$, namely $A e_1 + A e_1 + A^{-1}e_1^2 + A^{-3}e_1e_2e_1$, whose coefficient is
$$2A + A^{-1}\delta + A^{-3} = 2A - A - A^{-3} + A^{-3} = A ,$$
using $e_1^2 = \delta e_1$, $e_1e_2e_1 = e_1$ and $\delta = -A^2-A^{-2}$. The resulting normal form
$$A^3\cdot 1 + A\,e_1 + A\,e_2 + A^{-1}e_1e_2 + A^{-1}e_2e_1$$
is symmetric under $e_1 \leftrightarrow e_2$, and the same expansion of $g_2g_1g_2$ (using $e_2e_1e_2 = e_2$) yields the identical expression. $\square$

**Corollary 5.10 (Braid group representations).** Let $B_3 = \langle \sigma_1,\sigma_2 \mid \sigma_1\sigma_2\sigma_1 = \sigma_2\sigma_1\sigma_2\rangle$. Every Temperley–Lieb pair determines a group homomorphism $B_3 \to R^\times$ with $\sigma_i \mapsto g_i$. In particular the $8\times8$ matrices of Theorem 5.6 give an $8$-dimensional representation of $B_3$.

*Proof sketch.* Theorem 5.8 makes each $g_i$ a unit; Theorem 5.9 verifies the unique defining relation; the universal property of the presentation does the rest. $\square$

### 5.4 Naturality of the braiding

**Theorem 5.11.** Let $e$ be the Temperley–Lieb generator on $V \otimes V$ ($(e)_{p,r} = -c(p_1,p_2)c(r_1,r_2)$) and $q = A^{-2}$. Then $e$ commutes with $\Delta(E)$, $\Delta(F)$ and $\Delta(K)$; consequently the braiding $\check R = A\cdot 1 + A^{-1}e$ is a morphism of $U_q(\mathfrak{sl}_2)$-modules.

*Proof sketch.* $e$ is (up to scale) the composition of the cap with the cup, both of which are module maps by Theorem 5.3; concretely the four commutators are verified entry by entry, the substitution $q = A^{-2}$ being exactly what is needed in each. The statement for $\check R$ then follows by linearity. $\square$

This is the property that makes the assignment "braid $\mapsto$ operator" functorial with respect to the quantum group action, and hence makes the invariant of the next section well defined on link diagrams rather than merely on algebraic expressions.

---

## 6. The invariant of the $(2,n)$ torus links

### 6.1 Powers of the braiding

**Theorem 6.1 (Temperley–Lieb expansion).** Let $e^2 = \delta e$ and $g = A + A^{-1}e$. Then for all $n \ge 0$,
$$g^n = A^n\cdot 1 + b_n\,e,$$
where $b_0 = 0$ and $b_{n+1} = A\,b_n + A^{-1}A^n + A^{-1}\delta\,b_n$.

*Proof sketch.* Induction: $g^{n+1} = (A^n + b_ne)(A + A^{-1}e) = A^{n+1} + (A^{-1}A^n + Ab_n + A^{-1}\delta b_n)e$, using $e^2 = \delta e$. $\square$

**Theorem 6.2 (Closed form).** For $A \ne 0$ and all $n$,
$$\delta\,b_n = (-1)^n A^{-3n} - A^n .$$

*Proof sketch.* Induction. Multiplying the recursion by $\delta$ and inserting the inductive hypothesis,
$$\delta b_{n+1} = (A + A^{-1}\delta)\big((-1)^nA^{-3n} - A^n\big) + A^{-1}A^n\delta .$$
Since $A + A^{-1}\delta = A + A^{-1}(-A^2 - A^{-2}) = -A^{-3}$, the first bracket contributes $(-1)^{n+1}A^{-3(n+1)} + A^{-3}A^{n}$, and $A^{n-1}\delta = -A^{n+1} - A^{n-3}$; the two spurious terms $A^{n-3}$ cancel, leaving $(-1)^{n+1}A^{-3(n+1)} - A^{n+1}$. $\square$

### 6.2 The Markov/quantum trace

Closing a two-strand braid replaces the algebra element by a number. The correct functional is the quantum trace weighted by the ribbon element.

**Definition 6.3.** On $\mathrm{End}(V\otimes V)$ with $\mu = \mathrm{diag}(-A^2, -A^{-2})$ put
$$\mathrm{qtr}(X) \;=\; \sum_{i,j\in\{0,1\}} \mu_i\mu_j\,X_{(ij),(ij)} .$$

**Theorem 6.4.** $\mathrm{qtr}(1) = \delta^2$ and $\mathrm{qtr}(e) = \delta$.

*Proof sketch.* $\mathrm{qtr}(1) = (\mu_0 + \mu_1)^2 = (-A^2-A^{-2})^2 = \delta^2$. For $e$, the diagonal entries are $e_{(ij),(ij)} = -c(i,j)^2$, so, using $\mu_0\mu_1 = (-A^2)(-A^{-2}) = 1$,
$$\mathrm{qtr}(e) = -\sum_{i,j}\mu_i\mu_j\,c(i,j)^2 = -\big(\mu_0\mu_1A^{2} + \mu_1\mu_0A^{-2}\big) = -A^2 - A^{-2} = \delta. \qquad\square$$

Diagrammatically these are the two facts one expects: the closure of the identity braid is a two-component unlink (value $\delta^2$, one factor $\delta$ per circle, relative to the normalisation of a single circle), while the closure of $e$ is a single circle.

**Definition 6.5 (Bracket and invariant).** The *Kauffman bracket of the closure of $\sigma_1^n$* — the $(2,n)$ torus link — is
$$\langle n\rangle \;=\; A^n\delta + b_n ,$$
and the writhe-corrected invariant is $V_n = (-A^{-3})^n\,\langle n\rangle$.

**Theorem 6.6 (Consistency with the $R$-matrix).** $\mathrm{qtr}(\check R^{\,n}) = \delta\cdot\langle n\rangle$, and hence
$$V_n = (-A^{-3})^n\,\frac{\mathrm{qtr}(\check R^{\,n})}{\delta}\qquad (\delta \ne 0).$$

*Proof sketch.* Apply $\mathrm{qtr}$ to Theorem 6.1 and use Theorem 6.4: $\mathrm{qtr}(g^n) = A^n\delta^2 + b_n\delta = \delta(A^n\delta + b_n)$. $\square$

Thus the abstract Markov trace used to define $\langle n\rangle$ is literally the quantum trace of the explicit $R$-matrix; the two halves of the bridge meet.

**Theorem 6.7 (Closed form of the bracket).** For $A \ne 0$,
$$\delta\,\langle n\rangle \;=\; \delta^2A^n + (-1)^nA^{-3n} - A^n .$$

*Proof sketch.* Immediate from Definition 6.5 and Theorem 6.2. $\square$

### 6.3 Unknot, Hopf link, trefoil

**Theorem 6.8 (Normalisation).** $V_1 = 1$.

*Proof sketch.* $b_1 = A^{-1}$, so $\langle 1\rangle = A\delta + A^{-1} = -A^3 - A^{-1} + A^{-1} = -A^3$, and $V_1 = (-A^{-3})(-A^3) = 1$. $\square$

**Theorem 6.9 (Hopf link).** $\langle 2\rangle = -A^4 - A^{-4}$.

**Theorem 6.10 (Trefoil).** $\langle 3\rangle = -A^5 - A^{-3} + A^{-7}$, and in the variable $t = A^{-4}$,
$$V_3 = t + t^3 - t^4 .$$

*Proof sketch.* $b_2 = A\cdot A^{-1} + A^{-1}A + A^{-1}\delta A^{-1} = 2 + A^{-2}\delta = 1 - A^{-4}$ and $\langle 2\rangle = A^2\delta + b_2 = -A^4 - 1 + 1 - A^{-4}$. Similarly $b_3 = A b_2 + A^{-1}A^2 + A^{-1}\delta b_2$, giving $\langle 3\rangle = A^3\delta + b_3 = -A^5 - A^{-3} + A^{-7}$. Multiplying by $(-A^{-3})^3 = -A^{-9}$ yields $A^{-4} + A^{-12} - A^{-16} = t + t^3 - t^4$. $\square$

**Corollary 6.11 (The trefoil is knotted).** $V_3 \ne V_1$ as functions of $A$.

*Proof sketch.* Evaluate at $A = 2$: $t = 1/16$ and $V_3 = 1/16 + 1/4096 - 1/65536 = 4111/65536 \ne 1 = V_1$. $\square$

Combined with the two algebraic Reidemeister identities (Theorem 5.8 for move II and Theorem 5.9 for move III), which show that the bracket is unchanged under the diagram moves relating equivalent links, this is the classical proof that the trefoil cannot be unknotted.

*Scope.* We take the Markov-trace formula of Definition 6.5 as the definition of the invariant of the closed braid $\sigma_1^n$; the diagrammatic verification of Reidemeister invariance in full generality is a separate, purely topological step. What is established here is the complete algebra: the exact Temperley–Lieb expansion, the closed form of the bracket for every $n$, the coincidence of the abstract trace with the quantum trace of the $R$-matrix, and the resulting separation of the trefoil from the unknot.

---

## 7. Quantum doubles and braided structure

The braiding above arose from a specific quasitriangular structure. The general mechanism — the Drinfeld quantum double — produces braidings from arbitrary Hopf algebras. We isolate two completely explicit instances of it.

### 7.1 Self-distributivity is the Yang–Baxter equation

**Definition 7.1.** A binary operation $\triangleright$ on a set $X$ is *self-distributive* if $x\triangleright(y\triangleright z) = (x\triangleright y)\triangleright(x\triangleright z)$ for all $x,y,z$.

Define $c_1, c_2 : X^3 \to X^3$ by $c_1(x,y,z) = (x\triangleright y,\,x,\,z)$ and $c_2(x,y,z) = (x,\,y\triangleright z,\,y)$.

**Theorem 7.2.** $c_1c_2c_1 = c_2c_1c_2$ **if and only if** $\triangleright$ is self-distributive.

*Proof sketch.* Both composites send $(x,y,z)$ to a triple whose second and third coordinates agree automatically; the first coordinates are $x\triangleright(y\triangleright z)$ and $(x\triangleright y)\triangleright(x\triangleright z)$ respectively. Equality of the maps is therefore exactly self-distributivity, in both directions. $\square$

**Corollary 7.3 (The double of a group is braided).** In any group $G$, conjugation $x\triangleright y = xyx^{-1}$ is self-distributive. Hence $c_1, c_2$ are commuting-free braidings; they are moreover bijections of $G^3$ (with inverses $(x,y,z)\mapsto(y, y^{-1}xy, z)$ and its analogue), and therefore define a group homomorphism
$$B_3 \longrightarrow \mathrm{Sym}(G\times G\times G), \qquad \sigma_1\mapsto c_1,\ \sigma_2\mapsto c_2 .$$

Conjugation is the canonical Yetter–Drinfeld structure on the quantum double $D(k[G])$; Corollary 7.3 is that statement made elementary.

### 7.2 Abelian anyons and modularity

Let $A$ be a finite abelian group.

**Definition 7.4.** A *bicharacter* is $\chi : A\times A \to \mathbb{C}$ with $\chi(x+y,z) = \chi(x,z)\chi(y,z)$, $\chi(x,y+z) = \chi(x,y)\chi(x,z)$, $\chi(x,0) = 1$. It is *nondegenerate* if for every $x\ne 0$ there is $y$ with $\chi(x,y)\ne 1$.

The associated *anyon braiding* acts on coefficient functions on $A^3$ by
$$(c_1f)(x,y,z) = \chi(y,x)f(y,x,z), \qquad (c_2f)(x,y,z) = \chi(z,y)f(x,z,y).$$

**Theorem 7.5 (Yang–Baxter and hexagons).** $c_1c_2c_1 = c_2c_1c_2$ for every $\chi$; and the two bilinearity axioms of Definition 7.4 are precisely the left and right hexagon identities relating braiding to fusion.

*Proof sketch.* Both triple composites multiply the same three scalars $\chi(y,x)$, $\chi(z,x)$, $\chi(z,y)$ (in different orders) and apply the same permutation of coordinates; commutativity of $\mathbb{C}$ finishes it. $\square$

**Lemma 7.6.** $\chi(0,y) = 1$ for all $y$. (From $\chi(0,y)^2 = \chi(0,y)$ and invertibility of $\chi(0,y)$, which follows from $\chi(0,y)\chi(0,-y) = \chi(0,0) = 1$.)

**Theorem 7.7 (Modularity).** Let $\chi$ be a nondegenerate bicharacter and $S_{xy} = \chi(x,y)$, $S'_{y,x'} = \chi(-x',y)$. Then
$$\sum_{y\in A}\chi(x,y)\chi(-x',y) = \begin{cases}|A|, & x = x',\\ 0, & x\ne x',\end{cases} \qquad\text{i.e.}\qquad S\,S' = |A|\cdot\mathrm{Id}.$$
In particular $S$ is invertible.

*Proof sketch.* By bilinearity the summand is $\psi(y)$ where $\psi = \chi(x-x',\,\cdot\,)$ is an additive character of $A$. Orthogonality of characters gives $\sum_y \psi(y) = |A|$ if $\psi$ is trivial and $0$ otherwise. If $x = x'$ then $\psi = \chi(0,\cdot) = 1$ by Lemma 7.6. If $x\ne x'$, nondegeneracy applied to $x - x' \ne 0$ produces $y$ with $\psi(y)\ne 1$, so $\psi$ is nontrivial. $\square$

Invertibility of the $S$-matrix is the defining property of a *modular* tensor category: no nontrivial object is transparent to the braiding. Theorem 7.7 is the abelian-group model of the nondegeneracy enjoyed by the semisimplified category of $U_q(\mathfrak{sl}_2)$-modules at a root of unity — the setting in which such categories describe topologically ordered phases of matter.

---

## 8. Algorithms

Three computations underlie everything above and are directly implementable.

**Algorithm A (Torus-link bracket by Temperley–Lieb recursion).** Given $A$ and $n$, set $\delta = -A^2 - A^{-2}$, $b \leftarrow 0$; for $i = 0, \dots, n-1$ set $b \leftarrow Ab + A^{-1}A^i + A^{-1}\delta b$. Return $\langle n\rangle = A^n\delta + b$ and $V_n = (-A^{-3})^n\langle n\rangle$. Cost: $O(n)$ field operations. Correctness is Theorems 6.1 and 6.2; the closed form $\delta b_n = (-1)^nA^{-3n} - A^n$ gives an $O(\log n)$ alternative and an independent check.

**Algorithm B (Quantum trace of the $R$-matrix).** Build the $4\times4$ matrix $e$ from the cup coefficients, form $\check R = A\cdot 1 + A^{-1}e$, compute $\check R^{\,n}$ by repeated squaring, and return $\sum_{i,j}\mu_i\mu_j(\check R^{\,n})_{(ij),(ij)}$ with $\mu = (-A^2, -A^{-2})$. Cost: $O(\log n)$ matrix multiplications of fixed size $4$. By Theorem 6.6 the output equals $\delta\langle n\rangle$; comparing it with Algorithm A is a sharp consistency test of the whole bridge.

**Algorithm C (Degeneration scan).** For a decreasing sequence $q \to 1$, tabulate $[m]_q$ against $m$, $\binom{n}{j}_q$ against $\binom{n}{j}$, and the shifted Casimir eigenvalue against $n(n+2)/4$. The first two converge linearly in $q - 1$; the third is a difference of two quantities each of size $\Theta((q-1)^{-2})$, so it is the numerically delicate one and should be evaluated through the regular form of Theorem 4.4 when $|q - 1|$ is small.

---

## 9. Discussion

**What deformation buys.** The classical algebra $U(\mathfrak{sl}_2)$ is cocommutative: the two orders of a tensor product are canonically identified, and the flip squares to the identity. The deformation breaks cocommutativity — visibly, in the asymmetric coproduct $\Delta(E) = E\otimes1 + K\otimes E$ — and the price of restoring an isomorphism $V\otimes W \cong W\otimes V$ is that the isomorphism is no longer an involution. That failure is the braiding, and the braid relation (Theorem 5.9) is the coherence condition it must satisfy. At $q = 1$ the braiding degenerates to the flip and the extra information evaporates; Theorems 4.1, 4.2, 4.10 and Corollary 4.5 confirm that nothing else is lost in that limit.

**Why $\delta = -A^2 - A^{-2}$ is not a choice.** Theorem 5.8 shows the loop value is exactly what is needed for $A + A^{-1}e$ to be invertible with the mirror-image inverse; the writhe factor $(-A^{-3})$ of Definition 6.5 is exactly what is needed to cancel the kink factor $A\delta + A^{-1} = -A^3$ that appears in Theorem 6.8. Two scalar equations, one unknown $\delta$ — and topological invariance is downstream of their simultaneous solvability. This is the sense in which the Jones polynomial is forced, once one asks for a $\mathbb{C}$-valued invariant built from a two-term skein resolution.

**The three layers of the bridge.** (a) *Algebra*: $U_q(\mathfrak{sl}_2)$ and its modules, deforming $\mathfrak{sl}_2$; (b) *Category*: the braiding $\check R$, natural by Theorem 5.11, making the module category braided; (c) *Topology*: closure by the quantum trace, producing link invariants by Theorem 6.6. Each layer is independently meaningful — layer (b) alone is what one needs for anyons, layer (c) for knot theory — but the flow of information is one-directional, and each theorem above sits at a definite place in it.

**Limitations.** The invariant here is computed for the two-strand family only, and Reidemeister invariance for general diagrams is not established: we take the trace formula as the definition of the closed-braid invariant and prove everything algebraic about it. Second, the classical-limit statements are proved at the level of the explicit finite-dimensional modules and of the structure constants (quantum integers, Gaussian binomials, Casimir eigenvalues), not as a statement about a flat family of algebras over a formal parameter. Third, the modularity statement of Theorem 7.7 concerns the abelian (pointed) case, which is a model for, but not a proof of, the corresponding statement at roots of unity for $U_q(\mathfrak{sl}_2)$.

---

## 10. Future directions

Five falsifiable conjectures suggested by the development.

**C1. Rigidity of the loop value.** Let $R$ be any algebra containing $e$ with $e^2 = \delta e$, put $g = A + A^{-1}e$, and define a Markov-style functional by $\mathrm{tr}(1) = \delta$, $\mathrm{tr}(e) = 1$. Then the writhe-normalised value $(-A^{-3})^w\,\mathrm{tr}(g^n)$ is invariant under all three Reidemeister moves **if and only if** $\delta = -A^2 - A^{-2}$; no further hypothesis on $R$ is needed. The insight is that the loop value enters only through the two scalar identities $A\delta + A^{-1} = -A^3$ (kink) and $A\cdot A^{-1} + A^{-1}A + A^{-1}\delta A^{-1} = 0$ (Reidemeister II), which are simultaneously solvable for a single $\delta$ only at $\delta = -A^2 - A^{-2}$.

**C2. Completeness of the $(2,n)$ family.** The map $n \mapsto V_n(A) = (-A^{-3})^n(A^n\delta + b_n)$ is injective on $\mathbb{N}$ for every transcendental $A$, and already injective at the single rational point $A = 2$ (where $V_1 = 1$, $V_3 = 4111/65536$, $V_5 = 1052431/268435456$, …). The closed form $\delta\langle n\rangle = \delta^2A^n + (-1)^nA^{-3n} - A^n$ makes $V_n(2)$ a sequence of rationals with denominators $2^{4n}$, so injectivity should reduce to an elementary valuation argument rather than to topology.

**C3. Unitarity at roots of unity.** For $A = e^{i\theta}$, the $8$-dimensional Temperley–Lieb braid representation of $B_3$ is unitarisable exactly on the Jones interval of $\theta$ — that is, exactly when $|\delta| \le 2$ — with the invariant Hermitian form degenerating at the endpoints. This is the algebraic gateway to the root-of-unity truncation and to the Jones representations relevant to topological quantum computation.

**C4. A quantitative classical limit.** The convergence statements of §4 should admit uniform error bounds: e.g. $\big|[m]_q - m\big| \le C_m|q-1|$ and $\big|\Omega_q(n) - (q+q^{-1})/(q-q^{-1})^2 - n(n+2)/4\big| \le C_n|q-1|$ with explicit constants, giving a genuine first-order deformation theory rather than a bare limit.

**C5. Modularity beyond the pointed case.** Theorem 7.7 characterises modularity of the abelian double by nondegeneracy of the bicharacter. The conjecture is that the same two-line orthogonality argument, applied to the characters of the Grothendieck ring, yields invertibility of the $S$-matrix for the double of any finite group, with $|A|$ replaced by $|G|^2$ divided by the appropriate centraliser orders.

---

## 11. Conclusion

Bending a symmetry algebra by a single parameter has three consequences, each proved above. First, nothing is lost: quantum integers, Gaussian binomials, finite-dimensional modules and Casimir eigenvalues all converge to their classical counterparts as $q \to 1$, including the singular Cartan quotient which is a $0/0$ expression with a perfectly regular limit. Second, something is gained: the deformation supports an invariant, non-involutive exchange operator satisfying the Yang–Baxter equation, and hence representations of braid groups. Third, the gain is computable: closing two-strand braids with the quantum trace yields the exact bracket of every $(2,n)$ torus link, correctly normalised on the unknot, and yielding $t + t^3 - t^4$ for the trefoil — a number, $4111/65536$ at $t = 1/16$, that certifies a piece of string cannot be untied.
