/-
# Consequences and boundary of the additive uncertainty principle

Two applications of `FourierCyclic.uncertainty_sum_zmod`:

* `FourierCyclic.sparse_recovery` : a `k`-sparse signal on `ZMod p` is uniquely determined by
  *any* `2k` of its Fourier coefficients.  This is the compressed-sensing form of the additive
  uncertainty principle; the multiplicative bound `|supp f| · |supp f̂| ≥ p` is far too weak to
  give it.
* `FourierCyclic.uncertainty_sum_fails_at_four` : primality is essential.  For `n = 4` the
  indicator function of the subgroup `{0, 2}` has `|supp f| = |supp f̂| = 2`, so
  `|supp f| + |supp f̂| = 4 < 5 = n + 1`, while the multiplicative bound `2 * 2 ≥ 4` still holds.
-/

import Mathlib
import Shared.FourierUncertaintySum

open Finset FourierFA

namespace FourierCyclic

variable {p : ℕ} [NeZero p]

/-- The DFT is additive. -/
theorem dftZMod_sub (f g : ZMod p → ℂ) (k : ZMod p) :
    dftZMod (f - g) k = dftZMod f k - dftZMod g k := by
  simp only [dftZMod, Pi.sub_apply, mul_sub, Finset.sum_sub_distrib]

theorem supp_sub_subset (f g : ZMod p → ℂ) : supp (f - g) ⊆ supp f ∪ supp g := by
  intro x hx
  rw [mem_supp] at hx
  by_contra hc
  rw [Finset.mem_union] at hc
  push_neg at hc
  have h1 : f x = 0 := by
    by_contra h
    exact hc.1 (mem_supp.2 h)
  have h2 : g x = 0 := by
    by_contra h
    exact hc.2 (mem_supp.2 h)
  exact hx (by simp [Pi.sub_apply, h1, h2])

/-- **Unique sparse recovery.**  Over `ZMod p` with `p` prime, two `k`-sparse signals that agree
on any `2k` frequencies are equal. -/
theorem sparse_recovery (hp : p.Prime) {k : ℕ} (f g : ZMod p → ℂ)
    (hf : (supp f).card ≤ k) (hg : (supp g).card ≤ k)
    (S : Finset (ZMod p)) (hS : 2 * k ≤ S.card)
    (hSeq : ∀ s ∈ S, dftZMod f s = dftZMod g s) : f = g := by
  by_contra hne
  have hd : f - g ≠ 0 := fun h => hne (by
    funext x
    have hx := congrFun h x
    simpa [sub_eq_zero] using hx)
  have hcard : Fintype.card (ZMod p) = p := ZMod.card p
  -- the difference is `2k`-sparse
  have h1 : (supp (f - g)).card ≤ 2 * k := by
    have hsub := Finset.card_le_card (supp_sub_subset f g)
    have h2 := Finset.card_union_le (supp f) (supp g)
    omega
  -- and its transform vanishes on `S`
  have h2 : supp (dftZMod (f - g)) ⊆ Sᶜ := by
    intro s hs
    rw [Finset.mem_compl]
    intro hsS
    exact (mem_supp.1 hs) (by rw [dftZMod_sub, hSeq s hsS, sub_self])
  have h3 : (supp (dftZMod (f - g))).card ≤ p - S.card := by
    have h4 := Finset.card_le_card h2
    rwa [Finset.card_compl, hcard] at h4
  have hSp : S.card ≤ p := by simpa [hcard] using Finset.card_le_univ S
  have h4 := uncertainty_sum_zmod hp (f - g) hd
  omega

/-- **Optimality of the `2k` threshold.**  For `2k ≤ p` and *any* prescribed set `S` of `2k - 1`
frequencies there are two distinct `k`-sparse signals whose Fourier transforms agree on `S`.  So
the hypothesis `2 * k ≤ S.card` in `sparse_recovery` cannot be weakened, for any sampling
pattern. -/
theorem sparse_recovery_threshold_sharp (hp : p.Prime) {k : ℕ} (hk : 1 ≤ k) (h2k : 2 * k ≤ p)
    (S : Finset (ZMod p)) (hS : S.card = 2 * k - 1) :
    ∃ f g : ZMod p → ℂ, f ≠ g ∧ (supp f).card ≤ k ∧ (supp g).card ≤ k ∧
      ∀ s ∈ S, dftZMod f s = dftZMod g s := by
  have hcard : Fintype.card (ZMod p) = p := ZMod.card p
  -- a spatial support of size `2k`
  obtain ⟨A, -, hA⟩ : ∃ A ⊆ (univ : Finset (ZMod p)), A.card = 2 * k :=
    Finset.exists_subset_card_eq (by simpa [hcard] using h2k)
  -- the transform is allowed to live on the complement of `S`
  have hsplit : A.card + (Sᶜ).card = p + 1 := by
    rw [hA, Finset.card_compl, hcard, hS]
    omega
  obtain ⟨h, hhA, hhB⟩ := exists_supp_eq_of_card_add_card hp A (Sᶜ) hsplit
  -- split `A` into two halves
  obtain ⟨A₁, hA₁sub, hA₁⟩ : ∃ A₁ ⊆ A, A₁.card = k := Finset.exists_subset_card_eq (by omega)
  classical
  refine ⟨fun x => if x ∈ A₁ then h x else 0, fun x => if x ∈ A₁ then 0 else -h x, ?_, ?_, ?_, ?_⟩
  · -- the two signals differ, since their difference is `h ≠ 0`
    have hhne : h ≠ 0 := by
      intro h0
      have : supp h = ∅ := by
        ext x
        simp [mem_supp, h0]
      rw [hhA] at this
      have : A.card = 0 := by rw [this]; rfl
      omega
    intro hfg
    apply hhne
    funext x
    have hx := congrFun hfg x
    by_cases hxA : x ∈ A₁ <;> simp [hxA] at hx <;> simp [hx]
  · refine le_trans (Finset.card_le_card ?_) (le_of_eq hA₁)
    intro x hx
    by_contra hxA
    exact (mem_supp.1 hx) (by simp [hxA])
  · have hA₂ : (A \ A₁).card = k := by
      rw [Finset.card_sdiff, Finset.inter_eq_left.2 hA₁sub, hA, hA₁]
      omega
    refine le_trans (Finset.card_le_card ?_) (le_of_eq hA₂)
    intro x hx
    have hx0 : ¬(x ∈ A₁) := by
      by_contra hxA
      exact (mem_supp.1 hx) (by simp [hxA])
    have hxA : x ∈ A := by
      rw [← hhA]
      apply mem_supp.2
      intro h0
      exact (mem_supp.1 hx) (by simp [hx0, h0])
    exact Finset.mem_sdiff.2 ⟨hxA, hx0⟩
  · intro s hs
    have hdiff : (fun x => if x ∈ A₁ then h x else 0) - (fun x => if x ∈ A₁ then (0:ℂ) else -h x)
        = h := by
      funext x
      by_cases hxA : x ∈ A₁ <;> simp [hxA]
    have hzero : dftZMod h s = 0 := by
      by_contra h0
      have : s ∈ Sᶜ := by rw [← hhB]; exact mem_supp.2 h0
      exact (Finset.mem_compl.1 this) hs
    have := dftZMod_sub (fun x => if x ∈ A₁ then h x else 0)
      (fun x => if x ∈ A₁ then (0:ℂ) else -h x) s
    rw [hdiff, hzero] at this
    exact sub_eq_zero.1 this.symm

