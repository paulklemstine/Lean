# Five Ways Not to Factor a Number

### A guided tour of two structural barriers — and why every attack keeps hitting one of them

---

Multiply two thousand-digit primes together and you are done in a millisecond. Hand someone the product and ask for the primes back, and the best classical methods on earth will grind for longer than the universe has existed. That asymmetry is the load-bearing wall of modern cryptography, and nobody has proved it is solid.

So here is a different research posture. Instead of hunting for a fast factoring algorithm, hunt for **reasons every attempt fails** — and see whether the reasons repeat.

This page walks through five attacks on integer factoring, drawn from five unrelated corners of mathematics: error-correcting codes, divisor parity, braid groups, average-case statistics, and game theory. All five fail. The interesting part is that **all five fail for one of exactly two reasons**, and by the end of this page you will be able to predict, for a new idea, which of the two walls it is about to hit.

Everything below is interactive. Click things. The mathematics is easier to believe once you have watched it happen.

---

## Part I — The two walls, stated up front

Before the stories, the morals. Both are about a semiprime $N = pq$, a product of two distinct primes.

**Wall 1: the Chinese Remainder Theorem splits everything.**
The ring of integers modulo $N$ is not one object; it is two glued together:
$$\mathbb{Z}/N \;\cong\; \mathbb{Z}/p \times \mathbb{Z}/q.$$
Every structure you build over $\mathbb{Z}/N$ — a code, a matrix group, a polynomial — inherits that product decomposition. So every numerical invariant you extract is really a *function of the two prime-level invariants*. Which means: if you can compute it, you have learned something about $p$ and $q$ separately, and learning something about $p$ and $q$ separately **is** factoring. Such a quantity is a **free witness**: it certifies the factorization instantly, and it is free only once you already have the answer.

**Wall 2: congruence data is blind.**
The other temptation is to find a cheap statistic of $N$ alone — its residue mod 8, a Jacobi symbol, a digit pattern — that predicts something about $p$ and $q$. Every such statistic is determined by $N \bmod m$ for some fixed modulus $m$. And Dirichlet's classical theorem on primes in arithmetic progressions kills the idea outright: every residue class contains infinitely many primes, hence contains two semiprimes that are *coprime to each other*. A rule seeing only the class cannot tell them apart, so whatever divisor it names divides at most one of them.

<details>
<summary><strong>Refresher: what exactly does the Chinese Remainder Theorem say?</strong></summary>

