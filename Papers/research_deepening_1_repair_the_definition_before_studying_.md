# A Complete Classification of the Repaired Anti-Fibonacci Greedy Process

## Abstract

We study a greedy integer sequence defined by a *global additive avoidance* rule: starting from $a_0 = 1$, each successive term is chosen to be the least value that strictly exceeds the current term and that cannot be written as a sum of two earlier terms. This rule is a repair of a degenerate literal formulation of an "anti-Fibonacci" process, whose original statement excluded a single integer and collapsed to the constant sequence. We prove that the repaired process is completely rigid: it admits exactly one trajectory, namely the positive odd integers $a_n = 2n+1$. From this exact law we derive a suite of structural consequences — a constant first difference of two, strict monotonicity, oddness of every term, an exact identification of the value set with the set of all odd natural numbers, and exact prefix cardinalities. The central mechanism is that sums of odd numbers are even, so the odd numbers form a set that is sum-free under the induced dynamics; the unique even near-miss above each term is precisely blocked by the sum of the seed and the current term. The result upgrades a previously known exponential one-step ceiling to an exact linear law and provides a case study in the principle that a definition must be repaired to well-posedness before its asymptotics are studied.

**Keywords:** greedy sequences, anti-Fibonacci, sum-free sets, additive combinatorics, sumset avoidance, rigidity, odd numbers, uniqueness classification.

---

## 1. Introduction

Sequences of integers defined by greedy avoidance conditions occupy a rich corner of additive combinatorics. The prototype is the Fibonacci recurrence, in which each term is the *sum* of its two predecessors. Reversing the spirit of that construction leads to a family of "anti-Fibonacci" rules in which each term is required to *avoid* being expressible as a sum drawn from the sequence's own history. Such sum-avoiding constructions are close cousins of sum-free sets and Sidon sets, and they inherit the same fundamental tension: the interplay between a set and its own sumset.

A recurring hazard with these definitions is degeneracy. A rule may be stated with apparent precision and yet fail to define the intended object — for instance by excluding the wrong quantity, or by permitting a trivial escape that collapses the sequence to a constant. The direction motivating the present work is exactly this: **repair the definition before studying asymptotics.** A literal earlier rule excluded a single integer at each stage and, lacking a strict-growth requirement, admitted the constant-one sequence $1, 1, 1, \dots$ as a fixed point. Analyzing the "growth" of such a sequence is meaningless.

We adopt a repaired rule with two features. First, each new term must *strictly exceed* the current term, guaranteeing genuine progress. Second, the forbidden set is *global additive*: the term must avoid every value expressible as a sum $a_i + a_j$ of two earlier terms (indices allowed to coincide). Under this repair we establish complete rigidity.

**Main Theorem (Rigidity).** A sequence $a \colon \mathbb{N} \to \mathbb{N}$ satisfies the repaired rule if and only if $a_n = 2n+1$ for all $n$. In particular the rule has a unique trajectory, the positive odd integers $1, 3, 5, 7, \dots$.

The rest of the paper makes the rule precise (Section 2), proves the classification (Section 3), derives structural corollaries (Section 4), presents algorithms and numerical illustrations (Section 5), discusses significance (Section 6), and lists open extensions (Section 7).

---

## 2. Definitions

Throughout, $a \colon \mathbb{N} \to \mathbb{N}$ denotes a candidate sequence of natural numbers, and $n \in \mathbb{N}$ is a stage index.

**Definition 2.1 (Prior pair sums).** For a sequence $a$ and a bound $n$, the *prior pair-sum set* is
$$P_n(a) \;=\; \{\, a_i + a_j \;:\; 0 \le i < n,\ 0 \le j < n \,\}.$$
It collects every value obtainable as the sum of two terms whose indices lie strictly below $n$ (the two indices may coincide, so it includes doublings $2a_i$).

The membership criterion we use throughout is the direct unpacking of this definition:
$$s \in P_n(a) \iff \exists\, i < n,\ \exists\, j < n,\ a_i + a_j = s.$$

**Definition 2.2 (Admissibility).** A value $z$ is *admissible after stage $n$* for the sequence $a$ if it strictly exceeds the current term and avoids all pair sums formed from the first $n+1$ terms:
$$\operatorname{Adm}(a, n, z) \iff \bigl( a_n < z \bigr) \ \wedge \ \bigl( z \notin P_{n+1}(a) \bigr).$$
The bound $n+1$ means the forbidden sums are formed from the terms $a_0, \dots, a_n$ — the entire history including the current term.

