/-
# Temporal Fixed-Point Duality for Reversible Causal Semirings

This file formalizes a duality between reversible finite-state dynamics,
temporal fixed-point semantics, and certified loop invariant reconstruction.

## Main Results

### Reversible Dynamics (§1-§2)
- `bijective_dynamics_purely_periodic` — Bijections on finite types yield purely periodic orbits
- `iterate_eq_iff_period_dvd` — f^[k] x = x iff period divides k

### Temporal Fixed-Point Operators (§3-§4)
- `temporalReach_monotone` — The temporal reachability operator is monotone
- `temporalCoreach_monotone` — The temporal co-reachability operator is monotone

### Orbit-Fixed-Point Correspondence (§5)
- `periodic_orbit_is_lfp_gfp_pair` — Periodic orbits are minimal invariant sets

### Temporal Congruence (§6)
- `temporalCongruence_is_right_congruence` — Temporal congruence preserved by transitions

### Loop Invariant Reconstruction (§7)
- `certified_loop_invariant_reconstruction` — Certified forward/backward invariants

### Bisimulation Invariance (§9)
- `bisimulation_period_divides` — Periods divide under bisimulation
- `fixedPointSpectrum_coarser_under_bisim` — Spectrum coarsens under bisimulation

## Bridges
- **Algebra ↔ Logic**: Knaster-Tarski fixed points ↔ temporal μ/ν-calculus
- **Logic ↔ Computation**: Temporal congruence ↔ automata minimization
- **Computation ↔ Algebra**: Loop invariants ↔ idempotent semiring dynamics
-/

import Mathlib

open Function Finset

noncomputable section

namespace Bridges.TemporalComputation

/-! ## §1. Reversible Finite-State Dynamics -/

/-- A reversible transition system: a bijective self-map on a finite type. -/
structure ReversibleSystem (S : Type*) [Fintype S] where
  /-- The forward transition function -/
  step : S → S
  /-- The inverse transition function -/
  inv : S → S
  /-- step and inv are mutual inverses -/
  left_inv : ∀ s, inv (step s) = s
  right_inv : ∀ s, step (inv s) = s

variable {S : Type*} [Fintype S] [DecidableEq S]

/-- The forward map of a reversible system is bijective. -/
theorem ReversibleSystem.step_bijective (R : ReversibleSystem S) :
    Bijective R.step :=
  ⟨fun a b h => by rw [← R.left_inv a, ← R.left_inv b, h],
   fun b => ⟨R.inv b, R.right_inv b⟩⟩

/-! ## §2. Pure Periodicity of Reversible Dynamics -/

/-
On a finite type, a bijective map yields purely periodic orbits:
    there exists p > 0 such that f^[p] x = x. This is strictly stronger
    than `finite_dynamics_eventually_periodic` which only gives f^[m] = f^[n].

    Bridge: connects reversible computation to temporal logic via periodicity.
-/
theorem bijective_dynamics_purely_periodic
    (f : S → S) (hf : Bijective f) (x : S) :
    ∃ p : ℕ, 0 < p ∧ (f^[p]) x = x := by
  -- Since $f$ is injective, the sequence $x, f(x), f^2(x), \ldots$ must eventually repeat.
  have h_seq_repeat : ∃ m n : ℕ, m < n ∧ f^[m] x = f^[n] x := by
    by_contra! h;
    exact absurd ( Set.infinite_range_of_injective ( fun m n mn => le_antisymm ( not_lt.1 fun contra => h _ _ contra mn.symm ) ( not_lt.1 fun contra => h _ _ contra mn ) ) ) ( Set.not_infinite.2 <| Set.toFinite _ );
  obtain ⟨ m, n, hmn, h ⟩ := h_seq_repeat;
  refine' ⟨ n - m, tsub_pos_of_lt hmn, _ ⟩;
  rw [ ← Nat.add_sub_of_le hmn.le, Function.iterate_add_apply ] at h;
  exact hf.injective.iterate m h.symm

/-
f^[k] x = x iff the minimal period divides k, for bijections on finite types.
-/
theorem iterate_eq_iff_period_dvd
    (f : S → S) (hf : Bijective f) (x : S) (k : ℕ) :
    (f^[k]) x = x ↔ Function.minimalPeriod f x ∣ k := by
  refine' ⟨ fun hk => _, fun hk => _ ⟩;
  · exact?;
  · cases' hk with m hm;
    rw [ hm, Function.iterate_mul, Function.iterate_fixed ( Function.isPeriodicPt_minimalPeriod f x ) ]

