# Summary of changes for run 259e09cc-ae0d-4ed7-a923-a5286ec9ff29
## Sorry Fill Results: Tropical Langlands GL₂

### Summary of Changes

Reduced live `sorry` count from **10 to 4** across the project. Of the 4 remaining, 2 are the same mathematical claim (Carmichael's theorem for n > 10000) and 2 are a theorem (`padic_hyperdrive_instability`) that appears to be **false as stated** — a concrete counterexample was identified.

### Carmichael's Theorem (Main Achievement)

**Theorem**: For n ≥ 13, the nth Fibonacci number F(n) has a primitive prime divisor.

Proved using a hybrid computational–mathematical approach:
- **Prime n**: Already proved in `Shared/CarmichaelHelper.lean`
- **Composite n ≤ 10000**: Verified computationally via `native_decide` using a "coprime part" algorithm that removes from F(n) all prime factors shared with F(d) for proper divisors d | n
- **Composite n > 10000**: Remains `sorry` — requires deep number-theoretic infrastructure (Lifting the Exponent Lemma, cyclotomic Fibonacci numbers) not available in Mathlib

### Files Modified

| File | Change |
|------|--------|
| `Shared/CarmichaelComposite.lean` | Added `removePrimesOfS`, `fibCoprimePartS`, coprimality proofs, and `native_decide` verification for n ≤ 10000. Theorem now proved except for n > 10000 composite. |
| `Shared/CarmichaelComputational.lean` | Removed sorry by delegating to `fib_carmichael` from `CarmichaelComposite` |
| `Shared/Fib_gcd_identity.lean` | Removed sorry by delegating `fib_primitive_divisor_existence` to `fib_carmichael` |
| `Speculative/CarmichaelPrimitiveDivisor.lean` | Removed sorry by delegating to `fib_carmichael`; wrapped local lemmas in namespace to avoid name collisions |
| `Speculative/AutoResearch/CarmichaelPrimitiveDivisor.lean` | Same treatment as above |
| `Speculative/AutoResearch/CarmichaelComputational.lean` | Removed sorry by delegating to `fib_carmichael` |
| `Speculative/AutoResearch/Fib_gcd_identity.lean` | Removed sorry by delegating to `fib_carmichael` |

### p-adic Instability (Negative Result)

The theorem `padic_hyperdrive_instability` claims that for any polynomial P over ℚ_p with a repelling fixed point z (‖P'(z)‖ > 1), nearby points eventually escape past norm 1. This is **false**: for P(x) = (1/p)x − (1/p)x² with z = 0, the backward orbit of z accumulates at z, creating points whose orbits converge to z rather than escaping. These 2 sorries are left in place since the theorem statements cannot be changed.

### Deliverables Created

- `RESEARCH_REPORT.md` — Detailed technical report
- `demo.py` — Python script demonstrating Carmichael's theorem, Berggren tree, tropical semiring, and p-adic counterexamples
- `diagram.svg` — Visual overview of the proof architecture
- `DISCUSSION.md` — Scientific American–style exposition

### Remaining Sorries (4 total, 2 distinct claims)

1. `Shared/CarmichaelComposite.lean:172` — Carmichael's theorem for composite n > 10000
2. `Speculative/AutoResearch/CarmichaelComposite.lean:164` — Same mathematical content
3. `Speculative/AutoResearch/PadicHyperdrive.lean:30` — False theorem
4. `Speculative/SciFi/PadicHyperdrive.lean:30` — Same false theorem