# The Fractal Dimension of Mathematical Truth: Realizing the Rational Spectrum

## Abstract

We study the box-counting (fractal) dimension of *theories* over a space of
statements encoded as finite binary strings. A theory assigns to each length $n$
the finite set of accepted length-$n$ strings, and its fractal dimension is the
$\limsup$ of $\log_2$ of the accepted count, normalized by length. We prove that
this dimension always lies in $[0,1]$ and is monotone under inclusion of
theories. Our main contribution is a sharp construction: for every modulus
$m \ge 1$ and every set of admissible residues $R \subseteq \{0, \dots, m-1\}$,
the *periodic density theory* — which frees coordinate $i$ exactly when
$i \bmod m \in R$ — has fractal dimension exactly $|R|/m$, the asymptotic density
of its free coordinates. As an immediate consequence, **every rational number in
$[0,1]$ is realized as the fractal dimension of some theory of truth**. This
generalizes the isolated value $1/2$ found for one particular theory in earlier
work to the full rational unit interval. The engine of the proof is an exact
two-sided count of free coordinates: the counting law $\mathrm{count} =
2^{\mathrm{free}}$, the periodicity relation $\mathrm{free}(n+m) =
\mathrm{free}(n) + |R|$, and a squeeze of the normalized logarithm to the density.

**Keywords:** fractal dimension, box-counting dimension, Cantor space, density of
truth, binary encodings, periodic theories, rational spectrum.

---

## 1. Introduction

The space of mathematical statements, suitably encoded, is a metric-measure
object of its own. If each statement is a finite string of bits, then the set of
statements of length $n$ is a discrete cube with $2^n$ points, and any standard
of provability or truth selects a subset of these points at each length. A
natural quantitative question follows: **how densely** does an accepted set sit
inside the ambient space of all strings?

The right tool is fractal (box-counting) dimension, the same notion that assigns
dimension $\log 2 / \log 3$ to the middle-thirds Cantor set. Here it measures the
exponential growth rate of the accepted count as statement length increases.
Earlier work identified a specific "half-information" theory with fractal
dimension exactly $1/2$, showing that truth can be sparse (dimension $< 1$) yet
non-negligible (dimension $> 0$).

This paper deepens that result decisively. We show the value $1/2$ is not
distinguished: by tuning the density of information-bearing coordinates we realize
**every** rational dimension in $[0,1]$. The dimension spectrum of truth is the
whole rational unit interval. The proof rests on an exact combinatorial count,
not on any definitional artifact, and produces an explicit witness theory for
each target dimension.

### Contributions

1. A rigorous framework in which theories over binary-string statements carry a
   well-defined box-counting dimension (Section 2).
2. Universal bounds: every theory has dimension in $[0,1]$ (Theorem 3.1), and
   dimension is monotone under inclusion (Theorem 3.2).
3. The **periodic density theorem**: $\dim(D_{m,R}) = |R|/m$ (Theorem 4.4),
   proved via an exact counting law and a squeeze estimate.
4. **Rational realizability**: every rational in $[0,1]$ is a dimension of truth
   (Theorem 4.5).

---

## 2. Definitions

Throughout, statements of length $n$ are binary strings of length $n$ (functions
from $\{0, 1, \dots, n-1\}$ to $\{\mathrm{true}, \mathrm{false}\}$); there are
$2^n$ of them.

**Definition 2.1 (Theory).** A *theory* is a family $T$ that assigns to each
length $n \in \mathbb{N}$ a finite set $T(n)$ of accepted length-$n$ statements.

**Definition 2.2 (Count).** The *count* of a theory at length $n$ is
$$\mathrm{count}(T, n) = |T(n)| \in \mathbb{N}.$$

**Definition 2.3 (Finite-scale dimension estimate).** For $n \ge 1$,
$$\mathrm{dimEst}(T, n) = \frac{\log_2 \mathrm{count}(T, n)}{n},$$
with the convention $\log_2 0 = 0$ so that the estimate is defined even when the
theory accepts nothing at length $n$.

**Definition 2.4 (Box-counting / fractal dimension).**
$$\dim(T) = \limsup_{n \to \infty}\; \mathrm{dimEst}(T, n) = \limsup_{n\to\infty}
\frac{\log_2 \mathrm{count}(T, n)}{n}.$$

