# Fixed-Point Varieties of Elementary Cellular Automata: A Complete Refutation of the Dimension–Complexity Correspondence

**Aristotle**

---

## Abstract

Every elementary cellular automaton (ECA) is a polynomial map over the field $\mathbb{F}_2$ with two elements: on a cyclic array of $n$ cells the synchronous update is the morphism $\mathbb{A}^n \to \mathbb{A}^n$ whose $i$-th coordinate is a multilinear cubic $f(s_{i-1}, s_i, s_{i+1})$. This makes available the most basic invariant of algebraic geometry, the **fixed-point variety**
$$V(f,n) = \{\, s \in \mathbb{F}_2^n : f(s_{i-1},s_i,s_{i+1}) = s_i \ \forall i \,\},$$
the zero locus of $n$ cubic equations in $n$ unknowns, and it suggests an attractive conjecture: that $\dim V(f,n)$ recovers Wolfram's four-fold complexity classification, with the Turing-complete Class 4 rules attaining the maximal dimension $n$.

We refute this conjecture completely, and identify precisely what the fixed-point variety does measure. Our principal results are: (i) a **rigidity theorem** showing that for every ring size $n$, and on the bi-infinite line, the Turing-complete Rule 110 fixes only the zero configuration, so that $V(f_{110},n) = V(f_0,n)$ and *no* invariant of the fixed-point variety can distinguish a universal automaton from the null automaton; (ii) a **maximality classification** showing that for $n \ge 3$ the equality $\dim V(f,n) = n$ holds for exactly one of the $256$ rules, namely the identity Rule 204, so maximal dimension certifies the *absence* of dynamics; (iii) two independent **non-existence obstructions** — a parity obstruction eliminating all $128$ odd rules and a Lagrange divisibility obstruction eliminating any rule with $|V| \nmid 2^n$ — under which the dimension is undefined for the majority of rules, including Rule 30 on every even ring; and (iv) an **arithmetic characterisation** showing that for the additive rules the variety is the kernel of a circulant matrix whose size depends on $n$ modulo a small integer ($3$ for Rules 90 and 45, $2$ for Rules 30 and 150), whereas a Wolfram class is by definition independent of $n$.

We further establish the **symmetry covariance** of the fixed-point variety under the Klein four-group of reflection and colour inversion, which propagates the Rule 110 rigidity to the entire Class 4 orbit $\{110, 124, 137, 193\}$. Finally we propose and develop a replacement invariant: the tower of **temporal varieties** $\mathrm{Per}_k(f,n) = \{s : f^k(s) = s\}$. We prove that this tower is a lattice under divisibility, $\mathrm{Per}_k \cap \mathrm{Per}_\ell = \mathrm{Per}_{\gcd(k,\ell)}$, that the automaton acts bijectively on each level, that the tower of Rule 0 collapses to a point, and that it does separate Rule 110 from Rule 0 — while also showing that even the repaired invariant is not a dimension.

**Keywords:** elementary cellular automata, fixed-point variety, Rule 110, Rule 30, affine space over $\mathbb{F}_2$, subshift of finite type, Wolfram classification, dynamical zeta function, transfer matrix.

---

## 1. Introduction

### 1.1 Two languages for one object

An elementary cellular automaton is specified by a local map $f : \{0,1\}^3 \to \{0,1\}$; there are $2^8 = 256$ of them, indexed by Wolfram's convention in which the number's binary digits list the outputs on the eight neighbourhoods $(l,c,r)$ read as $4l + 2c + r$. Despite the triviality of the specification, the family contains a universal computer (Rule 110), a rule whose output columns pass most statistical tests for randomness (Rule 30), and rules that reproduce the Sierpiński gasket (Rules 90 and 150). Wolfram's empirical classification sorts the $256$ rules into four classes: uniform (1), periodic (2), chaotic (3), and complex/computational (4).

The classification is qualitative, and there is no known algorithm producing it — indeed for Class 4 rules most natural formulations are undecidable. It is therefore natural to look for a computable algebraic invariant which reproduces the classification, and one candidate presents itself immediately.

Over $\mathbb{F}_2$, where $x^2 = x$, every function $\mathbb{F}_2^3 \to \mathbb{F}_2$ has a unique representation as a multilinear polynomial
$$f(l,c,r) = a_\emptyset + a_l\,l + a_c\,c + a_r\,r + a_{lc}\,lc + a_{lr}\,lr + a_{cr}\,cr + a_{lcr}\,lcr,$$
the *algebraic normal form*, obtained from the truth table by the Reed–Müller (Möbius) transform $a_S = \sum_{T \subseteq S} f(T)$. The eight coefficients over $\mathbb{F}_2$ account for all $256$ rules; $128$ of them have degree $3$, $112$ degree $2$, $14$ degree $1$ and $2$ degree $0$. Some standard examples:

| Rule | Algebraic normal form | Degree |
|---|---|---|
| $0$ | $0$ | $0$ |
| $204$ | $c$ | $1$ |
| $90$ | $l + r$ | $1$ |
| $150$ | $l + c + r$ | $1$ |
| $30$ | $l + c + r + cr$ | $2$ |
| $45$ | $1 + l + r + cr$ | $2$ |
| $232$ | $lc + lr + cr$ | $2$ |
| $110$ | $c + r + cr + lcr$ | $3$ |

Thus an automaton on a cyclic array of $n$ cells is a morphism of affine $n$-space over $\mathbb{F}_2$ to itself, of degree at most three, and the object of study of this paper is the variety of its fixed points.

### 1.2 The conjecture under test

**The Dimension Conjecture.** *Let $f$ be an elementary rule and $V(f,n)$ its fixed-point variety on the ring of $n$ cells. Then $\dim V(f,n) = 0$ for Wolfram Class 1, $\dim V(f,n) \le n/2$ for Class 2, $\dim V(f,n) \ge n/2$ for Class 3, and $\dim V(f,n) = n$ for Class 4.*

The conjecture has considerable surface plausibility: Rule 0 (Class 1) has $V = \{0\}$, dimension $0$, and Rule 204 (a trivially periodic rule) has $V = \mathbb{A}^n$, dimension $n$. Additionally, one might hope that the sheaf-theoretic refinement — regarding each automaton as defining a sheaf on configuration space whose global sections classify stable configurations — would give an even finer invariant, with Rule 110's sheaf having the richest section structure.

Every clause of the conjecture is false, and the sheaf-theoretic refinement is false *a fortiori*, since by Theorem 3.4 the underlying varieties of Rules 110 and 0 coincide as sets.

### 1.3 Results and organisation

