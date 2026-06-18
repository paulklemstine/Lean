# Future Directions — The L-Function Oracle: Reductions, Duality, and Representation

## Synthesis

The "L-function oracle" thought experiment promises that an `O(1)` evaluator for
`L(s, χ)` would topple RH, BSD, Sato–Tate, Langlands, and factoring. The grand
claims are not literally formalizable — `O(1)` is a statement about a *cost model*,
not a mathematical proposition. What survives formalization, and what this cycle
isolates, is the **reduction skeleton** hiding inside each claim: the precise
mathematical step that converts *evaluating a function* into *finding or deciding a
witness*. Stripping away the cost model exposes honest theorems, all proved here
with zero `sorry` (`Shared/LFunctionOracle/Core.lean`,
`Shared/LFunctionOracle/EulerDuality.lean`).

Two threads emerge. The **computational thread** (Part I) shows the oracle's power
is always a reduction: search collapses to finite evaluation (`oracle_decides_exists`),
zero-finding collapses to sign detection via the Intermediate Value Theorem
(`oracle_root_of_sign_change`, `oracle_root_in_grid`), and factoring collapses to a
divisibility test (`oracle_factor_of_composite`). The **duality thread** (Part II)
shows the oracle's *arithmetic* content is a representation theorem: a completely
multiplicative coefficient sequence — an Euler product — is faithfully determined by
its values on primes (`completelyMult_determined_by_primes`), its zeros are explained
locally (`completelyMult_eq_zero_iff_prime`), and the BSD-style "analytic rank" is
the first nonzero Taylor index (`orderOfVanishing_eq_zero_iff`,
`orderOfVanishing_pos_iff`, `orderOfVanishing_spec`). This dovetails with the
catalog's `Shared/SelbergClassCensus.lean`, whose `SelbergDatum` records exactly the
finite local invariants (degree, conductor, Gamma data) that our representation
theorem treats as a complete invariant on the coefficient side.

## Results Summary

| Theorem | Oracle claim made honest |
|---|---|
| `oracle_decides_exists` | search → finite evaluation (the "PH collapse" core) |
| `oracle_root_of_sign_change` | RH: detect a zero from a sign change (IVT) |
| `oracle_root_in_grid` | RH: a grid scan certifies a zero |
| `oracle_factor_of_composite` | factoring: divisibility oracle splits composites |
| `completelyMult_determined_by_primes` | Euler product = its prime data (representation theorem) |
| `completelyMult_eq_zero_iff_prime` | local–global vanishing dictionary |
| `orderOfVanishing_{eq_zero,pos}_iff`, `_spec` | BSD: analytic rank = first nonzero coefficient |

## Bold, Falsifiable Research Directions

### 1. Euler product as a monoid representation into `(ℂ, ×)`
Upgrade `completelyMult_determined_by_primes` from "agreement" to a genuine
**representation theorem**: the multiplicative monoid `(ℕ_{>0}, ×)` is the free
commutative monoid on the primes, so a completely multiplicative `f : ℕ → ℂ` *is* a
monoid hom `ℕ_{>0} → (ℂ, ×)`, and the restriction map `Hom(ℕ_{>0}, ℂ) → (primes → ℂ)`
is a bijection. **Conjecture:** there is a Lean equivalence
`{f // CompletelyMultiplicative f} ≃ (Nat.Primes → ℂ)`. *The key insight is* that the
arithmetic of `ℕ` under multiplication is literally a free object, so "prime data is
a complete invariant" is the universal property of freeness, not a coincidence. *Why
now?* The agreement theorem is already proved; promoting it to a bijection only
requires packaging the inverse (multiply prime values over `Nat.factorization`), and
Mathlib's `Nat.factorization`/`ArithmeticFunction.IsMultiplicative` API makes the
construction tractable today. Falsifiable: the equivalence either type-checks as a
genuine `≃` or it does not.

### 2. Dirichlet convolution as a Stone-style dual of pointwise product
Pursue the duality the oracle hints at: under the Dirichlet series transform, the
**Dirichlet convolution** of coefficient sequences corresponds to **pointwise
multiplication** of `L`-functions. **Conjecture:** within `ArithmeticFunction`,
`L(f ⋆ g) = L(f) · L(g)` formally (as products of formal Dirichlet series), and
complete multiplicativity is exactly the condition `f ⋆ f⁻¹ = δ` with `f` a
ring homomorphism on the convolution monoid. *The key insight is* that the
coefficient↔`L`-function correspondence is an algebra isomorphism (convolution ring →
Dirichlet-series ring), the genuine "duality pairing" behind the mythical oracle.
*Why now?* Mathlib already has `ArithmeticFunction`, Dirichlet convolution, and
`zeta`/`moebius`; the missing piece is a clean formal-series target and the transport
lemma, both within reach. Falsifiable on a finite truncation: convolution coefficients
must match the Cauchy product of the transformed series.

### 3. Quantitative sign-change root finding with an explicit modulus
Strengthen `oracle_root_in_grid` from "a zero exists" to "a zero exists within
`(x i, x (i+1))` of width `δ`", yielding an explicit bisection bound. **Conjecture:**
for Lipschitz `f` with constant `K`, `n` bisection oracle calls locate a zero to
accuracy `(b-a)/2ⁿ`, and this is recordable as a Lean function returning an interval
of guaranteed width with a membership proof. *The key insight is* that the IVT is not
just existential — paired with a modulus of continuity it is an *algorithm*, making
the oracle's "`O(R²)` grid scan" a theorem about convergence rate, not folklore.
*Why now?* `oracle_root_of_sign_change` is the base case already proved; the recursion
is a straightforward `Nat.rec` over bisection steps. Falsifiable: the returned
interval width either provably satisfies the `2⁻ⁿ` bound or it does not.

### 4. A local–global rank inequality for products of L-functions
Combine the duality and order-of-vanishing threads: for completely multiplicative
coefficient data, the order of vanishing of a product `L(f)·L(g)` at the central
point should be the **sum** of the individual orders. **Conjecture:**
`orderOfVanishing (a ⋆ b) = orderOfVanishing a + orderOfVanishing b` for sequences
with nonzero leading terms (a formal-power-series valuation additivity), mirroring
`SelbergDatum.product` adding degrees in the catalog's Selberg census. *The key
insight is* that "analytic rank is additive under Rankin–Selberg products" is, at the
coefficient level, just additivity of the order of the first nonzero term — a
valuation. *Why now?* `orderOfVanishing_spec` already pins the first nonzero index;
additivity is the standard valuation argument and connects directly to the existing
`SelbergDatum.product`/`coarseComplexity` infrastructure. Falsifiable: compute both
sides on explicit truncated sequences.

### 5. Oracle-relative decidability as an honest "PH collapse" statement
Replace the unformalizable `O(1)` claim with a genuine relativized statement:
**Conjecture:** for any predicate `P : ℕ → Prop` such that membership is decidable
*given* an oracle `o : ℕ → Bool` deciding a fixed base predicate, the bounded
quantifiers `∃ n < N, P n` and `∀ n < N, P n` are decidable, uniformly in `o`. *The
key insight is* that "the oracle collapses search" is precisely closure of the
decidable predicates under bounded quantification relative to `o` — a statement about
`Decidable` instances, which Lean tracks natively, with no cost model required.
*Why now?* `oracle_decides_exists` is the unrelativized seed; generalizing to a fixed
oracle parameter and bounded ranges uses only `Nat.decidableBallLT` and friends.
Falsifiable: the relativized `Decidable` instances either elaborate or expose a
genuine obstruction.
