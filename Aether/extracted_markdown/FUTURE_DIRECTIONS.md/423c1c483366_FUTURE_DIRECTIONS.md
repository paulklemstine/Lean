# Future Directions — Tropical Scheme Theory: Tropical Ideals and Gröbner Bases

## Synthesis

This cold-start cycle established a rigorous, fully-formal foundation for *tropical
scheme theory* by identifying the right ambient object: the polynomial semiring
`Polynomial T` over the tropical (min-plus) semiring `T = Tropical (WithTop ℝ)`.
The key structural realization is that the framing's notion of a "tropical ideal —
a subsemimodule of the tropical polynomial semiring closed under tropical linear
combinations" is *exactly* `Ideal (Polynomial T) = Submodule (Polynomial T)
(Polynomial T)`. Because `T` is a `CommSemiring` with **no additive inverses**,
this is a genuine semimodule statement, and we get Mathlib's entire ideal/span
lattice API for free while the genuinely tropical content lives in how the
coefficients combine. We made that content explicit: tropical polynomial addition
is coefficientwise `min` (`tropAdd_coeff_eq_min`), and multiplication is the
tropical convolution — a `min` over the antidiagonal/Minkowski decomposition
(`tropMul_coeff_eq_inf`). These two facts are the combinatorial substrate of every
tropical Gröbner reduction.

On the Gröbner side we proved the two prototype results a Buchberger algorithm
rests on. First, the *staircase membership criterion* for the tropical monomial
ideal `⟨xᵈ⟩` (`tropMonomialIdeal_staircase`): membership is purely combinatorial —
all coefficients below degree `d` must be the tropical zero. Second, the
*single-generator Buchberger criterion* (`tropGroebner_div_criterion`): in a
principal tropical ideal, leading degrees can only grow, so a singleton is
automatically a tropical Gröbner basis (there are no S-polynomials to reduce). The
crux of this proof was that `T` has **no zero divisors**, which is what makes
`natDegree` additive and the leading-monomial divisibility hold.

What did *not* close this cycle is the multivariate finite-generation statement
(`tropMv_dickson_finite_generation`), left as a `conjecture`. The univariate
arguments degenerate because the leading-term (initial) ideal is principal in one
variable; the real Buchberger phenomenon — non-principal initial ideals and
mandatory S-polynomial reduction — only appears with ≥ 2 generators in ≥ 2
variables, and termination there needs a tropical Dickson lemma (well-quasi-order
of exponent vectors). That gap is the natural seed for the next cycle.

## Results Summary

- `tropAdd_coeff_eq_min`: proved — tropical polynomial addition is coefficientwise tropical `min`, certifying that ideal addition is the tropical linear-combination sum.
- `tropMul_coeff_eq_inf`: proved — tropical polynomial multiplication is the tropical convolution (`min` over the antidiagonal), the Minkowski-sum combinatorics underlying Gröbner reduction.
- `trop_linear_combination_mem`: proved — tropical ideals are closed under tropical linear combinations `c ⊙ a ⊕ d ⊙ b`, the defining subsemimodule axiom (a genuine semimodule, since `T` lacks additive inverses).
- `tropMonomialIdeal_staircase`: proved — staircase/Gröbner membership criterion for the tropical monomial ideal `⟨xᵈ⟩`.
- `tropGroebner_div_criterion`: proved — single-generator Buchberger criterion: every nonzero element of a principal tropical ideal has leading monomial divisible by the generator's, so a singleton is a tropical Gröbner basis.
- `tropMv_dickson_finite_generation`: conjecture (sorry) — every tropical monomial ideal in several variables is finitely generated (tropical Dickson), the termination input for a multivariate tropical Buchberger algorithm.

## Research Directions

### Direction 1: Multivariate tropical Dickson lemma and finite generation
**Hypothesis**: Every tropical *monomial* ideal in `MvPolynomial (Fin n) T` is finitely generated, and more strongly every tropical ideal whose initial ideal is monomial is finitely generated.
**Test**: Discharge `tropMv_dickson_finite_generation` by transporting Mathlib's well-quasi-order machinery on `Fin n →₀ ℕ` (`Finsupp`/`Set.IsPWO`, Dickson's lemma) to the support sets of generators; produce an explicit finite generating set from minimal exponent vectors.
**Why now**: This cycle pinned down the exact ambient object (`Ideal (Polynomial T)`) and proved the univariate base case, isolating the *only* missing ingredient — a combinatorial well-foundedness statement that is independent of the tropical arithmetic.
**If true**: Tropical Buchberger termination becomes provable, and the tropical polynomial semiring is "Noetherian for monomial ideals," opening tropical primary decomposition.
**If false**: It would expose a pathology of subsemimodules without additive inverses, sharpening exactly which classical commutative-algebra theorems survive tropicalization.

### Direction 2: Tropical S-polynomial and a two-generator Buchberger step
**Hypothesis**: For two univariate generators `f, g` with `natDegree f = natDegree g`, the tropical S-pair `min`-cancellation reduces to a strictly lower leading degree, and iterating yields a finite Gröbner basis.
**Test**: Define the tropical S-polynomial via `tropMul_coeff_eq_inf` (align leading monomials by scalar shifts `C c`, then take the coefficientwise `min` from `tropAdd_coeff_eq_min`) and prove the leading degree strictly drops; package as a terminating recursion on `natDegree`.
**Why now**: `tropMul_coeff_eq_inf` and `tropAdd_coeff_eq_min` give exact formulas for the two operations an S-polynomial is built from, and `tropGroebner_div_criterion` already controls leading degrees of multiples.
**If true**: First fully-formal tropical Buchberger step beyond the singleton case.
**If false**: The failure point identifies whether tropical S-reduction needs more than degree control (e.g. coefficient genericity).

### Direction 3: Initial (leading-term) ideals and a Gröbner-basis characterization
**Hypothesis**: A finite set `G` is a tropical Gröbner basis of `I = ⟨G⟩` iff the tropical monomial ideal generated by the leading monomials of `G` equals the initial ideal `in(I)`.
**Test**: Define `initialIdeal I := Ideal.span {X^(natDegree p) | p ∈ I, p ≠ 0}`, prove `in(⟨g⟩) = ⟨X^(natDegree g)⟩` from `tropGroebner_div_criterion`, then state and prove the iff in the univariate case before generalizing.
**Why now**: `tropMonomialIdeal_staircase` gives the membership test for these monomial initial ideals, and `tropGroebner_div_criterion` already computes the principal case.
**If true**: A clean, checkable definition of "tropical Gröbner basis" usable as a specification for algorithms.
**If false**: Reveals that the tropical initial ideal carries strictly less information than in the classical setting (a known subtlety for tropical ideals à la Maclagan–Rincón).

### Direction 4: Bridge to tropical varieties — the corner/non-differentiability locus
**Hypothesis**: For `p : Polynomial T`, the tropical variety `V(p)` (points where the evaluation `min_i (c_i + i·x)` is attained ≥ twice) is determined by the convolution data in `tropMul_coeff_eq_inf`, and `V(p·q) = V(p) ∪ V(q)`.
**Test**: Define evaluation `evalTrop p x := untrop (eval (trop x) p)` and the bend locus, then prove the union law using `tropMul_coeff_eq_inf` to relate the bend loci of a product to those of its factors.
**Why now**: `tropMul_coeff_eq_inf` gives the precise piecewise-linear structure of products, the exact data the bend locus reads off.
**If true**: Connects the ideal-theoretic side proved here to the geometric side (tropical hypersurfaces), enabling a `Nullstellensatz`-style statement.
**If false**: Pinpoints where the semiring/lattice mismatch breaks the scheme↔variety correspondence tropically.

### Direction 5: No-zero-divisors as the load-bearing axiom — boundary analysis
**Hypothesis**: `tropGroebner_div_criterion` (leading-degree monotonicity in principal ideals) is *equivalent* to `T` being a domain; replacing `T` by a tropical semiring that does admit zero divisors (e.g. a quotient/`WithTop` of a non-cancellative monoid) makes the criterion fail.
**Test**: Construct a small tropical-style coefficient semiring with `a ⊙ b = 0` for nonzero `a,b`, exhibit `g, r ≠ 0` with `natDegree (g*r) < natDegree g`, giving an explicit counterexample to the analogue of `tropGroebner_div_criterion`.
**Why now**: This cycle isolated `NoZeroDivisors` as the single nontrivial hypothesis powering the Buchberger criterion; a counterexample at the boundary is now a concrete finite construction.
**If true**: Cleanly delineates the class of tropical coefficient semirings for which Gröbner theory is well-behaved.
**If false**: Would mean degree monotonicity is more robust than expected, suggesting a weaker sufficient condition than being a domain.
