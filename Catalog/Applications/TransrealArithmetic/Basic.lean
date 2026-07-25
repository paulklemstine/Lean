import Mathlib
import Bridges.PosetTheory.ContinuousFunctionBridge

/-! # Transreal Arithmetic

The transreal line adjoins positive infinity, negative infinity, and the nullity value
`Φ` to the real numbers.  Nullity is infectious.  Addition treats opposite infinities
as indeterminate, while multiplication treats zero times either infinity as
indeterminate.  These conventions make every arithmetic expression meaningful, but
force familiar ring laws involving zero, inverses, and cancellation to fail.
-/

namespace TransrealArithmetic

/-- The real line with two signed infinities and nullity. -/
inductive Transreal where
  | finite : ℝ → Transreal
  | posInf : Transreal
  | negInf : Transreal
  | phi : Transreal

namespace Transreal

noncomputable section

/-- Additive negation exchanges the signed infinities and fixes nullity. -/
def neg : Transreal → Transreal
  | finite x => finite (-x)
  | posInf => negInf
  | negInf => posInf
  | phi => phi

/-- Total transreal addition. -/
def add : Transreal → Transreal → Transreal
  | phi, _ | _, phi => phi
  | finite x, finite y => finite (x + y)
  | posInf, negInf | negInf, posInf => phi
  | posInf, _ | _, posInf => posInf
  | negInf, _ | _, negInf => negInf

/-- Total transreal multiplication, with `0 · (±∞) = Φ`. -/
def mul : Transreal → Transreal → Transreal
  | phi, _ | _, phi => phi
  | finite x, finite y => finite (x * y)
  | finite x, posInf | posInf, finite x =>
      if x = 0 then phi else if 0 < x then posInf else negInf
  | finite x, negInf | negInf, finite x =>
      if x = 0 then phi else if 0 < x then negInf else posInf
  | posInf, posInf | negInf, negInf => posInf
  | posInf, negInf | negInf, posInf => negInf

/-- Total reciprocal.  The unsigned real zero maps to positive infinity. -/
def inv : Transreal → Transreal
  | finite x => if x = 0 then posInf else finite x⁻¹
  | posInf => finite 0
  | negInf => finite 0
  | phi => phi

instance : Zero Transreal := ⟨finite 0⟩
instance : One Transreal := ⟨finite 1⟩
instance : Neg Transreal := ⟨neg⟩
instance : Add Transreal := ⟨add⟩
instance : Mul Transreal := ⟨mul⟩
instance : Inv Transreal := ⟨inv⟩
instance : Div Transreal := ⟨fun x y => x * y⁻¹⟩

/-- The canonical inclusion of real numbers. -/
def ofReal (x : ℝ) : Transreal := finite x

/-- Exactly the ordinary values have a real shadow. -/
def realShadow : Transreal → Option ℝ
  | finite x => some x
  | _ => none

@[simp] theorem ofReal_injective : Function.Injective ofReal := by
  exact fun x y h => by injection h;

@[simp] theorem neg_finite (x : ℝ) : -(ofReal x) = ofReal (-x) := by
  rfl

@[simp] theorem add_finite (x y : ℝ) : ofReal x + ofReal y = ofReal (x + y) := by
  rfl

@[simp] theorem mul_finite (x y : ℝ) : ofReal x * ofReal y = ofReal (x * y) := by
  rfl

@[simp] theorem shadow_ofReal (x : ℝ) : realShadow (ofReal x) = some x := by
  rfl

/-
Finite arithmetic is closed and agrees exactly with real arithmetic.
-/
theorem finite_subfield_fragment (x y : ℝ) :
    realShadow (ofReal x + ofReal y) = some (x + y) ∧
    realShadow (ofReal x * ofReal y) = some (x * y) ∧
    realShadow (-ofReal x) = some (-x) := by
      unfold ofReal; aesop;

/-
Nullity is absorbing for all three basic arithmetic operations.
-/
theorem phi_absorbing (x : Transreal) :
    phi + x = phi ∧ x + phi = phi ∧ phi * x = phi ∧ x * phi = phi := by
      cases x <;> tauto

