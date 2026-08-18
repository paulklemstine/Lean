import Mathlib

/-!
# The subset spectrum of a finite group action

For a finite group `G` acting on a finite set `X` (`n := |X|`) the **subset spectrum**
is the sequence

`t_r := ` number of `G`-orbits on the `r`-element subsets of `X`,   `0 ≤ r ≤ n`.

This is the classical sequence of a permutation group (Livingstone–Wagner, Cameron).
This file sets up a *computable* model of the spectrum (`SubsetSpectrum.spec`) built from
`Finset.powersetCard` and orbit `Finset`s, and establishes its basic structural theory:

* `SubsetSpectrum.spec_zero`, `SubsetSpectrum.spec_card` : the two boundary values are `1`;
* `SubsetSpectrum.spec_pos`, `SubsetSpectrum.spec_eq_zero_of_lt` : support of the spectrum;
* `SubsetSpectrum.spec_compl` : the complementation symmetry `t_r = t_{n-r}`;
* `SubsetSpectrum.spec_le_choose` and `SubsetSpectrum.choose_le_card_mul_spec` :
  the two-sided sandwich `C(n,r)/|G| ≤ t_r ≤ C(n,r)`;
* `SubsetSpectrum.spec_of_trivial_action` : for the trivial action `t_r = C(n,r)`;
* `SubsetSpectrum.spec_eq_one_iff` : `t_r = 1` is exactly `r`-homogeneity, and
  `SubsetSpectrum.spec_one_eq_one_iff_pretransitive` : `t_1 = 1` is exactly transitivity;
* `SubsetSpectrum.spec_perm_eq_one` : the symmetric group is set-transitive;
* `Nat.choose_mul_choose_le_choose_sq` : log-concavity of the binomial coefficients
  (proved from scratch — Mathlib has no log-concavity API).

The log-concavity question itself is treated in `Applications.ActionSpectrum.LogConcavity`.
-/

open Finset

/-! ## Log-concavity of binomial coefficients -/

/-- **Log-concavity of the binomial coefficients**: `C(n,k)·C(n,k+2) ≤ C(n,k+1)²`.
Proved from the Pascal-type identity `C(n,k+1)·(k+1) = C(n,k)·(n-k)`. -/
theorem Nat.choose_mul_choose_le_choose_sq (n k : ℕ) :
    n.choose k * n.choose (k + 2) ≤ n.choose (k + 1) ^ 2 := by
  rcases Nat.lt_or_ge (k + 1) n with hn | hn
  · set a := n.choose k
    set b := n.choose (k + 1)
    set c := n.choose (k + 2)
    have h1 : b * (k + 1) = a * (n - k) := Nat.choose_succ_right_eq n k
    have h2 : c * (k + 2) = b * (n - (k + 1)) := Nat.choose_succ_right_eq n (k + 1)
    have hnk : n - k = (n - (k + 1)) + 1 := by omega
    set m := n - (k + 1) with hm
    have key : a * c * ((k + 1) * (k + 2)) ≤ b ^ 2 * ((k + 1) * (k + 2)) := by
      have e1 : a * c * ((k + 1) * (k + 2)) = (a * (k + 1)) * (c * (k + 2)) := by ring
      have e2 : b ^ 2 * ((k + 1) * (k + 2)) = (b * (k + 1)) * (b * (k + 2)) := by ring
      rw [e1, e2, h1, h2, hnk]
      have hstep : (k + 1) * m ≤ (m + 1) * (k + 2) := by nlinarith
      calc a * (k + 1) * (b * m) = (a * b) * ((k + 1) * m) := by ring
        _ ≤ (a * b) * ((m + 1) * (k + 2)) := Nat.mul_le_mul_left _ hstep
        _ = a * (m + 1) * (b * (k + 2)) := by ring
    exact Nat.le_of_mul_le_mul_right key (by positivity)
  · have : n.choose (k + 2) = 0 := Nat.choose_eq_zero_of_lt (by omega)
    simp [this]

namespace SubsetSpectrum

variable {G X : Type*} [Group G] [MulAction G X] [DecidableEq X]

/-! ## The induced action on finite subsets -/

/-- The induced action of `g : G` on a finite subset of `X`. -/
def act (g : G) (s : Finset X) : Finset X := s.image (fun x => g • x)

@[simp] lemma mem_act {g : G} {s : Finset X} {x : X} : x ∈ act g s ↔ g⁻¹ • x ∈ s := by
  simp only [act, mem_image]
  constructor
  · rintro ⟨y, hy, rfl⟩; simpa using hy
  · intro h; exact ⟨g⁻¹ • x, h, by simp⟩

