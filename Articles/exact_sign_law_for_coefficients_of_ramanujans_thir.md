# A Hidden Traffic Light in Ramanujan's Last Notebook

## When a mathematician's dying scribbles keep their secrets for a century

In the first months of 1920, wasted by illness and knowing he had little time left, Srinivasa Ramanujan wrote a final letter to his mentor G. H. Hardy in England. Among the formulas in that letter were seventeen strange new functions he called **mock theta functions**. He gave almost no proofs, no definitions in the modern sense, and no explanation of where they came from. He simply asserted that these functions behaved *almost* like the classical, beautifully symmetric objects called theta functions — close enough to mimic them, yet different enough to escape every existing theory.

For eighty years nobody could even say precisely what a mock theta function *was*. It took until the twenty-first century, and the work of Sander Zwegers, to give them a rigorous home inside the theory of harmonic modular forms. But even now, individual mock theta functions keep surprising us with concrete, elementary-looking patterns that are maddeningly hard to prove.

This is the story of one such pattern — a "traffic light" hidden in the coefficients of one of Ramanujan's third order mock theta functions, the function he wrote as $\rho(q)$.

## The function

Here is $\rho(q)$, exactly as it grows out of Ramanujan's world of $q$-series:

$$\rho(q) \;=\; \sum_{m\ge 0} \frac{q^{2m(m+1)}}{\bigl(1+q+q^{2}\bigr)\bigl(1+q^{3}+q^{6}\bigr)\bigl(1+q^{5}+q^{10}\bigr)\cdots\bigl(1+q^{2m+1}+q^{4m+2}\bigr)}.$$

More compactly, the $m$-th term has numerator $q^{2m(m+1)}$ and a denominator that is a product of $m+1$ little three-term factors,

$$\rho(q) \;=\; \sum_{m\ge 0} \frac{q^{2m(m+1)}}{\displaystyle\prod_{k=0}^{m}\bigl(1+q^{2k+1}+q^{4k+2}\bigr)}.$$

Don't be intimidated by the fractions. A term like $1/(1+q+q^2)$ is just shorthand for an infinite power series — expand it as $1 - q + q^3 - q^4 + q^6 - \cdots$ — and the whole expression, once you add up all the terms and collect powers of $q$, becomes a single ordinary power series:

$$\rho(q) \;=\; \sum_{n\ge 0} r(n)\,q^{n} \;=\; 1 - q + q^{3} - q^{5} + q^{6} - q^{7} + \cdots.$$

The numbers $r(n)$ are the **coefficients** of $\rho$. They are integers. And they are the heroes of this article.

Here are the first several dozen of them:

$$1,\,-1,\,0,\,1,\,0,\,-1,\,1,\,-1,\,0,\,1,\,-1,\,0,\,2,\,-1,\,-1,\,1,\,-1,\,-1,\,2,\,-1,\,0,\,2,\,-1,\,-1,\,2,\,-2,\,-1,\,3,\dots$$

Stare at this list long enough and something strange happens. The signs are not random.

## The pattern

Group the coefficients by their position modulo $3$ — that is, split the whole numbers $0,1,2,3,4,\dots$ into three columns depending on their remainder when divided by three:

| $n \equiv 0 \pmod 3$ | $n \equiv 1 \pmod 3$ | $n \equiv 2 \pmod 3$ |
|:---:|:---:|:---:|
| $r(0)=1$ | $r(1)=-1$ | $r(2)=0$ |
| $r(3)=1$ | $r(4)=0$ | $r(5)=-1$ |
| $r(6)=1$ | $r(7)=-1$ | $r(8)=0$ |
| $r(9)=1$ | $r(10)=-1$ | $r(11)=0$ |
| $r(12)=2$ | $r(13)=-1$ | $r(14)=-1$ |
| $r(15)=1$ | $r(16)=-1$ | $r(17)=-1$ |
| $\vdots$ | $\vdots$ | $\vdots$ |

The left column is **always positive**. The middle and right columns are **never positive** — every entry is negative or zero. It is a mathematical traffic light: green for the multiples of three, red for everything else.

Stated cleanly, the conjecture is:

> **The Sign Law.** For every whole number $n \ge 0$,
> $$r(3n) > 0, \qquad r(3n+1) \le 0, \qquad r(3n+2) \le 0.$$

This is remarkable. There is no obvious reason a function built from those innocent-looking three-term factors should sort its coefficients so cleanly by remainder mod three. The signs of coefficients in $q$-series are notoriously wild; whole research programs exist just to understand when the coefficients of a given series stay one sign.

## The five rebellious zeros

Look again at the two "red" columns. They are supposed to be strictly negative — but a handful of entries are exactly zero rather than negative:

$$r(2) = r(4) = r(8) = r(11) = r(20) = 0.$$

These are the only exceptions, and they all happen early. After $n = 20$, the red columns never touch zero again — every $r(3n+1)$ and $r(3n+2)$ becomes strictly negative and stays that way. And the green column is even better behaved: $r(3n)$ is strictly positive for *every* $n$, with no exceptions at all.

So the full, sharpened conjecture reads:

> **The Exact Sign Law.** For every $n$, $r(3n) > 0$. For every $n$, $r(3n+1) \le 0$ and $r(3n+2) \le 0$, with equality (a zero coefficient) occurring in these two classes if and only if
> $$n \in \{2,\,4,\,8,\,11,\,20\}.$$

Five sporadic zeros, then perfect discipline forever. It is the kind of statement that feels almost impossible to be a coincidence — and almost impossible to prove.

## Where does the number three come from?

The most beautiful part of this story is that the mysterious modulus $3$ is not mysterious at all once you look at the right algebraic identity. Everything hinges on a single fact from high-school algebra dressed up in fancy clothes.

