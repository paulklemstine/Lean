# Antichains, Height, and the Strict Growth of Boolean-Lattice Extremal Numbers

**Author:** Aristotle
**Date:** 2026-08-06

## Abstract

For a finite poset $P$, the extremal number $\mathrm{La}(n, P)$ is the largest size of a family of subsets of $[n]$ containing no weak copy of $P$, and $\mathrm{La}^*(n, P)$ is its analogue for strong (induced) copies. We study the case in which the forbidden poset is itself a Boolean lattice $B_d$, the family of all subsets of a $d$-element set ordered by inclusion.

Our central result is an **Antichain Augmentation Theorem**: if $\mathcal{F} \subseteq 2^{[n]}$ contains no weak copy of $B_d$ and $\mathcal{L} \subseteq 2^{[n]}$ is an antichain, then $\mathcal{F} \cup \mathcal{L}$ contains no weak copy of $B_{d+1}$; the same statement holds for strong copies. The proof rests on a lifting construction: for every antichain $A \subseteq B_{d+1}$ there is an order embedding $B_d \hookrightarrow B_{d+1}$ whose image is disjoint from $A$, obtained by adjoining the new atom exactly along an up-set determined by $A$.

Three families of consequences follow. First, **strict monotonicity in the forbidden dimension**: $\mathrm{La}(n, B_d) < \mathrm{La}(n, B_{d+1})$ and $\mathrm{La}^*(n, B_d) < \mathrm{La}^*(n, B_{d+1})$ for every $n \ge d$, and the condition $d \le n$ is necessary as well as sufficient; iterating, $\mathrm{La}(n, B_d) + k \le \mathrm{La}(n, B_{d+k})$ whenever $d + k \le n + 1$. Previously strictness was available only at the single boundary value $n = d+1$. Second, a **quantitative refinement** obtained by augmenting with the largest layer of the complement of an extremal family:
$$2^n + n\,\mathrm{La}(n, B_d) \;\le\; (n+1)\,\mathrm{La}(n, B_{d+1}) \qquad \text{for all } n, d,$$
so the gain $\mathrm{La}(n,B_{d+1}) - \mathrm{La}(n,B_d)$ is at least $(2^n - \mathrm{La}(n,B_d))/(n+1)$, of order $\binom{n}{\lfloor n/2\rfloor}/\sqrt{n}$ for fixed $d$. Third, **height criteria**: a family with no chain of $d+1$ sets is weak $B_d$-free — a strict generalization of the classical layer construction, requiring neither completeness of layers nor permutation invariance — while weak $B_d$-freeness forces the absence of chains of $2^d$ sets. Both thresholds are shown to be sharp. We also record the by-product that any family realizing at most $d$ distinct set sizes is weak $B_d$-free.

We complement the theory with exhaustive computations of $\mathrm{La}(n, B_d)$ and $\mathrm{La}^*(n, B_d)$ for $n \le 4$, and close with a programme of falsifiable conjectures, chief among them the subadditivity conjecture that the union of a weak $B_d$-free and a weak $B_e$-free family is weak $B_{d+e}$-free.

**Keywords:** forbidden subposet problem, Boolean lattice, antichain, Sperner theory, extremal set theory, Mirsky decomposition, order embedding.

---

## 1. Introduction

### 1.1 The forbidden subposet problem

Let $[n] = \{1, \dots, n\}$ and let $2^{[n]}$ denote the power set of $[n]$ partially ordered by inclusion. A *family* is a subset $\mathcal{F} \subseteq 2^{[n]}$. Given a finite poset $P$, the forbidden subposet problem asks for the maximum size of a family that does not contain $P$ in a prescribed sense.

The subject begins with Sperner's theorem (1928): a family in which no member contains another has at most $\binom{n}{\lfloor n/2 \rfloor}$ members, with equality for a central layer. Erdős extended this: a family with no chain of $k+1$ sets has at most the sum of the $k$ largest binomial coefficients $\binom{n}{i}$, again attained by $k$ consecutive central layers. Both results identify the extremum with a *layer family*, and much of the field is about the extent to which this phenomenon persists for other forbidden posets.

For a general $P$ the answer is governed, conjecturally, by a layer invariant. Write $e(P)$ for the largest $d$ such that the union of some $d$ consecutive layers of $2^{[n]}$, for all large $n$, is weak $P$-free; then $\mathrm{La}(n, P) \ge (e(P) + o(1))\binom{n}{\lfloor n/2\rfloor}$, and a much-studied conjecture asserts equality. The Boolean lattices $B_d$ are the fundamental test cases: $e(B_d) = e^*(B_d) = d$, since $d$ consecutive layers have no chain of $d+1$ sets while $B_d$ contains one, and adding any set outside those layers creates even a strong copy of $B_d$. The case $d = 3$ is the first where the conjectural equality is in doubt.

### 1.2 What this paper does

We are concerned not with the constant in front of $\binom{n}{\lfloor n/2\rfloor}$ but with a more basic structural question: *how does $\mathrm{La}(n, B_d)$ behave as $d$ varies with $n$ fixed?* Monotonicity, $\mathrm{La}(n, B_d) \le \mathrm{La}(n, B_{d+1})$, is immediate, because a weak copy of $B_{d+1}$ contains a weak copy of $B_d$. Strictness is not: it asks that relaxing the ban from $B_d$ to $B_{d+1}$ always buys at least one additional set, and the naive attempt to prove it — adjoin a missing set to an extremal family and hope — founders because deleting one vertex from a copy of $B_{d+1}$ leaves no copy of $B_d$ in any obvious way.

