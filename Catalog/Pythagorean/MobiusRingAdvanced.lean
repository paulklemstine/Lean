/-
  # Advanced Theory of the Möbius Ring ℤ√1

  Building on the basic Möbius ring theory, this file develops:
  1. Conjugation as a ring involution and its fixed-point structure
  2. The norm as a product z · conj(z), connecting to Galois-theoretic norms
  3. A complete characterization of norm-representable integers
  4. The splitting isomorphism onto the parity sublattice
  5. Bridge to the Lorentz form a² − b² and Pythagorean geometry

  ## Key Novel Results

  * `conj_involution` : conjugation is an involution (conj ∘ conj = id)
  * `norm_eq_mul_conj_re` : N(z) = re(z · conj(z)), the Galois norm formula
  * `norm_representable_iff` : n is a Möbius norm iff n % 4 ≠ 2 ∧ n % 4 ≠ -2
  * `splitting_surj_parity` : the splitting map is surjective onto the parity sublattice
  * `lorentz_norm_eq` : the Lorentz form Q(a,b) = a² − b² equals the Möbius norm
-/
import Mathlib

namespace MobiusRingAdvanced

/-- The Möbius ring ℤ√1. -/
abbrev M := ℤ√(1 : ℤ)

/-- The generator ε satisfying ε² = 1. -/
def eps : M := ⟨0, 1⟩

/-! ## Conjugation

The conjugation map conj(a + bε) = a − bε is the unique nontrivial
ring automorphism of ℤ√1. It is the algebraic analogue of the
orientation-reversing deck transformation of the Möbius double cover. -/

/-- Conjugation in the Möbius ring: conj(a + bε) = a − bε. -/
def conj (z : M) : M := ⟨z.re, -z.im⟩

/-- Conjugation is an involution: conj(conj(z)) = z. -/
theorem conj_involution (z : M) : conj (conj z) = z := by
  simp [conj, Zsqrtd.ext_iff]

/-- Conjugation is multiplicative: conj(x · y) = conj(x) · conj(y). -/
theorem conj_mul (x y : M) : conj (x * y) = conj x * conj y := by
  simp only [conj, Zsqrtd.ext_iff]; constructor <;> simp <;> ring

/-- Conjugation preserves addition. -/
theorem conj_add (x y : M) : conj (x + y) = conj x + conj y := by
  simp [conj, Zsqrtd.ext_iff]; omega

/-- Conjugation preserves 1. -/
theorem conj_one : conj (1 : M) = 1 := by
  simp [conj, Zsqrtd.ext_iff]

/-- Conjugation sends ε to −ε. -/
theorem conj_eps : conj eps = -eps := by
  simp [conj, eps, Zsqrtd.ext_iff]

/-- The fixed points of conjugation are exactly the "real" elements. -/
theorem conj_fixed_iff (z : M) : conj z = z ↔ z.im = 0 := by
  constructor
  · intro h; simp [conj, Zsqrtd.ext_iff] at h; omega
  · intro h; simp [conj, Zsqrtd.ext_iff, h]

/-! ## Norm via Conjugation

The norm N(z) = z.re² − z.im² equals the real part of z · conj(z).
This is the Möbius analogue of the Galois norm in quadratic extensions. -/

/-- The product z · conj(z) is always "real" (has zero imaginary part). -/
theorem mul_conj_im_zero (z : M) : (z * conj z).im = 0 := by
  simp [conj]; ring

/-- **Galois norm formula**: N(z) = re(z · conj(z)). -/
theorem norm_eq_mul_conj_re (z : M) : z.norm = (z * conj z).re := by
  simp [conj, Zsqrtd.norm_def]; ring

/-- The norm is multiplicative: N(xy) = N(x) · N(y). -/
theorem norm_mul (x y : M) : (x * y).norm = x.norm * y.norm :=
  Zsqrtd.norm_mul x y

/-! ## Norm Representation Theorem

Which integers n arise as N(z) for some z ∈ ℤ√1?
Since N(a + bε) = (a+b)(a−b) and a+b ≡ a−b (mod 2),
the product is either (even)(even) or (odd)(odd).
So n is representable iff n ≢ ±2 (mod 4). -/

