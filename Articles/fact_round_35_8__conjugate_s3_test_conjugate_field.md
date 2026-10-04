# The Field, Not the Polynomial

*Why two different-looking cubic equations always count their solutions the same way, at every clock size*

---

## Two equations that should disagree

Here are two cubic polynomials:

$$f_+(x) = x^3 - x + 1, \qquad f_-(x) = x^3 - x - 1.$$

They differ only in the sign of the constant term. Over the real numbers they look different. $f_-$ has its single real root at the *plastic number* $\rho \approx 1.3247$, a cousin of the golden ratio that shows up in architecture and in the Padovan sequence. $f_+$ has its single real root at $-\rho$. Each also has a pair of complex roots.

Now do arithmetic on a clock. Pick a whole number $n$, work "modulo $n$" so that only remainders after division by $n$ count, and ask: *how many of the $n$ possible values of $x$ make the polynomial zero?* We call that number the **type** of the polynomial at $n$ and write it $T(n)$. Modulo 3 neither cubic has a root, so $T(3) = 0$. Modulo 5 each has exactly one root. Modulo 59 each has three. Modulo $1357 = 23 \cdot 59$ each has six.

A recent series of experiments studied these types statistically. One fixes a "label" of a prime $p$, such as its remainder modulo 23, and measures how much information the label carries about the type $T(p)$. The measure is Shannon's **mutual information** $I(\text{label};T)$, counted in bits. The experiments ran the same measurement on both cubics and got the same answer, $I(p \bmod 23; T) = 1.000065$ bits, to every printed decimal place. On pairs of primes (semiprimes $pq$) the two answers agreed "within Monte Carlo noise".

That kind of agreement calls for an explanation. Is it a coincidence of the sample? A numerical artifact? Or is there a theorem behind it?

There is a theorem, and it is stronger than the experiment suggests. **The two cubics have exactly the same number of roots modulo every whole number $n$.** This holds at every modulus, prime or composite, and no statistics are needed to see it. More generally, it holds in *every finite commutative ring*. The data agree to the last digit because the two lists of types are the same list. The informal slogan is that the type channel sees **the field, not the polynomial**.

## A one-line mirror

The core of the argument fits on one line:

$$f_+(-x) = (-x)^3 - (-x) + 1 = -(x^3 - x - 1) = -f_-(x).$$

So $x$ is a root of $f_-$ exactly when $-x$ is a root of $f_+$. Negation $x \mapsto -x$ is a perfect matching of the clock face with itself. It is one-to-one and onto, and it is its own inverse. Hence it matches the roots of one polynomial with the roots of the other, one for one. Modulo 59, for example, the roots of $f_-$ are $4, 13, 42$. Their negatives $55, 46, 17$ are exactly the roots of $f_+$.

The same mirror works modulo 10, modulo $2^{20}$, modulo 1357, and in any finite system where you can add, subtract and multiply. That is the first theorem:

> **Conjugate invariance.** In every finite commutative ring, $x^3 - x + 1$ and $x^3 - x - 1$ have the same number of roots. In particular their type functions agree: $T_+(n) = T_-(n)$ for every whole number $n$.

After this, the experiment's equal numbers are no surprise. Mutual information is computed from a table of (label, type) pairs. If the type column is the same for both polynomials, the tables are the same and so are the numbers. This gives the second theorem:

> **Bit-for-bit channel identity.** For every finite sample of moduli and every way of labelling them, the mutual information between label and type is the same real number for both cubics. The same is true for semiprime samples, whether one uses the type of $pq$ or the pair of types of $p$ and $q$.

In the semiprime experiment, any disagreement can come only from feeding the two polynomials *different random samples*. When the sample is shared, the agreement is exact.

## Any change of variable will do

Negation is just one case of a general rule. Take *any* polynomial $f$ over a finite commutative ring. Take any invertible element $u$ (a *unit*) and any element $c$. Then the substituted polynomial $f(ux + c)$ has exactly as many roots as $f$. The reason is that $x \mapsto ux + c$ is a bijection of the ring, with inverse $y \mapsto u^{-1}(y - c)$. A bijection carries the zero set of one function onto the zero set of the other.

