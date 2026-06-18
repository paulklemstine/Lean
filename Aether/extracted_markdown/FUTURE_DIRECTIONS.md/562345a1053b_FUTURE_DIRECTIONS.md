# Future Directions — Capacity / Packing Theory for Fibonacci Apparitions

## Synthesis

This cycle built a *capacity / packing* layer on top of the catalog's Fibonacci
divisibility lattice (`Cryptography.FibonacciDivisibilityLattice`, the `Nat.fib_gcd` /
`Fib_gcd_identity` lineage) and its entry-point homomorphism theory
(`Cryptography.FibonacciEntryHomomorphism`, the `FibEntry` namespace). The catalog had
already established `entry` as an *algebraic* object: monotone for divisibility
(`FibEntry.entry_dvd_of_dvd`) and a join/lcm homomorphism (`FibEntry.entry_lcm`), both
driven purely by the apparition law `FibLattice.fib_dvd_iff_entry_dvd : m ∣ fib n ↔
entry m ∣ n`.

The pivot of this cycle was to read that same apparition law not as a divisibility fact
but as the statement that the apparition index set `{n : m ∣ fib n}` is *exactly the set
of multiples of `entry m`*. A set of multiples admits exact counting — so the
qualitative lattice law becomes a quantitative **measure** on the integers. The new file
`Catalog/Computation/FibonacciApparitionCapacity.lean` (namespace `FibCapacity`) proves
this, turning a Cryptography rank-of-apparition structure into a Computation
counting/packing theorem, and stress-tests the homomorphism by refuting its meet (gcd)
dual.

## Results summary

| Result | Statement | Status |
|---|---|---|
| `FibCapacity.entry_ge_three` | `m ≥ 2 → 3 ≤ entry m` | proved |
| `FibCapacity.apparition_count` | `#{n ∈ (0,N] : m ∣ fib n} = N / entry m` | proved |
| `FibCapacity.apparition_density_bound` | `m ≥ 2 → 3 · #{apparitions ≤ N} ≤ N` | proved |
| `FibCapacity.entry_not_gcd_hom` | `entry (gcd 4 6) = 3 ≠ 6 = gcd (entry 4) (entry 6)` | proved |

All results are `sorry`-free and depend only on `propext`, `Classical.choice`,
`Quot.sound`. They build on, rather than reprove, the catalog lemmas
`FibLattice.fib_dvd_iff_entry_dvd`, `FibEntry.entry_lcm`, and `FibEntry.entry_dvd_of_dvd`.

---

## Direction 1 — Asymptotic density is *exactly* `1 / entry m`

`apparition_count` is an **exact** identity, `#{n ∈ (0,N] : m ∣ fib n} = N / entry m`,
not merely a bound. Dividing by `N` and letting `N → ∞`, the floor `N / entry m`
satisfies `|N / entry m - N / (entry m : ℝ)| < 1`, so the apparition density of `m`
converges to exactly `1 / entry m`. **Conjecture:** `Filter.Tendsto (fun N =>
(#{n ∈ (0,N] : m ∣ fib n} : ℝ) / N) atTop (𝓝 (1 / entry m))`. Falsifiable: any modulus
whose empirical density deviates from `1/entry m` by a fixed margin refutes it.

The key insight is that `apparition_count` already collapses the limit to the elementary
fact `Nat.cast (N / e) / N → 1/e`; there is no remaining Fibonacci content, only the
real-analytic statement that floored division is asymptotically exact, so the proof is a
squeeze between `(N/e - 1)/N` and `(N/e)/N`.

Why now? The exact count is in hand this cycle, so the density theorem is a one-screen
`Filter.Tendsto` argument that upgrades a counting identity into a genuine
measure-theoretic statement — the natural capstone of the capacity viewpoint.

## Direction 2 — Characterize *exactly* when the gcd law holds

`entry_not_gcd_hom` refutes `entry (gcd a b) = gcd (entry a) (entry b)` in general
(witness `(4,6)`). But the law clearly *does* hold sometimes — e.g. whenever `a ∣ b`,
since then `gcd a b = a` and `entry a ∣ entry b` (catalog `entry_dvd_of_dvd`) gives
`gcd (entry a) (entry b) = entry a`. **Conjecture:** `entry (gcd a b) =
gcd (entry a) (entry b)` holds **iff** `entry (gcd a b) = gcd (entry a) (entry b)` is
forced by alignment, precisely when one of `entry a ∣ entry b` or `entry b ∣ entry a`
holds — i.e. the ranks form a chain. Falsifiable: a pair with non-comparable ranks yet
satisfying the gcd identity, or a comparable pair violating it, sinks the claim.

