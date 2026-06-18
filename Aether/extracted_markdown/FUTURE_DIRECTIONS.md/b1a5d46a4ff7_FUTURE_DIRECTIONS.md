# Future Directions — Period Structure of Fibonacci Apparition Indices

## Synthesis

This cycle reframed the catalog's Fibonacci *entry-point* thread
(`Catalog/Applications/FibonacciEntryPoints.lean`, `Catalog/Shared/CarmichaelProof.lean`)
as a statement about a **purely periodic Boolean signal**: for any `p`, the map
`n ↦ (p ∣ F_n)` is `1` exactly on the multiples of a single integer `e = entryPoint p`,
the rank of apparition. The catalog had `dvd_fib_iff_entry_dvd` (the pointwise period law)
but stopped there. We pushed the period viewpoint to its quantitative and constructive
consequences in `FibonacciPeriodSampling.lean`:

* `apparition_iff` / `apparition_set_eq` — the apparition set *is* the lattice `e·ℕ`;
* `apparition_count` — an **exact** count `#{x ∈ (0,N] : p ∣ F_x} = ⌊N/e⌋`, transferring
  Mathlib's multiples-count lemma `Nat.Ioc_filter_dvd_card_eq_div` verbatim once the
  filter predicate is rewritten through the period law;
* `apparition_window_unique` — every length-`e` window contains **exactly one** apparition,
  the collision-free "sampling block" that motivated the original period-sampling framing.

All results are `sorry`-free and depend only on `propext, Classical.choice, Quot.sound`,
and the period law is independently `decide`-verified for `p = 11` (`e = 10`) and
`p = 13` (`e = 7`).

## Results Summary

| Theorem | Statement | Status |
|---|---|---|
| `apparition_iff` | `p ∣ F_n ↔ e ∣ n` | proved |
| `apparition_set_eq` | `{n | p ∣ F_n} = {n | e ∣ n}` | proved |
| `apparition_count` | `#{x ∈ (0,N] : p ∣ F_x} = N / e` | proved |
| `apparition_window_unique` | `#{x ∈ (m, m+e] : p ∣ F_x} = 1` | proved |

## Research Directions

### 1. The two-prime apparition signal is periodic with period `lcm(e_p, e_q)`

Conjecture: for `p, q` both ever dividing a Fibonacci number, the joint signal
`n ↦ (p ∣ F_n ∧ q ∣ F_n)` is purely periodic with minimal period exactly
`lcm(entryPoint p) (entryPoint q)`, and consequently
`#{x ∈ (0,N] : p ∣ F_x ∧ q ∣ F_x} = N / lcm(e_p, e_q)`.
The key insight is that `apparition_iff` reduces the conjunction `p ∣ F_n ∧ q ∣ F_n` to
`e_p ∣ n ∧ e_q ∣ n`, i.e. `lcm(e_p, e_q) ∣ n`, so the same `Finset.filter_congr` +
`Nat.Ioc_filter_dvd_card_eq_div` pipeline that proved `apparition_count` applies once the
two-divisor predicate is collapsed to a single `lcm` divisibility.
Why now? `apparition_iff` already converts each apparition condition into a clean
divisibility, and Mathlib's `Nat.lcm_dvd_iff` closes the conjunction instantly — the only
new ingredient is one `lcm` rewrite, making this a low-risk immediate extension.

### 2. Entry points compose: `entryPoint (p*q) = lcm(entryPoint p)(entryPoint q)` for coprime `p,q`

Conjecture: if `gcd p q = 1` and both `p, q` have entry points, then
`entryPoint (p*q) = Nat.lcm (entryPoint p) (entryPoint q)`.
The key insight is that for coprime `p, q`, `p*q ∣ F_n ↔ p ∣ F_n ∧ q ∣ F_n` (CRT /
`Nat.Coprime.mul_dvd_of_dvd_of_dvd`), which by `apparition_iff` is `lcm(e_p,e_q) ∣ n`;
minimality of the entry point then pins `entryPoint (p*q)` to the least such `n`, namely
`lcm(e_p, e_q)` itself.
Why now? This is the multiplicative structure theorem that turns the single-prime period
law of this cycle into a full computation of entry points from their prime-power parts; it
needs only Direction 1's `lcm` collapse plus the existing `entryPoint_min`/`Nat.find`
minimality machinery, so no new analytic input is required.

### 3. Apparition density is asymptotically `1/e`

Conjecture: `(fun N => (#{x ∈ (0,N] : p ∣ F_x} : ℝ) / N)` tends to `1 / entryPoint p`
as `N → ∞`. The key insight is that `apparition_count` gives the count *exactly* as the
integer `⌊N/e⌋`, so the density is `⌊N/e⌋ / N`, and the standard squeeze
`N/e - 1 < ⌊N/e⌋ ≤ N/e` forces convergence to `1/e` with no number theory left to do.
Why now? With the exact count already in hand, this is a pure real-analysis limit
provable by `Filter.Tendsto` + a `squeeze`/`Nat.lt_div_add_one`-style sandwich; it upgrades
the discrete counting theorem to the analytic "natural density" statement that connects the
period viewpoint to equidistribution language.

### 4. Carmichael's infinite tail reduces to "entry point equals `n`"

Conjecture (a constructive reformulation of the open `sorry` in
`Catalog/Shared/CarmichaelProof.lean`): for `n ≥ 13` with `n ≠ 12`, `F_n` has a primitive
prime divisor **iff** some prime `p ∣ F_n` has `entryPoint p = n`, and the latter holds
whenever `F_n` is not entirely built from primes appearing at proper divisors of `n`.
The key insight is `primitive_iff_entry_eq` (catalog) combined with this cycle's
`apparition_iff`: a prime is primitive for `F_n` exactly when its period `e` equals `n`,
turning the hard "infinite tail" of Carmichael into the cyclotomic-style question of when
the *primitive part* `Φ_n^{Fib}` exceeds `1`.
Why now? The period law makes "primitive divisor" synonymous with "entry point `= n`",
so the tail case becomes a statement about the primitive (cyclotomic) part of `F_n` — a
problem with a known lower-bound strategy (`F_n` grows like `φ^n` while the imprimitive
part is bounded by `∏_{d|n, d<n} F_d`), giving a concrete, falsifiable attack on the
catalog's remaining `sorry`.

### 5. Window uniqueness yields an O(1)-memory streaming sampler

Conjecture: there is a deterministic streaming procedure that, reading indices
`1, 2, 3, …` and maintaining only the residue `n mod e`, emits exactly the apparition
indices of `p`, one per length-`e` block, and this is optimal (no sublinear-in-`e` memory
sampler can be exact). The key insight is `apparition_window_unique`: because each window
`(m, m+e]` contains a *unique* apparition, a single mod-`e` counter is a complete and
collision-free certificate of membership in the apparition set.
Why now? The uniqueness theorem is already formalized, so the sampler's correctness is a
direct corollary; formalizing it would connect the catalog's number theory to the
algorithmic/complexity thread (streaming lower bounds) and concretely realize the
"uniform period-sampling" objective that named this research line.
