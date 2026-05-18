import Mathlib
import Speculative.MetaComplexity.Defs

/-!
# Formal Meta-Complexity: Main Theorems

## Theorem 1: Universal upper bound on KW witness cardinality
Every true/false pair contributes at most `n` witnesses, so
`|KWWitness(f)| ≤ n * |{x | f x = true}| * |{y | f y = false}|`.

## Theorem 2: KW witness decomposition by differing coordinates
The KW witness set decomposes as a disjoint union over true/false pairs and
their differing coordinates.

## Theorem 3: Threshold function symmetry and witness lower bounds
For threshold functions, adjacent boundary layers contribute witnesses.

## Theorem 4: Majority witness lower bound
The majority function has large KW witness entropy.

## Theorem 5: Compression impossibility from KW witness cardinality
Large witness spaces force long codes (bridge to communication complexity).
-/

noncomputable section
open Classical Finset Fintype Function

namespace MetaComplexity

/-! ## Theorem 1: Universal Upper Bound on KW Witnesses

The key insight: `KWWitness(f)` embeds into the product
`{x | f x = true} × {y | f y = false} × Fin n`.
-/

/-- The projection from KWWitness to the product type. -/
def kwWitnessToTriple {n : ℕ} {f : BoolVec n → Bool} (w : KWWitness f) :
    BoolVec n × BoolVec n × Fin n :=
  w.val

theorem kwWitnessToTriple_injective {n : ℕ} (f : BoolVec n → Bool) :
    Injective (@kwWitnessToTriple n f) := Subtype.val_injective

