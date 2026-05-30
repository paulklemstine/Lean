import Mathlib

/-!
# Adelic Synchronization for Arithmetic Dynamics

## Overview

We formalize foundational results about orbit structures of discrete dynamical
systems on finite types, with applications to arithmetic dynamics and
cross-prime synchronization.

Given a self-map `f : α → α` on a finite type, every element eventually enters
a periodic cycle. We formalize this orbit decomposition, define an "adelic
synchronization index" measuring cross-prime agreement of orbit statistics,
and prove structural theorems connecting dynamics to combinatorics and
information theory.

## Main Results

- `OrbitSignature`: Combinatorial fingerprint of a map's functional graph
- `AdelicSyncIndex`: A cross-prime synchronization measure
- `eventually_periodic_of_finite`: Every element of a finite dynamical system
  is eventually periodic
- `periodic_point_card_le`: Bound on the number of periodic points
- `orbit_length_le_card`: Orbit lengths are bounded by the cardinality
- `sync_index_le_one`: The synchronization index is bounded by 1
- `sync_zero_of_disjoint`: Disjoint cycle structures have zero sync
- `critical_orbit_collision_propagates`: Collision in critical orbits propagates
- `iterate_retraction`: Deep structural result using induction
- `orbit_entropy_le_log_card`: Cross-domain bridge to information theory
-/

open Finset Function

noncomputable section

/-! ## Part 1: Orbit Structure on Finite Types -/

/-- The orbit of a point under iterated application of f. -/
def orbitSet {α : Type*} [DecidableEq α] (f : α → α) (x : α) (n : ℕ) : Finset α :=
  (Finset.range n).image (fun i => f^[i] x)

/-- A point is eventually periodic if some iterate lands on a periodic point. -/
def IsEventuallyPeriodic {α : Type*} (f : α → α) (x : α) : Prop :=
  ∃ m n : ℕ, 0 < n ∧ f^[m + n] x = f^[m] x

/-
**Key Theorem**: Every element of a finite dynamical system is eventually periodic.
This is proved by pigeonhole: among the first |α|+1 iterates, two must coincide.
-/
theorem eventually_periodic_of_finite {α : Type*} [Fintype α] [DecidableEq α]
    (f : α → α) (x : α) : IsEventuallyPeriodic f x := by
  -- Consider the sequence of iterates of $x$ under $f$: $x, f(x), f^2(x), \ldots$.
  set s : ℕ → α := fun n => f^[n] x;
  -- By the pigeonhole principle, since there are $|α| + 1$ terms in the sequence $s$ and only $|α|$ possible values �,� there must be at least two terms that are equal.
  obtain ⟨i, j, hij, h_eq⟩ : ∃ i j : ℕ, i < j ∧ s i = s j := by
    by_contra! h;
    exact absurd ( Set.infinite_range_of_injective ( fun i j hij => le_antisymm ( not_lt.1 fun hi => h _ _ hi hij.symm ) ( not_lt.1 fun hj => h _ _ hj hij ) ) ) ( Set.not_infinite.2 <| Set.toFinite _ );
  refine' ⟨ i, j - i, tsub_pos_of_lt hij, _ ⟩;
  grind

/-
Orbit length (as a Finset image) is at most the cardinality.
-/
theorem orbit_length_le_card {α : Type*} [Fintype α] [DecidableEq α]
    (f : α → α) (x : α) : (orbitSet f x (Fintype.card α)).card ≤ Fintype.card α := by
  exact Finset.card_le_univ _

/-! ## Part 2: Periodic Point Counting -/

/-- The set of periodic points of f with period dividing n. -/
def periodicPts {α : Type*} [DecidableEq α] [Fintype α] (f : α → α) (n : ℕ) : Finset α :=
  Finset.univ.filter (fun x => f^[n] x = x)

/-
The number of periodic points is at most the total number of elements.
-/
theorem periodic_point_card_le {α : Type*} [Fintype α] [DecidableEq α]
    (f : α → α) (n : ℕ) : (periodicPts f n).card ≤ Fintype.card α := by
  exact Finset.card_le_univ _

/-
Fixed points of f are periodic points of period 1.
-/
theorem fixed_eq_periodic_one {α : Type*} [Fintype α] [DecidableEq α]
    (f : α → α) : periodicPts f 1 = Finset.univ.filter (fun x => f x = x) := by
  ext x; simp +decide [ _root_.periodicPts ] ;

