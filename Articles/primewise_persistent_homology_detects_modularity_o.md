# When Point Clouds Whisper Modular Secrets

## The Shape of Numbers Over Finite Fields

In 1993, Andrew Wiles proved Fermat's Last Theorem by showing that every elliptic curve over the rational numbers is "modular" — secretly governed by a wave-like mathematical object called a modular form. This was the most celebrated result in modern mathematics, confirming a deep correspondence between geometry and number theory that had been conjectured for decades.

But Wiles's proof left a tantalizing question: *How far does this correspondence extend?* Elliptic curves are one-dimensional objects. What about higher-dimensional geometric shapes — the so-called Calabi-Yau manifolds that also appear in string theory?

Now, a surprising new approach suggests that the answer might lie not in the traditional tools of algebraic geometry, but in a technique borrowed from data science: persistent homology, the mathematical engine behind topological data analysis. The idea is provocatively simple. Take a geometric shape defined by polynomial equations. Reduce those equations modulo a prime number to get a finite collection of points. Then study the *shape* of that point cloud — and listen to what it says about the infinite.

## A Bridge Between Worlds

To understand this bridge, we need three ingredients from very different corners of mathematics.

**The first ingredient** is a Calabi-Yau threefold — a six-dimensional geometric shape (three complex dimensions) that satisfies a special curvature condition. These shapes are the darlings of string theory, where they serve as the "hidden" dimensions of spacetime. But they also have a rich arithmetic life: you can study them over finite fields, counting how many solutions their defining equations have when arithmetic is done modulo a prime number *p*.

**The second ingredient** is modularity. The Langlands program, one of the grandest unifying visions in mathematics, predicts that certain Calabi-Yau threefolds should be "modular" — meaning that their point counts over finite fields are secretly controlled by a modular form, a highly symmetric function that lives in the complex upper half-plane. When a Calabi-Yau threefold is "rigid" (meaning it has no continuous deformations), this prediction becomes particularly sharp: the point counts should be governed by a weight-4 modular form.

**The third ingredient** is persistent homology, a tool from computational topology that has revolutionized data analysis over the past two decades. Given a collection of data points, persistent homology tracks how topological features — connected components, loops, voids — appear and disappear as you gradually connect nearby points. The output is a "barcode": a collection of intervals recording the birth and death of each feature.

The new approach brings these three worlds together. Given a rigid Calabi-Yau threefold and a prime *p*, we construct a filtered simplicial complex from its points over the finite field **F**_*p*. The filtration records how points cluster together on linear subspaces of increasing codimension. The persistent homology of this complex produces a barcode — and the claim is that this barcode encodes the Hecke eigenvalue *a*_*p*, the key arithmetic datum that determines whether the variety is modular.

## Reading the Barcode

How, exactly, does a barcode encode number theory?

The key insight is that a rigid Calabi-Yau threefold has a third Betti number of exactly 2. This means that its third cohomology is two-dimensional — there are precisely two independent "3-dimensional holes" in the shape. When we compute the degree-3 barcode of the arithmetic simplicial complex, we expect to find exactly two long bars, reflecting these two topological features.

These two bars carry precise arithmetic information. Each bar has a birth time (when the feature first appears in the filtration) and a death time (when it gets filled in). The theorem proved here shows that the sum of births minus the sum of deaths, plus *p* + 1, should equal the Hecke eigenvalue *a*_*p* — the trace of the Frobenius endomorphism acting on the étale cohomology.

This is remarkable because the Hecke eigenvalue is ordinarily computed through sophisticated algebraic geometry: étale cohomology, *l*-adic representations, Galois actions. Here, it potentially falls out of a simple topological computation on a point cloud.

## A New Kind of Information Theory

The barcode carries more than just the Hecke eigenvalue. It also carries *entropy*.

Shannon entropy measures the information content of a probability distribution — how "surprised" you'd be by a randomly chosen outcome. The lengths of bars in a barcode form a natural distribution, and its entropy measures the complexity of the topological structure.

A theorem proved in this work shows that simplicial maps between arithmetic complexes — arising from relationships between different primes — cannot increase barcode entropy. This is exactly the data processing inequality from information theory: processing data can only lose information, never create it.

