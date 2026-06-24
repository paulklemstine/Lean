# Tactics: The Tireless Apprentices of Mathematical Proof

## A machine that never gets bored

Every working mathematician knows the feeling. You are deep inside a proof, the
real ideas are humming, and then you hit a wall of *bookkeeping*: a dozen tiny
cases that must each be checked, a sum that must be rearranged, an inequality
that just needs grinding out. None of it is hard. All of it is tedious. And one
slip — a forgotten case, a sign error — can quietly poison the whole argument.

This is exactly the kind of labor a machine should do. Not the inspiration, but
the perspiration. The trick is to package a recurring pattern of reasoning into
a single, reusable command — a *tactic* — that performs the drudgery
automatically and, crucially, performs it *correctly* every single time.

This article tells the story of three such apprentices, each designed for a
different corner of mathematics: one for number theory, one for the strange
"min-plus" algebra called the tropical semiring, and one for estimating the
eigenvalues of a matrix. Each one automates a chore that mathematicians do by
hand thousands of times. And each one comes with a guarantee that it can never
lie to you.

That guarantee is the heart of the matter, so let us start there.

## What it means for an apprentice to be honest

A tactic is, roughly, a little program that transforms one mathematical goal
into another, or finishes it off entirely. The danger is obvious: a buggy tactic
could "prove" something false, and a false theorem at the foundation can topple
an entire edifice. So before we celebrate convenience, we demand *soundness* — a
promise that the tactic only ever closes goals that are genuinely true.

There are two clean ways to keep that promise, and our three apprentices
illustrate both.

The first way is to build the tactic out of pieces that are *already* known to
be honest, so the whole inherits their honesty. The second way is to prove, once
and for all, a single load-bearing theorem — a *soundness certificate* — and
then have the tactic do nothing but invoke that theorem. The first style is like
assembling a tool from trusted parts; the second is like stamping a tool with a
certified safety rating. We will meet one of each.

## Apprentice One: the finite-case checker

The first apprentice is called `number_theory_decide`, and its philosophy is
disarmingly simple. An enormous number of statements in elementary number theory
ultimately reduce to checking *finitely many cases*. Is 97 prime? Check the
candidate divisors. Does some pattern hold for every remainder modulo 6? Check
all six remainders. These are exactly the moments where a human's attention
flags and errors creep in — and exactly where a machine excels.

So `number_theory_decide` is built as a *disjunction of trusted finishers*. In
plain terms, it tries, in order, a handful of well-established decision
procedures: an arithmetic solver for linear facts about integers; a brute-force
evaluator for decidable propositions; a normalizer for numerical equalities and
inequalities; and, when the goal ranges over a finite type, a routine that
splits into every case and checks each one. Because each of those four
ingredients is itself sound, *any* goal the apprentice closes was already
provable by an honest method. Honesty is inherited for free.

But here is the subtle and beautiful point. On its own, a finite-case checker is
not very impressive — it can only handle finite things. The real power emerges
when it is paired with a *reduction*: a mathematical maneuver that turns an
infinite problem into a finite one. The apprentice supplies the muscle; the
mathematician supplies the cleverness of the reduction. Three classic examples
show this partnership in action.

**Example 1: exponential growth outruns squares.** Consider the claim that
$n^2 < 2^n$ for every integer $n \ge 5$. (Check the boundary: $5^2 = 25 < 32 =
2^5$. It works, and the gap only widens.) This is an *infinite* statement — it
must hold for all $n$ — so no finite check can settle it directly. The reduction
here is *mathematical induction*. You prove the base case at $n = 5$, then show
that whenever the inequality holds for some $k$, it must also hold for $k+1$. The
inductive step is genuine algebra: from $k^2 < 2^k$ one argues
$$(k+1)^2 \le k^2 + k^2 < 2^k + 2^k = 2^{k+1},$$
using that $(k+1)^2 \le 2k^2$ once $k$ is large enough. That step needs a real
inequality solver, not a finite check. But the *base interval* — the small
values where the pattern first takes hold — is precisely where the finite-case
checker shines. The division of labor is exact: induction tames the infinity,
and the apprentice mops up the finitely many starting cases.

