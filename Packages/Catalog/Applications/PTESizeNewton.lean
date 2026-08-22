/-
Copyright (c) 2026. Released under Apache 2.0 license.
-/
import Mathlib
import Applications.InvisibleWeightVectors
import Applications.InvisibleWeightsSupport

/-!
# The sharp `ℓ¹` law for invisible weight vectors: `ℓ¹ ≥ 2K`

The Lagrange engine of `Shared/PowerSumSharpness.lean` and the structure theorem of
`Applications/InvisibleWeightVectors.lean` describe *which* weight vectors are invisible to
the power-sum window `k < K`.  What they do not measure is the **cost** of invisibility.
`Applications/InvisibleWeightsSupport.lean` gave the node count `≥ K + 1` and hence the
integral bound `ℓ¹ ≥ K + 1`, and `Applications/InvisibleWeightsSharpLower.lean` improved
this to `K + 2` (and `K + 3` for odd `K`) by a geometric argument on the node set.

This file replaces those linear-in-`K` bounds by the exact law

  `∑_j |e j| ≥ 2 K`

for every nonzero integral vector invisible to the window `k < K`.  The bound is *sharp*
for every `K ≤ 10` and for `K = 12` (see `Applications/PTEIdealWitnesses.lean`), so it is
the true growth law of the problem in the range where witnesses are known.

The mechanism is completely different from the Lagrange engine: instead of testing the
window against Lagrange basis polynomials (which only ever sees the *support*), we use
**Newton's identities** to convert the vanishing power sums into vanishing *elementary
symmetric functions* of the two multisets of nodes, counted with multiplicity.  Equal
elementary symmetric functions up to order `K - 1` force the two monic root polynomials to
agree in their top `K` coefficients; if the common size `n` of the multisets were `< K`
the two polynomials would be equal outright, hence the multisets equal, contradicting that
the vector is nonzero.  So `n ≥ K` and `ℓ¹ = 2 n ≥ 2 K`.

## Main results

* `multiset_newton` — Newton's identity for a multiset of rationals, transferred from
  Mathlib's `MvPolynomial.mul_esymm_eq_sum` along `aeval`.
* `esymm_eq_of_powerSum_eq` — equal power sums throughout a window force equal elementary
  symmetric functions throughout the same window.
* `multiset_eq_of_powerSums` — **a multiset of size `n` over `ℚ` is determined by its power
  sums `p_0, …, p_n`**; the `ℕ`-valued version is `multiset_nat_eq_of_powerSums`.
* `card_ge_window_of_nearMiss` — **the size law.**  A near miss at window `K` (two distinct
  multisets of naturals with equal power sums `p_k`, `k < K`) has `card ≥ K` on both sides.
* `l1_ge_two_mul_window` — **the `ℓ¹` law.**  A nonzero integral vector invisible to the
  window `k < K` satisfies `2 K ≤ ∑_{j ≤ N} |e j|`.
* `nearMiss_card_add_card_ge_two_mul` — the multiset form: a near miss at window `K` uses at
  least `2 K` elements in total.
* `l1_ge_two_mul_window_strengthens` — an explicit comparison showing the new bound beats
  the catalog's `K + 2` for every `K ≥ 3`.

-- !-- Lab Notes -- !--

HYPOTHESIS (Hypothesizer).  The catalog's lower bounds (`K + 1`, `K + 2`, `K + 3`) all come
from *support* arguments and therefore cannot exceed the number of distinct nodes, whereas
the known witnesses (Prouhet–Tarry–Escott solutions) have `ℓ¹ = 2K`.  Bold conjecture: the
truth is `ℓ¹ ≥ 2K`, i.e. **invisibility of order `K` costs `K` units of mass on each side**,
and the cost is governed by root multisets rather than by node sets.

