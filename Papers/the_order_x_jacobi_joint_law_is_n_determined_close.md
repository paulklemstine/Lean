# The Order × Jacobi Joint Law — a Guided Tour

*How an exact, beautiful law about squares and cycle lengths turns out to be
exactly as useless for factoring as it is elegant.*

---

## 0. Where we are going

Take two odd primes $p \neq q$, form $N = pq$, and look at the units modulo $N$
— the numbers coprime to $N$. Every unit carries two classical measurements:

- its **multiplicative order** $\operatorname{ord}_N(b)$, the least $k \ge 1$
  with $b^k \equiv 1 \pmod N$ — the length of the cycle $b$ traces out;
- its **Jacobi symbol** $J(b\mid N) = \left(\frac{b}{p}\right)\left(\frac{b}{q}\right)$,
  a single $\pm 1$ bit.

They are wildly different in cost. The Jacobi symbol is computable in
$O(\log^2 N)$ time by reciprocity, *without knowing $p$ and $q$*. The order is,
for general composite $N$, believed to be as hard as factoring.

By the end of this page you will know four things:

1. at a single prime, "is a square" and "has short order" are **the same
   property**;
2. the lift of that fact to $N = pq$ is exact **iff** a single power of $2$
   matches — a dial you can turn and watch;
3. on the bottom rung of the dial the quadrants are **exactly** equal quarters
   and the Jacobi symbol is **blind** to the order class;
4. the whole joint statistic **collides** on coprime moduli, which kills every
   attack of this shape at once.

Play first, read later — the widget below is the whole story in one screen.

{{interactive_demo:0}}

> **Try this now.** Press *jump to a Blum pair* a few times: every ring sits on
> a blue point and every blue point is ringed. Then press *jump to an
> unbalanced pair*: rings start appearing on orange and green points. That
> visual difference is the entire content of the dichotomy theorem.

---

## 1. The coupling at a prime

<details>
<summary><strong>Background: quadratic residues in sixty seconds</strong> (click to expand)</summary>

