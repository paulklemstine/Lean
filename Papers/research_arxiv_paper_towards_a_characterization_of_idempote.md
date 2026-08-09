# Contractive Idempotent Schur Multipliers, a Sharp Gap at $2\sqrt{3}/3$, and the Algebra of Signed Sums of Blow-Ups

**Author:** Aristotle
**Date:** 2026-08-09

---

## Abstract

A Schur multiplier is the operation $B \mapsto A \odot B$ of entrywise multiplication of matrices by a fixed *symbol* $A$; it is idempotent precisely when $A$ is a boolean matrix, and its operator norm is the factorization norm $\|A\|_{\gamma_2}$. A conjecture in the literature asserts that every idempotent Schur multiplier is a finite signed sum of *contractive* idempotents, with the number $L$ of terms bounded by a function of $\|A\|_{\gamma_2}$ alone, uniformly in the size of the matrix; the best known bounds are of the form $L = 2^{O(\gamma^9) + \log^* n}$, and the conjecture is equivalent to eliminating the residual $\log^* n$.

We develop, from first principles, the elementary theory needed to attack the bottom of this hierarchy, and we obtain a complete and sharp answer there. We prove: (i) a three-way equivalence identifying the contractive case — for a boolean $A$, $\|A\|_{\gamma_2} \le 1$ if and only if $A$ is a blow-up of a partial identity matrix, if and only if $A$ satisfies a purely combinatorial *row rigidity* condition; (ii) the exact value $\bigl\|\begin{smallmatrix}1&1\\1&0\end{smallmatrix}\bigr\|_{\gamma_2} = 2\sqrt3/3$, via an explicit planar factorization by four vectors at consecutive $30^\circ$ angles together with a matching two-term sum-of-squares dual certificate; (iii) a **gap theorem**: no boolean matrix of any size has factorization norm strictly between $1$ and $2\sqrt3/3$, and the gap is attained; (iv) submultiplicativity $\|A\odot B\|_{\gamma_2}\le\|A\|_{\gamma_2}\|B\|_{\gamma_2}$ together with closure of blow-ups and of signed sums of blow-ups under entrywise sum, negation, entrywise product and complementation, so that the class of signed sums of blow-ups is a subring for the Hadamard product and the number of terms behaves like a degree; and (v) the introduction of the *blow-up number* $\mathrm{eq}(A)$, equal to the number of equality queries needed to compute $A$ as a signed combination, with $\|A\|_{\gamma_2} \le \mathrm{eq}(A) \le \min(m,n)$, $\mathrm{eq}(A)\le 1 \iff A$ is a blow-up, and — as a corollary of the gap theorem — the conjecture holds with $L=1$, uniformly in the dimensions, for every $\gamma < 2\sqrt3/3$.

**Keywords:** Schur multiplier, factorization norm $\gamma_2$, boolean matrix, blow-up of the identity, contractive idempotent, semidefinite programming duality, communication complexity, equality oracle.

---

## 1. Introduction

### 1.1 Schur multipliers and idempotency

For matrices $A, B$ of the same shape, write $(A \odot B)_{ij} = A_{ij}B_{ij}$ for the *Hadamard* (entrywise) product. Fixing $A$ gives a linear operator
$$ S_A : B \longmapsto A \odot B, $$
the **Schur multiplier** with symbol $A$. Schur multipliers are among the simplest operations on matrices, and simultaneously among the most subtle when one asks about their norms as operators on the bounded operators of a Hilbert space.

$S_A$ is idempotent, $S_A \circ S_A = S_A$, exactly when $A_{ij}^2 = A_{ij}$ for all $i,j$, i.e. exactly when $A$ is **boolean**: all entries in $\{0,1\}$. Thus "idempotent Schur multiplier" is synonymous with "zero–one matrix", and the analytic question is how the norm of $S_A$ interacts with the combinatorics of the zero–one pattern.

By a classical theorem of Grothendieck–Haagerup type, the operator norm of $S_A$ equals the **factorization norm** $\|A\|_{\gamma_2}$, defined below in purely Euclidean terms. Everything in this paper is phrased in terms of $\|\cdot\|_{\gamma_2}$, which is elementary and self-contained; no operator-algebraic machinery is used.

### 1.2 The conjecture

A **contractive** idempotent Schur multiplier is one with $\|A\|_{\gamma_2} \le 1$. Livshits' description of these is that their symbols are exactly the *blow-ups of partial identity matrices*: after permuting rows and columns, $A$ is block-diagonal with all-ones rectangular blocks, and zeros elsewhere.

The conjecture that organizes the subject is:

> **Conjecture A.** Every idempotent Schur multiplier is a finite signed sum of contractive idempotents, with the number of terms bounded by a function of the norm alone.

Equivalently, in matrix form: for every $\gamma$ there is $L = L(\gamma)$ such that every boolean matrix $A$ with $\|A\|_{\gamma_2} \le \gamma$ admits a representation
$$ A = \sum_{\ell=1}^{L} \varepsilon_\ell B_\ell, \qquad \varepsilon_\ell \in \{\pm 1\}, $$
with each $B_\ell$ a blow-up of a partial identity matrix. The best known bounds attain $L = 2^{O(\gamma^9) + \log^* n}$ for $n\times n$ matrices, where $\log^*$ is the iterated logarithm; the conjecture is the statement that the $\log^* n$ can be removed. As an application, matrix families of bounded factorization norm lie in the communication complexity class $\mathrm{P}^{\mathrm{EQ}}$ of problems solvable with polylogarithmically many equality-oracle queries, because a signed sum of $L$ blow-ups is literally a signed combination of $L$ equality tests (Section 6).

### 1.3 Contributions

This paper gives a complete, self-contained treatment of the *bottom* of the hierarchy, together with the algebraic structure theory of the class of signed sums of blow-ups. Concretely:

1. **The contractive case, three ways** (Theorem 3.6): for boolean $A$,
 $$\|A\|_{\gamma_2}\le 1 \iff A \text{ is a blow-up of a partial identity} \iff A \text{ is row rigid}. $$
 The last is a finite, purely combinatorial condition — equivalently, $A$ contains no $2\times2$ submatrix equal to $\bigl(\begin{smallmatrix}1&1\\1&0\end{smallmatrix}\bigr)$.
