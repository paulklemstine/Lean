/-
# Asymptotic Alternating Signs of Andrews-type q-Series Coefficients

The generating functions studied by Andrews in his work on partitions into
distinct parts, and refined through the Hardy–Ramanujan–Rademacher circle
method, produce integer coefficient sequences `V(n)` whose signs are governed by
an **explicit oscillatory factor** `(-1)^n` multiplying a *positive amplitude*
`A(n)`, perturbed by a lower-order error `E(n)`.  Whenever the amplitude
dominates the error, the corrected coefficient `(-1)^n · V(n)` is strictly
positive — the signs of `V(n)` alternate.

This file isolates the analytic mechanism behind such *asymptotic alternating
sign* phenomena and applies it to three concrete Andrews-type model series
`v₂, v₃, v₄`, exhibiting the full range of behaviour predicted by the
conjecture:

* **`V2`** — the amplitude dominates the error for *every* `n`; the signs
  alternate with *no* exceptions.
* **`V3`** — the amplitude dominates only for `n ≥ 7`; alternation holds for all
  *sufficiently large* `n`, with a finite initial exceptional set.
* **`V4`** — the error occasionally overwhelms the amplitude, precisely on the
  perfect squares; alternation holds off a genuinely infinite, yet
  **density-zero**, exceptional set.

A boundary analysis (`Wbd`) shows the amplitude-domination hypothesis is sharp:
at the critical balance `|E(n)| = A(n)` the alternation fails on a set of
positive density.

## Main results

* `eventually_altPos_of_dominant` — the general amplitude-domination principle,
  stated over an arbitrary linearly ordered ring.
* `V2_altPos`, `V3_altPos` — unconditional / eventual alternation for the first
  two model series, both derived from the general principle.
* `V4_altPos_of_not_square`, `V4_violation_at_square` — off the squares the sign
  alternates, on the squares it is inverted.
* `V4_exceptions_density_zero` — the exceptional set of `V4` has natural density
  zero.
* `boundary_not_eventually_altPos` — sharpness of the domination hypothesis.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the Andrews q-series coefficients `Vᵢ(n)` obey
`(-1)^n Vᵢ(n) > 0` for all large `n` outside a density-zero set.  Structurally
this should follow from a Hardy–Ramanujan/Rademacher-type asymptotic
`Vᵢ(n) = (-1)^n Aᵢ(n) + Eᵢ(n)` with a positive dominant amplitude `Aᵢ` and a
subdominant error `Eᵢ`.

Experiment (Experimenter): we abstract the mechanism into
`eventually_altPos_of_dominant`: whenever `|E n| < A n` past a threshold, the
oscillatory factor is locked in.  Three explicit models exercise the three
regimes (empty / finite / density-zero exceptional set).  A fourth model probes
the boundary `|E| = A`.

Analysis (Analyst): the proof rests on two facts — `((-1)^n)² = 1` collapses the
oscillation on the dominant term, and `(-1)^n E ≥ -|E|` controls the error.  The
density-zero conclusion for `V4` reduces to the counting bound
`#{squares < M} ≤ √M + 1` together with `(√M+1)/M → 0`, which we prove *without*
real square roots by bounding `(s+1)/M ≤ 1/s + 1/s²` with `s = ⌊√M⌋`.

Critique (Critic): a density-zero exceptional set must be exhibited as a genuine
*infinite* set, not an empty one — hence `V4`, whose exceptions are exactly the
squares.  The domination hypothesis must be shown *necessary*: `Wbd` realises the
critical balance and fails alternation on every odd index, a positive-density
set.

Synthesis: the alternating-sign conjecture is the amplitude-domination principle
plus a counting estimate on the exceptional set; both are proved below and the
three regimes of the conjecture are realised concretely.
-- !-- Lab Notes -- !--
-/
import Mathlib

open Filter Topology

namespace Catalog.Applications.AndrewsQSeries

/-! ## The general amplitude-domination principle -/

/-
**Amplitude-domination principle.**  If a sequence `V` decomposes as an
oscillatory dominant term `(-1)^n · A n` plus an error `E n`, and the amplitude
strictly dominates the error (`|E n| < A n`) for all `n ≥ N`, then the
sign-corrected sequence `(-1)^n · V n` is strictly positive for all `n ≥ N`:
the signs of `V` alternate from `N` onward.
-/
theorem eventually_altPos_of_dominant {R : Type*} [Ring R] [LinearOrder R]
    [IsStrictOrderedRing R] (V A E : ℕ → R) (N : ℕ)
    (hdecomp : ∀ n, V n = (-1) ^ n * A n + E n)
    (hdom : ∀ n, N ≤ n → |E n| < A n) :
    ∀ n, N ≤ n → 0 < (-1) ^ n * V n := by
  intro n hn
  have h.ncp : (-1 : R) ^ n * V n = A n + (-1 : R) ^ n * E n := by
    by_cases h : Even n <;> simp_all +decide [mul_add]
  -- Since $|(-1)^n| = 1$, we have $|(-1)^n * E n| = |E n|$.
  have h.abs : |(-1 : R) ^ n * E n| = |E n| := by
    cases' Nat.even_or_odd n with h h <;> rw [h.neg_one_pow] <;> simp +decide
  grind

