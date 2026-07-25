# Greedy Avoidance of Distinct-Index Pair Sums: Exact Classification, Range, and Algorithms

**Aristotle**  
**July 25, 2026**

## Abstract

We study an increasing greedy sequence that begins at $1$ and, at each stage, selects the least larger natural number that is not representable as the sum of values at two distinct earlier indices. Distinctness changes the behavior substantially: the opening values are $1,2,4$, after which the sequence is an arithmetic progression of common difference $3$. We prove the exact formula

$$
a_0=1,\qquad a_1=2,\qquad a_n=3n-2\quad(n\ge2),
$$

establish uniqueness among all trajectories satisfying the rule, derive the stable increment identity $a_{n+3}=a_{n+2}+3$, and classify the range as

$$
\{2\}\cup\{3k+1:k\ge0\}.
$$

The proof separates into a local minimality certificate and a global admissibility certificate. The initial terms $1$ and $2$ forbid the two candidates immediately above each stable term, while reduction modulo $3$ proves that the next candidate cannot be a distinct-index pair sum. We also present exact prefix counts, a density consequence, direct and closed-form algorithms, numerical tests, and extensions to restricted sumsets, higher-order sums, alternative seeds, and approximate greediness.

## 1. Introduction

Greedy constructions in additive combinatorics often combine a simple local instruction with an expanding global constraint. At stage $n$, the legal status of a candidate may depend on every pair chosen during the preceding $n+1$ stages. Such dependence suggests increasing complexity: the forbidden set grows quadratically in the length of the known prefix, and a direct implementation repeatedly searches through it.

The process considered here is especially elementary to state. Start from $1$. Given the terms through index $n$, choose the least natural number strictly larger than the current term that is not the sum of values at two distinct earlier indices. The first terms are

$$
1,2,4,7,10,13,16,19,22,25,\ldots.
$$

The central issue is whether this pattern is genuine and forced. It is. After a short transient, every increment is $3$. More importantly, the proof explains *why* a rule involving an ever-growing sumset collapses to a fixed affine formula.

There are two mechanisms. Local minimality comes from the seeds: if $x$ is the current stable term, then $x+1=1+x$ and $x+2=2+x$ are forbidden. Global admissibility comes from a modular coloring: all terms other than the exceptional $2$ are congruent to $1$ modulo $3$, whereas a sum of two distinct earlier terms is congruent only to $0$ or $2$ modulo $3$. Therefore $x+3$, which is again congruent to $1$, is legal. These two certificates identify the least legal successor exactly.

Distinctness is essential at the boundary. At the stage with prefix $(1,2)$, the candidate $4$ is allowed because $4=2+2$ would reuse the same index. If repeated indices were permitted, the startup and subsequent trajectory would be different. Thus the small phrase “distinct earlier indices” is not cosmetic; it creates both the exceptional term and the modulus governing the stable regime.

The paper is organized as follows. Section 2 gives precise definitions. Section 3 analyzes the initial stages and modular invariant. Section 4 proves existence, uniqueness, and exact classification. Section 5 derives range, counting, and density consequences. Section 6 presents algorithms and complexity. Section 7 records computational examples and validation principles. Sections 8 and 9 discuss applications and future problems.

## 2. Definitions

Throughout, $\mathbb N=\{0,1,2,\ldots\}$. Let $a=(a_n)_{n\ge0}$ be a sequence in $\mathbb N$.

**Definition 2.1 (restricted prior pair-sum set).** For $n\ge0$, define

$$
\Sigma_n(a)=\{a_i+a_j:0\le i<j<n\}.
$$

Thus $\Sigma_n(a)$ uses the first $n$ indexed terms, and every sum uses two distinct indices. Equal values would be allowed if they occurred at different indices, but a single occurrence may not be reused.

**Definition 2.2 (admissibility after a stage).** Given the current stage $n$ and a candidate $z$, say that $z$ is admissible after stage $n$ if

$$
a_n<z\qquad\text{and}\qquad z\notin\Sigma_{n+1}(a).
$$

The first condition enforces strict increase; the second excludes all sums from two distinct positions in the available prefix $(a_0,\ldots,a_n)$.

**Definition 2.3 (greedy successor).** A natural number $z$ is the greedy successor at stage $n$ if it is admissible after stage $n$ and no smaller admissible number exists. Equivalently,