/-
Forward direction: every Möbius norm satisfies the mod-4 condition.
-/
theorem norm_mod4_forward (z : M) : z.norm % 4 ≠ 2 ∧ z.norm % 4 ≠ -2 := by
  rcases Int.even_or_odd' z.re with ⟨ k, hk | hk ⟩ <;> rcases Int.even_or_odd' z.im with ⟨ l, hl | hl ⟩ <;> push_cast [ hk, hl, Zsqrtd.norm ] <;> ring_nf <;> norm_num [ Int.add_emod, Int.sub_emod, Int.mul_emod ]

/-
Backward direction: every integer n with n % 4 ≠ 2 and n % 4 ≠ -2
    is representable as a Möbius norm.
    For n odd: take a = (n+1)/2, b = (n-1)/2, then a²-b² = n.
    For n ≡ 0 mod 4: write n = 4k, take a = k+1, b = k-1, then a²-b² = 4k.
-/
theorem norm_mod4_backward (n : ℤ) (h1 : n % 4 ≠ 2) (h2 : n % 4 ≠ -2) :
    ∃ z : M, z.norm = n := by
  rcases Int.even_or_odd' n with ⟨ k, rfl | rfl ⟩ <;> simp_all +decide [ sq, Zsqrtd.norm ];
  · rcases Int.even_or_odd' k with ⟨ k, rfl | rfl ⟩ <;> ring_nf at * <;> norm_num at *;
    exact ⟨ ⟨ k + 1, k - 1 ⟩, by norm_num; ring ⟩;
  · exact ⟨ ⟨ k + 1, k ⟩, by ring ⟩

/-- **Complete norm representation theorem**: n is a Möbius norm if and only
    if n ≢ ±2 (mod 4). -/
theorem norm_representable_iff (n : ℤ) :
    (∃ z : M, z.norm = n) ↔ (n % 4 ≠ 2 ∧ n % 4 ≠ -2) := by
  constructor
  · rintro ⟨z, rfl⟩; exact norm_mod4_forward z
  · rintro ⟨h1, h2⟩; exact norm_mod4_backward n h1 h2

/-! ## The Parity Sublattice and Splitting Isomorphism -/

/-- The splitting map φ: ℤ√1 → ℤ × ℤ. -/
def splitMap (z : M) : ℤ × ℤ := (z.re + z.im, z.re - z.im)

/-- The parity condition. -/
def InParitySublattice (p : ℤ × ℤ) : Prop := p.1 % 2 = p.2 % 2

/-
**Splitting surjectivity onto the parity sublattice**.
-/
theorem splitting_surj_parity (p : ℤ × ℤ) (hp : InParitySublattice p) :
    ∃ z : M, splitMap z = p := by
  -- Since $p.1$ and $p.2$ have the same parity, we can write $p.1 = p.2 + 2k$ for some integer $k$.
  obtain ⟨k, hk⟩ : ∃ k : ℤ, p.1 = p.2 + 2 * k := by
    -- Since $p.1 \equiv p.2 \pmod{2}$, we have $p.1 - p.2$ is even.
    have h_even : Even (p.1 - p.2) := by
      exact even_iff_two_dvd.mpr ( Int.dvd_of_emod_eq_zero ( by rw [ Int.sub_emod, hp ] ; norm_num ) );
    exact h_even.imp fun k hk => by linarith;
  exact ⟨ ⟨ p.2 + k, k ⟩, by ext <;> simp +decide [ splitMap, hk ] ; ring ⟩

/-- The splitting map is injective. -/
theorem splitting_injective : Function.Injective splitMap := by
  intro x y h
  simp [splitMap, Prod.ext_iff] at h
  exact Zsqrtd.ext (by omega) (by omega)

/-
The splitting map respects multiplication componentwise.
-/
theorem splitMap_mul (x y : M) :
    (splitMap (x * y)).1 = (splitMap x).1 * (splitMap y).1 ∧
    (splitMap (x * y)).2 = (splitMap x).2 * (splitMap y).2 := by
  unfold splitMap;
  constructor <;> erw [ Zsqrtd.re_mul, Zsqrtd.im_mul ] <;> ring

/-! ## Bridge to the Lorentz Form -/

/-- The Lorentz form Q(a,b) = a² − b². -/
def lorentzForm (a b : ℤ) : ℤ := a ^ 2 - b ^ 2

/-
**Lorentz-norm bridge**: the Lorentz form equals the Möbius norm.
-/
theorem lorentz_norm_eq (a b : ℤ) :
    lorentzForm a b = (⟨a, b⟩ : M).norm := by
  unfold lorentzForm Zsqrtd.norm; ring;

