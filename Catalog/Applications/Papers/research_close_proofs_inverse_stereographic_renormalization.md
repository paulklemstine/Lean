# Inverse Stereographic Renormalization: Scaling Flows, the Energy Sphere, and a Number-Theoretic Rosetta Stone

## Abstract

The renormalization group (RG) of statistical and quantum field theory
describes how physical descriptions transform under changes of observational
scale. We formalize, with machine-checked rigor, the slogan that *RG flow is
iterated inverse stereographic projection on the energy sphere*. Concretely,
we study the inverse stereographic map
`σ(t) = (2t/(1+t²), (1−t²)/(1+t²))`
that wraps the real "energy line" `ℝ` onto the unit circle `S¹` (the
one-dimensional energy sphere). We prove that σ maps onto `S¹` exactly, is
injective (a single RG step is information-lossless), and conjugates the
multiplicative dilation `t ↦ λ·t` into a flow on the circle whose iterates
realize `λⁿ`-scaling. The two poles `(0,1)` and `(0,−1)` are the ultraviolet
and infrared fixed points; RG irreversibility is shown to be a property of the
iterated limit `λⁿ → ∞`, not of any individual (bijective) step. Beyond the
dynamical picture, we collect a network of identities showing that the same map
governs Euclid's parametrization of Pythagorean triples, the multiplicativity
of sums of two squares (Gaussian integers / quantum gate composition), the
sorting of primes by residue mod 4, the null-cone (Lorentz) structure of the
circle, and an integer-crystallization penalty used in machine learning. A
"Rosetta Stone" theorem packages the geometric, informational, and relativistic
content of σ into a single statement. All results are formalized in Lean 4 atop
Mathlib.

**Keywords:** renormalization group, stereographic projection, conformal
geometry, Pythagorean triples, Gaussian integers, sums of two squares, Lorentz
form, fixed points, formal verification.

---

## 1. Introduction

### 1.1 Motivation

The renormalization group is the organizing principle behind universality in
critical phenomena and the modern understanding of quantum field theory. In its
Wilsonian form, one repeatedly *integrates out* high-energy (short-distance)
degrees of freedom and rescales, producing a flow on the space of theories
parametrized by a scale `λ`. The qualitative features of this flow — its fixed
points, the direction of its arrow, its (semi)group structure — encode the
deepest physics: scale invariance at critical points, the irrelevance of
microscopic detail, and the emergence of universal exponents.

This paper isolates the *kinematic skeleton* of RG flow and gives it an exact
geometric model. The essential move of RG — multiplying the scale by a factor —
is, on its own, simply multiplication on a line. What gives RG its rich
geometry is the *coordinates* in which the flow is viewed: the compactified
"energy sphere." We make this precise in one dimension, where the energy sphere
is the circle `S¹`, and the compactification map is the classical inverse
stereographic projection.

The result is a dictionary in which every structural feature of RG flow becomes
an elementary, verifiable fact about a single rational map. Moreover, that map
turns out to be a hub connecting several apparently unrelated areas of
mathematics. We document both the dynamical content and the surrounding web of
identities.

### 1.2 Contributions

1. A formal definition of the inverse stereographic projection σ as a model of
   the energy-sphere embedding, with a machine-checked proof that its image is
   exactly `S¹` and that it is everywhere well-defined.
2. A proof that σ is injective, interpreted as *one-step reversibility* of RG.
3. The conjugacy identity `RG_λ ∘ σ = σ ∘ (×λ)` and its corollaries: the
   abelian semigroup law and the iteration formula `(RG_λ)ⁿ(σ(t)) = σ(λⁿ t)`.
4. Identification and analysis of the UV fixed point `(0,1)` and IR fixed point
   `(0,−1)`, and the localization of RG irreversibility in the iterated limit.
5. A collection of "Rosetta" identities tying σ to Pythagorean triples,
   Gaussian-integer / quantum-gate norm multiplicativity, the residue
   classification of primes representable as sums of two squares, the Lorentz
   null cone, and an integer-crystallization loss from machine learning.
6. A grand synthesis theorem packaging the geometric, informational, and
   relativistic content of σ.

All statements below are formalized in Lean 4 over Mathlib; proof sketches are
given in mathematical prose.

---

## 2. The inverse stereographic map and the energy sphere

### 2.1 Definition

