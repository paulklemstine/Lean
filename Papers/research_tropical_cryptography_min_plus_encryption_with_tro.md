# Spectral Identifiability of Exponents in Min-Plus Matrix Powers

**Aristotle**  
**July 19, 2026**

## Abstract

We study positive powers of finite nonempty real matrices over the min-plus algebra and isolate a spectral leakage mechanism relevant to matrix-power cryptographic proposals. Min-plus multiplication is defined by $(A\otimes B)_{ij}=\min_k(A_{ik}+B_{kj})$, and the action on a vector is $(A\otimes v)_i=\min_j(A_{ij}+v_j)$. With the positive-power convention $P_0(A)=A$ and $P_{k+1}(A)=A\otimes P_k(A)$, we prove that every eigenpair $A\otimes v=\lambda+v$ propagates according to the exact law $P_k(A)\otimes v=(k+1)\lambda+v$. It follows that a nonzero eigenvalue makes the positive-power map injective, while a collision between distinct powers forces every represented eigenvalue to vanish. If a public power $B=P_k(A)$ has eigenvalue $\mu$ on the same eigenvector, then $\mu=(k+1)\lambda$, so the exponent index is algebraically recoverable as $k=\mu/\lambda-1$ when $\lambda\ne0$. We also prove that adding a constant $c$ to every matrix entry preserves the eigenvector and replaces $\lambda$ by $c+\lambda$; consequently, every offset except $c=-\lambda$ retains injectivity. These results establish mathematical identifiability, not an eigenvalue algorithm or a complexity-theoretic attack. They show that tropical spectral scaling is a potential leakage channel and must not be taken as evidence of one-wayness.

## 1. Introduction

The min-plus algebra replaces ordinary addition by minimum and ordinary multiplication by addition. This change gives matrix algebra a direct optimization interpretation: a product combines costs through an intermediate state, and a matrix power records optimal costs for paths of fixed length. The same structure appears in shortest-path problems, scheduling, dynamic programming, and discrete-event systems.

The apparent asymmetry between computing and reversing powers has also motivated cryptographic proposals. Given a public matrix $A$ and a positive tropical power of $A$, one may ask whether recovering the exponent is difficult. Repeated squaring can evaluate large powers efficiently once an associative multiplication and identity convention are fixed. It is therefore tempting to regard the inverse task as a tropical analogue of a discrete logarithm.

Such an analogy must be examined through the invariants native to tropical algebra. In ordinary linear algebra, eigenvalues convert repeated matrix multiplication into scalar exponentiation. In min-plus algebra, eigenvalues convert repeated matrix multiplication into ordinary scalar addition. This paper develops that observation from elementary finite-minimum identities and derives exact consequences for exponent identifiability.

Our setting deliberately avoids extended values and sparse matrices: all entries lie in $\mathbb{R}$, and the dimension $n$ is positive. This ensures that every minimum in the definitions is taken over a finite nonempty set. We do not assume that every matrix has an eigenpair; rather, the conclusions are conditional on a specified eigenpair. This distinction is important for cryptographic interpretation.

The principal contributions are:

1. an action-associativity theorem and a scalar-translation theorem for finite min-plus matrices;
2. an exact eigenvalue power law under a clearly stated positive-power convention;
3. injectivity of positive powers in the presence of a nonzero eigenvalue;
4. a collision criterion forcing any represented eigenvalue to be zero;
5. an exact exponent-scaling formula from an eigenvalue observed on a common eigenvector; and
6. a characterization of uniform entry shifts, showing that all but one offset preserve nonzero spectral leakage relative to a given eigenpair.

The conclusions are algebraic. They do not prove that eigenpairs can be found efficiently in every proposed parameter family, nor do they establish or refute post-quantum security. Instead, they identify what a complete security analysis must address.

## 2. Min-plus preliminaries

### 2.1 Scalars, matrices, and vectors

For real scalars $x$ and $y$, define the min-plus operations

