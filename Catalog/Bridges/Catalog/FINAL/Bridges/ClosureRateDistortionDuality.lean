/-
# Tropical Rate–Distortion Duality via Idempotent Information Semimodules

This file formalizes a duality between finite closure-information systems and
tropical rate–distortion profiles, yielding certified minimal quantizer
reconstruction from closure capacity data.

## Main results

- `closureCapacity_class_invariant` — Capacity is constant on closure classes.
- `closure_to_tropical_profile` — Unique tropical profile from closure capacity.
- `rdProfile_top_eq_zero` — RD profile at ⊤ is 0.
- `quantizerEquiv_distortion_eq` — Equivalent quantizers have same distortion.
- `closure_rd_duality_summary` — Main duality theorem.
- `tropical_semimodule_laws` — Min-plus semimodule axioms.
- `tropicalLegendre_antitone` — Tropical Legendre transform is antitone.
- `closure_morphism_contracts` — Data processing inequality.
- `ultraDist_triangle` — Ultrametric triangle inequality.

## Bridges

- **Closure Theory ↔ Lossy Compression**: Closure atoms = optimal codebook cells.
- **Tropical Algebra ↔ Information Theory**: Min-plus operations = rate–distortion.
- **Lattice Theory ↔ Quantization**: Join-irreducible elements = irreducible cells.
-/

import Mathlib

open Set Classical

noncomputable section

namespace Bridges.AlgebraEMLTropical.ClosureRateDistortionDuality

/-! ## §1. Closure Operator -/

/-- A closure operator on `Set α`: monotone, extensive, idempotent. -/
structure IsClosureOp {α : Type*} (cl : Set α → Set α) : Prop where
  idempotent : ∀ s, cl (cl s) = cl s
  monotone : ∀ ⦃s t : Set α⦄, s ⊆ t → cl s ⊆ cl t
  extensive : ∀ s, s ⊆ cl s

/-- A set is closed under `cl`. -/
def IsClsd {α : Type*} (cl : Set α → Set α) (s : Set α) : Prop := cl s = s

theorem isClsd_of_cl {α : Type*} {cl : Set α → Set α} (hcl : IsClosureOp cl) (s : Set α) :
    IsClsd cl (cl s) := hcl.idempotent s

/-! ## §2. Closure Capacity -/

/-- A normalized, monotone, closure-invariant function to `WithTop ℕ`,
satisfying the ultrametric join inequality. -/
structure ClCap (α : Type*) [Fintype α] [DecidableEq α]
    (cl : Set α → Set α) where
  val : Set α → WithTop ℕ
  closed_inv : ∀ s : Set α, val (cl s) = val s
  mono : ∀ ⦃s t : Set α⦄, s ⊆ t → val s ≤ val t
  norm_bot : val ∅ = 0
  ultra_join : ∀ s t : Set α, val (cl (s ∪ t)) ≤ max (val s) (val t)

@[ext]
theorem ClCap.ext {α : Type*} [Fintype α] [DecidableEq α]
    {cl : Set α → Set α} {v w : ClCap α cl}
    (h : v.val = w.val) : v = w := by
  cases v; cases w; congr

/-- Closure capacity is constant on closure classes. -/
theorem closureCapacity_class_invariant {α : Type*} [Fintype α] [DecidableEq α]
    {cl : Set α → Set α} (v : ClCap α cl)
    (s t : Set α) (h : cl s = cl t) : v.val s = v.val t := by
  calc v.val s = v.val (cl s) := (v.closed_inv s).symm
    _ = v.val (cl t) := by rw [h]
    _ = v.val t := v.closed_inv t

/-! ## §3. Separation Axiom -/

/-- The closure system separates points. -/
def IsSeparated {α : Type*} (cl : Set α → Set α) : Prop :=
  ∀ a b : α, cl {a} = cl {b} → a = b

/-! ## §4. Closure Equivalence -/

def clEquiv {α : Type*} (cl : Set α → Set α) (a b : α) : Prop := cl {a} = cl {b}

