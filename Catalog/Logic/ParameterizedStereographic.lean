/-! # CatalogBuild.Logic.ParameterizedStereographic

Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 20
-/

import Mathlib

noncomputable section

/-- The one-point compactification adds ∞ to a type -/
inductive Compactified (α : Type*)
  | finite (a : α)
  | infinity




/-- Extension of a function to compactified space -/
def extendFn {α β : Type*} (f : α → β) (default : β) :
    Compactified α → β
  | .finite a => f a
  | .infinity => default




/-- [Section: # CatalogBuild.Logic.ParameterizedStereographic
Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 20] -/
theorem extendFn_finite {α β : Type*} (f : α → β) (d : β) (a : α) :
    extendFn f d (.finite a) = f a := by
      rfl




/-- [Section: # CatalogBuild.Logic.ParameterizedStereographic
Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 20] -/
theorem extendFn_infinity {α β : Type*} (f : α → β) (d : β) :
    extendFn f d .infinity = d := by
      rfl




/-- Stereographic projection from S¹ minus north pole to ℝ -/
noncomputable def stereoProject (x y : ℝ) (hy : y ≠ 1) : ℝ :=
  x / (1 - y)




/-- Inverse stereographic projection: ℝ → S¹ -/
noncomputable def stereoInverse (t : ℝ) : ℝ × ℝ :=
  (2 * t / (1 + t^2), (t^2 - 1) / (1 + t^2))




theorem stereoInverse_on_circle (t : ℝ) :
    let p := stereoInverse t
    p.1 ^ 2 + p.2 ^ 2 = 1 := by
      unfold stereoInverse; ring_nf; norm_num [ show ( 1 + t ^ 2 ) ≠ 0 by positivity ] ;
      -- Combine and simplify the terms in the numerator.
      field_simp
      ring




/-- A parameterized problem instance -/
structure ParamInstance where
  inputSize : ℕ
  parameter : ℕ




/-- A kernel is a reduced instance with size bounded by the parameter -/
structure Kernel where
  bound : ℕ → ℕ  -- size bound as function of parameter
  reduce : ParamInstance → ParamInstance




/-- A kernel is polynomial if the bound is polynomial in k -/
def Kernel.isPoly (ker : Kernel) : Prop :=
  ∃ c d, ∀ k, ker.bound k ≤ c * k ^ d + c




/-- A kernel is linear if the bound is linear in k -/
def Kernel.isLinear (ker : Kernel) : Prop :=
  ∃ c, ∀ k, ker.bound k ≤ c * k + c




theorem linear_implies_poly (ker : Kernel) (h : ker.isLinear) : ker.isPoly := by
  exact ⟨ h.choose, 1, fun k => le_trans ( h.choose_spec k ) ( by ring_nf; norm_num ) ⟩




/-- ε-covering number (simplified model) -/
noncomputable def coveringNumber (n : ℕ) (radius : ℝ) : ℕ :=
  if radius ≤ 0 then 0
  else Nat.ceil ((1 / radius) ^ n)




theorem covering_number_pos (n : ℕ) (ε : ℝ) (hε : 0 < ε) :
    0 < coveringNumber (n + 1) ε := by
      unfold coveringNumber;
      split_ifs <;> [ linarith; exact Nat.ceil_pos.mpr ( pow_pos ( one_div_pos.mpr hε ) _ ) ]




theorem const_param_in_P (time : ℕ → ℕ → ℕ) (hfpt : IsFPT time) (k₀ : ℕ) :
    ∃ c' : ℕ, ∀ n, time n k₀ ≤ c' * n ^ c' + c' := by
      obtain ⟨ f, c, h ⟩ := hfpt;
      by_contra h_contra;
      -- Set k = k₀. Use c' = max c (f k₀).
      set k₀' := f k₀ with hk₀';
      refine' h_contra ⟨ c + k₀', fun n => le_trans ( h n k₀ ) _ ⟩;
      rcases n with ( _ | n ) <;> simp_all +decide [ pow_add ];
      · cases c <;> cases f k₀ <;> norm_num at *;
        exact absurd ( h_contra ( f k₀ + f k₀ + 1 ) ) ( by rintro ⟨ n, hn ⟩ ; nlinarith [ h n k₀, pow_nonneg ( Nat.zero_le n ) ( f k₀ + f k₀ + 1 ) ] );
      · nlinarith [ show 0 < ( n + 1 ) ^ c by positivity, show 0 < ( n + 1 ) ^ f k₀ by positivity, show ( n + 1 ) ^ c ≤ ( n + 1 ) ^ c * ( n + 1 ) ^ f k₀ by exact le_mul_of_one_le_right ( by positivity ) ( one_le_pow₀ ( by linarith ) ) ]




