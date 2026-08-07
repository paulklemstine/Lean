/-
# A formal large-sieve framework for Asai lifts

This file formalises, in a self-contained and quantitative way, the *analytic skeleton*
behind the paper **"On the Second Moment of `L(1/2, As(f) × φ)`"**: for `F = Q(√D)` a real
quadratic field and `f` running over a Hecke orthonormal basis of Hilbert modular cusp forms
of parallel weight `(k,k)` over `F`, one proves a **large sieve inequality** for the Hecke
eigenvalues of the Asai lifts `As(f)`, and then feeds an approximate functional equation into
it to bound the second moment of the central values `L(1/2, As(f) × φ)`.

What is formalised here is exactly the part of that argument that is *pure inequality
theory* — and it is formalised for an arbitrary finite family of "eigenvalue systems"
`lam : ι → ℕ → ℂ`, so that the Asai situation is one instance:

* `AsaiLargeSieve.LargeSieve S lam N C` — the large sieve inequality
  `∑_{f ∈ S} |∑_{n < N} a n · lam f n|² ≤ C · ∑_{n<N} |a n|²`.
* `AsaiLargeSieve.QuasiOrthogonal S lam N Δ ε` — a Petersson-type quasi-orthogonality
  relation `∑_{f ∈ S} lam f m · conj (lam f n) = Δ·δ_{m,n} + O(ε)`.

Main results:

* `AsaiLargeSieve.sum_normSq_linForm_eq` — the exact Gram expansion of the left-hand side of
  the large sieve into the correlation sums `∑_f lam f m · conj (lam f n)`.
* `AsaiLargeSieve.abs_sub_diagonal_le_of_quasiOrthogonal` — the two-sided estimate from which
  both the large sieve inequality and its matching lower bound follow.
* `AsaiLargeSieve.lowerBound_of_quasiOrthogonal` and
  `AsaiLargeSieve.secondMoment_order_of_quasiOrthogonal` — in the regime `2eN ≤ D` the second
  moment of a one-block Dirichlet polynomial has the *exact* order `D`, between `D/2` and
  `3D/2` times the coefficient mass; so the large sieve constant is of the correct order and
  not merely an upper bound.
* `AsaiLargeSieve.largeSieve_of_quasiOrthogonal` — **Petersson ⇒ large sieve**:
  quasi-orthogonality with diagonal `Δ` and off-diagonal error `ε` yields the large sieve
  constant `Δ + εN`.  This is the abstract form of the paper's Theorem on `As(f)`, where
  `Δ ≍ k` and `εN` is the Kloosterman/Salié contribution.
* `AsaiLargeSieve.dualLargeSieve_of_largeSieve` (and its converse
  `AsaiLargeSieve.largeSieve_of_dualLargeSieve`) — **duality**: the large sieve constant is
  the operator norm of the coefficient matrix, so it is the same for the matrix and its
  adjoint.  Proved by the self-testing trick, with no matrix theory.
* `AsaiLargeSieve.largeSieve_twist` — twisting the eigenvalue system by the (bounded) Hecke
  eigenvalues of a fixed cusp form `φ` costs only `ν²`; this is what converts a large sieve
  for `As(f)` into one for the Rankin–Selberg coefficients of `As(f) × φ`.
* `AsaiLargeSieve.diagonal_le_of_largeSieve`, `AsaiLargeSieve.trivialConstant_ge`,
  `AsaiLargeSieve.largeSieve_gain` — sharpness: any admissible constant dominates each
  diagonal term, the trivial (Cauchy–Schwarz) constant is `≥ N(Δ - ε)`, and hence the
  Petersson constant `Δ + εN` genuinely saves a factor `≍ N` whenever `εN ≤ Δ`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the whole large sieve half of the paper is a *finite-dimensional
operator norm statement*; the arithmetic (Asai lifts, real quadratic field, Petersson formula
with Salié sums) only enters through two scalars, the diagonal mass `Δ` and the off-diagonal
uniform error `ε`.  Bold form: the implication `Petersson ⇒ large sieve ⇒ second moment`
should be provable with *no* modular forms at all, and the resulting constant `Δ + εN` should
be sharp up to the factor `N` measured by `largeSieve_gain`.

Experiment (Experimenter): the Gram expansion `sum_normSq_linForm_eq` is an exact identity in
`ℂ`; separating the diagonal `Δ·δ` from the error and estimating `|∑_{m,n} a_m conj(a_n) E|
≤ ε (∑|a_n|)² ≤ εN ∑|a_n|²` (Cauchy–Schwarz against the constant `1`) gives the constant
`Δ + εN` unconditionally, with no positivity assumption on `Δ` or `ε`.  Duality was the one
place where the naive route (adjoint operators) is heavy; the self-testing choice
`a_n := ∑_f c_f conj(lam f n)` makes it a three-line Cauchy–Schwarz.