$$
z=\min\{w\in\mathbb N:a_n<w\text{ and }w\notin\Sigma_{n+1}(a)\}.
$$

**Definition 2.4 (distinct-summand greedy trajectory).** A sequence $a$ satisfies the distinct-summand rule if $a_0=1$ and $a_{n+1}$ is the greedy successor at every stage $n\ge0$.

The minimum in Definition 2.3 exists for every finite history: $\Sigma_{n+1}(a)$ is finite, while infinitely many natural numbers exceed $a_n$. The classification below gives a stronger conclusion for the specified initial seed: not only does each step exist, but the entire trajectory has a closed form.

We will compare the rule with the candidate sequence $c=(c_n)_{n\ge0}$ defined by

$$
c_0=1,\qquad c_1=2,\qquad c_{m+2}=3m+4\quad(m\ge0).
$$

Equivalently,

$$
c_n=
\begin{cases}
1,&n=0,\\
2,&n=1,\\
3n-2,&n\ge2.
\end{cases}
$$

Its values are $1,2,4,7,10,\ldots$.

## 3. Boundary behavior and the modular mechanism

### 3.1 The first two transitions

At stage $0$, there are no two distinct indices in the prefix $(1)$. Hence

$$
\Sigma_1(c)=\varnothing,
$$

and the least number larger than $1$ is $2$. Therefore $c_1=2$.

At stage $1$, the only pair of distinct indices is $(0,1)$, so

$$
\Sigma_2(c)=\{1+2\}=\{3\}.
$$

The least candidate above $2$ is $3$, which is forbidden, while $4$ is admissible. In particular, the representation $4=2+2$ is irrelevant because the value $2$ is available at only one index. Therefore $c_2=4$.

These checks explain the transient increments $1$ and $2$. From stage $2$ onward, both seeds can be paired with the current term, and the stable argument begins.

### 3.2 Residue structure

The candidate sequence has one exceptional value $2$. Every other term is congruent to $1$ modulo $3$:

$$
c_0=1\equiv1\pmod3,
$$

and for $n\ge2$,

$$
c_n=3n-2\equiv1\pmod3.
$$

This leads to the key exclusion lemma.

**Lemma 3.1 (residue exclusion for distinct pair sums).** Let $i<j$. Then $c_i+c_j$ is not congruent to $1$ modulo $3$. Consequently, no term $c_m$ with $m\ne1$ is representable as $c_i+c_j$ using two distinct earlier indices.

**Proof sketch.** If neither index is $1$, then both summands are congruent to $1$ modulo $3$, so their sum is congruent to $2$. If exactly one index is $1$, then one summand is $2$ and the other is congruent to $1$, so the sum is congruent to $0$. Both indices cannot equal $1$ because they are distinct. Thus residue $1$ never occurs among the permitted pair sums. Every candidate term other than $c_1=2$ has residue $1$, proving the claim. $\square$

The phrase “distinct pair” is used in the final case. Without distinctness, the exceptional value could be added to itself, producing $2+2=4\equiv1\pmod3$ and destroying the protected class at the first stable candidate.

### 3.3 Local obstruction of intervening candidates

**Lemma 3.2 (two-seed blocking).** For every $n\ge0$, after the current stable term $c_{n+2}=3n+4$, the two candidates $c_{n+2}+1$ and $c_{n+2}+2$ belong to the restricted prior pair-sum set.

**Proof sketch.** The current term has index $n+2$, distinct from the seed indices $0$ and $1$. Hence

$$
c_{n+2}+1=c_{n+2}+c_0
$$

is a permitted distinct-index pair sum, and

$$
c_{n+2}+2=c_{n+2}+c_1
$$

is another. Both candidates are therefore forbidden. $\square$

**Lemma 3.3 (stable admissibility).** For every $n\ge0$, the number $c_{n+3}=c_{n+2}+3$ is admissible after stage $n+2$.

**Proof sketch.** It is strictly larger than $c_{n+2}$. It is congruent to $1$ modulo $3$, while Lemma 3.1 shows that no distinct-index pair sum from the preceding prefix has that residue. $\square$

Combining Lemmas 3.2 and 3.3 gives exact minimality: there are only two natural numbers strictly between $c_{n+2}$ and $c_{n+3}$, both are forbidden, and $c_{n+3}$ is legal.

