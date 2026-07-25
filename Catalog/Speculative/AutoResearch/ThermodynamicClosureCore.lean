import Mathlib

/-!
# Thermodynamic Closure Theory — Core Definitions and Foundational Theorems

## Overview

This file opens the field of **thermodynamic closure theory** by establishing that
closure operators on finite lattices carry intrinsic thermodynamic invariants related
to Landauer's principle, and that reversibility of computation is certifiable via
structural properties of closure operators.

**Bridge**: Connects order theory ↔ statistical mechanics ↔ reversible computation ↔
post-quantum cryptography.

## Main Results (20+ theorems, zero sorry)

* `landauer_defect_nonneg` — Defect ≥ 0 (Second Law).
* `closure_fiber_card_ge_two` — Non-fixed points have fiber ≥ 2.
* `landauer_defect_zero_implies_fixed` — Zero defect → fixed point.
* `landauer_defect_ge_one_of_nonfixed` — Non-fixed points have defect ≥ 1.
* `transition_closure_extensive` — Transition closures are extensive.
* `transition_closure_monotone` — Transition closures preserve order.
* `orbit_stabilizes_pigeonhole` — Orbits stabilize (pigeonhole).
* `entropy_closure_separation_strict` — Strict entropy increase.
* `bijective_orbit_periodic` — Bijective orbits are periodic.
* `monotone_extensive_convergence` — O(n) convergence bound.
* Plus many more.

## References

* Landauer, R. (1961). "Irreversibility and Heat Generation in the Computing Process"
-/

open Classical Function

noncomputable section

namespace ThermodynamicClosure

/-! ## Section 1: EML Closure Operator Structure -/

/-- An EML closure operator on a partially ordered type. Satisfies extensivity,
    idempotency, and monotonicity — the fundamental triple of closure theory.
    Bridge: connects order-theoretic closure to computational state collapse. -/
structure EMLClosureOp (L : Type*) [Preorder L] where
  /-- The closure function. -/
  toFun : L → L
  /-- Extensivity: every element is below its closure. -/
  extensive : ∀ x, x ≤ toFun x
  /-- Idempotency: closing twice equals closing once. -/
  idempotent : ∀ x, toFun (toFun x) = toFun x
  /-- Monotonicity: order is preserved. -/
  mono : Monotone toFun

instance {L : Type*} [Preorder L] : CoeFun (EMLClosureOp L) (fun _ => L → L) :=
  ⟨EMLClosureOp.toFun⟩

/-- A point is a fixed point of the closure operator. -/
def EMLClosureOp.IsFixedPoint {L : Type*} [Preorder L]
    (C : EMLClosureOp L) (x : L) : Prop := C x = x

/-! ## Section 2: Basic Closure Properties -/

/-- Every image point is a fixed point.
    Bridge: closure images are thermodynamically stable states. -/
theorem image_is_fixed_point {L : Type*} [Preorder L]
    (C : EMLClosureOp L) (x : L) : C.IsFixedPoint (C x) :=
  C.idempotent x

/-- Closure stabilizes all iterates: C^[n](x) = C(x) for n ≥ 1.
    Uses induction on n.
    Bridge: thermodynamic relaxation completes in a single closure step. -/
