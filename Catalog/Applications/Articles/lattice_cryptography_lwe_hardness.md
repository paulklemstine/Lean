# When Pythagoras Meets the Codebreakers: How the Sum of Two Squares Guards Tomorrow's Secrets

## A 2,000-year-old identity is quietly defending the post-quantum world

There is a number that almost everyone learns as a child and almost no one
thinks about again: $3^2 + 4^2 = 5^2$. The Pythagorean theorem, the sum of two
squares, the diagonal of a rectangle — it feels like the most settled piece of
mathematics imaginable. Yet that same humble expression, $a^2 + b^2$, turns out
to sit at the heart of one of the most urgent technological races of our time:
the scramble to build cryptography that a quantum computer cannot break.

This is the story of how a composition identity discovered by Indian
mathematicians more than a thousand years ago becomes the engine of a modern
encryption scheme — and how every step of that journey can be made completely,
mechanically certain.

## The problem with today's locks

Almost every secure message you send — your banking session, your password
manager, the little padlock in your browser — is protected by one of two
mathematical problems: factoring large numbers, or computing discrete
logarithms. Both are believed to be hard for ordinary computers. Both are
*easy* for a sufficiently large quantum computer, thanks to an algorithm
discovered by Peter Shor in 1994.

No such machine exists yet at the scale needed. But the threat is not
hypothetical, and it is not even really in the future. An adversary can record
your encrypted traffic *today* and decrypt it years later once the hardware
arrives — the so-called "harvest now, decrypt later" attack. So the world needs
new locks, built on problems that *stay* hard even for quantum machines.

The leading candidate is a deceptively simple-sounding puzzle called **Learning
With Errors**, or **LWE**.

## Learning with errors: hide a message in noise

Imagine I give you a long list of linear equations, but I lie to you a little in
every one. Honestly, the equations would read

$$b = a_1 s_1 + a_2 s_2 + \cdots + a_n s_n \pmod q,$$

where the $s_i$ form a secret you are trying to recover, the $a_i$ are public
random numbers, and $q$ is a fixed modulus. If I gave you these *exactly*, you
could solve for the secret instantly with high-school linear algebra.

The trick of LWE is that I add a small random error $e$ to each equation:

$$b = a_1 s_1 + \cdots + a_n s_n + e \pmod q.$$

Each lie is tiny — the error $e$ is small compared to $q$ — but collectively the
errors make Gaussian elimination useless. The noise propagates and explodes.
Recovering the secret from noisy equations is the **search LWE** problem;
merely telling noisy equations apart from pure random gibberish is **decision
LWE**. Both are believed to be hard, even for quantum computers, and remarkably
their hardness can be tied back to the difficulty of geometric problems about
**lattices** — regular grids of points in high-dimensional space, where finding
the shortest nonzero vector (the problem called GapSVP) is a notorious
computational wall.

That chain — *worst-case lattice geometry* is at least as hard as *average-case
LWE*, due to Oded Regev's celebrated 2005 quantum reduction — is what makes LWE
trustworthy. You are not betting that *some particular* random instance is hard;
you are betting that *the hardest possible* lattice is hard, which is a far safer
bet.

## Making it efficient: ring-LWE and the Gaussian integers

Plain LWE is secure but bulky. Every public key is a big matrix; every
ciphertext drags along an entire vector. To make lattice cryptography practical
— fast enough for a phone, small enough for a network packet — cryptographers
moved to **ring-LWE**, where numbers are replaced by elements of an algebraic
ring. A single ring element packs in many coordinates at once, and multiplying
ring elements does the work of a whole matrix-vector product.

The simplest interesting ring is one Carl Friedrich Gauss studied two centuries
ago: the **Gaussian integers**, written $\mathbb{Z}[i]$. These are complex
numbers $a + bi$ where $a$ and $b$ are ordinary integers and $i = \sqrt{-1}$.
They add and multiply just like complex numbers, and they form a perfectly
well-behaved arithmetic world — with prime numbers, factorization, and all the
familiar structure.

And here is where Pythagoras walks back onto the stage. Every Gaussian integer
$z = a + bi$ has a **norm**:

$$N(a + bi) = a^2 + b^2.$$

That is the squared length of the vector $(a, b)$ — the Pythagorean diagonal,
the sum of two squares. The norm is the single most important number attached to
a Gaussian integer, and it is the bridge between the geometry of the plane and
the algebra of the ring.

## The magic identity

The norm has a property that looks almost too good to be true: it is
**multiplicative**. The norm of a product is the product of the norms:

$$N(z \cdot w) = N(z) \cdot N(w).$$

Spell that out in coordinates. If $z = a + bi$ and $w = c + di$, then their
product is $(ac - bd) + (ad + bc)i$, and the identity says

$$(a^2 + b^2)(c^2 + d^2) = (ac - bd)^2 + (ad + bc)^2.$$

This is the **Brahmagupta–Fibonacci identity**, written down by the Indian
mathematician Brahmagupta in the 7th century and rediscovered by Fibonacci in
the 13th. It says something marvelous: *if two numbers are each a sum of two
squares, then so is their product*, and it tells you exactly which two squares.
Multiply $5 = 1^2 + 2^2$ by $13 = 2^2 + 3^2$ and you are guaranteed
$65 = (1\cdot 2 - 2 \cdot 3)^2 + (1 \cdot 3 + 2 \cdot 2)^2 = 4^2 + 7^2$, and
indeed $16 + 49 = 65$.

In our formal development, this identity is exactly the lemma that proves the
norm is multiplicative — the theorem named `gaussNorm_mul`. The Pythagorean
composition law *is* the algebraic backbone of arithmetic in $\mathbb{Z}[i]$,
and therefore the backbone of ring-LWE over $\mathbb{Z}[i]$.

## Which primes split, and why it matters

To choose a secure modulus $q$ for ring-LWE, you need to understand how ordinary
primes behave inside the Gaussian integers. There is a beautiful dichotomy,
again governed entirely by the sum of two squares:

- A prime $p$ with $p \equiv 1 \pmod 4$ — like $5, 13, 17, 29$ — **splits**: it
  is no longer prime in $\mathbb{Z}[i]$, because it can be written as a sum of
  two squares, $p = a^2 + b^2$, and therefore factors as
  $p = (a + bi)(a - bi)$. Formally this is the theorem `prime_split`, with its
  companion `prime_not_prime_in_gaussian`.
- A prime $p$ with $p \equiv 3 \pmod 4$ — like $3, 7, 11, 19$ — stays **inert**:
  it remains prime in $\mathbb{Z}[i]$, precisely because it *cannot* be written
  as a sum of two squares. These are the theorems `prime_inert` and
  `prime_inert_not_sum_two_squares`.

This is Fermat's theorem on sums of two squares, dressed in the language of
Gaussian primes. It is not a curiosity here — it is a design rule. The ring
structure that ring-LWE relies on, the way the modulus factors, and the security
of the parameters all depend on which side of this $\bmod\ 4$ line your prime
falls.

## Encryption that survives the noise

Now we can build the actual cipher. Fix a modulus $q = 2t$ (so $t = q/2$ is the
"half modulus"). To encrypt a single bit $m \in \{0, 1\}$, encode it as $m \cdot
t$ — that is, as either $0$ or $q/2$, two points sitting at opposite ends of the
modular circle. Then bury it in a ring-LWE sample: publish $a$, compute
$a \cdot s + e + (\text{message})$, where $s$ is the secret and $e$ is a small
Gaussian-integer error.

Because we work in $\mathbb{Z}[i]$, a single ciphertext carries **two** bits at
once — one in the real coordinate, one in the imaginary coordinate.

To decrypt, the holder of the secret $s$ subtracts the mask $a \cdot s$, leaving
$e + (\text{message})$, and then **rounds**: if a coordinate is closer to $0$,
read off the bit $0$; if it is closer to $q/2$, read off the bit $1$. The
decoder is the function `decodeCoord`, and the guarantee that rounding recovers
the right bit is the theorem `decodeCoord_correct`:

> If a bit $m \in \{0, 1\}$ is encoded as $m \cdot t$ and corrupted by an error
> $e$ satisfying $2|e| < t$, then `decodeCoord` returns exactly $m$.

In words: as long as the noise pushes you less than a quarter of the way around
the circle, rounding lands you back on the correct codeword.

## The Pythagorean ball of safety

The final piece is the most elegant. In two dimensions — real and imaginary —
the error is a vector $(e_x, e_y)$, and the natural way to measure "small" is its
**Euclidean length**: small means

$$e_x^2 + e_y^2 < \left(\frac{q}{4}\right)^2,$$

the inside of a disk of radius $q/4$. This is, once more, the sum of two squares
— the Pythagorean norm of the error vector.

The bridge from this clean geometric condition to the per-coordinate rounding
guarantee is supplied by two twin theorems, `coord_bound_re` and
`coord_bound_im`. They prove that whenever the error lies inside the Euclidean
ball of radius $q/4$, *each individual coordinate* automatically satisfies the
rounding condition $2|e_x| < t$ and $2|e_y| < t$. After all, if $e_x^2 + e_y^2$
is small, then $e_x^2$ alone is even smaller.

Put the pieces together and you get the headline result, **decryption
correctness for ring-LWE over $\mathbb{Z}[i]$**: if the error vector lands inside
the Pythagorean ball of radius $q/4$, both message bits are recovered exactly.
The geometry of the circle of radius $q/4$ — the locus $x^2 + y^2 = (q/4)^2$,
Pythagoras himself — is *literally* the boundary between a message that decrypts
correctly and one that does not.

## The reduction that makes it trustworthy

Correctness tells you the cipher works when there is no adversary. Security tells
you it works when there is. The bridge between the two is a **reduction**: an
argument that breaking the cipher would let you solve a problem believed to be
impossibly hard.

For LWE, the crucial reduction is **search-to-decision**: if you could merely
*detect* LWE samples (decision), you could actually *recover* the secret
(search). The engine of that reduction is a small algebraic miracle about prime
moduli. When $q$ is prime, the map $x \mapsto a x + b$ with $a \neq 0$ is a
perfect shuffle — a bijection — of the numbers modulo $q$. This is the theorem
`ZMod.affine_bijective`. It means a wrong guess about the secret re-randomizes a
sample into pure uniform noise, so any detectable bias must come from a *correct*
guess. Recovering the secret one coordinate at a time then costs only a factor of
$n$ in the adversary's advantage, captured by the pigeonhole theorem
`search_to_decision_advantage_bound`:

> If the total distinguishing advantage is $\delta$ and it splits across $n$
> coordinates, then at least one coordinate carries advantage at least
> $\delta / n$.

Layer that on top of Regev's quantum worst-case reduction and you reach the
summit: *breaking this encryption is at least as hard as solving the shortest
vector problem on the worst lattice in the world.*

## Why certainty matters here

Cryptography is unusual among human endeavors: a single overlooked case, a
single off-by-one in a noise bound, can silently void a security proof and leave
a system exposed for years. The history of the field is littered with schemes
that were "proven secure" and later broken because a proof had a gap.

That is why every theorem in this story — the multiplicativity of the Gaussian
norm via Brahmagupta–Fibonacci, the splitting and inertness of primes, the
rounding correctness of the decoder, the Euclidean-ball error bound, the affine
re-randomization at the core of the reduction — has been written in a form a
machine can check, line by line, with no appeal to intuition or "it is easy to
see." The result is not a claim that a human believes; it is a fact a computer
has verified.

## The long arc

It is worth pausing on the sheer reach of this. A schoolchild's identity,
$a^2 + b^2$. A medieval composition law for sums of squares. A 17th-century
theorem of Fermat about which primes are sums of two squares. The 19th-century
arithmetic of Gauss. And a 21st-century encryption scheme designed to outlast
quantum computers. They are not analogies for one another. They are the *same
mathematics*, reused — the diagonal of a right triangle reborn as the radius of
the disk inside which a secret can be safely hidden.

The codebreakers of the future will bring quantum machines. The codemakers will
answer, it seems, with Pythagoras.