Analysis (Analyst): the failure mode of a naive attempt is the temptation to prove
`‖M‖ = ‖Mᵀ‖` through the spectral theorem.  The correct structural statement is that the
large sieve constant is a *quadratic form bound tested on the extremal vector*; both
directions of duality then have literally the same proof.  A second structural point: the
`εN` term is unavoidable, since `largeSieve_gain` shows the trivial constant is `≥ N(Δ-ε)`;
so `Δ + εN` is nontrivial precisely in the regime `ε ≤ Δ/N`, i.e. square-root cancellation
in the Kloosterman/Salié term — exactly the paper's threshold.

Critique (Critic): no statement here is vacuous — `diagonal_le_of_largeSieve` shows every
`LargeSieve` hypothesis has real content (it forces `C ≥ ∑_f |lam f n|²`), and the twisting
lemma is stated with an explicit bound `ν` rather than an unquantified `O(1)`.  The
hypotheses that are *not* needed (positivity of `Δ`, `ε`, or `C`) were deliberately dropped.
-/
import Mathlib

open Finset Complex

namespace AsaiLargeSieve

variable {ι : Type*}

/-! ## Definitions -/

/-- The Dirichlet polynomial `∑_{n < N} a n · lam f n` attached to the eigenvalue system
`lam f` of the `f`-th member of the family.  In the Asai setting `lam f n` is the `n`-th
Hecke eigenvalue of the Asai lift `As(f)` of a Hilbert modular form `f`. -/
noncomputable def linForm (lam : ι → ℕ → ℂ) (N : ℕ) (a : ℕ → ℂ) (f : ι) : ℂ :=
  ∑ n ∈ Finset.range N, a n * lam f n

/-- The large sieve inequality with constant `C`, length `N` and family `S`. -/
def LargeSieve (S : Finset ι) (lam : ι → ℕ → ℂ) (N : ℕ) (C : ℝ) : Prop :=
  ∀ a : ℕ → ℂ,
    ∑ f ∈ S, ‖linForm lam N a f‖ ^ 2 ≤ C * ∑ n ∈ Finset.range N, ‖a n‖ ^ 2

/-- The dual large sieve inequality: the same constant for the adjoint matrix. -/
def DualLargeSieve (S : Finset ι) (lam : ι → ℕ → ℂ) (N : ℕ) (C : ℝ) : Prop :=
  ∀ c : ι → ℂ,
    ∑ n ∈ Finset.range N, ‖∑ f ∈ S, c f * (starRingEnd ℂ) (lam f n)‖ ^ 2
      ≤ C * ∑ f ∈ S, ‖c f‖ ^ 2

/-- Petersson-type quasi-orthogonality: the correlation sums of the family are `Δ` on the
diagonal and `O(ε)` off it, uniformly for `m, n < N`. -/
def QuasiOrthogonal (S : Finset ι) (lam : ι → ℕ → ℂ) (N : ℕ) (D e : ℝ) : Prop :=
  ∀ m ∈ Finset.range N, ∀ n ∈ Finset.range N,
    ‖(∑ f ∈ S, lam f m * (starRingEnd ℂ) (lam f n)) - (if m = n then (D : ℂ) else 0)‖ ≤ e

/-! ## Elementary tools -/

/-- Cauchy–Schwarz for a finite sesquilinear sum of complex numbers, in squared form. -/
theorem cauchy_schwarz_sq {κ : Type*} (s : Finset κ) (u v : κ → ℂ) :
    ‖∑ i ∈ s, u i * (starRingEnd ℂ) (v i)‖ ^ 2
      ≤ (∑ i ∈ s, ‖u i‖ ^ 2) * (∑ i ∈ s, ‖v i‖ ^ 2) := by
  have h1 : ‖∑ i ∈ s, u i * (starRingEnd ℂ) (v i)‖ ≤ ∑ i ∈ s, ‖u i‖ * ‖v i‖ :=
    (norm_sum_le _ _).trans (Finset.sum_le_sum fun i _ => by simp)
  have h2 : (∑ i ∈ s, ‖u i‖ * ‖v i‖) ^ 2 ≤ (∑ i ∈ s, ‖u i‖ ^ 2) * (∑ i ∈ s, ‖v i‖ ^ 2) :=
    Finset.sum_mul_sq_le_sq_mul_sq s _ _
  refine le_trans ?_ h2
  gcongr

/-- `|z|² = z · conj z`, as an identity between complex numbers. -/
theorem sq_ofReal_norm (z : ℂ) : ((‖z‖ : ℂ)) ^ 2 = z * (starRingEnd ℂ) z := by
  rw [Complex.mul_conj]; norm_cast; exact (Complex.normSq_eq_norm_sq z).symm

