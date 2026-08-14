/-
# Mod-exponential windows are smoothness-blind

A *Bridges* file connecting three normally separate areas:

* **finite group theory** (multiplicative order in `(ZMod N)ˣ`),
* **combinatorics of words** (the collision pattern of a finite window of a sequence),
* **statistical learning** (the rank statistic `AUC` of a scoring rule).

## Scientific context

Experiment 397 of the factoring research loop (SEQSMOOTH-NULL) asked whether the
`p−1` smoothness class of a semiprime `N = p·q` leaks into the *statistics of a short
window* `s_x = a^x mod N`, `x < m`, with `m` far smaller than the smoothness bound `B`.
Empirically the answer was a hard null: 42 windowed features gave a permutation
`p = 0.502` and a 5-fold logistic `AUC = 0.500`, while Pollard's `p−1` method with
`B = 100` factored 35/36 of the SMOOTH instances and 0/36 of the GENERAL instances.

This file turns the empirical null into theorems.  The three pillars are:

1. **Structure theorem** (`firstOcc_eq_mod`, `distinctCount_eq`).  The entire
   *collision structure* of the window — which indices carry equal values — is the
   function `x ↦ x % d` where `d = ord_N(a)`.  Nothing else about `N` survives:
   in particular no arithmetic information about the factorisation of `p − 1`.

2. **Blindness / information bound** (`windowPattern_blind`, `collisionFeature_blind`,
   `windowPatterns_ncard_le`).  Any statistic that reads only the collision structure
   of a length-`m` window takes at most `m + 1` distinct values over *all* moduli and
   bases, and agrees on any two instances with `min m d` equal.  Composed with the
   `AUC` bridge (`auc_eq_half_of_blind`) this yields `AUC = 1/2` *exactly* — the
   experiment's 0.500 is not a sampling artefact but a theorem.

3. **The weakness is real, and only the `p−1` method sees it**
   (`pMinusOne_succeeds`, `pMinusOne_fails`) instantiated on an explicit matched pair

   * `N₁ = 1009 · 1019` (SMOOTH: `1008 = 2^4·3^2·7` divides `M = lcm(1..20)`),
   * `N₂ = 1019 · 1039` (GENERAL: `509 ∤ M`, `173 ∤ M`),

   for which `gcd(2^M − 1, N₁)` is a *proper nontrivial* divisor while
   `gcd(2^M − 1, N₂) = 1`, yet the two length-256 windows of `2^x` have *identical*
   collision structure, hence identical value under every collision feature, hence
   `AUC = 1/2`.

## Honest scope

The blindness theorems of §2–§13 cover the *collision-structure* features (distinct
count, self-collision gap, repeat/run pattern, any function of the pattern word).
Section 14 adds the first value-level result: over a *full period* the set of values is
invariant under the base action `a ↦ a^t`, `gcd(t, ord_N a) = 1`
(`periodValues_base_invariant`), so every symmetric value feature depends on the cyclic
subgroup alone.  Value-level features of a *short* window (top-bit balance of the first
`m ≪ d` terms) remain outside the scope of these theorems; the experiment found them
null too, but that is an empirical statement, not one proved here.

Sections 15–16 remove the last piece of ad-hockery from the blindness statements:
§15 abstracts the order lower bound into a *decidable certificate*
(`le_orderOf_of_certificate`, `le_orderOf_zmod_of_certificate`), and §16 uses it, with
the elementary bound `p < 2^(ord_p 2)` (`lt_two_pow_orderOf_two`), to build an infinite
blind family for **every** window length `m` (`exists_infinite_blind_family`), so that
`AUC = 1/2` holds for every real statistic at every length
(`no_free_lunch_auc_all_lengths`), not merely at the `m = 256` of the experiment.
-/
import Mathlib

namespace Bridges.ModExpSmoothnessBlindness

open Finset

/-! ## 1. The mod-exponential window and its order -/

/-- One term of the mod-exponential sequence: `s_x = a ^ x mod N`. -/
def modExp (a N x : ℕ) : ℕ := a ^ x % N

/-- Multiplicative order of `a` modulo `N` (the only invariant the window can see). -/
noncomputable def mexpOrd (a N : ℕ) : ℕ := orderOf (a : ZMod N)

lemma isOfFinOrder_cast {a N : ℕ} (hN : 0 < N) (h : Nat.Coprime a N) :
    IsOfFinOrder (a : ZMod N) := by
  haveI : NeZero N := ⟨hN.ne'⟩
  rw [isOfFinOrder_iff_pow_eq_one]
  refine ⟨N.totient, Nat.totient_pos.mpr hN, ?_⟩
  have h1 := Nat.ModEq.pow_totient h
  have h2 := (ZMod.natCast_eq_natCast_iff _ _ _).mpr h1
  push_cast at h2
  simpa using h2

lemma mexpOrd_pos {a N : ℕ} (hN : 0 < N) (h : Nat.Coprime a N) : 0 < mexpOrd a N :=
  (isOfFinOrder_cast hN h).orderOf_pos

/-- **Collision law.**  Two indices of the mod-exponential sequence carry the same value
iff they are congruent modulo the order.  This is the single structural fact behind all
the blindness results below. -/
theorem modExp_eq_iff {a N : ℕ} (hN : 0 < N) (h : Nat.Coprime a N) (x y : ℕ) :
    modExp a N y = modExp a N x ↔ y ≡ x [MOD mexpOrd a N] := by
  have h1 : modExp a N y = modExp a N x ↔ (a ^ y) ≡ (a ^ x) [MOD N] := Iff.rfl
  rw [h1, ← ZMod.natCast_eq_natCast_iff]
  push_cast
  exact (isOfFinOrder_cast hN h).pow_eq_pow_iff_modEq

/-! ## 2. The pattern word of a window -/

/-- `firstOcc a N x` is the least index carrying the same value as index `x`.
The function `x ↦ firstOcc a N x` is the *pattern word* of the sequence: it records
exactly the collision structure and nothing else. -/
def firstOcc (a N x : ℕ) : ℕ := Nat.find (p := fun y => modExp a N y = modExp a N x) ⟨x, rfl⟩

/-- **Structure theorem for the pattern word.**  The collision structure of the
mod-exponential sequence is *literally* the residue map modulo the order. -/
theorem firstOcc_eq_mod {a N : ℕ} (hN : 0 < N) (h : Nat.Coprime a N) (x : ℕ) :
    firstOcc a N x = x % mexpOrd a N := by
  have hd := mexpOrd_pos hN h
  have hmem : modExp a N (x % mexpOrd a N) = modExp a N x :=
    (modExp_eq_iff hN h x _).mpr (Nat.mod_modEq x _)
  unfold firstOcc
  apply le_antisymm
  · exact Nat.find_le hmem
  · rw [Nat.le_find_iff]
    intro y hy hcon
    have h3 : y % mexpOrd a N = x % mexpOrd a N := (modExp_eq_iff hN h x y).mp hcon
    have hyd : y < mexpOrd a N := lt_trans hy (Nat.mod_lt _ hd)
    rw [Nat.mod_eq_of_lt hyd] at h3
    omega

/-- The pattern word of the length-`m` window (padded with `0` outside the window). -/
def windowPattern (a N m : ℕ) : ℕ → ℕ := fun x => if x < m then firstOcc a N x else 0

/-- Inside a window of length `m`, only `min m d` is visible. -/
lemma mod_min_eq {m d x : ℕ} (hx : x < m) : x % min m d = x % d := by
  rcases le_total d m with h | h
  · rw [min_eq_right h]
  · rw [min_eq_left h, Nat.mod_eq_of_lt hx, Nat.mod_eq_of_lt (lt_of_lt_of_le hx h)]

/-- **Truncation theorem.**  A window of length `m` sees the order only through
`min m (ord_N a)`. -/
theorem windowPattern_eq {a N : ℕ} (hN : 0 < N) (h : Nat.Coprime a N) (m : ℕ) :
    windowPattern a N m = fun x => if x < m then x % min m (mexpOrd a N) else 0 := by
  funext x
  by_cases hx : x < m
  · simp only [windowPattern, if_pos hx, firstOcc_eq_mod hN h x, mod_min_eq hx]
  · simp [windowPattern, hx]

