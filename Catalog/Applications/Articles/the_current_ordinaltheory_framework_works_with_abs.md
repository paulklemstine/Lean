# How Many Exponentials Does It Take? The Tight Depth Hierarchy

## A question hiding in plain sight

Write down the number `e`. Now raise `e` to that power: `e^e`. Now raise `e`
to *that*: `e^(e^e)`. Keep going. After only four steps you have a number with
more digits than there are atoms in the observable universe. After five, the
count of its digits already dwarfs anything you could ever name. This staircase
of exponentials — a "power tower" — is one of the fastest-growing constructions
in everyday mathematics.

Mathematicians give the staircase a name. Define the *iterated exponential*:

- `iterExp 0 x = x`
- `iterExp 1 x = exp(x)`
- `iterExp 2 x = exp(exp(x))`
- `iterExp (n+1) x = exp(iterExp n x)`

So `iterExp n` is a tower of `n` exponentials sitting on top of the input `x`.

Here is the deceptively simple question this work answers. Suppose you are
allowed to build a function using only the ordinary tools of algebra — adding,
multiplying, negating — together with one transcendental gadget: the operation

> **eml(a, b) = a · exp(b)**

which multiplies one quantity by the exponential of another. You may nest these
gadgets inside each other as deeply as you like. The *depth* of your formula is
simply the maximum number of `eml` gadgets nested one inside another. A formula
of depth 0 uses no exponential at all (it is a polynomial-like field
expression); depth 1 allows a single layer of `exp`; depth 2 allows an
exponential of an exponential; and so on.

**The question:** to build a tower of height `n` — to reproduce `iterExp n` —
how much depth do you actually need?

The intuitive guess is "about `n`." The result proved here makes that intuition
*exact*, with no slack whatsoever:

> **The Tight Depth Hierarchy.** Using only addition, multiplication,
> negation, and the gadget `eml(a,b) = a·exp(b)` (no division), a formula of
> depth `D` can never represent `iterExp n` for any `n > D`. To climb `n`
> exponentials you need depth at least `n` — not `n+1`, not `n+3`, exactly `n`.

This is a statement about the fundamental cost of transcendence. Each genuine
new exponential in the answer demands a genuine new layer in the formula. You
cannot cheat the staircase.

## The language of `eml`

To make the claim precise we need a tidy little programming language for
formulas. Call it **EML**. An EML expression is built from:

- `var` — the input variable `x`;
- `const c` — any real constant `c`;
- `add a b`, `mul a b`, `neg a` — the field operations;
- `inv a` — multiplicative inverse (division);
- `eml a b` — the gadget, evaluating to `a · exp(b)`.

Every EML expression is just a recipe; to turn it into a number we *evaluate*
it at a point `x`. Evaluation does exactly what you expect: `var` returns `x`,
`add` adds the two pieces, `eml a b` returns `(value of a) · exp(value of b)`,
and so on.

Two structural numbers attached to each expression matter most.

The **eml-depth** counts how deeply `eml` gadgets are nested. Constants and the
variable have depth 0. Addition, multiplication and negation take the *maximum*
of their parts' depths — combining two formulas side by side does not add a new
layer. The inverse `inv a` inherits its child's depth. Only `eml a b` adds one:
its depth is `1 + max(depth a, depth b)`. So depth measures the longest chain of
`exp`-inside-`exp` in the whole formula.

The canonical height-`n` tower is built the obvious way: start from `x`, and
each time wrap the current formula in `eml(1, ·)`, which multiplies by `1` and
exponentiates. Doing this `n` times produces a formula whose eml-depth is
exactly `n` and which evaluates to `iterExp n`. So depth `n` is certainly
*enough*. The whole content of the theorem is that it is also *necessary*: depth
`n − 1` is not enough, and neither is anything smaller.

## Why "no division" matters

The theorem carefully restricts to the **inverse-free** fragment — formulas
with no `inv` node. This is not fussiness; it is essential. Division is
secretly powerful. With reciprocals you can manufacture functions that blow up
or oscillate near a point, and such singular behaviour can imitate growth that
otherwise would require an extra exponential. The clean, exact "depth `n` needs
exactly `n`" law is a phenomenon of the *honest*, division-free world, where
every formula is a smooth combination of polynomials and exponentials with
nothing hidden up its sleeve.

