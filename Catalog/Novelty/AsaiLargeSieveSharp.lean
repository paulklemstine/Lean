/-
# Sharpening the Asai large sieve framework

This file continues the formalisation of the analytic skeleton of the paper
**"On the Second Moment of `L(1/2, As(f) × φ)`"** begun in `Novelty.AsaiLargeSieve`,
`Novelty.AsaiLargeSieveGram`, `Novelty.AsaiSecondMoment` and
`Novelty.AsaiMomentApplications`.  It settles one of the conjectures recorded in
`FUTURE_DIRECTIONS.md` and makes definite progress on a second.

## Conjecture C2 (settled here)

`AsaiLargeSieve.largeSieve_of_periodic_gram` gives the admissible constant `D · (N/q + 1)`
for a Gram matrix supported on `m ≡ n (mod q)` with entries bounded by `D`, and
`largeSieve_of_periodic_gram_dvd` improves this to `D · (N/q)` when `q ∣ N`.  Conjecture C2
asserted that the `+1` is an artefact of the crude counting lemma and that the correct
constant is always `D · ⌈N/q⌉`.  This is proved here:

* `card_congruence_class_le_ceilDiv` — a residue class mod `q` meets `[0,N)` in at most
  `⌈N/q⌉ = (N + q - 1)/q` points (`q ≥ 1`), with `card_congruence_class_ceil_attained`
  an explicit instance showing that this count is attained, so the counting lemma is optimal;
* `largeSieve_of_periodic_gram_ceil` — the resulting large sieve constant `D · ⌈N/q⌉`;
* `ceilDiv_le_div_succ`, `ceilDiv_eq_div_of_dvd`, `ceilDiv_lt_real_of_not_dvd` — the new
  constant is never worse than either previous one, coincides with the divisible-case
  constant when `q ∣ N`, and is *strictly* better than `D · (N/q + 1)` whenever `q ∤ N`;
* `secondMoment_periodic_ceil` — the corresponding second-moment bound.

## Conjecture C1 (partial resolution)

C1 asserted `C_opt ≤ K_Schur ≤ 2 · C_opt`.  The first inequality is
`AsaiLargeSieve.largeSieve_of_schur`.  For the reverse direction we prove here the first
unconditional bound of the right shape:

* `norm_gram_le_geom_mean` — the Gram matrix satisfies the Cauchy–Schwarz entry bound
  `‖G m n‖ ≤ √(G m m) · √(G n n)`; this is positive semidefiniteness of `G`, exactly the
  structural input C1 predicted was the missing ingredient;
* `norm_gram_le_of_diag_le` and `schur_row_le_of_largeSieve` — consequently
  `K_Schur ≤ N · C_opt` for *every* admissible constant `C_opt`;
* `schur_row_le_two_mul_largeSieve_of_dominant` — and if the Gram matrix is diagonally
  dominant on `[0,N)` (the off-diagonal `ℓ¹`-mass of each row is at most its diagonal entry,
  which is the quasi-orthogonality regime `eN ≤ D`), then the conjectured constant is
  correct: `K_Schur ≤ 2 · C_opt`.

So the Schur constant is trapped between `C_opt` and `N · C_opt` in general, and between
`C_opt` and `2 · C_opt` under diagonal dominance; C1 for arbitrary Gram matrices remains
open.

Lab notes (Experimenter).  Counting check for `N = 5`, `q = 2`: the class of `0` in `[0,5)` is
`{0,2,4}`, of size `3 = ⌈5/2⌉`, so the counting lemma is attained.  The gain over the old
criterion is visible in the *real-valued* constants: for `N = 7`, `q = 2` the old constant is
`D · (7/2 + 1) = 4.5 D` while the new one is `D · ⌈7/2⌉ = 4 D`; `ceilDiv_lt_real_of_not_dvd`
proves that a strict gain occurs for every `q ∤ N`.

