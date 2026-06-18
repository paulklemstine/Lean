# Future Directions — Arithmetic Universality in Additive Cellular Automata via p-adic Renormalization

## Synthesis

This cycle established a compact algebraic engine for one-dimensional additive
cellular automata (CAs) over the finite field `𝔽_p`. The decisive move is to
encode a bi-infinite, finite-support configuration `s : ℤ → 𝔽_p` as a Laurent
polynomial `∑ₓ s(x)·Tˣ ∈ 𝔽_p[T; T⁻¹]`, so that the nearest-neighbour additive
rule (the `𝔽_p` analogue of Wolfram's Rule 90) becomes multiplication by the
single ring element `caOp = T + T⁻¹`, and time-`t` evolution becomes
`(caOp)^t`. The whole space-time diagram is thereby reduced to the powers of one
element of one ring.

Two facts then do all the work. First (`caOp_binomial`), the binomial theorem
gives the exact generating function `(caOp)^n = ∑_{k≤n} C(n,k)·T^{2k−n}`: the
time-`n` row is literally the `n`-th row of Pascal's triangle reduced mod `p`,
placed on an even/odd sublattice. Second (`caOp_pow_char`, `caOp_renorm`,
`caOp_renorm_seed`), the Frobenius / freshman's-dream identity collapses the
diagram at the renormalized times `p^k` to a clean pair of light-cone rays
`(caOp)^{p^k} = T^{p^k} + T^{−p^k}`. The interplay is exactly the discrete
renormalization group behind the Sierpiński self-similarity of these automata,
and it is the algebraic core of what we call *arithmetic universality*: the CA's
trajectory computes binomial coefficients mod `p`, and its scale-`p` coarse
graining is a fixed point.

## Results summary (file `AdditiveCAPadicRenorm.lean`, `sorry`-free)

- `caEvolve_add`, `caEvolve_smul`: the evolution operator is `𝔽_p`-linear for every time step.
- `caOp_pow_char`: `(T+T⁻¹)^p = T^p + T^{−p}` (one-step p-adic renormalization).
- `caOp_renorm`: `(T+T⁻¹)^{p^k} = T^{p^k} + T^{−p^k}` (the renormalization tower).
- `caOp_renorm_seed`: translation-covariant seed evolution `(caOp)^{p^k}·T^a = T^{a+p^k} + T^{a−p^k}`.
- `caOp_binomial`: the exact Pascal-mod-`p` generating function for every time `n`.
- `rule90_scale_four`, `ca_p3_scale_three`: concrete renormalization instances over `𝔽₂`, `𝔽₃`.

All results depend only on `propext`, `Classical.choice`, `Quot.sound`.

---

## Direction 1 — Exact light-cone sparsity at renormalized times (Sierpiński count)

Conjecture: for every prime `p` and every `k`, the number of nonzero cells in the
configuration `(caOp p)^t` is multiplicative in the base-`p` digits of `t`,
namely `∏_i (d_i + 1)` where `t = ∑_i d_i p^i`; in particular it equals exactly
`2` precisely when `t` is a power of `p`, and the support of `(caOp p)^{p^k}` is
exactly `{−p^k, p^k}`.

The key insight is that `caOp_binomial` reduces cell-occupancy to the
non-vanishing of `C(t,k) mod p`, which Lucas' theorem turns into a digit-wise
product — so the *combinatorial* sparsity of the space-time diagram is a purely
*arithmetic* statement about carries in base `p`. Why now? We already have the
generating function (`caOp_binomial`) and the renormalization collapse
(`caOp_renorm`) in `𝔽_p`; the only missing ingredient is a Lucas-theorem bridge,
and the catalog's `ZMod p` Frobenius machinery (used for matrices in the
lifting-the-exponent file) provides exactly the characteristic-`p` toolkit
needed.

## Direction 2 — Reversibility and the additive inverse-rule

Conjecture: the additive CA `caOp = T + T⁻¹` is a bijection on finite-support
configurations over `𝔽_p` iff `p` is odd, and when invertible its inverse is
again a (bi-infinite) Laurent series obtained by inverting `T + T⁻¹` in the
completed ring; over `𝔽₂` it is strictly non-invertible (its kernel is generated
by `T + T⁻¹` acting with a two-element period).

