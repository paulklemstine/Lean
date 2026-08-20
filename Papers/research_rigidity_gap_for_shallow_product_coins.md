# A Rigidity Gap for Shallow Product Coins

**Author:** Aristotle
**Date:** 2026-08-20

---

## Abstract

Let $A$ and $B$ be finite sets and let $R \subseteq A \times B$ be a *resonance set*. A **coin** on a finite register is an $\ell^2$-normalised complex amplitude vector, and the **resonance amplitude** of the product coin $f \otimes g$ is $\mathcal{A}(f,g)=\sum_{(a,b)\in R} f(a)g(b)$. Cauchy–Schwarz gives the universal bound $|\mathcal{A}(f,g)|^2 \le |R|$, with equality forcing the product coin to be the normalised indicator of $R$. We prove a *quantitative* converse: if $R$ is not a combinatorial box (a product set $A_0\times B_0$), then every product coin satisfies
$$|\mathcal{A}(f,g)|^2\,(3|R|+1) \;\le\; 3|R|^2, \qquad\text{i.e.}\qquad |\mathcal{A}(f,g)|^2 \le \Bigl(1-\tfrac{1}{3|R|+1}\Bigr)|R|,$$
and consequently the depth-, alphabet- and size-uniform additive bound $|\mathcal{A}(f,g)|^2 \le |R| - \tfrac27$. Combined with the fact that boxes attain the optimum, this yields an exact dichotomy: the Cauchy–Schwarz optimum is attained by a product coin if and only if $R$ is a box. The bipartite statement transports to arbitrary depth $n$ by splitting the word space at a single register: if a resonance set of $n$-letter words fails to be a box along one register, then *every* fully unentangled depth-$n$ coin loses at least $2/7$ of the optimum, with a constant independent of $n$ and of the alphabet sizes. We complement the theorem with sharpness data: the extremal constant for the smallest non-box set — the L-shape $\{(0,0),(0,1),(1,0)\}$ — is governed by the golden ratio, $\sup|\mathcal{A}|^2 = \varphi^2 = (3+\sqrt5)/2$, giving the bracket $\tfrac27 = 0.2857\ldots \le c^\ast \le 0.3820322\ldots$ for the optimal universal additive constant, a factor $1.34$. A matching combinatorial lower bound shows $\max_a |R_a| \le \sup |\mathcal{A}|^2$. The entire argument is elementary: one vanishing $2\times 2$ minor, one distance identity, and one four-variable inequality; no singular value theory is used.

**Keywords.** product state, rank-one approximation, combinatorial rectangle, rigidity, Cauchy–Schwarz deficiency, golden ratio, quantum coin, unentangled state.

---

## 1. Introduction

### 1.1 The problem

A recurring pattern across computation, quantum information and approximation theory is the following. A device is assembled from independent components; the states it can prepare are therefore *products*. A target is specified; the target need not respect the factorisation. How well can the device match the target, and what exactly obstructs a perfect match?

In its most economical form the question is bipartite. Fix finite sets $A$, $B$ (the letters available to two **registers**) and a set $R \subseteq A\times B$ of **resonant** pairs. A **coin** on $A$ is an amplitude vector $f : A \to \mathbb{C}$ with $\sum_{a} |f(a)|^2 = 1$; similarly on $B$. The **product coin** $f \otimes g$ is the state on $A \times B$ with amplitude $f(a)g(b)$, and its **resonance amplitude** is
$$\mathcal{A}(f,g) \;=\; \sum_{(a,b)\in R} f(a)\,g(b).$$

Since $f\otimes g$ is a unit vector in $\mathbb{C}^{A\times B}$ and the indicator $\mathbf{1}_R$ has $\ell^2$ norm $\sqrt{|R|}$, Cauchy–Schwarz yields
$$|\mathcal{A}(f,g)|^2 \;\le\; |R| \tag{1.1}$$
for every product coin. Equality in (1.1) requires $f\otimes g$ to be a positive multiple of $\mathbf{1}_R$; that is, $f(a)g(b)$ must be constant on $R$ and vanish off it.

A product is a rank-one matrix, and a rank-one matrix has no nonzero $2\times2$ minor. The indicator of a set that is not a combinatorial rectangle does have one. So equality in (1.1) is *impossible* for such sets. That is the qualitative statement, and it is the starting point rather than the destination: non-attainment of a supremum says nothing about how closely the supremum can be approached. The purpose of this paper is to replace non-attainment by an explicit, uniform *budget*.

### 1.2 Results

Our main theorem is a rigidity gap. Write $|R|$ for the cardinality of the resonance set.