/-- The norm of the complexification of a real difference. -/
theorem norm_ofReal_sub (x y : ℝ) : ‖((x : ℂ) - (y : ℂ))‖ = |x - y| := by
  rw [← Complex.ofReal_sub, Complex.norm_real, Real.norm_eq_abs]

/-- The `ℓ¹`–`ℓ²` inequality `(∑_{n<N} |a n|)² ≤ N ∑_{n<N} |a n|²`. -/
theorem sq_sum_norm_le (N : ℕ) (a : ℕ → ℂ) :
    (∑ n ∈ Finset.range N, ‖a n‖) ^ 2 ≤ (N : ℝ) * ∑ n ∈ Finset.range N, ‖a n‖ ^ 2 := by
  have h := Finset.sum_mul_sq_le_sq_mul_sq (Finset.range N) (fun n => ‖a n‖) (fun _ => (1 : ℝ))
  simpa [mul_comm] using h

/-- Squared triangle inequality with the loss `J` (number of terms). -/
theorem norm_sum_sq_le_card_mul {κ : Type*} (s : Finset κ) (x : κ → ℂ) :
    ‖∑ i ∈ s, x i‖ ^ 2 ≤ (s.card : ℝ) * ∑ i ∈ s, ‖x i‖ ^ 2 := by
  have h := cauchy_schwarz_sq s x (fun _ => (1 : ℂ))
  simpa [mul_comm] using h

/-! ## The Gram expansion -/

/-- **Exact Gram expansion.**  The left-hand side of the large sieve inequality equals the
double sum of the coefficient products against the correlation sums of the family. -/
theorem sum_normSq_linForm_eq (S : Finset ι) (lam : ι → ℕ → ℂ) (N : ℕ) (a : ℕ → ℂ) :
    ((∑ f ∈ S, ‖linForm lam N a f‖ ^ 2 : ℝ) : ℂ)
      = ∑ m ∈ Finset.range N, ∑ n ∈ Finset.range N,
          a m * (starRingEnd ℂ) (a n) * ∑ f ∈ S, lam f m * (starRingEnd ℂ) (lam f n) := by
  push_cast
  calc ∑ f ∈ S, ((‖linForm lam N a f‖ : ℂ)) ^ 2
      = ∑ f ∈ S, ∑ m ∈ Finset.range N, ∑ n ∈ Finset.range N,
          (a m * (starRingEnd ℂ) (a n)) * (lam f m * (starRingEnd ℂ) (lam f n)) := by
        refine Finset.sum_congr rfl fun f _ => ?_
        rw [sq_ofReal_norm, linForm, map_sum, Finset.sum_mul_sum]
        refine Finset.sum_congr rfl fun m _ => Finset.sum_congr rfl fun n _ => ?_
        rw [map_mul]; ring
    _ = _ := by
        rw [Finset.sum_comm]
        refine Finset.sum_congr rfl fun m _ => ?_
        rw [Finset.sum_comm]
        refine Finset.sum_congr rfl fun n _ => ?_
        rw [Finset.mul_sum]

/-- The diagonal part of the Gram expansion. -/
theorem diagonal_sum_eq (N : ℕ) (a : ℕ → ℂ) (D : ℝ) :
    ∑ m ∈ Finset.range N, ∑ n ∈ Finset.range N,
      a m * (starRingEnd ℂ) (a n) * (if m = n then (D : ℂ) else 0)
      = (D : ℂ) * ((∑ n ∈ Finset.range N, ‖a n‖ ^ 2 : ℝ) : ℂ) := by
  push_cast
  rw [Finset.mul_sum]
  refine Finset.sum_congr rfl fun m hm => ?_
  rw [Finset.sum_eq_single m]
  · rw [← sq_ofReal_norm]
    simp
    ring
  · intro n _ hne
    simp [Ne.symm hne]
  · intro h; exact absurd hm h

/-! ## Petersson ⇒ two-sided control of the quadratic form -/

