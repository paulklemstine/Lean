# A Greedy Integer Sequence with Global Pair-Sum Avoidance

**Aristotle**  
**July 22, 2026**

## Abstract

We study a repaired greedy recurrence designed to express global additive avoidance without ambiguity. Beginning with $a_0=1$, the successor $a_{n+1}$ is defined to be the least integer strictly larger than $a_n$ that is not a sum of two values among $a_0,\ldots,a_n$; repetition of a summand is permitted. We prove that the successor exists after every finite nondecreasing history and satisfies the explicit bound $a_{n+1}\le 2a_n+1$. Every resulting trajectory is strictly increasing and contains no chronological additive triple: if $i<k$ and $j<k$, then $a_i+a_j\ne a_k$. Equivalently, the chronological additive hypergraph on every finite initial segment is empty. We also show that the triangularly growing displayed list $1,1,2,4,7,\ldots$ is incompatible with the repaired rule, both because it is not strictly increasing at the beginning and because $1+1=2$. Algorithms for constructing the sequence, certifying a finite prefix, and enumerating additive triples are presented with complexity analyses. The framework separates established structural results from the experimentally suggested exact formula $a_n=2n+1$ and motivates questions about higher-order avoidance, perturbative stability, residue classes, and density.

## 1. Introduction

Greedy recurrences are often described informally: choose the smallest integer that avoids a prohibited relation with previously selected terms. Such descriptions are mathematically useful only when the candidate universe, the temporal scope of the prohibition, and the possibility of continuing the construction are all explicit. Additive recurrences are especially sensitive to these choices. A rule excluding one distinguished sum is fundamentally different from a rule excluding every sum formed from the available history. Likewise, “the smallest allowed integer” may repeatedly select the same value unless forward motion or non-repetition is included.

This paper isolates a natural global repair. At time $n$, all ordered pair sums $a_i+a_j$ with $0\le i,j\le n$ are forbidden, including the repeated-index sums $2a_i$. The next term must exceed the current term, and among all such candidates we choose the least. Thus three ingredients are built into the definition:

1. the candidate universe is the positive integers above the current value;
2. the obstruction set is the complete restricted pair sumset of the history;
3. the choice is greedy within that candidate universe.

Our first task is well-posedness. A recursive rule that can become trapped does not define an infinite trajectory. For a nondecreasing history, however, every forbidden sum is at most $2a_n$, so $2a_n+1$ is always available. This observation simultaneously proves existence and, by greedy minimality, gives the one-step ceiling $a_{n+1}\le 2a_n+1$.

The rule itself forces strict growth. It also prevents any later selected value from being a sum of two earlier values. This chronological avoidance statement has an exact hypergraph reformulation: if indices are vertices and additive triples are hyperedges, every finite chronological additive hypergraph is empty.

A second purpose of the paper is diagnostic. The list

$$
1,1,2,4,7,\ldots
$$

is given by $1+n(n-1)/2$ at the displayed indices, but it cannot arise from the global rule. The first repeated value violates strict growth, and the third value is the forbidden sum $1+1$. Therefore any problem that pairs this prefix with global pair-sum avoidance must revise either the prefix or the recurrence.

The remainder is organized as follows. Section 2 gives the definitions and clarifies chronology. Section 3 proves the witness lemma and successor existence. Section 4 derives strict monotonicity, additive avoidance, the growth ceiling, and hypergraph emptiness. Section 5 establishes incompatibility of the triangular prefix. Section 6 describes algorithms and numerical experiments. Sections 7 and 8 discuss applications, limitations, and future research.

## 2. Definitions and conventions

Throughout, $\mathbb N=\{0,1,2,\ldots\}$. A sequence is a function $a:\mathbb N\to\mathbb N$. Although the terms selected by the recurrence are positive, using zero-based indices simplifies the notation.

### Definition 2.1 (Prior pair-sum set)

For a sequence $a$ and an integer $n\ge 0$, define

$$
P_n(a)=\{a_i+a_j:0\le i\le n,\ 0\le j\le n\}.
$$

Indices may repeat, so $2a_i\in P_n(a)$ whenever $i\le n$. Although the definition uses ordered pairs, the resulting object is a set, and hence duplicate representations of the same sum are ignored.

The following elementary characterization will be used repeatedly.

### Lemma 2.2 (Witness characterization)

For every integer $s$,

$$
s\in P_n(a)
$$

if and only if there exist indices $i,j$ satisfying $0\le i,j\le n$ and $a_i+a_j=s$.

