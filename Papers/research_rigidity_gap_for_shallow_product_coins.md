# A Rigidity Gap for Shallow Product Coins: the Sharp Constant $(3-\sqrt5)/2$

**Author:** Aristotle
**Date:** 2026-08-22

---

## Abstract

Let $X$ be a finite state space, $R \subseteq X$ a *resonance set*, and let a
*coin* be a weight function $\psi : X \to \mathbb{R}$ with
$\sum_{x} \psi(x)^2 = 1$. The *resonance amplitude* of $\psi$ against $R$ is
$A_R(\psi) = \sum_{x \in R}\psi(x)$; Cauchy–Schwarz gives
$A_R(\psi)^2 \le |R|$, with equality exactly for scalar multiples of the
indicator $\mathbf 1_R$. We study the same optimisation restricted to *product
coins*, i.e. coins that factor over the coordinates of a product state space
and therefore cannot resolve the global shape of $R$.

Our main results are as follows. (i) An exact Cauchy–Schwarz defect identity
expressing $|R| - A_R(\psi)^2$ as $|R|$ times the squared $\ell^2$-distance
from $\psi$ to the best scalar multiple of $\mathbf 1_R$, and the resulting
rigidity characterisation of the equality case. (ii) A *quantitative* rigidity
gap: if $R \subseteq A \times B$ is not a combinatorial box, then every unit
product coin obeys $A_R(f \otimes g)^2 \le |R| - \tfrac{1}{9|R|}$, hence
$A_R(f\otimes g)^2 \le (1 - c)|R|$ with $c = 1/(9|R|^2) > 0$. (iii) The **sharp**
form of the gap, with an absolute constant:
$$A_R(f\otimes g)^2 \;\le\; |R| - \frac{3-\sqrt5}{2} \;=\; |R| - \varphi^{-2},$$
proved by an exact two-dimensional Eckart–Young argument, and *optimal*: the
three-element L-shape in $\{0,1\}^2$ attains it, with exact product optimum
$(3+\sqrt5)/2 = \varphi^2$. (iv) A combinatorial structure theorem — a set all
of whose single-coordinate splits are boxes is the product of all its coordinate
projections — which upgrades the gap to the intrinsic hypothesis "$R$ is not a
full box $\prod_i S_i$" at every depth $n$, with the *same* constant, uniformly
in $n$. (v) The converse: nonempty full boxes are exactly matched by products of
normalised indicators, yielding the exact dichotomy — *some* product coin is
optimal if and only if $R$ is a full box.

**Keywords.** Resonance amplitude, product coin, combinatorial box,
Cauchy–Schwarz rigidity, rank-one approximation, Eckart–Young, golden ratio,
Frobenius norm.

---

## 1. Introduction

### 1.1 The optimisation problem

Fix a finite set $X$ of states. A **resonance set** is a subset
$R \subseteq X$, thought of as the distinguished or "marked" states. A **coin**
is a function $\psi : X \to \mathbb{R}$ subject to the normalisation
$$\sum_{x \in X} \psi(x)^2 = 1 .$$
The **resonance amplitude** of $\psi$ against $R$ is
$$A_R(\psi) \;=\; \sum_{x\in R} \psi(x).$$
The elementary problem $\max_\psi A_R(\psi)^2$ is solved by Cauchy–Schwarz:
$A_R(\psi)^2 \le |R|$, attained uniquely (up to sign) by
$\psi = \mathbf 1_R / \sqrt{|R|}$.

The problem becomes interesting the moment the class of admissible coins is
restricted to a class that is blind to the global shape of $R$. The class we
study is the *product* class. When $X$ is a product, $X = A \times B$, a
**product coin** is
$$\psi(a,b) = f(a) g(b), \qquad \sum_a f(a)^2 = \sum_b g(b)^2 = 1,$$
which automatically satisfies the coin normalisation. More generally, when
$X = D^{\,n+1}$, a **depth-$(n+1)$ product coin** is
$\psi(x) = \prod_{i=0}^{n} f_i(x_i)$ with each factor normalised.

Product coins are the mean-field, separable, unentangled, rank-one members of
the coin family. The question addressed here — a fixed-depth quantitative form
of a conjecture asserting that the optimum "already knows" the global structure
— is: *by how much must a product coin fall short of the Cauchy–Schwarz optimum
when $R$ is not itself a product?*

### 1.2 Results

