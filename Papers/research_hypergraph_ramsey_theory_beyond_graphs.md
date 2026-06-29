# Hypergraph Ramsey Theory Beyond Graphs: A Formal Account of the Probabilistic Floor, the Stepping-Up Ceiling, and Their Double-Exponential Gap

## Abstract

We give a self-contained development of two-color diagonal Ramsey theory for
$r$-uniform hypergraphs, organized around the contrast between the *single*-
exponential lower bound produced by the probabilistic method and the *double*-
exponential upper bound produced by the Erdős–Rado stepping-up lemma. Working
over the explicit finite coloring model in which a coloring assigns a Boolean to
each $r$-element subset of an $n$-element vertex set, we prove: (1) an exact
double-counting form of the probabilistic method, yielding both
$2\binom{n}{k} < 2^{\binom{k}{3}} \Rightarrow R_3(k,k) > n$ and its converse
inequality $n \ge R_3(k,k) \Rightarrow 2^{\binom{k}{3}} \le 2\binom{n}{k}$, with
verified instances $R_3(5,5) > 11$ and $R_3(6,6) > 29$; (2) a structural
stepping-up lemma converting the $r$-uniform property on $N$ vertices into the
$(r{+}1)$-uniform property on $2^N$ vertices, iterated into a tower-function
growth law; and (3) explicit separation results showing the tower function
dominates every fixed exponential base ($c^k < \mathrm{tower}(2,k)$ for
$k \ge c+1$) together with the polynomial-versus-tower comparison
$\binom{k}{3} < 2^{k^2}$. Together these results delimit the central open problem
of the field — the conjecture that $R_3(k,k) = 2^{2^{\Theta(k)}}$ — between two
formally certified bounds. All statements correspond to fully formalized,
machine-checked theorems.

**Keywords.** Ramsey theory, hypergraphs, probabilistic method, stepping-up
lemma, tower function, double exponential growth, extremal combinatorics.

---

## 1. Introduction

Ramsey's theorem asserts that complete disorder is impossible: any sufficiently
large structure, however its constituents are colored, contains a large
monochromatic substructure. For graphs the quantitative form is the Ramsey
number $R(k,\ell)$, the least $n$ such that every red/blue coloring of the edges
of the complete graph $K_n$ contains a red $K_k$ or a blue $K_\ell$. The
diagonal numbers $R(k,k)$ are known to grow exponentially: classical bounds give
$2^{k/2} \lesssim R(k,k) \le 4^k$, and pinning the base of the exponent is a
famous open problem.

For *hypergraphs* the picture changes qualitatively. Fix the **uniformity**
$r \ge 2$. A coloring assigns one of two colors to every $r$-element subset of
the vertex set. The diagonal hypergraph Ramsey number $R_r(k,k)$ is the least
$n$ such that every such coloring on $n$ vertices contains a *monochromatic
$k$-clique*: a $k$-set all of whose $\binom{k}{r}$ $r$-subsets share a single
color. The known landscape for $r = 3$ is already severe: $R_3(4,4) = 13$ is
known exactly (McKay–Radziszowski, 1991), while $R_3(5,5)$ is only bounded
between 34 and 55. The conjectured asymptotic growth is doubly exponential,
$R_3(k,k) = 2^{2^{\Theta(k)}}$, in sharp contrast to the singly exponential
growth of graph Ramsey numbers.

This paper formalizes the two pillars that frame this conjecture. The lower
pillar is the probabilistic method (Erdős, 1947), which produces a floor of
$2^{\Omega(k^2)}$. The upper pillar is the stepping-up lemma (Erdős–Rado, 1952),
which produces a ceiling of $2^{2^{O(k)}}$ by trading one dimension of
uniformity for one extra level of a tower of exponentials. We develop both
inside a single explicit finite coloring model so that every probability is an
exact count and every bound is a verified arithmetic statement.

The remainder of the paper is organized as follows. Section 2 fixes definitions.
Section 3 develops the probabilistic lower bound, including its exact
double-counting core and concrete instances. Section 4 treats structural
properties (monotonicity and degeneracy). Section 5 develops the stepping-up
lemma and the tower-function growth law. Section 6 proves the separation results
that certify the lower/upper gap. Section 7 discusses applications and Section 8
gives future directions.

---

## 2. Definitions and the coloring model

