# How to Split a Secret So That Half a Truth Tells You Nothing

Imagine a bank vault that can only be opened when at least three of its five
managers turn their keys together. No single manager — and no pair of them — can
ever open it alone, no matter how clever they are or how long they scheme. Yet
any three of them, chosen however you like, can open it instantly. This is not a
fantasy of mechanical locks. It is a precise mathematical object called a
**secret sharing scheme**, and the surprising fact is that you can build one out
of nothing more exotic than a polynomial and a few points on its graph.

The idea is due to Adi Shamir, who in 1979 noticed that a humble fact from high
school algebra is, secretly, a fortress. This article is about that fortress:
how it keeps a secret perfectly hidden, how to recover the secret when enough
people cooperate, how to catch a dishonest dealer who hands out fake shares, and
a beautiful twist in which the commitments that prove honesty can themselves be
made to reveal *absolutely nothing*.

## A secret hidden in a polynomial

Here is the trick. Suppose your secret is a single number — a password, a
cryptographic key, the combination to that vault — and call it $c$. Pick a
field $F$ to do arithmetic in; you can think of it as the integers modulo a
large prime $p$, where addition, subtraction, multiplication, and division all
behave just as they do for ordinary fractions.

To share the secret among $n$ people so that any $t$ of them can recover it,
the dealer chooses a polynomial

$$f(X) = c + a_1 X + a_2 X^2 + \cdots + a_{t-1} X^{t-1}$$

of degree less than $t$. The constant term is the secret: $f(0) = c$. The other
coefficients $a_1, \dots, a_{t-1}$ are chosen completely at random. Then the
dealer assigns each participant $i$ a distinct nonzero evaluation point $x_i$
and hands them the single number

$$\text{share}_i = f(x_i).$$

That number — one point on the graph of a secret curve — is the participant's
entire share. Nothing else is revealed.

The whole scheme rests on one classical fact about polynomials, which is at once
completely elementary and completely decisive: **a polynomial of degree less
than $t$ is pinned down by any $t$ of its values.** Two points determine a line,
three points determine a parabola, and in general $t$ points determine a
degree-$(t-1)$ curve uniquely. Push this idea to its logical extreme and you get
both the strength and the secrecy of the scheme at the same time.

## Recovering the secret

Suppose $t$ of the participants pool their shares. Each holds a point
$(x_i, f(x_i))$ on the secret curve, and there are exactly $t$ of them. The
"two points make a line" principle, generalized, says there is one and only one
polynomial of degree less than $t$ passing through all of these points. Since
the dealer's $f$ is such a polynomial, the participants must have recovered
$f$ itself — and reading off its constant term gives the secret.

In its sharpest form the recovery guarantee is a uniqueness statement: if two
polynomials $f$ and $g$ both have degree less than $t$, and they agree on a set
$s$ of $t$ distinct points, then they are literally the same polynomial,
$f = g$. This is the statement that *the reconstruction threshold equals the
degree plus one*: you need exactly $t = (t-1) + 1$ points, not one fewer. As an
immediate consequence, the recovered constant terms agree too, so the secret
$f(0)$ is determined.

Uniqueness tells you the secret is *recoverable*, but it does not tell you
*how*. The constructive answer is the **Lagrange interpolation formula**, which
writes the value of the curve at any point $z$ as a weighted sum of the known
shares:

$$f(z) = \sum_{i \in s} f(x_i)\, \ell_i(z),$$

where each $\ell_i$ is the *Lagrange basis polynomial* — the unique degree-$(t-1)$
polynomial that equals $1$ at $x_i$ and $0$ at every other node. To get the
secret we simply set $z = 0$:

$$c = f(0) = \sum_{i \in s} f(x_i)\, w_i, \qquad w_i = \ell_i(0).$$

The magic is in those weights $w_i$. They depend *only* on which evaluation
points were used — not on the secret, not on the random coefficients, not on the
shares themselves. The very same fixed recipe of weights recovers the secret of
*any* polynomial shared on those nodes. Reconstruction is therefore a single
linear functional: multiply each share by its public weight and add. And these
weights have a charming property — **they always sum to one**. Reconstruction is
an *affine combination* of the shares, the algebraic cousin of a weighted
average.

A tiny example makes it concrete. Work modulo the prime $p = 2089$, let the
secret be $c = 1234$, and choose the random line

$$f(X) = 1234 + 1000\,X.$$

Three participants sit at points $x = 1, 2, 3$ and receive
$f(1) = 2234 \equiv 145$, $f(2) = 3234 \equiv 1145$, and
$f(3) = 4234 \equiv 2145 \equiv 56 \pmod{2089}$. Now hand any two of these
shares to the reconstruction formula. Using $x = 1$ and $x = 2$, the Lagrange
weights at $0$ are $w_1 = 2$ and $w_2 = -1$, so

$$w_1 \cdot 145 + w_2 \cdot 1145 = 290 - 1145 = -855 \equiv 1234 \pmod{2089}.$$

