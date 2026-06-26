# Theorem Trace (internal anti-hallucination ledger)

Every claim in ARTICLE.md and RESEARCH_PAPER.md traces to one of the
following Lean declarations from the Phase A output. No other theorems are
asserted as proved.

## File: Catalog/Bridges/TotientShiftWitnesses.lean (namespace `TotientShift`)

| Lean name | Mathematical statement | Article | Paper |
|-----------|------------------------|---------|-------|
| `ghp_15`  | `φ(15) = φ(16)` (both `= 8`; `15=3·5`, `16=2⁴`) | yes | yes |
| `ghp_104` | `φ(104) = φ(105)` (both `= 48`; `104=2³·13`, `105=3·5·7`) | yes | yes |
| `ghp_164` | `φ(164) = φ(165)` (both `= 80`; `164=2²·41`, `165=3·5·11`) | yes | yes |
| `ghp_194` | `φ(194) = φ(195)` (both `= 96`; `194=2·97`, `195=3·5·13`) | yes | yes |
| `ghp_255` | `φ(255) = φ(256)` (both `= 128`; `255=3·5·17`, `256=2⁸`) | yes | yes |
| `ghp_495` | `φ(495) = φ(496)` (both `= 240`; `495=3²·5·11`, `496=2⁴·31`) | yes | yes |
| `ghp_584` | `φ(584) = φ(585)` (both `= 288`; `584=2³·73`, `585=3²·5·13`) | yes | yes |
| `ghp_975` | `φ(975) = φ(976)` (both `= 480`; `975=3·5²·13`, `976=2⁴·61`) | yes | yes |

Proof method (all eight): factor `n` and `n+1` into coprime prime powers,
apply `Nat.totient_mul` (coprime multiplicativity), `Nat.totient_prime`,
`Nat.totient_prime_pow`, then close the arithmetic with `norm_num`.

## File: Catalog/Bridges/TotientUnitShift.lean (namespace `TotientShift`)

| Lean name | Mathematical statement | Article | Paper |
|-----------|------------------------|---------|-------|
| `S1phi` (def) | `S₁^φ(x) = #{ n ≤ x : φ(n) = φ(n+1) }` (counting function) | yes | yes |
| `S1phi` monotone | `S₁^φ` is monotone nondecreasing | yes | yes |
| `S1phi_lt_self` | `S₁^φ(x) < x` for `x ≥ 2` (non-saturation; `n=2` is a certified non-collision since `φ(2)=1 ≠ 2=φ(3)`) | yes | yes |
| `S1phi_ge_card` | counting transfer: any finite set of certified witnesses `⊆ {n ≤ x}` gives `#witnesses ≤ S₁^φ(x)` | yes | yes |
| `6 ≤ S1phi 194` | explicit lower bound from witnesses `{1,3,15,104,164,194}` | yes | yes |
| `10 ≤ S1phi 975` | explicit lower bound from witnesses `{1,3,15,104,164,194,255,495,584,975}` | yes | yes |
| `totient_shift_value_even` | for `n ≥ 3`, the common collision value `φ(n)=φ(n+1)` is even (via `Nat.totient_even`) | yes | yes |

## Context (stated as background, NOT claimed as Lean-proved)

- Graham–Holt–Pomerance upper bound `S₁^φ(x) ≪ x·exp{-(1/2 - o(1))√(log x · log₂ x)}`.
- The tightness lower bound `S₁^φ(x) ≥ C·x·exp{-(1/2 + o(1))√(log x · log₂ x)}`.
- Infinitude `S₁^φ(x) → ∞` is OPEN and explicitly NOT claimed.

These are framed as the analytic backdrop; the Lean artifact formalizes the
constructive/counting *skeleton* (witnesses + transfer theorem + structural
parity), not the asymptotics.
