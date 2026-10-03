# Five Fields, One Law: Why a Prime's Remainder Knows Exactly One Bit About a Cubic

*How a single coin flip, hidden inside the symmetries of three roots, explains a pattern that kept turning up in experiments*

---

## A pattern that would not go away

Take the cubic polynomial

$$f(x) = x^3 - 4x + 1 .$$

Over the real numbers it has three roots, roughly $-2.1149$, $0.2541$ and $1.8608$. Number theorists, though, like to look at a polynomial through many lenses at once. For each prime $p$ they ask how many solutions $f(x) \equiv 0 \pmod p$ has among the integers $0, 1, \dots, p-1$.

Try a few primes. Modulo $3$, plug in $x = 0, 1, 2$: you get $1, 1, 1$ modulo $3$, so there are no roots. Modulo $461$, a short search turns up exactly three roots: $162$, $368$ and $392$. Other primes give exactly one root. And, as we will see, the number of roots is never two.

That count of $0$, $1$ or $3$ roots is called the **splitting type** of the prime. It is a small fingerprint of how the prime behaves inside the number system built from the roots of $f$. The fingerprint looks random. Over the first eighteen thousand odd primes, about a third have no root, about half have one root and about a sixth have three. Nobody can predict the type of the next prime by looking at it.

Now add a second piece of data: the remainder of $p$ when divided by $229$. Why $229$? It is the **discriminant** of $f$, the number $-4a^3 - 27b^2$ for a cubic $x^3 + ax + b$. Here that is $-4(-4)^3 - 27 = 256 - 27 = 229$, which happens to be prime.

Experiments in this line of work kept measuring one quantity: how much information the remainder $p \bmod 229$ gives about the splitting type. The measuring stick was Shannon's **mutual information**, counted in bits. Over many primes the estimate came out at $1.0078$ bits. Four other cubic fields, with four other discriminants, had already given values just as close to $1$. So this was the fifth field and the fifth time the answer was one bit.

Five unrelated polynomials and five unrelated primes in the role of $229$, yet the same answer every time. That points to a law, and this article explains what the law is and why it holds.

---

## The secret life of three roots

The starting point is a 19th-century idea of Galois. The three roots of $f$ cannot be told apart by any rational equation. Any symmetry of the number system they generate simply shuffles them, so the symmetries form a group of permutations of three objects. For our cubic it is the whole **symmetric group** $S_3$, with all six permutations of $\{1,2,3\}$:

* the identity, which moves nothing;
* three **transpositions**, each swapping two roots and fixing one;
* two **3-cycles**, each moving every root one step around a triangle.

Each prime $p$ (apart from $229$) picks out one of these permutations, called its **Frobenius element**. Informally, it is how "raising to the $p$-th power" shuffles the roots when you reduce modulo $p$. The number of roots of $f$ modulo $p$ is exactly the number of roots the Frobenius element leaves in place:

* identity: $3$ fixed roots, so $f$ splits completely mod $p$;
* a transposition: $1$ fixed root;
* a 3-cycle: $0$ fixed roots, so $f$ has no root mod $p$ ("inert").

No permutation of three objects fixes exactly two of them, and this is why the root count is never $2$.

The **Chebotarev density theorem**, a deep result from the 1920s, says that Frobenius elements are spread evenly over the group. So in the long run the identity appears $1/6$ of the time, transpositions $3/6 = 1/2$ of the time and 3-cycles $2/6 = 1/3$ of the time. These are the frequencies $1/6$, $1/2$, $1/3$ seen in the data.

---

## The hidden coin: the sign of a permutation

Every permutation has a **sign**, $+1$ or $-1$, which records whether it can be built from an even or an odd number of swaps. In $S_3$:

* the identity and the two 3-cycles are **even** (sign $+1$);
* the three transpositions are **odd** (sign $-1$).

Look at what the root count tells you about the sign:

| root count | Frobenius | sign |
|---|---|---|
| $3$ | identity | $+1$ |
| $1$ | transposition | $-1$ |
| $0$ | 3-cycle | $+1$ |

The root count **determines the sign**: exactly one root means odd, and anything else means even. The sign does not determine the root count, though. An even sign leaves open both "three roots" and "no roots".

The sign is a coin flip hidden inside the Frobenius element, and it lands heads exactly half the time.

---

## The coin is readable from the remainder

Here is the arithmetic heart of the story, proved for the cubic $x^3 - 4x + 1$.

