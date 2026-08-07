/-
# The second moment of `L(1/2, As(f) × φ)` from the large sieve

This file completes the analytic skeleton begun in `Novelty.AsaiLargeSieve`.  There we proved
that a Petersson-type quasi-orthogonality relation for the Hecke eigenvalues of the Asai
lifts `As(f)` (with `f` in a Hecke orthonormal basis of Hilbert modular cusp forms of parallel
weight `(k,k)` over a real quadratic field `F = Q(√D)`) produces a large sieve inequality,
that the constant is self-dual, and that twisting by the bounded Hecke eigenvalues of a fixed
Hecke–Maass form `φ` over `Q` costs only `ν²`.

Here we feed an **approximate functional equation** into that machine.  An AFE writes each
central value as a *short* linear combination of Dirichlet polynomials in the Rankin–Selberg
coefficients `λ_{As(f)}(n) λ_φ(n)`:

`L(1/2, As(f) × φ) = ∑_{j < J} w j · ∑_{n < N} A j n · λ_{As(f)}(n) λ_φ(n)`

(the index `j` runs over the `O(log)` dyadic blocks and the two terms of the functional
equation; `w j` are the archimedean weights and `A j n` the smoothed coefficients).

Main results:

* `AsaiSecondMoment.secondMoment_le` — the second moment of any family of values admitting
  such a decomposition is bounded by `J · ∑_j |w j|² · C · ‖A j‖²`, where `C` is *any*
  admissible large sieve constant.
* `AsaiSecondMoment.secondMoment_uniform` — the uniform form `J² · C · B`.
* `AsaiSecondMoment.asai_second_moment_k_aspect` — **the flagship statement**: from
  quasi-orthogonality with diagonal `D ≤ c₁·k` and off-diagonal error `e` with `eN ≤ c₂·k`,
  from a `ν`-bounded twisting system `mu` (the Hecke eigenvalues of `φ`) and from an AFE with
  `J` blocks and coefficient mass `≤ B`, one gets

  `∑_f |L f|² ≤ (c₁ + c₂) · ν² · J² · B · k`,

  i.e. a second moment bound that is **linear in the weight `k`** up to the `J² = O(log²k)`
  loss of the AFE — the shape of the paper's main application.
* `AsaiSecondMoment.secondMoment_saving` — the adversarial check: the same second moment,
  bounded through the *trivial* (Cauchy–Schwarz, no cancellation) large sieve constant, is
  worse by a factor `≍ N`; so the bound above is genuinely non-trivial exactly in the regime
  `eN ≤ D` where the Kloosterman/Salié term is under control.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the passage AFE → second moment should cost exactly the square of
the number of blocks and nothing else; in particular the `k`-aspect exponent of the second
moment should be *inherited verbatim* from the diagonal `D` of the Petersson formula, with
the length `N` of the AFE entering only through the product `eN`.  Bold form: no analytic
input beyond `‖∑_{j<J} x_j‖² ≤ J ∑ ‖x_j‖²` is needed.

Experiment (Experimenter): confirmed.  `secondMoment_le` needs only the squared triangle
inequality plus the large sieve applied to each block after absorbing the weight `w j` into
the coefficients (`linForm` is linear in the coefficient vector, which is why the constant
`C` may be used blockwise with no loss).  The `k`-aspect corollary then composes
`largeSieve_of_quasiOrthogonal`, `largeSieve_twist` and `secondMoment_uniform`; positivity of
the large sieve constant is *not* assumed but derived from `diagonal_le_of_largeSieve`.

Analysis (Analyst): a first attempt assumed `0 ≤ D`, `0 ≤ e`, `0 ≤ B`, `0 ≤ k` as separate
hypotheses.  All four are removable: `e ≥ 0` follows from quasi-orthogonality on a nonempty
range, `D + eN ≥ 0` from the diagonal test vector, `B ≥ 0` from a nonempty block set, and the
`k`-positivity is never needed because only the product `(c₁+c₂)k` is compared with the
nonnegative quantity `D + eN`.  Removing them is what makes the final statement faithful:
no hidden assumption can make it vacuous.