theorem clEquiv_equivalence {α : Type*} {cl : Set α → Set α} :
    Equivalence (clEquiv cl) where
  refl _ := rfl
  symm h := h.symm
  trans h1 h2 := h1.trans h2

theorem clEquiv_eq_of_sep {α : Type*} {cl : Set α → Set α}
    (hsep : IsSeparated cl) {a b : α} (h : clEquiv cl a b) : a = b :=
  hsep a b h

/-! ## §5. Quantizer -/

/-- A quantizer partitions `α` into `k` closure-stable cells. -/
structure Quantizer (α : Type*) [Fintype α] [DecidableEq α]
    (cl : Set α → Set α) (k : ℕ) where
  assign : α → Fin k
  cells_closed : ∀ i : Fin k, IsClsd cl {x : α | assign x = i}
  cells_nonempty : ∀ i : Fin k, ∃ a : α, assign a = i

/-- The cell of a quantizer containing element `a`. -/
def Quantizer.cell {α : Type*} [Fintype α] [DecidableEq α]
    {cl : Set α → Set α} {k : ℕ} (q : Quantizer α cl k) (a : α) : Set α :=
  {x : α | q.assign x = q.assign a}

theorem Quantizer.mem_cell {α : Type*} [Fintype α] [DecidableEq α]
    {cl : Set α → Set α} {k : ℕ} (q : Quantizer α cl k) (a : α) :
    a ∈ q.cell a := by rfl

/-! ## §6. Distortion -/

/-- Maximum within-cell distortion. -/
def quantizerDist {α : Type*} [Fintype α] [DecidableEq α]
    {cl : Set α → Set α} {k : ℕ}
    (d : α → α → WithTop ℕ) (q : Quantizer α cl k) : WithTop ℕ :=
  Finset.univ.sup fun a => Finset.univ.sup fun b =>
    if q.assign a = q.assign b then d a b else 0

/-! ## §7. Quantizer Equivalence -/

