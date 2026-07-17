# Singleton Sum Avoidance and the Triangular Increment Model

## Abstract

We analyze a proposed “anti-Fibonacci” recurrence in which each new term is the smallest positive integer unequal to the sum of the preceding two terms. The least-excluded wording makes the recurrence rigid: for positive predecessors their sum is at least $2$, so $1$ is always the least admissible value. With initial values $1,1$, the unique trajectory is therefore constant. Every consecutive ratio equals $1$, and every consecutive pair has greatest common divisor $1$. We separately analyze the frequently associated list $1,1,2,4,7,11,16,\ldots$. That list obeys the increment recurrence $D_{n+1}=D_n+n$, not the singleton sum-avoidance recurrence, and has the exact closed form $D_n=1+n(n-1)/2$. Hence $D_n/n^2\to1/2$. On even indices it differs from $\lfloor n^2/4\rfloor$ by exactly $k(k-1)+1$ at index $2k$, proving that the discrepancy from the proposed quarter-square law is unbounded. These results isolate the structural weakness of singleton avoidance and motivate recurrences with growing forbidden sets.

## 1. Introduction

The Fibonacci recurrence

$$
F_{n+2}=F_{n+1}+F_n
$$

turns a local additive instruction into exponential growth. For positive initial data, consecutive ratios approach the golden ratio $\varphi=(1+\sqrt5)/2$. It is natural to ask whether an “anti-Fibonacci” instruction—one that avoids the same local sum—produces contrasting asymptotic behavior.

Consider the literal rule: begin with $A_0=A_1=1$, and let $A_{n+2}$ be the smallest positive integer that is not equal to $A_n+A_{n+1}$. This rule has been associated with the displayed list

$$
1,1,2,4,7,11,16,22,29,\ldots,
$$

and with conjectures of quarter-square growth, nonconvergent consecutive ratios, and sparse additive complements. The purpose of this paper is to resolve the definitions before addressing asymptotics.

The decisive observation is elementary. If $x$ and $y$ are positive, then $x+y\ge2$. Therefore $1$ is unequal to $x+y$, and it is already the smallest positive integer. The literal rule consequently selects $1$ at every stage. The resulting trajectory is unique and constant.

The displayed list nevertheless has a transparent mathematical origin. Its successive increments are $0,1,2,3,\ldots$, so it follows the recurrence $D_{n+1}=D_n+n$. It is exactly one plus a triangular number and grows with leading coefficient $1/2$, not $1/4$. Thus two distinct models have been conflated: a singleton-avoidance model that collapses and an increment model that grows quadratically.

This distinction illustrates a general principle for greedy least-excluded constructions. Their behavior is controlled not merely by the magnitude of forbidden values but by coverage of the smallest candidates. Forbidding a single value at least $2$ cannot dislodge the candidate $1$. Nontrivial growth requires additional restrictions, such as nonrepetition or a forbidden set of many earlier sums.

The paper is organized as follows. Section 2 defines the literal least-avoidance relation and the displayed increment model. Section 3 classifies all literal trajectories with initial values $1,1$. Section 4 derives the exact closed form of the displayed sequence. Section 5 disproves the quarter-square bounded-error conjecture and records the corrected asymptotics. Section 6 gives algorithms and complexity bounds. Section 7 discusses applications to greedy constructions and additive combinatorics, and Section 8 proposes extensions with genuinely growing forbidden sets.

## 2. Definitions and preliminary observations

Throughout, $\mathbb N=\{0,1,2,\ldots\}$, while “positive integer” means an element of $\{1,2,3,\ldots\}$.

### 2.1. Least avoidance of a single sum

**Definition 2.1 (least positive integer avoiding a sum).** Given $x,y,z\in\mathbb N$, we say that $z$ is the least positive integer avoiding the sum $x+y$ if:

1. $z>0$;
2. $z\ne x+y$; and
3. for every positive integer $k$ with $k\ne x+y$, one has $z\le k$.

The third condition supplies the essential minimality. Merely asking for some positive integer different from $x+y$ would leave infinitely many choices and would not define a recurrence.

**Definition 2.2 (literal anti-Fibonacci trajectory).** A sequence $(A_n)_{n\ge0}$ of natural numbers is a literal anti-Fibonacci trajectory if $A_0=A_1=1$ and, for every $n\ge0$, the term $A_{n+2}$ is the least positive integer avoiding $A_n+A_{n+1}$ in the sense of Definition 2.1.