@[simp] lemma act_one (s : Finset X) : act (1 : G) s = s := by ext x; simp

lemma act_mul (g h : G) (s : Finset X) : act (g * h) s = act g (act h s) := by
  ext x; simp [act, mul_smul]

@[simp] lemma act_card (g : G) (s : Finset X) : (act g s).card = s.card :=
  Finset.card_image_of_injective _ (MulAction.injective g)

lemma act_compl [Fintype X] (g : G) (s : Finset X) : act g sᶜ = (act g s)ᶜ := by ext x; simp

lemma act_singleton (g : G) (x : X) : act g {x} = {g • x} := by
  simp [act]

variable (G) in
/-- The `G`-orbit of a finite subset `s ⊆ X`, as a finite set of finite subsets. -/
def orb [Fintype G] (s : Finset X) : Finset (Finset X) := univ.image (fun g : G => act g s)

variable (G X) in
/-- `spec G X r = t_r` is the number of `G`-orbits on the `r`-element subsets of `X`:
the `r`-th term of the **subset spectrum** of the action. -/
def spec [Fintype G] [Fintype X] (r : ℕ) : ℕ :=
  (((univ : Finset X).powersetCard r).image (orb G)).card

variable [Fintype G]

lemma mem_orb_self (s : Finset X) : s ∈ orb G s := by
  simp only [orb, mem_image]
  exact ⟨1, mem_univ _, act_one s⟩

lemma orb_card_le (s : Finset X) : (orb G s).card ≤ Fintype.card G := by
  simpa [orb, Finset.card_univ] using
    Finset.card_image_le (s := (univ : Finset G)) (f := fun g : G => act g s)

lemma card_of_mem_orb {s t : Finset X} (h : t ∈ orb G s) : t.card = s.card := by
  simp only [orb, mem_image] at h
  obtain ⟨g, -, rfl⟩ := h
  simp

/-- Membership in an orbit is an equivalence: orbits of members coincide. -/
lemma orb_eq_of_mem {s t : Finset X} (h : t ∈ orb G s) : orb G t = orb G s := by
  simp only [orb, mem_image] at h
  obtain ⟨g, -, rfl⟩ := h
  ext u
  simp only [orb, mem_image, mem_univ, true_and]
  constructor
  · rintro ⟨h', rfl⟩; exact ⟨h' * g, by rw [act_mul]⟩
  · rintro ⟨h', rfl⟩
    exact ⟨h' * g⁻¹, by rw [← act_mul, mul_assoc, inv_mul_cancel, mul_one]⟩

lemma orb_eq_iff {s t : Finset X} : orb G s = orb G t ↔ t ∈ orb G s := by
  constructor
  · intro h; rw [h]; exact mem_orb_self t
  · intro h; exact (orb_eq_of_mem h).symm

variable [Fintype X]

/-! ## Boundary values and support -/

@[simp] theorem spec_zero : spec G X 0 = 1 := by
  simp [spec, Finset.powersetCard_zero]

@[simp] theorem spec_card : spec G X (Fintype.card X) = 1 := by
  have h : ((univ : Finset X).powersetCard (Fintype.card X)) = {univ} := by
    rw [← Finset.card_univ]; exact Finset.powersetCard_self _
  rw [spec, h]
  simp

theorem spec_eq_zero_of_lt {r : ℕ} (h : Fintype.card X < r) : spec G X r = 0 := by
  rw [spec, Finset.powersetCard_eq_empty.2 (by simpa using h)]
  simp

theorem spec_pos {r : ℕ} (h : r ≤ Fintype.card X) : 0 < spec G X r := by
  rw [spec, Finset.card_pos]
  exact (Finset.powersetCard_nonempty.2 (by simpa using h)).image _

/-! ## The sandwich `C(n,r)/|G| ≤ t_r ≤ C(n,r)` -/

theorem spec_le_choose (r : ℕ) : spec G X r ≤ (Fintype.card X).choose r := by
  simpa [spec, Finset.card_powersetCard] using
    Finset.card_image_le (s := ((univ : Finset X).powersetCard r)) (f := orb G)

