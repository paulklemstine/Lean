/-
# Cycle 2: counting the higher-power channel, and the hybrid no-amplification bound

Second research cycle on `39_PowerResidue_Circularity.md` (KPOWER, #374).
Cycle 1 (`Combinatorics.PowerResidueCriterion`,
`Combinatorics.PowerResidueCircularity`) showed:

* the cubic/quartic residuacity bit *escapes* every residue dial of conductor
  dividing `720720`, while the quadratic bit is a conductor-`8` dial;
* nevertheless a `K`-symbol residuacity fingerprint has capacity `2 ^ K`,
  independently of the exponent `k`.

This file closes the quantitative gap left open there.  Two new ingredients:

* **Sparsity of higher powers** (`PowerResidueCount.card_powerResidue_units`):
  for `p` prime and `k ∣ p - 1`, exactly `(p-1)/k` of the `p-1` invertible
  residues are `k`-th powers.  Hence the cubic bit is *biased*: it says "yes" on
  a third of the bases, versus a half for the quadratic bit
  (`PowerResidueCount.cubic_sparser_than_quadratic`).  A biased bit carries
  *less* than one bit; raising `k` strictly degrades the per-symbol information,
  which is the mechanism behind the experiment's "identical leakage rate".
* **Hybrid no-amplification** (`PowerResidueCount.hybrid_no_amplification`): a
  Coppersmith-style hint `p ≡ r (mod m)`, a system of `L` Kronecker dials and
  `K` higher-power residuacity bits, all used *together*, still leave a class of
  at least `|Ω| / (M*/gcd(M*,m) · 2^K)` indistinguishable candidates, where `M*`
  is the dial conductor lcm of `Combinatorics.DialThresholdNoAmplification`.
  The higher-power channel enters only through the factor `2^K`: exactly what a
  `K`-bit read-out of *any* channel would contribute, so the escape from
  periodicity buys no amplification.

The bridge is deliberately cross-file: group theory (cyclic power maps) supplies
the counting, finite combinatorics (fiberwise pigeonhole) supplies the bound, and
the catalog's dial calculus supplies the quadratic side.
-/
import Mathlib
import Combinatorics.PowerResidueCriterion
import Combinatorics.DialThresholdNoAmplification

namespace PowerResidueCount

open Finset PowerResidue

/-! ## 1. Exactly `(p-1)/k` of the residues are `k`-th powers -/

/-- **Sparsity of `k`-th powers.**  In `(ZMod p)ˣ` with `p` prime and
`k ∣ p - 1`, precisely `(p-1)/k` of the `p-1` units are `k`-th powers.  For
`k = 2` this is the classical "half the residues are squares"; for `k = 3` only
a third are cubes. -/
theorem card_powerResidue_units {p k : ℕ} [Fact p.Prime] (hk : k ∣ p - 1) :
    #{a : (ZMod p)ˣ | ∃ b : (ZMod p)ˣ, b ^ k = a} = (p - 1) / k := by
  classical
  have hcard : Nat.card (ZMod p)ˣ = p - 1 := by
    rw [Nat.card_eq_fintype_card]; exact ZMod.card_units p
  have h := IsCyclic.card_powMonoidHom_range (G := (ZMod p)ˣ) k
  rw [hcard, Nat.gcd_eq_right hk] at h
  have hfin : #{a : (ZMod p)ˣ | ∃ b : (ZMod p)ˣ, b ^ k = a}
      = Nat.card ((powMonoidHom k : (ZMod p)ˣ →* (ZMod p)ˣ).range) := by
    rw [Nat.card_eq_fintype_card, Fintype.card_subtype]
    apply Finset.card_bij (fun a _ => a) (fun a ha => ?_) (fun a _ b _ h => h) (fun a ha => ?_)
    · simp only [Finset.mem_filter, Finset.mem_univ, true_and] at ha ⊢
      obtain ⟨b, hb⟩ := ha
      exact ⟨b, hb⟩
    · refine ⟨a, ?_, rfl⟩
      simp only [Finset.mem_filter, Finset.mem_univ, true_and] at ha ⊢
      obtain ⟨b, hb⟩ := ha
      exact ⟨b, hb⟩
  rw [hfin, h]

/-- **The cubic bit is strictly sparser than the quadratic bit.**  For a prime
`p ≡ 1 (mod 6)` the cubes among the units number `(p-1)/3`, the squares
`(p-1)/2`, and the former is strictly smaller.  A cubic residuacity bit is
therefore a *biased* bit: it carries strictly less than the quadratic one. -/
theorem cubic_sparser_than_quadratic {p : ℕ} [Fact p.Prime] (hp : 6 ∣ p - 1) (hp1 : 1 < p) :
    #{a : (ZMod p)ˣ | ∃ b : (ZMod p)ˣ, b ^ 3 = a}
      < #{a : (ZMod p)ˣ | ∃ b : (ZMod p)ˣ, b ^ 2 = a} := by
  obtain ⟨d, hd⟩ := hp
  have hd0 : 0 < d := by omega
  rw [card_powerResidue_units (p := p) (k := 3) ⟨2 * d, by omega⟩,
      card_powerResidue_units (p := p) (k := 2) ⟨3 * d, by omega⟩]
  omega

/-! ## 2. A fiberwise pigeonhole -/

/-- **Large fibre.**  Any statistic has a reading whose fibre is at least a
`1/(number of readings)` fraction of the candidate set. -/
theorem exists_large_fibre {α β : Type*} [DecidableEq α] [DecidableEq β] (S : Finset α)
    (f : α → β) (hS : S.Nonempty) :
    ∃ v ∈ S.image f, S.card ≤ #{a ∈ S | f a = v} * (S.image f).card := by
  obtain ⟨v, hv, hmax⟩ :=
    Finset.exists_max_image (S.image f) (fun v => #{a ∈ S | f a = v}) (hS.image f)
  refine ⟨v, hv, ?_⟩
  calc S.card = ∑ w ∈ S.image f, #{a ∈ S | f a = w} :=
        Finset.card_eq_sum_card_fiberwise (fun a ha => mem_image_of_mem f ha)
    _ ≤ (S.image f).card * #{a ∈ S | f a = v} := by
        simpa using Finset.sum_le_card_nsmul (S.image f) _ _ (fun w hw => hmax w hw)
    _ = #{a ∈ S | f a = v} * (S.image f).card := Nat.mul_comm _ _

/-! ## 3. The hybrid bound: dials + higher-power bits + a hint -/

open scoped Classical in
/-- **Hybrid no-amplification.**  Take a candidate set `Ω` inside one hint class
`p ≡ r (mod m)`, a system of `L` residue dials with conductor lcm `M*`, and `K`
`k`-th power residuacity bits at arbitrary bases.  Then some *joint* reading is
shared by at least a
`1 / ((M*/gcd(M*,m)) · 2^K)` fraction of the candidates.

The quadratic (dial) side contributes its DIAL-THRESHOLD budget
`M*/gcd(M*,m)`; the higher-power side contributes at most `2^K`, the capacity of
`K` bits — the same factor a `K`-bit read-out of the *quadratic* channel would
contribute.  Escaping periodicity (`PowerResidueEscape.cubic_two_not_dial`)
therefore does not amplify: it only relabels which bits you read. -/
theorem hybrid_no_amplification {K L : ℕ} (Ds : Fin L → DialThreshold.Dial) (k : ℕ)
    (bases : Fin K → ℕ) (Ω : Finset ℕ) (hΩ : Ω.Nonempty) {m r : ℕ} (hm : 0 < m)
    (hclass : ∀ p ∈ Ω, p % m = r % m) :
    ∃ (v : Fin L → ℤ) (w : Fin K → Bool),
      Ω.card ≤ #{p ∈ Ω | DialThreshold.dialVec Ds p = v ∧ resVec k bases p = w} *
        ((DialThreshold.condLcm Ds / Nat.gcd (DialThreshold.condLcm Ds) m) * 2 ^ K) := by
  classical
  set F : ℕ → (Fin L → ℤ) × (Fin K → Bool) :=
    fun p => (DialThreshold.dialVec Ds p, resVec k bases p) with hF
  obtain ⟨⟨v, w⟩, -, hfib⟩ := exists_large_fibre Ω F hΩ
  refine ⟨v, w, ?_⟩
  have himg : Ω.image F ⊆ (Ω.image (DialThreshold.dialVec Ds)) ×ˢ (Ω.image (resVec k bases)) := by
    intro z hz
    simp only [mem_image] at hz
    obtain ⟨p, hp, rfl⟩ := hz
    exact Finset.mem_product.mpr ⟨mem_image_of_mem _ hp, mem_image_of_mem _ hp⟩
  have hcard : (Ω.image F).card ≤
      (DialThreshold.condLcm Ds / Nat.gcd (DialThreshold.condLcm Ds) m) * 2 ^ K := by
    calc (Ω.image F).card
        ≤ ((Ω.image (DialThreshold.dialVec Ds)) ×ˢ (Ω.image (resVec k bases))).card :=
          Finset.card_le_card himg
      _ = (Ω.image (DialThreshold.dialVec Ds)).card * (Ω.image (resVec k bases)).card :=
          Finset.card_product _ _
      _ ≤ (DialThreshold.condLcm Ds / Nat.gcd (DialThreshold.condLcm Ds) m) * 2 ^ K :=
          Nat.mul_le_mul (DialThreshold.card_image_dialVec_le Ds Ω hm hclass)
            (card_image_resVec_le k bases Ω)
  have hfilter : #{p ∈ Ω | F p = (v, w)}
      = #{p ∈ Ω | DialThreshold.dialVec Ds p = v ∧ resVec k bases p = w} := by
    congr 1
    apply Finset.filter_congr
    intro p _
    simp [hF, Prod.ext_iff]
  rw [hfilter] at hfib
  exact hfib.trans (Nat.mul_le_mul_left _ hcard)

/-! ## 4. Leakage saturation, stated as a collision -/

open scoped Classical in
/-- **Saturation.**  Once the candidate set exceeds `2 ^ K`, a `K`-symbol
residuacity fingerprint must collide — for every exponent `k`.  This is the
formal version of the experiment's observation that the cubic fingerprint
separates at exactly the quadratic rate: the rate is a property of the number of
*bits read*, not of the reciprocity law they come from. -/
theorem exists_fingerprint_collision {K k : ℕ} (bases : Fin K → ℕ) (S : Finset ℕ)
    (hS : 2 ^ K < S.card) :
    ∃ p ∈ S, ∃ q ∈ S, p ≠ q ∧ resVec k bases p = resVec k bases q := by
  classical
  by_contra hcon
  push_neg at hcon
  have hinj : Set.InjOn (resVec k bases) S := by
    intro p hp q hq hpq
    by_contra hne
    exact hne (hcon p hp q hq hne hpq).elim
  exact absurd (card_le_two_pow_of_injOn hinj) (by omega)

end PowerResidueCount