/-
# Sylvester's gap count for two-loop machines

`Computation.DegreeMonoidStructure` shows that the two-loop chain machine of coprime
`p, q > 1` has a largest unrealisable computation length `p*q - p - q` (the Frobenius
number).  This file computes the *whole* obstruction, not just its maximum: the number of
computation lengths that the machine cannot realise is exactly `(p-1)*(q-1)/2`
(`sylvester_gap_ncard`), Sylvester's classical count, here proved from scratch through:

* `mem_pair_closure_iff` — membership in `⟨p,q⟩` as a two-variable representation problem;
* `exists_residue` / `mem_iff_residue_le` — the **residue criterion**: writing `b` for the
  unique residue in `[0,p)` with `b*q ≡ n (mod p)`, one has `n ∈ ⟨p,q⟩ ↔ b*q ≤ n`;
* `frobenius_symmetry` — the **symmetry of the numerical semigroup**: for `0 ≤ n ≤ F` exactly
  one of `n` and `F - n` is realisable (this is the statement that `⟨p,q⟩` is a symmetric
  numerical semigroup);
* the resulting involution `n ↦ F - n` pairs gaps with non-gaps below `F`, giving the count.

All results are proved with no `sorry`.
-/
import Mathlib
import Computation.DegreeMonoidRealisation
import Computation.DegreeMonoidStructure

namespace Computation
namespace DegreeMonoid

section Sylvester

variable {p q : ℕ}

/-- Membership in the numerical semigroup `⟨p,q⟩` as a representation problem. -/
theorem mem_pair_closure_iff {n : ℕ} :
    n ∈ AddSubmonoid.closure ({p, q} : Set ℕ) ↔ ∃ a b : ℕ, a * p + b * q = n := by
  rw [AddSubmonoid.mem_closure_pair]
  simp [smul_eq_mul]

/-- For coprime `q, p` with `p > 0` every `n` has a residue `b < p` with `b*q ≡ n (mod p)`. -/
theorem exists_residue (hp : 0 < p) (cop : Nat.Coprime q p) (n : ℕ) :
    ∃ b < p, (p : ℤ) ∣ (n : ℤ) - (b : ℤ) * (q : ℤ) := by
  haveI : NeZero p := ⟨by omega⟩
  set u := ZMod.unitOfCoprime q cop with hu
  set z : ZMod p := (n : ZMod p) * ((u⁻¹ : (ZMod p)ˣ) : ZMod p) with hz
  refine ⟨z.val, ZMod.val_lt z, ?_⟩
  have hcast : ((z.val : ℕ) : ZMod p) = z := by
    simp [ZMod.natCast_val, ZMod.cast_id]
  have hinv : ((u⁻¹ : (ZMod p)ˣ) : ZMod p) * (q : ZMod p) = 1 := by
    have h1 : ((u : (ZMod p)ˣ) : ZMod p) = (q : ZMod p) := by
      rw [hu, ZMod.coe_unitOfCoprime]
    rw [← h1]
    exact_mod_cast u.inv_mul
  have hmain : ((z.val * q : ℕ) : ZMod p) = (n : ZMod p) := by
    push_cast
    rw [hcast, hz, mul_assoc, hinv, mul_one]
  have hmod : (z.val * q) ≡ n [MOD p] := (ZMod.natCast_eq_natCast_iff _ _ _).1 hmain
  have hdvd := (Nat.modEq_iff_dvd).1 hmod
  push_cast at hdvd
  exact hdvd