**Proof sketch.** The forward implication unpacks membership in the image of the finite index square $\{0,\ldots,n\}^2$ under the map $(i,j)\mapsto a_i+a_j$. The reverse implication inserts the witnessing pair $(i,j)$ into that square. $\square$

### Definition 2.3 (Admissibility)

An integer $z$ is **admissible after time $n$** if

$$
a_n<z \quad\text{and}\quad z\notin P_n(a).
$$

The first condition enforces forward motion. The second is global relative to the available history: it excludes every pair sum, not merely one selected sum.

### Definition 2.4 (Greedy successor)

An integer $z$ is the **greedy successor after time $n$** if $z$ is admissible after time $n$ and every admissible integer $w$ satisfies $z\le w$.

Thus a greedy successor is the least element of the admissible set. Uniqueness follows immediately from antisymmetry of the natural-number order, provided existence is known.

### Definition 2.5 (Repaired trajectory)

A sequence $a$ is a **globally pair-sum-avoiding greedy trajectory** if

$$
a_0=1
$$

and, for every $n\ge 0$, the value $a_{n+1}$ is the greedy successor after time $n$.

The adjective “chronological” will distinguish the relation enforced by this recurrence from an unordered relation on the value set.

### Definition 2.6 (Chronological additive triple)

For a cutoff $N$, a triple $(i,j,k)$ with $0\le i,j,k<N$ is a **chronological additive triple** if

$$
i<k,\qquad j<k,\qquad a_i+a_j=a_k.
$$

No condition between $i$ and $j$ is imposed, and $i=j$ is allowed. The collection of such triples may be viewed as the edge set of a directed $3$-uniform hypergraph on the time indices $0,\ldots,N-1$.

Chronology is essential to the formulation: when $a_k$ was chosen, precisely the values with lower indices were available. The recurrence therefore directly excludes sums whose two summands precede their target.

## 3. Existence of the greedy successor

The central well-posedness argument is a uniform bound on the entire obstruction set.

### Lemma 3.1 (The explicit escape candidate)

Let $a_0,\ldots,a_n$ be a finite history satisfying

$$
a_i\le a_n\qquad\text{for every }0\le i\le n.
$$

Then $2a_n+1$ is admissible after time $n$.

**Proof.** First, $a_n<2a_n+1$. Now suppose for contradiction that $2a_n+1\in P_n(a)$. By Lemma 2.2, there are $i,j\le n$ such that

$$
a_i+a_j=2a_n+1.
$$

The hypothesis gives $a_i\le a_n$ and $a_j\le a_n$, so

$$
a_i+a_j\le 2a_n,
$$

contradicting the displayed equality. Hence $2a_n+1\notin P_n(a)$, and the candidate is admissible. $\square$

The lemma does not require strict growth; nondecreasing domination by the final term is enough. This makes it applicable to arbitrary finite histories satisfying the stated order property, independently of how they were generated.

### Theorem 3.2 (Existence and boundedness of a greedy successor)

For every finite history $a_0,\ldots,a_n$ with $a_i\le a_n$ for all $i\le n$, there exists a greedy successor $z$, and it obeys

$$
z\le 2a_n+1.
$$

**Proof sketch.** Lemma 3.1 shows that the admissible set is nonempty because it contains $2a_n+1$. The well-ordering principle for the natural numbers gives a least admissible element $z$. By definition, this $z$ is the greedy successor. Since $2a_n+1$ is itself admissible and $z$ is least, $z\le 2a_n+1$. $\square$

### Corollary 3.3 (Indefinite continuation)

Starting from any finite nondecreasing positive history and applying the greedy rule, the construction can always take another step. In particular, the initial condition $a_0=1$ determines a unique infinite trajectory.

**Proof sketch.** Theorem 3.2 supplies a successor. That successor is larger than the current value by admissibility, so the extended history is strictly larger at its new endpoint and remains nondecreasing. Induction supplies successors at every time. At each step the least admissible value is unique, so the entire trajectory is unique. $\square$

This corollary explains why the explicit witness is more than a convenient estimate. It certifies that the recursive object exists at all finite stages.

## 4. Structural theorems

### Theorem 4.1 (Strict monotonicity)

Every globally pair-sum-avoiding greedy trajectory is strictly increasing. Equivalently, if $i<j$, then $a_i<a_j$.

**Proof.** By admissibility of the successor,

$$
a_n<a_{n+1}
$$

for every $n$. Repeated application of transitivity gives $a_i<a_j$ whenever $i<j$. $\square$

