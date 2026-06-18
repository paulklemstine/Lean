# The Hidden Wall Between Base 2 and Base 3

## A puzzle about numbers that look different in different bases

Pick a number — say, the digits of some endless, never-repeating sequence — and
write it down twice. The first time, use the binary system that computers love,
where everything is built from 0s and 1s. The second time, use base 3, where the
only digits are 0, 1, and 2. You now have two descriptions of the same object.

Here is a question that sounds almost too simple to be interesting: *can a
sequence be genuinely simple in both descriptions at once?*

By "simple" we will mean something very precise in a moment. But the rough idea
is this. Some sequences are so regular that a tiny machine — a gadget with a
handful of internal states — can spit out their digits one at a time, just by
reading the position number fed to it in binary. The famous Thue–Morse sequence
(0, 1, 1, 0, 1, 0, 0, 1, …, where the *n*-th term is the parity of the number of
1s in the binary expansion of *n*) is exactly this kind of sequence. It looks
chaotic, it never settles into a repeating pattern, yet a four-line program
generates it effortlessly. We call such sequences **2-automatic**: a finite
automaton, reading positions in base 2, produces them.

You can play the same game in base 3, base 5, base 10 — any base *k* ≥ 2. A
sequence is *k*-automatic if a finite machine reading position numbers in base
*k* generates it.

Now we can sharpen the puzzle. In 1972, the mathematician Alan Cobham proved a
startling theorem: **if a sequence is both 2-automatic and 3-automatic, then it
must be boring.** Not "complicated in a different way" — actually boring, in the
technical sense of *eventually periodic*. After some finite preamble, it simply
repeats the same block forever, like 0, 1, 0, 1, 0, 1, … . The only sequences
that two genuinely different bases agree are simple are the sequences that were
trivially simple to begin with.

This is Cobham's theorem, and it is one of the most beautiful "you can't have it
both ways" results in mathematics. It says that base 2 and base 3 are, in a deep
sense, *incompatible witnesses*. A nontrivial sequence can be simple in one of
them, but never both.

## Why "2 and 3" and not "2 and 4"?

There is a catch hiding in that statement, and it is the heart of this article.

Cobham's theorem is *not* true for every pair of bases. Consider base 2 and base
4. These are not really different bases at all: 4 is just 2 squared. Two binary
digits package together into exactly one base-4 digit. Anything a base-2 machine
can do, a base-4 machine can do, and vice versa, with only cosmetic rewiring. So
a sequence can absolutely be both 2-automatic and 4-automatic while remaining
wild and aperiodic. The Thue–Morse sequence itself is one.

So the theorem needs a precise condition on the pair of bases. The condition
Cobham identified is called **multiplicative independence**. Bases *j* and *k*
are multiplicatively *dependent* if some power of one equals some power of the
other:

> *j* and *k* are **multiplicatively dependent** when there exist positive whole
> numbers *a* and *b* with *j*ᵃ = *k*ᵇ.

Base 2 and base 4 are dependent, because 2² = 4¹. Base 8 and base 32 are
dependent, because 8⁵ = 2¹⁵ = 32³. But base 2 and base 3? No matter how high you
raise them, a power of 2 is never a power of 3 — 2, 4, 8, 16, 32, … never meets 3,
9, 27, 81, … . They are multiplicatively *independent*, and that is exactly why
Cobham's theorem bites for them.

Strip everything else away and you find that the entire force of Cobham's theorem
rests on a single arithmetic fact: **2 and 3 do not share a common power.** If
they did, the theorem would be vacuous — there would be no genuinely independent
pair to test it on. The wall between base 2 and base 3 is real, and this article
is about the bricks it is made of.

## The relation that governs everything

Let us name the central character. For two bases *j* and *k* (each at least 2),
define the relation

> **MultDep *j* *k***: there exist *a* > 0 and *b* > 0 with *j*ᵃ = *k*ᵇ.

This little relation turns out to have a remarkably clean structure. It behaves
exactly like an "equal up to scaling" relation — what mathematicians call an
*equivalence relation*. Three properties make that precise, and each is worth
seeing.

**It is reflexive.** Every base is dependent with itself: take *a* = *b* = 1, and
*j*¹ = *j*¹. A base shares a common power with itself, trivially. This is the kind
of statement that is obvious but still has to be said.

**It is symmetric.** If *j* and *k* are dependent, then so are *k* and *j*. The
proof is almost a joke: if *j*ᵃ = *k*ᵇ, just read the equation backwards as
*k*ᵇ = *j*ᵃ and swap the roles of the witnesses. Dependence does not care which
base you mention first.

**It is transitive.** This is the only part with any real content. Suppose *j* is
dependent with *k*, and *k* is dependent with *l*. Can we conclude *j* is
dependent with *l*? We have two equations,

> *j*ᵃ = *k*ᵇ  and  *k*ᶜ = *l*ᵈ,

with different exponents. The trick is to find a common power of *k* that both
equations can speak to. Raise the first to the *c*-th power and the second to the
*b*-th power:

> *j*^(*ac*) = *k*^(*bc*) = (*k*ᶜ)ᵇ = (*l*ᵈ)ᵇ = *l*^(*db*).

So *j*^(*ac*) = *l*^(*db*), with both exponents positive — exactly the witness we
needed. Dependence chains together. This is pure bookkeeping with exponents, no
deep number theory required, and it is the engine that makes the whole relation
an equivalence.