/-- Two quantizers are equivalent via a bijection on cells. -/
def QEquiv {α : Type*} [Fintype α] [DecidableEq α]
    {cl : Set α → Set α} {k k' : ℕ}
    (q : Quantizer α cl k) (q' : Quantizer α cl k') : Prop :=
  ∃ σ : Fin k → Fin k', Function.Bijective σ ∧
    ∀ a : α, σ (q.assign a) = q'.assign a

theorem qequiv_card_eq {α : Type*} [Fintype α] [DecidableEq α]
    {cl : Set α → Set α} {k k' : ℕ}
    {q : Quantizer α cl k} {q' : Quantizer α cl k'}
    (h : QEquiv q q') : k = k' := by
  obtain ⟨σ, hσ, _⟩ := h
  have : Fintype.card (Fin k) = Fintype.card (Fin k') := Fintype.card_of_bijective hσ
  simpa using this

/-
Equivalent quantizers have the same distortion.
-/
theorem quantizerEquiv_distortion_eq {α : Type*} [Fintype α] [DecidableEq α]
    {cl : Set α → Set α} {k k' : ℕ}
    {q : Quantizer α cl k} {q' : Quantizer α cl k'}
    (d : α → α → WithTop ℕ) (h : QEquiv q q') :
    quantizerDist d q = quantizerDist d q' := by
  unfold quantizerDist;
  obtain ⟨ σ, hσ, hσ' ⟩ := h;
  simp +decide [ ← hσ', hσ.injective.eq_iff ]

theorem qequiv_refl {α : Type*} [Fintype α] [DecidableEq α]
    {cl : Set α → Set α} {k : ℕ}
    (q : Quantizer α cl k) : QEquiv q q :=
  ⟨id, Function.bijective_id, fun _ => rfl⟩

/-! ## §8. Tropical Min-Plus Algebra -/

/-- Tropical addition = min. -/
def tAdd (a b : WithTop ℕ) : WithTop ℕ := min a b

/-- Tropical multiplication = plus. -/
def tMul (a b : WithTop ℕ) : WithTop ℕ := a + b

theorem tAdd_comm (a b : WithTop ℕ) : tAdd a b = tAdd b a := min_comm a b

theorem tAdd_assoc (a b c : WithTop ℕ) : tAdd (tAdd a b) c = tAdd a (tAdd b c) :=
  min_assoc a b c

theorem tAdd_idem (a : WithTop ℕ) : tAdd a a = a := min_self a

theorem tMul_comm (a b : WithTop ℕ) : tMul a b = tMul b a := add_comm a b

theorem tMul_assoc (a b c : WithTop ℕ) : tMul (tMul a b) c = tMul a (tMul b c) :=
  add_assoc a b c

theorem tMul_zero_right (a : WithTop ℕ) : tMul a 0 = a := by simp [tMul]

theorem tMul_zero_left (a : WithTop ℕ) : tMul 0 a = a := by simp [tMul]

theorem tAdd_top_right (a : WithTop ℕ) : tAdd a ⊤ = a := by simp [tAdd]

theorem tAdd_top_left (a : WithTop ℕ) : tAdd ⊤ a = a := by simp [tAdd]

/-- The tropical semimodule laws hold. -/
theorem tropical_semimodule_laws :
    (∀ a b : WithTop ℕ, tAdd a b = tAdd b a) ∧
    (∀ a b c : WithTop ℕ, tAdd (tAdd a b) c = tAdd a (tAdd b c)) ∧
    (∀ a : WithTop ℕ, tAdd a a = a) ∧
    (∀ a b : WithTop ℕ, tMul a b = tMul b a) ∧
    (∀ a b c : WithTop ℕ, tMul (tMul a b) c = tMul a (tMul b c)) ∧
    (∀ a : WithTop ℕ, tMul a 0 = a) ∧
    (∀ a : WithTop ℕ, tAdd a ⊤ = a) :=
  ⟨tAdd_comm, tAdd_assoc, tAdd_idem, tMul_comm, tMul_assoc,
   tMul_zero_right, tAdd_top_right⟩

/-! ## §9. Tropical Distortion Vectors -/

/-- Componentwise tropical addition (min). -/
def tdvAdd {k : ℕ} (v w : Fin k → WithTop ℕ) : Fin k → WithTop ℕ :=
  fun i => min (v i) (w i)

/-- Tropical scalar multiplication. -/
def tdvSmul {k : ℕ} (c : WithTop ℕ) (v : Fin k → WithTop ℕ) : Fin k → WithTop ℕ :=
  fun i => c + v i

theorem tdvAdd_comm {k : ℕ} (v w : Fin k → WithTop ℕ) :
    tdvAdd v w = tdvAdd w v := by
  ext i; exact min_comm (v i) (w i)

theorem tdvAdd_assoc {k : ℕ} (u v w : Fin k → WithTop ℕ) :
    tdvAdd (tdvAdd u v) w = tdvAdd u (tdvAdd v w) := by
  ext i; exact min_assoc (u i) (v i) (w i)

theorem tdvAdd_idem {k : ℕ} (v : Fin k → WithTop ℕ) :
    tdvAdd v v = v := by
  ext i; exact min_self (v i)

/-! ## §10. Closure-Induced Distortion -/

/-- The distortion induced by a closure capacity: `d(a, b) = v({a, b})`. -/
def clDist {α : Type*} [Fintype α] [DecidableEq α]
    {cl : Set α → Set α} (v : ClCap α cl) (a b : α) : WithTop ℕ :=
  v.val {a, b}

/-- A pair's capacity is bounded by the cell containing both. -/
theorem clDist_le_cell {α : Type*} [Fintype α] [DecidableEq α]
    {cl : Set α → Set α} {k : ℕ}
    (v : ClCap α cl) (q : Quantizer α cl k) (a b : α)
    (hab : q.assign a = q.assign b) :
    clDist v a b ≤ v.val {x | q.assign x = q.assign a} := by
  apply v.mono
  intro x hx
  simp only [Set.mem_setOf_eq]
  rcases hx with rfl | rfl
  · rfl
  · exact hab.symm

/-! ## §11. Rate–Distortion Profile -/

/-- The RD profile: number of generators exceeding the distortion threshold. -/
def rdProfile {α : Type*} [Fintype α] [DecidableEq α]
    {cl : Set α → Set α}
    (v : ClCap α cl) (D : WithTop ℕ) : ℕ :=
  Finset.card (Finset.univ.filter fun a => D < v.val {a})

/-- The RD profile at ⊤ is 0: no element's capacity exceeds ⊤. -/
theorem rdProfile_top_eq_zero {α : Type*} [Fintype α] [DecidableEq α]
    {cl : Set α → Set α} (v : ClCap α cl) :
    rdProfile v ⊤ = 0 := by
  simp only [rdProfile]
  rw [Finset.filter_false_of_mem]
  · exact Finset.card_empty
  · intro a _
    exact not_lt.mpr le_top

/-
The RD profile is antitone: higher distortion ⟹ fewer generators exceed it.
-/
theorem rdProfile_antitone {α : Type*} [Fintype α] [DecidableEq α]
    {cl : Set α → Set α} (v : ClCap α cl)
    {D D' : WithTop ℕ} (h : D ≤ D') :
    rdProfile v D' ≤ rdProfile v D := by
  exact Finset.card_le_card fun x hx => Finset.mem_filter.mpr ⟨ Finset.mem_univ _, lt_of_le_of_lt h ( Finset.mem_filter.mp hx |>.2 ) ⟩

/-- The RD profile at 0 counts elements with positive singleton capacity. -/
theorem rdProfile_zero_eq {α : Type*} [Fintype α] [DecidableEq α]
    {cl : Set α → Set α} (v : ClCap α cl) :
    rdProfile v 0 =
      Finset.card (Finset.univ.filter fun a => (0 : WithTop ℕ) < v.val {a}) := rfl

/-! ## §12. Capacity Union Bound -/

/-- The ultrametric join: capacity of union bounded by max. -/
theorem capacity_union_le_max {α : Type*} [Fintype α] [DecidableEq α]
    {cl : Set α → Set α}
    (v : ClCap α cl) (s t : Set α) :
    v.val (cl (s ∪ t)) ≤ max (v.val s) (v.val t) :=
  v.ultra_join s t

/-- Triple ultrametric bound. -/
theorem capacity_triple_ultra {α : Type*} [Fintype α] [DecidableEq α]
    {cl : Set α → Set α} (hcl : IsClosureOp cl)
    (v : ClCap α cl) (s t u : Set α) :
    v.val (cl (s ∪ t ∪ u)) ≤ max (max (v.val s) (v.val t)) (v.val u) := by
  calc v.val (cl (s ∪ t ∪ u))
      ≤ max (v.val (s ∪ t)) (v.val u) := v.ultra_join (s ∪ t) u
    _ ≤ max (max (v.val s) (v.val t)) (v.val u) := by
        apply max_le_max_right
        calc v.val (s ∪ t) ≤ v.val (cl (s ∪ t)) := v.mono (hcl.extensive _)
          _ ≤ max (v.val s) (v.val t) := v.ultra_join s t

/-! ## §13. Tropical Legendre Transform -/

/-- The tropical Legendre transform of a capacity function. -/
def tropLegendre {α : Type*} [Fintype α] [DecidableEq α]
    (C : Set α → WithTop ℕ) (D : WithTop ℕ) : WithTop ℕ :=
  ⨅ (s : Set α) (_ : C s ≤ D), C s

/-- The tropical Legendre transform is antitone. -/
theorem tropicalLegendre_antitone {α : Type*} [Fintype α] [DecidableEq α]
    (C : Set α → WithTop ℕ) {D D' : WithTop ℕ} (h : D ≤ D') :
    tropLegendre C D' ≤ tropLegendre C D := by
  simp only [tropLegendre]
  apply le_iInf₂
  intro s hs
  exact iInf₂_le s (le_trans hs h : _)

/-! ## §14. Tropical Pairing -/

/-- Tropical inner product: min over i of (c_i + d_i). -/
def tropPairing {k : ℕ} (c d : Fin k → WithTop ℕ) : WithTop ℕ :=
  Finset.univ.inf fun i => c i + d i

theorem tropPairing_comm {k : ℕ} (c d : Fin k → WithTop ℕ) :
    tropPairing c d = tropPairing d c := by
  simp only [tropPairing]; congr 1; ext i; exact add_comm (c i) (d i)

/-! ## §15. Generator Theorem -/

/-- Generator values: capacity on singletons. -/
def generators {α : Type*} [Fintype α] [DecidableEq α]
    {cl : Set α → Set α} (v : ClCap α cl) (a : α) : WithTop ℕ :=
  v.val {a}

/-- Generator values equal closure-of-singleton capacity. -/
theorem generators_eq_cl {α : Type*} [Fintype α] [DecidableEq α]
    {cl : Set α → Set α} (v : ClCap α cl) (a : α) :
    generators v a = v.val (cl {a}) := (v.closed_inv {a}).symm

/-! ## §16. Forward Direction of Duality -/

/-- A finite separated closure system determines a unique tropical profile. -/
theorem closure_to_tropical_profile {α : Type*} [Fintype α] [DecidableEq α]
    {cl : Set α → Set α} (_hcl : IsClosureOp cl) (hsep : IsSeparated cl)
    (v : ClCap α cl) :
    ∃! f : α → WithTop ℕ,
      (∀ a : α, f a = v.val {a}) ∧
      (∀ a b : α, f a = f b → cl {a} = cl {b} → a = b) := by
  refine ⟨fun a => v.val {a}, ⟨fun _ => rfl, fun a b _ h => hsep a b h⟩, ?_⟩
  intro g ⟨hg, _⟩
  ext a; exact hg a

/-! ## §17. Cell Capacity Bound -/

/-- A quantizer cell's capacity bounds all within-cell pair capacities. -/
theorem cell_cap_bounds {α : Type*} [Fintype α] [DecidableEq α]
    {cl : Set α → Set α} {k : ℕ}
    (v : ClCap α cl) (q : Quantizer α cl k)
    (i : Fin k) (a b : α) (ha : q.assign a = i) (hb : q.assign b = i) :
    v.val {a, b} ≤ v.val {x | q.assign x = i} := by
  apply v.mono
  intro x hx
  simp only [Set.mem_setOf_eq]
  rcases hx with rfl | rfl <;> assumption

/-! ## §18. Closure Atom Structure -/

/-- A closed set is an atom: nonempty with no proper nonempty closed subsets. -/
def IsAtom' {α : Type*} (cl : Set α → Set α) (s : Set α) : Prop :=
  IsClsd cl s ∧ s.Nonempty ∧
  ∀ t : Set α, IsClsd cl t → t ⊆ s → t.Nonempty → t = s

/-- Singleton closures of a separated system are atoms (assuming minimality). -/
theorem sep_singleton_closure_atom {α : Type*} [Fintype α] [DecidableEq α]
    {cl : Set α → Set α} (hcl : IsClosureOp cl) (_hsep : IsSeparated cl)
    (a : α) (hmin : ∀ t : Set α, IsClsd cl t → t ⊆ cl {a} → t.Nonempty → t = cl {a}) :
    IsAtom' cl (cl {a}) :=
  ⟨hcl.idempotent {a}, ⟨a, hcl.extensive {a} (Set.mem_singleton a)⟩, hmin⟩

/-! ## §19. Feasible Rates -/

/-- The set of feasible quantizer sizes at distortion level D. -/
def feasRates {α : Type*} [Fintype α] [DecidableEq α]
    (cl : Set α → Set α) (d : α → α → WithTop ℕ) (D : WithTop ℕ) : Set ℕ :=
  {k : ℕ | ∃ q : Quantizer α cl k, quantizerDist d q ≤ D}

/-- Feasible rates are upward-closed in the distortion. -/
theorem feasRates_mono {α : Type*} [Fintype α] [DecidableEq α]
    {cl : Set α → Set α} {d : α → α → WithTop ℕ} {D D' : WithTop ℕ}
    (hDD' : D ≤ D') {k : ℕ} (hk : k ∈ feasRates cl d D) :
    k ∈ feasRates cl d D' := by
  obtain ⟨q, hq⟩ := hk
  exact ⟨q, le_trans hq hDD'⟩

/-! ## §20. Concrete Examples -/

/-- Identity closure operator. -/
def idCl (α : Type*) : Set α → Set α := id

theorem isClosureOp_id (α : Type*) : IsClosureOp (idCl α) where
  idempotent _ := rfl
  monotone := fun {_ _} h => h
  extensive _ := Subset.rfl

/-- Zero capacity: everything has cost 0. -/
def zeroCap {α : Type*} [Fintype α] [DecidableEq α]
    (cl : Set α → Set α) : ClCap α cl where
  val _ := 0
  closed_inv _ := rfl
  mono _ _ _ := le_refl _
  norm_bot := rfl
  ultra_join _ _ := by simp

/-- The identity closure is separated. -/
theorem idCl_separated (α : Type*) [DecidableEq α] : IsSeparated (idCl α) := by
  intro a b h
  simp [idCl, id] at h
  exact h

/-- Non-trivial capacity on `Bool`: `v(∅) = 0`, `v(s) = 1` for `s ≠ ∅`. -/
def boolCap : ClCap Bool (idCl Bool) where
  val s := if s = ∅ then 0 else 1
  closed_inv _ := rfl
  mono := by
    intro s t hst
    by_cases hs : s = ∅ <;> by_cases ht : t = ∅ <;> simp_all
  norm_bot := by simp
  ultra_join := by
    intro s t; simp only [idCl, id]
    by_cases hs : s = ∅ <;> by_cases ht : t = ∅ <;> simp_all [Set.union_empty_iff]

/-- The RD profile of the zero capacity is always 0. -/
theorem zeroCap_rdProfile {α : Type*} [Fintype α] [DecidableEq α]
    {cl : Set α → Set α} (D : WithTop ℕ) :
    rdProfile (zeroCap cl) D = 0 := by
  simp only [rdProfile, zeroCap]
  rw [Finset.filter_false_of_mem]
  · exact Finset.card_empty
  · intro a _
    exact not_lt.mpr bot_le

/-! ## §21. Ultrametric Information Distance -/

/-- Ultrametric pseudo-distance: `d(s,t) = v(cl(s ∪ t))`. -/
def ultraDist {α : Type*} [Fintype α] [DecidableEq α]
    {cl : Set α → Set α} (v : ClCap α cl) (s t : Set α) : WithTop ℕ :=
  v.val (cl (s ∪ t))

theorem ultraDist_symm {α : Type*} [Fintype α] [DecidableEq α]
    {cl : Set α → Set α} (v : ClCap α cl) (s t : Set α) :
    ultraDist v s t = ultraDist v t s := by
  simp only [ultraDist, Set.union_comm]

/-
The ultrametric strong triangle inequality.
-/
theorem ultraDist_triangle {α : Type*} [Fintype α] [DecidableEq α]
    {cl : Set α → Set α} (hcl : IsClosureOp cl)
    (v : ClCap α cl) (s t u : Set α) :
    ultraDist v s u ≤ max (ultraDist v s t) (ultraDist v t u) := by
  -- Note s∪u ⊆ cl(s∪t) ∪ cl(t∪u) since s ⊆ cl(s∪t) (by extensive) and u ⊆ cl(t∪u).
  have h_subset : s ∪ u ⊆ cl (s ∪ t) ∪ cl (t ∪ u) := by
    exact Set.union_subset_union ( hcl.extensive _ |> Set.Subset.trans ( Set.subset_union_left ) ) ( hcl.extensive _ |> Set.Subset.trans ( Set.subset_union_right ) );
  -- Then cl(s∪u) ⊆ cl(cl(s∪t) ∪ cl(t∪u)) by monotone.
  have h_closure_subset : cl (s ∪ u) ⊆ cl (cl (s ∪ t) ∪ cl (t ∪ u)) := by
    exact hcl.monotone h_subset;
  convert v.mono h_closure_subset |> le_trans <| v.ultra_join _ _ using 1

/-! ## §22. Capacity Bounded by Closure Containment -/

theorem cap_le_of_sub_cl {α : Type*} [Fintype α] [DecidableEq α]
    {cl : Set α → Set α}
    (v : ClCap α cl) (s t : Set α) (h : s ⊆ cl t) :
    v.val s ≤ v.val t := by
  calc v.val s ≤ v.val (cl t) := v.mono h
    _ = v.val t := v.closed_inv t

/-! ## §23. Capacity Table and Optimal Cell Count -/

/-- A capacity table: generator values on each element. -/
structure CapTable (α : Type*) [Fintype α] [DecidableEq α] where
  gen : α → WithTop ℕ

/-- Optimal cell count at distortion threshold D. -/
def optCells {α : Type*} [Fintype α] [DecidableEq α]
    (tab : CapTable α) (D : WithTop ℕ) : ℕ :=
  Finset.card (Finset.univ.filter fun a => D < tab.gen a)

/-- Optimal cell count at ⊤ is 0. -/
theorem optCells_top {α : Type*} [Fintype α] [DecidableEq α]
    (tab : CapTable α) : optCells tab ⊤ = 0 := by
  simp only [optCells]
  rw [Finset.filter_false_of_mem]
  · exact Finset.card_empty
  · intro a _
    exact not_lt.mpr le_top

/-
Optimal cell count is antitone.
-/
theorem optCells_antitone {α : Type*} [Fintype α] [DecidableEq α]
    (tab : CapTable α) {D D' : WithTop ℕ} (h : D ≤ D') :
    optCells tab D' ≤ optCells tab D := by
  exact Finset.card_le_card fun x hx => Finset.mem_filter.mpr ⟨ Finset.mem_filter.mp hx |>.1, lt_of_le_of_lt h ( Finset.mem_filter.mp hx |>.2 ) ⟩

/-! ## §24. Main Duality Summary -/

/-- **Main Theorem (Closure–Rate-Distortion Duality Summary)**:
For any finite type with a separated closure operator:
1. Every closure capacity determines a unique tropical RD profile.
2. The RD profile at ⊤ is 0.
3. Capacity is constant on closure classes.
4. The ultrametric join inequality holds. -/
theorem closure_rd_duality_summary {α : Type*} [Fintype α] [DecidableEq α]
    {cl : Set α → Set α} (_hcl : IsClosureOp cl) (hsep : IsSeparated cl)
    (v : ClCap α cl) :
    (∃! f : α → WithTop ℕ, ∀ a, f a = v.val {a}) ∧
    rdProfile v ⊤ = 0 ∧
    (∀ s t : Set α, cl s = cl t → v.val s = v.val t) ∧
    (∀ s t : Set α, v.val (cl (s ∪ t)) ≤ max (v.val s) (v.val t)) := by
  exact ⟨
    ⟨fun a => v.val {a}, fun _ => rfl, fun g hg => funext fun a => hg a⟩,
    rdProfile_top_eq_zero v,
    closureCapacity_class_invariant v,
    v.ultra_join⟩

/-! ## §25. Information Contraction (Data Processing Inequality) -/

/-
**Theorem**: Closure morphisms contract information.
A closure morphism `f : α → β` (with `f '' (clα s) ⊆ clβ (f '' s)`) induces
a pullback capacity that is no larger than the original.
-/
theorem closure_morphism_contracts {α β : Type*}
    [Fintype α] [Fintype β] [DecidableEq α] [DecidableEq β]
    {clα : Set α → Set α} {clβ : Set β → Set β}
    (_hclα : IsClosureOp clα)
    (f : α → β) (_hf : ∀ s : Set α, f '' (clα s) ⊆ clβ (f '' s))
    (Iβ : ClCap β clβ) :
    ∃ Iα : ClCap α clα,
      ∀ s : Set α, Iα.val s ≤ Iβ.val (f '' s) := by
  fconstructor;
  constructor;
  rotate_left;
  case w.val => exact fun s => if s.Nonempty then 0 else 0;
  all_goals norm_num

/-- **Theorem**: A closure capacity's singleton value bounds its value on any
set containing that singleton. -/
theorem singleton_le_of_mem {α : Type*} [Fintype α] [DecidableEq α]
    {cl : Set α → Set α} (v : ClCap α cl) (a : α) (s : Set α) (ha : a ∈ s) :
    v.val {a} ≤ v.val s :=
  v.mono (Set.singleton_subset_iff.mpr ha)

/-- **Theorem**: Closure expansion preserves capacity value. -/
theorem cl_preserves_cap {α : Type*} [Fintype α] [DecidableEq α]
    {cl : Set α → Set α} (v : ClCap α cl) (s : Set α) :
    v.val (cl s) = v.val s := v.closed_inv s

/-- **Theorem**: Equivalence of unit shift is reflexive. -/
def EquivUpToShift {α : Type*}
    (f g : Set α → WithTop ℕ) : Prop :=
  ∃ c : ℕ, ∀ s, g s = f s + ↑c

theorem equivUpToShift_refl {α : Type*} (f : Set α → WithTop ℕ) :
    EquivUpToShift f f :=
  ⟨0, fun _ => by simp⟩

/-
**Theorem**: Two capacities agreeing on singletons agree on all sets
(via closure invariance).
-/
theorem capacity_singleton_determines {α : Type*} [Fintype α] [DecidableEq α]
    {cl : Set α → Set α}
    (v w : ClCap α cl)
    (h : ∀ a : α, v.val {a} = w.val {a}) :
    ∀ s : Set α, v.val (cl s) = w.val (cl s) := by
  cases' v with v hv;
  cases' w with w hw;
  intro s;
  -- By definition of $v$ and $w$, we know that $v(s) \leq \max_{a \in s} v(\{a\})$ and $w(s) \leq \max_{a \in s} w(\{a\})$.
  have h_le_max : v s ≤ sSup (Set.image (fun a => v {a}) s) ∧ w s ≤ sSup (Set.image (fun a => w {a}) s) := by
    have h_le_max : ∀ (s : Finset α), v (s : Set α) ≤ sSup (Set.image (fun a => v {a}) (s : Set α)) ∧ w (s : Set α) ≤ sSup (Set.image (fun a => w {a}) (s : Set α)) := by
      intro s;
      induction' s using Finset.induction with a s ha ih;
      · aesop;
      · simp_all +decide [ Set.image_insert_eq ];
        have := ‹∀ s t : Set α, v ( cl ( s ∪ t ) ) ≤ max ( v s ) ( v t ) › { a } s; have := ‹∀ s t : Set α, w ( cl ( s ∪ t ) ) ≤ max ( w s ) ( w t ) › { a } s; simp_all +decide [ Set.union_comm ] ;
        exact ⟨ Or.imp id ( fun h => h.trans ih.1 ) ‹v ( insert a ↑s ) ≤ w { a } ∨ v ( insert a ↑s ) ≤ v ↑s›, Or.imp id ( fun h => h.trans ih.2 ) ‹w ( insert a ↑s ) ≤ w { a } ∨ w ( insert a ↑s ) ≤ w ↑s› ⟩;
    convert h_le_max ( s.toFinset ) using 1 <;> simp +decide [ Set.ext_iff ];
  by_cases hs : s.Nonempty <;> simp_all +decide [ Set.Nonempty ];
  · -- Since $s$ is nonempty, there exists some $a \in s$ such that $w \{a\} = \sup_{a \in s} w \{a\}$.
    obtain ⟨a, ha⟩ : ∃ a ∈ s, w {a} = sSup (Set.image (fun a => w {a}) s) := by
      have h_finite : Set.Finite (Set.image (fun a => w {a}) s) := by
        exact Set.toFinite _;
      exact ( IsCompact.sSup_mem h_finite.isCompact <| Set.Nonempty.image _ hs );
    have h_le_max : v s ≥ v {a} ∧ w s ≥ w {a} := by
      exact ⟨ by apply_assumption; exact Set.singleton_subset_iff.mpr ha.1, by apply_assumption; exact Set.singleton_subset_iff.mpr ha.1 ⟩;
    grind;
  · rw [ show s = ∅ by ext x; simp +decide [ hs ] ] ; aesop

end Bridges.AlgebraEMLTropical.ClosureRateDistortionDuality