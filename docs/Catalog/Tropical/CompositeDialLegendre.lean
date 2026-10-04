import Mathlib
import Tropical.CompositeDialEmergence

/-!
# COMPOSITE-DIAL at the semiprime level: the Jacobi label is emergent

This file is the arithmetic half of **COMPOSITE-DIAL** (FACT round-35 #4, paper 125,
verdict *THE-WHOLE-EXCEEDS-THE-SUM*).  It instantiates the abstract emergence theory of
`Tropical.CompositeDialEmergence` on the multiplicative group of a squarefree modulus
`N = P₀ P₁ ⋯ P_{k-1}` (odd primes), presented through the Chinese remainder theorem as the
product `∏ᵢ (ZMod Pᵢ)ˣ`.

* The *irreducible components* are the residues `a mod Pᵢ`.
* The *composite label* is the Jacobi parity
  `jacobiLabel ω = ∑ᵢ legendreBit (ω i) ∈ ZMod 2`, the additive form of the Jacobi
  symbol `J(a | N) = ∏ᵢ (a | Pᵢ)` (see `jacobiSym_prod_eq_one_iff`).

## Main results

* `legendreBit_mul_nonsquare` — multiplying by a quadratic nonresidue flips the
  Legendre bit (odd primes).
* `proper_statistic_blind` — **any** statistic computed from the residues modulo a
  *proper* subset of the primes carries exactly zero information about the Jacobi label
  of a uniformly random unit.  In particular (`residuesOn_blind`) even the *complete*
  residue modulo every prime but one is blind.
* `full_residue_one_bit` — the full residue vector carries exactly `log 2` nats, i.e.
  `1` bit, about the Jacobi label; the Legendre-bit vector alone already does
  (`legendre_bits_one_bit`).
* `semiprime_whole_exceeds_sum` — for a semiprime modulus `p q` the two prime components
  carry `0 + 0` bits while the whole carries `1` bit; `three_prime_pairs_blind` shows that
  for `pqr` even every *pair* of components is blind.
* `jacobiSym_prod_eq_one_iff` — the bridge to Mathlib's `jacobiSym`:
  `J(a | ∏ Pᵢ) = 1` iff the Legendre bits of `a` sum to `0` in `ZMod 2`
  (for `a` prime to every `Pᵢ`).
-/

namespace CompositeDial
namespace Legendre

open Finset OrbitDialCap.Info

/-- The Legendre bit of a unit: `0` for a quadratic residue, `1` for a nonresidue. -/
noncomputable def legendreBit {p : ℕ} (a : (ZMod p)ˣ) : ZMod 2 :=
  open Classical in if IsSquare (a : ZMod p) then 0 else 1

lemma zmod2_add_one_eq_iff (x b b' : ZMod 2) (h : b ≠ b') : x + 1 = b' ↔ x = b := by
  revert x b b'; decide