2. **An exact norm** (Theorem 4.4): $\bigl\|\bigl(\begin{smallmatrix}1&1\\1&0\end{smallmatrix}\bigr)\bigr\|_{\gamma_2} = 2\sqrt3/3$, with matching primal and dual certificates.
3. **A sharp gap** (Theorem 4.6): the set of factorization norms of boolean matrices omits the open interval $(1, 2\sqrt3/3)$, and the right endpoint is attained by a $2\times2$ matrix.
4. **Algebra** (Section 5): $\gamma_2$ is submultiplicative for $\odot$; blow-ups are $\odot$-closed, i.e. contractive idempotent Schur multipliers are closed under composition; signed sums of blow-ups are closed under $+$, $-$, $\odot$ and complementation, with term counts $L_1+L_2$, $L$, $L_1L_2$ and $L+1$ respectively.
5. **The blow-up number** (Section 6): $\mathrm{eq}(A) := \min\{L : A \text{ is a signed sum of } L \text{ blow-ups}\}$ satisfies $\|A\|_{\gamma_2} \le \mathrm{eq}(A) \le \min(m,n)$ and $\mathrm{eq}(A)\le1 \iff A$ is a blow-up; and Conjecture A holds with $L = 1$, uniformly in the dimensions, for every $\gamma < 2\sqrt3/3$ (Theorem 6.6).

---

## 2. The factorization norm

Throughout, $A$ is a real $m\times n$ matrix with rows indexed by $i$ and columns by $j$. All Hilbert spaces are finite-dimensional real Euclidean spaces $\mathbb{R}^d$ with the standard inner product $\langle u,v\rangle = \sum_t u_t v_t$.

**Definition 2.1 (Factorization of size $c$).** A *$\gamma_2$-factorization of $A$ of size $c$* consists of a dimension $d \in \mathbb{N}$ and vectors $x_1,\dots,x_m,\ y_1,\dots,y_n \in \mathbb{R}^d$ such that
$$ \langle x_i, y_j\rangle = A_{ij} \quad \text{for all } i,j, \qquad \|x_i\|^2 \le c \ \ \forall i, \qquad \|y_j\|^2 \le c \ \ \forall j. $$
We write $\|A\|_{\gamma_2} \le c$ to mean that such a factorization exists, and $\|A\|_{\gamma_2}$ for the infimum of admissible $c$ (which is attained by compactness, though we never need this).

Note that the definition is *balanced*: the same bound $c$ constrains both families. The classical definition is unbalanced.

**Definition 2.2 (Unbalanced form).** $\|A\|'_{\gamma_2} \le c$ means: there exist $x_i, y_j \in \mathbb{R}^d$ with $\langle x_i,y_j\rangle = A_{ij}$ and $\bigl(\max_i \|x_i\|\bigr)\bigl(\max_j \|y_j\|\bigr) \le c$.

**Proposition 2.3 (Equivalence of the two forms).** For $c \ge 0$, $\|A\|_{\gamma_2}\le c$ if and only if $\|A\|'_{\gamma_2} \le c$.

*Proof sketch.* If all $\|x_i\|^2,\|y_j\|^2 \le c$ then $\max_i\|x_i\|\max_j\|y_j\| \le \sqrt c\sqrt c = c$. Conversely, given an unbalanced factorization put $X = \max_i\|x_i\|$, $Y = \max_j\|y_j\|$ with $XY \le c$. If $X = 0$ or $Y = 0$ then $A = 0$ and there is nothing to prove. Otherwise rescale by $\lambda = \sqrt{Y/X}$: replacing $x_i$ by $\lambda x_i$ and $y_j$ by $\lambda^{-1}y_j$ leaves all inner products unchanged, while $\max_i\|\lambda x_i\|^2 = XY \le c$ and $\max_j\|\lambda^{-1}y_j\|^2 = XY \le c$. $\square$

The balanced form is the convenient one for everything that follows: it is symmetric in rows and columns, and the constraint set is manifestly convex in the Gram matrix.

**Proposition 2.4 (Elementary properties).** Let $A, B$ be $m\times n$.
1. *(Monotonicity)* If $\|A\|_{\gamma_2}\le c$ and $c \le c'$ then $\|A\|_{\gamma_2}\le c'$.
2. *(Entrywise bound)* If $\|A\|_{\gamma_2} \le c$ then $|A_{ij}| \le c$ for all $i,j$.
3. *(Negation)* $\|-A\|_{\gamma_2} = \|A\|_{\gamma_2}$.
4. *(Subadditivity)* $\|A + B\|_{\gamma_2} \le \|A\|_{\gamma_2} + \|B\|_{\gamma_2}$; more generally $\bigl\|\sum_{\ell<L} C_\ell\bigr\|_{\gamma_2} \le \sum_{\ell<L}\|C_\ell\|_{\gamma_2}$.
5. *(Transposition)* $\|A^{\mathsf T}\|_{\gamma_2} = \|A\|_{\gamma_2}$.
6. *(Submatrices)* For any maps $\sigma : [m']\to[m]$, $\tau:[n']\to[n]$, the matrix $A' = (A_{\sigma(i)\tau(j)})$ satisfies $\|A'\|_{\gamma_2}\le\|A\|_{\gamma_2}$.

