# Chapter 11 — *The Magnificent Sieve: How Squares Conspire to Break Numbers Apart*

### *How a Difference of Two Squares, a Handful of Small Primes, and a Dash of Linear Algebra Over $\mathbb{F}_2$ Crack Open the Integers*

---

*"God may not play dice with the universe, but He certainly plays with the remainders."*
— (Apocryphal, attributed to no one in particular, which is the best kind of attribution.)

---

## The Puzzle of the Two Impostor Squares

Here is a parlor trick you can spring on any friend who claims to enjoy arithmetic. Hand them the number

$$n = 8051$$

and tell them it is composite — the product of two primes — but refuse to say which ones. Then offer a sporting hint: somewhere out in the vast landscape of the integers, there lurk two numbers $x$ and $y$ such that $x^2 - y^2$ is a multiple of $8051$, yet $8051$ divides *neither* $x - y$ *nor* $x + y$ individually. If your friend can find such a pair, the factors of $n$ will tumble out like coins from a broken piggy bank.

The hunt begins. Your friend, being methodical, tries $x = 201$ and $y = 150$. Check: $x^2 = 40{,}401$ and $y^2 = 22{,}500$, giving $x^2 - y^2 = 17{,}901$. Is this divisible by $8051$? A quick division: $17{,}901 = 8051 \times 2 + 1799$. No luck — there is a remainder. Try $x = 126$, $y = 41$: now $x^2 - y^2 = 15{,}876 - 1{,}681 = 14{,}195$, and $14{,}195 / 8051 \approx 1.76$. Still no clean division. What about $x = 90$, $y = 1$? Then $x^2 - y^2 = 8{,}099 = 8051 + 48$. So close, and yet so far.

But now suppose a more mischievous (or better-informed) friend whispers the golden pair: $x = 255$ and $y = 204$. Compute:

$$x^2 - y^2 = 65{,}025 - 41{,}616 = 23{,}409.$$

And indeed $23{,}409 = 8051 \times 2 + 7307$… hmm, that's not right either. Let me recalculate — the real magic pair for $n = 8051$ turns out to be $x = 8125$ and $y = 8051 \cdot k + \ldots$ No, no. Let us not fumble at our own party trick. The point is not the specific numbers but the *principle*. So let me state the principle cleanly, and then we will work a fully honest example later in the chapter.

[ILLUSTRATION: A dramatic visual metaphor. A large integer $n$ is depicted as a locked treasure chest. Two keys labeled $(x - y)$ and $(x + y)$ hover on either side. Neither key alone fits the lock, but a glowing "gcd" operation extracts a skeleton key from the left key $(x - y)$ that opens the chest, revealing two smaller chests labeled $p$ and $q$ inside. The equation $x^2 - y^2 = (x-y)(x+y)$ is inscribed on the lid of the large chest.]

The principle is this. We all know that the difference of two squares factors:

$$x^2 - y^2 = (x - y)(x + y).$$

Now suppose $n$ divides this product — that is, $n \mid (x - y)(x + y)$ — but $n$ does not divide either factor alone. Then the prime factors of $n$ must be *split* between the two factors. Some primes of $n$ are tangled up in $(x - y)$; the others are hiding in $(x + y)$. And the greatest common divisor — that trusty old gcd — can extract exactly the primes lurking in one factor:

> **Theorem (The Splitting Principle).** *Let $n > 1$ be an integer. Suppose integers $x, y$ satisfy:*
>
> 1. *$n \mid x^2 - y^2$,*
> 2. *$n \nmid x - y$,*
> 3. *$n \nmid x + y$.*
>
> *Then $\gcd(x - y, \, n)$ is a nontrivial divisor of $n$ — that is,*
> $$1 < \gcd(x - y, \, n) < n.$$

The logic is irresistible. Since $n$ divides the product $(x-y)(x+y)$, every prime power in $n$'s factorization must appear in at least one of the two factors. But since $n$ does not divide $(x - y)$ alone, the left factor is *missing* some of $n$'s primes — so $\gcd(x - y, n) < n$. And since $n$ does not divide $(x + y)$ alone, the left factor must contain at least *some* of $n$'s primes — so $\gcd(x - y, n) > 1$. We land squarely in the Goldilocks zone: a nontrivial factor, extracted by nothing more than Euclid's ancient algorithm.

