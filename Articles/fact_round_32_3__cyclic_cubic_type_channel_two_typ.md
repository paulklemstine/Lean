# The Prime That Tells You Everything

## How a single remainder decides the fate of a number field — and why multiplying two primes destroys exactly one bit's worth of that knowledge

Take a prime number — say $29$ — and divide it by $7$. The remainder is $1$. That is a completely elementary piece of information: a schoolchild can compute it, and it costs nothing.

Now here is the surprising part. That single remainder tells you, with absolute certainty and no residual doubt whatsoever, how the prime $29$ behaves inside a certain three-dimensional world of numbers — a world built from the seventh roots of unity, where $29$ either shatters into three pieces or stays stubbornly whole. The remainder does not merely *suggest* the answer, or make it likely. It *determines* it.

This article is about measuring that determination. Not proving it exists — that has been known since the nineteenth century — but weighing it, in bits, the same currency an engineer uses to measure the capacity of a telephone line. The result is a clean number, and then a second, stranger number: what happens to that certainty when you multiply two primes together and hand someone only the product.

---

## A field made from a heptagon

Draw a regular heptagon in the plane with its centre at the origin and one vertex at $1$. Its vertices are the seventh roots of unity: the seven complex numbers $\zeta^k$ with $\zeta = e^{2\pi i/7}$. Take one of them and add it to its mirror image across the real axis:

$$\alpha = \zeta + \zeta^{-1} = 2\cos\!\left(\tfrac{2\pi}{7}\right) \approx 1.24698.$$

This $\alpha$ is not a rational number, but it is not wildly transcendental either. It satisfies an honest cubic equation with integer coefficients:

$$f(x) = x^3 + x^2 - 2x - 1 = 0.$$

You can verify this from the identity $y^3 f\!\left(y + y^{-1}\right) = 1 + y + y^2 + \cdots + y^6$, valid for any nonzero $y$: if $y$ is a seventh root of unity other than $1$, the right-hand side is zero, so $y + y^{-1}$ is a root of $f$. The three roots of $f$ are the three quantities $2\cos(2\pi k/7)$ for $k = 1, 2, 3$, and the field $K = \mathbb{Q}(\alpha)$ they generate is a three-dimensional vector space over the rationals. It is the smallest genuinely cubic field with a completely symmetric structure — its symmetry group is the cyclic group of order three, which is why it is called a *cyclic cubic field*. Its **conductor** is $7$: the modulus that governs everything about it.

## Two types, and only two

Every prime $p \neq 7$ does one of two things when you drop it into $K$. Either the cubic $f$ factors completely into linear pieces modulo $p$ — the prime *splits*, breaking into three distinct prime ideals, each with residue degree $1$ — or $f$ stays irreducible modulo $p$ and the prime remains *inert*, a single prime ideal of residue degree $3$.

There is, remarkably, no middle case. Suppose $x$ is a root of $f$ modulo $p$. Then the "twisted" element $x^2 - 2$ is also a root — this is the shadow of the map $\zeta + \zeta^{-1} \mapsto \zeta^2 + \zeta^{-2}$, which squares the underlying root of unity — and one can check directly that $x^2 - 2 \neq x$ and $(x^2-2)^2 - 2 \neq x$ whenever $7 \neq 0$ in the ring. So one root instantly manufactures three distinct roots. Splitting is all-or-nothing.

Which of the two happens? Here is the law:

> **The Cyclic Cubic Splitting Criterion.** For a prime $p \neq 7$, the cubic $x^3 + x^2 - 2x - 1$ has a root modulo $p$ — equivalently, $p$ splits completely in $K$ — if and only if $p \equiv \pm 1 \pmod 7$. Otherwise $f$ is irreducible modulo $p$ and $p$ is inert.

Since $\{1, 6\}$ is exactly $\{\pm 1\}$ modulo $7$, the split primes are $13, 29, 41, 43, 71, 83, \ldots$ and the inert primes are $2, 3, 5, 11, 17, 19, \ldots$ Two of the six invertible residue classes mean "split", four mean "inert".

There is a beautiful way to see the hard direction, and it has nothing to do with the number $7$ specifically. Attach to a number $x$ the $2\times 2$ matrix
$$M(x) = \begin{pmatrix} x & -1 \\ 1 & 0\end{pmatrix},$$
the companion matrix of $Y^2 - xY + 1$. It has determinant $1$ and trace $x$, and it satisfies $M^2 = xM - I$. Iterating that relation gives $M^{n+1} = A_{n+1}(x)\,M - A_n(x)\,I$, where the *Chebyshev-type coefficients* are defined by $A_0 = 0$, $A_1 = 1$, and $A_{n+2}(t) = t\,A_{n+1}(t) - A_n(t)$. If $x$ is a root of $f$ modulo $p$, a short computation shows $A_7(x) = 0$ and $A_6(x) = -1$, so $M(x)^7 = I$ while $M(x) \neq I$: we have produced an element of order exactly $7$ inside the group $SL_2(\mathbb{F}_p)$. But the possible orders of elements of $SL_2(\mathbb{F}_p)$ are tightly constrained — a non-scalar element of order $m$ coprime to $p$ forces $m \mid p^2 - 1$. With $m = 7$ that says $7 \mid p^2 - 1 = (p-1)(p+1)$, that is, $p \equiv \pm 1 \pmod 7$.