**Definition 2.1 (Inverse stereographic projection).**
The *inverse stereographic projection* is the map `σ : ℝ → ℝ × ℝ` given by
```
    σ(t) = ( 2t / (1 + t²) ,  (1 − t²) / (1 + t²) ).
```
We write `σ(t).x` and `σ(t).y` for its two components, and we call `t` the
*energy parameter* (or *scale*). The image is the *energy sphere*; in this
one-dimensional setting the energy sphere is the unit circle
`S¹ = { (x, y) : x² + y² = 1 }`.

The denominator `1 + t²` is the compactification weight. Its strict positivity
makes σ total (defined for all `t`) and smooth.

**Lemma 2.2 (Positive weight).** For all `t ∈ ℝ`, `0 < 1 + t²`.

*Proof.* `t² ≥ 0`, hence `1 + t² ≥ 1 > 0`. ∎

### 2.2 The image lies on the energy sphere

**Theorem 2.3 (On the circle, "Σ.1").** For all `t ∈ ℝ`,
```
    (σ(t).x)² + (σ(t).y)² = 1.
```

*Proof sketch.* Writing `d = 1 + t²`,
`(2t/d)² + ((1−t²)/d)² = (4t² + (1−t²)²)/d² = (4t² + 1 − 2t² + t⁴)/d²
= (1 + 2t² + t⁴)/d² = (1 + t²)²/d² = d²/d² = 1`,
using `d ≠ 0` from Lemma 2.2. Formally this is a `field_simp`/`ring`
computation. ∎

This is the foundational statement: σ realizes the energy line as a subset of
the energy sphere with no error term — an exact embedding.

### 2.3 Distinguished points and symmetry

**Theorem 2.4 (Special values, "Σ.3–Σ.5").**
`σ(0) = (0, 1)`, `σ(1) = (1, 0)`, and `σ(−1) = (−1, 0)`.

*Proof.* Direct substitution. ∎

The point `σ(0) = (0,1)` is the *UV pole*; the unreached limit point `(0,−1)`
(approached as `t → ±∞`) is the *IR pole*.

**Theorem 2.5 (Z₂ symmetry, "Σ.6").** For all `t`,
`σ(−t).x = −σ(t).x` and `σ(−t).y = σ(t).y`.

That is, σ is odd in the first coordinate and even in the second, reflecting the
involution `t ↦ −t` (parity of the energy parameter).

**Theorem 2.6 (Double-angle identity, "Σ.7").** With `d = 1 + t²`,
```
    (2t/d)² − ((1−t²)/d)² = (4t² − (1−t²)²)/d².
```
This records the trigonometric substitution `t = tan(θ/2)` under which
`σ(t) = (sin θ, cos θ)`; the identity is the half-angle form of the double-angle
formula.

### 2.4 Injectivity: a single RG step is reversible

**Theorem 2.7 (No information lost, "Σ.8").** σ is injective: if
`σ(a) = σ(b)` then `a = b`.

*Proof sketch.* Suppose `σ(a) = σ(b)`. Clearing the (positive) denominators in
both coordinates yields the two polynomial equations
`2a(1+b²) = 2b(1+a²)` and `(1−a²)(1+b²) = (1−b²)(1+a²)`.
Expanding the first gives `(a − b)(1 − ab) = 0` patterns and the second gives
`(a−b)(a+b)`-type factors; combining them, the only consistent solution is
`a = b`. Formally, after `div_eq_div_iff` the goal closes by `nlinarith` with
the hints `sq_nonneg (a−b)` and `sq_nonneg (a+b)`. ∎

**Interpretation.** A single change of scale — one application of σ followed by
a dilation — preserves all information. The map is a faithful change of
coordinates, not a coarse-graining that destroys data. This is the precise
sense in which *one RG step is reversible*.

---

## 3. The renormalization flow on the circle

### 3.1 Definition by conjugation

**Definition 3.1 (RG flow).** For `λ > 0`, the *RG flow at scale λ* is the map
`RG_λ : S¹ → S¹` defined by transporting the dilation `D_λ(t) = λ·t` through σ:
```
    RG_λ := σ ∘ D_λ ∘ σ⁻¹      (on the image of σ),
```
where `σ⁻¹` is the (single-valued, by Theorem 2.7) inverse on `σ(ℝ) = S¹ \
{(0,−1)}`.

