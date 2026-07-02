import Mathlib

/-!
# Merkle-Tree Commitments for Zero-Knowledge Theorem Proving

The zero-knowledge theorem-proving protocol of the mission begins with step (1):
*the prover commits to each proof step using a collision-resistant hash*. The
standard device that makes this scale — a prover with an `n`-step proof publishes
a single short digest, yet can later open **any one** challenged step succinctly —
is the **Merkle tree**.

This file formalizes Merkle commitments over a complete binary tree of depth `d`,
whose `2^d` leaves are indexed by bit-strings `Fin d → Bool` (a leaf address is a
top-down list of left/right choices). A two-argument *compression function*
`h : α → α → α` folds child digests into parent digests. The salient
cryptographic contents are:

* **Binding of the root** (`mroot_binding`): if two different leaf assignments
  hash to the *same* Merkle root, then `h` has an explicit collision. Hence, under
  collision-resistance, the root binds the prover to a unique proof.
* **Perfect binding** (`mroot_injective`): if `h` is (jointly) injective — an
  idealized collision-free hash — the Merkle root is an injective function of the
  leaves, so the commitment determines the committed proof uniquely.
* **Opening completeness** (`recompute_auth`): the honest authentication path for
  a leaf (the sibling digests along its root path) recomputes exactly the true
  root. This is protocol step (3): "the prover opens that step."
* **Opening binding** (`path_binding`): if two authentication paths for the *same*
  leaf address recompute to the same root but claim *different* leaf values, then
  `h` again has an explicit collision. So a challenged step cannot be opened two
  ways — the verifier's single-step check is meaningful.

Together these say: the Merkle root is a succinct, binding commitment to the whole
proof, and each opened step is itself bound — exactly the properties the
zero-knowledge theorem-proving protocol relies on, with all "collision-resistance"
uses made explicit as constructed collisions.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): A hash-tree digest should be *binding* precisely to the
extent `h` is collision-resistant: any ambiguity in the committed leaves must
"surface" as a collision at some internal node on the divergence path. Two
surprising sub-claims: (a) binding holds with **no** algebraic assumption on `h`
whatsoever — the collision is *constructed*, not assumed away; (b) the same
inductive extractor handles both the global root and a single opened leaf.

Experiment (Experimenter): Modeled leaves as `f : (Fin d → Bool) → α` and defined
`mroot` by recursion on depth, splitting on the *first* address bit via `Fin.cons`.
Verified on depth 0 (root = the unique leaf, so equal roots ⟹ equal leaves) and the
inductive step: equal roots either collide at the top node (distinct child pairs) or
force equal child digests, whereupon `f ≠ g` pushes the divergence into one subtree
and the induction hypothesis manufactures the collision. The opening machinery
(`authPath`, `recompute`) was checked to satisfy `recompute_auth` by the same
first-bit case split, and `path_binding` reuses the identical top-node dichotomy.

Analysis (Analyst): The load-bearing fact is structural, not arithmetic: a compression
tree is binding "for free," and the security assumption (collision-resistance) enters
only when one wants to *conclude* uniqueness (`mroot_injective`). The reduction is
fully constructive — it names the colliding inputs — which is exactly what a soundness
extractor needs. Failure mode considered and avoided: indexing leaves by `Fin (2^d)`
forces awkward `Nat` arithmetic in the split; bit-string addresses with `Fin.cons`
make the recursion definitional.

Critique (Critic): None of the four results is `True`-shaped or `decide`-closed:
each returns/《consumes》an explicit collision witness or an injectivity statement, and
each proof is a genuine `induction` on depth with a nontrivial case dichotomy. The
binding theorems are non-vacuous for every `d` (for `d = 0` the "collision" branch is
unreachable and the leaf-equality branch does the work, which is the honest content).

Synthesis (PI): Root binding + perfect binding + opening completeness + opening
binding = a complete, assumption-free account of why a Merkle commitment lets a
prover commit to an entire proof with one digest yet be held to every opened step.
-- !-- Lab Notes -- !--
-/

namespace ZK.MerkleCommitment

open Function

