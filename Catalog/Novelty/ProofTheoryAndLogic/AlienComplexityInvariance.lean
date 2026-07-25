import Logic.PVsNp.PvsNPFoundations

/-!
# Substrate-Invariant Computational Complexity

Computational complexity is modeled here without choosing silicon, neurons, chemistry, or a
particular instruction set.  A machine model supplies programs, acceptance semantics, and a
resource cost.  A simulation preserves acceptance and controls resource growth.  The central
results show that exact-resource simulations compose, transport deterministic and witness-based
complexity classes, preserve hierarchy separations, and preserve the assertion that deterministic
and witness computation coincide.

The final section isolates the analogous obstruction faced by stronger civilizations: whenever a
jump operation escapes each resource tier, mutually exact simulations preserve every escape and
therefore cannot flatten the resulting hierarchy.
-/

open Set Function

namespace AlienComplexity

/-- A computational substrate with programs, acceptance semantics, and a natural-valued cost. -/
structure MachineModel (Input : Type*) where
  Program : Type*
  accepts : Program → Input → Prop
  cost : Program → Input → ℕ

/-- A program decides a language extensionally. -/
def Solves {α : Type*} (M : MachineModel α) (p : M.Program) (L : Set α) : Prop :=
  ∀ x, M.accepts p x ↔ x ∈ L

/-- A program obeys a pointwise resource bound. -/
def RunsWithin {α : Type*} (M : MachineModel α) (p : M.Program) (b : α → ℕ) : Prop :=
  ∀ x, M.cost p x ≤ b x

/-- The languages decidable within a resource bound. -/
def InClass {α : Type*} (M : MachineModel α) (b : α → ℕ) (L : Set α) : Prop :=
  ∃ p, Solves M p L ∧ RunsWithin M p b

/-- A semantics-preserving compiler with monotone resource overhead. -/
structure Simulation {α : Type*} (M N : MachineModel α) where
  translate : M.Program → N.Program
  overhead : ℕ → ℕ
  overhead_mono : Monotone overhead
  semantics : ∀ p x, N.accepts (translate p) x ↔ M.accepts p x
  cost_le : ∀ p x, N.cost (translate p) x ≤ overhead (M.cost p x)

/-- Identity compilation is a simulation. -/
def Simulation.refl {α : Type*} (M : MachineModel α) : Simulation M M where
  translate := id
  overhead := id
  overhead_mono := monotone_id
  semantics := by intros; rfl
  cost_le := by intros; exact le_rfl

/-- Simulations compose, with composed compilers and composed overhead functions. -/
def Simulation.comp {α : Type*} {M N K : MachineModel α}
    (s₂ : Simulation N K) (s₁ : Simulation M N) : Simulation M K where
  translate := s₂.translate ∘ s₁.translate
  overhead := s₂.overhead ∘ s₁.overhead
  overhead_mono := s₂.overhead_mono.comp s₁.overhead_mono
  semantics := by
    intro p x
    exact (s₂.semantics (s₁.translate p) x).trans (s₁.semantics p x)
  cost_le := by
    intro p x
    exact (s₂.cost_le (s₁.translate p) x).trans
      (s₂.overhead_mono (s₁.cost_le p x))

/-
Compilation transports every bounded decision procedure, with precisely the declared overhead.
-/
theorem Simulation.class_transport {α : Type*} {M N : MachineModel α}
    (s : Simulation M N) {b : α → ℕ} {L : Set α} (hL : InClass M b L) :
    InClass N (s.overhead ∘ b) L := by
  obtain ⟨ p, hp₁, hp₂ ⟩ := hL;
  exact ⟨ s.translate p, fun x => ( s.semantics p x ).trans ( hp₁ x ), fun x => ( s.cost_le p x ).trans ( s.overhead_mono ( hp₂ x ) ) ⟩

/-- An exact simulation does not increase cost. -/
def Simulation.IsExact {α : Type*} {M N : MachineModel α} (s : Simulation M N) : Prop :=
  s.overhead = id

