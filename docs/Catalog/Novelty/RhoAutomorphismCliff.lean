import Bridges.CRTSplitNoGoAverage
import Novelty.RhoDetectorBoundary

/-!
# The `gcd(E, p − 1) = 1` automorphism cliff for the rho map `x ↦ x^E + c`

On `ZMod p` the rho map `rhoMap E c x = x ^ E + c` is driven by the power map `x ↦ x ^ E`,
which restricts to an endomorphism of the cyclic group `(ZMod p)ˣ` of order `p − 1`.

## Main results

* `powMap_injective_iff` / `rhoMap_bijective_iff` — for `E ≥ 1`, the rho map is a
  **permutation** of `ZMod p` **iff** `gcd(E, p − 1) = 1`.
* `isRho_orb_of_injective` — for any injective self-map of a finite set the orbit is a *pure
  cycle*: rho-shaped with tail `0` and period equal to the catalog's first closure time
  (`CRTSplitNoGo.closureTime`).  The first collision is a return to the seed.
* `floyd_eq_closureTime_of_injective` — in that regime Floyd's detector stops *exactly* at the
  closure time, sharpening the catalog's factor-2 bound `closureTime_le_two_mul_floyd`.
* `closureTime_rhoMap_le` — **the compression side**: with `d = gcd(E, p − 1)`, every orbit of
  `x ↦ x^E + c` closes within `(p − 1)/d + 2` steps, because the image of the power map has at
  most `(p − 1)/d + 1` elements.
* `closureTime_successor` — **the automorphism side reaches `p`**: for `E = 1, c = 1` every
  orbit has closure time exactly `p`.
* `automorphism_cliff` — the dichotomy packaged: coprime exponent ⇒ every orbit is a pure cycle
  (and Brent beats Floyd strictly on it); every exponent ⇒ the `(p − 1)/d + 2` compression bound.
* `cube_map_permutes_F65537` — the concrete instance behind the measured 104.9× slowdown:
  `x ↦ x³ + c` is a permutation of `ZMod 65537` for every `c`.
-/

namespace RhoCliff

open CRTSplitNoGo RhoBoundary

/-! ## Orbits of injective maps are pure cycles -/

section Orbits

variable {α : Type*} [Fintype α] [DecidableEq α]

omit [DecidableEq α] in
lemma closureTime_pos (a : α) (f : α → α) : 0 < closureTime a f := by
  rcases Nat.eq_zero_or_pos (closureTime a f) with h0 | h0
  · have := closureTime_spec a f
    rw [h0] at this
    exact absurd (fun i hi j hj _ => by omega) this
  · exact h0

omit [DecidableEq α] in
lemma injPrefix_closureTime_pred (a : α) (f : α → α) :
    InjPrefix f a (closureTime a f - 1) := by
  by_contra h
  have h2 : closureTime a f ≤ closureTime a f - 1 := Nat.sInf_le h
  have := closureTime_pos a f
  omega

omit [Fintype α] [DecidableEq α] in
lemma orb_add (f : α → α) (a : α) (i T : ℕ) : orb f a (i + T) = orb f (orb f a T) i := by
  simp [orb, Function.iterate_add_apply]

omit [DecidableEq α] in
/-- For an injective map the first collision is a return to the seed. -/
theorem orb_closureTime_eq_of_injective {f : α → α} (hf : Function.Injective f) (a : α) :
    orb f a (closureTime a f) = a := by
  set T := closureTime a f with hT
  have hpre := injPrefix_closureTime_pred a f
  have hspec := closureTime_spec a f
  rw [← hT] at hpre hspec
  unfold InjPrefix at hspec
  push_neg at hspec
  obtain ⟨i, hi, j, hj, hij, hne⟩ := hspec
  -- reduce to `i < j`
  have key : ∀ i j, i ≤ T → j ≤ T → i < j → orb f a i = orb f a j → orb f a T = a := by
    intro i j hi hj hlt he
    have hjT : j = T := by
      by_contra hc
      exact absurd (hpre i (by omega) j (by omega) he) (by omega)
    subst hjT
    rcases Nat.eq_zero_or_pos i with h0 | h0
    · subst h0; exact he.symm
    · exfalso
      have e1 := orb_succ f a (i - 1)
      rw [Nat.sub_add_cancel h0] at e1
      have e2 := orb_succ f a (T - 1)
      rw [Nat.sub_add_cancel (show 1 ≤ T by omega)] at e2
      rw [e1, e2] at he
      have := hpre (i - 1) (by omega) (T - 1) le_rfl (hf he)
      omega
  rcases lt_or_gt_of_ne hne with h | h
  · exact key i j hi hj h hij
  · exact key j i hj hi h hij.symm

