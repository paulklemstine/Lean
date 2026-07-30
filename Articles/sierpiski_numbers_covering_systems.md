# Seven Small Primes Against an Infinite Tower

## How a finite covering system proves that $78557\cdot 2^n+1$ is composite forever

There is something audacious about an infinite claim. Compute a million examples and the next one may rebel. Check a trillion, and infinity remains untouched. Yet number theory often turns the infinite into the finite by finding the right rhythm.

The number $78557$ offers a striking example. For every nonnegative integer $n$, form

$$
N_n=78557\cdot 2^n+1.
$$

The first few terms are $78558$, $157115$, $314229$, and $628457$. They grow exponentially. Nevertheless, none is prime. The reason is not a heroic factorization of ever-larger integers. It is a repeating choreography involving only seven primes:

$$
3,\ 5,\ 7,\ 13,\ 19,\ 37,\ 73.
$$

Each exponent $n$ falls into one of seven congruence classes, and the class tells us in advance which small prime divides $N_n$. The classes cover every possible exponent, so no exponent can escape.

This is the central result:

**Universal compositeness theorem.** For every nonnegative integer $n$, the number $78557\cdot 2^n+1$ has a proper prime divisor belonging to $\{3,5,7,13,19,37,73\}$. Consequently, $78557\cdot 2^n+1$ is composite for every $n\ge 0$.

An odd positive integer $k$ with this universal compositeness property is called a **Sierpiński number**. Thus $78557$ is a Sierpiński number. This statement should not be confused with the famous unresolved question of whether $78557$ is the *smallest* one. The covering argument proves membership, not minimality.

## The clocks hidden inside powers of two

Why should seven primes control infinitely many exponents? Modular arithmetic makes powers repeat. Consider powers of $2$ modulo $3$:

$$
2^0\equiv 1,\qquad 2^1\equiv 2,\qquad 2^2\equiv 1\pmod 3.
$$

The pattern has period $2$. Modulo $5$, powers of $2$ have period $4$. More generally, if

$$
2^M\equiv 1\pmod p,
$$

then multiplication by another block of $2^M$ changes nothing modulo $p$. Writing $n=qM+r$ gives

$$
2^n=2^{qM+r}=(2^M)^q2^r\equiv 2^r\pmod p.
$$

This yields the **periodicity principle**: whenever $2^M\equiv1\pmod p$, the residue of $2^n$ modulo $p$ depends only on $n\bmod M$.

A second principle follows immediately. Suppose $p$ divides $k2^r+1$, and $n\equiv r\pmod M$. Then $2^n\equiv2^r\pmod p$, so

$$
k2^n+1\equiv k2^r+1\equiv0\pmod p.
$$

Call this the **divisor-transfer principle**. One divisibility check at a representative exponent propagates along an entire arithmetic progression of exponents.

The infinite sequence has become a collection of modular clocks.

## Seven nets cover every exponent

For $78557$, use these seven classes:

| Condition on $n$ | Guaranteed divisor of $78557\cdot2^n+1$ |
|---|---:|
| $n\equiv0\pmod2$ | $3$ |
| $n\equiv1\pmod4$ | $5$ |
| $n\equiv1\pmod3$ | $7$ |
| $n\equiv11\pmod{12}$ | $13$ |
| $n\equiv15\pmod{18}$ | $19$ |
| $n\equiv27\pmod{36}$ | $37$ |
| $n\equiv3\pmod9$ | $73$ |

A finite collection of congruence classes that contains every nonnegative integer is called a **covering system**. The table above is such a system.

To see the coverage, first catch every even exponent with $n\equiv0\pmod2$. Among odd exponents, those congruent to $1$ modulo $4$ are caught by the second class. The remaining odd exponents are congruent to $3$ modulo $4$. Some satisfy $n\equiv1\pmod3$ and enter the third class. What remains is easiest to inspect over one common period.

All seven moduli divide $36$, so the whole pattern repeats every $36$ exponents. Examining residues $0$ through $35$ is enough. The associated divisor table is

$$
\begin{array}{c|rrrrrrrrrrrr}
r&0&1&2&3&4&5&6&7&8&9&10&11\\
\hline
p&3&5&3&73&3&5&3&7&3&5&3&13
\end{array}
$$

$$
\begin{array}{c|rrrrrrrrrrrr}
r&12&13&14&15&16&17&18&19&20&21&22&23\\
\hline
p&3&5&3&19&3&5&3&7&3&5&3&13
\end{array}
$$

$$
\begin{array}{c|rrrrrrrrrrrr}
r&24&25&26&27&28&29&30&31&32&33&34&35\\
\hline
p&3&5&3&37&3&5&3&7&3&5&3&13.
\end{array}
$$

Every column has a prime. That is the finite heart of the infinite proof.

## Why the divisors really work

The entries are not arbitrary. Each comes from a congruence that matches the period of powers of two.

For even $n$, $2^n\equiv1\pmod3$, while $78557\equiv2\pmod3$. Therefore

$$
78557\cdot2^n+1\equiv2\cdot1+1\equiv0\pmod3.
$$

For $n\equiv1\pmod4$, powers of two repeat modulo $5$ with period $4$. Since $78557\equiv2\pmod5$ and $2^1=2$,

$$
78557\cdot2^n+1\equiv2\cdot2+1\equiv0\pmod5.
$$

For $n\equiv1\pmod3$, powers repeat modulo $7$ with period $3$; because $78557\equiv3\pmod7$,

$$
78557\cdot2^n+1\equiv3\cdot2+1\equiv0\pmod7.
$$

The four exceptional-looking classes work the same way:

$$
\begin{aligned}
2^{12}&\equiv1\pmod{13}, & 13&\mid78557\cdot2^{11}+1,\\
2^{18}&\equiv1\pmod{19}, & 19&\mid78557\cdot2^{15}+1,\\
2^{36}&\equiv1\pmod{37}, & 37&\mid78557\cdot2^{27}+1,\\
2^9&\equiv1\pmod{73}, & 73&\mid78557\cdot2^3+1.
\end{aligned}
$$

The divisor-transfer principle extends each base divisibility to its full congruence class. Coverage then guarantees that at least one row applies to every $n$.

There is one subtlety. A divisor does not prove compositeness if it equals the entire number. Here each assigned prime is a **proper** divisor. At the representative residues this is immediate from direct comparison, and the terms only increase as the exponent increases. Equivalently, the smallest term is already $78558$, far larger than the largest covering prime $73$. Thus every $N_n$ has a prime divisor strictly between $1$ and $N_n$.

## A reusable certificate

The argument suggests a compact recipe for proving universal compositeness of other sequences $k2^n+1$. Choose a positive period $M$. For each residue $r\in\{0,1,\dots,M-1\}$, assign a prime $p_r$ satisfying three conditions:

1. $2^M\equiv1\pmod{p_r}$;
2. $p_r\mid k2^r+1$;
3. $p_r<k2^r+1$.

Then every exponent $n$ reduces to $r=n\bmod M$. Periodicity transfers the divisibility from $r$ to $n$, and monotonicity preserves properness. Therefore $k2^n+1$ is never prime.

Call such data a **finite covering certificate**. Its power lies in the mismatch of scales: infinitely many enormous integers are controlled by a finite table of small modular facts. For $k=78557$, the period is $M=36$, and the displayed table is the certificate.

This idea reaches beyond a single sequence. In computation, periodic certificates let a program replace unbounded search with a bounded audit. In cryptography, the same modular habits—periods, residue classes, and divisibility—shape both algorithms and attacks, even though cryptographic parameters are chosen to avoid exactly this kind of predictable small-factor trap. In scheduling, congruence classes describe recurring events on clocks with different cycle lengths. The mathematical language is the same: local rhythms combine into a global pattern.

## When clocks must agree

Covering systems naturally lead to the Chinese remainder theorem. A normalized congruence class is a condition

$$
n\equiv a\pmod m,
$$

where $m>0$ and $0\le a<m$. Two classes are **compatible** if some integer satisfies both.

If their moduli $m_1$ and $m_2$ are coprime, every pair of residues is compatible. This is the familiar Chinese remainder theorem. A more general compatibility theorem says that the conditions

$$
n\equiv a_1\pmod{m_1},\qquad n\equiv a_2\pmod{m_2}
$$

have a simultaneous solution whenever

$$
a_1\equiv a_2\pmod{\gcd(m_1,m_2)}.
$$

The reason is necessary to the geometry of the clocks: any common solution makes $a_1-a_2$ divisible by both moduli’ common divisor. It is also sufficient: after removing the shared gcd, the remaining moduli can be reconciled by the coprime theorem.

These compatibility results do not alone prove that a list covers all integers; coverage is a union problem, while compatibility concerns intersections. But together they provide a toolkit for designing and combining modular schedules.

## A miniature journey through the table

Take an exponent that looks far removed from the small representatives, say $n=63$. Reducing modulo $36$ gives $27$. The table therefore assigns the prime $37$. We do not need to construct or factor the twenty-four-digit integer $78557\cdot2^{63}+1$. Since $2^{36}\equiv1\pmod{37}$ and $37$ divides $78557\cdot2^{27}+1$, the extra block of $36$ in the exponent is invisible modulo $37$:

$$
78557\cdot2^{63}+1
=78557\cdot2^{27}2^{36}+1
\equiv78557\cdot2^{27}+1
\equiv0\pmod{37}.
$$

Or take $n=1000$. Its residue modulo $36$ is $28$, an even residue, so the table chooses $3$. Because every even exponent makes $2^n\equiv1\pmod3$ and $78557\equiv2\pmod3$, the entire $306$-digit term is divisible by $3$. A tiny remainder calculation settles what direct factorization would make needlessly difficult.

This is why a certificate is more informative than a long list of factorizations. It explains *why* each future case must behave in the same way. The table is not evidence gathered from a sample; it is a map of every possible modular state. There are only $36$ states because all seven clocks reset together after $36$ steps.

The covering is also deliberately redundant in places. An exponent may satisfy more than one class, and then several small primes may divide the same term. Covering systems require at least one gate for every exponent, not exactly one. The period table simply chooses one available gate in each column, turning an overlapping family into an unambiguous lookup rule.

## What the proof does—and does not—settle

The covering gives an exact, unconditional conclusion: $78557$ is a Sierpiński number, and every term $78557\cdot2^n+1$ has a proper divisor among seven named primes.

It does **not** prove that $78557$ is the smallest Sierpiński number. That minimality question remains open. Five smaller odd candidates are traditionally outstanding:

$$
21181,\quad22699,\quad24737,\quad55459,\quad67607.
$$

To exclude one, it would be enough to find an exponent $n$ for which $k2^n+1$ is prime and establish that primality. Until each smaller candidate is excluded—or one is shown to have universal compositeness—the word “smallest” remains beyond the theorem.

That boundary is part of the beauty of the story. A seven-row table defeats an infinity of exponents for one carefully structured number. Yet nearby integers can resist years of computation and theory. Number theory alternates between these two moods: rigid periodic order and stubborn uncertainty.

For $78557$, the order is complete. Every exponent enters one of seven gates. Behind each gate waits a small prime. And no matter how high the tower $2^n$ rises, it never escapes the net.
