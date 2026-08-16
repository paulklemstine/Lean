/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Universality of the fourth spectral moment of Wigner matrices

The Rademacher computation of `Probability.WignerRademacherEnsemble` is a special
case of a *universal* phenomenon: the limiting spectral moments of a Wigner matrix
depend on the entry distribution **only through its mean and variance**.

Here we prove this at order four, for an arbitrary finitely supported entry law
`ℒ` with mean `0` and variance `1` (the fourth moment `m₄(ℒ)` is arbitrary):

  `E [ tr (W⁴) ] = 2N(N-1)² - 2N(N-1) + m₄ · N(N-1)`,

so that the normalised fourth spectral moment
`(1/N) E [ tr ((W/√N)⁴) ] → 2 = C₂`, independently of `m₄`.  The `m₄`-dependent
term counts the degenerate walks that traverse a single edge four times; there are
only `O(N²)` of them, which is why the entry distribution is invisible in the limit.

The proof replaces the sign-flip involution of the Rademacher case by genuine
independence: the expectation of a product over edges factorises
(`gexpect_prod`), so any closed walk that uses some edge exactly once contributes
`0` because the entries are centred.
-/
import Probability.WignerRademacherEnsemble
import Probability.WignerSemicircleLawLowOrder

open Matrix BigOperators Finset Filter Topology
open RademacherWigner (edgeOf edgeOf_comm edgeOf_eq_iff indA indB indC)

namespace WignerUniversal

variable {S : Type*} [Fintype S]

/-- A finitely supported, centred, unit-variance entry law: `w` are the
probabilities and `v` the values taken by a single matrix entry. -/
structure EntryLaw (S : Type*) [Fintype S] where
  /-- probability weights -/
  w : S → ℝ
  /-- values of the entry -/
  v : S → ℝ
  /-- weights are nonnegative -/
  w_nonneg : ∀ s, 0 ≤ w s
  /-- weights sum to one -/
  total : ∑ s, w s = 1
  /-- the law is centred -/
  mean : ∑ s, w s * v s = 0
  /-- the law has unit variance -/
  var : ∑ s, w s * v s ^ 2 = 1

/-- The fourth moment of the entry law (unconstrained). -/
noncomputable def EntryLaw.m4 (L : EntryLaw S) : ℝ := ∑ s, L.w s * L.v s ^ 4

variable {N : ℕ}

/-- A configuration: an independent sample of the entry law for each edge. -/
abbrev Conf (N : ℕ) (S : Type*) := (Fin N × Fin N) → S

/-- Expectation with respect to the product law. -/
noncomputable def gexpect (L : EntryLaw S) (f : Conf N S → ℝ) : ℝ :=
  ∑ ω : Conf N S, (∏ e, L.w (ω e)) * f ω

/-- The matrix entries: zero on the diagonal, symmetric, sampled at edge `{i,j}`. -/
def gentry (L : EntryLaw S) (ω : Conf N S) (i j : Fin N) : ℝ :=
  if i = j then 0 else L.v (ω (edgeOf i j))

theorem gentry_symm (L : EntryLaw S) (ω : Conf N S) (i j : Fin N) :
    gentry L ω i j = gentry L ω j i := by
  unfold gentry
  by_cases h : i = j
  · simp [h]
  · simp [h, Ne.symm h, edgeOf_comm i j]

theorem gentry_of_ne (L : EntryLaw S) (ω : Conf N S) {i j : Fin N} (h : i ≠ j) :
    gentry L ω i j = L.v (ω (edgeOf i j)) := by simp [gentry, h]

/-- The random matrix of the ensemble. -/
def GW (L : EntryLaw S) (ω : Conf N S) : Matrix (Fin N) (Fin N) ℝ :=
  Matrix.of fun i j => gentry L ω i j

@[simp] theorem GW_apply (L : EntryLaw S) (ω : Conf N S) (i j : Fin N) :
    GW L ω i j = gentry L ω i j := rfl

