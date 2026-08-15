# The Dial That Cannot Be Turned Past 0.3113

## A hard ceiling on what a "yes/no" question about a semiprime can tell you

Imagine you are handed a large number $N$ that you know is the product of exactly two primes, $N = pq$. You are not told $p$ or $q$ — finding them is, after all, the whole difficulty. But you are allowed one small favor. You may pick a *question about the primes themselves*, of a very restricted kind: for each prime, some random-looking event either happens or it does not, and you get to learn whether it happened **for at least one of the two factors**.

That is a single bit. One bit of yes/no about the pair $\{p, q\}$, delivered to you for free.

How much can that bit tell you?

The answer, it turns out, is a very specific number:

$$\boxed{0.3113\ \text{bits}}$$

Not approximately. Not "usually". This is a sharp global maximum, valid for *every* way of choosing the underlying event, for *every* modulus, for *every* pattern of probabilities — and it is exactly attained, by a family of events we can name completely: the quadratic characters, the same objects that Legendre and Gauss put at the center of number theory two hundred years ago.

This is the story of that number, of the variational principle that produces it, and of the sting in its tail: the bit that maximizes the dial turns out to be, for the purpose of actually factoring $N$, completely worthless.

---

## The residue dial

Start with the setting. Fix a modulus $m$ and look at primes through the narrow window of their residue class modulo $m$. A prime $p$ not dividing $m$ lands in one of the $\varphi(m)$ invertible classes — that is, in one element of the group $(\mathbb{Z}/m)^\times$, which we will call the **class group** $G$.

Now attach to each class a probability. A **class-rate profile** is a function

$$r : G \to [0,1], \qquad r(c) = \Pr\big[\,E(p) \mid p \equiv c \ (\mathrm{mod}\ m)\,\big],$$

where $E(p)$ is whatever "fork event" you care about. Some examples that occur naturally:

* $E(p)$ = "$p$ splits in $\mathbb{Q}(\sqrt{5})$", which happens exactly when $p \equiv \pm 1 \pmod 5$. Here $r$ is the indicator of an index-two subgroup of $(\mathbb{Z}/5)^\times$: $r$ is $1$ on half the classes and $0$ on the other half.
* $E(p)$ = "$p \equiv 1 \pmod 4$", i.e. $p$ splits in $\mathbb{Q}(i)$. Same shape, modulus $4$.
* $E(p)$ = "$p$ has a cube root of unity available modulo $p$", i.e. $p \equiv 1 \pmod 3$ — an index-three condition when read in a suitable class group.
* $E(p)$ = "a fixed cubic polynomial factors in a particular way mod $p$", where the Galois group is $S_3$. Here $r$ is genuinely *variable*: it takes different fractional values on different classes, say between $0.287$ and $0.349$ on the quadratic residues and $1.0$ off them. Nothing forces a profile to be $0/1$.

Because primes equidistribute over the classes, we may model $p$ and $q$ as independent and uniform on $G$. The observer knows $N \bmod m$, which is the *product class* $c = pq$, and receives the OR bit

$$B \;=\; \big[\,E(p) \ \text{or}\ E(q)\,\big].$$

The quantity to be maximized is the mutual information between what you already know and what you are given,

$$\Phi(r) \;=\; I\big(N \bmod m \,;\, B\big),$$

measured in bits. This is the **OR dial**: turn the profile $r$, and watch how many bits come out.

---

## The counting identity

Everything begins with an elementary observation about how a product class constrains its factors. Condition on $N \equiv c$. Then the pair $(p \bmod m, q \bmod m)$ is uniform over all pairs $(a, ca^{-1})$ with $a \in G$ — exactly $\varphi(m)$ equally likely pairs. Writing $s = 1 - r$ for the *no-fork* profile, the probability that neither prime forks is therefore

$$f(c) \;=\; \frac{1}{|G|} \sum_{a \in G} s(a)\, s(ca^{-1}),$$

which the reader will recognize as the group convolution $s * s$ evaluated at $c$. The OR bit fires with conditional probability $1 - f(c)$, and the dial reads

$$\Phi \;=\; H(\mu^2) \;-\; \frac{1}{|G|}\sum_{c \in G} H\big(f(c)\big), \qquad \mu = \frac{1}{|G|}\sum_{a} s(a),$$

with $H$ the binary entropy $H(x) = -x\log_2 x - (1-x)\log_2(1-x)$.

That formula is the entire object of study. It is a function on the cube $[0,1]^{|G|}$, and the question is: how large can it get?

---

## A window and a mean

Two facts about the convolution do almost all the work, and both are one-liners.

**The mean law.** Averaging $f$ over all classes $c$ decouples the two sums, so

$$\text{avg}_c\, f(c) \;=\; \mu^2 .$$

The conditional no-fork probabilities average to exactly the square of the mean no-fork rate — which is just the statement that the unconditional probability of "neither forks" is $\mu^2$, as it must be for independent primes.

**The window law.** Since every $s(a) \le 1$, each term $s(a)s(ca^{-1}) \le s(a)$, so $f(c) \le \mu$. And since $xy \ge x + y - 1$ on the unit square, $f(c) \ge 2\mu - 1$. Hence for every class,

