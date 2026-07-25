/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Holographic Verification of Tree-Structured Proofs

This module develops, from first principles, a rigorous formal framework for *holographic
proof verification*: the principle that a tree-structured proof of size `n` admits a
deterministic verification certificate of length `O(log n)` via Merkle authentication paths.

The "holographic" slogan is the *depth–information duality*: the certificate length equals
the path (tree) depth, which for balanced proofs is logarithmic in the number of leaves.
This parallels the Bekenstein–Hawking principle that boundary information scales with depth
(area) rather than bulk volume.

## Main Definitions

* `Holographic.PTree`     — binary proof trees with `ℕ`-labelled leaves (leaf hashes).
* `Holographic.PTree.root` — the Merkle root of a tree under a binary hash `h`.
* `Holographic.PTree.valid` — well-formed navigation paths (`List Bool`).
* `Holographic.PTree.authPath` — the Merkle authentication path (sibling digests) for a path.
* `Holographic.PTree.reconstruct` — the verifier folding a leaf + certificate back to a root.
* `Holographic.PTree.perfect`  — perfectly balanced trees of a given height.

## Main Results

* `merkleVerify_correct`      — **Completeness**: an honest authentication path reconstructs
  the true Merkle root.
* `authPath_binding`          — **Soundness / collision-resistance binding**: under an
  injective hash, any leaf that verifies against the root *is* the committed leaf.
* `authPath_length_le_depth`  — the certificate length never exceeds the tree depth.
* `depth_succ_le_numLeaves`   — depth `+ 1 ≤` number of leaves (general size bound).
* `holographic_cert_bound`    — **Holographic bound**: for a perfect tree the certificate
  length equals `log₂` of the number of leaves — the `O(log n)` certificate.
-/

namespace Holographic

/-- A binary proof tree: a `leaf` carries a natural-number digest (a hash of an axiom /
boundary datum), and a `node` joins two sub-proofs. -/
inductive PTree where
  | leaf : ℕ → PTree
  | node : PTree → PTree → PTree
deriving DecidableEq, Repr

namespace PTree

/-- Number of leaves (the "size" / boundary data of the proof). -/
def numLeaves : PTree → ℕ
  | leaf _ => 1
  | node l r => numLeaves l + numLeaves r

/-- Tree depth (the bulk "radius"). -/
def depth : PTree → ℕ
  | leaf _ => 0
  | node l r => 1 + max (depth l) (depth r)

/-- The Merkle root of a tree under a binary hash `h`. -/
def root (h : ℕ → ℕ → ℕ) : PTree → ℕ
  | leaf x => x
  | node l r => h (root h l) (root h r)

/-- Validity of a navigation path: `false = go left`, `true = go right`. A path is valid iff
it ends exactly at a leaf. -/
def valid : PTree → List Bool → Prop
  | leaf _, [] => True
  | leaf _, _ :: _ => False
  | node _ _, [] => False
  | node l _, false :: p => valid l p
  | node _ r, true :: p => valid r p

/-- The leaf digest reached by following a path. -/
def leafAt : PTree → List Bool → ℕ
  | leaf x, _ => x
  | node l _, false :: p => leafAt l p
  | node _ r, true :: p => leafAt r p
  | node _ _, [] => 0

/-- The Merkle authentication path: the list of *sibling* digests encountered while
descending toward the target leaf. This is the holographic certificate. -/
def authPath (h : ℕ → ℕ → ℕ) : PTree → List Bool → List ℕ
  | leaf _, _ => []
  | node l r, false :: p => root h r :: authPath h l p
  | node l r, true :: p => root h l :: authPath h r p
  | node _ _, [] => []

/-- The verifier: fold a claimed leaf digest `x` and a certificate (sibling list) back up to
a root, using the navigation path to decide hash ordering at each level. -/
def reconstruct (h : ℕ → ℕ → ℕ) : ℕ → List Bool → List ℕ → ℕ
  | x, false :: p, s :: ss => h (reconstruct h x p ss) s
  | x, true :: p, s :: ss => h s (reconstruct h x p ss)
  | x, _, _ => x

