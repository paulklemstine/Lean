# Summary of changes for run f01452d2-6330-4c6a-a4a8-c4f99c079377
Delivered a new, self-contained, fully-proven Lean development of the **Fibonacci entry point (rank of apparition)** theory — the conceptual backbone of Carmichael's primitive-divisor theorem.

**New file:** `Catalog/Speculative/AutoResearch/FibonacciEntryPoint.lean` (imports only Mathlib, so it builds independently of the catalog's broken `Shared.CarmichaelHelper` import). It verifies with `sorry = 0` and depends only on the standard axioms `propext`, `Classical.choice`, `Quot.sound`.

Theorems proved (all complete):
- `dvd_fib_gcd` — strong-divisibility helper (`p ∣ F(m), F(n) → p ∣ F(gcd m n)`).
- `fibEntryPt_spec` — the entry point `z(p)` is positive and `p ∣ F(z(p))` when it exists.
- `fibEntryPt_dvd` — **`z(p) ∣ n` whenever `p ∣ F(n)`** (no primality required).
- `fib_dvd_of_fibEntryPt_dvd` — the converse via `Nat.fib_dvd`.
- `dvd_fib_iff_fibEntryPt_dvd` — the clean equivalence `p ∣ F(n) ↔ z(p) ∣ n`.
- `primitive_iff_fibEntryPt_eq` — **`p` is a primitive divisor of `F(n)` iff `z(p) = n`**.
- `fib12_no_primitive` — the sharp counterexample (`F(12)=144` has no primitive prime divisor), explaining why Carmichael needs `n ≥ 13`.

Each proof carries a brief `-- !--` proof sketch, and the file opens with a `-- !-- Lab Notebook -- !--` block (Hypothesis / Result / Insight / Failure analysis).

**Catalog synthesis:** This generalizes and replaces the ad-hoc entry-point lemmas scattered across `CarmichaelComposite.lean` and `FibPrimitive.lean` (which currently do not build) with one reusable, axiom-clean calculus, recasting "primitive divisor" as the order-theoretic statement `z(p) = n`.

**Note on the existing `sorry`:** the catalog's only genuine code-level `sorry` is in `Shared/CarmichaelProof.lean`'s `fib_carmichael_composite` (existence of a primitive divisor for every composite `n > 50000`). This is the full research-grade Carmichael theorem; it requires a Fibonacci Lifting-the-Exponent lemma plus a growth estimate and is not cleanly closable in one pass. I left the user's files untouched and instead supplied the verified groundwork plus a precise roadmap to close it.

**`Catalog/Speculative/AutoResearch/FUTURE_DIRECTIONS.md`** lays out 5 falsifiable directions (Fibonacci LTE keystone; Möbius primitive-part growth to close the open case; entry-point density/Chebotarev law; generalization to all Lucas sequences; a formal Zsygmondy theorem for aⁿ−bⁿ), each with a "key insight" and "Why now?" justification.