theorem GW_isHermitian (L : EntryLaw S) (ω : Conf N S) : (GW L ω).IsHermitian := by
  ext i j
  simp [Matrix.conjTranspose_apply, gentry_symm L ω j i]

/-! ### Linearity of the expectation -/

theorem gexpect_zero (L : EntryLaw S) : gexpect (N := N) L (fun _ => 0) = 0 := by
  simp [gexpect]

theorem gexpect_sum {ι : Type*} (L : EntryLaw S) (s : Finset ι) (F : ι → Conf N S → ℝ) :
    gexpect L (fun ω => ∑ i ∈ s, F i ω) = ∑ i ∈ s, gexpect L (F i) := by
  unfold gexpect
  simp_rw [Finset.mul_sum]
  rw [Finset.sum_comm]

theorem gexpect_const_mul (L : EntryLaw S) (c : ℝ) (f : Conf N S → ℝ) :
    gexpect L (fun ω => c * f ω) = c * gexpect L f := by
  unfold gexpect
  rw [Finset.mul_sum]
  exact Finset.sum_congr rfl fun ω _ => by ring

/-! ### Independence: the expectation of a product over edges factorises -/

theorem gexpect_prod (L : EntryLaw S) (F : (Fin N × Fin N) → S → ℝ) :
    gexpect L (fun ω => ∏ e, F e (ω e)) = ∏ e, ∑ s, L.w s * F e s := by
  unfold gexpect
  have h : ∀ ω : Conf N S, (∏ e, L.w (ω e)) * ∏ e, F e (ω e)
      = ∏ e, (L.w (ω e) * F e (ω e)) := fun ω => (Finset.prod_mul_distrib).symm
  rw [Finset.sum_congr rfl fun ω _ => h ω, Finset.prod_univ_sum, Fintype.piFinset_univ]

/-! ### Elementary products over the edge set -/

theorem prod_eq_single' {ι : Type*} [Fintype ι] [DecidableEq ι] (p : ι) (F : ι → ℝ)
    (h1 : ∀ e, e ≠ p → F e = 1) : ∏ e, F e = F p :=
  Finset.prod_eq_single p (fun b _ hb => h1 b hb) (by simp)

theorem prod_eq_pair {ι : Type*} [Fintype ι] [DecidableEq ι] {p q : ι} (hpq : p ≠ q)
    (F : ι → ℝ) (h1 : ∀ e, e ≠ p → e ≠ q → F e = 1) : ∏ e, F e = F p * F q := by
  rw [← Finset.prod_pair hpq]
  refine (Finset.prod_subset (Finset.subset_univ _) ?_).symm
  intro x _ hx
  simp only [Finset.mem_insert, Finset.mem_singleton, not_or] at hx
  exact h1 x hx.1 hx.2

