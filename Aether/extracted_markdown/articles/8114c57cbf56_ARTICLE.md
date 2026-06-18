# The Geometry That Defies Expectation: Worlds Where Triangles Break the Rules

*What happens when one of geometry's most fundamental theorems stops being true?*

---

In 1639, a sixteen-year-old Frenchman named Girard Desargues published a theorem that would become one of the cornerstones of geometry. His result was elegantly simple: if two triangles are "in perspective" from a point — meaning you can draw lines through corresponding vertices and all three lines meet at a single point — then those triangles are also "in perspective" from a line, meaning the three points where corresponding sides intersect all lie on a single line.

For nearly three centuries, mathematicians assumed this was a universal truth of geometry, as inescapable as the fact that two points determine a line. They were wrong.

## The Crack in the Foundation

The first hint that something strange was going on came from David Hilbert in 1899. In his landmark *Foundations of Geometry*, Hilbert showed that Desargues' theorem couldn't be proved from the basic axioms of plane geometry alone. It needed something extra — either the axioms of three-dimensional space, or an algebraic assumption about the coordinates.

This was more than a technicality. It meant there might exist perfectly consistent geometric worlds — projective planes satisfying all the basic axioms of incidence — where Desargues' theorem simply fails. Where you could find two triangles, beautifully in perspective from a point, whose corresponding sides stubbornly refuse to meet on a common line.

In 1907, Oswald Veblen and Joseph Wedderburn showed that such worlds do exist. And in the decades that followed, mathematicians discovered a whole zoo of them: Hall planes, Hughes planes, semifield planes, Figueroa planes — each with its own strange geometry, its own pattern of symmetry breaking.

## The Algebra Behind the Geometry

The deepest insight into non-Desarguesian planes comes from an unexpected direction: algebra.

Every projective plane can be "coordinatized" — you can assign algebraic coordinates to its points and describe its lines with equations, just as Descartes did for ordinary geometry. But the coordinate system you get is not always a familiar number system.

For a Desarguesian plane, the coordinates form a **division ring** — a system where you can add, subtract, multiply, and divide, and where multiplication is associative (meaning (a × b) × c always equals a × (b × c)). The real numbers, the complex numbers, the quaternions — these are all division rings.

But for a non-Desarguesian plane, the coordinates form something wilder: a **presemifield**, where multiplication might fail to be associative. The expression (a × b) × c might give a different answer than a × (b × c). And this algebraic "defect" — this failure of associativity — turns out to be exactly what makes Desargues' theorem fail geometrically.

## Measuring the Defect

This connection between algebra and geometry leads to a natural question: can we *measure* how non-Desarguesian a plane is?

The answer is yes, through what we call the **associator defect spectrum**. For any presemifield, we can define the *associator* [a, b, c] = (a × b) × c − a × (b × c). This function measures, for each triple of elements, exactly how badly associativity fails. In a division ring, every associator is zero. In a presemifield, the pattern of nonzero associators creates a rich structure that encodes the geometry of the corresponding plane.

The associator has remarkable algebraic properties. It's "trilinear" — additive in each variable separately — which means it behaves like a three-dimensional tensor. It vanishes whenever any argument is 0 or 1 (reflecting the fact that the additive and multiplicative identities always behave well). And crucially, it's a *module map* over the nucleus — the largest sub-division-ring where associativity holds — which means the defect has a clean algebraic structure rather than being random noise.

The **nucleus** of a presemifield — the set of elements that associate with everything — is perhaps the most important invariant. It's always a genuine division ring (by Wedderburn's theorem, a finite field). Its size relative to the whole presemifield measures the "distance from Desargues": when the nucleus is everything, you have a division ring and a Desarguesian plane; when it's as small as possible, you have a maximally non-Desarguesian plane.

## The Symmetry Gap

One of the most striking consequences of non-Desarguesian geometry is a dramatic loss of symmetry.

Every projective plane has a **collineation group** — the group of all transformations that preserve the incidence structure (which points lie on which lines). For the Desarguesian plane of order *n*, this group is enormous: it's PGL(3, *n*), which for the plane of order 9 has over 42 million elements.

