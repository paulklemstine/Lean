# Future Directions — Fibonacci Entry Points, Apparition, and Carmichael Primitive Divisors

## Synthesis of this cycle

The Fibonacci **entry point** (rank of apparition) `α(m)` — the least `k > 0` with
`m ∣ F(k)` — is the organizing invariant tying together the catalog's scattered
Fibonacci-divisibility results (`fib_dvd_fib_iff`, `fibEntry_lcm`, the apparition
lattice, the p-adic valuation/LTE file, and the two Carmichael files).  This cycle
sharpened that picture in two concrete ways.

1. **Closed the `lcm`-law `sorry`.**  `FibEntryChar.fibEntryPt_mul_coprime`
   (`α(a·b) = lcm(α a, α b)` for coprime `a, b`) was a stated-but-unproven research
   target in `Catalog/Speculative/AutoResearch/FibonacciEntryPointCharacterization.lean`.
   It is now proved with `sorry = 0`, directly from the characterization
   `m ∣ F(k) ↔ α(m) ∣ k`.

2. **Promoted `α` to a factorization-determined arithmetic function.**  Building on
   the catalog fact that *every* `m ≥ 1` admits an entry point (a Pisano/pigeonhole
   result), the same file now contains a self-contained Part II proving, all
   `sorry`-free:
   * `entry_exists` — totality of `α` on positive moduli;
   * `fibEntryPt_dvd_of_dvd` — `α` is a **divisibility-order morphism**
     (`a ∣ b ⟹ α a ∣ α b`);
   * `fibEntryPt_prod_coprime` — the **n-ary `lcm` law** for pairwise coprime families
     (the `Finset` generalization of the binary law);
   * `fibEntryPt_factorization` — the **reconstruction law**
     `α(m) = lcm_{p ∣ m} α(p^{v_p(m)})`, reducing the computation of `α` to prime powers.

The one target that resisted automation is the **infinite tail of Carmichael's
theorem** (`fib_carmichael_composite` for composite `n > 10000` in
`Catalog/Shared/CarmichaelProof.lean`).  Its `n ≤ 10000` range is settled by
`native_decide`; the tail is the genuine Carmichael (1913) primitive-divisor theorem
and has no finite proof.  It remains a `sorry`, now fully documented in-file (a
broken dead `import` that previously prevented the file from elaborating was also
removed).

## Results summary

| Result | File | Status |
|---|---|---|
| `fibEntryPt_mul_coprime` (binary lcm law) | `FibonacciEntryPointCharacterization.lean` | proved (was `sorry`) |
| `entry_exists` (totality of α) | `FibonacciEntryPointCharacterization.lean` | proved (new) |
| `fibEntryPt_dvd_of_dvd` (order morphism) | `FibonacciEntryPointCharacterization.lean` | proved (new) |
| `fibEntryPt_prod_coprime` (n-ary lcm law) | `FibonacciEntryPointCharacterization.lean` | proved (new) |
| `fibEntryPt_factorization` (reconstruction) | `FibonacciEntryPointCharacterization.lean` | proved (new) |
| `fib_carmichael_composite` tail (`n > 10000`) | `CarmichaelProof.lean` | open (`sorry`, documented) |

## Research directions

### 1. Discharge the infinite tail of Carmichael's theorem via cyclotomic growth

State and prove, in Lean, that for composite `n > 12` the primitive part of `F(n)`
exceeds `1`, closing `fib_carmichael_composite` and `fib_carmichael_large`.  The
program is to introduce the homogeneous cyclotomic value
`Φ_n = ∏_{d ∣ n} (φ^d − ψ^d)^{μ(n/d)}` (with `φ, ψ` the golden-ratio conjugates),
prove the factorization `∏_{d ∣ n} Φ_d = F(n)` and the bound `Φ_n > P` for the
largest prime `P ∣ n`, and show `Φ_n` carries at most one non-primitive prime factor.
**The key insight is** that the entry-point theory already built here supplies the
"at most one non-primitive factor" half cheaply — `α(p) = n` is exactly primitivity,
and `fibEntryPt_factorization` controls which primes can be non-primitive — so the
only genuinely missing ingredient is the *analytic* lower bound `Φ_n ≥ φ^{φ(n)}/c`,
a finite real-analysis estimate rather than new algebra.  **Why now?** The
computational `native_decide` certificate already verifies the statement up to
`n = 10000`; this both rules out small counterexamples (so the conjecture is safe to
invest in) and pins down the exact threshold above which only the growth bound is
needed, turning an open-ended theorem into a single quantitative lemma to formalize.

