# The Square Root of a Determinant, and the Hidden Symmetry of Strict Partitions

## A number that remembers how it was built

Some quantities in mathematics are stubbornly one-directional. You can square a number,
but the square root throws away a sign. You can multiply, but factoring is hard. And yet,
every so often, mathematics hands us a structure so rigid that the "lost" information comes
back for free. The **Pfaffian** is one of those gifts.

Take a square grid of numbers — a matrix. There is a famous quantity attached to it called
the **determinant**, which measures, among other things, whether the matrix can be inverted
and how it scales volumes. For a special family of matrices — the *antisymmetric* ones, where
the entry in row $i$, column $j$ is always the negative of the entry in row $j$, column $i$,
and the diagonal is all zeros — something remarkable happens. The determinant is *always a
perfect square*. And the thing it is the square of is the Pfaffian.

In symbols, if $A$ is such an antisymmetric matrix, then
$$\det A = \operatorname{Pf}(A)^2.$$

This is not an approximation, not a special case, not a numerical coincidence. It is an exact
algebraic identity, and it holds over any ring of "numbers" you care to use — integers,
rationals, polynomials, even abstract symbols. The Pfaffian is, in a precise sense, *the*
square root of the determinant, with the sign included. Where the determinant forgets, the
Pfaffian remembers.

This article is about that remembering — and about a beautiful place where it shows up:
the combinatorics of **strict partitions** and the symmetric functions built on them.

## Pairing up the dancers

Before the symmetric functions, let us look at where the Pfaffian comes from, because the
origin story is delightfully concrete. Imagine $2k$ dancers standing in a circle, numbered
$1$ through $2k$. We want to pair them all off into couples. A complete pairing is called a
**perfect matching**. For four dancers $\{1,2,3,4\}$ there are exactly three ways to do it:
$$\{12, 34\}, \qquad \{13, 24\}, \qquad \{14, 23\}.$$

Now suppose that for each possible couple $(i,j)$ we have a "compatibility score" $A_{ij}$.
The Pfaffian is the sum, over all perfect matchings, of the products of the scores of the
couples in that matching — with a carefully chosen plus or minus sign attached to each
matching. For four dancers it reads:
$$\operatorname{Pf}(A) = A_{12}A_{34} - A_{13}A_{24} + A_{14}A_{23}.$$

Look at the signs: $+, -, +$. They are not arbitrary. They are exactly the signs needed so
that, when you square this expression and use antisymmetry ($A_{ji} = -A_{ij}$, $A_{ii}=0$),
the answer collapses precisely onto the determinant of the $4\times 4$ matrix. Squaring a
three-term expression gives nine terms; the determinant of a $4\times 4$ matrix expands into
twenty-four signed terms. The fact that these two completely different-looking computations
agree, term for term, is the content of the identity
$$\det A = \operatorname{Pf}(A)^2$$
in the first genuinely interesting case. For the smaller $2\times 2$ case the story is almost
trivial — there is only one couple, so the Pfaffian is just the single entry $A_{12}$, and
$\det\begin{pmatrix} 0 & A_{12} \\ -A_{12} & 0\end{pmatrix} = A_{12}^2$ — but the
$4\times 4$ case is where the magic becomes visible.

This is exactly the content that has been verified, down to the last sign, as a formal
theorem: for the $2\times 2$ block the identity $\det A = (\operatorname{Pf} A)^2$ is named
`pf2_sq_eq_det`, and for the $4\times 4$ block it is `pf4_sq_eq_det`. The $4\times 4$ version
required first establishing the full Laplace expansion of a four-by-four determinant — all
twenty-four terms — recorded as `det_fin_four`, and then checking that the square of the
three-term Pfaffian matches it after substituting the antisymmetry relations. It is a genuine
degree-four polynomial identity in twelve independent variables, and it is true.

## The fingerprint of antisymmetry

Antisymmetric matrices have a personality, and the Pfaffian wears it on its sleeve. Suppose
you take your $2k$ dancers and swap two of them — relabel dancer $1$ as dancer $2$ and vice
versa, both in the rows and in the columns of your matrix. What happens to the Pfaffian?

