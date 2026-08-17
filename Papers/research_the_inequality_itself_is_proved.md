# From Fourier Energy to Additive Energy: The Exact Collapse of a Covering Bound, with Three Explicit Families

**Author:** Aristotle
**Date:** 2026-08-17

---

## Abstract

Let $G$ be a finite abelian group and let $A, B \subseteq G$ be nonempty. The representation
function $r_{A,B}(c) = \#\{(a,b)\in A\times B : a+b=c\}$ has total mass $|A||B|$ and support
$A+B$, and a standard Cauchy–Schwarz argument over the character group produces the covering
bound
$$|A+B| \;\ge\; \frac{|G|\,(|A||B|)^2}{(|A||B|)^2 + E}, \qquad
E \;=\; \sum_{\psi \neq 0} \bigl|\widehat{1_A}(\psi)\bigr|^2 \bigl|\widehat{1_B}(\psi)\bigr|^2 ,$$
where $E$ is the nonprincipal Fourier energy. We prove that $E$ is not an independent
analytic quantity: by Parseval,
$$E = |G|\,\tilde{E}(A,B) - (|A||B|)^2,$$
where $\tilde{E}(A,B) = \sum_c r_{A,B}(c)^2$ is the combinatorial additive energy, i.e. the
number of additive quadruples. Consequently the entire right-hand side of the covering bound
collapses to the elementary second-moment ratio $(|A||B|)^2/\tilde{E}(A,B)$, with no loss and
no gain. This has three consequences developed here. (i) *Computability*: $E$ is available in
closed form for any family whose additive quadruples can be counted. (ii) *An exact
dichotomy*: for $A = B$ the bound strictly improves on the pigeonhole bound
$|A+A| \ge |A|$ if and only if $A$ has strictly positive doubling; the only exceptions are
cosets of subgroups, for which the bound is exactly sharp, returning $|H|$ for a subgroup
$H$ with $E = |G||H|^3 - |H|^4$. (iii) *Explicit families*: we compute $E$ and the bound in
closed form for Sidon sets ($\tilde E = 2k^2-k$, bound $k^3/(2k-1)$, sharp to
$1+\frac{1}{2k}$), for sets that are Sidon off the diagonal in groups of exponent two
($\tilde E = 3k^2 - 2k$, bound $k^3/(3k-2)$, off by exactly $3/2$ asymptotically), and for
arithmetic intervals in $\mathbb{Z}/n$ ($\tilde E = k(2k^2+1)/3$, bound $3k^3/(2k^2+1)$,
accuracy pinned to the window $[3/4, 1)$). Concrete instances are the parabola
$\{(x,x^2)\}\subseteq(\mathbb{Z}/p)^2$, with $E = p^4 - p^3$ and bound $p^3/(2p-1)\ge p^2/2$,
and the radius-one Hamming ball in $\mathbb{F}_2^n$, with $E = 2^n(3n^2+4n+1) - (n+1)^4$ and
bound $(n+1)^3/(3n+1) \ge (n+1)^2/3$. The interval family shows that the bound beats
pigeonhole even in the minimal-doubling regime, where no power gain is possible at all.

**Keywords:** additive energy, Fourier energy, Plancherel identity, sumset, Sidon set,
covering bound, second moment, doubling constant.

---

## 1. Introduction

### 1.1 The problem

Let $G$ be a finite abelian group, written additively, and let $A, B \subseteq G$. The sumset
is $A+B = \{a+b : a\in A,\ b\in B\}$, and the basic question of additive combinatorics is how
small $|A+B|$ can be relative to $|A|$ and $|B|$. The trivial answer is the **pigeonhole
bound**
$$|A+B| \;\ge\; \max(|A|, |B|), \tag{1.1}$$
obtained by observing that $y \mapsto a_0 + y$ injects $B$ into $A+B$ for any fixed
$a_0 \in A$, and symmetrically. Everything interesting in the subject consists of improving
on (1.1) under structural hypotheses.

One standard route is Fourier-analytic. Write $\widehat{G}$ for the group of characters
$\psi : G \to \mathbb{C}^{\times}$, and for $f : G \to \mathbb{C}$ put
$\widehat{f}(\psi) = \sum_{x\in G} f(x)\overline{\psi(x)}$. The **representation function**
$$r_{A,B}(c) \;=\; \#\{(a,b)\in A\times B : a+b=c\} \;=\; (1_A * 1_B)(c) \tag{1.2}$$
has transform $\widehat{1_A}\widehat{1_B}$, its principal Fourier coefficient is
$\widehat{1_A}(0)\widehat{1_B}(0) = |A||B|$, and all remaining spectral mass is measured by
the **nonprincipal Fourier energy**
$$E(A,B) \;=\; \sum_{\psi \in \widehat{G},\ \psi \neq 0}
\bigl|\widehat{1_A}(\psi)\bigr|^2\bigl|\widehat{1_B}(\psi)\bigr|^2 . \tag{1.3}$$
A Cauchy–Schwarz argument comparing $r_{A,B}$ with its mean value $|A||B|/|G|$ then yields the
**covering bound**
$$\bigl|\{c : r_{A,B}(c) > 0\}\bigr| \;\ge\; \frac{|G|\,(|A||B|)^2}{(|A||B|)^2 + E(A,B)} .
\tag{$\star$}$$
Since the support of $r_{A,B}$ is exactly $A+B$ (Proposition 3.1 below), $(\star)$ is a lower
bound for $|A+B|$ expressed entirely in spectral terms. Its shape is suggestive: were $E = 0$
one would conclude $|A+B| = |G|$, and each unit of nonprincipal energy degrades that
conclusion.

The inequality $(\star)$ is classical in form. What is not obvious, and what this paper
settles, is what it is *worth*: for which sets does it improve on (1.1), by how much, and how
does one evaluate $E$ — a sum over $|G|$ characters with no evident closed form — in practice?

### 1.2 Results

Our main structural result is that the question of evaluating $E$ has a purely combinatorial
answer. Define the **additive energy**
$$\tilde{E}(A,B) \;=\; \sum_{c \in G} r_{A,B}(c)^2
\;=\; \#\{(a,b,a',b') \in A\times B\times A\times B : a+b = a'+b'\} . \tag{1.4}$$

> **Theorem A (Energy identity).** For all $A, B \subseteq G$,
> $$E(A,B) \;=\; |G|\,\tilde{E}(A,B) \;-\; (|A|\,|B|)^2 .$$