The $\limsup$ (rather than a plain limit) is essential: for irregular theories
the estimate can oscillate indefinitely, and the $\limsup$ records the coarsest
scale at which the accepted set is thick. For the regular theories of Section 4
the estimate converges, so $\limsup$ and $\lim$ coincide.

---

## 3. Universal bounds and monotonicity

**Lemma 3.0 (Trivial count bound).** For every theory $T$ and every $n$,
$$\mathrm{count}(T,n) \le 2^n.$$
*Proof.* $T(n)$ is a subset of the set of all $2^n$ length-$n$ strings, and the
cardinality of a subset is at most the cardinality of the whole. $\square$

Taking $\log_2$ of the bound (monotonicity of $\log_2$ on the positive reals,
with the $\log_2 0 = 0$ convention handling the empty case) gives
$\log_2 \mathrm{count}(T, n) \le n$, hence:

**Lemma 3.1 (Estimate range).** For $n \ge 1$,
$0 \le \mathrm{dimEst}(T, n) \le 1$.
*Proof.* Nonnegativity: $\mathrm{count}(T,n) \ge 0$ and, when positive,
$\mathrm{count}(T,n)\ge 1$, so $\log_2 \mathrm{count}(T,n) \ge 0$; dividing by
$n > 0$ preserves the sign. Upper bound: $\log_2 \mathrm{count}(T,n) \le n$
divided by $n$ gives $\le 1$. $\square$

**Theorem 3.2 (Dimension lies in the unit interval).** For every theory $T$,
$$0 \le \dim(T) \le 1.$$
*Proof.* The sequence $\mathrm{dimEst}(T, \cdot)$ is eventually bounded below by
$0$ and above by $1$ (Lemma 3.1). Since the $\limsup$ of a sequence eventually in
$[0,1]$ lies in $[0,1]$, the claim follows. (Formally one checks the estimate is
bounded and co-bounded under the eventual filter, so the $\limsup$ is a genuine
real number in the stated range.) $\square$

