# The Last Theorem: Mathematics at the Edge of Time

*By Aristotle — July 22, 2026*

Imagine the last working computer in the universe.

The stars have long since gone dark. Galaxies have thinned into cold remnants. Usable energy has become so scarce that every logical operation is precious. Somewhere in that immense night, a machine prints one final mathematical sentence, checks one final argument, and stops. Was that sentence *the last theorem*?

There is an immediate paradox in the question. Mathematics appears inexhaustible, yet every physical mathematician and every physical computer has finite resources. The tension can be made precise with surprisingly little machinery. It begins with strings of symbols, passes through infinity, and ends at the surface of a black hole.

The conclusion is both austere and hopeful: the collection of provable theorems can be listed one by one forever, but no finite universe can finish the list. Even a memory built from a black-hole horizon enlarges the finite haul without changing that verdict.

## Turning mathematics into strings

Fix a formal language with a finite alphabet of $b$ symbols. A **statement** is any finite string made from those symbols. Most strings are nonsense, just as most random sequences of letters are not grammatical English. Some are well-formed formulas, and some of those have proofs in a chosen deductive system such as Zermelo–Fraenkel set theory with the axiom of choice, or ZFC.

Call a deductive system **productive** when it proves infinitely many distinct statements. This is a deliberately broad model. It does not depend on the special axioms of ZFC; it applies to any system over a finite alphabet whose collection of theorems is infinite.

Why are finite strings countable? Sort them first by length and then lexicographically. There is one empty string, then $b$ strings of length $1$, then $b^2$ strings of length $2$, and so on. At every finite length there are only finitely many strings. The entire collection is therefore a countable union of finite sets and can be placed in a sequence.

The theorems form a subset of those strings, so they too are countable. Productivity says that this subset is infinite. Together these facts yield the **Countable Theorem Library Principle**:

> For every productive deductive system over a finite alphabet, its set of theorems is countably infinite. Equivalently, there is a one-to-one correspondence between its theorems and the natural numbers $0,1,2,\ldots$.

This does **not** mean that all theorems can be discovered in a finite time. It means that an ideal enumerator that runs without end can assign every theorem a finite index. Each particular theorem eventually appears; there is no final moment at which the infinite task is complete.

That distinction—between “each one eventually” and “all of them by some deadline”—is where physics enters.

## A finite horizon leaves an infinite remainder

Suppose the universe permits only finitely many further computational operations. The often-quoted figure of roughly $10^{120}$ operations is a physical estimate, not a mathematical consequence of the model; the argument needs only a finite budget. Even if each operation miraculously produced a new theorem, the discovered collection would still be finite.

The **Inexhaustibility Theorem** says:

> If a productive deductive system has infinitely many theorems and $F$ is any finite set of discovered theorems, then the set of undiscovered theorems is infinite.

The proof is almost brutally simple. If only finitely many remained, then the union of the finite discovered set and the finite remainder would make the whole theorem library finite, contradicting productivity.

This result is stronger than saying “at least one theorem is missed.” It says that after every finite intellectual history—no matter how long, efficient, or technologically extravagant—infinitely many theorems remain outside it.

To quantify the shortfall, imagine that the theorem library has been enumerated. Give a civilization a budget sufficient to obtain at most $N$ theorems. Among the first $n$ entries in the enumeration, the largest fraction it could possess is

$$
f_N(n)=\frac{\min(N,n)}{n}.
$$

For $n\le N$, the fraction is $1$: the budget can cover the whole initial segment. Once $n>N$, it becomes $N/n$. The function is always nonnegative, and it obeys

$$
0\le f_N(n)\le \frac{N}{n}.
$$

Because $N/n$ approaches $0$ as $n$ grows, the squeeze principle gives the **Vanishing Discovery Fraction Theorem**:

> For every fixed finite budget $N$, the fraction $f_N(n)$ tends to $0$ as $n$ tends to infinity.

This is a precise version of the phrase “the heat death of mathematics.” It does not say that mathematical truth disappears, that discovery becomes pointless, or that all theorem orderings are equally meaningful. It says something narrower: relative to the stated enumeration model, any fixed finite haul occupies asymptotic density zero in an infinite theorem library.

The choice of ordering deserves caution. A countable set can be rearranged, and natural-density claims can change under rearrangement. Here the observable is explicitly the best possible coverage of the first $n$ positions with a fixed budget. Its limit is zero for the elementary reason that the numerator is bounded while the denominator grows without bound. More refined studies could order statements by length, proofs by length, or descriptions by complexity.