Critique (Critic).  Is `largeSieve_of_periodic_gram_ceil` vacuous?  No: it strictly implies
both earlier periodic criteria (`ceilDiv_le_div_succ`, `ceilDiv_eq_div_of_dvd`) and its
counting step is attained (`card_congruence_class_ceil_attained`).  Is
`schur_row_le_of_largeSieve` trivial?  No: it goes through the positive semidefiniteness of
the Gram matrix via `AsaiLargeSieve.cauchy_schwarz_sq`; for a general matrix with small
diagonal the off-diagonal entries are completely unconstrained, so no such bound holds.
-/
import Mathlib
import Novelty.AsaiLargeSieve
import Novelty.AsaiLargeSieveGram
import Novelty.AsaiSecondMoment

open Finset Complex

namespace AsaiLargeSieve

variable {ι : Type*}

/-! ## Positive semidefiniteness of the Gram matrix -/

/-- The diagonal of the Gram matrix is the (real, nonnegative) `ℓ²`-mass of the column. -/
theorem gram_diag_eq (S : Finset ι) (lam : ι → ℕ → ℂ) (n : ℕ) :
    gram S lam n n = ((∑ f ∈ S, ‖lam f n‖ ^ 2 : ℝ) : ℂ) := by
  rw [gram]
  push_cast
  exact (Finset.sum_congr rfl fun f _ => by rw [sq_ofReal_norm]).symm

/-- **Cauchy–Schwarz for the Gram matrix.**  Off-diagonal entries are dominated by the
geometric mean of the two corresponding diagonal entries: this is positive semidefiniteness
of `G` in its most usable elementary form. -/
theorem norm_gram_le_geom_mean (S : Finset ι) (lam : ι → ℕ → ℂ) (m n : ℕ) :
    ‖gram S lam m n‖
      ≤ Real.sqrt (∑ f ∈ S, ‖lam f m‖ ^ 2) * Real.sqrt (∑ f ∈ S, ‖lam f n‖ ^ 2) := by
  have hm : (0 : ℝ) ≤ ∑ f ∈ S, ‖lam f m‖ ^ 2 := Finset.sum_nonneg fun f _ => by positivity
  have hn : (0 : ℝ) ≤ ∑ f ∈ S, ‖lam f n‖ ^ 2 := Finset.sum_nonneg fun f _ => by positivity
  have hcs : ‖gram S lam m n‖ ^ 2
      ≤ (∑ f ∈ S, ‖lam f m‖ ^ 2) * (∑ f ∈ S, ‖lam f n‖ ^ 2) := by
    have := cauchy_schwarz_sq S (fun f => lam f m) (fun f => lam f n)
    simpa [gram] using this
  have hsqrt : ‖gram S lam m n‖
      ≤ Real.sqrt ((∑ f ∈ S, ‖lam f m‖ ^ 2) * (∑ f ∈ S, ‖lam f n‖ ^ 2)) :=
    (Real.le_sqrt (norm_nonneg _) (by positivity)).mpr hcs
  rwa [Real.sqrt_mul hm] at hsqrt

/-- If every diagonal entry of the Gram matrix on `[0,N)` is at most `D`, then *every* entry
is at most `D` in absolute value. -/
theorem norm_gram_le_of_diag_le (S : Finset ι) (lam : ι → ℕ → ℂ) (N : ℕ) (D : ℝ)
    (hdiag : ∀ n ∈ Finset.range N, ∑ f ∈ S, ‖lam f n‖ ^ 2 ≤ D)
    {m n : ℕ} (hm : m ∈ Finset.range N) (hn : n ∈ Finset.range N) :
    ‖gram S lam m n‖ ≤ D := by
  have hm0 : (0 : ℝ) ≤ ∑ f ∈ S, ‖lam f m‖ ^ 2 := Finset.sum_nonneg fun f _ => by positivity
  have hD : 0 ≤ D := hm0.trans (hdiag m hm)
  refine (norm_gram_le_geom_mean S lam m n).trans ?_
  have h1 : Real.sqrt (∑ f ∈ S, ‖lam f m‖ ^ 2) ≤ Real.sqrt D :=
    Real.sqrt_le_sqrt (hdiag m hm)
  have h2 : Real.sqrt (∑ f ∈ S, ‖lam f n‖ ^ 2) ≤ Real.sqrt D :=
    Real.sqrt_le_sqrt (hdiag n hn)
  calc Real.sqrt (∑ f ∈ S, ‖lam f m‖ ^ 2) * Real.sqrt (∑ f ∈ S, ‖lam f n‖ ^ 2)
      ≤ Real.sqrt D * Real.sqrt D :=
        mul_le_mul h1 h2 (Real.sqrt_nonneg _) (Real.sqrt_nonneg _)
    _ = D := Real.mul_self_sqrt hD