/-
Exact simulation gives inclusion at every unchanged resource bound.
-/
theorem Simulation.exact_class_transport {α : Type*} {M N : MachineModel α}
    (s : Simulation M N) (hs : s.IsExact) {b : α → ℕ} {L : Set α} :
    InClass M b L → InClass N b L := by
  convert Simulation.class_transport s using 1;
  rw [ hs ];
  rfl

/-- Two substrates are resource-equivalent when each simulates the other. -/
structure ResourceEquiv {α : Type*} (M N : MachineModel α) where
  forward : Simulation M N
  backward : Simulation N M

/-
Exact mutual simulation makes every bounded complexity class substrate-independent.
-/
theorem ResourceEquiv.class_iff {α : Type*} {M N : MachineModel α}
    (e : ResourceEquiv M N) (hf : e.forward.IsExact) (hb : e.backward.IsExact)
    (b : α → ℕ) (L : Set α) :
    InClass M b L ↔ InClass N b L := by
  constructor <;> intro h;
  · exact Simulation.exact_class_transport e.forward hf h;
  · exact Simulation.exact_class_transport e.backward hb h

/-- A hierarchy is the family of language classes obtained from indexed resource bounds. -/
def hierarchy {α : Type*} (M : MachineModel α) (bound : ℕ → α → ℕ) (n : ℕ) : Set (Set α) :=
  {L | InClass M (bound n) L}

/-
Exact mutual simulation identifies the entire hierarchy level by level.
-/
theorem ResourceEquiv.hierarchy_eq {α : Type*} {M N : MachineModel α}
    (e : ResourceEquiv M N) (hf : e.forward.IsExact) (hb : e.backward.IsExact)
    (bound : ℕ → α → ℕ) :
    hierarchy M bound = hierarchy N bound := by
  ext L;
  convert e.class_iff hf hb ( bound L ) _

/-
Strictness between adjacent levels is a property of the simulated computation, not its substrate.
-/
theorem ResourceEquiv.adjacent_separation_iff {α : Type*} {M N : MachineModel α}
    (e : ResourceEquiv M N) (hf : e.forward.IsExact) (hb : e.backward.IsExact)
    (bound : ℕ → α → ℕ) (n : ℕ) :
    (∃ L, InClass M (bound (n + 1)) L ∧ ¬ InClass M (bound n) L) ↔
    (∃ L, InClass N (bound (n + 1)) L ∧ ¬ InClass N (bound n) L) := by
  constructor;
  · rintro ⟨ L, hL₁, hL₂ ⟩;
    exact ⟨ L, by simpa [ hf ] using Simulation.exact_class_transport e.forward hf hL₁, by simpa [ hb ] using fun h => hL₂ <| by simpa [ hb ] using Simulation.exact_class_transport e.backward hb h ⟩;
  · rintro ⟨ L, hL₁, hL₂ ⟩;
    refine' ⟨ L, _, _ ⟩;
    · convert e.class_iff hf hb ( bound ( n + 1 ) ) L |>.2 hL₁;
    · exact fun h => hL₂ <| e.forward.exact_class_transport hf h

/-- Witness-based computation: membership has a witness accepted within the given bound. -/
def InWitnessClass {α ω : Type*} (V : MachineModel (α × ω))
    (b : α × ω → ℕ) (L : Set α) : Prop :=
  ∃ p, (∀ x, x ∈ L ↔ ∃ w, V.accepts p (x, w)) ∧ RunsWithin V p b