We resolve this. The mechanism is a lifting construction inside the cube (Section 3) which yields the Antichain Augmentation Theorem (Section 4): adjoining an antichain to a weak $B_d$-free family produces a weak $B_{d+1}$-free family. Everything else in the paper is an application: strict monotonicity in full (Section 5), a pigeonhole strengthening (Section 6), and height criteria with matching sharpness examples (Section 7). Section 8 reports exhaustive computations for $n \le 4$, and Section 9 lays out the resulting conjectures.

---

## 2. Definitions

Throughout, $\alpha$ is a finite ground set with $|\alpha| = n$; we write $2^{\alpha}$, or $2^{[n]}$, for its power set ordered by inclusion, and $B_d$ for the Boolean lattice of all subsets of a fixed $d$-element index set, again ordered by inclusion. Thus $|B_d| = 2^d$ and $B_1$ is a two-element chain.

**Definition 2.1 (Weak copy).** A family $\mathcal{F} \subseteq 2^{\alpha}$ *contains a weak copy* of a finite poset $P$ if there exists an injective map $\iota : P \to \mathcal{F}$ such that
$$p < q \ \Longrightarrow\ \iota(p) \subsetneq \iota(q) \qquad (p, q \in P).$$
$\mathcal{F}$ is *weak $P$-free* if no such $\iota$ exists.

**Definition 2.2 (Strong copy).** $\mathcal{F}$ *contains a strong copy* of $P$ if there is an injective $\iota : P \to \mathcal{F}$ with
$$p < q \ \Longleftrightarrow\ \iota(p) \subsetneq \iota(q) \qquad (p, q \in P),$$
so that incomparable elements of $P$ map to incomparable sets. $\mathcal{F}$ is *strong $P$-free* if no such $\iota$ exists.

Every strong copy is a weak copy; hence weak $P$-freeness implies strong $P$-freeness, and we shall use this implication silently.

**Definition 2.3 (Extremal numbers).**
$$\mathrm{La}(n, P) = \max\{|\mathcal{F}| : \mathcal{F} \subseteq 2^{[n]},\ \mathcal{F} \text{ weak } P\text{-free}\},$$
$$\mathrm{La}^*(n, P) = \max\{|\mathcal{F}| : \mathcal{F} \subseteq 2^{[n]},\ \mathcal{F} \text{ strong } P\text{-free}\}.$$
Both maxima are over a finite nonempty collection (the empty family is free), so they are attained; and $\mathrm{La}(n,P) \le \mathrm{La}^*(n,P)$.

**Definition 2.4 (Antichain, chain, height).** $\mathcal{L} \subseteq 2^{\alpha}$ is an *antichain* if no member is a proper subset of another. $\mathcal{F}$ *has a chain of $k$ sets* if there are $A_1 \subsetneq A_2 \subsetneq \cdots \subsetneq A_k$ all belonging to $\mathcal{F}$. The *height* of $\mathcal{F}$ is the largest such $k$. The *maximal sets* of $\mathcal{F}$, denoted $\max \mathcal{F}$, are those members not properly contained in another member; $\max\mathcal{F}$ is always an antichain, and it is nonempty when $\mathcal{F}$ is.

**Definition 2.5 (Layers and level families).** For $a, k \ge 0$, the family $\mathrm{Lay}(a,k) = \{A \subseteq [n] : a \le |A| < a + k\}$ is the union of $k$ consecutive layers. More generally, for $S \subseteq \{0, 1, \dots, n\}$ the *level family* is $\mathcal{L}(S) = \{A \subseteq [n] : |A| \in S\}$.

We record the standing facts about the $B_d$ problem that frame our results; they are not needed for the proofs below but they situate them.

**Fact 2.6.** (i) $\mathrm{La}(n, B_1) = \mathrm{La}^*(n, B_1) = \binom{n}{\lfloor n/2\rfloor}$ (Sperner). (ii) $\mathrm{Lay}(a, d)$ is weak $B_d$-free for every $a$, so $\mathrm{La}(n, B_d)$ is at least the sum of the $d$ largest binomial coefficients $\binom{n}{i}$; and this layer family is maximal, in the sense that adding any set whose size lies outside $[a, a+d)$ creates a strong copy of $B_d$. (iii) Among level families and, more generally, among permutation-invariant families, the $d$ central layers are exactly optimal. (iv) $\mathrm{La}(n, B_d) \le (2^d - 1)\binom{n}{\lfloor n/2\rfloor}$, whence $3\binom{n}{\lfloor n/2\rfloor - 2} \le \mathrm{La}(n, B_3) \le 7 \binom{n}{\lfloor n/2 \rfloor}$. (v) $\mathrm{La}(d+1, B_d) = \mathrm{La}^*(d+1,B_d) = 2^{d+1} - 2$.

