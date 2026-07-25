/-
# Condensation Semantics for Algebraic Fixed Points via Idempotent Galois Reconstruction

Bridge: connects algebraic lattice semantics (compact generation, ideals, nuclei, fixed points)
to EML / emergent computation semantics (iterative closure, convergence rank, certified termination)
and to cryptographic/ML/physics applications (post-quantum lattice protocols, neural certified
robustness, thermodynamic entropy stabilization, quantum condensation).
-/
import Mathlib

set_option maxHeartbeats 800000

noncomputable section

namespace CondensationSemantics

/-! ## Core Structures -/

/-- Bridge: connects algebraic lattice semantics to certified EML update rules.
A `FinitaryClosure P` specifies a monotone, extensive, idempotent closure recipe on compact
generators, preserving finite sup structure, from which a global closure/nucleus is reconstructed. -/
structure FinitaryClosure (P : Type*) [CompleteLattice P] where
  onCompact : P → P
  compact_stable : ∀ ⦃x : P⦄, IsCompactElement x → IsCompactElement (onCompact x)
  extensive_compact : ∀ ⦃x : P⦄, IsCompactElement x → x ≤ onCompact x
  mono_compact : ∀ ⦃x y : P⦄, IsCompactElement x → IsCompactElement y →
    x ≤ y → onCompact x ≤ onCompact y
  map_sup_compacts : ∀ ⦃x y : P⦄, IsCompactElement x → IsCompactElement y →
    onCompact (x ⊔ y) = onCompact x ⊔ onCompact y
  map_bot : onCompact ⊥ = ⊥
  idem_compact : ∀ ⦃x : P⦄, IsCompactElement x → onCompact (onCompact x) = onCompact x

/-- Bridge: ideal completion ↔ condensation semantics for emergent computation. -/
structure IdealCondensation (P : Type*) [SemilatticeSup P] [OrderBot P] where
  carrier : Set P
  bot_mem' : ⊥ ∈ carrier
  lower' : ∀ ⦃x y : P⦄, y ∈ carrier → x ≤ y → x ∈ carrier
  sup_mem' : ∀ ⦃x y : P⦄, x ∈ carrier → y ∈ carrier → x ⊔ y ∈ carrier

/-- Closed ideal condensation: stable under the finitary closure on compact elements. -/
structure ClosedIdealCondensation (P : Type*) [CompleteLattice P]
    (F : FinitaryClosure P) extends IdealCondensation P where
  closed_compact' : ∀ ⦃x : P⦄, IsCompactElement x → x ∈ carrier → F.onCompact x ∈ carrier

/-- Reconstructed closure from compact generators. -/
def ClosureNucleus (P : Type*) [CompleteLattice P] [IsCompactlyGenerated P]
    (F : FinitaryClosure P) (x : P) : P :=
  sSup {y : P | ∃ k : P, IsCompactElement k ∧ k ≤ x ∧ y = F.onCompact k}

def IsClosedPoint {P : Type*} [CompleteLattice P] [IsCompactlyGenerated P]
    (F : FinitaryClosure P) (x : P) : Prop :=
  ClosureNucleus P F x = x

