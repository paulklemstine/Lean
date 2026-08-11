import Mathlib
import Logic.StronglyCompleteSets.Contrarian
import Combinatorics.StronglyCompleteBlocks

/-!
# Congruence obstructions, the analytic divergence hypothesis, and strong completeness

This file continues the analysis of complete and strongly complete sets of natural
numbers (definitions from `Logic/StronglyCompleteSets/Contrarian.lean`, ordered-block
machinery from `Combinatorics/StronglyCompleteBlocks.lean`).

Main contributions.

* A **positive criterion**: if `A` contains all large multiples of some `d ≥ 1` and meets
  every residue class mod `d` infinitely often, then `A` is strongly complete
  (`stronglyComplete_of_multiples_and_residues`).  In particular a set containing all even
  numbers and infinitely many odd ones is strongly complete, in sharp contrast with the
  set `evenWithOne` of the previous file.

* A **refutation of the parity conjecture**: "complete + infinitely many odd elements ⟹
  strongly complete" is false.  The witness `threeAndUnits = 3ℕ ∪ {1, 2}` has infinitely
  many odd elements (all odd multiples of `3`), is complete, but loses completeness after
  deleting the two elements `1, 2`: the obstruction is modulo `3`, not modulo `2`.

* The **analytic divergence hypothesis** of the source paper is formalized with
  `ℝ≥0∞`-valued sums (`SqDistDiverges`), and is shown to *exclude exactly* congruence
  obstructions of this kind: divergence at the rational points `1/d` forces `A` to contain
  infinitely many elements outside every subgroup `dℕ`
  (`infinite_not_dvd_of_sqDistDiverges`).  Consequently the counterexamples above are
  invisible to the paper's theorem, as they must be.
-/

namespace StronglyCompleteSets

/-! ## A positive criterion: an arithmetic backbone plus residues -/

/-- `A` represents all large multiples of `d` as subset sums. -/
def CompleteMod (d : ℕ) (A : Set ℕ) : Prop :=
  ∃ N : ℕ, ∀ q, N ≤ q → IsSubsetSum A (d * q)

/-- `A` represents all large multiples of `d` even after any finite deletion:
a *backbone* for the subgroup `dℕ`. -/
def StronglyCompleteMod (d : ℕ) (A : Set ℕ) : Prop :=
  ∀ F : Set ℕ, F.Finite → CompleteMod d (A \ F)

/-- **Backbone-and-residues criterion.**  Suppose `A` contains a subset `B` which, after
any finite deletion, still represents all large multiples of `d`, and suppose every
residue class mod `d` meets `A` infinitely often.  Then `A` is strongly complete.