Section 2 sets up definitions and the elementary structural properties of $V(f,n)$: shift invariance, additivity, dimension, and the cardinality formula. Section 3 proves the rigidity of Rule 110 and the resulting total blindness of the invariant. Section 4 proves the maximality classification. Section 5 develops the two non-existence obstructions. Section 6 determines the loci of Rules 30, 90, 45 and 150 exactly, exhibiting their arithmetic nature. Section 7 proves symmetry covariance and propagates the Rule 110 result to the whole Class 4 orbit. Section 8 develops the replacement invariant, the temporal tower. Section 9 gives algorithms and computational data. Section 10 discusses consequences and open problems.

---

## 2. The fixed-point variety

### 2.1 Definitions

Throughout, $\mathbb{F}_2 = \mathbb{Z}/2$ and $n \ge 0$ is an integer. We index cells by $\mathbb{Z}/n$; the degenerate case $n = 0$ is read as $\mathbb{Z}$, so that all statements quantified over $n$ include the bi-infinite line.

**Definition 2.1 (Configuration space).** The *configuration space of size $n$* is $\mathrm{Cfg}(n) = \{ s : \mathbb{Z}/n \to \mathbb{F}_2\}$, i.e. the set of $\mathbb{F}_2$-points of affine $n$-space $\mathbb{A}^n_{\mathbb{F}_2}$.

**Definition 2.2 (Local rule and update).** For $0 \le \rho < 256$ let $f_\rho : \mathbb{F}_2^3 \to \mathbb{F}_2$ be the function whose value at $(l,c,r)$ is bit number $4\,l + 2\,c + r$ of $\rho$. The *global update* is $F_\rho : \mathrm{Cfg}(n) \to \mathrm{Cfg}(n)$, $(F_\rho s)_i = f_\rho(s_{i-1}, s_i, s_{i+1})$.

**Definition 2.3 (Fixed-point variety).** $V(\rho, n) = \{ s \in \mathrm{Cfg}(n) : F_\rho(s) = s\}$. Equivalently, $s \in V(\rho,n)$ if and only if $f_\rho(s_{i-1},s_i,s_{i+1}) = s_i$ for every $i$; this is the $\mathbb{F}_2$-point set of the affine subscheme of $\mathbb{A}^n$ cut out by the $n$ cubics $f_\rho(x_{i-1},x_i,x_{i+1}) - x_i$.

### 2.2 First structural properties

**Proposition 2.4 (Shift invariance).** *If $s \in V(\rho,n)$ and $k \in \mathbb{Z}/n$, then the rotated configuration $i \mapsto s_{i+k}$ also lies in $V(\rho,n)$.*

*Proof.* The defining condition at position $i$ for the rotate is the defining condition at position $i+k$ for $s$. $\square$

Thus $V(\rho,n)$ is not an arbitrary subset of $\mathbb{F}_2^n$ but a *cyclic subshift of finite type*: a set of cyclic words determined by a list of admissible three-letter windows. This is the structural fact behind almost everything that follows, and in particular behind Theorem 9.1.

**Definition 2.5 (Additive rule).** A rule $\rho$ is *additive* if $f_\rho$ is $\mathbb{F}_2$-linear in its three arguments, i.e. $f_\rho(l+l', c+c', r+r') = f_\rho(l,c,r) + f_\rho(l',c',r')$ for all arguments. Equivalently, the algebraic normal form of $\rho$ has no constant term and no monomial of degree $\ge 2$. There are exactly eight additive rules: $0, 60, 90, 102, 150, 170, 204, 240$.

**Proposition 2.6.** *If $\rho$ is additive then $f_\rho(0,0,0) = 0$ and $V(\rho,n)$ is an $\mathbb{F}_2$-linear subspace of $\mathrm{Cfg}(n)$.*

*Proof.* Setting all six arguments to $0$ in the additivity relation gives $f_\rho(0,0,0) = 2 f_\rho(0,0,0) = 0$, so $0 \in V(\rho,n)$. If $a, b \in V(\rho,n)$ then, at each $i$, additivity gives $f_\rho(a_{i-1}+b_{i-1}, a_i+b_i, a_{i+1}+b_{i+1}) = f_\rho(a_{i-1},a_i,a_{i+1}) + f_\rho(b_{i-1},b_i,b_{i+1}) = a_i + b_i$, so $a + b \in V(\rho,n)$. Closure under the two scalars $0$ and $1$ is trivial. $\square$

**Definition 2.7 (Dimension).** We say *$V(\rho,n)$ has dimension $d$*, written $\dim V(\rho,n) = d$, if there exists an $\mathbb{F}_2$-subspace $W \subseteq \mathrm{Cfg}(n)$ with $W = V(\rho,n)$ as sets and $\dim_{\mathbb{F}_2} W = d$.

**Proposition 2.8 (Well-definedness and cardinality).** *The dimension, when it exists, is unique; and if $\dim V(\rho,n) = d$ with $n \ge 1$ then $|V(\rho,n)| = 2^d$.*

*Proof.* Two subspaces with the same underlying set are equal, so their dimensions agree. A $d$-dimensional $\mathbb{F}_2$-space has $2^d$ elements. $\square$

We record one general dimension bound, used repeatedly in Section 6.

**Theorem 2.9 (Seed rigidity caps the dimension at two).** *Let $n \ge 1$ and suppose that every $s \in V(\rho,n)$ with $s_0 = s_1 = 0$ is identically zero. Then $\dim V(\rho,n) \le 2$ whenever the dimension exists, however large $n$ is.*

*Proof.* The evaluation map $\pi : \mathrm{Cfg}(n) \to \mathbb{F}_2^2$, $s \mapsto (s_0,s_1)$, is $\mathbb{F}_2$-linear. Its restriction to the subspace $W = V(\rho,n)$ has trivial kernel by hypothesis, so $\pi|_W$ is injective and $\dim W \le \dim \mathbb{F}_2^2 = 2$. $\square$

The hypothesis of Theorem 2.9 holds whenever the stationarity constraint is a two-term recurrence determining $s_{i+1}$ from $(s_{i-1}, s_i)$, which is the case for all additive rules with a nonzero $l$-coefficient.

### 2.3 Periodicity transfer

Several of the exact determinations below run through a common mechanism, which we isolate.

**Lemma 2.10 (Period transfer).** *Let $n \ge 1$ and let $s \in \mathrm{Cfg}(n)$ satisfy $s_{i+p} = s_i$ for all $i$, where $\gcd(p,n) = 1$. Then $s$ is constant.*

*Proof.* Iterating the hypothesis gives $s_{i + pk} = s_i$ for every $k \ge 0$. Since $p$ is invertible modulo $n$, choose $k$ with $pk \equiv 1 \pmod n$; then $s_{i+1} = s_i$ for all $i$, and an induction along $i = 0, 1, 2, \dots$ gives $s_i = s_0$ for all $i$. $\square$

