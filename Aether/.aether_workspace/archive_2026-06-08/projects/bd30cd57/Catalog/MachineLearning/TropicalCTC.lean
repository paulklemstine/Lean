import Mathlib

/-!
# Tropical Time Travel: Min-Plus Closed Timelike Curves and Consistency

We formalize the connection between closed timelike curves (CTCs) in general relativity
and fixed-point theory in tropical (min-plus) algebra. The key insight is that
self-consistency of a time-traveling system is equivalent to the existence of a fixed
point of a tropical affine operator, and chronology protection (uniqueness of consistent
histories) corresponds to contractivity conditions.

## Main Results

### Definitions
* `tropApply` — Tropical matrix-vector multiplication: (A ⊙ x)_i = inf_j (A i j + x j)
* `tropAffine` — Tropical affine map: F_{A,b}(x)_i = min((A ⊙ x)_i, b_i)
* `IsConsistentTimeline` — A state is consistent if F x = x
* `ChronologyProtected` — Exactly one consistent timeline exists

### Paradox Collapse (Tropical Idempotence)
* `tropical_idempotent` — min a a = a
* `tropical_min_comm` — min a b = min b a
* `tropical_branch_conflict_collapse` — Equal branches collapse under min
* `tropical_ctc_duplicate_constraint_absorption` — Duplicating a constraint is absorbed
* `tropical_weaker_branch_irrelevance` — Weaker branches are absorbed by stronger ones

### Monotonicity
* `tropApply_monotone` — Tropical matrix action is monotone
* `tropAffine_monotone` — Tropical affine maps are monotone

### Existence (Novikov Consistency)
* `tropical_ctc_fixed_point_exists` — If a tropical CTC update preserves a box, a
  consistent timeline exists (Knaster-Tarski)

### Uniqueness (Chronology Protection)
* `contraction_unique_fixed_point` — Contractions have at most one fixed point
* `tropical_ctc_unique_fixed_point_of_contraction` — Contractive tropical maps have
  exactly one consistent timeline (Banach)

### Spectral / Discounted Contractivity
* `tropAffineDiscounted_is_contraction` — Discounted tropical affine maps are contractions
* `tropical_chronology_protection_discounted` — Discounted systems are chronology-protected
-/

noncomputable section

open Finset

/-! ## Part 1: Core Definitions -/

/-- Tropical matrix-vector multiplication: `(A ⊙ x)_i = inf_j (A i j + x j)`.
This is the fundamental operation of min-plus algebra acting on state vectors. -/
def tropApply {n : ℕ} [NeZero n] (A : Fin n → Fin n → ℝ) (x : Fin n → ℝ) : Fin n → ℝ :=
  fun i => Finset.univ.inf' Finset.univ_nonempty (fun j => A i j + x j)

/-- Tropical affine map: `F_{A,b}(x)_i = min((A ⊙ x)_i, b_i)`.
Models a time-travel update rule where `A` encodes causal propagation weights
and `b` encodes boundary/clamping constraints. -/
def tropAffine {n : ℕ} [NeZero n] (A : Fin n → Fin n → ℝ) (b : Fin n → ℝ) :
    (Fin n → ℝ) → (Fin n → ℝ) :=
  fun x i => min (tropApply A x i) (b i)

/-- A state `x` is a consistent timeline for operator `F` if `F x = x`.
This is the tropical analogue of Novikov's self-consistency principle. -/
def IsConsistentTimeline {n : ℕ} (F : (Fin n → ℝ) → (Fin n → ℝ)) (x : Fin n → ℝ) : Prop :=
  F x = x

/-- Chronology protection: exactly one consistent timeline exists.
This is the tropical analogue of Hawking's chronology protection conjecture. -/
def ChronologyProtected {n : ℕ} (F : (Fin n → ℝ) → (Fin n → ℝ)) : Prop :=
  ∃! x, F x = x

/-! ## Part 2: Paradox Collapse — Tropical Idempotence -/