The backbone supplies size, the residues supply congruence repair; the point is that both
features survive finite deletions, which is exactly what strong completeness needs. -/
theorem stronglyComplete_of_backbone_and_residues {A B : Set ℕ} (d : ℕ) (hd : 1 ≤ d)
    (hBA : B ⊆ A) (hB : StronglyCompleteMod d B)
    (hres : ∀ r, r < d → {a ∈ A | a % d = r}.Infinite) :
    StronglyComplete A := by
  classical
  intro F hF
  obtain ⟨M, hM⟩ := hF.bddAbove
  -- pick, for every residue, one large representative
  have H : ∀ r : ℕ, ∃ b : ℕ, (b ∈ A ∧ b % d = r % d) ∧ M < b := by
    intro r
    have hr : r % d < d := Nat.mod_lt _ (by omega)
    obtain ⟨b, hb, hbM⟩ := (hres (r % d) hr).exists_gt M
    exact ⟨b, ⟨hb.1, hb.2⟩, hbM⟩
  choose g hg hgM using H
  set P : ℕ := (Finset.range d).sup g with hP
  have hgP : ∀ r, r < d → g r ≤ P := fun r hr =>
    Finset.le_sup (f := g) (Finset.mem_range.mpr hr)
  -- the backbone survives deletion of `F` and of everything below `P`
  obtain ⟨N₁, hN₁⟩ := hB (F ∪ Set.Iic P) (hF.union (Set.finite_Iic P))
  refine ⟨P + d * N₁ + 1, fun n hn => ?_⟩
  set r : ℕ := n % d with hr
  have hrd : r < d := Nat.mod_lt _ (by omega)
  set a : ℕ := g r with ha
  have haA : a ∈ A := (hg r).1
  have hamod : a % d = r % d := (hg r).2
  have haM : M < a := hgM r
  have haP : a ≤ P := hgP r hrd
  have hrr : r % d = r := Nat.mod_eq_of_lt hrd
  have han : a ≤ n := by omega
  -- the complement is a multiple of `d`
  have hdvd : d ∣ n - a := by
    refine (Nat.modEq_iff_dvd' han).mp ?_
    show a % d = n % d
    rw [hamod, hrr]
  obtain ⟨q, hq⟩ := hdvd
  have hqN : N₁ ≤ q := by
    by_contra hcon
    push_neg at hcon
    have h1 : d * q ≤ d * N₁ := Nat.mul_le_mul_left d (le_of_lt hcon)
    omega
  obtain ⟨s, hs, hsum⟩ := hN₁ q hqN
  have hsP : ∀ x ∈ s, P < x := by
    intro x hx
    have := hs hx
    simp only [Set.mem_diff, Set.mem_union, Set.mem_Iic, not_or, not_le] at this
    exact this.2.2
  have hanots : a ∉ s := fun hmem => absurd (hsP a hmem) (by omega)
  refine ⟨insert a s, ?_, ?_⟩
  · intro x hx
    simp only [Finset.coe_insert, Set.mem_insert_iff] at hx
    rcases hx with rfl | hx
    · exact ⟨haA, fun hxF => by have := hM hxF; omega⟩
    · have hxs := hs hx
      simp only [Set.mem_diff, Set.mem_union, Set.mem_Iic, not_or] at hxs
      exact ⟨hBA hxs.1, hxs.2.1⟩
  · rw [Finset.sum_insert hanots, hsum]
    omega

/-- **Multiples-and-residues criterion.**  If `A` contains every multiple `d * m` with
`m ≥ K`, and each residue class mod `d` contains infinitely many elements of `A`, then `A`
is strongly complete. -/
theorem stronglyComplete_of_multiples_and_residues {A : Set ℕ} (d : ℕ) (hd : 1 ≤ d) (K : ℕ)
    (hmul : ∀ m, K ≤ m → d * m ∈ A)
    (hres : ∀ r, r < d → {a ∈ A | a % d = r}.Infinite) :
    StronglyComplete A := by
  classical
  refine stronglyComplete_of_backbone_and_residues (B := {n | ∃ m, K ≤ m ∧ n = d * m}) d hd
    ?_ ?_ hres
  · rintro x ⟨m, hm, rfl⟩
    exact hmul m hm
  · intro F hF
    obtain ⟨M, hM⟩ := hF.bddAbove
    refine ⟨max K (M + 1), fun q hq => ?_⟩
    have hqK : K ≤ q := le_trans (le_max_left _ _) hq
    have hqM : M < q := by
      have := le_trans (le_max_right K (M + 1)) hq
      omega
    have hdq : q ≤ d * q := Nat.le_mul_of_pos_left q (by omega)
    refine ⟨{d * q}, ?_, by simp⟩
    intro x hx
    simp only [Finset.coe_singleton, Set.mem_singleton_iff] at hx
    subst hx
    exact ⟨⟨q, hqK, rfl⟩, fun hxF => by have := hM hxF; omega⟩

/-! ## A construction principle: dilation plus residue enrichment -/

/-- The whole of `ℕ` is strongly complete. -/
theorem stronglyComplete_univ : StronglyComplete (Set.univ : Set ℕ) := by
  intro F hF
  obtain ⟨M, hM⟩ := hF.bddAbove
  refine ⟨M + 1, fun n hn => ⟨{n}, ?_, by simp⟩⟩
  intro x hx
  simp only [Finset.coe_singleton, Set.mem_singleton_iff] at hx
  subst hx
  exact ⟨Set.mem_univ x, fun hxF => by have := hM hxF; omega⟩

/-- The dilate `d · A` of a strongly complete set is a backbone for the subgroup `dℕ`. -/
theorem stronglyCompleteMod_dilate {A : Set ℕ} (d : ℕ) (hd : 1 ≤ d)
    (hA : StronglyComplete A) :
    StronglyCompleteMod d ((fun a => d * a) '' A) := by
  classical
  intro F hF
  have hinj : Function.Injective (fun a : ℕ => d * a) := by
    intro a b hab
    simp only at hab
    have : d * a = d * b := hab
    exact Nat.eq_of_mul_eq_mul_left (by omega) this
  have hF' : ((fun a : ℕ => d * a) ⁻¹' F).Finite :=
    Set.Finite.preimage (Set.injOn_of_injective hinj) hF
  obtain ⟨N, hN⟩ := hA _ hF'
  refine ⟨N, fun q hq => ?_⟩
  obtain ⟨s, hs, hsum⟩ := hN q hq
  refine ⟨s.image (fun a => d * a), ?_, ?_⟩
  · intro x hx
    simp only [Finset.coe_image, Set.mem_image, Finset.mem_coe] at hx
    obtain ⟨a, ha, rfl⟩ := hx
    obtain ⟨haA, haF⟩ := hs ha
    exact ⟨⟨a, haA, rfl⟩, haF⟩
  · rw [Finset.sum_image (fun a _ b _ hab => hinj hab), ← Finset.mul_sum, hsum]

