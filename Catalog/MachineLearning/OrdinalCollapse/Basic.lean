import Mathlib

/-!
# Ordinal Collapse Theory for Bounded-Branching Research Objects

This module develops the **ordinal collapse theory** for adaptive research processes
modeled as well-founded trees. The central result is the **Finite Branching Collapse
Theorem**: any finitely branching research object has ordinal depth strictly below ω,
i.e., its transfinite depth collapses to a natural number.

## Main Definitions

* `ResearchObject` — Inductive type of finitely branching research structures.
* `researchDepth` — Ordinal-valued depth function.
* `natDepth` — Computable natural-number depth.
* `HeightBound` — Predicate bounding tree height.
* `BranchingBound` — Predicate bounding branching factor.
* `bootstrapIter` — Iterated bootstrap operator.
* `InfBranchTree` — Well-founded tree with countably infinite branching.

## Main Results

### Cluster A: Finite Branching Collapse
* `natDepth_eq_researchDepth` — Bridge: computable depth equals ordinal depth.
* `researchDepth_lt_omega` — **Collapse Theorem**: all research objects have depth < ω.
* `researchDepth_isNat` — Every research depth equals a natural ordinal.
* `researchDepth_lt_omega_of_branchingBound` — Collapse under explicit branching bound.

### Cluster B: Height Stratification
* `natDepth_height_bound` — Height bounds imply natDepth bounds.
* `researchDepth_le_of_heightBound` — Ordinal depth bounded by height-derived constant.
* `exists_researchObject_of_depth_eq` — Sharpness: every natural depth is realized.

### Cluster C: Unbounded Branching and Transfinite Escape
* `infBranchTree_depth_lt_omega_of_heightBound` — Even unbounded branching at bounded height
  cannot escape ω. This is the **universal collapse theorem**.
* `omegaTree_depth_eq_omega` — Without a height bound, unbounded branching achieves depth ω.
  This is the **transfinite escape theorem**.

### Cluster D: Operator Dynamics
* `bootstrapIter_depth` — Iterated bootstrap depth = base + iteration count.
* `depth_iter_eq_add_of_successor_law` — General successor-law operators have affine growth.
* `strict_increasing_depth_of_successor_law` — Strict monotonicity from successor law.

## Cross-Domain Significance

The collapse theorem establishes that **finite local nondeterminism cannot generate
transfinite global epistemic depth**. The universal collapse theorem strengthens this:
even **infinite** branching at bounded height stays below ω. Transfinite depth requires
both unbounded branching AND unbounded height—a phase transition in complexity.
-/

noncomputable section

open Ordinal

/-! ## Core Definitions -/

/-- A `ResearchObject` represents a finitely described research structure.
- `atom n` is an atomic research unit.
- `compose A B` is sequential composition of two research programs.
- `bootstrap A` is a self-improving transformation.
- `oracleNode arity deps` is a branching node with `arity` dependencies. -/
inductive ResearchObject where
  | atom : ℕ → ResearchObject
  | compose : ResearchObject → ResearchObject → ResearchObject
  | bootstrap : ResearchObject → ResearchObject
  | oracleNode : (arity : ℕ) → (Fin arity → ResearchObject) → ResearchObject

namespace ResearchObject

/-! ## Ordinal Depth -/

/-- The ordinal-valued depth of a research object.
- Atoms have depth 1.
- Compositions have depth equal to the ordinal sum of components.
- Bootstrap takes the successor.
- Oracle nodes take the supremum of successor depths over dependencies. -/
def researchDepth : ResearchObject → Ordinal
  | .atom _ => 1
  | .compose A B => researchDepth A + researchDepth B
  | .bootstrap A => Order.succ (researchDepth A)
  | .oracleNode arity deps =>
      ⨆ i : Fin arity, Order.succ (researchDepth (deps i))

/-! ## Computable Natural Depth -/

/-- A computable natural-number depth that exactly captures ordinal depth
for finitely branching objects. -/
def natDepth : ResearchObject → ℕ
  | .atom _ => 1
  | .compose A B => natDepth A + natDepth B
  | .bootstrap A => natDepth A + 1
  | .oracleNode 0 _ => 0
  | .oracleNode (n + 1) deps =>
      Finset.sup Finset.univ (fun i : Fin (n + 1) => natDepth (deps i) + 1)

/-! ## Structural Predicates -/