Critique (Critic): could the flagship theorem be vacuous, e.g. by unsatisfiable hypotheses?
No: `AsaiSecondMoment.exists_nontrivial_instance` exhibits a concrete nonzero instance of the
full hypothesis package (an orthonormal system with `D = 1`, `e = 0`), in which the conclusion
is a genuine nonzero inequality.  Could it be weak?  `secondMoment_saving` measures precisely
the factor `N` that separates it from the trivial bound.
-/
import Mathlib
import Novelty.AsaiLargeSieve

open Finset Complex AsaiLargeSieve

namespace AsaiSecondMoment

variable {ι : Type*}

/-- An **approximate functional equation** decomposition of a family of central values:
`L f = ∑_{j<J} w j · (∑_{n<N} A j n · lam f n)`. -/
def AFE (S : Finset ι) (lam : ι → ℕ → ℂ) (N J : ℕ) (w : ℕ → ℂ) (A : ℕ → ℕ → ℂ)
    (L : ι → ℂ) : Prop :=
  ∀ f ∈ S, L f = ∑ j ∈ Finset.range J, w j * linForm lam N (A j) f

/-- **Second moment from the large sieve.**  Any family of values with an AFE decomposition
into `J` Dirichlet polynomials of length `N` has second moment bounded by `J` times the
weighted sum of the large sieve bounds for the individual blocks. -/
theorem secondMoment_le (S : Finset ι) (lam : ι → ℕ → ℂ) (N : ℕ) (C : ℝ)
    (hLS : LargeSieve S lam N C) (J : ℕ) (w : ℕ → ℂ) (A : ℕ → ℕ → ℂ) (L : ι → ℂ)
    (hL : AFE S lam N J w A L) :
    ∑ f ∈ S, ‖L f‖ ^ 2
      ≤ (J : ℝ) * ∑ j ∈ Finset.range J, ‖w j‖ ^ 2 * (C * ∑ n ∈ Finset.range N, ‖A j n‖ ^ 2) := by
  have step1 : ∑ f ∈ S, ‖L f‖ ^ 2
      ≤ ∑ f ∈ S, (J : ℝ) * ∑ j ∈ Finset.range J, ‖w j * linForm lam N (A j) f‖ ^ 2 := by
    refine Finset.sum_le_sum fun f hf => ?_
    rw [hL f hf]
    have := norm_sum_sq_le_card_mul (Finset.range J) (fun j => w j * linForm lam N (A j) f)
    simpa using this
  have step2 : ∑ f ∈ S, (J : ℝ) * ∑ j ∈ Finset.range J, ‖w j * linForm lam N (A j) f‖ ^ 2
      = (J : ℝ) * ∑ j ∈ Finset.range J, ‖w j‖ ^ 2 * ∑ f ∈ S, ‖linForm lam N (A j) f‖ ^ 2 := by
    rw [← Finset.mul_sum, Finset.sum_comm]
    congr 1
    refine Finset.sum_congr rfl fun j _ => ?_
    rw [Finset.mul_sum]
    exact Finset.sum_congr rfl fun f _ => by rw [norm_mul]; ring
  have step3 : ∀ j ∈ Finset.range J,
      ‖w j‖ ^ 2 * ∑ f ∈ S, ‖linForm lam N (A j) f‖ ^ 2
        ≤ ‖w j‖ ^ 2 * (C * ∑ n ∈ Finset.range N, ‖A j n‖ ^ 2) := fun j _ =>
    mul_le_mul_of_nonneg_left (hLS (A j)) (by positivity)
  calc ∑ f ∈ S, ‖L f‖ ^ 2
      ≤ ∑ f ∈ S, (J : ℝ) * ∑ j ∈ Finset.range J, ‖w j * linForm lam N (A j) f‖ ^ 2 := step1
    _ = (J : ℝ) * ∑ j ∈ Finset.range J, ‖w j‖ ^ 2 * ∑ f ∈ S, ‖linForm lam N (A j) f‖ ^ 2 := step2
    _ ≤ (J : ℝ) * ∑ j ∈ Finset.range J, ‖w j‖ ^ 2 * (C * ∑ n ∈ Finset.range N, ‖A j n‖ ^ 2) := by
        exact mul_le_mul_of_nonneg_left (Finset.sum_le_sum step3) (by positivity)