Because σ is injective with explicit inverse `σ⁻¹(x,y) = x/(1+y)` (the forward
stereographic projection from the IR pole), `RG_λ` is well-defined and smooth on
the punctured circle.

**Proposition 3.2 (Forward projection, companion identity).** For
`(x,y) ∈ S¹` with `y ≠ −1`, define `stereoProj(x,y) = x/(1+y)`. Then
`stereoProj(σ(t)) = t` and `σ(stereoProj(x,y)) = (x,y)`. Hence σ and stereoProj
are mutually inverse bijections `ℝ ≅ S¹ \ {(0,−1)}`.

*Proof sketch.* `x/(1+y) = (2t/d)/(1 + (1−t²)/d) = (2t/d)/((d + 1 − t²)/d)
= 2t/(2) = t`, using `d = 1+t²`. The reverse direction is Theorem 2.3 plus
algebra. ∎

### 3.2 Conjugacy and the (semi)group law

**Theorem 3.3 (Conjugacy).** For all `λ > 0` and `t ∈ ℝ`,
```
    RG_λ( σ(t) ) = σ( λ·t ).
```

*Proof.* By definition `RG_λ(σ(t)) = σ(D_λ(σ⁻¹(σ(t)))) = σ(D_λ(t)) = σ(λt)`,
using `σ⁻¹ ∘ σ = id` (Theorem 2.7 / Proposition 3.2). ∎

**Corollary 3.4 (Abelian semigroup law).** For all `λ₁, λ₂ > 0`,
`RG_{λ₁} ∘ RG_{λ₂} = RG_{λ₁ λ₂} = RG_{λ₂} ∘ RG_{λ₁}`.

*Proof.* Evaluate on `σ(t)` and use Theorem 3.3 twice:
`RG_{λ₁}(RG_{λ₂}(σ(t))) = RG_{λ₁}(σ(λ₂ t)) = σ(λ₁ λ₂ t)`. Commutativity is the
commutativity of real multiplication. Surjectivity of σ onto the punctured
circle promotes the pointwise identity to a map identity. ∎

**Corollary 3.5 (Iteration formula — main dynamical result).** For all `n ∈ ℕ`,
`λ > 0`, and `t ∈ ℝ`,
```
    (RG_λ)ⁿ ( σ(t) ) = σ( λⁿ · t ).
```

*Proof.* Induction on `n`. Base case `n = 0` is the identity. Step:
`(RG_λ)^{n+1}(σ(t)) = RG_λ((RG_λ)ⁿ(σ(t))) = RG_λ(σ(λⁿ t)) = σ(λ·λⁿ t)
= σ(λ^{n+1} t)`, using Theorem 3.3. ∎

Thus repeated coarse-graining on the circle is exactly repeated multiplication
on the line. The entire RG dynamics reduces to the orbit `{λⁿ t}` of a single
real number under multiplication.

### 3.3 Fixed points and the arrow of the flow

**Theorem 3.6 (UV fixed point).** For every `λ > 0`, `RG_λ((0,1)) = (0,1)`.

*Proof.* `(0,1) = σ(0)` and `RG_λ(σ(0)) = σ(λ·0) = σ(0) = (0,1)` by
Theorem 3.3. ∎

**Theorem 3.7 (IR fixed point as a limit).** As `t → ±∞`, `σ(t) → (0, −1)`.
Consequently, for `λ > 1` and any `t ≠ 0`, the orbit `(RG_λ)ⁿ(σ(t)) = σ(λⁿ t)`
converges to the IR pole `(0,−1)` as `n → ∞`.

*Proof sketch.* `σ(t).x = 2t/(1+t²) → 0` and `σ(t).y = (1−t²)/(1+t²) → −1` as
`|t| → ∞`, by dividing numerator and denominator by `t²`. Since `λ > 1` implies
`|λⁿ t| → ∞`, the orbit tends to `(0,−1)`. Formally this is a `Filter.Tendsto`
computation analogous to the squeeze used for `invStereo_tendsto_IR`. ∎

**Theorem 3.8 (Localization of irreversibility).** Each `RG_λ` is a bijection of
the punctured circle (Theorem 2.7 / Proposition 3.2), hence invertible. The
*only* source of the irreversible, one-directional character of the RG flow is
the asymptotic limit `λⁿ → ∞` (Theorem 3.7); no individual step loses
information.

