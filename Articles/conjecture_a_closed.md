# The Shadow a Symmetry Casts

## How counting arrangements of $k$ objects tells you everything about a symmetry group's fixed points

Imagine you are handed a black box. Inside is a finite set of objects — beads, atoms, colours, whatever you like — and a finite group of symmetries shuffling them around. You are not allowed to look inside. You may only ask the box one kind of question:

> *"If I make necklaces of length $k$ out of your objects, how many genuinely different necklaces are there?"*

That is, you may ask for the number of orbits on $k$-tuples: the number of ways to choose an ordered list $(x_1, \dots, x_k)$ of objects from the set, counted up to the symmetry that acts on all coordinates at once. You may ask this for $k = 0, 1, 2, 3, \dots$

How much can you learn? Remarkably, the answer is: **essentially everything about the fixed-point structure of the action** — and you only need to ask finitely many questions before the box has told you all it will ever tell you.

This article is about that phenomenon, which turns out to be a crisp statement about power sums of multisets in disguise, complete with an exactly optimal threshold and an explicit example proving the threshold cannot be improved.

---

## Two invariants

Let $G$ be a finite group acting on a finite set $X$. There are two natural "combinatorial shadows" of the action.

**The trace distribution.** For each group element $g$, let $X^g = \{x \in X : g\cdot x = x\}$ be its fixed-point set, and let $|X^g|$ be its size. As $g$ ranges over $G$, these numbers form a *multiset* — a list where multiplicities matter but order does not:
$$\mathrm{tr}(G \curvearrowright X) \;=\; \bigl\{\!\bigl|\, |X^g| \;:\; g \in G \,\bigr|\!\bigr\}.$$
This multiset always has exactly $|G|$ entries, one for each group element. Representation theorists will recognise the numbers $|X^g|$ as the values of the *permutation character* of the action; the trace distribution is that character stripped of the labelling by group elements, retained only as an unordered bag of values.

**The orbit spectrum.** For each $k \ge 0$, let $X^{(k)}$ denote the set of $k$-tuples $(x_1,\dots,x_k)$ of elements of $X$, with $G$ acting diagonally: $g \cdot (x_1,\dots,x_k) = (g x_1, \dots, g x_k)$. Write
$$N_k(X) \;=\; \#\{\text{$G$-orbits on $X^{(k)}$}\}.$$
This is the sequence of answers your black box gives you. $N_0 = 1$ always (there is one empty tuple). $N_1$ is the ordinary number of orbits. $N_2$ counts orbits of ordered pairs — in permutation-group language, the number of *orbitals*.

These two invariants look quite different. The first is a static snapshot of how much each symmetry leaves untouched; the second is a growing sequence of enumeration data. The main theorem says they are the same information.

---

## Burnside, graded

The bridge between them is one of the oldest formulas in combinatorics, usually attributed to Burnside (and, more accurately, to Cauchy and Frobenius). It says that the number of orbits of a finite group acting on a finite set is the *average* number of fixed points:
$$\#\{\text{orbits}\} \cdot |G| \;=\; \sum_{g \in G} |X^g|.$$

The trick — and it really is the whole trick — is to apply this not to $X$ but to $X^{(k)}$. A tuple $(x_1,\dots,x_k)$ is fixed by $g$ precisely when *every one of its entries* is fixed by $g$. So the fixed-point set of $g$ on $k$-tuples is a $k$-fold Cartesian power:
$$(X^{(k)})^g \;=\; (X^g)^k, \qquad\text{hence}\qquad \bigl|(X^{(k)})^g\bigr| = |X^g|^k .$$

Feeding this into Burnside gives the **graded Burnside lemma**:
$$\boxed{\;N_k(X)\cdot |G| \;=\; \sum_{g\in G} |X^g|^{\,k}\;}$$

Read the right-hand side again. If we write the trace distribution as a multiset $A = \{|X^g| : g \in G\}$, then $\sum_{g} |X^g|^k$ is exactly the **$k$-th power sum**
$$p_k(A) = \sum_{a \in A} a^k .$$

So the orbit spectrum is *nothing but* the sequence of power sums of the trace distribution, rescaled by $|G|$. The black box, asked about $k$-tuples, is quietly reciting power sums.

