# The Wrong Polynomial That Passed Every Test

*How an experiment on the cubic $x^3-2$ quietly measured the quintic $x^5-2$ instead, why the mix-up went unnoticed, and which statistic finally catches it.*

---

## A mislabelled vial

Every lab has a version of this story. A sample goes into the machine with the wrong label. The machine does its job and the numbers come out. They look fine, and they match what the theory predicts. Only much later does somebody notice that the vial held something else.

This article is about a mathematical version of that story. The instrument was a simple and very old one: pick a polynomial with integer coefficients, reduce it modulo a prime $p$, and count how many solutions it has in the integers mod $p$. Do this for many primes and look at the statistics.

The polynomial that was supposed to go into the machine was

$$x^3 - 2,$$

whose symmetry group (its *Galois group*) is $S_3$, the group of all six ways to shuffle three objects. The polynomial that actually went in was

$$x^5 - 2,$$

whose Galois group is a twenty-element group usually called $F_{20}$. The experiment was meant to test whether certain root-count statistics are "universal", that is, the same for every polynomial of this kind. The answer that came back was *yes, they match*. That answer was true. It was also about the wrong polynomial.

The interesting question is not *who swapped the vials*. It is **why the swap was invisible**, and **what measurement would have caught it**. Both questions have short, exact answers, and those answers show a lot about how symmetry controls arithmetic.

---

## Counting roots, one prime at a time

Start with the measurement. Fix a prime $p$ and ask how many integers $x$ between $0$ and $p-1$ satisfy

$$x^3 \equiv 2 \pmod p.$$

At $p = 31$ there are three such $x$: $4$, $7$ and $20$ (for example $4^3 = 64 = 2\cdot 31 + 2$). At $p = 23$ there is exactly one, $x = 16$. At $p = 7$ there are none, because the cubes mod $7$ are only $0$, $1$ and $6$.

So a cubic can have $0$, $1$ or $3$ roots mod $p$. It can never have exactly $2$: if two of the three roots are in the field, the third one is too. Doing the same for $x^5-2$ turns up counts of $0$, $1$ and $5$, and nothing else.

That is the first clue. The two polynomials use slightly different **alphabets** of possible answers:

- $x^3 - 2$ answers with letters from $\{0, 1, 3\}$;
- $x^5 - 2$ answers with letters from $\{0, 1, 5\}$.

The two alphabets share $0$ and $1$ and differ only in their **top letter**. We will keep coming back to this.

### Why only these letters?

The reason is short and pretty. Suppose $x_0$ is one solution of $x^n = c$ in the field of integers mod $p$ (or in any finite field), with $c \neq 0$. Any other solution $x$ satisfies $(x/x_0)^n = 1$, so $x/x_0$ is an **$n$-th root of unity**. Conversely, multiplying $x_0$ by any $n$-th root of unity gives another solution. The solutions therefore form a shifted copy of the group of $n$-th roots of unity. There are either **none at all** or **exactly as many as there are $n$-th roots of unity**, and in a field with $q$ elements that number is $\gcd(n, q-1)$.

When $n = \ell$ is prime, $\gcd(\ell, q-1)$ can only be $1$ or $\ell$. That gives the alphabet:

> **Root-count alphabet.** For a prime $\ell$ and a nonzero constant $c$, the equation $x^\ell = c$ has $0$, $1$ or $\ell$ solutions in a finite field with $q$ elements. It has *exactly one* when $\ell$ does not divide $q-1$, because then $x \mapsto x^\ell$ is a bijection. When $\ell$ divides $q-1$ it has $0$ or $\ell$.

This explains the three sample primes. $23 - 1 = 22$ is divisible by neither $3$ nor $5$, so **both** polynomials have exactly one root mod $23$. At that prime the wrong polynomial gives exactly the reading the right one would. $31 - 1 = 30$ is divisible by both $3$ and $5$. There the cubic splits completely (three roots) and the quintic has none, so a single reading tells them apart.

Then there is $p = 151$. Modulo $151$ the quintic $x^5 - 2$ has **five** roots:

$$22,\ 25,\ 49,\ 90,\ 116.$$

No cubic can ever have five roots mod anything, since a polynomial of degree $n$ has at most $n$ roots in a field. So one reading at $151$ is a certificate: whatever was in the machine, it was not $x^3 - 2$.

The experiment did not report individual readings, though. It reported **averages**.

---

## The averages that could not tell the difference

Here is what the root counts look like over the $75$ primes from $7$ to $397$:

| polynomial | primes with 0 roots | 1 root | top-letter roots |
|---|---|---|---|
| $x^3-2$ | 26 | 38 | 11 (three roots) |
| $x^5-2$ | 14 | 58 | 3 (five roots) |

The distributions are clearly different. The quintic mostly sits at one root and only rarely hits its top letter. Now look at the averages, meaning the mean root count, the mean of its square and the mean of its cube:

| polynomial | mean | mean of square | mean of cube |
|---|---|---|---|
| $x^3-2$ | $0.947$ | $1.83$ | $4.47$ |
| $x^5-2$ | $0.973$ | $1.77$ | $5.77$ |

The first two columns are nearly the same. Anyone checking that the mean is close to $1$ and the mean square is close to $2$ would have passed both polynomials without hesitation. Only the third column shows a clear gap.

This is no accident of small samples. It holds **exactly** in the limit.

---

## Symmetry decides the statistics

The link between root counts and group theory is one of the great theorems of number theory, the **Chebotarev density theorem**. Roughly, it says this. For each prime $p$ (apart from finitely many exceptions) there is a symmetry of the roots called the *Frobenius element*, and the number of roots mod $p$ equals the number of roots this symmetry leaves in place. As $p$ runs over all primes, the Frobenius element visits every symmetry in the Galois group equally often, in a precise statistical sense.

So to predict average root counts, we can forget primes altogether and average **fixed points** over the Galois group.

### One family, two members

The Galois groups of $x^3-2$ and $x^5-2$ are not unrelated. They belong to a single family. Take a finite field $\mathbb{F}_q$ with $q$ elements and consider all maps of the form

$$x \longmapsto a x + b, \qquad a \neq 0.$$

These "affine maps" form a group with $q(q-1)$ elements, written $\mathrm{AGL}(1,q)$. It is the group of symmetries of a line over $\mathbb{F}_q$ that preserve the linear structure. For $q = 3$ it has $6$ elements, and it turns out to be *every* permutation of the three points of $\mathbb{F}_3$. So it is $S_3$, the symmetry group of $x^3-2$. For $q = 5$ it has $20$ elements, and it is exactly $F_{20}$, the symmetry group of $x^5-2$.

The intended measurement and the accidental one are therefore the $q=3$ and $q=5$ cases of one experiment. (Here is why: the roots of $x^\ell - 2$ are $\sqrt[\ell]{2}\,\zeta^i$, where $\zeta$ is a primitive $\ell$-th root of unity and $i$ runs over the integers mod $\ell$. A symmetry can multiply the exponent $i$ by a nonzero number and shift it, which is exactly an affine map of $i$.)

### Counting fixed points of an affine map

When does $ax + b = x$? Rearranging gives $(a-1)x = -b$, and there are three cases:

- $a = 1$ and $b = 0$: the identity map, which fixes all **$q$** points;
- $a = 1$ and $b \neq 0$: a pure shift, which fixes **no** points;
- $a \neq 1$: exactly **one** fixed point, $x = b/(1-a)$.

Now count. The identity occurs once. There are $q - 1$ nonzero shifts. The remaining $(q-2)q$ maps each fix one point. Raising the fixed-point count to the $k$-th power and adding over the whole group gives

$$\boxed{\ \sum_{a\neq 0,\;b} \operatorname{fix}(x\mapsto ax+b)^k \;=\; q^k + q(q-2)\qquad (k\ge 1).\ }$$

That is the **affine moment law**. Divide by the size of the group, $q(q-1)$, to get the average of $\operatorname{fix}^k$:

- $k = 1$: $\dfrac{q^2 - q}{q(q-1)} = 1$.
- $k = 2$: $\dfrac{2q^2 - 2q}{q(q-1)} = 2$.
- $k = 3$: $\dfrac{q^3 + q^2 - 2q}{q(q-1)} = \dfrac{q(q-1)(q+2)}{q(q-1)} = q + 2$.

The first moment is $1$ for every $q$, and the second is $2$ for every $q$. The **third moment is $q+2$**, which gives $5$ for the cubic and $7$ for the quintic, in line with the measured $4.47$ and $5.77$. Since $q+2$ determines $q$, equal third moments force equal field sizes.

This is exactly the pattern in the data. The "universal" behaviour that the experiment was checking is real, but it holds for **every** member of the affine family. It could not have told $S_3$ apart from $F_{20}$, or from $\mathrm{AGL}(1,7)$, $\mathrm{AGL}(1,11)$ and so on.

---

## Why the first two moments are blind

The numbers $1$ and $2$ have a classical explanation that reaches well beyond affine groups.

