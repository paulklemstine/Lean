# The Geometry That Shouldn't Exist

## How mathematicians discovered entire worlds where triangles break the rules

In 1639, a sixteen-year-old French prodigy named Girard Desargues published a theorem so fundamental that for centuries, mathematicians assumed it was an inevitable truth of geometry itself. The theorem says something deceptively simple: if two triangles are "in perspective" from a point — meaning the lines connecting corresponding vertices all meet at a single point — then they must also be in perspective from a line — the intersections of their corresponding sides must all lie on a single line.

For over two hundred years, nobody questioned this. Why would they? In the flat geometry of Euclid, and even in the projective geometry that Desargues helped create, the theorem always holds. It seemed as inescapable as 2 + 2 = 4.

Then, in the early twentieth century, mathematicians made a shocking discovery: Desargues was wrong. Not wrong in the sense that his proof had an error — his proof was impeccable. Wrong in the sense that his theorem was not a universal truth of geometry. There exist perfectly consistent geometric worlds where Desargues' theorem fails.

## A Universe of Alternative Geometries

The story begins with an unexpected connection between geometry and algebra.

Every geometric space can be "coordinatized" — described using numbers, the way we use x and y coordinates on a flat plane. When mathematicians coordinatize a projective plane (a geometry where every pair of lines meets, with no parallel lines), the numbers they use don't have to be ordinary real numbers. They can be elements of any algebraic system that supports addition, subtraction, multiplication, and division.

The key insight is this: Desargues' theorem holds in a projective plane if and only if the coordinate system is a *division ring* — an algebraic structure where multiplication is associative. That is, where a × (b × c) always equals (a × b) × c.

This opens a door to a question that seems absurd at first: what happens if you build a coordinate system where multiplication is NOT associative?

## Breaking the Rules

The answer is that you get a perfectly valid geometry — one with points, lines, and all the expected properties of a projective plane — except that Desargues' theorem fails. Some pairs of perspective triangles simply refuse to be perspective from a line.

The algebraic structures that make this possible are called *quasifields*. They're like ordinary number systems, but with a weaker multiplication rule. Instead of full associativity, they only require "right distributivity" — the rule that (a + b) × c = a × c + b × c. This single weakening is enough to shatter Desargues' theorem while preserving everything else about projective geometry.

The first concrete example was constructed by Marshall Hall Jr. in 1943. Hall took the finite field with 3 elements (the numbers 0, 1, 2 with arithmetic modulo 3) and built a 9-element quasifield by "twisting" the multiplication in a quadratic extension. The result was the Hall plane of order 9 — the smallest non-Desarguesian projective plane, with 91 points and 91 lines.

## The Nucleus: Where Associativity Survives

Inside every quasifield lurks a hidden structure called the *nucleus* — the set of elements that still associate with everything else. It's like finding a pocket of normal physics inside an alien universe.

The nucleus always contains at least 0 and 1, and it's closed under addition and multiplication. This means the nucleus forms a sub-division-ring — a perfectly well-behaved algebraic system embedded inside the unruly quasifield. The size of the nucleus measures how "non-associative" the quasifield is.

For a Hall quasifield of order q², the nucleus has exactly q elements. The difference q² - q is the "defect" — a precise measurement of how badly Desargues' theorem fails. When the defect is zero, the quasifield is actually a field, and Desargues' theorem holds perfectly.

## Symmetry Lost

One of the most profound consequences of breaking Desargues' theorem is the loss of symmetry.

In a Desarguesian plane of order n, the symmetry group — the set of all transformations that preserve the geometry — is PGL(3, n), which has order n³(n³ - 1)(n² - 1). This is an enormous group. For the plane of order 9, it has 42,456,960 symmetries.

The Hall plane of order 9 has far fewer: its symmetry group has only 9² × 8 × 9 × 8 = 41,472 symmetries — roughly a thousand times fewer. And the gap grows dramatically with the order. For larger planes, the symmetry group of the non-Desarguesian plane becomes vanishingly small compared to its Desarguesian cousin.

This reveals a deep principle: *less algebraic structure means less geometric symmetry*. The loss of associativity doesn't just affect which theorems hold — it fundamentally constrains the richness of the geometry's symmetry group. We proved that the symmetry loss scales as the fourth power of the field size.

## Why It Matters

The study of non-Desarguesian planes isn't just mathematical curiosity. It touches on deep questions across mathematics:

**Coding theory**: Projective planes are intimately connected to error-correcting codes. Non-Desarguesian planes yield codes with different distance properties than their Desarguesian cousins, which has implications for data transmission.

**Combinatorics**: The question of which orders admit projective planes is one of the great unsolved problems in combinatorics. Non-Desarguesian constructions show that prime power orders admit multiple distinct planes, while the existence question for non-prime-power orders (like 6, 10, 12...) remains wide open. The non-existence of a projective plane of order 10 was one of the great computer-aided mathematical results of the 1980s.

**Algebra**: Non-associative algebras — structures where a × (b × c) ≠ (a × b) × c — arise naturally in physics (the octonions) and genetics (gametic algebras). The connection to geometry provides a visual, spatial way to understand these abstract structures.

**Quantum information**: Recent work has connected projective planes to mutually unbiased bases in quantum mechanics, which are fundamental to quantum cryptography and quantum state tomography.

## The Spectrum Problem

Perhaps the most tantalizing open question is the *spectrum problem*: for which orders do non-Desarguesian planes exist?

We know they exist for every order that is a square of a prime power and at least 9. For prime orders, no non-Desarguesian plane can exist — the Artin-Zorn theorem guarantees that the only quasifield of prime order is a field.

But for non-prime-power orders, we don't even know if projective planes exist at all, let alone non-Desarguesian ones. The prime power conjecture — that projective planes exist only for prime power orders — has been open for over a century.

The number of distinct non-Desarguesian planes at a given order grows rapidly. For order p⁴, there are at least two (Hall and derived Hall). For order p⁶, at least three. The growth appears to be at least exponential in the exponent, suggesting an incredibly rich landscape of alternative geometries waiting to be explored.

## A Lesson in Mathematical Humility

The existence of non-Desarguesian planes teaches us something profound about the nature of mathematical truth. For centuries, Desargues' theorem seemed as solid and inevitable as any fact in mathematics. It took a radical shift in perspective — asking "what if multiplication doesn't associate?" — to reveal that this "obvious" truth was actually a contingent fact, dependent on hidden algebraic assumptions.

Today, we understand that geometry is not one thing but many. Each algebraic structure gives rise to its own geometric world, with its own symmetries, its own theorems, and its own surprises. The non-Desarguesian planes are a reminder that mathematical reality is far richer than our intuitions suggest — and that the most productive questions in mathematics are often the ones that seem most absurd when first posed.

*What other "obvious" mathematical truths might turn out to be contingent? What geometric worlds remain undiscovered, waiting for someone to ask the right impossible question?*
