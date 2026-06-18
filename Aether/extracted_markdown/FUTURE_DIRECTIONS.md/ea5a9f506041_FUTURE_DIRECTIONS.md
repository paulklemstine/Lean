# Future Directions — Stereographic Capacity Theory for Fibonacci Apparitions

## Synthesis

This cycle built a *capacity / packing* layer on top of the catalog's Fibonacci
divisibility lattice (`Cryptography.FibonacciDivisibilityLattice`, the
`Fib_gcd_identity` lineage). The pivot was reading the apparition law
`m ∣ fib n ↔ entry m ∣ n` not as a divisibility fact but as a statement that *the
apparition index set is a set of multiples*, and therefore admits exact counting.

The new file `Catalog/Computation/FibonacciApparitionCapacity.lean` proves four
results, all `sorry`-free and depending only on `propext`, `Classical.choice`,
`Quot.sound`:

1. **`entry_dvd_of_dvd`** — the rank of apparition is monotone for divisibility:
   `a ∣ b → entry a ∣ entry b`.
2. **`entry_lcm`** — `entry` is an lcm-homomorphism:
   `entry (lcm a b) = lcm (entry a) (entry b)`.
3. **`apparition_count`** — exact capacity: `#{n ∈ (0,N] : m ∣ fib n} = N / entry m`.
4. **`apparition_density_bound`** — uniform packing density: for `m ≥ 2`,
   `3 · #{apparitions ≤ N} ≤ N`, with `1/3` sharp (witnessed by `m = 2`,
   `entry 2 = 3`).

This is a Cryptography → Computation bridge: a Lucas/rank-of-apparition structure
became an exact counting/packing theorem.

## Results summary

| Result | Statement | Status |
|---|---|---|
| `entry_dvd_of_dvd` | `a ∣ b → entry a ∣ entry b` | proved |
| `entry_lcm` | `entry (lcm a b) = lcm (entry a) (entry b)` | proved |
| `apparition_count` | `#{n ∈ (0,N] : m ∣ fib n} = N / entry m` | proved |
| `apparition_density_bound` | `m ≥ 2 → 3 · #{apparitions ≤ N} ≤ N` | proved |

---

## Direction 1 — `entry` is **not** a gcd-homomorphism (refute the dual)

The lcm-homomorphism `entry (lcm a b) = lcm (entry a) (entry b)` begs the dual
question: is `entry (gcd a b) = gcd (entry a) (entry b)`? **Conjecture: this is
false, and the witness `a = 4, b = 6` refutes it.** Here `entry 4 = 6`,
`entry 6 = 12`, `gcd(4,6) = 2`, so the left side is `entry 2 = 3`, while the right
side is `gcd(6,12) = 6 ≠ 3`. The falsifiable task is to formalize this
counterexample and then characterize *exactly* the pairs `(a,b)` for which the gcd
identity does hold (the data suggests: precisely when `entry a` and `entry b` are
already "aligned", e.g. one rank divides the other).

The key insight is that `lcm` is the join in the apparition lattice and is preserved
because `lcm a b ∣ fib n ↔ a ∣ fib n ∧ b ∣ fib n` decomposes a single apparition set
into an intersection, whereas `gcd` is the meet and corresponds to a *union* of
apparition sets, which is not itself a set of multiples — so no rank can represent
it in general.

Why now? `entry_lcm` is already proved, so the homomorphism machinery is in place;
the meet/join asymmetry is the immediate stress-test and a clean adversarial result
(a proved non-theorem with an explicit witness) that sharpens the structure.

## Direction 2 — Law of apparition modulo a prime

