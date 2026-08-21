# The Single-Voter Exchange Law: Sharpness, Metric Structure, and Rigidity of Min-Plus Chamber Complexes

**Author:** Aristotle
**Date:** 2026-08-21

---

## Abstract

Let $S$ be a finite nonempty set of voters, let $\delta : S \to \mathbb{R}$ be a system of weights, and let a *profile* be a vector $x \in \mathbb{R}^{S}$ of scores. The min-plus (tropical) aggregator

$$F(x) \;=\; \min_{i \in S}\,\bigl(x_i + \delta_i\bigr)$$

partitions profile space into cells according to the *decisive set* $D(x) = \{ i \in S : x_i + \delta_i = F(x)\}$, the argmin of the aggregation. The resulting chamber complex is the normal fan of a simplex, and is the social-choice avatar of a tropical hyperplane.

We prove a complete theory of *exchange* in this complex. First, a sharp trichotomy: from a profile in the open chamber of an incumbent $i$, resetting the single score of a voter $j \ne i$ to a value $c$ places the profile in the open cell $\{j\}$ iff $c < \theta$, on the wall $\{i,j\}$ iff $c = \theta$, and in the incumbent's chamber iff $c \ge \theta$, where $\theta = x_i + \delta_i - \delta_j$ is the *exchange threshold*. Along the exchange segment the aggregate is $x_i + \delta_i - \max(t,0)$: piecewise affine with a single kink located exactly at the wall. A converse holds: a downward single-voter move from the chamber of $i$ into the chamber of $j$ must be a move of $j$ itself.

Second, a metric theory: the minimum number of voters who must lower their scores in order to move from the open chamber of $i$ to the cell labelled $T$ is *exactly* $|T \setminus \{i\}|$ — an attained optimum. For faces of the incumbent's chamber this common value equals the codimension $n - \dim(\mathrm{lin}\,T)$ of the target cell. The bound genuinely requires downward moves: an explicit two-voter example shows that raising the incumbent's own score transfers the win to a voter who never moved. The dual graph of chambers is the complete graph, so the complex is gallery-connected of diameter one; the $f$-vector is $f_d = \binom{|S|}{d+1}$, the number of cells is $2^{|S|} - 1$, and the alternating sum of the $f$-vector is $1$.

Third, a rigidity dichotomy: the aggregator as a *function* determines $(S,\delta)$ exactly, while the cell labelling determines $S$ exactly and $\delta$ exactly up to a single global additive constant — and no further, the gauge group being precisely $\mathbb{R}\cdot\mathbf{1}$.

Finally we record a Pythagorean instantiation in which the exchange gap of the hypotenuse voter is forced to be strictly positive by the relation $a^2 + b^2 = c^2$, and we interpret this gap as a stability margin against perturbation of the profile.

**Keywords:** min-plus algebra, tropical hyperplane, chamber complex, exchange law, normal fan, $f$-vector, rigidity, social choice.

---

## 1. Introduction

### 1.1 The object of study

Min-plus (equivalently, tropical) linear forms are ubiquitous: they compute shortest paths, bottleneck capacities, makespans, and the linear regions of rectified piecewise-linear functions. Fix a finite index set $\iota$ of *voters*, a nonempty finite *support* $S \subseteq \iota$, and *weights* $\delta : \iota \to \mathbb{R}$. A *profile* is a function $x : \iota \to \mathbb{R}$. The **aggregator** is

$$F(x) \;=\; \min_{i \in S}\, \bigl(x_i + \delta_i\bigr).$$

Reading $x_i$ as the score reported by voter $i$ and $\delta_i$ as a fixed handicap attached to that voter, $F$ is the *weakest-link* or *egalitarian bottleneck* social welfare function. In tropical language, writing $\oplus$ for $\min$ and $\odot$ for $+$, we have $F(x) = \bigoplus_{i \in S} \delta_i \odot x_i$: $F$ is a tropical linear form in which every monomial is essential.

The combinatorial content of $F$ is carried by its argmin.

> **Definition 1.1 (Decisive set).** For a profile $x$, the *decisive set* is
> $$D(x) \;=\; \{\, i \in S : x_i + \delta_i = F(x) \,\}.$$
> $D(x)$ is a nonempty subset of $S$: the voters whose handicapped scores realize the aggregate.

> **Definition 1.2 (Chamber).** For $i \in S$, the *chamber* of $i$ is
> $$C_i \;=\; \{\, x : x_i + \delta_i \le x_k + \delta_k \ \text{ for all } k \in S \,\}.$$
> Thus $i \in D(x)$ if and only if $i \in S$ and $x \in C_i$, and on $C_i$ we have $F(x) = x_i + \delta_i$.

> **Definition 1.3 (Cells and the chamber complex).** For a nonempty $T \subseteq S$, the *open cell* labelled $T$ is $\{x : D(x) = T\}$ and the *closed cell* is $\bigcap_{i \in T} C_i = \{x : T \subseteq D(x)\}$. The collection of all closed cells, indexed by the nonempty subsets $T \subseteq S$, is the *chamber complex* of $(S,\delta)$.

The closed cell labelled $T$ is cut out of $\mathbb{R}^{\iota}$ by the $|T|-1$ independent linear equations $x_i + \delta_i = x_j + \delta_j$ ($i, j \in T$) together with inequalities; writing $L_T$ for its direction (lineality) space, one has

$$\dim L_T \;=\; n - |T| + 1, \qquad n = |\iota|, \tag{1.1}$$

so the codimension of the cell labelled $T$ is $|T| - 1$. Chambers are the top-dimensional cells; walls, of codimension $1$, are the cells labelled by pairs.

### 1.2 The exchange question