variable {α : Type*}

/-- The Merkle root of a complete binary tree of depth `d` whose leaves are indexed
by bit-string addresses `Fin d → Bool`. At depth `d+1` the first address bit selects
the left (`false`) vs. right (`true`) subtree, and `h` folds the two subtree roots. -/
def mroot (h : α → α → α) : (d : ℕ) → ((Fin d → Bool) → α) → α
  | 0, f => f Fin.elim0
  | d + 1, f => h (mroot h d (fun p => f (Fin.cons false p)))
                  (mroot h d (fun p => f (Fin.cons true p)))

/-- An explicit collision of the compression function `h`: two *distinct* input
pairs with equal images. Under collision-resistance such a witness is infeasible to
find, so every theorem below whose conclusion is `HasCollision h` is a constructive
reduction of ambiguity to breaking `h`. -/
def HasCollision (h : α → α → α) : Prop :=
  ∃ a b a' b', h a b = h a' b' ∧ (a, b) ≠ (a', b')

/-! ## Binding of the Merkle root -/

/-- **Root binding (computational).** If two leaf assignments `f ≠ g` produce the
*same* Merkle root, then `h` has an explicit collision. Equivalently: to open a
single committed root as two different proofs, the prover must break collision
resistance. The proof is a depth induction whose inductive step performs the
top-node dichotomy "distinct child digests ⟹ collision here / equal child digests ⟹
divergence recurses into one subtree." -/
theorem mroot_binding (h : α → α → α) : ∀ (d : ℕ) (f g : (Fin d → Bool) → α),
    mroot h d f = mroot h d g → f ≠ g → HasCollision h := by
  intro d
  induction d with
  | zero =>
    intro f g hr hne
    exfalso; apply hne
    funext p
    have : p = Fin.elim0 := by funext i; exact i.elim0
    subst this; simpa [mroot] using hr
  | succ d ih =>
    intro f g hr hne
    simp only [mroot] at hr
    set F0 := mroot h d (fun p => f (Fin.cons false p))
    set F1 := mroot h d (fun p => f (Fin.cons true p))
    set G0 := mroot h d (fun p => g (Fin.cons false p))
    set G1 := mroot h d (fun p => g (Fin.cons true p))
    by_cases hcol : (F0, F1) = (G0, G1)
    · rw [Prod.mk.injEq] at hcol
      obtain ⟨e0, e1⟩ := hcol
      have hrest : (fun p => f (Fin.cons false p)) ≠ (fun p => g (Fin.cons false p)) ∨
                   (fun p => f (Fin.cons true p)) ≠ (fun p => g (Fin.cons true p)) := by
        by_contra hc
        push_neg at hc
        obtain ⟨hcf, hct⟩ := hc
        apply hne
        funext p
        have hp : p = Fin.cons (p 0) (Fin.tail p) := (Fin.cons_self_tail p).symm
        rw [hp]
        cases hb : p 0
        · exact congrFun hcf (Fin.tail p)
        · exact congrFun hct (Fin.tail p)
      rcases hrest with hr0 | hr1
      · exact ih _ _ e0 hr0
      · exact ih _ _ e1 hr1
    · exact ⟨F0, F1, G0, G1, hr, hcol⟩

/-- **Perfect binding.** If the compression function `h` is jointly injective — an
idealized collision-free hash — then the Merkle root is an injective function of the
leaves: distinct proofs never share a root, so the commitment determines the
committed proof uniquely. -/
theorem mroot_injective (h : α → α → α)
    (hinj : ∀ a b a' b', h a b = h a' b' → a = a' ∧ b = b') (d : ℕ) :
    Function.Injective (mroot h d) := by
  intro f g hr
  by_contra hne
  obtain ⟨a, b, a', b', he, hcol⟩ := mroot_binding h d f g hr hne
  obtain ⟨ha, hb⟩ := hinj a b a' b' he
  exact hcol (by rw [ha, hb])

/-! ## Authentication paths: opening a single committed step -/