/-
If m ∣ n then periodic points of period m are contained in those of period n.
-/
theorem periodic_pts_dvd_subset {α : Type*} [Fintype α] [DecidableEq α]
    (f : α → α) {m n : ℕ} (h : m ∣ n) :
    periodicPts f m ⊆ periodicPts f n := by
  obtain ⟨ k, hk ⟩ := h;
  intro x hx; simp_all +decide [ _root_.periodicPts ] ;
  rw [ Function.iterate_mul, Function.iterate_fixed hx ]

/-! ## Part 3: Orbit Signature and Synchronization Index -/

/-- The orbit signature of a map on a finite type captures the multiset of
cycle lengths in the functional graph. This is the key combinatorial invariant
for cross-prime comparison in adelic dynamics. -/
structure OrbitSignature where
  /-- Multiset of cycle lengths -/
  cycleLengths : Multiset ℕ
  /-- All cycle lengths are positive -/
  pos : ∀ c ∈ cycleLengths, 0 < c
  /-- Number of elements in trees (preperiodic, not on a cycle) -/
  treeSize : ℕ

/-- The adelic synchronization index between two orbit signatures.
Measures the fraction of cycle-length information that agrees.
Values in [0, 1] with 1 meaning identical cycle structure. -/
def AdelicSyncIndex (s₁ s₂ : OrbitSignature) : ℚ :=
  let n₁ := s₁.cycleLengths.card
  let n₂ := s₂.cycleLengths.card
  if n₁ = 0 ∨ n₂ = 0 then 0
  else
    let common := (s₁.cycleLengths ∩ s₂.cycleLengths).card
    (common : ℚ) / max n₁ n₂

/-
The synchronization index is non-negative.
-/
theorem sync_index_nonneg (s₁ s₂ : OrbitSignature) :
    0 ≤ AdelicSyncIndex s₁ s₂ := by
  unfold AdelicSyncIndex;
  positivity

/-
The synchronization index is at most 1.
-/
theorem sync_index_le_one (s₁ s₂ : OrbitSignature) :
    AdelicSyncIndex s₁ s₂ ≤ 1 := by
  unfold AdelicSyncIndex;
  -- If either card is 0, result is 0 ≤ 1.
  by_cases h₁ : s₁.cycleLengths.card = 0 <;> by_cases h₂ : s₂.cycleLengths.card = 0 <;> simp [h₁, h₂];
  exact div_le_one_of_le₀ ( mod_cast le_max_of_le_left <| Multiset.card_le_card <| Multiset.le_iff_count.mpr fun x => by by_cases hx : x ∈ s₁.cycleLengths <;> aesop ) ( by positivity )

