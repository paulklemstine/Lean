import Mathlib

/-!
# Taxicab numbers: representation sets, scaling structure, and a sharper growth floor

This file develops the combinatorial geometry of the *positive orthant* of the affine
Fermat cubic `x³ + y³ = N`: the lattice points with `1 ≤ x ≤ y` on this curve are exactly
the (unordered) representations of `N` as a sum of two positive cubes.

Main results.

* `mem_cubeReps` — the finite box `[1,N]²` already contains every representation,
  so `cubeReps N` is an honest model of the representation set.
* `cubeReps_1729` and `cubeReps_card_le_one_of_lt_1729` — the Hardy–Ramanujan theorem
  in its sharp form: `1729` is the *least* number with two representations
  (`Taxicab 2 = 1729`).
* `cubeScale_image_eq` / `cubeReps_card_le_scaled` — the scaling map `(a,b) ↦ (ma, mb)`
  identifies `cubeReps N` with exactly the `m`-divisible part of `cubeReps (m³N)`.
* `cube_core_conjecture_false` — a refutation: the representation count of `m³ · N₀`
  is *not* the representation count of its cube-free core `N₀`
  (`344 = 2³ · 43`, with `r(344) = 1 > 0 = r(43)`).
* `cubeReps_card_growth` — a sharpened elementary lower bound: a number with `n`
  representations is at least `110 (n-1)³`, improving the pigeonhole bound `n³`
  by an asymptotic factor of `110` (see `cubeReps_card_growth_cubic`).
-/

namespace Taxicab

open Finset

/-- The set of representations of `N` as an ordered pair `a ≤ b` of positive cubes.
The ambient box `[1,N]²` is harmless: every representation lies inside it
(see `mem_cubeReps`). -/
def cubeReps (N : ℕ) : Finset (ℕ × ℕ) :=
  ((Finset.Icc 1 N) ×ˢ (Finset.Icc 1 N)).filter fun p => p.1 ≤ p.2 ∧ p.1 ^ 3 + p.2 ^ 3 = N

/-- Membership in `cubeReps` is exactly "being a representation": the box is not a
restriction, because `a ≤ a³ ≤ N`. -/
@[simp] theorem mem_cubeReps {N : ℕ} {p : ℕ × ℕ} :
    p ∈ cubeReps N ↔ 0 < p.1 ∧ p.1 ≤ p.2 ∧ p.1 ^ 3 + p.2 ^ 3 = N := by
  simp only [cubeReps, Finset.mem_filter, Finset.mem_product, Finset.mem_Icc]
  constructor
  · rintro ⟨⟨⟨h1, _⟩, _⟩, h5, h6⟩
    exact ⟨h1, h5, h6⟩
  · rintro ⟨h1, h2, h3⟩
    have hb : 0 < p.2 := lt_of_lt_of_le h1 h2
    have h4 : p.1 ≤ p.1 ^ 3 := Nat.le_self_pow (by norm_num) _
    have h5 : p.2 ≤ p.2 ^ 3 := Nat.le_self_pow (by norm_num) _
    exact ⟨⟨⟨h1, by omega⟩, hb, by omega⟩, h2, h3⟩

/-- A representation is determined by its larger summand. -/
theorem cubeReps_snd_injOn (N : ℕ) :
    Set.InjOn Prod.snd (cubeReps N : Set (ℕ × ℕ)) := by
  rintro ⟨a, b⟩ hp ⟨c, d⟩ hq h
  simp only [Finset.mem_coe, mem_cubeReps] at hp hq
  simp only at h
  subst h
  have : a ^ 3 = c ^ 3 := by omega
  have : a = c := Nat.pow_left_injective (by norm_num) this
  simp [this]

/-! ## Hardy–Ramanujan: `Taxicab 2 = 1729` -/

