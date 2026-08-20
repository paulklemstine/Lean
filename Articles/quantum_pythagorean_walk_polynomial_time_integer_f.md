# The Music of Right Triangles: How a Tree of Pythagorean Triples Almost Factors Numbers

## A machine with three levers

Start with the most famous triangle in mathematics: legs $3$ and $4$, hypotenuse $5$. Now build a machine that takes any right triangle with whole-number sides and spits out three new ones. The machine has three levers, and each lever is a fixed recipe. Given a triple $(a,b,c)$ with $a^2+b^2=c^2$, the levers produce

$$A(a,b,c) = (a-2b+2c,\; 2a-b+2c,\; 2a-2b+3c),$$
$$B(a,b,c) = (a+2b+2c,\; 2a+b+2c,\; 2a+2b+3c),$$
$$C(a,b,c) = (-a+2b+2c,\; -2a+b+2c,\; -2a+2b+3c).$$

Pull lever $A$ on $(3,4,5)$ and out comes $(5,12,13)$. Pull $B$ and you get $(21,20,29)$. Pull $C$ and you get $(15,8,17)$. Pull again, and again, and a ternary tree grows: three children per node, $3^n$ triangles at depth $n$.

This is the *Berggren tree*, and it has a property that borders on the miraculous. Every primitive Pythagorean triple — every triple $(a,b,c)$ with $a^2+b^2=c^2$ and no common factor in the legs, written with the odd leg first — appears in this tree **exactly once**. Not "most of them", not "up to some symmetry": exactly once, at exactly one address. The address is the sequence of levers you pulled, a word in the three-letter alphabet $\{A,B,C\}$. The triangle $(33,56,65)$ lives at address $AC$; the triangle $(63,16,65)$ lives at address $CCC$.

So the infinite, apparently unruly family of Pythagorean triples is really a perfectly organised filing cabinet, and the filing system is a free ternary tree. That is the stage. What follows is a story about trying to use this filing cabinet to break numbers apart — and about discovering, with complete precision, exactly why it *almost* works and exactly what stops it.

## Resonance

Fix a target number $N$ — think of it as the number you want to factor. Walk down the tree, and at every node ask a single yes/no question: *does $N$ divide my hypotenuse?*

Call the node **resonant** for $N$ if it does. The name is deliberate. If you assign to each node the quantity $E_N(t) = c \bmod N$ — an "energy" — then resonant nodes are precisely the ones sitting at the bottom of the energy spectrum, $E_N = 0$. A walker exploring the tree with all three levers in superposition, as a quantum particle would, would find its amplitude concentrated on the resonant nodes only if those nodes could be made to interfere constructively. Hence: a quantum walk on the Pythagorean tree, resonating at the minima of an arithmetic energy.

Two questions immediately arise. Which targets $N$ resonate at all? And what do you learn when they do?

## Which numbers resonate

The first question has a clean and complete answer.

> **Resonance Dichotomy.** Let $N>1$ be odd. The tree contains a node whose hypotenuse is divisible by $N$ if and only if $-1$ is a square modulo $N$.

The "only if" half is the classical constraint on hypotenuses in disguise: if $a^2+b^2=c^2$ with $a,b$ coprime and $N \mid c$, then $a^2 \equiv -b^2 \pmod N$ and $b$ is invertible modulo $N$, so $(ab^{-1})^2 \equiv -1$. In particular, if any prime $p \equiv 3 \pmod 4$ divides $N$, then **no node of the entire infinite tree** is resonant for $N$. The target is invisible; the walk simply never sees it.

The "if" half is a construction. Suppose $s^2 \equiv -1 \pmod N$; because $N$ is odd we may pick the representative $s$ to be even. Then
$$(s^2-1)^2 + (2s)^2 = (s^2+1)^2,$$
and $(s^2-1, 2s, s^2+1)$ is a primitive Pythagorean triple with odd first leg whose hypotenuse $s^2+1$ is divisible by $N$. By the filing-cabinet theorem, this triple *is* a node of the tree, and it has a definite address. Moreover it is not far away: its hypotenuse is at most $(N-1)^2+1$.

So the resonant targets are exactly the odd numbers all of whose prime factors are $\equiv 1 \pmod 4$ (times the usual caveats about squares). Half of the primes are invisible to this machine. Keep that in mind; it will matter.

