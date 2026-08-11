/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Aristotle (Harmonic)
-/
import Mathlib
import Novelty.Z2CoindexJoin

/-!
# The multi-join law for the ℤ₂-coindex

This file *deepens* the join theory of `Novelty.Z2CoindexJoin` (the sharp two-factor join law
`coind(Oct m ⋆ Oct n) = m + n + 1` together with the constructive lower bound
`coind(K ⋆ L) ≥ coind K + coind L + 1`) by pushing it to **arbitrarily many factors**.

## The organising notion

The pivotal observation is that *any* iterated join of octahedral spheres is again a single
octahedral sphere.  We package this as `IsoOct K n`: an antipodally-equivariant vertex bijection
`K ≅ Oct n`.  It is closed under joins (`IsoOct.join`) with the additive-with-a-shift rule
`IsoOct K m → IsoOct L n → IsoOct (K ⋆ L) (m+n+1)`, and it determines the coindex outright
(`IsoOct.coind : IsoOct K n → coind K = n`).  Feeding the two base cases (`IsoOct.refl`) through
this closure computes the coindex of every finite octahedral join.

## Main results

* `IsoOct`, `IsoOct.coind`, `IsoOct.refl`, `IsoOct.join`, `IsoOct.congrN` — the equivariant
  "is an octahedral sphere" relation and its calculus.
* `octJoin`, `octJoin_iso`, `coind_octJoin_list` — the **multi-join law**:
  the join `Oct n ⋆ Oct l₀ ⋆ Oct l₁ ⋆ ⋯` of a head sphere `Oct n` with a list `l` of octahedral
  spheres has coindex exactly `n + l.sum + l.length`.
* `coind_octJoin_perm` — the coindex of an octahedral join depends only on the *multiset* of
  dimensions: it is invariant under permuting the factors.
* `coind_octJoin_replicate_zero` — the **suspension tower recovered**: joining `Oct n` with `k`
  copies of `S⁰ = Oct 0` yields coindex `n + k`, i.e. the `k`-fold suspension `Sⁿ ↦ Sⁿ⁺ᵏ`.
* `joinPow`, `joinPow_lower_bound` — the **constructive lower bound for iterated self-joins of an
  arbitrary free `ℤ₂`-set**: a witness `Oct a → K` powers up to a witness
  `Oct ((r+1)(a+1)-1) → K^{⋆(r+1)}`.
* `coind_joinPow_oct`, `coind_joinPow_S0` — the **sharp value on the octahedral tower**:
  the `(r+1)`-fold join of `Sᵃ` has coindex `(r+1)(a+1) - 1`; in particular the `(r+1)`-fold join
  of `S⁰` is `Sʳ`.
-/

namespace Z2CoindexMultiJoin

open Z2SuspensionTower Z2CoindexJoin

/-! ## The equivariant "is an octahedral sphere" relation -/

/-- `IsoOct K n` witnesses that the free `ℤ₂`-set `K` is `ℤ₂`-isomorphic to the octahedral sphere
`Oct n`, via an antipodally-equivariant vertex bijection. -/
structure IsoOct (K : FreeZ2) (n : ℕ) where
  /-- The underlying vertex equivalence `K ≅ Oct n`. -/
  e : K.V ≃ (Oct n).V
  /-- Equivariance with respect to the antipodal actions. -/
  he : ∀ p, e (K.anti p) = (Oct n).anti (e p)

/-- An octahedral witness pins the coindex: `IsoOct K n → coind K = n`. -/
lemma IsoOct.coind {K : FreeZ2} {n : ℕ} (h : IsoOct K n) : coind K = n := by
  rw [coind_congr h.e h.he, coind_Oct]

/-- Transport an octahedral witness along an equality of indices. -/
def IsoOct.congrN {K : FreeZ2} {m n : ℕ} (h : IsoOct K m) (hmn : m = n) : IsoOct K n :=
  hmn ▸ h

/-- Every octahedral sphere is (trivially) an octahedral sphere. -/
def IsoOct.refl (n : ℕ) : IsoOct (Oct n) n where
  e := Equiv.refl _
  he := fun _ => rfl

/-- **Octahedral witnesses are closed under joins** with the additive-with-a-shift rule. -/
def IsoOct.join {K L : FreeZ2} {m n : ℕ} (hK : IsoOct K m) (hL : IsoOct L n) :
    IsoOct (K ⋆ L) (m + n + 1) where
  e := (joinEquivVert hK.e hL.e).trans (octJoinEquiv m n)
  he := GMap.trans_equiv (joinEquivVert hK.e hL.e) (octJoinEquiv m n)
          (joinEquivVert_anti hK.e hL.e hK.he hL.he) (octJoinEquiv_anti m n)

/-! ## The multi-join over a list of octahedral spheres -/

/-- `octJoin n l` is the join of the head sphere `Oct n` with the octahedral spheres named by the
list `l`, associated to the right. -/
def octJoin : ℕ → List ℕ → FreeZ2
  | n, [] => Oct n
  | n, (m :: ms) => Oct n ⋆ octJoin m ms

