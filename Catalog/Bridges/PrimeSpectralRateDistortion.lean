/-
# Prime-Spectral Rate–Distortion Theory for Finite Spectra

This file develops a constructive rate–distortion theory over finite prime spectra.
The core idea: given a finite set of "spectral states" (prime witnesses of non-derivability)
and a "gap" function measuring separation power, we find optimal codebooks—minimal
subsets of spectral states that approximate the full separation power within tolerance ε.

## Main results

* `spec_is_zero_codebook` — the full spectrum is always a 0-codebook
* `exists_optimal_codebook` — existence of a cardinality-minimal ε-codebook
* `codingNumber_mono` — rate–distortion monotonicity: more tolerance ⟹ fewer codewords
* `zero_distortion_iff_complete_separation` — zero distortion ↔ full separation preserved
* `approximate_reconstruction` — the ε-reconstruction inequality
* `reconstruction_sound` — same code profile ⟹ same restricted gap
* Greedy codebook construction with monotone distortion decrease
-/
import Mathlib

open Finset BigOperators

noncomputable section

/-! ## Core Types -/

/-- Inverse temperature / free-energy parameter. -/
structure BetaParam where
  val : ℝ

instance : DecidableEq BetaParam := by
  intro a b
  rcases a with ⟨a⟩; rcases b with ⟨b⟩
  by_cases h : a = b
  · exact isTrue (by subst h; rfl)
  · exact isFalse (by intro hab; exact h (BetaParam.mk.inj hab))

/-- A prime spectral state: an index paired with a beta parameter. -/
abbrev PrimeBetaState (ι : Type*) := ι × BetaParam

/-- A pair of semantic objects. -/
abbrev Pair (S : Type*) := S × S

/-! ## Gap and Distortion Definitions -/

variable {S ι : Type*} [DecidableEq S] [Fintype S] [DecidableEq ι] [Fintype ι]

/-- The full spectral gap: supremum of gap values over the full spectrum. -/
def fullGap (gap : PrimeBetaState ι → Pair S → ℝ)
    (spec : Finset (PrimeBetaState ι)) (hspec : spec.Nonempty) (x : Pair S) : ℝ :=
  spec.sup' hspec (fun ω => gap ω x)

/-- The restricted gap over a sub-codebook C. Returns 0 if C is empty. -/
def restrictedGap (gap : PrimeBetaState ι → Pair S → ℝ)
    (C : Finset (PrimeBetaState ι)) (x : Pair S) : ℝ :=
  if hC : C.Nonempty then C.sup' hC (fun ω => gap ω x) else 0

/-- Distortion: the gap lost by restricting to codebook C. -/
def distortion (gap : PrimeBetaState ι → Pair S → ℝ)
    (spec : Finset (PrimeBetaState ι)) (hspec : spec.Nonempty)
    (C : Finset (PrimeBetaState ι)) (x : Pair S) : ℝ :=
  fullGap gap spec hspec x - restrictedGap gap C x

/-- Whether C is an ε-codebook: distortion ≤ ε on all training pairs. -/
def IsEpsilonCodebook (gap : PrimeBetaState ι → Pair S → ℝ)
    (spec : Finset (PrimeBetaState ι)) (hspec : spec.Nonempty)
    (pairs : Finset (Pair S)) (ε : ℝ) (C : Finset (PrimeBetaState ι)) : Prop :=
  ∀ x ∈ pairs, distortion gap spec hspec C x ≤ ε

/-- The set of admissible ε-codebooks drawn from the spectrum. -/
def admissibleCodebooks (gap : PrimeBetaState ι → Pair S → ℝ)
    (spec : Finset (PrimeBetaState ι)) (hspec : spec.Nonempty)
    (pairs : Finset (Pair S)) (ε : ℝ) : Finset (Finset (PrimeBetaState ι)) :=
  spec.powerset.filter (fun C => ∀ x ∈ pairs, distortion gap spec hspec C x ≤ ε)

/-- The coding number: minimum cardinality of an ε-codebook from spec.
    If no ε-codebook exists, returns spec.card + 1 as a sentinel. -/