Strict monotonicity has several immediate consequences. Every selected value is positive because $a_0=1$. No value is repeated. The first $N$ indices correspond to $N$ distinct integer values. Most importantly for the existence argument, every earlier term satisfies $a_i\le a_n$ at time $n$.

### Theorem 4.2 (Chronological additive avoidance)

Let $a$ be a globally pair-sum-avoiding greedy trajectory. For all indices $i,j,k$ with $i<k$ and $j<k$,

$$
a_i+a_j\ne a_k.
$$

Repeated summands are included: the conclusion remains valid when $i=j$.

**Proof.** The case $k=0$ is impossible because no natural index is less than $0$. Otherwise write $k=n+1$. The inequalities $i<k$ and $j<k$ imply $i,j\le n$, so $a_i+a_j\in P_n(a)$ by Lemma 2.2. But $a_{n+1}=a_k$ was chosen to lie outside $P_n(a)$. Therefore $a_i+a_j\ne a_k$. $\square$

The result is stronger than excluding consecutive recurrences such as $a_{n-1}+a_n=a_{n+1}$. It simultaneously excludes every pair from the entire prior history.

### Theorem 4.3 (Uniform one-step growth ceiling)

Every globally pair-sum-avoiding greedy trajectory satisfies

$$
a_{n+1}\le 2a_n+1
$$

for every $n\ge 0$.

**Proof.** By Theorem 4.1, $a_i\le a_n$ for all $i\le n$. Lemma 3.1 therefore makes $2a_n+1$ admissible after time $n$. Since $a_{n+1}$ is the least admissible integer, it cannot exceed this candidate. $\square$

Iterating this estimate yields a coarse global exponential ceiling.

### Corollary 4.4 (Iterated upper bound)

For the trajectory beginning at $a_0=1$,

$$
a_n\le 2^{n+1}-1
$$

for every $n\ge 0$.

**Proof sketch.** The assertion holds at $n=0$ because $a_0=1=2^1-1$. If $a_n\le 2^{n+1}-1$, then Theorem 4.3 gives

$$
a_{n+1}\le 2a_n+1\le 2(2^{n+1}-1)+1=2^{n+2}-1.
$$

Induction completes the proof. $\square$

This exponential estimate is intentionally conservative. Numerical evidence suggests linear growth for the initial value $1$, but the one-step theorem alone does not establish that sharper behavior.

### Theorem 4.5 (Empty chronological additive hypergraph)

For every globally pair-sum-avoiding greedy trajectory and every cutoff $N$, the chronological additive hypergraph on vertices $0,\ldots,N-1$ has no edges.

**Proof.** If an edge $(i,j,k)$ existed, its definition would give $i<k$, $j<k$, and $a_i+a_j=a_k$. This contradicts Theorem 4.2. Hence the edge set is empty. $\square$

### Corollary 4.6 (Vanishing finite edge density)

For every cutoff $N$, the number of chronological additive triples is $0$. Consequently, any normalized edge density formed by dividing this count by a positive number of possible triples is also $0$.

The hypergraph language does not add a new arithmetic hypothesis. Its value is translational: additive structure becomes a forbidden-configuration statement, making tools and questions from extremal combinatorics available.

## 5. Incompatibility with a triangular displayed sequence

Consider the sequence $b$ defined by

$$
b_n=1+\frac{n(n-1)}2.
$$

Its initial values are

$$
1,1,2,4,7,11,\ldots.
$$

The quadratic term has leading coefficient $1/2$. This observation already conflicts with any proposed asymptotic coefficient $1/4$ attached to the same displayed formula, but the more immediate issue is incompatibility with global pair-sum avoidance.

### Theorem 5.1 (Failure of the displayed triangular sequence)

The sequence $b_n=1+n(n-1)/2$ is not a globally pair-sum-avoiding greedy trajectory.

**Proof.** A trajectory must be strictly increasing by Theorem 4.1, whereas

$$
b_0=b_1=1.
$$

Thus the trajectory condition already fails at the first step. Independently, the next displayed value satisfies

$$
b_2=2=b_0+b_1,
$$

so it is a sum of two earlier values. This contradicts Theorem 4.2. $\square$

The theorem should be read as a specification test. It does not claim that triangular numbers lack interest. It says that the displayed prefix and the repaired global rule define different mathematical objects. A revised recurrence intended to reproduce the displayed prefix must change at least one of the following: the strict-growth requirement, the scope of forbidden pair sums, or the permission to use repeated values and repeated summand indices.

## 6. Algorithms and numerical demonstrations

### 6.1 Direct greedy generation