> **Splitting-Type Law.** Let $p$ be a prime other than $2$ and $229$. Then $x^3 - 4x + 1$ has exactly one root modulo $p$ if and only if $p$ is a quadratic non-residue modulo $229$, that is, $p$ is not congruent to a perfect square modulo $229$.

Put differently, the sign of the Frobenius element equals the **Legendre symbol** $\left(\tfrac{p}{229}\right)$, the classical $\pm 1$ marker that says whether $p$ is a square modulo $229$. That marker depends **only on the remainder of $p$ modulo $229$**, so the coin can be read straight off the remainder.

The proof has three steps, each of them elementary.

**Step 1: the discriminant is a perfect square of something built from the roots.** Suppose $r$ and $s$ are two different roots of $f$ in some number system. Subtracting $f(r) = 0$ from $f(s) = 0$ and dividing by $r - s$ gives
$$r^2 + rs + s^2 = 4, \qquad rs(r+s) = 1,$$
and the third root has to be $-(r+s)$. A short calculation then gives the identity
$$\big((r-s)(r+2s)(2r+s)\big)^2 = 4\,(r^2+rs+s^2)^3 - 27\,\big(rs(r+s)\big)^2 = 4\cdot 64 - 27 = 229.$$
The quantity $\delta = (r-s)(r+2s)(2r+s)$ is just the product of the three differences of roots, and its square is the discriminant. One immediate consequence: if $229$ is **not** a square modulo $p$, the cubic cannot have two different roots modulo $p$.