**Definition 2.3 (Greedy successor).** A value $z$ is the *greedy successor after stage $n$* if it is admissible and no smaller admissible value exists:
$$\operatorname{Greedy}(a, n, z) \iff \operatorname{Adm}(a, n, z) \ \wedge \ \bigl(\forall w,\ \operatorname{Adm}(a, n, w) \Rightarrow z \le w \bigr).$$

**Definition 2.4 (Repaired rule).** A sequence $a$ *satisfies the repaired rule* if it starts at one and always takes the greedy successor:
$$\operatorname{Repaired}(a) \iff \bigl( a_0 = 1 \bigr) \ \wedge \ \bigl( \forall n,\ \operatorname{Greedy}(a, n, a_{n+1}) \bigr).$$

**Definition 2.5 (Canonical trajectory).** The *canonical trajectory* is the sequence of positive odd integers,
$$c_n = 2n + 1, \qquad c_0 = 1,\ c_1 = 3,\ c_2 = 5,\ \dots$$

The goal is to prove $\operatorname{Repaired}(a) \iff a = c$.

---

## 3. The Classification Theorem

We prove rigidity through a sequence of lemmas. The recurring theme is that the greedy rule depends only on a finite prefix of the sequence, and that the odd near-miss/even-block dichotomy forces the step size to be exactly two.

### 3.1 Locality of the rule

Because $P_n(a)$ and admissibility reference only finitely many terms, they are insensitive to the sequence beyond the relevant prefix.

**Lemma 3.1 (Sumset locality).** If $a_i = b_i$ for all $i < n$, then $P_n(a) = P_n(b)$.

*Proof.* Membership $s \in P_n(a)$ unfolds to the existence of $i, j < n$ with $a_i + a_j = s$. Substituting the equalities $a_i = b_i$ and $a_j = b_j$ (valid since $i, j < n$) yields the same witnesses for $b$, and conversely. $\qquad\blacksquare$

**Lemma 3.2 (Admissibility locality).** If $a_i = b_i$ for all $i \le n$, then $\operatorname{Adm}(a, n, z) \iff \operatorname{Adm}(b, n, z)$ for every $z$.

*Proof.* The first conjunct $a_n < z$ becomes $b_n < z$ using $a_n = b_n$. The second conjunct references $P_{n+1}$, which by Lemma 3.1 (applied with bound $n+1$, whose hypothesis is exactly $a_i = b_i$ for $i \le n$) is unchanged. $\qquad\blacksquare$

**Lemma 3.3 (Greedy locality).** If $a_i = b_i$ for all $i \le n$, then $\operatorname{Greedy}(a, n, z) \iff \operatorname{Greedy}(b, n, z)$.

*Proof.* Immediate from Lemma 3.2, since the greedy predicate is built from admissibility of $z$ and of all competitors $w$. $\qquad\blacksquare$

### 3.2 Uniqueness of the greedy successor

**Lemma 3.4 (Uniqueness).** If $\operatorname{Greedy}(a, n, x)$ and $\operatorname{Greedy}(a, n, y)$, then $x = y$.

*Proof.* Since $x$ is a least admissible value and $y$ is admissible, $x \le y$; symmetrically $y \le x$. Antisymmetry of $\le$ gives $x = y$. $\qquad\blacksquare$

This lemma is the engine of rigidity: at each stage, *if* a greedy successor exists it is unique, so any two sequences agreeing up to stage $n$ must agree at stage $n+1$.

### 3.3 The canonical trajectory obeys the rule

We now show the odd numbers satisfy the repaired rule. The essential arithmetic fact is that a sum $c_i + c_j = (2i+1) + (2j+1) = 2(i+j+1)$ is even.

**Lemma 3.5 (Odd successor is admissible).** For every $n$, $\operatorname{Adm}(c, n, c_{n+1})$.

*Proof.* First, $c_n = 2n+1 < 2n+3 = c_{n+1}$. Second, suppose for contradiction $c_{n+1} \in P_{n+1}(c)$, i.e. $2n+3 = c_i + c_j = (2i+1)+(2j+1)$ for some $i, j$. The right side is even while $2n+3$ is odd — impossible. $\qquad\blacksquare$

**Lemma 3.6 (Odd successor is least).** For every $n$, $\operatorname{Greedy}(c, n, c_{n+1})$.

*Proof.* Admissibility holds by Lemma 3.5. For minimality, let $w$ be any admissible value, so $c_n = 2n+1 < w$; we must show $2n+3 \le w$. Suppose instead $2n+1 < w < 2n+3$, forcing $w = 2n+2$. But $2n+2 = 1 + (2n+1) = c_0 + c_n$, which exhibits $w \in P_{n+1}(c)$ via the witnesses $i = 0$, $j = n$. This contradicts the admissibility of $w$. Hence $w \ge 2n+3 = c_{n+1}$. $\qquad\blacksquare$