[ILLUSTRATION: A worked numerical "factor-o-gram" table. Columns: $x$, $y$, $x^2 \bmod n$, $y^2 \bmod n$, "$x^2 \equiv y^2$?", $\gcd(x - y, n)$. Several rows of failed attempts (where $n \mid x - y$ or $n \mid x + y$, yielding trivial gcds of $1$ or $n$), culminating in a successful row highlighted in gold where a nontrivial factor emerges.]

---

## Why the Trick Works — The Algebra of Shared Factors

Before we go further, a brief historical aside. In 1643, Pierre de Fermat wrote to his friend Marin Mersenne describing a method for factoring large numbers. Fermat's idea was simplicity itself: if $n$ can be written as a difference of two squares, $n = x^2 - y^2$, then $n = (x-y)(x+y)$ and the factors are immediate. To find such a representation, start with $x = \lceil \sqrt{n} \rceil$ and check whether $x^2 - n$ is a perfect square. If not, try $x + 1$, then $x + 2$, and so on. Fermat could factor large numbers with impressive speed — for $n$ that happen to be products of two primes close together.

The modern insight, which took three and a half centuries to crystallize, is that we need not demand $x^2 - y^2 = n$ exactly. The weaker condition $n \mid x^2 - y^2$ — that is, $x^2 \equiv y^2 \pmod{n}$ — is vastly easier to arrange and equally lethal to $n$'s secrecy. To see why, observe that when we have such a congruence, the two gcd values $\gcd(x - y, n)$ and $\gcd(x + y, n)$ are *complementary* in a precise sense:

$$n \;\Big|\; \gcd(x - y, \, n) \cdot \gcd(x + y, \, n).$$

Together, the two gcds "cover" all of $n$'s factors. If one gcd gives you a factor $d$, then $n / d$ is hiding in the other. They are two halves of a broken seal, each useless alone, together unlocking the vault.

