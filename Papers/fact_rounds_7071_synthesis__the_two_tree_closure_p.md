# The Two-Tree Closure — a guided tour

*Every right triangle with whole-number sides has an exact address in one infinite family tree. This page is about a simple question with a surprisingly sharp answer: can you read a triangle's address off its hypotenuse?*

---

## 1. A tree that contains every Pythagorean triple exactly once

Write a primitive Pythagorean triple in Euclid's form
$$(m^2 - n^2,\; 2mn,\; m^2 + n^2),$$
with $m > n \ge 1$ coprime and of opposite parity. Call the pair $(m,n)$ a **node** and $N = m^2+n^2$ its **hypotenuse**. The root is $(2,1)$, the familiar $(3,4,5)$. Each node has exactly three children:

$$A:(m,n)\mapsto(2m-n,\,m),\qquad B:(m,n)\mapsto(2m+n,\,m),\qquad C:(m,n)\mapsto(m+2n,\,n).$$

Applying these forever from the root sweeps out **every** primitive triple, each exactly once. So every triple carries a unique **address word** over the alphabet $\{A,B,C\}$ — the sequence of turns leading to it.

Start by walking the tree yourself. Descend with A, B, C; climb back with the parent button; watch how the address word grows and how the hypotenuse explodes.

{{interactive_demo:0}}

<details>
<summary><strong>Click to reveal: why the address is unique</strong></summary>

The **ascent letter** of a node is decided by the ratio $m/n$ alone:
$$\ell(m,n) = A \text{ if } m<2n, \qquad B \text{ if } 2n<m<3n, \qquad C \text{ if } 3n<m.$$
The boundary cases are impossible: $m=2n$ with $\gcd(m,n)=1$ forces the root $(2,1)$, and $m=3n$ forces $(3,1)$, whose coordinate sum is even — not a node.

Inverting the branch named by the letter gives a candidate parent, and one checks it is again a node with a strictly smaller leading coordinate. So descent terminates at the root: every node is reachable, the parent is unique, and the address word is unique. In fact distinct words always reach distinct nodes — the tree is *free* on its three generators. Consequently level $h$ has exactly $3^h$ nodes, and since the last letter of a word is the ascent letter of the node it reaches, each of the three letters is worn by exactly $3^{h}$ of the $3^{h+1}$ nodes at level $h+1$: **perfect equidistribution**.
</details>

---

## 2. Why anyone cares: the address hides a factorisation

Let $N = pq$ be a semiprime with $p \equiv q \equiv 1 \pmod 4$. Such an $N$ is a sum of two coprime squares, so it sits at a node. Find that node $(m,n)$ and you have written $N = m^2+n^2$ — a Gaussian factorisation, from which $p$ and $q$ fall out.

So a cheap letter oracle would be a factoring shortcut: predict the letter, invert one branch, repeat. The rest of this page is the story of why every cheap oracle fails.

The picture below shows the geometry of the obstruction in one image. On the left, the letter is a function of the **direction** of $(m,n)$; on the right, the hypotenuse is a function of its **length** — and lengths collide.

{{visualization:0}}

---

## 3. Seal one and two: dials with a modulus

The first probes to try read $N$ modulo something — a residue dial, or the magnitude of a quadratic Gauss sum
$$G_M(N) = \sum_{x \bmod M} e^{2\pi i N x^2/M}$$
at a smooth modulus like $M = 720720 = 2^4\cdot3^2\cdot5\cdot7\cdot11\cdot13$.

Both fail for the same reason, and you can manufacture the counterexample yourself for any modulus in the second tab of the lab above: pick $M$, hit "build a blindness certificate", and read off three nodes with the three distinct letters and one common residue.

<details>
<summary><strong>Click to reveal: the one-line certificate</strong></summary>

