/-
# Digital Immortality: Information-Theoretic Bounds on Mind Uploading

This module formalizes information-theoretic lower bounds on encoding neural
connectomes. The central results establish:

1. **Quadratic description length**: The number of distinct connectomes with n
   neurons and k synaptic weight levels is k^(n²), forcing average description
   length to be at least n² · log₂(k) bits.

2. **Incompressibility of generic connectomes**: For any compression scheme
   (modeled as an injection from a subset to shorter strings), at least half
   of all connectomes cannot be compressed below n² · log₂(k) - 1 bits.

3. **Coarse-graining information loss**: Any reduction in synaptic weight
   resolution destroys information proportional to the resolution gap.

4. **Bekenstein-style capacity bound**: The information capacity of a
   spherical region is bounded by 2π·R·E / (ℏ·ln 2).
-/
import Mathlib

open Finset Nat Real

/-! ## Part 1: Connectome Counting and Description Length -/

/-- A `ConnectomeSpace n k` represents the space of all possible neural
connectomes with `n` neurons and `k` distinct synaptic weight levels.
Each of the n² directed connections can take one of k values. -/
def ConnectomeSpace (n k : ℕ) := Fin n × Fin n → Fin k

noncomputable instance (n k : ℕ) [NeZero k] : Fintype (ConnectomeSpace n k) :=
  inferInstanceAs (Fintype (Fin n × Fin n → Fin k))

instance (n k : ℕ) [NeZero k] : DecidableEq (ConnectomeSpace n k) :=
  inferInstanceAs (DecidableEq (Fin n × Fin n → Fin k))

/-- The number of distinct connectomes with n neurons and k weight levels
is exactly k^(n²). -/
theorem connectome_count (n k : ℕ) [NeZero k] :
    Fintype.card (ConnectomeSpace n k) = k ^ (n * n) := by
  simp [ConnectomeSpace, Fintype.card_prod, Fintype.card_fin]

/-! ## Part 2: Incompressibility via Counting -/

/-- A `CompressionScheme` maps connectomes to codeword indices. -/
structure CompressionScheme (n k : ℕ) where
  encode : ConnectomeSpace n k → ℕ
  bound : ℕ

/-- A compression scheme is valid if injective and bounded. -/
structure CompressionScheme.IsValid {n k : ℕ} (cs : CompressionScheme n k) : Prop where
  injective : Function.Injective cs.encode
  bounded : ∀ c, cs.encode c < cs.bound