omit [DecidableEq α] in
/-- **Pure-cycle structure.**  The orbit of an injective self-map of a finite set is rho-shaped
with tail `0` and period `closureTime a f`. -/
theorem isRho_orb_of_injective {f : α → α} (hf : Function.Injective f) (a : α) :
    IsRho (orb f a) 0 (closureTime a f) where
  lam_pos := closureTime_pos a f
  periodic := fun i _ => by rw [orb_add, orb_closureTime_eq_of_injective hf]
  inj := fun i j hi hj he =>
    injPrefix_closureTime_pred a f i (by omega) j (by omega) he

omit [DecidableEq α] in
/-- **Floyd is exact on permutations.**  For injective `f`, the tortoise and hare first meet
exactly at the closure time (the catalog bound `closureTime ≤ 2·floyd` is not sharp here: the
two coincide). -/
theorem floyd_eq_closureTime_of_injective {f : α → α} (hf : Function.Injective f) (a : α) :
    orb f a (closureTime a f) = orb f a (2 * closureTime a f) ∧
      ∀ i, 0 < i → i < closureTime a f → orb f a i ≠ orb f a (2 * i) := by
  have h := isRho_orb_of_injective hf a
  obtain ⟨-, h1, h2⟩ := floydIdx_first h
  rw [floydIdx_zero_tail (closureTime_pos a f)] at h1 h2
  exact ⟨h1, h2⟩

end Orbits

/-! ## The power map on `ZMod p` -/

section PowerMap

variable {p : ℕ} [hp : Fact p.Prime]

/-- The Pollard rho map `x ↦ x ^ E + c` on `ZMod p`. -/
def rhoMap (E : ℕ) (c : ZMod p) : ZMod p → ZMod p := fun x => x ^ E + c

