/-
# How wide a closed parity gap can be

`Catalog/Probability/ParityGap/Primality.lean` shows that for a *composite* modulus `m = a · b`
the parity gap closes, and does so for every width `n ≤ min (a, b)`: the annihilating progressions
`S i = a · i`, `T j = b · j` make **all** permutation exponents equal, so the signed count cancels
for the trivial reason that the exponent map is constant.

This file exhibits a far more efficient mechanism, which closes the gap for every width up to
`m − a`, where `a` is *any* nontrivial factor of `m` — in particular up to `m − 2` for every even
modulus, which is the conjectured optimum.  The exponent map is now very far from constant; the
cancellation comes from a **pigeonhole involution**:

* choose a set `J` of row indices whose `S`-values pairwise annihilate a subgroup `B ≤ ZMod m`,
* choose the columns so that their `T`-values fall into fewer than `#J` classes modulo `B`;
* then for *every* permutation `σ` two columns of the same class are matched with rows of `J`,
  and swapping them preserves the exponent while reversing the sign.

Main results:

* `ParityGap.permCoeff_eq_zero_of_pigeonhole` — the abstract criterion just described;
* `ParityGap.parity_gap_closes_wide` — for `m = a · b` with `a, b ≥ 2` the gap closes for every
  width `2 ≤ n ≤ m − a`;
* `ParityGap.parity_gap_closes_of_even` — for even `m ≥ 4` the gap closes for every width
  `2 ≤ n ≤ m − 2`.

In the opposite direction the gap can never close at the two largest widths:

* `ParityGap.parity_gap_open_at_full_width` — at `n = m` the matrix `(ω^{S j · T k})` is a
  Vandermonde matrix in distinct roots of unity, hence nonsingular;
* `ParityGap.parity_gap_open_at_width_pred` — at `n = m − 1` a vanishing counter would produce a
  nonzero function on `ZMod m` supported on `m − 1` points whose Fourier transform is supported at
  a single point, contradicting the uncertainty principle `FourierCyclic.uncertainty_zmod`.

Combining the two sides, `ParityGap.gapCloses_iff_of_even` determines the maximal width exactly
for even moduli: the gap closes at width `n ≥ 2` over an even modulus `m ≥ 4` **iff** `n ≤ m − 2`.
-/

import Mathlib
import Probability.GapQuantitative

open Finset PrimeUncertainty

namespace ParityGap

variable {m n : ℕ}

/-! ## Swapping two columns -/

/-- Composing a permutation with the transposition of two columns `j₁, j₂` does not change the
exponent, provided the four products involved cancel in pairs. -/
theorem permExp_mul_swap {S T : Fin n → ZMod m} (σ : Equiv.Perm (Fin n)) (j₁ j₂ : Fin n)
    (h : S (σ j₁) * T j₁ + S (σ j₂) * T j₂ = S (σ j₂) * T j₁ + S (σ j₁) * T j₂) :
    permExp S T (σ * Equiv.swap j₁ j₂) = permExp S T σ := by
  classical
  rcases eq_or_ne j₁ j₂ with rfl | hne
  · simp
  have hsub : ({j₁, j₂} : Finset (Fin n)) ⊆ univ := subset_univ _
  have e1 := Finset.sum_sdiff (f := fun j => S ((σ * Equiv.swap j₁ j₂) j) * T j) hsub
  have e2 := Finset.sum_sdiff (f := fun j => S (σ j) * T j) hsub
  have hrest : ∑ j ∈ univ \ ({j₁, j₂} : Finset (Fin n)),
        S ((σ * Equiv.swap j₁ j₂) j) * T j
      = ∑ j ∈ univ \ ({j₁, j₂} : Finset (Fin n)), S (σ j) * T j := by
    refine Finset.sum_congr rfl fun j hj => ?_
    have hj' := Finset.mem_sdiff.mp hj
    have h1 : j ≠ j₁ := by
      intro h; exact hj'.2 (by simp [h])
    have h2 : j ≠ j₂ := by
      intro h; exact hj'.2 (by simp [h])
    simp [Equiv.Perm.mul_apply, Equiv.swap_apply_of_ne_of_ne h1 h2]
  have hpair1 : ∑ j ∈ ({j₁, j₂} : Finset (Fin n)), S ((σ * Equiv.swap j₁ j₂) j) * T j
      = S (σ j₂) * T j₁ + S (σ j₁) * T j₂ := by
    rw [Finset.sum_pair hne]
    simp [Equiv.Perm.mul_apply, Equiv.swap_apply_left, Equiv.swap_apply_right]
  have hpair2 : ∑ j ∈ ({j₁, j₂} : Finset (Fin n)), S (σ j) * T j
      = S (σ j₁) * T j₁ + S (σ j₂) * T j₂ := Finset.sum_pair hne
  have : permExp S T (σ * Equiv.swap j₁ j₂)
      = ∑ j ∈ univ \ ({j₁, j₂} : Finset (Fin n)), S ((σ * Equiv.swap j₁ j₂) j) * T j
        + ∑ j ∈ ({j₁, j₂} : Finset (Fin n)), S ((σ * Equiv.swap j₁ j₂) j) * T j := e1.symm
  rw [permExp, permExp] at *
  rw [← e1, ← e2, hrest, hpair1, hpair2, h]