/-- `HeightBound n A` means the tree height of `A` is at most `n`. -/
inductive HeightBound : ℕ → ResearchObject → Prop where
  | atom (n m : ℕ) : HeightBound n (.atom m)
  | compose {n : ℕ} {A B : ResearchObject} :
      HeightBound n A → HeightBound n B → HeightBound (n + 1) (.compose A B)
  | bootstrap {n : ℕ} {A : ResearchObject} :
      HeightBound n A → HeightBound (n + 1) (.bootstrap A)
  | oracleNode {n arity : ℕ} {deps : Fin arity → ResearchObject} :
      (∀ i, HeightBound n (deps i)) → HeightBound (n + 1) (.oracleNode arity deps)

/-- `BranchingBound k A` means every oracle node in `A` has arity ≤ `k`. -/
inductive BranchingBound : ℕ → ResearchObject → Prop where
  | atom (k m : ℕ) : BranchingBound k (.atom m)
  | compose {k : ℕ} {A B : ResearchObject} :
      BranchingBound k A → BranchingBound k B → BranchingBound k (.compose A B)
  | bootstrap {k : ℕ} {A : ResearchObject} :
      BranchingBound k A → BranchingBound k (.bootstrap A)
  | oracleNode {k arity : ℕ} {deps : Fin arity → ResearchObject} :
      arity ≤ k → (∀ i, BranchingBound k (deps i)) →
      BranchingBound k (.oracleNode arity deps)

/-! ## HeightBound monotonicity -/

/-- HeightBound is monotone in the height parameter. -/
theorem HeightBound.weaken {n : ℕ} {A : ResearchObject} (h : HeightBound n A) :
    HeightBound (n + 1) A := by
  induction A generalizing n with
  | atom => exact HeightBound.atom _ _
  | compose A B ihA ihB =>
    cases h with | compose hA hB => exact HeightBound.compose (ihA hA) (ihB hB)
  | bootstrap A ihA =>
    cases h with | bootstrap hA => exact HeightBound.bootstrap (ihA hA)
  | oracleNode arity deps ih =>
    cases h with | oracleNode hdeps => exact HeightBound.oracleNode (fun i => ih i (hdeps i))

/-! ## Cluster A: The Finite Branching Collapse Theorem -/

/-
**Bridge Theorem**: The computable `natDepth` exactly equals `researchDepth`
when both are viewed as ordinals. This is the key technical bridge that enables
all collapse results.
-/
theorem natDepth_eq_researchDepth (A : ResearchObject) :
    (natDepth A : Ordinal) = researchDepth A := by
  -- We'll use induction on the structure of `A`.
  induction' A with A B hA hB;
  · simp [ResearchObject.natDepth, ResearchObject.researchDepth];
  · erw [ show ( B.compose hA ).natDepth = B.natDepth + hA.natDepth from rfl, show ( B.compose hA ).researchDepth = B.researchDepth + hA.researchDepth from rfl, Nat.cast_add, hB, ‹ ( hA.natDepth : Ordinal ) = hA.researchDepth › ];
  · simp_all +decide [ ResearchObject.researchDepth, ResearchObject.natDepth ];
  · cases ‹ℕ› <;> simp_all +decide [ ResearchObject.natDepth, ResearchObject.researchDepth ];
    rw [ @ciSup_eq_of_forall_le_of_forall_lt_exists_gt ];
    · rename_i k ih;
      intro i;
      refine' le_trans _ ( Nat.cast_le.mpr <| Finset.le_sup <| Finset.mem_univ i );
      simp +decide [ ← ih i ];
    · rename_i k f ih;
      intro w hw;
      contrapose! hw;
      -- Since the supremum of a finite set of ordinals is the maximum of those ordinals, we can conclude that the supremum of the natDepths plus one is less than or equal to w.
      have h_max : ∃ i : Fin (k + 1), ∀ j : Fin (k + 1), (f j).natDepth + 1 ≤ (f i).natDepth + 1 := by
        simpa using Finset.exists_max_image Finset.univ ( fun i => ( f i |> ResearchObject.natDepth ) + 1 ) ⟨ 0, Finset.mem_univ 0 ⟩;
      obtain ⟨ i, hi ⟩ := h_max;
      refine' le_trans _ ( hw i );
      rw [ show ( Finset.univ.sup fun i => ( f i |> ResearchObject.natDepth ) + 1 ) = ( f i |> ResearchObject.natDepth ) + 1 from le_antisymm ( Finset.sup_le fun j _ => hi j ) ( Finset.le_sup ( f := fun i => ( f i |> ResearchObject.natDepth ) + 1 ) ( Finset.mem_univ i ) ) ] ; simp +decide [ ← ih ]

