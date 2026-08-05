/-
# Affine subspace statistics in `𝔽₂ⁿ`: the exact value of the codimension-`m` construction

This file completes the analysis of the codimension-`m` lower-bound construction begun in
`Catalog/Applications/AffineSubspaceStats/CodimSubspace.lean`.  There it was shown that a
random affine `d`-cube meets the codimension-`m` subspace `A ⊆ 𝔽₂ⁿ` in exactly `2^{d-m}`
points *iff* the projected directions span `𝔽₂^m` (for `m ≤ d`), and that this happens with
probability at least `1 - (2^m - 1)/2^d`.

Here we compute the probability exactly:

`P[|F ∩ A| = 2^{d-m}] = ∏_{i<m} (1 - 2^{i-d})`,

for all `n ≥ m` and `d ≥ m`.  With `k = d - m` the right-hand side is
`∏_{t=k+1}^{d} (1 - 2^{-t})`, the exact value of the classical lower-bound construction for
the affine subspace statistics problem; in particular it is `≥ 1 - 2^{-k}` and tends to
`1 - 2^{-k}` from above only up to the explicit correction computed here.

The proof has three ingredients:

* the fibers of the coordinate projection `π : 𝔽₂ⁿ → 𝔽₂^m` all have the same size, so the
  count of good direction tuples in `𝔽₂ⁿ` reduces to the count of good tuples in `𝔽₂^m`
  (`card_surj_dirs`);
* `y ↦ ∑ yᵢwᵢ` is surjective iff the transposed family of `m` vectors of `𝔽₂^d` is linearly
  independent (`surj_iff_linearIndependent`);