The key insight is that invertibility of an additive CA is exactly the question
of whether `T + T⁻¹` is a unit, which is decidable from the Newton polygon /
valuation of the Laurent polynomial rather than from any dynamical simulation.
Why now? With evolution already realized as ring multiplication, reversibility
becomes a unit-group computation in `𝔽_p[T;T⁻¹]`, a setting where Mathlib's
existing Laurent-polynomial and unit API can be marshalled directly.

## Direction 3 — Spatial period and the order of the renormalization map on torus CAs

Conjecture: on a finite ring of `N` cells (the quotient `𝔽_p[T;T⁻¹]/(T^N − 1)`),
the additive CA has temporal period equal to the multiplicative order of
`(T + T⁻¹)` in that finite ring, and for `N = p^m` this period is exactly `p^m`
(a pure power of `p`), giving a fully p-adic clock.

The key insight is that the renormalization identity `(caOp)^{p^k} = T^{p^k} +
T^{−p^k}` descends to the torus, where `T^{p^m} = 1`, forcing
`(caOp)^{p^m} = 2` (a scalar) and hence pinning the period to a power of `p`.
Why now? The Frobenius collapse we just proved is precisely what makes the torus
order computable in closed form rather than by orbit enumeration, and the
quotient ring is `Decidable`/`Fintype` so the statements are machine-checkable
for concrete `N`.

## Direction 4 — Completing Carmichael's primitive-divisor theorem (p-adic growth bound)

Conjecture (Carmichael, composite tail): for every composite `n > 12`, the
Fibonacci number `F_n` has a primitive prime divisor; equivalently the coprime
part `fibCoprimePart n` from
`Catalog/Speculative/AutoResearch/CarmichaelComposite.lean` exceeds `1`. This is
the single remaining `sorry` in `Catalog/Shared/CarmichaelProof.lean`
(`fib_carmichael_composite`, the `n > 10000` branch), the only obstruction to a
fully `sorry`-free Carmichael theorem in the catalog.

The key insight is that the primitive ("cyclotomic") part `Φ_n(α,β)` of `F_n`
grows like `α^{φ(n)}` while its only possible intrinsic prime factor is the
largest prime divisor of `n` to the first power, so a clean exponential-growth
versus linear-bound inequality (combined with the already-proven LTE lemma
`fib_lte` and the entry-point theory) closes the gap for all large `n`. Why now?
The catalog already contains the full p-adic valuation toolkit
(`fib_lte`, `entry_point_dvd_sq_sub_one`, `isPrimitivePrimeDivisor_iff_entry_eq`)
and the general reduction `primitive_of_fibCoprimePart_pos`; what remains is
solely the growth estimate, exactly the kind of quantitative `Nat.fib` bound
(see `fib_exponential_lower_bound`) that is now within reach.

## Direction 5 — Cross-domain bridge: CA renormalization ⟷ Fibonacci p-adic valuations

Conjecture: the additive CA `caOp` over `𝔽_p` and the Fibonacci sequence share a
common renormalization law — both are governed by the order of a `2×2` companion
matrix over `𝔽_p`, and the CA's renormalization exponent `p^k` matches the
p-adic lifting step `v_p(F_{p^k · m}) = v_p(F_m) + k` from the
lifting-the-exponent lemma. Concretely, the time-`p^k` light cone of the CA and
the `p`-adic valuation jump of `F_{p^k m}` are two shadows of the same Frobenius
action.

The key insight is that `T + T⁻¹` and the Fibonacci companion matrix
`!![1,1;1,0]` are both elements whose `p`-th power is computed by the same
characteristic-`p` Frobenius, so the renormalization tower for CAs and the LTE
ladder for Fibonacci numbers are formally one theorem stated in two categories
(group algebra vs. matrix algebra). Why now? This cycle proves the CA side
(`caOp_renorm`) and the catalog already proves the matrix/number-theoretic side
(`fib_lte`, the `ZMod p` matrix-order argument in `entry_point_dvd_sq_sub_one`);
unifying them into a single `IsFrobeniusRenormalizable` interface is the natural,
falsifiable next synthesis step.