/-- Perfectly balanced tree of height `k` (a `2^k`-leaf proof). -/
def perfect : ℕ → PTree
  | 0 => leaf 0
  | k + 1 => node (perfect k) (perfect k)

-- !-- Lab Notebook -- !--
-- Hypothesis: a Merkle authentication path is a *complete* and *sound* certificate of
--   leaf membership, with length governed by tree depth.
-- Result: completeness (`merkleVerify_correct`), soundness under injective hashing
--   (`authPath_binding`), and the depth/size length bounds below all hold for the binary
--   `PTree` model with an *arbitrary* hash `h : ℕ → ℕ → ℕ`.
-- Insight: completeness needs no assumption on `h`; only soundness invokes injectivity,
--   isolating exactly where collision-resistance is used.
-- Failure analysis: an early formulation indexed paths by `Fin (depth)` which created
--   index-arithmetic friction; switching to `List Bool` with a `valid` predicate removed it.
-- !-- end -- !--

/-! ### Completeness: honest certificates verify -/

/-
!-- merkleVerify_correct: by structural induction on `t` generalizing the path `p`;
at a `node`, `reconstruct` peels one hash layer and the inductive hypothesis supplies
the child root, while at a `leaf` the valid path is forced to be empty. -- !--

**Completeness.** The authentication path produced for a valid path reconstructs the
true Merkle root of the tree.
-/
theorem merkleVerify_correct (h : ℕ → ℕ → ℕ) (t : PTree) (p : List Bool)
    (hp : valid t p) :
    reconstruct h (leafAt t p) p (authPath h t p) = root h t := by
  induction' p with p_head p_tail ih generalizing t;
  · cases t <;> tauto;
  · cases t;
    · cases p_head <;> cases hp;
    · cases p_head <;> simp_all +decide [ PTree.valid ];
      · convert congr_arg ( fun x => h x ( root h ‹_› ) ) ( ih _ hp ) using 1;
      · convert congr_arg ( fun x => h ( root h _ ) x ) ( ih _ hp ) using 1

/-! ### Certificate length is governed by depth -/

/-
!-- authPath_length_eq: induction on `t`/`p`; each `node` step adds exactly one sibling
digest, matching the one consumed path bit. -- !--

The certificate length equals the navigation-path length.
-/
theorem authPath_length_eq (h : ℕ → ℕ → ℕ) (t : PTree) (p : List Bool)
    (hp : valid t p) :
    (authPath h t p).length = p.length := by
  induction t generalizing p <;> cases p <;> simp_all +decide [ List.length ];
  · rfl;
  · cases hp;
  · cases hp;
  · cases ‹Bool› <;> simp_all +decide [ PTree.valid ];
    · rename_i k hk₁ hk₂;
      convert congr_arg ( · + 1 ) ( k hk₂ hp ) using 1;
    · rename_i k hk₁ hk₂;
      convert congr_arg ( · + 1 ) ( hk₁ _ hp ) using 1

/-
!-- valid_length_le_depth: induction; descending into a child consumes one bit and the
child depth is `< depth t`. -- !--

Any valid navigation path is no longer than the tree depth.
-/
theorem valid_length_le_depth (t : PTree) (p : List Bool) (hp : valid t p) :
    p.length ≤ depth t := by
  induction' t with l r hl hr generalizing p;
  · cases p <;> trivial;
  · rcases p with ( _ | ⟨ b, p ⟩ ) <;> simp_all +decide [ PTree.depth ];
    cases b <;> simp_all +arith +decide [ PTree.valid ]

/-- **Certificate ≤ depth.** The holographic certificate is at most as long as the depth. -/
theorem authPath_length_le_depth (h : ℕ → ℕ → ℕ) (t : PTree) (p : List Bool)
    (hp : valid t p) :
    (authPath h t p).length ≤ depth t := by
  rw [authPath_length_eq h t p hp]
  exact valid_length_le_depth t p hp

/-
!-- depth_succ_le_numLeaves: induction; if `nₗ ≥ dₗ+1` and `nᵣ ≥ dᵣ+1` then
`nₗ+nᵣ ≥ max(dₗ,dᵣ)+2`. -- !--

