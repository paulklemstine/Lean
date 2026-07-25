import Mathlib

/-!
# Inverse limits of sequences of topological spaces

This file develops a small amount of theory about the inverse (projective) limit of a
sequence of topological spaces `F : ℕ → Type*` connected by bonding maps
`bond n : F (n+1) → F n`.

We define the underlying set `invLimitSet bond` of coherent sequences and the subtype
`InvLimit F bond`, and prove:

* `isClosed_invLimit`: the inverse limit is closed when each `F n` is Hausdorff and the
  bonding maps are continuous;
* `nonempty_invLimit`: the inverse limit is nonempty when each `F n` is nonempty and the
  bonding maps are surjective;
* `compactSpace_invLimit`: the inverse limit is compact when each `F n` is compact Hausdorff
  and the bonding maps are continuous.
-/

universe u

variable {F : ℕ → Type u} [∀ n, TopologicalSpace (F n)]

/-- The set of coherent sequences for the bonding maps `bond`. -/
def invLimitSet (bond : ∀ n, F (n+1) → F n) : Set (∀ n, F n) :=
  {x | ∀ n, bond n (x (n+1)) = x n}

/-- The inverse limit of the sequence `F` with bonding maps `bond`, as a subtype. -/
def InvLimit (F : ℕ → Type u) [∀ n, TopologicalSpace (F n)]
    (bond : ∀ n, F (n+1) → F n) : Type u :=
  {x // x ∈ invLimitSet bond}

instance instTopologicalSpaceInvLimit (bond : ∀ n, F (n+1) → F n) :
    TopologicalSpace (InvLimit F bond) :=
  inferInstanceAs (TopologicalSpace {x // x ∈ invLimitSet bond})

/-- The inverse limit is a closed subset of the product when each space is Hausdorff and the
bonding maps are continuous. -/
theorem isClosed_invLimit [∀ n, T2Space (F n)] (bond : ∀ n, F (n+1) → F n)
    (hbond : ∀ n, Continuous (bond n)) : IsClosed (invLimitSet bond) := by
  have : invLimitSet bond = ⋂ n, {x : ∀ n, F n | bond n (x (n+1)) = x n} := by
    ext x; simp [invLimitSet]
  rw [this]
  refine isClosed_iInter (fun n => ?_)
  have hcont : Continuous (fun x : ∀ n, F n => (bond n (x (n+1)), x n)) :=
    ((hbond n).comp (continuous_apply (n+1))).prodMk (continuous_apply n)
  have : {x : ∀ n, F n | bond n (x (n+1)) = x n}
      = (fun x : ∀ n, F n => (bond n (x (n+1)), x n)) ⁻¹' {p : F n × F n | p.1 = p.2} := rfl
  rw [this]
  exact (isClosed_diagonal).preimage hcont

/-- The inverse limit is nonempty when each space is nonempty and the bonding maps are
surjective.

The continuity hypothesis `hbond` is not needed for this statement; it is kept only to match
the requested signature. -/
theorem nonempty_invLimit [∀ n, Nonempty (F n)] (bond : ∀ n, F (n+1) → F n)
    (hbond : ∀ n, Continuous (bond n)) (hsurj : ∀ n, Function.Surjective (bond n)) :
    Nonempty (invLimitSet bond) := by
  -- Build a coherent sequence by choosing preimages step by step.
  classical
  let x : ∀ n, F n := fun n => Nat.rec (Classical.arbitrary (F 0))
    (fun k xk => (hsurj k xk).choose) n
  refine ⟨⟨x, fun n => ?_⟩⟩
  show bond n (x (n+1)) = x n
  exact (hsurj n (x n)).choose_spec

/-- The inverse limit of a sequence of compact Hausdorff spaces is compact. -/
instance compactSpace_invLimit [∀ n, CompactSpace (F n)] [∀ n, T2Space (F n)]
    (bond : ∀ n, F (n+1) → F n) (hbond : ∀ n, Continuous (bond n)) :
    CompactSpace (InvLimit F bond) := by
  have hcl : IsClosed (invLimitSet bond) := isClosed_invLimit bond hbond
  exact isCompact_iff_compactSpace.mp (hcl.isCompact)