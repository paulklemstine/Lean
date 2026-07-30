import Mathlib

/-!
# The arithmetic of ideals in the natural-number semiring

A formal development of foundational results and a concrete failure of cancellation from
Chen--Hyde--Laurens--Piermarini--Simons, *The Arithmetic of Semirings Part I: Ideals*.
We use Mathlib's existing `Ideal` type for ideals of a semiring.
-/

namespace ArithmeticOfSemirings

/-- Multiplicative similarity: two elements become equal after multiplication by a witness. -/
def Similar {M : Type*} [CommMonoid M] (a b : M) : Prop :=
  ∃ c : M, a * c = b * c

@[refl] theorem similar_refl {M : Type*} [CommMonoid M] (a : M) : Similar a a := by
  exact ⟨1, rfl⟩

@[symm] theorem similar_symm {M : Type*} [CommMonoid M] {a b : M} :
    Similar a b → Similar b a := by
  rintro ⟨c, h⟩
  exact ⟨c, h.symm⟩

@[trans] theorem similar_trans {M : Type*} [CommMonoid M] {a b c : M} :
    Similar a b → Similar b c → Similar a c := by
  rintro ⟨d, hd⟩ ⟨e, he⟩
  refine ⟨d * e, ?_⟩
  calc
    a * (d * e) = (a * d) * e := by simp [mul_assoc]
    _ = (b * d) * e := by rw [hd]
    _ = (b * e) * d := by ac_rfl
    _ = (c * e) * d := by rw [he]
    _ = c * (d * e) := by ac_rfl

/-- Similarity is compatible with multiplication. -/
theorem similar_mul {M : Type*} [CommMonoid M] {a₁ a₂ b₁ b₂ : M}
    (ha : Similar a₁ a₂) (hb : Similar b₁ b₂) :
    Similar (a₁ * b₁) (a₂ * b₂) := by
  rcases ha with ⟨c₁, h₁⟩
  rcases hb with ⟨c₂, h₂⟩
  refine ⟨c₁ * c₂, ?_⟩
  calc
    (a₁ * b₁) * (c₁ * c₂) = (a₁ * c₁) * (b₁ * c₂) := by ac_rfl
    _ = (a₂ * c₁) * (b₂ * c₂) := by rw [h₁, h₂]
    _ = (a₂ * b₂) * (c₁ * c₂) := by ac_rfl

/-- Every multiplicative invariant with cancellative target is constant on similarity classes. -/
theorem cancellative_invariant_of_similar
    {M N : Type*} [CommMonoid M] [CancelCommMonoid N]
    (f : M →* N) {a b : M} (h : Similar a b) : f a = f b := by
  rcases h with ⟨c, hc⟩
  apply mul_right_cancel (b := f c)
  simpa using congrArg f hc

namespace NatIdeal

/-- Similarity with a nonzero ideal witness, as used for ideals of `ℕ`. -/
def Similar (A B : Ideal ℕ) : Prop :=
  ∃ C : Ideal ℕ, C ≠ ⊥ ∧ A * C = B * C

/-- An element is integral over an ideal if multiplication by it preserves some nonzero
ideal witness up to multiplication by the original ideal. -/
def IsIntegralOver (A : Ideal ℕ) (r : ℕ) : Prop :=
  ∃ B : Ideal ℕ, B ≠ ⊥ ∧ Ideal.span {r} * B ≤ A * B

/-- The set-theoretic integral closure. -/
def integralClosure (A : Ideal ℕ) : Set ℕ :=
  {r | IsIntegralOver A r}

/-- Every element of an ideal is integral over it. -/
theorem subset_integralClosure (A : Ideal ℕ) : (A : Set ℕ) ⊆ integralClosure A := by
  intro r hr
  refine ⟨⊤, top_ne_bot, ?_⟩
  apply Ideal.mul_mono ?_ le_rfl
  exact Ideal.span_le.2 (by simpa using hr)

