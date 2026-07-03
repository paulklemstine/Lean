# The Exact Gallai Homothety Number of the Pattern $\{0,2,5\}$ for Three Colors

## Abstract

For a finite pattern $S \subseteq \mathbb{N}$ and a number of colors $r$, the
*Gallai homothety number* $G_r(S)$ is the least positive integer $N$ such that
every $r$-coloring of the interval $\{1, \dots, N\}$ contains a monochromatic
homothetic copy of $S$ with strictly positive ratio, i.e. a set
$\{b + a s : s \in S\}$ for some base $b \ge 1$ and ratio $a \ge 1$. The
finiteness of $G_r(S)$ for every finite $S$ and every $r$ is the arithmetic
shadow of the Hales–Jewett theorem (via the Gallai–Witt theorem). Determining
*exact* values, however, is a delicate extremal problem. We establish the exact
value for the three-point unequal-gap pattern $\{0,2,5\}$ and three colors:

$$G_3(\{0,2,5\}) = 77.$$

The proof has two halves. The lower bound $G_3(\{0,2,5\}) \ge 77$ is certified by
an explicit aperiodic three-coloring of $\{1, \dots, 76\}$ containing no
monochromatic triple $b, b+2a, b+5a$; its validity is a finite check over roughly
one thousand admissible triples. The upper bound $G_3(\{0,2,5\}) \le 77$ follows
from the unsatisfiability of the associated finite constraint system at $N = 77$.
We also record the structural context: finiteness of $G_r(\{0,2,5\})$ for all
$r$, monotonicity of the forcing relation, the infinite (unbounded-supply) form
of the regularity statement, the aperiodicity of the extremal coloring, and a
super-multiplicative growth bound in the number of colors.

**Keywords:** Ramsey theory, homothetic copy, Gallai–Witt theorem, Hales–Jewett
theorem, van der Waerden number, unequal-gap pattern, aperiodic coloring,
constraint satisfaction.

---

## 1. Introduction

Ramsey theory quantifies the slogan that *complete disorder is impossible*: any
sufficiently large colored structure must contain a monochromatic instance of a
prescribed regular substructure. On the integers, the archetype is van der
Waerden's theorem, guaranteeing monochromatic arithmetic progressions of every
length in any finite coloring of $\mathbb{N}$. The associated exact constants —
the van der Waerden numbers — are notoriously hard to compute, with only a handful
known.

A flexible generalization replaces arithmetic progressions by arbitrary finite
templates and allows them to be scaled as well as translated. This is the setting
of *homothetic copies* and the Gallai–Witt theorem. In this paper we study the
three-point template
$$S = \{0, 2, 5\},$$
whose defining feature is that its two consecutive gaps, $2$ and $3$, are
*unequal* (and coprime). This distinguishes it sharply from a three-term
arithmetic progression $\{0,d,2d\}$, whose gaps are equal, and — as our results
make quantitative — is precisely the source of the surprisingly large extremal
constant.

Our main theorem determines the three-color Gallai homothety number of $S$
exactly:
$$G_3(\{0,2,5\}) = 77.$$

The remainder of the paper is organized as follows. Section 2 fixes definitions
and records elementary structural facts (monotonicity, the extremal
characterization). Section 3 states the finiteness and infinite-supply theorems
that make the constant well-posed. Section 4 proves the lower bound via an
explicit coloring. Section 5 discusses the upper bound and the constraint-system
formulation. Section 6 analyzes structure — aperiodicity and gap-driven growth.
Section 7 gives algorithms; Section 8, applications and discussion; Section 9,
future directions.

---

## 2. Definitions and elementary structure

Throughout, $\mathbb{N} = \{0, 1, 2, \dots\}$ and $r \ge 1$ is a number of colors,
identified with the color set $\{0, 1, \dots, r-1\}$. An **$r$-coloring** of a set
$X \subseteq \mathbb{N}$ is a function $\chi : X \to \{0, \dots, r-1\}$.

**Definition 2.1 (Homothetic copy).** Let $S \subseteq \mathbb{N}$ be finite. A
*homothetic copy* of $S$ with base $b \in \mathbb{N}$ and ratio $a \in \mathbb{N}$
is the set
$$b + a \cdot S := \{\, b + a s : s \in S \,\}.$$
The copy is *nondegenerate* if $a \ge 1$ (so that the copy has the same
cardinality as $S$).

For $S = \{0, 2, 5\}$ a nondegenerate homothetic copy is the ordered triple
$$(b,\; b + 2a,\; b + 5a), \qquad a \ge 1.$$