> **Theorem B (Collapse of the covering bound).** For nonempty $A, B \subseteq G$ the
> right-hand side of $(\star)$ equals the elementary second-moment ratio:
> $$\frac{|G|\,(|A||B|)^2}{(|A||B|)^2 + E(A,B)} \;=\; \frac{(|A||B|)^2}{\tilde{E}(A,B)}
> \;=\; \frac{\bigl(\sum_c r_{A,B}(c)\bigr)^2}{\sum_c r_{A,B}(c)^2}.$$
> In particular $(\star)$ is *identically* the Cauchy–Schwarz second-moment bound
> $|{\rm supp}\, r| \ge (\sum r)^2/(\sum r^2)$, with no loss and no gain.

Theorem B is a negative result about the Fourier method and a positive result about
computation. Negative: whatever the derivation, $(\star)$ contains no information beyond the
first two moments of $r_{A,B}$; genuine Fourier gains must come from the *shape* of the
spectrum (a large individual coefficient, an $L^\infty$ or $L^p$ control on the nonprincipal
part) rather than from its total mass, which is a combinatorial invariant. Positive: $E$ is
computable in closed form for every family whose additive quadruples can be counted, and we
carry this out for three families.

> **Theorem C (Dichotomy).** Let $A \subseteq G$ be nonempty. Then
> $$|A| \;<\; \frac{|A|^4}{\tilde{E}(A,A)} \iff |A| < |A+A| .$$
> Equivalently, either the covering bound strictly improves on pigeonhole, or $A$ is a coset
> of a subgroup of $G$ (namely of its own stabiliser). In the exceptional case, with
> $A = H$ a subgroup of order $h$, one has $\tilde{E} = h^3$, $E = |G|h^3 - h^4$, and the
> bound returns exactly $h = |H+H|$.

> **Theorem D (Three families).** Let $k = |A|$.
> 1. *(Sidon)* If $A$ is a Sidon set then $\tilde E(A,A) = 2k^2-k$, so $E = |G|(2k^2-k)-k^4$
>    and the bound equals $k^3/(2k-1) \ge k^2/2$, while $|A+A| = k(k+1)/2$; the bound is
>    sharp to within a factor $1 + \frac{1}{2k}$. The parabola
>    $P = \{(x,x^2) : x \in \mathbb{Z}/p\} \subseteq (\mathbb{Z}/p)^2$ is Sidon for odd $p$,
>    giving $E = p^4 - p^3$ and bound $p^3/(2p-1)$.
> 2. *(Exponent two)* If $x+x=0$ for all $x \in G$ and $A$ is Sidon off the diagonal, then
>    $\tilde E(A,A) = 3k^2 - 2k$, so $E = |G|(3k^2-2k)-k^4$ and the bound equals
>    $k^3/(3k-2) \ge k^2/3$, while $|A+A| = 1 + \binom{k}{2}$; the bound is off by a factor
>    tending to exactly $3/2$. The radius-one Hamming ball
>    $B = \{0,e_1,\dots,e_n\} \subseteq \mathbb{F}_2^n$ qualifies, giving
>    $E = 2^n(3n^2+4n+1) - (n+1)^4$ and bound $(n+1)^3/(3n+1)$.
> 3. *(Intervals)* For $I_k = \{0,\dots,k-1\} \subseteq \mathbb{Z}/n$ with $2k \le n$,
>    $\tilde E(I_k,I_k) = k(2k^2+1)/3$, so $E = \frac{n k(2k^2+1)}{3} - k^4$ and the bound
>    equals $3k^3/(2k^2+1)$, which exceeds $k$ for every $k \ge 2$; the exact sumset is
>    $|I_k+I_k| = 2k-1$ and the ratio (bound)/(truth) lies in $[3/4, 1)$ for all $k \ge 2$.

Part 3 is worth emphasising: intervals realise *minimal* doubling, so no power improvement
over pigeonhole is available in principle; nevertheless the bound wins, by a constant factor
approaching $3/2$, and never overshoots.

### 1.3 Organisation

Section 2 fixes notation. Section 3 identifies the support of $r_{A,B}$ and expresses
$\tilde E$ as a quadruple count. Section 4 proves Theorems A and B. Section 5 proves the
dichotomy (Theorem C) and treats the subgroup equality case. Sections 6–8 treat the three
families. Section 9 gives algorithms and complexity. Section 10 discusses interpretation,
including a phase-space reading of the exponent-two family, and Section 11 lists open
problems.

---

## 2. Notation and conventions

Throughout, $G$ is a finite abelian group written additively, $|G| = N$, and $A, B \subseteq G$
are finite (hence arbitrary) subsets, nonempty unless stated otherwise. We write $\widehat{G}$
for the dual group of characters $\psi : G \to \mathbb{C}^\times$, with trivial character
denoted $0$; recall $|\widehat{G}| = |G|$ and the orthogonality relation
$\sum_{x\in G}\psi(x) = |G|\,[\psi = 0]$.

For $f : G \to \mathbb{C}$ set
$$\widehat{f}(\psi) = \sum_{x \in G} f(x)\overline{\psi(x)}, \qquad
(f*g)(c) = \sum_{a \in G} f(a) g(c-a) .$$
With these conventions $\widehat{f*g} = \widehat f\,\widehat g$ and Parseval's identity reads
$$\sum_{x\in G} |f(x)|^2 = \frac{1}{|G|}\sum_{\psi \in \widehat G} |\widehat f(\psi)|^2 .
\tag{2.1}$$

The **representation function** is $r_{A,B} = 1_A * 1_B$ as in (1.2); explicitly
$r_{A,B}(c) = \#\{a \in A : c - a \in B\}$. The **additive energy** $\tilde E(A,B)$ is (1.4),
the **Fourier energy** $E(A,B)$ is (1.3), and the **covering bound** is
$$\mathrm{FB}(A,B) \;=\; \frac{|G|\,(|A||B|)^2}{(|A||B|)^2 + E(A,B)} . \tag{2.2}$$
The **doubling constant** of $A$ is $\sigma(A) = |A+A|/|A| \ge 1$.

---

## 3. The support of $r_{A,B}$, and additive energy as a quadruple count

**Proposition 3.1 (Support).** For every $c \in G$, $r_{A,B}(c) > 0$ if and only if
$c \in A+B$. Hence $\operatorname{supp} r_{A,B} = A+B$ and
$$\sum_{c \in A+B} r_{A,B}(c) = |A||B|, \qquad \sum_{c\in A+B} r_{A,B}(c)^2 = \tilde E(A,B).$$