/-! ## Primality is essential -/

/-- The indicator function of the subgroup `{0, 2} ≤ ZMod 4`. -/
noncomputable def evenIndicator : ZMod 4 → ℂ := fun x => if x = 0 ∨ x = 2 then 1 else 0

theorem zetaNeg_four_sq : (zetaNeg 4) ^ 2 = -1 := by
  rw [zetaNeg_pow]
  have h : (-(2 * (Real.pi : ℂ) * Complex.I * ((2 : ℕ) : ℂ)) / ((4 : ℕ) : ℂ))
      = -((Real.pi : ℂ) * Complex.I) := by
    push_cast
    ring
  rw [h, Complex.exp_neg, Complex.exp_pi_mul_I]
  norm_num

theorem dftZMod_evenIndicator (k : ZMod 4) :
    dftZMod evenIndicator k = 1 + (-1) ^ (k.val) := by
  rw [dftZMod_eq_zeta]
  have hsum : ∀ g : ZMod 4 → ℂ, ∑ x : ZMod 4, g x = g 0 + g 1 + g 2 + g 3 := by
    intro g
    show ∑ x : Fin 4, g x = _
    rw [Fin.sum_univ_four]
  have hp1 : ¬((1 : ZMod 4) = 0 ∨ (1 : ZMod 4) = 2) := by decide
  have hp3 : ¬((3 : ZMod 4) = 0 ∨ (3 : ZMod 4) = 2) := by decide
  rw [hsum]
  simp only [evenIndicator, if_neg hp1, if_neg hp3,
    show ((0 : ZMod 4)).val = 0 from rfl, show ((2 : ZMod 4)).val = 2 from rfl]
  norm_num
  rw [pow_mul', zetaNeg_four_sq]

/-- **The additive uncertainty principle fails for composite modulus.**  For `n = 4` the
indicator of the subgroup `{0, 2}` satisfies `|supp f| + |supp f̂| = 4 < 5`, whereas the
multiplicative bound `|supp f| * |supp f̂| ≥ 4` still holds. -/
theorem uncertainty_sum_fails_at_four :
    (supp evenIndicator).card + (supp (dftZMod evenIndicator)).card = 4 ∧
      4 ≤ (supp evenIndicator).card * (supp (dftZMod evenIndicator)).card := by
  have hs : supp evenIndicator = {0, 2} := by
    ext x
    simp only [mem_supp, evenIndicator, Finset.mem_insert, Finset.mem_singleton]
    constructor
    · intro h
      by_contra hc
      push_neg at hc
      rw [if_neg (by tauto)] at h
      exact h rfl
    · intro h
      rw [if_pos h]
      exact one_ne_zero
  have hd : supp (dftZMod evenIndicator) = {0, 2} := by
    ext k
    simp only [mem_supp, dftZMod_evenIndicator, Finset.mem_insert, Finset.mem_singleton]
    have hlt := ZMod.val_lt k
    have h0 : (k = 0) ↔ k.val = 0 :=
      ⟨fun h => by rw [h]; rfl, fun h => ZMod.val_injective 4 (by rw [h]; rfl)⟩
    have h2 : (k = 2) ↔ k.val = 2 :=
      ⟨fun h => by rw [h]; rfl, fun h => ZMod.val_injective 4 (by rw [h]; rfl)⟩
    rw [h0, h2]
    rcases (show k.val = 0 ∨ k.val = 1 ∨ k.val = 2 ∨ k.val = 3 by omega) with h | h | h | h <;>
      rw [h] <;> norm_num
  rw [hs, hd]
  refine ⟨by decide, by decide⟩

end FourierCyclic