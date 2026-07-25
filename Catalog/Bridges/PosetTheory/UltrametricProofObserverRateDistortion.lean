import Mathlib

/-!
# Non-Archimedean Proof Information Theory:
# Ultrametric Observer Rate–Distortion via Congruence Spectra

This file establishes a bridge between ultrametric geometry, observer-based
proof compression, and rate–distortion theory. The central result shows that in a
finite ultrametric proof space, the minimal lossy codebook size under observer distortion
equals the number of equivalence classes in the observer congruence — converting an
optimization problem into exact combinatorics.

## Main Results

* `observerDistortion_ultra` — Observer distortion (sup over observers) is ultrametric
* `finite_ultrametric_covering_number_eq_congruence_index` — **Core theorem**: minimal
  ε-cover size = number of ε-congruence classes
* `class_rep_gives_cover` — Quotient representatives form an optimal cover
* `cover_card_ge_quotient_card` — Lower bound: any cover has ≥ #classes elements
* `observerCoverCard_antitone` — The covering number is antitone in ε
* `observerCoverCard_constant_between_critical` — Covering number is locally constant
  away from critical distortion values
* `greedy_ultrametric_codebook_certified` — Certified greedy codebook algorithm

## Mathematical Significance

This is a **non-Archimedean rate–distortion theorem**: proof compression under bounded
observer loss is governed by an ultrametric congruence spectrum. The compression curve
is not a smooth optimization artifact but a step function whose jumps correspond to
structural changes in the observer congruence lattice.

## Cross-Domain Bridges

* **Proof theory ↔ Information theory**: observer congruence = quantitative contextual
  equivalence
* **Ultrametric geometry ↔ ML**: clustering in proof space = certified representation
  compression
* **Tropical algebra ↔ Coding theory**: max-plus distortion = tropical rate function
* **Algebraic geometry ↔ Compression**: congruence spectrum = semantic phase diagram
-/

open Finset Function

attribute [local instance] Classical.propDecidable

noncomputable section

namespace UltrametricObserver

/-! ## §1. Core Definitions -/

variable {P : Type*} [Fintype P] [DecidableEq P]

/-- **Ultrametric observer family**: a family of `n` observer distance functions,
each satisfying the ultrametric axioms (diagonal zero, symmetry, strong triangle
inequality). Each observer `O i` measures proof-state distinguishability from
a particular observational perspective.

Bridge: observers are quantitative analogues of contextual equivalence tests;
the family is an algebraic hash family for proof states. -/
structure IsUltrametricObserverFamily {n : ℕ} (O : Fin n → P → P → ENNReal) : Prop where
  /-- Each observer assigns zero distortion to identical states -/
  diag_zero : ∀ i x, O i x x = 0
  /-- Each observer is symmetric -/
  symm : ∀ i x y, O i x y = O i y x
  /-- Each observer satisfies the ultrametric (strong) triangle inequality -/
  ultra : ∀ i x y z, O i x z ≤ O i x y ⊔ O i y z

/-- **Observer distortion**: the maximum distortion across all observers.
This is the worst-case distinguishability — two proof states are ε-indistinguishable
only if every observer agrees they are within ε.

In tropical/max-plus language, this is the tropical norm of the observer vector. -/
def observerDistortion {n : ℕ} (O : Fin n → P → P → ENNReal) (p q : P) : ENNReal :=
  Finset.sup Finset.univ (fun i => O i p q)

/-- **Observer ε-congruence**: the relation identifying proof states that are
ε-indistinguishable to all observers. In the ultrametric setting, this is
a genuine equivalence relation (not just a tolerance relation). -/
def observerCongRel {n : ℕ} (O : Fin n → P → P → ENNReal) (ε : ENNReal)
    (p q : P) : Prop :=
  observerDistortion O p q ≤ ε

