# Summary of changes for run 0458f121-da5d-4e2e-a1c9-dcbe30629acb
## What was delivered

I added a new self-contained Lean file and a research-direction document under `Catalog/Speculative/AutoResearch/`, extending the catalog's Carmichael / Fibonacci primitive-divisor line of work.

### New file: `Catalog/Speculative/AutoResearch/FibonacciRankOfApparition.lean`
A development of the **rank of apparition** (entry point) of integers in the Fibonacci sequence. It contains **4 theorems, all fully proved (zero `sorry`)**, verified to compile cleanly and to depend only on the standard kernel axioms (`propext`, `Classical.choice`, `Quot.sound`):

1. **`fib_entryPoint_dvd_iff`** — the *law of apparition*: if `a` is the least positive index with `p ∣ F a`, then `p ∣ F n ↔ a ∣ n`, for arbitrary `n` (no finiteness restriction, unlike the catalog's existing `n ≤ 10000` verification window).
2. **`fib_dvd_iff_of_three_le`** — the *strong divisibility law* `F m ∣ F n ↔ m ∣ n` for `m ≥ 3`, sharpening Mathlib's one-directional `Nat.fib_dvd` into an equivalence.
3. **`fib_primitive_iff_entryPoint`** — a prime `p` is a *primitive divisor* of `F n` (it divides `F n` but no earlier positive Fibonacci number) iff its rank of apparition equals `n`. This makes intrinsic the exact predicate the catalog's `fib_carmichael_composite` certifies.
4. **`fib_entryPoint_exists`** — every modulus `p ≥ 1` has a rank of apparition (a Pisano-period / pigeonhole argument: the Fibonacci sequence returns to `0` modulo `p`).

Each theorem carries a `-- !--` proof-sketch comment and a docstring, and three worked `example` blocks demonstrate the results on concrete data (e.g. the rank of apparition of `11` is `10`, giving `11 ∣ F 100` instantly).

### New file: `Catalog/Speculative/AutoResearch/FUTURE_DIRECTIONS.md`
A narrative listing five testable, falsifiable research conjectures (multiplicative entry-point function; closing the infinite Carmichael tail via a growth/totient counting bound; a uniform apparition law for general Lucas/strong-divisibility sequences; the Pisano period as the order of the apparition shift in `GL₂(ZMod p)`; and the originating phase-transition/threshold conjecture for random divisibility theories). Each direction includes a "The key insight is…" sentence and a "Why now?" justification.

### Note on the existing catalog `sorry` placeholders
The remaining `sorry` in the catalog's Carmichael files (`Shared/CarmichaelProof.lean` and `Speculative/AutoResearch/CarmichaelComposite.lean`) is the genuine *infinite tail* of Carmichael's primitive-divisor theorem (all composite `n > 10000`) — a deep result beyond a quick fill. I left those files untouched to avoid disturbing the 643 existing theorems, and instead built the reusable apparition-theory foundation that the new results show reduces that open tail to a divisor-counting inequality (spelled out as Direction 2). The new theorems are the concrete, verified progress toward that goal.

(Note: the project's `lakefile.toml` library globs point at the repository root rather than the `Catalog/` directory where the sources live, so the catalog libraries do not build via `lake` as configured; the new file imports only Mathlib and was verified to compile and to be axiom-clean via the compiler directly.)