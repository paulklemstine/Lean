/-
# Disjoint blocks: a matching lower bound and the removal of the `J²` loss

This file settles conjecture **C3** of `FUTURE_DIRECTIONS.md` for the Asai second-moment
framework of `Novelty.AsaiLargeSieve` / `Novelty.AsaiSecondMoment`.

The flagship theorem `AsaiSecondMoment.asai_second_moment_k_aspect` bounds the second moment
of a family of central values admitting a `J`-block approximate functional equation by
`J² · C · B`, the two factors of `J` coming from a Cauchy–Schwarz inequality applied to the
sum over the blocks.  C3 predicted that if the blocks are **spectrally separated** — their
coefficient vectors have pairwise disjoint supports, which is exactly the situation of a
dyadic decomposition of the Dirichlet series into ranges `n ≍ 2^j` — then

* the `J²` degrades to a single `J`, and
* a *matching lower bound* of the same shape holds.

Both are proved here, and the mechanism is the same in the two directions: for disjointly
supported blocks the whole approximate functional equation collapses to **one** Dirichlet
polynomial (`AsaiSecondMoment.afe_eq_linForm_aggregate`, which needs no disjointness at all),
and disjointness then converts the `ℓ²`-mass of the aggregated coefficient vector into the sum
of the blockwise masses (`sum_normSq_aggregate_of_disjoint`).

Main results:

* `AsaiSecondMoment.afe_eq_linForm_aggregate` — an AFE is a single Dirichlet polynomial with
  coefficients `c n = ∑_{j<J} w j · A j n`.
* `AsaiSecondMoment.sum_normSq_aggregate_of_disjoint` — for blocks separated by a block-index
  function `b`, `∑_{n<N} |c n|² = ∑_{j<J} |w j|² ∑_{n<N} |A j n|²`.
* `AsaiSecondMoment.secondMoment_disjoint_le` — the upper bound `C · ∑_j |w j|²‖A j‖²`, hence
  `secondMoment_disjoint_uniform`: `∑_f |L f|² ≤ J · C · B`, one factor of `J` better than the
  flagship bound.
* `AsaiSecondMoment.secondMoment_disjoint_lower` — the matching lower bound
  `(D − eN) · ∑_j |w j|²‖A j‖² ≤ ∑_f |L f|²`.
* `AsaiSecondMoment.secondMoment_disjoint_order` — combining the two: in the
  Kloosterman-controlled regime `2eN ≤ D` the second moment of a spectrally separated AFE has
  the exact order `D · ∑_j |w j|²‖A j‖²`, up to the factor `3`.
* `AsaiSecondMoment.dyadic_support_disjoint` and `AsaiSecondMoment.secondMoment_dyadic` — the
  case that actually occurs in the paper: for a dyadic AFE (the `j`-th block supported in
  `[2^j, 2^{j+1})`, block index `Nat.log 2`) the bound is `C · W · B`, where `W` bounds the
  total archimedean weight mass `∑_j |w j|²`.  There is then no `J`-dependence at all.

Lab notes (Experimenter).  Sanity check of the gain: with `J = 2`, `w = (1,1)`,
`A 0 = (1,0)`, `A 1 = (0,1)` on `N = 2` and an orthonormal system with `D = 1`, `e = 0`, the
flagship bound gives `J²·C·B = 4·1·1 = 4`, the disjoint bound gives `J·C·B = 2`, and the true
value is `∑_f |L f|² = 2`, which is also what `secondMoment_disjoint_le` predicts exactly
(`C · ∑_j |w j|²‖A j‖² = 1 · 2 = 2`).  So the improvement is not merely formal: the disjoint
bound is attained while the flagship bound is off by the full factor `J`.  This computation is
not left informal — it is the theorem `secondMoment_disjoint_attained` below.

Critique (Critic).  The disjointness hypothesis is recorded by an explicit block-index
function `b : ℕ → ℕ` with `A j n = 0` unless `b n = j`; this is strictly weaker than requiring
the supports to be intervals, and it allows blocks to be empty.  No positivity of `D` or `e`
is assumed anywhere: the lower bound is vacuous (but true) when `D ≤ eN`, which is the honest
statement.  The upper bound `secondMoment_disjoint_le` does not use quasi-orthogonality at
all — any admissible large sieve constant works.
-/
import Mathlib
import Novelty.AsaiLargeSieve
import Novelty.AsaiSecondMoment

open Finset Complex AsaiLargeSieve

namespace AsaiSecondMoment

variable {ι : Type*}

