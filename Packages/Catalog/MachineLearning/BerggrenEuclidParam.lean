import MachineLearning.BerggrenTreeStars

/-!
# Euclid coordinates for the Berggren tree, and a self-contained completeness theorem

The catalog's `MachineLearning/BerggrenTreeCompleteness.lean` attempts to prove the
Barning–Hall completeness theorem by a descent carried out directly on the triple
`(a, b, c)`.  That file does **not** compile: it quotes `invB1`, `invB2`, `invB3` and
`parent_exists` from `Shared/BerggrenTrees/Parent_hyp_lt.lean`, where `parent_exists` is
commented out (and the three inverse branches were never defined anywhere in the catalog).

This file supplies a complete, compiling replacement, obtained by moving the whole
discussion to *Euclid coordinates*.  Writing a node as `euclidTriple m n =
(m² - n², 2mn, m² + n²)`, the three Berggren generators become the **linear** maps

```
A : (m, n) ↦ (2m - n, m),   B : (m, n) ↦ (2m + n, m),   C : (m, n) ↦ (m + 2n, n),
```

i.e. exactly the three branches of the Stern–Brocot / Farey tree on coprime pairs.  The
descent then becomes a trichotomy on the position of `m` relative to `2n` and `3n`, and
the two degenerate cases `m = 2n`, `m = 3n` are eliminated by coprimality and parity.

## Main results

* `mA_euclid`, `mB_euclid`, `mC_euclid` — the generators in Euclid coordinates.
* `param_A`, `param_B`, `param_C` — admissible parameters are preserved.
* `isNode_iff_param` — the nodes of the tree are exactly the `euclidTriple m n` with
  `IsParam m n` (both directions; the hard direction is the descent).
* `isNode_iff` — **Barning–Hall**: the nodes of the tree are exactly the positive
  primitive Pythagorean triples with odd first leg.
* `isNodeSwap_iff` — the mirrored tree (seed `(4,3,5)`) gives exactly the positive
  primitive Pythagorean triples with *even* first leg.
* `isPPT_iff_node_or_swap` — the two seeds together give *every* positive primitive
  Pythagorean triple, exactly once.
-/

namespace BerggrenStars

open scoped Classical

/-! ### Euclid coordinates -/

/-- Euclid's parametrisation of Pythagorean triples. -/
def euclidTriple (m n : ℤ) : Vec := (m ^ 2 - n ^ 2, 2 * m * n, m ^ 2 + n ^ 2)

/-- Admissible Euclid parameters: `0 < n < m`, coprime, of opposite parity. -/
structure IsParam (m n : ℤ) : Prop where
  npos : 0 < n
  lt : n < m
  cop : Int.gcd m n = 1
  par : Odd (m - n)

theorem IsParam.mpos {m n : ℤ} (h : IsParam m n) : 0 < m := lt_trans h.npos h.lt

theorem euclidTriple_onCone (m n : ℤ) : OnCone (euclidTriple m n) := by
  simp only [OnCone, qform, bil, euclidTriple]
  ring

theorem euclid_root : euclidTriple 2 1 = root := by
  simp only [euclidTriple, root]
  norm_num

theorem param_root : IsParam 2 1 :=
  ⟨one_pos, one_lt_two, by decide, ⟨0, by ring⟩⟩

/-- The parameters of a node determine it, and conversely. -/
theorem euclidTriple_injective {m n m' n' : ℤ} (hm : 0 < m) (hn : 0 < n) (hm' : 0 < m')
    (hn' : 0 < n') (h : euclidTriple m n = euclidTriple m' n') : m = m' ∧ n = n' := by
  simp only [euclidTriple, Prod.mk.injEq] at h
  obtain ⟨h1, -, h3⟩ := h
  have hmm : m ^ 2 = m' ^ 2 := by linarith
  have hnn : n ^ 2 = n' ^ 2 := by linarith
  constructor
  · nlinarith
  · nlinarith

/-! ### The generators in Euclid coordinates -/

