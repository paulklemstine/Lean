# The Secret Handshake Between Dependency and Randomness

## Two worlds that should never have met

Mathematics is full of ideas that grow up on opposite sides of town and never
realize they are cousins. Two such ideas are *closure* and *extraction*.

**Closure** is the mathematics of dependency. When you take a handful of facts
and ask "what else is now forced to be true?", you are computing a closure. When
you take a few vectors and ask "what is the whole space they span?", that is a
closure. When a database knows that *employee → department* and *department →
building*, and concludes *employee → building*, it has computed a closure. The
operation that takes a set of starting points and returns everything they drag
along with them is the unifying abstraction behind logic, linear algebra,
geometry, and the theory of relational databases.

**Extraction** is the mathematics of purifying randomness. Imagine a noisy,
biased, partly-predictable source of random bits — radioactive decay timings,
mouse movements, the low-order bits of a microphone. A *seeded extractor* is a
small public algorithm that, with the help of a short truly-random "seed,"
squeezes out bits that look perfectly uniform. Extractors are the workhorses of
modern cryptography, derandomization, and privacy: they are how we turn messy
entropy into clean, usable secrets.

These two subjects use different words, different journals, and different
intuitions. This article is about a precise, machine-checked bridge between them.
It says, roughly:

> **A family of dependency-respecting *tests* can tell members of a structure
> apart exactly when a family of *seeded extractors* can — and you can convert
> either one into the other by an explicit recipe.**

That sentence sounds like a slogan. The point of the work behind this article is
that it is a *theorem*, stated with complete precision and verified down to the
last logical step. Let us build it up from scratch.

## Closure operators: the geometry of "what comes along"

Fix a finite universe of objects, call it $X$. A **closure operator** is a rule
$\operatorname{cl}$ that takes any subset $A \subseteq X$ and returns a (usually
larger) subset $\operatorname{cl}(A)$, obeying three commandments:

1. **Extensivity:** $A \subseteq \operatorname{cl}(A)$. You never lose anything;
   closure only adds.
2. **Monotonicity:** if $A \subseteq B$ then
   $\operatorname{cl}(A) \subseteq \operatorname{cl}(B)$. Starting from more,
   you finish with at least as much.
3. **Idempotence:** $\operatorname{cl}(\operatorname{cl}(A)) =
   \operatorname{cl}(A)$. Once you have closed something, closing it again does
   nothing.

These three rules are deceptively spare, yet they are satisfied by the span of
vectors, the convex hull of points, the deductive closure of axioms, the
down-closure in a partial order, and the "all attributes determined by a set of
attributes" operation in database theory. They are the common skeleton of
*dependency*.

A set $C$ is **closed** when it is already its own closure:
$\operatorname{cl}(C) = C$. Closed sets are the "saturated" configurations — the
ones that have already absorbed everything they imply. A first small but telling
fact: **the closure of *anything* is closed.** Apply $\operatorname{cl}$ once and
you land in the world of fixed points; idempotence guarantees you stay there.

To measure how far a set is from being saturated, define its **deficiency**:
$$
\operatorname{def}(A) = |\operatorname{cl}(A)| - |A|,
$$
the number of extra elements the closure drags in. A closed set has deficiency
zero — it pulls in nothing new, because there is nothing new to pull. Turning
this around, we can define an **entropy surrogate**
$|X| - \operatorname{def}(A)$, a quantity that is maximal (equal to the size of
the whole universe) exactly on closed sets. The vocabulary is chosen on purpose:
closed sets behave like *carriers of full information*, while deficiency behaves
like *information lost to dependency*. Hold that thought; it is the hinge of the
whole bridge.

## Tests that respect dependency

Now we want to *probe* the universe $X$ with simple yes/no questions. A
**predicate** is just a function $\varphi : X \to \{\text{true}, \text{false}\}$.
But not every predicate is fair game. If two elements $x$ and $y$ are
*indistinguishable from the point of view of dependency*, a respectful test
should not be allowed to separate them artificially.

We make this precise. Say $x$ and $y$ are **closure-equivalent** when their
single-element closures coincide,
$\operatorname{cl}(\{x\}) = \operatorname{cl}(\{y\})$. In the database picture,
two attributes are closure-equivalent when each determines exactly the same set
of other attributes; in the linear-algebra picture, two vectors are
closure-equivalent when they span the same line. A predicate $\varphi$ is
**closure-stable** if it never distinguishes closure-equivalent elements:
whenever $\operatorname{cl}(\{x\}) = \operatorname{cl}(\{y\})$ we must have
$\varphi(x) = \varphi(y)$.

