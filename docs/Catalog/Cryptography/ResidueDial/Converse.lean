import Cryptography.ResidueDial.Battery

/-!
# The converse capstone: structure blindness, factor blindness, and the cap

This file collects the *converse* statements: not "here is a dial that helps",
but "no dial of any kind helps beyond `4/3`", and — more sharply — "the internal
structure of the dial is invisible to the law".

## Lemma B2 (structure blindness)

`speedup_blind_to_structure`, `fiber_dial_speedup_eq_of_card_eq`: two dials of
equal density have *identical* speedup, whatever their internal structure.  In
particular a dial built by mixing character fibres — the `n = 3`, `n = 5` cubic
and quintic residue readings, or any reading into `n` symbols
(`symbolDial`) — cannot beat a plain half-density set, and half-density symbol
dials attain the cap exactly (`symbolDial_speedup_eq_four_thirds`).

## Corollary A2 (which-factor blindness is an identity)

For a semiprime `N = p·q` with `N ≡ c (mod M)`, the classes of `p` and `q` are
exchanged by the involution `u ↦ c·u⁻¹` (`factorSwap`,
`factorSwap_apply_of_mul_eq`).  Since densities are invariant under this
bijection (`density_image_factorSwap`), reading a dial against `p` and reading
it against `q` give *exactly* the same speedup (`which_factor_blind`): the
which-factor blindness observed empirically is an identity, not an
approximation.

## The capstone

`residue_dial_converse`: every residue dial, every fibre/character dial, and
every CRT battery is capped by `4/3`, strictly below the asked barrier `2`; and
`cap_attained_iff_half_density` pins down exactly when the cap is met.
-/

namespace ResidueDial

open Finset

variable {M : ℕ} [NeZero M]

/-! ## Density in terms of cardinality -/

theorem density_eq_half_iff (K : Finset (ZMod M)ˣ) :
    density M K = 1 / 2 ↔ 2 * K.card = M.totient := by
  have hpos : (0:ℝ) < (M.totient : ℝ) := by exact_mod_cast totient_pos_of_neZero M
  rw [density, div_eq_div_iff (ne_of_gt hpos) (by norm_num : (2:ℝ) ≠ 0)]
  constructor
  · intro h
    have : ((2 * K.card : ℕ) : ℝ) = ((M.totient : ℕ) : ℝ) := by push_cast; linarith
    exact_mod_cast this
  · intro h
    have : ((2 * K.card : ℕ) : ℝ) = ((M.totient : ℕ) : ℝ) := by exact_mod_cast h
    push_cast at this
    linarith

/-- Dials of equal cardinality have equal density. -/
theorem density_eq_of_card_eq {K L : Finset (ZMod M)ˣ} (h : K.card = L.card) :
    density M K = density M L := by
  rw [density, density, h]

/-! ## Lemma B2: the law is blind to the dial's internal structure -/

/-- **Lemma B2.**  The speedup depends on the dial only through its
cardinality: two filters of the same size — one a subgroup, one a coset, one a
random scatter, one a union of character fibres — buy exactly the same. -/
theorem speedup_blind_to_structure {K L : Finset (ZMod M)ˣ} (h : K.card = L.card) :
    speedup (density M K) = speedup (density M L) := by
  rw [density_eq_of_card_eq h]