/-- **Dilation principle.**  Scaling a strongly complete set by `d` and adding any set that
meets every residue class mod `d` infinitely often again produces a strongly complete set.
This manufactures strongly complete sets living on prescribed scales. -/
theorem stronglyComplete_dilate_union_residues {A C : Set ℕ} (d : ℕ) (hd : 1 ≤ d)
    (hA : StronglyComplete A)
    (hres : ∀ r, r < d → {a ∈ ((fun a => d * a) '' A) ∪ C | a % d = r}.Infinite) :
    StronglyComplete (((fun a => d * a) '' A) ∪ C) :=
  stronglyComplete_of_backbone_and_residues d hd Set.subset_union_left
    (stronglyCompleteMod_dilate d hd hA) hres

/-- A set containing all even numbers and infinitely many odd numbers is strongly
complete.  Compare `evenWithOne`, which contains a *single* odd number and is complete but
not strongly complete. -/
theorem stronglyComplete_of_evens_and_infinite_odds {A : Set ℕ}
    (heven : ∀ m : ℕ, 2 * m ∈ A) (hodd : {a ∈ A | a % 2 = 1}.Infinite) :
    StronglyComplete A := by
  refine stronglyComplete_of_multiples_and_residues 2 (by norm_num) 0 (fun m _ => heven m) ?_
  intro r hr
  interval_cases r
  · refine Set.infinite_of_injective_forall_mem (f := fun k : ℕ => 2 * k) ?_ ?_
    · intro a b hab; simp only at hab; omega
    · intro k
      refine ⟨heven k, ?_⟩
      simp only
      omega
  · exact hodd

/-! ## Refuting the parity conjecture -/

/-- Multiples of three together with the two units `1` and `2`. -/
def threeAndUnits : Set ℕ := {n | 3 ∣ n} ∪ {1, 2}

theorem mem_threeAndUnits {n : ℕ} : n ∈ threeAndUnits ↔ 3 ∣ n ∨ n = 1 ∨ n = 2 := by
  simp only [threeAndUnits, Set.mem_union, Set.mem_setOf_eq, Set.mem_insert_iff,
    Set.mem_singleton_iff]

