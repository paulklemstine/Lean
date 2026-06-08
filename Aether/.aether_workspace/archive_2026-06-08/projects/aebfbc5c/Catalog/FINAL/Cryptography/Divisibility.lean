import Cryptography.Berggren.Defs

/-!
# Berggren Semigroup: Divisibility, Partial Order, and Normal Forms

## Main Results

* `berggren_left_cancel'`, `berggren_right_cancel'` — Cancellation via φ
* `leftDivides_refl`, `leftDivides_trans`, `leftDivides_antisymm` — Partial order
* `leftDivides_iff_prefix` — Left divisibility ↔ prefix on normal forms
* `left_quotient_unique` — Unique quotients
-/

set_option linter.unusedVariables false
set_option linter.unusedTactic false
set_option linter.unusedSimpArgs false

/-! ## Cancellation transported from free semigroup -/

theorem berggren_left_cancel'
    {a b c : FreeSemigroup BGen} (h : φ (a * b) = φ (a * c)) : b = c :=
  fs_left_cancel (φ_injective h)

theorem berggren_right_cancel'
    {a b c : FreeSemigroup BGen} (h : φ (b * a) = φ (c * a)) : b = c :=
  fs_right_cancel (φ_injective h)

/-! ## Berggren semigroup as a subtype -/