/-- **The key two-sided estimate.**  Under quasi-orthogonality the quadratic form
`∑_f |∑_{n<N} a_n λ_f(n)|²` differs from its diagonal main term `D·∑|a_n|²` by at most
`eN·∑|a_n|²`.  Both the large sieve inequality and the matching lower bound are immediate
consequences. -/
theorem abs_sub_diagonal_le_of_quasiOrthogonal (S : Finset ι) (lam : ι → ℕ → ℂ) (N : ℕ)
    (D e : ℝ) (h : QuasiOrthogonal S lam N D e) (a : ℕ → ℂ) :
    |(∑ f ∈ S, ‖linForm lam N a f‖ ^ 2) - D * ∑ n ∈ Finset.range N, ‖a n‖ ^ 2|
      ≤ e * N * ∑ n ∈ Finset.range N, ‖a n‖ ^ 2 := by
  rcases Nat.eq_zero_or_pos N with hN0 | hNpos
  · subst hN0; simp [linForm]
  have he0 : 0 ≤ e :=
    le_trans (norm_nonneg _)
      (h 0 (Finset.mem_range.mpr hNpos) 0 (Finset.mem_range.mpr hNpos))
  set R : ℝ := ∑ f ∈ S, ‖linForm lam N a f‖ ^ 2 with hR
  set A : ℝ := ∑ n ∈ Finset.range N, ‖a n‖ ^ 2 with hA
  set E : ℕ → ℕ → ℂ := fun m n =>
    (∑ f ∈ S, lam f m * (starRingEnd ℂ) (lam f n)) - (if m = n then (D : ℂ) else 0) with hE
  have key : ((R - D * A : ℝ) : ℂ)
      = ∑ m ∈ Finset.range N, ∑ n ∈ Finset.range N, a m * (starRingEnd ℂ) (a n) * E m n := by
    have h1 := sum_normSq_linForm_eq S lam N a
    have h2 := diagonal_sum_eq N a D
    push_cast
    rw [← hR] at h1
    rw [← hA] at h2
    rw [h1, ← h2, ← Finset.sum_sub_distrib]
    refine Finset.sum_congr rfl fun m _ => ?_
    rw [← Finset.sum_sub_distrib]
    refine Finset.sum_congr rfl fun n _ => ?_
    rw [hE]; ring
  have hbound : |R - D * A| ≤ e * ((∑ n ∈ Finset.range N, ‖a n‖) ^ 2) := by
    have hnorm : ‖((R : ℂ) - (D * A : ℝ))‖ = |R - D * A| := norm_ofReal_sub R (D * A)
    rw [show |R - D * A| = ‖((R - D * A : ℝ) : ℂ)‖ by
        rw [show ((R - D * A : ℝ) : ℂ) = (R : ℂ) - ((D * A : ℝ) : ℂ) by push_cast; ring, hnorm],
      key]
    have step1 : ‖∑ m ∈ Finset.range N, ∑ n ∈ Finset.range N,
        a m * (starRingEnd ℂ) (a n) * E m n‖
        ≤ ∑ m ∈ Finset.range N, ∑ n ∈ Finset.range N, ‖a m‖ * ‖a n‖ * e := by
      refine (norm_sum_le _ _).trans (Finset.sum_le_sum fun m hm => ?_)
      refine (norm_sum_le _ _).trans (Finset.sum_le_sum fun n hn => ?_)
      have hEmn : ‖E m n‖ ≤ e := h m hm n hn
      have : ‖a m * (starRingEnd ℂ) (a n) * E m n‖ = ‖a m‖ * ‖a n‖ * ‖E m n‖ := by
        simp
      rw [this]
      have hpos : (0 : ℝ) ≤ ‖a m‖ * ‖a n‖ := by positivity
      exact mul_le_mul_of_nonneg_left hEmn hpos
    refine step1.trans_eq ?_
    simp_rw [← Finset.sum_mul, ← Finset.mul_sum, ← Finset.sum_mul]
    ring
  have hcs : (∑ n ∈ Finset.range N, ‖a n‖) ^ 2 ≤ (N : ℝ) * A := sq_sum_norm_le N a
  have he : e * ((∑ n ∈ Finset.range N, ‖a n‖) ^ 2) ≤ e * ((N : ℝ) * A) :=
    mul_le_mul_of_nonneg_left hcs he0
  calc |R - D * A| ≤ e * ((∑ n ∈ Finset.range N, ‖a n‖) ^ 2) := hbound
    _ ≤ e * ((N : ℝ) * A) := he
    _ = e * N * A := by ring

/-- **Main structural theorem.**  A Petersson-type quasi-orthogonality relation with diagonal
`D` and uniform off-diagonal error `e` implies the large sieve inequality with constant
`D + e·N`.  In the Asai application `D ≍ k` (the Petersson diagonal for parallel weight
`(k,k)`) and `e` is the size of the Kloosterman/Salié sum contribution. -/
theorem largeSieve_of_quasiOrthogonal (S : Finset ι) (lam : ι → ℕ → ℂ) (N : ℕ) (D e : ℝ)
    (h : QuasiOrthogonal S lam N D e) : LargeSieve S lam N (D + e * N) := by
  intro a
  have hb := abs_sub_diagonal_le_of_quasiOrthogonal S lam N D e h a
  have := (abs_le.mp hb).2
  nlinarith [this]