*Proof.* If $r_{A,B}(c) > 0$ there is $a \in A$ with $c - a \in B$, and then
$c = a + (c-a) \in A+B$. Conversely if $c = a+b$ with $a\in A$, $b\in B$ then $c - a = b \in B$,
so $a$ is counted by $r_{A,B}(c)$. The two displayed identities follow because $r_{A,B}$ and
$r_{A,B}^2$ vanish off $A+B$, while $\sum_{c\in G} r_{A,B}(c) = |A\times B| = |A||B|$ since each
pair $(a,b)$ is counted for exactly one $c$. $\square$

**Proposition 3.2 (Fibrewise form of the energy).** For all $A,B$,
$$\tilde E(A,B) \;=\; \sum_{(a,b)\in A\times B} r_{A,B}(a+b)
\;=\; \#\{(a,b,a',b') \in A\times B \times A\times B : a+b = a'+b'\}.$$

*Proof.* Partition $A\times B$ into the fibres $F_c = \{(a,b) : a+b = c\}$, whose cardinalities
are $|F_c| = r_{A,B}(c)$ (the map $a \mapsto (a, c-a)$ is a bijection from
$\{a \in A: c-a\in B\}$ to $F_c$). Summing the constant value $r_{A,B}(c)$ over $F_c$ and then
over $c$ gives $\sum_c r_{A,B}(c)\cdot r_{A,B}(c) = \tilde E(A,B)$. The quadruple description is
the same partition read as a count of pairs of pairs with equal sum. $\square$

Proposition 3.2 is the workhorse for the explicit computations of Sections 6–8: to evaluate
$\tilde E$ it suffices to know the value of $r_{A,B}$ on each sum $a+b$, which is a local,
finite piece of information.

**Proposition 3.3 (Positivity and the trivial bounds).** If $A,B \ne \emptyset$ then
$0 < \tilde E(A,B)$, and $r_{A,B}(c) \le \min(|A|,|B|)$ for all $c$; consequently
$$\frac{(|A||B|)^2}{\tilde E(A,B)} \;\le\; |A+B| \;\le\; |A||B| .$$

*Proof.* Positivity is Proposition 3.1 applied to any $c = a_0+b_0$. The pointwise bound holds
because $r_{A,B}(c)$ counts a subset of $A$ (and, symmetrically, of $B$). The lower bound is
Theorem 4.3 below; the upper bound is trivial. $\square$

---

## 4. Plancherel: the two energies coincide, and the bound collapses

**Theorem 4.1 (Energy identity; Theorem A).** For all $A, B \subseteq G$,
$$E(A,B) \;=\; |G|\,\tilde E(A,B) \;-\; (|A||B|)^2 .$$

*Proof.* Apply Parseval (2.1) to $f = r_{A,B} = 1_A*1_B$, whose transform is
$\widehat{1_A}\widehat{1_B}$:
$$\tilde E(A,B) = \sum_{c\in G} r_{A,B}(c)^2 = \frac{1}{|G|}\sum_{\psi\in\widehat G}
\bigl|\widehat{1_A}(\psi)\bigr|^2\bigl|\widehat{1_B}(\psi)\bigr|^2 .$$
The trivial character contributes $|\widehat{1_A}(0)|^2|\widehat{1_B}(0)|^2 = (|A||B|)^2$, and
by definition the remaining terms sum to $E(A,B)$. Hence
$|G|\tilde E(A,B) = (|A||B|)^2 + E(A,B)$. $\square$

Two immediate remarks. First, the identity forces $E \ge 0$ (obvious from (1.3)) to be
equivalent to $\tilde E \ge (|A||B|)^2/|G|$, which is exactly Cauchy–Schwarz applied to
$r_{A,B}$ against the constant function — so the nonnegativity of the Fourier energy *is* the
statement that the additive energy is at least its mean-field value. Second, $E = 0$ if and
only if $r_{A,B}$ is constant on $G$, which for $\{0,1\}$-valued indicator data forces $A$ or
$B$ to be a union of cosets in a very restricted way; generically $E$ is large.

**Theorem 4.2 (Collapse; Theorem B).** For nonempty $A, B$,
$$\mathrm{FB}(A,B) \;=\; \frac{(|A||B|)^2}{\tilde E(A,B)} .$$

*Proof.* By Theorem 4.1 the denominator of (2.2) is
$(|A||B|)^2 + \bigl(|G|\tilde E - (|A||B|)^2\bigr) = |G|\,\tilde E(A,B)$, which is positive by
Proposition 3.3. Cancelling $|G|$ from numerator and denominator gives the claim. $\square$

**Theorem 4.3 (The covering bound, combinatorial form).** For nonempty $A, B \subseteq G$,
$$\frac{(|A||B|)^2}{\tilde E(A,B)} \;\le\; |A+B| .$$

*Proof.* Cauchy–Schwarz on the support: with $S = A+B = \operatorname{supp} r_{A,B}$,
$$\Bigl(\sum_{c\in S} r_{A,B}(c)\Bigr)^2 \le |S| \sum_{c\in S} r_{A,B}(c)^2 ,$$
and by Proposition 3.1 the left side is $(|A||B|)^2$ while the sum on the right is
$\tilde E(A,B)$. $\square$

Thus the two derivations — Fourier plus Cauchy–Schwarz over $\widehat G$, versus Cauchy–Schwarz
over $G$ — deliver numerically identical bounds. The Fourier derivation is not weaker; it is
the same statement transported through Parseval.

**Corollary 4.4 (Computability of $E$).** For any family of sets whose additive quadruples can
be counted, the nonprincipal Fourier energy is available in closed form via
$E = |G|\tilde E - (|A||B|)^2$, without evaluating a single character sum.

---

## 5. The dichotomy: when does the bound beat pigeonhole?

We now specialise to $B = A$ and write $k = |A|$, $\tilde E = \tilde E(A,A)$. The pigeonhole
benchmark (1.1) is $k$.

**Lemma 5.1 (Criterion).** For nonempty $A, B$,
$$\max(|A|,|B|) < \mathrm{FB}(A,B) \iff \max(|A|,|B|)\cdot\tilde E(A,B) < (|A||B|)^2 .$$

*Proof.* Immediate from Theorem 4.2 and $\tilde E > 0$. $\square$

**Lemma 5.2 (Energy deficit under positive doubling).** If $A$ is nonempty and
$|A| < |A+A|$, then $\tilde E(A,A) < |A|^3$.