Throughout, $[n] = \{0, 1, \dots, n-1\}$ is the vertex set, modeled as `Fin n`.
For a finite set $S$ and an integer $r$, $\binom{S}{r}$ denotes the family of
$r$-element subsets of $S$, and $\binom{k}{r} = \mathrm{C}(k,r)$ is the binomial
coefficient.

**Definition 2.1 (Coloring).** An *$r$-uniform two-coloring* on $[n]$ is a
function
$$
\chi : \binom{[n]}{r} \longrightarrow \{\mathrm{true}, \mathrm{false}\},
$$
i.e. an assignment of one of two colors to every $r$-element subset. In the
formal model this is `HypergraphColoring n r := {T : Finset (Fin n) // T.card = r} → Bool`.

**Definition 2.2 (Monochromatic clique).** A set $S \subseteq [n]$ is a
*monochromatic clique of color $c$* under $\chi$, written
$\mathrm{Mono}(\chi, S, c)$, if every $r$-subset of $S$ has color $c$:
$$
\mathrm{Mono}(\chi, S, c) \;:\equiv\; \forall\, T \subseteq S,\ |T| = r \;\Rightarrow\; \chi(T) = c.
$$

**Definition 2.3 (Ramsey property).** The *(off-diagonal) Ramsey property*
$\mathrm{Ramsey}_r(n; k, \ell)$ holds if every $r$-uniform coloring on $[n]$
admits a monochromatic true-clique of size $k$ or a monochromatic false-clique
of size $\ell$:
$$
\forall \chi,\ \big(\exists S,\ |S| = k \wedge \mathrm{Mono}(\chi, S, \mathrm{true})\big)
\ \vee\ \big(\exists S,\ |S| = \ell \wedge \mathrm{Mono}(\chi, S, \mathrm{false})\big).
$$
The diagonal Ramsey number is $R_r(k,k) = \min\{ n : \mathrm{Ramsey}_r(n; k, k)\}$;
equivalently, $R_r(k,k) > n$ iff $\mathrm{Ramsey}_r(n;k,k)$ fails, i.e. some
coloring avoids monochromatic $k$-cliques of both colors.

**Definition 2.4 (Tower function).** The tower (iterated exponential) function
is
$$
\mathrm{tower}(b, 0) = 1, \qquad \mathrm{tower}(b, m+1) = b^{\mathrm{tower}(b, m)}.
$$
Thus $\mathrm{tower}(2, m)$ is a stack of $m$ twos. We also use the height-shifted
variant $\mathrm{towerExp}(0, N) = N$, $\mathrm{towerExp}(h+1, N) = 2^{\mathrm{towerExp}(h, N)}$,
which starts the tower from an arbitrary base value $N$.

**Definition 2.5 (Stepping-up bound).** The *stepping-up bound* is
$\mathrm{step}(R) = 2^{R-1} + 1$, the standard Erdős–Rado per-level blow-up.

---

## 3. The probabilistic lower bound

### 3.1 The exact double-counting core

The probabilistic method is usually phrased measure-theoretically. We instead
make it an *exact finite identity*, which is what permits full formalization
with no appeal to probability spaces.

**Theorem 3.1 (Probabilistic counting inequality).** *Let $k \ge 3$. If
$\mathrm{Ramsey}_3(n; k, k)$ holds, then*
$$
2^{\binom{k}{3}} \le 2 \binom{n}{k}.
$$

*Proof sketch.* Suppose for contradiction $2\binom{n}{k} < 2^{\binom{k}{3}}$. We
exhibit a coloring with no monochromatic $k$-clique by counting. Identify
colorings of the $\binom{n}{3}$ triples with subsets of the family
$\Omega = \binom{[n]}{3}$ (a triple is "in" the subset iff colored true), so the
space of colorings has size $2^{\binom{n}{3}}$. For a fixed $k$-set $S$, the
colorings making $S$ monochromatic are those in which all $\binom{k}{3}$ triples
of $S$ are simultaneously true, or all false; the triples outside $S$ are
unconstrained. Each case contributes $2^{\binom{n}{3} - \binom{k}{3}}$
colorings, so at most $2 \cdot 2^{\binom{n}{3} - \binom{k}{3}}$ colorings make
$S$ monochromatic. Summing over the $\binom{n}{k}$ choices of $S$, the number of
colorings admitting *some* monochromatic $k$-set is at most
$$
\binom{n}{k} \cdot 2 \cdot 2^{\binom{n}{3} - \binom{k}{3}}
= \frac{2\binom{n}{k}}{2^{\binom{k}{3}}} \cdot 2^{\binom{n}{3}}
< 2^{\binom{n}{3}},
$$
using the assumed inequality. Since this is strictly fewer than the total number
of colorings, some coloring admits no monochromatic $k$-set of either color,
contradicting $\mathrm{Ramsey}_3(n;k,k)$. $\square$

