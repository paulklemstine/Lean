# How Fast Must a Number System Grow Before Counting Becomes Free?

## A threshold hiding inside the humblest of ideas

Every schoolchild learns one number system and then forgets that it was a choice. In base ten, the digit positions carry the weights $1, 10, 100, 1000, \dots$, and the number of digits you need to write $n$ grows like $\log_{10} n$. In base two the weights are $1, 2, 4, 8, \dots$ and the digit count grows like $\log_2 n$. Change the base and you change the constant in front of the logarithm, but you never change the shape of the answer: writing down a number costs a logarithm.

Clocks and calendars already break the rule that the base has to stay fixed. Seconds come in sixties, minutes in sixties, hours in twenty-fours, days in sevens. Such a *mixed-radix* system has weights
$$V_0 = 1, \qquad V_1 = b_0, \qquad V_2 = b_0 b_1, \qquad V_3 = b_0 b_1 b_2, \ \dots$$
where $b_0, b_1, b_2, \dots$ is any sequence of bases you like. Nothing forces the bases to be small, and nothing forces them to be chosen in advance.

Here is the twist that makes the story interesting. Suppose the base at each level is not a fixed number but a *function of the weight already accumulated*. Physically, this is what a self-similar hierarchy of units looks like: each new stratum of a system is coarser than the last by an amount determined by how coarse the system has already become. Formally, fix a **radix schedule** $r$, a function from positive integers to positive integers, and define
$$V_0 = 1, \qquad V_{k+1} = r(V_k)\, V_k .$$
The $k$-th digit position carries weight $V_k$, and the base used at that position is $r(V_k)$: bigger weights beget bigger bases. If $r$ is the constant function $10$, we recover ordinary decimal. If $r(x) = 2^x$, we get something violent: the weights are $1, 2, 8, 2048, \dots$, and the next one already has $617$ digits.

The natural question is: **how many digits does $n$ need?** Define the **radix height**
$$K_r(n) = \min\{ k : n < V_k \},$$
the least number of positions whose weights suffice to exhaust $n$. For decimal, $K(n) \approx \log_{10} n$. For a schedule that grows, $K_r(n)$ grows more slowly. The question is *how* much more slowly, and the answer turns out to be a sharp threshold with a beautiful invariant sitting exactly on it.

## The slowest function you will ever meet

To say what the answer is, we need the iterated logarithm — the function computer scientists write $\log^* n$ and describe, only half-jokingly, as "the number of times you have to take the logarithm of $n$ before the result drops to $1$ or below." Precisely,
$$\log^* n = \begin{cases} 0 & n \le 1,\\ 1 + \log^*\!\big(\lfloor \log_2 n\rfloor\big) & n > 1. \end{cases}$$

This function grows so slowly that for every input anyone will ever write down, it is at most $5$. Its natural companion is the **tower of twos**,
$$T_0 = 1, \quad T_{k+1} = 2^{T_k},$$
so that $T_0 = 1$, $T_1 = 2$, $T_2 = 4$, $T_3 = 16$, $T_4 = 65536$, and $T_5 = 2^{65536}$, a number with about twenty thousand digits. Iterated logarithm and tower are exact inverses of each other:
$$\log^*(T_j) = j \quad \text{for every } j, \qquad\text{and}\qquad n < T_{\log^* n + 1} \text{ for every } n.$$
The first identity says $\log^*$ *is* unbounded — it just takes towers to make it move. The second says $\log^* n$ is exactly the height of the smallest tower that overtakes $n$, give or take one.

Everything below is really a statement about towers wearing a logarithmic disguise.

## The threshold

Here is the main result. Call a radix schedule *admissible* if $r(x) \ge 2$ for every $x$, so that the weights genuinely grow, and *monotone* if $x \le y$ implies $r(x) \le r(y)$.

> **The Radix-Growth Threshold.** Let $r$ be admissible.
> 1. **(Exponential regime.)** If $2^x \le r(x)$ for all $x$ beyond some threshold $x_0$, then for *every* $n$,
> $$K_r(n) \le x_0 + \log^* n + 1 .$$
> In particular $K_r(n) = O(\log^* n)$, and not merely up to a multiplicative constant — the overhead is a single additive constant.
> 2. **(Polynomial regime.)** If $r$ is monotone and $r(x) \le x^C$ for some fixed exponent $C$ and all $x$ beyond some threshold, then $K_r$ is *not* $O(\log^* n)$: for every constant $c$ and every bound $N$ there exists an input $n \ge N$ with
> $$c\,\big(\log^* n + 1\big) < K_r(n).$$