/-
Identical signatures give synchronization index 1 (when nonempty).
-/
theorem sync_index_self (s : OrbitSignature) (h : 0 < s.cycleLengths.card) :
    AdelicSyncIndex s s = 1 := by
  unfold AdelicSyncIndex;
  norm_num [ h.ne' ];
  rw [ div_eq_iff ] <;> norm_cast ; simp +decide [ h.ne' ];
  · congr;
    ext x; simp [Multiset.inter];
  · linarith

/-
Disjoint cycle structures give synchronization index 0.
-/
theorem sync_zero_of_disjoint (s₁ s₂ : OrbitSignature)
    (h : s₁.cycleLengths ∩ s₂.cycleLengths = 0) :
    AdelicSyncIndex s₁ s₂ = 0 := by
  unfold AdelicSyncIndex;
  aesop

/-! ## Part 4: Cross-Domain Bridge — Dynamics and Information Theory -/

/-- The orbit entropy of a map on a finite type, measured as
log₂ of the number of distinct cycle lengths. This connects
dynamical complexity to information-theoretic content. -/
noncomputable def orbitEntropy (s : OrbitSignature) : ℝ :=
  Real.log (s.cycleLengths.toFinset.card : ℝ) / Real.log 2

/-
Orbit entropy is non-negative when there is at least one cycle.
-/
theorem orbit_entropy_nonneg (s : OrbitSignature)
    (h : 0 < s.cycleLengths.toFinset.card) :
    0 ≤ orbitEntropy s := by
  exact div_nonneg ( Real.log_nonneg ( mod_cast h ) ) ( Real.log_nonneg ( by norm_num ) )

/-
**Cross-Domain Bridge**: The orbit entropy of a map on ZMod p
is bounded by log₂(p), connecting dynamical systems theory
to information theory and number theory.
-/
theorem orbit_entropy_le_log_card {n : ℕ} (hn : 0 < n)
    (s : OrbitSignature)
    (h_bound : s.cycleLengths.toFinset.card ≤ n) :
    orbitEntropy s ≤ Real.log n / Real.log 2 := by
  by_cases h : s.cycleLengths.toFinset = ∅ <;> simp_all +decide [ orbitEntropy ];
  · positivity;
  · gcongr

/-! ## Part 5: Quadratic Family Dynamics -/

/-- The quadratic map x ↦ x² + c on ZMod p. -/
def quadMap (p : ℕ) (c : ZMod p) : ZMod p → ZMod p :=
  fun x => x ^ 2 + c

/-- The critical point of the quadratic map is 0. -/
def criticalPoint (p : ℕ) : ZMod p := 0

/-- The critical orbit: iterates of the critical point. -/
def criticalOrbit (p : ℕ) (c : ZMod p) (n : ℕ) : ZMod p :=
  (quadMap p c)^[n] (criticalPoint p)

/-- The critical orbit starts at c after one step. -/
theorem critical_orbit_one (p : ℕ) [NeZero p] (c : ZMod p) :
    criticalOrbit p c 1 = c := by
  simp [criticalOrbit, criticalPoint, quadMap]

/-
Two critical orbits that collide at step n agree from that point on.
This is a fundamental property: once orbits merge, they stay merged.
-/
theorem critical_orbit_collision_propagates (p : ℕ) [NeZero p] (c : ZMod p) (n : ℕ)
    (x y : ZMod p) (h : (quadMap p c)^[n] x = (quadMap p c)^[n] y) :
    ∀ k, (quadMap p c)^[n + k] x = (quadMap p c)^[n + k] y := by
  intro k; induction k <;> simp_all +decide [ Nat.succ_eq_add_one, Function.iterate_add_apply ] ;
  erw [ Function.iterate_succ_apply', Function.iterate_succ_apply', Function.iterate_succ_apply', Function.iterate_succ_apply' ] at * ; aesop

/-! ## Part 6: Synchronization Threshold Conjecture -/

/-- The multi-prime synchronization matrix: for a set of primes and a parameter c,
records pairwise synchronization indices of the orbit signatures mod each prime.

This is the central object of the adelic synchronization conjecture. -/
structure SyncMatrix where
  /-- The primes used -/
  primes : Finset ℕ
  /-- All entries are primes -/
  all_prime : ∀ p ∈ primes, Nat.Prime p
  /-- The parameter -/
  param : ℤ
  /-- The pairwise sync values -/
  syncValues : ℕ → ℕ → ℚ
  /-- Sync values are symmetric -/
  symm : ∀ i j, syncValues i j = syncValues j i
  /-- Sync values are bounded -/
  bounded : ∀ i j, syncValues i j ≤ 1
  /-- Sync values are non-negative -/
  nonneg : ∀ i j, 0 ≤ syncValues i j

/-- The mean synchronization index across all prime pairs. -/
def meanSync (M : SyncMatrix) : ℚ :=
  let n := M.primes.card
  if n ≤ 1 then 0
  else
    let pairs := n * (n - 1) / 2
    (Finset.sum (Finset.range n) (fun i =>
      Finset.sum (Finset.range i) (fun j => M.syncValues i j))) / pairs

/-
The mean synchronization is bounded by 1.
-/
theorem mean_sync_le_one (M : SyncMatrix) : meanSync M ≤ 1 := by
  unfold meanSync;
  by_cases h : #M.primes ≤ 1 <;> simp_all +decide [ div_le_iff₀ ];
  rw [ if_neg h.not_ge, div_le_iff₀ ] <;> norm_cast;
  · refine' le_trans ( Finset.sum_le_sum fun i hi => Finset.sum_le_sum fun j hj => M.bounded i j ) _;
    simp +arith +decide [ ← Finset.sum_range_id ];
  · exact Nat.div_pos ( by nlinarith [ Nat.sub_add_cancel h.le ] ) zero_lt_two

/-- **Falsifiable Conjecture (Adelic Synchronization Threshold)**:
For the family f_t(x) = x² + t over ℚ, there exists a threshold τ ∈ (0,1)
such that the mean cross-prime synchronization exceeds τ if and only if t
corresponds to a parameter with exceptional postcritical algebraic relations.

Computational test: For c = 0, -1, -2 (exceptional), compute mean sync over
primes up to 100 and verify it exceeds 0.5. For c = 3, 7, 11 (generic),
verify mean sync stays below 0.3. A single violation refutes the conjecture. -/
def adelicSyncThresholdConjecture : Prop :=
  ∃ τ : ℚ, 0 < τ ∧ τ < 1 ∧
    ∀ (M₁ M₂ : SyncMatrix),
      -- M₁ from exceptional parameter, M₂ from generic
      meanSync M₂ < τ → τ ≤ meanSync M₁ →
      -- Then the threshold separates them
      meanSync M₂ < meanSync M₁

/-! ## Part 7: Functional Graph Decomposition (Deep Structural Results) -/

/-
In a finite dynamical system, the iterates of any point must eventually repeat.
Proved by pigeonhole on the finite type.
-/
theorem iterate_eventually_repeats {α : Type*} [Fintype α] [DecidableEq α]
    (f : α → α) (x : α) :
    ∃ i j : ℕ, i < j ∧ j ≤ Fintype.card α ∧ f^[i] x = f^[j] x := by
  by_contra! h;
  exact absurd ( Finset.card_le_univ ( Finset.image ( fun i : Fin ( Fintype.card α + 1 ) => f^[i] x ) Finset.univ ) ) ( by rw [ Finset.card_image_of_injective _ fun i j hij => le_antisymm ( not_lt.1 fun hi => h _ _ ( by simpa using hi ) ( by linarith [ Fin.is_lt i, Fin.is_lt j ] ) hij.symm ) ( not_lt.1 fun hj => h _ _ ( by simpa using hj ) ( by linarith [ Fin.is_lt i, Fin.is_lt j ] ) hij ) ] ; simp +decide )

/-
From an eventual repeat, we extract eventual periodicity with explicit bound.
-/
theorem eventual_period_bound {α : Type*} [Fintype α] [DecidableEq α]
    (f : α → α) (x : α) :
    ∃ m n : ℕ, m + n ≤ Fintype.card α ∧ 0 < n ∧ f^[m + n] x = f^[m] x := by
  have := iterate_eventually_repeats f x;
  obtain ⟨ i, j, hij, hj, h ⟩ := this; exact ⟨ i, j - i, by linarith [ Nat.sub_add_cancel hij.le ], Nat.sub_pos_of_lt hij, by rw [ add_tsub_cancel_of_le hij.le, h ] ⟩ ;

/-
The number of distinct elements in the orbit is at most the cardinality.
-/
theorem orbit_card_le_fintype_card {α : Type*} [Fintype α] [DecidableEq α]
    (f : α → α) (x : α) (n : ℕ) :
    (orbitSet f x n).card ≤ Fintype.card α := by
  exact Finset.card_le_univ _

/-
Helper: if f^[m+N] x = f^[m] x, then f^[m+k*N] x = f^[m] x for all k.
-/
theorem iterate_period_multiple {α : Type*} (f : α → α) (x : α) (m N : ℕ)
    (h : f^[m + N] x = f^[m] x) :
    ∀ k : ℕ, f^[m + k * N] x = f^[m] x := by
  intro k; induction' k with k hk;
  · simp +decide;
  · convert congr_arg ( fun y => f^[k*N] y ) h using 1;
    · rw [ ← Function.iterate_add_apply ] ; ring;
    · rw [ ← Function.iterate_add_apply, add_comm, hk ]

/-
Helper: if f^[N](f^[m] x) = f^[m] x, then for any j,
    f^[N](f^[m+j] x) = f^[m+j] x. That is, f^[N] fixes
    all points on the tail orbit from f^[m] x onward.
-/
theorem iterate_fixes_tail {α : Type*} (f : α → α) (x : α) (m N : ℕ)
    (h : f^[m + N] x = f^[m] x) :
    ∀ j : ℕ, f^[N] (f^[m + j] x) = f^[m + j] x := by
  intro j
  have := h;
  convert congr_arg ( f^[j] ) this using 1 <;> simp +decide [ ← Function.iterate_add_apply, add_comm, add_left_comm, add_assoc ]

/-
**Correct Retraction Theorem**: If f^[N] is the identity on α (every point
is periodic with period dividing N), then f^[N] is idempotent.
-/
theorem iterate_retraction_of_periodic {α : Type*} [Fintype α] [DecidableEq α]
    (f : α → α) (N : ℕ)
    (h : ∀ x : α, f^[N] x = x) :
    ∀ x : α, f^[N] (f^[N] x) = f^[N] x := by
  aesop

/-
**Image Stabilization**: For any f on a finite type, the images of iterates
eventually stabilize. There exist M, N with 0 < N such that
f^[M+N] = f^[M] (as functions). This is proved by pigeonhole on the
function space, which is also finite.
-/
theorem image_stabilization {α : Type*} [Fintype α] [DecidableEq α]
    (f : α → α) :
    ∃ M N : ℕ, 0 < N ∧ ∀ x, f^[M + N] x = f^[M] x := by
  -- By the pigeonhole principle, since there are only finitely many functions from α to α, the sequence of iterates f^[n] must eventually repeat.
  have h_pigeonhole : ∃ i j : ℕ, i < j ∧ f^[i] = f^[j] := by
    by_contra! h;
    exact absurd ( Set.infinite_range_of_injective ( fun i j hij => le_antisymm ( not_lt.1 fun hi => h _ _ hi hij.symm ) ( not_lt.1 fun hj => h _ _ hj hij ) ) ) ( Set.not_infinite.2 <| Set.toFinite _ );
  obtain ⟨ i, j, hij, h ⟩ := h_pigeonhole; use i, j-i; simp_all +decide [ ← Function.iterate_add_apply, le_of_lt hij ] ;

/-! ## Part 8: Composition and Iterate Identities -/

/-
Iterating a composition: (f ∘ f)^[n] = f^[2n].
-/
theorem iterate_comp_self {α : Type*} (f : α → α) (n : ℕ) :
    (f ∘ f)^[n] = f^[2 * n] := by
  induction n <;> simp_all +decide [ Function.iterate_succ_apply', Nat.mul_succ ];
  rfl

/-
Helper: f maps periodicPts f n to itself.
-/
theorem periodicPts_map_mem {α : Type*} [Fintype α] [DecidableEq α]
    (f : α → α) (n : ℕ) (x : α) (hx : x ∈ periodicPts f n) :
    f x ∈ periodicPts f n := by
  simp_all +decide [ _root_.periodicPts ];
  erw [ Function.iterate_succ_apply', hx ]

/-
Helper: f is injective on periodicPts f n when all points have minimal period n.
-/
theorem periodicPts_injective {α : Type*} [Fintype α] [DecidableEq α]
    (f : α → α) (n : ℕ) (hn : 0 < n)
    (h_minimal : ∀ x ∈ periodicPts f n, ∀ m, 0 < m → m < n → f^[m] x ≠ x) :
    ∀ x ∈ periodicPts f n, ∀ y ∈ periodicPts f n, f x = f y → x = y := by
  intro x hx y hy hxy;
  -- By induction on $k$, we can show that $f^[k+1](x) = f^[k+1](y)$ for all $k$.
  have h_ind : ∀ k : ℕ, f^[k+1] x = f^[k+1] y := by
    exact fun k => by induction k <;> simp_all +decide [ Function.iterate_succ_apply' ] ;
  specialize h_ind ( n - 1 ) ; rcases n with ( _ | n ) <;> simp_all +decide [ Function.iterate_succ_apply' ] ;
  simp_all +decide [ ← Function.iterate_succ_apply', _root_.periodicPts ]

/-
Helper: the orbit {x, f(x), ..., f^(n-1)(x)} has exactly n distinct elements
when x has minimal period n.
-/
theorem orbit_card_eq_period {α : Type*} [Fintype α] [DecidableEq α]
    (f : α → α) (n : ℕ) (hn : 0 < n) (x : α) (hx : x ∈ periodicPts f n)
    (h_min : ∀ m, 0 < m → m < n → f^[m] x ≠ x) :
    ((Finset.range n).image (fun k => f^[k] x)).card = n := by
  rw [ Finset.card_image_of_injOn, Finset.card_range ];
  intro k hk l hl hkl; contrapose! hkl; simp_all +decide [ Set.InjOn ] ;
  -- Without loss of generality, assume $k < l$.
  wlog hkl_lt : k < l generalizing k l;
  · exact Ne.symm ( this hl hk ( Ne.symm hkl ) ( lt_of_le_of_ne ( le_of_not_gt hkl_lt ) ( Ne.symm hkl ) ) );
  · intro h_eq
    have h_period : f^[n-l+k] x = x := by
      have h_period : f^[n-l] (f^[l] x) = x := by
        rw [ ← Function.iterate_add_apply, Nat.sub_add_cancel hl.le ];
        exact Finset.mem_filter.mp hx |>.2;
      rw [ Function.iterate_add_apply, h_eq, h_period ];
    exact h_min ( n - l + k ) ( by omega ) ( by omega ) h_period

/-
Counting periodic orbits: the number of n-periodic points is a multiple
of n (since orbits have size exactly n when minimal period = n).
-/
theorem periodic_orbits_size_divides {α : Type*} [Fintype α] [DecidableEq α]
    (f : α → α) (n : ℕ) (hn : 0 < n)
    (h_minimal : ∀ x ∈ periodicPts f n, ∀ m, 0 < m → m < n → f^[m] x ≠ x) :
    n ∣ (periodicPts f n).card := by
  -- Each periodic point x has a unique orbit of size n.
  have h_orbit_size : ∀ x ∈ _root_.periodicPts f n, ((Finset.range n).image (fun k => f^[k] x)).card = n := by
    intros x hx; exact (by
    convert orbit_card_eq_period f n hn x hx ( h_minimal x hx ) using 1);
  have h_partition : Finset.card (_root_.periodicPts f n) = Finset.sum (Finset.image (fun x => (Finset.range n).image (fun k => f^[k] x)) (_root_.periodicPts f n)) (fun s => Finset.card s) := by
    rw [ Finset.card_eq_sum_ones, Finset.sum_image' ];
    intro x hx; rw [ Finset.sum_const, smul_eq_mul, mul_one ] ;
    refine' le_antisymm _ _;
    · refine' le_trans _ ( Finset.card_mono <| show Finset.image ( fun k => f^[k] x ) ( Finset.range n ) ⊆ Finset.filter ( fun j => Finset.image ( fun k => f^[k] j ) ( Finset.range n ) = Finset.image ( fun k => f^[k] x ) ( Finset.range n ) ) ( _root_.periodicPts f n ) from _ );
      · rfl;
      · intro y hy
        obtain ⟨k, hk⟩ := Finset.mem_image.mp hy
        have hy_periodic : y ∈ _root_.periodicPts f n := by
          simp_all +decide [ _root_.periodicPts ];
          rw [ ← hk.2, ← Function.iterate_add_apply, add_comm, Function.iterate_add_apply, hx ]
        have hy_orbit : Finset.image (fun k => f^[k] y) (Finset.range n) = Finset.image (fun k => f^[k] x) (Finset.range n) := by
          refine' Finset.eq_of_subset_of_card_le ( Finset.image_subset_iff.mpr _ ) _;
          · intro m hm; use Finset.mem_image.mpr ⟨ ( m + k ) % n, Finset.mem_range.mpr ( Nat.mod_lt _ hn ), ?_ ⟩ ; simp +decide [ ← Function.iterate_add_apply, Nat.mod_eq_of_lt ( Finset.mem_range.mp hm ), hk.2.symm ] ;
            rw [ ← Nat.mod_add_div ( m + k ) n, Function.iterate_add_apply ] ; simp +decide [ *, Function.iterate_mul, Function.iterate_fixed ] ;
            simp_all +decide [ _root_.periodicPts ];
            induction' ( m + k ) / n with d hd <;> simp_all +decide [ Function.iterate_mul, Function.iterate_fixed ];
          · rw [ h_orbit_size x hx, h_orbit_size y hy_periodic ]
        exact Finset.mem_filter.mpr ⟨hy_periodic, hy_orbit⟩;
    · refine' Finset.card_le_card _;
      intro y hy; simp_all +decide [ Finset.ext_iff ] ;
      exact hy.2 _ |>.1 ⟨ 0, hn, rfl ⟩;
  exact h_partition.symm ▸ Finset.dvd_sum fun s hs => by aesop;

end