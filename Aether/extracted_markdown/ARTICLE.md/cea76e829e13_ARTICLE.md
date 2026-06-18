# The Shape That Broke the Pattern: How a Single Tile Rewrote the Rules of Symmetry

## A Bathroom Floor Revolution

Imagine you're tiling your bathroom floor. You pick a square tile, and it's easy — squares fit together perfectly, repeating the same pattern forever. Hexagons work too, as any beekeeper knows. These patterns are *periodic*: slide the whole floor a certain distance in some direction, and the pattern lands exactly on itself. For thousands of years, humans assumed that any shape capable of covering a flat surface without gaps must permit such a repeating pattern.

They were wrong.

In March 2023, a retired printing technician named David Smith, working at his kitchen table in the village of Bridlington, England, discovered a shape that shattered this assumption. He called it "the hat" — a simple, 13-sided polygon that looks like a fedora drawn by a child. The hat can tile an infinite plane with no gaps and no overlaps. But here's the astonishing part: *it can never do so in a repeating pattern*. No matter how you arrange hat tiles to cover the plane, the result is always aperiodic — structured but never repetitive, ordered but never periodic.

Smith had found the holy grail of tiling theory: a single shape that tiles the plane, but only aperiodically. Mathematicians call this an *aperiodic monotile* or, more poetically, an *einstein* — German for "one stone."

## The Fifty-Year Hunt

The story begins in 1961, when the logician Hao Wang posed a seemingly innocent question: given a set of tile shapes, is there an algorithm to determine whether they can tile the plane? Wang conjectured the answer was yes, which would require that any set of tiles able to tile the plane must also admit a periodic tiling.

His student Robert Berger proved him wrong in 1966, constructing a set of 20,426 tile shapes that could tile the plane only aperiodically. No periodic arrangement existed. The race was on to find smaller aperiodic sets.

In the 1970s, the physicist Roger Penrose achieved a breakthrough with just *two* tiles — a pair of rhombuses (or equivalently, a "kite" and a "dart") that tile the plane aperiodically. Penrose tilings became famous, appearing in everything from quilts to the structure of quasicrystals, a discovery that earned Dan Shechtman the 2011 Nobel Prize in Chemistry.

But the deepest question remained open: could a *single* shape do the job? For fifty years, the "einstein problem" tantalized mathematicians. Some suspected the answer was no — that aperiodicity intrinsically required the interplay between at least two different shapes. Others believed the einstein existed but despaired of finding it amid the infinite universe of possible polygons.

Then David Smith sent an email to Craig Kaplan, a computer scientist at the University of Waterloo.

## The Hat and Its Secret

Smith's hat tile is deceptively simple. Take a hexagonal grid, combine eight of the hexagons in a particular hat-like shape, and you have it. The magic lies not in the shape's complexity but in its *stubbornness*: when you try to extend a patch of hat tiles, the shape forces you into an aperiodic arrangement. You have no choice. The tile's geometry dictates a hierarchical structure — clusters of hats form larger super-tiles, which form even larger super-super-tiles, nesting infinitely like Russian dolls.

This hierarchical structure is the key, and it's captured mathematically by something called a *substitution rule*. Each tile, when magnified, can be decomposed into copies of itself (and possibly reflected copies). The magnification factor — the *inflation factor* — is a specific number: 2 + √3, approximately 3.732.

This number is not just any number. It's an algebraic integer satisfying the equation x² − 4x + 1 = 0. It's irrational. And it belongs to a special class called *Pisot numbers* — algebraic integers greater than 1 whose conjugate roots (in this case, 2 − √3 ≈ 0.268) all have absolute value less than 1.

The Pisot property is not a coincidence. It's the algebraic fingerprint of aperiodicity. A substitution tiling whose inflation factor is a Pisot number produces a tiling with "pure point diffraction" — sharp Bragg peaks in its X-ray pattern, just like a crystal, but arranged in a pattern that never repeats. The hat is maximally ordered among aperiodic structures: as close to a crystal as you can get without actually being one.

## Not One Shape, But a Family

Perhaps the most surprising revelation is that the hat is not alone. It belongs to a continuous *family* of aperiodic monotiles, parameterized by a single number.

Think of the hat as defined by two edge lengths, *a* and *b*. The original hat has a specific ratio between these lengths. But you can smoothly adjust the ratio, stretching one edge type while shrinking the other, and the resulting shape *still* tiles the plane aperiodically. Smith and his collaborators called this continuum the "hat spectrum."

At one end of the spectrum (parameter t = 0) sits the original hat. At the other end (t = 1) sits a different shape called "the turtle." In between lies a continuous infinity of aperiodic monotiles, each with slightly different geometry but the same underlying combinatorial structure.