/-- **Observer ε-cover**: a codebook `C ⊆ P` such that every proof state is
within observer distortion ε of some codeword. This is a lossy semantic
codebook — it preserves observer-visible behavior up to threshold ε. -/
def ObserverCovers {n : ℕ} (O : Fin n → P → P → ENNReal) (ε : ENNReal)
    (C : Finset P) : Prop :=
  ∀ p : P, ∃ c ∈ C, observerDistortion O p c ≤ ε

/-! ## §2. Observer Distortion is Ultrametric -/

omit [Fintype P] [DecidableEq P] in
/-- The observer distortion is zero on the diagonal. -/
lemma observerDistortion_self {n : ℕ} {O : Fin n → P → P → ENNReal}
    (hO : IsUltrametricObserverFamily O) (x : P) :
    observerDistortion O x x = 0 := by
  unfold observerDistortion;
  simp +decide [ hO.diag_zero ]

omit [Fintype P] [DecidableEq P] in
/-- The observer distortion is symmetric. -/
lemma observerDistortion_symm {n : ℕ} {O : Fin n → P → P → ENNReal}
    (hO : IsUltrametricObserverFamily O) (x y : P) :
    observerDistortion O x y = observerDistortion O y x := by
  exact Finset.sup_congr rfl fun i _ => hO.symm i x y

omit [Fintype P] [DecidableEq P] in
/-
**Ultrametric inequality for observer distortion**: the sup of ultrametrics
is ultrametric. This is the key structural fact enabling the rate–distortion
theorem — it makes ε-indistinguishability transitive.
-/
lemma observerDistortion_ultra {n : ℕ} {O : Fin n → P → P → ENNReal}
    (hO : IsUltrametricObserverFamily O) (x y z : P) :
    observerDistortion O x z ≤ observerDistortion O x y ⊔ observerDistortion O y z := by
  refine' Finset.sup_le fun i _ => _;
  exact le_trans ( hO.ultra i x y z ) ( max_le_max ( Finset.le_sup ( f := fun i => O i x y ) ( Finset.mem_univ i ) ) ( Finset.le_sup ( f := fun i => O i y z ) ( Finset.mem_univ i ) ) )

/-! ## §3. Observer Congruence is an Equivalence Relation -/

omit [Fintype P] [DecidableEq P] in
lemma observerCongRel_refl {n : ℕ} {O : Fin n → P → P → ENNReal}
    (hO : IsUltrametricObserverFamily O) (ε : ENNReal) (x : P) :
    observerCongRel O ε x x := by
  unfold observerCongRel
  rw [observerDistortion_self hO]
  exact zero_le ε

omit [Fintype P] [DecidableEq P] in
lemma observerCongRel_symm {n : ℕ} {O : Fin n → P → P → ENNReal}
    (hO : IsUltrametricObserverFamily O) (ε : ENNReal) {x y : P}
    (h : observerCongRel O ε x y) : observerCongRel O ε y x := by
  unfold observerCongRel at *
  rwa [observerDistortion_symm hO]

omit [Fintype P] [DecidableEq P] in
lemma observerCongRel_trans {n : ℕ} {O : Fin n → P → P → ENNReal}
    (hO : IsUltrametricObserverFamily O) (ε : ENNReal) {x y z : P}
    (hxy : observerCongRel O ε x y) (hyz : observerCongRel O ε y z) :
    observerCongRel O ε x z := by
  unfold observerCongRel at *
  exact le_trans (observerDistortion_ultra hO x y z) (sup_le hxy hyz)

/-- **Observer congruence setoid**: at each scale ε, observer ε-congruence
is an equivalence relation on proof states. This is the fundamental
difference from general metric spaces, where ε-closeness is not transitive.
The ultrametric structure makes it transitive, yielding clean quotients. -/
def observerCongruence {n : ℕ} (O : Fin n → P → P → ENNReal)
    (hO : IsUltrametricObserverFamily O) (ε : ENNReal) : Setoid P where
  r := observerCongRel O ε
  iseqv := ⟨observerCongRel_refl hO ε,
            fun h => observerCongRel_symm hO ε h,
            fun h1 h2 => observerCongRel_trans hO ε h1 h2⟩