theorem mA_euclid (m n : ℤ) : mA (euclidTriple m n) = euclidTriple (2 * m - n) m := by
  simp only [mA, euclidTriple, Prod.mk.injEq]
  refine ⟨by ring, by ring, by ring⟩

theorem mB_euclid (m n : ℤ) : mB (euclidTriple m n) = euclidTriple (2 * m + n) m := by
  simp only [mB, euclidTriple, Prod.mk.injEq]
  refine ⟨by ring, by ring, by ring⟩

theorem mC_euclid (m n : ℤ) : mC (euclidTriple m n) = euclidTriple (m + 2 * n) n := by
  simp only [mC, euclidTriple, Prod.mk.injEq]
  refine ⟨by ring, by ring, by ring⟩

/-! ### Admissibility is preserved -/

private theorem odd_sub_of_odd_add {x y : ℤ} (h : Odd (x - y)) : Odd (x + y) := by
  obtain ⟨t, ht⟩ := h
  exact ⟨t + y, by linarith⟩

theorem param_A {m n : ℤ} (h : IsParam m n) : IsParam (2 * m - n) m := by
  refine ⟨h.mpos, by linarith [h.lt], ?_, ?_⟩
  · have hc : IsCoprime m n := Int.isCoprime_iff_gcd_eq_one.mpr h.cop
    have : IsCoprime (-n + m * 2) m := ((hc.symm.neg_left).add_mul_left_left 2)
    have he : -n + m * 2 = 2 * m - n := by ring
    rw [he] at this
    exact Int.isCoprime_iff_gcd_eq_one.mp this
  · have : 2 * m - n - m = m - n := by ring
    rw [this]; exact h.par

theorem param_B {m n : ℤ} (h : IsParam m n) : IsParam (2 * m + n) m := by
  refine ⟨h.mpos, by linarith [h.npos, h.mpos], ?_, ?_⟩
  · have hc : IsCoprime m n := Int.isCoprime_iff_gcd_eq_one.mpr h.cop
    have : IsCoprime (n + m * 2) m := (hc.symm.add_mul_left_left 2)
    have he : n + m * 2 = 2 * m + n := by ring
    rw [he] at this
    exact Int.isCoprime_iff_gcd_eq_one.mp this
  · have : 2 * m + n - m = m + n := by ring
    rw [this]; exact odd_sub_of_odd_add h.par

theorem param_C {m n : ℤ} (h : IsParam m n) : IsParam (m + 2 * n) n := by
  refine ⟨h.npos, by linarith [h.lt, h.npos], ?_, ?_⟩
  · have hc : IsCoprime m n := Int.isCoprime_iff_gcd_eq_one.mpr h.cop
    have h2 : IsCoprime (m + n * 2) n := (hc.add_mul_left_left 2)
    have he : m + n * 2 = m + 2 * n := by ring
    rw [he] at h2
    exact Int.isCoprime_iff_gcd_eq_one.mp h2
  · have : m + 2 * n - n = m + n := by ring
    rw [this]; exact odd_sub_of_odd_add h.par

/-! ### Nodes of the Berggren tree -/

/-- The Berggren monoid orbit of a seed `s`. -/
def Orbit (s v : Vec) : Prop := ∃ W : List (Vec → Vec), IsBerggrenWord W ∧ applyWord W s = v

theorem orbit_self (s : Vec) : Orbit s s := ⟨[], by intro f hf; simp at hf, rfl⟩

theorem Orbit.mA {s v : Vec} (h : Orbit s v) : Orbit s (mA v) := by
  obtain ⟨W, hW, hv⟩ := h
  exact ⟨_root_.BerggrenStars.mA :: W, fun f hf => by
    rcases List.mem_cons.mp hf with rfl | hf'
    · exact Or.inl rfl
    · exact hW f hf', by rw [applyWord_cons, hv]⟩

