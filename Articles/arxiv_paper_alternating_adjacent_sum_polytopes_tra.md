# Counting Paths with a Two-Beat Rhythm

## How alternating local rules become a global recurrence

Many counting problems look difficult for the same reason: every new choice depends on the choice immediately before it. A password policy may restrict neighboring symbols. A communication protocol may forbid certain successive states. A lattice model may allow two heights to sit together only when their sum stays below a threshold. Local dependence seems to force us to remember an entire history.

The transfer-matrix method offers a way out. It replaces memory of the past by a finite state, and it replaces a long chain of choices by a power of a matrix. For a particularly transparent family of adjacent-sum constraints, there is an additional twist: the threshold alternates between two values. The rule has a two-beat rhythm—strict, relaxed, strict, relaxed—and the correct unit of time is therefore not one step but a pair of steps.

That pairing produces the central object of this article: a period matrix. In the two-state case, one elementary algebraic identity forces open chains and two different kinds of closed cycles to satisfy exactly the same second-order recurrence. Their initial values differ, but their long-term dynamics share one quadratic denominator.

## From neighboring coordinates to a matrix

Fix a finite state set $\{0,1,\ldots,d-1\}$. For a nonnegative integer bound $b$, declare states $i$ and $j$ compatible when

$$
i+j\le b.
$$

The corresponding adjacency matrix $A_b$ is the $d\times d$ matrix whose entry in row $i$ and column $j$ is

$$
(A_b)_{ij}=\begin{cases}1,&i+j\le b,\\0,&i+j>b.\end{cases}
$$

A product of entries records a chain of compatible transitions. Summing over intermediate states is precisely matrix multiplication. Consequently, if consecutive bounds alternate between $s$ and $s+1$, then two successive transitions are encoded by

$$
M=A_sA_{s+1}.
$$

Its entry $M_{ik}$ counts the possible intermediate states $j$ for a two-edge path from $i$ to $k$:

$$
M_{ik}=\sum_{j=0}^{d-1}\mathbf 1_{i+j\le s}\,\mathbf 1_{j+k\le s+1}.
$$

This is the Two-Step Path-Counting Theorem. It is simple, but it is the bridge between combinatorics and algebra. A problem about many inequalities has become a problem about powers of one fixed matrix.

The pattern resembles a turnstile with alternating settings. On the first beat, a pair may pass only under the stricter threshold $s$; on the second, the threshold becomes $s+1$. Looking only after every second beat makes the machine time-independent.

## Three ways to read a matrix power

A power $M^n$ represents $n$ complete periods, or $2n$ alternating transitions. There are several natural ways to turn this matrix into a number.

For an open chain, choose left and right boundary weights $u_i$ and $v_j$. The weighted count is

$$
C_n=\sum_{i,j}u_i(M^n)_{ij}v_j.
$$

Taking all weights equal to $1$ counts all possible endpoints; choosing indicator weights fixes one or both endpoints.

For a closed chain, the endpoint must return to the starting state. Summing diagonal entries gives the even cyclic count

$$
E_n=\operatorname{tr}(M^n).
$$

An odd cycle has one unpaired transition, represented by another matrix $A$. Its count is

$$
O_n=\operatorname{tr}(M^nA).
$$

Thus open boundaries, even cycles, and odd cycles are not unrelated constructions. They are three linear observations of the same evolving matrix power.

## Why two states imply a universal recurrence

Now specialize to two states. Write

$$
t=\operatorname{tr}(M),\qquad \delta=\det(M).
$$

Every $2\times2$ matrix satisfies its characteristic equation,

$$
M^2-tM+\delta I=0.
$$

This is the Cayley–Hamilton identity in dimension two. Multiplying it by $M^n$ yields the Matrix-Power Recurrence Theorem:

$$
M^{n+2}=tM^{n+1}-\delta M^n
$$

for every $n\ge0$.

Because the three counting operations above are linear in the matrix power, the same recurrence survives after applying any of them. Hence the Open-Chain Recurrence Theorem states

$$
C_{n+2}=tC_{n+1}-\delta C_n.
$$

The Even-Cycle Recurrence Theorem states

$$
E_{n+2}=tE_{n+1}-\delta E_n,
$$

and the Odd-Cycle Recurrence Theorem states

$$
O_{n+2}=tO_{n+1}-\delta O_n.
$$

This is the main structural result. Boundary conditions change the first two terms, but they cannot change the recurrence coefficients. The local alternating rule fixes $M$; its trace and determinant then govern every sequence derived linearly from its powers.

## One denominator, many numerators

A second-order recurrence immediately gives a rational generating function. If a sequence $x_n$ obeys

$$
x_{n+2}=tx_{n+1}-\delta x_n,
$$

then its ordinary generating function $X(z)=\sum_{n\ge0}x_nz^n$ is

$$
X(z)=\frac{x_0+(x_1-tx_0)z}{1-tz+\delta z^2}.
$$

Therefore the open, even-cyclic, and odd-cyclic series all have the common denominator

$$
1-tz+\delta z^2.
$$

Their numerators remember how the chain begins and ends. Their denominator remembers how one complete period propagates information. This distinction is useful far beyond this example: transient features live in initial data, while persistent growth lives in the characteristic polynomial.