The complex is a fan, and fans are traditionally studied through their *galleries*: sequences of chambers, each adjacent to the next. The natural social-choice avatar of a gallery step is an **exchange**: one voter changes their score and the identity of the winner changes. The programme of this paper is to make that avatar exact:

1. **Sharpness.** Determine precisely which single-voter revisions cross a wall, which land on it, and which do not move the winner. (§3)
2. **Metric.** Determine precisely how many voters must move to reach a prescribed cell, and identify that number with a geometric invariant. (§4)
3. **Combinatorics.** Determine the dual graph, the $f$-vector, and the Euler characteristic. (§5)
4. **Rigidity.** Determine how much of $(S,\delta)$ is recoverable from the aggregator, and how much from the cell labelling alone. (§6)

Every statement below is an equivalence or an attained optimum wherever one is available; we flag the one place (Theorem 4.6) where the hypothesis cannot be weakened, with a counterexample.

Throughout, $\mathrm{upd}(x; j, c)$ denotes the profile equal to $x$ except that the $j$-th coordinate is replaced by $c$.

---

## 2. The master formula

Everything in §3 flows from a single computation: a one-coordinate update touches exactly one monomial of the min-plus form.

> **Theorem 2.1 (Master formula).** Let $j \in S$ and suppose $S \setminus \{j\} \ne \emptyset$. Then for every $c \in \mathbb{R}$,
> $$F\bigl(\mathrm{upd}(x; j, c)\bigr) \;=\; \min\Bigl( c + \delta_j,\; \min_{k \in S \setminus \{j\}} (x_k + \delta_k)\Bigr).$$

*Proof sketch.* Both sides are minima over $S$ of the same family of affine functions, split according to whether the index equals $j$. For "$\le$" evaluate the left side at the index $j$ and at each $k \ne j$; for "$\ge$" bound the left side below by the right side term-by-term, using that the update leaves coordinates $k \ne j$ untouched. $\square$

On a chamber the second term collapses, because the incumbent already realizes the minimum over all indices, in particular over $S \setminus \{j\}$.

> **Theorem 2.2 (Master formula on a chamber).** Let $i, j \in S$ with $i \ne j$ and let $x \in C_i$. Then for every $c \in \mathbb{R}$,
> $$F\bigl(\mathrm{upd}(x; j, c)\bigr) \;=\; \min\bigl( c + \delta_j,\; x_i + \delta_i \bigr).$$

*Proof sketch.* "$\le$" is immediate from the definition, testing at the indices $j$ and $i$ (the latter using $\mathrm{upd}(x;j,c)_i = x_i$). "$\ge$": for any $k \in S$, either $k = j$, giving the first term, or $k \ne j$, and then $x_k + \delta_k \ge x_i + \delta_i$ because $x \in C_i$. $\square$

Theorem 2.2 exhibits the aggregate along a single-coordinate exchange as the minimum of two affine functions of $c$ — one of slope $1$ and one constant. This is the entire content of the exchange law, and the rest of §3 is bookkeeping around the crossing point of those two lines.

---

## 3. The sharp single-voter exchange law

> **Definition 3.1 (Exchange threshold).** For a profile $x$ and voters $i, j$, the *exchange threshold* is
> $$\theta_{ij}(x) \;=\; x_i + \delta_i - \delta_j,$$
> the score that voter $j$ must be given in order to tie exactly with $i$ at $x$.

Throughout this section, $i, j \in S$, $i \ne j$, and $x \in C_i$; write $\theta = \theta_{ij}(x)$ and $y_c = \mathrm{upd}(x;j,c)$.