/-- **An approximate functional equation is a single Dirichlet polynomial.**  Summing the
blocks against their archimedean weights produces the aggregated coefficient vector
`c n = ∑_{j<J} w j · A j n`.  No hypothesis on the blocks is needed. -/
theorem afe_eq_linForm_aggregate (S : Finset ι) (lam : ι → ℕ → ℂ) (N J : ℕ) (w : ℕ → ℂ)
    (A : ℕ → ℕ → ℂ) (L : ι → ℂ) (hL : AFE S lam N J w A L) {f : ι} (hf : f ∈ S) :
    L f = linForm lam N (fun n => ∑ j ∈ Finset.range J, w j * A j n) f := by
  rw [hL f hf]
  simp only [linForm, Finset.mul_sum, Finset.sum_mul]
  rw [Finset.sum_comm]
  exact Finset.sum_congr rfl fun j _ => Finset.sum_congr rfl fun n _ => by ring

/-- **Spectral separation collapses the coefficient mass.**  If a block-index function `b`
witnesses that the `j`-th block is supported in `{n : b n = j}`, then the `ℓ²`-mass of the
aggregated coefficient vector is exactly the weighted sum of the blockwise masses. -/
theorem sum_normSq_aggregate_of_disjoint (N J : ℕ) (w : ℕ → ℂ) (A : ℕ → ℕ → ℂ) (b : ℕ → ℕ)
    (hsupp : ∀ j ∈ Finset.range J, ∀ n ∈ Finset.range N, b n ≠ j → A j n = 0) :
    ∑ n ∈ Finset.range N, ‖∑ j ∈ Finset.range J, w j * A j n‖ ^ 2
      = ∑ j ∈ Finset.range J, ‖w j‖ ^ 2 * ∑ n ∈ Finset.range N, ‖A j n‖ ^ 2 := by
  have hpt : ∀ n ∈ Finset.range N, ‖∑ j ∈ Finset.range J, w j * A j n‖ ^ 2
      = ∑ j ∈ Finset.range J, ‖w j‖ ^ 2 * ‖A j n‖ ^ 2 := by
    intro n hn
    by_cases hb : b n ∈ Finset.range J
    · have hcoll : ∑ j ∈ Finset.range J, w j * A j n = w (b n) * A (b n) n := by
        refine Finset.sum_eq_single (b n) (fun j hj hne => ?_) (fun hmem => absurd hb hmem)
        rw [hsupp j hj n hn (Ne.symm hne), mul_zero]
      have hrhs : ∑ j ∈ Finset.range J, ‖w j‖ ^ 2 * ‖A j n‖ ^ 2
          = ‖w (b n)‖ ^ 2 * ‖A (b n) n‖ ^ 2 := by
        refine Finset.sum_eq_single (b n) (fun j hj hne => ?_) (fun hmem => absurd hb hmem)
        rw [hsupp j hj n hn (Ne.symm hne), norm_zero]
        ring
      rw [hcoll, hrhs, norm_mul, mul_pow]
    · have hzero : ∀ j ∈ Finset.range J, A j n = 0 := by
        intro j hj
        refine hsupp j hj n hn ?_
        intro hcon
        exact hb (hcon ▸ hj)
      have h1 : ∑ j ∈ Finset.range J, w j * A j n = 0 :=
        Finset.sum_eq_zero fun j hj => by rw [hzero j hj, mul_zero]
      have h2 : ∑ j ∈ Finset.range J, ‖w j‖ ^ 2 * ‖A j n‖ ^ 2 = 0 :=
        Finset.sum_eq_zero fun j hj => by rw [hzero j hj, norm_zero]; ring
      rw [h1, h2, norm_zero]
      norm_num
  rw [Finset.sum_congr rfl hpt, Finset.sum_comm]
  exact Finset.sum_congr rfl fun j _ => by rw [Finset.mul_sum]