The argument never used the number $7$. Run it with $m = 5$ and you recover the classical Fibonacci criterion: $x^2 + x - 1$ has a root modulo $p$ exactly when $p \equiv \pm 1 \pmod 5$ — the golden ratio lives in $\mathbb{F}_p$ precisely for those primes. Run it with $m = 11$ and the quintic $x^5 + x^4 - 4x^3 - 3x^2 + 3x + 1$, the minimal polynomial of $\zeta_{11} + \zeta_{11}^{-1}$, has a root modulo $p$ exactly when $p \equiv \pm 1 \pmod{11}$. One mechanism, all conductors.

---

## Weighing certainty in bits

Now we change languages. Instead of asking *whether* the remainder determines the type, we ask *how much information* it carries — in the sense of Claude Shannon, the engineer's sense, where the unit is the bit.

Model a random prime by its remainder modulo $7$. By Dirichlet's theorem on primes in arithmetic progressions, the six invertible classes $1, 2, 3, 4, 5, 6$ occur with equal frequency $1/6$. Let $R$ be that remainder and let $T$ be the resulting splitting type: $T = \text{split}$ if $R \in \{1, 6\}$, otherwise $T = \text{inert}$.

The type is not a fair coin. It is split with probability $2/6 = 1/3$ and inert with probability $4/6 = 2/3$. Its Shannon entropy — the average number of yes/no questions needed to learn it — is
$$H(T) = -\tfrac13\log_2\tfrac13 - \tfrac23\log_2\tfrac23 = \log_2 3 - \tfrac23 = 0.918296\ldots \text{ bits}.$$
A biased coin, worth a bit less than one full bit. (Sampling actual primes and estimating the entropy empirically returns $0.9179$ bits — the closed form, to the accuracy of the sample.)

The remainder itself is worth more: $H(R) = \log_2 6 = 1 + \log_2 3 \approx 2.585$ bits. And the *joint* entropy of the pair $(R, T)$ — the uncertainty in knowing both at once — is also exactly $\log_2 6$, because once you know $R$ there is nothing left to learn about $T$.

Mutual information, the quantity that measures how much one variable reveals about another, is $I(R;T) = H(R) + H(T) - H(R,T)$. Substituting:
$$I(R \,;\, T) = (1 + \log_2 3) + \left(\log_2 3 - \tfrac23\right) - (1 + \log_2 3) = \log_2 3 - \tfrac23 = H(T).$$

> **Full Pinning Theorem.** For the cyclic cubic field of conductor $7$, the residue modulo $7$ and the splitting type satisfy $I(R;T) = H(T) = \log_2 3 - 2/3 \approx 0.9183$ bits. The channel from remainder to type is perfect: it transmits the type's entire entropy and not a fraction of a bit less.

The word "pinned" is apt. There is a general ceiling here that no channel can exceed. For *any* joint distribution on a pair of finite variables, merging the fibres of one coordinate can only lose entropy, from which one deduces the **data-processing ceiling** $I(X;Y) \le H(X)$ and $I(X;Y) \le H(Y)$. Our channel does not merely come close to the ceiling $H(T)$; it sits on it.

And the reason is structural, not numerological. Here is a general statement whose proof is three lines:

> **Determinism Saturates the Ceiling.** If the second coordinate of a joint distribution is a function of the first — that is, the law is supported on the graph of some map $g$, with weight $v(a)$ at the point $(a, g(a))$ — then the joint entropy equals the entropy of the first marginal, and consequently $I(X;Y) = H(Y)$ exactly.

The splitting law $p \equiv \pm 1 \pmod 7 \Leftrightarrow$ split says precisely that the type is a *function* of the remainder. Full pinning follows immediately, without ever computing a logarithm. The two closed forms $\log_2 3 - 2/3$ agreeing on both sides of the equation is not a coincidence to be marvelled at; it is a shadow of the fact that the law is a function. Information theory has detected class field theory.

---

## Then you multiply, and something breaks

Cryptography is built on a simple asymmetry: multiplying two large primes is easy, and recovering them from the product is believed to be hard. So it is natural to ask what happens to our perfect channel when it is fed a *semiprime* $N = pq$ instead of a prime.

You are told $N \bmod 7$. What can you say about the splitting types of the two hidden factors?

The right way to see it is through the group structure. The invertible residues modulo $7$ form a cyclic group of order $6$, and the "split" classes $\{1, 6\} = \{\pm 1\}$ form a subgroup $H$ of index $3$. The type of $p$ is simply the question *does $p$ lie in $H$?* The quotient group $(\mathbb{Z}/7)^\times / H$ is cyclic of order $3$; call its elements $1, \omega, \omega^2$. Knowing $N \bmod 7$ tells you the coset of $N$, which is the *product* of the cosets of $p$ and $q$ — and that is all it tells you.

