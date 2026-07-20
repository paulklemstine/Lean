# Infinite Games Against Death: Cofinal Survival at $\omega$ and $\omega^2$

## Abstract

We study an ordinal model of survival games in which every individual choice is finite but the collection of compatible play lengths may have transfinite supremum. The deterministic finite-delay profile assigns $n$ rounds to choice $n$. Its values are cofinal in the first infinite ordinal $\omega$, although every play is finite and every proposed finite cap is exceeded. We then introduce the block clock $C(k,n)=\omega k+n$, where $k$ is a finite block budget and $n$ a finite tail. At fixed $k$, the exact supremum is $\omega k+\omega$; every reading is below $\omega^2$; and the joint supremum over all finite $k,n$ is exactly $\omega^2$. Thus locally finite, non-uniformly bounded choices create a second transfinite level without creating a play of limit length. The same clocks occur in canonical dyadic surreal games: the birthday of $2^{-n}$ is $n+1$, so these birthdays are cofinal in $\omega$, while their $\omega$-weighted lift is cofinal in $\omega^2$. We present exact symbolic algorithms, applications to transfinite computation and ranked trees, and the decisive distinction between per-play and global bounds.

## 1. Introduction

A family of finite processes can have infinite ordinal height. This separates the duration of an individual process from the least ordinal bounding an entire family of durations.

Consider a game between Mortal and Eternity. Mortal chooses a finite delay, after which the play ends. No choice grants an infinite play. Nevertheless, if every natural-number delay is available, then no natural number uniformly bounds the strategy. Its durations are cofinal in $\omega$, the first infinite ordinal. In this sense the strategy forces survival up to $\omega$.

A richer clock arises when Mortal chooses a finite number $k$ of completed limit-sized blocks and a finite tail $n$. The resulting ordinal is $\omega k+n$. Each reading lies below $\omega^2$, but the full two-parameter family is cofinal in $\omega^2$. This gives a precise meaning to the claim that bounded nondeterminism can yield an $\omega^2$ survival rank: each branch has a finite budget, but no one finite budget bounds every branch.

The model is independent of any particular transition system. It supplies ordinal clock semantics suitable for comparison with infinite-time machines, nested termination arguments, and well-founded strategy trees. A realization through birthdays of dyadic surreal games shows that the clock is not peculiar to survival terminology.

Our contributions are an exact cofinality semantics for survival profiles; exact calculations at $\omega$ and $\omega^2$; a proof that every individual reading and every fixed block budget falls short of $\omega^2$; a dyadic-game realization; and algorithms for finite symbolic exploration.

## 2. Ordinal preliminaries

An **ordinal** is the order type of a well-ordered set. Natural numbers are finite ordinals. Their supremum is the least infinite ordinal:

$$
\omega=\sup_{n<\omega}n.
$$

For a family $(\alpha_i)_{i\in I}$, its supremum $\sup_i\alpha_i$ is the least ordinal greater than or equal to every member. A supremum need not occur in the family.

A family $A$ is **cofinal in** an ordinal $\lambda$ if for every $\beta<\lambda$ some $a\in A$ satisfies $\beta<a$. In the bounded situations considered here, this is equivalent to $\sup A=\lambda$. The finite ordinals are cofinal in $\omega$.

Ordinal addition and multiplication concatenate well-orders and are not commutative. For instance,

$$
3+\omega=\omega,
\qquad
\omega+3>\omega.
$$

For finite $k$, the ordinal $\omega k$ is a sequence of $k$ copies of $\omega$. The next scale is

$$
\omega^2=\omega\cdot\omega=\sup_{k<\omega}\omega k.
$$

We use continuity in the right argument:

$$
\sup_{n<\omega}(a+n)=a+\omega
$$

for every ordinal $a$, together with

$$
\sup_{k<\omega}\omega k=\omega^2.
$$

## 3. Survival semantics

### Definition 3.1 (finite survival profile)

A finite survival profile is a function $s:\mathbb N\to\mathrm{Ord}$ assigning an ordinal duration $s(n)$ to each finite choice $n$.

### Definition 3.2 (cofinal forcing)

A profile $s$ **forces survival up to** $\alpha$ when

$$
\alpha\leq\sup_{n<\omega}s(n).
$$

This concerns the family rank. It does not assert that one play attains $\alpha$.

### Definition 3.3 (canonical finite-delay strategy)