## 4. Exact classification and uniqueness

**Theorem 4.1 (canonical trajectory satisfies the greedy rule).** The sequence

$$
c_0=1,\qquad c_1=2,\qquad c_n=3n-2\quad(n\ge2)
$$

satisfies the distinct-summand greedy rule at every stage.

**Proof sketch.** The transitions $1\to2$ and $2\to4$ follow from the direct boundary calculations in Section 3.1. At every later stage, write the current term as $c_{n+2}$. Lemma 3.3 makes $c_{n+3}$ admissible. Lemma 3.2 forbids the only smaller candidates exceeding the current term. Therefore $c_{n+3}$ is the least admissible successor. $\square$

To show that this solution is the only one, we isolate two elementary facts about greedy constructions.

**Lemma 4.2 (finite-history invariance).** Suppose two sequences $a$ and $b$ agree at every index from $0$ through $n$. Then they have the same restricted pair-sum set through stage $n$, and a number $z$ is a greedy successor for $a$ at stage $n$ if and only if it is a greedy successor for $b$ at that stage.

**Proof sketch.** Every element of the restricted pair-sum set has the form $a_i+a_j$ with $0\le i<j\le n$. Replacing $a_i$ and $a_j$ by the equal values $b_i$ and $b_j$ preserves every such sum, in both directions. The current values $a_n$ and $b_n$ also agree, so both the admissibility condition and its minimum are identical. $\square$

**Lemma 4.3 (uniqueness of a greedy successor).** For a fixed finite history and stage, any two greedy successors are equal.

**Proof sketch.** If $x$ and $y$ are both least admissible values, the minimality of $x$ gives $x\le y$, and the minimality of $y$ gives $y\le x$. Hence $x=y$. $\square$

**Theorem 4.4 (complete classification).** A sequence $a=(a_n)_{n\ge0}$ satisfies the distinct-summand greedy rule if and only if

$$
a_0=1,\qquad a_1=2,\qquad a_n=3n-2\quad(n\ge2).
$$

**Proof sketch.** The reverse implication is Theorem 4.1. For the forward implication, use strong induction on $n$. The base value is fixed by the rule. Assume that $a_i=c_i$ for every $i\le n$. By finite-history invariance, $a_{n+1}$ is a greedy successor for the candidate history through stage $n$. Theorem 4.1 says that $c_{n+1}$ is also a greedy successor for that history. Lemma 4.3 gives $a_{n+1}=c_{n+1}$. Thus all indices agree. $\square$

The proof is extensional: it does not assume an arithmetic progression and then check compatibility. It derives equality at each index solely from the greedy property and the common finite history.

**Corollary 4.5 (eventual constant increment).** Every sequence satisfying the rule obeys

$$
a_{n+3}=a_{n+2}+3
$$

for every $n\ge0$.

**Proof sketch.** Substitute the formula from Theorem 4.4:

$$
a_{n+3}=3(n+3)-2=3n+7
$$

and

$$
a_{n+2}+3=(3(n+2)-2)+3=3n+7.
$$

$\square$

Strict monotonicity follows at once. The increments are $1$, $2$, and then $3$ forever.

## 5. Range, prefix counts, and density

**Theorem 5.1 (exact range).** For every trajectory satisfying the distinct-summand rule,

$$
\{a_n:n\ge0\}=\{2\}\cup\{3k+1:k\ge0\}.
$$

**Proof sketch.** The classification gives $a_0=1=3\cdot0+1$, $a_1=2$, and for $n\ge2$,

$$
a_n=3n-2=3(n-1)+1.
$$

Thus every attained value lies in the displayed set. Conversely, $2=a_1$, the case $k=0$ gives $1=a_0$, and for $k\ge1$,

$$
3k+1=a_{k+1}.
$$

Hence every value in the displayed set is attained. $\square$

There are two useful notions of finite prefix. The first counts sequence indices. Because strict increase makes all values distinct, the first $m$ terms contain exactly $m$ values. The second counts attained values below a numerical cutoff.

**Proposition 5.2 (count below a cutoff).** Let

$$
A(N)=\#\bigl(\{a_n:n\ge0\}\cap\{0,1,\ldots,N\}\bigr).
$$

Then $A(0)=0$, and for $N\ge1$,

