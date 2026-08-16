/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Bridges.DeepestRungSharpness

/-!
# A two-sided knee law: the inverse-square tail ceiling (cycle 4)

Cycle 1 proved the concentration **floor** `k ≥ τ² · eff`, and cycle 3 showed it is sharp in
the exponent but loose by a factor `τ` on flat profiles, so no ceiling can follow from the
participation ratio alone (Conjecture 1 of `FUTURE_DIRECTIONS.md`).  This cycle supplies the
missing half under an explicit tail hypothesis, in the discrete case `α = 2` where the tail
sum telescopes exactly.

**Setting.**  An attention row `a` has an *inverse-square tail with constant `c`* if some
ranking `σ` of the keys satisfies `p(σ i) ≤ c / (i+1)²`.  Then

* `tail_sum_inv_sq_le` : `∑_{j ≥ k} 1/(j+1)² ≤ 1/k` (telescoping, exact),
* `bestMass_ge_of_inverse_square_tail` : `bestMass a k ≥ 1 − c/k`,
* `tail_ceiling` : every width `k ≥ c/(1−τ)` reaches mass `τ`,
* `knee_sandwich` : combining with the floor, the mass-knee obeys
  `τ² · eff ≤ k* ≤ ⌈c/(1−τ)⌉`.

The sandwich is the first *two-sided* statement about the knee in this thread: the floor is
driven by concentration, the ceiling by tail decay, and their ratio measures how far a
measured profile is from the extremal ones of cycle 3.

## Main results

* `tail_sum_inv_sq_le`
* `bestMass_ge_of_inverse_square_tail`
* `tail_ceiling`
* `knee_sandwich`
* `net43_tail_ceiling_at_256`
-/

namespace Bridges.DeepestRungTwoSeed256

open Finset

/-- **Telescoping tail bound.**  `∑_{j=k}^{n-1} 1/(j+1)² ≤ 1/k` for `k ≥ 1`. -/
theorem tail_sum_inv_sq_le (k n : ℕ) (hk : 1 ≤ k) :
    ∑ j ∈ Finset.Ico k n, (1:ℝ) / ((j:ℝ) + 1) ^ 2 ≤ 1 / (k:ℝ) := by
  rcases (by omega : n ≤ k ∨ k < n) with h | h
  · rw [Finset.Ico_eq_empty (by omega)]
    positivity
  · have key : ∀ m, k ≤ m →
        ∑ j ∈ Finset.Ico k m, (1:ℝ) / ((j:ℝ) + 1) ^ 2 ≤ 1 / (k:ℝ) - 1 / (m:ℝ) := by
      intro m hm
      induction m, hm using Nat.le_induction with
      | base => simp
      | succ m hm ih =>
          rw [Finset.sum_Ico_succ_top hm]
          have hm1 : (1:ℝ) ≤ (m:ℝ) := by exact_mod_cast le_trans hk hm
          have e : (1:ℝ) / (m:ℝ) - 1 / ((m:ℝ) + 1) = 1 / ((m:ℝ) * ((m:ℝ) + 1)) := by
            field_simp
            ring
          have h1 : (1:ℝ) / ((m:ℝ) + 1) ^ 2 ≤ 1 / (m:ℝ) - 1 / ((m:ℝ) + 1) := by
            rw [e]
            apply one_div_le_one_div_of_le (by nlinarith)
            nlinarith
          push_cast
          linarith
    refine le_trans (key n h.le) ?_
    have hn : (0:ℝ) < (n:ℝ) := by exact_mod_cast lt_of_lt_of_le hk h.le
    have hpos : (0:ℝ) < 1 / (n:ℝ) := by positivity
    linarith