At $k=0$ this reads $N_0 |G| = |G|$, i.e. $1 = 1$: the count of entries. At $k=1$ it is Burnside's lemma itself. At $k = 2$, $3$, $\dots$ it is new information — and the question becomes: *how much of a multiset is determined by its power sums, and how many of them do you need?*

---

## Recovering a bag of numbers from its power sums

Here is the combinatorial heart of the matter, phrased with no groups in sight.

> **Power-sum rigidity.** Let $A$ and $B$ be finite multisets of non-negative integers, and suppose the set of values occurring in $A$ or $B$ has at most $n$ distinct elements. If
> $$\sum_{a\in A} a^k \;=\; \sum_{b \in B} b^k \qquad\text{for every } k < n,$$
> then $A = B$.

There is also a convenient value-bounded version: if every element of $A$ and of $B$ is at most $n$, then agreement of $p_0, p_1, \dots, p_n$ forces $A = B$ (because at most $n+1$ distinct values can occur).

The classical route to such a statement is Newton's identities, converting power sums into elementary symmetric functions and then into a polynomial whose roots are the entries. That works, but it needs the two multisets to have the same size to begin with, and it needs division by integers.

There is a slicker argument, and it is the one used here: **Lagrange-interpolation duality**. Let $S$ be the (finite) set of distinct values appearing in $A$ or $B$, with $|S| \le n$. Define a signed weight on $S$,
$$c(m) \;=\; \mathrm{mult}_A(m) - \mathrm{mult}_B(m),$$
the difference of the multiplicities of the value $m$ in the two multisets. The hypothesis says precisely that this signed weight annihilates every monomial:
$$\sum_{m \in S} c(m)\, m^k \;=\; 0 \qquad (k = 0,1,\dots,n-1).$$
By linearity, $c$ annihilates *every* polynomial of degree $< n$. But $|S| \le n$, so for each node $m_0 \in S$ there is a Lagrange basis polynomial
$$L_{m_0}(x) \;=\; \prod_{m \in S,\; m \ne m_0} \frac{x - m}{m_0 - m}$$
of degree $|S| - 1 < n$, which is $1$ at $m_0$ and $0$ at all other nodes. Applying $c$ to it gives $c(m_0) = 0$. Since $m_0$ was arbitrary, all multiplicities agree, so $A = B$. $\blacksquare$

Two things are worth noticing. First, the argument never assumes $|A| = |B|$: the case $k=0$ of the hypothesis, $p_0(A) = p_0(B)$, *is* the statement that the cardinalities agree, and it comes for free. Second, the bound is stated in terms of the number of *distinct* values, which is often far smaller than the largest value — and that refinement will pay a dividend in a moment.

---

## The main theorem

Combining the graded Burnside lemma with power-sum rigidity gives the result we were after. Let $G$ be a finite group acting on two finite sets $X$ and $Y$.

> **Theorem (trace distributions are orbit spectra).** The following are equivalent:
> 1. $X$ and $Y$ have the same trace distribution: $\{|X^g| : g \in G\} = \{|Y^g| : g \in G\}$ as multisets;
> 2. $N_k(X) = N_k(Y)$ for every $k \le \max(|X|,|Y|)$;
> 3. $N_k(X) = N_k(Y)$ for every $k \ge 0$.

The implication (1) $\Rightarrow$ (3) is the easy direction: equal multisets have equal power sums, and by graded Burnside the orbit counts are power sums divided by the fixed positive number $|G|$. The implication (3) $\Rightarrow$ (2) is trivial. The substance is (2) $\Rightarrow$ (1): every fixed-point count $|X^g|$ is at most $|X|$, and likewise for $Y$, so all values in both trace distributions are bounded by $M = \max(|X|,|Y|)$; graded Burnside converts the hypothesis into agreement of the power sums $p_0, \dots, p_M$; and rigidity closes the case.

The composite (2) $\Rightarrow$ (3) deserves its own name. It says the orbit spectrum is a **rigid sequence**: two actions whose $k$-tuple counts agree over the finite window $0 \le k \le \max(|X|,|Y|)$ can never diverge afterwards, no matter how far out you look. Finitely much data pins down an infinite sequence. If your black box has answered your first $\max(|X|,|Y|)+1$ questions the same way as another box, the two boxes will agree forever.

---

