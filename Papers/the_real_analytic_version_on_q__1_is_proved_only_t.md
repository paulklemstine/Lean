# Symmetry, Temperature, and the Number at the Hot Point

*A guided tour of transitivity partition functions — what happens to a
symmetry-counting generating function where it blows up, and why the answer
involves a grade that does not exist.*

---

## 1. The set-up in one picture

Take a group $G$ acting on a finite set $Y$. The action is **$r$-transitive**
if $G$ can carry any ordered list of $r$ distinct points of $Y$ to any other
such list. Instead of asking yes/no, count:

$$t_r(Y) \;=\; \#\{\text{orbits of } G \text{ on injective } r\text{-tuples in } Y\},$$

so $t_r(Y) = 1$ means "$r$-transitive" and larger values measure the failure.

Now let the set grow: a **graded family** $Y_0, Y_1, Y_2,\dots$ all carrying
actions of the same $G$. Weight grade $n$ by $q^n$ and add everything up:

$$Z_r(q) \;=\; \sum_{n\ge0} t_r(Y_n)\,q^n .$$

If you read $q = e^{-\beta}$, this is a partition function: $q$ near $0$ is
cold (only the low grades matter) and $q \to 1$ is infinitely hot. The whole
story below is about what happens at that hot point.

<details>
<summary><b>Refresher: multiply transitive groups, and why they are rare</b></summary>