/-- Every representation of a number `< 1729` (indeed of any `N ≤ 1728`) has both
summands at most `12`. -/
theorem cubeReps_bound_of_lt {N : ℕ} (hN : N < 1729) {p : ℕ × ℕ} (hp : p ∈ cubeReps N) :
    1 ≤ p.1 ∧ p.1 ≤ 12 ∧ 1 ≤ p.2 ∧ p.2 ≤ 12 := by
  rw [mem_cubeReps] at hp
  obtain ⟨h1, h2, h3⟩ := hp
  refine ⟨h1, ?_, by omega, ?_⟩
  · by_contra h
    have : 13 ^ 3 ≤ p.1 ^ 3 := Nat.pow_le_pow_left (by omega) 3
    omega
  · by_contra h
    have : 13 ^ 3 ≤ p.2 ^ 3 := Nat.pow_le_pow_left (by omega) 3
    omega

set_option maxRecDepth 40000 in
/-- The exhaustive box computation behind the Hardy–Ramanujan minimality statement:
inside the box `[1,12]²` no value below `1729` is hit twice. -/
private theorem box_unique :
    ∀ p ∈ (Finset.Icc 1 12 ×ˢ Finset.Icc 1 12), ∀ q ∈ (Finset.Icc 1 12 ×ˢ Finset.Icc 1 12),
      p.1 ^ 3 + p.2 ^ 3 = q.1 ^ 3 + q.2 ^ 3 → p.1 ^ 3 + p.2 ^ 3 < 1729 →
      p.1 ≤ p.2 → q.1 ≤ q.2 → p = q := by decide

/-- **Minimality half of Hardy–Ramanujan.** No positive integer below `1729` has two
essentially different representations as a sum of two positive cubes. -/
theorem cubeReps_card_le_one_of_lt_1729 {N : ℕ} (hN : N < 1729) :
    (cubeReps N).card ≤ 1 := by
  rw [Finset.card_le_one]
  intro p hp q hq
  have hp' := cubeReps_bound_of_lt hN hp
  have hq' := cubeReps_bound_of_lt hN hq
  rw [mem_cubeReps] at hp hq
  refine box_unique p ?_ q ?_ (by omega) (by omega) hp.2.1 hq.2.1
  · simp only [Finset.mem_product, Finset.mem_Icc]; omega
  · simp only [Finset.mem_product, Finset.mem_Icc]; omega

set_option maxRecDepth 10000 in
/-- **Hardy–Ramanujan.** `1729 = 1³ + 12³ = 9³ + 10³`, and these are its only
representations. -/
theorem cubeReps_1729 : cubeReps 1729 = {(1, 12), (9, 10)} := by
  ext p
  rw [mem_cubeReps]
  constructor
  · intro hp
    have hb : 1 ≤ p.1 ∧ p.1 ≤ 12 ∧ 1 ≤ p.2 ∧ p.2 ≤ 12 := by
      refine ⟨hp.1, ?_, by omega, ?_⟩
      · by_contra h
        have h1 : 13 ^ 3 ≤ p.1 ^ 3 := Nat.pow_le_pow_left (by omega) 3
        have h2 : 1 ≤ p.2 ^ 3 := Nat.one_le_pow _ _ (by omega)
        omega
      · by_contra h
        have h1 : 13 ^ 3 ≤ p.2 ^ 3 := Nat.pow_le_pow_left (by omega) 3
        omega
    have hmem : p ∈ (Finset.Icc 1 12 ×ˢ Finset.Icc 1 12).filter
        (fun q => q.1 ≤ q.2 ∧ q.1 ^ 3 + q.2 ^ 3 = 1729) := by
      simp only [Finset.mem_filter, Finset.mem_product, Finset.mem_Icc]
      exact ⟨⟨⟨hb.1, hb.2.1⟩, hb.2.2⟩, hp.2⟩
    have hcalc : (Finset.Icc 1 12 ×ˢ Finset.Icc 1 12).filter
        (fun q => q.1 ≤ q.2 ∧ q.1 ^ 3 + q.2 ^ 3 = 1729) = {(1, 12), (9, 10)} := by decide
    rw [hcalc] at hmem
    exact hmem
  · intro hp
    simp only [Finset.mem_insert, Finset.mem_singleton] at hp
    rcases hp with h | h <;> subst h <;> norm_num

