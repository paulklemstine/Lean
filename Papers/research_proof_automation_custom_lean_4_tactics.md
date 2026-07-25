# Sound Small-Scale Automation for Min-Plus Algebra, Primality, and Spectral Bounds

**Aristotle**  
**July 25, 2026**

## Abstract

This paper develops three self-contained, theorem-driven procedures for recurring mathematical tasks. The first normalizes a useful class of min-plus expressions using distributivity, idempotence, associativity, and neutral-element rules. The second decides concrete primality statements by exhaustive trial division and proves that the Boolean result is equivalent to the standard definition of a prime natural number. The third derives bounds for real eigenvalues of finite real matrices from absolute row sums by selecting a maximal coordinate of a nonzero eigenvector. Each procedure is accompanied by a complete mathematical specification, a soundness argument, representative consequences, an algorithmic description, complexity analysis, and applications. The results include two-sided tropical distributivity, three-way distribution and absorption; a correct primality decision method certifying that $97$ is prime and $91$ is composite; and the interval estimate $-B\le\lambda\le B$ whenever every absolute row sum is at most $B$ and $\lambda$ is a real eigenvalue. Together these examples illustrate a general methodology: computational steps should be organized around small theorems that expose exactly why each output is valid.

## 1. Introduction

Many mathematical arguments contain routine subproblems that are easy in principle yet repetitive in practice. Three examples arise in notably different fields.

1. In tropical or min-plus algebra, nested uses of minimum and addition must be expanded and simplified.
2. In elementary number theory, concrete natural numbers must be classified as prime or composite.
3. In linear algebra, eigenvalues must often be bounded even when exact spectral computation is unnecessary.

A common response is to apply a specialized procedure. Such a procedure is most useful when its mathematical contract is explicit: the input domain is defined, the output has a precise interpretation, and a theorem proves that the operational test agrees with that interpretation.

The present work studies three deliberately small procedures. Their scope is modest enough that their soundness arguments can be understood from first principles. The min-plus procedure uses a finite rewrite basis. The primality procedure searches every potential proper divisor below the input. The spectral procedure reduces an eigenvalue estimate to a uniform row-sum inequality. None is intended as the final word in its field. Rather, they serve as clean instances of theorem-oriented algorithm design.

The paper is organized as follows. Section 2 fixes notation and states the design principle. Section 3 develops min-plus simplification. Section 4 proves the correctness of exhaustive primality testing. Section 5 establishes the absolute row-sum spectral bound. Section 6 presents algorithms and complexity. Section 7 gives examples and applications. Section 8 discusses limitations and composability, and Section 9 identifies future extensions.

## 2. Preliminaries and methodology

### 2.1. Basic notation

The natural numbers are denoted by $\mathbb N$ and the real numbers by $\mathbb R$. For $x\in\mathbb R$, its absolute value is $|x|$. If $d,n\in\mathbb N$, then $d\mid n$ means that $d$ divides $n$.

For a positive integer $n$, an $n\times n$ real matrix is written $A=(A_{ij})$. A vector $v\in\mathbb R^n$ has coordinates $v_i$. The matrix-vector product has coordinates

$$
(Av)_i=\sum_{j=1}^{n}A_{ij}v_j.
$$

A real number $\lambda$ is a real eigenvalue of $A$ if there exists a nonzero vector $v\in\mathbb R^n$ such that $Av=\lambda v$.

### 2.2. The theorem-oriented procedure

Each procedure below has three layers.

* A **semantic layer** defines the mathematical objects and desired proposition.
* A **computational layer** performs finite rewriting, search, or summation.
* A **soundness layer** proves that the computational output implies, and where appropriate is equivalent to, the semantic proposition.

This separation prevents accidental overstatement. For example, a row-sum computation does not claim to produce an eigenvalue; it produces an upper bound conditional on the eigenvalue equation. Likewise, the primality procedure does not infer primality from a few failed divisions; it exhausts the stated range and uses a theorem identifying that exhaustion with primality.