/-- A coprime exponent gives an injective power map. -/
theorem powMap_injective_of_coprime {E : ℕ} (hE : 0 < E) (h : Nat.Coprime E (p - 1)) :
    Function.Injective (fun x : ZMod p => x ^ E) := by
  intro x y hxy
  simp only at hxy
  by_cases hx : x = 0
  · subst hx
    rw [zero_pow hE.ne'] at hxy
    exact ((pow_eq_zero_iff hE.ne').1 hxy.symm).symm
  by_cases hy : y = 0
  · subst hy
    rw [zero_pow hE.ne'] at hxy
    exact absurd ((pow_eq_zero_iff hE.ne').1 hxy) hx
  have hcard : Nat.card (ZMod p)ˣ = p - 1 := by
    rw [Nat.card_eq_fintype_card, ZMod.card_units]
  have hc : (Nat.card (ZMod p)ˣ).Coprime E := by rw [hcard]; exact h.symm
  have hu : (powCoprime hc) (Units.mk0 x hx) = (powCoprime hc) (Units.mk0 y hy) := by
    ext
    simp [powCoprime, hxy]
  have := congrArg Units.val ((powCoprime hc).injective hu)
  simpa using this

/-- A non-coprime exponent collapses a nontrivial root of unity onto `1`. -/
theorem coprime_of_powMap_injective {E : ℕ} (h : Function.Injective (fun x : ZMod p => x ^ E)) :
    Nat.Coprime E (p - 1) := by
  by_contra hc
  obtain ⟨r, hr, hrd⟩ := Nat.exists_prime_and_dvd (show Nat.gcd E (p - 1) ≠ 1 from hc)
  have hr1 : r ∣ E := hrd.trans (Nat.gcd_dvd_left _ _)
  have hr2 : r ∣ Fintype.card (ZMod p)ˣ := by
    rw [ZMod.card_units]; exact hrd.trans (Nat.gcd_dvd_right _ _)
  haveI := Fact.mk hr
  obtain ⟨g, hg⟩ := exists_prime_orderOf_dvd_card r hr2
  have hgE : g ^ E = 1 := orderOf_dvd_iff_pow_eq_one.1 (hg ▸ hr1)
  have h1 : (g : ZMod p) = 1 := h (by
    simp only
    rw [← Units.val_pow_eq_pow_val, hgE]
    simp)
  have : g = 1 := Units.ext (by simpa using h1)
  rw [this, orderOf_one] at hg
  exact hr.one_lt.ne' hg.symm

/-- **The cliff criterion.**  For `E ≥ 1`, `x ↦ x^E` is injective on `ZMod p` iff
`gcd(E, p − 1) = 1`. -/
theorem powMap_injective_iff {E : ℕ} (hE : 0 < E) :
    Function.Injective (fun x : ZMod p => x ^ E) ↔ Nat.Coprime E (p - 1) :=
  ⟨coprime_of_powMap_injective, powMap_injective_of_coprime hE⟩

/-- **The rho map is a permutation iff the exponent is coprime to `p − 1`.** -/
theorem rhoMap_bijective_iff {E : ℕ} (hE : 0 < E) (c : ZMod p) :
    Function.Bijective (rhoMap E c) ↔ Nat.Coprime E (p - 1) := by
  rw [← Finite.injective_iff_bijective, ← powMap_injective_iff hE]
  constructor
  · intro h x y hxy
    exact h (show x ^ E + c = y ^ E + c by simp only at hxy; rw [hxy])
  · intro h x y hxy
    exact h (add_right_cancel (show x ^ E + c = y ^ E + c from hxy))

/-- Every nonzero `E`-th power is a `(p − 1)/gcd(E, p − 1)`-th root of unity. -/
lemma pow_pow_compress {E : ℕ} {x : ZMod p} (hx : x ≠ 0) :
    (x ^ E) ^ ((p - 1) / Nat.gcd E (p - 1)) = 1 := by
  set d := Nat.gcd E (p - 1)
  have h1 : E = E / d * d := (Nat.div_mul_cancel (Nat.gcd_dvd_left _ _)).symm
  have h2 : d * ((p - 1) / d) = p - 1 := Nat.mul_div_cancel' (Nat.gcd_dvd_right _ _)
  rw [← pow_mul]
  have : E * ((p - 1) / d) = (p - 1) * (E / d) := by
    conv_lhs => rw [h1]
    rw [Nat.mul_assoc, h2, Nat.mul_comm]
  rw [this, pow_mul, ZMod.pow_card_sub_one_eq_one hx, one_pow]

/-- The compressed target set: `0` together with the `(p − 1)/d`-th roots of unity. -/
noncomputable def compressSet (E : ℕ) : Finset (ZMod p) :=
  insert 0 (Polynomial.nthRoots ((p - 1) / Nat.gcd E (p - 1)) (1 : ZMod p)).toFinset

lemma compress_pos (E : ℕ) : 0 < (p - 1) / Nat.gcd E (p - 1) := by
  have h2 := hp.out.two_le
  apply Nat.div_pos (Nat.gcd_le_right _ (by omega)) (Nat.gcd_pos_of_pos_right _ (by omega))

lemma card_compressSet_le (E : ℕ) :
    (compressSet (p := p) E).card ≤ (p - 1) / Nat.gcd E (p - 1) + 1 := by
  unfold compressSet
  refine (Finset.card_insert_le _ _).trans ?_
  have := (Multiset.toFinset_card_le
    (Polynomial.nthRoots ((p - 1) / Nat.gcd E (p - 1)) (1 : ZMod p))).trans
    (Polynomial.card_nthRoots _ _)
  omega

lemma pow_mem_compressSet {E : ℕ} (hE : 0 < E) (x : ZMod p) : x ^ E ∈ compressSet E := by
  unfold compressSet
  by_cases hx : x = 0
  · subst hx; rw [zero_pow hE.ne']; exact Finset.mem_insert_self _ _
  · apply Finset.mem_insert_of_mem
    rw [Multiset.mem_toFinset, Polynomial.mem_nthRoots (compress_pos E)]
    exact pow_pow_compress hx

/-- **The compression side of the cliff.**  With `d = gcd(E, p − 1)`, every orbit of
`x ↦ x^E + c` on `ZMod p` closes within `(p − 1)/d + 2` steps. -/
theorem closureTime_rhoMap_le {E : ℕ} (hE : 0 < E) (c a : ZMod p) :
    closureTime a (rhoMap E c) ≤ (p - 1) / Nat.gcd E (p - 1) + 2 := by
  set m := (p - 1) / Nat.gcd E (p - 1)
  apply Nat.sInf_le
  show ¬ InjPrefix (rhoMap E c) a (m + 2)
  intro hinj
  have hle : (Finset.range (m + 2)).card ≤ ((compressSet (p := p) E).image (· + c)).card := by
    refine Finset.card_le_card_of_injOn (fun i => orb (rhoMap E c) a (i + 1)) ?_ ?_
    · intro i _
      simp only [Finset.coe_image, Set.mem_image, Finset.mem_coe]
      exact ⟨_, pow_mem_compressSet hE (orb (rhoMap E c) a i), by rw [orb_succ]; rfl⟩
    · intro i hi j hj he
      simp only [Finset.coe_range, Set.mem_Iio] at hi hj
      have := hinj (i + 1) (by omega) (j + 1) (by omega) he
      omega
  have := (Finset.card_image_le (s := compressSet (p := p) E) (f := (· + c))).trans
    (card_compressSet_le (p := p) E)
  rw [Finset.card_range] at hle
  omega

/-- **The automorphism side reaches `p`.**  For the successor map `x ↦ x¹ + 1` (`E = 1`,
coprime to `p − 1`), every orbit has closure time exactly `p` — the `O(p)` end of the cliff. -/
theorem closureTime_successor (a : ZMod p) : closureTime a (rhoMap 1 1) = p := by
  have horb : ∀ i : ℕ, orb (rhoMap 1 1) a i = a + i := by
    intro i
    induction i with
    | zero => simp
    | succ i ih => rw [orb_succ, ih]; simp [rhoMap]; ring
  have hinj : InjPrefix (rhoMap 1 1) a (p - 1) := by
    intro i hi j hj he
    rw [horb, horb] at he
    have he' : ((i : ℕ) : ZMod p) = (j : ℕ) := add_left_cancel he
    rw [ZMod.natCast_eq_natCast_iff'] at he'
    have h2 := hp.out.two_le
    rwa [Nat.mod_eq_of_lt (by omega), Nat.mod_eq_of_lt (by omega)] at he'
  have hlt : p - 1 < closureTime a (rhoMap 1 1) := by
    by_contra hc
    push_neg at hc
    exact closureTime_spec a (rhoMap 1 1)
      (fun i hi j hj he => hinj i (by omega) j (by omega) he)
  have hle : closureTime a (rhoMap 1 1) ≤ p := by
    apply Nat.sInf_le
    show ¬ InjPrefix (rhoMap 1 1) a p
    intro h
    have := h 0 (Nat.zero_le _) p le_rfl (by rw [horb, horb]; simp)
    have h2 := hp.out.two_le
    omega
  have h2 := hp.out.two_le
  omega

/-- **The automorphism cliff (dichotomy).**  For `E ≥ 1` and any `c`:
* if `gcd(E, p − 1) = 1`, every orbit of `x ↦ x^E + c` is a pure cycle (tail `0`, the first
  collision returns to the seed), Floyd stops exactly at the cycle length `T`, and Brent uses at
  most `3T − 1` evaluations against Floyd's `3T`;
* in all cases every orbit closes within `(p − 1)/gcd(E, p − 1) + 2` steps. -/
theorem automorphism_cliff {E : ℕ} (hE : 0 < E) (c : ZMod p) :
    (Nat.Coprime E (p - 1) → ∀ a : ZMod p,
        IsRho (orb (rhoMap E c) a) 0 (closureTime a (rhoMap E c)) ∧
        orb (rhoMap E c) a (closureTime a (rhoMap E c)) = a ∧
        brentEvals 0 (closureTime a (rhoMap E c)) < floydEvals 0 (closureTime a (rhoMap E c))) ∧
    (∀ a : ZMod p, closureTime a (rhoMap E c) ≤ (p - 1) / Nat.gcd E (p - 1) + 2) := by
  refine ⟨fun hc a => ?_, fun a => closureTime_rhoMap_le hE c a⟩
  have hinj : Function.Injective (rhoMap E c) := ((rhoMap_bijective_iff hE c).2 hc).1
  exact ⟨isRho_orb_of_injective hinj a, orb_closureTime_eq_of_injective hinj a,
    brentEvals_lt_floydEvals (closureTime_pos a _)⟩

end PowerMap

/-! ## The concrete instance `p = 65537`, `E = 3` -/

instance fact_prime_65537 : Fact (Nat.Prime 65537) := ⟨by norm_num⟩

/-- `x ↦ x³ + c` permutes `ZMod 65537` for every `c`: `gcd(3, 65536) = 1`, so the cubic rho
walk at the Fermat prime `F₄` runs on pure cycles — the regime of the measured slowdown. -/
theorem cube_map_permutes_F65537 (c : ZMod 65537) : Function.Bijective (rhoMap 3 c) :=
  (rhoMap_bijective_iff (by norm_num) c).2 (by norm_num)

/-- In contrast `x ↦ x² + c` on `ZMod 65537` is never a permutation (`gcd(2, 65536) = 2`), and
every orbit closes within `32769 + 2` steps by the compression bound. -/
theorem square_map_compresses_F65537 (c a : ZMod 65537) :
    ¬ Function.Bijective (rhoMap 2 c) ∧ closureTime a (rhoMap 2 c) ≤ 32770 := by
  refine ⟨fun h => ?_, ?_⟩
  · have := (rhoMap_bijective_iff (by norm_num) c).1 h
    norm_num at this
  · have := closureTime_rhoMap_le (p := 65537) (E := 2) (by norm_num) c a
    norm_num at this
    omega

end RhoCliff