/-- `threeAndUnits` is complete. -/
theorem threeAndUnits_complete : Complete threeAndUnits := by
  refine ⟨3, fun n hn => ?_⟩
  have h3 : n % 3 = 0 ∨ n % 3 = 1 ∨ n % 3 = 2 := by omega
  rcases h3 with h | h | h
  · exact ⟨{n}, by
      intro x hx
      simp only [Finset.coe_singleton, Set.mem_singleton_iff] at hx
      subst hx
      exact mem_threeAndUnits.mpr (Or.inl (by omega)), by simp⟩
  · have hne : (1 : ℕ) ≠ n - 1 := by omega
    refine ⟨{1, n - 1}, ?_, ?_⟩
    · intro x hx
      simp only [Finset.coe_insert, Set.mem_insert_iff, Finset.coe_singleton,
        Set.mem_singleton_iff] at hx
      rcases hx with rfl | rfl
      · exact mem_threeAndUnits.mpr (Or.inr (Or.inl rfl))
      · exact mem_threeAndUnits.mpr (Or.inl (by omega))
    · rw [Finset.sum_pair hne]; omega
  · have hne : (2 : ℕ) ≠ n - 2 := by omega
    refine ⟨{2, n - 2}, ?_, ?_⟩
    · intro x hx
      simp only [Finset.coe_insert, Set.mem_insert_iff, Finset.coe_singleton,
        Set.mem_singleton_iff] at hx
      rcases hx with rfl | rfl
      · exact mem_threeAndUnits.mpr (Or.inr (Or.inr rfl))
      · exact mem_threeAndUnits.mpr (Or.inl (by omega))
    · rw [Finset.sum_pair hne]; omega

/-- `threeAndUnits` contains infinitely many odd numbers, namely all odd multiples
of three. -/
theorem threeAndUnits_infinite_odd : {a ∈ threeAndUnits | Odd a}.Infinite := by
  refine Set.infinite_of_injective_forall_mem (f := fun k : ℕ => 6 * k + 3) ?_ ?_
  · intro a b hab; simp only at hab; omega
  · intro k
    exact ⟨mem_threeAndUnits.mpr (Or.inl ⟨2 * k + 1, by ring⟩), ⟨3 * k + 1, by ring⟩⟩

/-- Deleting the two units destroys completeness: the remaining set consists of multiples
of three. -/
theorem threeAndUnits_not_stronglyComplete : ¬ StronglyComplete threeAndUnits := by
  intro h
  obtain ⟨N, hN⟩ := h {1, 2} (Set.toFinite _)
  obtain ⟨s, hs, hsum⟩ := hN (3 * N + 1) (by omega)
  have hdvd : (3 : ℕ) ∣ ∑ a ∈ s, a := by
    refine Finset.dvd_sum (fun a ha => ?_)
    obtain ⟨hmem, hnot⟩ := hs ha
    have h1 : a ≠ 1 := by
      intro h; exact hnot (by simp [h])
    have h2 : a ≠ 2 := by
      intro h; exact hnot (by simp [h])
    rcases mem_threeAndUnits.mp hmem with h | h | h
    · exact h
    · exact absurd h h1
    · exact absurd h h2
  rw [hsum] at hdvd
  omega

/-- **Refutation of the parity conjecture.**  Completeness plus infinitely many odd
elements does *not* imply strong completeness: the obstruction may live modulo `3`. -/
theorem complete_infinite_odd_not_stronglyComplete :
    ∃ A : Set ℕ, Complete A ∧ {a ∈ A | Odd a}.Infinite ∧ ¬ StronglyComplete A :=
  ⟨threeAndUnits, threeAndUnits_complete, threeAndUnits_infinite_odd,
    threeAndUnits_not_stronglyComplete⟩

/-! ## A necessary congruence condition for strong completeness -/