/-! ## The pigeonhole criterion -/

/-- **Pigeonhole criterion for a closed parity gap.**  Suppose a set `J` of row indices and a
classification `cls` of the column indices are given such that

* whenever two columns `j₁, j₂` are in the same class, the products of their `T`-values against
  any two `S`-values coming from `J` cancel in pairs (this holds, e.g., when the differences of
  the `S`-values over `J` annihilate the differences of the `T`-values inside a class);
* there are strictly fewer classes than elements of `J`.

Then the parity-weighted exponent counter vanishes identically.  Indeed, for every permutation
`σ` the `#J` columns sent into `J` meet some class twice, and transposing two such columns
preserves the exponent while reversing the sign; choosing the pair canonically turns this into a
fixed-point-free sign-reversing involution of each exponent fibre. -/
theorem permCoeff_eq_zero_of_pigeonhole {κ : Type*} [DecidableEq κ]
    (S T : Fin n → ZMod m) (J : Finset (Fin n)) (cls : Fin n → κ)
    (hann : ∀ u ∈ J, ∀ v ∈ J, ∀ j₁ j₂ : Fin n, cls j₁ = cls j₂ →
      S u * T j₁ + S v * T j₂ = S v * T j₁ + S u * T j₂)
    (hcard : (univ.image cls).card < J.card) (r : ZMod m) :
    permCoeff S T r = 0 := by
  classical
  -- the columns that a permutation sends into `J`
  set C : Equiv.Perm (Fin n) → Finset (Fin n) := fun σ => univ.filter (fun j => σ j ∈ J) with hC
  have hCcard : ∀ σ : Equiv.Perm (Fin n), (C σ).card = J.card := by
    intro σ
    have : C σ = J.map σ.symm.toEmbedding := by
      ext j
      simp only [hC, Finset.mem_filter, Finset.mem_univ, true_and, Finset.mem_map,
        Equiv.coe_toEmbedding]
      constructor
      · exact fun h => ⟨σ j, h, by simp⟩
      · rintro ⟨u, hu, rfl⟩; simpa using hu
    rw [this, Finset.card_map]
  -- a canonical same-class pair inside any large enough set of columns
  have hchoice : ∀ D : Finset (Fin n), ∃ q : Fin n × Fin n,
      (univ.image cls).card < D.card → q.1 ∈ D ∧ q.2 ∈ D ∧ q.1 ≠ q.2 ∧ cls q.1 = cls q.2 := by
    intro D
    by_cases hD : (univ.image cls).card < D.card
    · obtain ⟨x, hx, y, hy, hxy, hcls⟩ :=
        Finset.exists_ne_map_eq_of_card_lt_of_maps_to hD
          (f := cls) (fun j _ => Finset.mem_image_of_mem cls (Finset.mem_univ j))
      exact ⟨(x, y), fun _ => ⟨hx, hy, hxy, hcls⟩⟩
    · have hne : (0 : ℕ) < J.card := lt_of_le_of_lt (Nat.zero_le _) hcard
      have : Nonempty (Fin n) := by
        rcases Finset.card_pos.mp hne with ⟨j, _⟩
        exact ⟨j⟩
      obtain ⟨j⟩ := this
      exact ⟨(j, j), fun h => absurd h hD⟩
  choose g hg using hchoice
  -- the involution
  set ι : Equiv.Perm (Fin n) → Equiv.Perm (Fin n) :=
    fun σ => σ * Equiv.swap (g (C σ)).1 (g (C σ)).2 with hι
  have hgprop : ∀ σ : Equiv.Perm (Fin n),
      (g (C σ)).1 ∈ C σ ∧ (g (C σ)).2 ∈ C σ ∧ (g (C σ)).1 ≠ (g (C σ)).2 ∧
        cls (g (C σ)).1 = cls (g (C σ)).2 := by
    intro σ
    exact hg (C σ) (by rw [hCcard σ]; exact hcard)
  -- the involution preserves the set of columns mapped into `J`
  have hCinv : ∀ σ : Equiv.Perm (Fin n), C (ι σ) = C σ := by
    intro σ
    obtain ⟨h1, h2, hne, -⟩ := hgprop σ
    ext j
    simp only [hC, hι, Finset.mem_filter, Finset.mem_univ, true_and, Equiv.Perm.mul_apply]
    by_cases hj1 : j = (g (C σ)).1
    · subst hj1
      rw [Equiv.swap_apply_left]
      simp only [hC, Finset.mem_filter, Finset.mem_univ, true_and] at h1 h2
      exact ⟨fun _ => h1, fun _ => h2⟩
    · by_cases hj2 : j = (g (C σ)).2
      · subst hj2
        rw [Equiv.swap_apply_right]
        simp only [hC, Finset.mem_filter, Finset.mem_univ, true_and] at h1 h2
        exact ⟨fun _ => h2, fun _ => h1⟩
      · rw [Equiv.swap_apply_of_ne_of_ne hj1 hj2]
  -- exponents are preserved
  have hexp : ∀ σ : Equiv.Perm (Fin n), permExp S T (ι σ) = permExp S T σ := by
    intro σ
    obtain ⟨h1, h2, hne, hcls⟩ := hgprop σ
    simp only [hC, Finset.mem_filter, Finset.mem_univ, true_and] at h1 h2
    exact permExp_mul_swap σ _ _ (hann _ h1 _ h2 _ _ hcls)
  -- signs are reversed
  have hsign : ∀ σ : Equiv.Perm (Fin n),
      (Equiv.Perm.sign (ι σ) : ℚ) = -(Equiv.Perm.sign σ : ℚ) := by
    intro σ
    obtain ⟨-, -, hne, -⟩ := hgprop σ
    rw [hι]
    simp [Equiv.Perm.sign_swap hne]
  refine Finset.sum_involution (fun σ _ => ι σ) (fun σ _ => ?_) (fun σ _ _ => ?_)
    (fun σ _ => Finset.mem_univ _) (fun σ _ => ?_)
  · by_cases hr : permExp S T σ = r
    · simp only [hr, if_true, hexp σ, hsign σ]
      ring
    · simp [hr, hexp σ]
  · -- the involution has no fixed point
    obtain ⟨-, -, hne, -⟩ := hgprop σ
    intro hfix
    rw [hι] at hfix
    have : Equiv.swap (g (C σ)).1 (g (C σ)).2 = 1 := by
      have := congrArg (fun τ => σ⁻¹ * τ) hfix
      simpa [mul_assoc] using this
    exact hne (Equiv.swap_eq_one_iff.mp this)
  · -- it is an involution
    show ι (ι σ) = σ
    rw [show ι (ι σ) = ι σ * Equiv.swap (g (C (ι σ))).1 (g (C (ι σ))).2 from rfl, hCinv σ,
      show ι σ = σ * Equiv.swap (g (C σ)).1 (g (C σ)).2 from rfl]
    simp [mul_assoc]