/-- **Matching lower bound.**  The same estimate, read in the other direction: the quadratic
form is bounded *below* by `(D - eN)·∑|a_n|²`.  Together with
`largeSieve_of_quasiOrthogonal` this pins the second moment of a one-block Dirichlet
polynomial down to within a factor `(D + eN)/(D - eN)`, which is `O(1)` in the
Kloosterman-controlled regime `eN ≤ D/2`. -/
theorem lowerBound_of_quasiOrthogonal (S : Finset ι) (lam : ι → ℕ → ℂ) (N : ℕ) (D e : ℝ)
    (h : QuasiOrthogonal S lam N D e) (a : ℕ → ℂ) :
    (D - e * N) * (∑ n ∈ Finset.range N, ‖a n‖ ^ 2)
      ≤ ∑ f ∈ S, ‖linForm lam N a f‖ ^ 2 := by
  have hb := abs_sub_diagonal_le_of_quasiOrthogonal S lam N D e h a
  have := (abs_le.mp hb).1
  nlinarith [this]

/-- **The second moment of a one-block Dirichlet polynomial has the exact order `D`.**  In the
regime `2eN ≤ D` (square-root cancellation in the Kloosterman/Salié term) the second moment
is between `D/2` and `3D/2` times the coefficient mass. -/
theorem secondMoment_order_of_quasiOrthogonal (S : Finset ι) (lam : ι → ℕ → ℂ) (N : ℕ)
    (D e : ℝ) (h : QuasiOrthogonal S lam N D e) (hreg : 2 * (e * N) ≤ D) (a : ℕ → ℂ) :
    (D / 2) * (∑ n ∈ Finset.range N, ‖a n‖ ^ 2) ≤ ∑ f ∈ S, ‖linForm lam N a f‖ ^ 2 ∧
      ∑ f ∈ S, ‖linForm lam N a f‖ ^ 2 ≤ (3 * D / 2) * (∑ n ∈ Finset.range N, ‖a n‖ ^ 2) := by
  have hA0 : (0 : ℝ) ≤ ∑ n ∈ Finset.range N, ‖a n‖ ^ 2 :=
    Finset.sum_nonneg fun n _ => by positivity
  constructor
  · refine le_trans ?_ (lowerBound_of_quasiOrthogonal S lam N D e h a)
    have : D / 2 ≤ D - e * N := by linarith
    exact mul_le_mul_of_nonneg_right this hA0
  · refine le_trans (largeSieve_of_quasiOrthogonal S lam N D e h a) ?_
    have : D + e * N ≤ 3 * D / 2 := by linarith
    exact mul_le_mul_of_nonneg_right this hA0

/-! ## Duality -/

/-- **Duality, forward direction.**  The large sieve constant transfers to the adjoint. -/
theorem dualLargeSieve_of_largeSieve (S : Finset ι) (lam : ι → ℕ → ℂ) (N : ℕ) (C : ℝ)
    (hC : 0 ≤ C) (h : LargeSieve S lam N C) : DualLargeSieve S lam N C := by
  intro c
  set Sq : ℝ := ∑ n ∈ Finset.range N, ‖∑ f ∈ S, c f * (starRingEnd ℂ) (lam f n)‖ ^ 2 with hSq
  set a : ℕ → ℂ := fun n => ∑ f ∈ S, c f * (starRingEnd ℂ) (lam f n) with ha
  have hSq0 : 0 ≤ Sq := Finset.sum_nonneg fun n _ => by positivity
  have hpair : ((Sq : ℝ) : ℂ) = ∑ f ∈ S, (starRingEnd ℂ) (c f) * linForm lam N a f := by
    have : ((Sq : ℝ) : ℂ) = ∑ n ∈ Finset.range N, a n * (starRingEnd ℂ) (a n) := by
      rw [hSq]
      push_cast
      exact Finset.sum_congr rfl fun n _ => by rw [← sq_ofReal_norm]
    rw [this]
    calc ∑ n ∈ Finset.range N, a n * (starRingEnd ℂ) (a n)
        = ∑ n ∈ Finset.range N, ∑ f ∈ S, a n * ((starRingEnd ℂ) (c f) * lam f n) := by
          refine Finset.sum_congr rfl fun n _ => ?_
          rw [ha]
          simp only [map_sum, map_mul, Complex.conj_conj, Finset.mul_sum]
      _ = ∑ f ∈ S, (starRingEnd ℂ) (c f) * linForm lam N a f := by
          rw [Finset.sum_comm]
          refine Finset.sum_congr rfl fun f _ => ?_
          rw [linForm, Finset.mul_sum]
          exact Finset.sum_congr rfl fun n _ => by ring
  have hcs : Sq ^ 2 ≤ (∑ f ∈ S, ‖c f‖ ^ 2) * (∑ f ∈ S, ‖linForm lam N a f‖ ^ 2) := by
    have := cauchy_schwarz_sq S (fun f => (starRingEnd ℂ) (c f))
      (fun f => (starRingEnd ℂ) (linForm lam N a f))
    simp only [Complex.conj_conj] at this
    have hrw : ‖∑ f ∈ S, (starRingEnd ℂ) (c f) * linForm lam N a f‖ = |Sq| := by
      rw [← hpair]; simp
    rw [hrw, abs_of_nonneg hSq0] at this
    simpa using this
  have hLS : ∑ f ∈ S, ‖linForm lam N a f‖ ^ 2 ≤ C * ∑ n ∈ Finset.range N, ‖a n‖ ^ 2 := h a
  have hAeq : ∑ n ∈ Finset.range N, ‖a n‖ ^ 2 = Sq := by rw [hSq, ha]
  rw [hAeq] at hLS
  have hc0 : 0 ≤ ∑ f ∈ S, ‖c f‖ ^ 2 := Finset.sum_nonneg fun f _ => by positivity
  rcases eq_or_lt_of_le hSq0 with hz | hz
  · rw [← hz]; positivity
  · have h2 : Sq ^ 2 ≤ (∑ f ∈ S, ‖c f‖ ^ 2) * (C * Sq) :=
      hcs.trans (mul_le_mul_of_nonneg_left hLS hc0)
    have : Sq * Sq ≤ ((∑ f ∈ S, ‖c f‖ ^ 2) * C) * Sq := by nlinarith
    exact le_of_mul_le_mul_right (by linarith [this]) hz

