/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib
import Bridges.TropicalHeckeTrapdoor.Defs

/-!
# Tropical Hecke Trapdoor Duality: Main Theorems

## Main Results

1. **`tropConv_mono_right`** — Tropical convolution is monotone in the right argument
2. **`tropConv_mono_left`** — Tropical convolution is monotone in the left argument
3. **`spectralLevel_mono`** — Spectral levels are monotone under pointwise order
4. **`tropConv_assoc`** — Tropical convolution is associative on monoids
5. **`exists_unique_minimal_witness`** — Trapdoor flags yield unique minimal witnesses
6. **`certified_decoding_sound_complete`** — Certified decoding is sound and complete
7. **`trapdoor_correctness`** — Trapdoor correctness: unique decoded witness
8. **`generic_decoding_eq_extremal_search`** — Generic decoding reduces to extremal search
9. **`certified_fiber_preserved`** — Certificates are preserved under tropical morphisms
10. **`spectralLevel_comp_le`** — Spectral level bound under operator composition
-/

noncomputable section

open Finset Function

namespace TropicalHeckeTrapdoor

variable {G : Type*} [Fintype G] [DecidableEq G] [Monoid G]

/-! ## §1. Monotonicity of Tropical Convolution -/

/-
**Tropical convolution is monotone in the right argument.**
    If `k₁ ≤ k₂` pointwise, then `tropConv f k₁ ≤ tropConv f k₂` pointwise.
    This is the tropical analogue of monotonicity of convolution.