/-- A product along a walk equals the product over edges of powers given by the
multiplicities with which the walk traverses them. -/
theorem prod_walk {ι : Type*} [Fintype ι] [DecidableEq ι] [BEq ι] [LawfulBEq ι]
    (x : ι → ℝ) (l : List ι) :
    (l.map x).prod = ∏ e, x e ^ l.count e := by
  induction l with
  | nil => simp
  | cons a t ih =>
      simp only [List.map_cons, List.prod_cons, ih, List.count_cons]
      simp_rw [pow_add]
      rw [Finset.prod_mul_distrib]
      have h : (∏ e : ι, x e ^ (if (a == e) = true then 1 else 0)) = x a := by
        rw [prod_eq_single' a]
        · simp
        · intro e he
          simp [Ne.symm he]
      rw [h]
      ring

/-! ### The expectation of a single closed 4-walk -/

/-- A walk that traverses one edge four times contributes the fourth moment. -/
theorem gexpect_quad (L : EntryLaw S) (p : Fin N × Fin N) :
    gexpect L (fun ω : Conf N S => L.v (ω p) ^ 4) = L.m4 := by
  set F : (Fin N × Fin N) → S → ℝ := fun e s => if e = p then L.v s ^ 4 else 1 with hF
  have h1 : ∀ ω : Conf N S, L.v (ω p) ^ 4 = ∏ e, F e (ω e) := by
    intro ω
    rw [prod_eq_single' p (fun e => F e (ω e)) (fun e he => by simp [hF, he])]
    simp [hF]
  simp only [h1]
  rw [gexpect_prod]
  rw [prod_eq_single' p (fun e => ∑ s, L.w s * F e s)
    (fun e he => by simp [hF, he, L.total])]
  simp [hF, EntryLaw.m4]

/-- A walk that traverses two distinct edges twice each contributes `1`. -/
theorem gexpect_double_pair (L : EntryLaw S) {p q : Fin N × Fin N} (hpq : p ≠ q) :
    gexpect L (fun ω : Conf N S => L.v (ω p) ^ 2 * L.v (ω q) ^ 2) = 1 := by
  set F : (Fin N × Fin N) → S → ℝ :=
    fun e s => if e = p then L.v s ^ 2 else if e = q then L.v s ^ 2 else 1 with hF
  have h1 : ∀ ω : Conf N S, L.v (ω p) ^ 2 * L.v (ω q) ^ 2 = ∏ e, F e (ω e) := by
    intro ω
    rw [prod_eq_pair hpq (fun e => F e (ω e)) (fun e he he' => by simp [hF, he, he'])]
    simp [hF, Ne.symm hpq]
  simp only [h1]
  rw [gexpect_prod]
  rw [prod_eq_pair hpq (fun e => ∑ s, L.w s * F e s)
    (fun e he he' => by simp [hF, he, he', L.total])]
  simp [hF, Ne.symm hpq, L.var]

/-- A closed 4-walk that traverses some edge exactly once has zero expectation:
this is where centredness of the entries enters. -/
theorem gexpect_walk_zero (L : EntryLaw S) {i j k l : Fin N} (hij : i ≠ j) (hjk : j ≠ k)
    (hkl : k ≠ l) (hli : l ≠ i) (hik : i ≠ k) (hjl : j ≠ l) :
    gexpect L (fun ω : Conf N S =>
      gentry L ω i j * gentry L ω j k * gentry L ω k l * gentry L ω l i) = 0 := by
  obtain ⟨e2, e3, e4⟩ := RademacherWigner.edges_ne_first hij hjk hkl hli hik hjl
  have h1 : ∀ ω : Conf N S,
      gentry L ω i j * gentry L ω j k * gentry L ω k l * gentry L ω l i =
        ∏ e, L.v (ω e) ^ ([edgeOf i j, edgeOf j k, edgeOf k l, edgeOf l i].count e) := by
    intro ω
    rw [gentry_of_ne L ω hij, gentry_of_ne L ω hjk, gentry_of_ne L ω hkl,
      gentry_of_ne L ω hli]
    have h := prod_walk (fun e => L.v (ω e))
      [edgeOf i j, edgeOf j k, edgeOf k l, edgeOf l i]
    simp only [List.map_cons, List.map_nil, List.prod_cons, List.prod_nil, mul_one] at h
    rw [← mul_assoc, ← mul_assoc] at h
    exact h
  simp only [h1]
  rw [gexpect_prod L (fun e s => L.v s ^
    ([edgeOf i j, edgeOf j k, edgeOf k l, edgeOf l i].count e))]
  refine Finset.prod_eq_zero (Finset.mem_univ (edgeOf i j)) ?_
  have hcount : [edgeOf i j, edgeOf j k, edgeOf k l, edgeOf l i].count (edgeOf i j) = 1 := by
    simp [e2, e3, e4]
  simp [hcount, L.mean]

/-- All three inclusion–exclusion indicators vanish on degenerate walks. -/
theorem ind_sum_degenerate (c : ℝ) {i j k l : Fin N}
    (h : i = j ∨ j = k ∨ k = l ∨ l = i) :
    indA i j k l + indB i j k l + c * indC i j k l = 0 := by
  unfold indA indB indC
  rcases h with rfl | rfl | rfl | rfl <;> split_ifs <;> simp_all