It flips sign:
$$\operatorname{Pf}(\text{swapped } A) = -\operatorname{Pf}(A).$$

This is the **sign law**, and it is the matrix-level echo of one of the deepest patterns in
physics and algebra: *anticommutation*. In quantum mechanics, the operators that create
fermions — electrons, the antisocial particles that refuse to share a state — satisfy
$\psi_i \psi_j = -\psi_j \psi_i$. Swap two of them, pick up a minus sign. The Pfaffian's sign
law is the same phenomenon, written in the language of matrices. The verified theorem
`pf4_swap12_neg` proves precisely this for the four-by-four case: transposing indices $1$ and
$2$ negates the Pfaffian, and — strikingly — the proof needs only antisymmetry, not even the
zero-diagonal condition. The sign law is more robust than the determinant identity itself.

## Building bigger Pfaffians from smaller ones

Here is the feature that turns the Pfaffian from a curiosity into a workhorse: it is
*self-similar*. A big Pfaffian can be assembled out of little ones. For the four-by-four case,
the three perfect matchings can be read as three ways of splitting $\{1,2,3,4\}$ into two
complementary couples, and the Pfaffian becomes an alternating sum of products of
$2\times 2$ Pfaffians:
$$\operatorname{Pf}(A) =
\operatorname{Pf}(A_{12})\operatorname{Pf}(A_{34})
- \operatorname{Pf}(A_{13})\operatorname{Pf}(A_{24})
+ \operatorname{Pf}(A_{14})\operatorname{Pf}(A_{23}),$$
where each $A_{ij}$ denotes the tiny $2\times 2$ block sitting at rows and columns $i,j$.
This recursive structure — verified as `pf4_giambelli` — is the engine of everything that
follows. It is the rule that lets a single algebraic gadget scale up to arbitrary size, one
couple at a time.

And this is where the partitions come in.

## Strict partitions and the shapes they name

A **partition** of a whole number $n$ is a way of writing $n$ as a sum of positive whole
numbers, where order does not matter: $5 = 4+1 = 3+2 = 3+1+1 = \dots$. Partitions are the
combinatorial atoms of an enormous amount of mathematics, from the representation theory of
symmetric groups to the counting of energy levels in statistical mechanics.

A **strict partition** is one where all the parts are *different*: $5 = 4+1 = 3+2$, but not
$3+1+1$. Strict partitions, with their "no repeats" rule, have a special affinity for
antisymmetry — and therefore for Pfaffians. The reason is almost poetic: antisymmetric things
*hate repetition*. Swap two equal things and you should get a minus sign, but you also get the
same thing back, so it must be zero. Distinctness and antisymmetry are made for each other.

To each strict partition $\lambda = (\lambda_1 > \lambda_2 > \dots > \lambda_k \ge 0)$ the
theory attaches a polynomial called a **Schur $Q$-function**, $s_\lambda^Q$. These are among
the most important symmetric functions in mathematics: they govern the projective
representations of the symmetric group, the cohomology of certain geometric spaces called
isotropic Grassmannians, and much more. And here is the punchline that ties the whole story
together — the **Giambelli formula**:
$$s_\lambda^Q = \operatorname{Pf}\big[\, s_{(\lambda_i, \lambda_j)}^Q \,\big]_{1 \le i < j \le k}.$$

In words: the Schur $Q$-function of *any* strict partition is the Pfaffian of a matrix whose
entries are the Schur $Q$-functions of the simplest strict partitions — those with just *two*
parts. The complicated object is the Pfaffian of an array of simple objects. This is the exact
combinatorial analogue of the four-by-four expansion above, scaled up to arbitrary size, and
it is why the humble three-term identity $A_{12}A_{34} - A_{13}A_{24} + A_{14}A_{23}$ is worth
proving with full rigor: it is the $k=2$ seed of a formula that organizes an entire universe
of symmetric functions.

## Adding a tuning knob: the parameter $t$

The classical Schur $Q$-functions are beautiful but fixed. Modern mathematics loves to take a
rigid classical object and *deform* it — to introduce a parameter $t$ that you can dial,
recovering the classical case at one special value (here $t = 0$) and discovering new structure
everywhere else. The deformed objects are the **shifted $t$-Schur functions** $s_\lambda^Q(t)$,
built from a family of operators (the odd Greaves–Jing–Zhu, or GJZ, operators) that carry the
same anticommutation fingerprint as fermions.