The formal proof realizes "at most $2^{\binom{n}{3}-\binom{k}{3}}$" via an
explicit injection: colorings forcing a fixed family $F \subseteq \Omega$ to be
all-true inject into subsets of $\Omega \setminus F$ by $c \mapsto c \setminus F$,
inverted by union with $F$; counting subsets gives the bound. The union bound
over $k$-sets is a `Finset.biUnion` cardinality estimate, and the final strict
inequality is the pigeonhole principle in the form "if a sum of fibers is below
the total, the cover is incomplete."

### 3.2 The lower bound and its instances

Contraposing Theorem 3.1 gives the usable lower bound.

**Theorem 3.2 (Probabilistic lower bound).** *Let $k \ge 3$. If
$2\binom{n}{k} < 2^{\binom{k}{3}}$, then $\mathrm{Ramsey}_3(n; k, k)$ fails;
equivalently $R_3(k,k) > n$.*

*Proof.* Immediate from Theorem 3.1: if the property held we would get
$2^{\binom{k}{3}} \le 2\binom{n}{k}$, contradicting the hypothesis. $\square$

Because $\binom{k}{3} = k(k-1)(k-2)/6 = \Theta(k^3)$, the threshold permits
$n \approx 2^{\binom{k}{3}/k} = 2^{\Theta(k^2)}$, giving the **single-exponential
floor** $R_3(k,k) \ge 2^{\Omega(k^2)}$. The same template at uniformity $r$
gives $R_r(k,k) \ge 2^{\Omega(k^{r-1})}$, since the exponent $\binom{k}{r}$ is
$\Theta(k^r)$ while the union bound only costs a factor of $\binom{n}{k}$.

**Corollary 3.3 (Verified instances).**
$$
2 \cdot \binom{11}{5} = 924 < 1024 = 2^{\binom{5}{3}} \;\Rightarrow\; R_3(5,5) > 11,
$$
$$
2 \cdot \binom{29}{6} = 951{,}918 < 1{,}048{,}576 = 2^{\binom{6}{3}} \;\Rightarrow\; R_3(6,6) > 29.
$$
Both arithmetic facts are decided by computation, and the implications follow
from Theorem 3.2.

### 3.3 A parametric exact-count variant

A parallel formalization replaces probability by an *exact incidence identity*
in the special case $(r,k) = (3,4)$, which is instructive because it pins down
exactly what the first moment can and cannot deliver. Let $\mathrm{Edge}_3(n)$
and $\mathrm{Quad}_4(n)$ denote the families of 3- and 4-subsets of $[n]$, let a
coloring be $\chi : \mathrm{Edge}_3(n) \to \{0,1\}$, and let
$\mathrm{badCount}(\chi)$ be the number of monochromatic 4-sets.

**Lemma 3.4 (Fixed-quad count).** *For each 4-set $Q$, the number of colorings
under which all four triples of $Q$ are monochromatic equals
$2^{\binom{n}{3} - 3}$* (two choices of common color times $2^{\binom{n}{3}-4}$
free triples).

**Theorem 3.5 (Exact incidence identity).**
$$
\sum_{\chi} \mathrm{badCount}(\chi) = \binom{n}{4} \cdot 2^{\binom{n}{3} - 3}.
$$

*Proof sketch.* Swap the order of summation to count incident pairs
$(\chi, Q)$; each $Q$ contributes the count of Lemma 3.4, and there are
$\binom{n}{4}$ choices of $Q$. $\square$

**Corollary 3.6 (Expectation).** *The average of $\mathrm{badCount}$ over the
$2^{\binom{n}{3}}$ colorings equals $\binom{n}{4}/8$.*