/-- **Necessary condition.**  A strongly complete set must contain, for every modulus
`d ≥ 2`, infinitely many elements outside the subgroup `dℕ`; otherwise deleting the finitely
many exceptions leaves only sums divisible by `d`. -/
theorem infinite_not_dvd_of_stronglyComplete {A : Set ℕ} (hA : StronglyComplete A)
    (d : ℕ) (hd : 2 ≤ d) : {a ∈ A | ¬ (d : ℕ) ∣ a}.Infinite := by
  intro hfin
  obtain ⟨N, hN⟩ := hA {a ∈ A | ¬ (d : ℕ) ∣ a} hfin
  obtain ⟨s, hs, hsum⟩ := hN (d * N + 1) (by nlinarith)
  have hdvd : d ∣ ∑ a ∈ s, a := by
    refine Finset.dvd_sum (fun a ha => ?_)
    obtain ⟨haA, hout⟩ := hs ha
    by_contra hcon
    exact hout ⟨haA, hcon⟩
  rw [hsum] at hdvd
  obtain ⟨t, ht⟩ := hdvd
  rcases Nat.lt_or_ge t (N + 1) with h | h
  · have : d * t ≤ d * N := Nat.mul_le_mul_left d (by omega)
    omega
  · have : d * (N + 1) ≤ d * t := Nat.mul_le_mul_left d h
    have hdN : d * (N + 1) = d * N + d := by ring
    omega

/-! ## The analytic divergence hypothesis -/

/-- Distance from a real number to the nearest integer. -/
noncomputable def distToInt (x : ℝ) : ℝ := min (Int.fract x) (1 - Int.fract x)

theorem distToInt_nonneg (x : ℝ) : 0 ≤ distToInt x := by
  have h1 : 0 ≤ Int.fract x := Int.fract_nonneg x
  have h2 : Int.fract x < 1 := Int.fract_lt_one x
  simp only [distToInt, le_min_iff]
  constructor <;> linarith

theorem distToInt_natCast (n : ℕ) : distToInt (n : ℝ) = 0 := by
  simp [distToInt, Int.fract_natCast]

/-- At the rational point `1/d`, elements not divisible by `d` are at distance at least
`1/d` from the integers. -/
theorem distToInt_ge_of_not_dvd {d a : ℕ} (hd : 2 ≤ d) (h : ¬ (d : ℕ) ∣ a) :
    1 / (d : ℝ) ≤ distToInt ((a : ℝ) * (1 / d : ℝ)) := by
  have hdR : (0 : ℝ) < d := by positivity
  have hx : ((a : ℝ) * (1 / d)) = (a : ℝ) / (d : ℝ) := by ring
  rw [hx, distToInt, Int.fract_div_natCast_eq_div_natCast_mod]
  have hr0 : a % d ≠ 0 := fun hc => h (Nat.dvd_of_mod_eq_zero hc)
  have hr1 : 1 ≤ a % d := Nat.one_le_iff_ne_zero.mpr hr0
  have hr2 : a % d + 1 ≤ d := by
    have := Nat.mod_lt a (show 0 < d by omega)
    omega
  have hc1 : (1 : ℝ) ≤ ((a % d : ℕ) : ℝ) := by exact_mod_cast hr1
  have hc2 : ((a % d : ℕ) : ℝ) + 1 ≤ (d : ℝ) := by exact_mod_cast hr2
  refine le_min ?_ ?_
  · gcongr
  · rw [le_sub_iff_add_le, ← add_div, div_le_one hdR]
    linarith

/-- The paper's analytic hypothesis: for every non-integral `θ`, the sum of
`‖aθ‖²` over `a ∈ A` diverges.  The sum is taken in `ℝ≥0∞`, so divergence is the clean
statement that it equals `⊤`. -/
noncomputable def SqDistDiverges (A : Set ℕ) : Prop :=
  ∀ θ : ℝ, θ ∉ Set.range ((↑) : ℤ → ℝ) →
    ∑' a : A, ENNReal.ofReal (distToInt ((a : ℕ) * θ) ^ 2) = ⊤