*Proof.* Always $r_{A,A}(c) \le k$. Suppose $r_{A,A}(c) = k$ for every $c \in A+A$. Summing
over the support and using Proposition 3.1 gives $k^2 = \sum_{c\in A+A} r_{A,A}(c) = k\,|A+A|$,
whence $|A+A| = k$, contradicting the hypothesis. So there is $c_0 \in A+A$ with
$r_{A,A}(c_0) < k$, and then
$$\tilde E = \sum_{c \in A+A} r_{A,A}(c)^2 < \sum_{c\in A+A} k\, r_{A,A}(c) = k \cdot k^2 = k^3,$$
the strict inequality coming from the term at $c_0$ (where $r_{A,A}(c_0) \ge 1$). $\square$

**Theorem 5.3 (Dichotomy; Theorem C).** For nonempty $A \subseteq G$,
$$|A| < \mathrm{FB}(A,A) \iff |A| < |A+A| .$$

*Proof.* ($\Leftarrow$) By Lemma 5.2, $\tilde E < k^3$, so
$\mathrm{FB} = k^4/\tilde E > k^4/k^3 = k$. ($\Rightarrow$) If $|A+A| \le |A|$ then, since
$\mathrm{FB}(A,A) \le |A+A|$ by Theorem 4.3, we get $\mathrm{FB}(A,A) \le |A|$, contradicting
the hypothesis. $\square$

**Corollary 5.4 (Structural form).** For every nonempty $A \subseteq G$ and every $a \in A$,
either $|A| < \mathrm{FB}(A,A)$, or $A = a + H$ where $H = \{g \in G : g + A = A\}$ is the
stabiliser subgroup of $A$. That is, the covering bound fails to improve on pigeonhole only for
cosets of subgroups.

*Proof.* If $|A| < |A+A|$ apply Theorem 5.3. Otherwise $|A+A| = |A|$ (the reverse inequality is
pigeonhole), and a set with no doubling in a finite abelian group is a coset of its own
stabiliser: for $a \in A$, $a + H = A$. $\square$

**Proposition 5.5 (Subgroups: exact equality).** Let $H \le G$ be a subgroup, $h = |H|$. Then
$$r_{H,H}(c) = \begin{cases} h, & c \in H,\\ 0, & c \notin H,\end{cases} \qquad
\tilde E(H,H) = h^3, \qquad E(H,H) = |G| h^3 - h^4,$$
and $\mathrm{FB}(H,H) = h^4/h^3 = h = |H+H|$. Thus subgroups are simultaneously the equality
case of the covering bound and the sole obstruction to beating pigeonhole.

*Proof.* For $c \in H$ every $y \in H$ satisfies $c - y \in H$, so $r_{H,H}(c) = h$; for
$c \notin H$ no $y \in H$ has $c - y \in H$, else $c \in H$. Hence
$\tilde E = \sum_{c\in H} h^2 = h^3$, and Theorem 4.1 gives $E$. Finally
$\mathrm{FB} = (h\cdot h)^2/h^3 = h$, and $H+H = H$. $\square$

This is the sharpest possible summary of the bound's quality: it is exactly tight precisely
where it is useless, and strictly informative everywhere else.

---

## 6. Family I: Sidon sets, and the parabola over $\mathbb{Z}/p$

**Definition 6.1.** A set $A \subseteq G$ is a **Sidon set** ($B_2$ set) if for all
$a,b,c,d \in A$, $a+b = c+d$ implies $\{a,b\} = \{c,d\}$ as unordered pairs (formally,
$(a,b)=(c,d)$ or $(a,b)=(d,c)$).

**Lemma 6.2 (Representation function of a Sidon set).** If $A$ is Sidon with $|A| = k$, then
$r_{A,A}(a+a) = 1$ for every $a\in A$, and $r_{A,A}(a+b) = 2$ for all $a \ne b$ in $A$.

*Proof.* Fix $a$. If $y \in A$ and $2a - y \in A$ then $y + (2a-y) = a+a$, so by the Sidon
property $y = a$; thus the fibre is $\{a\}$. Fix $a\ne b$. If $y \in A$ and $a+b-y \in A$ then
$y + (a+b-y) = a+b$ forces $y \in \{a,b\}$, and both occur; the fibre is $\{a,b\}$, of size $2$
since $a \ne b$. $\square$

**Theorem 6.3 (Sidon energies and bound).** Let $A$ be Sidon with $|A| = k \ge 1$. Then
$$\tilde E(A,A) = 2k^2 - k, \qquad E(A,A) = |G|(2k^2-k) - k^4, \qquad
\mathrm{FB}(A,A) = \frac{k^3}{2k-1} \;\ge\; \frac{k^2}{2}.$$
Moreover $\mathrm{FB}(A,A) > k$ whenever $k \ge 2$.

*Proof.* By Proposition 3.2, $\tilde E = \sum_{(a,b)\in A\times A} r_{A,A}(a+b)$. The diagonal
contributes $k$ terms each equal to $1$; the off-diagonal contributes $k^2 - k$ ordered pairs
each equal to $2$. Hence $\tilde E = k + 2(k^2-k) = 2k^2-k$. Theorem 4.1 gives $E$, and
Theorem 4.2 gives $\mathrm{FB} = k^4/(2k^2-k) = k^3/(2k-1)$. Since $2k-1 \le 2k$ we get
$\mathrm{FB} \ge k^2/2$. Finally $k^3/(2k-1) > k \iff k^2 > 2k-1 \iff (k-1)^2 > 0$, true for
$k \ge 2$. $\square$

**Theorem 6.4 (Exact sumset and sharpness).** If $A$ is Sidon with $|A| = k$ then
$$|A+A| = \frac{k(k+1)}{2}, \qquad\text{and}\qquad
|A+A| \;\le\; \Bigl(1 + \frac{1}{2k}\Bigr)\,\mathrm{FB}(A,A).$$

*Proof.* By Lemma 6.2, $r_{A,A}$ takes only the values $1$ and $2$ on its support, so
$r^2 + 2 = 3r$ there. Summing over $A+A$ and using Proposition 3.1,
$\tilde E + 2|A+A| = 3k^2$; with $\tilde E = 2k^2-k$ this gives $2|A+A| = k^2+k$. For the
second claim,
$$\Bigl(1+\frac{1}{2k}\Bigr)\frac{k^3}{2k-1} = \frac{k^2(2k+1)}{2(2k-1)}
\;\ge\; \frac{k(k+1)}{2} \iff k(2k+1) \ge (k+1)(2k-1) \iff k \ge -1 . \qquad\square$$