The canonical strategy is $s(n)=n$: Mortal requests $n$ more rounds.

### Theorem 3.4 (finite postponement)

The canonical strategy has exact supremum $\omega$ and therefore forces survival up to $\omega$:

$$
\sup_{n<\omega}s(n)=\omega.
$$

**Proof sketch.** The durations are exactly the finite ordinals. Their least upper bound is the first infinite ordinal $\omega$. $\square$

### Proposition 3.5 (non-attainment)

Every individual play is finite:

$$
\forall n\in\mathbb N,\quad s(n)<\omega.
$$

**Proof sketch.** Every natural number is strictly below $\omega$, and $s(n)=n$. $\square$

### Proposition 3.6 (no finite uniform cap)

For every $N\in\mathbb N$, there exists $n\in\mathbb N$ with $N<s(n)$.

**Proof sketch.** Choose $n=N+1$. Then $s(n)=N+1>N$. $\square$

Thus every play is finite, no play realizes $\omega$, and the family nevertheless has exact rank $\omega$. Infinite rank here means escape from every finite uniform bound.

## 4. The two-level block clock

### Definition 4.1 (bounded block strategy)

A bounded block strategy assigns an ordinal to each pair $(k,n)\in\mathbb N^2$. The first coordinate is a finite block budget and the second a finite tail.

### Definition 4.2 (two-parameter forcing)

A block strategy $C$ forces survival up to $\alpha$ when

$$
\alpha\leq\sup_{k<\omega}\sup_{n<\omega}C(k,n).
$$

### Definition 4.3 (canonical block clock)

The canonical clock is

$$
C(k,n)=\omega k+n.
$$

Here $k$ records completed $\omega$-blocks and $n$ records successor rounds. Representative readings are

$$
C(0,5)=5,
\qquad C(1,3)=\omega+3,
\qquad C(2,0)=\omega\cdot2.
$$

The leading block count and finite tail must remain distinct; ordinary integer arithmetic cannot represent their order type.

### Theorem 4.4 (exact fixed-budget supremum)

For every $k\in\mathbb N$,

$$
\sup_{n<\omega}C(k,n)=\omega k+\omega=\omega(k+1).
$$

**Proof sketch.** At fixed $k$, the sequence is $\omega k,\omega k+1,\omega k+2,\ldots$. Continuity of ordinal addition gives

$$
\sup_{n<\omega}(\omega k+n)=\omega k+\sup_{n<\omega}n=\omega k+\omega.
$$

The ordinal multiplication successor law identifies this with $\omega(k+1)$. $\square$

### Theorem 4.5 (every reading is below $\omega^2$)

For all $k,n\in\mathbb N$,

$$
C(k,n)<\omega^2.
$$

**Proof sketch.** A finite tail satisfies $\omega k+n<\omega k+\omega=\omega(k+1)$. Since $k+1<\omega$, monotonicity yields $\omega(k+1)<\omega\cdot\omega=\omega^2$. $\square$

### Corollary 4.6 (fixed budgets fall short)

For fixed $k$, all tails have supremum $\omega(k+1)<\omega^2$. Therefore no fixed finite block budget is cofinal in $\omega^2$.

**Proof sketch.** Combine Theorems 4.4 and 4.5. $\square$

### Theorem 4.7 (bounded nondeterminism forces $\omega^2$)

The block strategy forces survival up to $\omega^2$:

$$
\omega^2\leq\sup_{k<\omega}\sup_{n<\omega}C(k,n).
$$

**Proof sketch.** Choosing $n=0$ exhibits $C(k,0)=\omega k$ for every $k$. Hence the joint supremum dominates $\sup_k\omega k=\omega^2$. $\square$

### Theorem 4.8 (exact two-level clock)

The complete block clock has exact supremum

$$
\sup_{k<\omega}\sup_{n<\omega}(\omega k+n)=\omega^2.
$$

**Proof sketch.** Theorem 4.7 gives the lower bound. Theorem 4.5 makes $\omega^2$ an upper bound for every reading. Antisymmetry gives equality. Equivalently, Theorem 4.4 reduces the expression to $\sup_k\omega(k+1)=\omega^2$. $\square$

## 5. Local bounds and global bounds

“Bounded” means that each selected $k$ is finite. It does not mean that one finite $B$ bounds all selections. The quantifier patterns

$$
\forall p\ \exists B_p<\omega
$$

and

$$
\exists B<\omega\ \forall p
$$