So the result splits the EML universe into two regimes. In the inverse-free
fragment, depth is an exact, rigid ruler of exponential complexity. Allow
division, and the ruler bends.

## The key idea: bounding growth by towers

How do you *prove* that something is impossible — that no clever depth-`(n−1)`
formula, however ingenious, can ever equal `iterExp n`? You cannot check them
all; there are infinitely many. The strategy is to find an invariant: a
property shared by *every* low-depth formula that `iterExp n` provably lacks.

That invariant is **growth**. The intuition: a depth-`k` inverse-free formula
can only grow about as fast as a tower of height `k`. If `iterExp n` grew that
slowly it would contradict the well-known fact that each extra exponential is a
genuine leap. To turn this intuition into mathematics we need a precise upper
bound on how fast a low-depth formula can grow.

The first attempt at such a bound is the **tower majorant**. We say an
expression *has a tower majorant at level `k`* if, for all large enough `x`, its
value is at most `iterExp k (C · x)` for some constant `C`. In words: the
formula is eventually swallowed by a height-`k` tower fed a linear input. This
already works, but it leaves a frustrating gap. Each time you combine two
sub-formulas, the linear arguments pile up and you lose a little ground, so the
naive argument only proves depth `D` cannot reach `iterExp n` for `n > D + 3` —
a sloppy "off by three."

## The decisive sharpening: polynomial arguments

The innovation that makes the hierarchy *tight* is a sharper notion of
majorant. We say an expression **has a polynomial-argument tower majorant at
level `k`** if, for all large `x`,

> |value of the expression at `x`| ≤ `iterExp k (C · x^N)`

for some constant `C > 0` and some power `N`. The difference from before looks
tiny — we feed the tower a *polynomial* `C·x^N` instead of a *linear* `C·x` —
but it is exactly the right slack to make the bookkeeping close perfectly.

Here is why the polynomial version is the magic ingredient. When you multiply
two formulas, their exponents *add*; when you raise to the next tower level, a
polynomial argument gets absorbed cleanly into the next exponential, because
`exp(polynomial)` is still controlled by one more exponential of a polynomial.
A *linear* argument would force you to spend an extra tower level to soak up the
multiplication; a *polynomial* argument is closed under exactly the operations
that combine sub-formulas. The polynomial slack is "self-healing": it can absorb
the cross-terms from `mul`, `add`, and `neg` without ever costing a new tower
level. That self-healing is what deletes the spurious "+3."

To organize this we attach to every inverse-free formula a single number, its
**growth rank**:

- `var` and `const` have growth rank 0 (they are polynomial-sized);
- `add`, `mul`, `neg` take the maximum of their children's ranks (combining
  side-by-side does not increase rank);
- `eml a b` has rank `1 + max(rank a, rank b)` (a genuine exponential costs
  exactly one rank).

The growth rank is defined by the very same recursion as the eml-depth, with one
crucial relaxation absorbed into the proof: combining formulas never raises the
rank, and only a true `eml` does. Comparing the two definitions gives a clean
structural fact that anchors everything:

> **Rank is bounded by depth:** for every expression, `growthRank e ≤ emlDepth e`.

The chain of reasoning then runs:

1. Every inverse-free expression of growth rank `k` has a polynomial-argument
   tower majorant at level `k`: its size is eventually at most `iterExp k(C·x^N)`.
2. Since `growthRank e ≤ emlDepth e`, a depth-`D` inverse-free formula has growth
   rank at most `D`, hence is majorized by a tower of height at most `D`.
3. But `iterExp n`, by the elementary fact that "exp beats every polynomial,"
   eventually *outgrows* `iterExp k (C·x^N)` for every `k < n` and every
   choice of `C, N`. Taking logarithms `k` times reduces this to the schoolbook
   limit `exp(x) / (C·x^N) → ∞`.
4. Therefore a depth-`D` formula, capped at tower height `D`, can never keep up
   with `iterExp n` when `n > D`. It cannot equal it. **Impossible.**

The tightness — depth exactly `n`, with no `+1` or `+3` — is the direct payoff
of replacing the linear majorant by the polynomial one in step 1.

## Seeing it numerically