The positivity requirement is crucial. If arbitrary integer predecessors were permitted, their sum could equal $1$, and the least admissible positive integer would then be $2$. Under Definition 2.2, however, positivity starts at the initial terms and is preserved by the rule itself.

### 2.2. The displayed increment sequence

**Definition 2.3 (displayed increment model).** Define $(D_n)_{n\ge0}$ by

$$
D_0=1,
\qquad
D_{n+1}=D_n+n
\quad(n\ge0).
$$

The first values are

$$
D_0=1,
\ D_1=1,
\ D_2=2,
\ D_3=4,
\ D_4=7,
\ D_5=11,
\ D_6=16.
$$

This definition captures the displayed data exactly. It is not an avoidance condition: it specifies a deterministic additive increment.

**Definition 2.4 (quarter-square comparison).** For $n\ge0$, let

$$
Q(n)=\left\lfloor\frac{n^2}{4}\right\rfloor.
$$

We will compare $D_n$ with $Q(n)$. A statement of the form $D_n=Q(n)+O(1)$ means that there is a constant $C\ge0$ such that $|D_n-Q(n)|\le C$ for all sufficiently large $n$. We prove a stronger negation: for every $C\ge0$, some $n$ satisfies $D_n>Q(n)+C$.

## 3. Complete classification of the literal rule

The classification rests on a local lemma.

**Lemma 3.1 (least-avoidance lemma).** Let $x$ and $y$ be positive integers. If $z$ is the least positive integer unequal to $x+y$, then $z=1$.

**Proof sketch.** Since $x,y\ge1$, we have $x+y\ge2$, and hence $1\ne x+y$. Thus $1$ is an admissible positive candidate. By minimality, $z\le1$. Since $z$ is positive, $z\ge1$. Therefore $z=1$. $\square$

The lemma shows that no detailed information about $x$ and $y$ is needed beyond positivity. In particular, the size of their sum has no influence on the output.

**Theorem 3.2 (uniqueness of the literal trajectory).** If $(A_n)_{n\ge0}$ is a literal anti-Fibonacci trajectory, then

$$
A_n=1
$$

for every $n\ge0$.

**Proof sketch.** The initial conditions give $A_0=A_1=1$. Proceed by strong induction on $n$. The cases $n=0,1$ are given. For $n\ge2$, write $n=m+2$. The earlier values $A_m$ and $A_{m+1}$ are $1$ by induction, hence positive. Lemma 3.1 applied to the defining step yields $A_{m+2}=1$. $\square$

Existence must be checked as well as uniqueness.

**Theorem 3.3 (existence of the constant trajectory).** The constant sequence $A_n=1$ for all $n\ge0$ is a literal anti-Fibonacci trajectory.

**Proof sketch.** The initial conditions are immediate. At every step the forbidden sum is $1+1=2$. The value $1$ is positive, differs from $2$, and is the least positive integer. Hence every step satisfies the rule. $\square$

Together, Theorems 3.2 and 3.3 give a complete classification: the literal model has exactly one trajectory.

Two immediate consequences address the proposed ratio behavior and a basic arithmetic property.

**Corollary 3.4 (constant consecutive ratio).** For every literal anti-Fibonacci trajectory and every $n\ge0$,

$$
\frac{A_{n+1}}{A_n}=1.
$$

**Proof sketch.** By Theorem 3.2, both numerator and denominator equal $1$. $\square$

Thus the ratios do converge, and indeed they are identically $1$. There is no oscillation between $1$ and $2$.

**Corollary 3.5 (consecutive coprimality).** For every literal anti-Fibonacci trajectory and every $n\ge0$,

$$
\gcd(A_{n+1},A_n)=1.
$$

**Proof sketch.** Again, Theorem 3.2 reduces the claim to $\gcd(1,1)=1$. $\square$

The coprimality conclusion is valid but should not be mistaken for evidence of a complicated number-theoretic pattern. It is a direct consequence of complete collapse.

## 4. Exact analysis of the displayed increment model

The displayed sequence has a different recurrence and a nonconstant trajectory. Its formula follows by summing arithmetic increments.

**Theorem 4.1 (division-free triangular identity).** For every $n\ge0$,

$$
2D_n=n(n-1)+2.
$$

**Proof sketch.** At $n=0$, both sides equal $2$. Suppose the formula holds at $n$. Using $D_{n+1}=D_n+n$,

