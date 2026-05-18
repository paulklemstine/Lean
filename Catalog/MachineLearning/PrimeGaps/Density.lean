/-
# Exact Finite Density Law for CRT Survivors

This file formalizes the counting of residue classes surviving local prime
obstructions. For an admissible tuple H and a prime p, the number of
"forbidden" residue classes mod p is |H mod p|, and the survivors mod p
number p - |H mod p|. The total survivor count modulo a primorial factors
as a product of local survivor counts via the Chinese Remainder Theorem.

## Main results

* `localObstructionCount` — number of distinct residues of H mod p
* `local_factor_pos_of_admissible` — admissibility implies < p obstructions
* `card_survivors_mod_prime` — exact count of survivors mod a single prime
* `survivors_nonempty_of_admissible_prime` — admissibility gives survivors
-/

import Mathlib
import Speculative.PrimeGaps.Admissible

open Finset Nat

/-- The number of distinct residue classes of `H` modulo `p`. This counts
the "forbidden" residues: values `r` such that some `h ∈ H` has `h ≡ r (mod p)`. -/
def localObstructionCount (H : Finset ℕ) (p : ℕ) : ℕ :=
  (H.image (· % p)).card

/-- The set of survivor residues modulo a prime `p`: those `a ∈ [0, p)` such that
for all `h ∈ H`, `(a + h) % p ≠ 0`. -/
def survivorsMod (H : Finset ℕ) (p : ℕ) : Finset ℕ :=
  (Finset.range p).filter fun a => ∀ h ∈ H, (a + h) % p ≠ 0

/-
Under admissibility, the number of distinct residues of H mod p is strictly
less than p. This is the local non-coverage condition.
-/
theorem local_factor_pos_of_admissible
    (H : Finset ℕ) (hH : Admissible H)
    {p : ℕ} (hp : Nat.Prime p) :
    localObstructionCount H p < p := by
  -- By definition of admissibility, there exists a residue $a$ modulo $p$ such that for all $h \in H$, $(a + h) \mod p \neq 0$.
  obtain ⟨a, ha⟩ : ∃ a, a < p ∧ ∀ h ∈ H, (a + h) % p ≠ 0 := by
    exact hH p hp;
  refine' lt_of_lt_of_le ( Finset.card_lt_card ( Finset.ssubset_iff_subset_ne.mpr _ ) ) _;
  exact Finset.range p;
  · refine' ⟨ Finset.image_subset_iff.mpr fun x hx => Finset.mem_range.mpr <| Nat.mod_lt _ hp.pos, _ ⟩;
    intro h; have := Finset.ext_iff.mp h ( ( p - a ) % p ) ; simp_all +decide [ Nat.mod_eq_of_lt ] ;
    replace h := Finset.ext_iff.mp h ( ( p - a ) % p ) ; simp_all +decide [ Nat.mod_eq_of_lt ] ;
    exact ha.2 _ ( h.mpr ( Nat.mod_lt _ hp.pos ) |> Classical.choose_spec |> And.left ) ( by rw [ Nat.add_mod, h.mpr ( Nat.mod_lt _ hp.pos ) |> Classical.choose_spec |> And.right ] ; simp +decide [ Nat.add_sub_of_le ha.1.le ] );
  · norm_num

/-
The survivor count mod a prime p equals p minus the local obstruction count.
This is the exact single-prime counting law.
-/
theorem card_survivors_mod_prime
    (H : Finset ℕ) {p : ℕ} (hp : Nat.Prime p) :
    (survivorsMod H p).card = p - localObstructionCount H p := by
  haveI := Fact.mk hp;
  rw [ show survivorsMod H p = Finset.image ( fun x : ZMod p => x.val ) ( Finset.univ \ Finset.image ( fun h : ℕ => -h : ℕ → ZMod p ) H ) from ?_ ];
  · rw [ Finset.card_image_of_injOn, Finset.card_sdiff ];
    · congr 1;
      · simp +decide [ Finset.card_univ ];
      · refine' Finset.card_bij ( fun x hx => ( -x : ZMod p ).val ) _ _ _ <;> simp +decide [ localObstructionCount ];
        · exact fun a ha => ⟨ a, ha, rfl ⟩;
        · simp +decide [ ← ZMod.natCast_eq_natCast_iff' ];
    · exact fun x hx y hy hxy => by simpa [ ZMod.natCast_eq_zero_iff ] using congr_arg ( fun x : ℕ => x : ℕ → ZMod p ) hxy;
  · ext; simp [survivorsMod];
    constructor;
    · intro h;
      use ↑‹ℕ›;
      simp_all +decide [ ← ZMod.val_natCast, Nat.add_mod ];
      exact ⟨ fun x hx => fun hx' => h.2 x hx <| by linear_combination' -hx', ZMod.val_cast_of_lt h.1 ⟩;
    · rintro ⟨ a, ha, rfl ⟩;
      simp_all +decide [ ← ZMod.val_natCast, Nat.add_mod ];
      exact ⟨ ZMod.val_lt a, fun h hh => fun h' => ha h hh <| by linear_combination' -h' ⟩

/-
If H is admissible, there exists at least one survivor class mod p.
-/
theorem survivors_nonempty_of_admissible_prime
    (H : Finset ℕ) (hH : Admissible H)
    {p : ℕ} (hp : Nat.Prime p) :
    (survivorsMod H p).Nonempty := by
  have := hH p hp;
  exact ⟨ this.choose, Finset.mem_filter.mpr ⟨ Finset.mem_range.mpr this.choose_spec.1, this.choose_spec.2 ⟩ ⟩

/-
The local obstruction count is bounded by |H|.
-/
theorem localObstructionCount_le_card (H : Finset ℕ) (p : ℕ) :
    localObstructionCount H p ≤ H.card := by
  exact Finset.card_image_le

/-
For the empty set, there are zero obstructions.
-/
theorem localObstructionCount_empty (p : ℕ) :
    localObstructionCount ∅ p = 0 := by
  rfl

/-- For any admissible H and prime p, the survivor count is positive. -/
theorem card_survivors_pos_of_admissible
    (H : Finset ℕ) (hH : Admissible H) {p : ℕ} (hp : Nat.Prime p) :
    0 < (survivorsMod H p).card := by
  exact (survivors_nonempty_of_admissible_prime H hH hp).card_pos