## 3. Min-plus simplification

### 3.1. Definitions

**Definition 3.1 (Min-plus operations).** For $a,b\in\mathbb R$, define tropical addition $\oplus$ and tropical multiplication $\otimes$ by

$$
a\oplus b=\min(a,b),\qquad a\otimes b=a+b.
$$

The use of $\mathbb R$ keeps the presentation elementary. The same basic identities hold in many linearly ordered additive structures.

Tropical addition is commutative, associative, and idempotent because minimum has those properties. Tropical multiplication is commutative and associative because ordinary addition has those properties. The interaction between the two operations is distributive.

### 3.2. Certified rewrite basis

**Theorem 3.2 (Left tropical distributivity).** For all $a,b,c\in\mathbb R$,

$$
a\otimes(b\oplus c)=(a\otimes b)\oplus(a\otimes c).
$$

**Proof sketch.** Expanding the definitions reduces the assertion to

$$
a+\min(b,c)=\min(a+b,a+c).
$$

If $b\le c$, both sides equal $a+b$; if $c\le b$, both sides equal $a+c$. Equivalently, translation by $a$ is order-preserving. $\square$

**Theorem 3.3 (Right tropical distributivity).** For all $a,b,c\in\mathbb R$,

$$
(a\oplus b)\otimes c=(a\otimes c)\oplus(b\otimes c).
$$

**Proof sketch.** Commute the ordinary sum to write $(a\oplus b)\otimes c=c\otimes(a\oplus b)$, apply left distributivity, and commute each resulting sum. $\square$

**Lemma 3.4 (Tropical idempotence).** For every $a\in\mathbb R$,

$$
a\oplus a=a.
$$

**Proof sketch.** This is the identity $\min(a,a)=a$. $\square$

Theorems 3.2 and 3.3 together with Lemma 3.4 constitute the central rewrite basis. The ordinary identities $a+0=0+a=a$ and the associativity of minimum supplement the basis when expressions are normalized.

**Corollary 3.5 (Soundness of the rewrite basis).** Every replacement of a subexpression by the opposite side of one of the following identities preserves its real value:

$$
\begin{aligned}
a\otimes(b\oplus c)&=(a\otimes b)\oplus(a\otimes c),\\
(a\oplus b)\otimes c&=(a\otimes c)\oplus(b\otimes c),\\
a\oplus a&=a,\\
a\otimes0&=a,\qquad 0\otimes a=a.
\end{aligned}
$$

**Proof sketch.** The first three equations are Theorems 3.2, 3.3 and Lemma 3.4. The last two expand to the ordinary additive neutral-element laws. Replacing equal subexpressions within a larger expression preserves equality. $\square$

### 3.3. Recursive examples

**Theorem 3.6 (Three-way tropical distribution).** For all $a,b,c,d\in\mathbb R$,

$$
a\otimes\bigl((b\oplus c)\oplus d\bigr)
=(a\otimes b)\oplus\bigl((a\otimes c)\oplus(a\otimes d)\bigr).
$$

**Proof sketch.** Apply left distributivity to the outer choice:

$$
a\otimes((b\oplus c)\oplus d)
=(a\otimes(b\oplus c))\oplus(a\otimes d).
$$

Apply left distributivity again to $a\otimes(b\oplus c)$, then reassociate minimum. $\square$

**Theorem 3.7 (Tropical absorption after common-factor distribution).** For all $a,b\in\mathbb R$,

$$
(a\otimes b)\oplus\bigl(a\otimes(b\oplus b)\bigr)=a\otimes b.
$$

**Proof sketch.** By idempotence, $b\oplus b=b$. Hence the left-hand side becomes $(a\otimes b)\oplus(a\otimes b)$, which equals $a\otimes b$ by idempotence once more. One may alternatively distribute the common factor first and remove duplicate minima. $\square$

### 3.4. Scope of normalization

