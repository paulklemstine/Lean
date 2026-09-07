# The Shape of Taking Things Apart

## How three small rules force every decomposition in mathematics to be unique

There is a habit of mind so deeply built into mathematics that we barely notice
it any more: when something is complicated, break it. Factor the number. Peel
an element off the set. Quotient the group by a normal subgroup. Reduce the
matrix. Simplify the expression. Each time, we take an object, apply an
elementary move that makes it strictly smaller, and repeat until nothing more
can be done.

And each time — remarkably, suspiciously often — the answer does not depend on
the order in which we chose to break things.

Factor $60$ by pulling out $2$ first, then $2$, then $3$, then $5$. Or pull out
$5$ first, then $3$, then $2$, then $2$. Or $3, 2, 5, 2$. Twelve different
orders, one answer: $\{2,2,3,5\}$. Take a finite set and delete its elements
one at a time in any order you like; you always run out after exactly $|S|$
deletions, and you always delete each element exactly once. Take a finite group
and refine a chain of normal subgroups until you cannot refine further; the
Jordan–Hölder theorem says the list of simple pieces you obtain is independent
of every choice you made.

Three theorems from three different parts of mathematics, all saying the same
thing in different accents. The obvious question — and the subject of this
article — is: *what exactly do they have in common?* What is the minimal set of
hypotheses under which "break it apart however you like, you get the same
answer" is a theorem?

The answer turns out to be short. **Three axioms.** And they are not just
sufficient; each one of them is genuinely necessary — drop any single axiom and
the uniqueness collapses, in a concrete, three-element counterexample.

---

## Defining the move before defining the theorem

The instinct when facing a conjecture like "everything decomposes uniquely" is
to charge at the conjecture. That is a mistake. The productive move is to define
the *vocabulary* first, precisely enough that the conjecture becomes a question
with a yes-or-no answer.

So here are the two definitions everything rests on.

A **quotient system** consists of a collection $\alpha$ of objects, a collection
$\Lambda$ of labels, a relation $x \xrightarrow{\ell} y$ read "$y$ is obtained
from $x$ by a quotient step of type $\ell$", and a rank function
$\mathrm{rank} : \alpha \to \mathbb{N}$, subject to three axioms:

1. **Termination.** Every step strictly decreases rank:
   if $x \xrightarrow{\ell} y$ then $\mathrm{rank}(y) < \mathrm{rank}(x)$.
2. **Label determinacy.** The label of a step is determined by its endpoints:
   if $x \xrightarrow{\ell_1} y$ and $x \xrightarrow{\ell_2} y$ then
   $\ell_1 = \ell_2$.
3. **Exchange.** Two *different* steps out of the same object close up into a
   diamond, with the labels swapped: if $x \xrightarrow{\ell_1} y_1$ and
   $x \xrightarrow{\ell_2} y_2$ with $y_1 \neq y_2$, then there exists $z$ with
   $y_1 \xrightarrow{\ell_2} z$ and $y_2 \xrightarrow{\ell_1} z$.

A **quotient step** is precisely one such move $x \xrightarrow{\ell} y$. An
**evolutionary path** from $x$ to $t$ is a finite chain of them,
$$x = x_0 \xrightarrow{\ell_1} x_1 \xrightarrow{\ell_2} \cdots
\xrightarrow{\ell_k} x_k = t,$$
recording the list $\ell_1, \ldots, \ell_k$ of labels used along the way. Call
an object **terminal** if no step leaves it, and call a path **complete** if it
ends at a terminal object.

That is the entire setup. Note what is *not* assumed: no algebra, no group
structure, no topology, no finiteness of the object collection, no assumption
that a step out of $x$ with a given label is unique. Three axioms about an
abstract labelled relation.

Axiom 3 deserves its name. In group theory it is the Zassenhaus "butterfly"
lemma; in rewriting theory it is a labelled form of local confluence. It is the
formal content of the intuition *"if you can do two different things, doing them
in either order lands you in the same place."*