$$\max(0,\, 2\mu - 1) \;\le\; f(c) \;\le\; \mu .$$

Now the whole variational problem collapses. We are subtracting an *average of entropies* from a fixed number $H(\mu^2)$, so we want the average entropy to be as small as possible. The entropy function is concave, and a concave function on an interval is smallest, subject to a fixed mean, when its argument sits at the *endpoints* of the interval. The mean is pinned at $\mu^2$ and the interval is the window above. The chord of $H$ across the window therefore gives, in one stroke, the best possible bound — and it depends only on the single number $\mu$.

In the low regime $\mu \le 1/2$ the window is $[0,\mu]$ and the chord bound reads

$$\Phi \;\le\; H(\mu^2) - \mu H(\mu).$$

In the high regime $\mu \ge 1/2$ the window is $[2\mu - 1, \mu]$ and one gets

$$\Phi \;\le\; H(\mu^2) - \big(\mu H(2\mu - 1) + (1-\mu) H(\mu)\big).$$

An infinite-dimensional optimization over all profiles on all class groups has become a problem in one real variable.

---

## The peak

Both of those one-variable functions have the same maximum, and they attain it at the same place: $\mu = 1/2$. There,

$$\Phi \;\le\; H(1/4) - \tfrac12 H(1/2) \;=\; H(3/4) - \tfrac12 \;=\; \tfrac32\log 2 - \tfrac34 \log 3 \ \text{nats} \;=\; 0.311278\ldots \ \text{bits}.$$

Call this number $g(2)$. It is the cap.

**The Global Cap Theorem.** *For every finite abelian class group and every class-rate profile $r : G \to [0,1]$, the semiprime OR channel satisfies $\Phi(r) \le g(2) = 0.31128\ldots$ bits, and equality is attainable.*

The cap is small — under a third of a bit — and it is completely insensitive to the modulus. You may take $m = 5$ or $m = 10^{100}$; you may take a cyclic class group or one of shape $C_2 \times C_4$ or $C_2 \times C_6$; you may tune the $\varphi(m)$ knobs of the profile continuously and independently. The dial does not go past $0.3113$.

---

## Who reaches it: an exact classification

What makes the theorem sharp rather than merely true is that the extremal profiles can be described completely, and the description is startlingly rigid. Three successive rigidity statements pin them down.

1. **The mean is forced.** Equality requires $\mu = 1/2$ exactly. Any other mean no-fork rate is *strictly* below the cap. Equivalently, at the optimum the OR event has unconditional probability exactly $3/4$.

2. **The conditional probabilities are forced.** At a maximizer, $f(c) \in \{0, \tfrac12\}$ for every class $c$: either the OR bit is certain, or it is a fair coin. Nothing in between ever occurs.

3. **The profile itself is forced to be deterministic.** A maximizing profile takes only the values $0$ and $1$. Fractional rates — the kind that arise from genuinely random-looking events, such as the $S_3$ cubic example — are always strictly suboptimal.

Putting these together yields the classification:

**The Maximizer Classification Theorem.** *A class-rate profile attains the cap if and only if it is the indicator function of a coset of an index-two subgroup of the class group.*

Or, in the language of characters:

**Character Form.** *The maximizers are exactly the profiles $r = \dfrac{1 + \varepsilon\chi}{2}$, where $\chi$ is a nontrivial character of the class group taking only the values $\pm 1$ and $\varepsilon = \pm 1$.*

A nontrivial $\pm 1$-valued character of $(\mathbb{Z}/m)^\times$ is precisely a **quadratic character** — a Legendre or Kronecker symbol. So the answer to "which single bit about the factors of a semiprime is most informative?" is: *the quadratic residue symbol, and nothing else.* Splitting in $\mathbb{Q}(\sqrt 5)$ modulo $5$, splitting in $\mathbb{Q}(i)$ modulo $4$, splitting in $\mathbb{Q}(\sqrt{-11})$ modulo $11$, the Kronecker symbol $(8\,|\,p)$ modulo $8$ — all of these sit exactly at $0.3113$, each with $\Pr[\mathrm{OR}] = 3/4$. The complement of such an event (the other coset) gives the identical value; so does the AND version.

There is even an arithmetic obstruction on the other side: a class group of **odd order carries no quadratic character at all**, so on such a group the cap is a supremum that is never attained. Every profile there is strictly below $0.3113$.

---

## The order-$n$ ladder

The classification also explains all the values previously measured on individual channels. Take a subgroup $K$ of index $n$ and let the fork event be "$p \in K$" — the order-$n$ character event. Everything is computable in closed form, because the convolution of a subgroup indicator with itself is again supported on the subgroup. Two exact laws drop out.

For the **AND** channel ("both primes fork"),

$$\Phi_{\mathrm{AND}}(n) \;=\; H\!\left(\frac{1}{n^2}\right) - \frac{1}{n} H\!\left(\frac{1}{n}\right),$$

giving $0.3113$ at $n = 2$, then $0.1972$ at $n=3$, $0.1345$ at $n=4$ — decreasing, and capped by $g(2)$ for every $n \ge 2$.

