/-
# Peeling profiles, stopping times, and the rigidity of the pigeonhole bound

A *peeling process* is the abstract skeleton shared by a large family of
geometric arguments: one removes successive "layers" from a body and records
the remaining content.  Formally the data is a nonincreasing, nonnegative
sequence `size : ℕ → ℝ` (`PeelProfile`), whose successive differences
`peelGap` are the layer contents.

The classical *upper bound* half of the theory is a pigeonhole statement:
inside any window of `N` peeling steps there is a step whose layer content is
at most the average `peelRate = (size 0 - size N)/N`.  This file formalises
that half (`exists_peel_stopping_time`, `peelEstimate_error`,
`peel_gap_density`, `exists_peel_stable_window`) and then goes further, to the
question of *sharpness*:

* `peel_extremal_tfae` — a four-way equivalence showing that the pigeonhole
  bound is saturated exactly by the arithmetic (equipartition) profiles, and
  that saturation is equivalent to invariance of the gap function under the
  cyclic shift of `ZMod N`.  This is the rigidity statement that converts the
  inequality into a classification.
* `peel_gap_const_of_pretransitive` — the group-theoretic form: if *any* group
  acts pretransitively on the `N` peeling steps and the gap function is
  invariant, all gaps equal the average.  Symmetry forces extremality.

`Catalog/Geometry/PeelSymmetryConstruction.lean` supplies the matching
geometric family of actions (equal-volume shell peelings of Euclidean balls,
equivariant for the orthogonal group).

## Lab notes

Numerical sanity checks performed while developing the file (see
`ComputationalEvidence.md`): the extremal profile for `N = 4`, `A = 1` is
`1, 3/4, 1/2, 1/4, 0`, all gaps `1/4`; the "front-loaded" profile
`1, 0, 0, 0, 0` has gaps `1, 0, 0, 0`, minimum gap `0 < 1/4`, illustrating
that the pigeonhole bound is far from an equality in general and that the
rigidity statement really needs the *uniform* smallness hypothesis.
-/
import Mathlib

namespace Catalog.Geometry.Peel

open Finset

/-! ## Peeling profiles -/

/-- A **peeling profile**: the residual content after `k` peeling steps.
Nonincreasing and nonnegative. -/
structure PeelProfile where
  /-- Residual content after `k` peeling steps. -/
  size : ℕ → ℝ
  /-- Peeling only removes content. -/
  anti : Antitone size
  /-- Content is nonnegative. -/
  nonneg : ∀ k, 0 ≤ size k

variable (P : PeelProfile) {N J M k : ℕ}

/-- The content of the `k`-th peeled layer. -/
def peelGap (P : PeelProfile) (k : ℕ) : ℝ := P.size k - P.size (k + 1)

/-- Total content removed during the first `N` peeling steps. -/
def peelBudget (P : PeelProfile) (N : ℕ) : ℝ := P.size 0 - P.size N

/-- Average layer content over the first `N` steps. -/
noncomputable def peelRate (P : PeelProfile) (N : ℕ) : ℝ := peelBudget P N / N

lemma peelGap_nonneg (k : ℕ) : 0 ≤ peelGap P k :=
  sub_nonneg.2 (P.anti (Nat.le_succ k))

lemma peelBudget_nonneg (N : ℕ) : 0 ≤ peelBudget P N :=
  sub_nonneg.2 (P.anti (Nat.zero_le N))

lemma peelRate_nonneg (N : ℕ) : 0 ≤ peelRate P N :=
  div_nonneg (peelBudget_nonneg P N) (Nat.cast_nonneg N)

/-- Telescoping: the layer contents sum to the budget. -/
lemma sum_peelGap (N : ℕ) : ∑ k ∈ range N, peelGap P k = peelBudget P N :=
  Finset.sum_range_sub' P.size N

lemma nsmul_peelRate : (N : ℝ) * peelRate P N = peelBudget P N := by
  rcases Nat.eq_zero_or_pos N with h | h
  · subst h; simp [peelBudget]
  · have hne : (N : ℝ) ≠ 0 := Nat.cast_ne_zero.2 h.ne'
    rw [peelRate, mul_comm, div_mul_cancel₀ _ hne]