So on Sidon sets the covering bound is not merely quadratic — it is asymptotically exact.

### 6.1 The parabola

**Definition 6.5.** For an odd prime $p$ let $G = (\mathbb{Z}/p)^2$ and
$P = \{(x, x^2) : x \in \mathbb{Z}/p\}$.

**Lemma 6.6.** $|P| = p$, and $P$ is a Sidon set in $G$ when $p \ne 2$.

*Proof.* The map $x \mapsto (x,x^2)$ is injective (read off the first coordinate), so $|P| = p$.
Suppose $(x,x^2)+(y,y^2) = (u,u^2)+(v,v^2)$. Comparing coordinates,
$$x+y = u+v, \qquad x^2+y^2 = u^2+v^2 .$$
Then $2xy = (x+y)^2 - (x^2+y^2) = (u+v)^2-(u^2+v^2) = 2uv$, and since $2$ is invertible mod $p$
for odd $p$, $xy = uv$. Hence $x$ and $y$ are the two roots of $T^2 - (u+v)T + uv$, i.e.
$(x-u)(x-v) = x^2 - (u+v)x + uv = x^2 - (x+y)x + xy = 0$. So $x = u$ (forcing $y = v$) or
$x = v$ (forcing $y = u$). $\square$

(For $p = 2$ the "parabola" $\{(x,x)\}$ is a line — a subgroup — and by Proposition 5.5 no gain
is possible; the hypothesis $p \ne 2$ is therefore necessary, not technical.)

**Theorem 6.7 (The parabola).** For every odd prime $p$, with $G = (\mathbb{Z}/p)^2$ of order
$p^2$:
$$E(P,P) = p^4 - p^3, \qquad \mathrm{FB}(P,P) = \frac{p^3}{2p-1} \;\ge\; \frac{p^2}{2},
\qquad |P+P| = \frac{p(p+1)}{2},$$
and $\mathrm{FB}(P,P) > p$, the pigeonhole value. The bound is sharp to within the factor
$1 + \frac{1}{2p}$.

*Proof.* Combine Lemma 6.6 with Theorems 6.3 and 6.4 at $k = p$, $|G| = p^2$: indeed
$E = p^2(2p^2-p) - p^4 = p^4 - p^3$. $\square$

The gain over pigeonhole is a full power of $|P|$: from $p$ to $\sim p^2/2$.

---

## 7. Family II: exponent two, and the Hamming ball in $\mathbb{F}_2^n$

In a group of exponent two ($x+x=0$ for all $x$) no set of size $\ge 2$ can be Sidon, since the
entire diagonal maps to $0$. The correct analogue restricts the condition to distinct pairs.

**Definition 7.1.** $A \subseteq G$ is **Sidon off the diagonal** if for all $a,b,c,d \in A$
with $a\ne b$ and $c \ne d$, $a+b = c+d$ implies $\{a,b\} = \{c,d\}$.

**Lemma 7.2 (Triple criterion).** Suppose $x+x = 0$ for all $x \in G$, and suppose that for all
$a,b,y \in A$ with $a \ne b$, $y \ne a$, $y \ne b$ one has $a+b+y \notin A$. Then $A$ is Sidon
off the diagonal.

*Proof.* Let $a\ne b$, $c \ne d$ in $A$ with $a+b = c+d$. If $c = a$ then $b = d$ by
cancellation; if $c = b$ then $a = d$ likewise. Otherwise $c \notin \{a,b\}$, and
$a+b+c = c+d+c = d + (c+c) = d \in A$, contradicting the hypothesis. $\square$

**Lemma 7.3 (Representation function in exponent two).** If $x + x = 0$ for all $x$ and $A$ is
Sidon off the diagonal with $|A| = k$, then $r_{A,A}(0) = k$ and $r_{A,A}(a+b) = 2$ for all
$a \ne b$ in $A$; $r_{A,A}$ vanishes elsewhere.

*Proof.* Since $-y = y$, for every $y \in A$ we have $0 - y = y \in A$, so $r_{A,A}(0) = k$.
For $a \ne b$, if $y \in A$ and $a+b-y = a+b+y \in A$, then the pair $\{y, a+b+y\}$ has sum
$a+b$; it is a pair of distinct elements (if $y = a+b+y$ then $a+b = 0$, i.e. $a = b$), so the
off-diagonal Sidon property gives $y \in \{a,b\}$. Both values occur, so the fibre is
$\{a,b\}$. $\square$

**Theorem 7.4 (Exponent-two energies and bound).** With hypotheses as in Lemma 7.3 and
$k = |A|$:
$$\tilde E(A,A) = 3k^2 - 2k, \qquad E(A,A) = |G|(3k^2-2k) - k^4, \qquad
\mathrm{FB}(A,A) = \frac{k^3}{3k-2} \;\ge\; \frac{k^2}{3},$$
with $\mathrm{FB}(A,A) > k$ for $k \ge 3$. Moreover
$$|A+A| = 1 + \frac{k(k-1)}{2}, \qquad |A+A| \;\le\; \frac{3}{2}\,\mathrm{FB}(A,A),$$
and the factor $3/2$ is asymptotically attained.

*Proof.* By Proposition 3.2 the diagonal of $A\times A$ contributes $k$ terms each equal to
$r_{A,A}(0) = k$, i.e. $k^2$, and the $k^2-k$ ordered off-diagonal pairs contribute $2$ each;
hence $\tilde E = k^2 + 2(k^2-k) = 3k^2-2k$. Theorems 4.1, 4.2 give $E$ and
$\mathrm{FB} = k^4/(3k^2-2k) = k^3/(3k-2) \ge k^3/(3k) = k^2/3$. Strictness against pigeonhole:
$k^3 > k(3k-2) \iff k^2 - 3k + 2 > 0 \iff (k-1)(k-2) > 0$, i.e. $k \ge 3$.

For the sumset: the support consists of $0$ (with $r = k$) together with the distinct sums
$a+b$, $a\ne b$, each with $r = 2$; the number of such sums is $\binom{k}{2}$ by the off-diagonal
Sidon property. Hence $|A+A| = 1 + \binom{k}{2}$. Finally
$$\frac{3}{2}\cdot\frac{k^3}{3k-2} \ge 1 + \frac{k(k-1)}{2}
\iff 3k^3 \ge (k^2-k+2)(3k-2) = 3k^3 -2k^2 -3k^2 + 2k + 6k - 4,$$
i.e. $0 \ge -5k^2 + 8k - 4$, which holds for all $k \ge 1$ since the discriminant
$64 - 80 < 0$. As $k \to \infty$ the two sides are $\sim k^2/2$ and $\sim k^2/2$ respectively
after the factor $3/2$, so the constant cannot be improved. $\square$