/-- **Every finite octahedral join is an octahedral sphere**, of dimension
`n + l.sum + l.length`. -/
def octJoin_iso : ∀ (n : ℕ) (l : List ℕ), IsoOct (octJoin n l) (n + l.sum + l.length)
  | n, [] => (IsoOct.refl n).congrN (by simp)
  | n, (m :: ms) =>
      ((IsoOct.refl n).join (octJoin_iso m ms)).congrN (by
        simp only [List.sum_cons, List.length_cons]; omega)

/-- **The multi-join law.** The coindex of the octahedral join `Oct n ⋆ Oct l₀ ⋆ Oct l₁ ⋆ ⋯` is
exactly the sum of all dimensions plus the number of extra factors:
`coind(octJoin n l) = n + l.sum + l.length`. -/
theorem coind_octJoin_list (n : ℕ) (l : List ℕ) :
    coind (octJoin n l) = n + l.sum + l.length :=
  (octJoin_iso n l).coind

/-- **Permutation invariance.** The coindex of an octahedral join depends only on the multiset of
factor dimensions, so it is unchanged by permuting the factors. -/
theorem coind_octJoin_perm (n : ℕ) {l l' : List ℕ} (h : l.Perm l') :
    coind (octJoin n l) = coind (octJoin n l') := by
  rw [coind_octJoin_list, coind_octJoin_list, h.sum_eq, h.length_eq]

/-- **The suspension tower recovered.** Joining `Sⁿ = Oct n` with `k` copies of `S⁰ = Oct 0`
produces coindex `n + k`, i.e. the `k`-fold suspension `Sⁿ ↦ Sⁿ⁺ᵏ`. -/
theorem coind_octJoin_replicate_zero (n k : ℕ) :
    coind (octJoin n (List.replicate k 0)) = n + k := by
  rw [coind_octJoin_list, List.length_replicate, List.sum_replicate]
  simp

/-! ## Iterated self-joins of an arbitrary free ℤ₂-set -/

/-- `joinPow K r` is the `(r+1)`-fold join `K ⋆ K ⋆ ⋯ ⋆ K` of a free `ℤ₂`-set with itself. -/
def joinPow (K : FreeZ2) : ℕ → FreeZ2
  | 0 => K
  | (r + 1) => K ⋆ joinPow K r

/-- **Constructive lower bound for iterated self-joins.** A coindex witness `Oct a → K` powers up,
through the join bifunctor, to a witness `Oct ((r+1)(a+1)-1) → K^{⋆(r+1)}`. -/
theorem joinPow_lower_bound {K : FreeZ2} {a : ℕ} (h : Nonempty (GMap (Oct a) K)) :
    ∀ r, Nonempty (GMap (Oct ((r + 1) * (a + 1) - 1)) (joinPow K r))
  | 0 => by
      have hb : (0 + 1) * (a + 1) - 1 = a := by omega
      rw [hb]; exact h
  | (r + 1) => by
      have ih := joinPow_lower_bound h r
      have key := coindex_join_lower_bound h ih
      have hm : 1 ≤ (r + 1) * (a + 1) := Nat.one_le_iff_ne_zero.2 (by positivity)
      have e1 : (r + 1 + 1) * (a + 1) = (r + 1) * (a + 1) + (a + 1) := by ring
      have hidx : a + ((r + 1) * (a + 1) - 1) + 1 = (r + 1 + 1) * (a + 1) - 1 := by
        rw [e1]; omega
      rw [hidx] at key
      exact key

/-- **Sharp value on the octahedral tower.** The `(r+1)`-fold join of `Sᵃ = Oct a` is again an
octahedral sphere, of dimension `(r+1)(a+1) - 1`. -/
def joinPow_iso_oct (a : ℕ) : ∀ r, IsoOct (joinPow (Oct a) r) ((r + 1) * (a + 1) - 1)
  | 0 => (IsoOct.refl a).congrN (by omega)
  | (r + 1) =>
      ((IsoOct.refl a).join (joinPow_iso_oct a r)).congrN (by
        have hm : 1 ≤ (r + 1) * (a + 1) := Nat.one_le_iff_ne_zero.2 (by positivity)
        have e1 : (r + 1 + 1) * (a + 1) = (r + 1) * (a + 1) + (a + 1) := by ring
        rw [e1]; omega)

/-- **The sharp iterated join law on the octahedral tower.**
`coind(Sᵃ ⋆ Sᵃ ⋆ ⋯ ⋆ Sᵃ) = (r+1)(a+1) - 1` for the `(r+1)`-fold join. -/
theorem coind_joinPow_oct (a r : ℕ) :
    coind (joinPow (Oct a) r) = (r + 1) * (a + 1) - 1 :=
  (joinPow_iso_oct a r).coind

/-- **The classical join formula for the `0`-sphere.** The `(r+1)`-fold join of `S⁰` is `Sʳ`:
`coind(S⁰ ⋆ S⁰ ⋆ ⋯ ⋆ S⁰) = r`. -/
theorem coind_joinPow_S0 (r : ℕ) : coind (joinPow (Oct 0) r) = r := by
  simpa using coind_joinPow_oct 0 r

end Z2CoindexMultiJoin