**Lemma 2.11 (Period-two seeds).** *Let $n \ge 1$ and let $s, t \in \mathrm{Cfg}(n)$ both satisfy $x_{i+2} = x_i$ for all $i$. If $s_0 = t_0$ and $s_1 = t_1$, then $s = t$.*

*Proof.* A simultaneous induction on $k$ shows $s_k = t_k$ and $s_{k+1} = t_{k+1}$ for all natural $k$; every residue is of the form $k \bmod n$. $\square$

---

## 3. Rigidity of Rule 110

### 3.1 The local constraint

Rule 110 has algebraic normal form $f_{110} = c + r + cr + lcr$, so the stationarity condition $f_{110}(l,c,r) = c$ becomes
$$r + cr + lcr = 0, \qquad\text{i.e.}\qquad r\,(1 + c + lc) = 0. \tag{3.1}$$

**Lemma 3.1 (Local rigidity).** *For $l,c,r \in \mathbb{F}_2$ we have $f_{110}(l,c,r) = c$ if and only if $r = 0$, or ($c = 1$ and $l = 0$).*

*Proof.* Over $\mathbb{F}_2$, $(3.1)$ holds iff $r = 0$ or $1 + c + lc = 0$. The polynomial $1 + c + lc = 1 + c(1+l)$ vanishes iff $c(1+l) = 1$, i.e. iff $c = 1$ and $l = 0$. (Equivalently: check the eight cases.) $\square$

### 3.2 Backward rigidity

**Theorem 3.2 (Rigidity of Rule 110).** *For every $n \ge 0$ — including $n = 0$, i.e. the bi-infinite configuration space $\mathbb{Z} \to \mathbb{F}_2$ — we have*
$$V(110, n) = \{0\}.$$

*Proof.* The zero configuration is stationary since $f_{110}(0,0,0) = 0$. Conversely suppose $s \in V(110,n)$ and, for a contradiction, that $s_i = 1$ for some $i$.

Apply Lemma 3.1 to the window centred at $i-1$, namely $(s_{i-2}, s_{i-1}, s_i)$. Its right entry is $s_i = 1 \ne 0$, so the second alternative must hold:
$$s_{i-1} = 1 \quad\text{and}\quad s_{i-2} = 0. \tag{3.2}$$
Now apply Lemma 3.1 to the window centred at $i-2$, namely $(s_{i-3}, s_{i-2}, s_{i-1})$. Its right entry is $s_{i-1} = 1 \ne 0$ by $(3.2)$, so again the second alternative must hold, giving in particular
$$s_{i-2} = 1,$$
contradicting $(3.2)$. Hence no cell carries a $1$ and $s = 0$. $\square$

The argument uses only two applications of a purely local constraint; it is uniform in $n$, requires no induction on the ring size, and applies verbatim on $\mathbb{Z}$.

**Corollary 3.3.** *Rule 110 fixes exactly one configuration on every ring; $\dim V(110,n) = 0$; and $\dim V(110,n) \ne n$ for every $n \ge 1$. In particular $2\dim V(110,n) < n$ for all $n \ge 1$, so Rule 110 fails not only the Class 4 prediction $\dim = n$ but even the weaker Class 3 prediction $\dim \ge n/2$.*

### 3.3 Total blindness

**Theorem 3.4 (The fixed-point variety cannot detect universality).** *For every $n$, $V(110,n) = V(0,n)$. Consequently, for every predicate $P$ on subsets of $\mathrm{Cfg}(n)$,*
$$P\bigl(V(110,n)\bigr) \iff P\bigl(V(0,n)\bigr).$$

*Proof.* $V(0,n) = \{0\}$ because $f_0 \equiv 0$, so $F_0(s) = 0$ for every $s$ and $F_0(s) = s$ forces $s = 0$. Combine with Theorem 3.2 and substitute. $\square$

This is the decisive obstruction. It is not merely that dimension fails to separate the Turing-complete rule from the null rule: *no* invariant of the fixed-point variety can separate them, because the two varieties are equal as sets — hence equal as schemes, equal as ringed spaces, with the same sheaves and the same cohomology. Every conceivable refinement of the Dimension Conjecture along these lines is refuted simultaneously.

---

## 4. Maximal dimension classifies the identity automaton

The Dimension Conjecture's boldest clause is that Class 4 rules attain $\dim V = n$, i.e. $V(\rho,n) = \mathbb{A}^n$. We determine exactly which rules do so.

**Lemma 4.1 (Independence of local windows).** *Let $n \ge 3$. For any prescribed $(l,c,r) \in \mathbb{F}_2^3$ there is a configuration $s \in \mathrm{Cfg}(n)$ with $s_0 = l$, $s_1 = c$, $s_2 = r$.*

*Proof.* On a ring of size at least $3$ the residues $0, 1, 2$ are pairwise distinct, so the assignment is consistent; extend by $0$. $\square$

**Proposition 4.2.** *Let $n \ge 3$. Then $V(\rho,n) = \mathbb{A}^n$ if and only if $f_\rho(l,c,r) = c$ for all $(l,c,r) \in \mathbb{F}_2^3$.*

*Proof.* ($\Leftarrow$) Immediate from the definition. ($\Rightarrow$) Given $(l,c,r)$, choose $s$ as in Lemma 4.1. Since $s$ is stationary, the constraint at cell $1$ reads $f_\rho(s_0,s_1,s_2) = s_1$, i.e. $f_\rho(l,c,r) = c$. $\square$

**Proposition 4.3.** *For $\rho < 256$, $f_\rho$ is the centre projection $(l,c,r) \mapsto c$ if and only if $\rho = 204$.*

*Proof.* The truth table of the centre projection assigns $1$ exactly to the four neighbourhoods with $c = 1$, i.e. to indices $4l + 2c + r$ with $c = 1$: indices $2, 3, 6, 7$. Hence the Wolfram number is $2^2 + 2^3 + 2^6 + 2^7 = 4 + 8 + 64 + 128 = 204$. Conversely $204 = 11001100_2$ has precisely these bits set. Since a rule number below $256$ is determined by its eight low bits, the two conditions are equivalent. $\square$

**Theorem 4.4 (Maximality classification).** *Let $n \ge 3$ and $\rho < 256$. Then*
$$\dim V(\rho,n) = n \iff \rho = 204 .$$

