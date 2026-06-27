# When Neighbors Agree: The Strange Arithmetic of φ(n) = φ(n+1)

## A counting function with a secret

Pick a whole number $n$. Ask a deceptively simple question: how many numbers below $n$ share no common factor with it (other than 1)? That count is **Euler's totient function**, written $\varphi(n)$. It is one of the oldest and most useful gadgets in number theory: it governs the structure of clock arithmetic, underpins the RSA cryptosystem, and shows up whenever we ask how integers "interact" multiplicatively.

The totient is famously jumpy. It can plunge and spike from one integer to the next with no obvious rhythm. For a prime $p$, every smaller number is coprime to it, so $\varphi(p) = p - 1$ — almost as large as possible. For a number with many small prime factors, $\varphi$ collapses to a small fraction of $n$. Between these extremes, the values of $\varphi$ scatter like confetti.

So here is a question that sounds almost mischievous: **how often do two neighbors, $n$ and $n+1$, have exactly the same totient?** That is, how often does

$$\varphi(n) = \varphi(n+1)?$$

The first few solutions are $n = 1, 3, 15, 104, 164, 194, 255, 495, 584, 975, \dots$ — a thin, irregular trickle. The pattern is not obvious. Why should two consecutive integers, which by definition share no common factor at all, ever conspire to produce the same totient? This article is about the surprising structure hiding inside that trickle, the constructions that generate solutions on demand, and the precise — and still partly open — story of *how rare* the collisions really are.

## Why this is hard, and why it is beautiful

The first thing to appreciate is that $n$ and $n+1$ are always **coprime**: consecutive integers can never share a prime factor. (If a prime $p$ divided both, it would divide their difference, which is 1 — impossible.) This is the cleanest of facts, and in the formal development it is recorded as the lemma `coprime_self_succ`: for every $n$, the numbers $n$ and $n+1$ are coprime.

That coprimality is exactly what makes the equation $\varphi(n) = \varphi(n+1)$ interesting. The totient is *multiplicative*: if $a$ and $b$ are coprime, then $\varphi(ab) = \varphi(a)\,\varphi(b)$. For a prime power it is explicit:

$$\varphi(p^e) = p^{e-1}(p-1).$$

So the totient depends only on the **set of prime factors and their exponents**. A collision $\varphi(n) = \varphi(n+1)$ is therefore a delicate balancing act: two numbers built from completely *different* primes (they must be, since they are coprime) nevertheless produce the same totient value. It is like two orchestras with entirely different instruments playing the exact same chord.

Look at the smallest interesting example. We have $15 = 3 \cdot 5$ and $16 = 2^4$. Then

$$\varphi(15) = (3-1)(5-1) = 2 \cdot 4 = 8, \qquad \varphi(16) = 2^{4-1} = 8.$$

A product of small odd primes on one side, a pure power of two on the other — and the totients land on the same number, 8. This is no accident of small numbers. The same "power of two versus product of small odd primes" balancing recurs:

- $255 = 3 \cdot 5 \cdot 17$ and $256 = 2^8$, both with totient $128$;
- $104 = 2^3 \cdot 13$ and $105 = 3 \cdot 5 \cdot 7$, both with totient $48$;
- $495 = 3^2 \cdot 5 \cdot 11$ and $496 = 2^4 \cdot 31$, both with totient $240$.

Each of these is verified not by brute force but by genuine multiplicative reasoning — factoring both neighbors into coprime prime powers and computing $\varphi$ piece by piece. In the formal record these are the witness lemmas `ghp_15`, `ghp_104`, `ghp_164`, `ghp_194`, `ghp_255`, `ghp_495`, `ghp_584`, `ghp_975`.

## A factory for collisions: Fermat's old friends

Sporadic examples are charming, but the real prize is a **machine** that manufactures collisions. There is one, and it reaches back to Fermat.

A **Fermat number** is $F_k = 2^{2^k} + 1$. The first five are
$$F_0 = 3,\quad F_1 = 5,\quad F_2 = 17,\quad F_3 = 257,\quad F_4 = 65537,$$
and remarkably, all five are prime. (These are the celebrated *Fermat primes*; whether any larger Fermat number is prime is a famous open question.)