> **Affine invariance.** For every polynomial $f$ over a finite commutative ring, every unit $u$ and every element $c$, the polynomials $f(x)$ and $f(ux+c)$ have the same number of roots.

Behind this lies a principle that does most of the work in this story: *root counts move along bijections.* Suppose a map takes the roots of $f$ to the roots of $g$, and another map sends them back, the two undoing each other. Then $f$ and $g$ have equally many roots. The two maps need not be bijections of the whole ring. They only need to behave well on the roots.

## The surprising third generator

That last remark matters, because there is a third polynomial in the family:

$$f_r(x) = x^3 + x^2 - 1.$$

It is the *reciprocal* of $f_-$. If $\rho$ is a root of $f_-$, then $1/\rho$ is a root of $f_r$. Over the real numbers this is easy. On a clock, though, "$1/x$" is dangerous. Modulo 6, for instance, the number 2 has no inverse. So is it safe to move the roots across by taking reciprocals?

The cubic itself makes it safe. If $r^3 - r - 1 = 0$, then $r(r^2 - 1) = r^3 - r = 1$. **Every root of $f_-$ is automatically invertible, with inverse $r^2 - 1$.** The reciprocal is a *polynomial* expression in $r$, so it makes sense in any ring with no division at all. Let us check this:

$$f_r(r^2 - 1) = (r^3 - r + 1)\, f_-(r) = 0 .$$

For the return trip, if $s$ is a root of $f_r$, then $s(s^2+s) = s^3 + s^2 = 1$, so $s^{-1} = s^2 + s$. This is a root of $f_-$, because $f_-(s^2+s) = (s^3 + 2s^2 + s + 1)\,f_r(s)$. Two more polynomial identities show that the maps undo each other on roots:

$$(r^2-1)^2 + (r^2-1) = r + r\,f_-(r), \qquad (s^2+s)^2 - 1 = s + (s+1)\,f_r(s).$$

On roots the error terms vanish, so the two maps are inverse bijections between the two root sets. Modulo 59 the reciprocals of $4, 13, 42$ are $15, 50, 52$, and these are the three roots of $x^3+x^2-1$.

> **Reciprocal invariance.** In every finite commutative ring, $x^3 + x^2 - 1$ and $x^3 - x - 1$ have the same number of roots. So all three generators share one type function.

Notice that this map is *not* a bijection of the whole ring. Modulo 6 the map $x \mapsto x^2 - 1$ sends both 1 and 5 to 0. Only on the roots does it become a perfect matching. That is the point of the "bijection between zero sets" principle.

## Why "the field"?

Why do these three polynomials belong together? A root of any one of them generates the same **number field**: the smallest system of numbers that contains the rationals and the root, and is closed under arithmetic. If $\rho$ is the plastic number, then $-\rho$ is a root of $f_+$ and $1/\rho = \rho^2 - 1$ is a root of $f_r$. All three roots are rational-polynomial expressions in $\rho$, and $\rho$ can be recovered from each of them. So they generate one field, which we call $K$. Each polynomial is a different *coordinate system*, a different "generator", for the same object.

The field has a fingerprint, its **discriminant**. For a cubic $x^3 + ax + b$ the discriminant is $-4a^3 - 27b^2$. With $a = -1$ and $b = \pm 1$ this is $4 - 27 = -23$ in both cases. Flipping the sign of $b$ never changes $b^2$. The negative discriminant tells us something about symmetry. The three roots can be permuted in all $3! = 6$ ways, so the symmetry group (the Galois group) is $S_3$, the full symmetric group on three letters.

At a prime $p$, the type $T(p)$ records how the "Frobenius" symmetry at $p$ acts on the three roots:

- $T(p) = 3$: Frobenius is the identity, and all three roots exist mod $p$ (one sixth of all primes).
- $T(p) = 1$: Frobenius swaps two roots, so one root exists (half of all primes).
- $T(p) = 0$: Frobenius cycles all three, so no root exists (one third of all primes).

Up to 20,000, the observed frequencies are $0.162$, $0.501$ and $0.337$.

## The sign law and the one-bit channel

