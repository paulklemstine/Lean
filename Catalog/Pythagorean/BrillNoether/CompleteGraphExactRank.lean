/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib
import Pythagorean.BrillNoether.Divisors
import Pythagorean.BrillNoether.ResidualDuality
import Pythagorean.BrillNoether.RankUpperBound
import Pythagorean.BrillNoether.CompleteGraphRank

/-!
# The exact Baker–Norine rank of a constant divisor on a complete graph

`CompleteGraphRank.lean` established the *upper* bound `r(m · 1) ≤ m (m+3)/2` on the
complete graph `K n` (`not_rankAtLeast_const_K`), via an explicit reduced staircase
divisor, and matched it with the one-shot set-firing lower bound only for `m ≤ 2`.
This file proves the matching **lower bound for every `m`**, and hence the exact
formula

  `r(m · 1) = m (m + 3) / 2`  on `K n` for every `n ≥ m + 2`,

which is quadratic in `m`, whereas *all* previously available lower bounds
(`rankAtLeast_of_forall_le_three_mul`: `3m - 1`, and
`rankAtLeast_of_threshold_quadratic`: `2m + ⌊m²/4⌋`) are strictly weaker.

## The mechanism

A divisor `D` on `K n` is linearly equivalent to an effective divisor exactly when
the *whole* firing vector can be chosen at once: `lap (K n) f v = n · f v - ∑ u, f u`.
Writing `f = u - 1` with `u : V → ℕ` and `S = ∑ u`, the divisor `m · 1 - E + lap f`
is effective iff

  `E v + S ≤ m + n · u v`  for every vertex `v`.                     (★)

Given the effective test divisor `E` we take, for a threshold `t`,
`u v := ⌈(E v - (m - t))/n⌉` (the function `wt` below), so that (★) holds as soon as
`S = ∑ u = t`.  The map `t ↦ ∑ v, wt n (E v) (m - t)` is monotone, so it suffices to
find *some* `t ∈ [1, m]` with `∑ v wt n (E v) (m - t) ≤ t`: the least such `t` is
automatically a fixed point.  Such a `t` exists because of the counting identity

  `∑_{j < m} wt n a j = m ⌊a/n⌋ + min m (a % n) ≤ a`,   with strict inequality when `a > m`,

so that if no threshold worked we would get `∑ v E v ≥ ∑_{t<m} (t + 2) = m(m+3)/2`
*and* `∑ v E v ≥ m(m+3)/2 + 1`, contradicting `deg E = m(m+3)/2`.

## Main results

* `linEquiv_effective_iff_K` — the effectivity criterion: `D` is equivalent to an
  effective divisor iff some shift `s` satisfies `∑_v ⌈(s - D v)/n⌉ ≤ s`.