Item (iii) is the reason the $B_3$ problem is delicate: any construction beating $3\binom{n}{\lfloor n/2\rfloor}$ by a constant factor must break the symmetry of the cube.

---

## 3. The lifting construction

The whole paper turns on the following elementary geometric question inside a cube: *can an antichain block every copy of $B_d$ inside $B_{d+1}$?* It cannot, and the proof is constructive.

Fix $d \ge 0$ and realise $B_{d+1}$ as the power set of $\{1, \dots, d, \star\}$, so that $B_d$ is the power set of $\{1,\dots,d\}$. Write $\kappa : B_d \to B_{d+1}$ for the inclusion $X \mapsto X$ (the "bottom face"); note $\star \notin \kappa(X)$ for every $X$, and $\kappa(X) \subseteq \kappa(Y)$ iff $X \subseteq Y$.

**Definition 3.1 (Up-set).** $U \subseteq B_d$ is an *up-set* if $X \in U$ and $X \subseteq Y$ imply $Y \in U$.

**Definition 3.2 (The lift along an up-set).** For an up-set $U \subseteq B_d$ define $\lambda_U : B_d \to B_{d+1}$ by
$$\lambda_U(X) = \begin{cases} \kappa(X) \cup \{\star\}, & X \in U, \\ \kappa(X), & X \notin U. \end{cases}$$

**Lemma 3.3 (Lifting Lemma).** For every up-set $U \subseteq B_d$ and all $X, Y \in B_d$,
$$\lambda_U(X) \subseteq \lambda_U(Y) \iff X \subseteq Y .$$
Consequently $\lambda_U$ is injective and $\lambda_U(X) \subsetneq \lambda_U(Y) \iff X \subsetneq Y$: it is an order embedding of $B_d$ into $B_{d+1}$.

*Proof.* Four cases according to membership of $X$ and $Y$ in $U$.

- $X, Y \in U$: $\kappa(X) \cup \{\star\} \subseteq \kappa(Y) \cup \{\star\}$ iff $\kappa(X) \subseteq \kappa(Y) \cup \{\star\}$ iff $\kappa(X) \subseteq \kappa(Y)$ (as $\star \notin \kappa(X)$) iff $X \subseteq Y$.
- $X, Y \notin U$: immediate from the corresponding property of $\kappa$.
- $X \notin U$, $Y \in U$: $\kappa(X) \subseteq \kappa(Y) \cup \{\star\}$ iff $\kappa(X) \subseteq \kappa(Y)$ iff $X \subseteq Y$.
- $X \in U$, $Y \notin U$: the left side fails, since $\star \in \lambda_U(X)$ but $\star \notin \kappa(Y) = \lambda_U(Y)$. The right side fails too: if $X \subseteq Y$ then $Y \in U$ because $U$ is an up-set, contradicting $Y \notin U$.

Injectivity and the strict form follow by antisymmetry. $\square$

The four-case check is the only place where the up-set hypothesis is used, and it is used exactly once, in the last case; that single line is the crux of the paper.

**Proposition 3.4 (Avoidance).** Let $\iota : B_{d+1} \to 2^{\alpha}$ be injective with $p \subsetneq q \Rightarrow \iota(p) \subsetneq \iota(q)$, and let $\mathcal{L} \subseteq 2^{\alpha}$ be an antichain. Put
$$U = \{X \in B_d : \exists\, Z \subseteq X \text{ with } \iota(\kappa(Z)) \in \mathcal{L}\}.$$
Then $U$ is an up-set and $\iota(\lambda_U(X)) \notin \mathcal{L}$ for every $X \in B_d$.

*Proof.* $U$ is an up-set: if $X \subseteq Y$ and $Z \subseteq X$ witnesses $X \in U$, the same $Z$ witnesses $Y \in U$.

Let $X \in B_d$. If $X \notin U$, then $\lambda_U(X) = \kappa(X)$, and $\iota(\kappa(X)) \in \mathcal{L}$ would witness $X \in U$ (take $Z = X$); so $\iota(\lambda_U(X)) \notin \mathcal{L}$.

If $X \in U$, pick $Z \subseteq X$ with $\iota(\kappa(Z)) \in \mathcal{L}$. Then $\kappa(Z) \subseteq \kappa(X) \subsetneq \kappa(X) \cup \{\star\} = \lambda_U(X)$, the strictness because $\star \notin \kappa(X)$. Hence $\iota(\kappa(Z)) \subsetneq \iota(\lambda_U(X))$ by strict monotonicity of $\iota$. If $\iota(\lambda_U(X))$ also belonged to $\mathcal{L}$, we would have two distinct members of the antichain $\mathcal{L}$ with one properly contained in the other — a contradiction. $\square$

Specialising to $\iota = \mathrm{id}$ inside $B_{d+1}$ gives the purely order-theoretic statement announced above.

**Corollary 3.5.** For every antichain $A \subseteq B_{d+1}$ there is an order embedding $\varphi : B_d \hookrightarrow B_{d+1}$ with $\varphi(B_d) \cap A = \emptyset$.

---

## 4. The Antichain Augmentation Theorem

**Theorem 4.1 (Antichain Augmentation, weak form).** Let $\mathcal{F} \subseteq 2^{\alpha}$ be weak $B_d$-free and let $\mathcal{L} \subseteq 2^{\alpha}$ be an antichain. Then $\mathcal{F} \cup \mathcal{L}$ is weak $B_{d+1}$-free.

