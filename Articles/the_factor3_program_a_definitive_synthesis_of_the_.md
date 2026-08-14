# The Free Lunch That Isn't: Why Every Shortcut to Factoring Leads Back to the Same Wall

## A number that keeps a secret

Take two prime numbers, multiply them together, and hand me the answer. If the primes are small, I will find them in seconds. If they are three hundred digits long, I will not find them before the sun burns out — and neither will anyone else, using any method currently known. That asymmetry is the load-bearing wall of modern digital life. It is why your bank's certificate is trustworthy and why your messages stay yours.

The strange thing is that we cannot prove the wall is there. We have merely failed, for half a century, to walk through it. And every failure has a family resemblance to every other failure. Try enough different attacks and you begin to suspect you are not hitting many walls but one wall, from many angles.

This article is about making that suspicion precise. It concerns a class of would-be shortcuts — the *counting attacks* — and a pair of theorems that say, together: every counting attack in the class either tells you the entire secret at once, or tells you nothing at all; and the ones that tell you everything cost exactly as much to compute as the brute-force search they were supposed to replace.

The free lunch exists. You just cannot get to the restaurant.

## Counting your way to a factorization

Here is the shape of nearly every clever idea in the field. You want the factors $p$ and $q$ of $N = pq$. You cannot see them directly, so instead you count something — points on a circle, roots of a polynomial, representations by a quadratic form, solutions of a congruence — and you hope the count carries a fingerprint of $p$ and $q$.

The simplest such count is the *divisor sum*. Give every divisor $d$ of $N$ a numerical weight $w(d)$ and add them up:
$$A_w(N) \;=\; \sum_{d \mid N} w(d).$$
For instance, with $w(d) = d$ this is the classical sum-of-divisors function; with $w(d) = d^2$ it is the sum of the squares of the divisors.

The magic ingredient is *multiplicativity across coprime pieces*. Call $w$ a **CRT weight** if $w(1) = 1$ and
$$w(mn) = w(m)\,w(n) \qquad \text{whenever } m \text{ and } n \text{ share no common factor.}$$
The name honours the Chinese Remainder Theorem, which is what makes such weights natural: they respect the decomposition of the world modulo $N$ into a world modulo $p$ times a world modulo $q$.

For a CRT weight and a semiprime $N = pq$ with $p \ne q$, the divisor list is exactly $1, p, q, pq$, and the aggregate collapses beautifully:
$$A_w(pq) \;=\; 1 + w(p) + w(q) + w(p)w(q) \;=\; \bigl(1 + w(p)\bigr)\bigl(1 + w(q)\bigr).$$
This is the *factorization through the CRT splitting*. One number on the left; a product of two local contributions, one from each prime, on the right. The aggregate is a mirror in which both factors appear simultaneously.

That already dodges an obstacle that kills many naive attacks. A quantity built symmetrically from $N$ alone, with no memory of how $N$ was assembled, cannot possibly distinguish $3 \times 11$ from $33 \times 1$; it is *factorization-insensitive*. The CRT aggregate is not like that. Both $p$ and $q$ leave their marks, and the marks are separable.

## The trace and the norm

Now watch a two-hundred-year-old trick do the heavy lifting.

Set $x = w(p)$ and $y = w(q)$. From the identity above, if you know $A_w(N)$ then you know
$$x + y \quad \text{(after subtracting off } 1 + w(N)\text{)},$$
and you already know
$$xy = w(p)w(q) = w(pq) = w(N),$$
because $w$ is a CRT weight and you were handed $N$. A sum and a product. Every schoolchild who has met the quadratic formula knows what comes next: a pair of numbers is completely determined by its sum and its product.

In the language of field theory, the sum is the **trace** and the product is the **norm**. The norm is public — it is just $w(N)$. The trace is the secret. And the aggregate hands you the trace.

Made precise, this is the **Trace Lemma**:

> *Let $w$ be a CRT weight that is strictly increasing. Fix $N$ and suppose $N = ab = a'b'$ are two factorizations into coprime pairs with $a \le b$ and $a' \le b'$. If the two aggregates agree, $(1+w(a))(1+w(b)) = (1+w(a'))(1+w(b'))$, then $a = a'$ and $b = b'$.*

