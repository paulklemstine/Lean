/-
# Counting the Finite Control Frames

A combinatorial companion to `Catalog/Logic/Multiverse/BooleanValuedRealization.lean`.

The finite pre-Boolean forcing frames used for the countermodels are assembled from
`n` independent buttons and `m` independent switches.  We compute their size
exactly:

* `sum_two_pow_card_powerset` — `∑_{t ⊆ s} 2^|t| = 3^|s|`, proved by induction on
  `s` (the enumerative heart: each element is either outside `t`, inside `t` but
  outside the ambient set, or in both);
* `card_cacc_pairs` — the frame with `n` buttons and `m` switches has exactly
  `3^n · 4^m` accessibility pairs, and (`card_worlds`) `2^(n+m)` worlds.

The count `3^n · 4^m` is exactly what an independent enumeration of the frames
produces (see `ComputationalEvidence.md`), and it exhibits the accessibility
relation as a *product* of `n` three-element button orders with `m` complete
two-element switch relations — the combinatorial form of the statement that buttons
and switches act independently.
-/
import Logic.Multiverse.BooleanValuedRealization

namespace MultiverseFrameCounting

open BooleanValuedRealization Finset

variable {α : Type*} [DecidableEq α]

instance decidableCacc {Btn Sw : Type*} [DecidableEq Btn] :
    DecidableRel (cacc (Btn := Btn) (Sw := Sw)) :=
  fun w v => inferInstanceAs (Decidable (w.1 ⊆ v.1))

/-- **Enumerative lemma.**  Summing `2^{|t|}` over all subsets `t` of `s` gives
`3^{|s|}`: each element of `s` contributes three states (absent, present only in
the ambient set, present in both). -/
theorem sum_two_pow_card_powerset (s : Finset α) :
    ∑ t ∈ s.powerset, 2 ^ t.card = 3 ^ s.card := by
  induction s using Finset.induction_on with
  | empty => simp
  | insert a s ha ih =>
      rw [Finset.sum_powerset_insert ha, ih, Finset.card_insert_of_notMem ha]
      have h2 : ∑ t ∈ s.powerset, 2 ^ (insert a t).card
          = ∑ t ∈ s.powerset, 2 * 2 ^ t.card := by
        refine Finset.sum_congr rfl fun t ht => ?_
        have hat : a ∉ t := fun h => ha (Finset.mem_powerset.1 ht h)
        rw [Finset.card_insert_of_notMem hat, pow_succ, mul_comm]
      rw [h2, ← Finset.mul_sum, ih]
      ring

/-- The number of worlds of the `n`-button, `m`-switch control frame. -/
theorem card_worlds (n m : ℕ) :
    Fintype.card (CWorld (Fin n) (Fin m)) = 2 ^ (n + m) := by
  simp [CWorld, pow_add]

/-- For a fixed world, the set of worlds it is accessible *from* is a product of a
powerset with the full set of switch settings. -/
theorem filter_cacc_eq (n m : ℕ) (v : CWorld (Fin n) (Fin m)) :
    (Finset.univ.filter fun w : CWorld (Fin n) (Fin m) => cacc w v)
      = v.1.powerset ×ˢ (Finset.univ : Finset (Fin m → Bool)) := by
  ext w
  simp [cacc, Finset.mem_powerset]

/-- **Exact size of the forcing relation.**  The control frame built from `n`
independent buttons and `m` independent switches has exactly `3^n · 4^m`
accessibility pairs: `3` states per button (as in `sum_two_pow_card_powerset`) and
`4` per switch (its value before and after the extension are unconstrained). -/
theorem card_cacc_pairs (n m : ℕ) :
    ∑ v : CWorld (Fin n) (Fin m),
        (Finset.univ.filter fun w : CWorld (Fin n) (Fin m) => cacc w v).card
      = 3 ^ n * 4 ^ m := by
  have hcard : ∀ v : CWorld (Fin n) (Fin m),
      (Finset.univ.filter fun w : CWorld (Fin n) (Fin m) => cacc w v).card
        = 2 ^ v.1.card * 2 ^ m := by
    intro v
    rw [filter_cacc_eq n m v, Finset.card_product, Finset.card_powerset,
      Finset.card_univ]
    simp
  simp only [hcard]
  rw [Fintype.sum_prod_type]
  have hinner : ∀ S : Finset (Fin n),
      ∑ _g : Fin m → Bool, 2 ^ S.card * 2 ^ m = 2 ^ S.card * 4 ^ m := by
    intro S
    rw [Finset.sum_const, Finset.card_univ]
    simp only [Fintype.card_fun, Fintype.card_bool, Fintype.card_fin, smul_eq_mul,
      ← pow_add]
    rw [show (4 : ℕ) = 2 ^ 2 by norm_num, ← pow_mul, ← pow_add]
    congr 1
    omega
  simp only [hinner]
  rw [← Finset.sum_mul]
  congr 1
  have : (Finset.univ : Finset (Finset (Fin n))) = (Finset.univ : Finset (Fin n)).powerset := by
    simp [Finset.powerset_univ]
  rw [this, sum_two_pow_card_powerset, Finset.card_univ, Fintype.card_fin]

end MultiverseFrameCounting