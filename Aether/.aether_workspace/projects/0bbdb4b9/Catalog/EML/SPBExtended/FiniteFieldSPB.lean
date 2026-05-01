import Mathlib

/-! # CatalogBuild.EML.SPBExtended.FiniteFieldSPB

Auto-generated from theorem catalog database.
Domain: EML/SPBExtended
Declarations: 31
-/

theorem neg_one_qr_mod17 : (4 : ZMod 17) ^ 2 = (-1 : ZMod 17) := by decide

theorem neg_one_qr_mod29 : (12 : ZMod 29) ^ 2 = (-1 : ZMod 29) := by decide

theorem neg_one_qnr_mod3 : ∀ x : ZMod 3, x ^ 2 ≠ (-1 : ZMod 3) := by decide

theorem neg_one_qnr_mod7 : ∀ x : ZMod 7, x ^ 2 ≠ (-1 : ZMod 7) := by decide

theorem neg_one_qnr_mod11 : ∀ x : ZMod 11, x ^ 2 ≠ (-1 : ZMod 11) := by decide

theorem neg_one_qnr_mod19 : ∀ x : ZMod 19, x ^ 2 ≠ (-1 : ZMod 19) := by decide

-- ═══════════════════════════════════════════════
-- § 2. SPB Poles (where 1+a²=0)
-- ═══════════════════════════════════════════════

theorem p5_poles : (1 + (2 : ZMod 5) ^ 2 = 0) ∧ (1 + (3 : ZMod 5) ^ 2 = 0) := by decide

theorem p5_nonpoles :
    (1 + (0 : ZMod 5) ^ 2 ≠ 0) ∧ (1 + (1 : ZMod 5) ^ 2 ≠ 0) ∧
    (1 + (4 : ZMod 5) ^ 2 ≠ 0) := by decide

theorem p7_no_poles : ∀ a : ZMod 7, 1 + a ^ 2 ≠ 0 := by decide

theorem p11_no_poles : ∀ a : ZMod 11, 1 + a ^ 2 ≠ 0 := by decide

theorem p13_poles : (1 + (5 : ZMod 13) ^ 2 = 0) ∧ (1 + (8 : ZMod 13) ^ 2 = 0) := by decide

theorem p3_no_poles : ∀ a : ZMod 3, 1 + a ^ 2 ≠ 0 := by decide

theorem p17_poles : (1 + (4 : ZMod 17) ^ 2 = 0) ∧ (1 + (13 : ZMod 17) ^ 2 = 0) := by decide

theorem p19_no_poles : ∀ a : ZMod 19, 1 + a ^ 2 ≠ 0 := by decide

-- ═══════════════════════════════════════════════
-- § 3. Norm Identity (universal)
-- ═══════════════════════════════════════════════

theorem norm_identity_ring {R : Type*} [CommRing R] (a b : R) :
    (1 + a ^ 2) * (1 + b ^ 2) = (1 - a * b) ^ 2 + (a + b) ^ 2 := by ring

theorem norm_identity_zmod (p : ℕ) (a b : ZMod p) :
    (1 + a ^ 2) * (1 + b ^ 2) = (1 - a * b) ^ 2 + (a + b) ^ 2 := by ring

-- ═══════════════════════════════════════════════
-- § 4. Concrete SPB over 𝔽₇
-- ═══════════════════════════════════════════════

theorem spb_mod7_1_1 : ((1 + 1 : ZMod 7) * (1 - 1 * 1 : ZMod 7)⁻¹) = 0 := by decide

theorem spb_mod7_1_2 : ((1 + 2 : ZMod 7) * (1 - 1 * 2 : ZMod 7)⁻¹) = 4 := by decide

theorem spb_mod7_2_2 : ((2 + 2 : ZMod 7) * (1 - 2 * 2 : ZMod 7)⁻¹) = 1 := by decide

theorem spb_mod7_3_3 : ((3 + 3 : ZMod 7) * (1 - 3 * 3 : ZMod 7)⁻¹) = 1 := by decide

-- ═══════════════════════════════════════════════
-- § 5. Concrete SPB over 𝔽₃
-- ═══════════════════════════════════════════════

theorem spb_mod3_pole : (1 - 1 * 1 : ZMod 3) = 0 := by decide

theorem spb_mod3_1_2 : ((1 + 2 : ZMod 3) * (1 - 1 * 2 : ZMod 3)⁻¹) = 0 := by decide

-- ═══════════════════════════════════════════════
-- § 6. Norm Map Values over 𝔽₇
-- ═══════════════════════════════════════════════

theorem p7_norm_values :
    (1 + (0 : ZMod 7) ^ 2 = 1) ∧ (1 + (1 : ZMod 7) ^ 2 = 2) ∧
    (1 + (2 : ZMod 7) ^ 2 = 5) ∧ (1 + (3 : ZMod 7) ^ 2 = 3) ∧
    (1 + (4 : ZMod 7) ^ 2 = 3) ∧ (1 + (5 : ZMod 7) ^ 2 = 5) ∧
    (1 + (6 : ZMod 7) ^ 2 = 2) := by decide

theorem p7_norm_image_size :
    ({1, 2, 3, 5} : Finset (ZMod 7)).card = 4 := by decide

theorem norm_even {p : ℕ} (a : ZMod p) : 1 + (-a) ^ 2 = 1 + a ^ 2 := by ring

-- ═══════════════════════════════════════════════
-- § 7. Pole Counting (The p±1 Law)
-- ═══════════════════════════════════════════════

-- For p ≡ 1 (mod 4): 2 poles, SPB group order = (p-2) + 1 = p-1
-- For p ≡ 3 (mod 4): 0 poles, SPB group order = p + 1

theorem p5_pole_count :
    (Finset.univ.filter (fun a : ZMod 5 => 1 + a ^ 2 = 0)).card = 2 := by decide

theorem p7_pole_count :
    (Finset.univ.filter (fun a : ZMod 7 => 1 + a ^ 2 = 0)).card = 0 := by decide

theorem p11_pole_count :
    (Finset.univ.filter (fun a : ZMod 11 => 1 + a ^ 2 = 0)).card = 0 := by decide

theorem p13_pole_count :
    (Finset.univ.filter (fun a : ZMod 13 => 1 + a ^ 2 = 0)).card = 2 := by decide

theorem p17_pole_count :
    (Finset.univ.filter (fun a : ZMod 17 => 1 + a ^ 2 = 0)).card = 2 := by decide

theorem p19_pole_count :
    (Finset.univ.filter (fun a : ZMod 19 => 1 + a ^ 2 = 0)).card = 0 := by decide

-- The pattern:
-- p=3  (≡3 mod 4): 0 poles → order 4  = 3+1  ✓
-- p=5  (≡1 mod 4): 2 poles → order 4  = 5-1  ✓
-- p=7  (≡3 mod 4): 0 poles → order 8  = 7+1  ✓
-- p=11 (≡3 mod 4): 0 poles → order 12 = 11+1 ✓
-- p=13 (≡1 mod 4): 2 poles → order 12 = 13-1 ✓
-- p=17 (≡1 mod 4): 2 poles → order 16 = 17-1 ✓
-- p=19 (≡3 mod 4): 0 poles → order 20 = 19+1 ✓