So doubling the base as fast as an exponential makes representation essentially free — the digit count is bounded by an iterated logarithm plus a constant, meaning at most half a dozen digits for any number you will ever meet in this universe. Squaring the base, or cubing it, or raising it to the millionth power, does *not*. Between $x^{1{,}000{,}000}$ and $2^x$ lies a wall, and the wall is where the count stops being $O(\log^* n)$.

## Why the fast side works

The upper bound is short and pretty. Suppose $2^x \le r(x)$ once $x \ge x_0$. Every admissible schedule satisfies $2^k \le V_k$, simply because each step multiplies by at least $2$; hence the weights race past $x_0$ almost immediately. Once they have, each step *exponentiates*:
$$V_{k+1} = r(V_k) V_k \ge r(V_k) \ge 2^{V_k}.$$
That is precisely the recursion defining the tower of twos, so an induction gives
$$T_j \le V_{x_0 + j} \quad\text{for every } j.$$
The weights dominate a tower shifted by the constant $x_0$. Now feed in the tower characterization of $\log^*$: since $n < T_{\log^* n + 1} \le V_{x_0 + \log^* n + 1}$, the definition of the radix height gives $K_r(n) \le x_0 + \log^* n + 1$ immediately. The entire content of the upper bound is: *a schedule that exponentiates builds a tower, and towers are what $\log^*$ counts.*

## The bound is not an accident

An upper bound of $O(\log^* n)$ would be uninteresting if the truth were even smaller. It is not. Suppose the schedule is at most exponential, $r(x) \le 2^x$ for $x \ge 1$. Then the weights are trapped under a tower of *twice* the height:
$$V_k \le T_{2k}.$$
The induction is a two-line computation: $V_{k+1} = r(V_k)V_k \le 2^{V_k} \cdot 2^{V_k} = 2^{2V_k} \le 2^{2^{V_k}}$, and each application of $2^{(\cdot)}$ costs exactly one tower level. Because $\log^*$ is monotone and inverts the tower, this yields
$$\log^* n \le 2\, K_r(n) .$$

Put the two halves together on the canonical schedule $r(x) = \max(2, 2^x)$, which is at least $2^x$ everywhere and at most $2^x$ once $x \ge 1$, and you get, for every $n$ simultaneously,
$$\tfrac{1}{2}\log^* n \;\le\; K_r(n) \;\le\; \log^* n + 1 .$$
The radix height of the canonical exponential schedule is genuinely of order $\log^* n$ — no lossier estimate is hiding in the argument.

## Why the slow side fails — and what really causes the failure

The negative half is where the structure of the problem shows itself. One might guess that "polynomial" is the operative word. It is not.

Start with the schedule $r(x) \le x^C$. A single step then satisfies $V_{k+1} \le r(V_k)V_k \le M \cdot V_k^{C+1}$ for a suitable constant $M$ absorbing the behaviour below the threshold. Iterating a recursion of the form "raise to a fixed power" gives
$$V_k \le M^{E^k}, \qquad E = C+2 .$$
The weights are *doubly exponential in $k$* — enormous by ordinary standards, but only one exponential tall, whereas a tower of height $k$ is $k$ exponentials tall. That single missing level of the tower is the whole story.

To convert this into a lower bound on the radix height, one uses the sharpest possible probe: **test the system on its own weights**. Because the weights strictly increase, $V_k < V_{k+1}$, the radix height at a weight is known exactly:
$$K_r(V_k) = k + 1 .$$
So if we feed the input $n = V_k$ into the comparison, the left-hand side is $c(\log^*(V_k) + 1)$ and the right-hand side is $k+1$. All that remains is to check that $\log^*(V_k)$ is much smaller than $k$. And indeed: applying $\log^*$ to $M^{E^k}$ peels off the two exponentials at a cost of two, leaving roughly $\log_2(M + Ek)$, which is $O(\log k)$. Choosing $k$ of the form $2^{2t}$ makes $c \cdot O(\log k)$ far smaller than $k$, for any constant $c$ you like. Hence $c(\log^* n + 1) < K_r(n)$ at that input, and since $V_k \ge 2^k$, the witnesses are arbitrarily large. The failure is not a boundary effect at small $n$; it recurs forever.

Isolating this argument gives a **master transfer principle** far more general than the polynomial hypothesis:

> **Master Transfer Principle.** Let $r$ be admissible and suppose $\log^*(V_k) \le h(k)$ for a function $h$ that is *sublinear* in the weak sense that for all $c$ and $N$ there is some $k \ge N$ with $c\,(h(k)+1) < k+1$. Then for all $c$ and $N$ there is an $n \ge N$ with $c(\log^* n + 1) < K_r(n)$.

Only one number about the schedule matters: how fast $\log^*$ of the weights grows with the index. Everything else — polynomiality, monotonicity, the precise exponent — is scaffolding used to establish that single estimate.

The general principle immediately yields a hierarchy statement that the polynomial version cannot see. Write $E^{(h)}$ for $h$-fold exponentiation, $E^{(0)}(x) = x$ and $E^{(h+1)}(x) = 2^{E^{(h)}(x)}$, so that $T_k = E^{(k)}(1)$ is the tower again, but now with the height as a parameter.

> **Fixed-Height Theorem.** If for some *fixed* height $h$ and constants $M, E \ge 2$ the weights satisfy $V_k \le E^{(h)}(M + Ek)$ for all $k$, then $K_r$ is not $O(\log^* n)$.

Because $\log^*\big(E^{(h)}(y)\big) \le h + \log^* y \le h + \log_2 y$, a fixed height only shifts $\log^*$ by a constant — and $h + \log_2(M + Ek)$ is sublinear in $k$. So quasi-polynomial schedules, schedules like $r(x) = 2^{(\log_2 x)^C}$, even $r(x) = 2^{2^{\log_2 \log_2 x}}$: all of them fail. The dividing line is not polynomial versus exponential. **The dividing line is whether the height of the tower under which the weights live grows with $k$ or stays bounded.**

## The threshold, stated intrinsically

That reformulation invites a final question. Forget schedules; look only at the weights. What is the exact condition for the digit count to be $O(\log^* n)$?

> **Characterization.** For an admissible schedule, $K_r(n) = O(\log^* n)$ — meaning there is a constant $c$ with $K_r(n) \le c(\log^* n + 1)$ for all $n$ — **if and only if** the weights overtake the tower of twos along an arithmetic subsequence: there is a constant $c$ with
> $$T_k \le V_{c(k+1)} \qquad \text{for every } k .$$

Both directions are three lines once the right probes are chosen. Forwards: apply the hypothesis at $n = T_k$, use $\log^*(T_k) = k$, and use that the weights are increasing. Backwards: given $T_k \le V_{c(k+1)}$, combine with $n < T_{\log^* n + 1}$ to find a weight above $n$ at index $c(\log^* n + 2)$, which is at most $2c(\log^* n + 1)$.

This is the threshold in its clean form. The appearance of $\log^*$ in the original statement was never a coincidence, and never a choice of convenient yardstick. $\log^*$ is the inverse of the tower of twos; a positional system's digit count is $O(\log^* n)$ exactly when its weights can *track a tower*, up to a linear reparametrization of the index. Exponential schedules can; every fixed-height schedule cannot; and the gap between them is precisely one level of exponentiation.

## Why one might care

The result is elementary arithmetic, but it lives at the intersection of three scales that appear all over the mathematical sciences.

*Hierarchies of units.* Physical descriptions routinely stack scales: lattice spacing, correlation length, sample size, and so on up. If each new coarse-graining step multiplies the scale by a factor determined by the scale reached so far, this analysis says exactly how many strata are needed to cover a target scale — and shows that the answer depends on the coarsening rule only through the tower-height criterion above.

*Data structures and amortization.* $\log^*$ is the signature of the union-find data structure with path compression, of certain sorting networks, and of Ackermann-type recursions. The theorem above explains the phenomenon abstractly: iterated-logarithmic cost appears exactly when a recursive scheme escalates by exponentiation, and disappears the moment escalation is even slightly slower — by any fixed number of exponentials.

*The geometry of growth rates.* Between polynomials and exponentials there is an enormous zoo of intermediate functions, and one might expect the boundary between "$O(\log^*)$" and "not $O(\log^*)$" to be blurry. It is not blurry, but it also is not where naive intuition puts it. It sits at the level of tower height, which is an entirely different invariant from degree or growth order.

The most striking part is how thin the winning margin is. A schedule whose weights reach $M^{E^k}$ — a number with astronomically many digits by any human standard — is on the losing side. A schedule whose weights reach $T_k$ is on the winning one. All the arithmetic in between is invisible to $\log^*$, and all of it is on the same side of the wall.

