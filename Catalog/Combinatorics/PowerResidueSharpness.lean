/-
# Cycle 3: the capacity bound is sharp, and the escape is absolute

Third research cycle on `39_PowerResidue_Circularity.md` (KPOWER, #374).

Cycle 1 produced the dichotomy *escape from periodicity* vs *capacity `2^K`*;
cycle 2 (`Combinatorics.PowerResidueNoAmplification`) added the sparsity count
and the hybrid pigeonhole.  The Critic's objection to that package is the
obvious one: **is either half vacuous?**  A capacity bound is worthless if the
channel never attains it, and a non-periodicity theorem is worthless if it only
rules out a contrived class of statistics.  This file removes both doubts.

* `PowerResidueSharp.cubic_two_bits_injOn`,
  `PowerResidueSharp.capacity_two_bits_sharp` — the capacity bound `2 ^ K` is
  **attained**: the two cubic bits at bases `2, 3` take all four values on the
  primes `7, 31, 61, 307`, so `K = 2` cubic symbols really do separate `2² = 4`
  candidates, and `PowerResidue.card_le_two_pow_of_injOn` is sharp there.
* `PowerResidueSharp.cubic_two_not_congruence_computable` — the escape is not an
  artefact of the `Dial` formalism: **no** statistic whatsoever, valued in an
  arbitrary type, that depends on `p` only through `p % M` with `M ∣ 720720`,
  and **no** decision rule applied to it, can decide the cubic bit.
* `PowerResidueSharp.quadratic_two_congruence_computable` — the exact opposite
  for the quadratic bit, which *is* such a statistic (`f p = p % 8`).
* `PowerResidueSharp.escape_dichotomy` — the two put side by side.

Together with cycle 1 and 2 this closes the KPOWER question in the direction the
experiment reports: the higher-power channel is genuinely non-periodic (so it
cannot be simulated by any congruence data), genuinely `2^K`-sharp (so it is not
an empty channel), and still `2^K`-bounded (so it is not a better channel).
-/
import Mathlib
import Combinatorics.PowerResidueCriterion
import Combinatorics.PowerResidueCircularity

namespace PowerResidueSharp

open PowerResidue PowerResidueEscape

/-! ## 1. The two cubic bits at bases `2, 3` on `7, 31, 61, 307`

All four bit patterns occur, so two cubic symbols separate four primes: the
capacity bound `2 ^ K` of `PowerResidue.card_le_two_pow_of_injOn` is attained at
`K = 2`. -/

theorem bit_7_two : resVec 3 ![2, 3] 7 0 = false :=
  resVec_false (show ¬ IsPowerResidue 3 7 2 by decide)

theorem bit_7_three : resVec 3 ![2, 3] 7 1 = false :=
  resVec_false (show ¬ IsPowerResidue 3 7 3 by decide)

theorem bit_31_two : resVec 3 ![2, 3] 31 0 = true :=
  resVec_true (show IsPowerResidue 3 31 2 from ⟨4, by decide⟩)

theorem bit_31_three : resVec 3 ![2, 3] 31 1 = false :=
  resVec_false (show ¬ IsPowerResidue 3 31 3 by decide)

theorem bit_61_two : resVec 3 ![2, 3] 61 0 = false :=
  resVec_false (show ¬ IsPowerResidue 3 61 2 by decide)

theorem bit_61_three : resVec 3 ![2, 3] 61 1 = true :=
  resVec_true (show IsPowerResidue 3 61 3 from ⟨4, by decide⟩)

theorem bit_307_two : resVec 3 ![2, 3] 307 0 = true :=
  resVec_true (show IsPowerResidue 3 307 2 from ⟨52, by decide⟩)

theorem bit_307_three : resVec 3 ![2, 3] 307 1 = true :=
  resVec_true (show IsPowerResidue 3 307 3 from ⟨192, by decide⟩)

open scoped Classical in
/-- **Two cubic bits separate four primes.** -/
theorem cubic_two_bits_injOn :
    Set.InjOn (resVec 3 ![2, 3]) ({7, 31, 61, 307} : Finset ℕ) := by
  intro p hp q hq hpq
  have e0 := congrFun hpq 0
  have e1 := congrFun hpq 1
  simp only [Finset.coe_insert, Set.mem_insert_iff, Finset.coe_singleton,
    Set.mem_singleton_iff] at hp hq
  rcases hp with rfl | rfl | rfl | rfl <;> rcases hq with rfl | rfl | rfl | rfl <;>
    revert e0 e1 <;>
    simp [bit_7_two, bit_7_three, bit_31_two, bit_31_three, bit_61_two, bit_61_three,
      bit_307_two, bit_307_three]

open scoped Classical in
/-- **The capacity bound is sharp.**  There is a candidate set of exactly
`2 ^ 2` primes on which the two-symbol cubic fingerprint is injective; by
`PowerResidue.card_le_two_pow_of_injOn` no larger set admits this. -/
theorem capacity_two_bits_sharp :
    ∃ S : Finset ℕ, S.card = 2 ^ 2 ∧ Set.InjOn (resVec 3 ![2, 3]) S ∧
      ∀ T : Finset ℕ, Set.InjOn (resVec 3 ![2, 3]) T → T.card ≤ 2 ^ 2 :=
  ⟨{7, 31, 61, 307}, by decide, cubic_two_bits_injOn, fun _ h => card_le_two_pow_of_injOn h⟩

/-! ## 2. The escape does not depend on the `Dial` formalism -/

/-- **Absolute escape.**  Let `f` be *any* statistic of the candidate — valued in
an arbitrary type — that depends on `p` only through `p % M` for some modulus
`M ∣ 720720 = lcm(1,…,16)`, and let `g` be *any* decision rule applied to it.
Then `g ∘ f` does not decide cubic residuacity of `2`.  (The `Dial` version
`PowerResidueEscape.cubic_two_not_dial` is the special case
`X = ℤ`, `g = (· = c)`.) -/
theorem cubic_two_not_congruence_computable {X : Type*} {M : ℕ} (hM : M ∣ 720720)
    (f : ℕ → X) (hf : ∀ a b : ℕ, a % M = b % M → f a = f b) (g : X → Prop) :
    ¬ ∀ p : ℕ, p.Prime → p % 3 = 1 → (IsPowerResidue 3 p 2 ↔ g (f p)) := by
  intro H
  have hval : f 43 = f 720763 := hf 43 720763 (witness_congr hM)
  have h1 : g (f 43) := (H 43 prime_43 (by norm_num)).mp cubic_residue_two_43
  exact not_cubic_residue_two_720763
    ((H 720763 prime_720763 (by norm_num)).mpr (hval ▸ h1))

/-- Same for the quartic bit, witnessed by `137` and `720857`. -/
theorem quartic_two_not_congruence_computable {X : Type*} {M : ℕ} (hM : M ∣ 720720)
    (f : ℕ → X) (hf : ∀ a b : ℕ, a % M = b % M → f a = f b) (g : X → Prop) :
    ¬ ∀ p : ℕ, p.Prime → p % 4 = 1 → (IsPowerResidue 4 p 2 ↔ g (f p)) := by
  intro H
  have hval : f 137 = f 720857 := hf 137 720857 (witness_congr' hM)
  have h1 : g (f 720857) := (H 720857 prime_720857 (by norm_num)).mp quartic_residue_two_720857
  exact not_quartic_residue_two_137 ((H 137 prime_137 (by norm_num)).mpr (hval ▸ h1))

/-- **The quadratic bit, by contrast, is exactly such a statistic**: `f p = p % 8`
together with the rule `r ↦ (r = 1 ∨ r = 7)` decides it at every odd prime. -/
theorem quadratic_two_congruence_computable :
    ∃ (f : ℕ → ℕ) (g : ℕ → Prop), (∀ a b : ℕ, a % 8 = b % 8 → f a = f b) ∧
      ∀ p : ℕ, p.Prime → p ≠ 2 → (IsPowerResidue 2 p 2 ↔ g (f p)) := by
  refine ⟨fun n => n % 8, fun r => r = 1 ∨ r = 7, fun a b h => h, ?_⟩
  intro p hp hp2
  haveI : Fact p.Prime := ⟨hp⟩
  rw [isPowerResidue_two_iff, Nat.cast_ofNat]
  exact ZMod.exists_sq_eq_two_iff hp2

/-- **The dichotomy of the residue channel.**  Quadratic residuacity is
congruence-computable; cubic residuacity is not congruence-computable at any
modulus dividing `lcm(1,…,16)`; and yet the cubic channel's fingerprints obey
the same `2 ^ K` capacity, sharply. -/
theorem escape_dichotomy :
    (∃ (f : ℕ → ℕ) (g : ℕ → Prop), (∀ a b : ℕ, a % 8 = b % 8 → f a = f b) ∧
        ∀ p : ℕ, p.Prime → p ≠ 2 → (IsPowerResidue 2 p 2 ↔ g (f p))) ∧
    (∀ {X : Type} {M : ℕ}, M ∣ 720720 → ∀ (f : ℕ → X),
        (∀ a b : ℕ, a % M = b % M → f a = f b) → ∀ g : X → Prop,
        ¬ ∀ p : ℕ, p.Prime → p % 3 = 1 → (IsPowerResidue 3 p 2 ↔ g (f p))) :=
  ⟨quadratic_two_congruence_computable,
    fun hM f hf g => cubic_two_not_congruence_computable hM f hf g⟩

/-! ## 3. Cycle 4: the two channels are mutually independent

The escape theorems say the cubic bit is not a congruence datum.  One could still
hope it is a *quadratic* datum in disguise — a function of the Legendre symbols,
which the attacker already has.  It is not, and neither is the converse: all
four combinations of (quadratic bit of `2`, cubic bit of `2`) occur. -/

/-- All four (quadratic, cubic) bit patterns for the base `2` are realised by
primes `≡ 1 (mod 3)`: `7` (square, non-cube), `13` (neither), `31` (both),
`43` (cube, non-square). -/
theorem quadratic_cubic_all_patterns :
    (∃ p : ℕ, p.Prime ∧ p % 3 = 1 ∧ IsPowerResidue 2 p 2 ∧ ¬ IsPowerResidue 3 p 2) ∧
    (∃ p : ℕ, p.Prime ∧ p % 3 = 1 ∧ ¬ IsPowerResidue 2 p 2 ∧ ¬ IsPowerResidue 3 p 2) ∧
    (∃ p : ℕ, p.Prime ∧ p % 3 = 1 ∧ IsPowerResidue 2 p 2 ∧ IsPowerResidue 3 p 2) ∧
    (∃ p : ℕ, p.Prime ∧ p % 3 = 1 ∧ ¬ IsPowerResidue 2 p 2 ∧ IsPowerResidue 3 p 2) :=
  ⟨⟨7, by norm_num, by norm_num, ⟨3, by decide⟩, by decide⟩,
   ⟨13, by norm_num, by norm_num, by decide, by decide⟩,
   ⟨31, by norm_num, by norm_num, ⟨8, by decide⟩, ⟨4, by decide⟩⟩,
   ⟨43, prime_43, by norm_num, by decide, cubic_residue_two_43⟩⟩

/-- **The cubic bit is not a function of the quadratic bit.**  No rule `g`
whatsoever turns quadratic residuacity of `2` into cubic residuacity of `2`:
`7` and `31` have the same quadratic bit and opposite cubic bits. -/
theorem cubic_not_determined_by_quadratic :
    ¬ ∃ g : Prop → Prop, ∀ p : ℕ, p.Prime → p % 3 = 1 →
      (IsPowerResidue 3 p 2 ↔ g (IsPowerResidue 2 p 2)) := by
  rintro ⟨g, hg⟩
  have h7 : IsPowerResidue 2 7 2 := ⟨3, by decide⟩
  have h31 : IsPowerResidue 2 31 2 := ⟨8, by decide⟩
  have e : (IsPowerResidue 2 7 2) = (IsPowerResidue 2 31 2) :=
    propext ⟨fun _ => h31, fun _ => h7⟩
  have c31 : g (IsPowerResidue 2 31 2) :=
    (hg 31 (by norm_num) (by norm_num)).mp ⟨4, by decide⟩
  have c7 : ¬ IsPowerResidue 3 7 2 := by decide
  exact c7 ((hg 7 (by norm_num) (by norm_num)).mpr (by rw [e]; exact c31))

/-- **And the quadratic bit is not a function of the cubic bit.**  `31` and `43`
have the same cubic bit and opposite quadratic bits.  The two channels are
therefore genuinely transverse — which is why the cubic channel escapes, and
equally why it cannot be *combined* with the quadratic one beyond the joint
capacity bound `PowerResidueCount.hybrid_no_amplification`. -/
theorem quadratic_not_determined_by_cubic :
    ¬ ∃ g : Prop → Prop, ∀ p : ℕ, p.Prime → p % 3 = 1 →
      (IsPowerResidue 2 p 2 ↔ g (IsPowerResidue 3 p 2)) := by
  rintro ⟨g, hg⟩
  have h31 : IsPowerResidue 3 31 2 := ⟨4, by decide⟩
  have e : (IsPowerResidue 3 31 2) = (IsPowerResidue 3 43 2) :=
    propext ⟨fun _ => cubic_residue_two_43, fun _ => h31⟩
  have c31 : g (IsPowerResidue 3 31 2) :=
    (hg 31 (by norm_num) (by norm_num)).mp ⟨8, by decide⟩
  have c43 : ¬ IsPowerResidue 2 43 2 := by decide
  exact c43 ((hg 43 prime_43 (by norm_num)).mpr (by rw [← e]; exact c31))

end PowerResidueSharp