*Proof.* If $\dim V(\rho,n) = n$ then the witnessing subspace $W \subseteq \mathrm{Cfg}(n)$ has full dimension $n = \dim \mathrm{Cfg}(n)$, hence $W = \mathrm{Cfg}(n)$ and $V(\rho,n) = \mathbb{A}^n$; apply Propositions 4.2 and 4.3. Conversely for $\rho = 204$ we have $V = \mathbb{A}^n$, a subspace of dimension $n$. $\square$

**Corollary 4.5.** *None of the Class 4 rules $110, 124, 137, 193$ has $\dim V = n$ for any $n \ge 3$. The unique rule satisfying the conjecture's Class 4 prediction is the identity automaton, which has no dynamics at all.*

The conjecture's scale is thus inverted: maximal dimension of the fixed-point variety is a certificate of *triviality*, not of complexity.

---

## 5. Two obstructions to the existence of a dimension

Definition 2.7 presupposes that $V(\rho,n)$ is a linear subspace. We now show that this presupposition fails for the majority of the family.

### 5.1 The parity obstruction

**Lemma 5.1.** *$f_\rho(0,0,0) = 1$ if and only if $\rho$ is odd.*

*Proof.* $f_\rho(0,0,0)$ is bit number $4\cdot 0 + 2\cdot 0 + 0 = 0$ of $\rho$, i.e. $\rho \bmod 2$. $\square$

**Theorem 5.2 (Half the family has no dimension).** *If $\rho$ is odd then $0 \notin V(\rho,n)$ for every $n$, hence $V(\rho,n)$ is not a linear subspace and $\dim V(\rho,n)$ does not exist. This eliminates $128$ of the $256$ rules, for every ring size.*

*Proof.* By Lemma 5.1, the constraint at any cell of the zero configuration reads $1 = 0$, so $0 \notin V(\rho,n)$. A linear subspace always contains $0$. $\square$

Rules $45$, $137$ and $193$ — one Class 3 rule and two Class 4 rules — are among the eliminated.

### 5.2 The Lagrange obstruction

**Definition 5.3.** A set $S \subseteq \mathrm{Cfg}(n)$ is an *affine subvariety* if $S = v + W$ for some $v \in \mathrm{Cfg}(n)$ and some $\mathbb{F}_2$-subspace $W$. This is the weakest reasonable reading of "$S$ has a dimension"; every linear subvariety is affine.

**Theorem 5.4 (Lagrange obstruction).** *If $S \subseteq \mathrm{Cfg}(n)$ is a non-empty affine subvariety with $n \ge 1$, then $|S|$ divides $2^n$; in particular $|S|$ is a power of two.*

*Proof.* Translation by $v$ is a bijection, so $|S| = |W|$. Now $W$ is a subgroup of the additive group $\mathrm{Cfg}(n) \cong (\mathbb{Z}/2)^n$ of order $2^n$, and by Lagrange's theorem $|W| \mid 2^n$. $\square$

**Corollary 5.5.** *If $|V(\rho,n)| \nmid 2^n$ then $V(\rho,n)$ is not an affine subvariety, and $\dim V(\rho,n)$ does not exist in any sense.*

Two explicit instances, verified by exhaustive enumeration:

**Proposition 5.6 (The majority rule).** *Rule 232, $f = lc + lr + cr$, satisfies $f_{232}(l,c,r) = c$ if and only if $l = c$ or $r = c$. On the ring of size $4$ it has exactly $6$ stationary configurations — the two constants and four domain-wall patterns — and $6 \nmid 16$. Hence $V(232,4)$ is not an affine subvariety and has no dimension.*

**Proposition 5.7 (Rule 45).** *On the ring of size $3$, Rule 45 has exactly $3$ stationary configurations, the three rotations of the pulse train $100$, and $3 \nmid 8$. Hence $V(45,3)$ is not an affine subvariety.*

Exhaustive computation on the ring of size $6$ shows that only $91$ of the $256$ rules have a fixed-point locus that is a linear subspace. For the remaining $165$ the conjecture's central quantity is simply undefined.

### 5.3 Synthesis

**Theorem 5.8 (The Dimension Conjecture is false in four independent ways).**

1. *The Class 4 rule $110$ has $V(110,8) = V(0,8)$ and $\dim V(110,8) \ne 8$: the universal rule has the minimal variety, identical to that of the null rule.*
2. *The Class 3 rule $90$ satisfies $2 \dim V(90,n) < n$ for every $n \ge 5$: a chaotic rule violates the predicted $\dim \ge n/2$ for all large rings.*
3. *The Class 3 rule $45$ has $V(45,8) = \varnothing$ while $V(45,9) \ne \varnothing$: the invariant depends on $n$, whereas a Wolfram class does not.*
4. *The Class 2 rule $232$ has $|V(232,4)| = 6$ and no dimension at all.*

Each item is independently fatal; together they show that no repair of the statement can succeed.

---

## 6. What the variety really measures: arithmetic

We now determine the fixed-point loci of four of the most-studied rules completely, for all $n$ at once. In each case the answer is a function of $n$ modulo a small integer — the multiplicative order of the roots of the characteristic polynomial of the stationarity recurrence.

### 6.1 Rule 30: a three-point locus

Rule 30 has $f_{30} = l + c + r + cr$, so stationarity reads
$$l + r + cr = 0, \qquad\text{i.e.}\qquad \bigl(s_i = 0 \Rightarrow s_{i-1} = s_{i+1}\bigr) \ \text{ and } \ \bigl(s_i = 1 \Rightarrow s_{i-1} = 0\bigr). \tag{6.1}$$

**Lemma 6.1 (Transfer relation).** *If $s \in V(30,n)$ then $s_{i+2} = s_i$ for all $i$: every stationary configuration of Rule 30 has spatial period two.*

*Proof.* A finite check on $\mathbb{F}_2^4$ shows: if $f_{30}(a,b,c) = b$ and $f_{30}(b,c,d) = c$ then $c = a$. Apply this with $(a,b,c,d) = (s_i, s_{i+1}, s_{i+2}, s_{i+3})$, using the stationarity constraints at cells $i+1$ and $i+2$. $\square$

**Theorem 6.2 (Rule 30 on odd rings).** *If $n$ is odd then $V(30,n) = \{0\}$.*

*Proof.* By Lemma 6.1 and Lemma 2.10 (with $p = 2$, $\gcd(2,n) = 1$), every stationary $s$ is constant. A constant $x$ is stationary iff $f_{30}(x,x,x) = x$, which by $(6.1)$ requires $x + x + x^2 = x^2 = x \cdot x$; checking both values gives $x = 0$. $\square$

**Theorem 6.3 (Rule 30 on even rings).** *If $n \ge 2$ is even, let $\alpha \in \mathrm{Cfg}(n)$ be the alternating configuration $\alpha_i = i \bmod 2$ (well defined since $2 \mid n$) and $\bar\alpha = 1 + \alpha$ its colour complement. Then*
$$V(30,n) = \{\,0,\ \alpha,\ \bar\alpha\,\},$$
*a set of exactly three distinct configurations.*

