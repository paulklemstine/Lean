# The Greedy Anti-Fibonacci Sequence: A Sum-Avoiding Rule and Its Exact Structure

## Abstract

The Fibonacci recurrence $F(n+1) = F(n) + F(n-1)$ binds consecutive terms together by addition and drives the ratio of consecutive terms to the golden ratio $\varphi = (1+\sqrt5)/2$. We study its natural antagonist: the **greedy anti-Fibonacci sequence**, obtained by starting at $1$ and repeatedly appending the smallest positive integer not yet used that is *not* the sum of two consecutive earlier terms. We prove that this self-avoiding construction has a strikingly simple closed form: its $k$-th term (0-indexed) is $A(k) = \lfloor(3k+2)/2\rfloor$, and its value set is exactly the positive integers not divisible by $3$. The avoided values — the consecutive sums — are exactly the positive multiples of $3$. From a single identity, $A(k)+A(k+1) = 3(k+1)$, we derive the sequence's full structure: a characterization of its terms, the anti-Fibonacci avoidance property, greedy minimality, and the true asymptotics. The sequence grows *linearly* with $A(n)/n \to 3/2$ (term density $2/3$); its consecutive ratio converges to $1$, not to any oscillating limit; and its avoided set has density $1/3$. In particular the sequence "avoids the golden ratio" in the strongest possible sense: the very ratio that tends to $\varphi$ for Fibonacci tends to $1$ here. We also correct a common misattribution: the frequently quoted quadratic list $1,1,2,4,7,11,16,\dots$ consists of the lazy-caterer numbers $1+\binom{n}{2}$, which do *not* satisfy the sum-avoidance property and are a genuinely different object.

**Keywords:** anti-Fibonacci sequence, greedy construction, sum-free sequence, arithmetic progression, natural density, golden ratio, lazy-caterer numbers.

---

## 1. Introduction

The Fibonacci sequence is the canonical example of a linear recurrence whose consecutive-term ratio converges to an algebraic constant. Adding the two most recent terms compounds like repeated multiplication by a fixed factor, and that factor is the golden ratio $\varphi$. This paper investigates the opposite design principle. Rather than *forming* each term as a sum of predecessors, we *forbid* each term from being such a sum, and take the greedy (least admissible) choice at every step.

**The greedy rule.** Set $A(0) = 1$. Having produced $A(0), \dots, A(n)$, let $A(n+1)$ be the smallest positive integer that (i) has not yet appeared and (ii) is not equal to any consecutive sum $A(i) + A(i+1)$ with $i+1 \le n$. This is a well-defined deterministic construction.

Simulating it yields
$$1,\ 2,\ 4,\ 5,\ 7,\ 8,\ 10,\ 11,\ 13,\ 14,\ 16,\ 17,\ \dots,$$
i.e. every positive integer not divisible by $3$, while the avoided consecutive sums are exactly
$$3,\ 6,\ 9,\ 12,\ 15,\ \dots,$$
the positive multiples of $3$.

**Contributions.** We prove that the greedy sequence coincides with an explicit arithmetic object, and we extract its complete structure and asymptotics:

1. A closed form $A(k) = \lfloor(3k+2)/2\rfloor$ and the structural identity $A(k)+A(k+1) = 3(k+1)$ (Section 3).
2. A characterization: $m$ is a term iff $m \ge 1$ and $3 \nmid m$ (Theorem 4.1).
3. The avoidance property: no term equals a consecutive sum (Theorem 4.2).
4. Greedy minimality: every integer strictly between consecutive terms is a multiple of $3$, hence was skipped precisely because it is a consecutive sum (Theorem 4.3).
5. Asymptotics: $A(n)/n \to 3/2$ (linear growth, term density $2/3$); the consecutive ratio $A(n+1)/A(n) \to 1$; the avoided set has density $1/3$ (Section 5).
6. A correction of folklore: the commonly cited quadratic list is the lazy-caterer sequence, which is *not* sum-avoiding (Section 6).

**A note on the naive conjecture.** A frequently repeated informal claim asserts that the anti-Fibonacci sequence begins $1,1,2,4,7,11,16,\dots$, grows like $n^2/4$, has a consecutive ratio that oscillates between $1$ and $2$ without converging, and possesses an avoided set of density $0$. Every one of these quantitative claims is false for the honest greedy rule: growth is linear, the ratio converges to $1$, and the avoided set has density $1/3$. We explain the source of the confusion in Section 6.