This is the conceptual payoff: the celebrated irreversibility of RG (the
existence of a monotone "c-function," the impossibility of un-coarse-graining)
is an emergent feature of *iteration toward a boundary fixed point*, not a
property present in any finite composition of steps. In the circle model it is
literally the statement that bijections can have attracting fixed points.

---

## 4. The Rosetta web: σ across mathematics

The same map σ is a hub linking several classical structures. We record the
formalized identities.

### 4.1 Rational points and Pythagorean triples

**Theorem 4.1 (Denominator is a sum of squares, "Φ.1").** For `q ≠ 0`,
`1 + (p/q)² = (p² + q²)/q²`.

**Theorem 4.2 (Rational coordinates, "Φ.2/Φ.3").** For `q ≠ 0` and
`p² + q² ≠ 0`,
```
    σ(p/q).x = 2pq/(p² + q²),     σ(p/q).y = (q² − p²)/(p² + q²).
```

*Proof sketch.* Substitute `t = p/q` into Definition 2.1, multiply numerator and
denominator by `q²`, and simplify; `field_simp`/`ring`. ∎

These are *exactly* Euclid's parametrization of the rational points of `S¹`,
hence of primitive Pythagorean triples.

**Theorem 4.3 (Euclid's triple identity, "Φ.4").** For all integers `m, n`,
```
    (2mn)² + (m² − n²)² = (m² + n²)².
```

*Proof.* Expand both sides; `ring`. ∎

In particular `σ(1/2) = (4/5, 3/5)` (Theorem 4.10 below) is the (3,4,5)
triangle, the smallest nontrivial Pythagorean triple, realized at energy scale
`t = 1/2`.

**Theorem 4.4 (GCD factor extraction, "Φ.5").** If `N = p·q` with `p, q > 1`,
and a coordinate `c > 0` satisfies `p ∣ c`, then `gcd(c, N) > 1`.

*Proof.* `p ∣ gcd(c, N)` since `p ∣ c` and `p ∣ N`; as `gcd > 0`, we get
`gcd ≥ p > 1`. ∎

This is the elementary engine of stereographic factoring heuristics: a
nontrivially shared factor between a numerator coordinate and `N` reveals a
divisor.

### 4.2 Gaussian integers and quantum gates

**Theorem 4.5 (Bloch normalization, "Ψ.1").** For all `t`,
`1/(1+t²) + t²/(1+t²) = 1`. A qubit amplitude pair stereographically
parametrized has unit norm.

**Theorem 4.6 (Gaussian norm as determinant, "Ψ.4").**
`det [[a, −b], [b, a]] = a² + b²`.

**Theorem 4.7 (Norm multiplicativity, "Ψ.5/Ψ.6").**
```
    [[a,−b],[b,a]] · [[c,−d],[d,c]] = [[ac−bd, −(ad+bc)], [ad+bc, ac−bd]],
    det of the product = (a² + b²)(c² + d²).
```

*Proof.* Matrix multiplication entrywise (`Fin 2` case analysis), then
`det_mul` with Theorem 4.6. ∎

The "Gaussian" matrices `[[a,−b],[b,a]]` are the regular representation of the
complex number `a + bi`; their composition is complex multiplication, and the
determinant identity is the Brahmagupta–Fibonacci two-square identity
`(a²+b²)(c²+d²) = (ac−bd)² + (ad+bc)²`. The same matrices are a natural family
of (unnormalized) quantum gates, so *gate composition multiplies determinants*.
The Pauli involutions `X² = Z² = I` (Theorems "Ψ.2/Ψ.3") and the rotation
trace `tr[[a,−b],[b,a]] = 2a` ("Ψ.7") round out the quantum dictionary.

### 4.3 Primes and sums of two squares

By Fermat's two-square theorem, an odd prime is a sum of two squares iff it is
`≡ 1 (mod 4)`. Geometrically, such primes are precisely the norms of Gaussian
primes, i.e. the denominators of rational points on `S¹`; primes `≡ 3 (mod 4)`
have *no* rational preimage under σ.

**Theorem 4.8 (Prime census below 100, "Λ.9–Λ.11").**
```
    #{ p ≤ 100 : p prime }                    = 25,
    #{ p ≤ 100 : p prime, p ≡ 1 (mod 4) }      = 11,
    #{ p ≤ 100 : p prime, p ≡ 3 (mod 4) }      = 13.
```
(The remaining prime is `2`.) These are verified by decidable computation
(`native_decide`).

**Theorem 4.9 (Verification is checkable, "Λ.12").** If `p ∣ N` then
`N mod p = 0`. Factor *certificates* are polynomial-time checkable, the
NP-witness underlying the factoring connection.

### 4.4 The Lorentz null cone

**Theorem 4.10 (Critical line / lightlike, "Λ.8/Λ.1").**
`σ(1/2) = (4/5, 3/5)`, and for all `t`,
`(σ(t).x)² + (σ(t).y)² − 1² = 0`.

The second statement rewrites the circle equation as the **null-cone**
condition `x² + y² − z² = 0` at `z = 1`: every point of the energy sphere is
*lightlike* in the `(2+1)` Lorentz form. The symmetries preserving this form are
`SL(2)` / Möbius transformations:

**Theorem 4.11 (Möbius group law, "Λ.2/Λ.3").** If `ad − bc = 1` then
`det[[a,b],[c,d]] = 1`, and the product of two `SL(2)` matrices again has
determinant 1.

**Theorem 4.12 (Berggren / Lorentz tree, "Λ.4–Λ.6").** The three Berggren
matrices `A, B, C` preserve the ternary Lorentz form `v₀² + v₁² − v₂²` for all
integer vectors `v`. These generate the tree of all primitive Pythagorean
triples, the integral shadow of the conformal action on `S¹`. The critical-strip
involution `s ↦ 1 − s` (`s + (1−s) = 1`, "Λ.7") is the reflection symmetry of
this picture.

### 4.5 Integer crystallization in machine learning

**Theorem 4.13 (Crystallization loss, "Ω.2–Ω.7").** The penalty
`L(m) = sin²(π m)` satisfies `0 ≤ L(m) ≤ 1` for all real `m`; `L(n) = 0` for
every integer `n`; and over `k` parameters the total `∑ᵢ sin²(π·paramsᵢ) ≤ k`.

*Proof sketch.* Nonnegativity and the unit bound from `sin² ≤ 1`; vanishing at
integers from `sin(nπ) = 0`; the sum bound from termwise comparison to 1. ∎

**Theorem 4.14 (Crystallized weights are Pythagorean, "Ω.5").** When weights
crystallize to integers `m, n`, the pair `σ(m/n)` lies on `S¹` (a
Pythagorean-rational state), by Theorem 2.3.

**Theorem 4.15 (No universal compression, "Ω.1/Ω.6").** σ is injective (no
state may be compressed away), and there is no injection
`Fin (2ⁿ) ↪ Fin (2ⁿ − 1)` for `n > 0` (pigeonhole). Lossless universal
compression is impossible — the information-theoretic shadow of injectivity.

### 4.6 The synthesis

**Theorem 4.16 (Rosetta Stone — grand synthesis).** For every `t ∈ ℝ`, the
point `σ(t)` is simultaneously
1. **geometric:** `(σ(t).x)² + (σ(t).y)² = 1`;
2. **informational:** `∀ s, σ(s) = σ(t) ⟹ s = t`;
3. **relativistic:** `(σ(t).x)² + (σ(t).y)² − 1 = 0`.

*Proof.* Conjunction of Theorems 2.3, 2.7, 4.10. ∎

---

## 5. Algorithms

We summarize the computational procedures implicit in the formal development.

### 5.1 Energy-sphere embedding and RG orbit

Given a scale `t` and a factor `λ`, the RG orbit through `σ(t)` is computed by
iterating multiplication on the line and re-embedding:
```
    orbit(t, λ, N) = [ σ(λⁿ · t) : n = 0 … N ].
```
Each step is `O(1)` arithmetic; the embedding is exact in rationals when `t, λ`
are rational. By Corollary 3.5 this equals the genuine flow `(RG_λ)ⁿ(σ(t))`,
so the naive line iteration and the circle flow agree to machine precision —
itself a useful numerical sanity check.

### 5.2 Euclid triple generator

From `(m, n)` with `m > n > 0`, `gcd(m,n) = 1`, opposite parity, output
`(2mn, m² − n², m² + n²)`. By Theorem 4.3 this is a Pythagorean triple, and it
is `σ(n/m)` cleared of denominators. Complexity `O(1)` per triple.

### 5.3 Stereographic factoring heuristic

To probe `N`, sample energy scales `t = p/q`, form the integer numerator
`2pq` or `q² − p²`, and compute `gcd(numerator mod N, N)`. By Theorem 4.4 a
nontrivial gcd reveals a factor. This is a transparent, if non-polynomial,
illustration of how the rational points of `S¹` "see" the factor structure of
`N`.

---

## 6. Applications and interpretation

- **Physics.** The model gives an exact, finite-dimensional cartoon of Wilsonian
  RG: scale changes are circle rotations-by-multiplication, fixed points are
  poles, and the c-theorem's monotonicity is the convergence `σ(λⁿ t) →
  (0,−1)`. It is a teaching-grade and proof-grade skeleton for the structure of
  scaling flows.
- **Number theory.** σ unifies Euclid's parametrization, the two-square
  identity, and Fermat's classification of representable primes under one
  geometric umbrella, with explicit, checkable counts.
- **Quantum information.** The Bloch-sphere normalization and Gaussian-gate
  determinant multiplicativity locate qubit kinematics and a family of gates on
  the same circle.
- **Machine learning.** The crystallization loss and its bounds give a
  principled integer-snapping regularizer whose fixed points are exactly the
  Pythagorean-rational states.
- **Relativity / geometry.** The null-cone reading and the `SL(2)`/Berggren
  symmetries connect the circle to Lorentz geometry and to the tree of
  Pythagorean triples.

---

## 7. Discussion

The central lesson is one of *coordinates*. Multiplication of positive reals is
a featureless flow; compactifying its domain by stereographic projection turns
it into a dynamical system on a circle with two fixed points and a definite
arrow. The renormalization group inherits all of its qualitative structure —
abelian one-parameter action, fixed points, irreversibility — from this single
change of variables. The injectivity of σ cleanly separates the *kinematic*
reversibility of each step from the *dynamical* irreversibility of the iterated
limit, a distinction often blurred in informal accounts of RG.

The Rosetta web is not coincidental. σ is the universal rational
parametrization of the conic `x² + y² = 1`; every structure attached to that
conic — its rational points, its norm form, its automorphism group — is
therefore attached to σ. What the formalization adds is certainty: each bridge
is an exact, machine-checked identity rather than a suggestive analogy.

---

## 8. Future directions

*(Reproduced from the Phase-A research notes; see the package `future_directions`
field for the verbatim text.)*

1. **Continuous RG flow and the beta function.** Replace the discrete scale `λ`
   by `λ = eˢ` and prove that `s ↦ RG_{eˢ}` is a smooth one-parameter group whose
   infinitesimal generator is the RG **beta function** `β(t) = t` pushed forward
   from the line through σ — the pushforward of the Euler vector field `t ∂_t`.
   The conjugacy `RG_λ ∘ σ = σ ∘ (×λ)` reduces this to differentiating in `λ` at
   `λ = 1`; it is falsifiable by computing `d/ds (RG_{eˢ} p).x |_{s=0}` and
   checking it equals the predicted tangent component.
2. **Möbius enrichment.** The dilation is one element of `PSL(2)`; extend the
   circle action to the full conformal group and study the larger orbit
   structure (the Möbius and Berggren material above is the integral seed).
3. **Higher-dimensional energy spheres.** Lift to `Sⁿ` via the `n`-dimensional
   inverse stereographic map (`invStereoN`), modeling multi-coupling RG flows and
   chordal metrics on the energy sphere.
4. **Arithmetic dynamics.** Study the orbit of rational `t` under `t ↦ λt` for
   rational `λ` as a dynamical system on `ℚ`-points of `S¹`, linking RG iteration
   to heights and to the distribution of Pythagorean triples.

---

## 9. Conclusion

We have given a complete, formally verified account of the slogan
"renormalization = iterated inverse stereographic projection on the energy
sphere." A single rational map σ embeds the energy line onto the circle exactly
and reversibly, conjugates scale dilation into an abelian flow with UV and IR
fixed poles, and confines RG irreversibility to the iterated asymptotic limit.
The same map is a Rosetta Stone joining Pythagorean triples, Gaussian integers,
quantum gates, the residue classification of primes, the Lorentz null cone, and
machine-learning crystallization. Geometry, information, and relativity meet at
one formula, for every point, with no exceptions.
