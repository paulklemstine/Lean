# The Beautiful Trap: Why Singular Moduli Almost Break RSA

## A gift from the nineteenth century

Every so often, number theory hands cryptography a gift that looks too good to be true.

Here is one of them. Take a negative integer $D \equiv 0, 1 \pmod 4$ — say $D = -163$ — and consider the number

$$e^{\pi\sqrt{163}} = 262537412640768743.99999999999925\ldots$$

It is famously, absurdly close to an integer. This is not a coincidence, and the explanation is one of the deepest structures in classical mathematics: the theory of **complex multiplication**. The near-integer above is a shadow of the fact that the *singular modulus* $j\left(\frac{1+\sqrt{-163}}{2}\right)$ is exactly the integer $-262537412640768000$.

More generally, for each discriminant $D < 0$ there is a monic polynomial with integer coefficients,

$$H_D(X) \in \mathbb{Z}[X],$$

the **Hilbert class polynomial**, whose roots are precisely the singular moduli of discriminant $D$. Its degree is the *class number* $h(D)$ — the number of essentially different ways of writing quadratic forms of discriminant $D$. The first few are wonderfully concrete:

$$H_{-4}(X) = X - 1728, \qquad H_{-7}(X) = X + 3375, \qquad H_{-11}(X) = X + 32768,$$
$$H_{-15}(X) = X^2 + 191025\,X - 121287375, \qquad H_{-163}(X) = X + 262537412640768000.$$

Now here is the gift. Reduce $H_D$ modulo a prime $p$. A classical theorem of Deuring says that $H_D$ splits into linear factors modulo $p$ exactly when $p$ is represented by a quadratic form of discriminant $D$ — equivalently, when $4p = u^2 + |D|v^2$ has a solution. When it splits, it has exactly $h(D)$ roots in $\mathbb{F}_p$, and each root is the $j$-invariant of an elliptic curve over $\mathbb{F}_p$ with complex multiplication by the order of discriminant $D$.

So the roots of $H_D$ modulo $p$ are a **highly structured, arithmetically meaningful set** attached to the prime $p$. And structure, in cryptography, is danger.

## The attack that works

Suppose you are handed an RSA modulus $N = pq$, the product of two large unknown primes, and asked to factor it. Complex multiplication suggests an attack of striking simplicity:

> Pick a discriminant $D$. Pick an integer $j_0$. Compute
> $$\gcd\big(H_D(j_0),\, N\big).$$
> If the answer is neither $1$ nor $N$, you have factored $N$.

The intuition is exactly right. If $j_0$ happens to be a root of $H_D$ modulo $p$ — that is, if $j_0$ is the $j$-invariant of a CM curve over $\mathbb{F}_p$ — then $p$ divides $H_D(j_0)$. If simultaneously $j_0$ is *not* a root modulo $q$, then $q$ does not divide it, and the greatest common divisor is exactly $p$. The unknown prime falls out.

And this is not a fantasy. It works. Here is a real run: take $N = 5183$, discriminant $D = -11$, evaluation point $j_0 = 9$. Then $H_{-11}(9) = 9 + 32768 = 32777$, and

$$\gcd(32777,\ 5183) = 73,$$

so $5183 = 71 \cdot 73$. Or take $N = 77$ and the class-number-two polynomial $H_{-15}$ at $j_0 = 0$: the value is $-121287375$, and $\gcd(121287375, 77) = 11$. Or $N = 3599$ with $H_{-19}$ at $j_0 = 8$: $\gcd(884744, 3599) = 61$, giving $3599 = 59 \cdot 61$.

In a systematic sweep over the discriminants $-4, -7, -8, -11, -15, -19, -20, -23$ and evaluation points $j_0 = 0, 1, 2, \ldots$, every one of a batch of test semiprimes up to $N = 39203$ factored, using between $2$ and $131$ evaluations. The method is real. It is not a heuristic that "sometimes works." Every single instance factored.

The question is not *whether* it works. The question is **how fast it works as $N$ grows** — and that is where the story turns.

## Counting exactly, not guessing

Most analyses of factoring algorithms are heuristic: one assumes some quantity behaves like a random variable and computes an expectation. Here we can do far better. The success or failure of an evaluation point can be characterized *exactly*, with no probabilistic modelling whatsoever.