/-! ## Digit-swap enumerations of `ZMod (a·b)` -/

/-- The digit-swapping map `j ↦ a·(j % b) + j / b` stays inside `[0, a·b)`. -/
theorem digitSwap_lt {a b j : ℕ} (hb : 0 < b) (hj : j < a * b) :
    a * (j % b) + j / b < a * b := by
  have h1 : j % b < b := Nat.mod_lt _ hb
  have h2 : j / b < a := (Nat.div_lt_iff_lt_mul hb).2 hj
  have h3 : a * (j % b) ≤ a * (b - 1) := Nat.mul_le_mul_left a (by omega)
  obtain ⟨b', rfl⟩ : ∃ b', b = b' + 1 := ⟨b - 1, by omega⟩
  simp only [Nat.add_sub_cancel, Nat.mul_succ] at *
  omega

/-- The digit-swapping map `j ↦ a·(j % b) + j / b` is injective on `[0, a·b)`: it exchanges the
two digits of the mixed-radix expansion of `j`. -/
theorem digitSwap_injOn {a b j k : ℕ} (ha : 0 < a) (hb : 0 < b) (hj : j < a * b)
    (hk : k < a * b) (h : a * (j % b) + j / b = a * (k % b) + k / b) : j = k := by
  have hj2 : j / b < a := (Nat.div_lt_iff_lt_mul hb).2 hj
  have hk2 : k / b < a := (Nat.div_lt_iff_lt_mul hb).2 hk
  have hdiv : ∀ x : ℕ, x / b < a → (a * (x % b) + x / b) / a = x % b := by
    intro x hx
    rw [Nat.mul_add_div ha, Nat.div_eq_of_lt hx, Nat.add_zero]
  have hmod : ∀ x : ℕ, x / b < a → (a * (x % b) + x / b) % a = x / b := by
    intro x hx
    rw [Nat.mul_add_mod, Nat.mod_eq_of_lt hx]
  have h1 : j % b = k % b := by rw [← hdiv j hj2, ← hdiv k hk2, h]
  have h2 : j / b = k / b := by rw [← hmod j hj2, ← hmod k hk2, h]
  calc j = b * (j / b) + j % b := (Nat.div_add_mod j b).symm
    _ = b * (k / b) + k % b := by rw [h1, h2]
    _ = k := Nat.div_add_mod k b

/-! ## Wide gap-closing configurations over a composite modulus -/

/-- **The parity gap closes at every width up to `m − a`.**  Let `m = a · b` with `a, b ≥ 2`.
For every `2 ≤ n ≤ m − a` there are injective `S, T : Fin n → ZMod m` whose parity-weighted
exponent counter vanishes identically.