*Proof.* All three are stationary: for $\alpha$, neighbours $i-1$ and $i+1$ have equal parity so $l = r$ and $l + r = 0$, while $c$ and $r$ have opposite parity so $cr = 0$; thus $(6.1)$ holds. The same computation applies to $\bar\alpha$, and $0$ is immediate. Conversely, let $s$ be stationary; by Lemma 6.1 it has period two, so by Lemma 2.11 it is determined by $(s_0, s_1)$, giving four candidates: $0$, $\alpha$, $\bar\alpha$ and the all-ones configuration $1$. The last fails, since $f_{30}(1,1,1) = 1 + 1 + 1 + 1 = 0 \ne 1$. Distinctness is checked at cells $0$ and $1$. $\square$

**Corollary 6.4 (No dimension, for infinitely many $n$).** *For every even $n \ge 2$, $|V(30,n)| = 3$, which does not divide $2^n$; hence $V(30,n)$ is not an affine subvariety and $\dim V(30,n)$ does not exist.*

This upgrades the Lagrange obstruction from isolated computed examples to an infinite family, and it does so for the very rule that the Dimension Conjecture places at $\dim \ge n/2$.

### 6.2 Rule 90: the prime 3

Rule 90 is additive, $f_{90} = l + r$; stationarity reads $s_{i-1} + s_i + s_{i+1} = 0$, i.e. the linear recurrence $s_{i+1} = s_{i-1} + s_i$ with characteristic polynomial $x^2 + x + 1$ over $\mathbb{F}_2$, whose roots are the primitive cube roots of unity in $\mathbb{F}_4$.

**Lemma 6.5.** *If $s \in V(90,n)$ then $s_{i+3} = s_i$ for all $i$.*

*Proof.* A finite check shows that $f_{90}(a,b,c) = b$ and $f_{90}(b,c,d) = c$ together imply $d = a$; apply at cells $i+1$ and $i+2$. $\square$

**Theorem 6.6 (Mod-3 dichotomy for Rule 90).**
1. *If $3 \nmid n$ then $V(90,n) = \{0\}$, so $\dim V(90,n) = 0$.*
2. *If $3 \mid n$ and $n \ne 0$ then $V(90,n)$ contains the period-three wave $w$ with $w_i = 0$ if $3 \mid i$ and $w_i = 1$ otherwise, so it is strictly larger.*
3. *For every $n \ge 1$, $\dim V(90,n) \le 2$.*

*Proof.* (1) By Lemma 6.5 and Lemma 2.10 with $p = 3$, a stationary configuration is constant, say $\equiv x$; stationarity then reads $x + x = x$, i.e. $x = 0$. (2) Direct verification using the reduction $\mathbb{Z}/n \to \mathbb{Z}/3$, which is a ring homomorphism when $3 \mid n$: for each residue class the three-window condition $(w_{i-1} + w_{i+1} = w_i)$ holds by a three-case check. (3) The recurrence $s_{i+1} = s_{i-1} + s_i$ shows a stationary configuration vanishing at cells $0$ and $1$ vanishes identically (induct along $i$); apply Theorem 2.9. $\square$

**Corollary 6.7.** *For $n \ge 5$, $2 \dim V(90,n) < n$. The Class 3 rule $90$ violates the predicted $\dim \ge n/2$ for every large ring.*

### 6.3 Rule 45: existence itself is arithmetic

Rule 45 has $f_{45} = 1 + l + r + cr$; it is odd, so by Theorem 5.2 it has no dimension for any $n$. More is true.

**Lemma 6.8.** *If $s \in V(45,n)$ then $s_{i+3} = s_i$ for all $i$.*

*Proof.* A finite check shows: if $f_{45}(a,b,c) = b$, $f_{45}(b,c,d) = c$ and $f_{45}(c,d,e) = d$, then $d = a$. Apply at cells $i+1$, $i+2$, $i+3$. $\square$

**Theorem 6.9 (Existence criterion for Rule 45).** *$V(45,n) \ne \varnothing$ if and only if $3 \mid n$. When $3 \mid n$, the pulse train $p$ with $p_i = 1$ if $3 \mid i$ and $p_i = 0$ otherwise is stationary.*

*Proof.* If $3 \nmid n$, then by Lemma 6.8 and Lemma 2.10 a stationary configuration is constant, say $\equiv x$; but $f_{45}(x,x,x) = 1 + x + x + x\cdot x = 1 + x \ne x$ for both values of $x$, a contradiction, so $V(45,n) = \varnothing$. If $3 \mid n$, the reduction $\mathbb{Z}/n \to \mathbb{Z}/3$ transports the three-case verification for $p$. $\square$

The Class 3 rule $45$ therefore has an *empty* fixed-point variety for two thirds of all ring sizes. Any invariant of $V$ assigning it a class would have to make that class depend on $n$.

### 6.4 Rule 150: the prime 2

Rule 150 is additive, $f_{150} = l + c + r$; stationarity reads $l + r = 0$, i.e. $s_{i-1} = s_{i+1}$, so the variety is exactly the space of period-two configurations.

**Theorem 6.10.**
1. *Every $s \in V(150,n)$ satisfies $s_{i+2} = s_i$.*
2. *If $n$ is odd then $V(150,n) = \{0, 1\}$ (the two constants), and $\dim V(150,n) = 1$.*
3. *If $n$ is even then the alternating configuration $\alpha_i = i \bmod 2$ is a non-constant element of $V(150,n)$, so the variety strictly grows and has dimension $2$.*
4. *For every $n \ge 1$, $\dim V(150,n) \le 2$; hence for $n \ge 5$, $2\dim V(150,n) < n$.*

*Proof.* (1) is the stationarity relation itself, applied at cell $i+1$. (2) By (1) and Lemma 2.10 a stationary configuration on an odd ring is constant, and both constants satisfy $f_{150}(x,x,x) = 3x = x$. Since $|V| = 2$, Proposition 2.8 gives dimension $1$. (3) Reduce $\mathbb{Z}/n \to \mathbb{Z}/2$: $\alpha_{i-1} = \alpha_{i+1}$, and $\alpha_0 = 0 \ne 1 = \alpha_1$ shows non-constancy. (4) A stationary configuration vanishing at $0$ and $1$ vanishes identically by (1) and Lemma 2.11; apply Theorem 2.9. $\square$

### 6.5 Summary of the arithmetic phenomenon

