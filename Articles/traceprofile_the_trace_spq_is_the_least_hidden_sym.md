# The Number That Almost Tells You Everything

## What a semiprime hides, what it can't hide, and why the difference doesn't help you

Take two large prime numbers, $p$ and $q$, and multiply them together to get $N = pq$. Publish $N$. Keep $p$ and $q$ secret. That single act — easy to do, apparently impossible to undo — is the hinge on which a great deal of modern cryptography turns.

The security story usually gets told as a story about *hardness*: nobody knows a fast way to recover $p$ from $N$. But there is a second, quieter story underneath it, and it is a story about *information*. It asks not "how long would it take to find $p$?" but "how much does $N$ even say about $p$ in the first place?"

The answer, for the factor itself, is startling: **nothing at all**. And the answer for a closely related quantity — the sum $s = p + q$, which we will call the **trace** — is equally startling in the opposite direction: it says *exactly one bit, per prime, forever, and the bits are all things you already knew*.

This article is about that gap, and about why the gap is a mirage.

---

## The trace: the smallest thing that gives the game away

Why care about $s = p + q$? Because it is the minimal extra piece of data that breaks the whole problem open. If you know both $N$ and $s$, then $p$ and $q$ are the two roots of the quadratic
$$X^2 - sX + N = 0,$$
so
$$p, q = \frac{s \pm \sqrt{s^2 - 4N}}{2}.$$
One square root, and you're done. The trace is the *minimal factor-bearing symmetric witness*: it is symmetric in $p$ and $q$ (it doesn't play favourites), it is a single number, and together with $N$ it is complete.

So the trace is the natural target for an attacker who wants to be clever rather than brutal. Don't hunt for $p$ — hunt for $s$. And the natural way to hunt for a number you cannot see is to ask it questions modulo small primes: *what is $s$ modulo $3$? modulo $5$? modulo $7$?* Collect enough residues, glue them with the Chinese Remainder Theorem, and you have $s$.

The question this article answers is: **how much can $N$ alone tell you about those residues?**

---

## First surprise: the factor is invisible

Fix an odd prime $\ell$ — say $\ell = 7$ — and suppose $N$ is not divisible by $\ell$. Ask: knowing $N \bmod 7$, what can I say about $p \bmod 7$?

Absolutely nothing. Here is the entire proof. Whatever nonzero residue $a$ you propose for $p \bmod 7$, there is a residue $b$ with $ab \equiv N$, namely $b = a^{-1}N$ — and there is exactly one such $b$. So every one of the six nonzero residues is a live candidate for the factor, and each candidate is compatible with the observation in exactly one way. The counts factor perfectly:

> **Factor invisibility.** Over the field of residues modulo an odd prime $\ell$, the set of residues that a factor of a nonzero $N$ can occupy is the *entire* group of nonzero residues, all $\ell - 1$ of them. Moreover, on the uniform model over pairs of nonzero residues $(x, y)$, the events "$x = a$" and "$xy = b$" are exactly independent: the joint count times the total equals the product of the two marginal counts, for every $a$ and $b$. The mutual information $I(p \bmod \ell \,;\, N \bmod \ell)$ is exactly zero.

This is the "zero block" — a wall of zeros stretching across every modulus you can test. The public modulus is a perfect one-time pad for the residues of its own factors. It is not that finding $p$ is hard; it is that $N \bmod \ell$ contains *no evidence* at all about $p \bmod \ell$.

---

## Second surprise: the trace is not invisible

Now ask the same question of the trace. Which residues can $s = p + q$ occupy, modulo $7$?

Define the **trace set**
$$S_\ell(N) = \{\, x + y \;:\; xy \equiv N \bmod \ell \,\}.$$
This is the complete list of legal residues for the trace. And it is *not* everything.

The reason is the quadratic formula again, run backwards. A residue $s$ is a legal trace precisely when the equation $X^2 - sX + N$ splits — that is, when its discriminant is a square:

> **Discriminant description.** For an odd prime $\ell$, a residue $s$ lies in $S_\ell(N)$ if and only if $s^2 - 4N$ is a square modulo $\ell$.

And now the counting is immediate, because in a field of odd characteristic, exactly half the nonzero elements are squares. As $s$ runs over all $\ell$ residues, the quantity $s^2 - 4N$ lands in the squares about half the time. Sharpening "about" to "exactly" gives the central formula of this story:

> **The exact size of the trace set.** For an odd prime $\ell$ and $N \not\equiv 0$,
> $$2\,|S_\ell(N)| = \ell + \chi_\ell(N),$$
> where $\chi_\ell(N)$ is $+1$ if $N$ is a nonzero square modulo $\ell$ and $-1$ if it is not. Equivalently, $|S_\ell(N)| = (\ell+1)/2$ or $(\ell-1)/2$.

So the trace lives in a set of size roughly $\ell/2$ out of $\ell$ possibilities. In the language of information: **the public modulus reveals exactly one bit about the trace, modulo every odd prime.** Where the factor was invisible, the trace is half-visible.

Concretely, take $\ell = 7$ and $N \equiv 1$. Since $1$ is a square mod $7$, the formula predicts $|S_7(1)| = 4$, and indeed the factorisations $1 \cdot 1$, $2 \cdot 4$, $3 \cdot 5$, $6 \cdot 6$ give traces $2, 6, 1, 5$. Four residues out of seven are legal; three — namely $0, 3, 4$ — are impossible. If you ever meet a semiprime with $N \equiv 1 \bmod 7$, you may confidently assert that $p + q \not\equiv 3 \bmod 7$. That is a real, checkable constraint, obtained from public data, on a quantity that would break the cryptosystem if you knew it.

Should you be worried?

---

## Third surprise: the bits are perfectly additive

Before answering, let's see how far the constraint scales. Take several odd primes at once, say $3, 5, 7, 11$, and work modulo their product $M = 1155$. The trace set behaves as well as it possibly could:

> **Multiplicativity.** The trace set of a product ring is the product of the trace sets. Consequently, for coprime moduli $m$ and $n$, $|S_{mn}(N)| = |S_m(N)| \cdot |S_n(N)|$.

The proof is one line of bookkeeping: a factorisation modulo $mn$ is the same thing as a pair consisting of a factorisation modulo $m$ and one modulo $n$, and sums are computed componentwise. Combining this with the exact prime formula gives the joint law:

> **One bit per prime, additively independent.** Let $M = \prod_{\ell \in P} \ell$ be a squarefree product of odd primes, none dividing $N$. Then
> $$\prod_{\ell \in P}(\ell - 1) \;\le\; 2^{|P|} \, |S_M(N)| \;\le\; \prod_{\ell \in P}(\ell + 1).$$
> That is, the trace set has density $2^{-|P|}$ in the residues modulo $M$, up to the tiny corrections $1 \pm 1/\ell$.

Each new prime halves the space of legal traces, and the halvings never interfere. The measured densities — $0.5011$ for one prime, $0.2509$ for two, $0.1260$ for three — are exactly $2^{-1}, 2^{-2}, 2^{-3}$ with the predicted $O(1/\ell)$ wobble. This is as clean as an information law can be: the trace leaks $\omega(M)$ bits, where $\omega$ counts prime factors of the modulus, with no redundancy and no synergy.

---

## The catch: the bits were already yours

Now the twist that turns the whole story around. Look again at the exact formula:
$$2\,|S_\ell(N)| = \ell + \chi_\ell(N).$$
The one bit is $\chi_\ell(N)$ — the **quadratic character of $N$ modulo $\ell$**, the answer to "is $N$ a square mod $\ell$?" That quantity is computable from $N$ alone, in a fraction of a millisecond, by quadratic reciprocity. It is public data. It was public before anyone thought about traces.

The consequence is a theorem about what the constraint *cannot* do:

> **The visible bit is only the character.** If two moduli $N$ and $N'$ have the same quadratic character mod $\ell$, then $|S_\ell(N)| = |S_\ell(N')|$. The size of the trace constraint sees $N$ through the single public bit $\chi_\ell(N)$, and through nothing else.

