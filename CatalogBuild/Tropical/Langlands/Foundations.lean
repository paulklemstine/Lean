/-! # CatalogBuild.Tropical.Langlands.Foundations

Auto-generated from theorem catalog database.
Domain: Tropical/Langlands
Declarations: 22
-/

import Mathlib

noncomputable section

/-- The tropical semiring element type -/
abbrev TropicalR := WithTop ℝ

namespace TropicalLanglands

/-! ### Basic tropical operations -/

/-- Tropical addition (min) is commutative -/

theorem trop_add_zero (a : TropicalR) : min a ⊤ = a :=
  min_top_right a

/-- Tropical multiplication (+) distributes over tropical addition (min) -/

def tropInvertible (n : ℕ) (A : Fin n → Fin n → ℝ) : Prop :=
  tropDet n A ≠ 0

/-
Tropical matrix multiplication is associative (the key group law)
-/

theorem tropChar_determined_by_one (χ : TropicalCharacter) (n : ℤ) :
    χ.toFun n = n * χ.toFun 1 := by
  induction n using Int.induction_on <;> simp_all +decide;
  · have := χ.map_add 0 0; aesop;
  · rw [ add_mul, one_mul, χ.map_add, ‹χ.toFun _ = _› ];
  · have := χ.map_add ( -↑‹ℕ› - 1 ) 1; norm_num at * ; linarith

/-- The tropical characters on ℤ form a group under pointwise addition -/

theorem tropChar_add_is_char (χ₁ χ₂ : TropicalCharacter) :
    ∀ a b : ℤ, (χ₁.toFun a + χ₂.toFun a) + (χ₁.toFun b + χ₂.toFun b) =
    (χ₁.toFun (a + b) + χ₂.toFun (a + b)) := by
  intro a b
  rw [χ₁.map_add, χ₂.map_add]
  ring

/-! ## Section 4: Tropical Valuations and the Bridge to Number Theory

The connection between classical and tropical Langlands comes through valuations.
A p-adic valuation v_p : ℚ* → ℤ is already a "tropicalization map".
-/

/-- A valuation is a tropical homomorphism from (K*, ×) to (ℝ, +) -/

def trivialValuation (K : Type*) [Field K] [DecidableEq K] : TropicalValuation K where
  val := fun x => if x = 0 then ⊤ else (0 : ℝ)
  val_zero := by simp
  val_one := by simp [one_ne_zero]
  val_mul := by intro a b ha hb; simp [mul_ne_zero ha hb, ha, hb]
  val_add := by
    intro a b
    simp only [ge_iff_le]
    by_cases hab : a + b = 0
    · simp [hab]
    · simp only [hab, ite_false]
      by_cases ha : a = 0
      · subst ha; simp at hab; simp [hab]
      · by_cases hb : b = 0
        · subst hb; simp at hab; simp [hab]
        · simp [ha, hb]

/-! ## Section 5: Tropical L-Functions

Classical L-functions are Euler products L(s,π) = ∏_p L_p(s,π).
The tropical analogue replaces products with sums (tropical products)
and uses piecewise-linear functions.
-/

/-- A tropical L-function is a piecewise-linear function of s ∈ ℝ,
    defined as a tropical product (= sum) over "primes" -/

theorem tropicalL_convex
    (localFactors : ℕ → ℝ → ℝ)
    (primes : Finset ℕ)
    (hconvex : ∀ p ∈ primes, ∀ s t : ℝ, ∀ la : ℝ, 0 ≤ la → la ≤ 1 →
      localFactors p (la * s + (1 - la) * t) ≤
        la * localFactors p s + (1 - la) * localFactors p t) :
    ∀ s t : ℝ, ∀ la : ℝ, 0 ≤ la → la ≤ 1 →
      tropicalLFunction localFactors primes (la * s + (1 - la) * t) ≤
      la * tropicalLFunction localFactors primes s +
        (1 - la) * tropicalLFunction localFactors primes t := by
  intro s t la hla hla'; unfold tropicalLFunction; simp_all +decide [ ← add_assoc, Finset.mul_sum _ _ _ ] ;
  simpa only [ ← Finset.sum_add_distrib ] using Finset.sum_le_sum fun p hp => hconvex p hp s t la hla hla'