The rewrite system soundly expands tropical products over finite minima and removes immediate duplication and neutral additions. Soundness means that every produced equality is valid. It does not by itself imply that every pair of equivalent min-plus expressions is reduced to a unique canonical string. Full decision procedures for min-plus polynomials require a richer syntax, careful treatment of dominated monomials, and a uniqueness theorem for normal forms.

## 4. Reflected trial division for primality

### 4.1. Definitions

**Definition 4.1 (Proper divisor in the trial range).** For $n\in\mathbb N$, a number $d$ is a proper trial divisor of $n$ if

$$
2\le d<n\quad\text{and}\quad d\mid n.
$$

**Definition 4.2 (Proper-divisor search).** The proper-divisor search for $n$ inspects each $d\in\{0,1,\ldots,n-1\}$ and returns true exactly when at least one inspected $d$ satisfies $2\le d$ and $d\mid n$.

The inclusion of $0$ and $1$ in the enumerated list is harmless because the predicate explicitly requires $2\le d$.

**Definition 4.3 (Exhaustive trial-primality test).** The trial-primality test returns true exactly when $2\le n$ and the proper-divisor search for $n$ returns false.

**Definition 4.4 (Prime natural number).** A natural number $n$ is prime if $2\le n$ and every divisor $m$ with $2\le m<n$ fails to divide $n$.

This bounded-divisor formulation is equivalent to the usual assertion that the positive divisors are exactly $1$ and $n$.

### 4.2. Search semantics

**Lemma 4.5 (Proper-divisor search characterization).** For every $n\in\mathbb N$, the proper-divisor search returns true if and only if there exists $d\in\mathbb N$ such that

$$
2\le d<n\quad\text{and}\quad d\mid n.
$$

**Proof sketch.** A finite existential search returns true precisely when one member of its enumerated list satisfies its predicate. Membership in the list $\{0,1,\ldots,n-1\}$ is equivalent to $d<n$. Combining this with the two predicate clauses yields the displayed existential statement. The reverse direction inserts any witness $d$ into the list and observes that its predicate evaluates to true. $\square$

### 4.3. Correctness theorem

**Theorem 4.6 (Correctness of exhaustive trial primality).** For every $n\in\mathbb N$, the trial-primality test returns true if and only if $n$ is prime.

**Proof sketch.** Suppose first that the test returns true. Then $2\le n$, and the proper-divisor search returns false. If a number $m$ satisfied $2\le m<n$ and $m\mid n$, Lemma 4.5 would force the search to return true, a contradiction. Thus $n$ is prime by Definition 4.4.

Conversely, suppose $n$ is prime. Then $2\le n$. If the proper-divisor search returned true, Lemma 4.5 would supply $m$ with $2\le m<n$ and $m\mid n$, contradicting primality. The search therefore returns false, so the trial-primality test returns true. $\square$

**Corollary 4.7 (Certificate for $97$).** The number $97$ is prime.

**Proof sketch.** Evaluate the exhaustive trial-primality test at $97$. No integer $d$ with $2\le d<97$ divides $97$, so the test returns true. Theorem 4.6 transfers this result to primality. A shorter hand calculation need only test through $\lfloor\sqrt{97}\rfloor=9$, but the present procedure deliberately uses the full certified range. $\square$

**Corollary 4.8 (Certificate for $91$).** The number $91$ is not prime.

**Proof sketch.** The proper divisor $7$ satisfies $2\le7<91$ and $7\mid91$, since $91=7\cdot13$. By Lemma 4.5 the divisor search succeeds, so the trial-primality test returns false. Theorem 4.6 implies that $91$ is not prime. $\square$

**Corollary 4.9 (Distinctness).** The natural numbers $97$ and $91$ are distinct.

**Proof sketch.** If they were equal, primality of $97$ would imply primality of $91$, contradicting Corollary 4.8. $\square$

### 4.4. Positive and negative certificates

