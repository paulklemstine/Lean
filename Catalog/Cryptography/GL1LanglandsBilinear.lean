/-
# GL₁ Langlands Bilinear Framework

This file formalizes the algebraic structure underlying the GL₁ Langlands correspondence,
centered on the observation that the Jacobi symbol is a *bilinear* pairing — simultaneously
multiplicative in both arguments — and that quadratic reciprocity is a self-duality statement
for this pairing.

## Main Definitions
- `BilinearSymbol`: A structure capturing pairings ℤ → ℕ → ℤ that are multiplicative
  in both arguments and take values in {-1, 0, 1}.
- `ShapeColorPairing`: The GL₁ "shape-color dictionary" connecting quadratic field
  discriminants ("shapes") to Dirichlet characters ("colors").
- `ReciprocityData`: Encodes the correction sign in quadratic reciprocity as structure.

## Main Results
- `jacobiSym_bilinear`: The Jacobi symbol satisfies the BilinearSymbol axioms.
- `reciprocity_as_duality`: Quadratic reciprocity reformulated as self-duality of the
  Jacobi pairing with an explicit correction sign.
- `jacobi_neg_one_eq_chi4`: J(-1, b) = χ₄(b) for odd b.
- `bilinear_symbol_kernel_mul_closed`: The kernel of a bilinear symbol is closed under ×.
- `neg_one_shape_detector`: J(-1, p) = 1 iff p ≡ 1 (mod 4) for odd primes.
-/

import Mathlib

open ZMod Finset Nat Int

/-! ## Bilinear Symbol Structure -/

/-- A `BilinearSymbol` is a pairing `ℤ → ℕ → ℤ` that is multiplicative in both
arguments and whose values lie in `{-1, 0, 1}`. This abstracts the essential
algebraic structure of the Jacobi symbol. -/
structure BilinearSymbol where
  /-- The pairing function -/
  toFun : ℤ → ℕ → ℤ
  /-- Multiplicativity in the first argument -/
  mul_left : ∀ a₁ a₂ : ℤ, ∀ b : ℕ, toFun (a₁ * a₂) b = toFun a₁ b * toFun a₂ b
  /-- Multiplicativity in the second argument (for nonzero factors) -/
  mul_right : ∀ a : ℤ, ∀ b₁ b₂ : ℕ, b₁ ≠ 0 → b₂ ≠ 0 →
    toFun a (b₁ * b₂) = toFun a b₁ * toFun a b₂
  /-- Values are in {-1, 0, 1} -/
  val_trichotomy : ∀ a : ℤ, ∀ b : ℕ, toFun a b = -1 ∨ toFun a b = 0 ∨ toFun a b = 1

instance : CoeFun BilinearSymbol (fun _ => ℤ → ℕ → ℤ) := ⟨BilinearSymbol.toFun⟩

/-! ## The Jacobi Symbol is a Bilinear Symbol -/

/-
The Jacobi symbol `J(a, b)` takes values in `{-1, 0, 1}`.
-/
theorem jacobiSym_trichotomy (a : ℤ) (b : ℕ) :
    jacobiSym a b = -1 ∨ jacobiSym a b = 0 ∨ jacobiSym a b = 1 := by
  grind +suggestions

/-- The Jacobi symbol satisfies all `BilinearSymbol` axioms. -/
noncomputable def jacobiSym_bilinear : BilinearSymbol where
  toFun := jacobiSym
  mul_left := jacobiSym.mul_left
  mul_right := fun a b₁ b₂ h₁ h₂ => by
    haveI : NeZero b₁ := ⟨h₁⟩
    haveI : NeZero b₂ := ⟨h₂⟩
    exact jacobiSym.mul_right a b₁ b₂
  val_trichotomy := jacobiSym_trichotomy

/-! ## Reciprocity as Self-Duality -/

/-- `ReciprocityData` packages the correction sign `ε(a, b)` such that
`J(a, b) = ε(a, b) · J(b, a)` for odd coprime `a, b`. This is the
"self-duality defect" of the Jacobi pairing. -/
structure ReciprocityData where
  /-- The correction sign -/
  correctionSign : ℕ → ℕ → ℤ
  /-- The correction sign is ±1 -/
  sign_val : ∀ a b : ℕ, correctionSign a b = 1 ∨ correctionSign a b = -1
  /-- The correction sign is symmetric -/
  sign_symmetric : ∀ a b : ℕ, correctionSign a b = correctionSign b a

/-- The quadratic reciprocity correction sign `(-1)^((a/2)(b/2))`. -/
def qrCorrectionSign (a b : ℕ) : ℤ := (-1) ^ (a / 2 * (b / 2))