/-! ## Section 6: Tropical Hecke Algebra

The classical Hecke algebra is the convolution algebra of compactly supported
functions on G(F)\G(𝔸)/K. The tropical Hecke algebra replaces convolution
(integral of f*g) with tropical convolution (inf of f ⊕_trop g).
-/

/-- Tropical convolution of two functions f, g : ℤ → ℝ -/

def tropConvolution (f g : ℤ → ℝ) (n : ℤ) : ℝ :=
  ⨅ k : ℤ, f k + g (n - k)

/-
Tropical convolution is commutative
-/

theorem tropConv_comm (f g : ℤ → ℝ) (n : ℤ) :
    tropConvolution f g n = tropConvolution g f n := by
  unfold tropConvolution;
  rw [ ← Equiv.iInf_comp ( Equiv.subLeft n ) ] ; norm_num [ add_comm ]

/-! ## Section 7: Tropical Satake Isomorphism

The classical Satake isomorphism identifies the spherical Hecke algebra
H(G,K) with the representation ring Rep(Ĝ). In the tropical setting,
this becomes an isomorphism of tropical semirings.

For GL_2, the classical Satake parameters are eigenvalues (α, β) of the
Hecke operator. Tropically, these become slopes of a Newton polygon.
-/

/-- Tropical Satake parameter: a pair of slopes -/

def tropSatakeTransform (f : ℤ → ℝ) : ℝ × ℝ :=
  (⨅ n : ℤ, f n - n * (⨅ k : ℤ, f (k + 1) - f k),
   ⨆ n : ℤ, f n - n * (⨆ k : ℤ, f (k + 1) - f k))

/-! ## Section 8: Tropical Reciprocity — The Main Conjecture

The heart of the Langlands program is reciprocity: automorphic representations
↔ Galois representations. Our tropical analogue states:

**Tropical Reciprocity Conjecture**: There is a bijection between
- Tropical automorphic forms (piecewise-linear functions on the tropical building)
- Tropical Galois representations (piecewise-linear actions on tropical modules)
such that tropical L-functions match.

We formalize a finite version of this.
-/

/-- A tropical automorphic datum consists of a PL function on ℤ^n with
    specified slopes (the tropical Hecke eigenvalues) -/

structure TropicalAutomorphicDatum (n : ℕ) where
  slopes : Fin n → ℝ
  sorted : ∀ i j : Fin n, i ≤ j → slopes i ≤ slopes j

/-- A tropical Galois datum consists of a piecewise-linear action
    specified by its break-slopes -/

structure TropicalGaloisDatum (n : ℕ) where
  breaks : Fin n → ℝ
  sorted : ∀ i j : Fin n, i ≤ j → breaks i ≤ breaks j

/-- The tropical reciprocity map: send automorphic slopes to Galois breaks -/

def tropReciprocity (n : ℕ) (aut : TropicalAutomorphicDatum n) :
    TropicalGaloisDatum n where
  breaks := aut.slopes
  sorted := aut.sorted

/-- Tropical reciprocity is an involution -/

theorem tropReciprocity_invol (n : ℕ) (aut : TropicalAutomorphicDatum n) :
    let gal := tropReciprocity n aut
    let aut' : TropicalAutomorphicDatum n := ⟨gal.breaks, gal.sorted⟩
    tropReciprocity n aut' = gal := by
  simp [tropReciprocity]

/-
The L-functions match under tropical reciprocity (slope-matching theorem)
-/