theorem choose_le_card_mul_spec (r : ℕ) :
    (Fintype.card X).choose r ≤ Fintype.card G * spec G X r := by
  set S := ((univ : Finset X).powersetCard r) with hS
  have hsub : S ⊆ (S.image (orb G)).biUnion id := by
    intro s hs
    simp only [Finset.mem_biUnion, Finset.mem_image, id]
    exact ⟨orb G s, ⟨s, hs, rfl⟩, mem_orb_self s⟩
  have h1 : S.card ≤ ((S.image (orb G)).biUnion id).card := Finset.card_le_card hsub
  have h2 : ((S.image (orb G)).biUnion id).card ≤ ∑ O ∈ S.image (orb G), O.card :=
    Finset.card_biUnion_le
  have h3 : ∑ O ∈ S.image (orb G), O.card ≤ ∑ _O ∈ S.image (orb G), Fintype.card G := by
    refine Finset.sum_le_sum ?_
    intro O hO
    simp only [Finset.mem_image] at hO
    obtain ⟨s, -, rfl⟩ := hO
    exact orb_card_le s
  have h4 : S.card = (Fintype.card X).choose r := by simp [hS, Finset.card_powersetCard]
  rw [Finset.sum_const, smul_eq_mul] at h3
  calc (Fintype.card X).choose r = S.card := h4.symm
    _ ≤ Fintype.card G * spec G X r := by
        rw [spec, ← hS, mul_comm]
        exact le_trans h1 (le_trans h2 h3)

/-! ## Complementation symmetry -/

lemma orb_compl (s : Finset X) : (orb G s).image (fun u => uᶜ) = orb G sᶜ := by
  simp only [orb, Finset.image_image]
  exact Finset.image_congr (fun g _ => by simp [Function.comp, act_compl])

lemma powersetCard_compl {r : ℕ} (hr : r ≤ Fintype.card X) :
    ((univ : Finset X).powersetCard r).image (fun s => sᶜ)
      = (univ : Finset X).powersetCard (Fintype.card X - r) := by
  ext s
  simp only [mem_image, mem_powersetCard, Finset.subset_univ, true_and]
  constructor
  · rintro ⟨u, hu, rfl⟩; rw [card_compl, hu]
  · intro hs; exact ⟨sᶜ, by rw [card_compl, hs]; omega, compl_compl s⟩

/-- **Symmetry of the spectrum**: `t_{n-r} = t_r`, via `s ↦ sᶜ`. -/
theorem spec_compl {r : ℕ} (hr : r ≤ Fintype.card X) :
    spec G X (Fintype.card X - r) = spec G X r := by
  have hinj :
      Function.Injective (fun O : Finset (Finset X) => O.image (fun u : Finset X => uᶜ)) := by
    intro O P hOP
    have := congrArg (fun Q : Finset (Finset X) => Q.image (fun u : Finset X => uᶜ)) hOP
    simpa [Finset.image_image, Function.comp] using this
  have key : ((univ : Finset X).powersetCard (Fintype.card X - r)).image (orb G)
      = (((univ : Finset X).powersetCard r).image (orb G)).image
          (fun O : Finset (Finset X) => O.image (fun u : Finset X => uᶜ)) := by
    rw [Finset.image_image, ← powersetCard_compl hr, Finset.image_image]
    exact Finset.image_congr (fun s _ => (orb_compl s).symm)
  rw [spec, spec, key, Finset.card_image_of_injective _ hinj]

/-! ## Two extreme actions -/

/-- For the trivial action every orbit is a singleton, so the spectrum is the
binomial row: `t_r = C(n,r)`. -/
theorem spec_of_trivial_action (htriv : ∀ (g : G) (x : X), g • x = x) (r : ℕ) :
    spec G X r = (Fintype.card X).choose r := by
  have horb : ∀ s : Finset X, orb G s = {s} := by
    intro s
    ext u
    simp only [orb, mem_image, mem_univ, true_and, Finset.mem_singleton]
    constructor
    · rintro ⟨g, rfl⟩
      ext x; simp [act, htriv]
    · rintro rfl; exact ⟨1, act_one _⟩
  have hinj : Function.Injective (orb G (X := X)) := by
    intro s t hst
    rw [horb s, horb t] at hst
    exact Finset.singleton_injective hst
  rw [spec, Finset.card_image_of_injective _ hinj, Finset.card_powersetCard, Finset.card_univ]

/-! ## `t_r = 1` and `r`-homogeneity -/