## Collapse: two resonances make a factor

Now the payoff. Suppose two *different* nodes of the tree resonate for the same $N$:
$$(a_1,b_1,c_1), \quad (a_2,b_2,c_2), \qquad N \mid c_1, \quad N \mid c_2 .$$

From $a_i^2 + b_i^2 = c_i^2$ and $N \mid c_i$ we get $a_i^2 \equiv -b_i^2 \pmod N$ for each $i$. Multiply the two congruences:
$$(a_1a_2)^2 \equiv (-b_1^2)(-b_2^2) = (b_1b_2)^2 \pmod N .$$

That is a **congruence of squares** — the engine inside every modern factoring algorithm from Fermat's method to the number field sieve. The identity behind it is exact and needs no modular arithmetic at all:
$$(a_1a_2)^2 - (b_1b_2)^2 = a_2^2c_1^2 - b_1^2c_2^2 .$$

And once you have $x^2 \equiv y^2 \pmod N$ with $x \not\equiv \pm y$, you have a factor: $N$ divides $(x-y)(x+y)$ but divides neither factor, so
$$\gcd(x-y,\,N)$$
is a divisor of $N$ that is neither $1$ nor $N$.

> **Resonance Collapse Theorem.** If $t_1=(a_1,b_1,c_1)$ and $t_2=(a_2,b_2,c_2)$ are primitive Pythagorean triples with $N \mid c_1$, $N \mid c_2$, and $N$ divides neither $a_1a_2-b_1b_2$ nor $a_1a_2+b_1b_2$, then $\gcd(a_1a_2-b_1b_2,\,N)$ is a proper nontrivial divisor of $N$. In particular $N$ is composite.

Watch it work on $N = 65$. The nodes $(33,56,65)$ at address $AC$ and $(63,16,65)$ at address $CCC$ are both resonant. Then $a_1a_2 = 33\cdot 63 = 2079$ and $b_1b_2 = 56 \cdot 16 = 896$, and indeed $2079^2 \equiv 896^2 \pmod{65}$. Their difference is $1183$, and
$$\gcd(1183,\,65) = 13 .$$
The tree has factored $65 = 13 \times 5$ — not by trial division, not by searching for divisors, but by letting two triangles interfere.

Non-squarefree targets are no obstacle. For $N = 325 = 5^2 \cdot 13$ the resonant nodes are $(253,204,325)$ and $(323,36,325)$, and their interference returns $\gcd = 25$. For $N = 1105 = 5\cdot 13\cdot 17$ there are four resonant nodes; the first interfering pair returns $221 = 13 \cdot 17$.

## The arithmetic never fails

Is the collapse a lucky accident of small examples? No. It is universal on exactly the domain where it can possibly apply.

> **Universal Collapse Theorem.** Let $N$ be odd, with every prime factor congruent to $1$ modulo $4$, and suppose $N$ is not a prime power. Then the tree contains two *distinct* nodes whose hypotenuse is exactly $N$, and the interference of that pair returns an exact, nontrivial, proper divisor of $N$.

The proof is a chain of classical identities, sharpened. First, every prime $p \equiv 1 \pmod 4$ is a sum of two coprime squares, $p = x^2+y^2$ (Fermat). Second — and this is the technical heart — every *power* $p^k$ is again a sum of two coprime squares. The mechanism is the Gaussian recursion $z \mapsto (x \pm iy)z$: given a primitive representation of $p^{k-1}$, the two Brahmagupta compositions
$$(xA \mp yB)^2 + (xB \pm yA)^2 = p\,(A^2+B^2) = p^k$$
produce two representations of $p^k$, and exactly one of them stays primitive — the other has both coordinates divisible by $p$. Third, multiplying primitive representations of coprime parts, again by Brahmagupta, gives a primitive representation of the whole. So every admissible $N$ can be written $N = A^2+B^2$ with $\gcd(A,B)=1$, and every such representation gives a node $(A^2-B^2, 2AB, A^2+B^2)$... except that here we want representations of $N$ itself as a hypotenuse, which come from splitting $N = m\cdot n$ into coprime parts and composing their representations with the two possible signs. The two sign choices give genuinely different nodes, and their interference gcd is not merely *some* divisor: it is exactly the divisor $m$ (or a precise companion), computed on the nose.

