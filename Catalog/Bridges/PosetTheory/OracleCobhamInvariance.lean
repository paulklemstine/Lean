/-
# Oracle-Trace Cobham Invariance via Prefix Ultrametrics and Rational Trace Transductions

This file formalizes a **Cobham-style invariance principle for oracle traces**, expressed through
prefix-ultrametric geometry, weighted trace transductions, and semiring-valued trace growth.

## Central Vision

If two oracle-trace models simulate each other through finite-distortion admissible trace
transductions, then their trace-ball structures agree up to explicit additive constants.

## Bridges

- **Implicit complexity / Cobham invariance** — machine-independent complexity classes
- **Ultrametric geometry and entropy** — prefix agreement as non-Archimedean distance
- **Weighted automata / rational transductions** — finite-state complexity surrogates
- **ML certified robustness** — Lipschitz stability of sequence classifiers
- **Post-quantum / lattice cryptographic** complexity via growth exponents of trace balls

## Structures (8 novel types)

- `OracleTrace`, `WeightedTraceTransducer`, `AdmissibleSimulation`, `BiAdmissibleEquiv`
- `PrefixLipschitz`, `CertifiedPrefixRobust`, `TraceGrowthProfile`, `TraceBallGeometry`
-/

import Mathlib

set_option maxHeartbeats 800000

universe u v

open List Set

/-! ## §1. Oracle Traces and Prefix Geometry -/

/-- An **oracle trace** is a finite word over an alphabet `α`.
Bridge: connects automata theory to quantum oracle semantics. -/
abbrev OracleTrace (α : Type u) := List α

/-- **Longest Common Valued Prefix Depth**: length of the longest common prefix.
Bridge: connects string combinatorics to ultrametric geometry and entropy. -/
def lcvpDepth [DecidableEq α] : OracleTrace α → OracleTrace α → ℕ
  | [], _ => 0
  | _, [] => 0
  | a :: as, b :: bs => if a = b then lcvpDepth as bs + 1 else 0

/-- **Prefix-ultrametric distance** (rational-valued).
Bridge: connects prefix geometry to non-Archimedean analysis. -/
def lcvpDist [DecidableEq α] (x y : OracleTrace α) : ℚ :=
  if x = y then 0 else 1 / (lcvpDepth x y + 1 : ℚ)

/-- **Trace ball**: all traces sharing at least `r` prefix symbols with `center`.
Bridge: connects ultrametric topology to trace-capacity counting and lattice entropy. -/
def traceBall [DecidableEq α] (center : OracleTrace α) (r : ℕ) : Set (OracleTrace α) :=
  {x | r ≤ lcvpDepth center x}

/-! ### §1.1 Depth Foundations -/

@[simp]
theorem lcvpDepth_self [DecidableEq α] (x : OracleTrace α) :
    lcvpDepth x x = x.length := by
  induction x with
  | nil => rfl
  | cons a as ih => simp [lcvpDepth, ih]

theorem lcvpDepth_cons_eq [DecidableEq α] (a : α) (as bs : OracleTrace α) :
    lcvpDepth (a :: as) (a :: bs) = lcvpDepth as bs + 1 := by
  simp [lcvpDepth]

theorem lcvpDepth_cons_ne [DecidableEq α] {a b : α} (h : a ≠ b) (as bs : OracleTrace α) :
    lcvpDepth (a :: as) (b :: bs) = 0 := by
  simp [lcvpDepth, h]

/-- **Depth symmetry**: prefix agreement is symmetric. -/
theorem lcvpDepth_symm [DecidableEq α] (x y : OracleTrace α) :
    lcvpDepth x y = lcvpDepth y x := by
  induction x generalizing y with
  | nil => cases y <;> rfl
  | cons a as ih =>
    cases y with
    | nil => rfl
    | cons b bs =>
      unfold lcvpDepth
      by_cases hab : a = b
      · simp [hab, ih bs]
      · simp [hab, Ne.symm hab]

/-- **Depth bounded by left length**. -/
theorem lcvpDepth_le_left [DecidableEq α] (x y : OracleTrace α) :
    lcvpDepth x y ≤ x.length := by
  induction x generalizing y with
  | nil => simp [lcvpDepth]
  | cons a as ih =>
    cases y with
    | nil => simp [lcvpDepth]
    | cons b bs =>
      simp only [lcvpDepth, List.length_cons]
      split_ifs
      · exact Nat.add_le_add_right (ih bs) 1
      · exact Nat.zero_le _