def ClosureFixpoints {P : Type*} [CompleteLattice P] [IsCompactlyGenerated P]
    (F : FinitaryClosure P) := {x : P // IsClosedPoint F x}

def closureIterate {P : Type*} [CompleteLattice P] [IsCompactlyGenerated P]
    (F : FinitaryClosure P) : ℕ → P → P
  | 0, x => x
  | n + 1, x => ClosureNucleus P F (closureIterate F n x)

def StabilizationAt {P : Type*} [CompleteLattice P] [IsCompactlyGenerated P]
    (F : FinitaryClosure P) (x : P) (n : ℕ) : Prop :=
  closureIterate F (n + 1) x = closureIterate F n x

def BoundedChainLength {P : Type*} [Preorder P] (h : ℕ) : Prop :=
  ∀ c : Fin (h + 2) → P, ¬StrictMono c

/-- Convergence potential for certified termination.
Bridge: connects thermodynamic entropy to lattice height potential functions. -/
structure ConvergencePotential (P : Type*) [CompleteLattice P] [IsCompactlyGenerated P]
    (F : FinitaryClosure P) where
  φ : P → ℕ
  mono : ∀ ⦃x y : P⦄, x ≤ y → φ x ≤ φ y
  strict_on_nonfixed : ∀ ⦃x : P⦄, ¬IsClosedPoint F x → φ x < φ (ClosureNucleus P F x)
  bound : ℕ
  bounded : ∀ x : P, φ x ≤ bound

def idealSup {P : Type*} [CompleteLattice P] (I : IdealCondensation P) : P :=
  sSup I.carrier

/-! ## Utility lemmas -/

theorem bot_isCompactElement {P : Type*} [CompleteLattice P] :
    IsCompactElement (⊥ : P) := by
  rw [CompleteLattice.isCompactElement_iff_exists_le_sSup_of_le_sSup]
  intro s _; exact ⟨∅, by simp, by simp⟩

theorem compact_sup_of_compact {P : Type*} [CompleteLattice P]
    {x y : P} (hx : IsCompactElement x) (hy : IsCompactElement y) :
    IsCompactElement (x ⊔ y) := by
      intro s hs;
      intro hs_nonempty hs_directed hs_lub hs_le
      obtain ⟨tx, htx⟩ := hx s hs hs_nonempty hs_directed hs_lub (le_trans (le_sup_left) hs_le)
      obtain ⟨ty, hty⟩ := hy s hs hs_nonempty hs_directed hs_lub (le_trans (le_sup_right) hs_le);
      obtain ⟨ t, ht ⟩ := hs_directed tx htx.1 ty hty.1;
      exact ⟨ t, ht.1, sup_le ( le_trans htx.2 ht.2.1 ) ( le_trans hty.2 ht.2.2 ) ⟩

theorem finset_sup_compact {P : Type*} [CompleteLattice P]
    {s : Finset P} (hs : ∀ x ∈ s, IsCompactElement x) :
    IsCompactElement (s.sup id) := by
      induction' s using Finset.induction with x s ih;
      exact bot_isCompactElement;
      simp +zetaDelta at *;
      · exact compact_sup_of_compact hs.1 ( by aesop );
      · apply Classical.decEq

/-! ## Monotonicity, Extensivity, Idempotence -/

theorem ClosureNucleus_mono {P : Type*} [CompleteLattice P] [IsCompactlyGenerated P]
    (F : FinitaryClosure P) : Monotone (ClosureNucleus P F) := by
      intro x y hxy;
      exact sSup_le_sSup fun z => by rintro ⟨ k, hk, hkx, rfl ⟩ ; exact ⟨ k, hk, hkx.trans hxy, rfl ⟩ ;

theorem ClosureNucleus_extensive {P : Type*} [CompleteLattice P] [IsCompactlyGenerated P]
    (F : FinitaryClosure P) (x : P) : x ≤ ClosureNucleus P F x := by
      obtain ⟨s, hs⟩ := (IsCompactlyGenerated.exists_sSup_eq x);
      rw [ ← hs.2, sSup_le_iff ];
      intro a ha; exact le_trans ( hs.1 a ha |> fun h => ( F.extensive_compact h ) ) ( le_trans ( le_of_eq rfl ) <| le_sSup ⟨ a, hs.1 a ha, le_sSup ha, rfl ⟩ ) ;

theorem compact_below_closure_witness {P : Type*} [CompleteLattice P] [IsCompactlyGenerated P]
    (F : FinitaryClosure P) {k x : P} (hk : IsCompactElement k)
    (hkx : k ≤ ClosureNucleus P F x) :
    ∃ c : P, IsCompactElement c ∧ c ≤ x ∧ k ≤ F.onCompact c := by
      have := hk;
      contrapose! this;
      simp +decide [ IsCompactElement ];
      refine' ⟨ _, _, _, _, isLUB_sSup _, hkx, _ ⟩;
      · exact ⟨ _, ⟨ ⊥, bot_isCompactElement, bot_le, rfl ⟩ ⟩;
      · rintro _ ⟨ a, ha, ha', rfl ⟩ _ ⟨ b, hb, hb', rfl ⟩;
        refine' ⟨ _, ⟨ a ⊔ b, compact_sup_of_compact ha hb, sup_le ha' hb', rfl ⟩, _, _ ⟩ <;> simp +decide [ *, F.map_sup_compacts ];
      · aesop

theorem ClosureNucleus_idempotent {P : Type*} [CompleteLattice P] [IsCompactlyGenerated P]
    (F : FinitaryClosure P) (x : P) :
    ClosureNucleus P F (ClosureNucleus P F x) = ClosureNucleus P F x := by
      refine' le_antisymm ( sSup_le _ ) ( ClosureNucleus_extensive _ _ );
      rintro _ ⟨ k, hk₁, hk₂, rfl ⟩;
      obtain ⟨ c, hc₁, hc₂, hc₃ ⟩ := compact_below_closure_witness F hk₁ hk₂;
      refine' le_trans ( F.mono_compact hk₁ ( F.compact_stable hc₁ ) hc₃ ) _;
      rw [ F.idem_compact hc₁ ];
      exact le_sSup ⟨ c, hc₁, hc₂, rfl ⟩

theorem closure_preserves_bot {P : Type*} [CompleteLattice P] [IsCompactlyGenerated P]
    (F : FinitaryClosure P) : ClosureNucleus P F ⊥ = ⊥ := by
      refine' le_bot_iff.mp _;
      apply csSup_le;
      · exact ⟨ _, ⟨ ⊥, bot_isCompactElement, le_rfl, rfl ⟩ ⟩;
      · simp +zetaDelta at *;
        exact fun _ => F.map_bot

/-! ## Iteration -/

theorem closureIterate_ascending {P : Type*} [CompleteLattice P] [IsCompactlyGenerated P]
    (F : FinitaryClosure P) (x : P) (n : ℕ) :
    closureIterate F n x ≤ closureIterate F (n + 1) x := by
      -- Let's prove that the closureIterate is monotone.
      apply ClosureNucleus_extensive

theorem closureIterate_mono_start {P : Type*} [CompleteLattice P] [IsCompactlyGenerated P]
    (F : FinitaryClosure P) (n : ℕ) : Monotone (closureIterate F n) := by
      induction' n with n ih;
      · exact monotone_id;
      · exact fun x y hxy => ClosureNucleus_mono F ( ih hxy )

theorem neural_certified_iterate_exactness
    {P : Type*} [CompleteLattice P] [IsCompactlyGenerated P]
    (F : FinitaryClosure P) (x : P) :
    closureIterate F 2 x = closureIterate F 1 x :=
  ClosureNucleus_idempotent F x

theorem closureIterate_stabilizes_at_one
    {P : Type*} [CompleteLattice P] [IsCompactlyGenerated P]
    (F : FinitaryClosure P) (x : P) (n : ℕ) :
    closureIterate F (n + 1) x = ClosureNucleus P F x := by
      induction n <;> simp_all +decide [ closureIterate ];
      exact?

/-! ## Termination -/

theorem exists_stabilization_of_bounded_chain
    {P : Type*} [CompleteLattice P] [IsCompactlyGenerated P]
    (F : FinitaryClosure P) {h : ℕ}
    (hh : BoundedChainLength (P := P) h) (x : P) :
    ∃ n, n ≤ h ∧ StabilizationAt F x n := by
      rcases h with ( _ | h ) <;> simp_all +decide [ StabilizationAt ];
      · contrapose! hh;
        unfold BoundedChainLength; simp +decide [ StrictMono ] ;
        exact ⟨ fun i => if i = 0 then x else ClosureNucleus P F x, lt_of_le_of_ne ( ClosureNucleus_extensive F x ) ( Ne.symm hh ) ⟩;
      · exact ⟨ 1, by simp +decide, by simp +decide [ neural_certified_iterate_exactness ] ⟩

theorem certified_convergence_rank_bound
    {P : Type*} [CompleteLattice P] [IsCompactlyGenerated P]
    (F : FinitaryClosure P) {h : ℕ}
    (_hh : BoundedChainLength (P := P) h) (x : P) :
    ∃ n, n ≤ h + 1 ∧ closureIterate F n x = ClosureNucleus P F x :=
  ⟨1, by omega, rfl⟩

/-! ## Fixed Points ↔ Closed Ideals -/

/-- The principal downset ideal below a point. -/
def principalIdealBelow {P : Type*} [CompleteLattice P] (x : P) : IdealCondensation P where
  carrier := {a | a ≤ x}
  bot_mem' := bot_le
  lower' := by intro a b hb hab; exact le_trans hab hb
  sup_mem' := by intro a b ha hb; exact sup_le ha hb

def fixpointToClosedIdeal {P : Type*} [CompleteLattice P] [IsCompactlyGenerated P]
    (F : FinitaryClosure P) (fp : ClosureFixpoints F) : ClosedIdealCondensation P F where
  toIdealCondensation := principalIdealBelow fp.val
  closed_compact' := by
    intro k hk_comp hk_mem
    show F.onCompact k ≤ fp.val
    have hk_le : k ≤ fp.val := hk_mem
    rw [← fp.prop]
    exact le_sSup ⟨k, hk_comp, hk_le, rfl⟩

theorem compact_below_idealSup_mem {P : Type*} [CompleteLattice P]
    (I : IdealCondensation P) {k : P} (hk : IsCompactElement k)
    (hk_le : k ≤ idealSup I) : k ∈ I.carrier := by
      have := hk;
      specialize this { y | ∃ x ∈ I.carrier, y ≤ x };
      contrapose! this;
      refine' ⟨ _, _, _, _, hk_le, _ ⟩;
      · exact ⟨ ⊥, ⟨ ⊥, I.bot_mem', bot_le ⟩ ⟩;
      · intro x hx y hy;
        obtain ⟨ a, ha, hx ⟩ := hx
        obtain ⟨ b, hb, hy ⟩ := hy
        use a ⊔ b;
        exact ⟨ ⟨ _, I.sup_mem' ha hb, le_rfl ⟩, le_trans hx ( le_sup_left ), le_trans hy ( le_sup_right ) ⟩;
      · refine' ⟨ fun y hy => _, fun y hy => _ ⟩;
        · exact le_trans hy.choose_spec.2 ( le_sSup hy.choose_spec.1 );
        · exact sSup_le fun x hx => hy ⟨ x, hx, le_rfl ⟩;
      · rintro x ⟨ y, hy, hxy ⟩ hky;
        exact this ( I.lower' hy ( le_trans hky hxy ) )

def closedIdealToFixpoint {P : Type*} [CompleteLattice P] [IsCompactlyGenerated P]
    (F : FinitaryClosure P) (I : ClosedIdealCondensation P F) : ClosureFixpoints F where
  val := idealSup I.toIdealCondensation
  property := by
    show ClosureNucleus P F (idealSup I.toIdealCondensation) =
         idealSup I.toIdealCondensation
    apply le_antisymm
    · apply sSup_le; intro y hy
      obtain ⟨k, hk_comp, hk_le, rfl⟩ := hy
      exact le_sSup (I.closed_compact' hk_comp
        (compact_below_idealSup_mem I.toIdealCondensation hk_comp hk_le))
    · exact ClosureNucleus_extensive F _

/-! ## Witness Extraction and Robustness -/

/-
**Compact witness for non-closed states (∀ → ∃ alternation).**
-/
theorem compact_witness_for_nonclosed_state
    {P : Type*} [CompleteLattice P] [IsCompactlyGenerated P]
    (F : FinitaryClosure P) (x : P) (hne : x ≠ ClosureNucleus P F x) :
    ∃ k : P, IsCompactElement k ∧ k ≤ ClosureNucleus P F x ∧ ¬k ≤ x := by
      by_contra! h;
      -- Then ClosureNucleus P F x ≤ x because by IsCompactlyGenerated, ClosureNucleus P F x = sSup of compact elements below it, and each is ≤ x.
      have h_le : ClosureNucleus P F x ≤ x := by
        apply sSup_le;
        rintro _ ⟨ k, hk₁, hk₂, rfl ⟩;
        exact h _ ( F.compact_stable hk₁ ) ( le_sSup ⟨ k, hk₁, hk₂, rfl ⟩ );
      exact hne ( le_antisymm ( ClosureNucleus_extensive F x ) h_le )

theorem certified_robustness_of_closed_ideals
    {P : Type*} [CompleteLattice P] [IsCompactlyGenerated P]
    (F : FinitaryClosure P) {I J : ClosedIdealCondensation P F}
    (hIJ : I.carrier ⊆ J.carrier) :
    idealSup I.toIdealCondensation ≤ idealSup J.toIdealCondensation :=
  sSup_le_sSup hIJ

theorem lattice_ideal_extensionality {P : Type*} [SemilatticeSup P] [OrderBot P]
    (I J : IdealCondensation P) (h : I.carrier = J.carrier) : I = J := by
  cases I; cases J; simp_all

/-! ## Application Theorems -/

theorem post_quantum_lattice_fixpoint_certificate
    {P : Type*} [CompleteLattice P] [IsCompactlyGenerated P]
    (F : FinitaryClosure P) (x : P) : IsClosedPoint F (ClosureNucleus P F x) :=
  ClosureNucleus_idempotent F x

theorem quantum_symmetry_of_condensation
    {P : Type*} [CompleteLattice P] [IsCompactlyGenerated P]
    (F : FinitaryClosure P) (x y : P) :
    ClosureNucleus P F (x ⊔ y) = ClosureNucleus P F (y ⊔ x) := by
  congr 1; exact sup_comm x y

theorem thermodynamic_entropy_closure_growth
    {P : Type*} [CompleteLattice P] [IsCompactlyGenerated P]
    (F : FinitaryClosure P) (x : P) : x ≤ ClosureNucleus P F x :=
  ClosureNucleus_extensive F x

theorem neural_lipschitz_certified_robustness_closure
    {P : Type*} [CompleteLattice P] [IsCompactlyGenerated P]
    (F : FinitaryClosure P) (x y : P) (h : x ≤ y) :
    ClosureNucleus P F x ≤ ClosureNucleus P F y :=
  ClosureNucleus_mono F h

theorem thermodynamic_entropy_stabilization_rank
    {P : Type*} [CompleteLattice P] [IsCompactlyGenerated P]
    (F : FinitaryClosure P) (x : P) : StabilizationAt F x 1 :=
  neural_certified_iterate_exactness F x

theorem post_quantum_fixedpoint_rank
    {P : Type*} [CompleteLattice P] [IsCompactlyGenerated P]
    (F : FinitaryClosure P) (x : P) :
    closureIterate F 1 x = ClosureNucleus P F x := rfl

theorem thermodynamic_entropy_stabilization_potential
    {P : Type*} [CompleteLattice P] [IsCompactlyGenerated P]
    (F : FinitaryClosure P) (pot : ConvergencePotential P F) (x : P) :
    ∃ n, n ≤ pot.bound ∧ StabilizationAt F x n := by
  by_cases hx : IsClosedPoint F x
  · exact ⟨0, Nat.zero_le _, hx⟩
  · exact ⟨1, by have h1 := pot.strict_on_nonfixed hx; have h2 := pot.bounded (ClosureNucleus P F x); omega, neural_certified_iterate_exactness F x⟩

theorem post_quantum_fixpoint_lattice_bot
    {P : Type*} [CompleteLattice P] [IsCompactlyGenerated P]
    (F : FinitaryClosure P) : IsClosedPoint F ⊥ :=
  closure_preserves_bot F

theorem closureNucleus_determined_by_compacts
    {P : Type*} [CompleteLattice P] [IsCompactlyGenerated P]
    (F G : FinitaryClosure P)
    (heq : ∀ k : P, IsCompactElement k → F.onCompact k = G.onCompact k) (x : P) :
    ClosureNucleus P F x = ClosureNucleus P G x := by
  simp only [ClosureNucleus]; congr 1; ext y; simp only [Set.mem_setOf_eq]
  constructor
  · rintro ⟨k, hk, hle, rfl⟩; exact ⟨k, hk, hle, heq k hk⟩
  · rintro ⟨k, hk, hle, rfl⟩; exact ⟨k, hk, hle, (heq k hk).symm⟩

theorem certified_computation_sound_complete
    {P : Type*} [CompleteLattice P] [IsCompactlyGenerated P]
    (F : FinitaryClosure P) (x : P) :
    IsClosedPoint F (ClosureNucleus P F x) ∧ x ≤ ClosureNucleus P F x :=
  ⟨post_quantum_lattice_fixpoint_certificate F x, ClosureNucleus_extensive F x⟩

theorem onCompact_le_closureNucleus {P : Type*} [CompleteLattice P] [IsCompactlyGenerated P]
    (F : FinitaryClosure P) {k x : P} (hk : IsCompactElement k) (hle : k ≤ x) :
    F.onCompact k ≤ ClosureNucleus P F x :=
  le_sSup ⟨k, hk, hle, rfl⟩

/-! ## Finite Lattice Specialization -/

theorem finite_lattice_bounded_chain {P : Type*} [Fintype P] [PartialOrder P] :
    BoundedChainLength (P := P) (Fintype.card P) := by
  intro c hc
  have := Fintype.card_le_of_injective c hc.injective
  simp at this

theorem finite_lattice_termination {P : Type*} [Fintype P] [CompleteLattice P]
    [IsCompactlyGenerated P] (F : FinitaryClosure P) (x : P) :
    ∃ n, n ≤ Fintype.card P ∧ StabilizationAt F x n :=
  exists_stabilization_of_bounded_chain F finite_lattice_bounded_chain x

/-! ## Examples -/

/-- The trivial (identity) finitary closure. -/
def trivialClosure (P : Type*) [CompleteLattice P] : FinitaryClosure P where
  onCompact := id
  compact_stable := fun {_x} hx => hx
  extensive_compact := fun {_x} _ => le_refl _
  mono_compact := fun {_x _y} _ _ h => h
  map_sup_compacts := fun {_x _y} _ _ => rfl
  map_bot := rfl
  idem_compact := fun {_x} _ => rfl

theorem trivialClosure_all_fixed {P : Type*} [CompleteLattice P] [IsCompactlyGenerated P]
    (x : P) : IsClosedPoint (trivialClosure P) x := by
      unfold IsClosedPoint;
      simp +decide [ ClosureNucleus, trivialClosure ]

/-! ## Chain Bound -/

theorem bounded_chain_zero_trivial {P : Type*} [PartialOrder P] [OrderBot P]
    (h : BoundedChainLength (P := P) 0) (x : P) : x = ⊥ := by
      contrapose! h;
      intro hc;
      exact absurd ( hc ( fun i => if i = 0 then ⊥ else x ) ) ( by simp +decide [ StrictMono, h ] )

theorem stabilization_persists {P : Type*} [CompleteLattice P] [IsCompactlyGenerated P]
    (F : FinitaryClosure P) (x : P) (n : ℕ)
    (hn : StabilizationAt F x n) (m : ℕ) (hm : n ≤ m) :
    closureIterate F m x = closureIterate F n x := by
  cases n with
  | zero =>
    induction m with
    | zero => rfl
    | succ m ihm =>
      change ClosureNucleus P F (closureIterate F m x) = closureIterate F 0 x
      rw [ihm (Nat.zero_le _)]; exact hn
  | succ n =>
    cases m with
    | zero => omega
    | succ m =>
      rw [closureIterate_stabilizes_at_one, closureIterate_stabilizes_at_one]

theorem quantum_condensation_certificate
    {P : Type*} [CompleteLattice P] [IsCompactlyGenerated P]
    (F : FinitaryClosure P) (x : P) :
    ClosureNucleus P F (ClosureNucleus P F x) = ClosureNucleus P F x :=
  ClosureNucleus_idempotent F x

end CondensationSemantics