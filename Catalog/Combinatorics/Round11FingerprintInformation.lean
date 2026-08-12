/-
# Round-11 Closures, Part III: CFSIGMA — the hint feed is starved

Formal companion to the round-11 negative-results synthesis
(`29_Round11_Closures.md`, hypothesis **CFSIGMA**).

The paper's central claim is that the Coppersmith hint-amplification channel
*exists* — an approximation `σ̂ ≈ p + q` is worth a factorization — but that the
cycle-index fingerprint provides *no source* for it: below the order scale the
fingerprint carries zero mutual information with `(p+q) mod ℓ`.

This file proves both halves in an exact, finitary form.

* **The channel exists.**  `Round11.sum_prod_inversion`: the pair `(p+q, p·q)`
  determines `{p, q}`.  An *exact* hint `σ = p + q` is literally a factorization.
* **The source is starved.**  We use the finitary (counting) notion of
  independence `Round11.ZeroInfo`: a statistic `T` is uninformative about a
  secret `S` on a finite instance set `Ω` when every joint fibre has exactly the
  product cardinality.  `Round11.cfsigma_starved` shows that the *truncated
  fingerprint* `c ↦ F(c)`, `1 ≤ c ≤ D`, restricted to instances whose two
  multiplicative orders exceed `D`, is uninformative about `(p+q) mod ℓ` — for
  **every** modulus `ℓ` and **every** instance set.  By the data-processing
  lemma `Round11.zeroInfo_comp`, no post-processing of the truncated fingerprint
  can do better (`Round11.cfsigma_starved_postprocessed`).

The proof of starvation is Part I's order seal: below the order scale the
fingerprint is a *constant* function of the instance, so its fibres are either
empty or all of `Ω`.  Non-vacuity of the hypothesis is witnessed by
`Round11.cfsigma_instance_witness`.
-/
import Mathlib
import Combinatorics.Round11CycleIndexFingerprint

namespace Round11

open Finset

/-! ## The channel: an exact sum hint is a factorization -/

/-- **Sum–product inversion.**  Two positive integers are determined, up to
order, by their sum and their product.  Hence an exact hint `σ = p+q` together
with `N = p·q` pins down the factorization: the Coppersmith channel is real. -/
theorem sum_prod_inversion {a b c d : ℕ} (hsum : a + b = c + d) (hprod : a * b = c * d) :
    (a = c ∧ b = d) ∨ (a = d ∧ b = c) := by
  have hs : (a : ℤ) + b = c + d := by exact_mod_cast hsum
  have hp : (a : ℤ) * b = c * d := by exact_mod_cast hprod
  have key : ((c : ℤ) - a) * ((c : ℤ) - b) = 0 := by nlinarith [hs, hp]
  rcases mul_eq_zero.1 key with h | h
  · have : a = c := by omega
    left; omega
  · have : b = c := by omega
    right; omega

/-- **Weighted sum–product inversion.**  Any *affine* hint `A·p + B·q` together
with `N = p·q` pins the factorization down to at most two candidates: a second
factorization with the same `N` and the same affine value has `p = p'`, or else
`A·p·p' = B·N`, which determines `p'` from `p`.