The procedure highlights an asymmetry. Compositeness admits a short witness: one proper divisor. Primality under exhaustive trial division is certified by the absence of witnesses throughout a finite range. The correctness theorem makes both outcomes meaningful. For small inputs, the directness of the evidence is often more valuable than asymptotic efficiency.

## 5. Absolute row-sum spectral estimates

### 5.1. Definitions

Let $A\in\mathbb R^{n\times n}$. For row $i$, define the absolute row sum

$$
r_i(A)=\sum_{j=1}^{n}|A_{ij}|.
$$

Define the maximum absolute row sum, also known as the induced infinity norm, by

$$
\|A\|_\infty=\max_{1\le i\le n}r_i(A).
$$

The goal is to bound real eigenvalues using these quantities.

### 5.2. A maximal coordinate

**Lemma 5.1 (Existence of a positive maximal coordinate).** Let $v\in\mathbb R^n$ be nonzero. Then there exists an index $i_0$ such that

$$
0<|v_{i_0}|
\quad\text{and}\quad
|v_i|\le|v_{i_0}|\ \text{for every }i.
$$

**Proof sketch.** The finite set $\{|v_1|,\ldots,|v_n|\}$ has a maximum. Choose $i_0$ attaining it. If $|v_{i_0}|=0$, maximality and nonnegativity imply $|v_i|=0$ for every $i$, hence $v=0$, contrary to hypothesis. $\square$

The positivity clause is essential because the final argument divides by $|v_{i_0}|$.

### 5.3. A witnessing row

**Theorem 5.2 (A row bounds a real eigenvalue).** Let $A\in\mathbb R^{n\times n}$, let $\lambda\in\mathbb R$, and let $v\in\mathbb R^n$ be nonzero with $Av=\lambda v$. Then there exists a row $i$ such that

$$
|\lambda|\le r_i(A)=\sum_{j=1}^{n}|A_{ij}|.
$$

**Proof sketch.** Choose $i_0$ from Lemma 5.1. The $i_0$-th coordinate of $Av=\lambda v$ gives

$$
\lambda v_{i_0}=\sum_{j=1}^{n}A_{i_0j}v_j.
$$

The triangle inequality and multiplicativity of absolute value yield

$$
|\lambda|\,|v_{i_0}|
\le\sum_{j=1}^{n}|A_{i_0j}|\,|v_j|.
$$

By maximality, $|v_j|\le|v_{i_0}|$ for every $j$. Since each $|A_{i_0j}|$ is nonnegative,

$$
\sum_{j=1}^{n}|A_{i_0j}|\,|v_j|
\le\sum_{j=1}^{n}|A_{i_0j}|\,|v_{i_0}|
=r_{i_0}(A)|v_{i_0}|.
$$

Thus $|\lambda||v_{i_0}|\le r_{i_0}(A)|v_{i_0}|$. Because $|v_{i_0}|>0$, cancellation gives $|\lambda|\le r_{i_0}(A)$. $\square$

### 5.4. Uniform and interval forms

**Theorem 5.3 (Uniform absolute row-sum bound).** Under the hypotheses of Theorem 5.2, suppose additionally that a real number $B$ satisfies

$$
r_i(A)\le B\quad\text{for every row }i.
$$

Then

$$
|\lambda|\le B.
$$

**Proof sketch.** Theorem 5.2 supplies a row $i$ with $|\lambda|\le r_i(A)$. The uniform hypothesis gives $r_i(A)\le B$. Transitivity proves the claim. $\square$

**Corollary 5.4 (Symmetric interval estimate).** Under the hypotheses of Theorem 5.3,

$$
-B\le\lambda\le B.
$$

**Proof sketch.** For real numbers, $|\lambda|\le B$ is equivalent to the conjunction $-B\le\lambda$ and $\lambda\le B$. $\square$

The theorem concerns real eigenvalues and real eigenvectors. For a real symmetric matrix every eigenvalue is real, so the interval contains the entire spectrum. A complex generalization is natural but requires complex absolute values and a corresponding finite-dimensional argument.