If the roots of $r^2-tr+\delta=0$ are $\lambda_+$ and $\lambda_-$, then each sequence is a linear combination of $\lambda_+^n$ and $\lambda_-^n$, except in the repeated-root case, where a factor of $n$ may appear. Under the usual nonnegative irreducibility conditions, the larger positive root controls exponential growth. The shared denominator therefore predicts a shared growth scale for all three boundary models, although special initial data can cancel a mode.

## Closing a chain without choosing a starting beat

Alternation creates an apparent ambiguity. Should a complete period be $AB$ or $BA$? For an open chain the choice can affect endpoints, but for a positive-length cycle it does not affect the trace. The Cyclic Rotation Invariance Theorem says that for all $n\ge0$,

$$
\operatorname{tr}((AB)^{n+1})=\operatorname{tr}((BA)^{n+1}).
$$

The reason is the cyclic property of trace: $\operatorname{tr}(XY)=\operatorname{tr}(YX)$. One can rotate the first transfer step around the closed loop until it reaches the end. A cycle has no privileged starting edge, and the algebra respects that geometric fact.

## A small numerical example

Take two states, $0$ and $1$, and alternating bounds $s=1$ and $s+1=2$. Then

$$
A_1=\begin{pmatrix}1&1\\1&0\end{pmatrix},\qquad
A_2=\begin{pmatrix}1&1\\1&1\end{pmatrix},
$$

so

$$
M=A_1A_2=\begin{pmatrix}2&2\\1&1\end{pmatrix}.
$$

Here $t=3$ and $\delta=0$. Every count therefore satisfies

$$
x_{n+2}=3x_{n+1}.
$$

With all open boundary weights equal to $1$, the first values are $C_0=2$ and $C_1=6$, followed by $18,54,162,\ldots$. The value $C_0=2$ counts the two zero-edge paths, one at each state; a zero-edge path must have the same initial and final state. The even cyclic values begin $E_0=2$, $E_1=3$, then $9,27,81,\ldots$. If the extra odd step is $A_1$, then $O_0=1$, $O_1=5$, then $15,45,135,\ldots$. Different beginnings, same multiplier after the recurrence settles in.

This toy example also shows why one should not confuse the common denominator with identical sequences. Open chains and closed cycles count different objects. What they share is the spectral engine underneath.

## Why this matters

Transfer matrices appear whenever a global configuration is assembled from local compatibility rules. In coding and cryptographic design, finite-state constraints can model admissible symbol streams, constrained keys, or protocol states. In statistical mechanics, they describe one-dimensional spin systems. In enumerative geometry, they count lattice points subject to neighboring inequalities. In automata theory, they count accepted words of a given length.

The period-pairing idea is especially valuable for nonuniform systems. A rule that changes at every step seems time-dependent; grouping a full period converts it into an ordinary stationary evolution. Once that is done, low matrix dimension creates strong algebraic compression. For two states, an arbitrarily long chain is controlled by only two scalars, $t$ and $\delta$, plus two initial values for each observable.

There are also practical computational consequences. Directly enumerating all two-state strings of length $2n$ inspects exponentially many candidates. Matrix powering computes counts in $O(\log n)$ matrix multiplications by repeated squaring. Since the matrices are only $2\times2$, the arithmetic structure is tiny even when the answer itself has thousands of digits. Alternatively, once $t$, $\delta$, $x_0$, and $x_1$ are known, the scalar recurrence generates the first $N$ values in $O(N)$ arithmetic operations and constant working memory.

## A compact language for local constraints

There is a broader conceptual payoff in separating the transition rule from the boundary rule. The matrices $A_s$ and $A_{s+1}$ describe what is locally legal; the vectors $u$ and $v$, or the trace operation, describe how a legal path is observed. One may therefore change permitted starting states, assign endpoint rewards, or close the chain without rebuilding the dynamical core. This modularity is valuable in applications where the same local policy is tested under several threat models or usage scenarios.

The determinant also has an intuitive role. The trace measures the total tendency of states to persist through one period, while the determinant measures how the two independent directions of state information expand, contract, or collapse. In the numerical example the determinant is zero, so one direction disappears after a period and the recurrence effectively becomes first order. When the determinant is nonzero, both characteristic modes can contribute. Thus two familiar matrix invariants encode the complete temporal law of every scalar count considered here.

## The larger horizon

The two-state theory isolates a robust mechanism rather than the entire adjacent-sum polytope problem. For a larger threshold, the natural state space may have $s+2$ states. Cayley–Hamilton still gives a recurrence, but its order can rise with the matrix dimension. A complete geometric treatment must also identify lattice points with paths, derive the associated formal power series, and analyze dominant poles carefully. More refined formulas—such as Möbius recurrences, arctangent expressions, and derivative identities for cyclic numerators—require additional structure beyond the universal two-state argument.

Yet the essential lesson is already visible. Local inequalities become zero-one matrices. Periodic variation becomes one period matrix. Open and closed boundary conditions become linear observations. Cayley–Hamilton turns matrix evolution into recurrence. The recurrence turns into a rational generating function. And the poles of that function reveal growth.

A chain governed by alternating rules may look as if it changes character at every step. Viewed at the right tempo, however, it follows one steady beat.