This is what makes the GROUPOID identity of Part II a *channel*: rewriting
`C·n = n + (p-1)(n/d_p) + (q-1)(n/d_q) + (p-1)(q-1)` with `(p-1)(q-1) = N-p-q+1`
turns the orbit count into the affine observation
`(n/d_p - 1)·p + (n/d_q - 1)·q = C·n - n - n/d_p - n/d_q - N - 1`.
In the balanced case `d_p = d_q` both coefficients vanish — the observation is
empty, which is exactly `Round11.groupoid_balanced_no_leak`. -/
theorem weighted_sum_prod_inversion {A B p q p' q' N : ℕ}
    (h : p * q = N) (h' : p' * q' = N) (hlin : A * p + B * q = A * p' + B * q') :
    p = p' ∨ A * p * p' = B * N := by
  have hz : ((p:ℤ) - p') * ((A:ℤ) * (p + p') - ((A:ℤ) * p + (B:ℤ) * q)) = 0 := by
    have hZ : (p:ℤ) * q = N := by exact_mod_cast h
    have hZ' : (p':ℤ) * q' = N := by exact_mod_cast h'
    have hL : (A:ℤ) * p + B * q = (A:ℤ) * p' + B * q' := by exact_mod_cast hlin
    nlinarith [hZ, hZ', hL]
  rcases mul_eq_zero.1 hz with hc | hc
  · left; omega
  · right
    have hZ : (p:ℤ) * q = N := by exact_mod_cast h
    have hfin : (A:ℤ) * p * p' = B * N := by nlinarith [hc, hZ]
    exact_mod_cast hfin

/-- Degenerate case of the weighted inversion: when the `p`-coefficient of the
hint vanishes and the `q`-coefficient does not, the hint determines `q`, hence
the factorization outright. -/
theorem inversion_of_zero_coeff {B q q' : ℕ} (hB : 0 < B) (hlin : B * q = B * q') :
    q = q' :=
  Nat.eq_of_mul_eq_mul_left hB hlin

/-! ## Finitary independence -/

variable {α β γ δ : Type*} [DecidableEq β] [DecidableEq γ] [DecidableEq δ]

/-- `ZeroInfo Ω T S` : on the finite instance set `Ω`, the statistic `T` carries
zero information about the secret `S`, in the exact counting sense that every
joint fibre has product cardinality (equivalently, the empirical distributions of
`T` and `S` on `Ω` are independent). -/
def ZeroInfo (Ω : Finset α) (T : α → β) (S : α → γ) : Prop :=
  ∀ t s, (Ω.filter (fun w => T w = t ∧ S w = s)).card * Ω.card
      = (Ω.filter (fun w => T w = t)).card * (Ω.filter (fun w => S w = s)).card

/-- A statistic that is constant on `Ω` carries zero information. -/
theorem zeroInfo_of_const {Ω : Finset α} {T : α → β} {S : α → γ} {t₀ : β}
    (h : ∀ w ∈ Ω, T w = t₀) : ZeroInfo Ω T S := by
  intro t s
  by_cases ht : t = t₀
  · subst ht
    have e1 : Ω.filter (fun w => T w = t ∧ S w = s) = Ω.filter (fun w => S w = s) :=
      Finset.filter_congr (fun w hw => by simp [h w hw])
    have e2 : Ω.filter (fun w => T w = t) = Ω :=
      Finset.filter_true_of_mem (fun w hw => h w hw)
    rw [e1, e2, mul_comm]
  · have e1 : Ω.filter (fun w => T w = t ∧ S w = s) = ∅ :=
      Finset.filter_false_of_mem (fun w hw hc => ht (by rw [← hc.1, h w hw]))
    have e2 : Ω.filter (fun w => T w = t) = ∅ :=
      Finset.filter_false_of_mem (fun w hw hc => ht (by rw [← hc, h w hw]))
    rw [e1, e2]
    simp

/-- **Data processing.**  Post-processing a zero-information statistic keeps it
uninformative: no function of `T` learns anything about `S`. -/
theorem zeroInfo_comp {Ω : Finset α} {T : α → β} {S : α → γ} (g : β → δ)
    (h : ZeroInfo Ω T S) : ZeroInfo Ω (g ∘ T) S := by
  classical
  intro t' s
  set F := (Ω.image T).filter (fun t => g t = t') with hF
  have hmemF : ∀ t, t ∈ F ↔ ((∃ a ∈ Ω, T a = t) ∧ g t = t') := by
    intro t; rw [hF, Finset.mem_filter, Finset.mem_image]
  have h1 : (Ω.filter (fun w => (g ∘ T) w = t' ∧ S w = s)).card
      = ∑ t ∈ F, (Ω.filter (fun w => T w = t ∧ S w = s)).card := by
    rw [Finset.card_eq_sum_card_fiberwise (f := T) (t := F) ?_]
    · refine Finset.sum_congr rfl (fun t ht => ?_)
      have hgt : g t = t' := ((hmemF t).1 ht).2
      congr 1
      ext w
      simp only [mem_filter, Function.comp_apply]
      constructor
      · rintro ⟨⟨hw, _, hs⟩, hT⟩; exact ⟨hw, hT, hs⟩
      · rintro ⟨hw, hT, hs⟩
        exact ⟨⟨hw, by rw [hT, hgt], hs⟩, hT⟩
    · intro w hw
      have hw' := Finset.mem_filter.1 hw
      exact (hmemF (T w)).2 ⟨⟨w, hw'.1, rfl⟩, hw'.2.1⟩
  have h2 : (Ω.filter (fun w => (g ∘ T) w = t')).card
      = ∑ t ∈ F, (Ω.filter (fun w => T w = t)).card := by
    rw [Finset.card_eq_sum_card_fiberwise (f := T) (t := F) ?_]
    · refine Finset.sum_congr rfl (fun t ht => ?_)
      have hgt : g t = t' := ((hmemF t).1 ht).2
      congr 1
      ext w
      simp only [mem_filter, Function.comp_apply]
      constructor
      · rintro ⟨⟨hw, _⟩, hT⟩; exact ⟨hw, hT⟩
      · rintro ⟨hw, hT⟩
        exact ⟨⟨hw, by rw [hT, hgt]⟩, hT⟩
    · intro w hw
      have hw' := Finset.mem_filter.1 hw
      exact (hmemF (T w)).2 ⟨⟨w, hw'.1, rfl⟩, hw'.2⟩
  rw [h1, h2, Finset.sum_mul, Finset.sum_mul]
  exact Finset.sum_congr rfl (fun t _ => h t s)

/-! ## The truncated fingerprint and the CFSIGMA closure -/

/-- An instance is a triple `(p, q, b)`. -/
abbrev Instance := ℕ × ℕ × ℕ

/-- The fingerprint truncated to the window `1 ≤ c ≤ D`: this is everything an
attacker can read off the cycle-index object in `poly(log N)` time per
coefficient, before the order scale is reached. -/
def truncFinger (D : ℕ) (I : Instance) : Fin D → ℕ :=
  fun c => fpr I.2.2 (I.1 * I.2.1) ((c : ℕ) + 1)

/-- The secret statistic of CFSIGMA: `(p+q) mod ℓ`. -/
def sigmaMod (l : ℕ) (I : Instance) : ℕ := (I.1 + I.2.1) % l

/-- Below the order scale the truncated fingerprint is the constant function `1`. -/
theorem truncFinger_const {D : ℕ} {I : Instance} (hp : I.1.Prime) (hq : I.2.1.Prime)
    (hpq : I.1 ≠ I.2.1) (hb : 1 ≤ I.2.2)
    (hD : D < min (ordAt I.2.2 I.1) (ordAt I.2.2 I.2.1)) :
    truncFinger D I = fun _ => 1 := by
  funext c
  have hc : ((c : ℕ) + 1) < min (ordAt I.2.2 I.1) (ordAt I.2.2 I.2.1) := by
    have := c.isLt
    omega
  exact fpr_eq_one_of_lt_dstar hp hq hpq hb (Nat.succ_pos _) hc

/-- **CFSIGMA, closed.**  On any finite family of semiprime instances whose two
multiplicative orders both exceed the observation window `D`, the truncated
cycle-index fingerprint carries *exactly zero* information about `(p+q) mod ℓ`,
for every modulus `ℓ`.  The Coppersmith hint channel has no source here. -/
theorem cfsigma_starved (D l : ℕ) (Ω : Finset Instance)
    (hΩ : ∀ I ∈ Ω, I.1.Prime ∧ I.2.1.Prime ∧ I.1 ≠ I.2.1 ∧ 1 ≤ I.2.2 ∧
      D < min (ordAt I.2.2 I.1) (ordAt I.2.2 I.2.1)) :
    ZeroInfo Ω (truncFinger D) (sigmaMod l) := by
  refine zeroInfo_of_const (t₀ := fun _ => 1) (fun I hI => ?_)
  obtain ⟨h1, h2, h3, h4, h5⟩ := hΩ I hI
  exact truncFinger_const h1 h2 h3 h4 h5

/-- **No post-processing helps.**  Any statistic computed from the truncated
fingerprint — a hash, a projection, a candidate `σ̂` — is equally starved. -/
theorem cfsigma_starved_postprocessed (D l : ℕ) (Ω : Finset Instance)
    {δ : Type*} [DecidableEq δ] (g : (Fin D → ℕ) → δ)
    (hΩ : ∀ I ∈ Ω, I.1.Prime ∧ I.2.1.Prime ∧ I.1 ≠ I.2.1 ∧ 1 ≤ I.2.2 ∧
      D < min (ordAt I.2.2 I.1) (ordAt I.2.2 I.2.1)) :
    ZeroInfo Ω (g ∘ truncFinger D) (sigmaMod l) :=
  zeroInfo_comp g (cfsigma_starved D l Ω hΩ)

/-- The window `1 ≤ d ≤ D` of the `N`-computable Möbius coefficients `M_d` — the
per-coefficient cycle-index object of CIFINGER. -/
def truncMob (D : ℕ) (I : Instance) : Fin D → ℤ :=
  fun d => mobRaw I.2.2 (I.1 * I.2.1) ((d : ℕ) + 1)

/-- Below the order scale the Möbius window is the instance-independent vector
`(1, 0, 0, …)`. -/
theorem truncMob_const {D : ℕ} {I : Instance} (hp : I.1.Prime) (hq : I.2.1.Prime)
    (hpq : I.1 ≠ I.2.1) (hb : 1 ≤ I.2.2)
    (hD : D < min (ordAt I.2.2 I.1) (ordAt I.2.2 I.2.1)) :
    truncMob D I = fun d : Fin D => if (d : ℕ) = 0 then (1 : ℤ) else 0 := by
  funext d
  have hd : ((d : ℕ) + 1) < min (ordAt I.2.2 I.1) (ordAt I.2.2 I.2.1) := by
    have := d.isLt
    omega
  rw [truncMob, mobRaw_eq_of_lt_dstar hp hq hpq hb (Nat.succ_pos _) hd]
  by_cases h : (d : ℕ) = 0 <;> simp [h]

/-- **CFSIGMA for the per-coefficient spectral object.**  The Möbius window — the
very object CIFINGER proposed as a new channel — is likewise uninformative about
`(p+q) mod ℓ` below the order scale. -/
theorem cfsigma_starved_mobius (D l : ℕ) (Ω : Finset Instance)
    (hΩ : ∀ I ∈ Ω, I.1.Prime ∧ I.2.1.Prime ∧ I.1 ≠ I.2.1 ∧ 1 ≤ I.2.2 ∧
      D < min (ordAt I.2.2 I.1) (ordAt I.2.2 I.2.1)) :
    ZeroInfo Ω (truncMob D) (sigmaMod l) := by
  refine zeroInfo_of_const (t₀ := fun d : Fin D => if (d : ℕ) = 0 then (1 : ℤ) else 0)
    (fun I hI => ?_)
  obtain ⟨h1, h2, h3, h4, h5⟩ := hΩ I hI
  exact truncMob_const h1 h2 h3 h4 h5

/-- A pair of instances separated by both statistics defeats zero information:
the counting-independence notion is not vacuous. -/
theorem not_zeroInfo_pair [DecidableEq α] {T : α → β} {S : α → γ} {w₁ w₂ : α}
    (hne : w₁ ≠ w₂) (hT : T w₁ ≠ T w₂) (hS : S w₁ ≠ S w₂) :
    ¬ ZeroInfo ({w₁, w₂} : Finset α) T S := by
  intro h
  have h2 := h (T w₁) (S w₁)
  rw [show ({w₁, w₂} : Finset α).filter (fun w => T w = T w₁ ∧ S w = S w₁) = {w₁} by
        simp [Finset.filter_insert, Finset.filter_singleton, hT.symm, hS.symm],
      show ({w₁, w₂} : Finset α).filter (fun w => T w = T w₁) = {w₁} by
        simp [Finset.filter_insert, Finset.filter_singleton, hT.symm],
      show ({w₁, w₂} : Finset α).filter (fun w => S w = S w₁) = {w₁} by
        simp [Finset.filter_insert, Finset.filter_singleton, hS.symm],
      Finset.card_singleton, Finset.card_insert_of_notMem (by simpa using hne),
      Finset.card_singleton] at h2
  omega

/-! ## Non-vacuity -/

/-- The order of `b` mod `p` is at least `2` as soon as `b ≢ 1 (mod p)`. -/
theorem two_le_ordAt {p b : ℕ} (hp : p.Prime) (hbp : ¬ p ∣ b) (hne : (b : ZMod p) ≠ 1) :
    2 ≤ ordAt b p := by
  have h0 : 0 < ordAt b p := ordAt_pos hp hbp
  have h1 : ordAt b p ≠ 1 := by
    intro h
    exact hne (orderOf_eq_one_iff.1 h)
  omega

/-- **Non-vacuity witness.**  The hypothesis of `cfsigma_starved` is satisfiable:
the instance `(p, q, b) = (3, 5, 2)` has both orders `> 1`, so the window `D = 1`
is legitimate and the statement is not vacuous. -/
theorem cfsigma_instance_witness :
    (1 : ℕ) < min (ordAt 2 3) (ordAt 2 5) := by
  have h3 : 2 ≤ ordAt 2 3 :=
    two_le_ordAt (by norm_num) (by decide) (by decide)
  have h5 : 2 ≤ ordAt 2 5 :=
    two_le_ordAt (by norm_num) (by decide) (by decide)
  omega

/-- **The wall is sharp.**  Zero information fails as soon as the window reaches
the order scale: on the pair of instances `(3,5,2)` and `(3,7,2)` the fingerprint
window `1 ≤ c ≤ 4` already separates them (`F(3) = 1` versus `F(3) = 7`, since
`ord_7 2 = 3`), and so does `(p+q) mod 3` (`2` versus `1`).  Hence the truncated
fingerprint is *not* uninformative there: the closure of CFSIGMA is exactly a
statement about the sub-order-scale window, not a triviality. -/
theorem cifinger_informative_at_order_scale :
    ¬ ZeroInfo ({((3, 5, 2) : Instance), (3, 7, 2)} : Finset Instance)
      (truncFinger 4) (sigmaMod 3) :=
  not_zeroInfo_pair (by decide) (by decide) (by decide)

/-- The witness instance really satisfies the full hypothesis of
`cfsigma_starved` with `D = 1`. -/
theorem cfsigma_starved_witness (l : ℕ) :
    ZeroInfo ({(3, 5, 2)} : Finset Instance) (truncFinger 1) (sigmaMod l) := by
  refine cfsigma_starved 1 l _ (fun I hI => ?_)
  rw [Finset.mem_singleton] at hI
  subst hI
  exact ⟨by norm_num, by norm_num, by norm_num, by norm_num, cfsigma_instance_witness⟩

end Round11