/-- Similar ideals have the same integral closure. -/
theorem integralClosure_eq_of_similar {A B : Ideal ℕ} (h : Similar A B) :
    integralClosure A = integralClosure B := by
  obtain ⟨C, hC_ne, hAC_eq_BC⟩ := h
  apply Set.ext
  intro r
  constructor
  · -- If r ∈ integralClosure A, show r ∈ integralClosure B
    intro hr
    rw [integralClosure] at hr
    obtain ⟨B', hB'_ne, hUB'⟩ := hr
    refine ⟨B' * C, ?_, ?_⟩
    · -- B' * C ≠ ⊥
      intro hBC_eq_bot
      have hB'_lt := bot_lt_iff_ne_bot.mpr hB'_ne
      have hC_lt := bot_lt_iff_ne_bot.mpr hC_ne
      rw [SetLike.lt_iff_le_and_exists] at hB'_lt hC_lt
      obtain ⟨_, x, hxB', hx_ne⟩ := hB'_lt
      obtain ⟨_, y, hyC, hy_ne⟩ := hC_lt
      have hxy : x * y ∈ B' * C := Ideal.mul_mem_mul hxB' hyC
      rw [hBC_eq_bot, Ideal.mem_bot] at hxy
      rcases mul_eq_zero.mp hxy with hx | hy <;> contradiction
    · -- span {r} * (B' * C) ≤ B * (B' * C)
      calc Ideal.span {r} * (B' * C) = (Ideal.span {r} * B') * C := by ring
        _ ≤ (A * B') * C := by gcongr
        _ = B * (B' * C) := by rw [mul_assoc A B' C, mul_left_comm A B' C, hAC_eq_BC, mul_left_comm B' B C]
  · -- If r ∈ integralClosure B, show r ∈ integralClosure A
    intro hr
    rw [integralClosure] at hr
    obtain ⟨B', hB'_ne, hUB'⟩ := hr
    refine ⟨B' * C, ?_, ?_⟩
    · -- B' * C ≠ ⊥
      intro hBC_eq_bot
      have hB'_lt := bot_lt_iff_ne_bot.mpr hB'_ne
      have hC_lt := bot_lt_iff_ne_bot.mpr hC_ne
      rw [SetLike.lt_iff_le_and_exists] at hB'_lt hC_lt
      obtain ⟨_, x, hxB', hx_ne⟩ := hB'_lt
      obtain ⟨_, y, hyC, hy_ne⟩ := hC_lt
      have hxy : x * y ∈ B' * C := Ideal.mul_mem_mul hxB' hyC
      rw [hBC_eq_bot, Ideal.mem_bot] at hxy
      rcases mul_eq_zero.mp hxy with hx | hy <;> contradiction
    · -- span {r} * (B' * C) ≤ A * (B' * C)
      calc Ideal.span {r} * (B' * C) = (Ideal.span {r} * B') * C := by ring
        _ ≤ (B * B') * C := by gcongr
        _ = A * (B' * C) := by rw [mul_assoc B B' C, mul_left_comm B B' C, hAC_eq_BC.symm, mul_left_comm B' A C]

/-- Integral closure is monotone in the ideal. -/
theorem integralClosure_mono {A B : Ideal ℕ} (h : A ≤ B) :
    integralClosure A ⊆ integralClosure B := by
  rintro r ⟨C, hC, hr⟩
  exact ⟨C, hC, hr.trans (Ideal.mul_mono h le_rfl)⟩

/-- Adjoining one integral element does not change the similarity class. -/
theorem add_span_similar_iff (A : Ideal ℕ) (r : ℕ) :
    Similar (A + Ideal.span {r}) A ↔ IsIntegralOver A r := by
  constructor
  · intro ⟨C, hC_ne, hC_eq⟩
    refine ⟨C, hC_ne, ?_⟩
    have h_add : (A + Ideal.span {r}) * C = A * C ⊔ Ideal.span {r} * C := by
      rw [Ideal.add_eq_sup, Ideal.sup_mul]
    rw [hC_eq] at h_add
    exact le_trans le_sup_right h_add.symm.le
  · intro ⟨B, hB_ne, hB_le⟩
    refine ⟨B, hB_ne, ?_⟩
    have h_add : (A + Ideal.span {r}) * B = A * B ⊔ Ideal.span {r} * B := by
      rw [Ideal.add_eq_sup, Ideal.sup_mul]
    rw [h_add]
    exact sup_eq_left.mpr hB_le

section NonCancellation

/-- The first ideal in the paper's explicit noncancellation example. -/
def A : Ideal ℕ := Ideal.span {5, 17}

/-- The strictly larger second ideal in the paper's explicit noncancellation example. -/
def B : Ideal ℕ := Ideal.span ({5, 17, 43} : Set ℕ)

/-- The common factor in the paper's explicit noncancellation example. -/
def C : Ideal ℕ := Ideal.span ({5, 11, 19, 23} : Set ℕ)

/-- `A` and `B` are distinct: 43 belongs to `B` but not to `A`. -/
theorem A_ne_B : A ≠ B := by
  intro h
  have h43 : (43 : ℕ) ∈ B :=
    Ideal.subset_span (by norm_num : (43 : ℕ) ∈ ({5, 17, 43} : Set ℕ))
  rw [h.symm] at h43
  unfold A at h43
  rw [Ideal.mem_span_insert] at h43
  obtain ⟨a, z, hz, heq⟩ := h43
  rw [Ideal.mem_span_singleton] at hz
  obtain ⟨k, rfl⟩ := hz
  omega

/-- The paper's concrete failure of cancellation for ideals of `ℕ`. -/
theorem A_mul_C_eq_B_mul_C : A * C = B * C := by
  rw [A, B, C]
  apply le_antisymm
  · apply mul_le_mul_left
    apply Ideal.span_mono
    simp [Set.insert_subset_iff]
  · -- Need to show B * C ≤ A * C
    -- A*C = span{25, 55, 95, 115, 85, 187, 323, 391}
    -- Verify each 43*g for g ∈ {5,11,19,23} is in A*C:
    -- 215 = 3*55 + 2*25
    -- 473 = 1*323 + 6*25  
    -- 817 = 2*187 + 1*323 + 1*95 + 1*25
    -- 989 = 1*391 + 1*323 + 5*55
    -- B = span{5,17,43} = span{5,17} + span{43} = A + (43)
    -- B * C = A * C + (43) * C
    -- Need: (43) * C ≤ A * C
    -- i.e., span{215, 473, 817, 989} ≤ A * C
    -- First, express B * C in terms of generators
    have hB : Ideal.span ({5, 17, 43} : Set ℕ) = Ideal.span {5, 17} ⊔ Ideal.span {43} := by
      rw [show ({5, 17, 43} : Set ℕ) = {5, 17} ∪ {43} from by ext x; simp [Set.mem_insert_iff]; tauto]
      rw [Ideal.span_union]
    -- B * C = (A ⊔ (43)) * C = A * C ⊔ (43) * C
    rw [hB]
    -- Use: (I ⊔ J) * K = I * K ⊔ J * K
    rw [Ideal.sup_mul]
    -- Need: span{5,17} * span{5,11,19,23} + span{43} * span{5,11,19,23} ≤ span{5,17} * span{5,11,19,23}
    -- This is: A * C + (43) * C ≤ A * C
    -- Equivalently: (43) * C ≤ A * C
    rw [sup_le_iff]
    constructor
    · exact le_rfl
    · -- Need to show: span{43} * span{5,11,19,23} ≤ span{5,17} * span{5,11,19,23}
      -- span{43} * span{5,11,19,23} = span{215, 473, 817, 989}
      -- Need to show each is in span{5,17} * span{5,11,19,23}
      rw [Ideal.span_mul_span, Ideal.span_le]
      intro x hx
      simp at hx
      rcases hx with rfl | rfl | rfl | rfl
      · -- 215 = 10*5 + 15*11 where 10,15 ∈ A and 5,11 ∈ C
        have h10 : (10 : ℕ) ∈ Ideal.span {5, 17} := by
          rw [Ideal.mem_span_pair]
          exact ⟨2, 0, by norm_num⟩
        have h15 : (15 : ℕ) ∈ Ideal.span {5, 17} := by
          rw [Ideal.mem_span_pair]
          exact ⟨3, 0, by norm_num⟩
        have h5 : (5 : ℕ) ∈ Ideal.span {5, 11, 19, 23} := Ideal.subset_span (by simp)
        have h11 : (11 : ℕ) ∈ Ideal.span {5, 11, 19, 23} := Ideal.subset_span (by simp)
        have h1 : 10 * 5 ∈ Ideal.span {5, 17} * Ideal.span {5, 11, 19, 23} := Ideal.mul_mem_mul h10 h5
        have h2 : 15 * 11 ∈ Ideal.span {5, 17} * Ideal.span {5, 11, 19, 23} := Ideal.mul_mem_mul h15 h11
        simpa only [show (10 : ℕ) * 5 + 15 * 11 = 215 by norm_num] using Ideal.add_mem _ h1 h2
      · -- 473 = 1*323 + 6*25 = 1*(17*19) + 6*(5*5)
        have h17 : (17 : ℕ) ∈ Ideal.span {5, 17} := Ideal.subset_span (by simp)
        have h19 : (19 : ℕ) ∈ Ideal.span {5, 11, 19, 23} := Ideal.subset_span (by simp)
        have h5 : (5 : ℕ) ∈ Ideal.span {5, 11, 19, 23} := Ideal.subset_span (by simp)
        have h6_5 : (30 : ℕ) ∈ Ideal.span {5, 17} := by
          rw [Ideal.mem_span_pair]; exact ⟨6, 0, by norm_num⟩
        have h1 : 17 * 19 ∈ Ideal.span {5, 17} * Ideal.span {5, 11, 19, 23} := Ideal.mul_mem_mul h17 h19
        have h2 : 30 * 5 ∈ Ideal.span {5, 17} * Ideal.span {5, 11, 19, 23} := Ideal.mul_mem_mul h6_5 h5
        simpa only [show (17 : ℕ) * 19 + 30 * 5 = 473 by norm_num] using Ideal.add_mem _ h1 h2
      · -- 817 = 2*187 + 323 + 95 + 25 = 2*(17*11) + (17*19) + (5*19) + (5*5)
        have h17 : (17 : ℕ) ∈ Ideal.span {5, 17} := Ideal.subset_span (by simp)
        have h5_A : (5 : ℕ) ∈ Ideal.span {5, 17} := Ideal.subset_span (by simp)
        have h11 : (11 : ℕ) ∈ Ideal.span {5, 11, 19, 23} := Ideal.subset_span (by simp)
        have h19 : (19 : ℕ) ∈ Ideal.span {5, 11, 19, 23} := Ideal.subset_span (by simp)
        have h5_C : (5 : ℕ) ∈ Ideal.span {5, 11, 19, 23} := Ideal.subset_span (by simp)
        have h2_17 : (34 : ℕ) ∈ Ideal.span {5, 17} := by
          rw [Ideal.mem_span_pair]; exact ⟨0, 2, by norm_num⟩
        have h1a : 34 * 11 ∈ Ideal.span {5, 17} * Ideal.span {5, 11, 19, 23} := Ideal.mul_mem_mul h2_17 h11
        have h1b : 17 * 19 ∈ Ideal.span {5, 17} * Ideal.span {5, 11, 19, 23} := Ideal.mul_mem_mul h17 h19
        have h1c : 5 * 19 ∈ Ideal.span {5, 17} * Ideal.span {5, 11, 19, 23} := Ideal.mul_mem_mul h5_A h19
        have h1d : 5 * 5 ∈ Ideal.span {5, 17} * Ideal.span {5, 11, 19, 23} := Ideal.mul_mem_mul h5_A h5_C
        have hsum : (34 * 11 + 17 * 19 + 5 * 19 + 5 * 5 : ℕ) ∈ Ideal.span {5, 17} * Ideal.span {5, 11, 19, 23} := by
          have := Ideal.add_mem _ h1a h1b
          have := Ideal.add_mem _ this h1c
          exact Ideal.add_mem _ this h1d
        simpa only [show (34 : ℕ) * 11 + 17 * 19 + 5 * 19 + 5 * 5 = 817 by norm_num] using hsum
      · -- 989 = 391 + 323 + 275 = 17*23 + 17*19 + 25*11
        have h17 : (17 : ℕ) ∈ Ideal.span {5, 17} := Ideal.subset_span (by simp)
        have h23 : (23 : ℕ) ∈ Ideal.span {5, 11, 19, 23} := Ideal.subset_span (by simp)
        have h19 : (19 : ℕ) ∈ Ideal.span {5, 11, 19, 23} := Ideal.subset_span (by simp)
        have h25 : (25 : ℕ) ∈ Ideal.span {5, 17} := by rw [Ideal.mem_span_pair]; exact ⟨5, 0, by norm_num⟩
        have h11 : (11 : ℕ) ∈ Ideal.span {5, 11, 19, 23} := Ideal.subset_span (by simp)
        have h1 : 17 * 23 ∈ Ideal.span {5, 17} * Ideal.span {5, 11, 19, 23} := Ideal.mul_mem_mul h17 h23
        have h2 : 17 * 19 ∈ Ideal.span {5, 17} * Ideal.span {5, 11, 19, 23} := Ideal.mul_mem_mul h17 h19
        have h3 : 25 * 11 ∈ Ideal.span {5, 17} * Ideal.span {5, 11, 19, 23} := Ideal.mul_mem_mul h25 h11
        have hsum : (17 * 23 + 17 * 19 + 25 * 11 : ℕ) ∈ Ideal.span {5, 17} * Ideal.span {5, 11, 19, 23} := by
          have := Ideal.add_mem _ h1 h2
          exact Ideal.add_mem _ this h3
        simpa only [show (17 : ℕ) * 23 + 17 * 19 + 25 * 11 = 989 by norm_num] using hsum

/-- Consequently, multiplication in the semiring of ideals of `ℕ` is not cancellative. -/
theorem natIdeal_not_left_cancel :
    ∃ I J K : Ideal ℕ, I ≠ J ∧ I * K = J * K := by
  exact ⟨A, B, C, A_ne_B, A_mul_C_eq_B_mul_C⟩

end NonCancellation

end NatIdeal
end ArithmeticOfSemirings