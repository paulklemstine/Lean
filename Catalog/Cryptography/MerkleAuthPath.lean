/-
  Authentication-Path Soundness for Merkle Trees

  This module extends the binary Merkle-tree collision theory of
  `Cryptography.MerkleTreeHash` (definitions `treeHash`, `BTree`; theorems
  `treeHash_inj_sameShape`, `tree_collision_implies_compression_collision`,
  `treeHash_leftComb_eq_merkleDamgard`) and the linear Merkle–Damgård theory of
  `Cryptography.MerkleDamgard` (`merkleDamgard`, `foldl_joint_injective`) to
  *Merkle membership proofs* — the authentication paths verified by Git, Bitcoin
  SPV clients, and Certificate Transparency.

  An authentication path for a leaf at a fixed position is the list of sibling
  hashes encountered on the root-to-leaf path, each tagged by a side bit
  (`true` = the running value is the right child, `false` = the left child).
  The verifier recomputes the root by folding the compression `h` over this list.

  Main results:

  1. `verifyAt_joint_injective` — path verification is *jointly injective* in the
     opened value and the sibling list, once the side bits (the position) are
     fixed. This is the authentication-path analogue of
     `CryptoHash.foldl_joint_injective`.

  2. `authPath_soundness` — if the leaf map `g` and compression `h` are injective,
     two accepting openings at the same position with the same root are identical:
     you cannot open a Merkle proof to two different leaves.

  3. `authPath_collision_reduction` — the security reduction: a forged opening
     (a distinct leaf or distinct siblings that nonetheless verifies to the same
     root at the same position) yields an explicit `g`-collision or `h`-collision.
     Authentication-path soundness reduces to compression collision resistance.

  4. `verifyAt_allLeft_eq_merkleDamgard` — the **bridge**: an all-left
     authentication path (the running value is always the left child) is exactly
     the Merkle–Damgård fold over the sibling hashes, exhibiting path
     verification and `CryptoHash.merkleDamgard` as the same recursion on a spine.
-/

import Cryptography.MerkleTreeHash

namespace MerkleTree

variable {α : Type*} {γ : Type*}

/-! ## Authentication paths and their verification -/

/-- A single verification step at a fixed position. The boolean records whether
    the running hash sits as the *right* child (`true`) or the *left* child
    (`false`); `sib` is the sibling hash supplied by the proof. -/
def authStep (h : α → α → α) (acc : α) (sib : Bool × α) : α :=
  if sib.1 then h sib.2 acc else h acc sib.2

/-- Verify an authentication path: fold the compression `h` over the sibling
    list, starting from the opened (leaf) value `acc`, to recompute the root. -/
def verifyAt (h : α → α → α) (acc : α) (p : List (Bool × α)) : α :=
  p.foldl (authStep h) acc

@[simp] theorem verifyAt_nil (h : α → α → α) (acc : α) :
    verifyAt h acc [] = acc := rfl

@[simp] theorem verifyAt_cons (h : α → α → α) (acc : α) (s : Bool × α)
    (p : List (Bool × α)) :
    verifyAt h acc (s :: p) = verifyAt h (authStep h acc s) p := rfl

/-! ## Joint injectivity (fixed position) -/

/-
!-- Lab Notebook: authStep_injective -- !--
!-- Hypothesis: With the side bit fixed, one verification step is injective in
(running value, sibling), inheriting injectivity from h. -- !--
!-- Result: Proved by casing on the side bit and applying uncurried h-injectivity. -- !--
!-- Insight: The side bit must be FIXED; left-vs-right freedom is exactly the
obstruction (h s v = h v' s' has no contradiction across sides). -- !--
!-- Failure analysis: An earlier framing varying the side bit is NOT injective;
fixing the position (side sequence) is essential, mirroring "same shape". -- !--
!-- End Lab Notebook -- !--