$$
x\oplus y=\min(x,y),\qquad x\otimes y=x+y.
$$

Let $n\ge1$, and index rows and columns by $\{1,\ldots,n\}$. For matrices $A,B\in\mathbb{R}^{n\times n}$, their **min-plus product** is

$$
(A\otimes B)_{ij}=\min_{1\le k\le n}\bigl(A_{ik}+B_{kj}\bigr).
$$

For a vector $v\in\mathbb{R}^n$, the **min-plus action** is

$$
(A\otimes v)_i=\min_{1\le j\le n}\bigl(A_{ij}+v_j\bigr).
$$

These formulas are meaningful because $n$ is positive. The product can be interpreted as optimal composition: $A_{ik}$ is the cost of the first stage, $B_{kj}$ the cost of the second, and the minimum chooses the cheapest intermediate state.

### 2.2 Positive powers and indexing

We define the sequence of **positive powers** recursively by

$$
P_0(A)=A,
\qquad
P_{k+1}(A)=A\otimes P_k(A)
\quad(k\ge0).
$$

Thus $P_k(A)$ contains $k+1$ factors of $A$. Equivalently, if conventional notation $A^{\otimes r}$ is reserved for an exponent $r\ge1$, then

$$
P_k(A)=A^{\otimes(k+1)}.
$$

The shifted indexing avoids introducing an identity matrix, but it must be retained in every recovery formula. In particular, recovering $k$ is not the same as recovering the number $k+1$ of matrix factors.

### 2.3 Eigenpairs

A scalar $\lambda\in\mathbb{R}$ and vector $v\in\mathbb{R}^n$ form a **min-plus eigenpair** of $A$ if

$$
A\otimes v=\lambda+v,
$$

where $\lambda+v$ denotes componentwise translation:

$$
(\lambda+v)_i=\lambda+v_i.
$$

Unlike ordinary scalar multiplication, tropical scaling is additive translation. The eigenpair equation says that the shape of $v$ is unchanged by the action of $A$, while its common level increases by $\lambda$.

## 3. Two structural lemmas

The power theorem rests on two finite-minimum identities.

### Lemma 3.1. Action associativity

For all $A,B\in\mathbb{R}^{n\times n}$ and $v\in\mathbb{R}^n$,

$$
(A\otimes B)\otimes v=A\otimes(B\otimes v).
$$

#### Proof sketch

Fix a coordinate $i$. Expanding the left side gives

$$
\begin{aligned}
((A\otimes B)\otimes v)_i
&=\min_j\left((A\otimes B)_{ij}+v_j\right)\\
&=\min_j\left(\min_k(A_{ik}+B_{kj})+v_j\right)\\
&=\min_{j,k}(A_{ik}+B_{kj}+v_j).
\end{aligned}
$$

Expanding the right side gives

$$
\begin{aligned}
(A\otimes(B\otimes v))_i
&=\min_k\left(A_{ik}+(B\otimes v)_k\right)\\
&=\min_k\left(A_{ik}+\min_j(B_{kj}+v_j)\right)\\
&=\min_{k,j}(A_{ik}+B_{kj}+v_j).
\end{aligned}
$$

Both expressions minimize the same real-valued function over the same finite product set. The order of the two minima is immaterial, proving the identity coordinatewise.

### Lemma 3.2. Scalar translation of the action

For every $A\in\mathbb{R}^{n\times n}$, $v\in\mathbb{R}^n$, and $c\in\mathbb{R}$,

$$
A\otimes(c+v)=c+(A\otimes v).
$$

#### Proof sketch

For each coordinate $i$,

$$
\begin{aligned}
(A\otimes(c+v))_i
&=\min_j(A_{ij}+c+v_j)\\
&=c+\min_j(A_{ij}+v_j)\\
&=(c+(A\otimes v))_i.
\end{aligned}
$$

The second equality holds because the same constant $c$ is added to every member of a finite set before taking its minimum.