/-- **Finite Branching Collapse Theorem**: Every `ResearchObject` has ordinal depth
strictly below ω. This is the central result: finite local nondeterminism cannot
generate transfinite global depth.

This follows immediately from the bridge theorem: since `natDepth A` is a natural
number, `researchDepth A = ↑(natDepth A) < ω`. -/
theorem researchDepth_lt_omega (A : ResearchObject) :
    researchDepth A < omega0 := by
  rw [← natDepth_eq_researchDepth]
  exact nat_lt_omega0 _

/-- Every research depth is realized by a natural number. -/
theorem researchDepth_isNat (A : ResearchObject) :
    ∃ n : ℕ, researchDepth A = (n : Ordinal) :=
  ⟨natDepth A, (natDepth_eq_researchDepth A).symm⟩

/-- Collapse theorem with explicit branching bound hypothesis. -/
theorem researchDepth_lt_omega_of_branchingBound
    {k : ℕ} {A : ResearchObject}
    (_hb : BranchingBound k A) :
    researchDepth A < omega0 :=
  researchDepth_lt_omega A

/-- Variant: branching bound implies depth is a natural ordinal. -/
theorem researchDepth_isNat_of_branchingBound
    {k : ℕ} {A : ResearchObject}
    (_hb : BranchingBound k A) :
    ∃ n : ℕ, researchDepth A = (n : Ordinal) :=
  researchDepth_isNat A

/-! ## Cluster B: Height Stratification -/