!-- If two steps with the same side bit and the same running value agree,
the siblings agree (one direction of step injectivity). -- !--
-/
theorem authStep_sib_inj {h : α → α → α}
    (hh : Function.Injective (Function.uncurry h))
    {b : Bool} {acc s s' : α}
    (heq : authStep h acc (b, s) = authStep h acc (b, s')) :
    s = s' := by
      unfold authStep at heq;
      split_ifs at heq <;> have := @hh ( s, acc ) ( s', acc ) <;> have := @hh ( acc, s ) ( acc, s' ) <;> aesop

/-
!-- Lab Notebook: verifyAt_joint_injective -- !--
!-- Hypothesis: Once the side-bit sequence (the position) is fixed, path
verification is jointly injective in the opened value and the siblings. -- !--
!-- Result: Proved by induction on the path generalizing the second path and
both running values; one h-injectivity peels one layer. -- !--
!-- Insight: This is foldl_joint_injective transported through authStep; the
"same length" hypothesis of MD becomes "same position" (equal side bits). -- !--
!-- Failure analysis: Without hpos the heads can use opposite sides and the
statement is FALSE (see tree_cross_shape_collision_exists analogue). -- !--
!-- End Lab Notebook -- !--

!-- Proof sketch: induction on `p` generalizing `p'`, `v`, `v'`. The `hpos`
hypothesis forces matching list lengths and equal head side-bits; one
`authStep`/uncurried-`h` injectivity peels a layer, then the IH closes both
the value and the sibling-list equalities. Authentication-path analogue of
`CryptoHash.foldl_joint_injective`. -- !--

**Joint injectivity of path verification.** If `h` is injective (as a pair
    function) and two authentication paths share the same sequence of side bits
    (i.e. open the *same position*), then equal recomputed roots force both the
    opened values and the entire sibling lists to coincide.
-/
theorem verifyAt_joint_injective {h : α → α → α}
    (hh : Function.Injective (Function.uncurry h))
    {p p' : List (Bool × α)} {v v' : α}
    (hpos : p.map Prod.fst = p'.map Prod.fst)
    (heq : verifyAt h v p = verifyAt h v' p') :
    v = v' ∧ p = p' := by
      induction' p with bp p ih generalizing p' v v';
      · cases p' <;> aesop;
      · rcases p' with ( _ | ⟨ bp', p' ⟩ ) <;> simp_all +decide;
        rcases bp with ⟨ bp₁, bp₂ ⟩ ; rcases bp' with ⟨ bp₁', bp₂' ⟩ ; simp_all +decide ;
        specialize @ih p' ( authStep h v ( bp₁', bp₂ ) ) ( authStep h v' ( bp₁', bp₂' ) ) ; simp_all +decide [ authStep ];
        split_ifs at ih <;> have := @hh ( bp₂, v ) ( bp₂', v' ) <;> have := @hh ( v, bp₂ ) ( v', bp₂' ) <;> simp_all +decide [ Function.uncurry ]

/-! ## Soundness and the security reduction -/

/-
!-- Proof sketch: apply `verifyAt_joint_injective` to get `g x = g y` and
`p = p'`, then `hg` gives `x = y`. -- !--

**Authentication-path soundness.** With injective leaf map `g` and injective
    compression `h`, two accepting openings of the same root at the same position
    must be the *same* leaf opened with the *same* siblings: a Merkle proof
    cannot be opened to two different leaves.
-/
theorem authPath_soundness {g : γ → α} {h : α → α → α}
    (hg : Function.Injective g)
    (hh : Function.Injective (Function.uncurry h))
    {x y : γ} {p p' : List (Bool × α)}
    (hpos : p.map Prod.fst = p'.map Prod.fst)
    (heq : verifyAt h (g x) p = verifyAt h (g y) p') :
    x = y ∧ p = p' := by
      exact ⟨ hg <| by have := verifyAt_joint_injective hh hpos heq; aesop, by have := verifyAt_joint_injective hh hpos heq; aesop ⟩

/-
!-- Proof sketch: contrapositive of `authPath_soundness`. If neither `g` nor
`h` collided they would be injective, forcing `x = y` and `p = p'`,
contradicting the assumed distinct opening. -- !--

**Authentication-path security reduction** (main theorem). A *forged* opening —
    a distinct leaf or distinct sibling list that still verifies to the same root
    at the same position — yields an explicit collision in the leaf map `g` or in
    the compression `h`. Soundness of Merkle proofs reduces to compression
    collision resistance, exactly as `treeHash_inj_sameShape` does for whole trees.
-/
theorem authPath_collision_reduction (g : γ → α) (h : α → α → α)
    {x y : γ} {p p' : List (Bool × α)}
    (hpos : p.map Prod.fst = p'.map Prod.fst)
    (hne : x ≠ y ∨ p ≠ p')
    (heq : verifyAt h (g x) p = verifyAt h (g y) p') :
    (∃ a b : γ, a ≠ b ∧ g a = g b) ∨
      (∃ u v : α × α, u ≠ v ∧ Function.uncurry h u = Function.uncurry h v) := by
        contrapose! hne;
        exact authPath_soundness ( fun a b hab => by contrapose! hab; exact hne.1 a b hab ) ( fun u v huv => by contrapose! huv; exact hne.2 u v huv ) hpos heq

/-! ## Bridge to Merkle–Damgård -/

/-
!-- Proof sketch: `authStep h acc (false, s) = h acc s`, so folding over an
all-left path equals `List.foldl h`, which is `merkleDamgard h`. Uses
`List.foldl_map`. -- !--

**Bridge theorem.** An all-left authentication path (the running value is
    always the left child) recomputes the root by *exactly* the Merkle–Damgård
    fold over the sibling hashes. Thus path verification and
    `merkleDamgard` (from `Cryptography.MerkleDamgard`) are the same recursion
    restricted to a spine — the authentication-path counterpart of
    `treeHash_leftComb_eq_merkleDamgard`.
-/
theorem verifyAt_allLeft_eq_merkleDamgard (h : α → α → α) (v : α) (ss : List α) :
    verifyAt h v (ss.map (fun s => (false, s))) = merkleDamgard h v ss := by
      unfold verifyAt merkleDamgard;
      unfold authStep; induction ss using List.reverseRecOn <;> aesop;

end MerkleTree