The block on $2n+2$ is the crux: the unique integer strictly between consecutive odd terms is even, and it is pinned by the sum of the seed $c_0 = 1$ and the current term $c_n$. The seed polices its entire future.

**Proposition 3.7.** $\operatorname{Repaired}(c)$.

*Proof.* $c_0 = 1$ by definition, and $\operatorname{Greedy}(c, n, c_{n+1})$ for all $n$ by Lemma 3.6. $\qquad\blacksquare$

### 3.4 Rigidity

**Theorem 3.8 (Classification).** For every sequence $a$,
$$\operatorname{Repaired}(a) \iff a = c, \quad\text{i.e.}\quad a_n = 2n+1 \ \text{for all } n.$$

*Proof.* ($\Leftarrow$) is Proposition 3.7.

($\Rightarrow$) Assume $\operatorname{Repaired}(a)$; we prove $a_n = c_n$ by strong induction on $n$. For $n = 0$, $a_0 = 1 = c_0$. For $n+1$, the induction hypothesis gives $a_i = c_i$ for all $i \le n$. By Lemma 3.3 (greedy locality), $\operatorname{Greedy}(a, n, a_{n+1})$ transports to $\operatorname{Greedy}(c, n, a_{n+1})$. But $\operatorname{Greedy}(c, n, c_{n+1})$ holds by Lemma 3.6, so uniqueness (Lemma 3.4) yields $a_{n+1} = c_{n+1}$. $\qquad\blacksquare$

---

## 4. Structural Corollaries

All of the following follow immediately from Theorem 3.8, which identifies any repaired sequence with $a_n = 2n+1$.

**Corollary 4.1 (Exact value).** If $\operatorname{Repaired}(a)$ then $a_n = 2n+1$ for all $n$.

**Corollary 4.2 (Constant increment).** If $\operatorname{Repaired}(a)$ then $a_{n+1} = a_n + 2$ for all $n$. The sequence is an arithmetic progression with common difference two.

**Corollary 4.3 (Oddness).** If $\operatorname{Repaired}(a)$ then every $a_n$ is odd.

**Corollary 4.4 (Strict monotonicity).** If $\operatorname{Repaired}(a)$ then $a$ is strictly increasing.

*Proof.* Each step increases the value by $2 > 0$; a sequence whose successive differences are positive is strictly monotone. $\qquad\blacksquare$

**Corollary 4.5 (Value set).** If $\operatorname{Repaired}(a)$ then the set of values attained is exactly the set of odd natural numbers:
$$\{\, a_n : n \in \mathbb{N} \,\} = \{\, x \in \mathbb{N} : x \text{ odd} \,\}.$$

*Proof.* Each $a_n = 2n+1$ is odd, giving the inclusion "$\subseteq$". Conversely any odd $x = 2m+1$ equals $a_m$, giving "$\supseteq$". $\qquad\blacksquare$

**Corollary 4.6 (Exact prefix cardinality).** If $\operatorname{Repaired}(a)$ then the first $n$ terms are pairwise distinct; the image of the initial segment $\{0, 1, \dots, n-1\}$ has exactly $n$ elements.

*Proof.* Strict monotonicity (Corollary 4.4) makes $a$ injective, so it maps $n$ distinct indices to $n$ distinct values. $\qquad\blacksquare$

Corollary 4.5 is noteworthy for additive combinatorics: it exhibits the odd numbers as a set that is *sum-free under the induced dynamics*. No odd number is a sum of two odd numbers, so the trajectory never collides with its own forbidden sumset — the avoidance condition is satisfied not marginally but with room to spare, since the entire forbidden set lives in the even numbers.

Corollary 4.2 sharpens what was previously known. Earlier analysis provided only a one-step *ceiling* on the next term — a bound that in the worst case grew exponentially and left the true behavior undetermined. The classification collapses that uncertainty to an exact linear law $a_n = 2n+1$.

---

## 5. Algorithms and Numerical Illustration

Although the answer is a closed form, it is instructive to *simulate the greedy rule directly* and observe that it reproduces the odd numbers, and to verify the sum-free property empirically.

### 5.1 Direct greedy simulation

The naive simulation maintains the running sequence, computes the forbidden pair-sum set from the current history, and scans upward from the current value $+1$ for the first admissible candidate.

```
Algorithm GREEDY-ANTI-FIBONACCI(N):
  a <- [1]
  forbidden <- {2}           # 1 + 1
  for step in 1 .. N-1:
    z <- a[-1] + 1
    while z in forbidden:
      z <- z + 1
    for x in a:              # extend forbidden set with new pair sums
      forbidden.add(x + z)
    forbidden.add(z + z)
    a.append(z)
  return a
```