theorem cubeReps_card_1729 : (cubeReps 1729).card = 2 := by
  rw [cubeReps_1729]; decide

/-- `Taxicab 2 = 1729`, packaged: `1729` has two representations and nothing smaller has. -/
theorem taxicab_two_eq_1729 :
    2 ≤ (cubeReps 1729).card ∧ ∀ N < 1729, (cubeReps N).card < 2 := by
  refine ⟨by rw [cubeReps_card_1729], fun N hN => ?_⟩
  have := cubeReps_card_le_one_of_lt_1729 hN
  omega

/-! ## Scaling by cubes: the exact structure theorem -/

/-- Scaling a representation of `N` by `m` gives a representation of `m³N`. -/
theorem cubeScale_mem {N m : ℕ} (hm : 0 < m) {p : ℕ × ℕ} (hp : p ∈ cubeReps N) :
    (m * p.1, m * p.2) ∈ cubeReps (m ^ 3 * N) := by
  rw [mem_cubeReps] at hp ⊢
  refine ⟨Nat.mul_pos hm hp.1, Nat.mul_le_mul_left _ hp.2.1, ?_⟩
  have hexp : (m * p.1) ^ 3 + (m * p.2) ^ 3 = m ^ 3 * (p.1 ^ 3 + p.2 ^ 3) := by ring
  rw [hexp, hp.2.2]

/-- **Structure theorem for cube scaling.** The representations of `m³N` all of whose
summands are divisible by `m` are exactly the `m`-multiples of representations of `N`. -/
theorem cubeScale_image_eq {N m : ℕ} (hm : 0 < m) :
    (cubeReps (m ^ 3 * N)).filter (fun p => m ∣ p.1 ∧ m ∣ p.2)
      = (cubeReps N).image (fun p => (m * p.1, m * p.2)) := by
  ext p
  obtain ⟨x, y⟩ := p
  simp only [Finset.mem_filter, Finset.mem_image, mem_cubeReps]
  constructor
  · rintro ⟨⟨h1, h2, h3⟩, ⟨a, ha⟩, ⟨b, hb⟩⟩
    subst ha
    subst hb
    refine ⟨(a, b), ⟨?_, ?_, ?_⟩, ?_⟩
    · rcases Nat.eq_zero_or_pos a with h | h
      · simp [h] at h1
      · exact h
    · exact Nat.le_of_mul_le_mul_left h2 hm
    · have hm3 : 0 < m ^ 3 := by positivity
      have hkey : m ^ 3 * (a ^ 3 + b ^ 3) = m ^ 3 * N := by
        rw [← h3]; ring
      exact Nat.eq_of_mul_eq_mul_left hm3 hkey
    · rfl
  · rintro ⟨⟨a, b⟩, hab, heq⟩
    have hab' : (a, b) ∈ cubeReps N := by rw [mem_cubeReps]; exact hab
    have := cubeScale_mem hm hab'
    simp only [Prod.mk.injEq] at heq
    obtain ⟨rfl, rfl⟩ := heq
    rw [mem_cubeReps] at this
    exact ⟨this, ⟨a, rfl⟩, ⟨b, rfl⟩⟩