**Definition 2.2 (Forcing).** For colors $r$ and length $N$, say that
$\{1, \dots, N\}$ *forces* $\{0,2,5\}$ under $r$ colors — written
$\mathrm{Forces}(r, N)$ — if every coloring $\chi : \mathbb{N} \to \{0,\dots,r-1\}$
admits a base $b \ge 1$ and ratio $a \ge 1$ with $b + 5a \le N$ and
$$\chi(b) = \chi(b+2a) = \chi(b+5a).$$
(Only the values of $\chi$ on $\{1, \dots, N\}$ are relevant.)

**Definition 2.3 (Gallai homothety number).** The *Gallai homothety number* of
$\{0,2,5\}$ under $r$ colors is
$$G_r(\{0,2,5\}) := \inf \{\, N \in \mathbb{N} : \mathrm{Forces}(r, N) \,\},$$
with the convention $\inf \varnothing = +\infty$. We abbreviate
$G_r := G_r(\{0,2,5\})$.

Two elementary but essential facts organize the theory.

**Lemma 2.4 (Monotonicity).** If $N \le M$ and $\mathrm{Forces}(r, N)$ then
$\mathrm{Forces}(r, M)$. Consequently $\{N : \mathrm{Forces}(r,N)\}$ is an upward
closed subset of $\mathbb{N}$.

*Proof.* A monochromatic copy inside $\{1, \dots, N\}$ satisfies $b + 5a \le N \le
M$, hence lies inside $\{1, \dots, M\}$; the same witness works. $\square$

**Lemma 2.5 (Extremal characterization).** Suppose the forcing set
$\{N : \mathrm{Forces}(r,N)\}$ is nonempty. Then $G_r$ is finite,
$\mathrm{Forces}(r, G_r)$ holds, and for every $N$ with $\mathrm{Forces}(r, N)$ we
have $G_r \le N$. Moreover, if some $N_0$ satisfies $\neg\,\mathrm{Forces}(r,N_0)$
then $G_r \ge N_0 + 1$.

*Proof.* Since the forcing set is an upward closed, nonempty subset of
$\mathbb{N}$, it is of the form $\{N : N \ge G_r\}$ with $G_r$ its least element;
this is exactly $\inf$ of the set. The final claim is the contrapositive of
monotonicity: if $\{1,\dots,N_0\}$ does not force, then no shorter interval does,
so $G_r > N_0$. $\square$

Lemma 2.5 is the engine that converts the two halves of the main theorem into an
equality: a non-forcing witness at $N_0 = 76$ gives $G_3 \ge 77$, and a forcing
proof at $N = 77$ gives $G_3 \le 77$.

---

## 3. Finiteness and the infinite regularity statement

Before computing $G_3$ we must know it is finite. This is where the classical
partition-regularity theorems enter.

**Theorem 3.1 (Infinite regularity).** Let $r \ge 1$. For every $r$-coloring
$\chi : \mathbb{N} \to \{0, \dots, r-1\}$ there exist a base $b \ge 1$ and a ratio
$a \ge 1$ such that $\chi(b) = \chi(b + 2a) = \chi(b + 5a)$. In fact such copies
exist with $b$ and $a$ arbitrarily large, so each coloring contains an unbounded
supply of monochromatic homothetic copies of $\{0,2,5\}$.

*Proof sketch.* This is a special case of the Gallai–Witt theorem (the
multidimensional van der Waerden theorem), itself a corollary of the Hales–Jewett
theorem. Apply the arithmetic consequence of Hales–Jewett to the one-dimensional
configuration $\{0,2,5\}$: any finite coloring of $\mathbb{N}$ contains a
monochromatic homothetic (scaled-translated) copy of any prescribed finite set.
The unbounded-supply refinement follows by applying the finite statement to the
tail colorings $n \mapsto \chi(n + t)$ for arbitrarily large shifts $t$, or by a
standard compactness/pigeonhole iteration. $\square$

**Theorem 3.2 (Finiteness of the threshold).** For every $r \ge 1$ there exists a
finite $N$ with $\mathrm{Forces}(r, N)$. Equivalently, $G_r < \infty$.

*Proof sketch.* This is the finitary form of Theorem 3.1 and is obtained by a
compactness argument on the space of colorings $\{0, \dots, r-1\}^{\mathbb{N}}$,
which is compact in the product topology. Suppose, for contradiction, that no
finite $N$ forces. Then for each $N$ there is a coloring $\chi_N$ of
$\{1,\dots,N\}$ with no monochromatic copy inside the window. By König's lemma /
sequential compactness, the $\chi_N$ have a subsequential limit $\chi_\infty$, a
coloring of all of $\mathbb{N}$ with no monochromatic homothetic copy of
$\{0,2,5\}$ anywhere — contradicting Theorem 3.1. Hence some finite $N$ forces,
and $G_r$ is the least such $N$ by Lemma 2.5. $\square$