are different. The first allows rank $\omega^2$; the second does not.

### Proposition 5.1 (a global bound collapses the second level)

If one fixed $B\in\mathbb N$ satisfies $k\leq B$ for every play, then

$$
\sup_{k\leq B}\sup_{n<\omega}(\omega k+n)
=\omega B+\omega
=\omega(B+1)
<\omega^2.
$$

**Proof sketch.** Among the finitely many possible block indices, $B$ is largest. The fixed-budget theorem gives the first equality. Since $B+1<\omega$, the resulting ordinal is below $\omega^2$. $\square$

The second transfinite level therefore comes from arbitrary finite budgets across the family, not from an infinite local choice.

## 6. Dyadic surreal birthdays

A combinatorial game is recursively constructed from sets of earlier left and right options. Its **birthday** is the least ordinal stage at which it can be constructed. Canonical surreal numbers are games, and dyadic units have transparent construction depths.

### Lemma 6.1 (dyadic birthday identity)

For every $n\in\mathbb N$, the canonical game representing $2^{-n}$ has birthday

$$
b(2^{-n})=n+1.
$$

**Proof sketch.** The unit $1=2^0$ is born at day $1$. Each canonical halving introduces one more recursive construction layer. Induction gives $n+1$. $\square$

### Theorem 6.2 (dyadic birthdays are cofinal in $\omega$)

The birthday spectrum has exact supremum

$$
\sup_{n<\omega}b(2^{-n})=\omega.
$$

**Proof sketch.** The lemma makes the spectrum $1,2,3,\ldots$. Every term is finite, while every finite ordinal is below some term. Thus its least upper bound is $\omega$. $\square$

The numerical values $2^{-n}$ decrease toward zero as their construction ages increase without finite bound. Birthday measures recursive depth, not numerical magnitude.

### Theorem 6.3 (nested dyadic clock)

The weighted birthday spectrum is cofinal in $\omega^2$:

$$
\sup_{k<\omega}\omega\,b(2^{-k})=\omega^2.
$$

**Proof sketch.** Substitute $b(2^{-k})=k+1$. The family becomes $\omega,\omega\cdot2,\omega\cdot3,\ldots$, whose supremum is $\omega\cdot\omega=\omega^2$. $\square$

The unweighted birthdays realize the first limit clock; weighting them by $\omega$ realizes the block lift.

## 7. Algorithms for symbolic exploration

Ordinals below $\omega^2$ admit a simple canonical representation: store $\omega k+n$ as the pair $(k,n)$. This is exact, unlike replacing $\omega$ by a large integer.

### Algorithm 7.1 (canonical ordinal-pair encoding)

**Input:** $k,n\in\mathbb N$.

**Output:** the symbolic reading $(k,n)$ representing $\omega k+n$.

Comparison is lexicographic: $(k,n)<(k',n')$ exactly when $k<k'$, or $k=k'$ and $n<n'$. Construction and comparison take constant time under unit-cost arithmetic; under bit complexity, comparison is linear in the coordinate bit lengths.

### Algorithm 7.2 (finite clock-window enumeration)

Given cutoffs $K,N$, enumerate all $(k,n)$ with $0\leq k<K$ and $0\leq n<N$ in lexicographic order. The output displays $K$ sampled blocks and $N$ tails per block. Time and output size are $O(KN)$; streaming uses $O(1)$ auxiliary storage.

A finite window is not a metric approximation to $\omega^2$. Increasing $N$ illustrates cofinal movement toward a next block boundary, while increasing $K$ exposes unbounded finite block indices.

### Algorithm 7.3 (dyadic birthday table)

For $0\leq n<N$, compute the exact rational $2^{-n}$, birthday $n+1$, and weighted boundary $\omega(n+1)$. Exact rational arithmetic prevents floating-point underflow. The algorithm performs $O(N)$ row operations, with denominator bit length $O(N)$.

## 8. Applications

### 8.1 Termination analysis

A program may terminate on every input while having no finite worst-case runtime. The profile $s(n)=n$ is the simplest ranking of that situation: every run has finite rank, while the family rank is $\omega$. Nested families, where an outer finite parameter controls blocks of inner finite work, naturally receive ranks $\omega k+n$ and global rank $\omega^2$.

### 8.2 Infinite-time computation