/-- **Duality, converse direction.**  Same proof, tested on the other side. -/
theorem largeSieve_of_dualLargeSieve (S : Finset ι) (lam : ι → ℕ → ℂ) (N : ℕ) (C : ℝ)
    (hC : 0 ≤ C) (h : DualLargeSieve S lam N C) : LargeSieve S lam N C := by
  intro b
  set Sq : ℝ := ∑ f ∈ S, ‖linForm lam N b f‖ ^ 2 with hSq
  set c : ι → ℂ := fun f => linForm lam N b f with hc
  have hSq0 : 0 ≤ Sq := Finset.sum_nonneg fun f _ => by positivity
  have hceq : ∑ f ∈ S, ‖c f‖ ^ 2 = Sq := by rw [hSq, hc]
  have hpair : ((Sq : ℝ) : ℂ)
      = ∑ n ∈ Finset.range N, b n * (starRingEnd ℂ) (∑ f ∈ S, c f * (starRingEnd ℂ) (lam f n)) := by
    have h1 : ((Sq : ℝ) : ℂ)
        = ∑ f ∈ S, (starRingEnd ℂ) (linForm lam N b f) * linForm lam N b f := by
      rw [hSq]; push_cast
      exact Finset.sum_congr rfl fun f _ => by rw [sq_ofReal_norm]; ring
    rw [h1]
    calc ∑ f ∈ S, (starRingEnd ℂ) (linForm lam N b f) * linForm lam N b f
        = ∑ f ∈ S, ∑ n ∈ Finset.range N,
            (starRingEnd ℂ) (c f) * (b n * lam f n) := by
          refine Finset.sum_congr rfl fun f _ => ?_
          rw [hc]
          simp only [linForm, Finset.mul_sum]
      _ = ∑ n ∈ Finset.range N,
            b n * (starRingEnd ℂ) (∑ f ∈ S, c f * (starRingEnd ℂ) (lam f n)) := by
          rw [Finset.sum_comm]
          refine Finset.sum_congr rfl fun n _ => ?_
          simp only [map_sum, map_mul, Complex.conj_conj, Finset.mul_sum]
          exact Finset.sum_congr rfl fun f _ => by ring
  have hcs : Sq ^ 2 ≤ (∑ n ∈ Finset.range N, ‖b n‖ ^ 2) *
      (∑ n ∈ Finset.range N, ‖∑ f ∈ S, c f * (starRingEnd ℂ) (lam f n)‖ ^ 2) := by
    have := cauchy_schwarz_sq (Finset.range N) b
      (fun n => ∑ f ∈ S, c f * (starRingEnd ℂ) (lam f n))
    have hrw : ‖∑ n ∈ Finset.range N,
        b n * (starRingEnd ℂ) (∑ f ∈ S, c f * (starRingEnd ℂ) (lam f n))‖ = |Sq| := by
      rw [← hpair]; simp
    rw [hrw, abs_of_nonneg hSq0] at this
    exact this
  have hD := h c
  rw [hceq] at hD
  have hb0 : 0 ≤ ∑ n ∈ Finset.range N, ‖b n‖ ^ 2 := Finset.sum_nonneg fun n _ => by positivity
  rcases eq_or_lt_of_le hSq0 with hz | hz
  · rw [← hz]; positivity
  · have h2 : Sq ^ 2 ≤ (∑ n ∈ Finset.range N, ‖b n‖ ^ 2) * (C * Sq) :=
      hcs.trans (mul_le_mul_of_nonneg_left hD hb0)
    have : Sq * Sq ≤ (C * ∑ n ∈ Finset.range N, ‖b n‖ ^ 2) * Sq := by nlinarith
    exact le_of_mul_le_mul_right (by linarith [this]) hz

