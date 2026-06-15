# Future Directions — The Spectral Decomposition of the Pisano Period

## Synthesis

The catalog's Fibonacci entry-point program had, by the previous cycle, two well-developed
but *disjoint* halves. On one side sat the **entry point** `z(m)` (rank of apparition):
totality (`FibApparition.fib_apparition_exists`), the ideal law `m ∣ F n ↔ z(m) ∣ n`
(`FibApparition.fib_dvd_iff_apparitionRank_dvd`), and its lcm/multiplicative algebra
(`FibEntryChar.fibEntryPt_prod_coprime`). On the other side sat the **Pisano period**
`π(m)`, realized as `orderOf` of the Fibonacci shift `Q : (a,b) ↦ (b,a+b)` on
`(ZMod m)²`, together with the Chinese-Remainder law `π(mn) = lcm(π m, π n)`
(`FibPisano.pisano_mul_coprime`). Both halves knew `z(m) ∣ π(m)`, but the *exact*
quantitative relationship between the two invariants — the content of Direction 4 of the
prior `FUTURE_DIRECTIONS` — was missing.

This cycle (`Catalog/Novelty/FibPisanoEntryPointSpectrum.lean`) supplies that bridge,
fully `sorry`-free, with axioms `{propext, Classical.choice, Quot.sound}` only. The
organizing discovery is the **scalar-action lemma**: raised to the entry point, the shift
map *degenerates to multiplication by a single scalar*,
`Q^{z(m)}(a,b) = (c·a, c·b)` with `c = F_{z(m)+1} (mod m)`. Because consecutive Fibonacci
numbers are coprime and `m ∣ F_{z(m)}`, the scalar `c` is a unit of `ZMod m`. Iterating
the scalar action and matching principal ideals yields the headline equality.

## Results Summary

Seven theorems in one self-contained file (depending only on Mathlib):

* `fibStep_pow_entryPt` — **scalar-action lemma**: `Q^{z(m)}(a,b) = (c·a, c·b)`.
* `entryScalar_isUnit` — `c = F_{z(m)+1}` is a unit of `ZMod m`.
* `fibStep_pow_entryPt_mul` / `fibStep_pow_entryPt_mul_eq_one_iff` — the iterate law
  `Q^{z·j} = c^j·` and its triviality criterion `Q^{z·j} = 1 ↔ c^j = 1`.
* `pisano_eq_entryPt_mul_orderOf` — **spectral decomposition**:
  `π(m) = z(m) · orderOf(F_{z(m)+1} : ZMod m)`.
* `pisano_div_entryPt` — `π(m)/z(m) = orderOf(F_{z(m)+1})` (an exact quotient).
* `pisano_eq_entryPt_iff` — sharp shortness criterion: `π(m) = z(m) ↔ F_{z(m)+1} ≡ 1`.

Supporting tools `fibStep`, `fibStep_iterate_apply`, `pisano_dvd_iff`, `entryPt`,
`entry_exists`, `fib_dvd_iff_entryPt_dvd` are re-established self-contained so the file
stands alone over Mathlib.

## Research Directions

### 1. The quotient `π(p)/z(p) ∈ {1, 2, 4}` for odd primes
**Conjecture.** For an odd prime `p`, `orderOf(F_{z(p)+1} : ZMod p) ∈ {1, 2, 4}`, so by
`pisano_div_entryPt` the ratio `π(p)/z(p)` is always `1`, `2`, or `4`. The key insight is
that the scalar `c = F_{z(p)+1}` is not an arbitrary unit: at the entry point the Fibonacci
matrix `Q^{z}` is the *scalar* `c·I`, and taking determinants of `Q^{z}` gives
`c² = det(Q)^{z} = (-1)^{z}` in `ZMod p` (since `det Q = -1`). Hence `c² = ±1`, forcing
`c⁴ = 1` and `orderOf c ∣ 4`. **Why now?** The scalar-action lemma `fibStep_pow_entryPt`
already proves `Q^{z} = c·I` on the nose; the only missing ingredient is the determinant
identity `det(Q^{z}) = (det Q)^{z}`, a one-line `Matrix.det_pow` fact, after which the
bound is pure `orderOf ∣ 4` arithmetic. This converts a classically "known" fact about
Pisano periods into a short, fully checkable Lean proof and pins the period of every prime
modulus to its entry point up to a factor of at most four.