Closure-stable predicates are the legitimate measuring instruments of a
dependency structure. They are the analog, on the extractor side, of *seed
tests*: simple bit-valued probes that respect the underlying entropy structure.

Given a whole family of such tests $\Phi = (\varphi_1, \dots, \varphi_n)$, each
element $x$ acquires a **fingerprint**: the binary string
$$
\operatorname{enc}(x) = \big(\varphi_1(x), \varphi_2(x), \dots, \varphi_n(x)\big)
\in \{\text{true},\text{false}\}^n.
$$
This is the *encoding map*. It compresses an object into the sequence of answers
it gives to our battery of dependency-respecting questions.

## What it means to "separate"

The single most important question we can ask of a family of tests is: **does it
tell things apart?** But — and this is the crucial design choice — we only demand
that it tell things apart *inside large closed sets*, the saturated
configurations where all the dependency has been absorbed.

Formally, fix a threshold $k$. A predicate family $\Phi$ is said to
**$k$-separate** if, for every closed set $C$ with at least $k$ elements and
every pair of distinct $x, y \in C$, *some* test in the family answers them
differently:
$$
\exists\, i,\quad \varphi_i(x) \neq \varphi_i(y).
$$

The reason to restrict attention to large closed sets is exactly the entropy
intuition: those are the sets that carry the most information, and separating
their elements is the genuinely hard, genuinely useful task. Separating
deficient sets is comparatively cheap.

There is an immediate and satisfying reformulation, and it is the first theorem
of the framework:

> **Encoding–Separation Equivalence.** A predicate family $k$-separates *if and
> only if* its fingerprint map $\operatorname{enc}$ is injective on every closed
> set of size at least $k$ — that is, distinct elements of a large closed set
> always receive distinct fingerprints.

The proof is a clean unwinding of definitions: "some coordinate disagrees" is
literally the negation of "the whole fingerprint vectors agree." But the
*content* is conceptual. It says separation is not some delicate analytic
property; it is exactly injective fingerprinting. Tell-things-apart equals
label-them-uniquely. This is the same principle that underlies hashing,
checksums, and error-correcting codes, here pinned down for dependency
structures.

## Enter the extractor

On the cryptographic side of the dictionary we replace a *list of tests* with a
*seed-indexed family of maps*. A function
$$
f : \text{Seed} \times X \to Y
$$
takes a seed $s$ and an object $x$ and produces an output $f(s, x)$ in some
output space $Y$. Think of $s$ as the short random string that selects which
hash function to use, and $f(s, \cdot)$ as the resulting extractor.

This family **$k$-separates on closed sets** if, for every large closed set and
every pair of distinct elements in it, *some seed* drives them to different
outputs:
$$
\exists\, s,\quad f(s, x) \neq f(s, y).
$$

There is also a fairness condition mirroring closure-stability. A seed family is
**closure-compatible** if every seed respects closure-equivalence:
whenever $\operatorname{cl}(\{x\}) = \operatorname{cl}(\{y\})$, then
$f(s, x) = f(s, y)$ for every seed $s$. No seed is allowed to invent a
distinction that the dependency structure forbids.

We now have two languages for the same notion of "telling apart inside saturated
sets": *predicate families* and *seed families*. The bridge theorem says the two
languages are interchangeable.

## The duality, both ways

**From tests to seeds (the easy direction).** Suppose we already have a
closure-stable predicate family $\Phi$ that $k$-separates. Then there is a seed
family that $k$-separates too — and we barely have to do any work. Use a *single*
seed, and let that one seed's map be the entire fingerprint:
$f(\,\cdot\,, x) = \operatorname{enc}(x)$. Since the fingerprint is injective on
large closed sets (by Encoding–Separation Equivalence), distinct elements get
distinct outputs, so this lone seed already separates. Many tests collapse into
one richly-valued extractor.