theorem tropReciprocity_L_match (n : ℕ) (aut : TropicalAutomorphicDatum n)
    (localFactors : Fin n → ℝ → ℝ)
    (hfactors : ∀ i : Fin n, ∀ s : ℝ, localFactors i s = s - aut.slopes i) :
    let gal := tropReciprocity n aut
    ∀ s : ℝ, (∑ i : Fin n, localFactors i s) = (∑ i : Fin n, (s - gal.breaks i)) := by
  aesop

/-! ## Section 9: Tropical Langlands Duality

For a reductive group G, Langlands duality produces the dual group Ĝ.
In the tropical world, duality manifests through the duality of
tropical polytopes and the Legendre-Fenchel transform.
-/

/-- Legendre-Fenchel (convex conjugate) transform — the tropical Fourier transform -/

def legendreFenchel (f : ℝ → ℝ) (p : ℝ) : ℝ :=
  ⨆ x : ℝ, p * x - f x

/-
The Legendre-Fenchel transform is convex when the suprema are bounded above.
    This is a fundamental result: the sup of affine functions is convex.
-/

theorem legendreFenchel_convex (f : ℝ → ℝ)
    (hbdd : ∀ p : ℝ, BddAbove (Set.range fun x => p * x - f x)) :
    ∀ p q : ℝ, ∀ t : ℝ, 0 ≤ t → t ≤ 1 →
      legendreFenchel f (t * p + (1 - t) * q) ≤
      t * legendreFenchel f p + (1 - t) * legendreFenchel f q := by
  intro p q t ht₁ ht₂;
  refine' ciSup_le fun x => _;
  convert add_le_add ( mul_le_mul_of_nonneg_left ( le_ciSup ( hbdd p ) x ) ht₁ ) ( mul_le_mul_of_nonneg_left ( le_ciSup ( hbdd q ) x ) ( sub_nonneg.mpr ht₂ ) ) using 1 ; ring

/-
For a convex lsc function f with bounded conjugate, the biconjugate f** = f.
    This is the Fenchel-Moreau theorem.
-/