/-! ## §4. Cover ↔ Quotient Cardinality -/

/-
**Upper bound**: choosing one representative per congruence class yields
an ε-cover of optimal size. This is the constructive half of the main theorem.

Proof: Take C = {Quotient.out q | q : Quotient}. Then |C| = #classes (since
Quotient.out is injective). For any p, the representative Quotient.out ⟦p⟧
is in the same class as p, hence within distortion ε.
-/
theorem class_rep_gives_cover {n : ℕ} (O : Fin n → P → P → ENNReal)
    (hO : IsUltrametricObserverFamily O) (ε : ENNReal) :
    ∃ C : Finset P,
      C.card = Fintype.card (Quotient (observerCongruence O hO ε)) ∧
      ObserverCovers O ε C := by
  by_contra h_contra';
  push_neg at h_contra';
  apply h_contra';
  rw [ Finset.card_image_of_injective ];
  convert Finset.card_univ;
  convert Quotient.out_injective;
  intro p
  use Quotient.out (⟦p⟧ : Quotient (observerCongruence O hO ε));
  simp +decide [ observerCongruence ];
  have := Quotient.out_eq' ( ⟦p⟧ : Quotient ( observerCongruence O hO ε ) );
  rw [ Quotient.eq'' ] at this;
  exact observerCongRel_symm hO ε this

/-
**Lower bound**: any ε-cover must contain at least as many elements as
there are congruence classes. This follows because the quotient map restricted
to C must be surjective (each class has a covering element in C, which belongs
to that class), so |C| ≥ |image of C under quotient map| = #classes.

This is the information-theoretic half: you cannot compress below the
congruence index without exceeding the distortion threshold.
-/
omit [DecidableEq P] in
theorem cover_card_ge_quotient_card {n : ℕ} (O : Fin n → P → P → ENNReal)
    (hO : IsUltrametricObserverFamily O) (ε : ENNReal)
    (C : Finset P) (hC : ObserverCovers O ε C) :
    Fintype.card (Quotient (observerCongruence O hO ε)) ≤ C.card := by
  refine' le_trans _ ( Finset.card_le_card _ );
  rotate_left;
  exact C;
  · exact Finset.Subset.refl _;
  · -- Let $s$ be the setoid defined by the observer congruence.
    set s : Setoid P := observerCongruence O hO ε;
    -- Let $q : P → Quotient s$ be the quotient map.
    set q : P → Quotient s := fun p => Quotient.mk'' p;
    -- By definition of $q$, we know that for any $p \in P$, there exists $c \in C$ such that $q(p) = q(c)$.
    have h_q_surjective : ∀ p : P, ∃ c ∈ C, q p = q c := by
      intro p
      obtain ⟨c, hc⟩ := hC p
      use c;
      exact ⟨ hc.1, Quotient.sound hc.2 ⟩;
    have h_q_surjective : Set.range q ⊆ Set.image q C := by
      exact Set.range_subset_iff.2 fun p => by obtain ⟨ c, hc, hpc ⟩ := h_q_surjective p; exact ⟨ c, hc, hpc.symm ⟩ ;
    have h_q_surjective : Set.range q = Set.univ := by
      exact Set.eq_univ_of_forall fun x => by obtain ⟨ p, rfl ⟩ := Quotient.exists_rep x; exact Set.mem_range_self p;
    simp_all +decide;
    have h_q_surjective : Set.ncard (Set.image q C) ≤ Set.ncard (C : Set P) := by
      exact Set.ncard_image_le;
    convert h_q_surjective using 1;
    · rw [ ‹q '' ↑C = Set.univ›, Set.ncard_univ ];
      exact Fintype.card_eq_nat_card;
    · rw [ Set.ncard_coe_finset ]

