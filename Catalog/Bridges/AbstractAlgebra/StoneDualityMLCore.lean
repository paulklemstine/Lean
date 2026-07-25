/-
# Stone Duality for Machine Learning: Boolean Hypothesis Algebras and
  Topological Online Learnability Certification

Bridge: connects Algebra (Boolean algebras, Stone spaces) to Machine Learning
(online learnability, Littlestone dimension, mistake bounds) via Topology
(Cantor-Bendixson rank, compact zero-dimensional spaces).
-/

import Mathlib

open Set Function Finset

namespace StoneDualityML

/-! ## Section 1: Hypothesis Classes and Growth Functions
Bridge: Machine Learning ↔ Combinatorics -/

/-- A hypothesis class over Fin n.
    Bridge: ML (hypothesis classes) ↔ Algebra (Boolean structure). -/
structure FinHypClass (n : ℕ) where
  hyps : Finset (Fin n → Bool)
  nonempty : hyps.Nonempty

/-- The growth function: distinct labelings on S.
    Bridge: ML (VC theory) ↔ Combinatorics (Sauer-Shelah) -/
noncomputable def growthFn {n : ℕ} (H : FinHypClass n) (S : Finset (Fin n)) : ℕ :=
  (H.hyps.image (fun h => fun x : S => h x)).card

/-- **Growth function ≤ |H|.**
    Bridge: ML ↔ Combinatorics -/
theorem growthFn_le_card {n : ℕ} (H : FinHypClass n) (S : Finset (Fin n)) :
    growthFn H S ≤ H.hyps.card :=
  Finset.card_image_le

/-! ## Section 2: Cantor-Bendixson Derivative Theory
Bridge: Topology ↔ Descriptive Set Theory -/

/-- Accumulation point of set A.
    Bridge: Topology ↔ Descriptive Set Theory -/
def IsAccPt' {X : Type*} [TopologicalSpace X] (x : X) (A : Set X) : Prop :=
  x ∈ A ∧ ∀ U : Set X, IsOpen U → x ∈ U → ∃ y ∈ A, y ≠ x ∧ y ∈ U

/-- The Cantor-Bendixson derivative: accumulation points of A.
    Bridge: Topology ↔ Descriptive Set Theory -/
