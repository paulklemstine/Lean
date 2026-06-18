# Future Directions: Formal Hilbert 16 Program

## Conjecture 1: Certified Quartic Oval Classification

**Statement:** Every smooth real quartic curve (degree 4, squarefree polynomial with smooth projective closure) has a real locus whose topological type belongs to exactly one of 6 distinct oval arrangement classes, and the maximum oval count is exactly 4 (realized by Harnack's construction).

**Test:** Formalize the 6 topological types as `Finset`-valued invariants. For each type, construct an explicit polynomial witness in Lean using `MvPolynomial (Fin 2) ℝ` and verify:
- The polynomial has total degree 4.
- The discriminant condition (smoothness proxy) is satisfied.
- A certified component-count procedure (via Sturm chain or cylindrical algebraic decomposition) produces the expected oval count.

**Confirm/Refute:** Implement a decision procedure for the topological type of a quartic given its coefficient vector. Run on parametric families `a·x⁴ + b·x²y² + c·y⁴ + d·x² + e·y² + f = 0` and verify that the computed type always belongs to the classified list.

**Impact:** Produces the first machine-checked classification of real quartic curves. Validates the formal infrastructure against a fully understood case. Opens the door to degree-5 and degree-6 classification.

---

## Conjecture 2: Harnack Bound via Formalized Smith–Thom Inequality

**Statement:** For a smooth real projective variety `X` of dimension `n` defined over ℝ, with complex conjugation involution `σ`, the sum of mod-2 Betti numbers of the real locus `X(ℝ)` is at most the sum of mod-2 Betti numbers of the complex locus `X(ℂ)`:

$$\sum_i \dim H_i(X(\mathbb{R}); \mathbb{F}_2) \leq \sum_i \dim H_i(X(\mathbb{C}); \mathbb{F}_2)$$

For smooth plane curves, this specializes to: number of ovals ≤ genus + 1.

**Test:** Formalize the Smith–Thom inequality for finite CW complexes with a cellular involution using the `FinChainComplex` infrastructure from the Morse theory catalog. Derive the Harnack bound as a corollary by computing the Betti numbers of smooth complex plane curves (which are compact Riemann surfaces of known genus).

**Confirm/Refute:** The inequality is true (classical theorem). The test is whether it can be formalized in ≤ 500 lines of Lean 4, reusing the existing chain complex infrastructure. If the proof requires > 1000 lines or substantial new homological algebra, this indicates gaps in Mathlib's coverage that should be documented.

**Impact:** Replaces the axiomatic Harnack bound with a fully derived theorem, making the entire degree → genus → oval chain machine-checked from first principles. This would be the strongest formal result in real algebraic geometry to date.

---

## Conjecture 3: Nesting Depth of Ovals is Bounded by ⌊d/2⌋ from Bézout's Theorem

**Statement:** For a smooth real plane curve of degree `d`, the nesting depth of the oval arrangement (length of the longest chain in the nesting partial order) is at most ⌊d/2⌋. This follows from Bézout's theorem: a line meeting an oval of the real curve must intersect it in an even number of points (entering and exiting), and can meet the entire curve in at most `d` points total.

**Test:** Formalize Bézout's theorem for plane curves at the level of intersection multiplicity (using `MvPolynomial` resultants). Prove that a generic line meeting `k` nested ovals intersects the curve in at least `2k` points, hence `2k ≤ d`, giving `k ≤ ⌊d/2⌋`.

**Confirm/Refute:** The bound is tight: construct explicit curves of each degree with nesting depth exactly ⌊d/2⌋. For degree 4, an ellipse inside an ellipse achieves depth 2 = ⌊4/2⌋.

**Impact:** Derives the depth bound from algebraic geometry (Bézout) rather than taking it as an axiom. Creates a formal bridge between intersection theory and oval topology.

---

## Conjecture 4: Persistent Periodic Orbits under Hamiltonian Perturbation

**Statement:** For a polynomial Hamiltonian `H` of degree `d` and a small polynomial perturbation `εg` (with `g` of degree ≤ d), the number of limit cycles of the perturbed system `ẋ = Hᵧ + εgᵧ, ẏ = -Hₓ - εgₓ` that bifurcate from periodic orbits of the unperturbed system is bounded by the number of zeros of the Abelian integral `I(h) = ∮_{H=h} g dy - g dx` as a function of the energy parameter `h`.

For `d = 3` (cubic Hamiltonian with quadratic perturbation), the Abelian integral is an elliptic integral, and the number of zeros is at most 1 (the Bogdanov–Takens case).

**Test:** Formalize the Abelian integral as a function of energy. For `H(x,y) = y²/2 + x³/3 - x` and general quadratic perturbation, compute `I(h)` symbolically and verify that it has at most 1 zero for `h` in the bounded component range `(-2/3, 2/3)`.

**Confirm/Refute:** The bound of 1 zero is known for this case (Bogdanov–Takens bifurcation). The test is whether the formal integral computation and zero-counting can be certified. Attempt with both symbolic and interval arithmetic approaches.

**Impact:** Produces the first formally verified limit-cycle count for a specific polynomial system. Directly addresses Hilbert 16 Part II for the simplest nontrivial case.

---

## Conjecture 5: Discrete Morse Theory Gives Tighter Component Bounds for Curves with Symmetry

**Statement:** For a smooth real plane curve of degree `d` that is invariant under a finite group `G ≤ O(2)` of symmetries, a `G`-equivariant discrete Morse function on the CW decomposition of S² induced by the curve yields an upper bound on oval count that is strictly tighter than the Harnack bound `(d-1)(d-2)/2 + 1`.

Specifically, for `G = ℤ/2 × ℤ/2` (the symmetry group of an axis-aligned curve), the bound should be roughly `(d-1)(d-2)/4 + 1` for the number of orbits of ovals under `G`.

**Test:** Construct the CW decomposition for the curve `x⁴ + y⁴ = 1` (which has `G = D₄` symmetry). Apply the discrete Morse inequality from `DiscreteMorseInequalities.lean` to the quotient complex `S²/G`. Compare the resulting bound with the Harnack bound (which gives 4 for degree 4) and with the actual oval count (which is 1 for this particular curve).

**Confirm/Refute:** Build explicit cell decompositions for 3–5 symmetric curves of degrees 4, 6, and 8. For each, compute the Morse-theoretic bound and compare with both Harnack and the actual oval count. Document cases where the equivariant bound is strictly better.

**Impact:** Opens a new formal approach to Hilbert 16 through computational topology. The equivariant Morse method could yield the first machine-checkable improvement over Harnack for structured curve families.