The configuration is explicit: `S j = a·(j % b) + j / b` and `T k = b·(k % a) + k / a` are two
digit-swapped enumerations of `ZMod m`.  The first `c + 1` values of `S` (with `c = ⌈n/a⌉`) are
the multiples `a·0, a·1, …` of `a`, while the `T`-values fall into only `c` classes modulo the
subgroup generated by `b`; since `a·b = 0`, transposing two columns of the same class while both
are matched to multiples of `a` preserves the exponent and reverses the sign, and the pigeonhole
principle guarantees such a pair for every permutation. -/
theorem parity_gap_closes_wide {m a b n : ℕ} (hm : m = a * b) (ha : 2 ≤ a) (hb : 2 ≤ b)
    (hn : 2 ≤ n) (hnm : n ≤ m - a) :
    ∃ S T : Fin n → ZMod m, Function.Injective S ∧ Function.Injective T ∧
      ∀ r : ZMod m, permCoeff S T r = 0 := by
  classical
  have ha0 : 0 < a := by omega
  have hb0 : 0 < b := by omega
  have hba : (b - 1) * a + a = a * b := by
    obtain ⟨b', rfl⟩ : ∃ b', b = b' + 1 := ⟨b - 1, by omega⟩
    simp only [Nat.add_sub_cancel]
    ring
  have ham : a ≤ m := by omega
  have hnam : n + a ≤ m := by omega
  have hnm' : n ≤ a * b := by omega
  obtain ⟨d, hd⟩ : ∃ d, (n - 1) / a = d := ⟨_, rfl⟩
  have hdb : d < b - 1 := by
    rw [← hd]
    exact (Nat.div_lt_iff_lt_mul ha0).2 (by omega)
  have hdn : d < n - 1 := by
    rw [← hd]
    exact Nat.div_lt_self (by omega) (by omega)
  have hcb : d + 2 ≤ b := by omega
  have hcn : d + 2 ≤ n := by omega
  have hab : (a : ZMod m) * (b : ZMod m) = 0 := by
    rw [← Nat.cast_mul, ← hm, ZMod.natCast_self]
  refine ⟨fun j => ((a * ((j : ℕ) % b) + (j : ℕ) / b : ℕ) : ZMod m),
    fun k => ((b * ((k : ℕ) % a) + (k : ℕ) / a : ℕ) : ZMod m), ?_, ?_, ?_⟩
  · -- `S` is injective
    intro j k hjk
    have hjm : (j : ℕ) < a * b := lt_of_lt_of_le j.isLt hnm'
    have hkm : (k : ℕ) < a * b := lt_of_lt_of_le k.isLt hnm'
    have hlt1 : a * ((j : ℕ) % b) + (j : ℕ) / b < m := by
      rw [hm]; exact digitSwap_lt hb0 hjm
    have hlt2 : a * ((k : ℕ) % b) + (k : ℕ) / b < m := by
      rw [hm]; exact digitSwap_lt hb0 hkm
    have heq := (ZMod.natCast_eq_natCast_iff' _ _ _).mp hjk
    rw [Nat.mod_eq_of_lt hlt1, Nat.mod_eq_of_lt hlt2] at heq
    exact Fin.ext (digitSwap_injOn ha0 hb0 hjm hkm heq)
  · -- `T` is injective
    intro j k hjk
    have hjm : (j : ℕ) < b * a := by rw [Nat.mul_comm]; exact lt_of_lt_of_le j.isLt hnm'
    have hkm : (k : ℕ) < b * a := by rw [Nat.mul_comm]; exact lt_of_lt_of_le k.isLt hnm'
    have hlt1 : b * ((j : ℕ) % a) + (j : ℕ) / a < m := by
      rw [hm, Nat.mul_comm a b]; exact digitSwap_lt ha0 hjm
    have hlt2 : b * ((k : ℕ) % a) + (k : ℕ) / a < m := by
      rw [hm, Nat.mul_comm a b]; exact digitSwap_lt ha0 hkm
    have heq := (ZMod.natCast_eq_natCast_iff' _ _ _).mp hjk
    rw [Nat.mod_eq_of_lt hlt1, Nat.mod_eq_of_lt hlt2] at heq
    exact Fin.ext (digitSwap_injOn hb0 ha0 hjm hkm heq)
  · -- the counter vanishes
    intro r
    have hJ : ∀ i ∈ Finset.range (d + 2), i < n := fun i hi =>
      lt_of_lt_of_le (Finset.mem_range.mp hi) hcn
    refine permCoeff_eq_zero_of_pigeonhole _ _ ((Finset.range (d + 2)).attachFin hJ)
      (fun k => (k : ℕ) / a) ?_ ?_ r
    · -- same-class columns cancel against rows carrying multiples of `a`
      intro u hu v hv j₁ j₂ hcls
      rw [Finset.mem_attachFin, Finset.mem_range] at hu hv
      have hS : ∀ w : Fin n, (w : ℕ) < d + 2 →
          ((a * ((w : ℕ) % b) + (w : ℕ) / b : ℕ) : ZMod m) = (a : ZMod m) * ((w : ℕ) : ZMod m) := by
        intro w hw
        rw [Nat.mod_eq_of_lt (by omega), Nat.div_eq_of_lt (by omega)]
        push_cast
        ring
      have hT : ∀ k : Fin n, ((b * ((k : ℕ) % a) + (k : ℕ) / a : ℕ) : ZMod m)
          = (b : ZMod m) * ((((k : ℕ) % a : ℕ)) : ZMod m) + (((k : ℕ) / a : ℕ) : ZMod m) := by
        intro k; push_cast; ring
      have hcls' : ((j₁ : ℕ) / a) = ((j₂ : ℕ) / a) := hcls
      rw [hS u hu, hS v hv, hT j₁, hT j₂, hcls']
      linear_combination (((u : ℕ) : ZMod m) - ((v : ℕ) : ZMod m)) *
        ((((j₁ : ℕ) % a : ℕ) : ZMod m) - (((j₂ : ℕ) % a : ℕ) : ZMod m)) * hab
    · -- there are fewer classes than rows in `J`
      have himg : (univ.image (fun k : Fin n => (k : ℕ) / a)) ⊆ Finset.range (d + 1) := by
        intro x hx
        obtain ⟨k, -, rfl⟩ := Finset.mem_image.mp hx
        refine Finset.mem_range.mpr ?_
        have hle : (k : ℕ) / a ≤ (n - 1) / a := Nat.div_le_div_right (by omega)
        rw [hd] at hle
        omega
      calc (univ.image (fun k : Fin n => (k : ℕ) / a)).card
          ≤ (Finset.range (d + 1)).card := Finset.card_le_card himg
        _ = d + 1 := Finset.card_range _
        _ < d + 2 := lt_add_one _
        _ = ((Finset.range (d + 2)).attachFin hJ).card := by
            rw [Finset.card_attachFin, Finset.card_range]

/-- **Even moduli: the gap closes at every width `2 ≤ n ≤ m − 2`.**  This matches the conjectured
optimum: for `n = m` the gap never closes (`ParityGap.parity_gap_open_at_full_width`). -/
theorem parity_gap_closes_of_even {m n : ℕ} (hm : 4 ≤ m) (heven : 2 ∣ m) (hn : 2 ≤ n)
    (hnm : n ≤ m - 2) :
    ∃ S T : Fin n → ZMod m, Function.Injective S ∧ Function.Injective T ∧
      ∀ r : ZMod m, permCoeff S T r = 0 := by
  obtain ⟨b, hb⟩ := heven
  exact parity_gap_closes_wide hb le_rfl (by omega) hn hnm

/-- **Composite moduli: the gap closes at every width up to `m − p`, where `p` is the least
prime factor of `m`.**  This strictly improves the `n ≤ min (a, b)` bound obtained from
annihilating progressions in `ParityGap.parity_gap_closes_of_factorisation`. -/
theorem parity_gap_closes_of_not_prime_wide {m n : ℕ} (hm : 2 ≤ m) (hnp : ¬ m.Prime)
    (hn : 2 ≤ n) (hnm : n ≤ m - m.minFac) :
    ∃ S T : Fin n → ZMod m, Function.Injective S ∧ Function.Injective T ∧
      ∀ r : ZMod m, permCoeff S T r = 0 := by
  have hm0 : m ≠ 1 := by omega
  have hfac : m.minFac.Prime := Nat.minFac_prime hm0
  have hdvd : m.minFac ∣ m := Nat.minFac_dvd m
  obtain ⟨b, hb⟩ := hdvd
  have ha2 : 2 ≤ m.minFac := hfac.two_le
  have hb2 : 2 ≤ b := by
    by_contra hlt
    push_neg at hlt
    interval_cases b
    · omega
    · rw [mul_one] at hb
      rw [← hb] at hfac
      exact hnp hfac
  exact parity_gap_closes_wide hb ha2 hb2 hn hnm

/-! ## Full width: the gap never closes

At the maximal width `n = m` the two families are bijections onto `ZMod m`, so the matrix
`(ω^{S j · T k})` is the full DFT matrix of `ZMod m` up to permutations of rows and columns.  Its
determinant is a Vandermonde product in the distinct roots of unity `ω^{S j}`, hence nonzero, and
the Leibniz expansion then forces some parity-weighted count to be nonzero.  Together with
`ParityGap.parity_gap_closes_of_even` this pins the maximal width of a gap-closing configuration
over an even modulus to `m - 2` or `m - 1`. -/

section FullWidth

variable {M : ℕ} [NeZero M]

/-- The canonical character turns finite sums into products, for an arbitrary modulus. -/
theorem ez_sum' {ι : Type*} (s : Finset ι) (g : ι → ZMod M) :
    ez (∑ i ∈ s, g i) = ∏ i ∈ s, ez (g i) := by
  classical
  induction s using Finset.induction with
  | empty => simp
  | insert a s ha ih => rw [Finset.sum_insert ha, Finset.prod_insert ha, ez_add, ih]

/-- **Leibniz expansion of a DFT minor** over an arbitrary modulus: the determinant of
`(ω^{S j · T k})` is the generating function of the parity-weighted exponent counter. -/
theorem det_ez_eq_sum_permCoeff' {n : ℕ} (S T : Fin n → ZMod M) :
    (Matrix.of fun j k : Fin n => ez (S j * T k)).det
      = ∑ r : ZMod M, (permCoeff S T r : ℂ) * ez r := by
  classical
  have hdet : (Matrix.of fun j k : Fin n => ez (S j * T k)).det
      = ∑ σ : Equiv.Perm (Fin n), ((Equiv.Perm.sign σ : ℤ) : ℂ) * ez (permExp S T σ) := by
    rw [Matrix.det_apply]
    refine Finset.sum_congr rfl fun σ _ => ?_
    rw [permExp, ez_sum']
    simp [Units.smul_def]
  rw [hdet]
  simp only [permCoeff]
  have hswap : ∑ r : ZMod M, ((∑ σ : Equiv.Perm (Fin n),
        if permExp S T σ = r then (Equiv.Perm.sign σ : ℚ) else 0 : ℚ) : ℂ) * ez r
      = ∑ σ : Equiv.Perm (Fin n), ∑ r : ZMod M,
          (if permExp S T σ = r then ((Equiv.Perm.sign σ : ℤ) : ℂ) else 0) * ez r := by
    rw [Finset.sum_comm]
    refine Finset.sum_congr rfl fun r _ => ?_
    push_cast
    rw [Finset.sum_mul]
    refine Finset.sum_congr rfl fun σ _ => ?_
    split_ifs <;> simp
  rw [hswap]
  refine Finset.sum_congr rfl fun σ _ => ?_
  rw [Finset.sum_eq_single_of_mem (permExp S T σ) (Finset.mem_univ _)]
  · simp
  · intro r _ hr
    simp [Ne.symm hr]

/-- At full width the DFT matrix `(ω^{S j · T k})` of a pair of injective families is a
Vandermonde matrix in the distinct roots of unity `ω^{S j}`, up to a permutation of the columns;
in particular it is nonsingular. -/
theorem det_ez_full_ne_zero (S T : Fin M → ZMod M) (hS : Function.Injective S)
    (hT : Function.Injective T) :
    (Matrix.of fun j k : Fin M => ez (S j * T k)).det ≠ 0 := by
  classical
  set z : Fin M → ℂ := fun j => om M ^ (S j).val with hz
  have hzinj : Function.Injective z := by
    intro i j hij
    exact hS (ez_injective (a₁ := S i) (a₂ := S j) hij)
  have hTinj : Function.Injective (fun k : Fin M => (⟨(T k).val, ZMod.val_lt (T k)⟩ : Fin M)) := by
    intro i j hij
    have : (T i).val = (T j).val := congrArg Fin.val hij
    exact hT (ZMod.val_injective M this)
  let e : Equiv.Perm (Fin M) :=
    Equiv.ofBijective _ (Finite.injective_iff_bijective.mp hTinj)
  have hM : (Matrix.of fun j k : Fin M => ez (S j * T k))
      = (Matrix.vandermonde z).submatrix id e := by
    ext j k
    have he : (e k : ℕ) = (T k).val := rfl
    simp only [Matrix.of_apply, Matrix.submatrix_apply, id_eq, Matrix.vandermonde_apply, he, hz]
    rw [ez_mul_eq_om_pow, pow_mul]
  rw [hM, Matrix.det_permute']
  have hvan : (Matrix.vandermonde z).det ≠ 0 := by
    rw [Matrix.det_vandermonde]
    refine Finset.prod_ne_zero_iff.2 fun i _ => Finset.prod_ne_zero_iff.2 fun j hj => ?_
    have hij : j ≠ i := (Finset.mem_Ioi.mp hj).ne'
    exact sub_ne_zero.2 fun h => hij (hzinj h)
  have hsign : ((Equiv.Perm.sign e : ℤ) : ℂ) ≠ 0 := by
    rcases Int.units_eq_one_or (Equiv.Perm.sign e) with h | h <;> rw [h] <;> norm_num
  exact mul_ne_zero hsign hvan

/-- **The parity gap never closes at full width.**  For every modulus `M` and every pair of
injective (equivalently bijective) families `S, T : Fin M → ZMod M`, some residue carries a
nonzero parity-weighted count.  So a gap-closing configuration has width at most `M - 1`, while
`ParityGap.parity_gap_closes_of_even` produces configurations of every width up to `M - 2`. -/
theorem parity_gap_open_at_full_width (S T : Fin M → ZMod M) (hS : Function.Injective S)
    (hT : Function.Injective T) : ∃ r : ZMod M, permCoeff S T r ≠ 0 := by
  by_contra hall
  push_neg at hall
  have hdet := det_ez_full_ne_zero S T hS hT
  rw [det_ez_eq_sum_permCoeff'] at hdet
  simp [hall] at hdet

/-- **The parity gap never closes at width `M - 1` either.**  If `n + 1 = M` and `S, T` are
injective, some residue carries a nonzero parity-weighted count.

The proof combines two ingredients: a vanishing counter makes the DFT minor singular, so its rows
carry a nontrivial linear relation `c`; transplanting `c` to a function `w` on `ZMod M` supported
on the image of `S` (of size `M - 1`) gives a nonzero function whose Fourier transform vanishes on
the image of `T`, hence is supported at a single point.  The uncertainty principle
`FourierCyclic.uncertainty_zmod` then demands `M ≤ (M - 1) · 1`, which is absurd. -/
theorem parity_gap_open_at_width_pred {n : ℕ} (hnM : n + 1 = M) (S T : Fin n → ZMod M)
    (hS : Function.Injective S) (hT : Function.Injective T) :
    ∃ r : ZMod M, permCoeff S T r ≠ 0 := by
  classical
  by_contra hall
  push_neg at hall
  -- a vanishing counter makes the minor singular
  have hdet : (Matrix.of fun j k : Fin n => ez (S j * T k)).det = 0 := by
    rw [det_ez_eq_sum_permCoeff']
    simp [hall]
  obtain ⟨c, hc0, hc⟩ := Matrix.exists_vecMul_eq_zero_iff.2 hdet
  -- transplant the kernel vector to a function on `ZMod M`
  set w : ZMod M → ℂ := fun x => ∑ j, if S j = x then (starRingEnd ℂ) (c j) else 0 with hw
  have hwS : ∀ j, w (S j) = (starRingEnd ℂ) (c j) := by
    intro j
    simp only [hw]
    rw [Finset.sum_eq_single j (fun i _ hij => by
      simp only [if_neg (fun h : S i = S j => hij (hS h))]) (fun h => absurd (mem_univ j) h)]
    simp
  have hwmem : ∀ x : ZMod M, w x ≠ 0 → x ∈ univ.image S := by
    intro x hx
    by_contra hmem
    apply hx
    simp only [hw]
    refine Finset.sum_eq_zero fun j _ => ?_
    have : S j ≠ x := fun h => hmem (Finset.mem_image.2 ⟨j, mem_univ j, h⟩)
    simp [this]
  have hwne : w ≠ 0 := by
    obtain ⟨j, hj⟩ : ∃ j, c j ≠ 0 := by
      by_contra h
      push_neg at h
      exact hc0 (funext h)
    intro hzero
    have : w (S j) = 0 := by rw [hzero]; rfl
    rw [hwS j] at this
    exact hj (by simpa using congrArg (starRingEnd ℂ) this)
  -- the transform of `w` vanishes on the image of `T`
  have hdftT : ∀ k : Fin n, FourierCyclic.dftZMod w (T k) = 0 := by
    intro k
    have hvec : ∑ j, c j * ez (S j * T k) = 0 := by
      have h := congrFun hc k
      simpa [Matrix.vecMul, dotProduct] using h
    have hexp : ∀ j : Fin n,
        Complex.exp (-(2 * Real.pi * Complex.I * (((T k).val : ℂ) * ((S j).val : ℂ))) / M)
          = (starRingEnd ℂ) (ez (S j * T k)) := by
      intro j
      rw [ez_mul_eq_om_pow, om_pow_eq_exp, ← Complex.exp_conj]
      congr 1
      push_cast
      simp only [map_div₀, map_mul, map_natCast, Complex.conj_I, Complex.conj_ofNat,
        Complex.conj_ofReal]
      ring
    rw [FourierCyclic.dftZMod]
    calc ∑ x : ZMod M,
          Complex.exp (-(2 * Real.pi * Complex.I * (((T k).val : ℂ) * (x.val : ℂ))) / M) * w x
        = ∑ x : ZMod M, ∑ j, (if S j = x then
            Complex.exp (-(2 * Real.pi * Complex.I * (((T k).val : ℂ) * (x.val : ℂ))) / M) *
              (starRingEnd ℂ) (c j) else 0) := by
          refine Finset.sum_congr rfl fun x _ => ?_
          rw [hw, Finset.mul_sum]
          exact Finset.sum_congr rfl fun j _ => by split_ifs <;> simp
      _ = ∑ j, ∑ x : ZMod M, (if S j = x then
            Complex.exp (-(2 * Real.pi * Complex.I * (((T k).val : ℂ) * (x.val : ℂ))) / M) *
              (starRingEnd ℂ) (c j) else 0) := Finset.sum_comm
      _ = ∑ j, (starRingEnd ℂ) (ez (S j * T k)) * (starRingEnd ℂ) (c j) := by
          refine Finset.sum_congr rfl fun j _ => ?_
          rw [Finset.sum_ite_eq univ (S j) (fun x =>
            Complex.exp (-(2 * Real.pi * Complex.I * (((T k).val : ℂ) * (x.val : ℂ))) / M) *
              (starRingEnd ℂ) (c j)), if_pos (mem_univ _), hexp j]
      _ = (starRingEnd ℂ) (∑ j, c j * ez (S j * T k)) := by
          rw [map_sum]
          exact Finset.sum_congr rfl fun j _ => by rw [map_mul, mul_comm]
      _ = 0 := by rw [hvec, map_zero]
  -- cardinality bounds and the uncertainty principle
  have h1 : (FourierFA.supp w).card ≤ n := by
    have hsub : FourierFA.supp w ⊆ univ.image S := fun x hx =>
      hwmem x (FourierFA.mem_supp.mp hx)
    calc (FourierFA.supp w).card ≤ (univ.image S).card := Finset.card_le_card hsub
      _ ≤ (univ : Finset (Fin n)).card := Finset.card_image_le
      _ = n := by simp
  have h2 : (FourierFA.supp (FourierCyclic.dftZMod w)).card ≤ 1 := by
    have hsub : FourierFA.supp (FourierCyclic.dftZMod w) ⊆ univ \ univ.image T := by
      intro y hy
      refine Finset.mem_sdiff.2 ⟨mem_univ _, fun hmem => ?_⟩
      obtain ⟨k, -, rfl⟩ := Finset.mem_image.mp hmem
      exact FourierFA.mem_supp.mp hy (hdftT k)
    have hTcard : (univ.image T).card = n := by
      rw [Finset.card_image_of_injective _ hT, Finset.card_univ, Fintype.card_fin]
    calc (FourierFA.supp (FourierCyclic.dftZMod w)).card
        ≤ (univ \ univ.image T).card := Finset.card_le_card hsub
      _ = M - n := by rw [Finset.card_univ_diff, hTcard, ZMod.card]
      _ = 1 := by omega
  have hunc := FourierCyclic.uncertainty_zmod w hwne
  have : M ≤ n := by
    calc M ≤ (FourierFA.supp w).card * (FourierFA.supp (FourierCyclic.dftZMod w)).card := hunc
      _ ≤ n * 1 := Nat.mul_le_mul h1 h2
      _ = n := by ring
  omega

end FullWidth

/-! ## The exact width for even moduli -/

/-- The parity gap **closes at width `n` over `ZMod m`** when some injective pair
`S, T : Fin n → ZMod m` has identically vanishing parity-weighted exponent counter. -/
def GapCloses (m n : ℕ) : Prop :=
  ∃ S T : Fin n → ZMod m, Function.Injective S ∧ Function.Injective T ∧
    ∀ r : ZMod m, permCoeff S T r = 0

/-- Above width `m - 2` the gap never closes, for any modulus `m ≥ 1`. -/
theorem not_gapCloses_of_width_large {m n : ℕ} (hm : 0 < m) (hn : m ≤ n + 1) :
    ¬ GapCloses m n := by
  haveI : NeZero m := ⟨by omega⟩
  rintro ⟨S, T, hS, hT, hzero⟩
  have hnm : n ≤ m := by
    have := Fintype.card_le_of_injective S hS
    simpa [ZMod.card] using this
  rcases (by omega : n = m ∨ n + 1 = m) with rfl | hpred
  · obtain ⟨r, hr⟩ := parity_gap_open_at_full_width S T hS hT
    exact hr (hzero r)
  · obtain ⟨r, hr⟩ := parity_gap_open_at_width_pred hpred S T hS hT
    exact hr (hzero r)

/-- **The maximal width of a closed parity gap over an even modulus is exactly `m - 2`.**  For
every even `m ≥ 4` and every `n ≥ 2` the gap closes at width `n` if and only if `n ≤ m - 2`.
The positive direction is the pigeonhole construction `ParityGap.parity_gap_closes_of_even`, the
negative one the Vandermonde/uncertainty obstructions at widths `m - 1` and `m`. -/
theorem gapCloses_iff_of_even {m n : ℕ} (hm : 4 ≤ m) (heven : 2 ∣ m) (hn : 2 ≤ n) :
    GapCloses m n ↔ n ≤ m - 2 := by
  constructor
  · intro hclose
    by_contra hlt
    exact not_gapCloses_of_width_large (by omega) (by omega) hclose
  · intro h
    exact parity_gap_closes_of_even hm heven hn h

/-- **Two-sided bound on the maximal width for a composite modulus.**  For composite `m` the gap
closes at every width `2 ≤ n ≤ m - p` (`p` the least prime factor) and never at width `m - 1` or
`m`.  For `p = 2` the two bounds meet. -/
theorem gapCloses_of_not_prime_and_not_above {m n : ℕ} (hm : 2 ≤ m) (hnp : ¬ m.Prime)
    (hn : 2 ≤ n) :
    (n ≤ m - m.minFac → GapCloses m n) ∧ (m ≤ n + 1 → ¬ GapCloses m n) :=
  ⟨fun h => parity_gap_closes_of_not_prime_wide hm hnp hn h,
    fun h => not_gapCloses_of_width_large (by omega) h⟩

end ParityGap