**General size bound.** Depth `+1` is bounded by the number of leaves, so every
certificate has length `≤ numLeaves - 1`.
-/
theorem depth_succ_le_numLeaves (t : PTree) : depth t + 1 ≤ numLeaves t := by
  induction' t with t₁ t₂ ih₁ ih₂;
  · exact Nat.le_add_left _ _;
  · unfold PTree.depth PTree.numLeaves;
    grind

/-! ### Soundness: binding under collision resistance -/

/-
!-- authPath_binding: induction on `t`; at a `node`, `Function.Injective2 h` splits the
reconstructed hash equality into the two child equalities, and the inductive
hypothesis pins the claimed leaf. -- !--

**Soundness / binding.** If the hash `h` is (pairwise) injective — the formal stand-in
for collision resistance — then any claimed leaf digest `x` that verifies against the true
root along a valid path must equal the committed leaf. Forging a different leaf is
impossible.
-/
theorem authPath_binding (h : ℕ → ℕ → ℕ) (hinj : Function.Injective2 h)
    (t : PTree) (p : List Bool) (hp : valid t p) (x : ℕ)
    (heq : reconstruct h x p (authPath h t p) = root h t) :
    x = leafAt t p := by
  induction' p with p_head p_tail ih generalizing t x;
  · cases t <;> tauto;
  · rcases t with ( _ | ⟨ l, r ⟩ ) <;> rcases p_head with ( _ | _ ) <;> norm_num at *;
    · cases hp;
    · cases hp;
    · -- Apply the injectivity of `h` to split the equality `heq` into the two child equalities.
      have h_eq : reconstruct h x p_tail (authPath h l p_tail) = root h l := by
        exact hinj heq |>.1;
      exact ih l hp x h_eq;
    · exact ih r ( by tauto ) x ( by have := hinj heq; tauto )

/-! ### The holographic (logarithmic) bound for balanced proofs -/

/-
!-- perfect_numLeaves / perfect_depth: direct induction on the height `k`. -- !--

A perfect tree of height `k` has `2^k` leaves.
-/
theorem perfect_numLeaves (k : ℕ) : numLeaves (perfect k) = 2 ^ k := by
  induction k <;> simp_all +decide [ pow_succ', perfect ];
  simp_all +decide [ two_mul, PTree.numLeaves ]

/-
A perfect tree of height `k` has depth `k`.
-/
theorem perfect_depth (k : ℕ) : depth (perfect k) = k := by
  induction' k with k ih;
  · rfl;
  · -- By definition of depth, we have depth (node (perfect k) (perfect k)) = 1 + max (depth (perfect k)) (depth (perfect k)).
    have h_depth_succ : depth (PTree.node (perfect k) (perfect k)) = 1 + max (depth (perfect k)) (depth (perfect k)) := by
      rfl;
    convert h_depth_succ using 1 ; simp +arith +decide [ ih ]

/-
!-- valid_perfect_left: the all-`false` (leftmost) descent of length `k` is valid in a
height-`k` perfect tree, by induction on `k`. -- !--

The leftmost descent of length `k` is a valid path of the height-`k` perfect tree.
-/
theorem valid_perfect_left (k : ℕ) : valid (perfect k) (List.replicate k false) := by
  induction' k with k ih;
  · trivial;
  · exact ih

/-
**Holographic bound.** For a perfectly balanced proof (a `2^k`-leaf tree), the
authentication-path certificate of a leaf has length exactly `log₂` of the number of
leaves: an `O(log n)` certificate for an `n`-leaf proof.
-/
theorem holographic_cert_bound (h : ℕ → ℕ → ℕ) (k : ℕ) :
    (authPath h (perfect k) (List.replicate k false)).length
      = Nat.log 2 (numLeaves (perfect k)) := by
  convert authPath_length_eq h ( perfect k ) ( List.replicate k false ) ( valid_perfect_left k ) using 1;
  rw [ List.length_replicate,perfect_numLeaves, Nat.log_pow ( by decide ) ]

end PTree

end Holographic