Fermat numbers obey a gorgeous telescoping identity. The product of the first $m$ of them is always one less than a giant power of two:

$$\prod_{k=0}^{m-1} F_k = 2^{2^m} - 1.$$

Now watch the trick. Let $N_m = \prod_{k=0}^{m-1} F_k$ be that product. Then $N_m + 1 = 2^{2^m}$ — a perfect power of two. Suppose the Fermat numbers $F_0, \dots, F_{m-1}$ are all prime. Then on the one hand,

$$\varphi(N_m + 1) = \varphi\!\left(2^{2^m}\right) = 2^{2^m - 1}.$$

On the other hand, the $F_k$ are pairwise coprime (a classical fact about Fermat numbers), so the totient distributes across the product, and since each $F_k$ is prime, $\varphi(F_k) = F_k - 1 = 2^{2^k}$:

$$\varphi(N_m) = \prod_{k=0}^{m-1}(F_k - 1) = \prod_{k=0}^{m-1} 2^{2^k} = 2^{\sum_{k<m} 2^k} = 2^{2^m - 1}.$$

The two sides match exactly. So **whenever the first $m$ Fermat numbers are all prime, $N_m$ is a solution of $\varphi(n) = \varphi(n+1)$.** This is the theorem `fermatFamily_totient_eq`, and its skeleton — the telescoping, the coprimality, the geometric-sum exponent $\sum_{k<m} 2^k = 2^m - 1$ — is exactly what the supporting lemmas `fermatProd_succ`, `totient_fermatProd`, `prod_fermatNumber_sub_one`, and `totient_two_pow_pow` make precise.

Because we *know* the first five Fermat numbers are prime, we get a concrete, unconditional solution for free. Taking $m = 5$:

$$N_5 = 3 \cdot 5 \cdot 17 \cdot 257 \cdot 65537 = 4294967295 = 2^{32} - 1,$$

and indeed $\varphi(4294967295) = \varphi(4294967296) = 2^{31} = 2147483648$. This is the theorem `fermatFamily_solution_2pow32`: a single, exact, ten-digit collision delivered by three-centuries-old primes.

And here is the tantalizing part. If — *if* — arbitrarily long initial runs of Fermat numbers were all prime, the same machine would run forever, producing infinitely many solutions of ever-increasing size. That conditional statement is fully established as `infinite_solutions_of_infinitely_many_fermat_initial_segments`: *given* an endless supply of all-prime Fermat prefixes, the solution set is infinite. The implication is airtight; only its hypothesis is unknown. It is a clean illustration of how one famously open problem (are there infinitely many Fermat primes?) can be bottled and handed off as the single missing input to another (are there infinitely many totient-neighbor collisions?).

## Rules the collisions must obey

Even without resolving infinitude, we can pin down the *shape* of solutions.

First, a parity law. For $n \ge 2$, the totient $\varphi(n)$ is always even once $n \ge 3$. So if $n$ and $n+1$ collide with $n \ge 2$, their common value is **even**. This is the lemma `totient_shift_value_even`: every unit-shift collision value (for $n \ge 2$) is an even number. It is a small fact with a big consequence — it explains, at a stroke, why the collisions can never become *too* common, a point we return to below.

Second, a primality obstruction. A solution can never have $n+1$ prime. If $n+1$ were prime we would have $\varphi(n+1) = n$, but $\varphi(n) \le n - 1 < n$ for $n \ge 2$ — a contradiction. This is `succ_not_prime_of_shift`. A companion fact, `not_both_prime_of_shift`, records that $n$ and $n+1$ are never simultaneously prime at a solution (indeed they can never both be prime once $n \ge 3$, since one of them is even).

Third — and this is a cautionary tale about folklore — a *popular* claimed rule is simply **false**. It is sometimes asserted that any solution $n$ must be odd. But $n = 104$ is even and $\varphi(104) = \varphi(105) = 48$. This counterexample, recorded as `even_solution_counterexample`, is a reminder that in number theory, a pattern that holds for the first few cases is a conjecture, not a theorem.