**Example 2: Fermat's Little Theorem, in miniature.** A jewel of number theory
says that if $p$ is a prime, then $p$ divides $n^p - n$ for *every* integer $n$.
For $p = 5$ this means $5 \mid n^5 - n$; for $p = 7$, $7 \mid n^7 - n$. Again the
statement is infinite — it quantifies over all integers $n$. The reduction this
time is *modular arithmetic*: divisibility by $p$ is the same as vanishing in the
finite world of remainders modulo $p$, a system with exactly $p$ elements. In
that finite world, the claim becomes the crisp identity $x^p = x$ for every one
of the $p$ residues — and *that* is a finite check the apprentice dispatches
instantly. The infinite collapses to the finite the moment you pass to
remainders.

**Example 3: a composite modulus.** The very same trick is not limited to
primes. The fact that $6 \mid n^3 - n$ for every integer $n$ — a favorite of
competition mathematics, since $n^3 - n = (n-1)n(n+1)$ is a product of three
consecutive integers — follows by checking the identity $x^3 = x$ across the six
remainders modulo 6. One reduction, one finite check, done.

The lesson of the first apprentice is a manifesto: **automate the boredom, not
the insight.** The finite check is the only part a machine should own; choosing
the right reduction — induction here, remainders there — remains the
mathematician's art.

## Apprentice Two: the rearranger for min-plus algebra

The second apprentice lives in a stranger country. In ordinary arithmetic we add
and multiply. In *tropical* (or *min-plus*) arithmetic, we replace addition with
*taking the minimum* and replace multiplication with *ordinary addition*. It
sounds like a parlor trick, but this algebra is the secret language of shortest
paths, scheduling, optimization, and even certain neural networks: the cost of
the cheapest route is a giant min-of-sums, which is to say a tropical polynomial.

In this world the familiar distributive law $a \cdot (b + c) = a\cdot b + a \cdot
c$ becomes
$$c + \min(a, b) = \min(c + a,\; c + b).$$
Read it slowly: adding a fixed cost $c$ to the cheaper of two options is the same
as adding $c$ to each and then choosing the cheaper. Obvious once you see it —
and used constantly. The second apprentice, `tropical_simp`, exists to apply this
law, and the laws that the minimum is *associative* and *commutative*
($\min(a,b) = \min(b,a)$ and the order of a nested minimum does not matter),
over and over until an expression is in a clean canonical form.

The mathematical core that makes this honest is a distributivity lemma — call it
the *scalar-fold law*. It says that pushing a constant $c$ inside a whole
*chain* of minimums distributes onto every term at once:
$$c + \min(a_1, a_2, \ldots, a_k) = \min(c + a_1,\; c + a_2,\; \ldots,\; c + a_k).$$
Proving this once, rigorously, certifies that the apprentice's central rewrite
never changes the value of an expression. The remaining cleanup — flattening
nested minimums and sorting their operands into a standard order — rests on the
plain associativity and commutativity of $\min$, including the "left-commutative"
shuffle $\min(a, \min(b, c)) = \min(b, \min(a, c))$ that lets you slide any
operand to the front. Together these turn a tangled min-plus expression into a
tidy, comparable normal form, automatically.

There is an honest boundary worth naming. As built, `tropical_simp` normalizes
the *algebraic* structure — the distribution and the shuffling — but it does not
yet resolve the *order* of unknown operands inside a minimum. When you write
$\min(x, y)$ with $x$ and $y$ symbolic, the machine cannot know which is smaller
without more information. Closing that last gap — by enumerating the finitely
many possible orderings — would turn the rearranger into a complete decision
procedure for min-plus polynomial identities. That is the natural next chapter,
and the groundwork is already laid.