$$
2D_{n+1}=2D_n+2n
=n(n-1)+2+2n
=n(n+1)+2,
$$

which is the required formula at $n+1$. $\square$

This division-free statement is convenient over the natural numbers. Since $n(n-1)$ is always even, it yields the ordinary closed form.

**Theorem 4.2 (closed form).** For every $n\ge0$,

$$
D_n=1+\frac{n(n-1)}2.
$$

**Proof sketch.** Divide the identity of Theorem 4.1 by $2$. Alternatively, telescope the recurrence:

$$
D_n=D_0+\sum_{j=0}^{n-1}j
=1+\frac{n(n-1)}2.
$$

$\square$

The closed form provides direct evaluations. For example,

$$
D_6=1+\frac{6\cdot5}{2}=16,
\qquad
D_8=1+\frac{8\cdot7}{2}=29.
$$

It also gives first and second differences:

$$
D_{n+1}-D_n=n,
$$

and

$$
(D_{n+2}-D_{n+1})-(D_{n+1}-D_n)=1.
$$

Thus the displayed sequence is a discrete quadratic with constant second difference $1$.

**Corollary 4.3 (normalized limit).** The displayed increment sequence satisfies

$$
\lim_{n\to\infty}\frac{D_n}{n^2}=\frac12.
$$

**Proof sketch.** For $n>0$, Theorem 4.2 gives

$$
\frac{D_n}{n^2}
=\frac1{n^2}+\frac{n(n-1)}{2n^2}
=\frac12-\frac1{2n}+\frac1{n^2}.
$$

The last two terms tend to $0$. $\square$

**Corollary 4.4 (consecutive-ratio limit for the displayed model).** The displayed sequence satisfies

$$
\lim_{n\to\infty}\frac{D_{n+1}}{D_n}=1.
$$

**Proof sketch.** Using the closed form, both $D_{n+1}$ and $D_n$ have leading term $n^2/2$. More explicitly,

$$
\frac{D_{n+1}}{D_n}
=1+\frac{n}{D_n},
$$

and $n/D_n\to0$ because $D_n$ is quadratic. $\square$

Hence neither interpretation produces persistent oscillation between ratios near $1$ and $2$: the literal model has ratio exactly $1$, while the displayed model approaches $1$.

## 5. Failure of the quarter-square model

The normalized limit already conflicts with a leading coefficient of $1/4$. An exact decomposition on even indices gives a stronger, integer-valued result.

**Theorem 5.1 (even-index decomposition).** For every $k\ge0$,

$$
D_{2k}=Q(2k)+k(k-1)+1.
$$

**Proof sketch.** Since $(2k)^2/4=k^2$, one has $Q(2k)=k^2$. Theorem 4.2 gives

$$
D_{2k}
=1+\frac{(2k)(2k-1)}2
=1+k(2k-1)
=2k^2-k+1.
$$

Subtracting $k^2$ leaves $k^2-k+1=k(k-1)+1$. $\square$

The discrepancy is not merely nonzero; it grows like $k^2$.

**Theorem 5.2 (unbounded discrepancy from the quarter-square law).** For every nonnegative integer $C$, there exists $n\ge0$ such that

$$
Q(n)+C<D_n.
$$

Consequently, no estimate of the form

$$
D_n=\left\lfloor\frac{n^2}{4}\right\rfloor+O(1)
$$

is valid.

**Proof sketch.** Choose an integer $k$ such that $k(k-1)+1>C$; for example, $k=C+2$ suffices. Set $n=2k$. By Theorem 5.1,

$$
D_n-Q(n)=k(k-1)+1>C.
$$

Since this can be done for every $C$, the discrepancy is unbounded. $\square$

The theorem is stronger than comparing limits. It explicitly constructs a violating index for every proposed error bound. With $k=C+2$, one may take

$$
n=2(C+2).
$$

At this index the discrepancy equals

$$
(C+2)(C+1)+1,
$$

which is greater than $C$.

## 6. Algorithms and numerical demonstrations

The preceding results yield simple algorithms with sharply different purposes.

### 6.1. Simulating the literal recurrence

Given positive predecessors $x$ and $y$, a general least-avoidance routine could test positive candidates in ascending order until it finds one unequal to $x+y$. For the present domain this search is unnecessary: Lemma 3.1 proves that the answer is always $1$. Thus an optimized generator writes $1$ at every position.

For a requested prefix of length $N$, the running time is $O(N)$ because $N$ outputs must be produced, and the auxiliary working space is $O(1)$ apart from the output array. If values are streamed rather than stored, total auxiliary space remains $O(1)$.