The proof is three lines of honest algebra. Multiplicativity forces $w(a)w(b) = w(N) = w(a')w(b')$: the norms agree. Expanding the aggregate equation and cancelling the common norm term forces $w(a) + w(b) = w(a') + w(b')$: the traces agree. Sum and product determine the pair, so $w(a) = w(a')$; strict monotonicity makes $w$ injective, so $a = a'$, and then $b = b'$ by division.

The moral is stark. There is no such thing as a *partially* informative CRT aggregate. It does not leak a hint about the factorization that you must then work to amplify. It leaks the factorization, whole. The witness *is* the secret, wearing a coordinate change.

## A prediction that came true

Theories earn their keep by predicting things nobody looked for. This one did.

Consider the weight $w(d) = d^2$, whose aggregate is $\sigma_2(N) = \sum_{d \mid N} d^2$. On a semiprime,
$$\sigma_2(pq) = (1 + p^2)(1 + q^2) = 1 + p^2 + q^2 + N^2.$$
Subtract the known quantities $1$ and $N^2$, and out drops $p^2 + q^2$ — a value that looks, on its face, like a weaker piece of information than $p+q$. It is not. Add $2N = 2pq$ and you get $(p+q)^2$; take a square root and you have the trace; feed the trace and the norm into the quadratic formula
$$p \;=\; \frac{(p+q) - \sqrt{(p+q)^2 - 4N}}{2},$$
and the smaller prime falls out after a handful of arithmetic operations. Everything is exact integer arithmetic — no approximation, no search.

So $p^2 + q^2$ is exactly as good as knowing the factorization, and the theory said so before anyone checked. The same argument works for every exponent $k \ge 1$, because a sharper version of the trace lemma holds for power weights: among *all* factorizations $N = ab$ with $a \le b$ — not merely the prime one — the value $a^k + b^k$ determines the pair. The reason is a monotonicity principle worth stating on its own:

> **Spread monotonicity.** If $ab = a'b'$ with $a < a' \le b' < b$, then $a'^k + b'^k < a^k + b^k$ for every $k \ge 1$.

The more lopsided the factorization, the larger its power sum. Rectangles of equal area: the long thin one has the longer perimeter. Since the power sum is strictly monotone along the hyperbola $xy = N$, distinct factorizations cannot share a value.

## The dichotomy: everything or nothing

What if the weight is not monotone? What if it collides — two different primes $p \ne p'$ with $w(p) = w(p')$?