theorem legendreFenchel_biconjugate (f : ℝ → ℝ)
    (hconv : ∀ x y : ℝ, ∀ t : ℝ, 0 ≤ t → t ≤ 1 →
      f (t * x + (1 - t) * y) ≤ t * f x + (1 - t) * f y)
    (hlsc : ∀ x : ℝ, ∀ eps : ℝ, eps > 0 → ∃ delta : ℝ, delta > 0 ∧
      ∀ y : ℝ, |y - x| < delta → f x - eps < f y)
    (hbdd_conj : ∀ p : ℝ, BddAbove (Set.range fun x => p * x - f x))
    (hbdd_biconj : ∀ x : ℝ, BddAbove (Set.range fun p => x * p - legendreFenchel f p)) :
    legendreFenchel (legendreFenchel f) = f := by
  apply funext;
  -- Let's choose any $x$ and derive a contradiction to show that $f(x) \leq \text{ciSup} (\lambda p. x * p - \text{legendreFenchel} f p)$.
  intro x
  by_contra h_contra;
  have h_subgradient : ∃ p : ℝ, ∀ y : ℝ, f y ≥ f x + p * (y - x) := by
    have h_subgradient : ∀ y z : ℝ, y < x → x < z → (f x - f y) / (x - y) ≤ (f z - f x) / (z - x) := by
      intros y z hy hz;
      have := hconv z y ( ( x - y ) / ( z - y ) ) ( by rw [ le_div_iff₀ ] <;> linarith ) ( by rw [ div_le_iff₀ ] <;> linarith );
      rw [ div_le_div_iff₀ ] <;> try linarith;
      rw [ show ( x - y ) / ( z - y ) * z + ( 1 - ( x - y ) / ( z - y ) ) * y = x by linarith [ div_mul_cancel₀ ( x - y ) ( by linarith : ( z - y ) ≠ 0 ) ] ] at this; rw [ div_mul_eq_mul_div, one_sub_div ( by linarith ) ] at this; rw [ div_mul_eq_mul_div, ← add_div, le_div_iff₀ ] at this <;> linarith;
    -- Let's choose any $p$ such that $p$ is between the slopes of the secant lines through $x$.
    obtain ⟨p, hp⟩ : ∃ p : ℝ, ∀ y : ℝ, y < x → (f x - f y) / (x - y) ≤ p ∧ ∀ y : ℝ, x < y → p ≤ (f y - f x) / (y - x) := by
      use sSup (Set.image (fun y => (f x - f y) / (x - y)) (Set.Iio x));
      exact fun y hy => ⟨ le_csSup ⟨ ( f ( x + 1 ) - f x ) / ( x + 1 - x ), Set.forall_mem_image.2 fun z hz => h_subgradient _ _ hz ( by linarith ) ⟩ ⟨ y, hy, rfl ⟩, fun z hz => csSup_le ( Set.Nonempty.image _ <| Set.nonempty_Iio ) <| Set.forall_mem_image.2 fun w hw => h_subgradient _ _ hw hz ⟩;
    use p;
    intro y; cases lt_trichotomy y x <;> norm_num at *;
    · have := hp y ‹_›; rw [ div_le_iff₀ ] at this <;> linarith;
    · cases ‹y = x ∨ x < y› <;> simp_all +decide [ div_le_iff₀ ];
      have := hp ( x - 1 ) ( by linarith ) |>.2 y ‹_›; rw [ le_div_iff₀ ] at this <;> linarith;
  obtain ⟨ p, hp ⟩ := h_subgradient;
  have h_legendre : legendreFenchel f p = p * x - f x := by
    refine' le_antisymm _ _;
    · exact ciSup_le fun y => by linarith [ hp y ] ;
    · exact le_ciSup ( hbdd_conj p ) x |> le_trans ( by norm_num );
  refine' h_contra ( le_antisymm _ _ );
  · refine' ciSup_le fun q => _;
    linarith [ hp x, hp ( x + 1 ), hp ( x - 1 ), show legendreFenchel f q ≥ q * x - f x from le_ciSup ( hbdd_conj q ) x ];
  · refine' le_trans _ ( le_ciSup _ p );
    · linarith;
    · exact hbdd_biconj x

/-! ## Section 10: Connections to Buildings and Bruhat-Tits Theory

The Bruhat-Tits building of GL_n over a local field is a simplicial complex
whose apartments are copies of ℝ^(n-1). Tropicalization naturally maps to
the building, providing the geometric backbone of tropical Langlands.
-/

/-- A tropical apartment is an affine hyperplane arrangement in ℝ^n -/

def TropicalApartment (n : ℕ) := Fin n → ℝ

/-- The Weyl group action on a tropical apartment (permutation of coordinates) -/

def weylAction (n : ℕ) (sigma : Equiv.Perm (Fin n)) (x : TropicalApartment n) :
    TropicalApartment n :=
  fun i => x (sigma i)

/-
The Weyl group action composes contravariantly with permutation multiplication
-/

theorem weylAction_mul (n : ℕ) (sigma tau : Equiv.Perm (Fin n))
    (x : TropicalApartment n) :
    weylAction n (sigma * tau) x = weylAction n tau (weylAction n sigma x) := by
  exact funext fun i => by simp +decide [ weylAction ] ;

/-
The retraction to an apartment preserves tropical distances
-/

theorem apartment_retraction_isometry (n : ℕ)
    (d : TropicalApartment n → TropicalApartment n → ℝ)
    (hd : ∀ x y : TropicalApartment n, d x y = ∑ i : Fin n, |x i - y i|)
    (sigma : Equiv.Perm (Fin n))
    (x y : TropicalApartment n) :
    d (weylAction n sigma x) (weylAction n sigma y) = d x y := by
  simp +decide only [hd, weylAction];
  conv_rhs => rw [ ← Equiv.sum_comp sigma ] ;


end
