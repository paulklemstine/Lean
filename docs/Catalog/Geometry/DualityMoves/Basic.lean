module

public import Mathlib

/-!
# Duality eigensystems and their sign

We model the eigenvalue data of a pure weight-`w` piece of a Weil cohomology
satisfying Poincaré duality.  Write `Q = q ^ w` and fix a square root `s` of `Q`
(so `s ^ 2 = Q`; for an honest Weil number `s = q ^ (w / 2) > 0`, but all the
algebra below works for any nonzero complex `s`).

* A *duality eigensystem* is a finite list of nonzero complex numbers
  `α₁, …, α_d` (the inverse roots of the characteristic polynomial) which, as a
  multiset, is stable under the duality involution `α ↦ Q / α = s ^ 2 / α`.
* Its *sign* is `ε = (α₁ ⋯ α_d) / s ^ d`; this is the sign appearing in the
  functional equation `P(1 / (Q T)) = ± ε Q^{-d/2} T^{-d} P(T)`.
* The fixed points of the involution are exactly `±s`; we call `-s` the
  *`-Q` fixed points* (the eigenvalue `-√Q`).

The main result of this file is the *sign formula*
`ε = (-1) ^ (number of -Q fixed points)`, proved by peeling off fixed points and
dual pairs one at a time.
-/

@[expose] public section

noncomputable section

namespace DualityMoves

open Multiset

/-- The duality involution `α ↦ Q / α`, written with `Q = s ^ 2`. -/
def dual (s a : ℂ) : ℂ := s ^ 2 / a

/-- A *duality eigensystem* (relative to `s = √Q`): nonzero eigenvalues whose
multiset is stable under `α ↦ s ^ 2 / α`. -/
def IsEigensystem (s : ℂ) (l : List ℂ) : Prop :=
  (∀ a ∈ l, a ≠ 0) ∧ List.Perm (l.map (dual s)) l

/-- The sign of the functional equation: `∏ αᵢ / s ^ d`. -/
noncomputable def sign (s : ℂ) (l : List ℂ) : ℂ := l.prod / s ^ l.length

/-- Number of `-Q` fixed points, i.e. occurrences of the eigenvalue `-s`. -/
def negFix (s : ℂ) (l : List ℂ) : ℕ := l.count (-s)

lemma dual_injective {s : ℂ} (hs : s ≠ 0) : Function.Injective (dual s) := by
  intro a b h
  unfold dual at h
  have hs2 : s ^ 2 ≠ 0 := pow_ne_zero 2 hs
  rw [div_eq_mul_inv, div_eq_mul_inv] at h
  exact inv_injective (mul_left_cancel₀ hs2 h)

lemma dual_dual {s a : ℂ} (hs : s ≠ 0) (ha : a ≠ 0) : dual s (dual s a) = a := by
  unfold dual; field_simp

lemma dual_neg (s a : ℂ) : dual s (-a) = - dual s a := by
  unfold dual; ring

lemma dual_ne_zero {s a : ℂ} (hs : s ≠ 0) (ha : a ≠ 0) : dual s a ≠ 0 := by
  unfold dual; exact div_ne_zero (pow_ne_zero 2 hs) ha

/-- The fixed points of the duality involution are exactly `±s`. -/
lemma dual_eq_self_iff {s a : ℂ} (ha : a ≠ 0) : dual s a = a ↔ a = s ∨ a = -s := by
  unfold dual
  rw [div_eq_iff ha]
  constructor
  · intro h
    have : (a - s) * (a + s) = 0 := by linear_combination -h
    rcases mul_eq_zero.1 this with h1 | h1
    · left; linear_combination h1
    · right; linear_combination h1
  · rintro (rfl | rfl) <;> ring

lemma dual_self_s (s : ℂ) (hs : s ≠ 0) : dual s s = s :=
  (dual_eq_self_iff hs).2 (Or.inl rfl)

lemma dual_self_neg_s (s : ℂ) (hs : s ≠ 0) : dual s (-s) = -s :=
  (dual_eq_self_iff (neg_ne_zero.2 hs)).2 (Or.inr rfl)

/-- Removing one element `a` from a duality-closed multiset: the result is closed
under duality after also removing `dual a`. -/
lemma map_dual_erase {s : ℂ} (hs : s ≠ 0) (M : Multiset ℂ) (hM : M.map (dual s) = M)
    (a : ℂ) : (M.erase a).map (dual s) = M.erase (dual s a) := by
  rw [Multiset.map_erase _ (dual_injective hs), hM]