/-! ## The upper bound: existence of a good stopping time -/

/-- **Peeling stopping time.**  Within any window of `N` steps there is a step
whose layer content is at most the average rate. -/
theorem exists_peel_stopping_time (hN : 0 < N) :
    ∃ k < N, peelGap P k ≤ peelRate P N := by
  have hsum : ∑ k ∈ range N, peelGap P k ≤ ∑ _k ∈ range N, peelRate P N := by
    rw [sum_peelGap, Finset.sum_const, nsmul_eq_mul, Finset.card_range]
    exact (nsmul_peelRate P).ge
  obtain ⟨k, hk, hle⟩ :=
    Finset.exists_le_of_sum_le (s := range N) (Finset.nonempty_range_iff.2 hN.ne') hsum
  exact ⟨k, Finset.mem_range.1 hk, hle⟩

/-- The **mean-field (linear) estimate** of the profile: the straight line from
`size 0` to `size N`. -/
noncomputable def peelEstimate (P : PeelProfile) (N k : ℕ) : ℝ :=
  P.size 0 - k * peelRate P N

lemma peelEstimate_zero : peelEstimate P N 0 = P.size 0 := by simp [peelEstimate]

lemma peelEstimate_last : peelEstimate P N N = P.size N := by
  simp [peelEstimate, nsmul_peelRate P, peelBudget]

/-- The error of the linear estimate is the accumulated deviation of the gaps
from the average rate. -/
lemma peelEstimate_error_eq (N k : ℕ) :
    P.size k - peelEstimate P N k = ∑ j ∈ range k, (peelRate P N - peelGap P j) := by
  rw [Finset.sum_sub_distrib, sum_peelGap]
  simp only [peelEstimate, Finset.sum_const, Finset.card_range, nsmul_eq_mul, peelBudget]
  ring

/-- Total deviation of the gaps from the average rate vanishes. -/
lemma sum_rate_sub_gap (N : ℕ) : ∑ j ∈ range N, (peelRate P N - peelGap P j) = 0 := by
  rw [Finset.sum_sub_distrib, sum_peelGap, Finset.sum_const, Finset.card_range, nsmul_eq_mul,
    nsmul_peelRate P]
  ring

/-- The error of the linear estimate, read off from the tail of the window. -/
lemma peelEstimate_error_tail_eq (hk : k ≤ N) :
    ∑ j ∈ Finset.Ico k N, (peelRate P N - peelGap P j) = -(P.size k - peelEstimate P N k) := by
  have hsum := Finset.sum_range_add_sum_Ico (fun j => peelRate P N - peelGap P j) hk
  rw [sum_rate_sub_gap P N] at hsum
  rw [peelEstimate_error_eq]
  linarith [hsum]

/-- **Error bound for the peel estimate.**  Along the whole window the linear
estimate is accurate to within `max k (N - k)` times the average rate. -/
theorem peelEstimate_error (hk : k ≤ N) :
    |P.size k - peelEstimate P N k| ≤ (max k (N - k) : ℕ) * peelRate P N := by
  have hrate := peelRate_nonneg P N
  have hupper : P.size k - peelEstimate P N k ≤ (k : ℝ) * peelRate P N := by
    rw [peelEstimate_error_eq]
    calc ∑ j ∈ range k, (peelRate P N - peelGap P j)
        ≤ ∑ _j ∈ range k, peelRate P N := by
          refine Finset.sum_le_sum fun j _ => ?_
          have := peelGap_nonneg P j; linarith
      _ = (k : ℝ) * peelRate P N := by
          rw [Finset.sum_const, Finset.card_range, nsmul_eq_mul]
  have htail := peelEstimate_error_tail_eq P hk
  have hlower : -((N - k : ℕ) : ℝ) * peelRate P N ≤ P.size k - peelEstimate P N k := by
    have hle : ∑ j ∈ Finset.Ico k N, (peelRate P N - peelGap P j)
        ≤ ((N - k : ℕ) : ℝ) * peelRate P N := by
      calc ∑ j ∈ Finset.Ico k N, (peelRate P N - peelGap P j)
          ≤ ∑ _j ∈ Finset.Ico k N, peelRate P N := by
            refine Finset.sum_le_sum fun j _ => ?_
            have := peelGap_nonneg P j; linarith
        _ = ((N - k : ℕ) : ℝ) * peelRate P N := by
            rw [Finset.sum_const, Nat.card_Ico, nsmul_eq_mul]
    rw [htail] at hle
    linarith
  have h1 : (k : ℝ) ≤ ((max k (N - k) : ℕ) : ℝ) := by exact_mod_cast Nat.le_max_left _ _
  have h2 : ((N - k : ℕ) : ℝ) ≤ ((max k (N - k) : ℕ) : ℝ) := by
    exact_mod_cast Nat.le_max_right _ _
  rw [abs_le]
  constructor
  · nlinarith
  · nlinarith

/-- A crude but hypothesis-free form: the estimate never errs by more than the
whole budget. -/
theorem peelEstimate_error_budget (hk : k ≤ N) :
    |P.size k - peelEstimate P N k| ≤ peelBudget P N := by
  rcases Nat.eq_zero_or_pos N with hN | hN
  · subst hN
    obtain rfl : k = 0 := Nat.le_zero.1 hk
    simp [peelEstimate, peelBudget]
  have hrate := peelRate_nonneg P N
  have hsizes : P.size N ≤ P.size k ∧ P.size k ≤ P.size 0 :=
    ⟨P.anti hk, P.anti (Nat.zero_le k)⟩
  have hest : P.size N ≤ peelEstimate P N k ∧ peelEstimate P N k ≤ P.size 0 := by
    constructor
    · have hkN : (k : ℝ) * peelRate P N ≤ (N : ℝ) * peelRate P N := by
        have : (k : ℝ) ≤ (N : ℝ) := by exact_mod_cast hk
        nlinarith
      rw [nsmul_peelRate P] at hkN
      simp only [peelEstimate, peelBudget] at *
      linarith
    · have : 0 ≤ (k : ℝ) * peelRate P N := mul_nonneg (Nat.cast_nonneg k) hrate
      simp only [peelEstimate]
      linarith
  rw [abs_le]
  simp only [peelBudget]
  constructor <;> [linarith [hsizes.1, hest.2]; linarith [hsizes.2, hest.1]]

/-! ## Density of good stopping times -/

/-- **Markov bound for peelings.**  At most `budget / t` of the steps can have
layer content `≥ t`; in particular good stopping times are plentiful. -/
theorem peel_gap_density (t : ℝ) :
    (((range N).filter (fun k => t ≤ peelGap P k)).card : ℝ) * t ≤ peelBudget P N := by
  set S := (range N).filter (fun k => t ≤ peelGap P k) with hS
  have h1 : (S.card : ℝ) * t ≤ ∑ k ∈ S, peelGap P k := by
    have := Finset.card_nsmul_le_sum S (fun k => peelGap P k) t
      (fun x hx => (Finset.mem_filter.1 hx).2)
    simpa [nsmul_eq_mul, mul_comm] using this
  have h2 : ∑ k ∈ S, peelGap P k ≤ ∑ k ∈ range N, peelGap P k :=
    Finset.sum_le_sum_of_subset_of_nonneg (Finset.filter_subset _ _)
      (fun i _ _ => peelGap_nonneg P i)
  rw [sum_peelGap] at h2
  linarith

/-- Quantitative version: fewer than `N / c` of the first `N` steps can have
layer content exceeding `c` times the average rate. -/
theorem peel_gap_density_rate (hN : 0 < N) {c : ℝ} (hc : 0 < c)
    (hpos : 0 < peelBudget P N) :
    (((range N).filter (fun k => c * peelRate P N ≤ peelGap P k)).card : ℝ) ≤ (N : ℝ) / c := by
  have hNpos : (0 : ℝ) < N := by exact_mod_cast hN
  have hrate : 0 < peelRate P N := div_pos hpos hNpos
  have h := peel_gap_density P (N := N) (c * peelRate P N)
  have hbud : peelBudget P N = (N : ℝ) * peelRate P N := (nsmul_peelRate P).symm
  rw [hbud] at h
  rw [le_div_iff₀ hc]
  nlinarith [h, hrate]

/-! ## Stable windows: blocks of consecutive small layers -/

/-- The profile obtained by peeling in blocks of `J` steps. -/
def blockProfile (P : PeelProfile) (J : ℕ) : PeelProfile where
  size k := P.size (J * k)
  anti := fun _ _ h => P.anti (Nat.mul_le_mul_left J h)
  nonneg := fun _ => P.nonneg _

/-- **Stable window.**  Splitting `N = J * M` steps into `M` blocks of length
`J`, some block removes at most `J / N` of the budget, and hence *every* layer
inside that block is that small. -/
theorem exists_peel_stable_window (hM : 0 < M) :
    ∃ b < M, (∀ j < J, peelGap P (J * b + j) ≤ (P.size 0 - P.size (J * M)) / M) := by
  obtain ⟨b, hb, hle⟩ := exists_peel_stopping_time (blockProfile P J) hM
  refine ⟨b, hb, fun j hj => ?_⟩
  have hblock : P.size (J * b) - P.size (J * (b + 1)) ≤ (P.size 0 - P.size (J * M)) / M := by
    simpa [peelGap, peelRate, peelBudget, blockProfile] using hle
  have h1 : P.size (J * b + j) ≤ P.size (J * b) := P.anti (Nat.le_add_right _ _)
  have h2 : P.size (J * (b + 1)) ≤ P.size (J * b + j + 1) := by
    refine P.anti ?_
    have : J * b + j + 1 ≤ J * b + J := by omega
    simpa [Nat.mul_succ] using this
  simp only [peelGap]
  linarith

/-! ## Rigidity: the pigeonhole bound is saturated only by arithmetic profiles -/

/-- **Rigidity of the peeling bound.**  For a window of `N` steps the
following are equivalent:

1. every layer is at most the average rate;
2. every layer equals the average rate;
3. the profile is the arithmetic (equipartition) profile on the window;
4. the gap function is invariant under the cyclic shift of `ZMod N`.

Thus the pigeonhole inequality upgrades to a classification: the extremisers
are exactly the cyclically symmetric peelings. -/
theorem peel_extremal_tfae (hN : 0 < N) :
    List.TFAE
      [ ∀ k < N, peelGap P k ≤ peelRate P N,
        ∀ k < N, peelGap P k = peelRate P N,
        ∀ k ≤ N, P.size k = P.size 0 - k * peelRate P N,
        ∀ k < N, peelGap P k = peelGap P ((k + 1) % N) ] := by
  have hNR : (0 : ℝ) < N := by exact_mod_cast hN
  tfae_have 1 → 2 := by
    intro h k hk
    have hnn : ∀ j ∈ range N, 0 ≤ peelRate P N - peelGap P j := by
      intro j hj
      have := h j (Finset.mem_range.1 hj)
      linarith
    have hsum : ∑ j ∈ range N, (peelRate P N - peelGap P j) = 0 := by
      rw [Finset.sum_sub_distrib, sum_peelGap, Finset.sum_const, Finset.card_range, nsmul_eq_mul,
        nsmul_peelRate P]
      ring
    have := (Finset.sum_eq_zero_iff_of_nonneg hnn).1 hsum k (Finset.mem_range.2 hk)
    linarith
  tfae_have 2 → 3 := by
    intro h k hk
    induction k with
    | zero => simp
    | succ n ih =>
        have hn : n < N := by omega
        have hgap := h n hn
        have hprev := ih (by omega)
        simp only [peelGap] at hgap
        push_cast
        linarith
  tfae_have 3 → 1 := by
    intro h k hk
    have h1 := h k (le_of_lt hk)
    have h2 := h (k + 1) hk
    simp only [peelGap]
    push_cast at h2
    linarith
  tfae_have 2 → 4 := by
    intro h k hk
    have hmod : (k + 1) % N < N := Nat.mod_lt _ hN
    rw [h k hk, h _ hmod]
  tfae_have 4 → 2 := by
    intro h
    -- cyclic invariance forces the gap function to be constant on the window
    have hconst : ∀ k, k < N → peelGap P k = peelGap P 0 := by
      intro k
      induction k with
      | zero => intro _; rfl
      | succ n ih =>
          intro hn
          have hn' : n < N := by omega
          have hmod : (n + 1) % N = n + 1 := Nat.mod_eq_of_lt hn
          have := h n hn'
          rw [hmod] at this
          rw [← this, ih hn']
    have hsum : ∑ k ∈ range N, peelGap P k = (N : ℝ) * peelGap P 0 := by
      rw [Finset.sum_congr rfl (fun k hk => hconst k (Finset.mem_range.1 hk)),
        Finset.sum_const, Finset.card_range, nsmul_eq_mul]
    rw [sum_peelGap] at hsum
    have h0 : peelGap P 0 = peelRate P N := by
      rw [peelRate, hsum]
      field_simp
    intro k hk
    rw [hconst k hk, h0]
  tfae_finish

/-! ## Symmetry forces extremality -/

/-- The gap function of a window of `N` steps, as a function on `Fin N`. -/
def gapFin (P : PeelProfile) (N : ℕ) : Fin N → ℝ := fun i => peelGap P i

lemma sum_gapFin (N : ℕ) : ∑ i : Fin N, gapFin P N i = peelBudget P N := by
  have h := Fin.sum_univ_eq_sum_range (fun k => peelGap P k) N
  simp only [gapFin]
  rw [h, sum_peelGap]

/-- **Symmetry forces extremality.**  If a group acts pretransitively on the
`N` peeling steps and the layer contents are invariant, then every layer has
exactly the average content: the pigeonhole bound is attained. -/
theorem peel_gap_const_of_pretransitive (hN : 0 < N) {G : Type*} [Group G]
    [MulAction G (Fin N)] [MulAction.IsPretransitive G (Fin N)]
    (hinv : ∀ (g : G) (i : Fin N), gapFin P N (g • i) = gapFin P N i) :
    ∀ i : Fin N, gapFin P N i = peelRate P N := by
  have hNR : (0 : ℝ) < N := by exact_mod_cast hN
  haveI : NeZero N := ⟨hN.ne'⟩
  have hconst : ∀ i : Fin N, gapFin P N i = gapFin P N 0 := by
    intro i
    obtain ⟨g, hg⟩ := MulAction.exists_smul_eq G (0 : Fin N) i
    rw [← hg, hinv]
  have hsum : (N : ℝ) * gapFin P N 0 = peelBudget P N := by
    rw [← sum_gapFin P N, Finset.sum_congr rfl (fun i _ => hconst i), Finset.sum_const,
      Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
  intro i
  rw [hconst i, peelRate, ← hsum]
  field_simp

/-- Symmetric peelings are the extremal ones: under a pretransitive invariant
action the profile is arithmetic on the window. -/
theorem peel_arithmetic_of_pretransitive (hN : 0 < N) {G : Type*} [Group G]
    [MulAction G (Fin N)] [MulAction.IsPretransitive G (Fin N)]
    (hinv : ∀ (g : G) (i : Fin N), gapFin P N (g • i) = gapFin P N i) :
    ∀ k ≤ N, P.size k = P.size 0 - k * peelRate P N := by
  have h := peel_gap_const_of_pretransitive P hN hinv
  have h2 : ∀ k < N, peelGap P k = peelRate P N := by
    intro k hk
    simpa [gapFin] using h ⟨k, hk⟩
  exact ((peel_extremal_tfae P hN).out 1 2).1 h2

/-! ## The matching family: equipartition profiles -/

/-- The **equipartition profile**: total content `A` removed in `N` equal
layers.  This is the extremal family for the stopping-time bound. -/
noncomputable def equipartitionProfile (A : ℝ) (hA : 0 ≤ A) (N : ℕ) : PeelProfile where
  size k := A * max 0 (1 - (k : ℝ) / (N : ℝ))
  anti := by
    intro a b hab
    have hcast : (a : ℝ) ≤ b := by exact_mod_cast hab
    have : (1 : ℝ) - b / N ≤ 1 - a / N := by
      rcases Nat.eq_zero_or_pos N with h | h
      · subst h; simp
      · have hNR : (0 : ℝ) < N := by exact_mod_cast h
        have : (a : ℝ) / N ≤ b / N := by gcongr
        linarith
    have := max_le_max (le_refl (0 : ℝ)) this
    exact mul_le_mul_of_nonneg_left this hA
  nonneg := fun _ => mul_nonneg hA (le_max_left _ _)

variable {A : ℝ}

lemma equipartitionProfile_size_of_le (hA : 0 ≤ A) (hN : 0 < N) (hk : k ≤ N) :
    (equipartitionProfile A hA N).size k = A * (1 - k / N) := by
  have hNR : (0 : ℝ) < N := by exact_mod_cast hN
  have hkN : (k : ℝ) ≤ N := by exact_mod_cast hk
  have : (0 : ℝ) ≤ 1 - k / N := by
    rw [sub_nonneg, div_le_one hNR]; exact hkN
  show A * max 0 (1 - (k : ℝ) / (N : ℝ)) = A * (1 - (k : ℝ) / (N : ℝ))
  rw [max_eq_right this]

@[simp] lemma equipartitionProfile_zero (hA : 0 ≤ A) (hN : 0 < N) :
    (equipartitionProfile A hA N).size 0 = A := by
  rw [equipartitionProfile_size_of_le hA hN (Nat.zero_le N)]; simp

@[simp] lemma equipartitionProfile_last (hA : 0 ≤ A) (hN : 0 < N) :
    (equipartitionProfile A hA N).size N = 0 := by
  have hNR : (0 : ℝ) < N := by exact_mod_cast hN
  rw [equipartitionProfile_size_of_le hA hN (le_refl N), div_self hNR.ne']
  ring

lemma equipartitionProfile_budget (hA : 0 ≤ A) (hN : 0 < N) :
    peelBudget (equipartitionProfile A hA N) N = A := by
  simp [peelBudget, hN]

lemma equipartitionProfile_rate (hA : 0 ≤ A) (hN : 0 < N) :
    peelRate (equipartitionProfile A hA N) N = A / N := by
  rw [peelRate, equipartitionProfile_budget hA hN]

/-- All layers of the equipartition profile have the same content `A / N`. -/
theorem equipartitionProfile_gap (hA : 0 ≤ A) (hN : 0 < N) (hk : k < N) :
    peelGap (equipartitionProfile A hA N) k = A / N := by
  have hNR : (0 : ℝ) < N := by exact_mod_cast hN
  rw [peelGap, equipartitionProfile_size_of_le hA hN hk.le,
    equipartitionProfile_size_of_le hA hN hk]
  push_cast
  field_simp
  ring

/-- The equipartition profile saturates the stopping-time bound at *every*
step: it is an extremiser in the sense of `peel_extremal_tfae`. -/
theorem equipartitionProfile_extremal (hA : 0 ≤ A) (hN : 0 < N) :
    ∀ k < N, peelGap (equipartitionProfile A hA N) k
      = peelRate (equipartitionProfile A hA N) N := by
  intro k hk
  rw [equipartitionProfile_gap hA hN hk, equipartitionProfile_rate hA hN]

/-- **Optimality of the constant `1` in the stopping-time bound.**  For any
`c < 1` there is no step of the equipartition profile with layer content at
most `c` times the average rate, so `exists_peel_stopping_time` cannot be
improved. -/
theorem no_better_peel_constant {c : ℝ} (hc : c < 1) (hN : 0 < N) (hA : 0 < A) :
    ∀ k < N, ¬ (peelGap (equipartitionProfile A hA.le N) k
        ≤ c * peelRate (equipartitionProfile A hA.le N) N) := by
  intro k hk hcon
  rw [equipartitionProfile_gap hA.le hN hk, equipartitionProfile_rate hA.le hN] at hcon
  have hNR : (0 : ℝ) < N := by exact_mod_cast hN
  have hpos : 0 < A / N := div_pos hA hNR
  nlinarith

/-- The cyclic group of order `N` acts on the layers of the equipartition
profile preserving their contents: the promised *matching family of actions*
in its most elementary form. -/
theorem equipartitionProfile_cyclic_invariant (hA : 0 ≤ A) (hN : 0 < N) :
    ∀ k < N, peelGap (equipartitionProfile A hA N) k
      = peelGap (equipartitionProfile A hA N) ((k + 1) % N) := by
  intro k hk
  rw [equipartitionProfile_gap hA hN hk,
    equipartitionProfile_gap hA hN (Nat.mod_lt _ hN)]

end Catalog.Geometry.Peel