* `linEquiv_effective_of_genus_le_deg_K`, `rankAtLeast_of_genus_add_le_deg_K` —
  **Riemann's inequality on `K n`**, proved from the criterion by averaging the
  shift over a complete residue window (Hermite's identity `sum_ediv_range`);
  `exists_deg_genus_sub_one_not_effective_K` shows the degree bound `g` is sharp.
* `sum_wt_le_self`, `sum_wt_lt_self` — the counting estimate for the ceiling weights.
* `rankAtLeast_const_K` — the lower bound `r(m · 1) ≥ m (m+3)/2` on `K n`, `n ≥ m+2`.
* `rank_const_K`, `rankBN_const_K` — the exact rank `m (m+3)/2`.
* `rank_const_K_gt_threshold_bound` — for `m ≥ 3` the exact rank strictly exceeds the
  best one-shot threshold-firing bound `2m + ⌊m²/4⌋`, so iterated firing is genuinely
  needed.
-/

open Finset SimpleGraph

namespace BrillNoetherCompleteExact

open BrillNoetherDivisor BrillNoetherResidual BrillNoetherUpper BrillNoetherComplete

/-! ## The Laplacian of a complete graph -/

/-- On the complete graph the Laplacian acts by `f ↦ n f - (∑ f) 1`. -/
lemma lap_K {n : ℕ} (f : Fin n → ℤ) (v : Fin n) :
    lap (K n) f v = n * f v - ∑ u, f u := by
  have hn : 1 ≤ n := v.pos
  rw [lap_apply, degree_K, neighborFinset_K, Finset.sum_erase_eq_sub (Finset.mem_univ v)]
  have hc : ((n - 1 : ℕ) : ℤ) = (n : ℤ) - 1 := by omega
  rw [hc]; ring

/-- **Effectivity criterion on a complete graph.**  A divisor `D` on `K n` is linearly
equivalent to an effective divisor *iff* there is an integer shift `s` with
`∑ v ⌈(s - D v)/n⌉ ≤ s`.  (Ceilings are written `-⌊(D v - s)/n⌋`.)  This turns the
chip-firing question on `K n` into a one-parameter integer optimisation, and is the
structural reason behind the exact rank formula below. -/
theorem linEquiv_effective_iff_K {n : ℕ} (hn : 0 < n) (D : Divisor (Fin n)) :
    (∃ f : Fin n → ℤ, Effective (D + lap (K n) f)) ↔
      ∃ s : ℤ, ∑ v, -((D v - s) / (n : ℤ)) ≤ s := by
  have hnZ : (0 : ℤ) < n := by exact_mod_cast hn
  constructor
  · rintro ⟨f, hf⟩
    refine ⟨∑ u, f u, Finset.sum_le_sum fun v _ => ?_⟩
    have hv := hf v
    rw [Pi.add_apply, lap_K] at hv
    have : -(f v) ≤ (D v - ∑ u, f u) / (n : ℤ) :=
      (Int.le_ediv_iff_mul_le hnZ).mpr (by nlinarith [hv])
    linarith
  · rintro ⟨s, hs⟩
    refine ⟨fun v => -((D v - s) / (n : ℤ)), fun v => ?_⟩
    have hfloor : (n : ℤ) * ((D v - s) / (n : ℤ)) ≤ D v - s := by
      have h := Int.mul_ediv_add_emod (D v - s) (n : ℤ)
      have h2 : 0 ≤ (D v - s) % (n : ℤ) := Int.emod_nonneg _ (by omega)
      omega
    rw [Pi.add_apply, lap_K]
    have hsum : ∑ u, -((D u - s) / (n : ℤ)) ≤ s := hs
    nlinarith [hfloor, hsum]

/-! ## Hermite's identity and Riemann's inequality on a complete graph -/

/-- `-⌊y/n⌋ = ⌊(-y + n - 1)/n⌋`: the ceiling of `-y/n` written as a floor. -/
lemma neg_ediv_eq {n : ℕ} (hn : 0 < n) (y : ℤ) :
    -(y / (n : ℤ)) = (-y + (n : ℤ) - 1) / (n : ℤ) := by
  have hnZ : (0 : ℤ) < n := by exact_mod_cast hn
  have hq := Int.mul_ediv_add_emod y (n : ℤ)
  have ht0 : 0 ≤ y % (n : ℤ) := Int.emod_nonneg _ (by omega)
  have ht1 : y % (n : ℤ) < (n : ℤ) := Int.emod_lt_of_pos _ hnZ
  set q := y / (n : ℤ) with hqdef
  set t := y % (n : ℤ) with htdef
  have hrhs : -y + (n : ℤ) - 1 = ((n : ℤ) - 1 - t) + (n : ℤ) * (-q) := by linarith
  rw [hrhs, Int.add_mul_ediv_left _ _ (by omega : (n : ℤ) ≠ 0),
    Int.ediv_eq_zero_of_lt (by omega) (by omega)]
  ring

/-- **Hermite's identity** for a complete residue window:
`∑_{s < n} ⌊(z + s)/n⌋ = z`. -/
lemma sum_ediv_range {n : ℕ} (hn : 0 < n) (z : ℤ) :
    ∑ s ∈ range n, (z + (s : ℤ)) / (n : ℤ) = z := by
  have hnZ : (0 : ℤ) < n := by exact_mod_cast hn
  have hq := Int.mul_ediv_add_emod z (n : ℤ)
  have ht0 : 0 ≤ z % (n : ℤ) := Int.emod_nonneg _ (by omega)
  have ht1 : z % (n : ℤ) < (n : ℤ) := Int.emod_lt_of_pos _ hnZ
  set q := z / (n : ℤ) with hqdef
  set t := z % (n : ℤ) with htdef
  set rn := t.toNat with hrndef
  have hrn : (rn : ℤ) = t := Int.toNat_of_nonneg ht0
  have hrnle : rn ≤ n := by omega
  have hterm : ∀ s ∈ range n,
      (z + (s : ℤ)) / (n : ℤ) = q + (if n - rn ≤ s then 1 else 0) := by
    intro s hs
    have hsn : s < n := Finset.mem_range.mp hs
    have hz : z + (s : ℤ) = (t + (s : ℤ)) + (n : ℤ) * q := by linarith
    rw [hz, Int.add_mul_ediv_left _ _ (by omega : (n : ℤ) ≠ 0)]
    by_cases h : n - rn ≤ s
    · have h1 : t + (s : ℤ) = ((t + (s : ℤ)) - (n : ℤ)) + (n : ℤ) * 1 := by ring
      rw [h1, Int.add_mul_ediv_left _ _ (by omega : (n : ℤ) ≠ 0),
        Int.ediv_eq_zero_of_lt (by omega) (by omega)]
      simp only [h, if_true, zero_add]
      ring
    · rw [Int.ediv_eq_zero_of_lt (by omega) (by omega)]
      simp only [h, if_false, zero_add, add_zero]
  rw [Finset.sum_congr rfl hterm, Finset.sum_add_distrib, Finset.sum_const,
    Finset.card_range, nsmul_eq_mul]
  have hcount : ∑ s ∈ range n, (if n - rn ≤ s then (1 : ℤ) else 0) = (rn : ℤ) := by
    rw [Finset.sum_ite, Finset.sum_const, Finset.sum_const]
    have hfilter : (range n).filter (fun s => n - rn ≤ s) = Finset.Ico (n - rn) n := by
      ext s; simp only [Finset.mem_filter, Finset.mem_range, Finset.mem_Ico]; omega
    rw [hfilter, Nat.card_Ico]
    have h2 : n - (n - rn) = rn := by omega
    rw [h2]
    simp
  rw [hcount, hrn]
  linarith

/-- Gauss' sum, cast to `ℤ`. -/
lemma two_mul_sum_range_add_one (n : ℕ) :
    2 * ∑ s ∈ range n, ((s : ℤ) + 1) = (n : ℤ) * ((n : ℤ) + 1) := by
  induction n with
  | zero => simp
  | succ k ih =>
    rw [Finset.sum_range_succ]
    push_cast at ih ⊢
    linarith

/-- **Riemann's inequality on a complete graph, in its sharp form.**  Every divisor of
degree at least the genus `g = (n-1)(n-2)/2` on `K n` is linearly equivalent to an
effective divisor.  The bound is sharp: the staircase divisor of degree `g - 1`
(`stairF`) is not equivalent to an effective one. -/
theorem linEquiv_effective_of_genus_le_deg_K {n : ℕ} (hn : 0 < n) (D : Divisor (Fin n))
    (hd : genus (K n) ≤ deg D) : ∃ f : Fin n → ℤ, Effective (D + lap (K n) f) := by
  have hnZ : (0 : ℤ) < n := by exact_mod_cast hn
  rw [linEquiv_effective_iff_K hn]
  by_contra hcon
  push_neg at hcon
  -- every shift `s` fails, so summing over a complete residue window is impossible
  have hsum : ∀ s : ℕ, (s : ℤ) + 1 ≤ ∑ v, -((D v - (s : ℤ)) / (n : ℤ)) := fun s => hcon s
  have hle : ∑ s ∈ range n, ((s : ℤ) + 1)
      ≤ ∑ s ∈ range n, ∑ v, -((D v - (s : ℤ)) / (n : ℤ)) :=
    Finset.sum_le_sum fun s _ => hsum s
  have hswap : ∑ s ∈ range n, ∑ v, -((D v - (s : ℤ)) / (n : ℤ))
      = ∑ v, ∑ s ∈ range n, ((-(D v) + (n : ℤ) - 1) + (s : ℤ)) / (n : ℤ) := by
    rw [Finset.sum_comm]
    refine Finset.sum_congr rfl fun v _ => Finset.sum_congr rfl fun s _ => ?_
    rw [neg_ediv_eq hn]
    congr 1
    ring
  have hhermite : ∑ v, ∑ s ∈ range n, ((-(D v) + (n : ℤ) - 1) + (s : ℤ)) / (n : ℤ)
      = ∑ v, (-(D v) + (n : ℤ) - 1) :=
    Finset.sum_congr rfl fun v _ => sum_ediv_range hn _
  have hdeg : ∑ v : Fin n, (-(D v) + (n : ℤ) - 1) = -deg D + (n : ℤ) * ((n : ℤ) - 1) := by
    simp only [deg, Finset.sum_add_distrib, Finset.sum_sub_distrib, Finset.sum_neg_distrib,
      Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
    ring
  have hgauss := two_mul_sum_range_add_one n
  have hg := two_mul_genus_K (n := n) (by omega)
  rw [hswap, hhermite, hdeg] at hle
  linarith

/-- **Riemann's inequality on a complete graph.**  A divisor of degree at least
`g + r` on `K n` has Baker–Norine rank at least `r`. -/
theorem rankAtLeast_of_genus_add_le_deg_K {n r : ℕ} (hn : 0 < n) (D : Divisor (Fin n))
    (hd : genus (K n) + r ≤ deg D) : RankAtLeast (K n) D r := by
  intro E hE hdeg
  refine linEquiv_effective_of_genus_le_deg_K hn (D - E) ?_
  rw [deg_sub, hdeg]
  linarith

/-- **Sharpness of Riemann's inequality on `K n`.**  The staircase divisor with
profile `-1, 0, 1, …, n-2` has degree exactly `g - 1` and is *not* linearly
equivalent to an effective divisor, so `genus` cannot be lowered in
`linEquiv_effective_of_genus_le_deg_K`. -/
theorem exists_deg_genus_sub_one_not_effective_K {n : ℕ} (hn : 3 ≤ n) :
    deg (stairF n (n - 2)) = genus (K n) - 1 ∧
      ¬ ∃ f : Fin n → ℤ, Effective (stairF n (n - 2) + lap (K n) f) := by
  have hnpos : 0 < n := by omega
  have hmc : ((n - 2 : ℕ) : ℤ) = (n : ℤ) - 2 := by omega
  constructor
  · have hsplit : deg (stairF n (n - 2))
        = (n : ℤ) * ((n - 2 : ℕ) : ℤ) - deg (stairE n (n - 2)) := by
      simp only [stairF, deg, Finset.sum_sub_distrib, Finset.sum_const, Finset.card_univ,
        Fintype.card_fin, nsmul_eq_mul]
    have hst := two_mul_deg_stairE (n := n) (m := n - 2) (by omega)
    have hg := two_mul_genus_K (n := n) (by omega)
    push_cast [hmc] at hst hsplit ⊢
    linarith
  · intro hex
    set q : Fin n := ⟨0, hnpos⟩ with hqdef
    have hq : q.val = 0 := rfl
    refine not_rankAtLeast_zero_of_isReduced_neg (K n) (connected_K hnpos)
      (isReduced_stairF q hq) ?_ ((rankAtLeast_zero_iff (K n) _).mpr hex)
    rw [stairF_apply_zero q hq]
    norm_num

/-! ## Ceiling weights and their counting identity -/

/-- `wt n a j` is `⌈(a - j)/n⌉`, computed with truncated natural subtraction (so it
is `0` when `a ≤ j`). -/
def wt (n a j : ℕ) : ℕ := (a - j + n - 1) / n

/-- The defining property of the ceiling: `a ≤ j + n ⌈(a-j)/n⌉`. -/
lemma le_add_mul_wt {n : ℕ} (hn : 0 < n) (a j : ℕ) : a ≤ j + n * wt n a j := by
  have h := Nat.div_add_mod (a - j + n - 1) n
  have h2 : (a - j + n - 1) % n < n := Nat.mod_lt _ hn
  unfold wt
  omega

/-- `wt` is antitone in the shift `j`. -/
lemma wt_antitone {n a j j' : ℕ} (h : j ≤ j') : wt n a j' ≤ wt n a j :=
  Nat.div_le_div_right (by omega)

/-- Explicit value of the ceiling weight in terms of quotient and remainder. -/
lemma wt_eq {n a j Q R : ℕ} (hj : j < n) (hR : R < n) (ha : a = n * Q + R) :
    wt n a j = Q + (if j < R then 1 else 0) := by
  have hn : 0 < n := lt_of_le_of_lt (Nat.zero_le j) hj
  unfold wt
  by_cases h : j < R
  · have hnum : a - j + n - 1 = ((R - 1 - j) + n) + n * Q := by omega
    rw [hnum, Nat.add_mul_div_left _ _ hn, Nat.add_div_right _ hn,
      Nat.div_eq_of_lt (by omega : R - 1 - j < n)]
    simp only [h, if_true]
    omega
  · rcases Nat.eq_zero_or_pos Q with hQ | hQ
    · rw [hQ, Nat.mul_zero, Nat.zero_add] at ha
      have hnum : a - j + n - 1 = n - 1 := by omega
      rw [hnum, Nat.div_eq_of_lt (by omega : n - 1 < n)]
      simp only [h, if_false]
      omega
    · have hQn : n ≤ n * Q := Nat.le_mul_of_pos_right n hQ
      have hnum : a - j + n - 1 = (R + n - 1 - j) + n * Q := by omega
      rw [hnum, Nat.add_mul_div_left _ _ hn,
        Nat.div_eq_of_lt (by omega : R + n - 1 - j < n)]
      simp only [h, if_false]
      omega

/-- **The counting identity.**  Summing the ceiling weights over the first `m` shifts
gives `m ⌊a/n⌋ + min m (a mod n)`. -/
lemma sum_wt_eq {n m a Q R : ℕ} (hm : m ≤ n) (hR : R < n) (ha : a = n * Q + R) :
    ∑ j ∈ range m, wt n a j = m * Q + min m R := by
  have h1 : ∀ j ∈ range m, wt n a j = Q + (if j < R then 1 else 0) := by
    intro j hjm
    exact wt_eq (lt_of_lt_of_le (Finset.mem_range.mp hjm) hm) hR ha
  rw [Finset.sum_congr rfl h1, Finset.sum_add_distrib, Finset.sum_const,
    Finset.card_range, smul_eq_mul, Finset.sum_ite, Finset.sum_const, Finset.sum_const]
  have h2 : (range m).filter (fun j => j < R) = range (min m R) := by
    ext j; simp only [Finset.mem_filter, Finset.mem_range]; omega
  rw [h2, Finset.card_range]
  simp

/-- The ceiling weights over the first `m` shifts never overshoot `a`. -/
lemma sum_wt_le_self {n m a : ℕ} (hmn : m + 2 ≤ n) : ∑ j ∈ range m, wt n a j ≤ a := by
  have hn : 0 < n := by omega
  have ha : a = n * (a / n) + a % n := (Nat.div_add_mod a n).symm
  rw [sum_wt_eq (by omega) (Nat.mod_lt _ hn) ha]
  have hq : m * (a / n) ≤ n * (a / n) := Nat.mul_le_mul_right _ (by omega)
  omega

/-- If `a` exceeds `m` then the sum of ceiling weights is *strictly* below `a`.  This
strictness is what forces the existence of a workable firing threshold. -/
lemma sum_wt_lt_self {n m a : ℕ} (hmn : m + 2 ≤ n) (ha : m + 1 ≤ a) :
    ∑ j ∈ range m, wt n a j + 1 ≤ a := by
  have hn : 0 < n := by omega
  have hdm : a = n * (a / n) + a % n := (Nat.div_add_mod a n).symm
  rw [sum_wt_eq (by omega) (Nat.mod_lt _ hn) hdm]
  rcases Nat.eq_zero_or_pos (a / n) with hq0 | hq0
  · rw [hq0] at hdm ⊢
    omega
  · have hq : (m + 2) * (a / n) ≤ n * (a / n) := Nat.mul_le_mul_right _ (by omega)
    have hq2 : (m + 2) * (a / n) = m * (a / n) + 2 * (a / n) := by ring
    omega

/-! ## The lower bound -/

/-- **Every constant divisor on a complete graph has rank at least `m (m+3)/2`.**

The proof exhibits a single global firing vector: for the optimal threshold `t` the
vector `f v = ⌈(E v - (m - t))/n⌉ - 1` makes `m · 1 - E + lap f` effective. -/
theorem rankAtLeast_const_K {n m r : ℕ} (hn : m + 2 ≤ n) (hr : 2 * r = m * (m + 3)) :
    RankAtLeast (K n) (fun _ => (m : ℤ)) r := by
  classical
  have hnpos : 0 < n := by omega
  intro E hE hdeg
  set A : Fin n → ℕ := fun v => (E v).toNat with hAdef
  have hAE : ∀ v, ((A v : ℤ)) = E v := fun v => Int.toNat_of_nonneg (hE v)
  have hsumA : ∑ v, A v = r := by
    have : ((∑ v, A v : ℕ) : ℤ) = (r : ℤ) := by
      push_cast
      rw [Finset.sum_congr rfl (fun v _ => hAE v)]
      exact hdeg
    exact_mod_cast this
  by_cases hall : ∀ v, A v ≤ m
  · refine ⟨0, fun v => ?_⟩
    have h1 : ((A v : ℤ)) ≤ (m : ℤ) := by exact_mod_cast hall v
    rw [hAE v] at h1
    simp only [lap_zero, Pi.add_apply, Pi.sub_apply, Pi.zero_apply, add_zero]
    linarith
  · push_neg at hall
    obtain ⟨v₀, hv₀⟩ := hall
    set T : ℕ → ℕ := fun t => ∑ v, wt n (A v) (m - t) with hTdef
    have hTmono : ∀ s t : ℕ, s ≤ t → T s ≤ T t := by
      intro s t hst
      exact Finset.sum_le_sum (fun v _ => wt_antitone (by omega))
    have hT1 : 1 ≤ T 1 := by
      have hone : 1 ≤ wt n (A v₀) (m - 1) := by
        unfold wt
        have : n ≤ A v₀ - (m - 1) + n - 1 := by omega
        exact Nat.one_le_div_iff hnpos |>.mpr this
      exact le_trans hone
        (Finset.single_le_sum (f := fun v => wt n (A v) (m - 1))
          (fun _ _ => Nat.zero_le _) (Finset.mem_univ v₀))
    -- The counting argument: some threshold in `[1, m]` works.
    have hEx : ∃ t, 1 ≤ t ∧ t ≤ m ∧ T t ≤ t := by
      by_contra hcon
      push_neg at hcon
      have hlow : ∀ t ∈ range m, t + 2 ≤ T (t + 1) :=
        fun t ht => hcon (t + 1) (by omega) (by simpa using Finset.mem_range.mp ht)
      have h1 : ∑ t ∈ range m, (t + 2) ≤ ∑ t ∈ range m, T (t + 1) := Finset.sum_le_sum hlow
      have h2 : ∑ t ∈ range m, T (t + 1) = ∑ v, ∑ j ∈ range m, wt n (A v) j := by
        rw [hTdef]
        rw [Finset.sum_comm]
        refine Finset.sum_congr rfl fun v _ => ?_
        rw [← Finset.sum_range_reflect (fun j => wt n (A v) j) m]
        exact Finset.sum_congr rfl fun t _ => by congr 1; omega
      have h3 : ∑ v, ∑ j ∈ range m, wt n (A v) j < ∑ v, A v := by
        refine Finset.sum_lt_sum (fun v _ => sum_wt_le_self hn) ⟨v₀, Finset.mem_univ v₀, ?_⟩
        have := sum_wt_lt_self (n := n) (m := m) (a := A v₀) hn (by omega)
        omega
      have h4 : 2 * ∑ t ∈ range m, (t + 2) = m * (m + 3) := by
        have hg := Finset.sum_range_id_mul_two m
        have hsplit : ∑ t ∈ range m, (t + 2) = (∑ t ∈ range m, t) + 2 * m := by
          rw [Finset.sum_add_distrib, Finset.sum_const, Finset.card_range]
          ring
        have hmm : m * (m + 3) = m * (m - 1) + 4 * m := by
          cases m with
          | zero => simp
          | succ k => simp only [Nat.succ_sub_one]; ring
        omega
      omega
    have hspec := Nat.find_spec hEx
    set t := Nat.find hEx with htdef
    obtain ⟨ht1, htm, htle⟩ := hspec
    -- minimality forces the threshold to be a fixed point
    have hTeq : T t = t := by
      rcases Nat.lt_or_ge t 2 with h | h
      · have ht : t = 1 := by omega
        rw [ht] at htle ⊢
        omega
      · have hmin := Nat.find_min hEx (m := t - 1) (by omega)
        push_neg at hmin
        have h5 : t - 1 < T (t - 1) := by
          have := hmin (by omega) (by omega)
          omega
        have h6 := hTmono (t - 1) t (by omega)
        omega
    -- the global firing vector
    refine ⟨fun v => (wt n (A v) (m - t) : ℤ) - 1, fun v => ?_⟩
    have hsumf : ∑ u, ((wt n (A u) (m - t) : ℤ) - 1) = (t : ℤ) - n := by
      rw [Finset.sum_sub_distrib, Finset.sum_const, Finset.card_univ, Fintype.card_fin]
      have : ∑ u, (wt n (A u) (m - t) : ℤ) = ((T t : ℕ) : ℤ) := by
        rw [hTdef]; push_cast; rfl
      rw [this, hTeq]
      simp
    have hlap := lap_K (n := n) (fun v => (wt n (A v) (m - t) : ℤ) - 1) v
    rw [hsumf] at hlap
    have hkey : A v + t ≤ m + n * wt n (A v) (m - t) := by
      have := le_add_mul_wt (n := n) hnpos (A v) (m - t)
      omega
    have hkeyZ : (A v : ℤ) + (t : ℤ) ≤ (m : ℤ) + (n : ℤ) * (wt n (A v) (m - t) : ℤ) := by
      exact_mod_cast hkey
    have hEv : E v = (A v : ℤ) := (hAE v).symm
    simp only [Pi.add_apply, Pi.sub_apply, hlap, hEv]
    linarith

/-! ## The exact rank, and consequences -/

/-- **The exact Baker–Norine rank of a constant divisor on a complete graph.**
On `K n` with `n ≥ m + 2` the divisor with `m` chips at every vertex has rank exactly
`m (m + 3) / 2` — in particular the rank is *independent of `n`* and quadratic in `m`. -/
theorem rank_const_K {n m r : ℕ} (hn : m + 2 ≤ n) (hr : 2 * r = m * (m + 3)) :
    RankAtLeast (K n) (fun _ => (m : ℤ)) r ∧ ¬ RankAtLeast (K n) (fun _ => (m : ℤ)) (r + 1) :=
  ⟨rankAtLeast_const_K hn hr, not_rankAtLeast_const_K hn hr⟩

/-- The integer-valued form of `rank_const_K`. -/
theorem rankBN_const_K {n m r : ℕ} [NeZero n] (hn : m + 2 ≤ n) (hr : 2 * r = m * (m + 3)) :
    rankBN (K n) (fun _ => (m : ℤ)) = r :=
  rankBN_eq_of_between (K n) (rankAtLeast_const_K hn hr) (not_rankAtLeast_const_K hn hr)

/-- **One-shot threshold firing is not sharp.**  For `m ≥ 3` the true rank of the
constant divisor `m` on `K n` strictly exceeds the best bound `2m + ⌊m²/4⌋` obtainable
from a single threshold set firing (`rankAtLeast_of_threshold_quadratic`). -/
theorem rank_const_K_gt_threshold_bound {n m r : ℕ} [NeZero n] (hn : m + 2 ≤ n) (hm : 3 ≤ m)
    (hr : 2 * r = m * (m + 3)) :
    2 * m + m * m / 4 < (rankBN (K n) (fun _ => (m : ℤ))).toNat := by
  rw [rankBN_const_K hn hr]
  simp only [Int.toNat_natCast]
  have h2 : 3 * m ≤ m * m := Nat.mul_le_mul_right m hm
  have h3 : m * (m + 3) = m * m + 3 * m := by ring
  omega

/-- The rank of the constant divisor grows quadratically: `2 r = m² + 3m`. -/
theorem two_mul_rank_const_K {n m : ℕ} [NeZero n] (hn : m + 2 ≤ n) :
    2 * (rankBN (K n) (fun _ => (m : ℤ))).toNat = m * m + 3 * m := by
  obtain ⟨r, hr⟩ : ∃ r : ℕ, 2 * r = m * (m + 3) := by
    refine ⟨m * (m + 3) / 2, ?_⟩
    have hdvd : 2 ∣ m * (m + 3) := by
      rcases Nat.even_or_odd m with h | h
      · obtain ⟨k, hk⟩ := h
        exact ⟨k * (m + 3), by rw [hk]; ring⟩
      · obtain ⟨k, hk⟩ := h
        exact ⟨m * (k + 2), by rw [hk]; ring⟩
    obtain ⟨c, hc⟩ := hdvd
    omega
  have h3 : m * (m + 3) = m * m + 3 * m := by ring
  rw [rankBN_const_K hn hr]
  simp only [Int.toNat_natCast]
  omega

/-! ## The half-canonical theta characteristic of an odd complete graph -/

/-- **The half-canonical theta characteristic of `K_{2m+3}`.**  On the complete graph
with an odd number `n = 2m + 3` of vertices the constant divisor `m` is a theta
characteristic (`2 D = K` on the nose), it has the half-canonical degree `g - 1`, and
its Baker–Norine rank is *exactly* `m (m + 3) / 2`. -/
theorem thetaChar_halfCanonical_K_odd {m r : ℕ} (hr : 2 * r = m * (m + 3)) :
    IsThetaChar (K (2 * m + 3)) (fun _ => (m : ℤ)) ∧
      deg ((fun _ => (m : ℤ)) : Divisor (Fin (2 * m + 3))) = genus (K (2 * m + 3)) - 1 ∧
      rankBN (K (2 * m + 3)) (fun _ => (m : ℤ)) = r := by
  haveI : NeZero (2 * m + 3) := ⟨by omega⟩
  refine ⟨⟨0, ?_⟩, ?_, rankBN_const_K (by omega) hr⟩
  · funext v
    have hd : ((2 * m + 3 - 1 : ℕ) : ℤ) = 2 * (m : ℤ) + 2 := by omega
    simp only [canonical, degree_K, lap_zero, Pi.add_apply, Pi.zero_apply, add_zero, hd]
    ring
  · have hg := two_mul_genus_K (n := 2 * m + 3) (by omega)
    have hd : deg ((fun _ => (m : ℤ)) : Divisor (Fin (2 * m + 3))) = (2 * (m : ℤ) + 3) * m := by
      simp only [deg, Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
      push_cast
      ring
    rw [hd]
    push_cast at hg ⊢
    linarith

/-- **The half-canonical rank on a complete graph is quadratic in the regularity.**
`K_{2m+3}` is `k`-regular with `k = 2m + 2`, and the theta characteristic of
`thetaChar_halfCanonical_K_odd` has rank `m(m+3)/2 ≥ k - 1 = 2m + 1` for `m ≥ 2`, with
strict inequality as soon as `m ≥ 3`; so the general half-canonical bound `k - 1` of
`exists_halfCanonical_rank_conjecture` is very far from sharp on complete graphs. -/
theorem rank_thetaChar_K_odd_ge_regularity {m r : ℕ} (hm : 2 ≤ m) (hr : 2 * r = m * (m + 3)) :
    2 * m + 1 ≤ r ∧ (3 ≤ m → 2 * m + 1 < r) := by
  have h1 : 2 * m ≤ m * m := Nat.mul_le_mul_right m hm
  have h2 : m * (m + 3) = m * m + 3 * m := by ring
  refine ⟨by omega, fun h3 => ?_⟩
  have h4 : 3 * m ≤ m * m := Nat.mul_le_mul_right m h3
  omega

/-- **Complete graphs are extremely far from Brill–Noether general.**  On `K_{2m+3}` the
half-canonical theta characteristic has rank `r` with `4 r > g`: a positive proportion
(asymptotically a quarter) of the genus, whereas the Brill–Noether heuristic predicts
rank of order `√g` at degree `g - 1`. -/
theorem four_mul_rank_gt_genus_K_odd {m r : ℕ} (hm : 1 ≤ m) (hr : 2 * r = m * (m + 3)) :
    genus (K (2 * m + 3)) < 4 * (r : ℤ) := by
  have hg := two_mul_genus_K (n := 2 * m + 3) (by omega)
  have hrZ : 2 * (r : ℤ) = (m : ℤ) * ((m : ℤ) + 3) := by exact_mod_cast hr
  have hmZ : (1 : ℤ) ≤ (m : ℤ) := by exact_mod_cast hm
  push_cast at hg
  nlinarith [hg, hrZ, hmZ]

end BrillNoetherCompleteExact