**The mean is $1$ because of transitivity.** The *orbit-counting lemma* (often called Burnside's lemma) says that the average number of fixed points of a permutation group equals its number of orbits. Affine maps can move any point to any other, so there is one orbit and the average is $1$.

**The mean square is $2$ because of double transitivity.** The square of the fixed-point count of $g$ is the number of ordered *pairs* of points that $g$ fixes. Averaging over the group counts the orbits on ordered pairs. Affine maps can send any pair of distinct points to any other pair of distinct points: to send $(u,v)$ to $(u',v')$, solve two linear equations for $a$ and $b$. So there are exactly two orbits on pairs, the "equal" pairs and the "distinct" pairs, and the average is $2$.

Any statistic that sees only single points and pairs of points will therefore give the same readings for every doubly transitive group. To distinguish $S_3$ from $F_{20}$ you have to look at *triples*. There the groups finally differ. $S_3$ can do anything to three points, but an affine map of $\mathbb{F}_5$ is determined by where it sends two points, so it has much less freedom on triples. The third moment counts orbits on triples, and that is where $q$ appears.

---

## Averages over constants tell a different story

There is a second natural way to average root counts. Instead of fixing the polynomial and varying the prime, fix the field $\mathbb{F}_q$ and vary the constant $c$ in $x^n = c$.

In that setting the mean is still universal. Every element $x$ is a root of exactly one equation $x^n = c$, namely the one with $c = x^n$, so

$$\sum_{c \in \mathbb{F}_q} \#\{x : x^n = c\} = q$$

for **every** exponent $n$. The average number of roots is exactly $1$.

The second moment is **not** universal here. Adding up the squared counts gives

$$\sum_{c\in\mathbb{F}_q} \#\{x : x^n = c\}^2 \;=\; 1 + (q-1)\cdot \gcd(n,\,q-1).$$

In $\mathbb{F}_{31}$, for instance, this is $1 + 30\cdot 3 = 91$ for cubes and $1 + 30\cdot 5 = 151$ for fifth powers. So averaging over constants at one fixed prime *does* separate the two polynomials at the second moment, whereas averaging over primes needs the third. How much a statistic reveals depends on what you average over.

---

## What the mix-up really measured

Putting it all together, the verdict on the accidental experiment is:

1. **The measurement was true.** The prime-averaged root counts of $x^5-2$ really do have mean $1$ and mean square $2$, as the theory of $F_{20} = \mathrm{AGL}(1,5)$ predicts.
2. **It was misattributed.** Those two numbers are not special to $S_3$. They hold for every doubly transitive group, in particular for every $\mathrm{AGL}(1,q)$. The test could not have failed, so passing it tells us nothing about which polynomial was used.
3. **The wrong polynomial is detectable** in three independent ways:
   - the **third moment**: $5$ for the cubic and $7$ for the quintic;
   - the **top letter**: a single prime where the root count is $5$, such as $p = 151$, rules out any cubic;
   - **lucky primes**: at primes like $31$, where $p-1$ is divisible by both $3$ and $5$, the two polynomials can give different single readings. At primes like $23$ they cannot.
4. **$S_3$ is not simply "$F_{20}$ at a smaller size".** For $q = 3$ the affine group is the full symmetric group. For every $q \geq 4$ it is a proper subgroup, since $q(q-1) < q!$. The family has one member that is also a symmetric group, and the accidental measurement landed on a different one.

---

## The larger lesson

A test must be able to fail before passing it means anything. Here a check that looked natural (do the mean and variance of root counts match the prediction?) turned out to be insensitive to exactly the thing it was meant to confirm. The reason was structural: the first $k$ moments of fixed-point counts only register how the group acts on $k$-tuples. Two groups that are equally transitive up to level $k$ look identical through that window.

The fix is equally structural. Know which level of the symmetry hierarchy separates your hypotheses, and measure at that level. For the cubic and the quintic that level is three. The whole distinction is contained in the formula $q + 2$, together with one prime, $151$, where the quintic shows its fifth root.

Several natural questions are left for further work. For every odd prime $\ell$ and every integer $a$ that is not a perfect $\ell$-th power, Chebotarev's theorem makes the third prime-averaged moment of $x^\ell - a$ tend to $\ell+2$. How quickly does it get there, and how many primes does an experiment need before the gap between $5$ and $7$ is statistically unmistakable? Which pairs of groups need exactly $k+1$ moments to be told apart, no more and no fewer? And for Kummer polynomials $x^n - a$ with composite $n$, does the prime-averaged second moment equal the number of divisors of $n$, as the single-field formula above suggests? Each question asks the same thing: how to pass from exact counting in one finite field to averages over all primes.