The secret falls right out. Use the points $1$ and $3$ instead, or $2$ and $3$,
and you get $1234$ every time. Any two shares suffice — which is exactly the
threshold $t = 2$.

## Zero knowledge below threshold

Now for the heart of the matter, the property that makes secret sharing worth
caring about: what happens when you have *too few* shares? Intuitively, fewer
clues should mean a fuzzier picture of the secret. The astonishing truth is far
stronger. With $t-1$ shares you learn **nothing at all** — not "a little," not
"a narrowed-down range," but provably *zero information*.

Here is why. Suppose a coalition of $t-1$ participants pools its shares: they
know the value of $f$ at $t-1$ points, none of them the secret point $0$. Pick
*any* number $c$ you like and ask: is there a degree-$(t-1)$ polynomial that
matches all $t-1$ observed shares *and* has secret exactly $c$? Adding the
constraint $f(0) = c$ gives a $t$-th point, $(0, c)$, and now we are back to "$t$
points determine a unique degree-$(t-1)$ curve." So the answer is yes — and not
just yes, but *exactly one* such polynomial exists, for **every** candidate
secret $c$.

This is the punchline. The coalition's view — those $t-1$ numbers — is equally
consistent with every possible secret, and consistent in exactly one way each.
There is a perfect one-to-one correspondence between candidate secrets and the
polynomials explaining the observed shares. From the coalition's standpoint the
secret could be anything, with no value more plausible than any other. The
shares are, statistically, pure noise about $c$.

Contrast this with reconstruction above the threshold and you see the cliff
edge. With $t$ shares the secret is forced to a single value. With $t-1$ it is
totally free. There is no gradual fade: the scheme flips from *fully revealed*
to *fully hidden* the instant you drop below $t$ points. Concretely, given two
*different* candidate secrets $c_1 \ne c_2$, you can exhibit two genuinely
different polynomials, both of degree less than $t$, both matching the same
$t-1$ shares, one with secret $c_1$ and the other with secret $c_2$. The
coalition literally cannot tell them apart. This kind of security is called
**information-theoretic**: it does not rest on any assumption that some
computation is "too hard." Even an adversary with infinite computing power gets
nothing.

## Catching a cheating dealer

So far we have trusted the dealer. But what if the dealer is malicious and hands
out *inconsistent* shares — numbers that do not all lie on a single low-degree
curve — so that different groups of participants reconstruct different secrets?
We would like every participant to be able to *check* their own share without
learning anyone else's, and to detect cheating before it causes harm. This is
the job of **verifiable secret sharing (VSS)**, and the first solution is due to
Paul Feldman.

The idea is to have the dealer *commit publicly* to the polynomial's
coefficients in a way that hides them but allows checking. Work in a group where
multiplying a public generator $g$ by a scalar is easy but going backwards — the
discrete logarithm — is believed to be infeasible. (In our additive notation,
"raising $g$ to the power $a$" is just the scalar multiple $a \cdot g$.) For each
coefficient $a_j$ of the sharing polynomial the dealer publishes the commitment

$$C_j = a_j \cdot g.$$

A participant at point $x$ with claimed share $s$ checks the equation

$$s \cdot g \;=\; \sum_{j=0}^{t-1} x^j \, C_j.$$

Why does this work? Substitute $C_j = a_j \cdot g$ into the right-hand side and
factor out $g$: the sum becomes $\big(\sum_j a_j x^j\big)\cdot g = f(x)\cdot g$.
So the verification right-hand side is exactly $f(x)\cdot g$ — the commitment to
the honest share. An honest dealer therefore always passes: the share $f(x)$
satisfies the check automatically (**completeness**).

Now the soundness. Because multiplying by a nonzero $g$ is a reversible
operation in a field, $s \cdot g = f(x)\cdot g$ holds *if and only if*
$s = f(x)$. In words: **a claimed share verifies precisely when it equals the
true committed value.** Any forged share $s \ne f(x)$ fails the test and is
caught on the spot. The dealer can lie, but the lie cannot survive the public
equation.

Finally there is **binding**. Could a sly dealer publish one commitment vector
but secretly use two different polynomials with different secrets, opening
whichever is convenient later? No. If two polynomials of degree less than $t$
produce the *same* commitments $C_0, \dots, C_{t-1}$, then coefficient by
coefficient $a_j \cdot g = a'_j \cdot g$, and cancelling the nonzero $g$ forces
$a_j = a'_j$. The polynomials are identical. The commitment vector pins the
dealer to exactly one polynomial — hence one secret. Feldman commitments are
*perfectly binding*.

## Hiding everything, perfectly

Feldman's scheme has a subtle cost. Because $C_0 = a_0 \cdot g = c \cdot g$ is a
public, deterministic function of the secret, anyone who can guess the secret
can confirm it — the hiding is only *computational*, resting on the difficulty
of discrete logarithms. Torben Pedersen found a beautiful way to flip this
trade-off and hide the secret *perfectly*, at the price of making the binding
only computational.

