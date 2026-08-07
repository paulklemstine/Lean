/-
# Periodic Gram matrices and large-value consequences of the Asai second moment

Two further layers on top of `Novelty.AsaiLargeSieve`, `Novelty.AsaiLargeSieveGram` and
`Novelty.AsaiSecondMoment`.

**1. The `k + N/q` shape of the large sieve constant.**  In the Asai/Petersson setting the
correlation sums `∑_f λ_f(m) conj(λ_f(n))` are (up to the Kloosterman term) supported on
`m ≡ n` modulo the level/conductor parameter, and the true large sieve constant is therefore
of the shape *diagonal times the number of congruent pairs*, i.e. `D·(1 + N/q)`, rather than
`D + eN`.  `AsaiLargeSieve.largeSieve_of_periodic_gram` proves exactly this, and it is where
the `N`-aspect of the paper's `(kD + N^{1+ε})`-type constant comes from.  The combinatorial
core is `AsaiLargeSieve.card_congruence_class_le`: a residue class modulo `q` meets `[0,N)` in
at most `N/q + 1` points.

**2. Large values of central `L`-values.**  A second moment bound immediately controls the
number of forms with a large central value (Chebyshev), giving the standard "almost all
`As(f) × φ` have small central value" consequence:
`#{f : |L f| ≥ T} ≤ (c₁+c₂) ν² J² B k / T²`.

Main results:

* `AsaiLargeSieve.card_congruence_class_le`
* `AsaiLargeSieve.largeSieve_of_periodic_gram`
* `AsaiLargeSieve.secondMoment_periodic` — the `D·(1+N/q)` second moment.
* `AsaiLargeSieve.card_large_values_le` — Chebyshev for the moment.
* `AsaiLargeSieve.card_large_central_values` — the large-value bound under the full
  hypothesis package of `AsaiSecondMoment.asai_second_moment_k_aspect`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the two error shapes appearing in large sieve inequalities,
`D + eN` (uniform error) and `D(1 + N/q)` (periodic support), are both instances of the Schur
row bound; and the second, not the first, is what governs the `N`-aspect of the Asai constant.

Experiment (Experimenter): both are now derived from `largeSieve_of_schur`.  The periodic
case needed the counting lemma, proved by the injection `n ↦ n / q` from a residue class in
`[0,N)` into `[0, N/q]`; the reconstruction `n = q(n/q) + n%q` makes the injectivity an `omega`
computation.  The Chebyshev step needs no positivity beyond `T > 0`.

Analysis (Analyst): the comparison of the two criteria is instructive.  For `q ≥ N` the
periodic bound gives `2D` while the uniform criterion gives `D + eN`; for `q` small the
periodic bound degrades linearly in `N/q`, matching the classical `N + q²`-type constants.
So the abstract framework reproduces both regimes, which is evidence that the Schur row bound
is the correct axiom to isolate from the Petersson formula.

Critique (Critic): the Chebyshev corollary is stated multiplicatively
(`card · T² ≤ bound`) rather than as `card ≤ bound / T²` to avoid any hidden division-by-zero
convention; with `T > 0` the two are equivalent, and the multiplicative form is also correct
when the bound is negative (in which case the hypothesis set is empty).
-/
import Mathlib
import Novelty.AsaiLargeSieve
import Novelty.AsaiLargeSieveGram
import Novelty.AsaiSecondMoment

open Finset Complex

namespace AsaiLargeSieve

variable {ι : Type*}

/-! ## The periodic criterion -/

/-- A residue class modulo `q` meets `[0, N)` in at most `N / q + 1` points. -/
theorem card_congruence_class_le (N q m : ℕ) :
    (((Finset.range N).filter (fun n => m ≡ n [MOD q])).card : ℕ) ≤ N / q + 1 := by
  classical
  have h : ((Finset.range N).filter (fun n => m ≡ n [MOD q])).card
      ≤ (Finset.range (N / q + 1)).card := by
    refine Finset.card_le_card_of_injOn (fun n => n / q) ?_ ?_
    · intro n hn
      simp only [Finset.coe_filter, Set.mem_setOf_eq, Finset.mem_range, Finset.mem_coe] at hn ⊢
      have : n / q ≤ N / q := Nat.div_le_div_right (le_of_lt hn.1)
      omega
    · intro x hx y hy hxy
      simp only [Finset.coe_filter, Set.mem_setOf_eq, Finset.mem_range] at hx hy
      have h1 : x % q = y % q := by
        have h2 := hx.2; have h3 := hy.2
        unfold Nat.ModEq at h2 h3
        omega
      have hx' := Nat.div_add_mod x q
      have hy' := Nat.div_add_mod y q
      simp only at hxy
      rw [hxy] at hx'
      omega
  simpa using h