/-- **Grandfather Paradox Resolution (atomic).**
The idempotence of `min` is the algebraic engine that collapses contradictory
self-interaction branches: applying the same constraint twice has no additional effect. -/
theorem tropical_idempotent (a : ℝ) : min a a = a := min_self a

/-- **Branch commutativity.**
The order in which contradictory timeline constraints are combined is irrelevant. -/
theorem tropical_min_comm (a b : ℝ) : min a b = min b a := min_comm a b

/-
**Branch conflict collapse (vector version).**
If two timeline branches produce identical states, their tropical combination
is the original state — no paradox arises.
-/
theorem tropical_branch_conflict_collapse
    {n : ℕ} (u v : Fin n → ℝ) (h : ∀ i, u i = v i) :
    (fun i => min (u i) (v i)) = u := by
  grind

/-
**Duplicate constraint absorption (operator level).**
Duplicating the same self-consistency constraint does not create paradox;
tropical idempotence absorbs it. This is the formal content behind the slogan
"the grandfather paradox is resolved by idempotence."
-/
theorem tropical_ctc_duplicate_constraint_absorption
    {n : ℕ} [NeZero n]
    (A : Fin n → Fin n → ℝ)
    (x : Fin n → ℝ) :
    (fun i => min
      (Finset.univ.inf' Finset.univ_nonempty (fun j => A i j + x j))
      (Finset.univ.inf' Finset.univ_nonempty (fun j => A i j + x j)))
    = (fun i => Finset.univ.inf' Finset.univ_nonempty (fun j => A i j + x j)) := by
  exact funext fun i => min_self _

/-
**Weaker branch irrelevance.**
In a min-plus universe, the dominant (smaller) consistent branch absorbs
weaker (larger) alternatives. This is the true paradox-resolution principle.
-/
theorem tropical_weaker_branch_irrelevance
    {n : ℕ} (f g : Fin n → ℝ) (hfg : ∀ i, f i ≤ g i) :
    (fun i => min (f i) (g i)) = f := by
  exact funext fun i => min_eq_left ( hfg i )

/-! ## Part 3: Monotonicity of Tropical Maps -/

/-
Tropical matrix action is monotone: if x ≤ y pointwise, then A ⊙ x ≤ A ⊙ y pointwise.
This is because addition preserves order and inf preserves order.
-/
theorem tropApply_monotone {n : ℕ} [NeZero n] (A : Fin n → Fin n → ℝ) :
    Monotone (tropApply A) := by
  -- The infimum of a set of numbers is monotone with respect to the set of numbers.
  have h_inf_monotone : ∀ (x y : Fin n → ℝ), (∀ i, x i ≤ y i) → ∀ i, (Finset.univ.inf' Finset.univ_nonempty (fun j => A i j + x j)) ≤ (Finset.univ.inf' Finset.univ_nonempty (fun j => A i j + y j)) := by
    intro x y hxy i;
    simp +decide [ Finset.inf'_le_iff, hxy ];
    exact fun j => ⟨ j, by linarith [ hxy j ] ⟩;
  exact fun x y hxy => fun i => h_inf_monotone x y hxy i

/-
Tropical affine maps are monotone: they compose monotone operations (tropApply and min).
-/
theorem tropAffine_monotone {n : ℕ} [NeZero n] (A : Fin n → Fin n → ℝ) (b : Fin n → ℝ) :
    Monotone (tropAffine A b) := by
  exact fun x y hxy => fun i => min_le_min ( tropApply_monotone A hxy i ) ( le_rfl )

/-! ## Part 4: Existence of Consistent Timelines (Novikov Principle)

The central existence theorem: if a tropical CTC update preserves a finite box/order
interval `[lo, hi]`, then there exists a self-consistent timeline. This is the cleanest
formal Novikov principle available from finite order-theoretic machinery.

The proof uses the Knaster-Tarski fixed-point theorem on the complete lattice
`Set.Icc lo hi` with the pointwise order.
-/

/-
**Monotone box fixed-point theorem.**
If F is a monotone self-map of a box `[lo, hi]` in `ℝⁿ`, then F has a fixed point
in the box. This is a direct application of Knaster-Tarski to the complete lattice
structure of the closed interval.
-/
theorem monotone_box_fixed_point
    {n : ℕ} (F : (Fin n → ℝ) → (Fin n → ℝ))
    (lo hi : Fin n → ℝ)
    (hle : ∀ i, lo i ≤ hi i)
    (hF_mono : Monotone F)
    (hF_map : ∀ x : Fin n → ℝ,
      (∀ i, lo i ≤ x i ∧ x i ≤ hi i) →
      ∀ i, lo i ≤ F x i ∧ F x i ≤ hi i) :
    ∃ x : Fin n → ℝ, (∀ i, lo i ≤ x i ∧ x i ≤ hi i) ∧ F x = x := by
  -- Set `haveI : Fact (lo ≤ hi) := ⟨hle⟩`.
  have h_fact : Fact (lo ≤ hi) := ⟨fun i => hle i⟩;
  -- Define F' : Set.Icc lo hi → Set.Icc lo hi by mapping ⟨x, hx⟩ to ⟨F x, proof_from_hF_map⟩.
  obtain ⟨F', hF'⟩ : ∃ F' : Set.Icc lo hi →o Set.Icc lo hi, ∀ x : Set.Icc lo hi, F' x = ⟨F x, by
    exact ⟨ fun i => hF_map x ( fun i => ⟨ x.2.1 i, x.2.2 i ⟩ ) i |>.1, fun i => hF_map x ( fun i => ⟨ x.2.1 i, x.2.2 i ⟩ ) i |>.2 ⟩⟩ := by
    all_goals generalize_proofs at *;
    exact ⟨ ⟨ fun x => ⟨ F x, by aesop ⟩, fun x y hxy => by exact Subtype.mk_le_mk.mpr ( hF_mono hxy ) ⟩, fun x => rfl ⟩
  generalize_proofs at *;
  -- Apply `OrderHom.isFixedPt_lfp` to get a fixed point `p` of `F'`.
  obtain ⟨p, hp⟩ : ∃ p : Set.Icc lo hi, F' p = p := by
    exact ⟨ _, F'.isFixedPt_lfp ⟩;
  exact ⟨ p, fun i => ⟨ p.2.1 i, p.2.2 i ⟩, by simpa [ hF' ] using congr_arg Subtype.val hp ⟩

/-
**Existence of a consistent tropical CTC state (Novikov principle).**
If a tropical CTC update preserves a finite box, then there exists a self-consistent
timeline within that box. This upgrades "consistency of time travel" from science fiction
intuition to a certified theorem in idempotent dynamics.
-/
theorem tropical_ctc_fixed_point_exists
    {n : ℕ} [NeZero n]
    (A : Fin n → Fin n → ℝ)
    (b lo hi : Fin n → ℝ)
    (hlohi : ∀ i, lo i ≤ hi i)
    (hmap :
      ∀ x : Fin n → ℝ,
        (∀ i, lo i ≤ x i ∧ x i ≤ hi i) →
        ∀ i, lo i ≤ min (Finset.univ.inf' Finset.univ_nonempty (fun j => A i j + x j)) (b i)
             ∧ min (Finset.univ.inf' Finset.univ_nonempty (fun j => A i j + x j)) (b i) ≤ hi i) :
    ∃ x : Fin n → ℝ,
      (∀ i, lo i ≤ x i ∧ x i ≤ hi i) ∧
      (∀ i, min (Finset.univ.inf' Finset.univ_nonempty (fun j => A i j + x j)) (b i) = x i) := by
  -- We apply the monotone_box_fixed_point theorem to the tropAffine map.
  obtain ⟨x, hx⟩ : ∃ x : Fin n → ℝ, (∀ i, lo i ≤ x i ∧ x i ≤ hi i) ∧ tropAffine A b x = x := by
    apply monotone_box_fixed_point;
    · assumption;
    · exact?;
    · exact hmap;
  exact ⟨ x, hx.1, fun i => congr_fun hx.2 i ⟩

/-! ## Part 5: Uniqueness under Contraction (Chronology Protection)

Chronology protection = strict contractivity = unique self-consistent history.
This is much stronger than blanket uniqueness: it requires a dissipative condition
on the causal update, analogous to energy loss in physical time machines.
-/

/-
**Contraction implies unique fixed point.**
If a map on a metric space is strictly contractive, it has at most one fixed point.
This is the uniqueness half of the Banach fixed-point theorem.
-/
theorem contraction_unique_fixed_point
    {n : ℕ} {F : (Fin n → ℝ) → (Fin n → ℝ)} {q : ℝ}
    (hq0 : 0 ≤ q) (hq1 : q < 1)
    (hcontr : ∀ x y : Fin n → ℝ, dist (F x) (F y) ≤ q * dist x y)
    {x y : Fin n → ℝ} (hx : F x = x) (hy : F y = y) : x = y := by
  exact Classical.not_not.1 fun h => absurd ( hcontr x y ) ( by rw [ hx, hy ] ; exact not_le_of_gt ( mul_lt_of_lt_one_left ( dist_pos.2 h ) hq1 ) )

/-
**Chronology protection theorem (Banach).**
A contractive tropical map has exactly one consistent timeline.
This imports ideas from general relativity into tropical algebra: chronology
protection is not "no time machines," but "time machines whose causal update
is dissipative admit exactly one consistent history."
-/
theorem tropical_ctc_unique_fixed_point_of_contraction
    {n : ℕ} {F : (Fin n → ℝ) → (Fin n → ℝ)} {q : ℝ}
    (hq0 : 0 ≤ q) (hq1 : q < 1)
    (hcontr : ∀ x y : Fin n → ℝ, dist (F x) (F y) ≤ q * dist x y)
    (hfp : ∃ x : Fin n → ℝ, F x = x) :
    ∃! x : Fin n → ℝ, F x = x := by
  exact ⟨ hfp.choose, hfp.choose_spec, fun x hx => contraction_unique_fixed_point hq0 hq1 hcontr hx hfp.choose_spec ⟩

/-! ## Part 6: Discounted Tropical Maps are Contractions (Spectral Chronology Protection)

The discounted tropical affine map `F_λ(x)_i = min(inf_j(A i j + λ · x j), b_i)` with
`0 ≤ λ < 1` is a contraction with factor `λ` in the sup-norm. This connects the
spectral condition (discount factor < 1) to chronology protection.
-/

/-- The discounted tropical affine map with damping factor `lam`. -/
def tropAffineDiscounted {n : ℕ} [NeZero n]
    (A : Fin n → Fin n → ℝ) (b : Fin n → ℝ) (lam : ℝ) :
    (Fin n → ℝ) → (Fin n → ℝ) :=
  fun x i => min (Finset.univ.inf' Finset.univ_nonempty (fun j => A i j + lam * x j)) (b i)

/-
**Key contraction lemma:** `|min(a, c) - min(b, c)| ≤ |a - b|` for all reals.
-/
theorem min_dist_le (a b c : ℝ) : |min a c - min b c| ≤ |a - b| := by
  grind +splitIndPred

/-
**Inf' contraction lemma:** The tropical matrix action with discount factor `lam`
contracts distances by factor `|lam|` in each coordinate.
-/
theorem tropApply_discounted_coord_contraction {n : ℕ} [NeZero n]
    (A : Fin n → Fin n → ℝ) (lam : ℝ) (x y : Fin n → ℝ) (i : Fin n) :
    |Finset.univ.inf' Finset.univ_nonempty (fun j => A i j + lam * x j) -
     Finset.univ.inf' Finset.univ_nonempty (fun j => A i j + lam * y j)| ≤
    |lam| * dist x y := by
  have h_inf_diff : ∀ j, |(A i j + lam * x j) - (A i j + lam * y j)| ≤ |lam| * dist x y := by
    norm_num [ dist_eq_norm ];
    exact fun j => by rw [ ← mul_sub, abs_mul ] ; exact mul_le_mul_of_nonneg_left ( by simpa using norm_le_pi_norm ( x - y ) j ) ( abs_nonneg lam ) ;
  refine' abs_sub_le_iff.mpr ⟨ _, _ ⟩;
  · simp_all +decide [ Finset.inf'_le ];
    obtain ⟨ j, hj ⟩ := Finset.exists_mem_eq_inf' Finset.univ_nonempty ( fun j => A i j + lam * y j );
    exact ⟨ j, by linarith [ abs_le.mp ( h_inf_diff j ) ] ⟩;
  · simp_all +decide [ Finset.inf'_eq_csInf_image ];
    refine' le_of_forall_pos_le_add fun ε ε_pos => _;
    -- By definition of infimum, there exists some $j$ such that $A i j + lam * x j \leq sInf (Set.range (fun j => A i j + lam * x j)) + ε$.
    obtain ⟨j, hj⟩ : ∃ j, A i j + lam * x j ≤ sInf (Set.range (fun j => A i j + lam * x j)) + ε := by
      exact by rcases exists_lt_of_csInf_lt ( Set.nonempty_of_mem ( Set.mem_range_self i ) ) ( show sInf ( Set.range fun j => A i j + lam * x j ) < sInf ( Set.range fun j => A i j + lam * x j ) + ε from lt_add_of_pos_right _ ε_pos ) with ⟨ j, ⟨ k, rfl ⟩, hk ⟩ ; exact ⟨ k, by linarith ⟩ ;
    exact le_trans ( csInf_le ( Set.finite_range _ |> Set.Finite.bddBelow ) ( Set.mem_range_self j ) ) ( by linarith [ abs_le.mp ( h_inf_diff j ) ] )

/-
**Discounted tropical affine maps are contractions.**
When `0 ≤ lam < 1`, the discounted tropical affine map is a contraction with
factor `lam` in the sup-norm. This is the key technical result connecting
tropical spectral theory to chronology protection.
-/
theorem tropAffineDiscounted_is_contraction {n : ℕ} [NeZero n]
    (A : Fin n → Fin n → ℝ) (b : Fin n → ℝ) (lam : ℝ)
    (hlam0 : 0 ≤ lam) (_hlam1 : lam < 1)
    (x y : Fin n → ℝ) :
    dist (tropAffineDiscounted A b lam x) (tropAffineDiscounted A b lam y) ≤
    lam * dist x y := by
  -- By definition of tropAffineDiscounted, we have:
  unfold tropAffineDiscounted;
  rw [ dist_pi_le_iff ];
  · intro i;
    convert min_dist_le _ _ _ |> le_trans <| tropApply_discounted_coord_contraction _ _ _ _ i using 1;
    rw [ abs_of_nonneg hlam0 ];
  · exact mul_nonneg hlam0 ( dist_nonneg )

/-
**Chronology protection via discounting (spectral theorem).**
A discounted tropical system (discount factor < 1) is chronology-protected:
it has at most one consistent timeline. Combined with existence from
`tropical_ctc_fixed_point_exists`, this gives a complete consistency theorem.

Interpretation: the discount factor `λ < 1` models causal dissipation —
information loses energy as it traverses the time loop. Under dissipation,
paradoxes cannot sustain themselves and exactly one consistent history survives.
-/
theorem tropical_chronology_protection_discounted {n : ℕ} [NeZero n]
    (A : Fin n → Fin n → ℝ) (b : Fin n → ℝ) (lam : ℝ)
    (hlam0 : 0 ≤ lam) (hlam1 : lam < 1)
    {x y : Fin n → ℝ}
    (hx : tropAffineDiscounted A b lam x = x)
    (hy : tropAffineDiscounted A b lam y = y) :
    x = y := by
  exact contraction_unique_fixed_point hlam0 hlam1 ( tropAffineDiscounted_is_contraction A b lam hlam0 hlam1 ) hx hy

end