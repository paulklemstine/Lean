# Cracking RSA When You Whisper Half a Secret

## The lock that runs the internet

Every time you buy something online, log into your bank, or send an encrypted
message, a piece of arithmetic from the 1970s quietly stands guard. It is called
RSA, and its security rests on a deceptively simple fact: it is easy to multiply
two large prime numbers together, but staggeringly hard to pull the product back
apart.

Pick two secret primes, call them $p$ and $q$. Multiply them to get a public
number $n = p \cdot q$. You can shout $n$ from the rooftops; anyone can use it to
*encrypt* a message to you. But only someone who knows the original factors $p$
and $q$ can *decrypt* it. For a modulus with hundreds of digits, factoring $n$
without inside knowledge would take the fastest computers longer than the age of
the universe.

So the system is unbreakable — except when it isn't. The history of cryptography
is a history of clever shortcuts that sidestep the "hard" problem entirely. This
article is about one of the most elegant of these shortcuts, a 1990 attack by
Michael Wiener, and a modern twist on it that turns a small *leak* of secret
information into a complete collapse of the lock.

## The temptation of a small key

To decrypt with RSA you need a *private exponent*, written $d$. It is the
mathematical inverse of the public exponent $e$, tied together by the famous **key
equation**:

$$ e \cdot d = k \cdot \varphi(n) + 1, $$

where $k$ is some positive integer and $\varphi(n)$ is *Euler's totient* — for a
product of two primes it is simply

$$ \varphi(n) = (p - 1)(q - 1). $$

Here is the temptation. Decryption is faster when $d$ is small. A small $d$ means
quicker logins, snappier handshakes, less battery drained on your phone. Surely,
an engineer might reason, choosing a modest $d$ to speed things up couldn't hurt?

Wiener's attack is the devastating answer: **if $d$ is too small, RSA falls
apart.** Specifically, if $d$ is smaller than roughly the fourth root of $n$
(written $d < n^{1/4}$), an attacker can recover it — and therefore factor $n$ —
in a flash, using nothing more exotic than the arithmetic of fractions.

## The secret hiding in a fraction

Wiener's insight was to look at the key equation not as a statement about huge
integers, but as a statement about a *ratio*. Rearrange it and you find that the
fraction $k/d$ is an almost unbelievably good approximation to the public fraction
$e/n$.

Why "almost unbelievable"? Because of a theorem of Legendre from the theory of
continued fractions. It says: if a fraction $k/d$ approximates a number $x$ so
tightly that

$$ \left| x - \frac{k}{d} \right| < \frac{1}{2 d^2}, $$

then $k/d$ is not just *a* good approximation — it is forced to appear as one of
the **convergents** of $x$, the special sequence of best-possible fractions that
the continued-fraction algorithm spits out. There are only a handful of these
convergents, and they are trivially fast to compute. So if Wiener can show that
the *secret* fraction $k/d$ beats Legendre's threshold against the *public*
fraction $e/n$, the secret has nowhere to hide: it must be one of a short list of
fractions anyone can generate.

Once you have $k/d$, you know $d$. Once you know $d$, you can compute
$\varphi(n)$. And once you know both $n = p\cdot q$ and $\varphi(n) = (p-1)(q-1)$,
recovering $p$ and $q$ is a one-line exercise in solving a quadratic. The lock
springs open.

## Where the magic comes from

The whole attack hinges on an exact piece of algebra. Start from the key equation
and subtract a copy of $n$ scaled by $k$. The mess collapses into something
beautiful:

$$ e \cdot d - k \cdot n = 1 - k\big((p + q) - 1\big). $$

This is the heart of the matter, and it is an *exact identity* — no
approximation, no error term. The left side is the "residual" of the
approximation. The right side is controlled entirely by $p + q$, the sum of the
two secret primes. And here is the crucial scale: while $n$ is roughly the *size*
of $p$ times $q$, the sum $p + q$ is only about the *square root* of $n$. The
residual is small because $p+q$ is small compared to $n$. That smallness is
exactly what drives $k/d$ below Legendre's threshold.

## The twist: knowing half a secret

Wiener's classic attack only works when $d$ is genuinely tiny — below $n^{1/4}$.
Cryptographers learned that lesson and kept their private exponents large. So is
the attack a museum piece?

Not quite. The modern refinement asks a sharper question: **what if the attacker
already knows part of a secret?** In practice, secrets leak. A side-channel — a
power-consumption trace, a timing measurement, a fault injection — might reveal
the *most significant bits* of $p + q$, the leading digits of the prime sum.
Knowing the leading digits of a number is the same as having a good *estimate* of
it.

Call that estimate $s$. It is not exactly $p + q$, but it is close — the more
leading bits you have leaked, the closer it is. The brilliant move is to *correct
the modulus*. Instead of approximating $e/n$, the attacker builds a **corrected
modulus**

$$ \tilde{n} = n + 1 - s $$

and approximates $e / \tilde{n}$ instead. If the estimate were perfect — if
$s = p + q$ exactly — then $\tilde n$ would equal $\varphi(n)$ itself, the
totient the attacker is desperate to learn. With a merely good estimate, $\tilde
n$ is a near-perfect stand-in.