Take any even $n \ge 2$ with $M \mid n$ — for instance $n = 2Mt$. The three nodes
$$(n+1,\,n), \qquad (2n+1,\,n), \qquad (3n+1,\,n)$$
have ratios just below $2$, just above $2$, and just above $3$, hence letters $A$, $B$, $C$. Their hypotenuses are
$$2n^2+2n+1, \qquad 5n^2+4n+1, \qquad 10n^2+6n+1,$$
each of which is $1 + M\cdot(\text{integer})$ because $M \mid n$. Three letters, one residue: no function of $N \bmod M$ can output the letter, at any modulus and at any scale.

And $G_M(N+kM) = G_M(N)$, because each summand's exponent shifts by an integer multiple of $2\pi i$. So a Gauss-sum probe — magnitude, phase, or any learned readout — *is* a residue dial. A whole battery of moduli all dividing a common $M$ is still a function of $N \bmod M$, and still blind.
</details>

---

## 4. Seal three: sensors that never move

A third family reads structure: parities of the sides, sign counts, the quadratic form. These fail humiliatingly. At **every** node the parity profile of $(m^2-n^2,\ 2mn,\ m^2+n^2)$ is exactly $(\text{odd},\ \text{even},\ \text{odd})$, and the Lorentz form
$$(m^2-n^2)^2 + (2mn)^2 - (m^2+n^2)^2$$
vanishes identically — it *is* the Pythagorean identity. A constant sensor has zero mutual information with anything. Not "small": exactly zero.

---

## 5. Seal four: even the number itself is not enough

Here is the strongest statement, and the one to remember.

$$505 = 19^2 + 12^2 = 21^2 + 8^2 = 5 \cdot 101.$$

Two legitimate addresses for one number — and the first has $m<2n$ (letter $A$) while the second has $2n<m<3n$ (letter $B$). So the ascent letter **is not a function of the hypotenuse**, and no probe reading $N$, however clever, can compute it. The family is infinite: for every $t\ge1$,
$$(20t-1)^2 + (10t+2)^2 = (20t+1)^2 + (10t-2)^2 = 500t^2+5.$$

Type $505$, $8005$, or $2405$ into the "Blindness lab" tab above and watch the verdict change. Then try a number of your own.

<details>
<summary><strong>Click to reveal: why collisions exist at all</strong></summary>

The Brahmagupta–Fibonacci identity says a product of two sums of squares is a sum of squares in *two* ways:
$$(a^2+b^2)(c^2+d^2) = (ac-bd)^2 + (ad+bc)^2 = (ac+bd)^2 + (ad-bc)^2 .$$
With $(a,b) = (2,1)$ and $(c,d) = (10t,1)$ the two compositions are exactly $(20t-1,\,10t+2)$ and $(20t+1,\,10t-2)$ — the colliding pair. The ambiguity in the address is precisely the ambiguity in the composition, and pinning down the composition means knowing how $N$ factors. Positional information is real; it just lives on the far side of the factorisation.