/-- Scaling never loses representations: `r(N) ≤ r(m³N)`. -/
theorem cubeReps_card_le_scaled {N m : ℕ} (hm : 0 < m) :
    (cubeReps N).card ≤ (cubeReps (m ^ 3 * N)).card := by
  have hinj : Set.InjOn (fun p : ℕ × ℕ => (m * p.1, m * p.2)) (cubeReps N : Set (ℕ × ℕ)) := by
    rintro ⟨a, b⟩ _ ⟨c, d⟩ _ h
    simp only [Prod.mk.injEq] at h
    have h1 : a = c := Nat.eq_of_mul_eq_mul_left hm h.1
    have h2 : b = d := Nat.eq_of_mul_eq_mul_left hm h.2
    simp [h1, h2]
  calc (cubeReps N).card = ((cubeReps N).image (fun p => (m * p.1, m * p.2))).card :=
        (Finset.card_image_of_injOn hinj).symm
    _ = ((cubeReps (m ^ 3 * N)).filter (fun p => m ∣ p.1 ∧ m ∣ p.2)).card := by
        rw [cubeScale_image_eq hm]
    _ ≤ (cubeReps (m ^ 3 * N)).card := Finset.card_filter_le _ _

/-! ## Refutation of the "cube-free core" conjecture -/

theorem cubeReps_43 : cubeReps 43 = ∅ := by
  ext p
  simp only [mem_cubeReps, Finset.notMem_empty, iff_false]
  rintro ⟨h1, h2, h3⟩
  have hb : p.2 ≤ 3 := by
    by_contra h
    have : 4 ^ 3 ≤ p.2 ^ 3 := Nat.pow_le_pow_left (by omega) 3
    omega
  have hmem : p ∈ (Finset.Icc 1 3 ×ˢ Finset.Icc 1 3).filter
      (fun q => q.1 ≤ q.2 ∧ q.1 ^ 3 + q.2 ^ 3 = 43) := by
    simp only [Finset.mem_filter, Finset.mem_product, Finset.mem_Icc]
    exact ⟨⟨⟨h1, by omega⟩, by omega, hb⟩, h2, h3⟩
  have hcalc : (Finset.Icc 1 3 ×ˢ Finset.Icc 1 3).filter
      (fun q => q.1 ≤ q.2 ∧ q.1 ^ 3 + q.2 ^ 3 = 43) = ∅ := by decide
  rw [hcalc] at hmem
  exact absurd hmem (Finset.notMem_empty p)

set_option maxRecDepth 10000 in
theorem cubeReps_344 : cubeReps 344 = {(1, 7)} := by
  ext p
  rw [mem_cubeReps]
  constructor
  · intro hp
    have hb : p.2 ≤ 7 := by
      by_contra h
      have : 8 ^ 3 ≤ p.2 ^ 3 := Nat.pow_le_pow_left (by omega) 3
      omega
    have ha : p.1 ≤ 7 := le_trans hp.2.1 hb
    have h1 : 1 ≤ p.1 := hp.1
    have hmem : p ∈ (Finset.Icc 1 7 ×ˢ Finset.Icc 1 7).filter
        (fun q => q.1 ≤ q.2 ∧ q.1 ^ 3 + q.2 ^ 3 = 344) := by
      simp only [Finset.mem_filter, Finset.mem_product, Finset.mem_Icc]
      exact ⟨⟨⟨h1, ha⟩, by omega, hb⟩, hp.2⟩
    have hcalc : (Finset.Icc 1 7 ×ˢ Finset.Icc 1 7).filter
        (fun q => q.1 ≤ q.2 ∧ q.1 ^ 3 + q.2 ^ 3 = 344) = {(1, 7)} := by decide
    rw [hcalc] at hmem
    exact hmem
  · intro hp
    simp only [Finset.mem_singleton] at hp
    subst hp
    norm_num

/-- **The cube-free core conjecture is false.** `344 = 2³ · 43` with `43` cube-free,
yet `344` has a representation as a sum of two positive cubes while `43` has none.
Hence the representation count is *not* an invariant of the cube-free core, and the
scaling injection `cubeReps_card_le_scaled` is in general strict. -/
theorem cube_core_conjecture_false :
    (344 : ℕ) = 2 ^ 3 * 43 ∧ (cubeReps 43).card = 0 ∧ (cubeReps (2 ^ 3 * 43)).card = 1 := by
  refine ⟨by norm_num, ?_, ?_⟩
  · rw [cubeReps_43]; rfl
  · norm_num
    rw [cubeReps_344]
    rfl

