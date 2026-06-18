# Future Directions — Riemann Zeros, Zero-Free Regions, and Positive Proportion

## Synthesis

This cycle built the *unconditional structural skeleton* on which the
positive-proportion results of Selberg and Conrey rest, entirely inside Lean 4 /
Mathlib, with zero `sorry` on every main theorem.

Two files were produced:

- **`CriticalStrip.lean`** turns two heavyweight analytic facts from Mathlib —
  the functional equation `completedRiemannZeta_one_sub` and the prime-number
  non-vanishing `riemannZeta_ne_zero_of_one_le_re` — into clean geometric
  statements: the zeros of the completed zeta are invariant under the reflection
  `s ↦ 1 - s` (`completedZeta_zero_reflect`); the critical line `Re s = 1/2` is
  *exactly* the axis of that reflection (`reflect_eq_re_iff`, `reflect_fixed_iff`);
  and, the flagship, **every nontrivial zero lies in the open critical strip
  `0 < Re s < 1`** (`nontrivialZero_mem_open_critical_strip`). The left edge of the
  strip is obtained, perhaps surprisingly, *for free* by reflecting the
  `Re ≥ 1` non-vanishing through the functional equation, with the archimedean
  factor `Γℝ` (`Gammaℝ_eq_zero_iff`) accounting precisely for the trivial zeros.

- **`ZeroPairing.lean`** isolates the *combinatorial engine* of "positive
  proportion": a fixed-point-free involution forces even cardinality
  (`even_card_of_fixedPointFree_involution`); off-line zeros therefore come in
  mirror pairs (`offLine_card_even`); an odd symmetric collection must meet the
  critical line (`exists_onLine_of_odd_card`); and RH is reframed as
  "critical-line proportion `= 1`" (`criticalProportion_eq_one_of_RH`), the
  endpoint of the Selberg (`> 0`) → Conrey (`≥ 2/5`) → RH (`= 1`) ladder.

## Results Summary

| Theorem | Statement | Status |
|---|---|---|
| `completedZeta_zero_reflect` | `Λ(1-s)=0 ↔ Λ(s)=0` | proved |
| `reflect_eq_re_iff` / `reflect_fixed_iff` | critical line = symmetry axis | proved |
| `zeta_zero_iff_completed_zero_of_pos_re` | `ζ`/`Λ` zeros agree on `Re>0` | proved |
| `nontrivialZero_mem_open_critical_strip` | nontrivial zeros have `0<Re<1` | proved |
| `even_card_of_fixedPointFree_involution` | involution parity | proved |
| `offLine_card_even` | off-line zeros pair up | proved |
| `exists_onLine_of_odd_card` | odd ⇒ a zero on the line | proved |
| `criticalProportion_eq_one_of_RH` | RH ⇔ proportion `=1` | proved |

All depend only on `propext`, `Classical.choice`, `Quot.sound`.

---

## Direction 1 — A quantitative zero-free region (de la Vallée Poussin)

Upgrade `nontrivialZero_mem_open_critical_strip` from the *open* strip to a
genuine *quantitative* region: there is a constant `c > 0` such that `ζ(s) ≠ 0`
whenever `Re s ≥ 1 - c / log(|Im s| + 2)`. Formalize the classical
`3 + 4cos θ + cos 2θ ≥ 0` positivity trick already lurking (privately) inside
Mathlib's `Nonvanishing.lean` (`re_log_comb_nonneg`).

*The key insight is* that the same nonnegative trigonometric combination that
proves non-vanishing **on** the line `Re = 1` can be made *effective* by tracking
the implied constant through the `3-4-1` inequality, yielding a curve, not just a
boundary. **Why now?** Mathlib already contains the positivity lemma and the
`Re = 1` non-vanishing as private results; exposing and quantifying them is a
self-contained engineering+analysis task, not a new theorem from scratch — the
hardest conceptual ingredient is already in the library.