---

## 2. Definitions and conventions

Throughout, $\mathbb{N} = \{0, 1, 2, \dots\}$ and division is understood on the integers with $\lfloor \cdot \rfloor$ made explicit.

**Definition 2.1 (Anti-Fibonacci sequence).** For $k \in \mathbb{N}$ define
$$A(k) := \left\lfloor \frac{3k+2}{2} \right\rfloor.$$
Equivalently, splitting on the parity of $k$,
$$A(2m) = 3m + 1, \qquad A(2m+1) = 3m + 2.$$

The first values are $A(0)=1,\ A(1)=2,\ A(2)=4,\ A(3)=5,\ A(4)=7,\ A(5)=8,\ \dots$

**Definition 2.2 (Consecutive sum / avoided set).** The *consecutive sums* of the sequence are the numbers $S(k) := A(k) + A(k+1)$ for $k \in \mathbb{N}$. The *avoided set* is $\mathcal{S} := \{ S(k) : k \in \mathbb{N} \}$.

**Definition 2.3 (Natural density).** A set $T \subseteq \mathbb{Z}_{\ge 1}$ has natural density $d$ if
$$\lim_{N\to\infty} \frac{\#\{ t \in T : t \le N \}}{N} = d.$$

The two parity formulas in Definition 2.1 are the engine of every proof below: each claim reduces, after a parity split on the index, to elementary linear arithmetic.

---

## 3. The structural identity

**Lemma 3.1 (Positivity).** For all $k$, $A(k) \ge 1$.

*Proof.* $3k+2 \ge 2$, so $\lfloor(3k+2)/2\rfloor \ge 1$. $\square$

**Lemma 3.2 (Strict monotonicity).** $A$ is strictly increasing; moreover $A(k+1) - A(k) \in \{1, 2\}$.

*Proof.* By the parity formulas, consecutive differences are $A(2m+1)-A(2m) = 1$ and $A(2m+2)-A(2m+1) = 1$; more directly, $A(k+1) - A(k) = \lfloor(3k+5)/2\rfloor - \lfloor(3k+2)/2\rfloor \in \{1,2\}$, and is always positive. $\square$

**Theorem 3.3 (Structural identity).** For all $k \in \mathbb{N}$,
$$A(k) + A(k+1) = 3(k+1).$$

*Proof.* Split on the parity of $k$. If $k = 2m$, then $A(2m) + A(2m+1) = (3m+1) + (3m+2) = 6m + 3 = 3(2m+1) = 3(k+1)$. If $k = 2m+1$, then $A(2m+1) + A(2m+2) = (3m+2) + (3m+4) = 6m+6 = 3(2m+2) = 3(k+1)$. $\square$

**Corollary 3.4 (Terms avoid multiples of 3).** For all $k$, $3 \nmid A(k)$.

*Proof.* From the parity formulas, $A(2m) = 3m+1 \equiv 1 \pmod 3$ and $A(2m+1) = 3m+2 \equiv 2 \pmod 3$. In both cases $A(k) \not\equiv 0 \pmod 3$. $\square$

These two facts — consecutive sums are multiples of $3$, individual terms never are — already contain the whole story. Everything that follows is bookkeeping around them.

---

## 4. The three characterizing theorems

To justify that the closed form $A$ *is* the greedy construction, and not a mere lookalike, we verify the three properties that pin the greedy sequence down uniquely.

**Theorem 4.1 (Characterization of terms).** A positive integer $m$ is a term of the sequence — i.e. $m = A(k)$ for some $k$ — if and only if $3 \nmid m$.

*Proof.* ($\Rightarrow$) If $m = A(k)$ then $m \ge 1$ by Lemma 3.1 and $3\nmid m$ by Corollary 3.4.

($\Leftarrow$) Suppose $m \ge 1$ and $3 \nmid m$. Write $m = 3q + r$ with $r \in \{1, 2\}$. If $r = 1$, take $k = 2q$; then $A(k) = 3q+1 = m$. If $r = 2$, take $k = 2q+1$; then $A(k) = 3q+2 = m$. In closed form, $k = 2\lfloor m/3\rfloor + (m \bmod 3) - 1$ works in both cases. $\square$

Thus the value set of the sequence is exactly $\{ m \ge 1 : 3 \nmid m \} = \{1,2,4,5,7,8,\dots\}$: nothing is missing and nothing is extra.

**Theorem 4.2 (Avoidance — the anti-Fibonacci property).** No term of the sequence equals a consecutive sum. That is, for all $k, i \in \mathbb{N}$,
$$A(k) \ne A(i) + A(i+1).$$

*Proof.* By Theorem 3.3, $A(i)+A(i+1) = 3(i+1)$ is a multiple of $3$. By Corollary 3.4, $A(k)$ is not. Hence they cannot be equal. Equivalently, the term set (non-multiples of $3$) and the avoided set (multiples of $3$) are disjoint. $\square$

**Theorem 4.3 (Greedy minimality).** For all $n$, every integer $m$ with $A(n) < m < A(n+1)$ satisfies $3 \mid m$.

*Proof.* By Lemma 3.2 the gap $A(n+1) - A(n)$ is $1$ or $2$, so there is at most one such $m$, and it exists precisely when the gap is $2$. From the parity formulas, the gap equals $2$ exactly when $n$ is odd, say $n = 2t+1$: then $A(n) = 3t+2$ and $A(n+1) = A(2t+2) = 3t+4$, and the unique interior integer is $m = 3t+3 = 3(t+1)$, a multiple of $3$. When $n$ is even the gap is $1$ and there is no interior integer, vacuously satisfying the claim. $\square$

**Interpretation (uniqueness of the greedy sequence).** Read together, Theorems 4.1–4.3 show that $A$ is *the* greedy sequence. Suppose $B$ is any sequence produced by the greedy rule of Section 1. By induction: the base value is $1 = A(0)$. Given that $B$ agrees with $A$ up to index $n$, the next greedy choice $B(n+1)$ is the least integer exceeding $B(n) = A(n)$ that is not a consecutive sum. By Theorem 4.3, all integers strictly between $A(n)$ and $A(n+1)$ are multiples of $3$ (hence consecutive sums, by Theorem 3.3 and Theorem 5.3 below), so they are forbidden; and $A(n+1)$ itself is admissible by Theorem 4.2. Hence $B(n+1) = A(n+1)$. The closed form is therefore a theorem about the greedy construction, not a redefinition of it.

---

## 5. Asymptotics and density

**Lemma 5.1 (Two-sided linear bounds).** For all $k$,
$$3k + 1 \le 2\,A(k) \le 3k + 2.$$

*Proof.* From $A(k) = \lfloor(3k+2)/2\rfloor$: if $k$ is even, $2A(k) = 3k+2$; if $k$ is odd, $2A(k) = 3k+1$. Both lie in $[3k+1, 3k+2]$. $\square$

**Theorem 5.2 (Linear growth).** $\displaystyle \lim_{n\to\infty} \frac{A(n)}{n} = \frac{3}{2}.$

*Proof.* Dividing Lemma 5.1 by $2n$ gives, for $n \ge 1$,
$$\frac{3}{2} + \frac{1}{2n} \le \frac{A(n)}{n} \le \frac{3}{2} + \frac{1}{n}.$$
Both bounds tend to $3/2$ as $n \to \infty$, so by the squeeze theorem $A(n)/n \to 3/2$. $\square$

Because $A$ enumerates the non-multiples of $3$ in increasing order, this is the analytic shadow of a density statement: among the first $N$ positive integers, $\lfloor 2N/3\rfloor$ are non-multiples of $3$, so the *term set* has density $2/3$.

**Theorem 5.3 (The avoided set is the multiples of 3).** A positive integer $m$ is a consecutive sum — i.e. $m = A(k) + A(k+1)$ for some $k$ — if and only if $m = 3j$ for some integer $j \ge 1$. Consequently the avoided set $\mathcal{S}$ has natural density $1/3$.

*Proof.* ($\Rightarrow$) By Theorem 3.3, $m = A(k)+A(k+1) = 3(k+1)$ with $k+1 \ge 1$. ($\Leftarrow$) Given $m = 3j$ with $j \ge 1$, take $k = j-1$; then $A(k)+A(k+1) = 3(k+1) = 3j = m$. Thus $\mathcal{S} = \{3, 6, 9, \dots\}$, which has density $1/3$. $\square$

**Theorem 5.4 (Consecutive ratio converges to 1).** $\displaystyle \lim_{n\to\infty} \frac{A(n+1)}{A(n)} = 1.$

*Proof.* By Lemma 3.2, $0 \le A(n+1) - A(n) \le 2$, so
$$1 \le \frac{A(n+1)}{A(n)} = 1 + \frac{A(n+1)-A(n)}{A(n)} \le 1 + \frac{2}{A(n)}.$$
By Lemma 5.1, $A(n) \to \infty$, so $2/A(n) \to 0$ and the ratio is squeezed to $1$. $\square$

**Corollary 5.5 (Avoidance of the golden ratio).** For the Fibonacci sequence $F$, $F(n+1)/F(n) \to \varphi = (1+\sqrt5)/2 \approx 1.618$. For the greedy anti-Fibonacci sequence, the same ratio tends to $1 \ne \varphi$. The anti-Fibonacci sequence therefore avoids the golden ratio: the invariant that detects $\varphi$ in Fibonacci returns the trivial value $1$ here.

This is the precise sense in which the sequence is "anti-Fibonacci." It is not that the ratio oscillates or diverges (it does neither); it is that linear growth collapses the ratio limit to the trivial value, while Fibonacci's exponential growth produces $\varphi$.

---

## 6. Correcting the folklore: lazy-caterer numbers

The informal statement of the problem lists the anti-Fibonacci sequence as $1, 1, 2, 4, 7, 11, 16, 22, \dots$ and conjectures quadratic $n^2/4$ growth. These numbers are real and important — but they are a different sequence.

**Definition 6.1 (Lazy-caterer numbers).** The lazy-caterer (central polygonal) numbers are $q(n) = 1 + \binom{n}{2} = \tfrac12(n^2 - n + 2)$, giving $1, 2, 4, 7, 11, 16, 22, 29, \dots$. Combinatorially, $q(n)$ is the maximum number of regions into which $n$ straight cuts can divide a disk.

Two observations separate this object from the greedy anti-Fibonacci sequence.

**(a) Different growth.** $q(n) \sim n^2/2$ (and matching the shifted "$1,1,2,4,7,\dots$" indexing gives the $n^2/4$ heuristic), which is quadratic. The greedy sequence grows linearly (Theorem 5.2). They cannot be the same sequence.

**(b) Lazy-caterer numbers are not sum-avoiding.** The defining feature of the anti-Fibonacci sequence is that no term is a sum of two consecutive terms. The lazy-caterer numbers fail this. Indeed, $q(n) = 1 + \binom{n}{2}$ satisfies the Fibonacci-type coincidence $q(n+1) = q(n) + q(n-1)$ at isolated indices: for instance $q(3) + q(4) = 4 + 7 = 11 = q(5)$, so $11$ *is* a consecutive sum yet also a term. A genuine anti-Fibonacci sequence can contain no such coincidence.

The confusion arises from conflating two different "avoid the sum" readings. If one greedily lists integers avoiding consecutive sums, the answer is forced to be the non-multiples of $3$. The quadratic list is instead a natural but distinct object that happens to superficially resemble a Fibonacci variant.

**Remark 6.2 (Sum-coincidences).** The identity $q(n+1) = q(n) + q(n-1)$ substitutes to $\tfrac12((n+1)^2-(n+1)) = \tfrac12((n^2-n)+(n-1)^2-(n-1)) + \tfrac12$, a single quadratic in $n$ whose integer roots are controlled by a discriminant. This is why the lazy-caterer sequence exhibits exactly a bounded number of such coincidences — a phenomenon we flag as a direction for further study.

---

## 7. Algorithms

We record the two natural algorithms: the naive greedy simulation (used to discover the pattern) and the constant-time closed form (used to compute far into the sequence).

**Algorithm A (Greedy simulation).** Maintain the list of produced terms and the set of forbidden consecutive sums. At each step scan upward from the last term $+1$ for the first integer neither already used nor forbidden; append it; record its new consecutive sum. Producing $n$ terms costs $O(n)$ arithmetic operations amortized, since each candidate integer is examined a bounded number of times.

**Algorithm B (Closed form).** $A(k) = \lfloor(3k+2)/2\rfloor$ in $O(1)$ time per term. Correctness is Theorem 4.1 together with the uniqueness argument after Theorem 4.3. This lets one compute, say, $A(10^6) = 1{,}500{,}001$ instantly and verify $A(n)/n \to 3/2$ numerically to any range.

---

## 8. Applications and discussion

The greedy anti-Fibonacci sequence is a clean case study in how a *design principle* determines *growth*. Three points stand out.

1. **Avoidance yields structure.** A rule phrased entirely negatively ("never be a consecutive sum") produces a maximally structured object: an exact union of arithmetic progressions. This mirrors a broader theme in combinatorics, where greedy sum-free or sum-avoiding constructions frequently collapse to periodic residue patterns.

2. **Growth controls the ratio limit.** Fibonacci's exponential growth is what manufactures $\varphi$. Strip out the compounding — as sum-avoidance does — and only linear growth remains, forcing the consecutive ratio to $1$. The pair (Fibonacci, anti-Fibonacci) forms a sharp contrast: exponential/irrational-ratio versus linear/trivial-ratio.

3. **The value of formal correction.** The episode is a reminder that a plausible informal conjecture (quadratic growth, oscillating ratio, sparse avoided set) can be entirely wrong, and that a careful reading of the *actual* greedy rule yields a completely different, and completely determined, answer.

---

## 9. Future directions

**Density of greedy sequences avoiding sums of $k$ consecutive terms.** Generalize the rule to forbid sums of any $k$ consecutive earlier terms. For $k=2$ the outcome is the non-multiples of $3$, an exact union of arithmetic progressions of density $2/3$. Conjecture: for every $k$ the greedy sequence is eventually a finite union of arithmetic progressions, its avoided set is likewise structured, and its density is a rational number depending only on $k$. The mechanism is that admissibility of the next term depends only on a bounded sliding window of recent terms, so the construction is driven by a finite-state automaton whose recurrent structure forces eventual periodicity and rational density.

**Which reals are consecutive-ratio limits of additive greedy sequences?** Fibonacci's ratio converges to the quadratic irrational $\varphi$; the anti-Fibonacci ratio converges to $1$. Conjecture: any additively defined greedy avoidance sequence that grows polynomially has consecutive-ratio limit exactly $1$, so quadratic irrationals (and badly approximable numbers generally) can only arise from genuinely multiplicative, exponential recurrences. The intuition: polynomial growth makes consecutive gaps negligible relative to the terms, squeezing the ratio to $1$, whereas a nontrivial limit demands geometric growth.

**Sum-coincidences of quadratic sequences.** The lazy-caterer numbers $1 + \binom{n}{2}$ satisfy the Fibonacci-type identity $q(n+1) = q(n) + q(n-1)$ at exactly two indices. Conjecture: every integer quadratic $q(n) = an^2 + bn + c$ admits at most two such coincidences, with the exact count decided by the discriminant of an associated quadratic; the same should hold with a fixed lag $m$ in place of $1$. Substituting the closed form turns the recurrence into a single quadratic equation in $n$, so integer solutions are controlled entirely by a discriminant condition.

---

## 10. Conclusion

The greedy anti-Fibonacci sequence — start at $1$, always take the smallest positive integer that is not a sum of two consecutive earlier terms — is exactly the arithmetic progression of positive non-multiples of $3$, with closed form $A(k) = \lfloor(3k+2)/2\rfloor$. Its consecutive sums are precisely the positive multiples of $3$, so it can never collide with one of its own sums. It grows linearly ($A(n)/n \to 3/2$, term density $2/3$), its avoided set has density $1/3$, and its consecutive ratio converges to $1$. It thereby avoids the golden ratio decisively: the invariant that yields $\varphi$ for Fibonacci yields the trivial value $1$ here. The often-quoted quadratic list is the lazy-caterer sequence, a distinct and non-sum-avoiding object. The lesson is compact and durable: the golden ratio is a reward for exponential growth, and a sequence that merely avoids addition can only grow in a straight line.
