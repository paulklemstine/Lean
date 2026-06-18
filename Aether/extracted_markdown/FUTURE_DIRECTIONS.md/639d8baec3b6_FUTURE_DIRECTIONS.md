# Future Directions — Fibonacci Entry Points: the Reconstruction Law and Beyond

## Synthesis

This cycle turned the Fibonacci **entry point** (rank of apparition)
`α(m) = entry Nat.fib m` — the least `k > 0` with `m ∣ F k` — from a collection of
scattered one-directional divisibility lemmas into a **factorization-determined
arithmetic function**. The organizing principle is the *law of apparition*
`m ∣ F k ↔ α(m) ∣ k` (already in the catalog, proved abstractly for any strong
divisibility sequence in `EntryPointMultiplicativity.lean`). From it everything else
follows by pure lattice/order reasoning, with no growth estimates and no primality.

Two structural results closed the gap between the catalog's *binary* coprime join
law `α(a·b) = lcm(α a, α b)` and a genuine closed form. First, the binary law was
lifted to the **n-ary join law** `α(∏ f i) = lcm_i α(f i)` for any finite
pairwise-coprime family (`entry_prod_coprime`), proved by rigidity: both sides
generate the same divisibility ideal of `ℕ`. The delicate point was purely
type-theoretic — `ℕ`'s `Nat.Coprime` is the relation `IsRelPrime`, not the
ring-theoretic `IsCoprime`, so `Finset.prod_dvd_of_isRelPrime` is the correct
combinator. Second, combining the n-ary law with **totality** of `α` (every `m ≥ 1`
appears, a Pisano/pigeonhole fact rebuilt from scratch as `fib_appears`) and the
standard prime-power decomposition `m = ∏_{p ∣ m} p^{v_p(m)}` yields the headline
**reconstruction law** `α(m) = lcm_{p ∣ m} α(p^{v_p(m)})` (`fib_entry_factorization`),
reducing the computation of `α` of *any* modulus to prime powers. We also closed the
previously open `sorry` for the binary law `FibEntryChar.fibEntryPt_mul_coprime`.

The Critic's contribution was a sharp boundary: the coprimality hypothesis in the
n-ary law is *necessary*, witnessed by the constant family `2, 2` over `Fin 2` where
`α(4) = 6 ≠ 3 = lcm(α 2, α 2)` (`entry_prod_needs_coprime`). Crucially, the failure
is always in one direction — `α(∏)` becomes a strict *multiple* of the lcm, never
smaller — consistent with the catalog's unconditional lower bound `lcm ∣ α(∏)`. This
isolates exactly what remains unknown for a *complete* formula for `α`: the
prime-power values `α(p^k)`, the Wall–Sun–Sun frontier described below.

## Results Summary

- `FibEntryFactor.appears_of_dvd`: proved — appearance of a modulus is downward
  closed under divisibility; the basic API enabling per-prime-power reasoning.
- `FibEntryFactor.entry_prod_coprime`: proved — the **n-ary join law**
  `α(∏ f i) = lcm_i α(f i)` for pairwise-coprime appearing families; the engine of
  the reconstruction.
- `FibEntryFactor.fib_appears`: proved — **totality** of the Fibonacci entry point on
  every `m ≥ 1`, by pigeonhole on the reversible Fibonacci pair-recurrence over
  `ZMod m`.
- `FibEntryFactor.fib_entry_prod_coprime`: proved — Fibonacci specialization of the
  n-ary join law.
- `FibEntryFactor.fib_entry_factorization`: proved — the **reconstruction law**
  `α(m) = lcm_{p ∣ m} α(p^{v_p(m)})`, the headline result reducing `α` to prime
  powers.
- `FibEntryFactor.entry_fib_two` / `entry_fib_four`: proved — explicit values
  `α(2) = 3`, `α(4) = 6`.
- `FibEntryFactor.entry_prod_needs_coprime`: disproved (counterexample) — the n-ary
  law fails without pairwise coprimality, so the hypothesis is necessary.
- `FibEntryChar.fibEntryPt_mul_coprime`: proved (was `sorry`) — the binary coprime
  join law, now closed in the characterization file.

## Research Directions