$$
A(N)=\left\lfloor\frac{N-1}{3}\right\rfloor+1+\mathbf 1_{N\ge2},
$$

where $\mathbf 1_{N\ge2}$ is $1$ when $N\ge2$ and $0$ otherwise.

**Proof sketch.** The values of the form $3k+1$ not exceeding $N$ correspond exactly to integers $k$ satisfying

$$
0\le k\le\frac{N-1}{3}.
$$

There are $\lfloor(N-1)/3\rfloor+1$ such integers. The exceptional value $2$ contributes one additional point precisely when $N\ge2$. $\square$

An equivalent count on the half-open interval $\{0,1,\ldots,N-1\}$ is obtained by replacing $N$ with $N-1$.

**Corollary 5.3 (natural density).** The value set has natural density $1/3$:

$$
\lim_{N\to\infty}\frac{A(N)}{N+1}=\frac13.
$$

**Proof sketch.** The floor term differs from $(N-1)/3$ by less than $1$, and the exceptional contribution is bounded. Dividing by $N+1$ makes all bounded errors vanish, leaving $1/3$. $\square$

This density statement is a consequence of exact range rigidity, not a probabilistic heuristic. The isolated exceptional value affects finite counts but contributes zero to the limit.

## 6. Algorithms

### 6.1 Direct greedy generation

The definition suggests a general-purpose algorithm. Maintain the current list of values. At each stage, construct the set of all sums $a_i+a_j$ with $i<j$, then scan upward from $a_n+1$ until a number outside that set is found.

**Algorithm 6.1 (direct restricted-sumset generator).** Given a requested length $m$:

1. If $m=0$, return the empty list.
2. Initialize the list with $[1]$.
3. While the list has fewer than $m$ entries:
   1. Form the set of sums of values at all pairs of distinct indices.
   2. Set the candidate to one more than the current final value.
   3. Increase the candidate while it belongs to the forbidden set.
   4. Append the first candidate outside the set.
4. Return the list.

For a prefix of length $m$, rebuilding the pair-sum set at every stage uses $O(m^3)$ arithmetic operations in the straightforward implementation and $O(m^2)$ memory at the largest stage. An incremental implementation can add only sums involving the newest term, reducing total sum insertions to $O(m^2)$. The candidate scan is short for this classified sequence, but the direct algorithm does not assume that fact.

### 6.2 Closed-form generation

The classification yields a much faster specialized algorithm.

**Algorithm 6.2 (closed-form trajectory generator).** For each index $n$ from $0$ to $m-1$, output $1$ if $n=0$, output $2$ if $n=1$, and otherwise output $3n-2$.

This requires $O(m)$ time to materialize $m$ terms and $O(1)$ auxiliary space beyond the output. A single random-access query requires $O(1)$ time and space.

### 6.3 Membership and rank

The range theorem gives a constant-time membership test. A natural number $x$ is attained exactly when

$$
x=2\qquad\text{or}\qquad x\equiv1\pmod3.
$$

If membership holds, its index is also explicit:

$$
\operatorname{index}(x)=
\begin{cases}
1,&x=2,\\
0,&x=1,\\
(x+2)/3,&x\ge4\text{ and }x\equiv1\pmod3.
\end{cases}
$$

The quotient is integral in the final case. Both membership and index recovery take $O(1)$ arithmetic operations.

## 7. Numerical demonstrations

A transparent computational test should compare two independent descriptions: direct greedy generation and the closed form. For the first ten terms, both produce

$$
1,2,4,7,10,13,16,19,22,25.
$$

At each stable stage with current value $x$, a diagnostic can report three facts:

1. $x+1$ is forbidden because $x+1=x+1$ uses the current term and the initial value $1$;
2. $x+2$ is forbidden because $x+2=x+2$ uses the current term and the initial value $2$;
3. $x+3$ is absent from the entire distinct-index pair-sum set.

For example, after the prefix $(1,2,4,7)$, the distinct pair sums are

$$
3,5,6,8,9,11.
$$

The current term is $7$. Candidates $8=1+7$ and $9=2+7$ are forbidden, whereas $10$ is absent and is chosen. After appending $10$, the same pattern blocks $11$ and $12$ and admits $13$.