Once you know the relation is reflexive, symmetric, and transitive, it carves the
bases into clean families. Within a family, every base is a common power of one
underlying number: the family of {2, 4, 8, 16, 32, …} are all powers of 2, the
family of {3, 9, 27, …} are all powers of 3, and so on. Powers of a fixed base
are always dependent — *j*ᵐ and *j*ⁿ share the common power *j*^(*mn*), reachable
as (*j*ᵐ)ⁿ or (*j*ⁿ)ᵐ. Cobham's theorem fires precisely when two bases live in
*different* families.

## The barrier: coprime bases can never agree

Now for the punchline, the theorem that gives Cobham's result its teeth. It
concerns *coprime* bases — bases that share no common prime factor, like 2 and 3,
or 3 and 10, or 6 and 35.

> **The Barrier.** If a base *j* ≥ 2 is coprime to *k*, then *j* and *k* are
> never multiplicatively dependent.

The reasoning is elegant and short. Suppose, for contradiction, that they *were*
dependent, so *j*ᵃ = *k*ᵇ for some positive *a*, *b*. Since *j* ≥ 2, it has at
least one prime factor — call it *p*. Then *p* divides *j*, so *p* divides *j*ᵃ.
But *j*ᵃ equals *k*ᵇ, so *p* divides *k*ᵇ as well. A prime that divides a power of
*k* must divide *k* itself. So *p* divides both *j* and *k*. That is impossible:
coprime numbers share no prime factor. The contradiction means no such equation
can exist. The bases are independent.

Notice how little we assumed. We did not even need *k* ≥ 2; the argument rules out
dependence one-sidedly, from the structure of *j* alone. The barrier is sharp.

And specializing to the most famous case gives the keystone:

> **2 and 3 are multiplicatively independent.**

There is an even more elementary way to see this one, a proof a curious teenager
could find. Suppose 2ᵃ = 3ᵇ with *a*, *b* > 0. Look at both sides modulo 2. The
left side, 2ᵃ, is even — it leaves remainder 0. The right side, 3ᵇ, is a product
of odd numbers, hence odd — it leaves remainder 1. An even number cannot equal an
odd number. Done. The wall between base 2 and base 3 is, at bottom, the wall
between even and odd.

## Why the analytic detour is a trap

There is a tempting alternative way to phrase multiplicative dependence, one that
shows up in many textbooks. Bases *j* and *k* are dependent if and only if the
ratio of their logarithms, log *j* / log *k*, is a rational number. After all,
*j*ᵃ = *k*ᵇ is the same as *a* log *j* = *b* log *k*, which rearranges to
log *j* / log *k* = *b* / *a*.

This is true, and it is illuminating — it ties the question to the deep theory of
when logarithms are rational or irrational. But as a *foundation*, it is a trap.
The moment you write "log," you have summoned the entire apparatus of real
analysis: limits, the exponential function, the irrationality of real numbers.
For integer bases of size at least 2, all of that machinery is overkill. The
honest content of "multiplicative dependence" is the bare equation *j*ᵃ = *k*ᵇ,
an arithmetic statement about whole numbers that even-versus-odd can settle. The
lesson, learned the hard way, is that choosing the right *level of abstraction*
can collapse a problem from analytic to elementary. The purely multiplicative
form is equivalent for our purposes and incomparably more tractable.

## The bigger picture: two faces of one coin

Cobham's theorem sits at a crossroads of two ways of thinking. One is *geometric*:
you can measure how cheaply one computational model simulates another, how much
"distortion" a base change introduces, how rigidly the structure of a sequence is
pinned down. The other is *arithmetic*, the side we have explored here: whether a
finite, well-behaved translation between two bases can exist *at all*.

These two faces meet in a single principle. A base change is an honest, bounded
simulation precisely when the two bases are multiplicatively dependent — when they
belong to the same family, powers of a common root. The geometric side asks *how
expensive* the translation is; the arithmetic side asks *whether it can exist*.
The barrier theorem answers the second question for coprime bases with a flat
*no*. That "no" is the load-bearing wall of Cobham's entire edifice.

## A normal form, just out of reach

The relation we have studied splits bases into families, and within each family
every base is a power of a single underlying number. This suggests a clean
classification, a *normal form*:

> **Conjecture.** Two bases *j*, *k* ≥ 2 are multiplicatively dependent if and
> only if there is a common root *g* ≥ 2 and positive exponents *p*, *q* with
> *j* = *g^p* and *k* = *g^q*.

In words: dependent bases are exactly the bases that are common powers of one
primitive integer. The "if" direction is easy — if *j* = *g^p* and *k* = *g^q* then
*j*^q = *g*^(*pq*) = *k*ᵖ. The "only if" direction is where the work lies: from the
single equation *j*ᵃ = *k*ᵇ, one must reconstruct the shared root *g* by comparing
the prime factorizations of *j* and *k* and showing their exponent patterns are
proportional. Proving it would upgrade the qualitative barrier into a precise
quantitative normal form — and bring a full, self-contained account of Cobham's
theorem within reach.

## The moral

It is easy to think of base 2 and base 3 as two interchangeable lenses on the same
numbers, mere notational conveniences. Cobham's theorem says otherwise. The two
bases are *incompatible witnesses*: a sequence simple in both is necessarily
trivial, and the reason is the unbridgeable arithmetic gap between powers of 2 and
powers of 3. That gap, in turn, is just the ancient fact that no power of 2 is
ever odd.

There is something deeply satisfying about this. A theorem about exotic
self-generating sequences and finite automata — the stuff of theoretical computer
science — turns out to rest on a fact a child could verify by counting on their
fingers. The wall between base 2 and base 3 was there all along, hiding in plain
sight, in the difference between even and odd.