### 2. A sharp upper bound and divisibility law for `α` on primes

Conjecture: for every prime `p ≠ 5`, `α(p) ∣ p − (5/p)` where `(5/p)` is the
Legendre symbol, and consequently `α(p) ≤ p + 1`.  This is falsifiable: a single
prime with `α(p) ∤ p − (5/p)` refutes it.  **The key insight is** that the
characterization `p ∣ F(k) ↔ α(p) ∣ k` reduces the bound to the *single*
divisibility `p ∣ F_{p − (5/p)}`, which is the Fibonacci form of Euler's criterion
in `ℤ[φ]/p`; no growth estimates are required, only the Frobenius action on the
quadratic field.  **Why now?** With `fibEntryPt` and its order-morphism property
already formalized, the statement `α(p) ∣ N` is now a one-line consequence of
`p ∣ F(N)`, so the whole problem collapses to proving that one membership — an
isolated, self-contained target.

### 3. Prime-power growth of `α` (the Wall–Sun–Sun frontier)

Conjecture: for every prime `p` and `k ≥ 1`, `α(p^{k+1}) ∈ {α(p^k), p · α(p^k)}`,
and `α(p^{k+1}) = p · α(p^k)` whenever `p^2 ∤ F_{α(p)}`.  Combined with
`fibEntryPt_factorization`, this would give a *complete* closed form for `α(m)` from
the data `(α(p), v_p(F_{α(p)}))` over `p ∣ m`.  It is falsifiable by exhibiting a
prime power where `α` jumps by a factor other than `1` or `p`.  **The key insight is**
that the reconstruction law proved this cycle already reduces `α` of any modulus to
`α` of prime powers, so the *only* remaining unknown in a full formula for `α` is
this prime-power recursion — exactly the lifting-the-exponent phenomenon governed by
`v_p(F_{α(p)})`.  **Why now?** The catalog already contains a Fibonacci LTE / p-adic
valuation file, and `fibEntryPt_factorization` is the bridge that makes a prime-power
law immediately upgrade to all `m`; the two pieces have never been connected.

### 4. The meet law fails — characterize the defect `α(gcd a b) / gcd(α a, α b)`

The lcm (join) law is now an iff-level theorem, but `α` is *not* a meet morphism:
in general only `gcd(α a, α b) ∣ α(gcd a b)`, and the inclusion can be strict.
Conjecture: `α(gcd a b) = gcd(α a, α b)` holds **iff** `a` and `b` share no prime `p`
for which the `p`-parts of `α a` and `α b` differ.  This is falsifiable by a single
pair `(a, b)` violating either direction.  **The key insight is** that the failure is
localized entirely at shared primes — precisely the primes excluded by the
*coprime* hypothesis in `fibEntryPt_prod_coprime` — so the defect is computable from
the prime-power data of direction 3.  **Why now?** Having proved the join law as a
clean lattice identity, the natural adversarial question ("does the dual hold?") is
ripe, and the order-morphism lemma `fibEntryPt_dvd_of_dvd` already gives the easy
inclusion for free, isolating exactly the hard direction.

### 5. Entry point vs. Pisano period: the ratio is always in `{1, 2, 4}`

Let `π(m)` be the Pisano period (the period of `F mod m`).  Conjecture:
`α(m) ∣ π(m)` and the quotient `π(m) / α(m)` always lies in `{1, 2, 4}`, with the
value determined by the order of `(-1)^{?}` acting on the apparition.  It is
falsifiable by any `m` with `π(m)/α(m) ∉ {1,2,4}`.  **The key insight is** that the
existence proof `entry_exists` already constructs the entry point from the orbit of
the Fibonacci shift permutation on `ZMod m × ZMod m`, and the Pisano period is the
*full* orbit length of `(0,1)` under that same permutation — so `α` and `π` are two
invariants of one finite dynamical system, and their ratio is the index of a
cyclic subgroup.  **Why now?** The `fibStep` permutation and its iterate lemma
`fibStep_iterate` are already in the file as the engine behind `entry_exists`;
reusing them to define `π(m)` and relate it to `α(m)` requires no new machinery,
only a subgroup-index argument on an object already formalized.