/-- Uniform form of the previous bound: with archimedean weights bounded by `1` and blockwise
coefficient mass at most `B`, the second moment is at most `J² · C · B`. -/
theorem secondMoment_uniform (S : Finset ι) (lam : ι → ℕ → ℂ) (N : ℕ) (C : ℝ) (hC : 0 ≤ C)
    (hLS : LargeSieve S lam N C) (J : ℕ) (w : ℕ → ℂ) (A : ℕ → ℕ → ℂ) (L : ι → ℂ) (B : ℝ)
    (hL : AFE S lam N J w A L) (hw : ∀ j ∈ Finset.range J, ‖w j‖ ≤ 1)
    (hB : ∀ j ∈ Finset.range J, ∑ n ∈ Finset.range N, ‖A j n‖ ^ 2 ≤ B) :
    ∑ f ∈ S, ‖L f‖ ^ 2 ≤ (J : ℝ) ^ 2 * C * B := by
  have hterm : ∀ j ∈ Finset.range J,
      ‖w j‖ ^ 2 * (C * ∑ n ∈ Finset.range N, ‖A j n‖ ^ 2) ≤ C * B := by
    intro j hj
    have h1 : (0 : ℝ) ≤ C * ∑ n ∈ Finset.range N, ‖A j n‖ ^ 2 := by
      have : (0 : ℝ) ≤ ∑ n ∈ Finset.range N, ‖A j n‖ ^ 2 :=
        Finset.sum_nonneg fun n _ => by positivity
      exact mul_nonneg hC this
    have h2 : ‖w j‖ ^ 2 ≤ 1 := by nlinarith [norm_nonneg (w j), hw j hj]
    calc ‖w j‖ ^ 2 * (C * ∑ n ∈ Finset.range N, ‖A j n‖ ^ 2)
        ≤ 1 * (C * ∑ n ∈ Finset.range N, ‖A j n‖ ^ 2) :=
          mul_le_mul_of_nonneg_right h2 h1
      _ = C * ∑ n ∈ Finset.range N, ‖A j n‖ ^ 2 := one_mul _
      _ ≤ C * B := mul_le_mul_of_nonneg_left (hB j hj) hC
  have hsum : ∑ j ∈ Finset.range J, ‖w j‖ ^ 2 * (C * ∑ n ∈ Finset.range N, ‖A j n‖ ^ 2)
      ≤ (J : ℝ) * (C * B) := by
    have := Finset.sum_le_sum hterm
    simpa [Finset.sum_const, Finset.card_range, nsmul_eq_mul] using this
  calc ∑ f ∈ S, ‖L f‖ ^ 2
      ≤ (J : ℝ) * ∑ j ∈ Finset.range J,
          ‖w j‖ ^ 2 * (C * ∑ n ∈ Finset.range N, ‖A j n‖ ^ 2) :=
        secondMoment_le S lam N C hLS J w A L hL
    _ ≤ (J : ℝ) * ((J : ℝ) * (C * B)) := mul_le_mul_of_nonneg_left hsum (by positivity)
    _ = (J : ℝ) ^ 2 * C * B := by ring

/-- Positivity of the Petersson large sieve constant, derived rather than assumed. -/
theorem quasiOrthogonal_const_nonneg (S : Finset ι) (lam : ι → ℕ → ℂ) (N : ℕ) (D e : ℝ)
    (hN : 1 ≤ N) (h : QuasiOrthogonal S lam N D e) : 0 ≤ D + e * N := by
  have hLS := largeSieve_of_quasiOrthogonal S lam N D e h
  have hdiag := diagonal_le_of_largeSieve S lam N (D + e * N) hLS (n₀ := 0) hN
  exact le_trans (Finset.sum_nonneg fun f _ => by positivity) hdiag