In transfinite machine models, successor stages perform ordinary transitions and limit stages apply a prescribed update. The expression $\omega k+n$ is the natural chronology for $k$ completed limit blocks followed by $n$ successor stages. The exact supremum theorem identifies the horizon of all finite pairs as $\omega^2$.

This clock calculation does not by itself construct a machine. An operational realization must define states, successor transitions, limit updates, control choices, and halting, and then prove equality between attainable halting ranks and the algebraic clock.

### 8.3 Ranked trees

A strategy may be represented as a tree of continuations. The distinction between branch length and tree rank mirrors the distinction between a clock reading and the family supremum. A suitable well-founded family can have only finite individual histories while carrying a transfinite rank. Any concrete tree theorem must state branching and rank conventions carefully, because compactness principles can turn unbounded finite depth into an infinite branch under additional hypotheses.

### 8.4 Scheduling and nested search

The pair $(k,n)$ may represent a finite number of phases and work remaining in a current phase. Lexicographic ordinal rankings establish progress when tails decrease within phases and block counts decrease at resets. In the opposite direction, the cofinal family records the lack of a uniform runtime when arbitrary finite phase budgets are admitted.

## 9. Discussion

The phrase “survival to $\omega$” does not mean that one play has length $\omega$. It means that the supremum of compatible finite lengths reaches $\omega$. Non-attainment is not a defect; it is the defining limit behavior.

Likewise, the $\omega^2$ theorem conceals no $\omega^2$-long play. Every pair is strictly below the limit. The transfinite value measures architecture: tails fill each block cofinally, and finite block indices fill the sequence of blocks cofinally.

The dyadic result gives an independent conceptual realization. The identity $b(2^{-n})=n+1$ turns a familiar arithmetic family into unbounded finite game ranks. Multiplication by $\omega$ produces precisely the block boundaries of the survival model. Postponement choices and recursive construction ages share one ordinal skeleton.

The model has intentional limitations. It records lengths rather than rich strategic interaction, information sets, or adversarial transitions. Bounded nondeterminism is represented extensionally by finite indices. The relation to infinite-time machines is therefore structural until a concrete operational semantics is supplied.

## 10. Future work

The first direction is a finite-depth hierarchy. A $d$-tuple of finite counters, read lexicographically with ordinal place values, should be cofinal in $\omega^d$ while each reading remains below $\omega^d$. A uniform induction would generalize the present one- and two-level theorems.

The second direction is operational realization in an infinite-time register or Turing machine. A first limit stage can reset a finite tail while retaining a count of completed blocks. The goal is equality of operational ranks and algebraic readings, not merely a bound.

Third, explicit well-founded survival trees should realize rank $\omega^2$ while their fixed-budget subtrees remain below it. This would clarify the interaction between local branching constraints and global rank.

Finally, iterated game constructors may produce birthday spectra cofinal in $\omega^d$. Finding arithmetic families as transparent as the dyadic units would connect higher ordinal clocks with combinatorial-game structure.

## 11. Conclusion

The finite-delay strategy has exact rank $\omega$: every play is finite, yet no finite cap bounds them all. The block clock $C(k,n)=\omega k+n$ raises this pattern one level. Fixed tails approach the next block boundary, every reading lies below $\omega^2$, and arbitrary finite block budgets produce exact supremum $\omega^2$. A single global budget prevents this phenomenon.

Dyadic surreal birthdays realize the same hierarchy: $b(2^{-n})=n+1$ is cofinal in $\omega$, and its $\omega$-weighted lift is cofinal in $\omega^2$. Across survival games, computation clocks, and game birthdays, transfinite height belongs to a family of finite objects even when no member attains the limit.

## Appendix A. Worked examples and boundary cases

This appendix develops several concrete instances of the general results and clarifies common misreadings of the notation.

### A.1 The first clock

Suppose Eternity proposes the cap $7$. Mortal selects $8$, and the duration is $s(8)=8>7$. If the cap is $19$, Mortal selects $20$. The same successor response defeats every finite proposal. There is no final response that “reaches” $\omega$; the rule instead produces an unending sequence of stronger finite responses.

For a finite sample cutoff $N$, the maximum observed duration is $N$. Increasing the cutoff changes that maximum. Consequently, no finite experiment establishes a numerical maximum for the infinite family. The theorem relies on the symbolic characterization of $\omega$ as the supremum of all natural numbers, not on extrapolating measured data.

### A.2 A fixed block

Take $k=2$. The readings are