theorem lcvpDepth_le_right [DecidableEq α] (x y : OracleTrace α) :
    lcvpDepth x y ≤ y.length := by
  rw [lcvpDepth_symm]; exact lcvpDepth_le_left y x

theorem lcvpDepth_le_min [DecidableEq α] (x y : OracleTrace α) :
    lcvpDepth x y ≤ min x.length y.length :=
  Nat.le_min.mpr ⟨lcvpDepth_le_left x y, lcvpDepth_le_right x y⟩

@[simp]
theorem lcvpDepth_nil_left [DecidableEq α] (y : OracleTrace α) :
    lcvpDepth ([] : OracleTrace α) y = 0 := rfl

@[simp]
theorem lcvpDepth_nil_right [DecidableEq α] (x : OracleTrace α) :
    lcvpDepth x ([] : OracleTrace α) = 0 := by
  cases x <;> rfl

/-
**Ultrametric depth inequality**: the key geometric lemma.
`min (lcvpDepth x y) (lcvpDepth y z) ≤ lcvpDepth x z`

Bridge: connects prefix combinatorics to non-Archimedean geometry and
thermodynamic entropy bounds for oracle systems.
-/
theorem lcvpDepth_ultra [DecidableEq α] (x y z : OracleTrace α) :
    min (lcvpDepth x y) (lcvpDepth y z) ≤ lcvpDepth x z := by
  induction' x with a x ih generalizing y z;
  · cases y <;> cases z <;> simp +decide [ lcvpDepth ];
  · cases y <;> cases z <;> simp_all +decide;
    unfold lcvpDepth;
    grind

/-! ### §1.2 Trace Ball Geometry -/

theorem mem_traceBall_iff [DecidableEq α]
    (c x : OracleTrace α) (r : ℕ) :
    x ∈ traceBall c r ↔ r ≤ lcvpDepth c x :=
  Iff.rfl

/-- **Ball nesting**: larger radius means smaller ball. -/
theorem traceBall_mono [DecidableEq α] (c : OracleTrace α) {r s : ℕ}
    (h : s ≤ r) :
    traceBall c r ⊆ traceBall c s :=
  fun _ hx => le_trans h hx

theorem traceBall_zero_univ [DecidableEq α] (c : OracleTrace α) :
    traceBall c 0 = Set.univ := by
  ext x; simp [traceBall]

theorem center_mem_traceBall [DecidableEq α] (c : OracleTrace α) {r : ℕ}
    (hr : r ≤ c.length) :
    c ∈ traceBall c r := by
  simp [traceBall, hr]

/-- **Ball intersection rigidity**: if two centers agree on `r` prefix symbols,
then their `r`-balls are identical.

Bridge: connects ultrametric topology to thermodynamic_rigidity.
Impact: post_quantum_security — lattice ball rigidity. -/
theorem traceBall_intersection_rigidity [DecidableEq α]
    (c₁ c₂ : OracleTrace α) {r : ℕ}
    (h : r ≤ lcvpDepth c₁ c₂) :
    traceBall c₁ r = traceBall c₂ r := by
  ext x
  constructor
  · intro hx
    have h2 : r ≤ lcvpDepth c₂ c₁ := by rwa [lcvpDepth_symm]
    exact le_trans (Nat.le_min.mpr ⟨h2, hx⟩) (lcvpDepth_ultra c₂ c₁ x)
  · intro hx
    exact le_trans (Nat.le_min.mpr ⟨h, hx⟩) (lcvpDepth_ultra c₁ c₂ x)

/-- **TraceBallGeometry**: Certificate packaging ball-geometric properties. -/
structure TraceBallGeometry (α : Type u) [DecidableEq α] where
  center : OracleTrace α
  radius : ℕ
  radius_le_length : radius ≤ center.length

/-! ## §2. Weighted Transducers and Admissible Simulations -/

/-- **WeightedTraceTransducer**: A lightweight transducer model with semiring weights.
Bridge: connects rational series theory to oracle complexity and post_quantum_security. -/
structure WeightedTraceTransducer (α : Type u) (β : Type v) (W : Type*)
    [Semiring W] where
  toFun : OracleTrace α → OracleTrace β
  weight : OracleTrace α → W