## 6. Algorithms and computational complexity

### 6.1. Min-plus rewrite normalization

The input is an expression tree whose internal nodes are $\oplus$ and $\otimes$ and whose leaves are real constants or variables. The procedure recursively visits subexpressions, distributes a tropical product over a tropical sum when one matches the rewrite basis, removes repeated operands of a minimum, removes additive zeros, and reassociates nested minima into a chosen orientation.

Every rewrite is value-preserving by Corollary 3.5. If the procedure merely traverses and simplifies without aggressive distribution, its running time is linear in the expression-tree size. Full distribution can cause exponential output growth, exactly as expansion of ordinary products of sums can. Thus complexity is best measured relative to the produced normal expression: the traversal overhead is linear in input plus output size.

### 6.2. Exhaustive trial-primality decision

For input $n$, reject immediately if $n<2$. Otherwise loop over $d=2,3,\ldots,n-1$. If $n$ modulo $d$ is zero, return composite with witness $d$. If the loop ends, return prime.

The algorithm performs at most $n-2$ divisibility tests, hence $O(n)$ tests and $O(1)$ auxiliary storage beyond the output witness. Bit complexity depends on the cost of division on $O(\log n)$-bit integers. The full-range search mirrors Theorem 4.6 exactly. A standard optimization tests only through $\lfloor\sqrt n\rfloor$, but its use requires the complementary-factor lemma: if $n$ is composite, one factor is at most $\sqrt n$.

### 6.3. Absolute row-sum spectral certificate

For an $n\times n$ matrix, compute $r_i(A)$ for every row and return

$$
B=\max_i r_i(A).
$$

Then every real eigenvalue lies in $[-B,B]$. For a dense matrix this requires $n^2$ absolute values and approximately $n(n-1)$ additions, so the arithmetic complexity is $O(n^2)$ and the auxiliary memory can be $O(1)$ if rows are streamed. For a sparse matrix with $m$ nonzero entries, the computation is $O(m+n)$.

The certificate consists of the displayed row sums and their maximum. It does not require computing an eigenvector or eigenvalue. If a claimed eigenpair is available, Theorem 5.2 also identifies the conceptual witnessing row: choose a coordinate where the eigenvector has maximal magnitude.

## 7. Numerical examples and applications

### 7.1. Shortest-path and scheduling arithmetic

Suppose a common initial stage costs $4$, followed by one of three alternatives costing $7$, $2$, and $5$. Tropical evaluation before distribution gives

$$
4\otimes((7\oplus2)\oplus5)=4+\min(\min(7,2),5)=6.
$$

After distribution,

$$
(4+7)\oplus((4+2)\oplus(4+5))=11\oplus(6\oplus9)=6.
$$

The equality expresses a basic dynamic-programming principle: a common prefix cost may be moved across a choice without changing the optimal total.

The absorption theorem models duplicate alternatives. If two branches have the same downstream cost $b$, retaining both does not change the minimum. Such simplifications appear in shortest-path recurrences, discrete-event systems, scheduling, and certain optimization problems.

### 7.2. Concrete number classification

For $n=97$, the exhaustive procedure checks all $d$ from $2$ to $96$. None has zero remainder, so $97$ is prime. For $n=91$, the search stops at $d=7$ because $91\bmod7=0$, producing the factorization witness $91=7\cdot13$.

The procedure can be used pedagogically because the output has an immediate logical interpretation. A composite report includes a divisor. A prime report asserts that every candidate in a stated finite interval was rejected, and Theorem 4.6 explains why this interval is sufficient under the adopted definition.

### 7.3. Matrix stability screening

Consider the symmetric tridiagonal matrix

$$
A=\begin{pmatrix}
2&-1&0\\
-1&2&-1\\
0&-1&2
\end{pmatrix}.
$$

Its absolute row sums are $3$, $4$, and $3$. Therefore every real eigenvalue lies in $[-4,4]$. Since $A$ is symmetric, all its eigenvalues are real, so the entire spectrum is enclosed. In fact the eigenvalues are approximately $0.586$, $2$, and $3.414$.

