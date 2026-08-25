# Reading Numbers in Base Cube

## How a bookkeeping trick beats a two-century-old counting barrier for sums of three cubes

### A famous identity, and its hidden flaw

Start with the simplest possible question about cubes. Which whole numbers can be written as a sum of three cubes of whole numbers, where negative numbers are allowed?

The question is old, stubborn, and — for individual numbers — sometimes brutally hard. Nobody knew a representation of $33$ as a sum of three cubes until 2019, when a computer search turned up

$$33 = 8866128975287528^3 + (-8778405442862239)^3 + (-2736111468807040)^3.$$

But there is one corner of the problem where everything is easy. Take any two integers $a$ and $b$ and let the third cube root be $-a-b$, so that the three roots sum to zero. Expanding gives a clean cancellation:

$$a^3 + b^3 + (-a-b)^3 = -3ab(a+b).$$

This is the **Vieta identity** — the three roots $a$, $b$, $-a-b$ are exactly the roots of a cubic whose quadratic coefficient vanishes, and the identity is the statement that the sum of their cubes equals three times the product. It hands you, for free, an entire two-parameter family of integers you know how to write as a sum of three cubes. Choose $a = 1, b = 2$: you get $1 + 8 - 27 = -18 = -3 \cdot 1 \cdot 2 \cdot 3$. Choose $a = 2, b = 5$: $8 + 125 - 343 = -210$. It never fails.

So here is a natural question, and the one this article is about. **How many different integers does this identity actually produce?** If you let $a$ and $b$ range over all pairs with $|3ab(a+b)| \le N$, you are sweeping out roughly $N^{2/3}$ lattice points — the region $|xy(x+y)| \le N$ in the plane is a cubic-shaped region of area proportional to $N^{2/3}$. If every pair gave a different answer, you would get about $N^{2/3}$ distinct integers below $N$: a fat, satisfying harvest.

They do not give different answers. And the way they fail to is the whole story.

### The six-fold shadow

The first collisions are structural and unavoidable. The value $-3ab(a+b)$ is a symmetric function of the three roots $a$, $b$ and $c = -a-b$ — it is $3abc$ up to sign — and the three roots are interchangeable. Formally, if $V(a,b) = -3ab(a+b)$, then

$$V(a,b) = V(b,a) = V(a,-a-b) = V(-a-b,a) = V(b,-a-b) = V(-a-b,b).$$

Whenever $a$, $b$ and $-a-b$ are pairwise distinct, these are six genuinely different pairs of parameters producing one single value. The map is at best six-to-one.

That much is fixable: just restrict to a fundamental domain, say $1 \le a \le b$, and you have quotiented out the symmetry. Does that make the value map injective?

No. And the counterexample is embarrassingly small:

$$1^3 + 5^3 + (-6)^3 = -90 = 2^3 + 3^3 + (-5)^3.$$

Both $(a,b) = (1,5)$ and $(a,b) = (2,3)$ sit inside the fundamental domain, and both produce $-90$. This is not a symmetry; it is arithmetic. And once you see the mechanism, you see it is everywhere.

### Collisions are divisor collisions

Here is the mechanism. Suppose $3ab(a+b) = v$ with $a, b$ positive. Then $a$ divides $v$. And once $a$ is fixed, $b$ is determined, because for each fixed positive $a$ the function $b \mapsto 3ab(a+b)$ is strictly increasing — a bigger $b$ gives a strictly bigger value, so no two $b$'s can tie.

That gives a sharp structural statement:

> **Divisor bound for multiplicity.** For a positive integer $v$, the number of ordered pairs of positive integers $(a,b)$ with $3ab(a+b) = v$ is at most $d(v)$, the number of divisors of $v$.

The number of solutions is governed by the divisor function. And this is both good news and bad news.