So the "leak" is not a leak. It is a shadow cast by a fact you could already compute. The trace is congruence-visible, yes — but visible in a way that is symmetric in $p$ and $q$, derivable from $N$, and useless as evidence about which factorisation is the true one.

The same phenomenon appears in its purest form at the very bottom of the binary expansion, in what is probably the prettiest identity in the whole story.

---

## The exact low bit: $s_1 = 1 - N_1$

Let $p$ and $q$ be odd. Then a one-line computation — write $p = 2a+1$, $q = 2b+1$, expand — gives
$$p + q + pq = 4(a + b + ab) + 3,$$
so:

> **The exact low-bit theorem.** For all odd $p, q$: $\;p + q + pq \equiv 3 \pmod 4$. Equivalently, with $N = pq$ and $s = p+q$, one has $s \equiv 2 \pmod 4$ exactly when $N \equiv 1 \pmod 4$, and $s \equiv 0 \pmod 4$ exactly when $N \equiv 3 \pmod 4$. In binary digits: the second-lowest bit of the trace is the complement of the second-lowest bit of the modulus,
> $$s_1 = 1 - N_1.$$

This holds with no exceptions whatsoever — it was checked on three hundred thousand random semiprime pairs and failed on none, which is exactly what a theorem does. And it is the entire story in miniature: a bit of the secret trace, sitting there in plain view, *completely determined by the public modulus*. Two different factorisations with the same $N \bmod 4$ have the same $s \bmod 4$. Information content about the factorisation: zero.

The law is also sharp. It does not extend to the next bit. The pairs $(3,3)$ and $(5,13)$ have $N = 9$ and $N = 65$, both $\equiv 1 \bmod 8$, but traces $6$ and $18$, which differ mod $8$. So no exact relation determines bit $2$ of $s$ from bits of $N$. What survives is a statistic: over the sixteen odd residue pairs mod $8$, twelve have bit $2$ of the trace differing from bit $2$ of the modulus, giving probability exactly $3/4$. The measured value in the experiment was $0.754$.

There is even a version for any number of factors:

> **The $k$-factor low-bit law.** If $N = a_1 a_2 \cdots a_k$ with every $a_i$ odd, and $e_1 = a_1 + \cdots + a_k$ is the sum, then
> $$e_1 + 1 \equiv N + k \pmod 4.$$

For $k = 2$ this is $s + 1 \equiv N + 2$, the theorem above. The exactly-visible low bit of the first symmetric function is a function of the product and the *number of factors* — nothing more.

---

## Two factors are special: the arity dichotomy

Everything so far has been about $N = pq$. What if $N$ has three factors? Is there a constraint on $x + y + z$ when $xyz = N$?

Essentially none, and the reason is geometric. For two factors, "is $s$ a legal trace mod $\ell$?" asks whether the *conic* $s^2 - 4N = w^2$ has a point — one quadratic condition, hence one bit, hence a set of size about $\ell/2$. For three factors, the analogous question is whether a certain curve of genus one has a point with $z \ne 0$; and by the Hasse–Weil bound such a curve has $\ell + O(\sqrt{\ell})$ points over the field of $\ell$ elements, which is more than enough to guarantee a solution as soon as $\ell$ is not tiny. The constraint evaporates.

That is exactly what happens:

> **The arity dichotomy.** For every odd prime $\ell$ and every invertible $N$, the two-factor trace set $S_\ell(N)$ is a *proper* subset of the residues. But modulo $11$, the three-factor sum set $\{x + y + z : xyz = N\}$ is *all* of the residues, for every invertible $N$. Small primes are exceptional: modulo $5$, the three-factor sum set still misses a residue (for $N = 1$ it misses $2$). And the three-factor sum set always contains a shifted copy of the trace set, so it is never smaller.