/-
Addition remains associative despite the exceptional opposite-infinity case.
-/
theorem add_assoc_total (x y z : Transreal) : (x + y) + z = x + (y + z) := by
  rcases x with ( _ | _ | _ | _ ) <;> rcases y with ( _ | _ | _ | _ ) <;> rcases z with ( _ | _ | _ | _ ) <;> try rfl;
  rename_i x y z; exact congr_arg finite ( by simp +decide [ add_assoc ] ) ;

/-
Addition remains commutative.
-/
theorem add_comm_total (x y : Transreal) : x + y = y + x := by
  have h_add_cases : ∀ a b : ℝ, (finite a) + (finite b) = (finite b) + (finite a) := by
    exact fun x y => add_finite x y ▸ add_finite y x ▸ by simp +decide [ add_comm ] ;
  cases x <;> cases y <;> tauto

/-
Multiplication remains commutative.
-/
theorem mul_comm_total (x y : Transreal) : x * y = y * x := by
  rcases x with ( _ | _ | _ | _ ) <;> rcases y with ( _ | _ | _ | _ ) <;> norm_cast;
  rename_i x y;
  exact congr_arg Transreal.finite ( mul_comm x y )

/-
Nullity is genuinely distinct from ordinary zero.
-/
theorem phi_ne_zero : phi ≠ (0 : Transreal) := by
  exact fun h => by cases h;

/-
The ring annihilation law fails: multiplying infinity by zero produces nullity.
-/
theorem zero_mul_posInf_failure : (0 : Transreal) * posInf = phi ∧
    (0 : Transreal) * posInf ≠ 0 := by
      -- To prove the equality, it suffices to show that $0 * posInf = phi$.
      have h_zero_posInf : 0 * posInf = phi := by
        -- By definition of multiplication, $0 * posInf = \phi$ because $0 \neq 0$.
        apply Eq.symm; exact (by
          have h : (0 : Transreal) = finite 0 := by
            rfl
          rw [h]
          exact (by
          exact Eq.symm ( by exact if_pos rfl )))
      rw [h_zero_posInf]
      norm_num [phi_ne_zero]

/-
The additive-inverse axiom fails at infinity.
-/
theorem infinity_additive_inverse_failure : posInf + (-posInf) = phi ∧
    posInf + (-posInf) ≠ 0 := by
      constructor;
      · rfl;
      · convert phi_ne_zero

/-
Additive cancellation fails even away from nullity in the inputs.
-/
theorem additive_cancellation_failure :
    posInf + ofReal 0 = posInf + ofReal 1 ∧ ofReal 0 ≠ ofReal 1 := by
      constructor <;> norm_num [ Transreal.ofReal ];
      rfl

/-
Reciprocal is involutive on finite values and positive infinity, but signed zero
cannot remember negative infinity.
-/
theorem reciprocal_boundary :
    (∀ x : ℝ, (ofReal x)⁻¹⁻¹ = ofReal x) ∧
    posInf⁻¹⁻¹ = posInf ∧ negInf⁻¹⁻¹ = posInf ∧ negInf⁻¹⁻¹ ≠ negInf := by
      constructor;
      · intro x
        by_cases hx : x = 0;
        · convert congr_arg ( fun x : Transreal => x⁻¹ ) ( show ( ofReal 0 ) ⁻¹ = posInf from ?_ ) using 1;
          · rw [ hx ];
          · aesop;
          · exact if_pos rfl;
        · erw [ show ( ofReal x : Transreal ) ⁻¹ = ofReal x⁻¹ from ?_ ];
          · exact show ( inv ( finite ( x⁻¹ ) ) ) = finite x from by unfold inv; simp +decide [ hx ] ;
          · exact if_neg hx;
      · -- By definition of inverse, we know that if $x = \text{posInf}$, then $x^{-1} = \text{finite } 0$.
        simp [Inv.inv];
        simp +decide [ Transreal.inv ]