For coprime $p$ and $q$, the map $x \mapsto (x \bmod p,\ x \bmod q)$ is a *bijection* from $\mathbb{Z}/pq$ to $\mathbb{Z}/p \times \mathbb{Z}/q$, and it respects both addition and multiplication. So arithmetic modulo $N$ is exactly two independent arithmetics running in parallel. Picture $\mathbb{Z}/N$ as a $p \times q$ grid: the point $x$ sits at column $x \bmod p$ and row $x \bmod q$, and every cell is occupied exactly once. That picture is the single most useful thing on this page — the first widget draws it for you. [More background](https://en.wikipedia.org/wiki/Chinese_remainder_theorem).
</details>

---

## Part II — The code whose shape betrays a prime

Reed–Solomon codes are why a scratched CD still plays. The recipe: take polynomials of degree less than $k$, evaluate each at every point of a finite field, and call the resulting vectors codewords. The **minimum distance** — the smallest number of nonzero coordinates any nonzero codeword has — controls how many errors you can correct.

Now run the same recipe over $\mathbb{Z}/N$, which is *not* a field:
$$C_k(N) \;=\; \{(f(0), f(1), \dots, f(N-1)) : \deg f < k\}.$$

What is the minimum distance? Play with it before reading the answer. Choose two primes, choose a degree, and watch the grid.

{{interactive_demo:0}}

You will have seen the answer painted on the grid: the best codeword switches off **entire columns**.

> **Minimum-Distance Theorem.** For distinct primes $p < q$ and every $1 \le k \le p$, the minimum Hamming distance of the code of evaluations of polynomials of degree at most $k$ over $\mathbb{Z}/N$ is exactly
> $$d \;=\; N - k\max(p,q).$$

Stare at that. Set $k = 1$: then $\max(p,q) = N - d$ and $\min(p,q) = N/(N-d)$. **The minimum distance is the factorization.**

<details>
<summary><strong>Click to reveal the proof</strong></summary>

*The bound.* Suppose $f \ne 0$ and $f(x) = 0$. Reducing modulo $p$ and modulo $q$, the point $x$ maps to a pair: a root of $f \bmod p$ and a root of $f \bmod q$. The map $x \mapsto (x \bmod p, x \bmod q)$ is injective, so the zero set of $f$ injects into the *product* of the two prime-level root sets. At least one of the two reductions of $f$ is nonzero (if both vanished, every coefficient would be divisible by both $p$ and $q$, hence by $N$, so $f = 0$). Over a *field* a nonzero polynomial of degree $d$ has at most $d$ roots. So one factor of the product has size at most $\deg f$, the other at most $\max(p,q)$. Multiply:
$$|Z(f)| \;\le\; \deg(f)\cdot\max(p,q), \qquad\text{hence}\qquad \operatorname{wt}(f) \ge N - \deg(f)\max(p,q).$$

*Tightness.* Take $f_k(x) = q\,x(x-1)\cdots(x-k+1)$. Modulo $q$ it is identically zero — the leading constant kills it. Modulo $p$ it has exactly the $k$ roots $0, 1, \dots, k-1$, which are distinct because $k \le p$. So the codeword vanishes precisely on those $x$ whose residue mod $p$ lies in $\{0,\dots,k-1\}$: $k$ complete columns of the grid, each with exactly $q$ points. Total: exactly $kq = k\max(p,q)$ zeros. $\blacksquare$
</details>

So why is this not a factoring algorithm? Because you have exactly two routes to the minimum distance: the formula, which needs $p$ and $q$ (circular), or a search over $N^{k}$ codewords (exponential in the input length). Press the honest-computation button in the widget on a two-digit modulus and you can watch the cost arrive.

Here is the same phenomenon in three static pictures — the grid, the full weight spectrum, and the exact identity across ninety-one semiprimes:

{{visualization:0}}

And here is the reduction itself, written out as code — including both routes, so you can compare their costs directly:

{{algorithm:0}}

---

## Part III — The parity bit you cannot afford to ask for

Now a deliberately *weak* primitive. Fix a modulus $m$ and ask one bit:
$$P(N,m,a) \;=\; \#\{d : d \text{ a proper divisor of } N,\ d \equiv a \bmod m\} \bmod 2.$$

Surely a single parity bit is too coarse to be dangerous?

It is not. A semiprime $N = pq$ has exactly three proper divisors — $1$, $p$ and $q$ — so the bit is $1$ on exactly three residue classes and $0$ everywhere else.

> **Support Theorem.** If $1$, $p$, $q$ are pairwise incongruent mod $m$, the set of residues where the parity is $1$ is exactly $\{1 \bmod m,\ p \bmod m,\ q \bmod m\}$. Deleting the a priori known class $1$ returns exactly $\{p \bmod m,\ q \bmod m\}$.

The oracle is a factorization certificate modulo $m$. So why is *this* not an algorithm? Play the query game in the second half of the next widget — click residues, one query at a time, and try to find the needle.

{{interactive_demo:1}}

Three classes out of $m$. That is the whole story.

> **Indistinguishability Theorem.** Take two semiprimes, both non-degenerate at $m$. On every query outside their (at most six) marked classes, *both* oracles answer $0$ — the transcripts are literally identical. An adversary answering $0$ until forced compels $\Omega(m)$ queries.

An algorithm that has not hit a marked class has learned *nothing*: it cannot distinguish $N$ from a completely different semiprime. And each single query needs the divisors of $N$ — which is the problem you were trying to solve.

<details>
<summary><strong>When the oracle fails, it fails honestly</strong></summary>

If $p \equiv q \pmod m$ (and neither is $\equiv 1$), the two factor classes merge, their contributions *cancel* in the parity, and the whole pattern collapses to the single class $\{1 \bmod m\}$. Try $m = 4$ with $N = 253 = 11 \cdot 23$ in the widget above: since $11 \equiv 23 \equiv 3 \pmod 4$, everything vanishes. The failures are exactly the merged-class cases — structural, not accidental, and genuinely unresolvable, because at that modulus the two factors are indistinguishable in principle.
</details>

The first half of that same widget is the other experiment, and it belongs to Part V — come back to it.

---

## Part IV — Braids that are secretly clocks

Almost every failed attack lives in a *commutative* world. A recurring hope is that genuine non-commutativity is the missing ingredient, and braid groups are the natural place to look: tangles of strands, where the order of crossings matters.

The three-strand braid group is $B_3 = \langle \sigma_1, \sigma_2 \mid \sigma_1\sigma_2\sigma_1 = \sigma_2\sigma_1\sigma_2\rangle$. Its reduced Burau representation, specialized at a parameter $a$, sends
$$\sigma_1 \mapsto \begin{pmatrix} -a & 1 \\ 0 & 1\end{pmatrix}, \qquad \sigma_2 \mapsto \begin{pmatrix} 1 & 0 \\ a & -a\end{pmatrix}.$$
These genuinely satisfy the braid relation, so this is an honest non-abelian picture over $\mathbb{Z}/N$. Turn the crank and see what the invariants know:

{{interactive_demo:2}}

Every third power is a scalar — that is not a coincidence. The full twist $(\sigma_1\sigma_2)^3$ generates the centre of $B_3$, and central elements act by scalars:
$$B^3 = a^3 \cdot I, \qquad B := r(\sigma_1)r(\sigma_2).$$

> **Braid-Order Theorem.** For a unit $a$ in a nontrivial commutative ring, $B^n = I$ if and only if $3 \mid n$ *and* $a^n = 1$. Hence $\operatorname{ord}(B) = \operatorname{lcm}(3, \operatorname{ord}(a))$.

<details>
<summary><strong>Click to reveal the proof</strong></summary>

Write $n = 3s + t$ with $t \in \{0,1,2\}$. Since $B^{3s} = a^{3s}I$, we get $B^n = a^{3s}B^t$. If $B^n = I$, compare upper-right entries: $a^{3s}(B^t)_{01} = 0$, and $a^{3s}$ is a unit, so $(B^t)_{01} = 0$. But $(B)_{01} = -a$ and $(B^2)_{01} = a^2$, and neither vanishes for a unit $a$ in a nontrivial ring. So $t = 0$, i.e. $3 \mid n$; and then $a^nI = I$ gives $a^n = 1$. The converse is immediate. The order formula follows by applying the equivalence in both directions. $\blacksquare$
</details>

The consequences are fatal and immediate. $\operatorname{ord}(a)$ divides $\operatorname{ord}(B)$, and $\operatorname{ord}(B)$ divides $3\operatorname{ord}(a)$: the two computational problems are *the same problem* up to a factor of three. And by Lagrange's theorem, even the coarsest invariant of the whole braid image — the size of the group $H_a = \langle r(\sigma_1), r(\sigma_2)\rangle$ — is divisible by $\operatorname{lcm}(3,\operatorname{ord}(a))$.

Then Wall 1 closes the door:
$$\operatorname{ord}_{pq}(a) \;=\; \operatorname{lcm}\bigl(\operatorname{ord}_p(a),\ \operatorname{ord}_q(a)\bigr).$$
The braid order is $\operatorname{lcm}(3, \operatorname{ord}_p(a), \operatorname{ord}_q(a))$ — exactly the quantity Pollard's $p-1$ method hopes will be smooth, and exactly the quantity Shor's algorithm computes in order to factor.

<details>
<summary><strong>The one genuinely non-abelian hook — and why it doesn't help</strong></summary>

The group order $|H_a|$ carries strictly *more* information than the braid order. Modulo $21$, both $a = 2$ and $a = 5$ give $\operatorname{lcm}(\operatorname{ord}_3, \operatorname{ord}_7) = 6$, yet $|H_2| = 336$ while $|H_5| = 24$. The reason is genuinely non-commutative: the swap $p \leftrightarrow q$ is not realized by any braid, so the representation does not symmetrize the two prime-level data, and $|H_a|$ can see the *individual* pair $(\operatorname{ord}_p(a), \operatorname{ord}_q(a))$ rather than just its lcm.

That extra sensitivity points in exactly the unavailable direction. Knowing the pair separately is strictly *closer* to knowing $p$ and $q$ — which makes the invariant harder to compute, not easier. Separation is not extraction. (Verify the $336$ versus $24$ yourself in the widget above.)
</details>

The reduction, in code, in both directions:

{{algorithm:1}}

---

## Part V — There is no lucky family, and no lucky rule

Perhaps we are asking too much. Perhaps no algorithm factors *every* semiprime quickly, but a large, easily recognizable family succumbs. Fast subfamilies certainly exist: if $p$ and $q$ are close, Fermat's method wins instantly; if $p-1$ is smooth, Pollard's $p-1$ wins. But those are properties of $p$ and $q$ — you cannot check them without already knowing the answer.

Is there a family recognizable from $N$ itself? Go back to the first half of the blindness widget (Part III) and try to build a rule. Then look at the data:

{{visualization:1}}

Left panel: Pollard-$\rho$ step counts grouped by $N \bmod 8$ — a statistic anyone can read off $N$. The distributions are indistinguishable. Middle panel: the same counts grouped by decile of the factor gap $|p-q|$ — a property of the factors. Dramatic effect. Right panel: the parity oracle's three-in-$m$ needle.

The theorems behind the left panel are unconditional.

> **Class-Population Theorem.** Fix a modulus $m$, a unit residue $a$, and *any* prime $p$ invertible mod $m$. Then for every bound $B$ there is a prime $r > B$ with $pr \equiv a \pmod m$ and $\operatorname{minFac}(pr) = p$.

So a residue class contains semiprimes with whatever smallest factor you like, and with arbitrarily large factor gap. The Fermat-easy family is invisible from $N$.

> **Free-Witness Meta-Theorem.** Call an invariant *congruence-determined* modulo $m$ if it depends on $N$ only through $N \bmod m$, and *factor-revealing* if it returns a nontrivial divisor of every large semiprime. For every $m > 1$, no invariant is both.

<details>
<summary><strong>Click to reveal the proof — it is three lines</strong></summary>

By Dirichlet, choose primes $p_1 < p_2$ both $\equiv 1 \pmod m$, then $r_1 > p_2$ and $r_2 > r_1$ likewise. All four primes are distinct, and $N_1 = p_1r_1 \equiv 1 \equiv p_2r_2 = N_2 \pmod m$.

A congruence-determined invariant returns the *same* value $d$ on both. Being factor-revealing, $d$ is a nontrivial divisor of $N_1$, so $d \in \{p_1, r_1\}$; and of $N_2$, so $d \in \{p_2, r_2\}$. But the four primes are distinct. Contradiction. $\blacksquare$

Note the hypothesis is not vacuous on the revealing side: the least-prime-factor map *is* factor-revealing. The obstruction lands squarely on congruence-determination.
</details>

Nor does guessing a *list* help:

> **Bounded-List Theorem.** Fix $m > 1$ and a length bound $k$. If $S(a)$ is a set of at most $k$ candidates for each class $a$, then some large semiprime $N$ has no nontrivial divisor inside $S(N \bmod m)$.

The proof is a pigeonhole with teeth: build $k+1$ pairwise-coprime semiprimes in one class; each needs its own candidate, because coprimality means no number can serve two of them; so the list needs $k+1$ slots. Slide the list-length control in the blindness widget and watch the witness family grow to match.

Here is the witness construction as a standalone routine:

{{algorithm:2}}

---

## Part VI — The game whose equilibrium is the answer

The last attempt is the most philosophically pointed. Recast factoring as a game and hope that equilibrium-finding cracks it.

**The divisor congestion game.** Given $N$, each player bids $d \in \{2,\dots,N-1\}$ and receives
$$w(d) = \begin{cases} N/d & \text{if } d \mid N,\\ -N & \text{otherwise.}\end{cases}$$

> **Equilibrium Theorem.** For composite $N$, the least prime factor is a best response, and for $N = pq$ with $p < q$ it is the *unique* best response. Reading off the equilibrium bid $d$ and its payoff gives $N = d \cdot w(d)$ with $d$ prime — the complete factorization.

That is not a win; it is the definition of circularity. Three facts finish the job.

1. **A payoff query is a divisibility test:** $w(d) \ge 0$ if and only if $d \mid N$. Computing best responses *is* trial division.
2. **The landscape is exactly flat off the divisors:** every non-divisor pays precisely $-N$. No gradient, no slope, nothing for a hill-climber to climb. A plateau of size $N$ with a handful of invisible pits.
3. **No residue shortcut:** the equilibrium bid is $\operatorname{minFac}(N)$, which by the meta-theorem of Part V is not congruence-determined.

Verification is trivial; discovery is the whole problem. The game is a poly-time-checkable *restatement* of factoring.

The full numerical tour — all five closures, computed end to end — is here. Run it to see every theorem on this page checked against data:

{{demo:0}}

---

## Part VII — What five failures add up to

Line them up. A Reed–Solomon minimum distance. A braid-group order. A divisor-parity support. An equilibrium bid. Four objects from four disjoint areas of mathematics, and each one turns out to **be** the factorization rather than a route to it — each reachable only at cost $\Omega(N)$ or worse, each cheap only once you already have $p$ and $q$.

The structural cause is always the same splitting: $\mathbb{Z}/N \cong \mathbb{Z}/p \times \mathbb{Z}/q$ means an invariant over $\mathbb{Z}/N$ is a pair of prime-level invariants in a trench coat. And on the other side, the escape through cheap statistics of $N$ is closed by Dirichlet: residue classes are rich enough to contain every factorization profile, including coprime twins.

This proves nothing about the true hardness of factoring — that remains open, and nothing here rules out a genuinely new idea. What it gives you is a **map**. If your new idea builds an algebraic invariant over $\mathbb{Z}/N$, expect the splitting to turn it into a free witness. If your new idea reads a statistic off $N$, expect Dirichlet to blind it. Anything that escapes must dodge *both* — and saying precisely how is now a fair and answerable demand.

<details>
<summary><strong>Where to go next</strong></summary>

Three concrete open questions the analysis above suggests.

1. **The whole weight spectrum, not just the minimum.** The bound in Part II came from the product structure of the *zero set*, which controls every weight, not merely the smallest. Conjecture: the full weight enumerator of $C_k(N)$ is the Hadamard product of the two prime-level Reed–Solomon enumerators, and every gap in the spectrum determines $\max(p,q)$ — so a fast algorithm for *any single coefficient* would factor.
2. **Beyond congruences.** The Dirichlet argument used only one property of a residue class: that it contains two coprime semiprimes. Any invariant whose level sets are rich in that sense is blind in the same way — and the level sets of small arithmetic circuits are large. Conjecture: no circuit-determined invariant names a factor of every large semiprime, unless factoring is easy.
3. **Games with real gradients.** The congestion game died because its landscape is exactly flat. An interpolating payoff such as $-(N \bmod d)$ has genuine slope — but is it still computable from $N$ alone in polynomial time, and do its dynamics converge? The two demands appear to conflict, and turning that conflict into a theorem is the natural next step.

Further reading: [Dirichlet's theorem](https://en.wikipedia.org/wiki/Dirichlet%27s_theorem_on_arithmetic_progressions), [Reed–Solomon codes](https://en.wikipedia.org/wiki/Reed%E2%80%93Solomon_error_correction), [the braid group](https://en.wikipedia.org/wiki/Braid_group), [Pollard's rho](https://en.wikipedia.org/wiki/Pollard%27s_rho_algorithm_for_logarithms), [Shor's algorithm](https://en.wikipedia.org/wiki/Shor%27s_algorithm).
</details>