/-- The exact expectation of one closed 4-walk, in terms of the inclusion–exclusion
indicators of `Probability.WignerRademacherEnsemble`. -/
theorem gexpect_term (L : EntryLaw S) (i j k l : Fin N) :
    gexpect L (fun ω : Conf N S =>
        gentry L ω i j * gentry L ω j k * gentry L ω k l * gentry L ω l i) =
      indA i j k l + indB i j k l + (L.m4 - 2) * indC i j k l := by
  by_cases hij : i = j
  · have h0 : ∀ ω : Conf N S,
        gentry L ω i j * gentry L ω j k * gentry L ω k l * gentry L ω l i = 0 := by
      intro ω; simp [gentry, hij]
    simp only [h0]
    rw [gexpect_zero, ind_sum_degenerate _ (Or.inl hij)]
  by_cases hjk : j = k
  · have h0 : ∀ ω : Conf N S,
        gentry L ω i j * gentry L ω j k * gentry L ω k l * gentry L ω l i = 0 := by
      intro ω; simp [gentry, hjk]
    simp only [h0]
    rw [gexpect_zero, ind_sum_degenerate _ (Or.inr (Or.inl hjk))]
  by_cases hkl : k = l
  · have h0 : ∀ ω : Conf N S,
        gentry L ω i j * gentry L ω j k * gentry L ω k l * gentry L ω l i = 0 := by
      intro ω; simp [gentry, hkl]
    simp only [h0]
    rw [gexpect_zero, ind_sum_degenerate _ (Or.inr (Or.inr (Or.inl hkl)))]
  by_cases hli : l = i
  · have h0 : ∀ ω : Conf N S,
        gentry L ω i j * gentry L ω j k * gentry L ω k l * gentry L ω l i = 0 := by
      intro ω; simp [gentry, hli]
    simp only [h0]
    rw [gexpect_zero, ind_sum_degenerate _ (Or.inr (Or.inr (Or.inr hli)))]
  by_cases hik : i = k
  · subst hik
    by_cases hjl : j = l
    · -- one edge traversed four times
      subst hjl
      have h1 : ∀ ω : Conf N S,
          gentry L ω i j * gentry L ω j i * gentry L ω i j * gentry L ω j i
            = L.v (ω (edgeOf i j)) ^ 4 := by
        intro ω
        rw [gentry_of_ne L ω hij, ← gentry_symm L ω i j, gentry_of_ne L ω hij]
        ring
      simp only [h1]
      rw [gexpect_quad]
      have hji : ¬ j = i := fun h => hij h.symm
      simp [indA, indB, indC, hij, hji]
      ring
    · -- two distinct edges, each traversed twice
      have hil : i ≠ l := fun h => hkl h
      have hpq : edgeOf i j ≠ edgeOf i l := by
        intro h
        rcases (edgeOf_eq_iff hij hil).1 h with ⟨-, h2⟩ | ⟨h1, -⟩
        · exact hjl h2
        · exact hil h1
      have h1 : ∀ ω : Conf N S,
          gentry L ω i j * gentry L ω j i * gentry L ω i l * gentry L ω l i
            = L.v (ω (edgeOf i j)) ^ 2 * L.v (ω (edgeOf i l)) ^ 2 := by
        intro ω
        rw [gentry_of_ne L ω hij, ← gentry_symm L ω i j, gentry_of_ne L ω hij,
          gentry_of_ne L ω hil, ← gentry_symm L ω i l, gentry_of_ne L ω hil]
        ring
      simp only [h1]
      rw [gexpect_double_pair L hpq]
      have hji : ¬ j = i := fun h => hij h.symm
      have hli' : ¬ l = i := fun h => hli h
      simp [indA, indB, indC, hij, hji, hjl, hli', eq_comm]
  by_cases hjl : j = l
  · -- two distinct edges, each traversed twice (the other pairing)
    subst hjl
    have hjk' : j ≠ k := hjk
    have hpq : edgeOf i j ≠ edgeOf j k := by
      intro h
      rcases (edgeOf_eq_iff hij hjk').1 h with ⟨h1, -⟩ | ⟨h1, -⟩
      · exact hij h1
      · exact hik h1
    have h1 : ∀ ω : Conf N S,
        gentry L ω i j * gentry L ω j k * gentry L ω k j * gentry L ω j i
          = L.v (ω (edgeOf i j)) ^ 2 * L.v (ω (edgeOf j k)) ^ 2 := by
      intro ω
      rw [gentry_of_ne L ω hij, gentry_of_ne L ω hjk, ← gentry_symm L ω j k,
        gentry_of_ne L ω hjk, ← gentry_symm L ω i j, gentry_of_ne L ω hij]
      ring
    simp only [h1]
    rw [gexpect_double_pair L hpq]
    have hji : ¬ j = i := fun h => hij h.symm
    simp [indA, indB, indC, hij, hji, hik, hjk, eq_comm]
  · -- some edge traversed exactly once
    rw [gexpect_walk_zero L hij hjk hkl hli hik hjl]
    simp [indA, indB, indC, hik, hjl, eq_comm]

/-! ### The universal fourth trace moment -/

/-- **Universality of the fourth trace moment.**  For an arbitrary centred,
unit-variance entry law the expected fourth trace moment is
`2N(N-1)² - 2N(N-1) + m₄ N(N-1)`; only the `O(N²)` term sees the entry law. -/
theorem gexpect_trace_four (L : EntryLaw S) (N : ℕ) :
    gexpect L (fun ω : Conf N S => ((GW L ω) ^ 4).trace) =
      2 * (N : ℝ) * ((N : ℝ) - 1) ^ 2 - 2 * (N : ℝ) * ((N : ℝ) - 1)
        + L.m4 * ((N : ℝ) * ((N : ℝ) - 1)) := by
  have h1 : ∀ ω : Conf N S, ((GW L ω) ^ 4).trace =
      ∑ i : Fin N, ∑ j : Fin N, ∑ k : Fin N, ∑ l : Fin N,
        gentry L ω i j * gentry L ω j k * gentry L ω k l * gentry L ω l i := fun ω =>
    RademacherWigner.trace_pow_four (GW L ω)
  simp only [h1]
  rw [gexpect_sum]
  have h2 : ∀ i : Fin N,
      gexpect L (fun ω : Conf N S => ∑ j : Fin N, ∑ k : Fin N, ∑ l : Fin N,
        gentry L ω i j * gentry L ω j k * gentry L ω k l * gentry L ω l i)
      = ∑ j : Fin N, ∑ k : Fin N, ∑ l : Fin N,
          (indA i j k l + indB i j k l + (L.m4 - 2) * indC i j k l) := by
    intro i
    rw [gexpect_sum]
    refine Finset.sum_congr rfl fun j _ => ?_
    rw [gexpect_sum]
    refine Finset.sum_congr rfl fun k _ => ?_
    rw [gexpect_sum]
    exact Finset.sum_congr rfl fun l _ => gexpect_term L i j k l
  rw [Finset.sum_congr rfl fun i _ => h2 i]
  have hsplit : (∑ i : Fin N, ∑ j : Fin N, ∑ k : Fin N, ∑ l : Fin N,
      (indA i j k l + indB i j k l + (L.m4 - 2) * indC i j k l))
      = (∑ i : Fin N, ∑ j : Fin N, ∑ k : Fin N, ∑ l : Fin N, indA i j k l)
        + (∑ i : Fin N, ∑ j : Fin N, ∑ k : Fin N, ∑ l : Fin N, indB i j k l)
        + (L.m4 - 2) * (∑ i : Fin N, ∑ j : Fin N, ∑ k : Fin N, ∑ l : Fin N, indC i j k l) := by
    simp_rw [Finset.sum_add_distrib, ← Finset.mul_sum]
  rw [hsplit, RademacherWigner.sum_indA, RademacherWigner.sum_indB, RademacherWigner.sum_indC]
  ring

/-- **Universality of the limiting fourth spectral moment.**  For every centred,
unit-variance entry law the expected fourth moment of the empirical spectral
distribution of `W/√N` converges to `C₂ = 2`, the fourth moment of the semicircle
law — irrespective of the fourth moment `m₄` of the entries. -/
theorem tendsto_gexpect_normalizedMoment_four (L : EntryLaw S) :
    Tendsto (fun N : ℕ => gexpect L (fun ω : Conf N S =>
        WignerBridge.normalizedMoment (GW L ω) 4)) atTop
      (𝓝 (WignerSemicircle.semicircleMoment 4)) := by
  rw [WignerSemicircle.semicircleMoment_four]
  have hval : ∀ N : ℕ, 0 < N →
      gexpect L (fun ω : Conf N S => WignerBridge.normalizedMoment (GW L ω) 4)
        = 2 - 6 * (1 / (N : ℝ)) + 4 * (1 / (N : ℝ)) ^ 2
          + L.m4 * (1 / (N : ℝ)) - L.m4 * (1 / (N : ℝ)) ^ 2 := by
    intro N hN
    have hNR : (N : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr hN.ne'
    have hpow : (Real.sqrt (N : ℝ))⁻¹ ^ 4 = ((N : ℝ))⁻¹ ^ 2 := by
      rw [show (4 : ℕ) = 2 * 2 from rfl, pow_mul, RademacherWigner.sqrt_inv_sq]
    have hrw : ∀ ω : Conf N S, WignerBridge.normalizedMoment (GW L ω) 4 =
        (1 / (N : ℝ) * ((N : ℝ))⁻¹ ^ 2) * ((GW L ω) ^ 4).trace := by
      intro ω
      rw [WignerBridge.normalizedMoment_eq, RademacherWigner.card_fin_config, hpow]
    simp only [hrw]
    rw [gexpect_const_mul, gexpect_trace_four]
    field_simp
    ring
  have hlim : Tendsto (fun N : ℕ =>
      2 - 6 * (1 / (N : ℝ)) + 4 * (1 / (N : ℝ)) ^ 2
        + L.m4 * (1 / (N : ℝ)) - L.m4 * (1 / (N : ℝ)) ^ 2) atTop (𝓝 2) := by
    have h : Tendsto (fun N : ℕ => (1 : ℝ) / (N : ℝ)) atTop (𝓝 0) :=
      tendsto_one_div_atTop_nhds_zero_nat
    have h2 := ((((tendsto_const_nhds (x := (2:ℝ))).sub
        ((tendsto_const_nhds (x := (6:ℝ))).mul h)).add
      ((tendsto_const_nhds (x := (4:ℝ))).mul (h.pow 2))).add
      ((tendsto_const_nhds (x := L.m4)).mul h)).sub
      ((tendsto_const_nhds (x := L.m4)).mul (h.pow 2))
    simpa using h2
  refine hlim.congr' ?_
  filter_upwards [eventually_gt_atTop 0] with N hN
  exact (hval N hN).symm

/-! ### The Rademacher law as an instance -/

/-- The symmetric Rademacher law `±1` with probability `1/2`. -/
noncomputable def rademacherLaw : EntryLaw Bool where
  w := fun _ => 1 / 2
  v := fun b => if b then 1 else -1
  w_nonneg := by intro s; norm_num
  total := by simp
  mean := by simp
  var := by simp

@[simp] theorem rademacherLaw_m4 : rademacherLaw.m4 = 1 := by
  simp [EntryLaw.m4, rademacherLaw]
  norm_num

/-- Consistency check: specialising the universal formula to the Rademacher law
recovers the exact fourth trace moment computed by the sign-flip involution. -/
theorem gexpect_trace_four_rademacher (N : ℕ) :
    gexpect rademacherLaw (fun ω : Conf N Bool => ((GW rademacherLaw ω) ^ 4).trace) =
      2 * (N : ℝ) * ((N : ℝ) - 1) ^ 2 - (N : ℝ) * ((N : ℝ) - 1) := by
  rw [gexpect_trace_four, rademacherLaw_m4]
  ring

end WignerUniversal