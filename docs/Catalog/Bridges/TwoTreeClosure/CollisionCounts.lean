import Mathlib
import Bridges.TwoTreeClosure.TreeCore
import Bridges.TwoTreeClosure.RepresentationOrbit

/-!
# Both collision behaviours are power-law frequent

`RepresentationOrbit.collision_letter_dichotomy` shows that letter-*splitting* and
letter-*preserving* hypotenuse collisions both occur above every bound.  That is a
support statement; the open direction asked for frequencies.  This file proves the
first quantitative half of it: both behaviours occur at least a **power of the
magnitude** often, so neither is a sparse accident.

* `SplitCollision N` / `SameCollision N` : `N` carries two distinct primitive nodes
  with different (resp. equal) ascent letters.
* `many_split_collisions` : for every `T` there are at least `T` distinct numbers
  `N ≤ 500 T² + 5` with `SplitCollision N`.  Since `X = 500T² + 5`, the counting
  function of splitting collisions is `≫ X^{1/2}`.
* `many_same_letter_collisions` : for every `T` there are at least `T` distinct
  numbers `N ≤ sgN T` with `SameCollision N`, and `sgN T ≍ T⁴`, so the counting
  function of non-splitting collisions is `≫ X^{1/4}`.
* `collision_counts_both_unbounded` : both counting functions tend to infinity.

The two exponents `1/2` and `1/4` are lower bounds coming from one explicit family
each (the Brahmagupta family `500t² + 5` and the Sophie Germain family `u⁴ + 4`);
they already show that the *ratio* of the two behaviours cannot be decided by a
finite computation, which is what the density direction asks about.
-/

namespace TwoTreeClosure

/-- `N` has two distinct primitive representations whose nodes carry different
ascent letters. -/
def SplitCollision (N : ℕ) : Prop :=
  ∃ m n m' n' : ℕ, IsNode m n ∧ IsNode m' n' ∧ hyp m n = N ∧ hyp m' n' = N ∧
    (m, n) ≠ (m', n') ∧ letterOf m n ≠ letterOf m' n'

/-- `N` has two distinct primitive representations whose nodes carry the *same*
ascent letter. -/
def SameCollision (N : ℕ) : Prop :=
  ∃ m n m' n' : ℕ, IsNode m n ∧ IsNode m' n' ∧ hyp m n = N ∧ hyp m' n' = N ∧
    (m, n) ≠ (m', n') ∧ letterOf m n = letterOf m' n'

/-! ### The splitting family `500 t² + 5` -/

theorem hyp_split_family (t : ℕ) (ht : 1 ≤ t) :
    hyp (20 * t - 1) (10 * t + 2) = 500 * t ^ 2 + 5 := by
  obtain ⟨s, rfl⟩ : ∃ s, t = s + 1 := ⟨t - 1, by omega⟩
  simp only [hyp]
  have e1 : 20 * (s + 1) - 1 = 20 * s + 19 := by omega
  have e2 : 10 * (s + 1) + 2 = 10 * s + 12 := by omega
  rw [e1, e2]
  ring

theorem splitCollision_family (t : ℕ) (ht : 1 ≤ t) : SplitCollision (500 * t ^ 2 + 5) := by
  obtain ⟨h1, h2, hh, hA, hB⟩ := letterOf_blind_of_magnitude t ht
  refine ⟨20 * t - 1, 10 * t + 2, 20 * t + 1, 10 * t - 2, h1, h2,
    hyp_split_family t ht, ?_, ?_, ?_⟩
  · rw [← hh]; exact hyp_split_family t ht
  · intro h
    have : (20 * t - 1 : ℕ) = 20 * t + 1 := congrArg Prod.fst h
    omega
  · rw [hA, hB]
    exact Letter.noConfusion

/-- The splitting magnitudes are pairwise distinct. -/
theorem splitFamily_strictMono : StrictMono (fun t : ℕ => 500 * t ^ 2 + 5) := by
  intro a b hab
  simp only
  nlinarith

/-! ### The non-splitting Sophie Germain family -/

theorem sameCollision_family (s : ℕ) : SameCollision (sgN s) :=
  ⟨(sgP s).1, (sgP s).2, (sgQ s).1, (sgQ s).2, isNode_sgP s, isNode_sgQ s,
    hyp_sgP s, hyp_sgQ s, by simpa using sgP_ne_sgQ s,
    by rw [letterOf_sgP, letterOf_sgQ]⟩

theorem sgN_strictMono : StrictMono sgN := by
  intro a b hab
  have h1 : 4 * a ^ 2 + 28 * a + 49 < 4 * b ^ 2 + 28 * b + 49 := by nlinarith
  have h2 : (4 * a ^ 2 + 28 * a + 49) ^ 2 < (4 * b ^ 2 + 28 * b + 49) ^ 2 :=
    Nat.pow_lt_pow_left h1 (by norm_num)
  simp only [sgN]
  omega

/-! ### Counting -/

/-- **At least `T` splitting collisions below `500T² + 5`.**  Equivalently, the number
of letter-splitting magnitudes up to `X` is at least `√((X − 5)/500)`. -/
theorem many_split_collisions (T : ℕ) :
    ∃ S : Finset ℕ, S.card = T ∧ ∀ N ∈ S, SplitCollision N ∧ N ≤ 500 * T ^ 2 + 5 := by
  refine ⟨(Finset.Icc 1 T).image (fun t => 500 * t ^ 2 + 5), ?_, ?_⟩
  · rw [Finset.card_image_of_injective _ splitFamily_strictMono.injective, Nat.card_Icc]
    omega
  · intro N hN
    obtain ⟨t, ht, rfl⟩ := Finset.mem_image.mp hN
    rw [Finset.mem_Icc] at ht
    exact ⟨splitCollision_family t ht.1, by nlinarith [ht.2, Nat.zero_le t]⟩

/-- **At least `T` non-splitting collisions below `sgN T ≍ T⁴`.**  Equivalently, the
number of letter-preserving magnitudes up to `X` is at least `≫ X^{1/4}`. -/
theorem many_same_letter_collisions (T : ℕ) :
    ∃ S : Finset ℕ, S.card = T ∧ ∀ N ∈ S, SameCollision N ∧ N ≤ sgN T := by
  refine ⟨(Finset.Icc 1 T).image sgN, ?_, ?_⟩
  · rw [Finset.card_image_of_injective _ sgN_strictMono.injective, Nat.card_Icc]
    omega
  · intro N hN
    obtain ⟨t, ht, rfl⟩ := Finset.mem_image.mp hN
    rw [Finset.mem_Icc] at ht
    exact ⟨sameCollision_family t, sgN_strictMono.monotone ht.2⟩

/-- **Both counting functions are unbounded.**  For every bound `K` there are more than
`K` splitting magnitudes and more than `K` non-splitting magnitudes; so no finite
computation decides which behaviour is typical, and the density question of the
programme is genuinely asymptotic. -/
theorem collision_counts_both_unbounded (K : ℕ) :
    (∃ S : Finset ℕ, K < S.card ∧ ∀ N ∈ S, SplitCollision N) ∧
      (∃ S : Finset ℕ, K < S.card ∧ ∀ N ∈ S, SameCollision N) := by
  obtain ⟨S₁, hc₁, hm₁⟩ := many_split_collisions (K + 1)
  obtain ⟨S₂, hc₂, hm₂⟩ := many_same_letter_collisions (K + 1)
  exact ⟨⟨S₁, by omega, fun N hN => (hm₁ N hN).1⟩,
    ⟨S₂, by omega, fun N hN => (hm₂ N hN).1⟩⟩

end TwoTreeClosure