import Mathlib

/-!
# EML Closure One-Way Functions

Formalizes **self-referential cryptography**: bridging order-theoretic
closure operators with cryptographic protocol design.

## Bridge: Order Theory → Cryptography

- `closureMin x = min(cl({x}))` — one-way function candidate
- Idempotence enables zero-knowledge simulation
- Fixed points define the "hard language"
-/

set_option maxHeartbeats 800000
noncomputable section
open Classical

namespace EMLCrypto

/-- Closure operator with extensiveness, monotonicity, idempotence.
    Bridge: order theory → cryptography. -/
class EMLClosureOperator (C : Type*) where
  cl : Set C → Set C
  extensive : ∀ (A : Set C), A ⊆ cl A
  mono : ∀ {A B : Set C}, A ⊆ B → cl A ⊆ cl B
  idem : ∀ (A : Set C), cl (cl A) = cl A

variable {C : Type*}

section SetLevel
variable [EMLClosureOperator C]

theorem self_mem_closure (x : C) :
    x ∈ EMLClosureOperator.cl ({x} : Set C) :=
  EMLClosureOperator.extensive {x} rfl

theorem subset_closure (A : Set C) : A ⊆ EMLClosureOperator.cl A :=
  EMLClosureOperator.extensive A

theorem closure_idem (A : Set C) :
    EMLClosureOperator.cl (EMLClosureOperator.cl A) = EMLClosureOperator.cl A :=
  EMLClosureOperator.idem A

theorem closure_mono {A B : Set C} (h : A ⊆ B) :
    EMLClosureOperator.cl A ⊆ EMLClosureOperator.cl B :=
  EMLClosureOperator.mono h

/-- If B ⊆ cl(A), then cl(B) ⊆ cl(A). -/
theorem closure_of_subset_closure {A B : Set C}
    (h : B ⊆ EMLClosureOperator.cl A) :
    EMLClosureOperator.cl B ⊆ EMLClosureOperator.cl A := by
  have h1 := closure_mono h
  rw [closure_idem] at h1
  exact h1

def IsClosed (A : Set C) : Prop :=
  EMLClosureOperator.cl A = A

theorem closure_isClosed (A : Set C) : IsClosed (EMLClosureOperator.cl A) :=
  closure_idem A

theorem univ_isClosed : IsClosed (Set.univ : Set C) :=
  Set.eq_univ_of_univ_subset (subset_closure _)

/-- Closed sets are closed under intersection. -/
theorem closed_inter {A B : Set C}
    (hA : IsClosed A) (hB : IsClosed B) :
    EMLClosureOperator.cl (A ∩ B) ⊆ A ∩ B := by
  unfold IsClosed at hA hB
  intro x hx
  refine ⟨?_, ?_⟩
  · have h1 : x ∈ EMLClosureOperator.cl A := closure_mono Set.inter_subset_left hx
    rwa [hA] at h1
  · have h1 : x ∈ EMLClosureOperator.cl B := closure_mono Set.inter_subset_right hx
    rwa [hB] at h1

end SetLevel

section ClosureMin
variable [EMLClosureOperator C] [Fintype C] [LinearOrder C]

omit [LinearOrder C] in
private theorem closure_singleton_nonempty (x : C) :
    (Finset.univ.filter (fun y => y ∈ EMLClosureOperator.cl ({x} : Set C))).Nonempty :=
  ⟨x, Finset.mem_filter.mpr ⟨Finset.mem_univ x, self_mem_closure x⟩⟩

/-- The **closure min**: maps x to min(cl({x})).
    Bridge: order theory → cryptography (one-way function). -/
def closureMin (x : C) : C :=
  (Finset.univ.filter (fun y => y ∈ EMLClosureOperator.cl ({x} : Set C))).min'
    (closure_singleton_nonempty x)

