# Future Directions — The Multiplicative Algebra of the Fibonacci Entry Point

## Synthesis

This cycle closed two genuine `sorry` placeholders in the catalog's Fibonacci
entry-point program and erected a new layer of theory on top of them. The entry
point (rank of apparition) `α(m)` is the least positive index `k` with `m ∣ F(k)`.
The catalog already contained the *ideal-structure theorem*
`fib_dvd_iff_entryPt_dvd : m ∣ F(k) ↔ α(m) ∣ k`
(in `Speculative/AutoResearch/FibonacciEntryPointCharacterization.lean`), but its
multiplicative consequences were left open: the two-factor lcm law was stated as a
`sorry`-target, and there was no account of how `α` interacts with the
divisibility lattice of moduli.

The unifying realization is that *all* of this structure is a corollary of the one
bridge lemma. Once `{k | m ∣ F k}` is known to be the principal ideal `(α m)` of
`(ℕ, ∣)`, the map `α : ℕ → ℕ` inherits a rich algebra purely by elementary
divisibility/lcm bookkeeping — the Fibonacci-specific content never has to be
revisited. We made this precise: monotonicity under divisibility, the
trivial-modulus test, lattice closure, the two-factor lcm law, and the **finite
lcm law** `α(∏ m_i) = lcm_i α(m_i)` for pairwise-coprime families.

## Results Summary

Closed `sorry` placeholders:
- `FibEntryChar.fibEntryPt_mul_coprime` — the two-factor lcm law
  `α(a·b) = lcm(α a, α b)` for coprime `a, b`
  (in `FibonacciEntryPointCharacterization.lean`).

New file `Speculative/AutoResearch/FibonacciEntryPointMultiplicative.lean`
(all theorems `sorry`-free; axioms: `propext`, `Classical.choice`, `Quot.sound`):
- `entryPt_exists_of_dvd` — divisors of a modulus with an entry point again admit one.
- `fibEntryPt_dvd_of_dvd` — `a ∣ b ⟹ α(a) ∣ α(b)` (monotonicity under divisibility).
- `fibEntryPt_one`, `fibEntryPt_eq_one_iff` — `α(1) = 1` and `α(m) = 1 ↔ m ∣ 1`.
- `fib_dvd_lcm_of_dvd_left` — lcm-closure of the apparition index set.
- `entryPt_exists_prod_coprime` — finite coprime products admit an entry point.
- `fibEntryPt_prod_coprime` — the **finite lcm law**
  `α(∏ i ∈ s, m i) = s.lcm (α ∘ m)` for pairwise-coprime families.

The one remaining hard `sorry` in this neighborhood is the *infinite tail* of
Carmichael's primitive-divisor theorem in `Shared/CarmichaelProof.lean`
(composite `n > 10000`); the finite range is discharged by `native_decide`. The
directions below are the natural attack surface for it and for sharpening the new
theory.

## Research Directions

### 1. Reconstructing `α` from the prime-power factorization
The finite lcm law applies to the coprime factors `p^{v_p(m)}` of any `m`, giving
`α(m) = lcm_{p | m} α(p^{v_p(m)})`. The missing piece is the **prime-power law**
`α(p^e) = p^{max(e − v_p(F_{α(p)}), 0)} · α(p)`, the entry-point analogue of
Lifting-the-Exponent. **Conjecture:** for every prime `p` with entry point and
every `e ≥ 1`, `α(p^e) = p^{(e − v_p(F_{α p})) ⊔ 0} · α(p)`. *The key insight is*
that `v_p(F_k)` grows by exactly one each time `k` gains a factor of `p` once
`α(p) ∣ k`, so the entry point of `p^e` is forced by a single LTE step rather than
by recomputing apparitions. *Why now?* The catalog already contains the LTE
machinery (`fib_lte`, `padic_val_mul_eq_add` in the Tropical/LTE file) and we now
have the finite lcm law to glue the prime powers together — the two halves have
never been connected. Falsifiable: a single counterexample `(p, e)` checked by
`decide` refutes it.