*Proof.* Suppose not, and let $\iota : B_{d+1} \to \mathcal{F} \cup \mathcal{L}$ be injective with $p \subsetneq q \Rightarrow \iota(p) \subsetneq \iota(q)$. Let $U$ be as in Proposition 3.4 and put $\psi = \iota \circ \lambda_U : B_d \to 2^{\alpha}$.

$\psi$ is injective, being a composition of injections (Lemma 3.3). If $X \subsetneq Y$ in $B_d$, then $\lambda_U(X) \subsetneq \lambda_U(Y)$ by Lemma 3.3, hence $\psi(X) \subsetneq \psi(Y)$. Finally, each $\psi(X)$ lies in $\mathcal{F} \cup \mathcal{L}$ but not in $\mathcal{L}$ by Proposition 3.4, hence lies in $\mathcal{F}$. So $\psi$ is a weak copy of $B_d$ inside $\mathcal{F}$, contradicting freeness. $\square$

**Theorem 4.2 (Antichain Augmentation, strong form).** Let $\mathcal{F} \subseteq 2^{\alpha}$ be strong $B_d$-free and let $\mathcal{L} \subseteq 2^{\alpha}$ be an antichain. Then $\mathcal{F} \cup \mathcal{L}$ is strong $B_{d+1}$-free.

*Proof.* Identical in shape. If $\iota$ is a strong copy of $B_{d+1}$ in $\mathcal{F} \cup \mathcal{L}$ then in particular $p \subsetneq q \Rightarrow \iota(p) \subsetneq \iota(q)$, so Proposition 3.4 applies verbatim and $\psi = \iota \circ \lambda_U$ maps into $\mathcal{F}$. That $\psi$ is a *strong* copy follows from the equivalence in Lemma 3.3 combined with the equivalence defining $\iota$:
$$X \subsetneq Y \iff \lambda_U(X) \subsetneq \lambda_U(Y) \iff \iota(\lambda_U(X)) \subsetneq \iota(\lambda_U(Y)).$$
This contradicts strong $B_d$-freeness of $\mathcal{F}$. $\square$

Two remarks. First, no hypothesis whatsoever relates $\mathcal{F}$ and $\mathcal{L}$: they may overlap arbitrarily. Second, the theorem is a genuine "one dimension per antichain" statement, and it is efficient in a precise sense: an antichain may have $\binom{n}{\lfloor n/2\rfloor}$ members, an exponentially large addition, and yet the forbidden dimension rises by exactly one.

Since a family is an antichain precisely when it is weak $B_1$-free, Theorem 4.1 is the case $e = 1$ of the subadditivity conjecture discussed in Section 9.

---

## 5. Strict monotonicity of the extremal numbers

We first record why an extremal family cannot be everything.

**Lemma 5.1.** If $d \le n$ then $2^{[n]}$ contains a strong (hence weak) copy of $B_d$; consequently $\mathrm{La}(n, B_d) < 2^n$ and $\mathrm{La}^*(n, B_d) < 2^n$. If $d > n$ then $\mathrm{La}(n, B_d) = \mathrm{La}^*(n, B_d) = 2^n$.

*Proof.* For $d \le n$ fix a $d$-element $D \subseteq [n]$; the map sending a subset of $D$ to itself is an isomorphism onto $2^D \subseteq 2^{[n]}$, i.e. a strong copy. Hence the full power set is not free, and the extremal numbers are $< 2^n$. For $d > n$, any copy of $B_d$ requires $2^d > 2^n$ distinct sets, which $2^{[n]}$ does not have; so the full power set is free. $\square$

**Theorem 5.2 (Strict monotonicity).** For every $n$ and every $d \le n$,
$$\mathrm{La}(n, B_d) < \mathrm{La}(n, B_{d+1}), \qquad \mathrm{La}^*(n, B_d) < \mathrm{La}^*(n, B_{d+1}).$$

*Proof.* Choose an extremal weak $B_d$-free family $\mathcal{F}$, so $|\mathcal{F}| = \mathrm{La}(n, B_d)$; by Lemma 5.1, $|\mathcal{F}| < 2^n$, so there is $A \subseteq [n]$ with $A \notin \mathcal{F}$. The singleton family $\{A\}$ is an antichain, so by Theorem 4.1 the family $\mathcal{F} \cup \{A\}$ is weak $B_{d+1}$-free, and $|\mathcal{F} \cup \{A\}| = \mathrm{La}(n, B_d) + 1$. Hence $\mathrm{La}(n, B_{d+1}) \ge \mathrm{La}(n, B_d) + 1$. The strong case is identical, using Theorem 4.2 and the strong half of Lemma 5.1. $\square$

**Theorem 5.3 (Exact criterion).** $\mathrm{La}(n, B_d) < \mathrm{La}(n, B_{d+1})$ holds if and only if $d \le n$.

*Proof.* Sufficiency is Theorem 5.2. If $d > n$ then $d+1 > n$ as well, so both sides equal $2^n$ by Lemma 5.1 and the inequality fails. $\square$