So on the resonant domain the arithmetic is perfect. Every composite that is not a prime power splits. Nothing is left to chance.

## Multiplicity: counting resonances detects primality

There is a second, quieter payoff. Instead of asking *whether* a target resonates, count *how many* nodes have hypotenuse exactly $N$. Write $r(N)$ for that count.

> **Multiplicity Theorem (prime powers).** For a prime $p \equiv 1 \pmod 4$ and any $k \geq 1$, there is *exactly one* node of the tree with hypotenuse $p^k$. Hence $r(p^k)=1$.

> **Multiplicity Theorem (semiprimes).** For distinct primes $p,q \equiv 1 \pmod 4$, there are *exactly two* nodes with hypotenuse $pq$. Hence $r(pq)=2$.

Both are uniqueness statements about representations $N = A^2+B^2$ in disguise, and the prime-power case has a pretty direct proof. If $A^2+B^2 = A'^2+B'^2 = p^k$ with both pairs coprime, then
$$(AB'-A'B)(AB'+A'B) = p^k(B'^2-B^2),$$
and $p$ divides neither $A,B,A',B'$, so $p$ cannot divide both factors on the left; the whole of $p^k$ therefore divides one of them, and the Brahmagupta identity $(AA' \mp BB')^2 + (AB' \pm A'B)^2 = p^{2k}$ forces that factor to be $0$ or $\pm p^k$. Either alternative pins $\{A^2,B^2\} = \{A'^2,B'^2\}$.

Combining, one gets a crisp characterisation:

> **Unique Resonance Characterises Prime Powers.** Among odd targets all of whose prime factors are $\equiv 1 \pmod 4$, the resonant node is unique precisely when the target is a prime power. Every other target carries an interference pair, and hence splits.

Resonance multiplicity is thus a *primality certificate*: $r(N)=1$ says "prime power, nothing to factor"; $r(N)\ge 2$ says "composite, and here is the factor". Numerically the pattern is $r(N)=2^{\omega(N)-1}$, where $\omega$ counts distinct prime factors — $r(5)=1$, $r(65)=2$, $r(1105)=4$, $r(32045)=8$ — matching the classical count of essentially distinct representations as a sum of two squares.

## The wall

Everything so far says: the mechanism works. The obvious next thought is the seductive one — a quantum walker exploring all $3^n$ branches at depth $n$ in superposition, interfering constructively on the resonant set, would collapse onto a factor of $N$ in time polynomial in the number of digits of $N$. That is the claim this programme was built to test.

It is false, and the reason is beautifully simple.

Every lever multiplies the hypotenuse by at most $7$: $c' \le 7c$ for each of $A$, $B$, $C$. Starting from $c=5$, a walk of depth $n$ can only reach hypotenuses up to $5\cdot 7^n$. But a resonance for $N$ needs a hypotenuse divisible by $N$, hence at least $N$. So any resonant address has length
$$n \;\ge\; \log_7 (N/5).$$
Meanwhile the tree at depth $n$ holds $3^n$ nodes — and here is the punchline: since $9 > 7$, the inequality $N \le 5\cdot 7^n \le 5 \cdot 9^n$ rearranges to

$$3^n \;\ge\; \sqrt{N/5}.$$

> **Search Barrier Theorem.** If any node at depth $n$ is resonant for $N$, then the depth-$n$ layer contains at least $\sqrt{N/5}$ nodes.

The Hilbert space you would have to prepare, at the very first depth where a resonance is even possible, has dimension $\Omega(\sqrt N)$ — exponential in the bit length of $N$. Even a Grover-style quadratic speed-up over a single layer costs $\Omega(N^{1/4})$, still exponential in $\log N$. The tree is a superb filing cabinet, but the drawer you need is astronomically deep.

One might hope to escape by cleverness: a biased coin, a position-dependent coin, an adaptive or entangling coin. It does not help, and this can be stated without assuming anything at all about the dynamics. Let the state at depth $n$ be an arbitrary assignment of complex amplitudes $\psi$ to the $3^n$ branch histories, and let $R$ be the set of resonant histories. Define the coherent resonance amplitude $\mathcal{A}(\psi) = \sum_{r \in R}\psi_r$.

> **Coin-Independent Barrier.** If $5\cdot 7^n < N$, then $\mathcal{A}(\psi) = 0$ for *every* state $\psi$. The obstruction lies in the support of the walk, not in its amplitudes.

> **Interference Bound.** For every state $\psi$, $\;|\mathcal{A}(\psi)|^2 \le |R| \cdot \|\psi\|^2$. The maximal interference gain of any coin whatsoever is exactly the resonance multiplicity $|R|$.

The proof is two lines of Cauchy–Schwarz, and the uniform coin realises it as the special case $|R|^2 3^{-n} \le |R|$. But the last word is a rigidity statement, and it is the sharpest thing in the whole story.

> **Rigidity of the Optimum.** Assume $R \neq \emptyset$. Then $|\mathcal{A}(\psi)|^2 = |R|\cdot\|\psi\|^2$ holds **if and only if** $\psi$ is a scalar multiple of the indicator function of $R$.

Read that carefully. There is exactly one optimal state, up to a global amplitude: the state that puts equal weight on the resonant branches and nothing anywhere else. To prepare it, you must already know which branches are resonant — that is, you must already know the answer. The optimal coin is not a computational device; it is a description of the solution.

The proof does not even need the equality case of Cauchy–Schwarz. It is a variance identity: with $c = \mathcal{A}(\psi)/|R|$,
$$\sum_{r\in R}|\psi_r - c|^2 \;=\; \sum_{r\in R}|\psi_r|^2 \;-\; \frac{|\mathcal{A}(\psi)|^2}{|R|},$$
so saturating the bound forces the left-hand side to vanish — $\psi$ is constant on $R$ — and the same computation forces $\psi$ to vanish off $R$.

## What the failure teaches

It would be easy to file this under "another factoring idea that didn't work". That reading misses the point twice over.

First, the *arithmetic half is a complete success and is unconditional*. On the entire domain where the mechanism can operate — odd targets with all prime factors $\equiv 1 \bmod 4$ — every non-prime-power target provably splits, exactly, with an explicitly computed divisor; every prime power provably refuses to split, because it has only one resonant node and interference needs two. There is no gap between "usually works" and "always works", and no heuristic anywhere. The tree is a genuine, exact factoring oracle. What it lacks is a fast way to find the two resonant addresses.

Second, the *obstruction has been located precisely*, which is rarer and more useful than a vague impossibility. The barrier is **kinematic**, not dynamical: it lives in the geometry of the state space (the tree grows too slowly in value and too fast in width) and not in the choice of evolution. No amount of coin engineering can move it, because the bound holds for every conceivable state. And where the bound *is* attainable, rigidity says the attaining state encodes the answer. This is the same shape as the standard lower-bound arguments for unstructured search, but derived here from pure Diophantine geometry: two competing exponential rates, $7$ per step for the value and $3$ per step for the width, and $9 > 7$.

There is a pleasing tension in the numbers. The tree is genuinely *shallow* in one direction: iterating the single lever $A$ from the root gives
$$A^n(3,4,5) = (2n+3,\; 2n^2+6n+4,\; 2n^2+6n+5),$$
so hypotenuse $c$ is reachable at depth about $\sqrt{c/2}$, and every resonance sits in the explicit window
$$\log_7(c/5) \;\le\; n \;\le\; (c-5)/8 .$$
The slow branch reaches deep values with few steps — but it is one path among $3^n$, and finding it is the whole problem.

## Coda

There is something faintly musical about the whole picture, and the vocabulary of resonance is not just decoration. A target number defines a frequency. Most numbers — anything divisible by a prime $\equiv 3 \bmod 4$ — are simply inaudible to this instrument: no triangle in the entire infinite tree vibrates at their frequency. Those that are audible have a precise number of resonant modes, $2^{\omega(N)-1}$, one for each way of splitting the number into coprime parts. A prime power has a single pure tone and cannot be broken. Anything else has at least two tones, and the beat between them — the interference term $a_1a_2 - b_1b_2$ — carries, in its greatest common divisor with $N$, an exact factor.

The instrument is real and its physics is exact. The only trouble is that finding the two strings that beat together requires searching a concert hall with $\sqrt N$ seats. That is not a flaw in the theory of resonance. It is a theorem about the shape of the hall.