---

## The theorem

> **Decomposition Theorem (abstract Jordan–Hölder).**
> In any quotient system, if $x$ admits two complete evolutionary paths, one
> ending at $t_1$ with label list $L_1$ and one ending at $t_2$ with label list
> $L_2$, then $t_1 = t_2$ and $L_1$ and $L_2$ are equal *as multisets*.

Two complete paths out of the same object reach the same destination and use the
same labels with the same multiplicities. Only the *order* may differ.

The proof is a strong induction on $\mathrm{rank}(x)$, and it is short enough to
sketch honestly. Suppose the first path starts with $x \xrightarrow{\ell_1} y_1$
and the second with $x \xrightarrow{\ell_2} y_2$.

*If $y_1 = y_2$*, label determinacy forces $\ell_1 = \ell_2$, and we recurse at
$y_1$, whose rank is strictly smaller.

*If $y_1 \neq y_2$*, invoke the exchange axiom to obtain $z$ with
$y_1 \xrightarrow{\ell_2} z$ and $y_2 \xrightarrow{\ell_1} z$. Termination
guarantees that $z$ itself has *some* complete path — say with labels $L$ — down
to a terminal object $t$. Now compare the given path out of $y_1$ with the path
$y_1 \xrightarrow{\ell_2} z \rightsquigarrow t$; by induction they agree, so
$L_1$ minus $\ell_1$ equals $\ell_2 :: L$ and $t_1 = t$. Symmetrically
$L_2$ minus $\ell_2$ equals $\ell_1 :: L$ and $t_2 = t$. Hence
$L_1 = \ell_1 :: \ell_2 :: L$ and $L_2 = \ell_2 :: \ell_1 :: L$, and as
multisets these are equal, because a multiset does not remember which of
$\ell_1, \ell_2$ came first. $\blacksquare$

The whole proof is that transposition at the end. Uniqueness of decomposition
is, at bottom, the statement that *two labels commute inside a multiset*.

Because the multiset is the same for every complete path, it is an invariant of
the object. Write $\mathrm{decomp}(x)$ for it. Its basic laws follow at once:

- **One-step law.** If $x \xrightarrow{\ell} y$ then
  $\mathrm{decomp}(x) = \{\ell\} \uplus \mathrm{decomp}(y)$.
- **Terminality.** $x$ is terminal if and only if $\mathrm{decomp}(x)$ is empty.
- **Conservation of labels.** The labels of *any* path from $x$ to $y$ — complete
  or not — form the multiset difference $\mathrm{decomp}(x) - \mathrm{decomp}(y)$.
  The labels of a path depend only on its endpoints, never on the route.

That last item is the abstract reason nothing in a decomposition ever "leaks."
The invariant behaves like a potential energy, and every path is a difference of
potentials.

Two structural corollaries fall out. First, the reachability relation "$y$ lies
somewhere along an evolutionary path out of $x$" is a genuine partial order — no
cycles — and it is **graded**: if $y$ is reachable from $x$, then every
intermediate value of the height $|\mathrm{decomp}|$ between the two is realised
by an actual intermediate stage. Second, evolution is **confluent**: any two
futures of $x$ have a common future, namely the unique terminal object below $x$.

---

## Prime factorisation, rediscovered

Now the payoff of abstraction: instantiate.

Take the objects to be the natural numbers and the labels to be the primes.
Declare $n \xrightarrow{p} m$ to be a step when $p$ is prime, $m > 0$, and
$n = pm$: *divide out one prime*. Take the rank of $n$ to be the number of its
prime factors with multiplicity.

Do the three axioms hold?

Termination: dividing by a prime removes exactly one factor. Label determinacy:
if $pm = qm$ with $m > 0$ then $p = q$ — cancellation. Exchange: if
$n = p_1 m_1 = p_2 m_2$ with $m_1 \neq m_2$, then $p_1 \neq p_2$, and $p_2$
divides $p_1 m_1$; since $p_2$ is prime and does not divide $p_1$, **Euclid's
lemma** gives $p_2 \mid m_1$, say $m_1 = p_2 z$. Then $m_2 = p_1 z$ and the
diamond closes.