## How rare, exactly? The tightness question

Now to the deep question that gives this whole story its name. Define the **counting function**

$$S_1^{\varphi}(x) = \#\{\, n \le x : \varphi(n) = \varphi(n+1)\,\},$$

the number of collisions up to $x$. In the formal development this is `S1phi`, and two elementary facts about it are nailed down immediately: it is monotone — counting over a larger range can only find more collisions (`S1phi_mono`) — and it can never reach its trivial ceiling: $S_1^{\varphi}(x) < x$ for all $x \ge 2$ (`S1phi_lt_self`), because, for instance, $n = 2$ is *not* a solution ($\varphi(2) = 1 \ne 2 = \varphi(3)$). The parity law above is the structural reason such non-solutions are abundant: the trivial bound is never even close to tight.

How *sparse* are the collisions, then? A landmark analytic result of Graham, Holt, and Pomerance gives the upper bound

$$S_1^{\varphi}(x) \ll x \cdot \exp\!\left\{-\left(\tfrac12 - o(1)\right)\sqrt{\log x \cdot \log\log x}\,\right\}.$$

That exotic-looking factor — an exponential of a square root of a product of logarithms — is the fingerprint of "anatomy of integers" arguments: it is the same shape that governs how many integers are built only from small primes. The **tightness** claim, the headline of this work, is that this upper bound is essentially *best possible*: there is a constant $C > 0$ with

$$S_1^{\varphi}(x) \ge C\, x \cdot \exp\!\left\{-\left(\tfrac12 + o(1)\right)\sqrt{\log x \cdot \log\log x}\,\right\}$$

for all large $x$. Upper and lower bounds sandwich the truth, and the rarity of totient-neighbors is thereby measured with precision.

The lower bound is proved by a strategy that is conceptually simple even though its execution is formidable: **construct** many collisions, then **count** them. The clean logical core of that strategy is captured by a transfer theorem, `S1phi_ge_card`:

> If $W$ is any finite set of certified witnesses — numbers $w$ with $1 \le w \le x$ and $\varphi(w) = \varphi(w+1)$ — then $|W| \le S_1^{\varphi}(x)$.

In words: every batch of constructed solutions you can verify below $x$ is, automatically, a lower bound on the count. This severs the *constructive* part of the argument (build solutions) from the *analytic* part (estimate how many you can build), and it makes the rest of the lower-bound program a matter of feeding in dense families of witnesses.

We can already feed it real data. From the multiplicatively verified witnesses, the transfer theorem yields explicit, unconditional counts: at least six collisions occur up to $194$ (the set $\{1, 3, 15, 104, 164, 194\}$, theorem `S1phi_ge_six`) and at least ten occur up to $975$ (adding $255, 495, 584, 975$, theorem `S1phi_ge_ten`). These are not the deep asymptotic — they are the first concrete rungs on the ladder the asymptotic climbs.

## The frontier

What remains open is the genuine heart of the matter: producing an *infinite*, *dense* family of collisions by elementary means. The Fermat construction gives a beautiful infinite family — but only conditionally, hostage to the unknown supply of Fermat primes. The full Graham–Holt–Pomerance lower bound sidesteps Fermat primes using subtle smooth-number estimates and sieve methods, machinery that lives squarely in analytic number theory. Whether the simplest possible question — are there infinitely many $n$ with $\varphi(n) = \varphi(n+1)$? — has an elementary answer is, astonishingly, still unknown.

That is the texture of this corner of mathematics. A question a curious child could ask — *when do neighbors have the same totient?* — splits into a part we can build by hand (Fermat's telescoping product, the multiplicative balancing of $255$ against $256$), a part we can constrain (parity, primality), a part we can measure with the heaviest tools (the tight asymptotic), and a part that remains, gloriously, just out of reach. The collisions are rare, structured, and stubborn — and counting them exactly is a small triumph of mathematics that knows precisely how much it does, and does not yet, understand.