These lemmas express the two ingredients needed for spectral iteration: actions can be regrouped, and common translations pass unchanged through an action.

## 4. Exact spectral scaling under powers

### Theorem 4.1. Eigenpair power law

Let $A\in\mathbb{R}^{n\times n}$ with $n\ge1$. If $(\lambda,v)$ is a min-plus eigenpair of $A$, then for every $k\ge0$, $( (k+1)\lambda,v)$ is a min-plus eigenpair of $P_k(A)$. Explicitly,

$$
P_k(A)\otimes v=(k+1)\lambda+v.
$$

#### Proof sketch

Proceed by induction on $k$. At $k=0$, the assertion is

$$
P_0(A)\otimes v=A\otimes v=\lambda+v,
$$

which is the assumed eigenpair equation.

Assume the result for $k$. By the recursive definition of positive powers and Lemma 3.1,

$$
\begin{aligned}
P_{k+1}(A)\otimes v
&=(A\otimes P_k(A))\otimes v\\
&=A\otimes(P_k(A)\otimes v).
\end{aligned}
$$

Substitute the induction hypothesis and use Lemma 3.2:

$$
\begin{aligned}
A\otimes((k+1)\lambda+v)
&=(k+1)\lambda+(A\otimes v)\\
&=(k+1)\lambda+(\lambda+v)\\
&=(k+2)\lambda+v.
\end{aligned}
$$

This is the required formula for $k+1$.

### Interpretation

The theorem turns a matrix iteration into scalar arithmetic along an eigenvector. Each additional factor of $A$ contributes exactly $\lambda$ to the translated vector. The linear function $k\mapsto(k+1)\lambda$ is therefore a spectral timestamp attached to the power sequence.

The theorem is exact over the real numbers. No asymptotic approximation, genericity assumption, or limiting argument is involved. It is also conditional: it starts with a given eigenpair and does not assert existence for every real matrix.

## 5. Injectivity and collision consequences

### Theorem 5.1. Injectivity from a nonzero eigenvalue

Suppose $A$ has a min-plus eigenpair $(\lambda,v)$ with $\lambda\ne0$. Then the positive-power map

$$
k\longmapsto P_k(A)
$$

is injective on the nonnegative integers. In other words, if $P_a(A)=P_b(A)$, then $a=b$.

#### Proof sketch

Assume $P_a(A)=P_b(A)$. Acting on $v$ and invoking Theorem 4.1 on each side yields

$$
(a+1)\lambda+v=(b+1)\lambda+v.
$$

Compare any coordinate and cancel its common $v_i$ term:

$$
(a+1)\lambda=(b+1)\lambda.
$$

Since $\lambda\ne0$, ordinary real cancellation gives $a+1=b+1$, hence $a=b$.

This theorem concerns uniqueness rather than computational recovery. It says that no two indices can produce the same positive power under the stated spectral hypothesis.

### Corollary 5.2. Distinct-power collisions force zero eigenvalues

Let $(\lambda,v)$ be any min-plus eigenpair of $A$. If $P_a(A)=P_b(A)$ for distinct indices $a\ne b$, then

$$
\lambda=0.
$$

#### Proof sketch

If $\lambda$ were nonzero, Theorem 5.1 would force $a=b$, contradicting the hypothesis. Therefore $\lambda=0$.

The statement quantifies over every represented eigenpair: once a distinct-power collision is known, any scalar that occurs in an eigenpair must vanish. It does not assert that an eigenpair necessarily exists.

### The zero-eigenvalue boundary

When $\lambda=0$, Theorem 4.1 becomes

$$
P_k(A)\otimes v=v
$$

for every $k$. Along this eigenvector, the spectral timestamp contains no exponent information. This does not imply that powers collide; it means only that this particular argument cannot distinguish them. Characterizing eventual periodicity, collisions, and alternative invariants in the zero-eigenvalue regime remains a separate problem.

## 6. Exponent identification from observed eigenvalues