Abstract growth claims become believable when you watch the numbers. The
accompanying demonstration builds the canonical towers and confirms that the
height-`n` tower really does have eml-depth exactly `n` and really does evaluate
to `iterExp n`. It samples a handful of inverse-free expressions —
`x²+3`, `eˣ`, `eˣ + x⁵`, `e^(e^x)`, `x·eˣ + e^(x²)` — and checks the structural
inequality `growthRank ≤ emlDepth` for each.

It then exhibits the polynomial-argument majorant directly. For
`e(x) = x·eˣ + e^(x²)`, which has growth rank 1, the program tabulates `|e(x)|`
against `iterExp 1 (2·x²) = exp(2x²)` and shows the formula sitting comfortably
underneath the tower at every sampled point: at `x = 3`, the expression is about
`8.2 × 10³` while the majorant is about `6.6 × 10⁷`.

Finally it makes the separation tangible. Comparing `iterExp 4` against the best
a depth-3 formula could do, `iterExp 3 (C·x³)`, both sides overflow ordinary
floating point almost immediately — towers are merciless. So the demo peels off
three logarithms from each side, reducing the contest to its mathematical core:
`exp(x)` versus `C·x³`. The ratio climbs without bound — `4.4`, then `1.2×10⁴`,
then `7.9×10⁷`, then past `10¹⁵` — vividly confirming that one honest
exponential overpowers any polynomial, which is precisely why one missing layer
of depth can never be recovered.

## A companion toolkit: oracles, entropy, and spheres

The same body of work ships a small, sturdy toolkit of independently useful
facts that share the theme of *idempotence and fixed points* — the algebraic
backbone of "self-improving" computational procedures, here called oracles.

An **oracle** is just a function `O` from a space to itself, and we say `O₁`
*refines* `O₂` when every fixed point of `O₁` is also a fixed point of `O₂` —
`O₁` is at least as discriminating. This refinement relation is reflexive (every
oracle refines itself) and transitive (refinement chains compose), so oracles
form a clean preorder. An **idempotent** oracle — one satisfying `O(O(x)) =
O(x)` — has a striking property: it converges in a *single* step. Apply it once
and you are already at a fixed point; applying it again changes nothing. A
constant oracle has exactly one fixed point, its constant value. And idempotent
maps cleanly partition their domain into points already fixed and points sent,
in one move, to a fixed point.

The toolkit also pins down three concrete companions. The **binary entropy**
function `H(p) = −p·log₂p − (1−p)·log₂(1−p)` is proved non-negative on the open
unit interval and equal to exactly `1` at `p = 1/2` — the formal statement that
a fair coin carries precisely one bit of information. The **Möbius transform**
`(a,b,c,d): x ↦ (ax+b)/(cx+d)` is shown to compose by matrix multiplication of
its coefficients, the algebraic heart of projective geometry. And the
**inverse stereographic projection**, which wraps flat `n`-dimensional space
onto the unit `n`-sphere living in `(n+1)`-dimensional space, is proved to land
exactly on the sphere: the squared coordinates of the image always sum to `1`,
in every dimension at once. The demo confirms this last fact numerically in
dimensions 1, 2 and 3, with the squared norm coming out to `1.000000000000`
each time.

## Why this matters

At first glance the tight depth hierarchy is a niche fact about a toy language.
But it speaks to a question at the heart of computation and analysis: *what is
the true cost of a transcendental function?* Computer algebra systems,
automatic differentiation engines, and verification tools constantly manipulate
expressions built from exponentials. Knowing the exact minimum nesting required
to express a given growth rate tells you when a simplification is impossible —
when no rewriting, however clever, can shave off a layer. The hierarchy is a
*lower bound*, and lower bounds are precisely the guarantees that keep
optimizing compilers and symbolic engines honest.

More broadly, the result is a clean instance of a recurring story in
mathematics: a structural feature you can *see* (how deeply a formula is nested)
turns out to coincide exactly with an analytic feature you can *measure* (how
fast the function grows). The bridge between them is the growth rank, and the
polynomial-argument majorant is the bolt that makes the bridge bear weight with
no slack. When syntax and semantics line up that perfectly, you have found
something fundamental — and you have made the staircase of exponentials give up
one of its secrets: every step costs exactly one step, no more and no less.