/-! ## §5. Main Theorem -/

/-- **Non-Archimedean Observer Rate–Distortion Theorem** (finite case):

The minimal observer ε-cover cardinality equals the congruence index
(number of equivalence classes under observer ε-congruence).

This converts the optimization problem (find the smallest codebook) into
exact combinatorics (count equivalence classes). The proof combines:
- **Upper bound** (`class_rep_gives_cover`): quotient representatives form a cover
- **Lower bound** (`cover_card_ge_quotient_card`): any cover must intersect every class

This is the structural heart of non-Archimedean proof information theory:
proof compression is not an optimization problem but an algebraic invariant. -/
theorem finite_ultrametric_covering_number_eq_congruence_index
    {n : ℕ} (O : Fin n → P → P → ENNReal)
    (hO : IsUltrametricObserverFamily O) (ε : ENNReal) :
    (∃ C : Finset P,
      ObserverCovers O ε C ∧
      C.card = Fintype.card (Quotient (observerCongruence O hO ε))) ∧
    (∀ C : Finset P, ObserverCovers O ε C →
      Fintype.card (Quotient (observerCongruence O hO ε)) ≤ C.card) :=
  ⟨by obtain ⟨C, hcard, hcov⟩ := class_rep_gives_cover O hO ε
      exact ⟨C, hcov, hcard⟩,
   cover_card_ge_quotient_card O hO ε⟩

/-! ## §6. Covering Number Function and Monotonicity -/

/-- The observer covering number at scale ε: the number of congruence classes.
By the main theorem, this equals the minimal ε-cover cardinality. -/
def observerCoverCard {n : ℕ} (O : Fin n → P → P → ENNReal)
    (hO : IsUltrametricObserverFamily O) (ε : ENNReal) : ℕ :=
  Fintype.card (Quotient (observerCongruence O hO ε))

omit [Fintype P] [DecidableEq P] in
/-- Congruence refinement: smaller ε gives finer (more restrictive) congruence. -/
lemma observerCongRel_mono {n : ℕ} {O : Fin n → P → P → ENNReal}
    {ε₁ ε₂ : ENNReal} (hle : ε₁ ≤ ε₂)
    {x y : P} (h : observerCongRel O ε₁ x y) : observerCongRel O ε₂ x y :=
  le_trans h hle

/-
**Antitone covering number**: increasing ε makes the congruence coarser,
so there are fewer or equal classes. The covering number is antitone.

This is the fundamental monotonicity of the rate–distortion curve:
more distortion tolerance → fewer codebook entries needed.
-/
omit [DecidableEq P] in
theorem observerCoverCard_antitone {n : ℕ} (O : Fin n → P → P → ENNReal)
    (hO : IsUltrametricObserverFamily O) :
    Antitone (observerCoverCard O hO) := by
  intro ε₁ ε₂ hε;
  apply_rules [ Fintype.card_le_of_surjective ];
  swap;
  exact fun q => Quotient.map' id ( fun x y hxy => observerCongRel_mono hε hxy ) q;
  exact fun q => ⟨ Quotient.mk'' ( Quotient.out q ), by aesop ⟩

/-! ## §7. Critical Scales and Spectral Structure -/

/-- The set of critical scales: all pairwise observer distortion values.
The covering number can only change at these thresholds. This is a finite
set (since P is finite), giving the rate–distortion curve finitely many
breakpoints — the **compression spectrum**. -/
def criticalScales {n : ℕ} (O : Fin n → P → P → ENNReal) : Finset ENNReal :=
  (Finset.univ.product Finset.univ).image
    (fun pq : P × P => observerDistortion O pq.1 pq.2)

/-
**Locally constant off critical scales**: the covering number does not change
between consecutive critical values. This means the rate–distortion curve is a
step function with finitely many jumps — the **observer compression spectrum**.