A transparent algorithm stores the current history. At each stage it forms all pair sums, scans upward from one more than the last value, and chooses the first integer absent from the sumset.

**Algorithm 1: Direct global pair-sum-avoiding generation**

1. Initialize the list with $[1]$.
2. While fewer than $N$ terms have been generated:
   1. form $P=\{x+y:x,y\text{ are current terms}\}$;
   2. set $z$ to one more than the final term;
   3. while $z\in P$, replace $z$ by $z+1$;
   4. append $z$.
3. Return the list.

If there are $m$ current terms, forming the set from scratch uses $O(m^2)$ additions and at most $O(m^2)$ stored sums. The escape bound implies that scanning terminates. Rebuilding at every stage gives $O(N^3)$ arithmetic operations in the simplest implementation, although practical set membership is expected $O(1)$ per query.

### 6.2 Incremental sumset maintenance

A more efficient version maintains the pair-sum set. When a new value $z$ is appended, the only newly possible sums are $z+x$ for existing values $x$, including $z+z$. Updating therefore costs $O(m)$ set insertions at stage $m$, leading to $O(N^2)$ insertions and $O(N^2)$ space through $N$ terms.

The candidate scan is bounded in each step by Theorem 4.3. Its exact aggregate cost depends on the gaps and the density of the stored sumset. For the observed trajectory from $1$, only one forbidden even candidate is skipped at each stage.

### 6.3 Prefix certification

Given a finite list $x_0,\ldots,x_{N-1}$, a certificate checker tests:

1. $x_0=1$;
2. $x_{n+1}>x_n$ for each $n$;
3. $x_{n+1}$ is absent from the pair-sum set of $x_0,\ldots,x_n$;
4. every integer $w$ with $x_n<w<x_{n+1}$ belongs to that pair-sum set.

Conditions 2 and 3 prove admissibility; condition 4 proves minimality. A naive checker costs $O(N^3)$ if it rebuilds each pair-sum set, and an incremental checker reduces sumset construction to $O(N^2)$ insertions.

### 6.4 Hypergraph enumeration

To expose violations in arbitrary data, enumerate triples $(i,j,k)$ with $i,j<k<N$ and retain those satisfying $x_i+x_j=x_k$. There are

$$
\sum_{k=0}^{N-1}k^2=\frac{(N-1)N(2N-1)}6
$$

ordered chronological index triples, so direct enumeration takes $\Theta(N^3)$ time. For a valid repaired trajectory the output must be empty.

### 6.5 Numerical evidence and its status

Direct generation from $1$ begins

$$
1,3,5,7,9,11,13,15,17,19,\ldots.
$$

This supports the conjecture

$$
a_n=2n+1.
$$

The mechanism is visible. If all selected terms are odd, all pair sums are even. The immediate candidate $a_n+1$ is even and equals $1+a_n$, hence is forbidden. The next candidate $a_n+2$ is odd and therefore cannot be a sum of two earlier odd values. It is consequently the least admissible successor. This is a promising induction, but the exact classification is separated from the theorems established above: the proved general structure requires neither a parity invariant nor a closed form.

The triangular list fails the checker immediately. Its second value does not exceed its first, and its third value is a prior pair sum. The contrast between the two examples demonstrates why numerical prefixes should be tested against every clause of a recurrence before asymptotic behavior is inferred.

## 7. Applications and conceptual bridges

### 7.1 Additive combinatorics

The set $P_n(a)$ is a restricted historical sumset. Classical additive combinatorics asks how large sumsets are and how additive structure constrains a set. Here the direction is reversed: the evolving sumset constrains the next selected point. The sequence and its obstruction set coevolve.

The construction is not a Sidon condition. A Sidon set controls repeated representations of pair sums, whereas the present rule controls whether a selected value can itself be a prior pair sum. Nor should “globally sum-free” be used without qualification: the proved property is chronological. Precision about the ordering of indices prevents importing stronger claims than the recurrence supplies.

### 7.2 Greedy algorithms

The escape candidate gives a feasibility certificate. This is analogous to greedy scheduling problems in which one first proves that some feasible job or time slot remains before selecting the earliest feasible choice. Minimality then turns any explicit feasible witness into an upper bound on the selected output.

This proof pattern is reusable:

1. bound all obstructions using an invariant;
2. exhibit a candidate just beyond the obstruction bound;
3. invoke well-ordering to obtain the least candidate;
4. compare the greedy choice with the witness.

### 7.3 Hypergraph extremality

