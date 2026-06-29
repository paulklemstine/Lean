# The Numbers That Wear a Disguise

## A test that almost never lies

Imagine you are handed an enormous number — hundreds of digits long — and asked a deceptively
simple question: *is it prime?* Primes are the indivisible atoms of arithmetic, the raw material
out of which every whole number is built, and our ability to tell them apart from composite
numbers underpins almost all of modern digital security. When you buy something online, when you
send an encrypted message, when your phone establishes a secure connection, somewhere in the
background a computer is quietly testing gigantic numbers for primality.

Testing a thousand-digit number by trial division — checking whether it is divisible by 2, by 3,
by 5, and so on — is hopeless. The universe would burn out before the computation finished. So
mathematicians and engineers reach instead for a beautiful shortcut discovered by Pierre de
Fermat in the seventeenth century.

Fermat's **little theorem** says this: if `p` is a prime number, then for any base `b` that is not
a multiple of `p`,

> `b` raised to the power `p − 1`, when divided by `p`, leaves a remainder of exactly `1`.

In symbols, `p` divides `b^(p−1) − 1`. This is a startling, rigid fact. It gives us a *test*. Take
your mystery number `n`, pick a convenient base like `b = 2`, compute `2^(n−1)` modulo `n`
(which a computer can do astonishingly fast using repeated squaring), and look at the remainder.
If the remainder is **not** `1`, then `n` has failed a property that every prime obeys, so `n`
cannot be prime. Case closed. You have proved compositeness without ever finding a single factor.

But what if the remainder *is* `1`? Then `n` has *passed* the test, and you are tempted to declare
it prime. Here is where the story turns. Passing Fermat's test does not guarantee primality. Some
composite numbers are impostors: they sail through the test as if they were prime. These
counterfeit primes are called **Fermat pseudoprimes**, and they are the villains — or perhaps the
tricksters — of this story.

## The master forgers

Most pseudoprimes are clumsy forgers. A composite number might fool the test for base `2` but get
caught immediately by base `3`. So a natural defense is to run the test with many different bases.
If `n` passes for `b = 2`, then `b = 3`, then `b = 5`, then `b = 7`, our confidence that `n` is
genuinely prime grows with each success. Surely no composite could fool *all* of them?

This is where the deepest surprise lies. There exist composite numbers that fool Fermat's test for
**every** base coprime to them. No matter which witness `b` you choose (as long as `b` shares no
common factor with `n`), the number passes. These are the perfect forgers — the numbers that wear
the disguise of a prime so completely that Fermat's test, run with any honest witness, can never
unmask them. They are called **Carmichael numbers**, after the American mathematician Robert
Carmichael, who catalogued the first few in 1910.

The smallest Carmichael number is `561`. It factors as `561 = 3 × 11 × 17`, so it is unmistakably
composite. And yet, for every base `b` coprime to `561`,

> `561` divides `b^560 − 1`.

Pick `b = 2`: `561` divides `2^560 − 1`. Pick `b = 7`, or `b = 100`, or `b = 559`: same story,
every single time. The number `561` is a flawless counterfeit prime. Fermat's test, the workhorse
of primality checking, is utterly blind to it.

This raises an urgent question. How can a composite number possibly conspire to satisfy a prime's
defining property against *every* witness simultaneously? It sounds like it should be impossible —
or at least exceedingly rare and chaotic. The miracle is that it is not chaotic at all. There is a
clean, almost crystalline structural reason, and it was discovered by Alwin Korselt in 1899,
eleven years *before* Carmichael found his first example. Korselt described exactly what these
numbers must look like, even though he could not produce a single one.

## Korselt's recipe

Korselt's criterion is a recipe, a checklist that a number must satisfy to be a perfect forger.
A composite number `n` is a Carmichael number if and only if two conditions hold:

1. **`n` is squarefree.** That is, no prime appears twice in its factorization. The number `561 =
   3 × 11 × 17` is squarefree; the number `12 = 2 × 2 × 3` is not, because `2` appears twice.

2. **For every prime `p` dividing `n`, the number `p − 1` divides `n − 1`.** Let us check this for
   `561`. Its prime factors are `3`, `11`, and `17`. Then `p − 1` takes the values `2`, `10`, and
   `16`. And `n − 1 = 560`. Indeed `2` divides `560`, `10` divides `560` (since `560 = 10 × 56`),
   and `16` divides `560` (since `560 = 16 × 35`). All three conditions hold. So `561` is a
   Carmichael number — exactly as advertised.

This is an extraordinary thing to behold. A property about *infinitely many bases* — that `n`
divides `b^(n−1) − 1` for every coprime `b` — has been distilled into a *finite* check involving
only the handful of prime factors of `n`. You do not have to test any bases at all. You just
factor `n`, confirm no prime repeats, and verify a few small divisibility relations. The infinite
collapses into the finite.

In this work we have given a complete, machine-checked proof of the half of Korselt's criterion
that *manufactures* Carmichael numbers: we prove that **any** number satisfying Korselt's two
conditions really does fool Fermat's test against every coprime base. Let us see why this is true.

## Why the recipe works

The argument is a small masterpiece of "think locally, conclude globally," and it rests on two
ideas that fit together like a key in a lock.