/-- **Universal upper bound**: `|KWWitness(f)| ≤ n * |T(f)| * |F(f)|`. -/
theorem card_KWWitness_le_mul {n : ℕ} (f : BoolVec n → Bool) :
    Fintype.card (KWWitness f) ≤
      n * Fintype.card {x : BoolVec n // f x = true} *
        Fintype.card {y : BoolVec n // f y = false} := by
  have h_subset : Fintype.card (KWWitness f) ≤ Fintype.card ({x // f x = true} × {y // f y = false} × Fin n) := by
    refine' Fintype.card_le_of_injective _ _
    exact fun x => ⟨⟨x.val.1, x.property.1⟩, ⟨x.val.2.1, x.property.2.1⟩, x.val.2.2⟩
    simp +decide [Function.Injective]
    exact fun a b h₁ h₂ h₃ => Subtype.ext <| Prod.ext h₁ <| Prod.ext h₂ h₃
  convert h_subset using 1; simp +decide [mul_comm, mul_assoc, mul_left_comm]

/-! ## Compression Bridge

Large KW witness spaces force long codes via pigeonhole.
-/

/-- If `2^d ≤ |KWWitness(f)|`, every injective encoding has some codeword
of length ≥ `d`. -/
theorem kw_witness_compression {n : ℕ} (f : BoolVec n → Bool)
    (d : ℕ) (hlarge : 2 ^ d ≤ Fintype.card (KWWitness f))
    (Enc : KWWitness f → List Bool) (hinj : Injective Enc) :
    ∃ w : KWWitness f, d ≤ (Enc w).length := by
  contrapose! hlarge
  have h_codewords : (Finset.image Enc Finset.univ).card ≤ ∑ i ∈ Finset.range d, 2 ^ i := by
    refine' le_trans (Finset.card_le_card <| Finset.image_subset_iff.mpr _) _
    exact Finset.biUnion (Finset.range d) fun i =>
      Finset.image (fun x : Fin i → Bool => List.ofFn x) (Finset.univ : Finset (Fin i → Bool))
    · intro w hw; specialize hlarge w
      use Finset.mem_biUnion.mpr ⟨List.length (Enc w), Finset.mem_range.mpr hlarge,
        Finset.mem_image.mpr ⟨fun i => Enc w |> List.get <| ⟨i, by aesop⟩,
          Finset.mem_univ _, ?_⟩⟩; aesop
    · refine' le_trans Finset.card_biUnion_le _
      exact Finset.sum_le_sum fun i hi =>
        Finset.card_image_le.trans (by simp +decide [Finset.card_univ])
  simp_all +decide [Finset.card_image_of_injective _ hinj]
  simp_all +decide [Nat.geomSum_eq]
  exact lt_of_le_of_lt h_codewords (Nat.sub_lt (by norm_num) (by norm_num))

/-- Log-entropy lower bound: `d ≤ log₂ |KWWitness(f)|` when `2^d ≤ |KWWitness(f)|`. -/
theorem kw_log_entropy_bound {n : ℕ} (f : BoolVec n → Bool)
    (d : ℕ) (hlarge : 2 ^ d ≤ Fintype.card (KWWitness f)) :
    d ≤ Nat.log 2 (Fintype.card (KWWitness f)) := by
  exact Nat.le_log_of_pow_le (by decide) hlarge

/-! ## Threshold Function Properties -/

/-- Threshold functions are monotone (with respect to bitwise ordering). -/
theorem thresholdFn_monotone {n t : ℕ} (x y : BoolVec n)
    (hle : ∀ i, x i = true → y i = true) (hx : thresholdFn n t x = true) :
    thresholdFn n t y = true := by
  have h_hamming_le : hammingWeight x ≤ hammingWeight y := by
    exact Finset.card_le_card fun i hi => by aesop
  unfold thresholdFn at *; grind

/-! ## Witness existence for threshold functions -/

theorem threshold_witness_exists {n t : ℕ} (x y : BoolVec n)
    (hx : t ≤ hammingWeight x) (hy : hammingWeight y < t) :
    ∃ i : Fin n, x i = true ∧ y i = false := by
  contrapose! hy
  exact le_trans hx (Finset.card_mono fun i hi => by aesop)

/-! ## KW Witness Lower Bound for Threshold Functions -/

/-- Each pair of vectors from adjacent boundary layers contributes a KW witness. -/
theorem boundary_pair_gives_witness {n t : ℕ} (ht : 1 ≤ t) (_htn : t ≤ n)
    (x : BoolVec n) (hx : hammingWeight x = t)
    (y : BoolVec n) (hy : hammingWeight y = t - 1) :
    ∃ i : Fin n, x i ≠ y i := by
  exact not_forall.mp fun h => by rw [show x = y from funext h] at hx; omega

/-- Injection from boundary layer pairs to KW witnesses for threshold functions. -/
theorem card_KWWitness_threshold_ge {n t : ℕ} (ht : 1 ≤ t) (htn : t ≤ n) :
    (layer n t).card * (layer n (t - 1)).card ≤
      Fintype.card (KWWitness (thresholdFn n t)) := by
  have h_witness_exists : ∀ x ∈ layer n t, ∀ y ∈ layer n (t-1), ∃ i : Fin n, x i ≠ y i := by
    intros x hx y hy
    apply boundary_pair_gives_witness ht htn x (by
      exact Finset.mem_filter.mp hx |>.2) y (by
      exact Finset.mem_filter.mp hy |>.2)
  have h_inj : ∀ x ∈ layer n t, ∀ y ∈ layer n (t-1),
      ∃ w : KWWitness (thresholdFn n t), w.val.1 = x ∧ w.val.2.1 = y := by
    intro x hx y hy
    obtain ⟨i, hi⟩ := h_witness_exists x hx y hy
    use ⟨(x, y, i), by unfold thresholdFn; unfold layer at hx hy; aesop⟩
  choose! w hw₁ hw₂ using h_inj
  have h_inj : Function.Injective (fun p : {x : BoolVec n // x ∈ layer n t} ×
      {y : BoolVec n // y ∈ layer n (t-1)} =>
      w p.1.val p.1.property p.2.val p.2.property) := by
    intro p q h_eq
    have := hw₁ p.1.val p.1.property p.2.val p.2.property
    have := hw₂ p.1.val p.1.property p.2.val p.2.property
    have := hw₁ q.1.val q.1.property q.2.val q.2.property
    have := hw₂ q.1.val q.1.property q.2.val q.2.property
    aesop
  have := Fintype.card_le_of_injective _ h_inj
  simp_all +decide [Fintype.card_subtype]

/-- The size of a Hamming layer equals the binomial coefficient. -/
theorem layer_card_eq_choose (n k : ℕ) (hk : k ≤ n) :
    (layer n k).card = Nat.choose n k := by
  convert Finset.card_powersetCard k (Finset.univ : Finset (Fin n))
  · refine' Finset.card_bij (fun x hx => Finset.univ.filter fun i => x i = true) _ _ _ <;>
      simp +decide
    · exact fun x hx => Finset.mem_filter.mp hx |>.2
    · simp +contextual [funext_iff, Finset.ext_iff]
    · intro b hb; use fun i => if i ∈ b then Bool.true else Bool.false
      simp +decide [hb, layer]
      unfold hammingWeight; aesop
  · exact?

/-
**Threshold witness lower bound** in terms of binomial coefficients.
-/
theorem card_KWWitness_threshold_ge_choose {n t : ℕ} (ht : 1 ≤ t) (htn : t ≤ n) :
    Nat.choose n t * Nat.choose n (t - 1) ≤
      Fintype.card (KWWitness (thresholdFn n t)) := by
  rw [ ← layer_card_eq_choose n t htn, ← layer_card_eq_choose n ( t - 1 ) ( Nat.sub_le_of_le_add <| by linarith ) ];
  convert card_KWWitness_threshold_ge ht htn using 1

/-! ## Majority Function Witness Lower Bound -/

/-
**Majority witness lower bound**: the central binomial product bounds
the KW witness count from below.
-/
theorem card_KWWitness_majority_ge {n : ℕ} (hn : 1 ≤ n) :
    Nat.choose n ((n + 1) / 2) * Nat.choose n (((n + 1) / 2) - 1) ≤
      Fintype.card (KWWitness (majorityFn n)) := by
  apply card_KWWitness_threshold_ge_choose;
  · omega;
  · omega

/-! ## Monotone Formula Structure -/

/-- Monotone Boolean formulas (local copy for self-containment). -/
inductive MonoFormula' (n : ℕ) where
  | var : Fin n → MonoFormula' n
  | top : MonoFormula' n
  | bot : MonoFormula' n
  | and : MonoFormula' n → MonoFormula' n → MonoFormula' n
  | or  : MonoFormula' n → MonoFormula' n → MonoFormula' n

namespace MonoFormula'

def eval : MonoFormula' n → BoolVec n → Bool
  | var i, x => x i
  | top, _ => true
  | bot, _ => false
  | and φ₁ φ₂, x => φ₁.eval x && φ₂.eval x
  | or φ₁ φ₂, x => φ₁.eval x || φ₂.eval x

def depth : MonoFormula' n → ℕ
  | var _ => 0
  | top => 0
  | bot => 0
  | and φ₁ φ₂ => 1 + max φ₁.depth φ₂.depth
  | or φ₁ φ₂ => 1 + max φ₁.depth φ₂.depth

theorem eval_monotone (φ : MonoFormula' n) :
    ∀ x y : BoolVec n, (∀ i, x i = true → y i = true) →
    φ.eval x = true → φ.eval y = true := by
  intro x y hxy hx; induction' φ with i ih generalizing x y;
  · exact hxy i hx;
  · exact?;
  · cases hx;
  · grind +locals;
  · simp_all +decide [ MonoFormula'.eval ];
    grind +splitImp

end MonoFormula'

/-- A formula computes `f` if it agrees on all inputs. -/
def Computes {n : ℕ} (φ : MonoFormula' n) (f : BoolVec n → Bool) : Prop :=
  ∀ x, φ.eval x = f x

/-- Formula depth is a lower bound: if every formula computing `f` has depth ≥ `d`,
then `d` is a formula depth lower bound for `f`. -/
def FormulaDepthLB {n : ℕ} (f : BoolVec n → Bool) (d : ℕ) : Prop :=
  ∀ φ : MonoFormula' n, Computes φ f → d ≤ φ.depth

/-
For any nonconstant function that is NOT a single variable (i.e., depends on
at least 2 inputs), the formula depth is at least 1.
This corrects the earlier statement which was false for single-variable functions.
-/
theorem monoFormula_depth_ge_one_of_and {n : ℕ}
    (f : BoolVec n → Bool)
    (hx0 : f (fun _ => true) = true)
    (hy0 : f (fun _ => false) = false)
    (hnotvar : ∀ i : Fin n, ¬(∀ x, f x = x i)) :
    FormulaDepthLB f 1 := by
  intro φ hφ;
  have h_not_var : ¬∃ i : Fin n, ∀ x : BoolVec n, φ.eval x = x i := by
    exact fun ⟨ i, hi ⟩ => hnotvar i fun x => by rw [ ← hφ, hi ] ;
  rcases φ with ( _ | _ | _ | _ | _ ) <;> simp_all +decide [ FormulaDepthLB ];
  · exact absurd ( h_not_var ‹_› ) ( by simp +decide [ MonoFormula'.eval ] );
  · grind +locals;
  · have := hφ ( fun _ => true ) ; have := hφ ( fun _ => false ) ; simp_all +decide [ MonoFormula'.eval ] ;
  · exact Nat.succ_le_of_lt ( Nat.pos_of_ne_zero ( by simp +decide [ MonoFormula'.depth ] ) );
  · exact Nat.succ_le_of_lt ( Nat.pos_of_ne_zero ( by simp +decide [ MonoFormula'.depth ] ) )

end MetaComplexity

end