def codingNumber (gap : PrimeBetaState ι → Pair S → ℝ)
    (spec : Finset (PrimeBetaState ι)) (hspec : spec.Nonempty)
    (pairs : Finset (Pair S)) (ε : ℝ) : ℕ :=
  if h : (admissibleCodebooks gap spec hspec pairs ε).Nonempty then
    ((admissibleCodebooks gap spec hspec pairs ε).image Finset.card).min'
      (Nonempty.image h _)
  else
    spec.card + 1

/-- Complete separation: the restricted gap equals the full gap on all pairs. -/
def CompleteSeparation (gap : PrimeBetaState ι → Pair S → ℝ)
    (spec : Finset (PrimeBetaState ι)) (hspec : spec.Nonempty)
    (pairs : Finset (Pair S)) (C : Finset (PrimeBetaState ι)) : Prop :=
  ∀ x ∈ pairs, restrictedGap gap C x = fullGap gap spec hspec x

/-- Total distortion over all training pairs. -/
def totalDistortion (gap : PrimeBetaState ι → Pair S → ℝ)
    (spec : Finset (PrimeBetaState ι)) (hspec : spec.Nonempty)
    (pairs : Finset (Pair S)) (C : Finset (PrimeBetaState ι)) : ℝ :=
  ∑ x ∈ pairs, distortion gap spec hspec C x

/-- Same code profile: two pairs have identical gap values on all states in C. -/
def SameCodeProfile (gap : PrimeBetaState ι → Pair S → ℝ)
    (C : Finset (PrimeBetaState ι)) (x y : Pair S) : Prop :=
  ∀ ω ∈ C, gap ω x = gap ω y

/-- Reconstruction map: returns the gap profile restricted to C. -/
def reconstruct (gap : PrimeBetaState ι → Pair S → ℝ)
    (C : Finset (PrimeBetaState ι)) (x : Pair S) :
    PrimeBetaState ι → ℝ :=
  fun ω => if ω ∈ C then gap ω x else 0

/-- Marginal gain from adding ω to codebook C. -/
def marginalGain (gap : PrimeBetaState ι → Pair S → ℝ)
    (spec : Finset (PrimeBetaState ι)) (hspec : spec.Nonempty)
    (pairs : Finset (Pair S))
    (C : Finset (PrimeBetaState ι)) (ω : PrimeBetaState ι) : ℝ :=
  totalDistortion gap spec hspec pairs C -
    totalDistortion gap spec hspec pairs (insert ω C)

/-! ## Structural Lemmas -/

set_option linter.unusedSectionVars false

variable (gap : PrimeBetaState ι → Pair S → ℝ)
variable (spec : Finset (PrimeBetaState ι))
variable (hspec : spec.Nonempty)
variable (pairs : Finset (Pair S))

/-
Monotonicity of restricted gap under inclusion of codebooks.
-/
theorem restrictedGap_mono {C D : Finset (PrimeBetaState ι)}
    (hCD : C ⊆ D) (hC : C.Nonempty) :
    ∀ x, restrictedGap gap C x ≤ restrictedGap gap D x := by
  intro x
  simp [restrictedGap];
  split_ifs ; exact Finset.sup'_le _ _ fun ω hω => Finset.le_sup' ( fun ω => gap ω x ) ( hCD hω );
  exact False.elim ( ‹¬D.Nonempty› ( hC.mono hCD ) )

/-
The restricted gap on a nonempty subset of spec is bounded by the full gap.
-/
theorem restrictedGap_le_fullGap (C : Finset (PrimeBetaState ι)) (hC : C ⊆ spec)
    (hCne : C.Nonempty) :
    ∀ x, restrictedGap gap C x ≤ fullGap gap spec hspec x := by
  unfold restrictedGap fullGap;
  intro x; split_ifs; exact Finset.sup'_le _ _ fun ω hω => Finset.le_sup' ( fun ω => gap ω x ) ( hC hω ) ;

/-
Distortion is nonneg when C is a nonempty subset of spec.
-/
theorem distortion_nonneg (C : Finset (PrimeBetaState ι)) (hC : C ⊆ spec)
    (hCne : C.Nonempty) :
    ∀ x, 0 ≤ distortion gap spec hspec C x := by
  exact fun x => sub_nonneg_of_le ( restrictedGap_le_fullGap gap spec hspec C hC hCne x )