**The local idea.** Fix one prime factor `p` of `n`. Inside the world of arithmetic modulo `p` —
a self-contained number system with exactly `p` elements, where every nonzero element has a
multiplicative inverse — Fermat's little theorem says that raising any nonzero element to the power
`p − 1` gives `1`. Now suppose `p − 1` divides `n − 1`, so `n − 1 = (p − 1) × k` for some whole
number `k`. Then for any element `x` in this little world,

> `x^n = x^((p−1)·k + 1) = (x^(p−1))^k · x = 1^k · x = x`.

In words: modulo `p`, raising to the `n`-th power does nothing at all — every element returns to
itself. (And the equation `x^n = x` holds even for `x = 0`, trivially.) This is the key local
lemma. It says that the map "raise to the `n`-th power" is the identity in each prime residue
world, precisely because `p − 1` divides `n − 1`.

Translating back to integers: for any integer `a`, the prime `p` divides `a^n − a`.

**The global idea.** We have just shown that *each* prime factor `p` of `n` divides `a^n − a`. We
want to conclude that `n` *itself* divides `a^n − a`. This is where squarefreeness earns its keep.
Because `n` is squarefree, it is the product of its distinct prime factors, each appearing exactly
once. Distinct primes share no common factors — they are *pairwise coprime*. And there is a
fundamental principle of arithmetic: if several pairwise-coprime numbers each divide some quantity,
then their product divides that quantity too. (This is the Chinese Remainder Theorem wearing
working clothes.) So from "each prime `p` divides `a^n − a`" we glue together "the product of those
primes — which is `n` — divides `a^n − a`."

Putting the two ideas together, we obtain the central identity:

> **The Korselt identity.** If `n` is squarefree and `p − 1` divides `n − 1` for every prime `p`
> dividing `n`, then `n` divides `a^n − a` for *every* integer `a`.

This single statement is the engine of the entire theory. From it, the Carmichael property follows
almost immediately. Take any base `b` coprime to `n`. The identity gives us that `n` divides
`b^n − b = b · (b^(n−1) − 1)`. Since `b` shares no factor with `n`, the factor `b` cannot help with
the divisibility, so `n` must divide `b^(n−1) − 1` all on its own. That is exactly the statement
that `n` passes Fermat's test for base `b`. Because `b` was an arbitrary coprime base, `n` fools
the test for every one of them. The forgery is perfect.

## The hidden anatomy of a forger

Korselt's recipe does more than verify candidates; it constrains what a Carmichael number can
possibly look like. Two structural facts fall straight out of the criterion.

**Every Carmichael number is odd.** Suppose, for contradiction, that a Carmichael number `n` were
even. Being squarefree and composite, it must have some *odd* prime factor `p` (it cannot be a pure
power of `2`, since squarefree rules out repeated factors and `2` itself is prime, not composite).
For that odd prime, `p − 1` is even, so `2` divides `p − 1`, which divides `n − 1`. Hence `n − 1`
is even, which makes `n` odd — contradicting our assumption that `n` is even. So no even Carmichael
number can exist. Every forger is odd.

**Every Carmichael number has at least three distinct prime factors.** A squarefree composite
number has at least two prime factors by definition. Could a Carmichael number have exactly two,
say `n = p · q` with `p < q`? It turns out it cannot. The condition that `q − 1` divides `n − 1 =
pq − 1` forces a relationship that is impossible for two distinct primes (intuitively, `q − 1` is
"too large" relative to the gap it must divide). So a genuine Carmichael number needs three or more
prime factors. This is why `561 = 3 × 11 × 17`, with its three factors, is the smallest one — there
is simply no room for a smaller forger.

These structural theorems turn an abstract definition into a vivid silhouette. A Carmichael number
is odd, squarefree, and built from at least three different primes, each of which leaves a precise
fingerprint on `n − 1`. We know the shape of the disguise even before we meet the impostor wearing
it.

## Why this matters beyond the puzzle

There is a practical moral. Because Carmichael numbers defeat Fermat's test against *every* witness,
any primality test that relies purely on Fermat's congruence is fundamentally unreliable — there is
no number of random bases that will save it. This is not a hypothetical worry: Carmichael numbers
are infinite in supply (a celebrated 1994 theorem of Alford, Granville, and Pomerance proved there
are infinitely many of them). Modern cryptographic libraries therefore use *strengthened* tests —
the Miller–Rabin test chief among them — which exploit a little more structure of prime arithmetic
and provably catch every composite, Carmichael or not. The villains of our story are precisely the
reason those stronger tests had to be invented.

And there is an aesthetic moral too. Korselt's criterion is a perfect illustration of one of
mathematics' deepest pleasures: the collapse of the infinite into the finite. A statement about all
integers `a` and all bases `b` — an unbounded ocean of conditions — turns out to be governed by a
short, checkable list of facts about a number's prime skeleton. To verify that `561` is a flawless
counterfeit prime, you do not test a billion bases. You factor it, glance at three small
divisibilities, and you are done. The disguise, it turns out, has a blueprint — and once you hold
the blueprint, the magic becomes mechanics.

The forgers are no longer mysterious. They are merely numbers obeying a recipe we now understand
completely, line by line, with every step verified beyond doubt.