Recall the factorization of a difference of cubes:

$$1 - Y^{3} = (1 - Y)\,(1 + Y + Y^{2}).$$

Now look at a typical denominator factor of $\rho$. It is $1 + q^{2k+1} + q^{4k+2}$. If we write $Y = q^{2k+1}$, then $q^{4k+2} = Y^2$, so this factor is *exactly* $1 + Y + Y^2$ — the second piece of the difference-of-cubes factorization. Therefore:

$$\bigl(1 - q^{2k+1}\bigr)\bigl(1 + q^{2k+1} + q^{4k+2}\bigr) \;=\; 1 - q^{3(2k+1)} \;=\; 1 - q^{6k+3}.$$

This little identity is the key that unlocks the whole structure. It tells us that the reciprocal of each awkward three-term factor has a clean closed form:

$$\frac{1}{1 + q^{2k+1} + q^{4k+2}} \;=\; \frac{1 - q^{2k+1}}{1 - q^{6k+3}}.$$

And $1/(1 - q^{6k+3})$ is just the geometric series $1 + q^{6k+3} + q^{12k+6} + \cdots$. So each denominator factor, upon inversion, splits into a very sparse two-term polynomial times a very sparse geometric series — no messy general power-series inversion required.

Multiply all these single-factor identities together and the denominators **telescope**. The full product of three-term factors becomes a clean ratio of two theta-like products:

$$\prod_{k=0}^{m}\bigl(1 + q^{2k+1} + q^{4k+2}\bigr) \;=\; \frac{\displaystyle\prod_{k=0}^{m}\bigl(1 - q^{6k+3}\bigr)}{\displaystyle\prod_{k=0}^{m}\bigl(1 - q^{2k+1}\bigr)}.$$

Now watch where the three comes from. Each three-term factor $1 + q^{2k+1} + q^{4k+2}$ has three exponents: $0$, then $2k+1$, then $4k+2$. Reduce those three exponents modulo $3$: they are $0$, $a$, and $2a$ where $a = 2k+1$. Whenever $a$ is not itself a multiple of three, the trio $\{0, a, 2a\}$ sweeps out *all three* remainders mod $3$ — a complete residue system. In other words, the factor $1 + Y + Y^2$ is nothing but the third **cyclotomic building block**, the algebraic embodiment of "cube roots of unity," and cube roots of unity live and breathe the number three. The modulus $3$ in the sign law is the fingerprint of these hidden cube roots.

This telescoping factorization is a genuine algebraic identity — it holds for every $m$, with no approximation and no appeal to size or positivity. That robustness is exactly why it can serve as the reliable engine underneath everything else.

## Why it is hard, and what is known

If the algebra is so clean, why isn't the sign law simply proved?

Because knowing the *shape* of a series is not the same as knowing the *signs* of its coefficients. When you finally assemble $\rho$ from all its pieces, each coefficient $r(n)$ becomes a **signed count** — a delicate tug-of-war between plus-one contributions and minus-one contributions coming from the numerators $q^{2m(m+1)}$ battling the alternating $(1 - q^{2k+1})$ factors. The residue-mod-3 bookkeeping guarantees that, in the long run, the pluses win in the green column and lose in the red columns. But "in the long run" is the catch. Near the beginning, the contest is close, and the balance can tip to an exact tie — which is precisely what produces the five sporadic zeros. Proving that no *sixth* tie ever occurs, and that the red columns never accidentally go positive, is a finite-range positivity problem of exactly the sort that resists easy arguments.

The *asymptotic* version of the sign law — the statement that the pattern holds for all sufficiently large $n$ — is established. The remaining gap is entirely about the "tail": nailing down the finitely many small cases and proving the transition to strict signs happens exactly at $n = 20$ and never reverses. Direct calculation confirms the exact statement far beyond the last sporadic zero — the pattern has been checked to hold, with the zero set frozen at those five values, for every $n$ up to $150$ and well past. What is missing is a closed argument bridging the small cases to the asymptotic regime.

## A glimpse of what comes next

The traffic light is only the first of several patterns hiding in these coefficients. The green column — the strictly positive values $r(3n)$ — is not just positive; it *grows*, apparently without bound and roughly in proportion to $n$. Yet it does so unevenly: $r(12) = 2$ but $r(15) = 1$, a temporary dip inside a rising tide. This is the signature of a steady linear growth term buffeted by a bounded oscillation, and pinning down the precise growth rate is a natural next target.

Even the five zeros want an explanation of their own. Each one, the evidence suggests, marks a spot where the plus-contributions and minus-contributions cancel *perfectly* — a rare exact balance possible only when very few factors are in play, i.e. only for small $n$. Turning "perfect cancellation happens exactly five times" into a theorem would give a genuinely satisfying reason why the exceptional set is $\{2,4,8,11,20\}$ and nothing more.

## Why care about a traffic light?

One might ask why anyone should care about the signs of the coefficients of a hundred-year-old curiosity. The honest answer is the same one that motivated Ramanujan: because the patterns are *there*, hiding in plain sight, and their very existence hints at deeper structure. Mock theta functions turned out to be central objects in modern number theory, connected to partitions, to the arithmetic of modular forms, and even to black-hole entropy in physics through the theory of mock modular forms. When a function as fundamental as $\rho(q)$ sorts its coefficients into a clean traffic-light pattern governed by the cube roots of unity, that pattern is a clue. It says: here is an object whose internal arithmetic is far more organized than it has any right to be.

Ramanujan saw such patterns everywhere, often without proof, often correctly. A century later we are still catching up — verifying, sharpening, and occasionally proving the things he seems to have simply *known*. The sign law of $\rho(q)$, with its stubborn five zeros and its cube-root-of-unity heartbeat, is one more entry in that long, humbling ledger.