/-- **`t_r = 1` is exactly `r`-homogeneity**: the value `1` of the spectrum at `r` says
that `G` is transitive on the `r`-element subsets of `X`. -/
theorem spec_eq_one_iff {r : ℕ} (hr : r ≤ Fintype.card X) :
    spec G X r = 1 ↔ ∀ s t : Finset X, s.card = r → t.card = r → ∃ g : G, act g s = t := by
  constructor
  · intro h s t hs ht
    obtain ⟨O, hO⟩ := Finset.card_eq_one.1 h
    have hs' : s ∈ (univ : Finset X).powersetCard r := mem_powersetCard.2 ⟨subset_univ _, hs⟩
    have ht' : t ∈ (univ : Finset X).powersetCard r := mem_powersetCard.2 ⟨subset_univ _, ht⟩
    have h1 : orb G s = O := by
      have := Finset.mem_image_of_mem (orb G) hs'
      rw [hO, Finset.mem_singleton] at this
      exact this
    have h2 : orb G t = O := by
      have := Finset.mem_image_of_mem (orb G) ht'
      rw [hO, Finset.mem_singleton] at this
      exact this
    have hmem : t ∈ orb G s := by rw [h1, ← h2]; exact mem_orb_self _
    simp only [orb, mem_image, mem_univ, true_and] at hmem
    exact hmem
  · intro h
    obtain ⟨s₀, hs₀⟩ := Finset.powersetCard_nonempty.2 (le_trans hr (le_of_eq Finset.card_univ.symm))
    refine Finset.card_eq_one.2 ⟨orb G s₀, Finset.eq_singleton_iff_unique_mem.2
      ⟨Finset.mem_image_of_mem _ hs₀, ?_⟩⟩
    rintro O hO
    obtain ⟨s, hs, rfl⟩ := Finset.mem_image.1 hO
    obtain ⟨g, hg⟩ := h s₀ s (mem_powersetCard.1 hs₀).2 (mem_powersetCard.1 hs).2
    exact orb_eq_of_mem (by simp only [orb, mem_image, mem_univ, true_and]; exact ⟨g, hg⟩)

/-- **`t_1 = 1` is exactly transitivity** of the action (for nonempty `X`). -/
theorem spec_one_eq_one_iff_pretransitive [Nonempty X] :
    spec G X 1 = 1 ↔ ∀ x y : X, ∃ g : G, g • x = y := by
  have hr : 1 ≤ Fintype.card X := Fintype.card_pos
  rw [spec_eq_one_iff hr]
  constructor
  · intro h x y
    obtain ⟨g, hg⟩ := h {x} {y} (by simp) (by simp)
    rw [act_singleton] at hg
    exact ⟨g, Finset.singleton_injective hg⟩
  · intro h s t hs ht
    obtain ⟨x, rfl⟩ := Finset.card_eq_one.1 hs
    obtain ⟨y, rfl⟩ := Finset.card_eq_one.1 ht
    obtain ⟨g, hg⟩ := h x y
    exact ⟨g, by rw [act_singleton, hg]⟩

/-- The full symmetric group is set-transitive: all its spectrum values are `1`. -/
theorem spec_perm_eq_one {r : ℕ} (hr : r ≤ Fintype.card X) :
    spec (Equiv.Perm X) X r = 1 := by
  rw [spec_eq_one_iff hr]
  intro s t hs ht
  have h : s.card = t.card := by rw [hs, ht]
  have hc1 : Fintype.card {x // x ∈ s} = Fintype.card {x // x ∈ t} := by
    simp [Fintype.card_coe, h]
  have hc2 : Fintype.card {x // x ∉ s} = Fintype.card {x // x ∉ t} := by
    have h1 : Fintype.card {x // x ∉ s} = Fintype.card X - s.card := by
      simp [Fintype.card_subtype_compl, Fintype.card_coe]
    have h2 : Fintype.card {x // x ∉ t} = Fintype.card X - t.card := by
      simp [Fintype.card_subtype_compl, Fintype.card_coe]
    rw [h1, h2, h]
  obtain e1 := Fintype.equivOfCardEq hc1
  obtain e2 := Fintype.equivOfCardEq hc2
  set g : Equiv.Perm X :=
    (Equiv.sumCompl (· ∈ s)).symm.trans ((e1.sumCongr e2).trans (Equiv.sumCompl (· ∈ t))) with hg
  refine ⟨g, ?_⟩
  have hsub : act g s ⊆ t := by
    intro y hy
    simp only [act, Finset.mem_image] at hy
    obtain ⟨x, hx, rfl⟩ := hy
    have hgx : g x = (e1 ⟨x, hx⟩ : X) := by
      simp [hg, Equiv.sumCompl_symm_apply_of_pos hx]
    simp only [Equiv.Perm.smul_def, hgx]
    exact (e1 ⟨x, hx⟩).2
  refine Finset.eq_of_subset_of_card_le hsub ?_
  rw [act_card, h]

end SubsetSpectrum