### Theorem 6.1. Observed eigenvalue of a public power

Let $A,B\in\mathbb{R}^{n\times n}$ and suppose $B=P_k(A)$. If the same vector $v$ satisfies

$$
A\otimes v=\lambda+v
$$

and

$$
B\otimes v=\mu+v,
$$

then

$$
\mu=(k+1)\lambda.
$$

#### Proof sketch

Because $B=P_k(A)$, Theorem 4.1 gives

$$
B\otimes v=(k+1)\lambda+v.
$$

The observed eigenpair equation gives $B\otimes v=\mu+v$. Comparing any coordinate and canceling $v_i$ yields the stated equality.

### Corollary 6.2. Algebraic recovery formula

Under the hypotheses of Theorem 6.1, if $\lambda\ne0$, then

$$
k=\frac{\mu}{\lambda}-1.
$$

If one uses the conventional positive exponent $r=k+1$, then

$$
r=\frac{\mu}{\lambda}.
$$

The distinction between these formulas is purely the chosen indexing convention.

### Identifiability versus efficient attack

The recovery formula has three prerequisites: a base eigenvalue $\lambda$, a power eigenvalue $\mu$, and the guarantee that both correspond to the same vector $v$. The theorem neither supplies those data nor analyzes their computational cost. Consequently, it establishes **identifiability**: given certified spectral observations, the exponent is unique and explicitly determined. To upgrade this to a cryptanalytic algorithm, one would need an executable method for obtaining or certifying the relevant eigenpair data in the chosen matrix model.

For finite weighted directed graphs, tropical eigenvalues are closely related to cycle means under suitable hypotheses. That relationship suggests an algorithmic avenue, but it is outside the assumptions proved here. Sparse matrices with forbidden edges also require an extended scalar $+\infty$, which is absent from the present real-valued setting.

## 7. Uniform entry shifts

One possible attempt to mask tropical spectral information is to add a public or secret constant to every matrix entry.

### Definition 7.1. Uniformly shifted matrix

For $c\in\mathbb{R}$, define $S_c(A)\in\mathbb{R}^{n\times n}$ by

$$
S_c(A)_{ij}=c+A_{ij}.
$$

### Theorem 7.2. Eigenpair shift law

If $(\lambda,v)$ is a min-plus eigenpair of $A$, then $(c+\lambda,v)$ is a min-plus eigenpair of $S_c(A)$. That is,

$$
S_c(A)\otimes v=(c+\lambda)+v.
$$

#### Proof sketch

For each coordinate $i$,

$$
\begin{aligned}
(S_c(A)\otimes v)_i
&=\min_j(c+A_{ij}+v_j)\\
&=c+\min_j(A_{ij}+v_j)\\
&=c+(\lambda+v_i)\\
&=(c+\lambda)+v_i.
\end{aligned}
$$

Thus a uniform entry shift preserves the eigenvector and translates the eigenvalue by exactly the same constant.

### Corollary 7.3. Injectivity after a generic shift

Under the hypotheses of Theorem 7.2, if

$$
c+\lambda\ne0,
$$

then the positive-power map $k\mapsto P_k(S_c(A))$ is injective.

#### Proof sketch

The shifted matrix has eigenpair $(c+\lambda,v)$ by Theorem 7.2. Since its eigenvalue is nonzero, Theorem 5.1 applies directly.

For a fixed eigenpair $(\lambda,v)$, exactly one shift makes this particular eigenvalue zero: $c=-\lambda$. Every other scalar shift preserves a nonzero timestamp. Uniform shifting is therefore not a generic cure for spectral leakage. At the exceptional shift, the theorem makes no claim about other eigenpairs; another nonzero eigenvalue, if present, could still imply injectivity.

## 8. Algorithms and numerical realization

### 8.1 Direct min-plus multiplication

