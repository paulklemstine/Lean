/-
  # Cyclic Chain Counting via Matrix Trace

  The number of cyclic R-chains of length n in a finite directed graph
  equals the trace of the n-th power of its adjacency matrix.

  This is the fundamental bridge between combinatorial dynamics
  (counting periodic orbits / spacetime diagrams) and linear algebra
  (transfer matrices / zeta functions).
-/
import Mathlib
import Speculative.CellularAutomata.Defs

open Matrix Finset BigOperators

/-! ## The adjacency matrix with ℕ entries -/

/-- Adjacency matrix of a decidable relation, with entries in ℕ. -/
noncomputable def relAdjMatrixNat (σ : Type*) [Fintype σ] (R : σ → σ → Prop) [DecidableRel R] :
    Matrix σ σ ℕ :=
  Matrix.of (fun i j => if R i j then 1 else 0)

/-! ## Key identity: (A^n)_{i,j} counts walks of length n from i to j -/

/-- A walk of length n from i to j in a relation R is a sequence
    w : Fin (n+1) → σ with w 0 = i, w n = j, and R (w k) (w (k+1)) for all k < n. -/
def IsWalk {σ : Type*} (R : σ → σ → Prop) {n : ℕ}
    (i j : σ) (w : Fin (n + 1) → σ) : Prop :=
  w 0 = i ∧ w (Fin.last n) = j ∧ ∀ k : Fin n, R (w k.castSucc) (w k.succ)

instance {σ : Type*} [Fintype σ] [DecidableEq σ] (R : σ → σ → Prop) [DecidableRel R]
    {n : ℕ} (i j : σ) (w : Fin (n + 1) → σ) : Decidable (IsWalk R i j w) := by
  unfold IsWalk; exact instDecidableAnd