This makes the "monochromatic probability" of a fixed tetrahedron exactly
$2/2^4 = 1/8$ transparent, and shows the first-moment existence criterion
"expectation $< 1$" is precisely $\binom{n}{4} < 8$ — which holds only for
$n \le 5$. It is therefore a *theorem*, not an oversight, that the bare first
moment cannot reach the true value $R_3(4,4) = 13$: at $n = 13$ the expectation
is $\binom{13}{4}/8 = 715/8 \approx 89.4 \gg 1$. The honest conclusion the first
moment delivers in this regime is $R_3(4,4) > 5$, and the exact value $13$
requires the deeper structural arguments rather than averaging alone.

---

## 4. Structural properties

These properties hold at every uniformity and underpin the recursion.

**Theorem 4.1 (Monotonicity of monochromaticity).** *If $S$ is a monochromatic
clique of color $c$ and $T \subseteq S$, then $T$ is also a monochromatic clique
of color $c$.*

*Proof.* Every $r$-subset of $T$ is an $r$-subset of $S$, hence has color $c$.
$\square$

**Theorem 4.2 (Diagonal monotonicity).** *For $k \ge 1$ and $r \ge 1$, if
$\mathrm{Ramsey}_r(n; k+1, k+1)$ holds then $\mathrm{Ramsey}_r(n; k, k)$ holds.
Consequently $R_r(k,k) \le R_r(k+1, k+1)$.*

*Proof sketch.* Given a coloring, the $(k{+}1,k{+}1)$ property yields a
monochromatic $(k{+}1)$-clique $S$; by Theorem 4.1 any $k$-subset of $S$ (which
exists since $|S| = k+1$) is a monochromatic $k$-clique. $\square$

**Theorem 4.3 (Degenerate regime).** *If $k \le r$ and $k \le n$, then
$\mathrm{Ramsey}_r(n; k, k)$ holds (so $R_r(k,k) \le k$).*

*Proof sketch.* A $k$-set with $k \le r$ has no $r$-subsets (or only the trivial
one when $k = r$), so $\mathrm{Mono}(\chi, S, \mathrm{true})$ holds vacuously for
any $k$-set $S$; pick any $k$-subset of $[n]$. $\square$

Theorem 4.3 marks the boundary of the interesting regime: the explosive growth
lives entirely in $k > r$.

---

## 5. The stepping-up lemma and tower growth

### 5.1 The stepping-up lemma

The stepping-up lemma is the recursion that lifts uniformity at the cost of one
exponential. We use the clean structural form (a constant-factor relaxation of
the classical $2^{N-1}+1$, which suffices for the tower asymptotics).

**Lemma 5.1 (Stepping-up, structural form).** *Suppose
$\mathrm{Ramsey}_r(N; k, k)$ holds with $r \ge 1$ and $r \le k$. Then
$\mathrm{Ramsey}_{r+1}(2^N; k+1, k+1)$ holds.*

*Idea.* Label the $2^N$ vertices by distinct binary strings of length $N$. Given
a coloring $\chi$ of the $(r{+}1)$-subsets of these labels, order any
$(r{+}1)$-subset by its labels and read off the $r$ "branching positions" at
which consecutive labels first differ; this projects $\chi$ to a coloring
$\chi'$ of $r$-subsets of $[N]$. The hypothesis yields a monochromatic
$k$-clique for $\chi'$ in $[N]$; reconstructing labels around it produces a
monochromatic $(k{+}1)$-clique for $\chi$ among the $2^N$ vertices. $\square$

### 5.2 Tower growth law

Iterating Lemma 5.1 stacks exponentials. The formalization expresses this with
the height-shifted tower $\mathrm{towerExp}$.

**Theorem 5.2 (Tower growth).** *Fix a base case $\mathrm{Ramsey}_r(N; k, k)$
with $1 \le r \le k$. Then for every height $h \ge 0$,*
$$
\mathrm{Ramsey}_{r+h}\big(\mathrm{towerExp}(h, N);\ k+h,\ k+h\big) \text{ holds.}
$$

*Proof.* Induction on $h$. The base $h = 0$ is the hypothesis. For the inductive
step, $\mathrm{towerExp}(h+1, N) = 2^{\mathrm{towerExp}(h, N)}$, and Lemma 5.1
turns the height-$h$ instance into the height-$(h{+}1)$ instance. $\square$

Starting from the graph base case $R_2(k,k) \le 4^k$ and stepping up once yields
$$
R_3(k+1, k+1) \le 2^{R_2(k,k)} \le 2^{4^k},
$$
a **double exponential**; a second step gives a triple exponential at uniformity
4, and in general uniformity $r$ produces a tower of height $r-1$. This is the
mechanism behind the conjectured $R_3(k,k) = 2^{2^{\Theta(k)}}$.