## Apprentice Three: the eigenvalue appraiser

The third apprentice tackles a question from linear algebra that echoes through
physics, engineering, and data science: *how big can the eigenvalues of a matrix
be?* Eigenvalues govern whether a vibrating structure resonates, whether an
iterative algorithm converges, whether a dynamical system is stable. Pinning down
their magnitude is a daily need — and there is a wonderfully cheap way to bound
it without computing the eigenvalues at all.

The idea is a cousin of a classical result called Gershgorin's theorem. Look at
each row of your matrix and add up the *absolute values* of its entries; call
that the row's *absolute row sum*. The claim is that every eigenvalue, in
magnitude, is no larger than the biggest absolute row sum in the whole matrix.
The third apprentice, `spectral_bound`, certifies exactly this estimate.

Why is it true? The argument is a small gem, and it is the apprentice's
soundness certificate. Suppose $\lambda$ is an eigenvalue with eigenvector $v$,
meaning $Mv = \lambda v$ and $v$ is not the zero vector. Among the coordinates of
$v$, pick the one that is largest in absolute value; call its index $i$. Because
$v$ is nonzero, this largest coordinate $|v_i|$ is strictly positive — a fact the
proof genuinely relies on. Now write out the $i$-th line of the equation $Mv =
\lambda v$:
$$\lambda v_i = \sum_j M_{ij}\, v_j.$$
Take absolute values and apply the triangle inequality:
$$|\lambda|\,|v_i| = \Big|\sum_j M_{ij} v_j\Big| \le \sum_j |M_{ij}|\,|v_j|
\le \Big(\sum_j |M_{ij}|\Big)|v_i|,$$
where the last step uses that $|v_j| \le |v_i|$ for every $j$, since $i$ was
chosen to maximize it. Finally divide by the strictly positive number $|v_i|$ to
conclude
$$|\lambda| \le \sum_j |M_{ij}| \le B,$$
where $B$ is any agreed-upon bound on all the absolute row sums. The certificate
is proved.

Notice how the structure mirrors apprentice one: a single, carefully proved
theorem — here the "largest-coordinate" row-sum bound — is the entire source of
trust, and the tactic does nothing but invoke it. To see it in action, take a
concrete $2 \times 2$ matrix; its absolute row sums are easy to add up, and
`spectral_bound` immediately certifies that both eigenvalue magnitudes fall below
that maximum, with a clean corollary controlling the spectral radius.

Here too there is an honest limitation, openly flagged. This is the *weak*
Gershgorin bound: a single disc centered at the origin, large enough to contain
every eigenvalue. The full Gershgorin theorem is sharper — it confines the
eigenvalues to a *union* of smaller discs, one per row, each centered at that
row's diagonal entry. Remarkably, the very same "largest-coordinate" argument
yields the sharper version with only a small algebraic regrouping: move the
diagonal term $M_{ii} v_i$ to the other side before taking absolute values, and
the origin-centered disc becomes a disc centered at $M_{ii}$. The apprentice is
ready to be upgraded.

## The shape of the idea

Step back and the three apprentices rhyme. Each isolates a *mechanical* step —
checking finite cases, applying an algebraic law, invoking one inequality — and
makes that step both effortless and trustworthy. Each draws a sharp line between
the part a machine should own and the part a human must still supply: the
reduction, the formulation, the choice of strategy. And each carries its honesty
on its sleeve, whether inherited from trusted parts or stamped by a single
certified theorem.

This is, quietly, a model for how mathematics and machines can collaborate. Not
the machine replacing the mathematician, and not the mathematician drowning in
clerical work, but a partnership in which the boring-but-error-prone is delegated
to a tireless, honest apprentice — freeing human attention for the only thing it
was ever good at: having ideas.

The drudgery, at last, has somewhere to go.
