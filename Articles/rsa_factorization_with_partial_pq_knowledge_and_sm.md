# When a Few Leaked Bits Crack a Cipher: The Modified Wiener Attack on RSA

## A lock built from two prime numbers

Almost every secure connection you have ever made — buying a book, logging into a bank, sending an encrypted message — has at some point leaned on a number-theoretic puzzle so simple a child can state it and so hard that the world's computers cannot solve it in a hurry: *multiply two large prime numbers together, hand someone the product, and dare them to find the two factors.*

That product is called the **RSA modulus**, written $n = p \cdot q$, where $p$ and $q$ are large primes. The genius of RSA, the cryptosystem named for Rivest, Shamir, and Adleman, is that multiplying $p$ and $q$ is effortless while reversing the operation — *factoring* $n$ back into $p$ and $q$ — is, for well-chosen primes, astronomically expensive. Encryption hides behind that asymmetry. Anyone may know $n$; only someone who can split it into its prime factors holds the real key.

Alongside $n$, RSA publishes a second number, the **public exponent** $e$. The matching secret is the **private exponent** $d$, and the two are bound together by a single, unbreakable arithmetic law:

$$e \cdot d = k \cdot \varphi(n) + 1,$$

where $k$ is some positive integer and $\varphi(n) = (p-1)(q-1)$ is **Euler's totient** of $n$ — essentially $n$ with a small correction. This equation is the spine of the whole story. Notice what it quietly reveals: if you ever learn $\varphi(n)$, you have effectively factored $n$, because $n$ and $\varphi(n)$ together pin down $p$ and $q$. The security of RSA is the security of that totient.

## A temptation called "small $d$"

Decryption in RSA costs work proportional to the size of the private exponent $d$. So there is a constant, very human temptation: *make $d$ small to make decryption fast.* A small $d$ means snappier signatures on a smart card, less battery drained on a sensor, faster handshakes on a server.

In 1990, Michael Wiener showed this temptation is a trap. If the private exponent is too small — specifically smaller than roughly the fourth root of the modulus, $d < n^{1/4}$ — then RSA collapses entirely. An attacker who knows only the public pair $(n, e)$ can recover the secret $d$ and factor $n$, using nothing more exotic than a tool taught in elementary number theory: **continued fractions**.

This article is about a sharpened, *modern* version of Wiener's attack, and about a complete, machine-checked chain of reasoning that carries it all the way from "the exponent is small" to "here are your two primes." The sharpening is this: **what if the attacker also knows a few of the leading digits of $p+q$?** It turns out that even a modest leak of the *most significant bits* of the prime sum makes the attack hungrier — it devours private exponents far larger than Wiener's original $n^{1/4}$.

## Why $k/d$ hides in plain sight

Here is the central magic trick. Take the key equation $e \cdot d = k \cdot \varphi(n) + 1$ and divide everything by $d \cdot n$. After a little rearranging you find that the fraction $k/d$ — built entirely from secret quantities — is an *uncannily good* approximation of the public fraction $e/n$:

$$\frac{e}{n} \approx \frac{k}{d}.$$

How good? The error is controlled by how much $n$ differs from $\varphi(n)$, and that difference is exactly $p + q - 1$, a number roughly the size of $\sqrt{n}$ — tiny compared to $n$ itself. So $k/d$ shadows $e/n$ with almost eerie fidelity.

Now comes a classical theorem of Diophantine approximation, due to Legendre. It says that if a fraction $k/d$ approximates a real number to within $1/(2d^2)$, then $k/d$ is *forced* to appear among the **continued-fraction convergents** of that number. Convergents are the best rational approximations to a number that you can build with small denominators — the "greatest hits" of approximating fractions. There are only a handful of them, and they are cheap to compute.

So the attack writes itself:

1. Compute the continued-fraction convergents of the *public* number $e/n$.
2. The secret fraction $k/d$ must be one of them.
3. Test each candidate; the right one unlocks $\varphi(n)$, and from $\varphi(n)$ you factor $n$.

The whole secret falls out of a list of fractions anyone can compute from public data — provided $d$ was small enough for $k/d$ to clear Legendre's bar. That bar is what limits the classical attack to $d < n^{1/4}$.

## Buying a bigger attack with leaked bits