The terminal objects are exactly $0$ and $1$. And the Decomposition Theorem,
specialised, reads:

> **Fundamental Theorem of Arithmetic.** Any two lists of primes with the same
> product are permutations of one another.

Uniqueness of prime factorisation is not an independent miracle. It is Euclid's
lemma, wearing the exchange axiom as a costume, pushed through a single abstract
induction. The invariant $\mathrm{decomp}(n)$ is the prime factorisation; its
size is $\Omega(n)$, the number of prime factors with multiplicity; and the
multiplicity of the label $p$ inside it is exactly the $p$-adic valuation
$v_p(n)$.

Reachability, in this instance, is divisibility: for positive $m, n$, one can
evolve $n$ down to $m$ if and only if $m \mid n$.

The same machine, fed a different instance, gives combinatorics: let the objects
be finite subsets of some ambient type and let $S \xrightarrow{a} S \setminus
\{a\}$ delete one element. The three axioms are immediate, the terminal object
is $\varnothing$, and $\mathrm{decomp}(S) = S$. The theorem then says: every
complete deletion sequence uses each element exactly once, and has length $|S|$.
Elementary — but *the same theorem*.

And the two instances are linked. The map $S \mapsto \prod_{p \in S} p$, from
finite sets of primes to natural numbers, sends deletion steps to division
steps. Decomposition invariants transport along such maps, and one immediately
deduces that the prime factorisation of $\prod_{p \in S} p$ is exactly $S$ —
hence that a product of distinct primes is squarefree, and that distinct sets of
primes have distinct products, without a single multiplicative computation.

---

## Every axiom earns its place

It is easy to write down axioms; it is harder to show none is redundant. All
three are necessary, and the witnesses are tiny.

**Exchange is necessary.** On the three objects $0, 1, 2$, allow the steps
$0 \to 1$, $1 \to 2$, and the shortcut $0 \to 2$, with a single label. Rank
decreases, labels are trivially determined — but the pair of steps $0 \to 1$ and
$0 \to 2$ does not close into a diamond. And indeed uniqueness fails
spectacularly: there are two complete paths from $0$ to $2$, of *lengths $2$ and
$1$*. Not merely different orders: different sizes. No invariant can exist.

**Label determinacy is necessary.** On the two objects $0, 1$, allow the single
move $0 \to 1$ but permit it to carry either of two labels. Termination holds;
exchange holds vacuously (there is only one possible target, so the hypothesis
$y_1 \neq y_2$ is never met). Yet there are two complete paths out of $0$ with
*different* label multisets. Uniqueness of destination survives; uniqueness of
labels does not.

**Termination is necessary.** On a single object with a self-loop, label
determinacy and exchange both hold trivially. But no path ever reaches a
terminal object, so "the multiset of labels of a complete path" refers to
nothing at all. There is no invariant to be unique.

---

## How faithful is the shadow?

Every quotient system maps into one master example: multisets of labels, where a
step deletes one element. The invariant $\mathrm{decomp}$ *is* this map, and it
carries steps to deletions and paths to deletion sequences. So the theory has a
universal target — every evolutionary process is a shadow of multiset deletion.

The natural bold conjecture is that the shadow is faithful: that
$\mathrm{decomp}$ tells apart the distinct stages reachable from a fixed
starting object. **This is false.** Consider the four objects $3 \to \{1,2\} \to
0$, all steps sharing a single label — a diamond. Both $1$ and $2$ are reachable
from $3$, both are distinct, and both have invariant $\{\ell\}$.