/-- **Periodic Gram criterion.**  If the correlation sums vanish unless `m ≡ n (mod q)` and are
bounded by `D` in absolute value, then `D · (1 + N/q)` is an admissible large sieve constant.
This is the `k + N/q` shape of the Asai large sieve. -/
theorem largeSieve_of_periodic_gram (S : Finset ι) (lam : ι → ℕ → ℂ) (N q : ℕ) (D : ℝ)
    (hD : 0 ≤ D)
    (hoff : ∀ m ∈ Finset.range N, ∀ n ∈ Finset.range N, ¬ (m ≡ n [MOD q]) → gram S lam m n = 0)
    (hbnd : ∀ m ∈ Finset.range N, ∀ n ∈ Finset.range N, ‖gram S lam m n‖ ≤ D) :
    LargeSieve S lam N (D * ((N : ℝ) / q + 1)) := by
  classical
  refine largeSieve_of_schur S lam N _ ?_
  intro m hm
  have hsupp : ∑ n ∈ Finset.range N, ‖gram S lam m n‖
      = ∑ n ∈ (Finset.range N).filter (fun n => m ≡ n [MOD q]), ‖gram S lam m n‖ := by
    refine (Finset.sum_subset (Finset.filter_subset _ _) ?_).symm
    intro n hn hnot
    have hnc : ¬ (m ≡ n [MOD q]) := by
      intro hc
      exact hnot (Finset.mem_filter.mpr ⟨hn, hc⟩)
    rw [hoff m hm n hn hnc, norm_zero]
  rw [hsupp]
  have hcard := card_congruence_class_le N q m
  have hstep : ∑ n ∈ (Finset.range N).filter (fun n => m ≡ n [MOD q]), ‖gram S lam m n‖
      ≤ (((Finset.range N).filter (fun n => m ≡ n [MOD q])).card : ℝ) * D := by
    have : ∀ n ∈ (Finset.range N).filter (fun n => m ≡ n [MOD q]), ‖gram S lam m n‖ ≤ D := by
      intro n hn
      exact hbnd m hm n (Finset.mem_filter.mp hn).1
    calc ∑ n ∈ (Finset.range N).filter (fun n => m ≡ n [MOD q]), ‖gram S lam m n‖
        ≤ ∑ _n ∈ (Finset.range N).filter (fun n => m ≡ n [MOD q]), D :=
          Finset.sum_le_sum this
      _ = (((Finset.range N).filter (fun n => m ≡ n [MOD q])).card : ℝ) * D := by
          rw [Finset.sum_const, nsmul_eq_mul]
  refine hstep.trans ?_
  have hcast : (((Finset.range N).filter (fun n => m ≡ n [MOD q])).card : ℝ)
      ≤ (N : ℝ) / q + 1 := by
    have h1 : (((Finset.range N).filter (fun n => m ≡ n [MOD q])).card : ℝ)
        ≤ ((N / q + 1 : ℕ) : ℝ) := by exact_mod_cast hcard
    refine h1.trans ?_
    push_cast
    have := Nat.cast_div_le (α := ℝ) (m := N) (n := q)
    linarith
  calc (((Finset.range N).filter (fun n => m ≡ n [MOD q])).card : ℝ) * D
      ≤ ((N : ℝ) / q + 1) * D := mul_le_mul_of_nonneg_right hcast hD
    _ = D * ((N : ℝ) / q + 1) := by ring

/-- When `q` divides `N`, each residue class meets `[0,N)` in exactly `N / q` points, and the
`+1` in `card_congruence_class_le` can be dropped. -/
theorem card_congruence_class_le_of_dvd {N q : ℕ} (hdvd : q ∣ N) (m : ℕ) :
    (((Finset.range N).filter (fun n => m ≡ n [MOD q])).card : ℕ) ≤ N / q := by
  classical
  have h : ((Finset.range N).filter (fun n => m ≡ n [MOD q])).card
      ≤ (Finset.range (N / q)).card := by
    refine Finset.card_le_card_of_injOn (fun n => n / q) ?_ ?_
    · intro n hn
      simp only [Finset.coe_filter, Set.mem_setOf_eq, Finset.mem_range, Finset.mem_coe] at hn ⊢
      exact Nat.div_lt_div_of_lt_of_dvd hdvd hn.1
    · intro x hx y hy hxy
      simp only [Finset.coe_filter, Set.mem_setOf_eq, Finset.mem_range] at hx hy
      have h1 : x % q = y % q := by
        have h2 := hx.2; have h3 := hy.2
        unfold Nat.ModEq at h2 h3
        omega
      have hx' := Nat.div_add_mod x q
      have hy' := Nat.div_add_mod y q
      simp only at hxy
      rw [hxy] at hx'
      omega
  simpa using h

