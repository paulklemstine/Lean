# Future Directions: Combinatorial species → tropical valuation profiles

This cycle established the **coefficientwise valuation bridge** in
`Catalog/Tropical/SpeciesValuationProfile.lean`: the `p`-adic valuation profile of a counting
sequence is a *lax tropical semiring morphism* — an exact morphism for products
(`val_mul` / `trop_val_mul`), a super-additive (ultrametric) lax morphism for sums
(`val_add` / `trop_val_add_le`), and the convolution laws `val_cauchy_ge`, `val_binConv_ge`,
`trop_val_cauchy_ge` realize the *fundamental theorem of tropical geometry* inequality
coefficientwise. It connects to the EGF dictionary of `Catalog/Applications/CombinatorialSpecies.lean`
(the binomial convolution `binConv` is the counting law of the species product).

Below are bold, testable conjectures for follow-up cycles. Each is phrased so it can be stated
as a Lean theorem and attacked directly.

## Conjecture 1 — Generic equality (unique-minimizer ⇒ tropical morphism is exact)
The bound `val_cauchy_ge` is an *inequality*. Conjecture: if the antidiagonal infimum
`⨅_{i+j=n} (val p aᵢ + val p bⱼ)` is attained at a **unique** index `(i₀, j₀)`, then equality
holds: `val p (cauchy a b n) = val p (a i₀) + val p (b j₀)`.
*Testable form:* a hypothesis `∀ x ∈ antidiagonal n, x ≠ (i₀,j₀) → s < val p (a x.1)+val p (b x.2)`
forces `val p (cauchy a b n) = s`. Proof idea: split off the unique minimal term; the rest has
strictly larger valuation, so no `p`-adic cancellation can raise the minimum. This is the
Newton-polygon "non-collinear vertex" case.

## Conjecture 2 — Kummer profile of the species product
For the binomial convolution (`binConv`, the species product), the extra term
`val p (n.choose i)` equals the number of **carries** when adding `i` and `n-i` in base `p`
(Kummer's theorem). Conjecture: the tropical valuation profile of the species product
factorizes as `(carry-count tropical kernel) ⊗ (Cauchy tropical convolution of the factor
profiles)`. *Testable form:* `val_binConv_ge` with `val p (n.choose i)` replaced by the explicit
base-`p` carry count of `(i, n-i)`, and the conjecture that the bound is tight exactly when the
minimizing index has no carries.

## Conjecture 3 — Tropical Newton polygon of an EGF / OGF
Define the **tropical valuation profile** of a species `F` as `n ↦ trop (val p (F.coeffSeq n))`.
Conjecture: the lower convex hull of `{(n, val p (coeffSeq n))}` (the `p`-adic Newton polygon)
is *sub-additive* under the species product, i.e. the Newton polygon of `F·G` lies on or above
the (tropical) Minkowski sum of the Newton polygons of `F` and `G`, with equality on vertices
of unique support. *Testable form:* a `Convex`/`lowerConvexHull` statement comparing the
polygon of `cauchy a b` to the inf-convolution of the polygons of `a` and `b`.

## Conjecture 4 — Valuation profiles separate species up to `p`-adic relabelling
The EGF transform is injective (`CombinatorialSpecies.egf_injective`). Conjecture: the *family*
of tropical valuation profiles `{n ↦ val p (coeffSeq n)}_{p prime}` together with the leading
units determines the counting sequence (a `p`-adic / tropical analogue of EGF injectivity).
*Testable form:* if two sequences `a, b : ℕ → ℕ` satisfy `val p (a n) = val p (b n)` for all
primes `p` and all `n`, and agree on a sign/unit datum, then `a = b`. (The pure-valuation
version is false — `a n` and `2·a n` can share no prime structure difference at odd `p`; the
conjecture is to find the minimal extra datum that restores injectivity.)

## Conjecture 5 — Cryptographic application: tropical valuation profiles as a side-channel invariant
Counting sequences of structured objects (e.g. weight enumerators of codes, subgroup-counting
sequences, or the orbit-counting sequences of a permutation-group action used in a cipher's key
schedule) have valuation profiles that are *invariant* under the structural product. Conjecture:
the tropical valuation profile is a complete invariant for distinguishing two product structures
`F·G` and `F'·G'` with `val`-equal factor profiles **iff** the convolution minimizers are unique
(Conjecture 1). *Testable form:* construct two species products with identical ordinary EGF but
distinct tropical valuation profiles at some prime `p`, certifying that `trop_val_cauchy_ge` is
strictly stronger than EGF equality as a separating invariant. This makes the profile a candidate
*fingerprint* resistant to the cancellations that defeat naive coefficient comparison.