/-- **C3, upper half.**  For a spectrally separated AFE the second moment is bounded by the
large sieve constant times the *sum* of the blockwise coefficient masses — there is no
Cauchy–Schwarz loss over the blocks. -/
theorem secondMoment_disjoint_le (S : Finset ι) (lam : ι → ℕ → ℂ) (N : ℕ) (C : ℝ)
    (hLS : LargeSieve S lam N C) (J : ℕ) (w : ℕ → ℂ) (A : ℕ → ℕ → ℂ) (L : ι → ℂ) (b : ℕ → ℕ)
    (hL : AFE S lam N J w A L)
    (hsupp : ∀ j ∈ Finset.range J, ∀ n ∈ Finset.range N, b n ≠ j → A j n = 0) :
    ∑ f ∈ S, ‖L f‖ ^ 2
      ≤ C * ∑ j ∈ Finset.range J, ‖w j‖ ^ 2 * ∑ n ∈ Finset.range N, ‖A j n‖ ^ 2 := by
  have hrw : ∑ f ∈ S, ‖L f‖ ^ 2
      = ∑ f ∈ S, ‖linForm lam N (fun n => ∑ j ∈ Finset.range J, w j * A j n) f‖ ^ 2 :=
    Finset.sum_congr rfl fun f hf => by
      rw [afe_eq_linForm_aggregate S lam N J w A L hL hf]
  rw [hrw]
  refine (hLS _).trans_eq ?_
  rw [sum_normSq_aggregate_of_disjoint N J w A b hsupp]

/-- **The `J²` of the flagship theorem becomes `J` for spectrally separated blocks.** -/
theorem secondMoment_disjoint_uniform (S : Finset ι) (lam : ι → ℕ → ℂ) (N : ℕ) (C : ℝ)
    (hC : 0 ≤ C) (hLS : LargeSieve S lam N C) (J : ℕ) (w : ℕ → ℂ) (A : ℕ → ℕ → ℂ) (L : ι → ℂ)
    (b : ℕ → ℕ) (B : ℝ) (hL : AFE S lam N J w A L)
    (hsupp : ∀ j ∈ Finset.range J, ∀ n ∈ Finset.range N, b n ≠ j → A j n = 0)
    (hw : ∀ j ∈ Finset.range J, ‖w j‖ ≤ 1)
    (hB : ∀ j ∈ Finset.range J, ∑ n ∈ Finset.range N, ‖A j n‖ ^ 2 ≤ B) :
    ∑ f ∈ S, ‖L f‖ ^ 2 ≤ (J : ℝ) * C * B := by
  refine (secondMoment_disjoint_le S lam N C hLS J w A L b hL hsupp).trans ?_
  have hterm : ∀ j ∈ Finset.range J,
      ‖w j‖ ^ 2 * ∑ n ∈ Finset.range N, ‖A j n‖ ^ 2 ≤ B := by
    intro j hj
    have hA0 : (0 : ℝ) ≤ ∑ n ∈ Finset.range N, ‖A j n‖ ^ 2 :=
      Finset.sum_nonneg fun n _ => by positivity
    have h1 : ‖w j‖ ^ 2 ≤ 1 := by
      have := hw j hj
      nlinarith [norm_nonneg (w j)]
    calc ‖w j‖ ^ 2 * ∑ n ∈ Finset.range N, ‖A j n‖ ^ 2
        ≤ 1 * ∑ n ∈ Finset.range N, ‖A j n‖ ^ 2 :=
          mul_le_mul_of_nonneg_right h1 hA0
      _ = ∑ n ∈ Finset.range N, ‖A j n‖ ^ 2 := one_mul _
      _ ≤ B := hB j hj
  have hsum : ∑ j ∈ Finset.range J, ‖w j‖ ^ 2 * ∑ n ∈ Finset.range N, ‖A j n‖ ^ 2
      ≤ (J : ℝ) * B := by
    calc ∑ j ∈ Finset.range J, ‖w j‖ ^ 2 * ∑ n ∈ Finset.range N, ‖A j n‖ ^ 2
        ≤ ∑ _j ∈ Finset.range J, B := Finset.sum_le_sum hterm
      _ = (J : ℝ) * B := by rw [Finset.sum_const, Finset.card_range, nsmul_eq_mul]
  calc C * ∑ j ∈ Finset.range J, ‖w j‖ ^ 2 * ∑ n ∈ Finset.range N, ‖A j n‖ ^ 2
      ≤ C * ((J : ℝ) * B) := mul_le_mul_of_nonneg_left hsum hC
    _ = (J : ℝ) * C * B := by ring

