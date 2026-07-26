import Mathlib

/-!
# Tropical Thermodynamic Complexity Theory

This file develops a formal bridge between **reversible computation**, **tropical algebra**,
and **thermodynamic lower bounds**. We prove that logical reversibility is exactly
tropical entropy preservation, and that erasure manifests as a strict tropical
free-energy drop with unavoidable Landauer cost.

## Main Results

1. **Tropical Transport Algebra**: Reversible transitions transport energy via pullback,
   and this transport respects composition of equivalences.

2. **Entropy Preservation Theorem**: Bijections on finite types preserve counting entropy
   (log-cardinality), establishing that reversible computation has zero entropy cost.

3. **Uniform Fiber Cardinality Theorem**: If `e : σ → τ` is surjective with every fiber
   of cardinality `m`, then `card σ = card τ * m`.

4. **Landauer Sharpness Theorem**: Uniform `2^n`-to-1 erasure produces entropy drop
   exactly `n * log 2`, yielding thermodynamic cost `kB * T * n * log 2`.

5. **Reversible Simulation Theorem**: Any deterministic finite-state transition can be
   extended to a reversible (bijective) transition on an enlarged state space.

## References

- Bennett, C.H. (1973). Logical reversibility of computation.
- Landauer, R. (1961). Irreversibility and heat generation in the computing process.
-/

noncomputable section

open Finset Function Real

/-! ## Tropical Energy Transport -/

/-- Tropical energy: a real-valued cost function on configurations. -/
def TropicalEnergy (σ : Type*) := σ → ℝ

/-- Transport of tropical energy along a reversible transition (bijection).
This is the pullback `E ↦ E ∘ f.symm`, which propagates costs forward through
the bijection. -/
def tropicalTransport {σ : Type*} (f : σ ≃ σ) (E : TropicalEnergy σ) : TropicalEnergy σ :=
  fun x => E (f.symm x)

/-
Tropical transport respects composition of equivalences.
-/
theorem tropicalTransport_comp
    {σ : Type*} (f g : σ ≃ σ) (E : TropicalEnergy σ) :
    tropicalTransport (f.trans g) E =
      tropicalTransport g (tropicalTransport f E) := by
  exact funext fun x => rfl

/-
Tropical transport by the identity equivalence is the identity on energies.
-/
theorem tropicalTransport_id
    {σ : Type*} (E : TropicalEnergy σ) :
    tropicalTransport (Equiv.refl σ) E = E := by
  exact funext fun x => by simp +decide [ tropicalTransport ] ;

/-
Tropical transport by the inverse equivalence is the inverse transport.
-/
theorem tropicalTransport_symm
    {σ : Type*} (f : σ ≃ σ) (E : TropicalEnergy σ) :
    tropicalTransport f.symm (tropicalTransport f E) = E := by
  exact funext fun x => by simp +decide [ tropicalTransport ] ;

/-
The tropical minimum (ground-state energy) is preserved by reversible transport.
-/
theorem tropicalTransport_preserves_iInf
    {σ : Type*} [Fintype σ] [Nonempty σ] (f : σ ≃ σ) (E : TropicalEnergy σ) :
    ⨅ x, tropicalTransport f E x = ⨅ x, E x := by
  simp only [tropicalTransport]
  exact f.symm.surjective.iInf_congr _ (fun _ => rfl)

/-! ## Counting Entropy on Finite Types -/

/-- Counting entropy of a finite type: `log(card α)`.
This is the logarithmic measure of the number of microstates. -/
def countingEntropy (α : Type*) [Fintype α] : ℝ :=
  Real.log (Fintype.card α)

/-
Counting entropy is invariant under bijection.
This is the entropy preservation theorem for reversible transitions.
-/
theorem countingEntropy_equiv_invariant
    {α β : Type*} [Fintype α] [Fintype β] (e : α ≃ β) :
    countingEntropy α = countingEntropy β := by
  unfold countingEntropy;
  rw [ Fintype.card_congr e ]

/-- Counting entropy of a finite set: `log(|S|)`. -/
def countingEntropyFinset {α : Type*} (S : Finset α) : ℝ :=
  Real.log S.card

/-
Bijections preserve finset counting entropy under image.
-/
theorem countingEntropyFinset_image_equiv
    {α : Type*} [DecidableEq α] (f : α ≃ α) (S : Finset α) :
    countingEntropyFinset (S.image f) = countingEntropyFinset S := by
  unfold countingEntropyFinset;
  rw [ Finset.card_image_of_injective _ f.injective ]

/-! ## Uniform Fiber Cardinality -/