/-- **Arithmetic meaning of divergence at the rational test points.**  For `d ≥ 2`, the
series `∑ ‖a/d‖²` over `a ∈ A` diverges exactly when infinitely many elements of `A` avoid
the subgroup `dℕ`.  This is the precise bridge between the analytic hypothesis and the
congruence obstruction that governs strong completeness. -/
theorem tsum_sqDist_top_iff {A : Set ℕ} {d : ℕ} (hd : 2 ≤ d) :
    (∑' a : A, ENNReal.ofReal (distToInt ((a : ℕ) * (1 / d : ℝ)) ^ 2) = ⊤) ↔
      {a ∈ A | ¬ (d : ℕ) ∣ a}.Infinite := by
  classical
  set S : Set ℕ := {a ∈ A | ¬ (d : ℕ) ∣ a} with hS
  constructor
  · intro htop hfin
    have hpre : (Subtype.val ⁻¹' S : Set A).Finite :=
      Set.Finite.preimage (Set.injOn_of_injective Subtype.val_injective) hfin
    have hzero : ∀ x : A, x ∉ hpre.toFinset →
        ENNReal.ofReal (distToInt ((x : ℕ) * (1 / d : ℝ)) ^ 2) = 0 := by
      intro x hx
      have hxS : (x : ℕ) ∉ S := fun hh => hx ((Set.Finite.mem_toFinset hpre).mpr hh)
      have hdvd : (d : ℕ) ∣ (x : ℕ) := by
        by_contra hcon
        exact hxS ⟨x.2, hcon⟩
      obtain ⟨t, ht⟩ := hdvd
      have hcast : ((x : ℕ) : ℝ) * (1 / d : ℝ) = (t : ℕ) := by
        have hdR : (d : ℝ) ≠ 0 := by positivity
        rw [ht]
        push_cast
        field_simp
      rw [hcast, distToInt_natCast]
      simp
    have hne : ∑' a : A, ENNReal.ofReal (distToInt ((a : ℕ) * (1 / d : ℝ)) ^ 2) ≠ ⊤ := by
      rw [tsum_eq_sum hzero]
      refine LT.lt.ne ?_
      rw [ENNReal.sum_lt_top]
      intro a _
      exact ENNReal.ofReal_lt_top
    exact hne htop
  · intro hinf
    have hSinf : Infinite ↥S := hinf.to_subtype
    set c : ENNReal := ENNReal.ofReal ((1 / d : ℝ) ^ 2) with hc
    have hcpos : c ≠ 0 := by
      rw [hc, ne_eq, ENNReal.ofReal_eq_zero, not_le]
      positivity
    -- the inclusion of `S` into `A`
    have hSA : ∀ x : S, (x : ℕ) ∈ A := fun x => x.2.1
    set i : S → A := fun x => ⟨(x : ℕ), hSA x⟩ with hi
    have hinj : Function.Injective i := by
      intro x y hxy
      have hval : ((i x : A) : ℕ) = ((i y : A) : ℕ) := congrArg Subtype.val hxy
      exact Subtype.ext hval
    have hle1 : ∀ x : S, c ≤ ENNReal.ofReal (distToInt (((i x : A) : ℕ) * (1 / d : ℝ)) ^ 2) := by
      intro x
      have hnd : ¬ (d : ℕ) ∣ (x : ℕ) := x.2.2
      have hge := distToInt_ge_of_not_dvd (a := (x : ℕ)) hd hnd
      have hpos : (0 : ℝ) < 1 / d := by positivity
      refine ENNReal.ofReal_le_ofReal ?_
      have := mul_self_le_mul_self (le_of_lt hpos) hge
      calc (1 / (d : ℝ)) ^ 2 = (1 / (d : ℝ)) * (1 / (d : ℝ)) := by ring
      _ ≤ distToInt (((x : ℕ) : ℝ) * (1 / d : ℝ)) * distToInt (((x : ℕ) : ℝ) * (1 / d : ℝ)) :=
          this
      _ = distToInt (((x : ℕ) : ℝ) * (1 / d : ℝ)) ^ 2 := by ring
    have hconst : ∑' _ : S, c = ⊤ := ENNReal.tsum_const_eq_top_of_ne_zero hcpos
    have hstep : (⊤ : ENNReal) ≤
        ∑' x : S, ENNReal.ofReal (distToInt (((i x : A) : ℕ) * (1 / d : ℝ)) ^ 2) := by
      rw [← hconst]
      exact ENNReal.tsum_le_tsum hle1
    have hfinal := le_trans hstep
      (ENNReal.tsum_comp_le_tsum_of_injective hinj
        (fun a : A => ENNReal.ofReal (distToInt ((a : ℕ) * (1 / d : ℝ)) ^ 2)))
    exact top_le_iff.mp hfinal

/-- **The divergence hypothesis excludes congruence obstructions.**  If `A` satisfies the
analytic divergence hypothesis then, for every modulus `d ≥ 2`, infinitely many elements of
`A` are not divisible by `d`; that is, `A` automatically satisfies the necessary condition
`infinite_not_dvd_of_stronglyComplete` for strong completeness. -/
theorem infinite_not_dvd_of_sqDistDiverges {A : Set ℕ} (h : SqDistDiverges A)
    (d : ℕ) (hd : 2 ≤ d) : {a ∈ A | ¬ (d : ℕ) ∣ a}.Infinite := by
  have hdpos : (0 : ℝ) < d := by positivity
  have hθ : (1 / d : ℝ) ∉ Set.range ((↑) : ℤ → ℝ) := by
    rintro ⟨z, hz⟩
    have h0 : (0 : ℝ) < 1 / d := by positivity
    have h1 : (1 / d : ℝ) < 1 := by
      rw [div_lt_one hdpos]
      exact_mod_cast lt_of_lt_of_le one_lt_two (by exact_mod_cast hd)
    have hz0 : (0 : ℝ) < z := hz ▸ h0
    have hz1 : (z : ℝ) < 1 := hz ▸ h1
    have hz0' : (0 : ℤ) < z := by exact_mod_cast hz0
    have hz1' : (z : ℤ) < 1 := by exact_mod_cast hz1
    omega
  exact (tsum_sqDist_top_iff hd).mp (h (1 / d) hθ)

/-- The multiples of three fail the analytic divergence hypothesis, as they must: they
have at least six elements in each large dyadic block yet are not complete. -/
theorem multiplesOfThree_not_sqDistDiverges : ¬ SqDistDiverges multiplesOfThree := by
  intro h
  have hinf := infinite_not_dvd_of_sqDistDiverges h 3 (by norm_num)
  obtain ⟨a, ha⟩ := hinf.nonempty
  exact ha.2 ha.1

/-- The parity counterexample `threeAndUnits` also fails the analytic divergence
hypothesis: only the two units escape the subgroup `3ℕ`.  So the paper's theorem is not
contradicted by it. -/
theorem threeAndUnits_not_sqDistDiverges : ¬ SqDistDiverges threeAndUnits := by
  intro h
  have hinf := infinite_not_dvd_of_sqDistDiverges h 3 (by norm_num)
  refine hinf (Set.Finite.subset (Set.toFinite ({1, 2} : Set ℕ)) ?_)
  rintro a ⟨ha, hna⟩
  rcases mem_threeAndUnits.mp ha with h3 | h1 | h2
  · exact absurd h3 hna
  · simp [h1]
  · simp [h2]

/-- **Strongly complete sets diverge at every rational test point.**  Combining the
necessary congruence condition with the arithmetic characterization of divergence at
`1/d`, every strongly complete set satisfies the rational instances of the paper's
analytic hypothesis. -/
theorem tsum_sqDist_top_of_stronglyComplete {A : Set ℕ} (hA : StronglyComplete A)
    {d : ℕ} (hd : 2 ≤ d) :
    ∑' a : A, ENNReal.ofReal (distToInt ((a : ℕ) * (1 / d : ℝ)) ^ 2) = ⊤ :=
  (tsum_sqDist_top_iff hd).mpr (infinite_not_dvd_of_stronglyComplete hA d hd)

end StronglyCompleteSets