Given two dense $n\times n$ matrices, the direct product evaluates $n^2$ output entries, each as the minimum of $n$ sums. Its running time is $O(n^3)$ and its output storage is $O(n^2)$. The action on a vector requires $O(n^2)$ arithmetic comparisons and $O(n)$ output storage.

### 8.2 Positive-power evaluation

The recurrence $P_{k+1}(A)=A\otimes P_k(A)$ gives a transparent linear-chain algorithm requiring $k$ min-plus matrix products after the initial matrix, hence $O(kn^3)$ time for dense inputs. It directly matches the convention used in the theorems and is suitable for small demonstrations.

With a min-plus identity matrix in an extended domain containing $+\infty$, binary exponentiation can reduce the product count to $O(\log r)$ for conventional exponent $r$. For dense multiplication this gives $O(n^3\log r)$ time. A complete treatment must prove that the executable identity, associativity, and exponent convention correspond to the mathematical power sequence. The present results require only positive recursive powers and do not rely on a binary algorithm.

### 8.3 Eigenpair checking and exponent recovery

Given proposed values $(A,\lambda,v)$, one checks the eigenpair equation by computing $A\otimes v$ and comparing it with $\lambda+v$, an $O(n^2)$ operation. Given a second certified scalar $\mu$ for $P_k(A)$ on the same vector and nonzero $\lambda$, recovery requires one division and one subtraction. In exact rational or integer-compatible arithmetic this is algebraically straightforward. Floating-point implementations require tolerances and should not be confused with exact certification.

## 9. Worked examples

### Example 9.1. A two-state nonzero eigenpair

Let

$$
A=
\begin{pmatrix}
2&5\\
4&2
\end{pmatrix},
\qquad
v=
\begin{pmatrix}
0\\
1
\end{pmatrix}.
$$

Then

$$
(A\otimes v)_1=\min(2+0,5+1)=2
$$

and

$$
(A\otimes v)_2=\min(4+0,2+1)=3.
$$

Therefore

$$
A\otimes v=
\begin{pmatrix}2\\3\end{pmatrix}
=2+
\begin{pmatrix}0\\1\end{pmatrix},
$$

so $\lambda=2$. Theorem 4.1 predicts

$$
P_k(A)\otimes v=2(k+1)+v.
$$

For $k=2$, the matrix contains three factors and the observed eigenvalue is $\mu=6$. The recovery formula gives

$$
k=\frac{6}{2}-1=2.
$$

### Example 9.2. Uniform shifts

For the matrix in Example 9.1, shift every entry by $c=1$. The same vector has eigenvalue $3$, so

$$
P_k(S_1(A))\otimes v=3(k+1)+v.
$$

The positive powers are injective. If instead $c=-2$, this particular eigenvalue becomes zero. The same vector then satisfies

$$
P_k(S_{-2}(A))\otimes v=v
$$

for all $k$, so it no longer records the exponent. This illustrates the exceptional shift without claiming that the shifted matrix must have colliding powers.

### Example 9.3. Collision diagnostics

Suppose a computation or independent argument establishes $P_a(A)=P_b(A)$ for $a\ne b$. Corollary 5.2 immediately rules out any eigenpair with nonzero real eigenvalue. Thus finding a nonzero eigenpair certifies that the alleged collision is impossible, while confirming a collision constrains the entire represented spectrum to zero.

## 10. Cryptographic implications

A tropical matrix-power public value may be described as $B=A^{\otimes r}$ with a hidden positive exponent $r$. The spectral law shows that, on a shared eigenvector,

$$
\mu=r\lambda.
$$

When $\lambda\ne0$, the exponent satisfies $r=\mu/\lambda$. Hence the eigenvalue relation is a leakage channel, not a source of hardness. A scheme can still be difficult to attack if the required spectral data are unavailable or expensive to compute under its precise assumptions, but that must be demonstrated rather than presumed.

A credible security claim requires at least:

- a precise scalar domain, including treatment of $+\infty$ for missing edges;
- a distribution on public base matrices and private exponents;
- an adversarial model and a definition of success;
- an analysis of eigenpair existence and computation for sampled matrices;
- treatment of zero eigenvalues and normalization;
- a rigorous account of matrix and bit complexity; and
- a reduction, lower bound, or empirical attack analysis appropriate to the claim.

Key exchange introduces further algebraic obligations. With the present indexing, $P_a(A)$ has conventional exponent $a+1$. Re-powering by an index $b$ should therefore correspond, once associativity is fully developed, to conventional exponent $(a+1)(b+1)$, or index $(a+1)(b+1)-1$. Any protocol transcript and shared-key equation must respect this shift. Informal use of $ab$ without fixing conventions risks specifying different keys for the two parties.

No claim of post-quantum security follows from algebraic novelty. Quantum resistance is a complexity statement about a precisely defined problem and attacker. The results here instead narrow the burden of proof: proposed constructions must account for exact spectral scaling and cannot cite it as evidence that powers are one-way.

## 11. Scope and limitations

The results apply to finite nonempty square matrices over $\mathbb{R}$. They do not include $+\infty$, so they do not directly model absent edges in sparse weighted graphs. They assume a supplied eigenpair and do not prove eigenpair existence or uniqueness. They establish equality and injectivity exactly, not numerical stability under approximation.

The conclusions also distinguish three notions that are often conflated:

1. **Distinctness:** nonzero eigenvalues imply that different positive exponents yield different matrices.
2. **Identifiability:** certified eigenvalues on a common eigenvector determine the exponent algebraically.
3. **Efficient recoverability:** an algorithm can obtain the needed certified data within a stated complexity bound.

The first two are established here. The third is a further algorithmic question. Injectivity alone does not make inversion easy, but the scalar recovery formula shows precisely which additional capability would make it easy.

A further limitation is that matrix dimension by itself is not a security parameter. Increasing $n$ enlarges the cost of dense multiplication, but it may also introduce exploitable graph structure, repeated weights, or readily found critical cycles. Meaningful parameter selection must measure the bit lengths of entries and exponents, the cost of spectral algorithms, and the probability of exceptional cases under the actual sampling distribution.

## 12. Future work

The next mathematical step is to connect min-plus eigenpairs to minimum cycle means over rational or integer weights and to certify a cycle-mean algorithm. Extending the scalar domain to include $+\infty$ would permit sparse graphs, after which one can study eigenpair existence for irreducible matrices.

On the computational side, binary exponentiation should be defined together with a proof that it computes the same positive powers and an explicit count of min-plus products. Exact exponent recovery over rational or integer weights should include divisibility and uniqueness conditions. The zero-eigenvalue regime deserves a separate structural theory of eventual periodicity, collisions, and residual leakage after normalization.

For protocol analysis, the re-powering identity and shifted exponent convention should be proved before defining a shared key. Executable arrays should be related rigorously to the matrix model before benchmarking. Finally, masking by conjugation, scalar normalization, or projectivization should be tested against cycle-mean leakage rather than assumed to remove it.

## 13. Conclusion

A min-plus eigenvector linearizes the positive powers of a matrix. If $A\otimes v=\lambda+v$, then every power obeys the exact law

$$
P_k(A)\otimes v=(k+1)\lambda+v.
$$

For $\lambda\ne0$, this makes the power sequence injective and turns a matched observed eigenvalue into the explicit exponent formula $k=\mu/\lambda-1$. Distinct-power collisions force represented eigenvalues to vanish. Uniformly shifting all entries changes the eigenvalue from $\lambda$ to $c+\lambda$ and therefore preserves injectivity for every shift except the one that cancels that eigenvalue.

These facts are elementary consequences of finite minimization, associativity of the action, and translation invariance. Their cryptographic message is correspondingly direct: along an eigenvector, repeated tropical multiplication carries an exact scalar timestamp. Any tropical matrix-power construction must either show that this timestamp is inaccessible in its model or redesign the public information so that the leakage no longer determines the secret.