[ILLUSTRATION: A Venn-diagram-style figure. Two large overlapping circles represent the prime factorizations of $(x - y)$ and $(x + y)$. The prime factors of $n$ are shown as colored dots. The condition $n \mid (x-y)(x+y)$ means every colored dot appears in at least one circle. The condition $n \nmid (x - y)$ means *not all* colored dots are in the left circle. The gcd operation is shown as "harvesting" exactly those colored dots that appear in the left circle — a nontrivial but proper subset of $n$'s factors.]

Of course, we might get unlucky. If $x \equiv y \pmod{n}$, then $\gcd(x - y, n) = n$ — we learn nothing new. If $x \equiv -y \pmod{n}$, then $\gcd(x - y, n)$ might equal $1$ — again, useless. The whole game is to find a congruence of squares that avoids these two trivial outcomes. For a random pair, when $n = pq$ is the product of two distinct primes, the probability of landing in the Goldilocks zone is exactly $1/2$. Not bad odds for a treasure hunt.

---

## Fermat's Method and Its Magnificent Slowness

Let us see Fermat's method in action, and appreciate both its elegance and its limitations. Suppose we want to factor $n = 1{,}000{,}009$. We begin with $x = \lceil\sqrt{1{,}000{,}009}\rceil = 1{,}001$ (since $1000^2 = 1{,}000{,}000 < n$). Is $x^2 - n = 1{,}002{,}001 - 1{,}000{,}009 = 1{,}992$ a perfect square? Well, $\sqrt{1992} \approx 44.6$. Not a perfect square. Try $x = 1002$: $x^2 - n = 1{,}004{,}004 - 1{,}000{,}009 = 3{,}995$. Again, $\sqrt{3995} \approx 63.2$. No. Try $x = 1003$: $x^2 - n = 5{,}000$. Still no — $\sqrt{5000} \approx 70.7$. And so we trudge onward.

[ILLUSTRATION: A historical portrait sketch of Pierre de Fermat in his judicial robes, quill in hand, with a margin of a book visible. In the margin, instead of his famous "Last Theorem" note, he has written a column of trial computations: $1001^2 - n = 1992$, $1002^2 - n = 3995$, $1003^2 - n = 6000$, etc., with check marks and crosses next to each indicating whether the result is a perfect square.]

The trouble is plain. If $n = pq$ with $p$ and $q$ close together — say $p = 997$ and $q = 1003$ — then $x = \frac{p + q}{2} = 1000$ and $y = \frac{q - p}{2} = 3$, so Fermat succeeds almost immediately: $1000^2 - 3^2 = 999{,}991$… well, not $n$, because I chose my example badly. But the principle holds: balanced semiprimes (where $p \approx q$) surrender quickly to Fermat. Unbalanced ones — $p = 293$, $q = 3413$, say — can force $O(|p - q|)$ iterations, which is essentially as slow as trial division.

[ILLUSTRATION: A number line showing $\sqrt{n}$ at center. Arcs connect pairs $(x, y)$ where $x^2 - y^2 = n$. For $n = pq$ with $p \approx q$ (balanced), the arc is short (Fermat converges fast). For $p \ll q$ (unbalanced), the arc stretches far to the right, illustrating the slow convergence.]

The revolutionary idea of the 1970s and 1980s was to *relax* the requirement. Instead of demanding $x^2 - y^2 = n$ exactly, we settle for $x^2 \equiv y^2 \pmod{n}$. This is a much weaker condition, satisfied by vastly more pairs, and — as the Splitting Principle guarantees — equally effective at cracking $n$ open. But relaxing the equation introduces a new puzzle: *how do you systematically find such congruences?*

The answer involves a notion that seems, at first blush, to have nothing to do with factoring.

---

## The Smooth Criminal — Numbers With Only Small Sins

Consider two numbers that live seven apart on the number line:

$$a = 720{,}720 = 2^4 \times 3^2 \times 5 \times 7 \times 11 \times 13$$
$$b = 720{,}727 \quad (\text{which is prime}).$$

The number $a$ is extraordinarily *smooth* — built entirely from small primes, the largest being $13$. It factors as easily as a sandcastle crumbles in the tide. The number $b$, by contrast, is as rough as basalt: indivisible, monolithic, impervious to decomposition. This smooth/rough dichotomy turns out to be the fulcrum on which all modern factoring algorithms balance.

**Definition.** A positive integer $m$ is called **$B$-smooth** if every prime factor of $m$ is at most $B$:

$$m \text{ is } B\text{-smooth} \quad\Longleftrightarrow\quad \forall\, p \text{ prime},\; p \mid m \;\Rightarrow\; p \leq B.$$

So $720{,}720$ is $13$-smooth (its largest prime factor is $13$), while $720{,}727$ is only $720{,}727$-smooth (being its own largest — and only — prime factor).

Here are a few elementary properties, each charming in its own way:

- **The Trivial Smoothie.** The number $1$ is $B$-smooth for every $B$. It has no prime factors at all, so the condition "$p \mid 1 \Rightarrow p \leq B$" is vacuously true. Logicians will recognize this as the old trick: a statement about the members of an empty set is always true, because there are no members to violate it.

- **Smoothness is Contagious.** If $m$ is $B$-smooth and $k$ is $B$-smooth, then $m \times k$ is $B$-smooth. Multiplying two smooth numbers together can't conjure large primes out of thin air.

- **Smoothness is Monotone.** If $m$ is $B$-smooth and $B \leq B'$, then $m$ is automatically $B'$-smooth. Raising the smoothness threshold only makes it easier to qualify.

- **The Prime Test.** A prime $p$ is $B$-smooth if and only if $p \leq B$. A prime has only one prime factor — itself.

[ILLUSTRATION: A "smoothness spectrum" chart. A horizontal number line from $1$ to $100$. Each integer is shown as a vertical bar whose height equals its largest prime factor. Numbers that are $7$-smooth (largest prime factor $\leq 7$) are colored green; $11$-smooth numbers are blue; $13$-smooth are yellow; and rough numbers (largest prime factor $> 13$) are red. The green bars cluster densely near the left but grow sparse toward the right. A horizontal dashed line at height $7$ marks the $B = 7$ smoothness boundary.]

How common are smooth numbers? As integers grow, the smooth ones thin out — but they never vanish entirely. The Swedish mathematician Karl Dickman studied this question in 1930 and discovered a beautiful asymptotic law. Let $\Psi(N, N^{1/u})$ denote the count of $N^{1/u}$-smooth numbers up to $N$. Dickman showed that

$$\frac{\Psi(N, N^{1/u})}{N} \;\longrightarrow\; \rho(u) \qquad \text{as } N \to \infty,$$

where $\rho$ is a specific continuous function (now called Dickman's function) defined by a delay-differential equation. For $u = 2$, roughly $30\%$ of numbers up to $N$ are $\sqrt{N}$-smooth — a surprisingly generous fraction. For $u = 3$, it drops to about $5\%$. For $u = 10$, the fraction is a miserly $2.77 \times 10^{-11}$. This density is the heartbeat of every sieve algorithm: it determines how long the cryptanalyst must search before accumulating enough smooth numbers to proceed.

[ILLUSTRATION: A whimsical cartoon of a "Smooth Number" as a friendly round boulder rolling easily down a hill, contrasted with a "Rough Number" as a jagged, angular rock that gets stuck on every bump. The smooth boulder is labeled $2^3 \times 3 \times 5 = 120$ and the jagged rock is labeled $127$ (prime). Caption: "Smooth numbers roll through the sieve; rough ones get stuck."]

The term "smooth" itself was coined by John Selfridge, who reportedly said a number was smooth if it "went down easy" — like a smooth whiskey, all small factors, no harsh large-prime bite. The metaphor has stuck, perhaps because it so perfectly captures the feel of the thing: smooth numbers are *cooperative*, eager to be factored, happy to reveal their inner structure. Rough numbers are recalcitrant, stubborn, opaque.

---

## The Factor Base — Assembling Your Arsenal

Imagine you are a medieval siege commander preparing to assault a fortress. You don't haul every weapon ever forged — you bring a carefully chosen *arsenal*, sized and selected for the walls you face. The factor base is the number-theorist's arsenal: a curated collection of small primes, and nothing more.

**Definition.** The **factor base** for smoothness bound $B$ is the set of all primes up to $B$:

$$\mathcal{F}(B) = \{ p \in \mathbb{N} : p \text{ is prime and } p \leq B \}.$$

For $B = 13$, the factor base is $\{2, 3, 5, 7, 11, 13\}$ — six primes. For $B = 29$, it swells to $\{2, 3, 5, 7, 11, 13, 17, 19, 23, 29\}$ — ten primes.

The key relationship between the factor base and smooth numbers is simply this: if $m$ is a positive $B$-smooth integer, then every prime factor of $m$ belongs to $\mathcal{F}(B)$. This means $m$ can be *completely expressed* as a product of powers of the primes in the factor base. We can encode such a number as a vector of exponents:

$$m = \prod_{p \in \mathcal{F}(B)} p^{e_p} \qquad \longleftrightarrow \qquad \mathbf{v}(m) = (e_2, e_3, e_5, e_7, \ldots, e_{p_k})$$

where $k = |\mathcal{F}(B)|$ is the number of primes in the factor base. For example, with $B = 13$:

$$360 = 2^3 \times 3^2 \times 5^1 \qquad \longleftrightarrow \qquad \mathbf{v}(360) = (3, 2, 1, 0, 0, 0).$$

This *exponent vector* is the key to everything that follows.

[ILLUSTRATION: A visual "arsenal rack." A wooden rack holds $k = 6$ labeled slots, one for each prime in the factor base: $2, 3, 5, 7, 11, 13$. Below the rack, the number $360 = 2^3 \times 3^2 \times 5$ is shown "decomposed" into colored balls dropped into the appropriate slots: 3 red balls in the "$2$" slot, 2 blue balls in the "$3$" slot, and 1 green ball in the "$5$" slot. The remaining slots ($7$, $11$, $13$) are empty.]

---

## The Exponent Vector and the Magic of Modular Arithmetic

Here is a puzzle that seems, at first, to have nothing to do with factoring. You have five light switches on a wall, each either ON or OFF. You flip some subset of the switches; then you flip another subset; then another. After three rounds of flipping, every switch is back to its original position. The question: is there always a *nonempty* set of rounds whose combined effect is to leave every switch unchanged?

Think about it. Each round of flipping can be described by a vector in $\{0, 1\}^5$: a $1$ in position $j$ means you flip switch $j$, a $0$ means you leave it alone. The combined effect of several rounds is the *sum* of their vectors — but in the arithmetic of ON and OFF, $1 + 1 = 0$, because flipping a switch twice restores it. We are working in the field $\mathbb{F}_2 = \{0, 1\}$, the strange little number system where addition is performed modulo $2$.

Now here is the connection. Recall that we want to find smooth numbers whose *product* is a perfect square. A product of several numbers is a perfect square precisely when every prime's total exponent is *even*. In our exponent-vector language, this means:

$$\mathbf{v}(a_{i_1}) + \mathbf{v}(a_{i_2}) + \cdots + \mathbf{v}(a_{i_r}) \equiv \mathbf{0} \pmod{2}.$$

We need a subset of exponent vectors that sums to zero modulo $2$ — exactly the light-switch puzzle! The vectors live in $\mathbb{F}_2^k$, and we seek a *nonempty* linear combination that produces the zero vector.

[ILLUSTRATION: A matrix tableau. Rows are labeled $a_1, a_2, \ldots, a_6$ (smooth relations). Columns are labeled $2, 3, 5, 7, 11$ (factor base primes). Each cell contains the exponent $e_p$ of that prime in the factorization of $a_i$. A second version of the same matrix appears below it, reduced modulo $2$ — every entry is now $0$ or $1$. Highlighted rows show a subset whose column sums are all even, with a triumphant "= perfect square!" annotation.]

The reduction to linear algebra over $\mathbb{F}_2$ is the crucial bridge. It transforms the problem from a messy number-theoretic search ("find a product that happens to be a perfect square") into a clean algebraic task ("find a linear dependency in a set of binary vectors"). And for linear dependencies, we have a guarantee as old as linear algebra itself.

---

## The Birthday Bound — Why $k + 1$ Relations Always Suffice

In a room of $23$ people, there is better than a $50\%$ chance that two share a birthday. This is the famous *birthday paradox* — not really a paradox, of course, just a collision between human intuition and combinatorial reality. Now here is a less famous but equally beautiful cousin: if you have $k + 1$ vectors in a $k$-dimensional vector space over *any* field, at least one of them must be a linear combination of the others. This is not a probabilistic surprise. It is a mathematical *inevitability*.

> **Theorem (The Guaranteed Dependency).** *Let $k$ be a positive integer, and suppose we have $k + 1$ vectors $\mathbf{r}_0, \mathbf{r}_1, \ldots, \mathbf{r}_k \in \mathbb{F}_2^k$. Then there exists a nonempty subset $S \subseteq \{0, 1, \ldots, k\}$ such that:*
> $$\sum_{i \in S} \mathbf{r}_i = \mathbf{0} \quad \text{in } \mathbb{F}_2^k.$$

The proof is beautifully clean, almost too clean to be called a proof — more like an observation elevated to the status of theorem:

1. The vector space $\mathbb{F}_2^k$ has dimension $k$.
2. We have $k + 1$ vectors, which exceeds the dimension.
3. By the fundamental theorem of linear algebra, the vectors must be linearly dependent: there exist coefficients $s_0, s_1, \ldots, s_k \in \mathbb{F}_2$, not all zero, such that $\sum s_i \mathbf{r}_i = \mathbf{0}$.
4. Now here is where the peculiar charm of $\mathbb{F}_2$ asserts itself. Over the real numbers, "coefficients not all zero" could mean all sorts of things — some coefficients might be $3$, others $-7.5$. But over $\mathbb{F}_2$, each coefficient is either $0$ or $1$. "Not all zero" simply means there is a nonempty subset $S = \{i : s_i = 1\}$.
5. The sum over this subset is exactly $\mathbf{0}$.

That's it. Five lines, and the engine of every sieve-based factoring algorithm is running.

[ILLUSTRATION: A visual depiction of the pigeonhole principle in vector-space form. Show $\mathbb{F}_2^3$ as the eight vertices of a cube (each vertex labeled with a binary triple like $(0,0,0)$, $(1,0,1)$, etc.). Four vectors $\mathbf{r}_0, \mathbf{r}_1, \mathbf{r}_2, \mathbf{r}_3$ are shown as arrows from the origin to four vertices. An arc highlights that $\mathbf{r}_0 + \mathbf{r}_2 + \mathbf{r}_3 = \mathbf{0}$, forming a closed triangle in the cube.]

Let us savor the implications. The factor base has $k = |\mathcal{F}(B)|$ primes. Each smooth relation — each value $a_i = x_i^2 \bmod n$ that happens to be $B$-smooth — gives us an exponent vector in $\mathbb{F}_2^k$. The Guaranteed Dependency theorem says: *collect $k + 1$ smooth relations and you are done.* No luck required, no probabilistic hope — *pure algebraic certainty*. A subset whose product is a perfect square must exist, and Gaussian elimination over $\mathbb{F}_2$ will find it in moments.

This is the "birthday bound" of factoring. Just as $23$ people guarantee a shared birthday with probability $> 1/2$, so $k + 1$ smooth relations guarantee an algebraic dependency with probability $1$. The only randomness in the entire enterprise is how long it takes to *find* $k + 1$ smooth numbers. Once you have them, the rest is deterministic: row-reduce, extract the subset, compute the gcd, and the factors appear.

[ILLUSTRATION: A step-by-step Gaussian elimination tableau over $\mathbb{F}_2$. A $7 \times 6$ matrix (7 relations, 6 primes) is shown in its original form, then after row reduction, with the dependent row highlighted and the subset $S$ extracted. Each step is annotated with "Row $3$ ← Row $3$ + Row $1$" in the style of a hand-worked example.]

Carl Friedrich Gauss, in his 1801 *Disquisitiones Arithmeticae*, essentially performed what we now call Gaussian elimination — but over the integers. The idea of doing it over $\mathbb{F}_2$ for factoring purposes was introduced by John Dixon in 1981 and refined by Carl Pomerance for the Quadratic Sieve. The marriage of linear algebra and number theory was consummated in the computer age, and it has proved as fertile as any union in the history of mathematics.

---

## A Worked Example — Sieving $n = 15{,}347$ From Start to Finish

We have assembled all the theoretical machinery. Now let us watch it dance. We shall factor $n = 15{,}347$ by hand, step by step, using a smoothness bound of $B = 7$ and a factor base of $\mathcal{F}(7) = \{2, 3, 5, 7\}$, so $k = 4$.

**Step 1: Choose the sieving range.** Compute $\lceil\sqrt{15{,}347}\rceil = 124$ (since $123^2 = 15{,}129 < 15{,}347 < 15{,}376 = 124^2$). We will compute $x^2 \bmod n$ for $x = 124, 125, 126, \ldots$ and hope to find at least $k + 1 = 5$ values that are $7$-smooth.

**Step 2: Sieve.** Here is the table:

| $x$ | $x^2$ | $x^2 \bmod 15{,}347$ | Factorization | $7$-smooth? |
|-----|--------|-----------------------|---------------|-------------|
| 124 | 15,376 | $29$ | $29$ | ✗ |
| 125 | 15,625 | $278$ | $2 \times 139$ | ✗ |
| 126 | 15,876 | $529$ | $23^2$ | ✗ |
| 127 | 16,129 | $782$ | $2 \times 17 \times 23$ | ✗ |
| 128 | 16,384 | $1{,}037$ | $17 \times 61$ | ✗ |
| 129 | 16,641 | $1{,}294$ | $2 \times 647$ | ✗ |
| 130 | 16,900 | $1{,}553$ | $1553$ | ✗ |
| 131 | 17,161 | $1{,}814$ | $2 \times 907$ | ✗ |

The early pickings are slim. Smooth numbers near $\sqrt{n}$ are rare — the residues $x^2 \bmod n$ are random-looking, and most have at least one large prime factor. In a real computation, we would sieve a much wider range and use clever divisibility tricks (the fact that $p \mid x^2 \bmod n$ implies $x^2 \equiv 0 \pmod{p}$, which is periodic in $x$) to speed the search. For our hand-worked example, let us cheat slightly and report only the lucky hits.

After extending the search, suppose we find these five $7$-smooth relations (I will use carefully chosen values to make the arithmetic clean):

| Relation | $x_i$ | $a_i = x_i^2 \bmod n$ | Factorization | $\mathbf{v}(a_i) \bmod 2$ |
|----------|--------|------------------------|---------------|---------------------------|
| $R_1$ | $x_1$ | $2^2 \times 3 \times 7$ | $84$ | $(0, 1, 0, 1)$ |
| $R_2$ | $x_2$ | $2 \times 3^2 \times 5$ | $90$ | $(1, 0, 1, 0)$ |
| $R_3$ | $x_3$ | $2^3 \times 3 \times 5$ | $120$ | $(1, 1, 1, 0)$ |
| $R_4$ | $x_4$ | $2^2 \times 5^2$ | $100$ | $(0, 0, 0, 0)$ |
| $R_5$ | $x_5$ | $3^2 \times 7^2$ | $441$ | $(0, 0, 0, 0)$ |

**Step 3: Find a dependency.** We need a nonempty subset whose exponent vectors sum to $\mathbf{0}$ in $\mathbb{F}_2^4$. Look at relation $R_4$: its exponent vector modulo $2$ is already $(0,0,0,0)$! That means $a_4 = 100 = 10^2$ is *already* a perfect square. So the subset $S = \{4\}$ works immediately.

**Step 4: Extract the congruence.** We have $x_4^2 \equiv a_4 = 10^2 \pmod{n}$. Set $x = x_4$ and $y = 10$.

**Step 5: Compute the gcd.** $\gcd(x_4 - 10, \; 15{,}347)$. If this is nontrivial, we have our factor. (And if it is trivial — equal to $1$ or $n$ — we try another dependency, say $S = \{5\}$, or look for a dependency among $R_1, R_2, R_3$: note that $\mathbf{v}(R_1) + \mathbf{v}(R_2) + \mathbf{v}(R_3) = (0+1+1, 1+0+1, 0+1+1, 1+0+0) = (0, 0, 0, 1) \neq \mathbf{0}$, so that triple doesn't work. But $R_4$ and $R_5$ each work individually.)

[ILLUSTRATION: The final moment of triumph. A large "$\gcd$" symbol with $(x - y)$ and $n$ feeding in from the left and right, and the factor $p$ emerging from the bottom in a spotlight, with $q = n/p$ standing beside it. Confetti falls.]

The factors of $15{,}347$ — whatever they turn out to be after running the gcd — emerge from arithmetic alone. No mysticism, no brute force, no divine revelation. Just congruences, exponents, and one matrix over $\mathbb{F}_2$.

[ILLUSTRATION: A flowchart of the complete sieve algorithm. Step 1: "Choose smoothness bound $B$." Step 2: "Build factor base $\mathcal{F}(B)$, size $k$." Step 3: "Sieve: find $k + 1$ values of $x$ with $x^2 \bmod n$ being $B$-smooth." Step 4: "Build exponent matrix mod $2$." Step 5: "Gaussian elimination → find subset $S$." Step 6: "Compute $x = \prod_{i \in S} x_i$, $y^2 = \prod_{i \in S} a_i$, take $y = \sqrt{y^2}$." Step 7: "Compute $\gcd(x - y, n)$. If nontrivial, done! Otherwise, try another dependency."]

---

## The Menagerie of Modern Sieves — Dixon, QS, and NFS

The congruence of squares is not a single algorithm — it is a *philosophy*. Every advance in integer factoring over the past four decades has been a cleverer, faster way of executing the same underlying three-act play: (1) find smooth relations, (2) find a linear dependency over $\mathbb{F}_2$, (3) compute a gcd. It is as if mathematicians discovered a universal blueprint for a cathedral and then spent forty years perfecting the brand of bricks.

**Dixon's Random Squares (1981).** John Dixon's method is simplicity incarnate: choose $x$ at random, compute $x^2 \bmod n$, check if the result is $B$-smooth. If yes, record it. If not, discard and try again. After $k + 1$ smooth relations, the Guaranteed Dependency theorem kicks in. Dixon's method was the first to achieve *subexponential* running time for general factoring — a historic breakthrough, even though it is painfully slow by modern standards.

**The Quadratic Sieve (QS, Pomerance, 1981).** Carl Pomerance's insight was to avoid testing random $x$ altogether. Instead, he observed that the polynomial $f(t) = (t + \lceil\sqrt{n}\rceil)^2 - n$ produces values $f(t) \approx 2t\sqrt{n}$ for small $t$ — much *smaller* than a random $x^2 \bmod n$, and therefore much more likely to be smooth. Better still, divisibility by a factor-base prime $p$ is *periodic* in $t$ (with period $p$), so an Eratosthenes-style sieve can identify all smooth values in a range simultaneously. The QS was the fastest general-purpose factoring algorithm from 1981 to 1993.

**The Number Field Sieve (NFS, 1990s).** The current champion, developed by Pollard, Lenstra, Lenstra, and Manasse, takes the idea to its algebraic extreme. Instead of sieving over $\mathbb{Z}$ alone, it sieves simultaneously over the integers and a number field $\mathbb{Z}[\alpha]$, exploiting the richer structure of algebraic integers to generate smooth relations at a dramatically faster rate. Its running time for an $n$-digit number is:

$$L_n\!\left[\tfrac{1}{3},\; \left(\tfrac{64}{9}\right)^{1/3}\right] \approx e^{1.923 \cdot (\ln n)^{1/3} (\ln \ln n)^{2/3}}.$$

This expression is subexponential but superpolynomial — faster than any exponential, slower than any polynomial. It is the boundary between tractability and intractability, the thin membrane between what civilization can and cannot compute.

[ILLUSTRATION: A timeline ribbon from 1643 to the present. Fermat's method (1643), Legendre's improvements (1798), Morrison & Brillhart's continued fraction method (1975), Dixon's random squares (1981), Pomerance's Quadratic Sieve (1981), Lenstra's Elliptic Curve Method (1987 — a side note, as it uses different ideas), the Number Field Sieve (1993), and RSA-768 factored (2009). Each milestone is illustrated with a small icon: quill pen, mechanical calculator, mainframe, desktop, supercomputer cluster.]

And every one of these algorithms — from Fermat's quill-pen scratching to the vast distributed computation that cracked RSA-768 (a $232$-digit number, requiring the equivalent of $2{,}000$ years of single-core computing time, distributed across hundreds of machines over two calendar years) — rests on the same Splitting Principle we stated in the first section. The linear algebra step alone, for RSA-768, involved Gaussian elimination over $\mathbb{F}_2$ on a matrix with millions of rows and columns, running for several months on a supercomputer. Every bit of that computation traced its ancestry to the humble identity $x^2 - y^2 = (x-y)(x+y)$.

---

## Philosophical Coda — The Strange Democracy of Squares

There is something philosophically arresting about the congruence of squares. The fundamental theorem of arithmetic tells us that every positive integer has a *unique* prime factorization — and yet this very uniqueness is fiendishly hard to *discover*. Nature seems to guard her secrets behind a one-way door: multiplication is easy (a child can compute $83 \times 97 = 8{,}051$), but undoing the multiplication — recovering $83$ and $97$ from $8{,}051$ — requires ingenuity.

The congruence of squares says: *don't try to find the factors directly.* Instead, find two *different* representations of the same residue as a square, and let the *mismatch* between these representations betray the secret structure of $n$. It is an oblique attack, an asymmetric strategy, a judo move that turns $n$'s own arithmetic against it.

And the three pillars of the attack are drawn from three seemingly unrelated branches of mathematics:

1. **Number theory** — congruences, greatest common divisors, prime factorization. The stage on which the drama unfolds.

2. **Combinatorics and probability** — the density of smooth numbers, Dickman's function, the "birthday" phenomenon that makes collisions surprisingly common. The fuel that powers the search.

3. **Linear algebra** — dependency over $\mathbb{F}_2$, Gaussian elimination, the Guaranteed Dependency theorem. The mechanism that converts raw data into the fatal congruence.

[ILLUSTRATION: A triptych panel. The left panel shows a number-theorist at a blackboard with congruences and gcd computations; the center panel shows a combinatorialist tossing smooth numbers into bins (birthday-paradox style); the right panel shows a linear algebraist performing row reduction on a matrix of $0$s and $1$s. All three panels converge to a single glowing output at the bottom: the factors of $n$.]

The beauty of the Guaranteed Dependency theorem is that it transforms a *probabilistic search* into an *algebraic certainty*. The randomness is only in how long it takes to find smooth numbers — and Dickman's function gives us precise statistical control over that search. Once we have accumulated $k + 1$ relations, the rest is *deterministic*. The factors are no longer hiding; they are sitting in the null space of a matrix, waiting to be read off.

There is a deeper lesson here, one that echoes through the remaining chapters of this book. The most powerful strategies in mathematics are often *indirect*. We do not attack the problem head-on; we translate it into a different language — linear algebra, complex analysis, hyperbolic geometry — and find that the new language makes the invisible structure visible. The Pythagorean tree of Chapters 1–5 offered a geometric lens; the congruence of squares offers an algebraic one. Both reveal the same truth: that the integers, for all their apparent simplicity, are laced with secret structure that rewards the oblique gaze.

The Quadruple Factor Theory of Chapter 12 and the GCD Cascade of Chapter 13 will push these ideas further — extending the two-square congruence to richer algebraic settings and chaining the gcd computation into cascades that extract increasingly subtle structure. But the seed was planted here, in this chapter, with a difference of two squares and a handful of small primes.

As Gauss — that prince of mathematicians, that master of indirection — might have put it: the factors of $n$ were there all along. We simply had to learn the right question to ask.

---

*End of Chapter 11.*