Then the attack dies instantly, and it dies *unconditionally*. Pick a prime $q$ larger than both. The semiprimes $pq$ and $p'q$ have aggregates
$$(1 + w(p))(1 + w(q)) \quad\text{and}\quad (1 + w(p'))(1 + w(q)),$$
which are equal — while their smaller prime factors are different. So no function whatsoever of the aggregate value can return the smaller factor: any such function would have to output two different numbers from the same input. This is not a statement that a particular algorithm fails. It is a statement that *no algorithm exists*, however ingenious, however slow, because the information simply is not present.

Put the two branches together and you get the **classification**:

> *Every CRT weight is of exactly one of two kinds. Either it separates primes — and then, if it is also monotone, its aggregate pins the factorization completely, recoverable in a constant number of arithmetic operations. Or it collides on two primes — and then no function of its aggregate can ever return a factor.*

There is no third behaviour. No middle ground. No weight that leaks a useful trickle. This is the sense in which nine structurally unrelated computational experiments — counting lattice points on circles, counting roots, counting binary quadratic form representations, counting cusps, counting Reed–Solomon distances — turned out to be *one mechanism*. They are all CRT aggregates. They all fell on one of the two sides.

## Where the class ends

A classification is only as good as its boundary. Which weights are CRT weights?

Power functions are, trivially: $(mn)^k = m^k n^k$ always. What about the other great family of weights in analytic number theory, the exponential phases $x \mapsto z^x$ that power Fourier analysis and Gauss sums? Surely those, with their beautiful oscillation, are the real hope?

They are not even in the class, and the proof is a single evaluation. Suppose $z^{mn} = z^m z^n$ for all coprime $m, n$. Take $m = 2$, $n = 3$: then $z^6 = z^2 z^3 = z^5$, and dividing by $z^5$ (assuming $z \ne 0$) gives $z = 1$. The only CRT-multiplicative exponential phase is the constant one.

This is the **characters-only boundary**. Exponential phases add exponents; the CRT splitting multiplies arguments. The two operations are incompatible. Only genuine multiplicative characters decompose through the Chinese Remainder Theorem, and the classification therefore covers exactly the natural class of counting attacks — no more, and no less.

## The catch, and it is fatal

We have a witness that is worth everything. Why is factoring still hard?

Because the witness is not free. To evaluate $\sum_{d \mid N} w(d)$ you have to know the divisors of $N$, which is the problem you were trying to solve. Any honest evaluation is a *sweep*: you probe candidate values $d = 2, 3, 4, \ldots$ and see which ones divide $N$. And here the geometry of the divisor hyperbola turns cruel.

Look at the window of probes from $2$ up to $\sqrt{N}$. For a semiprime $N = pq$ with $p < q$, exactly one probe in that entire window is a divisor: $p$ itself. ($q$ lies above $\sqrt N$, and $1$ and $N$ are outside or useless.) The window contains $\sqrt{N} - 1$ candidates. The density of useful probes is
$$\frac{1}{\sqrt N - 1}.$$
That is the **noise floor**. Signal one, noise $\sqrt N$.

For the cryptographically relevant case — *balanced* semiprimes, where $p < q \le 2p$, so both primes sit near $\sqrt N$ — the statement sharpens into a theorem with an explicit constant. If any probe window $[2, m]$ contains a nontrivial divisor at all, then $N \le 2m^2$, so $\sqrt N \le \sqrt 2 \, m$: the sweep must already have reached the birthday scale $\sqrt{N/2}$ before it can possibly succeed. And no window, however long, can contain more than two factor-bearing probes, since $N$ has only two nontrivial divisors. Dividing the bounded numerator by the forced denominator gives the

> **Noise-Floor Principle.** For a balanced semiprime $N = pq$, the density of factor-bearing probes in any window that succeeds at all is at most
> $$\frac{2\sqrt 2}{\sqrt N}.$$

And the cost is pinned from both sides: the sweep length $p$ satisfies $\sqrt{N/2} \le p \le \sqrt N$. Aggregation costs $\Theta(\sqrt N)$ — which is, digit for digit, the cost of trial division.

This is the punchline that makes the whole framework more than a catalogue of failures. The *aggregation barrier* — the obstruction that stops counting attacks — and the *birthday bound* — the obstruction that stops brute-force search — are not two obstacles that happen to have similar size. They are the same obstacle. The counting attack was never a shortcut; it was trial division in a wig.

Nor can you dodge by fixing a clever set of probes in advance. For any finite probe set $S$, there is a semiprime $N = pq$ whose nontrivial divisors are both larger than everything in $S$ — take $p$ beyond $\max S$ and $q$ beyond $p$. A probe set that works for all $N$ must grow with $N$.

## The tropical picture

There is a change of coordinates that makes all of this visible at a glance.

*Tropical arithmetic* replaces addition by taking a minimum and multiplication by ordinary addition. In these min-plus coordinates, the multiplicative constraint $ab = N$ becomes a *tropical line*: a bent, piecewise-linear curve whose two rays meet at a corner. The corner sits at $a = b = \sqrt N$, the balanced point.

Every factorization of $N$ is a point on this line. The classical trace $a + b$ has a clean tropical meaning: it is *minimized at the corner*. Formally, among factorizations $N = ab = a'b'$ with $a \le b$, $a' \le b'$, and $a \le a'$, one has $a' + b' \le a + b$ — the more balanced pair has the smaller sum. The trivial factorization $N = 1 \cdot N$ sits at the far end of a ray with trace $1 + N$; the prime factorization sits at trace $p + q$, and $p + q < 1 + N$ always. The corner sees the factors; nothing else does.

So here is the whole story in one image. The factoring secret is *a position on a tropical line*. The trace lemma says that the position is all there is — pin it and you are done, and every counting witness in the class is just a relabelling of the coordinate along the line. The aggregation barrier says the position lies within a factor $\sqrt2$ of the corner, and that finding the corner requires sweeping a window of length $\Theta(\sqrt N)$.

The secret is one number. The number is exactly where you would guess. And getting there costs the same as guessing.

## What this does and does not settle

Let us be scrupulous. None of this proves that factoring is hard. That question remains open, and this framework does not close it. There is a quantum algorithm — Shor's — that factors in polynomial time, so no unconditional classical hardness proof can appeal to anything a quantum computer can also do; and on the classical side, no proof of hardness is known.

What the framework does establish is a *complete and predictive* account of one large, natural family of approaches. Within the class of CRT-multiplicative counting aggregates, the situation is now fully mapped: the boundary of the class is known (characters, not phases); the behaviour inside it is a strict dichotomy (everything or nothing); the "everything" branch comes with an explicit constant-time recovery formula; and the "everything" branch is sealed by a quantitative cost bound that coincides exactly with brute force. A theory that says *there is nothing new here, and here is the proof* is worth a great deal, because it tells the next researcher where not to dig.

And it made a prediction that held: that the sum of squares of the primes, $p^2 + q^2$, would be a complete witness. It is.

## The shape of the frontier

What would it take to go further? The classification currently covers weights that are multiplicative across the CRT splitting. The dream is to widen it: to show that *every* efficiently computable counting function that respects the CRT splitting is either factorization-insensitive or reduces to a factor-secret coordinate with efficient recovery. That would upgrade the aggregation barrier from a robust empirical regularity to a theorem equivalent, in a precise sense, to the hardness of factoring itself.

The other half is the noise floor. Right now it is a theorem for balanced semiprimes and divisor probes, and an extremely well-attested empirical principle everywhere else — observed independently in leak-density calculations for circle problems, in the classical error term for prime distribution in arithmetic progressions, in divisor-sum error terms, and in the statistics of Pythagorean-triple trees, all landing on the same $c/\sqrt N$ scale. Turning that coincidence into a general theorem is the natural next target.

Until then, the state of the art is this: we know why the clever ideas fail, we know they all fail for one reason, and we can prove that the reason is the same wall the dumb idea hits. That is not a proof that the wall is unbreakable. But it is a very good map of the wall.