/-- **Sharpened periodic criterion** when `q ∣ N`: the admissible constant is `D · (N/q)`,
without the `+1` loss.  Numerically (see `ComputationalEvidence.md`) this is attained: for the
two-character system mod `2` with `N = 4` and `D = 2` the extremal ratio is exactly `4`. -/
theorem largeSieve_of_periodic_gram_dvd (S : Finset ι) (lam : ι → ℕ → ℂ) (N q : ℕ) (D : ℝ)
    (hdvd : q ∣ N) (hD : 0 ≤ D)
    (hoff : ∀ m ∈ Finset.range N, ∀ n ∈ Finset.range N, ¬ (m ≡ n [MOD q]) → gram S lam m n = 0)
    (hbnd : ∀ m ∈ Finset.range N, ∀ n ∈ Finset.range N, ‖gram S lam m n‖ ≤ D) :
    LargeSieve S lam N (D * ((N / q : ℕ) : ℝ)) := by
  classical
  refine largeSieve_of_schur S lam N _ ?_
  intro m hm
  have hsupp : ∑ n ∈ Finset.range N, ‖gram S lam m n‖
      = ∑ n ∈ (Finset.range N).filter (fun n => m ≡ n [MOD q]), ‖gram S lam m n‖ := by
    refine (Finset.sum_subset (Finset.filter_subset _ _) ?_).symm
    intro n hn hnot
    have hnc : ¬ (m ≡ n [MOD q]) := fun hc => hnot (Finset.mem_filter.mpr ⟨hn, hc⟩)
    rw [hoff m hm n hn hnc, norm_zero]
  rw [hsupp]
  have hstep : ∑ n ∈ (Finset.range N).filter (fun n => m ≡ n [MOD q]), ‖gram S lam m n‖
      ≤ (((Finset.range N).filter (fun n => m ≡ n [MOD q])).card : ℝ) * D := by
    have hpt : ∀ n ∈ (Finset.range N).filter (fun n => m ≡ n [MOD q]),
        ‖gram S lam m n‖ ≤ D := fun n hn => hbnd m hm n (Finset.mem_filter.mp hn).1
    calc ∑ n ∈ (Finset.range N).filter (fun n => m ≡ n [MOD q]), ‖gram S lam m n‖
        ≤ ∑ _n ∈ (Finset.range N).filter (fun n => m ≡ n [MOD q]), D := Finset.sum_le_sum hpt
      _ = (((Finset.range N).filter (fun n => m ≡ n [MOD q])).card : ℝ) * D := by
          rw [Finset.sum_const, nsmul_eq_mul]
  refine hstep.trans ?_
  have hcast : (((Finset.range N).filter (fun n => m ≡ n [MOD q])).card : ℝ) ≤ ((N / q : ℕ) : ℝ) := by
    exact_mod_cast card_congruence_class_le_of_dvd hdvd m
  calc (((Finset.range N).filter (fun n => m ≡ n [MOD q])).card : ℝ) * D
      ≤ ((N / q : ℕ) : ℝ) * D := mul_le_mul_of_nonneg_right hcast hD
    _ = D * ((N / q : ℕ) : ℝ) := by ring