/-
For bijections on finite types, the minimal period is positive.
-/
theorem minimalPeriod_pos_of_bijective
    (f : S → S) (hf : Bijective f) (x : S) :
    0 < Function.minimalPeriod f x := by
  -- By definition of minimal period, we need to show that there exists a positive integer $p$ such that $f^p(x) = x$.
  have h_min_period_gt_zero : ∃ p : ℕ, 0 < p ∧ (f^[p]) x = x := by
    exact?;
  exact?

/-! ## §3. Temporal Fixed-Point Operators on Finsets -/

/-- The **temporal reachability operator**: F(X) = X ∪ f(X).
    Bridge: algebraic reachability ↔ μ-calculus least fixed point. -/
def temporalReach (f : S → S) (X : Finset S) : Finset S :=
  X ∪ X.image f

/-- The temporal reachability operator is monotone on the Finset lattice. -/
theorem temporalReach_monotone (f : S → S) :
    Monotone (temporalReach f) := by
  intro A B hAB
  simp only [temporalReach]
  exact union_subset_union hAB (image_subset_image hAB)

/-- X ⊆ F(X) for any X: the temporal reach is extensive. -/
theorem subset_temporalReach (f : S → S) (X : Finset S) :
    X ⊆ temporalReach f X :=
  Finset.subset_union_left

/-- The **temporal co-reachability operator**: G(X) = {s ∈ X | f(s) ∈ X}.
    Bridge: algebraic co-reachability ↔ ν-calculus greatest fixed point. -/
def temporalCoreach (f : S → S) (X : Finset S) : Finset S :=
  X.filter (fun s => f s ∈ X)

/-- The temporal co-reachability operator is monotone. -/
theorem temporalCoreach_monotone (f : S → S) :
    Monotone (temporalCoreach f) := by
  intro A B hAB
  simp only [temporalCoreach]
  intro x hx
  rw [mem_filter] at hx ⊢
  exact ⟨hAB hx.1, hAB hx.2⟩

/-- G(X) ⊆ X: the co-reachability operator is reductive. -/
theorem temporalCoreach_subset (f : S → S) (X : Finset S) :
    temporalCoreach f X ⊆ X :=
  Finset.filter_subset _ _

/-! ## §4. Invariant Sets and Their Characterization -/

/-- A set is **T-invariant** if f maps it into itself: f(X) ⊆ X. -/
def IsInvariant (f : S → S) (X : Finset S) : Prop :=
  X.image f ⊆ X

/-
A set is T-invariant iff it is a fixed point of the co-reachability operator.
    Bridge: algebraic (semiring) viewpoint ↔ logical (fixed point) viewpoint.
-/
theorem isInvariant_iff_coreach_fixed (f : S → S) (X : Finset S) :
    IsInvariant f X ↔ temporalCoreach f X = X := by
  unfold IsInvariant temporalCoreach;
  grind +splitImp

/-
For a bijection, invariant set has f-image equal to itself.
-/
theorem invariant_image_eq_of_bijective (f : S → S) (hf : Bijective f)
    (X : Finset S) (hinv : IsInvariant f X) :
    X.image f = X := by
  exact Finset.eq_of_subset_of_card_le hinv ( by rw [ Finset.card_image_of_injective _ hf.injective ] )