### 2. A purely entry-point proof of the Carmichael infinite tail
The remaining `sorry` in `CarmichaelProof.lean` asks for a primitive prime divisor
of `F_n` for composite `n > 10000`. **Conjecture:** for `n ∉ {1,2,6,12}`, the
"primitive part" `Φ_n := F_n / ∏_{d|n, d<n} gcd-stripped F_d` exceeds the product
of its possible *intrinsic* (non-primitive) prime factors, each bounded by `n` via
`α(p) ∣ n` and `p ≤` an LTE bound. *The key insight is* that a prime `p` divides
`F_n` non-primitively only when `α(p)` is a proper divisor of `n` and `p ∣ n`
(an LTE-controlled "wandering" factor), so the count and size of intrinsic factors
is `O(log n)` while `F_n` grows like `φ^n` — an exponential-vs-polynomial gap.
*Why now?* `entryPt_eq_iff_primitive` already recasts primitivity as `α(p) = n`,
and `fibEntryPt_prod_coprime` controls how intrinsic factors aggregate; combined
with `fib_exponential_lower_bound` from the catalog, the size inequality becomes a
finite analytic estimate. Falsifiable: the inequality `Φ_n > (LTE bound)^{ω(n)}`
can be tested numerically for `n` up to any chosen ceiling.

### 3. The image of `α` and a Fibonacci "apparition spectrum"
**Conjecture:** every `n ≥ 1` with `n ∉ {1,2,6,12}` is in the image of `α`
restricted to primes (i.e. some prime has entry point exactly `n`), and the fibers
`α^{-1}(n) ∩ primes` are exactly the primitive prime divisors of `F_n`. *The key
insight is* that surjectivity of `α|_primes` onto `ℕ \ {1,2,6,12}` is *equivalent*
to Carmichael's theorem via `entryPt_eq_iff_primitive`, turning an existence
statement into a statement about a single arithmetic function. *Why now?* With the
multiplicative structure of `α` in hand, the image question reduces to prime
inputs, and the catalog's small-case verifications (`fib_three_has_primitive`, …)
already pin the low end. Falsifiable: an `n` with no prime of entry point `n`,
found by factoring `F_n`, refutes it.

### 4. Generalization to Lucas sequences `U_n(P,Q)`
**Conjecture:** every theorem in `FibonacciEntryPointMultiplicative.lean` holds
verbatim for a nondegenerate Lucas sequence `U_n(P,Q)` with `gcd(P,Q)=1`, with `F`
replaced by `U` and `Nat.fib_gcd`/`Nat.fib_dvd` replaced by their Lucas analogues
`gcd(U_m,U_n)=U_{gcd(m,n)}` and `U_m ∣ U_n ⇐ m ∣ n`. *The key insight is* that the
entire development used *only* the gcd-divisibility identity and the
divisibility-monotonicity of the index — never a closed form — so the proofs are
parametric in the underlying divisibility sequence. *Why now?* Abstracting the two
input lemmas into a typeclass `IsDivisibilitySequence` would let the catalog reuse
this algebra across Fibonacci, Mersenne (`U_n(3,2)=2^n−1`), and Pell sequences in
one stroke. Falsifiable: exhibit a sequence satisfying the gcd identity for which
the lcm law fails — this would expose a hidden extra hypothesis.

### 5. Entry points and the order of the Fibonacci sequence modulo `m`
**Conjecture:** `α(m)` divides the Pisano period `π(m)`, and for prime `p`,
`π(p)/α(p) ∈ {1, 2, 4}` with the value determined by the 2-adic valuation of the
multiplicative order of the golden ratio in `𝔽_{p^2}^×`. *The key insight is* that
`α(p)` is the order of the companion matrix `Q = !![1,1;1,0]` *projectively*
(modulo scalars), while `π(p)` is its true order, so their ratio measures the
scalar `Q^{α(p)} = λ·I` — a single eigenvalue datum. *Why now?* The catalog's
`entry_point_dvd_sq_sub_one` already diagonalizes `Q` over `AlgebraicClosure (ZMod p)`
and extracts `α(p) ∣ p^2−1`; the same diagonalization yields `π(p)` with almost no
extra work, making the ratio theorem reachable. Falsifiable: a prime `p` with
`π(p)/α(p) ∉ {1,2,4}` (computable by `decide`) refutes it.
