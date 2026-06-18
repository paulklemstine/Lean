# Summary of changes for run b2bdff1f-2052-4115-a19f-ac2f907234c2
## Research cycle: Tropical p-adic Valuation Profile of Fibonacci Numbers

I investigated the follow-up direction around the catalog's Fibonacci / entry-point / tropical-valuation bridges (the `Tropical_p_adic_..._Fibonacci_Primitive_Divisors` and `CarmichaelComposite` material) and produced a self-contained, fully verified contribution.

### Deliverables
- **Lean proofs** — `Catalog/Speculative/AutoResearch/FibonacciValuationProfile.lean` (0 sorries; axioms ⊆ {propext, Classical.choice, Quot.sound, Lean.ofReduceBool, Lean.trustCompiler}). It studies the profile `n ↦ v_p(Fₙ)` and proves:
  - `padicValNat_fib_gcd_min` — the profile is a **tropical (min-plus) homomorphism for `gcd`**: `v_p(F_{gcd(m,n)}) = min (v_p Fₘ)(v_p Fₙ)`.
  - `padicValNat_fib_dvd_mono` — monotonicity along divisibility.
  - `padicValNat_fib_lcm_ge` — one-sided `lcm` bound `max(…) ≤ v_p(F_{lcm(m,n)})`.
  - `padicValNat_fib_lcm_max_not_general` — the dual `max`/`lcm` identity is **false** (disproved with witness p=2, m=3, n=4).
  - `fibRank` + `fibRank_dvd_iff`, `padicValNat_fib_support` — the **support** of the profile is exactly the multiples of the rank of apparition.
  - `fibRank_eq_of_primitive` — primitive prime divisors ⇔ rank-fixed points.
  A research insight discovered during cleanup is recorded: the support/rank results require no primality, so they are stated for arbitrary `p` (strictly more general).
- **Lab notes** — inline `-- !-- Lab Notes -- !--` block documenting hypotheses H1/H2, the falsification experiment, two generality insights, and a failure analysis.
- **FUTURE_DIRECTIONS.md** (same folder) — 5 bold, testable conjectures: (FD-1) affine LTE profile, (FD-2) closed-form `lcm` defect, (FD-3) tropical-convolution / valuation–skeleton duality, (FD-4) a primitive-part size bound reducing the open composite tail of Carmichael's theorem, (FD-5) strong-divisibility universality (Lucas / aⁿ−bⁿ).

### Verification & notes
Each theorem was proved and the complete file re-checked end-to-end against the Lean+Mathlib toolchain with zero warnings/errors and an explicit `#print axioms` check. The new file is self-contained (`import Mathlib`), so it is independent of the rest of the catalog.

I also found two pre-existing structural problems in the repository that are unrelated to this contribution and were left as-is to avoid risk: the `Shared/CarmichaelProof.lean` ↔ `Speculative/AutoResearch/CarmichaelComposite.lean` chain imports a file `Shared.CarmichaelHelper` that is missing from the project, and the lakefiles omit the `Catalog` source root mapping needed for `lake` to locate modules. The priority Carmichael composite target additionally still contains a genuine open `sorry` for the asymptotic tail (composite n > 10000); FD-4 lays out a concrete route to close it in a future cycle.