**Step 2: no root forces the discriminant to be a square (Stickelberger's phenomenon).** Suppose $f$ has no root modulo $p$. Then the roots live in a field with $p^3$ elements, and the map $y \mapsto y^p$ permutes them without fixing any of them. A permutation of three things with no fixed points is a 3-cycle, and a 3-cycle is even, so it leaves the product of differences $\delta$ unchanged: $\delta^p = \delta$. The only elements with $\delta^p = \delta$ are the ordinary integers modulo $p$. So $\delta$ is an integer mod $p$ whose square is $229$, which means $229$ is a square modulo $p$.

**Step 3: one root plus a square discriminant gives all three roots.** If $r$ is a root, the identity
$$(16 - 3r^2)(3r^2 - 4)^2 = 229$$
holds. It says that the discriminant of the leftover quadratic factor, multiplied by a square, equals $229$. So when $229$ is a square, the quadratic factor splits too, and one root brings two more with it.

Together: one root holds exactly when $229$ is a non-square modulo $p$. Then **quadratic reciprocity**, Gauss's "golden theorem", turns "$229$ is a square mod $p$" into "$p$ is a square mod $229$". There is no sign correction, because $229$ leaves remainder $1$ on division by $4$.

As a check, every one of the 17,982 odd primes up to $200{,}000$ (leaving out $229$) obeys the law, and none of them has exactly two roots.

---

## Exactly one bit, and why

What does the remainder $p \bmod 229$ tell you about the splitting type?

* If $p$ is a **non-residue**, the coin shows "odd", so the type is certainly "one root". You know everything.
* If $p$ is a **residue**, the coin shows "even", so the type is "three roots" or "no roots", with odds $1:2$ (the identity against the two 3-cycles). Some uncertainty remains.

Mutual information makes this precise. The **entropy** of the splitting type, its unpredictability in bits, is
$$H(T) = \tfrac16\log_2 6 + \tfrac12\log_2 2 + \tfrac13\log_2 3 = \tfrac23 + \tfrac12\log_2 3 \approx 1.459 \text{ bits}.$$
After you learn the remainder, the uncertainty left over is
$$H(T \mid \text{class}) = \tfrac12\cdot h\!\left(\tfrac13\right) = \tfrac12\log_2 3 - \tfrac13 \approx 0.459 \text{ bits},$$
where $h(q) = -q\log_2 q - (1-q)\log_2(1-q)$ is the binary entropy. The information gained is the difference:
$$I(T;\, p \bmod 229) = 1.459\ldots - 0.459\ldots = 1 \text{ bit, exactly.}$$

This is not a coincidence of decimals. The remainder carries exactly the sign coin, and a fair coin is worth exactly one bit.

The leftover uncertainty does occur. The primes $3$ and $461 = 3 + 2\cdot 229$ have the **same** remainder modulo $229$. Yet $f$ has no root modulo $3$ and three roots modulo $461$. Knowing the remainder pins down the coin, but not which even permutation you got.

---

## The law behind the five laws

Why would five different fields all give $1$? Because the argument above never really used the polynomial. It only used the *shape* of the situation, and that shape is general.

Think of two random objects that are tied together only through a shared "summary":

* a group element $\sigma$, chosen uniformly from a finite group $G$ (the Frobenius element);
* a residue class $r$, chosen uniformly from a finite group $R$ (the remainder);
* a common quotient $\Delta$ with maps $\varepsilon: G \to \Delta$ and $\chi: R \to \Delta$ (the sign and the Legendre symbol), whose fibres all have the same size.

The pair $(\sigma, r)$ is drawn uniformly from all pairs with $\varepsilon(\sigma) = \chi(r)$. Mathematicians call this set the **fibre product**. In arithmetic, Chebotarev's theorem combined with the theory of abelian extensions says that, statistically over many primes, Frobenius elements and residue classes behave like this. This is the model in which the law is stated.

> **Fibre-Product Law.** If the observed feature $\tau(\sigma)$ determines the summary $\varepsilon(\sigma)$, then the mutual information between $\tau(\sigma)$ and $r$ equals $\log_2 |\Delta|$, *whatever* $G$, $R$ and $\tau$ are.

The proof is a single observation. Mutual information is an average of logarithms of ratios of the form
$$\frac{\Pr[\tau = v,\ r = c]}{\Pr[\tau = v]\,\Pr[r = c]} .$$
Count the pairs, and every ratio that is not zero turns out to equal $|\Delta|$. There are no cancellations to chase and no estimates to make: every term is the same.

For any symmetric group $S_n$ with $n \ge 2$, the cycle type determines the sign, and $\Delta = \{\pm 1\}$ has two elements. So:

> **Universal Symmetric-Group Law.** For every $n \ge 2$ and every odd prime conductor $\ell$, the channel from cycle type to residue class modulo $\ell$ carries exactly $\log_2 2 = 1$ bit.

The "five fields" are five instances of one formula. The numbers $229$, the earlier discriminants and the particular cubics all drop out. What is left is the size of the shared summary, which is two.

There are matching boundary cases. If the shared summary is trivial, so that the two random objects are completely independent, the channel carries **zero** bits. If the feature you observe does *not* determine the summary, you get less than a bit. For example, the number of fixed points of a permutation of four objects does not determine its sign, and that channel gives about $0.656$ bits.

---

## And the extra $0.0078$?

If the true value is exactly $1$, where did $1.0078$ come from? It comes from estimating information from a finite sample. A table of $228$ residue classes against $3$ types, filled in with a few thousand primes, always contains small chance fluctuations, and the simple "plug-in" estimate counts them as signal. Statisticians have known this bias since the 1950s (the Miller–Madow correction): it is positive and shrinks roughly like $1/N$ in the sample size.

The numbers behave as expected. With the first $1{,}000$ odd primes the estimate is about $1.074$; with $5{,}000$, about $1.011$; with $10{,}000$, about $1.0045$; and with all $17{,}982$ odd primes below $200{,}000$, about $1.0023$. The excess goes down steadily as more primes are added. The huge "$z$-score" reported in the experiments measures how far $1$ bit is from $0$ bits, which is real. The $0.0078$ above $1$ is noise.

---

## Why this matters

There are three lessons here.

**First, an experiment pointed to a theorem.** A number that came out the same five times was a sign of structure, and once found, that structure explains the observations rather than just agreeing with them.

**Second, information theory and Galois theory fit together naturally.** "How many bits does the remainder carry?" turns out to be the question "how large is the abelian shadow of the symmetry group?" in other words, how much of the symmetry is visible to congruences. For $S_3$, $S_4$, $S_5$ and beyond, that shadow is the sign, which is one bit.

**Third, the sharp law makes better experiments possible.** Since the true value is known exactly, any measured excess can be read as a calibration of the estimator. That turns a source of confusion into a check on the method.

The same reasoning suggests what should happen for other symmetry groups. Quartic fields with the dihedral group of order $8$ should carry $2$ bits, and fields with the alternating group $A_4$ should carry $\log_2 3 \approx 1.585$ bits, wherever the observed feature determines the abelian shadow. These are predictions for now, not theorems, but they rest on the same identity: in a fibre product, every term of the information sum equals the size of the shared quotient.
