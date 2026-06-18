# Summary of changes for run 9518d2c2-e3e2-4169-b7b9-7497d92e98b6
## What I did

I closed the highest-priority open `sorry` in the catalog and substantially extended the surrounding theory, all `sorry`-free and verified to depend only on the standard axioms `propext`, `Classical.choice`, `Quot.sound`.

### Filled priority sorry
- `fibEntryPt_mul_coprime` (the **lcm law** for Fibonacci entry points, `α(a·b) = lcm(α a, α b)` for coprime `a,b`) in `Catalog/Speculative/AutoResearch/FibonacciEntryPointCharacterization.lean` — previously an explicit `sorry` research target — is now proved. Proof: the principal-ideal characterization plus `dvd`-antisymmetry, after exhibiting an apparition index for `a·b` via the lcm of the two factor entry points.

### New theorems added to the same file (extending the catalog's entry-point work)
- `fib_mul_dvd_iff_of_coprime` — coprime divisibility splitting `a·b ∣ F k ↔ a ∣ F k ∧ b ∣ F k`.
- `fibEntryPt_dvd_of_dvd` — the entry point is divisibility-monotone: `a ∣ b ⟹ α a ∣ α b`.
- `fibEntryPt_two = 3`, `fibEntryPt_three = 4` — base values.
- `fibEntryPt_six = 12` — a structural (non-computational) derivation of the Carmichael boundary index 12, recovering the obstruction recorded by `fib_twelve_no_primitive` from the lcm law and the base values.
- `fib_apparition_exists` — **totality of the rank of apparition**: every modulus `m ≥ 1` has a positive index `k` with `m ∣ F k` (proved via a pigeonhole/pure-periodicity argument on the Fibonacci state map mod `m`).
- `fibEntryPt_mul_coprime_of_pos` — an **unconditional** form of the lcm law (apparition hypotheses discharged by the totality theorem).

These specialize and concretize the abstract strong-divisibility-sequence machinery already present in `EntryPointMultiplicativity.lean`, adding explicit numbers and the explicit Carmichael-boundary explanation that were not there.

### Lab notebooks
Each new result carries `-- !-- Lab Notebook -- !--` blocks (Hypothesis / Result / Insight / Failure analysis), and the file's header index was updated to mark the lcm law as proved.

### FUTURE_DIRECTIONS.md
Added `Catalog/Speculative/AutoResearch/FUTURE_DIRECTIONS.md` with a synthesis, results table, and five falsifiable directions (each with a "key insight" and "why now"): (1) totality/Pisano existence, (2) a prime-power closed form for `α` via Wall–Sun–Sun, (3) recasting the remaining Carmichael composite `sorry` as `α`-surjectivity, (4) classifying all defective indices from the lcm law, (5) transporting the entry-point lattice morphism to Lucas/elliptic divisibility sequences.

### Remaining open item (documented, not closed)
The second catalog `sorry`, the infinite tail of `fib_carmichael_composite` in `Shared/CarmichaelProof.lean` (composite `n > 10000`), is the full Carmichael primitive-divisor theorem for Fibonacci numbers — not available in Mathlib and a major standalone formalization effort. It is left as-is (pre-existing) and laid out as research Direction 3 in FUTURE_DIRECTIONS.md.

Verification: the modified file elaborates with zero `sorry` warnings, builds as a module, and an axiom audit of all new results shows only the standard axioms.