/-! ## A sharper growth floor -/

/-- The arithmetic heart of the growth bound: if the shell `[s, s+j]` of larger summands
satisfies `(s+j)³ ≤ N ≤ 2s³`, then the shell is narrow. A first squeeze gives `s ≥ 3j`;
feeding that back into the same inequality gives `5s ≥ 19j`, whence `N ≥ 110 j³`.
(The optimal constant of this method is `(1 + 2^{1/3}/(2^{1/3}-1))³ ≈ 113.9`.) -/
private theorem shell_bound {N s m j : ℕ} (hspos : 0 < s) (hmj : m = s + j)
    (hupper : m ^ 3 ≤ N) (hlower : N ≤ 2 * s ^ 3) : 110 * j ^ 3 ≤ N := by
  subst hmj
  rcases Nat.eq_zero_or_pos j with rfl | hjpos
  · simp
  have hkey : (s + j) ^ 3 ≤ 2 * s ^ 3 := le_trans hupper hlower
  have hexp : 3 * s ^ 2 * j + 3 * s * j ^ 2 + j ^ 3 ≤ s ^ 3 := by nlinarith [hkey]
  -- first squeeze
  have h3j : 3 * j ≤ s := by
    by_contra hc
    push_neg at hc
    have h1 : s ^ 2 * (s + 1) ≤ s ^ 2 * (3 * j) := Nat.mul_le_mul_left _ (by omega)
    nlinarith [hexp, h1, hspos]
  -- second squeeze: write `s = 3j + r` and bound `r` from below
  obtain ⟨r, hr⟩ : ∃ r, s = 3 * j + r := ⟨s - 3 * j, by omega⟩
  subst hr
  have hexp10 : 10 * j ^ 3 ≤ 6 * j ^ 2 * r + 6 * j * r ^ 2 + r ^ 3 := by nlinarith [hexp]
  have h45 : 4 * j ≤ 5 * r := by
    by_contra hc
    push_neg at hc
    have h5 : 5 * r + 1 ≤ 4 * j := by omega
    have h1 : 150 * j ^ 2 * (5 * r + 1) ≤ 150 * j ^ 2 * (4 * j) := Nat.mul_le_mul_left _ h5
    have h2 : 30 * j * (5 * r + 1) ^ 2 ≤ 30 * j * (4 * j) ^ 2 :=
      Nat.mul_le_mul_left _ (Nat.pow_le_pow_left h5 2)
    have h3 : (5 * r + 1) ^ 3 ≤ (4 * j) ^ 3 := Nat.pow_le_pow_left h5 3
    nlinarith [hexp10, h1, h2, h3, hjpos]
  -- conclude
  have hbig : (24 * j) ^ 3 ≤ (5 * (3 * j + r + j)) ^ 3 := Nat.pow_le_pow_left (by omega) 3
  have hexpand : (5 * (3 * j + r + j)) ^ 3 = 125 * (3 * j + r + j) ^ 3 := by ring
  have h125 : 125 * (110 * j ^ 3) ≤ 125 * N := by
    have : (24 * j) ^ 3 = 13824 * j ^ 3 := by ring
    nlinarith [hbig, hexpand, hupper, this]
  omega

/-- **Sharpened pigeonhole bound.** If `N` admits at least `n` representations as a sum of
two positive cubes then `N ≥ 110 (n-1)³`.