theorem Orbit.mB {s v : Vec} (h : Orbit s v) : Orbit s (mB v) := by
  obtain ⟨W, hW, hv⟩ := h
  exact ⟨_root_.BerggrenStars.mB :: W, fun f hf => by
    rcases List.mem_cons.mp hf with rfl | hf'
    · exact Or.inr (Or.inl rfl)
    · exact hW f hf', by rw [applyWord_cons, hv]⟩

theorem Orbit.mC {s v : Vec} (h : Orbit s v) : Orbit s (mC v) := by
  obtain ⟨W, hW, hv⟩ := h
  exact ⟨_root_.BerggrenStars.mC :: W, fun f hf => by
    rcases List.mem_cons.mp hf with rfl | hf'
    · exact Or.inr (Or.inr rfl)
    · exact hW f hf', by rw [applyWord_cons, hv]⟩

/-- `v` is a node of the Berggren tree grown from `(3,4,5)`. -/
def IsNode (v : Vec) : Prop := Orbit root v

theorem isNode_root : IsNode root := orbit_self root

/-- Forward direction: every node has admissible Euclid parameters. -/
theorem isNode_param {v : Vec} (h : IsNode v) : ∃ m n : ℤ, IsParam m n ∧ v = euclidTriple m n := by
  obtain ⟨W, hW, hv⟩ := h
  subst hv
  induction W with
  | nil => exact ⟨2, 1, param_root, by rw [applyWord_nil, ← euclid_root]⟩
  | cons f t ih =>
      have ht : IsBerggrenWord t := fun g hg => hW g (List.mem_cons_of_mem _ hg)
      obtain ⟨m, n, hpar, heq⟩ := ih ht
      rcases hW f (List.mem_cons_self ..) with rfl | rfl | rfl
      · exact ⟨2 * m - n, m, param_A hpar, by rw [applyWord_cons, heq, mA_euclid]⟩
      · exact ⟨2 * m + n, m, param_B hpar, by rw [applyWord_cons, heq, mB_euclid]⟩
      · exact ⟨m + 2 * n, n, param_C hpar, by rw [applyWord_cons, heq, mC_euclid]⟩

/-! ### The descent: every admissible parameter pair is reached -/

