# When Triangles Refuse to Align: The Strange Geometry Beyond Desargues

## A Hidden World of Mathematical Rebellion

Imagine two triangles floating in space, each vertex connected by a line that passes through a single point — like the spokes of a wheel emanating from a hub. In 1648, the French mathematician Girard Desargues discovered something remarkable: the intersections of corresponding sides of these triangles always line up. Always. Without exception.

Or so mathematicians believed for nearly three centuries.

In 1943, Marshall Hall Jr. shattered this certainty by constructing a mathematical universe — a perfectly consistent geometry — where Desargues' theorem simply *fails*. Two triangles can be perspective from a point without being perspective from a line. It was as if someone had found a world where parallel lines could cross, or where the angles of a triangle didn't add up to 180 degrees. Except this was far stranger: this geometry wasn't curved or warped. It obeyed all the same basic incidence rules as ordinary geometry. The difference lay in something far more subtle — in the algebra hiding beneath the geometric surface.

## The Algebra-Geometry Connection

To understand what Hall discovered, we need to appreciate one of mathematics' deepest insights: geometry and algebra are two languages for the same reality.

Every geometric plane can be "coordinatized" — assigned a number system that describes it, much the way latitude and longitude describe the Earth. For ordinary Euclidean geometry, that number system is the real numbers. For the projective geometry of perspective drawing and Renaissance art, it's any *division ring* — a number system where you can add, subtract, multiply, and divide (except by zero), where multiplication is associative: (a × b) × c always equals a × (b × c).

Desargues' theorem, it turns out, is not really about triangles at all. It's about *associativity*. The theorem holds in a geometry precisely when the underlying number system has associative multiplication. Take away associativity, and Desargues' theorem crumbles.

## The Hall Quasifield: Breaking the Rules

Hall's construction begins with GF(9) — the finite field with nine elements, built by extending the integers modulo 3 with a square root of -1 (call it α). In this tiny number system, 1 + 1 + 1 = 0, and α² = -1 = 2.

The field GF(9) has a natural symmetry: the *Frobenius automorphism* σ, which maps each element to its cube. In coordinates, σ(a + bα) = a + 2bα. This map is like a mirror that fixes the base field GF(3) and flips everything else.

Hall's genius was to use this mirror selectively. He defined a new multiplication ○ on GF(9):

- If the right-hand factor is in the base field GF(3): multiply normally.
- If the right-hand factor is *not* in GF(3): first apply the Frobenius mirror to the left factor, then multiply.

The result is a *quasifield* — an algebraic structure that satisfies right distributivity (a + b) ○ c = a ○ c + b ○ c, has identity elements, and allows unique division. But this quasifield is *not* a field, because its multiplication is neither associative nor left-distributive.

The failure of associativity can be witnessed concretely. Take x = α, y = α, z = 1 + α:

- (x ○ y) ○ z = (1 + α)
- x ○ (y ○ z) = (2 + 2α)

These are different. In 81 elements' worth of arithmetic, associativity breaks down on this single triple. One counterexample is all it takes.

## A Plane with 91 Points

The Hall quasifield gives birth to the *Hall plane* — a projective plane with 9² + 9 + 1 = 91 points and 91 lines. Every line passes through exactly 10 points. Every point lies on exactly 10 lines. Any two points determine a unique line. Any two lines meet in a unique point. All the basic axioms of projective geometry hold perfectly.

And yet, Desargues' theorem fails. There exist configurations of two triangles, perspective from a point, whose corresponding sides do *not* meet on a common line.

This is the smallest non-Desarguesian projective plane, and its discovery opened a floodgate. Mathematicians went on to find non-Desarguesian planes of every prime-power-squared order: 9, 16, 25, 49, 64, 81, and infinitely beyond. Each one represents a fundamentally different geometry — a universe with its own internal logic, its own symmetries, its own surprises.

## The Symmetry Gap

One of the most striking features of non-Desarguesian planes is their *reduced symmetry*. The standard Desarguesian plane of order q has a collineation group (its group of geometric symmetries) of size |PGL(3, q)| — a number that grows rapidly with q. For q = 9, this is over 42 million symmetries.

The Hall plane, by contrast, has far fewer. Its collineation group is strictly smaller than PGL(3, 9). The loss of associativity in the algebra translates directly into a loss of symmetry in the geometry. Fewer algebraic identities mean fewer geometric transformations that preserve the structure.

This symmetry gap is not just a curiosity — it has deep implications for coding theory, network design, and the foundations of geometry itself.

## Why It Matters

The existence of non-Desarguesian planes challenges our intuitions about what geometry *is*. We tend to think of geometric theorems as universal truths, but Desargues' theorem teaches us that even the most natural-seeming geometric facts can be accidents of algebra.

The story also illustrates a profound duality: every question about geometric configurations is secretly a question about algebraic structure, and vice versa. The associativity of multiplication — something we take for granted when we balance our checkbooks — turns out to be the precise algebraic condition that determines whether triangles in perspective must have collinear meets.

In combinatorics, non-Desarguesian planes provide optimal structures for error-correcting codes and experimental designs. In physics, they hint at exotic symmetries that might describe the geometry of spacetime at scales where our usual assumptions break down.

Perhaps most importantly, they remind us that mathematics is not a single monolithic edifice. It is a vast landscape of possible structures, each consistent, each beautiful, each revealing something different about the nature of abstract truth.

## The Frontier

The classification of finite projective planes remains one of the great unsolved problems in combinatorics. We know that Desarguesian planes exist for every prime power order, and that non-Desarguesian planes exist for every prime power squared order greater than 4. But the question of which orders admit projective planes at all — the famous *prime power conjecture* — remains wide open.

No one has ever found a projective plane of order 6, or 10, or any non-prime-power order. A famous computer search in 1989 ruled out order 10 after years of computation. But whether projective planes of order 12 or 14 or 15 exist remains unknown.

What we do know is that when they exist, they come in bewildering variety. At order 9, there are exactly four non-isomorphic planes: the Desarguesian plane, the Hall plane, its dual, and the Hughes plane. At order 16, there are already hundreds. The taxonomy of these geometric universes is a rich and active area of research, connecting algebra, combinatorics, group theory, and computer science in unexpected ways.

In the end, the story of non-Desarguesian geometry is a story about the fertility of mathematical rebellion. By asking "what if this basic law fails?", Hall and his successors discovered not chaos but new order — new symmetries, new structures, and new connections that continue to surprise and inspire mathematicians today.