What goes wrong is identifiable, and repairing it is a theorem. Call a system
**separated** if a step is determined by its source *and its label*: $x
\xrightarrow{\ell} y_1$ and $x \xrightarrow{\ell} y_2$ force $y_1 = y_2$. The
diamond is exactly the failure of separation. And under separation one can prove
a strong **pull-forward lemma**: any label used *somewhere* along a path can be
brought to the *front* of that path, the rest rearranging accordingly. Iterating
it shows that the endpoint of a path depends only on the *multiset* of labels
used — so the invariant does separate the stages of a future after all.

Applied to arithmetic (which is separated, by cancellation), this says
$m \mid n$ if and only if the factorisation multiset of $m$ is contained in that
of $n$, and a positive integer is *determined* by its factorisation.

---

## Which futures exist?

Injectivity is half of a classification. The other half is surjectivity: is
every sub-multiset of $\mathrm{decomp}(x)$ realised by an actual stage?

Not automatically. In the two-step chain $2 \xrightarrow{b} 1 \xrightarrow{a}
0$, the label $a$ belongs to $\mathrm{decomp}(2) = \{a, b\}$, but no $a$-step
leaves $2$. The missing hypothesis is **saturation**: a label available one step
later was already available now. Under saturation, every label in
$\mathrm{decomp}(x)$ is available immediately, and by induction every
sub-multiset of $\mathrm{decomp}(x)$ is realised.

> **Classification of Futures.** In a separated, saturated quotient system, the
> stages reachable from $x$ are in bijection with the sub-multisets of
> $\mathrm{decomp}(x)$ — the bijection being $\mathrm{decomp}$ itself.

Read in arithmetic, this is the classical statement that the divisors of $n$
correspond bijectively to the sub-multisets of its prime factorisation. Read on
finite sets, it says the stages reachable from $S$ are exactly its subsets.

Saturation buys one more thing: **every ordering is realised**. The label lists
of complete paths out of $x$ are *exactly* the lists whose multiset is
$\mathrm{decomp}(x)$ — that is, exactly the permutations of the invariant. For
$n = 60$ that recovers the twelve factorisation chains we started with, and
predicts the count $4!/(2!\,1!\,1!) = 12$ in general.

---

## Arithmetic functions as conserved potentials

Finally, a change of viewpoint that makes the invariant look physical. Fix a
weight $w$ on labels. Define the **path weight** of $x$ as the product of $w$
over $\mathrm{decomp}(x)$, and the **path action** as the sum. Then a single
step multiplies (respectively increments) the potential by the weight of its
label, and the weight accumulated along *any* path from $x$ to $y$ is the ratio
(respectively difference) of the potentials at its endpoints. The label
conservation law becomes a conservation law in the physicist's sense: the
accumulated action is path-independent.

In the arithmetic instance this pins down two classical families exactly:

> A function $g$ on positive integers satisfies $g(1) = 1$ and $g(mn) = g(m)g(n)$
> for all positive $m, n$ **if and only if** $g$ is the path weight of its own
> restriction to the primes. A function $f$ satisfies $f(mn) = f(m) + f(n)$
> **if and only if** $f$ is the path action of its restriction to the primes.

Completely additive and completely multiplicative arithmetic functions are
precisely the conserved potentials of the multiplicative evolutionary flow.
Taking the constant weight $1$ recovers $\Omega$; taking the indicator of a
single prime $p$ recovers the $p$-adic valuation $v_p$.

---

## The moral

Mathematics accumulates uniqueness theorems the way a coastline accumulates
driftwood: prime factorisation, Jordan–Hölder, invariant factors, normal forms,
canonical decompositions of every stripe. It is tempting to treat each as a
local accident of its own subject.

It is not. Strip away the algebra and what remains is a labelled relation with
three properties — it terminates, its labels are pinned down by their endpoints,
and its diamonds close. Those three properties *force* uniqueness, and nothing
weaker will do. Everything else — the primes, the simple groups, the elements of
a set — is decoration on a single combinatorial skeleton whose deepest fact is
that in a multiset, order does not exist.
