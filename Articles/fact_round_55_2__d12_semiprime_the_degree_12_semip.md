# The Number That Knows Everything Except Which Half Is Which

## A story about primes, symmetry, and the exact price of forgetting

Imagine you are handed a large number $N$ and told, truthfully, that it is the
product of exactly two primes, $N = pq$. You are not told what $p$ and $q$ are.
This is the situation at the heart of modern public-key cryptography, and the
usual question — *can you find $p$ and $q$?* — is famously hard.

Here we ask a subtler question. Suppose you do not want the factors themselves,
only some *feature* of them. How much of that feature does $N$ give away for
free?

The answer, it turns out, can be computed exactly — not estimated, not sampled,
but written down in closed form as a formula in Euler's totient function. And
along the way something striking appears: a piece of information that $N$
withholds not partially, not approximately, but **perfectly**. One full bit,
sitting there in plain view, provably unreachable.

---

## Primes have a shape

Fix a prime, say $13$, and consider the arithmetic of the thirteenth roots of
unity — the field $\mathbb{Q}(\zeta_{13})$ obtained by adjoining a solution of
$z^{13} = 1$ to the rational numbers. This field is a *cyclic* extension of
degree $12$: its symmetry group is the cyclic group $C_{12} = \mathbb{Z}/12$, a
clock with twelve positions.

Every prime $p \neq 13$ occupies one of those twelve positions. The position is
called the Frobenius element of $p$, and I will write it as an exponent
$a \in \{0, 1, \dots, 11\}$. The position is not just bookkeeping: it decides
how $p$ behaves inside the bigger field. Write

$$T(a) = \frac{12}{\gcd(12, a)},$$

the *order* of the position $a$ on the twelve-hour clock. Then $p$ breaks up
into exactly $12/T(a)$ prime factors in $\mathbb{Q}(\zeta_{13})$, each of
"degree" $T(a)$. I will call $T(a)$ the **splitting type** of $p$. If
$T(a) = 1$ — that is, if $a = 0$ — the prime shatters completely into twelve
pieces; if $T(a) = 12$, it stays stubbornly whole.

Concretely: $p$ has splitting type $1$ exactly when $p \equiv 1 \pmod{13}$, and
in general the splitting type is the multiplicative order of $p$ modulo $13$.
The splitting type is a genuine, computable, arithmetic fingerprint of a prime.

Now take two primes $p$ and $q$, at clock positions $a$ and $b$, and form
$N = pq$. The Frobenius of a product is the product of the Frobenii, which on
the clock means **addition**:

$$N \text{ sits at position } a + b \bmod 12 .$$

So from $N$ alone — indeed from $N \bmod 13$ alone — you learn the *sum* of the
two positions, and nothing more. The question of this article is: how much does
knowing the sum tell you about the pair of splitting types
$\{T(a), T(b)\}$?

This is an information-theoretic question, and it has an exact numerical
answer.

---

## Counting first, entropy second

Everything hinges on a counting problem, and the counting problem has a
beautifully clean answer.

There are $144$ possible position pairs $(a,b)$ for a degree-$12$ semiprime.
Each pair produces an unordered pair of splitting types, written
$\Pi = \{T(a), T(b)\}$ — unordered, because $N = pq = qp$ does not remember
which factor you wrote first. How many of the $144$ pairs realise a given
unordered type pair $\{d, e\}$?

**The Exact Enumeration Law.** *Let $n \geq 1$ and let $d \le e$ be divisors of
$n$. Among the $n^2$ exponent pairs of a semiprime with cyclic symmetry group of
order $n$, the number whose unordered splitting-type pair equals $\{d,e\}$ is*

$$c_{d,e} \;=\; \begin{cases} \varphi(d)\,\varphi(e), & d = e,\\[2pt]
2\,\varphi(d)\,\varphi(e), & d < e,\end{cases}$$

*where $\varphi$ is Euler's totient function. Moreover these are the only type
pairs that occur, and the counts sum to exactly $n^2$.*

The proof is a two-line picture. On a clock with $n$ positions, exactly
$\varphi(d)$ positions have order $d$, for each divisor $d$ of $n$ — the classic
fact behind the identity $\sum_{d \mid n} \varphi(d) = n$. So the set of
position pairs with types $(d,e)$ *in that order* is a rectangle of size
$\varphi(d)\varphi(e)$. If $d = e$ the rectangle is a square and that is the
whole story. If $d \neq e$ there are **two** rectangles — one for each way of
assigning the two types to the two factors — and they are disjoint. Hence the
factor of $2$. The counts add to $n^2$ because every pair lands somewhere.

That factor of $2$ is small, innocuous, and — as we will see — the entire source
of the phenomenon this article is about.

For $n = 12$ the divisors are $1,2,3,4,6,12$ with totients $1,1,2,2,2,4$, giving
twenty-one type pairs with multiplicities

