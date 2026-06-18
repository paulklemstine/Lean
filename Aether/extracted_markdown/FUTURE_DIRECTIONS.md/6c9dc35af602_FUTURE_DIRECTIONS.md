# Future Directions: Non-Desarguesian Geometry

## 1. Hall Plane Construction and Non-Desarguesian Witness

The Hall quasifield on GF(9) has been verified as a proper quasifield (non-associative, right-distributive). The next step is to explicitly construct the Hall projective plane of order 9 as a `ProjectivePlane` instance using the standard coordinatization: points are `(x, y)` pairs plus ideal points, lines are `y = x ○ m + b` plus the line at infinity. Then exhibit a concrete Desargues configuration that fails — providing a fully machine-verified witness that non-Desarguesian planes exist.

The key insight is that the Frobenius twist in Hall multiplication (`hallMul x y = gf9Mul (frobenius3 x) y` when `y ∉ GF(3)`) creates a "kink" in perspectivities that breaks the Desargues collinearity condition for specific triangle pairs. The concrete witness is computable from the non-associativity triple `((0,1), (0,1), (1,1))` we already verified.

Why now? We have all the algebraic infrastructure verified (quasifield axioms, Frobenius properties, non-associativity witness). The remaining work is purely combinatorial: defining the 91-point/91-line incidence structure and checking the failing Desargues configuration by `native_decide`.

## 2. Dual Projective Plane and Self-Duality

We proved that the line_unique and point_unique axioms swap perfectly under duality. The missing piece is the general position axiom for the dual: showing that four points in general position give rise to (at least) four lines in general position.

The key insight is that from four points in general position {a, b, c, d}, the six lines they determine contain four lines — say ab, ac, bd, cd — no three of which are concurrent. This follows from: if three of these lines met at a point p, then p together with three of {a,b,c,d} would give three collinear points from the original quadrilateral, contradicting general position.

Why now? The proof is a short case analysis on which triples of the six lines could be concurrent, and each case leads to a contradiction with one of the four "no three collinear" hypotheses. This is cleanly formalizable and completes a fundamental structural theorem.

## 3. Non-Desarguesian Planes at Every Prime-Power Order ≥ 9

Hall's 1943 construction generalizes: for any prime power q = p^k with k ≥ 2, one can build a Hall quasifield on GF(q) by applying the Frobenius automorphism σ: x ↦ x^p to the left factor when the right factor is outside GF(p). This produces a non-associative quasifield (and hence a non-Desarguesian plane) at every order q ≥ 9.

The key insight is that the Frobenius automorphism σ is non-trivial iff [GF(q) : GF(p)] ≥ 2, which happens iff q is not prime. For q prime, GF(q) = GF(p) and σ = id, so the Hall construction collapses to the field — explaining why non-Desarguesian planes of prime order are much harder (and conjectured not to exist for primes > 2).

Why now? Mathlib has `GaloisField` and Frobenius endomorphisms formalized. The generalization from our GF(9) construction to GF(p^k) requires parameterizing by p and k and verifying that the same algebraic properties (right distributivity, non-associativity) hold generically. The non-associativity proof reduces to showing σ ≠ id, which follows from k ≥ 2.

## 4. Collineation Group Bounds

We defined collineations (incidence-preserving bijections) and stated that non-Desarguesian planes have strictly smaller collineation groups than PGL(3,q). The next step is to prove this rigorously: show that the Hall plane of order q has collineation group of order q^2 · (q-1)^2 · 2k (where q = p^k), compared to |PGL(3,q)| = q^3(q^3-1)(q^2-1).

The key insight is that collineations of a translation plane decompose as: translations (q^2 of them), dilatations (q-1), automorphisms of the quasifield kernel (k choices from GF(p)-linearity), and at most a duality factor. The non-associativity of the quasifield prevents the full GL(3,q) from acting, because GL(3,q)-type transformations would need to preserve an associative multiplication law.

Why now? The quasifield structure is verified. Bounding the collineation group requires showing that every collineation induces an automorphism of the coordinatizing quasifield, and then bounding the automorphism group of the Hall quasifield. The key lemma — that quasifield automorphisms are GF(p)-semilinear — is tractable with our current infrastructure.

## 5. Ternary Rings and the Classification Hierarchy

Every projective plane can be coordinatized by a planar ternary ring (PTR). The algebraic hierarchy — PTR ⊃ quasifield ⊃ semifield ⊃ division ring — corresponds to increasingly strong geometric properties: translation plane, Moufang plane, Desarguesian plane. Formalizing this hierarchy and proving the implications (each level implies the one above) would give a complete algebraic classification theory.

The key insight is that each step in the hierarchy corresponds to a single geometric axiom being satisfied: right distributivity gives translation invariance, left distributivity gives the Moufang condition (minor Desargues), and associativity gives the full Desargues theorem. Our quasifield formalization is the middle of this chain.

Why now? We have the quasifield level done. The PTR level above it requires only weakening the axioms (removing right distributivity). The semifield and division ring levels below require adding left distributivity and associativity respectively. The geometric implications (e.g., "right distributivity ⟺ translation plane") are classical theorems with clean proofs that decompose into small verifiable lemmas.