The answer is complete, and sharper than one has any right to expect: the
shortfall is bounded below by an **absolute constant**,
$$\frac{3-\sqrt5}{2} \;=\; 2 - \varphi \;=\; \varphi^{-2} \;=\; 0.3819660\ldots,
\qquad \varphi = \frac{1+\sqrt5}{2},$$
independent of $|R|$, of the ambient dimensions $|A|, |B|, |D|$, and of the
depth $n$; and this constant is attained. Section 2 sets up the exact defect
identity, Section 3 develops the crude gap $1/(9|R|)$ through a determinant
expansion, Section 4 sharpens it to the golden constant via Eckart–Young in
dimension two, Section 5 handles attainment and the L-shape, Section 6 handles
arbitrary depth, and Section 7 discusses applications and open problems.

---

## 2. The exact Cauchy–Schwarz defect

Throughout, $X$ is a finite set and $\mathbf 1_R$ denotes the indicator of
$R \subseteq X$. Call $\psi$ a **unit coin** if $\sum_x \psi(x)^2 = 1$.

> **Theorem 2.1 (Defect identity).** Let $R \subseteq X$ be nonempty and let
> $\psi$ be a unit coin. Then
> $$|R| - A_R(\psi)^2 \;=\; |R| \sum_{x \in X}\Bigl(\psi(x) - \frac{A_R(\psi)}{|R|}\,\mathbf 1_R(x)\Bigr)^{\!2}.$$

*Proof sketch.* Write $c = A_R(\psi)/|R|$ and expand the right-hand sum
pointwise. Using $\mathbf 1_R(x)^2 = \mathbf 1_R(x)$,
$$\sum_x \bigl(\psi(x) - c\,\mathbf 1_R(x)\bigr)^2
= \sum_x \psi(x)^2 - 2c\sum_{x\in R}\psi(x) + c^2 |R|
= 1 - 2c\,A_R(\psi) + c^2|R| .$$
Substituting $c = A_R(\psi)/|R|$ gives $1 - A_R(\psi)^2/|R|$; multiplying by
$|R|$ yields the claim. $\square$

Two corollaries are immediate.

> **Corollary 2.2 (Cauchy–Schwarz bound).** Every unit coin satisfies
> $A_R(\psi)^2 \le |R|$.

> **Corollary 2.3 (Rigidity).** For nonempty $R$ and a unit coin $\psi$,
> $A_R(\psi)^2 = |R|$ if and only if $\psi = c\,\mathbf 1_R$ for some
> $c \in \mathbb{R}$ (necessarily $c = \pm|R|^{-1/2}$).

*Proof sketch.* Equality forces the sum of squares in Theorem 2.1 to vanish,
hence each summand vanishes. Conversely, if $\psi = c\mathbf 1_R$ then
$A_R(\psi) = c|R|$ and normalisation gives $c^2|R| = 1$, so
$A_R(\psi)^2 = c^2|R|^2 = |R|$. $\square$

Corollary 2.3 is the pivot of the whole paper: it converts the question "can a
product coin be optimal?" into the question "**can the normalised indicator of
$R$ be a product?**" — a purely structural, non-analytic question. The
quantitative theorems below are quantitative forms of this reduction.

---

## 3. Depth two: boxes and the crude gap

Let $X = A \times B$ with $A, B$ finite.