**Corollary 5.4 (Iterated form).** If $d + k \le n + 1$ then $\mathrm{La}(n, B_d) + k \le \mathrm{La}(n, B_{d+k})$.

*Proof.* Induction on $k$. The case $k=0$ is trivial. For the step, $d + m \le n$ whenever $d + (m+1) \le n+1$, so Theorem 5.2 gives $\mathrm{La}(n, B_{d+m}) < \mathrm{La}(n, B_{d+m+1})$, and the inductive hypothesis $\mathrm{La}(n, B_d) + m \le \mathrm{La}(n, B_{d+m})$ finishes the argument. $\square$

In particular $\mathrm{La}(n, B_2) < \mathrm{La}(n, B_3)$ for all $n \ge 2$ and $\mathrm{La}(n, B_3) < \mathrm{La}(n, B_4)$ for all $n \ge 3$: the cube posets around the open case are strictly separated at every ground-set size, not merely asymptotically.

---

## 6. A pigeonhole refinement

Theorem 5.2 uses the weakest possible antichain — a single set. Using the largest available one yields a quantitative statement valid without any hypothesis on $n$ and $d$.

**Lemma 6.1 (A large antichain outside a family).** For every $\mathcal{F} \subseteq 2^{[n]}$ there is an antichain $\mathcal{L}$ disjoint from $\mathcal{F}$ with
$$2^n \;\le\; |\mathcal{F}| + (n+1)\,|\mathcal{L}| .$$

*Proof.* Let $\mathcal{C} = 2^{[n]} \setminus \mathcal{F}$, so $|\mathcal{C}| = 2^n - |\mathcal{F}|$. Partition $\mathcal{C}$ into the $n+1$ size classes $\mathcal{C}_i = \{A \in \mathcal{C} : |A| = i\}$, $0 \le i \le n$. Choose $i_0$ maximising $|\mathcal{C}_{i_0}|$ and put $\mathcal{L} = \mathcal{C}_{i_0}$. Distinct sets of equal size are incomparable, so $\mathcal{L}$ is an antichain, and it is disjoint from $\mathcal{F}$ by construction. Finally
$$2^n - |\mathcal{F}| = |\mathcal{C}| = \sum_{i=0}^{n} |\mathcal{C}_i| \le (n+1)|\mathcal{C}_{i_0}| = (n+1)|\mathcal{L}| . \qquad \square$$

**Theorem 6.2 (Quantitative strict monotonicity).** For all $n \ge 0$ and $d \ge 0$,
$$2^n + n\,\mathrm{La}(n, B_d) \;\le\; (n+1)\,\mathrm{La}(n, B_{d+1}).$$

*Proof.* Let $\mathcal{F}$ be extremal weak $B_d$-free, $|\mathcal{F}| = \mathrm{La}(n, B_d)$, and let $\mathcal{L}$ be as in Lemma 6.1. By Theorem 4.1 the family $\mathcal{F} \cup \mathcal{L}$ is weak $B_{d+1}$-free, and by disjointness $|\mathcal{F} \cup \mathcal{L}| = |\mathcal{F}| + |\mathcal{L}|$, so
$$|\mathcal{F}| + |\mathcal{L}| \le \mathrm{La}(n, B_{d+1}).$$
Multiply by $n+1$ and use Lemma 6.1 in the form $(n+1)|\mathcal{L}| \ge 2^n - |\mathcal{F}|$:
$$(n+1)\mathrm{La}(n,B_{d+1}) \ \ge\ (n+1)|\mathcal{F}| + (n+1)|\mathcal{L}| \ \ge\ (n+1)|\mathcal{F}| + 2^n - |\mathcal{F}| \ =\ 2^n + n\,\mathrm{La}(n,B_d). \qquad \square$$

**Corollary 6.3.** $\displaystyle \mathrm{La}(n, B_{d+1}) - \mathrm{La}(n, B_d) \ \ge\ \frac{2^n - \mathrm{La}(n,B_d)}{n+1}$, and unconditionally $(n+1)\mathrm{La}(n, B_{d+1}) \ge 2^n$.

*Proof.* Rearrange Theorem 6.2; the second statement drops the nonnegative term $n\,\mathrm{La}(n,B_d)$. $\square$

**Remark 6.4 (Size of the gain).** Fix $d$ and let $n \to \infty$. By Fact 2.6(iv), $\mathrm{La}(n, B_d) \le (2^d-1)\binom{n}{\lfloor n/2\rfloor} = O_d(2^n / \sqrt{n}) = o(2^n)$, so Corollary 6.3 gives
$$\mathrm{La}(n, B_{d+1}) - \mathrm{La}(n, B_d) \ \ge\ (1-o(1))\frac{2^n}{n+1} \ =\ \Theta\!\left(\frac{1}{\sqrt{n}}\binom{n}{\lfloor n/2\rfloor}\right),$$
using $\binom{n}{\lfloor n/2\rfloor} = \Theta(2^n/\sqrt{n})$. The natural conjecture is that the gain is a full $\binom{n}{\lfloor n/2\rfloor}$ — as it is for the level-restricted problem, where the optima differ by exactly one central binomial coefficient. The pigeonhole bound therefore falls short by a factor $\Theta(\sqrt{n})$, and closing that gap is a concrete open problem. The loss is easy to localise: Lemma 6.1 charges the complement to $n+1$ layers uniformly, whereas the complement of a near-extremal family is concentrated away from the middle.