Proof idea: if no pair (p,q) has observerDistortion O p q ∈ (ε₁, ε₂], then
the ε₁-congruence and ε₂-congruence coincide (same pairs are identified).
-/
omit [DecidableEq P] in
theorem observerCoverCard_constant_between_critical {n : ℕ}
    (O : Fin n → P → P → ENNReal)
    (hO : IsUltrametricObserverFamily O)
    (ε₁ ε₂ : ENNReal) (hle : ε₁ ≤ ε₂)
    (hno_critical : ∀ p q : P,
      ¬(ε₁ < observerDistortion O p q ∧ observerDistortion O p q ≤ ε₂)) :
    observerCoverCard O hO ε₁ = observerCoverCard O hO ε₂ := by
  -- Show that the two congruences are equal by showing they have the same relation.
  have h_congr_eq : observerCongruence O hO ε₁ = observerCongruence O hO ε₂ := by
    ext p q;
    exact ⟨ fun h => le_trans h hle, fun h => le_of_not_gt fun h' => hno_critical p q ⟨ h', h ⟩ ⟩;
  unfold observerCoverCard;
  rw [ h_congr_eq ]

/-! ## §8. Congruence Filtration Nesting -/

omit [Fintype P] [DecidableEq P] in
/-- The observer congruences form a nested filtration: finer at smaller ε,
coarser at larger ε. Formally, every ε₁-equivalent pair is also ε₂-equivalent
when ε₁ ≤ ε₂. This is the **ultrametric filtration** — the non-Archimedean
analogue of a Rips filtration in persistent homology. -/
theorem observerCongruence_nested {n : ℕ} (O : Fin n → P → P → ENNReal)
    (hO : IsUltrametricObserverFamily O)
    {ε₁ ε₂ : ENNReal} (hle : ε₁ ≤ ε₂) (x y : P)
    (h : (observerCongruence O hO ε₁).r x y) :
    (observerCongruence O hO ε₂).r x y :=
  observerCongRel_mono hle h

/-! ## §9. Greedy Codebook Algorithm -/

/-- Greedy codebook: one representative per congruence class. -/
def greedyObserverCodebook {n : ℕ} (O : Fin n → P → P → ENNReal)
    (hO : IsUltrametricObserverFamily O) (ε : ENNReal) : Finset P :=
  (Finset.univ : Finset (Quotient (observerCongruence O hO ε))).image Quotient.out

/-
**Certified greedy codebook theorem**: the greedy codebook is an optimal
ε-cover — it covers all proof states and has minimal cardinality.

This is the algorithmic version of the main theorem: not just existence
of an optimal codebook, but an explicit construction with a correctness
certificate.
-/
theorem greedy_ultrametric_codebook_certified {n : ℕ}
    (O : Fin n → P → P → ENNReal)
    (hO : IsUltrametricObserverFamily O) (ε : ENNReal) :
    let C := greedyObserverCodebook O hO ε
    ObserverCovers O ε C ∧
    C.card = observerCoverCard O hO ε := by
  unfold observerCoverCard greedyObserverCodebook;
  refine' ⟨ fun p => _, _ ⟩;
  · simp +decide [ observerCongruence ];
    refine' ⟨ Quotient.mk'' p, _ ⟩;
    have := Quotient.out_eq' ( Quotient.mk'' p : Quotient ( observerCongruence O hO ε ) );
    rw [ Quotient.eq'' ] at this;
    exact observerCongRel_symm hO ε this;
  · rw [ Finset.card_image_of_injective ];
    · rfl;
    · exact Quotient.out_injective

/-! ## §10. Observer Rate Function -/

/-- The observer rate function: the natural logarithm of the covering number.
This is the non-Archimedean analogue of the Shannon rate–distortion function. -/
def observerRateFunction {n : ℕ} (O : Fin n → P → P → ENNReal)
    (hO : IsUltrametricObserverFamily O) (ε : ENNReal) : ℝ :=
  Real.log (observerCoverCard O hO ε : ℝ)