Now count. If $N$ lies in the trivial coset, the cosets of $p$ and $q$ multiply to $1$, so they are either both trivial (both primes split) or an inverse pair $\{\omega, \omega^2\}$ (neither splits). Either two factors split or zero do — but never exactly one. If $N$ lies in a nontrivial coset, the possibilities are one trivial and one nontrivial (exactly one factor splits) or two equal nontrivial cosets (neither splits). So the residue narrows things down considerably, but never all the way.

Turning the crank on the same entropy machine — with $p$ and $q$ independent and uniform on the six invertible classes, and the observable being the unordered pair of types, encoded as the number $S \in \{0,1,2\}$ of split factors — gives the exact numbers. The distribution of $S$ is $\Pr[S=2] = 1/9$, $\Pr[S=1] = 4/9$, $\Pr[S=0] = 4/9$, with entropy $H(S) = 2\log_2 3 - 16/9 \approx 1.3921$ bits, and the joint entropy with the residue is $2\log_2 3 + 1/3$. Therefore:

> **Semiprime Degradation Theorem.** For $N = pq$ with independent factors, $I(N \bmod 7\,;\, S) = \log_2 3 - 10/9 = 0.473852\ldots$ bits — strictly less than $H(S)$. Pinning is destroyed by multiplication. (Empirically: $0.4747$ bits.)

Better still, the *amount* by which it is destroyed is exactly recognisable:

> **Exact Deficit Theorem.** The gap between the ceiling and the transmitted information is $H(S) - I = \left(2\log_2 3 - \tfrac{16}{9}\right) - \left(\log_2 3 - \tfrac{10}{9}\right) = \log_2 3 - \tfrac23 = H(T).$

The information lost in multiplying two primes is *exactly one type's worth of entropy* — one full label, $0.9183$ bits, no more and no less. Multiplication does not blur the picture by some awkward transcendental amount; it deletes precisely one of the two labels and leaves the other intact.

## Zero bits about which is which

There is one more question, and its answer is the crispest of all. Suppose you are told $N \bmod 7$ and, generously, the unordered pair of types — say, "exactly one of your two factors splits". Does the residue give you any hint about *which* one?

Encode the ordered pair of types as $(T_p, T_q)$. Its entropy is $H(T_p, T_q) = 2\log_2 3 - 4/3 \approx 1.8366$ bits, exactly $4/9 \approx 0.444$ bits more than the unordered version — that extra $4/9$ is the raw "which-factor" uncertainty, and it is genuinely there. But the joint entropy of the residue with the *ordered* pair works out to $2\log_2 3 + 7/9$, and the mutual information is

$$I(N \bmod 7 \,;\, (T_p, T_q)) = \log_2 3 - \tfrac{10}{9},$$

*identical* to the unordered value.

> **Which-Factor Blindness Theorem.** $I(N \bmod 7\,;\,(T_p,T_q)) - I(N \bmod 7\,;\, S) = 0$ exactly. The residue reveals the multiset of types as well as it possibly can, and precisely nothing — zero bits, not a rounding-error's worth — about which factor carries which type.

The reason is a perfect symmetry: for every residue class $n$, the number of factorisations $n = uv$ with ordered type pattern $(b_1, b_2)$ equals the number with pattern $(b_2, b_1)$. Multiplication is commutative, and commutativity is a symmetry of the channel, so the channel cannot break the tie. The $4/9$ bits of which-factor entropy sit there in plain view, entirely inaccessible from the residue.

---

## Why any of this matters

Three thoughts.

First, it is a clean demonstration that **information theory can see algebraic structure**. Full pinning — a channel achieving its theoretical ceiling with no slack — is equivalent to the statement that the splitting type factors through the residue modulo $m$. By the Kronecker–Weber theorem, the fields for which such a modulus exists are exactly the abelian ones. So "this channel has zero deficit" and "this field is abelian" are the same sentence in two languages. A non-abelian cubic field, such as the one generated by a root of $x^3 - x - 1$, cannot have a fully pinned residue channel for any modulus whatsoever: its deficit is strictly positive, and computable.

Second, it quantifies a cryptographic intuition that is usually stated only qualitatively. "Multiplying two primes hides them" is a slogan; "multiplying two primes destroys exactly $\log_2 3 - 2/3$ bits of splitting-type information and exactly all of the which-factor information" is a theorem. The leakage that *does* survive — nearly half a bit about the type multiset — is real and free to compute, and the leakage that does not survive is provably, exactly zero.

Third, and most simply, it is pretty. A regular heptagon, a cubic polynomial, a $2\times 2$ matrix of order seven, a biased coin worth $0.9183$ bits, and the fact that the two split classes among six force the numbers $\log_2 3 - 2/3$ and $\log_2 3 - 10/9$ into existence — all of it hangs together, and the same argument that handles the heptagon handles the pentagon and the hendecagon without modification. Ask a prime for its remainder modulo $7$ and it will tell you the truth about a three-dimensional universe. Multiply two primes and the universe withholds exactly one label — no more, no less.