/-
The full spectrum restricted gap equals the full gap.
-/
theorem spec_exact (x : Pair S) :
    restrictedGap gap spec x = fullGap gap spec hspec x := by
  unfold fullGap restrictedGap; aesop;

/-
The full spectrum is a 0-codebook.
-/
theorem spec_is_zero_codebook :
    IsEpsilonCodebook gap spec hspec pairs 0 spec := by
  intro x hx; simp +decide [ distortion ] ;
  rw [ spec_exact ];
  exact hspec

/-
The full spectrum is an ε-codebook for any ε ≥ 0.
-/
theorem spec_is_epsilon_codebook (ε : ℝ) (hε : 0 ≤ ε) :
    IsEpsilonCodebook gap spec hspec pairs ε spec := by
  exact fun x hx => le_trans ( spec_is_zero_codebook gap spec hspec pairs x hx ) hε

/-
ε-codebook monotonicity: if C is an ε₁-codebook and ε₁ ≤ ε₂, then C is an ε₂-codebook.
-/
theorem IsEpsilonCodebook_mono {ε₁ ε₂ : ℝ} (h : ε₁ ≤ ε₂)
    {C : Finset (PrimeBetaState ι)}
    (hC : IsEpsilonCodebook gap spec hspec pairs ε₁ C) :
    IsEpsilonCodebook gap spec hspec pairs ε₂ C := by
  intro x hx; unfold IsEpsilonCodebook at *; exact le_trans ( hC x hx ) h;

/-! ## Optimal Codebook Existence -/

/-
spec is in the admissible codebooks for ε ≥ 0.
-/
theorem spec_mem_admissibleCodebooks (ε : ℝ) (hε : 0 ≤ ε) :
    spec ∈ admissibleCodebooks gap spec hspec pairs ε := by
  exact Finset.mem_filter.mpr ⟨ Finset.mem_powerset.mpr ( Finset.Subset.refl _ ), spec_is_epsilon_codebook gap spec hspec pairs ε hε ⟩

/-
Admissible codebooks are nonempty when ε ≥ 0.
-/
theorem admissibleCodebooks_nonempty (ε : ℝ) (hε : 0 ≤ ε) :
    (admissibleCodebooks gap spec hspec pairs ε).Nonempty := by
  exact ⟨ _, Finset.mem_filter.mpr ⟨ Finset.mem_powerset.mpr ( Finset.Subset.refl _ ), fun x hx => by simpa using spec_is_epsilon_codebook gap spec hspec pairs ε hε x hx ⟩ ⟩

/-
Helper: a member of admissibleCodebooks is a subset of spec.
-/
theorem admissible_sub_spec {ε : ℝ} {C : Finset (PrimeBetaState ι)}
    (hC : C ∈ admissibleCodebooks gap spec hspec pairs ε) : C ⊆ spec := by
  exact Finset.mem_powerset.mp ( Finset.mem_filter.mp hC |>.1 )

/-
Helper: a member of admissibleCodebooks is an ε-codebook.
-/
theorem admissible_is_codebook {ε : ℝ} {C : Finset (PrimeBetaState ι)}
    (hC : C ∈ admissibleCodebooks gap spec hspec pairs ε) :
    IsEpsilonCodebook gap spec hspec pairs ε C := by
  exact Finset.mem_filter.mp hC |>.2

/-
**Existence of an optimal codebook on a finite spectrum.**
    For ε ≥ 0, there exists a subset of spec that is an ε-codebook with
    minimum cardinality among all admissible codebooks.
-/
theorem exists_optimal_codebook (ε : ℝ) (hε : 0 ≤ ε) :
    ∃ C : Finset (PrimeBetaState ι),
      C ⊆ spec ∧
      IsEpsilonCodebook gap spec hspec pairs ε C ∧
      C.card = codingNumber gap spec hspec pairs ε := by
  unfold codingNumber;
  split_ifs with h;
  · have := Finset.min'_mem ( image card ( admissibleCodebooks gap spec hspec pairs ε ) ) ⟨ _, Finset.mem_image_of_mem _ ( Classical.choose_spec h ) ⟩;
    grind +suggestions;
  · exact False.elim ( h ( admissibleCodebooks_nonempty gap spec hspec pairs ε hε ) )