The key insight is that `entry` is a *left adjoint* (the apparition law is literally an
adjunction `entry m ∣ n ↔ m ∣ fib n`), and left adjoints preserve joins but only those
meets that are already "split" by a chain condition; the chain hypothesis is exactly
what makes the meet behave like a join.

Why now? We have both the positive lcm law and an explicit negative witness, so the
remaining task is the clean boundary between them — a self-contained order-theoretic
characterization that sharpens the homomorphism structure.

## Direction 3 — Law of apparition modulo a prime, as a density theorem

**Conjecture (Lucas's law of apparition):** for every prime `p ≠ 5`,
`entry p ∣ p - legendreSym 5 p`; concretely `entry p ≤ p + 1`, with `entry p ∣ p - 1`
when `p ≡ ±1 (mod 5)` and `entry p ∣ p + 1` when `p ≡ ±2 (mod 5)`. Combined with
`apparition_count`, this immediately yields the *quantitative* statement that the
apparitions of any prime `p` occupy a density `1/entry p ≥ 1/(p+1)` of the integers.
Falsifiable: a single prime with `entry p > p + 1` refutes the rank bound.

The key insight is that `fib (p - legendreSym 5 p) ≡ 0 (mod p)` follows from the `ZMod`
Binet identity `fib p ≡ legendreSym 5 p (mod p)`; feeding this single divisibility
through the apparition law gives `entry p ∣ p - legendreSym 5 p`, and `apparition_count`
then converts the rank bound into a density-`≥ 1/(p+1)` packing statement for free.

Why now? `apparition_count` turns any apparition-index bound into a density statement
automatically, so the only new work is the one `ZMod` congruence — after which the
capacity machinery of this cycle does the rest.

## Direction 4 — Capacity theory for general strong divisibility sequences

**Conjecture:** every *strong divisibility sequence* `u` (i.e. `gcd(u_m, u_n) =
u_{gcd(m,n)}`) that is eventually strictly increasing admits a rank function `entryU`
satisfying the *entire* package proved here and in the catalog: `u_m ∣ u_n ↔ entryU m ∣
n`, `entryU` is monotone and an lcm-homomorphism, and `#{n ∈ (0,N] : m ∣ u_n} =
N / entryU m`. Fibonacci is just the prototype. Falsifiable: a strong divisibility
sequence (e.g. a Lucas `U_n(P,Q)`, Pell numbers, or repunits) where the counting law
fails refutes the abstraction.

The key insight is that *every* proof in this cycle used only two inputs — the gcd
identity (for the apparition law) and strict monotonicity (for rank well-definedness via
`Nat.find`) — and nothing Fibonacci-specific; so packaging these two hypotheses into a
typeclass `StrongDivSeq` should reproduce all four theorems verbatim, instantiated by
many classical sequences at once.

Why now? The proofs here are short and structural rather than arithmetic, which is
exactly the signal that the carrier can be abstracted; doing so harvests Pell, Lucas,
and Mersenne-type capacity theorems from a single generic development.

## Direction 5 — Tie `entry m` to the Pisano period and refine the packing constant

`apparition_density_bound` gives the uniform constant `1/3` (sharp at `m = 2`).
**Conjecture (two-sided refinement):** for every `m ≥ 1`, `entry m` divides the Pisano
period `π(m)` with quotient in `{1, 2, 4}`; consequently the apparition density
`1/entry m ∈ {1, 2, 4}/π(m)`, and the *exact* density spectrum of all moduli is
`{k/π(m) : k ∈ {1,2,4}}`. Falsifiable: a modulus with `π(m)/entry m ∉ {1,2,4}` refutes
the quotient claim outright.

The key insight is that `entry m` is the order of the bottom-left entry of the
Fibonacci shift matrix `[[1,1],[1,0]]^n` in `SL₂(ℤ/m)`, while `π(m)` is the order of the
whole matrix; the quotient `π(m)/entry m` is therefore the order of the *scalar* the
matrix collapses to at index `entry m`, which is `±1` or a 4th root of unity — pinning
the quotient to `{1,2,4}`.

Why now? With the exact count `N/entry m` established, the density is literally
`1/entry m`, so the only remaining content is the group-theoretic arithmetic of
`entry m` versus `π(m)` in `SL₂(ℤ/m)` — a self-contained, highly testable target that
would complete the capacity picture with an exact density spectrum.