$$
\omega\cdot2,
\quad \omega\cdot2+1,
\quad \omega\cdot2+2,
\quad\ldots.
$$

Their supremum is

$$
\omega\cdot2+\omega=\omega\cdot3.
$$

No finite tail $n$ produces the boundary $\omega\cdot3$. If someone proposes a particular tail cap $N$, choosing $N+1$ moves farther within the same block, but still does not leave it. Thus there are two distinct non-attainment statements: no finite tail attains its next block boundary, and no finite block index attains the global boundary $\omega^2$.

### A.3 Comparing readings

Consider $C(1,1000)=\omega+1000$ and $C(2,0)=\omega\cdot2$. The second is larger. Indeed, every finite tail after one $\omega$-block occurs before the start of the second block:

$$
\omega+1000<\omega+\omega=\omega\cdot2.
$$

This explains lexicographic comparison of pairs. The block coordinate dominates every finite difference in the tail coordinate. It would be incorrect to replace $\omega$ by a chosen large integer $M$, because then a sufficiently large tail could cross an artificial block boundary. Symbolic pairs preserve the ordinal structure exactly.

### A.4 Diagonal subfamilies

The full two-dimensional grid is not needed to witness the lower bound. The subfamily with $n=0$ already contains

$$
0,\omega,\omega\cdot2,\omega\cdot3,\ldots,
$$

which is cofinal in $\omega^2$. Similarly, many diagonal selections, such as $C(k,k)=\omega k+k$, are cofinal in $\omega^2$, because their block coefficients are unbounded. By contrast, any subfamily whose block coefficients are bounded by one finite $B$ has supremum at most $\omega(B+1)$.

This yields a useful criterion for subsets of the canonical clock. If their block indices are unbounded in $\mathbb N$, their readings are cofinal in $\omega^2$ regardless of the chosen finite tails. If their block indices have a finite bound, they are not cofinal in $\omega^2$.

### A.5 The birthday reversal

The dyadic sequence has values

$$
1,\frac12,\frac14,\frac18,\ldots,
$$

but birthdays

$$
1,2,3,4,\ldots.
$$

The values decrease while the birthdays increase. There is no contradiction: numerical order and construction rank are different structures. The example warns against interpreting a rank as a magnitude of the represented object. After weighting by $\omega$, the birthdays give

$$
\omega,\omega\cdot2,\omega\cdot3,\omega\cdot4,\ldots,
$$

which approach $\omega^2$ cofinally.

## Appendix B. A reusable proof pattern

The arguments above instantiate a general two-sided method for exact supremum calculations.

First, establish an upper bound by proving that every member of the family lies below a proposed limit $L$. This shows

$$
\sup_i a_i\leq L.
$$

Second, establish cofinality by finding a simpler subfamily $(b_j)$ among the $(a_i)$ whose supremum is already $L$. This shows

$$
L=\sup_j b_j\leq\sup_i a_i.
$$

Antisymmetry then gives equality. For the block clock, the pointwise upper bound is $C(k,n)<\omega^2$, while the subfamily $C(k,0)=\omega k$ supplies the lower bound. For dyadic birthdays, the exact identity $b(2^{-n})=n+1$ reduces both bounds to standard cofinality of the natural numbers.

This pattern is valuable in algorithmic rank analysis. Upper bounds often follow from a decreasing measure, while lower bounds follow from a deliberately chosen family of executions that approaches the proposed rank. Proving only the upper bound establishes termination strength but not sharpness; proving only the lower bound establishes richness but not containment. Exactness requires both.

## Appendix C. Terminology and scope

The word **strategy** here denotes a profile of compatible durations rather than a complete policy in an extensive-form game with alternating moves. The word **forces** denotes a lower bound on the profile supremum. These choices isolate the ordinal content and should not be confused with claims about winning strategies under arbitrary adversarial semantics.

The word **finite** always means a natural-number ordinal. The phrase **bounded nondeterminism** means that each choice supplies a finite budget. It does not mean uniform boundedness over all choices. Whenever a global bound is intended, it is stated explicitly.

Finally, $\omega^2$ is ordinal multiplication $\omega\cdot\omega$, not a cardinality larger than countable infinity. The set of pairs $\mathbb N^2$ is countable, as is the ordinal $\omega^2$. What differs is order type: $\omega^2$ organizes countably many successive $\omega$-blocks. The results concern order and rank, not a larger number of elements.
