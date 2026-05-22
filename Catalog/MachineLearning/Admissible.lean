/-
# Admissible Tuples and Local Obstructions for Prime Gaps

This file formalizes the theory of admissible tuples — finite sets of natural numbers
that avoid a specific local obstruction modulo every prime. Admissibility is the
combinatorial gateway to all modern prime gap results: Dickson's conjecture,
Hardy–Littlewood prime tuples, GPY, Zhang, and Maynard–Tao all require the tuple
under consideration to be admissible.

## Main definitions

* `Admissible H` — A finite set `H : Finset ℕ` is admissible if for every prime `p`,
  the reductions of `H` modulo `p` do not cover all residue classes.

## Main results

* `not_admissible_iff_full_cover` — A tuple is inadmissible iff some prime has all
  residue classes hit by shifts from `H`.
* `admissible_twin` — The set `{0, 2}` is admissible (no local obstruction to twin primes).
* `admissible_empty`, `admissible_singleton`, `admissible_mono` — Basic structural lemmas.
* `admissible_of_card_lt_prime` — If `|H| < p`, then `H` avoids full coverage mod `p`.
* `admissible_iff_check_primes_le_card` — Admissibility reduces to checking primes `p ≤ |H|`.

## References

* Green, B. and Tao, T., "The primes contain arbitrarily long arithmetic progressions"
* Maynard, J., "Small gaps between primes"
-/

import Mathlib

open Finset Nat

/-- A finite set `H` of natural numbers is *admissible* if for every prime `p`,
there exists a residue `a` modulo `p` such that no element of `H` shifted by `a`
is divisible by `p`. Equivalently, the reductions of `H` mod `p` do not cover
all residue classes. This is the fundamental local condition underlying all
prime tuple conjectures. -/
def Admissible (H : Finset ℕ) : Prop :=
  ∀ p : ℕ, Nat.Prime p → ∃ a : ℕ, a < p ∧ ∀ h, h ∈ H → (a + h) % p ≠ 0

/-
The empty set is trivially admissible.
-/
theorem admissible_empty : Admissible (∅ : Finset ℕ) := by
  exact fun p hp => ⟨ 1, hp.one_lt, by tauto ⟩

/-
Any singleton set is admissible: for any prime `p` and any `h`, we can choose
`a` to avoid `(a + h) % p = 0`.
-/
theorem admissible_singleton (h : ℕ) : Admissible ({h} : Finset ℕ) := by
  intro p hp;
  by_contra! htra;
  rcases htra 0 hp.pos with ⟨ a, ha₁, ha₂ ⟩ ; rcases htra 1 ( hp.two_le ) with ⟨ b, hb₁, hb₂ ⟩ ; simp_all +decide [ Nat.add_mod, Nat.mod_eq_of_lt hp.one_lt ]

/-
Admissibility is monotone: subsets of admissible sets are admissible.
-/
theorem admissible_mono {H K : Finset ℕ} (hHK : H ⊆ K) (hK : Admissible K) :
    Admissible H := by
  exact fun p hp => by obtain ⟨ a, ha, ha' ⟩ := hK p hp; exact ⟨ a, ha, fun h hh => ha' h ( hHK hh ) ⟩ ; ;

/-
A tuple is inadmissible if and only if some prime `p` has the property that
every residue class modulo `p` is "hit" by some shift from `H`. This is the
local obstruction criterion: the negation of admissibility is equivalent to
the existence of a covering prime.
-/
theorem not_admissible_iff_full_cover (H : Finset ℕ) :
    ¬Admissible H ↔
      ∃ p : ℕ, Nat.Prime p ∧ ∀ a : ℕ, a < p → ∃ h, h ∈ H ∧ (a + h) % p = 0 := by
  unfold Admissible;
  simp +zetaDelta at *