/-- **Residue criterion.**  If `b < p` is the residue of `n` (i.e. `b*q ≡ n (mod p)`), then
`n` lies in `⟨p,q⟩` exactly when `b*q ≤ n`. -/
theorem mem_iff_residue_le (cop : Nat.Coprime p q) {n b : ℕ} (hb : b < p)
    (hdvd : (p : ℤ) ∣ (n : ℤ) - (b : ℤ) * (q : ℤ)) :
    n ∈ AddSubmonoid.closure ({p, q} : Set ℕ) ↔ b * q ≤ n := by
  have hcopZ : IsCoprime (p : ℤ) (q : ℤ) := Nat.isCoprime_iff_coprime.2 cop
  constructor
  · intro hmem
    obtain ⟨a, c, hac⟩ := mem_pair_closure_iff.1 hmem
    have hn : (n : ℤ) = (a : ℤ) * p + (c : ℤ) * q := by exact_mod_cast hac.symm
    have hsub : (p : ℤ) ∣ ((c : ℤ) - (b : ℤ)) * q := by
      have h1 : (p : ℤ) ∣ (a : ℤ) * p := ⟨a, by ring⟩
      have h2 : (n : ℤ) - (b : ℤ) * q - (a : ℤ) * p = ((c : ℤ) - (b : ℤ)) * q := by
        rw [hn]; ring
      rw [← h2]
      exact dvd_sub hdvd h1
    have hcb : (p : ℤ) ∣ (c : ℤ) - (b : ℤ) := hcopZ.dvd_of_dvd_mul_right hsub
    have hble : b ≤ c := by
      by_contra hlt
      push_neg at hlt
      have hpos : (0 : ℤ) < (b : ℤ) - (c : ℤ) := by
        have : (c : ℤ) < (b : ℤ) := by exact_mod_cast hlt
        omega
      have hdvd' : (p : ℤ) ∣ (b : ℤ) - (c : ℤ) := by
        have h := dvd_neg.mpr hcb
        simpa using h
      have hle : (p : ℤ) ≤ (b : ℤ) - (c : ℤ) := Int.le_of_dvd hpos hdvd'
      have hbp : (b : ℤ) < (p : ℤ) := by exact_mod_cast hb
      omega
    calc b * q ≤ c * q := Nat.mul_le_mul_right q hble
      _ ≤ a * p + c * q := Nat.le_add_left _ _
      _ = n := hac
  · intro hle
    have hZ : ((n - b * q : ℕ) : ℤ) = (n : ℤ) - (b : ℤ) * q := by
      push_cast [Nat.cast_sub hle]
      ring
    have hdvdN : (p : ℕ) ∣ (n - b * q) := by
      have : (p : ℤ) ∣ ((n - b * q : ℕ) : ℤ) := by rw [hZ]; exact hdvd
      exact_mod_cast this
    obtain ⟨a, ha⟩ := hdvdN
    refine mem_pair_closure_iff.2 ⟨a, b, ?_⟩
    have hn : n = p * a + b * q := (Nat.sub_eq_iff_eq_add hle).mp ha
    rw [hn]
    ring