The proof is a geometric squeeze on the larger summands: they are `n` distinct integers
`b` lying in the shell `N/2 ≤ b³ ≤ N`, so the shell must be at least `n-1` wide, which
forces its inner radius to be at least `19(n-1)/5`, and hence `N ≥ 110 (n-1)³`. -/
theorem cubeReps_card_growth (N n : ℕ) (h : n ≤ (cubeReps N).card) :
    110 * (n - 1) ^ 3 ≤ N := by
  rcases Nat.lt_or_ge n 2 with hn | hn
  · interval_cases n <;> simp
  have hTcard : ((cubeReps N).image Prod.snd).card = (cubeReps N).card :=
    Finset.card_image_of_injOn (cubeReps_snd_injOn N)
  have hTne : ((cubeReps N).image Prod.snd).Nonempty := by
    rw [← Finset.card_pos, hTcard]; omega
  -- the larger summand of every representation determines the whole representation
  have key : ∀ x ∈ (cubeReps N).image Prod.snd, ∃ a, 0 < a ∧ a ≤ x ∧ a ^ 3 + x ^ 3 = N := by
    intro x hx
    obtain ⟨p, hp, rfl⟩ := Finset.mem_image.mp hx
    rw [mem_cubeReps] at hp
    exact ⟨p.1, hp.1, hp.2.1, hp.2.2⟩
  obtain ⟨s, hs⟩ : ∃ s, ((cubeReps N).image Prod.snd).min' hTne = s := ⟨_, rfl⟩
  obtain ⟨m, hm⟩ : ∃ m, ((cubeReps N).image Prod.snd).max' hTne = m := ⟨_, rfl⟩
  have hsmem : s ∈ (cubeReps N).image Prod.snd := hs ▸ Finset.min'_mem _ hTne
  have hmmem : m ∈ (cubeReps N).image Prod.snd := hm ▸ Finset.max'_mem _ hTne
  have hsub : (cubeReps N).image Prod.snd ⊆ Finset.Icc s m := by
    intro x hx
    simp only [Finset.mem_Icc]
    exact ⟨hs ▸ Finset.min'_le _ x hx, hm ▸ Finset.le_max' _ x hx⟩
  have hcard_le : ((cubeReps N).image Prod.snd).card ≤ m + 1 - s := by
    have := Finset.card_le_card hsub
    simpa [Nat.card_Icc] using this
  have hsm : s ≤ m := by
    have := hsub hsmem
    simp only [Finset.mem_Icc] at this
    exact this.2
  obtain ⟨a, ha0, hasm, haeq⟩ := key s hsmem
  obtain ⟨c, hc0, hcm, hceq⟩ := key m hmmem
  have hupper : m ^ 3 ≤ N := by omega
  have hlower : N ≤ 2 * s ^ 3 := by
    have h2 : a ^ 3 ≤ s ^ 3 := Nat.pow_le_pow_left hasm 3
    omega
  have hspos : 0 < s := lt_of_lt_of_le ha0 hasm
  have hjn : n - 1 ≤ m - s := by omega
  have hfinal := shell_bound (m := m) (j := m - s) hspos (by omega) hupper hlower
  calc 110 * (n - 1) ^ 3 ≤ 110 * (m - s) ^ 3 :=
        Nat.mul_le_mul_left _ (Nat.pow_le_pow_left hjn 3)
    _ ≤ N := hfinal

/-- The sharpened bound dominates the elementary cubic floor `N > n³` for all `n ≥ 2`. -/
theorem cubeReps_card_growth_cubic (N n : ℕ) (hn : 2 ≤ n) (h : n ≤ (cubeReps N).card) :
    n ^ 3 < N := by
  have hb := cubeReps_card_growth N n h
  obtain ⟨k, rfl⟩ : ∃ k, n = k + 1 := ⟨n - 1, by omega⟩
  simp only [Nat.add_sub_cancel] at hb
  have hk : 1 ≤ k := by omega
  have h1 : (k + 1) ^ 3 ≤ (2 * k) ^ 3 := Nat.pow_le_pow_left (by omega) 3
  nlinarith [hb, h1, hk]

end Taxicab