**From seeds to tests (the substantive direction).** Now suppose we have a
closure-compatible seed family $f$ over finite seed and output spaces, and it
$k$-separates. We want to manufacture closure-stable *predicates* that
$k$-separate. Here is the recipe. For every pair $(s, y)$ consisting of a seed
$s$ and a possible output value $y$, build the indicator test
$$
\varphi_{s,y}(x) \;=\; \big[\, f(s, x) = y \,\big],
$$
which asks "under seed $s$, does $x$ land on the value $y$?" Two facts make this
work. First, each $\varphi_{s,y}$ is closure-stable, *precisely because* $f$ is
closure-compatible — equivalent elements give the same $f(s, \cdot)$, hence the
same indicator answer. Second, this family separates: if seed $s$ sends $x$ and
$y$ to different outputs, then with $y^\star = f(s, x)$ the test
$\varphi_{s, y^\star}$ answers true on $x$ and false on $y$. The finite seed and
output spaces guarantee we only build finitely many predicates.

Put the two directions together and you get the headline result:

> **Closure–Extractor Duality.** Over a finite universe with a closure operator,
> the existence of a closure-stable predicate family that $k$-separates is
> equivalent to the existence of a (closure-compatible) seed family that
> $k$-separates. Separating power is the same resource, whether you spend it on
> dependency-respecting tests or on seeded extractors.

## From a table of numbers to a working extractor

The duality is not merely an existence statement. It comes with a
*constructive*, certified counterpart that turns raw data into an algorithm.

Imagine all you are handed is a **separation matrix** $M$: rows indexed by tests,
columns by elements of $X$, entries $M_{i}(x) \in \{0,1\}$, with the single
guarantee that within every large closed set, distinct columns differ in at least
one row. This is exactly the data a working engineer might collect by running a
battery of probes.

> **Certified Reconstruction.** From any such separation matrix one can build an
> explicit seed family that achieves the same separation, where each object is
> simply mapped to its own column vector. No search, no nondeterminism: the
> reconstruction is a direct formula, and it is guaranteed to separate exactly
> the sets the matrix separated.

In effect, a passive *table of measurements* is upgraded into an active
*extractor* by a mechanical procedure. The matrix's columns *are* the extracted
fingerprints; reading them off is the algorithm. This is the part of the story
that an applied cryptographer or a database engineer would actually run.

## Why an engineer should care

Strip away the abstraction and the duality is a statement about a resource that
shows up everywhere: **the ability to assign unique labels that respect an
underlying structure.**

- **Databases.** A relational schema comes with functional dependencies, and
  their closure decides which sets of attributes are *keys* — minimal sets whose
  values uniquely identify a row. Closure-stable predicates that separate large
  closed sets are exactly tests that respect the schema's dependencies while
  still distinguishing records. The duality says you can repackage such a test
  suite as a seeded fingerprinting scheme, and reconstruct one from a table of
  observed separations.

- **Cryptography and hashing.** Seeded extractors and universal hash families
  live or die by their ability to separate inputs. The duality re-describes that
  separating power in the structural language of closure, and the reconstruction
  theorem shows that an empirically-verified separation table can be promoted to
  a certified scheme.

- **Machine learning and feature selection.** A set of features induces an
  equivalence on data points (two points are equivalent if all features agree).
  Closure-equivalence is the structural version of this, and closure-stable
  predicates are features that respect a known dependency structure. Separation
  is the ability of a feature set to distinguish samples — and the duality says
  this can be traded freely between "a list of features" and "a randomized,
  seed-selected feature."

The common thread is that *separation is a conserved currency*. Whether you store
it as a list of structural tests or as a family of seeded maps, the total power
to tell things apart is the same, and there are explicit exchange rates in both
directions.

## The shape of certainty

Every claim above — the closure laws, the deficiency identity, the
encoding–separation equivalence, both halves of the duality, and the certified
reconstruction — has been proved with complete rigor, with no gaps and no
hand-waving. There is no "it is easy to see" hiding a subtle error, because every
step has been checked.

That level of certainty matters most precisely at a bridge like this one. When
you claim that two fields are secretly the same, the danger is always that the
correspondence is *almost* right — that it works on examples but quietly breaks
on an edge case, a degenerate closure, an empty set, a tie. A fully verified
duality removes that doubt. The handshake between dependency and randomness is
real, it is exact, and now it is permanent.

What began as a slogan — *tests that respect structure separate exactly when
seeded extractors do* — has become a small, sturdy theorem you can build on. And
the most beautiful thing about bridges is that, once built, traffic flows both
ways: every advance in the theory of extractors becomes a statement about
dependency, and every insight about closure becomes a tool for extraction.