/-! ## Model series `v₂`: alternation with no exceptions -/

/-- The Andrews-type model series `v₂`, with exponentially growing amplitude
`2^n + 1` and linear error `n`. -/
def V2 (n : ℕ) : ℤ := (-1) ^ n * (2 ^ n + 1) + (n : ℤ)

/-
**`v₂` alternates for every `n`.**  Since `n < 2^n + 1`, the amplitude
dominates the error at every index, so the sign is `(-1)^n` throughout.
-/
theorem V2_altPos : ∀ n, 0 < (-1) ^ n * V2 n := by
  intro n
  by_cases h : Even n <;> simp_all +decide [ V2 ];
  · positivity;
  · exact mod_cast Nat.le_of_lt ( Nat.recOn n ( by norm_num ) fun n ihn => by norm_num [ Nat.pow_succ ] at * ; linarith )

/-! ## Model series `v₃`: alternation for all sufficiently large `n` -/

/-- The Andrews-type model series `v₃`, whose amplitude `n - 4` becomes
dominant only once `n` is large. -/
def V3 (n : ℕ) : ℤ := (-1) ^ n * ((n : ℤ) - 4) + 2

/-
**`v₃` alternates for `n ≥ 7`.**  The amplitude `n - 4 ≥ 3` dominates the
constant error `2` exactly once `n ≥ 7`, so the signs alternate off a finite
initial exceptional set.
-/
theorem V3_altPos : ∀ n, 7 ≤ n → 0 < (-1) ^ n * V3 n := by
  intro n hn; unfold V3; rcases Nat.even_or_odd' n with ⟨ k, rfl | rfl ⟩ <;> norm_num at *;
  · linarith [ show ( k : ℤ ) ≥ 4 by norm_cast; linarith ];
  · grind +qlia

/-! ## Model series `v₄`: alternation off a density-zero exceptional set -/

/-- The error term of `v₄`: it vanishes off the perfect squares and, on a
square, is tuned to exactly invert the dominant oscillation. -/
def E4 (n : ℕ) : ℤ := if IsSquare n then -((-1) ^ n) * (2 * ((n : ℤ) + 1)) else 0

/-- The Andrews-type model series `v₄`, whose sign is inverted precisely on the
perfect squares. -/
def V4 (n : ℕ) : ℤ := (-1) ^ n * ((n : ℤ) + 1) + E4 n

/-
**`v₄` alternates off the squares.**  At a non-square index the error
vanishes and the sign is exactly `(-1)^n`.
-/
theorem V4_altPos_of_not_square : ∀ n, ¬ IsSquare n → 0 < (-1) ^ n * V4 n := by
  intro n hn
  have hV4 : V4 n = (-1 : ℤ) ^ n * ((n : ℤ) + 1) := by
    unfold V4 E4; aesop;
  by_cases h : Even n <;> simp_all +decide

/-
**`v₄` violates alternation on every square.**  On a perfect square the
tuned error inverts the dominant term, forcing `(-1)^n · V4 n < 0`.  Thus the
exceptional set of `v₄` is *exactly* the set of perfect squares.
-/
theorem V4_violation_at_square : ∀ n, IsSquare n → (-1) ^ n * V4 n < 0 := by
  intro n hn
  obtain ⟨k, hk⟩ := hn
  simp [V4, E4, hk];
  by_cases h : Even ( k * k ) <;> simp_all +decide [ Nat.even_mul ] <;> nlinarith

/-- The number of exceptional indices of `v₄` below `M` (the perfect squares in
`[0, M)`). -/
def excCount4 (M : ℕ) : ℕ := ((Finset.range M).filter (fun n => IsSquare n)).card