The good news: since $d(v)$ grows slower than any power of $v$, the $\sim N^{2/3}$ lattice points can only be collapsing by a sub-polynomial factor. Morally, the Vieta identity really should produce $\approx N^{2/3}$ distinct integers, and numerical experiment agrees: counting positive values of $3ab(a+b)$ up to $N$, one finds about $0.53\,N^{2/3}$ of them.

The bad news is that *proving* a lower bound requires exhibiting a family you can certify is collision-free, and the divisor mechanism fights you at every turn. To make the value $v$ determine the parameter $a$, you must sparsify the $a$'s — restrict to powers of two, or to smooth numbers, or to primes. But the moment you sparsify, the number of surviving pairs is a sum like $\sum_a \sqrt{N/a}$ over a thin set of $a$'s, and that sum converges. You are back to $\sqrt{N}$.

That is exactly what the provable subfamilies deliver.

**The spine.** Freeze $a = 1$. The values are $3b(b+1)$, strictly increasing in $b$, so distinct $b$'s give distinct values. Counting them: if $3m(m+1) \le N$ then at least $m$ positive integers up to $N$ arise. Choosing $m$ as large as possible gives

> **Square-root lower bound.** At least $\lfloor\sqrt{N/6}\rfloor$ positive integers $\le N$ are values of the Vieta identity, and each comes with **three nonzero cubes** — no padded $0^3$. Counting negative values too, at least $2\lfloor\sqrt{N/6}\rfloor$ integers of absolute value $\le N$.

**The dyadic family.** One can do a genuinely two-parameter version: take $a = 2^i$ with $i \ge 1$, and $b$ odd. The value is $3 \cdot 2^i \cdot b \cdot (2^i + b)$. Since $b$ is odd and $2^i$ is even, the factor $3b(2^i+b)$ is odd, so the exponent of $2$ in the factorization of the value is *exactly* $i$: the value announces its own layer. Read off $i$ from the $2$-adic valuation, then recover $b$ by monotonicity. Injective. The resulting count is $I\cdot m$ distinct values below $6\cdot 2^I m(2^I + 2m)$ — genuinely two-dimensional bookkeeping, but still, when you optimize, of square-root order.

So the situation is: the truth is $N^{2/3}$, the provable bound is $N^{1/2}$, and the gap is caused by a divisor function. This is not a false statement waiting for a cleverer argument about the same family. It is a signal that you need a different family.

### The idea: read the number in base cube

Forget Vieta. Here is the trick that breaks the barrier.

Consider the gap between consecutive cubes:

$$(z+1)^3 - z^3 = 3z^2 + 3z + 1.$$

Suppose someone hands you a number $n$ and promises it has the form $n = z^3 + r$ with the remainder $r$ *strictly smaller than that gap*. Then you can recover $z$ and $r$ from $n$ alone, with no further information: $z$ is the integer cube root of $n$, because $z^3 \le n < (z+1)^3$. This is the **cube-digit principle**, and it is the whole engine:

> **Cube-digit uniqueness.** If $r < 3z^2+3z+1$ and $r' < 3z'^2+3z'+1$ and $z^3 + r = z'^3 + r'$, then $z = z'$ and $r = r'$.

The proof is one line: if $z < z'$ then $z^3 + r < z^3 + 3z^2+3z+1 = (z+1)^3 \le z'^3 \le z'^3 + r'$, a contradiction, and symmetrically.

It is exactly the argument that makes decimal notation work. In base ten, the digits of a number are recoverable because each digit's contribution is smaller than the place value above it. Here the "places" are cubes, and the requirement is that everything below a given cube fits inside the gap above it.

Now iterate. Build a sum of three cubes $x^3 + y^3 + z^3$ where the scales are chosen so that:

- $x^3$ fits inside the gap at $y$, i.e. $x^3 < 3y^2+3y+1$;
- $x^3 + y^3$ fits inside the gap at $z$, i.e. $x^3+y^3 < 3z^2+3z+1$.

Then reading the value is a two-step greedy peel: the value's integer cube root is $z$; subtract $z^3$; the remainder's integer cube root is $y$; subtract $y^3$; what is left is $x^3$. Three cubes in, three cubes out — the map is injective.