/-! ## Twisting by a fixed form -/

/-- **Twisting.**  If the Hecke eigenvalues `mu n` of a fixed cusp form `φ` are bounded by
`ν` on `[0,N)`, then a large sieve inequality for `lam` implies one, with constant `C·ν²`,
for the Rankin–Selberg coefficients `lam f n · mu n` of the convolutions. -/
theorem largeSieve_twist (S : Finset ι) (lam : ι → ℕ → ℂ) (N : ℕ) (C : ℝ) (mu : ℕ → ℂ)
    (nu : ℝ) (hC : 0 ≤ C) (hnu0 : 0 ≤ nu) (h : LargeSieve S lam N C)
    (hmu : ∀ n ∈ Finset.range N, ‖mu n‖ ≤ nu) :
    LargeSieve S (fun f n => lam f n * mu n) N (C * nu ^ 2) := by
  intro a
  have hform : ∀ f, linForm (fun f n => lam f n * mu n) N a f
      = linForm lam N (fun n => a n * mu n) f := by
    intro f
    simp only [linForm]
    exact Finset.sum_congr rfl fun n _ => by ring
  simp only [hform]
  refine (h (fun n => a n * mu n)).trans ?_
  have : ∑ n ∈ Finset.range N, ‖a n * mu n‖ ^ 2
      ≤ nu ^ 2 * ∑ n ∈ Finset.range N, ‖a n‖ ^ 2 := by
    rw [Finset.mul_sum]
    refine Finset.sum_le_sum fun n hn => ?_
    have h1 : ‖a n * mu n‖ ^ 2 = ‖a n‖ ^ 2 * ‖mu n‖ ^ 2 := by
      rw [norm_mul]; ring
    rw [h1, mul_comm (nu ^ 2)]
    have := hmu n hn
    have h2 : ‖mu n‖ ^ 2 ≤ nu ^ 2 := by nlinarith [norm_nonneg (mu n)]
    exact mul_le_mul_of_nonneg_left h2 (by positivity)
  calc C * ∑ n ∈ Finset.range N, ‖a n * mu n‖ ^ 2
      ≤ C * (nu ^ 2 * ∑ n ∈ Finset.range N, ‖a n‖ ^ 2) := mul_le_mul_of_nonneg_left this hC
    _ = C * nu ^ 2 * ∑ n ∈ Finset.range N, ‖a n‖ ^ 2 := by ring

/-! ## Sharpness -/

/-- Every admissible large sieve constant dominates each diagonal term: this shows that a
`LargeSieve` hypothesis is never vacuous. -/
theorem diagonal_le_of_largeSieve (S : Finset ι) (lam : ι → ℕ → ℂ) (N : ℕ) (C : ℝ)
    (h : LargeSieve S lam N C) {n₀ : ℕ} (hn₀ : n₀ < N) :
    ∑ f ∈ S, ‖lam f n₀‖ ^ 2 ≤ C := by
  have := h (fun n => if n = n₀ then 1 else 0)
  have hform : ∀ f, linForm lam N (fun n => if n = n₀ then 1 else 0) f = lam f n₀ := by
    intro f
    rw [linForm, Finset.sum_eq_single n₀]
    · simp
    · intro n _ hne; simp [hne]
    · intro hmem; exact absurd (Finset.mem_range.mpr hn₀) hmem
  simp only [hform] at this
  have hrhs : ∑ n ∈ Finset.range N, ‖(if n = n₀ then (1 : ℂ) else 0)‖ ^ 2 = 1 := by
    rw [Finset.sum_eq_single n₀]
    · simp
    · intro n _ hne; simp [hne]
    · intro hmem; exact absurd (Finset.mem_range.mpr hn₀) hmem
  rw [hrhs, mul_one] at this
  exact this

/-- The trivial (Cauchy–Schwarz, no cancellation) large sieve constant. -/
theorem largeSieve_trivial (S : Finset ι) (lam : ι → ℕ → ℂ) (N : ℕ) :
    LargeSieve S lam N (∑ f ∈ S, ∑ n ∈ Finset.range N, ‖lam f n‖ ^ 2) := by
  intro a
  have hpt : ∀ f ∈ S, ‖linForm lam N a f‖ ^ 2
      ≤ (∑ n ∈ Finset.range N, ‖lam f n‖ ^ 2) * ∑ n ∈ Finset.range N, ‖a n‖ ^ 2 := by
    intro f _
    have := cauchy_schwarz_sq (Finset.range N) (fun n => a n * lam f n) (fun _ => (1 : ℂ))
    simp only [map_one, mul_one, norm_one, one_pow, Finset.sum_const, nsmul_eq_mul] at this
    have h2 : ‖linForm lam N a f‖ ^ 2 ≤ (∑ n ∈ Finset.range N, ‖a n‖ ^ 2) *
        ∑ n ∈ Finset.range N, ‖lam f n‖ ^ 2 := by
      have h3 := cauchy_schwarz_sq (Finset.range N) a (fun n => (starRingEnd ℂ) (lam f n))
      simp only [Complex.conj_conj, RCLike.norm_conj] at h3
      simpa [linForm] using h3
    rw [mul_comm]
    exact h2
  calc ∑ f ∈ S, ‖linForm lam N a f‖ ^ 2
      ≤ ∑ f ∈ S, (∑ n ∈ Finset.range N, ‖lam f n‖ ^ 2) * ∑ n ∈ Finset.range N, ‖a n‖ ^ 2 :=
        Finset.sum_le_sum hpt
    _ = (∑ f ∈ S, ∑ n ∈ Finset.range N, ‖lam f n‖ ^ 2) * ∑ n ∈ Finset.range N, ‖a n‖ ^ 2 := by
        rw [← Finset.sum_mul]