## A threshold that ignores the set entirely

The bound $\max(|X|,|Y|)$ is wasteful when a small group acts on a huge set. Suppose $G = \mathbb{Z}/2$ acts on a million points. Must you really count orbits on million-tuples?

No. Recall that rigidity is really governed by the number of *distinct values*, not their size. The trace distribution of $X$ has exactly $|G|$ entries; so does that of $Y$; between them they can exhibit at most $2|G|$ distinct values. Hence:

> **Group-order bound.** Two finite $G$-sets $X$ and $Y$ have the same trace distribution if and only if $N_k(X) = N_k(Y)$ for all $k < 2|G|$ — regardless of how large $X$ and $Y$ are.

For $\mathbb{Z}/2$ acting on a million points, $k \le 3$ suffices. Combining the two thresholds, only the first
$$\min\bigl(2|G|,\; \max(|X|,|Y|)+1\bigr)$$
orbit counts are ever needed.

---

## The generating-function repackaging

Multisets of natural numbers are the same thing as polynomials with non-negative integer coefficients. Encoding the trace distribution as a $q$-series makes this vivid: define the **fixed-point generating polynomial**
$$Z_X(q) \;=\; \sum_{g \in G} q^{\,|X^g|}.$$
Its coefficient of $q^m$ is the number of group elements fixing exactly $m$ points; that is precisely the multiplicity of $m$ in the trace distribution. So $Z_X = Z_Y$ if and only if the two trace distributions agree, and the theorem takes gradewise form:

> **Gradewise ($q$-series) form.** $Z_X(q) = Z_Y(q)$ if and only if $N_k(X) = N_k(Y)$ for all $k \le \max(|X|,|Y|)$ — and then for all $k$.

The polynomial $Z_X$ is a genuinely complete invariant of the data the orbit spectrum can see. It is also easy to manipulate: for a disjoint union of $G$-sets, $|X^g|$ adds, so $Z_{X \sqcup Y}$ is obtained by multiplying the corresponding monomials; for a product, $|X^g|$ multiplies. These little functorial rules make the invariant computable for any $G$-set built out of smaller ones.

---

## The smallest interesting example

Take $G = \mathbb{Z}/2 = \{e, \sigma\}$.

Let $X = G$ itself, acted on by translation. The identity fixes both points; $\sigma$ fixes none. Trace distribution: $\{2, 0\}$, and $Z_X(q) = q^2 + 1$. Graded Burnside gives
$$N_k(X) = \frac{2^k + 0^k}{2} = 1, 1, 2, 4, 8, 16, \dots$$

Let $Y$ be a single point with the trivial action. Both group elements fix the one point. Trace distribution: $\{1,1\}$, $Z_Y(q) = 2q$, and
$$N_k(Y) = \frac{1^k + 1^k}{2} = 1,1,1,1,\dots$$

The two agree at $k = 0$ (one empty tuple each) and at $k=1$ (one orbit each — the regular action is transitive), and they part company at $k=2$: two orbits of ordered pairs versus one. That is exactly at the boundary $\max(|X|,|Y|) = \max(2,1) = 2$.

This tiny example carries a moral. **Burnside's lemma alone is blind.** The ordinary orbit count $N_1$ cannot distinguish the regular action of any group $G$ (which is transitive, so $N_1 = 1$) from the one-point action (also $N_1 = 1$), and $N_0 = 1$ for both. Whenever $|G| \ge 2$ the two have different trace distributions, and they are separated only at $k=2$, where the regular action has $|G|$ orbits of pairs and the point has one. So no version of the theorem with the range shortened to $k \le 1$ can possibly be true: the higher grades are doing real work.

---

## The threshold is exactly right

Could the window $k \le \max(|X|,|Y|)$ be shortened by even one? For the underlying multiset statement, no — and there is a beautiful explicit obstruction, built out of the finite-difference operator.

For each $n$, split the alternating binomial coefficients $(-1)^{n-k}\binom{n}{k}$, $0 \le k \le n$, according to sign. Let
$$A_n \;=\; \text{the multiset in which each } k \text{ with } n-k \text{ even occurs } \tbinom{n}{k}\ \text{times},$$
$$B_n \;=\; \text{the multiset in which each } k \text{ with } n-k \text{ odd occurs } \tbinom{n}{k}\ \text{times}.$$