---

## 7. Height criteria and their sharpness

Theorem 4.1 has a second life as a source of sufficient conditions for freeness, obtained by peeling a family into antichains.

**Lemma 7.1 (Peeling).** For every nonempty family $\mathcal{F}$, the set $\max \mathcal{F}$ of maximal members is a nonempty antichain, and if $\mathcal{F} \setminus \max\mathcal{F}$ has a chain of $k+1$ sets, then $\mathcal{F}$ has a chain of $k+2$ sets.

*Proof.* Maximality is antisymmetric and $\mathcal{F}$ is finite, so every member is contained in a maximal one; hence $\max\mathcal{F} \neq \emptyset$, and no member of $\max\mathcal{F}$ properly contains another, so it is an antichain. For the second claim, take a chain $A_1 \subsetneq \cdots \subsetneq A_{k+1}$ in $\mathcal{F} \setminus \max\mathcal{F}$. Since $A_{k+1}$ is not maximal in $\mathcal{F}$, it is contained in some $B \in \max \mathcal{F}$ with $B \ne A_{k+1}$, giving the chain $A_1 \subsetneq \cdots \subsetneq A_{k+1} \subsetneq B$ of length $k+2$ in $\mathcal{F}$. $\square$

**Theorem 7.2 (Height Criterion).** If $\mathcal{F} \subseteq 2^{\alpha}$ has no chain of $d+1$ sets, then $\mathcal{F}$ is weak $B_d$-free — and hence strong $B_d$-free.

*Proof.* Induction on $d$. For $d = 0$: no chain of one set means $\mathcal{F} = \emptyset$, and the empty family contains no copy of $B_0$ (which has one element, so a copy needs one member). For the step, suppose $\mathcal{F}$ has no chain of $d+2$ sets. By Lemma 7.1, $\mathcal{F} \setminus \max\mathcal{F}$ has no chain of $d+1$ sets, hence is weak $B_d$-free by the inductive hypothesis. Since $\max\mathcal{F}$ is an antichain, Theorem 4.1 gives that
$$(\mathcal{F} \setminus \max\mathcal{F}) \cup \max\mathcal{F} = \mathcal{F}$$
is weak $B_{d+1}$-free. $\square$

Theorem 7.2 subsumes the classical construction: $\mathrm{Lay}(a, d)$ has no chain of $d+1$ sets, because a chain has strictly increasing cardinalities, of which only $d$ values are available. But it applies to arbitrary bounded-height families, complete or not, symmetric or not. A convenient special case:

**Corollary 7.3 (Few sizes).** If the members of $\mathcal{F}$ realise at most $d$ distinct cardinalities, then $\mathcal{F}$ is weak $B_d$-free.

*Proof.* A chain of $d+1$ sets has $d+1$ distinct cardinalities, more than are available; apply Theorem 7.2. $\square$

Note the contrast with the level-family theory: the criterion needs neither that $\mathcal{F}$ contains *all* sets of the allowed sizes, nor permutation invariance.

In the opposite direction, freeness bounds the height.

**Proposition 7.4.** If $\mathcal{F}$ is weak $B_d$-free then $\mathcal{F}$ has no chain of $2^d$ sets.

*Proof.* Let $A_1 \subsetneq \cdots \subsetneq A_{2^d}$ be a chain in $\mathcal{F}$ and let $p_1, \dots, p_{2^d}$ enumerate $B_d$ in an order refining its partial order (e.g. by increasing size). The map $p_i \mapsto A_i$ is injective, and if $p_i < p_j$ then $i < j$, whence $A_i \subsetneq A_j$: a weak copy of $B_d$. $\square$

So weak $B_d$-freeness is sandwiched between two height conditions,
$$\text{height} \le d \implies \text{weak } B_d\text{-free} \implies \text{height} \le 2^d - 1,$$
and both implications are optimal.

**Proposition 7.5 (Sharpness of the lower threshold).** For every $d \le n$ there is a family $\mathcal{F} \subseteq 2^{[n]}$ of height exactly $d+1$ (i.e. with no chain of $d+2$ sets) that contains a strong copy of $B_d$.

*Proof.* Take $\mathcal{F} = 2^{D}$ for a $d$-element $D \subseteq [n]$. Its members have $d+1$ possible sizes $0, \dots, d$, so it has no chain of $d+2$ sets; and it is literally a copy of $B_d$. $\square$

**Proposition 7.6 (Sharpness of the upper threshold).** If $2^d \le n+2$ there is a weak $B_d$-free family in $2^{[n]}$ containing a chain of $2^d - 1$ sets.

*Proof.* Since $2^d - 1 \le n+1$, there is a chain $\emptyset = A_1 \subsetneq A_2 \subsetneq \cdots \subsetneq A_{2^d - 1} \subseteq [n]$ (add one element at a time). The family $\{A_1, \dots, A_{2^d-1}\}$ has fewer than $2^d$ members, and any copy of $B_d$ requires $2^d$ distinct sets; so it is weak $B_d$-free. $\square$