/-- **Flagship theorem: the second moment of the convoluted central values in the `k`-aspect.**

`lam f n` are the Hecke eigenvalues of the Asai lift `As(f)`, `mu n` those of the fixed
Hecke–Maass form `φ`, so `lam f n * mu n` are the Rankin–Selberg coefficients of
`As(f) × φ`.  Given

* Petersson quasi-orthogonality of the Asai eigenvalues with diagonal `D ≤ c₁ k` and
  off-diagonal error `e` satisfying `eN ≤ c₂ k`;
* the Hecke bound `|mu n| ≤ ν` for `φ`;
* an approximate functional equation with `J ≥ 1` blocks of length `N ≥ 1`, archimedean
  weights `≤ 1` and coefficient mass `≤ B`,

the second moment of the central values obeys

`∑_f |L f|² ≤ (c₁ + c₂) · ν² · J² · B · k`.

No positivity is assumed on `D`, `e`, `B` or `k`; all of it is derived. -/
theorem asai_second_moment_k_aspect (S : Finset ι) (lam : ι → ℕ → ℂ) (mu : ℕ → ℂ)
    (N J : ℕ) (hN : 1 ≤ N) (hJ : 1 ≤ J) (D e nu k c₁ c₂ B : ℝ)
    (hQO : QuasiOrthogonal S lam N D e) (hD : D ≤ c₁ * k) (heN : e * N ≤ c₂ * k)
    (hnu0 : 0 ≤ nu) (hmu : ∀ n ∈ Finset.range N, ‖mu n‖ ≤ nu)
    (w : ℕ → ℂ) (A : ℕ → ℕ → ℂ) (L : ι → ℂ)
    (hL : AFE S (fun f n => lam f n * mu n) N J w A L)
    (hw : ∀ j ∈ Finset.range J, ‖w j‖ ≤ 1)
    (hB : ∀ j ∈ Finset.range J, ∑ n ∈ Finset.range N, ‖A j n‖ ^ 2 ≤ B) :
    ∑ f ∈ S, ‖L f‖ ^ 2 ≤ (c₁ + c₂) * nu ^ 2 * (J : ℝ) ^ 2 * B * k := by
  -- Step 1: Petersson ⇒ large sieve for the Asai eigenvalues.
  have hLS := largeSieve_of_quasiOrthogonal S lam N D e hQO
  have hC0 : 0 ≤ D + e * N := quasiOrthogonal_const_nonneg S lam N D e hN hQO
  -- Step 2: twist by the eigenvalues of `φ`.
  have hLS' : LargeSieve S (fun f n => lam f n * mu n) N ((D + e * N) * nu ^ 2) :=
    largeSieve_twist S lam N (D + e * N) mu nu hC0 hnu0 hLS hmu
  have hC0' : 0 ≤ (D + e * N) * nu ^ 2 := by positivity
  -- Step 3: feed in the approximate functional equation.
  have hmain := secondMoment_uniform S (fun f n => lam f n * mu n) N ((D + e * N) * nu ^ 2)
    hC0' hLS' J w A L B hL hw hB
  -- Step 4: `B ≥ 0` (nonempty block set) and the arithmetic comparison.
  have hB0 : 0 ≤ B := by
    have h0 : (0 : ℕ) ∈ Finset.range J := Finset.mem_range.mpr hJ
    exact le_trans (Finset.sum_nonneg fun n _ => by positivity) (hB 0 h0)
  have hcmp : (D + e * N) ≤ (c₁ + c₂) * k := by linarith
  have hfac : (0 : ℝ) ≤ (J : ℝ) ^ 2 * B * nu ^ 2 := by positivity
  calc ∑ f ∈ S, ‖L f‖ ^ 2 ≤ (J : ℝ) ^ 2 * ((D + e * N) * nu ^ 2) * B := hmain
    _ = (D + e * N) * ((J : ℝ) ^ 2 * B * nu ^ 2) := by ring
    _ ≤ ((c₁ + c₂) * k) * ((J : ℝ) ^ 2 * B * nu ^ 2) := mul_le_mul_of_nonneg_right hcmp hfac
    _ = (c₁ + c₂) * nu ^ 2 * (J : ℝ) ^ 2 * B * k := by ring

