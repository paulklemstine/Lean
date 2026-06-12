/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Logic.HolographicVerification

/-!
# Holographic Certificates under Proof Composition

Building on `Logic.HolographicVerification`, this module studies how Merkle
authentication-path certificates behave under *composition* of proofs — the operation by
which a large mathematical development is assembled from smaller pieces.

Sequential composition of `k` proofs is modelled as a right-leaning chain of binary joins.
The central result, `chain_cert_subadditive`, formalizes the **subadditivity of certificate
length under composition**: the certificate for a `k`-fold composition is bounded by the sum
of the component depths plus `k`. Thus modular verification is "holographic up to a linear
composition overhead" — exactly the controlled blow-up predicted for modular proof systems.

## Main Definitions

* `Holographic.PTree.compose` — binary composition of two proofs (a Merkle join).
* `Holographic.PTree.chain`   — right-leaning sequential composition of a list of proofs.

## Main Results

* `compose_depth`, `compose_numLeaves` — composition arithmetic.
* `cert_subadditive`        — a single composition adds at most `1` to the combined depth.
* `chain_depth_le`          — depth of a `k`-chain `≤ Σ depthᵢ + k`.
* `chain_cert_subadditive`  — **composition subadditivity**: the holographic certificate of a
  `k`-fold composition has length `≤ Σ depthᵢ + k`.
-/

namespace Holographic

namespace PTree

/-- Binary composition of two proofs: a Merkle join with the two proofs as children. -/
def compose (t1 t2 : PTree) : PTree := node t1 t2

@[simp] theorem compose_depth (t1 t2 : PTree) :
    depth (compose t1 t2) = 1 + max (depth t1) (depth t2) := rfl

@[simp] theorem compose_numLeaves (t1 t2 : PTree) :
    numLeaves (compose t1 t2) = numLeaves t1 + numLeaves t2 := rfl

/-- Descending into the left component of a composition exposes the right root as the first
sibling digest of the certificate. -/
@[simp] theorem compose_authPath_left (h : ℕ → ℕ → ℕ) (t1 t2 : PTree) (p : List Bool) :
    authPath h (compose t1 t2) (false :: p) = root h t2 :: authPath h t1 p := rfl

/-- Descending into the right component of a composition exposes the left root as the first
sibling digest of the certificate. -/
@[simp] theorem compose_authPath_right (h : ℕ → ℕ → ℕ) (t1 t2 : PTree) (p : List Bool) :
    authPath h (compose t1 t2) (true :: p) = root h t1 :: authPath h t2 p := rfl

-- !-- Lab Notebook -- !--
-- Hypothesis: composing proofs preserves the holographic (short-certificate) property with
--   only a controlled, linear-in-`k` overhead.
-- Result: `cert_subadditive` (one composition costs `+1`) and `chain_cert_subadditive`
--   (`k`-fold composition costs `Σ depthᵢ + k`) both hold, reusing the depth bound
--   `authPath_length_le_depth` from the core module.
-- Insight: subadditivity is purely a *depth* phenomenon — it needs nothing about the hash
--   `h`, so it holds for every commitment scheme. The blow-up is therefore structural, not
--   cryptographic.
-- Failure analysis: defining `chain` with a default `leaf 0` for the empty list keeps the
--   recursion total and avoids `Option`/nonempty-list friction in the induction.
-- !-- end -- !--

-- !-- cert_subadditive: `authPath_length_le_depth` bounds the certificate by the composed
--     depth `1 + max (depth t1) (depth t2)`, which is `≤ depth t1 + depth t2 + 1`. -- !--
/-- A single composition increases the certificate length by at most one beyond the sum of
the component depths. -/
theorem cert_subadditive (h : ℕ → ℕ → ℕ) (t1 t2 : PTree) (p : List Bool)
    (hp : valid (compose t1 t2) p) :
    (authPath h (compose t1 t2) p).length ≤ depth t1 + depth t2 + 1 := by
  have h_depth : (authPath h (compose t1 t2) p).length ≤ depth (compose t1 t2) :=
    authPath_length_le_depth h (compose t1 t2) p hp
  rw [compose_depth] at h_depth
  omega

/-- Right-leaning sequential composition of a list of proofs. The empty composition is the
trivial one-leaf proof. -/
def chain : List PTree → PTree
  | [] => leaf 0
  | [t] => t
  | t :: ts => compose t (chain ts)

-- !-- chain_depth_le: strong induction following the three `chain` cases; a non-empty cons
--     adds `1 + depth(head)` over the recursive bound, matching the right-hand increment. -- !--
/-- The depth of a `k`-fold sequential composition is bounded by the sum of the component
depths plus `k` (the number of composed proofs). -/
theorem chain_depth_le (ts : List PTree) :
    depth (chain ts) ≤ (ts.map depth).sum + ts.length := by
  induction' n : ts.length using Nat.strong_induction_on with n ih generalizing ts
  rcases ts with ( _ | ⟨ t, _ | ⟨ u, ts ⟩ ⟩ ) <;> simp_all +arith +decide
  · aesop
  · subst n; exact le_add_of_nonneg_of_le (by norm_num) (by rfl)
  · rw [show chain (t :: u :: ts) = compose t (chain (u :: ts)) from rfl]
    simp +arith +decide [*]
    grind

-- !-- chain_cert_subadditive: combine `authPath_length_le_depth` with `chain_depth_le`. -- !--
/-- **Composition subadditivity (holographic certificates).** For any sequential composition
of `k = ts.length` proofs, every authentication-path certificate has length at most the sum
of the component depths plus `k`. Hence modular verification is holographic up to a linear
composition overhead. -/
theorem chain_cert_subadditive (h : ℕ → ℕ → ℕ) (ts : List PTree) (p : List Bool)
    (hp : valid (chain ts) p) :
    (authPath h (chain ts) p).length ≤ (ts.map depth).sum + ts.length := by
  calc (authPath h (chain ts) p).length ≤ depth (chain ts) :=
        authPath_length_le_depth h (chain ts) p hp
    _ ≤ (ts.map depth).sum + ts.length := chain_depth_le ts

end PTree

end Holographic