# Future Directions — Zeta Quantum Group cycle

Derived from the research loop in `Casimir.lean`, `FibonacciBridge.lean`, and
`QuantumDimensionGrowth.lean`. Each conjecture is falsifiable and stated so that a
follow-up cycle can attempt it directly in Lean.

## What this cycle established (one-line recap)
- `qCheb t` = the integer quantum integers `[n]_q` with `t = q + q⁻¹`.
- Classical collapse: `qCheb 2 n = n` (`q → 1` recovers `su(2)`).
- Bridge: `qCheb 3 n = F(2n)`, so the `t = 3` quantum integers are an even-indexed
  Fibonacci **strong divisibility sequence** (`gcd (F 2m) (F 2n) = F (2 gcd m n)`).
- Dichotomy: at `t = 2` growth is linear; at every integer `t ≥ 3` growth is
  exponential (`2ⁿ ≤ qCheb t (n+1)`), so the Casimir-zeros conjecture fails as stated.

---

## Conjecture 1 — `qCheb t` is a strong divisibility sequence for every integer `t ≥ 1`
**Statement.** For each fixed integer `t ≥ 1`, the sequence `n ↦ (qCheb t n).toNat` satisfies
`gcd (qCheb t m).toNat (qCheb t n).toNat = (qCheb t (gcd m n)).toNat`, i.e. it is a
`StrongDivSeq` in the sense of `Catalog/Bridges/StrongDivisibilitySequences.lean`.

**The key insight is** that the `t = 3` case proved here is *not* special to Fibonacci: it is
the Chebyshev/Lucas strong-divisibility phenomenon, and the catalog's abstract `StrongDivSeq`
API is exactly the interface needed to state and consume it uniformly across all `t`.

**Why now?** The bridge `qCheb 3 = F(2·)` and the generic `StrongDivSeq.dvd_of_dvd` already
sit in the same compiled environment; lifting from the single value `t = 3` to all `t` only
requires the general resultant/`gcd`-of-Lucas-sequence lemma, which is a self-contained
number-theory target the prover can attack immediately.

## Conjecture 2 — Primitive-divisor (Zsygmondy) theory for quantum integers
**Statement.** For integer `t ≥ 3`, every `qCheb t n` with `n` large enough has a *primitive*
prime divisor (a prime dividing `qCheb t n` but no earlier term), and the entry-point map
`p ↦ entryPoint p` of `Catalog/Applications/FibonacciEntryPoints.lean` transports verbatim.

**The key insight is** that primitive divisors are a property of the `StrongDivSeq` axioms
alone, so once Conjecture 1 makes `qCheb t` a `StrongDivSeq`, the catalog's
`StrongDivSeq.entryPoint_isPrimitive` and `dvd_iff_entryPoint_dvd` apply with no new work.

**Why now?** `FibonacciBridge.lean` already instantiates the abstract entry-point theory for
`t = 3` through `fibSDS`; the generic machinery is one import away from every `t`.

## Conjecture 3 — The Casimir spectrum forgets `q`, so no reparametrization yields `γ₁`
**Statement.** There is **no** continuous `f` and no integer `t ≥ 3` with
`γ_n = f(casimir n)` reproducing the Riemann zeros, because `casimir n = n(n+1)` is
`t`-independent while the only `t`-dependent data (`qCheb t`) grows exponentially
(`qCheb_exp_growth`) whereas `γ_n ∼ 2πn/log n` grows sub-linearly.

**The key insight is** the proven *separation of scales*: the spectrum is rigid and classical,
the deformation is exponential, and the target sequence is sub-linear — three incompatible
growth rates that no single `f` can reconcile.

**Why now?** `qCheb_exp_growth` (this cycle) gives the exponential lower bound in compiled
form; pairing it with a formalized `γ_n = O(n / log n)` density bound turns the mission's
central conjecture into a *theorem of impossibility*, a sharper and provable replacement.

## Conjecture 4 — Telescoping spectral zeta of the Casimir operator is rational at integers
**Statement.** The "Casimir spectral zeta" partial sums `∑_{k<n} 1/casimir(k+1)^s` are, for
`s = 1`, exactly `n/(n+1)` (proved: `casimir_telescope`); conjecture that for every integer
`s ≥ 1` the limit `∑_{k≥1} 1/casimir(k)^s` is a rational combination of `ζ(2), …, ζ(2s)` and
hence transcendental, never matching the (conjecturally) different arithmetic of `ζ(s)`.

**The key insight is** that `1/(k(k+1))^s` admits a finite partial-fraction expansion in
`1/k^j`, so the spectral zeta of the Casimir collapses to ordinary `ζ`-values — making its
arithmetic *orthogonal* to that of the Riemann zeros rather than encoding them.

**Why now?** The `s = 1` telescoping identity is already verified; the partial-fraction step
for general `s` is a finite, prover-friendly induction that extends it directly.

## Conjecture 5 — Quantum dimension `q + q⁻¹` is the unique growth threshold
**Statement.** Over the reals, `t = q + q⁻¹` governs a sharp trichotomy for `qCheb t`:
bounded/periodic for `|t| < 2`, linear for `|t| = 2`, exponential for `|t| > 2`; and `t = 2`
(equality in `quantum_dim_ge_two`) is the *unique* boundary value giving polynomial growth.

**The key insight is** that `quantum_dim_ge_two` (`q + q⁻¹ ≥ 2`, equality iff `q = 1`) is not
just an inequality but the exact location of the growth phase transition for the whole family.

**Why now?** Both endpoints are already proved here (`qCheb_classical` for `t = 2`,
`qCheb_exp_growth` for integer `t ≥ 3`); the remaining `|t| < 2` periodic regime is a clean
Chebyshev/trigonometric computation that closes the trichotomy.