/-- **C3, lower half: a matching second-moment lower bound for spectrally separated AFEs.**
Under Petersson-type quasi-orthogonality with diagonal `D` and off-diagonal error `e`, the
second moment of a disjointly supported `J`-block AFE is at least `(D − eN)` times the sum of
the blockwise coefficient masses. -/
theorem secondMoment_disjoint_lower (S : Finset ι) (lam : ι → ℕ → ℂ) (N : ℕ) (D e : ℝ)
    (h : QuasiOrthogonal S lam N D e) (J : ℕ) (w : ℕ → ℂ) (A : ℕ → ℕ → ℂ) (L : ι → ℂ)
    (b : ℕ → ℕ) (hL : AFE S lam N J w A L)
    (hsupp : ∀ j ∈ Finset.range J, ∀ n ∈ Finset.range N, b n ≠ j → A j n = 0) :
    (D - e * N) * ∑ j ∈ Finset.range J, ‖w j‖ ^ 2 * ∑ n ∈ Finset.range N, ‖A j n‖ ^ 2
      ≤ ∑ f ∈ S, ‖L f‖ ^ 2 := by
  have hrw : ∑ f ∈ S, ‖L f‖ ^ 2
      = ∑ f ∈ S, ‖linForm lam N (fun n => ∑ j ∈ Finset.range J, w j * A j n) f‖ ^ 2 :=
    Finset.sum_congr rfl fun f hf => by
      rw [afe_eq_linForm_aggregate S lam N J w A L hL hf]
  rw [hrw, ← sum_normSq_aggregate_of_disjoint N J w A b hsupp]
  exact lowerBound_of_quasiOrthogonal S lam N D e h _

/-- **The exact order of the second moment of a spectrally separated AFE.**  In the regime
`2eN ≤ D` the second moment is between `D/2` and `3D/2` times the total blockwise coefficient
mass; in particular it is `≍ D · M`, with no `J`-dependent loss in either direction. -/
theorem secondMoment_disjoint_order (S : Finset ι) (lam : ι → ℕ → ℂ) (N : ℕ) (D e : ℝ)
    (h : QuasiOrthogonal S lam N D e) (hreg : 2 * (e * N) ≤ D) (J : ℕ) (w : ℕ → ℂ)
    (A : ℕ → ℕ → ℂ) (L : ι → ℂ) (b : ℕ → ℕ) (hL : AFE S lam N J w A L)
    (hsupp : ∀ j ∈ Finset.range J, ∀ n ∈ Finset.range N, b n ≠ j → A j n = 0) :
    (D / 2) * ∑ j ∈ Finset.range J, ‖w j‖ ^ 2 * ∑ n ∈ Finset.range N, ‖A j n‖ ^ 2
        ≤ ∑ f ∈ S, ‖L f‖ ^ 2 ∧
      ∑ f ∈ S, ‖L f‖ ^ 2
        ≤ (3 * D / 2) * ∑ j ∈ Finset.range J, ‖w j‖ ^ 2 * ∑ n ∈ Finset.range N, ‖A j n‖ ^ 2 := by
  have hM0 : (0 : ℝ) ≤ ∑ j ∈ Finset.range J, ‖w j‖ ^ 2 * ∑ n ∈ Finset.range N, ‖A j n‖ ^ 2 :=
    Finset.sum_nonneg fun j _ => by
      have : (0 : ℝ) ≤ ∑ n ∈ Finset.range N, ‖A j n‖ ^ 2 :=
        Finset.sum_nonneg fun n _ => by positivity
      positivity
  constructor
  · refine le_trans ?_ (secondMoment_disjoint_lower S lam N D e h J w A L b hL hsupp)
    have : D / 2 ≤ D - e * N := by linarith
    exact mul_le_mul_of_nonneg_right this hM0
  · refine (secondMoment_disjoint_le S lam N (D + e * N)
      (largeSieve_of_quasiOrthogonal S lam N D e h) J w A L b hL hsupp).trans ?_
    have : D + e * N ≤ 3 * D / 2 := by linarith
    exact mul_le_mul_of_nonneg_right this hM0