> **Main Theorem.** Let $R\subseteq A\times B$ contain two elements $(a,b)$ and $(a',b')$ whose crossover $(a,b')$ is not in $R$. Then every product coin $f\otimes g$ satisfies
> $$|\mathcal{A}(f,g)|^2 \cdot (3|R|+1) \;\le\; 3|R|^2 ,$$
> and hence $|\mathcal{A}(f,g)|^2 \le |R| - \tfrac{2}{7}$.

The additive constant $2/7$ is uniform: it does not degrade with $|A|$, $|B|$, $|R|$, or (after the reduction of §4) with the number of registers.

Four further results round out the picture:

1. **Dichotomy.** For a nonempty $R$, the optimum $|R|$ in (1.1) is attained by *some* product coin if and only if $R$ is a box, i.e. $R = A_0\times B_0$.
2. **Depth-$n$ transport.** If a set $R$ of $n$-letter words fails to be a box along a single register $i_0$, every fully unentangled depth-$n$ coin obeys the same bound with the same constants; conversely, a genuine product $S_1\times\cdots\times S_n$ of letter sets is optimally resonated by the uniform depth-$n$ product coin.
3. **Sharpness bracket.** The optimal universal additive constant $c^\ast$ satisfies $\tfrac27 \le c^\ast \le 3014418/7890481 = 0.3820322\ldots$, the upper bound coming from an exactly rational near-golden coin on the L-shape.
4. **Combinatorial lower bound.** For every $a$, the row $R_a = \{b : (a,b) \in R\}$ is achievable: some product coin attains $|\mathcal{A}|^2 = |R_a|$ exactly. Hence $\max_a |R_a| \le \sup|\mathcal{A}|^2 \le 3|R|^2/(3|R|+1)$.

### 1.3 Spectral dictionary

Although no spectral theory is used in any proof, it is worth recording the translation, since it explains why the statements take the form they do. Identify $R$ with its $0/1$ matrix $M \in \{0,1\}^{A\times B}$. Then
$$\sup_{\|f\|=\|g\|=1} |\mathcal{A}(f,g)| \;=\; \sigma_1(M), \qquad |R| \;=\; \|M\|_F^2 \;=\; \sum_i \sigma_i(M)^2 ,$$
where $\sigma_1 \ge \sigma_2 \ge \cdots$ are the singular values. Bound (1.1) is the triviality $\sigma_1^2 \le \sum_i \sigma_i^2$; equality means $\operatorname{rank}M = 1$, which for a $0/1$ matrix is exactly the box condition. The Main Theorem therefore says: *a $0/1$ matrix that is not a combinatorial rectangle keeps at least $2/7$ of its Frobenius energy outside the top singular direction.* The extremal example, the L-shape matrix $\begin{pmatrix}1&1\\1&0\end{pmatrix}$, has eigenvalues $\varphi$ and $-1/\varphi$ — whence the golden ratio in §5.

### 1.4 Method

The proof avoids all spectral machinery and rests on three elementary steps.

* **Modulus reduction.** Replace $f\otimes g$ by the nonnegative rank-one vector $u(a,b)=|f(a)|\,|g(b)|$. It is still normalised and $|\mathcal{A}(f,g)| \le \sum_{x\in R} u(x)=:T$.
* **A distance identity.** With $m=|R|$ and $\mu = T/m$,
 $$\sum_{x\in A\times B}\bigl(u(x)-\mu\mathbf 1_R(x)\bigr)^2 \;=\; 1-\frac{T^2}{m}. \tag{1.2}$$
 Thus $T^2$ is near $m$ exactly when $u$ is near a multiple of $\mathbf 1_R$: the loudness deficiency *is* the squared distance to the indicator line.
* **A minor obstruction.** At the four corners of the offending rectangle, $u$ has a vanishing $2\times2$ minor while $\mu \mathbf 1_R$ has minor $\mu^2$. A four-variable inequality (Lemma 3.1) converts this discrepancy into $\mu^2 \le 3\sum e_{ij}^2$, where the $e_{ij}$ are the corner deviations. Since the four corners are distinct, $\sum e_{ij}^2 \le 1 - T^2/m$ by (1.2), and rearranging gives the theorem.

### 1.5 Related contexts

The box/non-box dichotomy is the combinatorial rectangle dichotomy of communication complexity: a deterministic one-round protocol partitions the input space into rectangles, and lower bounds are proved by showing a target is far from rectangular. The rigidity gap gives a *metric* form of non-rectangularity in the $\ell^2$ geometry. In quantum information, product coins are unentangled pure states and the theorem bounds the fidelity of any product state with an entangled "indicator" target away from $1$, uniformly in the number of subsystems. In approximation theory it is a statement about the unavoidable error of rank-one (separable) approximation to non-separable $0/1$ templates. We stress that the constant $2/7$ obtained here is uniform in all structural parameters, which is what distinguishes a rigidity statement from an ordinary non-attainment argument.

---

## 2. Definitions and elementary facts

Throughout, $A$ and $B$ are nonempty finite sets.

**Definition 2.1 (Coin).** A function $f : A \to \mathbb{C}$ is a **coin** if $\sum_{a\in A}|f(a)|^2 = 1$.

**Definition 2.2 (Resonance set, resonance amplitude).** A **resonance set** is a subset $R\subseteq A\times B$. For coins $f$ on $A$ and $g$ on $B$, the **resonance amplitude** of the product coin $f \otimes g$ is
$$\mathcal{A}(f,g) \;=\; \sum_{(a,b)\in R} f(a)g(b) .$$
We call $|\mathcal{A}(f,g)|^2$ the **resonance intensity**.

**Definition 2.3 (Box).** $R$ is a **box** if for all $x,y \in R$ we have $(x_1,y_2) \in R$; that is, $R$ is closed under recombining the first coordinate of one element with the second coordinate of another.

**Lemma 2.4 (Boxes are products).** $R$ is a box if and only if $R = \pi_1(R) \times \pi_2(R)$, where $\pi_1,\pi_2$ are the coordinate projections. Consequently the boxes are exactly the sets of the form $A_0\times B_0$.

*Proof.* If $R$ is a box and $(a,b) \in \pi_1(R)\times\pi_2(R)$, pick $y,z\in R$ with $y_1=a$, $z_2=b$; the box property gives $(a,b)=(y_1,z_2)\in R$. The inclusion $R \subseteq \pi_1(R)\times\pi_2(R)$ is automatic, and any product set is trivially closed under recombination. $\square$

**Proposition 2.5 (Cauchy–Schwarz bound).** For all coins $f,g$,
$$|\mathcal{A}(f,g)|^2 \;\le\; |R| .$$

*Proof.* Put $p(a)=|f(a)|$, $q(b)=|g(b)|$. The triangle inequality gives $|\mathcal{A}(f,g)| \le \sum_{x\in R} p(x_1)q(x_2)$. By Cauchy–Schwarz on the $|R|$ summands,
$$\Bigl(\sum_{x\in R}p(x_1)q(x_2)\Bigr)^2 \le |R|\sum_{x\in R}\bigl(p(x_1)q(x_2)\bigr)^2 \le |R|\sum_{x\in A\times B}\bigl(p(x_1)q(x_2)\bigr)^2 = |R|,$$
using that $\sum_{a,b} p(a)^2q(b)^2 = \bigl(\sum_a p(a)^2\bigr)\bigl(\sum_b q(b)^2\bigr) = 1$. $\square$

**Lemma 2.6 (Product normalisation).** If $\sum_a p(a)^2 = \sum_b q(b)^2 = 1$ then $\sum_{(a,b)} (p(a)q(b))^2 = 1$. (Immediate from the product formula for double sums; used repeatedly.)

**Proposition 2.7 (Boxes attain the optimum).** If $R = A_0\times B_0$ is a nonempty box, define $f = |A_0|^{-1/2}\mathbf 1_{A_0}$ and $g = |B_0|^{-1/2}\mathbf 1_{B_0}$. These are coins, and
$$\mathcal{A}(f,g) = \Bigl(\sum_{a\in A_0} f(a)\Bigr)\Bigl(\sum_{b\in B_0} g(b)\Bigr) = \sqrt{|A_0|}\,\sqrt{|B_0|}, \qquad |\mathcal{A}(f,g)|^2 = |A_0||B_0| = |R| .$$

*Proof.* The amplitude against a product set factorises, $\mathcal{A}(f,g) = \bigl(\sum_{a\in A_0}f(a)\bigr)\bigl(\sum_{b\in B_0}g(b)\bigr)$, by Fubini for finite sums; the uniform coin has $\sum_{a \in A_0} f(a) = |A_0|\cdot|A_0|^{-1/2}=\sqrt{|A_0|}$. $\square$

---

## 3. The bipartite rigidity gap

### 3.1 The algebraic core

**Lemma 3.1 (Rank-one minor inequality).** Let $\mu, c, e_{11}, e_{12}, e_{21}, e_{22}$ be real numbers with $\mu \ge 0$, $e_{12}\ge 0$, $c \le 1$, satisfying
$$\mu^2 + \mu(e_{11}+e_{22}) + e_{11}e_{22} - \mu\,c\,e_{12} - e_{12}e_{21} \;=\; 0. \tag{3.1}$$
Then
$$\mu^2 \;\le\; 3\bigl(e_{11}^2+e_{12}^2+e_{21}^2+e_{22}^2\bigr).$$

*Proof sketch.* Identity (3.1) is the statement $(\mu+e_{11})(\mu+e_{22}) = (0+e_{12})(\mu c+e_{21})$, i.e. the vanishing of the $2\times2$ minor of a rank-one array whose entries deviate from the pattern $\begin{pmatrix}\mu & 0\\ \mu c & \mu\end{pmatrix}$ by $e_{11},e_{12},e_{21},e_{22}$. The pattern's own minor equals $\mu^2 - 0 = \mu^2$, so the deviations must "pay" for $\mu^2$, and one expects a bound of the form $\mu^2 \lesssim \sum e_{ij}^2$. Quantitatively, substitute (3.1) to write $\mu^2 = -\mu(e_{11}+e_{22}) - e_{11}e_{22} + \mu c e_{12} + e_{12}e_{21}$ and bound each term by a positive combination of $\mu^2/3$ and squares of the $e_{ij}$, using $\mu \ge 0$, $e_{12} \ge 0$ and $c\le1$ to control the sign of the cross term $\mu c e_{12} \le \mu e_{12}$. Concretely, the inequality follows from a positive-combination certificate built from the squares
$$(\mu+e_{11}+e_{22})^2,\quad (e_{11}-e_{22})^2,\quad (e_{12}-e_{21})^2,\quad (\mu-2e_{12})^2,\quad (\mu+2e_{11})^2,\quad (\mu+2e_{22})^2, \quad (e_{11}+e_{22}+e_{12})^2$$
together with the nonnegative products $\mu e_{12} \ge 0$ and $\mu e_{12}(1-c) \ge 0$. $\square$

**Remark 3.2 (Optimal constant in Lemma 3.1).** The constant $3$ is a convenient rational relaxation. Optimising (3.1) under the stated sign constraints returns the extremal ratio $\varphi^2 = (3+\sqrt5)/2 = 2.618\ldots$, i.e. the sharp form of the lemma is $\mu^2 \le \varphi^2\sum e_{ij}^2$; the extremiser is the golden configuration that reappears in §5 as the optimal coin for the L-shape. Every improvement of the constant in Lemma 3.1 propagates verbatim to the constants in Theorem 3.4 below.

**Lemma 3.3 (Four corners).** Let $F : A\times B\to\mathbb{R}_{\ge0}$, and let $a \ne a'$ in $A$, $b\ne b'$ in $B$. Then
$$F(a,b)+F(a,b')+F(a',b)+F(a',b') \;\le\; \sum_{x\in A\times B}F(x).$$

*Proof.* The four listed points are pairwise distinct, so they form a subset of $A\times B$ of size $4$, and dropping the remaining (nonnegative) summands only decreases the total. $\square$

### 3.2 The gap for nonnegative rank-one vectors

**Theorem 3.4 (Core gap).** Let $u : A\times B \to \mathbb{R}_{\ge0}$ satisfy $\sum_{x} u(x)^2 = 1$ and let one $2\times2$ minor of $u$ vanish:
$$u(a,b)\,u(a',b') = u(a,b')\,u(a',b)$$
for some $a,a',b,b'$ with $(a,b)\in R$, $(a',b')\in R$, $(a,b')\notin R$. Then
$$\Bigl(\sum_{x\in R}u(x)\Bigr)^2 (3|R|+1) \;\le\; 3|R|^2 .$$

*Proof.* First, $a\ne a'$ (else $(a,b')=(a',b')\in R$) and $b\ne b'$ (else $(a,b')=(a,b)\in R$), so the four corners are pairwise distinct. Set
$$m = |R| \ge 2, \qquad T = \sum_{x\in R} u(x) \ge 0, \qquad \mu = T/m \ge 0, \qquad \mathbf 1_R(x) = [x \in R].$$