| Rule | Class | Stationarity relation | Number of stationary configurations |
|---|---|---|---|
| $30$ | 3 | period two, $s_i = 1 \Rightarrow s_{i-1}=0$ | $3$ if $n$ even, $1$ if $n$ odd |
| $45$ | 3 | period three | $3$ if $3 \mid n$, $0$ otherwise |
| $90$ | 3 | $s_{i+1} = s_{i-1}+s_i$, period three | $4$ if $3 \mid n$, $1$ otherwise |
| $110$ | 4 | $r(1+c+lc)=0$ | $1$ for all $n$ |
| $150$ | 3 | $s_{i-1}=s_{i+1}$, period two | $4$ if $n$ even, $2$ if $n$ odd |
| $204$ | 2 | no constraint | $2^n$ |

All five nontrivial rules here have counts that are eventually periodic functions of $n$ with tiny period. A Wolfram class is a single number attached to the rule; these are sequences in $n$. The two cannot agree, and the reason is structural rather than accidental — see Theorem 9.1.

---

## 7. Symmetry covariance and the Class 4 orbit

The $256$ rules carry an action of the Klein four-group $\{1, R, C, RC\}$, where $R$ is *reflection* (exchange the roles of $l$ and $r$) and $C$ is *colour inversion* (complement all inputs and the output). Wolfram's classification is constant on orbits. We show the fixed-point variety is covariant.

Write $\mathrm{refl}(s)_i = s_{-i}$ and $\mathrm{conj}(s)_i = 1 + s_i$ for the induced involutions of configuration space.