/-- The honest authentication path for the leaf at address `path`: the list of
*sibling* subtree digests encountered on the way from the root to the leaf. -/
def authPath (h : α → α → α) :
    (d : ℕ) → (path : Fin d → Bool) → ((Fin d → Bool) → α) → (Fin d → α)
  | 0, _, _ => Fin.elim0
  | d + 1, path, f =>
      Fin.cons
        (mroot h d (fun p => f (Fin.cons (!(path 0)) p)))
        (authPath h d (Fin.tail path) (fun p => f (Fin.cons (path 0) p)))

/-- The verifier's root recomputation from a claimed `leaf` value at address `path`
together with a supplied list of sibling digests `sibs`: fold `h` up the path,
placing the sibling on the correct side dictated by each address bit. -/
def recompute (h : α → α → α) : (d : ℕ) → (path : Fin d → Bool) → α → (Fin d → α) → α
  | 0, _, leaf, _ => leaf
  | d + 1, path, leaf, sibs =>
      let child := recompute h d (Fin.tail path) leaf (Fin.tail sibs)
      if path 0 = false then h child (sibs 0) else h (sibs 0) child

/-- **Opening completeness.** The honest authentication path for a leaf recomputes
exactly the true Merkle root. This is protocol step (3): the prover opens the
challenged step and the verifier's recomputation matches the published commitment. -/
theorem recompute_auth (h : α → α → α) :
    ∀ (d : ℕ) (path : Fin d → Bool) (f : (Fin d → Bool) → α),
    recompute h d path (f path) (authPath h d path f) = mroot h d f := by
  intro d
  induction d with
  | zero =>
    intro path f
    simp only [recompute, mroot]
    congr 1
    funext i; exact i.elim0
  | succ d ih =>
    intro path f
    simp only [recompute, authPath, Fin.cons_zero, Fin.tail_cons]
    have hfp : f (Fin.cons (path 0) (Fin.tail path)) = f path := by
      rw [Fin.cons_self_tail]
    have key := ih (Fin.tail path) (fun p => f (Fin.cons (path 0) p))
    simp only [hfp] at key
    cases hb : path 0
    · simp only [hb, Bool.not_false, if_true] at key ⊢
      rw [key]; simp [mroot]
    · simp only [hb, Bool.not_true] at key ⊢
      rw [key]; simp [mroot]

/-- **Opening binding.** If two authentication paths for the *same* leaf address
recompute to the same root but claim *different* leaf values, then `h` has an
explicit collision. Hence a prover cannot open a single challenged step two ways
without breaking collision resistance — the verifier's per-step check is sound. -/
theorem path_binding (h : α → α → α) :
    ∀ (d : ℕ) (path : Fin d → Bool) (leaf leaf' : α) (sibs sibs' : Fin d → α),
    recompute h d path leaf sibs = recompute h d path leaf' sibs' →
    leaf ≠ leaf' → HasCollision h := by
  intro d
  induction d with
  | zero =>
    intro path leaf leaf' sibs sibs' hr hne
    simp only [recompute] at hr
    exact absurd hr hne
  | succ d ih =>
    intro path leaf leaf' sibs sibs' hr hne
    simp only [recompute] at hr
    set c := recompute h d (Fin.tail path) leaf (Fin.tail sibs) with hc
    set c' := recompute h d (Fin.tail path) leaf' (Fin.tail sibs') with hc'
    cases hb : path 0 <;> simp only [hb] at hr
    · by_cases hpair : (c, sibs 0) = (c', sibs' 0)
      · rw [Prod.mk.injEq] at hpair
        exact ih (Fin.tail path) leaf leaf' (Fin.tail sibs) (Fin.tail sibs') hpair.1 hne
      · exact ⟨c, sibs 0, c', sibs' 0, hr, hpair⟩
    · by_cases hpair : (sibs 0, c) = (sibs' 0, c')
      · rw [Prod.mk.injEq] at hpair
        exact ih (Fin.tail path) leaf leaf' (Fin.tail sibs) (Fin.tail sibs') hpair.2 hne
      · exact ⟨sibs 0, c, sibs' 0, c', hr, hpair⟩

end ZK.MerkleCommitment