/-
Integer points on the unit Lorentz hyperboloid a² − b² = 1 are exactly (±1, 0).
-/
theorem lorentz_unit_classification (a b : ℤ) (h : lorentzForm a b = 1) :
    (a = 1 ∧ b = 0) ∨ (a = -1 ∧ b = 0) := by
  -- By definition of $lorentzForm$, we know that $a^2 - b^2 = 1$.
  have h_eq : a^2 - b^2 = 1 := by
    exact h;
  -- This implies $(a - b)(a + b) = 1$.
  have h_factor : (a - b) * (a + b) = 1 := by
    linear_combination' h_eq;
  rw [ Int.mul_eq_one_iff_eq_one_or_neg_one ] at h_factor ; omega

/-! ## Quadratic Residue Connection -/

/-
**Every element mod an odd prime is a difference of two squares.**
-/
theorem norm_surjective_odd_prime (p : ℕ) (hp : Nat.Prime p) (hodd : p ≠ 2) :
    ∀ n : ZMod p, ∃ a b : ZMod p, a ^ 2 - b ^ 2 = n := by
  intro n
  by_cases hn : n = 0;
  · exact ⟨ 0, 0, by simp +decide [ hn ] ⟩;
  · haveI := Fact.mk hp; use ( n + 1 ) * ( 2 : ZMod p ) ⁻¹, ( n - 1 ) * ( 2 : ZMod p ) ⁻¹; ring;
    by_cases h : ( 2 : ZMod p ) = 0 <;> simp_all +decide [ sq, mul_assoc ];
    · rcases p with ( _ | _ | _ | p ) <;> cases h <;> trivial;
    · grind

/-! ## Idempotent Rigidity -/

/-
**Idempotent rigidity**: the only idempotents in ℤ√1 are 0 and 1.
-/
theorem no_nontrivial_idempotent :
    ¬ ∃ z : M, z * z = z ∧ z ≠ 0 ∧ z ≠ 1 := by
  simp +zetaDelta at *;
  intros x hx hx0
  have h1 : x.re * x.re + x.im * x.im = x.re := by
    simpa using congr_arg Zsqrtd.re hx
  have h2 : 2 * x.re * x.im = x.im := by
    convert congr_arg Zsqrtd.im hx using 1 ; norm_num ; ring;
  by_cases h_im : x.im = 0;
  · simp_all +decide [ Zsqrtd.ext_iff ];
  · exact False.elim <| h_im <| by nlinarith [ sq_nonneg ( x.re - 1 ) ] ;

/-! ## The Orientation Character -/

/-- The orientation character χ: ℤ√1 → ℤ/2ℤ, sending a + bε to b mod 2. -/
def orientChar (z : M) : ZMod 2 := z.im

/-- The orientation character is additive. -/
theorem orientChar_add (x y : M) :
    orientChar (x + y) = orientChar x + orientChar y := by
  simp [orientChar]

/-- The orientation character sends ε to 1 (the generator of ℤ/2ℤ). -/
theorem orientChar_eps : orientChar eps = 1 := by
  simp [orientChar, eps]

/-
An element is in the kernel of χ iff its ε-coefficient is even.
-/
theorem orientChar_zero_iff (z : M) :
    orientChar z = 0 ↔ (2 : ℤ) ∣ z.im := by
  erw [ ZMod.intCast_zmod_eq_zero_iff_dvd ];
  rfl

/-! ## Norm Fiber Structure -/

/-- **Novel structure**: The norm fiber, associating to each norm value
    the set of its preimages. -/
structure NormFiber (n : ℤ) where
  element : M
  norm_eq : element.norm = n

/-- The "positive" units {±1} (norm = 1) act on norm fibers,
    preserving the norm value. The "negative" units {±ε} (norm = -1)
    negate the norm. -/
theorem pos_unit_action_preserves_norm (n : ℤ) (z : M) (u : Mˣ)
    (hn : z.norm = n) (h_pos : u.val.norm = 1) :
    (u.val * z).norm = n := by
  rw [norm_mul, h_pos, one_mul, hn]

/-
Multiplication by ε negates the norm: N(ε·z) = −N(z).
-/
theorem eps_negates_norm (z : M) :
    (eps * z).norm = -z.norm := by
  -- By definition of $M$, we know that $eps * z = ⟨z.im, z.re⟩$.
  simp [eps, Zsqrtd.norm_def]

end MobiusRingAdvanced