/-- **Towards C1: the Schur constant is at most `N` times any admissible large sieve
constant.**  Combined with `largeSieve_of_schur` (`C_opt ≤ K_Schur`) this traps the Schur
constant: `C_opt ≤ K_Schur ≤ N · C_opt`. -/
theorem schur_row_le_of_largeSieve (S : Finset ι) (lam : ι → ℕ → ℂ) (N : ℕ) (C : ℝ)
    (h : LargeSieve S lam N C) :
    ∀ m ∈ Finset.range N, ∑ n ∈ Finset.range N, ‖gram S lam m n‖ ≤ (N : ℝ) * C := by
  intro m hm
  have hdiag : ∀ n ∈ Finset.range N, ∑ f ∈ S, ‖lam f n‖ ^ 2 ≤ C := fun n hn =>
    diagonal_le_of_largeSieve S lam N C h (Finset.mem_range.mp hn)
  have hpt : ∀ n ∈ Finset.range N, ‖gram S lam m n‖ ≤ C := fun n hn =>
    norm_gram_le_of_diag_le S lam N C hdiag hm hn
  calc ∑ n ∈ Finset.range N, ‖gram S lam m n‖
      ≤ ∑ _n ∈ Finset.range N, C := Finset.sum_le_sum hpt
    _ = (N : ℝ) * C := by rw [Finset.sum_const, Finset.card_range, nsmul_eq_mul]

/-! ## Conjecture C2: the ceiling form of the periodic criterion -/

/-- **Optimal congruence-class count.**  For `q ≥ 1` a residue class modulo `q` meets `[0,N)`
in at most `⌈N/q⌉ = (N + q - 1)/q` points.  This removes the `+1` loss of
`card_congruence_class_le`. -/
theorem card_congruence_class_le_ceilDiv {q : ℕ} (hq : 0 < q) (N m : ℕ) :
    (((Finset.range N).filter (fun n => m ≡ n [MOD q])).card : ℕ) ≤ (N + q - 1) / q := by
  classical
  rcases Nat.eq_zero_or_pos N with hN | hN
  · subst hN; simp
  have hceil : (N + q - 1) / q = (N - 1) / q + 1 := by
    have hrw : N + q - 1 = (N - 1) + q := by omega
    rw [hrw, Nat.add_div_right _ hq]
  have h : ((Finset.range N).filter (fun n => m ≡ n [MOD q])).card
      ≤ (Finset.range ((N - 1) / q + 1)).card := by
    refine Finset.card_le_card_of_injOn (fun n => n / q) ?_ ?_
    · intro n hn
      simp only [Finset.coe_filter, Set.mem_setOf_eq, Finset.mem_range, Finset.mem_coe] at hn ⊢
      have hle : n / q ≤ (N - 1) / q := Nat.div_le_div_right (by omega)
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
  rw [hceil]
  simpa using h

/-- The counting lemma is attained: the class of `0` modulo `2` inside `[0,5)` is `{0,2,4}`,
of size exactly `⌈5/2⌉ = 3`. -/
theorem card_congruence_class_ceil_attained :
    (((Finset.range 5).filter (fun n => 0 ≡ n [MOD 2])).card : ℕ) = (5 + 2 - 1) / 2 := by
  decide

/-- The ceiling constant never exceeds the constant `N/q + 1` of `card_congruence_class_le`. -/
theorem ceilDiv_le_div_succ (N q : ℕ) : (N + q - 1) / q ≤ N / q + 1 := by
  rcases Nat.eq_zero_or_pos q with hq | hq
  · subst hq; simp
  have : (N + q - 1) / q ≤ (N + q) / q := Nat.div_le_div_right (by omega)
  rw [Nat.add_div_right _ hq] at this
  exact this