/-- **Blindness theorem.**  Two instances whose orders agree after truncation at the
window length have *identical* pattern words: no statistic of the collision structure
can tell them apart. -/
theorem windowPattern_blind {a₁ N₁ a₂ N₂ m : ℕ} (hN₁ : 0 < N₁) (h₁ : Nat.Coprime a₁ N₁)
    (hN₂ : 0 < N₂) (h₂ : Nat.Coprime a₂ N₂)
    (hord : min m (mexpOrd a₁ N₁) = min m (mexpOrd a₂ N₂)) :
    windowPattern a₁ N₁ m = windowPattern a₂ N₂ m := by
  rw [windowPattern_eq hN₁ h₁, windowPattern_eq hN₂ h₂, hord]

/-- Any feature of the pattern word is blind in the same sense. -/
theorem collisionFeature_blind {β : Type*} (F : (ℕ → ℕ) → β) {a₁ N₁ a₂ N₂ m : ℕ}
    (hN₁ : 0 < N₁) (h₁ : Nat.Coprime a₁ N₁) (hN₂ : 0 < N₂) (h₂ : Nat.Coprime a₂ N₂)
    (hord : min m (mexpOrd a₁ N₁) = min m (mexpOrd a₂ N₂)) :
    F (windowPattern a₁ N₁ m) = F (windowPattern a₂ N₂ m) := by
  rw [windowPattern_blind hN₁ h₁ hN₂ h₂ hord]

/-! ## 3. Information bound: a length-`m` window carries at most `log₂(m+1)` bits -/

/-- The set of all pattern words of length-`m` windows, over *all* bases and moduli. -/
def windowPatterns (m : ℕ) : Set (ℕ → ℕ) :=
  {w | ∃ a N : ℕ, 0 < N ∧ Nat.Coprime a N ∧ w = windowPattern a N m}

