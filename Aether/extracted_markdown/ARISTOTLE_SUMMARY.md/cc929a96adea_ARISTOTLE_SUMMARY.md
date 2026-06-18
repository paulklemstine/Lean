# Summary of changes for run f9c73bb8-127b-4870-9590-4093fac7310b
## Summary

I deepened the Fibonacci **entry-point** (rank-of-apparition) theory that underlies Carmichael's primitive-divisor theorem, working in `Catalog/Speculative/AutoResearch/FibonacciEntryPointCharacterization.lean`.

### Closed the priority open `sorry`
- **`fibEntryPt_mul_coprime`** — the multiplicative **lcm law** `α(a·b) = lcm(α a, α b)` for coprime `a, b`, previously stated with `sorry` as a research target, is now proved. Proof: the index ideal of `a·b` equals `(α a) ∩ (α b) = (lcm)`, so divisibility-antisymmetry pins the entry point to the lcm.

### New sorry-free theorems (structural deepening)
Added a "Structural theory of entry points" section unifying the ad-hoc divisibility facts into the statement that `α : (ℕ,∣) → (ℕ,∣)` is a divisibility-monotone map whose image-ideals are the apparition sets:
- `fib_dvd_zero`, `fib_dvd_add` — the index set contains 0 and is closed under addition;
- `fibIndexSubmonoid` (+ `fibIndexSubmonoid_eq_multiples`) — the index set `{k | m ∣ F k}` is the **principal `AddSubmonoid (α m)`** of ℕ;
- `entryPt_exists_of_dvd`, `fibEntryPt_dvd_of_dvd` — divisibility-**monotonicity** of `α`;
- `fibEntryPt_one` — `α 1 = 1`;
- `exists_primitive_iff_exists_entryPt` — recasts Carmichael's theorem as the **surjectivity of `α` on primes** onto a given index.

All results were verified to compile and to depend only on the standard axioms (`propext`, `Classical.choice`, `Quot.sound`); the file is `sorry`-free. Each theorem carries `-- !-- Lab Notebook -- !--` blocks (Hypothesis / Result / Insight / Failure analysis) and brief proof-sketch docstrings.

### FUTURE_DIRECTIONS.md
Added `FUTURE_DIRECTIONS.md` with a synthesis, results table, and 5 falsifiable research directions (law of apparition `α(p) ∣ p − (5/p)`; prime-power reconstruction of `α`; Pisano-period connection `α(m) ∣ π(m)`; full Carmichael as surjectivity of `α`; functoriality to general strong-divisibility sequences), each with a "The key insight is…" sentence and a "Why now?" justification.

### Note on remaining work
One pre-existing `sorry` remains untouched in `Catalog/Shared/CarmichaelProof.lean` (`fib_carmichael_composite`, the infinite tail for composite `n > 10000`). This is the genuine analytic core of Carmichael's theorem (Zsygmondy-type primitive-divisor existence) and is beyond the elementary entry-point algebra developed here; it is recorded as research direction #4. The companion project files were left as-is; the broader catalog has unrelated pre-existing build breakages (e.g. a missing `Algebra/Jacobian/Defs.lean`) outside the scope of this work.