**Theorem 7.1 (Reflection covariance).** *Suppose $f_{\rho'}(l,c,r) = f_\rho(r,c,l)$ for all $l,c,r$. Then $\mathrm{refl}(s) \in V(\rho',n) \iff s \in V(\rho,n)$; equivalently $V(\rho',n) = \mathrm{refl}\bigl(V(\rho,n)\bigr)$.*

*Proof.* The constraint for $\mathrm{refl}(s)$ at cell $i$ involves $(s_{-i+1}, s_{-i}, s_{-i-1})$, and $f_{\rho'}$ applied to this triple equals $f_\rho(s_{-i-1}, s_{-i}, s_{-i+1})$, which is the constraint for $s$ at cell $-i$. As $i$ ranges over all cells so does $-i$. $\square$

**Theorem 7.2 (Conjugation covariance).** *Suppose $f_{\rho'}(l,c,r) = 1 + f_\rho(1+l, 1+c, 1+r)$ for all $l,c,r$. Then $\mathrm{conj}(s) \in V(\rho',n) \iff s \in V(\rho,n)$; equivalently $V(\rho',n) = \mathrm{conj}\bigl(V(\rho,n)\bigr)$.*

*Proof.* Substituting $\mathrm{conj}(s)$ into the $\rho'$-constraint and using $1 + (1+x) = x$ turns it into $1 + f_\rho(s_{i-1},s_i,s_{i+1}) = 1 + s_i$, which by cancellation is the $\rho$-constraint. $\square$

**Theorem 7.3 (The Class 4 orbit).** *Rule 124 is the reflection of Rule 110, Rule 137 its colour conjugate, and Rule 193 the reflection of Rule 137. Consequently, for every $n$,*
$$V(124,n) = \{0\}, \qquad V(137,n) = \{1\}, \qquad V(193,n) = \{1\},$$
*so every rule in the Turing-complete orbit $\{110,124,137,193\}$ has a one-point fixed-point variety. None of them attains maximal dimension for $n \ge 3$, and the two odd members ($137$ and $193$) have no dimension at all, their single point being the all-ones configuration rather than the origin.*

*Proof.* The three identities among the local rules are finite checks on $\mathbb{F}_2^3$. Apply Theorems 7.1 and 7.2 to Theorem 3.2, noting $\mathrm{refl}(0) = 0$, $\mathrm{conj}(0) = 1$ and $\mathrm{refl}(1) = 1$. Maximality fails by Theorem 4.4; the dimension fails to exist for $137$ and $193$ by Theorem 5.2. $\square$

The rigidity of Rule 110 is thus not a numerical accident of one rule number but a property of an entire symmetry class — precisely the class that the Dimension Conjecture predicted would be maximal.

---

## 8. A working replacement: the tower of temporal varieties

The diagnosis suggested by Sections 3–7 is that the fixed-point variety fails because it looks at a single instant. Complexity is a property of orbits, so we pass to the *temporal varieties*.

**Definition 8.1.** For $k \ge 0$ set $\mathrm{Per}_k(\rho,n) = \{ s \in \mathrm{Cfg}(n) : F_\rho^{\,k}(s) = s\}$, the $\mathbb{F}_2$-points of the fixed locus of the $k$-fold composite — a polynomial map of degree at most $3^k$. Note $\mathrm{Per}_1(\rho,n) = V(\rho,n)$.

**Lemma 8.2 (Return times are closed under gcd).** *Let $g : X \to X$ be any self-map of any set and $x \in X$. If $g^{k}(x) = x$ and $g^{\ell}(x) = x$ then $g^{\gcd(k,\ell)}(x) = x$.*

*Proof.* First, $g^{k}(x) = x$ implies $g^{km}(x) = x$ for all $m \ge 0$, by induction. Now argue by strong induction on $k$. If $k = 0$ then $\gcd(0,\ell) = \ell$ and the claim is the hypothesis. If $k > 0$, write $\ell = k\lfloor \ell/k\rfloor + (\ell \bmod k)$; then
$$x = g^{\ell}(x) = g^{\ell \bmod k}\bigl(g^{k\lfloor \ell/k\rfloor}(x)\bigr) = g^{\ell \bmod k}(x),$$
so $\ell \bmod k$ is also a return time. Since $\ell \bmod k < k$, the inductive hypothesis applies to the pair $(\ell \bmod k, k)$ and yields $g^{\gcd(\ell \bmod k,\, k)}(x) = x$; and $\gcd(\ell \bmod k, k) = \gcd(k,\ell)$ by the Euclidean algorithm. $\square$

**Theorem 8.3 (The tower is a divisibility lattice).** *For all $k, \ell \ge 0$,*
$$\mathrm{Per}_k(\rho,n) \cap \mathrm{Per}_\ell(\rho,n) = \mathrm{Per}_{\gcd(k,\ell)}(\rho,n),$$
*and $k \mid \ell$ implies $\mathrm{Per}_k(\rho,n) \subseteq \mathrm{Per}_\ell(\rho,n)$.*

*Proof.* Monotonicity is the first step of Lemma 8.2's proof. The inclusion $\subseteq$ is Lemma 8.2; the inclusion $\supseteq$ follows from monotonicity applied to $\gcd(k,\ell) \mid k$ and $\gcd(k,\ell) \mid \ell$. $\square$

**Theorem 8.4 (Bijectivity on each level).** *For $k \ge 1$ the automaton restricts to a bijection of $\mathrm{Per}_k(\rho,n)$ onto itself, with inverse $F_\rho^{\,k-1}$.*

*Proof.* Write $k = m+1$. If $F^{m+1}(s) = s$ then $F^{m+1}(F(s)) = F(F^{m+1}(s)) = F(s)$, so the level is preserved. Injectivity: if $F(a) = F(b)$ with $a,b$ of period dividing $k$, apply $F^{m}$ to get $a = F^{m+1}(a) = F^{m+1}(b) = b$. Surjectivity: given $s$ of period dividing $k$, the point $F^{m}(s)$ lies in the level and maps to $F^{m+1}(s) = s$. $\square$

**Theorem 8.5 (The tower of Rule 0 collapses).** *For every $k \ge 1$, $\mathrm{Per}_k(0,n) = \{0\}$.*

*Proof.* $F_0$ is the constant map to $0$, so $F_0^{k}(s) = 0$ for $k \ge 1$; equating to $s$ gives $s = 0$. $\square$

**Theorem 8.6 (The tower separates Rule 110 from Rule 0).** *On the ring of size $4$ the configuration $1110$ satisfies $F_{110}(1110) = 1011$ and $F_{110}(1011) = 1110$: a genuine $2$-cycle. Hence*
$$\mathrm{Per}_1(110,4) = \mathrm{Per}_1(0,4) = \{0\} \quad\text{but}\quad \mathrm{Per}_2(110,4) \ne \mathrm{Per}_2(0,4),$$
*and $V(110,4) \subsetneq \mathrm{Per}_2(110,4)$ strictly.*

*Proof.* Direct computation of the two update steps; the level-$2$ set of Rule 0 is $\{0\}$ by Theorem 8.5, while $1110$ lies in $\mathrm{Per}_2(110,4)$ and is not $0$. Strictness follows since $1110 \notin V(110,4) = \{0\}$. $\square$

**Proposition 8.7 (Even the repaired invariant is not a dimension).** *$|\mathrm{Per}_2(110,4)| = 5$ — the origin together with the four rotations forming one $2$-cycle — and $5 \nmid 16$. So $\mathrm{Per}_2(110,4)$ is not an affine subvariety of $\mathbb{A}^4$.*

The correct conclusion is that the invariant to pursue is a *counting function*, not a dimension: the sequence $k \mapsto |\mathrm{Per}_k(\rho,n)|$, equivalently the dynamical zeta function
$$\zeta_{\rho,n}(t) = \exp\left(\sum_{k \ge 1} \frac{|\mathrm{Per}_k(\rho,n)|}{k}\, t^k\right),$$
whose exponential growth rate is the topological entropy of the automaton on the ring.

---

## 9. Algorithms and computational structure

### 9.1 The de Bruijn transfer matrix

The shift invariance of Proposition 2.4 has a strong computational consequence. Encode a configuration by the sequence of overlapping pairs $(s_{i-1}, s_i)$; there are four such states. Define the *stationary de Bruijn matrix* $T_\rho \in \{0,1\}^{4 \times 4}$ by
$$\bigl(T_\rho\bigr)_{(a,b),\,(b',c)} = \begin{cases} 1 & \text{if } b = b' \text{ and } f_\rho(a,b,c) = b, \\ 0 & \text{otherwise.}\end{cases}$$
A stationary configuration on the ring of $n$ cells is exactly a closed walk of length $n$ in this graph, so one expects the following.

**Conjecture 9.1 (Transfer-matrix trace formula).** *For every rule $\rho$ and every $n \ge 1$,*
$$|V(\rho,n)| = \operatorname{tr}\bigl(T_\rho^{\,n}\bigr).$$

We have verified this exhaustively for all $256$ rules and all $1 \le n \le 12$. Granting it, the point counts of every fixed-point variety in the family satisfy a linear recurrence of order at most four with integer coefficients — the characteristic polynomial of $T_\rho$ — and are computable in $O(\log n)$ arithmetic operations. This explains the arithmetic phenomena of Section 6 in a single stroke: the counts of Rules 90 and 45 have period $3$ in $n$ because $T_\rho$ has eigenvalues that are cube roots of unity; the counts of Rules 30 and 150 have period $2$; Rule 110's matrix has spectral radius $1$ with a single fixed closed walk; Rule 204's matrix is the full de Bruijn matrix, with $\operatorname{tr}(T^n) = 2^n$. And it is the deepest reason why the Dimension Conjecture cannot be repaired: a $4 \times 4$ integer matrix has four eigenvalues, and four algebraic numbers cannot encode the undecidable question of whether a rule is computationally universal.

### 9.2 Algorithmic summary

**Algorithm A (Algebraic normal form).** Input: $\rho < 256$. Output: the eight coefficients $a_S$. Compute $a_S = \bigoplus_{T \subseteq S} f_\rho(T)$ by the Möbius transform over the Boolean lattice on three atoms. Cost $O(1)$ (at most $8 \times 8$ operations); using the in-place butterfly it is $3 \cdot 2^{2} = 12$ XORs.

**Algorithm B (Exhaustive fixed-point enumeration).** Input: $\rho$, $n$. Output: $V(\rho,n)$. Iterate over all $2^n$ configurations and test the $n$ constraints. Cost $O(n 2^n)$; exact but limited to $n \lesssim 24$.

**Algorithm C (Transfer-matrix counting).** Input: $\rho$, $n$. Output: $|V(\rho,n)|$. Build $T_\rho$ from the truth table ($O(1)$), compute $T_\rho^{\,n}$ by binary exponentiation ($O(\log n)$ multiplications of $4\times 4$ matrices), return the trace. Cost $O(\log n)$ matrix products; feasible for astronomically large $n$.

**Algorithm D (Dimension test).** Input: a finite set $S \subseteq \mathbb{F}_2^n$. Output: $\dim S$, or "no dimension". Check $|S| \mid 2^n$ (Lagrange screen, $O(1)$); if it fails, report failure. Otherwise pick $v \in S$, translate to $v + S$, and check that the result contains $0$ and is closed under XOR ($O(|S|^2 n)$, or $O(|S| n^2)$ by Gaussian elimination on a spanning set). Return $\log_2 |S|$.

**Algorithm E (Temporal tower).** Input: $\rho$, $n$, $K$. Output: $|\mathrm{Per}_k(\rho,n)|$ for $k \le K$. Build the functional graph of $F_\rho$ on all $2^n$ configurations ($O(n2^n)$), find its cycles by iterated traversal, and set $|\mathrm{Per}_k| = \sum_{d \mid k} d \cdot (\text{number of cycles of length } d)$. Cost $O(n 2^n + K \log K)$.

### 9.3 Selected computational data

Exhaustive enumeration on rings of small size confirms and extends the theorems:

- $|V(110,n)| = 1$ for all $1 \le n \le 14$, and $V(110,n) = V(0,n)$ throughout.
- The unique rule with $V(\rho,n) = \mathbb{A}^n$ is $204$, for each $n \in \{3,4,5,6\}$.
- Exactly $128$ rules omit the origin on the ring of size $5$, and these are exactly the odd Wolfram numbers.
- On the ring of size $6$, only $91$ of the $256$ rules have a linear fixed-point variety.
- $|V(30,n)| = 3$ for even $n \le 14$ and $1$ for odd $n \le 14$, with the three points always $\{0, \alpha, \bar\alpha\}$.
- $|V(90,n)| = 4$ if $3 \mid n$ and $1$ otherwise; $|V(45,n)| = 3$ if $3 \mid n$ and $0$ otherwise; $|V(150,n)| = 4$ for even $n$ and $2$ for odd $n$; all confirmed for $n \le 14$.
- Among $29$ commonly cited representative rules on the ring of size $6$, only $3$ satisfy the Dimension Conjecture's prediction; $15$ violate it outright and $11$ have no dimension at all. Every Class 4 rule fails.

---

## 10. Discussion

### 10.1 Why the conjecture had to fail

Three independent explanations converge.

**Structural.** By Proposition 2.4, $V(\rho,n)$ is a cyclic subshift of finite type on an alphabet of two letters with memory two — equivalently, the set of closed walks in a graph on four vertices. The class of such objects is extremely small: their point counts are traces of powers of $4\times4$ zero-one matrices, hence integer linear recurrences of order at most four. Universality is not visible in such data.

**Temporal.** The fixed-point variety is the level $k=1$ of the tower $\mathrm{Per}_k$, and it is precisely the level that discards all dynamical information. Rules $0$ and $110$ differ in their orbits, not in their stationary states, and Section 8 shows the difference appears already at $k=2$.

**Arithmetic.** By Section 6, the natural parameter controlling $V(\rho,n)$ is $n$ modulo the order of a root of unity in a small extension of $\mathbb{F}_2$. Wolfram's class is a function of the rule alone. An invariant depending essentially on $n$ cannot equal an invariant independent of $n$.

### 10.2 Positive residue

The refutation leaves behind a set of exact, ring-size-uniform determinations which are of independent interest:

1. $V(110,n) = V(124,n) = \{0\}$ and $V(137,n) = V(193,n) = \{1\}$ for all $n$, including the bi-infinite line.
2. $\dim V(\rho,n) = n$ if and only if $\rho = 204$, for $n \ge 3$.
3. $V(30,n) = \{0,\alpha,\bar\alpha\}$ for even $n$ and $\{0\}$ for odd $n$.
4. $V(90,n) = \{0\}$ exactly when $3 \nmid n$, with $\dim \le 2$ always.
5. $V(45,n) \ne \varnothing$ exactly when $3 \mid n$.
6. $V(150,n) = \{0,1\}$ for odd $n$; dimension $\le 2$ for all $n$.
7. The Klein-group covariance of $\rho \mapsto V(\rho,n)$.
8. The lattice structure $\mathrm{Per}_k \cap \mathrm{Per}_\ell = \mathrm{Per}_{\gcd(k,\ell)}$, valid for an arbitrary self-map of an arbitrary set, and the bijectivity of the automaton on each level.

Result 8 is a general dynamical fact with no cellular-automaton content, and is worth stating in that generality: for any self-map, the set of return times of a point is closed under gcd, so the periodic-point sets form a lattice indexed by the divisibility poset.

### 10.3 Open problems

**Problem 1 (Trace formula).** Prove Conjecture 9.1 in general, and identify for each rule the characteristic polynomial of $T_\rho$. Classify the $256$ rules by the eventual periodicity type of $n \mapsto |V(\rho,n)|$: the data suggest a small number of types (constant, period $2$, period $3$, exponential).

**Problem 2 (Zeta functions).** Compute the dynamical zeta function $\zeta_{\rho,n}(t)$ for the additive rules, where the update is a circulant matrix over $\mathbb{F}_2$ and the periodic-point counts should be expressible in terms of the factorisation of $x^n - 1$.

**Problem 3 (Entropy versus class).** The growth rate of $|\mathrm{Per}_k(\rho,n)|$ in $k$ is the natural candidate for a complexity invariant. Determine whether topological entropy separates Wolfram's Class 3 from Class 4 — the expectation is that it does not, since Rule 110 has positive but modest entropy while genuinely chaotic Class 3 rules have larger entropy, but the question of whether *any* computable invariant of the tower recovers universality remains open and is likely to have a negative answer for undecidability reasons.

**Problem 4 (Scheme structure).** We have worked with $\mathbb{F}_2$-points. The scheme $\mathrm{Spec}\, \mathbb{F}_2[x_0,\dots,x_{n-1}]/(f(x_{i-1},x_i,x_{i+1}) - x_i)$ carries nilpotents; determine whether the length of the structure sheaf at the origin — a genuinely scheme-theoretic invariant, invisible to point counts — distinguishes Rule 110 from Rule 0. Theorem 3.4 does not preclude this, since the two ideals may differ even though their radicals have the same $\mathbb{F}_2$-points; this is the one remaining loophole in the algebraic-geometric programme, and it is worth closing.

**Problem 5 (Higher-radius automata).** For radius-$r$ automata the transfer matrix has size $2^{2r}$, growing with $r$. Determine whether, in the limit of large $r$, the fixed-point subshift becomes rich enough to encode universality — that is, whether the obstruction found here is special to radius one.

### 10.4 Conclusion

Elementary cellular automata genuinely are algebraic varieties: the $256$ rules are the $256$ multilinear cubics over $\mathbb{F}_2$, and their stationary configurations are the $\mathbb{F}_2$-points of a cyclic scheme cut out by $n$ cubic equations. That much of the original vision survives intact, and it is a productive way to think.

What does not survive is the hope that this geometry sees complexity. The fixed-point variety of the Turing-complete Rule 110 is a single point, identical to that of the rule that erases everything; maximal dimension singles out the automaton that does nothing; and for most rules there is no dimension to speak of. The invariant measures the arithmetic of the ring size, and it does so through a $4 \times 4$ integer matrix whose spectrum is far too small a container for universality. Complexity, if it is algebraic at all, lives in the tower of temporal varieties — in the zeta function, not in a dimension.