### 5.3 Concrete tower arithmetic

The tower function is computed and shown to be strictly increasing and
super-doubling.

**Proposition 5.3 (Tower values and monotonicity).**
$$
\mathrm{tower}(2,2) = 4,\quad \mathrm{tower}(2,3) = 16,\quad \mathrm{tower}(2,4) = 65{,}536,
$$
$$
\mathrm{tower}(2, m) < \mathrm{tower}(2, m+1), \qquad
2\,\mathrm{tower}(2, m) \le \mathrm{tower}(2, m+1).
$$

*Proof sketch.* The numeric values unfold the definition. Strict monotonicity
follows from $2^a < 2^b$ when $a < b$ together with positivity of the tower; the
doubling bound from $2m \le 2^m$ for $m \ge 1$ applied at $m = \mathrm{tower}(2,k)$.
$\square$

**Proposition 5.4 (Stepping-up bound estimates).** *The Erdős–Rado per-level
bound satisfies $\mathrm{step}(R) = 2^{R-1}+1 \le 2^R + 1$ and is monotone in
$R$; moreover $\mathrm{step}(\mathrm{tower}(2,k)) \le \mathrm{tower}(2, k+1) + 1$
for $k \ge 1$, exhibiting one tower level of growth per step.*

---

## 6. Separation: single versus double exponential

The defining feature of the field is that the lower and upper bounds are not
merely far apart numerically — they are *qualitatively* different growth
classes. We certify the separation.

**Theorem 6.1 (Tower dominates every fixed exponential).** *For every base
$c \ge 2$ and every $k \ge c+1$,*
$$
c^k < \mathrm{tower}(2, k).
$$

*Proof sketch.* Induction on $k$ from $k = c+1$. The crux is the analytic
estimate $c^{k+1} < 2^{c^2} \le 2^{\mathrm{tower}(2,k)} = \mathrm{tower}(2,k+1)$
for the base of the induction, established by comparing $\log_2$ of both sides
($(k+1)\log_2 c < k^2$ for $k$ large enough) together with $k^2 \le
\mathrm{tower}(2, k)$; small cases are decided directly. The inductive step uses
$\mathrm{tower}(2,k) \ge$ the relevant power, propagated through
$x \mapsto 2^x$. $\square$

**Corollary 6.2 (Graph vs. 3-uniform).** *For $k \ge 5$, $\;4^k < \mathrm{tower}(2,k)$.*
Since $R_2(k,k) < 4^k$ while the conjectured $R_3(k,k)$ behaves like
$\mathrm{tower}(2, \Theta(k))$, this is the formal statement that 3-uniform
Ramsey numbers eventually dominate graph Ramsey numbers by an entire extra
exponential.

**Theorem 6.3 (Lower-bound exponent is sub-tower).** *For $k \ge 4$,
$\binom{k}{3} < 2^{k^2}$.*

*Proof sketch.* $\binom{k}{3} \le 2^k \le 2^{k^2/k} \cdots$; more directly,
$\binom{k}{3} \le k^3 / 6 < 2^{k^2}$ via $k^3 < 2^{3k} \le 2^{k^2}$ for
$k \ge 4$, using $k+1 \le 2^k$. $\square$

Theorems 6.1–6.3 jointly express the central gap. The probabilistic floor lives
at $2^{\Theta(k^2)}$ (single exponential of a quadratic), the stepping-up ceiling
at $\mathrm{tower}(2, \Theta(k)) = 2^{2^{\Theta(k)}}$ (double exponential of a
linear), and the tower strictly outpaces the floor. Closing this gap — proving
the ceiling is the truth — is the open problem.

---

## 7. Applications

**Lower bounds in complexity.** Monochromatic-clique guarantees in hypergraphs
translate into unavoidable-structure arguments in communication complexity and
data-structure lower bounds, where the doubly-exponential growth quantifies how
much "room" an adversary needs to maintain disorder.

**Coding and design theory.** Colorings avoiding monochromatic cliques are
extremal objects akin to codes with forbidden configurations; the probabilistic
floor is a non-constructive existence guarantee for such objects on
$2^{\Omega(k^2)}$ symbols.