private theorem descent : ∀ M : ℕ, ∀ m n : ℤ, m.toNat ≤ M → IsParam m n →
    IsNode (euclidTriple m n) := by
  intro M
  induction M with
  | zero =>
      intro m n hM hpar
      exfalso
      have := hpar.mpos
      omega
  | succ M ih =>
      intro m n hM hpar
      have hn := hpar.npos
      have hnm := hpar.lt
      -- the two degenerate positions are impossible unless we are at the root
      have hdvd : ∀ k : ℤ, k ∣ m → k ∣ n → k ∣ 1 := by
        intro k hk1 hk2
        have := Int.dvd_coe_gcd hk1 hk2
        rwa [hpar.cop, Int.natCast_one] at this
      by_cases hroot : m = 2
      · have hn1 : n = 1 := by omega
        subst hroot; subst hn1
        rw [euclid_root]
        exact isNode_root
      · have hm3 : 3 ≤ m := by
          have := hpar.mpos
          omega
        have hne2 : m ≠ 2 * n := by
          intro h
          have : (n : ℤ) ∣ 1 := hdvd n ⟨2, by omega⟩ dvd_rfl
          have : n = 1 := by
            rcases Int.isUnit_iff.mp (isUnit_of_dvd_one this) with h1 | h1 <;> omega
          omega
        have hne3 : m ≠ 3 * n := by
          intro h
          have hd : (n : ℤ) ∣ 1 := hdvd n ⟨3, by omega⟩ dvd_rfl
          have hn1 : n = 1 := by
            rcases Int.isUnit_iff.mp (isUnit_of_dvd_one hd) with h1 | h1 <;> omega
          obtain ⟨t, ht⟩ := hpar.par
          omega
        rcases lt_trichotomy m (2 * n) with hcase | hcase | hcase
        · -- parent `(n, 2n - m)` via `mA`
          have hpar' : IsParam n (2 * n - m) := by
            refine ⟨by omega, by omega, ?_, ?_⟩
            · have hc : IsCoprime m n := Int.isCoprime_iff_gcd_eq_one.mpr hpar.cop
              have h2 : IsCoprime (-m + n * 2) n := (hc.neg_left.add_mul_left_left 2)
              have he : -m + n * 2 = 2 * n - m := by ring
              rw [he] at h2
              exact Int.isCoprime_iff_gcd_eq_one.mp h2.symm
            · obtain ⟨t, ht⟩ := hpar.par
              exact ⟨t, by omega⟩
          have hsm : (n : ℤ).toNat ≤ M := by omega
          have := (ih n (2 * n - m) hsm hpar').mA
          rwa [mA_euclid, show 2 * n - (2 * n - m) = m by ring] at this
        · exact absurd hcase hne2
        · rcases lt_trichotomy m (3 * n) with hcase2 | hcase2 | hcase2
          · -- parent `(n, m - 2n)` via `mB`
            have hpar' : IsParam n (m - 2 * n) := by
              refine ⟨by omega, by omega, ?_, ?_⟩
              · have hc : IsCoprime m n := Int.isCoprime_iff_gcd_eq_one.mpr hpar.cop
                have h2 : IsCoprime (m + n * (-2)) n := (hc.add_mul_left_left (-2))
                have he : m + n * (-2) = m - 2 * n := by ring
                rw [he] at h2
                exact Int.isCoprime_iff_gcd_eq_one.mp h2.symm
              · obtain ⟨t, ht⟩ := hpar.par
                exact ⟨-t + n - 1, by omega⟩
            have hsm : (n : ℤ).toNat ≤ M := by omega
            have := (ih n (m - 2 * n) hsm hpar').mB
            rwa [mB_euclid, show 2 * n + (m - 2 * n) = m by ring] at this
          · exact absurd hcase2 hne3
          · -- parent `(m - 2n, n)` via `mC`
            have hpar' : IsParam (m - 2 * n) n := by
              refine ⟨hn, by omega, ?_, ?_⟩
              · have hc : IsCoprime m n := Int.isCoprime_iff_gcd_eq_one.mpr hpar.cop
                have h2 : IsCoprime (m + n * (-2)) n := (hc.add_mul_left_left (-2))
                have he : m + n * (-2) = m - 2 * n := by ring
                rw [he] at h2
                exact Int.isCoprime_iff_gcd_eq_one.mp h2
              · obtain ⟨t, ht⟩ := hpar.par
                exact ⟨t - n, by omega⟩
            have hsm : (m - 2 * n : ℤ).toNat ≤ M := by omega
            have := (ih (m - 2 * n) n hsm hpar').mC
            rwa [mC_euclid, show m - 2 * n + 2 * n = m by ring] at this

/-- **Every admissible Euclid pair is a node of the Berggren tree.** -/
theorem param_isNode {m n : ℤ} (h : IsParam m n) : IsNode (euclidTriple m n) :=
  descent m.toNat m n le_rfl h

/-- The nodes of the Berggren tree are exactly the admissible Euclid pairs. -/
theorem isNode_iff_param {v : Vec} :
    IsNode v ↔ ∃ m n : ℤ, IsParam m n ∧ v = euclidTriple m n := by
  refine ⟨isNode_param, ?_⟩
  rintro ⟨m, n, hpar, rfl⟩
  exact param_isNode hpar

/-! ### Barning–Hall: the tree is exactly the odd-leg primitive triples -/

/-- Opposite parity, in the form Mathlib's classification uses. -/
private theorem parity_of_odd_sub {m n : ℤ} (h : Odd (m - n)) :
    m % 2 = 0 ∧ n % 2 = 1 ∨ m % 2 = 1 ∧ n % 2 = 0 := by
  obtain ⟨t, ht⟩ := h
  omega

theorem IsParam.gcd_eq_one {m n : ℤ} (h : IsParam m n) :
    Int.gcd (m ^ 2 - n ^ 2) (2 * m * n) = 1 :=
  (PythagoreanTriple.coprime_classification.mpr
    ⟨m, n, Or.inl ⟨rfl, rfl⟩, Or.inl rfl, h.cop, parity_of_odd_sub h.par⟩).2

theorem IsParam.odd_fst {m n : ℤ} (h : IsParam m n) : Odd (m ^ 2 - n ^ 2) := by
  rcases parity_of_odd_sub h.par with ⟨h1, h2⟩ | ⟨h1, h2⟩
  · obtain ⟨s, hs⟩ : ∃ s, m = 2 * s := ⟨m / 2, by omega⟩
    obtain ⟨t, ht⟩ : ∃ t, n = 2 * t + 1 := ⟨n / 2, by omega⟩
    exact ⟨2 * s ^ 2 - 2 * t ^ 2 - 2 * t - 1, by subst hs; subst ht; ring⟩
  · obtain ⟨s, hs⟩ : ∃ s, m = 2 * s + 1 := ⟨m / 2, by omega⟩
    obtain ⟨t, ht⟩ : ∃ t, n = 2 * t := ⟨n / 2, by omega⟩
    exact ⟨2 * s ^ 2 + 2 * s - 2 * t ^ 2, by subst hs; subst ht; ring⟩

/-- **Barning–Hall completeness theorem.**  A triple is a node of the Berggren tree grown
from `(3,4,5)` if and only if it is a positive primitive Pythagorean triple whose first
leg is odd. -/
theorem isNode_iff (a b c : ℤ) :
    IsNode (a, b, c) ↔
      0 < a ∧ 0 < b ∧ 0 < c ∧ a ^ 2 + b ^ 2 = c ^ 2 ∧ Int.gcd a b = 1 ∧ Odd a := by
  constructor
  · intro h
    obtain ⟨m, n, hpar, heq⟩ := isNode_param h
    simp only [euclidTriple, Prod.mk.injEq] at heq
    obtain ⟨rfl, rfl, rfl⟩ := heq
    have hm := hpar.mpos
    have hn := hpar.npos
    have hnm := hpar.lt
    refine ⟨by nlinarith, by positivity, by positivity, by ring, hpar.gcd_eq_one, hpar.odd_fst⟩
  · rintro ⟨ha, hb, hc, hpyth, hcop, hodd⟩
    have hPT : PythagoreanTriple a b c := by
      simp only [PythagoreanTriple]
      nlinarith [hpyth]
    have hpar1 : a % 2 = 1 := Int.odd_iff.mp hodd
    obtain ⟨m, n, hA, hB, hC, hcop', hpp, hm0⟩ :=
      hPT.coprime_classification' hcop hpar1 hc
    have hmpos : 0 < m := by
      rcases lt_or_eq_of_le hm0 with h | h
      · exact h
      · exfalso; rw [← h] at hB; simp at hB; omega
    have hnpos : 0 < n := by
      rcases lt_trichotomy n 0 with h | h | h
      · exfalso; nlinarith [hB, hb]
      · exfalso; rw [h] at hB; simp at hB; omega
      · exact h
    have hnm : n < m := by nlinarith [hA, ha]
    have hpar : IsParam m n := by
      refine ⟨hnpos, hnm, hcop', ?_⟩
      rcases hpp with ⟨h1, h2⟩ | ⟨h1, h2⟩ <;> [skip; skip] <;>
        · rw [Int.odd_iff]; omega
    have : (a, b, c) = euclidTriple m n := by
      simp only [euclidTriple, Prod.mk.injEq]
      exact ⟨hA, hB, hC⟩
    rw [this]
    exact param_isNode hpar

/-! ### The mirrored tree -/

/-- The leg swap. -/
def swapVec (v : Vec) : Vec := (v.2.1, v.1, v.2.2)

@[simp] theorem swapVec_swapVec (v : Vec) : swapVec (swapVec v) = v := rfl

theorem swap_mA (v : Vec) : swapVec (mA (swapVec v)) = mC v := by
  obtain ⟨a, b, c⟩ := v
  simp only [swapVec, mA, mC, Prod.mk.injEq]
  refine ⟨by ring, by ring, by ring⟩

theorem swap_mB (v : Vec) : swapVec (mB (swapVec v)) = mB v := by
  obtain ⟨a, b, c⟩ := v
  simp only [swapVec, mB, Prod.mk.injEq]
  refine ⟨by ring, by ring, by ring⟩

theorem swap_mC (v : Vec) : swapVec (mC (swapVec v)) = mA v := by
  obtain ⟨a, b, c⟩ := v
  simp only [swapVec, mA, mC, Prod.mk.injEq]
  refine ⟨by ring, by ring, by ring⟩

/-- The seed of the mirrored tree. -/
def rootSwap : Vec := (4, 3, 5)

@[simp] theorem swapVec_root : swapVec root = rootSwap := rfl
@[simp] theorem swapVec_rootSwap : swapVec rootSwap = root := rfl

/-- `v` is a node of the Berggren tree grown from the mirrored seed `(4,3,5)`. -/
def IsNodeSwap (v : Vec) : Prop := Orbit rootSwap v

/-- Conjugating by the leg swap carries the orbit of a seed to the orbit of the swapped
seed: the swap exchanges the generators `mA` and `mC` and fixes `mB`. -/
theorem orbit_swap {s v : Vec} (h : Orbit s v) : Orbit (swapVec s) (swapVec v) := by
  obtain ⟨W, hW, rfl⟩ := h
  induction W with
  | nil => exact orbit_self _
  | cons f t ih =>
      have ht : IsBerggrenWord t := fun g hg => hW g (List.mem_cons_of_mem _ hg)
      have hrec := ih ht
      rcases hW f (List.mem_cons_self ..) with rfl | rfl | rfl
      · rw [applyWord_cons,
          show swapVec (mA (applyWord t s)) = mC (swapVec (applyWord t s)) by
            rw [← swap_mA (swapVec (applyWord t s)), swapVec_swapVec]]
        exact hrec.mC
      · rw [applyWord_cons,
          show swapVec (mB (applyWord t s)) = mB (swapVec (applyWord t s)) by
            rw [← swap_mB (swapVec (applyWord t s)), swapVec_swapVec]]
        exact hrec.mB
      · rw [applyWord_cons,
          show swapVec (mC (applyWord t s)) = mA (swapVec (applyWord t s)) by
            rw [← swap_mC (swapVec (applyWord t s)), swapVec_swapVec]]
        exact hrec.mA

/-- The mirrored tree is the leg-swap of the tree. -/
theorem isNodeSwap_iff_isNode {v : Vec} : IsNodeSwap v ↔ IsNode (swapVec v) := by
  constructor
  · intro h
    simpa using orbit_swap h
  · intro h
    have := orbit_swap h
    simpa using this

/-- **The mirrored tree is exactly the even-leg primitive triples.** -/
theorem isNodeSwap_iff (a b c : ℤ) :
    IsNodeSwap (a, b, c) ↔
      0 < a ∧ 0 < b ∧ 0 < c ∧ a ^ 2 + b ^ 2 = c ^ 2 ∧ Int.gcd a b = 1 ∧ Odd b := by
  rw [isNodeSwap_iff_isNode]
  have : swapVec (a, b, c) = (b, a, c) := rfl
  rw [this, isNode_iff]
  constructor
  · rintro ⟨h1, h2, h3, h4, h5, h6⟩
    exact ⟨h2, h1, h3, by linarith, by rwa [Int.gcd_comm], h6⟩
  · rintro ⟨h1, h2, h3, h4, h5, h6⟩
    exact ⟨h2, h1, h3, by linarith, by rwa [Int.gcd_comm], h6⟩

/-! ### The two seeds together exhaust the primitive triples -/

/-- A positive primitive Pythagorean triple. -/
def IsPPT (a b c : ℤ) : Prop :=
  0 < a ∧ 0 < b ∧ 0 < c ∧ a ^ 2 + b ^ 2 = c ^ 2 ∧ Int.gcd a b = 1

/-- In a positive primitive Pythagorean triple exactly one leg is odd. -/
theorem IsPPT.odd_xor {a b c : ℤ} (h : IsPPT a b c) : (Odd a ∧ ¬ Odd b) ∨ (¬ Odd a ∧ Odd b) := by
  obtain ⟨ha, hb, hc, hpy, hcop⟩ := h
  have hnot : ¬ (Even a ∧ Even b) := by
    rintro ⟨⟨s, hs⟩, ⟨t, ht⟩⟩
    have h2 : (2 : ℤ) ∣ (Int.gcd a b : ℤ) := Int.dvd_coe_gcd ⟨s, by omega⟩ ⟨t, by omega⟩
    rw [hcop] at h2
    norm_num at h2
  have hnotodd : ¬ (Odd a ∧ Odd b) := by
    rintro ⟨⟨s, hs⟩, ⟨t, ht⟩⟩
    -- then `c² ≡ 2 (mod 4)`, impossible
    have hc4 : c * c % 4 ≠ 2 := Int.sq_ne_two_mod_four c
    apply hc4
    have : c * c = 4 * (s * s + s + t * t + t) + 2 := by
      have : a ^ 2 + b ^ 2 = c ^ 2 := hpy
      subst hs; subst ht
      nlinarith [this]
    omega
  rcases Int.even_or_odd a with hae | hao
  · rcases Int.even_or_odd b with hbe | hbo
    · exact absurd ⟨hae, hbe⟩ hnot
    · exact Or.inr ⟨by simpa [Int.not_odd_iff_even] using hae, hbo⟩
  · exact Or.inl ⟨hao, fun hbo => hnotodd ⟨hao, hbo⟩⟩

/-- **Two seeds suffice, and never overlap.**  Every positive primitive Pythagorean
triple lies in exactly one of the two Berggren trees grown from `(3,4,5)` and `(4,3,5)`,
and conversely both trees consist of positive primitive Pythagorean triples. -/
theorem isPPT_iff_node_or_swap (a b c : ℤ) :
    IsPPT a b c ↔ IsNode (a, b, c) ∨ IsNodeSwap (a, b, c) := by
  constructor
  · intro h
    obtain ⟨ha, hb, hc, hpy, hcop⟩ := h
    rcases (IsPPT.odd_xor ⟨ha, hb, hc, hpy, hcop⟩) with ⟨h1, -⟩ | ⟨-, h2⟩
    · exact Or.inl ((isNode_iff a b c).mpr ⟨ha, hb, hc, hpy, hcop, h1⟩)
    · exact Or.inr ((isNodeSwap_iff a b c).mpr ⟨ha, hb, hc, hpy, hcop, h2⟩)
  · rintro (h | h)
    · obtain ⟨h1, h2, h3, h4, h5, -⟩ := (isNode_iff a b c).mp h
      exact ⟨h1, h2, h3, h4, h5⟩
    · obtain ⟨h1, h2, h3, h4, h5, -⟩ := (isNodeSwap_iff a b c).mp h
      exact ⟨h1, h2, h3, h4, h5⟩

/-- The two trees are disjoint. -/
theorem not_isNode_and_isNodeSwap (a b c : ℤ) : ¬ (IsNode (a, b, c) ∧ IsNodeSwap (a, b, c)) := by
  rintro ⟨h1, h2⟩
  obtain ⟨ha, hb, hc, hpy, hcop, hoa⟩ := (isNode_iff a b c).mp h1
  obtain ⟨-, -, -, -, -, hob⟩ := (isNodeSwap_iff a b c).mp h2
  rcases (IsPPT.odd_xor ⟨ha, hb, hc, hpy, hcop⟩) with ⟨-, h⟩ | ⟨h, -⟩
  · exact h hob
  · exact h hoa

end BerggrenStars