A residue histogram provides a second view. Up to any large cutoff, all stable sequence values occupy residue $1$ modulo $3$, with one exceptional point in residue $2$. Distinct pair sums among stable values occupy residue $2$, while sums involving the exceptional seed occupy residue $0$. No forbidden sum enters the protected residue-$1$ channel.

A third demonstration compares exact cutoff counts with empirical ratios. At $N=100$, the values $3k+1\le100$ number $34$, and the exceptional value $2$ gives $A(100)=35$. Thus

$$
\frac{A(100)}{101}=\frac{35}{101}\approx0.3465.
$$

At larger cutoffs the bounded exceptional contribution diminishes, and the ratio approaches $1/3$.

## 8. Interpretation and applications

The proof architecture is more reusable than the particular formula. A greedy avoidance problem can sometimes be solved by finding two certificates:

* a **local minimality certificate**, showing that all candidates between the current value and the proposed successor are forbidden; and
* a **global admissibility certificate**, showing that the proposed successor avoids every obstruction generated by the whole history.

Here the local certificate consists only of the seeds $1$ and $2$. The global certificate is a coloring by residues modulo $3$. This division of labor turns a growing sumset computation into a fixed argument.

In additive combinatorics, the attained set

$$
\{2\}\cup(1+3\mathbb N)
$$

has a restricted two-fold sumset whose residues avoid $1$. The exceptional point is simultaneously necessary for blocking nearby candidates and harmless to global admissibility because distinctness prevents its self-pairing.

In resource allocation, one may interpret values as ordered labels or time slots and pair sums as collision signatures generated by combining two prior resources. A protected congruence class supplies collision-free labels, while a small set of initial resources blocks wasteful nearby choices. The sequence shows how a modular design can make a greedy allocator predictable.

In coding and communication models, additive interference from two distinct previously used symbols may be treated as forbidden. Residue classes then act as coarse channels separating valid symbols from interference sums. The present model is idealized, but it clearly exhibits the mechanism.

The result also illustrates finite-state behavior. Although the formal rule remembers the entire prefix, its long-term decision can be certified using only the current term, two seeds, and a residue class. This suggests that other greedy sum-avoidance processes may admit compact automaton-like descriptions after a transient.

## 9. Discussion and future work

The exact trajectory resolves existence, uniqueness, stable growth, range, and density for the two-distinct-summand rule with seed $1$. Several questions remain.

First, one can determine the exact union-of-intervals structure of the restricted pair-sum set generated by the first $n$ terms. The affine parametrization reduces this to sums among a residue-class progression together with sums involving the exceptional value $2$, but overlaps and boundary defects require careful counting.

Second, for fixed $r\ge2$, one can greedily avoid sums of exactly $r$ earlier values at pairwise distinct indices. The pair case suggests searching for a finite seed certificate that blocks nearby candidates and a modular coloring that protects a successor class. It is not yet clear whether every $r$ yields eventual arithmetic progression or whether more complicated periodic patterns occur.

Third, the density argument can be developed in a general analytic form. The exact range immediately gives density $1/3$ by elementary counting. A reusable theorem translating eventual residue-class descriptions into limits of normalized counting functions would apply to broader families.

Fourth, replacing the seed $1$ by an arbitrary positive integer may produce phase transitions. Early exceptional values determine which local increments are blocked, while a stable modulus would have to protect a residue class from all available pair types. One may ask which seeds lead to eventual arithmetic progressions and how long the transient can last.

Finally, one can weaken greediness. If each successor may be any admissible value within a fixed additive error $E$ of the least admissible candidate, exact uniqueness disappears. Natural questions concern sharp upper and lower densities and whether every perturbed trajectory remains near a finite union of arithmetic progressions.

## 10. Conclusion

The distinct-index pair-sum avoidance rule has a unique and explicit trajectory:

$$
1,2,4,7,10,13,\ldots.
$$

Its initial irregularity lasts only two transitions, after which every step has size $3$. The stable candidate is protected globally by residue $1$ modulo $3$, while the two intervening candidates are blocked locally by addition with the seeds $1$ and $2$. This yields the complete formula, exact range, finite counts, and density $1/3$.

The principal conceptual lesson is that a history-dependent greedy rule can become rigid when local blockers and a modular invariant align. The entire past still defines the forbidden set, but a three-color argument makes that complexity transparent.