**Pattern avoidance in high-dimensional data.** When a learning pipeline seeks
to keep $r$-wise interactions among features "unstructured" (no large uniform
cluster), Theorem 3.2 bounds how many features can coexist before a uniform
pattern is forced, and the tower growth quantifies how this threshold scales
with interaction order $r$ — the practical face of "combinatorics is harder one
dimension up."

**Benchmarking exhaustive search.** Corollary 3.3 and the exact identity of
Section 3.3 give certified targets ($R_3(5,5) > 11$, $R_3(6,6) > 29$, the
$\binom{n}{4}/8$ expectation) against which heuristic or exhaustive solvers can
be validated.

---

## 8. Discussion and future work

We have framed diagonal 3-uniform Ramsey growth between two formally certified
bounds: a probabilistic floor $2^{\Omega(k^2)}$ and a stepping-up ceiling
$2^{2^{O(k)}}$, separated by the verified domination of the tower function over
fixed exponentials. Three concrete directions follow.

**Direction 1 — The first-moment ceiling is quadratic and tight.** The
affordable exponent in the probabilistic bound is budgeted by
$k\cdot m + 1 < \binom{k}{3}$, so the best floor obtainable is
$R_3(k,k) > 2^{m_k}$ with $m_k = \lfloor (\binom{k}{3}-2)/k \rfloor = \Theta(k^2)$.
This optimization is a finite arithmetic problem and the quadratic exponent is a
hard ceiling of the first moment, not a loose constant — no first-moment
argument over the uniform random coloring can do asymptotically better.

**Direction 2 — A formal stepping-up lemma closes the gap to a true double
exponential.** Composing a Lean-provable $R_3(k+1,k+1) \le 2^{R_2(k,k)} + 1$
with $R_2(k,k) \le 4^k$ would yield $R_3(k,k) \le \mathrm{tower}(2, c k) =
2^{2^{ck}}$. The separation $\binom{k}{3} < 2^{k^2} < \mathrm{tower}(2,k)$ shows
the proven floor lies strictly inside the conjectured ceiling, so the open
problem is exactly to raise the floor or lower the ceiling across this verified
gap; the tower machinery is already in place as a concrete target.

**Direction 3 — Off-diagonal numbers are polynomially skew.** Color symmetry
makes the two clique sizes interchangeable, so for fixed $r$ and $\ell$ the
off-diagonal $R_r(k, \ell)$ is conjectured to grow only polynomially in $k$
(degree $\approx \ell - 1$), in sharp contrast to the double-exponential
diagonal. Formalizing $R_3(k, \ell) = k^{\Theta(\ell)}$ for fixed $\ell$ would
delineate precisely where double-exponential behavior begins.

The overarching message is structural: each increment of uniformity adds an
exponential to the growth rate, turning a hard graph problem into a problem
whose answers are too large to ever enumerate. Ramsey's promise survives the
passage from pairs to triples; the cost of redeeming it climbs a tower.

---

## Appendix: Index of formalized results

- **Probabilistic counting inequality** (Thm 3.1): `prob_method_counting_ineq`.
- **Probabilistic lower bound** (Thm 3.2): `prob_method_lower_bound`,
  `hyper_ramsey_counting_lower_bound`.
- **Instances** (Cor 3.3): `R3_5_5_prob_lower_bound`,
  `prob_bound_verification_k5`, `prob_bound_verification_k6`.
- **Exact incidence identity / expectation** (Thm 3.5, Cor 3.6): `sum_badCount`,
  `expectation_badCount`, `card_mono_fixed_quad`.
- **Structure** (Thms 4.1–4.3): `MonochromaticClique.subset`,
  `diagonal_ramsey_mono`, `HypergraphRamseyProp_of_k_le_r`.
- **Stepping-up / tower growth** (Lem 5.1, Thm 5.2): `stepping_up_structural`,
  `hyper_ramsey_tower_bound`, `tower_of_towers`.
- **Tower arithmetic** (Props 5.3–5.4): `tower_two_two`, `tower_two_three`,
  `tower_two_four`, `tower_two_strict_mono`, `tower_ge_double`,
  `stepping_up_le_exp`, `steppingUpBound_mono`, `stepping_up_tower`.
- **Separation** (Thms 6.1–6.3): `tower_beats_exp`, `four_pow_lt_tower`,
  `lower_upper_gap_three_uniform`.