$$1,\;2,\;4,\;4,\;4,\;8,\;1,\;4,\;4,\;4,\;8,\;4,\;8,\;8,\;16,\;4,\;8,\;16,\;4,\;16,\;16,$$

which sum, as promised, to $144$.

Once you can count, you can compute entropy. Shannon's entropy of a quantity
taking value $v$ with multiplicity $c_v$ out of $M$ equally likely cases is
$\log_2 M - \frac{1}{M}\sum_v c_v \log_2 c_v$. So:

**The Entropy Law.** *For every $n \geq 1$, the entropy of the unordered
splitting-type pair of a semiprime with cyclic symmetry group of order $n$ is*

$$H(\Pi) \;=\; \log_2\!\big(n^2\big) \;-\; \frac{1}{n^2}\sum_{\substack{d \le e \\ d,e \mid n}} c_{d,e}\log_2 c_{d,e}.$$

At $n = 12$ the sum evaluates to exactly $450$ (all the multiplicities are
powers of two, so all the logarithms are integers), and

$$H(\Pi) \;=\; \log_2 144 - \frac{450}{144} \;=\; \frac{7}{8} + 2\log_2 3 \;\approx\; 4.0449 \text{ bits}.$$

No enumeration of $144$ cases; a formula.

Subtracting the entropy that remains once $N \bmod 13$ is known gives the
quantity we actually wanted — the **pair channel**, the number of bits that $N$
leaks about the splitting behaviour of its two factors:

$$I_{\text{pair}}(12) \;=\; \frac{5}{36} + \log_2 3 \;\approx\; 1.7239 \text{ bits}.$$

That is a lot. Out of roughly four bits of uncertainty, $N$ hands over more than
one and a half for free, simply by being reducible modulo $13$.

---

## The bit that never leaks

Now the surprise.

For most position pairs the two primes have *different* splitting types — $114$
of the $144$ pairs, to be exact. For those, there is a perfectly sensible extra
question to ask: *which* factor is the one with the smaller type? Call the
answer the **which-factor bit**. It is a genuine yes/no question about the
world, and by symmetry it is a fair coin: half the time the first factor has the
smaller type, half the time the second.

Can you learn it from $N$?

Not a little. Not sometimes. Not ever.

**The Which-Factor Wall.** *Fix $n \geq 2$ and restrict to the exponent pairs
whose two primes have distinct splitting types. Then the which-factor bit has
entropy exactly $1$ — a full bit of genuine uncertainty — and for **every**
read-out that is symmetric in the two factors, the mutual information between
that read-out and the which-factor bit is exactly $0$.*

"Every symmetric read-out" is a strong phrase and it means what it says: the
unordered type pair, the residue of $N$ modulo $13$, the residue modulo anything
at all, the value of $N$ itself, any combination of these, any function
whatsoever of the two factors that does not care about their order. All of them
are blind. Not $10^{-6}$ bits, not "below the noise floor" — zero.

The proof is one of those arguments that feels like a magic trick and then like
a triviality. Swapping the two factors is an operation on the population of
position pairs that (i) maps the population to itself, (ii) undoes itself when
applied twice, (iii) *flips* the which-factor bit, since if $T(a) < T(b)$ then
certainly not $T(b) < T(a)$, and (iv) leaves any symmetric read-out untouched.
Take any group of pairs sharing the same read-out value. Swapping shuffles that
group onto itself while flipping every label inside it. So within *every single*
read-out class, the two answers to "which factor?" occur exactly equally
often — the conditional distribution is a fair coin no matter what you have
observed. Observation changes nothing; the information is zero.

The wall is not an artefact of there being nothing to hide. If you could see the
splitting types *in order* — a read-out no symmetric quantity provides — you
would recover the whole bit immediately, and the abstract statement confirms
this: the ordered read-out has mutual information exactly $1$ with the
which-factor bit. So one full bit exists, and symmetry hides all of it. The wall
is a symmetry phenomenon, not an entropy deficit.

There is a moral here that reaches beyond this particular clock. Whenever the
thing you want to know is *antisymmetric* under an exchange, and everything you
can measure is *symmetric* under that same exchange, the leak is not small — it
is structurally, exactly nil. The argument never mentioned primes, splitting
types, or the number $13$. It only used the orbit structure of a two-element
group acting on the fibres of a measurement.

---

## Forgetting has a price, and the price is a probability

The two results above look unrelated: one is a counting law, the other a
symmetry principle. They are the same theorem seen from two sides.

Consider the ordered pair of splitting types $(T(a), T(b))$. Since $a$ and $b$
are independent, its entropy is exactly $2H(T)$, twice the entropy of a single
prime's splitting type. Now forget the order. How much entropy do you lose?

**The Symmetrization-Defect Law.** *For every $n \geq 1$,*