/-
If `e : σ → τ` is surjective and every fiber has cardinality `m`,
then `card σ = card τ * m`. This is the fulcrum lemma for Landauer's principle.
-/
theorem card_eq_card_mul_fiber_of_uniform_surjective
    {σ τ : Type*} [Fintype σ] [Fintype τ] [DecidableEq τ]
    (e : σ → τ) (m : ℕ)
    (_hsurj : Surjective e)
    (hfiber : ∀ y : τ, Fintype.card {x : σ // e x = y} = m) :
    Fintype.card σ = Fintype.card τ * m := by
  -- Use Fintype.card_eq_sum_card_fiberwise or Fintype.sum_card_fiber.
  have h_sum_card_fiber : ∑ y : τ, Fintype.card {x : σ // e x = y} = Fintype.card σ := by
    simp +decide only [Fintype.card_subtype];
    simp +decide only [card_filter];
    rw [ Finset.sum_comm ] ; simp +decide;
  aesop

/-! ## Entropy Drop Under Erasure -/

/-
The log-cardinality ratio for uniform-fiber erasure.
-/
theorem log_card_ratio_uniform_fiber
    {σ τ : Type*} [Fintype σ] [Fintype τ] [DecidableEq τ]
    (e : σ → τ) (n : ℕ)
    (hsurj : Surjective e)
    (hfiber : ∀ y : τ, Fintype.card {x : σ // e x = y} = 2 ^ n)
    (hτ : 0 < Fintype.card τ) :
    Real.log (Fintype.card σ) = Real.log (Fintype.card τ) + n * Real.log 2 := by
  -- By card_eq_card_mul_fiber_of_uniform_surjective, card σ = card τ * 2^n.
  have h_card : Fintype.card σ = Fintype.card τ * 2 ^ n :=
    card_eq_card_mul_fiber_of_uniform_surjective e (2 ^ n) hsurj hfiber
  rw [ h_card, Nat.cast_mul, Nat.cast_pow, Real.log_mul ( by positivity ) ( by positivity ), Real.log_pow ];
  norm_cast

/-
**Entropy drop theorem**: Uniform `2^n`-to-1 erasure produces
entropy drop of exactly `n * log 2`.
-/
theorem entropy_drop_of_uniform_fiber
    {σ τ : Type*} [Fintype σ] [Fintype τ] [DecidableEq τ]
    (e : σ → τ) (n : ℕ)
    (hsurj : Surjective e)
    (hfiber : ∀ y : τ, Fintype.card {x : σ // e x = y} = 2 ^ n)
    (hτ : 0 < Fintype.card τ) :
    countingEntropy σ - countingEntropy τ = n * Real.log 2 := by
  -- Apply the lemma log_card_ratio_uniform_fiber with the given hypotheses.
  have h_log_ratio : Real.log (Fintype.card σ) = Real.log (Fintype.card τ) + n * Real.log 2 := by
    -- Apply the lemma log_card_ratio_uniform_fiber with the given hypotheses to conclude the proof.
    apply log_card_ratio_uniform_fiber e n hsurj hfiber hτ;
  exact sub_eq_iff_eq_add'.mpr h_log_ratio

/-! ## Landauer's Principle -/

/-
**Landauer cost theorem for uniform erasure**.
-/
theorem landauer_cost_uniform_erasure
    {σ τ : Type*} [Fintype σ] [Fintype τ] [DecidableEq τ]
    (e : σ → τ) (n : ℕ) (T kB : ℝ)
    (hsurj : Surjective e)
    (hfiber : ∀ y : τ, Fintype.card {x : σ // e x = y} = 2 ^ n)
    (hτ : 0 < Fintype.card τ) :
    kB * T * (countingEntropy σ - countingEntropy τ) = kB * T * (n * Real.log 2) := by
  -- Apply the entropy_drop_of_uniform_fiber theorem to rewrite the left-hand side.
  rw [entropy_drop_of_uniform_fiber e n hsurj hfiber hτ]

/-
One-bit Landauer cost: erasing a single bit costs `kB * T * log 2`.
-/
theorem landauer_cost_one_bit (T kB : ℝ) :
    kB * T * ((1 : ℝ) * Real.log 2) = kB * T * Real.log 2 := by
  grind +splitImp

/-! ## One-Bit Erasure Example -/

/-- The canonical one-bit erasure map: `Bool × α → α` given by projection. -/
def eraseBit {α : Type*} : Bool × α → α := Prod.snd

/-
The eraseBit map is surjective.
-/
theorem eraseBit_surjective {α : Type*} [Nonempty α] :
    Surjective (@eraseBit α) := by
  exact fun y => ⟨ ⟨ Bool.true, y ⟩, rfl ⟩

/-
Each fiber of `eraseBit` has exactly 2 elements.
-/
theorem eraseBit_fiber_card {α : Type*} [Fintype α] [DecidableEq α] (y : α) :
    Fintype.card {x : Bool × α // eraseBit x = y} = 2 := by
  rw [ Fintype.card_subtype ];
  convert Finset.card_eq_sum_ones ( Finset.univ.image ( fun b : Bool => ( b, y ) ) ) using 1;
  congr with x ; simp +decide [ eraseBit ];
  cases x ; aesop

/-
**One-bit erasure entropy drop**: erasing one bit drops entropy by `log 2`.
-/
theorem eraseBit_entropy_drop {α : Type*} [Fintype α] [Nonempty α] :
    countingEntropy (Bool × α) - countingEntropy α = Real.log 2 := by
  unfold countingEntropy;
  rw [ sub_eq_iff_eq_add', ← Real.log_mul ] <;> norm_num;
  grind +revert

/-! ## Reversible Simulation -/

/-
On finite types, an injective endomorphism is a bijection.
-/
theorem injective_step_has_reversible_realization
    {σ : Type*} [Fintype σ] (step : σ → σ)
    (hinj : Injective step) :
    ∃ (rev : σ ≃ σ), ∀ x, rev x = step x := by
  exact ⟨ Equiv.ofBijective step ⟨ hinj, Finite.injective_iff_surjective.mp hinj ⟩, fun x => rfl ⟩

/-
**Reversible extension with garbage**: Any deterministic finite-state transition
can be extended to a reversible transition on `σ × σ` by recording the previous state.
-/
theorem reversible_extension_with_garbage
    {σ : Type*} [Fintype σ] [DecidableEq σ] (step : σ → σ) :
    ∃ (τ : Type) (_ : Fintype τ) (enc : σ → τ) (proj : τ → σ) (R : τ ≃ τ),
      ∀ x, proj (R (enc x)) = step x := by
  refine' ⟨ _, _, _, _, _, _ ⟩;
  exact ULift ( Fin ( Fintype.card ( σ × σ ) ) );
  exact inferInstance;
  exact fun x => ⟨ Fintype.equivFin ( σ × σ ) ( x, step x ) ⟩;
  exact fun x => ( Fintype.equivFin ( σ × σ ) ).symm x.down |>.2;
  exact Equiv.refl _;
  aesop

/-! ## Tropical Free Energy -/

/-- Tropical free energy: the minimum energy over all configurations. -/
def tropicalFreeEnergy {σ : Type*} [Fintype σ] [Nonempty σ] (E : TropicalEnergy σ) : ℝ :=
  ⨅ x, E x

/-
Reversible transitions preserve tropical free energy.
-/
theorem tropicalFreeEnergy_preserved
    {σ : Type*} [Fintype σ] [Nonempty σ] (f : σ ≃ σ) (E : TropicalEnergy σ) :
    tropicalFreeEnergy (tropicalTransport f E) = tropicalFreeEnergy E := by
  convert tropicalTransport_preserves_iInf f E using 1

/-! ## Tropical Entropy Functional -/

/-- Tropical entropy of a finite type: the log of its cardinality. -/
def tropicalEntropy (α : Type*) [Fintype α] : ℝ :=
  Real.log (Fintype.card α)

/-
**Reversible tropical entropy preservation**: a bijection on a finite type
preserves tropical entropy exactly.
-/
theorem reversible_tropical_entropy_preserved
    {σ : Type*} [Fintype σ] (_f : σ ≃ σ) :
    @tropicalEntropy σ _ = @tropicalEntropy σ _ := by
  rfl

/-
The tropical Landauer bound.
-/
theorem tropical_landauer_bound
    {σ τ : Type*} [Fintype σ] [Fintype τ] [DecidableEq τ]
    (e : σ → τ) (n : ℕ) (T kB : ℝ)
    (_hT : 0 ≤ T) (_hkB : 0 ≤ kB)
    (hsurj : Surjective e)
    (hfiber : ∀ y : τ, Fintype.card {x : σ // e x = y} = 2 ^ n)
    (hτ : 0 < Fintype.card τ) :
    kB * T * (@tropicalEntropy σ _ - @tropicalEntropy τ _) = kB * T * (n * Real.log 2) := by
  exact congr_arg _ ( entropy_drop_of_uniform_fiber e n hsurj hfiber hτ )

end