The condition "$x^3$ smaller than the gap at $y$" means roughly $x^3 \lesssim y^2$, i.e. $x \lesssim y^{2/3}$. Likewise $y \lesssim z^{2/3}$. Each scale is the two-thirds power of the one above it. That is the entire arithmetic of the construction, and it dictates the exponent.

### The three-scale box

Put $z$ at scale $t^9$, so $y$ at scale $(t^9)^{2/3} = t^6$, and $x$ at scale $(t^6)^{2/3} = t^4$. Concretely, take the box of integer triples

$$1 \le x \le t^4, \qquad t^6 \le y < 2t^6, \qquad 2t^9 \le z < 3t^9.$$

Check the two gap conditions. For the first: $x^3 \le t^{12}$ and $3y^2 \ge 3t^{12}$, so $x^3 < 3y^2 + 3y + 1$ comfortably. For the second: $x^3 + y^3 \le t^{12} + 8t^{18} < 12 t^{18}$ while $3z^2 \ge 12t^{18}$, again comfortably. (This is why the windows are placed at $[t^6, 2t^6)$ and $[2t^9,3t^9)$ rather than starting at zero: pushing $z$ out to $2t^9$ buys the factor of $4$ in $3z^2$ that pays for the $8t^{18}$ coming from $y^3$.)

Now count. The box contains exactly

$$t^4 \cdot t^6 \cdot t^9 = t^{19}$$

triples, all with positive coordinates, and every value $x^3+y^3+z^3$ is at most $t^{12} + 8t^{18} + 27t^{27} \le 36\,t^{27}$. Injectivity means those $t^{19}$ triples give $t^{19}$ *distinct* integers. Therefore:

> **Cube-digit counting theorem.** For every $t \ge 1$, at least $t^{19}$ positive integers not exceeding $36\,t^{27}$ are sums of three positive cubes.

Set $N = 36t^{27}$. Then $t^{19} \approx (N/36)^{19/27}$, so the count is of order $N^{19/27}$ with

$$\frac{19}{27} = 0.7037\ldots$$

Filling the gaps between the sample scales — round $t$ down from $(N/36)^{1/27}$, and note that doubling $t$ moves $N$ by at most $2^{27}$ — upgrades this to a bound valid for *every* $N \ge 36$:

$$\#\{\,n \le N : n = x^3+y^3+z^3,\ x,y,z \ge 1\,\} \;\ge\; \left(\frac{N}{36\cdot 2^{27}}\right)^{19/27}.$$

And the comparison with the barrier is explicit and elementary: for $t \ge 4$ and $N = 36t^{27}$,

$$100\sqrt{N} \le t^{19},$$

so the cube-digit count exceeds a hundred times the square root — and by the same argument, any fixed multiple of $\sqrt{N}$ is eventually left behind. The barrier is broken, not by cleverness about Vieta, but by refusing to play Vieta's game.

One point of hygiene deserves emphasis: **every cube in the construction is positive**. It is easy to inflate counts of "sums of three cubes" by padding with $0^3$ — that would reduce the problem to sums of two cubes, or even one. Nothing here is padded.

### Two numbers Vieta can never reach

Is the cube-digit family merely bigger, or is it genuinely somewhere else? Here is a clean way to see that it is somewhere else.

Every Vieta value is divisible by $6$. Indeed $-3ab(a+b)$ is visibly divisible by $3$, and $ab(a+b)$ is always even: if $a$ or $b$ is even we are done, and if both are odd then $a+b$ is even. So:

> **The Vieta ceiling.** Every value of the identity is a multiple of $6$; hence at most $\lfloor N/6\rfloor$ positive integers up to $N$ are Vieta values.

Combined with the spine bound, this sandwiches the Vieta counting function between $\lfloor \sqrt{N/6}\rfloor$ and $\lfloor N/6 \rfloor$.

