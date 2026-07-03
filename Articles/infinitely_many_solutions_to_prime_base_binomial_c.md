# When Binomial Coefficients Remember Their Base

## A congruence hiding in Pascal's triangle

Pascal's triangle is one of the first objects a student of mathematics meets, and one of the last to give up its secrets. Its entries, the binomial coefficients $\binom{m}{k}$, count the ways of choosing $k$ things from $m$. They are everywhere: in probability, in algebra, in the expansion of $(1+x)^m$. And they carry, buried inside their prime factorizations, an astonishing amount of number theory.

This article is about a family of congruences that live in that triangle. Fix a whole number $q \ge 2$ — call it the **base**. Now ask: for which numbers $n$ is it true that

$$\binom{qn}{n} \equiv q^{n} \pmod{n}\,?$$

In words: take the binomial coefficient that chooses $n$ objects from $qn$, and compare it with the pure power $q^n$. When are these two enormous integers equal *modulo* $n$?

The two sides look wildly different. The left is a ratio of factorials; the right is a single number multiplied by itself $n$ times. There is no obvious reason they should ever agree modulo $n$. And yet, as we will see, they agree remarkably often — in fact, for *every prime number* $n$, no matter what base $q$ you chose. That single observation is enough to prove the congruence has infinitely many solutions, unconditionally, for every base.

The story then continues into deeper water, where a beautiful conjecture about *composite* solutions still waits to be settled.

## The prime miracle

Let us start with the cleanest possible case: $n = p$, a prime. We claim that for **any** base $q$,

$$\binom{qp}{p} \equiv q^{p} \pmod{p}.$$

Because $q^p \equiv q \pmod p$ by Fermat's little theorem — the ancient fact that raising anything to the $p$-th power leaves it unchanged modulo $p$ — the right-hand side is just $q$. So the whole claim reduces to showing that the left-hand side is also $q$:

$$\binom{qp}{p} \equiv q \pmod{p}.$$

Here the hero is **Lucas' theorem**, a rule for computing binomial coefficients modulo a prime by looking at the base-$p$ digits of the top and bottom. Lucas' theorem says you may compute $\binom{m}{k} \bmod p$ digit by digit: split $m$ and $k$ into their base-$p$ representations and multiply together the small binomial coefficients of corresponding digits.

Apply this to $\binom{qp}{p}$. When we divide $qp$ by $p$ we get a quotient of $q$ and a remainder of $0$; when we divide $p$ by $p$ we get a quotient of $1$ and a remainder of $0$. Lucas' theorem then peels off the lowest digit and reduces the problem to

$$\binom{qp}{p} \equiv \binom{0}{0}\binom{q}{1} \pmod{p} = 1 \cdot q = q.$$

That's it. Both sides equal $q$ modulo $p$, so the congruence holds. And crucially, **nothing here needed $q$ to be small or special** — the digit reduction $qp \mapsto (q, 0)$ and $p \mapsto (1, 0)$ works for any base whatsoever.

Since there are infinitely many primes (Euclid, two thousand years ago), we have proved:

> **Theorem (Infinitude of solutions).** For every base $q \ge 2$, the congruence $\binom{qn}{n} \equiv q^{n} \pmod n$ has infinitely many solutions $n$; indeed every prime is one.

A short experiment confirms the pattern and reveals a hint of what lies beyond. For base $q = 2$, scanning $n$ up to $40$ turns up the solutions

$$2,\ 3,\ 5,\ 7,\ 11,\ 12,\ 13,\ 17,\ 19,\ 23,\ 29,\ 30,\ 31,\ 37.$$

Every prime is there, exactly as promised. But look closely: $12 = 2^2 \cdot 3$ and $30 = 2 \cdot 3 \cdot 5$ have sneaked in too. These are **composite** solutions, and they are far more mysterious.

## The composite frontier

The prime solutions are, in a sense, "free" — they fall out of two classical theorems. The real depth of the subject lies in the composite solutions, and the most fruitful place to look for them is among numbers of the special shape

$$n = q^{t}\, p,$$

where $q$ is our fixed base, $t \ge 1$ is an exponent, and $p$ is some *other* prime, different from $q$. The question is whether infinitely many such $n$ solve the congruence.

The engine driving this search is a single, concrete integer. Define

$$A_t \;=\; \binom{q^{\,t+1}}{q^{\,t}} \;-\; q^{\,q^{t}}.$$

This is the difference of two towering quantities: a central-style binomial coefficient sitting at height $q^{t+1}$, and a pure power of the base with an exponent that is itself a power of the base. It turns out that the primes $p$ capable of producing a composite solution $n = q^t p$ are governed by the prime factorizations of these numbers $A_t$: one needs $p$ to *divide* $A_t$, together with a mild "digit-sum" side condition. So understanding the arithmetic of $A_t$ is the key to the whole composite family.

## How much of the base hides inside $A_t$?

The first thing to understand about any integer is how divisible it is by the primes in play — here, by the base $q$ itself. And the answer is strikingly clean: **the base $q$ divides $A_t$ exactly once, and never twice.**