So the collapse has a threshold, and it is at $\ell = 11$: the primes $3, 5, 7$ are the last holdouts. The one visible bit is not a general fact about symmetric functions of factorisations. It is a fact about *discriminants*, and discriminants are what you get when there are exactly two roots.

---

## Why none of this factors anything

We now have a quantity, the trace, which is (i) sufficient to factor $N$ if you knew it, and (ii) genuinely constrained by public congruence data, one clean bit per prime. Why is this not an attack?

Because one bit per prime is *additive* and the search space is *exponential*. The trace of a semiprime with factors at least $2$ satisfies $p + q \le pq = N$, so a priori it lives in the window $[1, N]$. Congruence data modulo $M$ knocks out the residues outside the trace set, and the count of survivors is easy to bound from below: a residue class modulo $M$ meets $[1, B]$ in at least $B/M - 1$ integers, so a set of $|S_M(N)|$ legal residues leaves at least $|S_M(N)| \cdot (B/M - 1)$ candidates. Feeding in the one-bit-per-prime law:

> **The pinning barrier.** Let $M = \prod_{\ell \in P} \ell$ be squarefree, odd, coprime to $N$. The number of integers $t$ in the window $[1, B]$ whose residue modulo $M$ is a legal trace residue is at least
> $$\frac{\left(\prod_{\ell \in P}(\ell-1)\right)\left(B/M - 1\right)}{2^{|P|}}.$$
> The surviving set still has density about $2^{-|P|}$.

To cut $[1, N]$ down to a single candidate you need $2^{|P|} \gtrsim N$, that is $|P| \gtrsim \log_2 N$ distinct primes. For a $2048$-bit modulus that is over two thousand primes, whose product $M$ dwarfs $N$ by an astronomical margin — and once $M > N$, the residue of $s$ modulo $M$ simply *is* $s$, so you have assumed the answer. There is even a crisp small-scale version: whenever $3M \le N$, at least two integers of the window share the residue, so no modulus that small can ever determine the trace.

The bits are real. They are additive. They accumulate at the rate of one per prime — and the target shrinks at the rate of one bit per *bit*. Additive gain against exponential search is not a race; it is a rounding error.

---

## What the trace really is

Let us collect the verdict.

Among all the symmetric functions of a hidden factorisation, the trace $s = p+q$ is the **least hidden**. Its residues are constrained, exactly and computably, by public data, at every odd prime and in the low bits of its binary expansion — the only symmetric invariant of the factorisation for which this happens. It is the most accessible residue target there is.

And it is still perfectly safe, for three independent reasons, each of which is a theorem:

1. **The visible bit is public.** The deviation of the trace set from half the residues is exactly the Legendre symbol $\chi_\ell(N)$, which anybody can compute from $N$. The constraint sees $N$ only through that bit.
2. **The visible bits are symmetric.** The low-bit law $s_1 = 1 - N_1$ is a function of $N \bmod 4$ alone. Nothing that treats $p$ and $q$ alike can ever tell them apart.
3. **The visible bits don't scale.** Pinning $s$ needs a modulus larger than $N$, at which point the congruence data is the answer rather than a route to it.

There is one loose end, and it is the most interesting number-theoretic question the story raises. Although the *size* of the trace set sees only the character of $N$, the trace *set itself* appears to see everything: for every odd prime tested, distinct invertible $N$ give distinct trace sets — verified exhaustively at $\ell = 13$, and computationally up to $41$. The heuristic is a character-sum count: the overlap $|S_\ell(N) \cap S_\ell(N')|$ for $N \ne N'$ is a two-variable character sum of size $\ell/4 + O(\sqrt{\ell})$, while equality would demand $\ell/2 + O(1)$. The gap between "the size knows one bit" and "the set knows everything" is precisely the information a residue attack cannot convert into factors. Quantifying it turns a verdict into a theorem.

That is the shape of the thing. A secret can be surrounded by facts about itself, all of them true, all of them checkable, all of them free — and remain, in every way that matters, a secret. The trace of a semiprime is a small, sharp monument to that possibility: a number about which we know exactly one bit per prime, and exactly nothing at all.
