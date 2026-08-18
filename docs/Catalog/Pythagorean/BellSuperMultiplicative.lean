import Pythagorean.KernelPatternsBell

/-!
# Super-multiplicativity of the Bell numbers

Continuing the kernel-pattern programme of `Pythagorean.KernelPatterns` and
`Pythagorean.KernelPatternsBell`, we prove that the Bell numbers are *super-multiplicative*:

`Nat.bell m * Nat.bell n ≤ Nat.bell (m + n)`,

with strict inequality as soon as both `m` and `n` are positive.

The proof is a genuine combinatorial injection at the level of kernel relations, not a
numerical estimate: a pair consisting of an equivalence relation on `A` and an equivalence
relation on `B` assembles into an equivalence relation on `A ⊕ B` (blocks are never allowed
to cross the two summands), and this assembly map is injective.  Counting with
`KernelPattern.kerCount_eq_bell` — the theorem that the number of equivalence relations on an
`n`-element type is `Nat.bell n` — turns the injection into the stated inequality.  Strictness
comes from exhibiting one relation outside the image: the total relation, which merges the
two summands.

As a consequence, `Nat.bell n ^ k ≤ Nat.bell (n * k)`, so the Bell numbers grow faster than any
exponential (`bell_pow_le_bell_mul`, `pow_le_bell_mul`).
-/

open Finset

namespace KernelPattern

variable {A B : Type*}

/-- Assemble an equivalence relation on `A` and one on `B` into an equivalence relation on
`A ⊕ B` whose blocks never cross the two summands. -/
def sumRel (r : A → A → Bool) (s : B → B → Bool) : A ⊕ B → A ⊕ B → Bool
  | Sum.inl a, Sum.inl a' => r a a'
  | Sum.inr b, Sum.inr b' => s b b'
  | Sum.inl _, Sum.inr _ => false
  | Sum.inr _, Sum.inl _ => false