/-
Admissible codebook inclusion: ε₁ ≤ ε₂ implies admissible(ε₁) ⊆ admissible(ε₂).
-/
theorem admissibleCodebooks_mono_eps {ε₁ ε₂ : ℝ} (h : ε₁ ≤ ε₂) :
    admissibleCodebooks gap spec hspec pairs ε₁ ⊆
    admissibleCodebooks gap spec hspec pairs ε₂ := by
  -- Unfold the definition of admissibleCodebooks.
  unfold admissibleCodebooks;
  grind

/-
**Monotonicity of coding number**: more tolerance ⟹ fewer codewords needed.
-/
theorem codingNumber_mono {ε₁ ε₂ : ℝ} (h : ε₁ ≤ ε₂) (hε₁ : 0 ≤ ε₁) :
    codingNumber gap spec hspec pairs ε₂ ≤ codingNumber gap spec hspec pairs ε₁ := by
  unfold codingNumber;
  split_ifs <;> simp_all +decide [ Finset.min' ];
  · exact fun x hx => ⟨ x, admissibleCodebooks_mono_eps gap spec hspec pairs h hx, le_rfl ⟩;
  · rename_i h₁ h₂;
    exact absurd h₂ ( Finset.Nonempty.ne_empty ( admissibleCodebooks_nonempty gap spec hspec pairs ε₁ hε₁ ) );
  · exact absurd ‹_› ( Finset.Nonempty.ne_empty ( admissibleCodebooks_nonempty _ _ _ _ _ ( by linarith ) ) )

/-! ## Zero Distortion and Complete Separation -/

/-
**Zero distortion ↔ complete separation**: a codebook has zero distortion on all
    pairs iff it completely preserves the full spectral gap.
-/
theorem zero_distortion_iff_complete_separation
    (C : Finset (PrimeBetaState ι)) (_hC : C ⊆ spec) :
    (∀ x ∈ pairs, distortion gap spec hspec C x = 0) ↔
    CompleteSeparation gap spec hspec pairs C := by
  constructor;
  · intro h x hx;
    exact eq_of_sub_eq_zero ( h x hx ) ▸ rfl;
  · intro h x hx; unfold distortion; simp +decide [ h x hx ] ;

/-
Total distortion is zero iff complete separation, for C ⊆ spec.
-/
theorem completeSeparation_iff_zero_totalDistortion
    (C : Finset (PrimeBetaState ι)) (hC : C ⊆ spec) (hCne : C.Nonempty) :
    CompleteSeparation gap spec hspec pairs C ↔
    totalDistortion gap spec hspec pairs C = 0 := by
  constructor <;> intro h;
  · exact Finset.sum_eq_zero fun x hx => sub_eq_zero_of_eq <| h x hx ▸ rfl;
  · apply (zero_distortion_iff_complete_separation gap spec hspec pairs C hC).mp;
    exact fun x hx => le_antisymm ( le_trans ( Finset.single_le_sum ( fun x _ => distortion_nonneg gap spec hspec C hC hCne x ) hx ) h.le ) ( distortion_nonneg gap spec hspec C hC hCne x )

/-
Total distortion is monotone: larger codebooks have smaller distortion.
-/
theorem totalDistortion_antimono {C D : Finset (PrimeBetaState ι)}
    (hCD : C ⊆ D) (_hD : D ⊆ spec) (hCne : C.Nonempty) :
    totalDistortion gap spec hspec pairs D ≤ totalDistortion gap spec hspec pairs C := by
  exact Finset.sum_le_sum fun x hx => sub_le_sub_left ( restrictedGap_mono _ hCD hCne x ) _

/-! ## Reconstruction Theorems -/

/-
**Reconstruction soundness**: pairs with the same code profile
    have the same restricted gap.
-/
theorem reconstruction_sound
    (C : Finset (PrimeBetaState ι)) :
    ∀ {x y : Pair S}, SameCodeProfile gap C x y →
      restrictedGap gap C x = restrictedGap gap C y := by
  unfold SameCodeProfile restrictedGap;
  split_ifs <;> simp_all +decide

/-
**Approximate reconstruction**: an ε-codebook loses at most ε separation power.
-/
theorem approximate_reconstruction
    {ε : ℝ} (C : Finset (PrimeBetaState ι))
    (_hCsub : C ⊆ spec)
    (hC : IsEpsilonCodebook gap spec hspec pairs ε C) :
    ∀ x ∈ pairs, fullGap gap spec hspec x - ε ≤ restrictedGap gap C x := by
  intro x hx;
  linarith [ hC x hx, show distortion gap spec hspec C x = fullGap gap spec hspec x - restrictedGap gap C x from rfl ]

/-! ## Greedy Codebook Construction -/

/-- Choose the spectral state from spec that maximizes marginal gain. -/
def greedyChoice (C : Finset (PrimeBetaState ι)) :
    PrimeBetaState ι :=
  spec.exists_max_image (fun ω => marginalGain gap spec hspec pairs C ω)
    hspec |>.choose

/-- One step of greedy construction: add the best spectral state. -/
def greedyStep (C : Finset (PrimeBetaState ι)) :
    Finset (PrimeBetaState ι) :=
  insert (greedyChoice gap spec hspec pairs C) C

/-- The k-step greedy codebook. -/
def greedyCodebook : ℕ → Finset (PrimeBetaState ι)
  | 0 => ∅
  | k + 1 => greedyStep gap spec hspec pairs (greedyCodebook k)

/-
The greedy choice is in spec.
-/
theorem greedyChoice_mem_spec (C : Finset (PrimeBetaState ι)) :
    greedyChoice gap spec hspec pairs C ∈ spec := by
  exact Classical.choose_spec ( spec.exists_max_image _ hspec ) |>.1

/-
Greedy codebook is a subset of spec.
-/
theorem greedyCodebook_sub_spec :
    ∀ k : ℕ, greedyCodebook gap spec hspec pairs k ⊆ spec := by
  intro k;
  induction' k with k ih;
  · exact Finset.empty_subset _;
  · exact Finset.insert_subset_iff.mpr ⟨ greedyChoice_mem_spec gap spec hspec pairs _, ih ⟩

/-
Greedy codebook has cardinality at most k.
-/
theorem greedyCodebook_card_le :
    ∀ k : ℕ, (greedyCodebook gap spec hspec pairs k).card ≤ k := by
  intro k;
  induction' k with k ih;
  · rfl;
  · exact le_trans ( Finset.card_insert_le _ _ ) ( Nat.add_le_add_right ih 1 )

/-
Total distortion is nonincreasing along the greedy sequence
    (under nonneg gap assumption).
-/
theorem greedy_distortion_nonincreasing
    (hgap : ∀ ω x, 0 ≤ gap ω x) :
    ∀ k : ℕ,
      totalDistortion gap spec hspec pairs (greedyCodebook gap spec hspec pairs (k + 1)) ≤
      totalDistortion gap spec hspec pairs (greedyCodebook gap spec hspec pairs k) := by
  intro k;
  unfold totalDistortion;
  refine' Finset.sum_le_sum fun x _ => sub_le_sub_left _ _;
  unfold greedyCodebook;
  rcases k with ( _ | k ) <;> simp +decide [ greedyStep ];
  · unfold restrictedGap;
    simp +decide [hgap];
  · apply_rules [ restrictedGap_mono ];
    · exact Finset.subset_insert _ _;
    · exact ⟨ _, Finset.mem_insert_self _ _ ⟩

/-
The greedy step is at least as good as any single insertion from spec.
-/
theorem greedyStep_best_single_insertion
    (C : Finset (PrimeBetaState ι)) :
    ∀ ω ∈ spec,
      totalDistortion gap spec hspec pairs (greedyStep gap spec hspec pairs C) ≤
      totalDistortion gap spec hspec pairs (insert ω C) := by
  -- By definition of greedyChoice, it maximizes the marginal gain over all elements in spec.
  have h_max_marginalGain : ∀ ω ∈ spec, marginalGain gap spec hspec pairs C ω ≤ marginalGain gap spec hspec pairs C (greedyChoice gap spec hspec pairs C) := by
    exact Classical.choose_spec ( spec.exists_max_image _ hspec ) |>.2;
  unfold marginalGain at *;
  exact fun ω hω => le_of_sub_nonneg ( by linarith! [ h_max_marginalGain ω hω ] )

end