Which primes give a single root? There is a classical answer, which goes back to Stickelberger's work on discriminants. For a prime $p$ other than 2 and 23, **each of the two cubics has exactly one root modulo $p$ if and only if $-23$ is not a perfect square modulo $p$.** Both polynomials obey the same law with the same discriminant. That is one more sign that the polynomial is not what matters.

This also explains the "1 bit". By quadratic reciprocity, whether $-23$ is a square mod $p$ depends only on $p \bmod 23$. So the label $p \bmod 23$ tells you exactly whether $p$ is in the "transposition" half (type 1) or the other half (type 0 or 3). Inside the other half, the label tells you nothing more. The theory predicts

$$I(p \bmod 23;\, T) = H(T) - \tfrac12 H\!\left(\tfrac23, \tfrac13\right) = 1 \text{ bit exactly.}$$

Here $H(T) = \tfrac13\log_2 3 + \tfrac12 + \tfrac16\log_2 6 \approx 1.459$ bits is the entropy of the type. The identity is pure group theory. Making it into a statement about limits of prime counts needs the Chebotarev density theorem. The measured $1.000065$ is that exact bit plus a small upward bias. Such bias is typical whenever information is estimated from a finite table with 22 label classes. Our own sample of 2,260 primes gives an excess of $0.00024$, which shrinks as the sample grows.

## Semiprimes: the Chinese remainder theorem at work

The experiments also used semiprimes $n = pq$. Here an old tool, the **Chinese remainder theorem**, settles the matter. When $p$ and $q$ share no factor, arithmetic modulo $pq$ is the same as doing arithmetic modulo $p$ and modulo $q$ at once. A root mod $pq$ is exactly a pair (root mod $p$, root mod $q$). Hence

$$T(pq) = T(p)\,T(q) \qquad \text{whenever } \gcd(p,q) = 1.$$

This gives $T(1357) = T(23)\,T(59) = 2 \cdot 3 = 6$. A consequence for information: the type of $pq$ is a *function* of the pair of types. Applying a function never creates information, so the entropy of $T(pq)$ is at most the entropy of the pair $(T(p), T(q))$. On all prime pairs below 120 these come out as $1.566$ and $2.683$ bits.

## Polynomials, not just numbers

The mirror $x \mapsto -x$ also works at the level of whole polynomials. Substituting $-X$ for $X$ is an automorphism of the polynomial ring, so it respects factorisation. Two consequences follow:

- Over any commutative ring, $x^3 - x + 1$ is irreducible exactly when $x^3 - x - 1$ is.
- Over any field, the two cubics have the same **factorisation type**: the multiset of degrees of their irreducible factors, $\{3\}$, $\{1,2\}$ or $\{1,1,1\}$ for a cubic.

The factorisation type is finer than the root count at the one bad prime, $p = 23$. There

$$x^3 - x - 1 \equiv (x - 3)(x - 10)^2 \pmod{23}.$$

There is a *double* root at 10. Counting distinct roots gives 2 and loses the multiplicity. The factorisation type does not lose it. Mathematicians call 23 *ramified* in this field.

## But the channel can tell fields apart

If the type ignored everything, the theorem would say nothing. It does not. Compare $x^3 - x - 1$ (discriminant $-23$) with $x^3 + x + 1$ (discriminant $-31$, a different cubic field). Already modulo 3 they differ. The first has no root, since $0 \mapsto 2$, $1 \mapsto 2$ and $2 \mapsto 2$. The second has the root $x = 1$, because $1 + 1 + 1 = 3 \equiv 0$. So the type channel forgets the polynomial but remembers the field.

## The moral

The slogan "the field, not the polynomial" is an old idea in algebraic number theory. Since Dedekind, mathematicians have known that the way primes split depends on the number field, and that a generating polynomial is like a choice of coordinates. Except at a few primes dividing an "index", any two generators give the same splitting data. This story makes the idea concrete in a sharp form. For these three generators there are no exceptional primes and no exceptional moduli. The equality holds in every finite ring, for an elementary reason: a matching between roots that comes from a polynomial formula.

So the experiment's matching six decimal places are not a lucky coincidence. They are what a theorem looks like when you see it through a finite sample.
