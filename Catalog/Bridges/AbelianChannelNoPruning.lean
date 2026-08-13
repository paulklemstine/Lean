/-
# The abelian channel no-pruning theorem

Fifth file of the residue-leakage thread.  This closes conjecture **C3** of
`FUTURE_DIRECTIONS.md` for a fixed conductor: the Dirichlet no-pruning
phenomenon is not about quadratic residues at all.  It holds for *every* finite
family of Dirichlet characters of a fixed modulus — i.e. for every abelian
residue channel of bounded conductor, in any coefficient ring.

Given probes `χ₁,…,χ_K : DirichletCharacter R M` define the *character
fingerprint* `Φ(N) = [χ_i(N)]`.  For a target `N₀` coprime to `M` and any
candidate prime `p ∤ M`, put `q` in the class `N₀ · p⁻¹ (mod M)`: then
`χ_i(pq) = χ_i(p)·χ_i(N₀ p⁻¹) = χ_i(N₀)` for every `i`, and Dirichlet's theorem
supplies infinitely many primes in that class.

The quadratic case (`Bridges.ResidueLeakageDirichletNoPruning`) is the special
case where each `χ_i` is the Jacobi symbol `(a_i | ·)` of conductor `4a_i`; there
`p⁻¹ ≡ p` up to squares, which is why the compensating class was `N₀ · p`.
-/

import Mathlib

namespace Bridges.ResidueLeakage

/-- The character fingerprint of `N` relative to a list of Dirichlet characters
of modulus `M`. -/
def charFingerprint {R : Type*} [CommMonoidWithZero R] {M : ℕ}
    (X : List (DirichletCharacter R M)) (N : ℕ) : List R :=
  X.map (fun χ => χ (N : ZMod M))

/-- **Abelian no-pruning.**  For any finite family of Dirichlet characters of a
fixed modulus `M`, any target `N₀` coprime to `M`, and any candidate `p`
coprime to `M` (primality of `p` is not even needed), there are infinitely many
primes `q` such that `p·q` has exactly
the same character fingerprint as `N₀`.

No abelian residue channel of bounded conductor can eliminate a single candidate
prime factor. -/
theorem abelian_channel_no_pruning {R : Type*} [CommMonoidWithZero R] {M : ℕ}
    [NeZero M] (X : List (DirichletCharacter R M)) {N₀ p : ℕ}
    (hN₀ : Nat.Coprime N₀ M) (hpM : Nat.Coprime p M) :
    {q : ℕ | q.Prime ∧ charFingerprint X (p * q) = charFingerprint X N₀}.Infinite := by
  -- the compensating class `N₀ · p⁻¹`
  set u : (ZMod M)ˣ := ZMod.unitOfCoprime p hpM with hu
  set v : (ZMod M)ˣ := ZMod.unitOfCoprime N₀ hN₀ with hv
  have hup : ((u : ZMod M)) = (p : ZMod M) := rfl
  have hvN : ((v : ZMod M)) = (N₀ : ZMod M) := rfl
  have hunit : IsUnit (((v * u⁻¹ : (ZMod M)ˣ) : ZMod M)) := Units.isUnit _
  refine (Nat.infinite_setOf_prime_and_eq_mod hunit).mono ?_
  rintro q ⟨hq, hqc⟩
  refine ⟨hq, ?_⟩
  refine List.map_congr_left fun χ _ => ?_
  have hcast : ((p * q : ℕ) : ZMod M) = (p : ZMod M) * (q : ZMod M) := by push_cast; ring
  rw [hcast, hqc, map_mul]
  have hkey : (p : ZMod M) * ((v * u⁻¹ : (ZMod M)ˣ) : ZMod M) = (N₀ : ZMod M) := by
    have hgrp : (u * (v * u⁻¹) : (ZMod M)ˣ) = v := by
      rw [mul_comm v u⁻¹, ← mul_assoc, mul_inv_cancel, one_mul]
    calc (p : ZMod M) * ((v * u⁻¹ : (ZMod M)ˣ) : ZMod M)
        = ((u * (v * u⁻¹) : (ZMod M)ˣ) : ZMod M) := by
          rw [Units.val_mul u (v * u⁻¹), hup]
      _ = (N₀ : ZMod M) := by rw [hgrp, hvN]
  rw [← map_mul, hkey]

/-- Existence form. -/
theorem exists_abelian_compensating_prime {R : Type*} [CommMonoidWithZero R]
    {M : ℕ} [NeZero M] (X : List (DirichletCharacter R M)) {N₀ p : ℕ}
    (hN₀ : Nat.Coprime N₀ M) (hpM : Nat.Coprime p M) :
    ∃ q : ℕ, q.Prime ∧ charFingerprint X (p * q) = charFingerprint X N₀ := by
  obtain ⟨q, hq⟩ := (abelian_channel_no_pruning X hN₀ hpM).nonempty
  exact ⟨q, hq.1, hq.2⟩

/-! ## A quadratic instance: the supplementary symbol at `2` -/

private theorem coprime_eight_of_odd {n : ℕ} (hn : Odd n) : Nat.Coprime n 8 := by
  have h2 : Nat.Coprime n 2 := Nat.coprime_two_right.2 hn
  have := h2.pow_right 3
  norm_num at this
  exact this

/-- Instance of the general theorem for the mod-`8` quadratic character: the
symbol `(2 | ·)` cannot prune either.  Here the general machinery reproduces a
case of `dirichlet_no_pruning` without any use of quadratic reciprocity. -/
theorem jacobiSym_two_no_pruning {N₀ p : ℕ} (hN₀ : Odd N₀) (hp : Odd p) :
    {q : ℕ | q.Prime ∧ jacobiSym 2 (p * q) = jacobiSym 2 N₀}.Infinite := by
  refine (abelian_channel_no_pruning [ZMod.χ₈] (coprime_eight_of_odd hN₀)
    (coprime_eight_of_odd hp)).mono ?_
  rintro q ⟨hq, hf⟩
  have hval : ZMod.χ₈ ((p * q : ℕ) : ZMod 8) = ZMod.χ₈ ((N₀ : ℕ) : ZMod 8) := by
    simpa only [charFingerprint, List.map_cons, List.map_nil, List.cons.injEq,
      and_true] using hf
  have hNne : ZMod.χ₈ ((N₀ : ℕ) : ZMod 8) ≠ 0 := by
    rw [← jacobiSym.at_two hN₀]
    have hcop : Int.gcd 2 (N₀ : ℕ) = 1 := by
      have : Nat.Coprime 2 N₀ := (Nat.coprime_two_right.2 hN₀).symm
      simpa [Int.gcd] using this
    rcases jacobiSym.eq_one_or_neg_one hcop with h | h <;> rw [h] <;> norm_num
  have hqodd : Odd q := by
    rcases hq.eq_two_or_odd' with rfl | h
    · exfalso
      apply hNne
      rw [← hval, ZMod.χ₈_nat_eq_if_mod_eight]
      simp
    · exact h
  refine ⟨hq, ?_⟩
  rw [jacobiSym.at_two (hp.mul hqodd), jacobiSym.at_two hN₀]
  exact_mod_cast hval

end Bridges.ResidueLeakage