/-- The Berggren semigroup: matrices that are products of Berggren generators. -/
def BerggrenSg : Type :=
  { M : Matrix (Fin 3) (Fin 3) ℤ // ∃ w : FreeSemigroup BGen, φ w = M }

namespace BerggrenSg

noncomputable instance : Mul BerggrenSg where
  mul A B := ⟨A.1 * B.1, by
    obtain ⟨wa, hwa⟩ := A.2
    obtain ⟨wb, hwb⟩ := B.2
    exact ⟨wa * wb, by rw [φ_mul, hwa, hwb]⟩⟩

@[simp] theorem mul_val (A B : BerggrenSg) : (A * B).1 = A.1 * B.1 := rfl

noncomputable instance : Semigroup BerggrenSg where
  mul_assoc a b c := Subtype.ext (Matrix.mul_assoc a.1 b.1 c.1)

/-- Embed a FreeSemigroup word into BerggrenSg. -/
noncomputable def ofWord (w : FreeSemigroup BGen) : BerggrenSg := ⟨φ w, ⟨w, rfl⟩⟩

theorem ofWord_mul (a b : FreeSemigroup BGen) :
    ofWord (a * b) = ofWord a * ofWord b :=
  Subtype.ext (φ_mul a b)

theorem ofWord_injective : Function.Injective ofWord := fun _ _ h =>
  φ_injective (Subtype.ext_iff.mp h)

/-! ## Normal forms -/

/-- The unique normal form word for a Berggren semigroup element. -/
noncomputable def nf (A : BerggrenSg) : FreeSemigroup BGen := A.2.choose

theorem nf_spec (A : BerggrenSg) : φ (nf A) = A.1 := A.2.choose_spec

theorem nf_unique {A : BerggrenSg} {w : FreeSemigroup BGen}
    (hw : φ w = A.1) : w = nf A :=
  φ_injective (hw.trans (nf_spec A).symm)

theorem ofWord_nf (A : BerggrenSg) : ofWord (nf A) = A :=
  Subtype.ext (nf_spec A)

theorem nf_ofWord (w : FreeSemigroup BGen) : nf (ofWord w) = w :=
  (nf_unique rfl).symm

theorem nf_mul (A B : BerggrenSg) : nf (A * B) = nf A * nf B := by
  symm; apply nf_unique
  rw [φ_mul, nf_spec, nf_spec]; rfl

/-- Two BerggrenSg elements are equal iff their normal forms are equal. -/
theorem eq_iff_nf_eq {A B : BerggrenSg} : A = B ↔ nf A = nf B := by
  constructor
  · intro h; rw [h]
  · intro h; rw [← ofWord_nf A, ← ofWord_nf B, h]

/-! ## Left and right cancellation on BerggrenSg -/

theorem berggren_left_cancel {A B C : BerggrenSg} (h : A * B = A * C) : B = C := by
  rw [eq_iff_nf_eq] at h ⊢
  rw [nf_mul, nf_mul] at h
  exact fs_left_cancel h

theorem berggren_right_cancel {A B C : BerggrenSg} (h : B * A = C * A) : B = C := by
  rw [eq_iff_nf_eq] at h ⊢
  rw [nf_mul, nf_mul] at h
  exact fs_right_cancel h

/-! ## Divisibility relations -/

/-- `A` left-divides `B` if `B = A * C` for some `C`, or `A = B`. -/
def LeftDivides (A B : BerggrenSg) : Prop :=
  A = B ∨ ∃ C : BerggrenSg, B = A * C

/-- `A` right-divides `B` if `B = C * A` for some `C`, or `A = B`. -/
def RightDivides (A B : BerggrenSg) : Prop :=
  A = B ∨ ∃ C : BerggrenSg, B = C * A

/-- Prefix relation on FreeSemigroup. -/
def IsPrefixFS (u v : FreeSemigroup BGen) : Prop :=
  u = v ∨ ∃ t : FreeSemigroup BGen, v = u * t

/-- Suffix relation on FreeSemigroup. -/
def IsSuffixFS (u v : FreeSemigroup BGen) : Prop :=
  u = v ∨ ∃ t : FreeSemigroup BGen, v = t * u

/-! ## Partial order -/

theorem leftDivides_refl (A : BerggrenSg) : LeftDivides A A := Or.inl rfl

theorem leftDivides_trans {A B C : BerggrenSg}
    (h1 : LeftDivides A B) (h2 : LeftDivides B C) : LeftDivides A C := by
  rcases h1 with rfl | ⟨D₁, rfl⟩
  · exact h2
  · rcases h2 with rfl | ⟨D₂, rfl⟩
    · exact Or.inr ⟨D₁, rfl⟩
    · exact Or.inr ⟨D₁ * D₂, by rw [mul_assoc]⟩

/-- **Antisymmetry**: if `A | B` and `B | A`, then `A = B`.
    In a free semigroup, `a * x ≠ a`, so mutual divisibility forces equality. -/
theorem leftDivides_antisymm {A B : BerggrenSg}
    (h1 : LeftDivides A B) (h2 : LeftDivides B A) : A = B := by
  rcases h1 with rfl | ⟨C, hC⟩
  · rfl
  · rcases h2 with rfl | ⟨D, hD⟩
    · rfl
    · exfalso
      -- hC : B = A * C, hD : A = B * D
      -- So A = (A * C) * D = A * (C * D)
      have hAeq : nf A = nf A * (nf C * nf D) := by
        have h3 : A = A * (C * D) :=
          calc A = B * D := hD
            _ = (A * C) * D := by rw [hC]
            _ = A * (C * D) := mul_assoc A C D
        have h4 := congrArg nf h3
        rwa [nf_mul, nf_mul] at h4
      exact fs_no_right_id (nf A) (nf C * nf D) hAeq.symm

noncomputable instance : PartialOrder BerggrenSg where
  le := LeftDivides
  le_refl := leftDivides_refl
  le_trans _ _ _ := leftDivides_trans
  le_antisymm _ _ := leftDivides_antisymm

theorem rightDivides_antisymm {A B : BerggrenSg}
    (h1 : RightDivides A B) (h2 : RightDivides B A) : A = B := by
  rcases h1 with rfl | ⟨C, hC⟩
  · rfl
  · rcases h2 with rfl | ⟨D, hD⟩
    · rfl
    · exfalso
      have hAeq : nf A = (nf D * nf C) * nf A := by
        have h3 : A = (D * C) * A :=
          calc A = D * B := hD
            _ = D * (C * A) := by rw [hC]
            _ = (D * C) * A := (mul_assoc D C A).symm
        have h4 := congrArg nf h3
        rwa [nf_mul, nf_mul] at h4
      exact fs_no_left_id (nf A) (nf D * nf C) hAeq.symm

/-! ## Divisibility ↔ Prefix/Suffix -/

theorem leftDivides_iff_prefix (A B : BerggrenSg) :
    LeftDivides A B ↔ IsPrefixFS (nf A) (nf B) := by
  constructor
  · rintro (rfl | ⟨C, rfl⟩)
    · exact Or.inl rfl
    · exact Or.inr ⟨nf C, by rw [nf_mul]⟩
  · rintro (h | ⟨t, ht⟩)
    · left; rw [eq_iff_nf_eq]; exact h
    · right
      exact ⟨ofWord t, by
        rw [eq_iff_nf_eq, nf_mul, nf_ofWord]; exact ht⟩

theorem leftDivides_iff_exists_nf_factor (A B : BerggrenSg) :
    LeftDivides A B ↔ nf A = nf B ∨ ∃ t : FreeSemigroup BGen, nf B = nf A * t :=
  leftDivides_iff_prefix A B

theorem rightDivides_iff_suffix (A B : BerggrenSg) :
    RightDivides A B ↔ IsSuffixFS (nf A) (nf B) := by
  constructor
  · rintro (rfl | ⟨C, rfl⟩)
    · exact Or.inl rfl
    · exact Or.inr ⟨nf C, by rw [nf_mul]⟩
  · rintro (h | ⟨t, ht⟩)
    · left; rw [eq_iff_nf_eq]; exact h
    · right
      exact ⟨ofWord t, by
        rw [eq_iff_nf_eq, nf_mul, nf_ofWord]; exact ht⟩

/-! ## Unique quotients -/

theorem left_quotient_unique {A B C D : BerggrenSg}
    (h1 : B = A * C) (h2 : B = A * D) : C = D :=
  berggren_left_cancel (h1.symm.trans h2)

theorem right_quotient_unique {A B C D : BerggrenSg}
    (h1 : B = C * A) (h2 : B = D * A) : C = D :=
  berggren_right_cancel (h1.symm.trans h2)

end BerggrenSg