Falsifiable: if no such `c` can be extracted from the existing positivity lemma,
the conjecture (that Mathlib's machinery suffices) is refuted.

## Direction 2 — Hardy's theorem: infinitely many zeros on the line

Prove `{s : Λ s = 0 ∧ s.re = 1/2}` is infinite. This is the first *qualitative*
positive result and a strict prerequisite for any *proportion* statement.

*The key insight is* that `Λ(1/2 + it)` is **real-valued** for real `t` (immediate
from `completedRiemannZeta_one_sub` together with a conjugation symmetry
`Λ(conj s) = conj(Λ s)`), so sign changes of this real function force zeros; Hardy
counts sign changes via the non-vanishing of moments `∫ Λ(1/2+it) t^{2k} dt`.
**Why now?** The reflection symmetry `Λ(1-s)=Λ(s)` is *already proved* in
`CriticalStrip.lean`; the only missing algebraic input is the conjugation symmetry,
a short Schwarz-reflection argument on the Dirichlet series, after which Hardy's
moment argument becomes a real-analysis exercise.

Falsifiable: produce the conjugation lemma and show the real-restriction
`g(t) := Λ(1/2 + it)` is **not** eventually of one sign; if `g` were eventually
single-signed, Hardy's conclusion (and this direction) would fail.

## Direction 3 — The pairing framework predicts the exact parity of zero counts

Our `offLine_card_even` says off-line zeros are even in number. Conjecture the
sharper *global* statement: for the genuine zero-counting function `N(T)` (zeros
with `0 < Im ρ < T`) of a reflection-and-conjugation-symmetric zero set, the
on-line count `N₀(T)` satisfies `N₀(T) ≡ N(T) (mod 2)` up to a boundary term, so
that the discrete `exists_onLine_of_odd_card` becomes an asymptotic forcing
mechanism.

*The key insight is* that conjugation symmetry `ρ ↦ conj ρ` and reflection
`ρ ↦ 1-ρ` generate a Klein four-group acting on off-line zeros, so off-line zeros
actually come in **quadruples**, sharpening "even" to "divisible by 4" away from
the real axis. **Why now?** The involution-parity lemma
`even_card_of_fixedPointFree_involution` is fully general and already proved;
extending it to a `ℤ/2 × ℤ/2` action is a direct group-action generalization
(replace "even" by "`|group| ∣ card` on free orbits").

Falsifiable: exhibit a finite symmetric multiset of off-line points whose
cardinality is `≡ 2 (mod 4)` while avoiding the real axis — this would refute the
quadruple-orbit refinement.

## Direction 4 — Selberg's positive proportion as a moment inequality

Selberg proved `liminf_{T} N₀(T)/N(T) > 0`. Formalize the *reduction* of this to a
single second-moment inequality for a mollified zeta integral:
`∫_0^T |M(1/2+it) ζ(1/2+it)|² dt` is comparable to `∫_0^T |M ζ'|²`, where `M` is a
Dirichlet polynomial mollifier.

*The key insight is* that the proportion bound is **not** a statement about
individual zeros at all but about the *ratio of two integrals* (a Cauchy–Schwarz /
variance argument), so the entire analytic difficulty collapses onto bounding two
explicit mean-value integrals of Dirichlet polynomials. **Why now?** Mathlib's
`LSeries` and Mellin-transform infrastructure already give the Dirichlet-series
side; the missing piece is the **mean value theorem for Dirichlet polynomials**
`∫_0^T |Σ aₙ n^{-it}|² dt = (T + O(n)) Σ|aₙ|²`, a clean, self-contained analytic
lemma worth formalizing in its own right.

Falsifiable: state the mean-value lemma and the Cauchy–Schwarz reduction; if the
reduction does *not* yield a positive constant from a positive-definite mollifier,
the claimed pathway to Selberg is wrong.

## Direction 5 — Random-matrix moments as the conjectural value of the proportion

Conrey reached `2/5` by optimizing the mollifier; the conjectured *truth* is
proportion `= 1`. The Montgomery–Dyson philosophy predicts the optimization
constant from the **GUE pair-correlation** `1 - (sin πx / πx)²`. Conjecture: the
best achievable proportion from a length-`θ` mollifier is governed by the same
sine-kernel determinant that defines GUE eigenvalue statistics, and formalize the
*moment* `∫ (sin πx/πx)² dx` computation that appears on both sides.

*The key insight is* that the **moment problem** for the sine kernel is exactly
solvable — its low moments are rational multiples of `π`-powers, the same numbers
(`ζ(2k)` via `riemannZeta_two_mul_nat`) that Mathlib already computes — so the
"random matrix" input is, at the level of moments, *elementary special-function
arithmetic* rather than probability. **Why now?** Mathlib has closed forms for
`ζ(2k)` and the Bernoulli numbers; pinning the first few sine-kernel moments to
these constants is a concrete, checkable computation that builds the first formal
bridge between zeta values and GUE statistics.

Falsifiable: compute the first two sine-kernel moments and the mollifier-optimum
constant; if they fail to match the GUE prediction term-by-term, the
random-matrix correspondence (as a moment identity) is falsified at the very
first moment.
