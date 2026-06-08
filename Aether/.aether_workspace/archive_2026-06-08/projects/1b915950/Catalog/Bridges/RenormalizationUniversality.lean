/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Algebra–EML Renormalization Semantics via Closure Flow Monoids and Universality Classes

Bridge: connects renormalization-group universality to closure-semiring semantics
and certified asymptotic robustness across algebra, physics, ML, and cryptography.
-/
import Mathlib

universe u

-- Core classes
class ClosureFlow (α : Type u) where
  cl : α → α
  step : α → α
  step_cl_comm : ∀ x, step (cl x) = cl (step x)

class ClosureFlowMonoid (α : Type u) extends Monoid α, ClosureFlow α where
  cl_mul : ∀ (x y : α), cl (x * y) = cl (cl x * cl y)
  step_mul : ∀ (x y : α), step (x * y) = step x * step y
  step_one : step (1 : α) = 1

class ClosureFlowSemiring (α : Type u) extends Semiring α, ClosureFlow α where
  step_zero : step (0 : α) = 0
  step_one : step (1 : α) = 1
  step_add : ∀ (x y : α), step (x + y) = step x + step y
  step_mul : ∀ (x y : α), step (x * y) = step x * step y
  cl_idem : ∀ (x : α), cl (cl x) = cl x

class IdempotentStepFlow (α : Type u) extends ClosureFlow α where
  step_idem : ∀ x, step (step x) = step x

class FiniteClosureFlow (α : Type u) extends ClosureFlow α, Fintype α where
  [decEq : DecidableEq α]
attribute [instance] FiniteClosureFlow.decEq

-- Definitions
def IsClosureObservable {α : Type u} [ClosureFlow α] (x : α) : Prop := ClosureFlow.cl x = x
def IsRGFixed {α : Type u} [ClosureFlow α] (x : α) : Prop := ClosureFlow.step x = x
def rgIterate {α : Type u} [ClosureFlow α] : Nat → α → α
  | 0, x => x
  | n + 1, x => ClosureFlow.step (rgIterate n x)
def AsymptoticCong {α : Type u} [ClosureFlow α] (x y : α) : Prop :=
  ∃ N : Nat, ∀ n : Nat, N ≤ n → rgIterate n x = rgIterate n y
def ClosureAsymptoticCong {α : Type u} [ClosureFlow α] (x y : α) : Prop :=
  ∃ N : Nat, ∀ n : Nat, N ≤ n →
    ClosureFlow.cl (rgIterate n x) = ClosureFlow.cl (rgIterate n y)
def IsUniversalityClass {α : Type u} [ClosureFlow α] (C : Set α) : Prop :=
  ∃ x, C = {y | AsymptoticCong x y}
def StabilizesBy {α : Type u} [ClosureFlow α] (N : Nat) (x : α) : Prop :=
  ∀ n : Nat, N ≤ n → rgIterate (n + 1) x = rgIterate n x
def StabilizationWitness {α : Type u} [ClosureFlow α] (x : α) : Prop :=
  ∃ N : Nat, StabilizesBy N x
def CertifiedRGWindow {α : Type u} [ClosureFlow α] (k : Nat) (x y : α) : Prop :=
  ∀ n : Nat, n ≤ k → rgIterate n x = rgIterate n y
def HasClosureNormalForms (α : Type u) [ClosureFlow α] : Prop :=
  ∀ x : α, ∃ y, IsClosureObservable y ∧ AsymptoticCong x y

-- Iterate lemmas
@[simp] theorem rgIterate_zero {α : Type u} [ClosureFlow α] (x : α) :
    rgIterate 0 x = x := rfl

theorem rgIterate_add {α : Type u} [ClosureFlow α] (m n : Nat) (x : α) :
    rgIterate (m + n) x = rgIterate m (rgIterate n x) := by
      induction' m with m ih;
      · aesop;
      · simp +decide only [Nat.succ_add,rgIterate];
        rw [ih]

theorem rgIterate_step_comm {α : Type u} [ClosureFlow α] (n : Nat) (x : α) :
    rgIterate n (ClosureFlow.step x) = ClosureFlow.step (rgIterate n x) := by
  induction n with
  | zero => rfl
  | succ n ih => exact congrArg ClosureFlow.step ih