/-- **Symmetry of `⟨p,q⟩`.**  With `F = p*q - p - q`, for every `n ≤ F` exactly one of `n`
and `F - n` is a realisable length. -/
theorem frobenius_symmetry (cop : Nat.Coprime p q) (hp : 1 < p) (hq : 1 < q) {n : ℕ}
    (hn : n ≤ p * q - p - q) :
    (n ∉ AddSubmonoid.closure ({p, q} : Set ℕ) ↔
      (p * q - p - q - n) ∈ AddSubmonoid.closure ({p, q} : Set ℕ)) := by
  have hpq : p + q ≤ p * q := Nat.add_le_mul hp hq
  set F := p * q - p - q with hF
  have hFZ : (F : ℤ) = (p : ℤ) * q - p - q := by
    rw [hF]; push_cast [Nat.cast_sub (by omega : q ≤ p * q - p),
      Nat.cast_sub (by omega : p ≤ p * q)]; ring
  obtain ⟨b, hb, hdvd⟩ := exists_residue (by omega) cop.symm n
  -- the residue of `F - n` is `p - 1 - b`
  have hb' : p - 1 - b < p := by omega
  have hdvd' : (p : ℤ) ∣ ((F - n : ℕ) : ℤ) - ((p - 1 - b : ℕ) : ℤ) * (q : ℤ) := by
    have hcast1 : ((F - n : ℕ) : ℤ) = (F : ℤ) - (n : ℤ) := by
      push_cast [Nat.cast_sub hn]; ring
    have hcast2 : ((p - 1 - b : ℕ) : ℤ) = (p : ℤ) - 1 - (b : ℤ) := by omega
    rw [hcast1, hcast2, hFZ]
    have hEq : ((p : ℤ) * q - p - q - n) - ((p : ℤ) - 1 - b) * q
        = -( (p : ℤ) ) + (((b : ℤ) * q) - (n : ℤ)) := by ring
    rw [hEq]
    have h1 : (p : ℤ) ∣ ((b : ℤ) * q - (n : ℤ)) := by
      have := hdvd.neg_right
      simpa using (dvd_neg.2 hdvd)
    exact dvd_add (Dvd.intro (-1) (by ring)) h1
  rw [mem_iff_residue_le cop hb hdvd, mem_iff_residue_le cop hb' hdvd']
  -- translate both sides into arithmetic over ℤ
  have hbq : (p : ℤ) ∣ (n : ℤ) - (b : ℤ) * q := hdvd
  constructor
  · intro hlt
    have hnlt : (n : ℤ) < (b : ℤ) * q := by
      push_neg at hlt
      exact_mod_cast hlt
    -- `b*q - n` is a positive multiple of `p`, hence at least `p`
    have hposZ : (0 : ℤ) < (b : ℤ) * q - (n : ℤ) := by omega
    have hdvd2 : (p : ℤ) ∣ (b : ℤ) * q - (n : ℤ) := by simpa using (dvd_neg.2 hbq)
    have hple : (p : ℤ) ≤ (b : ℤ) * q - (n : ℤ) := Int.le_of_dvd hposZ hdvd2
    have hgoal : ((p - 1 - b : ℕ) : ℤ) * q ≤ ((F - n : ℕ) : ℤ) := by
      have hcast1 : ((F - n : ℕ) : ℤ) = (F : ℤ) - (n : ℤ) := by
        push_cast [Nat.cast_sub hn]; ring
      have hcast2 : ((p - 1 - b : ℕ) : ℤ) = (p : ℤ) - 1 - (b : ℤ) := by omega
      rw [hcast1, hcast2, hFZ]
      nlinarith [hple]
    exact_mod_cast hgoal
  · intro hge hlt
    -- both `n ≥ b*q` and `(p-1-b)*q ≤ F - n` cannot hold
    have h1 : ((p - 1 - b : ℕ) : ℤ) * q ≤ ((F - n : ℕ) : ℤ) := by exact_mod_cast hge
    have h2 : ((b : ℤ)) * q ≤ (n : ℤ) := by exact_mod_cast hlt
    have hcast1 : ((F - n : ℕ) : ℤ) = (F : ℤ) - (n : ℤ) := by
      push_cast [Nat.cast_sub hn]; ring
    have hcast2 : ((p - 1 - b : ℕ) : ℤ) = (p : ℤ) - 1 - (b : ℤ) := by omega
    rw [hcast1, hcast2, hFZ] at h1
    have hppos : (0 : ℤ) < (p : ℤ) := by exact_mod_cast (by omega : 0 < p)
    nlinarith [h1, h2, hppos]

/-! ## The gap count -/

/-- The set of gaps of `⟨p,q⟩` is contained in `[0, F]`. -/
theorem gaps_subset (cop : Nat.Coprime p q) (hp : 1 < p) (hq : 1 < q) :
    {n : ℕ | n ∉ AddSubmonoid.closure ({p, q} : Set ℕ)} ⊆ Set.Iic (p * q - p - q) := by
  intro n hn
  have hgt := (frobeniusNumber_iff.1 (frobeniusNumber_pair cop hp hq)).2
  simp only [Set.mem_setOf_eq] at hn
  simp only [Set.mem_Iic]
  by_contra hle
  push_neg at hle
  exact hn (hgt n hle)