EXPERIMENT (Experimenter).  Proved below.  Numerically: at `K = 3` the catalog's sharp value
`6` equals `2K`; at `K = 4, …, 10, 12` explicit ideal PTE pairs realise `2K`
(`Applications/PTEIdealWitnesses.lean`), so the inequality is tight wherever tightness can
currently be tested.  The proof needs char `0` (Newton's identities divide by `k`), which is
harmless here since the nodes are natural numbers.

ANALYSIS (Analyst).  The support bound `K + 1` and the mass bound `2K` measure different
things and neither implies the other: the support bound is about *distinct* nodes, the mass
bound about *multiplicity*.  A vector with `K + 1` nodes must therefore carry total mass at
least `2K`, so its average multiplicity is at least `2K / (K+1) → 2`: minimal-support
invisible vectors are necessarily "thick".  This explains, post hoc, why the
minimal-support witnesses (the shifted binomial vectors) have mass `2^K`, exponentially
above `2K` — minimal support and minimal mass are mutually exclusive optima for `K ≥ 4`.

CRITIQUE (Critic).  No vacuity: `l1_ge_two_mul_window` has a genuinely nonzero hypothesis
(`e j₀ ≠ 0`) and is attained (see the witness file).  The hypothesis `K ≥ 1` is not needed:
for `K = 0` the statement `0 ≤ ℓ¹` is true and the proof handles it uniformly.  The Newton
transfer is not circular: it uses Mathlib's `MvPolynomial` Newton identities, not the
catalog's Lagrange engine, and the catalog's own bounds are never invoked.
-/

open Finset Multiset Polynomial

namespace PTESize

open PowerSumSharpness InvisibleWeights

/-! ## Newton's identities for a multiset -/

/-- Every multiset of rationals is the image of a vector indexed by a `Fin n`. -/
lemma exists_fin_repr (s : Multiset ℚ) :
    ∃ (n : ℕ) (f : Fin n → ℚ), Multiset.map f Finset.univ.val = s := by
  refine ⟨s.toList.length, s.toList.get, ?_⟩
  have h1 : Multiset.map s.toList.get Finset.univ.val
      = ↑((List.finRange s.toList.length).map s.toList.get) := by
    simp [Finset.univ, Fintype.elems]
  rw [h1, List.map_get_finRange, Multiset.coe_toList]

/-- **Newton's identity for multisets.**  For a multiset `s` of rationals,
`k · e_k(s) = (-1)^{k+1} ∑_{a + b = k, a < k} (-1)^a e_a(s) p_b(s)`. -/
lemma multiset_newton (s : Multiset ℚ) (k : ℕ) :
    (k : ℚ) * s.esymm k = (-1) ^ (k + 1) *
      ∑ a ∈ antidiagonal k with a.1 < k,
        (-1) ^ a.1 * s.esymm a.1 * (s.map (fun x => x ^ a.2)).sum := by
  obtain ⟨n, f, rfl⟩ := exists_fin_repr s
  have h := congrArg (MvPolynomial.aeval f) (MvPolynomial.mul_esymm_eq_sum (Fin n) ℚ k)
  simp only [map_mul, map_sum, map_pow, map_neg, map_one, map_natCast,
    MvPolynomial.aeval_esymm_eq_multiset_esymm] at h
  rw [h]
  congr 1
  refine Finset.sum_congr rfl fun a _ => ?_
  simp only [MvPolynomial.psum, map_sum, map_pow, MvPolynomial.aeval_X, Multiset.map_map]
  congr 1

/-- **Power sums control elementary symmetric functions.**  If two multisets of rationals
have the same power sums `p_m` for all `m < K`, then they have the same elementary symmetric
functions `e_k` for all `k < K`. -/
theorem esymm_eq_of_powerSum_eq {K : ℕ} {s t : Multiset ℚ}
    (h : ∀ m < K, (s.map (fun x => x ^ m)).sum = (t.map (fun x => x ^ m)).sum) :
    ∀ k < K, s.esymm k = t.esymm k := by
  intro k
  induction k using Nat.strong_induction_on with
  | _ k ih =>
    intro hk
    rcases Nat.eq_zero_or_pos k with rfl | hkpos
    · simp [Multiset.esymm]
    · have hs := multiset_newton s k
      have ht := multiset_newton t k
      have hsum : ∑ a ∈ antidiagonal k with a.1 < k,
            (-1 : ℚ) ^ a.1 * s.esymm a.1 * (s.map (fun x => x ^ a.2)).sum
          = ∑ a ∈ antidiagonal k with a.1 < k,
            (-1 : ℚ) ^ a.1 * t.esymm a.1 * (t.map (fun x => x ^ a.2)).sum := by
        refine Finset.sum_congr rfl fun a ha => ?_
        simp only [Finset.mem_filter, Finset.mem_antidiagonal] at ha
        rw [ih a.1 ha.2 (by omega), h a.2 (by omega)]
      have hkey : (k : ℚ) * s.esymm k = (k : ℚ) * t.esymm k := by rw [hs, ht, hsum]
      exact mul_left_cancel₀ (Nat.cast_ne_zero.mpr (by omega : k ≠ 0)) hkey

/-- **A multiset of size `n` over `ℚ` is determined by its power sums `p_0, …, p_n`.**
(The `m = 0` instance is what forces the two multisets to have the same cardinality.) -/
theorem multiset_eq_of_powerSums {s t : Multiset ℚ}
    (h : ∀ m ≤ Multiset.card s, (s.map (fun x => x ^ m)).sum = (t.map (fun x => x ^ m)).sum) :
    s = t := by
  have hcard : Multiset.card s = Multiset.card t := by
    have := h 0 (Nat.zero_le _)
    simpa using this
  have hes := esymm_eq_of_powerSum_eq (K := Multiset.card s + 1) (fun m hm => h m (by omega))
  have hP : (s.map fun a => X - C a).prod = (t.map fun a => X - C a).prod := by
    rw [Multiset.prod_X_sub_X_eq_sum_esymm, Multiset.prod_X_sub_X_eq_sum_esymm, ← hcard]
    refine Finset.sum_congr rfl fun j hj => ?_
    rw [hes j (Nat.lt_succ_of_le (Nat.lt_succ_iff.mp (Finset.mem_range.mp hj)))]
  have hroots := congrArg Polynomial.roots hP
  rwa [Polynomial.roots_multiset_prod_X_sub_C, Polynomial.roots_multiset_prod_X_sub_C] at hroots

/-! ## The `ℕ`-valued version -/

lemma powerSum_eq_rat_powerSum (s : Multiset ℕ) (m : ℕ) :
    ((Multiset.map (Nat.cast : ℕ → ℚ) s).map (fun x => x ^ m)).sum = ((powerSum s m : ℤ) : ℚ) := by
  simp [powerSum, Multiset.map_map, Function.comp]

/-- **Determination for multisets of naturals.**  A multiset of naturals of size `n` is
determined by the power sums `p_0, …, p_n`. -/
theorem multiset_nat_eq_of_powerSums {s t : Multiset ℕ}
    (h : ∀ m ≤ Multiset.card s, powerSum s m = powerSum t m) : s = t := by
  have hmap : Multiset.map (Nat.cast : ℕ → ℚ) s = Multiset.map (Nat.cast : ℕ → ℚ) t := by
    refine multiset_eq_of_powerSums (fun m hm => ?_)
    rw [powerSum_eq_rat_powerSum, powerSum_eq_rat_powerSum]
    have hm' : m ≤ Multiset.card s := by simpa using hm
    rw [h m hm']
  exact Multiset.map_injective (f := fun x : ℕ => (x : ℚ)) Nat.cast_injective hmap

/-! ## The size law for near misses -/

/-- **The size law.**  If two *distinct* multisets of naturals have the same power sums
throughout the window `k < K`, then each of them has at least `K` elements (counted with
multiplicity).  This is the exact Prouhet–Tarry–Escott bound "size ≥ degree + 1", proved
here for multisets rather than sets. -/
theorem card_ge_window_of_nearMiss {K : ℕ} {s t : Multiset ℕ}
    (h : ∀ k < K, powerSum s k = powerSum t k) (hne : s ≠ t) :
    K ≤ Multiset.card s := by
  by_contra hlt
  push_neg at hlt
  exact hne (multiset_nat_eq_of_powerSums (fun m hm => h m (by omega)))

/-- The same bound on the other side of the near miss. -/
theorem card_ge_window_of_nearMiss' {K : ℕ} {s t : Multiset ℕ}
    (h : ∀ k < K, powerSum s k = powerSum t k) (hne : s ≠ t) :
    K ≤ Multiset.card t :=
  card_ge_window_of_nearMiss (fun k hk => (h k hk).symm) (Ne.symm hne)

/-- **Total mass of a near miss.**  A near miss at window `K` spends at least `2K` elements
in total. -/
theorem nearMiss_card_add_card_ge_two_mul {K : ℕ} {s t : Multiset ℕ}
    (h : ∀ k < K, powerSum s k = powerSum t k) (hne : s ≠ t) :
    2 * K ≤ Multiset.card s + Multiset.card t := by
  have h1 := card_ge_window_of_nearMiss h hne
  have h2 := card_ge_window_of_nearMiss' h hne
  omega

/-! ## The `ℓ¹` law -/

lemma card_ofCounts (N : ℕ) (c : ℕ → ℕ) :
    (Multiset.card (ofCounts N c) : ℤ) = ∑ j ∈ range (N + 1), (c j : ℤ) := by
  have h := powerSum_ofCounts N c 0
  rw [powerSum_index_zero] at h
  simpa using h

/-- **The `ℓ¹` law.**  A nonzero integral weight vector invisible to the window `k < K`
carries total mass at least `2K`.  This strictly improves the catalog's `K + 1`
(`InvisibleWeights.l1_ge_of_invisible_int`) and `K + 2`
(`InvisibleWeights.l1_ge_window_add_two`) for every `K ≥ 3`. -/
theorem l1_ge_two_mul_window {N K : ℕ} {e : ℕ → ℤ} (he : Invisible N K e)
    {j₀ : ℕ} (hj₀ : j₀ ≤ N) (hne : e j₀ ≠ 0) :
    (2 * K : ℤ) ≤ ∑ j ∈ range (N + 1), |e j| := by
  obtain ⟨-, -, hdist, hpow⟩ := nearMiss_of_invisible he hj₀ hne
  have hpos := card_ge_window_of_nearMiss hpow hdist
  have hneg := card_ge_window_of_nearMiss' hpow hdist
  have hsum : ∑ j ∈ range (N + 1), |e j|
      = (Multiset.card (posMultiset N e) : ℤ) + (Multiset.card (negMultiset N e) : ℤ) := by
    rw [posMultiset, negMultiset, card_ofCounts, card_ofCounts, ← Finset.sum_add_distrib]
    refine Finset.sum_congr rfl fun j _ => ?_
    simp only [InvisibleWeights.posPart, InvisibleWeights.negPart, Int.abs_eq_natAbs]
    omega
  rw [hsum]
  have h1 : (K : ℤ) ≤ (Multiset.card (posMultiset N e) : ℤ) := by exact_mod_cast hpos
  have h2 : (K : ℤ) ≤ (Multiset.card (negMultiset N e) : ℤ) := by exact_mod_cast hneg
  linarith

/-- The improvement is genuine: for `K ≥ 3` the new bound is strictly larger than the
catalog's `K + 2`, and the gap `K - 2` grows without bound. -/
theorem l1_ge_two_mul_window_strengthens {N K : ℕ} (hK : 3 ≤ K) {e : ℕ → ℤ}
    (he : Invisible N K e) {j₀ : ℕ} (hj₀ : j₀ ≤ N) (hne : e j₀ ≠ 0) :
    ((K : ℤ) + 2) < ∑ j ∈ range (N + 1), |e j| ∧
      (2 * K : ℤ) - ((K : ℤ) + 2) = (K : ℤ) - 2 := by
  have h := l1_ge_two_mul_window he hj₀ hne
  have hK' : (3 : ℤ) ≤ (K : ℤ) := by exact_mod_cast hK
  constructor
  · linarith
  · ring

/-- **Corollary in the multiset language.**  A near miss whose two sides have *no repeated
elements* (both are sets) needs at least `K` distinct nodes on each side; combined with the
support bound `K + 1` of the catalog this pins the shape of extremal examples. -/
theorem nearMiss_card_ge_of_nodup {K : ℕ} {s t : Multiset ℕ}
    (h : ∀ k < K, powerSum s k = powerSum t k) (hne : s ≠ t) (hs : s.Nodup) :
    K ≤ s.toFinset.card := by
  have := card_ge_window_of_nearMiss h hne
  rwa [← Multiset.toFinset_card_of_nodup hs] at this

end PTESize