The hat spectrum has a beautiful algebraic description. Each tile in the family has an inflation polynomial x² − c(t)·x + 1, where c(t) is a trace function that ranges from 4 (at the endpoints) to 7/2 (at the midpoint). The discriminant c(t)² − 4 is always positive — guaranteed by the inequality c(t) ≥ 7/2, which follows from the arithmetic-geometric mean inequality applied to the parameter. This means every tile in the spectrum has two distinct real eigenvalues, and the larger one (the inflation factor) always exceeds 1. The family is robustly aperiodic.

At the midpoint t = 1/2, the *spectral gap* — the difference between the two eigenvalues — reaches its minimum. This is the point where the aperiodic structure is, in a precise algebraic sense, "closest to periodic" without ever becoming periodic. It's as if the family of tiles is a taut bowstring, and the midpoint is where the tension is lowest.

## A Bridge Between Worlds

The algebraic structure of the hat reveals an unexpected connection to an entirely different branch of mathematics: *tropical geometry*.

Tropical geometry is a relatively young field that replaces ordinary arithmetic with a bizarre alternative: addition becomes "take the maximum," and multiplication becomes "add the numbers." This sounds like mathematical nonsense, but it turns out to be extraordinarily powerful. Tropical methods transform curved geometric objects into piecewise-linear ones — replacing smooth curves with stick figures that are much easier to analyze while preserving essential mathematical information.

The connection to aperiodic tilings runs through the *topological entropy* — the logarithm of the inflation factor. For the hat, this is log(2 + √3) ≈ 1.317. This number measures the intrinsic complexity of the tiling: how rapidly the number of distinct local configurations grows as you look at larger and larger patches.

In tropical terms, the topological entropy is exactly the *tropical eigenvalue* of the logarithmic substitution matrix — the maximum average weight along any cycle in a directed graph that encodes the substitution rule. This is not a superficial analogy. It's a mathematical identity that bridges three fields: the Perron-Frobenius theory of nonnegative matrices (classical linear algebra), the ergodic theory of tiling dynamical systems (dynamics), and the max-plus algebra of tropical geometry.

This bridge suggests that the powerful computational tools of tropical geometry — which have already revolutionized areas from algebraic geometry to optimization — could be brought to bear on open problems in tiling theory. Conversely, the rich structure of aperiodic tilings may provide new examples and test cases for tropical methods.

## Why It Matters

Aperiodic tilings are not just mathematical curiosities. They are the mathematical framework underlying *quasicrystals* — materials whose atomic arrangement has long-range order without periodicity. Since Shechtman's discovery in 1982, quasicrystals have been found in meteorites, created in laboratories, and used in industrial applications from non-stick coatings to LED lighting.

The hat tile and its spectrum open new possibilities. If you can design a single molecular shape that tiles aperiodically, you could potentially engineer new quasicrystalline materials with tailored properties. The continuous parameter of the hat spectrum suggests that these properties could be tuned smoothly — adjusting the "edge ratio" of molecular building blocks to control the resulting material's symmetry, diffraction pattern, and physical behavior.

Beyond materials science, aperiodic tilings have connections to information theory and coding. A tiling that never repeats is, in a sense, a two-dimensional sequence with zero redundancy — it carries the maximum possible "geometric information" per unit area. Understanding the entropy of such tilings could lead to new approaches in data compression and error-correcting codes.

## The View from Here

David Smith's discovery in 2023 resolved a question that had been open for over sixty years. But as with all great mathematical breakthroughs, it opened more doors than it closed.

We now know that aperiodic monotiles exist. We know they form continuous families. We know their algebraic structure connects to Pisot numbers, tropical geometry, and the theory of dynamical systems. But fundamental questions remain:

How many fundamentally different families of aperiodic monotiles exist? Is the hat spectrum the only such family, or are there others with different algebraic invariants? Can we classify all aperiodic monotiles, the way we classify crystallographic symmetry groups?

What happens in three dimensions? Can a single shape tile three-dimensional space only aperiodically? Such a shape would have immediate implications for the design of metamaterials — engineered structures whose properties emerge from their geometric arrangement rather than their chemical composition.

And perhaps most provocatively: is there a deeper reason why aperiodicity and Pisot numbers are connected? The Pisot property appears in seemingly unrelated areas of mathematics — number theory, harmonic analysis, dynamical systems — and aperiodic tilings may be the Rosetta Stone that reveals the common structure beneath.

The hat sitting on David Smith's kitchen table was, in the end, much more than a clever shape. It was a key that unlocked a new chapter in our understanding of order, symmetry, and the mathematics of pattern itself. And that chapter, mathematicians are beginning to realize, is far longer and more surprising than anyone imagined.