/-- When `q ∣ N` the ceiling constant equals the sharpened divisible-case constant `N/q`. -/
theorem ceilDiv_eq_div_of_dvd {N q : ℕ} (hq : 0 < q) (hdvd : q ∣ N) :
    (N + q - 1) / q = N / q := by
  obtain ⟨t, rfl⟩ := hdvd
  rcases Nat.eq_zero_or_pos t with ht | ht
  · subst ht
    simp only [Nat.mul_zero, Nat.zero_add, Nat.zero_div]
    exact Nat.div_eq_of_lt (by omega)
  obtain ⟨s, rfl⟩ : ∃ s, t = s + 1 := ⟨t - 1, by omega⟩
  have hrw : q * (s + 1) + q - 1 = q * (s + 1) + (q - 1) := by omega
  rw [hrw, Nat.mul_add_div hq, Nat.div_eq_of_lt (by omega), Nat.mul_div_cancel_left _ hq]

/-- Whenever `q ∤ N` the ceiling constant is *strictly* smaller than the real number
`N/q + 1` appearing in `largeSieve_of_periodic_gram`, so the new criterion is a genuine
improvement and not a restatement. -/
theorem ceilDiv_lt_real_of_not_dvd {N q : ℕ} (hq : 0 < q) (hnd : ¬ q ∣ N) :
    (((N + q - 1) / q : ℕ) : ℝ) < (N : ℝ) / q + 1 := by
  have hqR : (0 : ℝ) < q := by exact_mod_cast hq
  have hmod : N % q ≠ 0 := fun h => hnd (Nat.dvd_of_mod_eq_zero h)
  have hN : 0 < N := by
    rcases Nat.eq_zero_or_pos N with h | h
    · exact absurd (by simp [h]) hmod
    · exact h
  have hceil : (N + q - 1) / q = (N - 1) / q + 1 := by
    have hrw : N + q - 1 = (N - 1) + q := by omega
    rw [hrw, Nat.add_div_right _ hq]
  have hdiv : (N - 1) / q = N / q := by
    have h1 := Nat.div_add_mod N q
    have hlt : N % q < q := Nat.mod_lt _ hq
    have hpos : 0 < N % q := Nat.pos_of_ne_zero hmod
    have e : N - 1 = q * (N / q) + (N % q - 1) := by omega
    have hz : (N % q - 1) / q = 0 := Nat.div_eq_of_lt (by omega)
    rw [e, Nat.mul_add_div hq, hz, Nat.add_zero]
  rw [hceil]
  push_cast
  rw [hdiv]
  have hstrict : ((N / q : ℕ) : ℝ) < (N : ℝ) / q := by
    rw [lt_div_iff₀ hqR]
    have h1 := Nat.div_add_mod N q
    have hpos : 0 < N % q := Nat.pos_of_ne_zero hmod
    have : (q : ℝ) * ((N / q : ℕ) : ℝ) < (N : ℝ) := by
      have hcast : ((q * (N / q) : ℕ) : ℝ) < (N : ℝ) := by
        exact_mod_cast (by omega : q * (N / q) < N)
      push_cast at hcast
      linarith
    linarith
  linarith

/-- **Conjecture C2, proved.**  If the correlation sums vanish unless `m ≡ n (mod q)` and are
bounded by `D`, then `D · ⌈N/q⌉` is an admissible large sieve constant.  By
`ceilDiv_le_div_succ` and `ceilDiv_eq_div_of_dvd` this is at least as strong as both
`largeSieve_of_periodic_gram` and `largeSieve_of_periodic_gram_dvd`, and by
`ceilDiv_lt_real_of_not_dvd` it is strictly stronger than the former whenever `q ∤ N`. -/
theorem largeSieve_of_periodic_gram_ceil (S : Finset ι) (lam : ι → ℕ → ℂ) (N q : ℕ) (D : ℝ)
    (hq : 0 < q) (hD : 0 ≤ D)
    (hoff : ∀ m ∈ Finset.range N, ∀ n ∈ Finset.range N, ¬ (m ≡ n [MOD q]) → gram S lam m n = 0)
    (hbnd : ∀ m ∈ Finset.range N, ∀ n ∈ Finset.range N, ‖gram S lam m n‖ ≤ D) :
    LargeSieve S lam N (D * (((N + q - 1) / q : ℕ) : ℝ)) := by
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
  have hcast : (((Finset.range N).filter (fun n => m ≡ n [MOD q])).card : ℝ)
      ≤ (((N + q - 1) / q : ℕ) : ℝ) := by
    exact_mod_cast card_congruence_class_le_ceilDiv hq N m
  calc (((Finset.range N).filter (fun n => m ≡ n [MOD q])).card : ℝ) * D
      ≤ (((N + q - 1) / q : ℕ) : ℝ) * D := mul_le_mul_of_nonneg_right hcast hD
    _ = D * (((N + q - 1) / q : ℕ) : ℝ) := by ring