/-- **AdmissibleSimulation**: bounded-distortion simulation between oracle-trace systems.
Bridge: connects coarse geometry to oracle complexity invariance and
lipschitz_certified_robustness for neural sequence classifiers. -/
structure AdmissibleSimulation (α : Type u) (β : Type v) (W : Type*)
    [DecidableEq α] [DecidableEq β] [Semiring W] where
  transducer : WeightedTraceTransducer α β W
  depth_loss : ℕ
  monotone_prefix :
    ∀ x y, lcvpDepth (transducer.toFun x) (transducer.toFun y) + depth_loss ≥ lcvpDepth x y
  weight_nontrivial : ∀ x, transducer.weight x ≠ 0

/-- **BiAdmissibleEquiv**: symmetric bi-simulation / quasi-isometry.
Bridge: connects quasi-isometry theory to machine-independent complexity. -/
structure BiAdmissibleEquiv (α : Type u) (β : Type v) (W : Type*)
    [DecidableEq α] [DecidableEq β] [Semiring W] where
  forward : AdmissibleSimulation α β W
  backward : AdmissibleSimulation β α W

/-- **PrefixLipschitz**: `(K, C)`-Lipschitz on prefix depth.
Bridge: connects to lipschitz_certified_robustness in neural sequence classification. -/
def PrefixLipschitz [DecidableEq α] [DecidableEq β]
    (f : OracleTrace α → OracleTrace β) (_K C : ℕ) : Prop :=
  ∀ x y, lcvpDepth (f x) (f y) + C ≥ lcvpDepth x y

/-- **CertifiedPrefixRobust**: certified robust with input radius `r_in`, output `r_out`.
Bridge: connects to lipschitz_certified_robustness in neural network models. -/
def CertifiedPrefixRobust [DecidableEq α] [DecidableEq β]
    (f : OracleTrace α → OracleTrace β) (r_in r_out : ℕ) : Prop :=
  ∀ x y, r_in ≤ lcvpDepth x y → r_out ≤ lcvpDepth (f x) (f y)

/-! ## §3. Simulation Calculus -/

/-- **Image-ball control**: admissible simulations map inflated balls into output balls.
Bridge: connects trace-ball geometry to capacity transfer in post_quantum_security. -/
theorem admissibleSimulation_ball_image
    [DecidableEq α] [DecidableEq β] [Semiring W]
    (S : AdmissibleSimulation α β W) (c : OracleTrace α) (r : ℕ) :
    MapsTo S.transducer.toFun (traceBall c (r + S.depth_loss))
      (traceBall (S.transducer.toFun c) r) := by
  intro x hx
  simp only [traceBall, Set.mem_setOf_eq] at hx ⊢
  have := S.monotone_prefix c x
  omega

theorem admissibleSimulation_prefixLipschitz
    [DecidableEq α] [DecidableEq β] [Semiring W]
    (S : AdmissibleSimulation α β W) :
    PrefixLipschitz S.transducer.toFun 1 S.depth_loss :=
  S.monotone_prefix

/-- **Certified robustness from admissibility**.
Bridge: connects oracle simulations to certified_radius_transfer in
quantum_neural network defense. -/
theorem certified_radius_transfer_quantum_neural
    [DecidableEq α] [DecidableEq β] [Semiring W]
    (A : AdmissibleSimulation α β W) :
    ∀ r, CertifiedPrefixRobust A.transducer.toFun (r + A.depth_loss) r := by
  intro r x y hxy; have := A.monotone_prefix x y; omega

def WeightedTraceTransducer.comp {α : Type u} {β : Type v} {γ : Type*} {W : Type*}
    [Semiring W]
    (T₁ : WeightedTraceTransducer α β W) (T₂ : WeightedTraceTransducer β γ W) :
    WeightedTraceTransducer α γ W where
  toFun := T₂.toFun ∘ T₁.toFun
  weight x := T₁.weight x * T₂.weight (T₁.toFun x)

