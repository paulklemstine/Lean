# Future Directions: Hyperbolic Number Theory on the Poincaré Disk

The file `Catalog/Logic/HyperbolicDiskArithmetic.lean` establishes the algebraic
backbone of "arithmetic on a curved space": the disk automorphisms `mob a z =
(z - a)/(1 - ā z)` act on the Poincaré disk, preserve it (`mob_maps_disk`), form an
invertible group action (`mob_left_inv`), and — the centerpiece — preserve the
pseudohyperbolic distance (`pseudohyperbolic_invariant`) and hence the genuine
hyperbolic distance (`hyperbolicDist_invariant`). This is exactly the well-definedness
property that lets one speak of the hyperbolic "size" `|n|_H` of an orbit point
independently of how it was reached. The following directions extend this scaffold
toward the larger program of hyperbolic primes, factorization, and a hyperbolic zeta
function.

## 1. The pseudohyperbolic metric is a genuine metric (close the `sorry`)

The lone open statement in the file, `pseudohyperbolic_triangle`, asserts that
`ρ(z,w) = √(pdistSq z w)` satisfies the triangle inequality, upgrading the disk to a
bona fide metric space on which every `mob c` is an isometry.

**The key insight is** that the triangle inequality for `ρ` is *not* an independent
analytic fact but a direct consequence of the already-proven Möbius invariance: by
`pseudohyperbolic_invariant` one may pre-compose with `mob y` to send the middle point
`y` to the origin, where `ρ(0,·) = |·|` reduces the inequality to the ordinary triangle
inequality for `Complex.abs` combined with the elementary disk estimate
`|a ⊕ b| ≤ (|a| + |b|)/(1 + |a||b|)` for the Möbius "addition" `a ⊕ b = mob (-a) b`.

**Why now?** All the moving parts already exist in the file: invariance reduces the
problem to the origin, and the only missing lemma is a one-variable monotonicity bound
that `nlinarith`/`polyrith` can plausibly discharge once the reduction is set up.

## 2. Discreteness of the orbit `Z_H = Γ · 0` and a counting function

Define the hyperbolic integers as the orbit of `0` under a discrete subgroup
`Γ ≤ Aut(disk)` (e.g. a Fuchsian group acting via `mob`-type maps), and prove the orbit
is *discrete* and *locally finite*: every hyperbolic ball `{z : hyperbolicDist 0 z ≤ R}`
contains finitely many orbit points. Then study `N(R) = #(Z_H ∩ ball R)`.

**The key insight is** that local finiteness follows from invariance plus a packing
argument: by `hyperbolicDist_invariant` the orbit points are uniformly separated (each
sits at the center of a disjoint hyperbolic disk of fixed radius), and hyperbolic balls
have finite area, so only finitely many disjoint copies fit — turning a counting
question into an area inequality.

**Why now?** The isometry property `hyperbolicDist_invariant` is exactly the uniform
separation needed; with it, `N(R)` becomes an area-comparison estimate, and the leading
asymptotic `N(R) ∼ c·e^R` (exponential volume growth of hyperbolic space) is the honest
replacement for the speculative `R²/(2 log R)` originally conjectured.

## 3. Möbius "addition" as a commutative loop and its failure of associativity

The map `a ⊕ b := mob (-a) b` is the natural candidate for hyperbolic addition. Prove
`a ⊕ 0 = a`, `a ⊕ (⊖a) = 0` (an inverse law refining `mob_left_inv`), and the
commutativity-up-to-rotation identity, then *disprove* full associativity by exhibiting
an explicit triple where `(a ⊕ b) ⊕ c ≠ a ⊕ (b ⊕ c)`.

**The key insight is** that the non-associativity is governed precisely by hyperbolic
holonomy: the defect `((a ⊕ b) ⊕ c) ⊖ (a ⊕ (b ⊕ c))` is a pure rotation whose angle is
the area of the hyperbolic triangle with vertices `a, b, c` (the Gauss–Bonnet/Thomas
precession phenomenon), so the algebraic failure is a *geometric* quantity.

**Why now?** `mob_left_inv` and `mob_sub` already give the inverse and difference laws in
closed form; computing one explicit non-associative triple is a finite `norm_num`/`decide`
check on concrete complex numbers, making the falsification immediately mechanizable.

## 4. Convergence and a closed form for the hyperbolic zeta over a free group

For the orbit of a free Fuchsian group, define `ζ_H(s) = Σ_{n ∈ Z_H, n ≠ 0} |n|_H^{-2s}`
with `|n|_H = hyperbolicDist 0 n`, and prove **absolute convergence for `Re s > 1`** by
comparison with the orbit-counting function of Direction 2.

**The key insight is** that convergence is equivalent to summability of `e^{-2s·R}` against
`dN(R)`, so the exponential growth `N(R) ∼ c e^R` pins the abscissa of convergence at
`Re s = 1/2` for the *unsquared* exponent — recovering a critical line `Re s = 1/2`
geometrically, from volume growth rather than from any deep analytic continuation.

**Why now?** Direction 2 supplies the counting estimate, and `hyperbolicDist_invariant`
guarantees the summand depends only on the orbit point, not the group word — so the sum
is well defined and a Cauchy-condensation / integral-comparison argument over `R` settles
convergence without needing Selberg's trace formula.

## 5. A Schwarz–Pick contraction theorem for holomorphic self-maps

Generalize `pseudohyperbolic_invariant` (an *equality* for automorphisms) to the
*inequality* `pdistSq (f z) (f w) ≤ pdistSq z w` for an arbitrary holomorphic
`f : disk → disk`, with equality iff `f` is one of our `mob` maps.

**The key insight is** that the equality case already proved is the rigidity boundary of
the inequality: writing any self-map as `mob (f a) ∘ g ∘ mob (-a)` reduces Schwarz–Pick
to the classical Schwarz lemma at the origin (`|g(z)| ≤ |z|`), so the automorphism
invariance is precisely the tool that strips a general `f` down to the origin-fixing case.

**Why now?** Mathlib already contains the Schwarz lemma at the origin
(`Complex.abs_le_abs_of_mapsTo_ball`-style results); combining it with the now-available
`mob_maps_disk` and `pseudohyperbolic_invariant` turns the general contraction theorem
into a short conjugation argument rather than a from-scratch complex-analysis development.