The miracle is that the Giambelli formula survives the deformation *unchanged in shape*:
$$s_\lambda^Q(t) = \operatorname{Pf}\big[\, Y_{\lambda_i - i + j}(t) + Y_{\lambda_j - j + i}(t)\,\big]_{1\le i<j\le k}\cdot \text{vac},$$
where the matrix entries are now built from $t$-dependent operator modes $Y_m(t)$ acting on a
"vacuum" state. The Clifford anticommutation of the GJZ operators is precisely what makes a
Pfaffian — rather than some messier expression — the right tool. The sign law we met earlier
is not decoration; it is the structural reason the formula can exist at all.

Because a Pfaffian is a polynomial of degree exactly $k$ in the matrix entries, a *linear*
deformation $A + tB$ of the entries produces a quantity that is polynomial in $t$ of degree at
most $k$. At $k=2$ this is fully explicit: the deformed Pfaffian expands as
$$\operatorname{Pf}(A + tB) = \operatorname{Pf}(A) + t\cdot(\text{mixed term}) + t^2\cdot\operatorname{Pf}(B),$$
with the classical Schur $Q$-function $s_\lambda^Q(0) = \operatorname{Pf}(A)$ sitting at the
bottom as the constant term, and a clean leading term $\operatorname{Pf}(B)$ on top. The tuning
knob, it turns out, moves the answer along a tame, low-degree path — exactly the kind of
analytic control that makes a deformation useful rather than chaotic.

## A small counting aside, with a moral

There is a charming side-result lurking in the same circle of ideas. How many strict partitions
of $n$ are there, compared with how many partitions there are in total? Call these counts $q(n)$
and $p(n)$. Since every strict partition is in particular a partition, we have $q(n) \le p(n)$.
But for every $n \ge 3$ the inequality is *strict*: $q(n) < p(n)$. The reason is disarmingly
simple — as soon as $n$ is large enough to allow a repeated part (like $1+1$), there exists a
non-strict partition that the strict ones can never account for. The total partition count
$p(n)$ also happens to equal the number of conjugacy classes of the symmetric group $S_n$, so
this little inequality quietly compares two of the most basic counting functions in algebra.
The moral is the recurring theme of the whole story: *distinctness is special*, and the gap
between "all" and "distinct" is exactly the room in which the Pfaffian lives.

## Why it matters

It is tempting to file the Pfaffian under "elegant trick." But its reach is enormous. In
physics, Pfaffians compute the partition functions of dimer models — the statistical mechanics
of molecules tiling a surface — and appear in the famous solution of the two-dimensional Ising
model of magnetism. In quantum field theory they encode the vacuum amplitudes of free fermions.
In algebraic geometry they cut out the spaces of antisymmetric matrices of low rank. In
combinatorics, via the Giambelli formula, they organize the Schur $Q$-functions that index
projective representations. The same three-term expression $A_{12}A_{34} - A_{13}A_{24} +
A_{14}A_{23}$ shows up in all of these, wearing different costumes.

What has been accomplished here is to nail down the algebraic bedrock with complete certainty:
the explicit four-by-four determinant expansion, the square-root identity $\det A =
\operatorname{Pf}(A)^2$ for both the trivial $2\times 2$ and the first nontrivial $4\times 4$
case, the anticommutation sign law, and the recursive Giambelli expansion that lets small
Pfaffians build large ones. These are the load-bearing beams. Everything grander — the general
$2k \times 2k$ identity, the full $t$-deformation, the projective representation theory — is
built on exactly these beams, and now they are known to hold without a single gap.

There is a quiet beauty in that. The square root of a determinant should, by all the usual
rules, lose information. For antisymmetric matrices it does not. It remembers the signs, it
remembers the pairings, it remembers the anticommutation of fermions and the distinctness of
strict partitions. The Pfaffian is mathematics keeping a promise it had no obligation to keep —
and that, more than any single application, is why it is beautiful.