/-
A precise classification of when multiplication produces nullity.  Besides an
already-null input, the only source is zero multiplied by a signed infinity.
-/
theorem mul_eq_phi_iff (x y : Transreal) :
    x * y = phi ↔
      x = phi ∨ y = phi ∨
      (x = ofReal 0 ∧ (y = posInf ∨ y = negInf)) ∨
      (y = ofReal 0 ∧ (x = posInf ∨ x = negInf)) := by
        revert x y;
        intro x;
        induction' x with x x y;
        · intro y; induction' y with y y;
          · exact iff_of_false ( by rintro ⟨ ⟩ ) ( by rintro ( ⟨ ⟩ | ⟨ ⟩ | ⟨ ⟩ | ⟨ ⟩ ) <;> tauto );
          · by_cases hx : x = 0 <;> simp +decide [ hx, ofReal ];
            · exact if_pos ( by norm_num );
            · by_cases hx_pos : 0 < x;
              · exact fun h => by rw [ show finite x * posInf = posInf from by exact if_neg hx |> fun h => h.trans ( if_pos hx_pos ) ] at h; cases h;
              · exact ne_of_eq_of_ne ( show finite x * posInf = negInf from by { exact if_neg hx |> fun h => h.trans <| if_neg <| by linarith } ) ( by { exact fun h => by cases h } );
          · by_cases hx : x = 0 <;> simp +decide [ hx, Transreal.mul ];
            · exact iff_of_true ( by exact if_pos ( by norm_num ) ) rfl;
            · exact iff_of_false ( by rw [ show finite x * negInf = if x = 0 then phi else if 0 < x then negInf else posInf by rfl ] ; aesop ) ( by exact fun h => hx <| by injection h );
          · aesop;
        · intro y;
          cases y <;> simp +decide [ * ];
          · rename_i x; rw [ show posInf * finite x = if x = 0 then phi else if 0 < x then posInf else negInf from rfl ] ; split_ifs <;> simp_all +decide [ ofReal ] ;
          · exact iff_of_false ( by rintro ⟨ ⟩ ) ( by rintro ⟨ ⟩ );
          · exact iff_of_false ( by rintro ⟨ ⟩ ) ( by rintro ( h | h ) <;> cases h );
          · rfl;
        · intro y; constructor <;> intro h <;> rcases y with ( _ | _ | _ | _ | y ) <;> norm_num at *;
          all_goals norm_cast;
          · cases h' : ‹ℝ› ; simp_all +decide [ Transreal.mul ];
            erw [ show ( negInf : Transreal ) * finite _ = if ( { cauchy := _ } : ℝ ) = 0 then phi else if 0 < ( { cauchy := _ } : ℝ ) then negInf else posInf from rfl ] at h ; aesop;
          · rcases h with ( h | h | h | h ) <;> simp_all +decide [ Transreal.ofReal ];
            exact if_pos rfl;
          · tauto;
          · cases h <;> cases ‹_›;
        · exact fun y => iff_of_true ( phi_absorbing y |>.2.2.1 ) ( Or.inl rfl )

/-
Real division survives exactly at nonzero finite denominators.
-/
theorem finite_division_survives (x y : ℝ) (hy : y ≠ 0) :
    ofReal x / ofReal y = ofReal (x / y) := by
      unfold ofReal;
      -- By definition of division in the transreal numbers, we have that finite x / finite y = finite (x * y⁻¹).
      have h_div : finite x / finite y = finite x * (finite y)⁻¹ := by
        rfl;
      rw [ h_div, show ( finite y ) ⁻¹ = finite ( y⁻¹ ) from ?_ ];
      · convert mul_finite x y⁻¹ using 1;
      · exact if_neg hy

/-- The ordinary exponential remains continuous when observed through the finite
transreal fragment.  This transfers the catalog's continuity result through the exact
real shadow of the transreal inclusion. -/
theorem finite_exp_shadow_continuous :
    Continuous (fun x : ℝ => (realShadow (ofReal (Real.exp x))).getD 0) := by
  simpa using ContinuousFunctionBridge.exp_continuous

/-
Division by zero is total and records the sign of a nonzero numerator.
-/
theorem positive_div_zero (x : ℝ) (hx : 0 < x) :
    ofReal x / 0 = posInf := by
      -- By definition of multiplication, we have `ofReal x * (finite 0)⁻¹ = ofReal x * posInf`.
      have h_mul : (Transreal.ofReal x) * (Transreal.finite 0)⁻¹ = (Transreal.ofReal x) * Transreal.posInf := by
        congr;
        exact if_pos rfl;
      convert h_mul using 1;
      exact Eq.symm ( by rw [ show ( ofReal x : Transreal ) * posInf = if x = 0 then phi else if 0 < x then posInf else negInf by rfl ] ; aesop )

end
end Transreal
end TransrealArithmetic