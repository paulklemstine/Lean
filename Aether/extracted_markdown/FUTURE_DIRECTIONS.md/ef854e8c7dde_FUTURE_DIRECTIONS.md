# Future Directions — Proof-Complexity Phase Transition in Lean-Definable Rewriting Dynamics

## Synthesis

This cycle attacked the conjecture of a *sharp proof-complexity phase transition* in a
parametric family of terminating, confluent term-rewriting systems. Rather than chase the
full probabilistic 0/1-law statement (which requires unconditional superpolynomial lower
bounds against arbitrary local inference bases — currently research-open), we isolated and
formally proved the rigorous **deterministic skeleton** of the phenomenon in
`Catalog/Algebra/RewritingPhaseTransition.lean`.

The central discovery is a *duality-driven explanation* of the transition. For the
parametric decrement family `Dstep s` (one rewrite subtracts `s`), we proved:

1. **An exact certificate-length law** (`steps_Dstep_iff`): a length-`n` reduction exists
   between `a` and `b` iff `a = b + n·s`. Certificate length is a hard arithmetic invariant
   of the endpoints, not a search artifact.
2. **A representation/duality theorem** (`joinable_iff_mod`): the joinability equivalence
   of `Dstep s` is *exactly* congruence mod `s`. The dynamical rewriting system is dual to
   the algebraic quotient `ℤ/sℤ`; normal forms `{0,…,s−1}` represent joinability classes.
3. **A polynomial regime** (`cert_poly`): under the unary size measure, every convertible
   pair admits a certificate of length `|a−b| ≤ size`, i.e. linear.
4. **A superpolynomial regime** (`cert_superpoly`): under the binary size measure
   `Nat.size m`, the minimal certificate joining `m` to its normal form `0` has length
   `≥ 2^(size−1)`, i.e. exponential in the bit length.

Together, (3) and (4) witness the dichotomy on a *single* deterministic system: the same
local dynamics produces polynomial proofs under a low-density (unary) representation and
provably exponential proofs under a high-density (binary) representation. The "branching
density" β of the conjecture is reinterpreted, and made precise, as the *information
density of the term encoding* — the bits-per-symbol of the normal-form address space — and
the threshold is the point at which this density forces the certificate-length invariant to
outrun any polynomial in the input size.

## Results Summary

| Theorem | Statement | Role |
|---|---|---|
| `steps_one`, `Steps_trans` | length-instrumented reduction algebra | reusable ARS infrastructure |
| `steps_Dstep_iff` | `Steps (Dstep s) n a b ↔ a = b + n·s` | exact certificate-length law |
| `joinable_iff_mod` | `Joinable (Dstep s) a b ↔ a%s = b%s` | ARS ⊣ `ℤ/sℤ` duality / representation |
| `cert_poly` | `JoinableIn (Dstep 1) (max−min) a b` | polynomial (unary) regime |
| `cert_superpoly` | `JoinableIn (Dstep 1) k m 0 → 2^(size m −1) ≤ k` | superpolynomial (binary) regime |

All proofs are complete (`sorry`-free) and rest only on `propext`, `Classical.choice`,
`Quot.sound`.

## Research Directions

### 1. Encoding-induced threshold as a genuine order parameter

The unary/binary contrast is the two endpoints of a one-parameter family of positional
encodings of base `β` (β = 1 is unary, β ≥ 2 is positional). Define the size of `m` in base
`β` and study minimal certificate length divided by `poly(size_β m)`. The conjecture is that
this normalized ratio collapses to a step function of β with a single discontinuity at
`β_c = 1`: for β = 1 the ratio is bounded, for every β ≥ 2 it is unbounded (superpolynomial).
*The key insight is* that certificate length is encoding-invariant (it equals the residue
distance), so the transition lives entirely in the denominator — the size functor — making
β_c a property of the representation, not the dynamics. *Why now?* `steps_Dstep_iff` already
pins the numerator exactly; the only missing ingredient is the elementary inequality between
base-β digit length and value, which is squarely in Mathlib's `Nat.log`/`Nat.size` API.
Falsifiable: exhibit a base β ≥ 2 with polynomially bounded normalized certificate length, or
prove the ratio is continuous across β = 1.

### 2. Two-generator confluent families and a tunable interior threshold β_c

Replace the single decrement by two competing rules `a ↦ a − p` and `a ↦ a − q` with
`gcd(p,q) = 1`, so normal forms are the Frobenius non-representable residues. The joinability
duality should generalize to `joinable ↔ a ≡ b (mod gcd)`, while the *minimal* certificate
length becomes a coin-problem (numerical-semigroup) optimization. *The key insight is* that
branching (two rules) reintroduces genuine search: certificate length is now a shortest-path
length in the Cayley graph of the semigroup rather than a fixed value, so a real interior
β_c — controlled by the ratio `q/p` — can separate easy from hard joinability. *Why now?*
`Steps_trans` and `JoinableIn` already provide the additive length algebra needed to define
shortest certificates, and Mathlib has the numerical-semigroup / Frobenius scaffolding.
Falsifiable: show minimal certificate length stays polynomial for all coprime `p,q`, killing
the interior threshold.

### 3. A formal proof-compression ratio and its non-monotonicity

Define `compression(a,b) = minCertLen(a,b) / |⟨equality proof in `ℤ/sℤ`⟩|` — the ratio of
the dynamical certificate to the algebraic certificate obtained through the duality. The
duality `joinable_iff_mod` lets one *translate* a rewriting proof into a one-line modular
congruence. *The key insight is* that the dual (algebraic) proof is always O(size_β) while
the primal (rewriting) proof can be exponential, so the compression ratio is itself the order
parameter of the transition — duality is literally the compression mechanism. *Why now?*
Both sides are now formal objects in the file (`JoinableIn` lengths and the mod
characterization), so the ratio is definable and its blow-up provable without new axioms.
Falsifiable: find a regime where the dual proof is no shorter than the primal one.

### 4. Lower bounds against arbitrary local inference bases (the hard core)

The original conjecture demands superpolynomial lower bounds in *any* fixed local inference
basis, not just the canonical one-step relation. Formalize an "inference basis" as a finite
set of derived rewrite macros (bounded-size composite steps) and prove that for the binary
encoding no finite macro basis compresses the `m ↦ 0` certificate below `m / c` for a basis
constant `c`. *The key insight is* that any finite basis only changes certificate length by a
constant factor (each macro advances the value by a bounded amount), so the exponential gap of
`cert_superpoly` is basis-robust. *Why now?* `steps_Dstep_iff` makes "advance by a bounded
amount" literally a statement about `n·s`, so the constant-factor argument is a short pigeonhole
once macros are defined. Falsifiable: construct a finite macro basis giving polynomial
certificates in binary size.

### 5. From decrement chains to confluent string rewriting and Stone-type duality

Lift the family from `ℕ` to a confluent semi-Thue (string) rewriting system whose normal
forms form a Boolean algebra of "reduced words," and seek a Stone-duality bridge: convertible
classes ↔ clopen sets of a profinite space of infinite reductions. *The key insight is* that
the `ARS ⊣ ℤ/sℤ` duality proven here is the rank-1 shadow of a Stone/Gelfand-style duality
between confluent rewriting systems and the spectra of their normal-form algebras. *Why now?*
The abstract `Steps`/`Joinable`/`JoinableIn` layer in this file is type-polymorphic (`α`), so it
already applies verbatim to word rewriting; only the normal-form algebra and its spectrum need
to be built, both of which Mathlib supports (`Profinite`, Boolean algebras). Falsifiable: show
the normal-form algebra of some confluent system has no point-spectrum representation,
breaking the Stone bridge.
