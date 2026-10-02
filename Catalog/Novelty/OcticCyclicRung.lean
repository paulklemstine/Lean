/-
# THE OCTIC CYCLIC RUNG: full pinning at degree 8, and the ladder at every degree

FACT round-35 #3 (paper 124) reports, for the octic cyclic field `Q(ζ₁₇)⁺`
(Galois group `C₈`, conductor `17`):  `H(T) = 1.7474` bits, `I(p mod 17 ; T) = H(T)`,
the four types `{1 : 12%, 2 : 12%, 4 : 25%, 8 : 50%}`.  The catalog's prime-degree
ladder (`Shared.AbelianLadderUniversality.realCyclotomic_prime_degree`) needs the
real degree `(f-1)/2` to be *prime*, so degree 8 is not an instance of it.  This
file removes that restriction altogether.

Main results.

* `uEnt_comp_of_uniform` — counting entropy is invariant under uniform covers
  (all fibres of the same size); the engine behind everything else.
* `realDeg_pow_of_generator` — for every odd prime `f` and generator `g` of
  `(Z/f)ˣ`, the residue degree of `g^a` in `Q(ζ_f)⁺` is `ordType ((f-1)/2) a`.
* `uEnt_realDeg_eq_typeEntropy` — **the real-cyclotomic ladder at every degree**:
  `H(T) = typeEntropy ((f-1)/2)` for *every* odd prime `f`, prime degree or not.
* `card_realDeg_eq` — exactly `2 φ(d)` classes mod `f` have residue degree `d`.
* `typeEntropy_two_pow` — the two-power ladder `H(T_{2^m}) = 2 - 2^{1-m}`.
* `fermat_rung_entropy` — Fermat rungs `f = 2^{m+1}+1`: `H(T) = 2 - 2^{1-m}`.
* `octic_type_census`, `octic_entropy` (`= 7/4`), `full_pinning_deg8`,
  `full_pinning_deg8_residue`, `octic_reported_value` — the degree-8 rung.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the octic rung is not special — the arithmetic type of
`Q(ζ_f)⁺` is the pushforward of the abstract `C_{(f-1)/2}` type along the
discrete logarithm followed by the two-to-one sign quotient, so `H(T)` should be
`typeEntropy ((f-1)/2)` at *every* degree.  For `f = 17` the exact value should be
`7/4`, and the reported `1.7474` a finite-sample estimate of it.

Experiment (Experimenter): proved `uEnt_comp_of_uniform` (fibre-size scaling
`log(c N) - (1/cN)·c·∑ log(c m) = log N - (1/N)∑ log m`) and applied it twice:
`c = 1` along `a ↦ g^a` on `[0, f-1)`, then `c = 2` along `a ↦ a mod (f-1)/2`.
The census `{2, 2, 4, 8}` follows from `card_ordType_eq_totient` by the same two
covers.  The closed form `2 - 2^{1-m}` follows from the catalog's `φ`-law
`typeEntropy_formula` and `∑_{k<m} 2^k (m-k) = 2^{m+1} - m - 2`.

Analysis (Analyst): "true and structural".  The value `7/4` is exact;
`1.7474 < 7/4` with gap `< 0.003` (`octic_reported_value`) is the expected
downward bias of a plug-in entropy estimate.  The rounded densities `12%` are
`1/8 = 12.5%` exactly.

Critique (Critic): no `native_decide`; the only `decide` calls are totient values
`φ(1), φ(2), φ(4), φ(8)`.  Pinning is guarded: it holds because the observable
determines the type (`condEnt_eq_zero_of_determines`); the companion file
`Novelty.OcticTowerInformation` exhibits observables (the Legendre symbol) that
do *not* pin.
-- !-- Lab Notes -- !--
-/
import Shared.AbelianLadderUniversality

namespace OcticCyclic

open Finset CyclicTypeChannel AbelianLadder

/-! ## 1. Entropy is invariant under uniform covers -/

section Uniform

variable {α β γ : Type*} [DecidableEq β] [DecidableEq γ]