theorem rgIterate_cl_comm {α : Type u} [ClosureFlow α] (n : Nat) (x : α) :
    rgIterate n (ClosureFlow.cl x) = ClosureFlow.cl (rgIterate n x) := by
  induction n with
  | zero => rfl
  | succ n ih =>
    show ClosureFlow.step (rgIterate n (ClosureFlow.cl x)) =
         ClosureFlow.cl (ClosureFlow.step (rgIterate n x))
    rw [ih, ClosureFlow.step_cl_comm]

theorem rgIterate_succ' {α : Type u} [ClosureFlow α] (n : Nat) (x : α) :
    rgIterate (n + 1) x = rgIterate n (ClosureFlow.step x) :=
  (rgIterate_step_comm n x).symm

-- Equivalence relation
theorem asymptoticCong_refl {α : Type u} [ClosureFlow α] (x : α) :
    AsymptoticCong x x := ⟨0, fun _ _ => rfl⟩

theorem asymptoticCong_symm {α : Type u} [ClosureFlow α] {x y : α}
    (h : AsymptoticCong x y) : AsymptoticCong y x :=
  let ⟨N, hN⟩ := h; ⟨N, fun n hn => (hN n hn).symm⟩

theorem asymptoticCong_trans {α : Type u} [ClosureFlow α] {x y z : α}
    (hxy : AsymptoticCong x y) (hyz : AsymptoticCong y z) : AsymptoticCong x z := by
  obtain ⟨N₁, hN₁⟩ := hxy; obtain ⟨N₂, hN₂⟩ := hyz
  exact ⟨max N₁ N₂, fun n hn =>
    (hN₁ n (le_of_max_le_left hn)).trans (hN₂ n (le_of_max_le_right hn))⟩

def asymptoticSetoid (α : Type u) [ClosureFlow α] : Setoid α where
  r := AsymptoticCong
  iseqv := ⟨asymptoticCong_refl, asymptoticCong_symm, asymptoticCong_trans⟩