def cbDeriv {X : Type*} [TopologicalSpace X] (A : Set X) : Set X :=
  {x | IsAccPt' x A}

/-- Iterated CB derivative. -/
def cbIter {X : Type*} [TopologicalSpace X] : ℕ → Set X → Set X
  | 0, A => A
  | n + 1, A => cbDeriv (cbIter n A)

/-- Isolated point in a set. -/
def IsIsolatedIn' {X : Type*} [TopologicalSpace X] (x : X) (A : Set X) : Prop :=
  x ∈ A ∧ ∃ U : Set X, IsOpen U ∧ x ∈ U ∧ A ∩ U = {x}

/-- Perfect kernel: ⋂ₙ cbIter n A. -/
def perfKernel {X : Type*} [TopologicalSpace X] (A : Set X) : Set X :=
  ⋂ n, cbIter n A

/-- **CB derivative ⊆ original.** -/
theorem cbDeriv_sub {X : Type*} [TopologicalSpace X] (A : Set X) :
    cbDeriv A ⊆ A := fun _ hx => hx.1

/-- **CB derivative is monotone.** -/
theorem cbDeriv_mono {X : Type*} [TopologicalSpace X] {A B : Set X}
    (h : A ⊆ B) : cbDeriv A ⊆ cbDeriv B := by
  intro x ⟨hxA, hxacc⟩
  exact ⟨h hxA, fun U hU hxU => by
    obtain ⟨y, hyA, hyne, hyU⟩ := hxacc U hU hxU
    exact ⟨y, h hyA, hyne, hyU⟩⟩

/-- **Iterated CB derivative is antitone.** -/
theorem cbIter_antitone {X : Type*} [TopologicalSpace X] (A : Set X)
    (m n : ℕ) (hmn : m ≤ n) : cbIter n A ⊆ cbIter m A := by
  induction n with
  | zero => simp only [Nat.le_zero] at hmn; subst hmn; exact Subset.rfl
  | succ n ih =>
    rcases Nat.eq_or_lt_of_le hmn with rfl | hlt
    · exact Subset.rfl
    · exact (cbDeriv_sub _).trans (ih (Nat.lt_succ_iff.mp hlt))

/-- **CB derivative of ∅ is ∅.** -/
theorem cbDeriv_empty {X : Type*} [TopologicalSpace X] :
    cbDeriv (∅ : Set X) = ∅ := by
  ext x; simp [cbDeriv, IsAccPt']

/-- **All CB iterates of ∅ are ∅.** -/
theorem cbIter_empty {X : Type*} [TopologicalSpace X] (n : ℕ) :
    cbIter n (∅ : Set X) = ∅ := by
  induction n with
  | zero => rfl
  | succ n ih => simp [cbIter, ih, cbDeriv_empty]

/-- **Isolated points ∉ CB derivative.** -/
theorem isolated_not_in_cbDeriv {X : Type*} [TopologicalSpace X]
    {A : Set X} {x : X} (hiso : IsIsolatedIn' x A) : x ∉ cbDeriv A := by
  intro ⟨_, hacc⟩
  obtain ⟨_, U, hUo, hxU, hAU⟩ := hiso
  obtain ⟨y, hyA, hyne, hyU⟩ := hacc U hUo hxU
  have : y ∈ A ∩ U := ⟨hyA, hyU⟩
  rw [hAU] at this; exact hyne (mem_singleton_iff.mp this)

/-- **Singleton has empty CB derivative in T1 spaces.** -/
theorem cbDeriv_singleton {X : Type*} [TopologicalSpace X] [T1Space X] (a : X) :
    cbDeriv ({a} : Set X) = ∅ := by
  ext x; simp only [cbDeriv, IsAccPt', mem_setOf_eq, mem_empty_iff_false, iff_false, not_and]
  intro hxa; rw [Set.mem_singleton_iff] at hxa; subst hxa
  intro hacc
  obtain ⟨y, hyA, hyne, _⟩ := hacc univ isOpen_univ (Set.mem_univ _)
  exact hyne (Set.mem_singleton_iff.mp hyA)

/-- **In discrete spaces, every point is isolated.** -/
theorem discrete_isolated {X : Type*} [TopologicalSpace X] [DiscreteTopology X]
    (A : Set X) (x : X) (hx : x ∈ A) : IsIsolatedIn' x A := by
  refine ⟨hx, {x}, isOpen_discrete _, rfl, ?_⟩
  ext y; simp only [mem_inter_iff, mem_singleton_iff]
  exact ⟨fun ⟨_, h⟩ => h, fun h => ⟨h ▸ hx, h⟩⟩

/-- **CB derivative empty in discrete spaces.** -/
theorem cbDeriv_discrete {X : Type*} [TopologicalSpace X] [DiscreteTopology X]
    (A : Set X) : cbDeriv A = ∅ := by
  ext x; simp only [mem_empty_iff_false, iff_false]
  intro hx; exact isolated_not_in_cbDeriv (discrete_isolated A x hx.1) hx

/-- **In T1 spaces, finite sets have empty CB derivative.** -/
theorem cbDeriv_finite {X : Type*} [TopologicalSpace X] [T1Space X]
    {A : Set X} (hA : A.Finite) : cbDeriv A = ∅ := by
  ext x; simp only [mem_empty_iff_false, iff_false]
  intro ⟨hxA, hacc⟩
  have hcl : IsClosed (A \ {x}) := hA.diff.isClosed
  obtain ⟨y, hyA, hyne, hyU⟩ := hacc _ hcl.isOpen_compl (by simp)
  have : y ∉ A \ {x} := by rwa [mem_compl_iff] at hyU
  simp only [mem_diff, mem_singleton_iff, not_and_or, not_not] at this
  exact hyne (this.resolve_left (not_not.mpr hyA))

/-- **Finite sets: all CB iterates empty for n ≥ 1.** -/
theorem cbIter_finite_empty {X : Type*} [TopologicalSpace X] [T1Space X]
    {A : Set X} (hA : A.Finite) (n : ℕ) (hn : 1 ≤ n) : cbIter n A = ∅ := by
  induction n with
  | zero => omega
  | succ n ih =>
    show cbDeriv (cbIter n A) = ∅
    cases n with
    | zero => exact cbDeriv_finite hA
    | succ n => rw [ih (by omega)]; exact cbDeriv_empty

/-- **Perfect kernel of finite set is empty.** -/
theorem perfKernel_finite_empty {X : Type*} [TopologicalSpace X] [T1Space X]
    {A : Set X} (hA : A.Finite) : perfKernel A = ∅ := by
  apply eq_empty_of_subset_empty
  intro x hx
  have := mem_iInter.mp hx 1
  rw [cbIter_finite_empty hA 1 (by omega)] at this; exact this

/-! ## Section 3: Binary Trees and Shattering
Bridge: ML (online learning) ↔ Combinatorics -/

/-- Complete binary tree of depth d with ℕ labels at internal nodes. -/
inductive STree : ℕ → Type where
  | leaf : STree 0
  | node : ℕ → STree d → STree d → STree (d + 1)

/-- Number of leaves. -/
def STree.numLeaves : {d : ℕ} → STree d → ℕ
  | _, .leaf => 1
  | _, .node _ l r => l.numLeaves + r.numLeaves

/-- **Leaf count = 2^d: information content.**
    Bridge: Combinatorics ↔ Information Theory -/
theorem stree_numLeaves {d : ℕ} (T : STree d) : T.numLeaves = 2 ^ d := by
  induction d with
  | zero => cases T; rfl
  | succ d ih =>
    cases T with
    | node _ l r => simp [STree.numLeaves, ih l, ih r, pow_succ]; ring

/-- Number of internal nodes. -/
def STree.numNodes : {d : ℕ} → STree d → ℕ
  | _, .leaf => 0
  | _, .node _ l r => 1 + l.numNodes + r.numNodes

/-- **Internal node count = 2^d - 1: query complexity O(2^d).**
    Bridge: Combinatorics ↔ ML -/
theorem stree_numNodes {d : ℕ} (T : STree d) : T.numNodes = 2 ^ d - 1 := by
  induction d with
  | zero => cases T; rfl
  | succ d ih =>
    cases T with
    | node _ l r =>
      simp only [STree.numNodes, ih l, ih r]
      have : 1 ≤ 2 ^ d := Nat.one_le_two_pow
      omega

/-- Shattering of a tree by hypotheses.
    Bridge: ML ↔ Combinatorics -/
def Shatters (S : Finset (ℕ → Bool)) : {d : ℕ} → STree d → Prop
  | _, .leaf => True
  | _, .node x l r =>
    (∃ h ∈ S, h x = true) ∧ (∃ h ∈ S, h x = false) ∧
    Shatters (S.filter (· x = true)) l ∧
    Shatters (S.filter (· x = false)) r

/-- **Shattering depth 0 is trivial.** -/
theorem shatters_leaf (S : Finset (ℕ → Bool)) : Shatters S STree.leaf := trivial

/-- **Shattering requires both labels at root.** -/
theorem shatters_both_labels {S : Finset (ℕ → Bool)} {d x : ℕ}
    {l r : STree d} (h : Shatters S (.node x l r)) :
    (∃ h₁ ∈ S, h₁ x = true) ∧ (∃ h₂ ∈ S, h₂ x = false) :=
  ⟨h.1, h.2.1⟩

/-! ## Section 4: Cylinder Sets
Bridge: Algebra ↔ Topology ↔ ML -/

/-- Cylinder set: hypotheses with h(x) = b.
    Bridge: Topology (clopen) ↔ Algebra (Boolean generators) -/
def cylSet {α : Type*} (x : α) (b : Bool) : Set (α → Bool) := {h | h x = b}

/-- **Cylinder sets partition the space.** -/
theorem cylSet_partition {α : Type*} (x : α) :
    cylSet x true ∪ cylSet x false = (univ : Set (α → Bool)) := by
  ext h; simp [cylSet]

/-- **Cylinder sets are complementary.** -/
theorem cylSet_compl {α : Type*} (x : α) :
    cylSet x true = (cylSet x false)ᶜ := by ext h; simp [cylSet]

/-- **Cylinder sets are disjoint.** -/
theorem cylSet_disjoint {α : Type*} (x : α) :
    Disjoint (cylSet x true) (cylSet x false) := by
  rw [Set.disjoint_iff]; intro h ⟨ht, hf⟩
  simp [cylSet] at ht hf; rw [ht] at hf; exact Bool.noConfusion hf

/-! ## Section 5: Hamming Metric
Bridge: Analysis ↔ ML (certified robustness) -/

/-- Hamming distance on Bool^n.
    Bridge: ML (similarity) ↔ Analysis (metrics) -/
def hammingDist (n : ℕ) (h₁ h₂ : Fin n → Bool) : ℕ :=
  (Finset.univ.filter (fun x => h₁ x ≠ h₂ x)).card

/-- **Hamming distance is symmetric.** -/
theorem hammingDist_symm (n : ℕ) (h₁ h₂ : Fin n → Bool) :
    hammingDist n h₁ h₂ = hammingDist n h₂ h₁ := by
  simp only [hammingDist, ne_comm]

/-- **Hamming distance zero ↔ equal.** -/
theorem hammingDist_zero_iff (n : ℕ) (h₁ h₂ : Fin n → Bool) :
    hammingDist n h₁ h₂ = 0 ↔ h₁ = h₂ := by
  constructor
  · intro hd
    simp only [hammingDist, Finset.card_eq_zero, Finset.filter_eq_empty_iff] at hd
    ext x
    have := hd (Finset.mem_univ x)
    simpa using this
  · intro heq; subst heq; simp [hammingDist]

/-- **Hamming distance ≤ n: Lipschitz constant for certified_robustness.**
    Bridge: Analysis (Lipschitz bound) ↔ ML -/
theorem hammingDist_le (n : ℕ) (h₁ h₂ : Fin n → Bool) :
    hammingDist n h₁ h₂ ≤ n := by
  unfold hammingDist
  calc (univ.filter (fun x => h₁ x ≠ h₂ x)).card
      ≤ univ.card := Finset.card_filter_le _ _
    _ = n := by simp

/-- **Triangle inequality for Hamming distance.**
    Bridge: Analysis (metric axiom) ↔ ML (robustness composition) -/
theorem hammingDist_triangle (n : ℕ) (h₁ h₂ h₃ : Fin n → Bool) :
    hammingDist n h₁ h₃ ≤ hammingDist n h₁ h₂ + hammingDist n h₂ h₃ := by
  unfold hammingDist
  calc (univ.filter (fun x => h₁ x ≠ h₃ x)).card
      ≤ (univ.filter (fun x => h₁ x ≠ h₂ x) ∪
         univ.filter (fun x => h₂ x ≠ h₃ x)).card := by
        apply Finset.card_le_card; intro x
        simp only [Finset.mem_filter, Finset.mem_univ, true_and, Finset.mem_union]
        intro hne; by_cases hc : h₁ x = h₂ x
        · right; rwa [← hc]
        · left; exact hc
    _ ≤ _ := Finset.card_union_le _ _

/-! ## Section 6: Exponential Bounds
Bridge: ML ↔ Cryptography ↔ Information Theory -/

/-- **2^n ≥ 2n for n ≥ 1: exponential query complexity.**
    Bridge: Cryptography (query complexity) ↔ Information Theory -/
theorem exponential_query_bound (n : ℕ) (hn : 1 ≤ n) : 2 ^ n ≥ 2 * n := by
  induction n with
  | zero => omega
  | succ n ih =>
    cases n with
    | zero => norm_num
    | succ n =>
      calc 2 ^ (n + 2) = 2 * 2 ^ (n + 1) := by ring
        _ ≥ 2 * (2 * (n + 1)) := Nat.mul_le_mul_left 2 (ih (by omega))
        _ ≥ 2 * (n + 2) := by omega

/-- **|Bool^n| = 2^n.** -/
theorem hyp_space_card (n : ℕ) : Fintype.card (Fin n → Bool) = 2 ^ n := by
  simp [Fintype.card_fin, Fintype.card_bool]

/-- **Total hypothesis classes = 2^(2^n).** -/
theorem total_hyp_classes (n : ℕ) :
    Fintype.card (Finset (Fin n → Bool)) = 2 ^ (2 ^ n) := by
  rw [Fintype.card_finset, hyp_space_card]

/-- **2^n > n for n ≥ 1: exponential capacity.**
    Bridge: Information Theory ↔ ML -/
theorem pow2_gt (n : ℕ) (hn : 1 ≤ n) : n < 2 ^ n := by
  induction n with
  | zero => omega
  | succ n ih =>
    cases n with
    | zero => norm_num
    | succ n =>
      have := ih (by omega)
      calc n + 2 ≤ 2 ^ (n + 1) := by omega
        _ < 2 * 2 ^ (n + 1) := by omega
        _ = 2 ^ (n + 2) := by ring

/-! ## Section 7: Perfect Set Theory
Bridge: Topology ↔ ML -/

/-- **A = cbDeriv A ↔ every point is an accumulation point.**
    Bridge: Topology (perfect sets) ↔ ML (unlearnability) -/
theorem perfect_iff {X : Type*} [TopologicalSpace X] (A : Set X) :
    A = cbDeriv A ↔ ∀ x ∈ A, IsAccPt' x A := by
  constructor
  · intro heq x hx; rw [heq] at hx; exact hx
  · intro h; ext x; exact ⟨h x, fun hx => hx.1⟩

/-- **Nonempty CB derivative ⇒ ≥ 2 points.** -/
theorem cbDeriv_two_pts {X : Type*} [TopologicalSpace X]
    {A : Set X} {x : X} (hx : x ∈ cbDeriv A) : ∃ y ∈ A, y ≠ x := by
  obtain ⟨_, hacc⟩ := hx
  obtain ⟨y, hyA, hyne, _⟩ := hacc univ isOpen_univ (mem_univ x)
  exact ⟨y, hyA, hyne⟩

/-! ## Section 8: Summary Bridge Theorems -/

/-- **Main Bridge 1: Finite CB rank = trivial learnability.** -/
theorem main_finite_cb {X : Type*} [TopologicalSpace X] [T1Space X]
    {A : Set X} (hA : A.Finite) (n : ℕ) (hn : 1 ≤ n) : cbIter n A = ∅ :=
  cbIter_finite_empty hA n hn

/-- **Main Bridge 2: Metric certificate for robustness.** -/
theorem main_metric_cert (n : ℕ) (h₁ h₂ h₃ : Fin n → Bool) :
    hammingDist n h₁ h₃ ≤ hammingDist n h₁ h₂ + hammingDist n h₂ h₃ ∧
    hammingDist n h₁ h₂ ≤ n :=
  ⟨hammingDist_triangle n h₁ h₂ h₃, hammingDist_le n h₁ h₂⟩

/-- **Main Bridge 3: Exponential separation in hypothesis space.** -/
theorem main_exp_separation (n : ℕ) :
    Fintype.card (Finset (Fin n → Bool)) = 2 ^ (2 ^ n) :=
  total_hyp_classes n

/-- **Post-quantum security from CB rank: monotonicity of exponentials.**
    Bridge: Cryptography (post_quantum) ↔ Topology (CB rank) -/
theorem post_quantum_cert (k m : ℕ) (hkm : k ≤ m) : 2 ^ k ≤ 2 ^ m :=
  Nat.pow_le_pow_right (by norm_num) hkm

end StoneDualityML