The modified attack asks a sharper question. The error in the approximation $e/n \approx k/d$ comes from the gap between $n$ and $\varphi(n)$ — that is, from $p+q$. What if we could *shrink* that gap?

Suppose an attacker has learned a **$\delta$-fraction of the most significant bits of $p+q$** — through a side channel, a timing leak, a fault, or partial key exposure. Call the resulting estimate $s$. We do not need $s$ to be exact; we only need it close. Then, instead of approximating $e/n$, we approximate $e/\tilde{n}$ where

$$\tilde{n} = n + 1 - s$$

is a **corrected modulus**. The beauty is that this correction is *exact arithmetic*, not a heuristic. If the estimate were perfect ($s = p+q$), the corrected modulus would equal the totient itself: $\tilde n = \varphi(n)$. In that ideal case the approximation $e/\tilde n \approx k/d$ becomes razor-sharp.

In general, the residual error of the approximation is governed not by the full $p+q$ but by the much smaller *estimation error* $(p+q) - s$. Let $\Delta$ bound that residual, $|(p+q) - s| \le \Delta$. The smaller $\Delta$ — the more leading bits we know — the larger a private exponent we can still break. Concretely, the attack succeeds whenever the **partial-knowledge smallness condition**

$$2 \cdot d \cdot (k\Delta + 1) < \tilde n$$

holds. Read it as a budget: every leaked bit of $p+q$ roughly halves $\Delta$, and each halving relaxes the bound, admitting private exponents up to about $n^{(1+\delta)/2}$. At $\delta = 0$ (no bits known) it reproduces Wiener's classical $n^{1/4}$; as $\delta$ grows toward $1$, the danger zone swells toward $\sqrt n$. A "small $d$" is no longer a quarter-root nicety — with a side channel, "small" can mean *almost half the bits of $n$.*

## The exact identity at the heart of it

What makes this rigorous rather than hand-wavy is that every step is an *exact algebraic identity*, not an approximation glued together with hope. The corrected key identity states precisely:

$$e \cdot d - k \cdot \tilde n = 1 - k\bigl((p+q) - s\bigr).$$

The residual on the right is governed entirely by the estimation error $(p+q)-s$. Turning that into a statement about fractions gives the *exact* approximation error

$$\frac{e}{\tilde n} - \frac{k}{d} = \frac{1 - k\bigl((p+q)-s\bigr)}{\tilde n \cdot d},$$

and bounding the numerator by $k\Delta + 1$ yields

$$\left|\frac{e}{\tilde n} - \frac{k}{d}\right| \le \frac{k\Delta + 1}{\tilde n \cdot d}.$$

The smallness condition $2d(k\Delta+1) < \tilde n$ is exactly what drives this below Legendre's threshold $1/(2d^2)$ — which is the green light that $k/d$ is a convergent of $e/\tilde n$.

## Uniqueness: why you recover the *right* exponent

Finding a convergent is one thing; being *sure* it is the true private exponent is another. What stops two different fractions from both sneaking under Legendre's threshold and leaving the attacker guessing?

The answer is a gem from the theory of the **Farey sequence**: two *distinct* fractions $a/b$ and $c/e$ can never huddle arbitrarily close. They are always at least $1/(b \cdot e)$ apart:

$$\left|\frac{a}{b} - \frac{c}{e}\right| \ge \frac{1}{b \cdot e}.$$

This is the integer rigidity of rational numbers — fractions with small denominators are spread out, like fence posts that cannot be closer than a fixed spacing. Now suppose two candidate fractions, the true $k/d$ and some impostor $a/b$ with denominator $b \le d$, *both* approximate $e/\tilde n$ to within $1/(2d^2)$. By the triangle inequality they would have to be within $1/d^2$ of each other. But Farey separation insists they are at least $1/(d \cdot b) \ge 1/d^2$ apart. The two demands collide. The only escape is that there *is* no impostor: the fraction is unique.

One more turn of the screw delivers the exponent exactly. If the true fraction $k/d$ is in lowest terms — $k$ and $d$ share no common factor — then equality of the fractions forces the denominators themselves to match: the recovered $b$ *equals* the true private exponent $d$. Notably, the impostor need not be in lowest terms for this to work; the rigidity of the true fraction alone suffices.