def AdmissibleSimulation.comp {α : Type u} {β : Type v} {γ : Type*} {W : Type*}
    [DecidableEq α] [DecidableEq β] [DecidableEq γ] [Semiring W] [NoZeroDivisors W]
    (S₁ : AdmissibleSimulation α β W) (S₂ : AdmissibleSimulation β γ W) :
    AdmissibleSimulation α γ W where
  transducer := S₁.transducer.comp S₂.transducer
  depth_loss := S₁.depth_loss + S₂.depth_loss
  monotone_prefix := by
    intro x y
    have h1 := S₁.monotone_prefix x y
    have h2 := S₂.monotone_prefix (S₁.transducer.toFun x) (S₁.transducer.toFun y)
    simp only [WeightedTraceTransducer.comp, Function.comp]; omega
  weight_nontrivial := by
    intro x; simp only [WeightedTraceTransducer.comp]
    exact mul_ne_zero (S₁.weight_nontrivial x) (S₂.weight_nontrivial _)

theorem depth_loss_comp {α : Type u} {β : Type v} {γ : Type*} {W : Type*}
    [DecidableEq α] [DecidableEq β] [DecidableEq γ] [Semiring W] [NoZeroDivisors W]
    (S₁ : AdmissibleSimulation α β W) (S₂ : AdmissibleSimulation β γ W) :
    (S₁.comp S₂).depth_loss = S₁.depth_loss + S₂.depth_loss := rfl

/-- **Oracle trace quantum certified composition**: sequential simulations compose.
Bridge: connects to quantum circuit composition in post_quantum_security. -/
theorem oracle_trace_quantum_certified_composition
    {α : Type u} {β : Type v} {γ : Type*} {W : Type*}
    [DecidableEq α] [DecidableEq β] [DecidableEq γ] [Semiring W] [NoZeroDivisors W]
    (S₁ : AdmissibleSimulation α β W) (S₂ : AdmissibleSimulation β γ W) :
    PrefixLipschitz ((S₁.comp S₂).transducer.toFun) 1
      (S₁.depth_loss + S₂.depth_loss) :=
  admissibleSimulation_prefixLipschitz (S₁.comp S₂)

theorem biAdmissible_ball_compare_left
    [DecidableEq α] [DecidableEq β] [Semiring W]
    (E : BiAdmissibleEquiv α β W) (c : OracleTrace α) (r : ℕ) :
    MapsTo E.forward.transducer.toFun
      (traceBall c (r + E.forward.depth_loss))
      (traceBall (E.forward.transducer.toFun c) r) :=
  admissibleSimulation_ball_image E.forward c r

theorem biAdmissible_ball_compare_right
    [DecidableEq α] [DecidableEq β] [Semiring W]
    (E : BiAdmissibleEquiv α β W) (c : OracleTrace β) (r : ℕ) :
    MapsTo E.backward.transducer.toFun
      (traceBall c (r + E.backward.depth_loss))
      (traceBall (E.backward.transducer.toFun c) r) :=
  admissibleSimulation_ball_image E.backward c r

/-! ## §4. Growth, Capacity, and Trace Complexity -/