/-- **Sign formula (multiset form).**  For a duality-closed multiset of nonzero
numbers, `∏ α = (-1) ^ #{α = -s} · s ^ d`. -/
theorem prod_eq_of_dualClosed {s : ℂ} (hs : s ≠ 0) :
    ∀ (M : Multiset ℂ), (∀ a ∈ M, a ≠ 0) → M.map (dual s) = M →
      M.prod = (-1) ^ (M.count (-s)) * s ^ (card M) := by
  intro M
  induction hn : card M using Nat.strong_induction_on generalizing M with
  | _ n ih =>
  intro h0 hd
  rcases Multiset.empty_or_exists_mem M with rfl | ⟨a, haM⟩
  · subst hn; simp
  have ha0 := h0 a haM
  have hsn : s ≠ -s := fun h => hs (by linear_combination h / 2)
  by_cases hfix : dual s a = a
  · -- a is a fixed point: a = s or a = -s
    set M' := M.erase a with hM'
    have hM : M = a ::ₘ M' := (Multiset.cons_erase haM).symm
    have h0' : ∀ b ∈ M', b ≠ 0 := fun b hb => h0 b (Multiset.mem_of_mem_erase hb)
    have hd' : M'.map (dual s) = M' := by
      have := map_dual_erase hs M hd a
      rwa [hfix] at this
    have hcard : card M' + 1 = n := by rw [← hn, hM, Multiset.card_cons]
    have IH := ih (card M') (by omega) M' rfl h0' hd'
    rw [hM, Multiset.prod_cons, IH, ← hcard]
    rcases (dual_eq_self_iff ha0).1 hfix with rfl | rfl
    · rw [Multiset.count_cons_of_ne hsn.symm]; ring
    · rw [Multiset.count_cons_self]; ring
  · -- a is paired with b = dual a ≠ a
    set b := dual s a with hb
    have hbM : b ∈ M := by rw [← hd]; exact Multiset.mem_map_of_mem _ haM
    have hbM' : b ∈ M.erase a := (Multiset.mem_erase_of_ne hfix).2 hbM
    set M'' := (M.erase a).erase b with hM''
    have hM : M = a ::ₘ b ::ₘ M'' := by
      rw [hM'', Multiset.cons_erase hbM', Multiset.cons_erase haM]
    have h0' : ∀ c ∈ M'', c ≠ 0 := fun c hc =>
      h0 c (Multiset.mem_of_mem_erase (Multiset.mem_of_mem_erase hc))
    have hd' : M''.map (dual s) = M'' := by
      rw [hM'', Multiset.map_erase _ (dual_injective hs), map_dual_erase hs M hd a,
        hb, dual_dual hs ha0, Multiset.erase_comm]
    have hcard : card M'' + 2 = n := by rw [← hn, hM]; simp
    have IH := ih (card M'') (by omega) M'' rfl h0' hd'
    have ha_ne : a ≠ -s := fun h => hfix (by rw [hb, h]; exact dual_self_neg_s s hs)
    have hb_ne : b ≠ -s := by
      intro h
      apply ha_ne
      have : dual s b = dual s (-s) := by rw [h]
      rwa [hb, dual_dual hs ha0, dual_self_neg_s s hs] at this
    have hab : a * b = s ^ 2 := by rw [hb]; unfold dual; field_simp
    rw [hM, Multiset.prod_cons, Multiset.prod_cons, ← mul_assoc, hab, IH,
      Multiset.count_cons_of_ne ha_ne.symm, Multiset.count_cons_of_ne hb_ne.symm, ← hcard]
    ring

/-- **Sign formula.**  For every duality eigensystem,
`∏ αᵢ = (-1) ^ (#-Q fixed points) · s ^ d`. -/
theorem prod_eq (s : ℂ) (hs : s ≠ 0) (l : List ℂ) (hl : IsEigensystem s l) :
    l.prod = (-1) ^ negFix s l * s ^ l.length := by
  have hd : (l : Multiset ℂ).map (dual s) = l := by
    rw [Multiset.map_coe]; exact Multiset.coe_eq_coe.2 hl.2
  have := prod_eq_of_dualClosed hs (l : Multiset ℂ) (fun a ha => hl.1 a ha) hd
  simpa [negFix] using this

/-- **Sign formula.**  The sign of a duality eigensystem is
`(-1) ^ (number of -Q fixed points)`. -/
theorem sign_eq (s : ℂ) (hs : s ≠ 0) (l : List ℂ) (hl : IsEigensystem s l) :
    sign s l = (-1) ^ negFix s l := by
  rw [sign, prod_eq s hs l hl, mul_div_assoc, div_self (pow_ne_zero _ hs), mul_one]

/-- Two duality eigensystems have the same sign iff their numbers of `-Q` fixed
points have the same parity (the "proved converse" in sign-parity form). -/
theorem sign_eq_sign_iff (s : ℂ) (hs : s ≠ 0) (l l' : List ℂ)
    (hl : IsEigensystem s l) (hl' : IsEigensystem s l') :
    sign s l = sign s l' ↔ negFix s l % 2 = negFix s l' % 2 := by
  rw [sign_eq s hs l hl, sign_eq s hs l' hl']
  rcases Nat.even_or_odd (negFix s l) with h1 | h1 <;>
    rcases Nat.even_or_odd (negFix s l') with h2 | h2 <;>
    simp [h1.neg_one_pow, h2.neg_one_pow, Nat.even_iff.1, Nat.odd_iff.1, h1, h2] <;>
    norm_num

end DualityMoves

end