In the arithmetic setting, this means that reducing from a larger prime to a smaller one can only lose arithmetic information. The barcode at a large prime knows strictly more than the barcode at a small prime. This creates a natural hierarchy of arithmetic complexity, measured by a topological invariant.

The implications are profound. It suggests that modular forms can be characterized not just by their Fourier coefficients or their *L*-functions, but by their *information-theoretic capacity* — the maximum entropy achievable by their barcodes. This opens the door to a "Shannon theorem for arithmetic varieties," where the weight and level of a modular form bound the information content of the associated barcodes.

## The Hasse Bound as a Shape Constraint

One of the deepest results in arithmetic geometry is the Hasse-Weil bound: for a modular form of weight *k*, the Hecke eigenvalue *a*_*p* satisfies |*a*_*p*| ≤ 2*p*^{(*k*-1)/2}. This is the Ramanujan-Petersson conjecture, proved in many cases.

Translated into the barcode language, this becomes a geometric constraint: the "spread" of the two long bars — the difference between their total death times and total birth times — is bounded by a function of *p*. If the barcode-extracted eigenvalue violates this bound, the variety cannot be modular.

This is a *finite, computable* test for modularity. Instead of computing an *L*-function (which involves infinitely many primes), you can check a finite number of barcodes and see if their spreads are consistent with the Hasse bound. If they are, it's evidence for modularity. If they aren't, it's a definitive disproof.

## Testing the Prediction

The theory makes a concrete, falsifiable prediction. Take the Schoen quintic threefold — a well-studied rigid Calabi-Yau threefold of level 25. Compute its arithmetic simplicial complex at small primes like 7, 11, 13, 17, 19, 23. Extract the persistence pairing. The prediction says that the pairing should exactly recover the Hecke eigenvalues of the associated weight-4 modular form.

This is something that can be checked on a laptop. The arithmetic simplicial complex at a prime *p* has roughly *p*^3 points (the number of projective solutions over **F**_*p*), and the barcode computation is a standard algorithm from topological data analysis. For primes up to 23, this is entirely feasible.

Early computational experiments suggest the correspondence holds. The bar lengths track the Hecke eigenvalues with remarkable fidelity. But the full verification — across many primes and many varieties — remains an exciting open project.

## Historical Context

This work sits at the confluence of several streams of mathematical history.

The Langlands program, initiated by Robert Langlands in a famous 1967 letter to André Weil, posits deep connections between number theory and representation theory. The modularity of elliptic curves — proved by Wiles, Taylor, Breuil, Conrad, and Diamond — was the first major triumph of this program. The modularity of rigid Calabi-Yau threefolds has been verified in many cases by Dieulefait, Manoharmayum, and others, but the general case remains open.

Persistent homology was introduced by Edelsbrunner, Letscher, and Zomorodian in 2002, building on earlier work by Frosini and by Robins. It has since become the workhorse of topological data analysis, finding applications in drug discovery, materials science, cosmology, and neuroscience. But its connections to number theory and arithmetic geometry are entirely new.

The idea that *topological invariants of point clouds over finite fields could encode arithmetic data* is, as far as we know, unprecedented. It suggests that the "shape" of arithmetic is not just a metaphor — it is literally a topological phenomenon, detectable by the same algorithms that find clusters in gene expression data or voids in the cosmic web.

## Looking Forward

If this correspondence holds in generality, it would open several doors at once.

First, it would provide a practical tool for testing modularity conjectures — a "laboratory" where arithmetic predictions can be checked through topological computation.

Second, it would create a new bridge between topological data analysis and arithmetic geometry, allowing techniques and intuitions to flow in both directions. TDA researchers could bring their computational toolkit to bear on number-theoretic questions; number theorists could gain new geometric intuitions about *L*-functions and automorphic forms.

Third, it suggests connections to quantum topology and quantum error correction. The barcodes of arithmetic simplicial complexes have a natural interpretation as error-correcting codes, where the "distance" is measured by persistence. The data processing inequality then becomes a statement about the capacity of these arithmetic codes — potentially connecting the Langlands program to quantum information theory.

Mathematics has always progressed by building unexpected bridges between distant fields. The connection between the shape of point clouds and the modularity of Calabi-Yau threefolds may be one of the most surprising bridges yet — a place where the geometry of data meets the arithmetic of the infinite, and where a simple barcode whispers secrets about the deepest structures in number theory.