*Proof sketch.* (1) and (5) are immediate from the symmetry of Definition 2.1; (6) restricts the two families of vectors along $\sigma,\tau$, which cannot increase the maximum squared norm. (2) is Cauchy–Schwarz: $|A_{ij}| = |\langle x_i,y_j\rangle| \le \|x_i\|\|y_j\| \le c$. (3) negates the $x$ family. (4) is concatenation: if $A_{ij} = \langle x_i,y_j\rangle$ in $\mathbb{R}^{d}$ with bound $c$ and $B_{ij} = \langle u_i,v_j\rangle$ in $\mathbb{R}^{d'}$ with bound $c'$, then in $\mathbb{R}^{d+d'}$ the vectors $(x_i, u_i)$ and $(y_j, v_j)$ have inner products $A_{ij}+B_{ij}$ and squared norms at most $c + c'$. The general case follows by induction on $L$. $\square$

Property (6) is what makes forbidden-pattern arguments possible: a lower bound proved for a small pattern propagates to every matrix containing it.

---

## 3. Blow-ups, rigidity, and the contractive case

**Definition 3.1 (Blow-up of a partial identity).** A matrix $A$ is a **blow-up** if there exist label functions $f : [m]\to\mathbb{N}$ and $g:[n]\to\mathbb{N}$ with
$$ A_{ij} = \mathbf 1[\,f(i)=g(j)\,] = \begin{cases}1,& f(i)=g(j),\\ 0,&\text{otherwise.}\end{cases} $$

Grouping rows and columns by label exhibits $A$, after row and column permutations, as a block-diagonal matrix whose diagonal blocks are all-ones rectangles (rows or columns whose labels are used by no partner contribute zero rows/columns). Every blow-up is boolean.

**Definition 3.2 (Boolean).** $A$ is **boolean** if $A_{ij}\in\{0,1\}$ for all $i,j$.

**Proposition 3.3 (Idempotency).** The Schur multiplier $S_A$ satisfies $S_A\circ S_A = S_A$ if and only if $A$ is boolean.

*Proof.* $S_A(S_A(B))_{ij} = A_{ij}^2B_{ij}$, so idempotency for all $B$ is equivalent to $A_{ij}^2 = A_{ij}$ for all $i,j$, i.e. $A_{ij}\in\{0,1\}$ (take $B$ all-ones for the forward direction). $\square$

**Proposition 3.4 (Blow-ups are contractive).** If $A$ is a blow-up then $\|A\|_{\gamma_2}\le 1$.

*Proof.* Choose $K$ larger than all labels used and work in $\mathbb{R}^K$. Set $x_i = e_{f(i)}$ and $y_j = e_{g(j)}$, standard basis vectors. Then $\langle x_i, y_j\rangle = \mathbf 1[f(i)=g(j)] = A_{ij}$, and every vector has squared norm $1$. $\square$

**Definition 3.5 (Row rigidity).** $A$ is **row rigid** if for all rows $i,i'$ and every column $j$,
$$ A_{ij}=1 \text{ and } A_{i'j}=1 \implies A_{ij'} = A_{i'j'} \text{ for every column } j'. $$
That is, two rows that share a $1$ in a common column are identical.

For boolean matrices, row rigidity is precisely the *absence of the $2$-staircase pattern*: a failure means there are rows $i,i'$ and columns $j,j'$ with
$$ A_{ij}=A_{ij'}=A_{i'j}=1,\qquad A_{i'j'}=0, $$
i.e. a $2\times2$ submatrix equal to $T_2 := \bigl(\begin{smallmatrix}1&1\\1&0\end{smallmatrix}\bigr)$ (after possibly swapping the roles of the two rows). We record this as Lemma 4.5 below.

**Theorem 3.6 (Characterization of contractive idempotents).** For a boolean matrix $A$ the following are equivalent:
1. $\|A\|_{\gamma_2}\le 1$;
2. $A$ is a blow-up of a partial identity matrix;
3. $A$ is row rigid.

Equivalently, in multiplier language: $S_A$ is an idempotent Schur multiplier of norm at most $1$ if and only if $A$ is a blow-up of a partial identity matrix.

*Proof sketch.* $(2)\Rightarrow(1)$ is Proposition 3.4.

$(2)\Rightarrow(3)$: if $A_{ij}=A_{i'j}=1$ then $f(i)=g(j)=f(i')$, so rows $i$ and $i'$ have the same label and hence the same indicator row.

$(1)\Rightarrow(3)$ is the analytic heart, and it is the *equality case of Cauchy–Schwarz*. Let $x_i,y_j$ be a factorization with all squared norms at most $1$. If $A_{ij}=1$ then
$$ 1 = \langle x_i,y_j\rangle \le \|x_i\|\|y_j\| \le 1, $$
so all inequalities are equalities; combined with $\|x_i\|=\|y_j\|=1$ this forces $x_i = y_j$ (indeed $\|x_i-y_j\|^2 = \|x_i\|^2 - 2\langle x_i,y_j\rangle + \|y_j\|^2 \le 1-2+1 = 0$). Thus a $1$ in position $(i,j)$ *glues* $x_i$ to $y_j$. Now if $A_{ij}=A_{i'j}=1$ then $x_i = y_j = x_{i'}$, and therefore $A_{ij'} = \langle x_i,y_{j'}\rangle = \langle x_{i'},y_{j'}\rangle = A_{i'j'}$ for every $j'$: row rigidity.

$(3)\Rightarrow(2)$ is the combinatorial construction of labels. Assume $A$ boolean and row rigid. Give row $i$ the label
$$ f(i) := \min\bigl(\{\,j : A_{ij}=1\,\} \cup \{\,n+i\,\}\bigr), $$
i.e. the index of its leftmost $1$, or a *fresh* label $n+i$ (larger than any column index and distinct across rows) if the row is zero. Give column $j$ the label
$$ g(j) := \min\bigl(\{\,j' : \exists i,\ A_{ij}=1 \text{ and } A_{ij'}=1\,\}\cup\{\,n+m+j\,\}\bigr), $$
i.e. the leftmost $1$ of any row hitting column $j$, or a fresh label if column $j$ is zero. One checks: (a) if $A_{ij}=1$ then $f(i)=g(j)$, using rigidity — every row hitting $j$ is the same row, so the minimum defining $g(j)$ equals the minimum defining $f(i)$; (b) if $A_{ij}=0$ then $f(i)\ne g(j)$: if column $j$ is zero, $g(j)$ is a fresh label exceeding every $f(i)$; if some row $i_0$ hits $j$, then $g(j)=f(i_0)$ and $f(i)=f(i_0)$ would force $A_{ij'} = A_{i_0j'}$ at the common leftmost $1$ and then rigidity would give $A_{ij}=A_{i_0j}=1$, a contradiction. Hence $A_{ij}=\mathbf 1[f(i)=g(j)]$. $\square$

The equivalence $(1)\iff(2)$ is Livshits' description of contractive idempotent Schur multipliers; the point of including $(3)$ is that it converts an analytic hypothesis into a *forbidden $2\times2$ pattern*, which is what drives the gap theorem.

**Corollary 3.7 (Multiplier form).** For any matrix $A$: $S_A$ is idempotent and $\|A\|_{\gamma_2}\le1$ if and only if $A$ is a blow-up of a partial identity matrix.

---

## 4. The sharp gap at $2\sqrt3/3$

Write $T_2 = \begin{pmatrix}1&1\\1&0\end{pmatrix}$, the *triangular truth matrix* or $2$-staircase.

### 4.1 The dual bound: a two-term sum-of-squares certificate

**Theorem 4.1 (SOS lower bound).** Let $A$ have a $\gamma_2$-factorization of size $c$ and suppose $A$ contains $T_2$ as a (not necessarily contiguous) $2\times2$ submatrix: there are rows $i, i'$ and columns $j,j'$ with
$$A_{ij}=A_{ij'}=A_{i'j}=1,\qquad A_{i'j'}=0.$$
Then $c \ge 2\sqrt3/3$.

*Proof.* Put $a = x_i,\ b = x_{i'},\ p = y_j,\ q = y_{j'}$, so that
$$ \langle a,p\rangle = \langle a,q\rangle = \langle b,p\rangle = 1, \qquad \langle b,q\rangle = 0, $$
and $\|a\|^2,\|b\|^2,\|p\|^2,\|q\|^2 \le c$. Consider the nonnegative quantity
$$ 0 \;\le\; \bigl\|\sqrt3\,b - 2p + q\bigr\|^2 + 2\bigl\|-\sqrt3\,a + p + q\bigr\|^2. $$
Expanding coordinatewise (using $(\sqrt3)^2=3$) gives, for each coordinate $t$,
$$ (\sqrt3 b_t - 2p_t + q_t)^2 + 2(-\sqrt3 a_t + p_t + q_t)^2 = 6a_t^2+3b_t^2+6p_t^2+3q_t^2 - 4\sqrt3\,b_tp_t + 2\sqrt3\,b_tq_t - 4\sqrt3\,a_tp_t - 4\sqrt3\,a_tq_t. $$
Summing over $t$ and substituting the four known inner products,
$$ 0 \le 6\|a\|^2 + 3\|b\|^2 + 6\|p\|^2 + 3\|q\|^2 - 4\sqrt3 + 0 - 4\sqrt3 - 4\sqrt3 \le (6+3+6+3)c - 12\sqrt3 = 18c - 12\sqrt3 . $$
Hence $c \ge \dfrac{12\sqrt3}{18} = \dfrac{2\sqrt3}{3}$. $\square$

The coefficients are not guessed: the constraint "$\|A\|_{\gamma_2}\le c$ with prescribed inner products" is a semidefinite feasibility problem in the Gram matrix of $(a,b,p,q)$, and the two squares $\sqrt3\,b-2p+q$ and $-\sqrt3\,a+p+q$ (with weights $1$ and $2$) form an optimal dual solution. Because the primal bound below matches exactly, both certificates are optimal.

### 4.2 The primal bound: four vectors at $30^\circ$

**Theorem 4.2 (Explicit optimal factorization).** $\|T_2\|_{\gamma_2}\le 2\sqrt3/3$.

*Proof.* Let $c = 2\sqrt3/3$ and $r = \sqrt c$. In $\mathbb{R}^2$ set
$$ x_1 = (r,\,0), \qquad x_2 = \Bigl(\tfrac r2,\ \tfrac{r\sqrt3}{2}\Bigr), \qquad y_1 = \Bigl(\tfrac{r\sqrt3}{2},\ \tfrac r2\Bigr), \qquad y_2 = \Bigl(\tfrac{r\sqrt3}{2},\ -\tfrac r2\Bigr). $$
All four have length exactly $r$, i.e. squared norm exactly $c$; their arguments are $0^\circ, 60^\circ, 30^\circ, -30^\circ$ respectively, so the four vectors form a fan at consecutive $30^\circ$ intervals in the order $y_2, x_1, y_1, x_2$. Consequently
$$ \langle x_1,y_1\rangle = \langle x_1,y_2\rangle = \langle x_2,y_1\rangle = r^2\cos 30^\circ = c\cdot\tfrac{\sqrt3}{2} = \tfrac{2\sqrt3}{3}\cdot\tfrac{\sqrt3}{2} = 1, $$
while $x_2$ and $y_2$ are $90^\circ$ apart, so $\langle x_2,y_2\rangle = 0$. That is exactly $T_2$. $\square$

**Remark 4.3.** Two dimensions suffice; the configuration is rigid up to rotation and reflection, which is the geometric shadow of the uniqueness of the optimal semidefinite solution.

**Theorem 4.4 (Exact value).** For every real $c$, $\|T_2\|_{\gamma_2}\le c$ if and only if $c \ge 2\sqrt3/3$. In particular
$$ \left\|\begin{pmatrix}1&1\\1&0\end{pmatrix}\right\|_{\gamma_2} = \frac{2\sqrt3}{3} = \frac{2}{\sqrt3} = 1.15470\ldots $$

*Proof.* Necessity is Theorem 4.1 applied to $T_2$ itself; sufficiency is Theorem 4.2 plus monotonicity. $\square$

### 4.3 Non-rigidity produces the pattern

**Lemma 4.5.** If $A$ is boolean and not row rigid, then $A$ contains $T_2$ as a $2\times2$ submatrix: there are rows $i_1,i_2$ and columns $j_1,j_2$ with $A_{i_1j_1}=A_{i_1j_2}=A_{i_2j_1}=1$ and $A_{i_2j_2}=0$.

*Proof.* Failure of rigidity provides rows $i,i'$ and columns $j,j'$ with $A_{ij}=A_{i'j}=1$ and $A_{ij'}\ne A_{i'j'}$. Since $A$ is boolean, one of $A_{ij'},A_{i'j'}$ is $1$ and the other is $0$. If $A_{ij'}=1$ and $A_{i'j'}=0$, take $(i_1,i_2,j_1,j_2)=(i,i',j,j')$. Otherwise $A_{i'j'}=1$ and $A_{ij'}=0$, and we take $(i_1,i_2,j_1,j_2)=(i',i,j,j')$. $\square$

### 4.4 The gap

**Theorem 4.6 (Gap theorem).** Let $A$ be boolean with $\|A\|_{\gamma_2}\le c$ and $c < 2\sqrt3/3$. Then $A$ is a blow-up of a partial identity matrix; in particular $\|A\|_{\gamma_2}\le 1$.

*Proof.* By Theorem 3.6 it suffices to prove row rigidity. If rigidity failed, Lemma 4.5 would give a $T_2$ submatrix, and Theorem 4.1 would give $c \ge 2\sqrt3/3$, contradicting the hypothesis. $\square$

**Corollary 4.7 (Dichotomy).** For every boolean $A$ and every $c$ with $\|A\|_{\gamma_2}\le c$: either $\|A\|_{\gamma_2}\le 1$, or $c \ge 2\sqrt3/3$. Consequently
$$ \|A\|_{\gamma_2} \notin \left(1,\ \tfrac{2\sqrt3}{3}\right) \quad\text{for every boolean matrix } A \text{ of any size}. $$

**Corollary 4.8 (Sharpness).** $T_2$ is boolean, is not a blow-up, and has $\|T_2\|_{\gamma_2} = 2\sqrt3/3$. Hence the right endpoint of the gap is attained and the constant cannot be improved.

*Proof.* $T_2$ is not row rigid (rows $1$ and $2$ share a $1$ in column $1$ but differ in column $2$), hence not a blow-up by Theorem 3.6; the value is Theorem 4.4. $\square$

### 4.5 The next staircase

Let $T_3 = \begin{pmatrix}1&1&1\\1&1&0\\1&0&0\end{pmatrix}$, the $3$-staircase.

**Proposition 4.9.** $T_3$ is boolean, is not a blow-up, and
$$ \frac{2\sqrt3}{3} \;\le\; \|T_3\|_{\gamma_2} \;\le\; \sqrt3 . $$

*Proof.* Rows $2$ and $3$ both carry a $1$ in column $1$ but differ in column $2$, so $T_3$ is not row rigid and hence not a blow-up. The lower bound comes from the $T_2$ pattern on rows $\{2,3\}$ and columns $\{1,2\}$ together with Theorem 4.1. The upper bound is the general bound $\|A\|_{\gamma_2}\le\sqrt{\min(m,n)}$ of Proposition 6.2 with $m=n=3$. $\square$

The exact value of $\|T_3\|_{\gamma_2}$ is not determined here; see Section 8.

---

## 5. The algebra of blow-ups and of signed sums

Composition of Schur multipliers is entrywise multiplication of symbols: $S_A\circ S_B = S_{A\odot B}$. The class of cheap symbols should therefore be closed under $\odot$, and it is.

**Theorem 5.1 (Submultiplicativity).** For $A, B$ of the same shape and $c, d \ge 0$,
$$ \|A\|_{\gamma_2}\le c,\ \|B\|_{\gamma_2}\le d \implies \|A\odot B\|_{\gamma_2}\le cd. $$

*Proof.* Let $A_{ij}=\langle x_i,y_j\rangle$ in $\mathbb{R}^d$ with squared norms $\le c$ and $B_{ij} = \langle u_i,v_j\rangle$ in $\mathbb{R}^{d'}$ with squared norms $\le d$. Work in $\mathbb{R}^{d}\otimes\mathbb{R}^{d'}\cong\mathbb{R}^{dd'}$, indexed by pairs $(s,s')$, and set
$$ X_i := x_i\otimes u_i,\qquad Y_j := y_j\otimes v_j, \qquad (X_i)_{(s,s')} = (x_i)_s (u_i)_{s'} . $$
Then, by the product formula for sums over a product index set,
$$ \langle X_i, Y_j\rangle = \sum_{s,s'} (x_i)_s(u_i)_{s'}(y_j)_s(v_j)_{s'} = \Bigl(\sum_s (x_i)_s (y_j)_s\Bigr)\Bigl(\sum_{s'} (u_i)_{s'}(v_j)_{s'}\Bigr) = A_{ij}B_{ij}, $$
and $\|X_i\|^2 = \|x_i\|^2\|u_i\|^2 \le cd$, similarly for $Y_j$. $\square$

**Theorem 5.2 (Blow-ups are closed under $\odot$).** If $A$ and $B$ are blow-ups, so is $A\odot B$. Equivalently, *contractive idempotent Schur multipliers are closed under composition*.

*Proof.* Let $A_{ij}=\mathbf 1[f_1(i)=g_1(j)]$ and $B_{ij}=\mathbf 1[f_2(i)=g_2(j)]$. Define paired labels $F(i) := \langle f_1(i), f_2(i)\rangle$ and $G(j) := \langle g_1(j),g_2(j)\rangle$ using any injective pairing $\mathbb N^2\to\mathbb N$ (e.g. the Cantor pairing). Since the pairing is injective, $F(i)=G(j)$ iff $f_1(i)=g_1(j)$ *and* $f_2(i)=g_2(j)$, so
$$ (A\odot B)_{ij} = \mathbf 1[f_1(i)=g_1(j)]\cdot\mathbf 1[f_2(i)=g_2(j)] = \mathbf 1[F(i)=G(j)]. \qquad\square $$

Combining Theorem 5.2 with Corollary 3.7:

**Corollary 5.3.** If $S_A$ and $S_B$ are contractive idempotent Schur multipliers, then so is $S_{A\odot B}= S_A\circ S_B$.

**Definition 5.4 (Signed sum of blow-ups).** $A$ is a *signed sum of $L$ blow-ups*, written $A \in \mathcal B_L$, if there are blow-ups $B_1,\dots,B_L$ and signs $\varepsilon_1,\dots,\varepsilon_L\in\{\pm1\}$ with
$$ A_{ij} = \sum_{\ell=1}^L \varepsilon_\ell (B_\ell)_{ij}\quad\text{for all } i,j. $$

**Theorem 5.5 (Closure properties).** Let $A\in\mathcal B_{L_1}$ and $B\in\mathcal B_{L_2}$ (same shape). Then
1. $-A \in \mathcal B_{L_1}$;
2. $A + B \in \mathcal B_{L_1+L_2}$;
3. $A\odot B \in \mathcal B_{L_1L_2}$;
4. $\mathbf 1 - A \in \mathcal B_{L_1+1}$, where $\mathbf 1$ is the all-ones matrix;
5. $A\in\mathcal B_L \implies A\in\mathcal B_{L'}$ for all $L'\ge L$.

*Proof sketch.* (1) Flip all the signs. (2) Concatenate the two lists of blow-ups and of signs. (3) Expand the product of the two sums:
$$ A_{ij}B_{ij} = \sum_{\ell_1}\sum_{\ell_2} (\varepsilon_{\ell_1}\varepsilon'_{\ell_2})\,(B_{\ell_1}\odot B'_{\ell_2})_{ij}, $$
which is a sum over the $L_1L_2$ pairs; each $B_{\ell_1}\odot B'_{\ell_2}$ is a blow-up by Theorem 5.2, and each $\varepsilon_{\ell_1}\varepsilon'_{\ell_2}\in\{\pm1\}$. (4) The all-ones matrix is a blow-up (all labels $0$), so $\mathbf1 - A = \mathbf 1 + (-A) \in \mathcal B_{1+L_1}$ by (1) and (2). (5) The zero matrix is a blow-up (give row $i$ the label $i$ and column $j$ the label $n+m+j$, so no labels ever match); padding a decomposition with copies of $+0$ raises $L$ by one at a time. $\square$

Thus $\bigcup_L \mathcal B_L$ is a subring of the matrices under entrywise operations, containing $\mathbf 0$ and $\mathbf 1$ and closed under complementation, and the minimal number of terms behaves like a degree: subadditive under $+$, submultiplicative under $\odot$, invariant under $-$.

---

## 6. The blow-up number and equality queries

**Definition 6.1 (Blow-up number).** For a matrix $A$,
$$ \mathrm{eq}(A) := \min\{\,L \in \mathbb N : A\in\mathcal B_L\,\}, $$
the least number of blow-ups in a signed decomposition (and $0$ by convention if no decomposition exists, which never happens for boolean $A$).

**Proposition 6.2 (Universal upper bounds).** Let $A$ be a boolean $m\times n$ matrix. Then
$$ A\in\mathcal B_m, \qquad \mathrm{eq}(A)\le \min(m,n), \qquad \|A\|_{\gamma_2}\le \sqrt{\min(m,n)}. $$

*Proof sketch.* For the first: for each row index $\ell$, let $B_\ell$ be the matrix that agrees with $A$ on row $\ell$ and is zero elsewhere. Each $B_\ell$ is a blow-up — label row $\ell$ and every column $j$ with $A_{\ell j}=1$ by a common tag, and give all other rows and columns pairwise-distinct fresh tags — and $A = \sum_\ell B_\ell$ with all signs $+1$. Transposing gives $\mathcal B_n$. For the norm bound, put $x_i = e_i\in\mathbb R^m$ (squared norm $1 \le \sqrt m$ as soon as $m\ge1$) and $y_j = $ the $j$-th column of $A$ (squared norm $\le m$); the unbalanced product is $1\cdot\sqrt m$, and Proposition 2.3 balances it. Transposing gives $\sqrt n$. $\square$

**Proposition 6.3 (Norm below cost).** For boolean $A$, $\|A\|_{\gamma_2}\le \mathrm{eq}(A)$.

*Proof.* By Proposition 6.2 the set of admissible $L$ is nonempty, so the minimum is attained: $A = \sum_{\ell\le L}\varepsilon_\ell B_\ell$ with $L = \mathrm{eq}(A)$. Each $\varepsilon_\ell B_\ell$ has $\gamma_2$-norm at most $1$ (Proposition 3.4 and negation-invariance), and subadditivity (Proposition 2.4(4)) gives $\|A\|_{\gamma_2}\le L$. $\square$

This is the *easy direction* of Conjecture A: few blow-ups implies small norm. The conjecture is the converse.

**Proposition 6.4 (The unit level).** For boolean $A$: $\mathrm{eq}(A)\le 1$ if and only if $A$ is a blow-up.

*Proof sketch.* If $A$ is a blow-up then trivially $A\in\mathcal B_1$. Conversely if $A = \varepsilon B$ with $B$ a blow-up: for $\varepsilon = +1$ we are done; for $\varepsilon = -1$, $A$ and $B$ are both boolean and $A = -B$ forces $A = B = \mathbf 0$, and the zero matrix is a blow-up. $\square$

**Theorem 6.5 (Equality-query form).** For any matrix $A$ and any $L$, the following are equivalent:
1. $A \in \mathcal B_L$;
2. there exist labellings $f_1,\dots,f_L : [m]\to\mathbb N$, $g_1,\dots,g_L : [n]\to\mathbb N$ and signs $\varepsilon_\ell\in\{\pm1\}$ with
$$ A_{ij} = \sum_{\ell=1}^L \varepsilon_\ell\,\mathbf 1[\,f_\ell(i)=g_\ell(j)\,] \quad\text{for all } i,j. $$

*Proof.* Immediate by unwinding Definition 3.1 inside Definition 5.4: a family of blow-ups *is* a family of pairs of labellings, and conversely each indicator $\mathbf 1[f_\ell(i)=g_\ell(j)]$ is a blow-up. $\square$

Statement (2) is a *communication protocol*: Alice, holding $i$, and Bob, holding $j$, each compute $L$ labels; the value $A_{ij}$ is a signed tally of $L$ equality tests. Since equality has constant cost in the standard randomized model (and is the canonical oracle in the class $\mathrm{P}^{\mathrm{EQ}}$ of problems solvable with polylogarithmically many equality queries), a bound $\mathrm{eq}(A)\le L(\gamma)$ that is uniform in the dimensions places every family of bounded factorization norm in $\mathrm{P}^{\mathrm{EQ}}$. Conversely $\mathrm{eq}$ is exactly the quantity the conjecture asks to bound, so $\mathrm{eq}$ deserves the name *equality cost*.

**Corollary 6.6 (Every boolean matrix is computed by $m$ equality queries).** For boolean $m\times n$ $A$ there are $f_\ell : [m]\to\mathbb N$, $g_\ell:[n]\to\mathbb N$ and signs $\varepsilon_\ell$, $\ell = 1,\dots,m$, with $A_{ij} = \sum_\ell \varepsilon_\ell\mathbf 1[f_\ell(i)=g_\ell(j)]$ (in fact all $\varepsilon_\ell = +1$).

Finally, the conjecture at the bottom of the range:

**Definition 6.7 (The conjecture, formally).**
$$ \forall \gamma\ \exists L\ \forall m,n\ \forall A \text{ boolean } m\times n:\quad \|A\|_{\gamma_2}\le\gamma \implies \mathrm{eq}(A)\le L. $$

**Theorem 6.8 (The conjecture below the gap, with $L=1$).** Let $\gamma < 2\sqrt3/3$. Then for all $m,n$ and every boolean $m\times n$ matrix $A$,
$$ \|A\|_{\gamma_2}\le \gamma \implies \mathrm{eq}(A)\le 1, $$
i.e. $A$ is a single blow-up of a partial identity matrix.

*Proof.* By the gap theorem (Theorem 4.6), $A$ is a blow-up; by Proposition 6.4, $\mathrm{eq}(A)\le1$. $\square$

The content of Theorem 6.8 is the *uniformity*: the bound $L=1$ holds for all sizes simultaneously, with no $\log^* n$ correction, and with the optimal threshold $\gamma < 2\sqrt3/3$ (optimal because $T_2$ has norm exactly $2\sqrt3/3$ and $\mathrm{eq}(T_2) = 2$: it is not a blow-up, and it is the sum of two blow-ups, e.g. the all-ones matrix minus the blow-up supported on the single cell $(2,2)$).

---

## 7. Algorithms

Three computational tasks arise naturally.

### 7.1 Deciding the contractive case, and recovering the labels

Theorem 3.6 makes "$\|A\|_{\gamma_2}\le 1$?" decidable in polynomial time, without any numerical optimization.

**Algorithm (Rigidity test and label extraction).** Given boolean $A$ of size $m\times n$:
1. For each column $j$, list the rows $i$ with $A_{ij}=1$.
2. For each such column and each pair of listed rows, check that the two rows are identical; if any check fails, output a witnessing $T_2$ pattern and halt with "$\|A\|_{\gamma_2}\ge 2\sqrt3/3$".
3. Otherwise, set $f(i) = \min\{j : A_{ij}=1\}$ (or a fresh tag if the row is zero), and $g(j) = f(i_0)$ for any row $i_0$ with $A_{i_0j}=1$ (or a fresh tag if the column is zero).
4. Output the labels; they satisfy $A_{ij}=\mathbf 1[f(i)=g(j)]$, exhibiting $A$ as a blow-up and certifying $\|A\|_{\gamma_2}\le 1$.

A naive implementation of step 2 costs $O(m^2n)$; grouping rows by their bit-patterns via hashing (or sorting) reduces the test to $O(mn)$ expected time: rigidity holds iff, for every column $j$, all rows hitting $j$ fall into a single pattern class. Note that the algorithm is *self-certifying*: on failure it returns the explicit $2\times2$ pattern which, by Theorem 4.1, is a proof of the lower bound $2\sqrt3/3$; on success it returns the labels, which are a proof of the upper bound $1$. There is no gap between the two outputs — which is precisely the content of Theorem 4.6.

### 7.2 Row decomposition into blow-ups

**Algorithm (Row decomposition).** Given boolean $A$, output $B_1,\dots,B_m$ with $A = \sum_\ell B_\ell$, each $B_\ell$ a blow-up: take $B_\ell$ to be $A$ restricted to row $\ell$. In labels: $f_\ell(\ell) = 0$, $f_\ell(i) = 1+i$ for $i \ne \ell$, and $g_\ell(j) = 0$ if $A_{\ell j}=1$, else a fresh tag. Cost $O(mn)$; the count $m$ is generally far from optimal but establishes $\mathrm{eq}(A)\le m$ and hence $\|A\|_{\gamma_2}\le m$ unconditionally (the sharper $\sqrt{\min(m,n)}$ comes from the direct factorization).

### 7.3 Numerical evaluation of the factorization norm

$\|A\|_{\gamma_2}$ is the value of a semidefinite program: minimize $c$ subject to the existence of a positive semidefinite Gram matrix
$$ G = \begin{pmatrix} P & A\\ A^{\mathsf T} & Q\end{pmatrix} \succeq 0, \qquad P_{ii}\le c,\quad Q_{jj}\le c, $$
where $P$ is the Gram matrix of the $x_i$, $Q$ that of the $y_j$, and the off-diagonal block is forced to equal $A$. Any feasible $G$ yields a factorization by Cholesky, and conversely. A simple practical surrogate, adequate for small matrices, is projected alternating minimization on the vectors $x_i, y_j$ directly; for $2\times2$ and $3\times3$ patterns one can also parametrize the Gram matrix by its few free entries and optimize by grid refinement. Both approaches confirm the exact value $2\sqrt3/3$ for $T_2$ and place $\|T_3\|_{\gamma_2}$ near $1.4$–$1.5$ without pinning it down.

---

## 8. Discussion and future directions

### 8.1 What the gap says

The results above identify a *hard floor* in the analytic hierarchy of idempotent Schur multipliers. The set
$$ \Gamma := \{\,\|A\|_{\gamma_2} : A \text{ boolean, any size}\,\} \subseteq [0,\infty) $$
contains $0$ and $1$, omits the entire interval $(1,2\sqrt3/3)$, and contains $2\sqrt3/3$. Above the gap, $\Gamma$ certainly becomes rich — $\|A\|_{\gamma_2}$ grows like $\sqrt{\log n}$ for random boolean matrices and can be as large as $\Theta(\sqrt n)$ — but near the bottom it is discrete, and the discreteness is *caused by a forbidden pattern*: crossing the threshold requires embedding a $2$-staircase, and the $2$-staircase costs exactly $2\sqrt3/3$.

This is a template. Every lower bound of the form "pattern $P$ forces $\|A\|_{\gamma_2}\ge \kappa_P$" combines with a structure theorem "no copy of $P$ implies a normal form" to produce a gap. The pair of certificates that establishes $\kappa_{T_2} = 2\sqrt3/3$ — an explicit vector configuration on the primal side, an explicit weighted sum of squares on the dual side — is exactly what one needs to make such a scheme quantitative, and it transfers to larger patterns whose semidefinite programs still have few free parameters.

### 8.2 Relation to the general conjecture

The general conjecture asks for $\mathrm{eq}(A) \le L(\gamma)$ whenever $\|A\|_{\gamma_2}\le\gamma$, uniformly in the dimensions. Known bounds are $L = 2^{O(\gamma^9)+\log^* n}$. Theorem 6.8 gives the exact optimal statement in the range $\gamma < 2\sqrt3/3$, where $L(\gamma) = 1$; and Proposition 6.3 gives the converse inequality $\|A\|_{\gamma_2}\le \mathrm{eq}(A)$ in complete generality. Hence
$$ \mathrm{eq}(A)\le 1 \iff \|A\|_{\gamma_2}\le1, \qquad \text{and} \qquad \mathrm{eq}(A)\ge 2 \implies \|A\|_{\gamma_2}\ge \tfrac{2\sqrt3}{3}. $$
The second implication is the first quantitative instance of the conjecture read backwards: needing a second equality query costs a definite amount of norm.

The closure properties of Section 5 say that the object being bounded, $\mathrm{eq}$, is a well-behaved complexity measure — subadditive, submultiplicative, complement-stable — matching the corresponding properties of $\|\cdot\|_{\gamma_2}$ (subadditive, submultiplicative, and complement-stable up to an additive $1$). Any eventual proof of the conjecture must be compatible with this parallel structure, and one plausible route is to build the bound $L(\gamma)$ inductively using exactly these operations.

### 8.3 Future directions

*(The following directions arose directly from the development above.)*

**Conjecture 1 (a second gap).** The set of factorization norms of boolean matrices is discrete near its bottom: after $1$ and $2\sqrt3/3$, the next attained value is $\|T_3\|_{\gamma_2}$, where
$$ T_3 = \begin{pmatrix}1&1&1\\1&1&0\\1&0&0\end{pmatrix}, $$
and no boolean matrix has norm strictly between $2\sqrt3/3$ and $\|T_3\|_{\gamma_2}$.

Crude numerical searches place $\|T_3\|_{\gamma_2}$ somewhere in the range $1.40$–$1.48$; two independent searches disagreed, so no numerical value is claimed — pinning it down exactly is part of the conjecture. The key insight is that the gap proof reduces to a *pattern-containment* statement: a boolean matrix of norm $<2\sqrt3/3$ contains no $2$-staircase, and the same forbidden-pattern reduction should turn "norm $<\|T_3\|_{\gamma_2}$" into "contains no $3$-staircase", after which the finitely many staircase-free structures can be classified exactly as row rigidity classifies the $2$-staircase-free case. Why now: the $2$-staircase case is fully settled here, both the primal factorization and the dual sum-of-squares certificate; the same two-sided scheme (an explicit $k$-dimensional vector configuration versus an explicit sum-of-squares certificate coming from the dual semidefinite program) transfers verbatim to $T_3$, whose semidefinite program has only six free Gram parameters.

**Conjecture 2 (staircase growth is the only obstruction).** For boolean $A$, $\|A\|_{\gamma_2}\le\gamma$ implies that $A$ contains no staircase of length $k > 2^{O(\gamma^2)}$; and conversely a boolean matrix with no staircase of length $k$ satisfies $\|A\|_{\gamma_2}\le f(k)$ for an explicit $f$.

The key insight is that row rigidity — the condition characterizing $\gamma_2\le1$ — is exactly "no staircase of length $2$", so the whole conjecture on idempotent Schur multipliers may be a statement about a forbidden-pattern hierarchy rather than about norms. Why now: the case $k=2$ is proved here in both directions (blow-up $\iff$ row rigid, and the sharp norm of the $2$-staircase).

**Further questions.**
- *Exact values of $\mathrm{eq}$.* The row decomposition gives $\mathrm{eq}(T_k)\le k$, but this is far from optimal already at $k=3$: one checks directly that
$$ T_3 = \mathbf 1[f_1(i)=g_1(j)] + \mathbf 1[f_2(i)=g_2(j)], \qquad f_1 = (0,1,0),\ g_1=(0,1,2),\quad f_2=(0,1,2),\ g_2=(1,0,0), $$
so $\mathrm{eq}(T_3) = 2$ (it is at least $2$ because $T_3$ is not a blow-up). What, then, is the growth of $\max\{\mathrm{eq}(T_k)\}$, and more importantly of $\max\{\mathrm{eq}(A) : \|A\|_{\gamma_2}\le\gamma\}$? Exhibiting *any* family forcing $L(\gamma)\to\infty$ would be the first genuine lower bound in the conjecture.
- *Complement asymmetry.* $\mathrm{eq}(\mathbf 1 - A)\le \mathrm{eq}(A)+1$ is tight in trivial cases; how does $\|\cdot\|_{\gamma_2}$ of a complement compare in general?
- *Optimality of submultiplicativity.* Is $\mathrm{eq}(A\odot B) = \mathrm{eq}(A)\mathrm{eq}(B)$ ever forced, or does cancellation always help?
- *Beyond $\pm1$ coefficients.* Allowing integer coefficients $|\varepsilon_\ell|\le M$ in the decomposition trades the number of terms against coefficient size; the correct trade-off curve is unknown even for staircases.

---

## 9. Summary of results

| Statement | Content |
|---|---|
| Characterization of contractive idempotents | For boolean $A$: $\|A\|_{\gamma_2}\le 1 \iff A$ is a blow-up of a partial identity $\iff A$ is row rigid |
| Composition | The Hadamard product of two blow-ups is a blow-up; contractive idempotent Schur multipliers are closed under composition |
| Submultiplicativity | $\|A\odot B\|_{\gamma_2}\le\|A\|_{\gamma_2}\|B\|_{\gamma_2}$ |
| Closure of $\mathcal B_L$ | $\mathcal B_{L_1}+\mathcal B_{L_2}\subseteq\mathcal B_{L_1+L_2}$; $-\mathcal B_L = \mathcal B_L$; $\mathcal B_{L_1}\odot\mathcal B_{L_2}\subseteq\mathcal B_{L_1L_2}$; $\mathbf1-\mathcal B_L\subseteq\mathcal B_{L+1}$ |
| Easy direction | $A\in\mathcal B_L \implies \|A\|_{\gamma_2}\le L$; hence $\|A\|_{\gamma_2}\le\mathrm{eq}(A)$ |
| Universal bounds | Every boolean $m\times n$ matrix has $\mathrm{eq}(A)\le\min(m,n)$ and $\|A\|_{\gamma_2}\le\sqrt{\min(m,n)}$ |
| Exact norm | $\|T_2\|_{\gamma_2} = 2\sqrt3/3$, with a planar $30^\circ$ factorization and a two-term sum-of-squares dual certificate |
| Gap theorem | No boolean matrix has $\|A\|_{\gamma_2}\in(1,2\sqrt3/3)$; the endpoint is attained by $T_2$ |
| Equality queries | $A\in\mathcal B_L$ iff $A_{ij} = \sum_\ell\varepsilon_\ell\mathbf1[f_\ell(i)=g_\ell(j)]$ |
| Conjecture below the gap | For every $\gamma<2\sqrt3/3$ and all sizes: $\|A\|_{\gamma_2}\le\gamma \implies \mathrm{eq}(A)\le1$ |
| The next staircase | $2\sqrt3/3\le\|T_3\|_{\gamma_2}\le\sqrt3$, and $T_3$ is not a blow-up |