Now run the cube-digit construction with all three cube roots restricted to the residue class $1 \bmod 6$ — that is, use roots $6u+1$, $6v+1$, $6w+1$ and re-tune the windows to $1 \le u \le t^4$, $4t^6 \le v < 8t^6$, $34t^9 \le w < 68t^9$ so that the two gap inequalities still hold with the enlarged constants. Since $n^3 \equiv n \pmod 6$ for every integer $n$, each of the three cubes is $\equiv 1$, so every value is $\equiv 3 \pmod 6$: never a multiple of $6$, hence never a Vieta value.

> **Escape theorem.** For every $t \ge 1$ there are at least $136\,t^{19}$ integers in $[1, 10^8 t^{27}]$ which are sums of three positive cubes but are not values of the Vieta identity for any pair of integers whatsoever.

So the new family is not a refinement of the old one. It lives in a residue class the old one cannot enter, and it is polynomially larger.

### Climbing the tower

The cube-digit principle does not care that there were three cubes. Add a fourth, a fifth, an $s$-th: at each stage, place the new cube at a scale whose square dominates everything beneath it, and the greedy peel still recovers all the digits.

Running this induction — at each step replacing the scale parameter $t$ by $t^2$, and tracking the size constants through the recursion $C_0 = 1$, $C_{s+1} = 8C_s^3 + C_s$ — gives a clean general theorem.

> **Greedy cube tower.** For every $s \ge 1$ and every $t \ge 1$, at least $t^{\,3^s - 2^s}$ positive integers below $C_s\, t^{\,3^s}$ are sums of exactly $s$ positive cubes. Equivalently, for all $N \ge C_s$,
> $$\#\{\,n\le N : n \text{ is a sum of } s \text{ positive cubes}\,\} \;\ge\; \left(\frac{N}{C_s\, 2^{3^s}}\right)^{1-(2/3)^s}.$$

The exponent is

$$\frac{3^s - 2^s}{3^s} = 1 - \left(\frac{2}{3}\right)^{s},$$

and the pattern of the first few values tells the story: $s = 2$ gives $5/9 \approx 0.556$, $s = 3$ gives $19/27 \approx 0.704$, $s = 4$ gives $65/81 \approx 0.802$, and the exponents increase to $1$. Each additional cube recovers two thirds of the remaining deficit. In the limit, sums of many positive cubes have positive density in the counting sense — which is what one expects, but here it comes out of a single, completely elementary recovery principle rather than from circle-method machinery.

### What is still out of reach

The honest summary of the situation is a story about two exponents.

For the Vieta family itself, the truth is believed — and numerically observed — to be $\asymp N^{2/3}$, with the positive-side constant near $0.53$. What is *proved* is $N^{1/2}$ from below and $N/6$ from above. The obstruction is precise and identified: the divisor bound $d(v)$ converts the problem into a divisor-moment estimate, and any bound of the form $d(v) \ll_\varepsilon v^{\varepsilon}$ would immediately upgrade the lower bound to $N^{2/3-\varepsilon}$. Nothing deep is needed — no Thue equations, no class field theory — only an elementary multiplicative-function estimate applied at the right place.

For sums of three positive cubes in general, the cube-digit exponent $19/27 \approx 0.704$ is what the greedy principle gives. The conjectural truth is a positive proportion — a positive density of integers should be sums of three cubes, subject only to the congruence obstruction $n \not\equiv \pm 4 \pmod 9$ — and that remains far beyond reach. But $19/27$ is a real, unconditional, explicitly constructive foothold, and its proof fits in a page.

The moral is one worth carrying away from any counting problem. The Vieta identity is beautiful and it is the wrong tool, because its collisions are governed by an object — the divisor function — you cannot control by choosing parameters. The cube-digit family is not beautiful in the same way; it is a stack of carefully spaced windows. But its collisions are governed by nothing at all, because there are none, and injectivity by construction beats elegance by identity every time you are counting.