**The Exact Criterion.** Let $N = pq$ with $p \neq q$ prime, and let $H$ be *any* integer polynomial. Then $\gcd(H(j_0), N)$ is a nontrivial factor of $N$ if and only if $j_0$ is a root of $H$ modulo **exactly one** of $p$ and $q$. Moreover in that case the gcd equals precisely that prime.

The proof is a four-way case split. If $j_0$ is a root modulo neither prime, the gcd is $1$. If modulo both, then $pq \mid H(j_0)$ and the gcd is all of $N$ — a total failure, which is worth emphasizing: *too much* success is as useless as none. Only the exclusive-or works.

That "exclusive-or" is the whole story, because it is a condition depending only on $j_0 \bmod p$ and $j_0 \bmod q$ — and the Chinese Remainder Theorem then lets us count the good evaluation points exactly.

**The Exact Count.** Let $r_p$ and $r_q$ be the number of roots of $H$ modulo $p$ and modulo $q$. Then the number $S$ of residues $j_0 \in [0, N)$ at which the method succeeds is

$$S \;=\; r_p\,(q - r_q) \;+\; (p - r_p)\,r_q.$$

This is an identity, not an estimate. Test it: for $N = 77 = 7 \cdot 11$ with $D = -15$, one computes $r_7 = 1$ and $r_{11} = 2$, so $S = 1 \cdot 9 + 6 \cdot 2 = 21$. Exhaustively checking all $77$ residues gives exactly $21$ hits. For $N = 221 = 13\cdot 17$ with the same discriminant, $r_{13} = 1$ and $r_{17} = 0$, so $S = 17$, and the expected number of random evaluations is $221/17 = 13$.

Now comes the fatal step. Lagrange's theorem says a monic polynomial of degree $h$ has at most $h$ roots modulo a prime. So $r_p \le h$ and $r_q \le h$, and therefore

$$S \;\le\; h\,(p+q).$$

Out of $N = pq$ possible evaluation points, at most $h(p+q)$ of them work. The useful set is a *needle-thin sliver* of the search space.

## The $\sqrt{N}$ barrier

For an RSA modulus, $p$ and $q$ are deliberately chosen to be of comparable size — say $p \le q \le 3p$. Then $p + q \le 4\sqrt{pq} = 4\sqrt{N}$, and the density of useful evaluation points is at most

$$\frac{S}{N} \;\le\; \frac{4h}{\sqrt{N}}.$$

A uniformly random evaluation point therefore succeeds with probability at most $4h/\sqrt{N}$, and the expected number of evaluations before a success is at least

$$\frac{\sqrt{N}}{4h}.$$

That is the barrier. It is a hard theorem, not a heuristic: no probabilistic assumption about singular moduli enters, only Lagrange plus the Chinese Remainder Theorem.

But a lower bound alone would be consistent with the method never working at all, which would be a cheap victory. So the analysis has a second half, and it is the more interesting one. Suppose $H$ has at least one root modulo $p$ and none modulo $q$ — exactly the favourable configuration the method is designed to exploit. Then the count formula collapses to $S = r_p \cdot q \ge q$, and one gets a *matching upper bound*:

**Two-Sided Scaling Theorem.** For a balanced semiprime $N = pq$ and a monic polynomial $H$ of degree $h$ with at least one root modulo $p$ and none modulo $q$, the expected number of evaluations $N/S$ satisfies

$$\frac{\sqrt{N}}{4h} \;\le\; \frac{N}{S} \;\le\; \sqrt{N}.$$

The method is genuinely $\Theta(\sqrt{N})$. Not better, not worse — no polynomial-time behaviour hides in the constants, and no pathology makes it useless. The experimental data agrees beautifully: across two orders of magnitude of $N$, the observed ratio of evaluations to $\sqrt{N}$ stayed inside the narrow band $0.48$ to $2.0$. Exactly what a $\sqrt{N}$ law predicts, and precisely what it forbids is a ratio decaying like $N^{-c}$.

## Can't we just use a bigger class number?

Look again at the bound $\sqrt{N}/(4h)$. The class number $h$ sits in the *denominator*. Choose a discriminant with an enormous class number, and the number of evaluations plummets. Isn't that the escape?