Running this produces $1, 3, 5, 7, 9, \dots$, matching $2n+1$ exactly — a computational confirmation of Theorem 3.8.

The dominant cost is maintaining and querying the forbidden set. Over $N$ steps the set accrues $O(N^2)$ sums, so a hash-set implementation runs in $O(N^2)$ expected time and space.

### 5.2 Closed-form evaluation

Once the classification is proved, the closed form supersedes simulation:
$$a_n = 2n + 1, \qquad a_{n+1} - a_n = 2.$$
This evaluates any term in $O(1)$ time.

### 5.3 Empirical checks

- **Increment check:** every consecutive difference equals $2$.
- **Sum-free check:** for the first $N$ terms, no term equals a sum of two (not-necessarily-distinct) earlier terms — indeed every pair sum is even and every term is odd.
- **Value-set check:** the set of the first $N$ terms equals $\{1, 3, \dots, 2N-1\}$, the first $N$ odd numbers.
- **Prefix cardinality:** the first $N$ terms contain exactly $N$ distinct values.

The accompanying demonstration code performs all of these checks and prints a side-by-side comparison of the simulated sequence and the closed form.

---

## 6. Discussion

**A repair, not merely an analysis.** The methodological point is that the literal predecessor rule was ill-posed: without a strict-growth clause it admitted the constant sequence, and with only a single excluded integer it lacked the additive strength to constrain the trajectory. The repair introduces two coupled requirements — strict increase and global additive avoidance — and the classification shows they are *exactly* calibrated. Drop strict increase and the sequence can stall; weaken the avoidance to a single excluded value and multiple trajectories reappear. Together they carve out a one-dimensional solution set: a single sequence.

**The role of the seed.** A subtle feature is that the seed $a_0 = 1$ does double duty. It initializes the sequence, and it also supplies, at every stage $n$, the specific sum $1 + a_n = a_n + 1$ that blocks the even integer immediately above the current term. Without the seed contributing this block, the greedy rule might select the even near-miss and the odd structure would break. The classification thus depends delicately on the interaction between the initial value and the global additive condition.

**Greedy yet globally optimal.** Greedy algorithms are notorious for being locally optimal but globally suboptimal. Here the greedy rule is globally *perfect*: it produces a sequence that is simultaneously the densest sum-free progression it could be (hitting every odd number) and perfectly non-colliding (distinct prefix values). The myopic rule and the global structure coincide.

**Rigidity as a strong form of well-posedness.** Uniqueness is stronger than mere existence and well-definedness. The classification says the repaired rule is not only well-posed but *rigid*: the solution set is a single point. This is the ideal endpoint of a repair program — one starts with a degenerate definition and ends with a fully determined object.

---

## 7. Future Directions

The repaired repeated-summand rule is now completely classified: its unique trajectory is $a_n = 2n+1$. The development also establishes strict monotonicity, identifies the range with all odd natural numbers, and gives the exact cardinality of every finite prefix. The main remaining extensions are:

1. **Distinct-summand repair.** Replace repeated-index pair sums by sums from *distinct* earlier indices. Determine the resulting greedy trajectory and classify its growth.
2. **Higher-order forbidden sums.** Forbid sums of exactly $r$ earlier values (with or without repetition). Establish existence, uniqueness, and quantitative growth as a function of $r$.
3. **Alternative seeds.** Start from an arbitrary positive seed instead of one. Classify when the process becomes an arithmetic progression and when transient behavior persists.
4. **Finite-prefix sumset structure.** Prove exact descriptions and cardinalities for the restricted pair-sum sets of the canonical trajectory.
5. **Asymptotic density.** Upgrade the exact range classification to a filter-based proof that the value set has natural density $1/2$.
6. **Stability under weakened greediness.** Study trajectories that select any admissible value within a fixed additive error of the least one, and bound their lower and upper densities.

---

## 8. Conclusion

A greedy rule that avoids all sums of its own history, once repaired to strict growth and global additive avoidance, admits a unique trajectory: the positive odd integers $a_n = 2n+1$. The proof rests on a single arithmetic observation — odd plus odd is even — amplified by the observation that the seed blocks the lone even near-miss above each term. From the exact law flow strict monotonicity, oddness, the identification of the value set with all odd numbers, and exact prefix cardinalities. The example is a compact illustration of how repairing an ill-posed definition can turn an exponential worst-case fear into an exact, fully rigid linear law, and of how greedy dynamics can produce globally optimal sum-avoiding structure.