@[simp] theorem sumRel_inl_inl (r : A → A → Bool) (s : B → B → Bool) (a a' : A) :
    sumRel r s (Sum.inl a) (Sum.inl a') = r a a' := rfl

@[simp] theorem sumRel_inr_inr (r : A → A → Bool) (s : B → B → Bool) (b b' : B) :
    sumRel r s (Sum.inr b) (Sum.inr b') = s b b' := rfl

@[simp] theorem sumRel_inl_inr (r : A → A → Bool) (s : B → B → Bool) (a : A) (b : B) :
    sumRel r s (Sum.inl a) (Sum.inr b) = false := rfl

@[simp] theorem sumRel_inr_inl (r : A → A → Bool) (s : B → B → Bool) (a : A) (b : B) :
    sumRel r s (Sum.inr b) (Sum.inl a) = false := rfl

theorem isKerRel_sumRel {r : A → A → Bool} {s : B → B → Bool}
    (hr : IsKerRel r) (hs : IsKerRel s) : IsKerRel (sumRel r s) := by
  refine ⟨?_, ?_, ?_⟩
  · rintro (a | b)
    · simpa using hr.1 a
    · simpa using hs.1 b
  · rintro (a | b) (a' | b') h
    · simpa using hr.2.1 _ _ (by simpa using h)
    · simp at h
    · simp at h
    · simpa using hs.2.1 _ _ (by simpa using h)
  · rintro (a | b) (a' | b') (a'' | b'') h₁ h₂ <;> simp at h₁ h₂ ⊢
    · exact hr.2.2 _ _ _ h₁ h₂
    · exact hs.2.2 _ _ _ h₁ h₂

/-- The assembly map is injective: each summand can be read back off the assembled relation. -/
theorem sumRel_injective :
    Function.Injective (fun p : (A → A → Bool) × (B → B → Bool) => sumRel p.1 p.2) := by
  rintro ⟨r, s⟩ ⟨r', s'⟩ h
  have hr : r = r' := by
    funext a a'
    simpa using congrFun (congrFun h (Sum.inl a)) (Sum.inl a')
  have hs : s = s' := by
    funext b b'
    simpa using congrFun (congrFun h (Sum.inr b)) (Sum.inr b')
  simp [hr, hs]

variable [Fintype A] [DecidableEq A] [Fintype B] [DecidableEq B]

/-- The image of the assembly map inside the set of all equivalence relations on `A ⊕ B`. -/
def sumRelImage (A B : Type*) [Fintype A] [DecidableEq A] [Fintype B] [DecidableEq B] :
    Finset (A ⊕ B → A ⊕ B → Bool) :=
  (KerRels A ×ˢ KerRels B).image (fun p => sumRel p.1 p.2)

theorem sumRelImage_subset : sumRelImage A B ⊆ KerRels (A ⊕ B) := by
  intro t ht
  simp only [sumRelImage, Finset.mem_image, Finset.mem_product, mem_kerRels] at ht
  obtain ⟨⟨r, s⟩, ⟨hr, hs⟩, rfl⟩ := ht
  exact mem_kerRels.2 (isKerRel_sumRel hr hs)

theorem card_sumRelImage : (sumRelImage A B).card = kerCount A * kerCount B := by
  rw [sumRelImage, Finset.card_image_of_injective _ sumRel_injective, Finset.card_product]
  rfl

/-- **Super-multiplicativity of the count of equivalence relations.** -/
theorem kerCount_mul_le : kerCount A * kerCount B ≤ kerCount (A ⊕ B) := by
  rw [← card_sumRelImage]
  exact Finset.card_le_card sumRelImage_subset

/-- **Super-multiplicativity of the Bell numbers.** -/
theorem bell_mul_bell_le_bell_add (m n : ℕ) :
    Nat.bell m * Nat.bell n ≤ Nat.bell (m + n) := by
  have h := kerCount_mul_le (A := Fin m) (B := Fin n)
  rwa [kerCount_eq_bell, kerCount_eq_bell, kerCount_eq_bell, Fintype.card_fin,
    Fintype.card_fin, Fintype.card_sum, Fintype.card_fin, Fintype.card_fin] at h

/-! ## Strictness -/

/-- The relation merging *everything*, which is an equivalence relation on `A ⊕ B` but is never
of the form `sumRel r s` once both summands are inhabited. -/
theorem isKerRel_top (ι : Type*) : IsKerRel (fun _ _ : ι => true) :=
  ⟨fun _ => rfl, fun _ _ _ => rfl, fun _ _ _ _ _ => rfl⟩

theorem top_not_mem_sumRelImage (a : A) (b : B) :
    (fun _ _ : A ⊕ B => true) ∉ sumRelImage A B := by
  intro h
  simp only [sumRelImage, Finset.mem_image, Finset.mem_product] at h
  obtain ⟨⟨r, s⟩, -, hrs⟩ := h
  have := congrFun (congrFun hrs (Sum.inl a)) (Sum.inr b)
  simp at this

theorem kerCount_mul_lt (a : A) (b : B) : kerCount A * kerCount B < kerCount (A ⊕ B) := by
  rw [← card_sumRelImage]
  refine Finset.card_lt_card ⟨sumRelImage_subset, ?_⟩
  intro hsub
  exact top_not_mem_sumRelImage a b (hsub (mem_kerRels.2 (isKerRel_top _)))

/-- Strict super-multiplicativity of the Bell numbers for positive arguments. -/
theorem bell_mul_bell_lt_bell_add {m n : ℕ} (hm : 0 < m) (hn : 0 < n) :
    Nat.bell m * Nat.bell n < Nat.bell (m + n) := by
  have h := kerCount_mul_lt (A := Fin m) (B := Fin n) ⟨0, hm⟩ ⟨0, hn⟩
  rwa [kerCount_eq_bell, kerCount_eq_bell, kerCount_eq_bell, Fintype.card_fin,
    Fintype.card_fin, Fintype.card_sum, Fintype.card_fin, Fintype.card_fin] at h

/-! ## Consequences: super-exponential growth -/

/-- Iterating super-multiplicativity: `bell n ^ k ≤ bell (n * k)`. -/
theorem bell_pow_le_bell_mul (n k : ℕ) : Nat.bell n ^ k ≤ Nat.bell (n * k) := by
  induction k with
  | zero => simp
  | succ k ih =>
      calc Nat.bell n ^ (k + 1) = Nat.bell n ^ k * Nat.bell n := by ring
        _ ≤ Nat.bell (n * k) * Nat.bell n := Nat.mul_le_mul_right _ ih
        _ ≤ Nat.bell (n * k + n) := bell_mul_bell_le_bell_add _ _
        _ = Nat.bell (n * (k + 1)) := by ring_nf

/-- The Bell numbers dominate the exponential `2 ^ k`, at twice the index: `2 ^ k ≤ bell (2 * k)`. -/
theorem pow_le_bell_mul (k : ℕ) : 2 ^ k ≤ Nat.bell (2 * k) := by
  calc 2 ^ k = Nat.bell 2 ^ k := by rw [show Nat.bell 2 = 2 from bell_two']
    _ ≤ Nat.bell (2 * k) := bell_pow_le_bell_mul 2 k

/-- A sanity check against the table `1, 1, 2, 5, 15, 52`: the injection is far from
surjective already at `m = n = 2`, where `bell 2 * bell 2 = 4 < 15 = bell 4`. -/
theorem bell_two_mul_bell_two_lt_bell_four : Nat.bell 2 * Nat.bell 2 < Nat.bell 4 := by
  have := bell_mul_bell_lt_bell_add (m := 2) (n := 2) (by norm_num) (by norm_num)
  simpa using this

end KernelPattern