/-- **The disjoint-block bound is attained, and the flagship bound is not.**  A concrete
orthonormal system with `N = J = 2`, unit weights and the two coordinate blocks: the second
moment equals `2`, the disjoint bound `C · ∑_j |w j|²‖A j‖²` equals `2` as well (equality),
while the flagship bound `J² · C · B` equals `4`.  So the factor `J` removed by
`secondMoment_disjoint_uniform` is exactly the truth, not an artefact of the proof. -/
theorem secondMoment_disjoint_attained :
    let lam : Fin 2 → ℕ → ℂ := fun f n => if n = (f : ℕ) then 1 else 0
    let w : ℕ → ℂ := fun _ => 1
    let A : ℕ → ℕ → ℂ := fun j n => if n = j then 1 else 0
    let L : Fin 2 → ℂ := fun _ => 1
    AFE (Finset.univ : Finset (Fin 2)) lam 2 2 w A L
      ∧ LargeSieve (Finset.univ : Finset (Fin 2)) lam 2 1
      ∧ (∀ j ∈ Finset.range 2, ∀ n ∈ Finset.range 2, n ≠ j → A j n = 0)
      ∧ (∑ f : Fin 2, ‖L f‖ ^ 2) = 2
      ∧ (1 : ℝ) * ∑ j ∈ Finset.range 2, ‖w j‖ ^ 2 * ∑ n ∈ Finset.range 2, ‖A j n‖ ^ 2 = 2
      ∧ ((2 : ℝ)) ^ 2 * 1 * 1 = 4 := by
  intro lam w A L
  have hlin : ∀ (a : ℕ → ℂ) (f : Fin 2), linForm lam 2 a f = a (f : ℕ) := by
    intro a f
    simp only [linForm, lam]
    fin_cases f <;> simp
  refine ⟨?_, ?_, ?_, ?_, ?_, by norm_num⟩
  · intro f _
    simp only [w, one_mul, hlin]
    fin_cases f <;> simp [L, A]
  · intro a
    simp only [hlin]
    rw [Fin.sum_univ_two, Finset.sum_range_succ, Finset.sum_range_succ]
    norm_num
  · intro j _ n _ hne
    simp [A, hne]
  · simp [L]
  · simp [w, A, Finset.sum_range_succ]
    norm_num

/-! ## The dyadic case -/

/-- Dyadic blocks are spectrally separated, with block-index function `Nat.log 2`. -/
theorem dyadic_support_disjoint (N J : ℕ) (A : ℕ → ℕ → ℂ)
    (hdy : ∀ j ∈ Finset.range J, ∀ n ∈ Finset.range N,
      ¬ (2 ^ j ≤ n ∧ n < 2 ^ (j + 1)) → A j n = 0) :
    ∀ j ∈ Finset.range J, ∀ n ∈ Finset.range N, Nat.log 2 n ≠ j → A j n = 0 := by
  intro j hj n hn hne
  refine hdy j hj n hn ?_
  rintro ⟨h1, h2⟩
  exact hne (Nat.log_eq_of_pow_le_of_lt_pow h1 h2)

/-- **A dyadic approximate functional equation carries no `J`-loss whatsoever.**  If the
`j`-th block is supported in `[2^j, 2^{j+1})`, the archimedean weights have total mass
`∑_j |w j|² ≤ W` and each block has coefficient mass at most `B`, then
`∑_f |L f|² ≤ C · W · B`.  Compared with the flagship bound `J² · C · B` this replaces the
number of blocks by the (typically bounded) weight mass `W`. -/
theorem secondMoment_dyadic (S : Finset ι) (lam : ι → ℕ → ℂ) (N : ℕ) (C : ℝ) (hC : 0 ≤ C)
    (hLS : LargeSieve S lam N C) (J : ℕ) (w : ℕ → ℂ) (A : ℕ → ℕ → ℂ) (L : ι → ℂ) (W B : ℝ)
    (hB0 : 0 ≤ B) (hL : AFE S lam N J w A L)
    (hdy : ∀ j ∈ Finset.range J, ∀ n ∈ Finset.range N,
      ¬ (2 ^ j ≤ n ∧ n < 2 ^ (j + 1)) → A j n = 0)
    (hW : ∑ j ∈ Finset.range J, ‖w j‖ ^ 2 ≤ W)
    (hB : ∀ j ∈ Finset.range J, ∑ n ∈ Finset.range N, ‖A j n‖ ^ 2 ≤ B) :
    ∑ f ∈ S, ‖L f‖ ^ 2 ≤ C * (W * B) := by
  refine (secondMoment_disjoint_le S lam N C hLS J w A L (fun n => Nat.log 2 n) hL
    (dyadic_support_disjoint N J A hdy)).trans ?_
  have hmass : ∑ j ∈ Finset.range J, ‖w j‖ ^ 2 * ∑ n ∈ Finset.range N, ‖A j n‖ ^ 2
      ≤ W * B := by
    calc ∑ j ∈ Finset.range J, ‖w j‖ ^ 2 * ∑ n ∈ Finset.range N, ‖A j n‖ ^ 2
        ≤ ∑ j ∈ Finset.range J, ‖w j‖ ^ 2 * B :=
          Finset.sum_le_sum fun j hj => mul_le_mul_of_nonneg_left (hB j hj) (by positivity)
      _ = (∑ j ∈ Finset.range J, ‖w j‖ ^ 2) * B := by rw [Finset.sum_mul]
      _ ≤ W * B := mul_le_mul_of_nonneg_right hW hB0
  exact mul_le_mul_of_nonneg_left hmass hC

end AsaiSecondMoment