The comparison with Theorem 6.3 is exact and structural: the *only* difference between odd and
even characteristic is that in exponent two the diagonal of $A\times A$ deposits $k^2$ units of
energy on the single point $0$ instead of $k$ units spread over $k$ distinct points. That rigid
$k^2$ — not any analytic loss — degrades the constant from $1/2$ to $1/3$ and the accuracy
from $1+\frac{1}{2k}$ to $3/2$.

### 7.1 The Hamming ball

**Definition 7.5.** In $G = \mathbb{F}_2^n = (\mathbb{Z}/2)^n$ let
$\mathcal{B}_n = \{0, e_1, \dots, e_n\}$, the ball of Hamming radius one about the origin.

**Lemma 7.6.** $|\mathcal{B}_n| = n+1$, and $\mathcal{B}_n$ is Sidon off the diagonal.

*Proof.* The $e_i$ are distinct and nonzero, so the cardinality is $n+1$. For the Sidon
property use Lemma 7.2: take $a\ne b$ and $y \notin \{a,b\}$ in $\mathcal{B}_n$ and check in each
case that $a+b+y$ has two coordinates equal to $1$, hence lies outside the ball. For instance
if $a = e_i$, $b = e_j$, $y = e_l$ with $i,j,l$ pairwise distinct, then $a+b+y$ has weight
three; if $a = 0$, $b = e_j$, $y = e_l$ with $j \ne l$, then $a+b+y = e_j + e_l$ has weight two;
if $a = e_i$, $b = e_j$ ($i\ne j$) and $y = 0$, then $a+b+y = e_i+e_j$ again has weight two. In
every case the vector has at least two ones, so it is not in $\mathcal{B}_n$. $\square$

**Theorem 7.7 (The Hamming ball).** For $G = \mathbb{F}_2^n$ (of order $2^n$) and
$\mathcal{B}_n$ as above,
$$\tilde E = 3n^2+4n+1, \qquad E = 2^n(3n^2+4n+1) - (n+1)^4, \qquad
\mathrm{FB} = \frac{(n+1)^3}{3n+1} \;\ge\; \frac{(n+1)^2}{3},$$
with $\mathrm{FB} > n+1$ for $n \ge 2$; the exact sumset size is
$|\mathcal{B}_n + \mathcal{B}_n| = 1 + \frac{n(n+1)}{2}$, and the bound is within a factor
$3/2$ of it.

*Proof.* Apply Theorem 7.4 with $k = n+1$: $\tilde E = 3(n+1)^2 - 2(n+1) = 3n^2+4n+1$, and
$3k - 2 = 3n+1$. $\square$

**Interpretation.** $\mathbb{F}_2^n$ is the configuration space of $n$ classical bits, XOR is
the natural composition of "flip patterns", and $\mathcal{B}_n$ is the set of patterns that flip
at most one bit. Theorem 7.7 says that composing two such elementary operations already reaches
at least $\sim n^2/3$ distinct configurations — quadratically many, whereas pigeonhole certifies
only $n+1$. The true count $1+\binom{n+1}{2}$ is exactly the set of patterns of weight at most
two, as it must be.

---

## 8. Family III: intervals, the minimal-doubling regime

The two families above are as spread out as possible ($|A+A| \asymp |A|^2$). We now go to the
opposite extreme.

**Definition 8.1.** For $2k \le n$ let $I_k = \{0,1,\dots,k-1\} \subseteq \mathbb{Z}/n$, the
image of $\{0,\dots,k-1\}$ under reduction mod $n$ (injective since $k \le n$).

**Lemma 8.2 (Tent function).** Let $2k \le n$ and identify $c \in \mathbb{Z}/n$ with its
representative $m \in \{0,\dots,n-1\}$. Then
$$r_{I_k,I_k}(c) \;=\; \min(k, m+1) - \max(0,\, m+1-k),$$
which is $m+1$ for $0 \le m \le k-1$, is $2k-1-m$ for $k \le m \le 2k-2$, and is $0$ for
$m \ge 2k-1$.

*Proof.* Since $2k \le n$, a pair $(a,b) \in \{0,\dots,k-1\}^2$ has $a+b \le 2k-2 < n$, so no
wraparound occurs and $a + b \equiv m \pmod n$ if and only if $a+b = m$ as integers. The number
of integer solutions with $0\le a,b \le k-1$ and $a+b=m$ is the length of the integer interval
$[\max(0,m+1-k),\ \min(k,m+1))$, which is the stated quantity. $\square$

**Theorem 8.3 (Interval energies and bound).** For $2k \le n$ and $k \ge 1$,
$$\tilde E(I_k,I_k) = \frac{k(2k^2+1)}{3}, \qquad
E(I_k,I_k) = \frac{n\,k(2k^2+1)}{3} - k^4, \qquad
\mathrm{FB}(I_k,I_k) = \frac{3k^3}{2k^2+1}.$$

*Proof.* By Lemma 8.2,
$$\tilde E = \sum_{m=0}^{k-1}(m+1)^2 + \sum_{m=k}^{2k-2}(2k-1-m)^2
= \sum_{j=1}^{k} j^2 + \sum_{j=1}^{k-1} j^2 = \frac{k(k+1)(2k+1)}{6} + \frac{(k-1)k(2k-1)}{6}.$$
Expanding, the numerator is $k\bigl[(k+1)(2k+1) + (k-1)(2k-1)\bigr] = k\bigl[2k^2+3k+1 +
2k^2-3k+1\bigr] = k(4k^2+2)$, so $\tilde E = k(4k^2+2)/6 = k(2k^2+1)/3$. Theorem 4.1 gives $E$
(using $|G| = n$, $|I_k| = k$), and Theorem 4.2 gives
$\mathrm{FB} = k^4 / \bigl(k(2k^2+1)/3\bigr) = 3k^3/(2k^2+1)$. $\square$

**Theorem 8.4 (Exact sumset, and two-sided accuracy).** For $2k \le n$:
$$I_k + I_k = I_{2k-1}, \qquad |I_k + I_k| = 2k-1 .$$
Moreover, for $k \ge 2$,
$$k \;<\; \mathrm{FB}(I_k,I_k) \;<\; 2k-1 \;\le\; \frac43\,\mathrm{FB}(I_k,I_k),$$
so the ratio $\mathrm{FB}/|I_k+I_k|$ lies in $[3/4, 1)$ for every $k \ge 2$, and
$\mathrm{FB}(I_k,I_k) \ge \tfrac{3k}{2} - 1$.

