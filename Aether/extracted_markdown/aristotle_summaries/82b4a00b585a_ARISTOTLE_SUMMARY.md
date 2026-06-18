# Summary of changes for run d6ca30d1-126e-40a4-b6d1-d2618c63156a
## What was done

I worked the entry-point (rank of apparition) thread of the catalog — the self-contained, fully-building part of the Fibonacci/Carmichael area — closing open `sorry`s and extending it with new theory.

### 1. Closed an open conjecture (removed `sorry`)
In `Catalog/Speculative/AutoResearch/FibonacciEntryPointCharacterization.lean`, the previously-open conjecture `fibEntryPt_mul_coprime` — the binary lcm law `α(a·b) = lcm(α a, α b)` for coprime `a,b` — is now **proved**. (Its proof reduces, via the principal-ideal characterization `fib_dvd_iff_entryPt_dvd`, to `Nat.lcm_dvd_iff` plus antisymmetry.) Header/lab-notebook comments were updated accordingly.

### 2. New file with 10 proven theorems
`Catalog/Speculative/AutoResearch/FibEntryPointMultiplicative.lean` develops the rank of apparition `α` as an arithmetic function (each with a `-- !--` proof sketch and lab-notebook blocks):
- `fibEntryPt_one` : `α(1)=1`;
- `fib_dvd_add`, `fib_dvd_sub` : the index set `{k | m ∣ F k}` is an additive sub-semigroup of `(ℕ,+)`;
- base table `fibEntryPt_two/three/five/seven` : `α(2)=3, α(3)=4, α(5)=5, α(7)=8`;
- `fibEntryPt_six` : `α(6)=12` — the cross-domain gem, the *arithmetic* reason `F(12)=144` has no primitive prime divisor (the lone composite exception of Carmichael's theorem);
- `prod_has_entryPt` and `fibEntryPt_prod` : the **full multiplicativity law** `α(∏ᵢ mᵢ) = lcm ᵢ α(mᵢ)` for any finite pairwise-coprime family, generalizing the binary case to a `Finset`.

All theorems compile and depend only on the standard axioms `propext, Classical.choice, Quot.sound` (no `sorry`, no added axioms).

### 3. `FUTURE_DIRECTIONS.md`
Five falsifiable research directions (each with a "The key insight is…" sentence and a "Why now?" justification): prime-power lifting / full reconstruction of `α`; closing the deep Carmichael large-`n` gap; the rank-vs-Pisano-period ratio; Lucas-sequence universality of the whole theory; and the inverse/density problem for ranks of apparition.

### Build note and remaining gap
The package's `lakefile.toml` was missing `srcDir = "Catalog"` (its sources live under `Catalog/`, so no module resolved); I added it so modules build. The two files above build cleanly. One deep `sorry` remains untouched in `Catalog/Shared/CarmichaelProof.lean` (composite `n > 10000 ⟹ F(n)` has a primitive prime divisor): it is the genuine hard case of Carmichael's primitive-divisor theorem, and that file additionally does not currently build because it imports a missing `Shared/CarmichaelHelper.lean`. Both issues are documented as the highest-priority next-cycle direction in `FUTURE_DIRECTIONS.md`.