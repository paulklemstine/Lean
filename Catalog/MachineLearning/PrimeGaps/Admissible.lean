/-
# Admissible Tuples: Decidability and Finite Search

This file formalizes admissible tuples and proves that admissibility is decidable
via a finite search over primes p ≤ |H|. This converts an abstract predicate
into an executable certified object — the gateway to formal verification of
admissible tuple databases and automated discovery.

## Main results

* `Admissible` — definition of admissibility for finite sets of naturals
* `admissible_of_card_lt_prime` — pigeonhole: large primes are automatic
* `admissible_iff_check_primes_le_card` — finite search reduction
* `admissible_iff_bounded` — decidable reformulation with Finset.range
* Concrete decidability: `admissible_twin`, `not_admissible_0_2_4`, etc.
-/

import Mathlib

open Finset Nat

/-- A finite set `H` of natural numbers is *admissible* if for every prime `p`,
there exists a residue `a` modulo `p` such that no element of `H` shifted by `a`
is divisible by `p`. -/
def Admissible (H : Finset ℕ) : Prop :=
  ∀ p : ℕ, Nat.Prime p → ∃ a : ℕ, a < p ∧ ∀ h ∈ H, (a + h) % p ≠ 0

/-- The empty set is trivially admissible. -/
theorem admissible_empty : Admissible (∅ : Finset ℕ) :=
  fun p hp => ⟨1, hp.one_lt, by tauto⟩

/-- Admissibility is monotone: subsets of admissible sets are admissible. -/
theorem admissible_mono {H K : Finset ℕ} (hHK : H ⊆ K) (hK : Admissible K) :
    Admissible H :=
  fun p hp => by obtain ⟨a, ha, ha'⟩ := hK p hp; exact ⟨a, ha, fun h hh => ha' h (hHK hh)⟩

/-
For a prime `p` larger than `|H|`, the set `H` cannot cover all residue classes
mod `p` — by pigeonhole. The forbidden residues `{(p - h % p) % p : h ∈ H}` form
a set of size at most `|H| < p`, so some residue in `[0, p)` remains free.
-/
theorem admissible_of_card_lt_prime (H : Finset ℕ) {p : ℕ} (hp : Nat.Prime p)
    (hcard : H.card < p) : ∃ a : ℕ, a < p ∧ ∀ h ∈ H, (a + h) % p ≠ 0 := by
  by_contra hcard;
  -- Define a function `f : Fin p → H` such that for each `a : Fin p`, `f a` is an element of `H` satisfying `(a + f a) % p = 0`.
  obtain ⟨f, hf⟩ : ∃ f : Fin p → H, ∀ a : Fin p, (a.val + (f a : ℕ)) % p = 0 := by
    simp +zetaDelta at *;
    exact ⟨ fun a => ⟨ Classical.choose ( hcard a a.2 ), Classical.choose_spec ( hcard a a.2 ) |>.1 ⟩, fun a => Classical.choose_spec ( hcard a a.2 ) |>.2 ⟩;
  -- Since `f` is a function from `Fin p` to `H`, and `H` has fewer than `p` elements, `f` cannot be injective.
  have h_not_inj : ¬ Function.Injective f := by
    exact fun hinj => absurd ( Fintype.card_le_of_injective f hinj ) ( by simpa using by linarith );
  -- Since `f` is not injective, there exist distinct `a₁` and `a₂` in `Fin p` such that `f a₁ = f a₂`.
  obtain ⟨a₁, a₂, ha₁a₂, hfa⟩ : ∃ a₁ a₂ : Fin p, a₁ ≠ a₂ ∧ f a₁ = f a₂ := by
    simpa [ Function.Injective, and_comm ] using h_not_inj;
  have := Nat.modEq_iff_dvd.mp ( hf a₁ |> Eq.trans <| hf a₂ |> Eq.symm ) ; simp_all +decide [ Fin.ext_iff, Nat.dvd_iff_mod_eq_zero ] ;
  exact ha₁a₂ ( by obtain ⟨ k, hk ⟩ := this; nlinarith [ show k = 0 by nlinarith [ Fin.is_lt a₁, Fin.is_lt a₂ ] ] )

/-- **Finite-prime reduction.** Admissibility reduces to checking primes `p ≤ |H|`. -/
theorem admissible_iff_check_primes_le_card (H : Finset ℕ) :
    Admissible H ↔
      ∀ p : ℕ, Nat.Prime p → p ≤ H.card →
        ∃ a : ℕ, a < p ∧ ∀ h ∈ H, (a + h) % p ≠ 0 := by
  constructor
  · intro h p hp _; exact h p hp
  · intro h p hp
    by_cases hle : p ≤ H.card
    · exact h p hp hle
    · exact admissible_of_card_lt_prime H hp (by omega)

/-- Reformulation with Finset.range for decidability: admissibility is equivalent
to checking all primes in `range (|H| + 1)` and all residues in `range p`. -/
theorem admissible_iff_bounded (H : Finset ℕ) :
    Admissible H ↔ ∀ p ∈ Finset.range (H.card + 1), Nat.Prime p →
        ∃ a ∈ Finset.range p, ∀ h ∈ H, (a + h) % p ≠ 0 := by
  simp only [Finset.mem_range]
  constructor
  · intro h p _ hp; obtain ⟨a, ha, ha'⟩ := h p hp; exact ⟨a, by omega, ha'⟩
  · intro h p hp
    by_cases hle : p < H.card + 1
    · obtain ⟨a, ha, ha'⟩ := h p hle hp; exact ⟨a, by omega, ha'⟩
    · exact admissible_of_card_lt_prime H hp (by omega)

/-- The twin prime tuple `{0, 2}` is admissible. -/
theorem admissible_twin : Admissible ({0, 2} : Finset ℕ) := by
  rw [admissible_iff_bounded]; decide

/-- The set `{0, 2, 6}` is admissible. -/
theorem admissible_0_2_6 : Admissible ({0, 2, 6} : Finset ℕ) := by
  rw [admissible_iff_bounded]; decide

/-- The set `{0, 4, 6}` is admissible. -/
theorem admissible_0_4_6 : Admissible ({0, 4, 6} : Finset ℕ) := by
  rw [admissible_iff_bounded]; decide

/-- The set `{0, 2, 4}` is NOT admissible (p=3 covers all classes). -/
theorem not_admissible_0_2_4 : ¬ Admissible ({0, 2, 4} : Finset ℕ) := by
  rw [admissible_iff_bounded]; decide

/-- The quintuplet `{0, 2, 6, 8, 12}` is admissible. -/
theorem admissible_quintuplet : Admissible ({0, 2, 6, 8, 12} : Finset ℕ) := by
  rw [admissible_iff_bounded]; decide

/-- Executable admissibility checker using List (computable). -/
def admissibleCheck (H : List ℕ) : Bool :=
  (List.range (H.length + 1)).all fun p =>
    if Nat.Prime p then
      (List.range p).any fun a =>
        H.all fun h => (a + h) % p != 0
    else true

-- Executable tests
#eval admissibleCheck [0, 2]              -- true (twin primes)
#eval admissibleCheck [0, 2, 4]           -- false (covered by 3)
#eval admissibleCheck [0, 2, 6]           -- true
#eval admissibleCheck [0, 2, 6, 8, 12]    -- true (quintuplet)
#eval admissibleCheck [0, 4, 6, 10, 12, 16]