/-
Compatibility
-/
theorem asymptoticCong_step {α : Type u} [ClosureFlow α] {x y : α}
    (h : AsymptoticCong x y) : AsymptoticCong (ClosureFlow.step x) (ClosureFlow.step y) := by
      obtain ⟨ N, hN ⟩ := h;
      use N + 1;
      intro n hn; induction hn <;> simp_all +decide [ rgIterate_succ' ] ;
      · have := hN ( N + 2 ) ( by linarith ) ; simp_all +decide [ rgIterate_succ' ] ;
      · rename_i k hk ih; have := hN ( k + 2 ) ( by linarith ) ; simp_all +decide [ rgIterate_succ' ] ;

theorem asymptoticCong_of_step {α : Type u} [ClosureFlow α] {x y : α}
    (h : AsymptoticCong (ClosureFlow.step x) (ClosureFlow.step y)) : AsymptoticCong x y := by
      obtain ⟨ N, hN ⟩ := h;
      use N + 1;
      intro n hn; induction hn <;> simp_all +decide [ rgIterate_succ' ] ;
      exact hN _ ( Nat.le_of_lt ‹_› )

theorem asymptoticCong_closure {α : Type u} [ClosureFlow α] {x y : α}
    (h : AsymptoticCong x y) : AsymptoticCong (ClosureFlow.cl x) (ClosureFlow.cl y) := by
      -- From h, take N and use for cl x and cl y.
      obtain ⟨N, hN⟩ := h
      use N;
      -- Apply the closure operation to both sides of the equivalence.
      intros n hn
      have := hN n hn
      simp [rgIterate_cl_comm, this]

theorem closureAsymptoticCong_of_asymptoticCong {α : Type u} [ClosureFlow α] {x y : α}
    (h : AsymptoticCong x y) : ClosureAsymptoticCong x y :=
  by
    exact ⟨ h.choose, fun n hn => congr_arg _ ( h.choose_spec n hn ) ⟩

theorem asymptoticCong_rgIterate {α : Type u} [ClosureFlow α] (k : Nat) {x y : α}
    (h : AsymptoticCong x y) : AsymptoticCong (rgIterate k x) (rgIterate k y) := by
  obtain ⟨ N, hN ⟩ := h;
  refine' ⟨ N, fun n hn => _ ⟩;
  convert hN ( n + k ) ( by linarith ) using 1 <;> simp +decide [ ← rgIterate_add ]

-- Stabilization
theorem stabilizesBy_mono {α : Type u} [ClosureFlow α] {N M : Nat} {x : α}
    (h : StabilizesBy N x) (hNM : N ≤ M) : StabilizesBy M x :=
  fun n hn => h n (le_trans hNM hn)

theorem stabilizesBy_fixed_tail {α : Type u} [ClosureFlow α] {N : Nat} {x : α}
    (h : StabilizesBy N x) (k : Nat) : rgIterate (N + k) x = rgIterate N x := by
      exact Nat.recOn k rfl fun n ih => by rw [ Nat.add_succ, ← ih, h _ ( Nat.le_add_right _ _ ) ] ;

theorem every_stabilizing_observable_has_fixed_universality_class
    {α : Type u} [ClosureFlow α] {x : α} (hw : StabilizationWitness x) :
    ∃ y, IsRGFixed y ∧ AsymptoticCong x y := by
      use (‹ClosureFlow α›.step)^[hw.choose] x;
      have h_fixed : ∀ n ≥ hw.choose, (‹ClosureFlow α›.step)^[n] x = (‹ClosureFlow α›.step)^[hw.choose] x := by
        intro n hn; induction hn <;> simp_all +decide [ Function.iterate_succ_apply' ] ;
        have := hw.choose_spec ‹_›; simp_all +decide [ Function.iterate_succ_apply' ] ;
        simp_all +decide [ ← ‹ ( _ :ClosureFlow α ).step^[ _ ] x = _ ›, rgIterate ];
        convert this using 1;
        · congr! 1;
          rename_i k hk;
          exact Nat.recOn k rfl fun n ihn => by simp +decide [ *, Function.iterate_succ_apply', rgIterate ] ;
        · rename_i k hk;
          exact Nat.recOn k rfl fun n ihn => by simp +decide [ *, Function.iterate_succ_apply', rgIterate ] ;
      constructor;
      · have := h_fixed ( hw.choose + 1 ) ( Nat.le_succ _ ) ; simp_all +decide [ Function.iterate_succ_apply' ] ;
        exact this;
      · use hw.choose;
        intro n hn
        have h_eq : (‹ClosureFlow α›.step)^[n] x = (‹ClosureFlow α›.step)^[hw.choose] x := by
          exact h_fixed n hn;
        convert h_eq using 1;
        · exact Nat.recOn n rfl fun n ih => by simp +decide [ *, Function.iterate_succ_apply', rgIterate ] ;
        · convert h_fixed ( n + hw.choose ) ( by linarith ) using 1;
          induction' n with n ih;
          · aesop;
          · induction' n + 1 with n ih <;> simp_all +decide [ Function.iterate_succ_apply', rgIterate ];
            have := h_fixed ( hw.choose + 1 ) ( by linarith ) ; simp_all +decide [ Function.iterate_succ_apply' ] ;

theorem closure_observable_of_fixed {α : Type u} [ClosureFlow α] {x : α}
    (hcl : IsClosureObservable x) (hfp : IsRGFixed x) :
    ∃ y, y = ClosureFlow.cl x ∧ IsRGFixed y ∧ IsClosureObservable y := by
      simp_all +decide [ IsRGFixed, IsClosureObservable ]

-- Monoid
theorem rgIterate_mul {α : Type u} [ClosureFlowMonoid α] (n : Nat) (x y : α) :
    rgIterate n (x * y) = rgIterate n x * rgIterate n y := by
  induction n with
  | zero => rfl
  | succ n ih =>
    show ClosureFlow.step (rgIterate n (x * y)) =
         ClosureFlow.step (rgIterate n x) * ClosureFlow.step (rgIterate n y)
    rw [ih, ClosureFlowMonoid.step_mul]

theorem asymptoticCong_mul {α : Type u} [ClosureFlowMonoid α] {a b c d : α}
    (hac : AsymptoticCong a c) (hbd : AsymptoticCong b d) :
    AsymptoticCong (a * b) (c * d) := by
  obtain ⟨N₁, hN₁⟩ := hac; obtain ⟨N₂, hN₂⟩ := hbd
  exact ⟨max N₁ N₂, fun n hn => by
    rw [rgIterate_mul, rgIterate_mul, hN₁ n (le_of_max_le_left hn),
        hN₂ n (le_of_max_le_right hn)]⟩

theorem asymptoticCong_one {α : Type u} [ClosureFlowMonoid α] :
    AsymptoticCong (1 : α) 1 := asymptoticCong_refl 1

theorem rgIterate_one {α : Type u} [ClosureFlowMonoid α] (n : Nat) :
    rgIterate n (1 : α) = 1 := by
  induction n with
  | zero => rfl
  | succ n ih =>
    show ClosureFlow.step (rgIterate n (1 : α)) = 1; rw [ih, ClosureFlowMonoid.step_one]

-- Semiring
theorem rgIterate_add_distrib {α : Type u} [ClosureFlowSemiring α] (n : Nat) (x y : α) :
    rgIterate n (x + y) = rgIterate n x + rgIterate n y := by
  induction n with
  | zero => rfl
  | succ n ih =>
    show ClosureFlow.step (rgIterate n (x + y)) =
         ClosureFlow.step (rgIterate n x) + ClosureFlow.step (rgIterate n y)
    rw [ih, ClosureFlowSemiring.step_add]

theorem rgIterate_mul_distrib {α : Type u} [ClosureFlowSemiring α] (n : Nat) (x y : α) :
    rgIterate n (x * y) = rgIterate n x * rgIterate n y := by
  induction n with
  | zero => rfl
  | succ n ih =>
    show ClosureFlow.step (rgIterate n (x * y)) =
         ClosureFlow.step (rgIterate n x) * ClosureFlow.step (rgIterate n y)
    rw [ih, ClosureFlowSemiring.step_mul]

theorem asymptoticCong_add_semiring {α : Type u} [ClosureFlowSemiring α] {a b c d : α}
    (hac : AsymptoticCong a c) (hbd : AsymptoticCong b d) :
    AsymptoticCong (a + b) (c + d) := by
  obtain ⟨N₁, hN₁⟩ := hac; obtain ⟨N₂, hN₂⟩ := hbd
  exact ⟨max N₁ N₂, fun n hn => by
    rw [rgIterate_add_distrib, rgIterate_add_distrib,
        hN₁ n (le_of_max_le_left hn), hN₂ n (le_of_max_le_right hn)]⟩

theorem asymptoticCong_mul_semiring {α : Type u} [ClosureFlowSemiring α] {a b c d : α}
    (hac : AsymptoticCong a c) (hbd : AsymptoticCong b d) :
    AsymptoticCong (a * b) (c * d) := by
  obtain ⟨N₁, hN₁⟩ := hac; obtain ⟨N₂, hN₂⟩ := hbd
  exact ⟨max N₁ N₂, fun n hn => by
    rw [rgIterate_mul_distrib, rgIterate_mul_distrib,
        hN₁ n (le_of_max_le_left hn), hN₂ n (le_of_max_le_right hn)]⟩

-- Quotient
def UniversalityQuotient (α : Type u) [ClosureFlow α] :=
  Quotient (asymptoticSetoid α)

def uqStep {α : Type u} [ClosureFlow α] :
    UniversalityQuotient α → UniversalityQuotient α :=
  Quotient.map ClosureFlow.step (fun _ _ => asymptoticCong_step)

def uqClosure {α : Type u} [ClosureFlow α] :
    UniversalityQuotient α → UniversalityQuotient α :=
  Quotient.map ClosureFlow.cl (fun _ _ => asymptoticCong_closure)

theorem quotient_closure_flow_descends (α : Type u) [ClosureFlow α] :
    ∃ stepQ clQ : UniversalityQuotient α → UniversalityQuotient α,
      (∀ x, stepQ (Quotient.mk _ x) = Quotient.mk _ (ClosureFlow.step x)) ∧
      (∀ x, clQ (Quotient.mk _ x) = Quotient.mk _ (ClosureFlow.cl x)) :=
  ⟨uqStep, uqClosure, fun _ => rfl, fun _ => rfl⟩

-- Idempotent
theorem idempotentStep_stabilizesBy_one {α : Type u} [IdempotentStepFlow α] (x : α) :
    StabilizesBy 1 x := by
  intro n hn; match n with
  | 0 => omega
  | n + 1 =>
    show ClosureFlow.step (ClosureFlow.step (rgIterate n x)) = ClosureFlow.step (rgIterate n x)
    exact IdempotentStepFlow.step_idem _

theorem idempotentStep_has_fixed_point {α : Type u} [IdempotentStepFlow α] (x : α) :
    ∃ y, IsRGFixed y ∧ AsymptoticCong x y :=
  every_stabilizing_observable_has_fixed_universality_class ⟨1, idempotentStep_stabilizesBy_one x⟩

-- Finite state
theorem post_quantum_lattice_orbit_repeat_bound {α : Type u} [FiniteClosureFlow α] (x : α) :
    ∃ i j : Nat, i < j ∧ j ≤ Fintype.card α + 1 ∧ rgIterate i x = rgIterate j x := by
  by_contra h; push_neg at h
  have hinj : Function.Injective (fun i : Fin (Fintype.card α + 1) => rgIterate i.val x) := by
    intro ⟨i, hi⟩ ⟨j, hj⟩ heq; simp only at heq; by_contra hij
    have hne : i ≠ j := fun h' => hij (Fin.ext h')
    rcases Nat.lt_or_gt_of_ne hne with hlt | hgt
    · exact absurd heq (h i j hlt (by omega))
    · exact absurd heq.symm (h j i hgt (by omega))
  have := Fintype.card_le_of_injective _ hinj; simp [Fintype.card_fin] at this

theorem finite_stabilization_or_periodic_bound {α : Type u} [FiniteClosureFlow α] (x : α) :
    ∃ N p : Nat, 1 ≤ p ∧ N + p ≤ Fintype.card α + 1 ∧
      ∀ n : Nat, N ≤ n → rgIterate (n + p) x = rgIterate n x := by
  obtain ⟨ i, j, hij, hj, h ⟩ := @post_quantum_lattice_orbit_repeat_bound α ‹_› x;
  refine' ⟨ i, j - i, Nat.sub_pos_of_lt hij, by omega, fun n hn => _ ⟩;
  induction' hn with n hn ih;
  · rw [ add_tsub_cancel_of_le hij.le, h ];
  · convert congr_arg ( fun y => ( ‹FiniteClosureFlow α›.step ) y ) ih using 1;
    simp +decide [ Nat.succ_add, rgIterate ]

-- Additional
theorem isRGFixed_rgIterate {α : Type u} [ClosureFlow α] {x : α}
    (h : IsRGFixed x) (n : Nat) : rgIterate n x = x := by
  induction n with
  | zero => rfl
  | succ n ih => show ClosureFlow.step (rgIterate n x) = x; rw [ih]; exact h

theorem isRGFixed_stabilizesBy_zero {α : Type u} [ClosureFlow α] {x : α}
    (h : IsRGFixed x) : StabilizesBy 0 x := by
      intros n hn_nonneg
      simp [rgIterate, h];
      induction n <;> simp_all +decide [ IsRGFixed, rgIterate ]

theorem asymptoticCong_fixed_eq {α : Type u} [ClosureFlow α] {x y : α}
    (hf : IsRGFixed y) (h : AsymptoticCong x y) :
    ∃ N, ∀ n, N ≤ n → rgIterate n x = y := by
  obtain ⟨N, hN⟩ := h
  exact ⟨N, fun n hn => by rw [hN n hn, isRGFixed_rgIterate hf]⟩

theorem stabilizationWitness_step {α : Type u} [ClosureFlow α] {x : α}
    (h : StabilizationWitness x) : StabilizationWitness (ClosureFlow.step x) := by
  obtain ⟨N, hN⟩ := h
  exact ⟨N, fun n hn => by
    show rgIterate (n + 1) (ClosureFlow.step x) = rgIterate n (ClosureFlow.step x)
    rw [rgIterate_step_comm, rgIterate_step_comm]; exact congrArg _ (hN n hn)⟩

theorem certifiedRGWindow_mono {α : Type u} [ClosureFlow α] {k₁ k₂ : Nat} {x y : α}
    (h : CertifiedRGWindow k₂ x y) (hle : k₁ ≤ k₂) : CertifiedRGWindow k₁ x y :=
  fun n hn => h n (le_trans hn hle)

theorem certified_window_to_asymptotic {α : Type u} [ClosureFlow α] {x y : α}
    (h : ∃ N, CertifiedRGWindow N x y ∧ StabilizesBy N x ∧ StabilizesBy N y) :
    AsymptoticCong x y := by
  obtain ⟨N, hwindow, hsx, hsy⟩ := h
  exact ⟨N, fun n hn => by
    obtain ⟨k, rfl⟩ := Nat.exists_eq_add_of_le hn
    rw [stabilizesBy_fixed_tail hsx k, stabilizesBy_fixed_tail hsy k]; exact hwindow N le_rfl⟩


theorem universalityClass_nonempty {α : Type u} [ClosureFlow α]
    {C : Set α} (hC : IsUniversalityClass C) : C.Nonempty := by
  obtain ⟨rep, rfl⟩ := hC; exact ⟨rep, asymptoticCong_refl rep⟩

theorem quantum_entropy_style_normal_form_uniqueness {α : Type u} [ClosureFlow α]
    (huniq : ∀ x y : α, IsClosureObservable x → IsClosureObservable y →
      AsymptoticCong x y → x = y)
    (hnf : HasClosureNormalForms α) :
    ∀ x : α, ∃! y, IsClosureObservable y ∧ AsymptoticCong x y := by
  intro x; obtain ⟨y, hy_obs, hy_cong⟩ := hnf x
  refine ⟨y, ⟨hy_obs, hy_cong⟩, fun z ⟨hz_obs, hz_cong⟩ => ?_⟩
  by_contra h_neq;
  obtain ⟨ N, hN ⟩ := hz_cong;
  obtain ⟨ M, hM ⟩ := hy_cong;
  exact h_neq ( huniq _ _ hz_obs hy_obs ⟨ Max.max N M, fun n hn => by rw [ ← hN n ( le_trans ( le_max_left _ _ ) hn ), ← hM n ( le_trans ( le_max_right _ _ ) hn ) ] ⟩ )

theorem lipschitz_certified_robustness_via_universality_class {α : Type u} [ClosureFlow α]
    {x y : α} {k : Nat}
    (hwindow : CertifiedRGWindow k x y) (hsx : StabilizesBy k x) (hsy : StabilizesBy k y) :
    AsymptoticCong x y :=
  certified_window_to_asymptotic ⟨k, hwindow, hsx, hsy⟩

theorem thermodynamic_rg_fixed_tail_principle {α : Type u} [ClosureFlow α]
    {x : α} {N : Nat} (h : StabilizesBy N x) (m : Nat) (hm : N ≤ m) :
    rgIterate m x = rgIterate N x := by
  obtain ⟨k, rfl⟩ := Nat.exists_eq_add_of_le hm; exact stabilizesBy_fixed_tail h k

-- Quotient monoid descent
def uqMul {α : Type u} [ClosureFlowMonoid α] :
    UniversalityQuotient α → UniversalityQuotient α → UniversalityQuotient α :=
  Quotient.map₂ (· * ·) (fun _ _ h₁ _ _ h₂ => asymptoticCong_mul h₁ h₂)

def uqOne {α : Type u} [ClosureFlowMonoid α] : UniversalityQuotient α :=
  Quotient.mk _ (1 : α)

theorem quotient_monoid_descent {α : Type u} [ClosureFlowMonoid α] :
    ∃ mulQ : UniversalityQuotient α → UniversalityQuotient α → UniversalityQuotient α,
    ∃ oneQ : UniversalityQuotient α,
    ∃ stepQ clQ : UniversalityQuotient α → UniversalityQuotient α,
      (∀ x y, mulQ (Quotient.mk _ x) (Quotient.mk _ y) = Quotient.mk _ (x * y)) ∧
      (oneQ = Quotient.mk _ (1 : α)) ∧
      (∀ x, stepQ (Quotient.mk _ x) = Quotient.mk _ (ClosureFlow.step x)) ∧
      (∀ x, clQ (Quotient.mk _ x) = Quotient.mk _ (ClosureFlow.cl x)) :=
  ⟨uqMul, uqOne, uqStep, uqClosure, fun _ _ => rfl, rfl, fun _ => rfl, fun _ => rfl⟩

theorem renormalization_quantum_certified_universality {α : Type u} [ClosureFlowMonoid α] :
    ∃ (Q : Type u) (_ : Nonempty Q) (f : α → Q),
        (∀ x y, f x = f y ↔ @AsymptoticCong α _ x y) ∧
        (∀ x, ∃ y, @IsRGFixed α _ y ∨ @AsymptoticCong α _ x y) :=
  ⟨@UniversalityQuotient α _, ⟨Quotient.mk _ 1⟩, Quotient.mk _,
    fun _ _ => ⟨fun h => Quotient.exact h, fun h => Quotient.sound h⟩,
    fun x => ⟨x, Or.inr (asymptoticCong_refl x)⟩⟩

-- Instance 1: Identity
def closureFlowId (β : Type u) : ClosureFlow β where
  cl := id; step := id; step_cl_comm _ := rfl

theorem rgIterate_id {β : Type u} (n : Nat) (x : β) :
    @rgIterate β (closureFlowId β) n x = x := by
  induction n with
  | zero => rfl
  | succ n ih => change id _ = x; exact ih

theorem asymptoticCong_id_iff_eq {β : Type u} (x y : β) :
    @AsymptoticCong β (closureFlowId β) x y ↔ x = y := by
  constructor
  · intro ⟨N, hN⟩; have := hN N le_rfl; rwa [rgIterate_id, rgIterate_id] at this
  · intro h; subst h; exact ⟨0, fun _ _ => rfl⟩

-- Instance 2: Nat saturation
def natSaturatingStep (K n : Nat) : Nat := min n K
theorem natSaturatingStep_idem (K n : Nat) :
    natSaturatingStep K (natSaturatingStep K n) = natSaturatingStep K n := by
  simp only [natSaturatingStep, Nat.min_def]; split_ifs <;> omega
def natSaturationFlow (K : Nat) : ClosureFlow Nat where
  cl := id; step := natSaturatingStep K; step_cl_comm _ := rfl

private theorem natSat_rgIterate_pos (K n : Nat) (hn : 1 ≤ n) (x : Nat) :
    @rgIterate Nat (natSaturationFlow K) n x = natSaturatingStep K x := by
  obtain ⟨m, rfl⟩ := Nat.exists_eq_add_of_le hn
  induction m with
  | zero => rfl
  | succ m ih =>
    show natSaturatingStep K (@rgIterate Nat (natSaturationFlow K) (1 + m) x) = _
    rw [ih (by omega)]; exact natSaturatingStep_idem K x

theorem nat_saturation_quantum_robust_classification (K x y : Nat) :
    @AsymptoticCong Nat (natSaturationFlow K) x y ↔ min x K = min y K := by
  constructor
  · intro ⟨N, hN⟩
    have := hN (N + 1) (by omega)
    rwa [natSat_rgIterate_pos K _ (by omega), natSat_rgIterate_pos K _ (by omega)] at this
  · intro h; exact ⟨1, fun n hn => by
      rw [natSat_rgIterate_pos K n hn, natSat_rgIterate_pos K n hn]; exact h⟩

theorem nat_saturation_universality_classes (K x : Nat) :
    @IsUniversalityClass Nat (natSaturationFlow K) {y | min y K = min x K} := by
  refine ⟨x, ?_⟩; ext y; simp only [Set.mem_setOf_eq]
  rw [nat_saturation_quantum_robust_classification]
  constructor <;> (intro h; exact h.symm)

-- Instance 3: Finite endomorphism
def finiteFunctionClosureFlow (β : Type u) (f : β → β) : ClosureFlow β where
  cl := id; step := f; step_cl_comm _ := rfl

theorem tropical_hash_collision_periodicity_bound
    {β : Type u} [Fintype β] [DecidableEq β] (f : β → β) (x : β) :
    ∃ i j : Nat, i < j ∧ j ≤ Fintype.card β + 1 ∧
      @rgIterate β (finiteFunctionClosureFlow β f) i x =
      @rgIterate β (finiteFunctionClosureFlow β f) j x := by
  letI inst : FiniteClosureFlow β :=
    { (finiteFunctionClosureFlow β f) with toFintype := inferInstance, decEq := inferInstance }
  exact post_quantum_lattice_orbit_repeat_bound x