### Direction 1: Prime-power recursion for `α` (the Wall–Sun–Sun frontier)
**Hypothesis**: For every prime `p` and `k ≥ 1`,
`α(p^{k+1}) ∈ {α(p^k), p · α(p^k)}`, and `α(p^{k+1}) = p · α(p^k)` whenever
`p^2 ∤ F_{α(p)}`.
**Test**: Formalize the lifting-the-exponent step for Fibonacci using the catalog's
p-adic valuation file; falsified by a single prime power where `α` jumps by a factor
other than `1` or `p` (searchable by `#eval` over `p ≤ 100`, `k ≤ 5`).
**Why now**: `fib_entry_factorization` reduces *all* of `α` to prime powers, so this
recursion is the **only** remaining unknown for a complete closed form of `α(m)`.
**If true**: A fully explicit formula for `α(m)` from the data `(α(p), v_p(F_{α(p)}))`.
**If false**: A Fibonacci–Wentzel anomaly (a "Wall–Sun–Sun"-type prime), itself a
notable discovery.

### Direction 2: Failure of the meet (gcd) law and its defect
**Hypothesis**: `α` is not a meet morphism: in general only
`gcd(α a, α b) ∣ α(gcd a b)`, and `α(gcd a b) = gcd(α a, α b)` holds **iff** `a, b`
share no prime `p` whose `p`-parts of `α a` and `α b` differ.
**Test**: Prove the easy inclusion from the order-morphism lemma; search
computationally for a pair `(a,b)` with `α(gcd a b) ≠ gcd(α a, α b)` to confirm
strictness, then characterize.
**Why now**: With the join law now an `iff`-level lattice identity, the dual question
is ripe, and `entry_prod_coprime` already shows the defect is localized exactly at
the *shared* primes excluded by the coprime hypothesis.
**If true**: `α` is a join-but-not-meet morphism with a computable defect, completing
its lattice-theoretic profile.
**If false**: `α` is a full lattice morphism, strengthening every reconstruction
result to gcd inputs.

### Direction 3: A sharp upper bound for `α` on primes
**Hypothesis**: For every prime `p ≠ 5`, `α(p) ∣ p − (5/p)` (Legendre symbol), hence
`α(p) ≤ p + 1`.
**Test**: Reduce, via the law of apparition, to the single membership
`p ∣ F_{p − (5/p)}` (the Fibonacci form of Euler's criterion in `ℤ[φ]/p`); falsified
by one prime with `α(p) ∤ p − (5/p)`.
**Why now**: `entry_prod_coprime` and the law of apparition make `α(p) ∣ N` a
one-line consequence of `p ∣ F_N`, collapsing the whole problem to that one
divisibility.
**If true**: A linear bound feeding density/growth estimates for the entry-point
function.
**If false**: The Frobenius action on the quadratic field behaves unexpectedly mod
`p`, a deep anomaly.

### Direction 4: Entry point versus Pisano period
**Hypothesis**: Let `π(m)` be the Pisano period. Then `α(m) ∣ π(m)` and the quotient
`π(m)/α(m) ∈ {1, 2, 4}` for every `m`.
**Test**: Define `π(m)` as the orbit length of `(0,1)` under the reversible shift map
used in `fib_appears`; relate `α` and `π` as two invariants of one finite dynamical
system; falsified by any `m` with `π(m)/α(m) ∉ {1,2,4}` (immediate `#eval` search).
**Why now**: `fib_appears` already constructs the entry point from the orbit of the
Fibonacci shift permutation on `ZMod m × ZMod m`; `π` is the *full* orbit length of
the same map, so no new machinery is needed — only a cyclic-subgroup-index argument.
**If true**: A clean dynamical reading of both invariants and a bounded ratio.
**If false**: A modulus with exotic period structure, refining the theory of the
Fibonacci shift dynamical system.

### Direction 5: Reconstruction law for general strong divisibility sequences
**Hypothesis**: For *any* strong divisibility sequence `u` with `u 0 = 0` and `α`
total on positive moduli, `α(m) = lcm_{p ∣ m} α(p^{v_p(m)})`; in particular for the
Mersenne/repunit family `u n = aⁿ − 1` this recovers
`ord_m(a) = lcm_{p ∣ m} ord_{p^{v_p(m)}}(a)`.
**Test**: Abstract `fib_entry_factorization` to `entry u`, replacing `fib_appears`
with a totality hypothesis; instantiate at `u n = aⁿ − 1` (already an `IsSDS` in the
catalog).
**Why now**: `entry_prod_coprime` is already stated and proved for an arbitrary
`IsSDS u`; only the Fibonacci-specific totality lemma stands between us and the fully
general theorem, and totality is a hypothesis the Mersenne instance can discharge via
Euler's theorem.
**If true**: A single theorem unifying the rank-of-apparition factorization for
Fibonacci, Mersenne, Lucas sequences, and elliptic divisibility sequences.
**If false**: Totality, not the lattice structure, is the genuine obstruction —
itself a clarifying negative result.