To see why, we examine the two pieces separately.

**The binomial piece.** How many factors of $q$ live inside $\binom{q^{t+1}}{q^t}$? Kummer's theorem gives a gorgeous answer: the power of a prime $q$ dividing a binomial coefficient $\binom{a+b}{a}$ equals the number of *carries* that occur when you add $a$ and $b$ in base $q$. Our coefficient is $\binom{q^{t+1}}{q^t}$, which corresponds to adding $q^t$ and $q^{t+1} - q^t = (q-1)q^t$. In base $q$, the first number is a single digit $1$ sitting in place $t$; the second is a single digit $q-1$ sitting in the very same place. Adding them gives $1 + (q-1) = q$ in place $t$ — a value that overflows and produces exactly **one** carry into place $t+1$, turning the sum into $q^{t+1}$. One carry, and only one. Therefore

$$v_q\!\left(\binom{q^{\,t+1}}{q^{\,t}}\right) = 1,$$

where $v_q$ denotes the exponent of $q$ in a number's factorization. In plain terms: $q$ divides this binomial coefficient, but $q^2$ does not.

**The power piece.** The second term is $q^{\,q^t}$, whose exponent of $q$ is simply $q^t$. As soon as $t \ge 1$ we have $q^t \ge q \ge 2$, so this term is divisible by $q^2$ — in fact by a colossal power of $q$.

**Subtracting.** Now combine. Both terms are divisible by $q$, so their difference $A_t$ is divisible by $q$. But only the power term is divisible by $q^2$; the binomial term is not. A number divisible by $q^2$ minus a number *not* divisible by $q^2$ is itself *not* divisible by $q^2$. Hence:

> **Theorem (Exact valuation of $A_t$).** For every prime base $q$ and every exponent $t \ge 1$, the base $q$ divides $A_t$ exactly once: $q \mid A_t$ but $q^2 \nmid A_t$.

The small cases make this vivid. With $q = 2$: $A_1 = \binom{4}{2} - 2^{2} = 6 - 4 = 2 = 2 \cdot 1$, and $A_2 = \binom{8}{4} - 2^{4} = 70 - 16 = 54 = 2 \cdot 27$. With $q = 3$: $A_1 = \binom{9}{3} - 3^{3} = 84 - 27 = 57 = 3 \cdot 19$. In each case exactly one factor of the base appears, and what is left over — $1$, then $27$, then $19$ — is coprime to the base.

## Why the "exactly once" matters

At first glance this looks like a technical bookkeeping fact. But it carries a genuine structural payload. The composite construction needs a prime $p$ different from the base $q$ dividing $A_t$. Because the base appears in $A_t$ to the *first* power only, dividing it out leaves a **residual**

$$R_t \;=\; \frac{A_t}{q},$$

which is coprime to $q$. The sequence of residuals — $1, 27, 19, \dots$ for the bases above — is exactly where all the candidate primes live. The base $q$ can never itself be the prime $p$ used in $n = q^t p$; that exclusion, which the composite conjecture demands, is not an extra hypothesis one has to impose but an automatic consequence of the arithmetic. The valuation result *sharpens the search space* to precisely the primes $p \neq q$.

This is the reassuring shape of good number theory: a clean local fact (the base divides $A_t$ once) that tidies up a global question (which primes can appear).

## The conjecture that remains

With the prime solutions completely understood and the base cleanly stripped away, the frontier stands out sharply. The residuals $R_t = A_t/q$ grow explosively, and one expects — in the spirit of the classical theorems of Zsygmondy and Carmichael on primitive prime divisors — that these numbers keep throwing up brand-new large prime factors as $t$ increases. A large prime factor comfortably satisfies the digit-sum side condition, so each new primitive prime should hand us a fresh composite solution. That reasoning leads to the central open conjecture:

> **Conjecture (Infinitely many composite solutions).** For every prime base $q$ there are infinitely many pairs $(t, p)$, with $p$ a prime distinct from $q$ dividing $A_t$ and satisfying a linear digit-sum condition, such that $n = q^t p$ solves $\binom{qn}{n} \equiv q^n \pmod n$.

The path forward runs through the arithmetic of the residuals $R_t$: are they squarefree infinitely often? Do they always eventually acquire a prime factor larger than any fixed bound? These are questions about differences of binomial coefficients and pure prime powers — objects tailor-made for the tools of lifting-the-exponent and cyclotomic divisibility.

## The larger lesson

What makes this circle of ideas beautiful is how it braids together the oldest theorems in number theory — Euclid's infinitude of primes, Fermat's little theorem, Lucas' and Kummer's rules for binomial coefficients modulo a prime — to answer a question that at first sounds hopeless. Two gigantic and unrelated-looking integers, $\binom{qn}{n}$ and $q^n$, turn out to shake hands modulo $n$ every time $n$ is prime, whatever base you start from. And the moment you push past the primes, the subject opens onto genuinely uncharted territory, where a single, explicit sequence of integers holds the key.

Pascal's triangle, it seems, still remembers its base. We are only beginning to learn how to read what it recorded.