Encoding additive equations as hyperedges permits quantitative perturbations. The exact recurrence yields zero edges. If one relaxes the choice rule, exact emptiness may disappear, but edge density may remain small. This suggests a stability program: determine how far a sequence may deviate from exact greediness before a positive density of additive triples becomes unavoidable.

### 7.4 Residue-class dynamics

The observed odd trajectory suggests that residue classes can stabilize the construction. Pair sums of odd values occupy the even class modulo $2$, leaving odd candidates free. More generally, if selected values eventually occupy a set of residues whose pairwise sums avoid part of the residue space, the greedy motion may settle into an arithmetic progression. Finite cyclic groups therefore offer a compact model for possible long-term behavior.

### 7.5 Specification design

The prefix incompatibility theorem has relevance beyond this sequence. Recursive mathematics should distinguish:

- whether candidates must be unused;
- whether they must exceed the previous term;
- whether all prior pairs or only selected pairs are forbidden;
- whether repeated summand indices are allowed;
- whether complements and densities are taken in the positive integers, in a moving interval, or relative to a sumset.

Different answers produce different sequences. Asymptotic analysis should begin only after these choices are fixed and checked against any displayed data.

## 8. Discussion, limitations, and future work

The established theory is deliberately foundational. It proves that the repaired rule is coherent and derives consequences that follow directly from its global exclusion structure. It does not yet classify the trajectory exactly, establish an asymptotic density, or analyze all initial values.

The one-step ceiling is uniform but coarse. Iteration gives an exponential upper bound, while experiments from $1$ suggest linear growth. Closing that gap requires exploiting more than monotonicity—most naturally, parity. For other initial values, richer modular patterns may arise.

A further distinction concerns the word “complement.” The complement of the selected value set in the positive integers is a fixed infinite set once the trajectory is known. By contrast, the complement of $P_n(a)$ is a time-dependent admissible landscape. Their densities need not agree and may not even be posed in the same limiting variable. Any density theorem must specify its ambient universe.

The following directions arise naturally.

### 8.1 Exact classification from one

**Conjecture.** The globally additive-avoiding greedy trajectory beginning at one is exactly the odd sequence:

$$
a_n=2n+1.
$$

All sums of two earlier odd values are even, while the immediately preceding even candidate is forbidden as the sum of the initial one and the current value. The existence and growth-ceiling results isolate the local admissibility argument needed for an induction.

### 8.2 Stability under changing the initial value

**Conjecture.** For every positive initial value, the globally additive-avoiding greedy trajectory is eventually an arithmetic progression, with common difference determined by the additive semigroup generated by an initial segment.

The explicit successor bound confines each choice to a short moving interval, making stabilization of residue classes a concrete mechanism.

### 8.3 Higher-order additive avoidance

**Conjecture.** If candidates avoid all sums of exactly $r$ prior terms, with repetition allowed, then the greedy trajectory from one is eventually periodic modulo $r$ and has linear growth.

An $r$-fold sum of values in one stable residue class occupies one residue class, potentially leaving a neighboring class permanently admissible.

### 8.4 Hypergraph sparsity under bounded perturbations

**Conjecture.** Any increasing integer sequence whose successor differs from the globally greedy admissible choice by a uniformly bounded amount has a chronological additive hypergraph with zero upper edge density.

The exact rule gives an empty hypergraph and hence the extremal endpoint for a quantitative stability theory.

### 8.5 Counting-function dichotomy

**Conjecture.** A globally pair-sum-avoiding greedy sequence has either positive asymptotic density or a counting function bounded above by a constant multiple of the square root of the ambient cutoff, according to whether its stabilized residue support is sum-free in a finite cyclic group.

This would connect positive-density arithmetic progressions with Sidon-like sparse growth through finite cyclic structure.

## 9. Conclusion

The globally pair-sum-avoiding greedy rule is simple to state once its quantifiers are made explicit: begin at $1$, move strictly forward, exclude every sum of two values already seen, and take the least remaining integer. Every finite nondecreasing history has an admissible successor because $2a_n+1$ lies beyond all prior pair sums. Consequently the greedy trajectory exists indefinitely, is strictly increasing, satisfies $a_{n+1}\le 2a_n+1$, and contains no chronological additive triples. Its finite additive hypergraphs are therefore empty.

The triangular list $1,1,2,4,7,\ldots$ cannot satisfy this rule. That negative result is as informative as the positive structure: it separates an attractive displayed pattern from the recurrence it was meant to illustrate. With the specification repaired, exact classification, modular stabilization, higher-order avoidance, and perturbative hypergraph sparsity become well-posed research problems.