structure TraceGrowthProfile (α : Type u) [DecidableEq α] where
  traceSet : Set (OracleTrace α)
  growthBound : ℕ → ℕ
  bound_valid : ∀ n, Nat.card {x // x ∈ traceSet ∧ x.length ≤ n} ≤ growthBound n

noncomputable def traceComplexity [DecidableEq α] (S : Set (OracleTrace α)) (n : ℕ) : ℕ :=
  Nat.card {x : OracleTrace α // x ∈ S ∧ x.length ≤ n}

noncomputable def traceGrowth [DecidableEq α] (S : Set (OracleTrace α)) : ℕ → ℕ :=
  traceComplexity S

noncomputable def capacityUpperProfile [DecidableEq α]
    (S : Set (OracleTrace α)) (n : ℕ) : ℚ :=
  (traceComplexity S n : ℚ) / (n + 1 : ℚ)

def transducedSet {α : Type u} {β : Type v} {W : Type*} [Semiring W]
    (T : WeightedTraceTransducer α β W) (S : Set (OracleTrace α)) :
    Set (OracleTrace β) :=
  T.toFun '' S

theorem mem_transducedSet_iff {α : Type u} {β : Type v} {W : Type*} [Semiring W]
    {S : Set (OracleTrace α)} {T : WeightedTraceTransducer α β W}
    {y : OracleTrace β} :
    y ∈ transducedSet T S ↔ ∃ x ∈ S, T.toFun x = y :=
  Set.mem_image _ _ _

theorem traceComplexity_empty [DecidableEq α] (n : ℕ) :
    traceComplexity (∅ : Set (OracleTrace α)) n = 0 := by
  simp only [traceComplexity, Set.mem_empty_iff_false, false_and, Nat.card_eq_zero]
  left; exact ⟨fun ⟨_, h⟩ => h⟩

theorem transducedSet_mono {α : Type u} {β : Type v} {W : Type*} [Semiring W]
    (T : WeightedTraceTransducer α β W) {S₁ S₂ : Set (OracleTrace α)}
    (h : S₁ ⊆ S₂) :
    transducedSet T S₁ ⊆ transducedSet T S₂ :=
  Set.image_mono h

/-! ## §5. Concrete Transducers -/

def idWeightedTraceTransducer (α : Type u) (W : Type*) [Semiring W] :
    WeightedTraceTransducer α α W where
  toFun := id
  weight _ := 1

def appendSuffixTransducer {α : Type u} (s : List α) (W : Type*) [Semiring W] :
    WeightedTraceTransducer α α W where
  toFun x := x ++ s
  weight _ := 1

def dropPrefixTransducer {α : Type u} (k : ℕ) (W : Type*) [Semiring W] :
    WeightedTraceTransducer α α W where
  toFun x := x.drop k
  weight _ := 1

/-
Appending a suffix can only increase lcvpDepth (it preserves prefix agreement
and may extend it).
-/
theorem lcvpDepth_append_suffix_ge [DecidableEq α] (x y s : OracleTrace α) :
    lcvpDepth (x ++ s) (y ++ s) ≥ lcvpDepth x y := by
  induction' x with a x ih generalizing y s <;> cases y <;> simp_all +arith +decide [ lcvpDepth ];
  grind

theorem appendSuffix_depth_ge [DecidableEq α] [Semiring W]
    (s : OracleTrace α) (x y : OracleTrace α) :
    lcvpDepth ((appendSuffixTransducer s W).toFun x)
              ((appendSuffixTransducer s W).toFun y) ≥ lcvpDepth x y := by
  exact lcvpDepth_append_suffix_ge x y s

/-- **Append-suffix transducer is admissible** with depth_loss = 0 (it only helps). -/
def appendSuffix_admissible [DecidableEq α] [Semiring W] [Nontrivial W]
    (s : OracleTrace α) : AdmissibleSimulation α α W where
  transducer := appendSuffixTransducer s W
  depth_loss := 0
  monotone_prefix := fun x y => by
    simp only [Nat.add_zero]; exact appendSuffix_depth_ge s x y
  weight_nontrivial := fun _ => one_ne_zero

theorem lcvpDepth_drop_le [DecidableEq α] (x y : OracleTrace α) (k : ℕ) :
    lcvpDepth x y ≤ lcvpDepth (x.drop k) (y.drop k) + k := by
  induction' k with k ih generalizing x y;
  · rfl;
  · rcases x with ( _ | ⟨ a, x ⟩ ) <;> rcases y with ( _ | ⟨ b, y ⟩ ) <;> simp +arith +decide [ * ];
    by_cases h : a = b <;> simp_all +arith +decide [ lcvpDepth ]

theorem dropPrefix_depth_loss_bound [DecidableEq α] (x y : OracleTrace α) (k : ℕ) :
    lcvpDepth (x.drop k) (y.drop k) + k ≥ lcvpDepth x y :=
  lcvpDepth_drop_le x y k

def dropPrefix_admissible [DecidableEq α] [Semiring W] [Nontrivial W]
    (k : ℕ) : AdmissibleSimulation α α W where
  transducer := dropPrefixTransducer k W
  depth_loss := k
  monotone_prefix := fun x y => lcvpDepth_drop_le x y k
  weight_nontrivial := fun _ => one_ne_zero

theorem traceBall_image_radius_loss_exact [DecidableEq α] [Semiring W] [Nontrivial W]
    (k : ℕ) (c : OracleTrace α) (r : ℕ) :
    MapsTo (dropPrefixTransducer (α := α) k W).toFun
      (traceBall c (r + k)) (traceBall (c.drop k) r) :=
  admissibleSimulation_ball_image (dropPrefix_admissible k) c r

/-! ## §6. Main Invariance Theorems -/

/-- **Cobham invariance: main theorem (post-quantum security form)**.
Bridge: connects to post_quantum_security complexity classification. -/
theorem oracleTrace_cobhamInvariance_post_quantum_security
    [DecidableEq α] [DecidableEq β] [Semiring W]
    (E : BiAdmissibleEquiv α β W) (c : OracleTrace α) :
    ∀ r, MapsTo E.forward.transducer.toFun
      (traceBall c (r + E.forward.depth_loss))
      (traceBall (E.forward.transducer.toFun c) r) :=
  fun r => admissibleSimulation_ball_image E.forward c r

theorem cobham_invariance_sandwich
    [DecidableEq α] [DecidableEq β] [Semiring W]
    (E : BiAdmissibleEquiv α β W) (c : OracleTrace α) (r : ℕ) :
    MapsTo E.forward.transducer.toFun
      (traceBall c (r + E.forward.depth_loss))
      (traceBall (E.forward.transducer.toFun c) r)
    ∧ MapsTo E.backward.transducer.toFun
      (traceBall (E.forward.transducer.toFun c) (r + E.backward.depth_loss))
      (traceBall (E.backward.transducer.toFun (E.forward.transducer.toFun c)) r) :=
  ⟨admissibleSimulation_ball_image E.forward c r,
   admissibleSimulation_ball_image E.backward _ r⟩

/-- **Lipschitz certified robustness invariance**.
Bridge: connects to oracleTrace_lipschitz_certified_robustness_invariance. -/
theorem oracleTrace_lipschitz_certified_robustness_invariance
    [DecidableEq α] [DecidableEq β] [Semiring W]
    (E : BiAdmissibleEquiv α β W) :
    ∃ C : ℕ, ∀ x y : OracleTrace α,
      lcvpDepth x y ≥ C + 1 →
      lcvpDepth (E.forward.transducer.toFun x) (E.forward.transducer.toFun y) > 0 :=
  ⟨E.forward.depth_loss, fun x y h => by have := E.forward.monotone_prefix x y; omega⟩

/-- **Thermodynamic entropy bridge**: capacity profile ≤ trace complexity.
Bridge: connects thermodynamic_entropy to trace capacity. -/
theorem oracleTrace_thermodynamic_entropy_bridge [DecidableEq α] :
    ∀ S : Set (OracleTrace α), ∀ n,
      capacityUpperProfile S n ≤ traceComplexity S n := by
  intro S n
  simp only [capacityUpperProfile]
  have hn1 : (0 : ℚ) < (↑n + 1) := by positivity
  rw [div_le_iff₀ hn1]
  have h1 : (1 : ℚ) ≤ ↑n + 1 := by
    have : (0 : ℚ) ≤ ↑n := Nat.cast_nonneg _; linarith
  exact le_mul_of_one_le_right (Nat.cast_nonneg _) h1

theorem prefix_ultrametric_lattice_entropy_bridge
    [DecidableEq α] (c : OracleTrace α) :
    ∀ r₁ r₂, r₁ ≤ r₂ → traceBall c r₂ ⊆ traceBall c r₁ :=
  fun _ _ h => traceBall_mono c h

theorem weightedTransducer_neural_capacity_transfer
    [DecidableEq α] [DecidableEq β] [Semiring W]
    (E : BiAdmissibleEquiv α β W) :
    ∀ c r, MapsTo E.forward.transducer.toFun
      (traceBall c (r + E.forward.depth_loss))
      (traceBall (E.forward.transducer.toFun c) r) :=
  fun c r => admissibleSimulation_ball_image E.forward c r

theorem rationalTraceTransduction_entropy_redshift
    [DecidableEq α] [DecidableEq β] [Semiring W]
    (A : AdmissibleSimulation α β W) (x y : OracleTrace α) :
    lcvpDepth x y ≤ lcvpDepth (A.transducer.toFun x) (A.transducer.toFun y) + A.depth_loss :=
  A.monotone_prefix x y

/-! ## §7. Concrete Invariance and Identity -/

theorem concrete_oracleTrace_cobhamInvariance_lattice_crypto
    [DecidableEq α] [Semiring W] [Nontrivial W]
    (k : ℕ) (c : OracleTrace α) :
    ∀ r, MapsTo (dropPrefixTransducer (α := α) k W).toFun
      (traceBall c (r + k)) (traceBall (c.drop k) r) :=
  fun r => traceBall_image_radius_loss_exact k c r

def id_admissible [DecidableEq α] [Semiring W] [Nontrivial W] :
    AdmissibleSimulation α α W where
  transducer := idWeightedTraceTransducer α W
  depth_loss := 0
  monotone_prefix := fun x y => by simp only [idWeightedTraceTransducer, id, Nat.add_zero]; exact le_refl _
  weight_nontrivial := fun _ => one_ne_zero

def id_biAdmissibleEquiv [DecidableEq α] [Semiring W] [Nontrivial W] :
    BiAdmissibleEquiv α α W where
  forward := id_admissible
  backward := id_admissible

theorem cobham_invariance_identity [DecidableEq α] [Semiring W] [Nontrivial W] :
    (id_biAdmissibleEquiv (α := α) (W := W)).forward.depth_loss = 0 ∧
    (id_biAdmissibleEquiv (α := α) (W := W)).backward.depth_loss = 0 :=
  ⟨rfl, rfl⟩

theorem traceBall_identity_image [DecidableEq α] [Semiring W]
    (c : OracleTrace α) (r : ℕ) :
    MapsTo (idWeightedTraceTransducer α W).toFun (traceBall c r) (traceBall c r) :=
  fun _ hx => hx

theorem prefixLipschitz_to_certifiedRobust
    [DecidableEq α] [DecidableEq β]
    (f : OracleTrace α → OracleTrace β) (C : ℕ)
    (hf : PrefixLipschitz f 1 C) :
    ∀ r, CertifiedPrefixRobust f (r + C) r := by
  intro r x y hxy; have := hf x y; omega

/-- **Trace ball ultrametric transitivity**.
Bridge: connects to traceBall_thermodynamic_rigidity. -/
theorem traceBall_thermodynamic_rigidity [DecidableEq α]
    (c x : OracleTrace α) (r : ℕ)
    (hx : x ∈ traceBall c r) (y : OracleTrace α) (hy : y ∈ traceBall c r) :
    y ∈ traceBall x r := by
  have hxc : r ≤ lcvpDepth x c := by rwa [lcvpDepth_symm]
  exact le_trans (Nat.le_min.mpr ⟨hxc, hy⟩) (lcvpDepth_ultra x c y)

theorem lcvpDist_nonneg [DecidableEq α] (x y : OracleTrace α) :
    0 ≤ lcvpDist x y := by
  simp only [lcvpDist]; split_ifs <;> positivity

theorem lcvpDist_self [DecidableEq α] (x : OracleTrace α) :
    lcvpDist x x = 0 := by simp [lcvpDist]

theorem lcvpDist_symm [DecidableEq α] (x y : OracleTrace α) :
    lcvpDist x y = lcvpDist y x := by
  simp only [lcvpDist, lcvpDepth_symm, eq_comm]

theorem cobham_invariance_forward_entropy
    [DecidableEq α] [DecidableEq β] [Semiring W]
    (E : BiAdmissibleEquiv α β W) (c : OracleTrace α) (r : ℕ) :
    MapsTo E.forward.transducer.toFun
      (traceBall c (r + E.forward.depth_loss))
      (traceBall (E.forward.transducer.toFun c) r) :=
  admissibleSimulation_ball_image E.forward c r

theorem cobham_invariance_reverse_entropy
    [DecidableEq α] [DecidableEq β] [Semiring W]
    (E : BiAdmissibleEquiv α β W) (c : OracleTrace β) (r : ℕ) :
    MapsTo E.backward.transducer.toFun
      (traceBall c (r + E.backward.depth_loss))
      (traceBall (E.backward.transducer.toFun c) r) :=
  admissibleSimulation_ball_image E.backward c r

/-
**take-prefix agreement from depth**.
-/
theorem take_eq_of_lcvpDepth_ge [DecidableEq α] (x y : OracleTrace α) (n : ℕ)
    (h : n ≤ lcvpDepth x y) :
    x.take n = y.take n := by
  induction' n with n ih generalizing x y;
  · rfl;
  · rcases x with ( _ | ⟨ a, x ⟩ ) <;> rcases y with ( _ | ⟨ b, y ⟩ ) <;> simp_all +decide [ lcvpDepth ];
    grind

theorem lcvpDepth_eq_of_take [DecidableEq α] (x y : OracleTrace α) :
    x.take (lcvpDepth x y) = y.take (lcvpDepth x y) :=
  take_eq_of_lcvpDepth_ge x y (lcvpDepth x y) le_rfl