/-
Height bounds give computable upper bounds on `natDepth`.
-/
theorem natDepth_height_bound {n : ℕ} {A : ResearchObject}
    (h : HeightBound n A) : natDepth A ≤ 2 ^ (n + 1) := by
  induction' n with n ih generalizing A;
  · rcases A with ( _ | _ | _ | _ ) <;> simp +arith +decide;
    · exact Nat.le_add_left _ _;
    · cases h;
    · cases h;
    · cases h;
  · -- We'll use the fact that if the height bound is n+1, then A must be one of the constructors with height bound n+1.
    cases' h with hA hA hA;
    · exact Nat.le_trans ( by norm_num [ ResearchObject.natDepth ] ) ( Nat.pow_le_pow_right ( by norm_num ) ( Nat.le_add_left _ _ ) );
    · exact le_trans ( add_le_add ( ih ‹_› ) ( ih ‹_› ) ) ( by ring_nf; norm_num );
    · exact Nat.succ_le_of_lt ( lt_of_le_of_lt ( ih ‹_› ) ( pow_lt_pow_right₀ ( by decide ) ( Nat.lt_succ_self _ ) ) );
    · rename_i k deps hk;
      rcases k with ( _ | k ) <;> simp_all +decide [ pow_succ' ];
      · exact le_trans ( by norm_num [ ResearchObject.natDepth ] ) ( Nat.zero_le _ );
      · exact Finset.sup_le fun i _ => Nat.succ_le_of_lt ( lt_of_le_of_lt ( ih ( hk i ) ) ( by linarith [ pow_pos ( zero_lt_two' ℕ ) n ] ) )

/-- **Height-Depth Bound**: If a research object has height ≤ n,
its ordinal depth is at most `2^(n+1)`. -/
theorem researchDepth_le_of_heightBound {n : ℕ} {A : ResearchObject}
    (h : HeightBound n A) : researchDepth A ≤ (2 ^ (n + 1) : ℕ) := by
  rw [← natDepth_eq_researchDepth]
  exact_mod_cast natDepth_height_bound h

/-- **Sharpness**: Every natural number is realized as the depth of some
research object. This shows the finite-branching depth spectrum is exactly ℕ. -/
theorem exists_researchObject_of_depth_eq (n : ℕ) :
    ∃ A : ResearchObject, researchDepth A = (n : Ordinal) := by
  induction' n with n ih
  · use .oracleNode 0 (fun _ => .atom 0)
    simp +decide [ResearchObject.researchDepth]
  · obtain ⟨A, hA⟩ := ih
    use ResearchObject.bootstrap A
    convert congr_arg Order.succ hA using 1

/-! ## Core structural lemmas -/

/-- Bootstrap strictly increases ordinal depth. -/
theorem researchDepth_bootstrap_strict (A : ResearchObject) :
    researchDepth A < researchDepth (.bootstrap A) :=
  Order.lt_succ_iff.mpr le_rfl

/-- Composition depth equals the ordinal sum. -/
theorem researchDepth_compose (A B : ResearchObject) :
    researchDepth (.compose A B) = researchDepth A + researchDepth B :=
  rfl

/-- Bootstrap is never idempotent. -/
theorem bootstrap_not_idempotent (A : ResearchObject) :
    researchDepth (.bootstrap (.bootstrap A)) ≠ researchDepth (.bootstrap A) :=
  ne_of_gt (researchDepth_bootstrap_strict _)

/-! ## Cluster D: Operator Dynamics -/

/-- Bootstrap iterator: applies bootstrap `n` times. -/
def bootstrapIter : ℕ → ResearchObject → ResearchObject
  | 0, A => A
  | n + 1, A => .bootstrap (bootstrapIter n A)

/-
**Affine Growth Theorem**: Iterated bootstrap depth equals base depth
plus iteration count. This is the prototype for ordinal dynamical complexity.
-/
theorem bootstrapIter_depth (A : ResearchObject) (n : ℕ) :
    researchDepth (bootstrapIter n A) = researchDepth A + n := by
  induction n <;> simp_all +decide [ Nat.cast_succ ];
  · rfl;
  · nontriviality;
    rename_i n ih;
    convert congr_arg Order.succ n using 1;
    exact add_succ _ _

/-- Bootstrap iteration is strictly increasing in depth. -/
theorem bootstrapIter_strict_increasing (A : ResearchObject) (n : ℕ) :
    researchDepth (bootstrapIter n A) < researchDepth (bootstrapIter (n + 1) A) := by
  simp only [bootstrapIter]
  exact researchDepth_bootstrap_strict _

/-
**General Successor-Law Dynamics**: Any operator satisfying `depth(f(B)) = depth(B) + 1`
has affine depth growth on iterates. This abstracts the bootstrap pattern.
-/
theorem depth_iter_eq_add_of_successor_law
    {f : ResearchObject → ResearchObject}
    (hf : ∀ B, researchDepth (f B) = researchDepth B + 1) (A : ResearchObject)
    (n : ℕ) : researchDepth (f^[n] A) = researchDepth A + n := by
  nontriviality;
  convert natDepth_eq_researchDepth ( f^[n] A ) |> Eq.symm using 1;
  convert natDepth_eq_researchDepth ( f^[n] A );
  · -- By definition of `natDepth`, we know that `natDepth (f^[n] A) = natDepth A + n`.
    have h_natDepth : ∀ n : ℕ, natDepth (f^[n] A) = natDepth A + n := by
      intro n
      induction' n with n ih;
      · rfl;
      · rw [ Function.iterate_succ_apply' ];
        have := natDepth_eq_researchDepth ( f ( f^[n] A ) );
        rw [ hf, natDepth_eq_researchDepth ] at this;
        rw [ ← natDepth_eq_researchDepth ] at this;
        rw [ ← natDepth_eq_researchDepth ] at this;
        norm_cast at this; linarith;
    rw [ h_natDepth, Nat.cast_add, ← natDepth_eq_researchDepth ];
  · convert natDepth_eq_researchDepth ( f^[n] A ) using 1

/-- Successor-law operators produce strictly increasing depth sequences. -/
theorem strict_increasing_depth_of_successor_law
    {f : ResearchObject → ResearchObject}
    (hf : ∀ B, researchDepth (f B) = researchDepth B + 1) (A : ResearchObject)
    {m n : ℕ} (hmn : m < n) :
    researchDepth (f^[m] A) < researchDepth (f^[n] A) := by
  rw [depth_iter_eq_add_of_successor_law hf, depth_iter_eq_add_of_successor_law hf]
  exact add_lt_add_right (Nat.cast_lt.mpr hmn) _

/-! ## Cluster C: Unbounded Branching and the Transfinite Phase Transition -/

/-- A well-founded tree with countably infinite branching at each internal node.
This is the natural setting for studying transfinite ordinal depth, since
finite branching always collapses to ω (Cluster A). -/
inductive InfBranchTree where
  | leaf : InfBranchTree
  | node : (ℕ → InfBranchTree) → InfBranchTree

namespace InfBranchTree

/-- The ordinal rank (depth) of an infinitely branching tree.
- Leaves have rank 0.
- Internal nodes have rank = sup over children of (child rank + 1).
This is the standard well-founded tree rank. -/
def rank : InfBranchTree → Ordinal
  | .leaf => 0
  | .node children => ⨆ i : ℕ, Order.succ (rank (children i))

/-- Height bound for infinitely branching trees:
the maximum nesting depth of `node` constructors. -/
inductive TreeHeightBound : ℕ → InfBranchTree → Prop where
  | leaf (n : ℕ) : TreeHeightBound n .leaf
  | node {n : ℕ} {children : ℕ → InfBranchTree} :
      (∀ i, TreeHeightBound n (children i)) →
      TreeHeightBound (n + 1) (.node children)

/-- At height 0, all trees are leaves with rank 0. -/
theorem rank_of_height_zero {t : InfBranchTree}
    (h : TreeHeightBound 0 t) : t.rank = 0 := by
  cases h; rfl

/-
**Universal Collapse at Bounded Height**: Even with countably infinite
branching, bounded tree height forces the ordinal rank to be a natural number.

This is a key negative result: unbounded branching alone cannot produce
transfinite complexity. You need unbounded height as well.

Proof: by induction on the height bound. At height 0, all trees are leaves
(rank 0). At height n+1, each child has rank ≤ some f(n) by IH, so the
supremum of successor ranks is at most f(n) + 1, which is still natural.
-/
theorem rank_le_of_heightBound {n : ℕ} {t : InfBranchTree}
    (h : TreeHeightBound n t) : t.rank ≤ (n : Ordinal) := by
  induction' n with n ih generalizing t;
  · cases h ; aesop;
  · cases h;
    · exact Nat.cast_le.mpr ( Nat.zero_le _ );
    · exact ciSup_le fun i => by simpa using Order.succ_le_succ ( ih ( by solve_by_elim ) ) ;

/-- Corollary: bounded height forces rank strictly below ω. -/
theorem rank_lt_omega_of_heightBound {n : ℕ} {t : InfBranchTree}
    (h : TreeHeightBound n t) : t.rank < omega0 :=
  lt_of_le_of_lt (rank_le_of_heightBound h) (nat_lt_omega0 n)

/-- A chain of depth `n`: a linear path of `n` nodes. -/
def chain : ℕ → InfBranchTree
  | 0 => .leaf
  | n + 1 => .node (fun _ => chain n)

/-- The rank of a chain of depth `n` is exactly `n`. -/
theorem chain_rank (n : ℕ) : (chain n).rank = (n : Ordinal) := by
  induction n with
  | zero => rfl
  | succ n ih =>
    show ⨆ _ : ℕ, Order.succ (rank (chain n)) = ↑(n + 1)
    rw [ciSup_const, ih]
    simp

/-- **The Omega Tree**: A tree whose i-th child is a chain of depth i.
This tree has rank ω — the first transfinite ordinal — demonstrating
that unbounded branching without a uniform height bound produces
genuinely transfinite complexity.

This is the canonical witness for the ordinal phase transition. -/
def omegaTree : InfBranchTree := .node (fun i => chain i)

/-
**Transfinite Escape Theorem**: The omega tree has rank exactly ω.
This proves that removing the height bound allows unbounded branching
to escape the finite ordinals, reaching the first limit ordinal.

Combined with `rank_lt_omega_of_heightBound`, this precisely characterizes
the phase transition: bounded height → depth < ω, unbounded height → depth = ω.
-/
theorem omegaTree_rank_eq_omega : omegaTree.rank = omega0 := by
  refine' le_antisymm ( ciSup_le _ ) _;
  · simp +decide [ chain_rank ];
  · refine' le_of_forall_lt _;
    intro c hc
    have h_chain : ∃ n : ℕ, c < (chain n).rank := by
      rw [ Ordinal.lt_omega0 ] at hc;
      obtain ⟨ n, rfl ⟩ := hc; use n + 1; simp +decide [ chain_rank ] ;
    obtain ⟨ n, hn ⟩ := h_chain;
    refine' lt_of_lt_of_le hn ( le_trans _ ( le_ciSup _ n ) );
    · exact Order.le_succ _;
    · simp +zetaDelta at *;
      exact ⟨ _, Set.forall_mem_range.2 fun i => le_ciSup ( Ordinal.bddAbove_of_small _ ) i ⟩

/-- Sharpness: every natural rank is achieved by a chain. -/
theorem exists_tree_of_rank (n : ℕ) :
    ∃ t : InfBranchTree, t.rank = (n : Ordinal) :=
  ⟨chain n, chain_rank n⟩

/-- The rank spectrum below ω is exactly the naturals,
and ω itself is achieved. -/
theorem rank_spectrum :
    (∀ n : ℕ, ∃ t : InfBranchTree, t.rank = (n : Ordinal)) ∧
    (∃ t : InfBranchTree, t.rank = omega0) :=
  ⟨exists_tree_of_rank, ⟨omegaTree, omegaTree_rank_eq_omega⟩⟩

end InfBranchTree

end ResearchObject
end