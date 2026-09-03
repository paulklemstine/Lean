import Bridges.Ma1EffectiveSynthesis
import Mathlib.NumberTheory.DirichletCharacter.Orthogonality

/-!
# Fourier inversion: the exact converse of the character-sum bound

Cycle 4 of the MA-1 effectivization loop, closing the first conjecture recorded in
`FUTURE_DIRECTIONS.md`.

`Bridges.Ma1EffectiveEquidistribution` proves the *forward* direction — an `ε`-certificate on
the class counts bounds every nontrivial Dirichlet character sum by `φ(m)·ε·μ` — and the
converse only through the crude indicator test function.  Here the crude test function is
replaced by the full character basis, via the orthogonality relations for Dirichlet
characters, and the converse becomes an identity.

Main results.

* `fourier_inversion` — `Σ_χ χ(a⁻¹)·S_χ(N) = φ(m)·N a`, where `S_χ(N) = Σ_b χ(b)·N b`.  The
  count vector is *reconstructed* from its character sums.
* `dev_from_total_le_of_charSum_bound` — the converse bound: if every nontrivial character
  sum has modulus at most `S`, then `|φ(m)·N a − Σ_b N b| ≤ (φ(m) − 1)·S` for every class,
  i.e. every class count is within `((φ(m)−1)/φ(m))·S` of the empirical mean.
* `equiCert_charSum_round_trip` — the round trip: certificate `⇒` character-sum bound
  `⇒` deviation bound, with the honest loss factor `φ(m) − 1`.  The two formulations of
  equidistribution are equivalent, and the round trip costs exactly one factor of the class
  number; this is the quantitative price of passing through the dual side.
-/

namespace Ma1Effective

open Finset

variable {m : ℕ} [NeZero m] {N : (ZMod m)ˣ → ℝ}

/-- The character sum (twisted count) of a count vector. -/
noncomputable def charSum (N : (ZMod m)ˣ → ℝ) (χ : DirichletCharacter ℂ m) : ℂ :=
  ∑ b : (ZMod m)ˣ, χ (b : ZMod m) * (N b : ℂ)

/-- A Dirichlet character has modulus one at every unit. -/
theorem norm_dirichletChar_unit (χ : DirichletCharacter ℂ m) (u : (ZMod m)ˣ) :
    ‖χ (u : ZMod m)‖ = 1 := by
  have hp : (χ (u : ZMod m)) ^ (Fintype.card (ZMod m)ˣ) = 1 := by
    rw [← MulChar.coe_toUnitHom, ← Units.val_pow_eq_pow_val, ← map_pow, pow_card_eq_one, map_one]
    simp
  have hc := Fintype.card_pos (α := (ZMod m)ˣ)
  exact Complex.norm_eq_one_of_pow_eq_one hp (by omega)

omit [NeZero m] in
/-- A nontrivial Dirichlet character has nontrivial restriction to the units. -/
theorem toUnitHom_ne_one {χ : DirichletCharacter ℂ m} (h : χ ≠ 1) : χ.toUnitHom ≠ 1 := by
  intro hc
  apply h
  ext u
  have h1 := DFunLike.congr_fun hc u
  have h2 : (χ.toUnitHom u : ℂ) = ((1 : (ZMod m)ˣ →* ℂˣ) u : ℂ) := by rw [h1]
  simpa [MulChar.coe_toUnitHom] using h2

/-- There are `φ(m)` Dirichlet characters mod `m` with complex values. -/
theorem card_dirichletChar : Fintype.card (DirichletCharacter ℂ m) = Nat.totient m := by
  have h := DirichletCharacter.card_eq_totient_of_hasEnoughRootsOfUnity ℂ m
  rwa [Nat.card_eq_fintype_card] at h

/-- The trivial character reads off the total count. -/
theorem charSum_one : charSum N 1 = ((∑ b, N b : ℝ) : ℂ) := by
  unfold charSum
  push_cast
  refine Finset.sum_congr rfl fun b _ => ?_
  rw [MulChar.one_apply b.isUnit, one_mul]

/-- **Fourier inversion for the class counts.**  The count vector is reconstructed from its
Dirichlet character sums: `Σ_χ χ(a⁻¹)·S_χ = φ(m)·N a`. -/
theorem fourier_inversion (N : (ZMod m)ˣ → ℝ) (a : (ZMod m)ˣ) :
    ∑ χ : DirichletCharacter ℂ m, χ ((a : ZMod m))⁻¹ * charSum N χ
      = (Nat.totient m : ℂ) * (N a : ℂ) := by
  classical
  have hexp : ∀ χ : DirichletCharacter ℂ m,
      χ ((a : ZMod m))⁻¹ * charSum N χ
        = ∑ b : (ZMod m)ˣ, (χ ((a : ZMod m))⁻¹ * χ (b : ZMod m)) * (N b : ℂ) := by
    intro χ
    unfold charSum
    rw [Finset.mul_sum]
    exact Finset.sum_congr rfl fun b _ => by ring
  rw [Finset.sum_congr rfl fun χ _ => hexp χ, Finset.sum_comm]
  have hb : ∀ b : (ZMod m)ˣ,
      ∑ χ : DirichletCharacter ℂ m, (χ ((a : ZMod m))⁻¹ * χ (b : ZMod m)) * (N b : ℂ)
        = (if (a : ZMod m) = (b : ZMod m) then (Nat.totient m : ℂ) else 0) * (N b : ℂ) := by
    intro b
    rw [← Finset.sum_mul, DirichletCharacter.sum_char_inv_mul_char_eq ℂ a.isUnit _]
  rw [Finset.sum_congr rfl fun b _ => hb b]
  rw [Finset.sum_eq_single a]
  · rw [if_pos rfl]
  · intro b _ hb'
    have hne : (a : ZMod m) ≠ (b : ZMod m) := fun hcon => hb' (Units.ext hcon).symm
    rw [if_neg hne, zero_mul]
  · intro hmem
    exact absurd (Finset.mem_univ a) hmem