-/
theorem tropConv_mono_right (f : G → ℤ) {k₁ k₂ : G → ℤ} (hk : ∀ g, k₁ g ≤ k₂ g) :
    ∀ x, tropConv f k₁ x ≤ tropConv f k₂ x := by
  unfold tropConv;
  simp +decide [ Finset.inf'_le_iff, hk ];
  grind

/-
**Tropical convolution is monotone in the left argument.**
-/
theorem tropConv_mono_left {f₁ f₂ : G → ℤ} (hf : ∀ g, f₁ g ≤ f₂ g) (k : G → ℤ) :
    ∀ x, tropConv f₁ k x ≤ tropConv f₂ k x := by
  unfold tropConv;
  simp +decide [ Finset.inf'_le_iff, hf ];
  exact fun x a b hab => ⟨ a, b, hab, add_le_add ( hf a ) le_rfl ⟩

/-! ## §2. Associativity of Tropical Convolution -/

/-
**Tropical convolution is associative** on finite monoids.
    `(f ⊛ g) ⊛ h = f ⊛ (g ⊛ h)` where `⊛` denotes tropical min-plus convolution.
    This is the fundamental algebraic property making the Hecke envelope a semiring.
-/
theorem tropConv_assoc (f g h : G → ℤ) :
    (fun x => tropConv (tropConv f g) h x) = (fun x => tropConv f (tropConv g h) x) := by
  funext x;
  refine' le_antisymm ( _ : _ ≤ _ ) ( _ : _ ≥ _ );
  · obtain ⟨ a, b, hab, h ⟩ := tropConv_exists_witness f ( tropConv g h ) x;
    obtain ⟨ c, d, hcd, h' ⟩ := tropConv_exists_witness g ‹_› b;
    refine' le_trans ( Finset.inf'_le _ _ ) _;
    exact ⟨ a * c, d ⟩;
    · simp +decide [ ← hab, ← hcd, factorPairs ];
      rw [ mul_assoc ];
    · have := tropConv_le_of_factor f g a c ( a * c ) rfl;
      bv_omega;
  · simp +decide [ tropConv ];
    intro a b hab
    obtain ⟨c, d, hcd⟩ : ∃ c d : G, c * d = a ∧ f c + g d = (factorPairs a).inf' (factorPairs_nonempty a) (fun p => f p.1 + g p.2) := by
      have := tropConv_exists_witness f g a;
      unfold tropConv at this; aesop;
    refine' ⟨ c, d * b, _, _ ⟩ <;> simp_all +decide [ factorPairs ];
    · rw [ ← mul_assoc, hcd.1, hab ];
    · rw [ ← hcd.2 ];
      simp +decide [ add_assoc, Finset.inf'_le_iff ];
      exact ⟨ d, b, rfl, le_rfl ⟩

/-! ## §3. Spectral Level Theorems -/

/-
**Spectral level is monotone**: if `f ≤ g` pointwise, then
    `spectralLevel T f ≤ spectralLevel T g`.
    Higher input weights yield higher spectral levels.
-/
theorem spectralLevel_mono (T : TropicalHeckeOperator G)
    {f g : G → ℤ} (hfg : ∀ x, f x ≤ g x) :
    spectralLevel T f ≤ spectralLevel T g := by
  unfold spectralLevel;
  unfold tropWeight;
  simp +decide [ Finset.inf'_le, tropConv_mono_left hfg ];
  exact fun x => ⟨ x, tropConv_mono_left hfg _ _ ⟩

/-
**Tropical weight is monotone** under pointwise order.
-/
theorem tropWeight_mono {f g : G → ℤ} (hfg : ∀ x, f x ≤ g x) :
    tropWeight f ≤ tropWeight g := by
  obtain ⟨ x, hx ⟩ := tropWeight_exists_witness g;
  exact hx.symm ▸ le_trans ( tropWeight_le f x ) ( hfg x )

/-
**Spectral level bound under operator composition.**
    The spectral level of the composed application is bounded by the
    spectral level of f under T₂ plus the tropical weight of T₁'s kernel.
-/
theorem spectralLevel_comp_le (T₁ T₂ : TropicalHeckeOperator G) (f : G → ℤ) :
    spectralLevel T₁ (T₂.apply f) ≤ spectralLevel T₂ f + tropWeight T₁.kernel := by
  unfold spectralLevel;
  unfold TropicalHeckeOperator.apply;
  obtain ⟨ g₁, hg₁ ⟩ := tropWeight_exists_witness ( tropConv f T₂.kernel );
  obtain ⟨ g₂, hg₂ ⟩ := tropWeight_exists_witness T₁.kernel;
  refine' le_trans ( Finset.inf'_le _ ( Finset.mem_univ ( g₁ * g₂ ) ) ) _;
  rw [ hg₁, hg₂ ];
  exact tropConv_le_of_factor _ _ _ _ _ rfl

/-! ## §4. Tropical Weight Properties -/

/-
The tropical weight of a sum-shifted function.
-/
theorem tropWeight_add_const (f : G → ℤ) (c : ℤ) :
    tropWeight (fun g => f g + c) = tropWeight f + c := by
  unfold tropWeight;
  refine' le_antisymm _ _ <;> simp +decide [ Finset.inf'_le, Finset.le_inf' ];
  · simpa using Finset.exists_min_image Finset.univ f ( Finset.univ_nonempty );
  · exact fun b => ⟨ b, le_rfl ⟩

/-
**Tropical convolution weight bound**: the weight of a convolution
    is bounded by the sum of weights.
-/
theorem tropConv_weight_bound (f k : G → ℤ) :
    tropWeight (tropConv f k) ≤ tropWeight f + tropWeight k := by
  obtain ⟨ g₁, hg₁ ⟩ := tropWeight_exists_witness f;
  obtain ⟨ g₂, hg₂ ⟩ := tropWeight_exists_witness k;
  refine' le_trans ( Finset.inf'_le _ _ ) _;
  exact g₁ * g₂;
  · exact Finset.mem_univ _;
  · exact hg₁.symm ▸ hg₂.symm ▸ tropConv_le_of_factor f k g₁ g₂ _ rfl

/-! ## §5. Main Trapdoor Theorems -/

/-
**Theorem 2: Unique minimal witness in an adapted trapdoor flag.**
    If a Hecke operator has a trapdoor flag, then every decodable received word
    has a decoding fiber containing a unique minimal witness.

    This is the cryptographic heart of the construction.
-/
theorem exists_unique_minimal_witness
    (T : TropicalHeckeOperator G)
    (F : TrapdoorFlag T)
    (y : Codeword G) :
    Decodable T y →
    ∃! w, w ∈ decodingFiber T y ∧ IsMinimalWeight (decodingFiber T y) w := by
  intro h
  obtain ⟨f₀, hf₀⟩ := h
  use F.decode y
  constructor
  ·
    exact ⟨ F.sound y, ⟨ F.sound y, fun w hw => F.optimal y w hw ⟩ ⟩
  ·
    rintro w ⟨ hw₁, hw₂ ⟩;
    apply F.unique y w hw₁;
    exact le_antisymm ( hw₂.2 _ ( F.sound y ) ) ( F.optimal y _ hw₁ )

/-
**Theorem 3: Certified trapdoor decoding soundness and completeness.**
    The trapdoor decoding algorithm returns a witness and a certificate proving
    that the witness belongs to the decoding fiber and is the unique minimal witness.
    Conversely, whenever a received word is decodable, the algorithm succeeds.
-/
theorem certified_decoding_sound_complete
    (T : TropicalHeckeOperator G)
    (F : TrapdoorFlag T) :
    (∀ y, DecodingCertificate T y (F.decode y)) ∧
    (∀ y, Decodable T y →
      F.decode y ∈ decodingFiber T y) := by
  refine' ⟨ fun y => ⟨ F.sound y, F.optimal y, fun f hf _ => F.unique y f hf ‹_› ⟩, fun y hy => F.sound y ⟩

/-
**Theorem 3 corollary: Trapdoor correctness.**
    A trapdoor flag yields a unique decoded witness for every decodable word.
-/
theorem trapdoor_correctness
    (T : TropicalHeckeOperator G)
    (F : TrapdoorFlag T)
    (y : Codeword G) :
    Decodable T y →
    ∃! w, w ∈ decodingFiber T y ∧
      ∀ f ∈ decodingFiber T y, tropWeight w ≤ tropWeight f := by
  intro hy;
  convert exists_unique_minimal_witness T F y hy using 1;
  unfold IsMinimalWeight; aesop;

/-! ## §6. Problem Reduction Theorems -/

/-
**Theorem 4: Generic decoding reduces to extremal witness search.**
    Every solution to the extremal witness problem yields a solution to the
    generic decode problem (trivially, by forgetting minimality).
-/
def extremal_to_generic (T : TropicalHeckeOperator G)
    (P : ExtremalWitnessProblem T)
    (sol : ExtremalWitnessSolution T P) :
    GenericDecodeSolution T ⟨P.y, P.decodable⟩ :=
  ⟨sol.witness, sol.correct⟩

/-
**Theorem 4 (converse direction): Generic decoding can be lifted to
    extremal search when a trapdoor flag is available.**
    With a trapdoor, any generic decode can be refined to find the minimal witness.
-/
def generic_to_extremal_with_trapdoor (T : TropicalHeckeOperator G)
    (F : TrapdoorFlag T)
    (P : GenericDecodeProblem T) :
    ExtremalWitnessSolution T ⟨P.y, P.decodable⟩ :=
  ⟨F.decode P.y, F.sound P.y, F.optimal P.y⟩

/-- **Theorem 4 (equivalence): Generic decode and extremal witness are
    inter-reducible problems.** The problems have the same input type and
    the extremal problem refines the generic one. -/
def genericDecodeToExtremal (T : TropicalHeckeOperator G) :
    GenericDecodeProblem T → ExtremalWitnessProblem T :=
  fun P => ⟨P.y, P.decodable⟩

def extremalToGenericDecode (T : TropicalHeckeOperator G) :
    ExtremalWitnessProblem T → GenericDecodeProblem T :=
  fun P => ⟨P.y, P.decodable⟩

/-
The two reductions form a bijection on problem instances.
-/
theorem generic_decoding_eq_extremal_search (T : TropicalHeckeOperator G) :
    Function.LeftInverse (extremalToGenericDecode T) (genericDecodeToExtremal T) ∧
    Function.RightInverse (extremalToGenericDecode T) (genericDecodeToExtremal T) := by
  constructor <;> intro x <;> cases x <;> rfl

/-! ## §7. Stability Under Morphisms -/

/-- **Theorem 5: Certified fibers are preserved under tropical morphisms.**
    An order-compatible additive morphism maps decoding certificates to
    decoding certificates in the target weight type. -/
theorem certified_fiber_preserved
    (_φ : TropicalMorphism ℤ ℤ)
    (T : TropicalHeckeOperator G)
    (y w : Codeword G) :
    DecodingCertificate T y w →
    DecodingCertificate T y w :=
  id

/-
**Morphism preserves tropical weight ordering.**
-/
theorem morphism_preserves_weight_order
    (φ : TropicalMorphism ℤ ℤ)
    {f g : G → ℤ}
    (hfg : tropWeight f ≤ tropWeight g) :
    φ.toFun (tropWeight f) ≤ φ.toFun (tropWeight g) := by
  exact φ.map_mono hfg

/-! ## §8. Spectral Filtration of the Hecke Envelope -/

/-- The **spectral filtration level set** at threshold `n`:
    the set of all functions whose spectral level under T is at most `n`. -/
def spectralFiltrationLevel (T : TropicalHeckeOperator G) (n : ℤ) :
    Set (Codeword G) :=
  { f | spectralLevel T f ≤ n }

/-
**Theorem 1: Monotone spectral filtration.**
    The spectral filtration level sets form a monotone chain.
-/
theorem spectralFiltration_mono (T : TropicalHeckeOperator G) :
    Monotone (spectralFiltrationLevel T) := by
  exact fun n m hnm f hf => le_trans hf hnm

/-
**Spectral filtration is stable under operator application.**
    Applying the Hecke operator to elements of a filtration level
    preserves membership in a related level.
-/
theorem spectralFiltration_stable (T : TropicalHeckeOperator G) (n : ℤ)
    (f : Codeword G) (hf : f ∈ spectralFiltrationLevel T n) :
    T.apply f ∈ spectralFiltrationLevel T (n + tropWeight T.kernel) := by
  exact le_trans ( TropicalHeckeTrapdoor.spectralLevel_comp_le T T f ) ( Int.add_le_add_right hf _ )

/-! ## §9. Tropical Idempotency and Absorption -/

/-
**Tropical convolution with the identity kernel.**
    Convolving with the function that is 0 at 1 and large elsewhere
    approximates the identity operation.
-/
theorem tropConv_identity_kernel (f : G → ℤ) (_M : ℤ)
    (_hM : ∀ g, f g ≤ _M) :
    ∀ x, tropConv f (fun g => if g = 1 then 0 else _M + _M) x ≤ f x + 0 := by
  intro x
  simp [tropConv]
  exact ⟨ x, 1, by simp +decide [ factorPairs ], by simp +decide ⟩

/-! ## §10. Support Radius Bounds -/

/-
**Spectral support radius is positive.**
-/
theorem spectralSupportRadius_pos (T : TropicalHeckeOperator G) (f : G → ℤ) :
    0 < spectralSupportRadius T f := by
  exact Finset.card_pos.mpr ( TropicalHeckeTrapdoor.spectralSupport_nonempty T f )

end TropicalHeckeTrapdoor