### 6.2. Generating the displayed sequence

The recurrence algorithm starts with $D=1$ and, at stage $n$, outputs $D$ and then replaces it by $D+n$. It uses one addition per term, runs in $O(N)$ arithmetic operations for $N$ outputs, and uses $O(1)$ auxiliary space aside from storage.

For random access, Theorem 4.2 provides

$$
D_n=1+\frac{n(n-1)}2.
$$

This requires a constant number of arithmetic operations. In a bit-complexity model, the cost depends on multiplication of integers with $O(\log n)$ bits; under unit-cost arithmetic it is $O(1)$.

### 6.3. Certifying failure of any proposed bound

Given $C\ge0$, choose $k=C+2$ and $n=2k$. Compute $D_n$ from the closed form and $Q(n)=\lfloor n^2/4\rfloor$. Theorem 5.1 ensures

$$
D_n-Q(n)=k(k-1)+1>C.
$$

The construction is deterministic and requires constant many arithmetic operations. It is a certificate-producing algorithm: the output index $n$ witnesses failure of the proposed bound $C$.

### 6.4. Large-scale normalized checks

For a large index such as $n=10^6$, the closed form gives

$$
\frac{D_n}{n^2}
=\frac12-\frac{1}{2\cdot10^6}+\frac{1}{10^{12}},
$$

which is close to $1/2$, not $1/4$. Such computations illustrate the theorem but are not substitutes for it. The exact identity proves the behavior for every index and the limit follows symbolically.

## 7. Structural interpretation and applications

### 7.1. Least-excluded dynamics

The smallest excluded-value principle, often called a minimum-excluded or greedy admissibility rule, responds primarily to the low end of the candidate set. If a rule forbids only a value $s\ge2$, then $1$ remains admissible, regardless of how large or arithmetically complicated $s$ is. To force the selected value above $m$, every candidate $1,2,\ldots,m$ must be forbidden or independently disallowed.

This viewpoint is useful in greedy graph coloring, scheduling, resource allocation, and combinatorial game theory. A large forbidden label may have no effect on a least-choice algorithm; a dense block of small forbidden labels controls the output. The literal anti-Fibonacci recurrence is an extreme example in which the same smallest candidate survives forever.

### 7.2. Recurrences versus fitted data

A finite list can suggest many incompatible rules. The displayed values visibly encode increasing differences, making the triangular recurrence natural. But they do not satisfy the stated singleton-avoidance rule: after $A_0=A_1=1$, the forbidden sum is $2$, so the least allowed value is $1$, not $2$.

This emphasizes a methodological point. Before extrapolating asymptotics from data, one should verify that the data satisfy the proposed local definition. Difference tables are useful for recognizing polynomial sequences; direct substitution is indispensable for checking recurrence claims.

### 7.3. Additive-combinatorial redesign

A richer avoidance process can be formed by forbidding the set of sums of two earlier selected terms. If $S_n=\{a_0,\ldots,a_n\}$, one might forbid

$$
S_n\mathbin{\widehat{+}}S_n
=\{a_i+a_j:0\le i<j\le n\},
$$

and choose the least positive integer outside this restricted sumset, perhaps also requiring the new term not to have appeared before. Unlike a singleton, this forbidden set grows with $n$ and may cover many small candidates.

Such a model creates legitimate questions about the density of selected values, the density of representable sums, polynomial growth exponents, and stability under changes of initial conditions. None of those questions is meaningful for the literal constant trajectory in the intended sense, because the process never explores larger integers.

### 7.4. Ratio behavior

The Fibonacci ratio tends to a constant greater than $1$ because Fibonacci growth is exponential. Polynomially growing positive sequences generally have consecutive ratios tending to $1$. The displayed model confirms this: $D_n\sim n^2/2$ implies $D_{n+1}/D_n\to1$. Persistent oscillation between values bounded away from $1$ would require repeated multiplicative jumps, a phenomenon not generated by either singleton avoidance or smooth quadratic increments.

This suggests a phase-transition question for broader greedy recurrences. Bounded forbidden-set size may be insufficient to create repeated multiplicative gaps, whereas unbounded forbidden sets can potentially do so by covering long initial intervals of candidates.

### 7.5. Boundary conditions and alternative domains