*Proof.* The set identity is Lemma 8.2 (the support of the tent is exactly
$\{0,\dots,2k-2\}$), and $2k-1 \le n$ gives $|I_{2k-1}| = 2k-1$.

*Beating pigeonhole.* $3k^3 > k(2k^2+1) \iff 3k^2 > 2k^2+1 \iff k^2 > 1$, true for $k \ge 2$.

*Never tight.* $3k^3 < (2k-1)(2k^2+1) = 4k^3 - 2k^2 + 2k - 1 \iff 0 < k^3 - 2k^2 + 2k - 1
= (k-1)(k^2-k+1)$, true for $k \ge 2$.

*Within $4/3$.* $4\cdot 3k^3 \ge 3(2k-1)(2k^2+1) \iff 12k^3 \ge 12k^3 - 6k^2 + 6k - 3
\iff 6k^2 - 6k + 3 \ge 0$, true for all $k$.

*Linear lower bound.* $\frac{3k^3}{2k^2+1} \ge \frac{3k}{2} - 1 \iff 6k^3 \ge (3k-2)(2k^2+1)
= 6k^3 - 4k^2 + 3k - 2 \iff 4k^2 - 3k + 2 \ge 0$, true for all $k \ge 0$. $\square$

Theorem 8.4 is the qualitative point of this section. Intervals are the extremal configuration
for Cauchy–Davenport/Freiman minimal doubling: $|I_k+I_k| = 2k-1$ is as small as a
non-degenerate sumset can be. There is therefore no room for a power gain, and yet the second
moment still detects a constant-factor improvement, converging to $\frac{3}{2}k$ against the
truth $2k-1$: a systematic deficit of exactly $25\%$ in the limit, never more than $25\%$ and
never zero.

**Summary of the three regimes.** With $k = |A|$:

| family | $\tilde E(A,A)$ | $E(A,A)$ | bound | $|A+A|$ | bound/truth |
|---|---|---|---|---|---|
| Sidon | $2k^2-k$ | $\vert G\vert(2k^2-k)-k^4$ | $\dfrac{k^3}{2k-1}$ | $\dfrac{k(k+1)}{2}$ | $\to 1$ |
| exponent-two Sidon | $3k^2-2k$ | $\vert G\vert(3k^2-2k)-k^4$ | $\dfrac{k^3}{3k-2}$ | $1+\dbinom{k}{2}$ | $\to 2/3$ |
| interval | $\dfrac{k(2k^2+1)}{3}$ | $\dfrac{n k(2k^2+1)}{3}-k^4$ | $\dfrac{3k^3}{2k^2+1}$ | $2k-1$ | $\in[3/4,1)$ |
| subgroup | $k^3$ | $\vert G\vert k^3-k^4$ | $k$ | $k$ | $=1$ |

---

## 9. Algorithms and complexity

Three computational tasks arise, in decreasing order of cost.

**(A) Direct spectral evaluation of $E$.** Enumerate the $|G|$ characters, compute
$\widehat{1_A}(\psi) = \sum_{a\in A}\overline{\psi(a)}$ for each, and sum
$|\widehat{1_A}|^2|\widehat{1_B}|^2$ over $\psi \ne 0$. Cost: $O(|G|(|A|+|B|))$ complex
operations naively, $O(|G|\log|G|)$ with a fast transform. This is the definition, and it is
only ever needed as a check.

**(B) Combinatorial evaluation via the energy identity.** Compute the representation function
by convolution — either by the $O(|A||B|)$ direct double loop, accumulating $r(a+b)$, or by a
fast transform in $O(|G|\log|G|)$ — then set
$$\tilde E = \sum_c r(c)^2, \qquad E = |G|\tilde E - (|A||B|)^2 .$$
Since $|A||B| \le |G|^2$ but is typically far smaller, the direct loop is the method of choice
for sparse sets, and it never touches a complex number: all arithmetic is exact integer
arithmetic. This is Theorem A used as an algorithm, and it is the recommended route.

**(C) Closed forms.** For the families of Sections 6–8 no computation is needed at all:
$$\tilde E = 2k^2-k \ (\text{Sidon}), \quad 3k^2-2k \ (\text{exponent-two Sidon}), \quad
\tfrac{1}{3}k(2k^2+1)\ (\text{interval}), \quad k^3 \ (\text{subgroup}),$$
and $E = |G|\tilde E - k^4$ in each case. Cost: $O(1)$.

A fourth task is *auditing* a set: given $A$, decide whether the bound beats pigeonhole. By
Theorem 5.3 this is equivalent to deciding whether $|A+A| > |A|$, which costs $O(|A|^2)$ set
insertions — no energy computation required. The numerical value of the gain, however, does
require $\tilde E$.

---

## 10. Discussion

### 10.1 What the collapse does and does not say

Theorem B says that a covering bound derived by one application of Cauchy–Schwarz to the
nonprincipal spectrum carries exactly the information of the first two moments of $r_{A,B}$.
It does not say that Fourier analysis is useless in this context; it delimits precisely which
Fourier arguments can beat it. Any argument that uses only $\|\widehat{r}\|_2$ is subsumed.
Arguments that use $\sup_{\psi\ne0}|\widehat{1_A}(\psi)|$, or the *number* of large Fourier
coefficients (as in Bogolyubov/Chang-type arguments), or higher $L^p$ norms of the spectrum,
use genuinely more than the second moment and are not subsumed. The identity
$E = |G|\tilde E - (|A||B|)^2$ is thus a diagnostic: it isolates the exact point at which a
Fourier argument stops being combinatorics in disguise.

### 10.2 The physical reading

The nonprincipal energy $E$ is the "modal energy" of the configuration: it measures how much of
the indicator data sits in nontrivial modes of the group, i.e. how far the set is from being
spectrally featureless. Total modal energy, our identity shows, is a coarse invariant — it is
a count of coincidences, and it cannot distinguish a set concentrating all its structure in a
single enormous mode from one distributing the same energy across all modes. Resolving these
requires the shape of the spectrum, not its norm.

