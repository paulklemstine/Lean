/-
# Symmetry of the compensation map, and no-pinning for partial factorisations

Third companion to `Novelty/NoPinningLemma.lean`.  The no-pinning lemma says the
modulus-`L` data never excludes a candidate.  Here we describe *exactly what the
data does determine* — the partner class — and show that the group-theoretic
picture behind it is a single involution of `(ZMod L)ˣ`.

## Main results

* `compensating_class_unique` — the battery **does** determine the residue class
  of the cofactor: any two compensating partners of the same candidate are
  congruent mod `L`.  The pinning failure is therefore not a loss of
  information, but the fact that each class contains infinitely many primes.
* `partnerEquiv`, `partnerEquiv_involutive` — the compensation map
  `x ↦ N₀ · x⁻¹` is an involutive permutation of `(ZMod L)ˣ`; it exchanges the
  classes of the two factors, which is the "symmetric function of `(p,q)`"
  phenomenon (barrier 2) in group-theoretic form.
* `consistent_classes_eq_univ` — **full support**: every unit class of `ZMod L`
  contains a prime `p` that is consistent with the target, i.e. that has a prime
  partner `q` with `p·q ≡ N₀`.  The consistent set is the entire unit group.
* `no_pinning_of_partial_factorization` — no modulus-`L` battery can even
  exclude a *prescribed partial factorisation*: for any finite list of
  candidate factors coprime to `L`, infinitely many primes `q` complete it to a
  number with exactly the observed data.
-/

import Mathlib
import Novelty.NoPinningLemma

namespace Novelty.NoPinning

/-! ## What the data does determine: the partner class -/