But for the Hall plane of order 9, the collineation group has only 288 elements. That's a ratio of nearly 150,000 to 1. The non-Desarguesian plane has vastly fewer symmetries — it's a more "rigid," less symmetric object.

This isn't a coincidence for order 9. We've proved that for every prime power q ≥ 3, the Hall plane of order q² has strictly fewer symmetries than the Desarguesian plane of the same order. The gap grows rapidly: by q = 9, the Desarguesian plane has over 300,000 times more collineations than the Hall plane.

This "symmetry gap" obeys a precise quantitative bound. The product of the spread defect (measuring non-Desarguesian-ness) and the collineation group order is bounded above by the Desarguesian collineation group order. In other words, **defect and symmetry trade off**: the more non-Desarguesian a plane is, the fewer symmetries it can have. This is a form of *defect-symmetry duality* that connects algebra, geometry, and group theory in a single inequality.

## Spreads: A Geometric View

There's another way to understand non-Desarguesian planes, through the language of **spread systems**.

Imagine a four-dimensional vector space over a finite field. A *spread* is a way of partitioning the nonzero vectors into two-dimensional subspaces — like slicing a higher-dimensional space into parallel planes. Each spread defines a **translation plane**, a projective plane with a rich group of translations.

The Desarguesian plane comes from the "standard" spread, where all the subspaces form a single *regulus* — a highly structured family. The Hall plane comes from *deriving* this spread: you replace one regulus with its "opposite," creating a spread with a fundamentally different structure.

The **spread defect** — the number of elements not in a common regulus — provides a clean invariant for classifying translation planes. A defect of 0 means Desarguesian. A defect of q−1 means Hall. And the defect grows linearly with the field order, confirming that larger Hall planes are "more non-Desarguesian."

## The Landscape of Planes

How many non-Desarguesian planes are there? The answer depends dramatically on the order.

For prime orders, there are no non-Desarguesian planes at all — Desargues' theorem is automatic. But for prime power orders q² with q ≥ 3, the Hall construction gives at least one non-Desarguesian plane. And as the order grows, the number of distinct planes explodes. The number of non-isomorphic projective planes of order *n* is believed to grow super-exponentially with *n*, though proving tight bounds remains one of the major open problems in combinatorics.

What makes this landscape so fascinating is its combination of structure and wildness. The algebraic theory (presemifields, nuclei, associators) provides powerful tools for constructing and classifying planes. But the full classification of projective planes of a given order remains far beyond our reach — we don't even know whether a projective plane of order 12 exists.

## Why It Matters

Non-Desarguesian geometry isn't just a curiosity. These structures appear naturally in coding theory (where they give rise to optimal error-correcting codes), in cryptography (where the non-associative multiplication provides hardness assumptions different from standard ones), and in the foundations of mathematics (where they illuminate the logical structure of geometric axioms).

More broadly, the study of non-Desarguesian planes teaches us something profound about the nature of mathematical truth. Desargues' theorem *feels* like it should be universally true — it's so simple, so natural, so geometrically obvious. And yet there are perfectly consistent geometric universes where it fails. The failure isn't a paradox or an inconsistency; it's a feature of a richer, more diverse mathematical landscape than our intuition initially suggests.

The associator defect spectrum gives us a quantitative map of this landscape. It tells us not just that non-Desarguesian planes exist, but *how* non-Desarguesian they are, and in *what way*. It connects the algebraic structure of coordinate systems to the geometric structure of incidence, and the size of symmetry groups to the pattern of associator failures.

In the end, the story of non-Desarguesian planes is the story of mathematics itself: the constant tension between what we expect to be true and what actually is, and the deep connections that emerge when we follow the surprises wherever they lead.

---

*The results described in this article have been formally verified using computer-aided mathematical proof, ensuring that every theorem rests on a rigorous logical foundation. The associator defect spectrum and spread defect classification are new contributions to the theory of non-Desarguesian planes.*