For much more on the underlying arithmetic, see [sums of two squares](https://en.wikipedia.org/wiki/Sum_of_two_squares_theorem) and the [Brahmagupta–Fibonacci identity](https://en.wikipedia.org/wiki/Brahmagupta%E2%80%93Fibonacci_identity).
</details>

<details>
<summary><strong>Click to reveal: the conjecture that a collision must split the letters — and why it is false</strong></summary>

It is tempting to hope that whenever $N$ has two addresses, the letters differ, so that the mere existence of a collision is a signal. The Sophie Germain identity kills this:
$$u^4 + 4 = (u^2-2u+2)(u^2+2u+2), \qquad u^4+4 = (u^2-2)^2 + (2u)^2 = (u^2)^2 + 2^2 .$$
For odd $u \ge 7$ both nodes have ratio above $3$, so both carry letter $C$. The smallest case is $2405 = 47^2+14^2 = 49^2+2^2$, and the semiprime $50629 = 197\cdot257 = 223^2+30^2 = 225^2+2^2$ shows it is not a small-number accident. Both behaviours — splitting and non-splitting — occur above every bound, with at least $\sqrt{(X-5)/500}$ splitting collisions and $\gg X^{1/4}$ non-splitting ones below $X$. So "does $N$ collide?" is itself letter-free.
</details>

Finally, magnitude-*scale* probes die too: for every $X \ge 661$ and every letter there is a node with that letter whose hypotenuse lies in $[X,2X)$. Knowing the order of magnitude of $N$ does not even restrict which letters are possible.

{{algorithm:1}}

---

## 6. Suppose you had a noisy oracle anyway

Grant, hypothetically, a probe that guesses each letter correctly with probability $a$. Climb $h$ levels, restart on failure. The expected number of visited nodes is the **restart energy**
$$E(h,a) = \frac{h}{a^{h}} .$$

Slide the accuracy in the third tab of the lab and watch the gold curve cross the white one ($3^h$, exhaustive search) and the green one (your budget).

{{visualization:1}}

Two thresholds emerge, and they are far apart:

* **Worth switching on:** exactly $a > 1/3$, the reciprocal of the branching number. Below $1/3$ the guided ascent eventually costs *more* than sweeping the whole level. At $a = 1/2$ it wins at every depth, since $h\,2^h < 3^h$ for all $h$.
* **Competitive:** at height $30$ within a budget of $3000$ visits you need $\alpha^\ast$ with $0.85 < \alpha^\ast \le 0.86$, because $E(30,0.85) \approx 3931 > 3000 \ge 2768 \approx E(30,0.86)$ — exactly $\alpha^\ast = 100^{-1/30} \approx 0.8577$.

Against that floor, the best positional content ever measured for an oracle that *already knows the factorisation* is about $0.48$ bits per step. Everything cheaper is at exactly zero.

{{algorithm:2}}

<details>
<summary><strong>Click to reveal: why brute force is not an escape either</strong></summary>

Because the letters are unreadable from $N$, an adversary may place the target anywhere on level $h$. Any searcher visiting fewer than $3^h$ nodes provably misses one; below half the level it misses a strict majority; and adaptivity gains nothing, since the only feedback before a hit is "miss". Exhaustive search to depth $30$ visits $(3^{31}-1)/2 > 10^{14}$ nodes.

Worse, depth is expensive to reach: along the pure-$A$ spine the word of length $k$ lands on $(k+2,k+1)$, whose hypotenuse is $2k^2+6k+5$ — depth grows like $\sqrt{N}$, not $\log N$.
</details>

---

## 7. Decoding an address, when you already have the node

For completeness, here is the easy direction: given the node, the address is read off in a handful of comparisons. It is exact, it is fast, and it is useless without the node.

{{algorithm:0}}

---

## 8. Run everything

The complete numerical companion reproduces all of it — the four seals, the two refuted conjectures, the two-adic law, and the economics — with assertions that fail loudly if any claim is off.

{{demo:0}}

---

## 9. A methodological aside worth more than the negative result

Early rounds of this investigation "detected" signal by comparing sensors against a **row-shuffle null**: permute the labels, re-measure, and call the gap significance. For a deterministic function of $N$ this null is simply wrong. Tree position correlates with $|N|$ (deeper nodes are bigger), so shuffling destroys a shared dependence on magnitude and any sensor that merely tracks $|N|$ scores as informative.

The correct null **conditions on magnitude** — compare only within a decile of $\log N$. Under that null the promising spectral summaries collapsed to what the theorems say they are: mirrors of $|N|$, carrying nothing about position. Two habits follow: derive before you validate (ask whether the sensor factors through a quantity already known to be blind), and treat an implausibly successful pilot as a *mechanism detector*, not a discovery.

---

## 10. What would reopen the question

A probe that is **none** of the four sealed kinds — not a function of $N \bmod M$ for any $M$, not a Gauss-sum readout, not a structural constant, and not a function of $N$ at all — that is non-monotone in $|N|$, and that delivers per-step accuracy above $\approx 0.86$ at a cost of at most $3000$ visit-equivalents. Since the letter provably is not a function of $N$, such a probe must consume side information: partial factorisation data, class-group information for the Gaussian integers, or a quantum resource.

The tree keeps its perfect addresses. It just will not tell you yours.