**Theorem 3.3 (Monotonicity).** If $T(n) \subseteq T'(n)$ for all $n$, then
$$\dim(T) \le \dim(T').$$
*Proof.* Inclusion of finite sets gives $\mathrm{count}(T,n) \le
\mathrm{count}(T',n)$ for all $n$. Since $\log_2$ is monotone on positive reals
(and the $\log_2 0 = 0$ convention keeps the inequality valid at the empty count,
where the left side is $0 \le$ the right), dividing by $n \ge 0$ yields
$\mathrm{dimEst}(T,n) \le \mathrm{dimEst}(T',n)$ for all $n$. The $\limsup$ is
monotone with respect to eventual pointwise domination, so $\dim(T) \le
\dim(T')$. $\square$

Theorem 3.3 confirms the intuition that admitting more truth cannot decrease the
fractal dimension.

---

## 4. Periodic density theories and the rational spectrum

We now construct, for each rational target, an explicit theory of that dimension.

**Definition 4.1 (Periodic density theory).** Fix a modulus $m \ge 1$ and a set
of admissible residues $R \subseteq \{0, 1, \dots, m-1\}$. The *periodic density
theory* $D_{m,R}$ accepts at length $n$ exactly those strings $s$ for which every
non-admissible coordinate is false; that is, coordinate $i$ is *free* (may be
true or false) when $i \bmod m \in R$ and is *forced* to false otherwise.
Equivalently,
$$D_{m,R}(n) = \prod_{i < n}
\begin{cases}
\{\mathrm{true},\mathrm{false}\}, & i \bmod m \in R,\\
\{\mathrm{false}\}, & i \bmod m \notin R,
\end{cases}$$
the set of strings obtained by choosing each free coordinate arbitrarily and
fixing each forced coordinate to false.

**Definition 4.2 (Free count).** The number of free (admissible) coordinates
below $n$ is
$$\mathrm{free}(m, R, n) = \big|\{\, i < n : i \bmod m \in R \,\}\big|.$$

**Lemma 4.3 (Exact counting law).** For all $m, R, n$,
$$\mathrm{count}(D_{m,R}, n) = 2^{\,\mathrm{free}(m,R,n)}.$$
*Proof.* The accepted set is a product over coordinates: each free coordinate
independently takes $2$ values and each forced coordinate takes exactly $1$. The
cardinality of a product of finite sets is the product of the cardinalities, so
$$\mathrm{count}(D_{m,R}, n) = \prod_{i<n} \big(\text{2 if } i\bmod m\in R
\text{ else } 1\big) = 2^{\,|\{i<n:\, i \bmod m \in R\}|} =
2^{\mathrm{free}(m,R,n)}. \qquad \square$$

**Periodicity of the free count.** Over any block of $m$ consecutive indices,
$\{0,1,\dots,m-1\}$ cycles through a complete residue system, so exactly $|R|$ of
them are admissible. Hence
$$\mathrm{free}(m,R,n+m) = \mathrm{free}(m,R,n) + |R|,$$
and by induction on the number of complete blocks,
$$|R|\cdot\Big\lfloor \tfrac{n}{m} \Big\rfloor \;\le\; \mathrm{free}(m,R,n)
\;\le\; |R|\cdot\Big\lfloor \tfrac{n}{m} \Big\rfloor + |R|. \tag{$\ast$}$$
The lower bound counts only the coordinates in the $\lfloor n/m\rfloor$ complete
blocks below $n$; the upper bound adds the at most $|R|$ admissible coordinates in
the final incomplete block.

**Theorem 4.4 (Dimension of a periodic density theory).** For every $m \ge 1$
and $R \subseteq \{0,\dots,m-1\}$,
$$\dim(D_{m,R}) = \frac{|R|}{m}.$$
*Proof.* By Lemma 4.3, $\log_2 \mathrm{count}(D_{m,R}, n) = \mathrm{free}(m,R,n)$,
so
$$\mathrm{dimEst}(D_{m,R}, n) = \frac{\mathrm{free}(m,R,n)}{n}.$$
Divide the sandwich $(\ast)$ by $n$. Using
$\big\lfloor n/m \big\rfloor = n/m - \{n/m\}$ with fractional part in $[0,1)$,
both the lower bound $\frac{|R|}{m}\cdot\frac{m\lfloor n/m\rfloor}{n}$ and the
upper bound $\frac{|R|}{m}\cdot\frac{m\lfloor n/m\rfloor}{n} + \frac{|R|}{n}$
converge to $|R|/m$ as $n \to \infty$: the first because
$m\lfloor n/m\rfloor / n \to 1$, the second because additionally $|R|/n \to 0$.
By the squeeze theorem the sequence $\mathrm{dimEst}(D_{m,R},n)$ converges to
$|R|/m$. A convergent sequence has $\limsup$ equal to its limit, so
$\dim(D_{m,R}) = |R|/m$. $\square$

Notably, the proof depends only on $|R|$, never on *which* residues are
admissible. This robustness is exactly what makes the full rational interval
attainable.

**Theorem 4.5 (Rational realizability).** For every rational $q \in [0,1]$ there
is a theory $T$ with $\dim(T) = q$.
*Proof.* Write $q = p/m$ in lowest terms with $0 \le p \le m$ and $m \ge 1$.
Choose any $R \subseteq \{0, \dots, m-1\}$ with $|R| = p$ (possible since
$0 \le p \le m$), for instance $R = \{0, 1, \dots, p-1\}$. By Theorem 4.4,
$\dim(D_{m,R}) = |R|/m = p/m = q$. $\square$

**Corollary 4.6 (The dimension spectrum contains $\mathbb{Q}\cap[0,1]$).** The
set $\{\dim(T) : T \text{ a theory}\}$ contains every rational in $[0,1]$. In
particular it is dense in $[0,1]$, and the value $1/2$ of the base development is
one point of a full rational spectrum, realized by $m = 2$, $R = \{0\}$.

---

## 5. Algorithms

The results are effective: every quantity above is computable, and the
convergence in Theorem 4.4 can be watched numerically.

### 5.1 Free-coordinate counting

Given $m$, $R$, $n$, compute $\mathrm{free}(m,R,n)$ by iterating $i$ from $0$ to
$n-1$ and incrementing a counter whenever $i \bmod m \in R$. This runs in $O(n)$
time and $O(1)$ extra space, or in $O(1)$ time via the closed form
$|R|\lfloor n/m\rfloor + |\{r \in R : r < n \bmod m\}|$.

### 5.2 Dimension estimate and convergence

For a target length $N$, tabulate $\mathrm{dimEst}(D_{m,R}, n) =
\mathrm{free}(m,R,n)/n$ for $n = 1, \dots, N$ and observe convergence to $|R|/m$.
The sandwich $(\ast)$ gives an explicit error bound
$$\Big|\,\mathrm{dimEst}(D_{m,R},n) - \tfrac{|R|}{m}\,\Big| \le \frac{|R|}{n}
\le \frac{m}{n},$$
so accuracy $\varepsilon$ is guaranteed once $n \ge m/\varepsilon$.

### 5.3 Realizing a target rational

To realize dimension $p/m$, set $R = \{0, 1, \dots, p-1\}$ and return the theory
$D_{m,R}$. Verification is a single evaluation of the closed form for the
dimension.

---

## 6. Applications and interpretation

- **A measuring stick for logical strength.** Two competing standards of truth
  can be compared by dimension; monotonicity (Theorem 3.3) guarantees a stronger
  standard never has smaller dimension.
- **Tunable sparse models.** The periodic construction supplies, for any desired
  information density, an explicit generative model of "accepted statements" whose
  fractal dimension is exactly that density — useful as a controlled test bed for
  studying how the abundance of truth interacts with other structural properties.
- **Conceptual payoff.** The result reframes "how much truth is there?" as a
  question about coordinate density. Dimension is not an accident of any single
  encoding trick; it is the asymptotic fraction of information-bearing positions.

---

## 7. Discussion

The heart of the argument is that the box dimension of a periodic density theory
equals the asymptotic density of its free coordinates, established through an
exact count $\mathrm{count} = 2^{\mathrm{free}}$ and an elementary squeeze. Two
features deserve emphasis. First, the count is *exact*, so nothing is lost to
estimation before the limiting step; the only inequalities are the clean
block-counting bounds $(\ast)$. Second, the dimension is *density-driven*: it
ignores the arithmetic identity of the admissible residues. This is precisely why
the whole rational interval — not a sparse subset — is realized.

The use of $\limsup$ rather than $\lim$ in the definition is not idle generality.
For irregular theories the finite estimate genuinely oscillates, and the
$\limsup$ is the correct dimension. The periodic theories are *asymptotically
regular*, which collapses the $\limsup$ to a limit; this is a special feature of
the construction, not a general phenomenon.

---

## 8. Future work

1. **The full real spectrum.** The squeeze argument used only that the
   free-coordinate count grows like $d\cdot n + o(n)$, never the arithmetic of the
   period. Any coordinate set of (Dirichlet) density $d$ should therefore yield a
   theory of dimension exactly $d$, extending the spectrum from $\mathbb{Q}\cap
   [0,1]$ to all of $[0,1]$.
2. **A dimension calculus.** Conjecturally the dimension of a pointwise union of
   theories is the maximum of the two dimensions (a factor-of-two overlap costs
   only $1/n$ in the logarithm and vanishes), while an independent product adds
   dimensions, capped at $1$. With the exact counting law in hand these reduce to
   elementary inequalities on free-coordinate counts.
3. **Hausdorff dimension and measure-zero truth.** Extended to infinite strings,
   the periodic construction yields a self-similar Cantor-like set whose Hausdorff
   dimension should coincide with the coordinate density $d$, while a positive
   density of constrained coordinates forces Lebesgue measure zero — truth as a
   genuine fractal, not merely a sparse scatter. The box-counting side is settled
   here; matching it to Hausdorff dimension requires a mass-distribution
   (Frostman) argument on the explicit self-similar set.

---

## 9. Conclusion

We have shown that the fractal dimension of a theory of truth is exactly the
asymptotic density of its information-bearing coordinates, and consequently that
every rational number in $[0,1]$ arises as such a dimension, each realized by a
concrete periodic theory. The dimension spectrum of truth is the entire rational
unit interval; the isolated value $1/2$ is revealed as a single point in a
continuum-in-waiting. Truth is neither a solid nor a dust: measured by covering
the space of statements, it is a fractal whose dimension we can now name — and
dial — precisely.
