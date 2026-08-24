import Cryptography.Price2Adic.Tree

/-!
# Counting: the Price tree certifies exponentially many primitive triples

The bijection `evalEquiv` of `Tree.lean` is qualitative.  This file extracts its
quantitative consequence, using the depth bound `sum_le_of_length`:

* `card_valid_ge` — for every `d`, there are at least `3^d` primitive Euclid parameter
  pairs with `m + n ≤ 3^(d+1)`; i.e. the counting function of primitive Pythagorean
  triples ordered by `m+n` is at least `3^d` at `3^(d+1)`.

The proof is the Price tree itself: the `3^d` words of length `d` give `3^d` distinct
nodes (uniqueness) all of parameter sum at most `3^(d+1)` (the geometric depth bound).
-/

namespace Price2Adic

open Finset

instance : Fintype PriceLetter where
  elems := {.A, .B, .C}
  complete := by intro l; cases l <;> simp

@[simp] theorem card_priceLetter : Fintype.card PriceLetter = 3 := rfl

/-- The nodes of depth `d`, as a finite set of parameter pairs. -/
noncomputable def depthNodes (d : ℕ) : Finset (ℕ × ℕ) :=
  (univ : Finset (Fin d → PriceLetter)).image (fun g => eval (List.ofFn g))

theorem card_depthNodes (d : ℕ) : (depthNodes d).card = 3 ^ d := by
  rw [depthNodes, Finset.card_image_of_injective _ ?inj, Finset.card_univ]
  · simp
  case inj =>
    intro g h hgh
    have h1 : List.ofFn g = List.ofFn h := eval_injective hgh
    exact List.ofFn_injective h1

theorem mem_depthNodes (d : ℕ) {p : ℕ × ℕ} (hp : p ∈ depthNodes d) :
    Valid p ∧ p.1 + p.2 ≤ 3 ^ (d + 1) := by
  rw [depthNodes, Finset.mem_image] at hp
  obtain ⟨g, -, rfl⟩ := hp
  refine ⟨Valid_eval _, ?_⟩
  have h := sum_le_of_length (List.ofFn g)
  rwa [List.length_ofFn] at h

/-- **Exponential lower bound.**  At least `3^d` primitive Euclid parameter pairs — hence
at least `3^d` primitive Pythagorean triples — have `m + n ≤ 3^(d+1)`. -/
theorem card_valid_ge (d : ℕ) :
    3 ^ d ≤ ((Iic (3 ^ (d + 1)) ×ˢ Iic (3 ^ (d + 1))).filter
      (fun p => Valid p ∧ p.1 + p.2 ≤ 3 ^ (d + 1))).card := by
  rw [← card_depthNodes d]
  apply Finset.card_le_card
  intro p hp
  obtain ⟨hv, hsum⟩ := mem_depthNodes d hp
  simp only [Finset.mem_filter, Finset.mem_product, Finset.mem_Iic]
  exact ⟨⟨by omega, by omega⟩, hv, hsum⟩

end Price2Adic