/-- **The saving over the trivial bound.**  Running the same AFE argument through the trivial
(Cauchy–Schwarz) large sieve constant gives a bound worse by a factor `≍ N/4`: the trivial
constant is at least `(N/4)·(D + eN)` under the Kloosterman-controlled regime `eN ≤ D`.  Hence
`asai_second_moment_k_aspect` is non-trivial precisely there. -/
theorem secondMoment_saving (S : Finset ι) (lam : ι → ℕ → ℂ) (N : ℕ) (D e : ℝ)
    (hQO : QuasiOrthogonal S lam N D e) (he0 : 0 ≤ e) (heN : e * N ≤ D) (hN : 4 ≤ (N : ℝ)) :
    (D + e * N) * ((N : ℝ) / 4) ≤ ∑ f ∈ S, ∑ n ∈ Finset.range N, ‖lam f n‖ ^ 2 :=
  largeSieve_gain S lam N D e hQO he0 heN hN

/-- **Sharpness and non-vacuity of the flagship bound.**  There is a concrete system
satisfying *every* hypothesis of `asai_second_moment_k_aspect` with the parameters
`N = 2`, `J = 1`, `D = 1`, `e = 0`, `nu = 1`, `k = 1`, `c₁ = 1`, `c₂ = 0`, `B = 2`, for which
the conclusion holds with **equality**.  Hence the bound of the flagship theorem cannot be
improved as a function of these parameters, and the hypothesis package is satisfiable by a
nonzero system (so the theorem is not vacuous). -/
theorem flagship_bound_sharp :
    ∃ (lam : Fin 2 → ℕ → ℂ) (mu : ℕ → ℂ) (w : ℕ → ℂ) (A : ℕ → ℕ → ℂ) (L : Fin 2 → ℂ),
      QuasiOrthogonal (Finset.univ : Finset (Fin 2)) lam 2 1 0 ∧
      (1 : ℝ) ≤ 1 * 1 ∧ (0 : ℝ) * 2 ≤ 0 * 1 ∧
      (∀ n ∈ Finset.range 2, ‖mu n‖ ≤ 1) ∧
      AFE (Finset.univ : Finset (Fin 2)) (fun f n => lam f n * mu n) 2 1 w A L ∧
      (∀ j ∈ Finset.range 1, ‖w j‖ ≤ 1) ∧
      (∀ j ∈ Finset.range 1, ∑ n ∈ Finset.range 2, ‖A j n‖ ^ 2 ≤ 2) ∧
      (∑ f ∈ (Finset.univ : Finset (Fin 2)), ‖L f‖ ^ 2)
        = ((1 : ℝ) + 0) * (1 : ℝ) ^ 2 * ((1 : ℕ) : ℝ) ^ 2 * 2 * 1 := by
  classical
  refine ⟨fun f n => if (n : ℕ) = (f : ℕ) then 1 else 0, fun _ => 1,
    fun _ => 1, fun _ n => if n < 2 then 1 else 0, fun _ => 1, ?_, by norm_num, by norm_num,
    ?_, ?_, ?_, ?_, ?_⟩
  · intro m hm n hn
    fin_cases hm <;> fin_cases hn <;> simp
  · intro n _; simp
  · intro f _
    fin_cases f <;> simp [linForm]
  · intro j _; simp
  · intro j _; simp [Finset.sum_range_succ]; norm_num
  · simp

end AsaiSecondMoment