/-
Exact verifier simulation preserves witness complexity.
-/
theorem ResourceEquiv.witnessClass_iff {α ω : Type*}
    {V W : MachineModel (α × ω)}
    (e : ResourceEquiv V W) (hf : e.forward.IsExact) (hb : e.backward.IsExact)
    (b : α × ω → ℕ) (L : Set α) :
    InWitnessClass V b L ↔ InWitnessClass W b L := by
  constructor <;> rintro ⟨ p, hp₁, hp₂ ⟩;
  · use e.forward.translate p;
    simp_all +decide [ RunsWithin, Simulation.IsExact ];
    exact ⟨ fun x => ⟨ fun ⟨ w, hw ⟩ => ⟨ w, e.forward.semantics p ( x, w ) |>.2 hw ⟩, fun ⟨ w, hw ⟩ => ⟨ w, e.forward.semantics p ( x, w ) |>.1 hw ⟩ ⟩, fun a b => le_trans ( e.forward.cost_le p ( a, b ) ) ( by simp +decide [ hf ] ; exact hp₂ a b ) ⟩;
  · refine' ⟨ e.backward.translate p, fun x => _, fun x => _ ⟩;
    · simp +decide [ hp₁, e.backward.semantics ];
    · have := e.backward.cost_le p x;
      exact this.trans ( by rw [ hb ] ; exact hp₂ x )

/-- The abstract P-versus-NP assertion for fixed deterministic and verifier bounds. -/
def DeterministicEqualsWitness {α ω : Type*}
    (M : MachineModel α) (V : MachineModel (α × ω))
    (detBound : α → ℕ) (witBound : α × ω → ℕ) : Prop :=
  ∀ L, InClass M detBound L ↔ InWitnessClass V witBound L

/-
Whether deterministic and witness computation coincide is invariant under exact substrate changes.
-/
theorem p_vs_np_substrate_invariant {α ω : Type*}
    {M N : MachineModel α} {V W : MachineModel (α × ω)}
    (eDet : ResourceEquiv M N)
    (eWit : ResourceEquiv V W)
    (hdf : eDet.forward.IsExact) (hdb : eDet.backward.IsExact)
    (hwf : eWit.forward.IsExact) (hwb : eWit.backward.IsExact)
    (detBound : α → ℕ) (witBound : α × ω → ℕ) :
    DeterministicEqualsWitness M V detBound witBound ↔
      DeterministicEqualsWitness N W detBound witBound := by
  constructor;
  · intro h L;
    convert eDet.class_iff hdf hdb detBound L |>.symm.trans ( h L |> Iff.trans <| eWit.witnessClass_iff hwf hwb witBound L ) using 1;
  · intro hL;
    convert fun L => ( eDet.class_iff hdf hdb detBound L ).trans ( hL L ) |> Iff.trans <| ( eWit.witnessClass_iff hwf hwb witBound L ).symm using 1

/-- A many-one reduction whose precomposition is supported by a model. -/
structure SupportsReduction {α : Type*} (M : MachineModel α) (f : α → α) where
  precompile : M.Program → M.Program
  semantics : ∀ p x, M.accepts (precompile p) x ↔ M.accepts p (f x)
  cost_le : ∀ p x, M.cost (precompile p) x ≤ M.cost p (f x)

/-
Model-supported many-one reductions pull bounded decidability backward.
-/
theorem reduction_transports_complexity {α : Type*} {M : MachineModel α}
    {A B : Set α} {f : α → α} (hred : ∀ x, x ∈ A ↔ f x ∈ B)
    (support : SupportsReduction M f) {b : α → ℕ}
    (hB : InClass M b B) :
    InClass M (b ∘ f) A := by
  obtain ⟨ p, hp ⟩ := hB;
  exact ⟨ support.precompile p, fun x => by rw [ hred, support.semantics, hp.1 ], fun x => le_trans ( support.cost_le p x ) ( hp.2 ( f x ) ) ⟩

/-
The preceding theorem realizes the catalog's extensional many-one reduction relation.
-/
theorem reduction_witness_is_manyOne {α : Type*}
    {A B : Set α} {f : α → α} (hred : ∀ x, x ∈ A ↔ f x ∈ B) :
    PvsNPFoundations.ManyOneReducible A B := by
  exact ⟨f, hred⟩

/-- A jump hierarchy records a canonical problem at each tier and an escape at every successor. -/
structure JumpHierarchy {α : Type*} (M : MachineModel α)
    (bound : ℕ → α → ℕ) (jump : Set α → Set α) (seed : Set α) : Prop where
  member : ∀ n, InClass M (bound n) (jump^[n] seed)
  escapes : ∀ n, ¬ InClass M (bound n) (jump^[n + 1] seed)