/-
The QR correction sign takes values ±1.
-/
theorem qrCorrectionSign_val (a b : ℕ) :
    qrCorrectionSign a b = 1 ∨ qrCorrectionSign a b = -1 := by
  exact Int.isUnit_iff.mp ( isUnit_one.neg.pow _ )

/-
The QR correction sign is symmetric: `(-1)^((a/2)(b/2)) = (-1)^((b/2)(a/2))`.
-/
theorem qrCorrectionSign_symm (a b : ℕ) :
    qrCorrectionSign a b = qrCorrectionSign b a := by
  unfold qrCorrectionSign; ring;

/-- The quadratic reciprocity correction forms valid `ReciprocityData`. -/
def qrReciprocity : ReciprocityData where
  correctionSign := qrCorrectionSign
  sign_val := qrCorrectionSign_val
  sign_symmetric := qrCorrectionSign_symm

/-
**Quadratic Reciprocity as Self-Duality**: For odd `a, b`, the Jacobi symbol
satisfies `J(a, b) = ε(a,b) · J(b, a)` where `ε` is the QR correction sign.
This is the fundamental "shape-color duality" of the GL₁ correspondence.
-/
theorem reciprocity_as_duality {a b : ℕ} (ha : Odd a) (hb : Odd b) :
    jacobiSym (↑a) b = qrCorrectionSign a b * jacobiSym (↑b) a := by
  -- Since $a$ and $b$ are odd, we have $a \equiv a$ and $b \equiv b$.
  obtain ⟨k, rfl⟩ := ha
  obtain ⟨l, rfl⟩ := hb;
  convert jacobiSym.quadratic_reciprocity ( show Odd ( 2 * k + 1 ) from ⟨ k, rfl ⟩ ) ( show Odd ( 2 * l + 1 ) from ⟨ l, rfl ⟩ ) using 1

/-! ## Shape-Color Pairing for GL₁ -/

/-- The `ShapeColorPairing` formalizes the GL₁ Langlands dictionary:
- "Shapes" are quadratic field discriminants `d ∈ ℤ`
- "Colors" are quadratic Dirichlet characters `χ_d`
- The pairing is given by the Jacobi symbol `J(d, ·)`

The key insight is that `J(d, p)` simultaneously encodes:
1. Whether `p` splits, remains inert, or ramifies in `ℚ(√d)` (the "shape" of `p`)
2. The value of the Dirichlet character `χ_d(p)` (the "color" of `p`) -/
structure ShapeColorPairing where
  /-- The underlying bilinear symbol -/
  symbol : BilinearSymbol
  /-- The discriminant (shape) -/
  discriminant : ℤ
  /-- The character evaluator: for fixed discriminant, gives a multiplicative function on ℕ -/
  charEval : ℕ → ℤ := fun n => symbol n discriminant.natAbs
  /-- The splitting detector: for fixed prime, tells splitting behavior -/
  splitDetect : ℤ → ℕ → ℤ := fun d p => symbol d p

/-! ## Kernel Structure -/

/-- The kernel of a `BilinearSymbol` in the first argument at a fixed `b`
is the set of `a` where the symbol equals 1. -/
def BilinearSymbol.firstKernel (σ : BilinearSymbol) (b : ℕ) : Set ℤ :=
  {a : ℤ | σ a b = 1}

/-
The kernel (set where σ(·, b) = 1) is closed under multiplication,
which is the first step toward showing it forms a subgroup of (ℤ/bℤ)×.
-/
theorem bilinear_symbol_kernel_mul_closed (σ : BilinearSymbol) (b : ℕ) :
    ∀ a₁ a₂ : ℤ, a₁ ∈ σ.firstKernel b → a₂ ∈ σ.firstKernel b →
    (a₁ * a₂) ∈ σ.firstKernel b := by
  exact fun a₁ a₂ ha₁ ha₂ => by rw [ BilinearSymbol.firstKernel ] at *; have := σ.mul_left a₁ a₂ b; aesop;

/-
For a non-degenerate bilinear symbol (one where σ(a, b) ≠ 0 for some a),
`1` is in the kernel. The key insight: σ(1,b) = σ(1·1,b) = σ(1,b)², and
x² = x with x ∈ {-1,0,1} forces x ∈ {0,1}; non-degeneracy rules out 0.
-/
theorem bilinear_symbol_kernel_one (σ : BilinearSymbol) (b : ℕ)
    (hnd : ∃ a : ℤ, σ a b ≠ 0) :
    (1 : ℤ) ∈ σ.firstKernel b := by
  obtain ⟨ a, ha ⟩ := hnd;
  -- By definition of $σ$, we know that $σ(1, b) = 1$ or $σ(1, b) = 0$.
  by_cases h1 : σ.toFun 1 b = 0;
  · exact False.elim <| ha <| by simpa [ h1 ] using σ.mul_left 1 a b;
  · have := σ.mul_left 1 1 b; simp_all +decide [ BilinearSymbol.firstKernel ] ;