/-- Structure blindness across moduli: only the density matters, not the
modulus, its factorisation, or the dial's arithmetic content. -/
theorem speedup_eq_of_density_eq {M' : ℕ} [NeZero M'] {K : Finset (ZMod M)ˣ}
    {L : Finset (ZMod M')ˣ} (h : density M K = density M' L) :
    speedup (density M K) = speedup (density M' L) := by rw [h]

/-! ## Character / symbol dials: `n = 3`, `n = 5`, and all the rest -/

open scoped Classical in
/-- A *symbol dial*: read each residue class through a reading
`f : (ZMod M)ˣ → S` (a character, a power-residue symbol, a tuple of several
such readings) and keep the classes whose symbol lies in `T`. -/
noncomputable def symbolDial {S : Type*} (f : (ZMod M)ˣ → S) (T : Finset S) :
    Finset (ZMod M)ˣ :=
  (univ : Finset (ZMod M)ˣ).filter (fun u => f u ∈ T)

open scoped Classical in
@[simp] theorem mem_symbolDial {S : Type*} (f : (ZMod M)ˣ → S) (T : Finset S)
    (u : (ZMod M)ˣ) : u ∈ symbolDial f T ↔ f u ∈ T := by
  simp [symbolDial]

/-- **No character content helps.**  A dial built from any reading into any
symbol set is capped by `4/3` like every other dial. -/
theorem symbolDial_speedup_le_four_thirds {S : Type*} (f : (ZMod M)ˣ → S) (T : Finset S) :
    speedup (density M (symbolDial f T)) ≤ 4 / 3 :=
  speedup_le_four_thirds _

/-- **Mixing fibres cannot beat a plain set.**  A symbol dial and an arbitrary
dial of the same size are indistinguishable to the law — this is the precise
form of "Lemma B2 kills all internal structure". -/
theorem fiber_dial_speedup_eq_of_card_eq {S : Type*} (f : (ZMod M)ˣ → S) (T : Finset S)
    (K : Finset (ZMod M)ˣ) (h : (symbolDial f T).card = K.card) :
    speedup (density M (symbolDial f T)) = speedup (density M K) :=
  speedup_blind_to_structure h

/-- A symbol dial that keeps exactly half of the classes attains the cap — and
attains it *exactly*, for any reading `f` and any symbol subset `T`. -/
theorem symbolDial_speedup_eq_four_thirds {S : Type*} (f : (ZMod M)ˣ → S) (T : Finset S)
    (h : 2 * (symbolDial f T).card = M.totient) :
    speedup (density M (symbolDial f T)) = 4 / 3 :=
  speedup_eq_four_thirds_iff.mpr ((density_eq_half_iff _).mpr h)

/-- The cubic (`n = 3`) reading: cap `4/3`. -/
theorem cubic_dial_speedup_le_four_thirds (f : (ZMod M)ˣ → Fin 3) (T : Finset (Fin 3)) :
    speedup (density M (symbolDial f T)) ≤ 4 / 3 :=
  symbolDial_speedup_le_four_thirds f T

/-- The quintic (`n = 5`) reading: cap `4/3`. -/
theorem quintic_dial_speedup_le_four_thirds (f : (ZMod M)ˣ → Fin 5) (T : Finset (Fin 5)) :
    speedup (density M (symbolDial f T)) ≤ 4 / 3 :=
  symbolDial_speedup_le_four_thirds f T

/-! ## Corollary A2: which-factor blindness as an identity -/

/-- The involution exchanging the two factors of a semiprime: if `p·q ≡ c`
modulo `M`, then the class of `q` is `c` times the inverse of the class of
`p`. -/
def factorSwap (c : (ZMod M)ˣ) : (ZMod M)ˣ ≃ (ZMod M)ˣ where
  toFun u := c * u⁻¹
  invFun u := c * u⁻¹
  left_inv u := by simp [mul_inv_rev]
  right_inv u := by simp [mul_inv_rev]

omit [NeZero M] in
@[simp] theorem factorSwap_apply (c u : (ZMod M)ˣ) : factorSwap c u = c * u⁻¹ := rfl

omit [NeZero M] in
/-- The defining property: the swap really sends one factor's class to the
other's. -/
theorem factorSwap_apply_of_mul_eq {c u v : (ZMod M)ˣ} (h : u * v = c) :
    factorSwap c u = v := by
  rw [factorSwap_apply, ← h]
  simp [mul_assoc]

/-- Relabelling a dial by the factor swap does not change its density. -/
theorem density_image_factorSwap (c : (ZMod M)ˣ) (K : Finset (ZMod M)ˣ) :
    density M (K.image (factorSwap c)) = density M K := by
  classical
  rw [density, density, Finset.card_image_of_injective _ (factorSwap c).injective]

/-- **Corollary A2 (which-factor blindness is an identity).**  Reading a dial
against the first factor of a semiprime or against the second — the two readings
being related by `factorSwap` — yields *exactly* the same speedup.  There is no
residual advantage in choosing which factor to filter. -/
theorem which_factor_blind (c : (ZMod M)ˣ) (K : Finset (ZMod M)ˣ) :
    speedup (density M (K.image (factorSwap c))) = speedup (density M K) := by
  rw [density_image_factorSwap]

/-! ## Positional and interval witnesses -/

/-- **The cap is not special to congruences.**  In the finite scan model the
realized speedup of *any* filter on *any* finite class space — positional,
interval, congruence, or mixed — is at most `4/3`.  This closes the framing
question for witnesses that are not residue classes, as long as the test is
read in the same worst-case-in-phase accounting. -/
theorem positional_dial_cap {α : Type*} [Fintype α] [DecidableEq α] (K : Finset α)
    (hn : 0 < Fintype.card α) :
    (Fintype.card α : ℝ) / expectedScanCost K ≤ 4 / 3 := by
  rw [model_speedup K hn]
  exact speedup_le_four_thirds _

open scoped Classical in
/-- An *interval dial*: keep the scan positions lying in `[a, b)`. -/
noncomputable def intervalDial (n a b : ℕ) : Finset (Fin n) :=
  (univ : Finset (Fin n)).filter (fun i => a ≤ (i : ℕ) ∧ (i : ℕ) < b)

open scoped Classical in
/-- Interval (positional) witnesses obey the same universal cap. -/
theorem interval_dial_cap {n : ℕ} (hn : 0 < n) (a b : ℕ) :
    (Fintype.card (Fin n) : ℝ) / expectedScanCost (intervalDial n a b) ≤ 4 / 3 :=
  positional_dial_cap _ (by simpa using hn)

/-! ## The capstone -/

/-- Exactly when the cap is met: half density, and nothing else. -/
theorem cap_attained_iff_half_density (K : Finset (ZMod M)ˣ) :
    speedup (density M K) = 4 / 3 ↔ 2 * K.card = M.totient := by
  rw [speedup_eq_four_thirds_iff, density_eq_half_iff]

/-- **The converse theorem for the congruence stratum.**  For every modulus,
every dial (however structured), every symbol/character reading, and every CRT
battery, the speedup is at most `4/3` — strictly below the asked barrier `2` —
and the bound is tight: for `M > 2` a half-density dial attains it exactly. -/
theorem residue_dial_converse (K : Finset (ZMod M)ˣ) :
    speedup (density M K) ≤ 4 / 3 ∧ speedup (density M K) < 2 ∧
      (2 < M → ∃ L : Finset (ZMod M)ˣ, speedup (density M L) = 4 / 3) := by
  refine ⟨speedup_le_four_thirds _, speedup_lt_two _, fun hM => ?_⟩
  exact exists_dial_speedup_eq_four_thirds M (Nat.totient_even hM)

/-- The battery form of the capstone: composing dials on coprime moduli — the
CRT "battery" — obeys the very same cap, so no amount of composed capacity
reaches a factor-`2` speedup. -/
theorem battery_converse {m n : ℕ} [NeZero m] [NeZero n] (h : Nat.Coprime m n)
    (K₁ : Finset (ZMod m)ˣ) (K₂ : Finset (ZMod n)ˣ) :
    speedup (density (m * n) (crtDial h K₁ K₂))
        = speedup (density m K₁ * density n K₂) ∧
      speedup (density (m * n) (crtDial h K₁ K₂)) ≤ 4 / 3 ∧
      speedup (density (m * n) (crtDial h K₁ K₂)) < 2 := by
  refine ⟨by rw [crtDial_density], speedup_le_four_thirds _, speedup_lt_two _⟩

end ResidueDial