A unit $b$ modulo an odd prime $p$ is a **quadratic residue** if $b \equiv x^2$
for some $x$. Exactly half the units are residues. The
[Legendre symbol](https://en.wikipedia.org/wiki/Legendre_symbol)
$\left(\frac{b}{p}\right)$ records which: $+1$ for a residue, $-1$ for a
non-residue.

The group $(\mathbb{Z}/p\mathbb{Z})^\times$ is **cyclic**: there is a generator
$g$ such that every unit is $g^k$ for a unique $k \in \{0, \dots, p-2\}$. The
squares are exactly the even powers of $g$. See
[primitive root modulo n](https://en.wikipedia.org/wiki/Primitive_root_modulo_n).

</details>

Write $H_p = (p-1)/2$. The **half group** is
$\mathcal{H}_p = \{u : \operatorname{ord}_p(u) \mid H_p\}$: the units whose
cycle closes in at most half the maximum time.

> **Theorem (Exact coupling).** For an odd prime $p$ and a unit $u$,
> $$u \text{ is a quadratic residue} \iff \operatorname{ord}_p(u) \mid H_p.$$

<details>
<summary>Click to reveal the proof</summary>

Both sides describe the unique index-$2$ subgroup of a cyclic group.
$\operatorname{ord}_p(u) \mid H_p$ means $u^{(p-1)/2} = 1$, which by
[Euler's criterion](https://en.wikipedia.org/wiki/Euler%27s_criterion) holds
exactly when $u$ is a square.

Concretely, with $u = g^k$: $u$ is a square iff $k$ is even, and
$(g^k)^{(p-1)/2} = 1$ iff $(p-1) \mid k(p-1)/2$ iff $k$ is even. $\blacksquare$

</details>

This is worth pausing on. It is not a bias or a tendency. It is an equivalence
with no exceptions, at every odd prime. **Squares are the short cycles.**

{{algorithm:0}}

---

## 2. Lifting to $N = pq$ — and the crack

By the Chinese Remainder Theorem a unit modulo $N$ is a pair (unit mod $p$,
unit mod $q$), and the order of a pair is the least common multiple of the two
component orders:
$$\operatorname{ord}_N(b) = \operatorname{lcm}\big(\operatorname{ord}_p(b), \operatorname{ord}_q(b)\big).$$

Set $L = \operatorname{lcm}(H_p, H_q)$. One direction is immediate: if $b$ is a
square at both primes then $\operatorname{ord}_p(b) \mid H_p \mid L$ and
$\operatorname{ord}_q(b) \mid H_q \mid L$, so $\operatorname{ord}_N(b) \mid L$.

The converse is **false**, and the counterexample is tiny. Take $b = -1$, of
order $2$. If $q \equiv 1 \pmod 4$ then $H_q$ is even, so $2 \mid L$ and $-1$
passes the order test — but if $p \equiv 3 \pmod 4$ then $-1$ is a non-residue
modulo $p$. Try $N = 39 = 3 \cdot 13$ in the widget above: $L = 6$, and the
unit $38 \equiv -1$ is ringed while sitting in the wrong colour.

Why? Because $L$ is a least common multiple, and lcm's are greedy about prime
powers. If one half-order carries more factors of $2$ than the other, the
surplus lets short-order elements sneak through at the other prime.

---

## 3. The dial

Write $v_2(m)$ for the exponent of $2$ in $m$.

> **Theorem (The dichotomy).** For $N = pq$ with $p \ne q$ odd primes, the
> equivalence
> $$\operatorname{ord}_N(b) \mid L \iff b \text{ is a square mod } p \text{ and mod } q$$
> holds for **every** unit $b$ **if and only if** $v_2(H_p) = v_2(H_q)$.

<details>
<summary>Click to reveal both halves of the proof</summary>

**Sufficiency.** The engine is a lattice fact: if $a \mid 2x$,
$a \mid \operatorname{lcm}(x,y)$ and $v_2(y) \le v_2(x)$, then $a \mid x$.
Indeed it suffices that $\gcd(2x, \operatorname{lcm}(x,y)) \mid x$, and
comparing $\ell$-adic valuations: for odd $\ell$,
$\min(v_\ell(x), \max(v_\ell(x), v_\ell(y))) = v_\ell(x)$; for $\ell = 2$,
$\min(1 + v_2(x), \max(v_2(x), v_2(y))) = v_2(x)$ using $v_2(y) \le v_2(x)$.

Apply it with $a = \operatorname{ord}_p(b)$, $x = H_p$, $y = H_q$: a component
order always divides $p - 1 = 2H_p$, and if it also divides $L$, balance forces
it into $H_p$ — so $b$ is a residue at $p$. Symmetrically at $q$.

**Necessity.** Suppose $v_2(H_p) < v_2(H_q)$, say $v_2(H_p) = s$. The cyclic
group $(\mathbb{Z}/p)^\times$ contains an element $x$ of order exactly
$2^{s+1}$; since $2^{s+1} \mid H_q$, its order divides $L$, but $2^{s+1} \nmid H_p$,
so $x$ is a non-residue. Pair $x$ with $1$ at $q$ via the CRT and you have a
unit that passes the order test and fails residuosity. $\blacksquare$

</details>

Since $H_p$ is odd exactly when $p \equiv 3 \pmod 4$, the **bottom rung** of the
dial is
$$p \equiv q \equiv 3 \pmod 4 \iff v_2(H_p) = v_2(H_q) = 0,$$
the [Blum integers](https://en.wikipedia.org/wiki/Blum_integer) familiar from
Rabin encryption and the Blum–Blum–Shub generator. There the lift is exact for
free.

{{algorithm:1}}

---

## 4. Four equal quarters, and a symbol that cannot see

On the bottom rung the geometry is as clean as it gets. The pair of Legendre
symbols cuts the units into four classes, each of size exactly
$H_pH_q = \varphi(N)/4$; and the order class $\{b : \operatorname{ord}_N(b) \mid L\}$
is precisely the both-residue quadrant. Perfect equidistribution, no residual
signal in the counts.

Now the crucial merger. The Jacobi symbol is the *product* of the two Legendre
symbols, so $J = +1$ lumps the $(+,+)$ quadrant together with the $(-,-)$
quadrant — and that destroys exactly the information the order test uses.

> **Theorem (Blindness).** For $p \equiv q \equiv 3 \pmod 4$, the units $1$ and
> $-1$ both have Jacobi symbol $+1$; yet $\operatorname{ord}(1) = 1$ divides
> $L$ while $\operatorname{ord}(-1) = 2$ does not, because $L$ is odd.

Two units indistinguishable to the free measurement, on opposite sides of the
expensive one. Go back to the widget and read the census table on a Blum pair:
the $(+1,+1)$ row is fully ringed, the $(-1,-1)$ row not at all, and both rows
have Jacobi symbol $+1$.

{{visualization:0}}

---

## 5. The bias is real — and says nothing

So is there *anything* to see? Yes. Compare the average order in the two Jacobi
classes:
$$\frac{\mathbb{E}[\operatorname{ord}_N \mid J = +1]}{\mathbb{E}[\operatorname{ord}_N \mid J = -1]}.$$
It sits reliably below $1$ — around $0.68$ to $1.01$ in large-scale sampling,
and empirically exactly $3/4$ whenever $p \equiv q \equiv 3 \pmod 4$. The
mechanism is Corollary-level: the $+1$ class contains the whole both-residue
quadrant, all of whose members are confined to the half groups, so the $+1$
class is diluted with short cycles.

The question is only whether the tilt tracks $p$ and $q$ *individually*. Test
it honestly: correlate the ratio against $p$, $q$, $p+q$, $|p-q|$, and compare
each observed correlation against a permutation null obtained by reshuffling
the labels thousands of times.

{{algorithm:3}}

Every observed value lands inside its null band. The only structure that
survives is the residue dial — a function of $N \bmod 4$, which you knew the
moment $N$ was published.

---

## 6. The theorem that closes the case

Empirical non-correlation is suggestive, not conclusive. Maybe a cleverer
functional would crack it. To rule that out, work with the **joint law**: the
complete multiset
$$\mathcal{L}(N) = \big\{\!\!\big\{\,(\operatorname{ord}_N(b), J(b\mid N)) : b \text{ a unit mod } N \,\big\}\!\!\big\}.$$
Every conditional mean, variance, quantile and entropy of "order given symbol"
is a function of $\mathcal{L}(N)$. So a barrier at this level is a barrier for
the entire family.

> **Theorem (Collision).** $\mathcal{L}(35) = \mathcal{L}(39)$.

Both moduli have $24$ units, and their joint laws agree pair for pair,
multiplicity for multiplicity. And $\gcd(35,39) = 1$.

> **Theorem (Barrier).** No function $F$ of the joint law returns a nontrivial
> divisor of $N$ for both $N = 35$ and $N = 39$.

<details>
<summary>Click to reveal the (three-line) proof</summary>

Suppose such an $F$ exists. Since $\mathcal{L}(35) = \mathcal{L}(39)$, it
returns the same integer $d$ on both inputs. By assumption $d > 1$, $d \mid 35$
and $d \mid 39$, so $d \mid \gcd(35,39) = 1$, hence $d = 1$ — contradiction.
$\blacksquare$

</details>

No hypothesis, no asymptotics, no bound on the power of $F$; it may be
arbitrary, even non-computable. Press the collision button in the widget above
to watch the two columns match row by row.

{{algorithm:2}}

---

## 7. Why collisions are not accidents

> **Theorem (Transport).** If some isomorphism of unit groups
> $(\mathbb{Z}/N_1)^\times \cong (\mathbb{Z}/N_2)^\times$ preserves the Jacobi
> symbol, then $\mathcal{L}(N_1) = \mathcal{L}(N_2)$.

The proof is one observation: a group isomorphism preserves element orders, and
the hypothesis handles the symbol. So the joint law is not an invariant of $N$
at all — it is an invariant of the pair

$$\big(\text{abelian group } \mathbb{Z}_{p-1} \times \mathbb{Z}_{q-1},\; \text{quadratic character}\big),$$

an object with far fewer degrees of freedom than the factorisation. Semiprimes
are plentiful; isomorphism classes of (group, character) pairs are not.
Collisions are pigeonhole, not luck.

Our example is exactly of this type:
$(\mathbb{Z}/35)^\times \cong \mathbb{Z}_4 \times \mathbb{Z}_6$ and
$(\mathbb{Z}/39)^\times \cong \mathbb{Z}_2 \times \mathbb{Z}_{12}$ are the same
group of order $24$ in different clothing.

And the crowding starts immediately:

{{demo:1}}

Among the $73$ semiprimes below $400$ there are only $62$ distinct joint laws,
and ten of them are shared by coprime moduli — including the triple
$\{143, 155, 183\}$, whose unit groups
$\mathbb{Z}_{10}\times\mathbb{Z}_{12}$, $\mathbb{Z}_{4}\times\mathbb{Z}_{30}$
and $\mathbb{Z}_{2}\times\mathbb{Z}_{60}$ are all the same group of order $120$.
Each shared law is an independent instance of the barrier.

---

## 8. Run everything yourself

The full numerical verification — coupling at fourteen primes, the dichotomy
table, the quadrant census, the blindness pair, the $35$/$39$ collision, the
conditional bias over twenty semiprimes, and the permutation tests — is one
script:

{{demo:0}}

---

## 9. Three obstructions, and what remains

Put the reasons side by side.

1. **It is a residue dial.** All the structure collapses to
   $v_2(H_p) \overset{?}{=} v_2(H_q)$, whose bottom rung is visible in
   $N \bmod 4$.
2. **It is circular.** Computing the law needs component orders, which needs
   the factors. To evaluate the statistic that would reveal $p$ and $q$, you
   must already know $p$ and $q$.
3. **It collides.** The law is an invariant of (unit group, quadratic
   character), and coprime moduli share it.

Each alone is discouraging; together they close the case. What is left is a
small, sharp piece of theory that stands on its own: Euler's criterion is
really a statement about cycle lengths; its failure to lift to composites is
governed by a single power of $2$; the Blum integers are exactly the moduli
where it lifts for free; and the joint law is a genuine invariant of a category
of pairs (group, character), whose fibres are a well-posed question in
[multiplicative number theory](https://en.wikipedia.org/wiki/Multiplicative_number_theory).

Open problems worth the effort:

- **Collision density.** Does almost every semiprime have a joint-law twin?
  The transport theorem reduces this to counting isomorphism classes of
  (group, character) pairs — an Erdős–Pomerance-style question about fibres of
  Euler's totient.
- **Universality of the dial.** Replace the quadratic character by one of order
  $\ell$; does the same dichotomy hold with $v_2$ replaced by $v_\ell$? The
  lattice lemma is character-agnostic, so this should generalise.
- **The exact $3/4$.** Prove (or refute) that the conditional bias ratio is
  exactly $3/4$ for every $N = pq$ with $p \equiv q \equiv 3 \pmod 4$.

The clock modulo $N$ knows a great deal. It simply does not know how to say
$p$.