> **Theorem 3.2 (Challenger's half).** $j \in D(y_c) \iff c \le \theta$.

*Proof sketch.* By Theorem 2.2, $j \in D(y_c)$ means $c + \delta_j = \min(c+\delta_j,\, x_i + \delta_i)$, i.e. $c + \delta_j \le x_i + \delta_i$, i.e. $c \le \theta$. $\square$

> **Theorem 3.3 (Incumbent's half).** $i \in D(y_c) \iff \theta \le c$.

*Proof sketch.* Symmetrically, $i \in D(y_c)$ means $x_i + \delta_i = \min(c + \delta_j,\, x_i + \delta_i)$, i.e. $x_i + \delta_i \le c + \delta_j$, i.e. $\theta \le c$. $\square$

Combining the two halves gives the trichotomy in its sharpest form. Note that both statements are equivalences, so no case is lost.

> **Theorem 3.4 (Sharp exchange law).** $D(y_c) = \{j\} \iff c < \theta$.

*Proof sketch.* ($\Rightarrow$) If $c \ge \theta$ then $i \in D(y_c)$ by Theorem 3.3, contradicting $D(y_c) = \{j\}$ since $i \ne j$. ($\Leftarrow$) If $c < \theta$ then for every $k \in S$ with $k \ne j$ we have $c + \delta_j < x_i + \delta_i \le x_k + \delta_k$, so $j$ is the strict minimizer. $\square$

> **Theorem 3.5 (Sharp wall law).** $\{i,j\} \subseteq D(y_c) \iff c = \theta$.

*Proof sketch.* Immediate from Theorems 3.2 and 3.3: $\{i,j\} \subseteq D(y_c)$ iff both $c \le \theta$ and $\theta \le c$. $\square$

**Trichotomy.** For $x \in C_i$ and $j \ne i$:

| revision $c$ | decisive set |
|---|---|
| $c > \theta$ | contains $i$, not $j$ — incumbent's chamber |
| $c = \theta$ | contains both $i$ and $j$ — the wall $\{i,j\}$ |
| $c < \theta$ | equals $\{j\}$ — challenger's open chamber |

### 3.1 The kink of the aggregate

> **Definition 3.6 (Exchange path).** For $t \in \mathbb{R}$ let $\gamma(t) = \mathrm{upd}(x; j, \theta - t)$: the challenger's score is pushed $t$ units below the threshold.

> **Theorem 3.7 (Piecewise-affine aggregate).** For $x \in C_i$, $i \ne j$ in $S$, and all $t \in \mathbb{R}$,
> $$F(\gamma(t)) \;=\; x_i + \delta_i - \max(t, 0).$$

*Proof sketch.* By Theorem 2.2, $F(\gamma(t)) = \min(\theta - t + \delta_j,\ x_i + \delta_i) = \min(x_i + \delta_i - t,\ x_i + \delta_i)$, and $\min(u - t, u) = u - \max(t,0)$. $\square$

> **Corollary 3.8 (The kink is genuine).** For every $t > 0$,
> $$F(\gamma(-t)) = F(\gamma(0)) \qquad\text{and}\qquad F(\gamma(0)) - F(\gamma(t)) = t.$$
> Hence the left slope of $F \circ \gamma$ at $0$ is $0$ and the right slope is $-1$: the aggregate is not differentiable at the wall, and the one-sided slopes differ by exactly $1$.

The wall between two chambers is therefore precisely the non-differentiability locus of the aggregate along the exchange direction — the min-plus analogue of the activation boundary of a rectified linear unit. The parameter $t$ has a clean interpretation: on the incumbent's side it is *pure slack* (the challenger's concessions are socially invisible), and on the challenger's side it is transmitted one-for-one to the social score.

### 3.2 Comparative statics and the converse

> **Lemma 3.9 (Monotonicity).** If $x_k \le y_k$ for all $k$ then $F(x) \le F(y)$.

> **Theorem 3.10 (No spurious pivots).** If $c \le x_k$ (a downward revision by voter $k$), then
> $$D\bigl(\mathrm{upd}(x;k,c)\bigr) \;\subseteq\; \{k\} \cup D(x).$$

*Proof sketch.* Let $m$ be decisive after the move and $m \ne k$. The move is downward, so $F$ decreases weakly (Lemma 3.9), while $m$'s own score is untouched. Therefore $x_m + \delta_m = F(\mathrm{upd}(x;k,c)) \le F(x) \le x_m + \delta_m$, forcing equality; so $m \in D(x)$. $\square$

> **Theorem 3.11 (Raising cannot unseat a bystander).** If $x_k \le c$, then $D(x) \setminus \{k\} \subseteq D(\mathrm{upd}(x;k,c))$.

*Proof sketch.* Dual to Theorem 3.10: raising $x_k$ weakly increases $F$, while the monomial of any $m \ne k$ is unchanged, so a previously minimal monomial remains minimal. $\square$

Theorem 3.10 yields the converse of the exchange law, which is the statement that gallery adjacency is *only* realized by exchanges of the incoming winner.

> **Theorem 3.12 (Converse of the exchange law).** Suppose $D(x) = \{i\}$, let $c \le x_k$, and suppose $D(\mathrm{upd}(x;k,c)) = \{j\}$ with $j \ne i$. Then $k = j$.

*Proof sketch.* By Theorem 3.10, $j \in \{k\} \cup D(x) = \{k, i\}$; since $j \ne i$, $j = k$. $\square$

> **Theorem 3.13 (Exchange law, both directions).** Let $i, j \in S$, $i \ne j$, $D(x) = \{i\}$ and $c \le x_k$. Then
> $$D\bigl(\mathrm{upd}(x;k,c)\bigr) = \{j\} \iff \bigl( k = j \ \text{ and }\ c < \theta_{ij}(x) \bigr).$$

*Proof sketch.* ($\Rightarrow$) Theorem 3.12 gives $k = j$, then Theorem 3.4 gives $c < \theta$. ($\Leftarrow$) Theorem 3.4. $\square$

### 3.3 Coalition exchanges

The single-voter law has an exact multi-voter analogue, which will supply the upper bound of the metric theory.

> **Definition 3.14 (Coalition exchange).** For $x \in C_i$, a coalition $T \subseteq S$ and a parameter $\varepsilon \in \mathbb{R}$, let
> $$E_T^{\varepsilon}(x)_k \;=\; \begin{cases} x_i + \delta_i - \delta_k - \varepsilon, & k \in T,\\ x_k, & k \notin T.\end{cases}$$
> Every member of $T$ is given exactly the score that puts its monomial $\varepsilon$ below the incumbent's.

> **Theorem 3.15 (Coalition exchange law).** Let $x \in C_i$, let $\emptyset \ne T \subseteq S$ and let $\varepsilon > 0$. Then $D(E_T^{\varepsilon}(x)) = T$.

*Proof sketch.* Each $k \in T$ has monomial exactly $x_i + \delta_i - \varepsilon$; each $k \in S \setminus T$ has monomial $x_k + \delta_k \ge x_i + \delta_i > x_i + \delta_i - \varepsilon$ because $x \in C_i$. So the aggregate is $x_i + \delta_i - \varepsilon$ and the argmin is exactly $T$. $\square$

> **Theorem 3.16 (Wall case).** With $i \in S$ and $x \in C_i$ and $T \subseteq S$, $D(E_T^{0}(x)) = T \cup D(x)$.

*Proof sketch.* At $\varepsilon = 0$ every member of $T$ ties exactly with the incumbent's value $x_i+\delta_i = F(x)$, while all other monomials are unchanged; the argmin is therefore the union of $T$ with the old argmin. $\square$

> **Corollary 3.17 (Reachability).** From any $x \in C_i$ and any nonempty $T \subseteq S$ there exists a profile $y$ with $D(y) = T$ and $y_k = x_k$ for every $k \notin T$. Every cell is reachable from every chamber by revising only the scores of the voters that label the target cell.

### 3.4 Lipschitz control

> **Theorem 3.18.** If $|x_k - y_k| \le M$ for all $k$, then $|F(x) - F(y)| \le M$; that is, $F$ is $1$-Lipschitz for the sup-norm. In particular, for a single revision,
> $$\bigl| F(\mathrm{upd}(x;j,c)) - F(x) \bigr| \;\le\; |c - x_j| .$$

*Proof sketch.* If $u_k - v_k \le M$ for all $k$, then evaluating $F(u)$ at any index gives $F(u) \le F(v) + M$; apply this in both directions. The second statement is the first with the sup-distance of the two profiles equal to $|c - x_j|$. $\square$

Thus no single voter can swing the aggregate by more than the size of their own revision — a *non-manipulability* bound complementing the exchange law, which says exactly *how large* a revision is needed to swing the *identity* of the winner.

---

## 4. The exchange metric

We now measure distances in the complex by counting movers. Fix a profile $x$ with $D(x) = \{i\}$ (the open chamber of $i$), and consider *downward moves*: profiles $y$ with $y_k \le x_k$ for all $k$. The *exchange support* of the move is any set $D$ with $y_k = x_k$ for all $k \notin D$.

The first result is a locality principle: downward moves cannot create decisive voters out of nowhere.

> **Theorem 4.1 (Locality of downward moves).** Let $y_k \le x_k$ for all $k$ and $y_k = x_k$ for all $k \notin D$. Then
> $$D(y) \;\subseteq\; D \cup D(x).$$

*Proof sketch.* Let $m \in D(y)$ with $m \notin D$; we show $m \in D(x)$. Since $y \le x$ pointwise, $F(y) \le F(x)$ (Lemma 3.9). Since $m \notin D$, $y_m = x_m$, so $x_m + \delta_m = y_m + \delta_m = F(y) \le F(x) \le x_m + \delta_m$, whence equality throughout and $m \in D(x)$. $\square$

This is the coalition version of Theorem 3.10; note that it is proved by exactly the same two-line squeeze, which is why the single-voter and coalition theories have identical shape.

> **Theorem 4.2 (Lower bound).** Let $D(x) = \{i\}$, let $y$ be a downward move with support $D$, and suppose $D(y) = T$. Then $T \setminus \{i\} \subseteq D$.

*Proof sketch.* Let $m \in T$ with $m \ne i$. By Theorem 4.1, $m \in D \cup D(x) = D \cup \{i\}$; since $m \ne i$, $m \in D$. $\square$

> **Theorem 4.3 (Upper bound).** Let $D(x) = \{i\}$ and let $T \subseteq S$ be nonempty. Then there exists a downward move $y \le x$ with $y_k = x_k$ for all $k \notin T \setminus \{i\}$ and $D(y) = T$.

*Proof sketch.* Two cases.
*If $i \in T$*: take $y = E^{0}_{T \setminus \{i\}}(x)$, the coalition exchange at threshold applied to $T \setminus \{i\}$. Each member of $T \setminus\{i\}$ receives $x_i + \delta_i - \delta_k \le x_k$ (the inequality because $x \in C_i$), so the move is downward, and by Theorem 3.16 the new decisive set is $(T\setminus\{i\}) \cup D(x) = (T \setminus \{i\}) \cup \{i\} = T$. No voter outside $T \setminus \{i\}$ moves.
*If $i \notin T$*: take $y = E^{1}_{T}(x)$. Again each member of $T$ receives $x_i + \delta_i - \delta_k - 1 < x_k$, so the move is downward, and Theorem 3.15 gives $D(y) = T$. Since $i \notin T$, $T \setminus \{i\} = T$, so again only the required voters move. $\square$

Combining the two bounds gives the central result of the metric theory. Its content is that the natural cost function has an *attained* optimum equal to a combinatorial quantity, not merely bounds on both sides.

> **Theorem 4.4 (Exchange distance).** Let $D(x) = \{i\}$ and let $T \subseteq S$ be nonempty. Then $|T \setminus \{i\}|$ is the least element of the set
> $$\Bigl\{\, m \in \mathbb{N} : \exists\, D,\ \exists\, y,\ |D| = m,\ y \le x \text{ pointwise},\ y|_{D^c} = x|_{D^c},\ D(y) = T \,\Bigr\}.$$
> That is, the *exchange distance* from the open chamber of $i$ to the cell labelled $T$ is exactly $|T \setminus \{i\}|$.

*Proof sketch.* Membership is Theorem 4.3 with $D = T \setminus \{i\}$; the lower-bound property is Theorem 4.2 together with monotonicity of cardinality under inclusion. $\square$

> **Theorem 4.5 (Exchange distance equals codimension).** Suppose in addition that $i \in T$, so that the cell labelled $T$ is a face of the chamber of $i$. Then the exchange distance to that cell equals
> $$n - \dim L_T \;=\; |T| - 1,$$
> the codimension of the cell in profile space, where $n$ is the number of voters and $L_T$ is the direction space of the cell.

*Proof sketch.* $|T \setminus \{i\}| = |T| - 1$ since $i \in T$, and $\dim L_T = n - |T| + 1$ by (1.1), so $n - \dim L_T = |T| - 1$. $\square$

Theorem 4.5 is the reason the exchange law deserves the name "law": it converts a *combinatorial* budget (how many voters must be persuaded) into a *geometric* invariant (the codimension of the target stratum), exactly and in both directions. Moving to a wall costs one voter; moving to a codimension-$d$ cell costs $d$ voters; moving to the totally-tied cell costs $|S| - 1$ voters.

### 4.1 Downwardness is essential

The lower bound of Theorem 4.2 uses that the move is downward, and the hypothesis cannot be dropped.

> **Theorem 4.6 (Counterexample for upward moves).** There exist two voters, weights $\delta$, profiles $x, y$ and a set $D$ such that
> $$D(x) = \{0\},\quad D(y) = \{1\},\quad y_k = x_k \text{ for all } k \notin D,\quad x_k \le y_k \text{ for all } k,$$
> yet $\{1\} \setminus \{0\} \not\subseteq D$.

*Proof sketch.* Take $\iota = S = \{0,1\}$, $\delta = (0,1)$, $x = (0,0)$, $y = (2,0)$ and $D = \{0\}$. Then $F(x) = \min(0,1) = 0$ is attained only at voter $0$, so $D(x) = \{0\}$; $F(y) = \min(2,1) = 1$ is attained only at voter $1$, so $D(y) = \{1\}$. The move is upward and supported on $\{0\}$, yet the winner is voter $1$, who never moved: $\{1\} \not\subseteq \{0\}$. $\square$

The asymmetry is structural. Under a downward move the aggregate can only fall, and a voter who did not move keeps the same monomial, so they can only become decisive if they already were. Under an upward move the aggregate can rise to *meet* a stationary monomial, promoting an inactive bystander. In min-plus terms: lowering scores is a contraction that preserves the argmin structure locally; raising them is not.

---

## 5. The dual graph, the $f$-vector, and the Euler characteristic

### 5.1 The dual graph is complete

> **Definition 5.1 (Exchange graph).** The *exchange graph* has vertex set $S$, with $i$ and $j$ adjacent iff $i \ne j$ and there exists a profile $x$ with $D(x) = \{i,j\}$ — that is, iff the chambers of $i$ and $j$ share a wall.

> **Theorem 5.2 (Completeness).** The exchange graph is the complete graph on $S$.

*Proof sketch.* Given $i \ne j$ in $S$, choose a profile whose monomials at $i$ and $j$ are equal and strictly below all others: for instance $x_i = 0$, $x_j = \delta_i - \delta_j$, and $x_k$ very large for $k \notin \{i,j\}$. Then $D(x) = \{i,j\}$. $\square$

> **Corollary 5.3.** The exchange graph is connected, and indeed a single clique on all of $S$: the chamber complex is gallery-connected of *diameter one*. Any incumbent may be replaced by any challenger through a single wall crossing, with no intermediate winner.

Corollary 5.3, together with the exchange law, gives the promised description of adjacency: chambers $i$ and $j$ are adjacent (always), and the transition is effected by a single revision of voter $j$'s score through the threshold $\theta_{ij}$.

### 5.2 Counting cells

> **Definition 5.4.** The *labels* of the complex are the nonempty subsets $T \subseteq S$; the cell labelled $T$ has codimension $|T| - 1$.

> **Theorem 5.5 ($f$-vector).** The number of cells of codimension $d$ is
> $$f_d \;=\; \binom{|S|}{d+1}.$$

*Proof sketch.* Cells of codimension $d$ are labelled by the subsets of $S$ of cardinality $d+1$, and the number of such subsets is $\binom{|S|}{d+1}$. $\square$

> **Theorem 5.6 (Total count).** The complex has exactly $2^{|S|} - 1$ cells, one for each nonempty subset of $S$, and distinct labels give distinct cells.

*Proof sketch.* The powerset of $S$ has $2^{|S|}$ elements, of which exactly one — the empty set — is not a label. Injectivity of the labelling: distinct nonempty $T \ne T'$ give distinct closed cells, since a profile realizing $D = T$ lies in the closed cell of $T$ but not that of $T'$ whenever $T' \not\subseteq T$. $\square$

> **Theorem 5.7 (Euler contractibility).** The alternating sum of the $f$-vector is $1$:
> $$\sum_{\emptyset \ne T \subseteq S} (-1)^{|T| + 1} \;=\; \sum_{d \ge 0} (-1)^{d} \binom{|S|}{d+1} \;=\; 1 .$$

*Proof sketch.* Over the full powerset, $\sum_{T \subseteq S} (-1)^{|T|} = 0$ for nonempty $S$ (the binomial theorem applied to $(1-1)^{|S|}$). Splitting off $T = \emptyset$, which contributes $1$, gives $\sum_{\emptyset \ne T} (-1)^{|T|} = -1$, and multiplying by $-1$ yields the claim. $\square$

The value $1$ is the Euler characteristic of a point, as it must be for a complete fan: the complex is a cone with apex the lineality line $\mathbb{R}\cdot\mathbf{1}$, hence contractible. The three results of this section are three shadows of a single geometric fact: **the chamber complex of a min-plus linear form is the normal fan of a simplex on $|S|$ vertices**, whose faces are exactly the nonempty subsets of the vertex set. The complete dual graph is the $1$-skeleton of that simplex; the binomial $f$-vector counts its faces; the alternating sum is the reduced Euler characteristic of its boundary sphere, shifted by one.

---

## 6. Rigidity: what the geometry remembers

We now invert the construction. Two kinds of data have been attached to a pair $(S, \delta)$: the *function* $F$ and the *labelling* $x \mapsto D(x)$. How much of $(S,\delta)$ does each determine?

### 6.1 Spike profiles

The technical tool is a profile that drives a single voter's monomial far below all others.

> **Lemma 6.1 (Spike evaluation).** Let $i \in S$ and let $c$ be small enough that $c + \delta_i \le \delta_k$ for all $k \in S$. Let $x$ be the profile that is $0$ everywhere except $x_i = c$. Then $F(x) = c + \delta_i$.

> **Lemma 6.2 (Invisible voters).** If $i \notin S$, then the same spike profile satisfies $F(x) = F(0) = \min_{k \in S} \delta_k$: a voter outside the support has no influence whatsoever, however extreme their score.

*Proof sketch.* Direct evaluation of the minimum in each case: in Lemma 6.1 the spiked monomial is minimal by hypothesis, and in Lemma 6.2 the spiked coordinate does not occur in the minimum at all. $\square$

### 6.2 Functional rigidity

> **Theorem 6.3 (The support is determined).** If $F_{S,\delta} = F_{S',\delta'}$ as functions on profiles, then $S = S'$.

*Proof sketch.* Suppose $i \in S \setminus S'$. Drive $x_i$ to $-\infty$ along spikes. By Lemma 6.1 the left-hand aggregate tends to $-\infty$; by Lemma 6.2 the right-hand aggregate is constant. Contradiction; hence $S \subseteq S'$, and symmetrically $S' \subseteq S$. $\square$

> **Theorem 6.4 (The weights are determined).** If $F_{S,\delta} = F_{S',\delta'}$ and $i \in S$, then $\delta_i = \delta'_i$.

*Proof sketch.* By Theorem 6.3, $S = S'$. Take a spike at $i$ with $c$ so small that $i$ is decisive for both weight systems (possible since both minima over the finite set $S$ are finite). Then Lemma 6.1 gives $c + \delta_i = F(x) = c + \delta'_i$, so $\delta_i = \delta'_i$. $\square$

> **Theorem 6.5 (Functional rigidity).** Two min-plus aggregators define the same function on profiles if and only if they have the same support and the same weights on it. Equivalently: no monomial of a min-plus linear form is redundant, because every voter of the support is decisive somewhere.

This is the min-plus analogue of the statement that a tropical polynomial with only essential monomials is determined by the piecewise-linear function it defines — here in the strongest, purely finite-dimensional form, with no genericity hypothesis.

### 6.3 Combinatorial rigidity and the gauge group

The labelling remembers strictly less, and exactly one thing less.

> **Theorem 6.6 (Gauge invariance).** For every constant $c$ and every profile $x$, the weight system $\delta + c\mathbf{1}$ has the same decisive set as $\delta$:
> $$D_{S,\delta + c\mathbf{1}}(x) \;=\; D_{S,\delta}(x).$$

*Proof sketch.* Shifting all weights shifts the aggregate: $F_{\delta + c\mathbf 1}(x) = F_{\delta}(x) + c$. Since every monomial is shifted by the same $c$, the argmin is unchanged. $\square$

> **Theorem 6.7 (The labelling determines the support).** If $D_{S,\delta}(x) = D_{S',\delta'}(x)$ for every profile $x$, then $S = S'$.

*Proof sketch.* Every $i \in S$ labels a chamber all by itself: there is a profile $x$ with $D_{S,\delta}(x) = \{i\}$ (drive $x_i$ low). Then $\{i\} = D_{S',\delta'}(x)$, and decisive voters belong to the support, so $i \in S'$. Symmetrize. $\square$

> **Theorem 6.8 (The labelling determines the weights up to a constant).** If $D_{S,\delta}(x) = D_{S,\delta'}(x)$ for every $x$, then $\delta_i - \delta'_i = \delta_j - \delta'_j$ for all $i, j \in S$: the difference $\delta - \delta'$ is constant on $S$.

*Proof sketch.* Pick $i, j \in S$ and choose a profile $x$ with $D_{S,\delta}(x) = \{i,j\}$ (Theorem 5.2). By hypothesis $D_{S,\delta'}(x) = \{i,j\}$ too. Being tied means $x_i + \delta_i = x_j + \delta_j$ and $x_i + \delta'_i = x_j + \delta'_j$; subtracting gives $\delta_i - \delta'_i = \delta_j - \delta'_j$. $\square$

> **Theorem 6.9 (Combinatorial rigidity, both directions).** Two weight systems on the same support induce the same chamber complex if and only if they differ by a single global constant on the support:
> $$\bigl(\forall x,\ D_{S,\delta}(x) = D_{S,\delta'}(x)\bigr) \iff \exists\, c \in \mathbb{R}\ \ \forall k \in S,\ \delta_k = \delta'_k + c.$$

*Proof sketch.* ($\Rightarrow$) Theorem 6.8 with $c = \delta_{i_0} - \delta'_{i_0}$ for any fixed $i_0 \in S$. ($\Leftarrow$) Theorem 6.6, after noting that decisive sets depend only on the restriction of the weights to $S$. $\square$

**Summary of the dichotomy.** The map $(S, \delta) \mapsto F$ is injective. The map $(S,\delta) \mapsto (\text{chamber complex})$ has fibres exactly the lines $\delta + \mathbb{R}\cdot\mathbf{1}$. The chamber complex is thus a complete invariant of the electorate modulo the one gauge freedom that no observer of *who wins* could ever detect, and the numerical aggregator rigidifies that gauge. This is the exact analogue, for min-plus forms, of the familiar fact that a projective object determines its affine data only up to scaling.

---

## 7. A Pythagorean instantiation and stability margins

We record a family of examples in which the exchange threshold is forced to be nonzero by an arithmetic identity, and interpret the resulting gap as robustness.

> **Lemma 7.1.** If $a, b, c > 0$ and $a^2 + b^2 = c^2$, then $a < c$ and $b < c$.

*Proof sketch.* $c^2 - a^2 = b^2 > 0$ and $a, c > 0$, so $c > a$; symmetrically for $b$. $\square$

> **Lemma 7.2.** If $\delta_i \le \delta_j$ for all $j \in S$, then the neutral profile $0$ lies in the chamber $C_i$.

> **Theorem 7.3 (Pythagorean exchange gap).** Weight three voters by the sides of a Pythagorean triple: $\delta = (a, b, c)$ with $a, b, c > 0$, $a \le b$ and $a^2 + b^2 = c^2$. Then at the neutral profile $0$:
> 1. voter $0$ (the leg $a$) is decisive: $0 \in C_0$;
> 2. the exchange threshold for the hypotenuse voter is $\theta_{02}(0) = a - c$;
> 3. the exchange gap is strictly positive: $c - a > 0$;
> 4. for every $\varepsilon > 0$, giving the hypotenuse voter the score $a - c - \varepsilon$ makes it the unique winner: the decisive set becomes $\{2\}$.

*Proof sketch.* (1) By Lemma 7.1, $a \le b$ and $a < c$, so $a$ is the least weight and Lemma 7.2 applies. (2) By definition, $\theta_{02}(0) = 0 + \delta_0 - \delta_2 = a - c$. (3) Lemma 7.1. (4) Theorem 3.4, since $a - c - \varepsilon < a - c = \theta$. $\square$

> **Corollary 7.4 (The $(3,4,5)$ instance).** With weights $(3,4,5)$, the neutral profile is decided by the leg-$3$ voter. The hypotenuse voter must revise its score to exactly $-2$ to tie, and to anything strictly below $-2$ to win outright.

The content of Theorem 7.3 is that the Pythagorean relation *forces* a strictly positive exchange gap: the hypotenuse can never be a leg, and correspondingly the hypotenuse voter can never be decisive at the neutral profile — it can only be made decisive by a concession of size at least $c - a$.

**Gaps as stability margins.** More generally, suppose all pairwise weight gaps are at least $\gamma > 0$, and let $x$ be a profile with a unique decisive voter $i$, with margin $\mu = \min_{k \ne i}(x_k + \delta_k) - (x_i + \delta_i) > 0$. If $\|x - x'\|_\infty < \mu/2$, then every monomial moves by less than $\mu/2$, so the ordering of the monomial at $i$ against the others is preserved and $D(x') = \{i\}$: the open chamber contains the sup-ball of radius $\mu/2$ around $x$. Together with the $1$-Lipschitz bound of Theorem 3.18, this says the entire system is stable under bounded perturbation, with the exchange thresholds serving as the exact stability radii. At the neutral profile the margin is precisely the smallest weight gap, so gaps in $\delta$ are, quantitatively, robustness of the incumbent.

---

## 8. Algorithms

All the results above are effective, and the resulting algorithms are simple enough to state completely. Let $n = |S|$.

**A. Decisive set.** Compute $m = \min_{k \in S} (x_k + \delta_k)$ and return $\{k : x_k + \delta_k = m\}$. Cost $\Theta(n)$.

**B. Exchange threshold and trichotomy.** Given $x$ with $D(x) = \{i\}$ and a challenger $j$: return $\theta = x_i + \delta_i - \delta_j$, and classify a candidate revision $c$ as *incumbent retained* ($c > \theta$), *wall* ($c = \theta$), or *challenger wins* ($c < \theta$). Cost $\Theta(1)$ after $O(n)$ preprocessing.

**C. Minimum-cost exchange to a target cell.** Given $x$ with $D(x) = \{i\}$ and a nonempty target $T \subseteq S$: output the mover set $M = T \setminus \{i\}$ (of size $|T| - [\,i \in T\,]$, the exchange distance) and the profile
$$y_k = \begin{cases} x_i + \delta_i - \delta_k & k \in M,\ i \in T \quad (\text{wall case, } \varepsilon = 0),\\ x_i + \delta_i - \delta_k - \varepsilon & k \in M,\ i \notin T \quad (\varepsilon > 0),\\ x_k & \text{otherwise.}\end{cases}$$
By Theorems 4.2–4.4 this is optimal, and $D(y) = T$ exactly. Cost $\Theta(n)$.

**D. Weight recovery from the labelling.** Given an oracle for $x \mapsto D(x)$: recover $S$ by testing, for each candidate voter $i$, whether some profile has $D = \{i\}$; then normalize $\delta_{i_0} = 0$ for a fixed $i_0 \in S$ and recover each remaining $\delta_i$ as the unique value $\tau$ such that the profile with $x_i = \tau$, $x_{i_0} = 0$ and all others large has $D = \{i, i_0\}$ — a binary search on a monotone predicate. By Theorem 6.9 this determines $\delta$ up to the additive constant that the normalization fixes, and no better. Cost $O(n \log(1/\text{tol}))$ oracle calls.

**E. $f$-vector and Euler characteristic.** Return $f_d = \binom{n}{d+1}$ for $0 \le d \le n-1$, total $2^n - 1$, alternating sum $1$ (Theorems 5.5–5.7). Cost $\Theta(n)$ arithmetic operations.

---

## 9. Applications

**Shortest paths and routing.** In the Bellman relaxation $d_v = \min_{u \to v}(d_u + w_{uv})$, the incoming edges are the voters, the edge weights are $\delta$, and the tentative distances are the profile. The decisive set is the set of optimal predecessors; walls are the ties that make shortest paths non-unique. The exchange threshold $\theta$ is exactly the amount by which a non-optimal predecessor's distance must fall to become optimal — that is, the *reduced cost* of that edge — and the converse of the exchange law says that a reroute onto a specific predecessor requires changing *that* predecessor's data, not somebody else's. The exchange distance says how many predecessor distances must fall to make a prescribed set of routes simultaneously optimal: exactly one per route, less the incumbent.

**Scheduling and critical paths.** With $F$ a makespan-type bottleneck, the exchange threshold of a non-critical task is its total slack, and Corollary 3.8 says that slack is socially invisible until it is exhausted, whereupon delay is transmitted one-for-one. The kink of $F$ along the exchange path is the transition from non-critical to critical.

**Piecewise-linear networks.** A min-plus form is the negative of a max-plus form, hence a maxout/ReLU-type unit. The chambers are the linear regions, the walls are the activation boundaries, and Theorems 5.5–5.7 give the exact region count $2^{|S|}-1$ (counting all faces) with the top count $|S|$; the trichotomy is a precise statement of which single input coordinate crosses which single activation boundary, and the $1$-Lipschitz bound of Theorem 3.18 is the tight local sensitivity of the unit.

**Social choice.** For the egalitarian bottleneck rule, the exchange threshold is the exact concession required for a challenger to unseat the incumbent, and Theorem 3.13 is a strong locality statement: to make $j$ the winner, $j$'s own score is the only lever. Theorem 6.9 is a measurement statement: an observer who sees only *who wins* under every profile learns the electorate and the weights up to a uniform shift — the shift being unobservable in principle, since it changes no comparison.

**Auctions and procurement.** With $\delta_i$ a fixed handling cost and $x_i$ a bid, $F$ is the awarded price and $D$ the winning bidders. The exchange threshold is the bid a losing supplier must submit to tie; the coalition exchange constructs the cheapest simultaneous undercut by a prescribed group; the rigidity theorems say that repeated observation of *winners only* pins the handling costs down to a common constant.

---

## 10. Discussion

Three features of the theory deserve emphasis.

**Everything is an equivalence.** The classical exchange statements — "at the threshold you land on the wall; below it you land in the challenger's chamber" — are implications. Here each is upgraded to an *if and only if* (Theorems 3.4, 3.5, 3.13), and the metric statement is upgraded from a pair of inequalities to an *attained least element* (Theorem 4.4). This is not pedantry: sharpness is what allows the combinatorial quantity $|T \setminus \{i\}|$ to be *identified* with the geometric codimension rather than merely bounded by it.

**Downwardness is a real hypothesis.** The failure exhibited in Theorem 4.6 is instructive. The exchange metric measures the cost of *lowering* scores, and min-plus aggregation is monotone; lowering can only promote the mover, while raising can promote a stationary bystander by lifting the aggregate to meet them. Any attempt to define a two-sided exchange metric will therefore have to count differently — a bystander promotion has cost zero in movers but is not free in any other sense.

**Rigidity is exactly one-dimensional.** The gauge group is the additive line $\mathbb{R}\cdot\mathbf{1}$ and not one iota larger (Theorem 6.9). It is the same degeneracy that makes tropical projective space the natural home of these fans: the complex lives naturally in $\mathbb{R}^{n}/\mathbb{R}\cdot\mathbf{1}$, where it becomes the normal fan of a simplex, and there the labelling determines the weights outright.

A conceptual summary: for a min-plus linear form, *combinatorics, geometry, and the numerical data are the same object*, related by an exact dictionary — subsets of $S$ $\leftrightarrow$ cells; cardinality minus one $\leftrightarrow$ codimension $\leftrightarrow$ exchange distance; the aggregate function $\leftrightarrow$ the weights; the labelling $\leftrightarrow$ the weights modulo a shift.

---

## 11. Future directions

Three research cycles were run on the chamber complex of the min-plus aggregator $F(x) = \min_{i \in S}(x_i + \delta_i)$: sharpness of the exchange law, the metric and combinatorics of the complex, and rigidity. The following are the natural next targets.

**1. Exchange-metric realization of arbitrary polyhedral fans.** The exchange distance $|T \setminus \{i\}|$ is a purely combinatorial quantity that computes a geometric codimension, so it should be a *complete* invariant of the normal fan of a simplex, and should fail to extend to normal fans of general polytopes.

> **Conjecture.** A complete polyhedral fan in $\mathbb{R}^n / \mathbb{R}\cdot\mathbf{1}$ arises as the chamber complex of some min-plus aggregator if and only if it is the normal fan of a simplex; equivalently, iff its dual graph is complete and its $f$-vector is $\bigl(\binom{n}{d+1}\bigr)_d$.

The two invariants (complete dual graph, binomial $f$-vector) are established here, and the rigidity theorems make "arises from a unique $(S,\delta)$" precise.

**2. Weighted exchange law for max-plus/min-plus mixtures, with Pythagorean weights.** The strictly positive exchange gap $c - a$ produced by a Pythagorean triple should be an instance of a general *spectral gap* between tropical monomials, controlling the stability of the incumbent under noise.

> **Conjecture.** For weights $\delta$ with pairwise gaps at least $\gamma > 0$, the incumbent's chamber contains a sup-ball of radius $\gamma/2$ around every profile whose label is a singleton.

**3. Two-sided exchange metrics.** Theorem 4.6 shows that the metric theory as developed is one-sided. What is the correct cost function for arbitrary (not necessarily monotone) moves? A natural candidate is a weighted count in which a bystander promotion is charged the size of the incumbent's own increase; the analogue of Theorem 4.5 for such a cost is open.

**4. Higher tropical hypersurfaces.** For a general tropical polynomial (not merely a linear form) the cells are labelled by subsets of the monomial set, but not every subset occurs and the fan is not the normal fan of a simplex. The natural questions — the exchange distance to a prescribed cell, the diameter of the dual graph, and the correct rigidity statement modulo tropical equivalence of polynomials — are all open, and Theorems 4.4, 5.2 and 6.9 are exactly the linear-form base cases.

**5. Stochastic exchange.** If the profile is random, the label $D(x)$ is a random nonempty subset of $S$. The exchange thresholds determine the boundaries of the events $\{D = T\}$, so the distribution of the winner is computable from the $\theta$'s. Quantifying the *probability of a wall crossing* under a diffusion on profile space would connect the exchange law to the theory of first-passage times.