The least-avoidance lemma depends exactly on the positivity of both predecessors. This dependence is worth isolating because it explains why superficially similar variants can behave differently. For arbitrary integers $x$ and $y$, the least positive integer unequal to $x+y$ is $2$ when $x+y=1$, and $1$ otherwise. Thus a recurrence over all integers can react only to the exceptional event that the preceding sum equals $1$. With the prescribed initial values $1,1$, that event never occurs, so broadening the ambient domain alone does not alter the classified trajectory.

Changing “positive integer” to “nonnegative integer” has an even more dramatic effect. The least nonnegative candidate would usually be $0$, and a rule initialized at $1,1$ would immediately fall to $0$ whenever the forbidden sum were nonzero. This shows that the candidate domain is part of the dynamics, not harmless notation.

A nonrepetition convention would also change the model substantially. If previously selected values were prohibited, then after selecting $1$ the process could no longer return to it. The rule would cease to be singleton avoidance because the set of forbidden values would include the entire history in addition to the latest sum. Such a model may grow, but its behavior cannot be inferred from the theorems above without fresh analysis.

### 7.6. Logical status of the original asymptotic claims

It is useful to distinguish rejection from correction. For the literal trajectory, a claim such as $A_n\sim n^2/4$ is false because $A_n=1$. Its normalized values satisfy

$$
\frac{A_n}{n^2}=\frac1{n^2}\longrightarrow0
$$

for positive $n$. The ratio claim is also false in the proposed form because $A_{n+1}/A_n=1$ identically. Any claim about the density of a complement must first specify precisely which set of integers and which representation rule are intended; the constant trajectory does not realize the advertised additive structure.

For the displayed increment sequence, the quarter-square asymptotic is not repaired by changing only a bounded error term. The correct statement is the exact identity

$$
D_n=\frac12n^2-\frac12n+1,
$$

which gives $D_n=n^2/2+O(n)$. The lower-order term is linear and explicit. Therefore the correct asymptotic hierarchy is stronger than a leading-term limit but different from the proposed bounded-error formula.

These distinctions prevent results from one interpretation being transferred to another. The constant model answers the literal recurrence; the triangular model answers the displayed data. A future growing-forbidden-set model would constitute a third object and would require its own definitions and theorems.

## 8. Future directions

The classification identifies exactly what must change to obtain a nontrivial theory.

First, one may study growing forbidden-sum sets: at each stage choose the least unused positive integer outside all sums of two distinct earlier terms. The central problems are existence of stable growth exponents and sensitivity to finite changes in initial conditions.

Second, recurrences may be classified by forbidden-set cardinality. If at stage $n$ at most $r(n)$ candidates are forbidden, how quickly can the least admissible value grow? The singleton model supplies the cardinality-one endpoint. A sharp distinction may occur between bounded and linearly growing $r(n)$.

Third, the displayed increment model admits exact higher-order asymptotic analysis. Since

$$
D_n=\frac12n^2-\frac12n+1,
$$

all shifted rational normalizations can be expanded explicitly, and integer-valued affine perturbations with the same leading term can be classified.

Fourth, ratio-limit behavior should be studied under structural assumptions such as monotonicity and unboundedness. It is natural to ask whether bounded forbidden-set size forces consecutive ratios toward $1$, and whether oscillation bounded away from $1$ requires forbidden sets of unbounded size.

Finally, increasing greedy sequences that exclude every earlier pair-sum lead directly to additive-combinatorial density questions. Their selected sets and sumsets may exhibit complementary sparsity laws unavailable in the singleton model.

## 9. Conclusion

The literal anti-Fibonacci recurrence is completely rigid. Because the sum of two positive predecessors is at least $2$, the least positive integer unequal to that sum is always $1$. Starting from $1,1$, the unique trajectory is constant; all consecutive ratios equal $1$, and consecutive terms are coprime.

The displayed list $1,1,2,4,7,11,16,\ldots$ belongs to a separate increment model. It satisfies $D_{n+1}=D_n+n$ and has exact form

$$
D_n=1+\frac{n(n-1)}2.
$$

Its normalized values tend to $1/2$. At even index $2k$, its discrepancy from $\lfloor n^2/4\rfloor$ is exactly $k(k-1)+1$, so no bounded-error quarter-square estimate is possible.

The broader lesson is structural: avoiding one sum is too weak to drive a least-positive selection process upward. Nontrivial anti-additive growth requires a forbidden set capable of occupying the smallest available values. That observation turns a failed conjecture into a precise design principle for future avoidance sequences.