/-- The second moment under the periodic criterion: `J² · D · (1 + N/q) · B`. -/
theorem secondMoment_periodic (S : Finset ι) (lam : ι → ℕ → ℂ) (N q J : ℕ) (D B : ℝ)
    (hD : 0 ≤ D)
    (hoff : ∀ m ∈ Finset.range N, ∀ n ∈ Finset.range N, ¬ (m ≡ n [MOD q]) → gram S lam m n = 0)
    (hbnd : ∀ m ∈ Finset.range N, ∀ n ∈ Finset.range N, ‖gram S lam m n‖ ≤ D)
    (w : ℕ → ℂ) (A : ℕ → ℕ → ℂ) (L : ι → ℂ)
    (hL : AsaiSecondMoment.AFE S lam N J w A L)
    (hw : ∀ j ∈ Finset.range J, ‖w j‖ ≤ 1)
    (hB : ∀ j ∈ Finset.range J, ∑ n ∈ Finset.range N, ‖A j n‖ ^ 2 ≤ B) :
    ∑ f ∈ S, ‖L f‖ ^ 2 ≤ (J : ℝ) ^ 2 * (D * ((N : ℝ) / q + 1)) * B := by
  refine AsaiSecondMoment.secondMoment_uniform S lam N _ ?_
    (largeSieve_of_periodic_gram S lam N q D hD hoff hbnd) J w A L B hL hw hB
  have : (0 : ℝ) ≤ (N : ℝ) / q + 1 := by positivity
  exact mul_nonneg hD this

/-! ## Large values -/

open scoped Classical in
/-- **Chebyshev for the second moment.**  A bound `M` on the second moment bounds the number
of members of the family whose value exceeds `T`. -/
theorem card_large_values_le (S : Finset ι) (L : ι → ℂ) (T M : ℝ) (hT : 0 ≤ T)
    (hM : ∑ f ∈ S, ‖L f‖ ^ 2 ≤ M) :
    ((S.filter (fun f => T ≤ ‖L f‖)).card : ℝ) * T ^ 2 ≤ M := by
  have h1 : ∑ f ∈ S.filter (fun f => T ≤ ‖L f‖), T ^ 2
      ≤ ∑ f ∈ S.filter (fun f => T ≤ ‖L f‖), ‖L f‖ ^ 2 := by
    refine Finset.sum_le_sum fun f hf => ?_
    have hTf : T ≤ ‖L f‖ := (Finset.mem_filter.mp hf).2
    have hT0 : 0 ≤ ‖L f‖ := norm_nonneg _
    nlinarith
  have h2 : ∑ f ∈ S.filter (fun f => T ≤ ‖L f‖), ‖L f‖ ^ 2 ≤ ∑ f ∈ S, ‖L f‖ ^ 2 :=
    Finset.sum_le_sum_of_subset_of_nonneg (Finset.filter_subset _ _)
      (fun f _ _ => by positivity)
  have h3 : ((S.filter (fun f => T ≤ ‖L f‖)).card : ℝ) * T ^ 2
      = ∑ _f ∈ S.filter (fun f => T ≤ ‖L f‖), T ^ 2 := by
    rw [Finset.sum_const, nsmul_eq_mul]
  rw [h3]
  linarith

open scoped Classical in
/-- **Large values of the central `L`-values of `As(f) × φ`.**  Under the hypotheses of
`AsaiSecondMoment.asai_second_moment_k_aspect`, the number of forms in the family whose
central value exceeds `T` is at most `(c₁+c₂) ν² J² B k / T²`. -/
theorem card_large_central_values (S : Finset ι) (lam : ι → ℕ → ℂ) (mu : ℕ → ℂ)
    (N J : ℕ) (hN : 1 ≤ N) (hJ : 1 ≤ J) (D e nu k c₁ c₂ B T : ℝ) (hT : 0 ≤ T)
    (hQO : QuasiOrthogonal S lam N D e) (hD : D ≤ c₁ * k) (heN : e * N ≤ c₂ * k)
    (hnu0 : 0 ≤ nu) (hmu : ∀ n ∈ Finset.range N, ‖mu n‖ ≤ nu)
    (w : ℕ → ℂ) (A : ℕ → ℕ → ℂ) (L : ι → ℂ)
    (hL : AsaiSecondMoment.AFE S (fun f n => lam f n * mu n) N J w A L)
    (hw : ∀ j ∈ Finset.range J, ‖w j‖ ≤ 1)
    (hB : ∀ j ∈ Finset.range J, ∑ n ∈ Finset.range N, ‖A j n‖ ^ 2 ≤ B) :
    ((S.filter (fun f => T ≤ ‖L f‖)).card : ℝ) * T ^ 2
      ≤ (c₁ + c₂) * nu ^ 2 * (J : ℝ) ^ 2 * B * k :=
  card_large_values_le S L T _ hT
    (AsaiSecondMoment.asai_second_moment_k_aspect S lam mu N J hN hJ D e nu k c₁ c₂ B
      hQO hD heN hnu0 hmu w A L hL hw hB)

end AsaiLargeSieve