/-- The number of walks of length n from i to j. -/
noncomputable def walkCount (σ : Type*) [Fintype σ] [DecidableEq σ]
    (R : σ → σ → Prop) [DecidableRel R] (n : ℕ) (i j : σ) : ℕ :=
  Fintype.card { w : Fin (n + 1) → σ // IsWalk R i j w }

/-! ## Main counting theorems -/

/-
**Walk counting theorem**: The (i,j) entry of A^n counts walks of length n
    from i to j, where A is the adjacency matrix.

    This is proved by induction on n:
    - Base case: A^0 = I, and walks of length 0 from i to j exist iff i = j.
    - Inductive step: (A^{n+1})_{i,j} = Σ_k A_{i,k} * (A^n)_{k,j}
      corresponds to extending walks by one step.
-/
theorem adjMatrix_pow_eq_walkCount
    {σ : Type*} [Fintype σ] [DecidableEq σ]
    (R : σ → σ → Prop) [DecidableRel R]
    (n : ℕ) (i j : σ) :
    (relAdjMatrixNat σ R ^ n) i j = walkCount σ R n i j := by
  induction' n with n ih generalizing i j;
  · -- The base case when $n = 0$ follows directly from the definition of the adjacency matrix.
    simp [relAdjMatrixNat, walkCount];
    by_cases hij : i = j <;> simp +decide [ hij, IsWalk ];
    · rw [ Fintype.card_eq_one_iff.mpr ];
      · simp +decide [ hij, Matrix.one_apply ];
      · exact ⟨ ⟨ fun _ => j, rfl ⟩, fun y => Subtype.ext <| funext fun x => by fin_cases x; aesop ⟩;
    · rw [ Fintype.card_eq_zero_iff.mpr ];
      exact ⟨ by rintro ⟨ w, hw₁, hw₂ ⟩ ; exact hij ( hw₁.symm.trans hw₂ ) ⟩;
  · -- By definition of walkCount, we have:
    have h_walkCount_succ : walkCount σ R (n + 1) i j = ∑ k, (if R i k then walkCount σ R n k j else 0) := by
      unfold walkCount;
      simp +decide only [Fintype.card_subtype];
      simp +decide only [card_filter];
      rw [ ← Finset.sum_filter ];
      rw [ ← Finset.sum_filter ];
      rw [ ← Finset.sum_product' ];
      rw [ ← Finset.sum_filter ];
      refine' Finset.sum_bij ( fun x hx => ( x 1, fun k => x ( Fin.succ k ) ) ) _ _ _ _ <;> simp +decide [ IsWalk ];
      · exact fun a ha₁ ha₂ ha₃ => ⟨ by simpa [ ha₁ ] using ha₃ 0, ha₂, fun k => by simpa using ha₃ ( Fin.succ k ) ⟩;
      · intro a₁ ha₁ ha₂ ha₃ a₂ ha₄ ha₅ ha₆ ha₇ ha₈; ext k; induction k using Fin.inductionOn <;> simp_all +decide [ funext_iff ] ;
      · intro a b ha hb hj hb'; use Fin.cons i b; simp +decide [ *, Fin.forall_fin_succ ] ;
    simp +decide [ *, pow_succ', Matrix.mul_apply ];
    exact Finset.sum_congr rfl fun x _ => by unfold relAdjMatrixNat; aesop;

/-
**Trace counts closed walks**: trace(A^n) equals the number of closed walks
    of length n (walks from i to i, summed over all i).
-/
theorem trace_adjMatrix_pow_eq_closedWalkCount
    {σ : Type*} [Fintype σ] [DecidableEq σ]
    (R : σ → σ → Prop) [DecidableRel R]
    (n : ℕ) :
    Matrix.trace (relAdjMatrixNat σ R ^ n) =
      ∑ i : σ, walkCount σ R n i i := by
  exact Finset.sum_congr rfl fun i _ => adjMatrix_pow_eq_walkCount R n i i

/-
**Cyclic chain count equals trace**: For n ≥ 1, the number of cyclic R-chains
    of length n equals the trace of A^n.

    A cyclic chain w : Fin n → σ with R(w i, w(i+1 mod n)) corresponds
    bijectively to a closed walk of length n.
-/
theorem cyclicChainCount_eq_trace
    {σ : Type*} [Fintype σ] [DecidableEq σ]
    (R : σ → σ → Prop) [DecidableRel R]
    (n : ℕ) [NeZero n] :
    cyclicChainCount σ R n =
      Matrix.trace (relAdjMatrixNat σ R ^ n) := by
  convert trace_adjMatrix_pow_eq_closedWalkCount R n using 1;
  · -- By definition of $cyclicChainCount$, we have
    have h_cyclicChainCount : cyclicChainCount σ R n = Finset.card (Finset.filter (fun w => IsCyclicChain R w) (Finset.univ : Finset (Fin n → σ))) := by
      convert Fintype.card_subtype _;
    rw [ h_cyclicChainCount, trace_adjMatrix_pow_eq_closedWalkCount ];
    have h_bij : Finset.card (Finset.filter (fun w => IsCyclicChain R w) (Finset.univ : Finset (Fin n → σ))) = Finset.card (Finset.biUnion (Finset.univ : Finset σ) (fun i => Finset.image (fun w => fun k => w (Fin.castSucc k)) (Finset.filter (fun w => IsWalk R i i w) (Finset.univ : Finset (Fin (n + 1) → σ))))) := by
      refine' Finset.card_bij ( fun w hw => fun k => w k ) _ _ _ <;> simp +decide [ IsCyclicChain, IsWalk ];
      · intro a ha
        use fun k => if hk : k.val < n then a ⟨k.val, hk⟩ else a ⟨0, NeZero.pos n⟩
        simp [ha];
        intro k; specialize ha k; split_ifs <;> simp_all +decide [ Fin.add_def, Nat.mod_eq_of_lt ] ;
        convert ha using 2 ; simp +decide [ Nat.mod_eq_of_lt ( show ( k : ℕ ) + 1 < n + 1 from Nat.succ_lt_succ k.2 ), show ( k : ℕ ) + 1 = n from by linarith [ Fin.is_lt k ] ];
      · rintro b x hx₁ hx₂ rfl i; convert hx₂ i using 1;
        simp +decide [ Fin.add_def, Nat.mod_eq_of_lt ];
        cases eq_or_ne ( i + 1 : ℕ ) n <;> simp_all +decide [ Nat.mod_eq_of_lt ];
        · grind;
        · norm_num [ Nat.mod_eq_of_lt ( show ( i : ℕ ) + 1 < n from lt_of_le_of_ne ( Nat.succ_le_of_lt i.2 ) ‹_› ) ];
          rfl;
    rw [ h_bij, Finset.card_biUnion ];
    · refine' Finset.sum_congr rfl fun i _ => _;
      rw [ Finset.card_image_of_injOn, walkCount ];
      · rw [ Fintype.subtype_card ];
      · intro w hw w' hw' h_eq; simp_all +decide [ funext_iff, Fin.ext_iff ] ;
        intro x; induction x using Fin.lastCases <;> simp_all +decide [ IsWalk ] ;
    · intro i _ j _ hij; simp_all +decide [ Finset.disjoint_left, IsWalk ] ;
      intro a x hx₁ hx₂ hx₃ hx₄ y hy₁ hy₂ hy₃ hy₄; subst_vars; simp_all +decide [ funext_iff, Fin.forall_fin_succ ] ;
      cases n <;> simp_all +decide [ Fin.add_def, Fin.last ];
      · exact NeZero.ne 0 rfl;
      · exact hij ( by have := hy₄ 0; have := hy₄ ⟨ _, Nat.lt_succ_self _ ⟩ ; aesop );
  · exact trace_adjMatrix_pow_eq_closedWalkCount R n