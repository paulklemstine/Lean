# Computational Evidence: aleph/beth hierarchy and the placement of CH

## 1. The finite beth tower (small-case calculation)

The beth hierarchy is generated from the countable infinite by iterated
exponentiation:

| stage `n` | `ℶ_n`                         | symbolic size          |
|-----------|-------------------------------|------------------------|
| 0         | `ℵ₀`                          | countable infinite     |
| 1         | `2^ℵ₀`                        | the continuum `𝔠`      |
| 2         | `2^(2^ℵ₀)`                    | cardinality of `𝒫(ℝ)`  |
| 3         | `2^(2^(2^ℵ₀))`                | `𝒫(𝒫(ℝ))`              |

Key finite fact confirmed symbolically: `ℶ₁ = 2^ℵ₀ = 𝔠`.  This is the anchor
that recasts CH as the coincidence `ℵ₁ = ℶ₁` of the two towers at stage 1.

## 2. Successor-step structure of `ℵ₁`

The cardinals strictly below `ℵ₁` are exactly `0, 1, 2, …, ℵ₀` — the finite
cardinals together with `ℵ₀`.  There is no cardinal `c` with `ℵ₀ < c < ℵ₁`.
Sampling the candidate "gap" cardinals one might name:

- `ℵ₀` itself: not strictly above `ℵ₀`.  Excluded.
- `2^ℵ₀ = 𝔠`: satisfies `ℵ₀ < 𝔠`, but `𝔠 < ℵ₁` is false since `ℵ₁ ≤ 𝔠`.  Excluded.
- any `#α` for a countable `α`: equals some `ℵ₀` or a finite cardinal, hence
  `< ℵ₁` but not `> ℵ₀`.  Excluded.

Every candidate for an "intermediate" cardinal fails the test, matching the
theorem `no_cardinal_between_aleph0_alephOne`.

## 3. GCH → hierarchy coincidence (stage-by-stage check)

Under the arithmetic form of GCH (`2^c = c⁺` for infinite `c`), tabulating the
two hierarchies:

| stage `o` | `ℶ_o` under GCH | `ℵ_o` |
|-----------|-----------------|-------|
| 0         | `ℵ₀`            | `ℵ₀`  |
| 1         | `(ℵ₀)⁺ = ℵ₁`    | `ℵ₁`  |
| 2         | `(ℵ₁)⁺ = ℵ₂`    | `ℵ₂`  |
| ω (limit) | `sup ℶ_n = sup ℵ_n = ℵ_ω` | `ℵ_ω` |

At every sampled stage the two agree, consistent with the transfinite theorem
`GCH_beth_eq_aleph`.  In particular stage 1 yields `ℶ₁ = ℵ₁`, i.e. `𝔠 = ℵ₁`,
which is CH.

## 4. Counterexample hunt

- **Claim tested:** "there is a cardinal strictly between `ℵ₀` and `ℵ₁`."
  No witness exists; the successor structure forbids it.  (Confirmed as a
  theorem.)
- **Claim tested:** "the reals-dichotomy `∀ S ⊆ ℝ, S countable ∨ #S = 𝔠` is
  weaker than CH."  Attempting to separate them fails: producing a set of reals
  of size `ℵ₁` forces the two statements to be equivalent.  (Confirmed as the
  equivalence `CH_iff_subsets_of_reals`.)

No counterexamples were found; all universal claims survived and are recorded
as theorems.

## 5. OEIS

No integer sequence arises directly; the objects here are transfinite
cardinals rather than a numerical sequence, so an OEIS lookup is not applicable.