/-- **The converse of the character-sum bound.**  If every nontrivial character sum has
modulus at most `S`, then each class count is within `(φ(m) − 1)·S` of `φ(m)` times the
empirical mean.  This is the exact dual of `dirichletCharacter_sum_bound`. -/
theorem dev_from_total_le_of_charSum_bound {S : ℝ}
    (hS : ∀ χ : DirichletCharacter ℂ m, χ ≠ 1 → ‖charSum N χ‖ ≤ S) (a : (ZMod m)ˣ) :
    |(Nat.totient m : ℝ) * N a - ∑ b, N b| ≤ ((Nat.totient m : ℝ) - 1) * S := by
  classical
  have hinv := fourier_inversion N a
  -- split off the trivial character
  have hsplit : (1 : DirichletCharacter ℂ m) ((a : ZMod m))⁻¹ * charSum N 1
      + ∑ χ ∈ Finset.univ.erase (1 : DirichletCharacter ℂ m), χ ((a : ZMod m))⁻¹ * charSum N χ
      = (Nat.totient m : ℂ) * (N a : ℂ) := by
    rw [Finset.add_sum_erase Finset.univ
      (fun χ : DirichletCharacter ℂ m => χ ((a : ZMod m))⁻¹ * charSum N χ)
      (Finset.mem_univ 1)]
    exact hinv
  have hunit : ((a : ZMod m))⁻¹ = ((a⁻¹ : (ZMod m)ˣ) : ZMod m) := ZMod.inv_coe_unit a
  have hone : (1 : DirichletCharacter ℂ m) ((a : ZMod m))⁻¹ = 1 := by
    rw [hunit, MulChar.one_apply (a⁻¹ : (ZMod m)ˣ).isUnit]
  rw [hone, one_mul, charSum_one] at hsplit
  -- the remaining sum is the deviation
  have hdev : ((((Nat.totient m : ℝ) * N a - ∑ b, N b : ℝ)) : ℂ)
      = ∑ χ ∈ Finset.univ.erase (1 : DirichletCharacter ℂ m),
          χ ((a : ZMod m))⁻¹ * charSum N χ := by
    push_cast at hsplit ⊢
    linear_combination -hsplit
  have hnorm : ‖∑ χ ∈ Finset.univ.erase (1 : DirichletCharacter ℂ m),
      χ ((a : ZMod m))⁻¹ * charSum N χ‖ ≤ ((Nat.totient m : ℝ) - 1) * S := by
    have hterm : ∀ χ ∈ Finset.univ.erase (1 : DirichletCharacter ℂ m),
        ‖χ ((a : ZMod m))⁻¹ * charSum N χ‖ ≤ S := by
      intro χ hχ
      have hne : χ ≠ 1 := Finset.ne_of_mem_erase hχ
      rw [norm_mul, hunit, norm_dirichletChar_unit χ (a⁻¹ : (ZMod m)ˣ), one_mul]
      exact hS χ hne
    calc ‖∑ χ ∈ Finset.univ.erase (1 : DirichletCharacter ℂ m),
            χ ((a : ZMod m))⁻¹ * charSum N χ‖
        ≤ ∑ χ ∈ Finset.univ.erase (1 : DirichletCharacter ℂ m),
            ‖χ ((a : ZMod m))⁻¹ * charSum N χ‖ := norm_sum_le _ _
      _ ≤ ∑ _χ ∈ Finset.univ.erase (1 : DirichletCharacter ℂ m), S :=
          Finset.sum_le_sum hterm
      _ = ((Nat.totient m : ℝ) - 1) * S := by
          rw [Finset.sum_const, nsmul_eq_mul,
            Finset.card_erase_of_mem (Finset.mem_univ (1 : DirichletCharacter ℂ m)),
            Finset.card_univ, card_dirichletChar]
          have h1 : 1 ≤ Nat.totient m := Nat.totient_pos.2 (Nat.pos_of_ne_zero (NeZero.ne m))
          congr 1
          push_cast [Nat.cast_sub h1]
          ring
  have hcast : |(Nat.totient m : ℝ) * N a - ∑ b, N b|
      = ‖((((Nat.totient m : ℝ) * N a - ∑ b, N b : ℝ)) : ℂ)‖ := by
    rw [Complex.norm_real, Real.norm_eq_abs]
  rw [hcast, hdev]
  exact hnorm

/-- **The round trip.**  An `ε`-certificate implies a bound `φ(m)·ε·μ` on every nontrivial
character sum, and that bound implies in turn that every class count is within
`(φ(m) − 1)·φ(m)·ε·μ` of `φ(m)` times the empirical mean.  Passing through the dual side is
therefore lossy by exactly a factor `φ(m) − 1`: the character-sum formulation is strictly
weaker than the certificate for a fixed modulus, and only becomes equivalent when `φ(m)` is
treated as a constant. -/
theorem equiCert_charSum_round_trip {μ ε : ℝ} (h : EquiCert N μ ε) (a : (ZMod m)ˣ) :
    |(Nat.totient m : ℝ) * N a - ∑ b, N b|
      ≤ ((Nat.totient m : ℝ) - 1) * ((Nat.totient m : ℝ) * (ε * μ)) := by
  refine dev_from_total_le_of_charSum_bound (fun χ hχ => ?_) a
  exact dirichletCharacter_sum_bound χ (toUnitHom_ne_one hχ) h

end Ma1Effective