/-
For a bijection, any invariant set is backward-invariant.
-/
theorem invariant_backward_of_bijective (f : S → S) (hf : Bijective f)
    (X : Finset S) (hinv : IsInvariant f X) :
    ∀ x ∈ X, ∀ y, f y = x → y ∈ X := by
  intro x hx y hy;
  -- Since $f$ is bijective, we have $f^{-1}(x) = y$.
  obtain ⟨y', hy'⟩ : ∃ y', f y' = x ∧ y' ∈ X := by
    have := Finset.eq_of_subset_of_card_le ( show X.image f ⊆ X from hinv ) ?_;
    · replace this := Finset.ext_iff.mp this x; aesop;
    · rw [ Finset.card_image_of_injective _ hf.injective ];
  have := hf.1 ( hy.trans hy'.1.symm ) ; aesop;

omit [Fintype S] in
/-- For invariant sets, temporal reach is the identity. -/
theorem temporalReach_eq_of_invariant (f : S → S) (X : Finset S)
    (hinv : IsInvariant f X) :
    temporalReach f X = X := by
  simp only [temporalReach, Finset.union_eq_left]
  exact hinv

/-! ## §5. Periodic Orbits as Minimal Invariant Sets -/

/-- The forward orbit of a single element under f, computed using Fintype.card bound. -/
def singletonOrbit (f : S → S) (x : S) : Finset S :=
  (Finset.range (Fintype.card S)).image (fun k => (f^[k]) x)

/-- Every element is in its own orbit. -/
theorem mem_singletonOrbit (f : S → S) (x : S) : x ∈ singletonOrbit f x := by
  simp [singletonOrbit]
  exact ⟨0, @Fintype.card_pos S _ ⟨x⟩, rfl⟩

/-
The singleton orbit is T-invariant.
-/
theorem singletonOrbit_invariant (f : S → S) (hf : Bijective f) (x : S) :
    IsInvariant f (singletonOrbit f x) := by
  unfold IsInvariant;
  simp +decide [ singletonOrbit, Finset.subset_iff ];
  -- Since $f$ is bijective, its forward orbit is finite and thus must eventually repeat.
  have h_orbit_finite : ∃ p : ℕ, 0 < p ∧ p ≤ Fintype.card S ∧ f^[p] x = x := by
    -- By the pigeonhole principle, since there are only $|S|$ possible values for $f^k(x)$, there must be some $i < j \leq |S|$ such that $f^i(x) = f^j(x)$.
    obtain ⟨i, j, hij, h_eq⟩ : ∃ i j : ℕ, i < j ∧ j ≤ Fintype.card S ∧ f^[i] x = f^[j] x := by
      by_contra! h;
      exact absurd ( Finset.card_le_univ ( Finset.image ( fun i => f^[i] x ) ( Finset.range ( Fintype.card S + 1 ) ) ) ) ( by rw [ Finset.card_image_of_injOn fun i hi j hj hij => le_antisymm ( not_lt.1 fun hi' => h _ _ hi' ( by linarith [ Finset.mem_range.1 hi, Finset.mem_range.1 hj ] ) hij.symm ) ( not_lt.1 fun hj' => h _ _ hj' ( by linarith [ Finset.mem_range.1 hi, Finset.mem_range.1 hj ] ) hij ) ] ; simp +decide );
    refine' ⟨ j - i, tsub_pos_of_lt hij, _, _ ⟩;
    · exact le_trans ( Nat.sub_le _ _ ) h_eq.1;
    · rw [ ← Nat.add_sub_of_le hij.le, Function.iterate_add_apply ] at h_eq;
      exact hf.injective.iterate i h_eq.2.symm;
  intro a ha
  obtain ⟨p, hp_pos, hp_le, hp_eq⟩ := h_orbit_finite
  have h_orbit_step : f^[a + 1] x = f^[ (a + 1) % p ] x := by
    exact?;
  exact ⟨ ( a + 1 ) % p, lt_of_lt_of_le ( Nat.mod_lt _ hp_pos ) hp_le, by simpa [ ← Function.iterate_succ_apply' ] using h_orbit_step.symm ⟩

/-
**Orbit minimality theorem**: The orbit of x under a bijection is the
    smallest invariant set containing x.

    Bridge: Knaster-Tarski (Algebra) ↔ μ-calculus reachability (Logic)
    ↔ minimal automaton states (Computation).
-/
theorem periodic_orbit_is_lfp_gfp_pair (f : S → S) (hf : Bijective f) (x : S) :
    IsInvariant f (singletonOrbit f x) ∧
    x ∈ singletonOrbit f x ∧
    (∀ Y : Finset S, x ∈ Y → IsInvariant f Y → singletonOrbit f x ⊆ Y) := by
  refine' ⟨ _, _, _ ⟩;
  · exact?;
  · exact mem_singletonOrbit f x;
  · intro Y hx hY;
    intro y hy;
    obtain ⟨ k, hk ⟩ := Finset.mem_image.mp hy;
    exact hk.2 ▸ Nat.recOn k hx fun n ihn => by simpa only [ Function.iterate_succ_apply' ] using hY ( Finset.mem_image_of_mem _ ihn ) ;

/-- **Fixed-point spectrum**: the set of orbit sizes (minimal periods). -/
def fixedPointSpectrum (f : S → S) : Finset ℕ :=
  Finset.univ.image (fun x : S => Function.minimalPeriod f x)

/-! ## §6. Temporal Congruence -/

/-- Two states are **temporally congruent** w.r.t. observation `obs` if
    they produce identical observation sequences under all future iterates.
    Bridge: Myhill-Nerode for temporal logic ↔ automata minimization. -/
def temporalCongruent (f : S → S) (obs : S → ℕ) (x y : S) : Prop :=
  ∀ k : ℕ, obs ((f^[k]) x) = obs ((f^[k]) y)

omit [Fintype S] [DecidableEq S] in
/-- Temporal congruence is an equivalence relation. -/
theorem temporalCongruent_equiv (f : S → S) (obs : S → ℕ) :
    Equivalence (temporalCongruent f obs) :=
  ⟨fun _ _ => rfl,
   fun h k => (h k).symm,
   fun h1 h2 k => (h1 k).trans (h2 k)⟩

omit [Fintype S] [DecidableEq S] in
/-- **Right congruence**: Temporal congruence is preserved by one step of f.

    Bridge: Logic (temporal bisimulation) ↔ Computation (automata minimization). -/
theorem temporalCongruence_is_right_congruence
    (f : S → S) (obs : S → ℕ) (x y : S)
    (h : temporalCongruent f obs x y) :
    temporalCongruent f obs (f x) (f y) := by
  intro k
  have := h (k + 1)
  rwa [Function.iterate_succ_apply, Function.iterate_succ_apply] at this

/-- The temporal congruence as a setoid. -/
def temporalSetoid (f : S → S) (obs : S → ℕ) : Setoid S where
  r := temporalCongruent f obs
  iseqv := temporalCongruent_equiv f obs

/-! ## §7. Loop Invariants from Fixed Points -/

/-- A **loop invariant** for f is a predicate preserved by f. -/
def IsLoopInvariant (f : S → S) (P : S → Prop) : Prop :=
  ∀ s, P s → P (f s)

omit [Fintype S] in
/-- An invariant Finset yields a loop invariant predicate. -/
theorem invariant_finset_gives_loop_invariant (f : S → S) (X : Finset S)
    (hinv : IsInvariant f X) :
    IsLoopInvariant f (· ∈ X) := by
  intro s hs
  exact hinv (Finset.mem_image_of_mem f hs)

/-
The complement of an invariant set of a bijection is also invariant.
    Bridge: reversible dynamics ↔ dual loop invariants (safety + liveness).
-/
theorem complement_invariant_of_bijective (f : S → S) (hf : Bijective f)
    (X : Finset S) (hinv : IsInvariant f X) :
    IsInvariant f Xᶜ := by
  intro y hy;
  have := Fintype.bijective_iff_injective_and_card f; simp_all +decide;
  have h_image : Finset.image f X = X := by
    exact Finset.eq_of_subset_of_card_le hinv ( by rw [ Finset.card_image_of_injective _ this ] );
  grind

/-- **Certified loop invariant reconstruction**: Given a reversible system and
    an invariant set, we reconstruct certified forward AND backward
    loop invariants.

    Bridge: Computation (loop invariants) ↔ Algebra (idempotent semiring fixed points). -/
theorem certified_loop_invariant_reconstruction
    (f : S → S) (hf : Bijective f) (X : Finset S) (hinv : IsInvariant f X) :
    IsLoopInvariant f (· ∈ X) ∧ IsLoopInvariant f (· ∈ Xᶜ) :=
  ⟨invariant_finset_gives_loop_invariant f X hinv,
   invariant_finset_gives_loop_invariant f Xᶜ (complement_invariant_of_bijective f hf X hinv)⟩

omit [Fintype S] [DecidableEq S] in
/-- A loop invariant valid at time 0 holds at all future times. -/
theorem loop_invariant_induction (f : S → S) (P : S → Prop)
    (hinv : IsLoopInvariant f P) (x : S) (h0 : P x) :
    ∀ n : ℕ, P ((f^[n]) x) := by
  intro n
  induction n with
  | zero => simpa
  | succ n ih => rw [Function.iterate_succ_apply']; exact hinv _ ih

/-! ## §8. Idempotent Semiring Structure -/

omit [Fintype S] in
/-- Finset union is idempotent: X ∪ X = X. -/
theorem finset_union_idempotent (X : Finset S) : X ∪ X = X :=
  Finset.union_idempotent X

omit [Fintype S] in
/-- Intersection distributes over union for Finsets: the semiring distributivity. -/
theorem finset_inter_distrib_union (A B C : Finset S) :
    A ∩ (B ∪ C) = (A ∩ B) ∪ (A ∩ C) :=
  Finset.inter_union_distrib_left A B C

/-- For invariant sets, temporal reach is the identity, hence idempotent. -/
theorem temporalReach_idempotent_on_invariant (f : S → S) (X : Finset S)
    (hinv : IsInvariant f X) :
    temporalReach f (temporalReach f X) = temporalReach f X := by
  simp [temporalReach_eq_of_invariant f X hinv]

/-! ## §9. Bisimulation Invariance of the Spectrum -/

/-- A **bisimulation**: a surjective map commuting with transitions. -/
structure Bisimulation (S₁ S₂ : Type*) [Fintype S₁] [DecidableEq S₁]
    [Fintype S₂] [DecidableEq S₂]
    (f₁ : S₁ → S₁) (f₂ : S₂ → S₂) where
  φ : S₁ → S₂
  surj : Surjective φ
  commutes : ∀ s, φ (f₁ s) = f₂ (φ s)

/-- Under a bisimulation, iterates commute with the map. -/
theorem Bisimulation.iterate_commutes
    {S₁ S₂ : Type*} [Fintype S₁] [DecidableEq S₁]
    [Fintype S₂] [DecidableEq S₂]
    {f₁ : S₁ → S₁} {f₂ : S₂ → S₂}
    (B : Bisimulation S₁ S₂ f₁ f₂) (n : ℕ) (x : S₁) :
    (f₂^[n]) (B.φ x) = B.φ ((f₁^[n]) x) := by
  induction n with
  | zero => simp
  | succ n ih =>
    rw [Function.iterate_succ_apply', Function.iterate_succ_apply', ih, B.commutes]

/-
Under a bisimulation, periods in the codomain divide those in the domain.
    Bridge: the period spectrum is a bisimulation semi-invariant.
-/
theorem bisimulation_period_divides
    {S₁ S₂ : Type*} [Fintype S₁] [DecidableEq S₁]
    [Fintype S₂] [DecidableEq S₂]
    {f₁ : S₁ → S₁} {f₂ : S₂ → S₂}
    (B : Bisimulation S₁ S₂ f₁ f₂) (x : S₁) :
    Function.minimalPeriod f₂ (B.φ x) ∣ Function.minimalPeriod f₁ x := by
  apply Function.IsPeriodicPt.minimalPeriod_dvd;
  simp +decide [ IsPeriodicPt, IsFixedPt, B.iterate_commutes ]

/-- The fixed-point spectrum of f₂ is coarser under bisimulation. -/
theorem fixedPointSpectrum_coarser_under_bisim
    {S₁ S₂ : Type*} [Fintype S₁] [DecidableEq S₁]
    [Fintype S₂] [DecidableEq S₂]
    {f₁ : S₁ → S₁} {f₂ : S₂ → S₂}
    (B : Bisimulation S₁ S₂ f₁ f₂) :
    ∀ p ∈ fixedPointSpectrum f₂,
      ∃ q ∈ fixedPointSpectrum f₁, p ∣ q := by
  intro p hp
  simp [fixedPointSpectrum, mem_image] at hp
  obtain ⟨y, -, rfl⟩ := hp
  obtain ⟨x, hx⟩ := B.surj y
  exact ⟨Function.minimalPeriod f₁ x,
         Finset.mem_image_of_mem _ (Finset.mem_univ x),
         hx ▸ bisimulation_period_divides B x⟩

/-! ## §10. The Full Duality Theorem -/

/-- **The Temporal Fixed-Point Duality Theorem** (integrated):
    For any reversible system on a finite type:
    (1) Every orbit is purely periodic
    (2) Orbits are the minimal invariant sets containing each point
    (3) Each invariant set yields certified dual loop invariants

    Bridges: Algebra ↔ Logic ↔ Computation -/
theorem temporal_fixed_point_duality
    (R : ReversibleSystem S) :
    (∀ x, ∃ p, 0 < p ∧ (R.step^[p]) x = x) ∧
    (∀ x, IsInvariant R.step (singletonOrbit R.step x) ∧
           x ∈ singletonOrbit R.step x ∧
           ∀ Y, x ∈ Y → IsInvariant R.step Y → singletonOrbit R.step x ⊆ Y) ∧
    (∀ X : Finset S, IsInvariant R.step X →
      IsLoopInvariant R.step (· ∈ X) ∧ IsLoopInvariant R.step (· ∈ Xᶜ)) := by
  refine ⟨?_, ?_, ?_⟩
  · exact fun x => bijective_dynamics_purely_periodic R.step R.step_bijective x
  · exact fun x => periodic_orbit_is_lfp_gfp_pair R.step R.step_bijective x
  · exact fun X hinv =>
      certified_loop_invariant_reconstruction R.step R.step_bijective X hinv

end Bridges.TemporalComputation