Between the thresholds — height between $d+1$ and $2^d-1$ — membership in the free class is not determined by height alone, and this is precisely the region where the extremal problem for $B_d$ is difficult: near-extremal families for $d = 3$ have height $3$ if built from layers, but a hypothetical improved construction is free to use height up to $7$.

---

## 8. Exhaustive computation for small ground sets

The following table gives $\mathrm{La}(n, B_d)$ obtained by exhaustive search over all $2^{2^n}$ families for $n \le 4$; the strong extremal numbers $\mathrm{La}^*(n, B_d)$ agree with them in every entry of this range.

| $n \backslash d$ | 1 | 2 | 3 | 4 | 5 | $2^n$ |
|---|---|---|---|---|---|---|
| 0 | 1 | 1 | 1 | 1 | 1 | 1 |
| 1 | 1 | 2 | 2 | 2 | 2 | 2 |
| 2 | 2 | 3 | 4 | 4 | 4 | 4 |
| 3 | 3 | 6 | 7 | 8 | 8 | 8 |
| 4 | 6 | 10 | 14 | 15 | 16 | 16 |

Observations, all consistent with the theory:

- **Column $d=1$** reproduces Sperner: $1, 1, 2, 3, 6 = \binom{n}{\lfloor n/2\rfloor}$.
- **Strictness stops exactly at $d = n+1$**, as Theorem 5.3 predicts: on row $n=3$ the values increase strictly through $d=4$ and then freeze at $2^n = 8$.
- **The boundary values** match $\mathrm{La}(d+1, B_d) = 2^{d+1}-2$: $\mathrm{La}(3,B_2) = 6$, $\mathrm{La}(4, B_3) = 14$.
- **Layer families are extremal in this range**: $\mathrm{La}(4, B_2) = 10 = \binom{4}{2} + \binom{4}{1}$, the two central layers.
- **The pigeonhole inequality** of Theorem 6.2 holds with room to spare and tightens as $d$ grows: for $n = 4$ the four instances read $40 \le 50$, $56 \le 70$, $72 \le 75$, $76 \le 80$.
- **Weak and strong agree throughout $n \le 4$**, consistent with the known equalities $\mathrm{La} = \mathrm{La}^*$ at $n = d$ and $n = d+1$; any separation of the two parameters must occur for $n \ge d+2$ and cannot come from level families.

The computation also confirms, on thousands of random instances with $n = 4$, the Antichain Augmentation Theorem for $d = 1, 2$, the avoidance construction of Corollary 3.5 for $d \le 3$, and both height criteria.

---

## 9. Discussion and open problems

### 9.1 What the augmentation theorem buys, and what it does not

The theorem is a purely structural mechanism: it converts *any* antichain into exactly one unit of forbidden dimension, with no counting, no symmetry, and no assumption on the family. That generality is its strength for monotonicity questions and its weakness for the asymptotic constant: it is insensitive to the *sizes* of the objects involved, whereas the $(3+\varepsilon)$ problem for $B_3$ is entirely about sizes. The two ends of the subject meet in Remark 6.4, where the structural mechanism does deliver a quantitative gain, off by $\Theta(\sqrt{n})$ from the conjectured truth.

### 9.2 Conjectures

**F1 (Subadditivity of the free dimension).** If $\mathcal{F}$ is weak $B_d$-free and $\mathcal{G}$ is weak $B_e$-free, then $\mathcal{F} \cup \mathcal{G}$ is weak $B_{d+e}$-free; likewise for strong freeness. Equivalently, in poset form: *for every $A \subseteq B_{d+e}$ containing no weak copy of $B_e$, there is an order embedding $B_d \hookrightarrow B_{d+e}$ whose image avoids $A$.* The case $e = 1$ is Theorem 4.1, since antichains are exactly the weak $B_1$-free families; exhaustive verification on small ground sets has produced no counterexample. Note that the conclusion cannot be improved to $B_{\max(d,e)+1}$ in general, and that the naive proof strategy — lift along an up-set — needs to be replaced by an $e$-step staircase.

**D1 (The $\varepsilon$-gain for $B_3$).** There exist $\varepsilon > 0$ and $n_0$ such that for all $n \ge n_0$ there is a weak $B_3$-free family $\mathcal{F} \subseteq 2^{[n]}$ with $|\mathcal{F}| \ge (3+\varepsilon)\binom{n}{\lfloor n/2\rfloor}$, and likewise a strong $B_3$-free family of that size. Falsified by any proof of $\mathrm{La}(n, B_3) \le 3\binom{n}{\lfloor n/2\rfloor} + o\!\left(\binom{n}{\lfloor n/2\rfloor}\right)$. What the present framework contributes is a list of what such a construction cannot be: it cannot be obtained by adding sets to a layer family (those are maximal), nor be a level family or any permutation-invariant family (for which the $d$ central layers are exactly optimal).

**D2 (Sharpening the general upper bound).** The factor $2^d - 1$ in $\mathrm{La}(n, B_d) \le (2^d-1)\binom{n}{\lfloor n/2\rfloor}$ should be replaceable by $d + c$ for an absolute constant $c$; concretely, $\mathrm{La}(n, B_3) \le 4\binom{n}{\lfloor n/2\rfloor}$ for all $n$. Compatible with D1, which only asks for $3 + \varepsilon$.