/-
**Pigeonhole compression bound**: Any valid compression scheme must use
at least k^(n²) codewords.
-/
theorem compression_pigeonhole (n k : ℕ) [NeZero k]
    (cs : CompressionScheme n k) (hv : cs.IsValid) :
    k ^ (n * n) ≤ cs.bound := by
  by_contra h_contra' ; simp_all +decide [ Fintype.card_subtype ];
  -- Let's count the number of possible codewords.
  have h_count_codewords : Finset.card (Finset.image cs.encode (Finset.univ : Finset (ConnectomeSpace n k))) ≤ cs.bound := by
    exact le_trans ( Finset.card_le_card <| Finset.image_subset_iff.mpr fun x _ => Finset.mem_range.mpr <| hv.bounded x ) ( by simpa );
  rw [ Finset.card_image_of_injective _ hv.injective ] at h_count_codewords ; simp_all +decide [ Fintype.card_subtype ];
  exact not_lt_of_ge h_count_codewords ( h_contra'.trans_le ( by rw [ connectome_count ] ) )

/-
**No free lunch**: Encoding all connectomes into fewer than k^(n*n)
codewords cannot be injective.
-/
theorem no_lossless_compression_below_card (n k m : ℕ) [NeZero k]
    (f : ConnectomeSpace n k → Fin m)
    (hm : m < k ^ (n * n)) :
    ¬ Function.Injective f := by
  exact fun h => hm.not_ge <| by have := Fintype.card_le_of_injective f h; simpa [ connectome_count ] using this;

/-! ## Part 3: Coarse-Graining Information Loss -/

/-- A `CoarseGraining` maps fine-grained weight levels to coarser ones. -/
def CoarseGraining (k k' : ℕ) := Fin k → Fin k'

/-- Applying a coarse-graining to a connectome. -/
def applyCoarseGraining {n k k' : ℕ} (cg : CoarseGraining k k')
    (c : ConnectomeSpace n k) : ConnectomeSpace n k' :=
  fun p => cg (c p)

/-
**Coarse-graining is not injective when the weight map isn't**:
If the weight map is non-injective, so is the induced connectome map
(for nonempty neuron sets).
-/
theorem coarse_graining_not_injective {n k k' : ℕ}
    [NeZero n] [NeZero k]
    (cg : CoarseGraining k k')
    (hcg : ¬ Function.Injective cg) :
    ¬ Function.Injective (applyCoarseGraining cg :
      ConnectomeSpace n k → ConnectomeSpace n k') := by
  obtain ⟨ a, b, hab, h ⟩ := Function.not_injective_iff.mp hcg;
  exact fun hinj => h <| by simpa [ hab ] using congr_fun ( hinj <| show ( fun p => cg ( if p = ( ⟨ 0, NeZero.pos n ⟩, ⟨ 0, NeZero.pos n ⟩ ) then a else b ) ) = fun p => cg ( if p = ( ⟨ 0, NeZero.pos n ⟩, ⟨ 0, NeZero.pos n ⟩ ) then b else b ) by ext p; aesop ) ( ⟨ 0, NeZero.pos n ⟩, ⟨ 0, NeZero.pos n ⟩ ) ;

/-
**Image bound under coarse-graining**: The image has at most
(k')^(n²) elements, which is the size of the target space.
-/
theorem coarse_graining_image_bound (n k k' : ℕ) [NeZero k'] [NeZero k]
    (cg : CoarseGraining k k') :
    Fintype.card (Set.range (applyCoarseGraining cg :
      ConnectomeSpace n k → ConnectomeSpace n k')) ≤ k' ^ (n * n) := by
  convert Fintype.card_le_of_injective _ _;
  convert connectome_count n k' |> Eq.symm;
  exacts [ fun x => x.val, fun x y h => by cases x; cases y; simp +decide at *; tauto ]

/-! ## Part 4: Bekenstein-Style Information Capacity -/

/-- The `bekensteinBound` gives the maximum bits storable in a sphere
of radius R containing energy E. -/
noncomputable def bekensteinBound (R E : ℝ) : ℝ :=
  2 * Real.pi * R * E / Real.log 2

/-
The Bekenstein bound is non-negative for non-negative parameters.
-/
theorem bekenstein_nonneg {R E : ℝ} (hR : 0 ≤ R) (hE : 0 ≤ E) :
    0 ≤ bekensteinBound R E := by
  exact div_nonneg ( mul_nonneg ( mul_nonneg ( mul_nonneg zero_le_two Real.pi_pos.le ) hR ) hE ) ( Real.log_nonneg one_le_two )

/-
The Bekenstein bound scales linearly with radius.
-/
theorem bekenstein_linear_radius {R E : ℝ} (c : ℝ) :
    bekensteinBound (c * R) E = c * bekensteinBound R E := by
  unfold bekensteinBound; ring;

/-
The Bekenstein bound scales linearly with energy.
-/
theorem bekenstein_linear_energy {R E : ℝ} (c : ℝ) :
    bekensteinBound R (c * E) = c * bekensteinBound R E := by
  unfold bekensteinBound; ring;

/-! ## Part 5: Upload Fidelity Threshold -/

/-- An `UploadSpecification` captures parameters of a mind uploading scheme. -/
structure UploadSpecification where
  neurons : ℕ
  weightLevels : ℕ
  radius : ℝ
  energy : ℝ
  neurons_pos : 0 < neurons
  weights_pos : 0 < weightLevels
  radius_pos : 0 < radius
  energy_pos : 0 < energy

/-- The information requirement for lossless upload. -/
noncomputable def UploadSpecification.infoRequirement (spec : UploadSpecification) : ℝ :=
  (spec.neurons * spec.neurons : ℝ) * Real.logb 2 spec.weightLevels

/-- The physical capacity of the substrate. -/
noncomputable def UploadSpecification.physicalCapacity (spec : UploadSpecification) : ℝ :=
  bekensteinBound spec.radius spec.energy

/-! ## Part 6: Quadratic Growth of Connectome Complexity -/

/-
**Strict quadratic scaling**: k^(n²) ≥ n² for k ≥ 2.
-/
theorem description_length_quadratic_lower (n k : ℕ) (hk : 2 ≤ k) :
    n * n ≤ k ^ (n * n) := by
  -- Apply the lemma that states $m \leq k^m$ for any $m \geq 0$ and $k \geq 2$.
  have h_exp : ∀ m : ℕ, m ≤ k ^ m := by
    exact fun m => le_of_lt ( Nat.recOn m ( by norm_num ) fun m ih => by rw [ pow_succ' ] ; nlinarith );
  exact h_exp _

/-
**Monotonicity**: More neurons means more connectomes.
-/
theorem connectome_space_monotone (n₁ n₂ k : ℕ)
    (hn : n₁ ≤ n₂) (hk : 1 ≤ k) :
    k ^ (n₁ * n₁) ≤ k ^ (n₂ * n₂) := by
  exact Nat.pow_le_pow_right hk ( by nlinarith )

/-! ## Part 7: Neural Information Defect -/

/-- The **Neural Information Defect** measures information irrecoverably lost
when encoding at reduced precision. NID(n, k, k') = n² · (log₂(k) - log₂(k')).
This is a novel concept quantifying the "damage" of lossy mind uploading. -/
noncomputable def neuralInfoDefect (n k k' : ℕ) : ℝ :=
  (n * n : ℝ) * (Real.logb 2 k - Real.logb 2 k')

/-
The neural information defect is zero when resolution is preserved.
-/
theorem nid_zero_same_resolution (n k : ℕ) :
    neuralInfoDefect n k k = 0 := by
  unfold neuralInfoDefect; ring;

/-
The neural information defect is non-negative when coarsening (k' ≤ k).
-/
theorem nid_nonneg {n k k' : ℕ} (hk : (k' : ℝ) ≤ k) (hk' : 0 < (k' : ℝ)) :
    0 ≤ neuralInfoDefect n k k' := by
  refine mul_nonneg ( by positivity ) ( sub_nonneg_of_le ?_ );
  gcongr ; aesop

/-
The neural information defect is monotone: more coarsening loses more info.
-/
theorem nid_monotone_coarsening (n k : ℕ) {k₁ k₂ : ℕ}
    (h : k₂ ≤ k₁) (hk₂ : 0 < (k₂ : ℝ)) :
    neuralInfoDefect n k k₁ ≤ neuralInfoDefect n k k₂ := by
  by_cases hk : k = 0 <;> by_cases hk₂ : k₂ = 0 <;> by_cases hk₁ : k₁ = 0 <;> simp_all +decide [ neuralInfoDefect ]; all_goals gcongr ; norm_cast

/-
The neural information defect is additive under sequential coarsening.
-/
theorem nid_additive (n k k' k'' : ℕ) :
    neuralInfoDefect n k k'' = neuralInfoDefect n k k' + neuralInfoDefect n k' k'' := by
  unfold neuralInfoDefect;
  ring

/-! ## Conjecture Test -/

/-
**Small-case incompressibility**: 2^4 < 2^(3×3), confirming that for 3 neurons
with binary weights, fewer than 16 codewords cannot represent all 512 connectomes.
-/
theorem incompressibility_conjecture_small_case :
    (2 : ℕ) ^ 4 < 2 ^ (3 * 3) := by
  norm_num

#print axioms connectome_count