/-
For a prime `p` larger than `|H|`, the set `H` cannot cover all residue classes
mod `p`. This is because `H` has at most `|H|` distinct residues mod `p`, which is
fewer than `p` residue classes.
-/
theorem admissible_of_card_lt_prime (H : Finset ℕ) {p : ℕ} (hp : Nat.Prime p)
    (hcard : H.card < p) : ∃ a : ℕ, a < p ∧ ∀ h, h ∈ H → (a + h) % p ≠ 0 := by
  by_contra h;
  -- This means for every $a < p$, there exists some $h \in H$ such that $(a + h) \equiv 0 \pmod{p}$.
  have h_forbidden : ∀ a < p, ∃ h ∈ H, (a + h) ≡ 0 [MOD p] := by
    exact fun a ha => by push_neg at h; simpa [ Nat.ModEq, Nat.mod_eq_of_lt ha ] using h a ha;
  choose! f hf using h_forbidden;
  -- Since $f$ is injective, the values $f(a)$ for $a < p$ must all be distinct.
  have h_distinct : ∀ a b : ℕ, a < p → b < p → a ≠ b → f a ≠ f b := by
    intro a b ha hb hab hfab; have := hf a ha; have := hf b hb; simp_all +decide [ Nat.ModEq, Nat.mod_eq_of_lt ] ;
    exact hab ( by obtain ⟨ k, hk ⟩ := Nat.modEq_zero_iff_dvd.mp this; obtain ⟨ l, hl ⟩ := Nat.modEq_zero_iff_dvd.mp ( hf b hb |>.2 ) ; nlinarith [ show k = l by nlinarith ] );
  exact absurd ( Finset.card_le_card ( show Finset.image f ( Finset.range p ) ⊆ H from Finset.image_subset_iff.mpr fun x hx => hf x ( Finset.mem_range.mp hx ) |>.1 ) ) ( by rw [ Finset.card_image_of_injOn fun x hx y hy hxy => by contrapose! hxy; exact h_distinct x y ( Finset.mem_range.mp hx ) ( Finset.mem_range.mp hy ) hxy ] ; simpa using hcard )

/-
**Finite-prime reduction for admissibility.** A finite set `H` is admissible if and
only if for every prime `p ≤ |H|`, the reductions of `H` modulo `p` do not cover all
residue classes. This reduces an a priori infinite check to a finite computation,
since for primes `p > |H|` the pigeonhole principle guarantees non-coverage.
-/
theorem admissible_iff_check_primes_le_card (H : Finset ℕ) :
    Admissible H ↔
      ∀ p : ℕ, Nat.Prime p → p ≤ H.card →
        ∃ a : ℕ, a < p ∧ ∀ h, h ∈ H → (a + h) % p ≠ 0 := by
  refine' ⟨ fun h p hp hp' => h p hp |> fun ⟨ a, ha, h ⟩ => _, fun h p hp => _ ⟩;
  · -- By Lemma admissible_of_card_lt_prime, if p > H.card, then there exists an a < p such that (a + h) % p ≠ 0 for all h in H.
    by_cases hpcard : p > H.card
    · exact admissible_of_card_lt_prime H hp hpcard
    · exact h p hp (le_of_not_gt hpcard);
  · use a

/-
**The twin prime tuple `{0, 2}` is admissible.** This means there is no
congruence obstruction to the existence of infinitely many twin primes.
For `p = 2`, choose `a = 1`; for odd primes `p ≥ 3`, there are at most 2 forbidden
residues among `p ≥ 3` classes, so a free residue always exists.
-/
theorem admissible_twin : Admissible ({0, 2} : Finset ℕ) := by
  intro p hp;
  rcases p with ( _ | _ | _ | _ | p ) <;> simp_all +arith +decide [ Nat.mod_eq_of_lt ];
  exact ⟨ 1, by linarith, by norm_num, by rw [ Nat.mod_eq_of_lt ] <;> linarith ⟩

/-
The set `{0, 2, 6}` is admissible (prime constellation `(p, p+2, p+6)`).
-/
theorem admissible_0_2_6 : Admissible ({0, 2, 6} : Finset ℕ) := by
  intro p hp;
  by_cases h₂ : p ≤ 7;
  · interval_cases p <;> simp_all +decide;
  · use 1;
    exact ⟨ hp.one_lt, fun h hh => by rw [ Nat.mod_eq_of_lt ] <;> fin_cases hh <;> linarith ⟩

/-
The set `{0, 4, 6}` is admissible (prime constellation `(p, p+4, p+6)`).
-/
theorem admissible_0_4_6 : Admissible ({0, 4, 6} : Finset ℕ) := by
  intro p hp;
  by_contra! h;
  have := h 1 hp.one_lt; ( have := h 2 ( lt_of_le_of_ne hp.two_le ( Ne.symm ( by rintro rfl; specialize h 0; simp_all +decide ) ) ) ; ( have := h 3 ( lt_of_le_of_ne ( Nat.succ_le_of_lt ( lt_of_le_of_ne hp.two_le ( Ne.symm ( by rintro rfl; specialize h 0; simp_all +decide ) ) ) ) ( Ne.symm ( by rintro rfl; specialize h 0; simp_all +decide ) ) ) ; simp_all +decide [ ← Nat.dvd_iff_mod_eq_zero, hp.dvd_iff_eq ] ; ) );
  rcases ‹p = 1 ∨ p ∣ 5 ∨ p ∣ 7› with ( rfl | h | h ) <;> simp_all +decide [ Nat.prime_dvd_prime_iff_eq ]