No — and the reason is elegant. A degree-$h$ polynomial costs at least $h$ multiplications to evaluate (Horner's rule, which is optimal for a generic polynomial). So the total *arithmetic work* is the number of evaluations times the cost of one:

$$\text{work} \;=\; h \cdot \frac{N}{S} \;\ge\; h \cdot \frac{\sqrt{N}}{4h} \;=\; \frac{\sqrt{N}}{4}.$$

**The class number cancels exactly.** The $h$ you gain in fewer trials, you pay back in longer evaluations, with the same exponent. The $\sqrt{N}$ rate is not an artifact of a lossy counting argument; it is a *conservation law* of the construction itself. And this is not a coincidence of Horner's rule: it holds for any cost measure that charges at least $\deg H$ per evaluation.

Two natural variants die the same death. If you try to "aim" at the structured set by reparametrizing — replacing $j_0$ by $g(j_0)$ for some clever monic polynomial $g$ of degree $d$ — you are simply running the method with $H \circ g$, whose degree is $hd$. The density bound degrades by exactly the factor $d$ by which the evaluation cost grew. And if you run many discriminants at once, over a whole family $F$ of monic class polynomials of degree at most $h$, the density of successful (discriminant, point) pairs in the search space $F \times [0,N)$ is *still* at most $4h/\sqrt{N}$. The barrier is not an artifact of using one $H_D$.

## The circularity, made precise

Underneath all of this is a single conceptual obstruction, and it deserves a name: **circularity**.

The useful set is $\{\,j_0 : H_D(j_0) \equiv 0 \bmod p\,\}$. This set is *defined in terms of the very prime $p$ you are trying to find*. You know it is there. You know it is small, structured, arithmetically gorgeous. You cannot point at it.

The obvious way around this would be precomputation: build, once and for all, a giant table $T$ of evaluation points and a family of discriminants, and hope that for any $N$ that comes along, some table entry hits a root modulo one of its factors. Ship the table with the attack software.

This fails, and fails absolutely. The observation is almost embarrassingly simple: a table entry $t$ can only ever detect a prime that *divides the integer $H(t)$*. And a positive integer $n$ has at most $\log_2 n$ distinct prime factors. So the entire set of primes your table can ever catch has size at most

$$\sum_{t \in T} \log_2 |H(t)|,$$

a quantity determined by the **bit size of the table itself**, with no dependence on the modulus $N$ under attack. A gigabyte of precomputed evaluation points catches, at most, a few billion primes — and there are infinitely many primes it cannot see.

**No-Precomputation Theorem.** For every finite family $F$ of class polynomials, every finite table $T$ of evaluation points, and every bound $M$, there exist distinct primes $p, q > M$ such that on $N = pq$, every one of the $|F| \cdot |T|$ precomputed trials returns $\gcd = 1$. The attack learns nothing at all.

So there is no table. There is only search. And search is priced at $\sqrt{N}/(4h)$ evaluations, or $\sqrt{N}/4$ units of work.

## Where this puts singular moduli on the map

Write $x = \log N$ for the bit size. The proven cost profile of the method is

$$C(x) \;=\; \frac{e^{x/2}}{4h}.$$

This function is *superpolynomial*: it eventually outgrows $e^{dx}$-free polynomial bounds, so no choice of parameters makes the method polynomial-time. It is also *not subexponential*: it does not belong to the class $L_N[1/3, c] = \exp\!\big((c+o(1))(\log N)^{1/3}(\log\log N)^{2/3}\big)$ inhabited by the number field sieve. It sits squarely on the exponential rung.

And it eventually dominates $e^{x/4} = N^{1/4}$, the birthday-paradox cost of Pollard's rho. So the classification is complete:

$$\underbrace{\text{Number Field Sieve}}_{L_N[1/3,\,c]} \;\prec\; \underbrace{\text{Pollard rho},\ \text{Pollard } p-1,\ \textbf{singular moduli}}_{\Theta(\sqrt{N})\text{ family}} \;\prec\; \text{trial division}.$$

Singular moduli factoring is a legitimate, working, mathematically beautiful factoring algorithm that lands on exactly the same rung as the two classic $\sqrt{N}$ methods — and *strictly worse* than the sieve that actually threatens RSA.

## One more warning from the data

There is a failure mode the heuristic story quietly conceals. The slogan "$H_D$ modulo $p$ has $h$ roots" is only true when $D$ is a quadratic residue modulo $p$ — when $p$ is represented by a form of discriminant $D$. Otherwise $H_D$ may have *no root at all* modulo $p$, and if that happens modulo both $p$ and $q$ then $\gcd(H_D(j_0), N) = 1$ for **every** evaluation point $j_0$, forever. The method is not slow in that case; it is blind.

This is not hypothetical. In the experimental sweep, the pair $N = 71 \cdot 73 = 5183$ with $D = -23$ has $r_{71} = r_{73} = 0$: the exact success count is $0$, and no evaluation point in the entire range $[0, N)$ works. A clean toy instance is the polynomial $X^2 + 1$, which is irreducible modulo both $7$ and $11$; against $N = 77$, it will never produce a factor no matter how long you run. So the expected-value analysis is always *conditional* on the discriminant being usable at all, and a complete accounting must include the cost of finding one that is.

## The honest conclusion

Let me be precise about what has and has not been shown, because in cryptography the difference matters enormously.

**What is established.** The gcd-of-class-polynomial-values method is exactly a $\sqrt{N}$ method. Its success criterion is an exact exclusive-or condition; its success count is an exact Chinese-Remainder identity; the density of useful evaluation points on a balanced semiprime is at most $4h/\sqrt{N}$ and the expected number of evaluations lies in $[\sqrt{N}/(4h), \sqrt{N}]$; the class-number speed-up is cancelled exactly by evaluation cost; no finite precomputed table works for more than a bounded set of primes; and the resulting cost function is superpolynomial and genuinely exponential.

**What is not established.** Nothing here says that *no* method built from complex multiplication can factor quickly. What is shown is that this particular scheme — evaluate a fixed integer polynomial, take a gcd — is a $\sqrt{N}$ method, in the full generality of an arbitrary monic integer polynomial, arbitrary evaluation points, and arbitrary discriminant families. The counting theorem uses nothing about $H_D$ beyond its degree, which is exactly why it is so robust, and exactly why it does not rule out schemes of a different shape.

Indeed the counting theorem's indifference to the polynomial is an invitation. Substitute division polynomials of elliptic curves for $H_D$ and you get an analysis of ECM-flavoured attacks for free, with $h$ replaced by the degree $(\ell^2-1)/2$. Same rate. Same barrier. And there is a tantalizing quantitative trade-off left open: since $h(D) = O(\sqrt{|D|}\log|D|)$, pushing the class number toward $\sqrt{N}$ requires a discriminant of size roughly $N$, and a polynomial of degree $\sqrt{N}$ that nobody can write down, let alone evaluate. Where exactly that trade-off bites — whether the degree–density duality is a genuine conservation law for *every* cost model — is the natural next theorem.

## Why beautiful mathematics does not break RSA

There is a lesson here that goes well beyond one algorithm.

Complex multiplication is one of the most structured corners of number theory. Its objects — singular moduli, class polynomials, CM curves — are rigid, computable, and carry enormous arithmetic information about primes. It is entirely reasonable to expect that such structure should be a weapon.

And it is a weapon. The attack works, on every instance tested. But the structure it exposes is *indexed by the secret*. The set of useful evaluation points is a perfectly well-defined, beautifully organized subset of $\mathbb{Z}/N$ — organized around the factor $p$ you do not know. Knowing that a needle exists, and even knowing its precise shape, does not tell you where in the haystack it is. You must still look, and there are $\sqrt{N}$ places to look.

That is the deep pattern behind essentially every $\sqrt{N}$ factoring method. Pollard's rho knows that a random walk modulo $p$ collides after $\sqrt{p}$ steps — but it cannot see modulo $p$. Pollard's $p-1$ knows that $p-1$ is smooth for some primes — but it cannot see which. Singular moduli factoring knows that CM points modulo $p$ are special — but it cannot see modulo $p$ either. Each method converts a piece of genuine arithmetic structure into a search, and each search costs the square root of the modulus.

The number field sieve breaks that pattern, and that is why it is the one we worry about: it finds structure that is visible *without* knowing $p$ — smooth values of polynomials over the rational integers — and assembles it by linear algebra. That is the real lesson. The security of RSA does not rest on our factors being unstructured. It rests on the structure being *invisible from the outside*.

Singular moduli factoring is a lovely, working, thoroughly analysable algorithm. It just happens to be a beautiful trap: all the structure in the world, arranged around a secret you cannot see, priced at $\sqrt{N}$.