$1$-transitivity is ordinary transitivity. $2$-transitivity already forces
strong structure; $4$- and $5$-transitive finite permutation groups other than
the symmetric and alternating groups are exactly the
[Mathieu groups](https://en.wikipedia.org/wiki/Mathieu_group), a fact that sits
at the heart of the classification of finite simple groups. Counting orbits on
$r$-tuples, rather than testing transitivity, gives a quantitative version of
this hierarchy that varies continuously with the family.
</details>

---

## 2. First surprise: the universal residue

Suppose the family is eventually $r$-transitive: $t_r(Y_n) = 1$ for all
$n \ge N$, with the first $N$ grades arbitrary. Split head from tail; the tail
is geometric:

$$Z_r(q) \;=\; \sum_{n<N} a_n q^n + \frac{q^N}{1-q}
\;=\; \underbrace{\Bigl(\sum_{n<N}a_nq^n - \sum_{k<N}q^k\Bigr)}_{\text{polynomial}} - \frac{1}{q-1}.$$

So $Z_r$ extends to an analytic function on the plane minus the single point
$q = 1$, and at that point it has a **simple pole with residue $-1$** — no
matter what the group, the sets, the arity $r$, or the finitely many bad grades
were. Everything specific lives in the polynomial part; the singularity is
universal.

Play with this in the explorer: set the grade count to the constant polynomial
`1` and watch the single bright pole at $q = 1$; the hue turns exactly once
around it, the signature of a simple pole.

{{interactive_demo:0}}

---

## 3. When symmetry decays: $-P(-1)$

Most families are not perfectly transitive. The typical behaviour is
*polynomial*: $t_r(Y_n) = P(n)$ for $n$ large, $\deg P = d$. Then two things
happen at once at $q=1$:

- the pole order becomes $d+1$ (faster growth, worse blow-up);
- the residue becomes $-P(-1)$.

That is the counting polynomial evaluated at the grade $-1$, which does not
exist. It is the same **zeta-regularisation** phenomenon that assigns
$-\tfrac1{12}$ to $1+2+3+\cdots$, except that here it is the exact value of a
convergent contour integral.

Try `5,-3,2` (that is $P(n)=2n^2-3n+5$) in the explorer above: pole order $3$,
residue $-10 = -P(-1)$, and the hue now winds three times around the pole.

<details>
<summary><b>Click to reveal the proof</b></summary>

Two classical facts meet. Combinatorics: every polynomial expands in the
binomial basis,
$$P(x) = \sum_{k\le d} (\Delta^kP)(0)\binom{x}{k}, \qquad \Delta P(x) = P(x+1)-P(x).$$
Analysis: $\sum_{n\ge0}\binom nk q^n = q^k/(1-q)^{k+1}$, whose residue at
$q=1$ is the pure sign $(-1)^{k+1}$ (substitute $u=q-1$ and read the
coefficient of $u^k$ in $(1+u)^k$). Adding the contributions gives
$-\sum_k(-1)^k(\Delta^kP)(0)$, and since $\binom{-1}{k}=(-1)^k$ this is exactly
$-P(-1)$. The alternating signs of complex analysis and of finite differences
are the same signs.
</details>

**Two extremes.** Maximal symmetry, $P=1$, gives residue $-1$. No symmetry at
all — the trivial group acting on $n$ points — gives
$t_r(Y_n) = n(n-1)\cdots(n-r+1)$ and hence

$$\operatorname{Res}_{q=1} Z_r = (-1)^{r+1}\,r!, \qquad \text{pole order } r+1 .$$

The factorial appears out of a contour integral.

---

## 4. Analysis as a measuring instrument

Because the extremes differ, the analysis becomes a *detector*. For any family
with eventually polynomial orbit counts:

> the pole at $q=1$ is simple **and** the residue is $-1$
> $\iff$ the family is eventually $r$-transitive.

Neither half suffices: a simple pole only says the counts settle to a constant
$c$, and then the residue is $-c$. Set the explorer to the constant `2` and the
verdict flips, with residue $-2$ at the same pole order.

Here is that pipeline run on genuine group actions: rotations, reflections, the
affine group of a prime field, and the trivial group, with orbits counted by
brute force, the counting polynomial recovered from finite differences, and the
residue confirmed by numerical contour integration.

{{demo:1}}

Notice what happens for the dihedral group at $r=2$: the orbit counts are
$\lfloor n/2\rfloor$, which is *not* a polynomial. That is the cue for the next
section.

---

## 5. Rhythm: a singularity at every root of unity

Suppose the counts alternate, eventually $c_0$ at even grades and $c_1$ at odd
grades. Then

$$Z(q) = \frac{c_0+c_1q}{1-q^2},$$

with **two** poles:

$$\operatorname{Res}_{q=1} = -\frac{c_0+c_1}{2}
\quad\text{(minus the mean)},\qquad
\operatorname{Res}_{q=-1} = \frac{c_0-c_1}{2}
\quad\text{(half the amplitude)}.$$

The second singularity vanishes exactly when the rhythm does. More generally,
if the counts are eventually periodic mod $m$, discrete Fourier inversion turns
them into a sum of geometric progressions and the partition function into a sum
of simple poles: **one at every $m$-th root of unity**, with residue
$-\hat A_k/\zeta^k$ at $\zeta^{-k}$, where $\hat A_k$ is the $k$-th Fourier
coefficient of one period.

Switch the explorer to *periodic* and enter `3,1,4,1,5`: five poles appear on
the unit circle, and each residue is a Fourier coefficient in disguise.

{{visualization:0}}

The residue list — the **residue spectrum** — is a complete fingerprint: two
eventually periodic families have the same residues at all $m$-th roots of
unity precisely when their grade counts eventually agree. Nothing is lost.

{{visualization:1}}

---

## 6. Growth times rhythm: the general law

The general shape of a combinatorial count with a modular constraint is
*quasi-polynomial*, $a_n = P_{n \bmod m}(n)$. Then the partition function
continues off the $m$-th roots of unity and

$$\operatorname{Res}_{q=\zeta^{-k}} \;=\; -\frac{1}{m\,\zeta^{k}}\sum_{j<m}\zeta^{-kj}\,P_j(-1).$$

Everything is visible at once: the regularised values $P_j(-1)$ at a
nonexistent grade, the Fourier weights that read the rhythm, and the twist
$\zeta^{-k}$ recording which root of unity you stand at.

<details>
<summary><b>Click to reveal the two-line mechanism</b></summary>

Step 1 (twist): $\sum_n P(n)w^nq^n = Z_P(wq)$, so a single twisted family has a
pole at $q=w^{-1}$ with residue $-P(-1)/w$ — just the change of variables
$z=wq$ inside the contour integral.

Step 2 (Fourier): a quasi-polynomial count is a sum of $m$ twisted polynomial
counts, with twists $\zeta^k$ and coefficient polynomials the *section
polynomials* $S_k = \frac1m\sum_j\zeta^{-kj}P_j$. Apply step 1 to each.
</details>

The algorithm that turns raw grade counts into this residue spectrum:

{{algorithm:1}}

Try the *quasi-polynomial* mode of the explorer with `1,1 ; 2` — that is
$P_0(n) = n+1$ on even grades and $P_1 = 2$ on odd grades — and compare the
residue at each square root of unity with the formula.

---

## 7. Why a negative grade? Reciprocity

The formula $-P(-1)$ still feels like a coincidence of signs. It is not. The
closed form is a rational function, so it can be evaluated at $1/q$, and

$$Z(1/q) \;=\; -\sum_{n\ge1}P(-n)\,q^{n}, \qquad 0<|q|<1 .$$

Inverting the temperature reflects the family through the origin, and the
coefficient of $q^1$ on the right is $-P(-1)$: **the residue is the first
reflected grade.** Equivalently $Z(1/q) = -q\,Z^{\vee}(q)$ for the reflected
polynomial $P^{\vee}(x)=P(-x-1)$, and reflecting twice gives $P$ back.

{{interactive_demo:1}}

<details>
<summary><b>Where this sits in mathematics</b></summary>

This is the same shape as
[Ehrhart reciprocity](https://en.wikipedia.org/wiki/Ehrhart_polynomial): the
lattice-point counting polynomial of a rational polytope, evaluated at negative
integers, counts interior points. In both cases an "impossible" evaluation is
the honest content of an inversion symmetry. The combinatorial engine here is
$\binom{-n-1}{k} = (-1)^k\binom{n+k}{k}$, which converts
$\sum_n\binom nk q^n = q^k(1-q)^{-(k+1)}$ into its mirror
$\sum_n\binom{n+k}{k}q^n = (1-q)^{-(k+1)}$ — the two differ by the factor $q^k$,
and that factor is exactly what $q\mapsto 1/q$ undoes.
</details>

---

## 8. Reading the whole singularity

The residue is only the top coefficient. For a polynomial grade count the
coefficient of $(q-1)^{-(j+1)}$ is the finite-difference functional

$$m_j(P) \;=\; \sum_{k\le\deg P}(-1)^{k+1}\binom kj (\Delta^kP)(0),$$

which equals $-P(-1)$ at $j=0$, vanishes for $j>\deg P$ (so the principal part
terminates, confirming the pole order), and has nonzero top coefficient
$(-1)^{\deg P+1}(\Delta^{\deg P}P)(0)$. For $P(x)=2x^2-3x+5$ the principal part
at $q=1$ is

$$\frac{-10}{q-1}+\frac{-9}{(q-1)^2}+\frac{-4}{(q-1)^3}.$$

All of these numbers are **tail-only invariants**: change finitely many grades
however you like and not one of them moves.

{{algorithm:0}}

And here is the independent numerical check, contour integral by contour
integral:

{{algorithm:2}}

---

## 9. Everything at once

The complete verification suite: universal residue, zeta-regularised residue,
Laurent moments, the trivial-action factorial, the detector, the second
singularity of a two-periodic count, the quasi-polynomial spectrum, and
reciprocity — each closed form checked against a numerically evaluated contour
integral.

{{demo:0}}

---

## 10. The dictionary

| symmetry side | analytic side |
|---|---|
| eventually $r$-transitive | simple pole at $q=1$, residue $-1$ |
| eventually $c$ orbits | simple pole at $q=1$, residue $-c$ |
| counts $\sim$ polynomial of degree $d$ | pole of order $d+1$, residue $-P(-1)$ |
| trivial action on $n$ points | pole of order $r+1$, residue $(-1)^{r+1}r!$ |
| rhythm of period $m$ | one pole per $m$-th root of unity; residues $=$ Fourier transform |
| growth times rhythm | residue $-\frac{1}{m\zeta^k}\sum_j\zeta^{-kj}P_j(-1)$ |
| finitely many exceptional grades | nothing changes |

Qualitative questions about group actions have become numbers you can compute
by integrating around a circle — stable, additive, and complete.