/-- **Uniqueness of the partner class.**  Two compensating partners of the same
candidate `p` (coprime to `L`) are congruent modulo `L`.  A modulus-`L` battery
thus pins the cofactor's *residue class* exactly — and nothing more. -/
theorem compensating_class_unique {L : ℕ} [NeZero L] {N₀ p q q' : ℕ}
    (hp : Nat.Coprime p L) (h : p * q ≡ N₀ [MOD L]) (h' : p * q' ≡ N₀ [MOD L]) :
    q ≡ q' [MOD L] := by
  have hpu : IsUnit ((p : ZMod L)) := (ZMod.isUnit_iff_coprime p L).2 hp
  have h1 : ((p : ZMod L)) * (q : ZMod L) = ((p : ZMod L)) * (q' : ZMod L) := by
    have e1 : ((p * q : ℕ) : ZMod L) = (N₀ : ZMod L) :=
      (ZMod.natCast_eq_natCast_iff _ _ _).2 h
    have e2 : ((p * q' : ℕ) : ZMod L) = (N₀ : ZMod L) :=
      (ZMod.natCast_eq_natCast_iff _ _ _).2 h'
    push_cast at e1 e2
    rw [e1, e2]
  have hcancel : (q : ZMod L) = (q' : ZMod L) := by
    obtain ⟨u, hu⟩ := hpu
    rw [← hu] at h1
    exact (Units.mul_right_inj u).mp h1
  exact (ZMod.natCast_eq_natCast_iff _ _ _).1 hcancel

/-! ## The compensation involution -/

/-- The compensation map on unit classes: `x ↦ u · x⁻¹`, where `u` is the class
of the target `N₀`.  It sends the class of one factor to the class of the
other. -/
def partnerEquiv {L : ℕ} (u : (ZMod L)ˣ) : (ZMod L)ˣ ≃ (ZMod L)ˣ where
  toFun x := u * x⁻¹
  invFun x := u * x⁻¹
  left_inv x := by simp
  right_inv x := by simp

@[simp] theorem partnerEquiv_apply {L : ℕ} (u x : (ZMod L)ˣ) :
    partnerEquiv u x = u * x⁻¹ := rfl

/-- The compensation map is an involution: swapping the roles of the two factors
twice returns the original candidate.  This is the barrier-2 symmetry:
modulus-`L` data sees only the unordered pair of classes. -/
theorem partnerEquiv_involutive {L : ℕ} (u : (ZMod L)ˣ) :
    Function.Involutive (partnerEquiv u) := fun x => by
  simp [partnerEquiv]

/-- The partner class really is a compensating class: if `p` lies in the class
`x` and `q` in the class `partnerEquiv u x`, then `p · q ≡ N₀ (mod L)`. -/
theorem mul_partner_class {L : ℕ} [NeZero L] {N₀ p q : ℕ} (u : (ZMod L)ˣ)
    (hu : ((u : (ZMod L)ˣ) : ZMod L) = (N₀ : ZMod L)) (x : (ZMod L)ˣ)
    (hp : ((p : ZMod L)) = (x : ZMod L))
    (hq : ((q : ZMod L)) = ((partnerEquiv u x : (ZMod L)ˣ) : ZMod L)) :
    p * q ≡ N₀ [MOD L] := by
  rw [← ZMod.natCast_eq_natCast_iff]
  push_cast
  rw [hp, hq, ← hu]
  simp [partnerEquiv, mul_left_comm]

/-! ## Full support: every unit class is consistent -/

/-- **Full support of the consistent set.**  For any target `N₀` coprime to `L`,
*every* unit class of `ZMod L` contains a prime candidate that is consistent
with the modulus-`L` data: it has a prime partner producing exactly the observed
residue.  Consequently the data cuts nothing out of the candidate space, not
even at the level of residue classes. -/
theorem consistent_classes_eq_univ (L : ℕ) [NeZero L] {N₀ : ℕ}
    (hN : Nat.Coprime N₀ L) :
    {x : (ZMod L)ˣ | ∃ p q : ℕ, p.Prime ∧ q.Prime ∧
      ((p : ZMod L)) = (x : ZMod L) ∧ p * q ≡ N₀ [MOD L]} = Set.univ := by
  ext x
  simp only [Set.mem_setOf_eq, Set.mem_univ, iff_true]
  obtain ⟨p, hp, hpx⟩ :=
    (Nat.infinite_setOf_prime_and_eq_mod (x.isUnit)).nonempty
  have hpcop : Nat.Coprime p L := (ZMod.isUnit_iff_coprime p L).1 (hpx ▸ x.isUnit)
  obtain ⟨q, hq, -, hmod⟩ := (infinite_compensating_primes L hN hpcop).nonempty
  exact ⟨p, q, hp, hq, hpx, hmod⟩

/-! ## Partial factorisations are not excluded either -/

theorem coprime_list_prod_of_forall {L : ℕ} {ps : List ℕ}
    (h : ∀ p ∈ ps, Nat.Coprime p L) : Nat.Coprime ps.prod L := by
  induction ps with
  | nil => simp
  | cons a t ih =>
      rw [List.prod_cons]
      exact Nat.Coprime.mul_left (h a (by simp)) (ih fun b hb => h b (by simp [hb]))

/-- **No pinning of partial factorisations.**  Given any finite list `ps` of
prescribed candidate factors, each coprime to `L`, there are infinitely many
primes `q` such that the number `(∏ ps) · q` has exactly the modulus-`L` data of
the target `N₀`.  So a poly(log N)-computable congruence battery cannot rule out
any prescribed partial factorisation — not just any single factor. -/
theorem no_pinning_of_partial_factorization (L : ℕ) [NeZero L] (h2 : 2 ∣ L)
    {ps : List ℕ} (hps : ∀ p ∈ ps, Nat.Coprime p L) {N₀ : ℕ}
    (hN : Nat.Coprime N₀ L) :
    {q : ℕ | q.Prime ∧ Nat.Coprime q L ∧
      ∀ {β : Type} (f : ℕ → β), IsModObs L f → f (ps.prod * q) = f N₀}.Infinite :=
  no_pinning_universal L h2 hN (coprime_list_prod_of_forall hps)

/-- Battery form: for a list of prescribed factors, some prime `q` makes the
whole level-`L` battery agree with the target. -/
theorem exists_partial_factorization_partner (L : ℕ) [NeZero L] (h2 : 2 ∣ L)
    (Bat : List (ℕ → ℤ)) (hBat : ∀ f ∈ Bat, IsModObs L f)
    {ps : List ℕ} (hps : ∀ p ∈ ps, Nat.Coprime p L) {N₀ : ℕ}
    (hN : Nat.Coprime N₀ L) :
    ∃ q : ℕ, q.Prime ∧
      batteryValue Bat (ps.prod * q) = batteryValue Bat N₀ := by
  obtain ⟨q, hq, -, hall⟩ := (no_pinning_of_partial_factorization L h2 hps hN).nonempty
  exact ⟨q, hq, List.map_congr_left fun f hf => hall f (hBat f hf)⟩

end Novelty.NoPinning