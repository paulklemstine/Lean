# Three Small Engines of Mathematical Certainty

Mathematics often advances through grand ideas, but much of its daily work is powered by modest, repeatable moves. An expression is simplified according to a familiar algebra. A whole number is tested for primality. An eigenvalue is bounded without being computed. Each task looks different, yet all three share a useful design principle: replace an open-ended search with a short procedure whose every step has a clear mathematical justification.

This article develops three such procedures. The first works in **min-plus arithmetic**, the geometry behind shortest paths and tropical mathematics. The second decides primality by exhaustive trial division. The third controls real eigenvalues through absolute row sums. Their common theme is not clever guessing but *local evidence*: a small list of identities, a finite divisor search, or one carefully chosen coordinate of an eigenvector.

## When minimum becomes addition

In ordinary arithmetic, addition and multiplication are basic operations. Min-plus arithmetic changes the roles. For real numbers $a$ and $b$, define tropical addition and multiplication by

$$
a\oplus b=\min(a,b),\qquad a\otimes b=a+b.
$$

The notation is exotic, but the operations are familiar. This arithmetic appears naturally whenever alternatives compete by cost and sequential stages add costs. If one route costs $a$ and another costs $b$, choosing the better route costs $a\oplus b$. If a journey of cost $a$ is followed by one of cost $b$, the total is $a\otimes b$.

The central simplification rule is distributivity.

**Tropical Distributivity Theorem.** For all real $a,b,c$,

$$
a\otimes(b\oplus c)=(a\otimes b)\oplus(a\otimes c)
$$

and

$$
(a\oplus b)\otimes c=(a\otimes c)\oplus(b\otimes c).
$$

To see the first identity, expand the definitions:

$$
a+\min(b,c)=\min(a+b,a+c).
$$

Adding the same number preserves order, so whichever of $b$ and $c$ is smaller remains smaller after adding $a$. The second identity follows similarly, or by commutativity of ordinary addition. Tropical addition is also idempotent:

$$
a\oplus a=a.
$$

These facts form a small rewrite basis. One repeatedly expands a common tropical factor, removes repeated minima, and uses associativity to regroup. For example, distributing over three alternatives gives the following complete statement.

**Three-Way Distribution Theorem.** For all real $a,b,c,d$,

$$
a\otimes((b\oplus c)\oplus d)
=(a\otimes b)\oplus((a\otimes c)\oplus(a\otimes d)).
$$

The proof applies two-term distributivity twice and then reassociates the minimum. A useful absorption identity follows as well.

**Tropical Absorption Theorem.** For all real $a,b$,

$$
(a\otimes b)\oplus\bigl(a\otimes(b\oplus b)\bigr)=a\otimes b.
$$

Indeed, $b\oplus b=b$, so both terms under the outer minimum are identical.

This tiny algebra has a practical interpretation. Imagine a fixed entrance fee $a$ followed by a choice among three routes of costs $b,c,d$. It does not matter whether one first chooses the cheapest route and then adds the entrance fee, or computes all three complete costs and then takes their minimum. The theorem says that these two planning strategies agree exactly.

## Turning primality into a finite witness search

A prime number is an integer $n\ge 2$ whose only positive divisors are $1$ and $n$. Equivalently, no integer $d$ with $2\le d<n$ divides $n$. This equivalence immediately suggests an algorithm.

Define a **proper-divisor search** for $n$ to inspect each integer $d$ in the range $2\le d<n$ and report success when $d\mid n$. Define the **trial-primality test** to report prime precisely when $n\ge2$ and the proper-divisor search reports no divisor.

The key point is that the computation and the definition coincide.

**Divisor-Search Characterization.** The proper-divisor search for $n$ succeeds if and only if there exists an integer $d$ such that $2\le d<n$ and $d\mid n$.

The proof is a direct reading of the finite search. If the search succeeds, the successful entry supplies $d$. Conversely, any such $d$ occurs in the inspected range and makes the search succeed.

**Trial-Primality Correctness Theorem.** For every natural number $n$, the trial-primality test reports prime if and only if $n$ is prime.

For the forward direction, the test ensures $n\ge2$ and rules out every proper divisor, which is exactly primality. For the reverse direction, a prime $n$ is at least $2$ and cannot have a divisor between $2$ and $n-1$, so the divisor search must fail and the test reports prime.

Two examples show both sides. The number $97$ is prime because none of $2,3,\ldots,96$ divides it. The number $91$ is not prime because

$$
91=7\cdot13.
$$

These certificates are logically different. A composite number can be settled by one witness, such as $7$. A prime number requires the exhaustion of the entire prescribed search range. The elementary algorithm takes $O(n)$ divisibility tests in its stated form. It is not intended to compete with modern primality testing; its virtue is transparency. There is no probabilistic guess and no unexplained shortcut.

There is also a small logical consequence worth stating. Since $97$ is prime while $91$ is not, the two numbers cannot be equal: equality would transfer the primality property from one to the other and create a contradiction.

## Hearing eigenvalues through row sums