### 2. Parity of the quotient via the determinant sign
**Conjecture.** With `c = F_{z(m)+1}`, one has `c² = (-1)^{z(m)} (mod m)`; consequently the
quotient `q(m) := π(m)/z(m) = orderOf c` satisfies: `q(m) = 1 ↔ c = 1`, `q(m) ≤ 2` exactly
when `z(m)` is even, and `q(m)` is forced to be even (`q ∈ {2,4}`) when `z(m)` is odd and
`c ≠ ±1` is impossible. The key insight is that the *sign* `(-1)^{z(m)}` of the determinant
power is exactly the obstruction separating the shortness criterion `pisano_eq_entryPt_iff`
(`c = 1`) from the next case `c = -1` (period `2z`). **Why now?** `pisano_eq_entryPt_iff`
already isolates the `c = 1` case; the determinant identity of Direction 1 supplies the
companion `c = -1` case, so the full case split `q ∈ {1,2,4}` becomes a finite decision on
`(parity of z, value of c² )` rather than an analytic argument.

### 3. Multiplicativity of the quotient is *not* the lcm law
**Conjecture (falsifiable).** The quotient `q(m) = π(m)/z(m)` is **not** multiplicative on
coprime moduli: there exist coprime `m, n` with `q(mn) ≠ lcm(q(m), q(n))` and also
`q(mn) ≠ q(m)·q(n)`. The key insight is that although both `z` and `π` obey clean lcm laws
on coprime factors (`fibEntryPt_prod_coprime`, `pisano_mul_coprime`), their *ratio* mixes
two different lattice joins — `π(mn)/z(mn) = lcm(π m, π n)/lcm(z m, z n)` need not equal any
fixed combination of `q(m), q(n)`. **Why now?** With both lcm laws and the exact
decomposition `pisano_eq_entryPt_mul_orderOf` in hand, the conjecture reduces to evaluating
`q` on a handful of explicit coprime pairs by `decide`/`native_decide`; a single
counterexample (e.g. comparing small primes whose `c`-orders differ) refutes the naive
multiplicativity and sharpens our picture of how the two invariants decouple.

### 4. The entry scalar generates the apparition structure of every multiple
**Conjecture.** For `m ≥ 1` and any `t ≥ 1`, `m ∣ F_{z(m)·t}` *with quotient governed by `c`*:
specifically `F_{z(m)·t} / F_{z(m)} ≡ t · c^{t-1} (mod m)` and more generally the matrices
`Q^{z·t}` form the cyclic group `{c^t · I}`. The key insight is that the scalar-action lemma
turns the entire arithmetic progression of apparitions `z, 2z, 3z, …` into the cyclic
sequence of scalars `c, c², c³, …`, so the "higher apparition" behaviour of `F` modulo `m`
is completely captured by powers of one unit. **Why now?** `fibStep_pow_entryPt_mul` already
proves `Q^{z·t} = c^t·I`; reading off the top-right matrix entry gives a closed form for
`F_{z·t} (mod m)` directly, with no new induction, immediately yielding `p`-adic
valuation / lifting-the-exponent statements for Fibonacci numbers from the order of `c`.

### 5. Spectral decomposition for nondegenerate Lucas sequences
**Conjecture.** For a nondegenerate Lucas sequence `U_n(P,Q)` with `gcd(P,Q)=1` and `Q` a
unit mod `m`, the shift `T(a,b) = (b, P·b - Q·a)` on `(ZMod m)²` satisfies `T^{z_U(m)} = γ·I`
for a unit scalar `γ`, and the Lucas–Pisano period decomposes as
`π_U(m) = z_U(m) · orderOf(γ)`, with `γ² = (det T)^{z_U} = Q^{z_U}`. The key insight is that
*nothing* in this cycle's proofs used `P = Q = 1` beyond (i) the two-term recurrence (encoded
in `T`) and (ii) reversibility of `T` (a bijection precisely when `Q` is a unit); the scalar
collapse at the entry point is a determinant phenomenon, not a Fibonacci accident. **Why now?**
The Fibonacci proofs here are already written against the abstract shift `(a,b)↦(b,a+b)`;
re-parameterising to `T(a,b)=(b,Pb-Qa)` is a substitution exercise, making this the most
direct route from the Fibonacci spectral decomposition toward the Bilu–Hanrot–Voutier
primitive-divisor theorem for general Lucas sequences.