**Conjecture (Lucas's law of apparition):** for every prime `p ≠ 5`,
`entry p ∣ p - legendreSym 5 p`, i.e. `entry p ∣ p - 1` when `5` is a quadratic
residue mod `p` (`p ≡ ±1 mod 5`) and `entry p ∣ p + 1` otherwise
(`p ≡ ±2 mod 5`). Falsifiable: a single prime violating the claimed divisor would
sink it; verifying it for all primes below a bound is a concrete first milestone.

The key insight is that `fib (p - legendreSym 5 p) ≡ 0 (mod p)` follows from the
Binet/`ZMod` identity `fib p ≡ legendreSym 5 p (mod p)` together with
`fib (p+1) ≡ ...`, after which `apparition_count` immediately upgrades this single
divisibility into the statement that a `Θ(N/p)` fraction of indices `≤ N` are
apparitions of `p`.

Why now? `apparition_count` turns any apparition-index bound into a density
statement for free, so proving the rank bound `entry p ≤ p + 1` instantly yields a
quantitative "every prime appears with density `≥ 1/(p+1)`" theorem — exactly the
capacity viewpoint this cycle introduced.

## Direction 3 — Close the Carmichael composite tail via rank growth

`Catalog/Shared/CarmichaelProof.lean` proves the primitive-divisor theorem for
composite `13 ≤ n ≤ 10000` by `native_decide` but leaves the tail `n > 10000` as a
`sorry`. **Conjecture:** the tail follows from a *rank-injectivity* statement —
for composite `n`, the primitive part `primPart n` exceeds `1` because the ranks
`entry (fib d)` for proper divisors `d ∣ n` cannot jointly exhaust the prime factors
of `fib n` once `fib n` outgrows `∏_{d ∣ n, d < n} fib d`.

The key insight is that a prime `p` is primitive for `F_n` iff `entry p = n`
(catalog `primitive_iff_entry_eq`), so the existence of a primitive divisor is
equivalent to `entry` *hitting* `n`; combined with `entry_dvd_of_dvd` and the
Carmichael–Zsygmondy size estimate `fib n > ∏_{d∣n, d<n} fib d` for large `n`, the
counting becomes a pigeonhole on apparition indices.

Why now? This cycle established `entry` as a structured (monotone, lcm-respecting)
function with an exact counting law; that is precisely the toolkit needed to replace
the brute-force `native_decide` window with a uniform argument for the infinite tail.

## Direction 4 — Capacity theory for general Lucas / strong divisibility sequences

**Conjecture:** every *strong divisibility sequence* `u` (i.e. `gcd(u_m,u_n) =
u_{gcd(m,n)}`) with `u` eventually strictly increasing admits a rank function
`entryU` satisfying the same package proved here: `u_m ∣ u_n ↔ entryU m ∣ n`,
`entryU` is an lcm-homomorphism, and `#{n ∈ (0,N] : m ∣ u_n} = N / entryU m`. The
Fibonacci file is the prototype; the claim is that *nothing was special about
Fibonacci* beyond the gcd identity plus monotonicity.

The key insight is that all four theorems used only two inputs — the gcd identity
(for the apparition law) and strict monotonicity (for rank well-definedness via
`Nat.find`) — so abstracting to a typeclass `StrongDivSeq` should reproduce them
verbatim, with Lucas sequences `U_n(P,Q)` and Mersenne-type sequences as instances.

Why now? The proofs in this cycle are short and structural rather than
Fibonacci-arithmetic-specific, which is exactly the signal that the right move is to
generalize the carrier and harvest many sequences (Pell, Lucas, repunits) at once.

## Direction 5 — Sharp lower bounds and a packing "Pisano" refinement

`apparition_density_bound` gives the uniform upper bound `density ≤ 1/3`. **Conjecture
(two-sided):** for every `m ≥ 1` the apparition density of `m` is *exactly*
`1 / entry m`, and moreover `entry m` divides the Pisano period `π(m)` with quotient
in `{1, 2, 4}`; consequently `density(m) ∈ {1, 2, 4} / π(m)`. Falsifiable: a modulus
with `π(m) / entry m ∉ {1,2,4}` refutes the quotient claim.

The key insight is that `apparition_count = N / entry m` is the *exact* count, not
just a bound, so dividing by `N` and taking `N → ∞` makes the density literally
`1/entry m`; tying `entry m` to the Pisano period `π(m)` then converts the capacity
statement into a statement about the order of the Fibonacci shift matrix in
`SL₂(ℤ/m)`.

Why now? With the exact count `N / entry m` in hand, the asymptotic density is a
one-line limit, so the only remaining content is the arithmetic of `entry m` versus
`π(m)` — a self-contained, highly testable number-theoretic target.