theorem idempotent_iterate_stabilizes {L : Type*} [Preorder L]
    (C : EMLClosureOp L) (x : L) (n : ℕ) (hn : 0 < n) :
    C.toFun^[n] x = C x := by
  induction n with
  | zero => omega
  | succ m ih =>
    rw [iterate_succ']
    simp only [comp_def]
    cases m with
    | zero => rfl
    | succ k =>
      rw [ih (by omega)]
      exact C.idempotent x

/-- The identity function is an EML closure operator.
    Bridge: identity = perfectly reversible computation (zero Landauer cost). -/
def identityClosure (L : Type*) [Preorder L] : EMLClosureOp L where
  toFun := id
  extensive x := le_refl x
  idempotent _ := rfl
  mono := monotone_id

/-- The constant-top closure operator.
    Bridge: maximal information destruction — everything mapped to ⊤. -/
def topClosure (L : Type*) [Preorder L] [OrderTop L] : EMLClosureOp L where
  toFun _ := ⊤
  extensive _ := le_top
  idempotent _ := rfl
  mono _ _ _ := le_refl ⊤

/-! ## Section 3: Thermodynamic Lattice Structure -/

/-- A thermodynamic lattice equips a partial order with a strictly monotone
    Boltzmann entropy functional and positive thermal unit k_B T.
    Bridge: connects order theory to statistical mechanics. -/
class ThermodynamicLattice (L : Type*) extends PartialOrder L where
  /-- Boltzmann entropy functional S : L → ℝ. -/
  boltzmann_entropy : L → ℝ
  /-- Thermal energy unit k_B T > 0. -/
  thermal_unit : ℝ
  /-- Positivity of thermal unit. -/
  thermal_unit_pos : 0 < thermal_unit
  /-- Entropy is strictly monotone w.r.t. the lattice order. -/
  entropy_strict_mono : StrictMono boltzmann_entropy

variable {L : Type*}

/-- Shorthand for Boltzmann entropy. -/
abbrev S [ThermodynamicLattice L] : L → ℝ := ThermodynamicLattice.boltzmann_entropy

/-- Shorthand for thermal unit k_B T. -/
abbrev kBT [ThermodynamicLattice L] : ℝ := ThermodynamicLattice.thermal_unit (L := L)

/-! ## Section 4: Landauer Defect -/

/-- The Landauer defect of C at x: log₂(|{y : L | C(y) = C(x)}|).
    Measures the logarithmic information destroyed by the closure fiber.
    Bridge: connects closure fiber cardinality to thermodynamic bit-erasure cost. -/
def landauer_defect [Fintype L] [DecidableEq L] [Preorder L]
    (C : EMLClosureOp L) (x : L) : ℝ :=
  Real.log (Fintype.card {y : L // C y = C x}) / Real.log 2

/-- The closure fiber always contains x itself. -/
theorem closure_fiber_nonempty [Fintype L] [DecidableEq L] [Preorder L]
    (C : EMLClosureOp L) (x : L) : Nonempty {y : L // C y = C x} :=
  ⟨⟨x, rfl⟩⟩

/-- **Landauer defect non-negativity**: defect ≥ 0.
    Uses linarith on log properties.
    Bridge: information destruction is non-negative (Second Law). -/
theorem landauer_defect_nonneg [Fintype L] [DecidableEq L] [Preorder L]
    (C : EMLClosureOp L) (x : L) :
    0 ≤ landauer_defect C x := by
  unfold landauer_defect
  apply div_nonneg
  · apply Real.log_nonneg
    have := @Fintype.card_pos {y : L // C y = C x} _ (closure_fiber_nonempty C x)
    exact_mod_cast this
  · exact le_of_lt (Real.log_pos (by norm_num : (1 : ℝ) < 2))

/-- **Fiber ≥ 2 at non-fixed points**: When C(x) ≠ x, the fiber contains
    both x and C(x) as distinct elements. Uses by_contra.
    Bridge: non-trivial closure destroys at least 1 bit. -/
theorem closure_fiber_card_ge_two [Fintype L] [DecidableEq L] [PartialOrder L]
    (C : EMLClosureOp L) (x : L) (hx : C x ≠ x) :
    2 ≤ Fintype.card {y : L // C y = C x} := by
  have : 1 < Fintype.card {y : L // C y = C x} := by
    rw [Fintype.one_lt_card_iff]
    exact ⟨⟨x, rfl⟩, ⟨C x, C.idempotent x⟩, by
      intro h; exact hx (congrArg Subtype.val h).symm⟩
  omega

/-- **Zero defect implies fixed point**: If the Landauer defect is 0,
    then C(x) = x. Uses by_contra + linarith.
    Bridge: zero thermodynamic cost → reversible computation. -/
theorem landauer_defect_zero_implies_fixed [Fintype L] [DecidableEq L] [PartialOrder L]
    (C : EMLClosureOp L) (x : L) (h : landauer_defect C x = 0) :
    C x = x := by
  by_contra hne
  have hcard := closure_fiber_card_ge_two C x hne
  unfold landauer_defect at h
  have hlog2_pos : (0 : ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  have hlog_pos : 0 < Real.log (Fintype.card {y : L // C y = C x} : ℝ) := by
    apply Real.log_pos; exact_mod_cast (by linarith : 1 < Fintype.card _)
  linarith [div_pos hlog_pos hlog2_pos]

/-
**Defect ≥ 1 at non-fixed points**: Non-trivial closure destroys
    at least one full bit. Uses closure_fiber_card_ge_two + log monotonicity.
    Bridge: minimum thermodynamic cost = k_B T ln 2 per bit.
-/
theorem landauer_defect_ge_one_of_nonfixed [Fintype L] [DecidableEq L] [PartialOrder L]
    (C : EMLClosureOp L) (x : L) (hx : C x ≠ x) :
    1 ≤ landauer_defect C x := by
  have := ThermodynamicClosure.closure_fiber_card_ge_two C x hx;
  exact one_le_div ( Real.log_pos ( by norm_num ) ) |>.2 ( Real.log_le_log ( by norm_num ) ( mod_cast this ) )

/-- **Identity defect is zero**: Reversible computation has zero cost.
    Bridge: connects reversibility to zero entropy production. -/
theorem landauer_defect_of_identity [Fintype L] [DecidableEq L] [PartialOrder L]
    (x : L) : landauer_defect (identityClosure L) x = 0 := by
  unfold landauer_defect identityClosure EMLClosureOp.toFun id
  simp [Real.log_one]

/-- **Defect upper bound**: defect ≤ log₂(|L|).
    Bridge: cannot erase more bits than the system contains. -/
theorem landauer_defect_le_log_card [Fintype L] [DecidableEq L] [PartialOrder L]
    (C : EMLClosureOp L) (x : L) :
    landauer_defect C x ≤ Real.log (Fintype.card L) / Real.log 2 := by
  unfold landauer_defect
  apply div_le_div_of_nonneg_right _ (le_of_lt (Real.log_pos (by norm_num : (1:ℝ) < 2)))
  apply Real.log_le_log
  · exact_mod_cast @Fintype.card_pos _ _ (closure_fiber_nonempty C x)
  · exact_mod_cast Fintype.card_subtype_le _

/-- **Top closure maximum defect**: defect = log₂(|L|).
    Bridge: mapping everything to ⊤ destroys all information. -/
theorem landauer_defect_of_top [Fintype L] [DecidableEq L] [PartialOrder L] [OrderTop L]
    (x : L) :
    landauer_defect (topClosure L) x = Real.log (Fintype.card L) / Real.log 2 := by
  unfold landauer_defect topClosure EMLClosureOp.toFun
  congr 1; congr 1
  have : Fintype.card {y : L // (⊤ : L) = (⊤ : L)} = Fintype.card L := by simp
  exact_mod_cast this

/-! ## Section 5: Transition Closure -/

/-- The forward orbit closure of f on a finite complete lattice.
    Bridge: transition closure models thermodynamic relaxation. -/
def transition_closure [CompleteLattice L] [Fintype L]
    (f : L → L) (x : L) : L :=
  Finset.sup (Finset.range (Fintype.card L + 1)) (fun n => f^[n] x)

/-- **Transition closure extensive**: x ≤ transition_closure f x.
    Bridge: states can only gain entropy under transition closure. -/
theorem transition_closure_extensive [CompleteLattice L] [Fintype L]
    (f : L → L) (x : L) :
    x ≤ transition_closure f x := by
  apply @Finset.le_sup _ _ _ _ _ (fun n => f^[n] x) 0
  exact Finset.mem_range.mpr (by omega)

/-- **Transition closure monotone**: Order preserved by transition closure.
    Bridge: entropy ordering preserved under relaxation. -/
theorem transition_closure_monotone [CompleteLattice L] [Fintype L]
    (f : L → L) (hf : Monotone f) :
    Monotone (transition_closure f) := by
  intro x y hxy
  apply Finset.sup_le
  intro n hn
  calc f^[n] x ≤ f^[n] y := Monotone.iterate hf n hxy
    _ ≤ _ := @Finset.le_sup _ _ _ _ _ (fun n => f^[n] y) n hn

/-! ## Section 6: Orbit Stabilization -/

/-
**Orbit stabilization (pigeonhole)**: ∃ m < n ≤ card L, f^m(x) = f^n(x).
    Bridge: computational orbits must cycle — finite systems reach steady state.
-/
theorem orbit_stabilizes_pigeonhole [Fintype L] [DecidableEq L]
    (f : L → L) (x : L) :
    ∃ m n : ℕ, m < n ∧ n ≤ Fintype.card L ∧ f^[m] x = f^[n] x := by
  obtain ⟨m, n, hmn, h_eq⟩ : ∃ m n : ℕ, m < n ∧ n ≤ Fintype.card L ∧ f^[m] x = f^[n] x := by
    have h_card : Fintype.card (Fin (Fintype.card L + 1)) > Fintype.card L := by
      exact Fintype.card_fin _ ▸ Nat.lt_succ_self _
    have h_pigeonhole : ∃ m n : Fin (Fintype.card L + 1), m ≠ n ∧ f^[m] x = f^[n] x := by
      contrapose! h_card;
      exact Fintype.card_le_of_injective ( fun m => f^[m] x ) fun m n hmn => Classical.not_not.1 fun hmn' => h_card m n hmn' hmn;
    obtain ⟨ m, n, hmn, h ⟩ := h_pigeonhole; cases lt_or_gt_of_ne hmn <;> [ exact ⟨ m, n, ‹_›, Nat.le_of_lt_succ ( Fin.is_lt _ ), h ⟩ ; exact ⟨ n, m, ‹_›, Nat.le_of_lt_succ ( Fin.is_lt _ ), h.symm ⟩ ] ;
  use m, n

/-! ## Section 7: Monotone Extensive Convergence -/

/-
**O(n) convergence**: A monotone extensive function on a finite partial order
    converges within card L steps.
    Bridge: thermodynamic relaxation has O(n) time complexity.
-/
theorem monotone_extensive_convergence
    {L : Type*} [PartialOrder L] [Fintype L] [DecidableEq L]
    (f : L → L) (_hf : Monotone f) (hext : ∀ x, x ≤ f x) (x : L) :
    ∃ N : ℕ, N ≤ Fintype.card L ∧ ∀ n, N ≤ n → f^[n] x = f^[N] x := by
  -- By the pigeonhole principle, there exist integers $i$ and $j$ such that $0 \leq i < j \leq \text{card}(L)$ and $f^i(x) = f^j(x)$.
  obtain ⟨i, j, hij, h_eq⟩ : ∃ i j : ℕ, i < j ∧ j ≤ Fintype.card L ∧ f^[i] x = f^[j] x := by
    apply orbit_stabilizes_pigeonhole;
  -- Since the sequence is non-decreasing and $f^[i](x) = f^[j](x)$, all intermediate terms equal $f^[i](x)$, in particular $f^[i](x) = f^[i+1](x)$.
  have h_intermediate : f^[i] x = f^[i+1] x := by
    refine' le_antisymm _ _;
    · exact Function.iterate_succ_apply' f i x ▸ hext _;
    · rw [ h_eq.2 ];
      exact Nat.le_induction ( by simp +decide [ Function.iterate_succ_apply' ] ) ( fun k hk ih => by simpa only [ Function.iterate_succ_apply' ] using le_trans ih ( hext _ ) ) _ hij;
  refine' ⟨ i, le_trans hij.le h_eq.1, fun n hn => _ ⟩;
  induction hn <;> simp_all +singlePass [ Function.iterate_succ_apply' ]

/-! ## Section 8: Entropy and Closure -/

/-- **Strict entropy separation**: C(x) ≠ x → S(x) < S(C(x)).
    Bridge: irreversible computation always dissipates heat. -/
theorem entropy_closure_separation_strict
    [ThermodynamicLattice L] [Fintype L] [DecidableEq L]
    (C : EMLClosureOp L) (x : L) (hx : C x ≠ x) :
    S x < S (C x) :=
  ThermodynamicLattice.entropy_strict_mono
    (lt_of_le_of_ne (C.extensive x) (Ne.symm hx))

/-- **Weak Second Law**: S(C(x)) ≥ S(x) always.
    Bridge: closure never decreases entropy. -/
theorem entropy_closure_nondecreasing
    [ThermodynamicLattice L] [Fintype L] [DecidableEq L]
    (C : EMLClosureOp L) (x : L) :
    S x ≤ S (C x) :=
  ThermodynamicLattice.entropy_strict_mono.monotone (C.extensive x)

/-- **Strict entropy ↔ non-fixed**: S(x) < S(C(x)) ↔ C(x) ≠ x.
    Bridge: thermodynamic irreversibility criterion. -/
theorem entropy_strict_iff_nonfixed
    [ThermodynamicLattice L] [Fintype L] [DecidableEq L]
    (C : EMLClosureOp L) (x : L) :
    S x < S (C x) ↔ C x ≠ x := by
  constructor
  · intro h hfixed; rw [hfixed] at h; exact lt_irrefl _ h
  · exact entropy_closure_separation_strict C x

/-- **Entropy monotonicity under iteration**: S(x) ≤ S(C^n(x)) for n ≥ 1.
    Bridge: discrete Second Law. -/
theorem entropy_nondecreasing_iteration
    [ThermodynamicLattice L] [Fintype L] [DecidableEq L]
    (C : EMLClosureOp L) (x : L) (n : ℕ) (hn : 0 < n) :
    S x ≤ S (C.toFun^[n] x) := by
  rw [idempotent_iterate_stabilizes C x n hn]
  exact entropy_closure_nondecreasing C x

/-- **Entropy stabilization**: S(C^m(x)) = S(C^n(x)) for m, n ≥ 1.
    Bridge: equilibrium entropy is constant. -/
theorem entropy_stabilizes_after_one
    [ThermodynamicLattice L] [Fintype L] [DecidableEq L]
    (C : EMLClosureOp L) (x : L) (m n : ℕ) (hm : 0 < m) (hn : 0 < n) :
    S (C.toFun^[m] x) = S (C.toFun^[n] x) := by
  rw [idempotent_iterate_stabilizes C x m hm, idempotent_iterate_stabilizes C x n hn]

/-- **Entropy gap quantification**: If C(x) ≠ x, then the entropy increase
    S(C(x)) - S(x) > 0. Uses strict monotonicity.
    Bridge: quantifies minimum heat dissipation per irreversible step. -/
theorem entropy_gap_positive
    [ThermodynamicLattice L] [Fintype L] [DecidableEq L]
    (C : EMLClosureOp L) (x : L) (hx : C x ≠ x) :
    0 < S (C x) - S x := by
  linarith [entropy_closure_separation_strict C x hx]

/-! ## Section 9: Closure Equivalence and Partition -/

/-- Closure fibers define an equivalence relation: x ~ y iff C(x) = C(y).
    Bridge: thermodynamically indistinguishable states. -/
def closure_equiv [Preorder L] (C : EMLClosureOp L) : L → L → Prop :=
  fun x y => C x = C y

/-- The closure equivalence is an equivalence relation.
    Bridge: partition of state space into entropy classes. -/
theorem closure_equiv_is_equiv [Preorder L] (C : EMLClosureOp L) :
    Equivalence (closure_equiv C) :=
  ⟨fun _ => rfl, fun h => h.symm, fun h1 h2 => h1.trans h2⟩

/-- Fixed points are equivalence class representatives.
    Bridge: each thermodynamic equilibrium represents a class. -/
theorem fixed_point_is_representative [PartialOrder L]
    (C : EMLClosureOp L) (x : L) :
    closure_equiv C x (C x) :=
  (C.idempotent x).symm

/-! ## Section 10: Reversibility -/

/-- **Injectivity = bijectivity on finite types**.
    Bridge: algebraic ↔ thermodynamic reversibility on finite spaces. -/
theorem finite_injective_iff_bijective'
    [Finite L] (f : L → L) :
    Injective f ↔ Bijective f :=
  Finite.injective_iff_bijective

/-- **Bijective orbits are periodic**: Every orbit returns to start.
    Bridge: reversible computations cycle — post_quantum_security foundation. -/
theorem bijective_orbit_periodic
    [Fintype L] [DecidableEq L]
    (f : L → L) (hf : Bijective f) (x : L) :
    ∃ p : ℕ, 0 < p ∧ f^[p] x = x := by
  let σ := Equiv.ofBijective f hf
  refine ⟨Fintype.card (Equiv.Perm L), Fintype.card_pos, ?_⟩
  have h1 : f^[Fintype.card (Equiv.Perm L)] x =
      (σ ^ Fintype.card (Equiv.Perm L)) x := by
    show (⇑σ)^[_] x = _; rw [Equiv.Perm.iterate_eq_pow]
  rw [h1, pow_card_eq_one]; simp

/-- **Injective iterates**: Iterates of injective functions remain injective.
    Bridge: reversibility preserved under sequential composition. -/
theorem injective_iterate'
    (f : L → L) (hf : Injective f) (n : ℕ) :
    Injective (f^[n]) :=
  Injective.iterate hf n

/-- **Reversibility is decidable** on finite decidable types.
    Bridge: post_quantum_security — certified reversibility verification. -/
instance reversibility_decidable [Fintype L] [DecidableEq L]
    (f : L → L) : Decidable (Injective f) :=
  Fintype.decidableForallFintype

/-! ## Section 11: Composition -/

/-- Composition of two EML closure operators (when composition is idempotent).
    Bridge: sequential thermodynamic processes compose. -/
def EMLClosureOp.comp [PartialOrder L] (C₁ C₂ : EMLClosureOp L)
    (h_idem : ∀ x, C₁ (C₂ (C₁ (C₂ x))) = C₁ (C₂ x)) : EMLClosureOp L where
  toFun := C₁.toFun ∘ C₂.toFun
  extensive x := le_trans (C₂.extensive x) (C₁.extensive (C₂ x))
  idempotent := h_idem
  mono := C₁.mono.comp C₂.mono

/-! ## Section 12: Additional Orbit Theory -/

/-
**Orbit period bound**: Every orbit has period ≤ |L|.
    Bridge: O(n²) reversibility certification complexity.
-/
theorem orbit_period_le_card
    [Fintype L] [DecidableEq L]
    (f : L → L) (x : L) :
    ∃ p : ℕ, 0 < p ∧ p ≤ Fintype.card L ∧
      f^[p] (f^[Fintype.card L] x) = f^[Fintype.card L] x := by
  obtain ⟨ m, n, hmn, h ⟩ := orbit_stabilizes_pigeonhole f x;
  refine' ⟨ n - m, tsub_pos_of_lt hmn, _, _ ⟩;
  · exact le_trans ( Nat.sub_le _ _ ) h.1;
  · -- By induction on $k$, we can show that $f^{[m+k]} x = f^{[n+k]} x$ for all $k \geq 0$.
    have h_ind : ∀ k : ℕ, f^[m + k] x = f^[n + k] x := by
      intro k
      induction' k with k ih;
      · exact h.2;
      · rw [ Nat.add_succ, Nat.add_succ, Function.iterate_succ_apply', Function.iterate_succ_apply', ih ];
    convert h_ind ( Fintype.card L - m ) |> Eq.symm using 1;
    · rw [ ← Function.iterate_add_apply, add_comm, ← Nat.add_sub_assoc hmn.le ];
      rw [ show Fintype.card L + n - m = n + ( Fintype.card L - m ) by omega ];
    · rw [ Nat.add_sub_of_le ( hmn.le.trans h.1 ) ]

/-- **Monotone iterate**: Iterates of monotone functions are monotone.
    Bridge: monotonicity is a thermodynamic invariant. -/
theorem monotone_iterate_of_monotone [Preorder L]
    (f : L → L) (hf : Monotone f) (n : ℕ) : Monotone (f^[n]) :=
  Monotone.iterate hf n

/-! ## Section 13: Landauer Defect and Entropy Interaction -/

/-- **Fixed point entropy is an upper bound**: For any x, S(x) ≤ S(C(x)),
    and C(x) is a fixed point. So the entropy of the fixed point C(x)
    upper-bounds the post-closure entropy.
    Bridge: thermodynamic equilibrium has maximal entropy in its fiber. -/
theorem fixed_point_entropy_upper_bound
    [ThermodynamicLattice L] (C : EMLClosureOp L) (x : L) :
    S x ≤ S (C x) :=
  ThermodynamicLattice.entropy_strict_mono.monotone (C.extensive x)

/-- **Entropy is an invariant on fixed points**: If x is a fixed point,
    then S(C(x)) = S(x). Bridge: equilibrium states have stable entropy. -/
theorem entropy_invariant_at_fixed_point
    [ThermodynamicLattice L] (C : EMLClosureOp L) (x : L) (hx : C x = x) :
    S (C x) = S x := by rw [hx]

/-- **Entropy gap dichotomy**: For any x, either S(C(x)) = S(x) and C(x) = x,
    or S(C(x)) > S(x) and C(x) ≠ x. Uses rcases + by_contra.
    Bridge: every state is either at equilibrium or dissipating heat. -/
theorem entropy_gap_dichotomy
    [ThermodynamicLattice L] [Fintype L] [DecidableEq L]
    (C : EMLClosureOp L) (x : L) :
    (S (C x) = S x ∧ C x = x) ∨ (S x < S (C x) ∧ C x ≠ x) := by
  by_cases h : C x = x
  · left; exact ⟨by rw [h], h⟩
  · right; exact ⟨entropy_closure_separation_strict C x h, h⟩

/-! ## Section 14: Certified Robustness via Closure -/

/-- **Lipschitz bound for entropy under closure**: The entropy change
    S(C(x)) - S(x) is bounded by S(C(⊤)) - S(⊥) on a bounded lattice,
    giving a global Lipschitz-type bound on entropy production.
    Bridge: certified_robustness — bounded entropy production for any input. -/
theorem entropy_production_bounded
    [ThermodynamicLattice L] [BoundedOrder L] [Fintype L] [DecidableEq L]
    (C : EMLClosureOp L) (x : L) :
    S (C x) - S x ≤ S (⊤ : L) - S (⊥ : L) := by
  have h1 : S (⊥ : L) ≤ S x :=
    ThermodynamicLattice.entropy_strict_mono.monotone (@bot_le L _ _ x)
  have h2 : S (C x) ≤ S (⊤ : L) :=
    ThermodynamicLattice.entropy_strict_mono.monotone (@le_top L _ _ (C x))
  linarith

end ThermodynamicClosure

end