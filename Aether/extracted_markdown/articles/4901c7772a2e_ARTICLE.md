# Close Proofs: How "Distance" in a World Without Decimals Becomes a Universal Translator

## A strange kind of nearness

Ask anyone what it means for two things to be *close* and they will reach for a
ruler. Two cities are close if the highway between them is short. Two numbers are
close if their difference is small. Closeness, we are taught from childhood, is a
matter of degree: a little gap, a bigger gap, a huge gap, and somewhere out there,
infinity.

But there is another, stranger notion of nearness — one that runs the engines of
number theory, lattice-based cryptography, and certified machine learning — in
which distance behaves nothing like a ruler. In this world the triangle
inequality, that humble schoolbook fact that "a detour is never shorter than the
direct route," is replaced by something far more rigid:

> **The strong triangle inequality.** The distance from A to C is never larger
> than the *larger* of the two legs A-to-B and B-to-C.

In symbols, ordinary geometry says `d(A, C) ≤ d(A, B) + d(B, C)`. The strange
geometry says `d(A, C) ≤ max(d(A, B), d(B, C))`. The plus has become a max.

Spaces obeying this stronger law are called **ultrametric**, and they are full of
counterintuitive delights. Every triangle is isosceles. Every point inside a ball
is its center. Balls do not gently overlap — they are either nested or completely
disjoint, like Russian dolls that refuse to touch. These are not pathological
curiosities; they are exactly the geometry of the *p-adic numbers*, the
alternative number systems that have become indispensable in modern arithmetic.

This article is about a precise, machine-checked bridge between this strange
geometry and an equally strange algebra — **tropical mathematics** — and about
why the bridge is not a mere translation dictionary but a *quantitative functor*:
a structure-preserving machine that carries numerical guarantees, untouched, from
one world to the other.

## The tropical world: where plus is max and times is plus

Tropical mathematics — named, with a wink, after the Brazilian mathematician
Imre Simon — rewrites arithmetic with two audacious substitutions. In the
**min-plus** (or its mirror, **max-plus**) semiring, you replace ordinary
addition by *taking the maximum*, and ordinary multiplication by *ordinary
addition*:

- `a ⊕ b := max(a, b)`  (tropical "addition")
- `a ⊗ b := a + b`       (tropical "multiplication")

At first this looks like a typo. But it is wildly useful. Shortest-path problems,
scheduling, the asymptotics of polynomials, the combinatorics of polytopes — all
of these simplify dramatically when you squint at them through tropical glasses,
because the tropical operations are exactly what survive when you track only the
*leading order* of a quantity. Tropical addition is idempotent (`a ⊕ a = a`),
which means there is no "carrying," no cancellation, no subtraction-induced
surprises. It is arithmetic stripped down to a skeleton of order.

The central object in our story is a **tropical valuation object**: a set
equipped with these tropical operations and a compatible order, distilled to its
essential axioms. The crucial one is the *tropical addition law*: addition
literally equals the max operation, `a ⊕ b = max(a, b)`. Everything else —
commutativity, associativity, idempotence, the existence of a tropical zero and a
tropical one — follows the pattern of a linearly ordered, additively idempotent
commutative monoid.

## Valuations: the bridge's first plank

Where does a tropical valuation come from in real mathematics? From *valuations*.

Fix a prime number `p`. Every nonzero rational number `q` can be written
uniquely as `p^k · (a/b)` where `a` and `b` are not divisible by `p`. The
exponent `k` is the **p-adic valuation** of `q`, written `v_p(q)`. For example,
with `p = 3`: the number `q = 18 = 2 · 3^2` has `v_3(18) = 2`, while
`q = 5/27 = 5 · 3^{-3}` has `v_3(5/27) = -3`.

The p-adic valuation has a remarkable property. The valuation of a sum is *at
least* the minimum of the valuations:

> `v_p(x + y) ≥ min(v_p(x), v_p(y))`.

This is the tropical strong-additivity law in disguise. And it is exactly the
fingerprint of ultrametric geometry, because if we *exponentiate* the valuation
to get a size — the **p-adic norm** `|q|_p := p^{-v_p(q)}` — the inequality flips
through the order-reversing map `t ↦ p^{-t}` into

> `|x + y|_p ≤ max(|x|_p, |y|_p)`.

There it is: the strong triangle inequality. A high valuation means a *small*
norm; a number deeply divisible by `p` is tiny in the p-adic world. The map that
turns a tropical valuation into an ultrametric size is, conceptually,
exponentiation — `t ↦ exp(−t)` or `t ↦ p^{−t}` — an order-isomorphism that
carries `(addition, min)` onto `(multiplication, max)`. This single observation
is the heart of the bridge: *tropical min-superadditivity is the same fact as
the ultrametric strong triangle inequality, viewed through an exponential
mirror.*

## From a dictionary to a machine

It is one thing to notice that two structures rhyme. It is another to prove,
rigorously and once and for all, that *every* construction, *every* numerical
bound, and *every* morphism on one side has a faithful counterpart on the other.
That is what this work does, and it does it in a form a computer can verify line
by line.

The central construction is a function we call **valuation reconstruction**.
Feed it a *tropical valuation carrier* — an abstract algebraic object with
addition, negation, multiplication, and a valuation function `val` satisfying

- `val(0) = 0`,
- `val(−x) = val(x)`  (the valuation is blind to sign),
- `val(x · y) = val(x) · val(y)`  (it is multiplicative),
- `val(x + y) ≤ max(val(x), val(y))`  (the strong, tropical additivity law),

and it returns a bona fide **ultrametric seminorm object**: a space whose
"norm" satisfies precisely the ultrametric axioms. The reconstruction is, in a
sense, almost too simple — the new norm *is* the old valuation — but the content
of the theorem is that the strong triangle inequality is *guaranteed* to come
out the other end. We state this as the foundational result:

> **Reconstruction Theorem (ultrametric).** For every tropical valuation carrier
> `X` and all elements `x, y`, the reconstructed norm satisfies
> `norm(x + y) ≤ max(norm(x), norm(y))`. Moreover the norm sends zero to zero and
> is multiplicative: `norm(x · y) = norm(x) · norm(y)`.

From this single inequality cascade all the classic surprises of ultrametric
geometry. We prove, for instance, the **isosceles principle** in its asymmetric
form: if `norm(x) ≤ norm(y)`, then `norm(x + y) ≤ norm(y)`. The smaller term
cannot push the sum above the larger one — the very reason every ultrametric
triangle is isosceles.

There is also a road back. The **tropicalization** functor takes any ultrametric
seminorm object and remembers only its value semiring — the natural numbers under
`max` and `+` — forgetting the ambient ring. Reconstruction and tropicalization
are not arbitrary maps slapped between the two worlds; they are **functors**, and
we prove they respect identities and compositions exactly. Tropicalization of a
composite map equals the composite of tropicalizations; reconstruction of a
composite carrier-morphism equals the composite of reconstructions. This
functoriality is what upgrades the dictionary into a machine. Translate, then
compute — or compute, then translate; the answer is the same.

On well-behaved objects the round trip even closes up into an honest
*equivalence*. On **rigid** tropical objects (where the max-structure separates
points) and on **separated** ultrametric objects (where a vanishing norm forces
the element to be zero — the ultrametric echo of the Hausdorff property), the unit
and counit of the adjunction are genuine isomorphisms. The two worlds are, on
their respectable members, two views of one thing.

## Why a functor beats a dictionary: bounds travel for free

Here is the punchline that makes this more than aesthetics. Suppose you are an
engineer and you have proven, in the clean combinatorial tropical world, that
some operation `f` is **Lipschitz with constant `C`**: it never inflates a
valuation by more than a factor of `C`, i.e. `val(f(x)) ≤ C · val(x)`. Because
reconstruction is a quantitative functor, that bound *transfers verbatim* to the
ultrametric world:

> **Sharp Lipschitz Transfer.** If `f` is `C`-Lipschitz for the tropical
> valuation, then `f` is `C`-Lipschitz for the reconstructed ultrametric norm —
> with the *same constant `C`*. No loss, no fudge factor.

Sharpness matters. In certified machine learning and in cryptography, every
factor you give away in a bound is security or robustness you cannot get back. A
transfer principle that doubled your constant at each step would be useless after
a few layers. This one is exact.

And it compounds correctly. Iterating a `C`-Lipschitz map `n` times yields a map
that is `C^n`-Lipschitz — proven cleanly by induction, in both the tropical and
the ultrametric world:

> **Iterated Lipschitz Rate.** If `val(f(x)) ≤ C · val(x)` for all `x`, then for
> every `n`, `val(f^{[n]}(x)) ≤ C^n · val(x)`; and the identical `C^n` bound holds
> for the reconstructed ultrametric norm.

This is precisely the law governing how perturbations propagate through an
`L`-layer deep neural network with per-layer Lipschitz constant `C`: the whole
network is `C^L`-Lipschitz, and a certified-robustness radius computed for one
layer degrades by exactly that controlled rate. The same `C^n` law tells a
cryptographer how a security gap erodes under `n` rounds of an iterated attack.

## Three worlds, one theorem

What makes the bridge worth building is the company it lets the two endpoints
keep.

**Cryptography.** Lattice-based post-quantum schemes rest on *gaps*: the secret
must sit a guaranteed distance away from every decoy, so that no efficient
algorithm can find it. We prove that a separation gap measured tropically — "every
wrong guess `y` differs from the secret by valuation at least `gap`" — transfers
into an identical ultrametric security gap. The hardness you establish in the
combinatorial world is the hardness you enjoy in the geometric one.

**Certified machine learning.** A classifier is *certifiably robust* at a point
if every input within some radius receives the same label. We package this as a
radius-transfer theorem: a tropical certificate of a robustness radius `R` around
a center becomes an ultrametric certificate of the same radius `R`. Tropical
computations, which are fast and combinatorial, can therefore *underwrite*
nonarchimedean robustness guarantees.

**Statistical physics and beyond.** The stability of the `max` operation under
perturbation — a tropical fact — becomes the ultrametric isosceles concentration
that governs energy landscapes with a nonarchimedean flavor. The same inequality,
read three ways.

None of these connections is hand-waved. Each is a theorem with an explicit
constant, assembled into a single coherent categorical framework and verified
end to end. The "transfer principles" are not analogies; they are functions
between proofs.

## The shape of an idea

Step back and the architecture is elegant. On the left, **tropical algebra**:
order, max, and the leading-order skeleton of quantities. On the right,
**ultrametric geometry**: balls within balls, isosceles triangles, the native
landscape of p-adic numbers. Between them, an order-reversing exponential that
turns valuations into sizes and `min` into `max`. And wrapping the whole picture,
the discovery that this correspondence is *functorial and quantitative* — that it
ships numbers, not just names, across the divide.

The deepest lesson is one about *closeness* itself. We began with a child's ruler.
We end with a notion of nearness in which the third side of every triangle is
trapped beneath the longer of the other two — a discipline so rigid that it makes
distance behave like the order of divisibility by a prime, or the leading term of
a polynomial, or the depth of a perturbation through a deep network. That such a
counterintuitive geometry should be the *same object* as the brute-force max-plus
arithmetic of optimization is the kind of unification mathematics lives for. Here
it has been written down so carefully that a machine agrees, and so clearly that,
one hopes, a curious reader can too.