$$H(\Pi) \;=\; 2H(T) \;-\; \frac{\#\mathrm{asym}(n)}{n^2},$$

*where $\#\mathrm{asym}(n)$ is the number of exponent pairs whose two primes
have distinct splitting types. Equivalently, since
$\#\mathrm{asym}(n) = n^2 - \sum_{d\mid n}\varphi(d)^2$,*

$$H(\Pi) \;=\; 2H(T) - 1 + \frac{1}{n^2}\sum_{d \mid n}\varphi(d)^2 .$$

Read that again slowly. The entropy cost of forgetting which factor is which is
*exactly the probability that the question was meaningful in the first place*.
Every pair with two distinct types loses precisely one bit when you symmetrize;
every pair with two equal types loses nothing; average over the population and
you get the defect. The population appearing in the defect is, to the last
element, the population on which the which-factor wall operates. The wall says
that bit is unreachable; the defect law says that same bit is exactly what
symmetrization destroys. Conservation of ignorance, in a sense: the bit is not
leaked because it was already spent.

Two immediate consequences fall out. Symmetrizing always costs something (for
$n \ge 2$ the defect is strictly positive, since there is always at least one
mismatched pair — take a completely split prime alongside an inert one), and it
never costs more than one bit (the defect is a probability). So

$$2H(T) - 1 \;\le\; H(\Pi) \;<\; 2H(T)$$

for every cyclic order. At $n = 12$: $\#\mathrm{asym}(12) = 144 - 30 = 114$, the
defect is $114/144 = 19/24 \approx 0.7917$ bits, and
$\tfrac78 + 2\log_2 3 = 2\big(\tfrac56 + \log_2 3\big) - \tfrac{19}{24}$ —
the closed forms agree on the nose.

---

## A much thinner channel

There is one more read-out worth examining, because it is the one a
number-theorist would reach for first: forget the full type pair and keep only
the **split count**, the number of the two factors that split completely
($0$, $1$, or $2$). Among the $144$ degree-$12$ position pairs, the split count
has profile $(121, 22, 1)$: exactly one pair has both factors completely split,
$22$ have exactly one, and $121$ have none.

The exact channel is

$$I_{\text{split}}(12) \;=\; \frac{199}{72} + \log_2 3 + \frac{55}{72}\log_2 5 - \frac{253}{144}\log_2 11 \;\approx\; 0.04452 \text{ bits},$$

a magnificently lopsided expression that is nevertheless provably positive and
provably below one eighth of a bit — in fact below one *tenth* of what the full
type pair leaks. The split count is a leak, but a whisper.

The reason it is a whisper is an astonishing rigidity. Sort the $144$ position
pairs by the residue of $N$ modulo $13$; each of the twelve classes gets exactly
twelve pairs. Then **eleven of the twelve classes have identical split-count
profiles** $(2, 10)$ — two pairs with one completely split factor, ten with
none. Only the class $N \equiv 1$ is different, with profile $(1, 11)$: it
contains the single pair in which *both* factors split completely, namely both
primes $\equiv 1 \pmod{13}$, and no pair with exactly one. The entire channel is
driven by one lattice point. That is where the isolated coefficient
$-\tfrac{253}{144}$ on $\log_2 11$ comes from, and why the leak is so small:
eleven of twelve times, the observation tells you nothing whatsoever.

Across cyclic orders the split-count channel measures
$0.2947,\, 0.1487,\, 0.0614,\, 0.0445,\, 0.0267$ bits at $n = 4, 6, 10, 12, 16$ —
falling steadily, never reaching zero. Whether it *can* reach zero is, as far as
I know, open; the single-lattice-point picture suggests it decays like
$\log n / n$ and stays strictly positive forever.

---

## What was actually accomplished

Three things, each of which replaced a case-by-case computation with a theorem
that holds for every cyclic order.

First, a **closed-form law** for the splitting-type statistics of a semiprime,
purely in terms of Euler's totient function, together with the entropy it
forces. What used to require enumerating $n^2$ cases is now a sum over the
divisors of $n$.

Second, an **exact zero**: the which-factor wall. Empirically the leak measured
at $0.0002$ bits — which is exactly what numerical noise looks like. The theorem
says the true value is $0$, in the sharpest available generality, for every
symmetric read-out and every cyclic order at once.

Third, an **identity binding the two**: $H(\Pi) = 2H(T) - \#\mathrm{asym}(n)/n^2$.
The cost of symmetrization is the size of the population that symmetrization
makes anonymous.

The degree-$12$ numbers — $I_{\text{pair}}(12) = \tfrac{5}{36} + \log_2 3$,
$I_{\text{split}}(12) = \tfrac{199}{72} + \log_2 3 + \tfrac{55}{72}\log_2 5 - \tfrac{253}{144}\log_2 11$,
$\#\mathrm{asym}(12) = 114$ — are now corollaries of general laws rather than
isolated data points. That is the difference between a measurement and an
explanation.

And the punchline stands on its own, independent of any clock size: a semiprime
$N = pq$ tells you a surprising amount about the *shapes* of its two prime
factors, and absolutely nothing — provably, exactly nothing — about which of
them has which shape. The product $pq$ has, at the deepest level, forgotten the
order in which you wrote it.