Pedersen's recipe uses *two* generators, $g$ and a second one $h$ whose
discrete logarithm relative to $g$ nobody knows. Alongside the sharing
polynomial $f$, the dealer chooses a completely independent random **blinding
polynomial** $f'$, and commits to each coefficient as

$$C_j = a_j \cdot g + a'_j \cdot h,$$

mixing in the blinding coefficient $a'_j$. A share is now a *pair*
$(f(x), f'(x))$, and it verifies when

$$s \cdot g + s' \cdot h \;=\; \sum_{j=0}^{t-1} x^j \, C_j.$$

The same algebra as before shows the right-hand side equals
$f(x)\cdot g + f'(x)\cdot h$, so honest shares verify (**completeness**), and the
commitments still add coefficient-wise — the commitment of a sum of polynomials
is the sum of their commitments (**homomorphism**).

The revelation is what the blinding buys. Fix *any* sharing polynomial $f$ you
wish — any secret at all — and fix *any* published commitment vector $C$. As
long as $h \ne 0$, there is always a blinding polynomial $f'$ that makes
Pedersen's commitments come out exactly equal to $C$. You can read it straight
off: choose the blinding coefficient so that

$$a'_j = \frac{C_j - a_j \cdot g}{h},$$

and the commitment $a_j \cdot g + a'_j \cdot h$ collapses back to $C_j$. Because
*every* secret admits such a blinding, the published commitments are equally
consistent with every secret. They carry no information whatsoever about the
sharing polynomial. This is **perfect hiding** — the same information-theoretic
flavor as Shamir's privacy, now extended to the verification data itself.

The flip side has a name too: **equivocation**. Given any two sharing
polynomials $f_1$ and $f_2$ — encoding two different secrets — one can find
blinding polynomials that make them produce the *identical* commitment vector.
This is the exact opposite of Feldman's binding, where the commitments forced a
single polynomial. Here the commitments refuse to choose; that very refusal is
what makes them leak nothing. The two schemes sit on opposite shores of a single
river: Feldman is perfectly binding and only computationally hiding; Pedersen is
perfectly hiding and only computationally binding. You cannot have both
perfectly at once, and these two designs are the canonical witnesses to that
duality.

## Adding secrets without revealing them

There is one last gift hidden in the linear structure, and it is the foundation
of an entire field called **secure multiparty computation (MPC)**. Recall that
reconstruction is the fixed weighted sum $c = \sum_i \text{share}_i \cdot w_i$.
Because this is *linear*, secrets combine in the most convenient possible way.

Suppose two secrets $c$ and $d$ are each shared, on the same evaluation points,
by polynomials $f$ and $g$. If every participant simply *adds* their two shares
locally — computing $f(x_i) + g(x_i)$ — they now hold shares of the polynomial
$f + g$, whose secret is $c + d$. Running the very same reconstruction weights on
these summed shares yields $c + d$ directly. Nobody ever saw $c$ or $d$; the
sum emerged from purely local arithmetic followed by public reconstruction. This
is **additive homomorphism**, the algebraic backbone of MPC addition. The same
linearity gives scaling by public constants for free, and combining the two
gives arbitrary linear combinations of secrets.

Multiplication is harder, because multiplying the two share polynomials produces
$f \cdot g$, whose degree is roughly *doubled*. But the principle survives: as
long as the participant set is large enough to interpolate the product —
formally, when the degree of $f \cdot g$ stays below the number of nodes — the
product secret $c \cdot d$ is recovered from the participant-wise products of
shares using the *same* Lagrange weights. This degree-doubling phenomenon is the
core of the classic BGW protocol for general secure computation; a full
multiplication round adds a "degree reduction" step to bring the doubled degree
back down, after which the parties can compute any arithmetic circuit on their
private inputs.

## A small fact, a large fortress

Step back and the architecture is breathtaking in its economy. A single
elementary fact — *$t$ points determine a degree-$(t-1)$ polynomial* — read in
one direction gives perfect recovery, and read in the other gives perfect
secrecy. The map from low-degree polynomials to their values on $t$ nodes is a
*bijection*: invertible (that's reconstruction) and, at $t-1$ nodes,
surjective with every secret equally likely (that's privacy). Layer a homomorphic
commitment on top and you can police a dishonest dealer; choose the commitment's
flavor and you decide whether it is the dealer or the secret that is bound
perfectly. Exploit the linearity and you can compute on secrets you are never
allowed to see.

From the combination to a vault to the keys that guard a cryptocurrency wallet,
from distributing trust across data centers to letting hospitals jointly compute
statistics without sharing patient records, the same humble polynomial keeps
turning up. It is one of those rare ideas that is simultaneously simple enough to
teach in an afternoon and deep enough to anchor a generation of cryptography —
proof that sometimes the strongest locks are the ones made of pure arithmetic.