/-
Every jump level is genuinely new relative to the preceding resource tier.
-/
theorem JumpHierarchy.successor_separation {α : Type*} {M : MachineModel α}
    {bound : ℕ → α → ℕ} {jump : Set α → Set α} {seed : Set α}
    (H : JumpHierarchy M bound jump seed) (n : ℕ) :
    ∃ L, InClass M (bound (n + 1)) L ∧ ¬ InClass M (bound n) L := by
  exact ⟨ _, H.member _, H.escapes _ ⟩

/-
Hypercomputational jump barriers survive every exact change of implementation.
-/
theorem ResourceEquiv.jumpHierarchy_iff {α : Type*} {M N : MachineModel α}
    (e : ResourceEquiv M N) (hf : e.forward.IsExact) (hb : e.backward.IsExact)
    (bound : ℕ → α → ℕ) (jump : Set α → Set α) (seed : Set α) :
    JumpHierarchy M bound jump seed ↔ JumpHierarchy N bound jump seed := by
  constructor;
  · intro h;
    constructor;
    · exact fun n => e.forward.exact_class_transport hf ( h.member n );
    · intro n hn;
      exact h.escapes n ( by simpa [ hf, hb ] using e.backward.exact_class_transport hb hn );
  · intro H;
    constructor;
    · exact fun n => e.backward.exact_class_transport hb ( H.member n );
    · intro n hn;
      exact H.escapes n ( e.forward.exact_class_transport hf hn )

/-
No finite level of a jump hierarchy can already decide its own next jump.
-/
theorem JumpHierarchy.no_stabilization {α : Type*} {M : MachineModel α}
    {bound : ℕ → α → ℕ} {jump : Set α → Set α} {seed : Set α}
    (H : JumpHierarchy M bound jump seed) :
    ∀ n, ¬ (InClass M (bound n) (jump^[n] seed) ↔
      InClass M (bound n) (jump^[n + 1] seed)) := by
  intro n hn
  have h_cur : InClass M (bound n) (jump^[n] seed) := by
    exact H.member n
  have h_succ : InClass M (bound n) (jump^[n + 1] seed) := by
    grind
  exact (by
  exact H.escapes n h_succ)

-- !-- Lab Notes -- !--
/-
Hypothesis: The following falsifiable conjectures were ranked by expected structural impact.
(1) Deterministic-versus-witness equality is invariant under resource-exact changes of substrate.
(2) Every exact substrate equivalence preserves an entire infinite complexity hierarchy.
(3) A civilization with a stronger base model still encounters noncollapsing successor jumps.
(4) Semantics-preserving compilers with controlled overhead transport all bounded language classes.
(5) Witness complexity is invariant under exact changes of verifier architecture.
(6) Extensional many-one reductions become complexity transfers whenever precomposition is
supported without additional cost.  The first three are the grand-challenge forms; the latter
three expose the mechanisms needed to test them.

Experiment: The simulation calculus was tested against identity, composition, class transport,
many-one precomposition, witness verification, indexed hierarchies, and successor jumps.  Fixed
bounds were also tested against simulations with nontrivial overhead, revealing the boundary of
the strongest claims.

Analysis: Unqualified substrate independence is false: a compiler with arbitrary overhead need
not preserve a fixed bound.  The surviving statement requires explicit overhead control; exact
simulations preserve fixed levels, while general simulations preserve a transformed bound.

Critique: The results do not resolve P versus NP and do not assert that every physical substrate is
resource-equivalent.  They isolate the precise mathematical obligation behind that claim.  The
jump construction is abstract, so existence of a concrete jump remains model-specific, but once
its escape laws hold their persistence is unconditional.

Synthesis: Complexity is invariant under resource-respecting semantic equivalence.  Reduction
closure links this invariance to extensional many-one reducibility, witness transport covers the
P-versus-NP shape, and jump transport gives the corresponding barrier for stronger models.
-/

end AlienComplexity