/-- **Tail ceiling on the top-`k` mass.**  If some ranking of the keys has an inverse-square
tail with constant `c`, then the top-`k` selection already captures mass `1 − c/k`. -/
theorem bestMass_ge_of_inverse_square_tail {n : ℕ} (a : AttnDist n) {c : ℝ} (hc : 0 ≤ c)
    (σ : Equiv.Perm (Fin n)) (hdecay : ∀ i : Fin n, a.p (σ i) ≤ c / (((i : ℕ) : ℝ) + 1) ^ 2)
    {k : ℕ} (hk : 1 ≤ k) : 1 - c / k ≤ bestMass a k := by
  classical
  set S : Finset (Fin n) := Finset.univ.filter (fun x : Fin n => ((σ.symm x : Fin n) : ℕ) < k)
    with hS
  -- the selected set has at most `k` keys
  have hcard : S.card ≤ k := by
    have hinj : Set.InjOn (fun x : Fin n => ((σ.symm x : Fin n) : ℕ)) S := by
      intro x _ y _ hxy
      have : σ.symm x = σ.symm y := Fin.ext hxy
      simpa using congrArg σ this
    have hmaps : Set.MapsTo (fun x : Fin n => ((σ.symm x : Fin n) : ℕ)) ↑S ↑(Finset.range k) := by
      intro x hx
      have hx' : x ∈ S := hx
      simp only [hS, Finset.mem_filter] at hx'
      simpa using hx'.2
    have := Finset.card_le_card_of_injOn _ hmaps hinj
    simpa using this
  -- the complement's mass is controlled by the tail sum
  have hsplit : ∑ x ∈ S, a.p x + ∑ x ∈ Finset.univ.filter
      (fun x : Fin n => ¬ ((σ.symm x : Fin n) : ℕ) < k), a.p x = 1 := by
    rw [Finset.sum_filter_add_sum_filter_not]
    exact a.sum_one
  have hreindex : ∑ x ∈ Finset.univ.filter (fun x : Fin n => ¬ ((σ.symm x : Fin n) : ℕ) < k),
      a.p x = ∑ j ∈ Finset.univ.filter (fun j : Fin n => ¬ ((j : ℕ) < k)), a.p (σ j) := by
    refine (Finset.sum_equiv σ ?_ ?_).symm
    · intro j
      simp
    · intro j _
      rfl
  have htail : ∑ j ∈ Finset.univ.filter (fun j : Fin n => ¬ ((j : ℕ) < k)), a.p (σ j)
      ≤ c / k := by
    have hbound : ∑ j ∈ Finset.univ.filter (fun j : Fin n => ¬ ((j : ℕ) < k)), a.p (σ j)
        ≤ ∑ j ∈ Finset.univ.filter (fun j : Fin n => ¬ ((j : ℕ) < k)),
            c / (((j : ℕ) : ℝ) + 1) ^ 2 :=
      Finset.sum_le_sum (fun j _ => hdecay j)
    have hset : (Finset.range n).filter (fun j : ℕ => ¬ (j < k)) = Finset.Ico k n := by
      ext j
      simp only [Finset.mem_filter, Finset.mem_range, Finset.mem_Ico, not_lt]
      omega
    have hcast : ∑ j ∈ Finset.univ.filter (fun j : Fin n => ¬ ((j : ℕ) < k)),
        c / (((j : ℕ) : ℝ) + 1) ^ 2
        = ∑ j ∈ Finset.Ico k n, c / ((j : ℝ) + 1) ^ 2 := by
      rw [Finset.sum_filter,
        Fin.sum_univ_eq_sum_range
          (fun j : ℕ => if ¬ (j < k) then c / ((j : ℝ) + 1) ^ 2 else 0) n,
        ← Finset.sum_filter, hset]
    have hfin : ∑ j ∈ Finset.Ico k n, c / ((j : ℝ) + 1) ^ 2 ≤ c / k := by
      have : ∑ j ∈ Finset.Ico k n, c / ((j : ℝ) + 1) ^ 2
          = c * ∑ j ∈ Finset.Ico k n, (1:ℝ) / ((j : ℝ) + 1) ^ 2 := by
        rw [Finset.mul_sum]
        exact Finset.sum_congr rfl (fun j _ => by ring)
      rw [this, div_eq_mul_one_div]
      exact mul_le_mul_of_nonneg_left (tail_sum_inv_sq_le k n hk) hc
    exact le_trans hbound (le_trans (le_of_eq hcast) hfin)
  have hmass : 1 - c / k ≤ ∑ x ∈ S, a.p x := by
    rw [hreindex] at hsplit
    linarith
  exact le_trans hmass (mass_le_bestMass a hcard)

/-- **The tail ceiling on the knee.**  Under an inverse-square tail with constant `c`, every
width `k ≥ c / (1 − τ)` reaches mass target `τ`. -/
theorem tail_ceiling {n : ℕ} (a : AttnDist n) {c τ : ℝ} (hc : 0 ≤ c) (hτ : τ < 1)
    (σ : Equiv.Perm (Fin n)) (hdecay : ∀ i : Fin n, a.p (σ i) ≤ c / (((i : ℕ) : ℝ) + 1) ^ 2)
    {k : ℕ} (hk : 1 ≤ k) (hbig : c / (1 - τ) ≤ (k : ℝ)) : τ ≤ bestMass a k := by
  have hkR : (0:ℝ) < (k : ℝ) := by exact_mod_cast hk
  have h1 : c / k ≤ 1 - τ := by
    rw [div_le_iff₀ hkR]
    rw [div_le_iff₀ (by linarith : (0:ℝ) < 1 - τ)] at hbig
    linarith
  have := bestMass_ge_of_inverse_square_tail a hc σ hdecay hk
  linarith

/-- **Two-sided knee law.**  Concentration bounds the knee from below and the tail from above:
for a target `τ ∈ (0,1)` under an inverse-square tail with constant `c`, every passing width
obeys `τ² · eff ≤ k`, and every width above `c/(1−τ)` passes. -/
theorem knee_sandwich {n : ℕ} (a : AttnDist n) {c τ : ℝ} (hc : 0 ≤ c) (hτ0 : 0 ≤ τ)
    (hτ : τ < 1) (σ : Equiv.Perm (Fin n))
    (hdecay : ∀ i : Fin n, a.p (σ i) ≤ c / (((i : ℕ) : ℝ) + 1) ^ 2) :
    (∀ k : ℕ, τ ≤ bestMass a k → τ ^ 2 * eff a ≤ (k : ℝ)) ∧
      (∀ k : ℕ, 1 ≤ k → c / (1 - τ) ≤ (k : ℝ) → τ ≤ bestMass a k) :=
  ⟨fun _ hpass => card_ge_of_bestMass_ge a hτ0 hpass,
   fun _ hk hbig => tail_ceiling a hc hτ σ hdecay hk hbig⟩

/-- **NET-43 instance.**  If the measured attention row at `(d = 32, ctx = 512)` has an
inverse-square tail with constant `c = 20`, then width `256` certifies mass at least `0.92`
— matching the measured top-`256` mass `0.922`, and bracketing the profile between the two
extremal families of cycle 3. -/
theorem net43_tail_ceiling_at_256 (a : AttnDist 512) (σ : Equiv.Perm (Fin 512))
    (hdecay : ∀ i : Fin 512, a.p (σ i) ≤ 20 / (((i : ℕ) : ℝ) + 1) ^ 2) :
    (0.92 : ℝ) ≤ bestMass a 256 := by
  refine tail_ceiling a (by norm_num) (by norm_num) σ hdecay (by norm_num) ?_
  norm_num

end Bridges.DeepestRungTwoSeed256