## The last mile: from $d$ to the primes

Recovering $d$ is a triumph, but it is not the attacker's actual goal. The goal is to *factor* $n$ — to name $p$ and $q$. Many accounts of Wiener's attack stop at "and then you have $d$," waving at the rest. The complete chain insists on finishing the job, and the finish is elegant.

Once $d$ (and the cofactor $k$) is known, the key equation hands you the totient directly:

$$k \cdot \varphi(n) = e \cdot d - 1.$$

From $\varphi(n)$ and $n$ you get the prime sum for free, because $n - \varphi(n) + 1 = p + q$. Now you know both the **sum** $S = p+q$ and the **product** $N = pq = n$ of the two primes. Schoolroom algebra says $p$ and $q$ are the two roots of the quadratic

$$X^2 - S\,X + N = 0,$$

and the quadratic formula gives them in closed form:

$$p = \frac{S + \sqrt{S^2 - 4N}}{2}, \qquad q = \frac{S - \sqrt{S^2 - 4N}}{2}.$$

Here lies the most satisfying structural surprise of the whole story. The discriminant under that square root is not some messy irrational — it is a *perfect square*:

$$S^2 - 4N = (p+q)^2 - 4pq = (p-q)^2.$$

So $\sqrt{S^2 - 4N} = p - q$ *exactly*, with no rounding, no approximation, no numerical error. The square root that usually injects irrationality into the quadratic formula here closes perfectly into an integer. Recovering $d$ and factoring $n$ are revealed to be two faces of one fact — *information-theoretically equivalent*, joined at the hip by a perfect square.

## A worked example you can check by hand

Take the toy primes $p = 17$ and $q = 11$, so $n = 187$ and $\varphi(n) = 16 \cdot 10 = 160$. Choose the public exponent $e = 7$; the matching private exponent is $d = 23$ with cofactor $k = 1$ (indeed $7 \cdot 23 = 161 = 1 \cdot 160 + 1$). Grant the attacker a perfect estimate of the prime sum, $s = p + q = 28$, so the corrected modulus is $\tilde n = 187 + 1 - 28 = 160$.

Now compute the approximation error:

$$\frac{e}{\tilde n} - \frac{k}{d} = \frac{7}{160} - \frac{1}{23} = \frac{1}{3680}.$$

Legendre's threshold here is $1/(2 \cdot 23^2) = 1/1058$, and indeed $1/3680 < 1/1058$. The convergent test fires: $k/d = 1/23$ is recovered. Farey separation is realized *with equality* in this instance — $|1/23 - 7/160| = 1/3680 = 1/(23 \cdot 160)$ — a clean illustration that the bound is sharp, not slack.

With $d = 23$ in hand: $\varphi(n) = (e\,d - 1)/k = 160$, so $S = n - \varphi(n) + 1 = 187 - 160 + 1 = 28$. The discriminant is $28^2 - 4 \cdot 187 = 784 - 748 = 36 = 6^2$, a perfect square as promised. The quadratic formula returns

$$p = \frac{28 + 6}{2} = 17, \qquad q = \frac{28 - 6}{2} = 11.$$

The modulus $187$ is factored. The whole journey — from a small private exponent and a few known bits, through continued fractions, Farey rigidity, and a perfect-square discriminant — lands exactly on its prime factors.

## What it means for the rest of us

The lesson is not that RSA is broken. Properly used, with a large private exponent and no side leaks, it stands. The lesson is about *margins*. Cryptographic safety is not a wall; it is a set of conditions, and each shortcut — a small exponent here, a leaked bit there — chips at the conditions until they fail all at once. The modified Wiener attack quantifies that erosion with brutal precision: it shows exactly how many leaked bits of $p+q$ buy how much extra reach, and it proves that once the smallness condition tips, the secret does not degrade gracefully. It falls out whole, primes and all.

It is a reminder that in cryptography, *partial* information is rarely partial in effect. A few most-significant bits of a quantity you thought was hidden, a private exponent shaved a little too small for speed — each seems harmless in isolation. Combined, and pressed against the unyielding arithmetic of continued fractions and Farey separation, they unlock the whole door. The mathematics that makes RSA strong is the very same mathematics that, given an inch, takes the entire mile.
