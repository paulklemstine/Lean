# How Often Can a Number Appear in Pascal's Triangle?

*A guided tour: from a puzzle you can see with your eyes, to a complete classification of an infinite family of coincidences.*

---

## 1. The question

Write out [Pascal's triangle](https://en.wikipedia.org/wiki/Pascal%27s_triangle). Ignore the border of $1$'s — that single value repeats forever, and it is the only one that does. Every other integer $n \ge 2$ appears **at least twice**, because
$$n = \binom{n}{1} = \binom{n}{n-1}.$$
Those two appearances are free, and they are boring. The interesting question is how many *extra* appearances a number can collect.

Define the **multiplicity**
$$m(n) = \#\Bigl\{(N,k) \ : \ 0 \le k \le N, \ \tbinom{N}{k} = n\Bigr\}.$$

A few values, which you can check by eye:

| $n$ | $m(n)$ | where |
|---:|---:|---|
| $5$ | $2$ | edges only |
| $6$ | $3$ | $\binom{4}{2}$ and the edges |
| $10$ | $4$ | $\binom{5}{2}, \binom{5}{3}$ and the edges |
| $120$ | $6$ | $\binom{10}{3}, \binom{10}{7}, \binom{16}{2}, \binom{16}{14}$ and the edges |
| $3003$ | $8$ | $\binom{14}{6}, \binom{14}{8}, \binom{15}{5}, \binom{15}{10}, \binom{78}{2}, \binom{78}{76}$ and the edges |

In 1971 David Singmaster conjectured that $m$ is **bounded by an absolute constant** — see [Singmaster's conjecture](https://en.wikipedia.org/wiki/Singmaster%27s_conjecture). Fifty years later this is wide open. The largest known value is $m(3003)=8$; the best unconditional upper bounds are of size $O(\log n/\log\log n)$, which is infinitely far from a constant.

This page is a tour of what *can* be proved, ending with a brand-new classification theorem.

---

## 2. Play first: the Singmaster Laboratory

Before any proofs, get your hands dirty. Type a number into panel 1 and see its multiplicity, all of its positions, and the theorem that explains the answer. Then, in panel 2, watch the descent that classifies the deepest coincidences. (Suggested tour: try $3003$; then $924$, whose multiplicity is *odd*; then $58$, which is forced to appear exactly twice; then run the descent on the rung $(714, 272)$.)

{{interactive_demo:0}}

Everything the widget reports is a theorem. The rest of this page explains why.

---

## 3. Why the search is finite: two squeezes

Inside a row, binomial coefficients grow as you move toward the middle. Precisely: if $j \le k$ and $j+k \le N$ then $\binom{N}{j} \le \binom{N}{k}$.

Two consequences do all the work.

> **Row squeeze.** If $\binom{N}{k}=n$ with $2 \le k \le N-2$, then $N(N-1)\le 2n$.

*Why:* the smallest entry in that range is $\binom{N}{2} = N(N-1)/2$.

> **Column squeeze.** If $\binom{N}{k}=n$ with $2k \le N$, then $2^k \le \binom{2k}{k} \le n$, so $k \le \log_2 n$.

So all the *interesting* occurrences of $n$ — the ones that are not on the two edges — live inside a rectangle of size roughly $\sqrt{2n}\times\log_2 n$. For $n=3003$: rows at most $78$, columns at most $11$. That is why a laptop can settle the record in milliseconds.

<details>
<summary><b>Click to reveal the proof of row monotonicity</b></summary>

First assume $2k \le N$. Then $\binom{N}{k+1} = \binom{N}{k}\frac{N-k}{k+1}$, and $2(k+1)\le N$ gives $N-k \ge k+1$, so the row is non-decreasing up to the centre; induct. For the general case $j\le k$, $j+k\le N$ with $2k > N$: then $j \le N-k$ and $2(N-k) \le N$, so the special case gives $\binom{N}{j}\le\binom{N}{N-k} = \binom{N}{k}$. $\blacksquare$
</details>

Here is the confinement, drawn — together with a preview of the coincidence family we will classify in §7.

{{visualization:1}}

And here is the algorithm that exploits it: the difference between $O(n\log n)$ and $O(\sqrt n\,\log n)$ work.

{{algorithm:0}}

---

## 4. The parity law: why odd multiplicities are almost impossible

Pascal's triangle is symmetric: $\binom{N}{k}=\binom{N}{N-k}$. The reflection $k \mapsto N-k$ therefore pairs each occurrence strictly left of centre with one strictly right of centre. Only *central* occurrences, those with $N = 2k$, are unpaired. Hence
$$m(n) = 2\lambda(n) + \gamma(n),$$
where $\lambda(n)$ counts occurrences left of centre and $\gamma(n)$ counts central ones. And $\gamma(n)\le 1$, because the central binomial coefficients $\binom{2t}{t} = 1, 2, 6, 20, 70, 252, 924, 3432, \dots$ are strictly increasing.

> **Parity law.** For $n \ge 2$, $m(n)$ is **odd if and only if** $n$ is a central binomial coefficient $\binom{2t}{t}$.

This is the complete explanation of a pattern anyone tabulating multiplicities notices at once. Below $3003$ the *only* numbers of odd multiplicity are $2$, $6$, $20$, $70$, $252$, $924$ — exactly the central binomial coefficients in range.

<details>
<summary><b>Click to reveal why there is at most one central occurrence</b></summary>

From $(t+1)\binom{2t+2}{t+1} = 2(2t+1)\binom{2t}{t}$ and $\binom{2t}{t}>0$ one gets $\binom{2t+2}{t+1} > \binom{2t}{t}$, so $t \mapsto \binom{2t}{t}$ is strictly increasing and therefore injective. A central occurrence of $n$ is a $t$ with $\binom{2t}{t}=n$, so there is at most one. $\blacksquare$
</details>

The parity law converts a counting problem into an identification problem — and identification is cheap:

{{algorithm:2}}

---

## 5. Arithmetic obstructions: being boring on purpose

Everything above was combinatorial. Now bring in divisibility. If $p$ is a prime dividing $\binom{N}{k}$, then since $\binom{N}{k}$ divides $N!$, we get $p \le N$. Combine with the row squeeze:

> **Large-prime-factor theorem.** If $n \ge 3$ has a prime factor $p$ with $p(p-1) > 2n$, then $n$ has **no** interior occurrence, so $m(n)=2$ exactly.

A number with a big prime factor relative to its size is condemned to the edges. Immediately: $m(p)=2$ for every prime $p\ge5$, and $m(2p)=2$ for every prime $p\ge7$ — so infinitely many integers occur exactly twice.

Sharpen the same argument and you get something better than a bound — an *exact* infinite family.

> **Exact-four theorem.** For every prime $p \ge 5$, $m\!\left(\binom{p}{2}\right)=4$, the only interior occurrences being $(p,2)$ and $(p,p-2)$.

<details>
<summary><b>Click to reveal the proof of the exact-four theorem</b></summary>

Let $n=\binom{p}{2}=p(p-1)/2$; since $p$ is odd, $p \mid n$. Let $(N,k)$ be an interior occurrence. The row squeeze gives $N(N-1)\le 2n = p(p-1)$, hence $N\le p$. Divisibility gives $p \le N$. So $N=p$. Inside row $p$: if $3\le k\le p-3$ then $\binom{p}{k}\ge\binom{p}{3}>\binom{p}{2}=n$ (using $3\binom{p}{3}=\binom{p}{2}(p-2)$ and $p-2>3$), a contradiction. Hence $k\in\{2,p-2\}$: exactly two interior occurrences, and $m(n)=2+2=4$. $\blacksquare$
</details>

Now look at the whole landscape below the record. Grey is the generic value $2$; blue is the exact family $\binom{p}{2}$ at $4$; green diamonds are the central binomial coefficients, the only odd values; red stars are the rare coincidences at $6$ and the record at $8$.

{{visualization:0}}

---

## 6. Almost every integer occurs exactly twice

The confinement rectangle immediately gives a density theorem. Assign to each $n \le x$ with $m(n)\ge3$ one interior occurrence in the left half; distinct $n$'s get distinct positions (a position determines its value), and every position lies in the rectangle. Therefore

$$\#\{3\le n\le x : m(n)\ge3\} \ \le\ \bigl(\lfloor\sqrt{2x}\rfloor+2\bigr)\bigl(\lfloor\log_2 x\rfloor+2\bigr) \;=\; O(\sqrt x\log x).$$

| $x$ | actual exceptions | proved bound |
|---:|---:|---:|
| $100$ | $16$ | $128$ |
| $1000$ | $64$ | $506$ |
| $3000$ | $110$ | $1027$ |

Note the shape of our ignorance: we can prove that high multiplicity is *rare*, but not that it is *bounded*. Singmaster's conjecture is precisely the second statement.

---

## 7. Where coincidences come from — and the new theorem

Now the other direction: what *creates* a number of high multiplicity? One mechanism explains almost every known example. Ask when a number equals the entry one row up and one column right:

$$\binom{N}{k} = \binom{N-1}{k+1} \iff N(k+1) = (N-k)(N-k-1). \qquad (\ast)$$

A solution is a jackpot: it gives two occurrences, the mirror symmetry doubles them to four interior ones, and with the two edge occurrences the multiplicity is at least $6$. The smallest solution with $2\le k\le N/2$ is $(N,k) = (15,5)$ — that is $3003 = \binom{15}{5} = \binom{14}{6}$, the record holder. The next few are $(104,39)$, $(714,272)$, $(4895,1869)$.

Those numbers are products of Fibonacci numbers: $15 = 3\cdot5$, $104 = 8\cdot13$, $714 = 21\cdot34$, $4895 = 55\cdot89$. Indeed for every $i\ge1$ the pair
$$N_i = F_{2i+2}F_{2i+3}, \qquad k_i = F_{2i}F_{2i+3}$$
solves $(\ast)$, so infinitely many integers occur at least six times. The engine is the even form of the classical [Cassini identity](https://en.wikipedia.org/wiki/Cassini_and_Catalan_identities),
$$F_{2i+1}^2 = F_{2i}F_{2i+1} + F_{2i}^2 + 1.$$

**But is that all?** Could $(\ast)$ have solutions of some completely different shape — an unnoticed second family of six-fold coincidences? The answer, and the main new result of this work, is no.

> **Row-shift classification.** For integers with $2 \le k$ and $2k \le N$,
> $$N(k+1)=(N-k)(N-k-1) \iff \exists\, i\ge1:\ N = F_{2i+2}F_{2i+3},\quad k = F_{2i}F_{2i+3}.$$

The proof is a *two-step [Vieta descent](https://en.wikipedia.org/wiki/Vieta_jumping)* — the same technique that tames the Markov equation.

<details>
<summary><b>Click to reveal the descent argument in full</b></summary>

Clearing the truncated subtractions (valid for $k+2\le N$), equation $(\ast)$ becomes
$$k^2 + k + N^2 = 3Nk + 2N.$$
This is monic and quadratic in **each** variable separately, so it carries two involutions.

*Vieta in the row.* Fix $k$: $N^2 - (3k+2)N + (k^2+k) = 0$. If $N$ is a root so is $M = 3k+2-N$, with $NM = k(k+1)$. When $1\le k$ and $2k\le N$ one checks $2 \le M$, $M < N$ and $2M \le k+1$: a strictly smaller admissible row.

*Vieta in the column.* Fix the new row $M$: $k^2 - (3M-1)k + (M^2-2M) = 0$. If $k$ is a root so is $j = 3M-1-k$, with $kj = M(M-2)$, and $2M\le k+1$ forces $2j \le M$: the column is dragged back into range.

So $(N,k)\mapsto(M,j)$ is a strict descent inside the admissible region, and it must terminate. The only terminus is the degenerate pair $(2,0)$ — the $i=0$ member of the family, excluded by $k\ge2$.

*The ascent.* Reversing one step from $\bigl((a+b)(a+2b),\, a(a+2b)\bigr)$ produces $\bigl((2a+3b)(3a+5b),\, (a+b)(3a+5b)\bigr)$, and verifying that this is again a solution is *exactly* the relation $b^2 = ab+a^2+1$. With $(a,b) = (F_{2i},F_{2i+1})$ we have $a+b = F_{2i+2}$, $a+2b=F_{2i+3}$, $2a+3b = F_{2i+4}$, $3a+5b = F_{2i+5}$ — the Fibonacci index shifts by two, and the ladder reproduces itself. $\blacksquare$
</details>

<details>
<summary><b>Click to reveal the Pell shadow</b></summary>

Eliminating $k$ from the classification gives
$$(3N-1-2k)^2 = 5N^2 + 2N + 1,$$
so $5N^2+2N+1$ must be a perfect square; equivalently $(5N+1)^2 - 5(3N-1-2k)^2 = -4$, the [Pell-type equation](https://en.wikipedia.org/wiki/Pell%27s_equation) whose solutions are the Lucas–Fibonacci pairs. At $(N,k)=(15,5)$: $34^2 = 1156 = 5\cdot 225 + 30 + 1$, with $5N+1 = 76 = L_9$ and $3N-1-2k = 34 = F_9$.

Notably the classification does **not** need Pell theory — the descent alone suffices, and the Pell equation appears only as a corollary.
</details>

Run the descent yourself on any rung (panel 2 of the laboratory above), or in code:

{{algorithm:1}}

And here is the whole story verified end to end — brute-force search matching the Fibonacci prediction exactly, the descent chains, the Cassini identity, the Pell shadow, and the four interior positions per rung:

{{demo:1}}

---

## 8. The record, dissected

Finally the small-number end. With the row squeeze, verifying a multiplicity is a finite computation with an explicit radius, and carrying it out gives the definitive local picture:

- $m(3003) = 8$, realised at $(14,6), (14,8), (15,5), (15,10), (78,2), (78,76), (3003,1), (3003,3002)$;
- $m(n)\le 8$ for **every** $n<3003$ — so $3003$ is a genuine record, not just the smallest example of $8$;
- $m(n) \ne 5$ and $m(n)\ne 7$ for all $n<3003$ (odd multiplicity forces a central binomial coefficient, and each of those has multiplicity $3$);
- the attained multiplicities are $1, 2, 3, 4, 6, 8$, witnessed by $2, 5, 6, 21, 120, 3003$.

<details>
<summary><b>Click to reveal how "no multiplicity above 8 below 3003" is proved</b></summary>

Write $m(n) = 2 + 2\iota_L(n) + \gamma(n)$, where $\iota_L(n)$ counts interior occurrences strictly left of centre. If $\gamma(n)=1$ then $m(n)$ is odd, hence equals $3$ by the parity law plus the list of small central binomials. If $\gamma(n)=0$ it suffices to show $\iota_L(n)\le3$. For $n<3003$ such an occurrence has $N\le78$ (row squeeze) and $k\le6$, because $k\ge7$ with $2k\le N$ would give $\binom{N}{k}\ge\binom{14}{7}=3432>3003$. So all candidates lie in one finite strip of positions, and a direct check shows no value is hit more than three times inside it. $\blacksquare$
</details>

The complete numerical audit — every theorem on this page, asserted rather than merely printed:

{{demo:0}}

---

## 9. Where this leaves the conjecture

We now have a network of reasons for the *floor* of the multiplicity function:

* a **parity law** forbidding odd values except at central binomial coefficients;
* an **arithmetic obstruction** pinning numbers with a large prime factor to exactly $2$;
* an **exact infinite family** at $4$;
* a **Fibonacci ladder** pushing infinitely many values to at least $6$ — and, now, the knowledge that this ladder is *everything* its mechanism can produce;
* a **density bound** showing the exceptions number at most $O(\sqrt x\log x)$ up to $x$.

And yet the *ceiling* remains untouched. Notice, too, that the record is only half explained: the ladder accounts for the four occurrences of $3003$ in rows $14$ and $15$, but the extra coincidence $3003 = \binom{78}{2}$ is a *distant-row* collision, and no mechanism is known that produces an infinite family of those. Whether any integer other than $3003$ has multiplicity $8$ is unknown.

The natural next target is the two-row shift $\binom{N}{k} = \binom{N-2}{k+r}$. Does it also carry a pair of Vieta involutions? Is its solution set again a linear-recurrence ladder — or empty? Either answer would be news.