* the number of linearly independent `m`-tuples in `𝔽₂^d` is `∏_{i<m}(2^d - 2^i)`
  (Mathlib's `card_linearIndependent`).
-/
import Mathlib
import Applications.AffineSubspaceStats.CodimSubspace

namespace AffineStats

open Finset

section Exact

variable {n m d : ℕ}

lemma proj_add (hmn : m ≤ n) (x y : Vec n) : proj hmn (x + y) = proj hmn x + proj hmn y := rfl

/-- All fibers of the coordinate projection `𝔽₂ⁿ → 𝔽₂^m` have the same size. -/
lemma card_proj_fiber_eq (hmn : m ≤ n) (w : Vec m) :
    (univ.filter fun x : Vec n => proj hmn x = w).card
      = (univ.filter fun x : Vec n => proj hmn x = 0).card := by
  obtain ⟨x₀, hx₀⟩ : ∃ x₀ : Vec n, proj hmn x₀ = w := by
    refine ⟨fun i => if h : i.val < m then w ⟨i.val, h⟩ else 0, ?_⟩
    funext j
    simp [proj, Fin.castLE]
  have hcancel : ∀ x : Vec n, x + x₀ + x₀ = x := by
    intro x; rw [add_assoc, vadd_self, add_zero]
  refine Finset.card_nbij' (fun x => x + x₀) (fun z => z + x₀) ?_ ?_ ?_ ?_
  · intro a ha
    simp only [Finset.mem_coe, mem_filter, mem_univ, true_and] at ha ⊢
    rw [proj_add hmn, ha, hx₀, vadd_self]
  · intro a ha
    simp only [Finset.mem_coe, mem_filter, mem_univ, true_and] at ha ⊢
    rw [proj_add hmn, ha, hx₀, zero_add]
  · intro a _; exact hcancel a
  · intro a _; exact hcancel a

/-- The projection is `2^{n-m}`-to-one: `2^m` times the fiber size is `2^n`. -/
lemma card_proj_fiber_mul (hmn : m ≤ n) :
    2 ^ m * (univ.filter fun x : Vec n => proj hmn x = 0).card = 2 ^ n := by
  classical
  have h := Finset.card_eq_sum_card_fiberwise (f := fun x : Vec n => proj hmn x)
    (s := univ) (t := (univ : Finset (Vec m))) (fun x _ => mem_univ _)
  rw [Finset.sum_congr rfl (fun w _ => card_proj_fiber_eq hmn w), Finset.sum_const,
    smul_eq_mul, Finset.card_univ, card_Vec, Finset.card_univ, card_Vec] at h
  omega

/-- Fibers of the induced map on direction tuples. -/
lemma card_tuple_fiber (hmn : m ≤ n) (w : Fin d → Vec m) :
    (univ.filter fun v : Fin d → Vec n => (fun i => proj hmn (v i)) = w).card
      = (univ.filter fun x : Vec n => proj hmn x = 0).card ^ d := by
  classical
  rw [show (univ.filter fun v : Fin d → Vec n => (fun i => proj hmn (v i)) = w)
      = Fintype.piFinset (fun i => univ.filter fun x : Vec n => proj hmn x = w i) from by
    ext v; simp [Fintype.mem_piFinset, funext_iff]]
  rw [Fintype.card_piFinset]
  simp [card_proj_fiber_eq hmn]

/-- Counting good direction tuples in `𝔽₂ⁿ` reduces to counting them in `𝔽₂^m`. -/
theorem card_surj_dirs (hmn : m ≤ n) (d : ℕ) :
    2 ^ (m * d) *
        (univ.filter fun v : Fin d → Vec n =>
          Function.Surjective (Lmap fun i => proj hmn (v i))).card
      = (univ.filter fun w : Fin d → Vec m =>
          Function.Surjective (Lmap w)).card * 2 ^ (n * d) := by
  classical
  set F := (univ.filter fun x : Vec n => proj hmn x = 0).card with hF
  set W := (univ.filter fun w : Fin d → Vec m => Function.Surjective (Lmap w)) with hW
  have hpart : (univ.filter fun v : Fin d → Vec n =>
      Function.Surjective (Lmap fun i => proj hmn (v i))).card = W.card * F ^ d := by
    rw [Finset.card_eq_sum_card_fiberwise (f := fun v : Fin d → Vec n => fun i => proj hmn (v i))
      (s := univ.filter fun v : Fin d → Vec n =>
        Function.Surjective (Lmap fun i => proj hmn (v i))) (t := W)
      (fun v hv => by
        simp only [hW, Finset.mem_coe, mem_filter, mem_univ, true_and]
        exact (mem_filter.1 hv).2)]
    refine (Finset.sum_congr rfl (fun w hw => ?_)).trans (by
      rw [Finset.sum_const, smul_eq_mul])
    have hwsurj : Function.Surjective (Lmap w) := by simpa [hW] using hw
    rw [show ((univ.filter fun v : Fin d → Vec n =>
        Function.Surjective (Lmap fun i => proj hmn (v i))).filter
          fun v => (fun i => proj hmn (v i)) = w)
        = univ.filter (fun v : Fin d → Vec n => (fun i => proj hmn (v i)) = w) from by
      ext v
      simp only [mem_filter, mem_univ, true_and]
      exact ⟨fun h => h.2, fun h => ⟨by rw [h]; exact hwsurj, h⟩⟩]
    exact card_tuple_fiber hmn w
  have h1 : (2 : ℕ) ^ (m * d) * F ^ d = 2 ^ (n * d) := by
    rw [pow_mul, pow_mul, ← mul_pow, card_proj_fiber_mul hmn]
  rw [hpart, show (2 : ℕ) ^ (m * d) * (W.card * F ^ d) = W.card * (2 ^ (m * d) * F ^ d) from by
    ring, h1]

/-- **Duality.** `y ↦ ∑ yᵢwᵢ` is surjective onto `𝔽₂^m` iff the `m` transposed vectors of
`𝔽₂^d` are linearly independent. -/
theorem surj_iff_linearIndependent (w : Fin d → Vec m) :
    Function.Surjective (Lmap w) ↔
      LinearIndependent (ZMod 2) (fun j : Fin m => (fun i => w i j : Vec d)) := by
  rw [Fintype.linearIndependent_iff]
  constructor
  · intro hs g hg j₀
    have hzero : ∀ i : Fin d, ∑ j, g j * w i j = 0 := by
      intro i
      have h := congrFun hg i
      simpa [Finset.sum_apply, mul_comm] using h
    obtain ⟨y, hy⟩ := hs (fun j => if j₀ = j then (1 : ZMod 2) else 0)
    have hcalc : ∑ j, g j * (Lmap w y) j = 0 := by
      have hswap : ∑ j, g j * (Lmap w y) j = ∑ i, y i * (∑ j, g j * w i j) := by
        simp only [Lmap, Fintype.linearCombination, LinearMap.coe_mk, AddHom.coe_mk,
          Finset.sum_apply, Pi.smul_apply, smul_eq_mul, Finset.mul_sum]
        rw [Finset.sum_comm]
        exact Finset.sum_congr rfl fun j _ => Finset.sum_congr rfl fun i _ => by ring
      rw [hswap]
      simp [hzero]
    rw [hy] at hcalc
    simpa using hcalc
  · intro hli
    by_contra hns
    obtain ⟨a, ha0, ha⟩ := exists_orth_of_not_surjective w hns
    refine ha0 (funext fun j => ?_)
    have hsum : ∑ j, a j • (fun i => w i j : Vec d) = 0 := by
      funext i
      simpa [Finset.sum_apply, mul_comm] using ha i
    simpa using hli a hsum j

/-- **The number of spanning `d`-tuples in `𝔽₂^m`** is `∏_{i<m}(2^d - 2^i)`. -/
theorem card_surj_tuples (hmd : m ≤ d) :
    (univ.filter fun w : Fin d → Vec m => Function.Surjective (Lmap w)).card
      = ∏ i : Fin m, (2 ^ d - 2 ^ (i : ℕ)) := by
  classical
  have hfr : Module.finrank (ZMod 2) (Vec d) = d := by simp [Vec]
  have hcard := card_linearIndependent (K := ZMod 2) (V := Vec d) (k := m)
    (by omega : m ≤ Module.finrank (ZMod 2) (Vec d))
  rw [hfr, ZMod.card] at hcard
  have hequiv : {w : Fin d → Vec m // Function.Surjective (Lmap w)}
      ≃ {s : Fin m → Vec d // LinearIndependent (ZMod 2) s} :=
    Equiv.subtypeEquiv (Equiv.piComm _) fun w => by
      simpa [Equiv.piComm] using surj_iff_linearIndependent w
  have h1 : Nat.card {w : Fin d → Vec m // Function.Surjective (Lmap w)}
      = Nat.card {s : Fin m → Vec d // LinearIndependent (ZMod 2) s} := Nat.card_congr hequiv
  rw [hcard] at h1
  rw [← h1, Nat.card_eq_fintype_card, Fintype.card_subtype]

/-- **The exact probability.** For `m ≤ n` and `m ≤ d`, a uniformly random affine `d`-cube
meets the codimension-`m` coordinate subspace of `𝔽₂ⁿ` in exactly `2^{d-m}` points with
probability exactly `∏_{i<m}(1 - 2^{i-d})`.  Note that the value does not depend on `n`. -/
theorem flatProb_codimSub_prod (hmn : m ≤ n) (hmd : m ≤ d) :
    flatProb n d (codimSub n hmn) (2 ^ (d - m))
      = ∏ i : Fin m, (1 - (2 : ℚ) ^ (i : ℕ) / 2 ^ d) := by
  classical
  rw [flatProb_codimSub_eq hmn hmd]
  have hcount := card_surj_dirs hmn d
  rw [card_surj_tuples hmd] at hcount
  -- pass to `ℚ`
  have hQ : (2 : ℚ) ^ (m * d) *
      ((univ.filter fun v : Fin d → Vec n =>
        Function.Surjective (Lmap fun i => proj hmn (v i))).card : ℚ)
      = ((∏ i : Fin m, (2 ^ d - 2 ^ (i : ℕ)) : ℕ) : ℚ) * 2 ^ (n * d) := by
    exact_mod_cast congrArg (fun t : ℕ => (t : ℚ)) hcount
  have hprodcast : ((∏ i : Fin m, (2 ^ d - 2 ^ (i : ℕ)) : ℕ) : ℚ)
      = ∏ i : Fin m, ((2 : ℚ) ^ d - 2 ^ (i : ℕ)) := by
    rw [Nat.cast_prod]
    refine Finset.prod_congr rfl fun i _ => ?_
    have hle : (2 : ℕ) ^ (i : ℕ) ≤ 2 ^ d :=
      Nat.pow_le_pow_right (by norm_num) (le_trans (le_of_lt i.isLt) hmd)
    push_cast [Nat.cast_sub hle]
    ring
  rw [hprodcast] at hQ
  have hne : ((2 : ℚ) ^ (n * d)) ≠ 0 := by positivity
  have hne2 : ((2 : ℚ) ^ (m * d)) ≠ 0 := by positivity
  have hsplit : ∏ i : Fin m, (1 - (2 : ℚ) ^ (i : ℕ) / 2 ^ d)
      = (∏ i : Fin m, ((2 : ℚ) ^ d - 2 ^ (i : ℕ))) / 2 ^ (m * d) := by
    have h1 : ∀ i : Fin m, (1 - (2 : ℚ) ^ (i : ℕ) / 2 ^ d) = ((2 : ℚ) ^ d - 2 ^ (i : ℕ)) / 2 ^ d := by
      intro i; field_simp
    rw [Finset.prod_congr rfl (fun i _ => h1 i), Finset.prod_div_distrib,
      Finset.prod_const, Finset.card_univ, Fintype.card_fin, ← pow_mul, Nat.mul_comm d m]
  rw [hsplit]
  field_simp
  linarith [hQ]

/-- **The case `s = 1`.** Taking the codimension-`d` subspace of `𝔽₂ⁿ` (`d ≤ n`), a random
affine `d`-cube meets it in exactly one point with probability `∏_{i<d}(1 - 2^{i-d})`.  This
gives the lower bound `λ*(d, 1) ≥ ∏_{i<d}(1 - 2^{i-d})`, which equals `1/2` for `d = 1` and
decreases to `∏_{t≥1}(1 - 2^{-t}) ≈ 0.2887…` as `d → ∞`. -/
theorem flatProb_one_eq_prod (hdn : d ≤ n) :
    flatProb n d (codimSub n hdn) 1 = ∏ i : Fin d, (1 - (2 : ℚ) ^ (i : ℕ) / 2 ^ d) := by
  have h := flatProb_codimSub_prod (m := d) (n := n) (d := d) hdn le_rfl
  rwa [Nat.sub_self, pow_zero] at h

end Exact

end AffineStats