> **Definition 3.1 (Combinatorial box).** $R \subseteq A \times B$ is a
> **box** if it is closed under the rectangle rule: for all $a,a',b,b'$,
> $(a,b) \in R$ and $(a',b') \in R$ imply $(a,b') \in R$.

> **Lemma 3.2.** $R$ is a box if and only if
> $R = \pi_A(R) \times \pi_B(R)$, the product of its two projections.

*Proof sketch.* Any $R$ is contained in the product of its projections. If $R$
is a box and $a \in \pi_A(R)$, $b\in\pi_B(R)$, pick witnesses $(a,b_1),
(a_2,b) \in R$; the rectangle rule gives $(a,b) \in R$. Conversely a product
set trivially satisfies the rectangle rule. $\square$

> **Lemma 3.3.** If $R$ is not a box then $|R| \ge 2$.

*Proof sketch.* A non-box witness supplies $(a,b), (a',b') \in R$ with
$(a,b') \notin R$; then $a \ne a'$ (else $(a,b') = (a',b') \in R$), so the two
witnesses are distinct elements of $R$. $\square$

### 3.1 The matrix reformulation

Let $M \in \{0,1\}^{A\times B}$ be the indicator matrix of $R$, and let
$t = A_R(f\otimes g)$ for a unit product coin. Then $t\, f g^{\mathsf T}$ is a
rank-one matrix, and the defect has an exact Pythagorean form.

> **Lemma 3.4 (Product defect identity).** For unit factors $f, g$ and
> $t = A_R(f\otimes g)$,
> $$\sum_{(a,b) \in A\times B}\bigl(M_{ab} - t\,f(a)g(b)\bigr)^2
> \;=\; |R| - t^2 .$$

*Proof sketch.* Expand the square. The three sums are
$\sum_{a,b} M_{ab}^2 = |R|$; the cross term
$2t\sum_{(a,b)\in R} f(a)g(b) = 2t^2$; and
$t^2\sum_{a,b} f(a)^2g(b)^2 = t^2(\sum_a f(a)^2)(\sum_b g(b)^2) = t^2$.
Hence the total is $|R| - 2t^2 + t^2 = |R| - t^2$. $\square$

Thus the amplitude defect of a product coin equals the squared Frobenius
distance from $M$ to a specific rank-one matrix, and lower bounds on the defect
are exactly lower bounds on rank-one approximation error for $0/1$ matrices.
Crucially, the defect dominates the contribution of *any four cells*, in
particular of the $2\times 2$ minor supplied by a non-box witness.

### 3.2 The determinant argument

> **Lemma 3.5 (Algebraic core, crude form).** Let $m_1 = m_4 = 1$, $m_2 = 0$,
> $m_3 \ge 0$, so that the block $\begin{pmatrix} m_1 & m_2\\ m_3 & m_4\end{pmatrix}$
> has determinant $1$. Let $(x_1,x_2;x_3,x_4)$ be singular,
> $x_1x_4 = x_2x_3$. Put $P = \sum_{i}(m_i - x_i)^2$ and
> $M_{\mathrm{sq}} = \sum_i m_i^2$. If $M_{\mathrm{sq}} \le \rho$ and
> $\rho \ge 2$, then $P \ge \dfrac{1}{9\rho}$.

*Proof sketch.* Write $e_i = m_i - x_i$. Bilinearity of the determinant gives
the exact identity
$$\bigl(m_1e_4 + m_4e_1 - m_2e_3 - m_3e_2\bigr) - \bigl(e_1e_4 - e_2e_3\bigr) = \det m - \det x = 1 .$$
Call the first bracket $U$ and the second $\Delta$. A four-term Cauchy–Schwarz
inequality gives $U^2 \le M_{\mathrm{sq}}\,P \le \rho P$, while the
arithmetic–geometric estimate $|\Delta| \le P/2$ follows from
$\pm 2(e_1e_4 - e_2e_3) \le e_1^2+e_2^2+e_3^2+e_4^2$. Suppose
$P < 1/(9\rho)$. Since $\rho\ge2$, $P < 1/18$, so
$U = 1 + \Delta \ge 1 - P/2 > 35/36$, whence $U^2 > (35/36)^2 > 1/9$. But
$U^2 \le \rho P < 1/9$, a contradiction. $\square$

> **Theorem 3.6 (Crude rigidity gap, depth two).** If $R \subseteq A\times B$
> is not a box, then every unit product coin satisfies
> $$A_R(f\otimes g)^2 \;\le\; |R| - \frac{1}{9|R|}
> \;=\; \Bigl(1 - \frac{1}{9|R|^2}\Bigr)|R| .$$

*Proof sketch.* Take a non-box witness $(a,b),(a',b')\in R$, $(a,b')\notin R$;
then $a\ne a'$ and $b\ne b'$, so the four cells $(a,b),(a,b'),(a',b),(a',b')$
are pairwise distinct. The corresponding block of $M$ is
$\begin{pmatrix}1&0\\ m_3&1\end{pmatrix}$ with $m_3 \in\{0,1\}$; the
corresponding block of $t\,fg^{\mathsf T}$ is singular. The block's Frobenius
mass satisfies $M_{\mathrm{sq}} \le \sum_{a,b}M_{ab}^2 = |R|$, and by Lemma 3.4
the block's error energy $P$ satisfies $P \le |R| - t^2$. Lemma 3.5 with
$\rho = |R| \ge 2$ (Lemma 3.3) yields $|R| - t^2 \ge 1/(9|R|)$. $\square$

> **Corollary 3.7 (Qualitative dichotomy, one direction).** If a unit product
> coin satisfies $A_R(f\otimes g)^2 = |R|$, then $R$ is a box.

This already shows that the optimum is never attained by a coin that does not
"see" the joint structure. The rest of the paper makes the constant sharp,
supplies the converse, and lifts everything to arbitrary depth.

---

## 4. The sharp constant: Eckart–Young in dimension two

Define the **golden gap**
$$\gamma \;=\; \frac{3-\sqrt5}{2} \;=\; 2 - \varphi \;=\; \varphi^{-2} \;=\;0.381966\ldots,$$
the smaller root of $\lambda^2 - 3\lambda + 1 = 0$; thus
$\gamma^2 = 3\gamma - 1$ and $0 < \gamma < 1$.

The crude bound of Section 3 loses on two counts: it uses only the *bilinear*
part of the determinant expansion, and it pays a factor $|R|$ for the Frobenius
mass of the ambient indicator matrix. Both losses disappear if one estimates the
distance to the *singular variety* directly.

> **Lemma 4.1 (Unit kernel).** Every singular real $2\times2$ matrix
> $X = \begin{pmatrix}x_1&x_2\\x_3&x_4\end{pmatrix}$ (i.e. $x_1x_4 = x_2x_3$)
> annihilates some unit vector $n = (n_1,n_2)$, $n_1^2+n_2^2 = 1$, $Xn = 0$.

*Proof sketch.* If $(x_1,x_2) \ne (0,0)$, take
$n = (-x_2, x_1)/\sqrt{x_1^2+x_2^2}$; the first row is annihilated by
construction, and the second by the singularity relation. If the first row
vanishes, use the second row analogously; if $X = 0$, any unit vector works.
$\square$

> **Lemma 4.2 (Golden quadratic form).** For $m \in [0,1]$ and any unit vector
> $(n_1,n_2)$,
> $$n_1^2 + (m n_1 + n_2)^2 \;\ge\; \gamma .$$

*Proof sketch.* The left side is $\|Nn\|^2$ for
$N = \begin{pmatrix}1&0\\m&1\end{pmatrix}$. The identity
$$(1-\gamma)\bigl(n_1^2 + (mn_1+n_2)^2 - \gamma\bigr)
= \bigl((1-\gamma)n_2 + m n_1\bigr)^2 + \gamma\,(1-m^2)\,n_1^2$$
holds identically on $n_1^2+n_2^2 = 1$, by the defining relation
$\gamma^2 = 3\gamma - 1$. The right side is nonnegative for $m\in[0,1]$ and
$1-\gamma > 0$, giving the claim. Equality at $m = 1$ occurs for the singular
direction of $\begin{pmatrix}1&0\\1&1\end{pmatrix}$, whose squared singular
values are the roots $\varphi^{\pm2}$ of $\lambda^2 - 3\lambda+1$. $\square$

> **Lemma 4.3 (Sharp algebraic core).** For $m \in [0,1]$ and any singular
> $2\times2$ matrix $X$,
> $$\Bigl\|\begin{pmatrix}1&0\\m&1\end{pmatrix} - X\Bigr\|_F^2 \;\ge\; \gamma .$$

*Proof sketch.* Let $n$ be a unit kernel vector of $X$ (Lemma 4.1) and write
$N$ for the displayed block, $E = N - X$. Then $En = Nn$, and row-wise
Cauchy–Schwarz gives $\|E\|_F^2 \ge \|En\|^2 = \|Nn\|^2$, which is at least
$\gamma$ by Lemma 4.2. This is the $2\times2$ instance of the Eckart–Young
theorem: the Frobenius distance from $N$ to the rank-$\le1$ matrices is
$\sigma_{\min}(N)$. $\square$

> **Theorem 4.4 (Sharp rigidity gap, depth two).** If $R \subseteq A\times B$
> is not a box, then every unit product coin satisfies
> $$A_R(f\otimes g)^2 \;\le\; |R| - \gamma \;=\; |R| - \frac{3-\sqrt5}{2},$$
> equivalently $A_R(f\otimes g)^2 \le \bigl(1 - \gamma/|R|\bigr)\,|R|$.

*Proof sketch.* As in Theorem 3.6, a non-box witness gives four distinct cells
whose $M$-block is $\begin{pmatrix}1&0\\m_3&1\end{pmatrix}$ with
$m_3 \in \{0,1\} \subseteq [0,1]$, and whose $t\,fg^{\mathsf T}$-block is
singular. The block error energy is at most the total error energy, which
equals $|R| - t^2$ by Lemma 3.4. Lemma 4.3 bounds the block error energy below
by $\gamma$. $\square$

> **Proposition 4.5.** For every non-box $R$, $\;1/(9|R|) < \gamma$: the sharp
> bound strictly improves the crude one in all cases.

*Proof sketch.* $|R| \ge 2$ gives $1/(9|R|) \le 1/18 = 0.0555\ldots$, while
$\gamma > 0.38$ since $\sqrt5 < 9/4$. $\square$

The two features of Theorem 4.4 worth emphasising are that (a) the loss does
**not** decay with $|R|$ — a single violated rectangle in an arbitrarily large
resonance set costs a fixed amount — and (b) the constant is not an artefact of
the method; Section 5 shows it is exactly attained.

---

## 5. Attainment, the dichotomy, and the L-shape

### 5.1 Boxes are optimal

> **Lemma 5.1.** For a nonempty $S \subseteq Y$ finite, the normalised
> indicator $u_S = \mathbf 1_S/\sqrt{|S|}$ satisfies $\sum_y u_S(y)^2 = 1$ and
> $\sum_{y\in S} u_S(y) = \sqrt{|S|}$.

> **Theorem 5.2 (Converse: boxes attain the optimum).** Let
> $R \subseteq A\times B$ be a nonempty box, $R = S\times T$ with
> $S = \pi_A(R)$, $T = \pi_B(R)$. Then the product coin $u_S \otimes u_T$ is a
> unit product coin with
> $$A_R(u_S\otimes u_T)^2 = |S|\,|T| = |R| .$$

*Proof sketch.* By Lemma 5.1 both factors are normalised. Summing over
$R = S\times T$ factorises:
$\sum_{(a,b)\in S\times T} u_S(a)u_T(b) = \bigl(\sum_{a\in S}u_S(a)\bigr)\bigl(\sum_{b\in T}u_T(b)\bigr) = \sqrt{|S|}\sqrt{|T|}$.
Squaring and using $|R| = |S||T|$ finishes. $\square$

Combining Theorem 5.2 with Corollary 3.7:

> **Theorem 5.3 (Exact dichotomy at depth two).** For nonempty
> $R \subseteq A\times B$, there exists a unit product coin with
> $A_R(f\otimes g)^2 = |R|$ **if and only if** $R$ is a combinatorial box.

### 5.2 The L-shape and optimality of $\gamma$

The smallest resonance set that is not a box is the **L-shape**
$$L \;=\; \{(0,0),(0,1),(1,0)\} \subseteq \{0,1\}\times\{0,1\},
\qquad M_L = \begin{pmatrix}1&1\\1&0\end{pmatrix}, \qquad |L| = 3 .$$
(It fails the rectangle rule: $(0,1),(1,0) \in L$ but $(1,1)\notin L$.)

> **Theorem 5.4 (Exact product optimum for the L-shape).** For unit factors
> $f, g$ on $\{0,1\}$,
> $$A_L(f\otimes g)^2 \;=\; \bigl(f_0g_0 + f_0g_1 + f_1g_0\bigr)^2 \;\le\; \frac{3+\sqrt5}{2} \;=\; \varphi^2,$$
> and equality is attained by explicit unit vectors. Hence the exact product
> optimum is $\varphi^2 = 2.618033\ldots$, strictly below $|L| = 3$.

*Proof sketch (upper bound).* Group the amplitude as
$(f_0+f_1)g_0 + f_0 g_1$ and apply Cauchy–Schwarz in $(g_0,g_1)$:
$$A_L(f\otimes g)^2 \le \bigl((f_0+f_1)^2 + f_0^2\bigr)\bigl(g_0^2+g_1^2\bigr)
= (f_0+f_1)^2 + f_0^2 .$$
The right side is the quadratic form of
$Q = \begin{pmatrix}2&1\\1&1\end{pmatrix} = M_L^{\mathsf T}M_L$ evaluated on the
unit vector $(f_0,f_1)$; its maximum is $\lambda_{\max}(Q) = (3+\sqrt5)/2$,
since $\det Q = 1$, $\operatorname{tr} Q = 3$. Explicitly, with
$u = (\sqrt5-1)/2$ one has the pointwise certificate
$(3+\sqrt5)/2 - \bigl((f_0+f_1)^2+f_0^2\bigr) \ge 0$ from the square
$\bigl(u f_0 - f_1\bigr)^2 \ge 0$ together with $f_0^2 + f_1^2 = 1$.

*Proof sketch (attainment).* Set $u = (\sqrt5-1)/2$,
$N = \sqrt{(5-\sqrt5)/2}$, $L_\ast = \sqrt{(3+\sqrt5)/2}$ and take
$$f = \bigl(1/N,\; u/N\bigr), \qquad g = \bigl((1+u)/(NL_\ast),\; 1/(NL_\ast)\bigr).$$
Then $1 + u^2 = N^2$ gives $\|f\|=1$, and $(1+u)^2 + 1 = N^2L_\ast^2$ gives
$\|g\| = 1$; a direct computation gives $A_L(f\otimes g) = L_\ast$, so
$A_L(f\otimes g)^2 = L_\ast^2 = (3+\sqrt5)/2$. $\square$

Since $3 - \varphi^2 = (3-\sqrt5)/2 = \gamma$, we obtain:

> **Corollary 5.5 (Optimality of the golden constant).** There is a non-box
> resonance set and a unit product coin with
> $A_R(f\otimes g)^2 = |R| - \gamma$ exactly. Hence no constant larger than
> $\gamma = (3-\sqrt5)/2$ can replace $\gamma$ in Theorem 4.4.

> **Remark 5.6.** For the L-shape the crude bound of Theorem 3.6 reads
> $A_L(f\otimes g)^2 \le 3 - 1/27$, i.e. a guaranteed loss of $0.037\ldots$,
> whereas the true loss is $0.381966\ldots$: the crude constant is valid but a
> factor of more than ten from optimal, and — unlike $\gamma$ — it degrades as
> $|R|$ grows.

---

## 6. Arbitrary depth

Let $D$ be a finite alphabet and $X = D^{\,n+1}$, with **depth-$(n+1)$ product
coins** $\psi(x) = \prod_{i=0}^{n} f_i(x_i)$, each factor normalised.

> **Lemma 6.1.** A depth-$(n+1)$ product coin is a unit coin:
> $\sum_{x} \prod_i f_i(x_i)^2 = \prod_i \sum_{d} f_i(d)^2 = 1$.

> **Definition 6.2 (Coordinate split, full box).** For $i \in \{0,\dots,n\}$
> let $\sigma_i : D^{\,n+1} \to D \times D^{\,n}$ be the bijection
> $x \mapsto (x_i, x_{\widehat i})$ that peels coordinate $i$ off the rest. A
> set $R \subseteq D^{\,n+1}$ is a **full box** if
> $R = \prod_{i} \pi_i(R)$, where $\pi_i(R) = \{x_i : x \in R\}$.

The reduction to depth two is immediate and lossless:

> **Lemma 6.3 (Split reduction).** For any $i$, a depth-$(n+1)$ product coin
> $\psi$ corresponds under $\sigma_i$ to the two-factor product coin
> $f_i \otimes g$ on $D \times D^{\,n}$, where
> $g(z) = \prod_{j \ne i} f_j(z_j)$ is itself a unit coin (Lemma 6.1), and
> $A_{\sigma_i(R)}(f_i \otimes g) = A_R(\psi)$, $|\sigma_i(R)| = |R|$.

Consequently, Theorem 4.4 applies verbatim to $\sigma_i(R)$ whenever the latter
is not a box. To get an *intrinsic* hypothesis, one needs the following purely
combinatorial statement.

> **Theorem 6.4 (Structure theorem).** Let $R \subseteq D^{\,n+1}$. If for
> every coordinate $i$ the image $\sigma_i(R) \subseteq D \times D^{\,n}$ is a
> combinatorial box, then $R$ is a full box: $R = \prod_i \pi_i(R)$.

*Proof sketch.* One inclusion always holds. For the other, let $y$ satisfy
$y_i \in \pi_i(R)$ for every $i$; choose witnesses $w^{(i)} \in R$ with
$w^{(i)}_i = y_i$. Fix any $r \in R$ and repair its coordinates one at a time:
being a box at coordinate $i$ means exactly that $R$ is closed under the
*crossover* which replaces the $i$-th coordinate of one member by the $i$-th
coordinate of another. Applying crossover at coordinate $0$ to $r$ and
$w^{(0)}$ produces a member of $R$ agreeing with $y$ in coordinate $0$;
applying crossover at coordinate $1$ to that member and $w^{(1)}$ produces a
member agreeing with $y$ in coordinates $0$ and $1$; after $n+1$ steps we reach
$y \in R$. $\square$

> **Corollary 6.5.** If $R$ is not a full box, then some coordinate split
> $\sigma_i(R)$ is not a box.

> **Theorem 6.6 (Sharp rigidity gap at depth $n$).** Let
> $R \subseteq D^{\,n+1}$ fail to be a full box. Then every depth-$(n+1)$
> product coin $\psi$ satisfies
> $$A_R(\psi)^2 \;\le\; |R| - \frac{3-\sqrt5}{2},$$
> and in multiplicative form $A_R(\psi)^2 \le (1 - c)|R|$ with
> $c = \gamma/|R| > 0$ (and, from the crude route, also with
> $c = 1/(9|R|^2)$). The constant is independent of the depth $n$, of the
> alphabet size $|D|$, and of $|R|$.

*Proof sketch.* Combine Corollary 6.5, Lemma 6.3, and Theorem 4.4. $\square$

> **Theorem 6.7 (Converse at depth $n$).** If $R = \prod_i S_i$ is a nonempty
> full box, then the depth-$(n+1)$ product coin $\psi = \bigotimes_i u_{S_i}$
> built from the normalised indicators of the factors satisfies
> $A_R(\psi)^2 = \prod_i |S_i| = |R|$.

*Proof sketch.* The sum over the product set factorises,
$A_R(\psi) = \prod_i \sum_{d \in S_i} u_{S_i}(d) = \prod_i \sqrt{|S_i|}$;
square and use $|R| = \prod_i |S_i|$. $\square$

> **Theorem 6.8 (Exact dichotomy at depth $n$).** For nonempty
> $R \subseteq D^{\,n+1}$: some depth-$(n+1)$ product coin attains the
> Cauchy–Schwarz optimum $A_R(\psi)^2 = |R|$ **if and only if** $R$ is a full
> combinatorial box $\prod_i S_i$.

This is the precise sense in which "the optimum is never attained by a coin
that does not already depend on the joint structure": optimality of a
factorised coin is equivalent to factorisation of the target, and any failure
of factorisation is punished by at least $(3-\sqrt5)/2$.

---

## 7. Algorithms

Three computational primitives underlie the numerical exploration of these
results.

**(A) Box testing.** Given $R \subseteq A\times B$ as a $0/1$ matrix, deciding
whether $R$ is a box can be done in $O(|A||B|)$ time by comparing $R$ with the
product of its projections: compute the row-support and column-support, form
the outer product, and test equality. Equivalently, one scans for a *non-box
witness* — a pair of ones whose "crossover" entry is zero — which also produces
the certificate $2\times2$ minor used by the proofs.

**(B) Exact product optimum.** By Lemma 3.4, maximising $A_R(f\otimes g)^2$
over unit product coins is equivalent to computing
$\max_{\|f\|=\|g\|=1} (f^{\mathsf T} M g)^2 = \sigma_{\max}(M)^2$, the squared
largest singular value of the indicator matrix. Hence the true product optimum
is $\sigma_1(M)^2$ and the true gap is $|R| - \sigma_1(M)^2 = \sum_{k\ge2}\sigma_k(M)^2$,
since $\|M\|_F^2 = |R|$. Theorem 4.4 is therefore the statement that a $0/1$
matrix of rank $\ge 2$ has singular tail at least $\gamma$; computing it costs
$O(\min(|A|,|B|)^2\max(|A|,|B|))$ by a singular value decomposition, or
$O(|A||B|)$ per iteration by power iteration on $M^{\mathsf T}M$.

**(C) Exhaustive verification of sharpness.** Enumerating all non-box subsets
of a $p\times q$ grid and computing $\sum_{k\ge2}\sigma_k^2$ for each verifies
that the minimum over all such patterns equals $\gamma$, attained exactly by
the L-shape (and its transposes/complementary reflections). The enumeration is
$2^{pq}$ and is feasible up to $4\times4$; random sampling extends the check
into $5\times5$ and beyond. This is how the golden constant was discovered
before it was proved.

---

## 8. Discussion and applications

**Rank-one approximation of binary data.** Theorem 4.4 is a hard floor for
rank-one fitting of $0/1$ matrices: the best rank-one approximation of a binary
matrix that is not a combinatorial rectangle (a bicluster) has squared
Frobenius error at least $0.381966\ldots$, uniformly in the size of the matrix
and the number of ones. Standard low-rank error bounds are relative and
degrade with scale; this bound is absolute. In biclustering, topic modelling,
and Boolean matrix factorisation, it quantifies the exact price of the
single-factor ansatz.

**Separability and entanglement.** Reading a coin as a real amplitude vector on
a bipartite (or $(n+1)$-partite) state space, product coins are exactly the
separable pure states of product form. Theorem 6.8 says that the optimal
overlap with the uniform superposition on $R$ is achievable by an unentangled
state precisely when $R$ is a product of local supports; otherwise the overlap
is deficient by an absolute constant, giving an entanglement witness of
constant strength that depends only on the combinatorics of $R$.

**Communication complexity.** Combinatorial rectangles are the elementary
objects certified by deterministic two-party protocols. The identity
$|R| - \sigma_1(M)^2 = \sum_{k\ge2}\sigma_k^2$ together with the golden bound
says: any non-rectangular set has spectral tail bounded away from zero by an
absolute constant, so a single rank-one certificate can never come
asymptotically close to explaining a non-rectangular pattern.

**Mean-field methods.** A depth-$n$ product coin is exactly a mean-field
(fully factorised) ansatz. Theorem 6.6 is a depth-independent no-go: whenever
the target support has any coordinate correlation at all — i.e. is not a
product of coordinate ranges — the factorised ansatz forfeits at least
$(3-\sqrt5)/2$, however many coordinates are involved.

**Why the golden ratio.** The constant is not decorative. Failure of the
rectangle rule always exposes a $2\times2$ minor $\begin{pmatrix}1&0\\m&1\end{pmatrix}$
with $m \in \{0,1\}$. Among these the extremal one is
$\begin{pmatrix}1&0\\1&1\end{pmatrix}$, whose singular values squared solve
$\lambda^2 - 3\lambda + 1 = 0$; its roots are $\varphi^{\pm2}$, since squaring
the golden equation $x^2 = x + 1$ produces exactly $\lambda^2 = 3\lambda - 1$.
The rigidity modulus of rectangles and the arithmetic of $\varphi$ coincide
because the minimal non-rectangle is the $2\times2$ lower-triangular all-ones
matrix, the smallest Fibonacci-type incidence pattern.

---

## 9. Future directions

**1. A second-eigenvalue floor for $0/1$ matrices.** The present proof
lower-bounds the *total* tail $\sum_{k\ge2}\sigma_k^2$. Numerics indicate the
stronger, purely spectral statement:

> **Conjecture.** For every $0/1$ matrix $M$ of rank at least two,
> $\sigma_2(M)^2 \ge (3-\sqrt5)/2$, with equality exactly for matrices whose
> non-trivial part is a copy of $\begin{pmatrix}1&0\\1&1\end{pmatrix}$.

The certificate used here is local (a $2\times2$ minor), so what remains is to
show that the local certificate can be chosen simultaneously optimal for the
second singular direction.

**2. A golden rigidity modulus at bounded rank.** Let $A_r(R)$ be the best
squared amplitude achievable by a coin of tensor rank at most $r$ (product
coins are $r=1$).

> **Conjecture.** If the indicator matrix of $R$ has rank greater than $r$,
> then $A_r(R) \le |R| - (3-\sqrt5)/2$: the golden constant is a
> *rank-independent* modulus of rigidity.

The $2\times2$ Eckart–Young certificate should become an
$(r+1)\times(r+1)$ determinant certificate, with extremal integer block the
lower-triangular all-ones matrix, whose smallest singular value is
$2\sin\bigl(\pi/(2(2r+3))\bigr)$ — an explicit trigonometric constant
degenerating to the golden one at $r=1$. The coordinate-split reduction already
turns any coordinate-factorised ansatz into a two-factor problem, so only the
block estimate needs generalising.

**3. A depth hierarchy for resonance coins.**

> **Conjecture.** For every $n$ there is a resonance set
> $R_n \subseteq \{0,1\}^{n+1}$ with $|R_n| = n+2$ such that every coin
> factorising over *any* partition of the coordinates into two blocks loses at
> least $(3-\sqrt5)/2$, while a coin factorising over some partition into three
> blocks attains the optimum.

A positive answer would show that "shallowness" is a genuinely graded resource
and that the golden gap detects each level of the hierarchy separately.

---

## 10. Conclusion

The optimisation of resonance amplitude over factorised coins is completely
resolved at fixed depth. The Cauchy–Schwarz optimum $|R|$ is attained by a
depth-$(n+1)$ product coin if and only if the resonance set is a full
combinatorial box; whenever it is not, every product coin forfeits at least
$$\frac{3-\sqrt5}{2} \;=\; \varphi^{-2} \;=\; 0.381966\ldots,$$
a constant independent of the depth, of the alphabet, and of the size of the
resonance set, and attained exactly by the three-element L-shape, whose product
optimum is precisely $\varphi^2$. The mechanism is a single $2\times2$ minor of
determinant one: local combinatorial failure of the rectangle rule, converted
by an exact Frobenius Pythagoras identity and a two-dimensional Eckart–Young
step into a global, absolute analytic loss.