theorem compactified_fpt (time : ℕ → ℕ → ℕ) (hfpt : IsFPT time) (kmax : ℕ) :
    ∃ c : ℕ, ∀ n k, k ≤ kmax → time n k ≤ c * n ^ c + c := by
      -- From IsFPT, obtain f, c with ∀ n k, time n k ≤ f k * n^c + f k.
      obtain ⟨f, c, hc⟩ := hfpt;
      use ( ∑ k ∈ Finset.range ( kmax + 1 ), f k ) * 2 + c + 1;
      intro n k hk;
      by_cases hn : n = 0;
      · rcases c with ( _ | c ) <;> simp_all +decide;
        · linarith [ hc 0 k, Finset.single_le_sum ( fun a _ => Nat.zero_le ( f a ) ) ( Finset.mem_range.mpr ( by linarith : k < kmax + 1 ) ) ];
        · exact le_trans ( hc 0 k ) ( by norm_num; linarith [ Finset.single_le_sum ( fun x _ => Nat.zero_le ( f x ) ) ( Finset.mem_range.mpr ( Nat.lt_succ_of_le hk ) ) ] );
      · refine le_trans ( hc n k ) ?_;
        refine' add_le_add _ _;
        · refine' le_trans _ ( Nat.mul_le_mul_right _ <| show ( ∑ k ∈ Finset.range ( kmax + 1 ), f k ) * 2 + c + 1 ≥ f k from _ );
          · exact Nat.mul_le_mul_left _ ( pow_le_pow_right₀ ( Nat.pos_of_ne_zero hn ) ( by linarith [ Finset.single_le_sum ( fun x _ => Nat.zero_le ( f x ) ) ( Finset.mem_range.mpr ( Nat.lt_succ_of_le hk ) ) ] ) );
          · linarith [ Finset.single_le_sum ( fun x _ => Nat.zero_le ( f x ) ) ( Finset.mem_range.mpr ( by linarith : k < kmax + 1 ) ) ];
        · linarith [ Finset.single_le_sum ( fun x _ => Nat.zero_le ( f x ) ) ( Finset.mem_range.mpr ( by linarith : k < kmax + 1 ) ) ]




/-- Stereographic distance: maps parameter k to arctan, giving bounded metric -/
noncomputable def stereoDistance (k₁ k₂ : ℕ) : ℝ :=
  |Real.arctan (k₁ : ℝ) - Real.arctan (k₂ : ℝ)|




theorem stereoDistance_comm (k₁ k₂ : ℕ) :
    stereoDistance k₁ k₂ = stereoDistance k₂ k₁ := by
      exact abs_sub_comm _ _




theorem stereoDistance_bounded (k₁ k₂ : ℕ) :
    stereoDistance k₁ k₂ ≤ Real.pi := by
      exact abs_sub_le_iff.mpr ⟨ by linarith [ Real.neg_pi_div_two_lt_arctan k₁, Real.arctan_lt_pi_div_two k₁, Real.neg_pi_div_two_lt_arctan k₂, Real.arctan_lt_pi_div_two k₂ ], by linarith [ Real.neg_pi_div_two_lt_arctan k₁, Real.arctan_lt_pi_div_two k₁, Real.neg_pi_div_two_lt_arctan k₂, Real.arctan_lt_pi_div_two k₂ ] ⟩




theorem stereoDistance_triangle (k₁ k₂ k₃ : ℕ) :
    stereoDistance k₁ k₃ ≤ stereoDistance k₁ k₂ + stereoDistance k₂ k₃ := by
      exact abs_sub_le _ _ _




end