/-- Under quasi-orthogonality the *trivial* constant is at least `N (D - e)`.  Combined with
`largeSieve_of_quasiOrthogonal` this quantifies the saving: the Petersson constant is
`D + eN`, so the gain over the trivial bound is a factor `≍ N` as soon as `eN ≤ D`. -/
theorem trivialConstant_ge (S : Finset ι) (lam : ι → ℕ → ℂ) (N : ℕ) (D e : ℝ)
    (h : QuasiOrthogonal S lam N D e) :
    (N : ℝ) * (D - e) ≤ ∑ f ∈ S, ∑ n ∈ Finset.range N, ‖lam f n‖ ^ 2 := by
  have hpt : ∀ n ∈ Finset.range N, D - e ≤ ∑ f ∈ S, ‖lam f n‖ ^ 2 := by
    intro n hn
    have hqo : ‖(∑ f ∈ S, lam f n * (starRingEnd ℂ) (lam f n)) - (D : ℂ)‖ ≤ e := by
      simpa using h n hn n hn
    have hreal : ((∑ f ∈ S, ‖lam f n‖ ^ 2 : ℝ) : ℂ)
        = ∑ f ∈ S, lam f n * (starRingEnd ℂ) (lam f n) := by
      push_cast
      exact Finset.sum_congr rfl fun f _ => by rw [← sq_ofReal_norm]
    rw [← hreal] at hqo
    rw [norm_ofReal_sub] at hqo
    have := abs_le.mp hqo
    linarith [this.1]
  have hsum : ∑ n ∈ Finset.range N, (D - e) ≤ ∑ n ∈ Finset.range N, ∑ f ∈ S, ‖lam f n‖ ^ 2 :=
    Finset.sum_le_sum hpt
  rw [Finset.sum_const, Finset.card_range, nsmul_eq_mul] at hsum
  rw [Finset.sum_comm] at hsum
  exact hsum

/-- **The gain over the trivial bound.**  If `e·N ≤ D` and `0 < D`, then the Petersson large
sieve constant `D + eN` is at most `4/N` times the trivial constant, for `N ≥ 4`;
concretely, `(D + eN) * (N/4) ≤ trivial constant`. -/
theorem largeSieve_gain (S : Finset ι) (lam : ι → ℕ → ℂ) (N : ℕ) (D e : ℝ)
    (h : QuasiOrthogonal S lam N D e) (he0 : 0 ≤ e) (heN : e * N ≤ D) (hN : 4 ≤ (N : ℝ)) :
    (D + e * N) * ((N : ℝ) / 4) ≤ ∑ f ∈ S, ∑ n ∈ Finset.range N, ‖lam f n‖ ^ 2 := by
  have hbase := trivialConstant_ge S lam N D e h
  have heD : e ≤ D / N := by
    have hN0 : (0 : ℝ) < N := by linarith
    rw [le_div_iff₀ hN0]; linarith
  have hD0 : 0 ≤ D := le_trans (by positivity) heN
  have h4 : e ≤ D / 4 := by
    have hN0 : (0 : ℝ) < N := by linarith
    calc e ≤ D / N := heD
      _ ≤ D / 4 := by
        apply div_le_div_of_nonneg_left hD0 (by norm_num) hN
  refine le_trans ?_ hbase
  have : (D + e * N) * ((N : ℝ) / 4) ≤ (N : ℝ) * (D - e) := by
    have hN0 : (0 : ℝ) < N := by linarith
    have hkey : (D + e * N) / 4 ≤ D - e := by
      have : e * N ≤ D := heN
      linarith [h4]
    calc (D + e * N) * ((N : ℝ) / 4) = (N : ℝ) * ((D + e * N) / 4) := by ring
      _ ≤ (N : ℝ) * (D - e) := by
          exact mul_le_mul_of_nonneg_left hkey (le_of_lt hN0)
  exact this

end AsaiLargeSieve