/-- **Sylvester's gap count.**  The two-loop machine of coprime `p, q > 1` fails to realise
exactly `(p-1)*(q-1)/2` computation lengths. -/
theorem sylvester_gap_ncard (cop : Nat.Coprime p q) (hp : 1 < p) (hq : 1 < q) :
    {n : ℕ | n ∉ degreeMonoid (chainRel ({p, q} : Set ℕ)) 0}.ncard = (p - 1) * (q - 1) / 2 := by
  classical
  have hDeg : degreeMonoid (chainRel ({p, q} : Set ℕ)) 0 = AddSubmonoid.closure ({p, q} : Set ℕ) :=
    degreeMonoid_chainRel _
  rw [hDeg]
  have hpq : p + q ≤ p * q := Nat.add_le_mul hp hq
  set F := p * q - p - q with hF
  set G : Finset ℕ := (Finset.range (F + 1)).filter
    (fun n => n ∉ AddSubmonoid.closure ({p, q} : Set ℕ)) with hG
  set H : Finset ℕ := (Finset.range (F + 1)).filter
    (fun n => n ∈ AddSubmonoid.closure ({p, q} : Set ℕ)) with hH
  -- the gap set is exactly `G`
  have hset : {n : ℕ | n ∉ AddSubmonoid.closure ({p, q} : Set ℕ)} = ↑G := by
    apply Set.Subset.antisymm
    · intro n hn
      have hle : n ≤ F := gaps_subset cop hp hq hn
      simp only [hG, Finset.coe_filter, Set.mem_setOf_eq, Finset.mem_range]
      exact ⟨by omega, hn⟩
    · intro n hn
      simp only [hG, Finset.coe_filter, Set.mem_setOf_eq, Finset.mem_range] at hn
      exact hn.2
  rw [hset, Set.ncard_coe_finset]
  -- `G` and `H` partition `range (F+1)` and are equinumerous via `n ↦ F - n`
  have hpart : G.card + H.card = F + 1 := by
    have := Finset.card_filter_add_card_filter_not (s := Finset.range (F + 1))
      (p := fun n => n ∉ AddSubmonoid.closure ({p, q} : Set ℕ))
    simp only [not_not] at this
    rw [hG, hH]
    simpa using this
  have hbij : G.card = H.card := by
    refine Finset.card_bij' (fun n _ => F - n) (fun n _ => F - n) ?_ ?_ ?_ ?_
    · intro n hn
      simp only [hG, Finset.mem_filter, Finset.mem_range] at hn
      obtain ⟨hlt, hnot⟩ := hn
      simp only [hH, Finset.mem_filter, Finset.mem_range]
      exact ⟨by omega, (frobenius_symmetry cop hp hq (by omega)).1 hnot⟩
    · intro n hn
      simp only [hH, Finset.mem_filter, Finset.mem_range] at hn
      obtain ⟨hlt, hmemn⟩ := hn
      simp only [hG, Finset.mem_filter, Finset.mem_range]
      refine ⟨by omega, ?_⟩
      intro hmem
      have hsym := (frobenius_symmetry cop hp hq (n := F - n) (by omega))
      have hff : F - (F - n) = n := by omega
      rw [hff] at hsym
      exact (hsym.2 hmemn) hmem
    · intro n hn
      simp only [hG, Finset.mem_filter, Finset.mem_range] at hn
      obtain ⟨hlt, -⟩ := hn
      show F - (F - n) = n
      omega
    · intro n hn
      simp only [hH, Finset.mem_filter, Finset.mem_range] at hn
      obtain ⟨hlt, -⟩ := hn
      show F - (F - n) = n
      omega
  -- arithmetic: `F + 1 = (p-1)*(q-1)`
  have harith : F + 1 = (p - 1) * (q - 1) := by
    obtain ⟨a, rfl⟩ : ∃ a, p = a + 2 := ⟨p - 2, by omega⟩
    obtain ⟨c, rfl⟩ : ∃ c, q = c + 2 := ⟨q - 2, by omega⟩
    have h1 : (a + 2) * (c + 2) = a * c + 2 * a + 2 * c + 4 := by ring
    have h2 : (a + 2 - 1) * (c + 2 - 1) = a * c + a + c + 1 := by
      have : a + 2 - 1 = a + 1 := by omega
      rw [this]
      have : c + 2 - 1 = c + 1 := by omega
      rw [this]
      ring
    rw [hF, h1, h2]
    omega
  omega

/-- The `⟨2,3⟩` machine has exactly one unrealisable length (namely `1`). -/
theorem gap_ncard_two_three :
    {n : ℕ | n ∉ degreeMonoid (chainRel ({2, 3} : Set ℕ)) 0}.ncard = 1 := by
  have h := sylvester_gap_ncard (p := 2) (q := 3) (by decide) (by norm_num) (by norm_num)
  simpa using h

/-- The `⟨3,5⟩` machine has exactly four unrealisable lengths (`1, 2, 4, 7`). -/
theorem gap_ncard_three_five :
    {n : ℕ | n ∉ degreeMonoid (chainRel ({3, 5} : Set ℕ)) 0}.ncard = 4 := by
  have h := sylvester_gap_ncard (p := 3) (q := 5) (by decide) (by norm_num) (by norm_num)
  simpa using h

end Sylvester

end DegreeMonoid
end Computation