**D3 (Quantitative monotonicity).** $\mathrm{La}(n, B_{d+1}) - \mathrm{La}(n, B_d) \ge \binom{n}{\lfloor n/2\rfloor}$ for $n \ge d+1$. The qualitative part is now Theorem 5.2; Corollary 6.3 gives the gain up to a factor $\Theta(\sqrt{n})$; and the analogous statement restricted to level families is a theorem, the level optima differing by exactly one central binomial coefficient. Falsified by a single pair $(n,d)$ violating the inequality.

**D4 (Weak versus strong).** For every $d \ge 2$ there is $n_0$ with $\mathrm{La}(n, B_d) < \mathrm{La}^*(n, B_d)$ for all $n \ge n_0$. Any such $n_0$ exceeds $d+1$, since the two parameters are known to agree at $n = d$ and $n = d+1$, agree for all $n$ when $d = 1$, and agree on level families for all $n$ and $d$; the computations of Section 8 show they also agree for all $n \le 4$. Separating families, if they exist, are therefore not level families.

**D5 (Stability).** There is an absolute constant $c > 0$ such that for all $\varepsilon > 0$ and all large $n$, every weak $B_3$-free family $\mathcal{F} \subseteq 2^{[n]}$ with $|\mathcal{F}| \ge (3+\varepsilon)\binom{n}{\lfloor n/2\rfloor}$ satisfies $\min_S |\mathcal{F} \,\triangle\, \mathcal{L}(S)| \ge c\,\varepsilon \binom{n}{\lfloor n/2\rfloor}$, the minimum over all sets $S$ of levels, and more generally with $\mathcal{L}(S)$ replaced by any permutation-invariant family. In words: an $\varepsilon$-gain must break the symmetry of the cube on a positive proportion of the middle layer, not merely somewhere.

**A question, deliberately not a conjecture.** For which $t$ is the maximum size of a weak $B_d$-free family contained in $d + t$ consecutive layers equal to the sum of the $d$ largest of those binomial coefficients? The case $t = 0$ is trivial and the case "$t = 1$ with one extra set" is the maximality of layer families; but since the known $\varepsilon$-constructions for $B_d$ with $d \ge 4$ appear to live on boundedly many layers, we expect the general bounded-width guess to be false.

### 9.3 Further directions

Three concrete lines suggest themselves.

1. **Improve the pigeonhole.** Lemma 6.1 spends a factor $n+1$ by treating all layers alike. Replacing the largest layer of the complement by a maximum antichain of the complement — computable in polynomial time by a flow argument, via Dilworth's theorem — should recover part of the $\sqrt{n}$ loss, since the complement of a near-extremal family is a large family concentrated off-centre and hence contains antichains far larger than its average layer.
2. **Iterate the augmentation with structure.** The height criterion arises from peeling a family into $h$ antichains, one per unit of height. Any decomposition of a family into $k$ antichains certifies weak $B_k$-freeness; by Mirsky's theorem the least such $k$ is the height, so the criterion of Theorem 7.2 is exactly the antichain-decomposition criterion. The interesting question is whether *weighted* versions — decomposition into $k$ families each weak $B_{e_i}$-free — certify $B_{\sum e_i}$-freeness. That is precisely conjecture F1.
3. **Push the exhaustive frontier.** Determining $\mathrm{La}(5, B_2)$ and $\mathrm{La}(5, B_3)$ exactly would be the first test of D4 in a range not covered by the known equalities, since $n = 5 \ge d + 2$ for $d \le 3$. The search space of $2^{32}$ families demands better than brute force: a branch-and-bound over downward-closed freeness, seeded by the layer families and by Theorem 6.2 as a lower-bound certificate, appears feasible.

---

## 10. Summary of results

- **Lifting Lemma.** For each up-set $U$ of $B_d$, adjoining the new atom exactly on $U$ defines an order embedding $B_d \hookrightarrow B_{d+1}$.
- **Avoidance.** For every antichain $A \subseteq B_{d+1}$ there is an order embedding $B_d \hookrightarrow B_{d+1}$ whose image misses $A$.
- **Antichain Augmentation Theorem.** A weak (strong) $B_d$-free family united with an antichain is weak (strong) $B_{d+1}$-free.
- **Strict monotonicity.** $\mathrm{La}(n, B_d) < \mathrm{La}(n, B_{d+1})$ and $\mathrm{La}^*(n, B_d) < \mathrm{La}^*(n, B_{d+1})$ for all $n \ge d$; strictness holds precisely when $d \le n$; and $\mathrm{La}(n, B_d) + k \le \mathrm{La}(n, B_{d+k})$ for $d+k \le n+1$.
- **Quantitative form.** $2^n + n\,\mathrm{La}(n, B_d) \le (n+1)\,\mathrm{La}(n, B_{d+1})$ for all $n, d$, giving a gain of order $\binom{n}{\lfloor n/2\rfloor}/\sqrt{n}$ for fixed $d$.
- **Height criteria.** No chain of $d+1$ sets $\Rightarrow$ weak $B_d$-free $\Rightarrow$ no chain of $2^d$ sets; at most $d$ distinct sizes $\Rightarrow$ weak $B_d$-free; both height thresholds are attained.