/-! ## χ₄ and χ₈: Character Detection -/

/-
For odd `b`, `J(-1, b) = χ₄(b)`. This connects the Jacobi symbol at `-1`
to the primitive Dirichlet character mod 4, which detects whether `-1` is a
quadratic residue mod `b`.
-/
theorem jacobi_neg_one_eq_chi4 {b : ℕ} (hb : Odd b) :
    jacobiSym (-1) b = χ₄ (b : ZMod 4) := by
  obtain ⟨ k, rfl ⟩ := hb;
  convert jacobiSym.at_neg_one ( show Odd ( 2 * k + 1 ) from by norm_num ) using 1

/-
For odd `b`, `J(2, b) = χ₈(b)`. This connects the Jacobi symbol at `2`
to the primitive character mod 8, detecting the splitting of `2` in quadratic fields.
-/
theorem jacobi_two_eq_chi8 {b : ℕ} (hb : Odd b) :
    jacobiSym 2 b = χ₈ (b : ZMod 8) := by
  convert jacobiSym.at_two hb using 1

/-! ## Bilinear Symbol Composition -/

/-
Twisting the first argument of a bilinear symbol by a unit preserves the
multiplicative decomposition. This captures gauge invariance of the pairing.
-/
theorem bilinear_symbol_twist (σ : BilinearSymbol) (u : ℤ) (a : ℤ) (b : ℕ) :
    σ (u * a) b = σ u b * σ a b := by
  exact σ.mul_left u a b

/-! ## The Fundamental Bilinearity Equation -/

/-
**The Fundamental Bilinearity Equation**: For the Jacobi symbol,
`J(a₁a₂, b₁b₂) = J(a₁,b₁) · J(a₁,b₂) · J(a₂,b₁) · J(a₂,b₂)`
when `b₁, b₂ ≠ 0`. This is the "full expansion" of the bilinear pairing,
analogous to the distributive law for bilinear forms.
-/
theorem jacobi_full_bilinearity (a₁ a₂ : ℤ) (b₁ b₂ : ℕ)
    (hb₁ : b₁ ≠ 0) (hb₂ : b₂ ≠ 0) :
    jacobiSym (a₁ * a₂) (b₁ * b₂) =
    jacobiSym a₁ b₁ * jacobiSym a₁ b₂ * (jacobiSym a₂ b₁ * jacobiSym a₂ b₂) := by
  grind +suggestions

/-! ## Quadratic Character Periodicity -/

/-
The Jacobi symbol is periodic in the first argument modulo `b`.
-/
theorem jacobi_periodic (a : ℤ) (b : ℕ) (_hb : b ≠ 0) :
    jacobiSym a b = jacobiSym (a % (b : ℤ)) b := by
  convert jacobiSym.mod_left a b using 1

/-! ## Parity Detection via Bilinear Symbols -/

/-
For the Jacobi symbol, the value at `-1` completely determines whether
an odd prime is `1 mod 4` or `3 mod 4`. This is the simplest "shape detector":
the shape of `-1` classifies primes by their residue class mod 4.
-/
theorem neg_one_shape_detector {p : ℕ} (hp : Nat.Prime p) (hp2 : p ≠ 2) :
    jacobiSym (-1) p = 1 ↔ p % 4 = 1 := by
  rw [ jacobiSym.mod_right ];
  · have := Nat.mod_lt p zero_lt_four; interval_cases _ : p % 4 <;> simp_all +decide [ ← Nat.dvd_iff_mod_eq_zero, hp.dvd_iff_eq ] ;
    · exact absurd ( Nat.Prime.eq_two_or_odd hp ) ( by omega );
    · native_decide +revert;
  · exact hp.odd_of_ne_two hp2

/-! ## Conjecture: Bilinear Symbol Classification -/

/-- **Conjecture** (testable fragment): Every bilinear symbol that agrees with
the Jacobi symbol on inputs with `|a| ≤ 100` and prime `p ≤ 100` also agrees
on products of those inputs. This follows from multiplicativity but captures
the deeper fact that bilinear symbols on ℤ × ℕ are determined by their values
on generators. -/
def bilinear_agrees_on_small_primes (σ : BilinearSymbol) : Prop :=
  ∀ p : ℕ, p.Prime → p ≤ 100 → ∀ a : ℤ, |a| ≤ 100 →
    σ a p = jacobiSym a p →
    ∀ b : ℤ, |b| ≤ 100 →
      σ (a * b) p = jacobiSym (a * b) p

/-
The Jacobi symbol itself satisfies the classification test.
-/
theorem jacobi_satisfies_classification_test :
    bilinear_agrees_on_small_primes jacobiSym_bilinear := by
  unfold bilinear_agrees_on_small_primes; aesop