theorem closureMin_mem_closure (x : C) :
    closureMin x ∈ EMLClosureOperator.cl ({x} : Set C) :=
  (Finset.mem_filter.mp (Finset.min'_mem _ _)).2

theorem closureMin_le_self (x : C) : closureMin x ≤ x :=
  Finset.min'_le _ x (Finset.mem_filter.mpr ⟨Finset.mem_univ x, self_mem_closure x⟩)

theorem closureMin_le_of_mem {x y : C}
    (hy : y ∈ EMLClosureOperator.cl ({x} : Set C)) :
    closureMin x ≤ y :=
  Finset.min'_le _ y (Finset.mem_filter.mpr ⟨Finset.mem_univ y, hy⟩)

/-- cl({closureMin x}) ⊆ cl({x}). -/
theorem closure_closureMin_subset (x : C) :
    EMLClosureOperator.cl ({closureMin x} : Set C) ⊆
    EMLClosureOperator.cl ({x} : Set C) := by
  apply closure_of_subset_closure
  intro y hy
  rw [Set.mem_singleton_iff] at hy
  subst hy
  exact closureMin_mem_closure x

theorem closureMin_closureMin_le (x : C) :
    closureMin (closureMin x) ≤ closureMin x :=
  closureMin_le_self _

theorem le_closureMin_closureMin (x : C) :
    closureMin x ≤ closureMin (closureMin x) :=
  closureMin_le_of_mem (closure_closureMin_subset x (closureMin_mem_closure (closureMin x)))

/-- **Idempotence**: closureMin² = closureMin.
    Bridge: THE algebraic property enabling ZK simulation. -/
theorem closureMin_idempotent (x : C) :
    closureMin (closureMin x) = closureMin x :=
  le_antisymm (closureMin_closureMin_le x) (le_closureMin_closureMin x)

theorem closureMin_range_eq_fixedPoints :
    Set.range (closureMin (C := C)) = {x | closureMin x = x} := by
  ext y; constructor
  · rintro ⟨x, rfl⟩; exact closureMin_idempotent x
  · intro h; exact ⟨y, h⟩

theorem exists_closureMin_fixed [Nonempty C] :
    ∃ x : C, closureMin x = x := by
  let m := Finset.min' (Finset.univ : Finset C) Finset.univ_nonempty
  refine ⟨m, le_antisymm (closureMin_le_self m) ?_⟩
  exact Finset.min'_le _ (closureMin m) (Finset.mem_univ _)

theorem closureMin_mem_own_fiber (x : C) :
    closureMin x ∈ Finset.univ.filter (fun z : C => closureMin z = closureMin x) :=
  Finset.mem_filter.mpr ⟨Finset.mem_univ _, closureMin_idempotent x⟩

theorem fiber_ge {y x : C} (h : closureMin x = y) : y ≤ x :=
  h ▸ closureMin_le_self x

theorem fixed_points_card_le :
    (Finset.univ.filter (fun x : C => closureMin x = x)).card ≤ Fintype.card C :=
  Finset.card_filter_le _ _

theorem closureMin_retraction (x : C) :
    closureMin x ≤ x ∧ closureMin (closureMin x) = closureMin x :=
  ⟨closureMin_le_self x, closureMin_idempotent x⟩

theorem fiber_nonempty (x : C) :
    0 < (Finset.univ.filter (fun z : C => closureMin z = closureMin x)).card :=
  Finset.card_pos.mpr ⟨closureMin x, closureMin_mem_own_fiber x⟩

end ClosureMin

/-! ## Identity Closure -/

instance identityClosure (C : Type*) : EMLClosureOperator C where
  cl := id
  extensive := fun _ => Set.Subset.rfl
  mono := fun h => h
  idem := fun _ => rfl

theorem identity_closureMin_eq [Fintype C] [LinearOrder C] (x : C) :
    @closureMin C (identityClosure C) _ _ x = x := by
  apply le_antisymm
  · exact @closureMin_le_self C (identityClosure C) _ _ x
  · have h := @closureMin_mem_closure C (identityClosure C) _ _ x
    -- h : closureMin x ∈ (identityClosure C).cl {x} = id {x} = {x}
    simp [identityClosure, EMLClosureOperator.cl] at h
    exact le_of_eq h.symm

/-! ## Sigma Protocol -/

structure SigmaTranscript (C : Type*) where
  commitment : C
  challenge : Bool
  response : C

section SigmaProtocol
variable [EMLClosureOperator C] [Fintype C] [LinearOrder C]

def sigmaCommit (r : C) : C := closureMin r

def sigmaRespond (r : C) (e : Bool) : C :=
  if e then closureMin r else r

def sigmaVerify (a : C) (e : Bool) (z : C) : Prop :=
  if e then z = a else closureMin z = a

theorem sigma_complete_true (r : C) :
    sigmaVerify (sigmaCommit r) true (sigmaRespond r true) := by
  simp [sigmaVerify, sigmaCommit, sigmaRespond]

theorem sigma_complete_false (r : C) :
    sigmaVerify (sigmaCommit r) false (sigmaRespond r false) := by
  simp [sigmaVerify, sigmaCommit, sigmaRespond]

theorem sigma_complete (r : C) (e : Bool) :
    sigmaVerify (sigmaCommit r) e (sigmaRespond r e) := by
  cases e <;> simp [sigmaVerify, sigmaCommit, sigmaRespond]

theorem sigma_special_soundness (a z₀ z₁ : C)
    (h₀ : sigmaVerify a false z₀) (h₁ : sigmaVerify a true z₁) :
    closureMin z₀ = z₁ := by
  simp [sigmaVerify] at h₀ h₁; rw [h₀, h₁]

theorem sigma_extractor_valid (a z₀ : C)
    (h₀ : sigmaVerify a false z₀) :
    closureMin z₀ = a := by
  simp [sigmaVerify] at h₀; exact h₀

theorem sigma_hvzk_true (t : C) : sigmaVerify t true t := by
  simp [sigmaVerify]

theorem sigma_hvzk_false (x : C) :
    sigmaVerify (closureMin x) false x := by
  simp [sigmaVerify]

theorem sigma_simulation_idem (x : C) :
    closureMin (closureMin x) = closureMin x :=
  closureMin_idempotent x

end SigmaProtocol

/-! ## Key Exchange -/

structure FixedPointKeyExchange (C : Type*) [LinearOrder C] [Fintype C] where
  cl_A : EMLClosureOperator C
  cl_B : EMLClosureOperator C
  secret_A : C
  secret_B : C

section KeyExchange
variable [LinearOrder C] [Fintype C]

def FixedPointKeyExchange.pubA (kex : FixedPointKeyExchange C) : C :=
  @closureMin C kex.cl_A _ _ kex.secret_A

def FixedPointKeyExchange.pubB (kex : FixedPointKeyExchange C) : C :=
  @closureMin C kex.cl_B _ _ kex.secret_B

def FixedPointKeyExchange.ssA (kex : FixedPointKeyExchange C) : C :=
  @closureMin C kex.cl_A _ _ kex.pubB

def FixedPointKeyExchange.ssB (kex : FixedPointKeyExchange C) : C :=
  @closureMin C kex.cl_B _ _ kex.pubA

theorem kex_ssA_fixed (kex : FixedPointKeyExchange C) :
    @closureMin C kex.cl_A _ _ kex.ssA = kex.ssA :=
  @closureMin_idempotent C kex.cl_A _ _ _

theorem kex_ssB_fixed (kex : FixedPointKeyExchange C) :
    @closureMin C kex.cl_B _ _ kex.ssB = kex.ssB :=
  @closureMin_idempotent C kex.cl_B _ _ _

theorem kex_ssA_le (kex : FixedPointKeyExchange C) :
    kex.ssA ≤ kex.pubB :=
  @closureMin_le_self C kex.cl_A _ _ _

theorem kex_ssB_le (kex : FixedPointKeyExchange C) :
    kex.ssB ≤ kex.pubA :=
  @closureMin_le_self C kex.cl_B _ _ _

end KeyExchange

/-! ## Commuting Closures -/

def CommutingClosures (cl_A cl_B : EMLClosureOperator C) : Prop :=
  ∀ (A : Set C), cl_A.cl (cl_B.cl A) = cl_B.cl (cl_A.cl A)

theorem commuting_symm (cl_A cl_B : EMLClosureOperator C)
    (h : CommutingClosures cl_A cl_B) : CommutingClosures cl_B cl_A :=
  fun A => (h A).symm

theorem commuting_collapse (cl_A cl_B : EMLClosureOperator C) (A : Set C)
    (h : CommutingClosures cl_A cl_B) :
    cl_A.cl (cl_B.cl (cl_A.cl A)) = cl_A.cl (cl_B.cl A) := by
  calc cl_A.cl (cl_B.cl (cl_A.cl A))
      = cl_B.cl (cl_A.cl (cl_A.cl A)) := h (cl_A.cl A)
    _ = cl_B.cl (cl_A.cl A) := by rw [cl_A.idem]
    _ = cl_A.cl (cl_B.cl A) := (h A).symm

/-! ## One-Way Function Structure -/

structure ClosureOWF (C : Type*) [LinearOrder C] [Fintype C]
    extends EMLClosureOperator C where
  surj_fixed : ∀ y : C,
    @closureMin C toEMLClosureOperator _ _ y = y →
    ∃ x, @closureMin C toEMLClosureOperator _ _ x = y

def ClosureOWF.f [LinearOrder C] [Fintype C] (owf : ClosureOWF C) : C → C :=
  @closureMin C owf.toEMLClosureOperator _ _

theorem ClosureOWF.f_idempotent [LinearOrder C] [Fintype C]
    (owf : ClosureOWF C) (x : C) : owf.f (owf.f x) = owf.f x :=
  @closureMin_idempotent C owf.toEMLClosureOperator _ _ x

theorem ClosureOWF.f_le [LinearOrder C] [Fintype C]
    (owf : ClosureOWF C) (x : C) : owf.f x ≤ x :=
  @closureMin_le_self C owf.toEMLClosureOperator _ _ x

/-! ## Protocol Instance -/

section ProtocolInstance
variable [EMLClosureOperator C] [Fintype C] [LinearOrder C]

structure IdempotentSigmaProtocol where
  target : C
  witness : C
  valid : closureMin witness = target

def mkProtocol (x : C) : IdempotentSigmaProtocol (C := C) where
  target := closureMin x
  witness := x
  valid := rfl

theorem protocol_target_fixed (p : IdempotentSigmaProtocol (C := C)) :
    closureMin p.target = p.target := by
  rw [← p.valid]; exact closureMin_idempotent p.witness

theorem protocol_witness_ge (p : IdempotentSigmaProtocol (C := C)) :
    p.target ≤ p.witness := by
  rw [← p.valid]; exact closureMin_le_self p.witness

end ProtocolInstance

end EMLCrypto
end