For $n=2$ this is $A_2 = \{0, 2\}$ and $B_2 = \{1,1\}$ — the pair we just met. For $n = 3$: $A_3 = \{1,1,1,3\}$ and $B_3 = \{0, 2,2,2\}$.

The classical fact that the $n$-th finite difference annihilates polynomials of degree $< n$ says
$$\sum_{k=0}^{n} (-1)^{n-k}\binom{n}{k} k^{\,j} = 0 \qquad (j < n),$$
which translates exactly into $p_j(A_n) = p_j(B_n)$ for all $j < n$. And the companion fact that the $n$-th difference of $x^n$ is $n!$ says
$$\sum_{k=0}^{n} (-1)^{n-k}\binom{n}{k} k^{\,n} = n! ,$$
so the two multisets first disagree at degree $n$, and the discrepancy there is precisely the factorial $n!$. The multisets themselves are certainly different (the top value $n$ appears in exactly one of them, with multiplicity $1$), and every element of both is at most $n$; moreover their joint support is *all* of $\{0,1,\dots,n\}$, so even the support-based threshold is saturated.

Conclusion: $n+1$ power sums suffice to determine a multiset with values in $\{0,\dots,n\}$, and $n$ power sums do not. Both thresholds appearing in the theorem are genuinely necessary — the value-bounded one by the alternating binomial pair, the range $k \le 1$ prohibition by the regular-versus-point example.

---

## Why one might care

The trace distribution is, in disguise, an old and much-studied object. Two $G$-sets with $|X^g| = |Y^g|$ *pointwise* are called **Gassmann equivalent**, and this is the mechanism behind arithmetically equivalent number fields (different fields with the same Dedekind zeta function) and behind Sunada's construction of isospectral, non-isometric Riemannian manifolds — the "can one hear the shape of a drum?" counterexamples. The theorem here says that the *unordered* version of that data, the trace distribution, is exactly the information recoverable from counting orbits on tuples.

The practical content is a decision procedure. Given two actions, to test whether they have the same fixed-point profile you need not inspect the group element by element: count orbits on $k$-tuples for
$$k < \min\bigl(2|G|,\;\max(|X|,|Y|)+1\bigr)$$
and you are done. And the rigidity statement means such a test can never be fooled by data that agrees for a while and then diverges.

There is a second, more philosophical reading. The sequence $N_0, N_1, N_2, \dots$ is a kind of *spectrum* of the action, analogous to a sequence of moments of a probability distribution. The theorem is then the statement that this discrete moment problem is *determinate*, with an effective and sharp bound on how many moments are needed. Moment problems in analysis notoriously require care — a distribution on the real line need not be determined by its moments. Here, because the "measure" is supported on finitely many non-negative integers with bounded support, determinacy is not just true but effective and optimal.

---

## What comes next

Two questions sit immediately beyond the horizon.

The first is about upgrading unordered data to ordered data. The trace distribution forgets *which* group element fixes how many points. But one can run the theorem separately inside every cyclic subgroup $C = \langle g\rangle \le G$, using the fact that $X^g = X^{\langle g \rangle}$. Each such run returns a multiset of fixed-point counts graded by the order of the elements, and Möbius inversion over the divisor lattice of $|C|$ should convert that graded bundle of unordered data into genuinely pointwise information — recovering $|X^g|$ for every single $g$, i.e. full Gassmann equivalence, from orbit counts of restrictions to cyclic subgroups.

The second is about realisability. The alternating binomial pair shows the multiset threshold is attained by *some* pair of multisets. Are those multisets ever trace distributions of actual group actions? For $n=2$ the answer is yes: $\{0,2\}$ and $\{1,1\}$ are the regular and trivial $\mathbb{Z}/2$-sets. In general, a multiset of size $|G|$ is a trace distribution exactly when it is the mark vector of a genuine (non-virtual) element of the Burnside ring — a lattice-point condition on the table of marks. Whether the extremal pairs live inside that cone, for every $n$, is open.

Either way, the picture is settled for the question we started with. Ask the black box how many necklaces it can make, for a bounded and explicitly computable range of lengths. It will tell you exactly how much each of its symmetries leaves standing — and nothing you ask afterwards will change the answer.