Repeating the same algebra with the corrected modulus yields the **modified key
identity**:

$$ e \cdot d - k \cdot \tilde{n} = 1 - k\big((p + q) - s\big). $$

Look at what changed. The residual is no longer governed by $p + q$ itself, but
by the *estimation error* $(p + q) - s$. And that error shrinks every time the
attacker learns one more leading bit. The leak directly sharpens the blade.

## How much leakage is enough?

Suppose the attacker's estimate is good enough that the error is bounded:

$$ |(p + q) - s| \le \Delta $$

for some known $\Delta$. Then the approximation error of the secret fraction
satisfies a clean bound:

$$ \left| \frac{e}{\tilde n} - \frac{k}{d} \right| \le \frac{k\Delta + 1}{\tilde n
\, d}. $$

To trigger Legendre's theorem and force $k/d$ to be a convergent, this must drop
below $1/(2d^2)$. A little rearrangement shows that it suffices to have

$$ 2 \, d \, (k\Delta + 1) < \tilde{n}. $$

This single inequality — call it the **partial-knowledge smallness condition** —
is the entire attack distilled into one line. And notice its structure: it is
*linear* in the error bound $\Delta$. Smaller $\Delta$ (more leaked bits) lets you
get away with a larger $d$. When you leak a $\delta$-fraction of the bits of
$p+q$, the tolerable private exponent grows from Wiener's $d < n^{1/4}$ all the
way up to roughly $d < n^{(1+\delta)/2}$. At zero leakage ($\delta = 0$) you
recover the classic fourth-root bound; with substantial leakage, even large,
"safe" private exponents become vulnerable.

This is the central lesson of partial key exposure: **security is not binary.**
Leaking even a fraction of a secret does not merely weaken a system a little — it
can interact multiplicatively with other small weaknesses (like a moderately
sized $d$) to bring the whole structure down.

## A worked example you can check by hand

Abstract bounds are convincing, but nothing beats watching the gears turn on real
numbers. Take the toy primes $p = 17$ and $q = 11$. Then:

- the modulus is $n = 17 \cdot 11 = 187$;
- the totient is $\varphi(n) = 16 \cdot 10 = 160$;
- choose the private exponent $d = 23$ and the public exponent $e = 7$;
- the key equation $7 \cdot 23 = 161 = 1 \cdot 160 + 1$ holds with $k = 1$.

Now suppose the attacker has a *perfect* estimate $s = p + q = 28$. The corrected
modulus is $\tilde n = 187 + 1 - 28 = 160$, which (as promised) equals
$\varphi(n)$ exactly. The approximation error of the secret fraction is

$$ \frac{7}{160} - \frac{1}{23} = \frac{161 - 160}{3680} = \frac{1}{3680}. $$

Legendre's threshold here is $1/(2 \cdot 23^2) = 1/1058$. And indeed

$$ \frac{1}{3680} < \frac{1}{1058}, $$

so the secret fraction $1/23$ clears the bar with room to spare. It *must* be a
convergent of $7/160$ — and it is. Run the continued-fraction algorithm on
$7/160$ and out pops $1/23$, revealing $d = 23$ and unlocking the cipher.

## Why this story matters

There are three takeaways, each larger than RSA itself.

**First, structure is a liability.** RSA is hard to break by brute force precisely
because factoring is hard. But the key equation imposes *structure* — a hidden
relationship between public and private data — and structure can be exploited even
when brute force cannot. The continued-fraction attack never factors anything the
"hard" way. It listens for the faint music of a near-perfect rational
approximation, and that music is enough.

**Second, partial leaks are not partial damage.** It is tempting to think that
leaking, say, a third of the bits of a secret leaves two-thirds of your security
intact. The modified Wiener attack shows the opposite: a $\delta$-fraction of
leaked bits stretches the attacker's reach by an *exponential* factor in the size
of the key. In the arithmetic of secrets, the whole is far more fragile than the
sum of its parts.

**Third, the boundary is sharp and knowable.** Everything above reduces to a
single, checkable inequality, $2 d (k\Delta + 1) < \tilde n$. There is no hand
waving, no "in practice it usually works." There is a precise line in the sand:
on one side the attack provably succeeds, on the other it provably loses its
guarantee. That kind of clean threshold is what lets cryptographers design
systems with confidence — by staying safely on the right side of it.

## The continued-fraction lens

Step back and the deepest idea here is not about cryptography at all. It is that a
single real number, expanded as a continued fraction, contains within it a short
and canonical list of "best" rational approximations, and that *any* fraction
which approximates the number too well is compelled to join that list. This is a
piece of pure number theory more than two centuries old, the kind of thing one
might file under "beautiful but useless."

Wiener's attack is the spectacular refutation of that filing. The same Legendre
theorem that classifies approximations of irrational numbers turns out to be a
skeleton key for one of the most important cryptosystems ever deployed. And the
modified attack shows that the key only gets sharper when the world leaks a little
of its secrets — as the world always does.

The arithmetic of fractions, it turns out, has been quietly auditing the security
of the internet all along. We just had to learn how to listen.