The exponent-two family makes this concrete in the language of physical state spaces.
$\mathbb{F}_2^n$ is the configuration space of $n$ two-level systems, and $\mathcal{B}_n$ is the
set of operations flipping at most one of them. The bound certifies that composing two such
operations reaches $\gtrsim n^2/3$ configurations. The degradation from the odd-characteristic
constant $1/2$ to $1/3$ is a pure involution effect: because every flip is its own inverse, the
$n+1$ trivial compositions $x + x$ all pile onto the identity configuration, wasting $k^2$
units of energy at a single point. The gap of $3/2$ between bound and truth in exponent two is
exactly the accounting cost of that pile-up.

### 10.3 The accuracy hierarchy

The three families quantify the accuracy of the second-moment method across the whole doubling
spectrum:

- **maximal doubling** ($|A+A| \sim k^2/2$, Sidon): accuracy $\to 1$, error $\le 1+\frac1{2k}$;
- **maximal doubling in exponent two** ($|A+A|\sim k^2/2$ with a collapsed diagonal): accuracy
  $\to 2/3$;
- **minimal doubling** ($|A+A| = 2k-1$, intervals): accuracy in $[3/4,1)$;
- **no doubling** (cosets): accuracy exactly $1$, but no gain over pigeonhole.

The method is therefore never worse than a bounded factor on these families and asymptotically
exact on the most spread-out ones. Its weakness is not inaccuracy but insensitivity: it cannot
see anything that the distribution of $r$ does not already record in its first two moments.

---

## 11. Open problems and future directions

**Problem 1 (Universality of the characteristic defect).** Is the exponent-two computation
extremal? Precisely: for every finite abelian $G$ of exponent two and every $A \subseteq G$
with $|A| = k$, is $\tilde E(A,A) \ge 3k^2 - 2k$, with equality if and only if $A$ is Sidon off
the diagonal? An affirmative answer would show that no subset of $\mathbb{F}_2^n$ can push the
covering bound above $k^3/(3k-2)$, whereas in odd characteristic $k^3/(2k-1)$ is attained. The
mechanism is visible: in exponent two the diagonal of $A\times A$ is forced onto the single
point $0$, contributing $k^2$ to $\tilde E$ before any off-diagonal collision occurs, and this
rigid contribution — not any Fourier-analytic loss — is the entire source of the $3/2$ gap. Both
sides of the comparison are now closed-form identities, so the problem is a finite convexity
question about the distribution of $r$, not a new spectral estimate.

**Problem 2 (Systematic deficit against Cauchy–Davenport).** In $\mathbb{Z}/p$ the
Cauchy–Davenport theorem gives $|A+A| \ge \min(p, 2k-1)$, matching the interval exactly. The
second-moment bound converges to $\frac32 k$ on intervals, a deficit factor of $3/4$. Is
$\frac{3}{4}$ the worst case, i.e. does
$$\frac{(|A||A|)^2}{\tilde E(A,A)} \;\ge\; \frac34 \min(p, 2|A|-1)$$
hold for all $A \subseteq \mathbb{Z}/p$? Equivalently, is the interval the minimiser of the
ratio (second-moment bound)/(true sumset size) among sets of given size in a cyclic group of
prime order?

**Problem 3 (Interpolating families).** The three families computed here sit at
$\sigma(A) = |A+A|/|A| \approx k/2$, $\approx k/2$ (exponent two) and $\approx 2$. Construct
families with $\sigma$ of intermediate order — for example generalised arithmetic progressions
of rank $d$, or unions of $t$ intervals — and compute $\tilde E$ (hence $E$) in closed form as
a function of $(k, \sigma)$. Conjecturally the accuracy of the second-moment bound is a
monotone function of $\sigma$, interpolating between $3/4$ at minimal doubling and $1$ at
maximal doubling.

**Problem 4 (Asymmetric pairs).** All explicit computations here take $B = A$. For $B \ne A$
the dichotomy of Theorem 5.3 has no known clean analogue: the correct statement should
characterise the pairs for which $(|A||B|)^2/\tilde E(A,B) \le \max(|A|,|B|)$, presumably in
terms of $A$ and $B$ being cosets of a common subgroup, possibly with $A$ or $B$ contained in a
coset. Formulate and prove the asymmetric dichotomy.

**Problem 5 (Beyond the second moment).** Given that the covering bound is exactly the
second-moment bound, the natural refinement is the third-moment or entropy bound: for
nonnegative $r$ with known $\sum r$, $\sum r^2$ and $\sum r^3$, the support is bounded below by
an explicit function of the three moments strictly larger than $(\sum r)^2/\sum r^2$ unless $r$
is constant on its support. For Sidon sets the third moment is $\sum r^3 = k + 4(k^2-k)$, giving
a computable improvement; quantify the gain on the three families and identify the spectral
quantity — necessarily not $\|\widehat r\|_2$ — that the third moment corresponds to.

**Problem 6 (Continuous and non-abelian analogues).** Both Parseval and the second-moment
inequality survive in compact groups and, with the appropriate representation-theoretic
Plancherel formula, in finite non-abelian groups, where $E$ becomes a weighted sum over
irreducible representations of dimension-weighted matrix norms. Determine whether the analogue
of the collapse identity holds verbatim (the dimensional weights suggest not, and the
discrepancy would be an honest measure of noncommutativity).

---

## 12. Conclusion

The nonprincipal Fourier energy appearing in the covering bound
$|A+B| \ge |G|(|A||B|)^2/((|A||B|)^2+E)$ is not an independent analytic quantity: Parseval
gives $E = |G|\tilde E(A,B) - (|A||B|)^2$ in terms of the additive energy, and the bound
collapses exactly to the second-moment ratio $(|A||B|)^2/\tilde E(A,B)$. This makes $E$
computable wherever additive quadruples are countable, and we have computed it in closed form
for Sidon sets (the parabola over $\mathbb{Z}/p$, $E = p^4-p^3$), for sets Sidon off the
diagonal in exponent two (the Hamming ball in $\mathbb{F}_2^n$,
$E = 2^n(3n^2+4n+1)-(n+1)^4$), for intervals in $\mathbb{Z}/n$
($E = \frac{nk(2k^2+1)}{3}-k^4$), and for subgroups ($E = |G|h^3-h^4$). The resulting bounds
beat pigeonhole for every set of strictly positive doubling — the sole exceptions being cosets
of subgroups, where the bound is exactly sharp — and their accuracy against the true sumset
size is quantified in every case: a factor $1+\frac{1}{2k}$ on Sidon sets, exactly $3/2$
asymptotically in exponent two, and a window $[3/4,1)$ on intervals.