For the **OR** channel with the same event,

$$g(n) \;=\; H\!\left(\Big(\tfrac{n-1}{n}\Big)^{2}\right) - \left[\frac{1}{n} H\!\left(\tfrac{n-1}{n}\right) + \frac{n-1}{n} H\!\left(\tfrac{n-2}{n}\right)\right],$$

which reads $g(2) = 0.3113$, $g(3) = 0.0728$, $g(4) = 0.0359$, $g(5) = 0.0215$. The cyclic cubic field of conductor $7$ gives $g(3)$; the quartic field $\mathbb{Q}(\zeta_5)$ gives $g(4)$; the quadratic fields give $g(2)$ and sit at the summit. Only index two is extremal, and every other index is *strictly* below the cap.

Variable profiles land below as well, exactly as the rigidity theorems predict: the $S_3$ cubic $x^3 + x + 1$ read modulo $31$, whose per-class identity rates hover between $0.287$ and $0.349$ on the quadratic residues and equal $1$ off them, yields a dial reading of about $0.123$ bits — well under half the cap.

---

## More than two primes

What if $N$ has three prime factors, or ten? Take $N = p_1 p_2 \cdots p_k$ with all $p_i$ independent and uniform on the class group, and ask for the OR of the $k$ fork events. The conditional no-fork probability becomes the $k$-fold convolution $f_k = s^{*k}$, and two clean facts persist: its average over classes is exactly $\mu^k$, and it is bounded pointwise by $\mu^{k-1}$. Feeding these into a two-variable analytic inequality — $H(\mu x) - \mu H(x) \le g(2)$ whenever $x \le \mu^2$ — yields:

**The Multi-Prime Cap.** *For every $k \ge 2$, every class group and every profile, the $k$-factor OR channel obeys $\Phi_k \le g(2) = 0.3113$ bits.*

And more: for $k \ge 3$ the bound is *never* tight. There is a uniform gap,

$$\Phi_k \;\le\; g(2) - \frac{1}{500} \qquad (k \ge 3),$$

independent of the profile, the class group, and $k$ itself. The cap belongs to semiprimes alone. For the champion profiles — the quadratic kernels — the exact $k$-factor value is

$$\Phi_k \;=\; H(2^{-k}) - \tfrac12 H\big(2^{-(k-1)}\big) \;\le\; (1 + \log 2)\,2^{-k},$$

reading $0.3113$ for $k = 2$, $0.1379$ for $k=3$, $0.0655$ for $k=4$: the dial decays geometrically as the number of prime factors grows. More factors, less information — the OR of many events is nearly always "yes", and a near-certainty carries no news.

---

## The sting: a full bit that tells you nothing

Here is the part that ought to unsettle anyone who equates "mutual information" with "useful information".

Replace OR with XOR. Let $\chi$ be a quadratic character with kernel $K$, and let the fork event be $p \in K$. Then

$$E(p) \ \mathrm{XOR}\ E(q) \quad\Longleftrightarrow\quad pq \notin K,$$

because $\chi$ is multiplicative: $\chi(p)\chi(q) = \chi(N)$. The XOR bit equals $[\chi(N) = -1]$ — a deterministic function of $N$ itself. Its mutual information with $N \bmod m$ is a **full bit, exactly $1.0000$**, three times the OR cap.

And it is worth nothing at all. You can compute $\chi(N)$ from $N$ alone in microseconds; the "channel" hands you back a number you already had. This is the sharpest possible demonstration that raw mutual information with the residue class of $N$ is *not* a measure of factorization knowledge. The dial can be pegged at one full bit while conveying precisely zero help.

The same shadow falls across the OR channel, even at its optimum. What the maximizing quadratic bit does is split the classes into those where the OR is certain and those where it is a fair coin — information about $\chi(N)$, which is again free. This is the reason such channels have never threatened factoring, and the reason the theorem, rather than being discouraging, is clarifying: it draws the boundary of a whole family of approaches in a single number.

---

## Why a cap is good news

It is easy to read a theorem like this as a negative result: here is a natural source of information about the factors of a semiprime, and it leaks less than a third of a bit. But the value of a sharp maximum is that it *closes* a line of inquiry rather than leaving it open. Before, one had a scattering of measurements — a quadratic channel here at $0.31$, a cubic there at $0.07$, an $S_3$ profile at $0.12$ — and no way to know whether some cleverer event, some exotic modulus, some finely tuned mixture of rates, might do far better. Now there is a proof that none can: the summit is $g(2)$, its shape is $H(3/4) - \frac12$, and the flags planted at it belong to the quadratic characters, alone.

There is something pleasing in the answer. Of all the ways to interrogate a semiprime one bit at a time, the most informative is the oldest one in the book — the question Gauss asked, whether a number is a square modulo a prime. Two centuries of reciprocity laws have made that question so thoroughly computable that its answer, for a product, is free. The dial's maximum and the dial's uselessness are, in the end, the same fact wearing two hats: quadratic characters are extremal *because* they are multiplicative, and multiplicative *is* exactly what "computable from $N$ alone" means.

The ceiling is real, it is $0.3113$ bits, and standing at it you can see that there is nothing above.