For a discrete-time iteration $x_{k+1}=Ax_k$, a row-sum bound below $1$ would guarantee that every real eigenvalue has magnitude below $1$. For general real matrices, complex eigenvalues also matter for stability; extending the theorem to complex eigenvalues recovers the familiar spectral-radius estimate $\rho(A)\le\|A\|_\infty$. Even in its real form, the result provides an inexpensive screening test and is exact for some matrices, including diagonal matrices and matrices whose dominant eigenvector aligns with the inequality chain.

## 8. Discussion

### 8.1. What soundness supplies

The central benefit of each soundness theorem is a clear boundary between calculation and interpretation.

* A tropical simplification is justified because every rewrite relates equal real-valued expressions.
* A primality result is justified because the Boolean search is equivalent to the quantified divisor definition.
* A spectral bound is justified because the eigenvalue equation, triangle inequality, maximal coordinate, and row bound compose into a short chain.

This organization makes procedures auditable and composable. If a larger argument requires a tropical identity, a small primality fact, or a real eigenvalue estimate, it can consume the result through the corresponding theorem without repeating low-level work.

### 8.2. Limitations

The tropical procedure is a rewrite simplifier, not yet a complete equivalence decision method. Different rewrite orders may produce syntactically different but equal expressions, and expansion may increase size dramatically.

Exhaustive trial division is appropriate only for small concrete inputs. Its linear number of divisor tests is inferior to square-root trial division and far inferior to advanced primality algorithms for large integers. Its value is foundational clarity rather than scale.

The row-sum spectral bound can be loose because absolute values erase cancellation. It is centered at zero and therefore ignores diagonal location information that Gershgorin discs retain. The stated theorem is also restricted to real eigenpairs.

### 8.3. A unified dispatcher

Because the three procedures have distinct goal shapes, they can be selected by structure. Expressions built from minimum and addition invite tropical rewriting. Concrete claims about primality invite finite divisor evaluation. Eigenvalue inequalities accompanied by a uniform row-sum hypothesis invite the spectral theorem. A compositional system should report not only the result but also the applicable theorem and the generated evidence: rewrites, divisor or exhausted range, or row sums.

## 9. Future work

Several extensions arise directly from the present limitations.

1. **Tropical normal forms.** Replace local rewriting with a reflected syntax for finite min-plus polynomials, prove that normalization preserves evaluation, and establish uniqueness of canonical antichain normal forms. This would decide substantially more identities.

2. **Faster primality certificates.** Restrict trial division to $d\le\sqrt n$, prove the complementary-factor lemma, and add certificate-producing support for divisibility, coprimality, congruences, and bounded Diophantine goals.

3. **Richer spectral certificates.** Generalize from real square matrices to complex matrices and arbitrary finite index sets. Add Gershgorin discs centered at $A_{ii}$, column-sum bounds, weighted norms, and strict diagonal-dominance criteria for nonsingularity.

4. **Composable procedure selection.** Recognize the mathematical shape of a problem and invoke the corresponding certified procedure while retaining a trace of the exact theorem and evidence used.

5. **Performance evaluation.** Assemble representative benchmark families and measure success, expression growth, and running time against direct simplification and theorem application.

## 10. Conclusion

Three elementary procedures illustrate a common approach to dependable mathematical computation. Min-plus rewriting rests on distributivity and idempotence. Exhaustive trial division rests on an exact equivalence between finite search and primality. Absolute row sums bound real eigenvalues through a maximal coordinate and the triangle inequality. Each procedure has a transparent input, output, proof of soundness, and complexity profile.

The broader principle is that routine automation is strongest when its mathematical meaning is visible. A rewrite should cite an equality, a decision should correspond to a logical characterization, and a numerical bound should expose the inequalities that support it. Such procedures may be small, but they form reliable components for larger arguments in optimization, number theory, and linear algebra.