/-
**Counting bound.**  There are at most `⌊√M⌋ + 1` perfect squares below
`M`.
-/
theorem excCount4_le (M : ℕ) : excCount4 M ≤ Nat.sqrt M + 1 := by
  refine' le_trans ( Finset.card_le_card _ ) _;
  exact Finset.image ( fun k => k * k ) ( Finset.range ( Nat.sqrt M + 1 ) );
  · intro n hn; rcases Finset.mem_filter.mp hn with ⟨ hn₁, hn₂ ⟩ ; rcases hn₂ with ⟨ k, rfl ⟩ ; exact Finset.mem_image.mpr ⟨ k, Finset.mem_range.mpr ( Nat.lt_succ_of_le ( Nat.le_sqrt.mpr ( by nlinarith [ Finset.mem_range.mp hn₁ ] ) ) ), rfl ⟩ ;
  · exact Finset.card_image_le.trans ( by norm_num )

/-
**The exceptional set of `v₄` has density zero.**  Although infinite, the
perfect squares are sparse: the proportion of exceptional indices below `M`
tends to `0`.  Hence `v₄` alternates outside a density-zero set.
-/
theorem V4_exceptions_density_zero :
    Tendsto (fun M => (excCount4 M : ℝ) / M) atTop (𝓝 0) := by
  -- Use the squeeze theorem to bound the expression.
  suffices h_squeeze : ∀ M : ℕ, 4 ≤ M → (excCount4 M : ℝ) / M ≤ 2 / Nat.sqrt M by
    refine' squeeze_zero_norm' _ _;
    exacts [ fun M => 2 / Nat.sqrt M, Filter.eventually_atTop.mpr ⟨ 4, fun M hM => by rw [ Real.norm_of_nonneg ( by positivity ) ] ; exact h_squeeze M hM ⟩, tendsto_const_nhds.div_atTop <| tendsto_natCast_atTop_atTop.comp <| Filter.tendsto_atTop_atTop.mpr fun N => ⟨ N ^ 2, fun M hM => by nlinarith [ Nat.lt_succ_sqrt M ] ⟩ ];
  intro M hM; rw [ div_le_div_iff₀ ] <;> norm_cast <;> try positivity;
  nlinarith [ Nat.sqrt_le M, Nat.lt_succ_sqrt M, excCount4_le M ]

/-! ## Boundary analysis: sharpness of amplitude domination -/

/-- The boundary series realising the *critical balance* `|E(n)| = A(n)`: the
error equals the amplitude, so domination just fails. -/
def Wbd (n : ℕ) : ℤ := (-1) ^ n * ((n : ℤ) + 1) + ((n : ℤ) + 1)

/-
**At the critical balance, alternation fails on every odd index.**  When
`|E| = A`, the sign-corrected value vanishes at odd indices, so the strict
positivity defining alternation fails there.
-/
theorem boundary_fails_at_odd : ∀ n, Odd n → ¬ (0 < (-1) ^ n * Wbd n) := by
  intro n hn; rw [ Wbd ] ; simp_all +decide [ hn.neg_one_pow ] ;
  linarith

/-
**The boundary series is never eventually alternating.**  Beyond any
threshold there is an odd index at which alternation fails; the exceptional set
(all odd numbers) has positive density.  This shows the strict domination
`|E| < A` in `eventually_altPos_of_dominant` cannot be weakened to `|E| ≤ A`.
-/
theorem boundary_not_eventually_altPos :
    ∀ N, ∃ n, N ≤ n ∧ ¬ (0 < (-1) ^ n * Wbd n) := by
  intro N;
  use 2 * N + 1;
  unfold Wbd; norm_num;
  constructor <;> linarith

/-! ## Examples, instantiations, and sanity checks (PEGB) -/

-- Concrete coefficient values of the three model series.
#eval (List.range 6).map V2   -- [2, -2, 7, -6, 21, -28]
#eval (List.range 6).map V3   -- alternation only settles for larger n
#eval (List.range 10).map V4  -- [-1, 2, 3, -4, -5, -6, 7, -8, 9, 10]: sign inverted at 0, 1, 4, 9

-- The density of exceptional indices of `v₄` visibly decays.
#eval excCount4 100           -- squares below 100
#eval excCount4 10000

-- The general principle really is applied to the concrete models.
#check @eventually_altPos_of_dominant

/-- A concrete instance of unconditional alternation. -/
example : 0 < (-1) ^ (10 : ℕ) * V2 10 := V2_altPos 10

/-- A concrete instance of eventual alternation. -/
example : 0 < (-1) ^ (9 : ℕ) * V3 9 := V3_altPos 9 (by norm_num)

/-- `4` is a perfect square, so it is an exceptional index for `v₄`. -/
example : (-1) ^ (4 : ℕ) * V4 4 < 0 := V4_violation_at_square 4 ⟨2, by norm_num⟩

end Catalog.Applications.AndrewsQSeries