/-- The second moment under the ceiling form of the periodic criterion. -/
theorem secondMoment_periodic_ceil (S : Finset ι) (lam : ι → ℕ → ℂ) (N q J : ℕ) (D B : ℝ)
    (hq : 0 < q) (hD : 0 ≤ D)
    (hoff : ∀ m ∈ Finset.range N, ∀ n ∈ Finset.range N, ¬ (m ≡ n [MOD q]) → gram S lam m n = 0)
    (hbnd : ∀ m ∈ Finset.range N, ∀ n ∈ Finset.range N, ‖gram S lam m n‖ ≤ D)
    (w : ℕ → ℂ) (A : ℕ → ℕ → ℂ) (L : ι → ℂ)
    (hL : AsaiSecondMoment.AFE S lam N J w A L)
    (hw : ∀ j ∈ Finset.range J, ‖w j‖ ≤ 1)
    (hB : ∀ j ∈ Finset.range J, ∑ n ∈ Finset.range N, ‖A j n‖ ^ 2 ≤ B) :
    ∑ f ∈ S, ‖L f‖ ^ 2 ≤ (J : ℝ) ^ 2 * (D * (((N + q - 1) / q : ℕ) : ℝ)) * B := by
  refine AsaiSecondMoment.secondMoment_uniform S lam N _ (by positivity)
    (largeSieve_of_periodic_gram_ceil S lam N q D hq hD hoff hbnd) J w A L B hL hw hB

/-- **Conjecture C1 for diagonally dominant Gram matrices, with the conjectured constant `2`.**
If on `[0,N)` the off-diagonal `ℓ¹`-mass of each row does not exceed the diagonal entry, then
every admissible large sieve constant `C` satisfies `K_Schur ≤ 2 · C`.  Together with
`largeSieve_of_schur` this gives `C_opt ≤ K_Schur ≤ 2 · C_opt` in the diagonally dominant
case, which is exactly the assertion of C1. -/
theorem schur_row_le_two_mul_largeSieve_of_dominant (S : Finset ι) (lam : ι → ℕ → ℂ) (N : ℕ)
    (C : ℝ) (h : LargeSieve S lam N C)
    (hdom : ∀ m ∈ Finset.range N,
      ∑ n ∈ (Finset.range N).erase m, ‖gram S lam m n‖ ≤ ∑ f ∈ S, ‖lam f m‖ ^ 2) :
    ∀ m ∈ Finset.range N, ∑ n ∈ Finset.range N, ‖gram S lam m n‖ ≤ 2 * C := by
  intro m hm
  have hdiag0 : (0 : ℝ) ≤ ∑ f ∈ S, ‖lam f m‖ ^ 2 := Finset.sum_nonneg fun f _ => by positivity
  have hnorm : ‖gram S lam m m‖ = ∑ f ∈ S, ‖lam f m‖ ^ 2 := by
    rw [gram_diag_eq, Complex.norm_real, Real.norm_eq_abs, abs_of_nonneg hdiag0]
  have hsplit : ∑ n ∈ Finset.range N, ‖gram S lam m n‖
      = ∑ n ∈ (Finset.range N).erase m, ‖gram S lam m n‖ + ‖gram S lam m m‖ :=
    (Finset.sum_erase_add _ _ hm).symm
  have hC : ∑ f ∈ S, ‖lam f m‖ ^ 2 ≤ C :=
    diagonal_le_of_largeSieve S lam N C h (Finset.mem_range.mp hm)
  rw [hsplit, hnorm]
  have := hdom m hm
  linarith

end AsaiLargeSieve