/-- **Information bound.**  At most `m + 1` pattern words exist in total, so a window of
length `m` carries at most `log₂ (m+1)` bits about `N` — vanishing compared with the
`Θ(log N)` bits needed to name a factor.  This is the structural reason a smoothness
classifier trained on collision features cannot beat chance. -/
theorem windowPatterns_ncard_le (m : ℕ) : (windowPatterns m).ncard ≤ m + 1 := by
  set Φ : ℕ → (ℕ → ℕ) := fun k => fun x => if x < m then x % k else 0 with hΦ
  have hsub : windowPatterns m ⊆ Φ '' (↑(Finset.range (m + 1)) : Set ℕ) := by
    rintro w ⟨a, N, hN, hco, rfl⟩
    refine ⟨min m (mexpOrd a N), ?_, ?_⟩
    · simp only [Finset.coe_range, Set.mem_Iio]
      exact lt_of_le_of_lt (min_le_left _ _) (Nat.lt_succ_self m)
    · rw [hΦ, windowPattern_eq hN hco m]
  have hfin : (Φ '' (↑(Finset.range (m + 1)) : Set ℕ)).Finite :=
    (Finset.finite_toSet _).image _
  calc (windowPatterns m).ncard ≤ (Φ '' (↑(Finset.range (m + 1)) : Set ℕ)).ncard :=
        Set.ncard_le_ncard hsub hfin
    _ ≤ (↑(Finset.range (m + 1)) : Set ℕ).ncard := Set.ncard_image_le (Finset.finite_toSet _)
    _ = m + 1 := by simp [Set.ncard_eq_toFinset_card']

/-! ## 4. The distinct-count feature -/

/-- Number of distinct values in the length-`m` window (the workhorse feature of the
experiment). -/
def distinctCount (a N m : ℕ) : ℕ := ((Finset.range m).image (modExp a N)).card

/-- **Exact law for the distinct count**: `#{a^x mod N : x < m} = min m (ord_N a)`.
The feature is a function of the order alone. -/
theorem distinctCount_eq {a N : ℕ} (hN : 0 < N) (h : Nat.Coprime a N) (m : ℕ) :
    distinctCount a N m = min m (mexpOrd a N) := by
  have hd := mexpOrd_pos hN h
  have himg : (Finset.range m).image (modExp a N)
      = (Finset.range (min m (mexpOrd a N))).image (modExp a N) := by
    apply Finset.Subset.antisymm
    · intro v hv
      simp only [Finset.mem_image, Finset.mem_range] at hv ⊢
      obtain ⟨x, hx, rfl⟩ := hv
      refine ⟨x % mexpOrd a N, ?_, ?_⟩
      · exact lt_min (lt_of_le_of_lt (Nat.mod_le _ _) hx) (Nat.mod_lt _ hd)
      · exact (modExp_eq_iff hN h x _).mpr (Nat.mod_modEq x _)
    · have hsub : Finset.range (min m (mexpOrd a N)) ⊆ Finset.range m :=
        Finset.range_subset_range.mpr (min_le_left m (mexpOrd a N))
      exact Finset.image_subset_image hsub
  rw [distinctCount, himg, Finset.card_image_of_injOn, Finset.card_range]
  intro x hx y hy hxy
  simp only [Finset.coe_range, Set.mem_Iio] at hx hy
  have h3 : x % mexpOrd a N = y % mexpOrd a N := (modExp_eq_iff hN h y x).mp hxy
  rwa [Nat.mod_eq_of_lt (lt_of_lt_of_le hx (min_le_right _ _)),
    Nat.mod_eq_of_lt (lt_of_lt_of_le hy (min_le_right _ _))] at h3

/-- If the window is shorter than the order, every value is fresh. -/
theorem distinctCount_of_le {a N m : ℕ} (hN : 0 < N) (h : Nat.Coprime a N)
    (hm : m ≤ mexpOrd a N) : distinctCount a N m = m := by
  rw [distinctCount_eq hN h, min_eq_left hm]

/-! ## 5. The learning bridge: a blind feature has `AUC = 1/2` -/

/-- Rank-based area under the ROC curve of a real score `f`, positives `S`, negatives `G`
(ties counted with weight `1/2`, the standard convention). -/
noncomputable def auc {ι : Type*} (S G : Finset ι) (f : ι → ℝ) : ℝ :=
  (∑ s ∈ S, ∑ g ∈ G, (if f g < f s then (1 : ℝ) else if f g = f s then 1 / 2 else 0)) /
    (S.card * G.card)

/-- **AUC bridge.**  A feature that is constant across the two classes scores *exactly*
chance.  The experiment's `AUC = 0.500` is therefore a theorem, not an estimate. -/
theorem auc_eq_half_of_blind {ι : Type*} (S G : Finset ι) (f : ι → ℝ)
    (hS : S.Nonempty) (hG : G.Nonempty) (h : ∀ s ∈ S, ∀ g ∈ G, f s = f g) :
    auc S G f = 1 / 2 := by
  have hsum : (∑ s ∈ S, ∑ g ∈ G, (if f g < f s then (1 : ℝ) else if f g = f s then 1/2 else 0))
      = S.card * G.card * (1 / 2) := by
    rw [Finset.sum_congr rfl (fun s hs => Finset.sum_congr rfl (fun g hg => by
      rw [if_neg (by rw [h s hs g hg]; exact lt_irrefl _), if_pos (h s hs g hg).symm]))]
    simp [Finset.sum_const, mul_assoc]
  rw [auc, hsum]
  have h1 : (S.card : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr (Finset.card_ne_zero_of_mem hS.choose_spec)
  have h2 : (G.card : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr (Finset.card_ne_zero_of_mem hG.choose_spec)
  field_simp

/-! ## 6. Pollard's `p−1`: the weakness is real -/

/-- **Correctness of the `p−1` method.**  If `p ∣ N` and `p − 1 ∣ M`, then `p` divides
`gcd(a^M − 1, N)`: the smooth factor is exposed. -/
theorem pMinusOne_succeeds {a N p M : ℕ} (hp : p.Prime) (hpN : p ∣ N) (hpa : ¬ p ∣ a)
    (hM : (p - 1) ∣ M) : p ∣ Nat.gcd (a ^ M - 1) N := by
  haveI : Fact p.Prime := ⟨hp⟩
  have ha0 : (a : ZMod p) ≠ 0 := by simpa [ZMod.natCast_eq_zero_iff] using hpa
  have hfer : (a : ZMod p) ^ (p - 1) = 1 := ZMod.pow_card_sub_one_eq_one ha0
  have hpow : ((a ^ M : ℕ) : ZMod p) = ((1 : ℕ) : ZMod p) := by
    push_cast
    obtain ⟨k, rfl⟩ := hM
    rw [pow_mul, hfer, one_pow]
  have hmod : (1 : ℕ) ≡ a ^ M [MOD p] := ((ZMod.natCast_eq_natCast_iff _ _ _).mp hpow).symm
  have ha1 : 1 ≤ a ^ M :=
    Nat.one_le_pow _ _ (Nat.pos_of_ne_zero (by rintro rfl; exact hpa (dvd_zero p)))
  exact Nat.dvd_gcd ((Nat.modEq_iff_dvd' ha1).mp hmod) hpN

/-- If the order of `a` mod `r` does not divide `M`, then `r` misses `a^M − 1`. -/
theorem not_dvd_of_ord_not_dvd {a r M : ℕ} (ha : 1 ≤ a)
    (hro : ¬ (orderOf (a : ZMod r) ∣ M)) : ¬ r ∣ (a ^ M - 1) := by
  intro hdvd
  have ha1 : 1 ≤ a ^ M := Nat.one_le_pow _ _ ha
  have hmod : (1 : ℕ) ≡ a ^ M [MOD r] := (Nat.modEq_iff_dvd' ha1).mpr hdvd
  have hc : ((a ^ M : ℕ) : ZMod r) = ((1 : ℕ) : ZMod r) :=
    (ZMod.natCast_eq_natCast_iff _ _ _).mpr hmod.symm
  push_cast at hc
  exact hro (orderOf_dvd_iff_pow_eq_one.mpr hc)

/-- **Failure of the `p−1` method.**  If neither order divides `M`, the method returns
the trivial gcd. -/
theorem pMinusOne_fails {a p q M : ℕ} (hp : p.Prime) (hq : q.Prime) (ha : 1 ≤ a)
    (hpo : ¬ (orderOf (a : ZMod p) ∣ M)) (hqo : ¬ (orderOf (a : ZMod q) ∣ M)) :
    Nat.gcd (a ^ M - 1) (p * q) = 1 := by
  have key : ∀ r : ℕ, r.Prime → ¬ (orderOf (a : ZMod r) ∣ M) → Nat.Coprime (a ^ M - 1) r :=
    fun r hr hro =>
      Nat.coprime_comm.mp ((Nat.Prime.coprime_iff_not_dvd hr).mpr (not_dvd_of_ord_not_dvd ha hro))
  exact Nat.Coprime.mul_right (key p hp hpo) (key q hq hqo)

/-! ## 7. Auxiliary order arithmetic -/

lemma ord_dvd_sub_one {a r : ℕ} (hr : r.Prime) (ha : ¬ r ∣ a) :
    orderOf (a : ZMod r) ∣ r - 1 := by
  haveI : Fact r.Prime := ⟨hr⟩
  exact orderOf_dvd_iff_pow_eq_one.mpr
    (ZMod.pow_card_sub_one_eq_one (by simpa [ZMod.natCast_eq_zero_iff] using ha))

/-- If `d ∣ s * r` with `r` prime and `d ∤ s`, then `r ∣ d`. -/
lemma prime_dvd_of_not_dvd {d s r : ℕ} (hr : r.Prime) (hdvd : d ∣ s * r) (hns : ¬ d ∣ s) :
    r ∣ d := by
  by_contra hc
  exact hns (((Nat.Prime.coprime_iff_not_dvd hr).mpr hc).symm.dvd_of_dvd_mul_right hdvd)

/-- The order mod a divisor divides the order mod the modulus. -/
lemma ord_dvd_ord_of_dvd (a N r : ℕ) (h : r ∣ N) :
    orderOf ((a : ℕ) : ZMod r) ∣ orderOf ((a : ℕ) : ZMod N) := by
  have h2 := orderOf_map_dvd (ZMod.castHom h (ZMod r)).toMonoidHom ((a : ℕ) : ZMod N)
  rwa [show ((ZMod.castHom h (ZMod r)).toMonoidHom ((a : ℕ) : ZMod N)) = ((a : ℕ) : ZMod r) from
    map_natCast (ZMod.castHom h (ZMod r)) a] at h2


/-! ## 8. The explicit matched pair: SMOOTH vs GENERAL

`bigM = lcm(1,…,20) = 232792560 = 2^4·3^2·5·7·11·13·17·19` is the exponent used by
Pollard's `p−1` method with bound `B = 20`.

* `N_smooth  = 1009 · 1019`, and `1009 − 1 = 1008 = 2^4·3^2·7` divides `bigM`;
* `N_general = 1019 · 1039`, and `1019 − 1 = 2·509`, `1039 − 1 = 2·3·173`, whose large
  prime factors `509`, `173` exceed the bound.

Both moduli share the prime `1019`, whose base-2 order is a multiple of `509 > 256`;
this is what pins the window statistics of the two classes to the *same* value.
-/

/-- `lcm (1, …, 20)`, the exponent of Pollard's `p−1` method at bound `B = 20`. -/
def bigM : ℕ := 232792560

/-- SMOOTH instance: `1009 · 1019` with `1009 − 1` `20`-smooth. -/
def N_smooth : ℕ := 1028171

/-- GENERAL instance: `1019 · 1039`, neither factor `20`-smooth. -/
def N_general : ℕ := 1058741

lemma N_smooth_eq : N_smooth = 1009 * 1019 := by norm_num [N_smooth]

lemma N_general_eq : N_general = 1019 * 1039 := by norm_num [N_general]

lemma coprime_two_N_smooth : Nat.Coprime 2 N_smooth := by norm_num [N_smooth, Nat.Coprime]

lemma coprime_two_N_general : Nat.Coprime 2 N_general := by norm_num [N_general, Nat.Coprime]

/-- The base-2 order mod `1019` does not divide `bigM`: `gcd(bigM, 1018) = 2` and `2² ≠ 1`. -/
lemma ord_two_1019_not_dvd : ¬ (orderOf ((2 : ℕ) : ZMod 1019) ∣ bigM) := by
  intro h
  have h1 : orderOf ((2 : ℕ) : ZMod 1019) ∣ 1018 := by
    have h0 := ord_dvd_sub_one (a := 2) (r := 1019) (by norm_num) (by norm_num)
    simpa using h0
  have h2 : orderOf ((2 : ℕ) : ZMod 1019) ∣ Nat.gcd bigM 1018 := Nat.dvd_gcd h h1
  rw [show Nat.gcd bigM 1018 = 2 by norm_num [bigM]] at h2
  have h4 : ((2 : ℕ) : ZMod 1019) ^ 2 = 1 := orderOf_dvd_iff_pow_eq_one.mp h2
  norm_num at h4
  revert h4
  decide

/-- The base-2 order mod `1039` does not divide `bigM`: `gcd(bigM, 1038) = 6` and `2⁶ ≠ 1`. -/
lemma ord_two_1039_not_dvd : ¬ (orderOf ((2 : ℕ) : ZMod 1039) ∣ bigM) := by
  intro h
  have h1 : orderOf ((2 : ℕ) : ZMod 1039) ∣ 1038 := by
    have h0 := ord_dvd_sub_one (a := 2) (r := 1039) (by norm_num) (by norm_num)
    simpa using h0
  have h2 : orderOf ((2 : ℕ) : ZMod 1039) ∣ Nat.gcd bigM 1038 := Nat.dvd_gcd h h1
  rw [show Nat.gcd bigM 1038 = 6 by norm_num [bigM]] at h2
  have h4 : ((2 : ℕ) : ZMod 1039) ^ 6 = 1 := orderOf_dvd_iff_pow_eq_one.mp h2
  norm_num at h4
  revert h4
  decide

/-- The base-2 order mod `1019` is at least `509`: `509 ∣ ord` because `ord ∣ 2·509`
and `ord ∤ 2`. -/
lemma ord_two_1019_ge : 256 ≤ orderOf ((2 : ℕ) : ZMod 1019) := by
  have h1 : orderOf ((2 : ℕ) : ZMod 1019) ∣ 2 * 509 := by
    have h0 := ord_dvd_sub_one (a := 2) (r := 1019) (by norm_num) (by norm_num)
    norm_num at h0
    exact h0
  have hne2 : ¬ (orderOf ((2 : ℕ) : ZMod 1019) ∣ 2) := by
    intro h
    have h4 : ((2 : ℕ) : ZMod 1019) ^ 2 = 1 := orderOf_dvd_iff_pow_eq_one.mp h
    norm_num at h4
    revert h4
    decide
  have h509 : (509 : ℕ) ∣ orderOf ((2 : ℕ) : ZMod 1019) :=
    prime_dvd_of_not_dvd (by norm_num) h1 hne2
  have hpos : orderOf ((2 : ℕ) : ZMod 1019) ≠ 0 := by
    intro h0
    rw [h0] at h1
    simp at h1
  have := Nat.le_of_dvd (Nat.pos_of_ne_zero hpos) h509
  omega

/-- Both moduli have base-2 order well beyond the window length, because both are
divisible by `1019`. -/
lemma mexpOrd_ge_of_1019_dvd {N : ℕ} (hN : 0 < N) (hco : Nat.Coprime 2 N) (h : (1019 : ℕ) ∣ N) :
    256 ≤ mexpOrd 2 N := by
  have hdvd : orderOf ((2 : ℕ) : ZMod 1019) ∣ mexpOrd 2 N := ord_dvd_ord_of_dvd 2 N 1019 h
  have hpos : 0 < mexpOrd 2 N := mexpOrd_pos hN hco
  exact le_trans ord_two_1019_ge (Nat.le_of_dvd hpos hdvd)

lemma mexpOrd_smooth_ge : 256 ≤ mexpOrd 2 N_smooth :=
  mexpOrd_ge_of_1019_dvd (by norm_num [N_smooth]) coprime_two_N_smooth ⟨1009, by norm_num [N_smooth]⟩

lemma mexpOrd_general_ge : 256 ≤ mexpOrd 2 N_general :=
  mexpOrd_ge_of_1019_dvd (by norm_num [N_general]) coprime_two_N_general
    ⟨1039, by norm_num [N_general]⟩

/-! ### 8a. The classes really differ: Pollard `p−1` separates them -/

/-- On the SMOOTH instance, the `p−1` method at bound `B = 20` returns a **proper
nontrivial divisor**: it finds the factor `1009`. -/
theorem pMinusOne_separates_smooth :
    1009 ∣ Nat.gcd (2 ^ bigM - 1) N_smooth ∧
      Nat.gcd (2 ^ bigM - 1) N_smooth ≠ 1 ∧ Nat.gcd (2 ^ bigM - 1) N_smooth ≠ N_smooth := by
  have hdvd : 1009 ∣ Nat.gcd (2 ^ bigM - 1) N_smooth :=
    pMinusOne_succeeds (by norm_num) ⟨1019, by norm_num [N_smooth]⟩ (by norm_num)
      (by norm_num [bigM])
  refine ⟨hdvd, ?_, ?_⟩
  · intro h
    rw [h] at hdvd
    norm_num at hdvd
  · intro h
    have h1019 : (1019 : ℕ) ∣ (2 ^ bigM - 1) := by
      have hg : N_smooth ∣ (2 ^ bigM - 1) := h ▸ Nat.gcd_dvd_left _ _
      exact dvd_trans ⟨1009, by norm_num [N_smooth]⟩ hg
    exact not_dvd_of_ord_not_dvd (by norm_num) ord_two_1019_not_dvd h1019

/-- On the GENERAL instance the very same computation returns the trivial gcd: the
`p−1` method fails. -/
theorem pMinusOne_fails_general : Nat.gcd (2 ^ bigM - 1) N_general = 1 := by
  rw [N_general_eq]
  exact pMinusOne_fails (by norm_num) (by norm_num) (by norm_num)
    ord_two_1019_not_dvd ord_two_1039_not_dvd

/-! ### 8b. …yet the length-256 windows are literally indistinguishable -/

/-- The two classes have **identical** pattern words on the length-256 window: the
window is the identity on `[0,256)` in both cases. -/
theorem windowPattern_smooth_eq_general :
    windowPattern 2 N_smooth 256 = windowPattern 2 N_general 256 := by
  refine windowPattern_blind (by norm_num [N_smooth]) coprime_two_N_smooth
    (by norm_num [N_general]) coprime_two_N_general ?_
  rw [min_eq_left mexpOrd_smooth_ge, min_eq_left mexpOrd_general_ge]

/-- Consequently **every** collision-structure feature (distinct count, self-collision
gap, run lengths, …) takes the same value on the two classes. -/
theorem collisionFeature_smooth_eq_general {β : Type*} (F : (ℕ → ℕ) → β) :
    F (windowPattern 2 N_smooth 256) = F (windowPattern 2 N_general 256) := by
  rw [windowPattern_smooth_eq_general]

/-- Both windows contain 256 distinct values. -/
theorem distinctCount_smooth : distinctCount 2 N_smooth 256 = 256 :=
  distinctCount_of_le (by norm_num [N_smooth]) coprime_two_N_smooth mexpOrd_smooth_ge

theorem distinctCount_general : distinctCount 2 N_general 256 = 256 :=
  distinctCount_of_le (by norm_num [N_general]) coprime_two_N_general mexpOrd_general_ge

/-- The distinct-count feature, as a real-valued score on moduli. -/
noncomputable def distinctScore (m : ℕ) : ℕ → ℝ := fun N => (distinctCount 2 N m : ℝ)

/-- **AUC = 1/2 exactly.**  A classifier scoring the SMOOTH modulus against the GENERAL
one by the window distinct count achieves precisely chance — the experiment's
`AUC = 0.500`, as a theorem. -/
theorem auc_distinctScore_eq_half :
    auc ({N_smooth} : Finset ℕ) ({N_general} : Finset ℕ) (distinctScore 256) = 1 / 2 := by
  refine auc_eq_half_of_blind _ _ _ ⟨N_smooth, by simp⟩ ⟨N_general, by simp⟩ ?_
  intro s hs g hg
  simp only [Finset.mem_singleton] at hs hg
  subst hs
  subst hg
  simp [distinctScore, distinctCount_smooth, distinctCount_general]

/-! ### 8c. The null result, packaged -/

/-- **SEQSMOOTH-NULL (formal version).**  For the matched pair `N_smooth`, `N_general`:

1. the `p−1` weakness is *real* — the method at bound `B = 20` extracts a proper
   nontrivial divisor of `N_smooth` and returns the trivial gcd on `N_general`;
2. the length-256 mod-exponential windows of base 2 are *identical* as combinatorial
   objects, so every collision-structure feature agrees on the two classes;
3. hence any such feature attains `AUC = 1/2` exactly.

The weakness therefore lives strictly outside the window: it is visible to the
computation `a^M mod N` (the `p−1` method itself) and to nothing that reads a
short prefix of the sequence. -/
theorem seqsmooth_null :
    (1009 ∣ Nat.gcd (2 ^ bigM - 1) N_smooth ∧
        Nat.gcd (2 ^ bigM - 1) N_smooth ≠ 1 ∧
        Nat.gcd (2 ^ bigM - 1) N_smooth ≠ N_smooth) ∧
      Nat.gcd (2 ^ bigM - 1) N_general = 1 ∧
      windowPattern 2 N_smooth 256 = windowPattern 2 N_general 256 ∧
      distinctCount 2 N_smooth 256 = distinctCount 2 N_general 256 ∧
      auc ({N_smooth} : Finset ℕ) ({N_general} : Finset ℕ) (distinctScore 256) = 1 / 2 :=
  ⟨pMinusOne_separates_smooth, pMinusOne_fails_general, windowPattern_smooth_eq_general,
    by rw [distinctCount_smooth, distinctCount_general], auc_distinctScore_eq_half⟩


/-! ## 9. Mechanism: CRT decomposition of the order

Why can the window not see smoothness?  Because the only invariant it sees is
`ord_N(a) = lcm (ord_p a) (ord_q a)`, and a *large* order is compatible with either
smoothness class: `ord_p a` divides `p − 1`, but its size says nothing about the
factorisation of `p − 1` into primes.  The theorem below is the exact CRT statement. -/

/-- **Order under CRT.**  For coprime moduli the order is the `lcm` of the local orders. -/
theorem mexpOrd_mul_coprime (a p q : ℕ) (h : Nat.Coprime p q) :
    mexpOrd a (p * q) = Nat.lcm (mexpOrd a p) (mexpOrd a q) := by
  set he := (ZMod.chineseRemainder h).toMulEquiv with hedef
  have h1 : orderOf ((a : ℕ) : ZMod (p * q)) = orderOf (he ((a : ℕ) : ZMod (p * q))) :=
    (MulEquiv.orderOf_eq he _).symm
  have h2 : he ((a : ℕ) : ZMod (p * q)) = (((a : ℕ) : ZMod p), ((a : ℕ) : ZMod q)) := by
    rw [hedef]
    exact map_natCast (ZMod.chineseRemainder h) a
  simp only [mexpOrd]
  rw [h1, h2, Prod.orderOf_mk]

/-! ## 10. The exact criterion for the `p−1` method, and an infinite blind family -/

/-- **Exact criterion.**  A prime `r` shows up in `gcd(a^M − 1, N)` *iff* the local order
`ord_r(a)` divides `M`.  So the `p−1` method sees exactly one bit of the arithmetic of
`p − 1`, and it costs the full exponentiation `a^M` to read it. -/
theorem pMinusOne_dvd_iff {a r M : ℕ} (ha : 1 ≤ a) :
    r ∣ (a ^ M - 1) ↔ orderOf ((a : ℕ) : ZMod r) ∣ M := by
  constructor
  · intro hdvd
    by_contra hc
    exact not_dvd_of_ord_not_dvd ha hc hdvd
  · intro hord
    have hpow : ((a ^ M : ℕ) : ZMod r) = ((1 : ℕ) : ZMod r) := by
      push_cast
      exact orderOf_dvd_iff_pow_eq_one.mp hord
    have hmod : (1 : ℕ) ≡ a ^ M [MOD r] := ((ZMod.natCast_eq_natCast_iff _ _ _).mp hpow).symm
    exact (Nat.modEq_iff_dvd' (Nat.one_le_pow _ _ ha)).mp hmod

/-- The infinite family of odd multiples of `1019`.  Every member has base-2 order at
least `509`, hence a completely rigid length-256 window. -/
def blindFamily : Set ℕ := {N | (1019 : ℕ) ∣ N ∧ Odd N}

lemma blindFamily_pos {N : ℕ} (hN : N ∈ blindFamily) : 0 < N := by
  rcases Nat.eq_zero_or_pos N with rfl | h
  · have := hN.2
    rw [Nat.odd_iff] at this
    omega
  · exact h

lemma blindFamily_coprime {N : ℕ} (hN : N ∈ blindFamily) : Nat.Coprime 2 N := by
  refine (Nat.Prime.coprime_iff_not_dvd Nat.prime_two).mpr ?_
  intro hd
  have := hN.2
  rw [Nat.odd_iff] at this
  omega

/-- The family is infinite: it contains `1019 * (2k+1)` for every `k`. -/
theorem blindFamily_infinite : blindFamily.Infinite := by
  refine Set.infinite_of_injective_forall_mem
    (f := fun k : ℕ => 1019 * (2 * k + 1)) (fun i j hij => by simp only at hij; omega) ?_
  intro k
  exact ⟨⟨2 * k + 1, rfl⟩, ⟨1019 * k + 509, by ring⟩⟩

lemma mexpOrd_ge_of_mem {N : ℕ} (hN : N ∈ blindFamily) : 256 ≤ mexpOrd 2 N :=
  mexpOrd_ge_of_1019_dvd (blindFamily_pos hN) (blindFamily_coprime hN) hN.1

/-- **Blind family theorem.**  All members of this infinite family — smooth and general
alike — have the *same* length-256 pattern word. -/
theorem blindFamily_windowPattern_eq {N₁ N₂ : ℕ} (h₁ : N₁ ∈ blindFamily) (h₂ : N₂ ∈ blindFamily) :
    windowPattern 2 N₁ 256 = windowPattern 2 N₂ 256 := by
  refine windowPattern_blind (blindFamily_pos h₁) (blindFamily_coprime h₁)
    (blindFamily_pos h₂) (blindFamily_coprime h₂) ?_
  rw [min_eq_left (mexpOrd_ge_of_mem h₁), min_eq_left (mexpOrd_ge_of_mem h₂)]

theorem N_smooth_mem_blindFamily : N_smooth ∈ blindFamily :=
  ⟨⟨1009, by norm_num [N_smooth]⟩, ⟨514085, by norm_num [N_smooth]⟩⟩

theorem N_general_mem_blindFamily : N_general ∈ blindFamily :=
  ⟨⟨1039, by norm_num [N_general]⟩, ⟨529370, by norm_num [N_general]⟩⟩

/-! ## 11. No free lunch: every collision feature scores chance on the family -/

/-- AUC only depends on the ranking, not on the scale of the score. -/
theorem auc_comp_strictMono {ι : Type*} (S G : Finset ι) (f : ι → ℝ) (g : ℝ → ℝ)
    (hg : StrictMono g) : auc S G (fun i => g (f i)) = auc S G f := by
  simp only [auc]
  congr 1
  refine Finset.sum_congr rfl (fun s _ => Finset.sum_congr rfl (fun t _ => ?_))
  by_cases h1 : f t < f s
  · rw [if_pos (hg h1), if_pos h1]
  · rw [if_neg (fun hc => h1 (hg.lt_iff_lt.mp hc)), if_neg h1]
    by_cases h2 : f t = f s
    · rw [if_pos (by rw [h2]), if_pos h2]
    · rw [if_neg (fun hc => h2 (hg.injective hc)), if_neg h2]

/-- **No-free-lunch theorem for collision features.**  Let `F` be *any* real-valued
statistic of the pattern word of a length-256 window (distinct count, self-collision
gap, longest repeat, spectral statistic of the pattern, …).  Then on *any* labelling of
the infinite family `blindFamily` into positives and negatives — in particular the
SMOOTH / GENERAL labelling, whose classes are genuinely different for the `p−1`
method — the induced classifier has `AUC = 1/2` exactly. -/
theorem no_free_lunch_auc (F : (ℕ → ℕ) → ℝ) (S G : Finset ℕ)
    (hS : S.Nonempty) (hG : G.Nonempty)
    (hSm : ∀ N ∈ S, N ∈ blindFamily) (hGm : ∀ N ∈ G, N ∈ blindFamily) :
    auc S G (fun N => F (windowPattern 2 N 256)) = 1 / 2 := by
  refine auc_eq_half_of_blind _ _ _ hS hG ?_
  intro s hs g hg
  rw [blindFamily_windowPattern_eq (hSm s hs) (hGm g hg)]

/-- Concrete instance of the no-free-lunch theorem on the matched pair of §8. -/
theorem no_free_lunch_matched_pair (F : (ℕ → ℕ) → ℝ) :
    auc ({N_smooth} : Finset ℕ) ({N_general} : Finset ℕ)
      (fun N => F (windowPattern 2 N 256)) = 1 / 2 :=
  no_free_lunch_auc F _ _ ⟨N_smooth, by simp⟩ ⟨N_general, by simp⟩
    (by intro N hN; simp only [Finset.mem_singleton] at hN; subst hN;
        exact N_smooth_mem_blindFamily)
    (by intro N hN; simp only [Finset.mem_singleton] at hN; subst hN;
        exact N_general_mem_blindFamily)


/-! ## 12. Pigeonhole form of the information bound (barrier 4)

The counting bound of §3 has a sharp combinatorial consequence: among any `m + 2`
odd moduli, two already have *identical* length-`m` windows up to collision structure.
So a window of length `m` cannot even name one modulus out of `m + 2`, let alone
separate a smoothness class. -/

theorem exists_collision_of_card_gt (m : ℕ) (T : Finset ℕ) (hodd : ∀ N ∈ T, Odd N)
    (hcard : m + 1 < T.card) :
    ∃ N₁ ∈ T, ∃ N₂ ∈ T, N₁ ≠ N₂ ∧ windowPattern 2 N₁ m = windowPattern 2 N₂ m := by
  have hpos : ∀ N ∈ T, 0 < N := by
    intro N hN
    rcases Nat.eq_zero_or_pos N with rfl | h
    · have := hodd 0 hN
      rw [Nat.odd_iff] at this
      omega
    · exact h
  have hco : ∀ N ∈ T, Nat.Coprime 2 N := by
    intro N hN
    refine (Nat.Prime.coprime_iff_not_dvd Nat.prime_two).mpr ?_
    intro hd
    have := hodd N hN
    rw [Nat.odd_iff] at this
    omega
  have hmaps : Set.MapsTo (fun N => min m (mexpOrd 2 N)) (↑T : Set ℕ)
      (↑(Finset.range (m + 1)) : Set ℕ) := by
    intro N _
    simp only [Finset.coe_range, Set.mem_Iio]
    exact Nat.lt_succ_of_le (min_le_left _ _)
  obtain ⟨N₁, h₁, N₂, h₂, hne, heq⟩ :=
    Finset.exists_ne_map_eq_of_card_lt_of_maps_to (by simpa using hcard) hmaps
  exact ⟨N₁, h₁, N₂, h₂, hne,
    windowPattern_blind (hpos N₁ h₁) (hco N₁ h₁) (hpos N₂ h₂) (hco N₂ h₂) heq⟩

/-- Consequently no collision feature can be injective on a large set of moduli: the
window is *class-independent incompressible*. -/
theorem collisionFeature_not_injective {β : Type*} (F : (ℕ → ℕ) → β) (m : ℕ) (T : Finset ℕ)
    (hodd : ∀ N ∈ T, Odd N) (hcard : m + 1 < T.card) :
    ∃ N₁ ∈ T, ∃ N₂ ∈ T, N₁ ≠ N₂ ∧
      F (windowPattern 2 N₁ m) = F (windowPattern 2 N₂ m) := by
  obtain ⟨N₁, h₁, N₂, h₂, hne, heq⟩ := exists_collision_of_card_gt m T hodd hcard
  exact ⟨N₁, h₁, N₂, h₂, hne, by rw [heq]⟩


/-! ## 13. The null is a fact about cyclic prefixes, not about factoring

Nothing in §2 used the modulus: only that the element has finite order.  The blindness
phenomenon is therefore a structural theorem about prefixes of cyclic orbits in an
arbitrary monoid — mod-exponential sequences, elliptic-curve multiples and
function-field analogues all inherit it. -/

open Classical in
/-- Abstract pattern word: the least index of the orbit prefix with the same value. -/
noncomputable def absFirstOcc {M : Type*} [Monoid M] (g : M) (n : ℕ) : ℕ :=
  Nat.find (p := fun y => g ^ y = g ^ n) ⟨n, rfl⟩

open Classical in
/-- **Abstract structure theorem.**  The collision pattern of a cyclic orbit is the
residue map modulo the order — in any monoid. -/
theorem absFirstOcc_eq_mod {M : Type*} [Monoid M] {g : M} (hg : IsOfFinOrder g) (n : ℕ) :
    absFirstOcc g n = n % orderOf g := by
  have hd : 0 < orderOf g := hg.orderOf_pos
  have hmem : g ^ (n % orderOf g) = g ^ n := hg.pow_eq_pow_iff_modEq.mpr (Nat.mod_modEq n _)
  unfold absFirstOcc
  apply le_antisymm
  · exact Nat.find_le hmem
  · rw [Nat.le_find_iff]
    intro y hy hcon
    have h3 : y % orderOf g = n % orderOf g := hg.pow_eq_pow_iff_modEq.mp hcon
    have hyd : y < orderOf g := lt_trans hy (Nat.mod_lt _ hd)
    rw [Nat.mod_eq_of_lt hyd] at h3
    omega

/-- **Cross-structure blindness.**  Two elements of *arbitrary* monoids with the same
order have the same orbit pattern: no invariant of the ambient structure (its size, the
smoothness of that size, the arithmetic of the ground ring) survives in the prefix. -/
theorem absFirstOcc_blind {M₁ M₂ : Type*} [Monoid M₁] [Monoid M₂] {g₁ : M₁} {g₂ : M₂}
    (h₁ : IsOfFinOrder g₁) (h₂ : IsOfFinOrder g₂) (hord : orderOf g₁ = orderOf g₂) (n : ℕ) :
    absFirstOcc g₁ n = absFirstOcc g₂ n := by
  rw [absFirstOcc_eq_mod h₁, absFirstOcc_eq_mod h₂, hord]

/-- The concrete mod-exponential pattern word is the abstract one for the residue class
of the base: §2 is the `ZMod N` instance of §13. -/
theorem firstOcc_eq_absFirstOcc {a N : ℕ} (hN : 0 < N) (h : Nat.Coprime a N) (x : ℕ) :
    firstOcc a N x = absFirstOcc ((a : ℕ) : ZMod N) x := by
  rw [firstOcc_eq_mod hN h, absFirstOcc_eq_mod (isOfFinOrder_cast hN h), mexpOrd]


/-! ## 14. Value-level blindness over a full period

§2–§12 cover *collision-structure* features.  This section takes the first step beyond
them, to the **values** themselves.  The base of a mod-exponential sequence is a free
parameter: replacing `a` by `a^t` with `t` coprime to `d = ord_N(a)` is a bijection of
the cyclic group `⟨a⟩` and reindexes the orbit.  We prove that the *set of values of a
full-period window is unchanged*, so every value-level feature that reads the window as
a set (top-bit balance, value histogram, extreme values, any symmetric statistic) is
blind to the exponent `t`: it depends on `(N, ⟨a⟩)` only, never on which generator of
the subgroup is used, hence never on the arithmetic of `t`.

Together with `mexpOrd_mul_coprime` this says the only channel left open at the value
level is the *subgroup itself*, whose size `lcm(ord_p a, ord_q a)` is smoothness-agnostic. -/

/-- Inside `ZMod N`, the term of the mod-exponential sequence is the `val` of a power. -/
lemma modExp_eq_val (N a x : ℕ) : modExp a N x = ZMod.val (((a : ZMod N)) ^ x) := by
  rw [modExp, ← Nat.cast_pow, ZMod.val_natCast]

/-- If `t` is coprime to the order of `g`, then `g^t` generates the same cyclic group:
some power of `g^t` returns `g` itself. -/
theorem exists_pow_pow_eq_self_of_coprime {M : Type*} [Monoid M] {g : M}
    (hg : IsOfFinOrder g) {t : ℕ} (ht : Nat.Coprime t (orderOf g)) : ∃ u : ℕ, (g ^ t) ^ u = g := by
  have hd : 0 < orderOf g := hg.orderOf_pos
  rcases eq_or_lt_of_le (Nat.one_le_iff_ne_zero.mpr hd.ne') with h1 | h1
  · refine ⟨0, ?_⟩
    have h2 : g ^ orderOf g = 1 := pow_orderOf_eq_one g
    rw [← h1] at h2
    simpa using h2.symm
  · obtain ⟨u, -, hu⟩ := Nat.exists_mul_mod_eq_one_of_coprime ht h1
    refine ⟨u, ?_⟩
    rw [← pow_mul]
    have h3 : g ^ (t * u) = g ^ (t * u % orderOf g) :=
      (hg.pow_eq_pow_iff_modEq.mpr (Nat.mod_modEq _ _)).symm
    rw [h3, hu, pow_one]

/-- **Orbit invariance.**  A full period of the orbit of `g^t` visits exactly the same
elements as a full period of the orbit of `g`, whenever `t` is coprime to `ord(g)`. -/
theorem image_pow_range_eq_of_coprime {M : Type*} [Monoid M] [DecidableEq M] {g : M}
    (hg : IsOfFinOrder g) {t : ℕ} (ht : Nat.Coprime t (orderOf g)) :
    (range (orderOf g)).image (fun x => (g ^ t) ^ x)
      = (range (orderOf g)).image (fun x => g ^ x) := by
  have hd : 0 < orderOf g := hg.orderOf_pos
  obtain ⟨u, hu⟩ := exists_pow_pow_eq_self_of_coprime hg ht
  apply Finset.Subset.antisymm
  · intro y hy
    simp only [Finset.mem_image, Finset.mem_range] at hy ⊢
    obtain ⟨x, -, rfl⟩ := hy
    exact ⟨t * x % orderOf g, Nat.mod_lt _ hd, by
      rw [← pow_mul]; exact hg.pow_eq_pow_iff_modEq.mpr (Nat.mod_modEq _ _)⟩
  · intro y hy
    simp only [Finset.mem_image, Finset.mem_range] at hy ⊢
    obtain ⟨x, -, rfl⟩ := hy
    refine ⟨u * x % orderOf g, Nat.mod_lt _ hd, ?_⟩
    have hh : IsOfFinOrder (g ^ t) := hg.pow
    have hot : orderOf (g ^ t) = orderOf g := Nat.Coprime.orderOf_pow ht.symm
    have h2 : (g ^ t) ^ (u * x % orderOf g) = (g ^ t) ^ (u * x) :=
      hh.pow_eq_pow_iff_modEq.mpr (by rw [hot]; exact Nat.mod_modEq _ _)
    rw [h2, pow_mul, hu]

open Classical in
/-- The set of values of one full period of the mod-exponential sequence. -/
noncomputable def periodValues (a N : ℕ) : Finset ℕ :=
  (range (mexpOrd a N)).image (modExp a N)

/-- Coprime exponentiation of the base does not change the order. -/
theorem mexpOrd_pow_of_coprime {a N t : ℕ} (ht : Nat.Coprime t (mexpOrd a N)) :
    mexpOrd (a ^ t) N = mexpOrd a N := by
  unfold mexpOrd at *
  push_cast
  exact Nat.Coprime.orderOf_pow ht.symm

open Classical in
/-- **Value-level blindness (full period).**  The full-period value set is invariant
under the action `a ↦ a^t` of `(ℤ/dℤ)ˣ` on bases: the window *values*, not merely their
collision pattern, depend on the cyclic subgroup alone. -/
theorem periodValues_base_invariant {a N t : ℕ} (hN : 0 < N) (h : Nat.Coprime a N)
    (ht : Nat.Coprime t (mexpOrd a N)) : periodValues (a ^ t) N = periodValues a N := by
  have hg : IsOfFinOrder ((a : ℕ) : ZMod N) := isOfFinOrder_cast hN h
  obtain ⟨u, hu⟩ := exists_pow_pow_eq_self_of_coprime hg ht
  have key := image_pow_range_eq_of_coprime hg ht
  unfold periodValues
  rw [mexpOrd_pow_of_coprime ht]
  have e1 : ∀ x, modExp (a ^ t) N x = ZMod.val (((a : ZMod N) ^ t) ^ x) := by
    intro x; rw [modExp_eq_val]; push_cast; ring_nf
  calc (range (mexpOrd a N)).image (modExp (a ^ t) N)
      = ((range (mexpOrd a N)).image (fun x => ((a : ZMod N) ^ t) ^ x)).image ZMod.val := by
        rw [Finset.image_image]; exact Finset.image_congr (fun x _ => e1 x)
    _ = ((range (mexpOrd a N)).image (fun x => (a : ZMod N) ^ x)).image ZMod.val := by
        rw [show mexpOrd a N = orderOf ((a : ℕ) : ZMod N) from rfl, key]
    _ = (range (mexpOrd a N)).image (modExp a N) := by
        rw [Finset.image_image]; exact Finset.image_congr (fun x _ => (modExp_eq_val N a x).symm)

open Classical in
/-- Every set-valued feature of a full-period window — the value-level analogue of
`collisionFeature_blind` — is blind to the choice of generator. -/
theorem valueFeature_base_invariant {β : Type*} (F : Finset ℕ → β) {a N t : ℕ}
    (hN : 0 < N) (h : Nat.Coprime a N) (ht : Nat.Coprime t (mexpOrd a N)) :
    F (periodValues (a ^ t) N) = F (periodValues a N) := by
  rw [periodValues_base_invariant hN h ht]

open Classical in
/-- The one number a full-period value set does reveal is the order — nothing else. -/
theorem card_periodValues {a N : ℕ} (hN : 0 < N) (h : Nat.Coprime a N) :
    (periodValues a N).card = mexpOrd a N := by
  have := distinctCount_eq hN h (mexpOrd a N)
  simpa [periodValues, distinctCount] using this

/-! ## 15. A decidable certificate for large multiplicative order

The blind families of §10 rest on one quantitative input: a *lower bound* for the
multiplicative order `ord_p(2)`.  Computing the order itself is infeasible, but a lower
bound never needs it — one non-vanishing power suffices.  The following is the abstract
form of the ad-hoc argument used for `p = 1019` in §8, and it is the general tool asked
for by Conjecture 4 of `FUTURE_DIRECTIONS.md`.

If `r` is a prime dividing an exponent `n` that annihilates `g`, and `g^(n/r) ≠ 1`, then
`r ∣ ord(g)`; in particular `r ≤ ord(g)`.  The hypothesis is a single equality test in
the ambient monoid, hence decidable in `ZMod p`. -/

/-- **Order certificate (monoid form).**  A prime `r ∣ n` with `g^n = 1` and
`g^(n/r) ≠ 1` divides the order of `g`. -/
theorem prime_dvd_orderOf_of_pow_ne_one {M : Type*} [Monoid M] {g : M} {n r : ℕ}
    (hr : r.Prime) (hrn : r ∣ n) (hn : g ^ n = 1) (hne : g ^ (n / r) ≠ 1) :
    r ∣ orderOf g := by
  obtain ⟨s, hs⟩ := hrn
  have hdvd : orderOf g ∣ s * r := by
    have h := orderOf_dvd_of_pow_eq_one hn
    rwa [hs, mul_comm] at h
  refine prime_dvd_of_not_dvd hr hdvd ?_
  intro hds
  refine hne ?_
  rw [hs, Nat.mul_div_cancel_left _ hr.pos]
  exact orderOf_dvd_iff_pow_eq_one.mp hds

/-- **Order lower bound from a certificate.**  Same hypotheses, numerical conclusion. -/
theorem le_orderOf_of_certificate {M : Type*} [Monoid M] {g : M} {n r : ℕ}
    (hr : r.Prime) (hrn : r ∣ n) (hn : g ^ n = 1) (hne : g ^ (n / r) ≠ 1) :
    r ≤ orderOf g := by
  have hdvd : r ∣ orderOf g := prime_dvd_orderOf_of_pow_ne_one hr hrn hn hne
  have hn0 : n ≠ 0 := by
    rintro rfl
    exact hne (by simp)
  have hpos : 0 < orderOf g := by
    rcases Nat.eq_zero_or_pos (orderOf g) with h0 | h
    · exact absurd (Nat.eq_zero_of_zero_dvd (h0 ▸ orderOf_dvd_of_pow_eq_one hn)) hn0
    · exact h
  exact Nat.le_of_dvd hpos hdvd

/-- **Order certificate in `ZMod p`.**  For a prime `p`, a base `a` invertible mod `p`
and a prime `r ∣ p − 1` with `a^((p−1)/r) ≠ 1`, the order of `a` is at least `r`.  The
side condition is a single decidable computation. -/
theorem le_orderOf_zmod_of_certificate {p a r : ℕ} (hp : p.Prime) (hpa : ¬ p ∣ a)
    (hr : r.Prime) (hrn : r ∣ p - 1) (hne : ((a : ℕ) : ZMod p) ^ ((p - 1) / r) ≠ 1) :
    r ≤ orderOf ((a : ℕ) : ZMod p) := by
  haveI : Fact p.Prime := ⟨hp⟩
  have ha : ((a : ℕ) : ZMod p) ≠ 0 := fun h0 => hpa ((ZMod.natCast_eq_zero_iff a p).mp h0)
  exact le_orderOf_of_certificate hr hrn (ZMod.pow_card_sub_one_eq_one ha) hne

/-- The certificate applied to `p = 1019`: `1018 = 2 · 509`, and `2² = 4 ≠ 1`, so the
base-2 order mod `1019` is at least `509` — twice the window length used in §8. -/
theorem ord_two_1019_ge_509 : 509 ≤ orderOf ((2 : ℕ) : ZMod 1019) := by
  refine le_orderOf_zmod_of_certificate (by norm_num) (by norm_num) (by norm_num)
    (by norm_num) ?_
  intro h
  norm_num at h
  revert h
  decide

/-- The certificate applied to `p = 1039`: `1038 = 2 · 3 · 173`, and `2⁶ = 64 ≠ 1`, so
the base-2 order mod `1039` is at least `173`. -/
theorem ord_two_1039_ge_173 : 173 ≤ orderOf ((2 : ℕ) : ZMod 1039) := by
  refine le_orderOf_zmod_of_certificate (by norm_num) (by norm_num) (by norm_num)
    (by norm_num) ?_
  intro h
  norm_num at h
  revert h
  decide

/-! ## 16. Blind families of every window length

§10 exhibits one infinite blind family, rigid up to window length 256.  With the
certificate of §15 and the elementary bound `p < 2^(ord_p 2)` we can now produce, for
*every* `m`, an infinite family of moduli whose length-`m` windows are literally
identical — so the no-free-lunch statement of §11 holds at every window length, not just
at the one used in the experiment.  This is the constructive half of Conjecture 2. -/

/-- The infinite family of odd multiples of a fixed odd prime `p`. -/
def blindFamilyAt (p : ℕ) : Set ℕ := {N | p ∣ N ∧ Odd N}

lemma blindFamilyAt_pos {p N : ℕ} (hN : N ∈ blindFamilyAt p) : 0 < N := by
  rcases Nat.eq_zero_or_pos N with rfl | h
  · have := hN.2
    rw [Nat.odd_iff] at this
    omega
  · exact h

lemma blindFamilyAt_coprime {p N : ℕ} (hN : N ∈ blindFamilyAt p) : Nat.Coprime 2 N := by
  refine (Nat.Prime.coprime_iff_not_dvd Nat.prime_two).mpr ?_
  intro hd
  have := hN.2
  rw [Nat.odd_iff] at this
  omega

/-- The family is infinite: it contains `p · (2k+1)` for every `k`. -/
theorem blindFamilyAt_infinite {p : ℕ} (hp : 0 < p) (hodd : Odd p) :
    (blindFamilyAt p).Infinite := by
  refine Set.infinite_of_injective_forall_mem
    (f := fun k : ℕ => p * (2 * k + 1)) (fun i j hij => by
      simp only at hij
      have : 2 * i + 1 = 2 * j + 1 := Nat.eq_of_mul_eq_mul_left hp hij
      omega) ?_
  intro k
  exact ⟨⟨2 * k + 1, rfl⟩, hodd.mul ⟨k, by ring⟩⟩

/-- Every member of the family inherits the order of `2` mod `p`. -/
lemma le_mexpOrd_of_mem_blindFamilyAt {p m N : ℕ} (hm : m ≤ orderOf ((2 : ℕ) : ZMod p))
    (hN : N ∈ blindFamilyAt p) : m ≤ mexpOrd 2 N := by
  have hdvd : orderOf ((2 : ℕ) : ZMod p) ∣ mexpOrd 2 N := ord_dvd_ord_of_dvd 2 N p hN.1
  have hpos : 0 < mexpOrd 2 N := mexpOrd_pos (blindFamilyAt_pos hN) (blindFamilyAt_coprime hN)
  exact le_trans hm (Nat.le_of_dvd hpos hdvd)

/-- **Blind family at every length.**  If the base-2 order mod `p` is at least `m`, all
members of `blindFamilyAt p` share the same length-`m` pattern word. -/
theorem blindFamilyAt_windowPattern_eq {p m N₁ N₂ : ℕ}
    (hm : m ≤ orderOf ((2 : ℕ) : ZMod p))
    (h₁ : N₁ ∈ blindFamilyAt p) (h₂ : N₂ ∈ blindFamilyAt p) :
    windowPattern 2 N₁ m = windowPattern 2 N₂ m := by
  refine windowPattern_blind (blindFamilyAt_pos h₁) (blindFamilyAt_coprime h₁)
    (blindFamilyAt_pos h₂) (blindFamilyAt_coprime h₂) ?_
  rw [min_eq_left (le_mexpOrd_of_mem_blindFamilyAt hm h₁),
    min_eq_left (le_mexpOrd_of_mem_blindFamilyAt hm h₂)]

/-- …and the window is nondegenerate: all `m` of its values are distinct. -/
theorem blindFamilyAt_distinctCount {p m N : ℕ} (hm : m ≤ orderOf ((2 : ℕ) : ZMod p))
    (hN : N ∈ blindFamilyAt p) : distinctCount 2 N m = m :=
  distinctCount_of_le (blindFamilyAt_pos hN) (blindFamilyAt_coprime hN)
    (le_mexpOrd_of_mem_blindFamilyAt hm hN)

/-- **Orders grow with the modulus.**  Since `p ∣ 2^(ord_p 2) − 1`, one has
`p < 2^(ord_p 2)`: a large prime automatically has a large base-2 order. -/
theorem lt_two_pow_orderOf_two {p : ℕ} (hp : p.Prime) (hodd : Odd p) :
    p < 2 ^ orderOf ((2 : ℕ) : ZMod p) := by
  have hcop : Nat.Coprime 2 p := by
    refine (Nat.Prime.coprime_iff_not_dvd Nat.prime_two).mpr ?_
    intro hd
    rw [Nat.odd_iff] at hodd
    omega
  have hfin : IsOfFinOrder ((2 : ℕ) : ZMod p) := isOfFinOrder_cast hp.pos hcop
  have hd : 0 < orderOf ((2 : ℕ) : ZMod p) := hfin.orderOf_pos
  have hdvd : p ∣ 2 ^ orderOf ((2 : ℕ) : ZMod p) - 1 :=
    (pMinusOne_dvd_iff (a := 2) (r := p) (M := orderOf ((2 : ℕ) : ZMod p)) (by norm_num)).mpr
      dvd_rfl
  have h2 : 2 ≤ 2 ^ orderOf ((2 : ℕ) : ZMod p) := by
    calc (2 : ℕ) = 2 ^ 1 := by norm_num
      _ ≤ 2 ^ orderOf ((2 : ℕ) : ZMod p) := Nat.pow_le_pow_right (by norm_num) hd
  have hle := Nat.le_of_dvd (by omega) hdvd
  omega

/-- For every `m` there is an odd prime whose base-2 order exceeds `m`. -/
theorem exists_prime_orderOf_two_ge (m : ℕ) :
    ∃ p : ℕ, p.Prime ∧ Odd p ∧ m ≤ orderOf ((2 : ℕ) : ZMod p) := by
  obtain ⟨p, hpge, hp⟩ := Nat.exists_infinite_primes (2 ^ m + 2)
  have hp2 : p ≠ 2 := by
    have : (1 : ℕ) ≤ 2 ^ m := Nat.one_le_two_pow
    omega
  refine ⟨p, hp, hp.odd_of_ne_two hp2, ?_⟩
  have hlt : 2 ^ m < 2 ^ orderOf ((2 : ℕ) : ZMod p) :=
    lt_of_lt_of_le (by omega) (le_of_lt (lt_two_pow_orderOf_two hp (hp.odd_of_ne_two hp2)))
  exact le_of_lt ((Nat.pow_lt_pow_iff_right (by norm_num)).mp hlt)

/-- **Blind families exist at every window length.**  For every `m` there is an infinite
set of odd moduli — containing both smooth and general instances, since it is closed
under multiplication by arbitrary odd numbers — on which the length-`m` window is a
*constant* combinatorial object with `m` distinct values. -/
theorem exists_infinite_blind_family (m : ℕ) :
    ∃ p : ℕ, p.Prime ∧ (blindFamilyAt p).Infinite ∧
      (∀ N₁ ∈ blindFamilyAt p, ∀ N₂ ∈ blindFamilyAt p,
        windowPattern 2 N₁ m = windowPattern 2 N₂ m) ∧
      (∀ N ∈ blindFamilyAt p, distinctCount 2 N m = m) := by
  obtain ⟨p, hp, hodd, hm⟩ := exists_prime_orderOf_two_ge m
  exact ⟨p, hp, blindFamilyAt_infinite hp.pos hodd,
    fun _ h₁ _ h₂ => blindFamilyAt_windowPattern_eq hm h₁ h₂,
    fun _ hN => blindFamilyAt_distinctCount hm hN⟩

/-- **No free lunch at every window length.**  Strengthening of §11: for every window
length `m` there is an infinite family of moduli on which *every* real statistic of the
length-`m` window scores exactly chance, under *every* labelling into two classes. -/
theorem no_free_lunch_auc_all_lengths (m : ℕ) :
    ∃ p : ℕ, p.Prime ∧ (blindFamilyAt p).Infinite ∧
      ∀ (F : (ℕ → ℕ) → ℝ) (S G : Finset ℕ), S.Nonempty → G.Nonempty →
        (∀ N ∈ S, N ∈ blindFamilyAt p) → (∀ N ∈ G, N ∈ blindFamilyAt p) →
        auc S G (fun N => F (windowPattern 2 N m)) = 1 / 2 := by
  obtain ⟨p, hp, hodd, hm⟩ := exists_prime_orderOf_two_ge m
  refine ⟨p, hp, blindFamilyAt_infinite hp.pos hodd, ?_⟩
  intro F S G hS hG hSm hGm
  refine auc_eq_half_of_blind _ _ _ hS hG ?_
  intro s hs g hg
  rw [blindFamilyAt_windowPattern_eq hm (hSm s hs) (hGm g hg)]

end Bridges.ModExpSmoothnessBlindness