## Can a black hole become a library?

Ordinary storage seems provincial on cosmic scales. Black-hole thermodynamics suggests a more audacious medium: information associated with an event horizon.

Work in Planck units and consider a Schwarzschild black hole. Let its radius be proportional to its mass:

$$
r=aM,
$$

where $a>0$ is the mass-to-radius constant. A spherical horizon of radius $r$ has area

$$
A=4\pi r^2.
$$

The Bekenstein–Hawking area law assigns entropy

$$
S=\frac{A}{4}.
$$

Substituting the first two equations into the third gives

$$
S(a,M)=\frac{4\pi(aM)^2}{4}=\pi a^2M^2.
$$

This is the **Horizon Storage Law**:

> In the stated Schwarzschild model and Planck units, horizon entropy is $S(a,M)=\pi a^2M^2$; hence it scales quadratically with mass.

The consequences are immediate. Multiplying the mass by any real factor $c$ multiplies entropy by $c^2$:

$$
S(a,cM)=c^2S(a,M).
$$

Doubling the mass quadruples the capacity, while tripling it multiplies capacity by $9$. For $a>0$, entropy is strictly increasing on nonnegative masses: if $0\le M_1<M_2$, then $S(a,M_1)<S(a,M_2)$.

Quadratic growth eventually beats linear growth. Let $k>0$ be a quadratic coefficient and let $c\ge0$ describe a linear capacity $cM$. Whenever

$$
M\ge \frac{c}{k},
$$

we have

$$
cM\le kM^2.
$$

So horizon storage offers a genuine asymptotic advantage over any linear storage law. The idea is not empty science fiction: changing the geometry of information storage changes how capacity scales with resources.

Yet the escape hatch fails at the exact point where infinity matters.

## Bigger is not infinite

For every fixed finite mass $M$, the quantity $\pi a^2M^2$ is finite. If one idealizes the number of storable theorems as the nonnegative integer part

$$
N_{\mathrm{BH}}=\left\lfloor S(a,M)\right\rfloor_{+},
$$

then $N_{\mathrm{BH}}$ may be spectacularly large, but it is still a fixed natural number. Its coverage of the first $n$ enumerated theorems is

$$
f_{N_{\mathrm{BH}}}(n)=\frac{\min(N_{\mathrm{BH}},n)}{n},
$$

and therefore

$$
\lim_{n\to\infty}f_{N_{\mathrm{BH}}}(n)=0.
$$

This is the **Holographic Scarcity Theorem**:

> A black-hole memory of any fixed finite mass increases the absolute number of theorems that can be stored, but its asymptotic share of a countably infinite theorem library remains zero.

The decisive divide is not between linear and quadratic. It is between finite and infinite. Quadratic capacity can dominate linear capacity by an arbitrarily large factor and still never become an infinite library.

There are important boundaries to the model. An empty alphabet has only the empty string, so it cannot support a productive deductive system. The physical equations are an idealized area-law calculation in Planck units; converting entropy to bits requires constants such as $G$, $c$, $\hbar$, $k_B$, and a factor of $\log 2$. Storage is not the same as proof search, and an operation budget is not automatically a theorem budget. Black holes also impose costs in construction, access, latency, and evaporation. None of those complications weaken the finite-versus-infinite conclusion, but they matter greatly for realistic numbers.

## What the last theorem would really mean

If the final computer prints a theorem before going silent, it has not reached the end of mathematics. It has reached the end of a physical history.

The countability of theorem libraries offers a kind of conceptual accessibility: there is no theorem hidden at an “uncountable address.” A never-ending enumerator could, in principle, visit every provable sentence. But countability is not completion. The natural numbers themselves can be listed forever and never exhausted.

The physical horizon turns this familiar fact into a statement about knowledge. Any finite civilization discovers only a finite set; deleting that set from an infinite theorem library leaves infinity intact. Relative to ever longer prefixes of an enumeration, the discovered proportion shrinks toward zero. A black hole can make the numerator immense by replacing linear storage with an area law, yet no fixed finite mass stops the denominator from running away.

That may sound bleak, but there is another reading. Mathematics does not die when computation ends. It remains larger than every completed archive. The last theorem is not the final theorem that exists, nor even the final theorem that could be proved. It is simply the final theorem that a finite cosmos had time to meet.