/-
The rate function is antitone: more distortion tolerance → lower rate.
-/
omit [DecidableEq P] in
theorem observerRateFunction_antitone {n : ℕ} (O : Fin n → P → P → ENNReal)
    (hO : IsUltrametricObserverFamily O) :
    Antitone (observerRateFunction O hO) := by
  intro ε₁ ε₂ hle; exact (by
  -- The covering number is antitone, so observerCoverCard O hO ε₂ ≤ observerCoverCard O hO ε₁.
  have h_covering_antitone : observerCoverCard O hO ε₂ ≤ observerCoverCard O hO ε₁ := by
    exact observerCoverCard_antitone O hO hle
  generalize_proofs at *; (
  by_cases h : observerCoverCard O hO ε₂ = 0 <;> simp_all +decide [ observerRateFunction ];
  · exact Real.log_natCast_nonneg _;
  · exact Real.log_le_log ( Nat.cast_pos.mpr ( Nat.pos_of_ne_zero h ) ) ( Nat.cast_le.mpr h_covering_antitone )));

/-! ## §11. Rate–Distortion Existence Theorem -/

/-
**Full rate–distortion existence theorem**: there exists a rate function R
satisfying:
1. R is antitone (more tolerance → lower rate)
2. R equals log of the congruence index at every scale
3. R equals the infimum of log-cardinalities of ε-covers

This packages the main results into a single existence statement matching
the classical rate–distortion function interface.
-/
theorem finite_ultrametric_observer_rate_distortion_exists
    {n : ℕ} (O : Fin n → P → P → ENNReal)
    (hO : IsUltrametricObserverFamily O) :
    ∃ R : ENNReal → ℝ,
      Antitone R ∧
      (∀ ε, R ε = Real.log
        (Fintype.card (Quotient (observerCongruence O hO ε)) : ℝ)) ∧
      (∀ ε, ∃ C : Finset P, ObserverCovers O ε C ∧
        R ε = Real.log (C.card : ℝ)) := by
  refine' ⟨ _, _, fun ε => rfl, fun ε => _ ⟩;
  · convert observerRateFunction_antitone O hO using 1;
  · exact Exists.elim ( class_rep_gives_cover O hO ε ) fun C hC => ⟨ C, hC.2, by rw [ hC.1 ] ⟩

/-! ## §12. Bridge: Observer Separation -/

/-- Two proof states are observer-separated at scale ε if they are in distinct
congruence classes. -/
def ObserverSeparated {n : ℕ} (O : Fin n → P → P → ENNReal)
    (hO : IsUltrametricObserverFamily O) (ε : ENNReal) (x y : P) : Prop :=
  ¬(observerCongruence O hO ε).r x y

omit [Fintype P] [DecidableEq P] in
/-- Observer separation is equivalent to exceeding the distortion threshold. -/
lemma observerSeparated_iff {n : ℕ} (O : Fin n → P → P → ENNReal)
    (hO : IsUltrametricObserverFamily O) (ε : ENNReal) (x y : P) :
    ObserverSeparated O hO ε x y ↔ ε < observerDistortion O x y := by
  simp [ObserverSeparated, observerCongruence, observerCongRel, not_le]

omit [DecidableEq P] in
/-- **Covering number bounds codebook**: any valid ε-cover has cardinality
at least the covering number (the congruence index). -/
theorem observerCoverCard_le_card_of_covers {n : ℕ}
    (O : Fin n → P → P → ENNReal)
    (hO : IsUltrametricObserverFamily O) (ε : ENNReal)
    (C : Finset P) (hC : ObserverCovers O ε C) :
    observerCoverCard O hO ε ≤ C.card :=
  cover_card_ge_quotient_card O hO ε C hC

end UltrametricObserver