/-- Counting through a cover all of whose fibres have size `c`. -/
theorem card_filter_comp_of_uniform {s : Finset α} {t : Finset β} {φ : α → β} {c : ℕ}
    (hmaps : ∀ a ∈ s, φ a ∈ t) (hfib : ∀ b ∈ t, #{a ∈ s | φ a = b} = c)
    (P : β → Prop) [DecidablePred P] :
    #{a ∈ s | P (φ a)} = c * #{b ∈ t | P b} := by
  have hmaps' : Set.MapsTo φ ↑({a ∈ s | P (φ a)}) ↑t := by
    intro a ha
    exact hmaps a (mem_filter.1 ha).1
  rw [card_eq_sum_card_fiberwise hmaps', card_filter, mul_sum]
  refine sum_congr rfl fun b hb => ?_
  by_cases hP : P b
  · rw [if_pos hP, mul_one, ← hfib b hb]
    congr 1
    ext a
    simp only [mem_filter]
    constructor
    · rintro ⟨⟨ha, _⟩, h⟩; exact ⟨ha, h⟩
    · rintro ⟨ha, h⟩; exact ⟨⟨ha, h ▸ hP⟩, h⟩
  · rw [if_neg hP, mul_zero, card_eq_zero]
    ext a
    simp only [mem_filter, Finset.notMem_empty, iff_false, not_and]
    rintro ⟨_, h1⟩ h2
    exact hP (h2 ▸ h1)

/-- The total size of a uniform cover. -/
theorem card_of_uniform {s : Finset α} {t : Finset β} {φ : α → β} {c : ℕ}
    (hmaps : ∀ a ∈ s, φ a ∈ t) (hfib : ∀ b ∈ t, #{a ∈ s | φ a = b} = c) :
    s.card = c * t.card := by
  have h := card_filter_comp_of_uniform hmaps hfib (fun _ => True)
  simpa using h

/-- **Entropy is invariant under uniform covers.**  If every fibre of
`φ : s → t` has the same size `c > 0`, then pulling a read-out `h` back along `φ`
does not change its counting entropy.  (Both a bijection, `c = 1`, and the
two-to-one sign cover `(Z/f)ˣ → (Z/f)ˣ/{±1}`, `c = 2`, are instances.) -/
theorem uEnt_comp_of_uniform {s : Finset α} {t : Finset β} {φ : α → β} {c : ℕ}
    (hc : 0 < c) (hmaps : ∀ a ∈ s, φ a ∈ t) (hfib : ∀ b ∈ t, #{a ∈ s | φ a = b} = c)
    (h : β → γ) : uEnt s (h ∘ φ) = uEnt t h := by
  have hcard := card_of_uniform hmaps hfib
  -- fibre sizes multiply by `c`
  have hfibre : ∀ a ∈ s, #{x ∈ s | (h ∘ φ) x = (h ∘ φ) a} = c * #{y ∈ t | h y = h (φ a)} :=
    fun a _ => card_filter_comp_of_uniform hmaps hfib (fun y => h y = h (φ a))
  have hsum : (∑ a ∈ s, Real.logb 2 (#{x ∈ s | (h ∘ φ) x = (h ∘ φ) a} : ℝ))
      = ∑ b ∈ t, (c : ℝ) * Real.logb 2 ((c : ℝ) * #{y ∈ t | h y = h b}) := by
    rw [sum_congr rfl fun a ha => by rw [hfibre a ha]]
    rw [← sum_fiberwise_of_maps_to hmaps]
    refine sum_congr rfl fun b hb => ?_
    rw [sum_congr rfl fun a ha => by rw [(mem_filter.1 ha).2], sum_const, hfib b hb,
      nsmul_eq_mul]
    push_cast
    ring
  rcases t.eq_empty_or_nonempty with rfl | ht
  · have : s = ∅ := by
      rw [← card_eq_zero, hcard]; simp
    subst this
    simp [uEnt]
  have hc0 : (0 : ℝ) < c := by exact_mod_cast hc
  have ht0 : (0 : ℝ) < t.card := by exact_mod_cast ht.card_pos
  have hsum2 : ∑ b ∈ t, (c : ℝ) * Real.logb 2 ((c : ℝ) * #{y ∈ t | h y = h b})
      = (c : ℝ) * (t.card * Real.logb 2 c + ∑ b ∈ t, Real.logb 2 (#{y ∈ t | h y = h b} : ℝ)) := by
    rw [← mul_sum]
    congr 1
    rw [sum_congr rfl fun b hb => Real.logb_mul (ne_of_gt hc0)
      (by exact_mod_cast (fiber_card_pos (g := h) hb).ne'), sum_add_distrib, sum_const,
      nsmul_eq_mul]
  rw [uEnt, uEnt, hsum, hsum2, hcard]
  push_cast
  rw [Real.logb_mul (ne_of_gt hc0) (ne_of_gt ht0)]
  field_simp
  ring

end Uniform

/-! ## 2. The real-cyclotomic type at every degree -/

section RealCyclotomic

variable {f : ℕ} [hf : Fact f.Prime]

/-- The Galois group `(Z/f)ˣ/{±1}` of `Q(ζ_f)⁺` has order `(f-1)/2`. -/
theorem card_quot_eq_half (hf2 : 2 < f) :
    Nat.card ((ZMod f)ˣ ⧸ signSub f) = (f - 1) / 2 := by
  have := card_quot_signSub hf.out hf2
  omega

/-- **The arithmetic type is the exponent-model type, at every degree.**  If `g`
generates `(Z/f)ˣ`, the residue degree of `g ^ a` in `Q(ζ_f)⁺` is
`ordType ((f-1)/2) a`: the order of `a` in the cyclic group `C_{(f-1)/2}`. -/
theorem realDeg_pow_of_generator (hf2 : 2 < f) {g : (ZMod f)ˣ}
    (hg : ∀ u, u ∈ Subgroup.zpowers g) (a : ℕ) :
    realDeg f (g ^ a) = ordType ((f - 1) / 2) a := by
  set π := QuotientGroup.mk' (signSub f)
  have hgen : ∀ x : (ZMod f)ˣ ⧸ signSub f, x ∈ Subgroup.zpowers (π g) := by
    intro x
    obtain ⟨u, rfl⟩ := QuotientGroup.mk'_surjective (signSub f) x
    obtain ⟨k, rfl⟩ := hg u
    exact ⟨k, by simp [π]⟩
  have hord : orderOf (π g) = (f - 1) / 2 := by
    rw [orderOf_eq_card_of_forall_mem_zpowers hgen, card_quot_eq_half hf2]
  rw [realDeg, map_pow, orderOf_pow_eq_ordType, hord]

/-- A generator of `(Z/f)ˣ` has order `f - 1`. -/
theorem orderOf_generator {g : (ZMod f)ˣ} (hg : ∀ u, u ∈ Subgroup.zpowers g) :
    orderOf g = f - 1 := by
  rw [orderOf_eq_card_of_forall_mem_zpowers hg, Nat.card_eq_fintype_card,
    ZMod.card_units_eq_totient, Nat.totient_prime hf.out]

/-- The discrete-logarithm parametrisation `a ↦ g ^ a`, `a < f - 1`, is a
bijection onto `(Z/f)ˣ`: every fibre is a singleton. -/
theorem fibre_pow_generator {g : (ZMod f)ˣ} (hg : ∀ u, u ∈ Subgroup.zpowers g)
    (u : (ZMod f)ˣ) : #{a ∈ range (f - 1) | g ^ a = u} = 1 := by
  have hord := orderOf_generator hg
  have hpos : 0 < f - 1 := by have := hf.out.two_le; omega
  obtain ⟨k, rfl⟩ : ∃ k : ℕ, g ^ k = u :=
    (mem_powers_iff_mem_zpowers (x := g) (y := u)).2 (hg u)
  rw [card_eq_one]
  refine ⟨k % (f - 1), ?_⟩
  ext a
  simp only [mem_filter, mem_range, mem_singleton]
  constructor
  · rintro ⟨ha, hak⟩
    have hk' : g ^ (k % (f - 1)) = g ^ k := by rw [← hord, pow_mod_orderOf]
    have := pow_injOn_Iio_orderOf (x := g) (by simpa [hord] using ha)
      (by simpa [hord] using Nat.mod_lt k hpos) (hak.trans hk'.symm)
    exact this
  · rintro rfl
    exact ⟨Nat.mod_lt _ hpos, by rw [← hord, pow_mod_orderOf]⟩

/-- Reduction `a ↦ a mod n` from `[0, 2n)` to `[0, n)` is exactly two-to-one. -/
theorem fibre_mod_double {n b : ℕ} (hn : 0 < n) (hb : b ∈ range n) :
    #{a ∈ range (2 * n) | a % n = b} = 2 := by
  have hb' := mem_range.1 hb
  have : ({a ∈ range (2 * n) | a % n = b} : Finset ℕ) = {b, b + n} := by
    ext a
    simp only [mem_filter, mem_range, mem_insert, mem_singleton]
    constructor
    · rintro ⟨ha, rfl⟩
      rcases lt_or_ge a n with h | h
      · left; exact (Nat.mod_eq_of_lt h).symm
      · right
        have : a % n = a - n := by
          rw [Nat.mod_eq_sub_mod h, Nat.mod_eq_of_lt (by omega)]
        omega
    · rintro (rfl | rfl)
      · exact ⟨by omega, Nat.mod_eq_of_lt hb'⟩
      · exact ⟨by omega, by rw [Nat.add_mod_right, Nat.mod_eq_of_lt hb']⟩
  rw [this, card_pair (by omega)]

/-- The real-cyclotomic type, read through a generator, is the type of the
exponent modulo `(f-1)/2`. -/
theorem realDeg_comp_pow (hf2 : 2 < f) {g : (ZMod f)ˣ} (hg : ∀ u, u ∈ Subgroup.zpowers g) :
    (realDeg f ∘ fun a : ℕ => g ^ a) = ordType ((f - 1) / 2) ∘ fun a => a % ((f - 1) / 2) := by
  funext a
  simp only [Function.comp, realDeg_pow_of_generator hf2 hg, ordType_mod]

/-- The degree identity `f - 1 = 2 · ((f-1)/2)` for an odd prime. -/
theorem sub_one_eq_two_mul (hf2 : 2 < f) : f - 1 = 2 * ((f - 1) / 2) := by
  rcases hf.out.eq_two_or_odd with h | h <;> omega

/-- **THE REAL-CYCLOTOMIC LADDER AT EVERY DEGREE.**  For every odd prime `f`, the
Frobenius-type entropy of `Q(ζ_f)⁺` — computed over the `f - 1` residue classes
mod `f` — equals the entropy of the abstract cyclic type channel of order
`(f-1)/2`.  No primality of the degree is required: composite rungs such as the
octic field `Q(ζ₁₇)⁺` are covered on the same footing as the prime ones. -/
theorem uEnt_realDeg_eq_typeEntropy (hf2 : 2 < f) :
    uEnt (univ : Finset (ZMod f)ˣ) (realDeg f) = typeEntropy ((f - 1) / 2) := by
  obtain ⟨g, hg⟩ := IsCyclic.exists_generator (α := (ZMod f)ˣ)
  set n := (f - 1) / 2 with hn
  have hn0 : 0 < n := by omega
  have h1 := uEnt_comp_of_uniform (s := range (f - 1)) (t := (univ : Finset (ZMod f)ˣ))
    (φ := fun a => g ^ a) (c := 1) one_pos (fun _ _ => mem_univ _)
    (fun u _ => fibre_pow_generator hg u) (realDeg f)
  have h2 := uEnt_comp_of_uniform (s := range (2 * n)) (t := range n) (φ := fun a => a % n)
    (c := 2) two_pos (fun a _ => mem_range.2 (Nat.mod_lt a hn0))
    (fun b hb => fibre_mod_double hn0 hb) (ordType n)
  have hdeg : f - 1 = 2 * n := sub_one_eq_two_mul hf2
  rw [← h1, realDeg_comp_pow hf2 hg, ← hn, hdeg, h2, typeEntropy]

/-- **The exact type-count law in `Q(ζ_f)⁺`.**  For every divisor `d` of the real
degree `(f-1)/2`, exactly `2 φ(d)` residue classes mod `f` have residue degree
`d`. -/
theorem card_realDeg_eq (hf2 : 2 < f) {d : ℕ} (hd : d ∣ (f - 1) / 2) :
    #{u ∈ (univ : Finset (ZMod f)ˣ) | realDeg f u = d} = 2 * Nat.totient d := by
  obtain ⟨g, hg⟩ := IsCyclic.exists_generator (α := (ZMod f)ˣ)
  set n := (f - 1) / 2 with hn
  have hn0 : 0 < n := by omega
  have h1 := card_filter_comp_of_uniform (s := range (f - 1))
    (t := (univ : Finset (ZMod f)ˣ)) (φ := fun a => g ^ a) (c := 1) (fun _ _ => mem_univ _)
    (fun u _ => fibre_pow_generator hg u) (fun u => realDeg f u = d)
  have h2 := card_filter_comp_of_uniform (s := range (2 * n)) (t := range n)
    (φ := fun a => a % n) (c := 2) (fun a _ => mem_range.2 (Nat.mod_lt a hn0))
    (fun b hb => fibre_mod_double hn0 hb) (fun b => ordType n b = d)
  have hfun : ∀ a, realDeg f (g ^ a) = ordType n (a % n) := fun a =>
    congrFun (realDeg_comp_pow hf2 hg) a
  simp only [hfun, one_mul] at h1
  rw [← h1, sub_one_eq_two_mul hf2, ← hn, h2, card_ordType_eq_totient hn0 hd]

end RealCyclotomic

/-! ## 3. The two-power ladder: `H(T_{2^m}) = 2 - 2^{1-m}` -/

/-- `∑_{k<m} 2^k = 2^m - 1`. -/
theorem sum_two_pow_real (m : ℕ) : ∑ k ∈ range m, (2 : ℝ) ^ k = 2 ^ m - 1 := by
  induction m with
  | zero => simp
  | succ m ih => rw [sum_range_succ, ih, pow_succ]; ring

/-- `∑_{k<m} 2^k (m - k) = 2^{m+1} - m - 2`. -/
theorem sum_two_pow_mul_sub (m : ℕ) :
    ∑ k ∈ range m, (2 : ℝ) ^ k * ((m : ℝ) - k) = 2 ^ (m + 1) - m - 2 := by
  induction m with
  | zero => simp
  | succ m ih =>
    have hsplit : ∑ k ∈ range (m + 1), (2 : ℝ) ^ k * (((m + 1 : ℕ) : ℝ) - k)
        = ∑ k ∈ range (m + 1), (2 : ℝ) ^ k * ((m : ℝ) - k) + ∑ k ∈ range (m + 1), (2 : ℝ) ^ k := by
      rw [← sum_add_distrib]
      refine sum_congr rfl fun k _ => ?_
      push_cast; ring
    rw [hsplit, sum_range_succ, ih, sum_two_pow_real]
    push_cast
    ring

/-- **The two-power ladder.**  The Frobenius type of a cyclic field of degree
`2^m` has entropy exactly `2 - 2^{1-m}` bits: `0, 1, 3/2, 7/4, 15/8, …`.  The
octic value `7/4` is the `m = 3` rung, and the whole two-power ladder is
bounded by — and converges to — two bits. -/
theorem typeEntropy_two_pow (m : ℕ) :
    typeEntropy (2 ^ m) = 2 - 2 / (2 : ℝ) ^ m := by
  have h2 : Nat.Prime 2 := Nat.prime_two
  rw [typeEntropy_formula _ (by positivity), Nat.divisors_prime_pow h2, sum_map,
    sum_range_succ']
  simp only [Function.Embedding.coeFn_mk, pow_zero, Nat.totient_one, Nat.cast_one]
  have hterm : ∀ k ∈ range m,
      ((Nat.totient (2 ^ (k + 1)) : ℝ) / ((2 ^ m : ℕ) : ℝ)) *
          Real.logb 2 (((2 ^ m : ℕ) : ℝ) / (Nat.totient (2 ^ (k + 1)) : ℝ))
        = (2 : ℝ) ^ k * ((m : ℝ) - k) / 2 ^ m := by
    intro k _
    rw [Nat.totient_prime_pow h2 (Nat.succ_pos k)]
    simp only [show (2 : ℕ) - 1 = 1 from rfl, mul_one]
    push_cast
    rw [Real.logb_div (by positivity) (by positivity), Real.logb_pow, Real.logb_pow,
      Real.logb_self_eq_one (by norm_num)]
    ring
  rw [sum_congr rfl hterm, ← sum_div, sum_two_pow_mul_sub]
  push_cast
  rw [div_one, Real.logb_pow, Real.logb_self_eq_one (by norm_num)]
  have hpos : (0 : ℝ) < 2 ^ m := by positivity
  field_simp
  ring

/-- **Fermat rungs.**  For a prime `f = 2^{m+1} + 1` (a Fermat prime: `5, 17, 257,
65537`) the field `Q(ζ_f)⁺` is cyclic of degree `2^m` and its Frobenius-type
entropy is exactly `2 - 2^{1-m}` bits. -/
theorem fermat_rung_entropy {f m : ℕ} [Fact f.Prime] (hfm : f = 2 ^ (m + 1) + 1) :
    uEnt (univ : Finset (ZMod f)ˣ) (realDeg f) = 2 - 2 / (2 : ℝ) ^ m := by
  have hf2 : 2 < f := by
    have : 2 ≤ 2 ^ (m + 1) := by
      calc 2 = 2 ^ 1 := rfl
        _ ≤ 2 ^ (m + 1) := Nat.pow_le_pow_right (by norm_num) (by omega)
    omega
  have hdeg : (f - 1) / 2 = 2 ^ m := by
    rw [hfm, Nat.add_sub_cancel, pow_succ, Nat.mul_div_cancel _ (by norm_num)]
  rw [uEnt_realDeg_eq_typeEntropy hf2, hdeg, typeEntropy_two_pow]

/-! ## 4. Divisibility criterion for the real residue degree -/

/-- **The `±1`-criterion.**  The residue degree of `u` in `Q(ζ_f)⁺` divides `d`
exactly when `u ^ d = ±1` in `(Z/f)ˣ`. -/
theorem realDeg_dvd_iff {f d : ℕ} {u : (ZMod f)ˣ} :
    realDeg f u ∣ d ↔ u ^ d = 1 ∨ u ^ d = -1 := by
  rw [realDeg, orderOf_dvd_iff_pow_eq_one, ← map_pow, QuotientGroup.mk'_apply,
    QuotientGroup.eq_one_iff, mem_signSub]

/-! ## 5. The octic rung `Q(ζ₁₇)⁺` -/

instance fact_prime_17 : Fact (Nat.Prime 17) := ⟨by norm_num⟩

/-- `Gal(Q(ζ₁₇)⁺/Q)` has order `8`. -/
theorem card_quot_17 : Nat.card ((ZMod 17)ˣ ⧸ signSub 17) = 8 :=
  card_quot_eq_half (by norm_num)

/-- The residue degree of every prime `p ≠ 17` in `Q(ζ₁₇)⁺` divides `8`. -/
theorem realDeg_17_dvd_eight (u : (ZMod 17)ˣ) : realDeg 17 u ∣ 8 := by
  rw [realDeg, ← card_quot_17]
  exact orderOf_dvd_natCard _

/-- **Four splitting types.**  The residue degree in the octic field is one of
`1, 2, 4, 8`. -/
theorem realDeg_17_mem (u : (ZMod 17)ˣ) : realDeg 17 u ∈ ({1, 2, 4, 8} : Finset ℕ) := by
  have h := realDeg_17_dvd_eight u
  rw [show (8 : ℕ) = 2 ^ 3 from rfl, Nat.dvd_prime_pow Nat.prime_two] at h
  obtain ⟨k, hk, hk'⟩ := h
  interval_cases k <;> simp [hk']

/-- **The type census `{1 : 2, 2 : 2, 4 : 4, 8 : 8}`** over the sixteen residue
classes mod 17, i.e. densities `1/8, 1/8, 1/4, 1/2` — the `C₈` profile
`φ(d)/8`. -/
theorem octic_type_census :
    #{u ∈ (univ : Finset (ZMod 17)ˣ) | realDeg 17 u = 1} = 2 ∧
    #{u ∈ (univ : Finset (ZMod 17)ˣ) | realDeg 17 u = 2} = 2 ∧
    #{u ∈ (univ : Finset (ZMod 17)ˣ) | realDeg 17 u = 4} = 4 ∧
    #{u ∈ (univ : Finset (ZMod 17)ˣ) | realDeg 17 u = 8} = 8 := by
  have hf2 : 2 < 17 := by norm_num
  refine ⟨?_, ?_, ?_, ?_⟩
  · rw [card_realDeg_eq hf2 (by norm_num)]; decide
  · rw [card_realDeg_eq hf2 (by norm_num)]; decide
  · rw [card_realDeg_eq hf2 (by norm_num)]; decide
  · rw [card_realDeg_eq hf2 (by norm_num)]; decide

/-- **`H(T) = 7/4` bits exactly** for the Frobenius type of `Q(ζ₁₇)⁺`. -/
theorem octic_entropy : uEnt (univ : Finset (ZMod 17)ˣ) (realDeg 17) = 7 / 4 := by
  rw [fermat_rung_entropy (f := 17) (m := 3) (by norm_num)]
  norm_num

/-- The arithmetic octic channel and the abstract `C₈` channel of the catalog
coincide (`typeEntropy_val_8`). -/
theorem octic_entropy_eq_C8 :
    uEnt (univ : Finset (ZMod 17)ˣ) (realDeg 17) = typeEntropy 8 := by
  rw [octic_entropy, typeEntropy_val_8]

/-- **FULL PINNING AT DEGREE 8.**  The sign class of `p mod 17` determines the
residue degree of `p` in `Q(ζ₁₇)⁺`: the conditional entropy vanishes and the
mutual information equals `H(T) = 7/4` bits exactly. -/
theorem full_pinning_deg8 :
    condEnt (univ : Finset (ZMod 17)ˣ) (realDeg 17) (signClass 17) = 0 ∧
      mutInfo (univ : Finset (ZMod 17)ˣ) (realDeg 17) (signClass 17) = 7 / 4 := by
  have hcond : condEnt (univ : Finset (ZMod 17)ˣ) (realDeg 17) (signClass 17) = 0 := by
    refine condEnt_eq_zero_of_determines fun u _ v _ huv => ?_
    rcases signClass_eq_iff huv.symm with h | h
    · rw [h]
    · rw [h, realDeg_neg]
  exact ⟨hcond, by rw [mutInfo, hcond, sub_zero, octic_entropy]⟩

/-- The residue `p mod 17` itself (finer than the sign class) also pins the type:
`I(p mod 17 ; T) = H(T) = 7/4`. -/
theorem full_pinning_deg8_residue :
    mutInfo (univ : Finset (ZMod 17)ˣ) (realDeg 17) id = 7 / 4 := by
  have hcond : condEnt (univ : Finset (ZMod 17)ˣ) (realDeg 17) id = 0 :=
    condEnt_eq_zero_of_injOn _ (fun _ _ _ _ h => h)
  rw [mutInfo, hcond, sub_zero, octic_entropy]

/-- **The reported value is a finite-sample under-estimate.**  The experimental
`1.7474` lies strictly below the exact `7/4` and within `0.003` of it — the sign
expected of a plug-in entropy estimator. -/
theorem octic_reported_value :
    (1.7474 : ℝ) < uEnt (univ : Finset (ZMod 17)ˣ) (realDeg 17) ∧
      uEnt (univ : Finset (ZMod 17)ˣ) (realDeg 17) - 1.7474 < 0.003 := by
  rw [octic_entropy]; constructor <;> norm_num

end OcticCyclic