The third procedure enters linear algebra. Let $A=(A_{ij})$ be a real $n\times n$ matrix. A real number $\lambda$ is a real eigenvalue of $A$ if there is a nonzero vector $v$ such that

$$
Av=\lambda v.
$$

Eigenvalues govern repeated dynamics, stability, vibration, network diffusion, and many iterative computations. Computing them exactly may be expensive or symbolically impossible. Yet a simple inspection of the matrix can fence them in.

For each row $i$, define its absolute row sum by

$$
r_i=\sum_{j=1}^{n}|A_{ij}|.
$$

The decisive observation is that every nonzero finite vector has a coordinate of maximal absolute value.

**Maximal-Coordinate Lemma.** If $v\ne0$, then some index $i_0$ satisfies

$$
|v_{i_0}|>0
\quad\text{and}\quad
|v_j|\le |v_{i_0}|\ \text{for every }j.
$$

Finiteness guarantees a maximum. It must be positive, since otherwise every coordinate would vanish and $v$ would be zero.

Now inspect the $i_0$-th coordinate of the eigenvalue equation:

$$
\lambda v_{i_0}=\sum_{j=1}^{n}A_{i_0j}v_j.
$$

Taking absolute values and applying the triangle inequality gives

$$
|\lambda|\,|v_{i_0}|
\le \sum_{j=1}^{n}|A_{i_0j}|\,|v_j|.
$$

Maximality of $|v_{i_0}|$ bounds the right-hand side by

$$
\left(\sum_{j=1}^{n}|A_{i_0j}|\right)|v_{i_0}|.
$$

Because $|v_{i_0}|>0$, it can be cancelled. This proves the central estimate.

**Absolute Row-Sum Eigenvalue Theorem.** If $Av=\lambda v$ for a nonzero real vector $v$, then there is a row $i$ such that

$$
|\lambda|\le \sum_{j=1}^{n}|A_{ij}|.
$$

Consequently, if every absolute row sum is at most $B$, then every real eigenvalue satisfies

$$
|\lambda|\le B,
$$

or equivalently,

$$
-B\le\lambda\le B.
$$

This is a remarkably cheap certificate. Computing all row sums costs $O(n^2)$ arithmetic operations for a dense matrix, while a full eigenvalue computation is typically more involved. The estimate may be conservative, but it is immediate, robust, and easy to audit.

Consider

$$
A=\begin{pmatrix}2&-1\\1&3\end{pmatrix}.
$$

Its absolute row sums are $3$ and $4$, so every real eigenvalue lies in $[-4,4]$. In this case the eigenvalues are not even real: they are complex conjugates. The real theorem therefore makes no nontrivial eigenvalue claim for this particular matrix, a reminder that hypotheses matter. For the symmetric matrix

$$
S=\begin{pmatrix}2&-1\\-1&2\end{pmatrix},
$$

all eigenvalues are real, the row sums are both $3$, and the eigenvalues $1$ and $3$ sit exactly inside the predicted interval.

## One design pattern, three mathematical worlds

The three procedures look unrelated on the surface. Tropical simplification manipulates expressions; primality testing searches finite lists; spectral estimation applies inequalities. Yet each has the same architecture.

First, identify a mathematical interface whose meaning is unambiguous. In min-plus arithmetic it is the pair $\min$ and $+$. In number theory it is the existence of a proper divisor. In spectral analysis it is the eigenvalue equation together with absolute row sums.

Second, isolate a small soundness theorem. Distribution preserves the value of a tropical expression. Exhaustive search agrees with the definition of primality. The maximal-coordinate argument turns an eigenvector equation into a row-sum bound.

Third, let routine calculation carry the remaining load. Rewriting expands nested choices. A finite loop checks divisibility. Summing absolute values produces a spectral certificate.

This pattern matters wherever decisions must be explainable. A route planner can expose the min-plus identity behind its simplification. A number-theory lesson can show exactly why a reported prime passed. A stability analysis can display the row sums that confine possible growth factors. The result is not merely an answer, but an answer accompanied by a compact mathematical reason.

The limits are equally instructive. Local tropical rewriting does not yet produce unique normal forms for every min-plus polynomial. Exhaustive trial division scales poorly. Absolute row sums ignore cancellation and can overestimate the spectrum. But these limitations point naturally toward stronger methods: canonical tropical forms, square-root trial division and richer certificates, and Gershgorin discs or weighted matrix norms.

Small engines are valuable because they can be understood end to end. Their reliability comes not from mystery, but from the fact that each computational move is the visible shadow of a theorem.

There is a broader lesson here about trustworthy computation. A useful calculation should admit two readings: an operational reading that says what to do, and a mathematical reading that says why the result follows. The tropical rules are simultaneously an expression transformer and a statement about ordered addition. Trial division is simultaneously a loop and a quantified claim about divisors. The row-sum estimate is simultaneously a quick matrix scan and a consequence of the triangle inequality. When those two readings align, even a very small procedure can carry substantial explanatory force. It becomes reusable precisely because its assumptions, conclusion, and failure modes remain in plain view.