*Step 1: the distance identity (1.2).* Expanding pointwise,
$$\bigl(u(x)-\mu\mathbf 1_R(x)\bigr)^2 = u(x)^2 - 2\mu\,u(x)\mathbf 1_R(x) + \mu^2\mathbf 1_R(x),$$
and summing over all $x\in A\times B$ using $\sum_x u(x)^2=1$, $\sum_x u(x)\mathbf 1_R(x) = T$, $\sum_x \mathbf 1_R(x)=m$:
$$D \;:=\; \sum_{x\in A\times B}\bigl(u(x)-\mu \mathbf 1_R(x)\bigr)^2 \;=\; 1 - 2\mu T + \mu^2 m \;=\; 1 - \frac{T^2}{m}. $$

*Step 2: corner deviations.* Put
$$e_{11}=u(a,b)-\mu, \quad e_{12}=u(a,b')-0 = u(a,b'), \quad e_{21}=u(a',b)-\mu c, \quad e_{22}=u(a',b')-\mu,$$
where $c = \mathbf 1_R(a',b) \in\{0,1\}$, so $c \le 1$; note $\mathbf 1_R(a,b)=\mathbf 1_R(a',b')=1$ and $\mathbf 1_R(a,b')=0$, which is why the $\mu$-shifts take the displayed form. Also $\mu \ge 0$ and $e_{12}=u(a,b')\ge0$. Substituting $u(a,b)=\mu+e_{11}$ etc. into the vanishing minor gives exactly identity (3.1).

*Step 3: apply the lemmas.* Lemma 3.1 yields $\mu^2 \le 3\sum_{i,j} e_{ij}^2$. The four numbers $e_{ij}^2$ are precisely the values of the nonnegative function $F(x)=(u(x)-\mu\mathbf 1_R(x))^2$ at the four distinct corners, so Lemma 3.3 gives $\sum_{i,j}e_{ij}^2 \le D = 1 - T^2/m$. Hence
$$\frac{T^2}{m^2} \;=\; \mu^2 \;\le\; 3\Bigl(1-\frac{T^2}{m}\Bigr).$$

*Step 4: clear denominators.* Multiplying by $m^2>0$ gives $T^2 \le 3m^2 - 3mT^2$, i.e. $T^2(3m+1)\le 3m^2$. $\square$

### 3.3 The gap for product coins

**Theorem 3.5 (Rigidity gap, multiplicative form).** Let $f,g$ be coins and suppose $(a,b),(a',b')\in R$ while $(a,b')\notin R$. Then
$$|\mathcal{A}(f,g)|^2\,(3|R|+1) \;\le\; 3|R|^2, \qquad\text{equivalently}\qquad |\mathcal{A}(f,g)|^2 \le \Bigl(1-\frac{1}{3|R|+1}\Bigr)|R| .$$

*Proof.* Let $u(x) = |f(x_1)|\,|g(x_2)| \ge 0$. By Lemma 2.6, $\sum_x u(x)^2 = 1$. Every $2\times2$ minor of a product vanishes:
$$u(a,b)u(a',b') = |f(a)||g(b)||f(a')||g(b')| = u(a,b')u(a',b).$$
Theorem 3.4 gives $T^2(3|R|+1) \le 3|R|^2$ with $T=\sum_{x\in R}u(x)$, and the triangle inequality gives $|\mathcal{A}(f,g)| \le T$. The displayed equivalence is the identity $3|R|^2/(3|R|+1) = \bigl(1-\tfrac1{3|R|+1}\bigr)|R|$. $\square$

**Corollary 3.6 (Rigidity gap, additive form).** Under the hypotheses of Theorem 3.5,
$$|\mathcal{A}(f,g)|^2 \;\le\; |R| - \tfrac27 .$$

*Proof.* Since $(a,b)\ne(a',b')$ (their crossover is missing, so $b \ne b'$), $m=|R|\ge 2$. Theorem 3.5 gives $|\mathcal{A}|^2 \le m - \frac{m}{3m+1}$, and $t\mapsto t/(3t+1)$ is increasing on $t>0$ with value $2/7$ at $t=2$. $\square$

**Remark 3.7.** The bound of Corollary 3.6 is *tight at $m=2$ within the method*: the multiplicative theorem gives exactly $|R|-2/7$ when $|R|=2$, and gives strictly more for larger $R$ (approaching $|R|-\frac13$ as $|R|\to\infty$). Thus $1/3$ is the ceiling on what this proof can produce, while §5 shows the truth is at most $0.3820322\ldots$; closing the interval $[1/3,\,0.38197]$ requires improving Lemma 3.1 towards its optimal constant $\varphi^2$, which raises the asymptotic ceiling from $1/3$ to $1/\varphi^2 = 0.38196\ldots = (3-\sqrt5)/2$.

### 3.4 The dichotomy

**Theorem 3.8 (Rigidity dichotomy).** Let $R\subseteq A\times B$ be nonempty. Then
$$\exists\ \text{coins } f, g \ \text{ with } |\mathcal{A}(f,g)|^2 = |R| \iff R \text{ is a box.}$$

*Proof.* ($\Leftarrow$) is Proposition 2.7 with Lemma 2.4. ($\Rightarrow$): if $R$ is not a box there exist $x,y\in R$ with $(x_1,y_2)\notin R$; apply Theorem 3.5 with $(a,b)=x$, $(a',b')=y$ to get $|R|(3|R|+1) \le 3|R|^2$, i.e. $|R| \le 0$, contradicting $R\ne\emptyset$. $\square$

Equivalently: *the normalised indicator of $R$ lies in the projectivised product family if and only if $R$ is a product set*, and Theorem 3.5 measures, in the natural $\ell^2$ metric, how far outside that family a non-product indicator sits.

---

## 4. Arbitrary depth

### 4.1 Setting

Let $\iota$ be a finite index set with $|\iota| = n$ **registers**, and for each $i \in \iota$ let $\alpha_i$ be a finite alphabet. A **word** is an element $x$ of the product $\prod_{i}\alpha_i$. A **product coin of depth $n$** is
$$\psi_f(x) \;=\; \prod_{i\in\iota} f_i(x_i), \qquad \text{each } f_i \text{ a coin on } \alpha_i,$$
i.e. a fully unentangled (shallow, register-wise) state. For a resonance set $R$ of words its resonance amplitude is $\mathcal{A}(\psi_f) = \sum_{x\in R}\psi_f(x)$.

**Definition 4.1 (Non-box along a register).** $R$ is **non-box at $i_0$** if there exist $x,y\in R$ such that the hybrid word $y[i_0 \mapsto x_{i_0}]$ — equal to $y$ except that its $i_0$-th letter is replaced by $x_{i_0}$ — does not lie in $R$.

This is the exact depth-$n$ analogue of a missing crossover: $R$ genuinely *couples* register $i_0$ to the rest.

### 4.2 Transport

**Lemma 4.2 (Splitting at one register).** Fix $i_0$. The map $x \mapsto (x_{i_0}, x|_{\iota\setminus\{i_0\}})$ is a bijection $\prod_i \alpha_i \to \alpha_{i_0}\times \prod_{j\ne i_0}\alpha_j$, and under it
$$\psi_f(x) \;=\; f_{i_0}(x_{i_0})\cdot \tau(x|_{\iota\setminus\{i_0\}}), \qquad \tau(b) := \prod_{j\ne i_0} f_j(b_j).$$
Moreover $\tau$ is a coin on the tail alphabet $\prod_{j\ne i_0}\alpha_j$.

*Proof.* The factorisation is the splitting of a finite product at one index. For normalisation, $|\tau(b)|^2 = \prod_{j\ne i_0}|f_j(b_j)|^2$, and summing a product of functions over a product index set factorises:
$$\sum_{b}\prod_{j\ne i_0}|f_j(b_j)|^2 = \prod_{j\ne i_0}\sum_{c\in\alpha_j}|f_j(c)|^2 = 1. \qquad\square$$

**Theorem 4.3 (Depth-$n$ rigidity gap).** Suppose $R$ is non-box at some register $i_0$. Then for every product coin of depth $n$,
$$|\mathcal{A}(\psi_f)|^2\,(3|R|+1) \;\le\; 3|R|^2, \qquad |\mathcal{A}(\psi_f)|^2 \le \Bigl(1-\frac{1}{3|R|+1}\Bigr)|R|, \qquad |\mathcal{A}(\psi_f)|^2 \le |R| - \tfrac27 .$$
The constants depend on $|R|$ alone — not on $n$, not on the alphabet sizes.

*Proof.* Let $e$ be the splitting bijection of Lemma 4.2 and $R' = e(R)$, so $|R'|=|R|$ and $\mathcal{A}(\psi_f) = \sum_{z\in R'} f_{i_0}(z_1)\tau(z_2)$ is a bipartite resonance amplitude of the product coin $f_{i_0}\otimes\tau$. If $x,y\in R$ witness non-boxness at $i_0$, then $e(x),e(y) \in R'$ while $\bigl((e x)_1, (e y)_2\bigr) = e\bigl(y[i_0\mapsto x_{i_0}]\bigr) \notin R'$: the crossover is exactly the hybrid word. Theorem 3.5 and Corollary 3.6 apply. (For the additive form, note $x\ne y$ — if $x=y$ the hybrid is $x$ itself, which lies in $R$ — so $|R|\ge2$.) $\square$

**Theorem 4.4 (Depth-$n$ converse).** Let $S_i \subseteq \alpha_i$ be nonempty for each $i$ and let $R = \prod_i S_i$. Then the uniform product coin $f_i = |S_i|^{-1/2}\mathbf 1_{S_i}$ attains
$$|\mathcal{A}(\psi_f)|^2 = |R| = \prod_i |S_i| .$$

*Proof.* $\mathcal{A}(\psi_f) = \sum_{x\in\prod_i S_i}\prod_i f_i(x_i) = \prod_i \sum_{a\in S_i} f_i(a) = \prod_i \sqrt{|S_i|}$, and squaring the modulus gives $\prod_i |S_i| = |R|$. $\square$

Theorems 4.3 and 4.4 together are the **depth-$n$ dichotomy**: *a shallow, register-wise coin attains the Cauchy–Schwarz optimum exactly when the resonance set does not couple registers.* In the language that motivates the problem: the optimum is never attained by a coin that does not already "know" about the coupling; the amount of knowledge missing is at least $2/7$ of a resonance unit, at every depth.

### 4.3 The agreement family

**Definition 4.5.** For $n\ge2$ and distinct registers $i\ne j$, the **agreement set** is
$$\mathrm{Agr}_{i,j} \;=\; \{x \in \{0,1\}^n : x_i = x_j\}, \qquad |\mathrm{Agr}_{i,j}| = 2^{n-1}.$$

**Proposition 4.6.** $\mathrm{Agr}_{i,j}$ is non-box at $i$. Consequently, for every $n$, every pair $i\ne j$ and every depth-$n$ product coin,
$$|\mathcal{A}(\psi_f)|^2 \;\le\; 2^{n-1} - \tfrac27 .$$

*Proof.* Take $x = (0,\dots,0)$ and $y = (1,\dots,1)$, both in the agreement set. The hybrid $y[i\mapsto 0]$ has $i$-th bit $0$ and $j$-th bit $1$ (since $j \ne i$), so it is not in the set. Apply Theorem 4.3. $\square$

**Proposition 4.7 (Sharp behaviour of the agreement family).** For $\mathrm{Agr}_{i,j}$ the true supremum over depth-$n$ product coins is $2^{n-2} = \tfrac12|R|$: half the Cauchy–Schwarz optimum is lost.

*Proof sketch.* Factorising the sum over the agreement set,
$$\mathcal{A}(\psi_f) = \bigl(f_i(0)f_j(0)+f_i(1)f_j(1)\bigr)\prod_{k\ne i,j}\bigl(f_k(0)+f_k(1)\bigr).$$
For a coin $h$ on $\{0,1\}$, $|h(0)+h(1)|^2 \le 2(|h(0)|^2+|h(1)|^2) = 2$, with equality for $h=(1/\sqrt2,1/\sqrt2)$. For the bracket, $|f_i(0)f_j(0)+f_i(1)f_j(1)| \le |f_i(0)||f_j(0)|+|f_i(1)||f_j(1)| \le 1$ by Cauchy–Schwarz, with equality when $f_i = f_j$ is concentrated on one bit. Hence $|\mathcal{A}(\psi_f)|^2 \le 1\cdot 2^{n-2}$, and the bound is attained by taking $f_i=f_j=(1,0)$ and $f_k=(1/\sqrt2,1/\sqrt2)$ for $k \ne i,j$. $\square$

Proposition 4.7 shows that on natural coupled families the true loss is *multiplicative* and enormous, while the universal theorem guarantees only the additive $2/7$; the universal constant is the price of covering *all* non-box sets simultaneously.

---

## 5. Sharpness

### 5.1 The extremal small example

Define the optimal universal additive constant
$$c^\ast \;=\; \sup\Bigl\{\,c \;:\; |\mathcal{A}(f,g)|^2 \le |R| - c \text{ for every non-box } R \text{ and all coins } f,g \,\Bigr\}.$$
Corollary 3.6 says $c^\ast \ge 2/7$. An upper bound is obtained by exhibiting a *good* coin for a single non-box set.

**Definition 5.1 (L-shape).** $\mathrm{L} = \{(0,0),(0,1),(1,0)\}\subseteq\{0,1\}^2$, of size $3$; it is the smallest non-box resonance set (indeed $(1,0),(0,1)\in \mathrm L$ but $(1,1)\notin \mathrm L$).

**Proposition 5.2 (Golden optimum for the L-shape).** $\displaystyle\sup_{f,g}|\mathcal{A}(f,g)|^2 = \varphi^2 = \frac{3+\sqrt5}{2} = 2.61803\ldots$, where $\varphi = \frac{1+\sqrt5}{2}$; the true deficiency is $3-\varphi^2 = \frac{3-\sqrt5}{2} = 0.381966\ldots$.

*Proof sketch.* By the modulus reduction it suffices to maximise $p_0q_0+p_0q_1+p_1q_0$ over nonnegative unit vectors $p,q$. The bilinear form is $p^{\top} M q$ with $M = \begin{pmatrix}1&1\\1&0\end{pmatrix}$, whose maximum over unit vectors is $\sigma_1(M)$. Since $M$ is symmetric with characteristic polynomial $\lambda^2-\lambda-1$, its eigenvalues are $\varphi$ and $-1/\varphi$; the top eigenvector $(\varphi,1)/\sqrt{\varphi^2+1}$ is nonnegative, so the constrained and unconstrained maxima agree, giving $\sigma_1 = \varphi$ and $\sup|\mathcal{A}|^2 = \varphi^2$. $\square$

**Proposition 5.3 (Exactly rational certificate).** The pair $(45/53,\,28/53)$ is a coin (a Pythagorean triple: $45^2+28^2 = 2025+784 = 2809 = 53^2$), and, using it for both registers on the L-shape,
$$\mathcal{A} = \frac{45\cdot45 + 45\cdot 28 + 28\cdot 45}{53^2} = \frac{4545}{2809}, \qquad |\mathcal{A}|^2 = \frac{20657025}{7890481} = 2.6179678\ldots$$
(The ratio $28/45 = 0.62\overline{2}$ approximates $1/\varphi = 0.61803\ldots$.)

**Theorem 5.4 (Bracket for the universal constant).**
$$\frac27 = 0.285714\ldots \;\le\; c^\ast \;\le\; 3 - \frac{20657025}{7890481} = \frac{3014418}{7890481} = 0.3820322\ldots$$
In particular the constant $2/7$ proved in Corollary 3.6 is within a factor $1.337$ of optimal, and (by Proposition 5.2) the exact value of $c^\ast$ restricted to the L-shape is $(3-\sqrt5)/2 = 0.381966\ldots$

*Proof.* The lower bound is Corollary 3.6 (which applies to $\mathrm L$: $(1,0),(0,1)\in\mathrm L$, $(1,1)\notin\mathrm L$). For the upper bound, any admissible $c$ must satisfy $|\mathcal{A}|^2 \le 3-c$ for the coin of Proposition 5.3, whence $c \le 3 - 20657025/7890481$. $\square$

The rational certificate is worth a comment: one wants a *provably valid* upper bound on $c^\ast$, and irrational golden coordinates would force an approximation argument. A Pythagorean pair gives an exactly normalised coin with rational coordinates, so the whole computation stays inside $\mathbb{Q}$ and the resulting bound is exact rather than numerical.

### 5.2 A combinatorial lower bound on achievable resonance

**Definition 5.5.** The **row** of $R$ at $a\in A$ is $R_a = \{b\in B : (a,b)\in R\}$.

**Theorem 5.6 (Rows are achievable).** For every $a$ with $R_a \ne \emptyset$ there are coins $f,g$ with $|\mathcal{A}(f,g)|^2 = |R_a|$ exactly. Consequently, for every non-box $R$,
$$\max_{a\in A}|R_a| \;\le\; \sup_{f,g}|\mathcal{A}(f,g)|^2 \;\le\; \frac{3|R|^2}{3|R|+1} .$$

*Proof.* Take $f = \mathbf 1_{\{a\}}$ (concentrated on the single letter $a$) and $g = |R_a|^{-1/2}\mathbf 1_{R_a}$. Then only the terms with first coordinate $a$ survive, and each contributes $|R_a|^{-1/2}$; the row of $R$ at $a$ has exactly $|R_a|$ such terms, so $\mathcal{A} = |R_a|\cdot|R_a|^{-1/2} = \sqrt{|R_a|}$. $\square$

For the L-shape this gives $2 \le \varphi^2 \le 27/10$, correctly bracketing $2.618$.

### 5.3 A benchmark: the two-point diagonal

**Definition 5.7.** $\mathrm{Diag} = \{(0,0),(1,1)\} \subseteq \{0,1\}^2$, of size $2$; it is not a box, since $(0,0),(1,1)\in\mathrm{Diag}$ but $(0,1)\notin\mathrm{Diag}$.

**Theorem 5.8 (Exact optimum for the diagonal).** For all coins $f,g$ on $\{0,1\}$,
$$|\mathcal{A}(f,g)|^2 = |f(0)g(0)+f(1)g(1)|^2 \;\le\; 1,$$
and the value $1$ is attained by $f = g = (1,0)$. Hence $\sup|\mathcal{A}|^2 = 1 = |R| - 1$: the loss is a full unit, versus the $2/7$ guaranteed in general.

*Proof.* With $p_k=|f(k)|$, $q_k = |g(k)|$ we have $p_0^2+p_1^2 = q_0^2+q_1^2 = 1$ and, by the triangle inequality, $|\mathcal{A}| \le p_0q_0+p_1q_1$. Then
$$(p_0q_0+p_1q_1)^2 = (p_0^2+p_1^2)(q_0^2+q_1^2) - (p_0q_1-p_1q_0)^2 = 1 - (p_0q_1-p_1q_0)^2 \le 1$$
by the Lagrange identity. Attainment is immediate. $\square$

The diagonal is the canonical "entangled" target: a product device can realise exactly one of its two resonances. It also illustrates that the universal $2/7$ is far from the *pointwise* truth for individual sets — the theorem's virtue is uniformity, not per-instance sharpness.

---

## 6. Algorithms

Three computational primitives accompany the theory. Throughout, $M \in \{0,1\}^{|A|\times|B|}$ is the resonance matrix of $R$.

**(A) Box test and witness extraction.** Deciding whether $R$ is a box, and extracting a non-box witness $\bigl((a,b),(a',b'),(a,b')\bigr)$ when it is not, is done by comparing $R$ with $\pi_1(R)\times\pi_2(R)$ (Lemma 2.4): if some $(a,b) \in \pi_1(R)\times\pi_2(R)\setminus R$, then picking $y\in R$ with $y_1 = a$ and $z \in R$ with $z_2 = b$ produces the witness $\bigl(y,\,z,\,(a,b)\bigr)$ — note $(y_1, z_2) = (a,b) \notin R$. The cost is $O(|R| + |\pi_1(R)|\cdot|\pi_2(R)|)$ time with a hash set, and $O(|R|)$ space.

**(B) Optimal product coin by power iteration.** By the spectral dictionary, $\sup|\mathcal{A}|^2 = \sigma_1(M)^2$, and since $M$ is entrywise nonnegative, Perron–Frobenius guarantees a nonnegative maximiser. Alternating maximisation — $f \leftarrow Mg/\|Mg\|$, $g \leftarrow M^{\top}f/\|M^{\top}f\|$ — is exactly power iteration on $M M^{\top}$ and converges monotonically to $\sigma_1$ at a linear rate governed by $\sigma_2/\sigma_1$. Each sweep costs $O(|R|)$ using a sparse representation, so $t$ sweeps cost $O(t\,|R|)$.

**(C) Certified gap evaluation.** Given $R$: run (A); if $R$ is a box, report the exact optimum $|R|$ with the uniform coin of Proposition 2.7. Otherwise run (B) to obtain the empirical optimum $\sigma_1^2$ and report the certified upper bounds $3|R|^2/(3|R|+1)$ and $|R|-2/7$, together with the combinatorial lower bound $\max_a|R_a|$ of Theorem 5.6. The output is a validated interval containing $\sup|\mathcal{A}|^2$, together with the observed and guaranteed deficiencies. Total cost $O(t|R| + |\pi_1(R)||\pi_2(R)|)$.

---

## 7. Applications and interpretation

**Unentangled state preparation.** Product coins are unentangled pure states of $n$ subsystems. Theorem 4.3 states that the squared overlap of any such state with the normalised indicator of a register-coupling target set is bounded away from the maximum by $2/7$, uniformly in $n$. The obstruction is one missing corner of one rectangle — a maximally local certificate for a global impossibility.

**Communication complexity.** Combinatorial rectangles are the atoms of one-round deterministic protocols. Theorem 3.8 is the assertion that the $\ell^2$-optimal separable approximation to a set is exact exactly for rectangles; Theorem 3.5 converts "not a rectangle" into a quantitative distance, which is the form typically needed in lower-bound arguments.

**Rank-one approximation of $0/1$ data.** For a binary matrix $M$, the best rank-one approximation captures $\sigma_1^2$ of the total energy $\|M\|_F^2 = |R|$. The theorem lower-bounds the residual energy $\|M\|_F^2 - \sigma_1^2$ by $2/7$ for any non-rectangular pattern — a floor on the unexplained variance of any rank-one (biclustering) model of binary data, independent of matrix size.

**Separable filters.** Separable (outer-product) filters are the product coins of image processing. A non-separable binary template cannot be matched exactly, and the resonance deficiency $2/7$ bounds the correlation loss from below.

**Design guidance.** Theorem 5.6 says the achievable resonance is at least the largest row, and Proposition 4.7 shows a coupled family can lose half its optimum. In practice this means: if a target genuinely couples two registers, an unentangled controller should be benchmarked against $\max_a|R_a|$, not against $|R|$.

---

## 8. Discussion and future work

**The optimal constant.** The truth for the extremal small set is $(3-\sqrt5)/2 = 1/\varphi^2$, and Remark 3.2 identifies exactly where the loss occurs: the relaxation of $\varphi^2$ to $3$ in Lemma 3.1. Sharpening that lemma to its extremal constant would give the asymptotic gap $|R| - |R|/(\varphi^2|R|+1) \to |R| - 1/\varphi^2$, matching the L-shape. It remains to determine whether the L-shape is the global minimiser of the deficiency over all non-box sets — we conjecture it is, i.e. $c^\ast = (3-\sqrt5)/2$.

**Structure-dependent gaps.** The $2/7$ bound uses a *single* missing corner. A set may have many independent missing corners, and each contributes deviation energy at (essentially) disjoint locations. Summing over a family of pairwise-disjoint non-box witnesses should give a gap growing with the number of witnesses — quantitatively, a bound of the form $\sup|\mathcal{A}|^2 \le |R| - c\cdot w(R)$, where $w(R)$ is the maximum size of a set of corner-disjoint violating rectangles. This would interpolate towards Proposition 4.7's multiplicative losses.

**Higher rank / bounded entanglement.** The natural generalisation replaces product coins by states of Schmidt rank at most $r$ across the chosen cut. The Cauchy–Schwarz optimum is then $\sum_{i\le r}\sigma_i^2$, and one expects a gap unless $R$ is a union of $r$ disjoint boxes. The minor argument should generalise: rank $\le r$ forces the vanishing of all $(r+1)\times(r+1)$ minors, and one would compare a vanishing $(r+1)$-minor with the corresponding minor of the pattern.

**Multi-cut strengthening.** Theorem 4.3 uses one register cut. A set may be non-box at several registers simultaneously, and the deviation energies coming from different cuts are, generically, not the same energy. Combining $k$ cuts should give $c \asymp k/7$ rather than $2/7$, yielding gaps that grow with the depth $n$ for genuinely global targets.

**Complexity of the extremal problem.** Computing $\sup|\mathcal{A}|^2$ exactly is computing $\sigma_1$ of a $0/1$ matrix — tractable. But the *combinatorial* question "which non-box $R$ of size $m$ minimises $m - \sigma_1^2$?" is an extremal problem in its own right, and its answer for each $m$ would give the exact size-dependent gap function to replace $m/(3m+1)$.

**Beyond $\ell^2$.** The distance identity (1.2) is specific to the Euclidean structure. Analogous rigidity in $\ell^p$ geometry, or for relative-entropy distance to the product family, would connect the statement to information-theoretic separability measures.

---

## 9. Summary of results

| Statement | Content |
|---|---|
| Cauchy–Schwarz bound | $|\mathcal{A}(f,g)|^2 \le |R|$ for every product coin |
| Rank-one minor inequality | $\mu^2 \le 3(e_{11}^2+e_{12}^2+e_{21}^2+e_{22}^2)$ under the vanishing-minor identity; optimal constant $\varphi^2$ |
| Core gap | $\bigl(\sum_{x\in R}u(x)\bigr)^2(3|R|+1) \le 3|R|^2$ for normalised nonnegative $u$ with a vanishing minor across a missing corner |
| Rigidity gap (multiplicative) | $|\mathcal{A}|^2 \le \bigl(1-\tfrac1{3|R|+1}\bigr)|R|$ for non-box $R$ |
| Rigidity gap (additive) | $|\mathcal{A}|^2 \le |R| - \tfrac27$ |
| Boxes attain | uniform coins on $A_0\times B_0$ give $|\mathcal{A}|^2 = |R|$ |
| Dichotomy | optimum attained by a product coin $\iff$ $R$ is a box |
| Depth-$n$ gap | same constants for all $n$, if $R$ is non-box at one register |
| Depth-$n$ converse | product letter-sets are attained by the uniform depth-$n$ coin |
| Agreement family | non-box at $i$ for all $n$; true optimum $2^{n-2} = \tfrac12|R|$ |
| Diagonal benchmark | $\sup|\mathcal{A}|^2 = 1$, attained; loss $=1$ |
| Golden L-shape | $\sup|\mathcal{A}|^2 = \varphi^2$; rational certificate $20657025/7890481$ |
| Constant bracket | $\tfrac27 \le c^\ast \le 3014418/7890481 = 0.3820322\ldots$ |
| Row lower bound | $\max_a |R_a| \le \sup|\mathcal{A}|^2$ |