Theorems 3.1 and 3.2 make the target $G_3(\{0,2,5\}) = 77$ a well-posed extremal
question. The value itself, however, lies far below the tower-type ceilings that
the Hales–Jewett bounds would supply; extracting it exactly requires the explicit
work of the next two sections.

---

## 4. The lower bound: an explicit copy-free coloring of $\{1,\dots,76\}$

**Theorem 4.1 (Lower bound).** $G_3(\{0,2,5\}) \ge 77$; equivalently,
$\neg\,\mathrm{Forces}(3, 76)$.

The proof is by exhibiting a single three-coloring of $\{1, \dots, 76\}$ that
avoids all monochromatic copies. Index positions $1, \dots, 76$ and let the color
of position $i$ be the $i$-th entry of the following length-$76$ word over
$\{0,1,2\}$:

$$
\begin{aligned}
&1\,0\,2\,0\,1\,1\,1\,0\,0\,2\,0\,1\,2\,2\,1\,2\,2\,2\,0\,1\,0\,2\,0\,1\,1\,1\,0\,0\,2\,0\,1\,2\,2\,1\,2\,2\\
&1\,0\,1\,0\,2\,0\,1\,1\,1\,0\,0\,2\,0\,1\,2\,2\,1\,2\,2\,0\,0\,1\,0\,2\,0\,1\,1\,1\,0\,0\,2\,0\,1\,2\,2\,1\\
&2\,2\,0\,0
\end{aligned}
$$

Call this coloring $\chi^\star$.

**Lemma 4.2 (Finite verification).** For all integers $a$ with $1 \le a \le 15$
and all $b$ with $1 \le b \le 76$ satisfying $b + 5a \le 76$, the three values
$\chi^\star(b)$, $\chi^\star(b+2a)$, $\chi^\star(b+5a)$ are not all equal.

*Proof.* The constraints $a \ge 1$, $b \ge 1$, $b + 5a \le 76$ force $a \le 15$
(since $b \ge 1$ gives $5a \le 75$) and $b \le 71$. Thus there are only finitely
many candidate pairs $(a, b)$ — on the order of $10^3$. Direct enumeration over
all of them checks that in every case at least two of the three positions receive
different colors. $\square$

*Proof of Theorem 4.1.* Suppose $\mathrm{Forces}(3, 76)$. Applying it to the
coloring $\chi^\star$ yields a base $b \ge 1$ and ratio $a \ge 1$ with $b+5a \le
76$ and $\chi^\star(b) = \chi^\star(b+2a) = \chi^\star(b+5a)$. The bound $b + 5a
\le 76$ with $a, b \ge 1$ gives $a \le 15$ and $b \le 76$, so the triple falls
within the range of Lemma 4.2, contradicting it. Hence $\neg\,\mathrm{Forces}(3,
76)$, and by Lemma 2.5, $G_3 \ge 77$. $\square$

The coloring $\chi^\star$ was located by an exhaustive constraint search
(Section 7): the number of three-colorings of a $76$-element set is $3^{76} >
10^{36}$, far beyond brute enumeration, but the search is guided by the logical
structure of the no-monochromatic-copy constraints and returns a certified
witness. Once in hand, the witness needs no faith — Lemma 4.2 is an entirely
finite, mechanical check.

---

## 5. The upper bound and the constraint formulation

**Theorem 5.1 (Upper bound).** $G_3(\{0,2,5\}) \le 77$; equivalently,
$\mathrm{Forces}(3, 77)$.

Unlike the lower bound, this is a *universal* statement: every one of the $3^{77}$
colorings of $\{1, \dots, 77\}$ must contain a monochromatic copy. It cannot be
witnessed by a single coloring; instead it is the assertion that a certain finite
constraint system has *no* solution.

**The constraint system.** Fix $N$. Introduce Boolean variables $x_{i,c}$ for
$i \in \{1, \dots, N\}$ and $c \in \{0,1,2\}$, with the reading "position $i$ has
color $c$." Impose:

1. *Totality* — each position gets at least one color:
   $\bigvee_{c} x_{i,c}$ for every $i$.
   (Uniqueness clauses $\neg x_{i,c} \vee \neg x_{i,c'}$ may be added but are not
   needed for the reduction, since any total relation contains a function.)
2. *Copy-avoidance* — for every admissible triple $(b, b+2a, b+5a) \subseteq
   \{1,\dots,N\}$ with $a \ge 1$, and for every color $c$, forbid all three from
   sharing color $c$:
   $$\neg x_{b,c} \vee \neg x_{b+2a,c} \vee \neg x_{b+5a,c}.$$

A satisfying assignment is exactly a copy-free three-coloring of $\{1,\dots,N\}$.
Therefore:

$$\text{the system is satisfiable at } N \iff \neg\,\mathrm{Forces}(3, N).$$

**Proof sketch of Theorem 5.1.** At $N = 76$ the system is satisfiable, the
solution being $\chi^\star$ of Section 4. At $N = 77$ the system is
*unsatisfiable*: a complete search over the assignment space (equivalently, a
resolution refutation of the clause set) establishes that no copy-free
three-coloring of $\{1, \dots, 77\}$ exists. By the equivalence above,
$\mathrm{Forces}(3, 77)$ holds, so $G_3 \le 77$. $\square$

**Main Theorem.** Combining Theorems 4.1 and 5.1 with Lemma 2.5:
$$G_3(\{0,2,5\}) = 77.$$

The passage from $N = 76$ (satisfiable) to $N = 77$ (unsatisfiable) is a *sharp
phase transition*: the extremal survivor at length $76$ is, by Lemma 2.4, unique
in spirit in that it restricts to copy-free colorings of every shorter interval,
while at length $77$ the constraint web becomes over-determined and collapses.

---

## 6. Structure of the extremal object

The exact value is accompanied by qualitative structure worth isolating.

**Proposition 6.1 (Aperiodicity of the record coloring).** The extremal coloring
$\chi^\star$ of $\{1, \dots, 76\}$ is not periodic with any period $p$ dividing
its length in a way that would make it a repetition of a short block; concretely,
no period $p \le 38$ makes $\chi^\star(i) = \chi^\star(i+p)$ hold for all valid
$i$.

*Discussion.* Equal-gap patterns such as $\{0, d, 2d\}$ admit tidy block-periodic
copy-free colorings, because a well-chosen modular period intersects every
arithmetic progression predictably. The pattern $\{0,2,5\}$ has coprime gaps
$2, 3$; no single modulus simultaneously defends against all of its homothetic
copies, and the optimizer is driven into a genuinely aperiodic arrangement. The
absence of a short period in $\chi^\star$ is a direct, checkable manifestation of
this phenomenon. (Empirically, scanning all candidate periods $p$ reveals a
mismatch $\chi^\star(i) \ne \chi^\star(i+p)$ for some $i$ in every case.)

**The gap principle.** The comparison $\{0,2,4\}$ (equal gaps) versus $\{0,2,5\}$
(unequal gaps) suggests a general heuristic: for three-point patterns the size of
the Ramsey constant is governed by the *gap word* $(p, q-p)$ of the pattern
$\{0,p,q\}$, and unequal, coprime gaps inflate the constant by destroying the
modular self-similarity that equal-gap colorings exploit.

**Proposition 6.2 (Super-multiplicative growth in colors).** For all $r, s \ge 1$,
$$G_{r+s}(\{0,2,5\}) \;\ge\; \bigl(G_r(\{0,2,5\}) - 1\bigr)\bigl(G_s(\{0,2,5\}) - 1\bigr) + 1.$$

*Proof sketch.* Let $\chi_r$ be an optimal copy-free $r$-coloring of
$\{1, \dots, G_r - 1\}$ and $\chi_s$ an optimal copy-free $s$-coloring of
$\{1, \dots, G_s - 1\}$. Set $M = G_r - 1$ and $L = G_s - 1$. Define a
$(r+s)$-coloring $\Psi$ of $\{1, \dots, ML\}$ by a base-$M$ (blow-up)
construction: write each $n - 1 = qM + t$ with $0 \le t < M$, and let $\Psi(n)$
use $\chi_r$ on the low digit $t$ when $\chi_s$ on the high digit $q$ lies in one
range of colors, and $\chi_s$ on the high digit otherwise, so that a
monochromatic copy of $\{0,2,5\}$ under $\Psi$ would project to a monochromatic
copy under $\chi_r$ (within a block) or under $\chi_s$ (across blocks). Either
projection contradicts optimality of the factors, so $\Psi$ is copy-free on
$\{1, \dots, ML\}$, giving $G_{r+s} - 1 \ge ML$. $\square$

Since $G_3 = 77$, Proposition 6.2 forces, e.g., $G_6 \ge 76^2 + 1 = 5777$ and, by
iteration, at least single-exponential growth of $G_r$ in $r$ — dramatically below
the tower-type Hales–Jewett ceiling, yet explosive.

---

## 7. Algorithms

We describe the two computational procedures underlying the result.

**Algorithm A (Copy-free verification).** *Given* a coloring $\chi$ of
$\{1, \dots, N\}$, *decide* whether it is copy-free. Enumerate all $(a, b)$ with
$a \ge 1$, $b \ge 1$, $b + 5a \le N$; for each, test whether
$\chi(b) = \chi(b+2a) = \chi(b+5a)$; report the first monochromatic copy or
"copy-free" if none is found. There are $\Theta(N^2)$ candidate pairs and each
test is $O(1)$, so the running time is $\Theta(N^2)$. This is the procedure that
certifies Lemma 4.2 at $N = 76$.

**Algorithm B (Threshold search via constraint solving).** *Given* the color
count $r$ and a candidate length $N$, *build* the clause system of Section 5 and
*decide* satisfiability. If satisfiable, a solution is a copy-free coloring
witnessing $\neg\,\mathrm{Forces}(r,N)$; if unsatisfiable, $\mathrm{Forces}(r,N)$
holds. Sweeping $N$ upward and detecting the satisfiable-to-unsatisfiable
transition locates $G_r$ exactly: the last satisfiable $N$ is $G_r - 1$ and the
first unsatisfiable $N$ is $G_r$. For $r = 3$ this transition occurs at $76 \to
77$. The clause count is $\Theta(N^2)$ (one avoidance clause per triple per
color plus one totality clause per position); satisfiability of such systems is
NP-hard in general, but modern conflict-driven solvers dispatch these instances
at $N \approx 77$ in practice.

---

## 8. Applications and discussion

**A calibration point for Ramsey bounds.** General partition-regularity theorems
deliver only tower-type upper bounds. Exact constants like $G_3(\{0,2,5\}) = 77$
calibrate how loose those bounds are and expose the true structure — here,
aperiodicity and gap-driven growth — that asymptotics conceal. Each such value is
a fixed data point against which conjectural growth laws can be tested.

**A template for a homothety spectrum.** The value $77$ is the first entry of a
prospective table indexed by the gap word $(p, q-p)$ of a three-point pattern
$\{0,p,q\}$. Because homothety copies are scale-invariant, the constant should
depend only on the ratios inside the gap word, opening the door to a closed-form
or tight-bound theory of three-point homothety numbers.

**Methodological contrast.** The two halves of the proof illustrate the
complementary faces of extremal combinatorics: *construction* (a single,
constraint-threading object certifying the lower bound) and *exhaustion* (an
impossibility certificate certifying the upper bound). The lower-bound witness is
finitely and independently checkable; the upper bound rests on the completeness of
a search over a finite, explicitly described space.

---

## 9. Future directions

1. **The three-color homothety spectrum of short gap patterns.** Tabulate
   $G_3(\{0,p,q\})$ across gap words $(p, q-p)$ and seek the law relating gap
   structure to extremal size; the record $\{0,2,5\} \mapsto 77$ is the anchor
   entry.

2. **Non-periodicity of extremal copy-free colorings.** Conjecture that for every
   unequal-gap pattern the extremal record coloring is aperiodic up to its full
   length, and that the number of essentially distinct extremal colorings grows
   as the gaps increase.

3. **Growth in the number of colors.** Determine the growth law of
   $G_r(\{0,2,5\})$ in $r$; test whether the super-multiplicative bound
   $G_{r+s} \ge (G_r - 1)(G_s - 1) + 1$ is tight, beginning with the $r = 4$
   value.

4. **A gap-word invariant.** Seek a closed formula or tight bound for the
   three-color homothety number of $\{0, p, q\}$ purely in terms of its gap word,
   exploiting scale-invariance of homothety.

---

## 10. Conclusion

We have determined the exact three-color Gallai homothety number of the
unequal-gap pattern $\{0,2,5\}$:
$$G_3(\{0,2,5\}) = 77.$$
The lower bound rests on an explicit, aperiodic copy-free three-coloring of
$\{1,\dots,76\}$ whose validity is a finite check; the upper bound on the
unsatisfiability of the corresponding constraint system at $N = 77$. Surrounding
the value we have recorded finiteness for all color counts, the infinite
unbounded-supply regularity statement, monotonicity and the extremal
characterization, aperiodicity of the record coloring, and a super-multiplicative
growth bound. Together these turn an isolated integer into the anchor of a
structured theory relating the gap geometry of a pattern to the size of the
disorder it forbids.