/-- Multiplying by a quadratic nonresidue flips the Legendre bit. -/
lemma legendreBit_mul_nonsquare {p : ℕ} [Fact p.Prime] (hp : p ≠ 2) {u : (ZMod p)ˣ}
    (hu : ¬ IsSquare (u : ZMod p)) (a : (ZMod p)ˣ) :
    legendreBit (u * a) = legendreBit a + 1 := by
  classical
  have hchar : ringChar (ZMod p) ≠ 2 := by rwa [ZMod.ringChar_zmod_n]
  have hu' : quadraticChar (ZMod p) (u : ZMod p) = -1 :=
    quadraticChar_neg_one_iff_not_isSquare.mpr hu
  have hmul : quadraticChar (ZMod p) ((u * a : (ZMod p)ˣ) : ZMod p) =
      - quadraticChar (ZMod p) (a : ZMod p) := by
    rw [Units.val_mul, map_mul, hu', neg_one_mul]
  have hua0 : ((u * a : (ZMod p)ˣ) : ZMod p) ≠ 0 := Units.ne_zero _
  have ha0 : (a : ZMod p) ≠ 0 := Units.ne_zero _
  unfold legendreBit
  by_cases ha : IsSquare (a : ZMod p)
  · have h1 : quadraticChar (ZMod p) (a : ZMod p) = 1 :=
      (quadraticChar_one_iff_isSquare ha0).mpr ha
    have : ¬ IsSquare ((u * a : (ZMod p)ˣ) : ZMod p) := by
      rw [← quadraticChar_neg_one_iff_not_isSquare, hmul, h1]
    rw [if_pos ha, if_neg this]; simp
  · have h1 : quadraticChar (ZMod p) (a : ZMod p) = -1 :=
      quadraticChar_neg_one_iff_not_isSquare.mpr ha
    have : IsSquare ((u * a : (ZMod p)ˣ) : ZMod p) := by
      rw [← quadraticChar_one_iff_isSquare hua0, hmul, h1, neg_neg]
    simp only [this, ha, if_true, if_false]
    decide

/-- Every odd prime has a quadratic nonresidue unit. -/
lemma exists_nonsquare_unit {p : ℕ} [Fact p.Prime] (hp : p ≠ 2) :
    ∃ u : (ZMod p)ˣ, ¬ IsSquare (u : ZMod p) := by
  obtain ⟨x, hx⟩ := FiniteField.exists_nonsquare (F := ZMod p) (by rwa [ZMod.ringChar_zmod_n])
  have hx0 : x ≠ 0 := by rintro rfl; exact hx ⟨0, by simp⟩
  exact ⟨Units.mk0 x hx0, by simpa using hx⟩

variable {k : ℕ} (P : Fin k → ℕ) [∀ i, Fact (P i).Prime]

/-- The CRT model of `(ZMod N)ˣ` for `N = ∏ Pᵢ`: a unit is its vector of prime residues. -/
abbrev ResidueSpace := (i : Fin k) → (ZMod (P i))ˣ

/-- The composite label: the Jacobi parity `∑ᵢ legendreBit (a mod Pᵢ)`. -/
noncomputable def jacobiLabel (ω : ResidueSpace P) : ZMod 2 := ∑ i, legendreBit (ω i)

/-- The uniform law on units. -/
noncomputable def residueLaw : ResidueSpace P → ℝ :=
  fun _ => 1 / (Fintype.card (ResidueSpace P) : ℝ)

/-- The residues of a unit modulo the primes indexed by `S`. -/
def residuesOn (S : Finset (Fin k)) (ω : ResidueSpace P) : (i : S) → (ZMod (P i))ˣ :=
  fun i => ω i

lemma residueLaw_total : ∑ ω, residueLaw P ω = 1 := by
  have : (Fintype.card (ResidueSpace P) : ℝ) ≠ 0 := by exact_mod_cast Fintype.card_ne_zero
  simp only [residueLaw, Finset.sum_const, Finset.card_univ, nsmul_eq_mul]
  field_simp

/-- Flipping coordinate `j` by a nonresidue flips the Jacobi label. -/
lemma jacobiLabel_flip (hodd : ∀ i, P i ≠ 2) (j : Fin k) {u : (ZMod (P j))ˣ}
    (hu : ¬ IsSquare (u : ZMod (P j))) (ω : ResidueSpace P) :
    jacobiLabel P ((Pi.mulSingle j u : ResidueSpace P) * ω) = jacobiLabel P ω + 1 := by
  classical
  have hpt : ∀ i, legendreBit (((Pi.mulSingle j u : ResidueSpace P) * ω) i) =
      legendreBit (ω i) + (Pi.single j 1 : Fin k → ZMod 2) i := by
    intro i
    by_cases h : i = j
    · subst h
      simp [legendreBit_mul_nonsquare (hodd i) hu]
    · simp [Pi.mulSingle_eq_of_ne h, Pi.single_eq_of_ne h]
  unfold jacobiLabel
  rw [Finset.sum_congr rfl fun i _ => hpt i, Finset.sum_add_distrib]
  simp

/-- The label-swap family needed by the abstract criteria, flipping coordinate `j`. -/
lemma label_swap (hodd : ∀ i, P i ≠ 2) (j : Fin k) (b b' : ZMod 2) :
    ∃ τ : ResidueSpace P ≃ ResidueSpace P, (∀ ω, residueLaw P (τ ω) = residueLaw P ω) ∧
      (∀ ω, ∀ i, i ≠ j → τ ω i = ω i) ∧
      (∀ ω, jacobiLabel P (τ ω) = b' ↔ jacobiLabel P ω = b) := by
  classical
  by_cases hb : b = b'
  · subst hb; exact ⟨Equiv.refl _, fun _ => rfl, fun _ _ _ => rfl, fun _ => Iff.rfl⟩
  · obtain ⟨u, hu⟩ := exists_nonsquare_unit (hodd j)
    refine ⟨Equiv.mulLeft (Pi.mulSingle j u : ResidueSpace P), fun _ => rfl, fun ω i hi => ?_, fun ω => ?_⟩
    · simp [Pi.mulSingle_eq_of_ne hi]
    · simp only [Equiv.coe_mulLeft]
      rw [jacobiLabel_flip P hodd j hu]
      exact zmod2_add_one_eq_iff _ _ _ hb

/-- **Proper statistics are blind.**  Any observable `X` that only depends on the residues
modulo the primes in a proper subset `S` carries exactly zero information about the Jacobi
label of a uniformly random unit. -/
theorem proper_statistic_blind (hodd : ∀ i, P i ≠ 2) {α : Type*} [Fintype α]
    (S : Finset (Fin k)) (hS : S ≠ Finset.univ) (X : ResidueSpace P → α)
    (hX : ∀ ω ω', (∀ i ∈ S, ω i = ω' i) → X ω = X ω') :
    info (residueLaw P) X (jacobiLabel P) = 0 := by
  obtain ⟨j, hj⟩ : ∃ j, j ∉ S := by
    by_contra h; push_neg at h; exact hS (Finset.eq_univ_iff_forall.mpr h)
  refine info_eq_zero_of_swap (residueLaw_total P) fun b b' => ?_
  obtain ⟨τ, h1, h2, h3⟩ := label_swap P hodd j b b'
  exact ⟨τ, h1, fun ω => hX _ _ fun i hi => h2 ω i fun h => hj (h ▸ hi), h3⟩

/-- The complete residues modulo all primes of a proper subset are blind to the Jacobi
label. -/
theorem residuesOn_blind (hodd : ∀ i, P i ≠ 2) (S : Finset (Fin k)) (hS : S ≠ Finset.univ) :
    info (residueLaw P) (residuesOn P S) (jacobiLabel P) = 0 :=
  proper_statistic_blind P hodd S hS _ fun ω ω' h => by
    funext i; exact h i i.2

/-- **The whole carries one bit.**  The full residue vector carries `log 2` nats about the
Jacobi label (`k ≥ 1`). -/
theorem full_residue_one_bit (hodd : ∀ i, P i ≠ 2) (hk : k ≠ 0) :
    info (residueLaw P) id (jacobiLabel P) = Real.log 2 := by
  have h := info_eq_log_card_of_determined (residueLaw_total P) (jacobiLabel P)
    (X := id) (Y := jacobiLabel P) (fun _ => rfl) fun b b' => by
      obtain ⟨τ, h1, -, h3⟩ := label_swap P hodd ⟨0, Nat.pos_of_ne_zero hk⟩ b b'
      exact ⟨τ, h1, h3⟩
  rw [h, ZMod.card]; norm_num

/-- The Legendre-bit vector alone already carries the full bit. -/
theorem legendre_bits_one_bit (hodd : ∀ i, P i ≠ 2) (hk : k ≠ 0) :
    info (residueLaw P) (fun ω i => legendreBit (ω i)) (jacobiLabel P) = Real.log 2 := by
  have h := info_eq_log_card_of_determined (residueLaw_total P)
    (fun v : Fin k → ZMod 2 => ∑ i, v i)
    (X := fun ω i => legendreBit (ω i)) (Y := jacobiLabel P) (fun _ => rfl) fun b b' => by
      obtain ⟨τ, h1, -, h3⟩ := label_swap P hodd ⟨0, Nat.pos_of_ne_zero hk⟩ b b'
      exact ⟨τ, h1, h3⟩
  rw [h, ZMod.card]; norm_num

/-- In bits: the whole residue vector carries exactly one bit. -/
theorem full_residue_bits (hodd : ∀ i, P i ≠ 2) (hk : k ≠ 0) :
    bits (info (residueLaw P) id (jacobiLabel P)) = 1 := by
  rw [full_residue_one_bit P hodd hk, bits, div_self (Real.log_pos one_lt_two).ne']

/-- A single prime component, as an observable. -/
def primeComponent (i : Fin k) (ω : ResidueSpace P) : (ZMod (P i))ˣ := ω i

/-- With at least two primes, each single prime component is blind. -/
theorem primeComponent_blind (hodd : ∀ i, P i ≠ 2) (hk : 2 ≤ k) (i : Fin k) :
    info (residueLaw P) (primeComponent P i) (jacobiLabel P) = 0 := by
  have hS : ({i} : Finset (Fin k)) ≠ Finset.univ := by
    intro h
    have : Fintype.card (Fin k) ≤ 1 := by
      rw [← Finset.card_univ, ← h, Finset.card_singleton]
    simp at this; omega
  exact proper_statistic_blind P hodd {i} hS _ fun ω ω' h => h i (Finset.mem_singleton_self i)

/-- **THE-WHOLE-EXCEEDS-THE-SUM, semiprime level.**  For a modulus with `k ≥ 2` odd prime
factors, the prime components carry `0` information in total, while the whole carries
`log 2` nats (one bit): all of the information is emergent. -/
theorem whole_exceeds_sum (hodd : ∀ i, P i ≠ 2) (hk : 2 ≤ k) :
    ∑ i, info (residueLaw P) (primeComponent P i) (jacobiLabel P) = 0 ∧
      info (residueLaw P) id (jacobiLabel P) = Real.log 2 ∧
      ∑ i, info (residueLaw P) (primeComponent P i) (jacobiLabel P) <
        info (residueLaw P) id (jacobiLabel P) := by
  have h0 : ∑ i, info (residueLaw P) (primeComponent P i) (jacobiLabel P) = 0 :=
    Finset.sum_eq_zero fun i _ => primeComponent_blind P hodd hk i
  have h1 := full_residue_one_bit P hodd (by omega)
  exact ⟨h0, h1, by rw [h0, h1]; exact Real.log_pos one_lt_two⟩

/-- The prime vector `![p, q]` of a semiprime carries the primality instances. -/
instance instFactPrimeVec2 {p q : ℕ} [hp : Fact p.Prime] [hq : Fact q.Prime] (i : Fin 2) :
    Fact ((![p, q] : Fin 2 → ℕ) i).Prime := by
  fin_cases i
  · exact hp
  · exact hq

/-- **Semiprime instance.**  For odd primes `p, q`, the residue mod `p` and the residue
mod `q` are each blind to the Jacobi label of `a mod pq`, while together they carry
exactly one bit. -/
theorem semiprime_whole_exceeds_sum (p q : ℕ) [Fact p.Prime] [Fact q.Prime] (hp : p ≠ 2)
    (hq : q ≠ 2) :
    info (residueLaw ![p, q]) (primeComponent ![p, q] 0) (jacobiLabel ![p, q]) = 0 ∧
      info (residueLaw ![p, q]) (primeComponent ![p, q] 1) (jacobiLabel ![p, q]) = 0 ∧
      bits (info (residueLaw ![p, q]) id (jacobiLabel ![p, q])) = 1 := by
  have hodd : ∀ i, (![p, q] : Fin 2 → ℕ) i ≠ 2 := by
    intro i; fin_cases i
    · exact hp
    · exact hq
  exact ⟨primeComponent_blind _ hodd le_rfl 0, primeComponent_blind _ hodd le_rfl 1,
    full_residue_bits _ hodd (by norm_num)⟩

/-- **Three irreducible components.**  For `N = p q r` every *pair* of prime components is
blind to the Jacobi label (and so is every single one), while the triple carries one bit. -/
theorem three_prime_pairs_blind (P : Fin 3 → ℕ) [∀ i, Fact (P i).Prime] (hodd : ∀ i, P i ≠ 2)
    (i j : Fin 3) :
    info (residueLaw P) (residuesOn P {i, j}) (jacobiLabel P) = 0 ∧
      bits (info (residueLaw P) id (jacobiLabel P)) = 1 := by
  refine ⟨residuesOn_blind P hodd _ fun h => ?_, full_residue_bits P hodd (by norm_num)⟩
  have : (Finset.univ : Finset (Fin 3)).card ≤ 2 := by
    rw [← h]; exact Finset.card_le_two
  simp at this

/-! ### Bridge to Mathlib's Jacobi symbol -/

/-- The Legendre bit of an integer modulo `p`. -/
noncomputable def intBit (p : ℕ) (a : ℤ) : ZMod 2 :=
  open Classical in if IsSquare (a : ZMod p) then 0 else 1

/-- The Legendre symbol of an integer prime to `p` is the sign of its bit. -/
lemma legendreSym_eq_sign {p : ℕ} [Fact p.Prime] {a : ℤ} (ha : (a : ZMod p) ≠ 0) :
    legendreSym p a = if intBit p a = 0 then 1 else -1 := by
  classical
  unfold intBit
  by_cases h : IsSquare (a : ZMod p)
  · simp [h, (legendreSym.eq_one_iff p ha).mpr h]
  · simp [h, (legendreSym.eq_neg_one_iff p).mpr h]

/-- The Jacobi symbol modulo a product of primes is the product of Legendre symbols. -/
theorem jacobiSym_prod (a : ℤ) : ∀ {k : ℕ} (P : Fin k → ℕ) [∀ i, Fact (P i).Prime],
    jacobiSym a (∏ i, P i) = ∏ i, legendreSym (P i) a
  | 0, P, _ => by simp [jacobiSym.one_right]
  | k + 1, P, _ => by
    have h0 : P 0 ≠ 0 := (Fact.out : (P 0).Prime).ne_zero
    have h1 : ∏ i : Fin k, P i.succ ≠ 0 :=
      Finset.prod_ne_zero_iff.mpr fun i _ => (Fact.out : (P i.succ).Prime).ne_zero
    rw [Fin.prod_univ_succ, Fin.prod_univ_succ, jacobiSym.mul_right' a h0 h1,
      ← jacobiSym.legendreSym.to_jacobiSym, jacobiSym_prod a (fun i => P i.succ)]

lemma prod_sign_eq {ι : Type*} (s : Finset ι) (g : ι → ZMod 2) :
    ∏ i ∈ s, (if g i = 0 then (1 : ℤ) else -1) = if ∑ i ∈ s, g i = 0 then 1 else -1 := by
  classical
  induction s using Finset.induction_on with
  | empty => simp
  | insert x s hx ih =>
    rw [Finset.prod_insert hx, Finset.sum_insert hx, ih]
    generalize g x = c
    generalize ∑ i ∈ s, g i = d
    revert c d; decide

/-- **Bridge.**  For an integer `a` prime to each `Pᵢ`, `J(a | ∏ Pᵢ) = 1` iff the Legendre
bits of `a` sum to `0` in `ZMod 2`: the composite label of this file is the Jacobi symbol
in additive notation. -/
theorem jacobiSym_prod_eq_one_iff (a : ℤ) (ha : ∀ i, (a : ZMod (P i)) ≠ 0) :
    jacobiSym a (∏ i, P i) = 1 ↔ ∑ i, intBit (P i) a = 0 := by
  rw [jacobiSym_prod, Finset.prod_congr rfl fun i _ => legendreSym_eq_sign (ha i),
    prod_sign_eq]
  split_ifs with h <;> simp [h]

end Legendre
end CompositeDial